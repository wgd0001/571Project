local widget = require("widget")
local physics = require ("physics");
physics.start();

local composer = require( "composer" );
local options = {effect="fade", time=1000}

composer.gotoScene( "startScene", options);