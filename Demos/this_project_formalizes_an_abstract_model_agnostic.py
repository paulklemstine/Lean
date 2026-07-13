"""Numerical demonstrations of the tropical calculus for the set-theoretic multiverse.

This self-contained script illustrates every result of the accompanying paper on an
explicit three-universe multiverse. It uses the tropical (min-plus) semiring, in which
tropical addition is ``min`` and tropical multiplication is ordinary ``+``, with the
additive unit ``+inf`` and the multiplicative unit ``0``.

Truth values embed via the bridge map ``beta``:
    true  -> 1_trop = 0
    false -> 0_trop = +inf

Consequently existence over a finite multiverse is a tropical *sum* and universality is
a tropical *product*. Weighting each universe with a real cost turns these operators
into a shortest-path (cheapest witness) and a total-cost calculus.

Run with:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Optional, Tuple

# --------------------------------------------------------------------------------------
# The tropical (min-plus) semiring on the extended reals R u {+inf}.
# --------------------------------------------------------------------------------------

TROP_ZERO: float = math.inf   # additive unit  (min-neutral)
TROP_ONE: float = 0.0         # multiplicative unit (plus-neutral)


def trop_add(a: float, b: float) -> float:
    """Tropical addition: the minimum."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: ordinary addition (with +inf absorbing)."""
    return a + b


def trop_sum(values: List[float]) -> float:
    """Tropical sum (iterated min) of a list; empty sum is the additive unit."""
    acc = TROP_ZERO
    for v in values:
        acc = trop_add(acc, v)
    return acc


def trop_prod(values: List[float]) -> float:
    """Tropical product (iterated +) of a list; empty product is the mult. unit."""
    acc = TROP_ONE
    for v in values:
        acc = trop_mul(acc, v)
    return acc


def beta(b: bool) -> float:
    """The Boolean-to-tropical bridge map:  true -> 0 (=1_trop), false -> +inf (=0_trop)."""
    return TROP_ONE if b else TROP_ZERO


# --------------------------------------------------------------------------------------
# A concrete three-universe multiverse.
# --------------------------------------------------------------------------------------

UNIVERSES: List[str] = ["L", "Cohen", "Meas"]
STATEMENTS: List[str] = ["ZFC", "CH", "V=L", "LC"]

# holds[universe][statement] = truth of the statement in that universe.
HOLDS: Dict[str, Dict[str, bool]] = {
    "L":     {"ZFC": True,  "CH": True,  "V=L": True,  "LC": False},
    "Cohen": {"ZFC": True,  "CH": False, "V=L": False, "LC": False},
    "Meas":  {"ZFC": True,  "CH": True,  "V=L": False, "LC": True},
}

# Forcing / construction cost of each universe.
FORCING_COST: Dict[str, float] = {"L": 0.0, "Cohen": 1.0, "Meas": 5.0}


# --------------------------------------------------------------------------------------
# Modes of multiverse truth (Boolean layer).
# --------------------------------------------------------------------------------------

def multiverse_true(stmt: str) -> bool:
    """Holds in every universe."""
    return all(HOLDS[u][stmt] for u in UNIVERSES)


def multiverse_false(stmt: str) -> bool:
    """Holds in no universe."""
    return all(not HOLDS[u][stmt] for u in UNIVERSES)


def possibly_true(stmt: str) -> bool:
    """Holds in some universe."""
    return any(HOLDS[u][stmt] for u in UNIVERSES)


def independent(stmt: str) -> bool:
    """Holds somewhere and fails somewhere."""
    return (any(HOLDS[u][stmt] for u in UNIVERSES)
            and any(not HOLDS[u][stmt] for u in UNIVERSES))


def undetermined(stmt: str) -> bool:
    """Neither multiverse-true nor multiverse-false."""
    return (not multiverse_true(stmt)) and (not multiverse_false(stmt))


# --------------------------------------------------------------------------------------
# Tropical bridge: quantifiers as big operators.
# --------------------------------------------------------------------------------------

def tropical_sum_of(stmt: str) -> float:
    """Tropical sum of truth values = the additive image of existence."""
    return trop_sum([beta(HOLDS[u][stmt]) for u in UNIVERSES])


def tropical_prod_of(stmt: str) -> float:
    """Tropical product of truth values = the multiplicative image of universality."""
    return trop_prod([beta(HOLDS[u][stmt]) for u in UNIVERSES])


def tropical_signature(stmt: str) -> Tuple[float, float]:
    """Return (tropical sum, tropical product) -- the tropical signature of a statement.

    Signature classification:
        sum = 0, prod = 0     -> multiverse-true
        sum = 0, prod = +inf  -> independent
        sum = +inf            -> multiverse-false
    """
    return tropical_sum_of(stmt), tropical_prod_of(stmt)


def classify(stmt: str) -> str:
    s, p = tropical_signature(stmt)
    if s == TROP_ONE and p == TROP_ONE:
        return "multiverse-true"
    if s == TROP_ONE and p != TROP_ONE:
        return "independent (undetermined)"
    return "multiverse-false"


# --------------------------------------------------------------------------------------
# Weighted (shortest-path) calculus.
# --------------------------------------------------------------------------------------

def wcost(stmt: str, u: str, cost: Dict[str, float]) -> float:
    """Weighted cost of a universe: its real cost if the statement holds, else +inf."""
    return cost[u] if HOLDS[u][stmt] else math.inf


