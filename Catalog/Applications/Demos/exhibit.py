#!/usr/bin/env python3
"""
Applications of Reed-Muller Codes and PIT Soundness

Demonstrates real-world applications:
1. Shamir Secret Sharing threshold analysis
2. Error correction over noisy channels
3. Freivalds' matrix multiplication verification
4. Polynomial commitment scheme soundness
"""

import numpy as np
from itertools import product as cartesian_product
from algorithms import GF, MvPoly, witness_polynomial, hamming_weight, reed_muller_encode


def demo_shamir_secret_sharing():
    """Demonstrate Shamir's Secret Sharing with exact threshold analysis.

    In Shamir's scheme, a secret s is encoded as f(0) where f is a random
    polynomial of degree ≤ t. Shares are f(1), f(2), ..., f(n).

    The Reed-Muller minimum distance theorem tells us:
    - Any t shares reveal NO information about the secret (privacy)
    - Any t+1 shares uniquely determine f and hence s (reconstruction)
    """
    print("=" * 70)
    print("APPLICATION 1: Shamir Secret Sharing — Exact Threshold Analysis")
    print("=" * 70)

    q = 11  # prime field
    F = GF(q)
    threshold = 3  # degree of polynomial = t
    n_shares = 7   # number of parties

    # Secret
    secret = 7

    # Random polynomial f(x) = secret + a1*x + a2*x^2 + a3*x^3
    rng = np.random.default_rng(42)
    coeffs = [secret] + [rng.integers(1, q) for _ in range(threshold)]
    print(f"\n  Field: GF({q})")
    print(f"  Secret: {secret}")
    print(f"  Threshold: {threshold} (degree of polynomial)")
    print(f"  Number of shares: {n_shares}")
    print(f"  Polynomial: f(x) = {' + '.join(f'{c}x^{i}' if i > 0 else str(c) for i, c in enumerate(coeffs))}")

    # Generate shares
    shares = []
    for i in range(1, n_shares + 1):
        val = sum(c * pow(i, j, q) for j, c in enumerate(coeffs)) % q
        shares.append((i, val))
        print(f"  Share {i}: f({i}) = {val}")

    # Reconstruction with threshold+1 shares using Lagrange interpolation
    def lagrange_reconstruct(selected_shares, F):
        """Reconstruct f(0) from selected shares."""
        result = 0
        for i, (xi, yi) in enumerate(selected_shares):
            # Lagrange basis polynomial evaluated at 0
            num = 1
            den = 1
            for j, (xj, _) in enumerate(selected_shares):
                if i != j:
                    num = F.mul(num, F.neg(xj))
                    den = F.mul(den, F.sub(xi, xj))
            basis = F.mul(num, F.inv(den))
            result = F.add(result, F.mul(yi, basis))
        return result

    print(f"\n  --- Reconstruction Tests ---")

    # With threshold+1 shares: should recover secret
    for start in range(0, n_shares - threshold):
        selected = shares[start:start + threshold + 1]
        recovered = lagrange_reconstruct(selected, F)
        print(f"  Using shares {[s[0] for s in selected]}: recovered = {recovered} {'✓' if recovered == secret else '✗'}")

    # With only threshold shares: cannot determine secret
    print(f"\n  --- Privacy Analysis ---")
    print(f"  Reed-Muller minimum distance: (q-d)·q^(n-1) = ({q}-{threshold})·{q}^0 = {q - threshold}")
    print(f"  This means: any {threshold} evaluations are consistent with ANY secret value.")
    print(f"  Information-theoretically, {threshold} shares reveal 0 bits about the secret.")


