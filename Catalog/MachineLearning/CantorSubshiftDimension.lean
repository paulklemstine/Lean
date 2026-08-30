import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness

/-!
# Cylinders, total disconnectedness and the golden-mean box dimension

This is the second cycle of the study of the Cantor truth space
`Cantor = ℕ → Bool` with the first-disagreement ultrametric of
`Shared.GraphTheory.FractalTruthMetric`, continuing
`MachineLearning.CantorCompactness` (completeness, total boundedness, compactness,
closedness of the golden-mean subshift and the `fib (n+2)` covering count).

The results here fall into three groups.

1. **Spectrum discreteness and clopen cylinders.**  The distance takes only the values
   `0` and `2⁻ᵖ`, so a strict inequality `dist x y < 2^{1-n}` is *equivalent* to the
   closed condition `AgreeTo n x y`.  Cylinders are therefore simultaneously open balls
   and closed balls, and the space is totally separated (hence totally disconnected).

2. **Size.** An explicit continuous injection `spread : Cantor → Cantor` with image inside
   the golden-mean subshift (interleave the bits with `false`) shows the subshift is
   uncountable, while `interior_goldenMean_eq_empty` shows it is nowhere dense: it is a
   genuine "fat but thin" fractal.

3. **Box dimension.** Combining the exact count `fib (n+2)` of `2⁻ⁿ`-cylinders of the
   subshift with the sharp two-sided estimate `φ ^ n ≤ fib (n+2) ≤ φ ^ (n+1)` gives

   `log (covering number at scale 2⁻ⁿ) / (n log 2) → log φ / log 2`,

   i.e. the box dimension of the golden-mean subshift is `log φ / log 2 ≈ 0.694`.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Metric Filter
open scoped Topology

instance instNonemptyCantor : Nonempty Cantor := ⟨(fun _ => false : ℕ → Bool)⟩

/-! ## The distance spectrum is discrete -/

/-- **Spectrum discreteness.**  Because the only possible distances are `0` and the powers
`2⁻ᵖ`, the *strict* inequality `dist x y < 2^{1-n}` is equivalent to the *closed* condition
`AgreeTo n x y`. -/
theorem agreeTo_iff_dist_lt (n : ℕ) (x y : Cantor) :
    AgreeTo n x y ↔ dist x y < (2 : ℝ) ^ (1 - (n : ℤ)) := by
  by_cases hxy : x = y
  · subst hxy
    constructor
    · intro _
      rw [dist_self]; positivity
    · intro _ k _; rfl
  · have hd : dist x y = (2 : ℝ) ^ (-(firstDiff x y : ℤ)) := by
      rw [dist_eq, cantorDist, if_neg hxy]
    rw [hd, agreeTo_iff_le_firstDiff hxy,
      zpow_lt_zpow_iff_right₀ (by norm_num : (1 : ℝ) < 2)]
    omega

/-! ## Cylinders are clopen -/

/-- The depth-`n` cylinder through `x`: all streams agreeing with `x` on the first `n`
coordinates. -/
def cylinder (n : ℕ) (x : Cantor) : Set Cantor := {y | AgreeTo n x y}

theorem mem_cylinder {n : ℕ} {x y : Cantor} : y ∈ cylinder n x ↔ AgreeTo n x y := Iff.rfl

theorem cylinder_eq_closedBall (n : ℕ) (x : Cantor) :
    cylinder n x = closedBall x ((2 : ℝ) ^ (-(n : ℤ))) := by
  ext y
  rw [mem_cylinder, mem_closedBall, dist_comm, dist_le_iff_agreeTo]

theorem cylinder_eq_ball (n : ℕ) (x : Cantor) :
    cylinder n x = ball x ((2 : ℝ) ^ (1 - (n : ℤ))) := by
  ext y
  rw [mem_cylinder, mem_ball, dist_comm, agreeTo_iff_dist_lt]

/-- **Cylinders are clopen**: an open ball and a closed ball at once. -/
theorem isClopen_cylinder (n : ℕ) (x : Cantor) : IsClopen (cylinder n x) :=
  ⟨by rw [cylinder_eq_closedBall]; exact isClosed_closedBall,
   by rw [cylinder_eq_ball]; exact isOpen_ball⟩

theorem self_mem_cylinder (n : ℕ) (x : Cantor) : x ∈ cylinder n x := fun _ _ => rfl

