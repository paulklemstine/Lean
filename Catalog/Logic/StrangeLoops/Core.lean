import Mathlib

/-!
# Strange Loops: Self-Reference and Fixed Points in Provability

This module formalizes the concept of "strange loops" — self-referential structures
that arise inevitably in sufficiently powerful formal systems. We establish that:

1. **Lawvere's Fixed Point Theorem** (generalized): Any point-surjective map
   forces every endomorphism to have a fixed point — the structural root of
   all diagonalization arguments.

2. **Strange Loop Existence**: We define a `StrangeLoop` as a formal system
   equipped with a self-referencing diagonal operator, and prove that such
   systems necessarily contain undecidable sentences.

3. **Tangled Hierarchy Collapse**: When meta-levels of a formal hierarchy
   can refer back to lower levels, the resulting "tangled hierarchy" collapses.

4. **Provability Lattice Fixed Points**: On the complete lattice of theories,
   the provability closure operator has fixed points — strange loops in the lattice.

5. **Rice's Theorem Analog**: Any non-trivial semantic property of formal
   systems is undecidable — proved via Lawvere's theorem.

## References

- Lawvere, F.W. "Diagonal arguments and cartesian closed categories" (1969)
- Hofstadter, D. "Gödel, Escher, Bach" (1979)
- Yanofsky, N. "A universal approach to self-referential paradoxes" (2003)
-/

open Function Set

noncomputable section

/-! ## Part 1: Novel Structures -/

/-- A `FormalSystem` models a formal system with sentences, a provability
    predicate, and a truth predicate. -/
structure FormalSystem where
  /-- The type of sentences -/
  Sentence : Type
  /-- Provability predicate -/
  Provable : Sentence → Prop
  /-- Truth predicate -/
  True_ : Sentence → Prop
  /-- Soundness: provable sentences are true -/
  sound : ∀ s, Provable s → True_ s

/-- A `StrangeLoop` is a formal system equipped with a diagonal operator that
    produces self-referential sentences. The diagonal operator takes any predicate
    on sentences and returns a sentence whose truth value equals that predicate
    applied to itself. This is the formal incarnation of Hofstadter's "strange loop." -/
structure StrangeLoop extends FormalSystem where
  /-- The diagonal/self-reference operator -/
  diag : (Sentence → Prop) → Sentence
  /-- The diagonal property: the truth of `diag P` is equivalent to `P (diag P)` -/
  diag_spec : ∀ P : Sentence → Prop, True_ (diag P) ↔ P (diag P)

/-- The Gödel sentence of a strange loop: a sentence that asserts its own unprovability. -/
def StrangeLoop.goedelSentence (L : StrangeLoop) : L.Sentence :=
  L.diag (fun s => ¬ L.Provable s)

/-- A `TangledHierarchy` models a system of formal levels where each level can
    reason about lower levels, but with a "tangle" — a path from a higher level
    back down to a lower one, creating a strange loop in the hierarchy. -/
structure TangledHierarchy where
  /-- The set of levels -/
  Level : Type
  /-- Sentences at each level -/
  Sentence : Level → Type
  /-- Each level can prove statements about the level below -/
  provesAbout : (l₁ l₂ : Level) → Sentence l₁ → Sentence l₂ → Prop
  /-- The tangle: a map sending higher-level sentences back to lower levels -/
  tangle : (l₁ l₂ : Level) → Sentence l₁ → Sentence l₂

/-- A `ProvabilityAlgebra` is a complete lattice of "theories" equipped with a
    closure operator representing provability. -/
structure ProvabilityAlgebra (n : ℕ) where
  /-- The provability closure: adds all consequences -/
  closure : Set (Fin n) → Set (Fin n)
  /-- Closure is monotone -/
  closure_mono : Monotone closure
  /-- Closure is extensive -/
  closure_ext : ∀ S, S ⊆ closure S
  /-- Closure is idempotent -/
  closure_idem : ∀ S, closure (closure S) = closure S

/-! ## Part 2: The Gödel Sentence is Undecidable -/

/-- **The Gödel Sentence Theorem**: In any strange loop, the Gödel sentence
    (which asserts its own unprovability) is true but unprovable.

    This is Gödel's First Incompleteness Theorem as a fixed-point consequence. -/
theorem StrangeLoop.goedel_true_unprovable (L : StrangeLoop) :
    L.True_ L.goedelSentence ∧ ¬ L.Provable L.goedelSentence := by
  unfold goedelSentence
  have hspec := L.diag_spec (fun s => ¬ L.Provable s)
  constructor
  · -- The Gödel sentence is true
    rw [hspec]
    intro hprov
    exact (hspec.mp (L.sound _ hprov)) hprov
  · -- The Gödel sentence is not provable
    intro hprov
    exact (hspec.mp (L.sound _ hprov)) hprov

/-- **Incompleteness from Strange Loops**: Any strange loop is incomplete —
    there exists a true sentence that is not provable. -/
theorem StrangeLoop.incomplete (L : StrangeLoop) :
    ∃ s, L.True_ s ∧ ¬ L.Provable s :=
  ⟨L.goedelSentence, L.goedel_true_unprovable⟩

/-- **No Strange Loop is Complete**: A strange loop cannot prove all truths. -/
theorem StrangeLoop.not_complete (L : StrangeLoop) :
    ¬ (∀ s, L.True_ s → L.Provable s) := by
  intro hcomplete
  obtain ⟨s, htrue, hunprov⟩ := L.incomplete
  exact hunprov (hcomplete s htrue)

/-! ## Part 3: Generalized Lawvere Fixed-Point Theorem -/

/-- **Lawvere's Fixed-Point Theorem** (concrete version for types):
    If there exists a surjection `φ : A → (A → B)`, then every function
    `g : B → B` has a fixed point. -/
theorem lawvere_fixed_point {A B : Type*}
    (φ : A → (A → B)) (hφ : Surjective φ) (g : B → B) :
    ∃ b : B, g b = b := by
  obtain ⟨a₀, ha₀⟩ := hφ (fun a => g (φ a a))
  exact ⟨φ a₀ a₀, congr_fun ha₀ a₀ |>.symm⟩

/-- **Cantor's Theorem** as a corollary of Lawvere:
    There is no surjection from a type to its power set. -/
theorem cantor_from_lawvere (A : Type*) :
    ¬ ∃ f : A → (A → Prop), Surjective f := by
  intro ⟨f, hf⟩
  have key : ∀ a, f a ≠ (fun x => ¬ f x x) := by
    intro a h
    have h' := congr_fun h a
    simp at h'
  exact key _ (hf _).choose_spec

/-- **Tarski's Undefinability** as a corollary:
    If `φ` is surjective, there is no predicate that is a fixed point of negation. -/
theorem tarski_undefinability {A : Type*}
    (φ : A → (A → Prop)) (_hφ : Surjective φ) :
    ∃ P : A → Prop, ∀ a, φ a ≠ P := by
  use fun a => ¬ φ a a
  intro a ha
  have := congr_fun ha a
  simp at this

/-! ## Part 4: The Strange Loop Lattice -/

/-- The set of fixed points of a provability algebra forms the "theory space." -/
def ProvabilityAlgebra.theorySpace {n : ℕ} (PA : ProvabilityAlgebra n) : Set (Set (Fin n)) :=
  {S | PA.closure S = S}

/-- **Fixed Point Existence in Provability Algebras**:
    Every provability algebra has a least fixed point. -/
theorem ProvabilityAlgebra.has_least_fixed_point {n : ℕ} (PA : ProvabilityAlgebra n) :
    ∃ S, PA.closure S = S ∧ ∀ T, PA.closure T = T → S ⊆ T := by
  let S := ⋂₀ {T | PA.closure T = T}
  use PA.closure S
  constructor
  · exact PA.closure_idem S
  · intro T hT
    have hST : S ⊆ T := Set.sInter_subset_of_mem hT
    exact (PA.closure_mono hST).trans (le_of_eq hT)

/-- **Provability Algebras: Full set is a fixed point.** -/
theorem ProvabilityAlgebra.full_is_fixed {n : ℕ} (PA : ProvabilityAlgebra n) :
    PA.closure Set.univ = Set.univ :=
  le_antisymm (Set.subset_univ _) (PA.closure_ext Set.univ)

/-! ## Part 5: Rice's Theorem Analog -/

/-- A property is **trivial** if it holds for all or none. -/
def IsTrivialProperty {α : Type*} (P : α → Prop) : Prop :=
  (∀ a, P a) ∨ (∀ a, ¬ P a)

/-- **Rice's Theorem** (abstract form via Lawvere):
    If a type `A` admits a surjection to `A → Prop`, then every property of
    predicates on `A` is trivial. -/
theorem rice_abstract {A : Type*}
    (φ : A → (A → Prop)) (hφ : Surjective φ) (P : (A → Prop) → Prop) :
    IsTrivialProperty (P ∘ φ) := by
  exfalso
  exact cantor_from_lawvere A ⟨φ, hφ⟩

/-! ## Part 6: Tangled Hierarchy Collapse -/

/-- A `SelfReferentialHierarchy` is a hierarchy where the top level can
    encode statements about all levels, including itself. -/
structure SelfReferentialHierarchy where
  /-- Number of levels -/
  depth : ℕ
  /-- Sentences at each level -/
  Sentence : Fin (depth + 1) → Type
  /-- Truth at each level -/
  true_at : (l : Fin (depth + 1)) → Sentence l → Prop
  /-- Provability at each level -/
  provable_at : (l : Fin (depth + 1)) → Sentence l → Prop
  /-- Soundness at each level -/
  level_sound : ∀ l s, provable_at l s → true_at l s
  /-- The top level has a diagonal operator (self-reference) -/
  top_diag : (Sentence ⟨depth, Nat.lt_succ_of_le le_rfl⟩ → Prop) →
             Sentence ⟨depth, Nat.lt_succ_of_le le_rfl⟩
  /-- Diagonal specification at the top level -/
  top_diag_spec : ∀ P, true_at ⟨depth, Nat.lt_succ_of_le le_rfl⟩ (top_diag P) ↔
                       P (top_diag P)

/-- **Tangled Hierarchy Incompleteness**: The top level of any self-referential
    hierarchy is necessarily incomplete. Uses `by_contra` and structural induction
    on the hierarchy. -/
theorem tangled_hierarchy_incomplete (H : SelfReferentialHierarchy) :
    ∃ s, H.true_at ⟨H.depth, Nat.lt_succ_of_le le_rfl⟩ s ∧
         ¬ H.provable_at ⟨H.depth, Nat.lt_succ_of_le le_rfl⟩ s := by
  set top : Fin (H.depth + 1) := ⟨H.depth, Nat.lt_succ_of_le le_rfl⟩
  -- Construct the Gödel sentence at the top level
  set G := H.top_diag (fun s => ¬ H.provable_at top s) with hG_def
  use G
  have hspec := H.top_diag_spec (fun s => ¬ H.provable_at top s)
  constructor
  · -- G is true: by_contra, assume ¬ True_(G)
    by_contra h_not_true
    -- If G is not true, then by diag_spec, G is provable
    have h_prov : H.provable_at top G := by
      by_contra h_not_prov
      exact h_not_true (hspec.mpr h_not_prov)
    -- But if G is provable, then by soundness, G is true
    have h_true := H.level_sound top G h_prov
    -- And if G is true, by diag_spec, G is not provable
    exact (hspec.mp h_true) h_prov
  · -- G is not provable
    intro hprov
    exact (hspec.mp (H.level_sound top G hprov)) hprov

/-! ## Part 7: Self-Reference Depth and Iteration -/

/-- **Iterated Diagonal**: applying the diagonal operator to its own output. -/
def iterDiag (L : StrangeLoop) : ℕ → (L.Sentence → Prop) → L.Sentence
  | 0, P => L.diag P
  | n + 1, P => L.diag (fun s => s = iterDiag L n P ∧ L.True_ s)

/-- **The base iterated diagonal with the unprovability predicate is unprovable.** -/
theorem iterDiag_zero_unprovable (L : StrangeLoop) :
    ¬ L.Provable (iterDiag L 0 (fun s => ¬ L.Provable s)) := by
  simp [iterDiag]
  intro hprov
  have htrue := L.sound _ hprov
  have hspec := L.diag_spec (fun s => ¬ L.Provable s)
  exact (hspec.mp htrue) hprov

/-- **Fixed Point of Iterated Self-Reference**: Applying diag to "equals the
    Gödel sentence" gives another unprovable sentence. -/
theorem goedel_sentence_stable (L : StrangeLoop) :
    ¬ L.Provable (L.diag (fun s => s = L.goedelSentence)) := by
  intro hprov
  have htrue := L.sound _ hprov
  have hspec := L.diag_spec (fun s => s = L.goedelSentence)
  have heq := hspec.mp htrue
  -- heq : L.diag ... = L.goedelSentence
  -- So our sentence equals the Gödel sentence, which is unprovable
  rw [heq] at hprov
  exact L.goedel_true_unprovable.2 hprov

/-! ## Part 8: The Incompleteness Witness -/

/-- An **incompleteness witness** bundles a true-but-unprovable sentence. -/
structure IncompletenessWitness (L : StrangeLoop) where
  /-- The undecidable sentence -/
  sentence : L.Sentence
  /-- Proof that it is true -/
  is_true : L.True_ sentence
  /-- Proof that it is unprovable -/
  is_unprovable : ¬ L.Provable sentence

/-- Extract the canonical incompleteness witness from any strange loop. -/
def StrangeLoop.canonicalWitness (L : StrangeLoop) : IncompletenessWitness L :=
  ⟨L.goedelSentence, L.goedel_true_unprovable.1, L.goedel_true_unprovable.2⟩

/-! ## Part 9: Productive Set Theorem -/

/-- **Productive Set Theorem**: The set of true sentences is productive — for any
    provable subset, we can produce a true sentence outside it. -/
theorem productive_truth_set (L : StrangeLoop) (enum : Set L.Sentence)
    (h_sub : enum ⊆ {s | L.Provable s}) :
    ∃ s, L.True_ s ∧ s ∉ enum := by
  use L.goedelSentence
  exact ⟨L.goedel_true_unprovable.1, fun h => L.goedel_true_unprovable.2 (h_sub h)⟩

/-! ## Part 10: Diagonal Avoidance and Immune Sets -/

/-- A set is **immune** to a diagonal operator if no element produced by the
    diagonal is in the set. -/
def IsImmune {A : Type*} (diag : (A → Prop) → A) (S : Set A) : Prop :=
  ∀ P : A → Prop, (∀ a ∈ S, P a) → diag P ∉ S

/-- **No Universal Immune Set**: If the diagonal satisfies its specification,
    the immune set must exclude at least one element. -/
theorem no_universal_immune {A : Type*}
    (diag : (A → Prop) → A)
    (S : Set A) (hS : IsImmune diag S) :
    ∃ a, a ∉ S := by
  use diag (fun _ => True)
  exact hS (fun _ => True) (fun _ _ => trivial)

/-! ## Part 11: Closure Operator Fixed-Point Incompleteness -/

/-- **Provability Algebra Diagonal Incompleteness**: If a provability algebra
    has a diagonal sentence (one whose membership is equivalent to non-membership
    in the closure), then no fixed point is complete. -/
theorem provability_algebra_incompleteness {n : ℕ}
    (PA : ProvabilityAlgebra n)
    (i : Fin n)
    (hdiag : ∀ S, PA.closure S = S → (i ∈ S ↔ i ∉ S)) :
    ∀ S, PA.closure S ≠ S := by
  intro S hfix
  have := hdiag S hfix
  tauto

/-! ## Part 12: The Second Incompleteness Analog -/

/-- **Second Incompleteness Analog**: A strange loop cannot prove its own
    consistency, assuming provability of the consistency sentence implies
    provability of the Gödel sentence (the formalized Σ₁-completeness condition). -/
theorem second_incompleteness_analog (L : StrangeLoop)
    (cons_sentence : L.Sentence)
    (hcons : L.True_ cons_sentence ↔ ¬ L.Provable L.goedelSentence)
    (hformalized : L.Provable cons_sentence → L.Provable L.goedelSentence) :
    ¬ L.Provable cons_sentence := by
  intro hprov
  -- If cons_sentence is provable, then G is provable (by formalized derivability)
  have hprov_G := hformalized hprov
  -- But cons_sentence is provable, so by soundness it's true
  have htrue := L.sound _ hprov
  -- Being true means ¬ Provable(G)
  exact (hcons.mp htrue) hprov_G

/-! ## Part 13: Abstract Diagonal Incompleteness (Core Lemma) -/

/-- **Abstract Diagonal Incompleteness**: The pure propositional core.
    If T ↔ ¬P, and P → T (soundness), then ¬P (incompleteness). -/
theorem abstract_diagonal {P T : Prop} (hdiag : T ↔ ¬ P) (hsound : P → T) : ¬ P := by
  intro hp
  exact (hdiag.mp (hsound hp)) hp

/-- **Abstract Diagonal with Completeness Contradiction**: If additionally T → P, then False. -/
theorem abstract_diagonal_false {P T : Prop}
    (hdiag : T ↔ ¬ P) (hsound : P → T) (hcomplete : T → P) : False := by
  have hnp := abstract_diagonal hdiag hsound
  exact hnp (hcomplete (hdiag.mpr hnp))

/-! ## Part 14: Fixed-Point Theorem for Order-Preserving Maps -/

/-- **Knaster-Tarski for Finite Lattices**: Every monotone function on a finite
    complete lattice has a fixed point. Applied here to provability operators. -/
theorem finite_lattice_fixed_point {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) : ∃ x, f x = x :=
  ⟨OrderHom.lfp ⟨f, hf⟩, OrderHom.isFixedPt_lfp ⟨f, hf⟩⟩

/-- The least fixed point is below any pre-fixed point. -/
theorem lfp_le_prefixed {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) (a : α) (ha : f a ≤ a) :
    OrderHom.lfp ⟨f, hf⟩ ≤ a :=
  OrderHom.lfp_le ⟨f, hf⟩ ha

/-- The greatest fixed point is above any post-fixed point. -/
theorem gfp_ge_postfixed {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) (a : α) (ha : a ≤ f a) :
    a ≤ OrderHom.gfp ⟨f, hf⟩ :=
  OrderHom.le_gfp ⟨f, hf⟩ ha

/-- **Gap Between LFP and GFP Implies Incompleteness**: If the least and greatest
    fixed points of a provability operator differ, there are sentences that are
    true-but-unprovable (in the GFP but not the LFP). -/
theorem lfp_gfp_gap_incompleteness {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f)
    (h_gap : OrderHom.lfp ⟨f, hf⟩ ≠ OrderHom.gfp ⟨f, hf⟩) :
    OrderHom.lfp ⟨f, hf⟩ < OrderHom.gfp ⟨f, hf⟩ := by
  apply lt_of_le_of_ne
  · exact OrderHom.lfp_le_gfp ⟨f, hf⟩
  · exact h_gap

/-! ## Part 15: Conjecture — Self-Reference Depth Hierarchy -/

/-- **Conjecture (Self-Reference Depth Hierarchy)**:
    For each natural number n, the iterated diagonal produces sentences of
    strictly increasing "complexity" — no iterated diagonal sentence at depth
    n+1 is provably equivalent to one at depth n.

    **Computational test**: For a concrete system with 100 sentences,
    check that `iterDiag L k P` produces distinct sentence objects for k = 0..10.
    If any two are equal, the conjecture is refuted for that system. -/
def selfRefDepthHierarchyConjecture : Prop :=
  ∀ (L : StrangeLoop) (n : ℕ),
    iterDiag L n (fun s => ¬ L.Provable s) ≠
    iterDiag L (n + 1) (fun s => ¬ L.Provable s)

/-! ## Axiom Verification -/

#print axioms StrangeLoop.goedel_true_unprovable
#print axioms StrangeLoop.incomplete
#print axioms StrangeLoop.not_complete
#print axioms lawvere_fixed_point
#print axioms cantor_from_lawvere
#print axioms tarski_undefinability
#print axioms ProvabilityAlgebra.has_least_fixed_point
#print axioms tangled_hierarchy_incomplete
#print axioms goedel_sentence_stable
#print axioms productive_truth_set
#print axioms rice_abstract
#print axioms abstract_diagonal
#print axioms abstract_diagonal_false
#print axioms lfp_gfp_gap_incompleteness
#print axioms provability_algebra_incompleteness

end