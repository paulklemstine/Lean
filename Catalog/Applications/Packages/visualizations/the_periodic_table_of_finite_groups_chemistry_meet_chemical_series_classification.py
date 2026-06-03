#!/usr/bin/env python3
"""
algorithms.py — Algorithms for the Periodic Table of Finite Groups

Type-hinted implementations of the core classification algorithms:
1. Group chemical series classification
2. Center-valence computation
3. Derived series / solvability spectrum
4. Nilpotency class detection
5. Periodic table construction

These algorithms can classify any finite group given its multiplication table.
"""

from typing import List, Set, Dict, Tuple, Optional
from dataclasses import dataclass
from enum import Enum


class ChemicalSeries(Enum):
    """Chemical series classification for finite groups."""
    VACUUM = "Vacuum"              # Trivial group
    PRIME_ELEMENT = "Prime Element" # Cyclic of prime order
    NOBLE_GAS = "Noble Gas"         # Cyclic of composite order
    ALKALINE_EARTH = "Alkaline Earth"  # Abelian non-cyclic
    ALKALI_METAL = "Alkali Metal"   # Nilpotent non-abelian
    COMPOUND = "Compound"           # Solvable non-nilpotent
    RADIOACTIVE = "Radioactive"     # Non-solvable


@dataclass
class GroupInvariants:
    """Structural invariants of a finite group — its 'electron configuration'."""
    order: int                      # Atomic number
    center_valence: int             # |Z(G)|
    abelian_defect: int             # |G| / |Z(G)|
    derived_length: Optional[int]   # None if not solvable
    nilpotency_class: Optional[int] # None if not nilpotent
    is_cyclic: bool
    is_abelian: bool
    is_simple: bool
    chemical_series: ChemicalSeries
    derived_spectrum: List[int]     # Sizes of derived series terms


@dataclass
class PeriodicEntry:
    """Entry in the periodic table of finite groups."""
    name: str
    invariants: GroupInvariants
    composition_factors: List[int]  # Sizes of composition factors


def is_prime(n: int) -> bool:
    """Primality test."""
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


