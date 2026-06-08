/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Perturbation Amplification: Tensorization under Products

This file establishes the first formal **tensorization law** for tropical perturbation
complexity. The central result is that the log-cardinality complexity measure of a
finite support is **exactly additive** under Cartesian products of supports, and that
the tropical max functional on product supports **decomposes additively** for
separable weights and inputs.

## Main Results

1. **`tropical_perturbation_product_exact`**: The tropical perturbation bound (log-cardinality)
   of a product support equals the sum of the bounds of the factors.

2. **`tropMax_product_separable`**: The tropical max functional on a product support with
   separable weights, evaluated on a separable function, equals the sum of the factor
   functionals.

3. **`tropical_perturbation_separable_product`**: Separable perturbation bounds on
   factors compose additively: factor errors add under product composition.

4. **`tropical_perturbation_product_n_fold`**: The n-fold iterated product has bound
   equal to `n` times the base bound.

5. **`tropical_perturbation_exp_multiplicative`**: After exponentiation, the bound
   becomes multiplicative — connecting to automata counting growth.

## Mathematical Significance

This is the tropical analogue of:
- **Tensorization** in information theory (entropy is additive for independent sources),
- **Direct-sum theorems** in complexity theory (independent instances cost proportionally more),
- **Extensivity** in statistical mechanics (free energy is additive for non-interacting systems),
- **Error exponent additivity** in coding theory (block coding multiplies exponents).

The key insight is that `log(card(S × T)) = log(card S) + log(card T)` is not merely
an arithmetic identity — it reflects the deeper fact that tropical max functionals on
products decompose into sums of independent factor functionals. This converts the
isolated stability estimate of `tropical_perturbation_exact_bound` into a scalable,
compositional invariant.

## References

- Akian, Gaubert, Kolokoltsov: "Idempotent analysis and max-plus algebra"
- Litvinov, Maslov: "Idempotent mathematics and mathematical physics"
-/

noncomputable section

open Finset Real

/-! ## 1. The Tropical Max Functional (Self-Contained) -/

namespace TropicalAmplification

variable {α : Type*} [DecidableEq α]

/-- The tropical max functional: `F(f) = max_{s ∈ S} (f(s) + w(s))`.
    This is the fundamental object of tropical Choquet representation theory. -/
def tropMax (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) (f : α → ℝ) : ℝ :=
  S.sup' hS (fun s => f s + w s)

/-! ## 2. Tropical Perturbation Bound: Log-Cardinality Complexity -/

/-- The **tropical perturbation bound** of a finite support, defined as the natural
    logarithm of its cardinality. This represents the informational complexity or
    "tropical entropy" of the support set.

    The name reflects the role this quantity plays in perturbation theory: it measures
    the dimension of the space of perturbations that can be applied to the tropical
    max functional. The perturbation stability constant is 1 (by
    `tropical_perturbation_exact_bound`), but the complexity of the support — how
    many independent atoms contribute — is captured by this logarithmic measure.

    Key property: this is exactly additive under Cartesian products, making it an
    **extensive thermodynamic variable** in the tropical setting. -/
def tropicalPerturbationBound {α : Type*} (S : Finset α) : ℝ :=
  Real.log (S.card : ℝ)

/-! ## 3. Product Additivity: The Tensorization Theorem -/

/-- Product of nonempty finsets is nonempty. -/
theorem nonempty_product {α β : Type*} (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) : (S ×ˢ T).Nonempty :=
  hS.product hT

/-- The cardinality of a product finset equals the product of cardinalities. -/
theorem card_product_eq {α β : Type*} (S : Finset α) (T : Finset β) :
    (S ×ˢ T).card = S.card * T.card :=
  Finset.card_product S T

/-
**Tropical Perturbation Product Theorem (Main Tensorization Law).**

    The tropical perturbation bound of a product support is the sum of the
    perturbation bounds of the factors:

    `log(card(S × T)) = log(card S) + log(card T)`

    This is the foundational extensivity / tensorization principle for tropical
    perturbation complexity. It converts the one-shot stability estimate of
    `tropical_perturbation_exact_bound` into a compositional, scalable invariant.
