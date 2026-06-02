/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# MDS–Uncertainty Equivalence and Vandermonde Nonsingularity

This file proves the precise algebraic equivalence between the MDS property
and the discrete uncertainty principle, together with the nonsingularity of
Vandermonde matrices with distinct evaluation points.

## Main Results

* `vandermonde_det_ne_zero` — Vandermonde matrix with injective nodes has nonzero determinant
* `critical_submatrix_breaks_uncertainty` — A singular submatrix yields an uncertainty violation
* `not_mds_implies_not_uncertainty` — ¬MDS → ¬SatisfiesUP
* `uncertainty_implies_mds` — SatisfiesUP → IsMDS (one direction of the equivalence)
* `mds_implies_uncertainty` — IsMDS → SatisfiesUP (the other direction)
* `mds_iff_uncertainty` — The full equivalence: IsMDS ↔ SatisfiesUP

## Mathematical Content

The MDS–Uncertainty equivalence is a fundamental result connecting three domains:
1. **Coding theory**: MDS codes achieve the Singleton bound
2. **Harmonic analysis**: The discrete uncertainty principle
3. **Linear algebra**: Submatrix invertibility

The forward direction (MDS → UP) uses the rank argument: if |supp(f)| + |supp(Mf)| ≤ n,
then the matrix restricted to the zero positions of Mf and the support of f has a
nontrivial kernel, contradicting MDS.

The backward direction (UP → MDS) is constructive: from a singular submatrix, we build
an explicit vector violating the uncertainty bound.
-/

import Algebra.MDSUncertainty.Defs

open Matrix Finset BigOperators Function

noncomputable section

variable {F : Type*} [Field F] [DecidableEq F]

/-! ## Vandermonde Nonsingularity -/

/-
**Vandermonde matrices with distinct nodes are nonsingular.**
The determinant of the Vandermonde matrix `V(v)` with entries `V_{ij} = v_i^j`
equals `∏_{i<j} (v_j - v_i)`, which is nonzero when `v` is injective.
-/
omit [DecidableEq F] in
theorem vandermonde_det_ne_zero {n : ℕ} {v : Fin n → F}
    (hv : Function.Injective v) :
    (Matrix.vandermonde v).det ≠ 0 := by
  simp +decide [ Matrix.det_vandermonde ];
  exact Finset.prod_ne_zero_iff.mpr fun i hi => Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero_of_ne <| hv.ne <| ne_of_gt <| Finset.mem_Ioi.mp hj

/-! ## Critical Submatrix → Uncertainty Violation -/

/-
Given a critical submatrix of M (a singular square submatrix with a kernel witness),
we can construct a vector f that violates the uncertainty principle.
The vector is defined by extending the witness to all of Fin n using the column injection,
and it satisfies |supp(f)| + |supp(Mf)| ≤ n.
-/
theorem critical_submatrix_breaks_uncertainty {n : ℕ}
    (M : Matrix (Fin n) (Fin n) F) (crit : CriticalSubmatrix M) :
    ¬SatisfiesUP M := by
  -- Define the vector f by extending the witness to all of Fin n using the column injection.
  obtain ⟨k, hk, rows, cols, witness, witness_ne_zero, kernel_eq⟩ := crit
  set f : Fin n → F := fun i => if h : ∃ j, cols j = i then witness (Classical.choose h) else 0
  have hf_ne_zero : f ≠ 0 := by
    simp_all +decide [ funext_iff ];
    obtain ⟨ x, hx ⟩ := witness_ne_zero; use cols x; aesop;
  have hsupp_f : (vecSupport f).card ≤ k := by
    refine' le_trans ( Finset.card_le_card _ ) _;
    exact Finset.image cols Finset.univ;
    · intro i hi; simp_all +decide [ vecSupport ] ;
      grind;
    · exact Finset.card_image_le.trans_eq ( Finset.card_fin _ )
  have hsupp_Mf : (vecSupport (M.mulVec f)).card ≤ n - k := by
    -- For each i in range(r), (M.mulVec f)(r l) = ∑_{j : Fin k} M(r l, c j) v(j) = ((M.submatrix r c).mulVec v)(l) = 0 by kernel_eq.
    have hsupp_Mf_subset : ∀ l : Fin k, (M.mulVec f) (rows l) = 0 := by
      intro l
      have hsupp_Mf_subset : (M.mulVec f) (rows l) = ∑ j : Fin k, M (rows l) (cols j) * witness j := by
        simp +decide [ Matrix.mulVec, dotProduct, f ];
        rw [ ← Finset.sum_subset ( Finset.subset_univ ( Finset.image cols Finset.univ ) ) ];
        · rw [ Finset.sum_image ];
          · simp +decide [ cols.injective.eq_iff ];
          · exact cols.injective.injOn;
        · aesop;
      exact hsupp_Mf_subset.trans ( by simpa [ Matrix.mulVec, dotProduct ] using congr_fun kernel_eq l );
    have hsupp_Mf_subset : vecSupport (M.mulVec f) ⊆ Finset.univ \ Finset.image rows Finset.univ := by
      intro i hi; simp_all +decide [ vecSupport ] ;
      exact fun l hl => hi <| hl ▸ hsupp_Mf_subset l;
    exact le_trans ( Finset.card_le_card hsupp_Mf_subset ) ( by simp +decide [ Finset.card_sdiff, Finset.card_image_of_injective _ rows.injective ] )
  have hsum : (vecSupport f).card + (vecSupport (M.mulVec f)).card ≤ n := by
    exact le_trans ( add_le_add hsupp_f hsupp_Mf ) ( by rw [ Nat.add_sub_of_le ( show k ≤ n from le_trans ( by simpa using Fintype.card_le_of_injective cols cols.injective ) ( by simp +decide ) ) ] )
  exact fun h => by linarith [h f hf_ne_zero]