/-- Distinct streams are separated by a cylinder. -/
theorem exists_cylinder_separating {x y : Cantor} (hxy : x ≠ y) :
    ∃ n, y ∉ cylinder n x := by
  refine ⟨firstDiff x y + 1, ?_⟩
  intro hy
  exact firstDiff_spec hxy (hy (firstDiff x y) (Nat.lt_succ_self _))

/-- **The Cantor truth space is totally separated.**  Any two distinct streams are split by a
clopen cylinder. -/
instance instTotallySeparatedSpaceCantor : TotallySeparatedSpace Cantor := by
  constructor
  intro x _ y _ hxy
  obtain ⟨n, hn⟩ := exists_cylinder_separating hxy
  refine ⟨cylinder n x, (cylinder n x)ᶜ, (isClopen_cylinder n x).2,
    (isClopen_cylinder n x).1.isOpen_compl, self_mem_cylinder n x, hn, ?_, ?_⟩
  · intro z _
    by_cases hz : z ∈ cylinder n x
    · exact Or.inl hz
    · exact Or.inr hz
  · exact disjoint_compl_right

/-! ## Uncountability of the space and of the subshift -/

/-- **Cantor diagonal argument**: the truth space is uncountable. -/
theorem cantor_uncountable : Uncountable Cantor := by
  rw [← not_countable_iff]
  intro hc
  obtain ⟨g, hg⟩ := exists_surjective_nat Cantor
  obtain ⟨n, hn⟩ := hg (fun k => !(g k k) : Cantor)
  have h := congrFun hn n
  simp at h

/-- Interleave the bits of a stream with `false`s. -/
def spread (x : Cantor) : Cantor := fun k => if k % 2 = 0 then x (k / 2) else false

/-- Interleaving lands inside the golden-mean subshift: consecutive `true`s are impossible
because every odd coordinate is `false`. -/
theorem spread_mem_goldenMean (x : Cantor) : spread x ∈ GoldenMean := by
  intro k hk
  by_cases h0 : k % 2 = 0
  · have h1 : (k + 1) % 2 ≠ 0 := by omega
    have hf : spread x (k + 1) = false := by simp [spread, h1]
    rw [hf] at hk
    simp at hk
  · have hf : spread x k = false := by simp [spread, h0]
    rw [hf] at hk
    simp at hk

theorem spread_injective : Function.Injective spread := by
  intro x y h
  funext k
  have hk := congrFun h (2 * k)
  have h1 : (2 * k) % 2 = 0 := by omega
  have h2 : (2 * k) / 2 = k := by omega
  simpa [spread, h1, h2] using hk

/-- Interleaving is continuous (indeed distance non-increasing). -/
theorem dist_spread_le (x y : Cantor) : dist (spread x) (spread y) ≤ dist x y := by
  by_cases hxy : x = y
  · subst hxy; simp
  · have hd : dist x y = (2 : ℝ) ^ (-(firstDiff x y : ℤ)) := by
      rw [dist_eq, cantorDist, if_neg hxy]
    have hA : AgreeTo (firstDiff x y) x y := agreeTo_firstDiff x y
    have hAs : AgreeTo (firstDiff x y) (spread x) (spread y) := by
      intro k hk
      by_cases h2 : k % 2 = 0
      · have : k / 2 < firstDiff x y := by omega
        simp only [spread, h2, if_true]
        exact hA _ this
      · simp [spread, h2]
    rw [hd]
    exact (dist_le_iff_agreeTo _ _ _).mpr hAs

theorem continuous_spread : Continuous spread :=
  (LipschitzWith.of_dist_le_mul (K := 1) (by simpa using dist_spread_le)).continuous

/-- **The golden-mean subshift is uncountable**: it contains a homeomorphic copy of the whole
truth space. -/
theorem goldenMean_uncountable : ¬ GoldenMean.Countable := by
  intro h
  have hsub : Set.range spread ⊆ GoldenMean := by
    rintro _ ⟨x, rfl⟩
    exact spread_mem_goldenMean x
  have h2 : (Set.range spread).Countable := h.mono hsub
  rw [Set.countable_coe_iff.symm] at h2
  have : Countable Cantor := Countable.of_equiv _ (Equiv.ofInjective spread spread_injective).symm
  exact (not_countable_iff.mpr cantor_uncountable) this

