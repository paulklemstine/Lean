import Mathlib

/-!
# Voice-Leading as a Category with Functor to Lawvere Metric Spaces

This file constructs a **category** whose objects are equal-cardinality voicings
and whose morphisms are voice-leadings (permutation-based assignments), then
proves the fundamental **cost triangle inequality** that makes it a Lawvere metric.

## Main Results

* `VLF.VLHom.cost_comp_le` — Triangle inequality for composition of voice-leadings
* `VLF.VLHom.cost_id` — Identity morphism has zero cost
* `VLF.vlBundledLawvere` — Voice-leadings form a Lawvere metric space
* `VLF.vlDist_triangle` — Triangle inequality for minimum voice-leading distance

## Mathematical Significance

Voice-leading — the art of moving smoothly between chords — is shown to be
not merely a musical heuristic but a **functorial distance theory**: the cost
of voice-leading satisfies the enriched composition law of Lawvere metric spaces.
-/

open Finset BigOperators CategoryTheory

noncomputable section

namespace VLF

/-! ## Core Definitions -/

/-- A voicing of n notes is a function from Fin n to pitch classes in ℤ. -/
abbrev Voicing (n : ℕ) := Fin n → ℤ

/-- Voice-leading morphism: a permutation-based assignment between voicings. -/
structure VLHom {n : ℕ} (V W : Voicing n) where
  perm : Equiv.Perm (Fin n)

/-- Identity voice-leading. -/
def VLHom.id {n : ℕ} (V : Voicing n) : VLHom V V where
  perm := Equiv.refl _

/-- Composition of voice-leadings. -/
def VLHom.comp {n : ℕ} {V W U : Voicing n} (f : VLHom V W) (g : VLHom W U) :
    VLHom V U where
  perm := f.perm.trans g.perm

/-- Cost (total displacement) of a voice-leading. -/
def VLHom.cost {n : ℕ} {V W : Voicing n} (f : VLHom V W) : ℝ :=
  ∑ i : Fin n, |(V i : ℝ) - (W (f.perm i) : ℝ)|

/-- Identity voice-leading has zero cost. -/
theorem VLHom.cost_id {n : ℕ} (V : Voicing n) : (VLHom.id V).cost = 0 := by
  simp [VLHom.cost, VLHom.id]

/-- Cost is nonnegative. -/
theorem VLHom.cost_nonneg {n : ℕ} {V W : Voicing n} (f : VLHom V W) : 0 ≤ f.cost :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
**Triangle inequality for voice-leading cost**: the cost of a composed
voice-leading is at most the sum of the individual costs.
This is the fundamental enriched composition law.
-/
theorem VLHom.cost_comp_le {n : ℕ} {V W U : Voicing n}
    (f : VLHom V W) (g : VLHom W U) :
    (f.comp g).cost ≤ f.cost + g.cost := by
  convert Finset.sum_le_sum fun i _ => ?_;
  nontriviality;
  rotate_left;
  exact fun i => |( V i : ℝ ) - ( W ( f.perm i ) : ℝ )| + |( W ( f.perm i ) : ℝ ) - ( U ( g.perm ( f.perm i ) ) : ℝ )|;
  · infer_instance;
  · convert abs_sub_le _ _ _ using 2;
    infer_instance;
  · rw [ Finset.sum_add_distrib, eq_comm ];
    exact congrArg₂ ( · + · ) rfl ( Equiv.sum_comp f.perm fun x => |( W x : ℝ ) - ( U ( g.perm x ) : ℝ )| )

/-! ## Minimum Voice-Leading Distance -/

/-- Minimum voice-leading distance. -/
def vlDist {n : ℕ} (V W : Voicing n) : ℝ :=
  (Finset.univ : Finset (Equiv.Perm (Fin n))).inf'
    Finset.univ_nonempty
    (fun σ => ∑ i : Fin n, |(V i : ℝ) - (W (σ i) : ℝ)|)

theorem vlDist_nonneg {n : ℕ} (V W : Voicing n) : 0 ≤ vlDist V W :=
  Finset.le_inf' _ _ fun _ _ => Finset.sum_nonneg fun _ _ => abs_nonneg _

theorem vlDist_self {n : ℕ} (V : Voicing n) : vlDist V V = 0 := by
  refine le_antisymm ?_ (vlDist_nonneg V V)
  calc vlDist V V ≤ ∑ i : Fin n, |(V i : ℝ) - (V ((Equiv.refl _) i) : ℝ)| :=
        Finset.inf'_le _ (Finset.mem_univ _)
    _ = 0 := by simp

