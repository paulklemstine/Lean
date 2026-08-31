/-
# PTX transport: the no-starvation floor and its sharp factor `2`

## The physical model

A *photon-transport exchange* (PTX) is an idealised model of a shared quantum channel that
multiplexes several transport classes `y`.  Each class is described by three numbers:

* `p y ∈ (0,1]` — the *occupancy* (the probability that a slot offered to `y` is actually
  usable);
* `d y > 0`    — the *demand* (how much channel time class `y` asks for);
* `r y`        — the *reservation credit* already granted to `y` by the arbiter.

Three global constants govern the exchange: an inverse temperature `β > 0`, a scheduling
quantum `γ > 0`, and a background cost `M`.

The **transport gap** of class `y` is the Boltzmann cost of one successful transfer, corrected
by the class's own credit,
```
gap y  =  β · log (1 / p y)  +  M  +  γ  −  r y ,
```
and the **ideal service** that a perfectly divisible arbiter would hand to `y` is
```
ideal y  =  γ · d y / gap y .
```
This is the familiar "`γ d / (β log(1/p) + M + γ − r)`" expression: a rare class
(`p y` small, hence `log (1/p y)` large) has a large gap and therefore a small ideal share,
while a class holding a large credit `r y` has a small gap and a large share.

A *real* arbiter cannot hand out an arbitrary real amount of channel time.  Slots are handed
out in **binary exponential backoff windows**: the arbiter must pick a window that is an
integer power of two (positive or negative) of the base quantum, and it picks the smallest
such window that covers the ideal share.  Hence the delivered service is
```
service y  =  2 ^ ⌈log₂ (ideal y)⌉ .
```

## What is proved here

* `ptx_no_starvation` : `ideal y ≤ service y` — the floor.  No class is ever starved: it always
  receives at least `γ d y / (β log (1/p y) + M + γ − r y)`.
* `ptx_service_lt_two_ideal` : `service y < 2 · ideal y` — the ceiling, valid for *every*
  instance.  In particular there really are instances with `service y ≤ 2 · ideal y`, which is
  the statement that the floor cannot be improved by more than a factor of `2`.
* `ptx_floor_attained` : an explicit instance with `service y = ideal y`.  Consequently
  (`ptx_floor_constant_optimal`) the constant `1` in the floor is *exactly* optimal: no
  `c > 1` works uniformly.
* `ptx_ratio_approaches_two` : for every `ε > 0` an instance whose slack exceeds `2 − ε`.
  Together with the ceiling this pins the supremum of the slack at exactly `2`
  (`ptx_two_is_optimal_ceiling`): the "factor `2`" in the headline statement is not an
  artefact of the proof, it is the exact width of the dyadic backoff grid.

The technical engine is the *grid quantiser* `gridCeil ρ x = ρ ^ ⌈log_ρ x⌉`, developed for a
general ratio `ρ > 1` in the first section; the value `ρ = 2` of the PTX arbiter is what
produces the factor `2`.
-/

import Mathlib

namespace Physics.PTX

open Real

/-! ## 1. The grid quantiser -/

/-- `gridCeil ρ x` is the smallest power of `ρ` (integer exponent, possibly negative) that is
at least `x`.  For `ρ = 2` this is the binary exponential backoff window covering `x`. -/
noncomputable def gridCeil (rho x : ℝ) : ℝ := rho ^ (⌈Real.logb rho x⌉ : ℤ)

lemma gridCeil_pos {rho x : ℝ} (hrho : 1 < rho) : 0 < gridCeil rho x :=
  zpow_pos (lt_trans zero_lt_one hrho) _

lemma gridCeil_eq_rpow {rho x : ℝ} :
    gridCeil rho x = rho ^ ((⌈Real.logb rho x⌉ : ℤ) : ℝ) := by
  rw [gridCeil, Real.rpow_intCast]

/-- **Covering property.** The quantised window is never smaller than the request. -/
lemma self_le_gridCeil {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) : x ≤ gridCeil rho x := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hlog : rho ^ (Real.logb rho x) = x := Real.rpow_logb h0 (ne_of_gt hrho) hx
  calc x = rho ^ (Real.logb rho x) := hlog.symm
    _ ≤ rho ^ ((⌈Real.logb rho x⌉ : ℤ) : ℝ) :=
        Real.rpow_le_rpow_of_exponent_le (le_of_lt hrho) (Int.le_ceil _)
    _ = gridCeil rho x := gridCeil_eq_rpow.symm