/-! ## The subshift is nowhere dense -/

/-- The stream agreeing with `x` up to `n` and then constantly `true`. -/
def spike (n : ℕ) (x : Cantor) : Cantor := fun k => if k < n then x k else true

theorem agreeTo_spike (n : ℕ) (x : Cantor) : AgreeTo n x (spike n x) := by
  intro k hk
  simp [spike, hk]

theorem spike_not_mem_goldenMean (n : ℕ) (x : Cantor) : spike n x ∉ GoldenMean := by
  intro h
  exact h n ⟨by simp [spike], by simp [spike]⟩

/-- **The golden-mean subshift has empty interior**: arbitrarily close to any stream there is
a stream with two consecutive `true`s. -/
theorem interior_goldenMean_eq_empty : interior GoldenMean = ∅ := by
  rw [Set.eq_empty_iff_forall_notMem]
  intro x hx
  obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.mp isOpen_interior x hx
  obtain ⟨n, hn⟩ := exists_two_zpow_lt hε
  have hd : dist (spike n x) x < ε := by
    rw [dist_comm]
    exact lt_of_le_of_lt ((dist_le_iff_agreeTo _ _ n).mpr (agreeTo_spike n x)) hn
  have : spike n x ∈ GoldenMean :=
    interior_subset (hball (mem_ball.mpr hd))
  exact spike_not_mem_goldenMean n x this

/-- The subshift is nowhere dense. -/
theorem goldenMean_nowhereDense : interior (closure GoldenMean) = ∅ := by
  rw [isClosed_goldenMean.closure_eq]
  exact interior_goldenMean_eq_empty

/-! ## Sharp Fibonacci growth -/

/-- Lower bound: `φ ^ n ≤ fib (n + 2)`. -/
theorem goldenRatio_pow_le_fib : ∀ n : ℕ, Real.goldenRatio ^ n ≤ (Nat.fib (n + 2) : ℝ)
  | 0 => by norm_num
  | 1 => by
      have h := Real.goldenRatio_lt_two
      norm_num
      linarith
  | (n + 2) => by
      have ih1 := goldenRatio_pow_le_fib (n + 1)
      have ih2 := goldenRatio_pow_le_fib n
      have hsq : Real.goldenRatio ^ 2 = Real.goldenRatio + 1 := Real.goldenRatio_sq
      have hfib : Nat.fib (n + 2 + 2) = Nat.fib (n + 2) + Nat.fib (n + 2 + 1) := Nat.fib_add_two
      have hcast : ((Nat.fib (n + 2 + 2) : ℕ) : ℝ)
          = (Nat.fib (n + 2) : ℝ) + (Nat.fib (n + 1 + 2) : ℝ) := by
        rw [hfib]; push_cast; ring_nf
      have hexp : Real.goldenRatio ^ (n + 2)
          = Real.goldenRatio ^ (n + 1) + Real.goldenRatio ^ n := by
        have : Real.goldenRatio ^ (n + 2) = Real.goldenRatio ^ n * Real.goldenRatio ^ 2 := by
          ring
        rw [this, hsq]; ring
      rw [hcast, hexp]
      linarith

/-- Upper bound: `fib (n + 2) ≤ φ ^ (n + 1)`. -/
theorem fib_le_goldenRatio_pow : ∀ n : ℕ, (Nat.fib (n + 2) : ℝ) ≤ Real.goldenRatio ^ (n + 1)
  | 0 => by
      have h := Real.one_lt_goldenRatio
      norm_num
      linarith
  | 1 => by
      have hsq : Real.goldenRatio ^ 2 = Real.goldenRatio + 1 := Real.goldenRatio_sq
      have h := Real.one_lt_goldenRatio
      norm_num [hsq]
      linarith
  | (n + 2) => by
      have ih1 := fib_le_goldenRatio_pow (n + 1)
      have ih2 := fib_le_goldenRatio_pow n
      have hsq : Real.goldenRatio ^ 2 = Real.goldenRatio + 1 := Real.goldenRatio_sq
      have hfib : Nat.fib (n + 2 + 2) = Nat.fib (n + 2) + Nat.fib (n + 2 + 1) := Nat.fib_add_two
      have hcast : ((Nat.fib (n + 2 + 2) : ℕ) : ℝ)
          = (Nat.fib (n + 2) : ℝ) + (Nat.fib (n + 1 + 2) : ℝ) := by
        rw [hfib]; push_cast; ring_nf
      have hexp : Real.goldenRatio ^ (n + 2 + 1)
          = Real.goldenRatio ^ (n + 1 + 1) + Real.goldenRatio ^ (n + 1) := by
        have : Real.goldenRatio ^ (n + 2 + 1) = Real.goldenRatio ^ (n + 1) * Real.goldenRatio ^ 2 :=
          by ring
        rw [this, hsq]; ring
      rw [hcast, hexp]
      linarith

