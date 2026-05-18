import math

def hamiltonian_vf(dHdx: float, dHdy: float) -> tuple:
    """Hamiltonian vector field from gradient."""
    return (dHdy, -dHdx)

def check_orthogonality(dHdx: float, dHdy: float) -> float:
    """Returns dot product of gradient and Ham. VF (should be 0)."""
    vf = hamiltonian_vf(dHdx, dHdy)
    return dHdx * vf[0] + dHdy * vf[1]

# Test at random gradients
import random
random.seed(42)
for _ in range(5):
    dx, dy = random.uniform(-10, 10), random.uniform(-10, 10)
    dot = check_orthogonality(dx, dy)
    print(f'grad=({dx:.3f}, {dy:.3f}), dot product={dot:.1e}')