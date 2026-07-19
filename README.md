# Hillside ZMK firmware

![hillside](https://imgur.com/emWDXiT.png)
[![Build](https://github.com/dee-tree/zmk-config-hillside/actions/workflows/build.yml/badge.svg)](https://github.com/dee-tree/zmk-config-hillside/actions/workflows/build.yml)

## Description

This is the [ZMK](https://zmk.dev/docs) firmware
for the [Hillside](https://github.com/mmccoyd/hillside) family of split ergonomic keyboards.

It contains keymap definition files for three boards in [./config](./config):

- Hillside 52 with 3x6+3+5 keys
- Hillside 48 with 3x6+1+5 keys
- Hillside 46 with 3x6+5 keys

Pushing changes will build all the keyboards. You need to be signed in to a GitHub account to push changes and build the firmware. To not waste build time, comment out the keyboards in [./build.yaml](./build.yaml) that you do not have.

## Build

### CI build

To build the firmware:

- Fork this repo on GitHub
- Clone your fork locally
- Trigger a build:
  - Make a trivial change to ./build.yaml (or any non \*.md file)
  - Push that change
- Look in the [Actions](https://github.com/dee-tree/zmk-config/actions) tab
  for the build triggered by that change.
- Wait for the build to finish
- Click on the build link next to the green checkbox
- Download the artifact file with the firmware
- See [Installing The Firmware](https://zmk.dev/docs/user-setup#installing-the-firmware)
  for more details from there.

### Local build

To build the firmware locally, there is a nix flake populating required dependencies integrated with direnv.

Initially, allow direnv to activate flake, executing: `direnv allow`.

Next, update project modules with:
`west update`

Build left (central half):
`west build -s zmk/app -b nice_nano//zmk -d ${ZMK_BUILD_DIR}/left -- -DZMK_CONFIG=${ZMK_CONFIG_DIR} -DSHIELD="hillsideview_left nice_view_gem"`

Build right (peripheral half):
`west build -s zmk/app -b nice_nano//zmk -d ${ZMK_BUILD_DIR}/right -- -DZMK_CONFIG=${ZMK_CONFIG_DIR} -DSHIELD="hillsideview_right"`

If you don't need `nice!view` for left half, then remove `nice_view_gem` from `-DSHIELD` option.

**NOTE:** If you need to build the firmware with local modules, use `-DZMK_EXTRA_MODULES=` option for build (as CMake argument, after `--` in west command).

## Customization

If you want to enable features,
modify the appropriate ./config/hillside\*.conf file.

To add RGB support, uncomment the lines in the ./config/hillside\*.conf file
and add the `&rgb_ug RGB_TOG` and other keycodes to the keymap adjust layer.
While RGB is disabled, any RGB control keys
behave as transparent keys and activate keys on lower layers,
which can be confusing.

The Hillside shield definition files should _not_ need to be modified and are in ./config/boards/shields.

More information about each keymap is in their readme files.
