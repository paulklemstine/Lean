/-
  # Cycle 5: The Cauchy–Binet Bloch Gap (Conjecture C of the previous cycle)

  The previous cycle proved three instances of one identity:

  * `HopfEntanglement.hopf_dot_identity` — the `2 × 2` Hopf gap
    `‖u‖²‖v‖² − ⟨h(u), h(v)⟩ = 2|αδ − βγ|²`;
  * `EntanglementInvariance.purity_eq` — `Tr(ρ_A²) = ‖ψ‖⁴ − C²/2`;
  * `QubitQudit.lagrange_complex` — the `2 × ι` Lagrange identity.

  Conjecture C asserted that all of them are shadows of a single statement about an
  arbitrary rectangular complex matrix `M`, namely

  `(Tr M Mᴴ)² − Tr((M Mᴴ)²) = 2 Σ_{i<j} Σ_{k<l} |M_{ik}M_{jl} − M_{il}M_{jk}|²`,

  the *Cauchy–Binet Bloch gap*: the deficit of the Cauchy–Schwarz-type inequality
  `(Tr G)² ≥ Tr(G²)` for the Gram matrix `G = M Mᴴ` is exactly twice the sum of the
  squared moduli of all `2 × 2` minors of `M`.

  This file proves Conjecture C, in both the symmetric (unordered) and the ordered
  form, and derives from it:

  * `trace_sq_ge_trace_gram_sq` — the inequality `(Tr G)² ≥ Tr(G²)` with an exact defect;
  * `eq_iff_minors_zero` — equality holds iff every `2 × 2` minor of `M` vanishes, i.e.
    iff the state has Schmidt rank ≤ 1 (a product state);
  * `purity_eq_re` — a *reproof from first principles* of the two-qubit purity formula
    `Tr(ρ_A²) = ‖ψ‖⁴ − C²/2`, obtained by specialising the general identity to a `2 × 2`
    coefficient matrix, where the single minor `αδ − βγ` is the entanglement determinant.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): the whole quantitative theory of the previous cycles is a
  Cauchy–Binet expansion of a `2 × 2` Gram determinant summed over pairs of rows.
  EXPERIMENT (Experimenter): sum the already-proved Lagrange identity over all pairs of
  rows `(i, j)` of `M`; the cross terms reassemble as `Σ_{i,j} |G_{ij}|² = Tr(G²)`.
  ANALYSIS (Analyst): the unordered form is the natural one — the passage to `i < j`,
  `k < l` costs a factor `4` and needs a genuine combinatorial lemma
  (`sum_symm_eq_two_mul_sum_lt`), proved by splitting a double sum by trichotomy.
  CRITIQUE (Critic): `Tr(G²)` is a priori a complex number; every statement below is
  phrased with the real quantities `(Tr G).re` and `(Tr G²).re` and the reality of both
  is proved (`trace_gram_re`, `trace_gram_sq_re`), so no reality assumption is hidden.
-/
import Mathlib
import Bridges.QuantumSystems.QuantumEntanglementLinkingNumber
import Pythagorean.QubitQuditConcurrence
import Pythagorean.EntanglementInvariance

open Complex Finset Matrix

noncomputable section

namespace CauchyBinetGap

variable {ι κ : Type*} [Fintype ι] [Fintype κ]

/-! ## A combinatorial lemma: symmetric double sums -/

