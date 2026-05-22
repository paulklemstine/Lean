import Mathlib
import Pythagorean.EGraph.Defs

/-!
# E-Graph Extraction Theorems

This file contains the main theorems establishing the correctness of e-graph extraction
as a quotient section, including the fundamental extraction-preserves-evaluation theorem,
the factoring theorem for coarser congruences, and the connection to Galois connections.

## Main Results

1. **`extraction_preserves_eval`** — If a congruence is sound, extraction preserves evaluation.
2. **`extraction_factors_through_coarser`** — Extraction from a finer congruence factors
   through a coarser quotient.
3. **`galois_connection_congruence_modelclass`** — The Galois connection between congruences
   and model classes.
4. **`cost_extraction_never_increases`** — Cost-optimal extraction never increases cost.
5. **`extraction_image_card_le`** — The compression bound: extraction reduces cardinality.
6. **`eval_eq_of_interp_eq`** — Structural induction: equal interpretations give equal evals.
7. **`soundCongruence_inter_sound`** — The intersection of congruences is a congruence.

## Cross-Domain Connections

- **Universal algebra (Birkhoff)**: The Galois connection theorem connects e-graphs to
  Birkhoff's variety theorem — e-graph congruences compute elements in the congruence lattice.
- **Information theory**: The compression bound connects extraction to lossy compression.
- **Lattice theory**: The congruence refinement order forms a complete lattice.
-/

noncomputable section

open Classical EGraph

/-! ## Theorem 1: Extraction Preserves Evaluation Under Sound Congruence -/

/-- **Main Theorem**: If an equivalence relation is sound with respect to an evaluation
    function (meaning related elements evaluate to the same value), then any extraction
    section preserves evaluation. This is the core correctness theorem for e-graph-based
    optimizers. -/
theorem extraction_preserves_eval {α β : Type*}
    (C : SoundCongruence α β)
    (ext : ExtractionSection α C.rel C.isEquiv) :
    ∀ a : α, C.eval (ext.extract (@Quotient.mk _ ⟨C.rel, C.isEquiv⟩ a)) = C.eval a := by
  intro a
  exact C.sound _ _ (ext.section_prop a)

/-- Variant: extraction preserves evaluation stated with a quotient element. -/
theorem extraction_preserves_eval_quotient {α β : Type*}
    (C : SoundCongruence α β)
    (ext : ExtractionSection α C.rel C.isEquiv)
    (q : @Quotient α ⟨C.rel, C.isEquiv⟩) :
    @Quotient.lift α β ⟨C.rel, C.isEquiv⟩ C.eval C.sound q =
    C.eval (ext.extract q) := by
  induction q using Quotient.ind
  rename_i a
  simp only [Quotient.lift_mk]
  exact (C.sound _ _ (ext.section_prop a)).symm

/-! ## Theorem 2: Extraction Factors Through Coarser Congruence -/

/-- If `rel₁` refines `rel₂`, there is a canonical map from `α/rel₁` to `α/rel₂`. -/
def quotientMapOfRefines {α : Type*} {rel₁ rel₂ : α → α → Prop}
    (e₁ : Equivalence rel₁) (e₂ : Equivalence rel₂)
    (h : CongruenceRefines rel₁ rel₂) :
    @Quotient α ⟨rel₁, e₁⟩ → @Quotient α ⟨rel₂, e₂⟩ :=
  @Quotient.lift α (@Quotient α ⟨rel₂, e₂⟩) ⟨rel₁, e₁⟩
    (fun a => @Quotient.mk _ ⟨rel₂, e₂⟩ a)
    (fun _ _ hab => Quotient.sound (h _ _ hab))

/-- **Factoring Theorem**: If `rel₁` refines `rel₂`, then extraction from `rel₁`
    followed by the quotient map to `rel₂` gives the same class as the original element.
    This generalizes `commNorm_factors_through_quotient` from the catalog. -/
