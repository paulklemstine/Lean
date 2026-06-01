import Mathlib

/-!
# p-adic Langlands Correspondence for GL₂(ℚ_p): Foundations

This file formalizes foundational structures and theorems toward the p-adic Langlands
correspondence for GL₂(ℚ_p), following Colmez, Berger, and Breuil.

## Mathematical Overview

The p-adic Langlands correspondence establishes a bijection between:
- 2-dimensional p-adic representations of Gal(Q̄_p/Q_p)
- Certain irreducible unitary Banach space representations of GL₂(Q_p)

The bridge is the theory of (φ,Γ)-modules:
- Fontaine's equivalence: étale (φ,Γ)-modules ↔ p-adic Galois representations
- Colmez's functor: GL₂(Q_p)-representations → (φ,Γ)-modules

## Novel Definitions

- `PhiModule`, `PhiGammaModule`: Core algebraic structures
- `Rank2Slopes`: Newton polygon slope data with duality and twist operations
- `Rank2WA`: Weak admissibility for rank 2 filtered φ-modules
- `ColmezFunctorData`: Abstract axiomatization of the Colmez functor
- `TriangulineParam`: Parameter space for trianguline representations
-/

noncomputable section

open scoped Classical

/-! ## §1. Frobenius Modules -/

/-- A φ-module: a module with a φ-semilinear Frobenius endomorphism. -/
structure PhiModule (R : Type*) [CommRing R] (φ : R →+* R) where
  carrier : Type*
  [instAddCommGroup : AddCommGroup carrier]
  [instModule : Module R carrier]
  Φ : carrier →+ carrier
  Φ_smul : ∀ (r : R) (x : carrier), Φ (r • x) = φ r • Φ x

attribute [instance] PhiModule.instAddCommGroup PhiModule.instModule

/-- A morphism of φ-modules. -/
structure PhiModuleHom {R : Type*} [CommRing R] {φ : R →+* R}
    (D E : PhiModule R φ) where
  toFun : D.carrier →+ E.carrier
  map_smul' : ∀ (r : R) (x : D.carrier), toFun (r • x) = r • toFun x
  comm_Φ : ∀ x, toFun (D.Φ x) = E.Φ (toFun x)

namespace PhiModuleHom

variable {R : Type*} [CommRing R] {φ : R →+* R}

def comp {D E F : PhiModule R φ} (g : PhiModuleHom E F) (f : PhiModuleHom D E) :
    PhiModuleHom D F where
  toFun := g.toFun.comp f.toFun
  map_smul' := fun r x => by simp [AddMonoidHom.comp_apply, f.map_smul', g.map_smul']
  comm_Φ := fun x => by simp [AddMonoidHom.comp_apply, f.comm_Φ, g.comm_Φ]

end PhiModuleHom

/-! ## §2. (φ,Γ)-Modules -/

/-- A (φ,Γ)-module: a φ-module with a commuting group action of Γ. -/
structure PhiGammaModule (R : Type*) [CommRing R] (φ : R →+* R)
    (Γ : Type*) [Group Γ] extends PhiModule R φ where
  γ_action : Γ → carrier →+ carrier
  γ_mul : ∀ (g₁ g₂ : Γ) (x : carrier),
    γ_action g₁ (γ_action g₂ x) = γ_action (g₁ * g₂) x
  γ_one : ∀ x : carrier, γ_action 1 x = x
  γ_comm_Φ : ∀ (g : Γ) (x : carrier),
    γ_action g (toPhiModule.Φ x) = toPhiModule.Φ (γ_action g x)

namespace PhiGammaModule

variable {R : Type*} [CommRing R] {φ : R →+* R} {Γ : Type*} [Group Γ]

theorem γ_inv (D : PhiGammaModule R φ Γ) (g : Γ) (x : D.carrier) :
    D.γ_action g⁻¹ (D.γ_action g x) = x := by
  rw [D.γ_mul]; simp [D.γ_one]

end PhiGammaModule

/-! ## §3. Slope Theory -/

/-- Slope data for a rank 2 Frobenius module. -/
@[ext]
structure Rank2Slopes where
  s₁ : ℚ
  s₂ : ℚ
  ordered : s₁ ≤ s₂

namespace Rank2Slopes

