#***************************************************************
#
#  Purpose Test ChrPairs
#
#***************************************************************
set currpath [file dirname [info script]]
set lib_path [file join  ".." "lib"]
source "$lib_path/API_Misc.tcl"
# source "$lib_path/API_Chariot.tcl"

set inifile [file join [file dirname [info script]] setup.ini]
################################################################################
# Get INI file paramter
################################################################################
# Func_INI::Ping_igp "192.168.1.152"
set Func_INI::verbose on;#on off

Func_INI::_GetChariot_Param $inifile
Func_INI::_GetDUT $inifile
Func_INI::Ping_igp "192.168.1.1"
Func_INI::_GetTopologyIP $inifile
Func_INI::_GetWLAN_ClientModelName $inifile
Func_INI::_GetCriteria $inifile

################################################################################
# Check each endpoint if alive
################################################################################

set retval_wlan_ep [Func_INI::ChkDUTalive [dict get $dict_TopologyIP "wlan_ep_ipaddr"]]
set retval_dut_lan [Func_INI::ChkDUTalive [dict get $dict_TopologyIP "dut_lan_ipaddr"]]
set retval_wan_ep [Func_INI::ChkDUTalive [dict get $dict_TopologyIP "wan_ep_ipaddr"]]

#***************************************************************
#
# Script main
#
# catch is used when there could be extended error information,
# so we can log what happened.
#***************************************************************
#set Func_Chariot::verbose off;#on off

################################################################################
# Thruput 11AC
################################################################################

# Setup Chariot test file name
set testChrfile_11ac_lan2wan "";#dut modelname ;#wlan client modelname \;#TX or RX ;#timestamp
append testChrfile_11ac_lan2wan [dict get $Func_INI::dict_DUT "dut_modelname"] "_" \
        [dict get $Func_INI::dict_WLAN_ClientModelName "wlan_modelname"] "_" \
        "11ac" "_" "LAN2WLAN" "_" \
        [clock format [clock seconds] -format "%H:%M:%S_%m%d%Y"] ".tst"

set testChrfile_11ac_wlan2lan [regsub -all "LAN2WLAN" $testChrfile_11ac_lan2wan "WLAN2LAN"]
set testChrfile_11ac_wlan2wan2wlan [regsub -all "LAN2WLAN" $testChrfile_11ac_lan2wan "WLAN2LAN2WLAN"]
# puts $testChrfile_11ac_lan2wan,$testChrfile_11ac_wlan2lan,$testChrfile_11ac_wlan2wan2wlan

# Create a new test.
#Func_Chariot::Initialize

#set Func_Chariot::testFile $testChrfile_11ac_lan2wan
        
# Set the test filename for saving later.
#Func_Chariot::Test_Filename

# Set test duration
#set Func_Chariot::test_duration [dict get $Func_INI::dict_Chariot_Param "test_duration"]

# puts $Func_Chariot::test_duration
#Func_Chariot::SetRunOpts

# Set chariot related parameters
#set Func_Chariot::pairCount [dict get $Func_INI::dict_Chariot_Param "paircount"]
#set Func_Chariot::e1Addrs [dict get $Func_INI::dict_TopologyIP  "lan_ep_ipaddr"]
#set Func_Chariot::e2Addrs [dict get $Func_INI::dict_TopologyIP  "wlan_ep_ipaddr"]
#set Func_Chariot::protocols [dict get $Func_INI::dict_Chariot_Param "protocols"]
#set Func_Chariot::chrscript [dict get $Func_INI::dict_Chariot_Param "scripts"]

# Define some pairs for the test.
#Func_Chariot::SetChrPair

#Func_Chariot::RunTest_tillEnd

# Save the test so we can show results later.
#Func_Chariot::GetPairResult

################################################################################
# Thruput 11N
################################################################################

# Setup Chariot test file name
set testChrfile_11n_lan2wan ""     ;;#wlan client modelname#TX or RX #timestamp
append testChrfile_11n_lan2wan [dict get $Func_INI::dict_DUT "dut_modelname"] "_" \
        [dict get $Func_INI::dict_WLAN_ClientModelName "wlan_modelname"] "_" \
        "11n" "_" [string toupper "lan2wlan"] "_" \
        [clock format [clock seconds] -format "%H:%M:%S_%m%d%Y"] ".tst"

set testChrfile_11n_wlan2lan [regsub -all "LAN2WLAN" $testChrfile_11n_lan2wan "WLAN2LAN"]
set testChrfile_11n_wlan2wan2wlan [regsub -all "LAN2WLAN" $testChrfile_11n_lan2wan "WLAN2LAN2WLAN"]

# puts $testChrfile_11n_lan2wan,$testChrfile_11n_wlan2lan,$testChrfile_11n_wlan2wan2wlan

#set Func_Chariot::testFile $testChrfile_11ac_lan2wan
# 
# Set the test filename for saving later.
#Func_Chariot::Test_Filename

# Set test duration
#set Func_Chariot::test_duration [dict get $Func_INI::dict_Chariot_Param "test_duration"]

# puts $Func_Chariot::test_duration
#Func_Chariot::SetRunOpts

# Set chariot related parameters
#set Func_Chariot::pairCount [dict get $Func_INI::dict_Chariot_Param "paircount"]
#set Func_Chariot::e1Addrs [dict get $Func_INI::dict_TopologyIP  "lan_ep_ipaddr"]
#set Func_Chariot::e2Addrs [dict get $Func_INI::dict_TopologyIP  "wlan_ep_ipaddr"]
#set Func_Chariot::protocols [dict get $Func_INI::dict_Chariot_Param "protocols"]
#set Func_Chariot::chrscript [dict get $Func_INI::dict_Chariot_Param "scripts"]

# Define some pairs for the test.
#Func_Chariot::SetChrPair

#Func_Chariot::RunTest_tillEnd

# Save the test so we can show results later.
#Func_Chariot::GetPairResult