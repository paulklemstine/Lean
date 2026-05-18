import numpy as np

def can_clone(psi, phi, tol=1e-10):
    """Check if two quantum states can be simultaneously cloned."""
    z = np.vdot(psi, phi)
    return abs(z) < tol or abs(z - 1) < tol

# Examples
psi = np.array([1, 0], dtype=complex)
phi_orth = np.array([0, 1], dtype=complex)
phi_nonorth = np.array([1, 1], dtype=complex) / np.sqrt(2)

print(f"Orthogonal states: can clone = {can_clone(psi, phi_orth)}")
print(f"Non-orthogonal states: can clone = {can_clone(psi, phi_nonorth)}")