def totalSlope (s : Rank2Slopes) : ℚ := s.s₁ + s.s₂
def slopeGap (s : Rank2Slopes) : ℚ := s.s₂ - s.s₁

theorem slopeGap_nonneg (s : Rank2Slopes) : 0 ≤ s.slopeGap :=
  sub_nonneg.mpr s.ordered

def isEtale (s : Rank2Slopes) : Prop := s.s₁ = 0 ∧ s.s₂ = 0
def isOrdinary (s : Rank2Slopes) : Prop := s.s₁ = 0
def isSupersingular (s : Rank2Slopes) : Prop := s.s₁ = s.s₂

theorem isEtale_totalSlope (s : Rank2Slopes) (h : s.isEtale) :
    s.totalSlope = 0 := by simp [totalSlope, h.1, h.2]

theorem isSupersingular_gap (s : Rank2Slopes) (h : s.isSupersingular) :
    s.slopeGap = 0 := by
  unfold slopeGap isSupersingular at *; linarith

/-- Supersingular implies each slope is half the total. -/
theorem isSupersingular_half (s : Rank2Slopes) (h : s.isSupersingular) :
    s.s₁ = s.totalSlope / 2 := by
  unfold totalSlope isSupersingular at *; linarith

theorem s₁_le_half_total (s : Rank2Slopes) : s.s₁ ≤ s.totalSlope / 2 := by
  unfold totalSlope; linarith [s.ordered]

theorem s₂_ge_half_total (s : Rank2Slopes) : s.totalSlope / 2 ≤ s.s₂ := by
  unfold totalSlope; linarith [s.ordered]

/-- **Duality**: dual module has negated, reversed slopes. -/
def dual (s : Rank2Slopes) : Rank2Slopes where
  s₁ := -s.s₂; s₂ := -s.s₁; ordered := neg_le_neg_iff.mpr s.ordered

@[simp] theorem dual_dual (s : Rank2Slopes) : s.dual.dual = s := by ext <;> simp [dual]
theorem dual_totalSlope (s : Rank2Slopes) : s.dual.totalSlope = -s.totalSlope := by
  unfold dual totalSlope; ring
theorem dual_slopeGap (s : Rank2Slopes) : s.dual.slopeGap = s.slopeGap := by
  unfold dual slopeGap; ring

/-- **Twist**: tensoring with a character of slope t. -/
def twist (s : Rank2Slopes) (t : ℚ) : Rank2Slopes where
  s₁ := s.s₁ + t; s₂ := s.s₂ + t; ordered := by linarith [s.ordered]

theorem twist_totalSlope (s : Rank2Slopes) (t : ℚ) :
    (s.twist t).totalSlope = s.totalSlope + 2 * t := by unfold twist totalSlope; ring
theorem twist_slopeGap (s : Rank2Slopes) (t : ℚ) :
    (s.twist t).slopeGap = s.slopeGap := by unfold twist slopeGap; ring
theorem twist_twist (s : Rank2Slopes) (t₁ t₂ : ℚ) :
    (s.twist t₁).twist t₂ = s.twist (t₁ + t₂) := by ext <;> simp [twist] <;> ring
@[simp] theorem twist_zero (s : Rank2Slopes) : s.twist 0 = s := by ext <;> simp [twist]
theorem dual_twist (s : Rank2Slopes) (t : ℚ) :
    (s.twist t).dual = s.dual.twist (-t) := by ext <;> simp [twist, dual] <;> ring

/-- Twisting can normalize the lower slope to zero (ordinary reduction). -/
theorem exists_twist_ordinary (s : Rank2Slopes) :
    ∃ t, (s.twist t).isOrdinary :=
  ⟨-s.s₁, by simp [twist, isOrdinary]⟩

/-- Twisting normalizes to étale iff supersingular. -/
theorem exists_twist_etale_iff (s : Rank2Slopes) :
    (∃ t, (s.twist t).isEtale) ↔ s.isSupersingular := by
  constructor
  · rintro ⟨t, h₁, h₂⟩
    simp [twist] at h₁ h₂
    simp [isSupersingular]; linarith
  · intro h
    simp [isSupersingular] at h
    refine ⟨-s.s₁, ?_, ?_⟩ <;> simp [twist, isEtale] <;> linarith

