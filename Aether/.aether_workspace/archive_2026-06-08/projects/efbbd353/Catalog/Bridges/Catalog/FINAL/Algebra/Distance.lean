/-
  # Reed–Solomon Code Distance

  The MDS property: the minimum distance of an RS code with parameters
  (n, k) over distinct evaluation points equals n - k + 1.

  ## Proof Strategy
  A nonzero polynomial of degree < k has at most k - 1 roots among any
  set of distinct field elements. Therefore it is nonzero at at least
  n - (k - 1) = n - k + 1 evaluation points.
-/

import Mathlib
import CodingTheory.ReedSolomon.Basic

open Polynomial Finset CodingTheory

noncomputable section

namespace CodingTheory

/-
The number of evaluation points where a nonzero polynomial of degree < k
vanishes is at most k - 1.
-/
theorem rs_eval_roots_le {K : Type*} [Field K] [DecidableEq K] {n k : ℕ}
    (α : Fin n → K) (hα : Function.Injective α)
    (p : K[X]) (hp : p ≠ 0) (hpk : p.natDegree < k) :
    (Finset.univ.filter fun i : Fin n => p.eval (α i) = 0).card ≤ k - 1 := by
  -- Use the fact that the image of a set under a bijective function has the same cardinality as the set.
  have h_card : Finset.card (Finset.filter (fun i => p.eval (α i) = 0) Finset.univ) ≤ Finset.card {x ∈ Finset.image α Finset.univ | p.eval x = 0} := by
    have h_card : Finset.image α (Finset.filter (fun i => p.eval (α i) = 0) Finset.univ) = Finset.filter (fun x => p.eval x = 0) (Finset.image α Finset.univ) := by
      grind;
    rw [ ← h_card, Finset.card_image_of_injective _ hα ];
  refine' le_trans h_card _;
  exact le_trans ( Finset.card_le_card fun x hx => show x ∈ p.roots.toFinset from by aesop ) ( le_trans ( Multiset.toFinset_card_le _ ) ( Nat.le_sub_one_of_lt ( lt_of_le_of_lt ( Polynomial.card_roots' _ ) hpk ) ) )

/-
**RS weight bound**: Every nonzero RS codeword has weight ≥ n - k + 1.
-/
theorem rs_nonzero_weight_ge {K : Type*} [Field K] [DecidableEq K] {n k : ℕ}
    (α : Fin n → K) (hα : Function.Injective α) (hk : k ≤ n)
    (c : Fin n → K) (hc : c ∈ RSCode n α k) (hne : c ≠ 0) :
    hammingWt c ≥ n - k + 1 := by
  -- Since c ∈ RSCode and c ≠ 0, by RSCode_nonzero_poly there exists a nonzero polynomial p with natDegree < k such that c i = p.eval (α i).
  obtain ⟨p, hp_nonzero, hp_deg, hp_eval⟩ : ∃ p : K[X], p ≠ 0 ∧ p.natDegree < k ∧ ∀ i, c i = p.eval (α i) := RSCode_nonzero_poly α k hc hne;
  -- By rs_eval_roots_le, card of {i | p.eval (α i) = 0} ≤ k - 1.
  have h_roots : (Finset.univ.filter fun i : Fin n => p.eval (α i) = 0).card ≤ k - 1 := by
    convert rs_eval_roots_le α hα p hp_nonzero hp_deg using 1;
  -- By hammingWt_add_zeros, wt(c) = n - card of {i | p.eval (α i) = 0}.
  have h_hammingWt : hammingWt c + (Finset.univ.filter fun i : Fin n => p.eval (α i) = 0).card = n := by
    convert hammingWt_add_zeros c ; aesop;
  grind

/-- **RS distance lower bound**: minimum distance ≥ n - k + 1. -/
theorem rs_distance_lower_bound {K : Type*} [Field K] [DecidableEq K] {n k : ℕ}
    (α : Fin n → K) (hα : Function.Injective α) (hk : k ≤ n) :
    ∀ c ∈ RSCode n α k, c ≠ 0 → hammingWt c ≥ n - k + 1 :=
  fun c hc hne => rs_nonzero_weight_ge α hα hk c hc hne

/-
**RS distance witness**: There exists a nonzero codeword with weight
exactly n - k + 1.
-/
theorem rs_distance_witness {K : Type*} [Field K] [DecidableEq K] {n k : ℕ}
    (α : Fin n → K) (hα : Function.Injective α) (hk : 1 ≤ k) (hkn : k ≤ n) :
    ∃ c ∈ RSCode n α k, c ≠ 0 ∧ hammingWt c = n - k + 1 := by
  rcases k with ( _ | k ) <;> simp_all +decide;
  refine' ⟨ fun i => ( ∏ j : Fin k, ( α i - α ⟨ j, by linarith [ Fin.is_lt j ] ⟩ ) ), _, _, _ ⟩;
  · refine' ⟨ ∏ j : Fin k, ( Polynomial.X - Polynomial.C ( α ⟨ j, by linarith [ Fin.is_lt j ] ⟩ ) ), _, _ ⟩;
    · rw [ Polynomial.natDegree_prod _ _ fun i _ => Polynomial.X_sub_C_ne_zero _ ] ; simp +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ];
    · simp +decide [ Polynomial.eval_prod ];
  · simp +decide [ funext_iff, Finset.prod_eq_zero_iff, sub_eq_zero, hα.eq_iff ];
    exact ⟨ ⟨ k, hkn ⟩, fun i => ne_of_gt i.2 ⟩;
  · -- The set of indices where the product is non-zero is exactly the set of indices greater than or equal to `k`.
    have h_support : Finset.univ.filter (fun i : Fin n => ∏ j : Fin k, (α i - α ⟨↑j, by linarith [ Fin.is_lt j ] ⟩) ≠ 0) = Finset.univ.filter (fun i : Fin n => i.val ≥ k) := by
      ext i; simp +decide [ Finset.prod_eq_zero_iff, sub_eq_zero, hα.eq_iff ] ;
      exact ⟨ fun hi => not_lt.1 fun contra => hi ⟨ i, contra ⟩ rfl, fun hi x => ne_of_gt <| Nat.lt_of_lt_of_le x.2 hi ⟩;
    convert congr_arg Finset.card h_support using 1;
    rw [ show ( Finset.univ.filter fun i : Fin n => ( i : ℕ ) ≥ k ) = Finset.Ici ⟨ k, by linarith ⟩ by ext; aesop ] ; simp +decide [ Nat.sub_add_comm hkn.le ];
    omega

/-- **Reed–Solomon MDS theorem**: minimum weight equals n - k + 1. -/
theorem rs_mds {K : Type*} [Field K] [DecidableEq K] {n k : ℕ}
    (α : Fin n → K) (hα : Function.Injective α) (hk : 1 ≤ k) (hkn : k ≤ n) :
    (∀ c ∈ RSCode n α k, c ≠ 0 → hammingWt c ≥ n - k + 1) ∧
    (∃ c ∈ RSCode n α k, c ≠ 0 ∧ hammingWt c = n - k + 1) :=
  ⟨rs_distance_lower_bound α hα hkn, rs_distance_witness α hα hk hkn⟩

/-
**Unique decoding**: If two RS codewords are both within distance
(n-k)/2 of a received word, they must be equal.
-/
theorem rs_unique_decoding {K : Type*} [Field K] [DecidableEq K] {n k : ℕ}
    (α : Fin n → K) (hα : Function.Injective α) (hk : k ≤ n)
    (c₁ c₂ : Fin n → K) (r : Fin n → K)
    (hc₁ : c₁ ∈ RSCode n α k) (hc₂ : c₂ ∈ RSCode n α k)
    (hd₁ : hammingD r c₁ ≤ (n - k) / 2)
    (hd₂ : hammingD r c₂ ≤ (n - k) / 2) :
    c₁ = c₂ := by
  by_contra hne;
  -- By the properties of Hamming distance, we have $d(c₁, c₂) \leq d(r, c₁) + d(r, c₂)$.
  have h_dist : hammingD c₁ c₂ ≤ hammingD r c₁ + hammingD r c₂ := by
    unfold hammingD;
    rw [ ← Finset.card_union_add_card_inter ];
    exact le_add_right ( Finset.card_mono fun i hi => by by_cases hi₁ : r i = c₁ i <;> by_cases hi₂ : r i = c₂ i <;> aesop );
  -- Since $c₁ \neq c₂$, by the properties of Hamming distance, we have $d(c₁, c₂) \geq n - k + 1$.
  have h_dist_ge : hammingD c₁ c₂ ≥ n - k + 1 := by
    convert rs_nonzero_weight_ge α hα hk ( c₁ - c₂ ) _ _ using 1;
    · exact hammingD_eq_hammingWt_sub _ _;
    · exact?;
    · exact sub_ne_zero_of_ne hne;
  grind

end CodingTheory

end