/-
# Multiverse Truth and Forcing Branches

A set-theoretic multiverse is represented by a class of universes, an internal
satisfaction relation for sentences, and a forcing accessibility relation.
The axioms below isolate four mathematical features: every admitted universe
satisfies the background theory, forcing extensions remain in the multiverse,
forcing is reflexive and transitive, and any two extensions have a common
further extension.  The Continuum Hypothesis is treated as a distinguished
sentence with both a positive and a negative forcing branch above every
universe.

This axiomatic presentation deliberately separates the semantic consequences
of forcing from the construction of particular Boolean-valued models.  It
shows exactly which closure and branching principles imply that ZFC is true
throughout the multiverse while neither CH nor its negation is.
-/
import Mathlib
import Novelty.PosetTheory.MultiverseAsymmetricForcing

namespace MultiverseSetTheory

open Set

/-- Semantic data for a collection of universes and its forcing extensions. -/
structure Frame (Sentence : Type*) where
  Universe : Type*
  member : Set Universe
  satisfies : Universe → Sentence → Prop
  background : Set Sentence
  CH : Sentence
  forces : Universe → Universe → Prop
  background_sound : ∀ {u}, member u → ∀ {φ}, φ ∈ background → satisfies u φ
  forcing_closed : ∀ {u v}, member u → forces u v → member v
  forces_refl : Reflexive forces
  forces_trans : Transitive forces
  forces_confluent : MultiverseAsymmetricForcing.Confluent forces
  ch_forceable : ∀ {u}, member u → ∃ v, forces u v ∧ satisfies v CH
  not_ch_forceable : ∀ {u}, member u → ∃ v, forces u v ∧ ¬ satisfies v CH

variable {Sentence : Type*} (M : Frame Sentence)

/-- A sentence is multiverse-true when it holds in every admitted universe. -/
def MultiverseTrue (φ : Sentence) : Prop := ∀ u, M.member u → M.satisfies u φ

/-- A sentence is multiverse-false when it fails in every admitted universe. -/
def MultiverseFalse (φ : Sentence) : Prop :=
  ∀ u, M.member u → ¬ M.satisfies u φ

/-- A sentence is multiverse-independent when it is true in one admitted
universe and false in another. -/
def MultiverseIndependent (φ : Sentence) : Prop :=
  (∃ u, M.member u ∧ M.satisfies u φ) ∧
  (∃ v, M.member v ∧ ¬ M.satisfies v φ)

/-- Multiverse independence rules out both uniform truth values. -/
theorem independent_not_true_or_false {φ : Sentence}
    (h : MultiverseIndependent M φ) :
    ¬ MultiverseTrue M φ ∧ ¬ MultiverseFalse M φ := by
  rcases h with ⟨⟨u, hu, hφu⟩, ⟨v, hv, hφv⟩⟩
  constructor
  · intro hall
    exact hφv (hall v hv)
  · intro hall
    exact hall u hu hφu

/-- Semantic independence is equivalent to the failure of both uniform truth
values.  On the empty frame both universal predicates hold, so the equivalence
also correctly rules out independence there. -/
theorem independent_iff_not_true_and_not_false {φ : Sentence} :
    MultiverseIndependent M φ ↔
      ¬ MultiverseTrue M φ ∧ ¬ MultiverseFalse M φ := by
  constructor
  · exact independent_not_true_or_false M
  · rintro ⟨hnotTrue, hnotFalse⟩
    constructor
    · by_contra hnoWitness
      push_neg at hnoWitness
      apply hnotFalse
      intro u hu hsat
      exact hnoWitness u hu hsat
    · by_contra hnoWitness
      push_neg at hnoWitness
      apply hnotTrue
      intro u hu
      exact hnoWitness u hu

/-- Consequently, having no uniform Boolean verdict is precisely semantic
multiverse independence. -/
theorem independent_iff_no_uniform_verdict {φ : Sentence} :
    MultiverseIndependent M φ ↔
      ¬ (MultiverseTrue M φ ∨ MultiverseFalse M φ) := by
  rw [independent_iff_not_true_and_not_false M]
  tauto

/-- Every sentence has one of three semantic statuses: uniformly true,
uniformly false, or multiverse-independent. -/
theorem multiverse_semantic_trichotomy (φ : Sentence) :
    MultiverseTrue M φ ∨ MultiverseFalse M φ ∨ MultiverseIndependent M φ := by
  by_cases htrue : MultiverseTrue M φ
  · exact Or.inl htrue
  · by_cases hfalse : MultiverseFalse M φ
    · exact Or.inr (Or.inl hfalse)
    · exact Or.inr (Or.inr
        ((independent_iff_not_true_and_not_false M).2 ⟨htrue, hfalse⟩))

/-- On an inhabited multiverse, uniform truth and uniform falsity are mutually
exclusive.  The inhabitance hypothesis is necessary only to rule out the empty
frame, where both universal assertions hold vacuously. -/
theorem true_and_false_disjoint (hex : ∃ u, M.member u) {φ : Sentence} :
    ¬ (MultiverseTrue M φ ∧ MultiverseFalse M φ) := by
  rintro ⟨htrue, hfalse⟩
  rcases hex with ⟨u, hu⟩
  exact hfalse u hu (htrue u hu)

/-- Semantic independence is disjoint from either uniform truth value. -/
theorem independent_disjoint_from_uniform {φ : Sentence} :
    ¬ (MultiverseIndependent M φ ∧
      (MultiverseTrue M φ ∨ MultiverseFalse M φ)) := by
  rintro ⟨hind, htrue | hfalse⟩
  · exact (independent_not_true_or_false M hind).1 htrue
  · exact (independent_not_true_or_false M hind).2 hfalse

/-- In every inhabited multiverse, the three semantic statuses form an
exhaustive and pairwise-disjoint classification. -/
theorem multiverse_semantic_classification (hex : ∃ u, M.member u)
    (φ : Sentence) :
    (MultiverseTrue M φ ∨ MultiverseFalse M φ ∨ MultiverseIndependent M φ) ∧
    ¬ (MultiverseTrue M φ ∧ MultiverseFalse M φ) ∧
    ¬ (MultiverseIndependent M φ ∧
      (MultiverseTrue M φ ∨ MultiverseFalse M φ)) := by
  exact ⟨multiverse_semantic_trichotomy M φ,
    true_and_false_disjoint M hex,
    independent_disjoint_from_uniform M⟩

/-- A sentence is forceably true over a universe. -/
def Forceable (u : M.Universe) (φ : Sentence) : Prop :=
  MultiverseAsymmetricForcing.Dia M.forces (fun v => M.satisfies v φ) u

/-- A sentence is forcing-necessary over a universe. -/
def Necessary (u : M.Universe) (φ : Sentence) : Prop :=
  MultiverseAsymmetricForcing.Box M.forces (fun v => M.satisfies v φ) u

/-- Forcing contingency means the existence of both a positive and a negative
branch above the same universe. -/
def BranchesBothWays (u : M.Universe) (φ : Sentence) : Prop :=
  (∃ v, M.forces u v ∧ M.satisfies v φ) ∧
  (∃ v, M.forces u v ∧ ¬ M.satisfies v φ)

