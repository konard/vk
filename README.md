# vk
VK automation for personal auditory growth.

# Warnings

DO NOT TRUST THIS SOFTWARE.

READ THE CODE.

BE CAREFUL TO
NOT UPLOAD YOUR TOKENS OR CREDENTIALS
TO THE REPOSITORY/PULL REQUEST.
CHECK GITIGNORE FILE.

# Setup

1. Setup your own [backend application](Application/README.md), or _please do not_ use app with 7907795 id.
2. Install prerequisites:
   ```
   sudo apt install curl jq
   ```
3. Install Node.js and npm (version 14 or higher is required):

   **Option A (Recommended): Using nvm**
   ```bash
   # Install nvm
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   # Restart your terminal or run:
   source ~/.bashrc
   # Install latest LTS version of Node.js
   nvm install --lts
   nvm use --lts
   ```

   **Option B: Using NodeSource repository**
   ```bash
   # Install Node.js 20.x (LTS)
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

   **Note:** Do NOT use `sudo apt install npm` as it installs Node.js v10.19.0, which is too old for chromedriver (requires Node.js >= 14).
4. Install selenium (for automatic token refreshing):

   If using nvm (Option A):
   ```bash
   npm install -g selenium-side-runner
   ```
   If using NodeSource (Option B):
   ```bash
   sudo npm install -g selenium-side-runner
   ```

5. Install Chrome driver (other browsers may be also used):

   If using nvm (Option A):
   ```bash
   npm install -g chromedriver --unsafe-perm=true --allow-root
   ```
   If using NodeSource (Option B):
   ```bash
   sudo npm install -g chromedriver --unsafe-perm=true --allow-root
   ```
   Execute this command again for a new major version of the Chrome browser.

# Use

0. This step is _optional_. Put your credentials in `email` and `pass` files (required to use automatic token refreshing):
   ```
   echo "top-secret-password" > pass
   echo "user@gmail.com" > email
   ```
1. Receive your token:

   https://oauth.vk.com/authorize?client_id=7907795&scope=friends&redirect_uri=https://oauth.vk.com/blank.html&display=page&response_type=token&revoke=1

   7907795 is an id of VK backend app where main logic is located. _Please use_ your app id here.

   Token works for 24 hours, it has access only to `friends` API methods.
2. Put your token at `access-token` file with no additional whitespace:
   ```
   echo "5c6a04c2805acbe79ed02c4e428d9d9a2054decb432f76b6532b3cdca5219059510679444396bead857ff" > access-token
   ```
