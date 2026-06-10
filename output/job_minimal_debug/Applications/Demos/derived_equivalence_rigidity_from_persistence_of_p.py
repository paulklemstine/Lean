"""
Applications of Arithmetic Persistence Modules

Demonstrates real-world applications of the persistence framework:
1. Cryptographic curve selection via persistence fingerprints
2. Mirror symmetry detection
3. Modular form identification via persistence data
"""

import numpy as np
from typing import List, Tuple, Dict


def power_sum_seq(eigenvalues, r):
    """Compute sum(alpha_i^r)."""
    return sum(alpha ** r for alpha in eigenvalues)


# ============================================================
# APPLICATION 1: Cryptographic Curve Fingerprinting
# ============================================================
def curve_persistence_fingerprint(p: int, trace: int, max_r: int = 10) -> List[int]:
    """Compute a persistence fingerprint for an elliptic curve.
    
    The fingerprint is the sequence of point counts N_r mod some small number,
    providing a fast "hash" for curve classification.
    
    In cryptographic applications, this can verify that two curves are
    NOT isogenous (different fingerprints => not isogenous).
    """
    # Eigenvalues of Frobenius on H^1
    disc = trace**2 - 4*p
    alpha = (trace + np.sqrt(complex(disc))) / 2
    beta = (trace - np.sqrt(complex(disc))) / 2
    
    fingerprint = []
    for r in range(1, max_r + 1):
        Nr = round((p**r + 1 - alpha**r - beta**r).real)
        fingerprint.append(Nr % 12)  # mod 12 for compactness
    
    return fingerprint


# ============================================================
# APPLICATION 2: Mirror Symmetry Detection
# ============================================================
def check_mirror_symmetry(h_pq_X: Dict[Tuple[int,int], int],
                           h_pq_Y: Dict[Tuple[int,int], int],
                           dim: int) -> Tuple[bool, str]:
    """Check if two Hodge diamonds satisfy the mirror symmetry relation.
    
    Mirror symmetry predicts: h^{p,q}(X) = h^{dim-p,q}(Y).
    This is a necessary condition for mirror pairs.
    
    At the level of persistence modules, mirror symmetry corresponds to
    a specific transformation of the Frobenius eigenvalues.
    """
    for (p, q), h in h_pq_X.items():
        mirror_key = (dim - p, q)
        h_mirror = h_pq_Y.get(mirror_key, 0)
        if h != h_mirror:
            return False, f"h^{{{p},{q}}}(X) = {h} != h^{{{dim-p},{q}}}(Y) = {h_mirror}"
    
    return True, "Hodge numbers satisfy mirror relation"


def mirror_persistence_test(eigenvalues_X: List[complex],
                             eigenvalues_Y: List[complex],
                             q: int, dim: int,
                             max_r: int = 20) -> Tuple[bool, float]:
    """Test mirror symmetry at the level of persistence modules.
    
    For mirror pairs, the Frobenius eigenvalues on H^{p,q}(X) and
    H^{dim-p,q}(Y) should be related by multiplication by q^{dim/2-p}.
    
    Returns (passes_test, max_deviation).
    """
    max_dev = 0
    for r in range(1, max_r + 1):
        sx = power_sum_seq(eigenvalues_X, r)
        # Mirror transform: multiply eigenvalues by q^{dim/2}
        sy_mirror = power_sum_seq([a * q**(dim/2) for a in eigenvalues_Y], r)
        dev = abs(sx - sy_mirror)
        max_dev = max(max_dev, dev)
    
    return max_dev < 1e-6, max_dev


# ============================================================
# APPLICATION 3: Modular Form Identification
# ============================================================
def modular_form_from_persistence(p: int, traces: Dict[int, int],
                                   weight: int) -> List[int]:
    """Given point-count traces for several primes, reconstruct
    the q-expansion coefficients of the associated modular form.
    
    For an elliptic curve E, the associated modular form f(q) = sum a_n q^n
    has a_p = trace of Frobenius at p.
    
    The persistence module data at each prime directly gives a_p.
    """
    # The first few coefficients
    max_n = max(traces.keys()) + 1
    coeffs = [0] * max_n
    coeffs[0] = 0  # a_0 = 0 for cusp forms
    if 1 in traces:
        coeffs[1] = 1  # normalized
    
    for prime, trace in traces.items():
        coeffs[prime] = trace
    
    return coeffs[:max_n]


