/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Separation ⇒ Finite Max-Plus Classifier with Certified Margin

This file formalizes a bridge from existential coordinate-wise separation data
to an explicit max-plus (tropical) scoring rule on finite feature sets, together
with a provable positive margin.

## Main definitions

* `tropicalScore` — the max-plus score: `sup'_i (w i + φ i)`
* `tropicallySeparates` — predicate: weight vector `w` with margin `γ` separates
  positive set `P` from negative set `N`
* `tropicalMargin` — the optimal margin achievable by the zero-weight classifier
  on a single separating coordinate

## Main results

* `tropicalScore_ge_coord` — the tropical score is at least any single coordinate
* `tropicalScore_le_of_forall` — the tropical score is at most an upper bound
* `tropicalScore_eq_of_dominant` — when one coordinate dominates all others
* `exists_tropical_separator_with_margin` — main theorem: coordinate separation
  implies existence of weight vector with positive margin
* `tropicalMargin_positive_of_sep` — the explicitly defined margin is positive
* `exists_weights_realizing_margin` — constructive classifier theorem

## Strategy

Given a separating coordinate `i₀` (where all positives beat all negatives),
we construct weight vector `w` with `w i₀ = 0` and `w i = -M` for `i ≠ i₀`,
where `M` is large enough to suppress all other coordinates. The tropical score
then reduces to `φ x i₀`, and separation follows from the coordinate gap.
-/

noncomputable section

open Finset BigOperators

/-! ### Core definitions -/

/-- The tropical (max-plus) score of a point with features `φ` against weight vector `w`.
    This is `max_i (w i + φ i)`, implemented via `Finset.sup'` on `Finset.univ`. -/
def tropicalScore {ι : Type*} [Fintype ι] [Nonempty ι] (w φ : ι → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => w i + φ i)

/-- Weight vector `w` with margin `γ` tropically separates positive set `P`
    from negative set `N` using feature map `φ`. -/
def tropicallySeparates
    {α ι : Type*} [Fintype ι] [Nonempty ι]
    (φ : α → ι → ℝ) (w : ι → ℝ) (γ : ℝ) (P N : Finset α) : Prop :=
  ∀ p ∈ P, ∀ n ∈ N,
    tropicalScore w (φ p) ≥ tropicalScore w (φ n) + γ

/-! ### Basic lemmas about tropical scores -/

/-
The tropical score is at least `w i + φ i` for any coordinate `i`.
-/
theorem tropicalScore_ge_coord {ι : Type*} [Fintype ι] [Nonempty ι]
    (w φ : ι → ℝ) (i : ι) :
    tropicalScore w φ ≥ w i + φ i := by
  -- By definition of `tropicalScore`, we know that `tropicalScore w φ = Finset.univ.sup' Finset.univ_nonempty (fun i => w i + φ i)`. Therefore, we can use the fact that the supremum of a set is greater than or equal to any of its elements.
  apply Finset.le_sup' (fun i => w i + φ i) (Finset.mem_univ i)

/-
The tropical score is at most `a` if every coordinate satisfies `w i + φ i ≤ a`.
-/
theorem tropicalScore_le_of_forall {ι : Type*} [Fintype ι] [Nonempty ι]
    (w φ : ι → ℝ) (a : ℝ) (h : ∀ i, w i + φ i ≤ a) :
    tropicalScore w φ ≤ a := by
  exact Finset.sup'_le _ _ fun i _ => h i

/-
When coordinate `i₀` dominates all others, the tropical score equals `w i₀ + φ i₀`.
-/
theorem tropicalScore_eq_of_dominant {ι : Type*} [Fintype ι] [Nonempty ι]
    (w φ : ι → ℝ) (i₀ : ι) (h : ∀ i, w i + φ i ≤ w i₀ + φ i₀) :
    tropicalScore w φ = w i₀ + φ i₀ := by
  exact le_antisymm ( Finset.sup'_le _ _ fun i _ => h i ) ( Finset.le_sup' ( fun i => w i + φ i ) ( Finset.mem_univ i₀ ) )

/-! ### Main separation theorem -/

/-
**Main theorem: Tropical separation from coordinate witness.**

