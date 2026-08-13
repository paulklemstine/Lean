import Mathlib

/-!
# The trace norm of a Hermitian matrix, via Jordan decompositions

This file develops, from scratch, the piece of finite dimensional operator theory that is
needed for the theory of the logarithmic negativity: the *trace norm*

`‖X‖₁ = inf { tr P + tr Q | P, Q ⪰ 0 and X = P - Q }`

of a Hermitian matrix `X`, defined through its Jordan (positive/negative part)
decompositions.  This variational (primal) description is equivalent to the usual
`tr √(X† X)`, and it is the description that makes the two structural facts we need
transparent:

* the trace norm is subadditive and positively homogeneous, and
* it is *contractive under positive trace preserving maps*,

which is the analytic engine behind monotonicity of the logarithmic negativity under
LOCC / PPT operations.

Main definitions

* `EntMonotone.IsJordanPair X P Q` : `P, Q` are positive semidefinite with `X = P - Q`.
* `EntMonotone.traceNormSet X`     : the set of numbers `tr P + tr Q` over Jordan pairs.
* `EntMonotone.traceNorm X`        : the infimum of that set.
* `EntMonotone.IsContraction W`    : `-1 ≤ W ≤ 1` in the Loewner order (`W` Hermitian).

Main results

* `EntMonotone.exists_jordanPair`   : every Hermitian matrix admits a Jordan decomposition
  (proved from the spectral theorem).
* `EntMonotone.traceNorm_posSemidef`: `‖ρ‖₁ = tr ρ` for `ρ ⪰ 0`.
* `EntMonotone.traceNorm_add_le`    : the triangle inequality.
* `EntMonotone.traceNorm_smul`      : positive homogeneity.
* `EntMonotone.traceNorm_le_of_positive_tracePreserving` : contractivity under positive
  trace preserving maps.
* `EntMonotone.re_trace_mul_le_traceNorm` : weak duality `Re tr (X W) ≤ ‖X‖₁` for
  contractions `W`, the source of all *lower* bounds on the trace norm.
-/

namespace EntMonotone

open Matrix ComplexOrder
open scoped MatrixOrder

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

/-! ## Positivity toolbox -/

omit [DecidableEq n] in
/-- The trace of a positive semidefinite matrix has nonnegative real part. -/
theorem re_trace_nonneg {P : Matrix n n ℂ} (hP : P.PosSemidef) : 0 ≤ P.trace.re := by
  have h := hP.trace_nonneg
  simpa using (Complex.le_def.mp h).1

/-- The trace of a product of two positive semidefinite matrices is nonnegative.
Proved by writing `A = √A √A` and cycling the trace. -/
theorem trace_mul_nonneg {A B : Matrix n n ℂ} (hA : A.PosSemidef) (hB : B.PosSemidef) :
    0 ≤ (A * B).trace := by
  have h1 : CFC.sqrt A * CFC.sqrt A = A :=
    CFC.sqrt_mul_sqrt_self A (Matrix.nonneg_iff_posSemidef.mpr hA)
  have h2 : (CFC.sqrt A).PosSemidef := Matrix.nonneg_iff_posSemidef.mp (CFC.sqrt_nonneg A)
  have h3 := hB.conjTranspose_mul_mul_same (CFC.sqrt A)
  rw [h2.isHermitian.eq] at h3
  calc (0 : ℂ) ≤ (CFC.sqrt A * B * CFC.sqrt A).trace := h3.trace_nonneg
    _ = (A * B).trace := by
        rw [Matrix.trace_mul_comm (CFC.sqrt A * B) (CFC.sqrt A), ← Matrix.mul_assoc, h1]

/-- Real-part version of `trace_mul_nonneg`. -/
theorem re_trace_mul_nonneg {A B : Matrix n n ℂ} (hA : A.PosSemidef) (hB : B.PosSemidef) :
    0 ≤ (A * B).trace.re := by
  simpa using (Complex.le_def.mp (trace_mul_nonneg hA hB)).1

/-! ## Jordan decompositions -/

/-- `IsJordanPair X P Q` records that `P` and `Q` are positive semidefinite matrices with
`X = P - Q`; i.e. `(P, Q)` is a (not necessarily minimal) splitting of the Hermitian matrix
`X` into a difference of positive parts. -/
structure IsJordanPair (X P Q : Matrix n n ℂ) : Prop where
  posP : P.PosSemidef
  posQ : Q.PosSemidef
  decomp : X = P - Q

