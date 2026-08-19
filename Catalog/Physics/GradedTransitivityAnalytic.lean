import Physics.GradedTransitivityGSet

/-!
# Graded `G`-sets: the generating function as an honest function of `q`

The formal statement `(1 − q)^{r+1} · ∑ₙ t r Yₙ qⁿ ∈ ℤ[q]` proved in
`Physics.GradedTransitivityGSet` is an identity of formal power series.  This file
converts it into an identity of *real-analytic* functions on the unit disc: for
`|q| < 1` the series converges and its value is the explicit rational function

  `∑_{n < N} t r Yₙ qⁿ + q^N / (1 − q)`.

In statistical-mechanics language: the "transitivity partition function" of a graded
`G`-set whose grades are eventually `r`-transitive has a single simple pole at `q = 1`
and no other singularity, the polar part being `1/(1 − q)`.

## Main results

* `Physics.GradedTransitivity.tsum_of_eventually_const` — summation of an eventually
  constant coefficient sequence.
* `Physics.GradedTransitivity.tsum_transCount_of_eventually_transitive` — the analytic
  form of the main theorem.
* `Physics.GradedTransitivity.tsum_transCount_mul_one_sub_q` — clearing the denominator:
  `(1 − q) · ∑ₙ t r Yₙ qⁿ` is a polynomial in `q` (evaluated at `q`).
-/

namespace Physics.GradedTransitivity

open Finset

variable {G : Type*} [Group G]

/-- A geometric-type summation lemma: a sequence which is eventually constant has an
explicit rational sum on `|q| < 1`. -/
theorem tsum_of_eventually_const {a : ℕ → ℤ} {N : ℕ} {c : ℤ} (ha : ∀ n, N ≤ n → a n = c)
    {q : ℝ} (hq : |q| < 1) :
    ∑' n, (a n : ℝ) * q ^ n
      = (∑ n ∈ range N, (a n : ℝ) * q ^ n) + (c : ℝ) * q ^ N / (1 - q) := by
  have hnorm : ‖q‖ < 1 := by simpa [Real.norm_eq_abs] using hq
  have htail : ∀ n : ℕ, ((a (n + N) : ℝ) * q ^ (n + N)) = ((c : ℝ) * q ^ N) * q ^ n := by
    intro n
    rw [ha (n + N) (Nat.le_add_left _ _), pow_add]
    ring
  have hgeo : Summable (fun n : ℕ => ((c : ℝ) * q ^ N) * q ^ n) :=
    (summable_geometric_of_norm_lt_one hnorm).mul_left _
  have hshift : Summable (fun n : ℕ => (a (n + N) : ℝ) * q ^ (n + N)) := by
    simpa [htail] using hgeo
  have hsummable : Summable (fun n : ℕ => (a n : ℝ) * q ^ n) :=
    (summable_nat_add_iff N).mp hshift
  have hsplit := hsummable.sum_add_tsum_nat_add N
  have htailsum : ∑' n : ℕ, (a (n + N) : ℝ) * q ^ (n + N) = (c : ℝ) * q ^ N / (1 - q) := by
    calc ∑' n : ℕ, (a (n + N) : ℝ) * q ^ (n + N)
        = ∑' n : ℕ, ((c : ℝ) * q ^ N) * q ^ n := by
          exact tsum_congr htail
      _ = ((c : ℝ) * q ^ N) * ∑' n : ℕ, q ^ n := by rw [tsum_mul_left]
      _ = (c : ℝ) * q ^ N / (1 - q) := by
          rw [tsum_geometric_of_norm_lt_one hnorm]
          ring
  rw [← hsplit, htailsum]

/-- **Analytic form of the main theorem.**  If the grades of a graded `G`-set are
eventually `r`-transitive then, for every real `q` with `|q| < 1`, the transitivity
generating function converges and equals an explicit rational function of `q` whose only
pole is the simple pole at `q = 1`. -/
theorem tsum_transCount_of_eventually_transitive {Y : ℕ → Type*} [∀ n, MulAction G (Y n)]
    {r N : ℕ} (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) {q : ℝ} (hq : |q| < 1) :
    ∑' n, (transCount G r (Y n) : ℝ) * q ^ n
      = (∑ n ∈ range N, (transCount G r (Y n) : ℝ) * q ^ n) + q ^ N / (1 - q) := by
  have ha : ∀ n, N ≤ n → ((transCount G r (Y n) : ℤ)) = 1 := by
    intro n hn
    have := (transCount_eq_one_iff r (Y n)).mpr (h n hn)
    simp [this]
  have := tsum_of_eventually_const (a := fun n => (transCount G r (Y n) : ℤ)) (c := 1) ha hq
  simpa using this

/-- Clearing the denominator analytically: `(1 − q)` times the transitivity generating
function is a polynomial expression in `q`. -/
theorem tsum_transCount_mul_one_sub_q {Y : ℕ → Type*} [∀ n, MulAction G (Y n)]
    {r N : ℕ} (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) {q : ℝ} (hq : |q| < 1) :
    (1 - q) * ∑' n, (transCount G r (Y n) : ℝ) * q ^ n
      = (1 - q) * (∑ n ∈ range N, (transCount G r (Y n) : ℝ) * q ^ n) + q ^ N := by
  have hq1 : (1 : ℝ) - q ≠ 0 := by
    have : q < 1 := lt_of_abs_lt hq
    linarith
  rw [tsum_transCount_of_eventually_transitive h hq]
  field_simp

end Physics.GradedTransitivity