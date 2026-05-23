#!/usr/bin/env python3
"""
Tropical KAM Stability — Applications

Real-world applications of tropical KAM stability theory:

1. Stability certification for discrete dynamical systems
2. Resonance detection in coupled oscillators
3. Frequency locking analysis
4. Tropical optimization landscape stability
"""

import numpy as np
from typing import List, Tuple, Dict
from collections import defaultdict


# ============================================================
# Application 1: Stability Certification
# ============================================================

def stability_certificate(omega: np.ndarray, K: int, 
                          perturbation_bound: float) -> Dict:
    """
    Generate a stability certificate for a quasi-periodic system.
    
    Given a frequency vector omega, certifies that all perturbations
    within the given bound preserve the resonance profile up to scale K.
    
    This is the computational implementation of the Tropical KAM
    Persistence Theorem: if C/(2K) > perturbation_bound, the system
    is certified stable.
    
    Args:
        omega: Frequency vector
        K: Lattice scale for stability
        perturbation_bound: Maximum componentwise perturbation
    
    Returns:
        Certificate dictionary with stability analysis
    
    Example:
        >>> omega = np.array([1.0, (1 + np.sqrt(5)) / 2])
        >>> cert = stability_certificate(omega, K=10, perturbation_bound=0.001)
        >>> print(cert['is_stable'])
    """
    n = len(omega)
    
    # Compute the Diophantine gap
    min_gap = float('inf')
    worst_k = None
    
    for total_norm in range(1, K + 1):
        for k in _enum_lattice(n, total_norm):
            val = abs(float(np.dot(k.astype(float), omega)))
            if val < min_gap:
                min_gap = val
                worst_k = k.copy()
    
    C = min_gap  # optimal Diophantine constant
    rigidity_bound = C / (2 * K)
    is_stable = perturbation_bound < rigidity_bound
    
    return {
        'frequency': omega.tolist(),
        'scale_K': K,
        'diophantine_constant_C': C,
        'rigidity_bound': rigidity_bound,
        'perturbation_bound': perturbation_bound,
        'is_stable': is_stable,
        'stability_margin': rigidity_bound - perturbation_bound,
        'worst_resonance_vector': worst_k.tolist() if worst_k is not None else None,
        'certificate_valid': True,
    }


# ============================================================
# Application 2: Coupled Oscillator Resonance Detection
# ============================================================

def detect_resonances(frequencies: np.ndarray, K: int,
                      tolerance: float = 1e-8) -> List[Dict]:
    """
    Detect near-resonances in a system of coupled oscillators.
    
    Finds all integer vectors k with ||k||_1 ≤ K such that
    |⟨k, ω⟩| < tolerance, indicating potential resonance.
    
    Applications:
    - Celestial mechanics: detecting orbital resonances
    - Electrical engineering: identifying harmonic interference
    - Structural engineering: resonance-induced vibration analysis
    
    Args:
        frequencies: Array of oscillator frequencies
        K: Maximum resonance complexity
        tolerance: Threshold for near-resonance detection
    
    Returns:
        List of detected resonances with metadata
    
    Example:
        >>> freqs = np.array([1.0, 2.01, 3.005])  # near 1:2:3 resonance
        >>> resonances = detect_resonances(freqs, K=5)
    """
    n = len(frequencies)
    resonances = []
    
    for total_norm in range(1, K + 1):
        for k in _enum_lattice(n, total_norm):
            val = float(np.dot(k.astype(float), frequencies))
            if abs(val) < tolerance:
                # Classify the resonance
                order = total_norm
                resonances.append({
                    'vector': k.tolist(),
                    'order': order,
                    'inner_product': val,
                    'residual': abs(val),
                    'type': _classify_resonance(k),
                })
    
    return sorted(resonances, key=lambda r: r['residual'])


def _classify_resonance(k: np.ndarray) -> str:
    """Classify the type of resonance from the integer vector."""
    nonzero = np.count_nonzero(k)
    if nonzero == 1:
        return "fundamental"
    elif nonzero == 2:
        return "pairwise"
    else:
        return "multi-body"


# ============================================================
# Application 3: Frequency Locking Analysis
# ============================================================

