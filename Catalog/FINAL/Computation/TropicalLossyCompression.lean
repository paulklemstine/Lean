/-
# Tropical Lagrangian Duality for Lossy Compression

This module establishes a formal bridge between lossy source coding (quantization)
and tropical (min-plus) optimization. The core insight: because the Lagrangian cost
of a deterministic quantizer decomposes as a sum over independent source symbols,
optimal quantization reduces to pointwise min-plus selection — a tropical linear
computation.

## Main Results

* `tropical_lagrangian_quantizer_optimal` — Existence of a globally optimal quantizer
  that achieves the pointwise tropical minimum at every source symbol.
* `tropical_KKT_quantizer_characterization` — A quantizer is globally optimal iff it
  selects a local cost minimizer at every source symbol (tropical KKT conditions).
* `tropical_weak_duality_lossy_compression` — Weak duality between the
  distortion-constrained primal and the Lagrangian dual for finite lossy compression.

## Mathematical Context

These results formalize the statement "lossy compression is tropical optimization."
In the min-plus semiring (ℝ, min, +), the Lagrangian cost functional is a tropical
linear form, and optimality reduces to idempotent active-set selection rather than
analytic subgradient conditions. This opens a path toward verified compression bounds,
tropical dynamic programming, and semiring-native information theory.
-/

import Mathlib

open Finset

/-! ## Core Definitions -/

/-- Local cost of assigning source symbol `x` to reproduction symbol `y`
    at Lagrange multiplier `lam`. This is the per-symbol tropical cost. -/
noncomputable def localCost {α β : Type*} (d : α → β → ℝ) (κ : β → ℝ)
    (lam : ℝ) (x : α) (y : β) : ℝ :=
  d x y + lam * κ y

/-- A quantizer `q` is tropically optimal if it minimizes total Lagrangian cost
    over all quantizers `α → β`. -/
def IsTropicallyOptimal
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (s : Finset α) (w : α → ℝ) (d : α → β → ℝ) (κ : β → ℝ) (lam : ℝ)
    (q : α → β) : Prop :=
  ∀ q' : α → β,
    ∑ x ∈ s, (w x + (d x (q x) + lam * κ (q x)))
      ≤ ∑ x ∈ s, (w x + (d x (q' x) + lam * κ (q' x)))

/-- Primal feasible set: rates achievable under distortion budget `D`. -/
def primalValue
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (s : Finset α) (w : α → ℝ) (d : α → β → ℝ) (κ : β → ℝ) (D : ℝ) : Set ℝ :=
  {r | ∃ q : α → β,
      (∑ x ∈ s, d x (q x)) ≤ D ∧
      r = ∑ x ∈ s, (w x + κ (q x))}