/-- **Efficiency property.** The quantised window overshoots by strictly less than the grid
ratio `ρ`. -/
lemma gridCeil_lt {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) : gridCeil rho x < rho * x := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hlog : rho ^ (Real.logb rho x) = x := Real.rpow_logb h0 (ne_of_gt hrho) hx
  have hceil : ((⌈Real.logb rho x⌉ : ℤ) : ℝ) < Real.logb rho x + 1 := Int.ceil_lt_add_one _
  calc gridCeil rho x = rho ^ ((⌈Real.logb rho x⌉ : ℤ) : ℝ) := gridCeil_eq_rpow
    _ < rho ^ (Real.logb rho x + 1) := (Real.rpow_lt_rpow_left_iff hrho).2 hceil
    _ = rho ^ (Real.logb rho x) * rho := by rw [Real.rpow_add h0, Real.rpow_one]
    _ = x * rho := by rw [hlog]
    _ = rho * x := mul_comm _ _

/-- On the half-open interval `(1, ρ]` the quantiser must jump all the way to `ρ`. -/
lemma gridCeil_eq_base_of_mem_Ioc {rho x : ℝ} (hrho : 1 < rho) (hx1 : 1 < x) (hx2 : x ≤ rho) :
    gridCeil rho x = rho := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx1
  have hlogpos : 0 < Real.logb rho x := Real.logb_pos hrho hx1
  have hlogle : Real.logb rho x ≤ 1 := by
    rw [Real.logb_le_iff_le_rpow hrho hx0, Real.rpow_one]
    exact hx2
  have hceil : ⌈Real.logb rho x⌉ = (1 : ℤ) := by
    rw [Int.ceil_eq_iff]
    constructor
    · push_cast; linarith
    · push_cast; linarith
  rw [gridCeil, hceil, zpow_one]

