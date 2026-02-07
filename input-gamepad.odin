package main

//initial code and assets provide by https://github.com/raysan5/raylib/blob/master/examples/core/core_input_gamepad.c

import "core:c"
import "core:fmt"
import "vendor:raylib"

XBOX_ALIAS_1: cstring = "xbox"
XBOX_ALIAS_2: cstring = "x-box"
PS_ALIAS: cstring = "playstation"

leftStickDeadzoneX: f32 = 0.1
leftStickDeadzoneY: f32 = 0.1
rightStickDeadzoneX: f32 = 0.1
rightStickDeadzoneY: f32 = 0.1
leftTriggerDeadzone: f32 = -0.9
rightTriggerDeadzone: f32 = -0.9

gamepad: c.int = 0

leftStickX: f32 = 0
leftStickY: f32 = 0
rightStickX: f32 = 0
rightStickY: f32 = 0
leftTrigger: f32 = 0
rightTrigger: f32 = 0

GamePadType :: enum {
	Ps3,
	Xbox,
	Generic,
	None,
}

getGamePadType :: proc() -> GamePadType {
	if raylib.TextFindIndex(raylib.TextToLower(raylib.GetGamepadName(gamepad)), XBOX_ALIAS_1) >
		   -1 ||
	   raylib.TextFindIndex(raylib.TextToLower(raylib.GetGamepadName(gamepad)), XBOX_ALIAS_2) >
		   -1 {
		return .Xbox
	}
	if raylib.TextFindIndex(raylib.TextToLower(raylib.GetGamepadName(gamepad)), PS_ALIAS) > -1 {
		return .Ps3
	}

	return .Generic
}

isSettingsWindowOpen := false
userSelectedPad: GamePadType = .None

main :: proc() {
	screenWidth: c.int = 800
	screenHeight: c.int = 600
	raylib.SetConfigFlags({.MSAA_4X_HINT})
	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - input gamepad")
	raylib.SetTargetFPS(60)

	defaultPs3Pad: raylib.Texture2D = raylib.LoadTexture("./resources/ps3/default.png")
	defaultXboxPad: raylib.Texture2D = raylib.LoadTexture("./resources/xbox/default.png")

	vibrateButton: raylib.Rectangle

	gamepadIndexSelected: c.int = 0
	isGamepadSelectorEditMode := false

	for !raylib.WindowShouldClose() {
		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.GREEN)

		if !raylib.IsGamepadAvailable(gamepad) {
			raylib.DrawText(
				raylib.TextFormat("GP%d: NOT DETECTED", gamepad),
				10,
				10,
				10,
				raylib.GRAY,
			)
			raylib.DrawTexture(defaultXboxPad, 0, 0, raylib.LIGHTGRAY)

			raylib.EndDrawing()
			continue
		}

		settingsButtonMessage: cstring = ""
		if isSettingsWindowOpen {
			settingsButtonMessage = "close settings"
		} else {
			settingsButtonMessage = "open settings"
		}

		if raylib.GuiButton({5, 5, 95, 25}, settingsButtonMessage) {
			isSettingsWindowOpen = !isSettingsWindowOpen
		}

		if isSettingsWindowOpen {
			selected := raylib.GuiDropdownBox(
				{110, 5, 200, 25},
				"Ps3;Xbox;Generic",
				&gamepadIndexSelected,
				isGamepadSelectorEditMode,
			)
			if selected {
				isGamepadSelectorEditMode = !isGamepadSelectorEditMode
				userSelectedPad = GamePadType(gamepadIndexSelected)
			}
		}

		leftStickX = raylib.GetGamepadAxisMovement(gamepad, .LEFT_X)
		leftStickY = raylib.GetGamepadAxisMovement(gamepad, .LEFT_Y)
		rightStickX = raylib.GetGamepadAxisMovement(gamepad, .RIGHT_X)
		rightStickY = raylib.GetGamepadAxisMovement(gamepad, .RIGHT_Y)
		leftTrigger = raylib.GetGamepadAxisMovement(gamepad, .LEFT_TRIGGER)
		rightTrigger = raylib.GetGamepadAxisMovement(gamepad, .RIGHT_TRIGGER)

		// Calculate deadzones
		if leftStickX > -leftStickDeadzoneX && leftStickX < leftStickDeadzoneX {
			leftStickX = 0
		}
		if leftStickY > -leftStickDeadzoneY && leftStickY < leftStickDeadzoneY {
			leftStickY = 0
		}
		if rightStickX > -rightStickDeadzoneX && rightStickX < rightStickDeadzoneX {
			rightStickX = 0
		}
		if rightStickY > -rightStickDeadzoneY && rightStickY < rightStickDeadzoneY {
			rightStickY = 0
		}
		if leftTrigger < leftTriggerDeadzone {
			leftTrigger = -1
		}
		if rightTrigger < rightTriggerDeadzone {
			rightTrigger = -1
		}

		padType: GamePadType

		if userSelectedPad != .None {
			padType = userSelectedPad
		} else {
			padType = getGamePadType()
		}

		switch padType {
		case .Xbox:
			drawXboxPad(defaultXboxPad)
		case .Ps3:
			drawPs3Pad(defaultPs3Pad)
		case .Generic:
			drawGenericPad()
		case .None:
			drawGenericPad()
		}

		raylib.EndDrawing()
	}

	raylib.UnloadTexture(defaultPs3Pad)
	raylib.UnloadTexture(defaultXboxPad)

	raylib.CloseWindow()
}

