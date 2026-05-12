# See algorithms.py for full implementation
def congruence_decode(observers, levels, k, received, n):
    candidates = set(range(n))
    for i, (obs, lvl) in enumerate(zip(observers, levels)):
        if lvl <= k and i in received:
            candidates = {p for p in candidates if obs[p] == received[i]}
    return candidates