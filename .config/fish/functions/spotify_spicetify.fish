function spotify_spicetify --description "Configure spicetify permissions and backup for Spotify"
    set -l spotify_path "/opt/spotify"
    if test -d "$HOME/.local/share/spotify-launcher/install/usr/share/spotify"
        set spotify_path "$HOME/.local/share/spotify-launcher/install/usr/share/spotify"
    end

    set -l prefs_path "$HOME/.config/spotify/prefs"

    if not test -d "$spotify_path"
        echo "Error: Spotify not found at $spotify_path. Is it installed?"
        return 1
    end

    echo "Using Spotify path: $spotify_path"
    spicetify config spotify_path "$spotify_path"
    spicetify config prefs_path "$prefs_path"

    echo "Setting directory permissions..."
    sudo chmod a+wr "$spotify_path"
    sudo chmod a+wr -R "$spotify_path/Apps"

    if contains -- "-f" $argv
        echo "Forcing backup reset..."
        rm -rf ~/.config/spicetify/Backup
    end

    echo "Cleaning up previous backup state..."
    spicetify restore backup 2>/dev/null

    echo "Applying Spicetify..."
    spicetify backup apply
end
