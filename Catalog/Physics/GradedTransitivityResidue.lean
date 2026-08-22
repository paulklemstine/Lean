import Physics.GradedTransitivityComplex

/-!
# Zeta-regularised residues: polynomial grade counts and the value at `q = −1`

`Physics.GradedTransitivityComplex` continued the transitivity partition function — whose
coefficients are *eventually constant* — to `ℂ \ {1}` and computed its residue, the universal
constant `−1`.  This file treats the general situation of the catalogue's rationality
theorems (`Physics.GradedTransitivityCore.denom_of_eventually_polynomial`): coefficient
sequences that are eventually given by a **polynomial** `P` of degree `d`.

Two things happen at once:

* the singularity at `q = 1` is a pole of order exactly `d + 1` (Theorem
  `order_polyZeta`), and
* its residue is **`−P(−1)`** (Theorem `circleIntegral_polyZeta`).

The second statement is the surprise: the residue of the partition function at the
"infinite-temperature" point `q = 1` is the value of the grade-counting polynomial at the
*negative* integer `−1` — a zeta-regularisation phenomenon, obtained here by an honest
contour integral rather than by formal manipulation.  The mechanism is a bridge between two
different worlds: the Gregory–Newton finite-difference expansion `P = ∑ₖ Δᵏ P(0)·binom k`
(combinatorics) and the Laurent expansion of `qᵏ/(1−q)^{k+1}` at `q = 1` (complex analysis).
Each binomial basis element contributes exactly `(−1)^{k+1}` to the residue, and Newton's
formula evaluated at `−1` reassembles these signs into `−P(−1)`.

For `P = 1` (the eventually transitive case) this gives residue `−1`, recovering
`Physics.GradedTransitivity.circleIntegral_transCount`.

## Main results

* `Physics.GradedTransitivity.binomPoly` — the binomial polynomial `X choose k`.
* `Physics.GradedTransitivity.newton_eval_natCast`, `newton_polynomial_eq`,
  `eval_neg_one_eq_alternating` — the Gregory–Newton expansion of a complex polynomial and
  its evaluation at `−1`.
* `Physics.GradedTransitivity.hasSum_choose_pow` — `∑ₙ C(n,k) qⁿ = qᵏ/(1−q)^{k+1}`.
* `Physics.GradedTransitivity.polyZeta`, `tsum_polyZeta` — the closed form of
  `∑ₙ P(n) qⁿ` and the fact that it sums the series on the unit disc.
* `Physics.GradedTransitivity.circleIntegral_polyZeta` — the residue computation
  `∮_{|q−1|=ρ} = −2πi·P(−1)`.
* `Physics.GradedTransitivity.order_polyZeta` — the pole has order exactly `deg P + 1`.
* `Physics.GradedTransitivity.circleIntegral_of_eventually_polynomial` — the residue of any
  analytic continuation of a generating function with eventually polynomial coefficients is
  `−P(−1)`: only the tail matters.
* `Physics.GradedTransitivity.circleIntegral_eventually_one` — consistency with the
  eventually transitive case: residue `−1`.
-/

namespace Physics.GradedTransitivity

open Finset Polynomial Complex Filter Topology

/-! ### Gregory–Newton expansion -/

/-- The binomial polynomial `X choose k = X(X−1)⋯(X−k+1)/k!` over `ℂ`. -/
noncomputable def binomPoly (k : ℕ) : Polynomial ℂ :=
  Polynomial.C ((Nat.factorial k : ℂ)⁻¹) * descPochhammer ℂ k

@[simp] theorem binomPoly_eval_natCast (k n : ℕ) : (binomPoly k).eval (n : ℂ) = (n.choose k : ℂ) := by
  rw [binomPoly, eval_mul, eval_C, Nat.cast_choose_eq_descPochhammer_div ℂ n k]
  field_simp

/-- The binomial polynomial at `−1` alternates: `(−1 choose k) = (−1)^k`. -/
@[simp] theorem binomPoly_eval_neg_one (k : ℕ) : (binomPoly k).eval (-1) = (-1 : ℂ) ^ k := by
  have h : (descPochhammer ℂ k).eval (-1) = (-1 : ℂ) ^ k * (Nat.factorial k : ℂ) := by
    induction k with
    | zero => simp
    | succ k ih =>
      rw [descPochhammer_succ_right]
      simp [ih, Nat.factorial_succ]
      ring
  have hk : (Nat.factorial k : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero k)
  rw [binomPoly, eval_mul, eval_C, h]
  field_simp

/-- The `k`-th Newton coefficient `Δᵏ P (0)` of a complex polynomial. -/
noncomputable def newtonCoeff (P : Polynomial ℂ) (k : ℕ) : ℂ := (fwdDiff (1 : ℂ))^[k] P.eval 0

