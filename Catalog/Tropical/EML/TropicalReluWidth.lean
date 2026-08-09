import Tropical.EML.TropicalDescentRobustness

/-!
# Exact ReLU width of tropical clipped updates: a kink-counting lower bound

`Tropical.EML.TropicalDescentRobustness` proves that the *scalar* clipped tropical
update needs exactly two ReLU units.  That argument used convexity, which is
special to two kinks.  Here we develop the general mechanism behind such
statements and push it to the even-sample dynamics, whose update map has **four**
kinks.

The mechanism is a discrete second-difference (curvature) test:

* `relu_second_diff_zero` : a single ReLU has vanishing second difference at any
  point whose `h`-window misses its kink;
* `reluNet_second_diff_zero` : hence so does a whole width-`k` network with a
  linear skip term, `reluNet a b c p q x = ∑ⱼ aⱼ relu (bⱼ x + cⱼ) + p x + q`;
* `reluNet_kink_witness` : contrapositive — a nonzero second difference at `x`
  with radius `h` *forces* some unit to have its kink strictly inside the window.

Counting witnesses at well-separated kinks then yields width lower bounds:

* `tropicalFlow_relu_width_ge_two` : the scalar clipped update needs `≥ 2` units,
  even allowing an arbitrary affine skip connection (strictly stronger than the
  convexity argument of `no_single_relu`);
* `intervalStep_relu_width_ge_four` and `intervalStep_relu_width_four_exact` :
  the even-sample interval update needs `≥ 4` units and `4` units suffice.

So the tropical minimizer geometry (a point versus a segment) is read off exactly
by the ReLU width needed to implement one training step: `2` versus `4`.
-/

noncomputable section

open EMLTropicalGradientFlow EMLTropicalGD TropicalMedianDescent

namespace TropicalReluWidth

/-! ## The second-difference (curvature) test -/

/-- A ReLU is affine on any window avoiding its kink: the second difference vanishes. -/
theorem relu_second_diff_zero {u v : ℝ} (h : |v| ≤ |u|) :
    relu (u + v) + relu (u - v) - 2 * relu u = 0 := by
  unfold relu
  have hva := neg_abs_le v
  have hvb := le_abs_self v
  rcases le_total 0 u with hu | hu
  · have h1 : |v| ≤ u := by rwa [abs_of_nonneg hu] at h
    rw [max_eq_left (by linarith), max_eq_left (by linarith), max_eq_left hu]
    ring
  · have h1 : |v| ≤ -u := by rwa [abs_of_nonpos hu] at h
    rw [max_eq_right (by linarith), max_eq_right (by linarith), max_eq_right hu]
    ring

/-- A width-`k` ReLU network with an affine skip term. -/
def reluNet {k : ℕ} (a b c : Fin k → ℝ) (p q x : ℝ) : ℝ :=
  (∑ j, a j * relu (b j * x + c j)) + p * x + q

/-- If no unit has its kink inside the `h`-window at `x`, the network is affine there. -/
theorem reluNet_second_diff_zero {k : ℕ} {a b c : Fin k → ℝ} {p q x h : ℝ} (hh : 0 ≤ h)
    (hkink : ∀ j, |b j| * h ≤ |b j * x + c j|) :
    reluNet a b c p q (x + h) + reluNet a b c p q (x - h) - 2 * reluNet a b c p q x = 0 := by
  unfold reluNet
  have key : ∀ j : Fin k,
      a j * relu (b j * (x + h) + c j) + a j * relu (b j * (x - h) + c j)
        - 2 * (a j * relu (b j * x + c j)) = 0 := by
    intro j
    have habs : |b j * h| ≤ |b j * x + c j| := by
      rw [abs_mul, abs_of_nonneg hh]
      exact hkink j
    have hz := relu_second_diff_zero (u := b j * x + c j) (v := b j * h) habs
    have e1 : b j * (x + h) + c j = (b j * x + c j) + b j * h := by ring
    have e2 : b j * (x - h) + c j = (b j * x + c j) - b j * h := by ring
    rw [e1, e2]
    linear_combination a j * hz
  have hsum := Finset.sum_eq_zero (fun j (_ : j ∈ Finset.univ) => key j)
  rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum] at hsum
  linarith

