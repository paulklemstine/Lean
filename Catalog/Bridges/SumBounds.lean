/-
# Extensive Complexity Accumulation: Summation Bounds for Certified Length

This file establishes a family of **summation principles** that turn pointwise
(local, per-step) bounds on code/certificate/description lengths into **global
linear-in-horizon** bounds. The key results are:

* `sum_le_sum_of_pointwise_bound` — pointwise comparison implies aggregate comparison (ℕ)
* `sum_le_card_mul_of_uniform_bound` — uniform per-element bound yields `|s| * C` (ℕ)
* `total_length_le_horizon_mul_bound` — time-indexed version over `Finset.range T` (ℕ)
* Real-valued analogues of all the above
* Bridge theorems that compose pointwise bound generators with summation
* `total_golay_block_length` — instantiation: `T` Golay blocks have total length `24 * T`

## Cross-Domain Significance

These theorems formalize the **extensivity principle**: bounded local complexity
implies linear global complexity. This pattern appears in:
- Information theory (bounded expected code length → linear total description length)
- Learning theory (bounded certificate length per layer → linear certification budget)
- Topological data analysis (bounded persistence per feature → linear total persistence)
- Algebraic complexity (bounded decomposition length → linear total symbolic cost)
-/

import Mathlib

open Finset in

/-! ## Core comparison principle -/

/-- Pointwise comparison of functions implies comparison of their sums over a finset.
This is the fundamental engine: if `f a ≤ g a` for all `a ∈ s`, then `∑ f ≤ ∑ g`. -/
theorem sum_le_sum_of_pointwise_bound
    {α : Type*} [DecidableEq α]
    (s : Finset α) (f g : α → ℕ)
    (h : ∀ a ∈ s, f a ≤ g a) :
    ∑ a ∈ s, f a ≤ ∑ a ∈ s, g a :=
  Finset.sum_le_sum h

open Finset in

/-! ## Uniform bound: ℕ version -/

/-- If every value `f a` for `a ∈ s` is bounded by `C`, then the total sum
is at most `|s| * C`. This is the atomic summation engine for complexity accounting. -/
theorem sum_le_card_mul_of_uniform_bound
    {α : Type*} [DecidableEq α]
    (s : Finset α) (f : α → ℕ) (C : ℕ)
    (hC : ∀ a ∈ s, f a ≤ C) :
    ∑ a ∈ s, f a ≤ s.card * C := by
  have h := Finset.sum_le_card_nsmul s f C hC
  rwa [smul_eq_mul] at h

/-- Time-indexed corollary: if each stage `t < T` has length `ℓ t ≤ C`,
then total length over the horizon is at most `T * C`.
This is the precise formal statement of "total code length proportional to `T`." -/
theorem total_length_le_horizon_mul_bound
    (T C : ℕ) (ℓ : ℕ → ℕ)
    (hℓ : ∀ t < T, ℓ t ≤ C) :
    ∑ t ∈ Finset.range T, ℓ t ≤ T * C := by
  have h := sum_le_card_mul_of_uniform_bound (Finset.range T) ℓ C
    (fun a ha => hℓ a (Finset.mem_range.mp ha))
  rwa [Finset.card_range] at h

open Finset in

/-! ## Real-valued versions -/

/-- Real-valued pointwise comparison principle. -/
theorem sum_le_sum_of_pointwise_bound_real
    {α : Type*} [DecidableEq α]
    (s : Finset α) (f g : α → ℝ)
    (h : ∀ a ∈ s, f a ≤ g a) :
    ∑ a ∈ s, f a ≤ ∑ a ∈ s, g a :=
  Finset.sum_le_sum h

/-- Real-valued uniform bound over a finset. -/
theorem sum_le_card_mul_of_uniform_bound_real
    {α : Type*} [DecidableEq α]
    (s : Finset α) (f : α → ℝ) (C : ℝ)
    (hC : ∀ a ∈ s, f a ≤ C) :
    ∑ a ∈ s, f a ≤ (↑s.card : ℝ) * C := by
  have h := Finset.sum_le_card_nsmul s f C hC
  rwa [nsmul_eq_mul] at h

