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

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Globals
local playerBall = display.newCircle(display.contentCenterX, 
	display.contentHeight*4-150, display.contentWidth / 35.0);

local scrollAmt = -10;
local scrollView = nil;

local gameStarted = false;


local function scrollListener(event)
	local phase = event.phase;
	local direction = event.direction;

	print(scrollView:getContentPosition())

	if(event.limitReached) then
		if(direction == "up") then
			print("up limit reached");
		elseif (direction == "down") then
			print("down limit reached");
		end
	end
end

local function colorObject( object )
	-- Colors here are from http://www.avatar.se/molscript/doc/colour_names.html
	local i = math.random(1, 4);
	if ( i ==  1) then
		-- set to cyan
		object:setFillColor(0,1,1);
		object.tag = "cyan";
	elseif ( i == 2 ) then
		-- set to purple
		object:setFillColor(0.627451, 0.12549, 0.941176)
		object.tag = "purple";
	elseif ( i == 3 ) then
		-- set to orange
		object:setFillColor(1, 0.647059, 0)
		object.tag = "orange";
	else -- ( i == 4 ) 
		-- set to chartreuse
		object:setFillColor(0.498039, 1, 0)
		object.tag = "chartreuse";
	end
end

local function ballCollision ( event )
	if (event.phase=="began" and event.other.name ~= nil) then
		if(event.other.name == "top") then
			local newX,newY = scrollView:getContentPosition();

			scrollView:scrollToPosition{
			    --y = scrollAmt,
			    y = newY + 100,
			    time = 800
			}

			-- timer.performWithDelay(1,
			-- 	function()
			-- 		top.y = top.y + scrollAmt;
			-- 		bottom.y = bottom.y + scrollAmt;
			-- 		--testbox.y = testbox.y - 10;
			-- 	end,
			-- 1)

			scrollAmt = scrollAmt - 10;

			--print(scrollView.scrollHeight)
		end
	end
end

local function screenTap ( event )

	if ( gameStarted == false ) then -- leaving ball stationary until first tap
		physics.addBody (playerBall, "dynamic");
		gameStarted = true;
	end
	
	playerBall:applyForce(0,-15, playerBall.x, playerBall.y)
end

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
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
		local left = display.newRect(0,0,20, display.contentHeight);
		local right = display.newRect(display.contentWidth-20,0,20,display.contentHeight);
		local bottom = display.newRect(0,display.contentHeight*4,display.contentWidth, 20);
		local top = display.newRect(0,display.contentHeight*4-800,display.contentWidth, 20);
		top.name = "top";
		left:setFillColor(0,0,0);
		right:setFillColor(0,0,0);
		bottom:setFillColor(0,1,0);
		top:setFillColor(1,0,0);	
							   
		left.anchorX = 0;left.anchorY = 0;
		right.anchorX = 0;right.anchorY = 0;
		bottom.anchorX = 0;bottom.anchorY = 0;
		top.anchorX = 0;top.anchorY = 0;
		physics.addBody( bottom, "static" );
		physics.addBody( top, "static" );

		-- add a box for testing scrolling up
		local testbox = display.newRect(210, -50,200, 200);

		scrollView = widget.newScrollView{
			left = 0,
			top = 0,
			width = display.contentWidth,
			height = display.contentHeight,
			scrollHeight = display.contentHeight * 2,
			topPadding = 0,
			bottomPadding = 0,
			horizontalScrollDisabled = true,
			verticalScrollDisabled = false,
			listener = scrollListener,
			backgroundColor = {0, 0, 0},
		}

		scrollView:insert(bottom);
		scrollView:insert(top);
		scrollView:insert(testbox);
		
		playerBall:addEventListener("collision", ballCollision);
		colorObject(playerBall);
		scrollView:insert(playerBall);
		
		Runtime:addEventListener("tap", screenTap);

		scrollView:scrollTo( "bottom", { time=100} )
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

-- -------------------------------------------------------------------------------

return scene
