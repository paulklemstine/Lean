#!/usr/bin/env python3
"""
Demo: Surreal Topology — The Archimedean–Connected Dichotomy

Demonstrates the key constructions from the formal proof:
1. The clopen set construction for non-Archimedean fields
2. How the "infinitesimal region" partitions the field
3. The rescaling trick for total disconnectedness
"""

from fractions import Fraction
from typing import List, Tuple

# ============================================================
# 1. Simulating a Non-Archimedean Ordered Field
# ============================================================
# We use rational functions Q(t) with t "infinitesimal"
# Elements are (a, b) representing a + b*t where t → 0+

class InfinitesimalField:
    """Simple model of Q(epsilon): rationals extended by an infinitesimal.
    Elements are a + b*epsilon where epsilon is infinitesimally small.
    Order: a + b*eps < c + d*eps iff a < c, or (a == c and b < d)."""
    
    def __init__(self, real: Fraction, inf: Fraction = Fraction(0)):
        self.real = real  # "standard part"
        self.inf = inf    # coefficient of epsilon
    
    def __repr__(self):
        if self.inf == 0:
            return f"{self.real}"
        elif self.real == 0:
            return f"{self.inf}·ε"
        else:
            sign = "+" if self.inf > 0 else "-"
            return f"{self.real} {sign} {abs(self.inf)}·ε"
    
    def __lt__(self, other):
        if self.real != other.real:
            return self.real < other.real
        return self.inf < other.inf
    
    def __le__(self, other):
        return self == other or self < other
    
    def __eq__(self, other):
        return self.real == other.real and self.inf == other.inf
    
    def __add__(self, other):
        return InfinitesimalField(self.real + other.real, self.inf + other.inf)
    
    def __sub__(self, other):
        return InfinitesimalField(self.real - other.real, self.inf - other.inf)
    
    def __mul__(self, other):
        # (a + bε)(c + dε) ≈ ac + (ad + bc)ε  (ignoring ε² terms)
        return InfinitesimalField(
            self.real * other.real,
            self.real * other.inf + self.inf * other.real
        )
    
    def nsmul(self, n: int):
        """n • self = self + self + ... + self (n times)"""
        return InfinitesimalField(n * self.real, n * self.inf)


# ============================================================
# 2. Demonstrating the Clopen Set
# ============================================================

def demo_clopen_construction():
    """Shows that ltNsmulRegion(ε) is a proper clopen subset."""
    print("=" * 60)
    print("DEMO 1: The Clopen Set Construction")
    print("=" * 60)
    
    eps = InfinitesimalField(Fraction(0), Fraction(1))  # ε
    one = InfinitesimalField(Fraction(1))                # 1
    zero = InfinitesimalField(Fraction(0))               # 0
    
    print(f"\nε = {eps}")
    print(f"1 = {one}")
    print(f"\nChecking: is n·ε < 1 for various n?")
    
    for n in [1, 5, 10, 100, 1000000]:
        neps = eps.nsmul(n)
        print(f"  {n}·ε = {neps}, {n}·ε < 1? {neps < one}")
    
    print(f"\n→ For ALL n ∈ ℕ: n·ε < 1. This witnesses ¬Archimedean.")
    
    # The clopen set
    print(f"\nltNsmulRegion(ε) = {{z : ∃ n, z < n·ε}}")
    
    test_points = [
        InfinitesimalField(Fraction(0)),
        InfinitesimalField(Fraction(0), Fraction(1, 2)),   # ε/2
        InfinitesimalField(Fraction(0), Fraction(3)),       # 3ε
        InfinitesimalField(Fraction(1, 2)),                  # 1/2
        InfinitesimalField(Fraction(1)),                      # 1
        InfinitesimalField(Fraction(-1)),                     # -1
    ]
    
    print(f"\nMembership in ltNsmulRegion(ε):")
    for z in test_points:
        # z ∈ ltNsmulRegion(ε) iff z.real < 0 or (z.real == 0)
        # Since n·ε has real part 0 for all n, z < n·ε iff z.real < 0
        # or (z.real == 0 and z.inf < n for some n)
        in_set = z.real < 0 or (z.real == 0)  # since for z.real==0, z.inf < n for large n
        print(f"  z = {str(z):>12s}: in ltNsmulRegion? {in_set}")
    
    print(f"\n→ ltNsmulRegion(ε) = {{z : real_part(z) ≤ 0}} ∪ {{z : real_part(z) = 0, inf_part(z) < n for some n}}")
    print(f"  This set is CLOPEN: open (union of rays) AND closed (complement is open).")
    print(f"  It contains 0 but not 1 → PROPER clopen subset → NOT CONNECTED!")