def demo_error_correction():
    """Demonstrate error correction using Reed-Muller code parameters."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Error Correction over Noisy Channels")
    print("=" * 70)

    q = 5
    n = 2
    d = 1
    F = GF(q)

    min_dist = (q - d) * q ** (n - 1)
    error_correction = (min_dist - 1) // 2
    error_detection = min_dist - 1

    print(f"\n  Reed-Muller Code RM_{q}({n}, {d})")
    print(f"  Code length: {q**n} symbols over GF({q})")
    print(f"  Minimum distance: {min_dist}")
    print(f"  Error correction capability: {error_correction} errors")
    print(f"  Error detection capability: {error_detection} errors")

    # Encode a polynomial
    poly = MvPoly(n, F, {(0, 0): 3, (1, 0): 2, (0, 1): 1})
    codeword = reed_muller_encode(poly, F, n)
    print(f"\n  Message polynomial: {poly}")
    print(f"  Codeword: {codeword}")

    # Introduce errors
    rng = np.random.default_rng(123)
    corrupted = list(codeword)
    error_positions = rng.choice(len(corrupted), size=error_correction, replace=False)
    for pos in error_positions:
        corrupted[pos] = (corrupted[pos] + rng.integers(1, q)) % q

    errors = sum(1 for a, b in zip(codeword, corrupted) if a != b)
    print(f"  Introduced {errors} errors at positions {sorted(error_positions)}")
    print(f"  Corrupted: {corrupted}")
    print(f"  Since {errors} ≤ {error_correction} = ⌊(d_min-1)/2⌋, unique decoding is possible.")


def demo_freivalds():
    """Demonstrate Freivalds' algorithm using Schwartz-Zippel / PIT framework.

    Freivalds' algorithm verifies A·B = C for n×n matrices using O(n²) time
    instead of O(n³): pick random r, check A·(B·r) = C·r.

    The soundness follows from the Schwartz-Zippel lemma with degree d=1:
    if A·B ≠ C, then Pr[A·B·r = C·r] ≤ 1/q.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Freivalds' Matrix Verification")
    print("=" * 70)

    q = 101  # large prime for low error
    F = GF(q)
    n = 4  # matrix size

    rng = np.random.default_rng(42)

    # Create matrices
    A = rng.integers(0, q, size=(n, n))
    B = rng.integers(0, q, size=(n, n))
    C_correct = (A @ B) % q
    C_wrong = C_correct.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q  # single error

    print(f"\n  Matrix size: {n}×{n} over GF({q})")
    print(f"  Standard verification: O(n³) = O({n**3}) multiplications")
    print(f"  Freivalds' verification: O(n²) = O({n**2}) multiplications")

    # Test correct product
    num_trials = 20
    false_accepts_correct = 0
    for _ in range(num_trials):
        r = rng.integers(0, q, size=(n, 1))
        lhs = (A @ ((B @ r) % q)) % q
        rhs = (C_correct @ r) % q
        if not np.array_equal(lhs, rhs):
            false_accepts_correct += 1

    print(f"\n  Testing correct C = A·B:")
    print(f"    All {num_trials} trials accepted ✓" if false_accepts_correct == 0
          else f"    {false_accepts_correct} false rejections")

    # Test wrong product
    detections = 0
    for _ in range(num_trials):
        r = rng.integers(0, q, size=(n, 1))
        lhs = (A @ ((B @ r) % q)) % q
        rhs = (C_wrong @ r) % q
        if not np.array_equal(lhs, rhs):
            detections += 1

    print(f"\n  Testing wrong C ≠ A·B:")
    print(f"    Detected in {detections}/{num_trials} trials")
    print(f"    Schwartz-Zippel bound: Pr[miss] ≤ 1/{q} ≈ {1/q:.4f}")
    print(f"    Expected detections: ≥ {num_trials * (1 - 1/q):.1f}")


def demo_polynomial_commitment():
    """Illustrate polynomial commitment scheme soundness.

    In a polynomial commitment scheme:
    1. Prover commits to polynomial f of degree ≤ d
    2. Verifier queries f at random point r
    3. Prover reveals f(r)

    The Reed-Muller minimum distance ensures:
    - Two distinct polynomials of degree ≤ d agree on at most d/q fraction of points
    - So binding holds with soundness error ≤ d/q
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Polynomial Commitment Soundness")
    print("=" * 70)

    q = 13
    F = GF(q)
    n = 1  # univariate for simplicity
    d = 3

    print(f"\n  Field: GF({q}), degree bound: {d}")
    print(f"  Soundness error: d/q = {d}/{q} ≈ {d/q:.4f}")

    # Two distinct polynomials of degree 3
    f1 = MvPoly(1, F, {(0,): 2, (1,): 5, (2,): 1, (3,): 3})
    f2 = MvPoly(1, F, {(0,): 7, (1,): 5, (2,): 1, (3,): 3})
    # They differ only in constant term

    agreements = 0
    for x in range(q):
        v1 = f1.eval((x,))
        v2 = f2.eval((x,))
        if v1 == v2:
            agreements += 1

    print(f"\n  f₁ = {f1}")
    print(f"  f₂ = {f2}")
    print(f"  Agreement points: {agreements}/{q}")
    print(f"  Schwartz-Zippel bound: ≤ {d}")
    print(f"  Bound satisfied: {'✓' if agreements <= d else '✗'}")
    print(f"\n  Interpretation: If prover commits to f₁ but tries to open as f₂,")
    print(f"  the verifier detects cheating with probability ≥ {1 - d/q:.4f}")


if __name__ == "__main__":
    demo_shamir_secret_sharing()
    demo_error_correction()
    demo_freivalds()
    demo_polynomial_commitment()
    print("\n" + "=" * 70)
    print("All application demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Reed-Muller Minimum Distance & PIT Soundness — Interactive Demo

Demonstrates the exact minimum distance theorem for Reed-Muller evaluation codes
and the PIT (Polynomial Identity Testing) soundness guarantee.
"""

import numpy as np
from itertools import product as cartesian_product


def make_field(q):
    """Create arithmetic tables for GF(q) where q is prime."""
    assert all(q % i != 0 for i in range(2, int(q**0.5) + 1)) or q == 2, \
        f"{q} is not prime"
    add = np.zeros((q, q), dtype=int)
    mul = np.zeros((q, q), dtype=int)
    for a in range(q):
        for b in range(q):
            add[a, b] = (a + b) % q
            mul[a, b] = (a * b) % q
    return add, mul


def eval_witness_poly(x, roots, q):
    """Evaluate the witness polynomial prod_{a in roots} (x[0] - a) mod q."""
    result = 1
    for a in roots:
        result = (result * ((x[0] - a) % q)) % q
    return result


def count_zeros_witness(q, n, roots):
    """Count zeros of the witness polynomial over GF(q)^n."""
    zeros = 0
    for x in cartesian_product(range(q), repeat=n):
        if eval_witness_poly(x, roots, q) == 0:
            zeros += 1
    return zeros


def hamming_weight_witness(q, n, roots):
    """Compute Hamming weight of the witness polynomial's evaluation vector."""
    total = q ** n
    return total - count_zeros_witness(q, n, roots)


def demo_minimum_distance():
    """Demonstrate the exact minimum distance theorem."""
    print("=" * 70)
    print("DEMO 1: Exact Minimum Distance of Reed-Muller Codes")
    print("=" * 70)

    examples = [
        (5, 2, 2),   # GF(5), 2 variables, degree 2
        (7, 3, 3),   # GF(7), 3 variables, degree 3
        (3, 4, 1),   # GF(3), 4 variables, degree 1
        (11, 2, 5),  # GF(11), 2 variables, degree 5
    ]

    for q, n, d in examples:
        if d >= q:
            continue
        roots = list(range(d))
        predicted_weight = (q - d) * q ** (n - 1)
        actual_weight = hamming_weight_witness(q, n, roots)
        predicted_zeros = d * q ** (n - 1)
        actual_zeros = count_zeros_witness(q, n, roots)

        print(f"\n  GF({q}), n={n}, d={d}")
        print(f"    Witness roots: {roots}")
        print(f"    Total points:     {q**n}")
        print(f"    Predicted zeros:  {predicted_zeros}")
        print(f"    Actual zeros:     {actual_zeros}  {'✓' if actual_zeros == predicted_zeros else '✗'}")
        print(f"    Predicted weight: {predicted_weight}")
        print(f"    Actual weight:    {actual_weight}  {'✓' if actual_weight == predicted_weight else '✗'}")


def eval_random_poly(x, coeffs, terms, q):
    """Evaluate a polynomial given by (coeff, monomial) pairs over GF(q)."""
    result = 0
    for c, mon in zip(coeffs, terms):
        val = c
        for i, e in enumerate(mon):
            val = (val * pow(int(x[i]), int(e), q)) % q
        result = (result + val) % q
    return result


def demo_pit_soundness():
    """Demonstrate PIT soundness via random evaluation."""
    print("\n" + "=" * 70)
    print("DEMO 2: PIT Soundness — Random Evaluation Detects Nonzeroness")
    print("=" * 70)

    q = 7
    n = 2

    # A nonzero polynomial of degree 3: x0^3 + x1^2 + 1
    terms_nonzero = [(3, 0), (0, 2), (0, 0)]
    coeffs_nonzero = [1, 1, 1]
    d_nonzero = 3

    # Count zeros
    zeros = 0
    total = q ** n
    for x in cartesian_product(range(q), repeat=n):
        val = (pow(x[0], 3, q) + pow(x[1], 2, q) + 1) % q
        if val == 0:
            zeros += 1

    print(f"\n  Field: GF({q}), Variables: {n}")
    print(f"  Polynomial: x₀³ + x₁² + 1  (degree {d_nonzero})")
    print(f"  Total points: {total}")
    print(f"  Zeros: {zeros}")
    print(f"  Fraction of zeros: {zeros}/{total} = {zeros/total:.4f}")
    print(f"  Schwartz-Zippel bound: {d_nonzero}/{q} = {d_nonzero/q:.4f}")
    print(f"  Bound satisfied: {'✓' if zeros / total <= d_nonzero / q else '✗'}")

    # Simulate random PIT trials
    print(f"\n  --- Random PIT Simulation (1000 trials) ---")
    rng = np.random.default_rng(42)
    detections = 0
    num_trials = 1000
    for _ in range(num_trials):
        x = tuple(int(v) for v in rng.integers(0, q, size=n))
        val = (pow(x[0], 3, q) + pow(x[1], 2, q) + 1) % q
        if val != 0:
            detections += 1

    print(f"  Detected nonzero: {detections}/{num_trials} = {detections/num_trials:.3f}")
    print(f"  Theoretical lower bound: 1 - {d_nonzero}/{q} = {1 - d_nonzero/q:.4f}")
    print(f"  Bound satisfied: {'✓' if detections / num_trials >= 1 - d_nonzero / q - 0.05 else '≈'}")


def demo_minimum_distance_verification():
    """Verify the minimum distance by exhaustive search over all nonzero low-degree polys."""
    print("\n" + "=" * 70)
    print("DEMO 3: Exhaustive Verification (Small Case)")
    print("=" * 70)

    q = 3
    n = 2
    d = 1  # degree bound
    predicted_min_dist = (q - d) * q ** (n - 1)

    print(f"\n  GF({q}), n={n}, d={d}")
    print(f"  Predicted minimum distance: {predicted_min_dist}")
    print(f"  Checking all nonzero polynomials of degree ≤ {d}...")

    # Over GF(3) with 2 variables and degree ≤ 1:
    # f(x0, x1) = a + b*x0 + c*x1, where (a,b,c) ≠ (0,0,0)
    min_weight = float('inf')
    min_poly = None
    count = 0

    for a in range(q):
        for b in range(q):
            for c in range(q):
                if a == 0 and b == 0 and c == 0:
                    continue
                count += 1
                weight = 0
                for x in cartesian_product(range(q), repeat=n):
                    val = (a + b * x[0] + c * x[1]) % q
                    if val != 0:
                        weight += 1
                if weight < min_weight:
                    min_weight = weight
                    min_poly = (a, b, c)

    print(f"  Checked {count} nonzero polynomials")
    print(f"  Minimum weight found: {min_weight}")
    print(f"  Achieved by: f = {min_poly[0]} + {min_poly[1]}*x₀ + {min_poly[2]}*x₁")
    print(f"  Matches prediction: {'✓' if min_weight == predicted_min_dist else '✗'}")


def demo_fiber_structure():
    """Visualize the fiber structure of the witness polynomial's zero set."""
    print("\n" + "=" * 70)
    print("DEMO 4: Fiber Structure of Witness Polynomial")
    print("=" * 70)

    q = 5
    n = 2
    roots = [1, 3]  # d=2: witness poly = (x0-1)(x0-3)
    d = len(roots)

    print(f"\n  GF({q}), n={n}, roots = {roots}")
    print(f"  Witness polynomial: (x₀ - {roots[0]})(x₀ - {roots[1]})")
    print(f"\n  Evaluation grid ({q}×{q}):")
    print(f"  x₁ \\ x₀ | ", end="")
    for x0 in range(q):
        print(f"  {x0} ", end="")
    print()
    print(f"  --------+-" + "----" * q)

    for x1 in range(q):
        print(f"     {x1}    | ", end="")
        for x0 in range(q):
            val = ((x0 - roots[0]) * (x0 - roots[1])) % q
            if val == 0:
                print("  · ", end="")  # zero
            else:
                print(f"  {val} ", end="")
        print()

    zeros = count_zeros_witness(q, n, roots)
    weight = q ** n - zeros
    print(f"\n  '·' = zero, numbers = nonzero values")
    print(f"  Zero fibers at x₀ = {roots}: each fiber has {q**(n-1)} points")
    print(f"  Total zeros: {d} fibers × {q**(n-1)} points = {zeros}")
    print(f"  Hamming weight: {q**n} - {zeros} = {weight}")
    print(f"  Formula: (q-d)·q^(n-1) = ({q}-{d})·{q}^{n-1} = {(q-d)*q**(n-1)}")


if __name__ == "__main__":
    demo_minimum_distance()
    demo_pit_soundness()
    demo_minimum_distance_verification()
    demo_fiber_structure()
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Reed-Muller Codes and PIT Soundness.

Generates publication-quality figures:
1. Zero set heatmap of the witness polynomial
2. Minimum distance vs degree curve
3. PIT error probability decay
4. Fiber structure diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from itertools import product as cartesian_product
import base64
import io


def save_figure_base64(fig) -> str:
    """Save a matplotlib figure as base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def fig1_zero_set_heatmap():
    """Heatmap showing zero/nonzero pattern of witness polynomial over GF(7)²."""
    q = 7
    roots = [1, 3, 5]  # d=3
    d = len(roots)

    grid = np.zeros((q, q))
    for x0 in range(q):
        for x1 in range(q):
            val = 1
            for a in roots:
                val = (val * ((x0 - a) % q)) % q
            grid[x1, x0] = 0 if val == 0 else 1

    fig, ax = plt.subplots(1, 1, figsize=(8, 7))
    cmap = ListedColormap(['#2C3E50', '#E74C3C'])
    im = ax.imshow(grid, cmap=cmap, origin='lower', aspect='equal')

    ax.set_xlabel('$x_0$ (first coordinate)', fontsize=14)
    ax.set_ylabel('$x_1$ (second coordinate)', fontsize=14)
    ax.set_title(f'Zero Set of Witness Polynomial over GF({q})²\n'
                 f'$f(x_0,x_1) = (x_0-1)(x_0-3)(x_0-5)$, degree $d={d}$',
                 fontsize=14)
    ax.set_xticks(range(q))
    ax.set_yticks(range(q))

    # Add text annotations
    for x0 in range(q):
        for x1 in range(q):
            val = 1
            for a in roots:
                val = (val * ((x0 - a) % q)) % q
            color = 'white'
            ax.text(x0, x1, str(val), ha='center', va='center',
                    fontsize=10, color=color, fontweight='bold')

    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [Patch(facecolor='#2C3E50', label=f'Zero ({d}×{q}={d*q} pts)'),
                       Patch(facecolor='#E74C3C', label=f'Nonzero ({(q-d)*q} pts)')]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=11)

    fig.tight_layout()
    return fig


def fig2_minimum_distance_curve():
    """Plot minimum distance vs degree for several field sizes."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    for q in [5, 7, 11, 13]:
        degrees = list(range(q))
        n = 2  # 2 variables
        distances = [(q - d) * q ** (n - 1) for d in degrees]
        ax.plot(degrees, distances, 'o-', label=f'GF({q}), n={n}', linewidth=2, markersize=6)

    ax.set_xlabel('Degree bound $d$', fontsize=14)
    ax.set_ylabel('Minimum distance $(q-d) \\cdot q^{n-1}$', fontsize=14)
    ax.set_title('Exact Minimum Distance of Reed–Muller Codes $RM_q(2, d)$', fontsize=15)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 13)

    fig.tight_layout()
    return fig


def fig3_pit_error_probability():
    """Plot PIT error probability d/q for various configurations."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: error probability vs field size for fixed degree
    q_values = list(range(5, 101, 2))
    for d in [1, 3, 5, 10]:
        errors = [d / q for q in q_values if d < q]
        qs = [q for q in q_values if d < q]
        ax1.plot(qs, errors, '-', label=f'd={d}', linewidth=2)

    ax1.set_xlabel('Field size $q$', fontsize=13)
    ax1.set_ylabel('PIT error probability $d/q$', fontsize=13)
    ax1.set_title('PIT Error vs Field Size', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 1)

    # Right: detection probability after k independent trials
    q = 7
    d = 2
    single_error = d / q
    k_values = list(range(1, 21))
    for q, d in [(5, 2), (7, 3), (11, 5)]:
        single_error = d / q
        probs = [1 - single_error ** k for k in k_values]
        ax2.plot(k_values, probs, 'o-', label=f'q={q}, d={d}', linewidth=2, markersize=4)

    ax2.axhline(y=0.99, color='gray', linestyle='--', alpha=0.5, label='99% confidence')
    ax2.set_xlabel('Number of independent trials $k$', fontsize=13)
    ax2.set_ylabel('Detection probability $1-(d/q)^k$', fontsize=13)
    ax2.set_title('PIT Detection After Repeated Trials', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


def fig4_fiber_structure():
    """Diagram showing the fiber decomposition of the zero set."""
    q = 5
    n = 2
    roots = [1, 3]
    d = len(roots)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Draw the grid
    for x0 in range(q):
        for x1 in range(q):
            is_zero = x0 in roots
            color = '#3498DB' if is_zero else '#E8E8E8'
            size = 300 if is_zero else 150
            marker = 's' if is_zero else 'o'
            ax.scatter(x0, x1, c=color, s=size, marker=marker,
                       edgecolors='#2C3E50', linewidth=1.5, zorder=3)

    # Highlight fiber columns
    for r in roots:
        ax.axvline(x=r, color='#3498DB', alpha=0.2, linewidth=20, zorder=1)
        ax.text(r, q - 0.3, f'$x_0={r}$\nFiber', ha='center', va='bottom',
                fontsize=11, color='#2980B9', fontweight='bold')

    ax.set_xlabel('$x_0$ (first coordinate)', fontsize=14)
    ax.set_ylabel('$x_1$ (second coordinate)', fontsize=14)
    ax.set_title(f'Fiber Decomposition of Zero Set\n'
                 f'$f=(x_0-{roots[0]})(x_0-{roots[1]})$ over GF({q})²',
                 fontsize=14)
    ax.set_xticks(range(q))
    ax.set_yticks(range(q))
    ax.set_xlim(-0.5, q - 0.5)
    ax.set_ylim(-0.5, q + 0.3)
    ax.grid(True, alpha=0.15)

    # Stats box
    stats = (f'Zeros: {d}×{q}={d*q} (blue squares)\n'
             f'Nonzeros: {(q-d)*q} (gray circles)\n'
             f'Min distance = {(q-d)*q}')
    ax.text(0.98, 0.02, stats, transform=ax.transAxes, fontsize=11,
            verticalalignment='bottom', horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    from matplotlib.patches import Patch
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='s', color='w', markerfacecolor='#3498DB',
               markersize=12, label=f'Zero fiber (d={d} fibers)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#E8E8E8',
               markersize=10, label='Nonzero points'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=11)

    fig.tight_layout()
    return fig


def generate_all_figures():
    """Generate all figures and save them."""
    print("Generating visualizations...")

    fig1 = fig1_zero_set_heatmap()
    fig1.savefig('/workspace/request-project/fig1_zero_set.png', dpi=150, bbox_inches='tight')
    print("  Saved fig1_zero_set.png")

    fig2 = fig2_minimum_distance_curve()
    fig2.savefig('/workspace/request-project/fig2_min_distance.png', dpi=150, bbox_inches='tight')
    print("  Saved fig2_min_distance.png")

    fig3 = fig3_pit_error_probability()
    fig3.savefig('/workspace/request-project/fig3_pit_error.png', dpi=150, bbox_inches='tight')
    print("  Saved fig3_pit_error.png")

    fig4 = fig4_fiber_structure()
    fig4.savefig('/workspace/request-project/fig4_fiber_structure.png', dpi=150, bbox_inches='tight')
    print("  Saved fig4_fiber_structure.png")

    print("All visualizations generated.")
    return {
        "fig1": save_figure_base64(fig1_zero_set_heatmap()),
        "fig2": save_figure_base64(fig2_minimum_distance_curve()),
        "fig3": save_figure_base64(fig3_pit_error_probability()),
        "fig4": save_figure_base64(fig4_fiber_structure()),
    }


if __name__ == "__main__":
    generate_all_figures()