/-- **Theorem**: If two slope data have the same total and gap, they are equal.
    Total slope and slope gap form a complete invariant. -/
theorem eq_of_totalSlope_slopeGap {s t : Rank2Slopes}
    (h1 : s.totalSlope = t.totalSlope) (h2 : s.slopeGap = t.slopeGap) : s = t := by
  ext
  · unfold totalSlope slopeGap at *; linarith
  · unfold totalSlope slopeGap at *; linarith

/-- **Theorem**: The ordinary-supersingular dichotomy for non-negative slopes:
    if s₁ = 0 and s₁ < s₂, then the module is ordinary but not supersingular. -/
theorem ordinary_not_supersingular (s : Rank2Slopes) (_ : s.isOrdinary)
    (hne : s.s₁ < s.s₂) : ¬s.isSupersingular := by
  simp [isOrdinary, isSupersingular] at *; linarith

end Rank2Slopes

/-! ## §4. Weak Admissibility for Rank 2 -/

/-- Weak admissibility data for a rank 2 filtered φ-module. -/
structure Rank2WA where
  slopes : Rank2Slopes
  ht₁ : ℤ
  ht₂ : ℤ
  ht_ordered : ht₁ ≤ ht₂
  total_eq : (slopes.s₁ + slopes.s₂ : ℚ) = ↑ht₁ + ↑ht₂
  sub_cond : slopes.s₁ ≥ (ht₁ : ℚ)

namespace Rank2WA

/-
Upper slope ≤ upper HT weight.
-/
theorem s₂_le_ht₂ (wa : Rank2WA) : wa.slopes.s₂ ≤ (wa.ht₂ : ℚ) := by
  linarith [ wa.total_eq, wa.sub_cond ]

/-
Duality preserves weak admissibility.
-/
theorem dual_wa (wa : Rank2WA) :
    ∃ wa' : Rank2WA,
      wa'.slopes = wa.slopes.dual ∧ wa'.ht₁ = -wa.ht₂ ∧ wa'.ht₂ = -wa.ht₁ := by
  fconstructor;
  constructor;
  rotate_left;
  convert congr_arg Neg.neg wa.total_eq using 1;
  rotate_left;
  rotate_left;
  rotate_left;
  exact wa.slopes.dual;
  exact -wa.ht₂;
  exact -wa.ht₁;
  all_goals norm_num [ Rank2Slopes.dual ];
  · exact wa.ht_ordered;
  · exact s₂_le_ht₂ wa

/-
Twisting preserves weak admissibility.
-/
theorem twist_wa (wa : Rank2WA) (n : ℤ) :
    ∃ wa' : Rank2WA,
      wa'.slopes = wa.slopes.twist n ∧ wa'.ht₁ = wa.ht₁ + n ∧ wa'.ht₂ = wa.ht₂ + n := by
  use ⟨Rank2Slopes.twist wa.slopes n, wa.ht₁ + n, wa.ht₂ + n, by
    linarith [ wa.ht_ordered ], by
    have := wa.total_eq; norm_num [ Rank2Slopes.twist ] at *; linarith;, by
    exact_mod_cast ( by linarith [ wa.sub_cond ] : ( wa.slopes.s₁ : ℚ ) + n ≥ wa.ht₁ + n )⟩

/-
Newton above Hodge: slope gap ≤ HT weight gap.
-/
theorem slopeGap_le_htGap (wa : Rank2WA) :
    wa.slopes.slopeGap ≤ (wa.ht₂ - wa.ht₁ : ℚ) := by
  unfold Rank2Slopes.slopeGap;
  linarith [ wa.s₂_le_ht₂, wa.sub_cond ]

end Rank2WA

/-! ## §5. Colmez Functor -/

/-- Abstract axiomatization of the Colmez functor. -/
structure ColmezFunctorData where
  BanRep : Type*
  GalRep : Type*
  V : BanRep → GalRep
  slopes : GalRep → Rank2Slopes
  htWt : GalRep → ℤ × ℤ
  wa : ∀ π, let s := slopes (V π); let hw := htWt (V π);
    (s.s₁ + s.s₂ : ℚ) = ↑hw.1 + ↑hw.2
  twist_compat : ∀ π (t : ℚ), ∃ π', slopes (V π') = (slopes (V π)).twist t
  dual_compat : ∀ π, ∃ π', slopes (V π') = (slopes (V π)).dual

