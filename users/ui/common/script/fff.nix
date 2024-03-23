{ writeShellApplication
, pkgs
}: writeShellApplication {
  name = "fff";
  runtimeInputs = with pkgs; [
    fzf
    (callPackage ./preview.nix { })
  ];

  text = ''
    set +o errexit

    # Setting ls command
    if type lsd >/dev/null; then
      _fzf_fm_lscmd='lsd -A --group-directories-first --color=always'
    elif type exa >/dev/null; then
      _fzf_fm_lscmd='exa -a --group-directories-first --icons --color=always'
    else
      _fzf_fm_lscmd='ls -A --group-directories-first --color=always'
    fi

    # Temp file
    _fff_up_dir_temp='/tmp/fff-up-dir'

    while :; do
      # prepare the prompt to show current directory
      pwd="$(pwd | sed "s#^$HOME#~#")"

      # shellcheck disable=SC2000
      if [ "$(echo "$pwd" | wc -c)" -gt 25 ]; then
        # only show first char
        pwd="$(printf '%s' "$pwd" | sed 's#\([^/.]\)[^/]\+/#\1/#g')"
      fi

      # shellcheck disable=SC2016
      selected="$($_fzf_fm_lscmd "$PWD" |
        fzf --prompt "$pwd/" \
            --preview 'preview $PWD/{}' \
            --preview-window '70%,border-left' \
            --ansi \
            --height 100 \
            --info inline \
            --color prompt:245 \
            --cycle \
            --bind left:"execute(touch $_fff_up_dir_temp)+abort",right:accept \
            --bind ctrl-h:"execute(touch $_fff_up_dir_temp)+abort",ctrl-l:accept
      )"

      # Go upper dir
      if [ -f "$_fff_up_dir_temp" ]; then
        rm -f "$_fff_up_dir_temp"
        cd ..
        continue
      fi

      # End, if no selected
      [ -z "$selected" ] && return

      # Open the selected
      file="$PWD/$selected"
      if [ -d "$file" ]; then
        cd "$file"
      elif type open >/dev/null 2>&1; then
        open "$file"
      elif [ "$(file --mime-type "$file" -bL | sed 's#/.*$##')" = 'text' ]; then
        $EDITOR "$file"
      fi
    done
  '';
}
