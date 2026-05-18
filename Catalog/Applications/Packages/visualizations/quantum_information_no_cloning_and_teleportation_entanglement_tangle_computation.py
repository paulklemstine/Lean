import numpy as np

def tangle(psi):
    """Compute the tangle of a two-qubit pure state."""
    M = psi.reshape(2, 2)
    rho_A = M @ M.conj().T
    return 4 * np.real(np.linalg.det(rho_A))

# Bell state
bell = np.array([1,0,0,1], dtype=complex) / np.sqrt(2)
print(f"Bell state tangle: {tangle(bell):.6f}")

# Product state
product = np.array([1,0,0,0], dtype=complex)
print(f"Product state tangle: {tangle(product):.6f}")

# Parametric family
for theta in range(0, 100, 15):
    t = np.radians(theta)
    state = np.array([np.cos(t), 0, 0, np.sin(t)], dtype=complex)
    print(f"θ={theta:3d}°: τ = {tangle(state):.6f}")
