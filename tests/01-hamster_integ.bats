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

@test 'new activity is added to the database' {
   export _HAMSTER="$(mock_create)"
   mock_set_output "$_HAMSTER" 'No activity'
   export _all_activities="$(mock_create)"
   export _ROFI="$(mock_create)"
   mock_set_output "$_ROFI" "test@Unsorted|"
   export _FRECE="$(mock_create)"
   export _DUNSTIFY="$(mock_create)"
   mock_set_status "$_FRECE" 1 1 
   mock_set_status "$_FRECE" 0 2 
   mock_set_status "$_FRECE" 0 3 

   run main

   assert_equal "$(mock_get_call_num "$_HAMSTER")" "2" # current + start
   assert_equal "$(mock_get_call_args "$_HAMSTER" 2)" "start test@Unsorted"
   assert_equal "$(mock_get_call_num "$_FRECE")" "3"
   assert_equal "$(mock_get_call_args "$_FRECE" 2)" "add $CACHE test@Unsorted"
   assert_equal "$(mock_get_call_args "$_FRECE" 3)" "increment $CACHE test@Unsorted"
}

@test 'existing activity is incremented in the database' {
   export _HAMSTER="$(mock_create)"
   mock_set_output "$_HAMSTER" 'No activity'
   export _all_activities="$(mock_create)"
   export _ROFI="$(mock_create)"
   mock_set_output "$_ROFI" "test@Unsorted|"
   export _FRECE="$(mock_create)"
   export _DUNSTIFY="$(mock_create)"

   run main

   assert_equal "$(mock_get_call_num "$_HAMSTER")" "2" # current + start
   assert_equal "$(mock_get_call_args "$_HAMSTER" 2)" "start test@Unsorted"
   assert_equal "$(mock_get_call_num "$_FRECE")" "1"
   assert_equal "$(mock_get_call_args "$_FRECE" 1)" "increment $CACHE test@Unsorted"
}

@test 'stop current activity' {
   export _HAMSTER="$(mock_create)"
   mock_set_output "$_HAMSTER" '2021-07-07 17:21 test@Unsorted 00:05'
   export _all_activities="$(mock_create)"
   export _ROFI="$(mock_create)"
   mock_set_output "$_ROFI" "test@Unsorted|"
   export _FRECE="$(mock_create)"
   export _DUNSTIFY="$(mock_create)"

   run main

   assert_equal "$(mock_get_call_num "$_HAMSTER")" "2" # current + stop
   assert_equal "$(mock_get_call_args "$_HAMSTER" 2)" "stop"
   assert_equal "$(mock_get_call_num "$_FRECE")" "0"
}

@test 'activity with time is started accordingly' {
   export _HAMSTER="$(mock_create)"
   mock_set_output "$_HAMSTER" '"No activity"'
   export _all_activities="$(mock_create)"
   export _ROFI="$(mock_create)"
   mock_set_output "$_ROFI" "test@Unsorted|test@Unsorted,22:30"
   export _FRECE="$(mock_create)"
   export _DUNSTIFY="$(mock_create)"

   run main

   assert_equal "$(mock_get_call_num "$_HAMSTER")" "2" # current + start
   assert_equal "$(mock_get_call_args "$_HAMSTER" 2)" "start test@Unsorted,22:30"
   assert_equal "$(mock_get_call_num "$_FRECE")" "1"
   assert_equal "$(mock_get_call_args "$_FRECE" 1)" "increment $CACHE test@Unsorted"
}

@test 'activity with duration is started accordingly' {
   export _HAMSTER="$(mock_create)"
   mock_set_output "$_HAMSTER" '"No activity"'
   export _all_activities="$(mock_create)"
   export _ROFI="$(mock_create)"
   mock_set_output "$_ROFI" "test@Unsorted|test@Unsorted , -22"
   export _FRECE="$(mock_create)"
   export _DUNSTIFY="$(mock_create)"

   run main

   assert_equal "$(mock_get_call_num "$_HAMSTER")" "2" # current + start
   assert_equal "$(mock_get_call_args "$_HAMSTER" 2)" "start test@Unsorted , -22"
   assert_equal "$(mock_get_call_num "$_FRECE")" "1"
   assert_equal "$(mock_get_call_args "$_FRECE" 1)" "increment $CACHE test@Unsorted"
}

