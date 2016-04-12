--
-- CS571 Spring 2016 
--  Final Project
--
-- Scene template from Corona SDK documentation
--
local composer = require( "composer" )
local physics = require( "physics" ) 
physics.start()
physics.setGravity( 0, display.contentHeight / 25.0 )

local widget = require("widget")
local scene = composer.newScene()
local game = display.newGroup();
local bottom = nil;
local top = nil;

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Globals
local playerBall = nil;

local gameStarted = false;

local function colorObject( object )
	-- Colors here are from http://www.avatar.se/molscript/doc/colour_names.html
	local i = math.random(1, 4);
	if ( i ==  1) then
		-- set to cyan
		object:setFillColor(0,1,1);
		object.colorTag = "cyan";
	elseif ( i == 2 ) then
		-- set to purple
		object:setFillColor(0.627451, 0.12549, 0.941176)
		object.colorTag = "purple";
	elseif ( i == 3 ) then
		-- set to orange
		object:setFillColor(1, 0.647059, 0)
		object.colorTag = "orange";
	else -- ( i == 4 ) 
		-- set to chartreuse
		object:setFillColor(0.498039, 1, 0)
		object.colorTag = "chartreuse";
	end
end

local function reset()
	physics.removeBody(playerBall);
	playerBall.y = display.contentHeight-150;
	game.y = 0;
	bottom.y = display.contentHeight-20;
	top.y = 0;
	gameStarted = false;
end

local function gameOver()
	timer.performWithDelay(
		100,
		function()
			reset();
		end,
		1
	);
	
end

local function ballCollision ( event )
	if (event.phase=="began" and event.other.name ~= nil) then
		if(event.other.name == "bottom") then
			gameOver();
		elseif(string.find(event.other.name, "testObs_") ~= nil) then
			print("collided with " .. event.other.name);

			if(playerBall.colorTag == event.other.colorTag) then
				print("you may pass");
			else
				print("none shall pass");
				--gameOver();
			end
		end
	end
end

local function screenTap ( event )
	if ( gameStarted == false ) then -- leaving ball stationary until first tap
		physics.addBody (playerBall, "dynamic", { density=-.5, friction=0.0, bounce=0.2, radius=30 });
		gameStarted = true;
	end
	
	local delta = top.y - playerBall.y;
	--print(delta, delta/100)
	-- playerBall:applyForce(0,-25, playerBall.x, playerBall.y);
	playerBall:applyForce(0, delta/35, playerBall.x, playerBall.y);
end

local function moveView()
	if(playerBall ~= nil) then
		--print("top", top.y)
		-- print(game.topBounds);
		local delta = playerBall.y - top.y;
		if(delta < 500 and playerBall.y > -5000) then
			top.y = top.y - 10;
			game.y = game.y + 10;
			bottom.y = bottom.y - 10;
		end
	end
end

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

local function addSomeTestObstacles()
	local testObs = {"box", "circle", "rect"};
	local numTestObs = 10;
	local testObsY = 300;

	for obsNum = 1, numTestObs do
		local randInd = math.random(1, #testObs);
		local testObsType = testObs[randInd];

		local testObs = nil;

		if(testObsType == "box") then
			testObs = display.newRect(display.contentWidth/2, testObsY, 200, 200);
		elseif(testObsType == "circle") then
			testObs = display.newCircle(display.contentCenterX, testObsY, display.contentWidth / 15.0);
		elseif(testObsType == "rect") then
			testObs = display.newRect(display.contentWidth/2, testObsY, 300, 200);
		end

		timer.performWithDelay(
			10,
			function()
				testObs.rotation = testObs.rotation + 1;
			end,
			0
		);

		testObs.name = "testObs_" .. obsNum;
		colorObject(testObs);
		physics.addBody(testObs, "static");
		testObs.isSensor = true;
		game:insert(testObs);

		testObsY = testObsY - 300;
	end
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
		
		local BoxLineWidth = 2;
		-- local left = display.newRect(0,0,20, display.contentHeight);
		-- local right = display.newRect(display.contentWidth-20,0,20,display.contentHeight);
		top = display.newRect(0,0,display.contentWidth, 20);
		bottom = display.newRect(0,display.contentHeight-20,display.contentWidth, 20);
		bottom.name = "bottom";
		-- top.name = "top";
		-- left:setFillColor(0,1,0);
		-- right:setFillColor(0,1,0);
		top:setFillColor(0,0,0);
		bottom:setFillColor(0,1,0);
							   
		-- left.anchorX = 0;left.anchorY = 0;
		-- right.anchorX = 0;right.anchorY = 0;
		bottom.anchorX = 0;bottom.anchorY = 0;
		top.anchorX = 0;top.anchorY = 0;
		physics.addBody( bottom, "static" );
		-- physics.addBody( top, "static" );

		game:insert(bottom);
		game:insert(top);
		-- game:insert(left);
		-- game:insert(right);
		-- game:insert(testbox);

		playerBall = display.newCircle(display.contentCenterX, 
			display.contentHeight-150, display.contentWidth / 35.0);
		
		playerBall:addEventListener("collision", ballCollision);
		colorObject(playerBall);
		game:insert(playerBall);

		addSomeTestObstacles();
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
Runtime:addEventListener( "tap", screenTap );
Runtime:addEventListener( "enterFrame", moveView );

-- -------------------------------------------------------------------------------

return scene