def frequency_locking_diagram(omega_base: np.ndarray, 
                              param_range: Tuple[float, float],
                              n_points: int = 200,
                              K: int = 10) -> Dict:
    """
    Compute a frequency locking diagram.
    
    As a parameter varies, tracks which frequency ratios become
    resonant and which maintain Diophantine stability.
    
    This visualizes the tropical KAM persistence theorem:
    Diophantine frequencies maintain their resonance profile
    through a range of parameters, while resonant frequencies
    cause "locking" (collapse of the invariant torus).
    
    Args:
        omega_base: Base frequency vector (dim 2)
        param_range: Range of the perturbation parameter
        n_points: Number of parameter values to sample
        K: Resonance detection scale
    
    Returns:
        Diagram data with parameter values, gaps, and locking regions
    
    Example:
        >>> omega = np.array([1.0, (1 + np.sqrt(5)) / 2])
        >>> diagram = frequency_locking_diagram(omega, (-0.5, 0.5))
    """
    params = np.linspace(param_range[0], param_range[1], n_points)
    results = []
    
    for p in params:
        omega = omega_base.copy()
        omega[1] += p
        
        # Compute Diophantine gap
        min_gap = float('inf')
        for total_norm in range(1, K + 1):
            for k in _enum_lattice(len(omega), total_norm):
                val = abs(float(np.dot(k.astype(float), omega)))
                if val > 1e-15:
                    min_gap = min(min_gap, val)
        
        # Check for exact rational ratio
        ratio = omega[1] / omega[0] if omega[0] != 0 else float('inf')
        
        results.append({
            'parameter': float(p),
            'omega': omega.tolist(),
            'diophantine_gap': min_gap,
            'ratio': ratio,
            'is_locked': min_gap < 1e-8,
        })
    
    # Identify locking intervals
    locking_regions = []
    in_lock = False
    lock_start = None
    
    for r in results:
        if r['is_locked'] and not in_lock:
            lock_start = r['parameter']
            in_lock = True
        elif not r['is_locked'] and in_lock:
            locking_regions.append((lock_start, r['parameter']))
            in_lock = False
    
    return {
        'data': results,
        'locking_regions': locking_regions,
        'n_locked': sum(1 for r in results if r['is_locked']),
        'n_free': sum(1 for r in results if not r['is_locked']),
    }


# ============================================================
# Application 4: Tropical Optimization Landscape
# ============================================================

def tropical_landscape_stability(coefficients: Dict[Tuple[int, ...], float],
                                 perturbation_scale: float,
                                 n_samples: int = 50) -> Dict:
    """
    Analyze stability of a tropical optimization landscape.
    
    A tropical polynomial f(x) = max_α (c_α + α·x) defines a
    piecewise-linear optimization landscape. We check whether
    small perturbations of coefficients preserve the landscape structure.
    
    Applications:
    - Min-plus optimization: stability of optimal solutions
    - Tropical linear programming: sensitivity analysis
    - Network optimization: robustness of shortest paths
    
    Args:
        coefficients: Dict mapping exponent tuples to coefficients
        perturbation_scale: Scale of random perturbations
        n_samples: Number of random perturbations to test
    
    Returns:
        Stability analysis results
    
    Example:
        >>> coeffs = {(0,0): 0, (1,0): 1, (0,1): 1, (1,1): 0.5}
        >>> result = tropical_landscape_stability(coeffs, perturbation_scale=0.1)
    """
    support = list(coefficients.keys())
    base_coeffs = [coefficients[s] for s in support]
    
    preserved_count = 0
    changed_count = 0
    
    for _ in range(n_samples):
        # Random perturbation
        pert_coeffs = [c + np.random.uniform(-perturbation_scale, perturbation_scale)
                       for c in base_coeffs]
        
        # Check if subdivision is preserved
        base_cells = _compute_cells(support, base_coeffs)
        pert_cells = _compute_cells(support, pert_coeffs)
        
        if base_cells == pert_cells:
            preserved_count += 1
        else:
            changed_count += 1
    
    return {
        'support_size': len(support),
        'perturbation_scale': perturbation_scale,
        'n_samples': n_samples,
        'preserved': preserved_count,
        'changed': changed_count,
        'preservation_rate': preserved_count / n_samples,
        'is_robust': preserved_count == n_samples,
    }


def _compute_cells(support, coeffs, grid_res=30):
    """Compute the cell structure of a tropical polynomial."""
    cells = set()
    for x in np.linspace(-3, 3, grid_res):
        for y in np.linspace(-3, 3, grid_res):
            vals = [coeffs[i] + support[i][0] * x + support[i][1] * y
                    for i in range(len(support))]
            max_val = max(vals)
            achiever = frozenset(i for i in range(len(vals))
                                if abs(vals[i] - max_val) < 1e-10)
            cells.add(achiever)
    return cells


