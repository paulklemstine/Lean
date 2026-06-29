#!/usr/bin/env python3
"""
Knuth Semifield Classification: Algorithms

Type-hinted implementations of core algorithms for semifield
nucleus theory and classification.
"""

from typing import Optional
from dataclasses import dataclass
from itertools import permutations


@dataclass(frozen=True)
class NucleiConfig:
    """The discrete invariant of a finite semifield.

    Attributes:
        p: Base prime
        n: Total exponent (order = p^n)
        d_l: Left nucleus exponent
        d_m: Middle nucleus exponent
        d_r: Right nucleus exponent
        d_0: Center exponent
    """
    p: int
    n: int
    d_l: int
    d_m: int
    d_r: int
    d_0: int = 1

    def order(self) -> int:
        return self.p ** self.n

    def left_nuc_size(self) -> int:
        return self.p ** self.d_l

    def mid_nuc_size(self) -> int:
        return self.p ** self.d_m

    def right_nuc_size(self) -> int:
        return self.p ** self.d_r

    def nuc_product(self) -> int:
        return self.left_nuc_size() * self.mid_nuc_size() * self.right_nuc_size()

    def left_rank(self) -> int:
        return self.n // self.d_l

    def mid_rank(self) -> int:
        return self.n // self.d_m

    def right_rank(self) -> int:
        return self.n // self.d_r

    def is_field(self) -> bool:
        return self.d_l == self.n and self.d_m == self.n and self.d_r == self.n

    def nuc_exp_sum(self) -> int:
        return self.d_l + self.d_m + self.d_r

    def defect(self) -> int:
        """Defect with respect to left nucleus."""
        return self.p ** self.n - self.p ** self.d_l

    def nucleus_triple(self) -> tuple[int, int, int]:
        return (self.d_l, self.d_m, self.d_r)

    def isotopy_invariant(self) -> tuple[int, ...]:
        """Sorted nucleus triple (multiset representative)."""
        return tuple(sorted(self.nucleus_triple()))

    def validate(self) -> bool:
        """Check all NucleiConfig constraints."""
        from sympy import isprime
        if not isprime(self.p):
            return False
        if self.n < 1:
            return False
        for d in [self.d_l, self.d_m, self.d_r, self.d_0]:
            if d < 1 or self.n % d != 0:
                return False
        if not (self.d_0 <= self.d_l and self.d_0 <= self.d_m and self.d_0 <= self.d_r):
            return False
        for d in [self.d_l, self.d_m, self.d_r]:
            if d % self.d_0 != 0:
                return False
        return True


def knuth_transpose(cfg: NucleiConfig) -> NucleiConfig:
    """Knuth transpose: swap left and right nuclei."""
    return NucleiConfig(cfg.p, cfg.n, cfg.d_r, cfg.d_m, cfg.d_l, cfg.d_0)


def knuth_dual(cfg: NucleiConfig) -> NucleiConfig:
    """Knuth dual: swap left and middle nuclei."""
    return NucleiConfig(cfg.p, cfg.n, cfg.d_m, cfg.d_l, cfg.d_r, cfg.d_0)


def knuth_rotate(cfg: NucleiConfig) -> NucleiConfig:
    """Knuth rotation: dual ∘ transpose."""
    return knuth_dual(knuth_transpose(cfg))


def knuth_orbit(cfg: NucleiConfig) -> set[NucleiConfig]:
    """Compute the full Knuth S₃ orbit."""
    orbit: set[NucleiConfig] = set()
    current = cfg
    for _ in range(6):
        orbit.add(current)
        orbit.add(knuth_transpose(current))
        current = knuth_rotate(current)
    return orbit


def classify_knuth_orbit(cfg: NucleiConfig) -> str:
    """Classify the Knuth orbit type."""
    orbit = knuth_orbit(cfg)
    size = len(orbit)
    if size == 1:
        return "trivial (d_l = d_m = d_r)"
    elif size == 2:
        return "dihedral-2 (two equal nuclei)"
    elif size == 3:
        return "cyclic-3 (all distinct, cyclic symmetry)"
    elif size == 6:
        return "full S₃ (all distinct, no symmetry)"
    else:
        return f"unexpected orbit size {size}"


