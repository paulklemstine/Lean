import Mathlib
import Catalog.NumberTheory.EMLQuantumRigidityLocus

/-!
# Stratum separation for the quantum EML rigidity locus

`Catalog/NumberTheory/EMLQuantumRigidityLocus.lean` proved that the rigidity locus

`𝓛 n = {H : Matrix n n ℂ | H Hermitian ∧ H² = t*² I}`

is exactly the affine image `H = t* (2P − I)` of the orthogonal projections, that it is
compact and nowhere dense, and that two admissible Hamiltonians either share a trace or
their traces differ by at least `2 t*`.  It also showed (`exists_distinct_close_mem`) that
the trace gap does **not** upgrade to a distance gap on the whole locus: distinct
admissible Hamiltonians of the *same* trace can be arbitrarily close.

This file proves the corrected separation statement — next-cycle Conjecture B of
`FUTURE_DIRECTIONS.md`:

* `frobSq` is the squared Frobenius norm, and `frobSq_eq_trace` identifies it with
  `tr (M Mᴴ)`.
* `abs_frobSq_sub_le_frobSq_sub` — a projection inequality of independent interest:
  for orthogonal projections `P, Q`, `|tr P − tr Q| ≤ ‖P − Q‖_F²`.  The proof is the
  positivity chain `tr P − tr (PQ) = ‖P(I − Q)‖_F² ≥ 0`.
* `frobSq_sub_ge_of_trace_ne`, `two_scalarLogRoot_le_frobenius_dist` — **stratum
  separation**: two admissible Hamiltonians lying in different rank strata (equivalently,
  with different traces) satisfy `‖H − K‖_F ≥ 2 t*`.  This is a strict strengthening of
  the trace gap `trace_eq_or_two_scalarLogRoot_le_dist`, and it is sharp: the pair
  `(t* I, −t* I)` in dimension one attains it.
* `exists_entry_dist_ge` — the entrywise shadow of the separation, giving a genuine
  separation of strata in the ambient (sup-norm) topology of `Matrix n n ℂ`.
* `not_mem_rigidityLocus_of_row_normSq_int` — the **integral row obstruction**: if every
  entry of `H` has integral squared modulus, `H` is not admissible.  Corollaries:
  the Eisenstein-integer obstruction `not_mem_rigidityLocus_of_eisensteinInt` and the
  obstruction for the imaginary quadratic orders `ℤ[√−d]`
  (`not_mem_rigidityLocus_of_quadraticInt`), which contains the Gaussian-integer case
  `d = 1` proved in the previous instalment.

All results are unconditional and use only the standard Lean axioms.
-/

open Complex Matrix Set

namespace QuantumEML

namespace Locus

variable {n : Type*} [Fintype n] [DecidableEq n]

/-! ### The squared Frobenius norm -/

/-- The squared Frobenius norm `∑_{i,j} |M_{ij}|²`. -/
noncomputable def frobSq (M : Matrix n n ℂ) : ℝ := ∑ i, ∑ j, ‖M i j‖ ^ 2

omit [DecidableEq n] in
theorem frobSq_nonneg (M : Matrix n n ℂ) : 0 ≤ frobSq M :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _

omit [DecidableEq n] in
/-- The Frobenius norm as a trace: `‖M‖_F² = tr (M Mᴴ)`. -/
theorem frobSq_eq_trace (M : Matrix n n ℂ) : ((frobSq M : ℝ) : ℂ) = (M * Mᴴ).trace := by
  simp only [frobSq, Matrix.trace, Matrix.diag_apply, Matrix.mul_apply,
    Matrix.conjTranspose_apply, Complex.ofReal_sum]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  rw [show (star (M i j)) = (starRingEnd ℂ) (M i j) from rfl, Complex.mul_conj]
  norm_cast
  exact (Complex.normSq_eq_norm_sq (M i j)).symm

