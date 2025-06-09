## Initial setup
Assuming a Unix-like OS and Python available as `python3`, from the project root dir, setup with:
```bash
mkdir .venv results

python3 -m venv .venv/
. .venv/bin/activate

pip install --upgrade -r requirements.txt
```

## Run the tests
```bash
robot --output-dir results tests
```

Reports of test results and failiures (bugs) are in HTML and XML format in the `results` directory.

### Question
Is HTML acceptable as a format for the results and "bug report"? Is Excel a requirement?