Given a finite feature map `φ : α → ι → ℝ` and finite sets `P`, `N`,
if there exists a coordinate `i₀` such that `φ n i₀ < φ p i₀` for all
`p ∈ P` and `n ∈ N`, then there exist a weight vector `w : ι → ℝ` and
margin `γ > 0` such that the tropical score of every positive point exceeds
the tropical score of every negative point by at least `γ`.
-/
theorem exists_tropical_separator_with_margin
    {α ι : Type*} [Fintype ι] [Nonempty ι] [DecidableEq ι] [DecidableEq α]
    (φ : α → ι → ℝ) (P N : Finset α)
    (hsep : ∃ i : ι, ∀ p ∈ P, ∀ n ∈ N, φ n i < φ p i) :
    ∃ w : ι → ℝ, ∃ γ : ℝ, 0 < γ ∧
      ∀ p ∈ P, ∀ n ∈ N,
        tropicalScore w (φ p) ≥ tropicalScore w (φ n) + γ := by
  by_cases hPN : P.Nonempty ∧ N.Nonempty;
  · obtain ⟨ i₀, hi₀ ⟩ := hsep;
    -- Define the weight vector $w$ such that $w i₀ = 0$ and $w i = -M$ for $i ≠ i₀$, where $M$ is a large enough constant.
    obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ x ∈ P ∪ N, ∀ i, i ≠ i₀ → -M + φ x i ≤ φ x i₀ := by
      -- Since P ∪ N is finite, the set of values {φ x i - φ x i₀ | x ∈ P ∪ N, i ≠ i₀} is also finite. Therefore, there must be a maximum value in this set.
      obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ x ∈ P ∪ N, ∀ i ≠ i₀, φ x i - φ x i₀ ≤ M := by
        exact ⟨ ∑ x ∈ P ∪ N, ∑ i ∈ Finset.univ, |φ x i - φ x i₀|, fun x hx i hi => le_trans ( le_abs_self _ ) ( Finset.single_le_sum ( fun x _ => Finset.sum_nonneg fun i _ => abs_nonneg ( φ x i - φ x i₀ ) ) hx |> le_trans ( Finset.single_le_sum ( fun i _ => abs_nonneg ( φ x i - φ x i₀ ) ) ( Finset.mem_univ i ) ) ) ⟩;
      exact ⟨ M, fun x hx i hi => by linarith [ hM x hx i hi ] ⟩;
    refine' ⟨ fun i => if i = i₀ then 0 else -M, ( Finset.inf' ( P.product N ) ( Finset.Nonempty.mono ( Finset.product_subset_product ( Finset.Subset.refl _ ) ( Finset.Subset.refl _ ) ) ( Finset.Nonempty.product hPN.1 hPN.2 ) ) fun v => φ v.1 i₀ - φ v.2 i₀ ), _, _ ⟩;
    · simp +zetaDelta at *;
      exact fun a b ha hb => hi₀ a ha b hb;
    · intro p hp n hn
      have h_tropical_p : tropicalScore (fun i => if i = i₀ then 0 else -M) (φ p) ≥ φ p i₀ := by
        exact le_trans ( by aesop ) ( Finset.le_sup' ( fun i => ( if i = i₀ then 0 else -M ) + φ p i ) ( Finset.mem_univ i₀ ) )
      have h_tropical_n : tropicalScore (fun i => if i = i₀ then 0 else -M) (φ n) ≤ φ n i₀ := by
        apply tropicalScore_le_of_forall;
        grind
      have h_gap : φ p i₀ - φ n i₀ ≥ (Finset.inf' (P.product N) (Finset.Nonempty.mono (Finset.product_subset_product (Finset.Subset.refl _) (Finset.Subset.refl _)) (Finset.Nonempty.product hPN.1 hPN.2)) fun v => φ v.1 i₀ - φ v.2 i₀) := by
        exact Finset.inf'_le _ ( Finset.mk_mem_product hp hn ) |> le_trans <| by simp +decide ;
      linarith [h_tropical_p, h_tropical_n, h_gap];
  · exact ⟨ 0, 1, zero_lt_one, fun p hp n hn => False.elim ( hPN ⟨ ⟨ p, hp ⟩, ⟨ n, hn ⟩ ⟩ ) ⟩

/-! ### Explicit margin definition and positivity -/

/-- The tropical margin on coordinate `i₀`: minimum over all pairs `(p, n) ∈ P × N`
    of the gap `φ p i₀ - φ n i₀`. -/
noncomputable def tropicalCoordMargin
    {α ι : Type*}
    (φ : α → ι → ℝ) (i₀ : ι) (P N : Finset α)
    (hPN : (P ×ˢ N).Nonempty) : ℝ :=
  (P ×ˢ N).inf' hPN (fun pn => φ pn.1 i₀ - φ pn.2 i₀)

/-
The coordinate margin is positive when `i₀` separates all pairs.
-/
theorem tropicalCoordMargin_pos
    {α ι : Type*} [DecidableEq α]
    (φ : α → ι → ℝ) (i₀ : ι) (P N : Finset α)
    (hPN : (P ×ˢ N).Nonempty)
    (hsep : ∀ p ∈ P, ∀ n ∈ N, φ n i₀ < φ p i₀) :
    0 < tropicalCoordMargin φ i₀ P N hPN := by
  unfold tropicalCoordMargin;
  simp +zetaDelta at *;
  grind +extAll

/-! ### Constructive classifier -/

/-
Given a separating coordinate and nonempty sets, there exist explicit weights
    realizing the coordinate margin as a tropical margin.
-/
theorem exists_weights_realizing_margin
    {α ι : Type*} [Fintype ι] [Nonempty ι] [DecidableEq ι] [DecidableEq α]
    (φ : α → ι → ℝ) (P N : Finset α) (i₀ : ι)
    (hP : P.Nonempty) (hN : N.Nonempty)
    (hsep : ∀ p ∈ P, ∀ n ∈ N, φ n i₀ < φ p i₀) :
    let hPN : (P ×ˢ N).Nonempty := Finset.Nonempty.product hP hN
    let γ := tropicalCoordMargin φ i₀ P N hPN
    ∃ w : ι → ℝ,
      0 < γ ∧
      ∀ p ∈ P, ∀ n ∈ N,
        tropicalScore w (φ p) ≥ tropicalScore w (φ n) + γ := by
  -- Let's choose $M$ large enough to suppress all coordinates except $i₀$.
  obtain ⟨bigM, hbigM⟩ : ∃ bigM : ℝ, ∀ x ∈ P ∪ N, ∀ i ∈ Finset.univ.erase i₀, (φ x i - φ x i₀) ≤ bigM := by
    exact ⟨ ∑ x ∈ P ∪ N, ∑ i ∈ Finset.univ.erase i₀, |φ x i - φ x i₀|, fun x hx i hi => le_trans ( le_abs_self _ ) ( Finset.single_le_sum ( fun x _ => Finset.sum_nonneg fun i _ => abs_nonneg ( φ x i - φ x i₀ ) ) hx |> le_trans ( Finset.single_le_sum ( fun i _ => abs_nonneg ( φ x i - φ x i₀ ) ) hi ) ) ⟩;
  refine' ⟨ fun i => if i = i₀ then 0 else -bigM - 1, _, _ ⟩ <;> simp_all +decide [ tropicalScore ];
  · exact tropicalCoordMargin_pos φ i₀ P N ( Finset.Nonempty.product hP hN ) hsep;
  · intro p hp n hn
    use i₀
    simp [tropicalCoordMargin];
    refine' le_trans ( add_le_add ( Finset.sup'_le _ _ _ ) ( Finset.inf'_le _ _ ) ) _ <;> norm_num;
    exact φ n i₀;
    exact fun i => by split_ifs <;> [ simp +decide [ * ] ; linarith [ hbigM n ( Or.inr hn ) i ( by tauto ) ] ] ;
    exacts [ ⟨ p, n ⟩, ⟨ hp, hn ⟩, by linarith [ hsep p hp n hn ] ]

/-! ### Concrete validation example -/

/-- Feature map for the concrete example: 4 points, 2 features.
    Points 0,1 are positive (high feature 0), points 2,3 are negative (low feature 0). -/
def examplePhi : Fin 4 → Fin 2 → ℝ
  | 0 => ![10, 1]    -- positive point 1
  | 1 => ![8, 2]     -- positive point 2
  | 2 => ![3, 5]     -- negative point 1
  | 3 => ![2, 7]

/-
negative point 2

Coordinate 0 separates the positive set {0,1} from the negative set {2,3}.
-/
theorem examplePhi_sep :
    ∀ p ∈ ({0, 1} : Finset (Fin 4)), ∀ n ∈ ({2, 3} : Finset (Fin 4)),
      examplePhi n 0 < examplePhi p 0 := by
  simp +decide [ examplePhi ];
  norm_num

/-
The concrete example admits a tropical separator with positive margin.
-/
theorem example_tropical_separator :
    ∃ w : Fin 2 → ℝ, ∃ γ : ℝ, 0 < γ ∧
      tropicallySeparates examplePhi w γ ({0, 1} : Finset (Fin 4)) ({2, 3} : Finset (Fin 4)) := by
  exact exists_tropical_separator_with_margin examplePhi { 0, 1 } { 2, 3 } ⟨ 0, examplePhi_sep ⟩

end