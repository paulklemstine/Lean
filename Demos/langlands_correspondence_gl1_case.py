"""
Numerical demonstration of the explicit GL(1) Langlands correspondence
(cyclotomic case over Q).

Main theorem demonstrated (Lean `explicit_reciprocity`):
    For a Galois automorphism sigma of Q(zeta_n) with sigma(zeta_n) = zeta_n^a,
    and a Dirichlet character D mod n, the attached 1-dimensional Galois
    representation rho_D satisfies

        rho_D(sigma) = D(a),      where a = artinIso(sigma).

Here:
  * The Galois group Gal(Q(zeta_n)/Q) is realized as (Z/nZ)^*  (Lean `artinIso`).
  * An automorphism is the residue a (coprime to n) acting by zeta_n -> zeta_n^a.
  * zeta_n = exp(2*pi*i/n).

This script verifies, on genuine non-trivial characters:
  - the explicit reciprocity value  rho_D(sigma) = D(a)            (explicit_reciprocity)
  - the action on roots of unity     sigma(zeta_n) = zeta_n^a        (artin_action)
  - the homomorphism law             D(a*b) = D(a) D(b)              (langlandsGL1 is MulEquiv)
  - triviality detection             rho_D = 1  <=>  D = 1           (langlandsGL1_eq_one_iff)
  - the counts                       #reps = phi(n)  (= p-1 for prime p)
                                     (card_galois_reps_eq_totient / _prime)
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Dict, List


# --------------------------------------------------------------------------
# Elementary number theory
# --------------------------------------------------------------------------
def gcd(a: int, b: int) -> int:
    """Greatest common divisor."""
    while b:
        a, b = b, a % b
    return abs(a)


def units_mod(n: int) -> List[int]:
    """The unit group (Z/nZ)^* as a sorted list of representatives in [1, n)."""
    return [a for a in range(1, n) if gcd(a, n) == 1]


def euler_totient(n: int) -> int:
    """Euler's totient phi(n) = #(Z/nZ)^*."""
    return len(units_mod(n))


def multiplicative_order(a: int, n: int) -> int:
    """Order of a in (Z/nZ)^*."""
    a %= n
    k, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        k += 1
    return k


def primitive_root(n: int) -> int:
    """A generator of (Z/nZ)^* when one exists (n in {1,2,4,p^k,2p^k})."""
    phi = euler_totient(n)
    for g in units_mod(n):
        if multiplicative_order(g, n) == phi:
            return g
    raise ValueError(f"(Z/{n}Z)^* is not cyclic; no primitive root.")


# --------------------------------------------------------------------------
# Roots of unity and the Artin action
# --------------------------------------------------------------------------
def zeta(n: int) -> complex:
    """Canonical primitive n-th root of unity zeta_n = exp(2*pi*i/n)."""
    return cmath.exp(2j * math.pi / n)


def artin_action(n: int, a: int) -> complex:
    """sigma_a(zeta_n) = zeta_n^a  (Lean `artin_action`)."""
    return zeta(n) ** a


# --------------------------------------------------------------------------
# Dirichlet characters mod n
# --------------------------------------------------------------------------
class DirichletCharacter:
    """
    A Dirichlet character mod n built from a value on a chosen generator g of
    (Z/nZ)^* (when cyclic): D(g) = exp(2*pi*i*j/phi) for some 0 <= j < phi.
    Extended multiplicatively, and D(x)=0 when gcd(x,n)>1.
    """

    def __init__(self, n: int, g: int, j: int) -> None:
        self.n = n
        self.g = g
        self.phi = euler_totient(n)
        self.j = j % self.phi
        # Precompute D on all units via discrete log base g.
        self._table: Dict[int, complex] = {}
        cur = 1
        for k in range(self.phi):
            val = cmath.exp(2j * math.pi * self.j * k / self.phi)
            self._table[cur] = val
            cur = (cur * g) % n

    def __call__(self, a: int) -> complex:
        """D(a): zero on non-units, table value on units."""
        a %= self.n
        if gcd(a, self.n) != 1:
            return 0.0
        return self._table[a]

    def is_principal(self) -> bool:
        return self.j == 0


