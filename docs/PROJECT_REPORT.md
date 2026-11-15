# PROJECT REPORT

## Title Page

**Project title:** Automated Web Application Deployment Using Jenkins CI/CD Pipeline on AWS EC2  
**Submitted by:** [Student Name]  
**Roll number:** [Roll Number]  
**Course / Department:** [Course and Department]  
**Institution:** [College / University]  
**Guide:** [Faculty Guide]  
**Academic year:** [Academic Year]  
**Submission date:** [Date]

---

## Abstract

This project demonstrates continuous integration and continuous delivery (CI/CD) for a static website. A developer stores HTML, CSS and JavaScript in GitHub and pushes updates to the `main` branch. Jenkins on an Ubuntu 24.04 Amazon EC2 instance polls the repository, validates required files, invokes a restricted Bash deployment helper, and verifies that Nginx serves the deployed homepage. The design uses one EC2 server to keep the learning setup accessible and explainable. The report documents the architecture, implementation, tests, benefits and limitations. It is an educational demonstration and does not claim that an AWS instance has been created for the student.

## 1. Introduction

Software updates often involve repeated manual copying and can be inconsistent. CI/CD automates defined delivery steps so each source change follows a repeatable path. This project applies that idea to a small static website. Git and GitHub track the source, Jenkins runs the workflow, a Bash helper deploys files, and Nginx serves the result from a cloud virtual machine.

## 2. Problem Statement

Manual deployment requires a person to copy files to a server after every update. This takes time, can omit files, and offers limited evidence of what was deployed. A beginner-friendly automated pipeline is needed to demonstrate change detection, validation, deployment and verification using commonly understood tools.

## 3. Objectives

- Build an attractive responsive website with HTML, CSS and JavaScript.
- Track revisions in Git and host the project on GitHub.
- Provision an Ubuntu 24.04 EC2 server for Jenkins and Nginx.
- Define pipeline stages in a version-controlled Jenkinsfile.
- Deploy automatically after Jenkins detects a change on `main`.
- Restrict deployment privileges to a fixed-purpose root-owned helper.
- Verify that Nginx is active and serves the expected homepage.
- Document the implementation so it can be demonstrated and explained.

## 4. Existing System

In a basic manual process, a developer edits local files, connects to a server, copies files and manually checks the browser. It is easy to forget a step, and there may be no consistent build history or quick failure signal.

## 5. Proposed System

The proposed workflow uses GitHub as the source repository and Jenkins SCM polling at approximately two-minute intervals. On detecting a new commit, Jenkins checks out `main`, verifies `index.html`, `style.css` and `script.js`, calls a fixed deployment wrapper, then confirms Nginx is active and a local HTTP response contains expected page content. Nginx serves the files to site visitors over HTTP.

## 6. Software and Hardware Requirements

### Software

- Ubuntu Server 24.04 LTS
- Java 21 runtime
- Jenkins LTS and Pipeline/Git plugins
- Nginx, Git and Bash
- Modern browser
- Git client on a developer computer

### Hardware / Cloud

- AWS account and internet connection
- One eligible EC2 instance; a small instance such as `t3.small` is suitable for a basic demonstration where available, while additional RAM improves Jenkins responsiveness
- At least 20 GiB disk is a convenient learning allocation
- A laptop/desktop for editing, Git and browser access

Instance availability, account eligibility and pricing vary by region and time. Check AWS before launching.

## 7. Technologies Used

| Technology | Role |
|---|---|
| HTML | Structure and project content |
| CSS | Responsive design, colors, layout and motion |
| JavaScript | Mobile menu, year display and subtle reveal effects |
| Git / GitHub | Version control and remote source repository |
| Jenkins | SCM polling and pipeline orchestration |
| Bash | Validation and deployment helper |
| Ubuntu 24.04 | EC2 operating system |
| Java 21 | Jenkins runtime |
| Nginx | Serves the static website |
| AWS EC2 | Cloud virtual machine |

## 8. System Architecture

A developer commits and pushes to GitHub `main`. Jenkins on EC2 polls the repository. Its pipeline checks out the configured source, validates the expected website files and runs `scripts/deploy.sh`. That wrapper invokes the administrator-installed `/usr/local/sbin/deploy-college-site` helper through a narrow sudoers permission. The root-owned helper copies exactly three named files from the fixed Jenkins workspace to `/var/www/html` with safe ownership and readable modes. Nginx serves the site on port 80. Jenkins uses localhost HTTP and systemd checks to verify deployment. See [`ARCHITECTURE.md`](ARCHITECTURE.md).

