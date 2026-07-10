"""
The Topology of Harmony: numerical demonstrations.

This self-contained script demonstrates the main results of the accompanying
paper on the cyclic structure of musical intervals in twelve-tone equal
temperament:

  * harmonic cycle length         cycleLen(k) = 12 / gcd(12, k)
  * the complete harmonic inventory (fifth = 12, tritone = 2, ...)
  * maximality of the perfect fifth and the divisibility (Lagrange) constraint
  * the spanning-iff-coprimality characterization; generators {1,5,7,11}
  * the explicit circle-of-fifths Hamiltonian cycle
  * normalized persistence-bar lengths and the separating thresholds
  * the generalization to n-tone equal temperament (Euler totient count)

Run:  python demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List


# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------

OCTAVE: int = 12  # number of pitch classes in twelve-tone equal temperament

NOTE_NAMES: List[str] = [
    "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
]

INTERVAL_NAMES: Dict[int, str] = {
    1: "semitone",
    2: "whole tone",
    3: "minor third",
    4: "major third",
    5: "perfect fourth",
    6: "tritone",
    7: "perfect fifth",
    8: "minor sixth",
    9: "major sixth",
    10: "minor seventh",
    11: "major seventh",
}


def cycle_len(k: int, n: int = OCTAVE) -> int:
    """Harmonic cycle length of an interval of k semitones in n-TET.

    Equals the additive order of k in Z/nZ, i.e. the number of distinct pitch
    classes visited by stacking the interval before the loop closes.
    Closed form:  n / gcd(n, k).
    """
    return n // gcd(n, k % n if k % n != 0 else n)


def stack_interval(k: int, start: int = 0, n: int = OCTAVE) -> List[int]:
    """The orbit of `start` under repeated addition of k, until it closes."""
    orbit: List[int] = []
    x: int = start % n
    while x not in orbit:
        orbit.append(x)
        x = (x + k) % n
    return orbit


def bar_len(k: int, n: int = OCTAVE) -> float:
    """Normalized persistence-bar length in (0, 1]:  cycleLen(k) / n."""
    return cycle_len(k, n) / n


def circle_of_fifths(n: int = OCTAVE, step: int = 7) -> List[int]:
    """The circle of fifths: i -> (step * i) mod n for i = 0 .. n-1."""
    return [(step * i) % n for i in range(n)]


def is_hamiltonian(seq: List[int], n: int = OCTAVE) -> bool:
    """True iff `seq` is a duplicate-free enumeration of all n pitch classes."""
    return len(seq) == n and len(set(seq)) == n and set(seq) == set(range(n))


def maximal_generators(n: int = OCTAVE) -> List[int]:
    """Residues 0 < k < n coprime to n: the spanning (maximal) intervals."""
    return [k for k in range(1, n) if gcd(n, k) == 1]


def euler_totient(n: int) -> int:
    """Count of residues in [1, n] coprime to n (via the coprimality test)."""
    return sum(1 for k in range(1, n + 1) if gcd(n, k) == 1)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_closed_form() -> None:
    print("=" * 68)
    print("1. Cycle-length closed form:  cycleLen(k) = 12 / gcd(12, k)")
    print("=" * 68)
    for k in range(1, 12):
        name = INTERVAL_NAMES.get(k, f"interval {k}")
        length = cycle_len(k)
        assert length == 12 // gcd(12, k), "closed form violated"
        print(f"  k={k:2d}  {name:<15s}  gcd(12,{k:2d})={gcd(12, k)}  "
              f"cycleLen={length:2d}")
    print()


def demo_inventory() -> None:
    print("=" * 68)
    print("2. Harmonic inventory (orbits from C = 0)")
    print("=" * 68)
    facts = {7: 12, 6: 2, 4: 3, 2: 6, 3: 4, 1: 12}
    for k, expected in facts.items():
        orbit = stack_interval(k)
        names = " -> ".join(NOTE_NAMES[p] for p in orbit)
        assert len(orbit) == expected == cycle_len(k)
        print(f"  {INTERVAL_NAMES[k]:<15s} (k={k:2d}): length {len(orbit):2d}"
              f"  |  {names}")
    print()


def demo_structure() -> None:
    print("=" * 68)
    print("3. Structural results")
    print("=" * 68)
    lengths = [cycle_len(k) for k in range(1, 12)]
    print(f"  All cycle lengths <= 12                : {all(L <= 12 for L in lengths)}")
    print(f"  Fifth is maximal (12) among 1..11      : "
          f"{cycle_len(7) == max(lengths)}")
    print(f"  Every length divides 12 (Lagrange)     : "
          f"{all(12 % L == 0 for L in lengths)}")
    print(f"  Distinct lengths (divisors of 12)      : {sorted(set(lengths))}")
    gens = maximal_generators()
    print(f"  Maximal generators (coprime to 12)     : {gens}")
    assert gens == [1, 5, 7, 11]
    print()


def demo_hamiltonian() -> None:
    print("=" * 68)
    print("4. The circle of fifths as a Hamiltonian cycle")
    print("=" * 68)
    cof = circle_of_fifths()
    names = " -> ".join(NOTE_NAMES[p] for p in cof)
    print(f"  cof = {cof}")
    print(f"        {names} -> (C)")
    print(f"  length == 12               : {len(cof) == 12}")
    print(f"  no repeats                 : {len(set(cof)) == 12}")
    print(f"  covers all pitch classes   : {set(cof) == set(range(12))}")
    print(f"  is Hamiltonian             : {is_hamiltonian(cof)}")
    assert is_hamiltonian(cof)
    print()


def demo_bars() -> None:
    print("=" * 68)
    print("5. Normalized persistence bars and thresholds")
    print("=" * 68)
    for k in range(1, 12):
        b = bar_len(k)
        regime = ("TONAL (>0.5)" if b > 0.5 else
                  "short-cycle (0.2-0.5)" if b >= 0.2 else
                  "atonal-like (<0.2)")
        print(f"  k={k:2d} {INTERVAL_NAMES.get(k, ''):<15s} "
              f"barLen={b:0.3f}   {regime}")
    print()
    print(f"  Fifth   barLen(7) = {bar_len(7):.3f}  > 0.5   -> {bar_len(7) > 0.5}")
    print(f"  Tritone barLen(6) = {bar_len(6):.3f}  < 0.5   -> {bar_len(6) < 0.5}")
    assert bar_len(7) == 1.0 and bar_len(7) > 0.5
    assert abs(bar_len(6) - 1 / 6) < 1e-12 and bar_len(6) < 0.5
    print()


def demo_temperaments() -> None:
    print("=" * 68)
    print("6. Generalization to n-tone equal temperament")
    print("=" * 68)
    for n in (12, 19, 24, 31):
        gens = maximal_generators(n)
        phi = euler_totient(n)
        assert len(gens) == phi
        longest = max(cycle_len(k, n) for k in range(1, n))
        print(f"  n={n:2d}-TET: longest cycle = {longest:2d} = n,"
              f"  #generators = phi({n}) = {phi}")
    print()


def main() -> None:
    demo_closed_form()
    demo_inventory()
    demo_structure()
    demo_hamiltonian()
    demo_bars()
    demo_temperaments()
    print("All demonstrations completed and internal assertions passed.")


if __name__ == "__main__":
    main()