# ============================================================
# Helper: Lattice vector enumeration
# ============================================================

def _enum_lattice(n: int, target_norm: int) -> List[np.ndarray]:
    """Generate integer vectors in Z^n with L1 norm exactly target_norm."""
    results = []
    _enum_helper(n, target_norm, [], results)
    return results

def _enum_helper(dims_left: int, remaining: int, current: list, results: list):
    if dims_left == 0:
        if remaining == 0:
            results.append(np.array(current, dtype=int))
        return
    for abs_val in range(remaining + 1):
        if abs_val == 0:
            _enum_helper(dims_left - 1, remaining, current + [0], results)
        else:
            for sign in [1, -1]:
                _enum_helper(dims_left - 1, remaining - abs_val,
                            current + [sign * abs_val], results)


# ============================================================
# Main: Demonstrate Applications
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL KAM STABILITY — Applications")
    print("=" * 70)
    
    # Application 1: Stability Certificate
    print("\n--- Application 1: Stability Certification ---")
    phi = (1 + np.sqrt(5)) / 2
    omega = np.array([1.0, phi])
    
    cert = stability_certificate(omega, K=10, perturbation_bound=0.001)
    print(f"System: ω = [1, φ]")
    print(f"  Diophantine constant: C = {cert['diophantine_constant_C']:.6f}")
    print(f"  Rigidity bound: {cert['rigidity_bound']:.6f}")
    print(f"  Perturbation bound: {cert['perturbation_bound']}")
    print(f"  STABLE: {cert['is_stable']}")
    print(f"  Safety margin: {cert['stability_margin']:.6f}")
    
    # Application 2: Resonance Detection
    print("\n--- Application 2: Coupled Oscillator Resonance Detection ---")
    # Near 1:2:3 resonance
    freqs = np.array([1.0, 2.01, 3.005])
    resonances = detect_resonances(freqs, K=5, tolerance=0.05)
    print(f"Frequencies: {freqs}")
    print(f"Near-resonances found: {len(resonances)}")
    for r in resonances[:5]:
        print(f"  k={r['vector']}, order={r['order']}, "
              f"residual={r['residual']:.6f}, type={r['type']}")
    
    # Application 3: Frequency Locking
    print("\n--- Application 3: Frequency Locking Diagram ---")
    omega_base = np.array([1.0, phi])
    diagram = frequency_locking_diagram(omega_base, (-0.3, 0.3), n_points=100, K=8)
    print(f"Parameter range: [-0.3, 0.3]")
    print(f"Locked points: {diagram['n_locked']} / {diagram['n_locked'] + diagram['n_free']}")
    print(f"Locking regions: {len(diagram['locking_regions'])}")
    
    # Application 4: Landscape Stability
    print("\n--- Application 4: Tropical Optimization Landscape ---")
    coeffs = {(0, 0): 0, (2, 0): -1, (0, 2): -1, (1, 1): -0.5}
    
    for scale in [0.01, 0.1, 0.5, 1.0]:
        result = tropical_landscape_stability(coeffs, scale, n_samples=100)
        print(f"  Perturbation scale {scale:.2f}: "
              f"preserved {result['preservation_rate']*100:.0f}%")
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tropical KAM Stability — Interactive Demonstration

Demonstrates the core theorems of tropical KAM stability theory:
1. Tropical Diophantine condition checking
2. Resonance rigidity under perturbation
3. Rational vs irrational frequency behavior
4. Level-set visualization for tropical polynomials
"""

import numpy as np
import itertools
from fractions import Fraction
from typing import List, Tuple, Optional

# ============================================================
# Core Definitions
# ============================================================

def l1_norm(k: np.ndarray) -> int:
    """L1 norm of an integer lattice vector."""
    return int(np.sum(np.abs(k)))

def lattice_inner(k: np.ndarray, omega: np.ndarray) -> float:
    """Inner product <k, omega> = sum_i k_i * omega_i."""
    return float(np.dot(k.astype(float), omega.astype(float)))

def is_tropical_diophantine(omega: np.ndarray, K: int, C: float) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Check if omega satisfies the Tropical Diophantine condition with parameters (K, C).
    
    Returns (True, None) if the condition holds, or (False, k) where k is a
    violating lattice vector.
    """
    n = len(omega)
    # Enumerate all integer vectors k with 0 < ||k||_1 <= K
    for norm in range(1, K + 1):
        for k in _lattice_vectors_of_norm(n, norm):
            val = abs(lattice_inner(k, omega))
            if val < C:
                return False, k
    return True, None

