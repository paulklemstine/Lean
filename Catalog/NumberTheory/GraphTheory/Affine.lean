import Mathlib

/-!
# Sun's truncated Legendre-symbol determinant — the affine (rank-one) structure

The matrix `A j k = X + (j - k | p)` is `C.map (C ·) + X • J`, where `J` is the
all-ones matrix and `C` is the integer Legendre-difference matrix.  Because `J`
has rank one, the determinant `det A`, *a priori* a polynomial of degree `m` in
`X`, is in fact **affine**:
`det A = det C + (det (C + J) - det C) · X`.

This is the general linear-algebra heart of the result, valid for an arbitrary
square matrix `M` in place of `C`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Although a determinant of an `m × m` matrix whose
entries are degree-≤ 1 polynomials can have degree up to `m`, the special
all-ones perturbation `X • J` forces the determinant to be affine in `X`.

Experiment (Experimenter): Confirmed numerically that for the Legendre matrices
`det A = c · X` (degree 1) for all tested primes.  Formal proof via the
multilinear expansion of the determinant over the rows: `MultilinearMap.map_add_univ`
splits `det (rows of M + c · rows of J)` into a sum over subsets `s` of rows that
keep `M`; whenever two or more rows take the `c · (1,…,1)` part the alternating
determinant kills them.  Only the full set (giving `det M`) and the
co-singletons (each contributing `c · det(updateRow)`) survive.

Analysis (Analyst): Specialising the scalar `c` to `1` gives the integer identity
`det (M + J) = det M + ∑ⱼ det (updateRow M j 1)`; specialising the base ring to
`ℤ[X]` and `c` to `X` gives the affine polynomial form.  One general lemma,
`det_add_smul_onesM`, yields both.

Critique (Critic): No smallness or primality hypothesis is needed — this is pure
multilinear algebra over a commutative ring.  The only subtlety is the
bookkeeping of the alternating/piecewise terms.

Synthesis (PI): Combined with `det C = 0` (file `Basic`) this reduces Sun's
identity to the single scalar `det (C + J)`.
-/

open Polynomial Matrix

namespace SunLegendreDet

/-- The all-ones `m × m` matrix over a commutative ring. -/
def onesM (R : Type*) [CommRing R] (m : ℕ) : Matrix (Fin m) (Fin m) R :=
  fun _ _ => 1

/-- The polynomial matrix `A j k = C (M j k) + X` attached to an integer matrix `M`. -/
noncomputable def Apoly {m : ℕ} (M : Matrix (Fin m) (Fin m) ℤ) : Matrix (Fin m) (Fin m) ℤ[X] :=
  fun j k => Polynomial.C (M j k) + Polynomial.X

