--[[

CS 571 Final Project
Stephen Cothren & Trey Dickerhoff
Color Matcher

Main.lua

Main class for Color Matcher.

--]]

-- loud physics modules
local physics = require ("physics");
-- start the physics engine
physics.start();

-- load composer modules
local composer = require( "composer" );
-- setup options for showing start scene
local options = {effect="fade", time=1000}
-- transition to our start scene.
composer.gotoScene( "startScene", options);