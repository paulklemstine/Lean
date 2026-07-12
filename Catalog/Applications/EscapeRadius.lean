/-
# The Mandelbrot Set: Escape Radius and Containment

The Mandelbrot set `M` is the set of complex parameters `c` for which the orbit
of `0` under the quadratic map `f_c(z) = z^2 + c` stays bounded:

    z_0 = 0,   z_{n+1} = z_n^2 + c.

This file develops the elementary but genuine *dynamics* of this quadratic
recurrence and proves the classical **escape–radius theorem**:

* If at some stage the orbit reaches a point `z` with `‖z‖ > 2` (and `‖c‖ ≤ ‖z‖`),
  then the orbit escapes to infinity: `‖f_c^[n] z‖ ≥ ‖z‖·(‖z‖-1)^n → ∞`.
* Consequently, if `‖c‖ > 2` then `c ∉ M`.
* Equivalently, `M` is contained in the closed disk of radius `2`:
  every `c ∈ M` satisfies `‖c‖ ≤ 2`.

We also verify two concrete membership facts:

* `0 ∈ M` (the fixed point at the origin), and
* `-1 ∈ M` (the center of the period-2 bulb: the orbit is `0, -1, 0, -1, …`).

Everything is proved from scratch over `ℂ`; the only imported machinery is the
norm / triangle inequality from `Mathlib`.
-/
import Mathlib

namespace MandelbrotNT

open scoped BigOperators

/-- The quadratic map `f_c(z) = z^2 + c`. -/
noncomputable def step (c z : ℂ) : ℂ := z ^ 2 + c

/-- The orbit of `0` under `f_c`: `orbit c n = f_c^[n] 0`. -/
noncomputable def orbit (c : ℂ) : ℕ → ℂ
  | 0 => 0
  | (n + 1) => step c (orbit c n)

/-- A parameter `c` has bounded orbit if the orbit of `0` is bounded in norm. -/
def BoundedOrbit (c : ℂ) : Prop := ∃ R : ℝ, ∀ n, ‖orbit c n‖ ≤ R

/-- The Mandelbrot set: parameters with bounded orbit of `0`. -/
def Mandelbrot : Set ℂ := {c | BoundedOrbit c}

/-! ## Basic identities -/

@[simp] theorem orbit_zero (c : ℂ) : orbit c 0 = 0 := rfl

@[simp] theorem orbit_succ (c : ℂ) (n : ℕ) :
    orbit c (n + 1) = (orbit c n) ^ 2 + c := rfl

/-- The first iterate of `0` is `c`. -/
theorem orbit_one (c : ℂ) : orbit c 1 = c := by
  simp [orbit, step]