/-- **Kink witness.**  A nonvanishing second difference forces a unit whose kink lies
strictly inside the window. -/
theorem reluNet_kink_witness {k : ℕ} {a b c : Fin k → ℝ} {p q x h : ℝ} (hh : 0 ≤ h)
    (hD : reluNet a b c p q (x + h) + reluNet a b c p q (x - h)
      - 2 * reluNet a b c p q x ≠ 0) :
    ∃ j, |b j * x + c j| < |b j| * h := by
  by_contra hcon
  push_neg at hcon
  exact hD (reluNet_second_diff_zero hh (fun j => hcon j))

/-- Two windows of radius `h` sharing a unit must be closer than `2h`. -/
theorem kink_window_separation {b c x y h : ℝ}
    (hx : |b * x + c| < |b| * h) (hy : |b * y + c| < |b| * h) (hsep : 2 * h ≤ |x - y|) :
    False := by
  have hb : 0 < |b| := by
    rcases lt_or_ge 0 |b| with hb | hb
    · exact hb
    · have hb0 : |b| = 0 := le_antisymm hb (abs_nonneg b)
      rw [hb0, zero_mul] at hx
      exact absurd hx (not_lt.mpr (abs_nonneg _))
  have hxy : |b| * |x - y| = |(b * x + c) - (b * y + c)| := by
    rw [← abs_mul]
    congr 1
    ring
  have htri : |(b * x + c) - (b * y + c)| ≤ |b * x + c| + |b * y + c| := abs_sub _ _
  have h1 : |b| * (2 * h) ≤ |b| * |x - y| := by
    exact mul_le_mul_of_nonneg_left hsep hb.le
  rw [hxy] at h1
  linarith

/-! ## Width lower bounds from separated kinks -/

/-- **Scalar clipped update needs at least two ReLU units**, even with an affine skip. -/
theorem tropicalFlow_relu_width_ge_two {m t : ℝ} (ht : 0 < t) {k : ℕ} {a b c : Fin k → ℝ}
    {p q : ℝ} (hrep : ∀ x : ℝ, reluNet a b c p q x = tropicalFlow m t x) : 2 ≤ k := by
  set h : ℝ := t / 2 with hh
  have hhpos : 0 < h := by rw [hh]; linarith
  -- values of the clipped flow near its two kinks
  have f_left_lo : tropicalFlow m t (m - t - h) = m - h := by
    unfold tropicalFlow
    rw [if_pos (by linarith), min_eq_right (by linarith)]
    ring
  have f_left_mid : tropicalFlow m t (m - t) = m := by
    unfold tropicalFlow
    rw [if_pos (by linarith), min_eq_left (by linarith)]
  have f_left_hi : tropicalFlow m t (m - t + h) = m := by
    unfold tropicalFlow
    rw [if_pos (by linarith), min_eq_left (by linarith)]
  have f_right_lo : tropicalFlow m t (m + t - h) = m := by
    unfold tropicalFlow
    rw [if_neg (by linarith), max_eq_left (by linarith)]
  have f_right_mid : tropicalFlow m t (m + t) = m := by
    unfold tropicalFlow
    rw [if_neg (by linarith), max_eq_left (by linarith)]
  have f_right_hi : tropicalFlow m t (m + t + h) = m + h := by
    unfold tropicalFlow
    rw [if_neg (by linarith), max_eq_right (by linarith)]
    ring
  have hD1 : reluNet a b c p q ((m - t) + h) + reluNet a b c p q ((m - t) - h)
      - 2 * reluNet a b c p q (m - t) ≠ 0 := by
    rw [hrep, hrep, hrep, f_left_hi, f_left_mid, f_left_lo]
    intro hc
    linarith
  have hD2 : reluNet a b c p q ((m + t) + h) + reluNet a b c p q ((m + t) - h)
      - 2 * reluNet a b c p q (m + t) ≠ 0 := by
    rw [hrep, hrep, hrep, f_right_hi, f_right_mid, f_right_lo]
    intro hc
    linarith
  obtain ⟨j1, hj1⟩ := reluNet_kink_witness hhpos.le hD1
  obtain ⟨j2, hj2⟩ := reluNet_kink_witness hhpos.le hD2
  have hne : j1 ≠ j2 := by
    rintro rfl
    refine kink_window_separation hj1 hj2 ?_
    have : |(m - t) - (m + t)| = 2 * t := by
      rw [show (m - t) - (m + t) = -(2 * t) by ring, abs_neg, abs_of_nonneg (by linarith)]
    rw [this, hh]
    linarith
  by_contra hk
  push_neg at hk
  interval_cases k
  · exact absurd j1.isLt (by omega)
  · have : j1 = j2 := Subsingleton.elim _ _
    exact hne this

