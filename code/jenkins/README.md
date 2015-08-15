# kitchen docker test
curl -L https://raw.githubusercontent.com/DennyZhang/data/master/jenkins/kitchen_docker_test.sh 2>/dev/null | bash

# code style check
curl -L https://raw.githubusercontent.com/DennyZhang/data/master/jenkins/chef_style_check.sh 2>/dev/null | bash

# setup
echo "Install foodcritic to check Cookbook Style &amp; Correctness"
$(sudo gem list | grep foodcritic 1>/dev/null 2>/dev/null) || sudo gem install foodcritic --no-ri --no-rdoc -v 4.0.0

echo "Install rubocop to check Cookbook Style &amp; Correctness"
$(sudo gem list | grep rubocop 1>/dev/null 2>/dev/null) || sudo gem install rubocop --no-ri --no-rdoc -v 0.31.0

foodcritic $cookbook
