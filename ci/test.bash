set -ex

export CI=true

apt-get update
apt-get install -y unzip

USE_SYSTEM_GECODE=1 bundle install --jobs=4
bundle exec rake spec:unit
bundle exec rake spec:integration:prepare
bundle exec rake spec:integration

