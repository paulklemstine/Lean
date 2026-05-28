/-
Copyright (c) 2025. All rights reserved.
Shadow Profile Convolution and Circuit Complexity Bounds — Main Theorems

This file proves the core results:
1. Key Lemma: ∂(A+B) ⊆ (∂A+B) ∪ (A+∂B)
2. Shadow Convolution: ∂ᵏ(A+B) ⊆ ⋃_{i+j=k} ∂ⁱ(A) + ∂ʲ(B)
3. Shadow Complexity Sub-additivity: Σ(A∪B) ≤ Σ(A) + Σ(B)
-/
import Mathlib
import ShadowComplexity.Defs

namespace ShadowComplexity

open Finset

/-! ## Key Lemma: Shadow of Minkowski Sum

The fundamental insight: if c ∈ ∂(A+B), then c = (a+b) - eᵢ for some
a ∈ A, b ∈ B with (a+b)ᵢ > 0. Since (a+b)ᵢ = aᵢ + bᵢ > 0, either
aᵢ > 0 or bᵢ > 0. In the first case, c = (a-eᵢ) + b ∈ ∂A + B.
In the second case, c = a + (b-eᵢ) ∈ A + ∂B.
-/

/-- Subtraction distributes over addition for natural number functions
    when the subtracted part only affects one summand. -/
theorem sub_stdBasis_add_left {n : ℕ} (a b : Fin n → ℕ) (i : Fin n) (ha : a i > 0) :
    (a + b) - stdBasis i = (a - stdBasis i) + b := by
  ext j
  simp only [Pi.add_apply, Pi.sub_apply, stdBasis]
  split_ifs with h
  · subst h; omega
  · omega

theorem sub_stdBasis_add_right {n : ℕ} (a b : Fin n → ℕ) (i : Fin n) (hb : b i > 0) :
    (a + b) - stdBasis i = a + (b - stdBasis i) := by
  ext j
  simp only [Pi.add_apply, Pi.sub_apply, stdBasis]
  split_ifs with h
  · subst h; omega
  · omega

/-
**Key Lemma**: The shadow of a Minkowski sum is contained in the union
    of (shadow of A) + B and A + (shadow of B).
    ∂(A + B) ⊆ (∂A + B) ∪ (A + ∂B)
