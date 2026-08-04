import Mathlib

/-! # Consciousness as Integrated Information

This file develops a finite mathematical model of integrated information.  A
causal structure has finitely many admissible cuts and a nonnegative loss at
each cut.  Its integrated information `Φ` is the least such loss.  Parallel
composition adds losses, while exclusion selects a maximally integrated member
of a finite family.  Pointwise comparison of loss functions supplies a small
category-like refinement calculus.
-/

open Finset

namespace IntegratedInformation

/-- A finite causal structure consists of admissible interventions (`Cut`) and
the nonnegative causal information destroyed by each intervention. -/
structure CausalStructure where
  Cut : Type
  [finiteCut : Fintype Cut]
  [cutNonempty : Nonempty Cut]
  loss : Cut → ℝ
  loss_nonneg : ∀ c, 0 ≤ loss c

attribute [instance] CausalStructure.finiteCut CausalStructure.cutNonempty

/-- Integrated information `Φ` is the minimum information loss among all
admissible causal cuts. -/
noncomputable def Phi (S : CausalStructure) : ℝ :=
  (Finset.univ.image S.loss).min' (Finset.univ_nonempty.image S.loss)

/-- Some admissible cut realizes the integrated information. -/
theorem exists_minimum_information_cut (S : CausalStructure) :
    ∃ c : S.Cut, S.loss c = Phi S := by
  simpa [Phi] using Finset.mem_image.mp
    (Finset.min'_mem (Finset.univ.image S.loss) (Finset.univ_nonempty.image S.loss))

/-- Integrated information is below the loss at every admissible cut. -/
theorem phi_le_loss (S : CausalStructure) (c : S.Cut) : Phi S ≤ S.loss c := by
  exact Finset.min'_le _ _ (Finset.mem_image_of_mem _ (Finset.mem_univ c))

/-- Integrated information is the greatest common lower bound of all cut
losses. -/
theorem le_phi (S : CausalStructure) {a : ℝ}
    (h : ∀ c : S.Cut, a ≤ S.loss c) : a ≤ Phi S := by
  apply Finset.le_min'
  intro x hx
  obtain ⟨c, -, rfl⟩ := Finset.mem_image.mp hx
  exact h c

/-- Integrated information cannot be negative. -/
theorem phi_nonneg (S : CausalStructure) : 0 ≤ Phi S :=
  le_phi S S.loss_nonneg

/-- A causal structure is reducible exactly when one admissible cut destroys no
causal information. -/
theorem phi_eq_zero_iff (S : CausalStructure) :
    Phi S = 0 ↔ ∃ c : S.Cut, S.loss c = 0 := by
  constructor
  · intro h
    obtain ⟨c, hc⟩ := exists_minimum_information_cut S
    exact ⟨c, hc.trans h⟩
  · rintro ⟨c, hc⟩
    exact le_antisymm ((phi_le_loss S c).trans_eq hc) (phi_nonneg S)

/-- Parallel composition: a cut chooses one cut in each component and the two
independent information losses add. -/
def tensor (S T : CausalStructure) : CausalStructure where
  Cut := S.Cut × T.Cut
  loss c := S.loss c.1 + T.loss c.2
  loss_nonneg c := add_nonneg (S.loss_nonneg c.1) (T.loss_nonneg c.2)

/-- **Composition law.** Integrated information is additive under independent
parallel composition. -/
theorem phi_tensor (S T : CausalStructure) :
    Phi (tensor S T) = Phi S + Phi T := by
  apply le_antisymm
  · obtain ⟨s, hs⟩ := exists_minimum_information_cut S
    obtain ⟨t, ht⟩ := exists_minimum_information_cut T
    simpa [tensor, hs, ht] using phi_le_loss (tensor S T) (s, t)
  · apply le_phi
    intro c
    exact add_le_add (phi_le_loss S c.1) (phi_le_loss T c.2)

/-- Pointwise causal refinement: `S ⟶ T` means every cut of `T`, translated to
a cut of `S`, destroys at most as much information in `S`. -/
structure Refinement (S T : CausalStructure) where
  onCut : T.Cut → S.Cut
  loss_le : ∀ c, S.loss (onCut c) ≤ T.loss c

/-- Identity causal refinement. -/
def Refinement.id (S : CausalStructure) : Refinement S S where
  onCut := fun c => c
  loss_le _ := le_rfl

/-- Composition of causal refinements. -/
def Refinement.comp {R S T : CausalStructure}
    (f : Refinement S T) (g : Refinement R S) : Refinement R T where
  onCut c := g.onCut (f.onCut c)
  loss_le c := (g.loss_le (f.onCut c)).trans (f.loss_le c)

/-- Integrated information is monotone under causal refinement. -/
theorem phi_mono_of_refinement {S T : CausalStructure} (f : Refinement S T) :
    Phi S ≤ Phi T := by
  obtain ⟨c, hc⟩ := exists_minimum_information_cut T
  calc
    Phi S ≤ S.loss (f.onCut c) := phi_le_loss S _
    _ ≤ T.loss c := f.loss_le c
    _ = Phi T := hc

/-- Monotonicity is compatible with composition of causal refinements, as
expected for an order-valued invariant on the refinement category. -/
theorem phi_mono_of_composable_refinements {R S T : CausalStructure}
    (f : Refinement S T) (g : Refinement R S) : Phi R ≤ Phi T := by
  exact (phi_mono_of_refinement g).trans (phi_mono_of_refinement f)

/-- A finite family of candidate complexes on one cut space. -/
structure CandidateFamily (ι : Type) [Fintype ι] [Nonempty ι] where
  system : ι → CausalStructure

/-- The exclusion value is the maximum `Φ` among a finite nonempty family of
candidate complexes. -/
noncomputable def BigPhi {ι : Type} [Fintype ι] [Nonempty ι]
    (F : CandidateFamily ι) : ℝ :=
  (Finset.univ.image (fun i => Phi (F.system i))).max'
    (Finset.univ_nonempty.image fun i => Phi (F.system i))

/-- **Exclusion.** A finite candidate family contains a maximally integrated
complex realizing its exclusion value. -/
theorem exists_exclusion_winner {ι : Type} [Fintype ι] [Nonempty ι]
    (F : CandidateFamily ι) : ∃ i : ι, Phi (F.system i) = BigPhi F := by
  simpa [BigPhi] using Finset.mem_image.mp
    (Finset.max'_mem (Finset.univ.image fun i => Phi (F.system i))
      (Finset.univ_nonempty.image fun i => Phi (F.system i)))

/-- Every candidate's integrated information is bounded by the exclusion
value. -/
theorem phi_le_bigPhi {ι : Type} [Fintype ι] [Nonempty ι]
    (F : CandidateFamily ι) (i : ι) : Phi (F.system i) ≤ BigPhi F := by
  exact Finset.le_max'
    (Finset.univ.image (fun j : ι => Phi (F.system j)))
    (Phi (F.system i))
    (Finset.mem_image_of_mem _ (Finset.mem_univ i))

/-- The exclusion value is the least upper bound of the finite landscape of
candidate integrated-information values. -/
theorem bigPhi_le {ι : Type} [Fintype ι] [Nonempty ι]
    (F : CandidateFamily ι) {a : ℝ}
    (h : ∀ i, Phi (F.system i) ≤ a) : BigPhi F ≤ a := by
  apply (Finset.max'_le_iff _ _).2
  intro x hx
  obtain ⟨i, -, rfl⟩ := Finset.mem_image.mp hx
  exact h i

/-- If one candidate strictly exceeds all others, exclusion selects it
uniquely. -/
theorem exclusion_winner_unique {ι : Type} [Fintype ι] [Nonempty ι]
    (F : CandidateFamily ι) (winner : ι)
    (h : ∀ i, i ≠ winner → Phi (F.system i) < Phi (F.system winner)) :
    ∀ i, Phi (F.system i) = BigPhi F → i = winner := by
  intro i hi
  by_contra hne
  have hlt := h i hne
  have hw : BigPhi F ≤ Phi (F.system winner) :=
    bigPhi_le F fun j => by
      by_cases hj : j = winner
      · subst j
        exact le_rfl
      · exact (h j hj).le
  have heq : BigPhi F = Phi (F.system winner) :=
    le_antisymm hw (phi_le_bigPhi F winner)
  linarith

/-- The number of nontrivial cuts of an `n`-element mechanism is at most the
number `2^n` of all subsets. -/
theorem nontrivial_cut_complexity (n : ℕ) :
    (Finset.univ.powerset.filter
      (fun A : Finset (Fin n) => A.Nonempty ∧ A ≠ Finset.univ)).card ≤ 2 ^ n := by
  calc
    _ ≤ Finset.univ.powerset.card := Finset.card_filter_le _ _
    _ = 2 ^ n := by simp

end IntegratedInformation