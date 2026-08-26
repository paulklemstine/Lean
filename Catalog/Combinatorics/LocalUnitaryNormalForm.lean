import Mathlib

/-!
# Local-unitary normal form for maximally entangled two-qubit states

A two-qubit pure state `∑ᵢⱼ Mᵢⱼ |ij⟩` is encoded by its `2 × 2` complex amplitude matrix
`M : Matrix (Fin 2) (Fin 2) ℂ`.  Its squared Frobenius norm `frobSq M` is the total
probability and its *concurrence* is `concurrence M = 2 ‖det M‖` (Wootters).  A **sharp
maximizer** is a normalized state whose concurrence attains the maximal value `1`.

The main results are:

* `two_mul_norm_det_le_frobSq` : the sharp inequality `2 ‖det M‖ ≤ ‖M‖_F²`, obtained from the
  two-dimensional Lagrange / Cauchy–Binet identity `lagrange_two` together with AM–GM;
  `concurrence_le_one` is the resulting bound on normalized states.
* `row_sq_of_sharp`, `rowGram_of_sharp` : the **row classification** — the two rows of a
  normalized sharp maximizer are orthogonal and each of squared length `1/2`, equivalently
  `M * Mᴴ = (1/2) • 1`: the reduced density matrix is maximally mixed.
* `sharp_iff_rowGram` : conversely, a maximally mixed reduced density matrix forces sharpness.
* `sqrtTwo_smul_mem_unitaryGroup` : the promised step "build a unitary from an orthonormal
  basis" — for a sharp maximizer `√2 • M` is a unitary matrix.
* `localAct` : the two-sided `U(2) × U(2)` action `M ↦ U M Vᵀ` of the local unitaries `U ⊗ V`
  on amplitude matrices, with its action laws (`localAct_one`, `localAct_mul`) and the
  invariance of both `frobSq` and `‖det ·‖` (`frobSq_localAct`, `norm_det_localAct`).
* `sharp_iff_localAct_bell` : **every** normalized sharp maximizer lies in the local-unitary
  orbit of `bell = diag(1/√2, 1/√2)`, and conversely every point of that orbit is a sharp
  maximizer.
* `sharp_iff_exists_left`, `sharp_iff_exists_right` : one-sided transitivity — either factor of
  the local group already acts transitively on sharp maximizers, because `bell` is a scalar
  matrix; `exists_lact_of_sharp_sharp` phrases this as transitivity on the orbit.
* `stabilizer_bell` : the stabilizer of `bell` is `{(U, U̅)}`, i.e. `U ⊗ V` fixes the Bell state
  iff `V` is the entrywise conjugate of `U` (`V = Uᴴᵀ`).
* `concurrence_eq_zero_iff_isProduct` and `sharp_not_isProduct` : the opposite extreme of the
  scale, and the fact that the two extremes are disjoint.
* `flat_sharp_iff`, `card_sharp_signMats` : the *flat* sharp maximizers (all amplitudes of
  modulus `1/2`) are exactly the images of `(1/2) F₂` under diagonal unitaries — the order-two
  case of the classification of complex Hadamard matrices — and exactly `8` of the `16` real
  sign patterns are sharp.
* `sharpMaximizer_bellBasis`, `hsInner_bellBasis`, `bellBasis_expansion` : the Pauli orbit of
  `bell` is an orthonormal basis of the state space consisting of sharp maximizers.
* `concurrence_sq_eq_two_mul_linearEntropy`, `sharp_iff_purity`, `half_le_purity` : the
  concurrence is twice the linear entropy of the marginal, and sharp maximizers are exactly the
  normalized states of minimal purity `1/2`.
* `marginal_quadratic`, `sharp_iff_schmidt_eq`, `isProduct_iff_schmidtLo_eq_zero` : the Schmidt
  spectrum `(1 ± √(1 - C²))/2` of the marginal, degenerate exactly at the maximizers and
  containing `0` exactly at the product states.
* `frobSq_marginal_eq`, `frobSq_marginal_le_deficit` : a quantitative form of the row
  classification — the squared Frobenius distance of the marginal from `(1/2)·I` is exactly
  `(1 - C²)/2`, hence at most the concurrence deficit `1 - C`.
-/

open Matrix Finset
open scoped ComplexConjugate

noncomputable section

namespace LocalUnitaryNormalForm

/-- Amplitude matrix of a two-qubit pure state. -/
abbrev Amp := Matrix (Fin 2) (Fin 2) ℂ

/-- The unitary group `U(2)`, as a submonoid of `2 × 2` complex matrices. -/
abbrev U2 : Submonoid Amp := Matrix.unitaryGroup (Fin 2) ℂ

/-- Squared Frobenius norm (total probability) of an amplitude matrix. -/
def frobSq (M : Amp) : ℝ := ∑ i, ∑ j, Complex.normSq (M i j)

/-- A state is normalized when its total probability is one. -/
def Normalized (M : Amp) : Prop := frobSq M = 1

/-- Wootters' concurrence of a two-qubit pure state. -/
def concurrence (M : Amp) : ℝ := 2 * ‖M.det‖

/-- A *sharp maximizer* is a normalized state of maximal concurrence. -/
def SharpMaximizer (M : Amp) : Prop := Normalized M ∧ concurrence M = 1

/-- The canonical maximally entangled state `diag(1/√2, 1/√2)` (the Bell state `Φ⁺`). -/
def bell : Amp := Matrix.diagonal fun _ => ((Real.sqrt 2)⁻¹ : ℝ)

/-- Left action of `U(2)`: a unitary applied to the first qubit. -/
def lact (U : Amp) (M : Amp) : Amp := U * M

/-- Right action of `U(2)`: a unitary applied to the second qubit.  On amplitude matrices
`1 ⊗ V` acts through the transpose of `V`. -/
def ract (V : Amp) (M : Amp) : Amp := M * Vᵀ

/-- The two-sided local-unitary action of `U ⊗ V` on amplitude matrices. -/
def localAct (U V : Amp) (M : Amp) : Amp := U * M * Vᵀ

/-! ## Algebra of the two actions -/

theorem localAct_eq (U V M : Amp) : localAct U V M = lact U (ract V M) := by
  simp [localAct, lact, ract, Matrix.mul_assoc]

theorem localAct_one (M : Amp) : localAct 1 1 M = M := by
  simp [localAct]

theorem lact_mul (U₁ U₂ M : Amp) : lact (U₁ * U₂) M = lact U₁ (lact U₂ M) := by
  simp [lact, Matrix.mul_assoc]

theorem ract_mul (V₁ V₂ M : Amp) : ract (V₁ * V₂) M = ract V₁ (ract V₂ M) := by
  simp [ract, Matrix.transpose_mul, Matrix.mul_assoc]

theorem localAct_mul (U₁ U₂ V₁ V₂ M : Amp) :
    localAct (U₁ * U₂) (V₁ * V₂) M = localAct U₁ V₁ (localAct U₂ V₂ M) := by
  simp [localAct, Matrix.transpose_mul, Matrix.mul_assoc]

