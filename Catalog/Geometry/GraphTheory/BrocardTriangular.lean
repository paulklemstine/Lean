/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Brocard–Ramanujan via Triangular (Figurate) Numbers

Brocard's problem asks for which `n` the equation `n! + 1 = m²` has a solution.
The known solutions are the *Brown numbers* `n = 4, 5, 7`, and it is a famous
**open** conjecture that there are no others.

This file approaches the problem from the **Geometry** domain, through the lens of
*figurate numbers*.  A triangular number is `T y = y (y+1) / 2` (the number of dots
in a triangular array of side `y`).  The geometric reformulation of Brocard's
problem is:

> `n! / 8` is a triangular number  ⟺  `n! + 1` is a perfect square.

The bridge is the classical identity `8 · T y + 1 = (2y+1)²`.  We make this
equivalence completely rigorous (`factorial_eq_eight_triangular_iff_brown`),
exhibit the three Brown solutions in triangular form (`triangular_indices`),
and record the structural obstruction connecting the triangular index `y` to the
square root `m = 2y + 1`.

The full classification ("only 4, 5, 7") is exactly Brocard's open problem and is
**not** claimed here; we prove the unconditional geometric equivalence and a
finite verification.

-- !-- Lab Notes -- !--
Hypotheses explored in this cycle (Hypothesizer):
  (H1)  `n!/8` triangular  ⟺  `n!+1` a perfect square.                 [PROVED]
  (H2)  The triangular index for n=4,5,7 is 2, 5, 35.                  [PROVED]
  (H3)  In any solution the square root is `m = 2y+1` (odd).           [PROVED]
  (H4)  The full classification "only {4,5,7}".                        [OPEN — Brocard]
  (H5)  No Brown numbers (triangular witnesses) for 8 ≤ n ≤ 50.        [PROVED]
Experiment (Experimenter):
  * The forward/backward bridge `8·T y + 1 = (2y+1)²` reduces everything to
    `omega`/`ring` once the `Nat` division in `T` is cleared with
    `Nat.even_mul_succ_self` ⇒ `2 ∣ y*(y+1)`.
  * Oddness of `m` is forced because `n!` is even for `n ≥ 2`.
Analysis (Analyst):
  * H1–H3, H5 are "true and provable"; H4 is "true (conjecturally) but hard" —
    it is the open Brocard–Ramanujan problem and no elementary obstruction is
    known, so we deliberately do not state it as a theorem.
  * Failure mode: stating `T y` with `Nat` division and feeding it straight to
    `ring` fails; one must first prove `2 * T y = y*(y+1)` via divisibility.
Critique (Critic):
  * The equivalence is NOT vacuous: both sides have models (n=4,5,7) and
    non-models (n=8,...,50, verified).  No `native_decide`-only main theorem;
    the equivalence is genuine algebra.
Synthesis (PI):
  * Geometric dictionary: Brown numbers ↔ triangular factorial-eighths, with the
    explicit index map y ↦ 2y+1.
-- !-- end Lab Notes -- !--
-/
import Mathlib

namespace BrocardTriangular

open Nat

/-- The `y`-th triangular number `T y = y (y+1) / 2`. -/
def triangular (y : ℕ) : ℕ := y * (y + 1) / 2

/-- The defining (division-free) identity for triangular numbers:
`2 · T y = y (y + 1)`. -/
theorem two_mul_triangular (y : ℕ) : 2 * triangular y = y * (y + 1) := by
  unfold triangular; rw [ Nat.mul_div_cancel' ] ; exact even_iff_two_dvd.mp <| by simp +arith +decide [ mul_add, parity_simps ] ;

/-- The figurate bridge: `8 · T y + 1 = (2y + 1)²`. -/
theorem eight_triangular_succ (y : ℕ) :
    8 * triangular y + 1 = (2 * y + 1) ^ 2 := by
  unfold triangular; linarith [ Nat.div_mul_cancel ( show 2 ∣ y * ( y + 1 ) from even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] ) ) ] ;

/-- In any Brown solution `n! + 1 = m²` with `n ≥ 2`, the root `m` is odd.
Indeed `n!` is even (since `2 ∣ n!`), so `m² = n! + 1` is odd, forcing `m` odd. -/
theorem brown_root_odd {n m : ℕ} (hn : 2 ≤ n)
    (h : Nat.factorial n + 1 = m ^ 2) : Odd m := by
  by_contra hm_even;
  replace h := congr_arg Even h; simp_all +decide [ parity_simps ] ;
  exact absurd h ( by rw [ Nat.odd_iff ] ; exact ne_of_eq_of_ne ( Nat.mod_eq_zero_of_dvd ( Nat.dvd_factorial ( by decide ) hn ) ) ( by decide ) )

/-- **Main geometric equivalence (Brocard via triangular numbers).**
For `n ≥ 2`, `n!/8` is a triangular number iff `n! + 1` is a perfect square,
i.e. `n` is a Brown number.  The bridge is `8·T y + 1 = (2y+1)²`. -/
theorem factorial_eq_eight_triangular_iff_brown (n : ℕ) (hn : 2 ≤ n) :
    (∃ y, Nat.factorial n = 8 * triangular y) ↔
      (∃ m, Nat.factorial n + 1 = m ^ 2) := by
  constructor <;> intro h;
  · exact ⟨ 2 * h.choose + 1, by linarith [ h.choose_spec, eight_triangular_succ h.choose ] ⟩;
  · obtain ⟨ m, hm ⟩ := h
    obtain ⟨ y, rfl ⟩ := brown_root_odd hn hm
    exact ⟨ y, by linarith [ eight_triangular_succ y ] ⟩

/-- The three Brown numbers, expressed geometrically: `n!/8` is the triangular
number with index `2, 5, 35` for `n = 4, 5, 7` respectively. -/
theorem triangular_indices :
    Nat.factorial 4 = 8 * triangular 2 ∧
    Nat.factorial 5 = 8 * triangular 5 ∧
    Nat.factorial 7 = 8 * triangular 35 := by
  decide

/-- Finite verification: for `8 ≤ n ≤ 50` there is no triangular witness, i.e.
no Brown number in that range. -/
theorem no_triangular_witness_8_to_50 (n : ℕ) (h1 : 8 ≤ n) (h2 : n ≤ 50) :
    ¬ ∃ m, Nat.factorial n + 1 = m ^ 2 := by
  interval_cases n <;> norm_num at *;
  all_goals intro x hx; have := congr_arg Nat.sqrt hx; norm_num at this;
  all_goals subst this; norm_num at hx;

end BrocardTriangular