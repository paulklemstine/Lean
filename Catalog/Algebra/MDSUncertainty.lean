/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# MDS Matrices and the Algebraic Uncertainty Principle

We prove that the Maximum Distance Separable (MDS) property of a matrix is
the precise algebraic condition equivalent to the strongest form of the
discrete additive uncertainty principle:

  **For all nonzero f, |supp(f)| + |supp(Mf)| ≥ n + 1.**

This connects three domains:
- **Harmonic analysis**: The Fourier uncertainty principle
- **Coding theory**: MDS codes (Reed-Solomon) achieve the Singleton bound
- **Linear algebra**: Every square submatrix being invertible

## Main results

- `IsMDS`: Definition of MDS matrices (every square submatrix is invertible)
- `mds_implies_uncertainty`: MDS matrices satisfy the strongest uncertainty bound
- `not_mds_implies_violator`: Non-MDS matrices have uncertainty-violating vectors
- `mds_iff_uncertainty`: Full characterization — MDS ↔ strongest uncertainty
- `mds_invertible`: MDS matrices are invertible

## References

- Donoho, D.L. and Stark, P.B., "Uncertainty principles and signal recovery"
- Tao, T., "An uncertainty principle for cyclic groups of prime order"
- MacWilliams and Sloane, "The Theory of Error-Correcting Codes"
-/

import Mathlib

open Matrix Finset Function BigOperators

variable {F : Type*} [Field F] [DecidableEq F]

/-! ## Definitions -/

/-- Support of a vector: the set of indices where the vector is nonzero. -/
def vecSupport {n : ℕ} (v : Fin n → F) : Finset (Fin n) :=
  Finset.univ.filter (fun i => v i ≠ 0)

/-- Zero set of a vector: the set of indices where the vector vanishes. -/
def vecZeros {n : ℕ} (v : Fin n → F) : Finset (Fin n) :=
  Finset.univ.filter (fun i => v i = 0)

/-- **Maximum Distance Separable (MDS) matrix**: A square matrix over a field
is MDS if every square submatrix (obtained by selecting any k rows and any k
columns) has nonzero determinant. This is the algebraic core of Reed-Solomon
codes and the Singleton bound.

Equivalently, M is MDS iff the associated linear code has minimum distance
n - k + 1 (the maximum possible by the Singleton bound). -/
def IsMDS {n : ℕ} (M : Matrix (Fin n) (Fin n) F) : Prop :=
  ∀ (k : ℕ) (r : Fin k ↪ Fin n) (c : Fin k ↪ Fin n),
    (M.submatrix r c).det ≠ 0

/-- The additive uncertainty bound: a matrix M satisfies this bound if for
every nonzero vector f, the sum of support sizes of f and Mf is at least
`bound`. The MDS property is equivalent to the bound being n + 1. -/
def SatisfiesUncertainty {n : ℕ} (M : Matrix (Fin n) (Fin n) F) (bound : ℕ) : Prop :=
  ∀ f : Fin n → F, f ≠ 0 →
    (vecSupport f).card + (vecSupport (M.mulVec f)).card ≥ bound

/-- **Uncertainty defect** (novel definition). For a matrix M, the uncertainty
defect measures how far M is from achieving the MDS uncertainty bound. It is
defined as n + 1 minus the minimum support sum over all nonzero vectors.
An MDS matrix has defect 0; larger defects mean weaker uncertainty. -/
structure UncertaintyProfile (n : ℕ) (F : Type*) [Field F] [DecidableEq F] where
  /-- The matrix whose uncertainty we study. -/
  mat : Matrix (Fin n) (Fin n) F
  /-- Lower bound on support sums that we have verified. -/
  certifiedBound : ℕ
  /-- Proof that the bound holds. -/
  bound_valid : ∀ f : Fin n → F, f ≠ 0 →
    (vecSupport f).card + (vecSupport (mat.mulVec f)).card ≥ certifiedBound

/-! ## Basic properties of support and zeros -/

@[simp]
lemma vecSupport_apply {n : ℕ} {v : Fin n → F} {i : Fin n} :
    i ∈ vecSupport v ↔ v i ≠ 0 := by
  simp [vecSupport]

@[simp]
lemma vecZeros_apply {n : ℕ} {v : Fin n → F} {i : Fin n} :
    i ∈ vecZeros v ↔ v i = 0 := by
  simp [vecZeros]