/-- Real-valued time-indexed horizon bound. -/
theorem total_real_length_le_horizon_mul_bound
    (T : ℕ) (C : ℝ) (ℓ : ℕ → ℝ)
    (hℓ : ∀ t < T, ℓ t ≤ C) :
    ∑ t ∈ Finset.range T, ℓ t ≤ (T : ℝ) * C := by
  have h := sum_le_card_mul_of_uniform_bound_real (Finset.range T) ℓ C
    (fun a ha => hℓ a (Finset.mem_range.mp ha))
  rwa [Finset.card_range] at h

/-! ## Bridge theorems: composing pointwise bound generators with summation -/

/-- Bridge theorem (ℕ): if a per-step bound generator `b` satisfies `ℓ t ≤ b t ≤ C`
for all `t < T`, the total length is at most `T * C`. This abstracts the common
pattern where an existing theorem gives a bound at each time step, and summation
yields the total budget. -/
theorem total_length_from_pointwise_bound
    (T : ℕ) (ℓ b : ℕ → ℕ)
    (h : ∀ t < T, ℓ t ≤ b t) (C : ℕ)
    (hC : ∀ t < T, b t ≤ C) :
    ∑ t ∈ Finset.range T, ℓ t ≤ T * C :=
  total_length_le_horizon_mul_bound T C ℓ
    (fun t ht => le_trans (h t ht) (hC t ht))

/-- Bridge theorem (ℝ): real-valued analogue of `total_length_from_pointwise_bound`. -/
theorem total_real_length_from_pointwise_bound
    (T : ℕ) (ℓ b : ℕ → ℝ)
    (h : ∀ t < T, ℓ t ≤ b t) (C : ℝ)
    (hC : ∀ t < T, b t ≤ C) :
    ∑ t ∈ Finset.range T, ℓ t ≤ (T : ℝ) * C :=
  total_real_length_le_horizon_mul_bound T C ℓ
    (fun t ht => le_trans (h t ht) (hC t ht))

/-! ## Constant-function identities -/

/-- Sum of a constant over `Finset.range T`. -/
theorem sum_range_const_nat (T C : ℕ) :
    ∑ _t ∈ Finset.range T, C = T * C := by
  simp [Finset.sum_const, Finset.card_range, smul_eq_mul]

/-! ## Instantiation: Golay code blocks -/

/-- `T` Golay code blocks (each of length 24) have total length `T * 24`.
This instantiates the summation framework with the constant from `golay_code_length`. -/
theorem total_golay_block_length (T : ℕ) :
    ∑ _t ∈ Finset.range T, 24 = T * 24 :=
  sum_range_const_nat T 24

/-! ## Generalized comparison principle (ordered additive commutative monoid) -/

/-- The most general form: pointwise comparison implies aggregate comparison
in any ordered additive commutative monoid with `AddLeftMono`. -/
theorem sum_le_sum_of_pointwise_bound_general
    {α β : Type*} [DecidableEq α]
    [AddCommMonoid β] [PartialOrder β] [AddLeftMono β]
    (s : Finset α) (f g : α → β)
    (h : ∀ a ∈ s, f a ≤ g a) :
    ∑ a ∈ s, f a ≤ ∑ a ∈ s, g a :=
  Finset.sum_le_sum h

/-- General uniform bound in any ordered additive commutative monoid. -/
theorem sum_le_card_nsmul_of_uniform_bound_general
    {α β : Type*} [DecidableEq α]
    [AddCommMonoid β] [PartialOrder β] [AddLeftMono β]
    (s : Finset α) (f : α → β) (C : β)
    (hC : ∀ a ∈ s, f a ≤ C) :
    ∑ a ∈ s, f a ≤ s.card • C :=
  Finset.sum_le_card_nsmul s f C hC

/-! ## Verification of axiom cleanliness -/

#print axioms sum_le_sum_of_pointwise_bound
#print axioms sum_le_card_mul_of_uniform_bound
#print axioms total_length_le_horizon_mul_bound
#print axioms sum_le_sum_of_pointwise_bound_real
#print axioms sum_le_card_mul_of_uniform_bound_real
#print axioms total_real_length_le_horizon_mul_bound
#print axioms total_length_from_pointwise_bound
#print axioms total_real_length_from_pointwise_bound
#print axioms sum_range_const_nat
#print axioms total_golay_block_length
#print axioms sum_le_sum_of_pointwise_bound_general
#print axioms sum_le_card_nsmul_of_uniform_bound_general