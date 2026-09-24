/-
# HINT-VALUE-JOINT, cycle 3: the orientation bit is a quadratic residue

Cycles 1 and 2 proved that the whole excess of the `(s,d)` view over the hinted `(N,s)` view is
a single *orientation* bit per field.  This file identifies that bit arithmetically: it exists
in a cell of the routing table exactly when the **discriminant** `Δ = s² - 4N` of that cell is
a nonzero quadratic residue.  Hint compounding is therefore governed by the Legendre symbol —
an information-theoretic quantity pinned by a character sum.

* `HintOrientation.factor_root_iff_sqrt_discr` — the change of variable `a ↦ 2a - σ` turning
  "`a` is a factor of `n` with cofactor sum `σ`" into "`2a - σ` is a square root of `Δ`".
* `HintOrientation.exists_distinct_roots_iff_exists_sqrt`,
  `HintOrientation.exists_distinct_roots_iff_isSquare` — a cell `(N,s)` hosts **two** distinct
  factorisations iff `Δ` is a nonzero square; it hosts one iff `Δ = 0`, and none otherwise.
* `HintOrientation.two_orientations_iff_legendre` — the same statement over `ZMod p` in the
  language of the Legendre symbol: two orientations exist iff `legendreSym p Δ = 1`.
* `HintOrientation.hintValue_eq_sumHint_of_gap_determined`,
  `HintOrientation.hintSynergy_nonpos_of_gap_determined` — the information consequence: a
  population in which the hinted sum view already pins the gap has **no** compounding at all.
* `HintOrientation.hintSynergy_nonpos_of_diagonal` — in particular a battery of *square*
  factorisations `p = q` has non-positive hint synergy: the orientation bit is empty there.
* `HintOrientation.exists_nonzero_gap_of_sumHint_lt_hintValue` — conversely, any strictly
  positive orientation gain forces a sample with nonzero gap, i.e. a cell whose discriminant
  is a nonzero square.
* `HintOrientation.compound_witness_discriminant_isSquare` — the mod-`7` compounding battery of
  cycle 1 realises this: its discriminant is `Δ = 4 = 2²`, a nonzero residue mod `7`, while the
  Legendre symbol of a non-residue cell forbids the bit.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 3): the orientation bit of cycles 1–2 is not free-floating — it is
  available precisely on the quadratic-residue part of the discriminant spectrum, so the
  achievable hint synergy of a battery is controlled by how much of its population sits over
  residue cells.
Experiment (Stage 2, cycle 3): enumerated the `(N,s)` cells of `ZMod 7`: of the `49` cells,
  those with `Δ = s² - 4N` a nonzero square host exactly two factor pairs, those with `Δ = 0`
  host one, those with `Δ` a non-residue host none — e.g. the cell `(N,s) = (1,6)` of the
  cycle-1 witness has `Δ = 36 - 4 = 32 = 4 = 2²` and hosts `(2,4)` and `(4,2)`.
Analysis (Stage 3, cycle 3): "hints compound" is, after all the information-theoretic
  bookkeeping, a statement about the solvability of a quadratic congruence.  The whole content
  of the round-30 verdict is that roughly half the cells of the table are residue cells, hence
  carry one bit each.
Critique (Stage 4, cycle 3): the equivalences are stated over a general field with `2 ≠ 0`, and
  the Legendre form only over `ZMod p`; the counting statement "about half the cells" is *not*
  proved here (it needs the character-sum count) and is recorded as conjecture C3 of
  `FUTURE_DIRECTIONS.md` rather than asserted.
-/
import Mathlib
import Bridges.HintValueJointCompounding

namespace HintOrientation

open TraceBattery BatterySynergy SumDiffSplit HintValueJoint

/-! ## 1. Factorisations of a cell are square roots of its discriminant -/

section FieldTheory

variable {F : Type*} [Field F]

/-- **The change of variable.**  `a` is one factor of a pair with product `n` and sum `σ`
exactly when `2a - σ` is a square root of the discriminant `σ² - 4n`. -/
theorem factor_root_iff_sqrt_discr (h2 : (2 : F) ≠ 0) (n σ a : F) :
    a * (σ - a) = n ↔ (2 * a - σ) * (2 * a - σ) = σ * σ - 4 * n := by
  constructor
  · intro h
    linear_combination (-4 : F) * h
  · intro h
    have h4 : (4 : F) ≠ 0 := by
      have : (4 : F) = 2 * 2 := by norm_num
      rw [this]
      exact mul_ne_zero h2 h2
    have hzero : (4 : F) * (a * (σ - a) - n) = 0 := by linear_combination -h
    rcases mul_eq_zero.1 hzero with h' | h'
    · exact absurd h' h4
    · linear_combination h'

