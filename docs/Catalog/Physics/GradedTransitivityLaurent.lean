import Physics.GradedTransitivityResidue

/-!
# The full principal part at `q = 1`: Laurent moments of a polynomial grade count

`Physics.GradedTransitivityResidue` computed the *residue* at `q = 1` of the partition
function of a grade count that is eventually a polynomial `P`: it is the zeta-regularised
value `−P(−1)`.  This file computes the **entire principal part**, not just its top
coefficient.

For a function `F` meromorphic at `1` the number

  `(1/2πi) ∮_{|z−1|=ρ} (z − 1)^j F(z) dz`

is the Laurent coefficient of `(z − 1)^{−(j+1)}`; `j = 0` is the residue.  The theorem proved
here is that for a polynomial grade count these *Laurent moments* are explicit finite
differences:

  `laurentMoment P j = ∑_{k ≤ deg P} (−1)^{k+1} C(k,j) Δᵏ P(0)`.

Two structural consequences drop out:

* `laurentMoment_zero`: at `j = 0` the formula collapses, by Newton's expansion at `−1`, to
  the residue `−P(−1)` — the new computation contains the old one.
* `laurentMoment_eq_zero_of_lt`: the moments vanish for `j > deg P`, so the principal part
  terminates in degree `deg P + 1`, in agreement with the independently proved pole order
  `order_polyZeta`.

As with the residue, the moments are **tail-only invariants**: adding a polynomial correction
supported on finitely many grades changes nothing
(`circleIntegral_moment_of_eventually_polynomial`).

## Main results

* `Physics.GradedTransitivity.circleIntegral_choose_term_moment` — the `j`-th moment of a
  single binomial basis element `qᵏ/(1−q)^{k+1}` is `(−1)^{k+1} C(k,j)·2πi`.
* `Physics.GradedTransitivity.laurentMoment` — the moment functional of a polynomial.
* `Physics.GradedTransitivity.circleIntegral_polyZeta_moment` — the moments of `polyZeta P`.
* `Physics.GradedTransitivity.laurentMoment_zero` — consistency with the residue `−P(−1)`.
* `Physics.GradedTransitivity.laurentMoment_natDegree` — the leading principal coefficient is
  `(−1)^{deg P+1} Δ^{deg P} P(0)`, in particular nonzero for `P ≠ 0`.
* `Physics.GradedTransitivity.circleIntegral_moment_of_eventually_polynomial` — only the tail
  of the grade count matters.
-/

namespace Physics.GradedTransitivity

open Finset Polynomial Complex Filter Topology

/-! ### The moments of one binomial basis element -/

/-- **The `j`-th Laurent moment of a binomial basis element.**  Around `q = 1`,

  `∮ (z−1)^j · zᵏ/(1−z)^{k+1} = (−1)^{k+1} C(k,j) · 2πi`.

