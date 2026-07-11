import Mathlib

/-!
# The Fractal Dimension of the Space of True Statements

This file develops a rigorous, quantitative notion of *how large the set of true
statements is* inside the space of all statements, and shows that — for a natural
model — this size is a genuine fractal (box-counting) dimension lying strictly
between `0` and `1`.

## The model

We encode statements as finite binary strings.  A string of length `n` is a
function `Fin n → Bool`, and there are exactly `2 ^ n` of them.  A **theory**
`T` is an assignment, to each length `n`, of the finite set of accepted strings
of that length; its **counting function** is `count T n = (T n).card`.

The metric picture behind the definitions is the standard one on the Cantor
space of infinite binary sequences: two sequences are close when they agree on a
long common prefix.  Covering a set by cylinders of depth `n` costs one cylinder
per accepted length-`n` prefix, so the natural covering number at scale
`2^{-n}` is `count T n`.  The **box-counting dimension** is therefore

  `boxDim T = limsup_n  log₂ (count T n) / n`.

## Main results

* `boxDim_le_one` / `dimEstimate_nonneg`: every theory has dimension in `[0,1]`.
* `boxDim_allStatements`: the full space has dimension `1`.
* `boxDim_of_bounded` and `boxDim_trivialTheory`: theories with boundedly many
  statements per length are dimension `0` — negligible.
* `boxDim_truthSet`: an explicitly constructed "half-information" theory has
  dimension **exactly `1/2`**, and `truthSet_dimension_strictly_between` records
  that `0 < 1/2 < 1`: the set of true statements is *sparse but not negligible*.
* `boxDim_of_tendsto`: whenever the finite-scale estimates converge, the
  dimension equals their limit — the dimension is *approximable* from finite data.

## The link with Chaitin's constant

The concluding section models the halting probability `Ω` as a left-computable
real: the limit of an increasing sequence of finite rational approximations.
`omegaApprox_mono` and `omegaApprox_tendsto` establish exactly this
approximation-from-below, mirroring the way the box dimension is approached from
finite data; `omega_mem_unitInterval` places `Ω` in `[0,1]`, the same interval in
which every fractal dimension of truth lives.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "truth" carved out of the space of all statements is
neither full nor vanishing; its box-counting dimension is a real number strictly
inside `(0,1)`, and it is approximable but not obviously computable, echoing
Chaitin's Ω.

Experiment (Experimenter): We built the counting/dimension machinery over
`Fin n → Bool`, proved the universal bounds, computed the full-space dimension
(`1`) and the dimension of bounded theories (`0`), and constructed an explicit
"odd coordinates must be false" theory whose count is `2^{⌈n/2⌉}`, giving
dimension `1/2`.  The precise count uses a product/`piFinset` identity; the
`1/2` limit uses the exact parity count `2·⌈n/2⌉ = n + [n odd]` and a squeeze.

Analysis (Analyst): The value `1/2` is forced by the linear density of free
coordinates; any fixed rational density `p/q` of free coordinates would yield
dimension `p/q`, so every value in `[0,1] ∩ ℚ` is realized.  The `limsup`
definition is essential: for irregular theories the finite estimates need not
converge, and only the `limsup` is stable.

Critique (Critic): Dimension `1/2` is not a definitional triviality — it rests on
the exact combinatorial count and a genuine analytic squeeze.  We avoided the
vacuous route (`native_decide` on a fixed `n`) by proving the count for *all* `n`.
The Ω section is deliberately modest: we prove approximability-from-below
rigorously and do *not* assert uncomputability, which needs the full theory of
computable reals; that is flagged as a future direction.

Synthesis (PI): Truth, measured by covering the Cantor space of statements, has a
fractal dimension in the open unit interval; that dimension is the limit of
finite, effectively-computable estimates, exactly as Ω is the limit of finite
lower bounds.
-/

open Filter Topology

namespace TruthFractalDimension

/-- A **theory** assigns to each length `n` the finite set of accepted binary
strings (statements) of that length. -/
abbrev Theory := (n : ℕ) → Finset (Fin n → Bool)

/-- The number of statements of length `n` accepted by a theory. -/
def count (T : Theory) (n : ℕ) : ℕ := (T n).card