omit [DecidableEq n] in
/-- For a Hermitian matrix the Frobenius norm is the trace of the square. -/
theorem frobSq_eq_trace_sq {M : Matrix n n ℂ} (hM : M.IsHermitian) :
    ((frobSq M : ℝ) : ℂ) = (M * M).trace := by
  rw [frobSq_eq_trace, hM.eq]

omit [DecidableEq n] in
theorem frobSq_smul (z : ℂ) (M : Matrix n n ℂ) : frobSq (z • M) = ‖z‖ ^ 2 * frobSq M := by
  simp only [frobSq, Matrix.smul_apply, smul_eq_mul, norm_mul, mul_pow, Finset.mul_sum]

/-! ### A trace inequality for orthogonal projections -/

omit [DecidableEq n] in
/-- `tr (PQ)` is the squared Frobenius norm of `PQ`; in particular it is a nonnegative
real number. -/
theorem trace_mul_eq_frobSq {P Q : Matrix n n ℂ} (hP : P.IsHermitian) (hPi : IsIdempotentElem P)
    (hQ : Q.IsHermitian) (hQi : IsIdempotentElem Q) :
    (P * Q).trace = ((frobSq (P * Q) : ℝ) : ℂ) := by
  rw [frobSq_eq_trace, Matrix.conjTranspose_mul, hP.eq, hQ.eq]
  have h1 : P * Q * (Q * P) = P * (Q * P) := by
    rw [Matrix.mul_assoc P Q (Q * P), ← Matrix.mul_assoc Q Q P, hQi.eq]
  rw [h1, ← Matrix.mul_assoc, Matrix.trace_mul_comm (P * Q) P, ← Matrix.mul_assoc, hPi.eq]

/-- The defect `tr P − tr (PQ)` is a squared Frobenius norm, hence nonnegative. -/
theorem trace_sub_trace_mul_eq_frobSq {P Q : Matrix n n ℂ} (hP : P.IsHermitian)
    (hPi : IsIdempotentElem P) (hQ : Q.IsHermitian) (hQi : IsIdempotentElem Q) :
    P.trace - (P * Q).trace = ((frobSq (P * (1 - Q)) : ℝ) : ℂ) := by
  have hherm : (1 - Q)ᴴ = 1 - Q := by
    rw [Matrix.conjTranspose_sub, Matrix.conjTranspose_one, hQ.eq]
  have hidem : (1 - Q) * (1 - Q) = 1 - Q := hQi.one_sub
  rw [frobSq_eq_trace, Matrix.conjTranspose_mul, hherm, hP.eq]
  have h1 : P * (1 - Q) * ((1 - Q) * P) = P * (1 - Q) * P := by
    rw [Matrix.mul_assoc P (1 - Q) ((1 - Q) * P), ← Matrix.mul_assoc (1 - Q) (1 - Q) P, hidem,
      Matrix.mul_assoc]
  rw [h1, Matrix.trace_mul_comm (P * (1 - Q)) P, ← Matrix.mul_assoc, hPi.eq, Matrix.mul_sub,
    Matrix.mul_one, Matrix.trace_sub]

omit [DecidableEq n] in
/-- For an orthogonal projection, the trace is the squared Frobenius norm. -/
theorem trace_eq_frobSq_of_projection {P : Matrix n n ℂ} (hP : P.IsHermitian)
    (hPi : IsIdempotentElem P) : P.trace = ((frobSq P : ℝ) : ℂ) := by
  rw [frobSq_eq_trace_sq hP, hPi.eq]

