/-
# The starvation slack spectrum of a PTX arbiter

`Physics.PTXStarvationFloor` established the two-sided estimate

```
ideal y  ≤  service y  <  2 · ideal y ,      ideal y = γ d y / (β log(1/p y) + M + γ − r y),
```

for the dyadic (binary exponential backoff) arbiter.  This file determines the *exact* set of
slack ratios that occur, and identifies where the constant `2` comes from.

## Main results

* `ptx_slack_mem_Ico` : the slack `service y / ideal y` always lies in `[1, 2)`.
* `ptx_slack_spectrum_eq` : **every** value of `[1, 2)` is realised by some PTX instance; the
  slack spectrum is *exactly* `Set.Ico 1 2`.  In particular the floor constant `1` is attained
  and the ceiling constant `2` is approached but never attained.
* `ptx_grid_optimal_ceiling_iff` / `ptx_grid_optimal_floor_iff` : for a general arbiter grid of
  ratio `ρ > 1`, the inequality `service ≤ c · ideal` holds for all instances **iff** `ρ ≤ c`,
  and `c · ideal ≤ service` holds for all instances **iff** `c ≤ 1`.  Specialised to `ρ = 2`
  (`ptx_two_optimal_ceiling_iff`) this says the headline factor `2` is not an artefact of the
  argument: it is precisely the grid ratio of the arbiter.
* `gridCeil_mul_base` and `ptx_slack_log_periodic` : the slack function is invariant under
  scaling the demand by the grid ratio, i.e. it is log-periodic with period `log ρ`.  This is
  the structural reason the supremum `ρ` is never attained: the slack orbit is a scale-invariant
  half-open interval.
* `ptx_aggregate_floor` / `ptx_aggregate_lt_two` : the same two-sided bound survives summation
  over a finite family of transport classes, so the factor `2` is also the exact price of
  quantisation for the *total* channel occupancy.
* `ptx_service_lt_of_gap_large` : a quantitative starvation estimate — classes with a large
  transport gap (very rare channels, `p y → 0`) receive arbitrarily little service, which is
  what makes the floor a genuine constraint rather than a vacuous one.
-/

import Physics.PTXStarvationFloor

namespace Physics.PTX

open Real

variable {ι : Type*}

/-! ## 1. Structural properties of the quantiser -/