def divisors(n: int) -> list[int]:
    """All positive divisors of n, sorted."""
    return sorted(d for d in range(1, n + 1) if n % d == 0)


def enumerate_nuclei_configs(p: int, n: int) -> list[NucleiConfig]:
    """Enumerate all valid NucleiConfig for given (p, n)."""
    divs = divisors(n)
    configs = []
    for dl in divs:
        for dm in divs:
            for dr in divs:
                # Find valid center exponents
                for d0 in divs:
                    if (d0 <= dl and d0 <= dm and d0 <= dr and
                            dl % d0 == 0 and dm % d0 == 0 and dr % d0 == 0):
                        configs.append(NucleiConfig(p, n, dl, dm, dr, d0))
                        break  # Use smallest valid center
    return configs


def isotopy_classes(p: int, n: int) -> dict[tuple[int, ...], list[NucleiConfig]]:
    """Group NucleiConfigs by isotopy invariant."""
    configs = enumerate_nuclei_configs(p, n)
    classes: dict[tuple[int, ...], list[NucleiConfig]] = {}
    for cfg in configs:
        inv = cfg.isotopy_invariant()
        if inv not in classes:
            classes[inv] = []
        classes[inv].append(cfg)
    return classes


def semifield_code_params(cfg: NucleiConfig) -> dict[str, int]:
    """Compute the rank-metric code parameters from a NucleiConfig."""
    return {
        "matrix_dim": cfg.n,
        "subfield_dim": cfg.d_l,
        "min_rank_dist": cfg.left_rank(),
        "code_size": cfg.order(),
        "is_mrd": cfg.left_rank() == cfg.n - cfg.d_l + 1
    }


def twisted_field_config(p: int, n: int, sigma_order: int) -> Optional[NucleiConfig]:
    """Construct a NucleiConfig for a generalized twisted field.

    Args:
        p: Prime base
        n: Total exponent (n ≥ 2)
        sigma_order: Order of the twisting automorphism (must divide n, > 1)

    Returns:
        NucleiConfig or None if parameters are invalid
    """
    if n < 2 or sigma_order < 2 or n % sigma_order != 0:
        return None
    d = n // sigma_order
    return NucleiConfig(p=p, n=n, d_l=d, d_m=1, d_r=d, d_0=1)


def minimum_defect_bound(p: int, k: int, rank: int) -> int:
    """Lower bound on defect for given rank.

    For a semifield with left nucleus p^k and rank ≥ 2:
    defect ≥ p^k * (p^k - 1)
    """
    if rank < 2:
        return 0
    return p**k * (p**k - 1)


def nucleus_product_bound_check(cfg: NucleiConfig) -> dict[str, bool]:
    """Check various nucleus product bounds."""
    prod = cfg.nuc_product()
    order = cfg.order()
    return {
        "product_le_order_cubed": prod <= order**3,
        "product_lt_order_cubed_if_nonfield": (
            prod < order**3 if not cfg.is_field() else True
        ),
        "product_eq_order_cubed_iff_field": (
            (prod == order**3) == cfg.is_field()
        )
    }


if __name__ == "__main__":
    # Example usage
    cfg = NucleiConfig(p=2, n=6, d_l=3, d_m=1, d_r=3)
    print(f"Config: {cfg}")
    print(f"Order: {cfg.order()}")
    print(f"Nucleus product: {cfg.nuc_product()}")
    print(f"Is field: {cfg.is_field()}")
    print(f"Isotopy invariant: {cfg.isotopy_invariant()}")
    print(f"Knuth orbit type: {classify_knuth_orbit(cfg)}")
    print(f"Code params: {semifield_code_params(cfg)}")
    print(f"Bounds check: {nucleus_product_bound_check(cfg)}")

    print(f"\nIsotopy classes for p=2, n=6:")
    classes = isotopy_classes(2, 6)
    for inv, cfgs in sorted(classes.items()):
        print(f"  {inv}: {len(cfgs)} configs")
