import Mathlib

/-!
# Smooth Four-Manifold Topology: Intersection Forms and Exotic Structures

This module formalizes the algebraic theory of intersection forms on 4-manifolds
and proves key results that detect exotic smooth structures. The central results are:

1. **Even quadratic form lemma**: A symmetric bilinear form with even diagonal
   entries produces even values on all integer vectors.
2. **Minimum norm bound**: Even positive-definite forms have minimum norm ≥ 2.
3. **Non-diagonalizability**: Even positive-definite unimodular forms cannot be
   equivalent to the standard diagonal form over ℤ.
4. **Donaldson obstruction**: Combined with Donaldson's diagonalization theorem,
   this proves that certain topological 4-manifolds cannot be smoothed.

## Mathematical Background

The intersection form of a closed, oriented, simply-connected 4-manifold M is
a unimodular symmetric bilinear form on H₂(M; ℤ). Freedman (1982) showed that
the homeomorphism type is determined by this form. Donaldson (1983) proved that
if M is smooth and the form is definite, it must be diagonalizable over ℤ.

The E₈ lattice is even, positive-definite, and unimodular of rank 8. Since it has
minimum norm 2, it is NOT diagonalizable. By Donaldson's theorem, no smooth
4-manifold realizes E₈. But by Freedman's theorem, such a manifold exists
topologically — giving the first examples of exotic 4-dimensional phenomena.
-/

open Finset BigOperators Matrix

noncomputable section

/-! ## Core Definitions -/

/-- The quadratic form value v^T M v for an integer matrix M and vector v. -/
def quadForm {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ) (v : Fin n → ℤ) : ℤ :=
  ∑ i : Fin n, ∑ j : Fin n, v i * M i j * v j

/-- The standard basis vector eᵢ in ℤⁿ. -/
def basisVec {n : ℕ} (i : Fin n) : Fin n → ℤ := fun j => if j = i then 1 else 0