/-! ## The box dimension of the golden-mean subshift -/

/-- The covering number of the subshift at scale `2⁻ⁿ`. -/
noncomputable def coveringNumber (n : ℕ) : ℕ := (goldenWords n).card

theorem coveringNumber_eq_fib (n : ℕ) : coveringNumber n = Nat.fib (n + 2) :=
  card_goldenWords n

theorem log_coveringNumber_lower (n : ℕ) :
    (n : ℝ) * Real.log Real.goldenRatio ≤ Real.log (coveringNumber n) := by
  rw [coveringNumber_eq_fib]
  have h1 : (0 : ℝ) < Real.goldenRatio ^ n := by
    exact pow_pos Real.goldenRatio_pos n
  have h2 := goldenRatio_pow_le_fib n
  calc (n : ℝ) * Real.log Real.goldenRatio = Real.log (Real.goldenRatio ^ n) := by
        rw [Real.log_pow]
    _ ≤ Real.log (Nat.fib (n + 2) : ℝ) := Real.log_le_log h1 h2

theorem log_coveringNumber_upper (n : ℕ) :
    Real.log (coveringNumber n) ≤ ((n : ℝ) + 1) * Real.log Real.goldenRatio := by
  rw [coveringNumber_eq_fib]
  have h1 : (0 : ℝ) < (Nat.fib (n + 2) : ℝ) := by
    exact_mod_cast Nat.fib_pos.mpr (by omega)
  have h2 := fib_le_goldenRatio_pow n
  calc Real.log (Nat.fib (n + 2) : ℝ) ≤ Real.log (Real.goldenRatio ^ (n + 1)) :=
        Real.log_le_log h1 h2
    _ = ((n : ℝ) + 1) * Real.log Real.goldenRatio := by rw [Real.log_pow]; push_cast; ring

/-- **Exponential growth rate.**  The number of distinct depth-`n` observations of the
golden-mean subshift grows like `φ ⁿ`: its logarithmic growth rate is `log φ`. -/
theorem tendsto_log_coveringNumber :
    Tendsto (fun n : ℕ => Real.log (coveringNumber n) / n) atTop
      (𝓝 (Real.log Real.goldenRatio)) := by
  have hlogpos : 0 < Real.log Real.goldenRatio :=
    Real.log_pos Real.one_lt_goldenRatio
  have hupper : Tendsto
      (fun n : ℕ => Real.log Real.goldenRatio + Real.log Real.goldenRatio / n) atTop
      (𝓝 (Real.log Real.goldenRatio)) := by
    have h := tendsto_const_div_atTop_nhds_zero_nat (Real.log Real.goldenRatio)
    simpa using (tendsto_const_nhds (x := Real.log Real.goldenRatio) (f := atTop)).add h
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    rw [le_div_iff₀ hn']
    have := log_coveringNumber_lower n
    linarith [this]
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    rw [div_le_iff₀ hn']
    have h := log_coveringNumber_upper n
    have : ((n : ℝ) + 1) * Real.log Real.goldenRatio
        = (Real.log Real.goldenRatio + Real.log Real.goldenRatio / n) * n := by
      field_simp
    linarith [this ▸ h]

/-- **Box dimension of the golden-mean subshift.**  At scale `2⁻ⁿ` the subshift needs exactly
`fib (n+2)` balls, and therefore its box-counting dimension is `log φ / log 2`. -/
theorem tendsto_boxDimension :
    Tendsto (fun n : ℕ => Real.log (coveringNumber n) / (n * Real.log 2)) atTop
      (𝓝 (Real.log Real.goldenRatio / Real.log 2)) := by
  have h := tendsto_log_coveringNumber.div_const (Real.log 2)
  refine h.congr (fun n => ?_)
  rw [div_div]

end FractalTruthCompactness