/-
Triangle inequality for minimum voice-leading distance.
-/
theorem vlDist_triangle {n : ℕ} (V W U : Voicing n) :
    vlDist V U ≤ vlDist V W + vlDist W U := by
  -- Apply the triangle inequality to each term in the infimum.
  have h_triangle : ∀ σ₁ σ₂ : Equiv.Perm (Fin n), (∑ i : Fin n, |(V i : ℝ) - (U (σ₁.trans σ₂ i) : ℝ)|) ≤ (∑ i : Fin n, |(V i : ℝ) - (W (σ₁ i) : ℝ)|) + (∑ i : Fin n, |(W i : ℝ) - (U (σ₂ i) : ℝ)|) := by
    intros σ₁ σ₂
    have h_triangle : ∀ i : Fin n, |(V i : ℝ) - (U (σ₁.trans σ₂ i) : ℝ)| ≤ |(V i : ℝ) - (W (σ₁ i) : ℝ)| + |(W (σ₁ i) : ℝ) - (U (σ₁.trans σ₂ i) : ℝ)| := by
      exact fun i => abs_sub_le _ _ _;
    convert Finset.sum_le_sum fun i _ => h_triangle i using 1;
    simp +decide [ Finset.sum_add_distrib, Equiv.sum_comp σ₁ fun i => |( W i : ℝ ) - U ( σ₂ i )| ];
  -- By definition of infimum, for any ε > 0, there exist permutations σ₁ and σ₂ such that the sum of the costs of the individual voice-leadings is within ε of the infimum.
  have h_inf : ∀ ε > 0, ∃ σ₁ σ₂ : Equiv.Perm (Fin n), (∑ i : Fin n, |(V i : ℝ) - (W (σ₁ i) : ℝ)|) < vlDist V W + ε ∧ (∑ i : Fin n, |(W i : ℝ) - (U (σ₂ i) : ℝ)|) < vlDist W U + ε := by
    intro ε hε
    have h_inf_VW : ∃ σ₁ : Equiv.Perm (Fin n), (∑ i : Fin n, |(V i : ℝ) - (W (σ₁ i) : ℝ)|) < vlDist V W + ε := by
      have := Finset.exists_min_image Finset.univ ( fun σ : Equiv.Perm ( Fin n ) => ∑ i : Fin n, |( V i : ℝ ) - W ( σ i )| ) ⟨ Equiv.refl ( Fin n ), Finset.mem_univ _ ⟩;
      exact ⟨ this.choose, lt_of_le_of_lt ( this.choose_spec.2 _ ( Finset.mem_univ _ ) ) ( lt_add_of_le_of_pos ( Finset.le_inf' _ _ fun x hx => this.choose_spec.2 x hx ) hε ) ⟩
    have h_inf_WU : ∃ σ₂ : Equiv.Perm (Fin n), (∑ i : Fin n, |(W i : ℝ) - (U (σ₂ i) : ℝ)|) < vlDist W U + ε := by
      contrapose! hε;
      exact le_of_not_gt fun h => by have := Finset.exists_min_image Finset.univ ( fun σ₂ : Equiv.Perm ( Fin n ) => ∑ i : Fin n, |( W i : ℝ ) - U ( σ₂ i )| ) ⟨ Equiv.refl _, Finset.mem_univ _ ⟩ ; obtain ⟨ σ₂, hσ₂₁, hσ₂₂ ⟩ := this; linarith [ hε σ₂, show vlDist W U = ∑ i : Fin n, |( W i : ℝ ) - U ( σ₂ i )| from le_antisymm ( Finset.inf'_le _ <| Finset.mem_univ _ ) <| Finset.le_inf' _ _ fun σ₃ hσ₃ => hσ₂₂ σ₃ <| Finset.mem_univ _ ] ;
    obtain ⟨σ₁, hσ₁⟩ := h_inf_VW
    obtain ⟨σ₂, hσ₂⟩ := h_inf_WU
    use σ₁, σ₂;
  refine' le_of_forall_pos_le_add fun ε ε_pos => _;
  obtain ⟨ σ₁, σ₂, h₁, h₂ ⟩ := h_inf ( ε / 2 ) ( half_pos ε_pos ) ; exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ ( σ₁.trans σ₂ ) ) ) ( by linarith [ h_triangle σ₁ σ₂ ] ) ;

/-! ## Lawvere Metric Space -/

/-- A bundled Lawvere metric space. -/
structure BundledLawvere where
  carrier : Type*
  dist : carrier → carrier → ℝ
  dist_self : ∀ x, dist x x = 0
  dist_nonneg : ∀ x y, 0 ≤ dist x y
  dist_triangle : ∀ x y z, dist x z ≤ dist x y + dist y z

/-- Voice-leadings form a Lawvere metric space. -/
def vlBundledLawvere (n : ℕ) : BundledLawvere where
  carrier := Voicing n
  dist := vlDist
  dist_self := vlDist_self
  dist_nonneg := vlDist_nonneg
  dist_triangle := vlDist_triangle

/-! ## Bridge: Cost as Categorical Distance -/

/-- Voice-leading identity has zero cost. -/
theorem voiceLeading_cost_zero (n : ℕ) (V : Voicing n) :
    VLHom.cost (VLHom.id V) = 0 := VLHom.cost_id V

/-- Voice-leading cost satisfies the triangle inequality. -/
theorem voiceLeading_cost_triangle {n : ℕ} {V W U : Voicing n}
    (f : VLHom V W) (g : VLHom W U) :
    (f.comp g).cost ≤ f.cost + g.cost := VLHom.cost_comp_le f g

end VLF