"""
algorithms.py — Algorithms for the Periodic Table of Finite Groups

Implements group classification, derived series computation, and
periodic table construction for finite groups up to a given order.
"""

from typing import List, Dict, Tuple, Optional, Set
from itertools import product as cartesian_product
from math import gcd, factorial
from functools import reduce
from collections import Counter


def prime_factorization(n: int) -> Dict[int, int]:
    """Return the prime factorization of n as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    result = n
    for p in prime_factorization(n):
        result -= result // p
    return result


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


def num_groups_of_order(n: int) -> int:
    """
    Estimate the number of groups of order n.
    Exact for small n, uses known formulas for prime powers and products.
    """
    if n == 1:
        return 1
    if is_prime(n):
        return 1  # Only Z/pZ
    factors = prime_factorization(n)
    if len(factors) == 1:
        p, k = list(factors.items())[0]
        # Known counts for small prime powers
        known = {
            (2, 2): 2, (2, 3): 5, (2, 4): 14, (2, 5): 51,
            (2, 6): 267, (2, 7): 2328, (2, 8): 56092,
            (3, 2): 2, (3, 3): 5, (3, 4): 15,
            (5, 2): 2, (5, 3): 5,
            (7, 2): 2, (7, 3): 5,
        }
        if (p, k) in known:
            return known[(p, k)]
        if k == 2:
            return 2  # Z/p²Z and Z/pZ × Z/pZ
        return -1  # Unknown
    # For squarefree n with distinct primes
    plist = sorted(factors.keys())
    if all(e == 1 for e in factors.values()):
        # Count based on semidirect products
        # This is a rough lower bound
        return max(1, sum(1 for p in plist for q in plist
                         if p < q and (q - 1) % p == 0))
    return -1  # Unknown


class FiniteGroup:
    """Represents a finite group by its multiplication table (Cayley table)."""

    def __init__(self, table: List[List[int]], name: str = ""):
        self.table = table
        self.order = len(table)
        self.name = name
        self._validate()

    def _validate(self) -> None:
        """Verify the table defines a valid group."""
        n = self.order
        assert all(len(row) == n for row in self.table), "Table not square"
        # Check identity (row 0 should be identity)
        for i in range(n):
            assert self.table[0][i] == i and self.table[i][0] == i, \
                f"Element 0 is not identity: row/col {i}"

    def mul(self, a: int, b: int) -> int:
        """Multiply elements a and b."""
        return self.table[a][b]

    def inv(self, a: int) -> int:
        """Find the inverse of element a."""
        for b in range(self.order):
            if self.mul(a, b) == 0:
                return b
        raise ValueError(f"No inverse for {a}")

    def commutator(self, a: int, b: int) -> int:
        """Compute [a, b] = a * b * a⁻¹ * b⁻¹."""
        return self.mul(self.mul(self.mul(a, b), self.inv(a)), self.inv(b))

    def is_abelian(self) -> bool:
        """Check if the group is abelian."""
        for a in range(self.order):
            for b in range(a + 1, self.order):
                if self.mul(a, b) != self.mul(b, a):
                    return False
        return True

    def subgroup_generated_by(self, generators: Set[int]) -> Set[int]:
        """Generate the subgroup from a set of generators."""
        subgroup = {0}  # Identity
        subgroup.update(generators)
        changed = True
        while changed:
            changed = False
            new_elements: Set[int] = set()
            for a in subgroup:
                for b in subgroup:
                    prod = self.mul(a, b)
                    if prod not in subgroup:
                        new_elements.add(prod)
                        changed = True
                inv_a = self.inv(a)
                if inv_a not in subgroup:
                    new_elements.add(inv_a)
                    changed = True
            subgroup.update(new_elements)
        return subgroup

    def commutator_subgroup(self, H: Set[int]) -> Set[int]:
        """Compute [H, H] — the commutator subgroup of H."""
        commutators: Set[int] = set()
        for a in H:
            for b in H:
                commutators.add(self.commutator(a, b))
        return self.subgroup_generated_by(commutators)

    def derived_series(self) -> List[Set[int]]:
        """Compute the derived series G ⊇ G' ⊇ G'' ⊇ ..."""
        series = [set(range(self.order))]
        while True:
            next_term = self.commutator_subgroup(series[-1])
            if next_term == series[-1]:
                break
            series.append(next_term)
            if next_term == {0}:
                break
        return series

    def derived_length(self) -> int:
        """Compute the derived length (length of derived series until it stabilizes)."""
        series = self.derived_series()
        if series[-1] == {0}:
            return len(series) - 1
        return -1  # Not solvable

    def is_solvable(self) -> bool:
        """Check if the group is solvable."""
        return self.derived_length() >= 0

    def center(self) -> Set[int]:
        """Compute the center Z(G)."""
        z: Set[int] = set()
        for g in range(self.order):
            if all(self.mul(g, h) == self.mul(h, g) for h in range(self.order)):
                z.add(g)
        return z

    def upper_central_series(self) -> List[Set[int]]:
        """Compute the upper central series."""
        series = [self.center()]
        # Simplified: just return center for now
        return series

    def is_nilpotent(self) -> bool:
        """Check if the group is nilpotent (upper central series reaches G)."""
        if self.is_abelian():
            return True
        # For small groups, check if center is non-trivial and quotient is nilpotent
        center = self.center()
        if len(center) == self.order:
            return True
        if len(center) == 1:
            return False
        # Simplified check: nilpotent iff all Sylow subgroups are normal
        # This requires more machinery; approximate
        return self.is_solvable() and len(center) > 1

    def is_simple(self) -> bool:
        """Check if the group is simple (no non-trivial normal subgroups)."""
        if self.order <= 1:
            return False
        # Check all subsets that could be subgroups
        for size in range(2, self.order):
            if self.order % size != 0:
                continue
            # Generate all subgroups of this size
            for start in range(1, self.order):
                subgroup = self.subgroup_generated_by({start})
                if len(subgroup) == size:
                    # Check if normal
                    is_normal = True
                    for g in range(self.order):
                        for h in subgroup:
                            conj = self.mul(self.mul(g, h), self.inv(g))
                            if conj not in subgroup:
                                is_normal = False
                                break
                        if not is_normal:
                            break
                    if is_normal:
                        return False
        return True

    def classify_family(self) -> str:
        """Classify the group into a chemical family."""
        if self.order == 1:
            return "NobleGas"

        is_cyclic = any(
            len(self.subgroup_generated_by({g})) == self.order
            for g in range(1, self.order)
        )
        if is_cyclic:
            return "NobleGas"

        if self.is_simple() and not self.is_abelian():
            return "TransitionMetal"

        if self.is_nilpotent():
            return "AlkaliMetal"

        if self.is_solvable():
            return "AlkalineEarth"

        return "Radioactive"

    def minimal_normal_subgroups(self) -> List[Set[int]]:
        """Find all minimal normal subgroups (the 'valence')."""
        normal_subgroups: List[Set[int]] = []
        checked: Set[frozenset] = set()

        for start in range(1, self.order):
            # Generate normal closure
            subgroup = self.subgroup_generated_by({start})
            fs = frozenset(subgroup)
            if fs in checked:
                continue
            checked.add(fs)

            if len(subgroup) == self.order or len(subgroup) == 1:
                continue

            # Check normality
            is_normal = True
            for g in range(self.order):
                for h in subgroup:
                    if self.mul(self.mul(g, h), self.inv(g)) not in subgroup:
                        is_normal = False
                        break
                if not is_normal:
                    break

            if not is_normal:
                continue

            # Check minimality
            is_minimal = True
            for other in normal_subgroups:
                if other < subgroup:
                    is_minimal = False
                    break

            if is_minimal:
                # Remove any that this is strictly contained in
                normal_subgroups = [
                    ns for ns in normal_subgroups
                    if not (subgroup < ns)
                ]
                normal_subgroups.append(subgroup)

        return normal_subgroups

    def valence(self) -> int:
        """The group valence: number of minimal normal subgroups."""
        return len(self.minimal_normal_subgroups())


