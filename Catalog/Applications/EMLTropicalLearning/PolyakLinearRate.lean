import Applications.EMLTropicalLearning.TropicalERM

/-!
# Linear convergence of tropical training with Polyak steps

The fixed-step rate of `SubgradientRate.lean` is `O(1/√n)`, which is optimal for a
*general* nonsmooth convex objective.  Tropical losses are not general: by
`tropL1_sharp_growth` they are **sharp** (they grow at a linear rate away from the
minimizer).  Sharpness is exactly the property that makes subgradient descent with the
Polyak step size converge *geometrically*.

Main results:

* `polyak_step_contraction` — one Polyak step contracts the squared distance to the
  minimizer by the factor `1 - μ²/G²`;
* `polyak_geometric` — hence `(xₙ - z)² ≤ (1 - μ²/G²)ⁿ (x₀ - z)²`;
* `polyak_tendsto` — the iterates converge to the minimizer;
* `tropical_polyak_linear_rate`, `tropical_polyak_tendsto` — instantiation to tropical
  `L¹` training of an EML max-plus monomial on `2m+1` ordered samples, where `μ = 1`
  and `G = N`, so the contraction factor is `1 - 1/N²`.

Comparison with ReLU networks: by `risk_landscape_equivalence` a ReLU network computing
the same function has an identical risk landscape, so it inherits exactly the same
geometric rate — the speed-up comes from the tropical geometry of the loss, not from
the parameterization.
-/

noncomputable section

open Filter Topology Finset EMLTropicalPWL EMLTropicalSGD EMLTropicalERM

namespace EMLTropicalPolyak

/-- One Polyak step for the objective `f` with subgradient oracle `g` and known optimal
value `fstar`. -/
def polyakStep (f g : ℝ → ℝ) (fstar x : ℝ) : ℝ :=
  if g x = 0 then x else x - ((f x - fstar) / (g x) ^ 2) * g x

/-- Subgradient descent with Polyak steps. -/
def polyakIter (f g : ℝ → ℝ) (fstar x₀ : ℝ) : ℕ → ℝ
  | 0 => x₀
  | n + 1 => polyakStep f g fstar (polyakIter f g fstar x₀ n)

@[simp] theorem polyakIter_zero (f g : ℝ → ℝ) (fstar x₀ : ℝ) :
    polyakIter f g fstar x₀ 0 = x₀ := rfl

@[simp] theorem polyakIter_succ (f g : ℝ → ℝ) (fstar x₀ : ℝ) (n : ℕ) :
    polyakIter f g fstar x₀ (n + 1) = polyakStep f g fstar (polyakIter f g fstar x₀ n) := rfl

/-- Sharpness constant never exceeds the subgradient bound. -/
theorem sharp_le_subgradient_bound {f g : ℝ → ℝ} (hg : IsSubgradientOracle f g)
    {G μ fstar z : ℝ} (hG : ∀ x, |g x| ≤ G)
    (hstar : f z = fstar) (hsharp : ∀ x, fstar + μ * |x - z| ≤ f x) : μ ≤ G := by
  have h1 : fstar + μ * |z + 1 - z| ≤ f (z + 1) := hsharp (z + 1)
  have h2 := hg (z + 1) z
  have h3 : |g (z + 1)| ≤ G := hG (z + 1)
  have h4 : g (z + 1) * (z - (z + 1)) = -g (z + 1) := by ring
  have h5 : g (z + 1) ≤ |g (z + 1)| := le_abs_self _
  simp only [add_sub_cancel_left, abs_one, mul_one] at h1
  rw [h4, hstar] at h2
  linarith