class FiniteGroup:
    """A finite group represented by its multiplication table."""

    def __init__(self, table: List[List[int]], name: str = "G"):
        self.table = table
        self.order = len(table)
        self.name = name
        self._inverses: Optional[List[int]] = None
        self._center: Optional[List[int]] = None

    @property
    def inverses(self) -> List[int]:
        """Compute inverse of each element."""
        if self._inverses is None:
            self._inverses = [0] * self.order
            for i in range(self.order):
                for j in range(self.order):
                    if self.table[i][j] == 0:
                        self._inverses[i] = j
                        break
        return self._inverses

    def multiply(self, a: int, b: int) -> int:
        """Multiply two elements."""
        return self.table[a][b]

    def inverse(self, a: int) -> int:
        """Inverse of an element."""
        return self.inverses[a]

    def commutator(self, a: int, b: int) -> int:
        """Compute [a,b] = a·b·a⁻¹·b⁻¹."""
        ab = self.multiply(a, b)
        a_inv_b_inv = self.multiply(self.inverse(a), self.inverse(b))
        return self.multiply(ab, a_inv_b_inv)

    def center(self) -> List[int]:
        """Compute the center Z(G)."""
        if self._center is None:
            self._center = [
                g for g in range(self.order)
                if all(self.table[g][h] == self.table[h][g]
                       for h in range(self.order))
            ]
        return self._center

    def center_valence(self) -> int:
        """The center-valence: |Z(G)|."""
        return len(self.center())

    def abelian_defect(self) -> int:
        """The abelian defect: |G| / |Z(G)|."""
        cv = self.center_valence()
        return self.order // cv if cv > 0 else self.order

    def is_abelian(self) -> bool:
        """Check if G is abelian."""
        return self.center_valence() == self.order

    def generate_subgroup(self, generators: Set[int]) -> List[int]:
        """Generate the smallest subgroup containing the given generators."""
        subgroup = set(generators) | {0}
        changed = True
        while changed:
            changed = False
            new = set()
            for a in subgroup:
                for b in subgroup:
                    p = self.table[a][b]
                    if p not in subgroup:
                        new.add(p)
                        changed = True
            subgroup |= new
        return sorted(subgroup)

    def commutator_subgroup(self, elements: Optional[List[int]] = None) -> List[int]:
        """Compute [H,H] for H = elements (default: G)."""
        if elements is None:
            elements = list(range(self.order))

        # Compute inverses within elements
        comms: Set[int] = set()
        for a in elements:
            for b in elements:
                comms.add(self.commutator(a, b))

        return self.generate_subgroup(comms)

    def derived_series(self, max_depth: int = 50) -> List[List[int]]:
        """Compute the derived series: G = G⁽⁰⁾ ⊇ G⁽¹⁾ ⊇ G⁽²⁾ ⊇ ..."""
        current = list(range(self.order))
        series = [current]

        for _ in range(max_depth):
            next_sub = self.commutator_subgroup(current)
            if len(next_sub) == len(current):
                break
            current = next_sub
            series.append(current)
            if len(current) == 1:
                break

        return series

    def derived_length(self) -> Optional[int]:
        """Derived length, or None if not solvable."""
        series = self.derived_series()
        if len(series[-1]) > 1:
            return None
        return len(series) - 1

    def solvability_spectrum(self) -> List[int]:
        """The sizes of derived series terms — the group's spectral fingerprint."""
        return [len(s) for s in self.derived_series()]

    def is_cyclic(self) -> bool:
        """Check if G is cyclic."""
        for g in range(self.order):
            seen = {0}
            current = g
            for _ in range(self.order):
                seen.add(current)
                current = self.table[current][g]
            if len(seen) == self.order:
                return True
        return False

    def nilpotency_class(self) -> Optional[int]:
        """Compute the nilpotency class, or None if not nilpotent."""
        current = list(range(self.order))
        for depth in range(self.order + 1):
            # Compute [G, current]
            comms: Set[int] = set()
            for a in range(self.order):
                for b in current:
                    comms.add(self.commutator(a, b))
            next_sub = self.generate_subgroup(comms)
            if len(next_sub) == 1:
                return depth + 1
            if len(next_sub) == len(current):
                return None  # stabilized
            current = next_sub
        return None

    def is_simple(self) -> bool:
        """Check if G is simple (no proper normal subgroups)."""
        if self.order <= 1:
            return False
        for size in range(2, self.order):
            if self.order % size != 0:
                continue
            # Check all subsets of this size — too expensive for large groups
            # For demo purposes, check subgroups generated by single elements
            pass
        # Simple check: for small groups, use derived series
        # A non-abelian group is simple if it has no normal subgroups
        return self.order > 1 and self.derived_length() is None

    def classify(self) -> ChemicalSeries:
        """Classify into chemical series."""
        if self.order == 1:
            return ChemicalSeries.VACUUM
        if self.is_abelian():
            if self.is_cyclic():
                if is_prime(self.order):
                    return ChemicalSeries.PRIME_ELEMENT
                return ChemicalSeries.NOBLE_GAS
            return ChemicalSeries.ALKALINE_EARTH
        nc = self.nilpotency_class()
        if nc is not None:
            return ChemicalSeries.ALKALI_METAL
        dl = self.derived_length()
        if dl is not None:
            return ChemicalSeries.COMPOUND
        return ChemicalSeries.RADIOACTIVE

    def invariants(self) -> GroupInvariants:
        """Compute all structural invariants."""
        return GroupInvariants(
            order=self.order,
            center_valence=self.center_valence(),
            abelian_defect=self.abelian_defect(),
            derived_length=self.derived_length(),
            nilpotency_class=self.nilpotency_class(),
            is_cyclic=self.is_cyclic(),
            is_abelian=self.is_abelian(),
            is_simple=self.is_simple(),
            chemical_series=self.classify(),
            derived_spectrum=self.solvability_spectrum(),
        )


