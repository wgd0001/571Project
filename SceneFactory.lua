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
	-- Colors here are from http://www.avatar.se/molscript/doc/colour_names.html
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

local function explode ( event )
	for i = 1, 10 do
		local radius = math.random(1, 10);
		local circle = display.newCircle(event.source.params.x, event.source.params.y, radius);
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
		elseif (event.other.name == "colorChanger") then
			colorObject(playerBall);
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

function addSpinningDiamondObs(testObsY)
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
	local randIndex = math.random(4);

	-- diamond 1 (top)
	local diamond1 = display.newPolygon(display.contentWidth/2.+xOffset, testObsY, diamondVerts);
	diamond1.name = "testObs_spinWheel1_diamond1";
	sx, sy = diamond1:localToContent( diamond1.width*ax, diamond1.height*ay )
   	diamond1.anchorX = ax
   	diamond1.anchorY = ay
   	diamond1.x = sx - (diamond1.width/2)
   	diamond1.y = sy - (diamond1.height/2)
	
   	if(randIndex == 1) then
   		diamond1:setFillColor(playerBall.r, playerBall.g, playerBall.b);
		diamond1.colorTag = playerBall.colorTag;
		diamond1.r = playerBall.r;
		diamond1.g = playerBall.g;
		diamond1.b = playerBall.b;
   	else
   		colorObject(diamond1);
   	end

	game:insert(diamond1);
	physics.addBody( diamond1, "kinematic", {isSensor=true})
	diamond1.angularVelocity = 50;

	-- diamond 2 (bottom)
	local diamond2 = display.newPolygon(display.contentWidth/2.+xOffset, testObsY, diamondVerts);
	diamond2.name = "testObs_spinWheel1_diamond2";
	sx, sy = diamond2:localToContent( diamond2.width*ax, diamond2.height*ay )
   	diamond2.anchorX = ax
   	diamond2.anchorY = ay
   	diamond2.x = sx - (diamond2.width/2)
   	diamond2.y = sy - (diamond2.height/2)

   	if(randIndex == 2) then
   		diamond2:setFillColor(playerBall.r, playerBall.g, playerBall.b);
		diamond2.colorTag = playerBall.colorTag;
		diamond2.r = playerBall.r;
		diamond2.g = playerBall.g;
		diamond2.b = playerBall.b;
   	else
   		colorObject(diamond2);
   	end

	game:insert(diamond2);
	physics.addBody( diamond2, "kinematic", {isSensor=true})
	diamond2.rotation = 180;
	diamond2.angularVelocity = 50;

	-- diamond 3 (left)
	local diamond3 = display.newPolygon(display.contentWidth/2.+xOffset, testObsY, diamondVerts);
	diamond3.name = "testObs_spinWheel1_diamond3";
	sx, sy = diamond3:localToContent( diamond3.width*ax, diamond3.height*ay )
   	diamond3.anchorX = ax
   	diamond3.anchorY = ay
   	diamond3.x = sx - (diamond3.width/2)
   	diamond3.y = sy - (diamond3.height/2)

   	if(randIndex == 3) then
   		diamond3:setFillColor(playerBall.r, playerBall.g, playerBall.b);
		diamond3.colorTag = playerBall.colorTag;
		diamond3.r = playerBall.r;
		diamond3.g = playerBall.g;
		diamond3.b = playerBall.b;
   	else
   		colorObject(diamond3);
   	end

	game:insert(diamond3);
	physics.addBody( diamond3, "kinematic", {isSensor=true})
	diamond3.rotation = -90;
	diamond3.angularVelocity = 50;

	-- diamond 4 (right)
	local diamond4 = display.newPolygon(display.contentWidth/2.+xOffset, testObsY, diamondVerts);
	diamond4.name = "testObs_spinWheel1_diamond4";
	sx, sy = diamond4:localToContent( diamond4.width*ax, diamond4.height*ay )
   	diamond4.anchorX = ax
   	diamond4.anchorY = ay
   	diamond4.x = sx - (diamond4.width/2)
   	diamond4.y = sy - (diamond4.height/2)

   	if(randIndex == 4) then
   		diamond4:setFillColor(playerBall.r, playerBall.g, playerBall.b);
		diamond4.colorTag = playerBall.colorTag;
		diamond4.r = playerBall.r;
		diamond4.g = playerBall.g;
		diamond4.b = playerBall.b;
   	else
   		colorObject(diamond4);
   	end

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
	local diamond1 = display.newPolygon(display.contentWidth/2.+xOffset, testObsY, diamondVerts);
	diamond1.name = "testObs_spinWheel2_diamond1";
	sx, sy = diamond1:localToContent( diamond1.width*ax, diamond1.height*ay )
   	diamond1.anchorX = ax
   	diamond1.anchorY = ay
   	diamond1.x = sx - (diamond1.width/2)
   	diamond1.y = sy - (diamond1.height/2)
   	
   	if(randIndex == 1) then
   		diamond1:setFillColor(randDiamond.r, randDiamond.g, randDiamond.b);
		diamond1.colorTag = randDiamond.colorTag;
		diamond2.r = playerBall.r;
		diamond2.g = playerBall.g;
		diamond2.b = playerBall.b;
   	else
   		colorObject(diamond1);
   	end

	game:insert(diamond1);
	physics.addBody( diamond1, "kinematic", {isSensor=true})
	diamond1.angularVelocity = -50;

	-- diamond 2 (bottom)
	local diamond2 = display.newPolygon(display.contentWidth/2.+xOffset, testObsY, diamondVerts);
	diamond2.name = "testObs_spinWheel2_diamond2";
	sx, sy = diamond2:localToContent( diamond2.width*ax, diamond2.height*ay )
   	diamond2.anchorX = ax
   	diamond2.anchorY = ay
   	diamond2.x = sx - (diamond2.width/2)
   	diamond2.y = sy - (diamond2.height/2)
	
	if(randIndex == 2) then
   		diamond2:setFillColor(randDiamond.r, randDiamond.g, randDiamond.b);
		diamond2.colorTag = randDiamond.colorTag;
		diamond2.r = playerBall.r;
		diamond2.g = playerBall.g;
		diamond2.b = playerBall.b;
   	else
   		colorObject(diamond2);
   	end

	game:insert(diamond2);
	physics.addBody( diamond2, "kinematic", {isSensor=true})
	diamond2.rotation = 180;
	diamond2.angularVelocity = -50;

	-- diamond 3 (left)
	local diamond3 = display.newPolygon(display.contentWidth/2.+xOffset, testObsY, diamondVerts);
	diamond3.name = "testObs_spinWheel2_diamond3";
	sx, sy = diamond3:localToContent( diamond3.width*ax, diamond3.height*ay )
   	diamond3.anchorX = ax
   	diamond3.anchorY = ay
   	diamond3.x = sx - (diamond3.width/2)
   	diamond3.y = sy - (diamond3.height/2)
	
   	if(randIndex == 4) then
   		diamond3:setFillColor(randDiamond.r, randDiamond.g, randDiamond.b);
		diamond3.colorTag = randDiamond.colorTag;
		diamond3.r = playerBall.r;
		diamond3.g = playerBall.g;
		diamond3.b = playerBall.b;
   	else
   		colorObject(diamond3);
   	end

	game:insert(diamond3);
	physics.addBody( diamond3, "kinematic", {isSensor=true})
	diamond3.rotation = -90;
	diamond3.angularVelocity = -50;

	-- diamond 4 (right)
	local diamond4 = display.newPolygon(display.contentWidth/2.+xOffset, testObsY, diamondVerts);
	diamond4.name = "testObs_spinWheel2_diamond4";
	sx, sy = diamond4:localToContent( diamond4.width*ax, diamond4.height*ay )
   	diamond4.anchorX = ax
   	diamond4.anchorY = ay
   	diamond4.x = sx - (diamond4.width/2)
   	diamond4.y = sy - (diamond4.height/2)

   	if(randIndex == 3) then
   		diamond4:setFillColor(randDiamond.r, randDiamond.g, randDiamond.b);
		diamond4.colorTag = randDiamond.colorTag;
		diamond4.r = playerBall.r;
		diamond4.g = playerBall.g;
		diamond4.b = playerBall.b;
   	else
   		colorObject(diamond4);
   	end

	game:insert(diamond4);
	physics.addBody( diamond4, "kinematic", {isSensor=true})
	diamond4.rotation = 90;
	diamond4.angularVelocity = -50;

	return testObsY - 400;
