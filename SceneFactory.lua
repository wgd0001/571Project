--
-- CS571 Spring 2016 
--  Final Project
--
-- Scene template from Corona SDK documentation
--

local composer = require( "composer" )
local physics = require( "physics" ) 
-- physics.setDrawMode( 'hybrid' )
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
local deadMeat = false;
local DelaySwap = false;
local obsNum = 0;

local score = 0;
local scoreTextInit = false;
local scoreText;

-- Colors here are from http://www.avatar.se/molscript/doc/colour_names.html
local function colorObjectCyan( object ) 
	object:setFillColor(0,1,1);
	object.colorTag = "cyan";
	object.r = 0;
	object.g = 1;
	object.b = 1;
end

local function colorObjectPurple( object ) 
	object:setFillColor(0.627451, 0.12549, 0.941176)
	object.colorTag = "purple";
	object.r = 0.627451;
	object.g = 0.12549;
	object.b = 0.941176;
end

local function colorObjectOrange( object )
	object:setFillColor(1, 0.647059, 0)
	object.colorTag = "orange";
	object.r = 1;
	object.g = 0.647059;
	object.b = 0;
end

local function colorObjectGreen( object )
	object:setFillColor(0.498039, 1, 0)
	object.colorTag = "green";
	object.r = 0.498039;
	object.g = 1;
	object.b = 0;
end

local function colorObject( object )
	local i = math.random(1, 4);
	if ( i ==  1) then
		-- set to cyan
		colorObjectCyan(object);
	elseif ( i == 2 ) then
		-- set to purple
		colorObjectPurple(object);
	elseif ( i == 3 ) then
		-- set to orange
		colorObjectOrange(object);
	else -- ( i == 4 ) 
		-- set to green
		colorObjectGreen(object);
	end
end

local function threeColorObject( object )
	local i = math.random(1, 3);
	if ( i == 1 ) then 
		-- set to cyan
		colorObjectCyan(object);
	elseif ( i == 2 ) then
		-- set to purple
		colorObjectPurple(object);
	else -- ( i == 3 ) then 
		-- set to orange
		colorObjectOrange(object);
	end
end

local function twoColorObject( object ) 
	local i = math.random(1, 2);
	if ( i == 1 ) then 
		-- set to cyan
		colorObjectCyan(object);
	else -- ( i == 2 ) then
		-- set to purple
		colorObjectPurple(object);
	end
end

local function reset()
	physics.removeBody(playerBall);
	playerBall.x = display.contentWidth/2.0;
	playerBall.y = display.contentHeight-150;
	game.y = 0;
	bottom.y = display.contentHeight-20;
	top.y = 0;
	gameStarted = false;
	colorObject(playerBall);
	deadMeat = false;
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

local function updateScore()
	if ( scoreTextInit == true ) then 
		scoreText:removeSelf();
	end
	
	local scoreTextOpt = 
	{
		text = "  Score : " .. score .. "   ",     
		x = display.contentWidth / 2.0 ,
		y = 0 + 50,
		width = display.contentWidth,    
		height = 50;
		font = native.systemFontBold,   
		fontSize = 48,
		align = "left" 
	}
	scoreText = display.newText(scoreTextOpt);
	scoreText:setFillColor(1,1,1);
	scoreTextInit = true;
end

local function explode ( event )
	for i = 1, 10 do
		local radius = math.random(1, 10);
		local circle = display.newCircle(event.source.params.x, 
		                                   event.source.params.y, radius);
		colorObject(circle);
		physics.addBody(circle, "dynamic", { density=-.5, friction=0.0, bounce=1, radius=radius });
		circle:applyForce(math.random(3, 5), 0, x, y);
		circle.name = "garbage"
		game:insert(circle);
	end
end

