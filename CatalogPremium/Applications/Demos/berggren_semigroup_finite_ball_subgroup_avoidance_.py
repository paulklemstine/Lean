#!/usr/bin/env python3
"""
Berggren Ball Rigidity & Generic-Group Transfer — Concrete Demonstrations

This script demonstrates the mathematical theorems proved in BerggrenBallRigidity.lean:

1. Builds the Berggren ball of radius R (products of ≤R generators)
2. Computes pairwise difference sets and quotient power sets
3. Finds separating primes that make reduction mod p injective
4. Demonstrates that relation lifting holds: equalities mod p lift to ℤ
5. Visualizes the structure of the Berggren semigroup

Requirements: numpy, matplotlib (optional for plots)
"""

import numpy as np
from itertools import product as iterproduct

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not available; skipping plots")

# ============================================================
# Section 1: Berggren Generators (2×2 integer matrices)
# ============================================================

M1 = np.array([[2, -1], [1, 0]], dtype=np.int64)   # A-branch, det = 1
M2 = np.array([[2, 1], [1, 0]], dtype=np.int64)     # B-branch, det = -1
M3 = np.array([[1, 2], [0, 1]], dtype=np.int64)     # C-branch, det = 1

GENERATORS = [M1, M2, M3]
GEN_NAMES = ['M₁', 'M₂', 'M₃']

def mat_to_tuple(M):
    return tuple(M.flatten())

def tuple_to_mat(t):
    return np.array(t, dtype=np.int64).reshape(2, 2)

# ============================================================
# Section 2: Berggren Ball Construction
# ============================================================

def berggren_ball(R):
    """Compute the Berggren ball of radius R."""
    ball = {}
    identity = np.eye(2, dtype=np.int64)
    ball[mat_to_tuple(identity)] = (identity, [])
    frontier = [(identity, [])]
    for depth in range(R):
        new_frontier = []
        for M, word in frontier:
            for i, G in enumerate(GENERATORS):
                product = M @ G
                key = mat_to_tuple(product)
                if key not in ball:
                    new_word = word + [i]
                    ball[key] = (product, new_word)
                    new_frontier.append((product, new_word))
        frontier = new_frontier
    return ball

def word_to_string(word):
    if not word:
        return "I"
    return '·'.join(GEN_NAMES[i] for i in word)

# ============================================================
# Section 3: Prime finding and Residual Separation
# ============================================================

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def next_prime(n):
    p = max(2, n + 1)
    while not is_prime(p):
        p += 1
    return p

def max_entry_abs(matrices):
    return max(int(np.max(np.abs(M))) for M in matrices)

def find_separating_modulus(matrices):
    B = max_entry_abs(matrices)
    return next_prime(2 * B)

def reduce_mod(M, p):
    return M % p

def check_injectivity(matrices, p):
    reductions = {}
    for M in matrices:
        key = mat_to_tuple(reduce_mod(M, p))
        if key in reductions:
            return False, (M, reductions[key])
        reductions[key] = M
    return True, None

# ============================================================
# Section 4: Demonstrations
# ============================================================

def demo_berggren_ball():
    print("=" * 70)
    print("DEMONSTRATION 1: Berggren Ball Structure")
    print("=" * 70)
    for R in range(5):
        ball = berggren_ball(R)
        print(f"\n  Berggren ball B({R}): {len(ball)} distinct matrices")
        if R <= 2:
            for key, (M, word) in sorted(ball.items(), key=lambda x: len(x[1][1])):
                det = int(round(np.linalg.det(M)))
                print(f"    {word_to_string(word):15s}  det={det:+d}  "
                      f"[[{M[0,0]:3d}, {M[0,1]:3d}], [{M[1,0]:3d}, {M[1,1]:3d}]]")
    print(f"\n  Ball growth: ", end="")
    for R in range(6):
        ball = berggren_ball(R)
        print(f"B({R})={len(ball)}", end="  ")
    print()

def demo_residual_separation():
    print("\n" + "=" * 70)
    print("DEMONSTRATION 2: Residual Separation (Core Theorem)")
    print("=" * 70)
    print()
    print("  Theorem: For any finite set T of 2×2 integer matrices,")
    print("  ∃ N ≥ 2 such that reduction mod N is injective on T.")
    print()
    for R in range(1, 5):
        ball = berggren_ball(R)
        matrices = [M for M, _ in ball.values()]
        B = max_entry_abs(matrices)
        p = find_separating_modulus(matrices)
        is_inj, _ = check_injectivity(matrices, p)
        print(f"  R={R}: |B(R)|={len(matrices):5d}, max|entry|={B:8d}, "
              f"separating prime p={p:10d}, injective={is_inj}")

    print("\n  Failure of small primes on B(3):")
    ball = berggren_ball(3)
    matrices = [M for M, _ in ball.values()]
    for p in [2, 3, 5, 7, 11, 13]:
        is_inj, collision = check_injectivity(matrices, p)
        if not is_inj:
            M1c, M2c = collision
            print(f"    p={p:2d}: NOT injective — collision between "
                  f"matrices with entries {M1c.flatten()} and {M2c.flatten()}")
        else:
            print(f"    p={p:2d}: injective ✓")

