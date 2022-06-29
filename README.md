<!-- PROJECT LOGO -->

<br />

<div align="center">
  <a href="https://github.com/Bluegg/toward">
    <img src="https://bluegg.co.uk/images/logo.svg" alt="The Project's Logo" width="160" style="background: white; padding: 1rem; border-radius: 1rem;">
  </a>

  <h3 align="center">Zero Downtime Deployment</h3>
  <p align="center">A zero downtime deployment strategy for Laravel Forge. 🚫⏰</p>
  <div align="center">
    <a href="https://github.com/Bluegg/bluegg-open-source-disclaimer">Open Source Disclaimer</a>
  </div>
  <br />
</div>

<!-- GETTING STARTED -->

## Important

The contents of this repository are pulled by Laravel Forge every time a site deployment is performed. The deploy script is then run to carry out the zero downtime deployment strategy. As such, it's **essential** that any changes to this script are tested thoroughly, and a **new release is created** when it is ready for use.

## Deploy Script

This script should be added to a Laravel Forge site's _Deploy Script_ field to enable this functionality.

```sh
FORGE_PATH="/home/forge"

DEPLOY_SCRIPT_VERSION="v1.0.0"
DEPLOY_SCRIPT_URL="https://raw.githubusercontent.com/Bluegg/zero-downtime-deployment/$DEPLOY_SCRIPT_VERSION/deploy.sh"

DEPLOY_DIRECTORY="$FORGE_PATH/.deploy/$DEPLOY_SCRIPT_VERSION"
DEPLOY_SCRIPT="$DEPLOY_DIRECTORY/deploy.sh"

#  Check if the deploy script exists, and if not, download it from GitHub
[ -f "$DEPLOY_SCRIPT" ] || { echo -e "\nDownloading Zero Downtime Deployment $DEPLOY_SCRIPT_VERSION..." && mkdir -p "$DEPLOY_DIRECTORY" && curl -o "$DEPLOY_SCRIPT" -sL "$DEPLOY_SCRIPT_URL"; }

# Check if the deploy script exists and run it, otherwise exit
[ -f "$DEPLOY_SCRIPT" ] && { source "$DEPLOY_SCRIPT"; } || { echo -e "\n$DEPLOY_SCRIPT does not exist." && exit 1; }
```

<!-- BLUEGG LOGO -->

<br />

<p align="center">
  <a href="https://bluegg.co.uk" target="_blank">
    <img src="https://bluegg.co.uk/apple-touch-icon.png" alt="Logo" width="40" height="40" style="border-radius: 0.5rem;">
  </a>
</p>
