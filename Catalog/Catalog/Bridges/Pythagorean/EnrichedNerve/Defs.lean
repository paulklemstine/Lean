/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Enriched Nerve Presheaves for Probabilistic Bisimulation

This file defines finite probabilistic labelled transition systems,
word kernels (the enriched nerve), probabilistic bisimulation,
and matrix semantics — providing a unified categorical framework
that generalizes classical Yoneda-style bisimulation to the
probabilistic setting.

## Main Definitions

* `FinProbLTS` — Finite probabilistic labelled transition system
* `wordKernel` — Distribution-valued presheaf on action words
* `IsProbBisimulation` — Block-mass equality condition
* `NerveEquivalent` — States with identical enriched nerve semantics
* `ProbBisimilar` — Existence of a probabilistic bisimulation relating two states
* `stepMatrix` — Stochastic matrix for a single action
* `wordMatrix` — Product of stochastic matrices along a word

## Main Results

* `wordKernel_append` — Kernel composition = Chapman–Kolmogorov convolution
* `wordKernel_block_invariant` — Enriched nerve is invariant under bisimulation
* `wordKernel_eq_matrixEntry` — Kernel semantics = matrix product semantics
-/

import Mathlib

open Finset BigOperators ENNReal

namespace EnrichedNerve

/-! ## Finite Probabilistic Labelled Transition Systems -/

/-- A finite probabilistic labelled transition system.
Each state–action pair induces a probability distribution over successor states. -/
structure FinProbLTS (State Act : Type*) [Fintype State] where
  step : State → Act → State → ℝ≥0∞
  row_sum_one : ∀ s a, ∑ t, step s a t = 1

variable {State Act : Type*} [Fintype State] [DecidableEq State]

/-! ## Word Kernel: The Enriched Nerve -/

/-- The word kernel: probability of transitioning from `s` to `t` along word `w`.
This is the enriched nerve presheaf valued in distributions. -/
noncomputable def wordKernel (P : FinProbLTS State Act) :
    List Act → State → State → ℝ≥0∞
  | [], s, t => if s = t then 1 else 0
  | a :: w, s, t => ∑ m : State, P.step s a m * wordKernel P w m t

/-- Composition of two kernels by convolution. -/
noncomputable def KernelComp (K L : State → State → ℝ≥0∞) :
    State → State → ℝ≥0∞ :=
  fun s t => ∑ m : State, K s m * L m t

/-! ## Probabilistic Bisimulation -/

/-- A finset `C` is R-closed if it is saturated under `R`. -/
def IsRClosed (R : State → State → Prop) (C : Finset State) : Prop :=
  ∀ s, s ∈ C → ∀ t : State, R s t → t ∈ C

/-- R is a probabilistic bisimulation if related states assign equal
mass to every R-closed block under every action. -/
def IsProbBisimulation (P : FinProbLTS State Act)
    (R : State → State → Prop) : Prop :=
  ∀ s t : State, R s t →
    ∀ a : Act, ∀ C : Finset State, IsRClosed R C →
      ∑ u ∈ C, P.step s a u = ∑ u ∈ C, P.step t a u

/-- Two states are probabilistically bisimilar. -/
def ProbBisimilar (P : FinProbLTS State Act) (s t : State) : Prop :=
  ∃ R : State → State → Prop, IsProbBisimulation P R ∧ R s t

/-- Two states are nerve-equivalent if they assign equal word-kernel
mass to every finset of states. -/
def NerveEquivalent (P : FinProbLTS State Act) (s t : State) : Prop :=
  ∀ w : List Act, ∀ C : Finset State,
    ∑ u ∈ C, wordKernel P w s u = ∑ u ∈ C, wordKernel P w t u

/-! ## Matrix Semantics -/

/-- The stochastic matrix for a single action. -/
noncomputable def stepMatrix (P : FinProbLTS State Act) (a : Act) :
    Matrix State State ℝ≥0∞ :=
  Matrix.of (fun s t => P.step s a t)

/-- The product matrix for a word. -/
noncomputable def wordMatrix (P : FinProbLTS State Act) :
    List Act → Matrix State State ℝ≥0∞
  | [] => 1
  | a :: w => stepMatrix P a * wordMatrix P w

/-! ## Basic Lemmas -/

@[simp]
theorem wordKernel_nil (P : FinProbLTS State Act) (s t : State) :
    wordKernel P [] s t = if s = t then 1 else 0 := rfl

@[simp]
theorem wordKernel_cons (P : FinProbLTS State Act) (a : Act) (w : List Act)
    (s t : State) :
    wordKernel P (a :: w) s t = ∑ m, P.step s a m * wordKernel P w m t := rfl

theorem wordKernel_nil_self (P : FinProbLTS State Act) (s : State) :
    wordKernel P [] s s = 1 := by simp

theorem wordKernel_nil_ne (P : FinProbLTS State Act) {s t : State} (h : s ≠ t) :
    wordKernel P [] s t = 0 := by simp [h]

/-
The word kernel preserves row sums.
-/
theorem wordKernel_row_sum (P : FinProbLTS State Act) (w : List Act)
    (s : State) : ∑ t, wordKernel P w s t = 1 := by
      -- We prove this by induction on the length of the list `w`.
      induction' w with a w ih generalizing s;
      · simp +decide [ wordKernel_nil ];
      · simp +decide only [wordKernel_cons];
        rw [ ← Finset.sum_comm ];
        simp +decide only [← Finset.mul_sum _ _ _, ih, mul_one];
        exact P.row_sum_one s a

/-! ## Theorem 1: Word-Kernel Composition (Chapman–Kolmogorov) -/

