# vim:foldmethod=marker:foldlevel=0
{ writeShellApplication
, pkgs
}: writeShellApplication {
  name = "preview";
  runtimeInputs = with pkgs; [
    bat
    chafa
  ];

  text = ''
    directory(){ #{{{
      normal=$(tput sgr0)
      green=$(tput setaf 2 bold)
      # print infomation of directory
      printf '%s %s %s %s %s %s' \
        "''${green}Total:''${normal}" \
        "$(find -L "$1" -maxdepth 1 -mindepth 1 | wc -l)" \
        "''${green}Dir:''${normal}" \
        "$(find -L "$1" -maxdepth 1 -mindepth 1 -type d | wc -l)" \
        "''${green}File:''${normal}" \
        "$(find -L "$1" -maxdepth 1 -mindepth 1 -type f | wc -l)"

      # if directory is symbolic link
      if [ -h "$1" ]; then
        blue=$(tput setaf 4 bold)
        printf "\t\t->''${blue}%s''${normal}" "$(realpath "$1")"
      fi

      printf '\n'

      if type lsd >/dev/null; then
        lsd -A --group-directories-first --color=always "$1"
      elif type exa >/dev/null; then
        exa -a --group-directories-first --icons --color=always "$1"
      else
        ls -A --group-directories-first --color=always "$1"
      fi
    } #}}}
    # TODO: ls solution
    file_info(){ #{{{
      if type lsd >/dev/null; then
        lsd -l --color=always "$1"
      elif type exa >/dev/null; then
        exa -l --icons --color=always "$1"
      else
        ls -l --color=always "$1"
      fi
      printf '\n'
    } #}}}
    cat_file(){ #{{{
      bat -n --style=plain --pager=never --color=always "$1"
      # cat "$1"
    } #}}}
    image(){ #{{{
      chafa "$1"
    } #}}}

    if [ -z "''${1+x}" ]; then
      echo "Usage: ''${0##*/} filename" >&2
      exit 1
    fi

    file="$1"

    if [ -d "$file" ]; then
      directory "$file"
      exit
    fi

    if [ ! -f "$file" ]; then
      echo 'File not found!' >&2
      exit 1
    fi

    file_info "$file"

    case $(readlink -f "$file" | tr '[:upper:]' '[:lower:]') in
      *.tgz|*.tar.gz) tar tzf "$file" ;;
      *.tar.bz2|*.tbz2) tar tjf "$file" ;;
      *.tar.txz|*.txz) xz --list "$file" ;;
      *.tar) tar tf "$file" ;;
      *.zip|*.jar|*.war|*.ear|*.oxt) unzip -l "$file" ;;
      *.rar) unrar l "$file" ;;
      *.7z) 7z l "$file" ;;

      *.[1-8]) man "$file" | col -b ;;

      *.png|*.jpg|*.jpeg|*.webp) image "$file" ;;

      # TODO:
      # *.gif) ;;
      # *.pdf) ;;

      *) cat_file "$file"
    esac
  '';
}
