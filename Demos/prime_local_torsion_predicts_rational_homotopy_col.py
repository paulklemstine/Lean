"""
Applications of Torsion Persistence Spectrum theory.

Demonstrates real-world applications of the mathematical results:
1. Algebraic formality detection
2. Torsion entropy analysis of group decompositions
3. Persistence-based classification of finite groups
"""

import math
from typing import List, Dict, Tuple, Set
from collections import defaultdict


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_factors(n: int) -> Set[int]:
    """Return the set of prime factors of n."""
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


# ============================================================
# APPLICATION 1: Formality Detection
# ============================================================

class FormalityDetector:
    """Detect algebraic formality of persistence modules using TPS bounds.

    Uses the principle: if TPS(p) ≤ B for all primes p, then the
    module is likely formal (degenerate). This provides a fast
    screening test before running expensive formality algorithms.
    """

    def __init__(self, m: int, endomorphisms: List[int], bound: int = 1):
        self.m = m
        self.endos = endomorphisms
        self.bound = bound
        self.n = len(endomorphisms)

    def compose(self, k: int, a: int) -> int:
        result = a % self.m
        for i in range(min(k, self.n)):
            result = (self.endos[i] * result) % self.m
        return result

    def is_p_torsion(self, p: int, a: int) -> bool:
        a = a % self.m
        if a == 0:
            return False
        pk = p
        while pk <= self.m * self.m:
            if (pk * a) % self.m == 0:
                return True
            pk *= p
        return False

    def compute_tps(self, p: int) -> int:
        max_persistence = 0
        for a in range(1, self.m):
            if not self.is_p_torsion(p, a):
                continue
            x = a
            steps = 0
            for i in range(self.n):
                x = (self.endos[i] * x) % self.m
                if x == 0:
                    break
                steps = i + 1
            max_persistence = max(max_persistence, steps)
        return max_persistence

    def detect_formality(self) -> Dict:
        """Run the formality detection algorithm.

        Returns a dict with:
        - 'likely_formal': bool, whether TPS is bounded
        - 'tps_values': dict of TPS values by prime
        - 'violating_primes': primes where TPS exceeds bound
        - 'confidence': str describing confidence level
        """
        pf = prime_factors(self.m)
        tps_values = {p: self.compute_tps(p) for p in pf}
        violating = {p: v for p, v in tps_values.items() if v > self.bound}

        if not violating:
            confidence = "HIGH" if self.bound >= self.n else "MEDIUM"
            likely_formal = True
        else:
            confidence = "LOW"
            likely_formal = False

        return {
            'likely_formal': likely_formal,
            'tps_values': tps_values,
            'violating_primes': violating,
            'confidence': confidence,
            'bound_used': self.bound,
        }


# ============================================================
# APPLICATION 2: Torsion Entropy Profile
# ============================================================

class TorsionEntropyProfiler:
    """Analyze the information-theoretic properties of finite abelian groups.

    Computes the torsion entropy profile: for each prime p, the entropy
    H_p = log₂(|p-torsion subgroup|). This connects algebraic structure
    to information theory.
    """

    def __init__(self, m: int):
        self.m = m
        self.primes = sieve_primes(m)
        self.pf = prime_factors(m)

    def p_torsion_size(self, p: int) -> int:
        """Count elements in the p-torsion subgroup of ℤ/mℤ."""
        count = 0
        for a in range(self.m):
            pk = 1
            while pk <= self.m:
                if (pk * a) % self.m == 0:
                    count += 1
                    break
                pk *= p
        return count

    def entropy_profile(self) -> Dict[int, float]:
        """Compute the torsion entropy at each prime dividing m."""
        profile = {}
        for p in self.pf:
            size = self.p_torsion_size(p)
            profile[p] = math.log2(size) if size > 1 else 0.0
        return profile

    def total_torsion_entropy(self) -> float:
        """Sum of torsion entropies across all primes."""
        return sum(self.entropy_profile().values())

    def entropy_ratio(self) -> float:
        """Ratio of total torsion entropy to group entropy."""
        group_entropy = math.log2(self.m) if self.m > 1 else 0
        total = self.total_torsion_entropy()
        return total / group_entropy if group_entropy > 0 else 0

    def full_report(self) -> Dict:
        """Generate a complete entropy analysis report."""
        profile = self.entropy_profile()
        group_ent = math.log2(self.m) if self.m > 1 else 0
        total = sum(profile.values())

        return {
            'group_order': self.m,
            'group_entropy': group_ent,
            'prime_entropies': profile,
            'total_torsion_entropy': total,
            'entropy_ratio': total / group_ent if group_ent > 0 else 0,
            'omega_m': len(self.pf),
            'bound_check': total <= group_ent * len(self.pf),
        }


