local widget = require("widget")

local physics = require ("physics");
physics.start();

local scrollAmt = -10;
local scrollView = nil;

-- This SHOULD give us a pretty consistent feel across
--  devices (I hope)
physics.setGravity( 0, display.contentHeight / 25.0 )

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

local function ballCollision ( event )
	if (event.phase=="began" and event.other.name ~= nil) then
		if(event.other.name == "top") then
			local newX,newY = scrollView:getContentPosition();

			scrollView:scrollToPosition{
			    --y = scrollAmt,
			    y = newY - 100,
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

local playerBall = display.newCircle(display.contentCenterX, 
	display.contentHeight*4-150, display.contentWidth / 35.0);
playerBall:addEventListener("collision", ballCollision);
colorObject(playerBall);
physics.addBody (playerBall, "dynamic");
scrollView:insert(playerBall);

local function screenTap ( event )
	playerBall:applyForce(0,-15, playerBall.x, playerBall.y)
end

Runtime:addEventListener("tap", screenTap);

scrollView:scrollTo( "bottom", { time=100} )