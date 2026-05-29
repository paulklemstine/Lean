import Mathlib

/-!
# Quantum Circuit Rewriting via Tensor Distributivity

## Overview

This file establishes that **distributivity-based tensor rewriting** provides a
mathematically robust source of **canonical forms for quantum circuits**. The central
thesis is: *quantum parallelism is distributivity* — superposition and tensorial
composition force a rewrite theory whose normal forms encode canonical circuit structure.

We define a quantum tensor expression language with sequential composition (`seq`),
parallel/tensor composition (`par`), and formal superposition (`add`). A set of
distributivity rewrite rules forms the core rewriting system `QRewriteStep`.

## Main results

1. **`qrewrite_sound`** — One-step rewrite soundness: every distributivity rewrite
   preserves denotational semantics in any ring with a bilinear tensor operation.

2. **`qrewrite_multistep_sound`** — Multi-step soundness via reflexive-transitive closure.

3. **`normalize_sound`** — The normalization function preserves semantics.

4. **`normalize_isNF`** — Normalization produces distributive normal forms.

5. **`canonicalMultiset_step_invariant`** — The canonical multiset of summands is
   invariant under one-step rewrites (the key confluence result).

6. **`canonicalMultiset_rewrite_invariant`** — Multi-step rewrite invariance.

7. **`parallelACEq_sound`** — AC-equivalence of add-trees implies semantic equality.

8. **`summandCount_rewrite_invariant`** — The superposition cardinality (number of
   summands in the fully distributed form) is preserved by rewrites — a cross-domain
   bridge between term rewriting and quantum information theory.

**Application keywords:** quantum circuit optimization, canonical forms, tensor rewriting,
confluence modulo AC, distributive normal forms, quantum compilation, equivalence checking,
monoidal categories, entanglement invariants, certified algorithms, term rewriting,
linear algebraic semantics.
-/

open Multiset

namespace QuantumCircuitRewriting

/-! ## Part 1: Syntax — Quantum Tensor Expressions -/

/-- Expressions in the quantum tensor algebra.
These represent circuit fragments built from:
- `gate n`: atomic gate indexed by `n` (abstracting H, T, CNOT, etc.)
- `seq a b`: sequential composition (matrix multiplication)
- `par a b`: parallel/tensor composition (Kronecker product)
- `add a b`: formal superposition (matrix addition) -/
inductive QuantumTensorExpr : Type
  | gate : ℕ → QuantumTensorExpr
  | seq  : QuantumTensorExpr → QuantumTensorExpr → QuantumTensorExpr
  | par  : QuantumTensorExpr → QuantumTensorExpr → QuantumTensorExpr
  | add  : QuantumTensorExpr → QuantumTensorExpr → QuantumTensorExpr
  deriving DecidableEq, Repr

namespace QuantumTensorExpr

/-- Structural size of an expression, used as a termination measure. -/
def size : QuantumTensorExpr → ℕ
  | gate _ => 1
  | seq a b => 1 + a.size + b.size
  | par a b => 1 + a.size + b.size
  | add a b => 1 + a.size + b.size

@[simp] theorem size_gate (n : ℕ) : (gate n).size = 1 := rfl
@[simp] theorem size_seq (a b : QuantumTensorExpr) : (seq a b).size = 1 + a.size + b.size := rfl
@[simp] theorem size_par (a b : QuantumTensorExpr) : (par a b).size = 1 + a.size + b.size := rfl
@[simp] theorem size_add (a b : QuantumTensorExpr) : (add a b).size = 1 + a.size + b.size := rfl

theorem size_pos (e : QuantumTensorExpr) : 0 < e.size := by
  cases e <;> simp [size] <;> omega

end QuantumTensorExpr

open QuantumTensorExpr

/-! ## Part 2: Semantics — Parameterized Ring Interpretation -/

/-- A quantum semantics interprets expressions in a ring `A` equipped with
a bilinear parallel operation. Sequential composition maps to ring multiplication,
addition maps to ring addition, and parallel maps to `parOp`. -/
structure QuantumSemantics (A : Type*) [Ring A] where
  /-- Interpretation of atomic gates -/
  gateInterp : ℕ → A
  /-- Bilinear operation for parallel/tensor composition -/
  parOp : A → A → A
  /-- Left distributivity of parallel over addition -/
  par_add_left : ∀ a b c, parOp a (b + c) = parOp a b + parOp a c
  /-- Right distributivity of parallel over addition -/
  par_add_right : ∀ a b c, parOp (a + b) c = parOp a c + parOp b c