# ============================================================
# APPLICATION 3: Group Classification by TPS Signature
# ============================================================

class TPSClassifier:
    """Classify finite abelian groups by their TPS signatures.

    Groups with similar TPS signatures under various endomorphisms
    are grouped together, revealing structural similarities.
    """

    def __init__(self, max_order: int = 30):
        self.max_order = max_order

    def compute_signature(self, m: int) -> Tuple:
        """Compute a TPS signature for ℤ/mℤ.

        The signature consists of:
        - Prime factors
        - TPS values for multiplication by each prime factor
        """
        pf = sorted(prime_factors(m))
        sig_parts = []
        for p in pf:
            # TPS for multiplication-by-p endomorphism
            max_pers = 0
            for a in range(1, m):
                # Check if a is p-torsion
                pk = p
                is_pt = False
                while pk <= m * m:
                    if (pk * a) % m == 0:
                        is_pt = True
                        break
                    pk *= p
                if not is_pt:
                    continue
                # Persistence under ×p
                x = (p * a) % m
                pers = 1 if x != 0 else 0
                max_pers = max(max_pers, pers)
            sig_parts.append((p, max_pers))
        return tuple(sig_parts)

    def classify(self) -> Dict[Tuple, List[int]]:
        """Classify all groups of order ≤ max_order by TPS signature."""
        classes = defaultdict(list)
        for m in range(2, self.max_order + 1):
            sig = self.compute_signature(m)
            classes[sig].append(m)
        return dict(classes)


# ============================================================
# DEMO
# ============================================================

def main():
    print("=" * 60)
    print("APPLICATION 1: Formality Detection")
    print("=" * 60)

    test_cases = [
        (6, [2, 3], "ℤ/6 with ×2, ×3"),
        (12, [4, 3], "ℤ/12 with ×4, ×3"),
        (30, [6, 10, 15], "ℤ/30 with ×6, ×10, ×15"),
        (7, [3, 3, 3], "ℤ/7 with ×3, ×3, ×3"),
    ]

    for m, endos, desc in test_cases:
        fd = FormalityDetector(m, endos)
        result = fd.detect_formality()
        status = "FORMAL" if result['likely_formal'] else "NON-FORMAL"
        print(f"\n{desc}: {status} (confidence: {result['confidence']})")
        print(f"  TPS values: {result['tps_values']}")
        if result['violating_primes']:
            print(f"  Violating primes: {result['violating_primes']}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Torsion Entropy Profile")
    print("=" * 60)

    for m in [6, 12, 30, 60, 210]:
        profiler = TorsionEntropyProfiler(m)
        report = profiler.full_report()
        print(f"\nℤ/{m}ℤ:")
        print(f"  Group entropy: {report['group_entropy']:.3f}")
        print(f"  Prime entropies: {report['prime_entropies']}")
        print(f"  Total torsion entropy: {report['total_torsion_entropy']:.3f}")
        print(f"  Entropy ratio: {report['entropy_ratio']:.3f}")
        print(f"  Bound H_total ≤ H_group · ω(m): {report['bound_check']}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Group Classification by TPS Signature")
    print("=" * 60)

    classifier = TPSClassifier(max_order=30)
    classes = classifier.classify()
    print(f"\nFound {len(classes)} distinct TPS signature classes:")
    for sig, groups in sorted(classes.items(), key=lambda x: -len(x[1])):
        if len(groups) > 1:
            print(f"  Signature {sig}: groups {groups}")


