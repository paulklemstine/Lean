import Mathlib
import Applications.Collatz.Basic

/-! # Iterated Collatz maps and cryptographic obstructions

The unrestricted iterated Collatz map admits an explicit right inverse: to invert
`a` steps at a target `y`, multiply `y` by `2^a`.  Every one of those `a` steps
then follows the even branch.  The same dynamics also has an infinite,
parameterized family of collisions.  These facts are unconditional and show
that convergence of Collatz orbits, by itself, cannot provide one-wayness or
collision resistance for the unrestricted map.
-/

namespace CollatzCryptography

open Collatz

/-- The output after `a` iterations of the Collatz map. -/
def iteratedCollatz (a n : ℕ) : ℕ := T^[a] n

/-- A canonical depth-`a` preimage, obtained by taking only even reverse edges. -/
def canonicalPreimage (a y : ℕ) : ℕ := 2 ^ a * y

/-- Every natural number has the even preimage obtained by doubling it. -/
lemma T_double (n : ℕ) : T (2 * n) = n := by
  simp [T]

/-- Following `a` even reverse edges gives an exact preimage at depth `a`. -/
theorem iterate_pow_two_mul (a y : ℕ) : T^[a] (2 ^ a * y) = y := by
  induction a with
  | zero => simp
  | succ a ih =>
    rw [pow_succ]
    have harg : 2 ^ a * 2 * y = 2 * (2 ^ a * y) := by
      ac_rfl
    rw [harg, Function.iterate_succ_apply, T_double, ih]

/-- The canonical preimage operation composes additively in its depth. -/
lemma canonicalPreimage_add (a b y : ℕ) :
    canonicalPreimage (a + b) y = canonicalPreimage a (canonicalPreimage b y) := by
  simp [canonicalPreimage, pow_add, mul_assoc]

/-- The canonical preimage is a right inverse to every iterated Collatz map. -/
theorem canonicalPreimage_rightInverse (a : ℕ) :
    Function.RightInverse (canonicalPreimage a) (iteratedCollatz a) := by
  intro y
  exact iterate_pow_two_mul a y

/-- Every iterate of the unrestricted Collatz map is surjective. -/
theorem iteratedCollatz_surjective (a : ℕ) : Function.Surjective (iteratedCollatz a) := by
  exact (canonicalPreimage_rightInverse a).surjective

/-- A collision at one step remains a collision after any common suffix of steps. -/
lemma collision_propagates {x z : ℕ} (h : T x = T z) (a : ℕ) :
    iteratedCollatz (a + 1) x = iteratedCollatz (a + 1) z := by
  unfold iteratedCollatz
  rw [show a + 1 = a.succ by omega]
  rw [Function.iterate_succ_apply, Function.iterate_succ_apply, h]

/-- Each `k` yields a distinct odd/even pair with the same one-step image. -/
lemma parameterized_step_collision (k : ℕ) :
    T (2 * k + 1) = T (12 * k + 8) ∧ 2 * k + 1 ≠ 12 * k + 8 := by
  constructor
  · rw [show T (2 * k + 1) = 6 * k + 4 by
          rw [T_odd]
          · omega
          · exact ⟨k, by omega⟩]
    rw [show T (12 * k + 8) = 6 * k + 4 by
          rw [T_even]
          · omega
          · exact ⟨6 * k + 4, by omega⟩]
  · omega

/-- Every positive iterate has an explicit collision. -/
theorem iteratedCollatz_collision (a : ℕ) (ha : 0 < a) :
    ∃ x z, x ≠ z ∧ iteratedCollatz a x = iteratedCollatz a z := by
  obtain ⟨b, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : a ≠ 0)
  refine ⟨1, 8, by omega, ?_⟩
  simpa using collision_propagates (parameterized_step_collision 0).1 b

/-- No positive iterate of the unrestricted Collatz map is injective. -/
theorem iteratedCollatz_not_injective (a : ℕ) (ha : 0 < a) :
    ¬ Function.Injective (iteratedCollatz a) := by
  obtain ⟨x, z, hxz, hcollision⟩ := iteratedCollatz_collision a ha
  intro hinj
  exact hxz (hinj hcollision)

/-- The canonical inverter succeeds for every depth and every target. -/
theorem canonical_inverter_correct (a y : ℕ) :
    iteratedCollatz a (canonicalPreimage a y) = y := by
  exact iterate_pow_two_mul a y

/-- The usual convergence assertion, isolated to make its logical role explicit. -/
def CollatzConverges : Prop := ∀ n > 0, ∃ a, iteratedCollatz a n = 1

/-- Even assuming convergence, the explicit inverter still succeeds on every target.
The convergence hypothesis is retained because it is the premise proposed for the
cryptographic construction; the conclusion does not require it. -/
theorem convergence_does_not_block_inversion (_h : CollatzConverges) (a y : ℕ) :
    ∃ n, iteratedCollatz a n = y := by
  exact iteratedCollatz_surjective a y

/-- For every positive depth there is both a total explicit inverter and a collision.
This combines the two independent obstructions to the proposed unrestricted
one-way and collision-resistant construction. -/
theorem unrestricted_cryptographic_obstruction (a : ℕ) (ha : 0 < a) :
    (∀ y, iteratedCollatz a (canonicalPreimage a y) = y) ∧
      (∃ x z, x ≠ z ∧ iteratedCollatz a x = iteratedCollatz a z) := by
  constructor
  · exact canonical_inverter_correct a
  · exact iteratedCollatz_collision a ha

-- !-- Lab Notes -- !--
-- Hypothesis: Ranked by scientific impact, the investigated claims were:
-- (1) convergence forces subexponential inversion hardness; (2) positive iterates
-- form a collision-resistant hash family; (3) bounded-domain restrictions preserve
-- one-wayness; (4) reverse-orbit branching yields average-case hardness; (5) parity
-- vectors conceal inputs; (6) unrestricted iterates are surjective; and (7) even
-- reverse edges provide a compositional section.
--
-- Experiment: Claims (1) and (2), the two highest-impact proposals, fail before any
-- asymptotic model is chosen.  The input `2^a*y` maps to `y` in exactly `a` even
-- steps, while `2*k+1` and `12*k+8` collide after one step.  The latter collision
-- persists under every further iterate.  Claims (6) and (7) survive exactly.
--
-- Analysis: Forward convergence and reverse search are structurally separate.
-- The reverse graph always contains the deterministic edge `y ↦ 2*y`, so inversion
-- is not a search problem on the unrestricted natural-number domain.  Branching may
-- still matter only after a distribution or a domain restriction excludes this edge.
--
-- Critique: No runtime lower bound follows from Collatz convergence, and the present
-- results make no claim about length-preserving encodings or restricted input
-- distributions.  Surjectivity alone would not refute one-wayness, but the displayed
-- total section does; noninjectivity alone would not rule out all hashes, but the
-- explicit persistent collisions rule out the proposed raw iterate family.
--
-- Synthesis: The correct unconditional conclusion is an obstruction theorem, not a
-- cryptographic construction.  Any viable successor must specify a bounded domain,
-- an output encoding, and a distribution under which multiplication by `2^a` is
-- disallowed or does not constitute a valid inversion.

end CollatzCryptography