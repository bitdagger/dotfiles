if [[ ! -f /etc/pacman.d/mirrorlist ]]; then
    return
fi

reflectorize() {
    sudo su <<'EOF'
    cat /etc/pacman.d/mirrorlist >> /etc/pacman.d/mirrorlist.top
    rm -f /etc/pacman.d/mirrorlist
    reflector -c "United States" -p http -a 24 -f 5 --sort rate --save /etc/pacman.d/mirrorlist
EOF
}