For `j = 0` this is `circleIntegral_choose_term`. -/
theorem circleIntegral_choose_term_moment (j k : ℕ) {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), (z - 1) ^ j * (z ^ k / (1 - z) ^ (k + 1)))
      = (-1) ^ (k + 1) * (k.choose j : ℂ) * (2 * (Real.pi : ℂ) * I) := by
  have hs := sub_one_ne_zero_of_mem_sphere (ρ := ρ) hρ
  have hEq : Set.EqOn (fun z : ℂ => (z - 1) ^ j * (z ^ k / (1 - z) ^ (k + 1)))
      (fun z : ℂ => ∑ i ∈ range (k + 1),
        ((-1 : ℂ) ^ (k + 1) * (k.choose i : ℂ)) * (z - 1) ^ ((i : ℤ) + j - (k + 1)))
      (Metric.sphere (1 : ℂ) ρ) := by
    intro z hz
    have hz0 : z - 1 ≠ 0 := hs z hz
    have hnum : z ^ k = ∑ i ∈ range (k + 1), (z - 1) ^ i * (k.choose i : ℂ) := by
      simpa using add_pow (z - 1) (1 : ℂ) k
    have hden : (1 - z) ^ (k + 1) = (-1 : ℂ) ^ (k + 1) * (z - 1) ^ (k + 1) := by
      rw [← neg_sub z 1, neg_pow]
    have hsq : ((-1 : ℂ) ^ (k + 1)) * ((-1 : ℂ) ^ (k + 1)) = 1 := by
      rw [← pow_add, ← two_mul, pow_mul]; norm_num
    have hinv : ((-1 : ℂ) ^ (k + 1))⁻¹ = (-1 : ℂ) ^ (k + 1) := inv_eq_of_mul_eq_one_right hsq
    simp only [hnum, hden, Finset.sum_div, Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hzp : (z - 1) ^ ((i : ℤ) + j - (k + 1))
        = (z - 1) ^ i * (z - 1) ^ j / (z - 1) ^ (k + 1) := by
      rw [show ((i : ℤ) + j - (k + 1)) = ((i : ℤ) + j) - ((k : ℤ) + 1) by ring,
        zpow_sub₀ hz0, zpow_add₀ hz0]
      norm_cast
    rw [hzp, div_eq_mul_inv, mul_inv, hinv, div_eq_mul_inv]
    ring
  have hint : ∀ i ∈ range (k + 1), CircleIntegrable
      (fun z : ℂ => ((-1 : ℂ) ^ (k + 1) * (k.choose i : ℂ)) * (z - 1) ^ ((i : ℤ) + j - (k + 1)))
      1 ρ := by
    intro i _
    refine ContinuousOn.circleIntegrable hρ.le ?_
    exact continuousOn_const.mul
      ((continuousOn_id.sub continuousOn_const).zpow₀ _ fun z hz => Or.inl (hs z hz))
  rw [circleIntegral.integral_congr hρ.le hEq, circleIntegral.integral_fun_sum hint]
  by_cases hjk : j ≤ k
  · -- the surviving term is `i = k − j`
    rw [Finset.sum_eq_single (k - j)]
    · have h1 : ((k - j : ℕ) : ℤ) + j - (k + 1) = -1 := by omega
      have hsmul := circleIntegral.integral_smul (E := ℂ)
        ((-1 : ℂ) ^ (k + 1) * (k.choose (k - j) : ℂ))
        (fun z : ℂ => (z - 1) ^ (((k - j : ℕ) : ℤ) + j - (k + 1))) 1 ρ
      simp only [smul_eq_mul] at hsmul
      rw [hsmul, h1]
      simp only [zpow_neg, zpow_one]
      rw [circleIntegral.integral_sub_inv_of_mem_ball (Metric.mem_ball_self hρ),
        Nat.choose_symm hjk]
    · intro i _ hik
      have hne : ((i : ℤ) + j - (k + 1)) ≠ -1 := by
        intro h
        exact hik (by omega)
      have hsmul := circleIntegral.integral_smul (E := ℂ)
        ((-1 : ℂ) ^ (k + 1) * (k.choose i : ℂ))
        (fun z : ℂ => (z - 1) ^ ((i : ℤ) + j - (k + 1))) 1 ρ
      simp only [smul_eq_mul] at hsmul
      rw [hsmul, circleIntegral.integral_sub_zpow_of_ne hne]
      simp
    · intro h
      exact absurd (Finset.mem_range.mpr (by omega)) h
  · -- no term survives, and the binomial coefficient vanishes as well
    push_neg at hjk
    have hzero : ∀ i ∈ range (k + 1),
        (∮ z in C((1 : ℂ), ρ),
          ((-1 : ℂ) ^ (k + 1) * (k.choose i : ℂ)) * (z - 1) ^ ((i : ℤ) + j - (k + 1))) = 0 := by
      intro i _
      have hne : ((i : ℤ) + j - (k + 1)) ≠ -1 := by omega
      have hsmul := circleIntegral.integral_smul (E := ℂ)
        ((-1 : ℂ) ^ (k + 1) * (k.choose i : ℂ))
        (fun z : ℂ => (z - 1) ^ ((i : ℤ) + j - (k + 1))) 1 ρ
      simp only [smul_eq_mul] at hsmul
      rw [hsmul, circleIntegral.integral_sub_zpow_of_ne hne]
      simp
    rw [Finset.sum_congr rfl hzero, Finset.sum_const_zero,
      Nat.choose_eq_zero_of_lt hjk]
    simp

/-! ### The moment functional of a polynomial grade count -/

/-- The `j`-th **Laurent moment** of a polynomial grade count: the coefficient of
`(q − 1)^{−(j+1)}` in the expansion of the partition function at `q = 1`, expressed as a
finite-difference functional of `P`. -/
noncomputable def laurentMoment (P : Polynomial ℂ) (j : ℕ) : ℂ :=
  ∑ k ∈ range (P.natDegree + 1), (-1) ^ (k + 1) * (k.choose j : ℂ) * newtonCoeff P k

/-- **The moments of the partition function of a polynomial grade count.** -/
theorem circleIntegral_polyZeta_moment (P : Polynomial ℂ) (j : ℕ) {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), (z - 1) ^ j * polyZeta P z)
      = laurentMoment P j * (2 * (Real.pi : ℂ) * I) := by
  have hs := sub_one_ne_zero_of_mem_sphere (ρ := ρ) hρ
  have hEq : Set.EqOn (fun z : ℂ => (z - 1) ^ j * polyZeta P z)
      (fun z : ℂ => ∑ k ∈ range (P.natDegree + 1),
        newtonCoeff P k * ((z - 1) ^ j * (z ^ k / (1 - z) ^ (k + 1))))
      (Metric.sphere (1 : ℂ) ρ) := by
    intro z _
    simp only [polyZeta, Finset.mul_sum]
    exact Finset.sum_congr rfl fun k _ => by ring
  have hint : ∀ k ∈ range (P.natDegree + 1), CircleIntegrable
      (fun z : ℂ => newtonCoeff P k * ((z - 1) ^ j * (z ^ k / (1 - z) ^ (k + 1)))) 1 ρ := by
    intro k _
    refine ContinuousOn.circleIntegrable hρ.le (continuousOn_const.mul ?_)
    refine ContinuousOn.mul ((continuousOn_id.sub continuousOn_const).pow j) ?_
    refine ContinuousOn.div (continuousOn_id.pow k)
      ((continuousOn_const.sub continuousOn_id).pow (k + 1)) fun z hz => ?_
    exact pow_ne_zero _ (fun h => hs z hz (by linear_combination -h))
  have hterm : ∀ k ∈ range (P.natDegree + 1),
      (∮ z in C((1 : ℂ), ρ), newtonCoeff P k * ((z - 1) ^ j * (z ^ k / (1 - z) ^ (k + 1))))
        = newtonCoeff P k * ((-1) ^ (k + 1) * (k.choose j : ℂ) * (2 * (Real.pi : ℂ) * I)) := by
    intro k _
    have hsmul := circleIntegral.integral_smul (E := ℂ) (newtonCoeff P k)
      (fun z : ℂ => (z - 1) ^ j * (z ^ k / (1 - z) ^ (k + 1))) 1 ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, circleIntegral_choose_term_moment j k hρ]
  rw [circleIntegral.integral_congr hρ.le hEq, circleIntegral.integral_fun_sum hint,
    Finset.sum_congr rfl hterm, laurentMoment, Finset.sum_mul]
  exact Finset.sum_congr rfl fun k _ => by ring

