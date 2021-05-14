# Start X at login
status is-login && [ -z "$DISPLAY" -a "$XDG_VTNR" = 1 ] &&  exec startx -- -keeptty

# disale useless stuf
function fish_greeting; end
function fish_mode_prompt; end

# seting up prompt
function fish_prompt
    set error $status
    set mode --bold red

    if set -q SSH_CLIENT
        set color1 green
    else
        set color1 red
    end

    switch $fish_bind_mode
        case default;     printf '[d]'
        case replace-one; printf '[r]'
        case visual;      printf '[v]'
    end

    printf '[%s%s%s] ' (set_color $color1) \
                       (basename $PWD)     \
                       (set_color normal)

end

function :q;  exit; end
function :Q;  exit; end
function :wq; exit; end
function :Wq; exit; end
function :WQ; exit; end
function md; mkdir -p $argv;    end
function rm; /bin/rm -i $argv;  end
