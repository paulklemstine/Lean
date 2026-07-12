"""
Thermodynamics of Mathematical Proof -- numerical demonstrations.

This self-contained script instruments the erasure theory of proof developed in
the accompanying paper. Every proof step is modelled as a function on a finite
register (the finite set of distinguishable states of a memory). We compute, for
single steps and for whole derivations (pipelines):

  * erased(f)          = log2(|domain|) - log2(|image f|)          [bits]
  * landauer(b, kB, T) = b * kB * T * ln(2)                        [joules]
  * stepDrop           = marginal per-step entropy production
  * the discrete Clausius decomposition of a pipeline's total erasure
  * monotonicity of dissipated heat under extension
  * the Bennett creation/erasure trade-off

Boltzmann's constant kB = 1.380649e-23 J/K (SI exact); room temperature T = 300 K.
"""

from __future__ import annotations

import math
from typing import Callable, Hashable, Iterable, List, Sequence, Tuple

KB: float = 1.380649e-23  # Boltzmann constant, J/K (SI exact)
ROOM_T: float = 300.0  # kelvin


# --------------------------------------------------------------------------- #
# Single-step erasure theory
# --------------------------------------------------------------------------- #
def image_card(f: Callable[[Hashable], Hashable], domain: Sequence[Hashable]) -> int:
    """Number of distinct values f attains on `domain` (|image f|)."""
    return len({f(x) for x in domain})


def erased_bits(f: Callable[[Hashable], Hashable], domain: Sequence[Hashable]) -> float:
    """Information erased by f: log2(|domain|) - log2(|image f|), in bits."""
    n = len(domain)
    if n == 0:
        return 0.0
    return math.log2(n) - math.log2(image_card(f, domain))


def landauer_cost(bits: float, kB: float = KB, T: float = ROOM_T) -> float:
    """Minimum heat (joules) dissipated by erasing `bits` bits at temperature T."""
    return bits * kB * T * math.log(2.0)


def is_injective(f: Callable[[Hashable], Hashable], domain: Sequence[Hashable]) -> bool:
    """A step is logically reversible iff it is injective on its register."""
    return image_card(f, domain) == len(domain)


# --------------------------------------------------------------------------- #
# Pipeline (derivation) theory
# --------------------------------------------------------------------------- #
def compose(fs: Sequence[Callable[[Hashable], Hashable]]) -> Callable[[Hashable], Hashable]:
    """Composite applied left-to-right in temporal order: f_k o ... o f_1."""
    def g(x: Hashable) -> Hashable:
        for f in fs:
            x = f(x)
        return x
    return g


def total_erased(
    fs: Sequence[Callable[[Hashable], Hashable]], domain: Sequence[Hashable]
) -> float:
    """Total information erased by the whole pipeline = erased(compose fs)."""
    return erased_bits(compose(fs), domain)


def clausius_decomposition(
    fs: Sequence[Callable[[Hashable], Hashable]], domain: Sequence[Hashable]
) -> List[float]:
    """Per-step entropy productions d_i >= 0 with sum d_i = total_erased(fs).

    d_i = log2(|image(compose fs[:i])|) - log2(|image(compose fs[:i+1])|).
    """
    drops: List[float] = []
    for i in range(len(fs)):
        before = image_card(compose(fs[:i]), domain)
        after = image_card(compose(fs[: i + 1]), domain)
        drops.append(math.log2(before) - math.log2(after))
    return drops


def total_heat(
    fs: Sequence[Callable[[Hashable], Hashable]],
    domain: Sequence[Hashable],
    kB: float = KB,
    T: float = ROOM_T,
) -> float:
    """Physical Landauer heat dissipated by the derivation."""
    return landauer_cost(total_erased(fs, domain), kB, T)


# --------------------------------------------------------------------------- #
# Creation / erasure ledger (Bennett trade-off)
# --------------------------------------------------------------------------- #
def created_bits(a: int, b: int) -> float:
    """Register capacity created growing an a-state register to a b-state one."""
    return math.log2(b) - math.log2(a)


def bennett_ledger(
    f: Callable[[Hashable], Hashable], domain: Sequence[Hashable], codomain_size: int
) -> Tuple[float, float]:
    """Return (erased, created) for Bennett's dilation x -> (x, f(x)).

    The dilation is injective, so it erases 0 bits, while its codomain grows to
    |alpha| * |beta|, creating exactly log2(|beta|) bits of ancilla.
    """
    dilation = lambda x: (x, f(x))  # noqa: E731
    dilation_domain = list(domain)
    erased = erased_bits(dilation, dilation_domain)
    created = created_bits(len(domain), len(domain) * codomain_size)
    return erased, created


# --------------------------------------------------------------------------- #
# Concrete gates and collapse families
# --------------------------------------------------------------------------- #
def and_gate(bits: Tuple[int, int]) -> int:
    return bits[0] & bits[1]


def not_gate(bit: int) -> int:
    return 1 - bit


