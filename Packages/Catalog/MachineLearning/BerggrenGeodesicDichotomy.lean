import MachineLearning.BerggrenHorocycleStars

/-!
# Geodesic versus horocycle: why some Berggren lines radiate and others make stars

The companion file `MachineLearning.BerggrenHorocycleStars` shows that the two *parabolic*
Berggren generators sweep every node of the tree along a horocycle into a **rational**
boundary point, producing the observed stars.  This file completes the picture by
analysing the third, *hyperbolic*, generator and by quantifying the difference.

## Main results

* `abs_sub_sqrt_two_div_two_le` — a sharp elementary estimate on the unit circle: for a
  point `(x,y)` of the first quadrant of the circle, `|x − √2/2| ≤ |x − y|`.
* `dirx_sub_diag_le` — hence for a Pythagorean triple, `|a/c − √2/2| ≤ |a−b|/c`.
* `mB_ray_bound`, `mB_ray_tendsto` — the hyperbolic generator conserves `|a − b|` while
  multiplying the hypotenuse by at least `3`, so *every* node is driven to the ideal point
  at angle `π/4` at an **exponential** rate `O(3^{-k})`.
* `mC_ray_poly_lower` — by contrast the parabolic rays approach their boundary point at
  the polynomial rate `Θ(k^{-2})` and no faster.
* `berggren_rate_dichotomy` — the two rates compared on the root triple `(3,4,5)`.
* `no_triple_direction_at_pi_div_four` — the hyperbolic ideal point is irrational, hence
  is *never* occupied by a plotted triple.  There is no star at `π/4`, only one geodesic:
  stars can occur only at rational ideal points.
* `star_centres_dense` — and rational ideal points (star centres) are dense in the arc,
  which is why the plot is speckled with stars everywhere along the boundary.
-/

namespace BerggrenStars

open Filter Topology

/-! ### A sharp circle estimate -/

/-- On the first quadrant of the unit circle, the distance to the diagonal point
`(√2/2, √2/2)` is controlled by the difference of the coordinates. -/
theorem abs_sub_sqrt_two_div_two_le {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y)
    (hxy : x ^ 2 + y ^ 2 = 1) : |x - Real.sqrt 2 / 2| ≤ |x - y| := by
  set s := Real.sqrt 2 with hs
  have hs2 : s ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hs0 : 0 < s := Real.sqrt_pos.mpr (by norm_num)
  have hsum : x + y ≤ s := by
    by_contra hcon
    push_neg at hcon
    have h1 : 0 < x + y - s := by linarith
    have h2 : 0 < x + y + s := by linarith
    nlinarith [mul_pos h1 h2, sq_nonneg (x - y)]
  have hpos : 0 < x + s / 2 := by linarith
  have hprod : |x - s / 2| * (x + s / 2) = |x - y| * (x + y) / 2 := by
    rw [← abs_of_pos hpos, ← abs_mul]
    have h1 : (x - s / 2) * (x + s / 2) = (x - y) * (x + y) / 2 := by nlinarith
    rw [h1, abs_div, abs_mul, abs_of_nonneg (by linarith : (0 : ℝ) ≤ x + y)]
    norm_num
  have hle : |x - y| * (x + y) / 2 ≤ |x - y| * (x + s / 2) := by
    nlinarith [abs_nonneg (x - y), hsum, hx]
  exact le_of_mul_le_mul_right (by linarith [hprod, hle]) hpos

/-- For a Pythagorean triple with nonnegative legs, the plotted abscissa is within
`|a−b|/c` of the diagonal ideal point `√2/2 = cos(π/4)`. -/
theorem dirx_sub_diag_le {a b c : ℤ} (h : OnCone (a, b, c)) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hc : 0 < c) : |dirx (a, b, c) - Real.sqrt 2 / 2| ≤ |(a : ℝ) - (b : ℝ)| / (c : ℝ) := by
  have hcR : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hc
  have hx : 0 ≤ dirx (a, b, c) := div_nonneg (by exact_mod_cast ha) hcR.le
  have hy : 0 ≤ diry (a, b, c) := div_nonneg (by exact_mod_cast hb) hcR.le
  have hcirc := dir_on_circle (a, b, c) h (by simpa using hc)
  have hdiff : dirx (a, b, c) - diry (a, b, c) = ((a : ℝ) - (b : ℝ)) / (c : ℝ) := by
    simp only [dirx, diry]
    ring
  have := abs_sub_sqrt_two_div_two_le hx hy hcirc
  rwa [hdiff, abs_div, abs_of_pos hcR] at this

