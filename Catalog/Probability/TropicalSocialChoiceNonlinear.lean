/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Probability.TropicalSocialChoiceOligarchy

/-!
# Tropical social choice IV: linearity cannot be dropped from the oligarchy theorem

`Probability.TropicalSocialChoiceOligarchy` proved the *tropical oligarchy theorem*: a
**tropically linear**, unanimous, diagonally idempotent rule `f : TRⁿ → TR` is the minimum
rule `x ↦ ⨁_{i ∈ s} xᵢ` of a nonempty coalition `s`.  Conjecture 1 of
`FUTURE_DIRECTIONS.md` asked whether the linearity hypothesis is redundant, as it is for
the full multiplicativity axiom (`isTropLinear_of_tropIIA`).

**It is not.**  This file constructs an explicit counterexample and thereby refutes
Conjecture 1.

The counterexample is the two-voter rule
`f (x₀, x₁) = x₀ ⊕ φ(x₁) = min (x₀, φ(x₁))`,
where `φ` is the piecewise-linear cost distortion `φ(r) = 2r` for `r ≥ 0` and `φ(r) = r/2`
for `r < 0` (and `φ(∞) = ∞`).  The point is that `φ` is monotone (hence `⊕`-additive) and
*doubling-homogeneous*, `φ(2r) = 2φ(r)`, but not a translation `r ↦ a + r`.  Diagonal
idempotence only ever tests `f` along the doubling map, so it cannot see the difference,
whereas full multiplicativity would.

## Main results

* `phiT_add`, `phiT_mul_self`, `phiT_ge` : the distortion `φ` preserves tropical addition,
  is homogeneous along the diagonal, and is a *penalty* (`c ≤ φ c`).
* `distortedRule_tropIIA`, `distortedRule_tropPareto`, `distortedRule_tropDiagIdem` : the
  rule satisfies tropical IIA, tropical Pareto and diagonal idempotence.
* `distortedRule_not_isTropLinear` : it is **not** tropically linear.
* `distortedRule_ne_tropCoalition` : it differs from every coalition rule.
* `not_oligarchy_of_tropIIA_tropDiagIdem` : the refutation of Conjecture 1 — there is a
  rule satisfying `TropIIA`, `TropPareto` and `TropDiagIdem` which is not a coalition rule
  (and not even tropically linear).  Hence the oligarchy theorem genuinely needs its
  linearity hypothesis, in sharp contrast with the tropical Arrow theorem.
-/

namespace TropicalSocialChoice

open Tropical

/-! ## A monotone, doubling-homogeneous cost distortion which is not a translation -/

/-- The real cost distortion `φ(r) = 2r` for `r ≥ 0`, `φ(r) = r/2` for `r < 0`. -/
noncomputable def phiR (r : ℝ) : ℝ := if 0 ≤ r then 2 * r else r / 2

/-- `φ` extended to extended costs, with `φ(∞) = ∞`. -/
noncomputable def phiT (c : TR) : TR := trop ((untrop c).map phiR)

theorem phiR_mono : Monotone phiR := by
  intro r s h
  unfold phiR
  split_ifs <;> linarith

/-- `φ` is homogeneous along doublings: `φ(r + r) = φ(r) + φ(r)`. -/
theorem phiR_double (r : ℝ) : phiR (r + r) = phiR r + phiR r := by
  unfold phiR
  split_ifs <;> linarith

/-- `φ` never lowers a cost. -/
theorem phiR_ge (r : ℝ) : r ≤ phiR r := by
  unfold phiR
  split_ifs <;> linarith

/-- `φ` is not a translation: it is not of the form `r ↦ a + r`. -/
theorem phiR_one_two : phiR 1 = 2 ∧ phiR 2 = 4 := by
  constructor <;> · unfold phiR; norm_num

theorem phiT_mono : Monotone phiT := by
  intro c d h
  rw [← untrop_le_iff] at h ⊢
  exact phiR_mono.withTop_map h

/-- **Tropical additivity of the distortion**: `φ (min (c, d)) = min (φ c, φ d)`. -/
theorem phiT_add (c d : TR) : phiT (c + d) = phiT c + phiT d := by
  rcases le_total c d with h | h
  · rw [Tropical.add_eq_left h, Tropical.add_eq_left (phiT_mono h)]
  · rw [Tropical.add_eq_right h, Tropical.add_eq_right (phiT_mono h)]

