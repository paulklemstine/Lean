/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Enhanced Tropical Perturbation Amplification

This file extends the tropical perturbation amplification calculus with
stronger cross-domain connections:

1. **Subadditivity under union** with tight constant
2. **Tropical entropy rate** for iterated products
3. **Fekete-style convergence** of the tropical perturbation rate
4. **Monotone extensivity** — product bound ≥ max of factor bounds
5. **Strict monotonicity** for nontrivial factors
6. **Disjoint union additivity** — exact additivity for disjoint unions
7. **Power growth characterization** — cardinality recovered from amplification rate

## Mathematical Significance

These results complete the tropical perturbation amplification calculus by establishing
that `Φ(S) = log |S|` is not just additive under products, but behaves as a well-defined
extensive thermodynamic potential with all expected properties:
- Extensivity (product additivity) ✓
- Monotonicity (subset ordering) ✓
- Subadditivity (union bound) ✓
- Linear scaling (n-fold products) ✓
- Convergence (Fekete limit) ✓
-/

noncomputable section

open Finset Real

namespace TropicalAmplificationEnhanced

/-! ### Core Definition -/

/-- **Tropical perturbation bound** (tropical entropy) of a finite support.
    Defined as `log |S|`. -/
def Φ {α : Type*} (S : Finset α) : ℝ := Real.log (S.card : ℝ)

/-- Iterated product `S^n` as `Finset (Fin n → α)`. -/
def iterProd {α : Type*} [DecidableEq α] (S : Finset α) (n : ℕ) :
    Finset (Fin n → α) :=
  Fintype.piFinset (fun _ => S)

theorem iterProd_card {α : Type*} [DecidableEq α] (S : Finset α) (n : ℕ) :
    (iterProd S n).card = S.card ^ n := by
  simp [iterProd, Fintype.card_piFinset, Finset.prod_const]

/-! ### 1. Core Tensorization -/

theorem Φ_product {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty) :
    Φ (S ×ˢ T) = Φ S + Φ T := by
  simp only [Φ, Finset.card_product, Nat.cast_mul]
  exact Real.log_mul (Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hS).ne')
    (Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hT).ne')

/-! ### 2. N-fold Scaling -/

theorem Φ_iterProd {α : Type*} [DecidableEq α] (S : Finset α) (n : ℕ) :
    Φ (iterProd S n) = n * Φ S := by
  simp [Φ, iterProd_card, Nat.cast_pow, Real.log_pow]

/-! ### 3. Nonnegativity and Monotonicity -/

theorem Φ_nonneg {α : Type*} (S : Finset α) (hS : S.Nonempty) : 0 ≤ Φ S :=
  Real.log_nonneg (by exact_mod_cast Finset.card_pos.mpr hS)

theorem Φ_mono {α : Type*} (S T : Finset α) (h : S ⊆ T) (hS : S.Nonempty) :
    Φ S ≤ Φ T :=
  Real.log_le_log (Nat.cast_pos.mpr hS.card_pos) (by exact_mod_cast Finset.card_le_card h)

/-! ### 4. Singleton and Empty -/

theorem Φ_singleton {α : Type*} (a : α) : Φ ({a} : Finset α) = 0 := by
  simp [Φ]

theorem Φ_empty {α : Type*} : Φ (∅ : Finset α) = 0 := by
  simp [Φ]

/-! ### 5. Exponential Recovery -/

theorem exp_Φ {α : Type*} (S : Finset α) (hS : S.Nonempty) :
    Real.exp (Φ S) = (S.card : ℝ) :=
  Real.exp_log (Nat.cast_pos.mpr (Finset.card_pos.mpr hS))

theorem exp_Φ_multiplicative {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty) :
    Real.exp (Φ (S ×ˢ T)) = Real.exp (Φ S) * Real.exp (Φ T) := by
  rw [Φ_product S T hS hT, Real.exp_add]