end

function addColorChanger2(testObsY)
	local vertices = { 0,-110, 27,-35, 105,-35, 43,16, 65,90, 0,45, -65,90, -43,15, -105,-35, -27,-35, }

	local colorChanger = display.newPolygon( display.contentWidth/2., testObsY, vertices )
	colorChanger.name = "colorChanger";
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

	return testObsY - 400;
end

local function addColorChanger(testObsY)
	local colorChangerImage = "colorChanger.png"
	local colorChanger_outline = graphics.newOutline( 2, colorChangerImage )
	local colorChanger = display.newImageRect( colorChangerImage, 32, 32 )
	colorChanger.name = "colorChanger";
	colorChanger.xScale = 2;
	colorChanger.yScale = 2;
	colorChanger.x = display.contentWidth / 2.;
	colorChanger.y = testObsY;
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

	return testObsY - 400;
end

local function addMultiLineObs(testObsY)
	local blockX = 0 - display.contentWidth + display.contentWidth/8;
	if ( DelaySwap == true) then
		DelaySwap = false;
		waitTime = 500;
	else
		DelaySwap = true;
		waitTime = 100;
	end

	for i = 1 , 9 do
		local block = display.newRect(blockX, testObsY, display.contentWidth/4.0, 50);
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
	testObsY = testObsY - 50;
	for i = 1 , 10 do
		local block = display.newRect(blockX, testObsY, display.contentWidth/4.0, 50);
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
	testObsY = testObsY - 50;
	for i = 1 , 11 do
		local block = display.newRect(blockX, testObsY, display.contentWidth/4.0, 50);
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

	return testObsY - 400;