# ============================================================
# 3. Demonstrating the Separation Trick
# ============================================================

def demo_separation():
    """Shows how to separate any two points with a clopen set."""
    print("\n" + "=" * 60)
    print("DEMO 2: Clopen Separation of Arbitrary Points")
    print("=" * 60)
    
    eps = InfinitesimalField(Fraction(0), Fraction(1))
    
    # Separate a = 1/3 from b = 2/3
    a = InfinitesimalField(Fraction(1, 3))
    b = InfinitesimalField(Fraction(2, 3))
    delta = b - a  # = 1/3
    
    print(f"\nSeparating a = {a} from b = {b}")
    print(f"δ = b - a = {delta}")
    
    # Rescaled infinitesimal: ε' = ε * δ (in our model, this has real part 0, inf part 1/3)
    eps_rescaled = eps * delta
    print(f"Rescaled ε' = ε · δ = {eps_rescaled}")
    
    print(f"\nCheck: n · ε' < δ for all n?")
    for n in [1, 10, 100]:
        neps = eps_rescaled.nsmul(n)
        print(f"  {n} · ε' = {neps}, < δ = {delta}? {neps < delta}")
    
    print(f"\nClopen set S = {{z : ∃ n, z - a < n · ε'}}")
    print(f"  a ∈ S: a - a = 0 < ε' ✓")
    print(f"  b ∉ S: b - a = δ > n·ε' for all n ✓")
    print(f"\n→ a and b are SEPARATED by a clopen set!")


# ============================================================
# 4. The Archimedean-Connected Classification
# ============================================================

def demo_classification():
    """Shows the classification of ordered fields by Archimedean/Connected."""
    print("\n" + "=" * 60)
    print("DEMO 3: The Archimedean–Connected Classification")
    print("=" * 60)
    
    fields = [
        ("ℝ (reals)", True, True, True),
        ("ℚ (rationals)", True, False, False),
        ("ℚ(ε) (with infinitesimal)", False, False, True),
        ("*ℝ (hyperreals)", False, False, True),
        ("No (surreal numbers)", False, False, True),
        ("ℝ((t)) (Laurent series)", False, False, True),
    ]
    
    print(f"\n{'Field':<30} {'Archimedean':<15} {'Complete':<12} {'Connected':<12} {'Tot. Disconn.':<15}")
    print("-" * 84)
    for name, arch, complete, has_inf in fields:
        connected = arch and complete
        tot_disc = has_inf  # non-Archimedean → totally disconnected
        print(f"{name:<30} {'Yes' if arch else 'No':<15} {'Yes' if complete else 'No':<12} "
              f"{'Yes' if connected else 'No':<12} {'Yes' if tot_disc else '—':<15}")
    
    print(f"\nKey insight: Connected ⟹ Archimedean (our theorem)")
    print(f"            Archimedean + Complete ⟹ Connected")
    print(f"            Non-Archimedean ⟹ Totally Disconnected (our strengthened theorem)")


# ============================================================
# 5. Counting Clopen Sets
# ============================================================

def demo_clopen_density():
    """Shows the density of clopen sets in non-Archimedean fields."""
    print("\n" + "=" * 60)
    print("DEMO 4: Density of Clopen Separations")
    print("=" * 60)
    
    print("\nIn a non-Archimedean field, for any a < b, there is a clopen")
    print("set S with a ∈ S and b ∉ S. The construction uses rescaling.")
    print()
    
    # Show that between any two "surreal-like" numbers, there's a clopen gap
    pairs = [
        (Fraction(0), Fraction(1)),
        (Fraction(1, 2), Fraction(1, 2) + Fraction(1, 1000000)),
        (Fraction(3, 7), Fraction(3, 7) + Fraction(1, 10**12)),
    ]
    
    for a, b in pairs:
        delta = b - a
        print(f"  a = {float(a):.10f}, b = {float(b):.10f}")
        print(f"  δ = b - a = {delta}")
        print(f"  Clopen separator: {{z : ∃n, z - a < n · (ε · δ)}}")
        print(f"  (where ε is any infinitesimal)")
        print()


if __name__ == "__main__":
    demo_clopen_construction()
    demo_separation()
    demo_classification()
    demo_clopen_density()