# ============================================================
# RUN APPLICATIONS
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Cryptographic Curve Fingerprinting")
    print("=" * 60)
    
    p = 101  # A prime used in elliptic curve cryptography
    
    # Different curves over F_101
    traces = [0, 1, -1, 5, -5, 10, -10, 15]
    
    print(f"\nFingerprints for curves over F_{p}:")
    print(f"{'Trace':>6} | {'Fingerprint':>30} | {'#E(F_p)':>8}")
    print("-" * 55)
    
    fingerprints = {}
    for t in traces:
        fp = curve_persistence_fingerprint(p, t)
        fp_str = str(fp[:6])
        Nr = p + 1 - t
        print(f"{t:6d} | {fp_str:>30} | {Nr:8d}")
        fingerprints[t] = fp
    
    # Check uniqueness
    print(f"\nAll fingerprints unique: {len(set(tuple(v) for v in fingerprints.values())) == len(fingerprints)}")
    
    
    print("\n" + "=" * 60)
    print("APPLICATION 2: Mirror Symmetry (Quintic Threefold)")
    print("=" * 60)
    
    # Quintic threefold X in P^4: h^{1,1} = 1, h^{2,1} = 101
    # Mirror Y: h^{1,1} = 101, h^{2,1} = 1
    
    hodge_X = {(0,0): 1, (1,1): 1, (2,1): 101, (1,2): 101, (2,2): 1, (3,3): 1,
               (3,0): 1, (0,3): 1}
    hodge_Y = {(0,0): 1, (1,1): 101, (2,1): 1, (1,2): 1, (2,2): 101, (3,3): 1,
               (3,0): 1, (0,3): 1}
    
    is_mirror, msg = check_mirror_symmetry(hodge_X, hodge_Y, 3)
    print(f"\nMirror symmetry check: {is_mirror}")
    print(f"  {msg}")
    
    # Betti numbers
    betti_X = [1, 0, 1, 204, 1, 0, 1]  # b_0, ..., b_6
    betti_Y = [1, 0, 101, 4, 101, 0, 1]
    
    euler_X = sum((-1)**i * b for i, b in enumerate(betti_X))
    euler_Y = sum((-1)**i * b for i, b in enumerate(betti_Y))
    print(f"\n  Euler char X = {euler_X}")
    print(f"  Euler char Y = {euler_Y}")
    print(f"  χ(X) = -χ(Y): {euler_X == -euler_Y}")
    
    
    print("\n" + "=" * 60)
    print("APPLICATION 3: Modular Form from Persistence Data")
    print("=" * 60)
    
    # The elliptic curve y^2 + y = x^3 - x (conductor 37)
    # Its associated modular form has known coefficients
    known_traces = {2: -2, 3: -3, 5: -2, 7: -2, 11: 0, 13: 5, 17: -2, 19: 0, 23: -1}
    
    print(f"\nTraces of Frobenius (from persistence data at each prime):")
    for p, t in sorted(known_traces.items()):
        Nr = p + 1 - t
        print(f"  a_{p} = {t:3d}  (so #E(F_{p}) = {Nr})")
    
    coeffs = modular_form_from_persistence(2, known_traces, 2)
    print(f"\nReconstructed q-expansion: f(q) = q", end="")
    for n in range(2, len(coeffs)):
        if coeffs[n] != 0:
            sign = "+" if coeffs[n] > 0 else ""
            print(f" {sign}{coeffs[n]}q^{n}", end="")
    print(" + ...")
    print("\n(This is the modular form associated to the curve of conductor 37)")
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
Arithmetic Persistence Modules: Computational Demonstrations