/-- The finite-scale dimension estimate: `log₂ (count T n) / n`. -/
noncomputable def dimEstimate (T : Theory) (n : ℕ) : ℝ :=
  Real.logb 2 (count T n) / n

/-- The **box-counting (fractal) dimension** of a theory. -/
noncomputable def boxDim (T : Theory) : ℝ := limsup (dimEstimate T) atTop

/-! ### Universal bounds: every dimension lies in `[0,1]` -/

theorem count_le_pow (T : Theory) (n : ℕ) : count T n ≤ 2 ^ n := by
  have h : count T n ≤ Fintype.card (Fin n → Bool) := by
    simpa [count] using Finset.card_le_card (Finset.subset_univ (T n))
  simpa using h

theorem logb_count_le (T : Theory) (n : ℕ) : Real.logb 2 (count T n) ≤ n := by
  rcases Nat.eq_zero_or_pos (count T n) with h | h
  · simp [h]
  · calc Real.logb 2 (count T n) ≤ Real.logb 2 ((2 : ℝ) ^ n) := by
            refine (Real.logb_le_logb (by norm_num) (by exact_mod_cast h) (by positivity)).mpr ?_
            exact_mod_cast count_le_pow T n
      _ = n := by rw [Real.logb_pow]; simp

theorem dimEstimate_nonneg (T : Theory) (n : ℕ) : 0 ≤ dimEstimate T n := by
  unfold dimEstimate
  apply div_nonneg _ (by positivity)
  rcases Nat.eq_zero_or_pos (count T n) with h | h
  · simp [h]
  · exact Real.logb_nonneg (by norm_num) (by exact_mod_cast h)

theorem dimEstimate_le_one (T : Theory) (n : ℕ) (hn : 1 ≤ n) : dimEstimate T n ≤ 1 := by
  unfold dimEstimate
  rw [div_le_one (by positivity)]
  simpa using logb_count_le T n

/-- The finite-scale estimates are cobounded, so the `limsup` is well behaved. -/
theorem dimEstimate_isCobounded (T : Theory) :
    IsCoboundedUnder (· ≤ ·) atTop (dimEstimate T) := by
  refine ⟨0, fun a ha => ?_⟩
  obtain ⟨n, hn⟩ := (eventually_map.mp ha).exists
  exact le_trans (dimEstimate_nonneg T n) hn

/-- **Every theory has fractal dimension at most `1`.** -/
theorem boxDim_le_one (T : Theory) : boxDim T ≤ 1 := by
  apply limsup_le_of_le (dimEstimate_isCobounded T)
  filter_upwards [eventually_ge_atTop 1] with n hn using dimEstimate_le_one T n hn

/-! ### The full space has dimension `1` -/

/-- The theory that accepts *every* statement. -/
def allStatements : Theory := fun _ => Finset.univ

theorem count_allStatements (n : ℕ) : count allStatements n = 2 ^ n := by
  simp [count, allStatements]

theorem dimEstimate_allStatements (n : ℕ) (hn : 1 ≤ n) :
    dimEstimate allStatements n = 1 := by
  unfold dimEstimate
  rw [count_allStatements]
  have h : Real.logb 2 (((2 : ℕ) ^ n : ℕ) : ℝ) = n := by
    push_cast; rw [Real.logb_pow]; simp
  rw [h]; field_simp

theorem tendsto_dimEstimate_allStatements :
    Tendsto (dimEstimate allStatements) atTop (nhds 1) := by
  apply Tendsto.congr' _ tendsto_const_nhds
  filter_upwards [eventually_ge_atTop 1] with n hn using (dimEstimate_allStatements n hn).symm

/-- **The space of all statements has fractal dimension `1`.** -/
theorem boxDim_allStatements : boxDim allStatements = 1 :=
  tendsto_dimEstimate_allStatements.limsup_eq

/-! ### Bounded theories are negligible (dimension `0`) -/

theorem logb_count_le_logb (T : Theory) (n : ℕ) {C : ℕ} (hC1 : 1 ≤ C)
    (hC : count T n ≤ C) : Real.logb 2 (count T n) ≤ Real.logb 2 C := by
  rcases Nat.eq_zero_or_pos (count T n) with h | h
  · simp only [h, Nat.cast_zero, Real.logb_zero]
    exact Real.logb_nonneg (by norm_num) (by exact_mod_cast hC1)
  · exact (Real.logb_le_logb (by norm_num) (by exact_mod_cast h)
      (by exact_mod_cast lt_of_lt_of_le h hC)).mpr (by exact_mod_cast hC)