/-! ## Backward Direction: SatisfiesUP → IsMDS -/

/-
The existence of a singular square submatrix (¬IsMDS) implies the existence of
a critical submatrix certificate.
-/
omit [DecidableEq F] in
theorem critical_of_not_mds {n : ℕ} (M : Matrix (Fin n) (Fin n) F)
    (h : ¬IsMDS M) : Nonempty (CriticalSubmatrix M) := by
  contrapose! h;
  intro k hk r c;
  contrapose! h;
  obtain ⟨ v, hv ⟩ := Matrix.exists_mulVec_eq_zero_iff.mpr h;
  exact ⟨ ⟨ k, hk, r, c, v, hv.1, hv.2 ⟩ ⟩

/-- **Backward direction**: If a matrix satisfies the uncertainty principle, then
it is MDS. Equivalently, ¬MDS → ¬UP. -/
theorem uncertainty_implies_mds {n : ℕ} (M : Matrix (Fin n) (Fin n) F) :
    SatisfiesUP M → IsMDS M := by
  intro hup
  by_contra h
  exact critical_submatrix_breaks_uncertainty M (critical_of_not_mds M h).some hup

/-! ## Forward Direction: IsMDS → SatisfiesUP -/

/-
**Key lemma for the forward direction**: If `A` is a square matrix with nonzero
determinant and `A.mulVec v = 0`, then `v = 0`.
-/
omit [DecidableEq F] in
theorem mulVec_eq_zero_of_det_ne_zero {k : ℕ}
    (A : Matrix (Fin k) (Fin k) F) (hA : A.det ≠ 0)
    (v : Fin k → F) (hv : A.mulVec v = 0) : v = 0 := by
  exact Matrix.eq_zero_of_mulVec_eq_zero hA hv ▸ rfl

/-
**Forward direction**: If a matrix is MDS, then it satisfies the discrete
uncertainty principle. For every nonzero f, |supp(f)| + |supp(Mf)| ≥ n + 1.