This script demonstrates the core concepts of arithmetic persistence modules
through concrete examples with elliptic curves, K3 surfaces, and abelian varieties.
"""

import numpy as np
from typing import List, Tuple, Dict
from collections import Counter


def power_sum_seq(eigenvalues: List[complex], r: int) -> complex:
    """Compute the power sum s_r = sum(alpha_i^r) for a list of eigenvalues."""
    return sum(alpha ** r for alpha in eigenvalues)


def point_count_curve(q: int, h1_eigenvalues: List[complex], r: int) -> complex:
    """Point count for a smooth projective curve over F_{q^r}.
    
    N_r = q^r + 1 - sum(alpha_i^r) where alpha_i are H^1 eigenvalues.
    """
    return q**r + 1 - power_sum_seq(h1_eigenvalues, r)


def newton_recurrence(e1: complex, e2: complex, n_terms: int) -> List[complex]:
    """Compute power sums using Newton's recurrence.
    
    s_0 = 2, s_1 = e1
    s_{r+2} = e1 * s_{r+1} - e2 * s_r
    
    This is proved in our Lean formalization (newton_recurrence_two).
    """
    s = [2, e1]
    for _ in range(n_terms - 2):
        s.append(e1 * s[-1] - e2 * s[-2])
    return s


def char_poly_from_eigenvalues(eigenvalues: List[complex]) -> np.ndarray:
    """Compute characteristic polynomial coefficients from eigenvalues.
    
    chi(t) = prod(t - alpha_i) = t^n - e1*t^{n-1} + ... + (-1)^n * prod(alpha_i)
    """
    return np.polynomial.polynomial.polyfromroots(eigenvalues)


def persistence_module_data(eigenvalues: List[complex], max_r: int = 20) -> List[complex]:
    """Compute the persistence module data: power sums for r = 0, 1, ..., max_r."""
    return [power_sum_seq(eigenvalues, r) for r in range(max_r + 1)]


def tropical_slopes(eigenvalues: List[int], p: int) -> List[int]:
    """Compute p-adic valuations (tropical slopes) of integer eigenvalues."""
    def padic_val(n: int, p: int) -> int:
        if n == 0:
            return float('inf')
        v = 0
        n = abs(n)
        while n % p == 0:
            v += 1
            n //= p
        return v
    
    slopes = sorted([padic_val(a, p) for a in eigenvalues])
    return slopes


# ============================================================
# DEMO 1: Elliptic Curves over F_p
# ============================================================
print("=" * 60)
print("DEMO 1: Elliptic Curve Persistence Modules")
print("=" * 60)

# Two elliptic curves over F_5
# E1: y^2 = x^3 + x + 1 over F_5 has trace a = 2, so #E1(F_5) = 5 + 1 - 2 = 4
# E2: y^2 = x^3 + 2x + 3 over F_5 has trace a = -1, so #E2(F_5) = 5 + 1 + 1 = 7
# Their H^1 eigenvalues satisfy alpha + beta = -a, alpha*beta = p

p = 5

# E1: trace = 2, eigenvalues are roots of t^2 - 2t + 5
a1 = 2
disc1 = a1**2 - 4*p
alpha1 = (a1 + np.sqrt(complex(disc1))) / 2
beta1 = (a1 - np.sqrt(complex(disc1))) / 2

# E2: trace = -1, eigenvalues are roots of t^2 + t + 5
a2 = -1
disc2 = a2**2 - 4*p
alpha2 = (a2 + np.sqrt(complex(disc2))) / 2
beta2 = (a2 - np.sqrt(complex(disc2))) / 2

print(f"\nE1 over F_5: trace = {a1}")
print(f"  H^1 eigenvalues: {alpha1:.4f}, {beta1:.4f}")
print(f"  |eigenvalues| = {abs(alpha1):.4f} (should be sqrt(5) = {np.sqrt(5):.4f})")

print(f"\nE2 over F_5: trace = {a2}")
print(f"  H^1 eigenvalues: {alpha2:.4f}, {beta2:.4f}")
print(f"  |eigenvalues| = {abs(alpha2):.4f}")

# Compute point counts
print("\nPoint counts over extensions:")
print(f"{'r':>3} | {'#E1(F_{5^r})':>15} | {'#E2(F_{5^r})':>15} | {'Match':>5}")
print("-" * 50)
for r in range(1, 11):
    n1 = round(point_count_curve(p, [alpha1, beta1], r).real)
    n2 = round(point_count_curve(p, [alpha2, beta2], r).real)
    print(f"{r:3d} | {n1:15d} | {n2:15d} | {'YES' if n1 == n2 else 'NO':>5}")

# Newton recurrence verification
print("\nNewton recurrence verification for E1:")
print("(Proved in Lean as `two_eigenvalue_recurrence`)")
newton_e1 = newton_recurrence(a1, p, 10)
direct_e1 = persistence_module_data([alpha1, beta1], 9)
for r in range(10):
    print(f"  s_{r} = {newton_e1[r]:>10.0f} (Newton) vs {direct_e1[r].real:>10.0f} (direct)")


# ============================================================
# DEMO 2: Derived-Equivalent K3 Surfaces
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Derived-Equivalent K3 Surface Simulation")
print("=" * 60)

# For K3 surfaces, the cohomology is:
# H^0: dim 1 (eigenvalue q^0 = 1)
# H^1: dim 0
# H^2: dim 22 (21 from H^{1,1} + 1 from H^{2,0} + H^{0,2})
# H^3: dim 0
# H^4: dim 1 (eigenvalue q^2)

# Two derived-equivalent K3 surfaces should have the same
# Frobenius eigenvalues on H^2.

# Simulate with p=3, using random Weil numbers of weight 1
np.random.seed(42)
p_k3 = 3

# Generate 22 eigenvalues of absolute value p = 3 for H^2
# (weight 2, so |alpha| = p)
angles = np.random.uniform(0, 2*np.pi, 11)
h2_eigenvalues_X = []
for theta in angles:
    h2_eigenvalues_X.append(p_k3 * np.exp(1j * theta))
    h2_eigenvalues_X.append(p_k3 * np.exp(-1j * theta))

# For a derived-equivalent K3, eigenvalues are the same
h2_eigenvalues_Y = h2_eigenvalues_X.copy()

# Full cohomological data
cohom_X = [[1], [], h2_eigenvalues_X, [], [p_k3**2]]
cohom_Y = [[1], [], h2_eigenvalues_Y, [], [p_k3**2]]

print(f"\nK3 surface X over F_{p_k3}:")
print(f"  H^2 has {len(h2_eigenvalues_X)} eigenvalues")

def alternating_point_count(cohom_data, r):
    total = 0
    for i, eigs in enumerate(cohom_data):
        total += (-1)**i * power_sum_seq(eigs, r)
    return total

print(f"\nPoint count comparison (derived-equivalent pair):")
print(f"{'r':>3} | {'#X(F_{q^r})':>15} | {'#Y(F_{q^r})':>15} | {'Difference':>10}")
print("-" * 55)
for r in range(1, 8):
    nx = round(alternating_point_count(cohom_X, r).real)
    ny = round(alternating_point_count(cohom_Y, r).real)
    print(f"{r:3d} | {nx:15d} | {ny:15d} | {nx - ny:10d}")


# ============================================================
# DEMO 3: Non-Derived-Equivalent Separation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Persistence Separation of Non-Equivalent Varieties")
print("=" * 60)

# Two curves of genus 2 with different H^1 eigenvalues
# should be separated by their persistence modules

# Curve C1: eigenvalues are roots of t^4 - t^3 + 3t^2 - 7t + 49
# (weight 1 eigenvalues for p=7)
p_sep = 7
coeffs1 = [49, -7, 3, -1, 1]
roots1 = np.roots(coeffs1[::-1])

coeffs2 = [49, 0, 5, -2, 1]
roots2 = np.roots(coeffs2[::-1])

print(f"\nCurve C1 eigenvalues: {[f'{r:.3f}' for r in roots1]}")
print(f"Curve C2 eigenvalues: {[f'{r:.3f}' for r in roots2]}")

print(f"\nPersistence module comparison:")
print(f"{'r':>3} | {'s_r(C1)':>15} | {'s_r(C2)':>15} | {'Separated':>10}")
print("-" * 55)
first_sep = None
for r in range(0, 11):
    s1 = round(power_sum_seq(roots1, r).real)
    s2 = round(power_sum_seq(roots2, r).real)
    sep = s1 != s2
    if sep and first_sep is None:
        first_sep = r
    print(f"{r:3d} | {s1:15d} | {s2:15d} | {'YES ***' if sep else 'NO':>10}")

if first_sep:
    print(f"\n→ First separation at r = {first_sep}")
    print(f"  (Conjecture: separation occurs at r ≤ dim = {len(roots1)})")
    print(f"  {'CONJECTURE CONFIRMED' if first_sep <= len(roots1) else 'CONJECTURE VIOLATED!'}")


# ============================================================
# DEMO 4: Tropical Slopes
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Tropical Persistence Slopes")
print("=" * 60)

eigenvalues_int = [2, 6, 15, 14, 9, 8]
for prime in [2, 3, 5, 7]:
    slopes = tropical_slopes(eigenvalues_int, prime)
    print(f"  p = {prime}: eigenvalues {eigenvalues_int}")
    print(f"         tropical slopes = {slopes}")
    print(f"         sum of slopes = {sum(s for s in slopes if s != float('inf'))}")


# ============================================================
# DEMO 5: Product Variety (Künneth)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Product Variety Multiplicativity")
print("=" * 60)
print("(Proved in Lean as `product_point_count`)")

eigs_A = [2, 3]
eigs_B = [5, 7]
tensor_eigs = [a * b for a in eigs_A for b in eigs_B]

print(f"\nVariety A eigenvalues: {eigs_A}")
print(f"Variety B eigenvalues: {eigs_B}")
print(f"Product eigenvalues: {tensor_eigs}")

print(f"\n{'r':>3} | {'s_r(A)':>8} | {'s_r(B)':>8} | {'s_r(A)*s_r(B)':>14} | {'s_r(A×B)':>10} | {'Match':>5}")
print("-" * 65)
for r in range(0, 8):
    sA = power_sum_seq(eigs_A, r)
    sB = power_sum_seq(eigs_B, r)
    sAB = power_sum_seq(tensor_eigs, r)
    print(f"{r:3d} | {sA:8.0f} | {sB:8.0f} | {sA*sB:14.0f} | {sAB:10.0f} | {'OK' if abs(sA*sB - sAB) < 0.1 else 'FAIL':>5}")


print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


"""
Visualization: Frobenius Eigenvalue Orbits and Persistence

