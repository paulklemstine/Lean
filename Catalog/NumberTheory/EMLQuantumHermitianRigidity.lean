import Mathlib

/-!
# Hermitian rigidity of the quantum EML logarithmic activation

This file is the fifth instalment of the *quantum EML scalar logarithm* thread
(`Catalog/NumberTheory/EMLQuantumScalarLog.lean`,
`Catalog/NumberTheory/EMLQuantumScalarLogSharp.lean`,
`Catalog/NumberTheory/EMLQuantumUnitaryExponential.lean`,
`Catalog/NumberTheory/EMLQuantumTaylorCertificates.lean`,
`Catalog/NumberTheory/EMLQuantumScalarLogRootIsolation.lean`).

The previous instalment proved *spectral* rigidity: a logarithmic activation
presented as `V · diag (log (1 + i d)) · V⋆` is unitary iff every `d i` equals
`± t*`, where `t*` is the unique positive solution of `‖log (1 + t i)‖ = 1`.
That statement is about a chosen spectral presentation.  Here the result is
promoted to a statement about an **arbitrary Hermitian matrix `H`**, using
Mathlib's spectral theorem, and its arithmetic consequences are extracted.

Because the catalog files compile independently of one another, the scalar
material is restated here in the shortest possible form: the root is isolated
only in `[1, √3]` (the closed-form values `arctan 1 = π/4` and
`arctan √3 = π/3` make this interval certifiable from `π > 3` and
`log 2 < 0.6931471808` alone).  The high-precision isolation lives in
`EMLQuantumScalarLogRootIsolation.lean` and is not needed for the rigidity
theorems below.

## Main results

* `QuantumEML.logActivation` : the logarithmic activation `log (I + i H)` of a
  Hermitian matrix, defined through Mathlib's spectral decomposition.
* `QuantumEML.logActivation_mem_unitary_iff` : **eigenvalue rigidity.**  The
  activation is unitary iff every eigenvalue of `H` equals `± t*`.
* `QuantumEML.logActivation_mem_unitary_iff_sq` : **matrix rigidity, presentation
  free.**  The activation is unitary iff `H² = t*² · I`.
* `QuantumEML.involution_of_logActivation_mem_unitary` and
  `QuantumEML.isIdempotentElem_projection` : in that case `t*⁻¹ · H` is a
  self-adjoint involution and `(1 + t*⁻¹ H)/2` is an orthogonal projection, so
  the admissible Hamiltonians form a union of Grassmannians.
* `QuantumEML.sum_eigenvalues_eq` , `QuantumEML.trace_eq` : **trace
  quantization.**  `tr H = t* · (2k − n)` where `k` is the number of `+t*`
  eigenvalues; the trace is confined to a one-dimensional lattice of `n + 1`
  admissible values.
* `QuantumEML.trace_ne_zero_of_odd_card` : an odd-dimensional Hamiltonian with
  unitary logarithmic activation has `‖tr H‖ ≥ 1` (`one_lt_abs_trace_of_odd_card`);
  in particular the activation is *never* traceless in odd dimension.
* `QuantumEML.det_sq_eq` , `QuantumEML.isUnit_det` , `QuantumEML.trace_mul_self_eq` :
  determinant, invertibility and Frobenius-norm quantization.
* `QuantumEML.one_lt_scalarLogRoot_sq` , `QuantumEML.scalarLogRoot_sq_lt_two` :
  the certified enclosure `1 < t*² < 2`, proved here from `π > 3.141592`,
  `log 2 > 0.6931471803` and one order-5 Taylor certificate for `arctan`.
* `QuantumEML.not_logActivation_mem_unitary_of_intCast` : **integrality
  obstruction.**  No Hermitian matrix with integer entries has a unitary
  logarithmic activation, because `H² = t*² I` would make `t*²` an integer
  strictly between `1` and `2`.
* `QuantumEML.exists_hermitian_logActivation_unitary_trace_of_le` : **sharpness.**
  Every lattice point `t* (2k − n)`, `0 ≤ k ≤ n`, is the trace of an actual
  Hermitian matrix with unitary logarithmic activation, so the rigidity theorems
  above are not vacuous and the trace spectrum is described exactly.
-/

noncomputable section

open Complex Real Set Matrix

namespace QuantumEML

/-! ## 1.  The scalar logarithmic norm (restated, minimal form) -/

/-- The scalar logarithmic norm along the vertical line through `1`. -/
def scalarLogNorm (t : ℝ) : ℝ := ‖Complex.log (1 + (t : ℂ) * I)‖

/-- Closed form of its square. -/
def scalarLogNormSq (t : ℝ) : ℝ := (Real.log (1 + t ^ 2) / 2) ^ 2 + (Real.arctan t) ^ 2

theorem arg_one_add_mul_I (t : ℝ) : (1 + (t : ℂ) * I).arg = Real.arctan t := by
  rw [Complex.arg, if_pos (by simp), Real.arctan_eq_arcsin]
  congr 1
  rw [Complex.norm_def]
  simp [Complex.normSq]
  ring_nf

theorem norm_one_add_mul_I (t : ℝ) : ‖1 + (t : ℂ) * I‖ = Real.sqrt (1 + t ^ 2) := by
  rw [Complex.norm_def]
  congr 1
  simp [Complex.normSq]
  ring

theorem scalarLogNorm_sq (t : ℝ) : scalarLogNorm t ^ 2 = scalarLogNormSq t := by
  have hre : (Complex.log (1 + (t : ℂ) * I)).re = Real.log (1 + t ^ 2) / 2 := by
    rw [Complex.log_re, norm_one_add_mul_I, Real.log_sqrt (by positivity)]
  have him : (Complex.log (1 + (t : ℂ) * I)).im = Real.arctan t := by
    rw [Complex.log_im, arg_one_add_mul_I]
  rw [scalarLogNorm, scalarLogNormSq, ← Complex.normSq_eq_norm_sq, Complex.normSq_apply, hre, him]
  ring