The proof proceeds by contradiction. If |supp(f)| + |supp(Mf)| ≤ n, then
the number of zeros of Mf is at least |supp(f)|. Restricting M to the zero
positions of Mf (rows) and the support of f (columns) gives a matrix whose
kernel contains the restriction of f. Extracting a square submatrix and
using MDS yields a contradiction with f ≠ 0.
-/
theorem mds_implies_uncertainty {n : ℕ} (M : Matrix (Fin n) (Fin n) F) :
    IsMDS M → SatisfiesUP M := by
  intro hMDS f hf_nonzero
  by_contra h_contra
  have h_card : (vecSupport f).card + (vecSupport (M.mulVec f)).card ≤ n := by
    linarith
  generalize_proofs at *; (
  -- Let $S = \text{vecSupport } f$ and $Z = \text{vecZeros } (M \cdot f)$.
  set S := vecSupport f
  set Z := vecZeros (M.mulVec f) with hZ_def
  have hZ_card : Z.card ≥ S.card := by
    have hZ_card : Z.card + (vecSupport (M.mulVec f)).card = n := by
      convert vecSupport_card_add_vecZeros_card ( M.mulVec f ) using 1 ; ring!;
    generalize_proofs at *; linarith;
  generalize_proofs at *; (
  -- Pick s elements from Z (possible since |Z| ≥ s ≥ 1). Use Finset.orderIsoOfFin to get an order-preserving bijection from Fin s to a subset of Z of size s.
  obtain ⟨r, hr⟩ : ∃ r : Fin S.card ↪ Fin n, ∀ i, r i ∈ Z := by
    have := Finset.exists_subset_card_eq hZ_card; obtain ⟨ T, hT₁, hT₂ ⟩ := this; exact ⟨ ⟨ fun i ↦ T.orderEmbOfFin ( by aesop ) i, fun i j hij ↦ by simpa [ Fin.ext_iff ] using hij ⟩, fun i ↦ hT₁ ( by simp +decide ) ⟩ ;
  generalize_proofs at *; (
  -- Construct injections:
  -- - c : Fin s ↪ Fin n from S using Finset.orderIsoOfFin S (refl)
  -- - r : Fin s ↪ Fin n from a subset of Z of size s
  obtain ⟨c, hc⟩ : ∃ c : Fin S.card ↪ Fin n, ∀ i, c i ∈ S := by
    exact ⟨ ⟨ fun i => S.orderEmbOfFin rfl i, fun i j hij => by simpa [ Fin.ext_iff ] using hij ⟩, fun i => S.orderEmbOfFin_mem rfl _ ⟩
  generalize_proofs at *; (
  -- Then (M.submatrix r c).mulVec (witness) = 0 where witness l = f(c l).
  have h_submatrix : (M.submatrix r c).mulVec (fun l => f (c l)) = 0 := by
    ext i; simp_all +decide [ Matrix.mulVec, dotProduct ] ;
    have h_sum_zero : ∑ x ∈ Finset.univ, M (r i) x * f x = 0 := by
      exact hr i |> fun h => by simpa [ Matrix.mulVec, dotProduct ] using Finset.mem_filter.mp h |>.2;
    generalize_proofs at *; (
    convert h_sum_zero using 1
    generalize_proofs at *; (
    rw [ ← Finset.sum_subset ( show Finset.image c Finset.univ ⊆ Finset.univ from Finset.subset_univ _ ) ] <;> simp +decide [ Finset.sum_image, Function.Injective, * ];
    exact fun x hx => Or.inr ( Classical.not_not.1 fun hx' => hx ( Classical.choose ( Finset.mem_image.mp ( show x ∈ Finset.image c Finset.univ from by rw [ show Finset.image c Finset.univ = S from Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => hc i ) ( by rw [ Finset.card_image_of_injective _ c.injective, Finset.card_fin ] ) ] ; exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx' ⟩ ) ) ) ( Classical.choose_spec ( Finset.mem_image.mp ( show x ∈ Finset.image c Finset.univ from by rw [ show Finset.image c Finset.univ = S from Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => hc i ) ( by rw [ Finset.card_image_of_injective _ c.injective, Finset.card_fin ] ) ] ; exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx' ⟩ ) ) |>.2 ) )))
  generalize_proofs at *; (
  -- Since f is nonzero on S, witness ≠ 0.
  have h_witness_nonzero : (fun l => f (c l)) ≠ 0 := by
    simp_all +decide [ funext_iff, vecSupport ];
    exact ⟨ ⟨ 0, Finset.card_pos.mpr ⟨ Classical.choose hf_nonzero, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Classical.choose_spec hf_nonzero ⟩ ⟩ ⟩, Finset.mem_filter.mp ( hc _ ) |>.2 ⟩
  generalize_proofs at *; (
  exact h_witness_nonzero ( mulVec_eq_zero_of_det_ne_zero _ ( hMDS _ ( Finset.card_pos.mpr ( vecSupport_nonempty_of_ne_zero hf_nonzero ) ) _ _ ) _ h_submatrix )))))))

/-! ## The Main Equivalence -/

/-- **MDS–Uncertainty Equivalence**: A square matrix M over a field satisfies
the discrete uncertainty principle (|supp(f)| + |supp(Mf)| ≥ n + 1 for all
nonzero f) if and only if every square submatrix of M has nonzero determinant
(the MDS property).

This result unifies:
- The Singleton bound from coding theory (MDS codes meet the bound with equality)
- The Donoho–Stark uncertainty principle from harmonic analysis
- Submatrix invertibility from linear algebra -/
theorem mds_iff_uncertainty {n : ℕ} (M : Matrix (Fin n) (Fin n) F) :
    IsMDS M ↔ SatisfiesUP M :=
  ⟨mds_implies_uncertainty M, uncertainty_implies_mds M⟩

end