/-- **Gregory–Newton formula, truncated at the degree.**  For every natural `n`,
`P(n) = ∑_{k ≤ deg P} C(n,k) · Δᵏ P(0)`. -/
theorem newton_eval_natCast (P : Polynomial ℂ) (n : ℕ) :
    P.eval (n : ℂ) = ∑ k ∈ range (P.natDegree + 1), (n.choose k : ℂ) * newtonCoeff P k := by
  have hn : P.eval (n : ℂ)
      = ∑ k ∈ range (n + 1), (n.choose k : ℂ) * newtonCoeff P k := by
    have := shift_eq_sum_fwdDiff_iter (h := (1 : ℂ)) (M := ℂ) (G := ℂ) P.eval n 0
    simp only [zero_add, nsmul_eq_mul, mul_one] at this
    simpa [newtonCoeff] using this
  set d := P.natDegree with hd
  have h1 : ∑ k ∈ range (max n d + 1), (n.choose k : ℂ) * newtonCoeff P k = P.eval (n : ℂ) := by
    rw [hn]
    refine (Finset.sum_subset (Finset.range_mono (Nat.succ_le_succ (le_max_left n d))) ?_).symm
    intro k _ hk
    have hnk : n < k := by simpa using hk
    simp [Nat.choose_eq_zero_of_lt hnk]
  have h2 : ∑ k ∈ range (max n d + 1), (n.choose k : ℂ) * newtonCoeff P k
      = ∑ k ∈ range (d + 1), (n.choose k : ℂ) * newtonCoeff P k := by
    refine (Finset.sum_subset (Finset.range_mono (Nat.succ_le_succ (le_max_right n d))) ?_).symm
    intro k _ hk
    have hkd : d < k := by simpa using hk
    have hz := congrFun (Polynomial.fwdDiff_iter_eq_zero_of_degree_lt (P := P) (n := k) hkd) 0
    simp [newtonCoeff, hz]
  rw [← h2, h1]

/-- **Gregory–Newton as an identity of polynomials.** -/
theorem newton_polynomial_eq (P : Polynomial ℂ) :
    P = ∑ k ∈ range (P.natDegree + 1), Polynomial.C (newtonCoeff P k) * binomPoly k := by
  have hinj : Function.Injective (fun n : ℕ => (n : ℂ)) := fun m n h => Nat.cast_injective h
  refine Polynomial.eq_of_infinite_eval_eq _ _
    (Set.Infinite.mono ?_ (Set.infinite_range_of_injective hinj))
  rintro _ ⟨n, rfl⟩
  simp only [Set.mem_setOf_eq, eval_finset_sum, eval_mul, eval_C, binomPoly_eval_natCast]
  rw [newton_eval_natCast P n]
  exact Finset.sum_congr rfl fun k _ => mul_comm _ _

/-- **Newton's formula at `−1`.**  The alternating sum of the Newton coefficients is the value
of the polynomial at `−1`. -/
theorem eval_neg_one_eq_alternating (P : Polynomial ℂ) :
    P.eval (-1) = ∑ k ∈ range (P.natDegree + 1), (-1 : ℂ) ^ k * newtonCoeff P k := by
  conv_lhs => rw [newton_polynomial_eq P]
  simp only [eval_finset_sum, eval_mul, eval_C, binomPoly_eval_neg_one]
  exact Finset.sum_congr rfl fun k _ => mul_comm _ _

/-! ### The analytic closed form -/

/-- `∑ₙ C(n,k) qⁿ = qᵏ/(1−q)^{k+1}` on the open unit disc. -/
theorem hasSum_choose_pow (k : ℕ) {q : ℂ} (hq : ‖q‖ < 1) :
    HasSum (fun n : ℕ => (n.choose k : ℂ) * q ^ n) (q ^ k / (1 - q) ^ (k + 1)) := by
  have h0 := (hasSum_choose_mul_geometric_of_norm_lt_one (𝕜 := ℂ) k hq).mul_left (q ^ k)
  have hshift : HasSum (fun n : ℕ => ((n + k).choose k : ℂ) * q ^ (n + k))
      (q ^ k * (1 / (1 - q) ^ (k + 1))) := by
    refine h0.congr_fun ?_
    intro n
    rw [pow_add]
    ring
  have hz : ∑ i ∈ range k, ((i.choose k : ℂ) * q ^ i) = 0 := by
    refine Finset.sum_eq_zero fun i hi => ?_
    rw [Nat.choose_eq_zero_of_lt (Finset.mem_range.mp hi)]
    simp
  have hmain := (hasSum_nat_add_iff (f := fun n : ℕ => (n.choose k : ℂ) * q ^ n) k).mp hshift
  rw [hz, add_zero] at hmain
  convert hmain using 1
  field_simp

