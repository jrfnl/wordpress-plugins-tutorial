printf "\nCommencing Setup for WP Plugin Tutorial\n"

# **
# Allow for this database to be backed up and reused.
# **
# Create custom database init script.
sh ./init-custom-sql.sh


# If we deleted htdocs, let's just start over.
if [ ! -d htdocs ]; then

	printf "Creating directory htdocs for WP Plugin Tutorial...\n"
	mkdir htdocs
	cd htdocs

	# **
	# Database
	# **

	# Create the database over again.
	printf "(Re-)Creating database 'wordpress_tutorial'...\n"
	mysql -u root --password=root -e "DROP DATABASE IF EXISTS \`wordpress_tutorial\`"
	mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS \`wordpress_tutorial\`"
	mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON \`wordpress_tutorial\`.* TO wp@localhost IDENTIFIED BY 'wp';"

	# **
	# WordPress
	# **

	# Download WordPress
	printf "Downloading WordPress in htdocs...\n"
	wp core download --allow-root

	# Install WordPress.
	printf "Creating wp-config in htdocs...\n"
	wp core config --dbname="wordpress_tutorial" --dbuser=wp --dbpass=wp --dbhost="localhost" --allow-root --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_DISPLAY', true );
define( 'SCRIPT_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
//define( 'SAVEQUERIES', true );
PHP

	# Install into DB
	printf "Installing WordPress...\n"
	wp core install --url=wptutorial.dev --title="A WordPress Plugin Developers VVV" --admin_user=admin --admin_password=password --admin_email=changme@changeme.com --allow-root

	# **
	# Installing Developer Plugins from WP.org
	# **

	printf 'Installing Developer Plugins...\n'
	wp plugin install debug-bar  --activate --allow-root
	wp plugin install debug-bar-actions-and-filters-addon  --activate --allow-root
	wp plugin install debug-bar-console --allow-root
	wp plugin install debug-bar-constants --allow-root
	wp plugin install debug-bar-cron  --activate --allow-root
	wp plugin install debug-bar-extender  --activate --allow-root
	wp plugin install debug-bar-localization --allow-root
	wp plugin install debug-bar-list-dependencies --allow-root
	wp plugin install tdd-debug-bar-post-meta --allow-root
	wp plugin install debug-bar-plugin-activation  --activate --allow-root
	wp plugin install debug-bar-post-types  --activate --allow-root
	wp plugin install debug-bar-query-count-alert --allow-root
	wp plugin install debug-bar-query-tracer --allow-root
	wp plugin install debug-bar-remote-requests --allow-root
	wp plugin install fg-debug-bar-rewrite-rules --allow-root
	wp plugin install debug-bar-roles-and-capabilities --allow-root
	wp plugin install debug-bar-screen-info  --activate --allow-root
	wp plugin install debug-bar-shortcodes --allow-root
	wp plugin install debug-bar-sidebars-widgets --allow-root
	wp plugin install debug-bar-slow-actions --allow-root
	wp plugin install debug-bar-super-globals --allow-root
	wp plugin install debug-bar-taxonomies  --allow-root
	#wp plugin install debug-bar-template-trace --allow-root # No longer in WP repo... ?
	wp plugin install debug-bar-transients --allow-root
	wp plugin install heartbeat-control --allow-root
	wp plugin install pmc-benchmark --allow-root

	wp plugin install demo-data-creator --allow-root
	# Fix PHP4 constructor in the Demo Data Creator plugin.
	echo "Removing errors from the Demo Data Creator plugin."
	if [[ -f /srv/www/wp-tutorial/htdocs/wp-content/plugins/demo-data-creator/plugin-register.class.php ]]; then
		sed -i -e 's/function Plugin_Register() {/function __construct() {/g' "/srv/www/wp-tutorial/htdocs/wp-content/plugins/demo-data-creator/plugin-register.class.php"
	fi
	if [[ -f /srv/www/wp-tutorial/htdocs/wp-content/plugins/demo-data-creator/demodata.php ]]; then
		sed -i -e 's/\$register->Plugin_Register();//g' "/srv/www/wp-tutorial/htdocs/wp-content/plugins/demo-data-creator/demodata.php"
	fi
	wp plugin activate demo-data-creator --allow-root

	wp plugin install developer --allow-root
	wp plugin install kint-debugger --allow-root

	wp plugin install log-deprecated-notices --allow-root
	# Fix PHP4 constructor in the Log Deprecated Notices plugin.
	echo "Removing errors from the Log Deprecated Notices plugin."
	if [[ -f /srv/www/wp-tutorial/htdocs/wp-content/plugins/log-deprecated-notices/log-deprecated-notices.php ]]; then
		sed -i -e 's/function Deprecated_Log() {/function __construct() {/g' "/srv/www/wp-tutorial/htdocs/wp-content/plugins/log-deprecated-notices/log-deprecated-notices.php"
	fi
	wp plugin activate log-deprecated-notices --allow-root

	wp plugin install log-deprecated-notices-extender  --activate --allow-root
	wp plugin install log-viewer  --activate --allow-root
	wp plugin install p3-profiler --allow-root
	wp plugin install piglatin --allow-root
	wp plugin install rewrite-rules-inspector --allow-root
	wp plugin install rtl-tester --allow-root
	wp plugin install sf-adminbar-tools --allow-root
	wp plugin install simply-show-ids --allow-root
	wp plugin install vip-scanner --allow-root
	wp plugin install what-the-file --allow-root
	wp plugin install whats-running --allow-root
	wp plugin install user-switching --allow-root
	wp plugin install wordpress-beta-tester --allow-root
	wp plugin install wordpress-database-reset --allow-root

	# **
	# Cloning some Plugins from Git
	# **

	# Best Practices Demo Plugin
	cd /srv/www/wp-tutorial/htdocs/wp-content/plugins
	printf "\nCloning example best practices plugin, see https://github.com/jrfnl/wp-plugin-best-practices-demo\n"
	git clone -b master https://github.com/jrfnl/wp-plugin-best-practices-demo.git "example-plugin"

	printf "\nCloning some plugins we can improve\n"
	git clone -b master https://github.com/oscitasthemes/Easy-Bootstrap-Shortcode.git "tutorial-easy-bootstrap-shortcode"
	git clone -b master https://github.com/minimus/wp-copyrighted-post.git "tutorial-copyrighted-post"
	git clone -b master https://github.com/bennettmcelwee/Search-Meter.git "tutorial-search-meter"
	git clone -b master https://github.com/webvitaly/login-logout.git "tutorial-login-logout"

	cd /srv/www/wp-tutorial/

else

	cd htdocs/

	# Updates
	if $(wp core is-installed --allow-root); then

		# Update WordPress.
		printf "Updating WordPress for WP Plugin Tutorial...\n"
		wp core update --allow-root
		wp core update-db --allow-root

		# Update Tutorial Plugins from Git
		printf "Updating tutorial plugins from Git...\n"

		cd /srv/www/wp-tutorial/htdocs/wp-content/plugins/example-plugin
		if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' ]]; then
			echo -e "\nUpdating example best practices plugin..."
			git pull --ff-only origin master
		else
			echo -e "\nSkipped updating example best practices plugin since not on master branch"
		fi

		cd /srv/www/wp-tutorial/htdocs/wp-content/plugins/tutorial-easy-bootstrap-shortcode
		if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' ]]; then
			echo -e "\nUpdating Easy Bootstrap Shortcode plugin..."
			git pull --ff-only origin master
		else
			echo -e "\nSkipped updating Easy Bootstrap Shortcode Plugin since not on master branch"
		fi

		cd /srv/www/wp-tutorial/htdocs/wp-content/plugins/tutorial-copyrighted-post
		if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' ]]; then
			echo -e "\nUpdating Copyrighted Post plugin..."
			git pull --ff-only origin master
		else
			echo -e "\nSkipped updating Copyrighted Post Plugin since not on master branch"
		fi

		cd /srv/www/wp-tutorial/htdocs/wp-content/plugins/tutorial-search-meter
		if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' ]]; then
			echo -e "\nUpdating Search Meter plugin..."
			git pull --ff-only origin master
		else
			echo -e "\nSkipped updating Search Meter Plugin since not on master branch"
		fi

		cd /srv/www/wp-tutorial/htdocs/wp-content/plugins/tutorial-login-logout
		if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' ]]; then
			echo -e "\nUpdating Login Logout plugin..."
			git pull --ff-only origin master
		else
			echo -e "\nSkipped updating Login Logout Plugin since not on master branch"
		fi
		
		cd /srv/www/wp-tutorial/htdocs

		# Update Developer Plugins from WP.org
		printf "Updating Developer Plugins which need updating from WP.org...\n"
		# DON'T update the git repos from WP.org!
		wp plugin update --all --allow-root

		# Update Themes from WP.org
		printf "Updating themes which need updating from WP.org...\n"
		wp theme update --all --allow-root

	fi

	cd ..

fi


# =============================================================================
# Removing Errors
# =============================================================================

# Fix PHP4 constructor in the Demo Data Creator plugin.
echo "Removing errors from the Demo Data Creator plugin."
if [[ -f /srv/www/wp-tutorial/htdocs/wp-content/plugins/demo-data-creator/plugin-register.class.php ]]; then
	sed -i -e 's/function Plugin_Register() {/function __construct() {/g' "/srv/www/wp-tutorial/htdocs/wp-content/plugins/demo-data-creator/plugin-register.class.php"
fi
if [[ -f /srv/www/wp-tutorial/htdocs/wp-content/plugins/demo-data-creator/demodata.php ]]; then
	sed -i -e 's/\$register->Plugin_Register();//g' "/srv/www/wp-tutorial/htdocs/wp-content/plugins/demo-data-creator/demodata.php"
fi

# Fix PHP4 constructor in the Log Deprecated Notices plugin.
echo "Removing errors from the Log Deprecated Notices plugin."
if [[ -f /srv/www/wp-tutorial/htdocs/wp-content/plugins/log-deprecated-notices/log-deprecated-notices.php ]]; then
	sed -i -e 's/function Deprecated_Log() {/function __construct() {/' "/srv/www/wp-tutorial/htdocs/wp-content/plugins/log-deprecated-notices/log-deprecated-notices.php"
fi

printf "Finished Setup for WP Plugin Tutorial!\n"