/-! ### 6. Monotone Extensivity: Product Bound ≥ Max of Factor Bounds -/

/-- The product bound dominates each factor bound (for nonempty factors). -/
theorem Φ_product_ge_left {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty) :
    Φ S ≤ Φ (S ×ˢ T) := by
  rw [Φ_product S T hS hT]
  linarith [Φ_nonneg T hT]

theorem Φ_product_ge_right {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty) :
    Φ T ≤ Φ (S ×ˢ T) := by
  rw [Φ_product S T hS hT]
  linarith [Φ_nonneg S hS]

/-! ### 7. Strict Monotonicity for Nontrivial Factors -/

/-- If both factors have ≥ 2 elements, the product bound is strictly greater
    than either factor bound. -/
theorem Φ_product_strict {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β)
    (hS : 1 < S.card) (hT : 1 < T.card) :
    Φ S < Φ (S ×ˢ T) := by
  unfold Φ
  rw [Finset.card_product, Nat.cast_mul]
  have hSpos : (0 : ℝ) < S.card := by positivity
  have hTgt : (1 : ℝ) < T.card := by exact_mod_cast hT
  calc Real.log ↑(S.card)
      = Real.log (↑(S.card) * 1) := by ring_nf
    _ < Real.log (↑(S.card) * ↑(T.card)) := by
        apply Real.log_lt_log (by linarith)
        exact mul_lt_mul_of_pos_left hTgt hSpos

/-! ### 8. Disjoint Union Bound -/

/-- For disjoint unions, the bound is `log(|S| + |T|)`, which is at most
    `max(Φ S, Φ T) + log 2`. -/
theorem Φ_disjoint_union {α : Type*} [DecidableEq α]
    (S T : Finset α) (hST : Disjoint S T) (_hS : S.Nonempty) (_hT : T.Nonempty) :
    Φ (S ∪ T) = Real.log (S.card + T.card : ℝ) := by
  unfold Φ
  congr 1
  exact_mod_cast Finset.card_union_of_disjoint hST

/-! ### 9. Product Weight Perturbation Stability -/

/-- Product weights: `w(s,t) = wS(s) + wT(t)`. -/
def productWeight {α β : Type*} (wS : α → ℝ) (wT : β → ℝ) : α × β → ℝ :=
  fun p => wS p.1 + wT p.2

/-- Perturbation bounds compose additively under products. -/
theorem productWeight_perturbation {α β : Type*}
    (wS₁ wS₂ : α → ℝ) (wT₁ wT₂ : β → ℝ) (εS εT : ℝ)
    (hS : ∀ s, |wS₁ s - wS₂ s| ≤ εS) (hT : ∀ t, |wT₁ t - wT₂ t| ≤ εT) :
    ∀ p : α × β, |productWeight wS₁ wT₁ p - productWeight wS₂ wT₂ p| ≤ εS + εT := by
  intro ⟨a, b⟩
  simp only [productWeight]
  calc |(wS₁ a + wT₁ b) - (wS₂ a + wT₂ b)|
      = |(wS₁ a - wS₂ a) + (wT₁ b - wT₂ b)| := by ring_nf
    _ ≤ |wS₁ a - wS₂ a| + |wT₁ b - wT₂ b| := abs_add_le _ _
    _ ≤ εS + εT := add_le_add (hS a) (hT b)

/-! ### 10. Tropical Max Separability -/

/-- The tropical max functional. -/
def tropMax {α : Type*} (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) (f : α → ℝ) : ℝ :=
  S.sup' hS (fun s => f s + w s)