/-- A double sum of a symmetric function that vanishes on the diagonal is twice the sum
over strictly increasing pairs. -/
theorem sum_symm_eq_two_mul_sum_lt {α : Type*} [Fintype α] [LinearOrder α] (f : α → α → ℝ)
    (hs : ∀ i j, f i j = f j i) (hd : ∀ i, f i i = 0) :
    ∑ i, ∑ j, f i j = 2 * ∑ i, ∑ j ∈ univ.filter (fun j => i < j), f i j := by
  have hswap : ∑ i, ∑ j ∈ univ.filter (fun j => j < i), f i j
      = ∑ i, ∑ j ∈ univ.filter (fun j => i < j), f i j := by
    rw [Finset.sum_comm' (t' := univ) (s' := fun j => univ.filter (fun i => j < i))]
    · exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => hs j i
    · intro x y
      simp [and_comm]
  have key : ∀ i : α, ∑ j, f i j
      = ∑ j ∈ univ.filter (fun j => j < i), f i j
        + ∑ j ∈ univ.filter (fun j => i < j), f i j := by
    intro i
    rw [← Finset.sum_filter_add_sum_filter_not univ (fun j => j < i)]
    congr 1
    rw [← Finset.sum_filter_add_sum_filter_not (univ.filter (fun j => ¬ j < i)) (fun j => i < j)]
    have h0 : ∑ j ∈ (univ.filter (fun j => ¬ j < i)).filter (fun j => ¬ i < j), f i j = 0 := by
      refine Finset.sum_eq_zero fun j hj => ?_
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hj
      have hji : j = i := le_antisymm (not_lt.mp hj.2) (not_lt.mp hj.1)
      rw [hji, hd]
    rw [h0, add_zero]
    congr 1
    ext j
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact ⟨fun h => h.2, fun h => ⟨not_lt.mpr h.le, h⟩⟩
  simp only [key, Finset.sum_add_distrib, hswap]
  ring

/-! ## The Gram matrix -/

/-- The `2 × 2` minor of `M` on rows `i, j` and columns `k, l`. -/
def minor (M : Matrix ι κ ℂ) (i j : ι) (k l : κ) : ℂ := M i k * M j l - M i l * M j k

omit [Fintype ι] [Fintype κ] in
theorem minor_swap_rows (M : Matrix ι κ ℂ) (i j : ι) (k l : κ) :
    minor M j i k l = -minor M i j k l := by simp only [minor]; ring

omit [Fintype ι] [Fintype κ] in
theorem minor_swap_cols (M : Matrix ι κ ℂ) (i j : ι) (k l : κ) :
    minor M i j l k = -minor M i j k l := by simp only [minor]; ring

omit [Fintype ι] [Fintype κ] in
theorem minor_diag_row (M : Matrix ι κ ℂ) (i : ι) (k l : κ) : minor M i i k l = 0 := by
  simp only [minor]; ring

omit [Fintype ι] [Fintype κ] in
theorem minor_diag_col (M : Matrix ι κ ℂ) (i j : ι) (k : κ) : minor M i j k k = 0 := by
  simp only [minor]; ring

omit [Fintype ι] in
theorem gram_apply (M : Matrix ι κ ℂ) (i j : ι) :
    (M * Mᴴ) i j = ∑ k, M i k * (starRingEnd ℂ) (M j k) := by
  simp [Matrix.mul_apply, Matrix.conjTranspose_apply]

omit [Fintype ι] in
theorem gram_conj (M : Matrix ι κ ℂ) (i j : ι) :
    (starRingEnd ℂ) ((M * Mᴴ) j i) = (M * Mᴴ) i j := by
  simp only [gram_apply, map_sum, map_mul, Complex.conj_conj]
  exact Finset.sum_congr rfl fun k _ => mul_comm _ _

/-- `Tr(M Mᴴ)` is the (real) squared Frobenius norm of `M`. -/
theorem trace_gram (M : Matrix ι κ ℂ) :
    Matrix.trace (M * Mᴴ) = ((∑ i, ∑ k, Complex.normSq (M i k) : ℝ) : ℂ) := by
  rw [Matrix.trace]
  push_cast
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Matrix.diag_apply, gram_apply]
  exact Finset.sum_congr rfl fun k _ => Complex.mul_conj _

theorem trace_gram_re (M : Matrix ι κ ℂ) :
    (Matrix.trace (M * Mᴴ)).re = ∑ i, ∑ k, Complex.normSq (M i k) := by
  rw [trace_gram]; simp

/-- `Tr((M Mᴴ)²)` is the (real) sum of the squared moduli of the Gram entries. -/
theorem trace_gram_sq (M : Matrix ι κ ℂ) :
    Matrix.trace ((M * Mᴴ) * (M * Mᴴ))
      = ((∑ i, ∑ j, Complex.normSq ((M * Mᴴ) i j) : ℝ) : ℂ) := by
  rw [Matrix.trace]
  push_cast
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Matrix.diag_apply, Matrix.mul_apply]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [← gram_conj M j i, Complex.mul_conj]

theorem trace_gram_sq_re (M : Matrix ι κ ℂ) :
    (Matrix.trace ((M * Mᴴ) * (M * Mᴴ))).re = ∑ i, ∑ j, Complex.normSq ((M * Mᴴ) i j) := by
  rw [trace_gram_sq]; simp

/-! ## The identity -/

