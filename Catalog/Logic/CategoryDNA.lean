import Mathlib.CategoryTheory.Adjunction.Basic
import Mathlib.CategoryTheory.Discrete.Basic

/-!
# Category theory as a precise “genome” metaphor

We test the proposed slogans on a deliberately broad class of theories: a theory is
represented only by its type of models, and its genome is the discrete category on
those models.  This setting is broad enough to prove an exact Morita theorem and to
exhibit an obstruction to the proposed mutation principle.
-/

universe u v

open CategoryTheory

namespace CategoryDNA

/-- A minimal semantic theory, retaining its collection of models. -/
structure Theory where
  Model : Type u

/-- The genome of a theory is its category of models. -/
abbrev Theory.Genome (T : Theory.{u}) := Discrete T.Model

/-- Semantic Morita equivalence at the level of model types. -/
def MoritaEquivalent (T U : Theory.{u}) : Prop := Nonempty (T.Model ≃ U.Model)

/-- Morita equivalence expressed categorically at the level of genomes. -/
def CategoricallyMoritaEquivalent (T U : Theory.{u}) : Prop :=
  Nonempty (T.Genome ≌ U.Genome)

/-
For discrete model semantics, type-level and categorical Morita equivalence agree exactly.
-/
theorem morita_iff_genome_equivalent (T U : Theory.{u}) :
    MoritaEquivalent T U ↔ CategoricallyMoritaEquivalent T U := by
  refine ⟨ ?_, fun ⟨ e ⟩ => ⟨ CategoryTheory.Discrete.equivOfEquivalence e ⟩ ⟩;
  intro h;
  exact ⟨ CategoryTheory.Discrete.equivalence h.some ⟩

/-
Morita equivalences compose, corresponding to composition of genome equivalences.
-/
theorem morita_trans {T U V : Theory.{u}} :
    MoritaEquivalent T U → MoritaEquivalent U V → MoritaEquivalent T V := by
  exact fun h1 h2 => ⟨ h1.some.trans h2.some ⟩

/-- Strengthening a theory by one axiom `P` restricts models to a subtype. -/
def axiomMutation (T : Theory.{u}) (P : T.Model → Prop) : Theory.{u} :=
  ⟨Subtype P⟩

/-- The forgetful functor from models satisfying a new axiom to old models. -/
def mutationForgetful (T : Theory.{u}) (P : T.Model → Prop) :
    (axiomMutation T P).Genome ⥤ T.Genome :=
  Discrete.functor (fun X => Discrete.mk X.val)

/-
A right adjoint to axiom-forgetting forces the new axiom to hold in every old model.
This is the key obstruction to the unrestricted mutation slogan.
-/
theorem mutation_adjunction_forces_axiom (T : Theory.{u}) (P : T.Model → Prop)
    (G : T.Genome ⥤ (axiomMutation T P).Genome)
    (h : mutationForgetful T P ⊣ G) : ∀ x, P x := by
  intro x;
  obtain ⟨y, hy⟩ : ∃ y : (axiomMutation T P).Model, Discrete.mk y.val = (mutationForgetful T P).obj (G.obj (Discrete.mk x)) := by
    exact ⟨ _, rfl ⟩;
  have h_adj : ∃ f : (mutationForgetful T P).obj (G.obj (Discrete.mk x)) ⟶ Discrete.mk x, True := by
    exact ⟨ h.counit.app ( Discrete.mk x ), trivial ⟩;
  obtain ⟨ f, hf ⟩ := h_adj;
  have := CategoryTheory.Discrete.eq_of_hom f;
  grind

/-
Conversely, a redundant axiom does produce an adjunction: the forgetful functor is
part of an equivalence of discrete model categories.
-/
theorem redundant_axiom_has_adjoint (T : Theory.{u}) (P : T.Model → Prop)
    (hP : ∀ x, P x) :
    ∃ G : T.Genome ⥤ (axiomMutation T P).Genome,
      Nonempty (mutationForgetful T P ⊣ G) := by
  refine' ⟨ _, ⟨ _ ⟩ ⟩;
  refine' Discrete.functor _;
  exact fun x => Discrete.mk ⟨ x, hP x ⟩;
  refine' ⟨ _, _, _, _ ⟩;
  refine' { app := fun X => 𝟙 _ };
  refine' { app := fun X => 𝟙 _ }; all_goals aesop

/-
Complete classification: in discrete semantics, adjoining one axiom has the claimed
right adjoint exactly when the axiom was already valid in every model.
-/
theorem mutation_has_right_adjoint_iff (T : Theory.{u}) (P : T.Model → Prop) :
    (∃ G : T.Genome ⥤ (axiomMutation T P).Genome,
      Nonempty (mutationForgetful T P ⊣ G)) ↔ ∀ x, P x := by
  refine ⟨fun ⟨G, ⟨h⟩⟩ x => mutation_adjunction_forces_axiom T P G h x, ?_⟩
  exact fun hP => redundant_axiom_has_adjoint T P hP

/-
Concrete counterexample to “every one-axiom mutation induces an adjunction”.
Starting with one model and adjoining the false axiom leaves no models.
-/
theorem false_axiom_mutation_has_no_right_adjoint :
    ¬ ∃ G : (Theory.Genome ⟨PUnit⟩) ⥤ (axiomMutation ⟨PUnit⟩ (fun _ => False)).Genome,
      Nonempty (mutationForgetful ⟨PUnit⟩ (fun _ => False) ⊣ G) := by
  rintro ⟨ G, ⟨ h ⟩ ⟩;
  convert mutation_adjunction_forces_axiom _ _ G h PUnit.unit

/-
A conservative evolutionary path (an equivalence of genomes) is a single
adjunction step.  Thus the path-decomposition conjecture is valid for equivalences,
but the counterexample above shows it fails for arbitrary axiom changes.
-/
theorem equivalence_is_adjunction_step {T U : Theory.{u}} (e : T.Genome ≌ U.Genome) :
    ∃ G : U.Genome ⥤ T.Genome, Nonempty (e.functor ⊣ G) := by
  exact ⟨ e.inverse, ⟨ e.toAdjunction ⟩ ⟩

end CategoryDNA