/-
Support and zero set partition the index set.
-/
lemma vecSupport_card_add_vecZeros_card {n : ℕ} (v : Fin n → F) :
    (vecSupport v).card + (vecZeros v).card = n := by
  unfold vecZeros vecSupport;
  rw [ Finset.card_filter, Finset.card_filter ];
  rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun _ _ => by aesop, Finset.sum_const, Finset.card_fin, smul_eq_mul, mul_one ]

/-
A nonzero vector has nonempty support.
-/
lemma vecSupport_nonempty_of_ne_zero {n : ℕ} {v : Fin n → F} (hv : v ≠ 0) :
    (vecSupport v).Nonempty := by
  exact Function.ne_iff.mp hv |> Exists.imp fun i hi => vecSupport_apply.mpr hi

/-- A nonzero vector has positive support size. -/
lemma vecSupport_card_pos_of_ne_zero {n : ℕ} {v : Fin n → F} (hv : v ≠ 0) :
    0 < (vecSupport v).card :=
  Finset.card_pos.mpr (vecSupport_nonempty_of_ne_zero hv)

/-! ## Key connection: submatrix and support -/

/-
**Key connection lemma**: If f vanishes outside the range of an embedding c,
then the submatrix product (M.submatrix r c).mulVec (f ∘ c) at index i equals
(M.mulVec f) at index (r i). This links the submatrix determinant theory
to the global matrix-vector product.
-/
lemma submatrix_mulVec_of_support {n k : ℕ} (M : Matrix (Fin n) (Fin n) F)
    (f : Fin n → F) (r : Fin k → Fin n) (c : Fin k ↪ Fin n)
    (hsupp : ∀ j : Fin n, f j ≠ 0 → j ∈ Set.range c) (i : Fin k) :
    (M.submatrix r c).mulVec (f ∘ c) i = M.mulVec f (r i) := by
  simp +decide only [mulVec, dotProduct, submatrix_apply];
  rw [ ← Finset.sum_subset ( Finset.subset_univ ( Finset.image c Finset.univ ) ) ];
  · rw [ Finset.sum_image ] ; aesop;
    exact c.injective.injOn;
  · exact fun j _ hj => mul_eq_zero_of_right _ ( Classical.not_not.1 fun h => hj <| by simpa using hsupp j h )

/-! ## MDS implies invertibility -/

/-
An MDS matrix is invertible (has nonzero determinant). This is immediate:
take k = n and the identity embeddings.
-/
theorem mds_invertible {n : ℕ} (M : Matrix (Fin n) (Fin n) F) (hMDS : IsMDS M) :
    M.det ≠ 0 := by
  convert hMDS n ( Function.Embedding.refl _ ) ( Function.Embedding.refl _ )

/-! ## Forward direction: MDS implies uncertainty -/

/-
**Forward direction of the MDS-Uncertainty characterization.**
If M is MDS and f is a nonzero vector in F^n, then the sum of the support
sizes of f and Mf is at least n + 1.

