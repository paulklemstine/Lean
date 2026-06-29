"""
Numerical demonstrations for:

    Korselt's Criterion and a Multiplicative-Order Bridge to
    Cryptographic Pseudoprimality

The central verified result (the "arithmetic bridge") states:

    Let n be squarefree, p a prime dividing n, and suppose every unit u modulo n
    satisfies u^(n-1) = 1 (mod n).  Then (p - 1) | (n - 1).

This file gives self-contained Python that:
  1. recomputes element orders in (Z/nZ)^x from scratch,
  2. verifies the bridge's hypothesis and conclusion on Carmichael numbers,
  3. exhibits the surjective reduction map (Z/nZ)^x -> (Z/pZ)^x,
  4. confirms that homomorphisms do not increase order,
  5. illustrates the generalized-exponent (Carmichael-lambda) viewpoint, and
  6. shows the Fermat test's blind spot vs. a Miller-Rabin-style probe.

No external libraries are required (only the standard library).
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Optional, Tuple


# ----------------------------------------------------------------------------- #
# Basic number theory, all inlined.
# ----------------------------------------------------------------------------- #
def units_mod(n: int) -> List[int]:
    """Return the residues in (Z/nZ)^x, i.e. all a in [1, n) with gcd(a, n) = 1."""
    return [a for a in range(1, n) if gcd(a, n) == 1]


def element_order(a: int, n: int) -> int:
    """Return the multiplicative order of a modulo n (a must be a unit)."""
    if gcd(a, n) != 1:
        raise ValueError(f"{a} is not a unit modulo {n}")
    k, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        k += 1
    return k


def factorize(n: int) -> Dict[int, int]:
    """Return the prime factorization of n as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def is_squarefree(n: int) -> bool:
    """True iff no prime square divides n."""
    return all(e == 1 for e in factorize(n).values())


def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b


def carmichael_lambda(n: int) -> int:
    """Carmichael's lambda(n): the exponent of (Z/nZ)^x.

    For squarefree n = p_1 ... p_k this equals lcm(p_1 - 1, ..., p_k - 1).
    Computed here directly as the lcm of orders of all units (definitional check).
    """
    e = 1
    for a in units_mod(n):
        e = lcm(e, element_order(a, n))
    return e


# ----------------------------------------------------------------------------- #
# The arithmetic bridge and Korselt's criterion.
# ----------------------------------------------------------------------------- #
def all_units_killed_by(n: int, e: int) -> bool:
    """True iff u^e = 1 (mod n) for every unit u (the pseudoprime hypothesis)."""
    return all(pow(u, e, n) == 1 for u in units_mod(n))


def is_fermat_pseudoprime(n: int) -> bool:
    """True iff n is composite and every coprime base a satisfies a^(n-1) = 1."""
    return (factorize(n) != {n: 1}) and n > 1 and all_units_killed_by(n, n - 1)


def is_korselt(n: int) -> bool:
    """Korselt's criterion: n squarefree and (p-1) | (n-1) for all primes p | n."""
    if n <= 1 or factorize(n) == {n: 1}:  # prime or unit -> not a Carmichael number
        return False
    if not is_squarefree(n):
        return False
    return all((n - 1) % (p - 1) == 0 for p in factorize(n))


def reduction_map(a: int, n: int, p: int) -> int:
    """The reduction homomorphism (Z/nZ)^x -> (Z/pZ)^x : [a]_n |-> [a]_p."""
    return a % p


def verify_bridge(n: int) -> List[Tuple[int, bool]]:
    """For squarefree n with the killing hypothesis, check (p-1) | (n-1) per prime.

    Returns a list of (p, holds) pairs.
    """
    assert is_squarefree(n), "bridge requires squarefree n"
    assert all_units_killed_by(n, n - 1), "bridge hypothesis u^(n-1)=1 must hold"
    return [(p, (n - 1) % (p - 1) == 0) for p in factorize(n)]


def reduction_surjective(n: int, p: int) -> bool:
    """Check that the reduction map (Z/nZ)^x -> (Z/pZ)^x hits every unit mod p."""
    image = {reduction_map(a, n, p) for a in units_mod(n)}
    return image == set(units_mod(p))


def hom_never_increases_order(n: int, p: int) -> bool:
    """Check ord(f(a)) | ord(a) for the reduction map f, over all units a mod n."""
    for a in units_mod(n):
        v = reduction_map(a, n, p)
        if v == 0:  # not a unit mod p; skip (cannot happen when p | n and gcd(a,n)=1)
            continue
        if element_order(a, n) % element_order(v, p) != 0:
            return False
    return True


# ----------------------------------------------------------------------------- #
# Miller-Rabin-style probe: the Fermat test's repair.
# ----------------------------------------------------------------------------- #
def miller_rabin_witness(a: int, n: int) -> bool:
    """Return True if base a is a Miller-Rabin witness that n is COMPOSITE."""
    if n % 2 == 0:
        return n != 2
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    x = pow(a, d, n)
    if x in (1, n - 1):
        return False
    for _ in range(r - 1):
        x = (x * x) % n
        if x == n - 1:
            return False
    return True  # witness for compositeness


# ----------------------------------------------------------------------------- #
# Demonstrations.
# ----------------------------------------------------------------------------- #
def carmichael_numbers_up_to(limit: int) -> List[int]:
    return [n for n in range(3, limit + 1) if is_korselt(n)]