local function ballCollision ( event )
	if (event.phase=="began" and event.other.name ~= nil) then
		if(event.other.name == "bottom" ) then
			gameOver();
		elseif (event.other.name == "colorChanger" and 
		        event.other.used == false ) then
			local currentColor = playerBall.colorTag
			while (currentColor == playerBall.colorTag ) do
				colorObject(playerBall);
			end
			event.other.used = true;
			score = score + 1;
			updateScore();
		elseif ( event.name == "garbage" or event.other.name == "garbage") then
			-- no op
		elseif(string.find(event.other.name, "testObs_") ~= nil) then
			print("collided with " .. event.other.name);

			if(playerBall.colorTag == event.other.colorTag) then
				print("you may pass");
			elseif ( deadMeat ~= true ) then 
				deadMeat = true;
				print("none shall pass");
				local tm = timer.performWithDelay(10, explode);
				tm.params = {x = playerBall.x, y= playerBall.y}
				playerBall:setFillColor(0,0,0);
				--gameOver();
			end
		end
	end
end

local function screenTap ( event )
	if ( gameStarted == false ) then -- leaving ball stationary until first tap
		physics.addBody (playerBall, "dynamic", { density=-.5, friction=0.0, bounce=0.2, radius=display.contentWidth / 35.0 });
		gameStarted = true;
	end
	
	local delta = top.y - playerBall.y;
	--print(delta, delta/100)
	-- playerBall:applyForce(0,-25, playerBall.x, playerBall.y);
	playerBall:applyForce(0, delta/75, playerBall.x, playerBall.y);
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

function moveRight( object ) 
	transition.to(object, {x=object.x + display.contentWidth, time=3000, 
	                       onComplete= function(obj) 
								moveLeft(obj, object);
						   end
						   } );
end	

function moveLeft( object ) 
	transition.to(object, {x=object.x - display.contentWidth, time=3000, 
	                       onComplete= function(obj) 
								moveRight(obj, object);
						   end
						   } );
end

function moveBackAndForthForever( object ) 
	moveRight(object);
end

