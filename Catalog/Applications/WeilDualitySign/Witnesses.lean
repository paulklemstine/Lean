/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sharpness Witnesses for the Duality Sign Law

This file is the adversarial half of `EigenvalueModel.lean`.  There we proved

  `∏ α_i = (−1)^{#neg-fixed} · Q^d`,   `ε = (−1)^{d + #neg-fixed}`,

and the mission conjecture as the corollary "no `−Q` fixed point ⟹ `∏ α_i = Q^d`,
`ε = (−1)^d`".  Here we exhibit explicit complex eigensystems showing that **every
hypothesis is load-bearing and the theorem is sharp**:

* `posFixed_deg_one` — degree 1 with the fixed point `α = +Q`: `∏ α = Q`, `ε = −1`.
  This is the `d = 1` sign the conjecture predicts.
* `negFixed_deg_one` — degree 1 with the fixed point `α = −Q`: `∏ α = −Q ≠ Q` and
  `ε = +1 ≠ (−1)^1`.  A *single* anti-diagonal fixed point flips the sign, so the
  hypothesis of the conjecture cannot be deleted.
* `pair_deg_two` — a free duality 2-cycle `{a, Q²/a}`: `∏ α = Q²`, `ε = +1`, valid for
  every `a ≠ 0`.  2-cycles are sign-neutral, whatever the eigenvalues are.
* `twoNegFixed_deg_two` — two `−Q` fixed points: the hypothesis of the conjecture
  *fails* yet the conclusion `∏ α = Q²` still *holds*.  The hypothesis is therefore
  sufficient but not necessary — only the parity matters.
* `cycle4_two_pairs` and `cycle4_mixed` — the degree-4 witnesses: two duality
  2-cycles give `ε = +1 = (−1)^4`, while `(+Q, −Q, a, Q²/a)` gives `ε = −1 ≠ (−1)^4`.
* `three_cycle_no_fixed_point_sign_flip` — the deepest one: a *non-involutive* duality
  (a 3-cycle) with **no fixed points at all** — so the mission hypothesis holds
  vacuously — yet `∏ α = −Q³`.  Involutivity of `σ` is not decorative: it is exactly
  what the pairing argument consumes.

-- !-- Lab Notes -- !--
Experiment (Experimenter): the search for a counterexample to the conjecture was run
  by hand over all duality structures of degree ≤ 4 (`ε` depends only on `d` and the
  fixed-point data, so degree 4 already exhibits every pattern: 4 fixed points,
  2 fixed + one 2-cycle, two 2-cycles).  All conform to `ε = (−1)^{d + #neg-fixed}`.
Analysis (Analyst): the only way to break the conclusion while keeping the stated
  hypothesis is to break *involutivity*.  Chasing `α_i α_{σ i} = Q²` around a 3-cycle
  forces `α_0 = α_2` and then `α_0² = Q²`, so the whole cycle is constant `±Q`; the
  choice `−Q` yields `∏ α = −Q³` with an empty fixed-point set.
Critique (Critic): all witnesses are genuine inhabitants of `DualEigensystem` (the
  3-cycle one is stated separately, precisely because it is not one), and each claim
  is an equation between explicit complex numbers, not a vacuous implication.
-/
import Mathlib
import Catalog.Applications.WeilDualitySign.EigenvalueModel

open Finset

namespace WeilDualitySign

namespace Witnesses

variable (Q : ℂ) (hQ : Q ≠ 0)

/-! ### Degree 1: the two self-dual eigenvalues -/

/-- Degree-1 system with the **`+Q` fixed point** (`σ = id`, `α = Q`). -/
def posFixed : DualEigensystem ℂ (Fin 1) where
  Q := Q
  Q_ne_zero := hQ
  α := fun _ => Q
  σ := Equiv.refl _
  σ_involutive := fun _ => rfl
  duality := fun _ => by ring

/-- Degree-1 system with the **`−Q` fixed point** (`σ = id`, `α = −Q`). -/
def negFixedOne : DualEigensystem ℂ (Fin 1) where
  Q := Q
  Q_ne_zero := hQ
  α := fun _ => -Q
  σ := Equiv.refl _
  σ_involutive := fun _ => rfl
  duality := fun _ => by ring