omit [DecidableEq n] in
/-- `‖P − Q‖_F² = tr P + tr Q − 2 tr (PQ)` for orthogonal projections. -/
theorem frobSq_sub_projections {P Q : Matrix n n ℂ} (hP : P.IsHermitian)
    (hPi : IsIdempotentElem P) (hQ : Q.IsHermitian) (hQi : IsIdempotentElem Q) :
    frobSq (P - Q) = frobSq P + frobSq Q - 2 * frobSq (P * Q) := by
  have hherm : (P - Q).IsHermitian := hP.sub hQ
  have hexp : (P - Q) * (P - Q) = P - P * Q - Q * P + Q := by
    have hPP : P * P = P := hPi
    have hQQ : Q * Q = Q := hQi
    rw [Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub, hPP, hQQ]
    abel
  have hcast : ((frobSq (P - Q) : ℝ) : ℂ)
      = ((frobSq P + frobSq Q - 2 * frobSq (P * Q) : ℝ) : ℂ) := by
    rw [frobSq_eq_trace_sq hherm, hexp, Matrix.trace_add, Matrix.trace_sub, Matrix.trace_sub,
      Matrix.trace_mul_comm Q P, trace_eq_frobSq_of_projection hP hPi,
      trace_eq_frobSq_of_projection hQ hQi, trace_mul_eq_frobSq hP hPi hQ hQi]
    push_cast
    ring
  exact_mod_cast hcast

/-- **The projection inequality.**  For two orthogonal projections,
`|tr P − tr Q| ≤ ‖P − Q‖_F²`.  Since the traces are the ranks, projections of different
rank are at squared Frobenius distance at least `1`. -/
theorem abs_frobSq_sub_le_frobSq_sub {P Q : Matrix n n ℂ} (hP : P.IsHermitian)
    (hPi : IsIdempotentElem P) (hQ : Q.IsHermitian) (hQi : IsIdempotentElem Q) :
    |frobSq P - frobSq Q| ≤ frobSq (P - Q) := by
  have hPQ : frobSq P - frobSq (P * Q) = frobSq (P * (1 - Q)) := by
    have h := trace_sub_trace_mul_eq_frobSq hP hPi hQ hQi
    rw [trace_eq_frobSq_of_projection hP hPi, trace_mul_eq_frobSq hP hPi hQ hQi] at h
    exact_mod_cast h
  have hQP : frobSq Q - frobSq (P * Q) = frobSq (Q * (1 - P)) := by
    have h := trace_sub_trace_mul_eq_frobSq hQ hQi hP hPi
    rw [trace_eq_frobSq_of_projection hQ hQi, Matrix.trace_mul_comm Q P,
      trace_mul_eq_frobSq hP hPi hQ hQi] at h
    exact_mod_cast h
  have h1 : 0 ≤ frobSq P - frobSq (P * Q) := hPQ ▸ frobSq_nonneg _
  have h2 : 0 ≤ frobSq Q - frobSq (P * Q) := hQP ▸ frobSq_nonneg _
  rw [frobSq_sub_projections hP hPi hQ hQi, abs_le]
  constructor <;> linarith

/-! ### The spectral projection of an admissible Hamiltonian -/

/-- The spectral projection `P = (I + t*⁻¹ H)/2` onto the `+t*` eigenspace. -/
noncomputable def projOf (H : Matrix n n ℂ) : Matrix n n ℂ :=
  ((2 : ℂ)⁻¹) • ((1 : Matrix n n ℂ) + ((scalarLogRoot⁻¹ : ℝ) : ℂ) • H)

omit [Fintype n] in
theorem isHermitian_projOf {H : Matrix n n ℂ} (hH : H.IsHermitian) : (projOf H).IsHermitian :=
  isHermitian_projection hH

theorem isIdempotentElem_projOf {H : Matrix n n ℂ} (hH : H ∈ rigidityLocus n) :
    IsIdempotentElem (projOf H) :=
  isIdempotentElem_projection hH.1 ((mem_rigidityLocus_iff_logActivation hH.1).1 hH)