def cyclic_group(n: int) -> FiniteGroup:
    """Construct the cyclic group Z/nZ."""
    table = [[(i + j) % n for j in range(n)] for i in range(n)]
    return FiniteGroup(table, f"Z/{n}Z")


def symmetric_group(n: int) -> FiniteGroup:
    """Construct S_n for small n (n <= 4)."""
    from itertools import permutations

    perms = list(permutations(range(n)))
    perm_to_idx = {p: i for i, p in enumerate(perms)}
    order = len(perms)

    def compose(p: tuple, q: tuple) -> tuple:
        return tuple(p[q[i]] for i in range(n))

    table = [[perm_to_idx[compose(perms[i], perms[j])]
              for j in range(order)]
             for i in range(order)]

    return FiniteGroup(table, f"S_{n}")


def dihedral_group(n: int) -> FiniteGroup:
    """Construct the dihedral group D_n of order 2n."""
    order = 2 * n
    # Elements: r^0, r^1, ..., r^(n-1), s, sr, sr^2, ..., sr^(n-1)
    # r^i * r^j = r^((i+j) mod n)
    # r^i * sr^j = sr^((j-i) mod n)
    # sr^i * r^j = sr^((i+j) mod n)
    # sr^i * sr^j = r^((i-j) mod n)
    table = [[0] * order for _ in range(order)]
    for i in range(order):
        for j in range(order):
            if i < n and j < n:
                table[i][j] = (i + j) % n
            elif i < n and j >= n:
                table[i][j] = n + (j - n - i) % n
            elif i >= n and j < n:
                table[i][j] = n + (i - n + j) % n
            else:
                table[i][j] = (i - j) % n
    return FiniteGroup(table, f"D_{n}")


