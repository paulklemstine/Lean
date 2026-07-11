"""
Hypercomputation: Computing the Uncomputable -- Numerical Demonstrations
=======================================================================

Self-contained Python illustrations of the three pillars of the accompanying
paper:

  1. The enumerative asymmetry of halting: a bounded-step probe can *confirm*
     halting but never certify non-halting (Theorems: halting is r.e.,
     non-halting is not r.e.).

  2. The finite-precision collapse: reading only the first p bits of a physical
     "oracle" stream and post-processing them yields an ordinary computable
     function; the output is invariant under changing bits beyond position p
     (Theorem: accidentally computable = essentially computable).

  3. The diagonal witness: given any listing of Boolean functions, the diagonal
     complement is a Boolean function absent from the list -- the constructive
     shadow of "the computable functions are a countable sliver of an
     uncountable whole".

Everything is standard-library Python with type hints. Run: `python demo.py`.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# Pillar 1: bounded halting probe (the r.e. semi-decision procedure)
# ---------------------------------------------------------------------------

def bounded_halt_probe(step: Callable[[int], Optional[int]],
                       start: int,
                       budget: int) -> Tuple[str, Optional[int]]:
    """Simulate an abstract program for at most `budget` steps.

    The program is presented as a one-step transition `step`, which maps a
    machine state to the next state, or returns None to signal termination.
    Returns ("halted", steps_used) if the program terminates within budget,
    otherwise ("unknown", None) -- we can NEVER return "loops forever" from a
    finite simulation. This is exactly the recursive-enumerability asymmetry.
    """
    state = start
    for used in range(budget):
        nxt = step(state)
        if nxt is None:
            return ("halted", used + 1)
        state = nxt
    return ("unknown", None)


def collatz_step(n: int) -> Optional[int]:
    """One step of the Collatz map; terminates (returns None) at n == 1."""
    if n == 1:
        return None
    return n // 2 if n % 2 == 0 else 3 * n + 1


def demo_halting_asymmetry() -> None:
    print("=" * 68)
    print("Pillar 1: halting is confirmable, non-halting is not")
    print("=" * 68)
    for start in (6, 27, 97):
        verdict, steps = bounded_halt_probe(collatz_step, start, budget=1000)
        if verdict == "halted":
            print(f"  Collatz from {start:>3}: HALTED after {steps} steps.")
        else:
            print(f"  Collatz from {start:>3}: UNKNOWN within budget "
                  f"(cannot certify non-halting).")

    # A genuinely non-terminating program: the probe is forever inconclusive.
    forever = lambda s: s + 1
    verdict, _ = bounded_halt_probe(forever, 0, budget=10_000)
    print(f"  Divergent counter    : {verdict.upper()} "
          f"-- no finite budget ever yields 'loops forever'.")
    print()


# ---------------------------------------------------------------------------
# Pillar 2: finite-precision physical oracle collapses to computable
# ---------------------------------------------------------------------------

def read_bits(stream: Callable[[int], bool], precision: int) -> List[bool]:
    """Extract the first `precision` bits of an infinite bit stream."""
    return [stream(k) for k in range(precision)]


def finite_precision_device(post: Callable[[int, List[bool]], bool],
                            stream: Callable[[int], bool],
                            precision: int) -> Callable[[int], bool]:
    """A physical device: reads `precision` oracle bits, then runs effective
    procedure `post` on (input, bits). The returned function is *ordinary
    computable* -- the finitely many bits are baked in as a constant.
    """
    bits = read_bits(stream, precision)  # a fixed, finite constant
    return lambda a: post(a, bits)


def demo_finite_precision_collapse() -> None:
    print("=" * 68)
    print("Pillar 2: finite precision = ordinary computability")
    print("=" * 68)

    # An "oracle" stream: pretend bit k encodes some uncomputable answer.
    stream_a: Callable[[int], bool] = lambda k: (k * k + 1) % 3 == 0
    # A different stream agreeing with stream_a on the first 5 bits only.
    stream_b: Callable[[int], bool] = lambda k: stream_a(k) if k < 5 else (k % 2 == 0)

    # Post-processor: XOR the input's parity with the parity of set oracle bits.
    def post(a: int, bits: List[bool]) -> bool:
        return (a % 2 == 1) ^ (sum(bits) % 2 == 1)

    p = 5
    dev_a = finite_precision_device(post, stream_a, p)
    dev_b = finite_precision_device(post, stream_b, p)

    same = all(dev_a(a) == dev_b(a) for a in range(20))
    print(f"  Precision p = {p}; streams agree on first {p} bits.")
    print(f"  Device outputs identical on inputs 0..19: {same}")
    print("  => bits beyond p are irrelevant; the device is computable.")
    print(f"  Sample outputs (input -> bit): "
          f"{[(a, dev_a(a)) for a in range(6)]}")
    print()


# ---------------------------------------------------------------------------
# Pillar 3: diagonalization -- no list captures every Boolean function
# ---------------------------------------------------------------------------

def diagonal_complement(listing: Sequence[Callable[[int], bool]]
                        ) -> Callable[[int], bool]:
    """Given f_0, f_1, ..., return d with d(n) = not f_n(n).
    Then d differs from every f_n at input n, so d is not in the list.
    """
    return lambda n: (not listing[n](n)) if n < len(listing) else True


def demo_diagonal() -> None:
    print("=" * 68)
    print("Pillar 3: the diagonal function escapes every listing")
    print("=" * 68)

    # A finite sample listing of Boolean functions on N.
    listing: List[Callable[[int], bool]] = [
        lambda n: n % 2 == 0,
        lambda n: n % 3 == 0,
        lambda n: n < 5,
        lambda n: (n * n) % 7 == 1,
        lambda n: bin(n).count("1") % 2 == 0,
    ]
    d = diagonal_complement(listing)

    for i, f in enumerate(listing):
        differ_at = i
        print(f"  d differs from f_{i} at n={differ_at}: "
              f"d={d(differ_at)}, f_{i}={f(differ_at)} "
              f"({'OK' if d(differ_at) != f(differ_at) else 'FAIL'})")
    print("  => d is a Boolean function outside the list; any countable")
    print("     listing of Boolean functions is provably incomplete.")
    print()


# ---------------------------------------------------------------------------
# Bonus: precision -> energy heuristic (divergence of resolving cost)
# ---------------------------------------------------------------------------

def resolving_energy(precision: int, hbar_over_dt: float = 1.0) -> float:
    """Heuristic energy to resolve `precision` bits: sum of per-bit costs
    E(k) ~ (hbar/dt) * 2^k, which diverges as precision grows. Illustrative
    only -- shows unbounded precision implies unbounded energy.
    """
    return sum(hbar_over_dt * (2.0 ** k) for k in range(precision))


def demo_energy_divergence() -> None:
    print("=" * 68)
    print("Bonus: unbounded precision => unbounded energy (heuristic)")
    print("=" * 68)
    for p in (4, 8, 16, 24):
        print(f"  precision {p:>2} bits -> resolving energy ~ "
              f"{resolving_energy(p):.3e} (arb. units)")
    print("  => deciding halting needs unbounded precision, hence unbounded")
    print("     energy: no finite-budget device is a hypercomputer.")
    print()


def main() -> None:
    demo_halting_asymmetry()
    demo_finite_precision_collapse()
    demo_diagonal()
    demo_energy_divergence()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