function addSpinningDiamondObs(obsY)
	local diamondVerts = {-13,-17, 0,55, 13,-17, 0,-55};
	local ax = 0.5
    local ay = 1
    local sx, xy;

    --======================
	-- add first pinwheel
	--======================

	local xOffset = -115;

	-- make sure at least one diamond is the color of the ball
	-- just in case we add more colors...
	local randIndex = 1;

	-- diamond 1 (top)
	local diamond1 = display.newPolygon(display.contentWidth/2.+xOffset, obsY, diamondVerts);
	diamond1.name = "testObs_spinWheel1_diamond1";
	sx, sy = diamond1:localToContent( diamond1.width*ax, diamond1.height*ay )
   	diamond1.anchorX = ax
   	diamond1.anchorY = ay
   	diamond1.x = sx - (diamond1.width/2)
   	diamond1.y = sy - (diamond1.height/2)
	
	colorObjectOrange(diamond1);

	game:insert(diamond1);
	physics.addBody( diamond1, "kinematic", {isSensor=true})
	diamond1.angularVelocity = 50;

	-- diamond 2 (bottom)
	local diamond2 = display.newPolygon(display.contentWidth/2.+xOffset, obsY, diamondVerts);
	diamond2.name = "testObs_spinWheel1_diamond2";
	sx, sy = diamond2:localToContent( diamond2.width*ax, diamond2.height*ay )
   	diamond2.anchorX = ax
   	diamond2.anchorY = ay
   	diamond2.x = sx - (diamond2.width/2)
   	diamond2.y = sy - (diamond2.height/2)

	colorObjectPurple(diamond2);

	game:insert(diamond2);
	physics.addBody( diamond2, "kinematic", {isSensor=true})
	diamond2.rotation = 180;
	diamond2.angularVelocity = 50;

	-- diamond 3 (left)
	local diamond3 = display.newPolygon(display.contentWidth/2.+xOffset, obsY, diamondVerts);
	diamond3.name = "testObs_spinWheel1_diamond3";
	sx, sy = diamond3:localToContent( diamond3.width*ax, diamond3.height*ay )
   	diamond3.anchorX = ax
   	diamond3.anchorY = ay
   	diamond3.x = sx - (diamond3.width/2)
   	diamond3.y = sy - (diamond3.height/2)

	colorObjectCyan(diamond3);

	game:insert(diamond3);
	physics.addBody( diamond3, "kinematic", {isSensor=true})
	diamond3.rotation = -90;
	diamond3.angularVelocity = 50;

	-- diamond 4 (right)
	local diamond4 = display.newPolygon(display.contentWidth/2.+xOffset, obsY, diamondVerts);
	diamond4.name = "testObs_spinWheel1_diamond4";
	sx, sy = diamond4:localToContent( diamond4.width*ax, diamond4.height*ay )
   	diamond4.anchorX = ax
   	diamond4.anchorY = ay
   	diamond4.x = sx - (diamond4.width/2)
   	diamond4.y = sy - (diamond4.height/2)

	colorObjectGreen(diamond4);

	game:insert(diamond4);
	physics.addBody( diamond4, "kinematic", {isSensor=true})
	diamond4.rotation = 90;
	diamond4.angularVelocity = 50;


	--======================
	-- add second pinwheel
	--======================

	local xOffset = 115;

	-- need to randomly make sure at least one way to get through
	-- randIndex = math.random(4);
	local prevDiamonds = {diamond1, diamond2, diamond3, diamond4};
	local randDiamond = prevDiamonds[randIndex];
	print("randDiamond " .. randIndex, randDiamond)

	-- diamond 1 (top)
	local diamond1 = display.newPolygon(display.contentWidth/2.+xOffset, obsY, diamondVerts);
	diamond1.name = "testObs_spinWheel2_diamond1";
	sx, sy = diamond1:localToContent( diamond1.width*ax, diamond1.height*ay )
   	diamond1.anchorX = ax
   	diamond1.anchorY = ay
   	diamond1.x = sx - (diamond1.width/2)
   	diamond1.y = sy - (diamond1.height/2)
   	
	colorObjectOrange(diamond1);

	game:insert(diamond1);
	physics.addBody( diamond1, "kinematic", {isSensor=true})
	diamond1.angularVelocity = -50;

	-- diamond 2 (bottom)
	local diamond2 = display.newPolygon(display.contentWidth/2.+xOffset, obsY, diamondVerts);
	diamond2.name = "testObs_spinWheel2_diamond2";
	sx, sy = diamond2:localToContent( diamond2.width*ax, diamond2.height*ay )
   	diamond2.anchorX = ax
   	diamond2.anchorY = ay
   	diamond2.x = sx - (diamond2.width/2)
   	diamond2.y = sy - (diamond2.height/2)

	colorObjectPurple(diamond2);

	game:insert(diamond2);
	physics.addBody( diamond2, "kinematic", {isSensor=true})
	diamond2.rotation = 180;
	diamond2.angularVelocity = -50;

	-- diamond 3 (left)
	local diamond3 = display.newPolygon(display.contentWidth/2.+xOffset, obsY, diamondVerts);
	diamond3.name = "testObs_spinWheel2_diamond3";
	sx, sy = diamond3:localToContent( diamond3.width*ax, diamond3.height*ay )
   	diamond3.anchorX = ax
   	diamond3.anchorY = ay
   	diamond3.x = sx - (diamond3.width/2)
   	diamond3.y = sy - (diamond3.height/2)

	colorObjectGreen(diamond3);

	game:insert(diamond3);
	physics.addBody( diamond3, "kinematic", {isSensor=true})
	diamond3.rotation = -90;
	diamond3.angularVelocity = -50;

	-- diamond 4 (right)
	local diamond4 = display.newPolygon(display.contentWidth/2.+xOffset, obsY, diamondVerts);
	diamond4.name = "testObs_spinWheel2_diamond4";
	sx, sy = diamond4:localToContent( diamond4.width*ax, diamond4.height*ay )
   	diamond4.anchorX = ax
   	diamond4.anchorY = ay
   	diamond4.x = sx - (diamond4.width/2)
   	diamond4.y = sy - (diamond4.height/2)
	
	colorObjectCyan(diamond4);

	game:insert(diamond4);
	physics.addBody( diamond4, "kinematic", {isSensor=true})
	diamond4.rotation = 90;
	diamond4.angularVelocity = -50;

	return obsY - 400;
end

