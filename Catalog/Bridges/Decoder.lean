/-
Copyright (c) 2025 Tropical Closure Coding Theory. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Closure Coding Theory — Decoder

This file defines the tropical nearest-codeword decoder and proves its correctness.

## Main Definitions

* `repairCost` — The weighted cost of repairing a set to a target (insertion-only model).
* `tropicalDecode` — The decoder: computes the closure as the minimum-cost repair.

## Main Results

* `tropicalDecode_eq_closure` — **Theorem B (strong)**: The decoder computes exactly the closure.
* `tropicalDecode_spec` — **Theorem B**: The decoder output is closed, contains the input,
  and minimizes repair cost among all closed supersets.
-/

import Mathlib
import Bridges.TropicalClosureCoding.Basic

noncomputable section

open Classical

universe u

variable {α : Type u} [DecidableEq α]

/-- Weighted repair cost (insertion-only model):
    the sum of weights of elements in `y \ x`.
    This measures the cost of adding elements to `x` to reach `y`. -/
noncomputable def repairCost [Fintype α] (w : α → ℕ) (x y : Set α) : ℕ :=
  ∑ a : α, if a ∈ y ∧ a ∉ x then w a else 0

/-- A weight function is strictly positive if every element has positive weight. -/
def StrictlyPositiveWeight (w : α → ℕ) : Prop :=
  ∀ a, 0 < w a

/-- The tropical decoder: for insertion-only repair, the decoder is simply the closure.
    This is the key insight — the closure operator IS the nearest-codeword decoder. -/
noncomputable def tropicalDecode (C : ClosureCode α) (x : Set α) : Set α :=
  C.cl x

/-- Repair cost is monotone: if z ⊆ y and both contain x, then cost(x→z) ≤ cost(x→y). -/
theorem repairCost_mono [Fintype α] (w : α → ℕ) (x y z : Set α)
    (hxz : x ⊆ z) (hzy : z ⊆ y) :
    repairCost w x z ≤ repairCost w x y := by
  unfold repairCost
  apply Finset.sum_le_sum
  intro a _
  split_ifs with h1 h2
  · exact le_rfl
  · push_neg at h2
    exact absurd (hzy h1.1) (by tauto)
  · exact Nat.zero_le _
  · exact le_rfl

/-- **Theorem B (Strong Form — Decoder equals closure):**
    The tropical decoder computes exactly the closure operator. -/
theorem tropicalDecode_eq_closure (C : ClosureCode α) (x : Set α) :
    tropicalDecode C x = C.cl x :=
  rfl

/-- **Theorem B (Specification Form):**
    The tropical decoder output is:
    1. Closed (a valid codeword)
    2. Contains the input
    3. Minimizes repair cost among all closed supersets -/
theorem tropicalDecode_spec [Fintype α]
    (C : ClosureCode α) (w : α → ℕ) (x : Set α) :
    C.IsClosed (tropicalDecode C x) ∧
    x ⊆ tropicalDecode C x ∧
    ∀ y, C.IsClosed y → x ⊆ y →
      repairCost w x (tropicalDecode C x) ≤ repairCost w x y := by
  refine ⟨C.cl_isClosed x, C.subset_cl x, fun y hy hxy => ?_⟩
  apply repairCost_mono
  · exact C.subset_cl x
  · exact C.cl_least_closed_superset x y hy hxy

/-- The decoder preserves closed sets: decoding a codeword returns it unchanged. -/
theorem tropicalDecode_of_closed {α : Type*}
    (C : ClosureCode α) {x : Set α} (hx : C.IsClosed x) :
    tropicalDecode C x = x :=
  C.cl_of_isClosed hx

/-- The repair cost from a set to its closure is zero iff the set is already closed. -/
theorem repairCost_closure_eq_zero_iff {α : Type*} [Fintype α]
    (C : ClosureCode α) (w : α → ℕ)
    (hw : StrictlyPositiveWeight w) (x : Set α) :
    repairCost w x (C.cl x) = 0 ↔ C.IsClosed x := by
  constructor
  · intro h
    unfold repairCost at h
    rw [Finset.sum_eq_zero_iff] at h
    unfold ClosureCode.IsClosed
    ext a
    constructor
    · intro ha
      by_contra hna
      have := h a (Finset.mem_univ a)
      simp only [ite_eq_right_iff] at this
      exact absurd (this ⟨ha, hna⟩).symm (by linarith [hw a])
    · intro ha
      exact C.extensive x ha
  · intro h
    unfold repairCost
    apply Finset.sum_eq_zero
    intro a _
    split_ifs with hc
    · exact absurd (h ▸ hc.1 : a ∈ x) hc.2
    · rfl

/-- The syndrome of the decoded output is always zero. -/
theorem syndrome_tropicalDecode_eq_zero
    (C : ClosureCode α) (P : ClosurePresentation α)
    (hpres : PresentsClosure C P) (x : Set α) :
    syndrome P (tropicalDecode C x) = 0 :=
  syndrome_eq_zero_of_closed C P hpres (C.cl_isClosed x)

end