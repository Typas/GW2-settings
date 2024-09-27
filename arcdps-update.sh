#!/usr/bin/env sh

GW2PATH="$HOME/.local/share/Steam/steamapps/common/Guild Wars 2"
ARCDPS_FILENAME="d3d11.dll"
ARCDPS_URL="https://www.deltaconnected.com/arcdps/x64/$ARCDPS_FILENAME"
ARCDPS_MD5_URL="https://www.deltaconnected.com/arcdps/x64/$ARCDPS_FILENAME.md5sum"
BOON_TABLE_FILENAME="d3d9_arcdps_table.dll"
BOON_TABLE_BASE_URL="https://github.com/knoxfighter/GW2-ArcDPS-Boon-Table/releases/latest"
BOON_TABLE_DOWNLOAD_URL="$BOON_TABLE_BASE_URL/download/$BOON_TABLE_FILENAME"
HEALING_STATS_FILENAME="arcdps_healing_stats.dll"
HEALING_STATS_BASE_URL="https://github.com/Krappa322/arcdps_healing_stats/releases/latest"
HEALING_STATS_DOWNLOAD_URL="$HEALING_STATS_BASE_URL/download/$HEALING_STATS_FILENAME"
MECHANICS_FILENAME="d3d9_arcdps_mechanics.dll"
MECHANICS_BASE_URL="https://github.com/knoxfighter/GW2-ArcDPS-Mechanics-Log/releases/latest"
MECHANICS_DOWNLOAD_URL="$MECHANICS_BASE_URL/download/$MECHANICS_FILENAME"

cd /tmp
rm -f $ARCDPS_FILENAME "$ARCDPS_FILENAME.md5sum" $BOON_TABLE_FILENAME $HEALING_STATS_FILENAME
echo "downloading arcdps md5sum"
wget2 "$ARCDPS_MD5_URL"
rsync "$GW2PATH/$ARCDPS_FILENAME" $ARCDPS_FILENAME
md5sum -c $ARCDPS_FILENAME.md5sum >& /dev/null
if [ $? -eq 0 ]; then
    echo "arcdps is latest"
else
    echo "downloading arcdps"
    wget2 "$ARCDPS_URL"
    md5sum -c $ARCDPS_FILENAME.md5sum || exit 1
    rsync -uv $ARCDPS_FILENAME "$GW2PATH/$ARCDPS_FILENAME"
fi


# checking for github update
ADDON_VERSIONS_PATH="$GW2PATH/addons_ver.txt"
VERSIONS=
if [ -f "$ADDON_VERSIONS_PATH" ]; then
    # needs bash 4.0
    readarray -t VERSIONS < "$ADDON_VERSIONS_PATH"
fi
BOON_TABLE_VERSION_URL=$(curl -Ls -o /dev/null -w %{url_effective} $BOON_TABLE_BASE_URL)
HEALING_STATS_VERSION_URL=$(curl -Ls -o /dev/null -w %{url_effective} $HEALING_STATS_BASE_URL)
MECHANICS_VERSION_URL=$(curl -Ls -o /dev/null -w %{url_effective} $MECHANICS_BASE_URL)

if [ "$BOON_TABLE_VERSION_URL" != "${VERSIONS[0]}" ]; then
    wget2 "$BOON_TABLE_DOWNLOAD_URL"
    rsync -uv $BOON_TABLE_FILENAME "$GW2PATH/$BOON_TABLE_FILENAME"
else
    echo "boon table is latest"
fi
if [ "$HEALING_STATS_VERSION_URL" != "${VERSIONS[1]}" ]; then
    wget2 "$HEALING_STATS_DOWNLOAD_URL"
    rsync -uv $HEALING_STATS_FILENAME "$GW2PATH/$HEALING_STATS_FILENAME"
else
    echo "healing stats is latest"
fi
if [ "$MECHANICS_VERSION_URL" != "${VERSIONS[2]}" ]; then
    wget2 "$MECHANICS_DOWNLOAD_URL"
    rsync -uv $MECHANICS_FILENAME "$GW2PATH/$MECHANICS_FILENAME"
else
    echo "mechanics is latest"
fi

cat > "$ADDON_VERSIONS_PATH" <<EOF
$BOON_TABLE_VERSION_URL
$HEALING_STATS_VERSION_URL
$MECHANICS_VERSION_URL
EOF
