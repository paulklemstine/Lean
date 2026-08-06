import Mathlib

/-! # Entropy toolkit for integrated information of tensor network states

This file provides the entropic infrastructure used by the formalization of
Tononi's Integrated Information Theory (IIT) in terms of tensor network states.

We work with Shannon entropy of a finite probability vector and with the von
Neumann entropy of a Hermitian complex matrix, defined through the eigenvalues
supplied by Mathlib's spectral theorem.  The main results are

* `sum_negMulLog_le_log_card_support` : Shannon entropy is bounded by the
  logarithm of the size of the support (the "maximal entropy" bound);
* `sum_negMulLog_eq_zero_iff` : entropy vanishes exactly for point masses;
* `vnEntropy_le_log_rank` : von Neumann entropy of a positive semidefinite
  matrix of unit trace is at most the logarithm of its rank;
* `vnEntropy_eq_zero_iff_rank_eq_one` : the von Neumann entropy vanishes iff the
  state is pure (rank one);
* `vnEntropy_smul_one` : the entropy of a flat (maximally mixed) spectrum.
-/

open Finset

namespace IITTensorNetwork

/-! ## Shannon entropy of a finite probability vector -/

section Shannon

variable {ι : Type*} [Fintype ι]

/-- The support of a probability vector. -/
noncomputable def support (p : ι → ℝ) : Finset ι :=
  Finset.univ.filter (fun i => p i ≠ 0)

@[simp] lemma mem_support {p : ι → ℝ} {i : ι} : i ∈ support p ↔ p i ≠ 0 := by
  simp [support]

lemma sum_support (p : ι → ℝ) : ∑ i ∈ support p, p i = ∑ i, p i :=
  Finset.sum_subset (Finset.subset_univ _) (by
    intro i _ hi
    simpa [support] using hi)

lemma sum_negMulLog_support (p : ι → ℝ) :
    ∑ i ∈ support p, Real.negMulLog (p i) = ∑ i, Real.negMulLog (p i) :=
  Finset.sum_subset (Finset.subset_univ _) (by
    intro i _ hi
    have : p i = 0 := by simpa [support] using hi
    simp [this])

/-- The support of a probability vector is nonempty. -/
lemma support_nonempty {p : ι → ℝ} (hsum : ∑ i, p i = 1) :
    (support p).Nonempty := by
  rcases Finset.eq_empty_or_nonempty (support p) with h | h
  · exfalso
    have : ∑ i, p i = 0 := by
      rw [← sum_support p, h, Finset.sum_empty]
    rw [hsum] at this
    norm_num at this
  · exact h

/-- **Maximal entropy bound.**  The Shannon entropy of a finite probability
vector is at most the logarithm of the cardinality of its support. -/
theorem sum_negMulLog_le_log_card_support {p : ι → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hsum : ∑ i, p i = 1) :
    ∑ i, Real.negMulLog (p i) ≤ Real.log (support p).card := by
  set S := support p with hS
  set r : ℝ := (S.card : ℝ) with hr
  have hSne : S.Nonempty := support_nonempty hsum
  have hrpos : 0 < r := by
    rw [hr]
    exact_mod_cast Finset.card_pos.mpr hSne
  have hsumS : ∑ i ∈ S, p i = 1 := by rw [sum_support p, hsum]
  have key : ∀ i ∈ S, Real.negMulLog (p i) ≤ p i * Real.log r + 1 / r - p i := by
    intro i hi
    have hpi : 0 < p i := lt_of_le_of_ne (hp i) (Ne.symm (mem_support.mp hi))
    have hx : 0 < 1 / (r * p i) := by positivity
    have hlog := Real.log_le_sub_one_of_pos hx
    have hmul : p i * Real.log (1 / (r * p i)) ≤ p i * (1 / (r * p i) - 1) :=
      mul_le_mul_of_nonneg_left hlog hpi.le
    have hrewrite : Real.log (1 / (r * p i)) = -(Real.log r + Real.log (p i)) := by
      rw [Real.log_div one_ne_zero (by positivity), Real.log_one,
        Real.log_mul (ne_of_gt hrpos) (ne_of_gt hpi)]
      ring
    have hval : p i * (1 / (r * p i) - 1) = 1 / r - p i := by
      field_simp
    rw [hrewrite, hval] at hmul
    have hexp : p i * (-(Real.log r + Real.log (p i)))
        = -(p i * Real.log r) - p i * Real.log (p i) := by ring
    rw [hexp] at hmul
    simp only [Real.negMulLog]
    nlinarith [hmul]
  calc ∑ i, Real.negMulLog (p i) = ∑ i ∈ S, Real.negMulLog (p i) :=
        (sum_negMulLog_support p).symm
    _ ≤ ∑ i ∈ S, (p i * Real.log r + 1 / r - p i) := Finset.sum_le_sum key
    _ = (∑ i ∈ S, p i) * Real.log r + S.card * (1 / r) - ∑ i ∈ S, p i := by
        rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul,
          Finset.sum_const, nsmul_eq_mul]
    _ = Real.log r := by
        rw [hsumS, ← hr]
        field_simp
        ring