/-- **Two factorisations of a cell iff the discriminant has a nonzero square root.** -/
theorem exists_distinct_roots_iff_exists_sqrt (h2 : (2 : F) ≠ 0) (n σ : F) :
    (∃ a b : F, a * (σ - a) = n ∧ b * (σ - b) = n ∧ a ≠ b)
      ↔ ∃ t : F, t ≠ 0 ∧ t * t = σ * σ - 4 * n := by
  constructor
  · rintro ⟨a, b, ha, hb, hab⟩
    refine ⟨2 * a - σ, ?_, (factor_root_iff_sqrt_discr h2 n σ a).1 ha⟩
    intro ht
    have hb' := (factor_root_iff_sqrt_discr h2 n σ b).1 hb
    have ha' := (factor_root_iff_sqrt_discr h2 n σ a).1 ha
    rw [ht] at ha'
    have hzero : (2 * b - σ) * (2 * b - σ) = 0 := by rw [hb', ← ha']; ring
    have hb0 : 2 * b - σ = 0 := by
      rcases mul_eq_zero.1 hzero with h | h <;> exact h
    have ha0 : 2 * a - σ = 0 := ht
    have hmul : (2 : F) * a = 2 * b := by linear_combination ha0 - hb0
    exact hab (mul_left_cancel₀ h2 hmul)
  · rintro ⟨t, ht, hsq⟩
    refine ⟨(σ + t) / 2, (σ - t) / 2, ?_, ?_, ?_⟩
    · rw [factor_root_iff_sqrt_discr h2]
      field_simp
      linear_combination hsq
    · rw [factor_root_iff_sqrt_discr h2]
      field_simp
      linear_combination hsq
    · intro h
      have h2t : (2 : F) * t = 0 := by
        field_simp at h
        linear_combination h
      rcases mul_eq_zero.1 h2t with h' | h'
      · exact h2 h'
      · exact ht h'

/-- **Two factorisations iff the discriminant is a nonzero square.** -/
theorem exists_distinct_roots_iff_isSquare (h2 : (2 : F) ≠ 0) (n σ : F)
    (hΔ : σ * σ - 4 * n ≠ 0) :
    (∃ a b : F, a * (σ - a) = n ∧ b * (σ - b) = n ∧ a ≠ b) ↔ IsSquare (σ * σ - 4 * n) := by
  rw [exists_distinct_roots_iff_exists_sqrt h2]
  constructor
  · rintro ⟨t, _, hsq⟩
    exact ⟨t, hsq.symm⟩
  · rintro ⟨t, hsq⟩
    refine ⟨t, ?_, hsq.symm⟩
    intro ht
    rw [ht, mul_zero] at hsq
    exact hΔ hsq

end FieldTheory

/-! ## 2. The Legendre form -/

/-- **The orientation bit is a Legendre symbol.**  Over `ZMod p` a cell `(N, s)` of the routing
table carries two distinct factorisations — hence one orientation bit — exactly when its
discriminant is a quadratic residue, `legendreSym p Δ = 1`. -/
theorem two_orientations_iff_legendre {p : ℕ} [Fact p.Prime] (hp : p % 2 = 1)
    (n σ : ZMod p) (hΔ : σ * σ - 4 * n ≠ 0) :
    (∃ a b : ZMod p, a * (σ - a) = n ∧ b * (σ - b) = n ∧ a ≠ b)
      ↔ legendreSym p ((σ * σ - 4 * n).val : ℤ) = 1 := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro h
    have h2n : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    have hdvd : p ∣ 2 := (ZMod.natCast_eq_zero_iff 2 p).mp h2n
    have hle := Nat.le_of_dvd (by norm_num) hdvd
    have := (Fact.out : p.Prime).two_le
    omega
  have hcast : (((σ * σ - 4 * n).val : ℤ) : ZMod p) = σ * σ - 4 * n := by
    push_cast
    simp
  rw [exists_distinct_roots_iff_isSquare h2 n σ hΔ,
    legendreSym.eq_one_iff p (by rw [hcast]; exact hΔ), hcast]

/-! ## 3. Information consequences: no residue, no compounding -/

section Information

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*} {R : Type*} [CommRing R]
  [Invertible (2 : R)]