/-- The `+Q` system satisfies the mission hypothesis, its eigenvalue product is `Q`, and
its root sign is `(−1)^1 = −1` — exactly the conjectured value at `d = 1`. -/
theorem posFixed_deg_one :
    (posFixed Q hQ).deg = 1 ∧
    (∀ i, (posFixed Q hQ).σ i = i → (posFixed Q hQ).α i ≠ -(posFixed Q hQ).Q) ∧
    (∏ i, (posFixed Q hQ).α i) = Q ∧
    (posFixed Q hQ).rootSign = -1 := by
  refine ⟨rfl, ?_, by simp [posFixed], ?_⟩
  · intro i _ h
    simp only [posFixed] at h
    exact hQ (by linear_combination h / 2)
  · simp only [DualEigensystem.rootSign, posFixed, DualEigensystem.deg]
    simp
    field_simp

/-- **The single anti-diagonal fixed point flips the sign.**  With `α = −Q` at the unique
(self-dual) index, the eigenvalue product is `−Q`, *not* `Q`, and the root sign is `+1`
instead of the conjectured `(−1)^1 = −1`.  Hence the hypothesis "no `−Q` fixed point"
cannot be removed from the conjecture. -/
theorem negFixed_deg_one :
    (negFixedOne Q hQ).deg = 1 ∧
    (∏ i, (negFixedOne Q hQ).α i) = -Q ∧
    (∏ i, (negFixedOne Q hQ).α i) ≠ (negFixedOne Q hQ).Q ^ (negFixedOne Q hQ).deg ∧
    (negFixedOne Q hQ).rootSign = 1 ∧
    (negFixedOne Q hQ).rootSign ≠ (-1 : ℂ) ^ (negFixedOne Q hQ).deg := by
  have hprod : (∏ i, (negFixedOne Q hQ).α i) = -Q := by simp [negFixedOne]
  refine ⟨rfl, hprod, ?_, ?_, ?_⟩
  · rw [hprod]
    intro h
    simp only [negFixedOne, DualEigensystem.deg, Fintype.card_fin, pow_one] at h
    exact hQ (by linear_combination -h / 2)
  · simp only [DualEigensystem.rootSign, DualEigensystem.deg, Fintype.card_fin, pow_one]
    rw [show (∏ i, (negFixedOne Q hQ).α i) = -Q from hprod]
    simp only [negFixedOne]
    field_simp
  · intro h
    have h2 : (negFixedOne Q hQ).rootSign = 1 := by
      simp only [DualEigensystem.rootSign, DualEigensystem.deg, Fintype.card_fin, pow_one]
      rw [show (∏ i, (negFixedOne Q hQ).α i) = -Q from hprod]
      simp only [negFixedOne]
      field_simp
    rw [h2] at h
    simp only [DualEigensystem.deg, Fintype.card_fin, pow_one] at h
    norm_num at h

/-! ### Degree 2: a free duality pair, and two anti-diagonal fixed points -/

/-- Degree-2 system consisting of a single duality 2-cycle `{a, Q²/a}`. -/
noncomputable def pair (a : ℂ) (ha : a ≠ 0) : DualEigensystem ℂ (Fin 2) where
  Q := Q
  Q_ne_zero := hQ
  α := ![a, Q ^ 2 / a]
  σ := Equiv.swap 0 1
  σ_involutive := by decide
  duality := by
    intro i
    fin_cases i <;>
      simp [Equiv.swap_apply_left, Equiv.swap_apply_right] <;> field_simp