/-- The closed form of the partition function `∑ₙ P(n) qⁿ` of a polynomial grade count. -/
noncomputable def polyZeta (P : Polynomial ℂ) (q : ℂ) : ℂ :=
  ∑ k ∈ range (P.natDegree + 1), newtonCoeff P k * (q ^ k / (1 - q) ^ (k + 1))

/-- **The partition function of a polynomial grade count.**  On the open unit disc the series
`∑ₙ P(n) qⁿ` converges to `polyZeta P`. -/
theorem tsum_polyZeta (P : Polynomial ℂ) {q : ℂ} (hq : ‖q‖ < 1) :
    ∑' n : ℕ, P.eval (n : ℂ) * q ^ n = polyZeta P q := by
  have hsum : HasSum (fun n : ℕ => ∑ k ∈ range (P.natDegree + 1),
      newtonCoeff P k * ((n.choose k : ℂ) * q ^ n)) (polyZeta P q) :=
    hasSum_sum fun k _ => (hasSum_choose_pow k hq).mul_left (newtonCoeff P k)
  have hfun : (fun n : ℕ => P.eval (n : ℂ) * q ^ n)
      = fun n : ℕ => ∑ k ∈ range (P.natDegree + 1),
          newtonCoeff P k * ((n.choose k : ℂ) * q ^ n) := by
    funext n
    rw [newton_eval_natCast P n, Finset.sum_mul]
    exact Finset.sum_congr rfl fun k _ => by ring
  rw [hfun]
  exact hsum.tsum_eq

/-- `polyZeta P` is analytic away from `q = 1`. -/
theorem analyticOnNhd_polyZeta (P : Polynomial ℂ) :
    AnalyticOnNhd ℂ (polyZeta P) {(1 : ℂ)}ᶜ := by
  refine DifferentiableOn.analyticOnNhd (fun q hq => ?_) isOpen_compl_singleton
  have h2 : (1 : ℂ) - q ≠ 0 := by
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff] at hq
    exact fun h => hq (by linear_combination -h)
  apply DifferentiableAt.differentiableWithinAt
  unfold polyZeta
  refine DifferentiableAt.fun_sum fun k _ => ?_
  have hpow : (1 - q) ^ (k + 1) ≠ 0 := pow_ne_zero _ h2
  fun_prop (disch := assumption)

/-! ### The residue computation -/

/-- The Laurent term `qᵏ/(1−q)^{k+1}` integrates to `(−1)^{k+1}·2πi` around `q = 1`: each
binomial basis element carries a *unit* residue, with an alternating sign. -/
theorem circleIntegral_choose_term (k : ℕ) {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), z ^ k / (1 - z) ^ (k + 1))
      = (-1) ^ (k + 1) * (2 * (Real.pi : ℂ) * I) := by
  have hs := sub_one_ne_zero_of_mem_sphere (ρ := ρ) hρ
  have hEq : Set.EqOn (fun z : ℂ => z ^ k / (1 - z) ^ (k + 1))
      (fun z : ℂ => ∑ j ∈ range (k + 1),
        ((-1 : ℂ) ^ (k + 1) * (k.choose j : ℂ)) * (z - 1) ^ ((j : ℤ) - (k + 1)))
      (Metric.sphere (1 : ℂ) ρ) := by
    intro z hz
    have hz0 : z - 1 ≠ 0 := hs z hz
    have hnum : z ^ k = ∑ j ∈ range (k + 1), (z - 1) ^ j * (k.choose j : ℂ) := by
      simpa using add_pow (z - 1) (1 : ℂ) k
    have hden : (1 - z) ^ (k + 1) = (-1 : ℂ) ^ (k + 1) * (z - 1) ^ (k + 1) := by
      rw [← neg_sub z 1, neg_pow]
    have hsq : ((-1 : ℂ) ^ (k + 1)) * ((-1 : ℂ) ^ (k + 1)) = 1 := by
      rw [← pow_add, ← two_mul, pow_mul]; norm_num
    have hinv : ((-1 : ℂ) ^ (k + 1))⁻¹ = (-1 : ℂ) ^ (k + 1) := inv_eq_of_mul_eq_one_right hsq
    simp only [hnum, hden, Finset.sum_div]
    refine Finset.sum_congr rfl fun j _ => ?_
    have hzp : (z - 1) ^ ((j : ℤ) - (k + 1)) = (z - 1) ^ j / (z - 1) ^ (k + 1) := by
      rw [zpow_sub₀ hz0]; norm_cast
    rw [hzp, div_eq_mul_inv, mul_inv, hinv, div_eq_mul_inv]
    ring
  have hint : ∀ j ∈ range (k + 1), CircleIntegrable
      (fun z : ℂ => ((-1 : ℂ) ^ (k + 1) * (k.choose j : ℂ)) * (z - 1) ^ ((j : ℤ) - (k + 1)))
      1 ρ := by
    intro j _
    refine ContinuousOn.circleIntegrable hρ.le ?_
    exact continuousOn_const.mul
      ((continuousOn_id.sub continuousOn_const).zpow₀ _ fun z hz => Or.inl (hs z hz))
  rw [circleIntegral.integral_congr hρ.le hEq, circleIntegral.integral_fun_sum hint,
    Finset.sum_eq_single k]
  · have h1 : ((k : ℤ) - (k + 1)) = -1 := by ring
    have hsmul := circleIntegral.integral_smul (E := ℂ)
      ((-1 : ℂ) ^ (k + 1) * (k.choose k : ℂ)) (fun z : ℂ => (z - 1) ^ ((k : ℤ) - (k + 1))) 1 ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, h1]
    simp only [zpow_neg, zpow_one]
    rw [circleIntegral.integral_sub_inv_of_mem_ball (Metric.mem_ball_self hρ)]
    simp
  · intro j _ hjk
    have hne : ((j : ℤ) - (k + 1)) ≠ -1 := by intro h; exact hjk (by omega)
    have hsmul := circleIntegral.integral_smul (E := ℂ)
      ((-1 : ℂ) ^ (k + 1) * (k.choose j : ℂ)) (fun z : ℂ => (z - 1) ^ ((j : ℤ) - (k + 1))) 1 ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, circleIntegral.integral_sub_zpow_of_ne hne]
    simp
  · intro h
    exact absurd (Finset.self_mem_range_succ k) h