Proof sketch: By contradiction. If |supp(f)| + |supp(Mf)| ≤ n, then
|zeros(Mf)| ≥ |supp(f)| = s. Select s rows from zeros(Mf) to form an
s × s submatrix with the columns from supp(f). This submatrix maps the
nonzero part of f to zero, but MDS says it's invertible, forcing f = 0.
-/
theorem mds_implies_uncertainty {n : ℕ} (M : Matrix (Fin n) (Fin n) F)
    (hMDS : IsMDS M) (f : Fin n → F) (hf : f ≠ 0) :
    (vecSupport f).card + (vecSupport (M.mulVec f)).card ≥ n + 1 := by
  by_contra! h;
  obtain ⟨T, hT⟩ : ∃ T : Finset (Fin n), T ⊆ vecZeros (M.mulVec f) ∧ T.card = (vecSupport f).card := by
    refine' Finset.exists_subset_card_eq _;
    linarith [ vecSupport_card_add_vecZeros_card f, vecSupport_card_add_vecZeros_card ( M *ᵥ f ) ];
  -- Let $r$ be an order embedding of $T$ into $\text{Fin } n$.
  obtain ⟨r, hr⟩ : ∃ r : Fin (vecSupport f).card ↪ Fin n, Set.range r ⊆ T := by
    obtain ⟨r, hr⟩ : ∃ r : Fin (vecSupport f).card ↪ T, True := by
      exact ⟨ ( Fintype.equivOfCardEq ( by simp +decide [ hT.2 ] ) ).toEmbedding, trivial ⟩;
    exact ⟨ r.trans ( Function.Embedding.subtype _ ), Set.range_subset_iff.mpr fun i => r i |>.2 ⟩;
  -- Let $c$ be an order embedding of $\text{supp}(f)$ into $\text{Fin } n$.
  obtain ⟨c, hc⟩ : ∃ c : Fin (vecSupport f).card ↪ Fin n, Set.range c = vecSupport f := by
    have h_orderEmb : ∃ c : Fin (vecSupport f).card → Fin n, StrictMono c ∧ Set.range c = vecSupport f := by
      exact ⟨ fun i => Finset.orderEmbOfFin _ ( by aesop ) i, by aesop_cat, by aesop_cat ⟩;
    exact ⟨ ⟨ h_orderEmb.choose, h_orderEmb.choose_spec.1.injective ⟩, h_orderEmb.choose_spec.2 ⟩;
  -- By submatrix_mulVec_of_support, for each i:
  have h_submatrix : ∀ i : Fin (vecSupport f).card, (M.submatrix r c).mulVec (f ∘ c) i = 0 := by
    intro i
    have h_submatrix : (M.submatrix r c).mulVec (f ∘ c) i = M.mulVec f (r i) := by
      apply submatrix_mulVec_of_support;
      simp_all +decide [ Set.ext_iff ];
    exact h_submatrix.trans ( Finset.mem_filter.mp ( hT.1 ( hr ( Set.mem_range_self i ) ) ) |>.2 );
  -- By IsMDS, det(M.submatrix r c) ≠ 0. By Matrix.eq_zero_of_mulVec_eq_zero, f ∘ c = 0.
  have h_det : (M.submatrix r c).det ≠ 0 := by
    exact hMDS _ r c
  have h_zero : f ∘ c = 0 := by
    exact Matrix.eq_zero_of_mulVec_eq_zero h_det ( funext h_submatrix );
  simp_all +decide [ funext_iff, Set.ext_iff ];
  exact hf.elim fun x hx => hx <| by obtain ⟨ y, rfl ⟩ := hc x |>.2 hx; exact h_zero y;

/-! ## Converse direction: Non-MDS implies a violating vector -/

/-
**Converse direction of the MDS-Uncertainty characterization.**
If M is not MDS, there exists a singular k×k submatrix. A nonzero vector in
its kernel, extended by zeros, yields a vector f with
|supp(f)| + |supp(Mf)| ≤ n.
-/
theorem not_mds_implies_violator {n : ℕ} (M : Matrix (Fin n) (Fin n) F)
    (hM : ¬IsMDS M) :
    ∃ f : Fin n → F, f ≠ 0 ∧
      (vecSupport f).card + (vecSupport (M.mulVec f)).card ≤ n := by
  obtain ⟨k, r, c, h_sub⟩ : ∃ k : ℕ, ∃ r : Fin k ↪ Fin n, ∃ c : Fin k ↪ Fin n, (M.submatrix r c).det = 0 := by
    contrapose! hM; tauto;
  -- By Matrix.exists_mulVec_eq_zero_iff, there exists v : Fin k → F with v ≠ 0 and (M.submatrix r c).mulVec v = 0.
  obtain ⟨v, hv_ne_zero, hv_zero⟩ : ∃ v : Fin k → F, v ≠ 0 ∧ (M.submatrix r c).mulVec v = 0 := by
    convert Matrix.exists_mulVec_eq_zero_iff.mpr h_sub;
  refine' ⟨ fun i => if h : i ∈ Set.range c then v ( Classical.choose h ) else 0, _, _ ⟩;
  · contrapose! hv_ne_zero;
    ext i; have := congr_fun hv_ne_zero ( c i ) ; aesop;
  · -- By submatrix_mulVec_of_support, (M.submatrix r c).mulVec (f ∘ c) i = M.mulVec f (r i).
    have h_submatrix_mulVec : ∀ i : Fin k, (M.submatrix r c).mulVec v i = M.mulVec (fun i => if h : i ∈ Set.range c then v (Classical.choose h) else 0) (r i) := by
      intro i;
      convert submatrix_mulVec_of_support M ( fun i => if h : i ∈ Set.range c then v ( Classical.choose h ) else 0 ) r c _ i using 1;
      · simp +decide [ funext_iff, Matrix.mulVec, dotProduct ];
      · grind;
    have h_support_f : (vecSupport (fun i => if h : i ∈ Set.range c then v (Classical.choose h) else 0)).card ≤ k := by
      refine' le_trans ( Finset.card_le_card _ ) _;
      exact Finset.image c Finset.univ;
      · intro i hi; aesop;
      · exact Finset.card_image_le.trans_eq ( Finset.card_fin _ );
    have h_support_Mf : (vecZeros (M.mulVec (fun i => if h : i ∈ Set.range c then v (Classical.choose h) else 0))).card ≥ k := by
      have h_support_Mf : Finset.image r Finset.univ ⊆ vecZeros (M.mulVec (fun i => if h : i ∈ Set.range c then v (Classical.choose h) else 0)) := by
        simp_all +decide [ Finset.subset_iff, vecZeros ];
        exact fun i => h_submatrix_mulVec i ▸ rfl;
      exact le_trans ( by rw [ Finset.card_image_of_injective _ r.injective ] ; simp +decide ) ( Finset.card_mono h_support_Mf );
    linarith [ vecSupport_card_add_vecZeros_card ( M.mulVec fun i => if h : i ∈ Set.range c then v ( Classical.choose h ) else 0 ) ]