function addColorChanger2(obsY)
	local vertices = { 0,-110, 27,-35, 105,-35, 43,16, 65,90, 0,45, -65,90, -43,15, -105,-35, -27,-35, }

	local colorChanger = display.newPolygon( display.contentWidth/2., obsY, vertices )
	colorChanger.name = "colorChanger";
	colorChanger.used = false;
	colorChanger.xScale = .5;
	colorChanger.yScale = .5;
	colorChanger.strokeWidth = 5
	colorChanger:setStrokeColor( 1, 0, 0 )
	physics.addBody( colorChanger, "static", {density=3, isSensor=true})
	game:insert(colorChanger);

	timer.performWithDelay(
		10,
		function()
			colorChanger.rotation = colorChanger.rotation + 1;
		end,
		0
	);

	return obsY - 400;
end

local function addColorChanger(obsY)
	local colorChangerImage = "colorChanger.png"
	local colorChanger_outline = graphics.newOutline( 2, colorChangerImage )
	local colorChanger = display.newImageRect( colorChangerImage, 32, 32 )
	colorChanger.name = "colorChanger";
	colorChanger.used = false;
	colorChanger.xScale = 2;
	colorChanger.yScale = 2;
	colorChanger.x = display.contentWidth / 2.;
	colorChanger.y = obsY;
	physics.addBody( colorChanger, "static", { outline=colorChanger_outline } )
	colorChanger.isSensor = true;
	game:insert(colorChanger);

	timer.performWithDelay(
		10,
		function()
			colorChanger.rotation = colorChanger.rotation + 1;
		end,
		0
	);

	return obsY - 400;
end

local function addMultiLineObs(obsY)
	local blockX = 0 - display.contentWidth + display.contentWidth/8;
	if ( DelaySwap == true) then
		DelaySwap = false;
		waitTime = 500;
	else
		DelaySwap = true;
		waitTime = 100;
	end

	for i = 1 , 9 do
		local block = display.newRect(blockX, obsY, display.contentWidth/4.0, 50);
		blockX = blockX + display.contentWidth/4.0;
		if ( (i % 4) == 3 ) then 
			colorObjectCyan(block);
		elseif ( (i % 4) == 0 ) then
			colorObjectOrange(block);
		elseif ( (i % 4) == 1 ) then
			colorObjectGreen(block);
		else -- ( (i % 4) == 2 ) then 
			colorObjectPurple(block);
		end
		physics.addBody(block, "static");
		block.isSensor = true;
		game:insert(block);
		block.name = "testObs_" .. obsNum;
		obsNum = obsNum + 1;
		timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);
	end
	blockX = - 150 - display.contentWidth + display.contentWidth/8 ;
	obsY = obsY - 50;
	for i = 1 , 10 do
		local block = display.newRect(blockX, obsY, display.contentWidth/4.0, 50);
		blockX = blockX + display.contentWidth/4.0;
		if ( (i % 4) == 0 ) then 
			colorObjectCyan(block);
		elseif ( (i % 4) == 1 ) then
			colorObjectOrange(block);
		elseif ( (i % 4) == 2 ) then
			colorObjectGreen(block);
		else -- ( (i % 4) == 3 ) then 
			colorObjectPurple(block);
		end
		physics.addBody(block, "static");
		block.isSensor = true;
		game:insert(block);
		block.name = "testObs_" .. obsNum;
		obsNum = obsNum + 1;
		timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);
	end
	blockX = - 300 - display.contentWidth + display.contentWidth/8 ;
	obsY = obsY - 50;
	for i = 1 , 11 do
		local block = display.newRect(blockX, obsY, display.contentWidth/4.0, 50);
		blockX = blockX + display.contentWidth/4.0;
		if ( (i % 4) == 1 ) then 
			colorObjectCyan(block);
		elseif ( (i % 4) == 2 ) then
			colorObjectOrange(block);
		elseif ( (i % 4) == 3 ) then
			colorObjectGreen(block);
		else -- ( (i % 4) == 0 ) then 
			colorObjectPurple(block);
		end
		physics.addBody(block, "static");
		block.isSensor = true;
		game:insert(block);
		block.name = "testObs_" .. obsNum;
		obsNum = obsNum + 1;
		timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);
	end

	return obsY - 400;
end