omit [Fintype n] in
/-- The Hamiltonian is recovered from its spectral projection: `H = t* (2P − I)`; hence
differences of admissible Hamiltonians are `2 t*` times differences of projections. -/
theorem sub_eq_smul_projOf_sub (A B : Matrix n n ℂ) :
    A - B = ((2 * scalarLogRoot : ℝ) : ℂ) • (projOf A - projOf B) := by
  have hne : ((scalarLogRoot : ℝ) : ℂ) ≠ 0 :=
    Complex.ofReal_ne_zero.2 scalarLogRoot_ne_zero
  simp only [projOf, smul_sub, smul_smul]
  push_cast
  rw [smul_add, smul_add, smul_smul, smul_smul]
  have h1 : (2 : ℂ) * (scalarLogRoot : ℂ) * (2 : ℂ)⁻¹ * ((scalarLogRoot : ℂ)⁻¹) = 1 := by
    field_simp
  rw [h1, one_smul, one_smul]
  abel

/-- The trace of the spectral projection is the number of `+t*` levels; in particular it
is a natural number. -/
theorem frobSq_projOf_eq {H : Matrix n n ℂ} (hH : H ∈ rigidityLocus n) :
    frobSq (projOf H) = (upperLevelCount hH.1 : ℝ) := by
  have hu : logActivation hH.1 ∈ unitary (Matrix n n ℂ) :=
    (mem_rigidityLocus_iff_logActivation hH.1).1 hH
  have htr := trace_eq hH.1 hu
  have hne : ((scalarLogRoot : ℝ) : ℂ) ≠ 0 :=
    Complex.ofReal_ne_zero.2 scalarLogRoot_ne_zero
  have htrP : (projOf H).trace = ((upperLevelCount hH.1 : ℝ) : ℂ) := by
    simp only [projOf, Matrix.trace_smul, Matrix.trace_add, Matrix.trace_smul,
      Matrix.trace_one, smul_eq_mul, htr]
    push_cast
    field_simp
    ring
  have := trace_eq_frobSq_of_projection (isHermitian_projOf hH.1) (isIdempotentElem_projOf hH)
  rw [htrP] at this
  exact_mod_cast this.symm

/-! ### Stratum separation -/

/-- **Stratum separation (squared form).**  If two admissible Hamiltonians have different
traces — equivalently, different numbers of `+t*` levels — then their squared Frobenius
distance is at least `4 t*²`. -/
theorem frobSq_sub_ge_of_trace_ne {A B : Matrix n n ℂ} (hA : A ∈ rigidityLocus n)
    (hB : B ∈ rigidityLocus n) (hne : A.trace ≠ B.trace) :
    4 * scalarLogRoot ^ 2 ≤ frobSq (A - B) := by
  have hAu : logActivation hA.1 ∈ unitary (Matrix n n ℂ) :=
    (mem_rigidityLocus_iff_logActivation hA.1).1 hA
  have hBu : logActivation hB.1 ∈ unitary (Matrix n n ℂ) :=
    (mem_rigidityLocus_iff_logActivation hB.1).1 hB
  have hkl : upperLevelCount hA.1 ≠ upperLevelCount hB.1 := by
    intro h
    exact hne (by rw [trace_eq hA.1 hAu, trace_eq hB.1 hBu, h])
  -- the projections differ in trace, hence by at least `1` in squared Frobenius norm
  have hproj := abs_frobSq_sub_le_frobSq_sub (isHermitian_projOf hA.1) (isIdempotentElem_projOf hA)
    (isHermitian_projOf hB.1) (isIdempotentElem_projOf hB)
  rw [frobSq_projOf_eq hA, frobSq_projOf_eq hB] at hproj
  have hone : (1 : ℝ) ≤ |(upperLevelCount hA.1 : ℝ) - (upperLevelCount hB.1 : ℝ)| := by
    have hZ : ((upperLevelCount hA.1 : ℤ) - (upperLevelCount hB.1 : ℤ)) ≠ 0 := by
      simpa [sub_eq_zero] using fun h => hkl (by exact_mod_cast h)
    have h1 : (1 : ℤ) ≤ |(upperLevelCount hA.1 : ℤ) - (upperLevelCount hB.1 : ℤ)| :=
      Int.one_le_abs hZ
    have : ((1 : ℤ) : ℝ) ≤ ((|(upperLevelCount hA.1 : ℤ) - (upperLevelCount hB.1 : ℤ)| : ℤ) : ℝ) :=
      by exact_mod_cast h1
    simpa [Int.cast_abs] using this
  have hscale : frobSq (A - B)
      = (2 * scalarLogRoot) ^ 2 * frobSq (projOf A - projOf B) := by
    rw [sub_eq_smul_projOf_sub A B, frobSq_smul]
    congr 1
    rw [Complex.norm_real, Real.norm_eq_abs, abs_of_pos (by nlinarith [scalarLogRoot_pos])]
  rw [hscale]
  nlinarith [scalarLogRoot_pos, hproj, hone, frobSq_nonneg (projOf A - projOf B)]