/-- Entropy is nonnegative for a probability vector. -/
theorem sum_negMulLog_nonneg {p : ι → ℝ} (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    0 ≤ ∑ i, Real.negMulLog (p i) := by
  refine Finset.sum_nonneg fun i _ => Real.negMulLog_nonneg (hp i) ?_
  exact hsum ▸ Finset.single_le_sum (fun j _ => hp j) (Finset.mem_univ i)

/-- Entropy of a probability vector vanishes exactly when the vector is a point
mass, i.e. exactly when its support is a singleton. -/
theorem sum_negMulLog_eq_zero_iff {p : ι → ℝ} (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    (∑ i, Real.negMulLog (p i)) = 0 ↔ (support p).card = 1 := by
  classical
  have hle : ∀ i, p i ≤ 1 := by
    intro i
    exact hsum ▸ Finset.single_le_sum (fun j _ => hp j) (Finset.mem_univ i)
  constructor
  · intro h
    have hterm : ∀ i ∈ Finset.univ, Real.negMulLog (p i) = 0 := by
      refine (Finset.sum_eq_zero_iff_of_nonneg ?_).mp h
      intro i _
      exact Real.negMulLog_nonneg (hp i) (hle i)
    -- each probability is `0` or `1`
    have hzo : ∀ i, p i = 0 ∨ p i = 1 := by
      intro i
      have hi := hterm i (Finset.mem_univ i)
      rcases eq_or_lt_of_le (hp i) with h0 | h0
      · exact Or.inl h0.symm
      · right
        have : Real.log (p i) = 0 := by
          have : -p i * Real.log (p i) = 0 := hi
          rcases mul_eq_zero.mp this with h1 | h1
          · exact absurd (by linarith [neg_eq_zero.mp h1] : p i = 0) (ne_of_gt h0)
          · exact h1
        exact Real.eq_one_of_pos_of_log_eq_zero h0 this
    obtain ⟨i0, hi0⟩ := support_nonempty hsum
    have hone : p i0 = 1 := (hzo i0).resolve_left (mem_support.mp hi0)
    have hsupp : support p = {i0} := by
      apply Finset.eq_singleton_iff_unique_mem.mpr
      refine ⟨hi0, ?_⟩
      intro j hj
      by_contra hne
      have hj1 : p j = 1 := (hzo j).resolve_left (mem_support.mp hj)
      have : (2 : ℝ) ≤ ∑ i, p i := by
        have hsub : ({i0, j} : Finset ι) ⊆ Finset.univ := Finset.subset_univ _
        have : p i0 + p j ≤ ∑ i, p i := by
          have := Finset.sum_le_sum_of_subset_of_nonneg hsub (fun i _ _ => hp i)
          simpa [Finset.sum_pair (Ne.symm hne), hone, hj1] using this
        rw [hone, hj1] at this
        linarith
      rw [hsum] at this
      linarith
    rw [hsupp, Finset.card_singleton]
  · intro h
    obtain ⟨i0, hi0⟩ := Finset.card_eq_one.mp h
    have hone : p i0 = 1 := by
      have : ∑ i ∈ support p, p i = 1 := by rw [sum_support p, hsum]
      rwa [hi0, Finset.sum_singleton] at this
    have : ∑ i, Real.negMulLog (p i) = ∑ i ∈ support p, Real.negMulLog (p i) :=
      (sum_negMulLog_support p).symm
    rw [this, hi0, Finset.sum_singleton, hone, Real.negMulLog_one]

end Shannon

/-! ## Von Neumann entropy of a Hermitian matrix -/

section VonNeumann

variable {n : Type*} [Fintype n] [DecidableEq n]

open Matrix
open scoped ComplexOrder

/-- The von Neumann entropy of a matrix: the Shannon entropy of its spectrum
when the matrix is Hermitian, and `0` otherwise. -/
noncomputable def vnEntropy (A : Matrix n n ℂ) : ℝ :=
  if h : A.IsHermitian then ∑ i, Real.negMulLog (h.eigenvalues i) else 0

lemma vnEntropy_of_isHermitian {A : Matrix n n ℂ} (h : A.IsHermitian) :
    vnEntropy A = ∑ i, Real.negMulLog (h.eigenvalues i) := by
  simp [vnEntropy, h]

/-- Eigenvalues of a positive semidefinite matrix of unit trace form a
probability vector. -/
lemma sum_eigenvalues_eq_one {A : Matrix n n ℂ} (hA : A.PosSemidef) (htr : A.trace = 1) :
    ∑ i, hA.isHermitian.eigenvalues i = 1 := by
  have h := hA.isHermitian.trace_eq_sum_eigenvalues
  rw [htr] at h
  have : ((∑ i, hA.isHermitian.eigenvalues i : ℝ) : ℂ) = (1 : ℂ) := by
    push_cast
    exact h.symm
  exact_mod_cast this

/-- Von Neumann entropy of a positive semidefinite unit-trace matrix (a density
matrix) is nonnegative. -/
theorem vnEntropy_nonneg {A : Matrix n n ℂ} (hA : A.PosSemidef) (htr : A.trace = 1) :
    0 ≤ vnEntropy A := by
  rw [vnEntropy_of_isHermitian hA.isHermitian]
  exact sum_negMulLog_nonneg hA.eigenvalues_nonneg (sum_eigenvalues_eq_one hA htr)

/-- The rank of a Hermitian matrix equals the cardinality of the support of its
spectrum. -/
lemma rank_eq_card_support {A : Matrix n n ℂ} (hA : A.IsHermitian) :
    A.rank = (support hA.eigenvalues).card := by
  rw [hA.rank_eq_card_non_zero_eigs]
  rw [Fintype.card_subtype]
  rfl

/-- **Maximal entropy bound for density matrices.**  The von Neumann entropy of
a density matrix is at most the logarithm of its rank. -/
theorem vnEntropy_le_log_rank {A : Matrix n n ℂ} (hA : A.PosSemidef) (htr : A.trace = 1) :
    vnEntropy A ≤ Real.log A.rank := by
  rw [vnEntropy_of_isHermitian hA.isHermitian, rank_eq_card_support hA.isHermitian]
  exact sum_negMulLog_le_log_card_support hA.eigenvalues_nonneg (sum_eigenvalues_eq_one hA htr)

/-- **Purity criterion.**  A density matrix has vanishing von Neumann entropy
exactly when it has rank one, i.e. exactly when it is a pure state. -/
theorem vnEntropy_eq_zero_iff_rank_eq_one {A : Matrix n n ℂ} (hA : A.PosSemidef)
    (htr : A.trace = 1) : vnEntropy A = 0 ↔ A.rank = 1 := by
  rw [vnEntropy_of_isHermitian hA.isHermitian, rank_eq_card_support hA.isHermitian]
  exact sum_negMulLog_eq_zero_iff hA.eigenvalues_nonneg (sum_eigenvalues_eq_one hA htr)

omit [Fintype n] in
/-- A real scalar multiple of the identity matrix is Hermitian. -/
lemma isHermitian_real_smul_one (c : ℝ) : ((c : ℂ) • (1 : Matrix n n ℂ)).IsHermitian := by
  unfold Matrix.IsHermitian
  rw [Matrix.conjTranspose_smul, Matrix.conjTranspose_one]
  norm_num [Complex.star_def]

/-- Eigenvalues of a scalar matrix `c • 1` are all equal to `c`. -/
lemma eigenvalues_smul_one {c : ℝ} (hc : ((c : ℂ) • (1 : Matrix n n ℂ)).IsHermitian) (i : n) :
    hc.eigenvalues i = c := by
  have h := hc.eigenvalues_eq i
  have hmv : ((c : ℂ) • (1 : Matrix n n ℂ)) *ᵥ (hc.eigenvectorBasis i).ofLp
      = (c : ℂ) • (hc.eigenvectorBasis i).ofLp := by
    simp [Matrix.smul_mulVec]
  have hnorm : star ((hc.eigenvectorBasis i).ofLp) ⬝ᵥ ((hc.eigenvectorBasis i).ofLp) = 1 := by
    rw [dotProduct_comm, ← EuclideanSpace.inner_eq_star_dotProduct]
    simp [inner_self_eq_norm_sq_to_K, hc.eigenvectorBasis.orthonormal.1 i]
  rw [hmv, dotProduct_smul, hnorm] at h
  simpa using h

/-- Entropy read off from the multiset of characteristic roots. -/
theorem vnEntropy_eq_multiset_sum {A : Matrix n n ℂ} (hA : A.IsHermitian) :
    vnEntropy A = (A.charpoly.roots.map (fun z : ℂ => Real.negMulLog z.re)).sum := by
  rw [vnEntropy_of_isHermitian hA, hA.roots_charpoly_eq_eigenvalues, Multiset.map_map,
    Finset.sum_eq_multiset_sum]
  congr 1

omit [Fintype n] in
/-- A diagonal matrix with real entries is Hermitian. -/
lemma isHermitian_diagonal_real (v : n → ℝ) :
    (Matrix.diagonal (fun i => (v i : ℂ))).IsHermitian := by
  unfold Matrix.IsHermitian
  rw [Matrix.diagonal_conjTranspose]
  simp

/-- Characteristic roots of a diagonal matrix are its diagonal entries. -/
lemma roots_charpoly_diagonal (v : n → ℂ) :
    (Matrix.diagonal v).charpoly.roots = Multiset.map v Finset.univ.val := by
  rw [Matrix.charpoly_diagonal, Finset.prod_eq_multiset_prod]
  rw [show (Multiset.map (fun i => Polynomial.X - Polynomial.C (v i)) Finset.univ.val)
      = Multiset.map (fun a => Polynomial.X - Polynomial.C a)
        (Multiset.map v Finset.univ.val) by rw [Multiset.map_map]; rfl]
  exact Polynomial.roots_multiset_prod_X_sub_C _

/-- **Entropy of a diagonal density matrix** is the Shannon entropy of its
diagonal. -/
theorem vnEntropy_diagonal (v : n → ℝ) :
    vnEntropy (Matrix.diagonal (fun i => (v i : ℂ))) = ∑ i, Real.negMulLog (v i) := by
  rw [vnEntropy_eq_multiset_sum (isHermitian_diagonal_real v), roots_charpoly_diagonal,
    Multiset.map_map, ← Finset.sum_eq_multiset_sum]
  simp

/-- The entropy of a maximally mixed spectrum: `S(c • 1) = |n| · (-c log c)`. -/
theorem vnEntropy_smul_one (c : ℝ) :
    vnEntropy ((c : ℂ) • (1 : Matrix n n ℂ)) = (Fintype.card n : ℝ) * Real.negMulLog c := by
  have hherm : ((c : ℂ) • (1 : Matrix n n ℂ)).IsHermitian := isHermitian_real_smul_one c
  rw [vnEntropy_of_isHermitian hherm]
  simp [eigenvalues_smul_one hherm, Finset.card_univ]

end VonNeumann

end IITTensorNetwork