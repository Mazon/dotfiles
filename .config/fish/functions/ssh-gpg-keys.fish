# Show SSH keys provided by gpg-agent (Nitrokey)
function ssh-gpg-keys
    echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
    echo ""
    echo "GPG Card status:"
    gpg --card-status 2>&1 | head -20
    echo ""
    echo "SSH keys via gpg-agent:"
    ssh-add -l 2>&1
end
