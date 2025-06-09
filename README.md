Assuming a Unix-like OS and Python available as `python3`, from the project root dir, setup with:
```bash
mkdir .venv results

python3 -m venv .venv/
. .venv/bin/activate

pip install --upgrade -r requirements.txt
```

Run the tests:
```bash
robot --output-dir results tests
```