/-- **Stratum separation.**  Admissible Hamiltonians with different traces are at
Frobenius distance at least `2 t*`. -/
theorem two_scalarLogRoot_le_frobenius_dist {A B : Matrix n n ℂ} (hA : A ∈ rigidityLocus n)
    (hB : B ∈ rigidityLocus n) (hne : A.trace ≠ B.trace) :
    2 * scalarLogRoot ≤ Real.sqrt (frobSq (A - B)) := by
  have h := frobSq_sub_ge_of_trace_ne hA hB hne
  have h2 : Real.sqrt ((2 * scalarLogRoot) ^ 2) ≤ Real.sqrt (frobSq (A - B)) := by
    apply Real.sqrt_le_sqrt
    nlinarith
  rwa [Real.sqrt_sq (by nlinarith [scalarLogRoot_pos])] at h2

/-- The dichotomy, in the shape of the previous instalment's trace gap but with the
*matrix* distance on the right-hand side: two admissible Hamiltonians either lie in the
same stratum or are `2 t*` apart in Frobenius norm. -/
theorem trace_eq_or_two_scalarLogRoot_le_frobenius_dist {A B : Matrix n n ℂ}
    (hA : A ∈ rigidityLocus n) (hB : B ∈ rigidityLocus n) :
    A.trace = B.trace ∨ 2 * scalarLogRoot ≤ Real.sqrt (frobSq (A - B)) := by
  by_cases h : A.trace = B.trace
  · exact Or.inl h
  · exact Or.inr (two_scalarLogRoot_le_frobenius_dist hA hB h)

/-- Separation in the ambient sup-norm topology: two admissible Hamiltonians in different
strata have an entry at distance at least `2 t* / card n`. -/
theorem exists_entry_dist_ge [Nonempty n] {A B : Matrix n n ℂ} (hA : A ∈ rigidityLocus n)
    (hB : B ∈ rigidityLocus n) (hne : A.trace ≠ B.trace) :
    ∃ i j, 2 * scalarLogRoot / (Fintype.card n : ℝ) ≤ ‖A i j - B i j‖ := by
  classical
  by_contra hcon
  push_neg at hcon
  set c : ℝ := 2 * scalarLogRoot / (Fintype.card n : ℝ) with hc
  have hcard : 0 < (Fintype.card n : ℝ) := by
    have := Fintype.card_pos (α := n)
    exact_mod_cast this
  have hcpos : 0 < c := by
    rw [hc]
    exact div_pos (by nlinarith [scalarLogRoot_pos]) hcard
  have hbound : frobSq (A - B) < (Fintype.card n : ℝ) ^ 2 * c ^ 2 := by
    have hlt : ∀ i, ∑ j, ‖(A - B) i j‖ ^ 2 < (Fintype.card n : ℝ) * c ^ 2 := by
      intro i
      have hterm : ∀ j ∈ (Finset.univ : Finset n), ‖(A - B) i j‖ ^ 2 < c ^ 2 := by
        intro j _
        have h1 : ‖(A - B) i j‖ < c := by
          simpa [Matrix.sub_apply] using hcon i j
        nlinarith [norm_nonneg ((A - B) i j)]
      calc ∑ j, ‖(A - B) i j‖ ^ 2 < ∑ _j : n, c ^ 2 :=
            Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty hterm
        _ = (Fintype.card n : ℝ) * c ^ 2 := by
            simp [Finset.card_univ]
    calc frobSq (A - B) = ∑ i, ∑ j, ‖(A - B) i j‖ ^ 2 := rfl
      _ < ∑ _i : n, (Fintype.card n : ℝ) * c ^ 2 :=
          Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty (fun i _ => hlt i)
      _ = (Fintype.card n : ℝ) ^ 2 * c ^ 2 := by
          simp [Finset.card_univ]
          ring
  have hcsq : (Fintype.card n : ℝ) ^ 2 * c ^ 2 = 4 * scalarLogRoot ^ 2 := by
    rw [hc]
    field_simp
    ring
  rw [hcsq] at hbound
  exact absurd (frobSq_sub_ge_of_trace_ne hA hB hne) (not_le.2 hbound)

