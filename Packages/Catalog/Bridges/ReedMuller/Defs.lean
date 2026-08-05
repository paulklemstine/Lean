/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Basic weight definitions for generalized Reed–Muller codes

The Reed–Muller files of the catalog (`Bridges.ReedMuller.ExtremalPoly`,
`Bridges.ReedMuller.FiberRestriction`, `Bridges.ReedMuller.MinDistance`) all
speak about the *evaluation word* of a multivariate polynomial over a finite
field: the function `x ↦ eval x f` on `𝔽ⁿ`.  This file collects the two counting
functions they use, together with the elementary relations between them.

## Main definitions

- `GRM.hammingWeight f`: the number of points of `𝔽ⁿ` at which `f` does not
  vanish, i.e. the Hamming weight of the evaluation word of `f`.
- `GRM.zeroCount f`: the number of points at which `f` vanishes.

## Main results

- `GRM.hammingWeight_add_zeroCount`: the two counts add up to `qⁿ`.
- `GRM.hammingWeight_eq`: `hammingWeight f = qⁿ - zeroCount f`.
-/

open MvPolynomial Finset Fintype

namespace GRM

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-- The Hamming weight of the evaluation word of `f`: the number of points of
`𝔽ⁿ` at which `f` does not vanish. -/
noncomputable def hammingWeight {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) : ℕ :=
  (Finset.univ.filter fun x : Fin n → 𝔽 => MvPolynomial.eval x f ≠ 0).card

/-- The number of points of `𝔽ⁿ` at which `f` vanishes. -/
noncomputable def zeroCount {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) : ℕ :=
  (Finset.univ.filter fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0).card

omit [Field 𝔽] [DecidableEq 𝔽] in
/-- The affine space `𝔽ⁿ` has `qⁿ` points. -/
theorem card_fin_arrow (n : ℕ) : Fintype.card (Fin n → 𝔽) = card 𝔽 ^ n := by
  simp

/-- Weight and zero count partition the affine space. -/
theorem hammingWeight_add_zeroCount {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) :
    hammingWeight f + zeroCount f = card 𝔽 ^ n := by
  classical
  rw [hammingWeight, zeroCount]
  simp only [ne_eq]
  have h := Finset.card_filter_add_card_filter_not
    (s := (Finset.univ : Finset (Fin n → 𝔽)))
    (p := fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0)
  have hcard : (Finset.univ : Finset (Fin n → 𝔽)).card = card 𝔽 ^ n := by
    simp [Finset.card_univ]
  omega

/-- The Hamming weight is the complement of the zero count. -/
theorem hammingWeight_eq {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) :
    hammingWeight f = card 𝔽 ^ n - zeroCount f := by
  have := hammingWeight_add_zeroCount f
  omega

end GRM