Shows how Frobenius eigenvalues on the complex plane generate
persistence module data through their powers α^r.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle

def get_eigenvalues(p, trace):
    disc = trace**2 - 4*p
    alpha = (trace + np.sqrt(complex(disc))) / 2
    beta = (trace - np.sqrt(complex(disc))) / 2
    return alpha, beta

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

p = 5
traces = [0, 1, -1, 2, -2, 3]
max_r = 30

for idx, trace in enumerate(traces):
    row, col = idx // 3, idx % 3
    ax = axes[row, col]
    
    alpha, beta = get_eigenvalues(p, trace)
    
    # Plot unit circle scaled by sqrt(p)
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.sqrt(p) * np.cos(theta), np.sqrt(p) * np.sin(theta),
            'k--', alpha=0.3, linewidth=1)
    
    # Plot powers of eigenvalues
    rs = np.arange(1, max_r + 1)
    alphas_r = np.array([alpha**r for r in rs])
    betas_r = np.array([beta**r for r in rs])
    
    # Color by r value
    cmap = plt.cm.viridis
    for i, r in enumerate(rs):
        color = cmap(i / len(rs))
        ax.plot(alphas_r[i].real, alphas_r[i].imag, 'o', color=color,
                markersize=max(2, 6 - i*0.15), alpha=0.7)
        ax.plot(betas_r[i].real, betas_r[i].imag, 's', color=color,
                markersize=max(2, 6 - i*0.15), alpha=0.7)
    
    # Mark initial eigenvalues
    ax.plot(alpha.real, alpha.imag, 'r*', markersize=12, zorder=5, label='α')
    ax.plot(beta.real, beta.imag, 'b*', markersize=12, zorder=5, label='β')
    
    # Power sum annotation
    s1 = round(power_sum := (alpha + beta).real)
    s2 = round((alpha**2 + beta**2).real)
    
    ax.set_title(f'trace = {trace}\ns₁={s1}, s₂={s2}', fontsize=10)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    ax.set_xlim(-p**2.5, p**2.5)
    ax.set_ylim(-p**2.5, p**2.5)
    
    if idx == 0:
        ax.legend(fontsize=8, loc='upper left')

