#!/bin/bash

# Capture a basic ping result to Google's primary DNS server to determine if
# outside access is available to us. If this does not reply after 2 attempts,
# we try one of Level3's DNS servers as well. If neither IP replies to a ping,
# then we'll skip a few things further in provisioning rather than creating a
# bunch of errors.
ping_result="$(ping -c 2 8.8.4.4 2>&1)"
if [[ $ping_result != *bytes?from* ]]; then
	ping_result="$(ping -c 2 4.2.2.2 2>&1)"
fi


if [[ $ping_result == *bytes?from* ]]; then

	## Drush install
	if [[ ! -d /srv/www/drush ]]; then
	   echo -e "\nDownloading drush..."
	   git clone https://github.com/drush-ops/drush.git /srv/www/drush
	   cd /srv/www/drush
	   # install composer to the local drush folder
	   composer install
	   ln -sf /srv/www/drush/drush /usr/local/bin/drush
	else
	   echo -e "\nUpdating drush..."
	   cd /srv/www/drush
	   git pull --rebase origin master
	fi

	# Install and configure the latest stable version of Drupal
	if [[ ! -d /srv/www/drupal-stable ]]; then
		echo "Downloading Drupal Stable, see http://drupal.org"
		cd /srv/www
		drush dl drupal
		mv drupal* drupal-stable
		cd /srv/www/drupal-stable/sites
		echo "Configuring Drupal Stable..."
		drush si --db-url=mysql://root:root@localhost/drupal_default --account-name=admin --account-pass=password --db-su=root --db-su-pw=root --site-name='Welcome to My Drupal Site' --y
	else
		echo "Drupal-stable already installed..."
	fi


fi