/-- **The zeta-regularised residue.**  The residue at `q = 1` of the partition function of a
polynomial grade count `P` is `−P(−1)`. -/
theorem circleIntegral_polyZeta (P : Polynomial ℂ) {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), polyZeta P z) = -P.eval (-1) * (2 * (Real.pi : ℂ) * I) := by
  have hs := sub_one_ne_zero_of_mem_sphere (ρ := ρ) hρ
  have hint : ∀ k ∈ range (P.natDegree + 1), CircleIntegrable
      (fun z : ℂ => newtonCoeff P k * (z ^ k / (1 - z) ^ (k + 1))) 1 ρ := by
    intro k _
    refine ContinuousOn.circleIntegrable hρ.le (continuousOn_const.mul ?_)
    refine ContinuousOn.div (continuousOn_id.pow k)
      ((continuousOn_const.sub continuousOn_id).pow (k + 1)) fun z hz => ?_
    exact pow_ne_zero _ (fun h => hs z hz (by linear_combination -h))
  have hterm : ∀ k ∈ range (P.natDegree + 1),
      (∮ z in C((1 : ℂ), ρ), newtonCoeff P k * (z ^ k / (1 - z) ^ (k + 1)))
        = newtonCoeff P k * ((-1) ^ (k + 1) * (2 * (Real.pi : ℂ) * I)) := by
    intro k _
    have hsmul := circleIntegral.integral_smul (E := ℂ) (newtonCoeff P k)
      (fun z : ℂ => z ^ k / (1 - z) ^ (k + 1)) 1 ρ
    simp only [smul_eq_mul] at hsmul
    rw [hsmul, circleIntegral_choose_term k hρ]
  calc (∮ z in C((1 : ℂ), ρ), polyZeta P z)
      = ∑ k ∈ range (P.natDegree + 1),
          ∮ z in C((1 : ℂ), ρ), newtonCoeff P k * (z ^ k / (1 - z) ^ (k + 1)) :=
        circleIntegral.integral_fun_sum hint
    _ = ∑ k ∈ range (P.natDegree + 1),
          newtonCoeff P k * ((-1) ^ (k + 1) * (2 * (Real.pi : ℂ) * I)) :=
        Finset.sum_congr rfl hterm
    _ = -(∑ k ∈ range (P.natDegree + 1), (-1 : ℂ) ^ k * newtonCoeff P k)
          * (2 * (Real.pi : ℂ) * I) := by
        rw [neg_mul, Finset.sum_mul, ← Finset.sum_neg_distrib]
        exact Finset.sum_congr rfl fun k _ => by rw [pow_succ]; ring
    _ = -P.eval (-1) * (2 * (Real.pi : ℂ) * I) := by rw [← eval_neg_one_eq_alternating P]

/-! ### The order of the pole -/