/-- The quantiser is exact precisely on the grid. -/
lemma gridCeil_eq_self_iff {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    gridCeil rho x = x ↔ ∃ k : ℤ, x = rho ^ k := by
  constructor
  · intro h; exact ⟨⌈Real.logb rho x⌉, h.symm⟩
  · rintro ⟨k, rfl⟩
    have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
    have hlogb : Real.logb rho (rho ^ k) = (k : ℝ) := by
      rw [show (rho ^ k) = rho ^ ((k : ℤ) : ℝ) by rw [Real.rpow_intCast],
        Real.logb_rpow h0 (ne_of_gt hrho)]
    rw [gridCeil, hlogb, Int.ceil_intCast]

/-! ## 2. PTX instances -/

/-- A photon-transport exchange: global constants `β, γ, M` together with occupancies `p`,
demands `d` and reservation credits `r` for each transport class. -/
structure PTXInstance (ι : Type*) where
  beta : ℝ
  gamma : ℝ
  M : ℝ
  p : ι → ℝ
  d : ι → ℝ
  r : ι → ℝ
  beta_pos : 0 < beta
  gamma_pos : 0 < gamma
  p_pos : ∀ y, 0 < p y
  p_le_one : ∀ y, p y ≤ 1
  d_pos : ∀ y, 0 < d y
  gap_pos : ∀ y, 0 < beta * Real.log (1 / p y) + M + gamma - r y

variable {ι : Type*}

/-- The transport gap `β log(1/p y) + M + γ − r y` of class `y`. -/
noncomputable def gap (I : PTXInstance ι) (y : ι) : ℝ :=
  I.beta * Real.log (1 / I.p y) + I.M + I.gamma - I.r y

/-- The ideal (perfectly divisible) share `γ d y / gap y` of class `y`. -/
noncomputable def ideal (I : PTXInstance ι) (y : ι) : ℝ := I.gamma * I.d y / gap I y

/-- The service actually delivered by the dyadic backoff arbiter. -/
noncomputable def service (I : PTXInstance ι) (y : ι) : ℝ := gridCeil 2 (ideal I y)

lemma gap_pos' (I : PTXInstance ι) (y : ι) : 0 < gap I y := I.gap_pos y

lemma ideal_pos (I : PTXInstance ι) (y : ι) : 0 < ideal I y :=
  div_pos (mul_pos I.gamma_pos (I.d_pos y)) (gap_pos' I y)

lemma service_pos (I : PTXInstance ι) (y : ι) : 0 < service I y :=
  gridCeil_pos (by norm_num)

/-- The transport gap decreases when the occupancy increases: a more reliable class has a
smaller Boltzmann cost.  (Both classes are compared inside the same exchange.) -/
lemma gap_antitone_in_p (I : PTXInstance ι) {y z : ι}
    (hp : I.p y ≤ I.p z) (hMr : I.M - I.r y = I.M - I.r z) : gap I z ≤ gap I y := by
  have hpy : 0 < I.p y := I.p_pos y
  have hpz : 0 < I.p z := I.p_pos z
  have h : Real.log (1 / I.p z) ≤ Real.log (1 / I.p y) := by
    apply Real.log_le_log (by positivity)
    exact one_div_le_one_div_of_le hpy hp
  have := mul_le_mul_of_nonneg_left h (le_of_lt I.beta_pos)
  simp only [gap]
  linarith [hMr]

/-! ## 3. The floor and the factor-two ceiling -/

/-- **No starvation.**  Every transport class receives at least
`γ d y / (β log (1/p y) + M + γ − r y)` units of channel time. -/
theorem ptx_no_starvation (I : PTXInstance ι) (y : ι) :
    I.gamma * I.d y / (I.beta * Real.log (1 / I.p y) + I.M + I.gamma - I.r y) ≤ service I y :=
  self_le_gridCeil (by norm_num) (ideal_pos I y)

/-- Restatement of `ptx_no_starvation` in terms of the abbreviation `ideal`. -/
theorem ptx_ideal_le_service (I : PTXInstance ι) (y : ι) : ideal I y ≤ service I y :=
  ptx_no_starvation I y

/-- **The floor cannot be improved by more than a factor `2`.**  For *every* instance the
delivered service is strictly below twice the floor; in particular there are instances with
`service y ≤ 2 γ d y / (β log(1/p y) + M + γ − r y)`. -/
theorem ptx_service_lt_two_ideal (I : PTXInstance ι) (y : ι) :
    service I y < 2 * ideal I y :=
  gridCeil_lt (by norm_num) (ideal_pos I y)

theorem ptx_service_le_two_ideal (I : PTXInstance ι) (y : ι) :
    service I y ≤ 2 * (I.gamma * I.d y /
      (I.beta * Real.log (1 / I.p y) + I.M + I.gamma - I.r y)) :=
  le_of_lt (ptx_service_lt_two_ideal I y)

/-- The service is exact exactly when the ideal share already sits on the dyadic grid. -/
theorem ptx_service_eq_ideal_iff (I : PTXInstance ι) (y : ι) :
    service I y = ideal I y ↔ ∃ k : ℤ, ideal I y = 2 ^ k :=
  gridCeil_eq_self_iff (by norm_num) (ideal_pos I y)

/-! ## 4. Witness instances: the floor is sharp and the factor `2` is exact -/

/-- A one-class exchange whose ideal share is exactly the prescribed number `x > 0`.
Here `p ≡ 1` (a perfect channel, `log (1/p) = 0`), `β = γ = M = 1`, `r ≡ 1`, so that
`gap = 0 + 1 + 1 − 1 = 1` and `ideal = γ·x/1 = x`. -/
noncomputable def witness (x : ℝ) (hx : 0 < x) : PTXInstance Unit where
  beta := 1
  gamma := 1
  M := 1
  p := fun _ => 1
  d := fun _ => x
  r := fun _ => 1
  beta_pos := one_pos
  gamma_pos := one_pos
  p_pos := fun _ => one_pos
  p_le_one := fun _ => le_refl 1
  d_pos := fun _ => hx
  gap_pos := fun _ => by norm_num

@[simp] lemma witness_gap (x : ℝ) (hx : 0 < x) (y : Unit) : gap (witness x hx) y = 1 := by
  simp [gap, witness]

@[simp] lemma witness_ideal (x : ℝ) (hx : 0 < x) (y : Unit) : ideal (witness x hx) y = x := by
  rw [ideal, witness_gap x hx y]
  simp [witness]

/-- **The floor is attained.**  There is a PTX instance in which the delivered service equals
the no-starvation floor exactly. -/
theorem ptx_floor_attained : ∃ (I : PTXInstance Unit) (y : Unit), service I y = ideal I y := by
  refine ⟨witness 1 one_pos, (), ?_⟩
  rw [ptx_service_eq_ideal_iff]
  exact ⟨0, by simp⟩

/-- **The constant in the floor is optimal.**  No constant `c > 1` can replace `1` in
`ptx_no_starvation`. -/
theorem ptx_floor_constant_optimal (c : ℝ) (hc : 1 < c) :
    ¬ ∀ (I : PTXInstance Unit) (y : Unit), c * ideal I y ≤ service I y := by
  intro h
  have := h (witness 1 one_pos) ()
  rw [witness_ideal] at this
  have hs : service (witness 1 one_pos) () = 1 := by
    have : service (witness (1:ℝ) one_pos) () = ideal (witness (1:ℝ) one_pos) () := by
      rw [ptx_service_eq_ideal_iff]; exact ⟨0, by simp⟩
    rw [this, witness_ideal]
  rw [hs] at this
  linarith

/-- On the interval `(1, 2]` the dyadic arbiter must jump to the window `2`. -/
lemma service_witness_of_mem_Ioc {x : ℝ} (hx1 : 1 < x) (hx2 : x ≤ 2) :
    service (witness x (lt_trans zero_lt_one hx1)) () = 2 := by
  have hx0 : (0:ℝ) < x := lt_trans zero_lt_one hx1
  rw [service, witness_ideal x hx0 (), gridCeil_eq_base_of_mem_Ioc (by norm_num) hx1 hx2]

/-- **The slack `2` is approached.**  For every `ε > 0` there is a PTX instance whose delivered
service exceeds `(2 − ε)` times the floor.  Hence the supremum of `service / ideal` is exactly
`2`. -/
theorem ptx_ratio_approaches_two (eps : ℝ) (heps : 0 < eps) :
    ∃ (I : PTXInstance Unit) (y : Unit), (2 - eps) * ideal I y < service I y := by
  set x : ℝ := 1 + min (eps / 4) (1 / 2) with hxdef
  have hmpos : 0 < min (eps / 4) (1 / 2) := lt_min (by linarith) (by norm_num)
  have hmle : min (eps / 4) (1 / 2) ≤ eps / 4 := min_le_left _ _
  have hmle2 : min (eps / 4) (1 / 2) ≤ 1 / 2 := min_le_right _ _
  have hx1 : 1 < x := by rw [hxdef]; linarith
  have hx2 : x ≤ 2 := by rw [hxdef]; linarith
  have hx0 : (0:ℝ) < x := lt_trans zero_lt_one hx1
  refine ⟨witness x hx0, (), ?_⟩
  rw [witness_ideal, service_witness_of_mem_Ioc hx1 hx2]
  -- need `(2 - eps) * x < 2`
  rcases le_or_gt 2 eps with h | h
  · nlinarith
  · have hmm : min (eps / 4) (1 / 2) < eps / (2 - eps) := by
      have h2 : 0 < 2 - eps := by linarith
      rw [lt_div_iff₀ h2]
      nlinarith
    nlinarith

/-- **The factor `2` is exactly right.**  No constant `c < 2` bounds the delivered service in
terms of the floor; combined with `ptx_service_lt_two_ideal` the optimal ceiling constant is
exactly `2`. -/
theorem ptx_two_is_optimal_ceiling (c : ℝ) (hc : c < 2) :
    ¬ ∀ (I : PTXInstance Unit) (y : Unit), service I y ≤ c * ideal I y := by
  intro h
  obtain ⟨I, y, hIy⟩ := ptx_ratio_approaches_two (2 - c) (by linarith)
  have := h I y
  simp only [sub_sub_cancel] at hIy
  linarith

/-- The headline statement of the mission, verbatim: there are PTX instances whose delivered
service is at most `2 γ d y / (β log(1/p y) + M + γ − r y)`, so the no-starvation constant
cannot be improved beyond a factor of `2`. -/
theorem ptx_floor_sharp :
    ∃ (I : PTXInstance Unit) (y : Unit),
      service I y ≤ 2 * (I.gamma * I.d y /
        (I.beta * Real.log (1 / I.p y) + I.M + I.gamma - I.r y)) ∧
      ideal I y ≤ service I y :=
  ⟨witness 1 one_pos, (), ptx_service_le_two_ideal _ _, ptx_ideal_le_service _ _⟩

end Physics.PTX