drawGenericPad :: proc() {

	raylib.DrawRectangleRounded({175, 210, 460, 220}, 0.3, 16, raylib.DARKGRAY)

	// raylib.Draw buttons: basic
	raylib.DrawCircle(365, 270, 12, raylib.RAYWHITE)
	raylib.DrawCircle(405, 270, 12, raylib.RAYWHITE)
	raylib.DrawCircle(445, 270, 12, raylib.RAYWHITE)
	raylib.DrawCircle(516, 291, 17, raylib.RAYWHITE)
	raylib.DrawCircle(551, 327, 17, raylib.RAYWHITE)
	raylib.DrawCircle(587, 291, 17, raylib.RAYWHITE)
	raylib.DrawCircle(551, 255, 17, raylib.RAYWHITE)
	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE_LEFT) {
		raylib.DrawCircle(365, 270, 10, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE) {
		raylib.DrawCircle(405, 270, 10, raylib.GREEN)
	}
	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE_RIGHT) {
		raylib.DrawCircle(445, 270, 10, raylib.BLUE)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_LEFT) {
		raylib.DrawCircle(516, 291, 15, raylib.GOLD)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_DOWN) {
		raylib.DrawCircle(551, 327, 15, raylib.BLUE)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_RIGHT) {
		raylib.DrawCircle(587, 291, 15, raylib.GREEN)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_UP) {
		raylib.DrawCircle(551, 255, 15, raylib.RED)
	}

	// raylib.Draw buttons: d-pad
	raylib.DrawRectangle(245, 245, 28, 88, raylib.RAYWHITE)
	raylib.DrawRectangle(215, 274, 88, 29, raylib.RAYWHITE)
	raylib.DrawRectangle(247, 247, 24, 84, raylib.BLACK)
	raylib.DrawRectangle(217, 276, 84, 25, raylib.BLACK)
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_UP) {
		raylib.DrawRectangle(247, 247, 24, 29, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_DOWN) {
		raylib.DrawRectangle(247, 301, 24, 30, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_LEFT) {
		raylib.DrawRectangle(217, 276, 30, 25, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_RIGHT) {
		raylib.DrawRectangle(271, 276, 30, 25, raylib.RED)
	}

	// raylib.Draw buttons: left-right back
	raylib.DrawRectangleRounded({215, 198, 100, 10}, 0.5, 16, raylib.DARKGRAY)
	raylib.DrawRectangleRounded({495, 198, 100, 10}, 0.5, 16, raylib.DARKGRAY)
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_TRIGGER_1) {
		raylib.DrawRectangleRounded({215, 198, 100, 10}, 0.5, 16, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_TRIGGER_1) {
		raylib.DrawRectangleRounded({495, 198, 100, 10}, 0.5, 16, raylib.RED)
	}

	// raylib.Draw axis: left joystick
	leftGamepadColor := raylib.BLACK
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_THUMB) {
		leftGamepadColor = raylib.RED
	}
	raylib.DrawCircle(345, 360, 40, raylib.BLACK)
	raylib.DrawCircle(345, 360, 35, raylib.LIGHTGRAY)
	raylib.DrawCircle(
		345 + c.int(leftStickX * 20),
		360 + c.int(leftStickY * 20),
		25,
		leftGamepadColor,
	)

	// raylib.Draw axis: right joystick
	rightGamepadColor := raylib.BLACK
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_THUMB) {
		rightGamepadColor = raylib.RED}
	raylib.DrawCircle(465, 360, 40, raylib.BLACK)
	raylib.DrawCircle(465, 360, 35, raylib.LIGHTGRAY)
	raylib.DrawCircle(
		465 + c.int(rightStickX * 20),
		360 + c.int(rightStickY * 20),
		25,
		rightGamepadColor,
	)

	// raylib.Draw axis: left-right triggers
	raylib.DrawRectangle(151, 210, 15, 70, raylib.GRAY)
	raylib.DrawRectangle(644, 210, 15, 70, raylib.GRAY)
	raylib.DrawRectangle(151, 210, 15, c.int(((1 + leftTrigger) / 2) * 70), raylib.RED)
	raylib.DrawRectangle(644, 210, 15, c.int(((1 + rightTrigger) / 2) * 70), raylib.RED)
}

