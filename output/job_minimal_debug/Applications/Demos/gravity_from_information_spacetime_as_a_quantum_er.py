"""
Holographic Polymatroids: Numerical Demonstrations

Demonstrates the key results from the Lean formalization:
1. Polymatroid rank functions and entropy quantities
2. Singleton bound verification for various codes
3. Syndrome defect computation
4. Toric code parameter families
"""

from itertools import combinations


def powerset(s):
    """Generate all subsets of a set."""
    s = list(s)
    result = []
    for r in range(len(s) + 1):
        for combo in combinations(s, r):
            result.append(frozenset(combo))
    return result


class Polymatroid:
    """A polymatroid rank function on subsets of {0, ..., n-1}."""
    
    def __init__(self, n: int, rho):
        self.n = n
        self.ground = frozenset(range(n))
        self._rho = rho
        self._verify()
    
    def rho(self, S) -> int:
        return self._rho(frozenset(S))
    
    def _verify(self):
        """Verify polymatroid axioms."""
        assert self.rho(frozenset()) == 0, "P1: rho(empty) != 0"
        subsets = powerset(self.ground)
        for S in subsets:
            assert self.rho(S) >= 0, f"P2: rho({set(S)}) = {self.rho(S)} < 0"
        for S in subsets:
            for T in subsets:
                if S <= T:
                    assert self.rho(S) <= self.rho(T), \
                        f"P3: rho({set(S)}) > rho({set(T)}) but S ⊆ T"
        for S in subsets:
            for T in subsets:
                lhs = self.rho(S) + self.rho(T)
                rhs = self.rho(S & T) + self.rho(S | T)
                assert lhs >= rhs, \
                    f"P4: rho({set(S)}) + rho({set(T)}) < rho(∩) + rho(∪)"
    
    def mutual_info(self, A, B) -> int:
        A, B = frozenset(A), frozenset(B)
        return self.rho(A) + self.rho(B) - self.rho(A | B)
    
    def cond_mutual_info(self, A, B, C) -> int:
        A, B, C = frozenset(A), frozenset(B), frozenset(C)
        return (self.rho(A | B) + self.rho(B | C)
                - self.rho(B) - self.rho(A | B | C))
    
    def syndrome_defect(self, X, Y) -> int:
        X, Y = frozenset(X), frozenset(Y)
        return self.rho(X) + self.rho(Y) - self.rho(X & Y) - self.rho(X | Y)


def trivial_polymatroid(n: int) -> Polymatroid:
    """The trivial polymatroid: rho(S) = |S|."""
    return Polymatroid(n, lambda S: len(S))


def min_rank_polymatroid(n: int, k: int) -> Polymatroid:
    """Polymatroid with rho(S) = min(|S|, k)."""
    return Polymatroid(n, lambda S: min(len(S), k))


# --- Demo 1: Basic polymatroid properties ---
print("=" * 60)
print("DEMO 1: Trivial Polymatroid on {0,1,2,3}")
print("=" * 60)

P = trivial_polymatroid(4)
A, B, C = {0}, {1}, {2}
print(f"  rho({{0}}) = {P.rho(A)}")
print(f"  rho({{0,1}}) = {P.rho({0,1})}")
print(f"  rho({{0,1,2,3}}) = {P.rho({0,1,2,3})}")
print(f"  I(A:B) = {P.mutual_info(A, B)}  (expected: 0 for trivial)")
print(f"  I(A:C|B) = {P.cond_mutual_info(A, B, C)}  (≥ 0: SSA)")
print(f"  δ(A,B) = {P.syndrome_defect(A, B)}  (= 0: flat)")

# --- Demo 2: Non-trivial polymatroid (min-rank) ---
print("\n" + "=" * 60)
print("DEMO 2: Min-Rank Polymatroid rho(S) = min(|S|, 2) on {0,1,2}")
print("=" * 60)