/-- Sharpness: in dimension one the two admissible Hamiltonians `± t*` realise the
separation constant `2 t*` exactly. -/
theorem exists_pair_frobenius_dist_eq_two_scalarLogRoot [Unique n] :
    ∃ A B : Matrix n n ℂ, A ∈ rigidityLocus n ∧ B ∈ rigidityLocus n ∧ A.trace ≠ B.trace ∧
      Real.sqrt (frobSq (A - B)) = 2 * scalarLogRoot := by
  refine ⟨((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ),
    -(((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ)), smul_one_mem, neg_mem smul_one_mem, ?_, ?_⟩
  · have hpos : (0 : ℝ) < scalarLogRoot := scalarLogRoot_pos
    simp only [Matrix.trace_smul, Matrix.trace_neg, Matrix.trace_one, smul_eq_mul]
    intro h
    have hcard : (Fintype.card n : ℂ) = 1 := by
      simp
    rw [hcard] at h
    have : ((scalarLogRoot : ℝ) : ℂ) = 0 := by linear_combination h / 2
    exact scalarLogRoot_ne_zero (by exact_mod_cast this)
  · have hsub : (((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ))
        - (-(((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ)))
        = ((2 * scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ) := by
      push_cast
      module
    rw [hsub, frobSq_smul]
    have hone : frobSq (1 : Matrix n n ℂ) = 1 := by
      simp only [frobSq]
      rw [Finset.sum_eq_single (default : n)]
      · rw [Finset.sum_eq_single (default : n)]
        · simp
        · intro j _ hj
          exact absurd (Subsingleton.elim j default) hj
        · intro h
          exact absurd (Finset.mem_univ _) h
      · intro i _ hi
        exact absurd (Subsingleton.elim i default) hi
      · intro h
        exact absurd (Finset.mem_univ _) h
    rw [hone, mul_one, Complex.norm_real, Real.norm_eq_abs,
      abs_of_pos (by nlinarith [scalarLogRoot_pos])]
    exact Real.sqrt_sq (by nlinarith [scalarLogRoot_pos])

/-! ### Integral obstructions from row quantization -/

/-- **Integral row obstruction.**  If every entry of a matrix has integral squared
modulus, it is not admissible: row quantization would force the integer
`∑_j |H_{ij}|²` to equal `t*² ∈ (1, 2)`. -/
theorem not_mem_rigidityLocus_of_row_normSq_int [Nonempty n] {H : Matrix n n ℂ}
    (hz : ∀ i j, ∃ m : ℤ, ‖H i j‖ ^ 2 = (m : ℝ)) : H ∉ rigidityLocus n := by
  intro hH
  obtain ⟨i⟩ := ‹Nonempty n›
  choose m hm using hz i
  have hrow := row_normSq_eq hH i
  have hsum : ((∑ j, m j : ℤ) : ℝ) = scalarLogRoot ^ 2 := by
    rw [← hrow]
    push_cast
    exact Finset.sum_congr rfl fun j _ => (hm j).symm
  set M : ℤ := ∑ j, m j with hM
  have h1 : (1 : ℝ) < (M : ℝ) := by rw [hsum]; exact one_lt_scalarLogRoot_sq
  have h2 : (M : ℝ) < 2 := by rw [hsum]; exact scalarLogRoot_sq_lt_two
  have h1' : (1 : ℤ) < M := by exact_mod_cast h1
  have h2' : M < (2 : ℤ) := by exact_mod_cast h2
  omega

/-- **Eisenstein-integer obstruction.**  No Hermitian matrix with entries in the
Eisenstein integers `ℤ[ω]`, `ω = (−1 + i√3)/2`, is admissible: `|a + bω|² = a² − ab + b²`
is a rational integer. -/
theorem not_mem_rigidityLocus_of_eisensteinInt [Nonempty n] {H : Matrix n n ℂ}
    (hz : ∀ i j, ∃ a b : ℤ, H i j =
      (a : ℂ) + (b : ℂ) * ((-1 + (Real.sqrt 3 : ℝ) * I) / 2)) : H ∉ rigidityLocus n := by
  refine not_mem_rigidityLocus_of_row_normSq_int ?_
  intro i j
  obtain ⟨a, b, hab⟩ := hz i j
  refine ⟨a ^ 2 - a * b + b ^ 2, ?_⟩
  have h3 : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hre : (H i j).re = (a : ℝ) - (b : ℝ) / 2 := by
    rw [hab]; simp; ring
  have him : (H i j).im = (b : ℝ) * (Real.sqrt 3) / 2 := by
    rw [hab]; simp; ring
  have hnorm : ‖H i j‖ ^ 2 = (H i j).re ^ 2 + (H i j).im ^ 2 := by
    rw [← Complex.normSq_eq_norm_sq, Complex.normSq_apply]
    ring
  rw [hnorm, hre, him]
  push_cast
  nlinarith [h3]

/-- **Quadratic-integer obstruction.**  No Hermitian matrix with entries in the imaginary
quadratic order `ℤ[√−d]` (`d ≥ 1`) is admissible.  The Gaussian-integer case of the
previous instalment is `d = 1`. -/
theorem not_mem_rigidityLocus_of_quadraticInt [Nonempty n] {H : Matrix n n ℂ} (d : ℕ)
    (hz : ∀ i j, ∃ a b : ℤ, H i j = (a : ℂ) + (b : ℂ) * ((Real.sqrt d : ℝ) * I)) :
    H ∉ rigidityLocus n := by
  refine not_mem_rigidityLocus_of_row_normSq_int ?_
  intro i j
  obtain ⟨a, b, hab⟩ := hz i j
  refine ⟨a ^ 2 + d * b ^ 2, ?_⟩
  have hd : (Real.sqrt d) ^ 2 = (d : ℝ) := Real.sq_sqrt (by positivity)
  have hre : (H i j).re = (a : ℝ) := by
    rw [hab]; simp
  have him : (H i j).im = (b : ℝ) * (Real.sqrt d) := by
    rw [hab]; simp
  have hnorm : ‖H i j‖ ^ 2 = (H i j).re ^ 2 + (H i j).im ^ 2 := by
    rw [← Complex.normSq_eq_norm_sq, Complex.normSq_apply]
    ring
  rw [hnorm, hre, him]
  push_cast
  nlinarith [hd]

/-- The catalog form of the integral obstruction: for a Hermitian matrix all of whose
entries have integral squared modulus, the logarithmic activation is never unitary. -/
theorem not_logActivation_mem_unitary_of_row_normSq_int [Nonempty n] {H : Matrix n n ℂ}
    (hH : H.IsHermitian) (hz : ∀ i j, ∃ m : ℤ, ‖H i j‖ ^ 2 = (m : ℝ)) :
    logActivation hH ∉ unitary (Matrix n n ℂ) := fun hu =>
  not_mem_rigidityLocus_of_row_normSq_int hz ((mem_rigidityLocus_iff_logActivation hH).2 hu)

end Locus

end QuantumEML