-/
theorem tropical_perturbation_product_exact
    {α β : Type*} (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    tropicalPerturbationBound (S ×ˢ T)
      = tropicalPerturbationBound S + tropicalPerturbationBound T := by
  unfold tropicalPerturbationBound;
  rw [ Finset.card_product, Nat.cast_mul, Real.log_mul ] <;> aesop

/-! ## 4. Tropical Max on Products: Separable Decomposition -/

/-
**Finset sup' over products separates for additive functions.**
    `sup'_{(s,t) ∈ S×T} (f(s) + g(t)) = (sup'_{s ∈ S} f(s)) + (sup'_{t ∈ T} g(t))`

    This is the key combinatorial identity underlying tropical tensorization.
-/
theorem finset_sup'_product_add
    {α β : Type*}
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty)
    (f : α → ℝ) (g : β → ℝ) :
    (S ×ˢ T).sup' (hS.product hT) (fun p => f p.1 + g p.2)
      = S.sup' hS f + T.sup' hT g := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
  · exact fun a b ha hb => add_le_add ( Finset.le_sup' f ha ) ( Finset.le_sup' g hb );
  · rcases Finset.exists_mem_eq_sup' hS f with ⟨ a, ha, ha' ⟩ ; rcases Finset.exists_mem_eq_sup' hT g with ⟨ b, hb, hb' ⟩ ; use a, b ; aesop

/-
**Tropical max decomposes on products with separable weights and functions.**

    For product weights `w(s,t) = w₁(s) + w₂(t)` and product functions
    `f(s,t) = f₁(s) + f₂(t)`, the tropical max functional on `S × T` equals
    the sum of the factor functionals:

    `max_{(s,t) ∈ S×T} (f₁(s) + f₂(t) + w₁(s) + w₂(t))`
    `= max_{s ∈ S} (f₁(s) + w₁(s)) + max_{t ∈ T} (f₂(t) + w₂(t))`
-/
theorem tropMax_product_separable
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty)
    (w₁ : α → ℝ) (w₂ : β → ℝ)
    (f₁ : α → ℝ) (f₂ : β → ℝ) :
    tropMax (S ×ˢ T) (hS.product hT)
      (fun p => w₁ p.1 + w₂ p.2) (fun p => f₁ p.1 + f₂ p.2)
    = tropMax S hS w₁ f₁ + tropMax T hT w₂ f₂ := by
  convert finset_sup'_product_add S T hS hT ( fun s => f₁ s + w₁ s ) ( fun t => f₂ t + w₂ t ) using 1;
  grind +locals

/-
**Separable perturbation stability on products.**

    If the factor weights are each ε₁-close and ε₂-close respectively, then the
    product functional with separable weights differs by at most `ε₁ + ε₂`.
    This is the correct compositional perturbation bound: errors from independent
    factors add under product composition.
