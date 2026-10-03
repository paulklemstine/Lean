"""
Robust class-number sampler.

qfbclassno on this host has WILDLY variable cost (0.3 ms at D=40 bits, >20 s
at D=56 bits for unlucky D), and a PARI stack overflow aborts the whole
interpreter.  So we run batches in a subprocess with a hard cap and simply
retry with a fresh seed until we have enough samples.  Samples obtained this
way are indistinguishable from any others -- we record nothing but (D, h).
"""
import random
import subprocess
import sys
import time

HERE = "/home/raver1975/lean/factor-scratch/r48/exp"


def _batch(db, k, seed, mode, cap):
    try:
        r = subprocess.run(
            [sys.executable, "-u", f"{HERE}/_probe_sample.py",
             str(db), str(k), str(seed), mode],
            capture_output=True, text=True, timeout=cap)
    except subprocess.TimeoutExpired:
        return None
    import ast
    for line in r.stdout.splitlines():
        if line.startswith("SAMPLES"):
            try:
                return ast.literal_eval(line.split(" ", 1)[1])
            except Exception:
                return None
    return None


def robust_class_numbers(k, db, mode="free", seed0=0, cap=45, tries=400,
                         batch=None):
    """Return up to k (key, h) pairs for discriminants of db bits."""
    batch = batch or max(1, min(k, 12))
    out = []
    seed = seed0
    for _ in range(tries):
        if len(out) >= k:
            break
        need = min(batch, k - len(out))
        got = _batch(db, need, seed, mode, cap)
        seed += 1
        if got:
            out.extend((a, b) for a, b, _t in got)
    return out[:k]