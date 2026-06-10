#!/usr/bin/env python3
"""
Tropical Cryptography Demo: Min-Plus Diffie-Hellman Key Exchange

Demonstrates the tropical Diffie-Hellman key exchange protocol,
power stagnation detection, and the diagonal TDLP vulnerability.
"""

import numpy as np
from typing import Optional
import time

INF = float('inf')


def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with infinity handling)."""
    if a == INF or b == INF:
        return INF
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A⊗B)_ij = min_k(A_ik + B_kj)."""
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = trop_mul(A[i, k], B[k, j])
                C[i, j] = trop_add(C[i, j], val)
    return C


def trop_mat_pow(A: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power via repeated squaring: A^⊗k."""
    n = A.shape[0]
    if k == 0:
        # Tropical identity: 0 on diagonal, inf elsewhere
        I = np.full((n, n), INF)
        np.fill_diagonal(I, 0)
        return I
    if k == 1:
        return A.copy()
    if k % 2 == 0:
        half = trop_mat_pow(A, k // 2)
        return trop_mat_mul(half, half)
    else:
        return trop_mat_mul(A, trop_mat_pow(A, k - 1))


def trop_trace(A: np.ndarray) -> float:
    """Tropical trace: min of diagonal entries."""
    return min(A[i, i] for i in range(A.shape[0]))


def detect_stagnation(A: np.ndarray, max_k: int = 1000) -> Optional[int]:
    """Find the stagnation index: smallest k with A^k = A^(k+1)."""
    Ak = A.copy()
    for k in range(1, max_k + 1):
        Ak1 = trop_mat_mul(A, Ak)
        if np.array_equal(Ak, Ak1):
            return k
        Ak = Ak1
    return None


def random_tropical_matrix(n: int, B: int = 10) -> np.ndarray:
    """Generate a random n×n tropical matrix with entries in {0,...,B}."""
    return np.random.randint(0, B + 1, size=(n, n)).astype(float)


def demo_dh_key_exchange():
    """Demonstrate tropical Diffie-Hellman key exchange."""
    print("=" * 60)
    print("TROPICAL DIFFIE-HELLMAN KEY EXCHANGE")
    print("=" * 60)
    
    n = 4
    G = random_tropical_matrix(n, B=10)
    
    print(f"\nPublic matrix G ({n}×{n}):")
    print(G)
    
    # Alice's secret
    a = np.random.randint(2, 20)
    Ga = trop_mat_pow(G, a)
    
    # Bob's secret
    b = np.random.randint(2, 20)
    Gb = trop_mat_pow(G, b)
    
    print(f"\nAlice's secret: a = {a}")
    print(f"Bob's secret:   b = {b}")
    print(f"\nAlice publishes G^⊗{a}:")
    print(Ga)
    print(f"\nBob publishes G^⊗{b}:")
    print(Gb)
    
    # Shared keys
    alice_key = trop_mat_pow(Gb, a)  # (G^b)^a = G^(ab)
    bob_key = trop_mat_pow(Ga, b)    # (G^a)^b = G^(ab)
    
    print(f"\nAlice computes (G^⊗{b})^⊗{a} = G^⊗{a*b}:")
    print(alice_key)
    print(f"\nBob computes (G^⊗{a})^⊗{b} = G^⊗{a*b}:")
    print(bob_key)
    
    keys_match = np.array_equal(alice_key, bob_key)
    print(f"\n✓ Keys match: {keys_match}")
    assert keys_match, "ERROR: Keys don't match!"


def demo_stagnation():
    """Demonstrate the power stagnation phenomenon."""
    print("\n" + "=" * 60)
    print("POWER STAGNATION DETECTION")
    print("=" * 60)
    
    # Small matrix for visualization
    A = np.array([[0, 3, INF],
                  [2, 0, 1],
                  [INF, 4, 0]], dtype=float)
    
    print(f"\nMatrix A:")
    print(A)
    
    print("\nPower sequence:")
    Ak = A.copy()
    for k in range(1, 10):
        print(f"\nA^⊗{k}:")
        print(Ak)
        print(f"  trace = {trop_trace(Ak)}")
        Ak_next = trop_mat_mul(A, Ak)
        if np.array_equal(Ak, Ak_next):
            print(f"\n★ STAGNATION at k = {k}")
            print(f"  All powers A^⊗m for m ≥ {k} equal A^⊗{k}")
            break
        Ak = Ak_next
    
    # Random matrices with varying sizes
    print("\n\nStagnation indices for random matrices:")
    print(f"{'Size':>6} {'B':>4} {'Stag. Index':>12} {'Time (ms)':>10}")
    print("-" * 36)
    for n in [3, 4, 5, 6, 8]:
        for B in [5, 10, 20]:
            A = random_tropical_matrix(n, B)
            t0 = time.time()
            k0 = detect_stagnation(A, max_k=500)
            dt = (time.time() - t0) * 1000
            print(f"{n:>6} {B:>4} {str(k0):>12} {dt:>10.1f}")


def demo_diagonal_vulnerability():
    """Demonstrate the diagonal TDLP vulnerability."""
    print("\n" + "=" * 60)
    print("DIAGONAL TDLP VULNERABILITY")
    print("=" * 60)
    
    # Diagonal matrix
    d = [3, 5, 7, 2]
    n = len(d)
    D = np.full((n, n), INF)
    for i in range(n):
        D[i, i] = d[i]
    
    k_secret = 17
    Dk = trop_mat_pow(D, k_secret)
    
    print(f"\nDiagonal matrix D = diag({d})")
    print(f"Secret exponent: k = {k_secret}")
    print(f"\nD^⊗{k_secret}:")
    print(Dk)
    
    # Attack: recover k from any diagonal entry
    print("\nAttack: recover k from diagonal entries:")
    for i in range(n):
        if D[i, i] != INF and D[i, i] != 0:
            k_recovered = Dk[i, i] / D[i, i]
            print(f"  Entry ({i},{i}): D_{{{i}{i}}} = {D[i,i]}, "
                  f"(D^k)_{{{i}{i}}} = {Dk[i,i]}, "
                  f"k = {Dk[i,i]}/{D[i,i]} = {k_recovered}")
    
    print(f"\n★ Secret exponent recovered: k = {k_secret}")
    print("  Diagonal TDLP is trivially solvable!")


def demo_timing():
    """Measure tropical matrix power computation time vs size."""
    print("\n" + "=" * 60)
    print("PERFORMANCE: TROPICAL MATRIX POWER (REPEATED SQUARING)")
    print("=" * 60)
    
    k = 1000000  # Large exponent
    print(f"\nComputing A^⊗{k} for various matrix sizes:")
    print(f"{'Size':>6} {'Time (ms)':>10} {'Muls (est)':>12}")
    print("-" * 32)
    
    for n in [2, 3, 4, 5, 8, 10]:
        A = random_tropical_matrix(n, B=100)
        t0 = time.time()
        _ = trop_mat_pow(A, k)
        dt = (time.time() - t0) * 1000
        muls = 2 * int(np.log2(k)) + 1  # Approximate
        print(f"{n:>6} {dt:>10.1f} {muls:>12}")


if __name__ == "__main__":
    np.random.seed(42)
    demo_dh_key_exchange()
    demo_stagnation()
    demo_diagonal_vulnerability()
    demo_timing()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Tropical Matrix Power Orbit
Shows the orbit structure and its implications for TDLP security.
"""
import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict

INF = float('inf')

def trop_mat_mul(A, B):
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if A[i,k] != INF and B[k,j] != INF:
                    C[i,j] = min(C[i,j], A[i,k] + B[k,j])
    return C

def mat_to_key(A):
    return tuple(A.flatten())

def main():
    np.random.seed(123)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Plot 1: Orbit size vs matrix size
    ax = axes[0, 0]
    sizes = [2, 3, 4, 5]
    Bs = [3, 5, 10]
    for B in Bs:
        orbit_sizes = []
        for n in sizes:
            total = 0
            trials = 50
            for _ in range(trials):
                A = np.random.randint(0, B+1, (n, n)).astype(float)
                seen = set()
                Ak = A.copy()
                for k in range(1, 500):
                    key = mat_to_key(Ak)
                    if key in seen:
                        break
                    seen.add(key)
                    Ak = trop_mat_mul(A, Ak)
                total += len(seen)
            orbit_sizes.append(total / trials)
        ax.plot(sizes, orbit_sizes, 'o-', linewidth=2, markersize=8, label=f'B={B}')
    ax.set_xlabel('Matrix Size n', fontsize=12)
    ax.set_ylabel('Average Orbit Size', fontsize=12)
    ax.set_title('Orbit Size vs Matrix Dimension', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Diagonal vs non-diagonal TDLP difficulty
    ax = axes[0, 1]
    n = 3
    diag_stag = []
    nondiag_stag = []
    for _ in range(100):
        # Diagonal matrix
        d = np.random.randint(1, 11, n).astype(float)
        D = np.full((n, n), INF)
        np.fill_diagonal(D, d)
        Dk = D.copy()
        for k in range(1, 200):
            Dk1 = trop_mat_mul(D, Dk)
            if np.array_equal(Dk, Dk1):
                diag_stag.append(k)
                break
            Dk = Dk1
        else:
            diag_stag.append(200)
        
        # Random non-diagonal matrix
        A = np.random.randint(0, 11, (n, n)).astype(float)
        Ak = A.copy()
        for k in range(1, 200):
            Ak1 = trop_mat_mul(A, Ak)
            if np.array_equal(Ak, Ak1):
                nondiag_stag.append(k)
                break
            Ak = Ak1
        else:
            nondiag_stag.append(200)
    
    ax.hist([diag_stag, nondiag_stag], bins=20, 
            label=['Diagonal', 'Random'], alpha=0.7,
            color=['coral', 'steelblue'], edgecolor='black')
    ax.set_xlabel('Stagnation Index', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Diagonal vs Random: Stagnation', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Plot 3: Key exchange timing
    ax = axes[1, 0]
    import time
    sizes_timing = [2, 3, 4, 5, 6, 8, 10]
    exponents = [10, 100, 1000, 10000]
    
    for k in exponents:
        times = []
        for n in sizes_timing:
            A = np.random.randint(0, 11, (n, n)).astype(float)
            t0 = time.time()
            for _ in range(5):
                result = A.copy()
                exp = k
                base = A.copy()
                I = np.full((n,n), INF)
                np.fill_diagonal(I, 0)
                result = I
                while exp > 0:
                    if exp % 2 == 1:
                        result = trop_mat_mul(result, base)
                    base = trop_mat_mul(base, base)
                    exp //= 2
            times.append((time.time() - t0) / 5 * 1000)
        ax.plot(sizes_timing, times, 'o-', linewidth=2, markersize=6, label=f'k={k}')
    
    ax.set_xlabel('Matrix Size n', fontsize=12)
    ax.set_ylabel('Time (ms)', fontsize=12)
    ax.set_title('Key Generation Time', fontsize=14)
    ax.set_yscale('log')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Trace as attack vector
    ax = axes[1, 1]
    n = 4
    A = np.random.randint(1, 6, (n, n)).astype(float)
    
    ks = list(range(1, 31))
    traces = []
    for k in ks:
        Ak = A.copy()
        I = np.full((n,n), INF)
        np.fill_diagonal(I, 0)
        result = I
        exp = k
        base = A.copy()
        while exp > 0:
            if exp % 2 == 1:
                result = trop_mat_mul(result, base)
            base = trop_mat_mul(base, base)
            exp //= 2
        traces.append(min(result[i,i] for i in range(n)))
    
    ax.plot(ks, traces, 'go-', linewidth=2, markersize=6)
    ax.plot(ks, [k * min(A[i,i] for i in range(n)) for k in ks], 
            'r--', linewidth=1.5, alpha=0.7, label='k · min(diag)')
    ax.set_xlabel('Exponent k', fontsize=12)
    ax.set_ylabel('Tropical Trace tr⊕(A^k)', fontsize=12)
    ax.set_title('Trace vs Exponent (Attack Vector)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('Tropical Cryptography: Security Analysis', fontsize=16, y=1.01)
    plt.tight_layout()
    plt.savefig('tropical_orbit_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_orbit_analysis.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Power Stagnation
Shows how tropical matrix entries converge as power k increases.
"""
import numpy as np
import matplotlib.pyplot as plt

INF = float('inf')

def trop_mat_mul(A, B):
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if A[i,k] != INF and B[k,j] != INF:
                    C[i,j] = min(C[i,j], A[i,k] + B[k,j])
    return C

def main():
    np.random.seed(42)
    n = 4
    B = 15
    A = np.random.randint(0, B+1, (n, n)).astype(float)
    
    max_k = 30
    entries = {(i,j): [] for i in range(n) for j in range(n)}
    traces = []
    
    Ak = np.full((n,n), INF)
    np.fill_diagonal(Ak, 0)  # Identity
    
    for k in range(max_k + 1):
        if k > 0:
            Ak = trop_mat_mul(A, Ak)
        for i in range(n):
            for j in range(n):
                entries[(i,j)].append(Ak[i,j] if Ak[i,j] != INF else np.nan)
        traces.append(min(Ak[i,i] for i in range(n)))
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Entry convergence
    ax = axes[0]
    ks = list(range(max_k + 1))
    colors = plt.cm.viridis(np.linspace(0, 1, n*n))
    for idx, (i,j) in enumerate([(i,j) for i in range(n) for j in range(n)]):
        vals = entries[(i,j)]
        finite_vals = [(k, v) for k, v in zip(ks, vals) if not np.isnan(v)]
        if finite_vals:
            kk, vv = zip(*finite_vals)
            ax.plot(kk, vv, color=colors[idx], alpha=0.6, linewidth=1.5,
                   label=f'({i},{j})' if idx < 6 else None)
    ax.set_xlabel('Power k', fontsize=12)
    ax.set_ylabel('Entry value (A^k)_ij', fontsize=12)
    ax.set_title('Tropical Matrix Entry Convergence', fontsize=14)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Trace convergence
    ax = axes[1]
    ax.plot(ks, traces, 'r-o', markersize=4, linewidth=2)
    ax.set_xlabel('Power k', fontsize=12)
    ax.set_ylabel('Tropical trace min_i (A^k)_ii', fontsize=12)
    ax.set_title('Tropical Trace vs Power', fontsize=14)
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Stagnation index distribution
    ax = axes[2]
    stag_indices = []
    for trial in range(200):
        A_rand = np.random.randint(0, 11, (4, 4)).astype(float)
        Ak = A_rand.copy()
        found = False
        for k in range(1, 100):
            Ak1 = trop_mat_mul(A_rand, Ak)
            if np.array_equal(Ak, Ak1):
                stag_indices.append(k)
                found = True
                break
            Ak = Ak1
        if not found:
            stag_indices.append(100)
    
    ax.hist(stag_indices, bins=range(1, max(stag_indices)+2), 
            color='steelblue', edgecolor='black', alpha=0.7)
    ax.set_xlabel('Stagnation Index k₀', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Stagnation Index Distribution\n(4×4 matrices, entries ∈ {0,...,10})', fontsize=14)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('tropical_stagnation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_stagnation.png")

if __name__ == "__main__":
    main()
