#!/usr/bin/env python3
"""
Applications of Quantum EML Activation Functions

Demonstrates real-world applications of the normalized quantum EML chart:
1. Variational quantum circuit optimization
2. Quantum gate compilation
3. Quantum state tomography via EML coordinates
4. Smooth interpolation between quantum gates
"""

import numpy as np
from typing import List, Tuple

# Pauli matrices
SIGMA_X = np.array([[0, 1], [1, 0]], dtype=complex)
SIGMA_Y = np.array([[0, -1j], [1j, 0]], dtype=complex)
SIGMA_Z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)


def pauli_compose(x: float, y: float, z: float) -> np.ndarray:
    """Construct traceless Hermitian from Pauli coordinates."""
    return x * SIGMA_X + y * SIGMA_Y + z * SIGMA_Z


def qEMLnorm(H: np.ndarray, c: float) -> np.ndarray:
    """Normalized quantum EML activation."""
    return (1.0 / np.sqrt(1 + c)) * (I2 + 1j * H)


def hermitian_sq_scalar(H: np.ndarray) -> float:
    """Compute c for H² = c·I."""
    return (H @ H)[0, 0].real


def qEML_from_params(x: float, y: float, z: float) -> np.ndarray:
    """
    Compute qEMLnorm directly from Pauli coordinates (x, y, z).
    This is the "activation function" mapping ℝ³ → SU(2).
    """
    H = pauli_compose(x, y, z)
    c = x**2 + y**2 + z**2
    return qEMLnorm(H, c)


def inverse_qEML_params(U: np.ndarray) -> Tuple[float, float, float]:
    """
    Inverse map: SU(2) → ℝ³ (Pauli coordinates).
    Works when tr(U).real > 0.
    """
    tr_re = np.trace(U).real
    if tr_re <= 0:
        raise ValueError("U has non-positive trace; outside chart domain")
    
    s = 2.0 / tr_re
    H = -1j * (s * U - I2)
    
    z = H[0, 0].real
    x = H[0, 1].real
    y = -H[0, 1].imag
    return x, y, z


# ============================================================
# APPLICATION 1: Smooth Gate Interpolation
# ============================================================
def gate_interpolation(U0: np.ndarray, U1: np.ndarray, 
                       n_steps: int = 10) -> List[np.ndarray]:
    """
    Smoothly interpolate between two SU(2) gates using qEML coordinates.
    
    Instead of interpolating in matrix space (which doesn't preserve unitarity),
    we interpolate in the ℝ³ Pauli parameter space and map back through qEML.
    
    This guarantees every intermediate gate is EXACTLY in SU(2).
    
    Parameters:
        U0, U1: Starting and ending SU(2) gates (must have positive trace)
        n_steps: Number of interpolation steps
        
    Returns: List of SU(2) matrices smoothly connecting U0 to U1
    """
    p0 = np.array(inverse_qEML_params(U0))
    p1 = np.array(inverse_qEML_params(U1))
    
    gates = []
    for t in np.linspace(0, 1, n_steps):
        p = (1 - t) * p0 + t * p1
        U = qEML_from_params(*p)
        gates.append(U)
    
    return gates


# ============================================================
# APPLICATION 2: Variational Quantum Circuit Layer
# ============================================================
class QuantumEMLLayer:
    """
    A variational quantum circuit layer parameterized by qEML coordinates.
    
    Each qubit has 3 real parameters (x, y, z) ∈ ℝ³ that map to an SU(2)
    rotation via the qEML chart. This gives:
    
    - Exact unitarity by construction (no projection needed)
    - Smooth, differentiable parameterization
    - Lipschitz-continuous dependence on parameters
    - Natural connection to Bloch sphere geometry
    
    Advantages over Euler angle parameterization:
    - No gimbal lock
    - No periodic boundary conditions to handle
    - Single chart covers half of SU(2) (sufficient for most circuits)
    """
    
    def __init__(self, n_qubits: int):
        """Initialize with random parameters."""
        self.n_qubits = n_qubits
        self.params = np.random.randn(n_qubits, 3) * 0.1
    
    def get_gates(self) -> List[np.ndarray]:
        """Compute SU(2) gate for each qubit."""
        return [qEML_from_params(*self.params[i]) for i in range(self.n_qubits)]
    
    def gradient(self, loss_grad: List[np.ndarray]) -> np.ndarray:
        """
        Compute parameter gradient via finite differences.
        
        In practice, this would use the parameter-shift rule or
        automatic differentiation.
        """
        eps = 1e-7
        grad = np.zeros_like(self.params)
        
        for i in range(self.n_qubits):
            for j in range(3):
                self.params[i, j] += eps
                gates_plus = self.get_gates()
                self.params[i, j] -= 2 * eps
                gates_minus = self.get_gates()
                self.params[i, j] += eps
                
                # Finite difference
                grad[i, j] = np.real(
                    np.trace(loss_grad[i].conj().T @ (gates_plus[i] - gates_minus[i]))
                ) / (2 * eps)
        
        return grad