/-- A symmetric integer matrix has even diagonal entries. -/
def HasEvenDiag {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  ∀ i : Fin n, 2 ∣ M i i

/-- A matrix is unimodular: its determinant is ±1. -/
def IsUnimodularZ {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  M.det = 1 ∨ M.det = -1

/-- Positive definiteness over ℤ: Q(v) > 0 for all nonzero integer vectors. -/
def IsPosDefZ {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  ∀ v : Fin n → ℤ, v ≠ 0 → 0 < quadForm M v

/-- Two matrices are ℤ-equivalent if there exists a unimodular P with Pᵀ M P = N. -/
def IsZEquiv {n : ℕ} (M N : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  ∃ P : Matrix (Fin n) (Fin n) ℤ, IsUnimodularZ P ∧ P.transpose * M * P = N

/-! ## Novel Definition: Smooth Structure Obstruction Certificate -/

/-- A certificate that an intersection form detects exotic (non-smoothable) behavior.
    This packages the algebraic invariants that, via Donaldson's theorem, obstruct
    the existence of a smooth structure on a topological 4-manifold.

    An ExoticWitness of rank n consists of an n×n integer matrix that is
    symmetric, even (all diagonal entries divisible by 2), positive definite
    (Q(v) > 0 for all nonzero v), and unimodular (det = ±1).

    These properties together guarantee minimum norm ≥ 2, making the form
    impossible to diagonalize over ℤ, which by Donaldson's theorem means
    no smooth 4-manifold can realize this intersection form. -/
structure ExoticWitness (n : ℕ) where
  form : Matrix (Fin n) (Fin n) ℤ
  symm : form.IsSymm
  even : HasEvenDiag form
  pos_def : IsPosDefZ form
  unimod : IsUnimodularZ form

/-! ## Key Algebraic Lemma: Even Diagonal Implies Even Quadratic Form

For a symmetric matrix M with even diagonal entries, Q(v) = v^T M v is even
for all integer vectors v. The proof decomposes Q(v) into diagonal terms
(each even because Mᵢᵢ is even) and off-diagonal terms (even by symmetry). -/

/-
**Even Quadratic Form Theorem**: If M is symmetric with even diagonal entries,
    then v^T M v is even for every integer vector v.
-/
theorem even_diag_even_quad {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ)
    (hS : M.IsSymm) (hE : HasEvenDiag M) (v : Fin n → ℤ) :
    2 ∣ quadForm M v := by
  -- Separate the sum into diagonal and off-diagonal parts.
  have h_split : quadForm M v = ∑ i, v i * M i i * v i + ∑ i, ∑ j ∈ Finset.univ.filter (fun j => i < j), (v i * M i j * v j + v j * M j i * v i) := by
    unfold quadForm;
    induction' n with n ih <;> simp +decide [ Fin.sum_univ_succ, * ];
    simp +decide [ Finset.sum_add_distrib, Finset.sum_filter, Finset.sum_range, Fin.sum_univ_succ ];
    specialize ih ( fun i j => M i.succ j.succ ) ( by ext i j; simpa using congr_fun ( congr_fun hS i.succ ) j.succ ) ( fun i => hE i.succ ) ( fun i => v i.succ ) ; simp_all +decide [ Finset.sum_add_distrib, Finset.sum_filter ] ; ring;
  simp_all +decide [ Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, hS.eq ];
  exact dvd_add ( Finset.dvd_sum fun i hi => dvd_mul_of_dvd_left ( hE i ) _ ) ( by rw [ ← Finset.sum_add_distrib ] ; exact Finset.dvd_sum fun i hi => by rw [ ← Finset.sum_add_distrib ] ; exact Finset.dvd_sum fun j hj => by rw [ hS.apply ] ; exact even_iff_two_dvd.mp ( by simp +decide [ mul_assoc, parity_simps ] ) )

/-! ## Minimum Norm Bound -/

/-
**Minimum Norm Theorem**: An even positive-definite form has minimum
    norm at least 2. Since Q(v) > 0 (so Q(v) ≥ 1) and Q(v) is even,
    we conclude Q(v) ≥ 2 for all nonzero v.
-/
theorem min_norm_even_posdef {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ)
    (hS : M.IsSymm) (hE : HasEvenDiag M) (hP : IsPosDefZ M)
    (v : Fin n → ℤ) (hv : v ≠ 0) :
    2 ≤ quadForm M v := by
  -- Since $M$ is symmetric and has even diagonal entries, $Q(v)$ is even.
  have h_even : 2 ∣ quadForm M v := by
    exact even_diag_even_quad M hS hE v
  exact Int.le_of_dvd ( hP v hv ) h_even

/-! ## Non-Diagonalizability -/

/-
Basis vectors are nonzero.
-/
theorem basisVec_ne_zero {n : ℕ} (i : Fin n) : basisVec i ≠ (0 : Fin n → ℤ) := by
  exact fun h => by have := congr_fun h i; simp +decide [ basisVec ] at this;

/-
The quadratic form of a basis vector in the identity matrix is 1.
-/
theorem quadForm_one_basis {n : ℕ} (i : Fin n) :
    quadForm (1 : Matrix (Fin n) (Fin n) ℤ) (basisVec i) = 1 := by
  unfold quadForm basisVec; aesop;

/-
The quadratic form is preserved under congruence: if N = Pᵀ M P,
    then Q_N(v) = Q_M(P v).
-/
theorem quadForm_congruence {n : ℕ} (M : Matrix (Fin n) (Fin n) ℤ)
    (P : Matrix (Fin n) (Fin n) ℤ) (v : Fin n → ℤ) :
    quadForm (P.transpose * M * P) v = quadForm M (P.mulVec v) := by
  unfold quadForm;
  simp +decide [ Matrix.mul_apply, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
  simp +decide only [mulVec, dotProduct, mul_sum];
  simp +decide only [sum_mul];
  simp +decide only [sum_sigma', Finset.mul_sum _ _ _];
  apply Finset.sum_bij (fun x _ => ⟨x.snd.snd.snd, x.snd.snd.fst, x.snd.fst, x.fst⟩);
  · aesop;
  · aesop;
  · aesop;
  · grind

/-
A column of a unimodular matrix is nonzero.
-/
theorem unimod_col_ne_zero {n : ℕ} (P : Matrix (Fin n) (Fin n) ℤ)
    (hU : IsUnimodularZ P) (hn : 0 < n) (i : Fin n) :
    (fun j => P j i) ≠ 0 := by
  -- If P were to have a zero column, then its determinant would be zero, contradicting the unimodularity.
  by_contra h_contra
  have h_det_zero : Matrix.det P = 0 := by
    exact Matrix.det_eq_zero_of_column_eq_zero i ( by simpa using congr_fun h_contra )
  have h_det_one : Matrix.det P = 1 ∨ Matrix.det P = -1 := by
    exact hU
  aesop

/-
**Non-Diagonalizability Theorem**: An even positive-definite form
    is not ℤ-equivalent to the identity matrix.

    Proof: Suppose Pᵀ M P = I for unimodular P. Then for each column
    vector pᵢ = P eᵢ, we have Q_M(pᵢ) = Q_I(eᵢ) = 1 via the congruence
    identity. But since M is even and positive definite, Q_M(pᵢ) ≥ 2
    for any nonzero vector — and pᵢ is nonzero since P is invertible.
    This gives the contradiction 2 ≤ 1.
-/
theorem even_posdef_not_equiv_identity {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℤ)
    (hS : M.IsSymm) (hE : HasEvenDiag M) (hP : IsPosDefZ M) :
    ¬ IsZEquiv M (1 : Matrix (Fin n) (Fin n) ℤ) := by
  rintro ⟨ P, hP₁, hP₂ ⟩;
  -- Let $i$ be an arbitrary index in $\{0, 1, ..., n-1\}$.
  obtain ⟨i, hi⟩ : ∃ i : Fin n, P.mulVec (basisVec i) ≠ 0 := by
    contrapose! hP₁;
    -- If $P.mulVec (basisVec i) = 0$ for all $i$, then $P$ is the zero matrix.
    have hP_zero : P = 0 := by
      ext i j; specialize hP₁ j; replace hP₁ := congr_fun hP₁ i; simp_all +decide [ Matrix.mulVec, dotProduct ] ;
      simp_all +decide [ basisVec ];
    cases n <;> aesop;
  have := quadForm_congruence M P ( basisVec i );
  rw [ hP₂, quadForm_one_basis ] at this ; linarith [ min_norm_even_posdef M hS hE hP ( P.mulVec ( basisVec i ) ) hi ]

/-! ## Donaldson Obstruction -/

/-- **Donaldson Obstruction**: An ExoticWitness certifies that the intersection
    form cannot be diagonalized, hence (by Donaldson) cannot be smooth. -/
theorem exotic_witness_obstructs {n : ℕ} (hn : 0 < n) (w : ExoticWitness n) :
    ¬ IsZEquiv w.form (1 : Matrix (Fin n) (Fin n) ℤ) :=
  even_posdef_not_equiv_identity hn w.form w.symm w.even w.pos_def

/-! ## Signature Theory for Intersection Forms -/

/-- The signature data of a form: counts of positive/negative eigenvalues. -/
structure FormSignatureData (n : ℕ) where
  bPlus : ℕ
  bMinus : ℕ
  rank_eq : bPlus + bMinus = n

/-- The signature σ = b⁺ - b⁻. -/
def FormSignatureData.signature {n : ℕ} (d : FormSignatureData n) : ℤ :=
  (d.bPlus : ℤ) - (d.bMinus : ℤ)

/-- The direct sum of two form signature data records. -/
def FormSignatureData.directSum {n m : ℕ}
    (d₁ : FormSignatureData n) (d₂ : FormSignatureData m) :
    FormSignatureData (n + m) where
  bPlus := d₁.bPlus + d₂.bPlus
  bMinus := d₁.bMinus + d₂.bMinus
  rank_eq := by have := d₁.rank_eq; have := d₂.rank_eq; omega

/-
**Signature Additivity**: The signature of a direct sum equals the sum of
    signatures. This is fundamental for invariants of connected sums.
-/
theorem signature_additive {n m : ℕ}
    (d₁ : FormSignatureData n) (d₂ : FormSignatureData m) :
    (d₁.directSum d₂).signature = d₁.signature + d₂.signature := by
  unfold FormSignatureData.signature FormSignatureData.directSum; simp +decide [ add_assoc, add_left_comm, add_comm ] ;
  ring

/-
For a positive-definite form, b⁻ = 0 and σ = rank.
-/
theorem posdef_signature {n : ℕ} (d : FormSignatureData n)
    (h : d.bMinus = 0) : d.signature = n := by
  simp_all +decide [ FormSignatureData.rank_eq, FormSignatureData.signature ];
  linarith [ d.rank_eq ]

/-! ## Furuta's 10/8 Bound -/

/-
**Furuta Exclusion of E₈**: The Furuta bound 8r ≥ 10|σ| + 16 with
    r = 8 and |σ| = 8 gives 64 ≥ 96, a contradiction.
-/
theorem furuta_excludes_e8 (d : FormSignatureData 8)
    (h_sig : |d.signature| = 8)
    (h_furuta : (8 : ℤ) * 8 ≥ 10 * |d.signature| + 16) : False := by
  linarith

/-
**Furuta Exclusion of E₈ ⊕ E₈**: rank 16, |σ| = 16 gives 128 ≥ 176.
-/
theorem furuta_excludes_e8_double (d : FormSignatureData 16)
    (h_sig : |d.signature| = 16)
    (h_furuta : (8 : ℤ) * 16 ≥ 10 * |d.signature| + 16) : False := by
  grind

/-! ## Computational Verification -/

example : ¬ ((8 : ℤ) * 8 ≥ 10 * 8 + 16) := by omega
example : ¬ ((8 : ℤ) * 16 ≥ 10 * 16 + 16) := by omega
/-- Verify: rank 12 with |σ| = 8 just satisfies the Furuta bound -/
example : (8 : ℤ) * 12 ≥ 10 * 8 + 16 := by omega

end