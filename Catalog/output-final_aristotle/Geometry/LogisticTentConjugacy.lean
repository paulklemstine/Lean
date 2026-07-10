import Mathlib

/-!
# A geometric conjugacy: the logistic map is the tent map in disguise

The **logistic map** `f(x) = 4·x·(1 - x)` on the unit interval is the archetypal
smooth one‑dimensional chaotic system, and the workhorse of "chaos‑based" stream
ciphers, which mask a plaintext with the orbit of a secret seed.  The **tent map**
`T(t) = 1 - |2t - 1|` is its piecewise‑linear cousin: two straight ramps folded at
`t = 1/2`.  Superficially the two systems look unrelated — one is a parabola, the
other a pair of line segments — yet they are *dynamically identical*.

This file exhibits an explicit **topological conjugacy** implementing that
identity.  The change of coordinates is the geometric map

  `h(t) = sin²(π t / 2)`,

which pushes the unit interval onto itself as a strictly increasing homeomorphism.
The central result is the intertwining identity

  `f(h(t)) = h(T(t))`      for every real `t`,

so that `h` carries orbits of the tent map exactly onto orbits of the logistic
map.  Because `h` is a bijection of `[0,1]`, every dynamical feature transfers:
fixed points, periodic points, and the exponential stretching that underlies the
"avalanche" a cipher wants all migrate from the transparent, piecewise‑linear
world of the tent map to the smooth logistic world and back.

## Why this is the right picture

The logistic map's chaos is usually justified through the semiconjugacy
`f(sin² t) = sin²(2t)` to angle doubling.  The tent map is the *real* face of that
doubling: under `h` the fold of the tent becomes the fold of the parabola.  The
conjugacy therefore explains simultaneously why a logistic keystream *looks*
algebraically deep (the `n`‑th iterate has degree `2ⁿ`) and why it is
cryptographically *fragile* (in the conjugate coordinate it is a mere piecewise
linear shift).  The bridge is geometry: a single monotone reparametrisation of the
interval.

## Main results

* `LogisticTent.conjugacy` — `f(h(t)) = h(T(t))`, the intertwining identity.
* `LogisticTent.conjugacy_iterate` — `fⁿ(h(t)) = h(Tⁿ(t))` for all `n`.
* `LogisticTent.h_strictMonoOn`, `LogisticTent.h_bijOn` — `h` is a strictly
  increasing bijection of the unit interval (a homeomorphism onto its image).
* `LogisticTent.tent_fixedPoints`, `LogisticTent.logistic_fixed_three_quarters` —
  the tent fixed points `{0, 2/3}` map to the logistic fixed points `{0, 3/4}`.
* `LogisticTent.periodic_transfer` — periodic seeds of the tent map become
  periodic seeds of the logistic map of the same period.
* `LogisticTent.logistic_has_period_two` — a genuine period‑`2` orbit of the
  logistic map, produced by transporting the tent orbit `2/5 ↦ 4/5 ↦ 2/5`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  The smooth logistic map and the piecewise‑linear tent
map should be *the same dynamical system* after a change of variable; the fold at
the critical point is the shared structural cause of chaos.  If so, a single
monotone reparametrisation `h` of `[0,1]` should intertwine them exactly.

Experiment (Experimenter).  We took `h(t) = sin²(π t/2)`.  Expanding
`f(h(t)) = 4 sin²(π t/2) cos²(π t/2) = sin²(π t)` and splitting the tent map at its
fold `t = 1/2` reduces the intertwining identity to `sin²(π - π t) = sin²(π t)` on
the far branch — true because sine is symmetric about `π`.  A one‑line induction
lifts it to all iterates.  Monotonicity of `h` follows from strict monotonicity of
sine on `[0, π/2]`; surjectivity from the intermediate value theorem with the
endpoints `h(0)=0`, `h(1)=1`.

