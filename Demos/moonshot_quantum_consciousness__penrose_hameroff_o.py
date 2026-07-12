"""Numerical demonstrations for
'Objective Reduction Timescales and the Non-Computability of Consciousness'.

This self-contained script illustrates the four groups of results:

  1. Energy-time reciprocity        E * t = hbar, and involutivity.
  2. Tubulin coherence scaling      t(N) = hbar / (E * sqrt(N)).
  3. The decoherence catastrophe    t(N) -> 0, and the whole-brain bound.
  4. Non-enumerability of states    the finite Cantor diagonal witness.

All physical constants are in SI units (J, s). Run with `python demo.py`.
"""

from __future__ import annotations

import math
from typing import Callable, FrozenSet, List, Set

# --- Physical constants (SI) --------------------------------------------------

HBAR: float = 1.054_571_817e-34   # reduced Planck constant, J*s
KT_BODY: float = 1.381e-23 * 310.15  # thermal energy kT at 37 C, ~4.28e-21 J
GAMMA_WINDOW: float = 0.5         # gamma-synchrony window, seconds
BRAIN_TUBULINS: int = 10 ** 11    # whole-brain tubulin estimate


# --- Part 1: energy-time reciprocity -----------------------------------------

def or_energy(hbar: float, t: float) -> float:
    """Self-energy induced by a collapse time t:  E = hbar / t."""
    return hbar / t


def or_time(hbar: float, energy: float) -> float:
    """Collapse time induced by a self-energy E:  t = hbar / E."""
    return hbar / energy


def demo_reciprocity() -> None:
    print("=" * 68)
    print("PART 1  Energy-time reciprocity  (E * t = hbar, involutivity)")
    print("=" * 68)
    for t in (GAMMA_WINDOW, 1e-3, 1e-9):
        e = or_energy(HBAR, t)
        t_back = or_time(HBAR, e)
        print(f"  t = {t:.3e} s -> E = {e:.3e} J -> t = {t_back:.3e} s "
              f"| E*t = {e * t:.3e} (== hbar {HBAR:.3e})")
        assert math.isclose(t_back, t, rel_tol=1e-12)
        assert math.isclose(e * t, HBAR, rel_tol=1e-12)
    # Strict antitonicity: longer events require sharper (smaller) energy.
    energies = [or_energy(HBAR, t) for t in (1e-3, 1e-2, 1e-1)]
    assert energies[0] > energies[1] > energies[2]
    print("  Monotonicity check: slower events demand smaller E  -> OK")
    print()


# --- Part 2 & 3: coherence scaling and the decoherence catastrophe ----------

def coh_time(hbar: float, energy: float, n: int) -> float:
    """Sustainable coherence time for N tubulins:  t(N) = hbar/(E*sqrt(N))."""
    return hbar / (energy * math.sqrt(n))


def crossover_tubulins(hbar: float, energy: float, t_target: float) -> float:
    """Smallest N above which coherence falls below t_target: (hbar/(E*t))^2."""
    return (hbar / (energy * t_target)) ** 2


def demo_scaling() -> None:
    print("=" * 68)
    print("PART 2/3  Coherence scaling and the decoherence catastrophe")
    print("=" * 68)
    e = KT_BODY
    # Inverse square-root scaling: N -> k^2 N divides t(N) by k.
    n0, k = 1000, 3
    ratio = coh_time(HBAR, e, n0) / coh_time(HBAR, e, k * k * n0)
    print(f"  Scaling law: t(N)/t(k^2 N) = {ratio:.6f}  (expected k = {k})")
    assert math.isclose(ratio, k, rel_tol=1e-9)

    print("\n  N            coherence time (s)")
    for n in (10 ** p for p in range(0, 13, 2)):
        print(f"  {n:<12d} {coh_time(HBAR, e, n):.3e}")

    tw = coh_time(HBAR, e, BRAIN_TUBULINS)
    print(f"\n  Whole brain N = {BRAIN_TUBULINS:.0e}:  t = {tw:.3e} s")
    print(f"  Gamma window:            {GAMMA_WINDOW:.3e} s")
    print(f"  Shortfall factor:        {GAMMA_WINDOW / tw:.3e}  "
          f"(~{math.log10(GAMMA_WINDOW / tw):.0f} orders of magnitude)")
    # Whole-brain bound from the paper (loose SI constants) : t < 1e-17 s.
    assert coh_time(2e-34, 1e-21, BRAIN_TUBULINS) < 1e-17
    print("  Whole-brain bound  t(1e11) < 1e-17 s  -> OK")

    n_star = crossover_tubulins(HBAR, e, GAMMA_WINDOW)
    print(f"  Crossover N* (coherence == gamma window): {n_star:.3e} tubulins")
    print()


# --- Part 4: the finite Cantor diagonal witness ------------------------------

def diagonal_configuration(
    universe: Set[int], index: Callable[[int], FrozenSet[int]]
) -> FrozenSet[int]:
    """Return D = { x in universe : x not in index(x) }, the unnamed config."""
    return frozenset(x for x in universe if x not in index(x))


def demo_diagonal() -> None:
    print("=" * 68)
    print("PART 4  Non-enumerability: the finite Cantor diagonal witness")
    print("=" * 68)
    universe: Set[int] = {0, 1, 2}
    # An arbitrary attempted indexing of configurations by microstates.
    table = {0: frozenset({0, 1}), 1: frozenset({1}), 2: frozenset()}
    index = lambda x: table[x]

    d = diagonal_configuration(universe, index)
    print(f"  Universe T          = {sorted(universe)}")
    for x in sorted(universe):
        print(f"  index({x})            = {set(index(x))}")
    print(f"  Diagonal config  D  = {set(d)}")
    named = {frozenset(index(x)) for x in universe}
    assert d not in named
    print(f"  D appears in the indexing? {d in named}  "
          "-> some configuration is always unnamed (Cantor)")
    # 2^|T| > |T|: strictly more configurations than microstates.
    print(f"  |T| = {len(universe)}, |P(T)| = 2^|T| = {2 ** len(universe)}  "
          "-> configuration space is strictly larger")
    print()


def main() -> None:
    demo_reciprocity()
    demo_scaling()
    demo_diagonal()
    print("All demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