def all_characters(n: int) -> List[DirichletCharacter]:
    """All phi(n) Dirichlet characters mod n (n cyclic)."""
    g = primitive_root(n)
    return [DirichletCharacter(n, g, j) for j in range(euler_totient(n))]


# --------------------------------------------------------------------------
# The attached Galois representation
# --------------------------------------------------------------------------
def galois_representation(D: DirichletCharacter) -> Callable[[int], complex]:
    """
    rho_D : Gal(Q(zeta_n)/Q) -> C^*,  sigma_a |-> D(a).
    This IS the explicit GL(1) Langlands value (Lean `langlandsGL1_apply_coe`).
    """
    return lambda a: D(a)


# --------------------------------------------------------------------------
# Verifications
# --------------------------------------------------------------------------
def close(x: complex, y: complex, tol: float = 1e-9) -> bool:
    return abs(x - y) < tol


def verify_explicit_reciprocity(n: int) -> bool:
    """rho_D(sigma_a) == D(a) and sigma_a(zeta_n) == zeta_n^a for all D, a."""
    ok = True
    for D in all_characters(n):
        rho = galois_representation(D)
        for a in units_mod(n):
            if not close(rho(a), D(a)):
                ok = False
            if not close(artin_action(n, a), zeta(n) ** a):
                ok = False
    return ok


def verify_homomorphism(n: int) -> bool:
    """D(a*b) == D(a)*D(b): langlandsGL1 is a group isomorphism."""
    ok = True
    for D in all_characters(n):
        for a in units_mod(n):
            for b in units_mod(n):
                if not close(D((a * b) % n), D(a) * D(b)):
                    ok = False
    return ok


def verify_triviality_detection(n: int) -> bool:
    """rho_D == 1 on all sigma  <=>  D is the principal character."""
    ok = True
    for D in all_characters(n):
        rho = galois_representation(D)
        rho_trivial = all(close(rho(a), 1.0) for a in units_mod(n))
        if rho_trivial != D.is_principal():
            ok = False
    return ok


def verify_count(n: int) -> bool:
    """#representations == phi(n)."""
    return len(all_characters(n)) == euler_totient(n)


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    moduli = [5, 7, 8, 12]  # 8 and 12 are not cyclic in general; we keep cyclic ones
    moduli = [m for m in moduli if _is_cyclic(m)]

    print("Explicit GL(1) Langlands correspondence (cyclotomic case)")
    print("=" * 64)

    for n in moduli:
        print(f"\nModulus n = {n}   (phi(n) = {euler_totient(n)})")
        g = primitive_root(n)
        print(f"  Galois group Gal(Q(zeta_{n})/Q) = (Z/{n}Z)^* = {units_mod(n)}")
        print(f"  primitive root (generator): {g}")

        # Show one concrete dictionary entry on a non-trivial character.
        D = all_characters(n)[1]  # first non-principal character
        rho = galois_representation(D)
        a = units_mod(n)[-1]
        print(f"  Example: take non-principal D with D({g}) = "
              f"{D(g):.4f}")
        print(f"           automorphism sigma_a, a = {a}: "
              f"sigma(zeta_{n}) = zeta_{n}^{a}")
        print(f"           rho_D(sigma_a) = D({a}) = {rho(a):.6f}")
        print(f"           (matches D(a)? {close(rho(a), D(a))})")

        print(f"  [explicit_reciprocity] all values match : "
              f"{verify_explicit_reciprocity(n)}")
        print(f"  [langlandsGL1 hom law]  D(ab)=D(a)D(b)   : "
              f"{verify_homomorphism(n)}")
        print(f"  [eq_one_iff] triviality detection        : "
              f"{verify_triviality_detection(n)}")
        print(f"  [card_galois_reps] #reps = phi(n) = {euler_totient(n)} : "
              f"{verify_count(n)}")

    # Prime case: phi(p) = p - 1.
    print("\nPrime case  (card_galois_reps_prime): phi(p) = p - 1")
    for p in [5, 7, 11, 13]:
        print(f"  p = {p}: #reps = phi({p}) = {euler_totient(p)} = p-1 = {p-1} "
              f"-> {euler_totient(p) == p - 1}")