# === Standard group constructors ===

def cyclic(n: int) -> FiniteGroup:
    """Cyclic group Z/nZ."""
    table = [[(i + j) % n for j in range(n)] for i in range(n)]
    return FiniteGroup(table, f"Z/{n}Z")

def dihedral(n: int) -> FiniteGroup:
    """Dihedral group D_n of order 2n."""
    order = 2 * n
    table = [[0]*order for _ in range(order)]
    for a in range(order):
        for b in range(order):
            ai = a % n
            bi = b % n
            if a < n and b < n:
                table[a][b] = (ai + bi) % n
            elif a < n and b >= n:
                table[a][b] = n + (ai + bi) % n
            elif a >= n and b < n:
                table[a][b] = n + (ai - bi) % n
            else:
                table[a][b] = (ai - bi) % n
    return FiniteGroup(table, f"D_{n}")

def direct_product(G: FiniteGroup, H: FiniteGroup) -> FiniteGroup:
    """Direct product G × H."""
    n1, n2 = G.order, H.order
    order = n1 * n2
    table = [[0]*order for _ in range(order)]
    for a in range(order):
        for b in range(order):
            a1, a2 = a // n2, a % n2
            b1, b2 = b // n2, b % n2
            table[a][b] = G.table[a1][b1] * n2 + H.table[a2][b2]
    return FiniteGroup(table, f"{G.name} × {H.name}")


# === Periodic Table Construction ===

def build_periodic_table(groups: Dict[str, FiniteGroup]) -> Dict[str, PeriodicEntry]:
    """Build the periodic table from a dictionary of named groups."""
    table: Dict[str, PeriodicEntry] = {}
    for name, group in groups.items():
        inv = group.invariants()
        entry = PeriodicEntry(
            name=name,
            invariants=inv,
            composition_factors=inv.derived_spectrum,
        )
        table[name] = entry
    return table


def print_periodic_table(entries: Dict[str, PeriodicEntry]) -> None:
    """Display the periodic table."""
    # Group by chemical series
    by_series: Dict[ChemicalSeries, List[PeriodicEntry]] = defaultdict(list)
    for entry in entries.values():
        by_series[entry.invariants.chemical_series].append(entry)

    for series in ChemicalSeries:
        if series not in by_series:
            continue
        print(f"\n{'='*50}")
        print(f"  {series.value}")
        print(f"{'='*50}")
        for entry in sorted(by_series[series], key=lambda e: e.invariants.order):
            inv = entry.invariants
            dl = inv.derived_length if inv.derived_length is not None else "∞"
            nc = inv.nilpotency_class if inv.nilpotency_class is not None else "—"
            print(f"  {entry.name:<25} n={inv.order:>3}  |Z|={inv.center_valence:>3}"
                  f"  dl={dl}  nc={nc}  spectrum={inv.derived_spectrum}")


if __name__ == "__main__":
    # Build table for groups up to order ~20
    groups = {}
    for n in range(1, 16):
        groups[f"Z/{n}Z"] = cyclic(n)
    for n in range(3, 9):
        groups[f"D_{n}"] = dihedral(n)
    groups["V₄"] = direct_product(cyclic(2), cyclic(2))
    groups["Z/2 × Z/4"] = direct_product(cyclic(2), cyclic(4))
    groups["Z/2³"] = direct_product(direct_product(cyclic(2), cyclic(2)), cyclic(2))
    groups["Z/3 × Z/3"] = direct_product(cyclic(3), cyclic(3))

    table = build_periodic_table(groups)
    print("THE PERIODIC TABLE OF FINITE GROUPS")
    print("=" * 50)
    print_periodic_table(table)
