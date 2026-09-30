# Python + uv + Jenkins starter

A small Python package with pytest tests and a scripted Jenkins pipeline. The pipeline checks out the repository, installs locked dependencies, runs tests, publishes JUnit results, builds a wheel and source archive, and saves those archives in Jenkins. It uses a macOS or Linux shell agent and is ready for later Docker or AWS stages.

## What's included

```text
.
├── .python-version          # Python 3.12
├── .gitignore
├── pyproject.toml           # Package metadata and pytest dependency
├── uv.lock                  # Locked dependency versions; commit this file
├── Jenkinsfile              # Scripted Pipeline
├── src/jenkins_uv_starter/
│   ├── __init__.py
│   └── app.py
├── tests/test_app.py
└── scripts/
    ├── setup.sh
    ├── test.sh
    └── build.sh
```

## 1. Prepare your Mac

Install [uv](https://docs.astral.sh/uv/getting-started/installation/) if needed. With Homebrew:

```bash
brew install uv
```

Check it and record its location:

```bash
uv --version
command -v uv
```

The `.python-version` file requests Python 3.12. uv can download it when first needed. If you prefer to prepare it ahead of time, run `uv python install 3.12`.

## 2. Run the project locally

From this directory:

```bash
bash scripts/setup.sh
bash scripts/test.sh
bash scripts/build.sh
uv run --locked hello-jenkins --name Ada
```

The expected app output is `Hello, Ada!`. Tests write `reports/pytest.xml`; the build writes a wheel and source archive to `dist/`. Those generated directories and `.venv/` are ignored by Git. No virtual environment activation or `pip install` step is needed.

## 3. Put the project in Git

Create an empty repository on your Git server, then run from this directory (replace the example URL):

```bash
git init
git add .
git commit -m "Add Python uv Jenkins starter"
git branch -M main
git remote add origin https://github.com/your-org/your-repo.git
git push -u origin main
```

Commit `uv.lock` along with the source files. Do not commit `.venv/`, `reports/`, or `dist/`.

## 4. Prepare the Jenkins Mac agent

Install uv **for the account running the Jenkins agent**, or in a location that account can execute. Homebrew commonly places it at `/opt/homebrew/bin/uv` on Apple silicon or `/usr/local/bin/uv` on Intel Macs. A standalone install may place it under that account's `~/.local/bin`. Jenkins may have a different `PATH` from your Terminal.

In **Manage Jenkins → System → Global properties → Environment variables**, set `UV_BIN` to the absolute path printed by `command -v uv` for the Jenkins agent account. If `uv` is already on the agent's `PATH`, this setting is optional. The pipeline's **Check uv** stage verifies the command Jenkins can actually run.

Make sure the agent can access the Python distribution download and package index for its first run, or preinstall Python 3.12 and warm the uv dependency cache on that agent. The project needs the Jenkins **Pipeline**, **Git**, and **JUnit** plugins (typically present in common Jenkins installations). Use a macOS agent for the Mac setup; if your Jenkins has multiple agent types, change `node {` in `Jenkinsfile` to `node('your-mac-label') {`.

## 5. Create and run the Jenkins job

1. In Jenkins, select **New Item → Pipeline** and give the job a name.
2. Under **Pipeline**, choose **Pipeline script from SCM**.
3. Choose **Git**, enter your repository URL and credentials if the repository is private, and set the branch (for example, `*/main`).
4. Leave **Script Path** as `Jenkinsfile` and save.
5. Select **Build Now**. Open **Console Output** to inspect each stage.
6. On a successful build, open **Test Result** for pytest results and **Artifacts** for the wheel and source archive.

If tests fail, `scripts/test.sh` exits with an error, so the build stage does not run. Jenkins still publishes any generated `reports/pytest.xml` from the `finally` block. There is no test failure ignore setting.

## Extend it later

Add runtime dependencies with `uv add package-name` and development tools with `uv add --dev tool-name`; commit the updated `pyproject.toml` and `uv.lock`. Add Docker image creation or AWS deployment as separate stages after **Build**, and store credentials in Jenkins Credentials rather than in the repository.

References: [uv project locking and syncing](https://docs.astral.sh/uv/concepts/projects/sync/), [uv package builds](https://docs.astral.sh/uv/guides/package/), and [Jenkins test results and artifacts](https://www.jenkins.io/doc/pipeline/tour/tests-and-artifacts/).
