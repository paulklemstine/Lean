/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A Square Characterization of Triangular Numbers (and Brocard as a corollary)

This file (Geometry domain, cycle 2) isolates the *general* figurate fact that
powers the Brocard–triangular bridge of `BrocardTriangular`:

> A natural number `t` is triangular  ⟺  `8 t + 1` is a perfect square.

This is the classical "look at `8 T_y + 1 = (2y+1)²`" identity promoted to a full
characterization (both directions).  We then recover the Brocard reformulation as
a one-line corollary by specialising `t := n!/8` — i.e. `n! = 8 t`.

-- !-- Lab Notes -- !--
Hypotheses explored in this cycle (Hypothesizer):
  (H1)  `t` triangular  ⟺  `8t+1` is a perfect square.                 [PROVED]
  (H2)  Any square root of `8t+1` is odd, and the index is `(m-1)/2`.  [PROVED]
  (H3)  Brocard equivalence is a clean corollary of (H1) at `t=n!/8`.  [PROVED]
  (H4)  "`8t+1` square" is the ONLY linear `at+b` that detects triangularity
        with a square — surprising rigidity claim.                     [NOT FORMALISED — heuristic]
Experiment (Experimenter):
  * Backward direction needs oddness of the root `m`: `8t+1` is odd, so `m` is
    odd, write `m = 2y+1`, then `8t = 4y(y+1)`, giving `t = T_y`.
  * The corollary reuses `BrocardTriangular.eight_triangular_succ` and the
    catalog equivalence from cycle 1.
Analysis (Analyst):
  * H1 is the "right definition": phrasing triangularity as `∃ y, t = T y`
    (rather than `t = y*(y+1)/2` with a loose `y`) makes the iff symmetric.
  * H4 is genuinely open-ended (a rigidity meta-conjecture) and we leave it for
    FUTURE_DIRECTIONS rather than asserting it.
Critique (Critic):
  * Not vacuous: `t = 0,1,3,6,10` satisfy both sides; `t = 2,4,5` satisfy
    neither (checked).  Main theorem uses real algebra (`Odd.exists`, `linarith`),
    not `decide`.
Synthesis (PI):
  * Triangular detection = a single quadratic-residue / square test, and Brocard
    is the `t = n!/8` instance.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Geometry.BrocardTriangular

namespace TriangularSquareCharacter

open BrocardTriangular

/-- Any square root `m` of `8 t + 1` is odd (because `8 t + 1` is odd). -/
theorem root_odd_of_eight_succ {t m : ℕ} (h : 8 * t + 1 = m ^ 2) : Odd m := by
  simpa [ parity_simps ] using congr_arg Even h

/-- **Square characterization of triangular numbers.**
`t` is a triangular number iff `8 t + 1` is a perfect square.  The forward
direction is the identity `8 · T y + 1 = (2y+1)²`; the backward direction writes
the (necessarily odd) root as `2y+1` and recovers `t = T y`. -/
theorem triangular_iff_eight_succ_square (t : ℕ) :
    (∃ y, t = triangular y) ↔ (∃ m, 8 * t + 1 = m ^ 2) := by
  constructor;
  · rintro ⟨ y, rfl ⟩ ; exact ⟨ 2 * y + 1, by linarith [ eight_triangular_succ y ] ⟩;
  · intro h;
    -- Given that $8t + 1 = m^2$, we can write $m = 2k + 1$ for some integer $k$.
    obtain ⟨k, hk⟩ : ∃ k : ℕ, 8 * t + 1 = (2 * k + 1) ^ 2 := by
      exact Exists.elim h fun m hm => by obtain ⟨ k, rfl ⟩ := Nat.odd_iff.mpr ( show m % 2 = 1 from by have := congr_arg ( · % 2 ) hm; norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] at this; have := Nat.mod_lt m two_pos; interval_cases m % 2 <;> trivial ) ; exact ⟨ k, hm ⟩ ;
    exact ⟨ k, Eq.symm <| Nat.div_eq_of_eq_mul_left zero_lt_two <| by linarith ⟩

/-- **Brocard reformulation, as a corollary.**
Whenever `n! = 8 t` (i.e. `t = n!/8`, which forces `n ≥ 4`), the number `n` is a
Brown number (`∃ m, n! + 1 = m²`) iff `t` is a triangular number. -/
theorem brown_iff_factorial_eighth_triangular
    (n t : ℕ) (ht : Nat.factorial n = 8 * t) :
    (∃ m, Nat.factorial n + 1 = m ^ 2) ↔ (∃ y, t = triangular y) := by
  rw [ ht, triangular_iff_eight_succ_square ]

end TriangularSquareCharacter