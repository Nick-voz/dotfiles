import json
import subprocess


def main(args):
    try:
        out = subprocess.check_output(['kitty', '@', 'ls'])
        data = json.loads(out)
        tabs = sum(len(w['tabs']) for w in data)
        if tabs > 1:
            subprocess.check_call(['kitty', '@', 'close-tab'])
    except Exception:
        pass