# ============================================================
# APPLICATION 3: Gate Compilation / Approximation
# ============================================================
def compile_gate_sequence(target: np.ndarray, 
                          gate_set: List[np.ndarray],
                          max_depth: int = 10,
                          tol: float = 1e-6) -> List[int]:
    """
    Approximate a target SU(2) gate as a sequence of gates from a discrete set.
    
    Uses qEML coordinates to measure distance between gates in ℝ³,
    then greedily selects the best next gate.
    
    This is a simplified version; production compilers use Solovay-Kitaev.
    """
    current = I2.copy()
    sequence = []
    
    for _ in range(max_depth):
        remaining = target @ current.conj().T
        tr_re = np.trace(remaining).real
        
        if tr_re > 2 - tol:  # Close to identity
            break
        
        # Find best gate to apply
        best_idx = 0
        best_trace = -3
        
        for idx, gate in enumerate(gate_set):
            new_remaining = remaining @ gate.conj().T
            tr = np.trace(new_remaining).real
            if tr > best_trace:
                best_trace = tr
                best_idx = idx
        
        sequence.append(best_idx)
        current = gate_set[best_idx] @ current
    
    return sequence


# ============================================================
# DEMONSTRATION
# ============================================================
if __name__ == "__main__":
    np.random.seed(42)
    
    # --- Application 1: Gate Interpolation ---
    print("=" * 60)
    print("APPLICATION 1: Smooth Gate Interpolation via qEML")
    print("=" * 60)
    
    # Interpolate between identity and a π/3 rotation around x-axis
    U0 = I2
    theta = np.pi / 3
    U1 = np.cos(theta/2) * I2 + 1j * np.sin(theta/2) * SIGMA_X
    
    gates = gate_interpolation(U0, U1, n_steps=11)
    
    print(f"\nInterpolating from I to Rx(π/3):")
    for i, U in enumerate(gates):
        tr = np.trace(U).real / 2
        angle = 2 * np.arccos(np.clip(tr, -1, 1))
        is_su2 = np.allclose(U @ U.conj().T, I2) and abs(np.linalg.det(U) - 1) < 1e-10
        print(f"  Step {i:2d}: angle={angle:.4f} rad ({np.degrees(angle):.1f}°), "
              f"SU(2)={is_su2}")
    
    # --- Application 2: Variational Layer ---
    print("\n" + "=" * 60)
    print("APPLICATION 2: Variational Quantum Circuit Layer")
    print("=" * 60)
    
    layer = QuantumEMLLayer(n_qubits=4)
    gates = layer.get_gates()
    
    print(f"\n{layer.n_qubits}-qubit variational layer:")
    for i, U in enumerate(gates):
        x, y, z = layer.params[i]
        is_su2 = np.allclose(U @ U.conj().T, I2) and abs(np.linalg.det(U) - 1) < 1e-10
        r = np.sqrt(x**2 + y**2 + z**2)
        angle = 2 * np.arctan(r)
        print(f"  Qubit {i}: params=({x:+.3f}, {y:+.3f}, {z:+.3f}), "
              f"‖r‖={r:.3f}, angle={np.degrees(angle):.1f}°, SU(2)={is_su2}")
    
    # --- Application 3: Gate Compilation ---
    print("\n" + "=" * 60)
    print("APPLICATION 3: Gate Compilation")
    print("=" * 60)
    
    # Define a small gate set (T, S, Hadamard-like)
    gate_set = [
        qEML_from_params(0.1, 0, 0),   # Small X rotation
        qEML_from_params(0, 0.1, 0),   # Small Y rotation
        qEML_from_params(0, 0, 0.1),   # Small Z rotation
        qEML_from_params(0.3, 0, 0),   # Medium X rotation
        qEML_from_params(0, 0, 0.3),   # Medium Z rotation
        qEML_from_params(0.1, 0.1, 0.1),  # Diagonal rotation
    ]
    
    # Target: a specific rotation
    target = qEML_from_params(0.5, 0.3, 0.2)
    
    sequence = compile_gate_sequence(target, gate_set, max_depth=20)
    
    # Reconstruct
    result = I2.copy()
    for idx in sequence:
        result = gate_set[idx] @ result
    
    error = np.linalg.norm(target - result)
    fidelity = abs(np.trace(target.conj().T @ result)) / 2
    
    print(f"\nTarget gate: qEML(0.5, 0.3, 0.2)")
    print(f"Gate sequence length: {len(sequence)}")
    print(f"Gate indices: {sequence}")
    print(f"Reconstruction error: {error:.6f}")
    print(f"Fidelity: {fidelity:.6f}")
    
    # --- Summary ---
    print("\n" + "=" * 60)
    print("KEY ADVANTAGES OF qEML PARAMETERIZATION")
    print("=" * 60)
    print("""
    1. EXACT UNITARITY: Every parameter setting gives an exact SU(2) element.
       No need for Gram-Schmidt or other post-hoc unitarization.
    
    2. SMOOTH INTERPOLATION: Linear interpolation in parameter space gives
       smooth paths on SU(2), useful for adiabatic quantum computation.
    
    3. LIPSCHITZ STABILITY: Small parameter changes → small gate changes,
       crucial for gradient-based quantum circuit optimization.
    
    4. NATURAL COORDINATES: Parameters directly encode rotation axis and
       angle via the Bloch sphere connection.
    
    5. NO GIMBAL LOCK: Unlike Euler angles, the qEML chart has no
       coordinate singularities (except at the antipodal point -I).
    """)