namespace ColmezFunctorData

variable (F : ColmezFunctorData)

theorem twist_gap_invariant (π : F.BanRep) (t : ℚ)
    (π' : F.BanRep) (h : F.slopes (F.V π') = (F.slopes (F.V π)).twist t) :
    (F.slopes (F.V π')).slopeGap = (F.slopes (F.V π)).slopeGap := by
  rw [h, Rank2Slopes.twist_slopeGap]

theorem dual_gap_invariant (π : F.BanRep)
    (π' : F.BanRep) (h : F.slopes (F.V π') = (F.slopes (F.V π)).dual) :
    (F.slopes (F.V π')).slopeGap = (F.slopes (F.V π)).slopeGap := by
  rw [h, Rank2Slopes.dual_slopeGap]

end ColmezFunctorData

/-! ## §6. The Full Correspondence -/

structure PadicLanglandsCorr extends ColmezFunctorData where
  V_inj : Function.Injective V
  V_surj : Function.Surjective V

namespace PadicLanglandsCorr

variable (plc : PadicLanglandsCorr)

theorem bijective : Function.Bijective plc.V := ⟨plc.V_inj, plc.V_surj⟩

theorem unique_preimage (ρ : plc.GalRep) : ∃! π, plc.V π = ρ := by
  obtain ⟨π, hπ⟩ := plc.V_surj ρ
  exact ⟨π, hπ, fun π' hπ' => plc.V_inj (hπ'.trans hπ.symm)⟩

end PadicLanglandsCorr

/-! ## §7. Trianguline Representations -/

structure TriangulineParam where
  δ₁_slope : ℚ
  δ₂_slope : ℚ

namespace TriangulineParam

def toSlopes (τ : TriangulineParam) : Rank2Slopes where
  s₁ := min τ.δ₁_slope τ.δ₂_slope
  s₂ := max τ.δ₁_slope τ.δ₂_slope
  ordered := min_le_max

theorem totalSlope_eq (τ : TriangulineParam) :
    τ.toSlopes.totalSlope = τ.δ₁_slope + τ.δ₂_slope := by
  simp [toSlopes, Rank2Slopes.totalSlope, min_def, max_def]
  split_ifs <;> ring

def refine (τ : TriangulineParam) : TriangulineParam where
  δ₁_slope := τ.δ₂_slope; δ₂_slope := τ.δ₁_slope

theorem refine_totalSlope (τ : TriangulineParam) :
    τ.refine.toSlopes.totalSlope = τ.toSlopes.totalSlope := by
  rw [totalSlope_eq, totalSlope_eq]; simp [refine]; ring

theorem refine_toSlopes (τ : TriangulineParam) :
    τ.refine.toSlopes = τ.toSlopes := by
  simp only [refine, toSlopes]
  ext
  · exact min_comm _ _
  · exact max_comm _ _

theorem slopeGap_eq (τ : TriangulineParam) :
    τ.toSlopes.slopeGap = |τ.δ₁_slope - τ.δ₂_slope| := by
  simp [toSlopes, Rank2Slopes.slopeGap, max_sub_min_eq_abs, abs_sub_comm]

def twist (τ : TriangulineParam) (t : ℚ) : TriangulineParam where
  δ₁_slope := τ.δ₁_slope + t; δ₂_slope := τ.δ₂_slope + t

theorem twist_toSlopes (τ : TriangulineParam) (t : ℚ) :
    (τ.twist t).toSlopes = τ.toSlopes.twist t := by
  simp only [twist, toSlopes, Rank2Slopes.twist]
  ext
  · exact min_add_add_right _ _ _
  · exact max_add_add_right _ _ _

/-- Supersingular iff both characters have equal slope. -/
theorem supersingular_iff (τ : TriangulineParam) :
    τ.toSlopes.isSupersingular ↔ τ.δ₁_slope = τ.δ₂_slope := by
  constructor
  · intro h
    unfold toSlopes Rank2Slopes.isSupersingular at h
    simp only at h
    by_contra hne
    push_neg at hne
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · rw [min_eq_left hlt.le, max_eq_right hlt.le] at h; linarith
    · rw [min_eq_right hgt.le, max_eq_left hgt.le] at h; linarith
  · intro h; simp [toSlopes, Rank2Slopes.isSupersingular, h]

end TriangulineParam

/-! ## §8. Weight Theory -/

structure WeightData where
  k : ℕ
  k_ge : 2 ≤ k

namespace WeightData

def htWeights (w : WeightData) : ℤ × ℤ := (0, ↑w.k - 1)

theorem ht_sum (w : WeightData) :
    (w.htWeights.1 : ℚ) + (w.htWeights.2 : ℚ) = ↑w.k - 1 := by
  simp [htWeights]

theorem crystalline_upper_bound (w : WeightData) (s : Rank2Slopes)
    (h_total : (s.s₁ + s.s₂ : ℚ) = ↑w.k - 1) (_ : 0 ≤ s.s₁) :
    s.s₂ ≤ ↑w.k - 1 := by linarith [s.ordered]

/-- For weight 2, slopes lie in [0,1/2] × [1/2,1]. -/
theorem weight2_slopes (s : Rank2Slopes)
    (h_total : (s.s₁ + s.s₂ : ℚ) = 1) (_ : 0 ≤ s.s₁) :
    s.s₁ ≤ 1/2 ∧ 1/2 ≤ s.s₂ := by
  constructor <;> linarith [s.ordered]

/-- In weight 2, supersingular iff slopes are (1/2, 1/2). -/
theorem weight2_supersingular (s : Rank2Slopes) (h_total : (s.s₁ + s.s₂ : ℚ) = 1) :
    s.isSupersingular ↔ s.s₁ = 1/2 := by
  simp [Rank2Slopes.isSupersingular]; constructor <;> intro h <;> linarith

end WeightData

/-! ## §9. Short Exact Sequences -/

structure SlopeExactSeq where
  s_sub : ℚ
  s_quot : ℚ
  s_mid : Rank2Slopes
  total_add : s_mid.totalSlope = s_sub + s_quot
  sub_bound : s_mid.s₁ ≤ s_sub

namespace SlopeExactSeq

theorem quot_le_s₂ (ses : SlopeExactSeq) : ses.s_quot ≤ ses.s_mid.s₂ := by
  have := ses.total_add;
  unfold Rank2Slopes.totalSlope at this;
  linarith [ ses.sub_bound ]

/-- The sub slope is at least s₁ (this is an axiom). The converse bound
    s_sub ≤ s₂ requires the additional assumption s_quot ≥ s₁. -/
theorem sub_ge_s₁ (ses : SlopeExactSeq) : ses.s_mid.s₁ ≤ ses.s_sub :=
  ses.sub_bound

/-- If the quotient slope is at least s₁, then the sub slope is at most s₂. -/
theorem sub_le_s₂_of_quot_ge (ses : SlopeExactSeq)
    (hq : ses.s_mid.s₁ ≤ ses.s_quot) : ses.s_sub ≤ ses.s_mid.s₂ := by
  have := ses.total_add
  unfold Rank2Slopes.totalSlope at this
  linarith

theorem dual_exact (ses : SlopeExactSeq) :
    ∃ ses' : SlopeExactSeq,
      ses'.s_sub = -ses.s_quot ∧ ses'.s_quot = -ses.s_sub ∧
      ses'.s_mid = ses.s_mid.dual := by
  fconstructor;
  constructor;
  convert congr_arg Neg.neg ses.total_add using 1;
  convert Rank2Slopes.dual_totalSlope _;
  rotate_left;
  rotate_left;
  exact -ses.s_quot;
  exact -ses.s_sub;
  all_goals norm_num [ add_comm ];
  exact neg_le_neg_iff.mpr ( ses.quot_le_s₂ )

end SlopeExactSeq

/-! ## §10. Breuil-Mézard Multiplicities -/

def crystallineMultiplicity (k a : ℕ) : ℕ :=
  if a ≤ (k - 1) / 2 then k - 1 - 2 * a else 0

example : crystallineMultiplicity 2 0 = 1 := by native_decide
example : crystallineMultiplicity 4 0 = 3 := by native_decide
example : crystallineMultiplicity 4 1 = 1 := by native_decide

end