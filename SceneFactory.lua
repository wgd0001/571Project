--[[

CS 571 Final Project
Stephen Cothren & Trey Dickerhoff
Color Matcher

SceneFactory.lua

Responsible for creating game based on the users
difficulty choice.

--]]

-- start physics
physics.start();
-- setup gravity
physics.setGravity( 0, display.contentHeight / 25.0 )
-- load compser modules
local composer = require( "composer" )
-- create scene
local scene = composer.newScene();
-- create a display group for our game
local game = display.newGroup();
-- create a bottom and top wall
local bottom = nil;
local top = nil;

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Globals
local difficulty;
local obsSpace;
local playerBall = nil;
local gameStarted = false;
local deadMeat = false;
local DelaySwap = false;
local obsNum = 0;
local obsTimers = {};
local numObsTimers = 1;
local score = 0;
local scoreTextInit = false;
local scoreText;
local difficultyText;

-- Colors here are from http://www.avatar.se/molscript/doc/colour_names.html

-- function: colorObjectCyan(object)
-- input: object to color cyan
-- output: na
-- description: colors provided object cyan
local function colorObjectCyan( object ) 
	object:setFillColor(0,1,1);
	object.colorTag = "cyan";
	object.r = 0;
	object.g = 1;
	object.b = 1;
end

-- function: colorObjectPurple(object)
-- input: object to color purple
-- output: na
-- description: colors provided object purple
local function colorObjectPurple( object ) 
	object:setFillColor(0.627451, 0.12549, 0.941176)
	object.colorTag = "purple";
	object.r = 0.627451;
	object.g = 0.12549;
	object.b = 0.941176;
end

-- function: colorObjectOrange(object)
-- input: object to color orange
-- output: na
-- description: colors provided object orange
local function colorObjectOrange( object )
	object:setFillColor(1, 0.647059, 0)
	object.colorTag = "orange";
	object.r = 1;
	object.g = 0.647059;
	object.b = 0;
end

-- function: colorObjectGreen(object)
-- input: object to color green
-- output: na
-- description: colors provided object green
local function colorObjectGreen( object )
	object:setFillColor(0.498039, 1, 0)
	object.colorTag = "green";
	object.r = 0.498039;
	object.g = 1;
	object.b = 0;
end

-- function: colorObject(object)
-- input: object to randomly color
-- output: na
-- description: assigns a random color to the
-- provided object
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

-- function: reset()
-- input: na
-- output: na
-- description: resets the game to initial state
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

-- function: gameOver()
-- input: na
-- output: na
-- description: preforms game over logic
local function gameOver()
	timer.performWithDelay(
		100,
		function()
			reset();
		end,
		1
	);
end

-- function: updateScore()
-- input: na
-- output: na
-- description: updates score bar to reflect current
-- score and difficulty mode during gameplay
local function updateScore()
	if ( scoreTextInit == true ) then 
		scoreText:removeSelf();
		difficultyText:removeSelf();
	end
	
	local scoreTextOpt = 
	{
		text = "  Score : " .. score,     
		x = display.contentWidth / 2.0 ,
		y = 0 + 50,
		width = display.contentWidth,    
		height = 60;
		font = native.systemFontBold,   
		fontSize = 48,
		align = "left" 
	}
	scoreText = display.newText(scoreTextOpt);
	scoreText:setFillColor(1,1,1);
	
	local difficultyTextOpt = 
	{
		text = "Mode : " .. difficulty .. "  " ,     
		x = display.contentWidth / 2.0 ,
		y = 0 + 50,
		width = display.contentWidth,    
		height = 60;
		font = native.systemFontBold,   
		fontSize = 48,
		align = "right" 
	}
	difficultyText = display.newText(difficultyTextOpt);
	difficultyText:setFillColor(1,1,1);

	scoreTextInit = true;	
end

-- function: explode(event)
-- input: event
-- output: na
-- description: creates an explosion effect when the user collides
-- with an obstacle
local function explode ( event )
	-- want these to go away so they don't bounce at the bottom on restart
	local circles = {};
	for i = 1, 10 do
		local radius = math.random(1, 10);
		circles[i] = display.newCircle(event.source.params.x, 
		                                   event.source.params.y, radius);
		colorObject(circles[i]);
		physics.addBody(circles[i], "dynamic", { density=-.5, friction=0.0, bounce=1, radius=radius });
		circles[i]:applyForce(math.random(3, 5), 0, x, y);
		circles[i].name = "garbage"
		game:insert(circles[i]);
	end

	timer.performWithDelay(
			1000,
			function()
				for i = 1, 10 do
					physics.removeBody(circles[i]);
					game:remove(circles[i]);
					circles[i]:removeSelf();
				end
			end,
			1
	);