-/
theorem tropical_perturbation_separable_product
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty)
    (w₁ w₁' : α → ℝ) (w₂ w₂' : β → ℝ) (ε₁ ε₂ : ℝ)
    (h₁ : ∀ s ∈ S, |w₁ s - w₁' s| ≤ ε₁)
    (h₂ : ∀ t ∈ T, |w₂ t - w₂' t| ≤ ε₂) :
    ∀ f : α × β → ℝ,
      |tropMax (S ×ˢ T) (hS.product hT) (fun p => w₁ p.1 + w₂ p.2) f -
       tropMax (S ×ˢ T) (hS.product hT) (fun p => w₁' p.1 + w₂' p.2) f| ≤ ε₁ + ε₂ := by
  intro f;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · unfold tropMax;
    simp +decide [ Finset.sup'_le_iff ];
    intro a b ha hb;
    linarith [ abs_le.mp ( h₁ a ha ), abs_le.mp ( h₂ b hb ), Finset.le_sup' ( fun x => f x + ( w₁' x.1 + w₂' x.2 ) ) ( Finset.mk_mem_product ha hb ) ];
  · rw [ sub_le_iff_le_add', tropMax, tropMax ];
    simp +decide [ Finset.sup'_le_iff ];
    intro a b ha hb;
    linarith [ abs_le.mp ( h₁ a ha ), abs_le.mp ( h₂ b hb ), Finset.le_sup' ( fun s => f s + ( w₁ s.1 + w₂ s.2 ) ) ( Finset.mk_mem_product ha hb ) ]

/-! ## 5. N-fold Amplification -/

/-- Iterated Cartesian product of a finset with itself, producing `Fin n → α`.
    Uses `Fintype.piFinset` for clean cardinality reasoning. -/
def iteratedProduct {α : Type*} [DecidableEq α] (S : Finset α) (n : ℕ) :
    Finset (Fin n → α) :=
  Fintype.piFinset (fun _ => S)

/-- The iterated product of a nonempty finset is nonempty. -/
theorem iteratedProduct_nonempty {α : Type*} [DecidableEq α]
    (S : Finset α) (hS : S.Nonempty) (n : ℕ) :
    (iteratedProduct S n).Nonempty :=
  Fintype.piFinset_nonempty.mpr (fun _ => hS)

/-
The cardinality of an iterated product is a power of the base cardinality.
-/
theorem iteratedProduct_card {α : Type*} [DecidableEq α] (S : Finset α) (n : ℕ) :
    (iteratedProduct S n).card = S.card ^ n := by
  convert Fintype.card_piFinset ( fun _ => S ) using 1;
  simp +decide [ Finset.prod_const ]

/-
**N-fold Tropical Amplification Theorem.**

    The tropical perturbation bound of an n-fold iterated product equals `n` times
    the base bound:  `log(card(S^n)) = n · log(card S)`

    This is the true amplification law, analogous to block coding exponents.
-/
theorem tropical_perturbation_product_n_fold
    {α : Type*} [DecidableEq α] (S : Finset α) (_hS : S.Nonempty)
    (n : ℕ) :
    tropicalPerturbationBound (iteratedProduct S n) =
      n * tropicalPerturbationBound S := by
  unfold tropicalPerturbationBound;
  rw [ iteratedProduct_card, Nat.cast_pow, Real.log_pow ]

/-! ## 6. Exponential Multiplicativity -/

/-
**Exponential multiplicativity of tropical perturbation complexity.**

    After exponentiation, the additive perturbation bound becomes multiplicative:
    `exp(bound(S × T)) = exp(bound(S)) · exp(bound(T))`

    This connects the tropical framework to automata counting: additive tropical
    exponents become multiplicative counting laws.
-/
theorem tropical_perturbation_exp_multiplicative
    {α β : Type*} (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    Real.exp (tropicalPerturbationBound (S ×ˢ T))
      = Real.exp (tropicalPerturbationBound S) *
        Real.exp (tropicalPerturbationBound T) := by
  -- By exponentiating both sides of the additivity theorem, we get the desired result.
  have h_exp : Real.exp (tropicalPerturbationBound (S ×ˢ T)) = Real.exp (tropicalPerturbationBound S + tropicalPerturbationBound T) := by
    exact congr_arg _ ( tropical_perturbation_product_exact S T hS hT );
  rw [ h_exp, Real.exp_add ]

/-! ## 7. Monotonicity and Basic Properties -/

/-
The tropical perturbation bound is nonneg for nonempty supports.
-/
theorem tropicalPerturbationBound_nonneg {α : Type*}
    (S : Finset α) (hS : S.Nonempty) :
    0 ≤ tropicalPerturbationBound S := by
  exact Real.log_nonneg ( mod_cast Finset.card_pos.2 hS )

/-
The perturbation bound is monotone under subset inclusion.
-/
theorem tropicalPerturbationBound_mono {α : Type*} [DecidableEq α]
    (S T : Finset α) (h : S ⊆ T) :
    tropicalPerturbationBound S ≤ tropicalPerturbationBound T := by
  by_cases hS : S.Nonempty;
  · exact Real.log_le_log ( Nat.cast_pos.mpr hS.card_pos ) ( mod_cast Finset.card_le_card h );
  · simp_all +decide [ Finset.not_nonempty_iff_eq_empty.mp hS ];
    unfold tropicalPerturbationBound; norm_num;
    finiteness

/-
Singleton supports have zero perturbation bound.
-/
theorem tropicalPerturbationBound_singleton {α : Type*}
    (a : α) :
    tropicalPerturbationBound ({a} : Finset α) = 0 := by
  -- The cardinality of a singleton set is 1.
  simp [tropicalPerturbationBound]

/-
**Product perturbation converse**: weight perturbations bounded on a product
    support imply functional perturbations bounded by the same quantity.
-/
theorem tropMax_product_perturbation_bound
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : S.Nonempty) (hT : T.Nonempty)
    (w₁ w₂ : α × β → ℝ) (ε : ℝ)
    (hw : ∀ p ∈ S ×ˢ T, |w₁ p - w₂ p| ≤ ε) :
    ∀ f : α × β → ℝ,
      |tropMax (S ×ˢ T) (hS.product hT) w₁ f -
       tropMax (S ×ˢ T) (hS.product hT) w₂ f| ≤ ε := by
  intro f
  unfold tropMax;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · simp +zetaDelta at *;
    exact fun a b ha hb => by linarith [ abs_le.mp ( hw a b ha hb ), Finset.le_sup' ( fun s => f s + w₂ s ) ( Finset.mk_mem_product ha hb ) ] ;
  · simp_all +decide;
    exact fun a b ha hb => by linarith [ abs_le.mp ( hw a b ha hb ), Finset.le_sup' ( fun s => f s + w₁ s ) ( Finset.mk_mem_product ha hb ) ] ;

end TropicalAmplification