/-! ### The hyperbolic ray: exponential approach to an irrational ideal point -/

/-- **Exponential approach along the hyperbolic generator.**  Every node of the tree is
driven by `mB` to the ideal point at angle `π/4`, and the error is `O(3^{-k})`. -/
theorem mB_ray_bound {a b c : ℤ} (h : OnCone (a, b, c)) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (k : ℕ) :
    |dirx (mB^[k] (a, b, c)) - Real.sqrt 2 / 2| ≤ |(a : ℝ) - (b : ℝ)| / (3 ^ k * (c : ℝ)) := by
  obtain ⟨hgrow, hp1, hp2⟩ := mB_iterate_growth ha hb hc k
  have hcone := onCone_mB_iterate (v := (a, b, c)) h k
  have hcharge := mB_iterate_charge (a, b, c) k
  have h3c : (0 : ℤ) < 3 ^ k * c := by positivity
  have hck : 0 < (mB^[k] (a, b, c)).2.2 := lt_of_lt_of_le h3c hgrow
  set w := mB^[k] (a, b, c) with hw
  have hbound := dirx_sub_diag_le (a := w.1) (b := w.2.1) (c := w.2.2)
      (by simpa using hcone) hp1.le hp2.le hck
  have hwe : ((w.1, w.2.1, w.2.2) : Vec) = w := rfl
  rw [hwe] at hbound
  refine hbound.trans ?_
  have habs : |(w.1 : ℝ) - (w.2.1 : ℝ)| = |(a : ℝ) - (b : ℝ)| := by
    have : ((w.1 - w.2.1 : ℤ) : ℝ) = ((-1) ^ k * (a - b) : ℤ) := by
      exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) hcharge
    push_cast at this
    rw [show (w.1 : ℝ) - (w.2.1 : ℝ) = ((w.1 - w.2.1 : ℤ) : ℝ) by push_cast; ring]
    rw [show ((w.1 - w.2.1 : ℤ) : ℝ) = (-1) ^ k * ((a : ℝ) - (b : ℝ)) by
      push_cast at this ⊢; linarith [this]]
    rw [abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul]
  rw [habs]
  apply div_le_div_of_nonneg_left (abs_nonneg _) (by positivity)
  exact_mod_cast hgrow

/-- The hyperbolic branch converges to the ideal point at angle `π/4`. -/
theorem mB_ray_tendsto {a b c : ℤ} (h : OnCone (a, b, c)) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) :
    Tendsto (fun k => dirx (mB^[k] (a, b, c))) atTop (𝓝 (Real.sqrt 2 / 2)) := by
  have hcR : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hc
  have hzero : Tendsto (fun k : ℕ => |(a : ℝ) - (b : ℝ)| / (3 ^ k * (c : ℝ))) atTop (𝓝 0) := by
    have : ∀ k : ℕ, |(a : ℝ) - (b : ℝ)| / (3 ^ k * (c : ℝ))
        = (|(a : ℝ) - (b : ℝ)| / (c : ℝ)) * ((1 / 3 : ℝ) ^ k) := by
      intro k
      rw [one_div, inv_pow]
      field_simp
    simp only [this]
    simpa using
      (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num : (0:ℝ) ≤ 1/3)
        (by norm_num : (1/3 : ℝ) < 1)).const_mul (|(a : ℝ) - (b : ℝ)| / (c : ℝ))
  exact tendsto_of_abs_sub_le hzero (fun k => mB_ray_bound h ha hb hc k)

/-! ### The parabolic rate is only polynomial -/

