import Mathlib
import Pythagorean.EGraph.Defs

/-!
# E-Graph Extraction Theorems

This file contains the main theorems establishing the correctness of e-graph
extraction as a quotient section. The central insight: extraction correctness
is a **corollary** of congruence soundness, not an independent property.

## Main Results

### Theorem 1: `extraction_eval_invariant`
If a congruence is sound (related terms evaluate identically), any extraction
section preserves evaluation on each equivalence class.

### Theorem 2: `extraction_correct_of_congruence_sound`
Extraction correctness reduces to congruence soundness: once the congruence
engine certifies soundness, extraction is automatically semantically correct.

### Theorem 3: `optimal_extract_semantics_unique`
Cost-optimal extraction is semantically constant: any two cost-minimal
representatives of the same class have equal denotation.

### Theorem 4: `eval_factors_through_egraph_quotient`
The evaluation map factors through the e-graph quotient exactly when
the e-graph relation is sound. This is the universal algebra statement
that turns an e-graph into a quotient algebra object.

### Theorem 5: `semantically_canonical_of_sound_section`
Semantic canonicity follows from soundness + section property.

### Theorem 6: `approximate_section_of_exact`
An exact section is automatically an approximate section for any
reflexive error relation.

### Theorem 7: `extraction_composition_sound`
Composing extractions through refined congruences preserves semantics.

### Theorem 8: `galois_connection_congruence_modelclass`
Congruences and model classes form a Galois connection.
-/

noncomputable section

open Classical

/-! ## Theorem 1: Extraction Evaluation Invariance

The formal heart of equality saturation: if the congruence is sound,
any section of the quotient map preserves evaluation. -/

/-
**Extraction Invariance Theorem.** Let `s` be an equivalence on terms, `eval`
    a denotation function, and suppose soundness holds: `s.r t₁ t₂ → eval t₁ = eval t₂`.
    If `extract` is a section of the quotient map, then for every class `q` and every
    term `t` in that class, `eval (extract q) = eval t`.

    This is not a property of a particular search heuristic. It is a theorem about
    sections of semantic quotients.
-/
theorem extraction_eval_invariant
    {Term : Type u} {α : Type v}
    (s : Setoid Term)
    (eval : Term → α)
    (h_sound : ∀ {t₁ t₂ : Term}, s.r t₁ t₂ → eval t₁ = eval t₂)
    (extract : Quotient s → Term)
    (h_sec : ∀ q : Quotient s, Quotient.mk s (extract q) = q) :
    ∀ (q : Quotient s) (t : Term),
      Quotient.mk s t = q → eval (extract q) = eval t := by
  grind +suggestions

/-! ## Theorem 2: Reduction of Extraction Correctness to Congruence Soundness

The sole mathematically essential obligation of e-graphs is sound congruence
closure. Once certified, extraction inherits semantic correctness. -/

/-
**Extraction Correctness Reduction.** Suppose `s` is an equivalence, `eval` is
    a denotation, `extract` picks a representative related to `Quotient.out`, and
    soundness holds. Then extraction preserves evaluation.

    This theorem isolates the sole essential obligation: **sound congruence closure**.
    Once that is certified, extraction inherits semantic correctness automatically.
-/
theorem extraction_correct_of_congruence_sound
    {Term : Type u} {α : Type v}
    (s : Setoid Term)
    (eval : Term → α)
    (extract : Quotient s → Term)
    (h_repr : ∀ q : Quotient s, s.r (extract q) (Quotient.out q))
    (h_sound : ∀ {t₁ t₂ : Term}, s.r t₁ t₂ → eval t₁ = eval t₂) :
    ∀ q : Quotient s, eval (extract q) = eval (Quotient.out q) := by
  grind

/-! ## Theorem 3: Cost-Optimal Extraction is Semantically Constant

Cost optimization is semantically harmless inside a sound e-class. -/

/-
**Optimal Extraction Semantics.** If `t₁` and `t₂` are related and both
    cost-minimal in their class, they have the same denotation under any
    sound evaluation. Cost optimization is semantically harmless.
-/
theorem optimal_extract_semantics_unique
    {Term : Type u} {α : Type v}
    (s : Setoid Term)
    (eval : Term → α)
    (cost : Term → ℕ)
    (t₁ t₂ : Term)
    (hrel : s.r t₁ t₂)
    (_hmin₁ : ∀ t, s.r t t₁ → cost t₁ ≤ cost t)
    (_hmin₂ : ∀ t, s.r t t₂ → cost t₂ ≤ cost t)
    (h_sound : ∀ {a b : Term}, s.r a b → eval a = eval b) :
    eval t₁ = eval t₂ := by
  exact h_sound hrel

/-! ## Theorem 4: Evaluation Factors Through E-Graph Quotient

The universal algebra statement: an e-graph is a quotient algebra object. -/

/-
**Factorization Theorem.** The evaluation map factors through the e-graph
    quotient exactly when the e-graph relation is sound. This constructs the
    unique algebra homomorphism from the quotient term algebra to the model.

    This generalizes `commNorm_factors_through_quotient` from the catalog:
    any sound congruence (not just AC-normalization) admits factorization.
-/
theorem eval_factors_through_egraph_quotient
    {Term : Type u} {α : Type v}
    (s : Setoid Term)
    (eval : Term → α)
    (h_sound : ∀ {t₁ t₂ : Term}, s.r t₁ t₂ → eval t₁ = eval t₂) :
    ∃ f : Quotient s → α, ∀ t : Term, f (Quotient.mk s t) = eval t := by
  by_contra h₂;
  have h_factor : ∃ f : Quotient s → α, ∀ t : Term, f (Quotient.mk s t) = eval t := by
    have h_lift : ∀ t₁ t₂ : Term, s t₁ t₂ → eval t₁ = eval t₂ := by
      assumption
    have h_lift : ∃ f : Quotient s → α, ∀ t : Term, f (Quotient.mk s t) = eval t := by
      have h_equiv : ∀ t₁ t₂ : Term, s t₁ t₂ → eval t₁ = eval t₂ := h_lift
      exact ⟨ fun q => Quotient.liftOn' q eval fun t₁ t₂ h => h_equiv t₁ t₂ h, fun t => rfl ⟩;
    exact h_lift;
  exact h₂ h_factor

/-! ## Theorem 5: Semantic Canonicity from Sound Section

The conceptual novelty: extraction need not be syntactically canonical
to be semantically canonical. -/

/-
**Semantic Canonicity Theorem.** If `extract` is a section of a sound
    congruence, then extraction is semantically canonical.
-/
theorem semantically_canonical_of_sound_section
    {Term : Type u} {α : Type v}
    (s : Setoid Term)
    (eval : Term → α)
    (h_sound : ∀ {t₁ t₂ : Term}, s.r t₁ t₂ → eval t₁ = eval t₂)
    (extract : Quotient s → Term)
    (h_sec : ∀ q : Quotient s, Quotient.mk s (extract q) = q) :
    SemanticallyCanonical s eval extract := by
  unfold SemanticallyCanonical;
  grind +suggestions

/-! ## Theorem 6: Exact Sections are Approximate

An exact section is automatically an approximate section for any
reflexive error relation. -/

/-
**Exact-to-Approximate Lifting.** Any exact section is an approximate
    section with respect to any reflexive error relation. This connects
    the ideal (full saturation) to the practical (partial saturation).
-/
theorem approximate_section_of_exact
    {Term : Type u} {α : Type v}
    (s : Setoid Term)
    (eval : Term → α)
    (err : α → α → Prop) (h_refl : ∀ x, err x x)
    (h_sound : ∀ {t₁ t₂ : Term}, s.r t₁ t₂ → eval t₁ = eval t₂)
    (extract : Quotient s → Term)
    (h_sec : ∀ q : Quotient s, Quotient.mk s (extract q) = q) :
    ApproximateSection err s eval extract := by
  intro q t ht
  have h_eq : eval (extract q) = eval t := by
    exact extraction_eval_invariant s eval h_sound extract h_sec q t ht;
  rw [ h_eq ] ; exact h_refl _

/-! ## Theorem 7: Extraction Composition Through Refined Congruences

Composing extractions through a chain of refined congruences preserves
semantics. This models multi-level e-graph optimization. -/

/-
**Composition Theorem.** Given sound congruences `C₁` and `C₂` where `C₁`
    refines `C₂`, composing extractions preserves evaluation through both levels.
    Uses multi-step reasoning: extract at finer level, then project to coarser.
-/
theorem extraction_composition_sound
    {α β : Type*}
    (C₁ C₂ : SoundCongruence α β)
    (h_refines : CongruenceRefines C₁.rel C₂.rel)
    (ext₁ : ExtractionSection α C₁.rel C₁.isEquiv)
    (ext₂ : ExtractionSection α C₂.rel C₂.isEquiv)
    (_h_eval : C₁.eval = C₂.eval) (a : α) :
    C₂.eval (ext₂.extract (@Quotient.mk _ ⟨C₂.rel, C₂.isEquiv⟩
      (ext₁.extract (@Quotient.mk _ ⟨C₁.rel, C₁.isEquiv⟩ a)))) =
    C₂.eval a := by
  convert C₂.sound _ _ _ using 1;
  exact C₂.isEquiv.trans ( ext₂.section_prop _ ) ( h_refines _ _ ( ext₁.section_prop _ ) )

/-! ## Theorem 8: Galois Connection Between Congruences and Model Classes

The abstract kernel of Birkhoff's variety theorem for e-graphs. -/

/-- The congruence induced by a set of functions. -/
def congruenceInducedBy {α β : Type*} (fs : Set (α → β)) : α → α → Prop :=
  fun a₁ a₂ => ∀ f ∈ fs, f a₁ = f a₂

/-
**Galois Connection Theorem.** Congruences and model classes form a Galois
    connection: a congruence refines the one induced by `fs` iff `fs` is contained
    in the model class of the congruence. This is the abstract kernel of Birkhoff's
    variety theorem applied to e-graphs.
-/
theorem galois_connection_congruence_modelclass
    {α β : Type*}
    (rel : α → α → Prop) (fs : Set (α → β)) :
    CongruenceRefines rel (congruenceInducedBy fs) ↔
    fs ⊆ ModelClass rel := by
  constructor <;> intro h;
  · exact fun f hf a₁ a₂ h' => h a₁ a₂ h' f hf;
  · exact fun a₁ a₂ h₁ => fun f hf => h hf a₁ a₂ h₁

/-! ## Theorem 9: Extraction Preserves Eval (SoundCongruence variant)

Directly using the SoundCongruence structure. -/

/-
**Main Correctness Theorem (Structured).** If `C` is a sound congruence and
    `ext` is an extraction section, then extraction preserves evaluation.
-/
theorem extraction_preserves_eval_structured
    {α β : Type*}
    (C : SoundCongruence α β)
    (ext : ExtractionSection α C.rel C.isEquiv) :
    ∀ a : α, C.eval (ext.extract (@Quotient.mk _ ⟨C.rel, C.isEquiv⟩ a)) = C.eval a := by
  exact fun a => C.sound _ _ ( ext.section_prop _ )

/-! ## Theorem 10: Extraction Idempotence -/

/-
**Idempotence.** Extraction is idempotent: extracting from an already-extracted
    element yields the same element.
-/
theorem extraction_idempotent
    {α : Type*}
    {rel : α → α → Prop} {equiv : Equivalence rel}
    (ext : ExtractionSection α rel equiv) (a : α) :
    ext.extract (@Quotient.mk _ ⟨rel, equiv⟩
      (ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a))) =
    ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a) := by
  have h_eq : rel (ext.extract ⟦ext.extract ⟦a⟧⟧) (ext.extract ⟦a⟧) := by
    exact ext.section_prop _;
  have h_eq : Quotient.mk ⟨rel, equiv⟩ (ext.extract ⟦ext.extract ⟦a⟧⟧) = Quotient.mk ⟨rel, equiv⟩ (ext.extract ⟦a⟧) := by
    exact Quotient.eq.mpr h_eq;
  convert congr_arg ( fun q => ext.extract q ) h_eq using 1;
  · exact congr_arg _ h_eq.symm;
  · convert congr_arg ( fun q => ext.extract q ) _;
    exact Quotient.sound ( ext.section_prop a ) |> Eq.symm

/-! ## Theorem 11: Model Class Antitone -/

/-
**Antitone Model Classes.** Finer congruences have larger model classes.
-/
theorem modelClass_antitone
    {α β : Type*} {rel₁ rel₂ : α → α → Prop}
    (h : CongruenceRefines rel₁ rel₂) :
    ModelClass rel₂ ⊆ @ModelClass α β rel₁ := by
  exact fun f hf a₁ a₂ h' => hf a₁ a₂ ( h a₁ a₂ h' )

/-! ## Theorem 12: Term Congruence Lemma -/

/-
**Congruence Lemma for Terms.** If arguments evaluate equally, composed terms
    evaluate equally. This is the structural property making congruence closure correct.
-/
theorem eval_binop_congr {S : Sig} {α : Type*} (A : Interp S α)
    (f : S.binop) {t₁ t₂ s₁ s₂ : Term S}
    (h₁ : t₁.eval A = t₂.eval A)
    (h₂ : s₁.eval A = s₂.eval A) :
    (Term.binop f t₁ s₁).eval A = (Term.binop f t₂ s₂).eval A := by
  exact congr_arg₂ ( A.interpBinop f ) h₁ h₂

/-! ## Theorem 13: Structural Induction on Interpretations -/

/-
**Structural Induction.** Two interpretations agreeing on all symbols produce
    equal evaluations on all terms.
-/
theorem eval_eq_of_interp_eq {S : Sig} {α : Type*}
    (A B : Interp S α)
    (h_const : ∀ c, A.interpConst c = B.interpConst c)
    (h_binop : ∀ f, A.interpBinop f = B.interpBinop f)
    (t : Term S) : t.eval A = t.eval B := by
  induction' t with c t₁ t₂ ih₁ ih₂;
  · exact h_const c;
  · simp +decide [ *, Term.eval ]

/-! ## Theorem 14: Cost-Optimal Extraction Never Increases Cost -/

/-- **Cost Monotonicity.** Cost-optimal extraction never increases cost. -/
theorem cost_extraction_never_increases
    {α : Type*} {rel : α → α → Prop} {equiv : Equivalence rel}
    (ext : CostExtractionSection α rel equiv) (a : α) :
    ext.cost (ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a)) ≤ ext.cost a :=
  ext.optimal a

/-! ## Theorem 15: Factorization Constructs Unique Quotient Map -/

/-
**Unique Factorization.** The factored evaluation map is the unique function
    making the diagram commute.
-/
theorem eval_factorization_unique
    {Term : Type u} {α : Type v}
    (s : Setoid Term)
    (eval : Term → α)
    (_h_sound : ∀ {t₁ t₂ : Term}, s.r t₁ t₂ → eval t₁ = eval t₂)
    (f g : Quotient s → α)
    (hf : ∀ t, f (Quotient.mk s t) = eval t)
    (hg : ∀ t, g (Quotient.mk s t) = eval t) :
    f = g := by
  exact funext fun x => by rcases Quotient.exists_rep x with ⟨ y, rfl ⟩ ; exact hf y ▸ hg y ▸ rfl;

end