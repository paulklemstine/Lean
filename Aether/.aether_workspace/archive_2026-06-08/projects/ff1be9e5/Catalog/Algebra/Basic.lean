/-
  # BCH Codes and the BCH Bound

  BCH codes are characterized by vanishing of syndromes at consecutive
  powers of a primitive root of unity. The BCH bound establishes that
  such codes have minimum distance at least δ.
-/

import Mathlib
import CodingTheory.Hamming

open Polynomial Finset CodingTheory

noncomputable section

namespace CodingTheory

/-- Syndrome of a vector c with respect to root α. -/
def bchSyndrome {K : Type*} [CommRing K] {n : ℕ}
    (α : K) (b : ℕ) (c : Fin n → K) (j : ℕ) : K :=
  ∑ i : Fin n, c i * α ^ ((b + j) * i.val)

/-- BCH parity check: syndromes 0 to δ-2 vanish. -/
def bchParityCheck {K : Type*} [CommRing K] {n : ℕ}
    (α : K) (b δ : ℕ) (c : Fin n → K) : Prop :=
  ∀ j : ℕ, j < δ - 1 → bchSyndrome α b c j = 0

/-
**BCH Bound**: The Hamming weight of any nonzero vector satisfying
the BCH parity check conditions is at least δ.

**Proof sketch**: Suppose c ≠ 0 has weight s < δ. Let i₁, …, iₛ be the
support positions and set xₗ = α^(iₗ), wₗ = c(iₗ) · α^(b·iₗ). The
parity check conditions give ∑ wₗ · xₗ^j = 0 for j = 0, …, s-1.
This is a homogeneous Vandermonde system. Since the xₗ are distinct
(by hα_inj), the Vandermonde matrix is invertible, forcing w = 0.
But wₗ ≠ 0 (since c(iₗ) ≠ 0 and α^(b·iₗ) ≠ 0 when α ≠ 0),
giving a contradiction.
-/
theorem bch_bound {K : Type*} [Field K] [DecidableEq K] {n δ : ℕ}
    (α : K) (b : ℕ)
    (hα_ne : α ≠ 0)
    (hα_inj : ∀ i j : Fin n, α ^ i.val = α ^ j.val → i = j)
    (_hδ : δ ≤ n + 1)
    (c : Fin n → K)
    (hc : bchParityCheck α b δ c) :
    c = 0 ∨ hammingWt c ≥ δ := by
  -- By contrapositive: push_neg to get hne : c ≠ 0 and hs : hammingWt c < δ.
  by_contra h
  push_neg at h
  obtain ⟨hne, hs⟩ := h;
  -- Let S = Finset.univ.filter (fun i => c i ≠ 0). So S.card = hammingWt c = s < δ.
  set S := Finset.univ.filter (fun i => c i ≠ 0)
  have hS_card : S.card < δ := by
    exact hs;
  -- Use Finset.orderEmbOfFin to index S by Fin s.
  obtain ⟨e, he⟩ : ∃ e : Fin S.card → Fin n, Function.Injective e ∧ ∀ i, e i ∈ S := by
    exact ⟨ fun i => S.orderEmbOfFin rfl i, by simp +decide [ Function.Injective ], fun i => S.orderEmbOfFin_mem rfl _ ⟩;
  -- Define $w$ and $x$ as in the provided solution.
  set w : Fin S.card → K := fun ℓ => c (e ℓ) * α ^ (b * (e ℓ).val)
  set x : Fin S.card → K := fun ℓ => α ^ (e ℓ).val;
  -- The equations become: for each j < s, ∑ ℓ : Fin s, w ℓ * (x ℓ)^j = 0.
  have h_eq : ∀ j : Fin S.card, ∑ ℓ : Fin S.card, w ℓ * (x ℓ) ^ (j : ℕ) = 0 := by
    intro j
    have h_eq_j : ∑ i ∈ S, c i * α ^ ((b + j.val) * i.val) = 0 := by
      have h_eq_j : ∑ i : Fin n, c i * α ^ ((b + j.val) * i.val) = 0 := by
        exact hc _ ( Nat.lt_of_lt_of_le j.2 ( Nat.le_sub_one_of_lt hS_card ) );
      rw [ ← h_eq_j, Finset.sum_filter_of_ne ] ; aesop;
    have h_eq_j : ∑ i ∈ S, c i * α ^ ((b + j.val) * i.val) = ∑ ℓ : Fin S.card, c (e ℓ) * α ^ ((b + j.val) * (e ℓ).val) := by
      have h_eq_j : ∑ i ∈ S, c i * α ^ ((b + j.val) * i.val) = ∑ i ∈ Finset.image e Finset.univ, c i * α ^ ((b + j.val) * i.val) := by
        rw [ Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => he.2 i ) ( by rw [ Finset.card_image_of_injective _ he.1, Finset.card_fin ] ) ];
      rw [ h_eq_j, Finset.sum_image <| by tauto ];
    convert h_eq_j.symm.trans ‹∑ i ∈ S, c i * α ^ ( ( b + j.val ) * i.val ) = 0› using 2 ; ring;
  -- This is a homogeneous Vandermonde system. Since the xₗ are distinct (by hα_inj), the Vandermonde matrix is invertible, forcing w = 0.
  have h_vandermonde : Matrix.det (Matrix.of (fun (i j : Fin S.card) => x j ^ (i : ℕ))) ≠ 0 := by
    erw [ Matrix.det_transpose, Matrix.det_vandermonde ];
    simp +decide [ Finset.prod_eq_zero_iff, sub_eq_zero ];
    exact fun i j hij => fun h => hij.ne <| he.1 <| hα_inj _ _ h.symm;
  -- Since the Vandermonde matrix is invertible, the only solution to the system is $w = 0$.
  have h_w_zero : w = 0 := by
    have h_w_zero : Matrix.mulVec (Matrix.of (fun (i j : Fin S.card) => x j ^ (i : ℕ))) w = 0 := by
      exact funext fun i => by simpa [ Matrix.mulVec, dotProduct, mul_comm ] using h_eq i;
    exact Matrix.eq_zero_of_mulVec_eq_zero h_vandermonde h_w_zero;
  simp +zetaDelta at *;
  exact he.2 ⟨ 0, Finset.card_pos.mpr ⟨ Classical.choose ( Function.ne_iff.mp hne ), Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Classical.choose_spec ( Function.ne_iff.mp hne ) ⟩ ⟩ ⟩ ( by simpa [ hα_ne ] using congr_fun h_w_zero ⟨ 0, Finset.card_pos.mpr ⟨ Classical.choose ( Function.ne_iff.mp hne ), Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Classical.choose_spec ( Function.ne_iff.mp hne ) ⟩ ⟩ ⟩ )

/-- The BCH bound as a minimum distance statement. -/
theorem bch_min_distance {K : Type*} [Field K] [DecidableEq K] {n δ : ℕ}
    (α : K) (b : ℕ)
    (hα_ne : α ≠ 0)
    (hα_inj : ∀ i j : Fin n, α ^ i.val = α ^ j.val → i = j)
    (hδ : δ ≤ n + 1)
    (c : Fin n → K)
    (hc : bchParityCheck α b δ c) (hne : c ≠ 0) :
    hammingWt c ≥ δ :=
  (bch_bound α b hα_ne hα_inj hδ c hc).resolve_left hne

end CodingTheory

end