def cheapest_cost(stmt: str, cost: Dict[str, float]) -> float:
    """Tropical sum of weighted values = cheapest witnessing cost (a min over costs)."""
    return trop_sum([wcost(stmt, u, cost) for u in UNIVERSES])


def cheapest_witness(stmt: str, cost: Dict[str, float]) -> Optional[Tuple[str, float]]:
    """Return an actual cost-minimal witnessing universe, or None if impossible."""
    witnesses = [(u, cost[u]) for u in UNIVERSES if HOLDS[u][stmt]]
    if not witnesses:
        return None
    return min(witnesses, key=lambda pair: pair[1])


def aggregate_cost(stmt: str, cost: Dict[str, float]) -> float:
    """Tropical product of weighted values = aggregate cost of a multiverse-truth."""
    return trop_prod([wcost(stmt, u, cost) for u in UNIVERSES])


# --------------------------------------------------------------------------------------
# Forcing closure (localized closure-under-forcing axiom).
# --------------------------------------------------------------------------------------

def forcing_closed(stmt: str) -> bool:
    """True iff from every universe some universe has the opposite truth value of stmt."""
    return all(
        any(HOLDS[v][stmt] == (not HOLDS[u][stmt]) for v in UNIVERSES)
        for u in UNIVERSES
    )


# --------------------------------------------------------------------------------------
# Reporting.
# --------------------------------------------------------------------------------------

def _fmt(x: float) -> str:
    return "+inf" if x == math.inf else f"{x:g}"


def main() -> None:
    print("=" * 78)
    print("Tropical calculus for the set-theoretic multiverse")
    print("Universes:", ", ".join(UNIVERSES))
    print("=" * 78)

    print("\nTruth table:")
    header = "  universe |" + "".join(f" {s:>4}" for s in STATEMENTS)
    print(header)
    print("  " + "-" * (len(header) - 2))
    for u in UNIVERSES:
        row = f"  {u:>8} |" + "".join(f" {'T' if HOLDS[u][s] else 'F':>4}" for s in STATEMENTS)
        print(row)

    print("\nModes of multiverse truth and tropical signatures:")
    print(f"  {'stmt':>4} | {'m-true':>7} {'m-false':>7} {'poss':>5} {'indep':>6}"
          f" | {'trop-sum':>8} {'trop-prod':>9} | classification")
    print("  " + "-" * 74)
    for s in STATEMENTS:
        tsum, tprod = tropical_signature(s)
        print(f"  {s:>4} | {str(multiverse_true(s)):>7} {str(multiverse_false(s)):>7}"
              f" {str(possibly_true(s)):>5} {str(independent(s)):>6}"
              f" | {_fmt(tsum):>8} {_fmt(tprod):>9} | {classify(s)}")

    print("\nForcing closure:")
    for s in STATEMENTS:
        print(f"  {s:>4}: forcing-closed = {forcing_closed(s)}")
    print("  (CH is forcing-closed => undetermined; ZFC is not forcing-closed.)")

    print("\nWeighted shortest-path calculus (costs L=0, Cohen=1, Meas=5):")
    for s in STATEMENTS:
        cw = cheapest_witness(s, FORCING_COST)
        cc = cheapest_cost(s, FORCING_COST)
        ag = aggregate_cost(s, FORCING_COST)
        witness_str = "none (impossible)" if cw is None else f"{cw[0]} at cost {_fmt(cw[1])}"
        print(f"  {s:>4}: cheapest cost = {_fmt(cc):>5} via {witness_str:>18}"
              f" | aggregate cost = {_fmt(ag)}")

    print("\nIndependence price of CH (max of cheapest cost of CH and of not-CH):")
    # Build the negated statement as a virtual costed problem.
    neg_holds = {u: not HOLDS[u]["CH"] for u in UNIVERSES}
    ch_cost = cheapest_cost("CH", FORCING_COST)
    notch_witnesses = [FORCING_COST[u] for u in UNIVERSES if neg_holds[u]]
    notch_cost = min(notch_witnesses) if notch_witnesses else math.inf
    price = max(ch_cost, notch_cost)
    print(f"  cheapest cost of CH     = {_fmt(ch_cost)}")
    print(f"  cheapest cost of not-CH = {_fmt(notch_cost)}")
    print(f"  independence price      = {_fmt(price)}  (finite <=> genuinely independent)")

    # A few sanity assertions mirroring the theorems.
    assert multiverse_true("ZFC")
    assert independent("CH") and undetermined("CH")
    assert independent("V=L") and independent("LC")
    assert not undetermined("ZFC")
    assert all(not (HOLDS[u]["V=L"] and HOLDS[u]["LC"]) for u in UNIVERSES)
    assert tropical_signature("CH") == (TROP_ONE, TROP_ZERO)        # sum=1, prod!=1
    assert tropical_signature("ZFC") == (TROP_ONE, TROP_ONE)        # sum=1, prod=1
    assert forcing_closed("CH") and not forcing_closed("ZFC")
    assert cheapest_cost("CH", FORCING_COST) == 0.0                 # cheapest witness is L
    assert cheapest_witness("CH", FORCING_COST) == ("L", 0.0)
    print("\nAll theorem-mirroring assertions passed.")


if __name__ == "__main__":
    main()
