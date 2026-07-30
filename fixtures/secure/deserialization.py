# FIXTURE — unsafe deserialization, every variant /secure must catch.
# None of this runs; it exists so the documented greps can be proven.
import pickle, yaml, torch, marshal, shelve, joblib, pandas as pd, numpy as np

def load_all(blob, path):
    a = pickle.load(blob)                     # arbitrary code execution
    b = yaml.load(blob)                       # !!python/object → RCE
    c = torch.load(path)                      # weights_only=False default
    d = marshal.loads(blob)
    e = shelve.open(path)
    f = joblib.load(path)
    g = pd.read_pickle(path)
    h = np.load(path, allow_pickle=True)
    return a, b, c, d, e, f, g, h
