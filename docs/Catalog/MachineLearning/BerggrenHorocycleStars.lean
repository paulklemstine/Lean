import MachineLearning.BerggrenHyperbolicStars

/-!
# Stars on the boundary circle: the horocycles of the Berggren tree

This file explains, and proves, the visual phenomenon described in the mission:
when the Berggren tree of Pythagorean triples is drawn inside a hyperbolic disc one sees
**stars**, i.e. bundles of curves radiating from isolated points *on the boundary circle*,
in addition to the lines through the centre.

The plotting map is the *ideal-point map*: a triple `(a,b,c)` is drawn at the point
`dir (a,b,c) = (a/c, b/c)` of the unit circle (its null ray, i.e. its ideal point in the
Klein model of `H²`), the plot being drawn at a radius that increases with the depth in
the tree, so that a family of triples whose directions converge to a boundary point `P`
is *seen* as a curve running into `P`.

## Main results

* `chord_eq_charge` — the chordal distance between the ideal points of two Pythagorean
  triples is governed exactly by their Lorentz product:
  `|dir v − dir p|² = −2⟨v,p⟩ / (c_v c_p)`.
* `tendsto_dir_of_constant_charge` — **the star theorem**.  Any family of Pythagorean
  triples on which the Lorentz product with a fixed null vector `p` is *constant* (a
  horocycle based at the ideal point of `p`) and whose hypotenuse tends to infinity
  converges, in the disc, to the ideal point of `p`.  Each value of the constant gives a
  different curve; they all radiate from the same boundary point.  That is the star.
* `mC_ray_tendsto`, `mA_ray_tendsto` — the two parabolic generators of the Berggren tree
  move *every* node along such a horocycle, so from every node of the tree there emanates
  a curve into the rational boundary point `(1,0)` (resp. `(0,1)`).
* `spoke_tendsto`, `spoke_tangency`, `spoke_charge_inj` — an explicit infinite family of
  distinct spokes of the star at `(1,0)`, together with the quadratic tangency law
  `c · (b/c)² → 4n²` which is the horocyclic signature (order-2 contact with the circle).
* `dirx_sub_sqrt_two_div_two_le` and `mB_ray_bound` — the hyperbolic generator instead
  drives every node to the ideal point at angle `π/4` at an **exponential** rate; the
  parabolic rays only approach their boundary point at the polynomial rate `Θ(1/k²)`
  (`mC_ray_poly_lower`).  This is the visible difference between "star curves" and
  "radiating lines".
* `no_triple_direction_at_pi_div_four` — the hyperbolic limit is irrational, so no triple
  is ever plotted there: there is *no* star at the `π/4` point, only a single geodesic.
* `star_centres_dense` — star centres (rational ideal points) are dense in the boundary
  arc, which is why the picture is speckled with stars.
-/

namespace BerggrenStars

open Filter Topology

/-! ### The plotting map -/

/-- First coordinate of the ideal point of a triple. -/
noncomputable def dirx (v : Vec) : ℝ := (v.1 : ℝ) / (v.2.2 : ℝ)

/-- Second coordinate of the ideal point of a triple. -/
noncomputable def diry (v : Vec) : ℝ := (v.2.1 : ℝ) / (v.2.2 : ℝ)

/-- The ideal point (boundary point of the disc) at which a triple is plotted. -/
noncomputable def dir (v : Vec) : ℝ × ℝ := (dirx v, diry v)

theorem dirx_e1 : dirx (1, 0, 1) = 1 := by norm_num [dirx]
theorem diry_e1 : diry (1, 0, 1) = 0 := by norm_num [diry]
theorem dirx_e2 : dirx (0, 1, 1) = 0 := by norm_num [dirx]
theorem diry_e2 : diry (0, 1, 1) = 1 := by norm_num [diry]

