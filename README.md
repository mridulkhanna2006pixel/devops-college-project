# Automated Web Application Deployment Using Jenkins CI/CD Pipeline on AWS EC2

A beginner-friendly college project that deploys a responsive static website to Nginx on Ubuntu 24.04 EC2 whenever Jenkins detects a change on GitHub's `main` branch. The setup uses Git, Jenkins Pipeline, Bash and Nginx. It does not use containers, Kubernetes, Terraform, paid APIs or a backend.

## Features

- Responsive project website with mobile navigation, sections and reduced-motion support.
- Jenkins pipeline with Checkout, Validate, Deploy and Verify stages, plus a success/failure message.
- SCM polling every two minutes.
- Root-owned, fixed-purpose deployment helper and a single-command sudoers rule for Jenkins.
- Detailed setup, architecture, college report and viva notes in `docs/`.

## Technology

HTML, CSS, JavaScript, Git/GitHub, Jenkins LTS, Bash, Ubuntu Server 24.04 LTS, Java 21, Nginx and AWS EC2.

## Folder structure

```text
devops-college-project/
├── index.html
├── style.css
├── script.js
├── Jenkinsfile
├── scripts/
│   ├── deploy.sh
│   ├── deploy-root.sh
│   ├── install-nginx.sh
│   └── setup-jenkins.sh
├── docs/
│   ├── PROJECT_REPORT.md
│   ├── VIVA_QUESTIONS.md
│   ├── IMPLEMENTATION_GUIDE.md
│   └── ARCHITECTURE.md
├── .gitignore
└── README.md
```

## Run locally

From this folder, run `python3 -m http.server 8000` and open <http://localhost:8000>. Stop the server with Ctrl+C. The site uses system fonts and needs no external assets or backend.

## GitHub and Jenkins deployment

Follow [`docs/IMPLEMENTATION_GUIDE.md`](docs/IMPLEMENTATION_GUIDE.md) in order. It has exact commands and labels which commands run on your laptop versus EC2. Key setup notes:

1. Create a public GitHub repository and push this folder to its `main` branch.
2. Launch Ubuntu 24.04 EC2. Restrict SSH and Jenkins 8080 inbound access to your current public IP; allow HTTP 80 publicly.
3. Install Java 21, Jenkins LTS and Nginx. Clone the project to `/var/lib/jenkins/workspace/devops-college-project` using a Pipeline job named `devops-college-project`.
4. Run `scripts/install-nginx.sh` as an administrator. It installs a root-owned helper and grants Jenkins permission to execute only that path. Do not change the job name without updating the helper's `SOURCE_DIR` and sudo rule.
5. Configure Pipeline from SCM, branch `*/main`, script path `Jenkinsfile`; first run and confirm success in Console Output.

Private repository users should add a GitHub read-only token or deploy key in Jenkins Credentials and select it in the SCM configuration. Never commit a token or PEM file.

## Architecture

Developer pushes to GitHub → Jenkins polls `main` → Jenkins checks out and validates the files → Jenkins runs the fixed deployment wrapper → the restricted root-owned helper copies only the three website files to `/var/www/html` → Nginx serves them → Jenkins checks the response on `127.0.0.1`.

## Screenshots

Add your own screenshots after completing the deployment:

- `[Homepage on desktop](screenshots/homepage-desktop.png)`
- `[Homepage on mobile](screenshots/homepage-mobile.png)`
- `[Jenkins pipeline success](screenshots/jenkins-success.png)`
- `[EC2 security group rules](screenshots/security-group.png)`
- `[Website open at the EC2 public address](screenshots/live-website.png)`

## Troubleshooting

- **Jenkins will not start:** `sudo journalctl -u jenkins -n 80 --no-pager`; check `java -version` (Java 21).
- **Pipeline has no changes:** confirm `*/main`, commit was pushed to `main`, and wait up to two minutes; check SCM polling log.
- **Permission denied in deploy:** confirm job path/name, helper ownership, and `sudo -l -U jenkins`; validate with `sudo visudo -cf /etc/sudoers.d/jenkins-deploy`.
- **HTTP fails:** confirm EC2 security group allows TCP 80, then use `sudo nginx -t` and `systemctl status nginx`.
- **SSH/Jenkins times out:** verify source IP rules and update them when your ISP changes your public IP.
- **Website styles are stale:** hard-refresh the browser (Ctrl+Shift+R / Cmd+Shift+R) and confirm the build deployed the latest commit.

## Future improvements

Use HTTPS with a domain and certificate, add HTML linting and richer alerts, use a separate build agent, and add a rollback strategy. For a production service, separate Jenkins from the public web server and evaluate stronger network isolation.

## License

For educational use. Add the license required by your college or repository owner.