/-- The distortion is a penalty: `c ≤ φ c`. -/
theorem phiT_ge (c : TR) : c ≤ phiT c := by
  rw [← untrop_le_iff]
  induction hc : untrop c using WithTop.recTopCoe with
  | top => simp [phiT, hc]
  | coe r =>
    simp only [phiT, untrop_trop, hc, WithTop.map_coe, WithTop.coe_le_coe]
    exact phiR_ge r

/-- **Diagonal homogeneity of the distortion**: `φ (2c) = 2 φ c`. -/
theorem phiT_mul_self (c : TR) : phiT (c * c) = phiT c * phiT c := by
  apply untrop_injective
  simp only [phiT, untrop_mul, untrop_trop]
  induction hc : untrop c using WithTop.recTopCoe with
  | top => simp
  | coe r =>
    simp only [← WithTop.coe_add, WithTop.map_coe]
    rw [phiR_double]

@[simp] theorem phiT_zero : phiT 0 = 0 := by
  apply untrop_injective
  simp [phiT]

@[simp] theorem phiT_one : phiT 1 = 1 := by
  apply untrop_injective
  have h : untrop (1 : TR) = ((0 : ℝ) : WithTop ℝ) := rfl
  simp only [phiT, untrop_trop, h, WithTop.map_coe]
  rw [show phiR 0 = 0 by unfold phiR; norm_num]

theorem phiT_ofReal (r : ℝ) : phiT (ofReal r) = ofReal (phiR r) := by
  apply untrop_injective
  simp [phiT, ofReal]

/-! ## The counterexample rule -/

/-- The two-voter rule `f (x₀, x₁) = min (x₀, φ x₁)`: voter `1`'s costs are distorted
before being compared with voter `0`'s. -/
noncomputable def distortedRule : (Fin 2 → TR) → TR := fun x => x 0 + phiT (x 1)

theorem distortedRule_apply (x : Fin 2 → TR) : distortedRule x = x 0 + phiT (x 1) := rfl

/-- The rule satisfies tropical IIA. -/
theorem distortedRule_tropIIA : TropIIA distortedRule := by
  intro x y
  show (x + y) 0 + phiT ((x + y) 1) = (x 0 + phiT (x 1)) + (y 0 + phiT (y 1))
  show x 0 + y 0 + phiT (x 1 + y 1) = (x 0 + phiT (x 1)) + (y 0 + phiT (y 1))
  rw [phiT_add, add_add_add_comm]

/-- The rule is unanimous: `φ` never lowers a cost, so `min (c, φ c) = c`. -/
theorem distortedRule_tropPareto : TropPareto distortedRule := by
  intro c
  show c + phiT c = c
  exact Tropical.add_eq_left (phiT_ge c)

/-- The rule is diagonally idempotent: doubling all costs doubles the social cost. -/
theorem distortedRule_tropDiagIdem : TropDiagIdem distortedRule := by
  intro x
  show (x * x) 0 + phiT ((x * x) 1) = (x 0 + phiT (x 1)) * (x 0 + phiT (x 1))
  show x 0 * x 0 + phiT (x 1 * x 1) = (x 0 + phiT (x 1)) * (x 0 + phiT (x 1))
  rw [phiT_mul_self, mul_self_add]

/-- The test profile: voter `0` reports the infinitely bad cost `⊤`, voter `1` reports
the cost `1`. -/
noncomputable def testProfile : Fin 2 → TR := ![0, ofReal 1]

theorem testProfile_zero : testProfile 0 = 0 := rfl
theorem testProfile_one : testProfile 1 = ofReal 1 := rfl

theorem distortedRule_testProfile : distortedRule testProfile = ofReal 2 := by
  rw [distortedRule_apply, testProfile_zero, testProfile_one, zero_add, phiT_ofReal,
    show phiR 1 = 2 from phiR_one_two.1]

theorem ofReal_ne_zero (r : ℝ) : ofReal r ≠ 0 := by
  intro h
  have := congrArg untrop h
  simp only [ofReal, untrop_trop] at this
  exact (WithTop.coe_ne_top) this

