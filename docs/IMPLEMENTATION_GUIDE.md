# Implementation Guide

Follow each section in order. Labels identify where commands run. Replace every value in `<ANGLE_BRACKETS>`; do not type the brackets.

## 1. Run the website on your laptop

From a terminal, enter the project folder:

```bash
cd devops-college-project
python3 -m http.server 8000
```

Open <http://localhost:8000>. The Python command starts a local static web server; it does not change or deploy files. Press Ctrl+C to stop it.

## 2. Create a GitHub repository — laptop

On GitHub, create a **public** empty repository named `devops-college-project`. Do not initialize it with a README or license (this folder already has a README). Then run:

```bash
git init -b main
git add .
git commit -m "Create Jenkins AWS deployment project"
git remote add origin https://github.com/mridulkhanna2006pixel/devops-college-project.git
git push -u origin main
```

`git add` stages files, `git commit` records a local snapshot, `remote add` links the folder to GitHub, and `push` uploads the main branch. GitHub may ask you to authenticate in a browser. A GitHub account password is not accepted for HTTPS Git operations; use Git Credential Manager/browser sign-in or a fine-grained token. Never put a token in the command URL or source files.

For later edits, use `git add .`, `git commit -m "Describe your change"`, then `git push`.

## 3. Launch EC2

In the AWS Console, choose **EC2 → Launch instance**:

1. Name: `devops-college-project`.
2. AMI: **Ubuntu Server 24.04 LTS**, 64-bit architecture.
3. Instance type: choose an eligible small type available in your region/account, such as `t3.small` (2 GiB RAM); check current pricing and Free Tier eligibility in your account before launch. Jenkins and Nginx share memory, so more RAM helps.
4. Create a new key pair, choose PEM/OpenSSH, download the `.pem` once, and store it outside the Git project. You cannot retrieve the private key later.
5. Create/select a security group with inbound rules: SSH TCP 22 from **My IP** only; Custom TCP 8080 from **My IP** only; HTTP TCP 80 from Anywhere IPv4 (and IPv6 if enabled). No other inbound rules are needed here.
6. Use enough storage for Ubuntu, Jenkins and logs (20 GiB is a convenient learning size). Review the estimate, then launch.
7. Wait until instance status checks pass. Copy its public IPv4 address or public DNS name.

AWS charges can apply. Stop or terminate the instance when finished; stopping may not remove storage charges.

## 4. Connect and install packages — laptop then EC2

On your laptop, set the downloaded key file permissions and connect (replace paths and host):

```bash
chmod 400 ~/Downloads/<KEY_NAME>.pem
ssh -i ~/Downloads/<KEY_NAME>.pem ubuntu@<EC2_PUBLIC_DNS_OR_IP>
```

`chmod 400` makes the private key readable only by your account. After login, these commands run **on EC2**:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y git curl wget fontconfig openjdk-21-jre nginx
java -version
```

`sudo` runs the system package operations as administrator. Java 21 is Jenkins' runtime; Git obtains source; Nginx serves the site. Install Jenkins LTS from its official stable repository:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins nginx
sudo systemctl status jenkins --no-pager
```

The first command creates a location for the repository signing key. The key lets apt verify Jenkins packages. The `deb` line adds the official Jenkins LTS package source; apt installs it. `enable --now` starts each service now and at reboot.

## 5. Unlock Jenkins — browser + EC2

Open `http://<EC2_PUBLIC_IP>:8080` from your own computer. Jenkins may take a minute to start. On EC2, retrieve the one-time password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Enter it in the browser, choose **Install suggested plugins**, and create your administrator account. Keep Jenkins 8080 limited to your IP. Install the **Pipeline**, **Git**, and **Pipeline: Stage View** plugins if not already present. The Pipeline job below reads a Jenkinsfile from source control. No GitHub webhook is required for polling.

## 6. Clone the repository for the fixed job workspace — EC2

Create the job in Jenkins first, named exactly `devops-college-project`. Then in Jenkins, open the job and select **Configure → Advanced Project Options → Use custom workspace**, and set:

```text
/var/lib/jenkins/workspace/devops-college-project
```

Alternatively, allow the job to use its standard workspace when the job is named exactly this. Confirm the resulting workspace is the path above in a build log. Clone there as an administrator, then transfer ownership to Jenkins:

```bash
sudo mkdir -p /var/lib/jenkins/workspace/devops-college-project
sudo git clone https://github.com/mridulkhanna2006pixel/devops-college-project.git /var/lib/jenkins/workspace/devops-college-project
sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace/devops-college-project
```

If you already created the Pipeline job with **Pipeline script from SCM**, Jenkins may create/check out its workspace on the first build. Keep the workspace path consistent with the helper's fixed `SOURCE_DIR`.

## 7. Configure least-privilege deployment — EC2