/-
**Scalar rank-one expansion (general).**  Adding a scalar multiple `c • J` of the
all-ones matrix to `M` changes the determinant linearly in `c`:
`det (M + c • J) = det M + c · ∑ⱼ det (updateRow M j 1)`.
The proof expands the determinant multilinearly over the rows; every term in which
two or more rows take the `c • (1,…,1)` part vanishes by the alternating property.
-/
theorem det_add_smul_onesM {R : Type*} [CommRing R] {m : ℕ}
    (c : R) (M : Matrix (Fin m) (Fin m) R) :
    (M + c • onesM R m).det = M.det + c * ∑ j, (M.updateRow j 1).det := by
  have h_expand : Matrix.det (M + c • onesM R m) = ∑ s : Finset (Fin m), Matrix.det (Matrix.of (fun i j => if i ∈ s then M i j else c)) := by
    have h_expand : Matrix.det (M + c • onesM R m) = ∑ s : Finset (Fin m), Matrix.det (Matrix.of (fun i j => if i ∈ s then M i j else c)) := by
      have h_expand : ∀ (v w : Fin m → (Fin m → R)), Matrix.det (Matrix.of (fun i j => v i j + w i j)) = ∑ s : Finset (Fin m), Matrix.det (Matrix.of (fun i j => if i ∈ s then v i j else w i j)) := by
        intro v w; simp +decide [ Matrix.det_apply' ] ;
        rw [ Finset.sum_comm, Finset.sum_congr rfl ];
        simp +decide [ Finset.prod_add, Finset.mul_sum _ _ _ ];
        intro σ; refine' Finset.sum_bij ( fun s _ => Finset.image ( fun i => σ i ) s ) _ _ _ _ <;> simp +decide [ Finset.prod_ite, Finset.filter_mem_eq_inter, Finset.filter_not ] ;
        · exact fun a₁ a₂ h => Finset.image_injective σ.injective h;
        · exact fun b => ⟨ Finset.image ( fun i => σ.symm i ) b, by simp +decide [ Finset.image_image ] ⟩
      convert h_expand ( fun i j => M i j ) ( fun i j => c ) using 1;
      congr ; ext i j ; simp +decide [ onesM ];
    exact h_expand;
  -- Split the sum into two parts: one where the complement has exactly one element, and one where it has more than one.
  have h_split : ∑ s : Finset (Fin m), Matrix.det (Matrix.of (fun i j => if i ∈ s then M i j else c)) = ∑ s ∈ Finset.filter (fun s => Finset.card (Finset.univ \ s) = 0) (Finset.powerset (Finset.univ : Finset (Fin m))), Matrix.det (Matrix.of (fun i j => if i ∈ s then M i j else c)) + ∑ s ∈ Finset.filter (fun s => Finset.card (Finset.univ \ s) = 1) (Finset.powerset (Finset.univ : Finset (Fin m))), Matrix.det (Matrix.of (fun i j => if i ∈ s then M i j else c)) := by
    have h_split : ∀ s : Finset (Fin m), Finset.card (Finset.univ \ s) > 1 → Matrix.det (Matrix.of (fun i j => if i ∈ s then M i j else c)) = 0 := by
      intro s hs_card
      have h_two_equal_rows : ∃ i j : Fin m, i ≠ j ∧ i ∉ s ∧ j ∉ s := by
        obtain ⟨ i, hi, j, hj, hij ⟩ := Finset.one_lt_card.mp hs_card; use i, j; aesop;
      obtain ⟨ i, j, hij, hi, hj ⟩ := h_two_equal_rows; exact Matrix.det_zero_of_row_eq hij ( by ext k; aesop ) ;
    rw [ ← Finset.sum_union ];
    · rw [ ← Finset.sum_subset ( show _ ⊆ Finset.univ from Finset.subset_univ _ ) ];
      grind;
    · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
  convert h_split using 2;
  · rw [ Finset.sum_eq_single ( Finset.univ : Finset ( Fin m ) ) ] <;> simp +decide [ Finset.card_sdiff ];
    · rfl;
    · exact fun s hs hs' => False.elim <| hs' <| Finset.eq_of_subset_of_card_le ( Finset.subset_univ s ) <| by simp +decide [ Nat.sub_eq_zero_iff_le.mp hs ] ;
  · rw [ Finset.mul_sum _ _ _ ];
    refine' Finset.sum_bij ( fun i _ => Finset.univ \ { i } ) _ _ _ _ <;> simp +decide;
    · simp +decide [ Finset.ext_iff ];
      exact fun a₁ a₂ h => Classical.not_not.1 fun h' => by simpa [ h' ] using h a₁;
    · intro s hs; obtain ⟨ a, ha ⟩ := Finset.card_eq_one.mp hs; use a; simp_all +decide [ Finset.ext_iff ] ;
      exact fun x => by rw [ ← ha x, not_not ] ;
    · intro i; rw [ ← Matrix.det_updateRow_smul ] ; congr; ext j; aesop;

/-- **Single-row expansion of the all-ones perturbation.**  (Special case `c = 1`.) -/
theorem det_add_onesM {R : Type*} [CommRing R] {m : ℕ}
    (M : Matrix (Fin m) (Fin m) R) :
    (M + onesM R m).det = M.det + ∑ j, (M.updateRow j 1).det := by
  have h := det_add_smul_onesM (1 : R) M
  simpa using h

/-
**The affine (rank-one) determinant theorem.**  Over `ℤ[X]`, the determinant of
`A j k = C (M j k) + X` is affine in `X` with constant term `det M` and linear
coefficient `det (M + J) − det M`, where `J` is the all-ones matrix.
-/
theorem det_Apoly {m : ℕ} (M : Matrix (Fin m) (Fin m) ℤ) :
    (Apoly M).det
      = Polynomial.C (M.det)
        + Polynomial.C ((M + onesM ℤ m).det - M.det) * Polynomial.X := by
  -- Apply `det_add_smul_onesM` with base ring `ℤ[X]`, scalar `c := Polynomial.X`, and matrix `M.map (Polynomial.C)`.
  have h_det : (Apoly M).det = (M.map (Polynomial.C)).det + Polynomial.X * ∑ j, ((M.map (Polynomial.C)).updateRow j 1).det := by
    convert det_add_smul_onesM Polynomial.X ( M.map Polynomial.C ) using 2;
    ext; simp [Apoly, onesM];
  -- By `RingHom.map_det`, `Polynomial.C : ℤ →+* ℤ[X]` commutes with determinant.
  have h_det_map : (M.map (Polynomial.C)).det = Polynomial.C M.det := by
    simp +decide [ Matrix.det_apply' ];
  -- By `det_add_onesM`, `∑ j, (M.updateRow j 1).det = (M + onesM ℤ m).det - M.det`.
  have h_sum_det : ∑ j, (M.updateRow j 1).det = (M + onesM ℤ m).det - M.det := by
    rw [ eq_sub_iff_add_eq', ← det_add_onesM ];
  convert h_det using 1;
  rw [ ← h_sum_det, h_det_map, mul_comm ];
  simp +decide [ Matrix.updateRow_apply, Matrix.det_apply' ]

end SunLegendreDet