def demo() -> None:
    print("=" * 72)
    print("Korselt's Criterion & the Multiplicative-Order Bridge -- demonstrations")
    print("=" * 72)

    carmichaels = carmichael_numbers_up_to(10000)
    print(f"\n[1] Carmichael numbers up to 10000:\n    {carmichaels}")

    print("\n[2] Korselt <=> Fermat-pseudoprime agreement (cross-check):")
    mismatches = [n for n in range(3, 5000)
                  if is_korselt(n) != is_fermat_pseudoprime(n)]
    print(f"    mismatches in [3, 5000): {mismatches}  (empty = perfect agreement)")

    print("\n[3] The arithmetic bridge on Carmichael numbers:")
    for n in [561, 1105, 1729, 2465, 2821]:
        rows = verify_bridge(n)
        detail = ", ".join(f"(p-1={p-1}) | (n-1={n-1}): {ok}" for p, ok in rows)
        print(f"    n={n} = {factorize(n)}  ->  {detail}")

    print("\n[4] Surjectivity of the reduction map (Z/nZ)^x ->> (Z/pZ)^x:")
    for n in [561, 1105, 1729]:
        for p in factorize(n):
            print(f"    n={n}, p={p}: surjective = {reduction_surjective(n, p)}")

    print("\n[5] Homomorphisms never increase order  (ord(f(a)) | ord(a)):")
    for n in [561, 1105, 1729]:
        ok = all(hom_never_increases_order(n, p) for p in factorize(n))
        print(f"    n={n}: holds for every prime factor = {ok}")

    print("\n[6] Generalized exponent: smallest e with all units killed equals")
    print("    the Carmichael lambda(n) = lcm(p-1):")
    for n in [561, 1105, 1729]:
        lam = carmichael_lambda(n)
        local = [p - 1 for p in factorize(n)]
        from functools import reduce
        local_lcm = reduce(lcm, local, 1)
        print(f"    n={n}: lambda(n)={lam}, lcm{tuple(local)}={local_lcm}, "
              f"and lambda | (n-1) = {(n - 1) % lam == 0}")

    print("\n[7] The Fermat blind spot vs. Miller-Rabin repair on n=561:")
    n = 561
    fermat_liars = [a for a in units_mod(n) if pow(a, n - 1, n) == 1]
    print(f"    Fermat liars (bases that wrongly suggest prime): "
          f"{len(fermat_liars)} of {len(units_mod(n))} units -> "
          f"{'ALL' if len(fermat_liars) == len(units_mod(n)) else 'some'}")
    mr_witnesses = [a for a in range(2, 30) if gcd(a, n) == 1
                    and miller_rabin_witness(a, n)]
    print(f"    Miller-Rabin witnesses among small bases: {mr_witnesses[:10]} ...")
    print(f"    -> Miller-Rabin exposes 561 as composite; Fermat alone cannot.")

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    demo()


"""
Visualization for the Korselt / multiplicative-order bridge.

Produces two figures:
  (A) A heatmap of the order spectrum: for several Carmichael numbers n, the
      distribution of element orders ord(a) in (Z/nZ)^x, all dividing n-1.
  (B) A scatter plot over composites n showing, per prime factor p, whether
      (p-1) | (n-1), highlighting how Carmichael numbers light up entirely.

Requires matplotlib and numpy.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List

import matplotlib.pyplot as plt
import numpy as np


def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1]


def element_order(a: int, n: int) -> int:
    k, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        k += 1
    return k


def is_korselt(n: int) -> bool:
    f = factorize(n)
    if n <= 1 or f == {n: 1} or any(e > 1 for e in f.values()):
        return False
    return all((n - 1) % (p - 1) == 0 for p in f)


def plot_order_spectrum(numbers: List[int]) -> None:
    fig, axes = plt.subplots(1, len(numbers), figsize=(5 * len(numbers), 4))
    if len(numbers) == 1:
        axes = [axes]
    for ax, n in zip(axes, numbers):
        orders = [element_order(a, n) for a in units_mod(n)]
        # All orders must divide n-1 (the bridge, extended to all units).
        assert all((n - 1) % o == 0 for o in orders)
        ax.hist(orders, bins=range(1, max(orders) + 2), color="#3b6fb6",
                edgecolor="white")
        ax.set_title(f"n = {n} = {'·'.join(map(str, factorize(n)))}\n"
                     f"all orders divide n-1 = {n-1}")
        ax.set_xlabel("ord(a) in (Z/nZ)^x")
        ax.set_ylabel("count")
    fig.suptitle("Order spectrum of Carmichael numbers (every order | n-1)",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("order_spectrum.png", dpi=130)
    print("wrote order_spectrum.png")


def plot_divisibility_grid(limit: int = 2000) -> None:
    xs, ys, cs = [], [], []
    for n in range(3, limit):
        f = factorize(n)
        if f == {n: 1}:  # prime
            continue
        for p in f:
            xs.append(n)
            ys.append((p - 1))
            cs.append(1.0 if (n - 1) % (p - 1) == 0 else 0.0)
    fig, ax = plt.subplots(figsize=(10, 5))
    sc = ax.scatter(xs, ys, c=cs, cmap="coolwarm_r", s=6, alpha=0.6)
    for n in range(3, limit):
        if is_korselt(n):
            ax.axvline(n, color="green", alpha=0.25, lw=0.8)
    ax.set_xlabel("composite n")
    ax.set_ylabel("p - 1  (over prime factors p of n)")
    ax.set_title("Blue: (p-1) | (n-1).  Green verticals: Carmichael numbers "
                 "(all factors blue).")
    fig.colorbar(sc, label="(p-1) | (n-1) ?")
    fig.tight_layout()
    fig.savefig("divisibility_grid.png", dpi=130)
    print("wrote divisibility_grid.png")


if __name__ == "__main__":
    plot_order_spectrum([561, 1105, 1729])
    plot_divisibility_grid(2000)