local function addSingleLineObs(obsY)
	local blockX = 0 - display.contentWidth + display.contentWidth/8;
	if ( DelaySwap == true) then
		DelaySwap = false;
		waitTime = 500;
	else
		DelaySwap = true;
		waitTime = 100;
	end

	for i = 1 , 9 do
		local block = display.newRect(blockX, obsY, display.contentWidth/4.0, 50);
		blockX = blockX + display.contentWidth/4.0;
		if ( (i % 4) == 0 ) then 
			colorObjectCyan(block);
		elseif ( (i % 4) == 1 ) then
			colorObjectOrange(block);
		elseif ( (i % 4) == 2 ) then
			colorObjectGreen(block);
		else -- ( (i % 4) == 3 ) then 
			colorObjectPurple(block);
		end
		physics.addBody(block, "static");
		block.isSensor = true;
		game:insert(block);
		block.name = "testObs_" .. obsNum;
		obsNum = obsNum + 1;
		timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);	end
	
	return obsY - 400;
end

local function addLinesWithSpaceObs( obsY ) 
	local blockX = 0 - display.contentWidth + display.contentWidth/8;
	if ( DelaySwap == true) then
		DelaySwap = false;
		waitTime = 500;
	else
		DelaySwap = true;
		waitTime = 100;
	end

	for i = 1 , 4 do
		local drawHeight;
		if ( i % 2 == 0 ) then 
			drawHeight = obsY;
		else 
			drawHeight = obsY - 200;
		end
		
		local block = display.newRect(blockX, drawHeight, display.contentWidth/4.0, 50);
		blockX = blockX + display.contentWidth/2.0;
		if ( (i % 4) == 0 ) then 
			colorObjectCyan(block);
		elseif ( (i % 4) == 1 ) then
			colorObjectOrange(block);
		elseif ( (i % 4) == 2 ) then
			colorObjectGreen(block);
		else -- ( (i % 4) == 3 ) then 
			colorObjectPurple(block);
		end
		physics.addBody(block, "static");
		block.isSensor = true;
		game:insert(block);
		block.name = "testObs_" .. obsNum;
		obsNum = obsNum + 1;
		timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);	end
	
	return obsY - 500;
end

local function addRotatingSquare( obsY )
	-- This call blows up :(
	--display.setDefault( "isAnchorClamped", false )
	local ax = 0.5
    local ay = 1
    local sx, xy;

	-- bottom
	local bottom = display.newRect(display.contentWidth/2, obsY, 
						display.contentWidth - display.contentWidth / 4.0, 50);
	bottom.name = "testObs_spinSqure_bottom";
	sx, sy = bottom:localToContent( bottom.width*ax, bottom.height*ay )
   	bottom.anchorX = ax
   	bottom.anchorY = 5
   	bottom.x = sx - (bottom.width/2)
   	bottom.y = sy - (bottom.height/2)
	
	colorObjectCyan(bottom);

	game:insert(bottom);
	physics.addBody( bottom, "kinematic", {isSensor=true})
	bottom.rotation = 90;
	bottom.angularVelocity = -50;
	

	return obsY - 400;
end

local function addObstacles()
	local obsY = 300;

	--obsY = addRotatingSquare(obsY); -- Has problem 
	obsY = addSpinningDiamondObs(obsY);
	--obsY = addColorChanger2(obsY);
	obsY = addColorChanger(obsY);
	obsY = addLinesWithSpaceObs(obsY);
	obsY = addColorChanger(obsY);
	obsY = addSingleLineObs(obsY);
	obsY = addSingleLineObs(obsY)
	obsY = addColorChanger(obsY);
	obsY = addMultiLineObs(obsY);
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
		top = display.newRect(0,0,display.contentWidth, 20);
		bottom = display.newRect(0,display.contentHeight-20,display.contentWidth, 20);
		bottom.name = "bottom";
		top:setFillColor(0,0,0);
		bottom:setFillColor(0,1,0);
							   
		bottom.anchorX = 0;bottom.anchorY = 0;
		top.anchorX = 0;top.anchorY = 0;
		physics.addBody( bottom, "static" );

		game:insert(bottom);
		game:insert(top);

		playerBall = display.newCircle(display.contentCenterX, 
			display.contentHeight-150, display.contentWidth / 35.0);
		
		playerBall.tag = "player";
		
		playerBall:addEventListener("collision", ballCollision);
		colorObject(playerBall);
		game:insert(playerBall);

		updateScore();

		addObstacles();
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
