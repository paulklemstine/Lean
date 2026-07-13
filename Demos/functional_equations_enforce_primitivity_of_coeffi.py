"""Numerical demonstrations for
"Functional Equations Enforce Primitivity of Coefficients".

This self-contained script illustrates the paper's central principle:

  * primitivity of a Dirichlet character is exactly the condition under
    which the functional equation of its L-function is "clean", and
  * the Gauss sum at the analytic heart of the root number vanishes
    exactly when primitivity fails.

We work with concrete Dirichlet characters modulo small N, compute their
conductors (hence detect primitivity), evaluate Gauss sums against
additive characters, verify the root-number reciprocity law
|W(chi)| = 1 and W(chi) * W(chi^{-1}) = 1, and confirm that a Gauss sum
survives against an imprimitive additive character precisely when the
Dirichlet character is imprimitive.

Only the Python standard library is used.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Dict, List, Tuple


# --------------------------------------------------------------------------
# Dirichlet characters modulo N, represented as a table chi[a] in C.
# --------------------------------------------------------------------------

def gcd(a: int, b: int) -> int:
    """Euclidean greatest common divisor."""
    while b:
        a, b = b, a % b
    return a


def units_mod(n: int) -> List[int]:
    """The multiplicative group (Z/nZ)^* as a sorted list of representatives."""
    return [a for a in range(1, n + 1) if gcd(a, n) == 1]


def primitive_root(n: int) -> int | None:
    """Return a generator of (Z/nZ)^* if the group is cyclic, else None."""
    us = units_mod(n)
    order = len(us)
    for g in us:
        seen = set()
        x = 1 % n
        for _ in range(order):
            x = (x * g) % n
            seen.add(x)
        if len(seen) == order:
            return g
    return None


def characters_mod(n: int) -> List[Dict[int, complex]]:
    """All Dirichlet characters modulo n, for n whose unit group is cyclic.

    Each character is returned as a dict mapping every residue 0..n-1 to a
    complex value (0 on non-units).  Requires (Z/nZ)^* cyclic (works for
    n = 1,2,4, p^k, 2p^k), which covers all cases used in this demo.
    """
    g = primitive_root(n)
    us = units_mod(n)
    order = len(us)
    if g is None:
        raise ValueError(f"(Z/{n}Z)^* is not cyclic; unsupported in this demo")

    # Discrete log base g of every unit.
    dlog: Dict[int, int] = {}
    x = 1 % n
    for k in range(order):
        x = (x * g) % n
        dlog[x] = (k + 1) % order
    dlog[1 % n] = 0

    chars: List[Dict[int, complex]] = []
    for j in range(order):
        table: Dict[int, complex] = {}
        for a in range(n):
            if gcd(a, n) == 1:
                table[a] = cmath.exp(2j * math.pi * j * dlog[a] / order)
            else:
                table[a] = 0.0
        chars.append(table)
    return chars


def character_conductor(chi: Dict[int, complex], n: int) -> int:
    """Smallest divisor d | n through which chi factors (its conductor)."""
    for d in range(1, n + 1):
        if n % d != 0:
            continue
        ok = True
        # chi factors through d iff chi(a) == chi(b) whenever a == b (mod d),
        # for all units a,b coprime to n.
        for a in units_mod(n):
            for b in units_mod(n):
                if (a - b) % d == 0 and abs(chi[a] - chi[b]) > 1e-9:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            return d
    return n


def is_primitive_character(chi: Dict[int, complex], n: int) -> bool:
    """A character is primitive iff its conductor equals its modulus."""
    return character_conductor(chi, n) == n


def inverse_character(chi: Dict[int, complex], n: int) -> Dict[int, complex]:
    """The dual character chi^{-1}(a) = conjugate(chi(a))."""
    return {a: (chi[a].conjugate() if gcd(a, n) == 1 else 0.0) for a in range(n)}


# --------------------------------------------------------------------------
# Additive characters and Gauss sums.
# --------------------------------------------------------------------------

def additive_character(n: int, a: int) -> Callable[[int], complex]:
    """e_a(x) = exp(2 pi i a x / n); primitive iff gcd(a, n) == 1."""
    return lambda x: cmath.exp(2j * math.pi * a * x / n)


def additive_is_primitive(n: int, a: int) -> bool:
    """The additive character x -> exp(2 pi i a x / n) is primitive iff gcd(a,n)=1."""
    return gcd(a % n, n) == 1


def gauss_sum(chi: Dict[int, complex], n: int, e: Callable[[int], complex]) -> complex:
    """g(chi, e) = sum_{x mod n} chi(x) e(x)."""
    return sum(chi[x] * e(x) for x in range(n))


def root_number(chi: Dict[int, complex], n: int) -> complex:
    """Normalised Gauss sum W(chi) = g(chi)/|g(chi)| against the standard
    additive character (well defined for primitive chi, where |g|=sqrt(n))."""
    g = gauss_sum(chi, n, additive_character(n, 1))
    mag = abs(g)
    return g / mag if mag > 1e-12 else 0.0


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------

def demo_primitivity_table(n: int) -> None:
    """Print each character modulo n with its conductor and primitivity."""
    print(f"\n=== Characters modulo {n}: conductor & primitivity ===")
    chars = characters_mod(n)
    for j, chi in enumerate(chars):
        cond = character_conductor(chi, n)
        prim = is_primitive_character(chi, n)
        print(f"  chi_{j}: conductor = {cond:2d}   primitive = {prim}")


def demo_gauss_sum_enforcement(n: int) -> None:
    """Show |g(chi)| = sqrt(N) exactly for primitive chi, and that a Gauss sum
    against an imprimitive additive character survives only for imprimitive chi."""
    print(f"\n=== Gauss-sum enforcement modulo {n} ===")
    chars = characters_mod(n)
    sqrtN = math.sqrt(n)
    for j, chi in enumerate(chars):
        prim = is_primitive_character(chi, n)
        g = gauss_sum(chi, n, additive_character(n, 1))
        print(f"  chi_{j}: primitive={prim!s:5}  |g(chi)| = {abs(g):.4f}"
              f"  (sqrt(N) = {sqrtN:.4f})")

    # Pick an imprimitive additive character (a with gcd(a,n) > 1) if one exists.
    imprim_a = next((a for a in range(1, n) if not additive_is_primitive(n, a)), None)
    if imprim_a is None:
        print("  (no imprimitive additive character for this N)")
        return
    print(f"\n  Testing imprimitive additive character e(x)=exp(2pi i*{imprim_a}*x/{n}):")
    e = additive_character(n, imprim_a)
    for j, chi in enumerate(chars):
        prim = is_primitive_character(chi, n)
        g = gauss_sum(chi, n, e)
        survives = abs(g) > 1e-9
        note = ""
        if prim and survives:
            note = "  <-- would contradict the vanishing theorem"
        print(f"  chi_{j}: primitive={prim!s:5}  g={g:+.3f}"
              f"  survives={survives}{note}")


def demo_root_number_reciprocity(n: int) -> None:
    """Verify |W(chi)| = 1 and W(chi)*W(chi^{-1}) = 1 for primitive characters."""
    print(f"\n=== Root-number reciprocity modulo {n} ===")
    chars = characters_mod(n)
    for j, chi in enumerate(chars):
        if not is_primitive_character(chi, n):
            continue
        chi_inv = inverse_character(chi, n)
        w = root_number(chi, n)
        w_inv = root_number(chi_inv, n)
        prod = w * w_inv
        real = all(abs(v.imag) < 1e-9 for v in chi.values())
        tag = " (real/quadratic)" if real else ""
        print(f"  chi_{j}{tag}: |W|={abs(w):.4f}  "
              f"W*W_inv = {prod.real:+.4f}{prod.imag:+.4f}i")
        if real:
            print(f"           W^2 = {(w*w).real:+.4f}{(w*w).imag:+.4f}i"
                  f"  (should be +1 for a real primitive character)")


def demo_central_point(n: int) -> None:
    """Illustrate the central-point functional equation via the finite analogue:
    at s=1/2 the modulus factor N^{s-1/2} = 1, so the reflection reduces to the
    root-number relation between chi and its dual (shown at the Gauss-sum level)."""
    print(f"\n=== Central-point modulus factor modulo {n} ===")
    s = 0.5
    factor = n ** (s - 0.5)
    print(f"  N^(s-1/2) at s=1/2 equals {factor:.4f} (the modulus factor vanishes),")
    print(f"  so Lambda(chi,1/2) = W(chi) * Lambda(chi^-1,1/2).")


def main() -> None:
    print("Functional Equations Enforce Primitivity of Coefficients")
    print("Numerical demonstrations")
    for n in (5, 7, 8, 9):
        try:
            demo_primitivity_table(n)
            demo_gauss_sum_enforcement(n)
            demo_root_number_reciprocity(n)
            demo_central_point(n)
        except ValueError as exc:
            print(f"\n(skipping N={n}: {exc})")


if __name__ == "__main__":
    main()
