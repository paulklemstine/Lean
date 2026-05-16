import numpy as np

def gauss_map(x):
    if x <= 0: return 0.0
    return 1.0/x - int(1.0/x)

def estimate_correlations(f, g, N=50000, max_lag=20, burn_in=200):
    """Estimate correlation decay. O(N * max_lag) time."""
    rng = np.random.default_rng(42)
    samples = rng.uniform(0.001, 0.999, N)
    for _ in range(burn_in):
        samples = np.array([gauss_map(x) for x in samples])
    
    f_vals = np.array([f(x) for x in samples])
    mean_f, mean_g = np.mean(f_vals), np.mean([g(x) for x in samples])
    
    corrs = []
    current = samples.copy()
    for lag in range(max_lag + 1):
        if lag > 0:
            current = np.array([gauss_map(x) for x in current])
        g_shifted = np.array([g(x) for x in current])
        corrs.append(abs(np.mean(f_vals * g_shifted) - mean_f * mean_g))
    return corrs

# Example: indicator observables
f = lambda x: 1.0 if x > 0 and int(1/x) == 1 else 0.0
g = lambda x: 1.0 if x > 0 and int(1/x) == 2 else 0.0
corrs = estimate_correlations(f, g)
print('Correlations:', [f'{c:.2e}' for c in corrs[:10]])