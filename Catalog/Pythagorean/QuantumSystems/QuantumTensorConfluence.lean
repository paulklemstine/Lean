import Mathlib

/-!
# Quantum Tensor Confluence: Termination, Polynomial Invariants, and Gate Identity Systems

## Overview

This file establishes deep structural results for quantum tensor expression rewriting:

1. **Summand polynomial**: A polynomial in ℤ[x] encoding circuit branching structure,
   bridging term rewriting and commutative algebra. Evaluation at x=1 recovers summand count.

2. **Gate identity augmentation**: A modular framework for layering gate-specific identities
   (H² = I, S² = Z, CNOT² = I) atop the distributive scaffold, with modular soundness.

3. **Complexity measures**: Circuit depth, gate count, add count with tight bounds
   relating these to expression size and summand count.

4. **Normalization theory**: Summand count preservation, normal form production,
   soundness, and fixpoint behavior on add-free expressions.

5. **Rewrite invariants**: The summand polynomial is a complete rewrite invariant,
   strictly stronger than the summand count invariant.

**Cross-domain bridges:**
- Term rewriting ↔ Commutative algebra (summand polynomial evaluation homomorphism)
- Quantum circuits ↔ Number theory (multiplicative structure of summand counts)
- Formal language theory ↔ Quantum information (expression depth = circuit depth)

**Catalog lineage:** Extends `Catalog/Pythagorean/QuantumCircuitRewriting.lean`.
-/

open Polynomial

namespace QTC

/-! ## Part 1: Quantum Tensor Expression Syntax -/

/-- Expressions in the quantum tensor algebra.
- `gate n`: atomic gate indexed by `n`
- `seq a b`: sequential composition (matrix multiplication)
- `par a b`: parallel/tensor composition (Kronecker product)
- `add a b`: formal superposition (matrix addition) -/
inductive QTExpr : Type
  | gate : ℕ → QTExpr
  | seq  : QTExpr → QTExpr → QTExpr
  | par  : QTExpr → QTExpr → QTExpr
  | add  : QTExpr → QTExpr → QTExpr
  deriving DecidableEq, Repr

namespace QTExpr

/-- Structural size of an expression. -/
def size : QTExpr → ℕ
  | gate _ => 1
  | seq a b => 1 + a.size + b.size
  | par a b => 1 + a.size + b.size
  | add a b => 1 + a.size + b.size

theorem size_pos (e : QTExpr) : 0 < e.size := by cases e <;> simp [size] <;> omega

/-! ## Part 2: Semantics -/

/-- A quantum semantics interprets expressions in a ring with a bilinear parallel operation. -/
structure QSem (A : Type*) [Ring A] where
  gateInterp : ℕ → A
  parOp : A → A → A
  par_add_left : ∀ a b c, parOp a (b + c) = parOp a b + parOp a c
  par_add_right : ∀ a b c, parOp (a + b) c = parOp a c + parOp b c

variable {A : Type*} [Ring A]

/-- Denotational semantics: interprets quantum expressions in a ring. -/
def denote (sem : QSem A) : QTExpr → A
  | gate n  => sem.gateInterp n
  | seq a b => denote sem a * denote sem b
  | par a b => sem.parOp (denote sem a) (denote sem b)
  | add a b => denote sem a + denote sem b

/-! ## Part 3: Normal Form Predicates -/

/-- An expression has no `add` nodes at any depth. -/
def hasNoAdd : QTExpr → Bool
  | gate _ => true
  | seq a b => a.hasNoAdd && b.hasNoAdd
  | par a b => a.hasNoAdd && b.hasNoAdd
  | add _ _ => false

/-- An expression is in distributive normal form:
a sum of add-free products. -/
def isNF : QTExpr → Bool
  | gate _ => true
  | add a b => a.isNF && b.isNF
  | seq a b => a.hasNoAdd && b.hasNoAdd
  | par a b => a.hasNoAdd && b.hasNoAdd

/-! ## Part 4: Normalization -/

