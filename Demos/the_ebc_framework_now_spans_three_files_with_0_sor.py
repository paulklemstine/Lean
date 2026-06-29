"""Entropy-Bounded Computation (EBC) — numerical demonstrations.

This self-contained script illustrates the central results of the EBC framework:

  * Landauer's per-bit cost  tf = kB * T * ln(2)              (Theorem: tempFactor_pos)
  * Additivity of the cost ledger over step concatenation     (Theorem: totalCost_append)
  * The flagship budget -> step-count bound                   (Theorem: step_count_bounded_by_budget)
  * Exact brute-force search cost  2^n * tf                    (Theorem: bruteForce_cost)
  * Maxwell-demon cost additivity                             (Theorem: demon_cost_additive)
  * Polynomial vs. exponential separation (unbounded gap)     (Theorem: entropy_gap_unbounded)
  * Quantum circuit cost = measurements * tf (gates free)     (Theorems: quantum_circuit_cost,
                                                               unitary_compose_free,
                                                               quantum_cost_additive)

Run with:  python demo.py
No third-party dependencies are required.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import List

# ---------------------------------------------------------------------------
# Physical constants (SI units)
# ---------------------------------------------------------------------------

K_B: float = 1.380649e-23  # Boltzmann constant, J/K (exact, SI 2019)
ROOM_T: float = 300.0      # room temperature, K


def temp_factor(k_b: float = K_B, temperature: float = ROOM_T) -> float:
    """Landauer per-bit energy cost  tf = kB * T * ln(2)  (joules per bit).

    Corresponds to LandauerParams.tempFactor.  Theorem tempFactor_pos asserts
    this is strictly positive whenever k_b > 0 and temperature > 0.
    """
    return k_b * temperature * math.log(2.0)


# ---------------------------------------------------------------------------
# The classical cost ledger
# ---------------------------------------------------------------------------

@dataclass
class IrreversibleStep:
    """A single computation step that erases `bits_erased` bits."""
    bits_erased: int


StepSequence = List[IrreversibleStep]


def total_bits(seq: StepSequence) -> int:
    """Total number of bits erased by a step sequence (StepSequence.totalBits)."""
    return sum(step.bits_erased for step in seq)


def total_cost(seq: StepSequence, tf: float) -> float:
    """Total Landauer energy cost of a step sequence (StepSequence.totalCost)."""
    return total_bits(seq) * tf


def max_steps_in_budget(budget: float, tf: float) -> float:
    """Flagship bound: with budget B and >=1 bit erased per step, the number of
    steps is at most B / tf  (step_count_bounded_by_budget)."""
    if tf <= 0.0:
        raise ValueError("tempFactor must be positive (tempFactor_pos)")
    return budget / tf


# ---------------------------------------------------------------------------
# Search problems
# ---------------------------------------------------------------------------

@dataclass
class SearchProblem:
    """Brute-force search over a `key_bits`-bit key space."""
    key_bits: int

    def candidates(self) -> int:
        """Number of candidate keys: 2 ^ key_bits (SearchProblem.candidates)."""
        return 2 ** self.key_bits

    def brute_force(self) -> StepSequence:
        """One single-bit-erasing step per candidate (SearchProblem.bruteForce).

        Note: materializing this list is only feasible for small key_bits;
        for large key spaces use `brute_force_cost` directly.
        """
        return [IrreversibleStep(1) for _ in range(self.candidates())]

    def brute_force_cost(self, tf: float) -> float:
        """Exact brute-force cost = 2^key_bits * tf  (Theorem bruteForce_cost)."""
        return self.candidates() * tf


# ---------------------------------------------------------------------------
# Maxwell demon
# ---------------------------------------------------------------------------

@dataclass
class MaxwellDemon:
    """A demon making `measurement_count` measurements of `bits_per_measurement`
    bits each, all of which must eventually be erased."""
    measurement_count: int
    bits_per_measurement: int

    def total_bits(self) -> int:
        return self.measurement_count * self.bits_per_measurement

    def cost(self, tf: float) -> float:
        return self.total_bits() * tf

    def append(self, other: "MaxwellDemon") -> "MaxwellDemon":
        """Run one demon after another (MaxwellDemon.append): counts add, one bit
        per measurement after normalization."""
        return MaxwellDemon(self.measurement_count + other.measurement_count, 1)


# ---------------------------------------------------------------------------
# Quantum circuits (gates are free; only measurements cost)
# ---------------------------------------------------------------------------

@dataclass
class QuantumCircuit:
    """A quantum circuit abstracted by its gate and measurement counts."""
    gate_count: int
    measurement_count: int

    def cost(self, tf: float) -> float:
        """Cost = measurement_count * tf, independent of gate_count
        (Theorems quantum_circuit_cost, unitary_compose_free)."""
        return self.measurement_count * tf

    def comp(self, other: "QuantumCircuit") -> "QuantumCircuit":
        """Compose circuits: gate and measurement counts add (QuantumCircuit.comp)."""
        return QuantumCircuit(
            self.gate_count + other.gate_count,
            self.measurement_count + other.measurement_count,
        )

    def defer(self) -> "QuantumCircuit":
        """Deferred-measurement transform: counts unchanged
        (deferred_measurement_cost_invariant)."""
        return QuantumCircuit(self.gate_count, self.measurement_count)


# ---------------------------------------------------------------------------
# Reference energy scales for context
# ---------------------------------------------------------------------------

SUN_LUMINOSITY: float = 3.828e26          # watts (joules/second)
SUN_LIFETIME_SECONDS: float = 1e10 * 3.156e7  # ~10 billion years in seconds
SUN_LIFETIME_ENERGY: float = SUN_LUMINOSITY * SUN_LIFETIME_SECONDS  # ~1.2e44 J


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_per_bit_cost() -> None:
    tf = temp_factor()
    print("=" * 70)
    print("1. Landauer per-bit cost  tf = kB * T * ln(2)")
    print("=" * 70)
    print(f"   kB              = {K_B:.6e} J/K")
    print(f"   T               = {ROOM_T} K")
    print(f"   tf              = {tf:.6e} J/bit")
    print(f"   tf > 0 ?        {tf > 0}   (Theorem tempFactor_pos)")
    print()


def demo_cost_additivity() -> None:
    tf = temp_factor()
    a: StepSequence = [IrreversibleStep(3), IrreversibleStep(1)]
    b: StepSequence = [IrreversibleStep(2), IrreversibleStep(5)]
    lhs = total_cost(a + b, tf)
    rhs = total_cost(a, tf) + total_cost(b, tf)
    print("=" * 70)
    print("2. Cost is additive over concatenation (totalCost_append)")
    print("=" * 70)
    print(f"   bits(A)         = {total_bits(a)},  bits(B) = {total_bits(b)}")
    print(f"   cost(A ++ B)    = {lhs:.6e} J")
    print(f"   cost(A)+cost(B) = {rhs:.6e} J")
    print(f"   equal ?         {math.isclose(lhs, rhs)}")
    print()


def demo_budget_bound() -> None:
    tf = temp_factor()
    budget = 1.0e-18  # joules
    n_max = max_steps_in_budget(budget, tf)
    print("=" * 70)
    print("3. Budget -> step-count bound (step_count_bounded_by_budget)")
    print("=" * 70)
    print(f"   budget B        = {budget:.3e} J")
    print(f"   max steps       = B/tf = {n_max:,.1f}")
    print(f"   (each step erasing >= 1 bit costs >= tf = {tf:.3e} J)")
    print()


def demo_brute_force() -> None:
    tf = temp_factor()
    print("=" * 70)
    print("4. Brute-force search cost = 2^n * tf  (bruteForce_cost)")
    print("=" * 70)
    # small case: verify against the materialized step sequence
    small = SearchProblem(key_bits=10)
    ledger = total_cost(small.brute_force(), tf)
    formula = small.brute_force_cost(tf)
    print(f"   n=10: ledger    = {ledger:.6e} J")
    print(f"   n=10: 2^n * tf  = {formula:.6e} J   equal? {math.isclose(ledger, formula)}")
    for n in (64, 128, 256):
        cost = SearchProblem(key_bits=n).brute_force_cost(tf)
        ratio = cost / SUN_LIFETIME_ENERGY
        print(f"   n={n:3d}: cost   = {cost:.3e} J  = {ratio:.3e} x (Sun's lifetime energy)")
    print(f"   (Sun's lifetime radiant energy approx {SUN_LIFETIME_ENERGY:.3e} J)")
    print()


def demo_maxwell_demon() -> None:
    tf = temp_factor()
    d = MaxwellDemon(measurement_count=5, bits_per_measurement=1)
    e = MaxwellDemon(measurement_count=8, bits_per_measurement=1)
    combined = d.append(e)
    print("=" * 70)
    print("5. Maxwell-demon cost additivity (demon_cost_additive)")
    print("=" * 70)
    print(f"   cost(d)         = {d.cost(tf):.6e} J  ({d.measurement_count} measurements)")
    print(f"   cost(e)         = {e.cost(tf):.6e} J  ({e.measurement_count} measurements)")
    print(f"   cost(d ++ e)    = {combined.cost(tf):.6e} J  ({combined.measurement_count} measurements)")
    print(f"   additive ?      {math.isclose(combined.cost(tf), d.cost(tf) + e.cost(tf))}")
    print()


def demo_entropy_gap() -> None:
    print("=" * 70)
    print("6. Polynomial vs exponential: unbounded gap (entropy_gap_unbounded)")
    print("=" * 70)
    k = 5  # polynomial exponent n^5
    print(f"   comparing  2^n  against polynomial  n^{k}")
    # find the permanent crossover: smallest N beyond which 2^n > n^k for all n >= N
    permanent = None
    for n in range(1, 120):
        if all(2.0 ** m > float(m) ** k for m in range(n, n + 30)):
            permanent = n
            break
    if permanent is not None:
        ev, pv = 2.0 ** permanent, float(permanent) ** k
        print(f"   permanent crossover: from n={permanent} on,  2^n = {ev:.3e} > n^{k} = {pv:.3e}")
    for n in (40, 50, 60):
        gap = 2.0 ** n - float(n) ** k
        print(f"   n={n}: 2^n - n^{k} = {gap:.3e}   (gap grows without bound)")
    print()


def demo_quantum() -> None:
    tf = temp_factor()
    print("=" * 70)
    print("7. Quantum circuits: gates free, measurements cost")
    print("=" * 70)
    c1 = QuantumCircuit(gate_count=1000, measurement_count=3)
    c2 = QuantumCircuit(gate_count=5, measurement_count=3)
    print(f"   c1 (1000 gates, 3 meas) cost = {c1.cost(tf):.6e} J")
    print(f"   c2 (   5 gates, 3 meas) cost = {c2.cost(tf):.6e} J")
    print(f"   gate independence ?          {math.isclose(c1.cost(tf), c2.cost(tf))}  (quantum_circuit_cost)")
    unitary = QuantumCircuit(gate_count=10**6, measurement_count=0)
    print(f"   purely unitary circuit cost  = {unitary.cost(tf):.1f} J  (unitary_compose_free)")
    composed = c1.comp(c2)
    print(f"   cost(c1 . c2)                = {composed.cost(tf):.6e} J")
    print(f"   additive ?                   {math.isclose(composed.cost(tf), c1.cost(tf) + c2.cost(tf))}  (quantum_cost_additive)")
    deferred = c1.defer()
    print(f"   deferred(c1) cost            = {deferred.cost(tf):.6e} J")
    print(f"   cost invariant under defer ? {math.isclose(deferred.cost(tf), c1.cost(tf))}  (deferred_measurement_cost_invariant)")
    print()


def main() -> None:
    print()
    print("ENTROPY-BOUNDED COMPUTATION (EBC) — NUMERICAL DEMONSTRATIONS")
    print()
    demo_per_bit_cost()
    demo_cost_additivity()
    demo_budget_bound()
    demo_brute_force()
    demo_maxwell_demon()
    demo_entropy_gap()
    demo_quantum()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
