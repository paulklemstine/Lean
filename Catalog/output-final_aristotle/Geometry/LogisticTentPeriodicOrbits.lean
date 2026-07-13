import Mathlib

/-!
# Periodic orbits through the logistic–tent conjugacy

The **logistic map** `f(x) = 4·x·(1 - x)` on the unit interval is the archetypal
smooth one-dimensional chaotic system; the **tent map** `T(t) = 1 - |2t - 1|` is
its piecewise-linear cousin.  The two are *dynamically identical*: the strictly
increasing homeomorphism

  `h(t) = sin²(π t / 2)`

of `[0,1]` intertwines them, `f(h(t)) = h(T(t))`, and hence `fⁿ(h(t)) = h(Tⁿ(t))`
for every `n`.  This file uses that exact conjugacy to transfer the *periodic-orbit
structure* of the transparent piecewise-linear map to the smooth one.

The guiding principle is that a homeomorphism moves periodic points to periodic
points of the same period.  Two consequences are developed here.

* **Exact counting reduction.**  For every `n`, the reparametrisation `h` is a
  bijection between the period-`n` points of the tent map and the period-`n` points
  of the logistic map (both in the unit interval).  The transcendental fixed-point
  count for the parabola therefore equals a combinatorial count of sawtooth
  crossings; in particular the two finite sets have equal cardinality.

* **Realisation of periods.**  A concrete tent `3`-cycle `2/7 ↦ 4/7 ↦ 6/7 ↦ 2/7`
  transports to a genuine period-three orbit of the logistic map.  By Sharkovskii's
  ordering a period-three orbit forces orbits of every period, so the smooth map is
  chaotic in the strongest combinatorial sense — a fact read off the linear model.

## Main results

* `LogisticTentPeriodic.periodic_iff` — `h t` is a period-`n` point of the logistic
  map iff `t` is a period-`n` point of the tent map.
* `LogisticTentPeriodic.periodic_bijOn` — `h` is a bijection between the two
  period-`n` point sets.
* `LogisticTentPeriodic.periodic_ncard_eq` — the two period-`n` point sets have
  equal cardinality (the counting reduction).
* `LogisticTentPeriodic.logistic_fixed_set`, `logistic_fixed_ncard` — the logistic
  fixed set is exactly `{0, 3/4}`, of cardinality `2 = 2¹`.
* `LogisticTentPeriodic.logistic_has_period_three` — a genuine period-three orbit
  of the logistic map.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  Since the smooth logistic map and the piecewise-linear
tent map are conjugate by the homeomorphism `h`, their periodic-orbit structures
must coincide *exactly*.  Counting fixed points of the `n`-th logistic iterate — a
transcendental problem about a degree-`2ⁿ` polynomial — should collapse to counting
crossings of a sawtooth against the diagonal, and every tent cycle should transport
verbatim to a logistic cycle of the same period.

Experiment (Experimenter).  Establishing the intertwining `fⁿ(h t) = h(Tⁿ t)` and
the bijectivity of `h` on `[0,1]`, we upgraded the one-directional transfer of the
base cycle to an *equivalence* `fⁿ(h t) = h t ↔ Tⁿ t = t` (injectivity supplies the
reverse implication).  This promotes to a bijection of the two period-`n` sets,
hence equal cardinalities.  We anchored the count at `n = 1` by solving
`4x(1-x) = x` to get exactly `{0, 3/4}`, and exhibited the tent `3`-cycle
`2/7 → 4/7 → 6/7 → 2/7`, transporting it to a logistic period-three orbit.

Analysis (Analyst).  What survives is the full structural bridge: periodicity,
period, and orbit count all transfer.  The reduction is exact, not asymptotic.  The
remaining quantitative claim — that the tent map has *exactly* `2ⁿ` period-`n`
points — is "true but hard": it needs the piecewise-linear geometry of the `n`-fold
iterate (a sawtooth of `2ⁿ` full ramps), which is a separate combinatorial argument
and is recorded as a future direction rather than proved here.

Critique (Critic).  No result is vacuous.  `periodic_iff` uses injectivity in an
essential way (the reverse direction is the base cycle's transfer; the forward
direction is new).  `logistic_fixed_set` is a genuine root computation, not a
definitional identity.  `logistic_has_period_three` exhibits a point of *exact*
period three: distinctness of `2/7, 4/7, 6/7` in `[0,1]` and injectivity of `h`
rule out any collapse to a shorter period.

