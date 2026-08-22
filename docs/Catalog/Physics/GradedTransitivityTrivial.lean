import Physics.GradedTransitivityResidue

/-!
# The trivial action: a completely explicit residue

`Physics.GradedTransitivityResidue` computes the residue of the partition function of a graded
`G`-set whose transitivity counts are eventually a polynomial `P`: it equals `−P(−1)`, and the
pole has order `deg P + 1`.  This file evaluates that formula on the extreme opposite of the
transitive case — the **trivial action**, where nothing is identified and the grade counts are
as large as possible.

For the trivial action on a graded `G`-set with `#Yₙ = n` the transitivity count is the
descending factorial `t r Yₙ = n^{\underline r}`, a polynomial of degree `r`, and the
zeta-regularised residue is the *factorial*:

  `Res_{q=1} ∑ₙ n^{\underline r} qⁿ = (−1)^{r+1} · r!`,

while the pole at `q = 1` has order exactly `r + 1`, matching the sharp denominator
`(1 − q)^{r+1}` of the catalogue's formal rationality theorem.  The two extremes therefore give
residues `−1` (eventually `r`-transitive) and `(−1)^{r+1} r!` (trivial action): the residue is a
genuine invariant of the growth of the grade counts, not a universal constant.

## Main results

* `Physics.GradedTransitivity.orbitNum_of_trivial`, `transCount_of_trivial` — for a trivial
  action, orbit counting is plain counting and `t r Y = (#Y)^{\underline r}`.
* `Physics.GradedTransitivity.descPochhammer_eval_neg_one` — `x^{\underline r}` at `x = −1` is
  `(−1)^r r!`.
* `Physics.GradedTransitivity.circleIntegral_trivialAction` — the residue is
  `(−1)^{r+1} r!`.
* `Physics.GradedTransitivity.order_trivialAction` — the pole has order exactly `r + 1`.
-/

namespace Physics.GradedTransitivity

open Finset Polynomial Complex Filter Topology MulAction

variable {G : Type*} [Group G]

/-! ### Orbit counting for the trivial action -/

/-- For a trivial action every orbit is a singleton, so the orbit count is the cardinality. -/
theorem orbitNum_of_trivial {X : Type*} [MulAction G X] (htriv : ∀ (g : G) (x : X), g • x = x) :
    orbitNum G X = Nat.card X := by
  refine Nat.card_congr (Equiv.ofBijective (Quotient.mk (orbitRel G X))
    ⟨?_, Quotient.mk_surjective⟩).symm
  intro x y hxy
  obtain ⟨g, hg⟩ := Quotient.exact hxy
  simpa [htriv] using hg.symm

/-- A trivial action on `Y` induces a trivial action on injective `r`-tuples. -/
theorem trivial_on_injTuple {Y : Type*} [MulAction G Y] (htriv : ∀ (g : G) (y : Y), g • y = y)
    (r : ℕ) : ∀ (g : G) (a : InjTuple r Y), g • a = a := by
  intro g a
  exact InjTuple.ext fun i => by simp [htriv]

/-- **Transitivity counts of a trivial action.**  They are the descending factorials of the
cardinality — the largest possible values, by `transCount_le_descFactorial`. -/
theorem transCount_of_trivial {Y : Type*} [Fintype Y] [MulAction G Y]
    (htriv : ∀ (g : G) (y : Y), g • y = y) (r : ℕ) :
    transCount G r Y = (Fintype.card Y).descFactorial r := by
  rw [transCount, orbitNum_of_trivial (trivial_on_injTuple htriv r), card_injTuple r Y]

/-! ### The descending-factorial polynomial -/

/-- `x^{\underline r}` evaluated at `x = −1` is `(−1)^r · r!`. -/
theorem descPochhammer_eval_neg_one (r : ℕ) :
    (descPochhammer ℂ r).eval (-1) = (-1 : ℂ) ^ r * (Nat.factorial r : ℂ) := by
  induction r with
  | zero => simp
  | succ r ih =>
    rw [descPochhammer_succ_right]
    simp [ih, Nat.factorial_succ]
    ring

theorem descPochhammer_ne_zero (r : ℕ) : descPochhammer ℂ r ≠ 0 := by
  intro h
  have hev : (descPochhammer ℂ r).eval (r : ℂ) = (r.descFactorial r : ℂ) :=
    descPochhammer_eval_eq_descFactorial ℂ r r
  rw [h] at hev
  simp only [eval_zero] at hev
  have : r.descFactorial r = Nat.factorial r := by
    simpa using Nat.descFactorial_self r
  rw [this] at hev
  exact (Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero r)) hev.symm

/-! ### The residue and the pole for the trivial action -/

