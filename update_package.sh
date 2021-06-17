#!/usr/bin/env bash

cat >./package.dhall <<EOF
{
$(ls -1 *.dhall | grep -v [p]ackage.dhall | sed 's|\(.*\)\.dhall|\1 = ./\1.dhall,|')
}
EOF

dhall format --inplace ./package.dhall