Synthesis (PI).  The homeomorphism `h` transports the entire periodic-orbit
skeleton of the tent map onto the logistic map.  Counting smooth periodic points
becomes counting linear ones, and a single explicit `3`-cycle certifies orbits of
every period — chaos in the smooth world, proved in the linear one.
-/

namespace LogisticTentPeriodic

open Real Set

/-- The logistic map at the fully chaotic parameter `r = 4`. -/
def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

/-- The tent map `T(t) = 1 - |2t - 1|`. -/
noncomputable def tent (t : ℝ) : ℝ := 1 - |2 * t - 1|

/-- The conjugating change of coordinates `h(t) = sin²(π t / 2)`. -/
noncomputable def h (t : ℝ) : ℝ := Real.sin (Real.pi * t / 2) ^ 2

/-! ## The conjugacy and homeomorphism data -/

/-- The tent map sends the unit interval into itself. -/
theorem tent_maps_unitInterval {t : ℝ} (h0 : 0 ≤ t) (h1 : t ≤ 1) :
    0 ≤ tent t ∧ tent t ≤ 1 := by
  unfold tent
  refine ⟨?_, ?_⟩
  · have : |2 * t - 1| ≤ 1 := by rw [abs_le]; constructor <;> linarith
    linarith
  · have : 0 ≤ |2 * t - 1| := abs_nonneg _
    linarith

/-- The change of coordinates keeps the unit interval inside itself. -/
theorem h_mem_unitInterval (t : ℝ) : 0 ≤ h t ∧ h t ≤ 1 := by
  refine ⟨sq_nonneg _, ?_⟩
  unfold h
  nlinarith [Real.neg_one_le_sin (Real.pi * t / 2), Real.sin_le_one (Real.pi * t / 2)]

/-- **Topological conjugacy.**  `h` intertwines the tent map with the logistic map:
`f(h(t)) = h(T(t))`. -/
theorem conjugacy (t : ℝ) : logistic (h t) = h (tent t) := by
  unfold logistic h tent
  rw [show 4 * Real.sin (Real.pi * t / 2) ^ 2 * (1 - Real.sin (Real.pi * t / 2) ^ 2)
      = Real.sin (2 * (Real.pi * t / 2)) ^ 2 by
        rw [Real.sin_two_mul, ← Real.cos_sq_add_sin_sq (Real.pi * t / 2)]; ring]
  rw [show 2 * (Real.pi * t / 2) = Real.pi * t by ring]
  rcases le_or_gt (2 * t - 1) 0 with hle | hgt
  · rw [abs_of_nonpos hle]; congr 2; ring
  · rw [abs_of_pos hgt,
      show Real.pi * (1 - (2 * t - 1)) / 2 = Real.pi - Real.pi * t by ring, Real.sin_pi_sub]

/-- The intertwining identity for all iterates: `fⁿ(h(t)) = h(Tⁿ(t))`. -/
theorem conjugacy_iterate (n : ℕ) (t : ℝ) : logistic^[n] (h t) = h (tent^[n] t) := by
  induction n generalizing t with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ', Function.comp_apply, ih, conjugacy,
        ← Function.comp_apply (f := tent), ← Function.iterate_succ']

/-- The change of coordinates is strictly increasing on the unit interval. -/
theorem h_strictMonoOn : StrictMonoOn h (Icc 0 1) := by
  intro a ha b hb hab
  simp only [mem_Icc] at ha hb
  obtain ⟨ha0, ha1⟩ := ha
  obtain ⟨hb0, hb1⟩ := hb
  unfold h
  have hpi := Real.pi_pos
  have ha' : (0 : ℝ) ≤ Real.pi * a / 2 := by positivity
  have hamem : Real.pi * a / 2 ∈ Icc (-(π / 2)) (π / 2) := by
    refine ⟨by linarith, ?_⟩
    rw [div_le_div_iff_of_pos_right (by norm_num : (0 : ℝ) < 2)]; nlinarith
  have hbmem : Real.pi * b / 2 ∈ Icc (-(π / 2)) (π / 2) := by
    refine ⟨by nlinarith, ?_⟩
    rw [div_le_div_iff_of_pos_right (by norm_num : (0 : ℝ) < 2)]; nlinarith
  have key : Real.sin (Real.pi * a / 2) < Real.sin (Real.pi * b / 2) := by
    apply Real.strictMonoOn_sin hamem hbmem
    rw [div_lt_div_iff_of_pos_right (by norm_num : (0 : ℝ) < 2)]; nlinarith
  have hnn : 0 ≤ Real.sin (Real.pi * a / 2) :=
    Real.sin_nonneg_of_nonneg_of_le_pi ha' (by linarith [hamem.2])
  nlinarith