-/
theorem lowerShadow_minkowskiSum_subset {n : ℕ} (A B : Finset (Fin n → ℕ)) :
    lowerShadow (minkowskiSum A B) ⊆
      minkowskiSum (lowerShadow A) B ∪ minkowskiSum A (lowerShadow B) := by
  intro v' hv'
  rw [mem_lowerShadow] at hv'
  obtain ⟨c, hc⟩ := hv';
  obtain ⟨ hc₁, i, hi, rfl ⟩ := hc;
  obtain ⟨ a, ha, b, hb, rfl ⟩ := mem_minkowskiSum.mp hc₁;
  by_cases ha' : a i > 0 <;> by_cases hb' : b i > 0 <;> simp_all +decide [ sub_stdBasis_add_left, sub_stdBasis_add_right ];
  · exact Or.inl ( mem_minkowskiSum.mpr ⟨ _, mem_lowerShadow.mpr ⟨ _, ha, _, ha', rfl ⟩, _, hb, rfl ⟩ );
  · exact Or.inl <| mem_minkowskiSum.mpr ⟨ _, mem_lowerShadow.mpr ⟨ _, ha, i, ha', rfl ⟩, _, hb, rfl ⟩;
  · exact Or.inr ( mem_minkowskiSum.mpr ⟨ a, ha, _, mem_lowerShadow.mpr ⟨ b, hb, i, hb', rfl ⟩, rfl ⟩ )

/-
**Shadow Convolution Theorem**: The k-th iterated shadow of A+B is contained
    in the union over all i+j=k of (∂ⁱA + ∂ʲB).

    ∂ᵏ(A+B) ⊆ ⋃_{i=0}^{k} ∂ⁱ(A) + ∂^{k-i}(B)

    This is proved by induction on k, using the key lemma at each step.
-/
theorem shadow_minkowski_convolution {n : ℕ} (A B : Finset (Fin n → ℕ)) (k : ℕ) :
    shadow_iter (minkowskiSum A B) k ⊆
      (Finset.range (k + 1)).biUnion fun i =>
        minkowskiSum (shadow_iter A i) (shadow_iter B (k - i)) := by
  induction' k with k ih generalizing A B <;> simp_all +decide [ shadow_iter ];
  refine' Finset.Subset.trans ( lowerShadow_mono ( ih _ _ ) ) _;
  -- By the properties of the shadow operator, we can apply it term by term to the union.
  have h_shadow_term : ∀ (i : ℕ), lowerShadow (minkowskiSum (shadow_iter A i) (shadow_iter B (k - i))) ⊆ minkowskiSum (shadow_iter A (i + 1)) (shadow_iter B (k - i)) ∪ minkowskiSum (shadow_iter A i) (shadow_iter B (k - i + 1)) := by
    intro i
    apply lowerShadow_minkowskiSum_subset;
  have h_shadow_union : lowerShadow (Finset.biUnion (Finset.range (k + 1)) (fun i => minkowskiSum (shadow_iter A i) (shadow_iter B (k - i)))) ⊆ Finset.biUnion (Finset.range (k + 1)) (fun i => lowerShadow (minkowskiSum (shadow_iter A i) (shadow_iter B (k - i)))) := by
    induction' ( Finset.range ( k + 1 ) ) using Finset.induction <;> simp_all +decide [ Finset.subset_iff ];
    · simp +decide [ lowerShadow ];
    · simp_all +decide [ lowerShadow_union ];
      grind;
  refine' Finset.Subset.trans h_shadow_union ( Finset.biUnion_subset.mpr _ );
  grind

/-
**Shadow Complexity Sub-additivity**: Σ(A ∪ B) ≤ Σ(A) + Σ(B).
    This follows because the shadow of a union equals the union of shadows,
    and |X ∪ Y| ≤ |X| + |Y|.
-/
theorem shadow_complexity_subadditive {n : ℕ} (A B : Finset (Fin n → ℕ)) :
    shadowComplexity (A ∪ B) ≤ shadowComplexity A + shadowComplexity B := by
  have h_max_deg : ∀ S : Finset (Fin n → ℕ), ∀ k > maxDegree S, shadow_iter S k = ∅ := by
    intro S k hk;
    induction' k with k ih generalizing S <;> simp_all +decide [ shadow_iter ];
    -- By definition of `shadow_iter`, if `maxDegree S ≤ k`, then `shadow_iter S k` is a subset of the set of vectors with total degree at most `maxDegree S - k`.
    have h_subset : ∀ v ∈ shadow_iter S k, totalDeg v ≤ maxDegree S - k := by
      refine' Nat.recOn k _ _ <;> simp_all +decide [ shadow_iter ];
      · exact fun v hv => Finset.le_sup ( f := fun v => totalDeg v ) hv;
      · intro n hn v hv; rw [ mem_lowerShadow ] at hv; obtain ⟨ w, hw, i, hi, rfl ⟩ := hv; simp_all +decide [ totalDeg ] ;
        have h_sum_le : ∑ x, (w x - stdBasis i x) ≤ ∑ x, w x - 1 := by
          refine' Nat.le_sub_one_of_lt _;
          refine' Finset.sum_lt_sum _ _;
          · exact fun _ _ => Nat.sub_le _ _;
          · exact ⟨ i, Finset.mem_univ _, by simp +decide [ stdBasis, hi ] ⟩;
        exact le_trans h_sum_le ( Nat.sub_le_sub_right ( hn _ hw ) _ );
    simp_all +decide [ lowerShadow ];
    simp_all +decide [ Finset.ext_iff, totalDeg ];
  -- By definition of shadowComplexity, we have:
  have h_def : ∀ S : Finset (Fin n → ℕ), shadowComplexity S = ∑ k ∈ Finset.range (maxDegree S + 1), (shadow_iter S k).card := by
    intro S; rfl;
  -- Applying the definition of shadowComplexity to both sides of the inequality.
  suffices h_suff : ∑ k ∈ Finset.range (maxDegree (A ∪ B) + 1), (shadow_iter (A ∪ B) k).card ≤ ∑ k ∈ Finset.range (maxDegree (A ∪ B) + 1), (shadow_iter A k).card + ∑ k ∈ Finset.range (maxDegree (A ∪ B) + 1), (shadow_iter B k).card by
    rw [ h_def, h_def, h_def ];
    refine le_trans h_suff ?_;
    rw [ ← Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ ( show maxDegree ( A ∪ B ) ≥ maxDegree A from ?_ ) ) ), ← Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ ( show maxDegree ( A ∪ B ) ≥ maxDegree B from ?_ ) ) ) ];
    · grind;
    · exact Finset.sup_mono ( Finset.subset_union_right );
    · aesop;
    · exact Finset.sup_mono <| Finset.subset_union_left;
  rw [ ← Finset.sum_add_distrib ];
  exact Finset.sum_le_sum fun i hi => by rw [ shadow_iter_union ] ; exact Finset.card_union_le _ _;

end ShadowComplexity