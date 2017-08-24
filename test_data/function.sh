#!/bin/bash

function init_func()
{
	echo "init_func"
	second_func
}

function second_func()
{
	echo "secon"
	source platform_config/platform.rc
	echo $H2_DOLPHIN_CANTV_H2_PATH
}

init_func
