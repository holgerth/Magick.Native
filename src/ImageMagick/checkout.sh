#!/bin/bash
set -e

clone() {
  local repo=$1
  local dir=$2
  local root="https://github.com/ImageMagick"

  echo ''
  echo "Cloning $1"

  if [ ! -d "$dir" ]; then
    git clone $root/$repo.git $dir
    if [ $? != 0 ]; then echo "Error during checkout"; exit; fi
  fi
  cd $dir
  git pull origin main
  cd ..
}

clone_commit()
{
  local repo=$1
  local commit=$2
  local dir=$repo

  clone $repo $dir

  cd $dir
  git checkout $commit
  cd ..
}

clone_date()
{
  local repo=$1
  local date=$2
  local dir=$repo

  clone $repo $dir

  cd $dir
  git checkout `git rev-list -n 1 --before="$date" origin/main`
  cd ..
}

create_notice()
{
  local output=$1

  if [ -z "$output" ]; then
    output=../output
  fi

  mkdir -p $output
  local notice=$output/Notice.txt
  echo -e "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n" > $notice
  echo -e "[ Magick.Native ] copyright:\n" >> $notice
  local charset="$(file -bi ../../Magick.Native/Copyright.txt | awk -F "=" '{print $2}')"
  iconv -f $charset -t utf-8 ../../Magick.Native/Copyright.txt | sed -e 's/\xef\xbb\xbf//' | sed -e 's/\r//g' >> $notice

  for dir in *; do
    if [ -d "$dir" ]; then
      local config=VisualMagick/$dir/Config.txt
      if [ -f "$config" ]; then
        echo -e "\n* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n" >> $notice
        echo -e "[ $dir ] copyright:\n" >> $notice
        copyright="$(sed -n '/\[LICENSE\]/{n;p;}' $config | sed -e 's/\r//g' | sed -e 's/\.\.\\//g' | sed -e 's/\\/\//g')"
        if [ -f "$copyright" ]; then
          local charset="$(file -bi $copyright | awk -F "=" '{print $2}')"
          iconv -f $charset -t utf-8 $copyright | sed -e 's/\xef\xbb\xbf//' | sed -e 's/\r//g' >> $notice
        fi
      fi
    fi
  done

  echo -e "\n* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n" >> $notice
}

commit=$(<ImageMagick.commit)

if [ ! -d "libraries" ]; then
  mkdir libraries
fi

cd libraries

clone_commit 'ImageMagick' $commit

# get a commit date from the current ImageMagick checkout
cd ImageMagick
declare -r commitDate=`git log -1 --format=%ci`
echo "Set latest commit date as $commitDate" 
cd ..

clone_date 'freetype' "$commitDate"
clone_date 'jpeg-turbo' "$commitDate"
clone_date 'lcms' "$commitDate"
clone_date 'libde265' "$commitDate"
clone_date 'libheif' "$commitDate"
clone_date 'libraw' "$commitDate"
clone_date 'libxml' "$commitDate"
clone_date 'openjpeg' "$commitDate"
clone_date 'png' "$commitDate"
clone_date 'tiff' "$commitDate"
clone_date 'VisualMagick' "$commitDate"
clone_date 'webp' "$commitDate"
clone_date 'zlib' "$commitDate"

if [ "$1" == "wasm" ]; then
  create_notice $2
  exit
fi

clone_date 'aom' "$commitDate"
clone_date 'cairo' "$commitDate"
clone_date 'croco' "$commitDate"
clone_date 'exr' "$commitDate"
clone_date 'ffi' "$commitDate"
clone_date 'fribidi' "$commitDate"
clone_date 'glib' "$commitDate"
clone_date 'harfbuzz' "$commitDate"
clone_date 'lqr' "$commitDate"
clone_date 'pango' "$commitDate"
clone_date 'pixman' "$commitDate"
clone_date 'librsvg' "$commitDate"

if [ "$1" == "macos" ] || [ "$1" == "linux" ]; then
  if [ ! -d fontconfig ]; then
    git clone https://gitlab.freedesktop.org/fontconfig/fontconfig fontconfig
  fi
  cd fontconfig
  git reset --hard
  git fetch
  git checkout 2.12.6
  cd ..

  mkdir -p VisualMagick/fontconfig
  echo -e "[LICENSE]\nfontconfig/COPYING" > VisualMagick/fontconfig/Config.txt
fi

if [ "$1" == "macos" ]; then
  create_notice $2
  exit
fi

clone_date 'brotli' "$commitDate"
clone_date 'bzlib' "$commitDate"
clone_date 'highway' "$commitDate"
clone_date 'jpeg-xl' "$commitDate"
clone_date 'liblzma' "$commitDate"
clone_date 'libzip' "$commitDate"

if [ "$1" == "linux" ]; then
  create_notice $2
  exit
fi

clone_date 'flif' "$commitDate"
clone_date 'jp2' "$commitDate"

create_notice $2

rm -rf VisualMagick/dcraw
rm -rf VisualMagick/demos
rm -rf VisualMagick/fuzz
rm -rf VisualMagick/ImageMagickObject
rm -rf VisualMagick/IMDisplay
rm -rf VisualMagick/iptcutil
rm -rf VisualMagick/jbig
rm -rf VisualMagick/Magick++
rm -rf VisualMagick/NtMagick
rm -rf VisualMagick/tests
rm -rf VisualMagick/utilities
