#!/bin/bash
# originally from https://github.com/ryotarai/dotfiles, thx.

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function symlink() {
SRC=$1
DST=$2
echo "symlink ${SRC} -> ${DST}"
if [ ! -e "${DST}" ] ; then
    ln -is "${SRC}" "${DST}"
    echo "> created"
else
    echo "> skipped (${DST} already exists)"
fi
}

# home
WORKDIR="${BASEDIR}/home"
cd $WORKDIR
for dotfile in *; do
    symlink "${WORKDIR}/${dotfile}" "$HOME/.${dotfile}"
done

# vim temp directories
mkdir -p "${HOME}/.vim.swap"
mkdir -p "${HOME}/.vim.backup"

