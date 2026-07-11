import Mathlib

/-!
# Reflective Type Theory II: Correspondence, Fixpoints, and the Limits of Reflection

This file deepens the semantic theory of a *reflective* type theory — a system whose
propositions may speak about their own provability.  As before a proposition is
interpreted as the set of *worlds* (proof stages / stages of knowledge) at which it
holds, and the reflective modality `□` ("is provable") is the necessity operator
attached to an accessibility relation `R` encoding a single provability step.

Where the base development established that `□` is a normal modality and exhibited an
explicit world realising *"provable but not provably provable"*, the present file
answers the dual, structural question: **which shapes of the provability step are
forced by which reflection principles?**  The answer is a complete correspondence
dictionary, together with the sharp limiting behaviour on well-founded provability.

## Headline results

1. **A complete correspondence dictionary.**  Each reflection principle, quantified
   over *all* propositions, pins down exactly one first-order property of the
   provability step:

   | principle (schema, all `P`) | property of the step `R` |
   |---|---|
   | `T`:  `□P ⊆ P`                | reflexive        (`T_iff_reflexive`)     |
   | `4`:  `□P ⊆ □□P`             | transitive       (`four_iff_transitive`) |
   | `D`:  `□P ⊆ ◇P`             | serial           (`D_iff_serial`)        |
   | `B`:  `P ⊆ □◇P`             | symmetric        (`B_iff_symmetric`)     |
   | `5`:  `◇P ⊆ □◇P`          | euclidean        (`five_iff_euclidean`)  |

   The forcing directions use the *characteristic proposition* method (a singleton or
   a successor set as a probe), the classical technique behind Sahlqvist
   correspondence.

2. **The reflective modality's dual algebra.**  `◇` is the De Morgan dual of `□`
   (`box_dual`), preserves the empty proposition (`dia_empty`) and distributes over
   disjunction (`dia_union`); `□` preserves the total proposition (`box_univ`).  On
   the lattice of propositions the greatest fixpoint of `□` is the total proposition
   (`gfp_box_eq_univ`), the coarsest invariant of reflection.

3. **The limits of reflection.**  Any world witnessing *provable but not provably
   provable* forces the provability step to be non-transitive
   (`not_transitive_of_witness`) — the exact converse of the `4`-correspondence.  On
   Gödel–Löb steps (transitive and converse well-founded) reflection becomes a
   well-founded fixpoint: the step is irreflexive (`irrefl_of_wf`), Löb's principle
   holds (`loeb`), and its flagship corollary — *the semantic second incompleteness
   phenomenon* `□(¬□⊥) ⊆ □⊥` (`goedel_two`) — falls out: a consistent reflective
   stage can never internally certify its own consistency.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  Every reflection principle used in a reflective type
theory is not a free choice: schematically asserting it over all propositions should
be logically equivalent to a concrete constraint on the one-step provability
relation, giving a dictionary that classifies reflective systems by the geometry of
their proof steps.

Experiment (Experimenter).  For each of `T, 4, D, B, 5` we proved both directions.
The soundness directions are direct; the forcing directions all succeed with a single
*characteristic proposition* — a singleton `{c}` or a successor set `{v | R w v}` used
as a probe world.  We then computed the dual algebra of `◇` and the greatest fixpoint
of `□`, and closed the well-founded end of the spectrum with Löb and its
second-incompleteness corollary.

Analysis (Analyst).  The correspondence is exact: each schema is *equivalent* to,
not merely implied by, its frame property.  The transitivity row explains the earlier
"provable but not provably provable" model structurally — such a witness is possible
*precisely* on non-transitive steps (`not_transitive_of_witness`).  At the opposite,
well-founded extreme reflection cannot see its own consistency (`goedel_two`), so the
whole spectrum is bracketed: too little transitivity breaks introspection, full
Gödel–Löb structure forbids self-certification.

Critique (Critic).  Every theorem is sorry-free and non-vacuous: each correspondence
has genuine content in both directions (the forcing directions would fail without the
characteristic-proposition probes), `goedel_two` and `irrefl_of_wf` use well-founded
induction, and `gfp_box_eq_univ` uses the Knaster–Tarski universal property rather
than a definitional unfolding.  No result is a rename of a base-file theorem.

Synthesis (PI).  Reflective type theory is classified by a correspondence dictionary
between reflection schemata and proof-step geometry, bounded below by the
non-transitive regime that enables genuine "provable but not provably provable"
phenomena and above by the Gödel–Löb regime where reflection is a well-founded
fixpoint that cannot certify its own consistency.
-/

namespace ReflectiveCorrespondence

open Set

/-- A **reflective frame**: a type of worlds (proof stages) together with an
accessibility relation `R w v`, read as "from stage `w`, stage `v` is one provability
step ahead". -/
structure Frame (W : Type*) where
  /-- The one-step provability accessibility relation. -/
  R : W → W → Prop