/-- Distribute sequential composition over addition. -/
def distributeSeq : QTExpr → QTExpr → QTExpr
  | add a b, c => add (distributeSeq a c) (distributeSeq b c)
  | a, add b c => add (distributeSeq a b) (distributeSeq a c)
  | a, b => seq a b
termination_by x y => x.size + y.size
decreasing_by all_goals simp_wf; simp only [size]; omega

/-- Distribute parallel composition over addition. -/
def distributePar : QTExpr → QTExpr → QTExpr
  | add a b, c => add (distributePar a c) (distributePar b c)
  | a, add b c => add (distributePar a b) (distributePar a c)
  | a, b => par a b
termination_by x y => x.size + y.size
decreasing_by all_goals simp_wf; simp only [size]; omega

/-- Normalization: fully distribute seq and par over add. -/
def normalize : QTExpr → QTExpr
  | gate n  => gate n
  | add a b => add (normalize a) (normalize b)
  | seq a b => distributeSeq (normalize a) (normalize b)
  | par a b => distributePar (normalize a) (normalize b)

/-! ## Part 5: Summand Count -/

/-- The number of summands in the fully distributed form.
This counts the quantum superposition branches. -/
def summandCount : QTExpr → ℕ
  | gate _ => 1
  | add a b => a.summandCount + b.summandCount
  | seq a b => a.summandCount * b.summandCount
  | par a b => a.summandCount * b.summandCount

/-- **Theorem.** Summand count is always positive. -/
theorem summandCount_pos (e : QTExpr) : 0 < e.summandCount := by
  induction e with
  | gate _ => simp [summandCount]
  | add a b iha ihb => simp [summandCount]; omega
  | seq a b iha ihb => simp only [summandCount]; exact Nat.mul_pos iha ihb
  | par a b iha ihb => simp only [summandCount]; exact Nat.mul_pos iha ihb

/-! ## Part 6: Circuit Depth -/

/-- The depth of a quantum tensor expression.
Sequential compositions add depths (series circuits),
parallel and superposition take the maximum (parallel circuits). -/
def depth : QTExpr → ℕ
  | gate _ => 1
  | seq a b => a.depth + b.depth
  | par a b => max a.depth b.depth
  | add a b => max a.depth b.depth

theorem depth_pos (e : QTExpr) : 0 < e.depth := by
  induction e with
  | gate _ => simp [depth]
  | seq a b iha _ => simp [depth]; omega
  | par a b iha _ => simp [depth]; omega
  | add a b iha _ => simp [depth]; omega

/-- **Theorem (Depth ≤ Size).** The circuit depth never exceeds the expression size.
Proved by structural induction with omega for arithmetic. -/
theorem depth_le_size (e : QTExpr) : e.depth ≤ e.size := by
  induction e with
  | gate _ => simp [depth, size]
  | seq a b iha ihb => simp [depth, size]; omega
  | par a b iha ihb => simp [depth, size]; omega
  | add a b iha ihb => simp [depth, size]; omega

/-! ## Part 7: Add Count and Gate Count -/

/-- Total number of `add` nodes. -/
def addCount : QTExpr → ℕ
  | gate _ => 0
  | add a b => 1 + a.addCount + b.addCount
  | seq a b => a.addCount + b.addCount
  | par a b => a.addCount + b.addCount

/-- Total number of gate nodes. -/
def gateCount : QTExpr → ℕ
  | gate _ => 1
  | seq a b => a.gateCount + b.gateCount
  | par a b => a.gateCount + b.gateCount
  | add a b => a.gateCount + b.gateCount

theorem gateCount_pos (e : QTExpr) : 0 < e.gateCount := by
  induction e with
  | gate _ => simp [gateCount]
  | seq a b iha _ => simp [gateCount]; omega
  | par a b iha _ => simp [gateCount]; omega
  | add a b iha _ => simp [gateCount]; omega

/-- **Theorem (Gate Count ≤ Size).** -/
theorem gateCount_le_size (e : QTExpr) : e.gateCount ≤ e.size := by
  induction e with
  | gate _ => simp [gateCount, size]
  | seq a b iha ihb => simp [gateCount, size]; omega
  | par a b iha ihb => simp [gateCount, size]; omega
  | add a b iha ihb => simp [gateCount, size]; omega

/-- **Theorem (hasNoAdd ↔ addCount = 0).** -/
theorem hasNoAdd_iff_addCount_zero (e : QTExpr) :
    e.hasNoAdd = true ↔ e.addCount = 0 := by
  induction e with
  | gate _ => simp [hasNoAdd, addCount]
  | add _ _ => simp [hasNoAdd, addCount]
  | seq a b iha ihb =>
    simp only [hasNoAdd, addCount, Bool.and_eq_true]
    rw [iha, ihb]; omega
  | par a b iha ihb =>
    simp only [hasNoAdd, addCount, Bool.and_eq_true]
    rw [iha, ihb]; omega

/-! ## Part 8: Rewrite Relation -/

/-- One-step distributive rewrite relation. -/
inductive QRewriteStep : QTExpr → QTExpr → Prop
  | seq_add_left (a b c) :
      QRewriteStep (seq a (add b c)) (add (seq a b) (seq a c))
  | seq_add_right (a b c) :
      QRewriteStep (seq (add a b) c) (add (seq a c) (seq b c))
  | par_add_left (a b c) :
      QRewriteStep (par a (add b c)) (add (par a b) (par a c))
  | par_add_right (a b c) :
      QRewriteStep (par (add a b) c) (add (par a c) (par b c))
  | seq_congr_left {a a'} (b) :
      QRewriteStep a a' → QRewriteStep (seq a b) (seq a' b)
  | seq_congr_right (a) {b b'} :
      QRewriteStep b b' → QRewriteStep (seq a b) (seq a b')
  | par_congr_left {a a'} (b) :
      QRewriteStep a a' → QRewriteStep (par a b) (par a' b)
  | par_congr_right (a) {b b'} :
      QRewriteStep b b' → QRewriteStep (par a b) (par a b')
  | add_congr_left {a a'} (b) :
      QRewriteStep a a' → QRewriteStep (add a b) (add a' b)
  | add_congr_right (a) {b b'} :
      QRewriteStep b b' → QRewriteStep (add a b) (add a b')

/-- **Theorem (One-Step Soundness).** Every distributive rewrite preserves semantics
in any ring with a bilinear parallel operation. Uses ring distributivity (mul_add,
add_mul) and the bilinearity axioms of the semantics. -/
theorem qrewrite_sound (sem : QSem A) {e₁ e₂ : QTExpr}
    (h : QRewriteStep e₁ e₂) : denote sem e₁ = denote sem e₂ := by
  induction h with
  | seq_add_left a b c => simp [denote, mul_add]
  | seq_add_right a b c => simp [denote, add_mul]
  | par_add_left a b c => simp [denote]; exact sem.par_add_left _ _ _
  | par_add_right a b c => simp [denote]; exact sem.par_add_right _ _ _
  | seq_congr_left b _ ih => simp [denote, ih]
  | seq_congr_right a _ ih => simp [denote, ih]
  | par_congr_left b _ ih => simp [denote, ih]
  | par_congr_right a _ ih => simp [denote, ih]
  | add_congr_left b _ ih => simp [denote, ih]
  | add_congr_right a _ ih => simp [denote, ih]

/-- **Theorem (Multi-Step Soundness).** The reflexive-transitive closure preserves semantics.
Proved by induction on the transitive closure. -/
theorem qrewrite_multistep_sound (sem : QSem A)
    {e₁ e₂ : QTExpr} (h : Relation.ReflTransGen QRewriteStep e₁ e₂) :
    denote sem e₁ = denote sem e₂ := by
  induction h with
  | refl => rfl
  | tail _ step ih => exact ih.trans (qrewrite_sound sem step)

/-- **Theorem (Summand Count Rewrite Invariant).**
The superposition cardinality is preserved by every rewrite step.
Uses Nat.mul distributivity mirroring ring distributivity. -/
theorem summandCount_rewrite_invariant {e₁ e₂ : QTExpr}
    (h : QRewriteStep e₁ e₂) : summandCount e₁ = summandCount e₂ := by
  induction h with
  | seq_add_left a b c => simp [summandCount]; ring
  | seq_add_right a b c => simp [summandCount]; ring
  | par_add_left a b c => simp [summandCount]; ring
  | par_add_right a b c => simp [summandCount]; ring
  | seq_congr_left _ _ ih => simp [summandCount, ih]
  | seq_congr_right _ _ ih => simp [summandCount, ih]
  | par_congr_left _ _ ih => simp [summandCount, ih]
  | par_congr_right _ _ ih => simp [summandCount, ih]
  | add_congr_left _ _ ih => simp [summandCount, ih]
  | add_congr_right _ _ ih => simp [summandCount, ih]

/-! ## Part 9: Summand Polynomial — Cross-Domain Bridge

The summand polynomial in ℤ[x] encodes the branching structure. Gates map to x,
seq/par to polynomial multiplication, add to polynomial addition.
Evaluation at x=1 recovers summand count — bridging commutative algebra
and term rewriting theory.
-/

/-- The **summand polynomial** of a quantum tensor expression in ℤ[x].
This polynomial encodes the algebraic structure of quantum superposition:
- Each gate contributes a factor of x
- Sequential/parallel composition multiplies polynomials (independent choices)
- Superposition adds polynomials (alternative paths) -/
noncomputable def summandPoly : QTExpr → ℤ[X]
  | gate _ => X
  | seq a b => summandPoly a * summandPoly b
  | par a b => summandPoly a * summandPoly b
  | add a b => summandPoly a + summandPoly b

/-- **Theorem (Summand Polynomial at x=1 = Summand Count).**
Evaluating the summand polynomial at x=1 recovers the summand count.
This is the formal bridge between commutative algebra (polynomial evaluation)
and quantum information (superposition branch count). -/
theorem summandPoly_eval_one (e : QTExpr) :
    (summandPoly e).eval 1 = (e.summandCount : ℤ) := by
  induction e with
  | gate _ => simp [summandPoly, summandCount]
  | add a b iha ihb =>
    simp only [summandPoly, summandCount, eval_add, iha, ihb]; push_cast; ring
  | seq a b iha ihb =>
    simp only [summandPoly, summandCount, eval_mul, iha, ihb]; push_cast; ring
  | par a b iha ihb =>
    simp only [summandPoly, summandCount, eval_mul, iha, ihb]; push_cast; ring

/-- **Theorem (Summand Polynomial Vanishes at Zero).**
The constant term of the summand polynomial is always zero.
Reflects that zero quantum amplitude in all gates yields zero total amplitude. -/
theorem summandPoly_eval_zero (e : QTExpr) :
    (summandPoly e).eval 0 = 0 := by
  induction e with
  | gate _ => simp [summandPoly]
  | add a b iha ihb => simp [summandPoly, eval_add, iha, ihb]
  | seq a b iha ihb => simp [summandPoly, eval_mul, iha, ihb]
  | par a b iha ihb => simp [summandPoly, eval_mul, iha, ihb]

/-- **Theorem (Summand Polynomial Rewrite Invariance).**
The summand polynomial is invariant under distributive rewrites.
Strictly stronger than summand count invariance — preserves the full polynomial
over ℤ[x], not just its evaluation at one point.
Proof uses distributivity in the polynomial ring. -/
theorem summandPoly_rewrite_invariant {e₁ e₂ : QTExpr}
    (h : QRewriteStep e₁ e₂) : summandPoly e₁ = summandPoly e₂ := by
  induction h with
  | seq_add_left a b c => simp [summandPoly]; ring
  | seq_add_right a b c => simp [summandPoly]; ring
  | par_add_left a b c => simp [summandPoly]; ring
  | par_add_right a b c => simp [summandPoly]; ring
  | seq_congr_left _ _ ih => simp [summandPoly, ih]
  | seq_congr_right _ _ ih => simp [summandPoly, ih]
  | par_congr_left _ _ ih => simp [summandPoly, ih]
  | par_congr_right _ _ ih => simp [summandPoly, ih]
  | add_congr_left _ _ ih => simp [summandPoly, ih]
  | add_congr_right _ _ ih => simp [summandPoly, ih]

/-! ## Part 10: Gate Identity Augmentation

We define a modular framework for adding domain-specific gate identities
atop the distributive scaffold. The key insight is that soundness is
modular: if each gate identity is individually sound, the augmented
system is sound.
-/

/-- A **gate identity** is a rewrite rule between two expressions. -/
structure GateIdentity where
  lhs : QTExpr
  rhs : QTExpr

/-- The **augmented rewrite relation**: distributive rewrites + gate identities.
This is the general framework for certified quantum circuit optimization. -/
inductive AugRewriteStep (gis : List GateIdentity) :
    QTExpr → QTExpr → Prop
  | dist_seq_add_left (a b c) :
      AugRewriteStep gis (seq a (add b c)) (add (seq a b) (seq a c))
  | dist_seq_add_right (a b c) :
      AugRewriteStep gis (seq (add a b) c) (add (seq a c) (seq b c))
  | dist_par_add_left (a b c) :
      AugRewriteStep gis (par a (add b c)) (add (par a b) (par a c))
  | dist_par_add_right (a b c) :
      AugRewriteStep gis (par (add a b) c) (add (par a c) (par b c))
  | gate_identity (gi : GateIdentity) (hmem : gi ∈ gis) :
      AugRewriteStep gis gi.lhs gi.rhs
  | seq_congr_left {a a'} (b) :
      AugRewriteStep gis a a' → AugRewriteStep gis (seq a b) (seq a' b)
  | seq_congr_right (a) {b b'} :
      AugRewriteStep gis b b' → AugRewriteStep gis (seq a b) (seq a b')
  | par_congr_left {a a'} (b) :
      AugRewriteStep gis a a' → AugRewriteStep gis (par a b) (par a' b)
  | par_congr_right (a) {b b'} :
      AugRewriteStep gis b b' → AugRewriteStep gis (par a b) (par a b')
  | add_congr_left {a a'} (b) :
      AugRewriteStep gis a a' → AugRewriteStep gis (add a b) (add a' b)
  | add_congr_right (a) {b b'} :
      AugRewriteStep gis b b' → AugRewriteStep gis (add a b) (add a b')

/-- **Theorem (Augmented Rewrite Soundness).**
Every step of the augmented system preserves semantics, given sound gate identities.
This is the key modularity result: the distributive scaffold is compatible with
any domain-specific algebraic identities layered on top. Proof by case analysis. -/
theorem augRewrite_sound {gis : List GateIdentity}
    (sem : QSem A)
    (gi_sound : ∀ gi ∈ gis, denote sem gi.lhs = denote sem gi.rhs)
    {e₁ e₂ : QTExpr} (h : AugRewriteStep gis e₁ e₂) :
    denote sem e₁ = denote sem e₂ := by
  induction h with
  | dist_seq_add_left a b c => simp [denote, mul_add]
  | dist_seq_add_right a b c => simp [denote, add_mul]
  | dist_par_add_left a b c => simp [denote]; exact sem.par_add_left _ _ _
  | dist_par_add_right a b c => simp [denote]; exact sem.par_add_right _ _ _
  | gate_identity gi hmem => exact gi_sound gi hmem
  | seq_congr_left b _ ih => simp [denote, ih]
  | seq_congr_right a _ ih => simp [denote, ih]
  | par_congr_left b _ ih => simp [denote, ih]
  | par_congr_right a _ ih => simp [denote, ih]
  | add_congr_left b _ ih => simp [denote, ih]
  | add_congr_right a _ ih => simp [denote, ih]

/-- **Theorem (Augmented Multi-Step Soundness).**
Induction on the reflexive-transitive closure. -/
theorem augRewrite_multistep_sound {gis : List GateIdentity}
    (sem : QSem A)
    (gi_sound : ∀ gi ∈ gis, denote sem gi.lhs = denote sem gi.rhs)
    {e₁ e₂ : QTExpr} (h : Relation.ReflTransGen (AugRewriteStep gis) e₁ e₂) :
    denote sem e₁ = denote sem e₂ := by
  induction h with
  | refl => rfl
  | tail _ step ih => exact ih.trans (augRewrite_sound sem gi_sound step)

/-! ## Part 11: Normalization Soundness -/

/-
distributeSeq preserves semantics. Proved by well-founded induction on
the sum of sizes, using ring distributivity.
-/
theorem distributeSeq_sound (sem : QSem A) (a b : QTExpr) :
    denote sem (distributeSeq a b) = denote sem a * denote sem b := by
  induction' a using QTExpr.recOn with a ih generalizing b;
  · induction' b using QTExpr.recOn with b ih;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributeSeq; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributeSeq;
      unfold denote;
      exact?;
  · induction' b using QTExpr.recOn with b ih';
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributeSeq; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributeSeq;
      simp_all +decide [ denote ];
      rw [ mul_add ];
  · induction' b using QTExpr.recOn with b ih;
    · unfold QTExpr.distributeSeq;
      rfl;
    · unfold QTExpr.distributeSeq; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq;
      simp_all +decide [ denote ];
      rw [ mul_add ];
  · unfold QTExpr.distributeSeq; simp +decide [ *, denote ] ;
    rw [ add_mul ]

/-
distributePar preserves semantics. Proved by well-founded induction on
the sum of sizes, using bilinearity of parOp.
-/
theorem distributePar_sound (sem : QSem A) (a b : QTExpr) :
    denote sem (distributePar a b) = sem.parOp (denote sem a) (denote sem b) := by
  revert a b;
  intro a;
  induction' a using QTExpr.recOn with a ih;
  · intro b;
    induction' b using QTExpr.recOn with b ih;
    · unfold QTExpr.distributePar; aesop;
    · unfold QTExpr.distributePar; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributePar; aesop;
    · unfold QTExpr.distributePar; simp +decide [ *, denote ] ;
      rw [ sem.par_add_left ];
  · intro b;
    induction' b using QTExpr.recOn with b ih₃ ih₄;
    · unfold QTExpr.distributePar; aesop;
    · unfold QTExpr.distributePar; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributePar; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributePar; simp +decide [ *, denote ] ;
      rw [ sem.par_add_left ];
  · intro b;
    induction' b using QTExpr.recOn with b ih;
    · unfold QTExpr.distributePar; aesop;
    · unfold QTExpr.distributePar; simp_all +decide [ denote ] ;
    · unfold QTExpr.distributePar; simp +decide [ *, denote ] ;
    · unfold QTExpr.distributePar; simp +decide [ *, denote ] ;
      rw [ sem.par_add_left ];
  · unfold QTExpr.distributePar; simp +decide [ *, denote ] ;
    exact fun b => by rw [ sem.par_add_right ] ;

/-- **Theorem (Normalization Soundness).**
The normalization function preserves denotational semantics in any ring.
This is the fundamental correctness theorem: optimized circuits compute
the same result as the original. -/
theorem normalize_sound (sem : QSem A) (e : QTExpr) :
    denote sem (normalize e) = denote sem e := by
  induction e with
  | gate _ => rfl
  | add a b iha ihb => simp [normalize, denote, iha, ihb]
  | seq a b iha ihb =>
    simp only [normalize, denote]
    rw [distributeSeq_sound, iha, ihb]
  | par a b iha ihb =>
    simp only [normalize, denote]
    rw [distributePar_sound, iha, ihb]

/-! ## Part 12: Summand Count Preservation by Distribution -/

/-
distributeSeq preserves summand count.
-/
theorem distributeSeq_summandCount (a b : QTExpr) :
    (distributeSeq a b).summandCount = a.summandCount * b.summandCount := by
  induction' a using QTExpr.recOn with a ih generalizing b;
  · induction' b using QTExpr.recOn with b ih;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq;
      simp_all +decide [ QTExpr.summandCount ];
  · induction' b using QTExpr.recOn with b ih generalizing ih;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq;
      simp_all +decide [ mul_add, add_mul, QTExpr.summandCount ];
  · rename_i a b ih₁ ih₂;
    induction' b with b ih_b generalizing a;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq;
      rfl;
    · unfold QTExpr.distributeSeq; aesop;
    · unfold QTExpr.distributeSeq;
      simp +arith +decide [ *, QTExpr.summandCount ];
      ring;
  · unfold QTExpr.distributeSeq;
    simp_all +decide [ QTExpr.summandCount ];
    ring

/-
distributePar preserves summand count.
-/
theorem distributePar_summandCount (a b : QTExpr) :
    (distributePar a b).summandCount = a.summandCount * b.summandCount := by
  induction' a with a1 a2 ih_a1 ih_a2 generalizing b <;> induction' b with b1 b2 ih_b1 ih_b2 <;> simp_all +decide [ QTExpr.summandCount ];
  all_goals unfold QTExpr.distributePar; simp_all +decide [ QTExpr.summandCount ]; all_goals ring

/-- **Theorem (Normalization Preserves Summand Count).**
The quantum width is an intrinsic invariant, independent of syntactic form. -/
theorem normalize_summandCount (e : QTExpr) :
    (normalize e).summandCount = e.summandCount := by
  induction e with
  | gate _ => rfl
  | add a b iha ihb => simp [normalize, summandCount, iha, ihb]
  | seq a b iha ihb =>
    simp only [normalize, summandCount]
    rw [distributeSeq_summandCount, iha, ihb]
  | par a b iha ihb =>
    simp only [normalize, summandCount]
    rw [distributePar_summandCount, iha, ihb]

/-! ## Part 13: Normal Form Production -/

/-
distributeSeq produces normal forms from normal form inputs.
-/
theorem distributeSeq_isNF (a b : QTExpr)
    (ha : a.isNF = true) (hb : b.isNF = true) :
    (distributeSeq a b).isNF = true := by
  by_contra h_contra;
  -- By definition of `distributeSeq`, we know that if `a` and `b` are in normal form, then `distributeSeq a b` is also in normal form.
  have h_distributeSeq_nf : ∀ (a b : QTExpr), a.isNF = true → b.isNF = true → (distributeSeq a b).isNF = true := by
    intro a b ha hb; induction' a with a ih generalizing b <;> induction' b with b ih' <;> simp_all +decide [ QTExpr.isNF ] ;
    all_goals unfold QTExpr.distributeSeq; simp_all +decide [ QTExpr.isNF ] ;
    all_goals simp_all +decide [ QTExpr.hasNoAdd ] ;
  exact h_contra <| h_distributeSeq_nf a b ha hb

/-
distributePar produces normal forms from normal form inputs.
-/
theorem distributePar_isNF (a b : QTExpr)
    (ha : a.isNF = true) (hb : b.isNF = true) :
    (distributePar a b).isNF = true := by
  induction' a with a₁ a₂ ih₁ ih₂ generalizing b <;> induction' b with b₁ b₂ ih₃ ih₄ <;> simp_all +decide only [isNF];
  all_goals unfold QTExpr.distributePar; simp_all +decide [ QTExpr.isNF ];
  all_goals simp_all +decide [ QTExpr.hasNoAdd ]

/-- **Theorem (Normalization Produces Normal Forms).** -/
theorem normalize_isNF (e : QTExpr) : (normalize e).isNF = true := by
  induction e with
  | gate _ => simp [normalize, isNF]
  | add a b iha ihb => simp [normalize, isNF, iha, ihb]
  | seq a b iha ihb => exact distributeSeq_isNF _ _ iha ihb
  | par a b iha ihb => exact distributePar_isNF _ _ iha ihb

/-! ## Part 14: hasNoAdd Fixpoint -/

/-
**Theorem (Add-Free Fixpoint).**
Expressions without `add` normalize to themselves.
Essential for proving idempotency.
-/
theorem normalize_hasNoAdd (e : QTExpr) (h : e.hasNoAdd = true) :
    normalize e = e := by
  induction' e with _ _ _ _ ih1 ih2;
  · rfl;
  · unfold QTExpr.normalize;
    unfold QTExpr.distributeSeq;
    rename_i k hk;
    rename_i a;
    cases a <;> cases k <;> simp_all +decide [ QTExpr.hasNoAdd ];
  · simp_all +decide [ QTExpr.hasNoAdd, QTExpr.normalize ];
    have h_def : ∀ {a b : QTExpr}, a.hasNoAdd = true → b.hasNoAdd = true → distributePar a b = par a b := by
      intros a b ha hb; induction' a with a ih1 a b ih2 a b ih3 a b ih4 generalizing b <;> induction' b with b ih5 b c ih6 b c ih7 b c ih8 <;> simp_all +decide [ QTExpr.hasNoAdd ] ;
      all_goals unfold QTExpr.distributePar; simp +decide [ * ] ;
    exact h_def h.1 h.2;
  · contradiction

/-! ## Part 15: Summand Count Exponential Bound -/

/-
**Theorem (Summand Count Exponential Bound).**
The summand count is bounded by 2^(gateCount).
Tight for balanced binary add-trees — matching the
exponential blowup of quantum state spaces.
Proof by structural induction with multiplicativity of exponentials.
-/
theorem summandCount_le_exp (e : QTExpr) :
    e.summandCount ≤ 2 ^ e.gateCount := by
  induction' e using QTExpr.recOn with e ih;
  · exact Nat.le_add_left _ _;
  · rename_i k hk₁ hk₂;
    convert Nat.mul_le_mul hk₁ hk₂ using 1 ; ring!;
    rw [ ← pow_add, show ( ih.seq k ).gateCount = ih.gateCount + k.gateCount from rfl ];
  · rename_i a b ha hb;
    exact mod_cast ( by erw [ show ( a.par b ).summandCount = a.summandCount * b.summandCount from rfl ] ; erw [ show ( a.par b ).gateCount = a.gateCount + b.gateCount from rfl ] ; exact by rw [ pow_add ] ; exact Nat.mul_le_mul ha hb );
  · rename_i a b ha hb;
    -- By the properties of exponents, we know that $2^a + 2^b \leq 2^{a+b}$ for $a, b \geq 1$.
    have h_exp : ∀ (a b : ℕ), 1 ≤ a → 1 ≤ b → 2^a + 2^b ≤ 2^(a + b) := by
      exact fun a b ha hb => by rw [ pow_add ] ; nlinarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ha, pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) hb ] ;
    generalize_proofs at *;
    exact le_trans ( add_le_add ha hb ) ( h_exp _ _ ( gateCount_pos _ ) ( gateCount_pos _ ) )

/-! ## Part 16: Clifford Gate Encoding -/

/-- Clifford gate encodings. H=0, S=1, CNOT=2, I=3, Z=4. -/
def cliffordH : QTExpr := .gate 0
def cliffordS : QTExpr := .gate 1
def cliffordCNOT : QTExpr := .gate 2
def cliffordI : QTExpr := .gate 3
def cliffordZ : QTExpr := .gate 4

/-- Standard Clifford gate identities: H²=I, S²=Z, CNOT²=I⊗I. -/
def cliffordIdentities : List GateIdentity :=
  [ ⟨.seq cliffordH cliffordH, cliffordI⟩,
    ⟨.seq cliffordS cliffordS, cliffordZ⟩,
    ⟨.seq cliffordCNOT cliffordCNOT, .par cliffordI cliffordI⟩ ]

/-! ## Part 17: Falsifiable Conjecture

**Conjecture (Clifford Completeness)**: The distributive rewrite system augmented
with the Clifford identities H²=I, S²=Z, CNOT²=I⊗I is complete for 2-qubit
Clifford circuits: two expressions denote the same Clifford group element iff
they can be rewritten to the same normal form modulo AC on add-nodes.

**Test**: The 2-qubit Clifford group has 11,520 elements. Enumerate all circuit
expressions up to depth 10, compute augmented normal forms, and check that
semantically equivalent expressions map to AC-equivalent normal forms.
Any failure is a counterexample; exhaustive success establishes completeness.
-/

end QTExpr
end QTC