/-- **The rule is not tropically linear.**  Its coefficients would have to be
`a₀ = a₁ = 1`, i.e. the Rawlsian rule, which disagrees with it on `testProfile`. -/
theorem distortedRule_not_isTropLinear : ¬ IsTropLinear distortedRule := by
  rintro ⟨a, ha⟩
  have e10 : (Pi.single (1 : Fin 2) (1 : TR) : Fin 2 → TR) 0 = 0 :=
    Pi.single_eq_of_ne (show (0 : Fin 2) ≠ 1 by decide) 1
  have e11 : (Pi.single (1 : Fin 2) (1 : TR) : Fin 2 → TR) 1 = 1 := Pi.single_eq_same 1 1
  have e00 : (Pi.single (0 : Fin 2) (1 : TR) : Fin 2 → TR) 0 = 1 := Pi.single_eq_same 0 1
  have e01 : (Pi.single (0 : Fin 2) (1 : TR) : Fin 2 → TR) 1 = 0 :=
    Pi.single_eq_of_ne (show (1 : Fin 2) ≠ 0 by decide) 1
  have ha1 : a 1 = 1 := by
    have h := (tropForm_apply_single a 1).symm.trans (ha (Pi.single 1 1)).symm
    rw [distortedRule_apply, e10, e11, phiT_one, zero_add] at h
    exact h
  have ha0 : a 0 = 1 := by
    have h := (tropForm_apply_single a 0).symm.trans (ha (Pi.single 0 1)).symm
    rw [distortedRule_apply, e00, e01, phiT_zero, add_zero] at h
    exact h
  have hval : distortedRule testProfile = ofReal 1 := by
    rw [ha testProfile, tropForm, Fin.sum_univ_two, ha0, ha1, one_mul, one_mul,
      testProfile_zero, testProfile_one, zero_add]
  rw [distortedRule_testProfile] at hval
  have : (2 : ℝ) = 1 := ofReal_injective hval
  norm_num at this

/-- **The rule is not a coalition rule.**  On `testProfile` every coalition rule returns
`⊤` or the undistorted cost `1`, while the distorted rule returns `2`. -/
theorem distortedRule_ne_tropCoalition (s : Finset (Fin 2)) :
    distortedRule ≠ tropCoalition s := by
  intro hs
  have hcases : ∀ t : Finset (Fin 2), t = ∅ ∨ t = {0} ∨ t = {1} ∨ t = {0, 1} := by decide
  have hval : distortedRule testProfile = ofReal 2 := distortedRule_testProfile
  rw [hs] at hval
  rcases hcases s with rfl | rfl | rfl | rfl
  · rw [tropCoalition, Finset.sum_empty] at hval
    exact ofReal_ne_zero 2 hval.symm
  · rw [tropCoalition, Finset.sum_singleton, testProfile_zero] at hval
    exact ofReal_ne_zero 2 hval.symm
  · rw [tropCoalition, Finset.sum_singleton, testProfile_one] at hval
    have : (2 : ℝ) = 1 := ofReal_injective hval.symm
    norm_num at this
  · rw [tropCoalition, show ({0, 1} : Finset (Fin 2)) = Finset.univ from rfl, Fin.sum_univ_two,
      testProfile_zero, testProfile_one, zero_add] at hval
    have : (2 : ℝ) = 1 := ofReal_injective hval.symm
    norm_num at this

/-- **Conjecture 1 refuted.**  There is a rule on two voters satisfying tropical IIA,
tropical Pareto and diagonal idempotence which is neither tropically linear nor a
coalition rule.  Consequently the linearity hypothesis in `oligarchy_of_diagIdem` cannot be
removed: unlike full tropical multiplicativity (`isTropLinear_of_tropIIA`), diagonal
idempotence does not force linearity. -/
theorem not_oligarchy_of_tropIIA_tropDiagIdem :
    ∃ f : (Fin 2 → TR) → TR,
      TropIIA f ∧ TropPareto f ∧ TropDiagIdem f ∧ ¬ IsTropLinear f ∧
        ∀ s : Finset (Fin 2), f ≠ tropCoalition s :=
  ⟨distortedRule, distortedRule_tropIIA, distortedRule_tropPareto, distortedRule_tropDiagIdem,
    distortedRule_not_isTropLinear, distortedRule_ne_tropCoalition⟩

/-- Since diagonal idempotence does not imply linearity, it also does not imply
multiplicativity; by the tropical Arrow theorem the counterexample is in particular not
tropically multiplicative. -/
theorem distortedRule_not_tropScaleInv : ¬ TropScaleInv distortedRule := by
  intro hmul
  obtain ⟨k, hk, -⟩ := tropical_arrow_of_tropIIA distortedRule_tropIIA distortedRule_tropPareto hmul
  exact distortedRule_not_isTropLinear (hk ▸ tropDictator_isTropLinear k)

end TropicalSocialChoice