#!/bin/bash
# Builder script, see README. Run from ..!
# This is not run by CI. Run manually and commit the resulting files.

for goal in */*/*/; do
    goal=${goal%*/} # Remove trailing slash
    IFS='/' read -r -a parts <<< "$goal"

    version="${parts[0]}"
    base="${parts[1]}"
    variant="${parts[2]}"

    # GD options for various PHP versions
    if [[ "7.4" == "$version" ]]
    then
        GD_OPTIONS="--with-freetype --with-jpeg"
    else
        GD_OPTIONS="--with-gd --with-webp-dir --with-jpeg-dir --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir"
    fi

    if [[ "builder" == "$version" ]]
    then
        continue
    fi
    echo "# THIS IS AUTO-GENERATED by builder/build.sh. DO NOT EDIT." > "$version/$base/$variant/Dockerfile"
    echo "FROM php:$version-$variant-$base" >> "$version/$base/$variant/Dockerfile"

    # Read base Dockefile, first three lines are skipped.
    tail -n +4 builder/Dockerfile >> "$version/$base/$variant/Dockerfile"
    sed -e "s/\@@gd_requirements@@/$GD_OPTIONS/" -i "$version/$base/$variant/Dockerfile"

    # If apache: Copy Vhost and add it
    if [[ "apache" == "$variant" ]]
    then
        cp "builder/000-default.conf" "$version/$base/$variant/"
        echo "COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf" >> "$version/$base/$variant/Dockerfile"
    fi

    cp "README.md" "$version/$base/$variant/"

done