/-! ## The even-sample interval update: explicit piecewise form -/

theorem intervalStep_left {lo hi η θ : ℝ} (hlohi : lo ≤ hi) (hη : 0 ≤ η) (hθ : θ ≤ lo) :
    intervalStep lo hi η θ = min lo (θ + η) := by
  unfold intervalStep projIcc tropicalFlow
  simp only [min_def, max_def]
  split_ifs <;> linarith

theorem intervalStep_right {lo hi η θ : ℝ} (hlohi : lo ≤ hi) (hθ : hi ≤ θ) :
    intervalStep lo hi η θ = max hi (θ - η) := by
  unfold intervalStep projIcc tropicalFlow
  simp only [min_def, max_def]
  split_ifs <;> linarith

/-- `relu` vanishes on nonpositive inputs. -/
theorem relu_of_nonpos {x : ℝ} (hx : x ≤ 0) : relu x = 0 := max_eq_right hx

/-- `relu` is the identity on nonnegative inputs. -/
theorem relu_of_nonneg {x : ℝ} (hx : 0 ≤ x) : relu x = x := max_eq_left hx

/-- **Four ReLU units realize the interval update exactly.**  The four kinks sit at
`lo - η`, `lo`, `hi` and `hi + η`, with alternating curvature signs. -/
theorem intervalStep_eq_four_relu {lo hi η θ : ℝ} (hlohi : lo ≤ hi) (hη : 0 ≤ η) :
    intervalStep lo hi η θ =
      θ + η - relu (θ - (lo - η)) + relu (θ - lo) - relu (θ - hi)
        + relu (θ - (hi + η)) := by
  rcases le_total θ (lo - η) with h1 | h1
  · rw [intervalStep_left hlohi hη (by linarith), min_eq_right (by linarith),
      relu_of_nonpos (x := θ - (lo - η)) (by linarith),
      relu_of_nonpos (x := θ - lo) (by linarith),
      relu_of_nonpos (x := θ - hi) (by linarith),
      relu_of_nonpos (x := θ - (hi + η)) (by linarith)]
    ring
  · rcases le_total θ lo with h2 | h2
    · rw [intervalStep_left hlohi hη h2, min_eq_left (by linarith),
        relu_of_nonneg (x := θ - (lo - η)) (by linarith),
        relu_of_nonpos (x := θ - lo) (by linarith),
        relu_of_nonpos (x := θ - hi) (by linarith),
        relu_of_nonpos (x := θ - (hi + η)) (by linarith)]
      ring
    · rcases le_total θ hi with h3 | h3
      · rw [intervalStep_fixed hη h2 h3,
          relu_of_nonneg (x := θ - (lo - η)) (by linarith),
          relu_of_nonneg (x := θ - lo) (by linarith),
          relu_of_nonpos (x := θ - hi) (by linarith),
          relu_of_nonpos (x := θ - (hi + η)) (by linarith)]
        ring
      · rcases le_total θ (hi + η) with h4 | h4
        · rw [intervalStep_right hlohi h3, max_eq_left (by linarith),
            relu_of_nonneg (x := θ - (lo - η)) (by linarith),
            relu_of_nonneg (x := θ - lo) (by linarith),
            relu_of_nonneg (x := θ - hi) (by linarith),
            relu_of_nonpos (x := θ - (hi + η)) (by linarith)]
          ring
        · rw [intervalStep_right hlohi h3, max_eq_right (by linarith),
            relu_of_nonneg (x := θ - (lo - η)) (by linarith),
            relu_of_nonneg (x := θ - lo) (by linarith),
            relu_of_nonneg (x := θ - hi) (by linarith),
            relu_of_nonneg (x := θ - (hi + η)) (by linarith)]
          ring