/-! ## Elementary facts about `U(2)` -/

theorem transpose_mem_unitaryGroup {V : Amp} (hV : V ∈ U2) : Vᵀ ∈ U2 := by
  rw [Matrix.mem_unitaryGroup_iff]
  have h : Vᴴ * V = 1 := by
    have := hV.1
    rwa [Matrix.star_eq_conjTranspose] at this
  calc Vᵀ * star (Vᵀ) = Vᵀ * (Vᴴ)ᵀ := by rw [Matrix.star_eq_conjTranspose]; rfl
    _ = (Vᴴ * V)ᵀ := by rw [Matrix.transpose_mul]
    _ = 1 := by rw [h, Matrix.transpose_one]

theorem conjTranspose_mem_unitaryGroup {V : Amp} (hV : V ∈ U2) : Vᴴ ∈ U2 := by
  have := Unitary.star_mem hV
  rwa [Matrix.star_eq_conjTranspose] at this

theorem norm_det_of_mem_unitaryGroup {U : Amp} (hU : U ∈ U2) : ‖U.det‖ = 1 := by
  have h : U.det * star U.det = 1 := (Matrix.det_of_mem_unitary hU).2
  have h2 : ‖U.det‖ * ‖U.det‖ = 1 := by
    have := congrArg norm h
    simpa [norm_mul, norm_star] using this
  nlinarith [norm_nonneg U.det]

/-! ## The Lagrange (Cauchy–Binet) identity in dimension two -/

/-- Lagrange's identity: for `u = (a,b)` and `v = (c,d)` in `ℂ²`,
`|⟨u,v⟩|² + |det [u;v]|² = ‖u‖² ‖v‖²`. -/
theorem lagrange_two (a b c d : ℂ) :
    Complex.normSq (a * conj c + b * conj d) + Complex.normSq (a * d - b * c)
      = (Complex.normSq a + Complex.normSq b) * (Complex.normSq c + Complex.normSq d) := by
  simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re, Complex.mul_im,
    Complex.sub_re, Complex.sub_im, Complex.conj_re, Complex.conj_im]
  ring

/-! ## Rows, the Frobenius norm and the Gram relation -/

/-- Squared length of the first row. -/
def row0Sq (M : Amp) : ℝ := Complex.normSq (M 0 0) + Complex.normSq (M 0 1)

/-- Squared length of the second row. -/
def row1Sq (M : Amp) : ℝ := Complex.normSq (M 1 0) + Complex.normSq (M 1 1)

/-- Hermitian inner product of the two rows. -/
def rowInner (M : Amp) : ℂ := M 0 0 * conj (M 1 0) + M 0 1 * conj (M 1 1)

theorem frobSq_eq_rows (M : Amp) : frobSq M = row0Sq M + row1Sq M := by
  simp [frobSq, row0Sq, row1Sq, Fin.sum_univ_two]

theorem row0Sq_nonneg (M : Amp) : 0 ≤ row0Sq M := by
  have h1 := Complex.normSq_nonneg (M 0 0)
  have h2 := Complex.normSq_nonneg (M 0 1)
  simp only [row0Sq]; linarith

theorem row1Sq_nonneg (M : Amp) : 0 ≤ row1Sq M := by
  have h1 := Complex.normSq_nonneg (M 1 0)
  have h2 := Complex.normSq_nonneg (M 1 1)
  simp only [row1Sq]; linarith

theorem frobSq_nonneg (M : Amp) : 0 ≤ frobSq M := by
  rw [frobSq_eq_rows]
  linarith [row0Sq_nonneg M, row1Sq_nonneg M]

/-- The Gram relation for a `2 × 2` matrix: `|⟨r₀, r₁⟩|² + |det M|² = ‖r₀‖² ‖r₁‖²`. -/
theorem gram_identity (M : Amp) :
    Complex.normSq (rowInner M) + Complex.normSq M.det = row0Sq M * row1Sq M := by
  rw [Matrix.det_fin_two]
  exact lagrange_two (M 0 0) (M 0 1) (M 1 0) (M 1 1)

/-! ## The sharp inequality `2 |det M| ≤ ‖M‖_F²` -/

theorem normSq_det_le (M : Amp) : Complex.normSq M.det ≤ row0Sq M * row1Sq M := by
  have h := gram_identity M
  have := Complex.normSq_nonneg (rowInner M)
  linarith

/-- Hadamard-type bound: twice the modulus of the determinant is at most the squared
Frobenius norm.  Equality is the sharp-maximizer condition analysed below. -/
theorem two_mul_norm_det_le_frobSq (M : Amp) : 2 * ‖M.det‖ ≤ frobSq M := by
  have hg := gram_identity M
  have hi := Complex.normSq_nonneg (rowInner M)
  have hn : ‖M.det‖ ^ 2 = Complex.normSq M.det := (Complex.normSq_eq_norm_sq _).symm
  have h0 := row0Sq_nonneg M
  have h1 := row1Sq_nonneg M
  have hd : (0:ℝ) ≤ ‖M.det‖ := norm_nonneg _
  rw [frobSq_eq_rows]
  nlinarith [sq_nonneg (row0Sq M - row1Sq M), sq_nonneg (row0Sq M + row1Sq M - 2 * ‖M.det‖)]

/-- On normalized states the concurrence never exceeds one. -/
theorem concurrence_le_one {M : Amp} (hM : Normalized M) : concurrence M ≤ 1 := by
  have h := two_mul_norm_det_le_frobSq M
  rw [Normalized] at hM
  simp only [concurrence]
  linarith [hM ▸ h]

/-! ## Row classification of the sharp maximizers -/

/-- **Row classification.** In a normalized sharp maximizer both rows have squared length
`1/2` and they are orthogonal for the Hermitian inner product. -/
theorem row_sq_of_sharp {M : Amp} (h : SharpMaximizer M) :
    row0Sq M = 1/2 ∧ row1Sq M = 1/2 ∧ rowInner M = 0 := by
  obtain ⟨hn, hc⟩ := h
  rw [Normalized, frobSq_eq_rows] at hn
  have hd : ‖M.det‖ = 1/2 := by simp only [concurrence] at hc; linarith
  have hdet : Complex.normSq M.det = 1/4 := by
    rw [Complex.normSq_eq_norm_sq, hd]; norm_num
  have hg := gram_identity M
  have hi := Complex.normSq_nonneg (rowInner M)
  refine ⟨by nlinarith [sq_nonneg (row0Sq M - row1Sq M)],
    by nlinarith [sq_nonneg (row0Sq M - row1Sq M)], ?_⟩
  exact Complex.normSq_eq_zero.mp (by nlinarith [sq_nonneg (row0Sq M - row1Sq M)])