drawXboxPad :: proc(texXboxPad: raylib.Texture2D) {
	raylib.DrawTexture(texXboxPad, 0, 100, raylib.DARKGRAY)

	// Draw buttons: xbox home
	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE) {
		raylib.DrawCircle(394, 189, 19, raylib.RED)
	}

	// Draw buttons: basic
	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE_RIGHT) {
		raylib.DrawCircle(436, 250, 9, raylib.RED)
	}

	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE_LEFT) {
		raylib.DrawCircle(352, 250, 9, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_LEFT) {
		raylib.DrawCircle(501, 251, 15, raylib.BLUE)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_DOWN) {
		raylib.DrawCircle(536, 287, 15, raylib.YELLOW)
	}
	if (raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_RIGHT)) {
		raylib.DrawCircle(572, 251, 15, raylib.MAROON)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_UP) {
		raylib.DrawCircle(536, 215, 15, raylib.GOLD)
	}

	// Draw buttons: d-pad
	raylib.DrawRectangle(317, 302, 19, 71, raylib.BLACK)
	raylib.DrawRectangle(293, 328, 69, 19, raylib.BLACK)
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_UP) {
		raylib.DrawRectangle(317, 302, 19, 26, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_DOWN) {
		raylib.DrawRectangle(317, 347, 19, 26, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_LEFT) {
		raylib.DrawRectangle(292, 328, 25, 19, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_RIGHT) {
		raylib.DrawRectangle(336, 328, 26, 19, raylib.RED)
	}

	// Draw buttons: left-right back
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_TRIGGER_1) {
		raylib.DrawCircle(259, 161, 20, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_TRIGGER_1) {
		raylib.DrawCircle(536, 161, 20, raylib.RED)
	}

	// Draw axis: left joystick
	leftGamepadColor := raylib.BLACK
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_THUMB) {
		leftGamepadColor = raylib.RED
	}
	raylib.DrawCircle(259, 252, 39, raylib.BLACK)
	raylib.DrawCircle(259, 252, 34, raylib.LIGHTGRAY)
	raylib.DrawCircle(
		259 + c.int(leftStickX * 20),
		252 + c.int(leftStickY * 20),
		25,
		leftGamepadColor,
	)

	// Draw axis: right joystick
	rightGamepadColor := raylib.BLACK
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_THUMB) {
		rightGamepadColor = raylib.RED
	}
	raylib.DrawCircle(461, 337, 38, raylib.BLACK)
	raylib.DrawCircle(461, 337, 33, raylib.LIGHTGRAY)
	raylib.DrawCircle(
		461 + c.int(rightStickX * 20),
		337 + c.int(rightStickY * 20),
		25,
		rightGamepadColor,
	)

	// Draw axis: left-right triggers
	raylib.DrawRectangle(170, 130, 15, 70, raylib.GRAY)
	raylib.DrawRectangle(604, 130, 15, 70, raylib.GRAY)
	raylib.DrawRectangle(170, 130, 15, c.int(((1 + leftTrigger) / 2) * 70), raylib.RED)
	raylib.DrawRectangle(604, 130, 15, c.int(((1 + rightTrigger) / 2) * 70), raylib.RED)
}

