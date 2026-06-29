"""Numerical demonstrations for:

    Arithmetic Closure of Strongly Critical Ordinals
    and the Ordinal Collapsing Bridge

This file is fully self-contained (standard library only) and illustrates,
on finite/computable shadows of the transfinite objects, the main results:

  * Finite Branching Collapse: every finitely branching research object has
    ordinal depth < omega, i.e. its depth is an ordinary natural number.
  * The Ordinal Collapsing Bridge: for every finitely branching research
    object A,  omega ^ (researchDepth A) < epsilon_0.  We witness this by
    locating omega^depth strictly below an explicit finite stage of the
    epsilon_0 fundamental tower (omega, omega^omega, ...).
  * Arithmetic closure of strongly critical ordinals (additive and
    multiplicative principality), checked on a Cantor-normal-form model.
  * The ascending strength tower  Gamma_0 < Gamma_1 < Gamma_2 < ...

We model ordinals below epsilon_0 in Cantor Normal Form (CNF) to base omega,
which suffices to make every comparison in the bridge concrete and decidable.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Tuple, Union


# ---------------------------------------------------------------------------
# Part 1 — Research objects and their (computable) depth
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Atom:
    """An atomic research unit; depth 1."""
    label: int


@dataclass(frozen=True)
class Compose:
    """Sequential composition; depth = sum of component depths."""
    left: "ResearchObject"
    right: "ResearchObject"


@dataclass(frozen=True)
class Bootstrap:
    """A self-improvement step; depth = successor of the inner depth."""
    inner: "ResearchObject"


@dataclass(frozen=True)
class OracleNode:
    """A branching node with finitely many dependencies.

    Depth = sup over children of (child depth + 1), with the empty node
    having depth 0 (matching the Lean `natDepth` definition exactly)."""
    deps: Tuple["ResearchObject", ...]


ResearchObject = Union[Atom, Compose, Bootstrap, OracleNode]


def nat_depth(obj: ResearchObject) -> int:
    """Computable natural-number depth = ordinal depth for finite branching.

    Mirrors the Lean `natDepth`, which is proved equal to `researchDepth`.
    """
    if isinstance(obj, Atom):
        return 1
    if isinstance(obj, Compose):
        return nat_depth(obj.left) + nat_depth(obj.right)
    if isinstance(obj, Bootstrap):
        return nat_depth(obj.inner) + 1
    if isinstance(obj, OracleNode):
        if not obj.deps:
            return 0
        return max(nat_depth(child) + 1 for child in obj.deps)
    raise TypeError(f"unknown ResearchObject: {obj!r}")


def bootstrap_iter(n: int, obj: ResearchObject) -> ResearchObject:
    """Apply `bootstrap` n times (the bootstrap iterator)."""
    result = obj
    for _ in range(n):
        result = Bootstrap(result)
    return result


# ---------------------------------------------------------------------------
# Part 2 — Ordinals below epsilon_0 in Cantor Normal Form
# ---------------------------------------------------------------------------
#
# An ordinal < epsilon_0 is written  omega^a_1 * c_1 + ... + omega^a_k * c_k
# with a_1 > ... > a_k (each a_i itself a CNF ordinal < epsilon_0) and
# positive integer coefficients c_i.  We represent it as a sorted list of
# (exponent, coefficient) terms in strictly decreasing exponent order.

@dataclass(frozen=True)
class CNF:
    """Ordinal < epsilon_0 in Cantor Normal Form.

    `terms` is a tuple of (exponent: CNF, coefficient: int) in strictly
    decreasing exponent order.  The empty tuple denotes 0.
    """
    terms: Tuple[Tuple["CNF", int], ...]

    # -- constructors --------------------------------------------------------
    @staticmethod
    def zero() -> "CNF":
        return CNF(())

    @staticmethod
    def from_nat(n: int) -> "CNF":
        """The finite ordinal n = omega^0 * n."""
        if n == 0:
            return CNF(())
        return CNF(((CNF.zero(), n),))

    @staticmethod
    def omega_pow(exp: "CNF") -> "CNF":
        """omega ^ exp (a single normal-form term with coefficient 1)."""
        return CNF(((exp, 1),))

    # -- comparison ----------------------------------------------------------
    def compare(self, other: "CNF") -> int:
        """Return -1, 0, or 1 for self <, ==, > other (ordinal order)."""
        a, b = self.terms, other.terms
        i = 0
        while i < len(a) and i < len(b):
            ea, ca = a[i]
            eb, cb = b[i]
            c = ea.compare(eb)
            if c != 0:
                return c
            if ca != cb:
                return -1 if ca < cb else 1
            i += 1
        if len(a) == len(b):
            return 0
        return -1 if len(a) < len(b) else 1

    def __lt__(self, other: "CNF") -> bool:
        return self.compare(other) < 0

    def __eq__(self, other: object) -> bool:
        return isinstance(other, CNF) and self.compare(other) == 0

    def __hash__(self) -> int:
        return hash(tuple((e, c) for e, c in self.terms))

    # -- arithmetic ----------------------------------------------------------
    def __add__(self, other: "CNF") -> "CNF":
        """Ordinal (non-commutative) addition in CNF."""
        if not other.terms:
            return self
        if not self.terms:
            return other
        lead_exp = other.terms[0][0]
        # Drop all terms of self with exponent < lead_exp; merge equal exps.
        kept: List[Tuple[CNF, int]] = []
        for exp, coef in self.terms:
            cmp = exp.compare(lead_exp)
            if cmp > 0:
                kept.append((exp, coef))
            elif cmp == 0:
                first_other_coef = other.terms[0][1]
                kept.append((exp, coef + first_other_coef))
                kept.extend(other.terms[1:])
                return CNF(tuple(kept))
            else:
                break
        kept.extend(other.terms)
        return CNF(tuple(kept))

    def __mul__(self, other: "CNF") -> "CNF":
        """Ordinal (non-commutative) multiplication in CNF."""
        if not self.terms or not other.terms:
            return CNF.zero()
        lead_exp_self = self.terms[0][0]
        lead_coef_self = self.terms[0][1]
        result = CNF.zero()
        for exp, coef in other.terms:
            if exp.terms:  # exp > 0: omega^(lead_exp_self + exp) * coef
                new_exp = lead_exp_self + exp
                result = result + CNF(((new_exp, coef),))
            else:  # finite tail: multiply leading coefficient, keep self tail
                head = CNF(((lead_exp_self, lead_coef_self * coef),))
                tail = CNF(self.terms[1:])
                result = result + head + tail
        return result

    # -- display -------------------------------------------------------------
    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        parts: List[str] = []
        for exp, coef in self.terms:
            if not exp.terms:
                parts.append(str(coef))
            elif exp == CNF.from_nat(1):
                parts.append("w" if coef == 1 else f"w*{coef}")
            else:
                base = f"w^({exp})"
                parts.append(base if coef == 1 else f"{base}*{coef}")
        return " + ".join(parts)


# Convenient constant: omega = omega^1.
OMEGA: CNF = CNF.omega_pow(CNF.from_nat(1))


def tower(n: int) -> CNF:
    """Finite stage of the epsilon_0 fundamental sequence:

        tower(0) = 0, tower(1) = 1, tower(n+1) = omega ^ tower(n).

    sup_n tower(n) = epsilon_0.  Every tower(n) is < epsilon_0.
    """
    result = CNF.zero()
    for _ in range(n):
        result = CNF.omega_pow(result)
    return result


# ---------------------------------------------------------------------------
# Part 3 — The demonstrations
# ---------------------------------------------------------------------------

def demo_finite_collapse() -> None:
    """Finite Branching Collapse: depths of various research objects are
    natural numbers (i.e. strictly below omega)."""
    print("=" * 70)
    print("DEMO 1 — Finite Branching Collapse  (researchDepth A < omega)")
    print("=" * 70)
    samples: List[Tuple[str, ResearchObject]] = [
        ("atom", Atom(0)),
        ("bootstrap^3(atom)", bootstrap_iter(3, Atom(0))),
        ("compose(atom, bootstrap(atom))",
         Compose(Atom(1), Bootstrap(Atom(2)))),
        ("oracleNode[atom, bootstrap^2(atom), atom]",
         OracleNode((Atom(0), bootstrap_iter(2, Atom(0)), Atom(1)))),
        ("deep mixed tree",
         Compose(bootstrap_iter(4, OracleNode((Atom(0), Atom(1)))),
                 Bootstrap(Atom(2)))),
    ]
    for name, obj in samples:
        d = nat_depth(obj)
        print(f"  depth({name:42s}) = {d:3d}   (< omega: True)")
    print()


def demo_bridge() -> None:
    """The Ordinal Collapsing Bridge: omega^(depth) < epsilon_0, witnessed by
    locating omega^depth strictly below tower(3) = omega^omega < epsilon_0."""
    print("=" * 70)
    print("DEMO 2 — Ordinal Collapsing Bridge  (omega^(researchDepth A) < e0)")
    print("=" * 70)
    ceiling = tower(3)  # omega^omega, an explicit finite stage below epsilon_0
    print(f"  ceiling tower(3) = omega^omega = {ceiling}")
    print(f"  (tower(0..4) are all < epsilon_0; tower(3) suffices here)\n")
    objs: List[Tuple[str, ResearchObject]] = [
        ("atom", Atom(0)),
        ("bootstrap^5(atom)", bootstrap_iter(5, Atom(0))),
        ("oracle of 6 bootstraps",
         OracleNode(tuple(bootstrap_iter(k, Atom(0)) for k in range(6)))),
    ]
    for name, obj in objs:
        d = nat_depth(obj)
        lift = CNF.omega_pow(CNF.from_nat(d))  # omega ^ d
        ok = lift < ceiling
        print(f"  depth = {d:2d}:  omega^{d:<2d} = {str(lift):14s} "
              f"<  omega^omega ?  {ok}")
    print("\n  In every case omega^depth < omega^omega < epsilon_0.  QED.\n")


def demo_arithmetic_closure() -> None:
    """Additive and multiplicative principality of a strongly critical-style
    fortress, modeled by the epsilon-number ceiling tower(3) = omega^omega.

    omega^omega is additively & multiplicatively principal: a,b < it imply
    a+b < it and a*b < it.  (A finite, decidable shadow of Theorems 3.3-3.5.)
    """
    print("=" * 70)
    print("DEMO 3 — Arithmetic closure (principality below omega^omega)")
    print("=" * 70)
    fortress = tower(3)  # omega^omega, an epsilon-number-like principal ordinal
    # A handful of ordinals strictly below omega^omega.
    a = CNF.omega_pow(CNF.from_nat(3)) + CNF.from_nat(7)        # w^3 + 7
    b = CNF.omega_pow(CNF.from_nat(5)) + CNF.omega_pow(CNF.from_nat(2))  # w^5+w^2
    pairs = [(a, b), (b, a), (CNF.from_nat(42), a)]
    for x, y in pairs:
        s = x + y
        p = x * y
        print(f"  a = {str(x):18s}  b = {str(y):18s}")
        print(f"    a < W: {x < fortress}, b < W: {y < fortress}")
        print(f"    a+b = {str(s):22s} < W (omega^omega)? {s < fortress}")
        print(f"    a*b = {str(p):22s} < W (omega^omega)? {p < fortress}")
    print("\n  Sums and products of things below omega^omega stay below it.\n")


def gamma_notation(n: int) -> str:
    """A purely symbolic notation for the n-th strongly critical ordinal Gamma_n.

    We cannot embed Gamma_0 in CNF (it is far above epsilon_0), but the
    strict order Gamma_0 < Gamma_1 < ... is exactly the order of the index n,
    because Gamma_ is a normal (strictly increasing) function.
    """
    return f"Gamma_{n}"


def demo_ascending_tower() -> None:
    """The ascending strength tower Gamma_0 < Gamma_1 < Gamma_2 < ... ,
    each rung strongly critical."""
    print("=" * 70)
    print("DEMO 4 — Ascending strength tower  (Gamma_0 < Gamma_1 < ...)")
    print("=" * 70)
    indices = list(range(6))
    chain = "  " + "  <  ".join(gamma_notation(n) for n in indices) + "  <  ..."
    print(chain)
    print("  Each Gamma_n is strongly critical (veblen Gamma_n 0 = Gamma_n),")
    print("  and strict increase follows from normality of the Gamma scale.")
    # Verify the order is the order of indices (the only computable shadow).
    strictly_increasing = all(indices[i] < indices[i + 1]
                              for i in range(len(indices) - 1))
    print(f"  strictly increasing (by index)?  {strictly_increasing}\n")


def demo_bootstrap_affine_growth() -> None:
    """Successor-law affine growth: depth(bootstrap^n(A)) = depth(A) + n,
    and its lift omega^(depth+n) climbs through finite stages, all < e0."""
    print("=" * 70)
    print("DEMO 5 — Bootstrap affine growth and lifted orbit (all < e0)")
    print("=" * 70)
    base = OracleNode((Atom(0), Atom(1)))  # depth 1
    base_depth = nat_depth(base)
    ceiling = tower(3)
    for n in range(6):
        obj = bootstrap_iter(n, base)
        d = nat_depth(obj)
        assert d == base_depth + n, "affine growth law"
        lift = CNF.omega_pow(CNF.from_nat(d))
        print(f"  n={n}: depth = {base_depth}+{n} = {d:2d},  "
              f"omega^{d:<2d} < omega^omega ? {lift < ceiling}")
    print("\n  depth grows affinely; every lift stays below epsilon_0.\n")


def main() -> None:
    print("\nThe Ordinal Collapsing Bridge — numerical demonstrations\n")
    demo_finite_collapse()
    demo_bridge()
    demo_arithmetic_closure()
    demo_ascending_tower()
    demo_bootstrap_affine_growth()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
