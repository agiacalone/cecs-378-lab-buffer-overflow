# shellcheck shell=bash
# Override the bash prompt to read "mainframe" regardless of the actual
# container hostname (Codespaces does not permit --hostname via
# devcontainer runArgs).
case $- in *i*) ;; *) return ;; esac

export PS1='\[\033[36m\]\u@mainframe\[\033[0m\]:\w\$ '

# First-prompt hook. Runs AFTER any personal-dotfiles ~/.bashrc has
# loaded, before the very first prompt renders. We use this to:
#   1. Force PS1 back to the mainframe prompt if personal dotfiles
#      overrode it (common — most custom prompts replace PS1 wholesale).
#   2. cd to $HOME on SSH sessions so the dial-in feel matches a real
#      Unix login. Skip for VS Code terminals (they should stay at the
#      workspace folder, where the user is editing).
__mainframe_first_prompt() {
    [ -n "$__MAINFRAME_BOOTED" ] && return
    __MAINFRAME_BOOTED=1
    PS1='\[\033[36m\]\u@mainframe\[\033[0m\]:\w\$ '
    if [ -n "$SSH_CONNECTION" ] && [ -z "$VSCODE_IPC_HOOK_CLI" ]; then
        cd 2>/dev/null || true
    fi
}
PROMPT_COMMAND="__mainframe_first_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