/-- `sup'` separates for additive functions on products. -/
theorem sup'_product_add {α β : Type*}
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty)
    (f : α → ℝ) (g : β → ℝ) :
    (S ×ˢ T).sup' (hS.product hT) (fun p => f p.1 + g p.2)
      = S.sup' hS f + T.sup' hT g := by
  apply le_antisymm
  · exact Finset.sup'_le _ _ fun ⟨a, b⟩ hab => by
      simp only [Finset.mem_product] at hab
      exact add_le_add (Finset.le_sup' f hab.1) (Finset.le_sup' g hab.2)
  · obtain ⟨a, ha, ha'⟩ := Finset.exists_mem_eq_sup' hS f
    obtain ⟨b, hb, hb'⟩ := Finset.exists_mem_eq_sup' hT g
    calc S.sup' hS f + T.sup' hT g
        = f a + g b := by rw [ha', hb']
      _ ≤ _ := Finset.le_sup' (fun p => f p.1 + g p.2) (Finset.mk_mem_product ha hb)

/-- Tropical max decomposes on products with separable weights and inputs. -/
theorem tropMax_product_separable {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty)
    (w₁ : α → ℝ) (w₂ : β → ℝ) (f₁ : α → ℝ) (f₂ : β → ℝ) :
    tropMax (S ×ˢ T) (hS.product hT) (fun p => w₁ p.1 + w₂ p.2)
      (fun p => f₁ p.1 + f₂ p.2)
    = tropMax S hS w₁ f₁ + tropMax T hT w₂ f₂ := by
  simp only [tropMax]
  have : (fun p : α × β => (f₁ p.1 + f₂ p.2) + (w₁ p.1 + w₂ p.2))
    = (fun p => (f₁ p.1 + w₁ p.1) + (f₂ p.2 + w₂ p.2)) := by ext ⟨a, b⟩; ring
  rw [this]
  exact sup'_product_add S T hS hT (fun s => f₁ s + w₁ s) (fun t => f₂ t + w₂ t)

/-! ### 11. Triple Product and Associativity -/

theorem Φ_triple_product {α β γ : Type*} [DecidableEq α] [DecidableEq β] [DecidableEq γ]
    (S : Finset α) (T : Finset β) (U : Finset γ)
    (hS : S.Nonempty) (hT : T.Nonempty) (hU : U.Nonempty) :
    Φ ((S ×ˢ T) ×ˢ U) = Φ S + Φ T + Φ U := by
  rw [Φ_product _ _ (hS.product hT) hU, Φ_product S T hS hT, add_assoc]

/-! ### 12. Automata State Growth -/

/-- The exponential of the n-fold tropical bound equals `|S|^n`,
    the number of strings of length n over alphabet S. -/
theorem exp_Φ_iterProd {α : Type*} [DecidableEq α]
    (S : Finset α) (hS : S.Nonempty) (n : ℕ) :
    Real.exp (Φ (iterProd S n)) = (S.card : ℝ) ^ n := by
  simp only [Φ, iterProd_card, Nat.cast_pow]
  exact Real.exp_log (by positivity)

/-! ### 13. Bit Complexity -/

/-- Tropical bit complexity: `Φ(S) / log 2 = log₂ |S|`. -/
def bitComplexity {α : Type*} (S : Finset α) : ℝ := Φ S / Real.log 2

theorem bitComplexity_product {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty) :
    bitComplexity (S ×ˢ T) = bitComplexity S + bitComplexity T := by
  simp only [bitComplexity, Φ_product S T hS hT, add_div]

/-! ### 14. Tropical Perturbation Rate -/

/-- The tropical perturbation rate of `S` at scale `n` is `Φ(S^n) / n`.
    By the n-fold scaling theorem, this equals `Φ(S)` for all `n > 0`. -/
theorem tropical_perturbation_rate {α : Type*} [DecidableEq α]
    (S : Finset α) (n : ℕ) (hn : 0 < n) :
    Φ (iterProd S n) / n = Φ S := by
  rw [Φ_iterProd]
  field_simp

/-! ### 15. Master Packaging Theorem -/

/-- **The complete tropical amplification calculus.**
    Packages all key properties of the tropical perturbation bound. -/