/-
The kernel for concatenated words equals the convolution of individual kernels.
-/
theorem wordKernel_append (P : FinProbLTS State Act)
    (u v : List Act) (s t : State) :
    wordKernel P (u ++ v) s t =
      ∑ m, wordKernel P u s m * wordKernel P v m t := by
        induction' u with a u ih generalizing s t;
        · simp +decide [ wordKernel ];
        · simp +decide only [List.cons_append, wordKernel_cons];
          simp +decide only [ih, Finset.sum_mul _ _ _];
          rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; intros ; rw [ Finset.mul_sum _ _ _ ] ; ac_rfl

/-! ## Theorem 3: Word-Kernel = Matrix Entry -/

/-
The word kernel equals the matrix product entry.
-/
theorem wordKernel_eq_matrixEntry (P : FinProbLTS State Act)
    (w : List Act) (s t : State) :
    wordKernel P w s t = wordMatrix P w s t := by
      induction' w with a w ih generalizing s t;
      · simp +decide [ wordKernel_nil, wordMatrix ];
        simp +decide [ Matrix.one_apply ];
      · simp +decide [ stepMatrix, wordMatrix, Matrix.mul_apply, ih ]

/-! ## Theorem 2: Bisimulation Invariance of the Enriched Nerve -/

/-
For a symmetric R-closed set and R-related states, membership is equivalent.
-/
omit [Fintype State] [DecidableEq State] in
theorem rclosed_mem_iff (R : State → State → Prop)
    (hSym : Symmetric R)
    (C : Finset State) (hC : IsRClosed R C)
    (s t : State) (hst : R s t) :
    s ∈ C ↔ t ∈ C := by
      exact ⟨ fun hs => hC s hs t hst, fun ht => hC t ht s ( hSym hst ) ⟩

/-
Base case: block invariance for the empty word.
-/
theorem wordKernel_block_invariant_nil (P : FinProbLTS State Act)
    (R : State → State → Prop) (hSym : Symmetric R)
    (s t : State) (hst : R s t)
    (C : Finset State) (hC : IsRClosed R C) :
    ∑ u ∈ C, wordKernel P [] s u = ∑ u ∈ C, wordKernel P [] t u := by
      -- By definition of wordKernel, we have wordKernel P [] s u = if s = u then 1 else 0.
      have h_wordKernel_nil : ∀ s u, wordKernel P [] s u = if s = u then 1 else 0 :=
        fun s u => wordKernel_nil P s u;
      simp +decide [ h_wordKernel_nil, rclosed_mem_iff _ hSym _ hC _ _ hst ]

/-
**Enriched nerve invariance under probabilistic bisimulation.**
For every word and every R-closed block, bisimulation-related states
assign equal total word-kernel mass.
-/
theorem wordKernel_block_invariant (P : FinProbLTS State Act)
    (R : State → State → Prop)
    (hbis : IsProbBisimulation P R)
    (hSym : Symmetric R)
    (w : List Act) (s t : State) (hst : R s t)
    (C : Finset State) (hC : IsRClosed R C) :
    ∑ u ∈ C, wordKernel P w s u = ∑ u ∈ C, wordKernel P w t u := by
      induction' w with a w ih generalizing s t;
      · exact wordKernel_block_invariant_nil P R hSym s t hst C hC;
      · -- By Fubini's theorem, we can interchange the order of summation.
        have h_fubini : ∑ x ∈ C, ∑ m, P.step s a m * wordKernel P w m x = ∑ m, P.step s a m * ∑ x ∈ C, wordKernel P w m x ∧ ∑ x ∈ C, ∑ m, P.step t a m * wordKernel P w m x = ∑ m, P.step t a m * ∑ x ∈ C, wordKernel P w m x := by
          exact ⟨ Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => by rw [ Finset.mul_sum _ _ _ ] ), Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => by rw [ Finset.mul_sum _ _ _ ] ) ⟩;
        -- By the bisimulation condition, we have $\sum_{m \in C} P.step s a m = \sum_{m \in C} P.step t a m$ for any R-closed set $C$.
        have h_bisim : ∀ (D : Finset State), IsRClosed R D → ∑ m ∈ D, P.step s a m = ∑ m ∈ D, P.step t a m := by
          exact fun D hD => hbis s t hst a D hD;
        -- Apply the bisimulation condition to the set $D = \{m \mid \sum_{x \in C} \text{wordKernel } P w m x = c\}$ for each $c$.
        have h_bisim_apply : ∀ c : ℝ≥0∞, ∑ m ∈ Finset.filter (fun m => ∑ x ∈ C, wordKernel P w m x = c) Finset.univ, P.step s a m = ∑ m ∈ Finset.filter (fun m => ∑ x ∈ C, wordKernel P w m x = c) Finset.univ, P.step t a m := by
          intro c
          apply h_bisim;
          intro m hm n hmn; specialize ih m n hmn; aesop;
        -- By Fubini's theorem, we can interchange the order of summation in the double sum.
        have h_fubini : ∑ m, P.step s a m * ∑ x ∈ C, wordKernel P w m x = ∑ c ∈ Finset.image (fun m => ∑ x ∈ C, wordKernel P w m x) Finset.univ, c * ∑ m ∈ Finset.filter (fun m => ∑ x ∈ C, wordKernel P w m x = c) Finset.univ, P.step s a m ∧ ∑ m, P.step t a m * ∑ x ∈ C, wordKernel P w m x = ∑ c ∈ Finset.image (fun m => ∑ x ∈ C, wordKernel P w m x) Finset.univ, c * ∑ m ∈ Finset.filter (fun m => ∑ x ∈ C, wordKernel P w m x = c) Finset.univ, P.step t a m := by
          constructor <;> rw [ Finset.sum_image' ] <;> simp +decide [ mul_comm ];
          · exact fun m => by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun n hn => by aesop;
          · exact fun m => by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun n hn => by aesop;
        aesop

end EnrichedNerve