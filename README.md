## Based on
* [Robot Framework](https://robotframework.org/)
* [RESTInstance](https://github.com/asyrjasalo/RESTinstance)

## Initial setup
Assuming a Unix-like OS and Python available as `python3`, from the project root dir, setup with:
```bash
mkdir .venv results

python3 -m venv .venv/
. .venv/bin/activate

pip install --upgrade -r requirements.txt
```

## Run the tests

### Locally

```bash
cp example.settings.sh settings.sh
chmod go-rwx settings.sh
# edit settings.sh with credentials and URL...
./run.sh
```

### GitHub Action

You have to set, for the `staging` environment:

#### Variables

* `STAGING_URL`

#### Secrets

* `STAGING_USERNAME`
* `STAGING_PASSWORD`

### Results

Reports of test results and failiures (bugs) are in HTML and XML format in the `results/` directory.

#### Question
Is HTML acceptable as a format for the results and "bug report"? Is Excel a requirement?

## TODOs / Known limitations
* Formats other than JSON
* DRY test cases, create custom keywords


