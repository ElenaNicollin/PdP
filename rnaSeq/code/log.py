import subprocess
from pipeline import wildcard, is_folder_existing, inputs
import argparse

#Lance la concatenation des logs.

def log(path, ext, nameRun):
    if not is_folder_existing("/home/OutputFiles/Log/"):
        subprocess.run(['mkdir', "/home/OutputFiles/Log/"])
    if is_folder_existing("/home/Log/"):
        samples = wildcard(path, ext)[0]
        for s in samples:
            pattern = "*" + s + "*"
            find = subprocess.check_output(['find', '/home/Log/', '-type', 'f', '-name', pattern])
            if len(find) > 0:
                subprocess.run(['/home/Utils/function.sh', s, "/home/OutputFiles/Log", 'SAMPLE', nameRun],shell=False)
            else:
                subprocess.run(['/home/Utils/function.sh', s, "/home/OutputFiles/Log", 'FAMILY', nameRun],shell=False)
    else:
        print("No log to create")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run name")
    parser.add_argument("-nameRun", "-n", help='Name of the run', type=str)
    args = parser.parse_args()
    path, ext = inputs()
    log(path, ext, args.nameRun)