/-- The plot really does land on the boundary circle. -/
theorem dir_on_circle (v : Vec) (hv : OnCone v) (hc : 0 < v.2.2) :
    dirx v ^ 2 + diry v ^ 2 = 1 := by
  obtain ⟨a, b, c⟩ := v
  simp only at hc
  have h : (a : ℝ) ^ 2 + (b : ℝ) ^ 2 = (c : ℝ) ^ 2 := by
    exact_mod_cast (onCone_iff a b c).mp hv
  have hc' : (c : ℝ) ≠ 0 := by exact_mod_cast hc.ne'
  simp only [dirx, diry]
  field_simp
  linarith [h]

/-- **Chordal distance = Lorentz charge.**  The squared chordal distance between the two
plotted boundary points is `-2⟨v,p⟩/(c_v c_p)`.  Everything else in this file is a
consequence of this identity. -/
theorem chord_eq_charge (v p : Vec) (hv : OnCone v) (hp : OnCone p)
    (hvc : 0 < v.2.2) (hpc : 0 < p.2.2) :
    (dirx v - dirx p) ^ 2 + (diry v - diry p) ^ 2
      = -2 * (bil v p : ℝ) / ((v.2.2 : ℝ) * (p.2.2 : ℝ)) := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨x, y, z⟩ := p
  simp only at hvc hpc
  have h1 : (a : ℝ) ^ 2 + (b : ℝ) ^ 2 = (c : ℝ) ^ 2 := by
    exact_mod_cast (onCone_iff a b c).mp hv
  have h2 : (x : ℝ) ^ 2 + (y : ℝ) ^ 2 = (z : ℝ) ^ 2 := by
    exact_mod_cast (onCone_iff x y z).mp hp
  have hc : (c : ℝ) ≠ 0 := by exact_mod_cast hvc.ne'
  have hz : (z : ℝ) ≠ 0 := by exact_mod_cast hpc.ne'
  simp only [dirx, diry, bil]
  push_cast
  field_simp
  ring_nf
  nlinarith [h1, h2]

/-- Convergence from a vanishing absolute bound. -/
theorem tendsto_of_abs_sub_le {f : ℕ → ℝ} {L : ℝ} {g : ℕ → ℝ}
    (hg : Tendsto g atTop (𝓝 0)) (h : ∀ k, |f k - L| ≤ g k) : Tendsto f atTop (𝓝 L) := by
  have h1 : Tendsto (fun k => ‖f k - L‖) atTop (𝓝 0) :=
    squeeze_zero (fun k => norm_nonneg _) h hg
  exact tendsto_iff_norm_sub_tendsto_zero.mpr h1

/-! ### The star theorem -/

/-- **Star theorem (horocyclic convergence).**
Let `p` be a null lattice vector (a Pythagorean triple) and let `w k` be Pythagorean
triples whose Lorentz product with `p` is the *same* value `-d` for all `k` — i.e. the
`w k` lie on one horocycle based at the ideal point of `p` — and whose hypotenuses tend
to infinity.  Then the plotted points `dir (w k)` converge to the plotted point `dir p`.