/-- The numerator of `polyZeta P` over the common denominator `(1 − q)^{deg P + 1}`. -/
noncomputable def polyZetaNum (P : Polynomial ℂ) (q : ℂ) : ℂ :=
  ∑ k ∈ range (P.natDegree + 1), newtonCoeff P k * q ^ k * (1 - q) ^ (P.natDegree - k)

theorem differentiable_polyZetaNum (P : Polynomial ℂ) : Differentiable ℂ (polyZetaNum P) := by
  unfold polyZetaNum
  exact Differentiable.fun_sum fun k _ => by fun_prop

/-- Clearing denominators: `polyZeta P = polyZetaNum P /(1 − q)^{deg P + 1}` off `q = 1`. -/
theorem polyZeta_eq_num_div {P : Polynomial ℂ} {q : ℂ} (hq : q ≠ 1) :
    polyZeta P q = polyZetaNum P q / (1 - q) ^ (P.natDegree + 1) := by
  have h2 : (1 : ℂ) - q ≠ 0 := fun h => hq (by linear_combination -h)
  unfold polyZeta polyZetaNum
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk' : k ≤ P.natDegree := Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
  have hsplit : (1 - q) ^ (P.natDegree + 1) = (1 - q) ^ (k + 1) * (1 - q) ^ (P.natDegree - k) := by
    rw [← pow_add]
    congr 1
    omega
  rw [hsplit]
  field_simp

/-- At the singularity the numerator takes the value `Δ^{deg P} P(0) = (lead P)·(deg P)!`. -/
theorem polyZetaNum_eval_one (P : Polynomial ℂ) :
    polyZetaNum P 1 = newtonCoeff P P.natDegree := by
  unfold polyZetaNum
  rw [Finset.sum_eq_single P.natDegree]
  · simp
  · intro k hk hne
    have hk' : k < P.natDegree := lt_of_le_of_ne (Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)) hne
    have : P.natDegree - k ≠ 0 := by omega
    simp [zero_pow this]
  · intro h
    exact absurd (Finset.self_mem_range_succ P.natDegree) h

/-- The top Newton coefficient is `(leading coefficient) · (degree)!`, hence nonzero for a
nonzero polynomial. -/
theorem newtonCoeff_natDegree_ne_zero {P : Polynomial ℂ} (hP : P ≠ 0) :
    newtonCoeff P P.natDegree ≠ 0 := by
  have h := congrFun (Polynomial.fwdDiff_iter_degree_eq_factorial P) 0
  simp only [Pi.smul_apply, smul_eq_mul, Pi.natCast_apply] at h
  rw [newtonCoeff, h]
  exact mul_ne_zero (Polynomial.leadingCoeff_ne_zero.mpr hP)
    (Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero _))

theorem meromorphicAt_polyZeta (P : Polynomial ℂ) : MeromorphicAt (polyZeta P) 1 := by
  refine ⟨P.natDegree + 2, ?_⟩
  have hfun : (fun z => (z - 1) ^ (P.natDegree + 2) • polyZeta P z)
      = fun z => (z - 1) * ((-1) ^ (P.natDegree + 1) * polyZetaNum P z) := by
    funext z
    rcases eq_or_ne z 1 with rfl | hz
    · simp
    · have hz0 : z - 1 ≠ 0 := sub_ne_zero.mpr hz
      have hden : (1 - z) ^ (P.natDegree + 1)
          = (-1 : ℂ) ^ (P.natDegree + 1) * (z - 1) ^ (P.natDegree + 1) := by
        rw [← neg_sub z 1, neg_pow]
      have hsq : ((-1 : ℂ) ^ (P.natDegree + 1)) * ((-1 : ℂ) ^ (P.natDegree + 1)) = 1 := by
        rw [← pow_add, ← two_mul, pow_mul]; norm_num
      have hinv : ((-1 : ℂ) ^ (P.natDegree + 1))⁻¹ = (-1 : ℂ) ^ (P.natDegree + 1) :=
        inv_eq_of_mul_eq_one_right hsq
      have hcancel : (z - 1) ^ (P.natDegree + 1) * ((z - 1) ^ (P.natDegree + 1))⁻¹ = 1 :=
        mul_inv_cancel₀ (pow_ne_zero _ hz0)
      rw [polyZeta_eq_num_div hz, smul_eq_mul, hden, div_eq_mul_inv, mul_inv, hinv]
      calc (z - 1) ^ (P.natDegree + 2)
            * (polyZetaNum P z * ((-1 : ℂ) ^ (P.natDegree + 1) * ((z - 1) ^ (P.natDegree + 1))⁻¹))
          = ((z - 1) ^ (P.natDegree + 1) * ((z - 1) ^ (P.natDegree + 1))⁻¹)
              * ((z - 1) * ((-1 : ℂ) ^ (P.natDegree + 1) * polyZetaNum P z)) := by ring
        _ = (z - 1) * ((-1 : ℂ) ^ (P.natDegree + 1) * polyZetaNum P z) := by rw [hcancel, one_mul]
  rw [hfun]
  have hd : Differentiable ℂ
      (fun z : ℂ => (z - 1) * ((-1) ^ (P.natDegree + 1) * polyZetaNum P z)) := by
    have := differentiable_polyZetaNum P
    fun_prop
  exact hd.analyticAt 1