theorem scalarLogNorm_nonneg (t : ℝ) : 0 ≤ scalarLogNorm t := norm_nonneg _

theorem scalarLogNormSq_nonneg (t : ℝ) : 0 ≤ scalarLogNormSq t := by
  rw [← scalarLogNorm_sq]; positivity

theorem scalarLogNorm_eq_sqrt (t : ℝ) : scalarLogNorm t = Real.sqrt (scalarLogNormSq t) := by
  rw [← scalarLogNorm_sq, Real.sqrt_sq (scalarLogNorm_nonneg t)]

theorem log_one_add_sq_nonneg (t : ℝ) : 0 ≤ Real.log (1 + t ^ 2) :=
  Real.log_nonneg (by nlinarith [sq_nonneg t])

theorem strictMonoOn_scalarLogNormSq : StrictMonoOn scalarLogNormSq (Ici (0 : ℝ)) := by
  intro a ha b hb hab
  simp only [mem_Ici] at ha hb
  have h1 : Real.log (1 + a ^ 2) < Real.log (1 + b ^ 2) := by
    apply Real.log_lt_log (by positivity)
    nlinarith
  have h2 : Real.arctan a < Real.arctan b := Real.arctan_strictMono hab
  have ha1 := log_one_add_sq_nonneg a
  have ha2 : 0 ≤ Real.arctan a := Real.arctan_nonneg.2 ha
  unfold scalarLogNormSq
  nlinarith

theorem strictMonoOn_scalarLogNorm : StrictMonoOn scalarLogNorm (Ici (0 : ℝ)) := by
  intro a ha b hb hab
  have h := strictMonoOn_scalarLogNormSq ha hb hab
  rw [scalarLogNorm_eq_sqrt, scalarLogNorm_eq_sqrt]
  exact Real.sqrt_lt_sqrt (scalarLogNormSq_nonneg a) h

theorem injOn_scalarLogNorm : InjOn scalarLogNorm (Ici (0 : ℝ)) :=
  strictMonoOn_scalarLogNorm.injOn

theorem continuous_scalarLogNorm : Continuous scalarLogNorm := by
  unfold scalarLogNorm
  apply Continuous.norm
  apply Continuous.clog
  · fun_prop
  · intro t
    rw [Complex.mem_slitPlane_iff]
    left
    simp

/-! ## 2.  Closed-form isolation of the root in `[1, √3]`

The two endpoints are exactly the points where the arctangent is a rational
multiple of `π`, which is what makes this interval certifiable without any
Taylor expansion. -/

/-- Order-5 upper Taylor certificate for `arctan` (restated from
`EMLQuantumTaylorCertificates.lean`); it is the only Taylor input needed here. -/
theorem arctan_le_taylor_five {y : ℝ} (hy : 0 ≤ y) : Real.arctan y ≤ y - y ^ 3 / 3 + y ^ 5 / 5 := by
  set g : ℝ → ℝ := fun x => (x - x ^ 3 / 3 + x ^ 5 / 5) - Real.arctan x with hg
  have hd : ∀ x : ℝ, HasDerivAt g (x ^ 6 / (1 + x ^ 2)) x := by
    intro x
    have h1 : HasDerivAt Real.arctan (1 / (1 + x ^ 2)) x := Real.hasDerivAt_arctan x
    have h2 : HasDerivAt (fun x : ℝ => x - x ^ 3 / 3 + x ^ 5 / 5) (1 - x ^ 2 + x ^ 4) x := by
      have ha : HasDerivAt (fun x : ℝ => x - x ^ 3 / 3) (1 - x ^ 2) x := by
        simpa using ((hasDerivAt_id x).sub ((hasDerivAt_pow 3 x).div_const 3)).congr_deriv (by
          push_cast; ring)
      have hb : HasDerivAt (fun x : ℝ => x ^ 5 / 5) (x ^ 4) x := by
        simpa using ((hasDerivAt_pow 5 x).div_const 5).congr_deriv (by push_cast; ring)
      exact ha.add hb
    refine (h2.sub h1).congr_deriv ?_
    have hpos : (0:ℝ) < 1 + x ^ 2 := by positivity
    field_simp
    ring
  have hmono : Monotone g := monotone_of_hasDerivAt_nonneg hd (by intro x; positivity)
  have h := hmono hy
  simp only [hg] at h
  simpa using h

theorem scalarLogNormSq_one_lt_one : scalarLogNormSq 1 < 1 := by
  have hlog : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hlog0 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hpi : Real.pi < 3.15 := Real.pi_lt_d2
  have hpi0 : 0 < Real.pi := Real.pi_pos
  have h1 : Real.log (1 + (1:ℝ) ^ 2) = Real.log 2 := by norm_num
  unfold scalarLogNormSq
  rw [h1, Real.arctan_one]
  nlinarith

theorem one_lt_scalarLogNormSq_sqrt_three : 1 < scalarLogNormSq (Real.sqrt 3) := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hpi : 3 < Real.pi := Real.pi_gt_three
  have hlog : 0 ≤ Real.log (1 + Real.sqrt 3 ^ 2) := log_one_add_sq_nonneg _
  unfold scalarLogNormSq
  rw [Real.arctan_sqrt_three]
  nlinarith [sq_nonneg (Real.log (1 + Real.sqrt 3 ^ 2) / 2)]

theorem one_lt_sqrt_three : (1 : ℝ) < Real.sqrt 3 := by
  have : Real.sqrt 1 < Real.sqrt 3 := by
    apply Real.sqrt_lt_sqrt <;> norm_num
  simpa using this