/-- **Consistency with the residue.**  The zeroth moment is the residue `−P(−1)`. -/
theorem laurentMoment_zero (P : Polynomial ℂ) : laurentMoment P 0 = -P.eval (-1) := by
  rw [laurentMoment, eval_neg_one_eq_alternating P, ← Finset.sum_neg_distrib]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [Nat.choose_zero_right, pow_succ]
  push_cast
  ring

/-- **The principal part terminates.**  Moments beyond the degree of `P` vanish, matching the
independently computed pole order `deg P + 1`. -/
theorem laurentMoment_eq_zero_of_lt {P : Polynomial ℂ} {j : ℕ} (hj : P.natDegree < j) :
    laurentMoment P j = 0 := by
  refine Finset.sum_eq_zero fun k hk => ?_
  have hkj : k < j := lt_of_le_of_lt (Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)) hj
  rw [Nat.choose_eq_zero_of_lt hkj]
  simp

/-- **The leading principal coefficient.**  The top moment is `(−1)^{deg P+1} Δ^{deg P} P(0)`,
which is nonzero for `P ≠ 0`: the pole really has order `deg P + 1`. -/
theorem laurentMoment_natDegree (P : Polynomial ℂ) :
    laurentMoment P P.natDegree
      = (-1) ^ (P.natDegree + 1) * newtonCoeff P P.natDegree := by
  rw [laurentMoment, Finset.sum_eq_single P.natDegree]
  · rw [Nat.choose_self]
    push_cast
    ring
  · intro k hk hne
    have hkd : k < P.natDegree := by
      have := Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
      omega
    rw [Nat.choose_eq_zero_of_lt hkd]
    simp
  · intro h
    exact absurd (Finset.self_mem_range_succ P.natDegree) h