end

local function addSingleLineObs(testObsY)
	local blockX = 0 - display.contentWidth + display.contentWidth/8;
	if ( DelaySwap == true) then
		DelaySwap = false;
		waitTime = 500;
	else
		DelaySwap = true;
		waitTime = 100;
	end

	for i = 1 , 9 do
		local block = display.newRect(blockX, testObsY, display.contentWidth/4.0, 50);
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
	
	return testObsY - 400;
end

local function addSomeTestObstacles()
	local testObs = {"box", "circle", "rect"};
	local numTestObs = 10;
	local testObsY = 300;

	testObsY = addSpinningDiamondObs(testObsY);
	testObsY = addColorChanger2(testObsY);
	testObsY = addColorChanger(testObsY);
	testObsY = addSingleLineObs(testObsY);
	testObsY = addSingleLineObs(testObsY)
	testObsY = addMultiLineObs(testObsY);


	-- for obsNum = 1, numTestObs do
		-- local randInd = math.random(1, #testObs);
		-- local testObsType = testObs[randInd];

		-- local testObs = nil;

		-- if(testObsType == "box") then
			-- testObs = display.newRect(display.contentWidth/2, testObsY, 200, 200);
		-- elseif(testObsType == "circle") then
			-- testObs = display.newCircle(display.contentCenterX, testObsY, display.contentWidth / 15.0);
		-- elseif(testObsType == "rect") then
			-- testObs = display.newRect(display.contentWidth/2, testObsY, 300, 200);
		-- end

		-- timer.performWithDelay(
			-- 10,
			-- function()
				-- testObs.rotation = testObs.rotation + 1;
			-- end,
			-- 0
		-- );

		-- testObs.name = "testObs_" .. obsNum;
		-- colorObject(testObs);
		-- physics.addBody(testObs, "static");
		-- testObs.isSensor = true;
		-- game:insert(testObs);

		-- testObsY = testObsY - 300;
	-- end
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
		
		playerBall.tag = "player";
		
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
