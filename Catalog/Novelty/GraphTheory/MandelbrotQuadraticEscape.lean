import Mathlib

/-!
# The Mandelbrot Set: Quadratic Recurrence and the Escape Radius

The Mandelbrot set `M` is the set of complex parameters `c` for which the *critical orbit*
`0, c, c²+c, …` of the quadratic map `f_c(z) = z² + c` stays bounded.

This file develops the elementary — but genuinely quantitative — dynamics of the recurrence
`z_{n+1} = z_n² + c` and proves the classical **escape-radius theorem**: if `‖c‖ > 2` then the
critical orbit diverges to infinity, so `M` is contained in the closed disk of radius `2`.

The heart of the argument is a geometric lower bound on the orbit:
`‖c‖·(‖c‖-1)ⁿ ≤ ‖f_c^{(n+1)}(0)‖`, which forces divergence because `‖c‖ - 1 > 1`.

We also record two concrete membership facts: `0 ∈ M` and `-1 ∈ M` (the orbit of `-1` is the
`2`-cycle `0, -1, 0, -1, …`), while every `c` with `‖c‖ > 2` lies outside `M`.
-/

namespace MandelbrotEscape

open Filter
open scoped Topology

/-- The quadratic map `f_c(z) = z² + c`. -/
def qmap (c z : ℂ) : ℂ := z ^ 2 + c

/-- The critical orbit: the iterates of `0` under `f_c`. -/
def critOrbit (c : ℂ) (n : ℕ) : ℂ := (qmap c)^[n] 0

/-- Membership in the Mandelbrot set: the critical orbit is bounded. -/
def Mandelbrot : Set ℂ := {c | ∃ B : ℝ, ∀ n, ‖critOrbit c n‖ ≤ B}

@[simp] lemma critOrbit_zero (c : ℂ) : critOrbit c 0 = 0 := rfl

lemma critOrbit_succ (c : ℂ) (n : ℕ) :
    critOrbit c (n + 1) = (critOrbit c n) ^ 2 + c := by
  simp [critOrbit, qmap, Function.iterate_succ_apply']

/-
Reverse triangle inequality specialised to the quadratic map:
`‖z‖² - ‖c‖ ≤ ‖z² + c‖`.
-/
lemma qmap_norm_lower (c z : ℂ) : ‖z‖ ^ 2 - ‖c‖ ≤ ‖qmap c z‖ := by
  have h := norm_sub_norm_le (z ^ 2) (-c)
  simpa [qmap, sub_neg_eq_add, norm_pow] using h

/-
The key growth invariant.  If `‖c‖ > 2`, then for every `n` the `(n+1)`-st iterate of the
critical orbit is at least `‖c‖` in norm, and in fact grows geometrically at rate `‖c‖ - 1`.
-/
lemma critOrbit_growth (c : ℂ) (hc : 2 < ‖c‖) (n : ℕ) :
    ‖c‖ ≤ ‖critOrbit c (n + 1)‖ ∧ ‖c‖ * (‖c‖ - 1) ^ n ≤ ‖critOrbit c (n + 1)‖ := by
  induction' n with n ih;
  · simp +decide [ critOrbit, qmap ];
  · -- Using the induction hypothesis and the triangle inequality, we have:
    have h_step : ‖critOrbit c (n + 2)‖ ≥ ‖critOrbit c (n + 1)‖^2 - ‖c‖ := by
      simpa only [ critOrbit_succ ] using qmap_norm_lower c _;
    constructor <;> ring_nf at * <;> nlinarith [ sq_nonneg ( ‖critOrbit c ( n + 1 )‖ - ‖c‖ ) ]

/-
**Escape theorem.**  If `‖c‖ > 2`, the norm of the critical orbit tends to infinity.
-/
theorem critOrbit_tendsto_atTop (c : ℂ) (hc : 2 < ‖c‖) :
    Tendsto (fun n => ‖critOrbit c n‖) atTop atTop := by
  -- We use the fact that ‖c‖ > 2 to show that ‖critOrbit c n‖ eventually grows at least as fast as a geometric sequence with ratio ‖c‖ - 1 > 1.
  have h_geometric : Filter.Tendsto (fun n => ‖c‖ * (‖c‖ - 1) ^ n) Filter.atTop Filter.atTop := by
    exact Filter.Tendsto.const_mul_atTop ( by positivity ) ( tendsto_pow_atTop_atTop_of_one_lt ( by linarith ) );
  rw [ ← Filter.tendsto_add_atTop_iff_nat 1 ];
  exact Filter.tendsto_atTop_mono ( fun n => by simpa using ( critOrbit_growth c hc n ).2 ) h_geometric

/-
**Escape radius / a-priori bound for the Mandelbrot set.**
Every parameter in the Mandelbrot set has norm at most `2`.
-/
theorem mandelbrot_subset_closedBall {c : ℂ} (hc : c ∈ Mandelbrot) : ‖c‖ ≤ 2 := by
  obtain ⟨B, hB⟩ := hc;
  -- By contradiction, assume ‖c‖ > 2.
  by_contra h_contra;
  exact absurd ( critOrbit_tendsto_atTop c ( not_le.mp h_contra ) ) ( by exact fun h => by have := h.eventually_gt_atTop B; obtain ⟨ n, hn ⟩ := this.exists; linarith [ hB n ] )

/-
Any parameter of norm `> 2` escapes, hence lies outside the Mandelbrot set.
-/
theorem not_mem_Mandelbrot_of_norm_gt_two {c : ℂ} (hc : 2 < ‖c‖) : c ∉ Mandelbrot := by
  exact fun h => by obtain ⟨ B, hB ⟩ := h; linarith [ hB ( Classical.choose ( Filter.eventually_atTop.mp ( Filter.Tendsto.eventually_gt_atTop ( critOrbit_tendsto_atTop c hc ) B ) ) ), Classical.choose_spec ( Filter.eventually_atTop.mp ( Filter.Tendsto.eventually_gt_atTop ( critOrbit_tendsto_atTop c hc ) B ) ) ( Classical.choose ( Filter.eventually_atTop.mp ( Filter.Tendsto.eventually_gt_atTop ( critOrbit_tendsto_atTop c hc ) B ) ) ) le_rfl ] ;

/-
The origin is in the Mandelbrot set (its critical orbit is constantly `0`).
-/
theorem zero_mem_Mandelbrot : (0 : ℂ) ∈ Mandelbrot := by
  use 0; simp [critOrbit];
  exact fun n => Function.iterate_fixed ( by norm_num [ qmap ] ) _

/-
The critical orbit of `c = -1` is the `2`-cycle `0, -1, 0, -1, …`.
-/
lemma critOrbit_neg_one (n : ℕ) :
    critOrbit (-1) n = if Even n then 0 else -1 := by
  induction' n with n ih;
  · rfl;
  · split_ifs at * <;> simp_all +decide [ Nat.even_add_one, critOrbit_succ ]

/-
`c = -1` lies in the Mandelbrot set (its orbit is a bounded `2`-cycle).
-/
theorem neg_one_mem_Mandelbrot : (-1 : ℂ) ∈ Mandelbrot := by
  use 1; intro n; rw [ critOrbit_neg_one ] ; split_ifs <;> norm_num;

/-
A concrete escaping parameter: `c = 3` is not in the Mandelbrot set.
-/
theorem three_not_mem_Mandelbrot : (3 : ℂ) ∉ Mandelbrot := by
  convert not_mem_Mandelbrot_of_norm_gt_two _;
  norm_num [ Norm.norm ]

end MandelbrotEscape