/-- **The order of the pole is exactly `deg P + 1`.**  A grade count growing like a polynomial
of degree `d` produces a pole of order `d + 1` — the analytic counterpart of the catalogue's
formal statement that the denominator is `(1 − q)^{d+1}`. -/
theorem order_polyZeta {P : Polynomial ℂ} (hP : P ≠ 0) :
    meromorphicOrderAt (polyZeta P) 1 = ((-(P.natDegree + 1 : ℤ) : ℤ) : WithTop ℤ) := by
  rw [meromorphicOrderAt_eq_int_iff (meromorphicAt_polyZeta P)]
  refine ⟨fun z => (-1) ^ (P.natDegree + 1) * polyZetaNum P z, ?_, ?_, ?_⟩
  · have := differentiable_polyZetaNum P
    exact (by fun_prop : Differentiable ℂ
      (fun z : ℂ => (-1 : ℂ) ^ (P.natDegree + 1) * polyZetaNum P z)).analyticAt 1
  · show ((-1 : ℂ) ^ (P.natDegree + 1) * polyZetaNum P 1) ≠ 0
    rw [polyZetaNum_eval_one]
    exact mul_ne_zero (pow_ne_zero _ (by norm_num)) (newtonCoeff_natDegree_ne_zero hP)
  · filter_upwards [self_mem_nhdsWithin] with z hz
    have hz1 : z ≠ 1 := hz
    have hz0 : z - 1 ≠ 0 := sub_ne_zero.mpr hz1
    have hden : (1 - z) ^ (P.natDegree + 1)
        = (-1 : ℂ) ^ (P.natDegree + 1) * (z - 1) ^ (P.natDegree + 1) := by
      rw [← neg_sub z 1, neg_pow]
    have hsq : ((-1 : ℂ) ^ (P.natDegree + 1)) * ((-1 : ℂ) ^ (P.natDegree + 1)) = 1 := by
      rw [← pow_add, ← two_mul, pow_mul]; norm_num
    have hzpow : (z - 1) ^ (-(P.natDegree + 1 : ℤ)) = ((z - 1) ^ (P.natDegree + 1))⁻¹ := by
      rw [zpow_neg]
      norm_cast
    have hinv : ((-1 : ℂ) ^ (P.natDegree + 1))⁻¹ = (-1 : ℂ) ^ (P.natDegree + 1) :=
      inv_eq_of_mul_eq_one_right hsq
    rw [polyZeta_eq_num_div hz1, smul_eq_mul, hden, hzpow, div_eq_mul_inv, mul_inv, hinv]
    ring

/-! ### Continuations, and the tail-only nature of the residue -/

/-- Two functions analytic on `ℂ \ {1}` that agree near the origin agree everywhere off `1`. -/
theorem eqOn_compl_one_of_eventuallyEq {F H : ℂ → ℂ} (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hH : AnalyticOnNhd ℂ H {(1 : ℂ)}ᶜ) (h : F =ᶠ[𝓝 (0 : ℂ)] H) :
    Set.EqOn F H {(1 : ℂ)}ᶜ := by
  have h0 : (0 : ℂ) ∈ ({(1 : ℂ)}ᶜ : Set ℂ) := by
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    exact zero_ne_one
  exact hF.eqOn_of_preconnected_of_eventuallyEq hH isPreconnected_compl_one h0 h

/-- The polynomial correction accounting for the finitely many grades on which the coefficient
sequence differs from the polynomial `P`. -/
noncomputable def tailCorrection (a : ℕ → ℂ) (P : Polynomial ℂ) (N : ℕ) (q : ℂ) : ℂ :=
  ∑ n ∈ range N, (a n - P.eval (n : ℂ)) * q ^ n

theorem differentiable_tailCorrection (a : ℕ → ℂ) (P : Polynomial ℂ) (N : ℕ) :
    Differentiable ℂ (tailCorrection a P N) := by
  unfold tailCorrection
  exact Differentiable.fun_sum fun n _ => by fun_prop