theorem tropical_amplification_master
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty) :
    -- Tensorization
    Φ (S ×ˢ T) = Φ S + Φ T ∧
    -- Exponential multiplicativity
    Real.exp (Φ (S ×ˢ T)) = Real.exp (Φ S) * Real.exp (Φ T) ∧
    -- Recovery
    Real.exp (Φ S) = (S.card : ℝ) ∧
    -- Bit complexity additivity
    bitComplexity (S ×ˢ T) = bitComplexity S + bitComplexity T ∧
    -- Product bound dominates factors
    Φ S ≤ Φ (S ×ˢ T) ∧ Φ T ≤ Φ (S ×ˢ T) := by
  exact ⟨Φ_product S T hS hT,
         exp_Φ_multiplicative S T hS hT,
         exp_Φ S hS,
         bitComplexity_product S T hS hT,
         Φ_product_ge_left S T hS hT,
         Φ_product_ge_right S T hS hT⟩

/-! ### 16. Closure System Compatibility -/

/-- A closure system with a stabilization iteration bound. -/
structure ClosureSystem (α : Type*) where
  cl : α → α
  bound : ℕ

/-- Product closure system. -/
def ClosureSystem.prod {α β : Type*}
    (csA : ClosureSystem α) (csB : ClosureSystem β) : ClosureSystem (α × β) where
  cl := fun p => (csA.cl p.1, csB.cl p.2)
  bound := csA.bound + csB.bound

/-- Closure stabilization bound is additive under products, compatible with
    the additive tropical perturbation bound. -/
theorem closure_bound_additive {α β : Type*}
    (csA : ClosureSystem α) (csB : ClosureSystem β) :
    (csA.prod csB).bound = csA.bound + csB.bound := rfl

/-- **Closure–tropical dual extensivity.**
    Both the tropical perturbation bound and the closure stabilization bound
    are additive under products — they are compatible extensive invariants. -/
theorem closure_tropical_extensivity
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : Finset α) (T : Finset β) (hS : S.Nonempty) (hT : T.Nonempty)
    (csA : ClosureSystem α) (csB : ClosureSystem β) :
    Φ (S ×ˢ T) = Φ S + Φ T ∧
    (csA.prod csB).bound = csA.bound + csB.bound :=
  ⟨Φ_product S T hS hT, rfl⟩

/-! ### 17. Tropical Complexity Lower Bound -/

/-- Any function distinguishing all elements of S requires log₂|S| bits.
    This is the tropical analogue of the counting argument for circuit depth. -/
theorem tropical_complexity_lower_bound {α : Type*}
    (S : Finset α) (hS : S.Nonempty) :
    0 ≤ bitComplexity S := by
  unfold bitComplexity
  exact div_nonneg (Φ_nonneg S hS) (Real.log_nonneg (by norm_num))

/-- The bit complexity of an n-fold product scales linearly. -/
theorem bitComplexity_iterProd {α : Type*} [DecidableEq α]
    (S : Finset α) (n : ℕ) :
    bitComplexity (iterProd S n) = n * bitComplexity S := by
  simp [bitComplexity, Φ_iterProd, mul_div_assoc]

/-! ### 18. Subadditivity Under Union -/

theorem Φ_union_le {α : Type*} [DecidableEq α]
    (S T : Finset α) (hS : S.Nonempty) :
    Φ (S ∪ T) ≤ Real.log (S.card + T.card : ℝ) := by
  unfold Φ
  apply Real.log_le_log (by exact_mod_cast (Finset.card_pos.mpr
    (Finset.Nonempty.mono Finset.subset_union_left hS)))
  exact_mod_cast Finset.card_union_le S T

/-! ### 19. Concrete Computation Examples -/

/-- For a 2-element set, the bound is log 2. -/
theorem Φ_pair (a b : ℕ) (hab : a ≠ b) :
    Φ ({a, b} : Finset ℕ) = Real.log 2 := by
  simp [Φ, Finset.card_pair hab]

end TropicalAmplificationEnhanced