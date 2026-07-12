"""Numerical demonstrations for Multiverse Set Theory.

This self-contained script models an abstract set-theoretic multiverse as a
finite truth table over universes and statements, and demonstrates the main
results:

  * ZFC is multiverse-true; CH, V=L, and large cardinals are independent
    hence undetermined ("no true CH").
  * Independence is equivalent to undeterminedness.
  * Forcing closure implies undeterminedness.
  * The Boolean -> tropical (min-plus) encoding turns OR into min and AND
    into +, so possibility is a tropical sum and necessity a tropical
    product, giving each statement a "tropical signature".

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, List, Tuple

INF = float("inf")


# ---------------------------------------------------------------------------
# Abstract multiverse as a finite truth table
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Multiverse:
    """A finite multiverse: universes, statements, and a truth relation."""

    universes: Tuple[str, ...]
    statements: Tuple[str, ...]
    holds: Dict[Tuple[str, str], bool]

    def truth(self, universe: str, statement: str) -> bool:
        return self.holds[(universe, statement)]


def concrete_multiverse() -> Multiverse:
    """The concrete 3-universe multiverse: L, a Cohen extension, measurable."""
    universes = ("L", "cohen", "measurable")
    statements = ("ZFC", "CH", "VeqL", "LargeCardinal")
    # T = holds, F = fails
    table = {
        ("L", "ZFC"): True,  ("L", "CH"): True,  ("L", "VeqL"): True,  ("L", "LargeCardinal"): False,
        ("cohen", "ZFC"): True, ("cohen", "CH"): False, ("cohen", "VeqL"): False, ("cohen", "LargeCardinal"): False,
        ("measurable", "ZFC"): True, ("measurable", "CH"): True, ("measurable", "VeqL"): False, ("measurable", "LargeCardinal"): True,
    }
    return Multiverse(universes, statements, table)


# ---------------------------------------------------------------------------
# Truth modalities
# ---------------------------------------------------------------------------
def multiverse_true(m: Multiverse, s: str) -> bool:
    return all(m.truth(u, s) for u in m.universes)


def multiverse_false(m: Multiverse, s: str) -> bool:
    return all(not m.truth(u, s) for u in m.universes)


def possibly_true(m: Multiverse, s: str) -> bool:
    return any(m.truth(u, s) for u in m.universes)


def independent(m: Multiverse, s: str) -> bool:
    return any(m.truth(u, s) for u in m.universes) and any(
        not m.truth(u, s) for u in m.universes
    )


def undetermined(m: Multiverse, s: str) -> bool:
    return not multiverse_true(m, s) and not multiverse_false(m, s)


def classify(m: Multiverse, s: str) -> str:
    if multiverse_true(m, s):
        return "multiverse-true"
    if multiverse_false(m, s):
        return "multiverse-false"
    return "independent / undetermined"


# ---------------------------------------------------------------------------
# Tropical (min-plus) bridge
# ---------------------------------------------------------------------------
def beta(b: bool) -> float:
    """Boolean -> tropical encoding.

    To make OR = min and AND = + a genuine semiring homomorphism, true maps
    to the tropical multiplicative unit 0 (cost 0 = achievable) and false to
    the tropical additive unit +infinity (cost inf = unreachable).
    """
    return 0.0 if b else INF


def trop_add(a: float, b: float) -> float:
    """Tropical addition = min."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary +."""
    return a + b


def tropical_sum(m: Multiverse, s: str) -> float:
    """Big tropical sum of encoded truth values (= min)."""
    acc: float = INF  # tropical additive identity
    for u in m.universes:
        acc = trop_add(acc, beta(m.truth(u, s)))
    return acc


def tropical_product(m: Multiverse, s: str) -> float:
    """Big tropical product of encoded truth values (= ordinary sum)."""
    acc: float = 0.0  # tropical multiplicative identity
    for u in m.universes:
        acc = trop_mul(acc, beta(m.truth(u, s)))
    return acc