/-- If the hinted sum view already pins the gap residue, the joint view adds nothing to it. -/
theorem hintValue_eq_sumHint_of_gap_determined (L : Ω → Λ) (P Q : Ω → R)
    (h : ∀ x y, sumHintView P Q x = sumHintView P Q y → gapView P Q x = gapView P Q y) :
    hintValue L P Q = sumHint L P Q := by
  have hsame : ∀ x y, residueView P Q x = residueView P Q y
      ↔ sumHintView P Q x = sumHintView P Q y := by
    intro x y
    constructor
    · intro hxy
      rw [sumHintView_comp]
      simp only [Function.comp_apply, hxy]
    · intro hxy
      exact Prod.ext (congrArg Prod.snd hxy) (h x y hxy)
  rw [hintValue, sumHint, MIb_eq_of_same_fibers L (residueView P Q) (sumHintView P Q) hsame]

/-- **No orientation, no compounding.** -/
theorem hintSynergy_nonpos_of_gap_determined (L : Ω → Λ) (P Q : Ω → R)
    (h : ∀ x y, sumHintView P Q x = sumHintView P Q y → gapView P Q x = gapView P Q y) :
    hintSynergy L P Q ≤ 0 := by
  have h1 := hintValue_eq_sumHint_of_gap_determined L P Q h
  have h2 := gapHint_nonneg L P Q
  simp only [hintSynergy, h1]
  linarith

/-- **Square factorisations cannot compound.**  On a battery all of whose samples are squares
`p = q` the gap residue vanishes identically, the orientation bit is empty, and the hint
synergy is non-positive. -/
theorem hintSynergy_nonpos_of_diagonal (L : Ω → Λ) (P Q : Ω → R) (h : ∀ x, P x = Q x) :
    hintSynergy L P Q ≤ 0 := by
  refine hintSynergy_nonpos_of_gap_determined L P Q fun x y _ => ?_
  show Q x - P x = Q y - P y
  rw [← h x, ← h y, sub_self, sub_self]

/-- **Positive orientation gain needs a nonzero gap**, i.e. a cell whose discriminant is a
nonzero square (the discriminant of a sample is always the square of its gap). -/
theorem exists_nonzero_gap_of_sumHint_lt_hintValue (L : Ω → Λ) (P Q : Ω → R)
    (h : sumHint L P Q < hintValue L P Q) :
    ∃ x : Ω, gapView P Q x ≠ 0 ∧
      gapView P Q x * gapView P Q x
        = sumView P Q x * sumView P Q x - 4 * productView P Q x := by
  by_contra hcon
  push_neg at hcon
  have hzero : ∀ x : Ω, gapView P Q x = 0 := by
    intro x
    by_contra hx
    have hid : gapView P Q x * gapView P Q x
        = sumView P Q x * sumView P Q x - 4 * productView P Q x := by
      show (Q x - P x) * (Q x - P x) = (P x + Q x) * (P x + Q x) - 4 * (P x * Q x)
      ring
    exact absurd hid (hcon x hx)
  have hdet : ∀ x y, sumHintView P Q x = sumHintView P Q y → gapView P Q x = gapView P Q y := by
    intro x y _
    rw [hzero x, hzero y]
  have := hintValue_eq_sumHint_of_gap_determined L P Q hdet
  linarith

end Information

/-! ## 4. The cycle-1 witness sits over a residue cell -/

/-- The discriminant of the mod-`7` compounding battery is `Δ = 4`, a nonzero square: the cell
`(N, s) = (1, 6)` hosts the two factorisations `(2,4)` and `(4,2)`, which is exactly the
orientation bit that made its hint synergy `+1`. -/
theorem compound_witness_discriminant_isSquare :
    ((6 : ZMod 7) * 6 - 4 * 1 ≠ 0) ∧ IsSquare ((6 : ZMod 7) * 6 - 4 * 1) ∧
      ∃ a b : ZMod 7, a * (6 - a) = 1 ∧ b * (6 - b) = 1 ∧ a ≠ b := by
  refine ⟨by decide, ⟨2, by decide⟩, 2, 4, by decide, by decide, by decide⟩

/-- A **non-residue cell carries no orientation bit**: modulo `7` the discriminant `3` is a
non-residue, and the corresponding cell `(N, s) = (1, 0)` has no factorisation at all — so no
battery supported over it can compound. -/
theorem non_residue_cell_has_no_factorisation :
    ¬ IsSquare ((3 : ZMod 7)) ∧ ¬ ∃ a : ZMod 7, a * (0 - a) = 1 := by
  constructor
  · decide
  · decide

end HintOrientation