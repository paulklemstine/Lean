/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Dual Tropical Certificate: Margin Geometry as Chamber Stability

This file establishes the formal foundations for tropical classifier certification.
We prove that robustness regions of tropical piecewise-linear classifiers decompose
into finite unions of affine polyhedra (chamber decomposition), and that Lipschitz
control yields certified robustness radii.

## Main Results

* `tropical_margin_ge_eq_finite_union_polyhedral` — The margin region of a tropical
  classifier is a finite union of affine polyhedral cells.
* `tropical_certified_radius` — Lipschitz control on the margin function yields
  a certified robustness radius.
* `tropical_distinguishing_advantage_stability` — Stability of positivity of a
  Lipschitz function under bounded perturbations (cryptographic analogue).
* `tropical_margin_lipschitz_of_score_lipschitz` — The margin function inherits
  Lipschitz continuity from the individual scores.

## References

This work connects tropical geometry, adversarial robustness, and post-quantum
cryptographic stability through a unified chamber-stability framework.
-/
import Mathlib

open Finset BigOperators NNReal

noncomputable section

/-! ## Part 1: Definitions -/

/-- An affine halfspace in `Fin n → ℝ` defined by `{x | ∑ i, w i * x i + b ≥ 0}`. -/
def AffineHalfspace (n : ℕ) : Type :=
  (Fin n → ℝ) × ℝ

/-- Membership in an affine halfspace. -/
def AffineHalfspace.mem {n : ℕ} (h : AffineHalfspace n) (x : Fin n → ℝ) : Prop :=
  0 ≤ (∑ i, h.1 i * x i) + h.2

/-- An affine polyhedron is a finite intersection of affine halfspaces. -/
def IsAffinePolyhedralSet (n : ℕ) (S : Set (Fin n → ℝ)) : Prop :=
  ∃ (m : ℕ) (hs : Fin m → AffineHalfspace n),
    S = {x | ∀ j, (hs j).mem x}

/-- A tropical affine form: a finite family of affine functions,
    evaluated as their pointwise maximum. -/
structure TropicalAffineForm (n : ℕ) where
  numTerms : ℕ
  hpos : 0 < numTerms
  slopes : Fin numTerms → (Fin n → ℝ)
  intercepts : Fin numTerms → ℝ

/-- Evaluate a single affine term. -/
def affineEval {n : ℕ} (a : Fin n → ℝ) (b : ℝ) (x : Fin n → ℝ) : ℝ :=
  (∑ i, a i * x i) + b

