import Mathlib

/-!
# Semiring-Relative Mathematical Reality

## Overview

This module formalizes the thesis that **different semirings support different mathematics**.
We prove that idempotent semirings collapse multiplicity information, so that polynomial
evaluation depends only on which monomials appear (the *support*), not on how many times
they appear. We then exhibit a concrete separating witness showing that this collapse
is genuinely non-trivial: the same expression evaluates differently over `ℕ`.

## Main Results

* `evalListIdem_dedup` — In any idempotent commutative semiring, list-based
  polynomial evaluation is invariant under deduplication. This is the **Alien Shadow
  Theorem**: multiplicity disappears for idempotent civilizations.

* `evalListIdem_perm_dedup` — Evaluation is invariant under any rewriting that
  preserves the underlying set of exponents (permutation of dedup).

* `separation_nat_vs_idempotent` — There exists a concrete list and evaluation point
  where `ℕ`-evaluation distinguishes the original list from its dedup.

* `tropical_not_nat_separator` — The canonical multiplicity-collapse separator:
  `max a a = a` holds universally over `ℝ` with `max`, but `n + n = n` fails in `ℕ`.

* `eval_support_invariance` — In a finset-based formulation, polynomial evaluation
  with arbitrary positive coefficients equals evaluation with unit coefficients.

* `counting_obstruction` — In `ℕ`, evaluation recovers list length (counting);
  in an idempotent semiring, this information is irreversibly destroyed.

## Interpretation

Classical civilizations (over `ℕ`, `ℤ`, `ℚ`, `ℝ`) perceive multiplicity-sensitive
identities. Tropical/idempotent civilizations perceive only support and extremal
structure. The overlap — the **combinatorial core** — is exactly the set of identities
that depend only on which monomials have nonzero coefficients.
-/

open Finset List

noncomputable section

/-! ## Part 1: List-based polynomial evaluation -/

/-- Evaluate a list of exponents as a polynomial expression `∑ xⁱ` ∈ a commutative semiring.
    Each entry `i` in the list contributes a term `x ^ i`. -/
def evalListSemiring {α : Type*} [CommSemiring α] (x : α) : List ℕ → α
  | [] => 0
  | i :: is => x ^ i + evalListSemiring x is

/-! ## Part 2: Idempotent addition collapses duplicates -/

/-- In an idempotent commutative semiring, `a + a = a`. -/
theorem idem_add_self {α : Type*} [IdemCommSemiring α] (a : α) : a + a = a := by
  simp [IdemSemiring.add_eq_sup]

/-
Prepending a duplicate exponent doesn't change evaluation in an
    idempotent commutative semiring.
-/
theorem evalListSemiring_cons_mem
    {α : Type*} [IdemCommSemiring α]
    (x : α) (i : ℕ) (L : List ℕ) (h : i ∈ L) :
    evalListSemiring x (i :: L) = evalListSemiring x L := by
  induction L <;> simp_all +decide [ evalListSemiring ];
  cases h <;> simp_all +decide [ ← add_assoc, idem_add_self ];
  -- Apply the idempotence property of addition in the semiring.
  have h_idempotent : x ^ i + x ^ ‹_› = x ^ ‹_› + x ^ i := by
    exact add_comm _ _;
  rw [ h_idempotent, add_assoc, ‹x ^ i + evalListSemiring x _ = evalListSemiring x _› ]

/-- **Alien Shadow Theorem (List version)**: In any idempotent commutative semiring,
    evaluation of a list of exponents depends only on its deduplication — i.e.,
    only on which monomials appear, not on how many times.

    This is the formal nucleus of "alien mathematics": a civilization built on
    idempotent arithmetic literally cannot distinguish repeated monomials. -/
