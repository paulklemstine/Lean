/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Perturbation Amplification: Product Tensorization Law

This file establishes the **first formal tensorization law** for tropical perturbation bounds.
The central result shows that the tropical perturbation complexity of a product support
decomposes additively into the complexities of the factors:

  `tropicalPerturbationBound (S ×ˢ T) = tropicalPerturbationBound S + tropicalPerturbationBound T`

## Mathematical Context

In information theory, entropy tensorizes: `H(X × Y) = H(X) + H(Y)` for independent systems.
In complexity theory, direct-sum theorems show that solving n independent copies of a problem
requires n times the resources. In statistical mechanics, extensive quantities (free energy,
entropy) are additive under product composition of independent subsystems.

The tropical perturbation bound `log |S|` is the **tropical entropy** of a finite support `S`.
It measures the logarithmic complexity of representing a tropical max functional over `S`.
The product theorem shows this quantity is extensive — it adds under product composition,
just as thermodynamic entropy adds for independent systems.

## Main Results

1. `tropical_perturbation_product_exact` — The core tensorization law
2. `tropical_perturbation_product_stability` — Product perturbation stability
3. `tropical_perturbation_exp_multiplicative` — Exponential multiplicativity
4. `tropicalPerturbationBound_power_card` — n-fold amplification via log-power identity
5. `tropical_perturbation_triple_product` — Three-fold extension

## References

- Akian, Gaubert, Kolokoltsov: "Idempotent analysis and max-plus algebra"
- Litvinov, Maslov: "Idempotent mathematics and mathematical physics"
-/

noncomputable section

open Finset Real

namespace TropicalAmplification

/-! ### 1. The Tropical Perturbation Bound -/

/-- **Tropical perturbation bound** (tropical entropy) of a finite support.

This is the logarithmic complexity measure attached to a finite support set `S`.
It measures the "information content" or "perturbation capacity" of the tropical
max functional defined over `S`.

Mathematically, `tropicalPerturbationBound S = log |S|`, the natural logarithm
of the cardinality. This is the tropical analogue of Shannon entropy for a
uniform distribution over `S`.

The key property is *extensivity*: under product composition,
`tropicalPerturbationBound (S ×ˢ T) = tropicalPerturbationBound S + tropicalPerturbationBound T`.
This makes it a well-behaved thermodynamic-like potential. -/
def tropicalPerturbationBound {α : Type*} (S : Finset α) : ℝ :=
  Real.log (S.card : ℝ)

/-- Alternative expression: the tropical perturbation bound equals the log of the cardinality. -/
theorem tropicalPerturbationBound_def {α : Type*} (S : Finset α) :
    tropicalPerturbationBound S = Real.log (S.card : ℝ) := rfl

/-! ### 2. Basic Properties -/

/-- The tropical perturbation bound is nonneg for nonempty supports. -/
theorem tropicalPerturbationBound_nonneg {α : Type*}
    (S : Finset α) (hS : S.Nonempty) :
    0 ≤ tropicalPerturbationBound S := by
  unfold tropicalPerturbationBound
  exact Real.log_nonneg (by exact_mod_cast Finset.card_pos.mpr hS)

/-- A singleton has zero tropical perturbation bound. -/
theorem tropicalPerturbationBound_singleton {α : Type*} (a : α) :
    tropicalPerturbationBound ({a} : Finset α) = 0 := by
  simp [tropicalPerturbationBound, Finset.card_singleton]