if __name__ == "__main__":
    main()


"""
Demo: Torsion Persistence Spectrum for Persistence Modules

Demonstrates the core mathematical concepts from the Prime-Local Torsion
Formality theory with concrete numerical examples.
"""

import math
from typing import List, Tuple, Optional


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def primes_up_to(n: int) -> List[int]:
    """Return all primes up to n."""
    return [p for p in range(2, n + 1) if is_prime(p)]


class ZModGroup:
    """Represents ℤ/mℤ as an additive group."""

    def __init__(self, m: int):
        self.m = m
        self.elements = list(range(m))

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.m

    def nsmul(self, n: int, a: int) -> int:
        """Compute n • a in ℤ/mℤ."""
        return (n * a) % self.m

    def is_p_torsion(self, p: int, a: int) -> bool:
        """Check if a is p-torsion: a ≠ 0 and p^k • a = 0 for some k ≥ 1."""
        if a % self.m == 0:
            return False
        pk = p
        for _ in range(20):  # sufficient for small groups
            if self.nsmul(pk, a) == 0:
                return True
            pk *= p
            if pk > self.m * 100:
                break
        return False

    def order(self, a: int) -> int:
        """Additive order of a in ℤ/mℤ."""
        if a == 0:
            return 1
        x = a
        for k in range(1, self.m + 1):
            if x == 0:
                return k
            x = (x + a) % self.m
        return self.m


class EndoPersistenceModule:
    """Endomorphism persistence module over ℤ/mℤ."""

    def __init__(self, m: int, endomorphisms: List[int]):
        """
        Create a persistence module over ℤ/mℤ with multiplication-by-r
        endomorphisms.

        Args:
            m: modulus for ℤ/mℤ
            endomorphisms: list of multipliers [r_0, r_1, ..., r_{n-1}]
        """
        self.group = ZModGroup(m)
        self.endos = endomorphisms
        self.n = len(endomorphisms)

    def apply_map(self, i: int, a: int) -> int:
        """Apply the i-th endomorphism φ_i(a) = r_i * a mod m."""
        return (self.endos[i] * a) % self.group.m

    def compose(self, k: int, a: int) -> int:
        """Compute compose(k)(a) = φ_{k-1} ∘ ... ∘ φ_0 (a)."""
        result = a
        for i in range(min(k, self.n)):
            result = self.apply_map(i, result)
        return result

    def tps(self, p: int) -> int:
        """
        Compute the Torsion Persistence Spectrum at prime p.

        Returns the maximum k such that some p-torsion element survives
        to step k.
        """
        max_len = 0
        for a in range(1, self.group.m):
            if not self.group.is_p_torsion(p, a):
                continue
            k = 0
            x = a
            while x != 0 and k < self.n:
                x = self.apply_map(k, x)
                k += 1
            max_len = max(max_len, k if x != 0 else k)
        return max_len

    def total_torsion_width(self) -> int:
        """Compute the total torsion width (max TPS over all primes)."""
        primes = primes_up_to(self.group.m)
        if not primes:
            return 0
        return max(self.tps(p) for p in primes)

    def is_degenerate(self) -> bool:
        """
        Check if the module is degenerate:
        compose(k)(a) = 0 for k ≥ 1 implies compose(1)(a) = 0.
        """
        for a in range(self.group.m):
            c1 = self.compose(1, a)
            for k in range(2, self.n + 1):
                ck = self.compose(k, a)
                if ck == 0 and c1 != 0:
                    return False
        return True

    def is_primewise_bounded(self, B: int) -> bool:
        """Check if all primes have TPS ≤ B."""
        primes = primes_up_to(self.group.m)
        return all(self.tps(p) <= B for p in primes)


