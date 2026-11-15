# Beginner-Friendly Viva Questions and Answers

1. **What is this project about?**  It automatically deploys a static website from GitHub to an Nginx web server using a Jenkins pipeline on AWS EC2.
2. **What does CI/CD mean?**  Continuous Integration and Continuous Delivery/Deployment are practices for regularly integrating code and automating its checks and release.
3. **What is Jenkins?**  Jenkins is an automation server that can run jobs and pipelines when source changes or other triggers occur.
4. **What is a pipeline?**  A pipeline is an ordered set of steps for building, checking or delivering software.
5. **What is a Jenkinsfile?**  It is a text file in the repository that defines a Jenkins Pipeline as code.
6. **What is Git?**  Git is a distributed version-control system that records project changes.
7. **What is GitHub?**  GitHub hosts Git repositories online and helps developers share source code.
8. **What does `git commit` do?**  It records staged changes as a version in the local repository.
9. **What does `git push` do?**  It sends local commits to a configured remote repository such as GitHub.
10. **What is a branch?**  A branch is a named line of development. This project uses `main`.
11. **How does Jenkins notice a change?**  It polls the configured source repository about every two minutes and starts a build when it finds a change.
12. **What is SCM polling?**  It is Jenkins periodically checking a source code management system for new commits.
13. **What is an alternative to polling?**  A GitHub webhook can notify a reachable Jenkins endpoint when a push happens.
14. **What is AWS EC2?**  EC2 provides virtual servers called instances in the AWS cloud.
15. **Why Ubuntu 24.04?**  It is the selected server operating system and has package management and service tools used by this project.
16. **Why does Jenkins need Java?**  Jenkins is a Java application and needs a supported Java runtime; this setup uses Java 21.
17. **What is Nginx?**  Nginx is a web server that serves the project's static HTML, CSS and JavaScript files.
18. **What is `/var/www/html`?**  It is the default Nginx website directory on Ubuntu package installations.
19. **What does the Validate stage do?**  It fails early if one of the three required site files is missing.
20. **What does the Verify stage do?**  It checks that Nginx is active and that the homepage responds over local HTTP with expected content.
21. **Why use Bash?**  Bash is available on Linux and can automate the simple file checks and copy operations needed for deployment.
22. **Why not give Jenkins unrestricted sudo?**  Jenkins runs jobs from source code, so broad root access would create unnecessary risk. The setup permits one fixed helper only.
23. **Why is the helper root-owned?**  A Jenkins-controlled workspace file must not be executed as root. An administrator installs a separate root-owned copy with fixed paths and no arguments.
24. **What is a sudoers file?**  It is an administrator-controlled configuration that specifies which commands users may run through `sudo`.
25. **Why use `visudo`?**  It validates sudoers syntax and helps prevent mistakes that could break sudo access.
26. **What does permission mode `0644` mean?**  The owner may read/write; the group and others may read. It is suitable for public static website files.
27. **Why should SSH port 22 be restricted?**  SSH is administrative access; limiting it to the student's IP reduces exposure to unwanted connection attempts.
28. **Why expose port 80 publicly?**  Port 80 carries HTTP traffic so visitors can open the website.
29. **Why restrict Jenkins port 8080?**  The Jenkins interface controls automation and should be reachable only by the administrator or through private access.
30. **What is a security group?**  It is an AWS virtual firewall that controls inbound and outbound traffic for associated instances.
31. **What happens if `index.html` is missing?**  The Validate stage exits with an error, and Jenkins marks that build as failed.
32. **What does `set -euo pipefail` do in Bash?**  It makes scripts stop on command errors, unset variables and failed commands inside pipelines.
33. **How can you check Jenkins logs?**  On EC2, use `sudo journalctl -u jenkins -n 80 --no-pager`.
34. **How do you check Nginx configuration?**  Run `sudo nginx -t` on EC2.
35. **How do you test the automatic deployment?**  Change a page string, commit and push to `main`, wait up to two minutes, then check the Jenkins build and refreshed website.
36. **What is a static website?**  A site delivered as files such as HTML, CSS and JavaScript without server-side application logic or a database.
37. **Does the project use Docker or Kubernetes?**  No. It uses a single Ubuntu EC2 instance, as required for a beginner-scale project.
38. **What is one limitation?**  Jenkins and Nginx share one instance, so a server outage affects both automation and the site.
39. **How could the project be improved?**  Add HTTPS, linting, deployment rollback, monitoring and separate production services.
40. **Has the AWS deployment already happened?**  The project files and instructions are prepared; a student must launch and configure an AWS instance to create and document a real deployment.