P2 = min_rank_polymatroid(3, 2)
print(f"  rho({{0}}) = {P2.rho({0})}")
print(f"  rho({{0,1}}) = {P2.rho({0,1})}")
print(f"  rho({{0,1,2}}) = {P2.rho({0,1,2})}")
print(f"  I({{0}}:{{1}}) = {P2.mutual_info({0}, {1})}")
print(f"  I({{0}}:{{1,2}}) = {P2.mutual_info({0}, {1,2})}")
print(f"  δ({{0,1}},{{1,2}}) = {P2.syndrome_defect({0,1}, {1,2})}")

# This is the counterexample to the quantum Singleton bound:
n, k, d = 3, 2, 2
print(f"\n  As [[{n},{k},{d}]] code:")
print(f"  Classical Singleton: k ≤ n-(d-1) = {n-(d-1)} → {k} ≤ {n-(d-1)}: {'✓' if k <= n-(d-1) else '✗'}")
print(f"  Quantum Singleton: k ≤ n-2(d-1) = {n-2*(d-1)} → {k} ≤ {n-2*(d-1)}: {'✓' if k <= n-2*(d-1) else '✗'}")
print(f"  → Quantum Singleton FAILS! This proves it can't follow from polymatroid axioms.")


# --- Demo 3: Code parameter verification ---
print("\n" + "=" * 60)
print("DEMO 3: Singleton Bound Verification")
print("=" * 60)

codes = [
    ("[[5,1,3]] Perfect", 5, 1, 3),
    ("[[7,1,3]] Steane", 7, 1, 3),
    ("[[9,1,3]] Shor", 9, 1, 3),
    ("[[23,1,7]] Golay", 23, 1, 7),
]

for name, n, k, d in codes:
    satisfies = 2*d + k <= n + 2
    is_mds = 2*d + k == n + 2
    redundancy = n - k
    min_redundancy = 2*(d-1)
    excess = redundancy - min_redundancy
    print(f"  {name}: 2d+k = {2*d+k}, n+2 = {n+2}, "
          f"Singleton: {'✓' if satisfies else '✗'}, "
          f"MDS: {'✓' if is_mds else '✗'}, "
          f"excess redundancy: {excess}")


# --- Demo 4: Toric code family ---
print("\n" + "=" * 60)
print("DEMO 4: Toric Code Family [[2L², 2, L]]")
print("=" * 60)

print(f"  {'L':>3} | {'n':>6} | {'k':>3} | {'d':>4} | {'2d+k':>5} | {'n+2':>5} | {'Sing':>4} | {'MDS':>3} | {'d²≤n':>5}")
print("  " + "-" * 55)
for L in range(2, 11):
    n, k, d = 2*L**2, 2, L
    sing = 2*d + k <= n + 2
    mds = 2*d + k == n + 2
    bpt = d**2 <= n
    print(f"  {L:3d} | {n:6d} | {k:3d} | {d:4d} | {2*d+k:5d} | {n+2:5d} | {'✓':>4} | {'✓' if mds else '✗':>3} | {'✓' if bpt else '✗':>5}")


# --- Demo 5: Syndrome defect as curvature ---
print("\n" + "=" * 60)
print("DEMO 5: Syndrome Defect (Curvature)")
print("=" * 60)

# A polymatroid modeling entanglement: rho(S) = min(|S|, k)
P3 = min_rank_polymatroid(4, 2)
pairs = [({0}, {1}), ({0,1}, {2,3}), ({0}, {1,2}), ({0,1}, {1,2})]
for X, Y in pairs:
    d = P3.syndrome_defect(X, Y)
    print(f"  δ({set(X)}, {set(Y)}) = {d}  {'(flat)' if d == 0 else '(curved)'}")

# --- Demo 6: BH entropy as Singleton ---
print("\n" + "=" * 60)
print("DEMO 6: Bekenstein-Hawking as Singleton Bound")
print("=" * 60)

for L in [8, 12, 16, 20, 100]:
    n = L  # area in Planck units
    k = L // 4  # BH entropy
    d = L // 4 + 1  # code distance
    sing = 2*d + k <= n + 2
    print(f"  L={L:3d}: n={n}, k=S_BH={k}, d={d}, "
          f"2d+k={2*d+k} ≤ n+2={n+2}: {'✓' if sing else '✗'}")


