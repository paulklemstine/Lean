"""
demo.py — Numerical demonstration of the Tropical Spectral Langlands Correspondence.

This script reproduces, on concrete finite lattices, every key construction proved in
the accompanying Lean development:

  * residuated actions  (act_h, res_h)  forming a Galois connection,
  * the induced closure operator  cl_h = res_h o act_h,
  * closed elements, spectral size, and the tropical character  chi(h) = cl_h(top),
  * simple summands and their indicator eigenmeasures (valued in WithBot Z),
  * the MAIN theorem: the summand -> eigenmeasure map is injective,
  * the two-element Bool examples (spectral size 2 and 1).

Everything is self-contained: no third-party imports, full type hints, all logic inlined.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, FrozenSet, Iterable, List, Optional, Sequence, Tuple, TypeVar

T = TypeVar("T")

# ----------------------------------------------------------------------------------
# WithBot Z : the integers extended by a least element -inf  (the tropical value range)
# ----------------------------------------------------------------------------------
# We model WithBot Z as Optional[int], where None denotes BOT = -infinity.
WithBot = Optional[int]
BOT: WithBot = None


def withbot_le(a: WithBot, b: WithBot) -> bool:
    """Order on WithBot Z:  BOT <= everything;  ints by usual <=."""
    if a is BOT:
        return True
    if b is BOT:
        return False
    return a <= b


# ----------------------------------------------------------------------------------
# A finite poset / lattice given by its carrier and an order relation `leq`.
# ----------------------------------------------------------------------------------
@dataclass(frozen=True)
class Lattice:
    """A finite lattice: a carrier list plus a partial order `leq`."""
    carrier: Tuple[T, ...]
    leq: Callable[[T, T], bool]

    def join(self, x: T, y: T) -> T:
        """Least upper bound of x and y."""
        ubs = [z for z in self.carrier if self.leq(x, z) and self.leq(y, z)]
        # the join is the unique minimal upper bound
        return min(ubs, key=lambda z: sum(1 for w in ubs if self.leq(w, z)))

    def top(self) -> T:
        """Top element (above everything)."""
        return next(t for t in self.carrier if all(self.leq(x, t) for x in self.carrier))

    def bot(self) -> T:
        """Bottom element (below everything)."""
        return next(b for b in self.carrier if all(self.leq(b, x) for x in self.carrier))


# ----------------------------------------------------------------------------------
# Residuated action : forward map `act` and residual `res` forming a Galois connection
#     act(x) <= y   <=>   x <= res(y)
# ----------------------------------------------------------------------------------
@dataclass(frozen=True)
class ResidualMap:
    """A single residuated map: forward `act`, residual `res`, on a fixed lattice."""
    lat: Lattice
    act: Callable[[T], T]
    res: Callable[[T], T]

    def is_galois_connection(self) -> bool:
        """Verify  act(x) <= y  iff  x <= res(y)  for all x, y."""
        L = self.lat
        return all(
            L.leq(self.act(x), y) == L.leq(x, self.res(y))
            for x in L.carrier
            for y in L.carrier
        )

    def closure(self, x: T) -> T:
        """Closure operator  cl(x) = res(act(x))."""
        return self.res(self.act(x))

    def is_closed(self, x: T) -> bool:
        """x is closed iff cl(x) = x."""
        return self.closure(x) == x

    def closed_elements(self) -> List[T]:
        """All fixed points of the closure operator."""
        return [x for x in self.lat.carrier if self.is_closed(x)]

    def spectral_size(self) -> int:
        """Number of closed elements (size of the spectrum)."""
        return len(self.closed_elements())

    def tropical_character(self) -> T:
        """chi = cl(top): the largest closed element."""
        return self.closure(self.lat.top())

    # --- structural checks corresponding to the proved theorems ---
    def check_extensive(self) -> bool:
        return all(self.lat.leq(x, self.closure(x)) for x in self.lat.carrier)

    def check_monotone(self) -> bool:
        L = self.lat
        return all(
            (not L.leq(x, y)) or L.leq(self.closure(x), self.closure(y))
            for x in L.carrier
            for y in L.carrier
        )

    def check_idempotent(self) -> bool:
        return all(self.closure(self.closure(x)) == self.closure(x) for x in self.lat.carrier)

    def check_character_is_largest_closed(self) -> bool:
        """Theorem: every closed element is <= chi = cl(top)."""
        chi = self.tropical_character()
        return all(self.lat.leq(x, chi) for x in self.closed_elements())


# ----------------------------------------------------------------------------------
# Simple summands and indicator eigenmeasures.
# ----------------------------------------------------------------------------------
@dataclass(frozen=True)
class SimpleSummand:
    """An irreducible building block: a non-bottom, closed, closure-prime element."""
    val: T


def summand_indicator(rm: ResidualMap, s: SimpleSummand) -> Callable[[T], WithBot]:
    """mu_s(x) = 0 if s.val <= x else BOT.  An indicator eigenmeasure."""
    def mu(x: T) -> WithBot:
        return 0 if rm.lat.leq(s.val, x) else BOT
    return mu


def eigenmeasure_axioms_hold(rm: ResidualMap, s: SimpleSummand) -> Tuple[bool, bool, bool]:
    """Verify (monotone, bot->bot, closure-invariant) for the indicator of s."""
    L = rm.lat
    mu = summand_indicator(rm, s)
    mono = all(
        (not L.leq(x, y)) or withbot_le(mu(x), mu(y))
        for x in L.carrier for y in L.carrier
    )
    bot_map = mu(L.bot()) is BOT
    closure_inv = all(mu(rm.closure(x)) == mu(x) for x in L.carrier)
    return mono, bot_map, closure_inv


def is_simple_summand(rm: ResidualMap, val: T) -> bool:
    """Check the three summand conditions: ne_bot, closed, closure_prime."""
    L = rm.lat
    ne_bot = val != L.bot()
    closed = rm.is_closed(val)
    closure_prime = all(
        (not L.leq(val, rm.closure(x))) or L.leq(val, x) for x in L.carrier
    )
    return ne_bot and closed and closure_prime


def summands_to_eigenmeasures_injective(rm: ResidualMap) -> bool:
    """MAIN THEOREM check: distinct simple summands give distinct eigenmeasures."""
    L = rm.lat
    summands = [SimpleSummand(v) for v in L.carrier if is_simple_summand(rm, v)]
    # Represent each eigenmeasure by its value-vector over the carrier.
    fingerprints = []
    for s in summands:
        mu = summand_indicator(rm, s)
        fingerprints.append(tuple(mu(x) for x in L.carrier))
    return len(set(fingerprints)) == len(fingerprints)


# ----------------------------------------------------------------------------------
# Example 1 : the two-element Bool lattice  (false < true).
# ----------------------------------------------------------------------------------
def bool_lattice() -> Lattice:
    """Bool = {False, True} with False < True."""
    return Lattice(carrier=(False, True), leq=lambda a, b: (not a) or b)


def bool_identity_action() -> ResidualMap:
    """Identity action: act x = x, res x = x.  Spectral size should be 2."""
    L = bool_lattice()
    return ResidualMap(L, act=lambda x: x, res=lambda x: x)


def bool_const_false_action() -> ResidualMap:
    """Constant-false action: act _ = False, res _ = True. Spectral size should be 1."""
    L = bool_lattice()
    return ResidualMap(L, act=lambda x: False, res=lambda x: True)


# ----------------------------------------------------------------------------------
# Example 2 : the powerset lattice 2^{a,b,c} (a distributive lattice) with an action.
# ----------------------------------------------------------------------------------
def powerset_lattice(ground: Sequence[str]) -> Lattice:
    """Lattice of subsets of `ground`, ordered by inclusion."""
    elems: List[FrozenSet[str]] = []
    for bits in product([0, 1], repeat=len(ground)):
        elems.append(frozenset(g for g, b in zip(ground, bits) if b))
    return Lattice(carrier=tuple(elems), leq=lambda A, B: A <= B)


def intersection_action(lat: Lattice, mask: FrozenSet[str]) -> ResidualMap:
    """
    Forward act(X) = X & mask  (project onto `mask`).
    Residual  res(Y) = Y | (ground \\ mask)  (largest X with X & mask <= Y).
    These form a Galois connection on the powerset lattice.
    """
    ground: FrozenSet[str] = lat.top()
    comp = ground - mask
    return ResidualMap(
        lat,
        act=lambda X: X & mask,
        res=lambda Y: Y | comp,
    )


# ----------------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------------
def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def report_action(name: str, rm: ResidualMap, show_elems: Callable[[T], str] = str) -> None:
    print(f"\n--- {name} ---")
    print(f"  valid Galois connection : {rm.is_galois_connection()}")
    print(f"  closure extensive       : {rm.check_extensive()}")
    print(f"  closure monotone        : {rm.check_monotone()}")
    print(f"  closure idempotent      : {rm.check_idempotent()}")
    closed = rm.closed_elements()
    print(f"  closed elements ({rm.spectral_size()}): "
          f"{[show_elems(x) for x in closed]}")
    print(f"  tropical character chi  : {show_elems(rm.tropical_character())}")
    print(f"  chi is largest closed   : {rm.check_character_is_largest_closed()}")
    summands = [v for v in rm.lat.carrier if is_simple_summand(rm, v)]
    print(f"  simple summands         : {[show_elems(v) for v in summands]}")
    for v in summands:
        m, b, c = eigenmeasure_axioms_hold(rm, SimpleSummand(v))
        print(f"    indicator of {show_elems(v)!s:>12}: "
              f"mono={m}, bot_map={b}, closure_inv={c}")
    print(f"  SATAKE MAP INJECTIVE    : {summands_to_eigenmeasures_injective(rm)}")


def main() -> None:
    banner("TROPICAL SPECTRAL LANGLANDS CORRESPONDENCE — NUMERICAL DEMO")

    banner("Example 1: the two-element Bool lattice  (false < true)")
    report_action("Identity action  (expect spectral size 2)", bool_identity_action())
    report_action("Constant-false action  (expect spectral size 1)",
                  bool_const_false_action())

    id_rm = bool_identity_action()
    cf_rm = bool_const_false_action()
    print("\n  CHECK vs Lean theorems:")
    print(f"    boolIdentity_spectralSize  == 2 : {id_rm.spectral_size() == 2}")
    print(f"    boolConstFalse_spectralSize== 1 : {cf_rm.spectral_size() == 1}")
    print(f"    spectralSize differs (classification): "
          f"{id_rm.spectral_size() != cf_rm.spectral_size()}")

    banner("Example 2: powerset lattice 2^{a,b,c} with a projection action")
    lat = powerset_lattice(["a", "b", "c"])
    show = lambda s: "{" + ",".join(sorted(s)) + "}" if s else "{}"
    rm = intersection_action(lat, frozenset({"a", "b"}))
    report_action("Projection onto {a,b}", rm, show_elems=show)

    banner("Example 3: identity action on 2^{a,b,c} (all 7 non-bottom atoms are summands)")
    id_pow = ResidualMap(lat, act=lambda X: X, res=lambda X: X)
    report_action("Identity action on the powerset", id_pow, show_elems=show)
    print("  -> 7 distinct simple summands map to 7 distinct eigenmeasures (injective).")

    banner("Summary")
    print("Across all examples the closure operator laws hold, the tropical character")
    print("is the largest closed element, every summand indicator is a valid")
    print("eigenmeasure, and the summand -> eigenmeasure map is injective —")
    print("exactly the content of the formally verified correspondence.")


if __name__ == "__main__":
    main()