/-! ## Width four is exactly right for the interval update -/

/-- **Interval update needs at least four ReLU units.**  Its four kinks are
`2h`-separated, so four distinct units must supply them. -/
theorem intervalStep_relu_width_ge_four {lo hi η : ℝ} (hlt : lo < hi) (hη : 0 < η)
    {k : ℕ} {a b c : Fin k → ℝ} {p q : ℝ}
    (hrep : ∀ θ : ℝ, reluNet a b c p q θ = intervalStep lo hi η θ) : 4 ≤ k := by
  set h : ℝ := min η (hi - lo) / 2 with hhdef
  have hη2 : 2 * h ≤ η := by
    rw [hhdef]
    have := min_le_left η (hi - lo)
    linarith
  have hgap : 2 * h ≤ hi - lo := by
    rw [hhdef]
    have := min_le_right η (hi - lo)
    linarith
  have hhpos : 0 < h := by
    rw [hhdef]
    have : 0 < min η (hi - lo) := lt_min hη (by linarith)
    linarith
  have hlohi : lo ≤ hi := hlt.le
  -- the twelve evaluations of the update map around its four kinks
  have v1a : intervalStep lo hi η (lo - η + h) = lo := by
    rw [intervalStep_left hlohi hη.le (by linarith), min_eq_left (by linarith)]
  have v1b : intervalStep lo hi η (lo - η) = lo := by
    rw [intervalStep_left hlohi hη.le (by linarith), min_eq_left (by linarith)]
  have v1c : intervalStep lo hi η (lo - η - h) = lo - h := by
    rw [intervalStep_left hlohi hη.le (by linarith), min_eq_right (by linarith)]
    ring
  have v2a : intervalStep lo hi η (lo + h) = lo + h :=
    intervalStep_fixed hη.le (by linarith) (by linarith)
  have v2b : intervalStep lo hi η lo = lo :=
    intervalStep_fixed hη.le (le_refl lo) hlohi
  have v2c : intervalStep lo hi η (lo - h) = lo := by
    rw [intervalStep_left hlohi hη.le (by linarith), min_eq_left (by linarith)]
  have v3a : intervalStep lo hi η (hi + h) = hi := by
    rw [intervalStep_right hlohi (by linarith), max_eq_left (by linarith)]
  have v3b : intervalStep lo hi η hi = hi :=
    intervalStep_fixed hη.le hlohi (le_refl hi)
  have v3c : intervalStep lo hi η (hi - h) = hi - h :=
    intervalStep_fixed hη.le (by linarith) (by linarith)
  have v4a : intervalStep lo hi η (hi + η + h) = hi + h := by
    rw [intervalStep_right hlohi (by linarith), max_eq_right (by linarith)]
    ring
  have v4b : intervalStep lo hi η (hi + η) = hi := by
    rw [intervalStep_right hlohi (by linarith), max_eq_left (by linarith)]
  have v4c : intervalStep lo hi η (hi + η - h) = hi := by
    rw [intervalStep_right hlohi (by linarith), max_eq_left (by linarith)]
  -- four nonvanishing second differences
  have hD1 : reluNet a b c p q (lo - η + h) + reluNet a b c p q (lo - η - h)
      - 2 * reluNet a b c p q (lo - η) ≠ 0 := by
    rw [hrep, hrep, hrep, v1a, v1b, v1c]
    intro hc; linarith
  have hD2 : reluNet a b c p q (lo + h) + reluNet a b c p q (lo - h)
      - 2 * reluNet a b c p q lo ≠ 0 := by
    rw [hrep, hrep, hrep, v2a, v2b, v2c]
    intro hc; linarith
  have hD3 : reluNet a b c p q (hi + h) + reluNet a b c p q (hi - h)
      - 2 * reluNet a b c p q hi ≠ 0 := by
    rw [hrep, hrep, hrep, v3a, v3b, v3c]
    intro hc; linarith
  have hD4 : reluNet a b c p q (hi + η + h) + reluNet a b c p q (hi + η - h)
      - 2 * reluNet a b c p q (hi + η) ≠ 0 := by
    rw [hrep, hrep, hrep, v4a, v4b, v4c]
    intro hc; linarith
  obtain ⟨j1, hj1⟩ := reluNet_kink_witness (x := lo - η) hhpos.le hD1
  obtain ⟨j2, hj2⟩ := reluNet_kink_witness (x := lo) hhpos.le hD2
  obtain ⟨j3, hj3⟩ := reluNet_kink_witness (x := hi) hhpos.le hD3
  obtain ⟨j4, hj4⟩ := reluNet_kink_witness (x := hi + η) hhpos.le hD4
  have habs : ∀ u v : ℝ, u ≤ v → |u - v| = v - u := by
    intro u v huv
    rw [abs_of_nonpos (by linarith)]
    ring
  have h12 : j1 ≠ j2 := by
    rintro rfl
    exact kink_window_separation hj1 hj2
      (by rw [habs _ _ (by linarith : lo - η ≤ lo)]; linarith)
  have h13 : j1 ≠ j3 := by
    rintro rfl
    exact kink_window_separation hj1 hj3
      (by rw [habs _ _ (by linarith : lo - η ≤ hi)]; linarith)
  have h14 : j1 ≠ j4 := by
    rintro rfl
    exact kink_window_separation hj1 hj4
      (by rw [habs _ _ (by linarith : lo - η ≤ hi + η)]; linarith)
  have h23 : j2 ≠ j3 := by
    rintro rfl
    exact kink_window_separation hj2 hj3
      (by rw [habs _ _ (by linarith : lo ≤ hi)]; linarith)
  have h24 : j2 ≠ j4 := by
    rintro rfl
    exact kink_window_separation hj2 hj4
      (by rw [habs _ _ (by linarith : lo ≤ hi + η)]; linarith)
  have h34 : j3 ≠ j4 := by
    rintro rfl
    exact kink_window_separation hj3 hj4
      (by rw [habs _ _ (by linarith : hi ≤ hi + η)]; linarith)
  have hcard4 : ({j1, j2, j3, j4} : Finset (Fin k)).card = 4 := by
    rw [Finset.card_insert_of_notMem (by simp [h12, h13, h14]),
      Finset.card_insert_of_notMem (by simp [h23, h24]),
      Finset.card_insert_of_notMem (by simp [h34]), Finset.card_singleton]
  have hle := Finset.card_le_univ ({j1, j2, j3, j4} : Finset (Fin k))
  simpa [hcard4] using hle