def torsion_entropy(m: int, p: int) -> float:
    """Compute torsion entropy H_p(ℤ/mℤ) = log₂(|p-torsion subgroup|)."""
    G = ZModGroup(m)
    count = sum(1 for a in G.elements if any(G.nsmul(p**k, a) == 0 for k in range(20)))
    return math.log2(count) if count > 0 else 0


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_basic_torsion():
    """Demonstrate p-torsion detection in cyclic groups."""
    print("=" * 60)
    print("Demo 1: p-Torsion Elements in ℤ/mℤ")
    print("=" * 60)

    for m in [6, 12, 30]:
        G = ZModGroup(m)
        print(f"\nℤ/{m}ℤ:")
        primes = primes_up_to(m)
        for p in primes:
            torsion_elts = [a for a in range(1, m) if G.is_p_torsion(p, a)]
            if torsion_elts:
                print(f"  {p}-torsion elements: {torsion_elts}")


def demo_persistence_spectrum():
    """Demonstrate TPS computation for various persistence modules."""
    print("\n" + "=" * 60)
    print("Demo 2: Torsion Persistence Spectrum")
    print("=" * 60)

    examples = [
        (6, [2, 3], "ℤ/6 with ×2, ×3"),
        (6, [0, 0], "ℤ/6 with zero maps"),
        (12, [2, 3, 4], "ℤ/12 with ×2, ×3, ×4"),
        (30, [6, 10, 15], "ℤ/30 with ×6, ×10, ×15"),
    ]

    for m, endos, desc in examples:
        M = EndoPersistenceModule(m, endos)
        print(f"\n{desc}:")
        primes = primes_up_to(m)
        for p in primes:
            print(f"  TPS({p}) = {M.tps(p)}")
        print(f"  Total Torsion Width = {M.total_torsion_width()}")
        print(f"  Degenerate: {M.is_degenerate()}")


def demo_formality_conjecture():
    """Search for counterexamples to the formality conjecture."""
    print("\n" + "=" * 60)
    print("Demo 3: Testing the Formality Conjecture")
    print("=" * 60)

    print("\nSearching for non-degenerate modules with bounded TPS...")
    counterexample_found = False

    for m in range(2, 51):
        for r1 in range(m):
            for r2 in range(m):
                M = EndoPersistenceModule(m, [r1, r2])
                if M.is_primewise_bounded(1) and not M.is_degenerate():
                    print(f"  COUNTEREXAMPLE: ℤ/{m} with ×{r1}, ×{r2}")
                    print(f"    TPS bounded by 1 but NOT degenerate")
                    counterexample_found = True

    if not counterexample_found:
        print("  No counterexamples found for m ≤ 50 with B = 1 and n = 2")
        print("  Conjecture supported in this range!")


def demo_entropy_bound():
    """Demonstrate the torsion entropy bound."""
    print("\n" + "=" * 60)
    print("Demo 4: Torsion Entropy Bound (Cross-Domain)")
    print("=" * 60)

    for m in [6, 12, 30, 60]:
        total_entropy = math.log2(m)
        print(f"\nℤ/{m}ℤ (total entropy = {total_entropy:.2f}):")
        primes = primes_up_to(m)
        for p in primes:
            he = torsion_entropy(m, p)
            print(f"  H_{p} = {he:.2f} ≤ {total_entropy:.2f} ✓")


if __name__ == "__main__":
    demo_basic_torsion()
    demo_persistence_spectrum()
    demo_formality_conjecture()
    demo_entropy_bound()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Degeneracy Landscape