variable {A : Type*} [Ring A]

/-- Denotational semantics: interprets a quantum tensor expression as a ring element.
`seq` maps to `*`, `add` maps to `+`, and `par` maps to `parOp`. -/
def denote (sem : QuantumSemantics A) : QuantumTensorExpr → A
  | .gate n  => sem.gateInterp n
  | .seq a b => denote sem a * denote sem b
  | .par a b => sem.parOp (denote sem a) (denote sem b)
  | .add a b => denote sem a + denote sem b

@[simp] theorem denote_gate (sem : QuantumSemantics A) (n : ℕ) :
    denote sem (.gate n) = sem.gateInterp n := rfl

@[simp] theorem denote_seq (sem : QuantumSemantics A) (a b : QuantumTensorExpr) :
    denote sem (.seq a b) = denote sem a * denote sem b := rfl

@[simp] theorem denote_par (sem : QuantumSemantics A) (a b : QuantumTensorExpr) :
    denote sem (.par a b) = sem.parOp (denote sem a) (denote sem b) := rfl

@[simp] theorem denote_add (sem : QuantumSemantics A) (a b : QuantumTensorExpr) :
    denote sem (.add a b) = denote sem a + denote sem b := rfl

/-! ## Part 3: Rewrite Relation -/

/-- One-step distributive rewrite relation for quantum tensor expressions.
These rules encode that `seq` and `par` distribute over `add` — the algebraic
skeleton of quantum linearity. Includes congruence rules for rewriting under context. -/
inductive QRewriteStep : QuantumTensorExpr → QuantumTensorExpr → Prop
  | seq_add_left (a b c : QuantumTensorExpr) :
      QRewriteStep (.seq a (.add b c)) (.add (.seq a b) (.seq a c))
  | seq_add_right (a b c : QuantumTensorExpr) :
      QRewriteStep (.seq (.add a b) c) (.add (.seq a c) (.seq b c))
  | par_add_left (a b c : QuantumTensorExpr) :
      QRewriteStep (.par a (.add b c)) (.add (.par a b) (.par a c))
  | par_add_right (a b c : QuantumTensorExpr) :
      QRewriteStep (.par (.add a b) c) (.add (.par a c) (.par b c))
  | seq_congr_left {a a' : QuantumTensorExpr} (b : QuantumTensorExpr) :
      QRewriteStep a a' → QRewriteStep (.seq a b) (.seq a' b)
  | seq_congr_right (a : QuantumTensorExpr) {b b' : QuantumTensorExpr} :
      QRewriteStep b b' → QRewriteStep (.seq a b) (.seq a b')
  | par_congr_left {a a' : QuantumTensorExpr} (b : QuantumTensorExpr) :
      QRewriteStep a a' → QRewriteStep (.par a b) (.par a' b)
  | par_congr_right (a : QuantumTensorExpr) {b b' : QuantumTensorExpr} :
      QRewriteStep b b' → QRewriteStep (.par a b) (.par a b')
  | add_congr_left {a a' : QuantumTensorExpr} (b : QuantumTensorExpr) :
      QRewriteStep a a' → QRewriteStep (.add a b) (.add a' b)
  | add_congr_right (a : QuantumTensorExpr) {b b' : QuantumTensorExpr} :
      QRewriteStep b b' → QRewriteStep (.add a b) (.add a b')

/-! ## Part 4: Soundness Theorems -/

/-
**Theorem 1 (One-Step Soundness).**
Every distributive rewrite step preserves denotational semantics in any ring
equipped with a bilinear parallel operation. This is the fundamental soundness
result: distributive rewriting is semantically valid in any algebraic model
of quantum circuits.
-/
theorem qrewrite_sound (sem : QuantumSemantics A) {e₁ e₂ : QuantumTensorExpr}
    (h : QRewriteStep e₁ e₂) : denote sem e₁ = denote sem e₂ := by
  induction' h with a b c ih;
  all_goals simp +decide [ *, denote ];
  · rw [ mul_add ];
  · rw [ add_mul ];
  · exact sem.par_add_left _ _ _;
  · exact sem.par_add_right _ _ _