/-- **2-cycles are sign-neutral.**  Whatever the eigenvalue `a ≠ 0` is, a duality pair
contributes `Q²` to the product and leaves the root sign at `(−1)^2 = +1`.  There is no
fixed point at all, so the mission hypothesis holds vacuously and the conclusion holds. -/
theorem pair_deg_two (a : ℂ) (ha : a ≠ 0) :
    (pair Q hQ a ha).deg = 2 ∧
    (∏ i, (pair Q hQ a ha).α i) = Q ^ 2 ∧
    (pair Q hQ a ha).rootSign = 1 := by
  have hprod : (∏ i, (pair Q hQ a ha).α i) = Q ^ 2 := by
    simp [pair, Fin.prod_univ_two]
    field_simp
  refine ⟨rfl, hprod, ?_⟩
  simp only [DualEigensystem.rootSign, DualEigensystem.deg, Fintype.card_fin]
  rw [hprod]
  simp only [pair]
  field_simp

/-- Degree-2 system with **two** `−Q` fixed points (`σ = id`, `α ≡ −Q`). -/
def twoNegFixed : DualEigensystem ℂ (Fin 2) where
  Q := Q
  Q_ne_zero := hQ
  α := fun _ => -Q
  σ := Equiv.refl _
  σ_involutive := fun _ => rfl
  duality := fun _ => by ring

/-- **Sufficient, not necessary.**  Two anti-diagonal fixed points cancel: the mission
hypothesis fails at *every* index, yet `∏ α = Q²` and `ε = (−1)^2` still hold.  The set
`negFixed` has even cardinality `2`, in accordance with `prod_alpha_eq_pow_iff_even`. -/
theorem twoNegFixed_deg_two :
    (twoNegFixed Q hQ).negFixed = univ ∧
    (twoNegFixed Q hQ).negFixed.card = 2 ∧
    ¬ (∀ i, (twoNegFixed Q hQ).σ i = i → (twoNegFixed Q hQ).α i ≠ -(twoNegFixed Q hQ).Q) ∧
    (∏ i, (twoNegFixed Q hQ).α i) = (twoNegFixed Q hQ).Q ^ (twoNegFixed Q hQ).deg ∧
    (twoNegFixed Q hQ).rootSign = 1 := by
  have huniv : (twoNegFixed Q hQ).negFixed = univ :=
    Finset.eq_univ_iff_forall.mpr fun i =>
      (twoNegFixed Q hQ).mem_negFixed.mpr ⟨rfl, rfl⟩
  have hcard : (twoNegFixed Q hQ).negFixed.card = 2 := by
    rw [huniv, Finset.card_univ, Fintype.card_fin]
  have hprod : (∏ i, (twoNegFixed Q hQ).α i) = Q ^ 2 := by
    simp [twoNegFixed]
  refine ⟨huniv, hcard, ?_, ?_, ?_⟩
  · intro h
    exact h 0 rfl rfl
  · rw [hprod]; rfl
  · simp only [DualEigensystem.rootSign, DualEigensystem.deg, Fintype.card_fin]
    rw [hprod]
    simp only [twoNegFixed]
    field_simp

/-! ### Degree 4: the cycle-4 witnesses -/

/-- Degree-4 system built from **two** duality 2-cycles `{a, Q²/a}`, `{b, Q²/b}`. -/
noncomputable def twoPairs (a b : ℂ) (ha : a ≠ 0) (hb : b ≠ 0) :
    DualEigensystem ℂ (Fin 4) where
  Q := Q
  Q_ne_zero := hQ
  α := ![a, Q ^ 2 / a, b, Q ^ 2 / b]
  σ := Equiv.swap 0 1 * Equiv.swap 2 3
  σ_involutive := by decide
  duality := by
    intro i
    fin_cases i <;>
      simp [Equiv.Perm.mul_apply, Equiv.swap_apply_def] <;> field_simp

/-- **Cycle-4 witness, sign `+1`.**  Two duality pairs in degree 4: no fixed points, so
the mission hypothesis holds vacuously, and indeed `∏ α = Q⁴` and `ε = (−1)^4 = +1`. -/
theorem cycle4_two_pairs (a b : ℂ) (ha : a ≠ 0) (hb : b ≠ 0) :
    (twoPairs Q hQ a b ha hb).deg = 4 ∧
    (∏ i, (twoPairs Q hQ a b ha hb).α i) = Q ^ 4 ∧
    (twoPairs Q hQ a b ha hb).rootSign = 1 := by
  have hprod : (∏ i, (twoPairs Q hQ a b ha hb).α i) = Q ^ 4 := by
    simp [twoPairs, Fin.prod_univ_four]
    field_simp
  refine ⟨rfl, hprod, ?_⟩
  simp only [DualEigensystem.rootSign, DualEigensystem.deg, Fintype.card_fin]
  rw [hprod]
  simp only [twoPairs]
  field_simp