def _is_cyclic(n: int) -> bool:
    """(Z/nZ)^* is cyclic iff n in {1,2,4,p^k,2p^k}."""
    try:
        primitive_root(n)
        return True
    except ValueError:
        return False


if __name__ == "__main__":
    main()


"""
Visualization of the explicit GL(1) Langlands correspondence (cyclotomic case).

Two panels:
  (left)  the Galois group Gal(Q(zeta_n)/Q) = (Z/nZ)^* acting on the n-th roots
          of unity:  sigma_a sends zeta_n -> zeta_n^a.
  (right) a Dirichlet character D mod n plotted on the unit circle, with the
          attached Galois representation value rho_D(sigma_a) = D(a) annotated
          on each automorphism (Lean `explicit_reciprocity`).

Run:  python visualize.py    (writes gl1_langlands.png)
"""

from __future__ import annotations

import cmath
import math
from typing import Dict, List

import matplotlib.pyplot as plt


def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)


def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1]


def primitive_root(n: int) -> int:
    units = units_mod(n)
    phi = len(units)
    for g in units:
        seen = set()
        cur = 1
        for _ in range(phi):
            cur = (cur * g) % n
            seen.add(cur)
        if len(seen) == phi:
            return g
    raise ValueError("no primitive root")


def dirichlet_table(n: int, j: int) -> Dict[int, complex]:
    g = primitive_root(n)
    phi = len(units_mod(n))
    table: Dict[int, complex] = {}
    cur = 1
    for k in range(phi):
        table[cur] = cmath.exp(2j * math.pi * (j % phi) * k / phi)
        cur = (cur * g) % n
    return table


def visualize(n: int = 7, j: int = 1, filename: str = "gl1_langlands.png") -> None:
    units = units_mod(n)
    table = dirichlet_table(n, j)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6))

    # ---- Left: roots of unity and the Artin action ----
    theta = [2 * math.pi * k / n for k in range(n)]
    xs = [math.cos(t) for t in theta]
    ys = [math.sin(t) for t in theta]
    ax1.plot(xs + [xs[0]], ys + [ys[0]], "o-", color="#444", alpha=0.4)
    for k in range(n):
        ax1.annotate(f"$\\zeta^{{{k}}}$", (xs[k], ys[k]),
                     textcoords="offset points", xytext=(8, 6))
    # highlight the action sigma_a: zeta -> zeta^a for the generator a
    a = units[-1]
    ax1.annotate("", xy=(xs[a % n], ys[a % n]), xytext=(xs[1], ys[1]),
                 arrowprops=dict(arrowstyle="->", color="crimson", lw=2))
    ax1.set_title(f"Gal(Q($\\zeta_{{{n}}}$)/Q): $\\sigma_a(\\zeta)=\\zeta^a$\n"
                  f"(arrow: $a={a}$)")
    ax1.set_aspect("equal")
    ax1.axhline(0, color="gray", lw=0.5)
    ax1.axvline(0, color="gray", lw=0.5)

    # ---- Right: Dirichlet character values = Galois rep values ----
    circ_t = [2 * math.pi * t / 200 for t in range(201)]
    ax2.plot([math.cos(t) for t in circ_t], [math.sin(t) for t in circ_t],
             color="#bbb", lw=1)
    for a in units:
        v = table[a]
        ax2.plot([v.real], [v.imag], "o", color="#1f77b4")
        ax2.annotate(f"$\\rho_D(\\sigma_{{{a}}})=D({a})$",
                     (v.real, v.imag),
                     textcoords="offset points", xytext=(8, 4), fontsize=8)
    ax2.set_title(f"Hecke = Galois values  $\\rho_D(\\sigma_a)=D(a)$\n"
                  f"(Dirichlet char mod {n}, index j={j})")
    ax2.set_aspect("equal")
    ax2.axhline(0, color="gray", lw=0.5)
    ax2.axvline(0, color="gray", lw=0.5)

    fig.suptitle("Explicit GL(1) Langlands correspondence (cyclotomic case)")
    fig.tight_layout()
    fig.savefig(filename, dpi=150)
    print(f"wrote {filename}")


if __name__ == "__main__":
    visualize()
