#!/usr/bin/env python3
"""
algorithms.py — Algorithms for computing and analyzing subgroup pressure.

Implements the core algorithms from the pressure theory:
1. Family pressure computation from subgroup data
2. Entropy-energy bound evaluation
3. Pressure admissibility checking
4. Generation probability estimation
"""

import math
from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass
class SubgroupClass:
    """A class of subgroups with given count and index."""
    name: str
    count: int
    index: int
    
    def pressure(self) -> float:
        """Pressure contribution: count / index²."""
        if self.index == 0:
            return float('inf')
        return self.count / (self.index ** 2)
    
    def __repr__(self) -> str:
        return f"SubgroupClass({self.name}, count={self.count}, index={self.index})"


@dataclass
class PressureProfile:
    """Complete pressure profile for a group with classified subgroups."""
    group_name: str
    group_order: int
    classes: List[SubgroupClass]
    
    def total_pressure(self) -> float:
        """Total family pressure = ∑ class pressures."""
        return sum(c.pressure() for c in self.classes)
    
    def total_count(self) -> int:
        """Total number of maximal subgroups."""
        return sum(c.count for c in self.classes)
    
    def min_index(self) -> int:
        """Minimum index across all classes."""
        if not self.classes:
            return 0
        return min(c.index for c in self.classes)
    
    def dominant_class(self) -> Optional[SubgroupClass]:
        """The class contributing most to pressure."""
        if not self.classes:
            return None
        return max(self.classes, key=lambda c: c.pressure())
    
    def generation_probability_lower_bound(self) -> float:
        """Lower bound on P[random pair generates G] = 1 - pressure."""
        return max(0.0, 1.0 - self.total_pressure())
    
    def entropy_exponent(self) -> float:
        """Estimated entropy exponent a: |F| ≈ |G|^a."""
        if self.group_order <= 1 or self.total_count() <= 0:
            return 0.0
        return math.log(self.total_count()) / math.log(self.group_order)
    
    def energy_exponent(self) -> float:
        """Estimated energy exponent b: min_index ≈ |G|^b."""
        if self.group_order <= 1 or self.min_index() <= 0:
            return 0.0
        return math.log(self.min_index()) / math.log(self.group_order)
    
    def pressure_exponent(self) -> float:
        """Effective pressure exponent: 2b - a."""
        return 2 * self.energy_exponent() - self.entropy_exponent()
    
    def summary(self) -> str:
        """Human-readable summary."""
        lines = [
            f"Pressure Profile: {self.group_name}",
            f"  Order: {self.group_order}",
            f"  Total subgroups: {self.total_count()}",
            f"  Min index: {self.min_index()}",
            f"  Total pressure: {self.total_pressure():.8f}",
            f"  P_gen lower bound: {self.generation_probability_lower_bound():.8f}",
            f"  Entropy exponent a: {self.entropy_exponent():.4f}",
            f"  Energy exponent b: {self.energy_exponent():.4f}",
            f"  Pressure exponent 2b-a: {self.pressure_exponent():.4f}",
            f"  Class decomposition:"
        ]
        total = self.total_pressure()
        for c in sorted(self.classes, key=lambda c: -c.pressure()):
            pct = 100 * c.pressure() / total if total > 0 else 0
            lines.append(f"    {c.name:<20} count={c.count:<8} idx={c.index:<10} "
                        f"p={c.pressure():.6e} ({pct:.1f}%)")
        return "\n".join(lines)


def entropy_energy_bound(family_card: int, min_index: int) -> float:
    """
    Entropy-energy bound: pressure ≤ |F| / D².
    
    This is the core inequality from Theorem familyPressure_le_card_div_sq.
    
    Parameters:
        family_card: Number of subgroups |F|
        min_index: Minimum index D of subgroups in the family
    
    Returns:
        Upper bound on family pressure
    
    Complexity: O(1)
    """
    if min_index <= 0:
        return float('inf')
    return family_card / (min_index ** 2)


def polynomial_decay_bound(group_order: int, family_card: int, 
                           min_index: int, a: float, b: float, 
                           C: float) -> float:
    """
    Polynomial pressure decay bound: pressure ≤ C · |G|^(a - 2b).
    
    This is the core inequality from Theorem pressure_le_of_admissible.
    
    Parameters:
        group_order: |G|
        family_card: |F| (verified ≤ C·|G|^a)
        min_index: D (verified ≥ |G|^b)
        a: Entropy exponent
        b: Energy exponent  
        C: Multiplicative constant
    
    Returns:
        Upper bound on family pressure
    
    Complexity: O(1)
    """
    if group_order <= 0:
        return float('inf')
    return C * (group_order ** (a - 2 * b))


def check_pressure_admissible(group_order: int, family_card: int,
                               min_index: int, a: float, b: float,
                               C: float) -> Tuple[bool, str]:
    """
    Check if a subgroup family is pressure-admissible with parameters (a, b, C).
    
    A family is admissible if:
    1. C ≥ 0
    2. |F| ≤ C · |G|^a
    3. min_index ≥ |G|^b
    
    Parameters:
        group_order: |G|
        family_card: |F|
        min_index: Minimum subgroup index
        a, b, C: Admissibility parameters
    
    Returns:
        (is_admissible, explanation)
    
    Complexity: O(1)
    """
    if C < 0:
        return False, f"C = {C} < 0"
    
    count_bound = C * (group_order ** a)
    if family_card > count_bound:
        return False, f"|F| = {family_card} > C·|G|^a = {count_bound:.2f}"
    
    index_bound = group_order ** b
    if min_index < index_bound:
        return False, f"min_index = {min_index} < |G|^b = {index_bound:.2f}"
    
    exponent = 2 * b - a
    return True, (f"Admissible! Pressure exponent = {exponent:.4f}. "
                  f"Bound: {C * group_order**(a - 2*b):.6e}")