def demo_power_collision():
    print("\n" + "=" * 70)
    print("DEMONSTRATION 3: Power Collision Lifting")
    print("=" * 70)
    print()
    print("  Theorem: ∃ N ≥ 2 s.t. any power equality mod N among")
    print("  (x-y)^a, (u-v)^b for x,y,u,v ∈ B(R), a,b ≤ K lifts to ℤ.")
    print()
    R, K = 2, 4
    ball = berggren_ball(R)
    matrices = [M for M, _ in ball.values()]
    power_set = set()
    for x in matrices:
        for y in matrices:
            diff = x - y
            for n in range(K + 1):
                power = np.linalg.matrix_power(diff, n).astype(np.int64)
                power_set.add(mat_to_tuple(power))
    power_matrices = [tuple_to_mat(t) for t in power_set]
    p = find_separating_modulus(power_matrices)
    is_inj, _ = check_injectivity(power_matrices, p)
    print(f"  R={R}, K={K}")
    print(f"  |B(R)|={len(matrices)}, |quotientPowerSet|={len(power_set)}")
    print(f"  Separating prime: p={p}")
    print(f"  Injective on quotientPowerSet: {is_inj}")
    # Verify lifting
    count_lifted = 0
    count_total = 0
    for x in matrices[:5]:
        for y in matrices[:5]:
            diff = x - y
            for a in range(K + 1):
                for b in range(a + 1, K + 1):
                    pa = np.linalg.matrix_power(diff, a).astype(np.int64)
                    pb = np.linalg.matrix_power(diff, b).astype(np.int64)
                    eq_mod = np.array_equal(pa % p, pb % p)
                    eq_int = np.array_equal(pa, pb)
                    count_total += 1
                    if eq_mod:
                        count_lifted += 1
                        assert eq_int, "Lifting theorem violated!"
    print(f"\n  Checked {count_total} power pairs")
    print(f"  Found {count_lifted} mod-p equalities, all lift to ℤ ✓")

def demo_word_expr_injectivity():
    print("\n" + "=" * 70)
    print("DEMONSTRATION 4: Bounded Word Expression Injectivity")
    print("=" * 70)
    print()
    for K in range(1, 4):
        eval_set = set()
        base_mats = [np.eye(2, dtype=np.int64)] + list(GENERATORS)
        for M in base_mats:
            eval_set.add(mat_to_tuple(M))
        prev = list(eval_set)
        for _ in range(K):
            new = set()
            for t1 in prev:
                M1v = tuple_to_mat(t1)
                for t2 in prev:
                    M2v = tuple_to_mat(t2)
                    prod = (M1v @ M2v).astype(np.int64)
                    new.add(mat_to_tuple(prod))
                for n in range(K + 1):
                    pw = np.linalg.matrix_power(M1v, n).astype(np.int64)
                    new.add(mat_to_tuple(pw))
            eval_set.update(new)
            prev = list(eval_set)
        all_matrices = [tuple_to_mat(t) for t in eval_set]
        B = max_entry_abs(all_matrices)
        p = find_separating_modulus(all_matrices)
        is_inj, _ = check_injectivity(all_matrices, p)
        print(f"  K={K}: |evalSet|={len(eval_set):6d}, max|entry|={B:12d}, "
              f"sep. prime={p:14d}, inj={is_inj}")

def demo_cryptographic_application():
    print("\n" + "=" * 70)
    print("DEMONSTRATION 5: Cryptographic Application — Generic-Group Hardness")
    print("=" * 70)
    print()
    print("  The relation lifting theorem gives a rigorous generic-group style")
    print("  obstruction: any bounded-complexity algorithm that works uniformly")
    print("  on reduced Berggren elements must exploit non-generic structure.")
    print()
    R = 3
    ball = berggren_ball(R)
    matrices = [M for M, _ in ball.values()]
    p = find_separating_modulus(matrices)
    print(f"  Setup: R={R}, |B(R)|={len(matrices)}, modulus p={p}")
    print()
    np.random.seed(42)
    alice_idx = np.random.randint(len(matrices))
    bob_idx = np.random.randint(len(matrices))
    alice_mat = matrices[alice_idx]
    bob_mat = matrices[bob_idx]
    alice_pub = reduce_mod(alice_mat, p)
    bob_pub = reduce_mod(bob_mat, p)
    shared_int = (alice_mat @ bob_mat).astype(np.int64)
    shared_mod = reduce_mod(shared_int, p)
    print(f"  Alice's matrix (over ℤ): {alice_mat.tolist()}")
    print(f"  Alice's public key (mod {p}): {alice_pub.tolist()}")
    print(f"  Bob's matrix (over ℤ): {bob_mat.tolist()}")
    print(f"  Bob's public key (mod {p}): {bob_pub.tolist()}")
    print(f"  Shared secret (over ℤ): {shared_int.tolist()}")
    print(f"  Shared secret (mod {p}): {shared_mod.tolist()}")
    print()
    print("  The relation lifting theorem guarantees that any equality")
    print("  discovered by a generic-group algorithm mod p was already")
    print("  present over ℤ — the reduction leaks no algebraic info.")

