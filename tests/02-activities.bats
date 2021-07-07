#!/usr/bin/env bats

load bats-support/load
load bats-assert/load
load bats-mock/load


function setup() {
   mkdir -p "${BATS_TMPDIR:?/tmp}/$BATS_TEST_NAME"
   cd "$BATS_TMPDIR/$BATS_TEST_NAME" || \
      fail "unable to cd in $BATS_TMPDIR/BTNBATS_TEST_NAME"
   export CACHEDIR="/tmp/$BATS_TEST_NAME.cache"
}
function teardown() {
   [[ -d $CACHEDIR ]] && rm -rf "$CACHEDIR"
   [[ -d "${BATS_TMPDIR:?/tmp}/$BATS_TEST_NAME" ]] && \
      rm -rf "${BATS_TMPDIR:?/tmp}/$BATS_TEST_NAME"
}

SRC="$BATS_TEST_DIRNAME/.."

export _TESTING=true
load "$SRC/rofi-hamster"

load "$BATS_TEST_DIRNAME"/data.sh

@test 'activities are parsed as expected' {
   export _HAMSTER="$(mock_create)"
   mock_set_output "$_HAMSTER" 'willbeoverridebyxsv'
   export _XSV="$(mock_create)"
   mock_set_output "$_XSV" "$(hamster_xsv_export)"

   run activities

   expected_activities | assert_output -
   
}