def compute_psl2_profile(p: int) -> PressureProfile:
    """
    Compute the pressure profile for PSL₂(p), p odd prime.
    
    Uses the known classification of maximal subgroups of PSL₂(p).
    
    Complexity: O(1)
    """
    n = p * (p * p - 1) // 2
    classes = []
    
    # Borel subgroups
    classes.append(SubgroupClass("Borel", p + 1, p + 1))
    
    if p >= 5:
        # Dihedral (split Cartan normalizer)
        classes.append(SubgroupClass("Dihedral(p-1)", 
                                     p * (p + 1) // 2, 
                                     p * (p - 1) // 2))
        # Dihedral (non-split Cartan normalizer)  
        classes.append(SubgroupClass("Dihedral(p+1)",
                                     p * (p - 1) // 2,
                                     p * (p + 1) // 2))
    
    # A₄ subgroups
    if p >= 5 and n % 24 == 0:
        classes.append(SubgroupClass("A₄", n // 24, n // 12))
    
    # S₄ subgroups (when p ≡ ±1 mod 8)
    if p >= 7 and p % 8 in (1, 7) and n % 48 == 0:
        classes.append(SubgroupClass("S₄", n // 48, n // 24))
    
    # A₅ subgroups (when p ≡ ±1 mod 5)
    if p >= 11 and p % 5 in (1, 4) and n % 120 == 0:
        classes.append(SubgroupClass("A₅", n // 120, n // 60))
    
    return PressureProfile(f"PSL₂({p})", n, classes)


def analyze_decay_trend(profiles: List[PressureProfile]) -> dict:
    """
    Analyze the decay trend of pressure across a family of groups.
    
    Fits pressure ~ C · |G|^(-ε) and reports the best-fit exponent.
    
    Returns:
        Dictionary with fit parameters and diagnostics.
    
    Complexity: O(n) where n = len(profiles)
    """
    if len(profiles) < 2:
        return {"error": "Need at least 2 profiles"}
    
    # Fit log(pressure) = log(C) - ε · log(|G|)
    log_orders = [math.log(p.group_order) for p in profiles if p.total_pressure() > 0]
    log_pressures = [math.log(p.total_pressure()) for p in profiles if p.total_pressure() > 0]
    
    if len(log_orders) < 2:
        return {"error": "Insufficient positive pressure values"}
    
    n = len(log_orders)
    mean_x = sum(log_orders) / n
    mean_y = sum(log_pressures) / n
    
    ss_xy = sum((x - mean_x) * (y - mean_y) for x, y in zip(log_orders, log_pressures))
    ss_xx = sum((x - mean_x) ** 2 for x in log_orders)
    
    if ss_xx == 0:
        return {"error": "No variation in group orders"}
    
    slope = ss_xy / ss_xx
    intercept = mean_y - slope * mean_x
    
    # R² computation
    ss_yy = sum((y - mean_y) ** 2 for y in log_pressures)
    r_squared = (ss_xy ** 2) / (ss_xx * ss_yy) if ss_yy > 0 else 0
    
    return {
        "decay_exponent": -slope,
        "log_constant": intercept,
        "constant_C": math.exp(intercept),
        "r_squared": r_squared,
        "n_points": n,
        "interpretation": (
            f"Pressure ≈ {math.exp(intercept):.4f} · |G|^({slope:.4f})\n"
            f"Decay exponent ε ≈ {-slope:.4f}\n"
            f"R² = {r_squared:.6f}"
        )
    }


# Example usage
if __name__ == "__main__":
    def is_prime(n):
        if n < 2: return False
        if n < 4: return True
        if n % 2 == 0 or n % 3 == 0: return False
        i = 5
        while i * i <= n:
            if n % i == 0 or n % (i + 2) == 0: return False
            i += 6
        return True
    
    primes = [p for p in range(3, 101) if is_prime(p)]
    profiles = [compute_psl2_profile(p) for p in primes]
    
    print("=" * 72)
    print("PRESSURE PROFILES FOR PSL₂(p)")
    print("=" * 72)
    
    for prof in profiles[:5]:
        print()
        print(prof.summary())
    
    print("\n" + "=" * 72)
    print("DECAY TREND ANALYSIS")
    print("=" * 72 + "\n")
    
    analysis = analyze_decay_trend(profiles)
    print(analysis["interpretation"])
    
    print("\n" + "=" * 72)
    print("ADMISSIBILITY CHECK")
    print("=" * 72 + "\n")
    
    for p in [5, 13, 37, 97]:
        prof = compute_psl2_profile(p)
        ok, msg = check_pressure_admissible(
            prof.group_order, prof.total_count(), prof.min_index(),
            a=2.0, b=1.0, C=1.0
        )
        print(f"PSL₂({p}): {msg}")
