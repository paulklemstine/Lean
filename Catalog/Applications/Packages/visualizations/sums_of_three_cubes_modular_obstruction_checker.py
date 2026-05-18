#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Sums of Three Cubes Analysis

Implements:
1. ModularObstructionChecker: checks local solvability mod m
2. AdmissibleDensityCounter: exact counting in residue blocks
3. PolynomialFamilyGenerator: generates representable integers from identities
4. BruteForceSearch: exhaustive search for representations
5. CRTDecomposer: Chinese Remainder Theorem analysis of local solvability
"""

from typing import Optional
from math import gcd


class ModularObstructionChecker:
    """
    Checks local solvability of x³ + y³ + z³ ≡ a (mod m).
    
    Precomputes the cube set and triple sumset for a given modulus m,
    then answers representability queries in O(1).
    
    Time complexity: O(m) precomputation, O(1) per query.
    Space complexity: O(m).
    
    Example:
        >>> checker = ModularObstructionChecker(9)
        >>> checker.is_locally_representable(0)
        True
        >>> checker.is_locally_representable(4)
        False
    """
    
    def __init__(self, m: int):
        """Initialize with modulus m. Precomputes cube image and triple sumset."""
        if m <= 0:
            raise ValueError(f"Modulus must be positive, got {m}")
        self.m = m
        self.cube_set = self._compute_cube_set()
        self.triple_sumset = self._compute_triple_sumset()
        self.obstructed = set(range(m)) - self.triple_sumset
    
    def _compute_cube_set(self) -> set[int]:
        """Compute {x³ mod m : x ∈ Z/mZ}."""
        return {pow(x, 3, self.m) for x in range(self.m)}
    
    def _compute_triple_sumset(self) -> set[int]:
        """Compute {a + b + c mod m : a, b, c ∈ cube_set}."""
        result = set()
        for a in self.cube_set:
            for b in self.cube_set:
                for c in self.cube_set:
                    result.add((a + b + c) % self.m)
        return result
    
    def is_locally_representable(self, a: int) -> bool:
        """Check if a is in the triple sumset of cubes mod m."""
        return (a % self.m) in self.triple_sumset
    
    def get_obstructions(self) -> set[int]:
        """Return the set of obstructed residue classes."""
        return self.obstructed.copy()
    
    def get_witness(self, a: int) -> Optional[tuple[int, int, int]]:
        """Find a witness (x, y, z) with x³+y³+z³ ≡ a (mod m), or None."""
        a = a % self.m
        for x in range(self.m):
            for y in range(self.m):
                for z in range(self.m):
                    if (x**3 + y**3 + z**3) % self.m == a:
                        return (x, y, z)
        return None


class AdmissibleDensityCounter:
    """
    Counts admissible integers (not obstructed mod m) in ranges.
    
    For a given modulus m and obstruction set S ⊂ Z/mZ, counts integers
    n in [0, N) with n mod m ∉ S.
    
    For complete blocks of length m, the count is exact:
      count([0, m*K)) = (m - |S|) * K
    
    Time complexity: O(1) for complete blocks, O(m) for partial blocks.
    
    Example:
        >>> counter = AdmissibleDensityCounter(9, {4, 5})
        >>> counter.count_in_range(90)
        70
    """
    
    def __init__(self, m: int, obstructions: set[int]):
        self.m = m
        self.obstructions = {s % m for s in obstructions}
        self.admissible_per_block = m - len(self.obstructions)
    
    def count_in_range(self, N: int) -> int:
        """Count admissible integers in [0, N)."""
        full_blocks = N // self.m
        remainder = N % self.m
        count = full_blocks * self.admissible_per_block
        for r in range(remainder):
            if r not in self.obstructions:
                count += 1
        return count
    
    def density(self) -> float:
        """Return the asymptotic density of admissible integers."""
        return self.admissible_per_block / self.m
    
    def count_complete_blocks(self, K: int) -> int:
        """Count admissible in [0, m*K). Returns exactly (m-|S|)*K."""
        return self.admissible_per_block * K


class PolynomialFamilyGenerator:
    """
    Generates representable integers from polynomial identities.
    
    Identity 1: m³ = m³ + 0³ + 0³  (trivial cubes)
    Identity 2: a³ + b³ + (-a-b)³ = -3ab(a+b)  (two-parameter family)
    Identity 3: k³ + (k+1)³ + (-(2k+1))³ = -3k(k+1)(2k+1)  (one-parameter)
    
    Example:
        >>> gen = PolynomialFamilyGenerator()
        >>> gen.trivial_family(3)
        (27, (3, 0, 0))
        >>> gen.two_param_family(2, 3)
        (-90, (2, 3, -5))
    """
    
    @staticmethod
    def trivial_family(m: int) -> tuple[int, tuple[int, int, int]]:
        """m³ = m³ + 0³ + 0³."""
        return (m**3, (m, 0, 0))
    
    @staticmethod
    def two_param_family(a: int, b: int) -> tuple[int, tuple[int, int, int]]:
        """a³ + b³ + (-a-b)³ = -3ab(a+b)."""
        z = -a - b
        n = a**3 + b**3 + z**3
        assert n == -3 * a * b * (a + b)
        return (n, (a, b, z))
    
    @staticmethod
    def one_param_family(k: int) -> tuple[int, tuple[int, int, int]]:
        """k³ + (k+1)³ + (-(2k+1))³ = -3k(k+1)(2k+1)."""
        a, b, c = k, k + 1, -(2 * k + 1)
        n = a**3 + b**3 + c**3
        return (n, (a, b, c))
    
    def generate_family(self, param_range: range, family: str = "one_param") -> list[tuple[int, tuple[int, int, int]]]:
        """Generate a list of (n, (x,y,z)) pairs from a parametric family."""
        if family == "trivial":
            return [self.trivial_family(m) for m in param_range]
        elif family == "one_param":
            return [self.one_param_family(k) for k in param_range]
        else:
            raise ValueError(f"Unknown family: {family}")


class BruteForceSearch:
    """
    Exhaustive search for representations n = x³ + y³ + z³.
    
    Searches all (x, y, z) with |x|, |y|, |z| ≤ bound.
    
    Time complexity: O(bound³).
    Space complexity: O(1) per query.
    
    Example:
        >>> searcher = BruteForceSearch(100)
        >>> searcher.find_representation(29)
        (3, 1, 1)
    """
    
    def __init__(self, bound: int = 100):
        self.bound = bound
    
    def find_representation(self, n: int) -> Optional[tuple[int, int, int]]:
        """Find one representation n = x³+y³+z³, or None."""
        for x in range(-self.bound, self.bound + 1):
            for y in range(-self.bound, self.bound + 1):
                z3 = n - x**3 - y**3
                # Check if z3 is a perfect cube
                if z3 == 0:
                    return (x, y, 0)
                sign = 1 if z3 > 0 else -1
                z_approx = round(abs(z3) ** (1/3))
                for z in [sign * z_approx - 1, sign * z_approx, sign * z_approx + 1]:
                    if z**3 == z3 and abs(z) <= self.bound:
                        return (x, y, z)
        return None
    
    def find_all_representations(self, n: int) -> list[tuple[int, int, int]]:
        """Find all representations within the bound."""
        results = []
        for x in range(-self.bound, self.bound + 1):
            for y in range(x, self.bound + 1):  # Use x ≤ y to reduce
                z3 = n - x**3 - y**3
                if z3 == 0 and y <= 0:
                    results.append((x, y, 0))
                elif z3 != 0:
                    sign = 1 if z3 > 0 else -1
                    z_approx = round(abs(z3) ** (1/3))
                    for z in [sign * z_approx - 1, sign * z_approx, sign * z_approx + 1]:
                        if z**3 == z3 and z >= y:
                            results.append((x, y, z))
        return results
    
    def is_representable(self, n: int) -> bool:
        """Check if n is representable within the search bound."""
        return self.find_representation(n) is not None


class CRTDecomposer:
    """
    Analyzes local solvability through Chinese Remainder Theorem decomposition.
    
    For coprime moduli m, n: checks whether LocRep(mn, a) ↔ LocRep(m, a mod m) ∧ LocRep(n, a mod n).
    
    Example:
        >>> decomp = CRTDecomposer()
        >>> decomp.verify_crt(3, 5)
        True
    """
    
    @staticmethod
    def verify_crt(m: int, n: int) -> bool:
        """Verify CRT decomposition holds for coprime m, n."""
        if gcd(m, n) != 1:
            raise ValueError(f"{m} and {n} are not coprime")
        
        checker_m = ModularObstructionChecker(m)
        checker_n = ModularObstructionChecker(n)
        checker_mn = ModularObstructionChecker(m * n)
        
        mn = m * n
        for a in range(mn):
            loc_mn = checker_mn.is_locally_representable(a)
            loc_m = checker_m.is_locally_representable(a % m)
            loc_n = checker_n.is_locally_representable(a % n)
            if loc_mn != (loc_m and loc_n):
                return False
        return True
    
    @staticmethod
    def find_crt_failures(m: int, n: int) -> list[int]:
        """Find all residues where CRT decomposition fails."""
        if gcd(m, n) != 1:
            raise ValueError(f"{m} and {n} are not coprime")
        
        checker_m = ModularObstructionChecker(m)
        checker_n = ModularObstructionChecker(n)
        checker_mn = ModularObstructionChecker(m * n)
        
        failures = []
        mn = m * n
        for a in range(mn):
            loc_mn = checker_mn.is_locally_representable(a)
            loc_m = checker_m.is_locally_representable(a % m)
            loc_n = checker_n.is_locally_representable(a % n)
            if loc_mn != (loc_m and loc_n):
                failures.append(a)
        return failures


# Example usage and verification
if __name__ == "__main__":
    print("=== Modular Obstruction Checker ===")
    checker9 = ModularObstructionChecker(9)
    print(f"Cube residues mod 9: {sorted(checker9.cube_set)}")
    print(f"Triple sumset mod 9: {sorted(checker9.triple_sumset)}")
    print(f"Obstructed classes: {sorted(checker9.obstructed)}")
    print()
    
    print("=== Admissible Density Counter ===")
    counter = AdmissibleDensityCounter(9, {4, 5})
    for N in [9, 90, 900, 9000]:
        print(f"  Admissible in [0, {N}): {counter.count_in_range(N)} "
              f"(expected {7 * N // 9})")
    print(f"  Asymptotic density: {counter.density():.6f}")
    print()
    
    print("=== Polynomial Family Generator ===")
    gen = PolynomialFamilyGenerator()
    print("One-parameter family -3k(k+1)(2k+1):")
    for k in range(1, 8):
        n, (a, b, c) = gen.one_param_family(k)
        print(f"  k={k}: {a}³ + {b}³ + ({c})³ = {n}")
    print()
    
    print("=== CRT Decomposition Verification ===")
    decomp = CRTDecomposer()
    for m, n in [(2, 3), (3, 5), (2, 5), (3, 7), (5, 7), (2, 9), (7, 9)]:
        if gcd(m, n) == 1:
            result = decomp.verify_crt(m, n)
            print(f"  CRT({m}, {n}): {'✓ holds' if result else '✗ FAILS'}")
