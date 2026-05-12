def canonical_sampling_set(d, r):
    import numpy as np
    n = d.shape[0]
    remaining = set(range(n))
    S = []
    while remaining:
        v = min(remaining)
        S.append(v)
        to_remove = {w for w in remaining if d[v, w] <= r}
        remaining -= to_remove
    return S

def reconstruct(d, r, S, samples):
    import numpy as np
    n = d.shape[0]
    f = np.zeros(n)
    for v in range(n):
        for idx, s in enumerate(S):
            if d[v, s] <= r:
                f[v] = samples[idx]
                break
    return f

# Example
import numpy as np
n, nc = 20, 5
rng = np.random.RandomState(42)
assignments = rng.randint(0, nc, size=n)
d = np.array([[0.0 if i==j else (1.0 if assignments[i]==assignments[j] else 2.0) for j in range(n)] for i in range(n)])
S = canonical_sampling_set(d, 1.5)
print(f"Sampling set: {S} ({len(S)} points from {n} vertices)")
f_orig = np.array([float(assignments[i]) for i in range(n)])  # locally constant
f_recon = reconstruct(d, 1.5, S, f_orig[S])
print(f"Perfect reconstruction: {np.allclose(f_orig, f_recon)}")