drawPs3Pad :: proc(texPs3Pad: raylib.Texture2D) {
	raylib.DrawTexture(texPs3Pad, 0, 100, raylib.DARKGRAY)

	// Draw buttons: ps
	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE) {
		raylib.DrawCircle(396, 322, 13, raylib.RED)
	}

	// Draw buttons: basic
	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE_LEFT) {
		raylib.DrawRectangle(328, 270, 32, 13, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .MIDDLE_RIGHT) {
		raylib.DrawTriangle({436, 268}, {436, 285}, {464, 277}, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_UP) {
		raylib.DrawCircle(557, 244, 13, raylib.YELLOW)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_RIGHT) {
		raylib.DrawCircle(586, 273, 13, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_DOWN) {
		raylib.DrawCircle(557, 303, 13, raylib.BLUE)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_FACE_LEFT) {
		raylib.DrawCircle(527, 273, 13, raylib.PINK)
	}

	// raylib.Draw buttons: d-pad
	raylib.DrawRectangle(225, 232, 24, 84, raylib.BLACK)
	raylib.DrawRectangle(195, 261, 84, 25, raylib.BLACK)
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_UP) {
		raylib.DrawRectangle(225, 232, 24, 29, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_DOWN) {
		raylib.DrawRectangle(225, 286, 24, 30, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_LEFT) {
		raylib.DrawRectangle(195, 261, 30, 25, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_FACE_RIGHT) {
		raylib.DrawRectangle(249, 261, 30, 25, raylib.RED)
	}

	// raylib.Draw buttons: left-right back buttons
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_TRIGGER_1) {
		raylib.DrawCircle(239, 182, 20, raylib.RED)
	}
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_TRIGGER_1) {
		raylib.DrawCircle(557, 182, 20, raylib.RED)
	}

	// raylib.Draw axis: left joystick
	leftGamepadColor := raylib.BLACK
	if raylib.IsGamepadButtonDown(gamepad, .LEFT_THUMB) {
		leftGamepadColor = raylib.RED
	}
	raylib.DrawCircle(319, 355, 35, raylib.BLACK)
	raylib.DrawCircle(319, 355, 31, raylib.LIGHTGRAY)
	raylib.DrawCircle(
		319 + c.int(leftStickX * 20),
		355 + c.int(leftStickY * 20),
		25,
		leftGamepadColor,
	)

	// raylib.Draw axis: right joystick
	rightGamepadColor := raylib.BLACK
	if raylib.IsGamepadButtonDown(gamepad, .RIGHT_THUMB) {
		rightGamepadColor = raylib.RED
	}
	raylib.DrawCircle(475, 355, 35, raylib.BLACK)
	raylib.DrawCircle(475, 355, 31, raylib.LIGHTGRAY)
	raylib.DrawCircle(
		475 + c.int(rightStickX * 20),
		355 + c.int(rightStickY * 20),
		25,
		rightGamepadColor,
	)

	// raylib.Draw axis: left-right triggers
	raylib.DrawRectangle(169, 148, 15, 70, raylib.GRAY)
	raylib.DrawRectangle(611, 148, 15, 70, raylib.GRAY)
	raylib.DrawRectangle(169, 148, 15, c.int(((1 + leftTrigger) / 2) * 70), raylib.RED)
	raylib.DrawRectangle(611, 148, 15, c.int(((1 + rightTrigger) / 2) * 70), raylib.RED)
}
