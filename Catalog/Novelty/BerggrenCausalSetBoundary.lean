import Novelty.BerggrenCausalSetGeometry

/-!
# The Berggren causal set IV: the Pell geodesic and the conformal boundary

Fourth cycle.  The three previous files established the causal-set axioms, the Lorentz
symmetry, the (uniformly spacelike) link structure and the linear interval growth.  Here we
analyse the *asymptotic* structure — the piece of the moonshot hypothesis that speaks of
"null infinity".

The middle Berggren move `B` generates the Pell spine `(3,4,5) → (21,20,29) → (119,120,169)
→ …`.  We prove:

* `spine_diff_sq` — along the spine the legs stay twins, `(a − b)² = 1` forever, because the
  move exchanges the sign of `a − b`;
* `spine_edge_length` — consequently **every link of the Pell spine has Minkowski length
  exactly `4`**: the spine is a uniformly spaced discrete null-cone geodesic, an infinite
  chain of equal spacelike steps;
* `spine_dir_tendsto` — the celestial directions of the spine converge to `√2/2`, the `45°`
  null direction, so the spine has a well-defined endpoint on the conformal boundary;
* `spine_limit_irrational`, `spine_limit_not_event` — that endpoint is *irrational*, hence
  not the direction of any event: the conformal boundary of the Berggren causal set
  strictly extends it, exactly as null infinity strictly extends Minkowski space.
-/

namespace BerggrenCausalSet

open Filter Topology

/-! ## Part A. The Pell spine -/

theorem spine_zero : spine 0 = root := rfl

