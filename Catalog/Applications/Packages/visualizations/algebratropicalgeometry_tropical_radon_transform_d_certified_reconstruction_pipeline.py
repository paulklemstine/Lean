import numpy as np

def tropical_radon(H, f):
    return np.array([np.max(f + h) for h in H])

def tropical_adjoint(H, F):
    n = len(H[0])
    result = np.full(n, np.inf)
    for i, h in enumerate(H):
        result = np.minimum(result, F[i] - h)
    return result

def certified_reconstruction(H, F):
    """Certified tropical tomography reconstruction.
    
    Returns (signal, is_certified, discrepancy).
    is_certified=True means F is valid support data and
    reconstruction is exact.
    """
    f = tropical_adjoint(H, F)
    F_recon = tropical_radon(H, f)
    disc = F - F_recon
    return f, np.allclose(disc, 0), disc

# Example: consistent data
H = [np.array([1, 0, -1.0]), np.array([0, 2, 1.0]), np.array([-1, -1, 3.0])]
F_good = np.array([4.0, 4.0, 4.0])
f, cert, disc = certified_reconstruction(H, F_good)
print(f"Signal: {f}, Certified: {cert}, Discrepancy: {disc}")

# Example: inconsistent data
F_bad = np.array([100.0, 0.0, 0.0])
f, cert, disc = certified_reconstruction(H, F_bad)
print(f"Signal: {f}, Certified: {cert}, Discrepancy: {disc}")