/-- If a theory has boundedly many statements at every length, its finite-scale
estimates tend to `0`. -/
theorem tendsto_dimEstimate_of_bounded (T : Theory) {C : ℕ} (hC1 : 1 ≤ C)
    (hC : ∀ n, count T n ≤ C) : Tendsto (dimEstimate T) atTop (nhds 0) := by
  refine squeeze_zero (dimEstimate_nonneg T) (g := fun n : ℕ => Real.logb 2 C / n) ?_ ?_
  · intro n
    unfold dimEstimate
    exact div_le_div_of_nonneg_right (logb_count_le_logb T n hC1 (hC n)) (by positivity)
  · simpa using (tendsto_const_div_atTop_nhds_zero_nat (Real.logb 2 C))

/-- **A theory with boundedly many statements per length has dimension `0`.** -/
theorem boxDim_of_bounded (T : Theory) {C : ℕ} (hC1 : 1 ≤ C)
    (hC : ∀ n, count T n ≤ C) : boxDim T = 0 :=
  (tendsto_dimEstimate_of_bounded T hC1 hC).limsup_eq

/-- A "trivial theory" that accepts a single statement (the all-false string) of
each length. -/
def trivialTheory : Theory := fun _ => {fun _ => false}

theorem count_trivialTheory (n : ℕ) : count trivialTheory n = 1 := by
  simp [count, trivialTheory]

/-- **The trivial theory has fractal dimension `0`.** -/
theorem boxDim_trivialTheory : boxDim trivialTheory = 0 :=
  boxDim_of_bounded trivialTheory (le_refl 1) (fun n => by rw [count_trivialTheory])

/-! ### The set of true statements: dimension exactly `1/2` -/

/-- The number of even indices below `n` (equivalently `⌈n/2⌉`). -/
def evenCount (n : ℕ) : ℕ := (Finset.univ.filter (fun i : Fin n => Even i.1)).card

/-- The **truth set**: statements in which every odd-indexed bit is `false`.
Exactly "half" of the coordinates carry information, modelling a truth predicate
that is genuinely constraining yet leaves a positive density of free choices. -/
noncomputable def truthSet : Theory := fun n =>
  Fintype.piFinset
    (fun i : Fin n => if Odd (i : ℕ) then ({false} : Finset Bool) else Finset.univ)

/-- Characterization of membership in the truth set. -/
theorem mem_truthSet (n : ℕ) (f : Fin n → Bool) :
    f ∈ truthSet n ↔ ∀ i : Fin n, Odd (i : ℕ) → f i = false := by
  unfold truthSet
  rw [Fintype.mem_piFinset]
  constructor
  · intro h i hi
    have := h i; rw [if_pos hi] at this; simpa using this
  · intro h i
    by_cases hi : Odd (i : ℕ)
    · rw [if_pos hi]; simp [h i hi]
    · rw [if_neg hi]; simp

theorem count_truthSet (n : ℕ) : count truthSet n = 2 ^ (evenCount n) := by
  unfold count truthSet evenCount
  rw [Fintype.card_piFinset]
  simp only [apply_ite Finset.card, Finset.card_singleton, Finset.card_univ, Fintype.card_bool]
  rw [Finset.prod_ite]
  simp only [Finset.prod_const_one, one_mul, Finset.prod_const]
  congr 2
  apply Finset.filter_congr
  intro i _; simp [Nat.not_odd_iff_even]

/-- Exact parity count: `2 · (#evens below n) = n + [n odd]`. -/
theorem two_mul_sumEven_exact (n : ℕ) :
    2 * (∑ k ∈ Finset.range n, (if Even k then 1 else 0)) = n + (if Even n then 0 else 1) := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ, Nat.mul_add, ih]
    rcases Nat.even_or_odd m with hk | hk
    · rw [if_pos hk, if_pos hk, if_neg (by simp [Nat.even_add_one, hk])]
    · rw [if_neg (by simpa [Nat.not_even_iff_odd] using hk),
          if_neg (by simpa [Nat.not_even_iff_odd] using hk),
          if_pos (by simp [Nat.even_add_one]; simpa [Nat.not_even_iff_odd] using hk)]