/-- Semantic consequence relative to the admitted universes: every admitted
universe satisfying all premises in `Γ` also satisfies the conclusion. -/
def SemanticConsequence (Γ : Set Sentence) (φ : Sentence) : Prop :=
  ∀ u, M.member u → (∀ ψ ∈ Γ, M.satisfies u ψ) → M.satisfies u φ

/-- A theory is realizable in the multiverse when some admitted universe
satisfies all of its sentences. -/
def TheoryRealizable (Γ : Set Sentence) : Prop :=
  ∃ u, M.member u ∧ ∀ φ ∈ Γ, M.satisfies u φ

/-- A positive model of `φ` over `Γ` is an admitted universe satisfying every
premise in `Γ` together with `φ`. -/
def HasPositiveModel (Γ : Set Sentence) (φ : Sentence) : Prop :=
  ∃ u, M.member u ∧ (∀ ψ ∈ Γ, M.satisfies u ψ) ∧ M.satisfies u φ

/-- A countermodel to `φ` over `Γ` is an admitted universe satisfying every
premise in `Γ` while refuting `φ`. -/
def HasCountermodel (Γ : Set Sentence) (φ : Sentence) : Prop :=
  ∃ u, M.member u ∧ (∀ ψ ∈ Γ, M.satisfies u ψ) ∧ ¬ M.satisfies u φ

/-- A positive model is locally forceable above `u` when it is witnessed by an
accessible admitted universe. -/
def HasLocalPositiveModel (u : M.Universe) (Γ : Set Sentence)
    (φ : Sentence) : Prop :=
  ∃ v, M.forces u v ∧ M.member v ∧
    (∀ ψ ∈ Γ, M.satisfies v ψ) ∧ M.satisfies v φ

/-- A countermodel is locally forceable above `u` when it is witnessed by an
accessible admitted universe. -/
def HasLocalCountermodel (u : M.Universe) (Γ : Set Sentence)
    (φ : Sentence) : Prop :=
  ∃ v, M.forces u v ∧ M.member v ∧
    (∀ ψ ∈ Γ, M.satisfies v ψ) ∧ ¬ M.satisfies v φ

/-- Local semantic undecidability means that both a positive model and a
countermodel are forceable above the same universe. -/
def LocallySemanticallyUndecided (u : M.Universe) (Γ : Set Sentence)
    (φ : Sentence) : Prop :=
  HasLocalPositiveModel M u Γ φ ∧ HasLocalCountermodel M u Γ φ

/-- Local positive models are global positive models after forgetting their
accessibility from the chosen ground. -/
theorem localPositiveModel_to_positiveModel {u : M.Universe}
    {Γ : Set Sentence} {φ : Sentence}
    (h : HasLocalPositiveModel M u Γ φ) : HasPositiveModel M Γ φ := by
  rcases h with ⟨v, huv, hv, hΓ, hφ⟩
  exact ⟨v, hv, hΓ, hφ⟩

/-- Local countermodels are global countermodels after forgetting their
accessibility from the chosen ground. -/
theorem localCountermodel_to_countermodel {u : M.Universe}
    {Γ : Set Sentence} {φ : Sentence}
    (h : HasLocalCountermodel M u Γ φ) : HasCountermodel M Γ φ := by
  rcases h with ⟨v, huv, hv, hΓ, hφ⟩
  exact ⟨v, hv, hΓ, hφ⟩

/-- A sentence is semantically undecided over a theory when the multiverse
contains both a positive model and a countermodel extending that theory. -/
def SemanticallyUndecided (Γ : Set Sentence) (φ : Sentence) : Prop :=
  HasPositiveModel M Γ φ ∧ HasCountermodel M Γ φ

/-- Local semantic undecidability implies global semantic undecidability. -/
theorem locallyUndecided_to_semanticallyUndecided {u : M.Universe}
    {Γ : Set Sentence} {φ : Sentence}
    (h : LocallySemanticallyUndecided M u Γ φ) :
    SemanticallyUndecided M Γ φ := by
  exact ⟨localPositiveModel_to_positiveModel M h.1,
    localCountermodel_to_countermodel M h.2⟩

/-- Semantic undecidability directly refutes semantic consequence. -/
theorem semanticallyUndecided_not_consequence {Γ : Set Sentence}
    {φ : Sentence} (h : SemanticallyUndecided M Γ φ) :
    ¬ SemanticConsequence M Γ φ := by
  intro hconsequence
  rcases h.2 with ⟨u, hu, hΓ, hφ⟩
  exact hφ (hconsequence u hu hΓ)

/-- Semantic consequence is equivalent to the absence of an admitted
countermodel. -/
theorem semanticConsequence_iff_no_countermodel {Γ : Set Sentence}
    {φ : Sentence} :
    SemanticConsequence M Γ φ ↔ ¬ HasCountermodel M Γ φ := by
  constructor
  · intro hconsequence
    rintro ⟨u, hu, hΓ, hφ⟩
    exact hφ (hconsequence u hu hΓ)
  · intro hno u hu hΓ
    by_contra hφ
    exact hno ⟨u, hu, hΓ, hφ⟩

/-- Every premise is a semantic consequence of the theory containing it. -/
theorem semanticConsequence_of_mem {Γ : Set Sentence} {φ : Sentence}
    (hφ : φ ∈ Γ) : SemanticConsequence M Γ φ := by
  intro u hu hΓ
  exact hΓ φ hφ

/-- The semantic closure of a theory consists of all of its consequences in the
admitted multiverse. -/
def SemanticClosure (Γ : Set Sentence) : Set Sentence :=
  {φ | SemanticConsequence M Γ φ}

/-- A theory is contained in its semantic closure. -/
theorem subset_semanticClosure (Γ : Set Sentence) :
    Γ ⊆ SemanticClosure M Γ := by
  intro φ hφ
  exact semanticConsequence_of_mem M hφ

/-- Multiverse truth is closed under semantic consequence. -/
theorem multiverseTrue_of_semanticConsequence {Γ : Set Sentence}
    {φ : Sentence} (hΓ : ∀ ψ ∈ Γ, MultiverseTrue M ψ)
    (hconsequence : SemanticConsequence M Γ φ) :
    MultiverseTrue M φ := by
  intro u hu
  apply hconsequence u hu
  intro ψ hψ
  exact hΓ ψ hψ u hu

/-- Any semantic consequence of the background theory is multiverse-true.  Thus
when the background presents ZFC, not only its axioms but all of its semantic
consequences hold throughout the multiverse. -/
theorem background_consequence_is_multiverse_true {φ : Sentence}
    (hconsequence : SemanticConsequence M M.background φ) :
    MultiverseTrue M φ := by
  apply multiverseTrue_of_semanticConsequence M
  · intro ψ hψ u hu
    exact M.background_sound hu hψ
  · exact hconsequence

