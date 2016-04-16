local widget = require("widget")
local physics = require ("physics");
physics.start();

local composer = require( "composer" );
local options = {effect="fade", time=1000, params={lives=1}}

composer.gotoScene( "SceneFactory", options);