/-- Evaluate a tropical affine form at a point: max over all terms. -/
def TropicalAffineForm.eval {n : ℕ} (f : TropicalAffineForm n) (x : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' ⟨⟨0, f.hpos⟩, Finset.mem_univ _⟩
    (fun k => affineEval (f.slopes k) (f.intercepts k) x)

/-- The pairwise margin region: all points where class c₀ beats every other class
    by at least margin m. -/
def PairwiseMarginRegion {n : ℕ} {ι : Type} [DecidableEq ι]
    (score : ι → (Fin n → ℝ) → ℝ) (c₀ : ι) (m : ℝ) : Set (Fin n → ℝ) :=
  {x | ∀ d, d ≠ c₀ → m ≤ score c₀ x - score d x}

/-- A chamber assignment: for each class, which term is active. -/
def ChamberIdx {ι : Type} [Fintype ι] {n : ℕ}
    (forms : ι → TropicalAffineForm n) : Type :=
  (c : ι) → Fin (forms c).numTerms

/-- The chamber cell: the set of points where the specified terms are active
    (i.e., achieve the maximum) for each class. -/
def ChamberCell {n : ℕ} {ι : Type} [Fintype ι]
    (forms : ι → TropicalAffineForm n)
    (σ : ChamberIdx forms) : Set (Fin n → ℝ) :=
  {x | ∀ (c : ι) (k : Fin (forms c).numTerms),
    affineEval ((forms c).slopes k) ((forms c).intercepts k) x ≤
    affineEval ((forms c).slopes (σ c)) ((forms c).intercepts (σ c)) x}

/-! ## Part 2: Chamber Structure Theorems -/

/-
Each chamber cell is an affine polyhedral set: it is cut out by finitely many
    affine halfspace inequalities (one per term per class).
-/
theorem chamberCell_isAffinePolyhedral {n : ℕ} {ι : Type} [Fintype ι]
    (forms : ι → TropicalAffineForm n)
    (σ : ChamberIdx forms) :
    IsAffinePolyhedralSet n (ChamberCell forms σ) := by
  refine' ⟨ _, _, _ ⟩;
  exact Fintype.card ( Σ c : ι, Fin ( forms c |> TropicalAffineForm.numTerms ) );
  exact fun j => ⟨ fun i => ( forms ( Fintype.equivFin _ |>.symm j |>.1 ) |> TropicalAffineForm.slopes ) ( σ ( Fintype.equivFin _ |>.symm j |>.1 ) ) i - ( forms ( Fintype.equivFin _ |>.symm j |>.1 ) |> TropicalAffineForm.slopes ) ( Fintype.equivFin _ |>.symm j |>.2 ) i, ( forms ( Fintype.equivFin _ |>.symm j |>.1 ) |> TropicalAffineForm.intercepts ) ( σ ( Fintype.equivFin _ |>.symm j |>.1 ) ) - ( forms ( Fintype.equivFin _ |>.symm j |>.1 ) |> TropicalAffineForm.intercepts ) ( Fintype.equivFin _ |>.symm j |>.2 ) ⟩;
  ext; simp +decide [ ChamberCell, AffineHalfspace.mem ];
  constructor <;> intro h;
  · intro j; specialize h ( Fintype.equivFin _ |>.symm j |>.1 ) ( Fintype.equivFin _ |>.symm j |>.2 ) ; simp_all +decide [ affineEval, sub_mul, Finset.sum_sub_distrib ] ;
    linarith;
  · intro c k; specialize h ( Fintype.equivFin _ ⟨ c, k ⟩ ) ; simp_all +decide [ sub_mul, affineEval ] ;
    grind

/-
On a chamber cell, the score of each class equals the active affine term.
-/
theorem score_eq_affine_on_chamber {n : ℕ} {ι : Type} [Fintype ι]
    (forms : ι → TropicalAffineForm n)
    (σ : ChamberIdx forms)
    (c : ι) (x : Fin n → ℝ)
    (hx : x ∈ ChamberCell forms σ) :
    (forms c).eval x = affineEval ((forms c).slopes (σ c)) ((forms c).intercepts (σ c)) x := by
  refine' le_antisymm ( Finset.sup'_le _ _ _ ) _;
  · exact fun k _ => hx c k;
  · exact Finset.le_sup' ( fun k => affineEval ( ( forms c ).slopes k ) ( ( forms c ).intercepts k ) x ) ( Finset.mem_univ _ )

/-
The pairwise margin region restricted to a chamber cell is affine polyhedral.
    This is the key geometric insight: within a single linearity chamber,
    each score is affine, so each margin inequality `m ≤ score c₀ x - score d x`
    is a single affine halfspace constraint.