end

-- function: ballCollision(event)
-- input: event
-- output: na
-- description: collision listener for the player ball
local function ballCollision ( event )
	-- check if we're in the began phase
	if (event.phase=="began" and event.other.name ~= nil) then
		-- if we've hit the floor, game over
		if(event.other.name == "bottom" ) then
			gameOver();
			-- react appropriately if the ball collides with a color changer
		elseif (event.other.name == "colorChanger" and 
		        event.other.used == false ) then
			-- make sure we give it a new color
			local currentColor = playerBall.colorTag
			while (currentColor == playerBall.colorTag ) do
				colorObject(playerBall);
			end
			event.other.used = true;
			event.other:setFillColor(0.15, 0.15, 0.15); -- look "used"
			-- update our score
			score = score + 1;
			updateScore();
		elseif ( event.name == "garbage" or event.other.name == "garbage") then
			-- no op
		elseif(string.find(event.other.name, "testObs_") ~= nil) then
			-- play has collided with an obstacle...see if we'll allow
			-- the ball to pass through or not
			if(playerBall.colorTag == event.other.colorTag) then
				-- good to go
			elseif ( deadMeat ~= true ) then
				-- show explosion animation 
				deadMeat = true;
				local tm = timer.performWithDelay(10, explode);
				tm.params = {x = playerBall.x, y= playerBall.y}
				playerBall:setFillColor(0,0,0);
			end
		end
	end
end

-- function: screenTap(event)
-- input: event
-- output: na
-- description: handles screen tap logic
local function screenTap ( event )
	if ( gameStarted == false ) then -- leaving ball stationary until first tap
		physics.addBody (playerBall, "dynamic",
			{ density=-.5, friction=0.0, bounce=0.2, radius=display.contentWidth / 35.0 });
		gameStarted = true;
	end
	
	-- try and help the ball stay in play a little here...
	local delta = top.y - playerBall.y;
	playerBall:applyForce(0, delta/75, playerBall.x, playerBall.y);
end

-- function: checkWinner()
-- input: na
-- output: na
-- description: checks to see if the player has crossed the finish line
local function checkWinner()
	-- if the player has passed the finish line congratulate them
	if(playerBall.y < -5500) then
		-- stop the game and move to the win screen
		physics.stop();
		local options = {effect="fade", time=500}
		composer.removeScene("SceneFactory", false);
		composer.gotoScene( "winScreen", options);
	end
end

-- function: moveView()
-- input: na
-- output: na
-- description: contains logic to move the view as the game progresses
local function moveView()
	if(playerBall ~= nil) then
		local delta = playerBall.y - top.y;
		-- go ahead and advance the view if we're getting close to the top
		if(delta < 500 and playerBall.y > -10000) then
			top.y = top.y - 10;
			game.y = game.y + 10;
			bottom.y = bottom.y - 10;
		end
		-- check if the player has won yet
		checkWinner();
	end
end

-- -------------------------------------------------------------------------------


-- function: create()
-- input: event
-- output: scene
-- description: creates and returns the scene
function scene:create( event )
end

-- function: moveRight(object)
-- input: object
-- output: na
-- description: creates transition effect to move obstacles to the right
-- over a specified period of time
function moveRight( object ) 
	transition.to(object, {x=object.x + display.contentWidth, time=3000, 
	                       onComplete= function(obj) 
								moveLeft(obj, object);
						   end
						   } );
end	

-- function: moveRight(object)
-- input: event
-- output: na
-- description: creates transition to move obstacles to the left over
-- a specified period of time
function moveLeft( object ) 
	transition.to(object, {x=object.x - display.contentWidth, time=3000, 
	                       onComplete= function(obj) 
								moveRight(obj, object);
						   end
						   } );
end

-- function: moveBackAndForthForever(event)
-- input: event
-- output: na
-- description: causes an object to transition from left to right across
-- the screen for the duration of the game
function moveBackAndForthForever( object ) 
	moveRight(object);
end

-- function: addSpinningDiamondObs(obsY)
-- input: obsY location to place obstacle
-- output: new valid obstacle y value
-- description: create the spinning diamond wheel obstacle
-- at the provided y location.  Returns a new y location
-- for the next obstacle to use
function addSpinningDiamondObs(obsY)
	local diamondVerts = {-13,-17, 0,55, 13,-17, 0,-55};
	local ax = 0.5
    local ay = 1
    local sx, xy;
	
	obsY = obsY - 50;

    --======================
	-- add first pinwheel
	--======================

	local xOffset = -115;

	-- make sure at least one diamond is the color of the ball
	-- just in case we add more colors...
	local randIndex = math.random(1,4);

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

	return obsY - obsSpace;