/-- **One-step contraction.**  Under sharpness with constant `μ` and subgradient bound
`G`, a Polyak step multiplies the squared distance to the minimizer by `1 - μ²/G²`. -/
theorem polyak_step_contraction {f g : ℝ → ℝ} (hg : IsSubgradientOracle f g)
    {G μ fstar z : ℝ} (hG : ∀ x, |g x| ≤ G) (hGpos : 0 < G) (hμ : 0 < μ)
    (hstar : f z = fstar) (hsharp : ∀ x, fstar + μ * |x - z| ≤ f x) (x : ℝ) :
    (polyakStep f g fstar x - z) ^ 2 ≤ (1 - μ ^ 2 / G ^ 2) * (x - z) ^ 2 := by
  have hμG : μ ≤ G := sharp_le_subgradient_bound hg hG hstar hsharp
  have hGμ : 0 ≤ 1 - μ ^ 2 / G ^ 2 := by
    have h1 : μ ^ 2 ≤ G ^ 2 := by nlinarith
    have h2 : (0:ℝ) < G ^ 2 := by positivity
    rw [sub_nonneg, div_le_one h2]
    exact h1
  by_cases hgx : g x = 0
  · have hxz : x = z := by
      have h1 := hg x z
      rw [hgx, hstar] at h1
      have h2 := hsharp x
      have h3 : μ * |x - z| ≤ 0 := by simp at h1; linarith
      have h4 : 0 ≤ |x - z| := abs_nonneg _
      have h5 : |x - z| = 0 := by nlinarith
      have := abs_eq_zero.mp h5
      linarith
    have hgz : g z = 0 := by rw [← hxz]; exact hgx
    rw [hxz]
    simp [polyakStep, hgz]
  · have hgg : (0:ℝ) < (g x) ^ 2 := by positivity
    set d := f x - fstar with hd
    have hdpos : 0 ≤ d := by
      have := hsharp x
      have := abs_nonneg (x - z)
      have : 0 ≤ μ * |x - z| := by positivity
      simp only [hd]
      linarith [hsharp x]
    have hdsharp : μ * |x - z| ≤ d := by
      have := hsharp x
      simp only [hd]
      linarith
    have hgrad : d ≤ g x * (x - z) := by
      have := hg x z
      rw [hstar] at this
      simp only [hd]
      nlinarith [this]
    set t := d / (g x) ^ 2 with ht
    have htnonneg : 0 ≤ t := by positivity
    have htgg : t * (g x) ^ 2 = d := by
      rw [ht]
      field_simp
    have hstep : polyakStep f g fstar x = x - t * g x := by
      simp [polyakStep, hgx, ht, hd]
    have hexpand : (x - t * g x - z) ^ 2
        = (x - z) ^ 2 - 2 * t * (g x * (x - z)) + t ^ 2 * (g x) ^ 2 := by ring
    have hsq : t ^ 2 * (g x) ^ 2 = t * d := by
      have : t ^ 2 * (g x) ^ 2 = t * (t * (g x) ^ 2) := by ring
      rw [this, htgg]
    have hkey : (x - t * g x - z) ^ 2 ≤ (x - z) ^ 2 - t * d := by
      rw [hexpand, hsq]
      nlinarith [mul_le_mul_of_nonneg_left hgrad htnonneg]
    have hdsq : μ ^ 2 * (x - z) ^ 2 ≤ d ^ 2 := by
      have h1 : 0 ≤ μ * |x - z| := by positivity
      have h2 : (μ * |x - z|) ^ 2 ≤ d ^ 2 := by nlinarith
      calc μ ^ 2 * (x - z) ^ 2 = (μ * |x - z|) ^ 2 := by
            rw [mul_pow, sq_abs]
        _ ≤ d ^ 2 := h2
    have hgG2 : (g x) ^ 2 ≤ G ^ 2 := by
      have h1 : |g x| ≤ G := hG x
      have h2 : (0:ℝ) ≤ |g x| := abs_nonneg _
      nlinarith [sq_abs (g x)]
    have htd : μ ^ 2 / G ^ 2 * (x - z) ^ 2 ≤ t * d := by
      have hG2 : (0:ℝ) < G ^ 2 := by positivity
      have hfrac : μ ^ 2 * (x - z) ^ 2 / G ^ 2 ≤ d * d / (g x) ^ 2 := by
        rw [div_le_div_iff₀ hG2 hgg]
        nlinarith [sq_nonneg (x - z), hdsq, hgG2, hdpos]
      have htd' : t * d = d * d / (g x) ^ 2 := by
        rw [ht]; ring
      rw [htd']
      calc μ ^ 2 / G ^ 2 * (x - z) ^ 2 = μ ^ 2 * (x - z) ^ 2 / G ^ 2 := by ring
        _ ≤ d * d / (g x) ^ 2 := hfrac
    rw [hstep]
    nlinarith [hkey, htd]

/-- **Geometric convergence** of Polyak-step subgradient descent on a sharp objective. -/
theorem polyak_geometric {f g : ℝ → ℝ} (hg : IsSubgradientOracle f g)
    {G μ fstar z : ℝ} (hG : ∀ x, |g x| ≤ G) (hGpos : 0 < G) (hμ : 0 < μ)
    (hstar : f z = fstar) (hsharp : ∀ x, fstar + μ * |x - z| ≤ f x) (x₀ : ℝ) (n : ℕ) :
    (polyakIter f g fstar x₀ n - z) ^ 2 ≤ (1 - μ ^ 2 / G ^ 2) ^ n * (x₀ - z) ^ 2 := by
  have hμG : μ ≤ G := sharp_le_subgradient_bound hg hG hstar hsharp
  have hr : 0 ≤ 1 - μ ^ 2 / G ^ 2 := by
    have h1 : μ ^ 2 ≤ G ^ 2 := by nlinarith
    have h2 : (0:ℝ) < G ^ 2 := by positivity
    rw [sub_nonneg, div_le_one h2]
    exact h1
  induction n with
  | zero => simp
  | succ n ih =>
      have hstep := polyak_step_contraction hg hG hGpos hμ hstar hsharp
        (polyakIter f g fstar x₀ n)
      calc (polyakIter f g fstar x₀ (n + 1) - z) ^ 2
          ≤ (1 - μ ^ 2 / G ^ 2) * (polyakIter f g fstar x₀ n - z) ^ 2 := by
            rw [polyakIter_succ]; exact hstep
        _ ≤ (1 - μ ^ 2 / G ^ 2) * ((1 - μ ^ 2 / G ^ 2) ^ n * (x₀ - z) ^ 2) :=
            mul_le_mul_of_nonneg_left ih hr
        _ = (1 - μ ^ 2 / G ^ 2) ^ (n + 1) * (x₀ - z) ^ 2 := by ring

/-- Polyak-step subgradient descent converges to the minimizer of a sharp objective. -/
theorem polyak_tendsto {f g : ℝ → ℝ} (hg : IsSubgradientOracle f g)
    {G μ fstar z : ℝ} (hG : ∀ x, |g x| ≤ G) (hGpos : 0 < G) (hμ : 0 < μ)
    (hstar : f z = fstar) (hsharp : ∀ x, fstar + μ * |x - z| ≤ f x) (x₀ : ℝ) :
    Tendsto (fun n => polyakIter f g fstar x₀ n) atTop (𝓝 z) := by
  set r := 1 - μ ^ 2 / G ^ 2 with hrdef
  have hG2 : (0:ℝ) < G ^ 2 := by positivity
  have hμ2 : (0:ℝ) < μ ^ 2 := by positivity
  have hrlt : r < 1 := by
    rw [hrdef]
    have : 0 < μ ^ 2 / G ^ 2 := by positivity
    linarith
  have hμG : μ ≤ G := sharp_le_subgradient_bound hg hG hstar hsharp
  have hrnonneg : 0 ≤ r := by
    have h1 : μ ^ 2 ≤ G ^ 2 := by nlinarith
    rw [hrdef, sub_nonneg, div_le_one hG2]
    exact h1
  have hpow : Tendsto (fun n : ℕ => r ^ n * (x₀ - z) ^ 2) atTop (𝓝 0) := by
    have h := tendsto_pow_atTop_nhds_zero_of_lt_one hrnonneg hrlt
    simpa using h.mul_const ((x₀ - z) ^ 2)
  have hsq : Tendsto (fun n : ℕ => (polyakIter f g fstar x₀ n - z) ^ 2) atTop (𝓝 0) := by
    refine squeeze_zero (fun n => sq_nonneg _) (fun n => ?_) hpow
    exact polyak_geometric hg hG hGpos hμ hstar hsharp x₀ n
  have habs : Tendsto (fun n : ℕ => |polyakIter f g fstar x₀ n - z|) atTop (𝓝 0) := by
    have hcont : Tendsto (fun u : ℝ => Real.sqrt u) (𝓝 0) (𝓝 0) := by
      simpa using (Real.continuous_sqrt.tendsto 0)
    have := hcont.comp hsq
    simpa [Function.comp_def, Real.sqrt_sq_eq_abs] using this
  have : Tendsto (fun n : ℕ => (polyakIter f g fstar x₀ n - z)) atTop (𝓝 0) := by
    rw [tendsto_zero_iff_abs_tendsto_zero]
    exact habs
  have hz := this.add (tendsto_const_nhds (x := z) (f := atTop (α := ℕ)))
  simpa using hz

/-! ## Instantiation: tropical `L¹` training of an EML monomial -/

/-- **Linear convergence of tropical EML training.**  With Polyak steps the squared
parameter error contracts by the factor `1 - 1/N²` at every iteration, `N = 2m+1` the
sample size — exponentially faster than the `O(1/√n)` fixed-step rate. -/
theorem tropical_polyak_linear_rate {y : ℕ → ℝ} {m : ℕ}
    (hy : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → y i ≤ y j) (x₀ : ℝ) (n : ℕ) :
    (polyakIter (tropL1Loss y (2 * m + 1)) (tropL1Sub y (2 * m + 1))
        (tropL1Loss y (2 * m + 1) (y m)) x₀ n - y m) ^ 2
      ≤ (1 - 1 / ((2 * m + 1 : ℕ) : ℝ) ^ 2) ^ n * (x₀ - y m) ^ 2 := by
  have hNpos : (0:ℝ) < ((2 * m + 1 : ℕ) : ℝ) := by
    have : (0:ℕ) < 2 * m + 1 := by omega
    exact_mod_cast this
  have hsharp : ∀ x : ℝ,
      tropL1Loss y (2 * m + 1) (y m) + 1 * |x - y m| ≤ tropL1Loss y (2 * m + 1) x := by
    intro x
    have := tropL1_sharp_growth hy x
    linarith
  have h := polyak_geometric (f := tropL1Loss y (2 * m + 1)) (g := tropL1Sub y (2 * m + 1))
    (tropL1_isSubgradientOracle y (2 * m + 1)) (G := ((2 * m + 1 : ℕ) : ℝ)) (μ := 1)
    (tropL1Sub_abs_le y (2 * m + 1)) hNpos one_pos rfl hsharp x₀ n
  simpa using h

/-- The Polyak-trained tropical parameter converges to the median parameter, which by
`tropL1_minimizer_unique` is the unique minimizer of the tropical loss. -/
theorem tropical_polyak_tendsto {y : ℕ → ℝ} {m : ℕ}
    (hy : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → y i ≤ y j) (x₀ : ℝ) :
    Tendsto (fun n => polyakIter (tropL1Loss y (2 * m + 1)) (tropL1Sub y (2 * m + 1))
      (tropL1Loss y (2 * m + 1) (y m)) x₀ n) atTop (𝓝 (y m)) := by
  have hNpos : (0:ℝ) < ((2 * m + 1 : ℕ) : ℝ) := by
    have : (0:ℕ) < 2 * m + 1 := by omega
    exact_mod_cast this
  have hsharp : ∀ x : ℝ,
      tropL1Loss y (2 * m + 1) (y m) + 1 * |x - y m| ≤ tropL1Loss y (2 * m + 1) x := by
    intro x
    have := tropL1_sharp_growth hy x
    linarith
  exact polyak_tendsto (f := tropL1Loss y (2 * m + 1)) (g := tropL1Sub y (2 * m + 1))
    (tropL1_isSubgradientOracle y (2 * m + 1)) (G := ((2 * m + 1 : ℕ) : ℝ)) (μ := 1)
    (tropL1Sub_abs_le y (2 * m + 1)) hNpos one_pos rfl hsharp x₀

/-- The Polyak-trained model converges pointwise to a tropical rational function that
minimizes the tropical loss. -/
theorem tropical_polyak_model_tendsto {y : ℕ → ℝ} {m : ℕ}
    (hy : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → y i ≤ y j) (x₀ z : ℝ) :
    Tendsto (fun n => tropModel (polyakIter (tropL1Loss y (2 * m + 1))
        (tropL1Sub y (2 * m + 1)) (tropL1Loss y (2 * m + 1) (y m)) x₀ n) z) atTop
      (𝓝 (tropModel (y m) z)) := by
  have h := tropical_polyak_tendsto hy x₀
  simpa [tropModel] using h.const_add z


/-! ## Boundary of the theory: fixed steps can fail entirely

Sharpness makes Polyak steps converge geometrically, but a *fixed* step that is too
large diverges from the minimizer forever: the piecewise-linear subgradient has constant
magnitude `N` away from the data, so the iterates jump over the optimum by a fixed
amount.  The following is an exact, kernel-checked two-cycle for the samples `0,1,2`
(median `1`) with step `η = 3`.
-/

/-- With samples `0, 1, 2` and the too-large fixed step `η = 3`, the iterates started at
`3` form an exact 2-cycle `3, -6, 3, -6, …`. -/
theorem fixedStep_two_cycle (n : ℕ) :
    gdIter (tropL1Sub (fun i => (i : ℝ)) 3) 3 3 n = if n % 2 = 0 then 3 else -6 := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [gdIter_succ, ih]
      by_cases h : n % 2 = 0
      · rw [if_pos h, if_neg (by omega : ¬ (n + 1) % 2 = 0)]
        norm_num [tropL1Sub, Finset.sum_range_succ]
      · rw [if_neg h, if_pos (by omega : (n + 1) % 2 = 0)]
        norm_num [tropL1Sub, Finset.sum_range_succ]

/-- Consequently fixed-step subgradient descent with that step never comes within
distance `2` of the unique minimizer: the `O(1/√n)` guarantee genuinely needs the step
size to shrink, whereas the Polyak rule needs no tuning at all. -/
theorem fixedStep_never_converges (n : ℕ) :
    2 ≤ |gdIter (tropL1Sub (fun i => (i : ℝ)) 3) 3 3 n - 1| := by
  rw [fixedStep_two_cycle n]
  by_cases h : n % 2 = 0
  · rw [if_pos h]; norm_num
  · rw [if_neg h]; norm_num

/-! ## Kernel-checked instances -/

-- One Polyak step on the three-sample tropical loss with data `0, 1, 2` from `x₀ = 0`
-- lands exactly on the median `1` (the subgradient there is `-1` and the gap is `1`).
example : polyakIter (tropL1Loss (fun i => (i : ℝ)) 3) (tropL1Sub (fun i => (i : ℝ)) 3)
    (tropL1Loss (fun i => (i : ℝ)) 3 1) 0 1 = 1 := by
  norm_num [polyakIter, polyakStep, tropL1Loss, tropL1Sub, Finset.sum_range_succ]

end EMLTropicalPolyak