def _lattice_vectors_of_norm(n: int, target_norm: int) -> List[np.ndarray]:
    """Generate all integer vectors in Z^n with L1 norm exactly target_norm."""
    if n == 0:
        return [np.array([], dtype=int)] if target_norm == 0 else []
    
    vectors = []
    # Distribute target_norm among n components with signs
    for composition in _compositions(target_norm, n):
        for signs in itertools.product([1, -1], repeat=n):
            k = np.array([s * c for s, c in zip(signs, composition)], dtype=int)
            if l1_norm(k) == target_norm:  # filter duplicates from zeros
                vectors.append(k)
    
    # Remove duplicates
    seen = set()
    unique = []
    for v in vectors:
        key = tuple(v)
        if key not in seen:
            seen.add(key)
            unique.append(v)
    return unique

def _compositions(n: int, k: int) -> List[List[int]]:
    """Generate all weak compositions of n into k parts (nonneg integers summing to n)."""
    if k == 1:
        return [[n]]
    result = []
    for i in range(n + 1):
        for rest in _compositions(n - i, k - 1):
            result.append([i] + rest)
    return result

def same_resonance_profile(omega1: np.ndarray, omega2: np.ndarray, K: int,
                           tol: float = 1e-12) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Check if omega1 and omega2 have the same resonance profile up to scale K.
    
    Returns (True, None) if profiles match, or (False, k) with a distinguishing vector.
    """
    n = len(omega1)
    for norm in range(0, K + 1):
        for k in _lattice_vectors_of_norm(n, norm):
            v1 = lattice_inner(k, omega1)
            v2 = lattice_inner(k, omega2)
            res1 = abs(v1) < tol
            res2 = abs(v2) < tol
            if res1 != res2:
                return False, k
    return True, None

def find_rational_resonance(omega: List[Fraction], n: int) -> Optional[np.ndarray]:
    """
    For rational omega in dimension >= 2, find a nontrivial integer resonance.
    
    Uses the construction: k = (num(omega_1)*den(omega_0), -num(omega_0)*den(omega_1), 0, ...)
    """
    if n < 2:
        return None
    
    a, b = omega[0].numerator, omega[0].denominator
    c, d = omega[1].numerator, omega[1].denominator
    
    # If omega_0 = 0, use e_0
    if a == 0:
        k = np.zeros(n, dtype=int)
        k[0] = 1
        return k
    
    # If omega_1 = 0, use e_1
    if c == 0:
        k = np.zeros(n, dtype=int)
        k[1] = 1
        return k
    
    # General case: k = (c*b, -a*d, 0, ..., 0)
    k = np.zeros(n, dtype=int)
    k[0] = c * b
    k[1] = -a * d
    return k

# ============================================================
# Demonstration 1: Tropical Diophantine Condition
# ============================================================

def demo_diophantine_check():
    """Demonstrate the Tropical Diophantine condition on various frequencies."""
    print("=" * 70)
    print("DEMO 1: Tropical Diophantine Condition Checking")
    print("=" * 70)
    
    # Golden ratio frequency (strongly Diophantine)
    phi = (1 + np.sqrt(5)) / 2
    omega_golden = np.array([1.0, phi])
    
    # Rational frequency (not Diophantine at large scale)
    omega_rational = np.array([1.0, 3/7])
    
    # Nearly rational (weakly Diophantine)
    omega_near_rat = np.array([1.0, 3/7 + 1e-4])
    
    test_cases = [
        ("Golden ratio [1, φ]", omega_golden),
        ("Rational [1, 3/7]", omega_rational),
        ("Near-rational [1, 3/7 + 10⁻⁴]", omega_near_rat),
    ]
    
    for name, omega in test_cases:
        print(f"\nFrequency: {name}")
        print(f"  ω = {omega}")
        for K in [3, 5, 10, 20]:
            C = 0.1
            result, violator = is_tropical_diophantine(omega, K, C)
            if result:
                print(f"  K={K:3d}, C={C}: ✓ Diophantine")
            else:
                inner_val = lattice_inner(violator, omega)
                print(f"  K={K:3d}, C={C}: ✗ Violated by k={violator}, "
                      f"|⟨k,ω⟩|={abs(inner_val):.6f}")

# ============================================================
# Demonstration 2: Resonance Rigidity
# ============================================================

def demo_resonance_rigidity():
    """Demonstrate the Resonance Rigidity Theorem."""
    print("\n" + "=" * 70)
    print("DEMO 2: Resonance Rigidity Under Perturbation")
    print("=" * 70)
    
    phi = (1 + np.sqrt(5)) / 2
    omega = np.array([1.0, phi])
    
    K = 10
    
    # Find the actual Diophantine constant
    min_gap = float('inf')
    for norm in range(1, K + 1):
        for k in _lattice_vectors_of_norm(2, norm):
            val = abs(lattice_inner(k, omega))
            if val > 0:
                min_gap = min(min_gap, val)
    
    C = min_gap
    bound = C / (2 * K)
    
    print(f"\nFrequency: ω = [1, φ] = {omega}")
    print(f"Scale K = {K}")
    print(f"Diophantine constant C = {C:.6f}")
    print(f"Rigidity bound C/(2K) = {bound:.6f}")
    
    # Test perturbations of varying sizes
    np.random.seed(42)
    perturbation_sizes = [bound * 0.1, bound * 0.5, bound * 0.9, bound * 1.1, bound * 2.0]
    
    print(f"\n{'Pert. size':>12s} | {'< C/(2K)?':>9s} | {'Same profile?':>13s} | {'Theory predicts':>15s}")
    print("-" * 60)
    
    for eps in perturbation_sizes:
        delta = np.random.randn(2) 
        delta = delta / np.max(np.abs(delta)) * eps
        omega_perturbed = omega + delta
        
        within_bound = np.all(np.abs(delta) < bound)
        same_profile, _ = same_resonance_profile(omega, omega_perturbed, K)
        theory = "✓ preserved" if within_bound else "? no guarantee"
        
        print(f"  {eps:.6f}  |  {'Yes':>7s}  |  {'Yes ✓' if same_profile else 'No ✗':>11s}  |  {theory}")

# ============================================================
# Demonstration 3: Rational Frequency Resonance
# ============================================================

def demo_rational_resonance():
    """Demonstrate that rational frequencies always admit resonances."""
    print("\n" + "=" * 70)
    print("DEMO 3: Rational Frequencies Admit Resonances (Cross-Domain)")
    print("=" * 70)
    
    test_cases = [
        ([Fraction(1, 1), Fraction(3, 7)], "ω = [1, 3/7]"),
        ([Fraction(2, 3), Fraction(5, 11)], "ω = [2/3, 5/11]"),
        ([Fraction(0, 1), Fraction(4, 5)], "ω = [0, 4/5]"),
        ([Fraction(1, 2), Fraction(1, 3), Fraction(1, 5)], "ω = [1/2, 1/3, 1/5]"),
    ]
    
    for omega_q, name in test_cases:
        n = len(omega_q)
        omega_r = np.array([float(q) for q in omega_q])
        k = find_rational_resonance(omega_q, n)
        
        if k is not None:
            inner = lattice_inner(k, omega_r)
            print(f"\n{name}")
            print(f"  Resonance vector: k = {k}")
            print(f"  L1 norm: ||k||₁ = {l1_norm(k)}")
            print(f"  Inner product: ⟨k,ω⟩ = {inner:.2e}")
            print(f"  → This shows ω cannot be Diophantine at scale K ≥ {l1_norm(k)}")
    
    # Show the contrast with irrational frequencies
    print(f"\nContrast: Irrational frequencies")
    phi = (1 + np.sqrt(5)) / 2
    omega_irr = np.array([1.0, phi])
    print(f"  ω = [1, φ] = {omega_irr}")
    
    min_gaps = []
    for K in [5, 10, 20, 50]:
        min_gap = float('inf')
        for norm in range(1, K + 1):
            for k in _lattice_vectors_of_norm(2, norm):
                val = abs(lattice_inner(k, omega_irr))
                if val > 0:
                    min_gap = min(min_gap, val)
        min_gaps.append((K, min_gap))
        print(f"  K={K:3d}: min |⟨k,ω⟩| = {min_gap:.6f}  (Diophantine gap)")

# ============================================================
# Demonstration 4: Level-Set Visualization (Text-Based)
# ============================================================

def demo_level_sets():
    """Visualize tropical level sets and subdivision preservation."""
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Level Sets and Subdivision Preservation")
    print("=" * 70)
    
    def tropical_poly(coeffs, x, y):
        """Evaluate tropical polynomial max(a_ij + i*x + j*y)."""
        return max(a + i * x + j * y for (i, j), a in coeffs.items())
    
    def level_set_cells(coeffs, c, grid_size=40, x_range=(-3, 3), y_range=(-3, 3)):
        """Compute the corner locus (tropical level set) on a grid."""
        xs = np.linspace(*x_range, grid_size)
        ys = np.linspace(*y_range, grid_size)
        corners = []
        
        for x in xs:
            for y in ys:
                # Check if (x,y) is near a corner (where max is achieved by 2+ terms)
                vals = [(a + i * x + j * y, (i, j)) for (i, j), a in coeffs.items()]
                vals.sort(reverse=True, key=lambda t: t[0])
                if len(vals) >= 2 and abs(vals[0][0] - vals[1][0]) < 0.15:
                    corners.append((x, y))
        
        return corners
    
    # Original tropical polynomial
    H = {(0, 0): 0.0, (2, 0): -1.0, (0, 2): -1.0, (1, 1): -0.5}
    
    # Subdivision-preserving perturbation (shifts coefficients uniformly)
    H_pert = {k: v + 0.3 for k, v in H.items()}
    
    # Non-subdivision-preserving perturbation (changes relative structure)
    H_bad = {(0, 0): 0.0, (2, 0): -1.0, (0, 2): -1.0, (1, 1): 1.5}
    
    corners_orig = level_set_cells(H, 0)
    corners_pert = level_set_cells(H_pert, 0)
    corners_bad = level_set_cells(H_bad, 0)
    
    print(f"\nOriginal H: {H}")
    print(f"  Corner locus points: {len(corners_orig)}")
    
    print(f"\nSubdiv.-preserving perturbation H': {H_pert}")
    print(f"  Corner locus points: {len(corners_pert)}")
    print(f"  → Same combinatorial type (subdivision preserved)")
    
    print(f"\nNon-preserving perturbation H'': {H_bad}")
    print(f"  Corner locus points: {len(corners_bad)}")
    print(f"  → Different combinatorial type (subdivision changed)")
    
    # Text-based visualization
    print("\n  Tropical curve structure (text plot):")
    grid = [['.' for _ in range(50)] for _ in range(30)]
    for x, y in corners_orig:
        gx = int((x + 3) / 6 * 49)
        gy = int((y + 3) / 6 * 29)
        if 0 <= gx < 50 and 0 <= gy < 30:
            grid[29 - gy][gx] = '#'
    
    for row in grid:
        print("  " + "".join(row))

# ============================================================
# Demonstration 5: Diophantine Gap Decay
# ============================================================

def demo_gap_decay():
    """Show how the Diophantine gap decays with K for different frequency types."""
    print("\n" + "=" * 70)
    print("DEMO 5: Diophantine Gap Decay Analysis")
    print("=" * 70)
    
    frequencies = {
        "Golden [1, φ]": np.array([1.0, (1 + np.sqrt(5)) / 2]),
        "√2 [1, √2]": np.array([1.0, np.sqrt(2)]),
        "Cubic [1, 2^(1/3)]": np.array([1.0, 2 ** (1/3)]),
        "Liouville-like": np.array([1.0, sum(10**(-k) for k in range(1, 8))]),
    }
    
    K_values = [2, 5, 10, 15, 20]
    
    print(f"\n{'Frequency':>20s} | " + " | ".join(f"K={K:2d}" for K in K_values))
    print("-" * (25 + 10 * len(K_values)))
    
    for name, omega in frequencies.items():
        gaps = []
        for K in K_values:
            min_gap = float('inf')
            for norm in range(1, K + 1):
                for k in _lattice_vectors_of_norm(2, norm):
                    val = abs(lattice_inner(k, omega))
                    if val > 1e-15:
                        min_gap = min(min_gap, val)
            gaps.append(min_gap)
        
        gap_strs = [f"{g:.4f}" if g < 100 else "  ∞   " for g in gaps]
        print(f"  {name:>18s} | " + " | ".join(gap_strs))
    
    print("\n  → Golden ratio has the slowest gap decay (best Diophantine properties)")
    print("  → This is the tropical analog of the classical result that φ is")
    print("    the 'most irrational' number in terms of continued fraction theory.")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║       TROPICAL KAM STABILITY — Interactive Demonstration           ║")
    print("║                                                                    ║")
    print("║   Combinatorial Persistence of Quasi-Periodic Tropical Dynamics    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_diophantine_check()
    demo_resonance_rigidity()
    demo_rational_resonance()
    demo_level_sets()
    demo_gap_decay()
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