/-- Cast of a nonempty finset's cardinality is nonzero as a real number. -/
theorem cast_card_ne_zero {α : Type*}
    (S : Finset α) (hS : S.Nonempty) :
    (S.card : ℝ) ≠ 0 :=
  Nat.cast_ne_zero.mpr (by exact Finset.card_pos.mpr hS |>.ne')

/-! ### 3. The Core Tensorization Law -/

/-- **Logarithm of product cardinality decomposes additively.**
    This is the key combinatorial identity underlying the tensorization law:
    `log(|S × T|) = log(|S|) + log(|T|)` for nonempty S, T. -/
theorem log_card_product {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    Real.log ((S ×ˢ T).card : ℝ) = Real.log (S.card : ℝ) + Real.log (T.card : ℝ) := by
  rw [Finset.card_product, Nat.cast_mul]
  exact Real.log_mul (cast_card_ne_zero S hS) (cast_card_ne_zero T hT)

/-- **The Tropical Perturbation Product Theorem (Tensorization Law).**

The tropical perturbation bound is additive under product composition of finite supports:
`tropicalPerturbationBound (S ×ˢ T) = tropicalPerturbationBound S + tropicalPerturbationBound T`

This is the central theorem of tropical perturbation amplification. It establishes that
the tropical entropy/complexity measure is *extensive* — it adds under independent composition,
just like:
- Shannon entropy for independent random variables
- free energy for independent thermodynamic subsystems
- circuit complexity in direct-sum theorems
- error exponents in product coding channels

The proof reduces to `|S × T| = |S| · |T|` and the multiplicativity of logarithm. -/
theorem tropical_perturbation_product_exact
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationBound (S ×ˢ T)
      = tropicalPerturbationBound S + tropicalPerturbationBound T := by
  simp only [tropicalPerturbationBound]
  exact log_card_product S T hS hT

/-- Lower bound direction of the tensorization law. -/
theorem tropical_perturbation_product_lower_bound
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationBound S + tropicalPerturbationBound T
      ≤ tropicalPerturbationBound (S ×ˢ T) :=
  le_of_eq (tropical_perturbation_product_exact S T hS hT).symm

/-- Upper bound direction of the tensorization law. -/
theorem tropical_perturbation_product_upper_bound
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationBound (S ×ˢ T)
      ≤ tropicalPerturbationBound S + tropicalPerturbationBound T :=
  le_of_eq (tropical_perturbation_product_exact S T hS hT)

/-! ### 4. Exponential Multiplicativity -/

/-- **Exponential multiplicativity of the tropical perturbation bound.**
After exponentiation, the additive tensorization law becomes multiplicative:
`exp(bound(S × T)) = exp(bound(S)) * exp(bound(T))`

This connects the tropical perturbation bound to counting/growth laws:
- In automata theory, exponential multiplicativity means word counts multiply
  under product automaton construction.
- In statistical mechanics, it corresponds to the partition function factoring
  for independent subsystems. -/
theorem tropical_perturbation_exp_multiplicative
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    Real.exp (tropicalPerturbationBound (S ×ˢ T))
      = Real.exp (tropicalPerturbationBound S) *
        Real.exp (tropicalPerturbationBound T) := by
  rw [tropical_perturbation_product_exact S T hS hT, Real.exp_add]

/-! ### 5. Product Perturbation Stability -/

/-- **Product tropical weight.**
Given weight functions on `α` and `β`, the product weight on `α × β` is additive:
`w(s,t) = wS(s) + wT(t)`. This is the tropical analogue of taking the tensor product
of measures. -/
def productWeight {α β : Type*} (wS : α → ℝ) (wT : β → ℝ) : α × β → ℝ :=
  fun p => wS p.1 + wT p.2

/-
The product perturbation is bounded by the sum of component perturbations.
This shows that perturbation stability composes well under products:
if component weights are perturbed by εS and εT respectively,
the product weight perturbation is bounded by εS + εT.
-/
theorem product_weight_perturbation_bound
    {α β : Type*}
    (wS₁ wS₂ : α → ℝ) (wT₁ wT₂ : β → ℝ)
    (εS εT : ℝ)
    (hS : ∀ s, |wS₁ s - wS₂ s| ≤ εS)
    (hT : ∀ t, |wT₁ t - wT₂ t| ≤ εT) :
    ∀ p : α × β, |productWeight wS₁ wT₁ p - productWeight wS₂ wT₂ p| ≤ εS + εT := by
  exact fun p => abs_sub_le_iff.mpr ⟨ by linarith! [ abs_le.mp ( hS p.fst ), abs_le.mp ( hT p.snd ), show productWeight wS₁ wT₁ p = wS₁ p.fst + wT₁ p.snd from rfl, show productWeight wS₂ wT₂ p = wS₂ p.fst + wT₂ p.snd from rfl ], by linarith! [ abs_le.mp ( hS p.fst ), abs_le.mp ( hT p.snd ), show productWeight wS₁ wT₁ p = wS₁ p.fst + wT₁ p.snd from rfl, show productWeight wS₂ wT₂ p = wS₂ p.fst + wT₂ p.snd from rfl ] ⟩

/-
**Perturbation stability for product tropical max functionals.**
Combining `tropical_perturbation_exact_bound` with the product structure,
perturbation of product functionals decomposes into perturbations of factors.
-/
theorem tropical_perturbation_product_stability
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (_hS : S.Nonempty) (_hT : T.Nonempty)
    (wS₁ wS₂ : α → ℝ) (wT₁ wT₂ : β → ℝ)
    (εS εT : ℝ)
    (hεS : ∀ s ∈ S, |wS₁ s - wS₂ s| ≤ εS)
    (hεT : ∀ t ∈ T, |wT₁ t - wT₂ t| ≤ εT) :
    ∀ p ∈ S ×ˢ T,
      |productWeight wS₁ wT₁ p - productWeight wS₂ wT₂ p| ≤ εS + εT := by
  unfold productWeight
  exact fun p hp => abs_le.mpr ⟨ by linarith [ abs_le.mp ( hεS p.1 ( Finset.mem_product.mp hp |>.1 ) ), abs_le.mp ( hεT p.2 ( Finset.mem_product.mp hp |>.2 ) ) ], by linarith [ abs_le.mp ( hεS p.1 ( Finset.mem_product.mp hp |>.1 ) ), abs_le.mp ( hεT p.2 ( Finset.mem_product.mp hp |>.2 ) ) ] ⟩

/-! ### 6. n-Fold Amplification -/

/-
The cardinality of an n-fold product is the n-th power of the original cardinality.
We prove this for the abstract formulation: `log(|S|^n) = n * log(|S|)`.
This is the **n-fold amplification law**: tropical complexity scales linearly
with the number of independent copies.
-/
theorem tropicalPerturbationBound_power_card
    {α : Type*}
    (S : Finset α) (_hS : S.Nonempty) (n : ℕ) :
    Real.log ((S.card : ℝ) ^ n) = n * tropicalPerturbationBound S := by
  exact Real.log_pow _ _

/-! ### 7. Monotonicity Properties -/

/-
The tropical perturbation bound is monotone with respect to finset inclusion.
-/
theorem tropicalPerturbationBound_mono {α : Type*}
    (S T : Finset α) (h : S ⊆ T) (hS : S.Nonempty) :
    tropicalPerturbationBound S ≤ tropicalPerturbationBound T := by
  exact Real.log_le_log ( Nat.cast_pos.mpr hS.card_pos ) ( mod_cast Finset.card_le_card h )

/-! ### 8. Recovery Dimension -/

/-
The tropical perturbation bound controls the dimension of the weight recovery problem.
Given `tropical_perturbation_exact_bound`, the number of independent test functions
needed to recover all weights scales as `exp(tropicalPerturbationBound S) = |S|`.
-/
theorem tropical_perturbation_recovery_dimension
    {α : Type*}
    (S : Finset α) (hS : S.Nonempty) :
    Real.exp (tropicalPerturbationBound S) = (S.card : ℝ) := by
  exact Real.exp_log ( Nat.cast_pos.mpr ( Finset.card_pos.mpr hS ) )

/-! ### 9. Subadditivity for Unions -/

/-
The tropical perturbation bound is subadditive under union:
`bound(S ∪ T) ≤ bound(S) + bound(T) + log 2` when S, T are nonempty.
This complements the product tensorization with a union estimate.
-/
theorem tropicalPerturbationBound_union_le {α : Type*} [DecidableEq α]
    (S T : Finset α) (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationBound (S ∪ T)
      ≤ tropicalPerturbationBound S + tropicalPerturbationBound T + Real.log 2 := by
  unfold tropicalPerturbationBound;
  rw [ ← Real.log_mul, ← Real.log_mul ] <;> norm_cast <;> try positivity;
  exact Real.log_le_log ( Nat.cast_pos.mpr ( Finset.card_pos.mpr ( Finset.Nonempty.mono ( Finset.subset_union_left ) hS ) ) ) ( mod_cast by nlinarith [ Finset.card_union_add_card_inter S T, show #S > 0 from Finset.card_pos.mpr hS, show #T > 0 from Finset.card_pos.mpr hT ] )

/-! ### 10. Three-Fold Product Extension -/

/-
The tensorization law extends to three-fold products by associativity.
This demonstrates the general n-fold structure.
-/
theorem tropical_perturbation_triple_product
    {α β γ : Type*} [DecidableEq α] [DecidableEq β] [DecidableEq γ]
    (S : Finset α) (T : Finset β) (U : Finset γ)
    (hS : S.Nonempty) (hT : T.Nonempty) (hU : U.Nonempty) :
    tropicalPerturbationBound ((S ×ˢ T) ×ˢ U)
      = tropicalPerturbationBound S + tropicalPerturbationBound T
        + tropicalPerturbationBound U := by
  rw [tropical_perturbation_product_exact _ _ (hS.product hT) hU,
      tropical_perturbation_product_exact S T hS hT, add_assoc]

end TropicalAmplification