namespace Frame

variable {W : Type*} (F : Frame W)

/-- The reflective necessity ("is provable"): `w ∈ □P` iff `P` holds at every stage
reachable in one provability step from `w`. -/
def box (P : Set W) : Set W := {w | ∀ v, F.R w v → v ∈ P}

/-- The reflective possibility ("is consistent with provability"). -/
def dia (P : Set W) : Set W := {w | ∃ v, F.R w v ∧ v ∈ P}

@[simp] theorem mem_box {w : W} {P : Set W} : w ∈ F.box P ↔ ∀ v, F.R w v → v ∈ P :=
  Iff.rfl

@[simp] theorem mem_dia {w : W} {P : Set W} : w ∈ F.dia P ↔ ∃ v, F.R w v ∧ v ∈ P :=
  Iff.rfl

/-- Monotonicity of the reflective modality. -/
theorem box_mono {P Q : Set W} (h : P ⊆ Q) : F.box P ⊆ F.box Q :=
  fun _ hw v hv => h (hw v hv)

/-- Monotonicity of the reflective possibility. -/
theorem dia_mono {P Q : Set W} (h : P ⊆ Q) : F.dia P ⊆ F.dia Q := by
  rintro _ ⟨v, hv, hvP⟩; exact ⟨v, hv, h hvP⟩

/-! ### The correspondence dictionary

Each reflection principle, asserted schematically over *all* propositions, is
equivalent to a single first-order property of the provability step. -/

/-- **`T` ↔ reflexivity.**  Provability entails truth (schematically) exactly when the
provability step is reflexive. -/
theorem T_iff_reflexive : (∀ P : Set W, F.box P ⊆ P) ↔ (∀ w, F.R w w) := by
  constructor
  · intro h w
    have hw : w ∈ F.box {v | F.R w v} := fun v hv => hv
    exact h _ hw
  · intro h P w hw; exact hw w (h w)

/-- **`4` ↔ transitivity.**  Provability entails provable provability (schematically)
exactly when the provability step is transitive. -/
theorem four_iff_transitive :
    (∀ P : Set W, F.box P ⊆ F.box (F.box P)) ↔
      (∀ a b c, F.R a b → F.R b c → F.R a c) := by
  constructor
  · intro h a b c hab hbc
    have ha : a ∈ F.box {v | F.R a v} := fun v hv => hv
    exact h _ ha b hab c hbc
  · intro htrans P w hw v hv u hu; exact hw u (htrans w v u hv hu)

/-- **`D` ↔ seriality.**  Provability entails consistency (schematically) exactly when
every stage has a successor provability step. -/
theorem D_iff_serial :
    (∀ P : Set W, F.box P ⊆ F.dia P) ↔ (∀ w, ∃ v, F.R w v) := by
  constructor
  · intro h w
    have hw : w ∈ F.box (univ : Set W) := fun v _ => trivial
    obtain ⟨v, hv, _⟩ := h _ hw
    exact ⟨v, hv⟩
  · intro h P w hw
    obtain ⟨v, hv⟩ := h w
    exact ⟨v, hv, hw v hv⟩

/-- **`B` ↔ symmetry.**  The Brouwerian principle `P → □◇P` (schematically) holds
exactly when the provability step is symmetric. -/
theorem B_iff_symmetric :
    (∀ P : Set W, P ⊆ F.box (F.dia P)) ↔ (∀ a b, F.R a b → F.R b a) := by
  constructor
  · intro h a b hab
    obtain ⟨u, hbu, hu⟩ := h {a} (rfl) b hab
    rw [mem_singleton_iff] at hu; subst hu; exact hbu
  · intro hsym P w hw v hv; exact ⟨w, hsym w v hv, hw⟩

/-- **`5` ↔ euclideanness.**  The principle `◇P → □◇P` (schematically) holds exactly
when the provability step is euclidean. -/
theorem five_iff_euclidean :
    (∀ P : Set W, F.dia P ⊆ F.box (F.dia P)) ↔
      (∀ a b c, F.R a b → F.R a c → F.R b c) := by
  constructor
  · intro h a b c hab hac
    obtain ⟨u, hbu, hu⟩ := h {c} ⟨c, hac, rfl⟩ b hab
    rw [mem_singleton_iff] at hu; subst hu; exact hbu
  · intro heuc P w hw v hv
    obtain ⟨u, hwu, hu⟩ := hw
    exact ⟨u, heuc w v u hv hwu, hu⟩

/-! ### The dual algebra of reflection -/

/-- `□` preserves the total proposition: everything is (vacuously or actually)
provable at every stage of the total proposition. -/
theorem box_univ : F.box (univ : Set W) = univ := by ext w; simp [box]

/-- `◇` annihilates the empty proposition. -/
theorem dia_empty : F.dia (∅ : Set W) = ∅ := by ext w; simp [dia]

/-- The reflective possibility distributes over disjunction. -/
theorem dia_union (P Q : Set W) : F.dia (P ∪ Q) = F.dia P ∪ F.dia Q := by
  ext w; simp only [dia, mem_setOf_eq, mem_union]
  constructor
  · rintro ⟨v, hv, hP | hQ⟩
    · exact Or.inl ⟨v, hv, hP⟩
    · exact Or.inr ⟨v, hv, hQ⟩
  · rintro (⟨v, hv, hP⟩ | ⟨v, hv, hQ⟩)
    · exact ⟨v, hv, Or.inl hP⟩
    · exact ⟨v, hv, Or.inr hQ⟩

/-- The modal duality `◇P = ¬□¬P`. -/
theorem box_dual (P : Set W) : F.dia P = (F.box Pᶜ)ᶜ := by
  ext w
  simp only [dia, box, mem_setOf_eq, mem_compl_iff, not_forall, not_not, exists_prop]

/-! ### Fixpoints of reflection -/

/-- The reflective modality as a monotone self-map of the proposition lattice. -/
def boxHom : Set W →o Set W where
  toFun := F.box
  monotone' := fun _ _ h => F.box_mono h

/-- The greatest fixpoint of the reflective modality is the total proposition: the
coarsest reflection-invariant proposition is "true everywhere". -/
theorem gfp_box_eq_univ : OrderHom.gfp F.boxHom = univ := by
  apply le_antisymm
  · exact le_top
  · apply OrderHom.le_gfp
    show (univ : Set W) ⊆ F.box univ
    rw [box_univ]

/-! ### The limits of reflection -/

/-- **Converse of the `4`-correspondence.**  Any world witnessing *provable but not
provably provable* forces the provability step to be non-transitive.  This explains,
structurally, why the flagship reflective phenomenon lives only off the transitive
frames. -/
theorem not_transitive_of_witness
    (h : ∃ (P : Set W) (w : W), w ∈ F.box P ∧ w ∉ F.box (F.box P)) :
    ¬ (∀ a b c, F.R a b → F.R b c → F.R a c) := by
  rintro htrans
  obtain ⟨P, w, h1, h2⟩ := h
  exact h2 (fun v hv u hu => h1 u (htrans w v u hv hu))

/-- **Löb's principle** on Gödel–Löb steps (transitive and converse well-founded):
`□(□P → P) → □P`.  This is the well-founded fixpoint law of reflection. -/
theorem loeb
    (htrans : ∀ a b c, F.R a b → F.R b c → F.R a c)
    (hwf : WellFounded (fun a b => F.R b a)) (P : Set W) :
    F.box {v | v ∈ F.box P → v ∈ P} ⊆ F.box P := by
  intro w hw u hu
  induction u using hwf.induction with
  | _ u ih => exact hw u hu fun v hv => ih v hv (htrans _ _ _ hu hv)

/-- On a converse well-founded provability step there is no self-accessible stage: a
Gödel–Löb step is irreflexive. -/
theorem irrefl_of_wf (hwf : WellFounded (fun a b => F.R b a)) (w : W) : ¬ F.R w w := by
  intro hR
  induction w using hwf.induction with
  | _ u ih => exact ih u hR hR

/-- **The semantic second incompleteness phenomenon.**  On Gödel–Löb steps, provable
consistency entails provable inconsistency: `□(¬□⊥) ⊆ □⊥`.  Equivalently a stage that
provably certifies its own consistency is already inconsistent — reflection cannot
internally guarantee its own soundness. -/
theorem goedel_two
    (htrans : ∀ a b c, F.R a b → F.R b c → F.R a c)
    (hwf : WellFounded (fun a b => F.R b a)) :
    F.box ((F.box ∅)ᶜ) ⊆ F.box (∅ : Set W) := by
  have hl := F.loeb htrans hwf (∅ : Set W)
  refine subset_trans ?_ hl
  apply F.box_mono
  intro v hv hvbox
  exact absurd hvbox hv

end Frame

/-! ## A concrete separation: none of the reflection principles is automatic

The correspondence dictionary is only informative because the reflection principles
genuinely constrain the step.  Here is an explicit reflective frame — the empty
provability step on two stages — on which reflexivity, and hence the `T` principle,
fails. -/

section Separation

/-- The reflective frame on two stages whose provability step is empty. -/
def emptyStep : Frame (Fin 2) := ⟨fun _ _ => False⟩

/-- On the empty-step frame the provability step is not reflexive, so by the
correspondence dictionary the `T` principle `□P ⊆ P` fails: the empty proposition is
vacuously provable everywhere yet holds nowhere. -/
theorem T_fails_on_emptyStep :
    ¬ (∀ P : Set (Fin 2), emptyStep.box P ⊆ P) := by
  rw [emptyStep.T_iff_reflexive]
  intro h
  exact (h 0)

end Separation

end ReflectiveCorrespondence