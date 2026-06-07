# Ensure gpg-agent.conf exists (handles tmpfs ~/.gnupg scenario)
# This runs before config.fish sets SSH_AUTH_SOCK

if not test -f $HOME/.gnupg/gpg-agent.conf
    mkdir -p $HOME/.gnupg
    chmod 700 $HOME/.gnupg
    echo "enable-ssh-support" > $HOME/.gnupg/gpg-agent.conf
    echo "default-cache-ttl 3600" >> $HOME/.gnupg/gpg-agent.conf
    echo "max-cache-ttl 7200" >> $HOME/.gnupg/gpg-agent.conf
    echo "default-cache-ttl-ssh 3600" >> $HOME/.gnupg/gpg-agent.conf
    echo "max-cache-ttl-ssh 7200" >> $HOME/.gnupg/gpg-agent.conf
    echo "pinentry-program /usr/bin/pinentry-gtk-2" >> $HOME/.gnupg/gpg-agent.conf
    chmod 600 $HOME/.gnupg/gpg-agent.conf
end