theorem scalarLogNorm_one_lt_one : scalarLogNorm 1 < 1 := by
  rw [scalarLogNorm_eq_sqrt]
  have := scalarLogNormSq_one_lt_one
  nlinarith [Real.sq_sqrt (scalarLogNormSq_nonneg 1), Real.sqrt_nonneg (scalarLogNormSq 1)]

theorem one_lt_scalarLogNorm_sqrt_three : 1 < scalarLogNorm (Real.sqrt 3) := by
  rw [scalarLogNorm_eq_sqrt]
  have := one_lt_scalarLogNormSq_sqrt_three
  nlinarith [Real.sq_sqrt (scalarLogNormSq_nonneg (Real.sqrt 3)),
    Real.sqrt_nonneg (scalarLogNormSq (Real.sqrt 3))]

theorem exists_scalarLogNorm_eq_one_mem_Icc :
    ∃ t ∈ Icc (1 : ℝ) (Real.sqrt 3), scalarLogNorm t = 1 := by
  have hone : (1 : ℝ) ∈ Icc (scalarLogNorm 1) (scalarLogNorm (Real.sqrt 3)) :=
    ⟨scalarLogNorm_one_lt_one.le, one_lt_scalarLogNorm_sqrt_three.le⟩
  exact intermediate_value_Icc one_lt_sqrt_three.le continuous_scalarLogNorm.continuousOn hone

/-- **The quantum EML scalar-log root** `t*`: the unique positive parameter whose
principal logarithm `log (1 + t i)` lies on the unit circle. -/
def scalarLogRoot : ℝ := exists_scalarLogNorm_eq_one_mem_Icc.choose

theorem scalarLogRoot_mem_Icc : scalarLogRoot ∈ Icc (1 : ℝ) (Real.sqrt 3) :=
  exists_scalarLogNorm_eq_one_mem_Icc.choose_spec.1

theorem scalarLogNorm_scalarLogRoot : scalarLogNorm scalarLogRoot = 1 :=
  exists_scalarLogNorm_eq_one_mem_Icc.choose_spec.2

theorem one_le_scalarLogRoot : 1 ≤ scalarLogRoot := scalarLogRoot_mem_Icc.1

theorem scalarLogRoot_pos : 0 < scalarLogRoot := lt_of_lt_of_le one_pos one_le_scalarLogRoot

theorem scalarLogRoot_ne_zero : scalarLogRoot ≠ 0 := ne_of_gt scalarLogRoot_pos

theorem eq_scalarLogRoot_of_pos {t : ℝ} (ht : 0 < t) (h : scalarLogNorm t = 1) :
    t = scalarLogRoot :=
  injOn_scalarLogNorm (mem_Ici.2 ht.le) (mem_Ici.2 scalarLogRoot_pos.le)
    (h.trans scalarLogNorm_scalarLogRoot.symm)

theorem scalarLogNorm_zero : scalarLogNorm 0 = 0 := by simp [scalarLogNorm]

theorem scalarLogNormSq_neg (t : ℝ) : scalarLogNormSq (-t) = scalarLogNormSq t := by
  unfold scalarLogNormSq
  rw [Real.arctan_neg, neg_pow, neg_pow]
  ring_nf

theorem scalarLogNorm_neg (t : ℝ) : scalarLogNorm (-t) = scalarLogNorm t := by
  rw [scalarLogNorm_eq_sqrt, scalarLogNorm_eq_sqrt, scalarLogNormSq_neg]

/-- **Complete classification.**  The principal logarithm `log (1 + t i)` lies on
the unit circle for exactly two real parameters, `± t*`. -/
theorem scalarLogNorm_eq_one_iff {t : ℝ} :
    scalarLogNorm t = 1 ↔ t = scalarLogRoot ∨ t = -scalarLogRoot := by
  constructor
  · intro h
    rcases lt_trichotomy t 0 with ht | ht | ht
    · right
      have hneg : scalarLogNorm (-t) = 1 := by rw [scalarLogNorm_neg]; exact h
      have := eq_scalarLogRoot_of_pos (by linarith) hneg
      linarith
    · exfalso
      rw [ht, scalarLogNorm_zero] at h
      norm_num at h
    · exact Or.inl (eq_scalarLogRoot_of_pos ht h)
  · rintro (rfl | rfl)
    · exact scalarLogNorm_scalarLogRoot
    · rw [scalarLogNorm_neg]; exact scalarLogNorm_scalarLogRoot

/-! ### Sharpening the enclosure: `1 < t* < √2`, hence `1 < t*² < 2`

This is what turns the quadratic relation `H² = t*² I` into an *integrality*
obstruction: `t*²` is strictly between two consecutive integers. -/

