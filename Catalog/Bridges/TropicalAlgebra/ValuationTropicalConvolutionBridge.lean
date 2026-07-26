import Mathlib

/-! # Valuation–Tropical Convolution Bridge

This file builds a small, self-contained bridge from additive valuations on a
commutative semiring to a tropical (min-plus) lower bound on the valuations of
finite Cauchy convolutions.

The central statement is `tropConv_le_vprofile_cauchyConv`: the tropical
convolution of two valuation profiles is a pointwise lower bound for the
valuation profile of the Cauchy convolution of the corresponding sequences.
-/

namespace ValuationTropicalConvolutionBridge

open Finset

/-- An additive valuation on a commutative semiring `K`, valued in `WithTop ℕ`. -/
structure AddVal (K : Type*) [CommSemiring K] where
  /-- The underlying valuation map. -/
  v : K → WithTop ℕ
  /-- The valuation of `0` is `⊤`. -/
  map_zero : v 0 = ⊤
  /-- The valuation of `1` is `0`. -/
  map_one : v 1 = 0
  /-- Valuations are additive on products. -/
  map_mul : ∀ x y, v (x * y) = v x + v y
  /-- The valuation of a sum is at least the minimum of the valuations. -/
  min_le_map_add : ∀ x y, min (v x) (v y) ≤ v (x + y)

variable {K : Type*} [CommSemiring K]

/-- The valuation profile of a sequence `a : ℕ → K`. -/
def vprofile (v : AddVal K) (a : ℕ → K) : ℕ → WithTop ℕ := fun n => v.v (a n)

/-- The finite Cauchy convolution of two sequences. -/
def cauchyConv (a b : ℕ → K) (n : ℕ) : K :=
  ∑ k ∈ Finset.range (n + 1), a k * b (n - k)

/-- The tropical (min-plus) convolution of two `WithTop ℕ`-valued profiles,
defined as a finite minimum over `range (n+1)`. -/
noncomputable def tropConv (u w : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  (Finset.range (n + 1)).inf' (by simp) (fun k => u k + w (n - k))

/-- A finite sum has valuation at least `m` whenever every summand does.
(The empty sum is `0`, whose valuation is `⊤`, so no nonemptiness is required.) -/
lemma le_val_sum (v : AddVal K) (m : WithTop ℕ) (s : Finset ℕ) (f : ℕ → K)
    (h : ∀ i ∈ s, m ≤ v.v (f i)) : m ≤ v.v (∑ i ∈ s, f i) := by
  induction' s using Finset.induction with i s hi ih;
  · simp +decide [ v.map_zero ];
  · simp_all +decide [ Finset.sum_insert hi ];
    exact le_trans ( le_min h.1 ih ) ( v.min_le_map_add _ _ )

/-- Termwise multiplicativity of the valuation on convolution summands. -/
lemma val_mul_term (v : AddVal K) (a b : ℕ → K) (n k : ℕ) :
    v.v (a k * b (n - k)) = vprofile v a k + vprofile v b (n - k) := by
  exact v.map_mul _ _

/-- The tropical convolution is below each term in the range. -/
lemma tropConv_le_term (v : AddVal K) (a b : ℕ → K) (n k : ℕ)
    (hk : k ∈ Finset.range (n + 1)) :
    tropConv (vprofile v a) (vprofile v b) n ≤ vprofile v a k + vprofile v b (n - k) := by
  exact Finset.inf'_le _ hk

/-- Sanity check: at `n = 0` the Cauchy convolution is just `a 0 * b 0`. -/
lemma cauchyConv_zero (a b : ℕ → K) : cauchyConv a b 0 = a 0 * b 0 := by
  simp [cauchyConv]

/-- Sanity check: at `n = 0` the tropical convolution is the sum of the
zeroth profile entries. -/
lemma tropConv_zero (u w : ℕ → WithTop ℕ) : tropConv u w 0 = u 0 + w 0 := by
  simp [tropConv]

/-- **Main theorem.** The tropical convolution of the valuation profiles is a
lower bound for the valuation profile of the Cauchy convolution. -/
theorem tropConv_le_vprofile_cauchyConv
    (v : AddVal K) (a b : ℕ → K) (n : ℕ) :
    tropConv (vprofile v a) (vprofile v b) n ≤ vprofile v (cauchyConv a b) n := by
  apply le_val_sum;
  exact fun i hi => le_trans ( tropConv_le_term v a b n i hi ) ( by rw [ val_mul_term ] )

end ValuationTropicalConvolutionBridge