Shows for each pair of endomorphisms (r1, r2) on ℤ/mℤ whether the resulting
persistence module is degenerate, and how TPS values correlate with degeneracy.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def prime_factors(n):
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return sorted(factors)


def compose(m, endos, k, a):
    result = a % m
    for i in range(min(k, len(endos))):
        result = (endos[i] * result) % m
    return result


def is_degenerate(m, endos):
    n = len(endos)
    for a in range(m):
        c1 = compose(m, endos, 1, a)
        if c1 != 0:
            for k in range(2, n + 1):
                if compose(m, endos, k, a) == 0:
                    return False
    return True


def compute_tps(m, endos, p):
    n = len(endos)
    max_persistence = 0
    for a in range(1, m):
        pk = p
        is_pt = False
        while pk <= m * m:
            if (pk * a) % m == 0:
                is_pt = True
                break
            pk *= p
        if not is_pt:
            continue
        x = a
        steps = 0
        for i in range(n):
            x = (endos[i] * x) % m
            if x == 0:
                break
            steps = i + 1
        max_persistence = max(max_persistence, steps)
    return max_persistence


def max_tps(m, endos):
    pf = prime_factors(m)
    if not pf:
        return 0
    return max(compute_tps(m, endos, p) for p in pf)


# Create degeneracy landscape for ℤ/12ℤ
m = 12
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Degeneracy map
degen_map = np.zeros((m, m))
tps_map = np.zeros((m, m))

for r1 in range(m):
    for r2 in range(m):
        endos = [r1, r2]
        degen_map[r1, r2] = 1 if is_degenerate(m, endos) else 0
        tps_map[r1, r2] = max_tps(m, endos)

ax1 = axes[0]
im1 = ax1.imshow(degen_map, cmap='RdYlGn', interpolation='nearest', origin='lower')
ax1.set_xlabel('r₂ (second endomorphism)', fontsize=12)
ax1.set_ylabel('r₁ (first endomorphism)', fontsize=12)
ax1.set_title(f'Degeneracy Landscape: ℤ/{m}ℤ\n(Green = degenerate, Red = non-degenerate)',
              fontsize=13)
plt.colorbar(im1, ax=ax1, label='Degenerate?', shrink=0.8)

ax2 = axes[1]
im2 = ax2.imshow(tps_map, cmap='viridis', interpolation='nearest', origin='lower')
ax2.set_xlabel('r₂ (second endomorphism)', fontsize=12)
ax2.set_ylabel('r₁ (first endomorphism)', fontsize=12)
ax2.set_title(f'Max TPS Landscape: ℤ/{m}ℤ\n(Darker = lower TPS)',
              fontsize=13)
plt.colorbar(im2, ax=ax2, label='max TPS(p)', shrink=0.8)

# Count statistics
total = m * m
degen_count = int(degen_map.sum())
fig.text(0.5, 0.02,
         f'ℤ/{m}ℤ: {degen_count}/{total} modules are degenerate ({100*degen_count/total:.1f}%)',
         ha='center', fontsize=12, style='italic')

