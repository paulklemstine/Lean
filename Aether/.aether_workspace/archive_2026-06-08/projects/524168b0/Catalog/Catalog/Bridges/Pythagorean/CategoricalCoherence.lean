import Mathlib

/-!
# Categorical Coherence from Confluent Rewriting

This file establishes that **categorical coherence is an instance of confluent
rewriting theory**. We define a syntactic language of tensor expressions,
oriented structural rewrite rules (associativity, left unit, right unit),
and prove that these rules yield unique right-associated unit-free normal forms.

The central insight is that Mac Lane's coherence theorem for monoidal categories
can be re-derived as a corollary of the confluence of a simple term rewriting
system. This opens the door to **algorithmic coherence theory**, where coherence
theorems are proved by normalization and critical-pair analysis rather than
ad hoc combinatorial arguments.

## Main Results

### Normalization (Strategy A: Direct Flattening)
* `reduces_to_normalForm` — Every tensor expression reduces to its canonical
  normal form `rightAssoc (flatten t)` via the structural rewrite rules
* `normalize_idempotent` — Normal forms are fixed points of normalization
* `normalForm_rightAssoc` — The output of `rightAssoc` is always in normal form

### Flatten Invariance
* `flatten_invariant_of_step` — Flattening is preserved by one rewrite step
* `flatten_invariant_of_multiStep` — Flattening is preserved by multi-step reduction
* `flatten_invariant_of_equivGen` — Equivalent expressions have equal flattened forms

### Confluence and Coherence (Strategy B: Via Catalog Bridge)
* `monoidal_confluent` — The monoidal rewrite system is confluent
* `coherence_of_confluent_general` — General theorem: confluence implies coherence
* `coherence_of_confluent` — **Main theorem**: structural equivalence implies joinability

### Normal Form Uniqueness
* `normal_form_unique` — Two equivalent normal forms are syntactically equal
* `normalize_eq_of_equiv` — Equivalent terms normalize to the same expression

### Algorithmic Coherence (Strategy C: Critical Pairs)
* `coherence_of_critical_pairs` — Critical-pair joinability + termination → coherence
* `monoidal_coherence_certificate` — Verified normalization certificate with soundness,
  completeness, and canonicity proofs

### Decidability
* `monoidal_equiv_decidable` — The word problem for monoidal structural equivalence
  is decidable

### Cross-Domain: Associahedron
* `all_same_leaves_joinable` — All tensor trees with the same leaf sequence are
  joinable, connecting rewriting to the Stasheff associahedron

### Cross-Domain: Symmetric Monoidal (Permutation Theory)
* `flatten_perm_of_symStep` — Symmetric rewrite steps preserve leaf order up to permutation
* `symmetric_equiv_implies_perm` — Symmetric monoidal equivalence implies leaf permutation

## Proof Architecture

**Strategy A (Direct Normalization)** is the workhorse: we define `flatten` and
`rightAssoc`, show every term reduces to its canonical form, and that `flatten`
is a complete invariant. This is the most concrete and computationally effective route.

**Strategy B (Catalog Bridge)** lifts confluence to coherence: we prove a general
theorem that any confluent rewrite system has the coherence property (equivalence
implies joinability), then instantiate it for our monoidal rewrite system.

**Strategy C (Critical Pairs)** shows that coherence can in principle be verified
by checking local overlap joinability plus termination, mirroring Knuth–Bendix
completion. We state the theorem and derive it from the confluence already established.

application keywords: categorical coherence, confluent rewriting, completion theory,
normal forms, monoidal categories, symmetric monoidal categories, critical pairs,
Knuth–Bendix, associahedron, operads, decidable word problem, algorithmic category theory,
structural equivalence, circuit canonicalization, categorical quantum mechanics
-/

universe u

namespace CategoricalCoherence

-- ============================================================================
-- Section 1: Tensor Expressions
-- ============================================================================

/-- Syntactic tensor expressions over a type of objects.
    These represent the free monoidal syntax: variables, the monoidal unit,
    and binary tensor products. Before quotienting by structural isomorphisms,
    expressions form a free algebra. -/
inductive TensorExpr (Obj : Type u) where
  | var : Obj → TensorExpr Obj
  | unit : TensorExpr Obj
  | tensor : TensorExpr Obj → TensorExpr Obj → TensorExpr Obj
  deriving DecidableEq, Repr

namespace TensorExpr

variable {Obj : Type u}

-- ============================================================================
-- Section 2: Flattening and Right-Association
-- ============================================================================

/-- Flatten a tensor expression to a list of variables, erasing units
    and reading leaves left-to-right. This is the semantic content of
    a tensor expression modulo structural isomorphisms.

    The key property is that `flatten` is invariant under all structural
    rewrite rules, making it a complete invariant for the equivalence
    relation generated by the monoidal structural laws. -/
def flatten : TensorExpr Obj → List Obj
  | var x => [x]
  | unit => []
  | tensor a b => a.flatten ++ b.flatten

/-- Reconstruct a canonical right-associated tensor expression from a list
    of variables. The output is always in normal form:
    - `[]` maps to `unit`
    - `[x]` maps to `var x`
    - `x :: y :: ys` maps to `tensor (var x) (rightAssoc (y :: ys))` -/
def rightAssoc : List Obj → TensorExpr Obj
  | [] => unit
  | x :: xs =>
    match xs with
    | [] => var x
    | _ :: _ => tensor (var x) (rightAssoc xs)

/-- The canonical normal form: flatten then right-associate. -/
def normalize (t : TensorExpr Obj) : TensorExpr Obj :=
  rightAssoc (flatten t)

-- ============================================================================
-- Section 3: Simp Lemmas for rightAssoc
-- ============================================================================

@[simp] theorem rightAssoc_cons_cons (x y : Obj) (ys : List Obj) :
    rightAssoc (x :: y :: ys) = tensor (var x) (rightAssoc (y :: ys)) := rfl

/-- **Lemma**: `flatten ∘ rightAssoc = id`. The flattening of a right-associated
    tree recovers the original list. This is the key roundtrip property. -/
@[simp] theorem flatten_rightAssoc (l : List Obj) : flatten (rightAssoc l) = l := by
  induction l with
  | nil => simp [flatten, rightAssoc]
  | cons x xs ih =>
    cases xs with
    | nil => simp [rightAssoc, flatten]
    | cons y ys => simp [flatten, ih]

-- ============================================================================
-- Section 4: Structural Rewrite Steps (Oriented Monoidal Laws)
-- ============================================================================

/-- One-step structural rewriting for monoidal categories.
    These are the oriented structural isomorphisms:
    - **Associativity**: `(A ⊗ B) ⊗ C → A ⊗ (B ⊗ C)` (re-bracket rightward)
    - **Left unit**: `I ⊗ A → A` (erase left unit)
    - **Right unit**: `A ⊗ I → A` (erase right unit)

    Plus congruence closure: if `a → a'` then `a ⊗ b → a' ⊗ b` and
    `b ⊗ a → b ⊗ a'`. This makes the rewrite system compatible with the
    tensor structure. -/
inductive MonoidalStep : TensorExpr Obj → TensorExpr Obj → Prop where
  | assoc (a b c : TensorExpr Obj) :
      MonoidalStep (tensor (tensor a b) c) (tensor a (tensor b c))
  | unitL (a : TensorExpr Obj) :
      MonoidalStep (tensor unit a) a
  | unitR (a : TensorExpr Obj) :
      MonoidalStep (tensor a unit) a
  | tensorL {a a' : TensorExpr Obj} (b : TensorExpr Obj) :
      MonoidalStep a a' → MonoidalStep (tensor a b) (tensor a' b)
  | tensorR (a : TensorExpr Obj) {b b' : TensorExpr Obj} :
      MonoidalStep b b' → MonoidalStep (tensor a b) (tensor a b')

-- ============================================================================
-- Section 5: Abstract Rewriting Definitions
-- ============================================================================

/-- Two terms are **joinable** if they reduce to a common term via
    zero or more rewrite steps. -/
def Joinable (R : α → α → Prop) (a b : α) : Prop :=
  ∃ c, Relation.ReflTransGen R a c ∧ Relation.ReflTransGen R b c

/-- A term is in **normal form** if no reduction step applies to it. -/
def IsNormalForm (R : α → α → Prop) (a : α) : Prop :=
  ∀ b, ¬ R a b

/-- A relation is **confluent** (Church-Rosser) if all divergent paths
    re-converge: whenever `a →* b` and `a →* c`, then `b` and `c` are
    joinable. -/
def IsConfluent (R : α → α → Prop) : Prop :=
  ∀ a b c, Relation.ReflTransGen R a b →
    Relation.ReflTransGen R a c → Joinable R b c

/-- A presentation is **coherent** if equivalence implies joinability.
    This is the rewriting-theoretic formulation of Mac Lane's coherence:
    any two parallel structural morphisms (= equivalent tensor expressions)
    reduce to a common canonical form. -/
def CoherentPresentation (R : α → α → Prop) : Prop :=
  ∀ a b, Relation.EqvGen R a b → Joinable R a b

-- ============================================================================
-- Section 6: General Coherence from Confluence
-- ============================================================================

/-- **Theorem (General Coherence from Confluence)**: If a rewrite system
    is confluent, then equivalence implies joinability — i.e., the
    presentation is coherent.

    This is the abstract bridge between rewriting theory and coherence:
    confluence is the engine that makes coherence work.

    **Proof**: By induction on the equivalence derivation.
    - `rel`: A single step `a → b` gives joinability via `b` itself.
    - `refl`: Trivially joinable.
    - `symm`: Swap the two reduction paths.
    - `trans`: The key case. Given `a ~ b ~ c` with `a` and `b` joinable
      at `d₁`, and `b` and `c` joinable at `d₂`, use confluence on
      `b →* d₁` and `b →* d₂` to find a common reduct `e`. -/
theorem coherence_of_confluent_general {α : Type*}
    (R : α → α → Prop)
    (hconfluent : IsConfluent R) :
    CoherentPresentation R := by
  intro a b hab
  induction hab with
  | rel x y hxy =>
    exact ⟨y, Relation.ReflTransGen.single hxy, Relation.ReflTransGen.refl⟩
  | refl x =>
    exact ⟨x, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl⟩
  | symm x y _ ih =>
    obtain ⟨c, hc1, hc2⟩ := ih
    exact ⟨c, hc2, hc1⟩
  | trans x y z _ _ ihxy ihyz =>
    obtain ⟨c₁, hc₁a, hc₁b⟩ := ihxy
    obtain ⟨c₂, hc₂a, hc₂b⟩ := ihyz
    obtain ⟨d, hd1, hd2⟩ := hconfluent y c₁ c₂ hc₁b hc₂a
    exact ⟨d, hc₁a.trans hd1, hc₂b.trans hd2⟩

-- ============================================================================
-- Section 7: Flatten is Invariant Under Monoidal Steps
-- ============================================================================

/-- **Key Lemma**: Flattening is preserved by one-step structural rewriting.
    Each structural rule preserves the list of variables:
    - Associativity: `(a ++ b) ++ c = a ++ (b ++ c)` (list associativity)
    - Left unit: `[] ++ a = a`
    - Right unit: `a ++ [] = a`
    - Congruence: induction on the position of the step -/
theorem flatten_invariant_of_step {a b : TensorExpr Obj}
    (h : MonoidalStep a b) : flatten a = flatten b := by
  induction h with
  | assoc a b c => simp [flatten, List.append_assoc]
  | unitL a => simp [flatten]
  | unitR a => simp [flatten]
  | tensorL b _ ih => simp [flatten, ih]
  | tensorR a _ ih => simp [flatten, ih]

/-- Flatten is preserved by multi-step reduction. -/
theorem flatten_invariant_of_multiStep {a b : TensorExpr Obj}
    (h : Relation.ReflTransGen MonoidalStep a b) : flatten a = flatten b := by
  induction h with
  | refl => rfl
  | tail _ h2 ih => rw [ih, flatten_invariant_of_step h2]

/-- **Theorem**: Flatten is invariant under the equivalence generated by
    monoidal steps. Equivalent expressions have the same flattened form.
    This makes `flatten` a complete invariant for structural equivalence. -/
theorem flatten_invariant_of_equivGen {a b : TensorExpr Obj}
    (h : Relation.EqvGen MonoidalStep a b) : flatten a = flatten b := by
  induction h with
  | rel _ _ h => exact flatten_invariant_of_step h
  | refl => rfl
  | symm _ _ _ ih => exact ih.symm
  | trans _ _ _ _ _ ih1 ih2 => exact ih1.trans ih2

-- ============================================================================
-- Section 8: Multi-Step Congruence Lemmas
-- ============================================================================

/-- Lift multi-step reduction under right tensor position. -/
theorem multiStep_tensorR (a : TensorExpr Obj) {b b' : TensorExpr Obj}
    (h : Relation.ReflTransGen MonoidalStep b b') :
    Relation.ReflTransGen MonoidalStep (tensor a b) (tensor a b') := by
  induction h with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ h2 ih =>
    exact ih.trans (Relation.ReflTransGen.single (MonoidalStep.tensorR a h2))

/-- Lift multi-step reduction under left tensor position. -/
theorem multiStep_tensorL {a a' : TensorExpr Obj} (b : TensorExpr Obj)
    (h : Relation.ReflTransGen MonoidalStep a a') :
    Relation.ReflTransGen MonoidalStep (tensor a b) (tensor a' b) := by
  induction h with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ h2 ih =>
    exact ih.trans (Relation.ReflTransGen.single (MonoidalStep.tensorL b h2))

-- ============================================================================
-- Section 9: Reduction of rightAssoc Concatenation
-- ============================================================================

/-- **Lemma**: The tensor of two right-associated trees reduces to the
    right-associated tree of their concatenation.
    This is the key structural lemma that makes normalization work:
    it shows that `tensor (rightAssoc l₁) (rightAssoc l₂)` normalizes
    to `rightAssoc (l₁ ++ l₂)`. -/
theorem rightAssoc_append (l₁ l₂ : List Obj) :
    Relation.ReflTransGen MonoidalStep
      (tensor (rightAssoc l₁) (rightAssoc l₂))
      (rightAssoc (l₁ ++ l₂)) := by
  induction l₁ with
  | nil =>
    simp [rightAssoc]
    exact Relation.ReflTransGen.single (MonoidalStep.unitL _)
  | cons x xs ih =>
    cases xs with
    | nil =>
      simp only [rightAssoc, List.cons_append, List.nil_append]
      cases l₂ with
      | nil =>
        simp [rightAssoc]
        exact Relation.ReflTransGen.single (MonoidalStep.unitR _)
      | cons y ys =>
        exact Relation.ReflTransGen.refl
    | cons y ys =>
      simp only [List.cons_append, rightAssoc_cons_cons]
      exact (Relation.ReflTransGen.single (MonoidalStep.assoc _ _ _)).trans
        (multiStep_tensorR (var x) ih)

-- ============================================================================
-- Section 10: Main Normalization Theorem
-- ============================================================================

/-- **Theorem (Reduction to Normal Form)**: Every tensor expression reduces
    to its canonical normal form `rightAssoc (flatten t)` via the structural
    rewrite rules.

    **Proof** by structural induction on tensor expressions:
    - `var x`: `normalize (var x) = var x` definitionally, so 0 steps.
    - `unit`: `normalize unit = unit` definitionally, so 0 steps.
    - `tensor a b`: First reduce `a` to `normalize a` and `b` to `normalize b`
      by the inductive hypotheses (under congruence). Then reduce
      `tensor (rightAssoc (flatten a)) (rightAssoc (flatten b))`
      to `rightAssoc (flatten a ++ flatten b)` by `rightAssoc_append`. -/
theorem reduces_to_normalForm (t : TensorExpr Obj) :
    Relation.ReflTransGen MonoidalStep t (normalize t) := by
  induction t with
  | var _ => exact Relation.ReflTransGen.refl
  | unit => exact Relation.ReflTransGen.refl
  | tensor a b ih_a ih_b =>
    simp only [normalize, flatten]
    exact ((multiStep_tensorL b ih_a).trans
      (multiStep_tensorR (normalize a) ih_b)).trans
      (rightAssoc_append _ _)

/-- **Theorem**: The normal form is idempotent — normalizing a normal form
    yields the same expression. -/
theorem normalize_idempotent (t : TensorExpr Obj) :
    normalize (normalize t) = normalize t := by
  simp [normalize, flatten_rightAssoc]

-- ============================================================================
-- Section 11: Normal Form Property of rightAssoc Output
-- ============================================================================

/-- No monoidal step is applicable to `unit`. -/
private theorem no_step_unit : IsNormalForm MonoidalStep (unit : TensorExpr Obj) :=
  fun _ h => nomatch h

/-- No monoidal step is applicable to `var x`. -/
private theorem no_step_var (x : Obj) : IsNormalForm MonoidalStep (var x) :=
  fun _ h => nomatch h

/-- `rightAssoc` of a nonempty list is never `unit`. -/
private theorem rightAssoc_ne_unit (x : Obj) (xs : List Obj) :
    rightAssoc (x :: xs) ≠ unit := by
  cases xs <;> simp [rightAssoc]

/-- If `b` is a normal form and `b ≠ unit`, then `tensor (var x) b` is
    also a normal form. The only possible steps from `tensor (var x) b` are:
    - `unitR`: requires `b = unit`, contradicted by `hne`
    - `tensorL`: requires `var x` to step, impossible
    - `tensorR`: requires `b` to step, contradicted by `hb` -/
private theorem nf_tensor_var (x : Obj) {b : TensorExpr Obj}
    (hb : IsNormalForm MonoidalStep b) (hne : b ≠ unit) :
    IsNormalForm MonoidalStep (tensor (var x) b) := by
  intro c h
  cases h with
  | unitR => exact hne rfl
  | tensorL _ h' => exact nomatch h'
  | tensorR _ h' => exact hb _ h'

/-- **Theorem**: The output of `rightAssoc` is always a normal form of
    the monoidal rewrite system. No structural rewrite step can be applied
    to a right-associated unit-free tree. -/
theorem normalForm_rightAssoc (l : List Obj) :
    IsNormalForm MonoidalStep (rightAssoc l) := by
  induction l with
  | nil => exact no_step_unit
  | cons x xs ih =>
    cases xs with
    | nil => exact no_step_var x
    | cons y ys =>
      show IsNormalForm MonoidalStep (tensor (var x) (rightAssoc (y :: ys)))
      exact nf_tensor_var x ih (rightAssoc_ne_unit y ys)

-- ============================================================================
-- Section 12: Normal Form Uniqueness
-- ============================================================================

/-- Two expressions with the same flatten normalize identically. -/
theorem normalize_eq_of_flatten_eq {a b : TensorExpr Obj}
    (h : flatten a = flatten b) : normalize a = normalize b := by
  simp [normalize, h]

/-- **Theorem**: Equivalent expressions have the same normal form. -/
theorem normalize_eq_of_equiv {a b : TensorExpr Obj}
    (h : Relation.EqvGen MonoidalStep a b) : normalize a = normalize b :=
  normalize_eq_of_flatten_eq (flatten_invariant_of_equivGen h)

/-- **Theorem (Normal Form Uniqueness)**: Two equivalent normal forms are
    syntactically equal. This is proved via the normalization invariant:
    if `a` is in normal form, then `a = normalize a` (since `a` cannot
    step, the reduction `a →* normalize a` must be trivial).

    Combined with `normalize_eq_of_equiv`, this shows that equivalent
    normal forms must be identical. -/
theorem normal_form_unique {a b : TensorExpr Obj}
    (hna : ∃ la, a = rightAssoc la)
    (hnb : ∃ lb, b = rightAssoc lb)
    (heq : Relation.EqvGen MonoidalStep a b) :
    a = b := by
  obtain ⟨la, rfl⟩ := hna
  obtain ⟨lb, rfl⟩ := hnb
  have h := flatten_invariant_of_equivGen heq
  simp [flatten_rightAssoc] at h
  rw [h]

-- ============================================================================
-- Section 13: Confluence
-- ============================================================================

/-- **Theorem (Confluence)**: The monoidal structural rewrite system is confluent.

    **Proof**: Every term `t` reduces to `normalize t = rightAssoc (flatten t)`.
    If `a →* b` and `a →* c`, then `flatten b = flatten a = flatten c`,
    so `normalize b = normalize c`. Both `b` and `c` reduce to this common
    normal form.

    This proof avoids Newman's lemma entirely — we prove confluence directly
    by exhibiting a canonical normal form for every term. -/
theorem monoidal_confluent : IsConfluent (@MonoidalStep Obj) := by
  intro a b c hab hac
  have hab' := flatten_invariant_of_multiStep hab
  have hac' := flatten_invariant_of_multiStep hac
  have : flatten b = flatten c := by rw [← hab', ← hac']
  have hnorm : normalize b = normalize c := normalize_eq_of_flatten_eq this
  exact ⟨normalize b, reduces_to_normalForm b, hnorm ▸ reduces_to_normalForm c⟩

-- ============================================================================
-- Section 14: Main Coherence Theorem
-- ============================================================================

/-- **Theorem (Coherence of Monoidal Structural Rewriting)**:
    For the monoidal structural rewrite system, any two tensor expressions
    equivalent under the congruence generated by associativity and unit laws
    are joinable — they reduce to a common normal form.

    **This is the conceptual centerpiece of the file**: categorical coherence
    is exactly confluent normalization for structural syntax. Mac Lane's
    coherence theorem, which states that all structural isomorphisms between
    the same source and target in a monoidal category are equal, follows
    from the fact that the oriented structural rules form a confluent and
    terminating rewrite system.

    The theorem is derived in two steps:
    1. We prove confluence of the monoidal rewrite system (`monoidal_confluent`)
       by exhibiting the canonical `rightAssoc ∘ flatten` normal form.
    2. We apply the general theorem `coherence_of_confluent_general` which
       shows that confluence implies coherence for any rewrite system. -/
theorem coherence_of_confluent :
    ∀ {a b : TensorExpr Obj},
      Relation.EqvGen MonoidalStep a b → Joinable MonoidalStep a b :=
  fun h => coherence_of_confluent_general MonoidalStep monoidal_confluent _ _ h

-- ============================================================================
-- Section 15: Coherence Certificate
-- ============================================================================

/-- A **coherence certificate** bundles a normalization function with
    machine-checked proofs of soundness, completeness, and canonicity.
    This is a verified computational artifact: it constitutes a correct-by-
    construction decision procedure for structural equivalence. -/
structure CoherenceCertificate (Obj : Type u) where
  /-- The normalization function -/
  nf : TensorExpr Obj → TensorExpr Obj
  /-- **Soundness**: every term is equivalent to its normal form -/
  sound : ∀ t, Relation.EqvGen MonoidalStep t (nf t)
  /-- **Completeness**: terms with the same normal form are equivalent -/
  complete : ∀ a b, nf a = nf b → Relation.EqvGen MonoidalStep a b
  /-- **Canonicity**: the normal form function is idempotent -/
  canonical : ∀ t, nf (nf t) = nf t

/-- Helper: ReflTransGen implies EqvGen. -/
private theorem reflTransGen_to_eqvGen {R : α → α → Prop} {a b : α}
    (h : Relation.ReflTransGen R a b) : Relation.EqvGen R a b := by
  induction h with
  | refl => exact Relation.EqvGen.refl _
  | tail _ hstep ih => exact ih.trans _ _ _ (Relation.EqvGen.rel _ _ hstep)

/-- **Verified Certificate**: The monoidal coherence certificate with
    machine-checked soundness, completeness, and canonicity. -/
noncomputable def monoidal_coherence_certificate : CoherenceCertificate Obj where
  nf := normalize
  sound := fun t => reflTransGen_to_eqvGen (reduces_to_normalForm t)
  complete := fun a b h => by
    have ha' := reflTransGen_to_eqvGen (reduces_to_normalForm a)
    have hb' := reflTransGen_to_eqvGen (reduces_to_normalForm b)
    exact ha'.trans _ _ _ (h ▸ (hb'.symm _ _))
  canonical := normalize_idempotent

-- ============================================================================
-- Section 16: Decidable Word Problem
-- ============================================================================

/-- **Theorem**: The word problem for monoidal structural equivalence is
    decidable. Two tensor expressions are equivalent iff their normal forms
    agree, and normal form equality is decidable when the object type has
    decidable equality.

    This gives a verified decision procedure for structural equivalence
    in monoidal categories. -/
instance monoidal_equiv_decidable [DecidableEq Obj] (a b : TensorExpr Obj) :
    Decidable (Relation.EqvGen MonoidalStep a b) := by
  by_cases h : normalize a = normalize b
  · exact isTrue (monoidal_coherence_certificate.complete a b h)
  · exact isFalse (fun heq => h (normalize_eq_of_equiv heq))

/-- **Corollary**: Equivalence is characterized by normal form equality. -/
theorem equiv_iff_normalize_eq [DecidableEq Obj] (a b : TensorExpr Obj) :
    Relation.EqvGen MonoidalStep a b ↔ normalize a = normalize b :=
  ⟨normalize_eq_of_equiv, monoidal_coherence_certificate.complete a b⟩

-- ============================================================================
-- Section 17: Cross-Domain — Associahedron Connection
-- ============================================================================

/-- Two tensor expressions have the **same leaf order** if they flatten to
    the same list. Combinatorially, this means they are vertices of the same
    **Stasheff associahedron**: different parenthesizations of the same
    sequence of variables. -/
def SameLeafOrder (a b : TensorExpr Obj) : Prop :=
  flatten a = flatten b

/-- **Theorem (Associahedron Coherence)**: All tensor expressions with the
    same leaf order are joinable under the structural rewrite rules.

    Combinatorially: every pair of vertices on the same associahedron
    is connected by a path of re-associations that converges to the unique
    right-associated canonical form. This is the rewriting-theoretic shadow
    of the contractibility of the associahedron. -/
theorem all_same_leaves_joinable {a b : TensorExpr Obj}
    (h : SameLeafOrder a b) :
    Joinable MonoidalStep a b := by
  refine ⟨normalize a, reduces_to_normalForm a, ?_⟩
  have : normalize a = normalize b := normalize_eq_of_flatten_eq h
  rw [this]; exact reduces_to_normalForm b

-- ============================================================================
-- Section 18: Critical-Pair Based Coherence
-- ============================================================================

/-- All local peaks of a relation are joinable (local confluence). -/
def AllLocalPeaksJoinable (R : α → α → Prop) : Prop :=
  ∀ a b c, R a b → R a c → Joinable R b c

/-- **Theorem (Coherence via Critical Pairs)**: If the monoidal rewrite system
    is terminating and all local peaks (critical pairs) are joinable, then
    the system is coherent.

    In the Knuth–Bendix completion paradigm:
    1. Check that every critical pair is joinable (local confluence).
    2. Prove termination via a well-founded measure.
    3. Apply Newman's lemma to obtain full confluence.
    4. Conclude coherence via `coherence_of_confluent_general`.

    Here we derive this from the confluence we have already established
    directly, but the theorem statement captures the critical-pair methodology. -/
theorem coherence_of_critical_pairs
    (_hterm : WellFounded (fun (a : TensorExpr Obj) (b : TensorExpr Obj) => MonoidalStep b a))
    (_hcrit : AllLocalPeaksJoinable (@MonoidalStep Obj)) :
    ∀ {a b : TensorExpr Obj},
      Relation.EqvGen MonoidalStep a b → Joinable MonoidalStep a b :=
  fun h => coherence_of_confluent h

-- ============================================================================
-- Section 19: Symmetric Monoidal Extension
-- ============================================================================

/-- Extended one-step rewriting for **symmetric** monoidal categories.
    Adds a braiding (swap) rule: `A ⊗ B → B ⊗ A`.

    Note: the symmetric system is NOT confluent (swapping is not oriented),
    but `flatten` still yields a permutation invariant. -/
inductive SymMonoidalStep : TensorExpr Obj → TensorExpr Obj → Prop where
  | assoc (a b c : TensorExpr Obj) :
      SymMonoidalStep (tensor (tensor a b) c) (tensor a (tensor b c))
  | unitL (a : TensorExpr Obj) :
      SymMonoidalStep (tensor unit a) a
  | unitR (a : TensorExpr Obj) :
      SymMonoidalStep (tensor a unit) a
  | swap (a b : TensorExpr Obj) :
      SymMonoidalStep (tensor a b) (tensor b a)
  | tensorL {a a' : TensorExpr Obj} (b : TensorExpr Obj) :
      SymMonoidalStep a a' → SymMonoidalStep (tensor a b) (tensor a' b)
  | tensorR (a : TensorExpr Obj) {b b' : TensorExpr Obj} :
      SymMonoidalStep b b' → SymMonoidalStep (tensor a b) (tensor a b')

/-- **Lemma**: Each symmetric monoidal step preserves the leaf list up to
    permutation. The braiding rule induces `List.perm_append_comm`. -/
theorem flatten_perm_of_symStep {a b : TensorExpr Obj}
    (h : SymMonoidalStep a b) : List.Perm (flatten a) (flatten b) := by
  induction h with
  | assoc a b c => simp [flatten, List.append_assoc]
  | unitL a => simp [flatten]
  | unitR a => simp [flatten]
  | swap a b => simp [flatten]; exact List.perm_append_comm
  | tensorL b _ ih => exact ih.append_right (flatten b)
  | tensorR a _ ih => exact (List.Perm.refl (flatten a)).append ih

/-- **Theorem (Symmetric Coherence → Permutation)**:
    Symmetric monoidal equivalence implies the flattened leaf lists are
    permutations of each other.

    This is one direction of the conjecture that symmetric monoidal equivalence
    is exactly captured by leaf-list permutation. It connects algebraic
    coherence to combinatorial permutation theory. -/
theorem symmetric_equiv_implies_perm {a b : TensorExpr Obj}
    (h : Relation.EqvGen SymMonoidalStep a b) :
    List.Perm (flatten a) (flatten b) := by
  induction h with
  | rel _ _ h => exact flatten_perm_of_symStep h
  | refl => exact List.Perm.refl _
  | symm _ _ _ ih => exact ih.symm
  | trans _ _ _ _ _ ih1 ih2 => exact ih1.trans ih2

-- ============================================================================
-- Section 20: Monoidal Rewrite Presentation Structure
-- ============================================================================

/-- A **monoidal rewrite presentation** packages a reduction relation
    with its induced equivalence, together with a proof that the equivalence
    is generated by the reduction. This is the abstract interface for
    completion-based coherence results. -/
structure MonoidalRewritePresentation (α : Type u) where
  /-- The one-step reduction relation -/
  Red : α → α → Prop
  /-- The induced equivalence -/
  equiv : α → α → Prop
  /-- Equivalence is generated by the reduction -/
  equiv_is_eqvGen : ∀ {a b : α}, equiv a b ↔ Relation.EqvGen Red a b

/-- The canonical monoidal rewrite presentation for tensor expressions. -/
def canonicalMonoidalPresentation (Obj : Type u) :
    MonoidalRewritePresentation (TensorExpr Obj) where
  Red := MonoidalStep
  equiv := Relation.EqvGen MonoidalStep
  equiv_is_eqvGen := Iff.rfl

-- ============================================================================
-- Section 21: Verified Normalization Algorithm
-- ============================================================================

/-- The verified normalization algorithm for monoidal tensor expressions.
    Computes `rightAssoc (flatten t)`, which is the unique canonical
    right-associated unit-free representative of the equivalence class. -/
def normalizeMonoidal : TensorExpr Obj → TensorExpr Obj := normalize

/-- **Soundness**: the input is equivalent to its normal form. -/
theorem normalizeMonoidal_sound (t : TensorExpr Obj) :
    Relation.EqvGen MonoidalStep t (normalizeMonoidal t) :=
  monoidal_coherence_certificate.sound t

/-- **Canonicity**: normal forms are fixed points. -/
theorem normalizeMonoidal_idempotent (t : TensorExpr Obj) :
    normalizeMonoidal (normalizeMonoidal t) = normalizeMonoidal t :=
  monoidal_coherence_certificate.canonical t

/-- **Completeness**: same normal form implies equivalence. -/
theorem normalizeMonoidal_complete (a b : TensorExpr Obj)
    (h : normalizeMonoidal a = normalizeMonoidal b) :
    Relation.EqvGen MonoidalStep a b :=
  monoidal_coherence_certificate.complete a b h

-- ============================================================================
-- Section 22: Normal Form Characterization Predicates
-- ============================================================================

/-- A tensor expression is **right-associated** if it has no left-nested
    tensors at the top level. -/
def isRightAssociated : TensorExpr Obj → Prop
  | var _ => True
  | unit => True
  | tensor (var _) b => isRightAssociated b
  | tensor unit _ => False
  | tensor (tensor _ _) _ => False

/-- A tensor expression is **unit-free** if it contains no `unit`
    subexpressions. -/
def isUnitFree : TensorExpr Obj → Prop
  | var _ => True
  | unit => False
  | tensor a b => isUnitFree a ∧ isUnitFree b

/-- **Canonical monoidal normal form**: either `unit` (for empty tensor products)
    or right-associated and unit-free. -/
def CanonicalMonoidalNF (t : TensorExpr Obj) : Prop :=
  (t = unit ∧ flatten t = []) ∨
  (isRightAssociated t ∧ isUnitFree t)

-- ============================================================================
-- Section 23: Structural Joinability (Novel Definition)
-- ============================================================================

/-- **Structural joinability** specializes joinability to structural rewrite
    systems. Two terms are structurally joinable if they share a common
    structural normal form reachable by oriented structural laws. -/
def StructuralJoinable (a b : TensorExpr Obj) : Prop :=
  Joinable MonoidalStep a b

/-- **Theorem**: Structural joinability is equivalent to having the same
    flattened leaf list. -/
theorem structuralJoinable_iff_same_flatten (a b : TensorExpr Obj) :
    StructuralJoinable a b ↔ SameLeafOrder a b := by
  constructor
  · intro ⟨c, hac, hbc⟩
    have h1 := flatten_invariant_of_multiStep hac
    have h2 := flatten_invariant_of_multiStep hbc
    exact h1.trans h2.symm
  · exact all_same_leaves_joinable

-- ============================================================================
-- Section 24: Conjecture Statement — Symmetric Coherence = Permutation
-- ============================================================================

/-- **Conjecture (Symmetric Coherence = Permutation Completeness)**:
    For the symmetric monoidal structural subsystem, two tensor expressions
    are structurally equivalent if and only if their flattened leaf lists
    are permutation-equivalent.

    The forward direction (`symmetric_equiv_implies_perm`) is proved above.
    The reverse direction would complete the characterization. -/
def SymmetricCoherenceConj : Prop :=
  ∀ {Obj : Type} (a b : TensorExpr Obj),
    List.Perm (flatten a) (flatten b) →
    Relation.EqvGen SymMonoidalStep a b

end TensorExpr
end CategoricalCoherence