import Mathlib

/-!
# Hydrogen Atom: Energy Level Degeneracy

This file proves the fundamental degeneracy theorem for the hydrogen atom:
the total number of quantum states at energy level `n` is `n²`.

## Main Results

* `hydrogen_degeneracy_count`: `∑_{l=0}^{n-1} (2l+1) = n²`
* `hydrogen_quantum_pairs_count`: The set of valid `(l, m)` pairs has cardinality `n²`
* `hydrogen_total_states_up_to`: Total states from level 1 to N

## Mathematical Context

The `n²` degeneracy of the hydrogen atom reflects a hidden SO(4) symmetry
of the Coulomb potential (the Laplace–Runge–Lenz vector). This is an
"accidental" degeneracy beyond the `2l+1` degeneracy of each angular
momentum subshell mandated by rotational SO(3) symmetry.
-/

open Finset BigOperators

/-! ## Core Degeneracy Identity -/

/-
**Hydrogen degeneracy count**: The sum of the first `n` odd numbers equals `n²`.
This identity establishes that each hydrogen energy level `E_n = -1/n²` has
exactly `n²` degenerate quantum states, counting `2l+1` magnetic substates
for each angular momentum value `l ∈ {0, 1, …, n-1}`.
-/
theorem hydrogen_degeneracy_count (n : ℕ) :
    ∑ l ∈ Finset.range n, (2 * l + 1) = n ^ 2 := by
  induction n <;> simp +arith +decide [ *, Finset.sum_range_succ ];
  lia

/-- Variant for positive naturals. -/
theorem hydrogen_degeneracy_count_pnat (n : ℕ+) :
    ∑ l ∈ Finset.range n, (2 * l + 1) = (n : ℕ) ^ 2 :=
  hydrogen_degeneracy_count n

/-! ## Magnetic Quantum Number Count -/

/-
For angular momentum `l`, the number of valid magnetic quantum numbers
`m ∈ {-l, …, l}` is `2l + 1`.
-/
theorem magnetic_count (l : ℕ) :
    (Finset.Icc (-↑l : ℤ) (↑l : ℤ)).card = 2 * l + 1 := by
  convert Int.card_Icc ( -l : ℤ ) l using 1 ; ring;
  norm_cast

/-! ## Full Quantum State Counting -/

/-
The set of valid `(l, m)` pairs for principal quantum number `n` has
cardinality `n²`. This counts all quantum states at energy level `E_n`.
-/
theorem hydrogen_quantum_pairs_count (n : ℕ) :
    (Finset.sigma (Finset.range n)
      (fun l => Finset.Icc (-↑l : ℤ) (↑l : ℤ))).card = n ^ 2 := by
  convert hydrogen_degeneracy_count n using 1;
  simp +decide [ Finset.card_sigma, magnetic_count ];
  grind

/-! ## Cumulative State Count -/

/-
The total number of hydrogen states with principal quantum number
from 1 to `N` is `N(N+1)(2N+1)/6`. This is the sum of squares formula.
-/
theorem hydrogen_total_states_up_to (N : ℕ) :
    6 * ∑ n ∈ Finset.range N, (n + 1) ^ 2 = N * (N + 1) * (2 * N + 1) := by
  induction N <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-! ## Degeneracy Growth -/

/-- The degeneracy grows quadratically: `n² < (n+1)²`. -/
theorem hydrogen_degeneracy_strict_mono : StrictMono (fun n : ℕ => n ^ 2) :=
  fun _ _ h => Nat.pow_lt_pow_left h (by norm_num)