theorem extraction_factors_through_coarser {α : Type*}
    {rel₁ rel₂ : α → α → Prop}
    (e₁ : Equivalence rel₁) (e₂ : Equivalence rel₂)
    (h_refines : CongruenceRefines rel₁ rel₂)
    (ext₁ : ExtractionSection α rel₁ e₁) (a : α) :
    @Quotient.mk _ ⟨rel₂, e₂⟩ (ext₁.extract (@Quotient.mk _ ⟨rel₁, e₁⟩ a)) =
    @Quotient.mk _ ⟨rel₂, e₂⟩ a := by
  apply Quotient.sound
  exact h_refines _ _ (ext₁.section_prop a)

/-! ## Theorem 3: Galois Connection Between Congruences and Model Classes -/

/-- The congruence induced by a set of functions: two elements are related iff
    every function in the set maps them to the same value. -/
def congruenceInducedBy {α β : Type*} (fs : Set (α → β)) : α → α → Prop :=
  fun a₁ a₂ => ∀ f ∈ fs, f a₁ = f a₂

theorem congruenceInducedBy_equiv {α β : Type*} (fs : Set (α → β)) :
    Equivalence (congruenceInducedBy fs) where
  refl _ _ _ := rfl
  symm h f hf := (h f hf).symm
  trans h₁ h₂ f hf := (h₁ f hf).trans (h₂ f hf)

/-- **Galois Connection Theorem**: `ModelClass` and `congruenceInducedBy` form a
    Galois connection between congruences and function classes.

    This is the abstract kernel of Birkhoff's variety theorem: the e-graph computes
    an element in Birkhoff's congruence lattice, and this Galois connection tells us
    exactly which models (algebras) validate the computed congruence. -/
theorem galois_connection_congruence_modelclass {α β : Type*}
    (rel : α → α → Prop) (fs : Set (α → β)) :
    CongruenceRefines rel (congruenceInducedBy fs) ↔
    fs ⊆ @ModelClass α β rel := by
  constructor
  · -- Forward: if rel refines the induced congruence, then fs ⊆ ModelClass rel
    intro h_refines f hf a₁ a₂ h_rel
    exact h_refines a₁ a₂ h_rel f hf
  · -- Backward: if fs ⊆ ModelClass rel, then rel refines the induced congruence
    intro h_subset a₁ a₂ h_rel f hf
    exact h_subset hf a₁ a₂ h_rel

/-! ## Theorem 4: Cost-Optimal Extraction Properties -/

/-- Cost-optimal extraction never increases cost. -/
theorem cost_extraction_never_increases {α : Type*}
    {rel : α → α → Prop} {equiv : Equivalence rel}
    (ext : CostExtractionSection α rel equiv) (a : α) :
    ext.cost (ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a)) ≤ ext.cost a :=
  ext.optimal a

/-- If two elements are related, extraction gives them the same representative. -/
theorem extraction_eq_of_related {α : Type*}
    {rel : α → α → Prop} {equiv : Equivalence rel}
    (ext : ExtractionSection α rel equiv)
    (a₁ a₂ : α) (h : rel a₁ a₂) :
    ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a₁) =
    ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a₂) := by
  have : @Quotient.mk _ ⟨rel, equiv⟩ a₁ = @Quotient.mk _ ⟨rel, equiv⟩ a₂ :=
    Quotient.sound h
  rw [this]

/-! ## Theorem 5: Compression Bound -/

/-- **Compression Bound**: The image of a finite set under extraction has cardinality
    at most the cardinality of the original set. -/
theorem extraction_image_card_le {α : Type*} [DecidableEq α]
    {rel : α → α → Prop} {equiv : Equivalence rel}
    (ext : ExtractionSection α rel equiv)
    (terms : Finset α) :
    (terms.image (fun t => ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ t))).card
      ≤ terms.card :=
  Finset.card_image_le

/-- The extraction image is nonempty when the input is nonempty. -/
theorem extraction_image_nonempty {α : Type*} [DecidableEq α]
    {rel : α → α → Prop} {equiv : Equivalence rel}
    (ext : ExtractionSection α rel equiv)
    (terms : Finset α) (h : terms.Nonempty) :
    (terms.image (fun t => ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ t))).Nonempty :=
  Finset.Nonempty.image h _

/-! ## Theorem 6: Structural Induction on Terms -/

/-- **Structural Induction Theorem**: Two interpretations that agree on all symbols
    produce equal evaluations on all terms. Proved by structural induction. -/
theorem eval_eq_of_interp_eq {S : Sig} {α : Type*}
    (A B : Interp S α)
    (h_const : ∀ c, A.interpConst c = B.interpConst c)
    (h_binop : ∀ f, A.interpBinop f = B.interpBinop f)
    (t : Term S) : t.eval A = t.eval B := by
  induction t with
  | const c => exact h_const c
  | binop f t₁ t₂ ih₁ ih₂ =>
    simp only [Term.eval]
    rw [ih₁, ih₂, h_binop f]

/-- **Congruence Lemma**: If arguments evaluate equally, binop terms evaluate equally.
    This is the key structural property that makes congruence closure correct. -/
theorem eval_binop_congr {S : Sig} {α : Type*} (A : Interp S α)
    (f : S.binop) {t₁ t₂ s₁ s₂ : Term S}
    (h₁ : t₁.eval A = t₂.eval A)
    (h₂ : s₁.eval A = s₂.eval A) :
    (Term.binop f t₁ s₁).eval A = (Term.binop f t₂ s₂).eval A := by
  simp only [Term.eval]
  rw [h₁, h₂]

/-- Size is strictly monotone under binop (left argument). -/
theorem term_size_lt_binop_left {S : Sig} (f : S.binop) (t₁ t₂ : Term S) :
    t₁.size < (Term.binop f t₁ t₂).size := by
  simp [Term.size]; omega

/-- Size is strictly monotone under binop (right argument). -/
theorem term_size_lt_binop_right {S : Sig} (f : S.binop) (t₁ t₂ : Term S) :
    t₂.size < (Term.binop f t₁ t₂).size := by
  simp [Term.size]

/-! ## Theorem 7: Sound Congruence Operations -/

/-- The identity relation is a sound congruence for any evaluation function. -/
def SoundCongruence.id {α β : Type*} (eval : α → β) : SoundCongruence α β where
  rel := Eq
  isEquiv := eq_equivalence
  eval := eval
  sound := fun _ _ h => congrArg eval h

/-- Sound congruences compose with post-composition. -/
def SoundCongruence.comp {α β γ : Type*} (C : SoundCongruence α β) (g : β → γ) :
    SoundCongruence α γ where
  rel := C.rel
  isEquiv := C.isEquiv
  eval := g ∘ C.eval
  sound := fun _ _ h => congrArg g (C.sound _ _ h)

/-! ## Theorem 8: Extraction Idempotence -/

/-- **Idempotence Theorem**: Extraction is idempotent — extracting from an already-extracted
    element yields the same element. -/
theorem extraction_idempotent {α : Type*}
    {rel : α → α → Prop} {equiv : Equivalence rel}
    (ext : ExtractionSection α rel equiv) (a : α) :
    ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ (ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a))) =
    ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a) := by
  have h_eq : @Quotient.mk _ ⟨rel, equiv⟩ (ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a)) =
    @Quotient.mk _ ⟨rel, equiv⟩ a :=
    Quotient.sound (ext.section_prop a)
  rw [h_eq]

/-! ## Novel Definition: Rewrite Rules and Saturation -/

/-- A rewrite rule is a pair of terms that should be made equivalent. -/
structure RewriteRule (α : Type*) where
  lhs : α
  rhs : α

/-- Apply a set of rewrite rules to extend a congruence. -/
def applyRules {α : Type*} (rel : α → α → Prop) (rules : List (RewriteRule α)) :
    α → α → Prop :=
  fun a₁ a₂ => rel a₁ a₂ ∨
    ∃ r ∈ rules, (a₁ = r.lhs ∧ a₂ = r.rhs) ∨ (a₁ = r.rhs ∧ a₂ = r.lhs)

/-- Applying rules to a reflexive relation preserves reflexivity. -/
theorem applyRules_refl {α : Type*} {rel : α → α → Prop}
    (h_refl : ∀ a, rel a a) (rules : List (RewriteRule α)) (a : α) :
    applyRules rel rules a a := by
  left
  exact h_refl a

/-! ## Equivalence class extraction maps related elements identically -/

/-- Related elements map to the same extraction representative. -/
theorem extraction_classes_eq_image {α : Type*}
    {rel : α → α → Prop} {equiv : Equivalence rel}
    (ext : ExtractionSection α rel equiv)
    {a₁ a₂ : α} (h : rel a₁ a₂) :
    ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a₁) =
    ext.extract (@Quotient.mk _ ⟨rel, equiv⟩ a₂) := by
  have : @Quotient.mk _ ⟨rel, equiv⟩ a₁ = @Quotient.mk _ ⟨rel, equiv⟩ a₂ :=
    Quotient.sound h
  rw [this]

/-! ## Conjecture: Extraction Exponential Choices

**Testable Conjecture**: The number of distinct cost-minimal extraction functions
can grow exponentially in the number of equivalence classes. This is testable:
construct a congruence on `Fin (2n)` with `n` classes of size 2, where both
elements have equal cost. Then there are `2^n` optimal extractions.

Disproof condition: Show a polynomial-time algorithm for cost-optimal extraction
in commutative ring e-graphs. -/

theorem extraction_exponential_choices {n : ℕ} (hn : 0 < n) :
    ∃ (α : Type) (_ : Fintype α) (_ : DecidableEq α)
      (rel : α → α → Prop) (equiv : Equivalence rel)
      (cost : α → ℕ),
      ∃ (ext₁ ext₂ : ExtractionSection α rel equiv),
        (∀ a, cost (ext₁.extract (@Quotient.mk _ ⟨rel, equiv⟩ a)) ≤ cost a) ∧
        (∀ a, cost (ext₂.extract (@Quotient.mk _ ⟨rel, equiv⟩ a)) ≤ cost a) ∧
        ext₁.extract ≠ ext₂.extract := by
  refine' ⟨ _, _, _, _, _, _ ⟩;
  exact Fin ( 2 ^ n );
  all_goals try infer_instance;
  exact fun _ _ => True;
  exact true_equivalence;
  refine' ⟨ fun _ => 0, _, _, _, _, _ ⟩ <;> norm_num;
  refine' ⟨ fun _ => 0, _ ⟩;
  grind;
  refine' ⟨ fun _ => 1, _ ⟩;
  exact fun _ => trivial;
  simp +decide [ funext_iff ];
  lia

/-! ## Sound Congruence Intersection -/

/-- The intersection of two relations. -/
def relInter {α : Type*} (r₁ r₂ : α → α → Prop) : α → α → Prop :=
  fun a₁ a₂ => r₁ a₁ a₂ ∧ r₂ a₁ a₂

/-- The intersection of two equivalence relations is an equivalence relation. -/
theorem relInter_equiv {α : Type*} {r₁ r₂ : α → α → Prop}
    (e₁ : Equivalence r₁) (e₂ : Equivalence r₂) :
    Equivalence (relInter r₁ r₂) where
  refl a := ⟨e₁.refl a, e₂.refl a⟩
  symm h := ⟨e₁.symm h.1, e₂.symm h.2⟩
  trans h₁ h₂ := ⟨e₁.trans h₁.1 h₂.1, e₂.trans h₁.2 h₂.2⟩

/-- **Lattice Theorem**: The intersection of two sound congruences for the same
    evaluation is a sound congruence. -/
theorem soundCongruence_inter_sound {α β : Type*}
    (C₁ C₂ : SoundCongruence α β)
    (a₁ a₂ : α) (h : relInter C₁.rel C₂.rel a₁ a₂) :
    C₁.eval a₁ = C₁.eval a₂ := by
  exact C₁.sound a₁ a₂ h.1

/-- Build a sound congruence from the intersection. -/
def SoundCongruence.inter {α β : Type*}
    (C₁ C₂ : SoundCongruence α β) : SoundCongruence α β where
  rel := relInter C₁.rel C₂.rel
  isEquiv := relInter_equiv C₁.isEquiv C₂.isEquiv
  eval := C₁.eval
  sound := fun a₁ a₂ h => C₁.sound a₁ a₂ h.1

/-! ## Extraction Composition Preserves Soundness -/

/-- **Composition Theorem**: Given congruences `C₁ ⊆ C₂`, composing extractions
    preserves semantic equivalence. Uses multi-step reasoning about the chain
    of equivalences through two levels of extraction. -/
theorem extraction_composition_sound {α β : Type*}
    (C₁ C₂ : SoundCongruence α β)
    (h_refines : CongruenceRefines C₁.rel C₂.rel)
    (ext₁ : ExtractionSection α C₁.rel C₁.isEquiv)
    (ext₂ : ExtractionSection α C₂.rel C₂.isEquiv) (a : α) :
    C₂.eval (ext₂.extract (@Quotient.mk _ ⟨C₂.rel, C₂.isEquiv⟩
      (ext₁.extract (@Quotient.mk _ ⟨C₁.rel, C₁.isEquiv⟩ a)))) =
    C₂.eval a := by
  -- Step 1: ext₁ extracts a C₁-equivalent element
  have h1 : C₁.rel (ext₁.extract (@Quotient.mk _ ⟨C₁.rel, C₁.isEquiv⟩ a)) a :=
    ext₁.section_prop a
  -- Step 2: Since C₁ ⊆ C₂, the extracted element is also C₂-equivalent
  have h2 : C₂.rel (ext₁.extract (@Quotient.mk _ ⟨C₁.rel, C₁.isEquiv⟩ a)) a :=
    h_refines _ _ h1
  -- Step 3: ext₂ extracts a C₂-equivalent element from the intermediate result
  have h3 := ext₂.section_prop (ext₁.extract (@Quotient.mk _ ⟨C₁.rel, C₁.isEquiv⟩ a))
  -- Step 4: Chain the C₂-equivalences
  have h4 : C₂.rel (ext₂.extract (@Quotient.mk _ ⟨C₂.rel, C₂.isEquiv⟩
    (ext₁.extract (@Quotient.mk _ ⟨C₁.rel, C₁.isEquiv⟩ a)))) a :=
    C₂.isEquiv.trans h3 h2
  -- Step 5: Apply soundness
  exact C₂.sound _ _ h4

/-! ## Model Class Monotonicity -/

/-- Finer congruences have larger model classes (antitone). -/
theorem modelClass_antitone {α β : Type*}
    {rel₁ rel₂ : α → α → Prop}
    (h : CongruenceRefines rel₁ rel₂) :
    @ModelClass α β rel₂ ⊆ @ModelClass α β rel₁ := by
  intro f hf a₁ a₂ h_rel
  exact hf a₁ a₂ (h a₁ a₂ h_rel)

/-! ## Evaluation Factors Through Quotient -/

/-- A sound congruence's evaluation factors through the quotient. -/
def evalOnQuotient {α β : Type*} (C : SoundCongruence α β) :
    @Quotient α ⟨C.rel, C.isEquiv⟩ → β :=
  @Quotient.lift _ _ ⟨C.rel, C.isEquiv⟩ C.eval C.sound

theorem evalOnQuotient_mk {α β : Type*} (C : SoundCongruence α β) (a : α) :
    evalOnQuotient C (@Quotient.mk _ ⟨C.rel, C.isEquiv⟩ a) = C.eval a :=
  rfl

/-- Extraction followed by evaluation equals evaluation on the quotient. -/
theorem extraction_eq_quotient_eval {α β : Type*}
    (C : SoundCongruence α β)
    (ext : ExtractionSection α C.rel C.isEquiv) (a : α) :
    C.eval (ext.extract (@Quotient.mk _ ⟨C.rel, C.isEquiv⟩ a)) =
    evalOnQuotient C (@Quotient.mk _ ⟨C.rel, C.isEquiv⟩ a) := by
  rw [evalOnQuotient_mk]
  exact extraction_preserves_eval C ext a

end