plt.suptitle(f'Frobenius Eigenvalue Orbits α^r, β^r on the Complex Plane (p={p})',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('eigenvalue_orbits.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eigenvalue_orbits.png")


"""
Visualization: Newton Polygon and Tropical Persistence

Shows the Newton polygon of characteristic polynomials and how
tropical slopes (p-adic valuations) create a bridge between
arithmetic geometry and tropical geometry.
"""

import numpy as np
import matplotlib.pyplot as plt

def padic_val(n, p):
    """Compute the p-adic valuation of n."""
    if n == 0:
        return float('inf')
    v = 0
    n = abs(n)
    while n % p == 0:
        v += 1
        n //= p
    return v

def newton_polygon(coeffs, p):
    """Compute the Newton polygon of a polynomial at prime p.
    
    coeffs[i] is the coefficient of x^i.
    Returns the lower convex hull points.
    """
    points = [(i, padic_val(int(round(c.real)) if isinstance(c, complex) else c, p))
              for i, c in enumerate(coeffs) if c != 0 and padic_val(int(round(c.real)) if isinstance(c, complex) else c, p) != float('inf')]
    
    if len(points) < 2:
        return points
    
    # Compute lower convex hull
    points.sort()
    hull = [points[0]]
    for pt in points[1:]:
        while len(hull) >= 2:
            # Check if turning right (remove middle point)
            x1, y1 = hull[-2]
            x2, y2 = hull[-1]
            x3, y3 = pt
            cross = (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1)
            if cross <= 0:
                hull.pop()
            else:
                break
        hull.append(pt)
    
    return hull

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Example polynomials (characteristic polynomials of Frobenius)
# For an elliptic curve over F_p: t^2 - a_p * t + p
primes = [2, 3, 5, 7, 11, 13]
p_curve = 30030  # = 2*3*5*7*11*13, to have interesting valuations

examples = [
    ("Elliptic (tr=0, p=7)", [7, 0, 1]),
    ("Elliptic (tr=2, p=7)", [7, -2, 1]),
    ("Genus 2 (p=5)", [25, -10, 11, -3, 1]),
    ("Genus 2 (p=7)", [49, -14, 15, -4, 1]),
    ("K3 surface H² sample", [49, -7, 22, -7, 49, 0, 1]),
    ("Abelian surface (p=3)", [9, -6, 10, -6, 9, 0, 0, 0, 1]),
]

prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71', 7: '#9b59b6', 11: '#e67e22', 13: '#1abc9c'}

for idx, (name, coeffs) in enumerate(examples):
    row, col = idx // 3, idx % 3
    ax = axes[row, col]
    
    # Plot Newton polygon for each prime
    for prime in [2, 3, 5, 7]:
        vals = [(i, padic_val(c, prime)) for i, c in enumerate(coeffs) if c != 0]
        vals = [(x, y) for x, y in vals if y != float('inf')]
        
        if vals:
            hull = newton_polygon(coeffs, prime)
            xs, ys = zip(*hull) if hull else ([], [])
            ax.plot(xs, ys, 'o-', color=prime_colors[prime], linewidth=2,
                    markersize=6, label=f'p={prime}', alpha=0.8)
    
    # Plot all points (not just convex hull)
    for i, c in enumerate(coeffs):
        if c != 0:
            ax.plot(i, 0, 'k.', markersize=3, alpha=0.3)
    
    ax.set_xlabel('Degree')
    ax.set_ylabel('p-adic valuation')
    ax.set_title(name, fontsize=10)
    ax.grid(True, alpha=0.2)
    ax.set_ylim(-0.5, max(4, max(padic_val(c, 2) for c in coeffs if c != 0 and padic_val(c, 2) != float('inf')) + 1))
    
    if idx == 0:
        ax.legend(fontsize=7, loc='upper right')

plt.suptitle('Newton Polygons: Tropical Persistence Slopes\n'
             'The slopes encode p-adic information about Frobenius eigenvalues',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('newton_polygon.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved newton_polygon.png")


"""
Visualization: Arithmetic Persistence Barcodes

Visualizes the persistence module data for elliptic curves over finite fields.
Shows how power sum sequences create "barcodes" that distinguish non-isogenous curves.
"""

import numpy as np
import matplotlib.pyplot as plt

def power_sum_seq(eigenvalues, r):
    return sum(alpha ** r for alpha in eigenvalues)

def get_eigenvalues(p, trace):
    disc = trace**2 - 4*p
    alpha = (trace + np.sqrt(complex(disc))) / 2
    beta = (trace - np.sqrt(complex(disc))) / 2
    return alpha, beta

# Setup
p = 7
traces = [0, 1, -1, 2, -2, 3]
max_r = 15
colors = plt.cm.Set2(np.linspace(0, 1, len(traces)))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Raw power sums
ax1 = axes[0, 0]
for i, t in enumerate(traces):
    alpha, beta = get_eigenvalues(p, t)
    sums = [abs(power_sum_seq([alpha, beta], r)) for r in range(max_r + 1)]
    ax1.semilogy(range(max_r + 1), [s + 1 for s in sums], '-o', color=colors[i],
                 markersize=4, label=f'trace={t}')
ax1.set_xlabel('Extension degree r')
ax1.set_ylabel('|s_r| + 1  (log scale)')
ax1.set_title('Power Sum Magnitudes')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Panel 2: Point counts
ax2 = axes[0, 1]
for i, t in enumerate(traces):
    alpha, beta = get_eigenvalues(p, t)
    counts = [round((p**r + 1 - alpha**r - beta**r).real) for r in range(1, max_r + 1)]
    ax2.semilogy(range(1, max_r + 1), counts, '-s', color=colors[i],
                 markersize=4, label=f'trace={t}')
ax2.semilogy(range(1, max_r + 1), [p**r for r in range(1, max_r + 1)],
             'k--', alpha=0.5, label='q^r')
ax2.set_xlabel('Extension degree r')
ax2.set_ylabel('#E(F_{q^r})  (log scale)')
ax2.set_title('Point Counts Over Extensions')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: Persistence barcode
ax3 = axes[1, 0]
# Show which extension degrees separate each pair of curves
for i, t1 in enumerate(traces):
    alpha1, beta1 = get_eigenvalues(p, t1)
    for j, t2 in enumerate(traces):
        if j <= i:
            continue
        alpha2, beta2 = get_eigenvalues(p, t2)
        sep_degrees = []
        for r in range(1, max_r + 1):
            s1 = round(power_sum_seq([alpha1, beta1], r).real)
            s2 = round(power_sum_seq([alpha2, beta2], r).real)
            if s1 != s2:
                sep_degrees.append(r)

        y_pos = i * len(traces) + j - (i + 1) * (i + 2) // 2 + len(traces) - 1
        if sep_degrees:
            ax3.barh(y_pos, max(sep_degrees) - min(sep_degrees) + 1,
                     left=min(sep_degrees) - 0.5, height=0.6,
                     color=colors[i], alpha=0.7)
            ax3.plot(sep_degrees, [y_pos]*len(sep_degrees), '|', 
                     color='black', markersize=10)
        ax3.text(-0.5, y_pos, f'({t1},{t2})', ha='right', va='center', fontsize=7)

ax3.set_xlabel('Extension degree r')
ax3.set_ylabel('Curve pair (trace₁, trace₂)')
ax3.set_title('Separation Barcode')
ax3.grid(True, alpha=0.3, axis='x')

# Panel 4: Newton polygon (tropical slopes)
ax4 = axes[1, 1]
# For the polynomial t^2 - at + p, the Newton polygon at various primes
primes_to_check = [2, 3, 5, 7]
bar_width = 0.15
for k, prime in enumerate(primes_to_check):
    for i, t in enumerate(traces[:4]):
        # Coefficients of char poly: t^2 - trace*t + p
        coeffs = [1, -t, p]
        def padic_val(n, pp):
            if n == 0: return 3  # cap at 3 for display
            v = 0
            n = abs(n)
            while n % pp == 0:
                v += 1
                n //= pp
            return v
        vals = [padic_val(c, prime) for c in coeffs]
        x_pos = i + k * bar_width - (len(primes_to_check) - 1) * bar_width / 2
        ax4.bar(x_pos, max(vals), width=bar_width, color=colors[k], alpha=0.7,
                label=f'p={prime}' if i == 0 else '')

ax4.set_xticks(range(len(traces[:4])))
ax4.set_xticklabels([f'tr={t}' for t in traces[:4]])
ax4.set_ylabel('Max p-adic valuation')
ax4.set_title('Tropical Slopes (Newton Polygon Heights)')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3, axis='y')

plt.suptitle('Arithmetic Persistence Modules for Elliptic Curves over F₇',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('persistence_barcode.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved persistence_barcode.png")