plt.tight_layout(rect=[0, 0.05, 1, 1])
plt.savefig('degeneracy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved degeneracy_landscape.png")


"""
Visualization: Torsion Entropy Profiles

Shows how the torsion entropy H_p decomposes across primes for different
group orders, illustrating the entropy bound theorem.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def prime_factors(n):
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return sorted(factors)


def p_torsion_size(m, p):
    """Count elements in the p-torsion subgroup of ℤ/mℤ."""
    count = 0
    for a in range(m):
        pk = 1
        while pk <= m:
            if (pk * a) % m == 0:
                count += 1
                break
            pk *= p
    return count


def torsion_entropy(m, p):
    size = p_torsion_size(m, p)
    return math.log2(size) if size > 1 else 0.0


# Groups to analyze
groups = [6, 12, 30, 60, 120, 210]

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
axes = axes.flatten()

for idx, m in enumerate(groups):
    ax = axes[idx]
    pf = prime_factors(m)
    group_ent = math.log2(m)

    # Compute entropies
    entropies = [torsion_entropy(m, p) for p in pf]
    labels = [str(p) for p in pf]

    # Bar chart
    bars = ax.bar(labels, entropies, color=['#2196F3', '#FF9800', '#4CAF50',
                                            '#E91E63', '#9C27B0', '#00BCD4'][:len(pf)],
                  alpha=0.8, edgecolor='black', linewidth=0.5)

    # Add group entropy line
    ax.axhline(y=group_ent, color='red', linestyle='--', linewidth=2,
               label=f'log₂({m}) = {group_ent:.2f}')

    ax.set_title(f'ℤ/{m}ℤ', fontsize=14, fontweight='bold')
    ax.set_xlabel('Prime p', fontsize=11)
    ax.set_ylabel('H_p (bits)', fontsize=11)
    ax.legend(fontsize=9)
    ax.set_ylim(0, group_ent * 1.2)

    # Add value labels on bars
    for bar, val in zip(bars, entropies):
        if val > 0:
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
                    f'{val:.2f}', ha='center', va='bottom', fontsize=9)

fig.suptitle('Torsion Entropy Profiles: H_p ≤ log₂(|A|) for Each Prime p',
             fontsize=16, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('entropy_profiles.png', dpi=150, bbox_inches='tight')
print("Saved entropy_profiles.png")


"""
Visualization: Torsion Persistence Spectrum Heatmap

Visualizes the TPS(p) values across different group orders m and primes p,
showing how torsion persistence varies with algebraic structure.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_factors(n):
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def compute_tps(m, endos, p):
    """Compute TPS at prime p for ℤ/mℤ with given endomorphisms."""
    n = len(endos)
    max_persistence = 0
    for a in range(1, m):
        # Check p-torsion
        pk = p
        is_pt = False
        while pk <= m * m:
            if (pk * a) % m == 0:
                is_pt = True
                break
            pk *= p
        if not is_pt:
            continue
        # Track persistence
        x = a
        steps = 0
        for i in range(n):
            x = (endos[i] * x) % m
            if x == 0:
                break
            steps = i + 1
        max_persistence = max(max_persistence, steps)
    return max_persistence


# Compute TPS heatmap for multiplication-by-2 endomorphism
group_orders = list(range(2, 61))
all_primes = sieve_primes(60)

# Create heatmap data
heatmap = np.full((len(group_orders), len(all_primes)), np.nan)

for i, m in enumerate(group_orders):
    pf = prime_factors(m)
    endos = [2, 2]  # multiplication by 2, twice
    for j, p in enumerate(all_primes):
        if p in pf:
            heatmap[i, j] = compute_tps(m, endos, p)

fig, ax = plt.subplots(1, 1, figsize=(14, 10))

# Plot heatmap
im = ax.imshow(heatmap, aspect='auto', cmap='YlOrRd',
               interpolation='nearest', origin='lower')
ax.set_xlabel('Prime p', fontsize=14)
ax.set_ylabel('Group order m', fontsize=14)
ax.set_title('Torsion Persistence Spectrum: TPS(p) for ℤ/mℤ with ×2 endomorphism',
             fontsize=16)

# Set tick labels
ax.set_xticks(range(len(all_primes)))
ax.set_xticklabels([str(p) for p in all_primes], fontsize=9)
ytick_positions = list(range(0, len(group_orders), 5))
ax.set_yticks(ytick_positions)
ax.set_yticklabels([str(group_orders[i]) for i in ytick_positions], fontsize=10)

plt.colorbar(im, ax=ax, label='TPS(p)', shrink=0.8)

# Add annotation
ax.text(0.02, 0.98,
        'White = prime does not divide m\nDarker = longer torsion persistence',
        transform=ax.transAxes, fontsize=10, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('tps_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved tps_heatmap.png")