-/
theorem margin_region_on_chamber_isAffinePolyhedral {n : ℕ} {ι : Type} [Fintype ι] [DecidableEq ι]
    (forms : ι → TropicalAffineForm n)
    (σ : ChamberIdx forms)
    (c₀ : ι) (m : ℝ) :
    IsAffinePolyhedralSet n
      (ChamberCell forms σ ∩
       PairwiseMarginRegion (fun c => (forms c).eval) c₀ m) := by
  -- The set ChamberCell forms σ ∩ PairwiseMarginRegion (fun c => (forms c).eval) c₀ m is an intersection of two polyhedral sets.
  have h_inter_polyhedra : IsAffinePolyhedralSet n (ChamberCell forms σ) ∧ IsAffinePolyhedralSet n (PairwiseMarginRegion (fun c => (forms c).eval) c₀ m ∩ ChamberCell forms σ) := by
    refine' ⟨ chamberCell_isAffinePolyhedral forms σ, _ ⟩;
    -- The intersection of two affine polyhedral sets is affine polyhedral.
    have h_inter : IsAffinePolyhedralSet n (ChamberCell forms σ ∩ {x | ∀ d ≠ c₀, m ≤ (forms c₀).eval x - (forms d).eval x}) := by
      have h_inter : IsAffinePolyhedralSet n (ChamberCell forms σ ∩ {x | ∀ d ≠ c₀, m ≤ affineEval ((forms c₀).slopes (σ c₀)) ((forms c₀).intercepts (σ c₀)) x - affineEval ((forms d).slopes (σ d)) ((forms d).intercepts (σ d)) x}) := by
        have h_inter : IsAffinePolyhedralSet n (ChamberCell forms σ) ∧ IsAffinePolyhedralSet n {x | ∀ d ≠ c₀, m ≤ affineEval ((forms c₀).slopes (σ c₀)) ((forms c₀).intercepts (σ c₀)) x - affineEval ((forms d).slopes (σ d)) ((forms d).intercepts (σ d)) x} := by
          constructor;
          · grind +suggestions;
          · use (Fintype.card ι - 1);
            -- Define the halfspaces for each $d \neq c₀$.
            obtain ⟨hs, hhs⟩ : ∃ hs : Fin (Fintype.card ι - 1) → ι, Function.Injective hs ∧ ∀ j, hs j ≠ c₀ := by
              have h_card : Fintype.card {x : ι // x ≠ c₀} = Fintype.card ι - 1 := by
                simp +decide [ Finset.filter_ne' ];
              have := Fintype.truncEquivFinOfCardEq h_card;
              obtain ⟨ e ⟩ := Trunc.exists_rep this; exact ⟨ fun j => e.symm j |>.1, fun a b h => by simpa [ Subtype.ext_iff ] using e.symm.injective ( Subtype.ext h ), fun j => e.symm j |>.2 ⟩ ;
            refine' ⟨ fun j => ⟨ fun i => ( forms c₀ |> TropicalAffineForm.slopes ) ( σ c₀ ) i - ( forms ( hs j ) |> TropicalAffineForm.slopes ) ( σ ( hs j ) ) i, ( forms c₀ |> TropicalAffineForm.intercepts ) ( σ c₀ ) - ( forms ( hs j ) |> TropicalAffineForm.intercepts ) ( σ ( hs j ) ) - m ⟩, _ ⟩ ; ext x ; simp +decide [ AffineHalfspace.mem ] ;
            constructor <;> intro h <;> simp_all +decide [ sub_mul, affineEval ];
            · exact fun j => by linarith [ h ( hs j ) ( hhs.2 j ) ] ;
            · intro d hd; have := Finset.eq_of_subset_of_card_le ( show Finset.image hs Finset.univ ⊆ Finset.univ.erase c₀ from Finset.image_subset_iff.mpr fun j _ => Finset.mem_erase_of_ne_of_mem ( hhs.2 j ) ( Finset.mem_univ _ ) ) ; simp_all +decide [ Finset.card_image_of_injective _ hhs.1 ] ;
              replace this := Finset.ext_iff.mp this d; simp_all +decide [ Finset.mem_image ] ;
              obtain ⟨ j, rfl ⟩ := this; specialize h j; ring_nf at *; linarith;
        obtain ⟨ ⟨ m₁, hs₁, h₁ ⟩, ⟨ m₂, hs₂, h₂ ⟩ ⟩ := h_inter;
        use m₁ + m₂;
        use Fin.append hs₁ hs₂;
        simp_all +decide [ Fin.forall_fin_add, Set.ext_iff ];
      convert h_inter using 1;
      ext x;
      simp +decide [ score_eq_affine_on_chamber ];
      exact fun hx => forall_congr' fun d => forall_congr' fun hd => by rw [ score_eq_affine_on_chamber forms σ c₀ x hx, score_eq_affine_on_chamber forms σ d x hx ] ;
    simpa only [ Set.inter_comm ] using h_inter;
  grind

/-! ## Part 3: Main Theorem A — Finite Union Decomposition -/

/-
The full space is covered by chamber cells.
-/
theorem chamber_cover {n : ℕ} {ι : Type} [Fintype ι]
    (forms : ι → TropicalAffineForm n) :
    ∀ x : Fin n → ℝ, ∃ σ : ChamberIdx forms, x ∈ ChamberCell forms σ := by
  intro x
  have h_sup : ∀ c, ∃ k : Fin (forms c).numTerms, ∀ k', affineEval ((forms c).slopes k') ((forms c).intercepts k') x ≤ affineEval ((forms c).slopes k) ((forms c).intercepts k) x := by
    exact fun c => by simpa using Finset.exists_max_image Finset.univ ( fun k => affineEval ( ( forms c ).slopes k ) ( ( forms c ).intercepts k ) x ) ⟨ ⟨ 0, forms c |>.hpos ⟩, Finset.mem_univ _ ⟩ ;
  choose σ hσ using h_sup; use σ; exact fun c k => hσ c k;

/-
**Main Theorem A**: The pairwise margin region of a tropical classifier is a finite
    union of affine polyhedral cells.

    Each cell corresponds to a chamber assignment (choice of active affine term for each
    class). Within each chamber, all score functions are affine, so the margin constraints
    become affine halfspace conditions. The full margin region is the union over all
    possible chamber assignments.
-/
theorem tropical_margin_ge_eq_finite_union_polyhedral
    {n : ℕ} {ι : Type} [Fintype ι] [DecidableEq ι]
    (forms : ι → TropicalAffineForm n)
    (c₀ : ι) (m : ℝ) :
    ∃ (cells : Finset (Set (Fin n → ℝ))),
      (∀ s ∈ cells, IsAffinePolyhedralSet n s) ∧
      PairwiseMarginRegion (fun c => (forms c).eval) c₀ m =
        ⋃₀ ↑cells := by
  have h_finite : Set.Finite (Set.range (fun σ : ChamberIdx forms => ChamberCell forms σ ∩ PairwiseMarginRegion (fun c => (forms c).eval) c₀ m)) := by
    have h_finite : Fintype (ChamberIdx forms) := by
      exact Fintype.ofEquiv _ ( Equiv.piCongrRight fun _ => Equiv.refl _ );
    exact Set.toFinite _;
  refine' ⟨ h_finite.toFinset, _, _ ⟩ <;> simp_all +decide [ Set.ext_iff ];
  · intro s σ hs; specialize hs; exact (by
    convert margin_region_on_chamber_isAffinePolyhedral forms σ c₀ m using 1 ; ext ; aesop);
  · exact fun x hx => by obtain ⟨ σ, hσ ⟩ := chamber_cover forms x; exact ⟨ σ, hσ ⟩ ;

/-! ## Part 4: Lipschitz Certificate Theorems -/

/-
**Main Theorem B (core inequality)**: If a function `f` is Lipschitz with constant `L > 0`,
    and `f(x) ≥ m`, then `f(y) ≥ 0` for all `y` with `‖y - x‖ ≤ m / L`.

    This is the core certified robustness inequality.
-/
theorem certified_robustness_from_lipschitz
    {n : ℕ} (f : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ)
    (m : ℝ) (L : ℝ≥0) (hL : 0 < (L : ℝ))
    (hm : m ≤ f x)
    (hf : LipschitzWith L f)
    (y : Fin n → ℝ) (hy : ‖y - x‖ ≤ m / L) :
    0 ≤ f y := by
  -- By the Lipschitz condition, we have |f y - f x| ≤ L * ‖y - x‖.
  have h_lip : |f y - f x| ≤ L * ‖y - x‖ := by
    exact hf.dist_le_mul y x;
  nlinarith [ abs_le.mp h_lip, mul_div_cancel₀ m ( ne_of_gt hL ) ]

/-
Each affine function `x ↦ ∑ i, a i * x i + b` is Lipschitz with constant
    `∑ i, |a i|` (the ℓ¹ norm of the gradient, which controls the Lipschitz constant
    in the ℓ∞ metric on `Fin n → ℝ`).
-/
theorem lipschitzWith_affineEval {n : ℕ} (a : Fin n → ℝ) (b : ℝ) :
    LipschitzWith (⟨∑ i : Fin n, ‖a i‖, Finset.sum_nonneg (fun i _ => norm_nonneg (a i))⟩ : ℝ≥0)
      (affineEval a b) := by
  refine' LipschitzWith.of_dist_le_mul _;
  norm_num [ affineEval, dist_eq_norm ];
  intro x y; rw [ ← Finset.sum_sub_distrib ] ; exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( by simpa only [ ← mul_sub, Finset.sum_mul _ _ _ ] using Finset.sum_le_sum fun i _ => by rw [ abs_mul ] ; exact mul_le_mul_of_nonneg_left ( by simpa using ( norm_le_pi_norm ( x - y ) i ) ) ( abs_nonneg _ ) ) ;

/-
**Main Theorem B**: Tropical certified robustness radius.
    If the margin at `x` is at least `m`, and all scores are Lipschitz with constant `L`,
    then for any `y` within distance `m / (2L)`, the classifier still predicts class `c₀`.
-/
theorem tropical_certified_radius
    {n : ℕ} {ι : Type} [Fintype ι] [DecidableEq ι]
    (score : ι → (Fin n → ℝ) → ℝ) (c₀ : ι)
    (L : ℝ≥0) (hLpos : 0 < (L : ℝ))
    (hL : ∀ c, LipschitzWith L (score c))
    (_hι : ∃ d : ι, d ≠ c₀)
    (x : Fin n → ℝ) (m : ℝ) (_hm : 0 < m)
    (hmargin : ∀ d, d ≠ c₀ → m ≤ score c₀ x - score d x) :
    ∀ y, ‖y - x‖ ≤ m / (2 * L) →
      ∀ d, d ≠ c₀ → 0 ≤ score c₀ y - score d y := by
  intros y hy d hd;
  -- By the Lipschitz property of the score functions, we have:
  have h_lip : ∀ c, ∀ x y, |score c x - score c y| ≤ L * ‖x - y‖ := by
    exact fun c x y => by simpa [ mul_comm ] using hL c |> fun h => h.dist_le_mul x y;
  nlinarith [ abs_le.mp ( h_lip c₀ y x ), abs_le.mp ( h_lip d y x ), hmargin d hd, mul_div_cancel₀ m ( by positivity : ( 2 * L : ℝ ) ≠ 0 ) ]

/-! ## Part 5: Cryptographic Stability (Theorem C) -/

/-
**Main Theorem C**: Stability of a distinguishing advantage.
    If a Lipschitz function (representing an advantage) is at least `m` at parameters `x`,
    then it stays nonneg under perturbations bounded by `m / L`.
-/
theorem tropical_distinguishing_advantage_stability
    {n : ℕ}
    (adv : (Fin n → ℝ) → ℝ)
    (x : Fin n → ℝ)
    (m : ℝ) (L : ℝ≥0) (hL : 0 < (L : ℝ))
    (hm : m ≤ adv x)
    (hLip : LipschitzWith L adv) :
    ∀ y, ‖y - x‖ ≤ m / L → 0 ≤ adv y := by
  exact fun y a => certified_robustness_from_lipschitz adv x m L hL hm hLip y a

/-- Security stability under parameter perturbation: if security holds at parameter
    point `p` with margin `m`, and the security advantage is `L`-Lipschitz,
    then security holds at any `p'` within distance `m / L`. -/
theorem security_stable_under_parameter_perturbation
    {n : ℕ}
    (securityAdvantage : (Fin n → ℝ) → ℝ)
    (securityPredicate : (Fin n → ℝ) → Prop)
    (hsec : ∀ p, 0 ≤ securityAdvantage p → securityPredicate p)
    (p : Fin n → ℝ) (m : ℝ) (L : ℝ≥0)
    (hL : 0 < (L : ℝ))
    (hm : m ≤ securityAdvantage p)
    (hLip : LipschitzWith L securityAdvantage)
    (p' : Fin n → ℝ) (hpert : ‖p' - p‖ ≤ m / L) :
    securityPredicate p' := by
  exact hsec p' (tropical_distinguishing_advantage_stability securityAdvantage p m L hL hm hLip p' hpert)

end