/-- **Exact ReLU width four for the even-sample interval update.**  Four shifted ReLU
units with a linear skip implement one clipped step toward the minimizer interval,
and no network of fewer units can. -/
theorem intervalStep_relu_width_four_exact {lo hi η : ℝ} (hlt : lo < hi) (hη : 0 < η) :
    (∀ θ : ℝ, intervalStep lo hi η θ =
        reluNet ![-1, 1, -1, 1] ![1, 1, 1, 1] ![η - lo, -lo, -hi, -(hi + η)] 1 η θ) ∧
    (∀ (k : ℕ) (a b c : Fin k → ℝ) (p q : ℝ),
      (∀ θ : ℝ, reluNet a b c p q θ = intervalStep lo hi η θ) → 4 ≤ k) := by
  refine ⟨fun θ => ?_, fun k a b c p q hrep => intervalStep_relu_width_ge_four hlt hη hrep⟩
  rw [intervalStep_eq_four_relu hlt.le hη.le]
  simp [reluNet, Fin.sum_univ_four]
  ring_nf

/-! ## The width dichotomy

The same one-parameter family of update maps `intervalStep lo hi η` covers both
sample parities: `lo = hi` is the odd (point minimizer) case and `lo < hi` the even
(segment minimizer) case.  Its exact ReLU width detects which one holds. -/