/-- Semantic consequence is monotone in its premises: a consequence of a
smaller theory remains a consequence after adding premises. -/
theorem semanticConsequence_mono {Γ Δ : Set Sentence} {φ : Sentence}
    (hsub : Γ ⊆ Δ) (h : SemanticConsequence M Γ φ) :
    SemanticConsequence M Δ φ := by
  intro u hu hΔ
  exact h u hu (fun ψ hψ => hΔ ψ (hsub hψ))

/-- Semantic consequence is transitive through an intermediate theory. -/
theorem semanticConsequence_cut {Γ Δ : Set Sentence} {φ : Sentence}
    (hΔ : ∀ ψ ∈ Δ, SemanticConsequence M Γ ψ)
    (hφ : SemanticConsequence M Δ φ) :
    SemanticConsequence M Γ φ := by
  intro u hu hΓ
  apply hφ u hu
  intro ψ hψ
  exact hΔ ψ hψ u hu hΓ

/-- Semantic closure is monotone with respect to inclusion of theories. -/
theorem semanticClosure_mono {Γ Δ : Set Sentence} (hsub : Γ ⊆ Δ) :
    SemanticClosure M Γ ⊆ SemanticClosure M Δ := by
  intro φ hφ
  exact semanticConsequence_mono M hsub hφ

/-- Taking semantic closure twice adds no new consequences. -/
theorem semanticClosure_idempotent (Γ : Set Sentence) :
    SemanticClosure M (SemanticClosure M Γ) = SemanticClosure M Γ := by
  apply Set.Subset.antisymm
  · intro φ hφ
    exact semanticConsequence_cut M (fun ψ hψ => hψ) hφ
  · exact subset_semanticClosure M (SemanticClosure M Γ)

/-- The semantic closure operator is extensive, monotone, and idempotent. -/
theorem semanticClosure_isClosureOperator :
    (∀ Γ : Set Sentence, Γ ⊆ SemanticClosure M Γ) ∧
    (∀ ⦃Γ Δ : Set Sentence⦄, Γ ⊆ Δ →
      SemanticClosure M Γ ⊆ SemanticClosure M Δ) ∧
    (∀ Γ : Set Sentence,
      SemanticClosure M (SemanticClosure M Γ) = SemanticClosure M Γ) := by
  refine ⟨subset_semanticClosure M, ?_, semanticClosure_idempotent M⟩
  intro Γ Δ hsub
  exact semanticClosure_mono M hsub

/-- Every semantic consequence of the background theory lies in the
multiverse-true fragment. -/
theorem background_semanticClosure_multiverseTrue :
    ∀ φ ∈ SemanticClosure M M.background, MultiverseTrue M φ := by
  intro φ hφ
  exact background_consequence_is_multiverse_true M hφ

/-- No semantic consequence of the background theory can be
multiverse-independent. -/
theorem background_semanticClosure_not_independent {φ : Sentence}
    (hφ : φ ∈ SemanticClosure M M.background) :
    ¬ MultiverseIndependent M φ := by
  intro hind
  exact (independent_not_true_or_false M hind).1
    (background_semanticClosure_multiverseTrue M φ hφ)

/-- In an inhabited multiverse, every semantic consequence of the background
has the unique uniformly true status. -/
theorem background_semanticClosure_unique_status (hex : ∃ u, M.member u)
    {φ : Sentence} (hφ : φ ∈ SemanticClosure M M.background) :
    MultiverseTrue M φ ∧
    ¬ MultiverseFalse M φ ∧
    ¬ MultiverseIndependent M φ := by
  have htrue := background_semanticClosure_multiverseTrue M φ hφ
  refine ⟨htrue, ?_, background_semanticClosure_not_independent M hφ⟩
  intro hfalse
  exact true_and_false_disjoint M hex ⟨htrue, hfalse⟩

/-- Every axiom of the background theory is true in every universe. -/
theorem background_is_multiverse_true {φ : Sentence} (hφ : φ ∈ M.background) :
    MultiverseTrue M φ := by
  intro u hu
  exact M.background_sound hu hφ

/-- The entire background theory, read axiom by axiom, is multiverse-true.  When
`background` presents ZFC, this is the precise assertion that ZFC is
multiverse-true. -/
theorem background_theory_is_multiverse_true :
    ∀ φ ∈ M.background, MultiverseTrue M φ := by
  intro φ hφ
  exact background_is_multiverse_true M hφ

/-- In an inhabited multiverse, a background axiom is neither uniformly false
nor multiverse-independent. -/
theorem background_has_unique_true_status (hex : ∃ u, M.member u)
    {φ : Sentence} (hφ : φ ∈ M.background) :
    MultiverseTrue M φ ∧
    ¬ MultiverseFalse M φ ∧
    ¬ MultiverseIndependent M φ := by
  have htrue : MultiverseTrue M φ := background_is_multiverse_true M hφ
  constructor
  · exact htrue
  constructor
  · intro hfalse
    exact true_and_false_disjoint M hex ⟨htrue, hfalse⟩
  · intro hind
    exact (independent_not_true_or_false M hind).1 htrue

/-- Every axiom of an inhabited background theory occupies exactly the uniform
truth branch of the semantic classification. -/
theorem background_theory_has_unique_true_status (hex : ∃ u, M.member u) :
    ∀ φ ∈ M.background,
      MultiverseTrue M φ ∧
      ¬ MultiverseFalse M φ ∧
      ¬ MultiverseIndependent M φ := by
  intro φ hφ
  exact background_has_unique_true_status M hex hφ

/-- Forcing closure transports every accessible extension back into the
multiverse. -/
theorem forceable_witness_is_member {u : M.Universe} (hu : M.member u)
    {φ : Sentence} (h : Forceable M u φ) :
    ∃ v, M.member v ∧ M.satisfies v φ := by
  rcases h with ⟨v, huv, hv⟩
  exact ⟨v, M.forcing_closed hu huv, hv⟩

/-- CH has positive and negative forcing branches above every admitted
universe. -/
theorem ch_branches_both_ways {u : M.Universe} (hu : M.member u) :
    BranchesBothWays M u M.CH := by
  constructor
  · rcases M.ch_forceable hu with ⟨v, huv, hv⟩
    exact ⟨v, huv, hv⟩
  · rcases M.not_ch_forceable hu with ⟨v, huv, hv⟩
    exact ⟨v, huv, hv⟩

/-- CH remains two-way forceable after every forcing extension.  Thus its
contingency is not merely local at a chosen ground: it is forcing-necessary. -/
theorem ch_necessarily_branches_both_ways {u : M.Universe} (hu : M.member u) :
    MultiverseAsymmetricForcing.Box M.forces
      (fun v => BranchesBothWays M v M.CH) u := by
  intro v huv
  exact ch_branches_both_ways M (M.forcing_closed hu huv)