/-- **Cauchy–Binet Bloch gap, unordered form.** The full quadruple sum of squared minors
is `2[(Tr G)² − Tr(G²)]` for the Gram matrix `G = M Mᴴ`. -/
theorem cauchy_binet_full (M : Matrix ι κ ℂ) :
    ∑ i, ∑ j, ∑ k, ∑ l, Complex.normSq (minor M i j k l)
      = 2 * ((∑ i, ∑ k, Complex.normSq (M i k)) ^ 2
          - ∑ i, ∑ j, Complex.normSq ((M * Mᴴ) i j)) := by
  have h : ∀ i j : ι, ∑ k, ∑ l, Complex.normSq (minor M i j k l)
      = 2 * ((∑ k, Complex.normSq (M i k)) * (∑ k, Complex.normSq (M j k))
        - Complex.normSq ((M * Mᴴ) i j)) := by
    intro i j
    rw [gram_apply]
    exact QubitQudit.lagrange_complex (M i) (M j)
  have hprod : ∑ i, ∑ j, (∑ k, Complex.normSq (M i k)) * (∑ k, Complex.normSq (M j k))
      = (∑ i, ∑ k, Complex.normSq (M i k)) ^ 2 := by
    rw [sq]
    exact (Finset.sum_mul_sum _ _ _ _).symm
  have step : ∑ i, ∑ j, ∑ k, ∑ l, Complex.normSq (minor M i j k l)
      = 2 * (∑ i, ∑ j, (∑ k, Complex.normSq (M i k)) * (∑ k, Complex.normSq (M j k)))
        - 2 * (∑ i, ∑ j, Complex.normSq ((M * Mᴴ) i j)) := by
    simp only [h, Finset.mul_sum, mul_sub, Finset.sum_sub_distrib]
  rw [step, hprod]
  ring

/-- **Cauchy–Binet Bloch gap, trace form.** -/
theorem cauchy_binet_trace (M : Matrix ι κ ℂ) :
    (Matrix.trace (M * Mᴴ)).re ^ 2 - (Matrix.trace ((M * Mᴴ) * (M * Mᴴ))).re
      = (1 / 2 : ℝ) * ∑ i, ∑ j, ∑ k, ∑ l, Complex.normSq (minor M i j k l) := by
  rw [cauchy_binet_full, trace_gram_re, trace_gram_sq_re]
  ring

/-- **Conjecture C, ordered form.** For linearly ordered index types the gap is exactly
twice the sum of the squared moduli of the `2 × 2` minors indexed by `i < j`, `k < l`. -/
theorem cauchy_binet_ordered [LinearOrder ι] [LinearOrder κ] (M : Matrix ι κ ℂ) :
    (Matrix.trace (M * Mᴴ)).re ^ 2 - (Matrix.trace ((M * Mᴴ) * (M * Mᴴ))).re
      = 2 * ∑ i, ∑ j ∈ univ.filter (fun j => i < j),
          ∑ k, ∑ l ∈ univ.filter (fun l => k < l), Complex.normSq (minor M i j k l) := by
  have hcols : ∀ i j : ι, ∑ k, ∑ l, Complex.normSq (minor M i j k l)
      = 2 * ∑ k, ∑ l ∈ univ.filter (fun l => k < l), Complex.normSq (minor M i j k l) := by
    intro i j
    refine sum_symm_eq_two_mul_sum_lt _ (fun k l => ?_) (fun k => ?_)
    · rw [minor_swap_cols]; simp
    · simp [minor_diag_col]
  have hrows : ∑ i, ∑ j, (∑ k, ∑ l, Complex.normSq (minor M i j k l))
      = 2 * ∑ i, ∑ j ∈ univ.filter (fun j => i < j),
          ∑ k, ∑ l, Complex.normSq (minor M i j k l) := by
    refine sum_symm_eq_two_mul_sum_lt _ (fun i j => ?_) (fun i => ?_)
    · refine Finset.sum_congr rfl fun k _ => Finset.sum_congr rfl fun l _ => ?_
      rw [minor_swap_rows]; simp
    · simp [minor_diag_row]
  rw [cauchy_binet_trace, hrows]
  simp only [hcols]
  rw [Finset.mul_sum]
  simp only [← Finset.mul_sum]
  ring

/-! ## Consequences -/

/-- **The Bloch gap is nonnegative:** `(Tr G)² ≥ Tr(G²)`, with the defect identified. -/
theorem trace_sq_ge_trace_gram_sq (M : Matrix ι κ ℂ) :
    (Matrix.trace ((M * Mᴴ) * (M * Mᴴ))).re ≤ (Matrix.trace (M * Mᴴ)).re ^ 2 := by
  have h := cauchy_binet_trace M
  have hnn : 0 ≤ ∑ i, ∑ j, ∑ k, ∑ l, Complex.normSq (minor M i j k l) :=
    Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ =>
      Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _
  linarith