print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


"""
Visualization: Singleton Bound and Code Parameters

Creates a plot of the Singleton bound k + 2d ≤ n + 2 for various codes,
showing the information-protection tradeoff.
"""

import matplotlib.pyplot as plt
import numpy as np


def plot_singleton_bound():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # --- Left panel: (k/n, d/n) tradeoff ---
    ax = axes[0]
    
    # Singleton boundary: k/n + 2d/n = 1 + 2/n ≈ 1 for large n
    rate = np.linspace(0, 1, 100)
    rel_dist = (1 - rate) / 2
    ax.plot(rate, rel_dist, 'k-', linewidth=2, label='Singleton bound')
    ax.fill_between(rate, 0, rel_dist, alpha=0.1, color='blue',
                    label='Feasible region')
    
    # Plot specific codes
    codes = {
        '[[5,1,3]]': (1/5, 3/5),
        '[[7,1,3]]': (1/7, 3/7),
        '[[9,1,3]]': (1/9, 3/9),
    }
    for name, (r, d) in codes.items():
        ax.plot(r, d, 'ro', markersize=8)
        ax.annotate(name, (r, d), textcoords="offset points",
                   xytext=(5, 5), fontsize=9)
    
    # Toric codes
    for L in range(2, 8):
        n, k, d = 2*L**2, 2, L
        r, rd = k/n, d/n
        ax.plot(r, rd, 'bs', markersize=6)
        if L <= 4:
            ax.annotate(f'Toric L={L}', (r, rd), textcoords="offset points",
                       xytext=(5, -10), fontsize=8, color='blue')
    
    ax.set_xlabel('Code rate k/n', fontsize=12)
    ax.set_ylabel('Relative distance d/n', fontsize=12)
    ax.set_title('Information-Protection Tradeoff\n(Singleton Bound)', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 0.55)
    ax.grid(True, alpha=0.3)
    
    # --- Right panel: Toric code scaling ---
    ax = axes[1]
    Ls = np.arange(2, 20)
    ns = 2 * Ls**2
    ds = Ls
    ks = np.full_like(Ls, 2)
    
    ax.plot(ns, ds, 'b-o', label='d = L', markersize=5)
    ax.plot(ns, np.sqrt(ns), 'r--', label='d = √n', linewidth=2)
    ax.plot(ns, ns/2, 'g:', label='d = n/2 (theoretical max)', linewidth=1)
    
    ax.set_xlabel('Physical qubits n', fontsize=12)
    ax.set_ylabel('Code distance d', fontsize=12)
    ax.set_title('Toric Code Distance Scaling\n(BPT Bound: d² ≤ n)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('singleton_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: singleton_bound.png")


def plot_syndrome_defect():
    """Plot syndrome defect for a family of polymatroids."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    # For the min-rank polymatroid rho(S) = min(|S|, k) on n elements
    ns = range(3, 12)
    for k in [1, 2, 3, 4]:
        defects = []
        for n in ns:
            # Average syndrome defect over all pairs of singleton sets
            total_defect = 0
            count = 0
            for i in range(n):
                for j in range(i+1, n):
                    X = frozenset([i])
                    Y = frozenset([j])
                    rho = lambda S, k=k: min(len(S), k)
                    d = rho(X) + rho(Y) - rho(X & Y) - rho(X | Y)
                    total_defect += d
                    count += 1
            defects.append(total_defect / count if count > 0 else 0)
        ax.plot(list(ns), defects, '-o', label=f'k={k}', markersize=5)
    
    ax.set_xlabel('Ground set size n', fontsize=12)
    ax.set_ylabel('Average syndrome defect δ', fontsize=12)
    ax.set_title('Syndrome Defect (Curvature) vs System Size\nMin-rank polymatroid ρ(S) = min(|S|, k)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('syndrome_defect.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: syndrome_defect.png")


if __name__ == "__main__":
    plot_singleton_bound()
    plot_syndrome_defect()
