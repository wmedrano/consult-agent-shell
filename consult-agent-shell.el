;;; consult-agent-shell.el --- Consult interface for agent-shell  -*- lexical-binding: t; -*-

;; Copyright (C) 2026

;; Author: Will Medrano <will.s.medrano@gmail.com>
;; Keywords: convenience, tools
;; Package-Requires: ((emacs "28.1") (consult "1.0") (agent-shell "0.1"))
;; Version: 0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A consult interface for agent-shell.  Provides completing-read
;; commands to interact with ACP-driven LLM agents.

;;; Code:

(require 'consult)
(require 'agent-shell)

(defgroup consult-agent-shell nil
  "Consult interface for agent-shell."
  :group 'consult
  :group 'agent-shell)

(defcustom consult-agent-shell-buffer-name-format "%s @ (%s)"
  "Format string for new agent-shell buffer names.
The first %s is replaced by the user-entered name, and the second
%s is replaced by the project name."
  :type 'string
  :group 'consult-agent-shell)

(defun consult-agent-shell--format-buffer-name (name)
  "Format the agent-shell buffer name for NAME.
Uses `consult-agent-shell-buffer-name-format` and project information."
  (let ((project-name (or (when (fboundp 'project-name)
                            (when-let ((proj (project-current)))
                              (project-name proj)))
                          (file-name-nondirectory
                           (string-remove-suffix "/" default-directory)))))
    (condition-case nil
        (format consult-agent-shell-buffer-name-format name project-name)
      (error (format consult-agent-shell-buffer-name-format name)))))

(defun consult-agent-shell--annotate (name)
  "Return a status annotation string for the agent-shell buffer named NAME."
  (when-let ((buf (get-buffer name)))
    (with-current-buffer buf
      (if (shell-maker-busy) " [busy]" " [idle]"))))

;;;###autoload
(defun consult-agent-shell-switch (&optional arg)
  "Switch to an agent-shell buffer, with live preview.
If the entered name does not match an existing buffer, a new
agent-shell is created and named accordingly.
With prefix ARG, open in other window."
  (interactive "P")
  (let* ((agent-buffers (agent-shell-buffers))
         (buffer-names (mapcar #'buffer-name agent-buffers))
         (selected (consult--read
                    buffer-names
                    :prompt "Agent Shell: "
                    :require-match nil
                    :state (consult--buffer-state)
                    :category 'consult-agent-shell
                    :annotate #'consult-agent-shell--annotate))
         (existing-buffer (get-buffer selected))
         (buffer (car (memq existing-buffer agent-buffers))))
    (unless buffer
      (when (and existing-buffer (> (buffer-size existing-buffer) 0))
        (user-error "Buffer %S already exists and is not an agent-shell" selected))
      (when existing-buffer (kill-buffer existing-buffer))
      (setq buffer (agent-shell-new-shell))
      (unless (string-empty-p selected)
        (shell-maker-set-buffer-name
         buffer
         (consult-agent-shell--format-buffer-name selected))))
    (if arg
        (switch-to-buffer-other-window buffer)
      (switch-to-buffer buffer))))

;;;###autoload
(defun consult-agent-shell-send-region (&optional arg)
  "Send region to an agent-shell buffer, selected with live preview.
With prefix ARG, open the shell in other window after sending."
  (interactive "P")
  (let* ((region-text (agent-shell--get-region-context
                       :deactivate t
                       :no-error nil))
         (buffer-names (mapcar #'buffer-name
                               (or (agent-shell-buffers)
                                   (user-error "No agent shells available"))))
         (selected (consult--read
                    buffer-names
                    :prompt "Send region to Agent Shell: "
                    :require-match t
                    :state (consult--buffer-state)
                    :category 'buffer))
         (buffer (get-buffer selected)))
    (agent-shell-insert
     :text region-text
     :shell-buffer buffer)
    (if arg
        (switch-to-buffer-other-window buffer)
      (switch-to-buffer buffer))))

(provide 'consult-agent-shell)
;;; consult-agent-shell.el ends here
