/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Transition endomorphisms of an endomorphism stream

Given a stream of endomorphisms `f : ℕ → V →ₗ[K] V`, we form the iterated
compositions `compFrom f i n = f (i+n-1) ∘ ... ∘ f i` and the transition
endomorphisms `transEndo f i j = compFrom f i (j - i)`.  We prove the basic
algebraic properties (composition / additivity) and that the rank of these
maps is antitone.
-/
import Mathlib

namespace Catalog.Algebra.TransEndo

open LinearMap Module Cardinal

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- `compFrom f i n` is the composite `f (i+n-1) ∘ ⋯ ∘ f (i+1) ∘ f i`. -/
def compFrom (f : ℕ → V →ₗ[K] V) (i n : ℕ) : V →ₗ[K] V :=
  match n with
  | 0 => LinearMap.id
  | n + 1 => f (i + n) ∘ₗ compFrom f i n

/-- The transition endomorphism from index `i` to index `j`. -/
def transEndo (f : ℕ → V →ₗ[K] V) (i j : ℕ) : V →ₗ[K] V :=
  compFrom f i (j - i)

/-- The empty composite is the identity. -/
theorem compFrom_zero (f : ℕ → V →ₗ[K] V) (i : ℕ) :
    compFrom f i 0 = LinearMap.id := rfl

/-- Recursive step for `compFrom`. -/
theorem compFrom_succ (f : ℕ → V →ₗ[K] V) (i n : ℕ) :
    compFrom f i (n + 1) = f (i + n) ∘ₗ compFrom f i n := rfl

/-
Additivity of `compFrom`: composing `m` then `n` steps.
-/
theorem compFrom_add (f : ℕ → V →ₗ[K] V) (i m n : ℕ) :
    compFrom f i (m + n) = compFrom f (i + m) n ∘ₗ compFrom f i m := by
  induction' n with n ih generalizing i m;
  · simp +decide [ compFrom_zero ];
  · rw [ ← add_assoc, compFrom_succ, ih ];
    rw [ ← LinearMap.comp_assoc, show compFrom f ( i + m ) ( n + 1 ) = f ( i + m + n ) ∘ₗ compFrom f ( i + m ) n from rfl ] ; simp +decide [ add_assoc ]

/-
Transition endomorphisms compose: `i → k` factors as `i → j` then `j → k`.
-/
theorem transEndo_comp (f : ℕ → V →ₗ[K] V) {i j k : ℕ} (hij : i ≤ j) (hjk : j ≤ k) :
    transEndo f i k = transEndo f j k ∘ₗ transEndo f i j := by
  convert compFrom_add f i ( j - i ) ( k - j ) using 1;
  · rw [ show j - i + ( k - j ) = k - i by omega, transEndo ];
  · simp +decide [ hij, transEndo ]

/-
The rank of `compFrom` is antitone in the number of steps.
-/
theorem rank_compFrom_antitone (f : ℕ → V →ₗ[K] V) (i : ℕ) {n m : ℕ} (h : n ≤ m) :
    (compFrom f i m).rank ≤ (compFrom f i n).rank := by
  rw [ show m = n + ( m - n ) by rw [ Nat.add_sub_of_le h ], compFrom_add f i n ( m - n ) ] ; exact LinearMap.rank_comp_le_right _ _;

/-
The rank of the transition endomorphism is antitone in the target index.
-/
theorem rank_transEndo_antitone (f : ℕ → V →ₗ[K] V) {i j k : ℕ} (hij : i ≤ j) (hjk : j ≤ k) :
    (transEndo f i k).rank ≤ (transEndo f i j).rank := by
  rw [ transEndo_comp f hij hjk ] ; exact LinearMap.rank_comp_le_right _ _;

end Catalog.Algebra.TransEndo