/-! ## The full characterization -/

/-- **MDS-Uncertainty Theorem (Donoho-Stark generalized).**
A square matrix M over a field is MDS if and only if it satisfies the
strongest additive uncertainty bound: for every nonzero f,
  |supp(f)| + |supp(Mf)| ≥ n + 1.

This theorem unifies three perspectives:
- **Harmonic analysis**: Uncertainty for the Fourier transform arises because
  the DFT matrix over cyclic groups of prime order is MDS.
- **Coding theory**: MDS codes (Reed-Solomon) achieve the Singleton bound
  precisely because their generator matrices are MDS.
- **Linear algebra**: The MDS condition (every square submatrix invertible)
  is equivalent to a support-sum lower bound. -/
theorem mds_iff_uncertainty {n : ℕ} (M : Matrix (Fin n) (Fin n) F) :
    IsMDS M ↔ SatisfiesUncertainty M (n + 1) := by
  constructor
  · exact fun hMDS f hf => mds_implies_uncertainty M hMDS f hf
  · intro hU
    by_contra hM
    obtain ⟨f, hf, hle⟩ := not_mds_implies_violator M hM
    exact Nat.not_le.mpr (by omega) (hU f hf)

/-! ## Properties of MDS matrices -/

/-
The transpose of an MDS matrix is MDS. This reflects the coding-theoretic
duality: if a code is MDS, so is its dual.
-/
theorem mds_transpose {n : ℕ} (M : Matrix (Fin n) (Fin n) F) (hMDS : IsMDS M) :
    IsMDS Mᵀ := by
  intro k r c; specialize hMDS k c r; simp_all +decide [ Matrix.det_transpose, Matrix.transpose_submatrix ] ;
  convert Iff.rfl using 2 ; rw [ ← Matrix.det_transpose ] ; aesop;

/-
**Singleton bound for uncertainty**: For any invertible n × n matrix M with
n ≥ 1, there exists a nonzero vector achieving |supp(f)| + |supp(Mf)| ≤ n + 1.
This shows that MDS matrices achieve the tightest possible bound.
-/
theorem singleton_bound {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) F)
    (_hM : M.det ≠ 0) :
    ∃ f : Fin n → F, f ≠ 0 ∧
      (vecSupport f).card + (vecSupport (M.mulVec f)).card ≤ n + 1 := by
  refine' ⟨ fun i => if i = ⟨ 0, hn ⟩ then 1 else 0, _, _ ⟩ <;> simp_all +decide [ funext_iff ];
  refine' Nat.add_comm 1 n ▸ Nat.add_le_add _ _;
  · exact Finset.card_le_one.mpr fun i hi j hj => by aesop;
  · exact le_trans ( Finset.card_le_univ _ ) ( by simp +decide )