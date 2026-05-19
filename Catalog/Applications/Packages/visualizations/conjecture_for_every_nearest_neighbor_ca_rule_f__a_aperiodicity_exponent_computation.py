# See algorithms.py for full implementation
def compute_exponent(tf: dict) -> int:
    states = list(tf.keys())
    prev = {s: s for s in states}
    for k in range(1, len(states) + 2):
        curr = {s: tf[prev[s]] for s in prev}
        if curr == prev:
            return k - 1
        prev = curr
    raise RuntimeError('Failed to converge')