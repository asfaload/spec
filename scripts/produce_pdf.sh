#!/bin/bash

set -euxo pipefail
work_dir=$(mktemp -d)
git_dir=$(git rev-parse --show-toplevel)

cp "$git_dir/spec.md" "$work_dir"
cd $work_dir
mmdc -i spec.md -e png -o spec-with-images.md
pandoc spec-with-images.md -o spec.pdf
mv spec.pdf "$git_dir"

# cleanup. comment if debugging
trap 'rm -rf "$work_dir"' EXIT