end

-- function: addColorChanger(obsY)
-- input: obsY location to place color changer
-- output: new valid obstacle y value
-- description: add a color changer obstacle at y location obsY
-- and returns a new valied location for the next obstacle
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

	obsTimers[numObsTimers] = timer.performWithDelay(
		10,
		function()
			colorChanger.rotation = colorChanger.rotation + 1;
		end,
		0
	);
	numObsTimers = numObsTimers + 1;

	return obsY - obsSpace;
end

-- function: addMultiLineObs(obsY)
-- input: obsY location to place obstacle
-- output: new valid obstacle y value
-- description: add a multiline obstacle at y location obsY
-- and returns a new valied location for the next obstacle
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
		obsTimers[numObsTimers] = timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);
		numObsTimers = numObsTimers + 1;
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
		obsTimers[numObsTimers] = timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);
		numObsTimers = numObsTimers + 1;
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
		obsTimers[numObsTimers] = timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);
		numObsTimers = numObsTimers + 1;
	end

	return obsY - obsSpace;
end

-- function: addSingleLineObs(obsY)
-- input: obsY location to place obstacle
-- output: new valid obstacle y value
-- description: add a single line obstacle at y location obsY
-- and returns a new valied location for the next obstacle
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
		obsTimers[numObsTimers] = timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);
		numObsTimers = numObsTimers + 1;
	end
	
	return obsY - obsSpace;
end

-- function: addLinesWithSpaceObs(obsY)
-- input: obsY location to place obstacle
-- output: new valid obstacle y value
-- description: add obstacle at y location obsY
-- and returns a new valied location for the next obstacle
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
		obsTimers[numObsTimers] = timer.performWithDelay(
			waitTime,
			function()
				moveBackAndForthForever(block);
			end,
			1
		);
		numObsTimers = numObsTimers + 1;
	end
	
	return obsY - obsSpace - 100;
end

-- function: addObstaclesEasy()
-- input: na
-- output: na
-- description: sets up the game for easy mode
local function addObstaclesEasy()
	local obsY = 300;
	local lastWasColorChanger = true;

	while ( obsY > -5000 ) do
		local rand = math.random();
		
		if ( rand < 0.35 ) then 
			if ( lastWasColorChanger ~= true ) then
				obsY = addColorChanger(obsY);
				lastWasColorChanger = true;
			end
		elseif ( rand < 0.5 ) then
			lastWasColorChanger = false;
			obsY = addLinesWithSpaceObs(obsY);
		elseif ( rand < 0.75 ) then
			lastWasColorChanger = false;
			obsY = addSpinningDiamondObs(obsY);
		elseif ( rand < 0.85 ) then 
			lastWasColorChanger = false;
			obsY = addSingleLineObs(obsY);
		else -- ( rand > 0.85 ) then 
			lastWasColorChanger = false;
			obsY = addSingleLineObs(obsY);
			obsY = addSingleLineObs(obsY - obsSpace / 2.0);
		end
	end
end

-- function: addObstaclesNormal()
-- input: na
-- output: na
-- description: sets up the game for normal mode
local function addObstaclesNormal()
	local obsY = 300;
	local lastWasColorChanger = true;

	while ( obsY > -5000 ) do
		local rand = math.random();
		
		if ( rand < 0.20 ) then 
			if ( lastWasColorChanger ~= true ) then
				obsY = addColorChanger(obsY);
				lastWasColorChanger = true;
			end
		elseif ( rand < 0.25 ) then
			lastWasColorChanger = false;
			obsY = addLinesWithSpaceObs(obsY);
		elseif ( rand < 0.50 ) then
			lastWasColorChanger = false;
			obsY = addSpinningDiamondObs(obsY);
		elseif ( rand < 0.75 ) then 
			lastWasColorChanger = false;
			obsY = addSingleLineObs(obsY);
		elseif ( rand < 0.85 ) then 
			lastWasColorChanger = false;
			obsY = addSingleLineObs(obsY);
			obsY = addSingleLineObs(obsY - obsSpace / 2.0);
		elseif ( rand < 0.95 ) then
			lastWasColorChanger = false;
			obsY = addMultiLineObs(obsY);
		else -- ( rand > 0.95 ) then 
			lastWasColorChanger = false;
			obsY = addSpinningDiamondObs(obsY);
			obsY = addSpinningDiamondObs(obsY - 100);
			obsY = addSpinningDiamondObs(obsY - 100);
		end
	end