Upload or clone the repository on EC2 as above. Enter the project directory and run the installer as the `ubuntu` administrator:

```bash
cd /var/lib/jenkins/workspace/devops-college-project
sudo bash scripts/install-nginx.sh
```

This installs Nginx, installs a root-owned copy of `deploy-root.sh` at `/usr/local/sbin/deploy-college-site`, and adds one sudoers rule. The deployed helper accepts no arguments, reads only `/var/lib/jenkins/workspace/devops-college-project`, and copies only the three named static files. The pipeline runs the tracked `scripts/deploy.sh` wrapper without sudo; the wrapper invokes the fixed helper non-interactively. The job must be named `devops-college-project` unless both helper source path and sudoers configuration are changed by an administrator.

Inspect the rule and validate its syntax:

```bash
sudo visudo -cf /etc/sudoers.d/jenkins-deploy
sudo -l -U jenkins
```

Do not add Jenkins to the `sudo` group, do not allow `ALL` commands, and never use `chmod 777`. `scripts/setup-jenkins.sh` is an optional combined package-install script for a fresh instance; if you used it, still run `scripts/install-nginx.sh` to install the deployment helper and sudo rule.

## 8. Create the Jenkins Pipeline job

In Jenkins, choose **New Item**, enter `devops-college-project`, select **Pipeline**, and click OK. Configure:

1. **Definition:** Pipeline script from SCM.
2. **SCM:** Git.
3. **Repository URL:** `https://github.com/mridulkhanna2006pixel/devops-college-project.git`.
4. **Credentials:** none for a public repository. For a private repository, create a fine-grained token with read-only repository contents or a read-only deploy key in **Manage Jenkins → Credentials**, then select it here. Do not place credentials in the Jenkinsfile or Git URL.
5. **Branch specifier:** `*/main`.
6. **Script Path:** `Jenkinsfile`.
7. Save, then choose **Build Now** for the first run.

`pollSCM('H/2 * * * *')` is in the Jenkinsfile: Jenkins checks about every two minutes and builds only when it sees an SCM change. View **Console Output** and confirm Checkout, Validate, Deploy and Verify pass.

## 9. Test an automatic deployment

On your laptop, make a visible text change in `index.html`, then:

```bash
git add index.html
git commit -m "Update homepage for deployment test"
git push
```

Wait up to two minutes, then open the Jenkins job's **Stage View** and **Console Output**. Confirm a new successful build. Refresh `http://<EC2_PUBLIC_IP>/` (hard refresh if needed) and confirm the changed text. This verifies the path from GitHub push through Jenkins to the live Nginx page.

## 10. Optional webhook alternative

Polling is simplest and works while port 8080 is private. For webhook triggers, install/configure the GitHub integration plugin, enable **GitHub hook trigger for GITScm polling** in the job, and add a GitHub repository webhook pointing at `http://<EC2_PUBLIC_DNS>:8080/github-webhook/`. A reachable Jenkins endpoint and careful firewall/proxy configuration are required. Do not open 8080 to everyone for convenience; use a secure reverse proxy/VPN and verify GitHub's current webhook IP guidance first.

## Common problems

- **`Permission denied (publickey)`**: use the correct `.pem`, username `ubuntu`, and key mode `400`.
- **SSH timeout**: security group source must match your current public IP `/32`; confirm instance checks passed.
- **Jenkins page timeout**: allow TCP 8080 from your IP and check `sudo systemctl status jenkins`.
- **`jenkins` service fails:** inspect `sudo journalctl -u jenkins -n 80 --no-pager`; install Java 21 first.
- **Repository not found/authentication error:** check URL, branch and credentials. Public URL should not contain a token.
- **Workspace/helper source missing:** job name/workspace must match `/var/lib/jenkins/workspace/devops-college-project`; ensure Jenkins owns the workspace.
- **Sudo says not permitted:** check `sudo -l -U jenkins`, file mode 0440 and `visudo -cf`. Run the exact helper with no arguments through the wrapper.
- **Nginx shows default page:** ensure the deployment stage completed; request `/` and confirm `/var/www/html/index.html` has the expected text.
- **Port 80 unreachable:** add inbound HTTP 80 from Anywhere and run `sudo nginx -t`.
- **Changes do not appear:** wait for SCM polling, inspect build history and hard-refresh browser cache.

## Evidence to capture for your college report

1. Homepage on desktop and mobile widths.
2. EC2 instance summary showing Ubuntu and running status (hide account identifiers).
3. Security group inbound rules showing restricted 22/8080 and public 80.
4. Jenkins job configuration (repository, `*/main`, Jenkinsfile path).
5. Jenkins Stage View with all stages successful.
6. Console Output showing deployment verification.
7. Browser displaying the site at the EC2 public address.
8. A second build after a GitHub change, with updated page content.

Never include your PEM file, Jenkins initial password, access token, or account-sensitive details in screenshots or Git.