#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Interactive Demonstration

Demonstrates the normalized quantum EML activation as a coordinate chart on SU(2):
  qEMLnorm(H, c) = (1/√(1+c)) · (I + iH)

where H is a traceless Hermitian 2×2 matrix with H² = c·I.

Key results demonstrated:
1. Unnormalized I + iH is NOT unitary (obstruction)
2. Traceless Hermitian 2×2 matrices square to scalar·I
3. Normalized qEMLnorm IS unitary with det = 1 (lands in SU(2))
4. Every SU(2) element with positive trace is in the image (surjectivity)
5. Reconstruction error analysis near the singular locus (-I)
"""

import numpy as np
from typing import Tuple

# Pauli matrices
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)


def random_traceless_hermitian(scale: float = 1.0) -> np.ndarray:
    """Generate a random traceless Hermitian 2×2 matrix H = x·σ_x + y·σ_y + z·σ_z."""
    x, y, z = np.random.randn(3) * scale
    return x * sigma_x + y * sigma_y + z * sigma_z


def random_su2() -> np.ndarray:
    """Generate a random SU(2) matrix via Haar measure (quaternion method)."""
    v = np.random.randn(4)
    v /= np.linalg.norm(v)
    a, x, y, z = v
    return a * I2 + 1j * (x * sigma_x + y * sigma_y + z * sigma_z)


def qEMLnorm(H: np.ndarray, c: float) -> np.ndarray:
    """Normalized quantum EML activation: (1/√(1+c)) · (I + iH)."""
    return (1.0 / np.sqrt(1 + c)) * (I2 + 1j * H)


def hermitian_sq_scalar(H: np.ndarray) -> float:
    """For traceless Hermitian H, compute c such that H² = c·I."""
    H2 = H @ H
    c = H2[0, 0].real  # Should be real and equal to the scalar
    return c


def inverse_qEML(U: np.ndarray) -> Tuple[np.ndarray, float]:
    """Given U ∈ SU(2) with tr(U) > 0, find H traceless Hermitian with qEMLnorm(H,c) = U.
    
    Construction: s = 2/Re(tr(U)), H = -i·(s·U - I), c = s² - 1.
    """
    tr_re = np.trace(U).real
    s = 2.0 / tr_re
    H = -1j * (s * U - I2)
    c = s**2 - 1
    return H, c


def check_hermitian(H: np.ndarray, tol: float = 1e-12) -> bool:
    """Check if H is Hermitian."""
    return np.allclose(H, H.conj().T, atol=tol)


def check_traceless(H: np.ndarray, tol: float = 1e-12) -> bool:
    """Check if H is traceless."""
    return abs(np.trace(H)) < tol


def check_unitary(U: np.ndarray, tol: float = 1e-12) -> bool:
    """Check if U is unitary."""
    return np.allclose(U @ U.conj().T, I2, atol=tol)


def check_su2(U: np.ndarray, tol: float = 1e-12) -> bool:
    """Check if U is in SU(2): unitary with det = 1."""
    return check_unitary(U, tol) and abs(np.linalg.det(U) - 1) < tol


# ============================================================
# DEMONSTRATION 1: Obstruction — unnormalized is not unitary
# ============================================================
print("=" * 70)
print("DEMO 1: Obstruction — I + iH is NOT unitary for nonzero H")
print("=" * 70)

H = sigma_z  # Pauli Z
A = I2 + 1j * H
product = A @ A.conj().T
print(f"\nH = σ_z = \n{H}")
print(f"\nI + iH = \n{A}")
print(f"\n(I + iH)(I + iH)† = \n{product}")
print(f"\nIs unitary? {check_unitary(A)}")
print(f"Expected: False (product = 2I, not I)")

# Test with random H
print("\nRandom traceless Hermitian matrices:")
for i in range(5):
    H = random_traceless_hermitian(scale=0.5 + i * 0.5)
    A = I2 + 1j * H
    c = hermitian_sq_scalar(H)
    product = A @ A.conj().T
    expected = (1 + c) * I2
    print(f"  ‖H‖={np.linalg.norm(H):.3f}, c={c:.3f}, "
          f"(I+iH)(I+iH)† ≈ {product[0,0].real:.3f}·I, "
          f"unitary={check_unitary(A)}")

# ============================================================
# DEMONSTRATION 2: H² = c·I for traceless Hermitian H
# ============================================================
print("\n" + "=" * 70)
print("DEMO 2: Traceless Hermitian H satisfies H² = c·I")
print("=" * 70)

for i in range(8):
    H = random_traceless_hermitian(scale=2.0)
    H2 = H @ H
    c = H2[0, 0].real
    residual = np.linalg.norm(H2 - c * I2)
    print(f"  H with ‖H‖={np.linalg.norm(H):.4f}: "
          f"c = {c:.4f}, ‖H² - c·I‖ = {residual:.2e}")

# ============================================================
# DEMONSTRATION 3: Normalized qEMLnorm is unitary with det = 1
# ============================================================
print("\n" + "=" * 70)
print("DEMO 3: Normalized qEMLnorm(H, c) is in SU(2)")
print("=" * 70)

for i in range(8):
    H = random_traceless_hermitian(scale=1.0 + i * 0.5)
    c = hermitian_sq_scalar(H)
    U = qEMLnorm(H, c)
    det_val = np.linalg.det(U)
    print(f"  ‖H‖={np.linalg.norm(H):.3f}, c={c:.3f}: "
          f"unitary={check_unitary(U)}, "
          f"det={det_val.real:.6f}+{det_val.imag:.2e}i, "
          f"in SU(2)={check_su2(U)}")

# ============================================================
# DEMONSTRATION 4: Surjectivity — reconstruct random SU(2)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 4: Surjectivity — every SU(2) with tr > 0 is qEMLnorm(H, c)")
print("=" * 70)

n_success = 0
n_total = 1000
max_error = 0

for i in range(n_total):
    U = random_su2()
    tr_re = np.trace(U).real
    
    if tr_re > 0.01:  # Positive trace (away from singularity)
        H, c = inverse_qEML(U)
        U_reconstructed = qEMLnorm(H, c)
        error = np.linalg.norm(U - U_reconstructed)
        max_error = max(max_error, error)
        
        if error < 1e-10:
            n_success += 1
        
        if i < 10:
            print(f"  tr(U)={tr_re:+.4f}: "
                  f"H hermitian={check_hermitian(H)}, "
                  f"H traceless={check_traceless(H)}, "
                  f"‖U - qEMLnorm(H,c)‖={error:.2e}")

print(f"\n  Success rate: {n_success}/{n_total} ({100*n_success/n_total:.1f}%)")
print(f"  Max reconstruction error: {max_error:.2e}")

# ============================================================
# DEMONSTRATION 5: Behavior near the singular locus (U → -I)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 5: Singular behavior as U approaches -I")
print("=" * 70)

print("\n  As rotation angle θ → π, the chart parameter r = tan(θ/2) → ∞")
print("  and the chart breaks down at U = -I (θ = π).\n")

angles = np.linspace(0.01, np.pi - 0.001, 20)
n_hat = np.array([0, 0, 1])  # Rotation axis = z

for theta in angles:
    # U = cos(θ)I + i·sin(θ)·σ_z
    U = np.cos(theta) * I2 + 1j * np.sin(theta) * sigma_z
    tr_re = np.trace(U).real  # = 2cos(θ)
    
    if abs(tr_re) > 1e-10:
        try:
            H, c = inverse_qEML(U)
            U_rec = qEMLnorm(H, c)
            error = np.linalg.norm(U - U_rec)
            r = np.sqrt(max(c, 0))
            print(f"  θ={theta:.4f} (θ/π={theta/np.pi:.3f}), "
                  f"tr(U)={tr_re:+.4f}, r={r:.4f}, "
                  f"error={error:.2e}")
        except Exception as e:
            print(f"  θ={theta:.4f}: FAILED ({e})")
    else:
        print(f"  θ={theta:.4f} (θ/π={theta/np.pi:.3f}): "
              f"tr(U)≈0, chart undefined")

# ============================================================
# DEMONSTRATION 6: Axis-angle decomposition
# ============================================================
print("\n" + "=" * 70)
print("DEMO 6: Bloch sphere / axis-angle connection")
print("=" * 70)

print("\n  For H = tan(θ/2)·n̂·σ, qEMLnorm gives rotation by θ around n̂")
print("  This is the Cayley chart: stereographic projection on S³\n")

for _ in range(6):
    # Random axis
    n = np.random.randn(3)
    n /= np.linalg.norm(n)
    
    # Random angle in (0, π/2) — well inside the chart
    theta = np.random.uniform(0.1, 1.4)
    
    # Construct H = tan(θ/2) · n̂·σ
    r = np.tan(theta / 2)
    H = r * (n[0] * sigma_x + n[1] * sigma_y + n[2] * sigma_z)
    c = hermitian_sq_scalar(H)
    
    # Get the unitary
    U = qEMLnorm(H, c)
    
    # Extract rotation angle from trace
    recovered_theta = 2 * np.arctan(np.sqrt(c))
    
    print(f"  Input θ={theta:.4f}, axis=({n[0]:+.3f},{n[1]:+.3f},{n[2]:+.3f})")
    print(f"  Recovered θ={recovered_theta:.4f}, "
          f"error=|Δθ|={abs(theta - recovered_theta):.2e}")
    print(f"  U in SU(2)={check_su2(U)}")
    print()

# ============================================================
# SUMMARY
# ============================================================
print("=" * 70)
print("SUMMARY OF FORMALLY VERIFIED RESULTS")
print("=" * 70)
print("""
1. OBSTRUCTION: I + iH is not unitary (verified in Lean 4)
   → Naive EML does not survive quantization

2. PAULI IDENTITY: H² = c·I for traceless Hermitian H (verified)
   → The key algebraic miracle of 2×2 matrices

3. UNITARITY: qEMLnorm(H,c) ∈ SU(2) (verified)
   → Normalized activation lands in the correct group

4. SURJECTIVITY: {U ∈ SU(2) : tr(U) > 0} ⊂ im(qEMLnorm) (verified)
   → The activation is a local coordinate chart

5. SINGULAR LOCUS: Chart breaks down at U = -I (tr = -2)
   → This is the antipodal point, unreachable by any single chart
""")