/-- Degree-4 system mixing the two fixed points `+Q`, `−Q` with one duality pair. -/
noncomputable def mixed (a : ℂ) (ha : a ≠ 0) : DualEigensystem ℂ (Fin 4) where
  Q := Q
  Q_ne_zero := hQ
  α := ![Q, -Q, a, Q ^ 2 / a]
  σ := Equiv.swap 2 3
  σ_involutive := by decide
  duality := by
    intro i
    fin_cases i <;>
      simp [Equiv.swap_apply_def] <;> field_simp

/-- **Cycle-4 witness, sign flip.**  With exactly one anti-diagonal fixed point in degree
`4`, the product is `−Q⁴` and the root sign is `−1 ≠ (−1)^4`.  The sign is genuinely a
function of the fixed-point data, not of the degree alone. -/
theorem cycle4_mixed (a : ℂ) (ha : a ≠ 0) :
    (mixed Q hQ a ha).deg = 4 ∧
    (∏ i, (mixed Q hQ a ha).α i) = -Q ^ 4 ∧
    (mixed Q hQ a ha).rootSign = -1 ∧
    (mixed Q hQ a ha).rootSign ≠ (-1 : ℂ) ^ (mixed Q hQ a ha).deg := by
  have hprod : (∏ i, (mixed Q hQ a ha).α i) = -Q ^ 4 := by
    simp [mixed, Fin.prod_univ_four]
    field_simp
  have hsign : (mixed Q hQ a ha).rootSign = -1 := by
    simp only [DualEigensystem.rootSign, DualEigensystem.deg, Fintype.card_fin]
    rw [hprod]
    simp only [mixed]
    field_simp
  refine ⟨rfl, hprod, hsign, ?_⟩
  rw [hsign]
  simp only [DualEigensystem.deg, Fintype.card_fin]
  norm_num

/-! ### Involutivity is essential: a fixed-point-free 3-cycle with `∏ α = −Q³` -/

include hQ in
/-- **The hypothesis "σ is an involution" cannot be weakened to "σ is a bijection".**
Take `σ` the 3-cycle `i ↦ i + 1` on `Fin 3` and `α ≡ −Q`.  Then duality
`α_i α_{σ i} = Q²` holds, `σ` has **no fixed point whatsoever** (so the mission
hypothesis is vacuously satisfied), yet

  `∏ α_i = −Q³ ≠ Q³`,

and correspondingly the functional-equation sign is `(−1)^{d+1}`, not `(−1)^d`.  The
pairing argument of `prod_alpha_eq_sign_mul_pow` really consumes `σ ∘ σ = id`. -/
theorem three_cycle_no_fixed_point_sign_flip :
    ∃ (σ : Equiv.Perm (Fin 3)) (α : Fin 3 → ℂ),
      (∀ i, α i * α (σ i) = Q ^ 2) ∧
      (∀ i, σ i ≠ i) ∧
      ¬ (∀ i, σ (σ i) = i) ∧
      (∏ i, α i) = -Q ^ 3 ∧
      (∏ i, α i) ≠ Q ^ 3 := by
  refine ⟨finRotate 3, fun _ => -Q, fun i => by ring, by decide, by decide, ?_, ?_⟩
  · simp
    ring
  · intro h
    rw [show (∏ _i : Fin 3, (-Q)) = -Q ^ 3 by simp; ring] at h
    have : (2 : ℂ) * Q ^ 3 = 0 := by linear_combination -h
    rcases mul_eq_zero.mp this with h2 | h2
    · norm_num at h2
    · exact hQ (pow_eq_zero_iff (n := 3) (by norm_num) |>.mp h2)

end Witnesses

end WeilDualitySign