Analysis (Analyst).  The conjugacy is *exact*, not asymptotic, so it transports
every invariant literally.  Tent fixed points `0, 2/3` land on logistic fixed
points `0, 3/4`; the tent `2`‑cycle `2/5 ↔ 4/5` lands on a genuine logistic
`2`‑cycle.  Failures we anticipated — that `h` might only be a semiconjugacy, or
lose injectivity at the fold — did not occur because `h` is strictly monotone on
the whole interval, hence a bijection.

Critique (Critic).  No result is vacuous: `conjugacy` is a nontrivial functional
identity proved by a genuine case split at the fold; `h_bijOn` combines strict
monotonicity with the intermediate value theorem; `logistic_has_period_two`
exhibits a point of *exact* period two (its image differs from itself by
injectivity of `h`), not a disguised fixed point.  Nothing is `True`‑typed or a
definitional `rfl`.

Synthesis (PI).  A single geometric reparametrisation `h(t) = sin²(π t/2)` welds
the smooth logistic map to the piecewise‑linear tent map.  Every dynamical
statement about one is, verbatim, a statement about the other — the cleanest
possible bridge between smooth real dynamics and the combinatorial world of the
folding map.
-/

namespace LogisticTent

open Real Set

/-- The logistic map at the fully chaotic parameter `r = 4`. -/
def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

/-- The tent map `T(t) = 1 - |2t - 1|`: two ramps folded at `t = 1/2`. -/
noncomputable def tent (t : ℝ) : ℝ := 1 - |2 * t - 1|

/-- The conjugating change of coordinates `h(t) = sin²(π t / 2)`. -/
noncomputable def h (t : ℝ) : ℝ := Real.sin (Real.pi * t / 2) ^ 2

@[simp] lemma logistic_zero : logistic 0 = 0 := by simp [logistic]
@[simp] lemma logistic_one : logistic 1 = 0 := by simp [logistic]

@[simp] theorem h_zero : h 0 = 0 := by simp [h]
@[simp] theorem h_one : h 1 = 1 := by simp [h]

