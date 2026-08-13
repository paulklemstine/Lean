import Physics.EntanglementMonotone.LogNegativity

/-!
# The maximally entangled state and non-triviality of the logarithmic negativity

We compute the logarithmic negativity of the maximally entangled state

`|Φ⟩ = d^{-1/2} ∑ᵢ |i i⟩`,  `ρ = |Φ⟩⟨Φ|`,   `d = dim`,

exactly: `E_N(ρ) = log d`.  The computation is a genuine two sided estimate:

* the *upper* bound comes from the explicit Jordan decomposition of the swap operator `S`
  into its symmetric and antisymmetric projections `(1 ± S)/2`, since `Γ ρ = S / d`;
* the *lower* bound comes from weak duality with the contraction `W = S`.

Together with monotonicity this yields the physically meaningful statement that a maximally
entangled state of local dimension `d ≥ 2` can never be produced from a PPT (in particular
from a separable or product) state by a PPT operation: LOCC cannot create entanglement.
-/

namespace EntMonotone

open Matrix Kronecker ComplexOrder
open scoped MatrixOrder

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## The swap operator -/

/-- The swap (flip) operator on `ℂ^α ⊗ ℂ^α`. -/
def swapMatrix : Matrix (α × α) (α × α) ℂ :=
  Matrix.of fun p q => if p.1 = q.2 ∧ p.2 = q.1 then 1 else 0

omit [Fintype α] in
@[simp] theorem swapMatrix_apply (p q : α × α) :
    (swapMatrix : Matrix (α × α) (α × α) ℂ) p q = if p.1 = q.2 ∧ p.2 = q.1 then 1 else 0 := rfl

omit [Fintype α] in
theorem swapMatrix_isHermitian : (swapMatrix : Matrix (α × α) (α × α) ℂ).IsHermitian := by
  ext p q
  simp only [Matrix.conjTranspose_apply, swapMatrix_apply]
  by_cases h : p.1 = q.2 ∧ p.2 = q.1
  · rw [if_pos ⟨h.2.symm, h.1.symm⟩, if_pos h, star_one]
  · rw [if_neg (fun hc => h ⟨hc.2.symm, hc.1.symm⟩), if_neg h, star_zero]

