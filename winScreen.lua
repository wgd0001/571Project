local composer = require( "composer" )
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here
local youWinText = nil;

local playAgainButton = nil; 
local playAgainText = nil;

local function playAgain()
	composer.removeScene("winScreen", false);
	local options = {effect="fade", time=1000}
	composer.gotoScene( "startScene", options);
end

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )

   local sceneGroup = self.view

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
	local youWinTextOpt = 
	{
		text = "YOU WIN!!",     
		x = display.contentWidth / 2.0 ,
		y = display.contentHeight / 2.0 - 100,
		width = display.contentWidth,    
		height = 70;
		font = native.systemFontBold,   
		fontSize = 56,
		align = "center" 
	}
	youWinText = display.newText(youWinTextOpt);
	youWinText:setFillColor(0,1,1);

	playAgainButton = display.newRect(display.contentWidth / 2.0, 
	  								   display.contentHeight / 2.0 + 100, 
									   display.contentWidth / 2.0, 
									   display.contentWidth / 5.0);
    playAgainButton:setFillColor(0,1,1);
	playAgainButton:addEventListener("tap", playAgain);
	local playAgainButtonTextOpt = 
	{
		text = "Play Again!",     
		x = playAgainButton.x ,
		y = playAgainButton.y,
		width = display.contentWidth,    
		height = 60;
		font = native.systemFontBold,   
		fontSize = 48,
		align = "center" 
	}
	playAgainButtonText = display.newText(playAgainButtonTextOpt);
	playAgainButtonText:setFillColor(0,0,0);

   end
end

-- "scene:hide()"
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

-- "scene:destroy()"
function scene:destroy( event )
   local sceneGroup = self.view
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
   	youWinText:removeSelf();
	playAgainButton:removeSelf(); 
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene