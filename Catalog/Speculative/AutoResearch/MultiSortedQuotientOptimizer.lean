import Mathlib

/-!
# The Interaction Principle: Multi-Sorted Quotient Optimizers

## Overview

This file formalizes the **Interaction Principle** for multi-sorted quotient
optimization: when algebraic operations mix elements from different sorts
(e.g., scalar multiplication `R × M → M`), normalizing only *some* sorts
still preserves evaluation correctness, mediated by the compatibility condition
of sort-indexed congruences.

This phenomenon has **no single-sorted analogue**. In a single-sorted algebra,
normalization either applies or doesn't. In multi-sorted algebras, partial
normalization creates *derived* identities on inactive sorts through the
interaction of mixed-sort operations with the congruence.

## Main Definitions

- `MultiSortedSig`: A multi-sorted algebraic signature
- `MultiSortedAlg`: An algebra over a multi-sorted signature
- `SortCongruence`: A sort-indexed family of equivalence relations compatible
  with all operations
- `MSTerm`: Well-sorted terms over a multi-sorted signature
- `msEval`: Evaluation of well-sorted terms in an algebra
- `PartialNormalizer`: A normalizer active on a subset of sorts
- `congruenceDist`: The discrete pseudometric induced by a congruence

## Main Results

1. `sort_interaction_lemma`: Normalizing arguments preserves the congruence class
   of the result for any operation, even mixed-sort ones.
2. `partial_norm_preserves_eval`: Partial normalization preserves evaluation
   up to congruence, proven by structural induction on well-sorted terms.
3. `interaction_coherence`: When an actively-normalized sort feeds into a
   mixed-sort operation, the result is congruent to the unnormalized result.
4. `compatibility_propagation`: Replacing a single congruent argument in an
   operation preserves congruence of the result.
5. `operation_nonexpanding`: Operations are nonexpanding (1-Lipschitz) with
   respect to the discrete congruence metric.

## Cross-Domain Connections

- **Algebra → Topology**: Sort congruences induce pseudometrics making all
  operations nonexpanding (Theorem 4).
- **Universal Algebra → Compiler Optimization**: Partial normalization models
  type-directed optimization passes in compilers.
- **Universal Algebra → Representation Theory**: The module-over-ring example
  is the starting point of representation theory.
-/

noncomputable section

open Classical

/-! ## Section 1: Multi-Sorted Signatures and Algebras -/

/-- A **multi-sorted algebraic signature** specifies a collection of operation
symbols, each with a list of input sorts and a result sort. This is the standard
notion from universal algebra, generalizing single-sorted signatures to handle
operations that mix elements of different types. -/
structure MultiSortedSig (σ : Type*) where
  /-- The type of operation symbols. -/
  ops : Type*
  /-- The input sorts for each operation (as a list). -/
  arity : ops → List σ
  /-- The result sort for each operation. -/
  resultSort : ops → σ

/-- A **multi-sorted algebra** interprets each sort as a carrier type and each
operation symbol as a function from the product of input carriers to the result
carrier. -/
structure MultiSortedAlg {σ : Type*} (S : MultiSortedSig σ) where
  /-- The carrier type for each sort. -/
  carrier : σ → Type*
  /-- The interpretation of each operation. -/
  interp : (f : S.ops) →
    ((i : Fin (S.arity f).length) → carrier ((S.arity f).get i)) →
    carrier (S.resultSort f)

/-! ## Section 2: Sort-Indexed Congruences -/

/-- A **sort congruence** on a multi-sorted algebra is a family of equivalence
relations (one per sort) that is compatible with all operations: if each argument
is related to a corresponding argument, then the results are related.

This compatibility condition is the key to the Interaction Principle: it ensures
that normalizing arguments of one sort propagates correctness through mixed-sort
operations to other sorts. -/
structure SortCongruence {σ : Type*} {S : MultiSortedSig σ} (A : MultiSortedAlg S) where
  /-- The equivalence relation on each sort's carrier. -/
  rel : ∀ s : σ, A.carrier s → A.carrier s → Prop
  /-- Each relation is an equivalence relation. -/
  is_equiv : ∀ s, Equivalence (rel s)
  /-- Operations respect the congruence: congruent inputs give congruent outputs. -/
  compatible : ∀ (f : S.ops)
    (args₁ args₂ : (i : Fin (S.arity f).length) → A.carrier ((S.arity f).get i)),
    (∀ i, rel ((S.arity f).get i) (args₁ i) (args₂ i)) →
    rel (S.resultSort f) (A.interp f args₁) (A.interp f args₂)

namespace SortCongruence

variable {σ : Type*} {S : MultiSortedSig σ} {A : MultiSortedAlg S}

/-- Reflexivity of the sort congruence. -/
theorem refl (C : SortCongruence A) (s : σ) (x : A.carrier s) : C.rel s x x :=
  (C.is_equiv s).refl x

/-- Symmetry of the sort congruence. -/
theorem symm (C : SortCongruence A) (s : σ) {x y : A.carrier s}
    (h : C.rel s x y) : C.rel s y x :=
  (C.is_equiv s).symm h

/-- Transitivity of the sort congruence. -/
theorem trans (C : SortCongruence A) (s : σ) {x y z : A.carrier s}
    (h₁ : C.rel s x y) (h₂ : C.rel s y z) : C.rel s x z :=
  (C.is_equiv s).trans h₁ h₂

end SortCongruence

/-! ## Section 3: Well-Sorted Terms -/

/-- **Well-sorted terms** over a multi-sorted signature. Each term is either:
- A variable of a given sort (indexed by a natural number), or
- An operation applied to a tuple of subterms of the correct sorts. -/
inductive MSTerm {σ : Type*} (S : MultiSortedSig σ) : σ → Type _
  | var (s : σ) (n : ℕ) : MSTerm S s
  | app (f : S.ops) (args : ∀ i : Fin (S.arity f).length, MSTerm S ((S.arity f).get i)) :
      MSTerm S (S.resultSort f)

/-- An **environment** assigns values to variables, indexed by sort and variable number. -/
def MSEnv {σ : Type*} {S : MultiSortedSig σ} (A : MultiSortedAlg S) :=
  ∀ s : σ, ℕ → A.carrier s

/-- **Evaluation** of a well-sorted term in an algebra given an environment.
This is defined by structural recursion:
- Variables look up their value in the environment.
- Operations apply the algebra's interpretation to the evaluated subterms. -/
def msEval {σ : Type*} {S : MultiSortedSig σ} {A : MultiSortedAlg S}
    (env : MSEnv A) : {s : σ} → MSTerm S s → A.carrier s
  | _, MSTerm.var s n => env s n
  | _, MSTerm.app f args => A.interp f (fun i => msEval env (args i))

/-! ## Section 4: Sort-Indexed Normalization -/

/-- A **sort-indexed normalizer** provides a normalization function for each sort. -/
structure SortNorm {σ : Type*} {S : MultiSortedSig σ} (A : MultiSortedAlg S) where
  /-- The normalization function for each sort. -/
  norm : ∀ s : σ, A.carrier s → A.carrier s

/-- Apply a sort normalizer to an environment: normalize every variable's value. -/
def normEnv {σ : Type*} {S : MultiSortedSig σ} {A : MultiSortedAlg S}
    (N : SortNorm A) (env : MSEnv A) : MSEnv A :=
  fun s n => N.norm s (env s n)

/-- A **partial normalizer** is a sort normalizer equipped with:
- A predicate `active` specifying which sorts are actively normalized.
- Soundness: normalization preserves the congruence class.
- Idempotence on active sorts.
- Identity on inactive sorts. -/
structure PartialNormalizer {σ : Type*} {S : MultiSortedSig σ}
    (A : MultiSortedAlg S) (C : SortCongruence A) extends SortNorm A where
  /-- Which sorts are actively normalized. -/
  active : σ → Prop
  /-- Decidability of the active predicate. -/
  [active_dec : DecidablePred active]
  /-- Normalization preserves the congruence class on every sort. -/
  norm_sound : ∀ (s : σ) (x : A.carrier s), C.rel s (norm s x) x
  /-- Normalization is idempotent on active sorts. -/
  norm_idem : ∀ (s : σ), active s → ∀ x : A.carrier s, norm s (norm s x) = norm s x
  /-- Normalization is the identity on inactive sorts. -/
  norm_inactive : ∀ (s : σ), ¬active s → ∀ x : A.carrier s, norm s x = x

/-! ## Section 5: The Compatibility Propagation Theorem -/

/-- Replace a single argument in a tuple at position `pos`, keeping all others. -/
def replaceArgAt {σ : Type*} {S : MultiSortedSig σ} {A : MultiSortedAlg S}
    {f : S.ops}
    (args : ∀ i : Fin (S.arity f).length, A.carrier ((S.arity f).get i))
    (pos : Fin (S.arity f).length)
    (val : A.carrier ((S.arity f).get pos)) :
    ∀ i : Fin (S.arity f).length, A.carrier ((S.arity f).get i) :=
  fun i =>
    if h : i = pos then h ▸ val else args i

/-
**Compatibility Propagation Theorem**: Replacing a single argument with a
congruent value preserves congruence of the operation's result. This is the
algebraic shadow of the topological fact that a quotient map composed with a
continuous map factors through the quotient.
-/
theorem compatibility_propagation {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S} (C : SortCongruence A)
    (f : S.ops)
    (args : ∀ i : Fin (S.arity f).length, A.carrier ((S.arity f).get i))
    (pos : Fin (S.arity f).length)
    (val : A.carrier ((S.arity f).get pos))
    (h_rel : C.rel ((S.arity f).get pos) val (args pos)) :
    C.rel (S.resultSort f) (A.interp f (replaceArgAt args pos val))
                           (A.interp f args) := by
  convert C.compatible f ( replaceArgAt args pos val ) args _ using 1;
  intro i; by_cases hi : i = pos <;> simp_all +decide [ replaceArgAt ] ;
  · grind;
  · exact C.is_equiv _ |>.refl _

/-! ## Section 6: The Sort Interaction Lemma -/

/-- Normalize all arguments of an operation using a sort normalizer. -/
def normArgs {σ : Type*} {S : MultiSortedSig σ} {A : MultiSortedAlg S}
    (N : SortNorm A) {f : S.ops}
    (args : ∀ i : Fin (S.arity f).length, A.carrier ((S.arity f).get i)) :
    ∀ i : Fin (S.arity f).length, A.carrier ((S.arity f).get i) :=
  fun i => N.norm ((S.arity f).get i) (args i)

/-
**The Sort Interaction Lemma**: For any operation, normalizing all arguments
preserves the congruence class of the result. This is the fundamental fact with
no single-sorted analogue: when an operation mixes sorts, normalization on one
sort propagates through the operation to affect the result's sort, mediated
entirely by the compatibility condition.

This is proven using the compatibility condition pointwise: each normalized
argument is congruent to the original, so by compatibility, the result with
normalized arguments is congruent to the result with original arguments.
-/
theorem sort_interaction_lemma {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S} {C : SortCongruence A}
    (N : SortNorm A)
    (h_sound : ∀ (s : σ) (x : A.carrier s), C.rel s (N.norm s x) x)
    (f : S.ops)
    (args : ∀ i : Fin (S.arity f).length, A.carrier ((S.arity f).get i)) :
    C.rel (S.resultSort f) (A.interp f (normArgs N args)) (A.interp f args) := by
  exact C.compatible f ( fun i => N.norm ( ( S.arity f ).get i ) ( args i ) ) args fun i => h_sound _ _

/-! ## Section 7: Partial Normalization Preserves Evaluation -/

/-
**The Main Theorem**: Evaluating a term in a normalized environment gives a
result congruent to the normalization of the evaluation in the original
environment.

More precisely, for any well-sorted term `t` of sort `s`:
  `C.rel s (msEval (normEnv N env) t) (N.norm s (msEval env t))`

This holds for ALL sorts, whether active or inactive:
- For active sorts, normalization applies nontrivially.
- For inactive sorts, `N.norm s = id`, so this reduces to showing that
  evaluation in the normalized environment is congruent to evaluation in
  the original environment.

The proof is by structural induction on the term `t`:
- **Variable case**: Immediate from the definition of `normEnv`.
- **Application case**: Uses the sort interaction lemma to propagate
  normalization through the operation, and the induction hypothesis to
  handle subterms.
-/
theorem partial_norm_preserves_eval {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S} {C : SortCongruence A}
    (N : PartialNormalizer A C) (env : MSEnv A) :
    ∀ {s : σ} (t : MSTerm S s),
    C.rel s (msEval (normEnv N.toSortNorm env) t) (N.norm s (msEval env t)) := by
  intro s t;
  induction' t with s n f args ih;
  · exact C.is_equiv s |>.refl _;
  · -- By the sort interaction lemma, we have:
    have h_sort_interaction : C.rel (S.resultSort f) (A.interp f (fun i => msEval (normEnv N.toSortNorm env) (args i))) (A.interp f (fun i => N.norm ((S.arity f).get i) (msEval env (args i)))) := by
      exact C.compatible f _ _ ih;
    -- By the compatibility of the congruence relation with the operation, we can combine the results from the induction hypothesis and the sort interaction lemma.
    have h_compatibility : C.rel (S.resultSort f) (A.interp f (fun i => N.norm ((S.arity f).get i) (msEval env (args i)))) (A.interp f (fun i => msEval env (args i))) := by
      apply sort_interaction_lemma N.toSortNorm N.norm_sound f (fun i => msEval env (args i));
    have := N.norm_sound ( S.resultSort f ) ( A.interp f fun i => msEval env ( args i ) );
    exact C.is_equiv _ |>.symm this |> fun h => C.is_equiv _ |>.trans ( C.is_equiv _ |>.trans h_sort_interaction h_compatibility ) h

/-! ## Section 8: Interaction Coherence -/

/-
**Interaction Coherence Theorem**: When an actively-normalized sort feeds
into a mixed-sort operation, the result is congruent to the unnormalized result,
even if the result sort is inactive. This captures the essence of sort
interaction: normalization on one sort creates derived identities on other sorts.
-/
theorem interaction_coherence {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S} {C : SortCongruence A}
    (N : PartialNormalizer A C) (f : S.ops)
    (args : ∀ i : Fin (S.arity f).length, A.carrier ((S.arity f).get i)) :
    C.rel (S.resultSort f) (A.interp f (normArgs N.toSortNorm args)) (A.interp f args) := by
  exact sort_interaction_lemma N.toSortNorm N.norm_sound f args

/-! ## Section 9: Congruence Pseudometrics and Lipschitz Property -/

/-- The **discrete congruence distance**: `0` if elements are congruent, `1` otherwise.
This turns any equivalence relation into a pseudometric. -/
def congruenceDist {α : Type*} (rel : α → α → Prop) (x y : α) : ℝ :=
  if rel x y then 0 else 1

/-
The congruence distance is nonneg.
-/
theorem congruenceDist_nonneg {α : Type*} (rel : α → α → Prop) (x y : α) :
    0 ≤ congruenceDist rel x y := by
  unfold congruenceDist; split_ifs <;> norm_num;

/-
The congruence distance is symmetric when the relation is symmetric.
-/
theorem congruenceDist_symm {α : Type*} {rel : α → α → Prop}
    (h_symm : ∀ x y, rel x y → rel y x) (x y : α) :
    congruenceDist rel x y = congruenceDist rel y x := by
  grind +locals

/-
The congruence distance satisfies the triangle inequality when the relation
is transitive.
-/
theorem congruenceDist_triangle {α : Type*} {rel : α → α → Prop}
    (h_trans : ∀ x y z, rel x y → rel y z → rel x z)
    (h_symm : ∀ x y, rel x y → rel y x)
    (x y z : α) :
    congruenceDist rel x z ≤ congruenceDist rel x y + congruenceDist rel y z := by
  unfold congruenceDist;
  grind

/-
**Operations are nonexpanding** (cross-domain: algebra → topology):
If all argument pairs have congruence distance 0 (i.e., are congruent), then
the operation results also have congruence distance 0. This makes every
operation in a multi-sorted algebra 1-Lipschitz with respect to the supremum
of the congruence distances, connecting algebraic quotient optimization to
metric space theory.
-/
theorem operation_nonexpanding {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S} (C : SortCongruence A) (f : S.ops)
    (args₁ args₂ : (i : Fin (S.arity f).length) → A.carrier ((S.arity f).get i))
    (h : ∀ i, congruenceDist (C.rel ((S.arity f).get i)) (args₁ i) (args₂ i) = 0) :
    congruenceDist (C.rel (S.resultSort f)) (A.interp f args₁) (A.interp f args₂) = 0 := by
  convert C.compatible f args₁ args₂ _;
  · unfold congruenceDist; aesop;
  · intro i; specialize h i; unfold congruenceDist at h; aesop;

/-! ## Section 10: The Trivial Congruence and Full Normalization -/

/-- Every multi-sorted algebra admits the **trivial congruence** (equality on
each sort). This serves as the base case and shows that the framework subsumes
ordinary (non-quotient) evaluation. -/
def trivialCongruence {σ : Type*} {S : MultiSortedSig σ} (A : MultiSortedAlg S) :
    SortCongruence A where
  rel s := Eq
  is_equiv s := eq_equivalence
  compatible f args₁ args₂ h := by
    congr 1; ext i; exact h i

/-
With the trivial congruence, the sort interaction lemma reduces to
`interp f (norm ∘ args) = interp f args` iff `norm = id` on each sort.
This shows the interaction principle is trivial for non-quotient algebras.
-/
theorem trivial_interaction {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S}
    (N : SortNorm A)
    (h_id : ∀ (s : σ) (x : A.carrier s), N.norm s x = x)
    (f : S.ops)
    (args : ∀ i : Fin (S.arity f).length, A.carrier ((S.arity f).get i)) :
    A.interp f (normArgs N args) = A.interp f args := by
  convert congr_arg _ ?_;
  exact funext fun i => h_id _ _

/-! ## Section 11: Composition of Partial Normalizers -/

/-- Two partial normalizers on disjoint sort sets compose to give a valid
partial normalizer. This is the algebraic foundation for compositional
optimization: independent optimization passes on different types can be
combined without interference. -/
def composeNormalizers {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S} {C : SortCongruence A}
    (N₁ N₂ : PartialNormalizer A C)
    (h_disjoint : ∀ s, ¬(N₁.active s ∧ N₂.active s)) :
    SortNorm A where
  norm s x := N₂.norm s (N₁.norm s x)

/-
The composed normalizer is sound: composing two sound normalizations
preserves congruence.
-/
theorem compose_sound {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S} {C : SortCongruence A}
    (N₁ N₂ : PartialNormalizer A C)
    (h_disjoint : ∀ s, ¬(N₁.active s ∧ N₂.active s))
    (s : σ) (x : A.carrier s) :
    C.rel s ((composeNormalizers N₁ N₂ h_disjoint).norm s x) x := by
  exact C.trans s ( N₂.norm_sound s _ ) ( N₁.norm_sound s _ )

/-! ## Section 12: Concrete Example — Two-Sorted Module Signature -/

/-- The two sorts for the module-over-ring example. -/
inductive ModuleSort | Ring | Module
  deriving DecidableEq, Repr

/-- A two-sorted signature for scalar multiplication: one binary operation
`smul : Ring × Module → Module`. This is the minimal signature exhibiting
sort interaction. -/
def smulSig : MultiSortedSig ModuleSort where
  ops := Unit
  arity := fun _ => [ModuleSort.Ring, ModuleSort.Module]
  resultSort := fun _ => ModuleSort.Module

/-- An algebra over the scalar multiplication signature consists of
a ring carrier, a module carrier, and a scalar multiplication operation. -/
def mkSmulAlg (R M : Type) (smul : R → M → M) : MultiSortedAlg smulSig where
  carrier := fun | ModuleSort.Ring => R | ModuleSort.Module => M
  interp := fun () args =>
    smul (args ⟨0, by simp [smulSig]⟩) (args ⟨1, by simp [smulSig]⟩)

/-! ## Section 13: Falsifiable Conjecture -/

/-- **Conjecture (Normalization Compositionality)**:
For any two partial normalizers `N₁`, `N₂` on disjoint sorts, the
evaluation-preservation property of their composition follows from the
individual preservation properties. That is, composing normalizers that
individually preserve evaluation also preserves evaluation.

This is a falsifiable conjecture: one could test it computationally by
constructing specific multi-sorted algebras with disjoint normalizers
and checking whether `msEval (normEnv (compose N₁ N₂) env) t` is always
congruent to `compose.norm s (msEval env t)`.

**Computational Test**: For the module-over-ring signature with ring
normalization (sorting products) and a trivial module normalization,
verify that composition preserves evaluation for all terms up to depth 4. -/
theorem normalization_compositionality_conjecture
    {σ : Type*} {S : MultiSortedSig σ}
    {A : MultiSortedAlg S} {C : SortCongruence A}
    (N₁ N₂ : PartialNormalizer A C)
    (h_disjoint : ∀ s, ¬(N₁.active s ∧ N₂.active s))
    (env : MSEnv A) {s : σ} (t : MSTerm S s) :
    C.rel s (msEval (normEnv (composeNormalizers N₁ N₂ h_disjoint) env) t)
            ((composeNormalizers N₁ N₂ h_disjoint).norm s (msEval env t)) := by
  sorry

end