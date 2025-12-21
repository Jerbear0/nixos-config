# Function to show /etc/nixos git status  
nixos_git_status() {  
  if [ -d /etc/nixos/.git ]; then  
    cd /etc/nixos 2>/dev/null || return  
  
    if git status --porcelain 2>/dev/null | grep -q .; then  
      # Dirty: RED pill  
      # bg: 204,36,29  fg: 255,255,255 (same as your old red block)  
      printf " \e[1;48;2;204;36;29;38;2;255;255;255m[nixos:dirty]\e[0m"  
    else  
      # Clean: GREEN pill  
      # bg: 152,151,26  fg: 255,255,255 (Gruvbox-ish green)  
      printf " \e[1;48;2;152;151;26;38;2;255;255;255m[nixos:clean]\e[0m"  
    fi  
  
    cd - >/dev/null 2>&1 || true  
  fi  
}  
  
# Hook: run before each prompt  
__nixos_prompt_hook() {  
  nixos_git_status  
}  
  
# Chain into PROMPT_COMMAND (don’t clobber Starship’s integration)  
if [ -n "$PROMPT_COMMAND" ]; then  
  PROMPT_COMMAND="__nixos_prompt_hook; $PROMPT_COMMAND"  
else  
  PROMPT_COMMAND="__nixos_prompt_hook"  
fi  
 