/-- A degenerate interval gives back the scalar clipped flow. -/
theorem intervalStep_degenerate (m η θ : ℝ) : intervalStep m m η θ = tropicalFlow m η θ := by
  unfold intervalStep projIcc
  rw [min_def, max_def]
  split_ifs <;> rfl

/-- Two ReLU units with a constant skip implement the scalar clipped update. -/
theorem tropicalFlow_eq_two_reluNet {m t : ℝ} (ht : 0 ≤ t) (θ : ℝ) :
    tropicalFlow m t θ = reluNet ![1, -1] ![1, -1] ![-(m + t), m - t] 0 m θ := by
  rw [tropicalFlow_eq_two_relu ht]
  simp [reluNet, Fin.sum_univ_two]
  ring_nf

/-- **Width dichotomy.**  One clipped descent step toward the tropical `L¹` minimizer
set needs exactly two ReLU units when that set is a point, and exactly four when it is
a nondegenerate segment.  The ReLU width of the optimizer therefore reads off the
parity structure of the sample. -/
theorem descent_step_relu_width_dichotomy {lo hi η : ℝ} (hlohi : lo ≤ hi) (hη : 0 < η) :
    (lo = hi →
      (∀ θ : ℝ, intervalStep lo hi η θ =
          reluNet ![1, -1] ![1, -1] ![-(lo + η), lo - η] 0 lo θ) ∧
      (∀ (k : ℕ) (a b c : Fin k → ℝ) (p q : ℝ),
        (∀ θ : ℝ, reluNet a b c p q θ = intervalStep lo hi η θ) → 2 ≤ k)) ∧
    (lo < hi →
      (∀ θ : ℝ, intervalStep lo hi η θ =
          reluNet ![-1, 1, -1, 1] ![1, 1, 1, 1] ![η - lo, -lo, -hi, -(hi + η)] 1 η θ) ∧
      (∀ (k : ℕ) (a b c : Fin k → ℝ) (p q : ℝ),
        (∀ θ : ℝ, reluNet a b c p q θ = intervalStep lo hi η θ) → 4 ≤ k)) := by
  constructor
  · rintro rfl
    refine ⟨fun θ => ?_, fun k a b c p q hrep => ?_⟩
    · rw [intervalStep_degenerate, tropicalFlow_eq_two_reluNet hη.le]
    · have hrep' : ∀ x : ℝ, reluNet a b c p q x = tropicalFlow lo η x := by
        intro x
        rw [hrep x, intervalStep_degenerate]
      exact tropicalFlow_relu_width_ge_two hη hrep'
  · intro hlt
    exact ⟨(intervalStep_relu_width_four_exact hlt hη).1,
      (intervalStep_relu_width_four_exact hlt hη).2⟩

end TropicalReluWidth