def tropical_signature(m: Multiverse, s: str) -> Tuple[float, float]:
    return tropical_sum(m, s), tropical_product(m, s)


# Tropical units for readability.
TROP_ONE = 0.0   # multiplicative unit of the min-plus semiring
TROP_ZERO = INF  # additive unit of the min-plus semiring


# ---------------------------------------------------------------------------
# Forcing closure
# ---------------------------------------------------------------------------
def forcing_closed(
    m: Multiverse, s: str, neighbor: Dict[str, str]
) -> bool:
    """Every universe has a neighbor with the opposite truth value for s."""
    return all(
        m.truth(neighbor[u], s) != m.truth(u, s) for u in m.universes
    )


# ---------------------------------------------------------------------------
# Homomorphism verification
# ---------------------------------------------------------------------------
def verify_homomorphism() -> bool:
    """Check beta(a OR b) = min and beta(a AND b) = + on all cases."""
    ok = True
    for a in (False, True):
        for b in (False, True):
            or_ok = beta(a or b) == trop_add(beta(a), beta(b))
            and_ok = beta(a and b) == trop_mul(beta(a), beta(b))
            ok = ok and or_ok and and_ok
    return ok


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def main() -> None:
    m = concrete_multiverse()

    print("=" * 68)
    print("The concrete multiverse truth table")
    print("=" * 68)
    header = "universe".ljust(12) + "".join(s.ljust(15) for s in m.statements)
    print(header)
    for u in m.universes:
        row = u.ljust(12) + "".join(
            ("T" if m.truth(u, s) else "F").ljust(15) for s in m.statements
        )
        print(row)

    print("\n" + "=" * 68)
    print("Modalities and independence = undeterminedness")
    print("=" * 68)
    for s in m.statements:
        ind = independent(m, s)
        und = undetermined(m, s)
        assert ind == und, "Theorem 3.6 must hold"
        print(
            f"{s:14s} class={classify(m, s):28s} "
            f"independent={ind!s:5s} undetermined={und!s:5s} (equal: {ind == und})"
        )
    print("\n=> 'no true CH': CH is undetermined =", undetermined(m, "CH"))
    print("=> ZFC is multiverse-true          =", multiverse_true(m, "ZFC"))

    print("\n" + "=" * 68)
    print("Tropical signatures  (sum = min, product = ordinary sum)")
    print("=" * 68)
    for s in m.statements:
        tsum, tprod = tropical_signature(m, s)
        # Corollary: possible iff Sigma = tropical one (0);
        # necessary iff Pi = tropical one (0);
        # independent iff Sigma = 0 (possible) and Pi != 0 (not necessary).
        sig_independent = (tsum == TROP_ONE) and (tprod != TROP_ONE)
        print(
            f"{s:14s} Sigma(min)={tsum!s:5s} Pi(sum)={tprod!s:5s}  "
            f"tropical-independent={sig_independent}"
        )

    print("\n" + "=" * 68)
    print("Boolean -> tropical homomorphism check")
    print("=" * 68)
    print("beta(OR)=min and beta(AND)=+ on all 4 cases:", verify_homomorphism())

    print("\n" + "=" * 68)
    print("Forcing closure => undeterminedness")
    print("=" * 68)
    # A neighbor map witnessing CH flips: L(CH=T)->cohen(CH=F),
    # cohen(CH=F)->L(CH=T), measurable(CH=T)->cohen(CH=F).
    ch_neighbors = {"L": "cohen", "cohen": "L", "measurable": "cohen"}
    fc_ch = forcing_closed(m, "CH", ch_neighbors)
    print("CH forcing-closed via neighbor map:", fc_ch)
    if fc_ch:
        print("  => CH undetermined (Theorem 5.2):", undetermined(m, "CH"))
    # ZFC cannot be forcing-closed: no neighbor flips it.
    zfc_neighbors = {"L": "cohen", "cohen": "measurable", "measurable": "L"}
    print("ZFC forcing-closed via any neighbor map:",
          forcing_closed(m, "ZFC", zfc_neighbors))


if __name__ == "__main__":
    main()
