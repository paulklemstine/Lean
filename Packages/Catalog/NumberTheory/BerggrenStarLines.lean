import Catalog.Geometry.HyperbolicBerggrenGeodesics

/-!
# The star lines of the Berggren tree on the boundary of the Poincaré half-plane

Plotting the Berggren tree of primitive Pythagorean triples in the upper half-plane
through the Euclid embedding `z(m,n) = (n + i)/m` produces a striking picture:
besides the hyperbolic circles `d(i, ·) = R`, one sees **straight lines radiating from
two points of the ideal boundary**, namely from `0` and from `1`, and these lines are
organised into two *stars*.

This file explains the picture exactly, and quantifies it.

## Main results

* `armL_closed`, `armR_closed` : the two *parabolic* Berggren moves have exact closed
  forms along their orbits.  Writing `u = m - n`, the `B₁`-orbit of a seed is the pure
  translation `(m, n) ↦ (m + k u, n + k u)`, and the `B₃`-orbit is `(m, n) ↦ (m + 2kn, n)`.
  The quantities `u = m - n` and `n` are the corresponding conserved charges.

* `hpoint_star_one`, `hpoint_star_zero` : the node `z(m,n)` lies on the Euclidean
  straight line through the boundary point `1` of Euclidean slope `-1/u` (`u = m-n`),
  and on the Euclidean straight line through the boundary point `0` of slope `1/n`.
  Consequently (`armL_on_star_line`, `armR_on_star_line`) a whole `B₁`-arm lies on **one**
  line through `1` and a whole `B₃`-arm lies on **one** line through `0`: these are the
  radiating lines of the picture.

* `star_line_isGLB_one`, `star_line_isGLB_zero` : such a line is a **hypercycle**: every
  point of it is at hyperbolic distance exactly `arsinh u` (resp. `arsinh n`) from the
  geodesic joining the ideal point `1` (resp. `0`) to `∞`.  The distance is *constant
  along the arm*, which is the geometric meaning of the conserved charge.

* `star_one_param_iff`, `star_zero_param_iff` : **quantisation of the two stars.**  The
  star at the boundary point `1` consists exactly of the lines with *odd* parameter
  `u = 1, 3, 5, …`, whereas the star at `0` contains the line of *every* parameter
  `n = 1, 2, 3, …`.  The two stars are therefore not isometric pictures.

* `isSeed_iff_grid` : in the coordinates `(u, n) = (m - n, n)` the set of Berggren nodes
  is exactly the coprime grid `{u odd, gcd(u,n) = 1}`; each node is the intersection of
  one line of the `1`-star with one line of the `0`-star.

* `armL_horocyclic`, `armL_tendsto_one` : along a `B₁`-arm the exact horospherical
  quantity `|z-1|²/Im z` equals `(u²+1)/(m + k u)` and tends to `0`: the arm converges to
  the ideal point `1` *tangentially*, at the parabolic rate `Θ(1/k)`.

* `armL_dist_log_bounds` : the hyperbolic speed along a star arm is **logarithmic**:
  `log k - log 2 ≤ d(i, z_k) ≤ log k + log (n + 2u) + (3/2) log 2`.  (Contrast with the
  `B₂`-spine, whose distance grows linearly; see `Novelty.HyperbolicBerggrenSilverGrowth`.)

All statements build on the catalog file `Geometry.HyperbolicBerggrenGeodesics`
(`IsSeed`, `seedL`, `seedM`, `seedR`, `hpoint`, `cosh_dist_hpoint_I`).
-/

namespace BerggrenStarLines

open Real HyperbolicBerggrenGeodesics UpperHalfPlane Filter Topology

noncomputable section

/-! ## Part 1. Closed forms for the two parabolic arms -/

/-- **The `B₁`-arm is a pure translation.**  Writing a seed as `(n + u, n)` with
`u = m - n`, the `k`-th iterate of the Berggren move `B₁` is `(n + (k+1)u, n + k u)`:
both coordinates advance by the *conserved charge* `u`. -/
theorem armL_closed (n u : ℕ) : ∀ k : ℕ,
    seedL^[k] (n + u, n) = (n + (k + 1) * u, n + k * u) := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply', ih]
      have key : 2 * (n + (k + 1) * u) = (n + (k + 1 + 1) * u) + (n + k * u) := by ring
      simp only [seedL, Prod.mk.injEq, and_true]
      rw [key, Nat.add_sub_cancel]