/-- The reduced density matrix of a sharp maximizer is maximally mixed. -/
theorem rowGram_of_sharp {M : Amp} (h : SharpMaximizer M) :
    M * Mᴴ = (1/2 : ℂ) • (1 : Amp) := by
  obtain ⟨h0, h1, hi⟩ := row_sq_of_sharp h
  have hi' : M 1 0 * conj (M 0 0) + M 1 1 * conj (M 0 1) = 0 := by
    have := congrArg (starRingEnd ℂ) hi
    simpa [rowInner, map_add, map_mul, mul_comm] using this
  simp only [rowInner] at hi
  simp only [row0Sq] at h0
  simp only [row1Sq] at h1
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply]
  · rw [Complex.mul_conj, Complex.mul_conj, ← Complex.ofReal_add, h0]
    norm_num
  · simpa [mul_comm] using hi
  · simpa [mul_comm] using hi'
  · rw [Complex.mul_conj, Complex.mul_conj, ← Complex.ofReal_add, h1]
    norm_num

/-- Building a unitary out of the orthonormal basis furnished by the rows: for a sharp
maximizer `√2 • M` is unitary. -/
theorem sqrtTwo_smul_mem_unitaryGroup {M : Amp} (hG : M * Mᴴ = (1/2 : ℂ) • (1 : Amp)) :
    ((Real.sqrt 2 : ℝ) : ℂ) • M ∈ U2 := by
  have hcc : ((Real.sqrt 2 : ℝ) : ℂ) * ((Real.sqrt 2 : ℝ) : ℂ) = 2 := by
    rw [← Complex.ofReal_mul, Real.mul_self_sqrt (by norm_num : (0:ℝ) ≤ 2)]
    norm_num
  rw [Matrix.mem_unitaryGroup_iff, Matrix.star_eq_conjTranspose, Matrix.conjTranspose_smul,
    Matrix.smul_mul, Matrix.mul_smul, hG, smul_smul, smul_smul]
  rw [show (star ((Real.sqrt 2 : ℝ) : ℂ)) = ((Real.sqrt 2 : ℝ) : ℂ) from Complex.conj_ofReal _,
    hcc]
  norm_num

/-! ## Sharpness ⟺ maximally mixed marginal -/

theorem frobSq_eq_trace (M : Amp) : frobSq M = (M * Mᴴ).trace.re := by
  simp [frobSq, Matrix.trace, Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply,
    Complex.add_re, Complex.mul_re, Complex.normSq_apply]