/-- In every inhabited frame, CH is multiverse-independent: forcing closure
turns the positive and negative branches into admitted witnesses. -/
theorem ch_multiverseIndependent (hex : ∃ u, M.member u) :
    MultiverseIndependent M M.CH := by
  rcases hex with ⟨u, hu⟩
  rcases M.ch_forceable hu with ⟨v, huv, hv⟩
  rcases M.not_ch_forceable hu with ⟨w, huw, hw⟩
  exact ⟨⟨v, M.forcing_closed hu huv, hv⟩,
    ⟨w, M.forcing_closed hu huw, hw⟩⟩

/-- Every admitted universe realizes the background theory, so an inhabited
multiverse makes the background semantically realizable. -/
theorem background_theory_realizable (hex : ∃ u, M.member u) :
    TheoryRealizable M M.background := by
  rcases hex with ⟨u, hu⟩
  exact ⟨u, hu, fun φ hφ => M.background_sound hu hφ⟩

/-- Above every admitted universe, forcing supplies both a background model of
CH and a background countermodel to CH. -/
theorem ch_locallySemanticallyUndecided_over_background
    {u : M.Universe} (hu : M.member u) :
    LocallySemanticallyUndecided M u M.background M.CH := by
  constructor
  · rcases M.ch_forceable hu with ⟨v, huv, hv⟩
    have hvmem := M.forcing_closed hu huv
    exact ⟨v, huv, hvmem, fun φ hφ => M.background_sound hvmem hφ, hv⟩
  · rcases M.not_ch_forceable hu with ⟨v, huv, hv⟩
    have hvmem := M.forcing_closed hu huv
    exact ⟨v, huv, hvmem, fun φ hφ => M.background_sound hvmem hφ, hv⟩

/-- Local semantic undecidability of CH is itself forcing-necessary: after every
forcing extension there are still accessible background models on both sides
of CH. -/
theorem ch_local_undecidability_is_necessary {u : M.Universe}
    (hu : M.member u) :
    MultiverseAsymmetricForcing.Box M.forces
      (fun v => LocallySemanticallyUndecided M v M.background M.CH) u := by
  intro v huv
  exact ch_locallySemanticallyUndecided_over_background M
    (M.forcing_closed hu huv)

/-- Every forcing extension contains a local countermodel to deriving CH from
the background theory. -/
theorem ch_countermodel_is_necessarily_forceable {u : M.Universe}
    (hu : M.member u) :
    MultiverseAsymmetricForcing.Box M.forces
      (fun v => HasLocalCountermodel M v M.background M.CH) u := by
  intro v huv
  exact (ch_locallySemanticallyUndecided_over_background M
    (M.forcing_closed hu huv)).2

/-- Every forcing extension also contains a local positive model of CH over the
background theory. -/
theorem ch_positive_model_is_necessarily_forceable {u : M.Universe}
    (hu : M.member u) :
    MultiverseAsymmetricForcing.Box M.forces
      (fun v => HasLocalPositiveModel M v M.background M.CH) u := by
  intro v huv
  exact (ch_locallySemanticallyUndecided_over_background M
    (M.forcing_closed hu huv)).1

/-- A positive CH branch is an explicit model of the background theory together
with CH. -/
theorem background_has_ch_positive_model (hex : ∃ u, M.member u) :
    HasPositiveModel M M.background M.CH := by
  rcases hex with ⟨u, hu⟩
  rcases M.ch_forceable hu with ⟨v, huv, hv⟩
  have hvmem := M.forcing_closed hu huv
  exact ⟨v, hvmem, fun φ hφ => M.background_sound hvmem hφ, hv⟩

/-- A negative CH branch is an explicit countermodel to deriving CH from the
background theory. -/
theorem background_has_ch_countermodel (hex : ∃ u, M.member u) :
    HasCountermodel M M.background M.CH := by
  rcases hex with ⟨u, hu⟩
  rcases M.not_ch_forceable hu with ⟨v, huv, hv⟩
  have hvmem := M.forcing_closed hu huv
  exact ⟨v, hvmem, fun φ hφ => M.background_sound hvmem hφ, hv⟩

/-- CH is semantically undecided over the background theory: there is both a
background model satisfying CH and a background model refuting it. -/
theorem ch_semanticallyUndecided_over_background (hex : ∃ u, M.member u) :
    SemanticallyUndecided M M.background M.CH := by
  exact ⟨background_has_ch_positive_model M hex,
    background_has_ch_countermodel M hex⟩

/-- CH cannot be a semantic consequence of the background theory in any
inhabited frame with opposite CH branches.  This is the internal semantic form
of independence from the background theory. -/
theorem ch_not_in_background_semanticClosure (hex : ∃ u, M.member u) :
    M.CH ∉ SemanticClosure M M.background := by
  intro hconsequence
  exact (semanticConsequence_iff_no_countermodel M).1 hconsequence
    (background_has_ch_countermodel M hex)

/-- In an inhabited multiverse, CH occupies exactly the independent branch of
the semantic classification. -/
theorem ch_has_unique_independent_status (hex : ∃ u, M.member u) :
    MultiverseIndependent M M.CH ∧
    ¬ MultiverseTrue M M.CH ∧
    ¬ MultiverseFalse M M.CH := by
  have hind : MultiverseIndependent M M.CH := ch_multiverseIndependent M hex
  rcases independent_not_true_or_false M hind with ⟨htrue, hfalse⟩
  exact ⟨hind, htrue, hfalse⟩

/-- Provided the multiverse is inhabited, CH is not multiverse-true. -/
theorem ch_not_multiverse_true (hex : ∃ u, M.member u) :
    ¬ MultiverseTrue M M.CH := by
  rintro hall
  rcases hex with ⟨u, hu⟩
  rcases M.not_ch_forceable hu with ⟨v, huv, hv⟩
  exact hv (hall v (M.forcing_closed hu huv))

/-- Provided the multiverse is inhabited, the negation of CH is not
multiverse-true either. -/
theorem not_ch_not_multiverse_true (hex : ∃ u, M.member u) :
    ¬ (∀ v, M.member v → ¬ M.satisfies v M.CH) := by
  rintro hall
  rcases hex with ⟨u, hu⟩
  rcases M.ch_forceable hu with ⟨v, huv, hv⟩
  exact hall v (M.forcing_closed hu huv) hv

/-- There is no universe-independent Boolean verdict on CH: neither uniform
truth value agrees with all admitted universes. -/
theorem no_uniform_ch_verdict (hex : ∃ u, M.member u) :
    ¬ (MultiverseTrue M M.CH ∨ MultiverseFalse M M.CH) := by
  rcases independent_not_true_or_false M (ch_multiverseIndependent M hex) with
    ⟨htrue, hfalse⟩
  rintro (hall | hall)
  · exact htrue hall
  · exact hfalse hall

/-- **Main multiverse theorem.** In every inhabited frame satisfying the stated
forcing laws, the background theory is true in all admitted universes, CH is
neither uniformly true nor uniformly false, and every universe has accessible
positive and negative CH branches that remain inside the multiverse. -/
theorem multiverse_truth_and_ch_independence (hex : ∃ u, M.member u) :
    (∀ φ ∈ M.background, MultiverseTrue M φ) ∧
    ¬ MultiverseTrue M M.CH ∧
    ¬ (∀ v, M.member v → ¬ M.satisfies v M.CH) ∧
    ∀ u, M.member u →
      (∃ v, M.member v ∧ M.forces u v ∧ M.satisfies v M.CH) ∧
      (∃ v, M.member v ∧ M.forces u v ∧ ¬ M.satisfies v M.CH) := by
  refine ⟨background_theory_is_multiverse_true M,
    ch_not_multiverse_true M hex, not_ch_not_multiverse_true M hex, ?_⟩
  intro u hu
  rcases ch_branches_both_ways M hu with ⟨⟨v, huv, hv⟩, ⟨w, huw, hw⟩⟩
  exact ⟨⟨v, M.forcing_closed hu huv, huv, hv⟩,
    ⟨w, M.forcing_closed hu huw, huw, hw⟩⟩

/-- Directedness of forcing yields the characteristic modal principle `.2`:
if a sentence can become necessary, then it is necessarily forceable. -/
theorem forcing_dot_two {u : M.Universe} {φ : Sentence}
    (h : MultiverseAsymmetricForcing.Dia M.forces
      (fun v => Necessary M v φ) u) :
    MultiverseAsymmetricForcing.Box M.forces
      (fun v => Forceable M v φ) u := by
  exact MultiverseAsymmetricForcing.box_dot2 M.forces_confluent h

/-- A forcing-necessary background axiom remains true throughout every further
extension of an admitted universe. -/
theorem background_necessary {u : M.Universe} (hu : M.member u)
    {φ : Sentence} (hφ : φ ∈ M.background) : Necessary M u φ := by
  intro v huv
  exact M.background_sound (M.forcing_closed hu huv) hφ

/-- Background axioms satisfy the stronger modal conclusion `□◇φ`: after every
forcing extension there remains a further extension satisfying the axiom. -/
theorem background_necessarily_forceable {u : M.Universe} (hu : M.member u)
    {φ : Sentence} (hφ : φ ∈ M.background) :
    MultiverseAsymmetricForcing.Box M.forces (fun v => Forceable M v φ) u := by
  intro v huv
  refine ⟨v, M.forces_refl v, ?_⟩
  exact M.background_sound (M.forcing_closed hu huv) hφ

/-! ## The internal frame of admitted universes

Restricting forcing to universes actually belonging to the multiverse turns the
semantic closure field into a genuine Kripke frame on a single type.  This
construction demonstrates that no inaccessible forcing witnesses are hidden in
the modal conclusions above. -/

/-- The type of universes admitted by the multiverse. -/
def Admitted := {u : M.Universe // M.member u}

/-- Forcing accessibility restricted to admitted universes. -/
def AdmittedForces (u v : Admitted M) : Prop := M.forces u.1 v.1

/-- Restricted forcing is reflexive. -/
theorem admittedForces_refl : Reflexive (AdmittedForces M) := by
  intro u
  exact M.forces_refl u.1

/-- Restricted forcing is transitive. -/
theorem admittedForces_trans : Transitive (AdmittedForces M) := by
  intro u v w huv hvw
  exact M.forces_trans huv hvw

/-- Restricted forcing remains confluent: forcing closure supplies membership
of the common extension produced by confluence in the ambient frame. -/
theorem admittedForces_confluent :
    MultiverseAsymmetricForcing.Confluent (AdmittedForces M) := by
  intro x y z hxy hxz
  rcases M.forces_confluent x.1 y.1 z.1 hxy hxz with ⟨u, hyu, hzu⟩
  have hu : M.member u := M.forcing_closed y.2 hyu
  exact ⟨⟨u, hu⟩, hyu, hzu⟩

/-- Every admitted universe has admitted positive and negative CH extensions. -/
theorem admitted_ch_branches (u : Admitted M) :
    (∃ v : Admitted M, AdmittedForces M u v ∧ M.satisfies v.1 M.CH) ∧
    (∃ v : Admitted M, AdmittedForces M u v ∧ ¬ M.satisfies v.1 M.CH) := by
  rcases M.ch_forceable u.2 with ⟨v, huv, hv⟩
  rcases M.not_ch_forceable u.2 with ⟨w, huw, hw⟩
  exact ⟨⟨⟨v, M.forcing_closed u.2 huv⟩, huv, hv⟩,
    ⟨⟨w, M.forcing_closed u.2 huw⟩, huw, hw⟩⟩

/-- A predicate is a forcing switch when either truth value can be reached from
every admitted universe. -/
def ForcingSwitch (P : Admitted M → Prop) : Prop :=
  ∀ u,
    MultiverseAsymmetricForcing.Dia (AdmittedForces M) P u ∧
    MultiverseAsymmetricForcing.Dia (AdmittedForces M) (fun v => ¬ P v) u

/-- The internal switch definition is equivalent to two-way branching in the
ambient universe type.  Forcing closure is exactly what transports ambient
branch witnesses into the admitted-universe subtype. -/
theorem forcingSwitch_iff_branchesBothWays {φ : Sentence} :
    ForcingSwitch M (fun v => M.satisfies v.1 φ) ↔
      ∀ u : Admitted M, BranchesBothWays M u.1 φ := by
  constructor
  · intro hswitch u
    rcases hswitch u with ⟨⟨v, huv, hv⟩, ⟨w, huw, hw⟩⟩
    exact ⟨⟨v.1, huv, hv⟩, ⟨w.1, huw, hw⟩⟩
  · intro hbranches u
    rcases hbranches u with ⟨⟨v, huv, hv⟩, ⟨w, huw, hw⟩⟩
    exact ⟨⟨⟨v, M.forcing_closed u.2 huv⟩, huv, hv⟩,
      ⟨⟨w, M.forcing_closed u.2 huw⟩, huw, hw⟩⟩

/-- A sentence is a forcing switch exactly when it has positive and negative
forcing branches above every admitted universe. -/
theorem forcingSwitch_iff_forceable_both_ways {φ : Sentence} :
    ForcingSwitch M (fun v => M.satisfies v.1 φ) ↔
      ∀ u : Admitted M,
        Forceable M u.1 φ ∧
        MultiverseAsymmetricForcing.Dia M.forces
          (fun v => ¬ M.satisfies v φ) u.1 := by
  rw [forcingSwitch_iff_branchesBothWays M]
  rfl

/-- Every forcing switch remains a switch throughout all further extensions. -/
theorem forcingSwitch_necessary {P : Admitted M → Prop}
    (hswitch : ForcingSwitch M P) (u : Admitted M) :
    MultiverseAsymmetricForcing.Box (AdmittedForces M)
      (fun v =>
        MultiverseAsymmetricForcing.Dia (AdmittedForces M) P v ∧
        MultiverseAsymmetricForcing.Dia (AdmittedForces M) (fun w => ¬ P w) v) u := by
  intro v _
  exact hswitch v

/-- A forcing switch cannot be necessary with either truth value at any world. -/
theorem forcingSwitch_no_necessary_verdict {P : Admitted M → Prop}
    (hswitch : ForcingSwitch M P) (u : Admitted M) :
    ¬ MultiverseAsymmetricForcing.Box (AdmittedForces M) P u ∧
    ¬ MultiverseAsymmetricForcing.Box (AdmittedForces M) (fun v => ¬ P v) u := by
  constructor
  · intro hbox
    rcases (hswitch u).2 with ⟨v, huv, hv⟩
    exact hv (hbox v huv)
  · intro hbox
    rcases (hswitch u).1 with ⟨v, huv, hv⟩
    exact hbox v huv hv

/-- No forcing extension can make the positive value of a switch necessary. -/
theorem forcingSwitch_not_forceably_necessary {P : Admitted M → Prop}
    (hswitch : ForcingSwitch M P) (u : Admitted M) :
    ¬ MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (fun v => MultiverseAsymmetricForcing.Box (AdmittedForces M) P v) u := by
  rintro ⟨v, huv, hv⟩
  exact (forcingSwitch_no_necessary_verdict M hswitch v).1 hv

/-- No forcing extension can make the negative value of a switch necessary. -/
theorem forcingSwitch_neg_not_forceably_necessary {P : Admitted M → Prop}
    (hswitch : ForcingSwitch M P) (u : Admitted M) :
    ¬ MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (fun v => MultiverseAsymmetricForcing.Box (AdmittedForces M)
        (fun w => ¬ P w) v) u := by
  rintro ⟨v, huv, hv⟩
  exact (forcingSwitch_no_necessary_verdict M hswitch v).2 hv

/-- Neither value of a switch can become necessary after forcing. -/
theorem forcingSwitch_no_forceably_necessary_value {P : Admitted M → Prop}
    (hswitch : ForcingSwitch M P) (u : Admitted M) :
    (¬ MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (fun v => MultiverseAsymmetricForcing.Box (AdmittedForces M) P v) u) ∧
    (¬ MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (fun v => MultiverseAsymmetricForcing.Box (AdmittedForces M)
        (fun w => ¬ P w) v) u) := by
  exact ⟨forcingSwitch_not_forceably_necessary M hswitch u,
    forcingSwitch_neg_not_forceably_necessary M hswitch u⟩

/-- A sentence whose satisfaction predicate is a forcing switch is
multiverse-independent whenever an admitted starting universe is supplied.
Forcing closure is built into the subtype of admitted universes. -/
theorem forcingSwitch_implies_independent {φ : Sentence}
    (hswitch : ForcingSwitch M (fun v => M.satisfies v.1 φ))
    (u : Admitted M) : MultiverseIndependent M φ := by
  rcases (hswitch u).1 with ⟨v, huv, hv⟩
  rcases (hswitch u).2 with ⟨w, huw, hw⟩
  exact ⟨⟨v.1, v.2, hv⟩, ⟨w.1, w.2, hw⟩⟩

/-- A forcing-switch sentence can have neither uniform multiverse truth value. -/
theorem forcingSwitch_no_uniform_multiverse_verdict {φ : Sentence}
    (hswitch : ForcingSwitch M (fun v => M.satisfies v.1 φ))
    (u : Admitted M) :
    ¬ (MultiverseTrue M φ ∨ MultiverseFalse M φ) := by
  exact (independent_iff_no_uniform_verdict M).1
    (forcingSwitch_implies_independent M hswitch u)

/-- Conversely, a multiverse-true sentence cannot be a forcing switch in an
inhabited internal frame. -/
theorem multiverseTrue_not_forcingSwitch {φ : Sentence}
    (hall : MultiverseTrue M φ) (u : Admitted M) :
    ¬ ForcingSwitch M (fun v => M.satisfies v.1 φ) := by
  intro hswitch
  exact (forcingSwitch_no_uniform_multiverse_verdict M hswitch u)
    (Or.inl hall)

/-! ## Invariant fragments on connected multiverses -/

/-- The admitted frame is globally directed when every pair of admitted
universes has a common forcing extension.  This strengthens the local
confluence condition, which only compares extensions of a common ground. -/
def GloballyDirected : Prop :=
  ∀ u v : Admitted M, ∃ w : Admitted M,
    AdmittedForces M u w ∧ AdmittedForces M v w

/-- An admitted universe is a common ground when every admitted universe is
accessible from it. -/
def CommonGround (g : Admitted M) : Prop :=
  ∀ u : Admitted M, AdmittedForces M g u

/-- Local confluence upgrades to global directedness whenever the multiverse
has a common ground.  Any two universes are successors of that ground, so the
ambient confluence law gives a common future, and forcing closure admits it. -/
theorem globallyDirected_of_commonGround (g : Admitted M)
    (hg : CommonGround M g) : GloballyDirected M := by
  intro u v
  rcases admittedForces_confluent M g u v (hg u) (hg v) with
    ⟨w, huw, hvw⟩
  exact ⟨w, huw, hvw⟩

/-- Any least admitted universe under forcing is a common ground. -/
theorem commonGround_of_least (g : Admitted M)
    (hleast : ∀ u : Admitted M, AdmittedForces M g u) :
    CommonGround M g := by
  exact hleast

/-- A predicate is forcing-invariant when its truth value is reflected as well
as preserved along every forcing extension. -/
def ForcingInvariant (P : Admitted M → Prop) : Prop :=
  ∀ ⦃u v⦄, AdmittedForces M u v → (P u ↔ P v)

/-- On a globally directed frame, an invariant predicate true at one universe
is true throughout the multiverse.  The common extension transports truth
forward from the witness and then reflects it backward to an arbitrary world. -/
theorem forcingInvariant_global_of_witness {P : Admitted M → Prop}
    (hdir : GloballyDirected M) (hinv : ForcingInvariant M P)
    {u : Admitted M} (hu : P u) : ∀ v, P v := by
  intro v
  rcases hdir u v with ⟨w, huw, hvw⟩
  have hw : P w := (hinv huw).1 hu
  exact (hinv hvw).2 hw

/-- A common-ground multiverse supports the global invariant-fragment
principles without assuming global directedness separately. -/
theorem forcingInvariant_global_of_commonGround {P : Admitted M → Prop}
    (g : Admitted M) (hg : CommonGround M g)
    (hinv : ForcingInvariant M P) (hgP : P g) : ∀ u, P u := by
  exact forcingInvariant_global_of_witness M
    (globallyDirected_of_commonGround M g hg) hinv hgP

/-- For an invariant sentence on a globally directed inhabited frame,
multiverse truth can be tested at any chosen admitted universe. -/
theorem multiverseTrue_iff_invariant_at
    (hdir : GloballyDirected M) {φ : Sentence}
    (hinv : ForcingInvariant M (fun v => M.satisfies v.1 φ))
    (u : Admitted M) :
    MultiverseTrue M φ ↔ M.satisfies u.1 φ := by
  constructor
  · intro hall
    exact hall u.1 u.2
  · intro hu v hv
    exact forcingInvariant_global_of_witness M hdir hinv hu ⟨v, hv⟩

/-- An invariant sentence that fails at one admitted universe is
multiverse-false on a globally directed frame. -/
theorem multiverseFalse_of_invariant_counterexample
    (hdir : GloballyDirected M) {φ : Sentence}
    (hinv : ForcingInvariant M (fun v => M.satisfies v.1 φ))
    (u : Admitted M) (hu : ¬ M.satisfies u.1 φ) :
    MultiverseFalse M φ := by
  intro v hv hφv
  let v' : Admitted M := ⟨v, hv⟩
  have hall := forcingInvariant_global_of_witness M hdir hinv
    (u := v') hφv
  exact hu (hall u)

/-- A forcing-invariant sentence cannot be multiverse-independent on a globally
directed frame. -/
theorem forcingInvariant_not_independent
    (hdir : GloballyDirected M) {φ : Sentence}
    (hinv : ForcingInvariant M (fun v => M.satisfies v.1 φ)) :
    ¬ MultiverseIndependent M φ := by
  rintro ⟨⟨u, hu, hφu⟩, ⟨v, hv, hφv⟩⟩
  let u' : Admitted M := ⟨u, hu⟩
  have hall := forcingInvariant_global_of_witness M hdir hinv
    (u := u') hφu
  exact hφv (hall ⟨v, hv⟩)

/-- Every invariant sentence on a globally directed inhabited multiverse has a
uniform Boolean verdict: it is either true everywhere or false everywhere. -/
theorem forcingInvariant_uniform_verdict
    (hdir : GloballyDirected M) {φ : Sentence}
    (hinv : ForcingInvariant M (fun v => M.satisfies v.1 φ))
    (u : Admitted M) :
    MultiverseTrue M φ ∨ MultiverseFalse M φ := by
  by_cases hu : M.satisfies u.1 φ
  · left
    exact (multiverseTrue_iff_invariant_at M hdir hinv u).2 hu
  · right
    exact multiverseFalse_of_invariant_counterexample M hdir hinv u hu

/-- On globally directed inhabited frames, invariance and independence are
incompatible in both directions: an independent sentence must vary along at
least one forcing edge. -/
theorem independent_not_forcingInvariant
    (hdir : GloballyDirected M) {φ : Sentence}
    (hind : MultiverseIndependent M φ) :
    ¬ ForcingInvariant M (fun v => M.satisfies v.1 φ) := by
  intro hinv
  exact forcingInvariant_not_independent M hdir hinv hind

/-- A globally directed frame admits no sentence that is simultaneously a
forcing switch and forcing-invariant. -/
theorem forcingSwitch_not_invariant
    (hdir : GloballyDirected M) {φ : Sentence}
    (hswitch : ForcingSwitch M (fun v => M.satisfies v.1 φ))
    (u : Admitted M) :
    ¬ ForcingInvariant M (fun v => M.satisfies v.1 φ) := by
  exact independent_not_forcingInvariant M hdir
    (forcingSwitch_implies_independent M hswitch u)

/-- A predicate is forcing-persistent when truth is preserved by every further
forcing extension. -/
def ForcingPersistent (P : Admitted M → Prop) : Prop :=
  ∀ ⦃u v⦄, AdmittedForces M u v → P u → P v

/-- A switch cannot be forcing-persistent.  Starting anywhere, first force the
positive value and then, from that positive world, force the negative value;
persistence would make the latter world satisfy both values. -/
theorem forcingSwitch_not_persistent {P : Admitted M → Prop}
    (hswitch : ForcingSwitch M P) (u : Admitted M) :
    ¬ ForcingPersistent M P := by
  intro hpersistent
  rcases (hswitch u).1 with ⟨v, huv, hv⟩
  rcases (hswitch v).2 with ⟨w, hvw, hw⟩
  exact hw (hpersistent hvw hv)

/-- The negative value of a switch cannot be forcing-persistent either. -/
theorem forcingSwitch_not_neg_persistent {P : Admitted M → Prop}
    (hswitch : ForcingSwitch M P) (u : Admitted M) :
    ¬ ForcingPersistent M (fun v => ¬ P v) := by
  intro hpersistent
  rcases (hswitch u).2 with ⟨v, huv, hv⟩
  rcases (hswitch v).1 with ⟨w, hvw, hw⟩
  exact hpersistent hvw hv hw

/-- Thus neither value of a switch is stable under all forcing extensions. -/
theorem forcingSwitch_no_persistent_value {P : Admitted M → Prop}
    (hswitch : ForcingSwitch M P) (u : Admitted M) :
    ¬ ForcingPersistent M P ∧
    ¬ ForcingPersistent M (fun v => ¬ P v) := by
  exact ⟨forcingSwitch_not_persistent M hswitch u,
    forcingSwitch_not_neg_persistent M hswitch u⟩

/-- CH is a forcing switch on the admitted-universe frame. -/
theorem ch_is_forcingSwitch :
    ForcingSwitch M (fun v => M.satisfies v.1 M.CH) := by
  intro u
  exact admitted_ch_branches M u

/-- Neither CH nor its negation is preserved by all forcing extensions. -/
theorem ch_no_persistent_value (u : Admitted M) :
    ¬ ForcingPersistent M (fun v => M.satisfies v.1 M.CH) ∧
    ¬ ForcingPersistent M (fun v => ¬ M.satisfies v.1 M.CH) := by
  exact forcingSwitch_no_persistent_value M (ch_is_forcingSwitch M) u

/-- CH remains modally contingent after every forcing extension: every
accessible universe still has both a CH and a non-CH future. -/
theorem admitted_ch_necessarily_contingent (u : Admitted M) :
    MultiverseAsymmetricForcing.Box (AdmittedForces M)
      (fun v =>
        MultiverseAsymmetricForcing.Dia (AdmittedForces M)
            (fun w => M.satisfies w.1 M.CH) v ∧
        MultiverseAsymmetricForcing.Dia (AdmittedForces M)
            (fun w => ¬ M.satisfies w.1 M.CH) v) u := by
  exact forcingSwitch_necessary M (ch_is_forcingSwitch M) u

/-- At every forcing extension of an admitted universe, neither CH nor its
negation is necessary there.  This is the iterated local form of “there is no
settled CH verdict.” -/
theorem admitted_ch_necessarily_unsettled (u : Admitted M) :
    MultiverseAsymmetricForcing.Box (AdmittedForces M)
      (fun v =>
        ¬ MultiverseAsymmetricForcing.Box (AdmittedForces M)
            (fun w => M.satisfies w.1 M.CH) v ∧
        ¬ MultiverseAsymmetricForcing.Box (AdmittedForces M)
            (fun w => ¬ M.satisfies w.1 M.CH) v) u := by
  intro v _
  exact forcingSwitch_no_necessary_verdict M (ch_is_forcingSwitch M) v

/-- No forcing extension can make CH permanently necessary. -/
theorem admitted_ch_not_forceably_necessary (u : Admitted M) :
    ¬ MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (fun v => MultiverseAsymmetricForcing.Box (AdmittedForces M)
        (fun w => M.satisfies w.1 M.CH) v) u := by
  exact forcingSwitch_not_forceably_necessary M (ch_is_forcingSwitch M) u

/-- No forcing extension can make the negation of CH permanently necessary. -/
theorem admitted_not_ch_not_forceably_necessary (u : Admitted M) :
    ¬ MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (fun v => MultiverseAsymmetricForcing.Box (AdmittedForces M)
        (fun w => ¬ M.satisfies w.1 M.CH) v) u := by
  exact forcingSwitch_neg_not_forceably_necessary M (ch_is_forcingSwitch M) u

/-- CH is modally contingent at every admitted universe: both CH and its
negation are possible in accessible admitted extensions. -/
theorem admitted_ch_contingent (u : Admitted M) :
    MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (fun v => M.satisfies v.1 M.CH) u ∧
    MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (fun v => ¬ M.satisfies v.1 M.CH) u := by
  exact admitted_ch_branches M u

/-- CH is not forcing-necessary at any admitted universe. -/
theorem admitted_ch_not_necessary (u : Admitted M) :
    ¬ MultiverseAsymmetricForcing.Box (AdmittedForces M)
      (fun v => M.satisfies v.1 M.CH) u := by
  intro hbox
  rcases (admitted_ch_contingent M u).2 with ⟨v, huv, hv⟩
  exact hv (hbox v huv)

/-- The negation of CH is not forcing-necessary at any admitted universe. -/
theorem admitted_not_ch_not_necessary (u : Admitted M) :
    ¬ MultiverseAsymmetricForcing.Box (AdmittedForces M)
      (fun v => ¬ M.satisfies v.1 M.CH) u := by
  intro hbox
  rcases (admitted_ch_contingent M u).1 with ⟨v, huv, hv⟩
  exact hbox v huv hv

/-- No admitted universe has a forcing-necessary Boolean verdict on CH.  This
is the local modal formulation of the absence of a universe-independent CH
truth value. -/
theorem admitted_no_necessary_ch_verdict (u : Admitted M) :
    ¬ MultiverseAsymmetricForcing.Box (AdmittedForces M)
        (fun v => M.satisfies v.1 M.CH) u ∧
    ¬ MultiverseAsymmetricForcing.Box (AdmittedForces M)
        (fun v => ¬ M.satisfies v.1 M.CH) u := by
  exact forcingSwitch_no_necessary_verdict M (ch_is_forcingSwitch M) u

/-- A sentence is globally forcing-necessary when it is necessary at every
admitted universe. -/
def GloballyNecessary (φ : Sentence) : Prop :=
  ∀ u : Admitted M, MultiverseAsymmetricForcing.Box (AdmittedForces M)
    (fun v => M.satisfies v.1 φ) u

/-- Multiverse truth is exactly global forcing necessity on the internal frame.
The forward implication uses that successors are admitted; the reverse
implication uses the trivial forcing extension supplied by reflexivity. -/
theorem multiverseTrue_iff_globallyNecessary {φ : Sentence} :
    MultiverseTrue M φ ↔ GloballyNecessary M φ := by
  constructor
  · intro hall u v _
    exact hall v.1 v.2
  · intro hglobal u hu
    let u' : Admitted M := ⟨u, hu⟩
    exact hglobal u' u' (admittedForces_refl M u')

/-- No background axiom can be a forcing switch in an inhabited multiverse. -/
theorem background_not_forcingSwitch {φ : Sentence} (hφ : φ ∈ M.background)
    (u : Admitted M) :
    ¬ ForcingSwitch M (fun v => M.satisfies v.1 φ) := by
  exact multiverseTrue_not_forcingSwitch M
    (background_is_multiverse_true M hφ) u

/-- Every background axiom is globally forcing-necessary. -/
theorem background_globallyNecessary {φ : Sentence} (hφ : φ ∈ M.background) :
    GloballyNecessary M φ := by
  exact (multiverseTrue_iff_globallyNecessary M).1
    (background_is_multiverse_true M hφ)

/-- In an inhabited multiverse, CH is not globally forcing-necessary. -/
theorem ch_not_globallyNecessary (hex : ∃ u, M.member u) :
    ¬ GloballyNecessary M M.CH := by
  intro h
  exact ch_not_multiverse_true M hex
    ((multiverseTrue_iff_globallyNecessary M).2 h)

/-- The negative CH predicate is not globally necessary either. -/
theorem not_ch_not_globallyNecessary (hex : ∃ u, M.member u) :
    ¬ (∀ u : Admitted M,
      MultiverseAsymmetricForcing.Box (AdmittedForces M)
        (fun v => ¬ M.satisfies v.1 M.CH) u) := by
  rcases hex with ⟨u, hu⟩
  intro h
  exact admitted_not_ch_not_necessary M ⟨u, hu⟩ (h ⟨u, hu⟩)

/-- Thus neither Boolean verdict on CH is globally necessary in an inhabited
multiverse, whereas every background axiom is. -/
theorem background_necessary_but_ch_unsettled (hex : ∃ u, M.member u) :
    (∀ φ ∈ M.background, GloballyNecessary M φ) ∧
    ¬ GloballyNecessary M M.CH ∧
    ¬ (∀ u : Admitted M,
      MultiverseAsymmetricForcing.Box (AdmittedForces M)
        (fun v => ¬ M.satisfies v.1 M.CH) u) := by
  exact ⟨fun _ hφ => background_globallyNecessary M hφ,
    ch_not_globallyNecessary M hex, not_ch_not_globallyNecessary M hex⟩

/-- The admitted-universe frame validates `.2` for every predicate: if a
predicate can become necessary, then it is necessarily possible. -/
theorem admitted_forcing_dot_two {P : Admitted M → Prop} {u : Admitted M}
    (h : MultiverseAsymmetricForcing.Dia (AdmittedForces M)
      (MultiverseAsymmetricForcing.Box (AdmittedForces M) P) u) :
    MultiverseAsymmetricForcing.Box (AdmittedForces M)
      (MultiverseAsymmetricForcing.Dia (AdmittedForces M) P) u := by
  exact MultiverseAsymmetricForcing.box_dot2 (admittedForces_confluent M) h

-- !-- Lab Notes -- !--
-- Hypothesis: forcing closure plus two-way CH branching separates background
-- truth from contingent truth, while confluence supplies the modal axiom `.2`.
-- Experiment: the consequences were derived from an abstract satisfaction
-- relation and then connected to the established asymmetric forcing semantics.
-- Analysis: closure is the crucial bridge from local forcing witnesses to
-- global failures of multiverse truth; confluence is independent of CH
-- branching and controls iterated possibility instead.
-- Critique: the construction does not claim an internal model of ZFC or prove
-- the metamathematical consistency of forcing extensions.  Those facts are
-- explicit semantic premises, avoiding a hidden consistency assumption.
-- Synthesis: background soundness gives multiverse truth, forcing branches
-- refute both uniform CH verdicts, and directedness organizes the result in
-- the modal logic S4.2.
-- !-- End Lab Notes -- !--

end MultiverseSetTheory