variable {Y : ℕ → Type*} [∀ n, Fintype (Y n)] [∀ n, MulAction G (Y n)]

/-- The transitivity counts of a trivially acted-on graded `G`-set with `#Yₙ = n` are the
values of the polynomial `x^{\underline r}`. -/
theorem transCount_eq_descPochhammer_eval (htriv : ∀ n (g : G) (y : Y n), g • y = y)
    (hcard : ∀ n, Fintype.card (Y n) = n) (r n : ℕ) :
    ((transCount G r (Y n) : ℂ)) = (descPochhammer ℂ r).eval (n : ℂ) := by
  rw [transCount_of_trivial (htriv n) r, hcard n, descPochhammer_eval_eq_descFactorial ℂ n r]

/-- **Existence of the continuation for the trivial action.**  The hypotheses of the two
theorems below are satisfiable. -/
theorem exists_continuation_trivialAction (htriv : ∀ n (g : G) (y : Y n), g • y = y)
    (hcard : ∀ n, Fintype.card (Y n) = n) (r : ℕ) :
    ∃ F : ℂ → ℂ, AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ ∧
      (∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, (transCount G r (Y n) : ℂ) * q ^ n) :=
  exists_analytic_continuation (P := descPochhammer ℂ r) (N := 0)
    (fun n _ => transCount_eq_descPochhammer_eval htriv hcard r n)

/-- **The residue of the trivial-action partition function is `(−1)^{r+1} r!`.**  Any analytic
continuation to `ℂ \ {1}` of `∑ₙ t r Yₙ qⁿ` integrates to `(−1)^{r+1} r! · 2πi` around `q = 1`. -/
theorem circleIntegral_trivialAction (htriv : ∀ n (g : G) (y : Y n), g • y = y)
    (hcard : ∀ n, Fintype.card (Y n) = n) {r : ℕ} {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, (transCount G r (Y n) : ℂ) * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), F z)
      = (-1 : ℂ) ^ (r + 1) * (Nat.factorial r : ℂ) * (2 * (Real.pi : ℂ) * I) := by
  have hcoef : ∀ n : ℕ, 0 ≤ n → ((transCount G r (Y n) : ℂ)) = (descPochhammer ℂ r).eval (n : ℂ) :=
    fun n _ => transCount_eq_descPochhammer_eval htriv hcard r n
  rw [circleIntegral_of_eventually_polynomial (N := 0) hcoef hF hF0 hρ,
    descPochhammer_eval_neg_one r]
  rw [pow_succ]
  ring

/-- **The pole of the trivial-action partition function has order exactly `r + 1`.**  This is
the analytic counterpart of the sharpness of the denominator `(1 − q)^{r+1}`. -/
theorem order_trivialAction (htriv : ∀ n (g : G) (y : Y n), g • y = y)
    (hcard : ∀ n, Fintype.card (Y n) = n) {r : ℕ} {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, (transCount G r (Y n) : ℂ) * q ^ n) :
    meromorphicOrderAt F 1 = ((-(r + 1 : ℤ) : ℤ) : WithTop ℤ) := by
  have hdeg : (descPochhammer ℂ r).natDegree = r := descPochhammer_natDegree ℂ r
  have hcoef : ∀ n : ℕ, 0 ≤ n → ((transCount G r (Y n) : ℂ)) = (descPochhammer ℂ r).eval (n : ℂ) :=
    fun n _ => transCount_eq_descPochhammer_eval htriv hcard r n
  -- the continuation agrees with `polyZeta (descPochhammer ℂ r)` off the singularity
  have hsplit : ∀ q : ℂ, ‖q‖ < 1 →
      ∑' n : ℕ, (transCount G r (Y n) : ℂ) * q ^ n = polyZeta (descPochhammer ℂ r) q := by
    intro q hq
    rw [← tsum_polyZeta (descPochhammer ℂ r) hq]
    exact tsum_congr fun n => by rw [hcoef n (Nat.zero_le n)]
  have hEq : Set.EqOn F (polyZeta (descPochhammer ℂ r)) {(1 : ℂ)}ᶜ := by
    refine eqOn_compl_one_of_eventuallyEq hF (analyticOnNhd_polyZeta _) ?_
    filter_upwards [hF0, Metric.ball_mem_nhds (0 : ℂ) one_pos] with q hq hball
    rw [hq, hsplit q (by simpa using hball)]
  have hgerm : F =ᶠ[𝓝[≠] (1 : ℂ)] polyZeta (descPochhammer ℂ r) := by
    filter_upwards [self_mem_nhdsWithin] with z hz
    exact hEq (by simpa using hz)
  rw [meromorphicOrderAt_congr hgerm, order_polyZeta (descPochhammer_ne_zero r), hdeg]

end Physics.GradedTransitivity