theorem laurentMoment_natDegree_ne_zero {P : Polynomial ℂ} (hP : P ≠ 0) :
    laurentMoment P P.natDegree ≠ 0 := by
  rw [laurentMoment_natDegree]
  exact mul_ne_zero (pow_ne_zero _ (neg_ne_zero.mpr one_ne_zero))
    (newtonCoeff_natDegree_ne_zero hP)

/-! ### Tail-only invariance -/

/-- **The moments only see the tail.**  If a grade count agrees with a polynomial `P` from some
grade on, then every analytic continuation of its generating function to `ℂ \ {1}` has the same
Laurent moments as `polyZeta P`; the finitely many exceptional grades contribute nothing, since
`(z−1)^j` times an entire function integrates to zero. -/
theorem circleIntegral_moment_of_eventually_polynomial {a : ℕ → ℂ} {P : Polynomial ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (j : ℕ) {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), (z - 1) ^ j * F z)
      = laurentMoment P j * (2 * (Real.pi : ℂ) * I) := by
  classical
  set D : ℂ → ℂ := tailCorrection a P N with hD
  have hDdiff : Differentiable ℂ D := differentiable_tailCorrection a P N
  have hEqF : Set.EqOn F (fun q => D q + polyZeta P q) {(1 : ℂ)}ᶜ :=
    eqOn_tailCorrection_add_polyZeta hcoef hF hF0
  have hs := sub_one_ne_zero_of_mem_sphere (ρ := ρ) hρ
  have hsub : Metric.sphere (1 : ℂ) ρ ⊆ {(1 : ℂ)}ᶜ := by
    intro z hz
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    exact sub_ne_zero.mp (hs z hz)
  have hEq : Set.EqOn (fun z : ℂ => (z - 1) ^ j * F z)
      (fun z : ℂ => (z - 1) ^ j * D z + (z - 1) ^ j * polyZeta P z)
      (Metric.sphere (1 : ℂ) ρ) := by
    intro z hz
    have h : F z = D z + polyZeta P z := hEqF (hsub hz)
    show (z - 1) ^ j * F z = (z - 1) ^ j * D z + (z - 1) ^ j * polyZeta P z
    rw [h]
    ring
  have hEntire : Differentiable ℂ (fun z : ℂ => (z - 1) ^ j * D z) := by
    exact (Differentiable.pow (differentiable_id.sub_const 1) j).mul hDdiff
  have hintD : CircleIntegrable (fun z : ℂ => (z - 1) ^ j * D z) 1 ρ :=
    hEntire.continuous.continuousOn.circleIntegrable hρ.le
  have hintZ : CircleIntegrable (fun z : ℂ => (z - 1) ^ j * polyZeta P z) 1 ρ := by
    refine ContinuousOn.circleIntegrable hρ.le ?_
    refine ContinuousOn.mul ((continuousOn_id.sub continuousOn_const).pow j) fun z hz => ?_
    exact ((analyticOnNhd_polyZeta P _ (hsub hz)).continuousAt).continuousWithinAt
  have hD0 : (∮ z in C((1 : ℂ), ρ), (z - 1) ^ j * D z) = 0 :=
    Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le Set.countable_empty
      hEntire.continuous.continuousOn fun z _ => hEntire z
  rw [circleIntegral.integral_congr hρ.le hEq,
    circleIntegral.integral_add hintD hintZ, hD0, zero_add,
    circleIntegral_polyZeta_moment P j hρ]

end Physics.GradedTransitivity