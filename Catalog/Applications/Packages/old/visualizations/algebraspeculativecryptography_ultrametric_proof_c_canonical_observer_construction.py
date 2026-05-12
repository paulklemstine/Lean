# See algorithms.py for full implementation
def canonical_observers(d, n):
    observers = [d[i][:] for i in range(n)]
    levels = [0] * n
    return observers, levels