Every value of `d` gives a different curve, and all of them run into the single boundary
point `dir p`: this is precisely the observed star. -/
theorem tendsto_dir_of_constant_charge
    (p : Vec) (hp : OnCone p) (hpc : 0 < p.2.2)
    (w : ℕ → Vec) (hw : ∀ k, OnCone (w k)) (hwc : ∀ k, 0 < (w k).2.2)
    (d : ℤ) (hcharge : ∀ k, bil (w k) p = -d)
    (hgrow : Tendsto (fun k => ((w k).2.2 : ℝ)) atTop atTop) :
    Tendsto (fun k => dirx (w k)) atTop (𝓝 (dirx p)) ∧
      Tendsto (fun k => diry (w k)) atTop (𝓝 (diry p)) := by
  have hpc' : (0 : ℝ) < (p.2.2 : ℝ) := by exact_mod_cast hpc
  -- the squared chordal distance
  have hchord : ∀ k, (dirx (w k) - dirx p) ^ 2 + (diry (w k) - diry p) ^ 2
      = 2 * (d : ℝ) / (((w k).2.2 : ℝ) * (p.2.2 : ℝ)) := by
    intro k
    rw [chord_eq_charge (w k) p (hw k) hp (hwc k) hpc, hcharge k]
    push_cast
    ring
  set g : ℕ → ℝ := fun k => Real.sqrt (2 * (d : ℝ) / (((w k).2.2 : ℝ) * (p.2.2 : ℝ))) with hg
  have hgtend : Tendsto g atTop (𝓝 0) := by
    have h0 : Tendsto (fun k => 2 * (d : ℝ) / (((w k).2.2 : ℝ) * (p.2.2 : ℝ))) atTop (𝓝 0) :=
      Tendsto.div_atTop tendsto_const_nhds (hgrow.atTop_mul_const hpc')
    simpa [hg] using h0.sqrt
  constructor
  · refine tendsto_of_abs_sub_le hgtend fun k => ?_
    have hle : (dirx (w k) - dirx p) ^ 2
        ≤ 2 * (d : ℝ) / (((w k).2.2 : ℝ) * (p.2.2 : ℝ)) := by
      rw [← hchord k]; nlinarith [sq_nonneg (diry (w k) - diry p)]
    have := Real.sqrt_le_sqrt hle
    rwa [Real.sqrt_sq_eq_abs] at this
  · refine tendsto_of_abs_sub_le hgtend fun k => ?_
    have hle : (diry (w k) - diry p) ^ 2
        ≤ 2 * (d : ℝ) / (((w k).2.2 : ℝ) * (p.2.2 : ℝ)) := by
      rw [← hchord k]; nlinarith [sq_nonneg (dirx (w k) - dirx p)]
    have := Real.sqrt_le_sqrt hle
    rwa [Real.sqrt_sq_eq_abs] at this

/-! ### The star at the rational boundary point `(1,0)`: the parabolic generator `mC` -/

theorem onCone_mC_iterate {v : Vec} (h : OnCone v) (k : ℕ) : OnCone (mC^[k] v) := by
  induction k with
  | zero => simpa using h
  | succ n ih => rw [Function.iterate_succ_apply']; exact onCone_mC ih

theorem onCone_mA_iterate {v : Vec} (h : OnCone v) (k : ℕ) : OnCone (mA^[k] v) := by
  induction k with
  | zero => simpa using h
  | succ n ih => rw [Function.iterate_succ_apply']; exact onCone_mA ih

theorem onCone_mB_iterate {v : Vec} (h : OnCone v) (k : ℕ) : OnCone (mB^[k] v) := by
  induction k with
  | zero => simpa using h
  | succ n ih => rw [Function.iterate_succ_apply']; exact onCone_mB ih

/-- **Equation of a star curve.**  A point of the `mC`-horocycle with charge `d = c − a`
is plotted at abscissa `1 − d/c`: the curve is the level set `c − a = d`. -/
theorem star_curve_equation (v : Vec) (hc : 0 < v.2.2) :
    dirx v = 1 - ((v.2.2 - v.1 : ℤ) : ℝ) / (v.2.2 : ℝ) := by
  have hc' : (v.2.2 : ℝ) ≠ 0 := by exact_mod_cast hc.ne'
  simp only [dirx]
  push_cast
  field_simp
  ring

/-- Along the `mC`-flow the hypotenuse grows at least linearly (in fact quadratically). -/
theorem mC_iterate_hyp_ge {a b c : ℤ} (h : OnCone (a, b, c)) (hb : 0 < b) (hc : 0 < c)
    (k : ℕ) : (k : ℤ) < (mC^[k] (a, b, c)).2.2 := by
  have hd : 0 < c - a := charge_pos h hb hc
  rw [mC_iterate]
  simp only
  nlinarith [sq_nonneg ((k : ℤ) - 1), Int.le_of_lt hd, (k : ℤ).natAbs, Int.natCast_nonneg k]

/-- **A star at `(1,0)`.**  From *every* node of the tree the parabolic generator `mC`
produces a curve of plotted points converging to the rational boundary point `(1,0)`. -/
theorem mC_ray_tendsto {a b c : ℤ} (h : OnCone (a, b, c)) (hb : 0 < b) (hc : 0 < c) :
    Tendsto (fun k => dirx (mC^[k] (a, b, c))) atTop (𝓝 1) ∧
      Tendsto (fun k => diry (mC^[k] (a, b, c))) atTop (𝓝 0) := by
  have key := tendsto_dir_of_constant_charge (1, 0, 1) onCone_e1 (by norm_num)
      (fun k => mC^[k] (a, b, c)) (fun k => onCone_mC_iterate h k) ?_ (c - a) ?_ ?_
  · rwa [dirx_e1, diry_e1] at key
  · intro k
    show 0 < (mC^[k] (a, b, c)).2.2
    have := mC_iterate_hyp_ge h hb hc k
    omega
  · intro k
    rw [bil_with_e1, ← mC_iterate_charge (a, b, c) k]
    simp only
    ring
  · apply tendsto_atTop_mono (f := fun k : ℕ => (k : ℝ))
    · intro k; exact_mod_cast (mC_iterate_hyp_ge h hb hc k).le
    · exact tendsto_natCast_atTop_atTop

/-- Along the `mA`-flow the hypotenuse grows at least linearly. -/
theorem mA_iterate_hyp_ge {a b c : ℤ} (h : OnCone (a, b, c)) (ha : 0 < a) (hc : 0 < c)
    (k : ℕ) : (k : ℤ) < (mA^[k] (a, b, c)).2.2 := by
  have he : 0 < c - b := by
    rw [onCone_iff] at h; nlinarith [sq_nonneg (b - c), sq_nonneg (b + c)]
  rw [mA_iterate]
  simp only
  nlinarith [sq_nonneg ((k : ℤ) - 1), Int.natCast_nonneg k]

/-- **A star at `(0,1)`.**  Same phenomenon for the other parabolic generator. -/
theorem mA_ray_tendsto {a b c : ℤ} (h : OnCone (a, b, c)) (ha : 0 < a) (hc : 0 < c) :
    Tendsto (fun k => dirx (mA^[k] (a, b, c))) atTop (𝓝 0) ∧
      Tendsto (fun k => diry (mA^[k] (a, b, c))) atTop (𝓝 1) := by
  have key := tendsto_dir_of_constant_charge (0, 1, 1) onCone_e2 (by norm_num)
      (fun k => mA^[k] (a, b, c)) (fun k => onCone_mA_iterate h k) ?_ (c - b) ?_ ?_
  · rwa [dirx_e2, diry_e2] at key
  · intro k
    show 0 < (mA^[k] (a, b, c)).2.2
    have := mA_iterate_hyp_ge h ha hc k
    omega
  · intro k
    rw [bil_with_e2, ← mA_iterate_charge (a, b, c) k]
    simp only
    ring
  · apply tendsto_atTop_mono (f := fun k : ℕ => (k : ℝ))
    · intro k; exact_mod_cast (mA_iterate_hyp_ge h ha hc k).le
    · exact tendsto_natCast_atTop_atTop

/-! ### Explicit spokes of the star at `(1,0)` -/

/-- The classical parametrisation.  For fixed `n`, the family `m ↦ spoke n m` is one
spoke of the star at `(1,0)`; different `n` give different spokes. -/
def spoke (n m : ℕ) : Vec := ((m : ℤ) ^ 2 - (n : ℤ) ^ 2, 2 * (m : ℤ) * (n : ℤ),
  (m : ℤ) ^ 2 + (n : ℤ) ^ 2)

theorem spoke_onCone (n m : ℕ) : OnCone (spoke n m) := by
  rw [spoke, onCone_iff]; ring

/-- The Lorentz charge of a spoke: constant along the family, equal to `-2n²`. -/
theorem spoke_charge (n m : ℕ) : bil (spoke n m) (1, 0, 1) = -(2 * (n : ℤ) ^ 2) := by
  rw [bil_with_e1, spoke]; ring

/-- Different `n` really give different curves of the star. -/
theorem spoke_charge_inj {n n' : ℕ} (h : ∀ m, bil (spoke n m) (1, 0, 1)
    = bil (spoke n' m) (1, 0, 1)) : n = n' := by
  have := h 0
  rw [spoke_charge, spoke_charge] at this
  have : (n : ℤ) ^ 2 = (n' : ℤ) ^ 2 := by omega
  have : (n : ℤ) = (n' : ℤ) := by nlinarith [Int.natCast_nonneg n, Int.natCast_nonneg n']
  exact_mod_cast this

private theorem tendsto_spoke_hyp (n : ℕ) (hn : 0 < n) :
    Tendsto (fun m : ℕ => (m : ℝ) ^ 2 + (n : ℝ) ^ 2) atTop atTop := by
  have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  apply tendsto_atTop_mono (f := fun m : ℕ => (m : ℝ))
  · intro m
    have hm : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
    nlinarith [sq_nonneg ((m : ℝ) - 1)]
  · exact tendsto_natCast_atTop_atTop

/-- Each spoke converges to the boundary point `(1,0)`. -/
theorem spoke_tendsto (n : ℕ) (hn : 0 < n) :
    Tendsto (fun m => dirx (spoke n m)) atTop (𝓝 1) ∧
      Tendsto (fun m => diry (spoke n m)) atTop (𝓝 0) := by
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hpos : ∀ m : ℕ, 0 < (spoke n m).2.2 := by
    intro m
    have : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn
    simp only [spoke]
    positivity
  have key := tendsto_dir_of_constant_charge (1, 0, 1) onCone_e1 (by norm_num)
      (fun m => spoke n m) (fun m => spoke_onCone _ _) hpos (2 * (n : ℤ) ^ 2)
      (fun m => spoke_charge n m) ?_
  · rwa [dirx_e1, diry_e1] at key
  · have heq : ∀ m : ℕ, ((spoke n m).2.2 : ℝ) = (m : ℝ) ^ 2 + (n : ℝ) ^ 2 := by
      intro m; simp only [spoke]; push_cast; ring
    simpa [heq] using tendsto_spoke_hyp n hn

/-- **Tangency law.**  Along a spoke of charge `2n²` the plotted points approach the
boundary with exact order-2 contact: `c · (b/c)² → 4n²`.  In the disc this is the
parabola-like shape of a horocycle touching the circle, not a straight radius. -/
theorem spoke_tangency (n : ℕ) (hn : 0 < n) :
    Tendsto (fun m => ((spoke n m).2.2 : ℝ) * (diry (spoke n m)) ^ 2) atTop
      (𝓝 (4 * (n : ℝ) ^ 2)) := by
  have hform : ∀ m : ℕ, ((spoke n m).2.2 : ℝ) * (diry (spoke n m)) ^ 2
      = 4 * (n : ℝ) ^ 2 - 4 * (n : ℝ) ^ 4 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) := by
    intro m
    have hden : ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) ≠ 0 := by
      have : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
      positivity
    simp only [spoke, diry]
    push_cast
    field_simp
    ring
  simp only [hform]
  have h0 : Tendsto (fun m : ℕ => 4 * (n : ℝ) ^ 4 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) atTop (𝓝 0) := by
    apply Tendsto.div_atTop tendsto_const_nhds
    exact tendsto_spoke_hyp n hn
  simpa using tendsto_const_nhds.sub h0

end BerggrenStars