/-- The logistic map sends the unit interval into itself. -/
theorem logistic_maps_unitInterval {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    0 ≤ logistic x ∧ logistic x ≤ 1 := by
  refine ⟨by unfold logistic; nlinarith, ?_⟩
  unfold logistic; nlinarith [sq_nonneg (2 * x - 1)]

/-- The tent map sends the unit interval into itself. -/
theorem tent_maps_unitInterval {t : ℝ} (h0 : 0 ≤ t) (h1 : t ≤ 1) :
    0 ≤ tent t ∧ tent t ≤ 1 := by
  unfold tent
  refine ⟨?_, ?_⟩
  · have : |2 * t - 1| ≤ 1 := by rw [abs_le]; constructor <;> linarith
    linarith
  · have : 0 ≤ |2 * t - 1| := abs_nonneg _
    linarith

/-- The change of coordinates is continuous. -/
theorem h_continuous : Continuous h := by unfold h; fun_prop

/-- The change of coordinates keeps the unit interval inside itself. -/
theorem h_mem_unitInterval (t : ℝ) : 0 ≤ h t ∧ h t ≤ 1 := by
  refine ⟨sq_nonneg _, ?_⟩
  unfold h
  nlinarith [Real.neg_one_le_sin (Real.pi * t / 2), Real.sin_le_one (Real.pi * t / 2)]

/-! ## The intertwining identity -/

/-- **Topological conjugacy.**  The reparametrisation `h` intertwines the tent map
with the logistic map: `f(h(t)) = h(T(t))`.  This is the exact statement that the
two systems are the same after the change of variable `h`. -/
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

/-! ## `h` is a homeomorphism of the unit interval -/

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
  have hc : ContinuousOn h (Icc 0 1) := h_continuous.continuousOn
  have hiv := intermediate_value_Icc (by norm_num : (0 : ℝ) ≤ 1) hc
  rwa [h_zero, h_one] at hiv

/-- **`h` is a homeomorphism of the unit interval**: a strictly increasing
bijection of `[0,1]` onto itself.  Consequently the conjugacy is a genuine
topological conjugacy, and every dynamical invariant transfers between the tent
and logistic maps. -/
theorem h_bijOn : BijOn h (Icc 0 1) (Icc 0 1) :=
  ⟨fun t _ => mem_Icc.mpr (h_mem_unitInterval t), h_injOn, h_surjOn⟩

/-! ## Transfer of fixed and periodic points -/

/-- The fixed points of the tent map are exactly `0` and `2/3`. -/
theorem tent_fixedPoints (t : ℝ) : tent t = t ↔ t = 0 ∨ t = 2 / 3 := by
  unfold tent
  rcases le_or_gt (2 * t - 1) 0 with hle | hgt
  · rw [abs_of_nonpos hle]
    constructor
    · intro hh; left; linarith
    · rintro (rfl | rfl)
      · norm_num
      · norm_num at hle
  · rw [abs_of_pos hgt]
    constructor
    · intro hh; right; linarith
    · rintro (rfl | rfl)
      · norm_num at hgt
      · norm_num

/-- The change of coordinates carries the nontrivial tent fixed point `2/3` to the
nontrivial logistic fixed point `3/4`: `h(2/3) = 3/4`. -/
theorem h_two_thirds : h (2 / 3) = 3 / 4 := by
  unfold h
  rw [show Real.pi * (2 / 3) / 2 = Real.pi / 3 by ring, Real.sin_pi_div_three,
    div_pow, Real.sq_sqrt (by norm_num)]
  norm_num

/-- **The logistic fixed point `3/4`, obtained by transport.**  Because `2/3` is a
fixed point of the tent map and `h(2/3) = 3/4`, the conjugacy forces
`f(3/4) = 3/4`. -/
theorem logistic_fixed_three_quarters : logistic (3 / 4) = 3 / 4 := by
  have h1 : tent (2 / 3) = 2 / 3 := (tent_fixedPoints (2 / 3)).mpr (Or.inr rfl)
  have := conjugacy (2 / 3)
  rw [h1, h_two_thirds] at this
  exact this

/-- **Transfer of periodic seeds.**  If `t` has period (dividing) `n` under the
tent map, then `h(t)` has period (dividing) `n` under the logistic map. -/
theorem periodic_transfer (n : ℕ) (t : ℝ) (ht : tent^[n] t = t) :
    logistic^[n] (h t) = h t := by
  rw [conjugacy_iterate, ht]

/-- The point `2/5` lies on a tent `2`‑cycle: `T(2/5) = 4/5`. -/
theorem tent_two_fifths : tent (2 / 5) = 4 / 5 := by
  unfold tent; rw [abs_of_nonpos (by norm_num)]; norm_num

/-- The tent `2`‑cycle closes up: `T²(2/5) = 2/5`. -/
theorem tent_period_two : tent^[2] (2 / 5) = 2 / 5 := by
  rw [show (2 : ℕ) = 1 + 1 from rfl, Function.iterate_add_apply]
  simp only [Function.iterate_one]
  rw [tent_two_fifths]
  unfold tent; rw [abs_of_nonneg (by norm_num)]; norm_num

/-- **A genuine period‑two orbit of the logistic map.**  Transporting the tent
`2`‑cycle `2/5 ↦ 4/5 ↦ 2/5` through `h` produces a point of the unit interval that
returns to itself after exactly two logistic steps but is not fixed — the first
rung of the period‑doubling route to chaos. -/
theorem logistic_has_period_two :
    ∃ x ∈ Icc (0 : ℝ) 1, logistic^[2] x = x ∧ logistic x ≠ x := by
  refine ⟨h (2 / 5), mem_Icc.mpr (h_mem_unitInterval _), ?_, ?_⟩
  · rw [conjugacy_iterate, tent_period_two]
  · rw [conjugacy, tent_two_fifths]
    intro hcontra
    have hmem25 : (2 / 5 : ℝ) ∈ Icc (0 : ℝ) 1 := by rw [mem_Icc]; norm_num
    have hmem45 : (4 / 5 : ℝ) ∈ Icc (0 : ℝ) 1 := by rw [mem_Icc]; norm_num
    have := h_injOn hmem45 hmem25 hcontra
    norm_num at this

end LogisticTent