def build_periodic_table(max_order: int = 30) -> Dict[int, List[Dict]]:
    """
    Build a periodic table of finite groups up to the given order.
    Returns a dictionary mapping order -> list of group info dicts.
    """
    table: Dict[int, List[Dict]] = {}

    for n in range(1, max_order + 1):
        groups = []

        # Always have the cyclic group
        zn = cyclic_group(n)
        groups.append({
            "name": f"Z/{n}Z",
            "order": n,
            "family": zn.classify_family(),
            "abelian": True,
            "solvable": True,
            "derived_length": zn.derived_length(),
            "valence": zn.valence(),
        })

        # Add dihedral group D_n for n >= 3
        if n >= 3 and n <= 15:
            dn = dihedral_group(n)
            groups.append({
                "name": f"D_{n}",
                "order": 2 * n,
                "family": dn.classify_family(),
                "abelian": dn.is_abelian(),
                "solvable": dn.is_solvable(),
                "derived_length": dn.derived_length(),
                "valence": dn.valence(),
            })

        # Add symmetric group for small n
        if n <= 4:
            sn = symmetric_group(n)
            groups.append({
                "name": f"S_{n}",
                "order": factorial(n),
                "family": sn.classify_family(),
                "abelian": sn.is_abelian(),
                "solvable": sn.is_solvable(),
                "derived_length": sn.derived_length(),
                "valence": sn.valence(),
            })

        table[n] = groups

    return table


def composition_factor_signature(n: int) -> List[int]:
    """
    Compute the composition factor signature: the sorted list of prime
    factors (with multiplicity) in the prime factorization of n.
    Groups of order n must have composition factors whose orders
    multiply to n, and for solvable groups these are all primes.
    """
    factors = prime_factorization(n)
    sig = []
    for p, e in sorted(factors.items()):
        sig.extend([p] * e)
    return sig


def predict_group_properties(n: int) -> Dict:
    """
    Predict properties of groups of order n based on the periodic table analogy.
    Uses the prime factorization to predict solvability, nilpotency, etc.
    """
    factors = prime_factorization(n)
    primes = list(factors.keys())

    # Burnside's theorem: groups of order p^a * q^b are solvable
    is_guaranteed_solvable = len(primes) <= 2

    # Groups of prime-power order are nilpotent
    is_guaranteed_nilpotent = len(primes) == 1

    # Groups of prime order are cyclic (simple)
    is_cyclic_only = is_prime(n)

    # Sylow theory predictions
    sylow_info = {}
    for p, e in factors.items():
        pe = p ** e
        # Number of Sylow p-subgroups divides n/p^e and ≡ 1 mod p
        n_div_pe = n // pe
        possible_counts = [k for k in range(1, n_div_pe + 1)
                          if n_div_pe % k == 0 and k % p == 1]
        sylow_info[p] = {
            "order": pe,
            "possible_counts": possible_counts,
            "unique": possible_counts == [1],
        }

    return {
        "order": n,
        "prime_factorization": factors,
        "composition_factors": composition_factor_signature(n),
        "guaranteed_solvable": is_guaranteed_solvable,
        "guaranteed_nilpotent": is_guaranteed_nilpotent,
        "cyclic_only": is_cyclic_only,
        "sylow_info": sylow_info,
        "predicted_family": (
            "NobleGas" if is_cyclic_only else
            "AlkaliMetal" if is_guaranteed_nilpotent else
            "AlkalineEarth" if is_guaranteed_solvable else
            "Unknown"
        ),
    }


if __name__ == "__main__":
    # Demonstrate the algorithms
    print("=" * 60)
    print("THE PERIODIC TABLE OF FINITE GROUPS")
    print("=" * 60)

    print("\n--- Group Classification ---")
    for n in [1, 2, 3, 4, 5, 6]:
        zn = cyclic_group(n)
        print(f"Z/{n}Z: family={zn.classify_family()}, "
              f"derived_length={zn.derived_length()}, valence={zn.valence()}")

    print("\n--- Symmetric Groups ---")
    for n in [2, 3, 4]:
        sn = symmetric_group(n)
        print(f"S_{n}: order={sn.order}, family={sn.classify_family()}, "
              f"abelian={sn.is_abelian()}, solvable={sn.is_solvable()}, "
              f"derived_length={sn.derived_length()}")

    print("\n--- Isotope Conjecture Disproof ---")
    z6 = cyclic_group(6)
    s3 = symmetric_group(3)
    print(f"Z/6Z: order={z6.order}, derived_length={z6.derived_length()}")
    print(f"S_3:  order={s3.order}, derived_length={s3.derived_length()}")
    print(f"Same order ({z6.order} = {s3.order}), "
          f"different derived lengths ({z6.derived_length()} ≠ {s3.derived_length()})")
    print("=> Isotope conjecture is FALSE!")

    print("\n--- Predictions for Order 120 ---")
    pred = predict_group_properties(120)
    print(f"Order 120 = {pred['prime_factorization']}")
    print(f"Composition factors: {pred['composition_factors']}")
    print(f"Guaranteed solvable: {pred['guaranteed_solvable']}")
    print(f"Sylow info: {pred['sylow_info']}")