theorem evalListIdem_dedup
    {α : Type*} [IdemCommSemiring α]
    (x : α) (L : List ℕ) :
    evalListSemiring x L.dedup = evalListSemiring x L := by
  induction L with
  | nil => simp [List.dedup]
  | cons a L' ih =>
    rw [List.dedup_cons]
    split
    · next h =>
      rw [ih, evalListSemiring_cons_mem x a L' h]
    · next h =>
      simp only [evalListSemiring]
      rw [ih]

/-! ## Part 3: Separation — ℕ distinguishes what idempotent semirings cannot -/

/-- **Separation Theorem**: There exists a list and evaluation point where
    `ℕ`-evaluation of the list differs from evaluation of its dedup. -/
theorem separation_nat_vs_idempotent :
    ∃ (L : List ℕ) (x : ℕ),
      evalListSemiring x L ≠ evalListSemiring x L.dedup := by
  exact ⟨[0, 0], 1, by native_decide⟩

/-- **The canonical separator**: `max a a = a` for all reals, but `n + n = n`
    fails in ℕ. -/
theorem tropical_not_nat_separator :
    (∀ a : ℝ, max a a = a) ∧ ¬(∀ n : ℕ, n + n = n) := by
  exact ⟨fun a => max_self a, fun h => by have := h 1; omega⟩

/-! ## Part 4: Coefficient invariance -/

/-- In an idempotent commutative semiring, `n • a = a` for any `n ≥ 1`. -/
theorem nsmul_eq_self_of_idem {α : Type*} [IdemCommSemiring α]
    (a : α) (n : ℕ) (hn : 1 ≤ n) :
    n • a = a := by
  induction n with
  | zero => omega
  | succ m ih =>
    cases m with
    | zero => simp
    | succ k =>
      rw [succ_nsmul, ih (by omega), idem_add_self]

/-- Summing `x ^ i + x ^ i` over a finset equals summing `x ^ i`. -/
theorem eval_eq_eval_doubled
    {α : Type*} [IdemCommSemiring α]
    (x : α) (s : Finset ℕ) :
    (∑ i ∈ s, (x ^ i + x ^ i)) = ∑ i ∈ s, x ^ i := by
  congr 1; ext i; exact idem_add_self (x ^ i)

/-- **Support Invariance Theorem**: In an idempotent commutative semiring,
    evaluation with any positive natural-number coefficients equals evaluation
    with unit coefficients. -/
theorem eval_support_invariance
    {α : Type*} [IdemCommSemiring α]
    (x : α) (s : Finset ℕ) (c : ℕ → ℕ) (hc : ∀ i ∈ s, 1 ≤ c i) :
    (∑ i ∈ s, (c i) • (x ^ i)) = ∑ i ∈ s, x ^ i := by
  apply Finset.sum_congr rfl
  intro i hi
  exact nsmul_eq_self_of_idem (x ^ i) (c i) (hc i hi)

/-! ## Part 5: Permutation invariance -/

/-- Evaluation over a list is additive. -/
theorem evalListSemiring_append
    {α : Type*} [CommSemiring α] (x : α) (L M : List ℕ) :
    evalListSemiring x (L ++ M) = evalListSemiring x L + evalListSemiring x M := by
  induction L with
  | nil => simp [evalListSemiring]
  | cons a L' ih => simp only [List.cons_append, evalListSemiring, ih, add_assoc]

/-- Evaluation is invariant under list permutation. -/
theorem evalListSemiring_perm
    {α : Type*} [CommSemiring α] (x : α) {L M : List ℕ} (h : L.Perm M) :
    evalListSemiring x L = evalListSemiring x M := by
  induction h with
  | nil => rfl
  | cons a _ ih => simp only [evalListSemiring]; rw [ih]
  | swap a b L' => simp only [evalListSemiring]; ring
  | trans _ _ ih1 ih2 => exact ih1.trans ih2

/-- **Combinatorial Core Theorem**: Two lists with the same deduplicated content
    (up to permutation) evaluate identically in any idempotent commutative semiring. -/
theorem evalListIdem_perm_dedup
    {α : Type*} [IdemCommSemiring α]
    (x : α) (L M : List ℕ) (h : L.dedup.Perm M.dedup) :
    evalListSemiring x L = evalListSemiring x M := by
  rw [← evalListIdem_dedup x L, ← evalListIdem_dedup x M]
  exact evalListSemiring_perm x h

/-! ## Part 6: Concrete examples -/

/-- Evaluation of `[0, 0]` in ℕ at x=1 gives 2. -/
theorem eval_duplicate_nat :
    evalListSemiring (1 : ℕ) [0, 0] = 2 := by native_decide

/-- Evaluation of the dedup `[0]` in ℕ at x=1 gives 1. -/
theorem eval_dedup_nat :
    evalListSemiring (1 : ℕ) [0, 0].dedup = 1 := by native_decide

theorem multiplicity_sensitive_example :
    evalListSemiring (1 : ℕ) [0, 1, 0, 1, 1] ≠ evalListSemiring (1 : ℕ) [0, 1] := by
  native_decide

/-! ## Part 7: Quantum obstruction — multiplicity destruction -/

/-- In ℕ, evaluation of a list of all-zero exponents at x=1 recovers the list length. -/
theorem nat_eval_counts_length :
    ∀ (L : List ℕ), (∀ i ∈ L, i = 0) →
      evalListSemiring (1 : ℕ) L = L.length := by
  intro L hL
  induction L with
  | nil => simp [evalListSemiring]
  | cons a L' ih =>
    simp only [evalListSemiring, List.length_cons]
    have ha : a = 0 := hL a List.mem_cons_self
    subst ha; simp
    have ih' := ih (fun i hi => hL i (List.mem_cons_of_mem 0 hi))
    omega

/-- In an idempotent commutative semiring, any nonempty all-zero-exponent list
    evaluates to 1 at x=1. Length information is destroyed. -/
theorem idem_eval_loses_length
    {α : Type*} [IdemCommSemiring α]
    (L : List ℕ) (hL : ∀ i ∈ L, i = 0) (hne : L ≠ []) :
    evalListSemiring (1 : α) L = 1 := by
  induction L with
  | nil => exact absurd rfl hne
  | cons a L' ih =>
    have ha : a = 0 := hL a List.mem_cons_self
    subst ha
    simp only [evalListSemiring, pow_zero]
    cases L' with
    | nil => simp [evalListSemiring]
    | cons b L'' =>
      rw [ih (fun i hi => hL i (List.mem_cons_of_mem 0 hi)) (List.cons_ne_nil b L'')]
      exact idem_add_self 1

/-- **Counting Obstruction**: In ℕ, list length is recoverable from evaluation;
    but different-length constant lists evaluate differently, so idempotent collapse
    irreversibly destroys counting information. -/
theorem counting_obstruction :
    (∀ n : ℕ, evalListSemiring (1 : ℕ) (List.replicate (n + 1) 0) = n + 1) ∧
    ¬(∀ n : ℕ, evalListSemiring (1 : ℕ) (List.replicate (n + 1) 0) =
      evalListSemiring (1 : ℕ) (List.replicate 1 0)) := by
  constructor
  · intro n
    rw [nat_eval_counts_length _ (fun i hi => List.eq_of_mem_replicate hi),
        List.length_replicate]
  · intro h
    have h2 := h 1
    simp [evalListSemiring] at h2

end