/-- **Rank-one criterion.** Equality in `(Tr G)² ≥ Tr(G²)` holds exactly when every
`2 × 2` minor of `M` vanishes — i.e. when the corresponding pure state is a product
state (Schmidt rank ≤ 1). -/
theorem eq_iff_minors_zero (M : Matrix ι κ ℂ) :
    (Matrix.trace (M * Mᴴ) ).re ^ 2 = (Matrix.trace ((M * Mᴴ) * (M * Mᴴ))).re
      ↔ ∀ i j k l, minor M i j k l = 0 := by
  have h := cauchy_binet_trace M
  constructor
  · intro heq
    have hzero : ∑ i, ∑ j, ∑ k, ∑ l, Complex.normSq (minor M i j k l) = 0 := by
      rw [heq] at h; linarith
    intro i j k l
    have h1 : ∀ i' ∈ (univ : Finset ι), (0 : ℝ)
        ≤ ∑ j, ∑ k, ∑ l, Complex.normSq (minor M i' j k l) :=
      fun _ _ => Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ =>
        Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _
    have hi := (Finset.sum_eq_zero_iff_of_nonneg h1).mp hzero i (mem_univ i)
    have h2 : ∀ j' ∈ (univ : Finset ι), (0 : ℝ)
        ≤ ∑ k, ∑ l, Complex.normSq (minor M i j' k l) :=
      fun _ _ => Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _
    have hj := (Finset.sum_eq_zero_iff_of_nonneg h2).mp hi j (mem_univ j)
    have h3 : ∀ k' ∈ (univ : Finset κ), (0 : ℝ) ≤ ∑ l, Complex.normSq (minor M i j k' l) :=
      fun _ _ => Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _
    have hk := (Finset.sum_eq_zero_iff_of_nonneg h3).mp hj k (mem_univ k)
    have hl := (Finset.sum_eq_zero_iff_of_nonneg
      (fun l' (_ : l' ∈ (univ : Finset κ)) => Complex.normSq_nonneg (minor M i j k l'))).mp hk
      l (mem_univ l)
    exact Complex.normSq_eq_zero.mp hl
  · intro hall
    simp only [hall, Complex.normSq_zero, Finset.sum_const_zero, mul_zero] at h
    linarith

/-! ## Specialisation: the two-qubit purity formula, reproved -/

open TwoQubitState EntanglementInvariance in
/-- The single `2 × 2` minor of a two-qubit coefficient matrix is the entanglement
determinant `αδ − βγ`. -/
theorem minor_coeffMatrix (ψ : TwoQubitState) :
    minor (coeffMatrix ψ) 0 1 0 1 = ψ.entanglementDet := by
  simp [minor, coeffMatrix, TwoQubitState.entanglementDet]

open TwoQubitState EntanglementInvariance in
/-- **The purity formula as a special case of Conjecture C.**  Applying the general
Cauchy–Binet gap to the `2 × 2` coefficient matrix of a two-qubit state reproves
`Tr(ρ_A²) = ‖ψ‖⁴ − C²/2` — the single minor being the entanglement determinant, whose
squared modulus is `C²/4`. -/
theorem purity_eq_re (ψ : TwoQubitState) :
    (Matrix.trace (rhoA ψ * rhoA ψ)).re = ψ.normSq ^ 2 - ψ.concurrence ^ 2 / 2 := by
  have hrho : rhoA ψ = coeffMatrix ψ * (coeffMatrix ψ)ᴴ := rfl
  have e00 : coeffMatrix ψ 0 0 = ψ.α := rfl
  have e01 : coeffMatrix ψ 0 1 = ψ.β := rfl
  have e10 : coeffMatrix ψ 1 0 = ψ.γ := rfl
  have e11 : coeffMatrix ψ 1 1 = ψ.δ := rfl
  have hgap := cauchy_binet_trace (coeffMatrix ψ)
  have htr : (Matrix.trace (coeffMatrix ψ * (coeffMatrix ψ)ᴴ)).re = ψ.normSq := by
    rw [trace_gram_re]
    simp only [Fin.sum_univ_two, e00, e01, e10, e11, TwoQubitState.normSq]
    ring
  have hsum : ∑ i, ∑ j, ∑ k, ∑ l, Complex.normSq (minor (coeffMatrix ψ) i j k l)
      = 4 * Complex.normSq ψ.entanglementDet := by
    simp only [Fin.sum_univ_two, minor, e00, e01, e10, e11, TwoQubitState.entanglementDet,
      Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re, Complex.mul_im]
    ring
  have hC : ψ.concurrence ^ 2 = 4 * Complex.normSq ψ.entanglementDet := by
    rw [TwoQubitState.concurrence, mul_pow, Complex.normSq_eq_norm_sq]
    norm_num
  rw [hsum, htr] at hgap
  rw [hrho]
  linarith [hgap, hC]

end CauchyBinetGap