theorem sharp_of_rowGram {M : Amp} (hG : M * Mᴴ = (1/2 : ℂ) • (1 : Amp)) : SharpMaximizer M := by
  constructor
  · rw [Normalized, frobSq_eq_trace, hG]
    simp
  · have h := congrArg Matrix.det hG
    rw [Matrix.det_mul, Matrix.det_conjTranspose] at h
    have h' : M.det * conj M.det = Matrix.det ((1/2 : ℂ) • (1 : Amp)) := h
    rw [Complex.mul_conj, show Matrix.det ((1/2 : ℂ) • (1 : Amp)) = 1/4 by simp; norm_num] at h'
    have h2 : ((Complex.normSq M.det : ℝ) : ℂ) = ((1/4 : ℝ) : ℂ) := by rw [h']; norm_num
    have h3 : Complex.normSq M.det = 1/4 := by exact_mod_cast h2
    have h4 : ‖M.det‖ ^ 2 = 1/4 := by rw [← Complex.normSq_eq_norm_sq]; exact h3
    have h5 : ‖M.det‖ = 1/2 := by nlinarith [norm_nonneg M.det]
    simp [concurrence, h5]

/-- A two-qubit state maximizes the concurrence iff its reduced density matrix is maximally
mixed. -/
theorem sharp_iff_rowGram (M : Amp) : SharpMaximizer M ↔ M * Mᴴ = (1/2 : ℂ) • (1 : Amp) :=
  ⟨rowGram_of_sharp, sharp_of_rowGram⟩

/-! ## The Bell state -/

theorem bell_eq_smul : bell = (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) • (1 : Amp) := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [bell]

theorem sharpMaximizer_bell : SharpMaximizer bell := by
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  have hne : Real.sqrt 2 ≠ 0 := by positivity
  constructor
  · simp only [Normalized, frobSq, bell_eq_smul, Fin.sum_univ_two]
    simp [Complex.normSq_apply]
    field_simp
    nlinarith [hs]
  · simp only [concurrence, bell_eq_smul, Matrix.det_fin_two]
    simp
    rw [abs_of_nonneg (Real.sqrt_nonneg 2)]
    field_simp
    nlinarith [hs]

/-! ## Invariance of the invariants under the local action -/

theorem frobSq_localAct {U V : Amp} (hU : U ∈ U2) (hV : V ∈ U2) (M : Amp) :
    frobSq (localAct U V M) = frobSq M := by
  have hUU : Uᴴ * U = 1 := by
    have := hU.1; rwa [Matrix.star_eq_conjTranspose] at this
  have hVV : Vᵀ * (Vᵀ)ᴴ = 1 := by
    have := (transpose_mem_unitaryGroup hV).2
    rwa [Matrix.star_eq_conjTranspose] at this
  rw [frobSq_eq_trace, frobSq_eq_trace]
  congr 1
  have h1 : (localAct U V M) * (localAct U V M)ᴴ = U * (M * Mᴴ) * Uᴴ := by
    simp only [localAct, Matrix.conjTranspose_mul, Matrix.mul_assoc]
    rw [← Matrix.mul_assoc (Vᵀ) ((Vᵀ)ᴴ), hVV, Matrix.one_mul]
  rw [h1, Matrix.trace_mul_cycle, ← Matrix.mul_assoc, hUU, Matrix.one_mul]

theorem det_localAct (U V M : Amp) : (localAct U V M).det = U.det * M.det * V.det := by
  simp [localAct, Matrix.det_mul, Matrix.det_transpose]

theorem norm_det_localAct {U V : Amp} (hU : U ∈ U2) (hV : V ∈ U2) (M : Amp) :
    ‖(localAct U V M).det‖ = ‖M.det‖ := by
  rw [det_localAct]
  simp [norm_det_of_mem_unitaryGroup hU, norm_det_of_mem_unitaryGroup hV]

theorem concurrence_localAct {U V : Amp} (hU : U ∈ U2) (hV : V ∈ U2) (M : Amp) :
    concurrence (localAct U V M) = concurrence M := by
  simp [concurrence, norm_det_localAct hU hV]

theorem sharpMaximizer_localAct {U V : Amp} (hU : U ∈ U2) (hV : V ∈ U2) {M : Amp}
    (h : SharpMaximizer M) : SharpMaximizer (localAct U V M) :=
  ⟨by simpa [Normalized] using (frobSq_localAct hU hV M).trans h.1,
   by rw [concurrence_localAct hU hV]; exact h.2⟩

/-! ## The normal form theorem -/

theorem eq_lact_bell_of_sharp {M : Amp} (h : SharpMaximizer M) : ∃ U ∈ U2, M = lact U bell := by
  refine ⟨((Real.sqrt 2 : ℝ) : ℂ) • M, sqrtTwo_smul_mem_unitaryGroup (rowGram_of_sharp h), ?_⟩
  have hs : ((Real.sqrt 2 : ℝ) : ℂ) * (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) = 1 := by
    rw [← Complex.ofReal_mul, mul_inv_cancel₀ (by positivity : (Real.sqrt 2) ≠ 0)]
    norm_num
  rw [lact, bell_eq_smul, Matrix.smul_mul, Matrix.mul_smul, smul_smul, Matrix.mul_one, hs, one_smul]

/-- **Local-unitary normal form.** A two-qubit state is a normalized sharp maximizer of the
concurrence iff it lies in the local-unitary orbit of `bell = diag(1/√2, 1/√2)`. -/
theorem sharp_iff_localAct_bell (M : Amp) :
    SharpMaximizer M ↔ ∃ U ∈ U2, ∃ V ∈ U2, M = localAct U V bell := by
  constructor
  · intro h
    obtain ⟨U, hU, hM⟩ := eq_lact_bell_of_sharp h
    exact ⟨U, hU, 1, Submonoid.one_mem _, by simpa [localAct, lact] using hM⟩
  · rintro ⟨U, hU, V, hV, rfl⟩
    exact sharpMaximizer_localAct hU hV sharpMaximizer_bell

/-- One-sided transitivity: the left factor alone already sweeps out all sharp maximizers,
because `bell` is a scalar matrix. -/
theorem sharp_iff_exists_left (M : Amp) : SharpMaximizer M ↔ ∃ U ∈ U2, M = lact U bell := by
  constructor
  · exact eq_lact_bell_of_sharp
  · rintro ⟨U, hU, rfl⟩
    have h : lact U bell = localAct U 1 bell := by simp [lact, localAct]
    rw [h]
    exact sharpMaximizer_localAct hU (Submonoid.one_mem _) sharpMaximizer_bell

/-- One-sided transitivity for the right factor. -/
theorem sharp_iff_exists_right (M : Amp) : SharpMaximizer M ↔ ∃ V ∈ U2, M = ract V bell := by
  constructor
  · intro h
    obtain ⟨U, hU, hM⟩ := eq_lact_bell_of_sharp h
    refine ⟨Uᵀ, transpose_mem_unitaryGroup hU, ?_⟩
    have hcomm : bell * U = U * bell := by
      rw [bell_eq_smul, Matrix.mul_smul, Matrix.smul_mul, Matrix.mul_one, Matrix.one_mul]
    rw [ract, Matrix.transpose_transpose, hcomm]
    exact hM
  · rintro ⟨V, hV, rfl⟩
    have h : ract V bell = localAct 1 V bell := by simp [ract, localAct]
    rw [h]
    exact sharpMaximizer_localAct (Submonoid.one_mem _) hV sharpMaximizer_bell

/-- The left `U(2)`-action is transitive on sharp maximizers. -/
theorem exists_lact_of_sharp_sharp {M N : Amp} (hM : SharpMaximizer M) (hN : SharpMaximizer N) :
    ∃ W ∈ U2, N = lact W M := by
  obtain ⟨A, hA, hMA⟩ := eq_lact_bell_of_sharp hM
  obtain ⟨B, hB, hNB⟩ := eq_lact_bell_of_sharp hN
  refine ⟨B * Aᴴ, Submonoid.mul_mem _ hB (conjTranspose_mem_unitaryGroup hA), ?_⟩
  have hAA : Aᴴ * A = 1 := by
    have := hA.1; rwa [Matrix.star_eq_conjTranspose] at this
  rw [hNB, hMA, lact, lact, lact]
  calc B * bell = B * (Aᴴ * A) * bell := by rw [hAA, Matrix.mul_one]
    _ = B * Aᴴ * (A * bell) := by simp [Matrix.mul_assoc]

/-- The stabilizer of the Bell state: `U ⊗ V` fixes `bell` iff `V` is the entrywise
conjugate of `U`, i.e. `V = Uᴴᵀ`. -/
theorem stabilizer_bell {U V : Amp} (hU : U ∈ U2) : localAct U V bell = bell ↔ V = Uᴴᵀ := by
  have hne : (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) ≠ 0 := by
    simp only [ne_eq, Complex.ofReal_eq_zero, inv_eq_zero]
    positivity
  have hbell : localAct U V bell = (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) • (U * Vᵀ) := by
    rw [localAct, bell_eq_smul, Matrix.mul_smul, Matrix.smul_mul, Matrix.mul_one]
  constructor
  · intro h
    rw [hbell, bell_eq_smul] at h
    have h1 : U * Vᵀ = 1 := smul_right_injective Amp hne h
    have hUU : Uᴴ * U = 1 := by
      have := hU.1; rwa [Matrix.star_eq_conjTranspose] at this
    have hVt : Vᵀ = Uᴴ := by
      calc Vᵀ = 1 * Vᵀ := by rw [Matrix.one_mul]
        _ = Uᴴ * (U * Vᵀ) := by rw [← Matrix.mul_assoc, hUU]
        _ = Uᴴ := by rw [h1, Matrix.mul_one]
    rw [← Matrix.transpose_transpose V, hVt]
  · rintro rfl
    have hUU : U * Uᴴ = 1 := by
      have := hU.2; rwa [Matrix.star_eq_conjTranspose] at this
    rw [hbell, Matrix.transpose_transpose, hUU, bell_eq_smul]

/-! ## The opposite extreme: product states -/

/-- A state is a product state when its amplitude matrix is an outer product. -/
def IsProduct (M : Amp) : Prop := ∃ u w : Fin 2 → ℂ, ∀ i j, M i j = u i * w j

/-- Vanishing concurrence characterizes product (unentangled) states. -/
theorem concurrence_eq_zero_iff_isProduct (M : Amp) : concurrence M = 0 ↔ IsProduct M := by
  constructor
  · intro h
    have hdet : M.det = 0 := by
      have : ‖M.det‖ = 0 := by simp only [concurrence] at h; linarith
      exact norm_eq_zero.mp this
    rw [Matrix.det_fin_two] at hdet
    by_cases h00 : M 0 0 = 0
    · by_cases h01 : M 0 1 = 0
      · refine ⟨![0, 1], ![M 1 0, M 1 1], ?_⟩
        intro i j
        fin_cases i <;> fin_cases j <;> simp [h00, h01]
      · have h10 : M 1 0 = 0 := by
          have hz : M 0 1 * M 1 0 = 0 := by rw [h00] at hdet; linear_combination -hdet
          rcases mul_eq_zero.mp hz with hz' | hz'
          · exact absurd hz' h01
          · exact hz'
        refine ⟨![1, M 1 1 / M 0 1], ![M 0 0, M 0 1], ?_⟩
        intro i j
        fin_cases i <;> fin_cases j <;> simp [h00, h10]
        field_simp
    · refine ⟨![1, M 1 0 / M 0 0], ![M 0 0, M 0 1], ?_⟩
      intro i j
      fin_cases i <;> fin_cases j <;> simp
      · field_simp
      · field_simp
        linear_combination hdet
  · rintro ⟨u, w, hM⟩
    have hd : M.det = 0 := by
      rw [Matrix.det_fin_two, hM, hM, hM, hM]; ring
    simp [concurrence, hd]

/-- Maximal and vanishing entanglement are mutually exclusive: a sharp maximizer is never
a product state. -/
theorem sharp_not_isProduct {M : Amp} (h : SharpMaximizer M) : ¬ IsProduct M := by
  intro hp
  have h0 : concurrence M = 0 := (concurrence_eq_zero_iff_isProduct M).mpr hp
  rw [h.2] at h0
  norm_num at h0

/-! ## Flat maximizers and complex Hadamard matrices of order two

A sharp maximizer is *flat* when all four amplitudes have the same modulus `1/2`.  Rescaled by
`2` such a matrix is precisely a complex Hadamard matrix of order two, and the classical fact
that all of them are equivalent to the Fourier matrix `F₂ = !![1, 1; 1, -1]` becomes here the
statement that the flat sharp maximizers form a single orbit of the *diagonal* subgroup of
`U(2) × U(2)`. -/

/-- The order-two Fourier (Hadamard) matrix. -/
def fourier2 : Amp := !![1, 1; 1, -1]

/-- A state is flat when all four amplitudes have the same modulus. -/
def IsFlat (M : Amp) : Prop := ∀ i j, ‖M i j‖ = 1/2

theorem diagonal_mem_unitaryGroup {d : Fin 2 → ℂ} (hd : ∀ i, ‖d i‖ = 1) :
    Matrix.diagonal d ∈ U2 := by
  rw [Matrix.mem_unitaryGroup_iff, Matrix.star_eq_conjTranspose, Matrix.diagonal_conjTranspose,
    Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
  congr 1
  funext i
  have h1 : ‖d i‖ ^ 2 = 1 := by rw [hd i]; norm_num
  have h2 : Complex.normSq (d i) = 1 := by rw [Complex.normSq_eq_norm_sq]; exact h1
  calc d i * star (d i) = ((Complex.normSq (d i) : ℝ) : ℂ) := by rw [← Complex.mul_conj]; rfl
    _ = 1 := by rw [h2]; norm_num

theorem rowGram_fourier2 :
    ((1/2 : ℂ) • fourier2) * ((1/2 : ℂ) • fourier2)ᴴ = (1/2 : ℂ) • (1 : Amp) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [fourier2, Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply] <;>
    norm_num [Complex.ext_iff]

theorem sharpMaximizer_fourier2 : SharpMaximizer ((1/2 : ℂ) • fourier2) :=
  sharp_of_rowGram rowGram_fourier2

theorem isFlat_fourier2 : IsFlat ((1/2 : ℂ) • fourier2) := by
  intro i j
  fin_cases i <;> fin_cases j <;> simp [fourier2]

/-- **Dephasing of a flat maximizer.**  Every flat sharp maximizer is obtained from
`(1/2) F₂` by diagonal unitaries on the left and on the right; equivalently, every complex
Hadamard matrix of order two is equivalent to the Fourier matrix. -/
theorem flat_sharp_dephase {M : Amp} (hs : SharpMaximizer M) (hf : IsFlat M) :
    ∃ d e : Fin 2 → ℂ, (∀ i, ‖d i‖ = 1) ∧ (∀ j, ‖e j‖ = 1) ∧
      M = localAct (Matrix.diagonal d) (Matrix.diagonal e) ((1/2 : ℂ) • fourier2) := by
  obtain ⟨-, -, hi⟩ := row_sq_of_sharp hs
  simp only [rowInner] at hi
  have hne : ∀ i j, M i j ≠ 0 := by
    intro i j h
    have hij := hf i j
    rw [h] at hij
    norm_num at hij
  have h00 : M 0 0 ≠ 0 := hne 0 0
  have hconj : ∀ i j, M i j * conj (M i j) = (1/4 : ℂ) := by
    intro i j
    rw [Complex.mul_conj]
    have h4 : Complex.normSq (M i j) = 1/4 := by
      rw [Complex.normSq_eq_norm_sq, hf i j]; norm_num
    rw [h4]; norm_num
  have hmul : M 0 0 * M 1 1 + M 0 1 * M 1 0 = 0 := by
    linear_combination (4 * M 1 0 * M 1 1) * hi - (4 * M 0 0 * M 1 1) * hconj 1 0
      - (4 * M 0 1 * M 1 0) * hconj 1 1
  refine ⟨![1, 2 * M 1 0 / (2 * M 0 0)], ![2 * M 0 0, 2 * M 0 1], ?_, ?_, ?_⟩
  · intro i
    fin_cases i
    · norm_num
    · simp [hf 1 0, hf 0 0]
  · intro j
    fin_cases j
    · simp [hf 0 0]
    · simp [hf 0 1]
  · ext i j
    fin_cases i <;> fin_cases j <;>
      simp [localAct, fourier2, Matrix.mul_apply, Matrix.diagonal] <;>
      field_simp
    linear_combination hmul

theorem sharpMaximizer_diagonal_fourier2 {d e : Fin 2 → ℂ} (hd : ∀ i, ‖d i‖ = 1)
    (he : ∀ j, ‖e j‖ = 1) :
    SharpMaximizer (localAct (Matrix.diagonal d) (Matrix.diagonal e) ((1/2 : ℂ) • fourier2)) :=
  sharpMaximizer_localAct (diagonal_mem_unitaryGroup hd) (diagonal_mem_unitaryGroup he)
    sharpMaximizer_fourier2

theorem isFlat_diagonal_fourier2 {d e : Fin 2 → ℂ} (hd : ∀ i, ‖d i‖ = 1) (he : ∀ j, ‖e j‖ = 1) :
    IsFlat (localAct (Matrix.diagonal d) (Matrix.diagonal e) ((1/2 : ℂ) • fourier2)) := by
  intro i j
  fin_cases i <;> fin_cases j <;>
    simp [localAct, fourier2, Matrix.mul_apply, Matrix.diagonal, hd, he]

/-- The flat sharp maximizers form exactly one orbit of the diagonal subgroup of the local
unitary group acting on `(1/2) F₂`. -/
theorem flat_sharp_iff (M : Amp) :
    (SharpMaximizer M ∧ IsFlat M) ↔
      ∃ d e : Fin 2 → ℂ, (∀ i, ‖d i‖ = 1) ∧ (∀ j, ‖e j‖ = 1) ∧
        M = localAct (Matrix.diagonal d) (Matrix.diagonal e) ((1/2 : ℂ) • fourier2) := by
  constructor
  · rintro ⟨hs, hf⟩
    exact flat_sharp_dephase hs hf
  · rintro ⟨d, e, hd, he, rfl⟩
    exact ⟨sharpMaximizer_diagonal_fourier2 hd he, isFlat_diagonal_fourier2 hd he⟩

/-! ### The real flat maximizers: a finite count -/

/-- The two possible real amplitudes of a flat normalized state. -/
def sgn (b : Bool) : ℂ := if b then 1/2 else -1/2

/-- The real flat state with the prescribed sign pattern. -/
def signMat (a b c d : Bool) : Amp := !![sgn a, sgn b; sgn c, sgn d]

/-- A real flat state is a sharp maximizer exactly when the two diagonal agreements
disagree — the order-two Hadamard condition on sign patterns. -/
theorem signMat_sharp_iff (a b c d : Bool) :
    SharpMaximizer (signMat a b c d) ↔ ((a == d) != (b == c)) := by
  cases a <;> cases b <;> cases c <;> cases d <;>
    simp [SharpMaximizer, Normalized, frobSq, concurrence, signMat, sgn, Fin.sum_univ_two,
      Matrix.det_fin_two, Complex.normSq_apply] <;>
    norm_num [Complex.ext_iff]

open Classical in
/-- Exactly `8` of the `16` real sign patterns are sharp maximizers: the `2 × 2` real Hadamard
matrices, i.e. a single orbit of the sign group `{±1}³` through `F₂`. -/
theorem card_sharp_signMats :
    (Finset.univ.filter fun p : Bool × Bool × Bool × Bool =>
        SharpMaximizer (signMat p.1 p.2.1 p.2.2.1 p.2.2.2)).card = 8 := by
  have h : (Finset.univ.filter fun p : Bool × Bool × Bool × Bool =>
        SharpMaximizer (signMat p.1 p.2.1 p.2.2.1 p.2.2.2))
      = (Finset.univ.filter fun p : Bool × Bool × Bool × Bool =>
        ((p.1 == p.2.2.2) != (p.2.1 == p.2.2.1)) = true) := by
    apply Finset.filter_congr
    intro p _
    simpa using signMat_sharp_iff p.1 p.2.1 p.2.2.1 p.2.2.2
  rw [h]
  rfl

/-! ## The Bell basis: an orthonormal basis made of maximal maximizers

The local-unitary orbit of `bell` is large enough to contain an orthonormal basis of the whole
four-dimensional state space: applying the three Pauli unitaries on the first qubit produces the
Bell basis.  This is the structural fact underlying dense coding and teleportation. -/

/-- Hilbert–Schmidt inner product on amplitude matrices. -/
def hsInner (M N : Amp) : ℂ := ∑ i, ∑ j, conj (M i j) * N i j

/-- The Pauli matrix `σₓ`. -/
def pauliX : Amp := !![0, 1; 1, 0]

/-- The Pauli matrix `σ_y`. -/
def pauliY : Amp := !![0, -Complex.I; Complex.I, 0]

/-- The Pauli matrix `σ_z`. -/
def pauliZ : Amp := !![1, 0; 0, -1]

/-- The four Pauli matrices `1, σₓ, σ_y, σ_z`. -/
def pauliMat : Fin 4 → Amp := ![1, pauliX, pauliY, pauliZ]

/-- The Bell basis, obtained from `bell` by the Pauli unitaries on the first qubit. -/
def bellBasis (k : Fin 4) : Amp := lact (pauliMat k) bell

theorem hsInner_smul_left (c : ℂ) (P N : Amp) : hsInner (c • P) N = conj c * hsInner P N := by
  simp [hsInner, map_mul]
  ring_nf

theorem lact_bell (P : Amp) : lact P bell = (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) • P := by
  rw [lact, bell_eq_smul, Matrix.mul_smul, Matrix.mul_one]

theorem sqrtTwoInv_sq : (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) * (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) = 1/2 := by
  rw [← Complex.ofReal_mul]
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  have hne : Real.sqrt 2 ≠ 0 := by positivity
  rw [show (Real.sqrt 2)⁻¹ * (Real.sqrt 2)⁻¹ = 1/2 by field_simp; nlinarith [hs]]
  norm_num

theorem pauliMat_mem_unitaryGroup (k : Fin 4) : pauliMat k ∈ U2 := by
  fin_cases k
  · exact Submonoid.one_mem _
  all_goals
    rw [Matrix.mem_unitaryGroup_iff, Matrix.star_eq_conjTranspose]
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [pauliMat, pauliX, pauliY, pauliZ, Matrix.mul_apply, Fin.sum_univ_two,
        Matrix.conjTranspose_apply]

/-- Every Bell-basis vector is a sharp maximizer. -/
theorem sharpMaximizer_bellBasis (k : Fin 4) : SharpMaximizer (bellBasis k) :=
  (sharp_iff_exists_left _).mpr ⟨pauliMat k, pauliMat_mem_unitaryGroup k, rfl⟩

/-- The Pauli matrices are orthogonal for the Hilbert–Schmidt inner product, each of squared
length `2`. -/
theorem hsInner_pauliMat (j k : Fin 4) :
    hsInner (pauliMat j) (pauliMat k) = if j = k then 2 else 0 := by
  fin_cases j <;> fin_cases k <;>
    simp [hsInner, pauliMat, pauliX, pauliY, pauliZ, Fin.sum_univ_two, Matrix.one_apply] <;>
    ring_nf

/-- The Bell basis is orthonormal. -/
theorem hsInner_bellBasis (j k : Fin 4) :
    hsInner (bellBasis j) (bellBasis k) = if j = k then 1 else 0 := by
  simp only [bellBasis, lact_bell, hsInner_smul_left, Complex.conj_ofReal]
  rw [show hsInner (pauliMat j) ((((Real.sqrt 2)⁻¹ : ℝ) : ℂ) • pauliMat k)
      = (((Real.sqrt 2)⁻¹ : ℝ) : ℂ) * hsInner (pauliMat j) (pauliMat k) by
    simp [hsInner]; ring_nf]
  rw [← mul_assoc, sqrtTwoInv_sq, hsInner_pauliMat]
  split <;> norm_num

/-- Pauli expansion of an arbitrary `2 × 2` matrix. -/
theorem pauli_expansion (M : Amp) :
    M = (1/2 : ℂ) • ∑ k, hsInner (pauliMat k) M • pauliMat k := by
  rw [Fin.sum_univ_four]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [hsInner, pauliMat, pauliX, pauliY, pauliZ, Fin.sum_univ_two, Matrix.one_apply] <;>
    ring_nf <;>
    simp [Complex.ext_iff] <;>
    and_intros <;>
    first
      | trivial
      | ring

/-- **Completeness of the Bell basis.**  Every two-qubit state is the Hilbert–Schmidt expansion
of its coefficients along the four maximally entangled Bell states. -/
theorem bellBasis_expansion (M : Amp) : M = ∑ k, hsInner (bellBasis k) M • bellBasis k := by
  have key : ∀ k, hsInner (bellBasis k) M • bellBasis k
      = (1/2 : ℂ) • (hsInner (pauliMat k) M • pauliMat k) := by
    intro k
    simp only [bellBasis, lact_bell, hsInner_smul_left, smul_smul, Complex.conj_ofReal]
    congr 1
    linear_combination (hsInner (pauliMat k) M) * sqrtTwoInv_sq
  rw [Finset.sum_congr rfl (fun k _ => key k), ← Finset.smul_sum]
  exact pauli_expansion M

/-! ## Entanglement versus mixedness: the linear-entropy identity

For a two-qubit pure state the reduced density matrix is `ρ = M Mᴴ`, and its purity
`tr ρ²` is a direct measure of how mixed the marginal is.  Cayley–Hamilton in dimension two
turns the concurrence into the linear entropy `1 - tr ρ²`; sharp maximizers are exactly the
normalized states of minimal purity `1/2`. -/

/-- Cayley–Hamilton in dimension two, in trace form. -/
theorem trace_sq_fin_two (A : Amp) : (A * A).trace = A.trace ^ 2 - 2 * A.det := by
  simp [Matrix.trace_fin_two, Matrix.det_fin_two, Matrix.mul_apply, Fin.sum_univ_two]
  ring

theorem det_mul_conjTranspose (M : Amp) : (M * Mᴴ).det = ((Complex.normSq M.det : ℝ) : ℂ) := by
  rw [Matrix.det_mul, Matrix.det_conjTranspose, ← Complex.mul_conj]
  rfl

theorem trace_mul_conjTranspose (M : Amp) : (M * Mᴴ).trace = ((frobSq M : ℝ) : ℂ) := by
  simp [Matrix.trace_fin_two, Matrix.mul_apply, Fin.sum_univ_two, frobSq, Complex.normSq_apply,
    Matrix.conjTranspose_apply, Complex.ext_iff]
  ring

/-- Purity `tr ρ²` of the reduced density matrix `ρ = M Mᴴ`. -/
def purity (M : Amp) : ℝ := ((M * Mᴴ) * (M * Mᴴ)).trace.re

theorem purity_eq (M : Amp) : purity M = (frobSq M) ^ 2 - 2 * Complex.normSq M.det := by
  have h2 : (M * Mᴴ * (M * Mᴴ)).trace
      = ((frobSq M ^ 2 - 2 * Complex.normSq M.det : ℝ) : ℂ) := by
    rw [trace_sq_fin_two, trace_mul_conjTranspose, det_mul_conjTranspose]
    push_cast
    ring
  simp only [purity, h2, Complex.ofReal_re]

/-- **Linear-entropy identity.**  On normalized states the squared concurrence equals twice the
linear entropy `1 - tr ρ²` of the reduced density matrix. -/
theorem concurrence_sq_eq_two_mul_linearEntropy {M : Amp} (h : Normalized M) :
    concurrence M ^ 2 = 2 * (1 - purity M) := by
  rw [purity_eq]
  rw [Normalized] at h
  rw [h]
  simp only [concurrence]
  rw [show (2 * ‖M.det‖) ^ 2 = 4 * ‖M.det‖ ^ 2 by ring, ← Complex.normSq_eq_norm_sq]
  ring

/-- Sharp maximizers are exactly the normalized states of minimal purity. -/
theorem sharp_iff_purity {M : Amp} (h : Normalized M) : SharpMaximizer M ↔ purity M = 1/2 := by
  have hc := concurrence_sq_eq_two_mul_linearEntropy h
  constructor
  · intro hs
    rw [hs.2] at hc
    linarith
  · intro hp
    refine ⟨h, ?_⟩
    rw [hp] at hc
    have h2 : 0 ≤ concurrence M := by
      simp only [concurrence]; positivity
    nlinarith

/-- The purity of the marginal of a normalized two-qubit state is at least `1/2`. -/
theorem half_le_purity {M : Amp} (h : Normalized M) : 1/2 ≤ purity M := by
  have hc := concurrence_sq_eq_two_mul_linearEntropy h
  have hle : concurrence M ≤ 1 := concurrence_le_one h
  have h0 : 0 ≤ concurrence M := by simp only [concurrence]; positivity
  nlinarith

/-! ## The Schmidt spectrum of a two-qubit state

Cayley–Hamilton in dimension two determines the spectrum of the marginal `ρ = M Mᴴ` from the
two invariants `tr ρ = ‖M‖_F²` and `det ρ = |det M|²`.  For a normalized state the two
*Schmidt coefficients* are therefore the explicit numbers `(1 ± √(1 - C²))/2`, and `ρ` is
annihilated by the corresponding quadratic.  Sharp maximizers are exactly the states whose
Schmidt coefficients coincide, product states exactly those with a vanishing one. -/

/-- Cayley–Hamilton for `2 × 2` matrices. -/
theorem cayleyHamilton_fin_two (A : Amp) : A * A - A.trace • A + A.det • (1 : Amp) = 0 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two, Matrix.trace_fin_two, Matrix.det_fin_two] <;>
    ring

/-- The larger Schmidt coefficient of a normalized two-qubit state. -/
def schmidtHi (M : Amp) : ℝ := (1 + Real.sqrt (1 - concurrence M ^ 2)) / 2

/-- The smaller Schmidt coefficient of a normalized two-qubit state. -/
def schmidtLo (M : Amp) : ℝ := (1 - Real.sqrt (1 - concurrence M ^ 2)) / 2

theorem concurrence_nonneg (M : Amp) : 0 ≤ concurrence M := by
  simp only [concurrence]; positivity

theorem schmidt_add (M : Amp) : schmidtHi M + schmidtLo M = 1 := by
  simp [schmidtHi, schmidtLo]; ring

theorem schmidt_mul {M : Amp} (hc : concurrence M ≤ 1) :
    schmidtHi M * schmidtLo M = Complex.normSq M.det := by
  have h0 := concurrence_nonneg M
  have hsq : Real.sqrt (1 - concurrence M ^ 2) ^ 2 = 1 - concurrence M ^ 2 :=
    Real.sq_sqrt (by nlinarith)
  have hn : Complex.normSq M.det = ‖M.det‖ ^ 2 := Complex.normSq_eq_norm_sq _
  simp only [schmidtHi, schmidtLo, concurrence] at *
  nlinarith [hsq]

theorem schmidt_bounds (M : Amp) :
    0 ≤ schmidtLo M ∧ schmidtLo M ≤ schmidtHi M ∧ schmidtHi M ≤ 1 := by
  have h0 := concurrence_nonneg M
  have hs : Real.sqrt (1 - concurrence M ^ 2) ≤ 1 := by
    have h := Real.sqrt_le_sqrt (show 1 - concurrence M ^ 2 ≤ 1 by nlinarith)
    simpa using h
  have hs0 : 0 ≤ Real.sqrt (1 - concurrence M ^ 2) := Real.sqrt_nonneg _
  refine ⟨by simp only [schmidtLo]; linarith, by simp only [schmidtLo, schmidtHi]; linarith,
    by simp only [schmidtHi]; linarith⟩

/-- **Schmidt spectrum.**  The marginal of a normalized state is annihilated by the quadratic
whose roots are the two Schmidt coefficients. -/
theorem marginal_quadratic {M : Amp} (h : Normalized M) (hc : concurrence M ≤ 1) :
    ((M * Mᴴ) - (schmidtHi M : ℂ) • (1 : Amp)) * ((M * Mᴴ) - (schmidtLo M : ℂ) • (1 : Amp))
      = 0 := by
  have hch := cayleyHamilton_fin_two (M * Mᴴ)
  rw [trace_mul_conjTranspose, det_mul_conjTranspose, (h : frobSq M = 1)] at hch
  have ha : schmidtHi M + schmidtLo M = 1 := schmidt_add M
  have hm : schmidtHi M * schmidtLo M = Complex.normSq M.det := schmidt_mul hc
  have hexp : ((M * Mᴴ) - (schmidtHi M : ℂ) • (1 : Amp))
        * ((M * Mᴴ) - (schmidtLo M : ℂ) • (1 : Amp))
      = (M * Mᴴ) * (M * Mᴴ) - ((schmidtHi M + schmidtLo M : ℝ) : ℂ) • (M * Mᴴ)
        + ((schmidtHi M * schmidtLo M : ℝ) : ℂ) • (1 : Amp) := by
    push_cast
    simp only [sub_mul, mul_sub, Matrix.smul_mul, Matrix.mul_smul, Matrix.mul_one, Matrix.one_mul,
      smul_smul, add_smul]
    module
  rw [hexp, ha, hm]
  push_cast at hch ⊢
  simpa using hch

/-- Sharp maximizers are exactly the normalized states with a degenerate Schmidt spectrum. -/
theorem sharp_iff_schmidt_eq {M : Amp} (h : Normalized M) :
    SharpMaximizer M ↔ schmidtHi M = schmidtLo M := by
  have h0 := concurrence_nonneg M
  have hc := concurrence_le_one h
  have hsq : Real.sqrt (1 - concurrence M ^ 2) ^ 2 = 1 - concurrence M ^ 2 :=
    Real.sq_sqrt (by nlinarith)
  have hs0 : 0 ≤ Real.sqrt (1 - concurrence M ^ 2) := Real.sqrt_nonneg _
  constructor
  · intro hs
    simp [schmidtHi, schmidtLo, hs.2]
  · intro heq
    refine ⟨h, ?_⟩
    simp only [schmidtHi, schmidtLo] at heq
    have hz : Real.sqrt (1 - concurrence M ^ 2) = 0 := by linarith
    rw [hz] at hsq
    nlinarith

/-- Product states are exactly the normalized states with a vanishing Schmidt coefficient. -/
theorem isProduct_iff_schmidtLo_eq_zero {M : Amp} (h : Normalized M) :
    IsProduct M ↔ schmidtLo M = 0 := by
  have h0 := concurrence_nonneg M
  have hc := concurrence_le_one h
  have hsq : Real.sqrt (1 - concurrence M ^ 2) ^ 2 = 1 - concurrence M ^ 2 :=
    Real.sq_sqrt (by nlinarith)
  have hs0 : 0 ≤ Real.sqrt (1 - concurrence M ^ 2) := Real.sqrt_nonneg _
  rw [← concurrence_eq_zero_iff_isProduct]
  constructor
  · intro hz
    rw [hz] at hsq
    have h1 : Real.sqrt (1 - (0:ℝ) ^ 2) = 1 := by norm_num
    simp only [schmidtLo, hz, h1]
    norm_num
  · intro hz
    simp only [schmidtLo] at hz
    have h1 : Real.sqrt (1 - concurrence M ^ 2) = 1 := by linarith
    rw [h1] at hsq
    nlinarith

/-! ## A quantitative row classification

The row classification is an equality statement; the computation behind it is in fact exact and
yields a *stability* statement: the squared Frobenius distance from the marginal to the
maximally mixed state is exactly `(1 - C²)/2`, hence at most the concurrence deficit `1 - C`.
So a state of nearly maximal concurrence has a nearly maximally mixed marginal. -/

theorem marginal_apply_00 (M : Amp) : (M * Mᴴ) 0 0 = ((row0Sq M : ℝ) : ℂ) := by
  simp [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, row0Sq, Complex.mul_conj]

theorem marginal_apply_11 (M : Amp) : (M * Mᴴ) 1 1 = ((row1Sq M : ℝ) : ℂ) := by
  simp [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, row1Sq, Complex.mul_conj]

theorem marginal_apply_01 (M : Amp) : (M * Mᴴ) 0 1 = rowInner M := by
  simp [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, rowInner]

theorem marginal_apply_10 (M : Amp) : (M * Mᴴ) 1 0 = conj (rowInner M) := by
  simp [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, rowInner, map_add, map_mul,
    mul_comm]

theorem frobSq_marginal_sub (M : Amp) :
    frobSq (M * Mᴴ - (1/2 : ℂ) • (1 : Amp))
      = (row0Sq M - 1/2) ^ 2 + (row1Sq M - 1/2) ^ 2 + 2 * Complex.normSq (rowInner M) := by
  simp only [frobSq, Fin.sum_univ_two, Matrix.sub_apply, Matrix.smul_apply, Matrix.one_apply,
    marginal_apply_00, marginal_apply_01, marginal_apply_10, marginal_apply_11]
  norm_num [Complex.normSq_apply]
  ring

/-- **Exact form of the row classification.**  For a normalized state the squared Frobenius
distance of the marginal from the maximally mixed state is `(1 - C²)/2`. -/
theorem frobSq_marginal_eq {M : Amp} (h : Normalized M) :
    frobSq (M * Mᴴ - (1/2 : ℂ) • (1 : Amp)) = (1 - concurrence M ^ 2) / 2 := by
  have hg := gram_identity M
  have hr : row0Sq M + row1Sq M = 1 := by rw [← frobSq_eq_rows]; exact h
  have hd : Complex.normSq M.det = ‖M.det‖ ^ 2 := Complex.normSq_eq_norm_sq _
  rw [frobSq_marginal_sub]
  simp only [concurrence]
  nlinarith [hg, hr, hd]

/-- **Stability.**  A concurrence deficit `ε` forces the marginal to be within `√ε` of the
maximally mixed state in Frobenius norm. -/
theorem frobSq_marginal_le_deficit {M : Amp} (h : Normalized M) :
    frobSq (M * Mᴴ - (1/2 : ℂ) • (1 : Amp)) ≤ 1 - concurrence M := by
  have he := frobSq_marginal_eq h
  have hc := concurrence_le_one h
  have h0 := concurrence_nonneg M
  rw [he]
  nlinarith

/-- The distance vanishes exactly at the sharp maximizers. -/
theorem frobSq_marginal_eq_zero_iff {M : Amp} (h : Normalized M) :
    frobSq (M * Mᴴ - (1/2 : ℂ) • (1 : Amp)) = 0 ↔ SharpMaximizer M := by
  have he := frobSq_marginal_eq h
  have hc := concurrence_le_one h
  have h0 := concurrence_nonneg M
  constructor
  · intro hz
    rw [hz] at he
    exact ⟨h, by nlinarith⟩
  · intro hs
    rw [he, hs.2]
    norm_num

end LocalUnitaryNormalForm

end