## 9. Working Methodology

1. **Source control:** the developer stages, commits and pushes website changes.
2. **Change detection:** Jenkins runs SCM polling from the job's configured `main` branch.
3. **Checkout:** source is retrieved using the Jenkins SCM configuration.
4. **Validation:** the pipeline confirms the three required files exist.
5. **Deployment:** the fixed root-owned helper copies the files into the Nginx document root.
6. **Verification:** systemd confirms Nginx is active and `curl` checks local HTTP content.
7. **Feedback:** Jenkins records a successful or failed build with stage and console output.

## 10. Implementation Steps

1. Create a public GitHub repository and push the project to `main`.
2. Launch Ubuntu 24.04 EC2 and configure SSH/8080 for the student's IP and HTTP 80 for website visitors.
3. Connect by SSH and install updates, Git, Java 21, Nginx and Jenkins LTS.
4. Unlock Jenkins, install suggested plugins and create an administrator.
5. Create a Pipeline job named `devops-college-project`, configured as Pipeline from SCM with branch `*/main` and script path `Jenkinsfile`.
6. Install the root-owned deployment helper and restricted sudoers rule with `scripts/install-nginx.sh`.
7. Build once manually; examine each pipeline stage and open the EC2 public address.
8. Push a content change and confirm a later automatic build updates the site.

Exact commands are in [`IMPLEMENTATION_GUIDE.md`](IMPLEMENTATION_GUIDE.md).

## 11. Testing

| Test | Expected result |
|---|---|
| Open site using local Python HTTP server | Page, CSS and JavaScript load |
| Remove or rename a required file in a test branch | Validate stage fails with a useful message |
| Run pipeline with valid repository | Checkout and Validate pass |
| Run deployment | Only the three named assets are copied to `/var/www/html` |
| Check Nginx state and local HTTP | Nginx active and expected homepage content returned |
| Push a commit to `main` | Jenkins starts a build within the polling interval |
| Inspect permissions | Jenkins can invoke one fixed helper, not arbitrary sudo commands |

Record actual results and attach screenshots after running the project. This report describes the planned verification; AWS deployment is not represented as completed by this document.

## 12. Results

When implemented as described, the pipeline provides a repeatable path from a GitHub commit to a website served by Nginx. Jenkins provides build history and stage-level feedback. The project files are prepared for deployment; the actual AWS account setup and live deployment must be completed by the student and evidenced with screenshots.

## 13. Advantages

- Reduces manual copying and missed files.
- Provides repeatable deployment steps and build history.
- Makes common DevOps concepts visible in a small project.
- Uses widely understood tools and a static site with no backend.
- Limits Jenkins deployment privilege to a fixed helper.
- Offers a practical base for future improvements.

## 14. Limitations

- Jenkins and Nginx share one instance, so resource usage and failure domains are coupled.
- SCM polling is not instantaneous; a change may wait about two minutes.
- HTTP is unencrypted; HTTPS and a domain are future improvements.
- The helper uses a fixed workspace/job path, which must remain consistent.
- There is no automated rollback, multi-server rollout, monitoring stack or production hardening.
- A public repository exposes its source code, though no secrets belong in the project.

## 15. Future Scope

- Add HTTPS with a domain and managed certificate renewal.
- Add HTML, CSS and JavaScript linting.
- Add deployment backups and a documented rollback stage.
- Separate Jenkins and website hosting into separate instances or managed services.
- Add notifications and monitoring.
- Use a securely managed secret store for private repository credentials.

## 16. Conclusion

The project presents a complete beginner-scale example of CI/CD for a static website. GitHub stores source, Jenkins orchestrates stages, a narrowly privileged Bash helper deploys files, and Nginx serves and verifies the result on EC2. Its small scope makes the workflow easier to demonstrate while leaving room to discuss security, reliability and production architecture.

## 17. References

1. Jenkins, *Installing Jenkins on Linux*, https://www.jenkins.io/doc/book/installing/linux/ (accessed 14 November 2026).
2. Jenkins, *Java Support Policy*, https://www.jenkins.io/doc/book/platform-information/support-policy-java/ (accessed 14 November 2026).
3. Amazon Web Services, *Connect to your Linux instance using SSH*, https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-to-linux-instance.html (accessed 14 November 2026).
4. Amazon Web Services, *Security group rules reference*, https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html (accessed 14 November 2026).
5. Ubuntu, *Ubuntu Server documentation*, https://ubuntu.com/server/docs (accessed 14 November 2026).