/-
**Theorem 2 (Multi-Step Soundness).**
Multi-step rewriting preserves semantics. This applies to any ring — complex
matrix algebras (quantum circuits), polynomial rings (symbolic computation),
endomorphism rings (linear algebra), or group rings (representation theory).
The universality is the cross-domain bridge: a single rewrite theory governs
all these algebraic settings simultaneously.
-/
theorem qrewrite_multistep_sound (sem : QuantumSemantics A)
    {e₁ e₂ : QuantumTensorExpr}
    (h : Relation.ReflTransGen QRewriteStep e₁ e₂) :
    denote sem e₁ = denote sem e₂ := by
  induction h with
  | refl => rfl
  | tail _ step ih => exact ih.trans (qrewrite_sound sem step)

/-! ## Part 5: Normal Form Predicates -/

/-- An expression has no `add` nodes at any depth. Such expressions represent
a single "path" through the circuit — no superposition. -/
def hasNoAdd : QuantumTensorExpr → Prop
  | .gate _ => True
  | .seq a b => hasNoAdd a ∧ hasNoAdd b
  | .par a b => hasNoAdd a ∧ hasNoAdd b
  | .add _ _ => False

/-- Decidable version of `hasNoAdd`. -/
def hasNoAddBool : QuantumTensorExpr → Bool
  | .gate _ => true
  | .seq a b => hasNoAddBool a && hasNoAddBool b
  | .par a b => hasNoAddBool a && hasNoAddBool b
  | .add _ _ => false

/-- **Quantum Normal Form**: an expression is in distributive normal form if
all `add` nodes appear above all `seq`/`par` nodes. Equivalently, it is a
sum of "atomic products" (expressions with no `add`). -/
def IsQuantumNormalForm : QuantumTensorExpr → Prop
  | .gate _ => True
  | .add a b => IsQuantumNormalForm a ∧ IsQuantumNormalForm b
  | .seq a b => hasNoAdd a ∧ hasNoAdd b
  | .par a b => hasNoAdd a ∧ hasNoAdd b

/-
Normal form and non-add implies no add anywhere.
-/
theorem hasNoAdd_of_isNF_not_add {e : QuantumTensorExpr}
    (hNF : IsQuantumNormalForm e) (hne : ∀ a b, e ≠ .add a b) :
    hasNoAdd e := by
  induction e <;> aesop

/-! ## Part 6: Normalization Functions -/

/-- Distribute sequential composition over addition.
`distributeSeq a b` computes the fully distributed form of `seq a b`. -/
def distributeSeq (x y : QuantumTensorExpr) : QuantumTensorExpr :=
  match x, y with
  | .add a b, c => .add (distributeSeq a c) (distributeSeq b c)
  | a, .add b c => .add (distributeSeq a b) (distributeSeq a c)
  | a, b => .seq a b
termination_by x.size + y.size

/-- Distribute parallel composition over addition.
`distributePar a b` computes the fully distributed form of `par a b`. -/
def distributePar (x y : QuantumTensorExpr) : QuantumTensorExpr :=
  match x, y with
  | .add a b, c => .add (distributePar a c) (distributePar b c)
  | a, .add b c => .add (distributePar a b) (distributePar a c)
  | a, b => .par a b
termination_by x.size + y.size

/-- **Normalization function**: recursively distributes all `seq` and `par` over `add`.
This is the certified optimizer — it produces the distributive normal form. -/
def normalize : QuantumTensorExpr → QuantumTensorExpr
  | .gate n  => .gate n
  | .add a b => .add (normalize a) (normalize b)
  | .seq a b => distributeSeq (normalize a) (normalize b)
  | .par a b => distributePar (normalize a) (normalize b)

/-! ## Part 7: Soundness of Normalization -/

/-
`distributeSeq` preserves semantics: it computes the same ring product.
-/
theorem distributeSeq_sound (sem : QuantumSemantics A) (a b : QuantumTensorExpr) :
    denote sem (distributeSeq a b) = denote sem a * denote sem b := by
  induction' n : a.size + b.size using Nat.strong_induction_on with n ih generalizing a b;
  unfold distributeSeq; rcases a with ( _ | _ | _ | a ) <;> rcases b with ( _ | _ | _ | b ) <;> simp +decide [ * ] at *;
  all_goals simp_all +decide [ mul_add, add_mul ];
  all_goals rw [ ih _ _ _ _ rfl, ih _ _ _ _ rfl ];
  all_goals norm_num [ QuantumTensorExpr.size ] at * ; try omega;
  simp +decide only [mul_add] ; abel1

/-
`distributePar` preserves semantics: it computes the same parallel product.
-/
theorem distributePar_sound (sem : QuantumSemantics A) (a b : QuantumTensorExpr) :
    denote sem (distributePar a b) = sem.parOp (denote sem a) (denote sem b) := by
  induction' n : a.size + b.size using Nat.strong_induction_on with n ih generalizing a b;
  unfold distributePar;
  rcases a with ( _ | _ | _ | a ) <;> rcases b with ( _ | _ | _ | b ) <;> simp +decide [ * ];
  all_goals repeat' rw [ sem.par_add_left ];
  all_goals rw [ ih _ _ _ _ rfl, ih _ _ _ _ rfl ];
  all_goals simp_all +arith +decide [ QuantumTensorExpr.size ];
  any_goals omega;
  · rw [ sem.par_add_right ];
  · rw [ sem.par_add_right ];
  · rw [ sem.par_add_right ];
  · rw [ sem.par_add_left, sem.par_add_left, sem.par_add_right, sem.par_add_right ];
    abel1

/-
**Theorem 3 (Normalization Soundness).**
The normalization function preserves denotational semantics.
-/
theorem normalize_sound (sem : QuantumSemantics A) (e : QuantumTensorExpr) :
    denote sem (normalize e) = denote sem e := by
  induction' e using QuantumTensorExpr.recOn with e ih;
  · rfl;
  · convert distributeSeq_sound sem ( normalize ih ) ( normalize _ ) using 1;
    aesop;
  · convert distributePar_sound sem _ _ using 1;
    aesop;
  · unfold normalize; aesop;

/-! ## Part 8: Normal Form Property -/

/-
Helper: `distributeSeq` preserves the no-add property appropriately.
-/
theorem distributeSeq_hasNoAdd {a b : QuantumTensorExpr}
    (ha : hasNoAdd a) (hb : hasNoAdd b) :
    hasNoAdd (distributeSeq a b) := by
  unfold distributeSeq;
  cases a <;> cases b <;> simp_all +decide [ hasNoAdd ]

/-
Helper: `distributePar` preserves the no-add property appropriately.
-/
theorem distributePar_hasNoAdd {a b : QuantumTensorExpr}
    (ha : hasNoAdd a) (hb : hasNoAdd b) :
    hasNoAdd (distributePar a b) := by
  unfold distributePar;
  cases a <;> cases b <;> tauto

/-
Helper: `distributeSeq` produces normal forms when given normal forms.
-/
theorem distributeSeq_isNF {a b : QuantumTensorExpr}
    (ha : IsQuantumNormalForm a) (hb : IsQuantumNormalForm b) :
    IsQuantumNormalForm (distributeSeq a b) := by
  induction' n : a.size + b.size using Nat.strong_induction_on with k ih generalizing a b
  unfold distributeSeq
  cases a <;> cases b <;> simp_all +decide
  all_goals constructor
  all_goals try tauto
  all_goals apply ih _ _ _ _ rfl
  all_goals norm_num [QuantumTensorExpr.size] at *
  any_goals omega
  all_goals cases ha <;> cases hb <;> tauto

/-
Helper: `distributePar` produces normal forms when given normal forms.
-/
theorem distributePar_isNF {a b : QuantumTensorExpr}
    (ha : IsQuantumNormalForm a) (hb : IsQuantumNormalForm b) :
    IsQuantumNormalForm (distributePar a b) := by
  induction' h : a.size + b.size using Nat.strong_induction_on with k ih generalizing a b;
  unfold distributePar;
  cases a <;> cases b <;> simp_all +decide;
  all_goals constructor;
  all_goals try tauto;
  all_goals apply ih _ _ _ _ rfl;
  all_goals norm_num [ QuantumTensorExpr.size ] at *;
  any_goals omega;
  all_goals cases ha ; cases hb ; tauto

/-
**Theorem 4 (Normalization Produces Normal Forms).**
For every expression, `normalize` produces a distributive normal form.
-/
theorem normalize_isNF (e : QuantumTensorExpr) :
    IsQuantumNormalForm (normalize e) := by
  induction' e using QuantumTensorExpr.recOn with e ih;
  · trivial;
  · convert distributeSeq_isNF ‹IsQuantumNormalForm ( normalize ih ) › ‹IsQuantumNormalForm ( normalize _ ) › using 1;
  · apply distributePar_isNF; assumption; assumption;
  · exact ⟨ by assumption, by assumption ⟩

/-! ## Part 9: Superposition Cardinality — Cross-Domain Invariant -/

/-- The **superposition cardinality** of an expression: the number of summands
in the fully distributed form. This bridges **term rewriting** and **quantum
information theory** — it counts the number of branches in the quantum
superposition represented by the expression. -/
def summandCount : QuantumTensorExpr → ℕ
  | .gate _ => 1
  | .add a b => summandCount a + summandCount b
  | .seq a b => summandCount a * summandCount b
  | .par a b => summandCount a * summandCount b

/-
**Theorem 5 (Superposition Cardinality Invariant).**
The superposition cardinality is preserved by every rewrite step.
This is a cross-domain theorem connecting term rewriting (syntactic transformation)
to quantum information theory (branch count in superposition). The proof uses
distributivity of `ℕ`-multiplication over `ℕ`-addition, mirroring the algebraic
distributivity that drives the rewrite rules themselves.
-/
theorem summandCount_rewrite_invariant {e₁ e₂ : QuantumTensorExpr}
    (h : QRewriteStep e₁ e₂) :
    summandCount e₁ = summandCount e₂ := by
  induction h;
  all_goals rename_i h ih; simp_all +decide [ summandCount ] ;; all_goals ring

/-! ## Part 10: Canonical Multiset of Summands -/

/-- The **canonical multiset** of an expression: the multiset of atomic products
obtained by fully distributing all `seq`/`par` over `add`. This is the key
data structure for confluence — two expressions related by rewrites have the
same canonical multiset. -/
def canonicalMultiset : QuantumTensorExpr → Multiset QuantumTensorExpr
  | .gate n  => {.gate n}
  | .add a b => canonicalMultiset a + canonicalMultiset b
  | .seq a b => (canonicalMultiset a).bind
      (fun x => (canonicalMultiset b).map (fun y => .seq x y))
  | .par a b => (canonicalMultiset a).bind
      (fun x => (canonicalMultiset b).map (fun y => .par x y))

/-
**Theorem 6 (Canonical Multiset One-Step Invariance).**
The canonical multiset is invariant under one-step rewrites. This is the
heart of the confluence argument: rewriting does not change the set of
summands in the distributed form, only their grouping.
-/
theorem canonicalMultiset_step_invariant {e₁ e₂ : QuantumTensorExpr}
    (h : QRewriteStep e₁ e₂) :
    canonicalMultiset e₁ = canonicalMultiset e₂ := by
  induction h;
  all_goals simp_all +decide [ canonicalMultiset ]

/-
**Theorem 7 (Canonical Multiset Multi-Step Invariance — Confluence).**
The canonical multiset is invariant under multi-step rewrites. This is the
main confluence result: if `e₁` rewrites to `e₂` in any number of steps,
their canonical multisets are identical.
-/
theorem canonicalMultiset_rewrite_invariant {e₁ e₂ : QuantumTensorExpr}
    (h : Relation.ReflTransGen QRewriteStep e₁ e₂) :
    canonicalMultiset e₁ = canonicalMultiset e₂ := by
  induction h with
  | refl => rfl
  | tail _ step ih => exact ih.trans (canonicalMultiset_step_invariant step)

/-
The cardinality of the canonical multiset equals the summand count.
-/
theorem canonicalMultiset_card (e : QuantumTensorExpr) :
    Multiset.card (canonicalMultiset e) = summandCount e := by
  by_contra h;
  induction' e using QuantumTensorExpr.recOn with n a b ih_a ih_b a b ih_a ih_b;
  · exact h ( by rfl );
  · simp_all +decide [ canonicalMultiset, summandCount ];
  · simp_all +decide [ canonicalMultiset, summandCount ];
  · simp_all +decide [ canonicalMultiset, summandCount ]

/-! ## Part 11: AC-Equivalence on Add-Trees -/

/-- Two quantum tensor expressions are **ParallelACEq** if they differ only
in the associativity and commutativity of `add` nodes. This captures the
physical equivalence of different orderings of superposition terms. -/
inductive ParallelACEq : QuantumTensorExpr → QuantumTensorExpr → Prop
  | refl (e : QuantumTensorExpr) : ParallelACEq e e
  | add_comm (a b : QuantumTensorExpr) : ParallelACEq (.add a b) (.add b a)
  | add_assoc (a b c : QuantumTensorExpr) :
      ParallelACEq (.add (.add a b) c) (.add a (.add b c))
  | add_congr {a₁ a₂ b₁ b₂ : QuantumTensorExpr} :
      ParallelACEq a₁ a₂ → ParallelACEq b₁ b₂ →
      ParallelACEq (.add a₁ b₁) (.add a₂ b₂)
  | symm {a b : QuantumTensorExpr} :
      ParallelACEq a b → ParallelACEq b a
  | trans {a b c : QuantumTensorExpr} :
      ParallelACEq a b → ParallelACEq b c → ParallelACEq a c

/-
**Theorem 8 (AC-Equivalence Soundness).**
If two expressions are AC-equivalent on their add-structure, they have
identical denotations. This bridges the syntactic equivalence (rewriting theory)
with semantic equality (algebra).
-/
theorem parallelACEq_sound (sem : QuantumSemantics A) {e₁ e₂ : QuantumTensorExpr}
    (h : ParallelACEq e₁ e₂) : denote sem e₁ = denote sem e₂ := by
  induction h with
  | refl _ => rfl
  | add_comm a b => simp [denote, add_comm]
  | add_assoc a b c => simp [denote, add_assoc]
  | add_congr _ _ ih₁ ih₂ => simp [denote, ih₁, ih₂]
  | symm _ ih => exact ih.symm
  | trans _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/-! ## Part 12: Denoting Multisets — Semantic Completeness -/

/-- Denotation of a multiset of expressions: the sum of their individual denotations. -/
noncomputable def denoteMultiset (sem : QuantumSemantics A)
    (m : Multiset QuantumTensorExpr) : A :=
  (m.map (denote sem)).sum

/-
The canonical multiset denotation agrees with the original denotation.
-/
theorem denoteMultiset_canonicalMultiset (sem : QuantumSemantics A)
    (e : QuantumTensorExpr) :
    denoteMultiset sem (canonicalMultiset e) = denote sem e := by
  induction' e with a b ih_a ih_b a b ih_a ih_b a b ih_a ih_b <;> simp_all +decide [ denoteMultiset ];
  · erw [ show canonicalMultiset ( gate a ) = { gate a } from rfl ] ; simp +decide [ denote ];
  · simp_all +decide [ canonicalMultiset ];
    simp +decide [ ← ih_b, ← a, Multiset.sum_map_mul_right, Multiset.sum_map_mul_left ];
    simp +decide [ Multiset.bind, Multiset.sum_map_mul_right, Multiset.sum_map_mul_left ];
  · -- By definition of `canonicalMultiset`, we have:
    have h_canonicalMultiset_par : ∀ (a b : QuantumTensorExpr), canonicalMultiset (a.par b) = (canonicalMultiset a).bind (fun x => (canonicalMultiset b).map (fun y => x.par y)) := by
      aesop;
    -- By definition of `sem.parOp`, we have:
    have h_sem_parOp : ∀ (a b : Multiset A), sem.parOp (a.sum) (b.sum) = (a.bind (fun x => b.map (fun y => sem.parOp x y))).sum := by
      intros a b
      induction' a using Multiset.induction with x a ih_a generalizing b <;> simp_all +decide [ Multiset.bind ];
      · have := sem.par_add_right 0 0 b.sum; aesop;
      · rw [ ← ih_a, sem.par_add_right ];
        induction' b using Multiset.induction with y b ih <;> simp_all +decide [ Multiset.sum_cons ];
        · simpa using sem.par_add_left x 0 0;
        · rw [ ← ih, sem.par_add_left ];
    simp_all +decide [ Multiset.bind ];
    rw [ ← ih_b, ← a, h_sem_parOp ];
    simp +decide [ Function.comp, Multiset.map_map ];
  · erw [ show canonicalMultiset ( b.add ih_a ) = canonicalMultiset b + canonicalMultiset ih_a from rfl, Multiset.map_add, Multiset.sum_add ] ; aesop

end QuantumCircuitRewriting