theorem swapMatrix_mul_self :
    (swapMatrix : Matrix (α × α) (α × α) ℂ) * swapMatrix = 1 := by
  ext p q
  rw [Matrix.mul_apply]
  have hterm : ∀ u : α × α, (swapMatrix : Matrix (α × α) (α × α) ℂ) p u * swapMatrix u q
      = if u = (p.2, p.1) then (if p = q then (1 : ℂ) else 0) else 0 := by
    intro u
    by_cases hu : u = (p.2, p.1)
    · subst hu
      have h1 : (swapMatrix : Matrix (α × α) (α × α) ℂ) p (p.2, p.1) = 1 := by
        simp only [swapMatrix_apply]
        simp
      have h2 : (swapMatrix : Matrix (α × α) (α × α) ℂ) (p.2, p.1) q
          = if p = q then (1 : ℂ) else 0 := by
        simp only [swapMatrix_apply]
        refine if_congr ?_ rfl rfl
        constructor
        · rintro ⟨ha, hb⟩
          exact Prod.ext_iff.mpr ⟨hb, ha⟩
        · rintro rfl
          exact ⟨rfl, rfl⟩
      rw [h1, one_mul, h2, if_pos rfl]
    · have hz : (swapMatrix : Matrix (α × α) (α × α) ℂ) p u = 0 := by
        simp only [swapMatrix_apply]
        rw [if_neg]
        rintro ⟨h1, h2⟩
        exact hu (Prod.ext h2.symm h1.symm)
      rw [hz, zero_mul, if_neg hu]
  rw [Finset.sum_congr rfl fun u _ => hterm u,
    Finset.sum_ite_eq' Finset.univ (p.2, p.1) (fun _ => if p = q then (1 : ℂ) else 0)]
  simp only [Finset.mem_univ, if_true, Matrix.one_apply]

omit [DecidableEq α] in
/-- A Hermitian idempotent matrix is positive semidefinite. -/
theorem posSemidef_of_isIdempotent {P : Matrix (α × α) (α × α) ℂ} (hP : P.IsHermitian)
    (hPP : P * P = P) : P.PosSemidef := by
  have := Matrix.posSemidef_conjTranspose_mul_self P
  rwa [hP.eq, hPP] at this

theorem posSemidef_one_add_swap :
    ((1 : Matrix (α × α) (α × α) ℂ) + swapMatrix).PosSemidef := by
  have hherm : (((2⁻¹ : ℝ) : ℂ) • ((1 : Matrix (α × α) (α × α) ℂ) + swapMatrix)).IsHermitian :=
    isHermitian_real_smul (Matrix.isHermitian_one.add swapMatrix_isHermitian) _
  have hP : ((((2⁻¹ : ℝ) : ℂ)) • ((1 : Matrix (α × α) (α × α) ℂ) + swapMatrix)).PosSemidef := by
    refine posSemidef_of_isIdempotent hherm ?_
    rw [Matrix.smul_mul, Matrix.mul_smul, smul_smul, Matrix.add_mul, Matrix.mul_add,
      Matrix.mul_add, Matrix.one_mul, Matrix.mul_one, Matrix.one_mul, swapMatrix_mul_self]
    rw [show (1 : Matrix (α × α) (α × α) ℂ) + swapMatrix + (swapMatrix + 1)
        = (2 : ℂ) • (1 + swapMatrix) by
      ext p q
      simp only [Matrix.add_apply, Matrix.smul_apply, smul_eq_mul]
      ring]
    rw [smul_smul]
    norm_num
  have := hP.smul (a := (2 : ℂ)) (by simp)
  rwa [smul_smul, show (2 : ℂ) * ((2⁻¹ : ℝ) : ℂ) = 1 by push_cast; norm_num, one_smul] at this

theorem posSemidef_one_sub_swap :
    ((1 : Matrix (α × α) (α × α) ℂ) - swapMatrix).PosSemidef := by
  have hherm : (((2⁻¹ : ℝ) : ℂ) • ((1 : Matrix (α × α) (α × α) ℂ) - swapMatrix)).IsHermitian := by
    refine isHermitian_real_smul ?_ _
    unfold Matrix.IsHermitian
    rw [Matrix.conjTranspose_sub, Matrix.conjTranspose_one, swapMatrix_isHermitian]
  have hP : ((((2⁻¹ : ℝ) : ℂ)) • ((1 : Matrix (α × α) (α × α) ℂ) - swapMatrix)).PosSemidef := by
    refine posSemidef_of_isIdempotent hherm ?_
    rw [Matrix.smul_mul, Matrix.mul_smul, smul_smul, Matrix.sub_mul, Matrix.mul_sub,
      Matrix.mul_sub, Matrix.one_mul, Matrix.mul_one, Matrix.one_mul, swapMatrix_mul_self]
    rw [show (1 : Matrix (α × α) (α × α) ℂ) - swapMatrix - (swapMatrix - 1)
        = (2 : ℂ) • (1 - swapMatrix) by
      ext p q
      simp only [Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul]
      ring]
    rw [smul_smul]
    norm_num
  have := hP.smul (a := (2 : ℂ)) (by simp)
  rwa [smul_smul, show (2 : ℂ) * ((2⁻¹ : ℝ) : ℂ) = 1 by push_cast; norm_num, one_smul] at this

/-- The swap operator is a Hermitian contraction. -/
theorem isContraction_swapMatrix : IsContraction (swapMatrix : Matrix (α × α) (α × α) ℂ) :=
  ⟨swapMatrix_isHermitian, posSemidef_one_sub_swap, posSemidef_one_add_swap⟩

/-- The trace norm of the swap operator is `d²`: an exact two sided computation, the upper
bound from the Jordan decomposition into the symmetric and antisymmetric projections and the
lower bound from weak duality with `W = S`. -/
theorem traceNorm_swapMatrix :
    traceNorm (swapMatrix : Matrix (α × α) (α × α) ℂ) = (Fintype.card α : ℝ) ^ 2 := by
  have hre : (((Fintype.card α : ℂ)) ^ 2).re = (Fintype.card α : ℝ) ^ 2 := by
    rw [← Complex.ofReal_natCast, ← Complex.ofReal_pow, Complex.ofReal_re]
  have htr1 : (1 : Matrix (α × α) (α × α) ℂ).trace = ((Fintype.card α : ℂ)) ^ 2 := by
    rw [Matrix.trace_one, Fintype.card_prod]
    push_cast
    ring
  refine le_antisymm ?_ ?_
  · have hJ : IsJordanPair (swapMatrix : Matrix (α × α) (α × α) ℂ)
        (((2⁻¹ : ℝ) : ℂ) • ((1 : Matrix (α × α) (α × α) ℂ) + swapMatrix))
        (((2⁻¹ : ℝ) : ℂ) • ((1 : Matrix (α × α) (α × α) ℂ) - swapMatrix)) := by
      refine ⟨posSemidef_one_add_swap.smul (by simp),
        posSemidef_one_sub_swap.smul (by simp), ?_⟩
      rw [← smul_sub, show (1 : Matrix (α × α) (α × α) ℂ) + swapMatrix - (1 - swapMatrix)
          = (2 : ℂ) • swapMatrix by
        ext p q
        simp only [Matrix.add_apply, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul]
        ring]
      rw [smul_smul, show ((2⁻¹ : ℝ) : ℂ) * (2 : ℂ) = 1 by push_cast; norm_num, one_smul]
    have hle := traceNorm_le hJ
    have hval : ((((2⁻¹ : ℝ) : ℂ) • ((1 : Matrix (α × α) (α × α) ℂ) + swapMatrix)).trace
        + (((2⁻¹ : ℝ) : ℂ) • ((1 : Matrix (α × α) (α × α) ℂ) - swapMatrix)).trace).re
        = (Fintype.card α : ℝ) ^ 2 := by
      rw [Matrix.trace_smul, Matrix.trace_smul, Matrix.trace_add, Matrix.trace_sub, htr1]
      simp only [smul_eq_mul]
      rw [show ((2⁻¹ : ℝ) : ℂ) * ((Fintype.card α : ℂ) ^ 2 + swapMatrix.trace)
          + ((2⁻¹ : ℝ) : ℂ) * ((Fintype.card α : ℂ) ^ 2 - swapMatrix.trace)
          = (Fintype.card α : ℂ) ^ 2 by push_cast; ring]
      exact hre
    rwa [hval] at hle
  · have hdual := re_trace_mul_le_traceNorm (swapMatrix_isHermitian (α := α))
      (isContraction_swapMatrix (α := α))
    rwa [swapMatrix_mul_self, htr1, hre] at hdual

/-! ## The maximally entangled state -/

/-- The maximally entangled state `|Φ⟩⟨Φ|` with `|Φ⟩ = d^{-1/2} ∑ᵢ |i i⟩`. -/
noncomputable def maxEntangled : Matrix (α × α) (α × α) ℂ :=
  Matrix.of fun p q => (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) *
    ((if p.1 = p.2 then 1 else 0) * (if q.1 = q.2 then 1 else 0))

/-- The maximally entangled state is a density matrix. -/
theorem maxEntangled_isState [Nonempty α] :
    IsState (maxEntangled : Matrix (α × α) (α × α) ℂ) := by
  have hd : (0 : ℝ) < Fintype.card α := by exact_mod_cast Fintype.card_pos
  constructor
  · have hv : (maxEntangled : Matrix (α × α) (α × α) ℂ)
        = (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) •
          Matrix.vecMulVec (fun p : α × α => if p.1 = p.2 then (1 : ℂ) else 0)
            (star fun p : α × α => if p.1 = p.2 then (1 : ℂ) else 0) := by
      ext p q
      simp only [maxEntangled, Matrix.of_apply, Matrix.smul_apply, Matrix.vecMulVec_apply,
        Pi.star_apply, smul_eq_mul]
      by_cases hq : q.1 = q.2 <;> simp [hq]
    rw [hv]
    refine (Matrix.posSemidef_vecMulVec_self_star _).smul ?_
    rw [Complex.le_def]
    constructor
    · simp only [Complex.zero_re, Complex.ofReal_re]
      positivity
    · simp
  · simp only [Matrix.trace, Matrix.diag_apply, maxEntangled, Matrix.of_apply]
    have h : ∀ p : α × α, (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) *
        ((if p.1 = p.2 then (1 : ℂ) else 0) * (if p.1 = p.2 then 1 else 0))
        = if p.1 = p.2 then (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) else 0 := by
      intro p
      by_cases hp : p.1 = p.2 <;> simp [hp]
    rw [Finset.sum_congr rfl fun p _ => h p, Fintype.sum_prod_type]
    have h2 : ∀ i : α, (∑ j : α, if (i, j).1 = (i, j).2
        then (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) else 0)
        = (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) := by
      intro i
      have hstep : ∀ j : α, (if (i, j).1 = (i, j).2 then (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) else 0)
          = if j = i then (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) else 0 := by
        intro j
        by_cases hj : j = i
        · subst hj; simp
        · rw [if_neg (fun hc => hj hc.symm), if_neg hj]
      rw [Finset.sum_congr rfl fun j _ => hstep j, Finset.sum_ite_eq' Finset.univ i]
      simp
    rw [Finset.sum_congr rfl fun i _ => h2 i]
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    push_cast
    field_simp

/-- The partial transpose of the maximally entangled state is the swap operator over `d`. -/
theorem ptrans_maxEntangled :
    ptrans (maxEntangled : Matrix (α × α) (α × α) ℂ)
      = (((Fintype.card α : ℝ)⁻¹ : ℝ) : ℂ) • swapMatrix := by
  ext ⟨i, j⟩ ⟨k, l⟩
  simp only [ptrans_apply, maxEntangled, Matrix.of_apply, Matrix.smul_apply, swapMatrix_apply,
    smul_eq_mul]
  by_cases h1 : i = l
  · by_cases h2 : k = j
    · simp [h1, h2]
    · simp [h1, h2, Ne.symm h2]
  · simp [h1]

/-! ## The exact value of the logarithmic negativity -/

theorem traceNorm_ptrans_maxEntangled [Nonempty α] :
    traceNorm (ptrans (maxEntangled : Matrix (α × α) (α × α) ℂ)) = (Fintype.card α : ℝ) := by
  have hd : (0 : ℝ) < Fintype.card α := by exact_mod_cast Fintype.card_pos
  rw [ptrans_maxEntangled,
    traceNorm_smul (swapMatrix_isHermitian (α := α)) (le_of_lt (inv_pos.mpr hd)),
    traceNorm_swapMatrix]
  field_simp

/-- **The logarithmic negativity of the maximally entangled state is `log d`.** -/
theorem logNeg_maxEntangled [Nonempty α] :
    logNeg (maxEntangled : Matrix (α × α) (α × α) ℂ) = Real.log (Fintype.card α) := by
  rw [logNeg, traceNorm_ptrans_maxEntangled]

/-- For local dimension at least `2` the maximally entangled state has strictly positive
logarithmic negativity: the monotone is not identically zero. -/
theorem logNeg_maxEntangled_pos [Nonempty α] (hd : 2 ≤ Fintype.card α) :
    0 < logNeg (maxEntangled : Matrix (α × α) (α × α) ℂ) := by
  rw [logNeg_maxEntangled]
  refine Real.log_pos ?_
  have : (2 : ℝ) ≤ (Fintype.card α : ℝ) := by exact_mod_cast hd
  linarith

/-- The maximally entangled state of local dimension `≥ 2` is not PPT. -/
theorem not_isPPT_maxEntangled [Nonempty α] (hd : 2 ≤ Fintype.card α) :
    ¬ IsPPT (maxEntangled : Matrix (α × α) (α × α) ℂ) := by
  intro h
  have hzero := logNeg_eq_zero_of_isPPT maxEntangled_isState h
  have hpos := logNeg_maxEntangled_pos (α := α) hd
  rw [hzero] at hpos
  exact lt_irrefl 0 hpos

/-- **PPT operations (in particular LOCC) cannot create maximal entanglement.**
No PPT operation maps a PPT state — for instance a product or separable state — to a
maximally entangled state of local dimension at least `2`. -/
theorem no_maxEntangled_from_isPPT [Nonempty α] (hd : 2 ≤ Fintype.card α)
    {ρ : Matrix (α × α) (α × α) ℂ} (hρ : IsState ρ) (hppt : IsPPT ρ)
    {Λ : Matrix (α × α) (α × α) ℂ → Matrix (α × α) (α × α) ℂ} (hΛ : IsPPTOperation Λ) :
    Λ ρ ≠ maxEntangled := by
  intro hcontra
  have hmono := logNeg_mono hΛ hρ
  rw [hcontra, logNeg_eq_zero_of_isPPT hρ hppt] at hmono
  have hpos := logNeg_maxEntangled_pos (α := α) hd
  linarith

end EntMonotone