/-- Lagrangian dual value: infimum of the Lagrangian over all quantizers. -/
noncomputable def dualValue
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β] [Nonempty β]
    (s : Finset α) (w : α → ℝ) (d : α → β → ℝ) (κ : β → ℝ) (D lam : ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨fun _ => Classical.arbitrary β, Finset.mem_univ _⟩
    (fun q : α → β =>
      ∑ x ∈ s, (w x + κ (q x)) + lam * ((∑ x ∈ s, d x (q x)) - D))

/-- Update a quantizer at a single source symbol. -/
def updateAt {α β : Type*} [DecidableEq α] (q : α → β) (x₀ : α) (y₀ : β) : α → β :=
  fun x => if x = x₀ then y₀ else q x

/-! ## Helper Lemmas -/

/-- For any function on a nonempty finite type, the `Finset.inf'` is attained. -/
lemma inf'_attained {β : Type*} [Fintype β] [Nonempty β] (f : β → ℝ) :
    ∃ y : β, f y = Finset.inf' Finset.univ Finset.univ_nonempty f := by
  have := Finset.exists_mem_eq_inf' Finset.univ_nonempty f
  tauto

/-- The `Finset.inf'` is a lower bound for all elements. -/
lemma inf'_le_of_mem {β : Type*} [Fintype β] [Nonempty β] (f : β → ℝ) (y : β) :
    Finset.inf' Finset.univ Finset.univ_nonempty f ≤ f y :=
  Finset.inf'_le _ (Finset.mem_univ _)

/-! ## Theorem A: Tropical Separable Dual Collapse -/

/-- **Tropical Lagrangian Quantizer Optimality.**
A globally optimal quantizer exists and achieves the pointwise tropical minimum
at every source symbol. This is the "one-shot min-plus computation" theorem:
the global optimization over all quantizers collapses to independent local
minimizations in the min-plus semiring. -/
theorem tropical_lagrangian_quantizer_optimal
    {α β : Type*} [Fintype β] [DecidableEq β] [Nonempty β]
    (s : Finset α)
    (w : α → ℝ) (d : α → β → ℝ) (κ : β → ℝ) (lam : ℝ) :
    ∃ q : α → β,
      (∀ q' : α → β,
        ∑ x ∈ s, (w x + (d x (q x) + lam * κ (q x)))
          ≤ ∑ x ∈ s, (w x + (d x (q' x) + lam * κ (q' x)))) ∧
      (∀ x ∈ s,
        d x (q x) + lam * κ (q x)
          = Finset.inf' Finset.univ Finset.univ_nonempty
              (fun y : β => d x y + lam * κ y)) := by
  have h_inf : ∀ x ∈ s, ∃ y : β, d x y + lam * κ y =
      (Finset.univ : Finset β).inf' Finset.univ_nonempty (fun y => d x y + lam * κ y) := by
    exact fun x _ => inf'_attained fun y => d x y + lam * κ y
  choose! q hq using h_inf
  use q; simp_all +decide [Finset.sum_add_distrib]
  exact fun q' => by
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_le_sum fun x _ => Finset.inf'_le _ (Finset.mem_univ _)

/-! ## Theorem B: Tropical KKT Characterization -/

/-- **Tropical KKT Characterization of Optimal Quantizers (≤ form).**
A quantizer is globally optimal if and only if at every source symbol
it selects a reproduction symbol achieving the local minimum cost.
This is the tropical analogue of KKT stationarity: no subgradients
are needed because min-plus linearity turns global optimality into
local active-minimizer selection. -/
theorem tropical_KKT_quantizer_characterization
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (s : Finset α)
    (w : α → ℝ) (d : α → β → ℝ) (κ : β → ℝ) (lam : ℝ)
    (q : α → β) :
    IsTropicallyOptimal s w d κ lam q ↔
    ∀ x ∈ s, ∀ y : β,
      d x (q x) + lam * κ (q x) ≤ d x y + lam * κ y := by
  constructor
  · intro h x hx y
    contrapose! h
    unfold IsTropicallyOptimal
    simp +zetaDelta at *
    exact ⟨fun z => if z = x then y else q z,
      Finset.sum_lt_sum (fun x' hx' => by grind) ⟨x, hx, by simpa using h⟩⟩
  · exact fun h q' => Finset.sum_le_sum fun x hx => by linarith [h x hx (q' x)]

/-! ## Theorem C: Weak Duality for Distortion-Constrained Compression -/

/-- **Tropical Weak Duality for Lossy Compression.**
For any non-negative Lagrange multiplier `lam`, the dual value is a lower
bound on every primal feasible cost. This is the finite tropical version
of weak Lagrangian duality: the min-plus dual relaxation underestimates
the distortion-constrained primal. -/
theorem tropical_weak_duality_lossy_compression
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β] [Nonempty β]
    (s : Finset α) (w : α → ℝ) (d : α → β → ℝ) (κ : β → ℝ) (D lam : ℝ)
    (hlam : 0 ≤ lam) :
    ∀ r ∈ primalValue s w d κ D,
      dualValue s w d κ D lam ≤ r := by
  intro r hr
  obtain ⟨q, hq⟩ := hr
  exact le_trans (Finset.inf'_le _ (Finset.mem_univ q)) (by nlinarith)