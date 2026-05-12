import numpy as np

def diamond_eval(A, v):
    """Tropical diamond: (diamond v)(x) = min_y (A[x,y] + v[y])"""
    n = A.shape[0]
    return np.array([min(A[x,y] + v[y] for y in range(n)) for x in range(n)])

def compute_spectrum(A, valuations, depth, state):
    """Compute tropical transfer profile up to given depth."""
    spectrum = {}
    for name, v in valuations.items():
        current = v.copy()
        for k in range(depth + 1):
            spectrum[(name, k)] = current[state]
            if k < depth:
                current = diamond_eval(A, current)
    return spectrum

def compute_quotient(A, valuations, depth):
    """Compute spectral equivalence classes."""
    n = A.shape[0]
    spectra = {}
    for s in range(n):
        spec = compute_spectrum(A, valuations, depth, s)
        key = tuple(sorted(spec.items()))
        spectra.setdefault(key, []).append(s)
    return list(spectra.values())

# Example
A = np.array([[0,1,5,5],[5,0,1,5],[5,5,0,1],[0,5,5,1]], dtype=float)
vals = {'p': np.array([2.,3.,4.,2.]), 'q': np.array([1.,5.,2.,1.])}
for d in range(4):
    classes = compute_quotient(A, vals, d)
    print(f'Depth {d}: {classes}')