/-- **Polynomial lower bound for a parabolic ray.**  Along the `mC`-flow the plotted point
stays at distance at least `d / (M k²)` from the boundary point `(1,0)`, where `d = c − a`
is the conserved charge.  Compare `mB_ray_bound`: exponential versus quadratic. -/
theorem mC_ray_poly_lower {a b c : ℤ} (h : OnCone (a, b, c)) (hb : 0 < b) (hc : 0 < c)
    {k : ℕ} (hk : 1 ≤ k) :
    ((c - a : ℤ) : ℝ) / (((c + 2 * b + 2 * (c - a) : ℤ) : ℝ) * (k : ℝ) ^ 2)
      ≤ 1 - dirx (mC^[k] (a, b, c)) := by
  have hd : 0 < c - a := charge_pos h hb hc
  have hck : (k : ℤ) < (mC^[k] (a, b, c)).2.2 := mC_iterate_hyp_ge h hb hc k
  have hckpos : (0 : ℤ) < (mC^[k] (a, b, c)).2.2 := lt_of_le_of_lt (by exact_mod_cast Nat.zero_le k) hck
  have hval : (mC^[k] (a, b, c)).2.2 = c + 2 * (k : ℤ) * b + 2 * (k : ℤ) ^ 2 * (c - a) := by
    rw [mC_iterate]
  have hupper : (mC^[k] (a, b, c)).2.2 ≤ (c + 2 * b + 2 * (c - a)) * (k : ℤ) ^ 2 := by
    have hk1 : (1 : ℤ) ≤ (k : ℤ) := by exact_mod_cast hk
    have hk2 : (k : ℤ) ≤ (k : ℤ) ^ 2 := by nlinarith
    have hk3 : (1 : ℤ) ≤ (k : ℤ) ^ 2 := by nlinarith
    rw [hval]
    nlinarith [mul_le_mul_of_nonneg_left hk3 hc.le, mul_le_mul_of_nonneg_left hk2 hb.le]
  have hcharge : (mC^[k] (a, b, c)).2.2 - (mC^[k] (a, b, c)).1 = c - a :=
    mC_iterate_charge (a, b, c) k
  have heq : 1 - dirx (mC^[k] (a, b, c)) = ((c - a : ℤ) : ℝ) / (((mC^[k] (a, b, c)).2.2 : ℤ) : ℝ) := by
    rw [star_curve_equation _ hckpos, hcharge]
    ring
  rw [heq]
  apply div_le_div_of_nonneg_left (by exact_mod_cast hd.le)
  · exact_mod_cast hckpos
  · exact_mod_cast hupper

/-- **The dichotomy, on the root triple.**  From `(3,4,5)`, the parabolic branch stays at
distance `≥ 2/(17k²)` from its ideal point, while the hyperbolic branch is within
`1/(5·3^k)` of its own — polynomial versus exponential contact with the circle. -/
theorem berggren_rate_dichotomy {k : ℕ} (hk : 1 ≤ k) :
    (2 : ℝ) / (17 * (k : ℝ) ^ 2) ≤ 1 - dirx (mC^[k] root) ∧
      |dirx (mB^[k] root) - Real.sqrt 2 / 2| ≤ 1 / (5 * 3 ^ k) := by
  have hroot : OnCone ((3 : ℤ), (4 : ℤ), (5 : ℤ)) := by
    simpa [root] using onCone_root
  constructor
  · have := mC_ray_poly_lower hroot (by norm_num) (by norm_num) hk
    simpa [root] using (by norm_num at this ⊢; exact this)
  · have := mB_ray_bound hroot (by norm_num) (by norm_num) (by norm_num) k
    have h1 : |((3 : ℤ) : ℝ) - ((4 : ℤ) : ℝ)| / (3 ^ k * ((5 : ℤ) : ℝ)) = 1 / (5 * 3 ^ k) := by
      norm_num
      ring
    rw [h1] at this
    simpa [root] using this

/-! ### Stars only sit at rational ideal points -/

theorem irrational_sqrt_two_div_two : Irrational (Real.sqrt 2 / 2) := by
  simpa using irrational_sqrt_two.div_natCast (m := 2) (by norm_num)

/-- The ideal point of the hyperbolic axis is never occupied by a Pythagorean triple:
there is no star at angle `π/4`, only a single geodesic sliding into it. -/
theorem no_triple_direction_at_pi_div_four (v : Vec) (hc : v.2.2 ≠ 0) :
    dirx v ≠ Real.sqrt 2 / 2 := by
  intro hcon
  have hq : dirx v = ((v.1 / v.2.2 : ℚ) : ℝ) := by
    have : ((v.2.2 : ℚ) : ℝ) ≠ 0 := by
      simpa using (show (v.2.2 : ℝ) ≠ 0 by exact_mod_cast hc)
    push_cast
    rfl
  exact irrational_sqrt_two_div_two ⟨(v.1 / v.2.2 : ℚ), by rw [← hq, hcon]⟩

