import Mathlib

/-!
# Convergence of the discrete `O(N)` renormalisation-group flow to Wilson–Fisher

The files `ONModelEpsilonExpansion.lean` and `ONModelTwoLoopFixedPoint.lean`
study the *fixed points* of the `O(N)` beta function.  This file studies the
*flow itself*: the infrared Euler flow

`g_{n+1} = g_n - h · β_N(ε, g_n)`,  `β_N(ε, g) = -εg + a_N g²`,  `a_N = (N+8)/3`,

started from any coupling strictly between the Gaussian and the Wilson–Fisher
value.  We prove, uniformly for `N ≥ 0`, `0 < ε` and every step size
`0 < h ≤ 1/ε`:

* the flow stays in the open interval `(0, g*)` (invariance);
* it is strictly increasing (monotonicity);
* it converges to the Wilson–Fisher coupling `g* = 3ε/(N+8)`.

This is a genuine dynamical statement: it identifies the Wilson–Fisher point as
the infrared attractor of the truncated flow with an explicit, `N`-uniform
basin of attraction, rather than merely as a zero of a polynomial.
-/

namespace ONModel

open Filter Topology

/-- The one-loop beta function coefficient `a_N = (N+8)/3`. -/
noncomputable def betaCoeff (N : ℝ) : ℝ := (N + 8) / 3

/-- The infrared Euler flow of the truncated one-loop `O(N)` beta function with
step `h`.  The infrared direction is `-β`, so the Wilson–Fisher point is
approached from below. -/
noncomputable def flowSeq (N ε h g₀ : ℝ) : ℕ → ℝ
  | 0 => g₀
  | n + 1 => flowSeq N ε h g₀ n - h * (-ε * flowSeq N ε h g₀ n
      + betaCoeff N * (flowSeq N ε h g₀ n) ^ 2)

@[simp] theorem flowSeq_zero (N ε h g₀ : ℝ) : flowSeq N ε h g₀ 0 = g₀ := rfl

theorem flowSeq_succ (N ε h g₀ : ℝ) (n : ℕ) :
    flowSeq N ε h g₀ (n + 1)
      = flowSeq N ε h g₀ n * (1 + h * ε - h * betaCoeff N * flowSeq N ε h g₀ n) := by
  rw [flowSeq]
  ring