# ============================================================
# Section 5: Visualizations
# ============================================================

def plot_berggren_ball_growth():
    if not HAS_MATPLOTLIB:
        return
    Rs = list(range(6))
    sizes = [len(berggren_ball(R)) for R in Rs]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ax1.plot(Rs, sizes, 'bo-', linewidth=2, markersize=8)
    ax1.set_xlabel('Radius R', fontsize=12)
    ax1.set_ylabel('|B(R)|', fontsize=12)
    ax1.set_title('Berggren Ball Size (Linear Scale)', fontsize=14)
    ax1.grid(True, alpha=0.3)
    ax2.semilogy(Rs, sizes, 'ro-', linewidth=2, markersize=8)
    theoretical = [sum(3**k for k in range(R + 1)) for R in Rs]
    ax2.semilogy(Rs, theoretical, 'g--', linewidth=1, label='Σ 3^k (no collisions)')
    ax2.set_xlabel('Radius R', fontsize=12)
    ax2.set_ylabel('|B(R)|', fontsize=12)
    ax2.set_title('Berggren Ball Size (Log Scale)', fontsize=14)
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demos/berggren_ball_growth.png', dpi=150, bbox_inches='tight')
    print("\n  [Saved: demos/berggren_ball_growth.png]")

def plot_separating_primes():
    if not HAS_MATPLOTLIB:
        return
    Rs = list(range(1, 5))
    primes, max_entries, ball_sizes = [], [], []
    for R in Rs:
        ball = berggren_ball(R)
        matrices = [M for M, _ in ball.values()]
        B = max_entry_abs(matrices)
        p = find_separating_modulus(matrices)
        primes.append(p)
        max_entries.append(B)
        ball_sizes.append(len(matrices))
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.semilogy(Rs, primes, 'rs-', linewidth=2, markersize=8, label='Separating prime p')
    ax.semilogy(Rs, max_entries, 'b^-', linewidth=2, markersize=8, label='Max |entry|')
    ax.semilogy(Rs, ball_sizes, 'go-', linewidth=2, markersize=8, label='Ball size |B(R)|')
    ax.set_xlabel('Radius R', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Separating Prime Growth vs Berggren Ball Radius', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demos/separating_primes.png', dpi=150, bbox_inches='tight')
    print("  [Saved: demos/separating_primes.png]")

def plot_injectivity_failure():
    if not HAS_MATPLOTLIB:
        return
    R = 3
    ball = berggren_ball(R)
    matrices = [M for M, _ in ball.values()]
    primes_to_test = []
    p = 2
    while p < 100:
        primes_to_test.append(p)
        p = next_prime(p)
    results = [1 if check_injectivity(matrices, p)[0] else 0 for p in primes_to_test]
    fig, ax = plt.subplots(figsize=(12, 4))
    colors = ['red' if r == 0 else 'green' for r in results]
    ax.bar(range(len(primes_to_test)), [1]*len(primes_to_test), color=colors, alpha=0.7)
    ax.set_xticks(range(len(primes_to_test)))
    ax.set_xticklabels([str(p) for p in primes_to_test], rotation=45, fontsize=8)
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_title(f'Injectivity of reduction mod p on B({R}) '
                 f'(green=injective, red=collision)', fontsize=13)
    ax.set_yticks([])
    plt.tight_layout()
    plt.savefig('demos/injectivity_by_prime.png', dpi=150, bbox_inches='tight')
    print("  [Saved: demos/injectivity_by_prime.png]")

# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("╔" + "═" * 68 + "╗")
    print("║  BERGGREN BALL RIGIDITY & GENERIC-GROUP TRANSFER DEMONSTRATIONS  ║")
    print("╚" + "═" * 68 + "╝")
    
    demo_berggren_ball()
    demo_residual_separation()
    demo_power_collision()
    demo_word_expr_injectivity()
    demo_cryptographic_application()
    
    print("\n" + "=" * 70)
    print("VISUALIZATIONS")
    print("=" * 70)
    plot_berggren_ball_growth()
    plot_separating_primes()
    plot_injectivity_failure()
    
    print("\n" + "=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)
