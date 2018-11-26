# ***********************************************************************************************************************
# **           Confidential and Proprietary – Qualcomm Technologies, Inc.
# **
# **           This technical data may be subject to U.S. and international export, re-export, or transfer
# **           ("export") laws. Diversion contrary to U.S. and international law is strictly prohibited.
# **
# **           Restricted Distribution: Not to be distributed to anyone who is not an employee of either
# **           Qualcomm or its subsidiaries without the express approval of Qualcomm’s Configuration
# **           Management.
# **
# **           © 2013 Qualcomm Technologies, Inc
# ************************************************************************************************************************

source ../../../../init_env

Timerun=$TOOLS/timerun
Shuffle=$TOOLS/shuffle
Cacheblast=$TOOLS/cacheblast
low=100us
high=10000us
RANDITER=10
total_time=100
let "random_time = total_time * RANDITER/100"

$Timerun $random_time $Shuffle 0 100000 $Cacheblast 50000 1000000 $low $high. 