/-- **Splitting off the exceptional grades.**  On the unit disc a generating function with
eventually polynomial coefficients is a polynomial correction plus `polyZeta P`. -/
theorem tsum_eq_tailCorrection_add_polyZeta {a : ℕ → ℂ} {P : Polynomial ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) {q : ℂ} (hq : ‖q‖ < 1) :
    ∑' n : ℕ, a n * q ^ n = tailCorrection a P N q + polyZeta P q := by
  classical
  have hP : HasSum (fun n : ℕ => P.eval (n : ℂ) * q ^ n) (polyZeta P q) := by
    have hsum : HasSum (fun n : ℕ => ∑ k ∈ range (P.natDegree + 1),
        newtonCoeff P k * ((n.choose k : ℂ) * q ^ n)) (polyZeta P q) :=
      hasSum_sum fun k _ => (hasSum_choose_pow k hq).mul_left (newtonCoeff P k)
    refine hsum.congr_fun fun n => ?_
    rw [newton_eval_natCast P n, Finset.sum_mul]
    exact Finset.sum_congr rfl fun k _ => by ring
  have he0 : ∀ n : ℕ, n ∉ range N → (a n - P.eval (n : ℂ)) * q ^ n = 0 := by
    intro n hn
    have hn' : N ≤ n := by simpa using hn
    simp [hcoef n hn']
  have hE : HasSum (fun n : ℕ => (a n - P.eval (n : ℂ)) * q ^ n) (tailCorrection a P N q) :=
    hasSum_sum_of_ne_finset_zero he0
  refine HasSum.tsum_eq ((hE.add hP).congr_fun fun n => ?_)
  ring

/-- **Existence of the continuation.**  A generating function with eventually polynomial
coefficients really does extend analytically to `ℂ \ {1}`, so the hypotheses of the residue
theorems below are never vacuous. -/
theorem exists_analytic_continuation {a : ℕ → ℂ} {P : Polynomial ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) :
    ∃ F : ℂ → ℂ, AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ ∧
      (∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) := by
  refine ⟨fun q => tailCorrection a P N q + polyZeta P q, ?_, ?_⟩
  · have hDan : AnalyticOnNhd ℂ (tailCorrection a P N) {(1 : ℂ)}ᶜ :=
      fun z _ => (differentiable_tailCorrection a P N).analyticAt z
    exact hDan.add (analyticOnNhd_polyZeta P)
  · filter_upwards [Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hball
    rw [tsum_eq_tailCorrection_add_polyZeta hcoef (by simpa using hball)]

/-- **The residue only sees the tail.**  If a coefficient sequence agrees with a polynomial `P`
from some index on, then every analytic continuation to `ℂ \ {1}` of its generating function
has residue `−P(−1)` at `q = 1`; the finitely many exceptional grades contribute nothing. -/
theorem circleIntegral_of_eventually_polynomial {a : ℕ → ℂ} {P : Polynomial ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), F z) = -P.eval (-1) * (2 * (Real.pi : ℂ) * I) := by
  classical
  set D : ℂ → ℂ := tailCorrection a P N with hD
  have hDdiff : Differentiable ℂ D := differentiable_tailCorrection a P N
  have hEq : Set.EqOn F (fun q => D q + polyZeta P q) {(1 : ℂ)}ᶜ := by
    have hDan : AnalyticOnNhd ℂ D {(1 : ℂ)}ᶜ := fun z _ => hDdiff.analyticAt z
    refine eqOn_compl_one_of_eventuallyEq hF (hDan.add (analyticOnNhd_polyZeta P)) ?_
    filter_upwards [hF0, Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hq hball
    rw [hq, tsum_eq_tailCorrection_add_polyZeta hcoef (by simpa using hball)]
  have hsub : Metric.sphere (1 : ℂ) ρ ⊆ {(1 : ℂ)}ᶜ := by
    intro z hz
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    exact sub_ne_zero.mp (sub_one_ne_zero_of_mem_sphere hρ z hz)
  have hintD : CircleIntegrable D 1 ρ := hDdiff.continuous.continuousOn.circleIntegrable hρ.le
  have hintZ : CircleIntegrable (polyZeta P) 1 ρ := by
    refine ContinuousOn.circleIntegrable hρ.le ?_
    intro z hz
    exact ((analyticOnNhd_polyZeta P _ (hsub hz)).continuousAt).continuousWithinAt
  have hD0 : (∮ z in C((1 : ℂ), ρ), D z) = 0 :=
    Complex.circleIntegral_eq_zero_of_differentiable_on_off_countable hρ.le Set.countable_empty
      hDdiff.continuous.continuousOn fun z _ => hDdiff z
  rw [circleIntegral.integral_congr hρ.le (hEq.mono hsub),
    circleIntegral.integral_add hintD hintZ, hD0, zero_add, circleIntegral_polyZeta P hρ]

/-- Every analytic continuation to `ℂ \ {1}` agrees off the singularity with the canonical
one, `tailCorrection + polyZeta`. -/
theorem eqOn_tailCorrection_add_polyZeta {a : ℕ → ℂ} {P : Polynomial ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) :
    Set.EqOn F (fun q => tailCorrection a P N q + polyZeta P q) {(1 : ℂ)}ᶜ := by
  have hDan : AnalyticOnNhd ℂ (tailCorrection a P N) {(1 : ℂ)}ᶜ :=
    fun z _ => (differentiable_tailCorrection a P N).analyticAt z
  refine eqOn_compl_one_of_eventuallyEq hF (hDan.add (analyticOnNhd_polyZeta P)) ?_
  filter_upwards [hF0, Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hq hball
  rw [hq, tsum_eq_tailCorrection_add_polyZeta hcoef (by simpa using hball)]

/-- **The pole order of any continuation is `deg P + 1`.**  The finitely many exceptional
grades are invisible to the order as well as to the residue. -/
theorem order_of_eventually_polynomial {a : ℕ → ℂ} {P : Polynomial ℂ} {N : ℕ} (hP : P ≠ 0)
    (hcoef : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) :
    meromorphicOrderAt F 1 = ((-(P.natDegree + 1 : ℤ) : ℤ) : WithTop ℤ) := by
  have hEq := eqOn_tailCorrection_add_polyZeta hcoef hF hF0
  have hgerm : F =ᶠ[𝓝[≠] (1 : ℂ)] (fun q => tailCorrection a P N q + polyZeta P q) := by
    filter_upwards [self_mem_nhdsWithin] with z hz
    exact hEq (by simpa using hz)
  have hDan : AnalyticAt ℂ (tailCorrection a P N) 1 :=
    (differentiable_tailCorrection a P N).analyticAt 1
  have hDorder : (0 : WithTop ℤ) ≤ meromorphicOrderAt (tailCorrection a P N) 1 :=
    hDan.meromorphicOrderAt_nonneg
  have hlt : meromorphicOrderAt (polyZeta P) 1 < meromorphicOrderAt (tailCorrection a P N) 1 := by
    rw [order_polyZeta hP]
    refine lt_of_lt_of_le ?_ hDorder
    have hneg : (-(P.natDegree + 1 : ℤ)) < 0 := by omega
    exact_mod_cast hneg
  rw [meromorphicOrderAt_congr hgerm,
    show (fun q => tailCorrection a P N q + polyZeta P q)
      = tailCorrection a P N + polyZeta P from rfl,
    meromorphicOrderAt_add_eq_right_of_lt hDan.meromorphicAt hlt, order_polyZeta hP]

/-- If the coefficients eventually vanish, the continuation has no pole at all: its order is
nonnegative. -/
theorem order_nonneg_of_eventually_zero {a : ℕ → ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = 0) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) :
    0 ≤ meromorphicOrderAt F 1 := by
  have hcoef' : ∀ n, N ≤ n → a n = (0 : Polynomial ℂ).eval (n : ℂ) := by
    intro n hn; simpa using hcoef n hn
  have hEq := eqOn_tailCorrection_add_polyZeta hcoef' hF hF0
  have hzero : polyZeta (0 : Polynomial ℂ) = fun _ => 0 := by
    funext q
    simp [polyZeta, newtonCoeff]
  have hgerm : F =ᶠ[𝓝[≠] (1 : ℂ)] tailCorrection a 0 N := by
    filter_upwards [self_mem_nhdsWithin] with z hz
    have := hEq (show z ∈ ({(1 : ℂ)}ᶜ : Set ℂ) by simpa using hz)
    simpa [hzero] using this
  rw [meromorphicOrderAt_congr hgerm]
  exact ((differentiable_tailCorrection a 0 N).analyticAt 1).meromorphicOrderAt_nonneg

/-- **Consistency with the eventually transitive case.**  Taking `P = 1` recovers the residue
`−1` of `Physics.GradedTransitivity.circleIntegral_transCount`. -/
theorem circleIntegral_eventually_one {a : ℕ → ℂ} {N : ℕ} (hcoef : ∀ n, N ≤ n → a n = 1)
    {F : ℂ → ℂ} (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n) {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), F z) = -(2 * (Real.pi : ℂ) * I) := by
  have hP : ∀ n, N ≤ n → a n = (Polynomial.C (1 : ℂ)).eval (n : ℂ) := by
    intro n hn; simpa using hcoef n hn
  rw [circleIntegral_of_eventually_polynomial hP hF hF0 hρ]
  simp

end Physics.GradedTransitivity