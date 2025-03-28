# retainer_engine.py
import time
import os

LOG = "engine.log"

def log(msg):
    with open(LOG, "a") as f:
        f.write(f"[ENGINE] {time.ctime()} - {msg}\n")

def verify_phi_scalar(path="./olivia_scope/tgdkdef_iris.vec"):
    with open(path, "r") as f:
        for line in f:
            if "phi_scalar=" in line:
                value = line.strip().split("=")[1].split(";")[0]
                log(f"Phi Scalar Detected: {value}")
                return float(value)
    return 0.0

def attach_captor():
    if os.path.exists("./captor/retainer_values.hex"):
        log("Captor retainer_values.hex found.")
        return True
    log("Captor not attached.")
    return False

def run_engine():
    log("Launching OliviaAI Retainer Engine")
    
    if not attach_captor():
        log("Aborting: Captor not valid")
        return

    phi = verify_phi_scalar()
    if not (0.00001446 <= phi <= 0.00001469):
        log("Aborting: Phi Scalar invalid")
        return

    log("Phi and Captor valid. AI handshake starting...")
    log(">>> Retainer bonded. OliviaAI memory scope activated.")

if __name__ == "__main__":
    run_engine()