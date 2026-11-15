# Architecture and CI/CD Workflow

## Components

- **Developer laptop:** edits the static site, commits and pushes with Git.
- **GitHub:** public repository and `main` branch hold versioned source. Public access avoids credential setup for the first demonstration.
- **AWS EC2:** one Ubuntu 24.04 LTS virtual machine runs Jenkins, Java 21 and Nginx. This is a learning topology, not a production isolation pattern.
- **Jenkins:** a Pipeline job checks out `main`, checks the three required website files, deploys and verifies the result.
- **Bash helper:** a root-owned script at `/usr/local/sbin/deploy-college-site` copies only `index.html`, `style.css`, and `script.js` from the fixed job workspace to `/var/www/html`.
- **Nginx:** serves those static files over HTTP on port 80.

## Flow

```text
Developer laptop --git push--> GitHub main
                                   ^
                         Jenkins polls every 2 min
                                   |
                                   v
              Checkout -> Validate -> Deploy -> Verify
                                              |
                        Jenkins user --sudo (one helper only)--> Nginx web root
                                                                  |
                                              Nginx serves HTTP 80 <--- Browser
```

1. A developer edits and pushes a change to `main`.
2. Jenkins' `pollSCM('H/2 * * * *')` checks for SCM changes approximately every two minutes. This is polling, not a GitHub webhook.
3. Checkout obtains the job's configured SCM source and branch.
4. Validate fails early if a required file is absent.
5. Deploy runs `bash scripts/deploy.sh` as the Jenkins user. That wrapper calls `sudo -n /usr/local/sbin/deploy-college-site`.
6. Sudo permits the `jenkins` user to run only the one root-owned helper with no arguments. The helper has fixed source and destination paths and installs exactly three files with owner `root`, group `www-data`, and mode `0644`.
7. Verify checks that Nginx is active and fetches `http://127.0.0.1/`, then checks for expected homepage text.
8. Jenkins marks the run successful or failed and records console output.

## Webhook alternative

Polling works with a public repository without opening an inbound GitHub-to-EC2 route. To use a webhook instead, configure Jenkins' GitHub integration plugin, enable the job's GitHub hook trigger, and set the repository webhook to `http://EC2_PUBLIC_DNS:8080/github-webhook/`. This requires exposing port 8080 to GitHub's changing address ranges or placing Jenkins behind a secure proxy. For a beginner single-instance project, keep the documented polling setup and restrict 8080 to your own IP.

## Network boundaries

| Port | Inbound source | Purpose |
|---|---|---|
| 22/TCP | Your current public IP `/32` | SSH administration |
| 8080/TCP | Your current public IP `/32`, or private access | Jenkins web UI |
| 80/TCP | `0.0.0.0/0` and optionally `::/0` | Public website |

Do not expose SSH or Jenkins to `0.0.0.0/0`. Use HTTPS and stronger isolation before treating this educational arrangement as a production service.