theorem spine_succ (k : ℕ) : spine (k + 1) = applyStep BerggrenStep.B (spine k) := by
  unfold spine
  rw [List.replicate_succ', run_concat]

theorem spine_isPrimEvent (k : ℕ) : IsPrimEvent (spine k) :=
  run_isPrimEvent _ root_isPrimEvent

theorem spine_isEvent (k : ℕ) : IsEvent (spine k) := (spine_isPrimEvent k).1

/-- The Berggren middle move exchanges the sign of `a − b`. -/
theorem step_B_diff (t : Event) :
    (applyStep BerggrenStep.B t).1 - (applyStep BerggrenStep.B t).2.1 = t.2.1 - t.1 := by
  obtain ⟨a, b, c⟩ := t
  simp only [applyStep_B, bergB]
  ring

/-- Along the Pell spine the legs remain twins forever. -/
theorem spine_diff_sq (k : ℕ) : ((spine k).1 - (spine k).2.1) ^ 2 = 1 := by
  induction k with
  | zero => decide
  | succ k ih =>
      rw [spine_succ, step_B_diff]
      linear_combination ih

/-- The Minkowski length of a middle link, stated for an arbitrary event. -/
theorem mink_step_B {t : Event} (h : IsEvent t) :
    mink t (applyStep BerggrenStep.B t) = 4 * (t.1 - t.2.1) ^ 2 := by
  obtain ⟨a, b, c⟩ := t
  exact mink_edge_B h

/-- **The Pell spine is a uniformly spaced discrete geodesic**: every one of its links has
Minkowski length exactly `4`. -/
theorem spine_edge_length (k : ℕ) : mink (spine k) (spine (k + 1)) = 4 := by
  rw [spine_succ, mink_step_B (spine_isEvent k)]
  linarith [spine_diff_sq k]

theorem spine_hyp_ge (k : ℕ) : (5 : ℤ) + (k : ℤ) ≤ (spine k).2.2 := by
  have := run_hyp_ge (List.replicate k BerggrenStep.B) root_isEvent
  simpa [spine, root] using this

/-! ## Part B. The celestial direction of the spine -/

/-- The quantitative statement behind the boundary limit: for a twin-legged event the
squared celestial direction is within `1/c` of `1/2`. -/
theorem dir_sq_bound {a b c : ℤ} (h : IsEvent (a, b, c)) (hd : (a - b) ^ 2 = 1) :
    |((a : ℝ) / (c : ℝ)) ^ 2 - 1 / 2| ≤ 1 / (c : ℝ) := by
  obtain ⟨hac, hbc⟩ := legs_lt_hyp h
  obtain ⟨hp, ha, hb, hc⟩ := h
  simp only at hac hbc ha hb hc hp
  unfold IsPythag at hp
  have hApos : (0 : ℝ) < (a : ℝ) := by exact_mod_cast ha
  have hBpos : (0 : ℝ) < (b : ℝ) := by exact_mod_cast hb
  have hCpos : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hc
  have hAC : (a : ℝ) ≤ (c : ℝ) := by exact_mod_cast hac.le
  have hBC : (b : ℝ) ≤ (c : ℝ) := by exact_mod_cast hbc.le
  have hpr : (a : ℝ) ^ 2 + (b : ℝ) ^ 2 = (c : ℝ) ^ 2 := by exact_mod_cast hp
  have hdr : ((a : ℝ) - (b : ℝ)) ^ 2 = 1 := by exact_mod_cast hd
  have hCne : (c : ℝ) ≠ 0 := ne_of_gt hCpos
  have key : ((a : ℝ) / (c : ℝ)) ^ 2 - 1 / 2
      = ((a : ℝ) - (b : ℝ)) * ((a : ℝ) + (b : ℝ)) / (2 * (c : ℝ) ^ 2) := by
    field_simp
    linear_combination hpr
  have habs : |(a : ℝ) - (b : ℝ)| = 1 := by
    have hfac : ((a : ℝ) - (b : ℝ) - 1) * ((a : ℝ) - (b : ℝ) + 1) = 0 := by
      linear_combination hdr
    rcases mul_eq_zero.mp hfac with hx | hx
    · rw [show (a : ℝ) - (b : ℝ) = 1 by linarith]; norm_num
    · rw [show (a : ℝ) - (b : ℝ) = -1 by linarith]; norm_num
  rw [key, abs_div, abs_mul, habs, one_mul,
    abs_of_pos (by positivity : (0 : ℝ) < 2 * (c : ℝ) ^ 2)]
  have h1 : |(a : ℝ) + (b : ℝ)| ≤ 2 * (c : ℝ) := by
    rw [abs_of_pos (by linarith)]; linarith
  have step1 : |(a : ℝ) + (b : ℝ)| / (2 * (c : ℝ) ^ 2) ≤ (2 * (c : ℝ)) / (2 * (c : ℝ) ^ 2) := by
    gcongr
  have step2 : (2 * (c : ℝ)) / (2 * (c : ℝ) ^ 2) = 1 / (c : ℝ) := by
    field_simp
  linarith [step2 ▸ step1]

/-- The first celestial coordinate of the `k`-th spine event, as a real number. -/
noncomputable def sx (k : ℕ) : ℝ := ((spine k).1 : ℝ) / ((spine k).2.2 : ℝ)

theorem sx_nonneg (k : ℕ) : 0 ≤ sx k := by
  obtain ⟨_, ha, _, hc⟩ := spine_isEvent k
  have h1 : (0 : ℝ) ≤ ((spine k).1 : ℝ) := by exact_mod_cast ha.le
  have h2 : (0 : ℝ) < ((spine k).2.2 : ℝ) := by exact_mod_cast hc
  exact div_nonneg h1 h2.le

/-- The square of the spine's celestial direction is within `1/(k+5)` of `1/2`. -/
theorem sx_sq_bound (k : ℕ) : |sx k ^ 2 - 1 / 2| ≤ 1 / ((k : ℝ) + 5) := by
  have hev : IsEvent ((spine k).1, (spine k).2.1, (spine k).2.2) := spine_isEvent k
  have hbound := dir_sq_bound hev (spine_diff_sq k)
  have hCk : (k : ℝ) + 5 ≤ ((spine k).2.2 : ℝ) := by
    have h := spine_hyp_ge k
    have h' : ((5 + (k : ℤ) : ℤ) : ℝ) ≤ ((spine k).2.2 : ℝ) := by exact_mod_cast h
    push_cast at h'
    linarith
  have hpos : (0 : ℝ) < (k : ℝ) + 5 := by positivity
  have hstep : 1 / ((spine k).2.2 : ℝ) ≤ 1 / ((k : ℝ) + 5) :=
    one_div_le_one_div_of_le hpos hCk
  calc |sx k ^ 2 - 1 / 2| ≤ 1 / ((spine k).2.2 : ℝ) := hbound
    _ ≤ 1 / ((k : ℝ) + 5) := hstep

/-- **The Pell spine has a well-defined endpoint on the celestial circle**: its null
directions converge to the `45°` direction `√2 / 2`. -/
theorem spine_dir_tendsto : Tendsto sx atTop (𝓝 (Real.sqrt 2 / 2)) := by
  have hb : Tendsto (fun k : ℕ => 1 / ((k : ℝ) + 5)) atTop (𝓝 0) :=
    squeeze_zero (fun k => by positivity)
      (fun k => by apply one_div_le_one_div_of_le (by positivity); linarith)
      tendsto_one_div_add_atTop_nhds_zero_nat
  have hsq0 : Tendsto (fun k : ℕ => sx k ^ 2 - 1 / 2) atTop (𝓝 0) :=
    squeeze_zero_norm (fun k => by simpa [Real.norm_eq_abs] using sx_sq_bound k) hb
  have hsq : Tendsto (fun k : ℕ => sx k ^ 2) atTop (𝓝 (1 / 2)) := by
    have h := hsq0.add_const (1 / 2)
    rw [zero_add] at h
    exact h.congr (fun k => by ring)
  have hlim : Tendsto (fun k : ℕ => Real.sqrt (sx k ^ 2)) atTop (𝓝 (Real.sqrt (1 / 2))) :=
    hsq.sqrt
  have hval : Real.sqrt (1 / 2 : ℝ) = Real.sqrt 2 / 2 := by
    rw [show (1 : ℝ) / 2 = (Real.sqrt 2 / 2) ^ 2 by
      rw [div_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)]; norm_num]
    exact Real.sqrt_sq (by positivity)
  rw [hval] at hlim
  exact hlim.congr (fun k => Real.sqrt_sq (sx_nonneg k))

/-- **The boundary point is not an event.**  The limiting celestial direction of the Pell
spine is irrational, whereas every event has a rational direction: the conformal boundary
of the Berggren causal set is a genuine extension of it, and the spine is an infinite
causal chain with no last event but a definite endpoint at infinity. -/
theorem spine_limit_irrational : Irrational (Real.sqrt 2 / 2) := by
  have h : Irrational (Real.sqrt 2 / ((2 : ℕ) : ℝ)) :=
    Irrational.div_natCast irrational_sqrt_two (by norm_num)
  simpa using h

/-- No event of the causal set sits at the spine's boundary direction. -/
theorem spine_limit_not_event (t : Event) :
    ((dir t).1 : ℝ) ≠ Real.sqrt 2 / 2 := fun h =>
  spine_limit_irrational ⟨(dir t).1, h⟩

end BerggrenCausalSet