/-- Scaling the request by the grid ratio scales the quantised window by the grid ratio:
the arbiter is equivariant for the multiplicative action of `ρ^ℤ`. -/
lemma gridCeil_mul_base {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    gridCeil rho (rho * x) = rho * gridCeil rho x := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hlog : Real.logb rho (rho * x) = Real.logb rho x + 1 := by
    rw [Real.logb_mul (ne_of_gt h0) (ne_of_gt hx), Real.logb_self_eq_one hrho]
    ring
  rw [gridCeil, gridCeil, hlog, Int.ceil_add_one, zpow_add₀ (ne_of_gt h0), zpow_one]
  ring

/-- The quantiser is monotone. -/
lemma gridCeil_mono {rho x y : ℝ} (hrho : 1 < rho) (hx : 0 < x) (hxy : x ≤ y) :
    gridCeil rho x ≤ gridCeil rho y := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hy : 0 < y := lt_of_lt_of_le hx hxy
  have hlog : Real.logb rho x ≤ Real.logb rho y := (Real.logb_le_logb hrho hx hy).2 hxy
  have hceil : ⌈Real.logb rho x⌉ ≤ ⌈Real.logb rho y⌉ := Int.ceil_le_ceil hlog
  exact zpow_le_zpow_right₀ (le_of_lt hrho) hceil

/-! ## 2. The dyadic slack spectrum is exactly `[1, 2)` -/

/-- The slack ratio of any transport class lies in `[1, 2)`. -/
theorem ptx_slack_mem_Ico (I : PTXInstance ι) (y : ι) :
    service I y / ideal I y ∈ Set.Ico (1 : ℝ) 2 := by
  have hpos : 0 < ideal I y := ideal_pos I y
  constructor
  · rw [le_div_iff₀ hpos, one_mul]
    exact ptx_ideal_le_service I y
  · rw [div_lt_iff₀ hpos]
    have := ptx_service_lt_two_ideal I y
    linarith

/-- Every ratio in `[1, 2)` is realised: for `t ∈ [1,2)` the one-class exchange with demand
`2/t` has slack exactly `t`. -/
theorem ptx_slack_realised (t : ℝ) (ht1 : 1 ≤ t) (ht2 : t < 2) :
    ∃ (I : PTXInstance Unit) (y : Unit), service I y = t * ideal I y := by
  have ht0 : 0 < t := lt_of_lt_of_le zero_lt_one ht1
  set x : ℝ := 2 / t with hxdef
  have hx1 : 1 < x := by
    rw [hxdef, lt_div_iff₀ ht0]; linarith
  have hx2 : x ≤ 2 := by
    rw [hxdef, div_le_iff₀ ht0]; nlinarith
  have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx1
  refine ⟨witness x hx0, (), ?_⟩
  rw [service_witness_of_mem_Ioc hx1 hx2, witness_ideal x hx0 (), hxdef]
  field_simp

/-- **The slack spectrum.**  The set of achievable ratios `service / ideal` over all PTX
instances is exactly the half-open interval `[1, 2)`. -/
theorem ptx_slack_spectrum_eq :
    {c : ℝ | ∃ (I : PTXInstance Unit) (y : Unit), service I y = c * ideal I y}
      = Set.Ico (1 : ℝ) 2 := by
  ext c
  simp only [Set.mem_setOf_eq, Set.mem_Ico]
  constructor
  · rintro ⟨I, y, hc⟩
    have hpos : 0 < ideal I y := ideal_pos I y
    have hfl : ideal I y ≤ service I y := ptx_ideal_le_service I y
    have hce : service I y < 2 * ideal I y := ptx_service_lt_two_ideal I y
    rw [hc] at hfl hce
    constructor
    · nlinarith
    · nlinarith
  · rintro ⟨h1, h2⟩
    exact ptx_slack_realised c h1 h2

/-! ## 3. General grid ratios: where the factor `2` comes from -/

/-- The service delivered by an arbiter whose backoff windows form the grid `ρ^ℤ`. -/
noncomputable def serviceGrid (rho : ℝ) (I : PTXInstance ι) (y : ι) : ℝ :=
  gridCeil rho (ideal I y)

@[simp] lemma serviceGrid_two (I : PTXInstance ι) (y : ι) : serviceGrid 2 I y = service I y := rfl

/-- No starvation for a general grid ratio. -/
theorem ptx_grid_no_starvation {rho : ℝ} (hrho : 1 < rho) (I : PTXInstance ι) (y : ι) :
    ideal I y ≤ serviceGrid rho I y :=
  self_le_gridCeil hrho (ideal_pos I y)

/-- The grid-`ρ` ceiling. -/
theorem ptx_grid_ceiling {rho : ℝ} (hrho : 1 < rho) (I : PTXInstance ι) (y : ι) :
    serviceGrid rho I y < rho * ideal I y :=
  gridCeil_lt hrho (ideal_pos I y)

/-- Every ratio in `[1, ρ)` occurs for the grid-`ρ` arbiter. -/
theorem ptx_grid_slack_realised {rho : ℝ} (hrho : 1 < rho) (t : ℝ) (ht1 : 1 ≤ t)
    (ht2 : t < rho) :
    ∃ (I : PTXInstance Unit) (y : Unit), serviceGrid rho I y = t * ideal I y := by
  have ht0 : 0 < t := lt_of_lt_of_le zero_lt_one ht1
  have hrho0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  set x : ℝ := rho / t with hxdef
  have hx1 : 1 < x := by rw [hxdef, lt_div_iff₀ ht0]; linarith
  have hx2 : x ≤ rho := by rw [hxdef, div_le_iff₀ ht0]; nlinarith
  have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx1
  refine ⟨witness x hx0, (), ?_⟩
  rw [serviceGrid, witness_ideal x hx0 (), gridCeil_eq_base_of_mem_Ioc hrho hx1 hx2, hxdef]
  field_simp

/-- **The optimal ceiling constant is exactly the grid ratio.**  A uniform bound
`service ≤ c · ideal` holds for all PTX instances precisely when `ρ ≤ c`. -/
theorem ptx_grid_optimal_ceiling_iff {rho : ℝ} (hrho : 1 < rho) (c : ℝ) :
    (∀ (I : PTXInstance Unit) (y : Unit), serviceGrid rho I y ≤ c * ideal I y) ↔ rho ≤ c := by
  constructor
  · intro h
    by_contra hlt
    push_neg at hlt
    set t : ℝ := max 1 ((c + rho) / 2) with htdef
    have ht1 : 1 ≤ t := le_max_left _ _
    have ht2 : t < rho := by
      rw [htdef]
      exact max_lt hrho (by linarith)
    have htc : c < t := by
      have hmid : (c + rho) / 2 ≤ t := le_max_right _ _
      linarith
    obtain ⟨I, y, hIy⟩ := ptx_grid_slack_realised hrho t ht1 ht2
    have hpos : 0 < ideal I y := ideal_pos I y
    have := h I y
    rw [hIy] at this
    nlinarith
  · intro hc I y
    have hpos : 0 < ideal I y := ideal_pos I y
    have h1 := ptx_grid_ceiling hrho I y
    nlinarith

/-- **The optimal floor constant is exactly `1`**, for every grid ratio. -/
theorem ptx_grid_optimal_floor_iff {rho : ℝ} (hrho : 1 < rho) (c : ℝ) :
    (∀ (I : PTXInstance Unit) (y : Unit), c * ideal I y ≤ serviceGrid rho I y) ↔ c ≤ 1 := by
  constructor
  · intro h
    obtain ⟨I, y, hIy⟩ := ptx_grid_slack_realised hrho 1 (le_refl 1) hrho
    have hpos : 0 < ideal I y := ideal_pos I y
    have := h I y
    rw [hIy, one_mul] at this
    nlinarith
  · intro hc I y
    have hpos : 0 < ideal I y := ideal_pos I y
    have h1 := ptx_grid_no_starvation hrho I y
    nlinarith

/-- **The headline factor `2` is exactly the dyadic grid ratio.** -/
theorem ptx_two_optimal_ceiling_iff (c : ℝ) :
    (∀ (I : PTXInstance Unit) (y : Unit), service I y ≤ c * ideal I y) ↔ 2 ≤ c :=
  ptx_grid_optimal_ceiling_iff (rho := 2) (by norm_num) c

/-- **The floor constant `1` cannot be raised.** -/
theorem ptx_one_optimal_floor_iff (c : ℝ) :
    (∀ (I : PTXInstance Unit) (y : Unit), c * ideal I y ≤ service I y) ↔ c ≤ 1 :=
  ptx_grid_optimal_floor_iff (rho := 2) (by norm_num) c

/-! ## 4. Log-periodicity of the slack -/

/-- The slack is unchanged when the ideal share is scaled by the grid ratio: the slack function
is log-periodic with period `log ρ`.  This is the structural reason why the supremum `ρ` of the
slack is approached but never attained. -/
theorem ptx_slack_log_periodic {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    gridCeil rho (rho * x) / (rho * x) = gridCeil rho x / x := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  rw [gridCeil_mul_base hrho hx]
  field_simp

/-! ## 5. Aggregate (whole-channel) bounds -/

variable [Fintype ι]

/-- The floor survives aggregation: the total delivered service is at least the total ideal
share of the channel. -/
theorem ptx_aggregate_floor (I : PTXInstance ι) :
    ∑ y, ideal I y ≤ ∑ y, service I y :=
  Finset.sum_le_sum fun y _ => ptx_ideal_le_service I y

/-- The factor `2` survives aggregation: for a nonempty family of transport classes the total
delivered service is strictly less than twice the total ideal share. -/
theorem ptx_aggregate_lt_two [Nonempty ι] (I : PTXInstance ι) :
    ∑ y, service I y < 2 * ∑ y, ideal I y := by
  have h : ∑ y, service I y < ∑ y, 2 * ideal I y :=
    Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty
      (fun y _ => ptx_service_lt_two_ideal I y)
  rwa [← Finset.mul_sum] at h

/-! ## 6. Quantitative starvation for rare channels -/

omit [Fintype ι] in
/-- A class whose transport gap is large receives arbitrarily little service: for any
`eps > 0`, a gap exceeding `2 γ d y / eps` forces `service y < eps`.  Physically, channels with
vanishing occupancy `p y` (hence diverging Boltzmann cost `β log (1/p y)`) are squeezed out, so
the floor of `ptx_no_starvation` is a genuine, saturating constraint. -/
theorem ptx_service_lt_of_gap_large (I : PTXInstance ι) (y : ι) (eps : ℝ) (heps : 0 < eps)
    (hgap : 2 * (I.gamma * I.d y) / eps < gap I y) : service I y < eps := by
  have hgp : 0 < gap I y := gap_pos' I y
  have hnum : 0 < I.gamma * I.d y := mul_pos I.gamma_pos (I.d_pos y)
  have hkey : 2 * ideal I y < eps := by
    rw [ideal, ← mul_div_assoc, div_lt_iff₀ hgp]
    rw [div_lt_iff₀ heps] at hgap
    nlinarith
  exact lt_of_lt_of_le (ptx_service_lt_two_ideal I y) (le_of_lt hkey)

end Physics.PTX