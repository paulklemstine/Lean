/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Boundary analysis for the extremal grid L1 mass bound

The headline bound `gridMass f m n ≤ n·m(m−1)/2 + m·n(n−1)/2`
(`GridLipschitzMass.gridMass_le`) requires the *anchoring* hypothesis
`f(0,0) = 0`.  This file makes the necessity of that hypothesis precise: dropping
the anchor lets the L1 mass grow without bound, while keeping it forces the sharp
estimate.

## Adversarial counterexample (the anchor is load-bearing)
The constant height function `f ≡ C` is 1-Lipschitz on every edge (all
differences are `0`), yet on a nonempty grid its L1 mass is `m·n·|C|`, which
exceeds any fixed bound for large `|C|`.  So *without* `f(0,0) = 0` the conclusion
is false; the anchor cannot be removed.  We prove this as
`constant_unbounded_mass`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The anchor `f(0,0)=0` in the extremal bound is not
  cosmetic — there is an admissible (1-Lipschitz) family whose mass diverges once
  the anchor is dropped.
Experiment (Experimenter): Took `f ≡ C`.  Each grid difference is `0 ≤ 1`, so it is
  1-Lipschitz; its mass is `∑∑|C| = (m·n)·|C|`, computed via `Finset.sum_const`.
  Choosing `C` large beats `triBound`, refuting the un-anchored statement.
Analysis (Analyst): The failure is structural ("needs the definition's anchor"),
  not "hard": the per-cell bound `|f(i,j)| ≤ i+j` is precisely the statement
  `|f(i,j) − f(0,0)| ≤ dist`, so removing `f(0,0)=0` removes the only normalization.
Critique (Critic): The witness is genuinely admissible (constant ⇒ 1-Lipschitz),
  the mass formula is exact (not an estimate), and `mn ≥ 1` on a nonempty grid
  makes the mass strictly grow in `|C|`.  No vacuity.
Synthesis (PI): Confirms the extremal bound is exactly the anchored statement;
  the un-anchored version is false, with an explicit diverging witness.
-/
import Catalog.Novelty.GridLipschitzMass

open Finset

namespace GridLipschitzMass

/-- The constant height function `f ≡ C` is 1-Lipschitz on every grid edge. -/
theorem const_lipschitz (C : ℤ) :
    (∀ i j : ℕ, |((fun _ _ : ℕ => C) (i + 1) j) - (fun _ _ : ℕ => C) i j| ≤ 1) ∧
    (∀ i j : ℕ, |((fun _ _ : ℕ => C) i (j + 1)) - (fun _ _ : ℕ => C) i j| ≤ 1) := by
  constructor <;> intro i j <;> simp

/-- The L1 mass of the constant height function `f ≡ C` on the `m × n` grid is
exactly `m·n·|C|`. -/
theorem gridMass_const (C : ℤ) (m n : ℕ) :
    gridMass (fun _ _ => C) m n = (m : ℤ) * (n : ℤ) * |C| := by
  unfold gridMass
  simp [Finset.sum_const, Finset.card_range]
  ring

/-- **Anchor necessity.**  On any nonempty grid, the un-anchored 1-Lipschitz mass
is unbounded: for every bound `B` there is an admissible constant height function
whose L1 mass exceeds `B`.  Hence the anchor `f(0,0) = 0` cannot be dropped from
`gridMass_le`. -/
theorem constant_unbounded_mass (m n : ℕ) (hm : 0 < m) (hn : 0 < n) (B : ℤ) :
    ∃ C : ℤ, gridMass (fun _ _ => C) m n > B := by
  refine ⟨|B| + 1, ?_⟩
  rw [gridMass_const]
  have hm1 : (1 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm
  have hn1 : (1 : ℤ) ≤ (n : ℤ) := by exact_mod_cast hn
  have hmn : (1 : ℤ) ≤ (m : ℤ) * (n : ℤ) := by nlinarith
  have hC : (0 : ℤ) ≤ |B| + 1 := by positivity
  have habs : |(|B| + 1)| = |B| + 1 := abs_of_nonneg hC
  rw [habs]
  nlinarith [abs_nonneg B, le_abs_self B]

end GridLipschitzMass