# pay-respects: suggest a fix for the previous command (mise.toml).
zsh_requires command pay-respects || return
zsh_init_cache pay-respects zsh --alias || return
source $REPLY

# Its release includes an AI module that sends commands no rule can fix to an
# online LLM service. Remove this line to opt in.
export _PR_AI_DISABLE=1
zsh_help 'f' 'fix the previous command'
