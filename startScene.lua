--[[

CS 571 Final Project
Stephen Cothren & Trey Dickerhoff
Color Matcher

startScene.lua

Start scene for Color Matcher.  Allows player to choose
their difficulty level and start the game

--]]

-- load composer module
local composer = require( "composer" )
-- create a new scene
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here
local nameText = nil;
local classText = nil;
local authorText = nil;
local selectLevelText = nil;
local easyButton = nil; 
local easyButtonText = nil;
local normalButton = nil;
local normalButtonText = nil;
local hardButton = nil;
local hardButtonText = nil;

-- function: startEasyMode()
-- input: na
-- output: na
-- description: start the game in easy mode
local function startEasyMode()
	composer.removeScene("startScene", false);
	local options = {effect="fade", time=1000, params={mode="Easy"}}
	composer.gotoScene( "SceneFactory", options);
end

-- function: startNormalMode()
-- input: na
-- output: na
-- description: start the game in normal mode
local function startNormalMode()
	composer.removeScene("startScene", false);
	local options = {effect="fade", time=1000, params={mode="Normal"}}
	composer.gotoScene( "SceneFactory", options);
end

-- function: startHardMode()
-- input: na
-- output: na
-- description: start the game in hard mode
local function startHardMode()
	composer.removeScene("startScene", false);
	local options = {effect="fade", time=1000, params={mode="Hard"}}
	composer.gotoScene( "SceneFactory", options);
end

---------------------------------------------------------------------------------

-- function: create(event)
-- input: event
-- output: scene
-- description: called when the scene is being created
function scene:create( event )
   local sceneGroup = self.view

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

-- function: show(event)
-- input: event
-- output: scene
-- description: called when the scene is ready to be displayed
function scene:show( event )
   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
	local nameTextOpt = 
	{
		text = "Color Matcher",     
		x = display.contentWidth / 2.0 ,
		y = 50,
		width = display.contentWidth,    
		height = 70;
		font = native.systemFontBold,   
		fontSize = 56,
		align = "center" 
	}
	nameText = display.newText(nameTextOpt);
	nameText:setFillColor(0,1,1);

	local classTextOpt = 
	{
		text = "CS 571 Final Project",     
		x = display.contentWidth / 2.0 ,
		y = 150,
		width = display.contentWidth,    
		height = 60;
		font = native.systemFontBold,   
		fontSize = 48,
		align = "center" 
	}
	classText = display.newText(classTextOpt);
	classText:setFillColor(0.627451, 0.12549, 0.941176);

	local authorTextOpt = 
	{
		text = "By Brian Cothren and Trey Dickerhoff",     
		x = display.contentWidth / 2.0 ,
		y = 215,
		width = display.contentWidth,    
		height = 50;
		font = native.systemFontBold,   
		fontSize = 24,
		align = "center" 
	}
	authorText = display.newText(authorTextOpt);
	authorText:setFillColor(1, 0.647059, 0);

	local selectLevelTextOpt = 
	{
		text = "   Select Difficulty!",     
		x = display.contentWidth / 2.0 ,
		y = display.contentHeight / 2.0,
		width = display.contentWidth,    
		height = 70;
		font = native.systemFontBold,   
		fontSize = 56,
		align = "left" 
	}
	selectLevelText = display.newText(selectLevelTextOpt);
	selectLevelText:setFillColor(0.498039, 1, 0);

	easyButton = display.newRect(display.contentWidth / 2.0 + 100 , 
	  								   800, 
									   display.contentWidth / 2.0, 
									   display.contentWidth / 5.0);
    easyButton:setFillColor(0,1,1);
	easyButton:addEventListener("tap", startEasyMode);
	local easyButtonTextOpt = 
	{
		text = "...easy...",     
		x = easyButton.x ,
		y = easyButton.y,
		width = display.contentWidth,    
		height = 60;
		font = native.systemFontBold,   
		fontSize = 48,
		align = "center" 
	}
	easyButtonText = display.newText(easyButtonTextOpt);
	easyButtonText:setFillColor(0,0,0);

	normalButton = display.newRect(display.contentWidth / 2.0 + 100 , 
										 970, 
										 display.contentWidth / 2.0, 
										 display.contentWidth / 5.0);
    normalButton:setFillColor(0.627451, 0.12549, 0.941176);
	normalButton:addEventListener("tap", startNormalMode);
	local normalButtonTextOpt = 
	{
		text = "Normal",     
		x = normalButton.x ,
		y = normalButton.y,
		width = display.contentWidth,    
		height = 60;
		font = native.systemFontBold,   
		fontSize = 48,
		align = "center" 
	}
	normalButtonText = display.newText(normalButtonTextOpt);
	normalButtonText:setFillColor(0,0,0);

	hardButton = display.newRect(display.contentWidth / 2.0 + 100 , 
										 1140, 
										 display.contentWidth / 2.0, 
										 display.contentWidth / 5.0);
    hardButton:setFillColor(1, 0.647059, 0);
	hardButton:addEventListener("tap", startHardMode);
	local hardButtonTextOpt = 
	{
		text = "HARD!!!",     
		x = hardButton.x ,
		y = hardButton.y,
		width = display.contentWidth,    
		height = 60;
		font = native.systemFontBold,   
		fontSize = 48,
		align = "center" 
	}
	hardButtonText = display.newText(hardButtonTextOpt);
	hardButtonText:setFillColor(0,0,0);

   end
end

-- function: hide(event)
-- input: event
-- output: scene
-- description: called when the scene is being hidden
function scene:hide( event )
   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- function: destroy(event)
-- input: event
-- output: scene
-- description: called when the scene is being destroyed
function scene:destroy( event )
   local sceneGroup = self.view
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
   	nameText:removeSelf();
	classText:removeSelf();
	authorText:removeSelf();
	selectLevelText:removeSelf();

	easyButton:removeSelf(); 
	easyButtonText:removeSelf();
	normalButton:removeSelf();
	normalButtonText:removeSelf();
	hardButton:removeSelf();
	hardButtonText:removeSelf();
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene