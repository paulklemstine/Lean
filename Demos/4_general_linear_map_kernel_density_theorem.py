#!/usr/bin/env python3
"""
Applications of the Kernel Density Theorem.

Demonstrates real-world applications in coding theory, hashing,
error detection, and probabilistic verification.
"""

from itertools import product as cartesian_product
import random
import math


def mat_vec_mul(matrix, vec, q):
    """Matrix-vector multiply over GF(q)."""
    return [sum(matrix[i][j] * vec[j] for j in range(len(vec))) % q
            for i in range(len(matrix))]


# ──────────────────────────────────────────────────────────────────────
# Application 1: Error Detection with Parity Checks
# ──────────────────────────────────────────────────────────────────────

def error_detection_demo():
    """Demonstrate error detection using kernel density.

    Key insight: a parity-check matrix H defines a linear code C = ker(H).
    By the kernel density theorem, at most 1/q fraction of all vectors
    are codewords. So a random error has probability ≤ 1/q of being
    undetected (landing in the kernel).
    """
    print("=" * 70)
    print("APPLICATION 1: Error Detection via Parity Checks")
    print("=" * 70)

    q = 2
    # Simple repetition-style parity checks
    H = [[1, 1, 0, 0],
         [0, 0, 1, 1]]  # Check pairs

    n = 4
    code = []
    for v in cartesian_product(range(q), repeat=n):
        v_list = list(v)
        if mat_vec_mul(H, v_list, q) == [0, 0]:
            code.append(v_list)

    print(f"\n  Parity-check matrix H (over GF({q})):")
    for row in H:
        print(f"    {row}")
    print(f"\n  Code C = ker(H):")
    for c in code:
        print(f"    {c}")
    print(f"\n  |C| = {len(code)}, |GF({q})^{n}| = {q**n}")
    print(f"  Density = {len(code)}/{q**n} = {len(code)/q**n:.4f}")
    print(f"  Kernel density bound: ≤ 1/q^rank(H) = 1/{q}^2 = {1/q**2:.4f}")
    print(f"  Undetected error probability ≤ {1/q**2:.4f}")

    # Simulate random errors
    n_trials = 10000
    undetected = 0
    for _ in range(n_trials):
        error = [random.randint(0, q-1) for _ in range(n)]
        if error != [0]*n and mat_vec_mul(H, error, q) == [0, 0]:
            undetected += 1

    print(f"\n  Simulation ({n_trials} random nonzero errors):")
    print(f"    Undetected errors: {undetected}")
    print(f"    Empirical rate: {undetected/n_trials:.4f}")
    print(f"    Theoretical bound: {(len(code)-1)/(q**n - 1):.4f}")


# ──────────────────────────────────────────────────────────────────────
# Application 2: Universal Hashing
# ──────────────────────────────────────────────────────────────────────

def universal_hashing_demo():
    """Demonstrate universal hashing using linear maps.

    A family of linear maps {φ_a : GF(q)^n → GF(q)} indexed by
    a ∈ GF(q)^n \ {0} forms a universal hash family.

    By the kernel density theorem: for any fixed x ≠ 0,
        Pr_a[φ_a(x) = 0] = 1/q

    This means: for any two distinct keys x ≠ y,
        Pr_a[φ_a(x) = φ_a(y)] = Pr_a[φ_a(x-y) = 0] = 1/q
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Universal Linear Hashing")
    print("=" * 70)

    q = 5
    n = 3
    print(f"\n  Hash family: φ_a(x) = a·x over GF({q})^{n}")
    print(f"  Collision guarantee: Pr[φ_a(x) = φ_a(y)] = 1/{q} for x ≠ y")

    # Verify for specific key pair
    x = [1, 2, 3]
    y = [0, 1, 4]
    diff = [(x[i] - y[i]) % q for i in range(n)]

    collisions = 0
    total_hashes = 0
    for a in cartesian_product(range(q), repeat=n):
        a_list = list(a)
        if a_list == [0]*n:
            continue
        total_hashes += 1
        hx = sum(a_list[i] * x[i] for i in range(n)) % q
        hy = sum(a_list[i] * y[i] for i in range(n)) % q
        if hx == hy:
            collisions += 1

    print(f"\n  Keys: x = {x}, y = {y}")
    print(f"  x - y = {diff}")
    print(f"  Total nonzero hash functions: {total_hashes}")
    print(f"  Collisions: {collisions}")
    print(f"  Collision rate: {collisions/total_hashes:.6f}")
    print(f"  Expected (1/q): {1/q:.6f}")


# ──────────────────────────────────────────────────────────────────────
# Application 3: Freivalds' Algorithm (Randomized Matrix Verification)
# ──────────────────────────────────────────────────────────────────────

def freivalds_demo():
    """Demonstrate Freivalds' algorithm for verifying matrix products.

    To check if AB = C, pick random r ∈ GF(q)^n and check ABr = Cr.
    If AB ≠ C, then (AB - C)r = 0 iff r ∈ ker(AB - C).
    By the kernel density theorem, this happens with probability ≤ 1/q.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Freivalds' Randomized Matrix Verification")
    print("=" * 70)

    q = 7
    n = 3

    # True product
    A = [[1, 2, 0], [3, 1, 4], [2, 0, 1]]
    B = [[1, 0, 2], [0, 1, 1], [3, 2, 0]]

    # Compute C = AB over GF(q)
    C = [[sum(A[i][k] * B[k][j] for k in range(n)) % q
          for j in range(n)] for i in range(n)]

    # Incorrect C (with an error)
    C_wrong = [row[:] for row in C]
    C_wrong[0][0] = (C_wrong[0][0] + 1) % q

    print(f"\n  Working over GF({q}), matrices are {n}×{n}")
    print(f"  Error probability per trial: ≤ 1/{q} = {1/q:.4f}")

    # Simulate Freivalds for correct product
    n_trials = 1000
    false_rejects = 0
    for _ in range(n_trials):
        r = [random.randint(0, q-1) for _ in range(n)]
        Br = [sum(B[i][j] * r[j] for j in range(n)) % q for i in range(n)]
        ABr = [sum(A[i][j] * Br[j] for j in range(n)) % q for i in range(n)]
        Cr = [sum(C[i][j] * r[j] for j in range(n)) % q for i in range(n)]
        if ABr != Cr:
            false_rejects += 1
    print(f"\n  Correct product (C = AB):")
    print(f"    False rejects in {n_trials} trials: {false_rejects}")

    # Simulate for incorrect product
    false_accepts = 0
    for _ in range(n_trials):
        r = [random.randint(0, q-1) for _ in range(n)]
        Br = [sum(B[i][j] * r[j] for j in range(n)) % q for i in range(n)]
        ABr = [sum(A[i][j] * Br[j] for j in range(n)) % q for i in range(n)]
        Cr_w = [sum(C_wrong[i][j] * r[j] for j in range(n)) % q for i in range(n)]
        if ABr == Cr_w:
            false_accepts += 1
    print(f"\n  Incorrect product (C ≠ AB):")
    print(f"    False accepts in {n_trials} trials: {false_accepts}")
    print(f"    Empirical error rate: {false_accepts/n_trials:.4f}")
    print(f"    Theoretical bound: 1/{q} = {1/q:.4f}")


# ──────────────────────────────────────────────────────────────────────
# Application 4: Linear Code Capacity
# ──────────────────────────────────────────────────────────────────────

def coding_theory_demo():
    """Demonstrate coding theory implications.

    The product formula |ker(H)| · |range(H)| = |V| directly gives
    the relationship between code dimension and parity-check rank.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Linear Code Analysis via Kernel Density")
    print("=" * 70)

    codes = [
        ("Hamming [7,4]₂", 2, 7,
         [[1,0,0,1,1,0,1],[0,1,0,1,0,1,1],[0,0,1,0,1,1,1]]),
        ("Repetition [3,1]₃", 3, 3,
         [[1,2,0],[0,1,2]]),
        ("Single parity [5,4]₅", 5, 5,
         [[1,1,1,1,1]]),
    ]

    for name, q, n, H in codes:
        # Compute rank
        mat = [row[:] for row in H]
        m = len(mat)
        rank = 0
        for col in range(n):
            pivot = None
            for row in range(rank, m):
                if mat[row][col] % q != 0:
                    pivot = row
                    break
            if pivot is None:
                continue
            mat[rank], mat[pivot] = mat[pivot], mat[rank]
            inv = pow(mat[rank][col], q-2, q)
            mat[rank] = [(x * inv) % q for x in mat[rank]]
            for row in range(m):
                if row != rank and mat[row][col] % q != 0:
                    f = mat[row][col]
                    mat[row] = [(mat[row][j] - f * mat[rank][j]) % q for j in range(n)]
            rank += 1

        k = n - rank
        print(f"\n  {name}:")
        print(f"    q={q}, n={n}, rank(H)={rank}, k={k}")
        print(f"    |code| = q^k = {q}^{k} = {q**k}")
        print(f"    |ambient| = q^n = {q}^{n} = {q**n}")
        print(f"    Code rate = k/n = {k}/{n} = {k/n:.4f}")
        print(f"    Density = 1/q^rank = 1/{q}^{rank} = {1/q**rank:.6f}")
        print(f"    Product check: {q**k} × {q**rank} = {q**k * q**rank} = {q**n} ✓")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  KERNEL DENSITY THEOREM — REAL-WORLD APPLICATIONS                  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    error_detection_demo()
    universal_hashing_demo()
    freivalds_demo()
    coding_theory_demo()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Kernel Density Theorem — Concrete Demonstrations

Demonstrates the theorem: for a nonzero linear map f: V → W over GF(q),
    |ker(f)| * q ≤ |V|
and the exact product formula:
    |ker(f)| * |range(f)| = |V|

Uses concrete finite vector spaces over prime fields.
"""

import numpy as np
from itertools import product as cartesian_product


def make_field(q: int):
    """Arithmetic mod q (assumes q is prime)."""
    return q


def all_vectors(q: int, n: int):
    """Generate all vectors in GF(q)^n."""
    return [list(v) for v in cartesian_product(range(q), repeat=n)]


def mat_vec_mul(matrix, vec, q):
    """Multiply matrix by vector over GF(q)."""
    m = len(matrix)
    result = [0] * m
    for i in range(m):
        s = 0
        for j in range(len(vec)):
            s += matrix[i][j] * vec[j]
        result[i] = s % q
    return result


def compute_kernel(matrix, q, n):
    """Compute the kernel of a matrix over GF(q)."""
    vectors = all_vectors(q, n)
    zero = [0] * len(matrix)
    kernel = [v for v in vectors if mat_vec_mul(matrix, v, q) == zero]
    return kernel


def compute_range(matrix, q, n):
    """Compute the range (image) of a matrix over GF(q)."""
    vectors = all_vectors(q, n)
    image = set()
    for v in vectors:
        image.add(tuple(mat_vec_mul(matrix, v, q)))
    return image


def demo_product_formula():
    """Demonstrate |ker(f)| * |range(f)| = |V| for various maps."""
    print("=" * 70)
    print("DEMO 1: Product Formula  |ker(f)| × |range(f)| = |V|")
    print("=" * 70)

    examples = [
        # (q, n_domain, m_codomain, matrix_rows, description)
        (2, 3, 2, [[1, 0, 1], [0, 1, 1]], "GF(2)^3 → GF(2)^2, parity-check style"),
        (3, 2, 2, [[1, 2], [2, 1]], "GF(3)^2 → GF(3)^2, invertible map"),
        (5, 3, 1, [[1, 2, 3]], "GF(5)^3 → GF(5), linear functional"),
        (2, 4, 2, [[1, 1, 0, 0], [0, 0, 1, 1]], "GF(2)^4 → GF(2)^2, block parity"),
        (3, 3, 2, [[1, 0, 0], [0, 1, 0]], "GF(3)^3 → GF(3)^2, projection"),
        (7, 2, 1, [[3, 5]], "GF(7)^2 → GF(7), linear functional"),
    ]

    for q, n, m, matrix, desc in examples:
        domain_size = q ** n
        kernel = compute_kernel(matrix, q, n)
        image = compute_range(matrix, q, n)
        ker_size = len(kernel)
        range_size = len(image)
        product = ker_size * range_size

        print(f"\n  {desc}")
        print(f"    q = {q}, dim(V) = {n}, dim(W) = {m}")
        print(f"    |V| = {domain_size}")
        print(f"    |ker(f)| = {ker_size}")
        print(f"    |range(f)| = {range_size}")
        print(f"    |ker(f)| × |range(f)| = {ker_size} × {range_size} = {product}")
        assert product == domain_size, f"Product formula FAILED: {product} ≠ {domain_size}"
        print(f"    ✓ Product formula verified: {product} = {domain_size}")


def demo_kernel_density():
    """Demonstrate |ker(f)| * q ≤ |V| for nonzero maps."""
    print("\n" + "=" * 70)
    print("DEMO 2: Kernel Density Bound  |ker(f)| × q ≤ |V|")
    print("=" * 70)

    examples = [
        (2, 4, [[1, 0, 1, 0]], "GF(2)^4 → GF(2), single constraint"),
        (3, 3, [[1, 1, 1]], "GF(3)^3 → GF(3), sum functional"),
        (5, 2, [[1, 0]], "GF(5)^2 → GF(5), projection to first coord"),
        (2, 5, [[1, 1, 1, 1, 1]], "GF(2)^5 → GF(2), total parity"),
        (7, 2, [[2, 3]], "GF(7)^2 → GF(7), generic functional"),
    ]

    print(f"\n  {'Map description':<45} {'q':>3} {'|ker|':>6} {'|V|':>6} "
          f"{'|ker|×q':>8} {'≤ |V|?':>7} {'density':>10}")
    print("  " + "-" * 90)

    for q, n, matrix, desc in examples:
        domain_size = q ** n
        kernel = compute_kernel(matrix, q, n)
        ker_size = len(kernel)
        bound = ker_size * q
        density = ker_size / domain_size

        ok = "✓" if bound <= domain_size else "✗"
        print(f"  {desc:<45} {q:>3} {ker_size:>6} {domain_size:>6} "
              f"{bound:>8} {ok:>7} {density:>10.4f}")
        assert bound <= domain_size


def demo_density_tightness():
    """Show that 1/q is tight: linear functionals achieve it exactly."""
    print("\n" + "=" * 70)
    print("DEMO 3: Tightness — Linear Functionals Achieve Density = 1/q Exactly")
    print("=" * 70)

    for q in [2, 3, 5, 7]:
        for n in [2, 3, 4]:
            # Use f(x) = x_1 (projection to first coordinate)
            matrix = [[1] + [0] * (n - 1)]
            domain_size = q ** n
            kernel = compute_kernel(matrix, q, n)
            ker_size = len(kernel)
            density = ker_size / domain_size

            print(f"  GF({q})^{n}, f(x) = x₁:  "
                  f"|ker| = {ker_size:>5}, |V| = {domain_size:>5}, "
                  f"density = {density:.6f} = 1/{q} = {1/q:.6f}")
            assert abs(density - 1/q) < 1e-10, "Tightness check failed"


def demo_codimension():
    """Show dim(ker f) < dim(V) for nonzero f."""
    print("\n" + "=" * 70)
    print("DEMO 4: Codimension — dim(ker f) < dim(V) for f ≠ 0")
    print("=" * 70)

    examples = [
        (2, 3, 1, [[1, 1, 0]]),
        (3, 4, 2, [[1, 0, 2, 1], [0, 1, 1, 2]]),
        (5, 3, 1, [[2, 3, 4]]),
        (2, 5, 3, [[1,0,0,1,1],[0,1,0,1,0],[0,0,1,0,1]]),
    ]

    for q, n, m, matrix in examples:
        kernel = compute_kernel(matrix, q, n)
        ker_size = len(kernel)
        # dim(ker) = log_q(|ker|)
        import math
        ker_dim = round(math.log(ker_size, q)) if ker_size > 0 else 0
        print(f"  GF({q})^{n} → GF({q})^{m}: "
              f"|ker| = {ker_size} = {q}^{ker_dim}, "
              f"dim(ker) = {ker_dim} < {n} = dim(V) ✓")
        assert ker_dim < n


def demo_divisibility():
    """Show |ker(f)| divides |V|."""
    print("\n" + "=" * 70)
    print("DEMO 5: Divisibility — |ker(f)| divides |V|")
    print("=" * 70)

    for q in [2, 3, 5]:
        for n in [2, 3, 4]:
            for matrix_row in [[1] + [0]*(n-1), [1]*n]:
                matrix = [matrix_row]
                domain_size = q ** n
                kernel = compute_kernel(matrix, q, n)
                ker_size = len(kernel)
                divides = domain_size % ker_size == 0
                quotient = domain_size // ker_size
                print(f"  GF({q})^{n}: |ker| = {ker_size}, |V| = {domain_size}, "
                      f"|V|/|ker| = {quotient}, divides: {'✓' if divides else '✗'}")
                assert divides


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     KERNEL DENSITY THEOREM — COMPUTATIONAL DEMONSTRATIONS          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_product_formula()
    demo_kernel_density()
    demo_density_tightness()
    demo_codimension()
    demo_divisibility()

    print("\n" + "=" * 70)
    print("All demonstrations passed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for the Kernel Density Theorem.

Generates publication-quality charts showing:
1. Kernel density as a function of field size q
2. Product formula verification across parameters
3. Code rate vs. density tradeoff
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_kernel_density_bound():
    """Plot kernel density 1/q as function of prime q."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    densities = [1.0 / p for p in primes]

    ax.bar(range(len(primes)), densities, color='#2196F3', alpha=0.8, edgecolor='#1565C0')
    ax.set_xticks(range(len(primes)))
    ax.set_xticklabels([str(p) for p in primes], fontsize=10)
    ax.set_xlabel('Prime field size q', fontsize=14)
    ax.set_ylabel('Maximum kernel density 1/q', fontsize=14)
    ax.set_title('Kernel Density Bound: Fraction of Domain in Kernel ≤ 1/q',
                 fontsize=16, fontweight='bold')
    ax.set_ylim(0, 0.55)

    # Add value labels
    for i, (p, d) in enumerate(zip(primes, densities)):
        ax.text(i, d + 0.01, f'1/{p}', ha='center', va='bottom', fontsize=9)

    ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='1/2 (binary field)')
    ax.legend(fontsize=12)
    ax.grid(axis='y', alpha=0.3)

    fig.savefig('/workspace/request-project/kernel_density_bound.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_product_formula():
    """Visualize the product formula |ker| × |range| = |V|."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, q in enumerate([2, 3, 5]):
        ax = axes[idx]
        dims = range(1, 7)
        for rank in range(1, 6):
            ker_sizes = []
            range_sizes = []
            domain_sizes = []
            valid_dims = []
            for n in dims:
                if rank <= n:
                    ker_size = q ** (n - rank)
                    range_size = q ** rank
                    domain_size = q ** n
                    ker_sizes.append(ker_size)
                    range_sizes.append(range_size)
                    domain_sizes.append(domain_size)
                    valid_dims.append(n)

            if valid_dims:
                ax.plot(valid_dims, ker_sizes, 'o-', label=f'rank={rank}', markersize=5)

        ax.set_xlabel('Domain dimension n', fontsize=12)
        ax.set_ylabel('|ker(f)|', fontsize=12)
        ax.set_title(f'Kernel Size over GF({q})', fontsize=14, fontweight='bold')
        ax.set_yscale('log')
        ax.legend(fontsize=9, loc='upper left')
        ax.grid(alpha=0.3)

    fig.suptitle('Product Formula: |ker(f)| = q^(n-rank) for Various Fields',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/product_formula.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_code_rate_density():
    """Plot code rate vs. density tradeoff."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    for q in [2, 3, 5, 7]:
        n_values = range(2, 20)
        rates = []
        densities = []
        for n in n_values:
            for rank in range(1, n):
                k = n - rank
                rate = k / n
                density = 1.0 / q ** rank
                rates.append(rate)
                densities.append(density)

        ax.scatter(rates, densities, alpha=0.5, s=20, label=f'GF({q})')

    ax.set_xlabel('Code Rate k/n', fontsize=14)
    ax.set_ylabel('Code Density |C|/|V| = 1/q^r', fontsize=14)
    ax.set_title('Code Rate vs. Density Tradeoff by Field Size',
                 fontsize=16, fontweight='bold')
    ax.set_yscale('log')
    ax.legend(fontsize=12)
    ax.grid(alpha=0.3)

    fig.savefig('/workspace/request-project/code_rate_density.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_error_probability():
    """Plot error detection probability as function of number of checks."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    num_checks = range(1, 11)

    for q in [2, 3, 5, 7, 11]:
        probs = [1.0 / q**r for r in num_checks]
        ax.plot(num_checks, probs, 'o-', label=f'q = {q}', linewidth=2, markersize=6)

    ax.set_xlabel('Number of independent parity checks (rank r)', fontsize=14)
    ax.set_ylabel('Undetected error probability 1/q^r', fontsize=14)
    ax.set_title('Error Detection Power: More Checks = Exponentially Better Detection',
                 fontsize=16, fontweight='bold')
    ax.set_yscale('log')
    ax.legend(fontsize=12)
    ax.grid(alpha=0.3)
    ax.set_xticks(range(1, 11))

    fig.savefig('/workspace/request-project/error_probability.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = plot_kernel_density_bound()
    print(f"  ✓ kernel_density_bound.png ({len(b64_1)} chars base64)")

    b64_2 = plot_product_formula()
    print(f"  ✓ product_formula.png ({len(b64_2)} chars base64)")

    b64_3 = plot_code_rate_density()
    print(f"  ✓ code_rate_density.png ({len(b64_3)} chars base64)")

    b64_4 = plot_error_probability()
    print(f"  ✓ error_probability.png ({len(b64_4)} chars base64)")

    print("\nAll visualizations generated successfully!")