/-
The orbit from step `1` onwards is the iterate of `step c` applied to `c`.
-/
theorem orbit_succ_iterate (c : ℂ) (n : ℕ) :
    orbit c (n + 1) = (step c)^[n] c := by
  induction n <;> simp_all +decide [ Function.iterate_succ_apply' ];
  rfl

/-! ## The one–step lower bound (reverse triangle inequality) -/

/-
Reverse triangle inequality for the quadratic step:
`‖f_c(z)‖ ≥ ‖z‖² − ‖c‖`.
-/
theorem step_norm_lower (c z : ℂ) : ‖z‖ ^ 2 - ‖c‖ ≤ ‖step c z‖ := by
  have := norm_sub_le ( z ^ 2 + c ) c;
  unfold step; norm_num at *; linarith

/-! ## The escape lemma

If `‖z‖ > 2` and `‖c‖ ≤ ‖z‖`, then a single step strictly increases the norm and
preserves the two hypotheses; iterating gives geometric growth. -/

/-
One step: from `2 < ‖z‖` and `‖c‖ ≤ ‖z‖` we get `‖z‖ < ‖step c z‖`.
-/
theorem step_norm_grow {c z : ℂ} (hz : 2 < ‖z‖) (hc : ‖c‖ ≤ ‖z‖) :
    ‖z‖ < ‖step c z‖ := by
  exact lt_of_lt_of_le ( by nlinarith ) ( step_norm_lower c z )

/-
**Geometric escape**: under the escape hypotheses, the `n`-th iterate of
`step c` starting from `z` has norm at least `‖z‖·(‖z‖-1)^n`.
-/
theorem iterate_norm_ge {c z : ℂ} (hz : 2 < ‖z‖) (hc : ‖c‖ ≤ ‖z‖) (n : ℕ) :
    ‖z‖ * (‖z‖ - 1) ^ n ≤ ‖(step c)^[n] z‖ := by
  induction' n with n ih;
  · norm_num;
  · -- By Lemma 2, ‖step c^[n+1] z‖ ≥ ‖step c^[n] z‖^2 - ‖c‖.
    have h_step : ‖(step c)^[n+1] z‖ ≥ ‖(step c)^[n] z‖^2 - ‖c‖ := by
      simpa only [ Function.iterate_succ_apply' ] using step_norm_lower c _;
    rw [ pow_succ' ];
    nlinarith [ show ‖( step c )^[n] z‖ ≥ ‖z‖ from le_trans ( le_mul_of_one_le_right ( by positivity ) ( one_le_pow₀ ( by linarith ) ) ) ih ]

/-
The iterated norms are unbounded once we start beyond the escape radius.
-/
theorem iterate_norm_unbounded {c z : ℂ} (hz : 2 < ‖z‖) (hc : ‖c‖ ≤ ‖z‖)
    (R : ℝ) : ∃ n, R < ‖(step c)^[n] z‖ := by
  have h_unbounded : Filter.Tendsto (fun n => ‖(step c)^[n] z‖) Filter.atTop Filter.atTop := by
    have h_unbounded : Filter.Tendsto (fun n => ‖z‖ * (‖z‖ - 1) ^ n) Filter.atTop Filter.atTop := by
      exact Filter.Tendsto.const_mul_atTop ( by linarith ) ( tendsto_pow_atTop_atTop_of_one_lt ( by linarith ) );
    exact Filter.tendsto_atTop_mono ( fun n => iterate_norm_ge hz hc n ) h_unbounded;
  exact ( h_unbounded.eventually_gt_atTop R ) |> fun h => h.exists

/-! ## Escape criterion and containment -/

/-
**Escape criterion**: if `‖c‖ > 2`, the orbit of `0` is unbounded, so
`c ∉ Mandelbrot`.
-/
theorem not_boundedOrbit_of_two_lt {c : ℂ} (hc : 2 < ‖c‖) : ¬ BoundedOrbit c := by
  rintro ⟨ R, hR ⟩;
  obtain ⟨ n, hn ⟩ := iterate_norm_unbounded hc ( by linarith ) R;
  exact hn.not_ge ( by simpa only [ ← orbit_succ_iterate ] using hR ( n + 1 ) )

/-- `c ∉ Mandelbrot` whenever `‖c‖ > 2`. -/
theorem not_mem_mandelbrot_of_two_lt {c : ℂ} (hc : 2 < ‖c‖) :
    c ∉ Mandelbrot := not_boundedOrbit_of_two_lt hc

/-- **Containment in the disk of radius 2**: every parameter in the Mandelbrot
set has norm at most `2`. -/
theorem mandelbrot_norm_le_two {c : ℂ} (hc : c ∈ Mandelbrot) : ‖c‖ ≤ 2 := by
  by_contra h
  push_neg at h
  exact not_boundedOrbit_of_two_lt h hc

/-- `Mandelbrot ⊆ closedBall 0 2`. -/
theorem mandelbrot_subset_closedBall :
    Mandelbrot ⊆ Metric.closedBall (0 : ℂ) 2 := by
  intro c hc
  simpa [Metric.mem_closedBall, dist_eq_norm] using mandelbrot_norm_le_two hc

/-! ## Concrete membership examples -/

/-- The origin belongs to the Mandelbrot set: the orbit of `0` for `c = 0` is
constantly `0`. -/
theorem zero_mem_mandelbrot : (0 : ℂ) ∈ Mandelbrot := by
  refine ⟨0, ?_⟩
  intro n
  have : orbit (0 : ℂ) n = 0 := by
    induction n with
    | zero => rfl
    | succ k ih => simp [orbit, step, ih]
  simp [this]

/-
For `c = -1` the orbit of `0` is the 2-cycle `0, -1, 0, -1, …`; in particular
each term has norm `≤ 1`.
-/
theorem orbit_neg_one_bound (n : ℕ) : ‖orbit (-1 : ℂ) n‖ ≤ 1 := by
  -- By induction on $n$, we can show that $orbit(-1, n)$ is either $0$ or $-1$.
  have h_ind : ∀ n, orbit (-1) n = 0 ∨ orbit (-1) n = -1 := by
    intro n;
    induction n <;> aesop;
  cases h_ind n <;> norm_num [ ‹_› ]

/-- `-1` belongs to the Mandelbrot set (the center of the period-2 bulb). -/
theorem neg_one_mem_mandelbrot : (-1 : ℂ) ∈ Mandelbrot :=
  ⟨1, orbit_neg_one_bound⟩

end MandelbrotNT