theorem one_lt_scalarLogNormSq_sqrt_two : 1 < scalarLogNormSq (Real.sqrt 2) := by
  have hs2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hs2pos : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos.2 (by norm_num)
  have hlow : (1.41421356 : ℝ) ≤ Real.sqrt 2 := by
    rw [show (1.41421356 : ℝ) = Real.sqrt (1.41421356 ^ 2) by
      rw [Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_le_sqrt (by norm_num)
  set y : ℝ := (Real.sqrt 2)⁻¹ with hy
  have hy0 : 0 ≤ y := by positivity
  have hymul : y * Real.sqrt 2 = 1 := inv_mul_cancel₀ (ne_of_gt hs2pos)
  have hyle : y ≤ 0.70710679 := by nlinarith
  have hy2 : y ^ 2 = 1/2 := by rw [hy, inv_pow, hs2]; norm_num
  have harc : Real.arctan y ≤ y - y ^ 3 / 3 + y ^ 5 / 5 := arctan_le_taylor_five hy0
  have hcube : y ^ 3 = y / 2 := by nlinarith [hy2]
  have hfive : y ^ 5 = y / 4 := by nlinarith [hy2, hcube]
  have harc2 : Real.arctan y ≤ 0.6246444 := by
    rw [hcube, hfive] at harc
    nlinarith
  have hpi : (3.141592 : ℝ) < Real.pi := Real.pi_gt_d6
  have hinv : Real.arctan y = Real.pi / 2 - Real.arctan (Real.sqrt 2) := by
    rw [hy]; exact Real.arctan_inv_of_pos hs2pos
  have hB : (0.9461 : ℝ) ≤ Real.arctan (Real.sqrt 2) := by
    rw [hinv] at harc2; linarith
  have h32 : (1:ℝ) - (3/2 : ℝ)⁻¹ ≤ Real.log (3/2) := Real.one_sub_inv_le_log_of_pos (by norm_num)
  have hsum : Real.log 3 = Real.log 2 + Real.log (3/2) := by
    rw [← Real.log_mul (by norm_num) (by norm_num)]; norm_num
  have hlog2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hA : (1.0264 : ℝ) ≤ Real.log (1 + Real.sqrt 2 ^ 2) := by
    rw [hs2]
    norm_num
    linarith
  unfold scalarLogNormSq
  nlinarith [hA, hB]

theorem scalarLogNormSq_scalarLogRoot : scalarLogNormSq scalarLogRoot = 1 := by
  rw [← scalarLogNorm_sq, scalarLogNorm_scalarLogRoot, one_pow]

/-- The root is strictly larger than `1`. -/
theorem one_lt_scalarLogRoot : 1 < scalarLogRoot := by
  by_contra hcon
  push_neg at hcon
  have h1 : scalarLogNormSq scalarLogRoot ≤ scalarLogNormSq 1 :=
    strictMonoOn_scalarLogNormSq.monotoneOn (mem_Ici.2 scalarLogRoot_pos.le)
      (mem_Ici.2 zero_le_one) hcon
  rw [scalarLogNormSq_scalarLogRoot] at h1
  linarith [scalarLogNormSq_one_lt_one]

/-- The root is strictly smaller than `√2`. -/
theorem scalarLogRoot_lt_sqrt_two : scalarLogRoot < Real.sqrt 2 := by
  by_contra hcon
  push_neg at hcon
  have hpos : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos.2 (by norm_num)
  have h1 : scalarLogNormSq (Real.sqrt 2) ≤ scalarLogNormSq scalarLogRoot :=
    strictMonoOn_scalarLogNormSq.monotoneOn (mem_Ici.2 hpos.le)
      (mem_Ici.2 scalarLogRoot_pos.le) hcon
  rw [scalarLogNormSq_scalarLogRoot] at h1
  linarith [one_lt_scalarLogNormSq_sqrt_two]

/-- `t*²` lies strictly between the consecutive integers `1` and `2`. -/
theorem one_lt_scalarLogRoot_sq : 1 < scalarLogRoot ^ 2 := by
  nlinarith [one_lt_scalarLogRoot]

theorem scalarLogRoot_sq_lt_two : scalarLogRoot ^ 2 < 2 := by
  have h := scalarLogRoot_lt_sqrt_two
  have hs2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  nlinarith [scalarLogRoot_pos, Real.sqrt_nonneg 2]

/-! ## 3.  Matrix preliminaries -/

section Matrices

variable {n : Type*} [Fintype n] [DecidableEq n]

theorem conj_mul_self_eq_one_iff (z : ℂ) : (starRingEnd ℂ) z * z = 1 ↔ ‖z‖ = 1 := by
  rw [mul_comm, Complex.mul_conj]
  constructor
  · intro h
    have hz : Complex.normSq z = 1 := by exact_mod_cast h
    rw [Complex.normSq_eq_norm_sq] at hz
    nlinarith [norm_nonneg z]
  · intro h
    rw [Complex.normSq_eq_norm_sq, h]
    norm_num

/-- A diagonal matrix is unitary exactly when all its diagonal entries are
unimodular. -/
theorem diagonal_mem_unitary_iff (v : n → ℂ) :
    Matrix.diagonal v ∈ unitary (Matrix n n ℂ) ↔ ∀ i, ‖v i‖ = 1 := by
  have hstar : star (Matrix.diagonal v) = Matrix.diagonal (fun i => (starRingEnd ℂ) (v i)) :=
    Matrix.diagonal_conjTranspose v
  constructor
  · intro h i
    have h1 := h.1
    rw [hstar, Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one] at h1
    have h2 := congrFun (Matrix.diagonal_injective h1) i
    exact (conj_mul_self_eq_one_iff (v i)).1 (by simpa using h2)
  · intro h
    have h1 : ∀ i, (starRingEnd ℂ) (v i) * v i = 1 :=
      fun i => (conj_mul_self_eq_one_iff (v i)).2 (h i)
    constructor
    · rw [hstar, Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
      congr 1
      funext i
      simpa using h1 i
    · rw [hstar, Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
      congr 1
      funext i
      have h2 := h1 i
      rw [mul_comm] at h2
      simpa using h2

/-- Unitary conjugation preserves and reflects unitarity. -/
theorem unitary_conj_mem_iff {V A : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ)) :
    V * A * star V ∈ unitary (Matrix n n ℂ) ↔ A ∈ unitary (Matrix n n ℂ) := by
  constructor
  · intro h
    have hA : A = star V * (V * A * star V) * V := by
      have h1 : star V * V = 1 := hV.1
      calc A = (star V * V) * A * (star V * V) := by rw [h1, one_mul, mul_one]
        _ = star V * (V * A * star V) * V := by noncomm_ring
    rw [hA]
    exact mul_mem (mul_mem (Unitary.star_mem hV) h) hV
  · intro h
    exact mul_mem (mul_mem hV h) (Unitary.star_mem hV)

/-- Unitary conjugation of a scalar matrix. -/
theorem conj_eq_smul_one_iff {V A : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ)) (c : ℂ) :
    V * A * star V = c • (1 : Matrix n n ℂ) ↔ A = c • (1 : Matrix n n ℂ) := by
  have h1 : star V * V = 1 := hV.1
  have h2 : V * star V = 1 := hV.2
  constructor
  · intro h
    calc A = star V * (V * A * star V) * V := by
          calc A = (star V * V) * A * (star V * V) := by rw [h1, one_mul, mul_one]
            _ = star V * (V * A * star V) * V := by noncomm_ring
      _ = star V * (c • (1 : Matrix n n ℂ)) * V := by rw [h]
      _ = c • (1 : Matrix n n ℂ) := by rw [mul_smul_comm, mul_one, smul_mul_assoc, h1]
  · rintro rfl
    rw [mul_smul_comm, mul_one, smul_mul_assoc, h2]

theorem conj_sq {V A : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ)) :
    (V * A * star V) ^ 2 = V * A ^ 2 * star V := by
  have h1 : star V * V = 1 := hV.1
  calc (V * A * star V) ^ 2 = V * A * (star V * V) * A * star V := by noncomm_ring
    _ = V * A ^ 2 * star V := by rw [h1]; noncomm_ring

theorem diagonal_sq_eq_smul_one_iff (d : n → ℝ) (c : ℝ) :
    (Matrix.diagonal (fun i => ((d i : ℝ) : ℂ))) ^ 2 = ((c ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) ↔
      ∀ i, d i = c ∨ d i = -c := by
  rw [pow_two, Matrix.diagonal_mul_diagonal, Matrix.smul_one_eq_diagonal]
  constructor
  · intro h i
    have h2 := congrFun (Matrix.diagonal_injective h) i
    have h3 : (d i) ^ 2 = c ^ 2 := by
      have hc : ((d i : ℝ) : ℂ) * ((d i : ℝ) : ℂ) = ((c ^ 2 : ℝ) : ℂ) := h2
      have h4 : ((d i * d i : ℝ) : ℂ) = ((c ^ 2 : ℝ) : ℂ) := by
        push_cast at hc ⊢; linear_combination hc
      have h5 := Complex.ofReal_injective h4
      nlinarith [h5]
    have hf : (d i - c) * (d i + c) = 0 := by nlinarith
    rcases mul_eq_zero.1 hf with h5 | h5
    · left; linarith
    · right; linarith
  · intro h
    congr 1
    funext i
    rcases h i with h5 | h5 <;> rw [h5] <;> push_cast <;> ring

end Matrices

/-! ## 4.  Rigidity for an arbitrary Hermitian matrix -/

section Hermitian

variable {n : Type*} [Fintype n] [DecidableEq n] {H : Matrix n n ℂ}

/-- The **logarithmic activation** `log (I + i H)` of a Hermitian matrix,
defined through Mathlib's spectral decomposition of `H`. -/
def logActivation (hH : H.IsHermitian) : Matrix n n ℂ :=
  (hH.eigenvectorUnitary : Matrix n n ℂ) *
    Matrix.diagonal (fun i => Complex.log (1 + (hH.eigenvalues i : ℂ) * I)) *
    star (hH.eigenvectorUnitary : Matrix n n ℂ)

theorem eigenvectorUnitary_mem_unitary (hH : H.IsHermitian) :
    (hH.eigenvectorUnitary : Matrix n n ℂ) ∈ unitary (Matrix n n ℂ) :=
  hH.eigenvectorUnitary.2

/-- Mathlib's spectral theorem, in the explicit conjugation form used below. -/
theorem eq_conj_diagonal_eigenvalues (hH : H.IsHermitian) :
    H = (hH.eigenvectorUnitary : Matrix n n ℂ) *
      Matrix.diagonal (fun i => ((hH.eigenvalues i : ℝ) : ℂ)) *
      star (hH.eigenvectorUnitary : Matrix n n ℂ) := by
  conv_lhs => rw [hH.spectral_theorem]
  simp [Unitary.conjStarAlgAut_apply, Function.comp_def]

/-- **Eigenvalue rigidity.**  The logarithmic activation of a Hermitian matrix is
unitary exactly when every eigenvalue is `± t*`. -/
theorem logActivation_mem_unitary_iff (hH : H.IsHermitian) :
    logActivation hH ∈ unitary (Matrix n n ℂ) ↔
      ∀ i, hH.eigenvalues i = scalarLogRoot ∨ hH.eigenvalues i = -scalarLogRoot := by
  rw [logActivation, unitary_conj_mem_iff (eigenvectorUnitary_mem_unitary hH),
    diagonal_mem_unitary_iff]
  exact forall_congr' fun i => scalarLogNorm_eq_one_iff (t := hH.eigenvalues i)

/-- **Matrix rigidity, free of any spectral presentation.**  For a Hermitian `H`,
the logarithmic activation `log (I + i H)` is unitary iff `H` satisfies the
quadratic relation `H² = t*² · I`.  Unitarity of the quantum EML activation is
therefore an algebraic — indeed a *closed, measure-zero* — constraint on the
Hamiltonian, not a generic property. -/
theorem logActivation_mem_unitary_iff_sq (hH : H.IsHermitian) :
    logActivation hH ∈ unitary (Matrix n n ℂ) ↔
      H * H = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) := by
  have hU := eigenvectorUnitary_mem_unitary hH
  have key : H * H = (hH.eigenvectorUnitary : Matrix n n ℂ) *
      (Matrix.diagonal fun i => ((hH.eigenvalues i : ℝ) : ℂ)) ^ 2 *
      star (hH.eigenvectorUnitary : Matrix n n ℂ) := by
    conv_lhs => rw [eq_conj_diagonal_eigenvalues hH]
    rw [← pow_two, conj_sq hU]
  rw [logActivation_mem_unitary_iff hH, ← diagonal_sq_eq_smul_one_iff hH.eigenvalues scalarLogRoot,
    key, conj_eq_smul_one_iff hU]

/-! ### Consequences of the quadratic relation -/

variable (hH : H.IsHermitian)

/-- `t*⁻¹ · H` is a self-adjoint involution. -/
theorem involution_of_logActivation_mem_unitary
    (h : logActivation hH ∈ unitary (Matrix n n ℂ)) :
    ((scalarLogRoot⁻¹ : ℝ) : ℂ) • H * (((scalarLogRoot⁻¹ : ℝ) : ℂ) • H) =
      (1 : Matrix n n ℂ) := by
  have hsq := (logActivation_mem_unitary_iff_sq hH).1 h
  have hne : ((scalarLogRoot : ℝ) : ℂ) ≠ 0 := by
    exact_mod_cast Complex.ofReal_ne_zero.2 scalarLogRoot_ne_zero
  rw [smul_mul_assoc, mul_smul_comm, hsq, smul_smul]
  push_cast
  rw [smul_smul,
    show ((scalarLogRoot : ℂ)⁻¹ * (scalarLogRoot : ℂ)⁻¹ * (scalarLogRoot : ℂ) ^ 2) = 1 by
      field_simp, one_smul]

/-- The spectral projection `P = (I + t*⁻¹ H)/2` is idempotent: the admissible
Hamiltonians are exactly `t* (2P − I)` for `P` an orthogonal projection, i.e.
they form a disjoint union of Grassmannians. -/
theorem isIdempotentElem_projection
    (h : logActivation hH ∈ unitary (Matrix n n ℂ)) :
    IsIdempotentElem
      (((2 : ℂ)⁻¹) • ((1 : Matrix n n ℂ) + ((scalarLogRoot⁻¹ : ℝ) : ℂ) • H)) := by
  have hinv := involution_of_logActivation_mem_unitary hH h
  set A : Matrix n n ℂ := ((scalarLogRoot⁻¹ : ℝ) : ℂ) • H with hA
  have : (((2 : ℂ)⁻¹) • ((1 : Matrix n n ℂ) + A)) * (((2 : ℂ)⁻¹) • (1 + A))
      = ((2 : ℂ)⁻¹ * (2 : ℂ)⁻¹) • ((1 : Matrix n n ℂ) + A + (A + A * A)) := by
    rw [smul_mul_assoc, mul_smul_comm, smul_smul]
    congr 1
    noncomm_ring
  rw [IsIdempotentElem, this, hinv]
  rw [show (1 : Matrix n n ℂ) + A + (A + 1) = (2 : ℂ) • (1 + A) by
    rw [two_smul]; abel]
  rw [smul_smul]
  norm_num

omit [Fintype n] in
/-- The projection is Hermitian; together with idempotency it is an orthogonal
projection. -/
theorem isHermitian_projection (hH : H.IsHermitian) :
    (((2 : ℂ)⁻¹) • ((1 : Matrix n n ℂ) + ((scalarLogRoot⁻¹ : ℝ) : ℂ) • H)).IsHermitian := by
  have h1 : Hᴴ = H := hH
  unfold Matrix.IsHermitian
  rw [Matrix.conjTranspose_smul, Matrix.conjTranspose_add, Matrix.conjTranspose_smul,
    Matrix.conjTranspose_one, h1]
  norm_num

/-! ### Arithmetic quantization -/

/-- The number of `+t*` energy levels of `H`. -/
def upperLevelCount (hH : H.IsHermitian) : ℕ :=
  (Finset.univ.filter fun i => hH.eigenvalues i = scalarLogRoot).card

theorem upperLevelCount_le (hH : H.IsHermitian) : upperLevelCount hH ≤ Fintype.card n := by
  classical
  simpa [upperLevelCount, Finset.card_univ] using
    Finset.card_le_card (Finset.filter_subset
      (fun i => hH.eigenvalues i = scalarLogRoot) Finset.univ)

/-- **Trace quantization.**  If the logarithmic activation is unitary, the sum of
the eigenvalues is `t* · (2k − n)` where `k` is the number of `+t*` levels. -/
theorem sum_eigenvalues_eq (h : logActivation hH ∈ unitary (Matrix n n ℂ)) :
    ∑ i, hH.eigenvalues i =
      scalarLogRoot * (2 * (upperLevelCount hH : ℝ) - Fintype.card n) := by
  classical
  have hspec := (logActivation_mem_unitary_iff hH).1 h
  set s : Finset n := Finset.univ.filter (fun i => hH.eigenvalues i = scalarLogRoot) with hs
  set u : Finset n := Finset.univ.filter (fun i => ¬ hH.eigenvalues i = scalarLogRoot) with hu
  have hsplit := Finset.sum_filter_add_sum_filter_not Finset.univ
      (fun i => hH.eigenvalues i = scalarLogRoot) hH.eigenvalues
  have key1 : ∀ i ∈ s, hH.eigenvalues i = scalarLogRoot := by
    intro i hi
    rw [hs] at hi
    exact (Finset.mem_filter.1 hi).2
  have key2 : ∀ i ∈ u, hH.eigenvalues i = -scalarLogRoot := by
    intro i hi
    rw [hu] at hi
    have hi' := (Finset.mem_filter.1 hi).2
    rcases hspec i with hv | hv
    · exact absurd hv hi'
    · exact hv
  have h1 : ∑ i ∈ s, hH.eigenvalues i = (s.card : ℝ) * scalarLogRoot := by
    rw [Finset.sum_congr rfl key1]
    simp [mul_comm]
  have h2 : ∑ i ∈ u, hH.eigenvalues i = (u.card : ℝ) * (-scalarLogRoot) := by
    rw [Finset.sum_congr rfl key2]
    simp [mul_comm]
  have hcards : s.card + u.card = Fintype.card n := by
    rw [hs, hu]
    simpa [Finset.card_univ] using
      Finset.card_filter_add_card_filter_not (s := (Finset.univ : Finset n))
        (p := fun i => hH.eigenvalues i = scalarLogRoot)
  have hcast : (s.card : ℝ) + (u.card : ℝ) = (Fintype.card n : ℝ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) hcards
  rw [h1, h2] at hsplit
  rw [← hsplit, upperLevelCount, ← hs, ← hcast]
  ring

/-- The trace version of quantization: `tr H = t* (2k − n)`. -/
theorem trace_eq (h : logActivation hH ∈ unitary (Matrix n n ℂ)) :
    H.trace =
      ((scalarLogRoot * (2 * (upperLevelCount hH : ℝ) - Fintype.card n) : ℝ) : ℂ) := by
  rw [← sum_eigenvalues_eq hH h, hH.trace_eq_sum_eigenvalues]
  push_cast
  rfl

/-- **Odd dimension forbids a traceless Hamiltonian.**  If `n` is odd and the
logarithmic activation of `H` is unitary, then the trace never vanishes.  This is
a genuinely arithmetic obstruction: it comes from the parity of `2k − n`, not
from any analytic estimate. -/
theorem trace_ne_zero_of_odd_card (h : logActivation hH ∈ unitary (Matrix n n ℂ))
    (hodd : Odd (Fintype.card n)) : H.trace ≠ 0 := by
  classical
  have htr := trace_eq hH h
  have hne : (2 * (upperLevelCount hH : ℝ) - Fintype.card n) ≠ 0 := by
    intro hzero
    obtain ⟨m, hm⟩ := hodd
    rw [hm] at hzero
    push_cast at hzero
    have h3 : (2 : ℤ) * ((upperLevelCount hH : ℤ) - m) = 1 := by
      have : ((2 * ((upperLevelCount hH : ℤ) - m) : ℤ) : ℝ) = ((1 : ℤ) : ℝ) := by
        push_cast
        linarith
      exact_mod_cast this
    omega
  rw [htr]
  simp only [ne_eq, Complex.ofReal_eq_zero]
  exact mul_ne_zero scalarLogRoot_ne_zero hne

/-- **Trace lower bound in odd dimension.**  The trace has absolute value at
least `t* ≥ 1`. -/
theorem one_lt_abs_trace_of_odd_card (h : logActivation hH ∈ unitary (Matrix n n ℂ))
    (hodd : Odd (Fintype.card n)) : 1 ≤ ‖H.trace‖ := by
  classical
  have htr := trace_eq hH h
  have hne : (1 : ℝ) ≤ |2 * (upperLevelCount hH : ℝ) - Fintype.card n| := by
    obtain ⟨m, hm⟩ := hodd
    set k := (upperLevelCount hH : ℤ) with hk
    have hzint : (2 * (upperLevelCount hH : ℝ) - Fintype.card n)
        = ((2 * k - (2 * m + 1) : ℤ) : ℝ) := by
      rw [hm, hk]; push_cast; ring
    rw [hzint, ← Int.cast_abs]
    have hne0 : (2 * k - (2 * m + 1) : ℤ) ≠ 0 := by omega
    have : (1 : ℤ) ≤ |2 * k - (2 * m + 1)| := Int.one_le_abs hne0
    exact_mod_cast this
  rw [htr, Complex.norm_real, Real.norm_eq_abs, abs_mul, abs_of_pos scalarLogRoot_pos]
  nlinarith [one_le_scalarLogRoot, abs_nonneg (2 * (upperLevelCount hH : ℝ) - Fintype.card n)]

/-- **Frobenius quantization.**  `tr (H²) = n · t*²`: all admissible Hamiltonians
lie on a single sphere in the Hermitian matrices. -/
theorem trace_mul_self_eq (h : logActivation hH ∈ unitary (Matrix n n ℂ)) :
    (H * H).trace = (((Fintype.card n : ℝ) * scalarLogRoot ^ 2 : ℝ) : ℂ) := by
  rw [(logActivation_mem_unitary_iff_sq hH).1 h]
  simp [Matrix.trace_smul, Matrix.trace_one, mul_comm]

/-- **Determinant quantization.**  `(det H)² = (t*²)ⁿ`. -/
theorem det_sq_eq (h : logActivation hH ∈ unitary (Matrix n n ℂ)) :
    H.det ^ 2 = (((scalarLogRoot ^ 2 : ℝ) : ℂ)) ^ Fintype.card n := by
  have hsq := (logActivation_mem_unitary_iff_sq hH).1 h
  have hdet := congrArg Matrix.det hsq
  rw [Matrix.det_mul, Matrix.det_smul, Matrix.det_one, mul_one] at hdet
  rw [pow_two]
  exact hdet

/-- A Hamiltonian with unitary logarithmic activation is invertible. -/
theorem isUnit_det (h : logActivation hH ∈ unitary (Matrix n n ℂ)) : IsUnit H.det := by
  have hd := det_sq_eq hH h
  have hne : H.det ≠ 0 := by
    intro hzero
    rw [hzero] at hd
    have hpow : (((scalarLogRoot ^ 2 : ℝ) : ℂ)) ^ Fintype.card n ≠ 0 :=
      pow_ne_zero _ (Complex.ofReal_ne_zero.2 (pow_ne_zero 2 scalarLogRoot_ne_zero))
    exact hpow (by simpa using hd.symm)
  exact isUnit_iff_ne_zero.2 hne

/-! ### An integrality obstruction -/

/-- **No integer Hamiltonian works.**  If `H` is the complexification of a matrix
with *integer* entries (and the index type is nonempty), its logarithmic
activation is never unitary.  Indeed the quadratic relation `H² = t*² I` would
force `t*²` to be the integer `∑_j M_{ij} M_{ji}`, whereas `1 < t*² < 2`.  This
is an unconditional arithmetic obstruction: no irrationality or transcendence
input is needed, only the certified enclosure of the root. -/
theorem not_logActivation_mem_unitary_of_intCast [Nonempty n] {M : Matrix n n ℤ}
    (hM : (M.map (fun z : ℤ => (z : ℂ))).IsHermitian) :
    logActivation hM ∉ unitary (Matrix n n ℂ) := by
  intro h
  have hsq := (logActivation_mem_unitary_iff_sq hM).1 h
  obtain ⟨i⟩ := ‹Nonempty n›
  have hentry := congrFun (congrFun hsq i) i
  have hL : ((M.map (fun z : ℤ => (z : ℂ))) * (M.map (fun z : ℤ => (z : ℂ)))) i i
      = ((∑ j, M i j * M j i : ℤ) : ℂ) := by
    rw [Matrix.mul_apply]
    push_cast
    simp [Matrix.map_apply]
  have hR : (((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ)) i i
      = ((scalarLogRoot ^ 2 : ℝ) : ℂ) := by simp
  rw [hL, hR] at hentry
  have hreal : (scalarLogRoot ^ 2 : ℝ) = ((∑ j, M i j * M j i : ℤ) : ℝ) := by
    exact_mod_cast hentry.symm
  have h1 : (1 : ℝ) < ((∑ j, M i j * M j i : ℤ) : ℝ) := by
    rw [← hreal]; exact one_lt_scalarLogRoot_sq
  have h2 : ((∑ j, M i j * M j i : ℤ) : ℝ) < 2 := by
    rw [← hreal]; exact scalarLogRoot_sq_lt_two
  have h1' : (1 : ℤ) < ∑ j, M i j * M j i := by exact_mod_cast h1
  have h2' : (∑ j, M i j * M j i : ℤ) < 2 := by exact_mod_cast h2
  omega

/-! ### Realizability: the quantization is sharp -/

/-- **Realizability.**  For every subset `s` of the index set there is a Hermitian
matrix whose logarithmic activation is unitary and whose trace is
`t* (2 |s| − n)`.  Together with `trace_eq` this shows the admissible traces are
*exactly* the `n + 1` lattice points `t* (2k − n)`, `0 ≤ k ≤ n`; in particular the
rigidity theorems above are not vacuous. -/
theorem exists_hermitian_logActivation_unitary_trace (s : Finset n) :
    ∃ (K : Matrix n n ℂ) (hK : K.IsHermitian),
      logActivation hK ∈ unitary (Matrix n n ℂ) ∧
        K.trace = ((scalarLogRoot * (2 * (s.card : ℝ) - Fintype.card n) : ℝ) : ℂ) := by
  classical
  set v : n → ℂ := fun i => if i ∈ s then ((scalarLogRoot : ℝ) : ℂ) else -((scalarLogRoot : ℝ) : ℂ)
    with hv
  have hK : (Matrix.diagonal v).IsHermitian := by
    unfold Matrix.IsHermitian
    rw [Matrix.diagonal_conjTranspose]
    congr 1
    funext i
    by_cases hi : i ∈ s <;> simp [hv, hi]
  refine ⟨Matrix.diagonal v, hK, ?_, ?_⟩
  · rw [logActivation_mem_unitary_iff_sq hK, Matrix.diagonal_mul_diagonal,
      Matrix.smul_one_eq_diagonal]
    congr 1
    funext i
    by_cases hi : i ∈ s <;> simp [hv, hi] <;> ring
  · rw [Matrix.trace_diagonal]
    have hsum : ∑ i, v i =
        (s.card : ℂ) * ((scalarLogRoot : ℝ) : ℂ) +
          ((Finset.univ.filter fun i => i ∉ s).card : ℂ) * (-((scalarLogRoot : ℝ) : ℂ)) := by
      rw [hv, Finset.sum_ite]
      simp [Finset.filter_mem_eq_inter, mul_comm]
    have hcards : (Finset.univ.filter fun i => i ∉ s).card = Fintype.card n - s.card := by
      have := Finset.card_filter_add_card_filter_not (s := (Finset.univ : Finset n))
        (p := fun i => i ∈ s)
      simp only [Finset.filter_mem_eq_inter, Finset.univ_inter, Finset.card_univ] at this ⊢
      omega
    have hle : s.card ≤ Fintype.card n := by
      simpa [Finset.card_univ] using Finset.card_le_card (Finset.subset_univ s)
    rw [hsum, hcards]
    have hcast : ((Fintype.card n - s.card : ℕ) : ℂ) = (Fintype.card n : ℂ) - (s.card : ℂ) := by
      have : ((Fintype.card n - s.card : ℕ) : ℂ)
          = ((Fintype.card n : ℕ) : ℂ) - ((s.card : ℕ) : ℂ) := by
        exact_mod_cast Nat.cast_sub hle (R := ℂ)
      simpa using this
    rw [hcast]
    push_cast
    ring

/-- Every lattice point `t* (2k − n)` with `0 ≤ k ≤ n` is attained. -/
theorem exists_hermitian_logActivation_unitary_trace_of_le {k : ℕ} (hk : k ≤ Fintype.card n) :
    ∃ (K : Matrix n n ℂ) (hK : K.IsHermitian),
      logActivation hK ∈ unitary (Matrix n n ℂ) ∧
        K.trace = ((scalarLogRoot * (2 * (k : ℝ) - Fintype.card n) : ℝ) : ℂ) := by
  classical
  obtain ⟨s, -, hs⟩ := Finset.exists_subset_card_eq (s := (Finset.univ : Finset n)) (n := k)
    (by simpa [Finset.card_univ] using hk)
  obtain ⟨K, hK, h1, h2⟩ := exists_hermitian_logActivation_unitary_trace s
  exact ⟨K, hK, h1, by rw [h2, hs]⟩

end Hermitian

end QuantumEML