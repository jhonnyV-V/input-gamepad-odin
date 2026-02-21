# What is this

this is a simple controller overlay made in odin and raylib, this project was made from this [raylib example](https://github.com/raysan5/raylib/blob/master/examples/core/core_input_gamepad.c) including the current default assets

# How to use

currently linux is the only tested platform but it should work on Windows

- run the executable (with obs-gamecapture for obs capture)
- connect controller (this can be done before opening the program it does not matter)
- profit

currently it is posible to use custom textures for the controllers BUT at the time of writing
it has to take as a base the positions of one of the existing default textures and be placed in the folder of said base
this is to avoid having buttons appearing in the wrong places

## Configuration

with the window focused you can press h to toggle the configurations
here you can force the controller you want (displaying an xbox controller instead of a ps3)
if any custom textures are available for the current controller you can select it in the dropdown
if the texture does not appear in the dropdown make sure the texture is in the correct directory inside of assets directory 

# Planned
- [ ] support for controller styling and trully custom textures
- [ ] remembering latest texture selected
- [ ] support for changing the position of the texture (this could not get implemented)

# Special Thanks

This tool would not have been made by me without raylib and odin, both are great tools that made this really easy to make

A big part of the code comes from this raylib example https://github.com/raysan5/raylib/blob/master/examples/core/core_input_gamepad.c
it really helped to understand how to use raylib and a lot of the heavy lifting of this small project