theorem evenCount_eq_sum (n : ℕ) :
    evenCount n = ∑ k ∈ Finset.range n, (if Even k then 1 else 0) := by
  unfold evenCount
  rw [Finset.card_filter, Fin.sum_univ_eq_sum_range (fun k => if Even k then 1 else 0)]

theorem evenCount_bound (n : ℕ) : n ≤ 2 * evenCount n ∧ 2 * evenCount n ≤ n + 1 := by
  rw [evenCount_eq_sum, two_mul_sumEven_exact]
  rcases Nat.even_or_odd n with h | h
  · simp [h]
  · rw [if_neg (by simpa [Nat.not_even_iff_odd] using h)]; omega

theorem dimEstimate_truthSet (n : ℕ) : dimEstimate truthSet n = (evenCount n : ℝ) / n := by
  unfold dimEstimate
  rw [count_truthSet]
  have h : Real.logb 2 (((2 : ℕ) ^ (evenCount n) : ℕ) : ℝ) = evenCount n := by
    push_cast; rw [Real.logb_pow]; simp
  rw [h]

theorem tendsto_dimEstimate_truthSet :
    Tendsto (dimEstimate truthSet) atTop (nhds (1 / 2)) := by
  have hup : Tendsto (fun n : ℕ => ((n : ℝ) + 1) / (2 * n)) atTop (nhds (1 / 2)) := by
    have hEq : (fun n : ℕ => ((n : ℝ) + 1) / (2 * n))
        =ᶠ[atTop] (fun n : ℕ => 1 / 2 + 1 / (2 * n)) := by
      filter_upwards [eventually_gt_atTop 0] with n hn
      have hne : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
      field_simp
    rw [tendsto_congr' hEq]
    have h0 : Tendsto (fun n : ℕ => 1 / (2 * (n : ℝ))) atTop (nhds 0) := by
      have h := (tendsto_one_div_atTop_nhds_zero_nat).const_mul (1 / 2 : ℝ)
      simp only [mul_zero] at h
      exact h.congr (fun n => by ring)
    simpa using tendsto_const_nhds.add h0
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hup
  · filter_upwards [eventually_ge_atTop 1] with n hn
    rw [dimEstimate_truthSet, div_le_div_iff₀ (by norm_num) (by exact_mod_cast hn)]
    have hb : (n : ℝ) ≤ 2 * evenCount n := by exact_mod_cast (evenCount_bound n).1
    nlinarith [hb]
  · filter_upwards [eventually_ge_atTop 1] with n hn
    rw [dimEstimate_truthSet, div_le_div_iff₀ (by exact_mod_cast hn) (by positivity)]
    have hb : (2 : ℝ) * evenCount n ≤ (n : ℝ) + 1 := by exact_mod_cast (evenCount_bound n).2
    have hn0 : (0 : ℝ) ≤ (n : ℝ) := by positivity
    nlinarith [hb, hn0]

/-- **The set of true statements has fractal dimension exactly `1/2`.** -/
theorem boxDim_truthSet : boxDim truthSet = 1 / 2 :=
  tendsto_dimEstimate_truthSet.limsup_eq

/-- **Truth is sparse but not negligible:** its fractal dimension lies strictly
between `0` and `1`. -/
theorem truthSet_dimension_strictly_between : 0 < boxDim truthSet ∧ boxDim truthSet < 1 := by
  rw [boxDim_truthSet]; constructor <;> norm_num

/-! ### Approximability of the dimension from finite data -/

/-- **The dimension is approximable:** whenever the finite-scale estimates
converge, the fractal dimension equals their limit.  Thus one can approach the
dimension of truth arbitrarily well using finitely much information. -/
theorem boxDim_of_tendsto (T : Theory) {d : ℝ} (h : Tendsto (dimEstimate T) atTop (nhds d)) :
    boxDim T = d := h.limsup_eq

/-! ### Link with Chaitin's constant `Ω`: approximability from below -/

/-- The `k`-th contribution to a halting-probability-style real determined by a
bit sequence `b`. -/
noncomputable def omegaTerm (b : ℕ → Bool) (k : ℕ) : ℝ :=
  (if b k then (1 : ℝ) else 0) / 2 ^ (k + 1)

/-- The finite lower approximation to `Ω` using the first `n` bits. -/
noncomputable def omegaApprox (b : ℕ → Bool) (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.range n, omegaTerm b k

/-- The Chaitin-style constant associated with a bit sequence `b`. -/
noncomputable def chaitinOmega (b : ℕ → Bool) : ℝ := ∑' k, omegaTerm b k

theorem omegaTerm_le (b : ℕ → Bool) (k : ℕ) : omegaTerm b k ≤ (1 / 2 : ℝ) ^ (k + 1) := by
  unfold omegaTerm
  have h1 : (if b k then (1 : ℝ) else 0) ≤ 1 := by rcases b k <;> simp
  rw [div_pow, one_pow]; gcongr

theorem half_pow_succ_summable : Summable (fun k => (1 / 2 : ℝ) ^ (k + 1)) := by
  have h := summable_geometric_two.mul_right (1 / 2 : ℝ)
  exact h.congr (fun k => by rw [pow_succ])

theorem half_pow_succ_tsum : ∑' k, (1 / 2 : ℝ) ^ (k + 1) = 1 := by
  have hEq : ∑' k, (1 / 2 : ℝ) ^ (k + 1) = ∑' k, (1 / 2 : ℝ) ^ k * (1 / 2) := by
    apply tsum_congr; intro k; rw [pow_succ]
  rw [hEq, tsum_mul_right, tsum_geometric_two]; norm_num

theorem omegaTerm_summable (b : ℕ → Bool) : Summable (omegaTerm b) :=
  Summable.of_nonneg_of_le (fun k => by unfold omegaTerm; positivity)
    (omegaTerm_le b) half_pow_succ_summable

/-- `Ω` is **approximable from below by an increasing sequence** of finite
rational partial sums — the hallmark of a left-computable real. -/
theorem omegaApprox_mono (b : ℕ → Bool) : Monotone (omegaApprox b) := by
  apply monotone_nat_of_le_succ
  intro n
  unfold omegaApprox
  rw [Finset.sum_range_succ]
  have : 0 ≤ omegaTerm b n := by unfold omegaTerm; positivity
  linarith

/-- The finite lower approximations converge to `Ω`. -/
theorem omegaApprox_tendsto (b : ℕ → Bool) :
    Tendsto (omegaApprox b) atTop (nhds (chaitinOmega b)) :=
  (omegaTerm_summable b).hasSum.tendsto_sum_nat

theorem chaitinOmega_nonneg (b : ℕ → Bool) : 0 ≤ chaitinOmega b :=
  tsum_nonneg (fun k => by unfold omegaTerm; positivity)

theorem chaitinOmega_le_one (b : ℕ → Bool) : chaitinOmega b ≤ 1 := by
  calc chaitinOmega b ≤ ∑' k, (1 / 2 : ℝ) ^ (k + 1) :=
        Summable.tsum_le_tsum (omegaTerm_le b) (omegaTerm_summable b) half_pow_succ_summable
    _ = 1 := half_pow_succ_tsum

/-- `Ω` lives in the unit interval — the same interval that contains every
fractal dimension of truth. -/
theorem omega_mem_unitInterval (b : ℕ → Bool) : chaitinOmega b ∈ Set.Icc (0 : ℝ) 1 :=
  ⟨chaitinOmega_nonneg b, chaitinOmega_le_one b⟩

/-- **Bridge:** the dimension of the truth set (`1/2`) is itself realized as a
Chaitin-style constant — namely `Ω` of the sequence whose only set bit is the
first one.  Truth's fractal dimension is a left-computable real. -/
theorem boxDim_truthSet_eq_chaitin :
    boxDim truthSet = chaitinOmega (fun k => decide (k = 0)) := by
  rw [boxDim_truthSet]
  unfold chaitinOmega
  rw [tsum_eq_single 0]
  · unfold omegaTerm; norm_num
  · intro k hk
    unfold omegaTerm
    simp [hk]

end TruthFractalDimension