/-- **The `B₃`-arm is a pure shear.**  The `k`-th iterate of the Berggren move `B₃`
is `(m + 2kn, n)`: the second coordinate `n` is the conserved charge. -/
theorem armR_closed (m n : ℕ) : ∀ k : ℕ, seedR^[k] (m, n) = (m + 2 * k * n, n) := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply', ih]
      simp only [seedR, Prod.mk.injEq, and_true]
      ring

/-- Every point of a `B₁`-arm is again a Euclid seed. -/
theorem armL_isSeed {m n : ℕ} (h : IsSeed m n) (k : ℕ) :
    IsSeed (seedL^[k] (m, n)).1 (seedL^[k] (m, n)).2 := by
  induction k with
  | zero => simpa using h
  | succ k ih =>
      rw [Function.iterate_succ_apply']
      have := seedL_isSeed (m := (seedL^[k] (m, n)).1) (n := (seedL^[k] (m, n)).2) ih
      simpa using this

/-- Every point of a `B₃`-arm is again a Euclid seed. -/
theorem armR_isSeed {m n : ℕ} (h : IsSeed m n) (k : ℕ) :
    IsSeed (seedR^[k] (m, n)).1 (seedR^[k] (m, n)).2 := by
  induction k with
  | zero => simpa using h
  | succ k ih =>
      rw [Function.iterate_succ_apply']
      have := seedR_isSeed (m := (seedR^[k] (m, n)).1) (n := (seedR^[k] (m, n)).2) ih
      simpa using this

/-! ## Part 2. The two families of straight lines -/

/-- **The `1`-star line through a node.**  The node `z(m,n)` lies on the Euclidean
straight line through the ideal point `1` determined by the parameter `u = m - n`:
`1 - Re z = u · Im z`. -/
theorem hpoint_star_one (m n : ℕ) (hm : 0 < m) :
    1 - (hpoint m n hm).re = ((m : ℝ) - n) * (hpoint m n hm).im := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  simp only [hpoint_re, hpoint_im]
  field_simp

/-- **The `0`-star line through a node.**  The node `z(m,n)` lies on the Euclidean
straight line through the ideal point `0` determined by the parameter `n`:
`Re z = n · Im z`. -/
theorem hpoint_star_zero (m n : ℕ) (hm : 0 < m) :
    (hpoint m n hm).re = (n : ℝ) * (hpoint m n hm).im := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  simp only [hpoint_re, hpoint_im]
  field_simp

/-- **A whole `B₁`-arm lies on a single line of the `1`-star**: the parameter
`u = m - n` does not depend on `k`. -/
theorem armL_on_star_line (n u k : ℕ) (h : 0 < n + (k + 1) * u) :
    1 - (hpoint (n + (k + 1) * u) (n + k * u) h).re
      = (u : ℝ) * (hpoint (n + (k + 1) * u) (n + k * u) h).im := by
  have := hpoint_star_one (n + (k + 1) * u) (n + k * u) h
  rw [this]
  congr 1
  push_cast
  ring

/-- **A whole `B₃`-arm lies on a single line of the `0`-star**: the parameter `n`
does not depend on `k`. -/
theorem armR_on_star_line (m n k : ℕ) (h : 0 < m + 2 * k * n) :
    (hpoint (m + 2 * k * n) n h).re = (n : ℝ) * (hpoint (m + 2 * k * n) n h).im :=
  hpoint_star_zero _ _ h

/-! ## Part 3. The star lines are hypercycles -/

/-- The vertical geodesic through the ideal point `x`: the points `x + i s`, `s > 0`. -/
def vpt (x s : ℝ) (hs : 0 < s) : ℍ := ⟨⟨x, s⟩, hs⟩

@[simp] theorem vpt_re (x s : ℝ) (hs : 0 < s) : (vpt x s hs).re = x := rfl
@[simp] theorem vpt_im (x s : ℝ) (hs : 0 < s) : (vpt x s hs).im = s := rfl

/-- **Lower bound: a point of the line `x - Re z = u · Im z` is at hyperbolic distance at
least `arcosh √(1+u²)` from the vertical geodesic through `x`.** -/
theorem cosh_dist_vertical_ge {x u : ℝ} {z : ℍ} (hz : x - z.re = u * z.im)
    {s : ℝ} (hs : 0 < s) :
    Real.sqrt (1 + u ^ 2) ≤ Real.cosh (dist z (vpt x s hs)) := by
  have hy : 0 < z.im := z.im_pos
  have hsq : Real.sqrt (1 + u ^ 2) ^ 2 = 1 + u ^ 2 :=
    Real.sq_sqrt (by positivity)
  have hsnn : 0 ≤ Real.sqrt (1 + u ^ 2) := Real.sqrt_nonneg _
  rw [UpperHalfPlane.cosh_dist']
  simp only [vpt_re, vpt_im]
  rw [le_div_iff₀ (by positivity)]
  have hre : (z.re - x) ^ 2 = u ^ 2 * z.im ^ 2 := by
    have : z.re - x = -(u * z.im) := by linarith
    rw [this]; ring
  have key : 0 ≤ (Real.sqrt (1 + u ^ 2) * z.im - s) ^ 2 := sq_nonneg _
  nlinarith [key, hsq, hy, hs]

/-- **Sharpness: the bound is attained**, at the foot of the perpendicular
`s = Im z · √(1+u²)`.  Hence the line `x - Re z = u · Im z` is exactly the hypercycle at
distance `arcosh √(1+u²) = arsinh |u|` from the geodesic `(x, ∞)`. -/
theorem cosh_dist_vertical_eq {x u : ℝ} {z : ℍ} (hz : x - z.re = u * z.im) :
    Real.cosh (dist z (vpt x (z.im * Real.sqrt (1 + u ^ 2))
      (by have := z.im_pos; positivity))) = Real.sqrt (1 + u ^ 2) := by
  have hy : 0 < z.im := z.im_pos
  have hsq : Real.sqrt (1 + u ^ 2) ^ 2 = 1 + u ^ 2 := Real.sq_sqrt (by positivity)
  have hspos : 0 < Real.sqrt (1 + u ^ 2) := Real.sqrt_pos.mpr (by positivity)
  rw [UpperHalfPlane.cosh_dist']
  simp only [vpt_re, vpt_im]
  have hre : (z.re - x) ^ 2 = u ^ 2 * z.im ^ 2 := by
    have : z.re - x = -(u * z.im) := by linarith
    rw [this]; ring
  rw [hre]
  field_simp
  nlinarith [hsq, hy, hspos]

/-- **The `1`-star lines are hypercycles.**  For a node `z(m,n)` the infimum of
`cosh d(z, ·)` over the geodesic from `1` to `∞` is exactly `√(1 + (m-n)²)`, attained.
In particular this distance is a *conserved charge* along a `B₁`-arm. -/
theorem star_line_isGLB_one (m n : ℕ) (hm : 0 < m) :
    IsLeast {t : ℝ | ∃ (s : ℝ) (hs : 0 < s),
        t = Real.cosh (dist (hpoint m n hm) (vpt 1 s hs))}
      (Real.sqrt (1 + ((m : ℝ) - n) ^ 2)) := by
  have hz : (1 : ℝ) - (hpoint m n hm).re = ((m : ℝ) - n) * (hpoint m n hm).im :=
    hpoint_star_one m n hm
  constructor
  · refine ⟨(hpoint m n hm).im * Real.sqrt (1 + ((m : ℝ) - n) ^ 2), ?_, ?_⟩
    · have := (hpoint m n hm).im_pos
      positivity
    · exact (cosh_dist_vertical_eq hz).symm
  · rintro t ⟨s, hs, rfl⟩
    exact cosh_dist_vertical_ge hz hs

/-- **The `0`-star lines are hypercycles.**  For a node `z(m,n)` the infimum of
`cosh d(z, ·)` over the geodesic from `0` to `∞` is exactly `√(1 + n²)`, attained; it is a
conserved charge along a `B₃`-arm. -/
theorem star_line_isGLB_zero (m n : ℕ) (hm : 0 < m) :
    IsLeast {t : ℝ | ∃ (s : ℝ) (hs : 0 < s),
        t = Real.cosh (dist (hpoint m n hm) (vpt 0 s hs))}
      (Real.sqrt (1 + (n : ℝ) ^ 2)) := by
  have hz : (0 : ℝ) - (hpoint m n hm).re = (-(n : ℝ)) * (hpoint m n hm).im := by
    have := hpoint_star_zero m n hm
    rw [this]; ring
  have hsq : (-(n : ℝ)) ^ 2 = (n : ℝ) ^ 2 := by ring
  constructor
  · refine ⟨(hpoint m n hm).im * Real.sqrt (1 + (-(n : ℝ)) ^ 2), ?_, ?_⟩
    · have := (hpoint m n hm).im_pos
      positivity
    · rw [← hsq]
      exact (cosh_dist_vertical_eq hz).symm
  · rintro t ⟨s, hs, rfl⟩
    rw [← hsq]
    exact cosh_dist_vertical_ge hz hs

/-! ## Part 4. Quantisation of the two stars -/

/-- For a Euclid seed the `1`-star parameter `u = m - n` is **odd**. -/
theorem seed_sub_odd {m n : ℕ} (h : IsSeed m n) : (m - n) % 2 = 1 := by
  have := h.parity
  have := h.lt
  omega

/-- **The coprime-grid description of the Berggren nodes.**  In the coordinates
`(u, n) = (m - n, n)` — the pair of star parameters — the seeds are exactly the pairs
with `u` odd and `gcd(u, n) = 1`.  So the node set is the intersection pattern of the two
stars. -/
theorem isSeed_iff_grid (n u : ℕ) :
    IsSeed (n + u) n ↔ (0 < n ∧ 0 < u ∧ u % 2 = 1 ∧ Nat.Coprime u n) := by
  have hgcd : Nat.gcd (n + u) n = Nat.gcd u n := Nat.gcd_self_add_left n u
  constructor
  · intro h
    refine ⟨h.pos, by have := h.lt; omega, ?_, ?_⟩
    · have := h.parity; omega
    · have hc : Nat.gcd (n + u) n = 1 := h.cop
      rw [hgcd] at hc
      exact hc
  · rintro ⟨hn, hu, hpar, hcop⟩
    refine ⟨hn, by omega, ?_, by omega⟩
    show Nat.gcd (n + u) n = 1
    rw [hgcd]; exact hcop

/-- **Quantisation of the star at the ideal point `1`:** a line of parameter `u`
carries a Berggren node **iff `u` is odd** (and positive).  The `1`-star has arms only at
the odd hypercycle distances `arsinh 1, arsinh 3, arsinh 5, …`. -/
theorem star_one_param_iff (u : ℕ) :
    (∃ m n : ℕ, IsSeed m n ∧ m - n = u) ↔ (0 < u ∧ u % 2 = 1) := by
  constructor
  · rintro ⟨m, n, h, rfl⟩
    exact ⟨by have := h.lt; omega, seed_sub_odd h⟩
  · rintro ⟨hu, hpar⟩
    refine ⟨1 + u, 1, ?_, by omega⟩
    rw [show (1 : ℕ) + u = 1 + u from rfl]
    exact (isSeed_iff_grid 1 u).mpr ⟨one_pos, hu, hpar, by simp [Nat.Coprime]⟩

/-- **No quantisation at the ideal point `0`:** every positive parameter `n` occurs.
The `0`-star has an arm at *every* hypercycle distance `arsinh n`, `n = 1, 2, 3, …`. -/
theorem star_zero_param_iff (n : ℕ) :
    (∃ m : ℕ, IsSeed m n) ↔ 0 < n := by
  constructor
  · rintro ⟨m, h⟩; exact h.pos
  · intro hn
    refine ⟨n + 1, ?_⟩
    exact (isSeed_iff_grid n 1).mpr ⟨hn, one_pos, by norm_num, by simp [Nat.Coprime]⟩

/-- **The two stars are genuinely different pictures**: the parameter `2` occurs in the
`0`-star but in no line of the `1`-star. -/
theorem stars_not_isometric :
    (∃ m : ℕ, IsSeed m 2) ∧ ¬ (∃ m n : ℕ, IsSeed m n ∧ m - n = 2) := by
  refine ⟨(star_zero_param_iff 2).mpr (by norm_num), ?_⟩
  intro h
  have := (star_one_param_iff 2).mp h
  omega

/-- Each line of either star carries **infinitely many** nodes: the arm is injective in
`k`.  (Stated through the strict growth of the first coordinate.) -/
theorem armL_strictMono {n u : ℕ} (hu : 0 < u) :
    StrictMono (fun k : ℕ => (seedL^[k] (n + u, n)).1) := by
  intro a b hab
  simp only [armL_closed]
  have : (a + 1) * u < (b + 1) * u :=
    mul_lt_mul_of_pos_right (by omega) hu
  omega

theorem armR_strictMono {m n : ℕ} (hn : 0 < n) :
    StrictMono (fun k : ℕ => (seedR^[k] (m, n)).1) := by
  intro a b hab
  simp only [armR_closed]
  have : 2 * a * n < 2 * b * n :=
    mul_lt_mul_of_pos_right (by omega) hn
  omega

/-! ## Part 5. Tangential convergence and logarithmic speed along a star arm -/

/-- The exact **horospherical coordinate** of a node at the ideal point `1`: the quantity
`|z-1|²/Im z`, whose sublevel sets are the horoballs at `1`, equals `((m-n)²+1)/m`. -/
theorem hpoint_horocyclic_one (m n : ℕ) (hm : 0 < m) :
    ((1 - (hpoint m n hm).re) ^ 2 + (hpoint m n hm).im ^ 2) / (hpoint m n hm).im
      = (((m : ℝ) - n) ^ 2 + 1) / (m : ℝ) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  simp only [hpoint_re, hpoint_im]
  field_simp

/-- The exact horospherical coordinate of a node at the ideal point `0`:
`|z|²/Im z = (n²+1)/m`. -/
theorem hpoint_horocyclic_zero (m n : ℕ) (hm : 0 < m) :
    (((hpoint m n hm).re) ^ 2 + (hpoint m n hm).im ^ 2) / (hpoint m n hm).im
      = ((n : ℝ) ^ 2 + 1) / (m : ℝ) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  simp only [hpoint_re, hpoint_im]
  field_simp

/-- **Exact horospherical rate along a `B₁`-arm.**  Along the arm the horospherical
coordinate at the ideal point `1` equals `(u²+1)/(n + (k+1)u)`: it decays like `1/k`, so
the arm enters *every* horoball at `1`.  The convergence to the boundary is tangential,
at the parabolic rate — this is the precise sense in which the arm is a ray of the star. -/
theorem armL_horocyclic (n u k : ℕ) (h : 0 < n + (k + 1) * u) :
    ((1 - (hpoint (n + (k + 1) * u) (n + k * u) h).re) ^ 2
        + (hpoint (n + (k + 1) * u) (n + k * u) h).im ^ 2)
        / (hpoint (n + (k + 1) * u) (n + k * u) h).im
      = ((u : ℝ) ^ 2 + 1) / ((n + (k + 1) * u : ℕ) : ℝ) := by
  rw [hpoint_horocyclic_one]
  congr 2
  push_cast
  ring

/-- **Exact horospherical rate along a `B₃`-arm** at the ideal point `0`:
`(n²+1)/(m + 2kn)`, again a `Θ(1/k)` parabolic decay. -/
theorem armR_horocyclic (m n k : ℕ) (h : 0 < m + 2 * k * n) :
    (((hpoint (m + 2 * k * n) n h).re) ^ 2 + (hpoint (m + 2 * k * n) n h).im ^ 2)
        / (hpoint (m + 2 * k * n) n h).im
      = ((n : ℝ) ^ 2 + 1) / ((m + 2 * k * n : ℕ) : ℝ) :=
  hpoint_horocyclic_zero _ _ h

/-- The first coordinates along a `B₁`-arm tend to infinity (for `u ≥ 1`). -/
theorem armL_fst_tendsto_atTop (n u : ℕ) (hu : 0 < u) :
    Tendsto (fun k : ℕ => ((n + (k + 1) * u : ℕ) : ℝ)) atTop atTop := by
  have hmono : ∀ k : ℕ, k ≤ n + (k + 1) * u := by
    intro k
    calc k ≤ (k + 1) * u := by
          have : k + 1 ≤ (k + 1) * u := Nat.le_mul_of_pos_right _ hu
          omega
      _ ≤ n + (k + 1) * u := Nat.le_add_left _ _
  have hnat : Tendsto (fun k : ℕ => n + (k + 1) * u) atTop atTop :=
    tendsto_atTop_mono hmono tendsto_id
  exact tendsto_natCast_atTop_atTop.comp hnat

/-- **The `B₁`-arm converges tangentially to the ideal point `1`.** -/
theorem armL_horocyclic_tendsto_zero (n u : ℕ) (hu : 0 < u)
    (h : ∀ k : ℕ, 0 < n + (k + 1) * u) :
    Tendsto (fun k : ℕ =>
        ((1 - (hpoint (n + (k + 1) * u) (n + k * u) (h k)).re) ^ 2
            + (hpoint (n + (k + 1) * u) (n + k * u) (h k)).im ^ 2)
          / (hpoint (n + (k + 1) * u) (n + k * u) (h k)).im) atTop (𝓝 0) := by
  have hEq : ∀ k : ℕ,
      ((1 - (hpoint (n + (k + 1) * u) (n + k * u) (h k)).re) ^ 2
          + (hpoint (n + (k + 1) * u) (n + k * u) (h k)).im ^ 2)
        / (hpoint (n + (k + 1) * u) (n + k * u) (h k)).im
        = ((u : ℝ) ^ 2 + 1) / ((n + (k + 1) * u : ℕ) : ℝ) := fun k => armL_horocyclic n u k (h k)
  simp only [hEq]
  exact Filter.Tendsto.div_atTop tendsto_const_nhds (armL_fst_tendsto_atTop n u hu)

/-- **The real parts along a `B₁`-arm converge to the ideal point `1`.** -/
theorem armL_tendsto_one (n u : ℕ) (hu : 0 < u) (h : ∀ k : ℕ, 0 < n + (k + 1) * u) :
    Tendsto (fun k : ℕ => (hpoint (n + (k + 1) * u) (n + k * u) (h k)).re) atTop (𝓝 1) := by
  have hEq : ∀ k : ℕ, (hpoint (n + (k + 1) * u) (n + k * u) (h k)).re
      = 1 - (u : ℝ) / ((n + (k + 1) * u : ℕ) : ℝ) := by
    intro k
    have hM : (0 : ℝ) < ((n + (k + 1) * u : ℕ) : ℝ) := by exact_mod_cast h k
    have hcast : ((n + k * u : ℕ) : ℝ) = ((n + (k + 1) * u : ℕ) : ℝ) - (u : ℝ) := by
      push_cast; ring
    simp only [hpoint_re, hcast]
    field_simp
  simp only [hEq]
  have h0 : Tendsto (fun k : ℕ => (u : ℝ) / ((n + (k + 1) * u : ℕ) : ℝ)) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds (armL_fst_tendsto_atTop n u hu)
  simpa using tendsto_const_nhds.sub h0

/-- **Logarithmic hyperbolic speed along a star arm.**  For `k ≥ 1` the hyperbolic
distance from the base point `i` to the `k`-th node of the `B₁`-arm through the seed
`(n+u, n)` satisfies `log k - log 2 ≤ d ≤ log k + log (n + 2u) + (3/2) log 2`.
The parabolic arms are therefore traversed at *logarithmic* speed, in sharp contrast with
the linear speed along the hyperbolic (`B₂`) spine. -/
theorem armL_dist_log_bounds (n u k : ℕ) (hn : 0 < n) (hu : 0 < u) (hk : 1 ≤ k)
    (h : 0 < n + (k + 1) * u) :
    Real.log k - Real.log 2
        ≤ dist (hpoint (n + (k + 1) * u) (n + k * u) h) UpperHalfPlane.I ∧
      dist (hpoint (n + (k + 1) * u) (n + k * u) h) UpperHalfPlane.I
        ≤ Real.log k + Real.log ((n : ℝ) + 2 * u) + (3 / 2) * Real.log 2 := by
  have hNpos : 0 < n + k * u := Nat.lt_of_lt_of_le hn (Nat.le_add_right _ _)
  have hNM : n + k * u < n + (k + 1) * u := by
    have : k * u < (k + 1) * u := by
      exact mul_lt_mul_of_pos_right (by omega) hu
    omega
  have hwin : |dist (hpoint (n + (k + 1) * u) (n + k * u) h) UpperHalfPlane.I
      - (1 / 2) * Real.log (((n + (k + 1) * u : ℕ) : ℝ) ^ 2 + ((n + k * u : ℕ) : ℝ) ^ 2)|
      ≤ Real.log 2 :=
    hyperbolic_dist_eq_half_log_hypotenuse hNpos hNM
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have huR : (1 : ℝ) ≤ (u : ℝ) := by exact_mod_cast hu
  have hnR : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hMR : ((n + (k + 1) * u : ℕ) : ℝ) = (n : ℝ) + ((k : ℝ) + 1) * u := by push_cast; ring
  have hNR : ((n + k * u : ℕ) : ℝ) = (n : ℝ) + (k : ℝ) * u := by push_cast; ring
  set M : ℝ := ((n + (k + 1) * u : ℕ) : ℝ) with hMdef
  set N : ℝ := ((n + k * u : ℕ) : ℝ) with hNdef
  have hMpos : 0 < M := by rw [hMR]; nlinarith
  have hNpos' : 0 < N := by rw [hNR]; nlinarith
  have hMge : (k : ℝ) ≤ M := by rw [hMR]; nlinarith
  have hMle : M ≤ (k : ℝ) * ((n : ℝ) + 2 * u) := by rw [hMR]; nlinarith
  have hNle : N ≤ M := by rw [hMR, hNR]; nlinarith
  have hc : (0 : ℝ) < M ^ 2 + N ^ 2 := by positivity
  have hlow : ((k : ℝ)) ^ 2 ≤ M ^ 2 + N ^ 2 := by nlinarith
  have hup : M ^ 2 + N ^ 2 ≤ 2 * (k : ℝ) ^ 2 * ((n : ℝ) + 2 * u) ^ 2 := by nlinarith
  have hlog_low : Real.log ((k : ℝ) ^ 2) ≤ Real.log (M ^ 2 + N ^ 2) :=
    Real.log_le_log (by positivity) hlow
  have hlog_up : Real.log (M ^ 2 + N ^ 2)
      ≤ Real.log (2 * (k : ℝ) ^ 2 * ((n : ℝ) + 2 * u) ^ 2) :=
    Real.log_le_log hc hup
  have e1 : Real.log ((k : ℝ) ^ 2) = 2 * Real.log k := by
    rw [Real.log_pow]; push_cast; ring
  have e2 : Real.log (2 * (k : ℝ) ^ 2 * ((n : ℝ) + 2 * u) ^ 2)
      = Real.log 2 + 2 * Real.log k + 2 * Real.log ((n : ℝ) + 2 * u) := by
    rw [Real.log_mul (by positivity) (by positivity), Real.log_mul (by norm_num) (by positivity),
      Real.log_pow, Real.log_pow]
    push_cast; ring
  rw [e1] at hlog_low
  rw [e2] at hlog_up
  rw [abs_le] at hwin
  exact ⟨by linarith [hwin.1], by linarith [hwin.2]⟩

end

end BerggrenStarLines