end

-- function: addObstaclesHard()
-- input: na
-- output: na
-- description: sets up the game for hard mode
local function addObstaclesHard()
	local obsY = 300;
	local lastWasColorChanger = true;

	while ( obsY > -5000 ) do
		local rand = math.random();
		
		if ( rand < 0.10 ) then 
			if ( lastWasColorChanger ~= true ) then
				obsY = addColorChanger(obsY);
				lastWasColorChanger = true;
			end
		elseif ( rand < 0.15 ) then
			lastWasColorChanger = false;
			obsY = addLinesWithSpaceObs(obsY);
		elseif ( rand < 0.30 ) then
			lastWasColorChanger = false;
			obsY = addSpinningDiamondObs(obsY);
		elseif ( rand < 0.50 ) then 
			lastWasColorChanger = false;
			obsY = addSingleLineObs(obsY);
		elseif ( rand < 0.65 ) then 
			lastWasColorChanger = false;
			obsY = addSingleLineObs(obsY);
			obsY = addSingleLineObs(obsY - obsSpace / 2.0);
		elseif ( rand < 0.75 ) then
			lastWasColorChanger = false;
			obsY = addMultiLineObs(obsY);
		elseif ( rand < 0.85 ) then 
			lastWasColorChanger = false;
			obsY = addSpinningDiamondObs(obsY);
			obsY = addSpinningDiamondObs(obsY - 100);
			obsY = addSpinningDiamondObs(obsY - 100);
		elseif ( rand < 0.95 ) then 
			lastWasColorChanger = false;
			obsY = addMultiLineObs(obsY);
			obsY = addMultiLineObs(obsY-100);
			obsY = addMultiLineObs(obsY-100);
			obsY = addMultiLineObs(obsY-100);
		else -- ( rand > 0.95 ) then 
			lastWasColorChanger = false;
			obsY = addMultiLineObs(obsY);
			obsY = addMultiLineObs(obsY-100);
		end
	end
end

-- function: addFinishLine()
-- input: na
-- output: na
-- description: adds a finish line for the user to cross
-- at the end of the game
local function addFinishLine()
	local finishLine = display.newGroup();
	local xBoxes = 30;
	local yBoxes = 30;
	-- the size of each box in the x-direction (width)
	local sizeX = display.contentWidth / xBoxes;
	-- the size of each box in the y-direction (height)
	local sizeY = display.contentHeight / yBoxes;

	local boxNum = 1;
	for i = 0, xBoxes-1 do
		for j = 0, 2 do
			-- decide where to place the box
			xLoc = sizeX * i + sizeX / 2;
			yLoc = sizeY * j + sizeY / 2;

			-- create the box
			box = display.newRect(xLoc, yLoc, sizeX, sizeY);
			-- add this box to our group
			finishLine:insert(box);
			-- set the box stroke width
			box.strokeWidth = 3;
			-- set the box stroke color to black
			box:setStrokeColor(0, 0, 0);
			-- fill in the box with black or white
			if(boxNum % 2 == 0) then
				box:setFillColor(0, 0, 0);
			else
				box:setFillColor(1, 1, 1);
			end

			-- increment our index
			boxNum = boxNum + 1;
		end
	end

	finishLine.x = 0;
	finishLine.y = -5500;
	game:insert(finishLine);
end

-- function: show(event)
-- input: event
-- output: scene
-- description: called when the scene is ready to be displayed
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
		addFinishLine();
		
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

		difficulty = event.params.mode;
		
		if ( difficulty == "Easy" ) then 
			obsSpace = 400;
			addObstaclesEasy();
		elseif ( difficulty == "Normal" ) then
			obsSpace = 300;
			addObstaclesNormal();
		else -- ( difficulty == "Hard" ) then
			obsSpace = 200;
			addObstaclesHard();
		end

		updateScore();

		Runtime:addEventListener( "tap", screenTap );
		Runtime:addEventListener( "enterFrame", moveView );
    end
end


-- function: hide(event)
-- input: event
-- output: scene
-- description: called when the scene is ready to be hidden
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


-- function: destroy(event)
-- input: event
-- output: scene
-- description: called when the scene is ready to be destroyed
function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
	for i=1,numObsTimers-1 do
        timer.cancel(obsTimers[i]);
    end

	Runtime:removeEventListener( "tap", screenTap );
	Runtime:removeEventListener( "enterFrame", moveView );
    game:removeSelf();
    scoreText:removeSelf();
	difficultyText:removeSelf();
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene