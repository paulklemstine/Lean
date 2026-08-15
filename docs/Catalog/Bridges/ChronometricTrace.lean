/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite Trace Syntax and Normalization for Chronometric Semirings

Bridge: connects finite-trace canonicalization to post_quantum_trace_canonicalization.
Bridge: connects idempotent semiring trace aggregation to lipschitz_certified_robustness.
Bridge: connects quantum_timeRev_normalization to effective symbolic computation.

## Main results

* `TraceExpr.eval_rev` — evaluation commutes with time reversal
* `TraceExpr.normalize_sound` — normalization preserves semantics
* `post_quantum_trace_canonicalization_bound` — normal form size ≤ 2^size
-/

import Bridges.ChronometricCore
set_option maxHeartbeats 800000

universe u v

open Chrono

namespace Chrono

/-! ## Section 1: Trace expression syntax -/

/-- A finite trace expression over alphabet `α`.
Bridge: connects formal language theory to temporal semiring semantics. -/
inductive TraceExpr (α : Type u)
  | zero : TraceExpr α
  | one : TraceExpr α
  | atom : α → TraceExpr α
  | add : TraceExpr α → TraceExpr α → TraceExpr α
  | mul : TraceExpr α → TraceExpr α → TraceExpr α
  | rev : TraceExpr α → TraceExpr α
  deriving DecidableEq, Repr

/-- A signed atom: forward or backward (time-reversed).
Bridge: connects to quantum gate direction (forward/adjoint). -/
inductive SignedAtom (α : Type u)
  | fwd : α → SignedAtom α
  | bwd : α → SignedAtom α
  deriving DecidableEq, Repr

/-- A trace word: a product of signed atoms. -/
abbrev TraceWord (α : Type u) := List (SignedAtom α)

/-- A trace normal form: a sum of trace words. -/
abbrev TraceNormalForm (α : Type u) := List (TraceWord α)

/-! ## Section 2: Semantic evaluation -/

variable {α : Type u} {R : Type v} [ChronometricSemiring R]

/-- Evaluate a signed atom. -/
def evalSignedAtom (σ : α → R) : SignedAtom α → R
  | .fwd a => σ a
  | .bwd a => ChronometricSemiring.timeRev (σ a)

/-- Evaluate a trace word (product of signed atoms). -/
def evalWord (σ : α → R) : TraceWord α → R
  | [] => 1
  | s :: w => evalSignedAtom σ s * evalWord σ w

/-- Evaluate a trace normal form (sum of words). -/
def evalNF (σ : α → R) : TraceNormalForm α → R
  | [] => 0
  | w :: ws => evalWord σ w + evalNF σ ws

/-- Evaluate a trace expression in a chronometric semiring. -/
def TraceExpr.eval (σ : α → R) : TraceExpr α → R
  | .zero => 0
  | .one => 1
  | .atom a => σ a
  | .add e f => e.eval σ + f.eval σ
  | .mul e f => e.eval σ * f.eval σ
  | .rev e => ChronometricSemiring.timeRev (e.eval σ)

/-- Evaluation of `rev` commutes with time reversal. -/
theorem TraceExpr.eval_rev (σ : α → R) (e : TraceExpr α) :
    (TraceExpr.rev e).eval σ = ChronometricSemiring.timeRev (e.eval σ) :=
  rfl

/-- Reverse of a product = product of reverses in opposite order.
Bridge: connects to quantum gate reversal: (UV)† = V†U†. -/
theorem TraceExpr.eval_mul_rev (σ : α → R) (e f : TraceExpr α) :
    (TraceExpr.rev (TraceExpr.mul e f)).eval σ =
    (TraceExpr.mul (TraceExpr.rev f) (TraceExpr.rev e)).eval σ := by
  simp only [TraceExpr.eval]
  exact ChronometricSemiring.timeRev_mul (e.eval σ) (f.eval σ)

/-! ## Section 3: Normalization -/

/-- Flip the direction of a signed atom. -/
def SignedAtom.flip : SignedAtom α → SignedAtom α
  | .fwd a => .bwd a
  | .bwd a => .fwd a

/-- Reverse a trace word. -/
def revWord (w : TraceWord α) : TraceWord α :=
  (w.map SignedAtom.flip).reverse

/-- Reverse a trace normal form. -/
def revNF (nf : TraceNormalForm α) : TraceNormalForm α :=
  nf.map revWord

/-- Multiply two normal forms via distribution. -/
def mulNF (nf1 nf2 : TraceNormalForm α) : TraceNormalForm α :=
  nf1.flatMap (fun w1 => nf2.map (fun w2 => w1 ++ w2))

/-- Normalize a trace expression.
Bridge: connects to post_quantum_trace_canonicalization. -/
def TraceExpr.normalize : TraceExpr α → TraceNormalForm α
  | .zero => []
  | .one => [[]]
  | .atom a => [[.fwd a]]
  | .add e f => e.normalize ++ f.normalize
  | .mul e f => mulNF e.normalize f.normalize
  | .rev e => revNF e.normalize

/-! ## Section 4: Soundness of normalization -/

/-- Evaluation of concatenated normal forms is additive. -/
theorem evalNF_append (σ : α → R) (nf1 nf2 : TraceNormalForm α) :
    evalNF σ (nf1 ++ nf2) = evalNF σ nf1 + evalNF σ nf2 := by
  induction nf1 with
  | nil => simp [evalNF]
  | cons w ws ih =>
    show evalWord σ w + evalNF σ (ws ++ nf2) = (evalWord σ w + evalNF σ ws) + evalNF σ nf2
    rw [ih, add_assoc]

/-- Evaluation of concatenated words is multiplicative. -/
theorem evalWord_append (σ : α → R) (w1 w2 : TraceWord α) :
    evalWord σ (w1 ++ w2) = evalWord σ w1 * evalWord σ w2 := by
  induction w1 with
  | nil => simp [evalWord, one_mul]
  | cons s ws ih =>
    show evalSignedAtom σ s * evalWord σ (ws ++ w2) = (evalSignedAtom σ s * evalWord σ ws) * evalWord σ w2
    rw [ih, mul_assoc]

/-- Evaluation of mapped-append normal form. -/
theorem evalNF_map_append (σ : α → R) (w : TraceWord α) (nf : TraceNormalForm α) :
    evalNF σ (nf.map (fun w2 => w ++ w2)) = evalWord σ w * evalNF σ nf := by
  induction nf with
  | nil => simp [evalNF, mul_zero]
  | cons w2 ws ih =>
    show evalWord σ (w ++ w2) + evalNF σ (ws.map (fun w2 => w ++ w2)) = evalWord σ w * (evalWord σ w2 + evalNF σ ws)
    rw [evalWord_append, ih, mul_add]

/-- Evaluation of mulNF equals the product. -/
theorem evalNF_mulNF (σ : α → R) (nf1 nf2 : TraceNormalForm α) :
    evalNF σ (mulNF nf1 nf2) = evalNF σ nf1 * evalNF σ nf2 := by
  induction nf1 with
  | nil => simp [mulNF, evalNF, zero_mul]
  | cons w ws ih =>
    show evalNF σ (nf2.map (fun w2 => w ++ w2) ++ mulNF ws nf2) =
         (evalWord σ w + evalNF σ ws) * evalNF σ nf2
    rw [evalNF_append, evalNF_map_append, ih, add_mul]

/-- Evaluation of a flipped signed atom. -/
theorem evalSignedAtom_flip (σ : α → R) (s : SignedAtom α) :
    evalSignedAtom σ s.flip = ChronometricSemiring.timeRev (evalSignedAtom σ s) := by
  cases s with
  | fwd a => rfl
  | bwd a =>
    show σ a = ChronometricSemiring.timeRev (ChronometricSemiring.timeRev (σ a))
    exact (ChronometricSemiring.timeRev_involutive (σ a)).symm

/-
Evaluation of a reversed word equals timeRev of the original.
-/
theorem evalWord_revWord (σ : α → R) (w : TraceWord α) :
    evalWord σ (revWord w) = ChronometricSemiring.timeRev (evalWord σ w) := by
  induction' w with s w ih;
  · exact ( ‹ChronometricSemiring R›.timeRev_one ) ▸ rfl;
  · unfold revWord; simp +decide [ *, evalWord ] ;
    rw [ evalWord_append ];
    convert congr_arg ( fun x => x * evalSignedAtom σ s.flip ) ih using 1;
    · congr;
      exact show evalSignedAtom σ s.flip * 1 = evalSignedAtom σ s.flip from by rw [ mul_one ] ;
    · rw [ evalSignedAtom_flip, ChronometricSemiring.timeRev_mul ]

/-- Evaluation of a reversed normal form. -/
theorem evalNF_revNF (σ : α → R) (nf : TraceNormalForm α) :
    evalNF σ (revNF nf) = ChronometricSemiring.timeRev (evalNF σ nf) := by
  induction nf with
  | nil =>
    show (0 : R) = ChronometricSemiring.timeRev 0
    exact ChronometricSemiring.timeRev_zero.symm
  | cons w ws ih =>
    show evalWord σ (revWord w) + evalNF σ (ws.map revWord) =
      ChronometricSemiring.timeRev (evalWord σ w + evalNF σ ws)
    have : evalNF σ (ws.map revWord) = evalNF σ (revNF ws) := rfl
    rw [this, evalWord_revWord, ih, ChronometricSemiring.timeRev_add]

/-- **Normalization is semantically sound.**
Bridge: connects to post_quantum_trace_canonicalization. -/
theorem TraceExpr.normalize_sound (σ : α → R) (e : TraceExpr α) :
    evalNF σ e.normalize = e.eval σ := by
  induction e with
  | zero => rfl
  | one =>
    show (1 : R) + 0 = 1
    exact add_zero 1
  | atom a =>
    show evalSignedAtom σ (.fwd a) * 1 + 0 = σ a
    simp [evalSignedAtom, mul_one, add_zero]
  | add e f ihe ihf =>
    show evalNF σ (e.normalize ++ f.normalize) = e.eval σ + f.eval σ
    rw [evalNF_append, ihe, ihf]
  | mul e f ihe ihf =>
    show evalNF σ (mulNF e.normalize f.normalize) = e.eval σ * f.eval σ
    rw [evalNF_mulNF, ihe, ihf]
  | rev e ih =>
    show evalNF σ (revNF e.normalize) = ChronometricSemiring.timeRev (e.eval σ)
    rw [evalNF_revNF, ih]

/-! ## Section 5: Size measures and complexity bounds -/

/-- Syntactic size of a trace expression. -/
def TraceExpr.size : TraceExpr α → Nat
  | .zero => 1
  | .one => 1
  | .atom _ => 1
  | .add e f => e.size + f.size
  | .mul e f => e.size + f.size
  | .rev e => e.size

/-- Every trace expression has positive size. -/
theorem TraceExpr.size_pos (e : TraceExpr α) : 0 < e.size := by
  induction e <;> simp [TraceExpr.size] <;> omega

/-
The size of mulNF is the product of sizes.
-/
theorem mulNF_length (nf1 nf2 : TraceNormalForm α) :
    (mulNF nf1 nf2).length = nf1.length * nf2.length := by
  unfold mulNF; simp +decide;

/-- The size of revNF equals the original size. -/
theorem revNF_length (nf : TraceNormalForm α) :
    (revNF nf).length = nf.length := by
  simp [revNF]

/-
**Post-quantum trace canonicalization bound**:
`‖normalize(e)‖ ≤ 2^(size(e))`.
Bridge: connects to lipschitz_certified_robustness_trace_bound.
-/
theorem post_quantum_trace_canonicalization_bound (e : TraceExpr α) :
    (TraceExpr.normalize e).length ≤ 2 ^ TraceExpr.size e := by
  have h_add : ∀ a b : ℕ, 0 < a → 0 < b → 2 ^ a + 2 ^ b ≤ 2 ^ (a + b) := by
    exact fun a b ha hb => by rw [ pow_add ] ; nlinarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ha, pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) hb ] ;
  induction' e with e ih;
  all_goals norm_num [ TraceExpr.normalize, TraceExpr.size ];
  · exact le_trans ( add_le_add ‹_› ‹_› ) ( h_add _ _ ( TraceExpr.size_pos _ ) ( TraceExpr.size_pos _ ) );
  · rename_i e₁ e₂ ih₁ ih₂;
    exact le_trans ( mulNF_length _ _ ▸ Nat.mul_le_mul ih₁ ih₂ ) ( by rw [ pow_add ] );
  · unfold revNF; aesop;

/-- A trace expression is mul-free if it contains no `mul` nodes. -/
def TraceExpr.isMulFree : TraceExpr α → Bool
  | .zero => true
  | .one => true
  | .atom _ => true
  | .add e f => e.isMulFree && f.isMulFree
  | .mul _ _ => false
  | .rev e => e.isMulFree

/-
**For mul-free expressions, normalization is linear.**
Bridge: connects to lipschitz_certified_robustness_trace_bound.
-/
theorem normalize_size_mul_free_linear (e : TraceExpr α)
    (hfree : e.isMulFree = true) :
    (TraceExpr.normalize e).length ≤ TraceExpr.size e := by
  revert hfree;
  induction' e using TraceExpr.recOn with e ih;
  all_goals simp +decide [ TraceExpr.normalize, TraceExpr.isMulFree ];
  · exact Nat.le_add_left _ _;
  · exact Nat.le_add_left _ _;
  · exact fun h1 h2 => add_le_add ( by solve_by_elim ) ( by solve_by_elim );
  · unfold revNF; aesop;

/-! ## Section 6: Decidable equivalence -/

/-- Decidable syntactic equivalence of normal forms. -/
def TraceExpr.equivNF [DecidableEq α] (e f : TraceExpr α) : Bool :=
  e.normalize == f.normalize

/-- Correctness of normal form equivalence. -/
theorem TraceExpr.equivNF_correct [DecidableEq α] (e f : TraceExpr α) :
    TraceExpr.equivNF e f = true ↔ e.normalize = f.normalize := by
  simp [TraceExpr.equivNF, beq_iff_eq]

/-- Equal normal forms imply equal evaluation.
Bridge: connects to certified_lipschitz_trace_depth_bound. -/
theorem eval_of_equivNF [DecidableEq α] {e f : TraceExpr α}
    (h : TraceExpr.equivNF e f = true) (σ : α → R) :
    e.eval σ = f.eval σ := by
  rw [TraceExpr.equivNF_correct] at h
  have h1 := TraceExpr.normalize_sound σ e
  have h2 := TraceExpr.normalize_sound σ f
  rw [h] at h1
  exact h1.symm.trans h2

/-- Normalization commutes with reversal. -/
theorem normalize_rev_commutes (e : TraceExpr α) :
    (TraceExpr.rev e).normalize = revNF e.normalize :=
  rfl

/-- Normal form of `add e e` has twice the length. -/
theorem normalize_add_self_length (e : TraceExpr α) :
    (TraceExpr.add e e).normalize.length = 2 * e.normalize.length := by
  show (e.normalize ++ e.normalize).length = 2 * e.normalize.length
  simp [List.length_append]; ring

end Chrono