def collapse_to_zero(_x: Hashable) -> int:
    return 0


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_gates() -> None:
    print("=" * 70)
    print("SINGLE-STEP ERASURE: reversible vs. irreversible gates")
    print("=" * 70)

    and_dom = [(a, b) for a in (0, 1) for b in (0, 1)]
    e_and = erased_bits(and_gate, and_dom)
    print(f"AND gate  : |domain|=4, |image|={image_card(and_gate, and_dom)}, "
          f"erased={e_and:.4f} bit(s), injective={is_injective(and_gate, and_dom)}")
    print(f"            Landauer heat @300K = {landauer_cost(e_and):.3e} J")

    not_dom = [0, 1]
    e_not = erased_bits(not_gate, not_dom)
    print(f"NOT gate  : |domain|=2, |image|={image_card(not_gate, not_dom)}, "
          f"erased={e_not:.4f} bit(s), injective={is_injective(not_gate, not_dom)}")
    print("  => NOT is a nontrivial bijection that erases nothing: "
          "'every step erases' is FALSE.")


def demo_collapse_family() -> None:
    print("\n" + "=" * 70)
    print("UNBOUNDED COST: linear and exponential collapse families")
    print("=" * 70)
    print(f"{'n':>3} | {'|register|':>12} | {'erased (bits)':>14} | {'heat @300K (J)':>16}")
    print("-" * 55)
    for n in range(1, 9):
        dom = list(range(2 ** n))  # n-bit register
        e = erased_bits(collapse_to_zero, dom)  # collapses to a single point
        print(f"{n:>3} | {2 ** n:>12} | {e:>14.4f} | {landauer_cost(e):>16.3e}")
    print("erased(collapse_n) = n bits: linear and unbounded.")
    print("A bigCollapse over 2^m states would erase 2^m bits: exponential.")


def demo_pipeline_clausius() -> None:
    print("\n" + "=" * 70)
    print("DISCRETE CLAUSIUS INEQUALITY for a derivation pipeline")
    print("=" * 70)
    # Register: integers 0..7 (a 3-bit register).
    domain = list(range(8))
    # A derivation of three steps, each collapsing more structure:
    step1 = lambda x: x % 4          # 8 -> 4 distinct values  (erases 1 bit)
    step2 = lambda x: x % 2          # 4 -> 2 distinct values  (erases 1 bit)
    step3 = lambda x: 0              # 2 -> 1 distinct value    (erases 1 bit)
    fs = [step1, step2, step3]

    drops = clausius_decomposition(fs, domain)
    total = total_erased(fs, domain)
    print(f"register size = {len(domain)} (3-bit)")
    for i, d in enumerate(drops, 1):
        print(f"  step {i}: entropy production d_{i} = {d:.4f} bit(s)  (>= 0)")
    print(f"  sum of productions      = {sum(drops):.4f} bits")
    print(f"  total_erased(pipeline)  = {total:.4f} bits")
    assert abs(sum(drops) - total) < 1e-12, "Clausius identity must hold exactly"
    print("  Clausius identity  sum d_i = total_erased  VERIFIED.")
    print(f"  total Landauer heat @300K = {total_heat(fs, domain):.3e} J")

    # Monotonicity under extension: append a reversible relabelling.
    reversible = lambda x: x  # identity step adds zero
    print("\n  Monotonicity check (append steps -> heat never decreases):")
    running: List[Callable[[Hashable], Hashable]] = []
    prev = 0.0
    for i, f in enumerate(fs + [reversible], 1):
        running.append(f)
        h = total_heat(running, domain)
        flag = "OK" if h >= prev - 1e-18 else "VIOLATION"
        print(f"    prefix length {i}: heat = {h:.3e} J  [{flag}]")
        prev = h


def demo_bennett() -> None:
    print("\n" + "=" * 70)
    print("BENNETT CREATION/ERASURE LEDGER")
    print("=" * 70)
    and_dom = [(a, b) for a in (0, 1) for b in (0, 1)]
    codomain_size = 2  # AND outputs live in {0, 1}
    erased, created = bennett_ledger(and_gate, and_dom, codomain_size)
    print("Bennett dilation of the AND gate: x -> (x, AND(x))")
    print(f"  erased  = {erased:.4f} bits (reversible: computation itself is free)")
    print(f"  created = {created:.4f} bits = log2(|codomain|) = log2({codomain_size})")
    print("  Reversibility is financed by allocation, not granted for free.")


def demo_incompressible() -> None:
    print("\n" + "=" * 70)
    print("KOLMOGOROV COUNTING BOUND: some predicates are intrinsically hot")
    print("=" * 70)
    print(f"{'n':>3} | {'predicates 2^n':>16} | {'short progs 2^n-1':>18} | fits?")
    print("-" * 55)
    for n in range(1, 7):
        predicates = 2 ** n
        short_programs = 2 ** n - 1
        fits = predicates <= short_programs
        print(f"{n:>3} | {predicates:>16} | {short_programs:>18} | {fits}")
    print("Since 2^n > 2^n - 1, some predicate has no program shorter than n bits;")
    print("verifying it erases >= n bits, dissipating >= n * kB * T * ln2 joules.")


def main() -> None:
    demo_gates()
    demo_collapse_family()
    demo_pipeline_clausius()
    demo_bennett()
    demo_incompressible()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