/-- The change of coordinates is injective on the unit interval. -/
theorem h_injOn : InjOn h (Icc 0 1) := h_strictMonoOn.injOn

/-- The change of coordinates maps the unit interval onto itself. -/
theorem h_surjOn : SurjOn h (Icc 0 1) (Icc 0 1) := by
  have hc : ContinuousOn h (Icc 0 1) := (by unfold h; fun_prop : Continuous h).continuousOn
  have hiv := intermediate_value_Icc (by norm_num : (0 : ℝ) ≤ 1) hc
  simp only [h] at hiv ⊢
  · have h0 : Real.sin (Real.pi * 0 / 2) ^ 2 = 0 := by simp
    have h1 : Real.sin (Real.pi * 1 / 2) ^ 2 = 1 := by
      rw [show Real.pi * 1 / 2 = Real.pi / 2 by ring]; simp
    rw [h0, h1] at hiv; exact hiv

/-- Every iterate of the tent map keeps the unit interval inside itself. -/
theorem tent_iterate_mem (n : ℕ) {t : ℝ} (ht : t ∈ Icc (0:ℝ) 1) :
    tent^[n] t ∈ Icc (0:ℝ) 1 := by
  induction n with
  | zero => simpa
  | succ k ih =>
    rw [Function.iterate_succ', Function.comp_apply]
    rw [mem_Icc] at ih ⊢
    exact tent_maps_unitInterval ih.1 ih.2

/-- Distinct seeds in the unit interval have distinct images under `h`. -/
theorem h_ne_of_ne {a b : ℝ} (ha : a ∈ Icc (0:ℝ) 1) (hb : b ∈ Icc (0:ℝ) 1)
    (hab : a ≠ b) : h a ≠ h b := fun heq => hab (h_injOn ha hb heq)

/-! ## Transfer of periodic points -/

/-- **Periodic-point equivalence.**  For a seed `t` in the unit interval, `h t` is a
period-`n` point of the logistic map if and only if `t` is a period-`n` point of the
tent map.  The reverse implication is the base transfer; the forward implication is
new and uses injectivity of `h`. -/
theorem periodic_iff (n : ℕ) {t : ℝ} (ht : t ∈ Icc (0:ℝ) 1) :
    logistic^[n] (h t) = h t ↔ tent^[n] t = t := by
  constructor
  · intro hpt
    rw [conjugacy_iterate] at hpt
    exact h_injOn (tent_iterate_mem n ht) ht hpt
  · intro hpt
    rw [conjugacy_iterate, hpt]

/-- **Bijection of periodic-point sets.**  The reparametrisation `h` restricts to a
bijection from the period-`n` points of the tent map onto the period-`n` points of
the logistic map, both taken in the unit interval. -/
theorem periodic_bijOn (n : ℕ) :
    BijOn h {t | t ∈ Icc (0:ℝ) 1 ∧ tent^[n] t = t}
            {x | x ∈ Icc (0:ℝ) 1 ∧ logistic^[n] x = x} := by
  refine ⟨?_, ?_, ?_⟩
  · rintro t ⟨ht, hpt⟩
    exact ⟨mem_Icc.mpr (h_mem_unitInterval t), (periodic_iff n ht).mpr hpt⟩
  · exact h_injOn.mono (fun t ht => ht.1)
  · rintro x ⟨hx, hpx⟩
    obtain ⟨t, ht, rfl⟩ := h_surjOn hx
    exact ⟨t, ⟨ht, (periodic_iff n ht).mp hpx⟩, rfl⟩

/-- **Counting reduction.**  The number of period-`n` points of the logistic map in
the unit interval equals the number of period-`n` points of the tent map.  The
transcendental fixed-point count for the smooth map is thereby reduced to the
combinatorial count for the piecewise-linear one. -/
theorem periodic_ncard_eq (n : ℕ) :
    {x | x ∈ Icc (0:ℝ) 1 ∧ logistic^[n] x = x}.ncard
      = {t | t ∈ Icc (0:ℝ) 1 ∧ tent^[n] t = t}.ncard := by
  have hb := periodic_bijOn n
  rw [← hb.image_eq, hb.injOn.ncard_image]

/-! ## The base of the exponential count: `n = 1` -/

/-- The fixed points of the logistic map in the unit interval are exactly `0` and
`3/4`. -/
theorem logistic_fixed_set :
    {x | x ∈ Icc (0:ℝ) 1 ∧ logistic x = x} = {0, 3/4} := by
  ext x
  simp only [mem_setOf_eq, mem_Icc, mem_insert_iff, mem_singleton_iff]
  constructor
  · rintro ⟨⟨hx0, hx1⟩, hfix⟩
    unfold logistic at hfix
    have hfac : x * (4 * x - 3) = 0 := by ring_nf; nlinarith [hfix]
    rcases mul_eq_zero.mp hfac with h1 | h2
    · left; exact h1
    · right; linarith
  · rintro (rfl | rfl)
    · exact ⟨⟨le_refl 0, by norm_num⟩, by unfold logistic; ring⟩
    · exact ⟨⟨by norm_num, by norm_num⟩, by unfold logistic; ring⟩

/-- The logistic map has exactly `2 = 2¹` fixed points in the unit interval — the
first instance of the conjectured exponential count `2ⁿ`. -/
theorem logistic_fixed_ncard :
    {x | x ∈ Icc (0:ℝ) 1 ∧ logistic x = x}.ncard = 2 := by
  rw [logistic_fixed_set, Set.ncard_pair (by norm_num)]

/-! ## A period-three orbit -/

/-- Tent step `2/7 ↦ 4/7`. -/
theorem tent_two_sevenths : tent (2/7) = 4/7 := by
  unfold tent; rw [abs_of_nonpos (by norm_num)]; norm_num

/-- Tent step `4/7 ↦ 6/7`. -/
theorem tent_four_sevenths : tent (4/7) = 6/7 := by
  unfold tent; rw [abs_of_nonneg (by norm_num)]; norm_num

/-- Tent step `6/7 ↦ 2/7`. -/
theorem tent_six_sevenths : tent (6/7) = 2/7 := by
  unfold tent; rw [abs_of_nonneg (by norm_num)]; norm_num

/-- The tent `3`-cycle closes up: `T³(2/7) = 2/7`. -/
theorem tent_period_three : tent^[3] (2/7) = 2/7 := by
  show tent (tent (tent (2/7))) = 2/7
  rw [tent_two_sevenths, tent_four_sevenths, tent_six_sevenths]

/-- **A genuine period-three orbit of the logistic map.**  Transporting the tent
`3`-cycle `2/7 ↦ 4/7 ↦ 6/7 ↦ 2/7` through `h` yields a point of *exact* period
three.  By Sharkovskii's ordering the presence of a period-three orbit forces orbits
of every period, so the logistic map is chaotic in the strongest combinatorial
sense. -/
theorem logistic_has_period_three :
    ∃ x ∈ Icc (0:ℝ) 1, logistic^[3] x = x ∧ logistic x ≠ x ∧ logistic^[2] x ≠ x := by
  refine ⟨h (2/7), mem_Icc.mpr (h_mem_unitInterval _), ?_, ?_, ?_⟩
  · rw [conjugacy_iterate, tent_period_three]
  · rw [conjugacy, tent_two_sevenths]
    exact h_ne_of_ne (by rw [mem_Icc]; norm_num) (by rw [mem_Icc]; norm_num) (by norm_num)
  · show logistic^[2] (h (2/7)) ≠ h (2/7)
    rw [conjugacy_iterate]
    have hT2 : tent^[2] (2/7) = 6/7 := by
      show tent (tent (2/7)) = 6/7
      rw [tent_two_sevenths, tent_four_sevenths]
    rw [hT2]
    exact h_ne_of_ne (by rw [mem_Icc]; norm_num) (by rw [mem_Icc]; norm_num) (by norm_num)

end LogisticTentPeriodic