/-- Every Hermitian matrix admits a Jordan decomposition; this is the spectral theorem
together with the splitting `λ = max λ 0 - max (-λ) 0` of the eigenvalues. -/
theorem exists_jordanPair {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    ∃ P Q, IsJordanPair X P Q := by
  classical
  set U : Matrix n n ℂ := (hX.eigenvectorUnitary : Matrix n n ℂ) with hU
  refine ⟨U * diagonal (fun i => ((max (hX.eigenvalues i) 0 : ℝ) : ℂ)) * Uᴴ,
          U * diagonal (fun i => ((max (-(hX.eigenvalues i)) 0 : ℝ) : ℂ)) * Uᴴ, ?_, ?_, ?_⟩
  · exact (Matrix.PosSemidef.diagonal
      (by intro i; simp [Complex.le_def])).mul_mul_conjTranspose_same U
  · exact (Matrix.PosSemidef.diagonal
      (by intro i; simp [Complex.le_def])).mul_mul_conjTranspose_same U
  · have key : (diagonal (fun i => ((max (hX.eigenvalues i) 0 : ℝ) : ℂ)))
        - (diagonal (fun i => ((max (-(hX.eigenvalues i)) 0 : ℝ) : ℂ)))
        = diagonal (RCLike.ofReal ∘ hX.eigenvalues : n → ℂ) := by
      ext i j
      by_cases h : i = j
      · subst h
        simp only [Matrix.sub_apply, Matrix.diagonal_apply_eq, Function.comp_apply,
          RCLike.ofReal_eq_complex_ofReal, ← Complex.ofReal_sub]
        congr 1
        rcases le_total (hX.eigenvalues i) 0 with h | h
        · rw [max_eq_right h, max_eq_left (by linarith)]; ring
        · rw [max_eq_left h, max_eq_right (by linarith)]; ring
      · simp [Matrix.sub_apply, Matrix.diagonal_apply_ne _ h]
    rw [← Matrix.sub_mul, ← Matrix.mul_sub, key]
    conv_lhs => rw [hX.spectral_theorem]
    rfl

/-! ## The trace norm -/

/-- The set of values `Re (tr P + tr Q)` over all Jordan decompositions `X = P - Q`. -/
def traceNormSet (X : Matrix n n ℂ) : Set ℝ :=
  {r | ∃ P Q, IsJordanPair X P Q ∧ r = (P.trace + Q.trace).re}

/-- The trace norm `‖X‖₁ = inf { tr P + tr Q : X = P - Q, P, Q ⪰ 0 }`. -/
noncomputable def traceNorm (X : Matrix n n ℂ) : ℝ := sInf (traceNormSet X)

theorem traceNormSet_nonempty {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    (traceNormSet X).Nonempty := by
  obtain ⟨P, Q, hPQ⟩ := exists_jordanPair hX
  exact ⟨(P.trace + Q.trace).re, P, Q, hPQ, rfl⟩

omit [DecidableEq n] in
theorem traceNormSet_bddBelow (X : Matrix n n ℂ) : BddBelow (traceNormSet X) := by
  refine ⟨0, ?_⟩
  rintro r ⟨P, Q, hPQ, rfl⟩
  simp only [Complex.add_re]
  exact add_nonneg (re_trace_nonneg hPQ.posP) (re_trace_nonneg hPQ.posQ)

omit [DecidableEq n] in
theorem traceNorm_le {X : Matrix n n ℂ} {P Q : Matrix n n ℂ} (h : IsJordanPair X P Q) :
    traceNorm X ≤ (P.trace + Q.trace).re :=
  csInf_le (traceNormSet_bddBelow X) ⟨P, Q, h, rfl⟩

theorem le_traceNorm {X : Matrix n n ℂ} (hX : X.IsHermitian) {c : ℝ}
    (h : ∀ P Q, IsJordanPair X P Q → c ≤ (P.trace + Q.trace).re) : c ≤ traceNorm X := by
  refine le_csInf (traceNormSet_nonempty hX) ?_
  rintro r ⟨P, Q, hPQ, rfl⟩
  exact h P Q hPQ

theorem traceNorm_nonneg (X : Matrix n n ℂ) : 0 ≤ traceNorm X := by
  by_cases hX : X.IsHermitian
  · exact le_traceNorm hX fun P Q hPQ => by
      simpa using add_nonneg (re_trace_nonneg hPQ.posP) (re_trace_nonneg hPQ.posQ)
  · -- for non-Hermitian `X` the set is empty and `sInf ∅ = 0`
    have : traceNormSet X = ∅ := by
      ext r
      simp only [Set.mem_empty_iff_false, iff_false]
      rintro ⟨P, Q, hPQ, rfl⟩
      exact hX (hPQ.decomp ▸ (hPQ.posP.isHermitian.sub hPQ.posQ.isHermitian))
    simp [traceNorm, this]

/-- For a positive semidefinite matrix the trace norm is just the trace. -/
theorem traceNorm_posSemidef {P : Matrix n n ℂ} (hP : P.PosSemidef) :
    traceNorm P = P.trace.re := by
  refine le_antisymm ?_ ?_
  · have := traceNorm_le (X := P) (P := P) (Q := 0) ⟨hP, Matrix.PosSemidef.zero, by simp⟩
    simpa using this
  · refine le_traceNorm hP.isHermitian ?_
    rintro A B ⟨hA, hB, hAB⟩
    have : P.trace.re = A.trace.re - B.trace.re := by
      rw [hAB]; simp
    rw [this]
    simp only [Complex.add_re]
    have := re_trace_nonneg hB
    linarith

@[simp] theorem traceNorm_zero : traceNorm (0 : Matrix n n ℂ) = 0 := by
  simpa using traceNorm_posSemidef (Matrix.PosSemidef.zero (n := n) (R := ℂ))

/-- The trace of a Hermitian matrix is bounded by its trace norm. -/
theorem re_trace_le_traceNorm {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    X.trace.re ≤ traceNorm X := by
  refine le_traceNorm hX ?_
  rintro P Q ⟨hP, hQ, rfl⟩
  simp only [Matrix.trace_sub, Complex.sub_re, Complex.add_re]
  have := re_trace_nonneg hQ
  linarith

omit [Fintype n] [DecidableEq n] in
/-- A real multiple of a Hermitian matrix is Hermitian. -/
theorem isHermitian_real_smul {X : Matrix n n ℂ} (hX : X.IsHermitian) (c : ℝ) :
    (((c : ℂ)) • X).IsHermitian := by
  unfold Matrix.IsHermitian at *
  rw [Matrix.conjTranspose_smul, hX]
  simp

/-- Subadditivity of the trace norm. -/
theorem traceNorm_add_le {X Y : Matrix n n ℂ} (hX : X.IsHermitian) (hY : Y.IsHermitian) :
    traceNorm (X + Y) ≤ traceNorm X + traceNorm Y := by
  have step : ∀ P₁ Q₁, IsJordanPair X P₁ Q₁ → ∀ P₂ Q₂, IsJordanPair Y P₂ Q₂ →
      traceNorm (X + Y) ≤ (P₁.trace + Q₁.trace).re + (P₂.trace + Q₂.trace).re := by
    intro P₁ Q₁ h₁ P₂ Q₂ h₂
    have hsum : IsJordanPair (X + Y) (P₁ + P₂) (Q₁ + Q₂) :=
      ⟨h₁.posP.add h₂.posP, h₁.posQ.add h₂.posQ, by rw [h₁.decomp, h₂.decomp]; abel⟩
    have := traceNorm_le hsum
    simp only [Matrix.trace_add, Complex.add_re] at this ⊢
    linarith
  -- first take the infimum over decompositions of `Y`, then over those of `X`
  have stepY : ∀ P₁ Q₁, IsJordanPair X P₁ Q₁ →
      traceNorm (X + Y) - (P₁.trace + Q₁.trace).re ≤ traceNorm Y := by
    intro P₁ Q₁ h₁
    refine le_traceNorm hY ?_
    intro P₂ Q₂ h₂
    have := step P₁ Q₁ h₁ P₂ Q₂ h₂
    linarith
  have : traceNorm (X + Y) - traceNorm Y ≤ traceNorm X := by
    refine le_traceNorm hX ?_
    intro P₁ Q₁ h₁
    have := stepY P₁ Q₁ h₁
    linarith
  linarith

theorem traceNorm_smul_le {X : Matrix n n ℂ} (hX : X.IsHermitian) {c : ℝ} (hc : 0 < c) :
    traceNorm ((c : ℂ) • X) ≤ c * traceNorm X := by
  have key : traceNorm ((c : ℂ) • X) / c ≤ traceNorm X := by
    refine le_traceNorm hX ?_
    intro P Q h
    have hJ : IsJordanPair ((c : ℂ) • X) ((c : ℂ) • P) ((c : ℂ) • Q) := by
      refine ⟨h.posP.smul (by simp [Complex.le_def, hc.le]),
        h.posQ.smul (by simp [Complex.le_def, hc.le]), ?_⟩
      rw [h.decomp, smul_sub]
    have hle := traceNorm_le hJ
    simp only [Matrix.trace_smul, smul_eq_mul, ← mul_add, Complex.mul_re, Complex.ofReal_re,
      Complex.ofReal_im, zero_mul, sub_zero] at hle
    rw [div_le_iff₀ hc]
    calc traceNorm ((c : ℂ) • X) ≤ c * (P.trace + Q.trace).re := hle
      _ = (P.trace + Q.trace).re * c := by ring
  rw [div_le_iff₀ hc] at key
  linarith

/-- Positive homogeneity of the trace norm on Hermitian matrices. -/
theorem traceNorm_smul {X : Matrix n n ℂ} (hX : X.IsHermitian) {c : ℝ} (hc : 0 ≤ c) :
    traceNorm ((c : ℂ) • X) = c * traceNorm X := by
  rcases eq_or_lt_of_le hc with rfl | hcpos
  · simp
  have hsmulHerm : ((c : ℂ) • X).IsHermitian := isHermitian_real_smul hX c
  refine le_antisymm (traceNorm_smul_le hX hcpos) ?_
  have := traceNorm_smul_le hsmulHerm (c := c⁻¹) (by positivity)
  rw [smul_smul] at this
  rw [show ((c⁻¹ : ℝ) : ℂ) * ((c : ℝ) : ℂ) = 1 by
    push_cast; field_simp] at this
  rw [one_smul] at this
  have h2 := mul_le_mul_of_nonneg_left this hcpos.le
  rwa [← mul_assoc, mul_inv_cancel₀ (ne_of_gt hcpos), one_mul] at h2

/-! ## Contractivity under positive trace preserving maps -/

/-- A (not necessarily completely) positive, trace preserving, subtraction respecting map on
matrices.  Every quantum channel (CPTP map) is of this kind, but so are, e.g., the transpose
map and compositions of channels with partial transposition. -/
structure IsPositiveTP (Phi : Matrix n n ℂ → Matrix m m ℂ) : Prop where
  map_sub : ∀ A B, Phi (A - B) = Phi A - Phi B
  map_pos : ∀ A, A.PosSemidef → (Phi A).PosSemidef
  map_trace : ∀ A, A.PosSemidef → (Phi A).trace = A.trace

omit [DecidableEq m] in
/-- **Contractivity of the trace norm**: a positive trace preserving map cannot increase the
trace norm of a Hermitian matrix.  This is the analytic core of entanglement monotonicity. -/
theorem traceNorm_le_of_positiveTP {Phi : Matrix n n ℂ → Matrix m m ℂ} (hPhi : IsPositiveTP Phi)
    {X : Matrix n n ℂ} (hX : X.IsHermitian) : traceNorm (Phi X) ≤ traceNorm X := by
  refine le_traceNorm hX ?_
  intro P Q h
  have hJ : IsJordanPair (Phi X) (Phi P) (Phi Q) :=
    ⟨hPhi.map_pos P h.posP, hPhi.map_pos Q h.posQ, by rw [h.decomp, hPhi.map_sub]⟩
  have := traceNorm_le hJ
  rwa [hPhi.map_trace P h.posP, hPhi.map_trace Q h.posQ] at this

/-! ## Weak duality -/

/-- `W` is a Hermitian contraction: `-1 ≤ W ≤ 1` in the Loewner order. -/
structure IsContraction (W : Matrix n n ℂ) : Prop where
  herm : W.IsHermitian
  one_sub : (1 - W).PosSemidef
  one_add : (1 + W).PosSemidef

/-- **Weak duality.** For a Hermitian `X` and a Hermitian contraction `W`,
`Re tr (X W) ≤ ‖X‖₁`.  All nontrivial *lower* bounds for the trace norm come from
exhibiting a good contraction `W`. -/
theorem re_trace_mul_le_traceNorm {X W : Matrix n n ℂ} (hX : X.IsHermitian)
    (hW : IsContraction W) : (X * W).trace.re ≤ traceNorm X := by
  refine le_traceNorm hX ?_
  intro P Q h
  have h1 : 0 ≤ (P * (1 - W)).trace.re := re_trace_mul_nonneg h.posP hW.one_sub
  have h2 : 0 ≤ (Q * (1 + W)).trace.re := re_trace_mul_nonneg h.posQ hW.one_add
  rw [Matrix.mul_sub, Matrix.mul_one, Matrix.trace_sub, Complex.sub_re] at h1
  rw [Matrix.mul_add, Matrix.mul_one, Matrix.trace_add, Complex.add_re] at h2
  rw [h.decomp, Matrix.sub_mul, Matrix.trace_sub, Complex.sub_re, Complex.add_re]
  linarith

omit [DecidableEq m] in
/-- **Contractivity for a family of positive maps summing to a trace preserving map.**
If `Psi i` are positive, subtraction respecting maps whose traces add up to the identity's,
then the trace norms of the branches `Psi i X` add up to at most `‖X‖₁`.  This is the
inequality behind monotonicity of entanglement monotones under *selective* measurements
(where the individual branches are only trace non-increasing). -/
theorem sum_traceNorm_le_of_positive_family {ι : Type*} [Fintype ι]
    {Psi : ι → Matrix n n ℂ → Matrix m m ℂ}
    (hsub : ∀ i A B, Psi i (A - B) = Psi i A - Psi i B)
    (hpos : ∀ i A, A.PosSemidef → (Psi i A).PosSemidef)
    (htr : ∀ A, A.PosSemidef → ∑ i, (Psi i A).trace = A.trace)
    {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    ∑ i, traceNorm (Psi i X) ≤ traceNorm X := by
  refine le_traceNorm hX ?_
  intro P Q h
  have hbranch : ∀ i, traceNorm (Psi i X) ≤ ((Psi i P).trace + (Psi i Q).trace).re := by
    intro i
    exact traceNorm_le ⟨hpos i P h.posP, hpos i Q h.posQ, by rw [h.decomp, hsub]⟩
  calc ∑ i, traceNorm (Psi i X)
      ≤ ∑ i, ((Psi i P).trace + (Psi i Q).trace).re := Finset.sum_le_sum fun i _ => hbranch i
    _ = ((∑ i, (Psi i P).trace) + ∑ i, (Psi i Q).trace).re := by
        simp [Complex.add_re, Finset.sum_add_distrib]
    _ = (P.trace + Q.trace).re := by rw [htr P h.posP, htr Q h.posQ]

omit [Fintype n] [DecidableEq n] in
/-- Hermitian matrices are closed under finite sums. -/
theorem isHermitian_sum {ι : Type*} (s : Finset ι) (X : ι → Matrix n n ℂ)
    (h : ∀ i ∈ s, (X i).IsHermitian) : (∑ i ∈ s, X i).IsHermitian := by
  classical
  induction s using Finset.cons_induction with
  | empty => simp
  | cons a s ha ih =>
      rw [Finset.sum_cons]
      exact (h a (Finset.mem_cons_self a s)).add
        (ih fun i hi => h i (Finset.mem_cons_of_mem hi))

/-- Subadditivity of the trace norm over finite sums. -/
theorem traceNorm_sum_le {ι : Type*} (s : Finset ι) (X : ι → Matrix n n ℂ)
    (h : ∀ i ∈ s, (X i).IsHermitian) :
    traceNorm (∑ i ∈ s, X i) ≤ ∑ i ∈ s, traceNorm (X i) := by
  classical
  induction s using Finset.cons_induction with
  | empty => simp
  | cons a s ha ih =>
      rw [Finset.sum_cons, Finset.sum_cons]
      refine le_trans (traceNorm_add_le (h a (Finset.mem_cons_self a s))
        (isHermitian_sum s X fun i hi => h i (Finset.mem_cons_of_mem hi))) ?_
      have := ih fun i hi => h i (Finset.mem_cons_of_mem hi)
      linarith

end EntMonotone