/-! ### Star centres are dense on the boundary arc -/

private theorem continuous_gcirc : Continuous fun r : ℝ => (r ^ 2 - 1) / (r ^ 2 + 1) := by
  apply Continuous.div (by fun_prop) (by fun_prop)
  intro r
  positivity

/-- **Density of star centres.**  Every point of the boundary arc `[0,1)` is approximated
arbitrarily well by the ideal point of a Pythagorean triple, i.e. by a star centre. -/
theorem star_centres_dense (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t < 1) {ε : ℝ} (hε : 0 < ε) :
    ∃ n m : ℕ, 0 < n ∧ n < m ∧ |dirx (spoke n m) - t| < ε := by
  set g : ℝ → ℝ := fun r => (r ^ 2 - 1) / (r ^ 2 + 1) with hg
  have h1t : 0 < 1 - t := by linarith
  set r₀ : ℝ := Real.sqrt ((1 + t) / (1 - t)) with hr₀
  have hquot : 1 ≤ (1 + t) / (1 - t) := by
    rw [le_div_iff₀ h1t]; linarith
  have hr₀sq : r₀ ^ 2 = (1 + t) / (1 - t) := Real.sq_sqrt (by linarith)
  have hr₀one : 1 ≤ r₀ := by
    nlinarith [Real.sqrt_nonneg ((1 + t) / (1 - t)), hr₀sq, hquot]
  have hgr₀ : g r₀ = t := by
    rw [hg]
    simp only [hr₀sq]
    field_simp
    ring
  -- continuity gives a δ
  obtain ⟨δ, hδ, hcont⟩ := Metric.continuousAt_iff.mp (continuous_gcirc.continuousAt (x := r₀)) ε hε
  -- pick a large denominator
  obtain ⟨N, hN⟩ := exists_nat_gt (2 / δ)
  have hNpos : 0 < N := by
    by_contra hcon
    push_neg at hcon
    interval_cases N
    · simp at hN
      nlinarith [div_pos (by norm_num : (0:ℝ) < 2) hδ]
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hNpos
  set m : ℕ := ⌈(N : ℝ) * r₀⌉₊ + 1 with hm
  have hmlb : (N : ℝ) * r₀ < (m : ℝ) := by
    have := Nat.le_ceil ((N : ℝ) * r₀)
    push_cast [hm]
    linarith
  have hmub : (m : ℝ) < (N : ℝ) * r₀ + 2 := by
    have hnn : (0 : ℝ) ≤ (N : ℝ) * r₀ := by positivity
    have := Nat.ceil_lt_add_one hnn
    push_cast [hm]
    linarith
  have hNm : N < m := by
    have : (N : ℝ) < (m : ℝ) := by nlinarith [hmlb, hr₀one, hNR]
    exact_mod_cast this
  refine ⟨N, m, hNpos, hNm, ?_⟩
  -- the plotted abscissa of this spoke is g (m/N)
  have hspoke : dirx (spoke N m) = g ((m : ℝ) / (N : ℝ)) := by
    have hN0 : (N : ℝ) ≠ 0 := hNR.ne'
    simp only [spoke, dirx, hg]
    push_cast
    rw [div_pow]
    field_simp
  rw [hspoke, ← hgr₀]
  have hdist : dist ((m : ℝ) / (N : ℝ)) r₀ < δ := by
    rw [Real.dist_eq, abs_lt]
    constructor
    · have : r₀ < (m : ℝ) / (N : ℝ) := by
        rw [lt_div_iff₀ hNR]; linarith [hmlb]
      linarith
    · have h2 : (m : ℝ) / (N : ℝ) < r₀ + 2 / (N : ℝ) := by
        rw [div_lt_iff₀ hNR]
        have : (2 : ℝ) / (N : ℝ) * (N : ℝ) = 2 := by field_simp
        nlinarith [hmub]
      have h3 : (2 : ℝ) / (N : ℝ) < δ := by
        rw [div_lt_iff₀ hNR]
        rw [div_lt_iff₀ hδ] at hN
        linarith [hN]
      linarith
  simpa [Real.dist_eq] using hcont hdist

end BerggrenStars