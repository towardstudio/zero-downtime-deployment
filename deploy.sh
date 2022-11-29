##
# Zero Downtime Deployment
# A zero downtime deployment strategy for Laravel Forge. 🚫⏰
##

PROJECT_NAME=$(basename "$FORGE_SITE_PATH")

SITE_DIRECTORY="$FORGE_SITE_PATH"

CURRENT_DIRECTORY="$FORGE_PATH/$PROJECT_NAME/current"
REPO_DIRECTORY="$FORGE_PATH/$PROJECT_NAME/repo"
RELEASES_DIRECTORY="$FORGE_PATH/$PROJECT_NAME/releases"
SHARED_DIRECTORY="$FORGE_PATH/$PROJECT_NAME/shared"

RELEASE_NAME=$(date +"%d%m%Y_%H%M%S")
NEW_RELEASE_DIRECTORY="$RELEASES_DIRECTORY/$RELEASE_NAME"

REBRAND_DIRECTORY="$NEW_RELEASE_DIRECTORY/storage/rebrand"
ENV_EXAMPLE_FILE="$NEW_RELEASE_DIRECTORY/.env.example"

SHARED_ASSETS_DIRECTORY="$SHARED_DIRECTORY/assets"
SHARED_STORAGE_DIRECTORY="$SHARED_DIRECTORY/storage"
SHARED_VENDOR_DIRECTORY="$SHARED_DIRECTORY/vendor"
SHARED_NODE_MODULES_DIRECTORY="$SHARED_DIRECTORY/node_modules"
SHARED_ENV_FILE="$SHARED_DIRECTORY/.env"


# Set the parent of the site directory to the current working directory
cd "$SITE_DIRECTORY" && cd ../

# Check if the repo directory exists, and if not, create it from the site directory
[ -d "$REPO_DIRECTORY" ] || { mv "$SITE_DIRECTORY" "repo" && mkdir -p "$SITE_DIRECTORY" && mv "repo" "$SITE_DIRECTORY"; }

# Check if the required directories exists, and if not, create each one
mkdir -p "$RELEASES_DIRECTORY" "$SHARED_DIRECTORY"

# Check if the shared directories exists, and if not, create each one
mkdir -p "$SHARED_ASSETS_DIRECTORY" "$SHARED_STORAGE_DIRECTORY" "$SHARED_VENDOR_DIRECTORY" "$SHARED_NODE_MODULES_DIRECTORY"

# Create the new release directory
mkdir -p "$NEW_RELEASE_DIRECTORY"

# Pull and copy the latest changes from the repo directory to the new release directory
echo -e "\nPulling the latest changes from GitHub..."
cd "$REPO_DIRECTORY" && git reset --hard && git pull origin --rebase $FORGE_SITE_BRANCH && rsync -a "$REPO_DIRECTORY/" "$NEW_RELEASE_DIRECTORY"

# Check if the rebrand directory exists and copy it to the shared storage directory
[ -d "$REBRAND_DIRECTORY" ] && { rsync -a "$REBRAND_DIRECTORY" "$SHARED_STORAGE_DIRECTORY"; }

# Check if the shared .env file exists
[ ! -f "$SHARED_ENV_FILE" ] && {
	# Check if the .env.example file exists and copy it to the shared directory, otherwise create a new shared .env file
	[ -f "$ENV_EXAMPLE_FILE" ] && { mv "$ENV_EXAMPLE_FILE" "$SHARED_ENV_FILE"; } || { touch "$SHARED_ENV_FILE"; };
}

# Check if any of the shared directories or files already exist in the new release directory and delete them
rm -rf "$NEW_RELEASE_DIRECTORY/web/assets"
rm -rf "$NEW_RELEASE_DIRECTORY/storage"
rm -rf "$NEW_RELEASE_DIRECTORY/vendor"
rm -rf "$NEW_RELEASE_DIRECTORY/node_modules"
rm -f "$NEW_RELEASE_DIRECTORY/.env"

# Create or update the symlinks for each of the shared directories and files
ln -sfn "$SHARED_ASSETS_DIRECTORY" "$NEW_RELEASE_DIRECTORY/web/assets"
ln -sfn "$SHARED_STORAGE_DIRECTORY" "$NEW_RELEASE_DIRECTORY/storage"
ln -sfn "$SHARED_VENDOR_DIRECTORY" "$NEW_RELEASE_DIRECTORY/vendor"
ln -sfn "$SHARED_NODE_MODULES_DIRECTORY" "$NEW_RELEASE_DIRECTORY/node_modules"
ln -sfn "$SHARED_ENV_FILE" "$NEW_RELEASE_DIRECTORY/.env"

# Set the new release directory to the current working directory
cd "$NEW_RELEASE_DIRECTORY"

# Install Composer packages
echo -e "\nInstalling Composer packages..."
composer install --no-interaction --prefer-dist --optimize-autoloader

# Install Node packages
echo -e "\nInstalling Node packages..."
npm ci

# Build the production-ready assets
echo -e "\nBuilding the production-ready assets..."
npm run build

# Check if the .deployignore file exists and delete all listed files and directories
[ -f ".deployignore" ] && { echo -e "\nChecking .deployignore..." && cat ".deployignore" | xargs rm -rf; }

# Set the site directory to the current working directory
cd "$SITE_DIRECTORY"

# Create or update the symlink for the current directory
ln -sfn "$NEW_RELEASE_DIRECTORY" "current"

# Reload the PHP FastCGI Process Manager to ensure the new symlinks are detected
echo -e "\nReloading PHP FPM..."
sudo service "$FORGE_PHP_FPM" reload

echo -e "\nDeployment complete! 🎉"
