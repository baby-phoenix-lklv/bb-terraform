# how to run the config

setup your AWS CLI -> https://louiskimlevu.atlassian.net/wiki/spaces/BABY/pages/98326/Project+Overview

# Run init, plan, apply

export AWS_PROFILE=bbphoenix-759744877037

cd 1-network/
tf init
tf plan
tf apply --auto-approve

cd 2-eks/
tf init
tf plan
tf apply --auto-approve
// update eks config from tf output
aws ec2 describe-vpcs | grep phoenix

cd 3-eks-addons/
tf init
tf plan
tf apply --auto-approve