/-- One step of the flow maps the interval `(0, g*)` into itself, where
`g* = ε / a` is the Wilson–Fisher coupling. -/
theorem flow_step_mem {a ε h x : ℝ} (ha : 0 < a) (hh : 0 < h)
    (hh' : h * ε ≤ 1) (hx0 : 0 < x) (hx1 : x < ε / a) :
    0 < x * (1 + h * ε - h * a * x) ∧ x * (1 + h * a * (ε / a - x)) < ε / a := by
  have hax : a * x < ε := by
    rw [lt_div_iff₀ ha] at hx1; linarith
  constructor
  · have hfac : 0 < 1 + h * ε - h * a * x := by nlinarith
    positivity
  · -- `x(1 + h(ε - a x)) < ε/a` since `(ε/a - x)(1 - h a x) > 0` and `h a x ≤ h ε ≤ 1`
    have hkey : ε / a - x * (1 + h * a * (ε / a - x))
        = (ε / a - x) * (1 - h * a * x) := by ring
    have h1 : 0 < ε / a - x := by linarith
    have h2 : 0 ≤ 1 - h * a * x := by nlinarith
    rcases eq_or_lt_of_le h2 with heq | hlt
    · -- degenerate case `h a x = 1`: then `h ε = 1` and `a x = ε`, excluded
      exfalso
      have : h * a * x = 1 := by linarith
      nlinarith
    · nlinarith

/-- **Invariance and monotonicity of the infrared flow.**  Started strictly
between the Gaussian and Wilson–Fisher couplings, the flow remains there and
increases at every step. -/
theorem flow_invariant {N ε h g₀ : ℝ} (hN : 0 ≤ N) (hh : 0 < h)
    (hh' : h * ε ≤ 1) (hg0 : 0 < g₀) (hg1 : g₀ < ε / betaCoeff N) :
    ∀ n, 0 < flowSeq N ε h g₀ n ∧ flowSeq N ε h g₀ n < ε / betaCoeff N ∧
      flowSeq N ε h g₀ n < flowSeq N ε h g₀ (n + 1) := by
  have ha : 0 < betaCoeff N := by unfold betaCoeff; linarith
  intro n
  induction n with
  | zero =>
    refine ⟨hg0, hg1, ?_⟩
    rw [flowSeq_succ, flowSeq_zero]
    have hax : betaCoeff N * g₀ < ε := by
      rw [lt_div_iff₀ ha] at hg1; linarith
    nlinarith [mul_pos (mul_pos hg0 hh) (by linarith : (0:ℝ) < ε - betaCoeff N * g₀)]
  | succ n ih =>
    obtain ⟨hpos, hlt, _⟩ := ih
    set x := flowSeq N ε h g₀ n with hxdef
    have hstep := flow_step_mem ha hh hh' hpos hlt
    have hnext : flowSeq N ε h g₀ (n + 1) = x * (1 + h * ε - h * betaCoeff N * x) := by
      rw [flowSeq_succ]
    have hpos' : 0 < flowSeq N ε h g₀ (n + 1) := by rw [hnext]; exact hstep.1
    have hlt' : flowSeq N ε h g₀ (n + 1) < ε / betaCoeff N := by
      rw [hnext]
      have hrw : x * (1 + h * ε - h * betaCoeff N * x)
          = x * (1 + h * betaCoeff N * (ε / betaCoeff N - x)) := by
        field_simp
        ring
      rw [hrw]; exact hstep.2
    refine ⟨hpos', hlt', ?_⟩
    rw [flowSeq_succ N ε h g₀ (n + 1)]
    have hax : betaCoeff N * flowSeq N ε h g₀ (n + 1) < ε := by
      rw [lt_div_iff₀ ha] at hlt'; linarith
    nlinarith [mul_pos (mul_pos hpos' hh)
      (by linarith : (0:ℝ) < ε - betaCoeff N * flowSeq N ε h g₀ (n + 1))]

/-- **The Wilson–Fisher coupling is the infrared attractor.**  For every `N ≥ 0`,
`ε > 0`, admissible step `0 < h ≤ 1/ε` and every start `g₀ ∈ (0, g*)`, the
discrete infrared flow converges to `g* = ε / a_N = 3ε/(N+8)`. -/
theorem flow_tendsto_fixedPoint {N ε h g₀ : ℝ} (hN : 0 ≤ N) (hh : 0 < h)
    (hh' : h * ε ≤ 1) (hg0 : 0 < g₀) (hg1 : g₀ < ε / betaCoeff N) :
    Tendsto (flowSeq N ε h g₀) atTop (𝓝 (ε / betaCoeff N)) := by
  have ha : 0 < betaCoeff N := by unfold betaCoeff; linarith
  have hinv := flow_invariant hN hh hh' hg0 hg1
  have hmono : Monotone (flowSeq N ε h g₀) := by
    apply monotone_nat_of_le_succ
    intro n
    exact le_of_lt (hinv n).2.2
  have hbdd : BddAbove (Set.range (flowSeq N ε h g₀)) := by
    refine ⟨ε / betaCoeff N, ?_⟩
    rintro y ⟨n, rfl⟩
    exact le_of_lt (hinv n).2.1
  -- the monotone bounded flow converges to its supremum
  set L := ⨆ n, flowSeq N ε h g₀ n with hL
  have hconv : Tendsto (flowSeq N ε h g₀) atTop (𝓝 L) := tendsto_atTop_ciSup hmono hbdd
  -- the limit is a zero of the beta function
  have hstep : Tendsto (fun n => flowSeq N ε h g₀ (n + 1)) atTop (𝓝 L) :=
    hconv.comp (tendsto_add_atTop_nat 1)
  have hcont : Tendsto (fun n => flowSeq N ε h g₀ n *
      (1 + h * ε - h * betaCoeff N * flowSeq N ε h g₀ n)) atTop
      (𝓝 (L * (1 + h * ε - h * betaCoeff N * L))) := by
    exact hconv.mul (((tendsto_const_nhds.add tendsto_const_nhds).sub
      (hconv.const_mul (h * betaCoeff N))).congr (fun n => by ring))
  have heq : L = L * (1 + h * ε - h * betaCoeff N * L) := by
    refine tendsto_nhds_unique hstep ?_
    exact hcont.congr (fun n => (flowSeq_succ N ε h g₀ n).symm)
  -- hence `L` is `0` or the Wilson-Fisher point; monotonicity rules out `0`
  have hLpos : 0 < L := lt_of_lt_of_le (hinv 0).1 (le_ciSup hbdd 0)
  have hfac : L * (h * ε - h * betaCoeff N * L) = 0 := by linarith [heq]
  have hzero : h * ε - h * betaCoeff N * L = 0 := by
    rcases mul_eq_zero.mp hfac with h' | h'
    · exact absurd h' (ne_of_gt hLpos)
    · exact h'
  have hLval : L = ε / betaCoeff N := by
    have hhne : h ≠ 0 := ne_of_gt hh
    field_simp at hzero ⊢
    nlinarith [hzero]
  rw [← hLval]
  exact hconv

end ONModel