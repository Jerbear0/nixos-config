# Enhanced /etc/nixos git status indicator (read-only)  
nixos_git_status() {  
  if [ ! -d /etc/nixos/.git ]; then  
    return  
  fi  
  
  local oldpwd  
  oldpwd=$(pwd)  
  cd /etc/nixos 2>/dev/null || return  
  
  # Local dirty?  
  local dirty="false"  
  if git status --porcelain 2>/dev/null | grep -q .; then  
    dirty="true"  
  fi  
  
  local branch  
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"  
  
  local ahead=0  
  local behind=0  
  
  if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then  
    # Don't care if fetch fails here; ns will fetch explicitly when run  
    local counts  
    counts=$(git rev-list --left-right --count "origin/$branch"...HEAD 2>/dev/null || echo "0 0")  
    behind=$(echo "$counts" | awk '{print $1}')  
    ahead=$(echo "$counts"  | awk '{print $2}')  
  fi  
  
  local label color_bg color_fg  
  color_fg="255;255;255"  
  
  if [ "$dirty" = "true" ]; then  
    label="nixos:dirty"  
    color_bg="204;36;29"      # red  
  elif [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then  
    label="nixos:diverged"  
    color_bg="193;132;1"      # orange-ish  
  elif [ "$behind" -gt 0 ]; then  
    label="nixos:behind"  
    color_bg="215;153;33"     # yellow  
  elif [ "$ahead" -gt 0 ]; then  
    label="nixos:ahead"  
    color_bg="69;133;136"     # blue-ish  
  else  
    label="nixos:clean"  
    color_bg="152;151;26"     # green  
  fi  
  
  # NOTE: no leading newline, just a leading space and the pill  
  printf " \e[1;48;2;%sm[%s]\e[0m" "$color_bg;$color_fg" "$label"  
  
  cd "$oldpwd" >/dev/null 2>&1 || true  
}  
  
# Wrapper that will be called from PROMPT_COMMAND in bashrc  
nixos_status_segment() {  
  nixos_git_status  
}  

