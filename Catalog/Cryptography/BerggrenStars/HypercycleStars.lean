import Mathlib

/-!
# The stars of the Berggren tree: hypercycle pencils in the Poincaré half-plane

This file explains, and proves exactly, the *visual* structure of the Berggren tree of
primitive Pythagorean triples embedded in the Poincaré upper half-plane `ℍ` by the Euclid
seed map

  `z(m, n) = (n + i) / m`,

namely the **families of straight lines that emanate from rational boundary points** and
which dominate any picture of the embedded tree.

## The phenomenon

Fix a boundary point `p/q ∈ ℚ ⊆ ∂ℍ` and an integer `k`. The seeds `(m, n)` with
`q * n - p * m = k` satisfy `Re z = p/q + (k/q) * Im z`, so they all lie on one Euclidean
half-line emanating from `p/q`. Such a Euclidean ray is *not* a geodesic: it is a
**hypercycle**, the curve of points at constant hyperbolic distance from the vertical
geodesic `(p/q, ∞)`. The main theorem `distVLine_hpoint` computes that distance exactly:

  `d_ℍ(z(m,n), geodesic at p/q) = arsinh (|q n - p m| / q)`.

So the picture is a superposition of *stars*: over each rational boundary point `p/q` sits
a discrete pencil of hypercycles indexed by `k ∈ ℤ`, at the quantized distances
`arsinh (|k| / q)`.

## Main results

* `isLeast_dist_vline`, `distVLine_eq` : for any `z ∈ ℍ` and any `a ∈ ℝ`, the distance from
  `z` to the complete geodesic `{Re = a}` is attained and equals `arsinh (|Re z - a| / Im z)`
  (a general half-plane fact, proved from `UpperHalfPlane.cosh_dist'`).
* `distVLine_hpoint` : the star formula above; `spoke_dist`, `costar_dist` : its two
  arithmetically meaningful specialisations, `arsinh n` at the boundary point `0` and
  `arsinh (m - n)` at the boundary point `1`.
* `charge_e1_eq`, `charge_e2_eq` : the two conserved *Lorentzian charges* of the Berggren
  action, `⟨v, e₁⟩ = -2n²` and `⟨v, e₂⟩ = -(m-n)²`, are exactly `-2 sinh²` and `-sinh²` of
  these two hyperbolic distances. The arithmetic invariants *are* geometric ones.
* `seedR_preserves_spoke`, `seedL_preserves_costar` : the Berggren move `B₃` slides a node
  along its `0`-hypercycle and `B₁` slides it along its `1`-hypercycle — each generator
  preserves one star exactly.
* `seedM_pell_flip`, `seedM_sinh_relation` : the third move `B₂` preserves no line of either
  star but negates the Pell form `m² - 2mn - n² = sinh²d₁ - 2 sinh²d₀`; this is the exact
  hyperbolic meaning of the Pell boundary layer.
* `spoke_tendsto_zero`, `costar_tendsto_one` : iterating `B₃` (resp. `B₁`) drives the node to
  the boundary point `0` (resp. `1`) *along* its hypercycle — the rays really do radiate out
  of the edge of the half-plane.
* `spoke_realized_iff` : an **exact census of the star**. The spoke index `n` occurs inside
  the hyperbolic ball `B(i, R)` if and only if `(n² + n + 1)/(n + 1) ≤ cosh R`; consequently
  the set of realized spoke indices is the initial interval `[1, K]` with
  `cosh R - 1 ≤ K < cosh R` (`spoke_realized_of_le`, `lt_cosh_of_spoke_realized`), so the
  number of visible rays in a ball of radius `R` is `Θ(e^R)`.
* `factoring_star_search_cost` : the cryptographic consequence. For odd `N` with two
  primitive representations, the nodes carrying `N` live in a ball of radius
  `R = ½ log N + log 2`, and the number of distinct hypercycles of the `0`-star meeting that
  ball is at least `√N / 2 - 1`: organising the collision search by star index costs `Θ(√N)`,
  the same as the naive enumeration.
* `dist_ge_spoke_gap` : colliding nodes, though at almost equal radius, are separated by at
  least the difference of their `arsinh` spoke indices, which is typically `≍ ½ log N`.

All of this is proved for Mathlib's genuine hyperbolic metric on `UpperHalfPlane`.
-/

namespace BerggrenHypercycleStars

open Real UpperHalfPlane

noncomputable section

/-! ## Part 0. Euclid seeds and the half-plane embedding

These mirror the definitions used elsewhere in the catalog for the Berggren tree. -/

/-- A **Euclid seed** is a pair `(m, n)` of naturals with `0 < n < m`, coprime and of
opposite parity; these are in bijection with primitive Pythagorean triples via
`(m,n) ↦ (m² - n², 2mn, m² + n²)`. -/
structure IsSeed (m n : ℕ) : Prop where
  pos : 0 < n
  lt : n < m
  cop : Nat.Coprime m n
  parity : (m + n) % 2 = 1

/-- The Berggren move `B₁` in seed coordinates. -/
def seedL (p : ℕ × ℕ) : ℕ × ℕ := (2 * p.1 - p.2, p.1)

/-- The Berggren move `B₂` in seed coordinates. -/
def seedM (p : ℕ × ℕ) : ℕ × ℕ := (2 * p.1 + p.2, p.1)

/-- The Berggren move `B₃` in seed coordinates. -/
def seedR (p : ℕ × ℕ) : ℕ × ℕ := (p.1 + 2 * p.2, p.2)

/-- The half-plane point attached to a seed: `z(m,n) = (n + i)/m`. -/
def hpoint (m n : ℕ) (hm : 0 < m) : ℍ :=
  ⟨⟨(n : ℝ) / m, 1 / m⟩, by
    have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
    show (0 : ℝ) < 1 / (m : ℝ)
    positivity⟩

@[simp] theorem hpoint_re (m n : ℕ) (hm : 0 < m) : (hpoint m n hm).re = (n : ℝ) / m := rfl

@[simp] theorem hpoint_im (m n : ℕ) (hm : 0 < m) : (hpoint m n hm).im = 1 / (m : ℝ) := rfl

/-! ## Part 1. The exact distance from a point to a vertical geodesic

The complete geodesics of `ℍ` with one endpoint at `∞` are the vertical lines `{Re = a}`.
We compute the distance from an arbitrary point to such a line, exactly, and show the
infimum is attained (at the *foot* of the perpendicular). -/

/-- Injectivity of `cosh` on the nonnegative reals. -/
theorem eq_of_cosh_eq {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) (h : Real.cosh x = Real.cosh y) :
    x = y := by
  have h1 : |x| ≤ |y| := Real.cosh_le_cosh.1 h.le
  have h2 : |y| ≤ |x| := Real.cosh_le_cosh.1 h.ge
  rw [abs_of_nonneg hx, abs_of_nonneg hy] at h1 h2
  linarith

/-- `cosh (arsinh (|u|/y)) = √(u² + y²)/y` for `y > 0`. -/
theorem cosh_arsinh_abs_div {u y : ℝ} (hy : 0 < y) :
    Real.cosh (Real.arsinh (|u| / y)) = Real.sqrt (u ^ 2 + y ^ 2) / y := by
  rw [Real.cosh_arsinh, div_pow, sq_abs,
    show (1 : ℝ) + u ^ 2 / y ^ 2 = (Real.sqrt (u ^ 2 + y ^ 2) / y) ^ 2 by
      rw [div_pow, Real.sq_sqrt (by positivity)]; field_simp; ring,
    Real.sqrt_sq (by positivity)]

/-- The vertical geodesic (complete hyperbolic line) with endpoints `a` and `∞`. -/
def vline (a : ℝ) : Set ℍ := {w : ℍ | w.re = a}

/-- The foot of the perpendicular from `z` to the vertical geodesic `{Re = a}`. -/
def foot (a : ℝ) (z : ℍ) : ℍ :=
  ⟨⟨a, Real.sqrt ((z.re - a) ^ 2 + z.im ^ 2)⟩, by
    have := z.im_pos
    show (0 : ℝ) < Real.sqrt ((z.re - a) ^ 2 + z.im ^ 2)
    have : (0 : ℝ) < (z.re - a) ^ 2 + z.im ^ 2 := by positivity
    exact Real.sqrt_pos.2 this⟩

@[simp] theorem foot_re (a : ℝ) (z : ℍ) : (foot a z).re = a := rfl

@[simp] theorem foot_im (a : ℝ) (z : ℍ) :
    (foot a z).im = Real.sqrt ((z.re - a) ^ 2 + z.im ^ 2) := rfl

theorem foot_mem (a : ℝ) (z : ℍ) : foot a z ∈ vline a := rfl

/-- Every point of the vertical geodesic `{Re = a}` is at least `arsinh (|Re z - a| / Im z)`
away from `z`. -/
theorem arsinh_le_dist_of_mem_vline {a : ℝ} {z w : ℍ} (hw : w ∈ vline a) :
    Real.arsinh (|z.re - a| / z.im) ≤ dist z w := by
  have hy : 0 < z.im := z.im_pos
  have ht : 0 < w.im := w.im_pos
  set u : ℝ := z.re - a with hu
  set S : ℝ := Real.sqrt (u ^ 2 + z.im ^ 2) with hS
  have hS0 : 0 < S := Real.sqrt_pos.2 (by positivity)
  have hSsq : S ^ 2 = u ^ 2 + z.im ^ 2 := Real.sq_sqrt (by positivity)
  have hwre : w.re = a := hw
  have hcosh : Real.cosh (dist z w) =
      ((z.re - w.re) ^ 2 + z.im ^ 2 + w.im ^ 2) / (2 * z.im * w.im) :=
    UpperHalfPlane.cosh_dist' z w
  have key : Real.cosh (Real.arsinh (|u| / z.im)) ≤ Real.cosh (dist z w) := by
    rw [cosh_arsinh_abs_div hy, hcosh, hwre, ← hu, ← hS]
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [sq_nonneg (w.im - S), hS0, ht, hy]
  have h1 : |Real.arsinh (|u| / z.im)| ≤ |dist z w| := Real.cosh_le_cosh.1 key
  rwa [abs_of_nonneg (Real.arsinh_nonneg_iff.2 (by positivity)), abs_of_nonneg dist_nonneg] at h1

/-- The distance from `z` to the foot of its perpendicular on `{Re = a}` is exactly
`arsinh (|Re z - a| / Im z)`. -/
theorem dist_foot (a : ℝ) (z : ℍ) :
    dist z (foot a z) = Real.arsinh (|z.re - a| / z.im) := by
  have hy : 0 < z.im := z.im_pos
  set u : ℝ := z.re - a with hu
  set S : ℝ := Real.sqrt (u ^ 2 + z.im ^ 2) with hS
  have hS0 : 0 < S := Real.sqrt_pos.2 (by positivity)
  have hSsq : S ^ 2 = u ^ 2 + z.im ^ 2 := Real.sq_sqrt (by positivity)
  refine eq_of_cosh_eq dist_nonneg (Real.arsinh_nonneg_iff.2 (by positivity)) ?_
  rw [cosh_arsinh_abs_div hy, UpperHalfPlane.cosh_dist' z (foot a z), ← hS]
  show ((z.re - a) ^ 2 + z.im ^ 2 + S ^ 2) / (2 * z.im * S) = S / z.im
  rw [← hu]
  field_simp
  linarith [hSsq]

/-- **The perpendicular distance to a vertical geodesic is attained and equals an `arsinh`.**
This is the basic geometric fact behind every "line" in the picture. -/
theorem isLeast_dist_vline (a : ℝ) (z : ℍ) :
    IsLeast ((fun w : ℍ => dist z w) '' vline a) (Real.arsinh (|z.re - a| / z.im)) :=
  ⟨⟨foot a z, foot_mem a z, dist_foot a z⟩, by
    rintro d ⟨w, hw, rfl⟩; exact arsinh_le_dist_of_mem_vline hw⟩

/-- The hyperbolic distance from a point of `ℍ` to the complete vertical geodesic `{Re = a}`. -/
def distVLine (z : ℍ) (a : ℝ) : ℝ := sInf ((fun w : ℍ => dist z w) '' vline a)

/-- **Exact formula for the distance to a vertical geodesic.** -/
theorem distVLine_eq (z : ℍ) (a : ℝ) :
    distVLine z a = Real.arsinh (|z.re - a| / z.im) :=
  (isLeast_dist_vline a z).csInf_eq

theorem distVLine_nonneg (z : ℍ) (a : ℝ) : 0 ≤ distVLine z a := by
  rw [distVLine_eq]; exact Real.arsinh_nonneg_iff.2 (by positivity)

/-- The hyperbolic sine of the distance to `{Re = a}` is the *Euclidean* slope `|x - a|/y`:
the level sets are Euclidean rays out of `a`. -/
theorem sinh_distVLine (z : ℍ) (a : ℝ) :
    Real.sinh (distVLine z a) = |z.re - a| / z.im := by
  rw [distVLine_eq, Real.sinh_arsinh]

/-- Distance to a fixed geodesic is `1`-Lipschitz. -/
theorem abs_distVLine_sub_le (z w : ℍ) (a : ℝ) :
    |distVLine z a - distVLine w a| ≤ dist z w := by
  have h1 : distVLine z a ≤ dist z w + distVLine w a := by
    rw [distVLine_eq z a, distVLine_eq w a, ← dist_foot a w]
    calc Real.arsinh (|z.re - a| / z.im) ≤ dist z (foot a w) :=
          arsinh_le_dist_of_mem_vline (foot_mem a w)
      _ ≤ dist z w + dist w (foot a w) := dist_triangle _ _ _
  have h2 : distVLine w a ≤ dist z w + distVLine z a := by
    rw [distVLine_eq w a, distVLine_eq z a, ← dist_foot a z]
    calc Real.arsinh (|w.re - a| / w.im) ≤ dist w (foot a z) :=
          arsinh_le_dist_of_mem_vline (foot_mem a z)
      _ ≤ dist w z + dist z (foot a z) := dist_triangle _ _ _
      _ = dist z w + dist z (foot a z) := by rw [dist_comm]
  rw [abs_sub_le_iff]; constructor <;> linarith

/-! ## Part 2. The star over a rational boundary point

For a boundary point `p/q` and a seed `(m,n)`, the distance from `z(m,n)` to the geodesic
`(p/q, ∞)` depends only on the integer linear form `q n - p m`. -/

/-- **Star formula.** The distance from the node `z(m,n)` to the vertical geodesic through the
rational boundary point `p/q` is `arsinh (|q n - p m| / q)`: it depends on the seed only
through the value of the integral linear form `q n - p m`, so the nodes with a fixed value of
that form lie on one hypercycle radiating out of `p/q`. -/
theorem distVLine_hpoint (m n : ℕ) (hm : 0 < m) (p : ℤ) (q : ℕ) (hq : 0 < q) :
    distVLine (hpoint m n hm) ((p : ℝ) / q) =
      Real.arsinh (|(q : ℝ) * n - (p : ℝ) * m| / (q : ℝ)) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  rw [distVLine_eq]
  congr 1
  rw [hpoint_re, hpoint_im,
    show (n : ℝ) / m - (p : ℝ) / q = ((q : ℝ) * n - (p : ℝ) * m) / ((q : ℝ) * m) by
      field_simp,
    abs_div, abs_of_pos (show (0 : ℝ) < (q : ℝ) * m by positivity)]
  field_simp

/-- **The star at the boundary point `0`.** The distance from `z(m,n)` to the imaginary axis is
`arsinh n`: all nodes with the same "spoke index" `n` lie on a single hypercycle emanating
from `0`, and the hypercycles are quantized at the levels `arsinh 1 < arsinh 2 < ⋯`. -/
theorem spoke_dist (m n : ℕ) (hm : 0 < m) :
    distVLine (hpoint m n hm) 0 = Real.arsinh n := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [distVLine_eq]
  congr 1
  rw [hpoint_re, hpoint_im, sub_zero, abs_div, abs_of_nonneg (by positivity : (0:ℝ) ≤ (n:ℝ)),
    abs_of_pos hM]
  field_simp

/-- **The star at the boundary point `1`.** The distance from `z(m,n)` to the geodesic
`(1, ∞)` is `arsinh (m - n)`. -/
theorem costar_dist (m n : ℕ) (hm : 0 < m) (hnm : n ≤ m) :
    distVLine (hpoint m n hm) 1 = Real.arsinh ((m : ℝ) - n) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hnR : (n : ℝ) ≤ m := by exact_mod_cast hnm
  rw [distVLine_eq]
  congr 1
  rw [hpoint_re, hpoint_im,
    show (n : ℝ) / m - 1 = -(((m : ℝ) - n) / m) by field_simp; ring,
    abs_neg, abs_div, abs_of_nonneg (by linarith : (0:ℝ) ≤ (m:ℝ) - n), abs_of_pos hM]
  field_simp

/-! ## Part 3. The Lorentzian charges are hyperbolic distances

The Berggren action preserves the Lorentz form `⟨v,w⟩ = v₁w₁ + v₂w₂ - v₃w₃` on the light cone
of Pythagorean triples, and the pairings with the two isotropic vectors `e₁ = (1,0,1)`,
`e₂ = (0,1,1)` are the standard conserved "charges". We identify them with the two stars. -/

/-- The Lorentz bilinear form on integer triples. -/
def bil (v w : ℤ × ℤ × ℤ) : ℤ := v.1 * w.1 + v.2.1 * w.2.1 - v.2.2 * w.2.2

/-- Euclid's parametrisation of Pythagorean triples. -/
def eu (m n : ℤ) : ℤ × ℤ × ℤ := (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

theorem bil_eu_e1 (m n : ℤ) : bil (eu m n) (1, 0, 1) = -(2 * n ^ 2) := by
  simp [bil, eu]; ring

theorem bil_eu_e2 (m n : ℤ) : bil (eu m n) (0, 1, 1) = -((m - n) ^ 2) := by
  simp [bil, eu]; ring

/-- **The charge at `e₁` is `-2 sinh²` of the distance to the `0`-geodesic.** -/
theorem charge_e1_eq (m n : ℕ) (hm : 0 < m) :
    ((bil (eu m n) (1, 0, 1) : ℤ) : ℝ) = -(2 * Real.sinh (distVLine (hpoint m n hm) 0) ^ 2) := by
  rw [spoke_dist, Real.sinh_arsinh, bil_eu_e1]
  push_cast
  ring

/-- **The charge at `e₂` is `-sinh²` of the distance to the `1`-geodesic.** -/
theorem charge_e2_eq (m n : ℕ) (hm : 0 < m) (hnm : n ≤ m) :
    ((bil (eu m n) (0, 1, 1) : ℤ) : ℝ) = -(Real.sinh (distVLine (hpoint m n hm) 1) ^ 2) := by
  rw [costar_dist m n hm hnm, Real.sinh_arsinh, bil_eu_e2]
  push_cast
  ring

/-! ## Part 4. Each Berggren generator slides along one star -/

/-- `B₃ : (m,n) ↦ (m + 2n, n)` moves a node **along its own hypercycle** of the `0`-star. -/
theorem seedR_preserves_spoke (m n : ℕ) (hm : 0 < m) (hm' : 0 < m + 2 * n) :
    distVLine (hpoint (m + 2 * n) n hm') 0 = distVLine (hpoint m n hm) 0 := by
  rw [spoke_dist, spoke_dist]

/-- `B₁ : (m,n) ↦ (2m - n, m)` moves a node **along its own hypercycle** of the `1`-star:
the linear form `m - n` is preserved. -/
theorem seedL_preserves_costar (m n : ℕ) (hm : 0 < m) (hn : n ≤ m) (hm' : 0 < 2 * m - n) :
    distVLine (hpoint (2 * m - n) m hm') 1 = distVLine (hpoint m n hm) 1 := by
  rw [costar_dist _ _ hm' (by omega), costar_dist m n hm hn]
  congr 1
  have : ((2 * m - n : ℕ) : ℝ) = 2 * (m : ℝ) - n := by
    have : (n : ℝ) ≤ m := by exact_mod_cast hn
    push_cast [Nat.cast_sub (by omega : n ≤ 2 * m)]
    ring
  rw [this]; ring

/-- The Pell form `m² - 2mn - n²`, the discriminant of the `B₂` dichotomy. -/
def pellForm (m n : ℤ) : ℤ := m ^ 2 - 2 * m * n - n ^ 2

/-- `B₂ : (m,n) ↦ (2m + n, m)` **negates** the Pell form: it preserves no line of either star,
but reflects the pencil. -/
theorem seedM_pell_flip (m n : ℤ) : pellForm (2 * m + n) m = -pellForm m n := by
  simp only [pellForm]; ring

/-- The Pell form is the exact combination `sinh² d₁ - 2 sinh² d₀` of the two star distances:
`B₂`'s invariant is a genuine hyperbolic quantity. -/
theorem seedM_sinh_relation (m n : ℕ) (hm : 0 < m) (hnm : n ≤ m) :
    Real.sinh (distVLine (hpoint m n hm) 1) ^ 2
        - 2 * Real.sinh (distVLine (hpoint m n hm) 0) ^ 2
      = ((pellForm m n : ℤ) : ℝ) := by
  rw [spoke_dist, costar_dist m n hm hnm, Real.sinh_arsinh, Real.sinh_arsinh]
  simp only [pellForm]
  push_cast
  ring

/-! ## Part 5. The rays really do radiate out of the boundary -/

/-- Iterating `B₃` from a seed drives the node to the boundary point `0`, staying on one
hypercycle: this is the visible "ray out of `0`". -/
theorem spoke_tendsto_zero (m n : ℕ) (hn : 0 < n) (hm : ∀ k : ℕ, 0 < m + 2 * k * n) :
    Filter.Tendsto (fun k : ℕ => ((hpoint (m + 2 * k * n) n (hm k) : ℍ) : ℂ))
      Filter.atTop (nhds 0) := by
  rw [tendsto_zero_iff_norm_tendsto_zero]
  have hbd : ∀ k : ℕ, ‖((hpoint (m + 2 * k * n) n (hm k) : ℍ) : ℂ)‖
      ≤ ((n : ℝ) + 1) / (2 * k + 1) := by
    intro k
    have hnR : (1 : ℝ) ≤ n := by exact_mod_cast hn
    have hMR : (0 : ℝ) < (m + 2 * k * n : ℕ) := by exact_mod_cast hm k
    have hge : (2 : ℝ) * k + 1 ≤ ((m + 2 * k * n : ℕ) : ℝ) := by
      have hm0 : 0 < m := by have := hm 0; omega
      have hkey : 1 + 2 * k ≤ m + 2 * k * n := by
        have : 2 * k * 1 ≤ 2 * k * n := Nat.mul_le_mul_left _ hn
        omega
      have := (Nat.cast_le (α := ℝ)).2 hkey
      push_cast at this ⊢
      linarith
    have hnormle : ‖((hpoint (m + 2 * k * n) n (hm k) : ℍ) : ℂ)‖ ≤
        ((n : ℝ) + 1) / ((m + 2 * k * n : ℕ) : ℝ) := by
      have hre : (((hpoint (m + 2 * k * n) n (hm k) : ℍ) : ℂ)).re = (n : ℝ) / (m + 2 * k * n : ℕ) :=
        rfl
      have him : (((hpoint (m + 2 * k * n) n (hm k) : ℍ) : ℂ)).im = 1 / ((m + 2 * k * n : ℕ) : ℝ) :=
        rfl
      calc ‖((hpoint (m + 2 * k * n) n (hm k) : ℍ) : ℂ)‖
          ≤ |(((hpoint (m + 2 * k * n) n (hm k) : ℍ) : ℂ)).re| +
            |(((hpoint (m + 2 * k * n) n (hm k) : ℍ) : ℂ)).im| := Complex.norm_le_abs_re_add_abs_im _
        _ = ((n : ℝ) + 1) / ((m + 2 * k * n : ℕ) : ℝ) := by
            rw [hre, him, abs_of_nonneg (by positivity), abs_of_nonneg (by positivity)]
            field_simp
    refine hnormle.trans ?_
    apply div_le_div_of_nonneg_left (by positivity) (by positivity) hge
  have htend : Filter.Tendsto (fun k : ℕ => ((n : ℝ) + 1) / (2 * k + 1)) Filter.atTop
      (nhds 0) := by
    have h1 : Filter.Tendsto (fun k : ℕ => (2 : ℝ) * k + 1) Filter.atTop Filter.atTop := by
      apply Filter.tendsto_atTop_add_const_right
      apply Filter.Tendsto.const_mul_atTop (by norm_num)
      exact tendsto_natCast_atTop_atTop
    exact Filter.Tendsto.div_atTop tendsto_const_nhds h1
  refine squeeze_zero (fun k => norm_nonneg _) hbd htend

/-! ## Part 6. Exact census of the star, and the cost of a star-organised search -/

/-- `cosh` of the distance from the base point `i` to the node `z(m,n)`, i.e. the radial
coordinate of the picture. -/
theorem cosh_dist_hpoint_I (m n : ℕ) (hm : 0 < m) :
    Real.cosh (dist (hpoint m n hm) UpperHalfPlane.I)
      = ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1) / (2 * m) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [UpperHalfPlane.cosh_dist']
  simp only [hpoint_re, hpoint_im, UpperHalfPlane.I_re, UpperHalfPlane.I_im]
  field_simp
  ring

/-- The `(n+1, n)` pairs are Euclid seeds; they are the cheapest representatives of each spoke. -/
theorem isSeed_succ (n : ℕ) (hn : 0 < n) : IsSeed (n + 1) n := by
  refine ⟨hn, Nat.lt_succ_self n, ?_, ?_⟩
  · simp [Nat.Coprime]
  · omega

/-- **Exact star census.** The spoke index `n ≥ 1` is realized inside the hyperbolic ball of
radius `R` about `i` — i.e. some Berggren node on the `n`-th hypercycle of the `0`-star lies in
the ball — if and only if `(n² + n + 1)/(n + 1) ≤ cosh R`. The optimal representative is always
the left-spine seed `(n+1, n)`. -/
theorem spoke_realized_iff (n : ℕ) (hn : 0 < n) (R : ℝ) (hR : 0 ≤ R) :
    (∃ m : ℕ, ∃ hm : 0 < m, IsSeed m n ∧ dist (hpoint m n hm) UpperHalfPlane.I ≤ R)
      ↔ ((n : ℝ) ^ 2 + n + 1) / ((n : ℝ) + 1) ≤ Real.cosh R := by
  have hnR : (1 : ℝ) ≤ n := by exact_mod_cast hn
  constructor
  · rintro ⟨m, hm, hseed, hd⟩
    have hMR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
    have hmn : (n : ℝ) + 1 ≤ (m : ℝ) := by exact_mod_cast hseed.lt
    have hcosh : ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1) / (2 * m) ≤ Real.cosh R := by
      rw [← cosh_dist_hpoint_I m n hm]
      exact Real.cosh_le_cosh.2 (by
        rw [abs_of_nonneg dist_nonneg, abs_of_nonneg hR]; exact hd)
    refine le_trans ?_ hcosh
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [sq_nonneg ((m : ℝ) - (n : ℝ) - 1), sq_nonneg ((m : ℝ) * ((n : ℝ) + 1) - ((n:ℝ)^2+1))]
  · intro h
    refine ⟨n + 1, by omega, isSeed_succ n hn, ?_⟩
    have hcosh : Real.cosh (dist (hpoint (n + 1) n (by omega)) UpperHalfPlane.I) ≤ Real.cosh R := by
      rw [cosh_dist_hpoint_I]
      refine le_trans (le_of_eq ?_) h
      push_cast
      field_simp
      ring
    have := Real.cosh_le_cosh.1 hcosh
    rwa [abs_of_nonneg dist_nonneg, abs_of_nonneg hR] at this

/-- Every spoke index up to `cosh R - 1` is realized in the ball of radius `R`. -/
theorem spoke_realized_of_le (n : ℕ) (hn : 0 < n) (R : ℝ) (hR : 0 ≤ R)
    (h : (n : ℝ) + 1 ≤ Real.cosh R) :
    ∃ m : ℕ, ∃ hm : 0 < m, IsSeed m n ∧ dist (hpoint m n hm) UpperHalfPlane.I ≤ R := by
  rw [spoke_realized_iff n hn R hR]
  refine le_trans ?_ h
  rw [div_le_iff₀ (by positivity)]
  nlinarith [(by exact_mod_cast hn : (1:ℝ) ≤ n)]

/-- Conversely, a realized spoke index is strictly below `cosh R`: the star is visible out to
radius `arsinh` of about `e^R`, and no further. -/
theorem lt_cosh_of_spoke_realized (n : ℕ) (hn : 0 < n) (R : ℝ) (hR : 0 ≤ R)
    (h : ∃ m : ℕ, ∃ hm : 0 < m, IsSeed m n ∧ dist (hpoint m n hm) UpperHalfPlane.I ≤ R) :
    (n : ℝ) < Real.cosh R := by
  rw [spoke_realized_iff n hn R hR] at h
  refine lt_of_lt_of_le ?_ h
  rw [lt_div_iff₀ (by positivity)]
  nlinarith [(by exact_mod_cast hn : (1:ℝ) ≤ n)]

open Classical in
/-- The finite set of spoke indices (`0`-star hypercycles) actually met by Berggren nodes inside
the hyperbolic ball of radius `R` about `i`. -/
def spokeSet (R : ℝ) : Finset ℕ :=
  (Finset.Icc 1 ⌊Real.cosh R⌋₊).filter
    (fun n => ∃ m : ℕ, ∃ hm : 0 < m, IsSeed m n ∧ dist (hpoint m n hm) UpperHalfPlane.I ≤ R)

/-- Membership in `spokeSet` is exactly the realizability condition: the ambient bound
`⌊cosh R⌋₊` discards nothing, by `lt_cosh_of_spoke_realized`. -/
theorem mem_spokeSet_iff (R : ℝ) (hR : 0 ≤ R) (n : ℕ) :
    n ∈ spokeSet R ↔ 0 < n ∧
      ∃ m : ℕ, ∃ hm : 0 < m, IsSeed m n ∧ dist (hpoint m n hm) UpperHalfPlane.I ≤ R := by
  classical
  rw [spokeSet, Finset.mem_filter, Finset.mem_Icc]
  constructor
  · rintro ⟨⟨h1, -⟩, h2⟩; exact ⟨h1, h2⟩
  · rintro ⟨h1, h2⟩
    refine ⟨⟨h1, ?_⟩, h2⟩
    exact Nat.le_floor (le_of_lt (lt_cosh_of_spoke_realized n h1 R hR h2))

/-- **Star census, lower bound.** The number of distinct hypercycles of the `0`-star that meet
the hyperbolic ball of radius `R` about `i` is at least `cosh R - 2`, hence at least
`e^R / 2 - 2`. -/
theorem card_spokeSet_ge (R : ℝ) (hR : 0 ≤ R) :
    Real.cosh R - 2 ≤ (spokeSet R).card := by
  classical
  have hc1 : (1 : ℝ) ≤ Real.cosh R := Real.one_le_cosh R
  set K : ℕ := ⌊Real.cosh R - 1⌋₊ with hK
  have hsub : Finset.Icc 1 K ⊆ spokeSet R := by
    intro n hn
    rw [Finset.mem_Icc] at hn
    have hn1 : 0 < n := hn.1
    have hnK : (n : ℝ) ≤ Real.cosh R - 1 :=
      le_trans (by exact_mod_cast hn.2) (Nat.floor_le (by linarith))
    have hreal : ∃ m : ℕ, ∃ hm : 0 < m, IsSeed m n ∧ dist (hpoint m n hm) UpperHalfPlane.I ≤ R :=
      spoke_realized_of_le n hn1 R hR (by linarith)
    rw [mem_spokeSet_iff R hR]
    exact ⟨hn1, hreal⟩
  have hcard : K ≤ (spokeSet R).card := by
    have := Finset.card_le_card hsub
    simpa using this
  have hKR : Real.cosh R - 1 - 1 ≤ (K : ℝ) := by
    have := Nat.sub_one_lt_floor (Real.cosh R - 1)
    linarith
  have : ((K : ℝ)) ≤ (spokeSet R).card := by exact_mod_cast hcard
  linarith

/-- **Star census, upper bound.** Conversely at most `cosh R` hypercycles are visible. Together
with `card_spokeSet_ge` the visible ray count is `cosh R + O(1) = Θ(e^R)`. -/
theorem card_spokeSet_le (R : ℝ) :
    ((spokeSet R).card : ℝ) ≤ Real.cosh R := by
  classical
  have h1 : (spokeSet R).card ≤ (Finset.Icc 1 ⌊Real.cosh R⌋₊).card :=
    Finset.card_le_card (Finset.filter_subset _ _)
  have h2 : (Finset.Icc 1 ⌊Real.cosh R⌋₊).card = ⌊Real.cosh R⌋₊ := by simp
  have h3 : ((⌊Real.cosh R⌋₊ : ℕ) : ℝ) ≤ Real.cosh R :=
    Nat.floor_le (le_trans zero_le_one (Real.one_le_cosh R))
  have h4 : ((spokeSet R).card : ℝ) ≤ ((⌊Real.cosh R⌋₊ : ℕ) : ℝ) := by
    exact_mod_cast h2 ▸ h1
  linarith

/-- Two nodes carrying the same hypotenuse are separated by at least the gap between their
spoke indices: even though a collision pair sits in a thin annulus around the sphere of radius
`½ log N`, the two nodes are far apart in the angular (star) direction. -/
theorem dist_ge_spoke_gap (m₁ n₁ m₂ n₂ : ℕ) (h₁ : 0 < m₁) (h₂ : 0 < m₂) :
    |Real.arsinh n₁ - Real.arsinh n₂| ≤ dist (hpoint m₁ n₁ h₁) (hpoint m₂ n₂ h₂) := by
  have := abs_distVLine_sub_le (hpoint m₁ n₁ h₁) (hpoint m₂ n₂ h₂) 0
  rwa [spoke_dist, spoke_dist] at this

theorem sqrt_eq_exp_half_log {x : ℝ} (hx : 0 < x) : Real.sqrt x = Real.exp (Real.log x / 2) := by
  rw [Real.sqrt_eq_rpow, Real.rpow_def_of_pos hx]
  ring_nf

/-- **No free lunch, star version.** All Berggren nodes of hypotenuse `N` lie in the ball of
radius `R = ½ log N + log 2` about `i` (the collision annulus). That ball already meets at
least `√N - 2` distinct hypercycles of the `0`-star, so scanning the picture ray by ray costs
`Ω(√N)` — no better than the naive enumeration of the representations of `N`. -/
theorem factoring_star_search_cost (N : ℕ) (hN : 1 ≤ N) :
    Real.sqrt N - 2 ≤ (spokeSet (Real.log N / 2 + Real.log 2)).card := by
  have hNR : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  have hlogN : 0 ≤ Real.log N := Real.log_nonneg hNR
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  set R : ℝ := Real.log N / 2 + Real.log 2 with hRdef
  have hR : 0 ≤ R := by positivity
  have hexp : Real.exp R = 2 * Real.sqrt N := by
    rw [hRdef, Real.exp_add, Real.exp_log (by norm_num : (0:ℝ) < 2),
      ← sqrt_eq_exp_half_log (by linarith : (0:ℝ) < (N:ℝ))]
    ring
  have hcosh : Real.sqrt N ≤ Real.cosh R := by
    rw [Real.cosh_eq]
    have := Real.exp_pos (-R)
    rw [hexp] at *
    linarith
  have := card_spokeSet_ge R hR
  linarith

/-! ## Part 7. The hyperbolic distance between colliding nodes *is* Euler's factoring datum

Euler's method factors `N` from two essentially different representations
`N = m₁² + n₁² = m₂² + n₂²` through the integer `G = m₁m₂ + n₁n₂`, whose gcd with `N` is a
proper divisor. We show that `G` is determined by the *hyperbolic distance* between the two
corresponding nodes: the arithmetic of the factorization is visible in the picture. -/

/-- The exact hyperbolic cosine of the distance between two nodes of the embedded tree. -/
theorem cosh_dist_hpoint_hpoint (m₁ n₁ m₂ n₂ : ℕ) (h₁ : 0 < m₁) (h₂ : 0 < m₂) :
    Real.cosh (dist (hpoint m₁ n₁ h₁) (hpoint m₂ n₂ h₂))
      = (((n₁ : ℝ) * m₂ - (n₂ : ℝ) * m₁) ^ 2 + (m₁ : ℝ) ^ 2 + (m₂ : ℝ) ^ 2)
          / (2 * m₁ * m₂) := by
  have hM₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast h₁
  have hM₂ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast h₂
  rw [UpperHalfPlane.cosh_dist']
  simp only [hpoint_re, hpoint_im]
  field_simp
  ring

/-- The Brahmagupta–Fibonacci identity, the algebraic heart of Euler's method. -/
theorem brahmagupta (m₁ n₁ m₂ n₂ : ℤ) :
    (m₁ ^ 2 + n₁ ^ 2) * (m₂ ^ 2 + n₂ ^ 2)
      = (m₁ * m₂ + n₁ * n₂) ^ 2 + (n₁ * m₂ - n₂ * m₁) ^ 2 := by ring

/-- **Euler's factoring datum is a hyperbolic observable.** If two Berggren nodes carry the same
hypotenuse `N`, then the integer `G = m₁m₂ + n₁n₂` — whose gcd with `N` splits `N` — is
recovered from the hyperbolic distance `d` between the two nodes by
`G² = N² + m₁² + m₂² - 2 m₁ m₂ cosh d`. -/
theorem euler_datum_from_dist (N m₁ n₁ m₂ n₂ : ℕ) (h₁ : 0 < m₁) (h₂ : 0 < m₂)
    (hN₁ : m₁ ^ 2 + n₁ ^ 2 = N) (hN₂ : m₂ ^ 2 + n₂ ^ 2 = N) :
    (((m₁ * m₂ + n₁ * n₂ : ℕ) : ℝ)) ^ 2
      = (N : ℝ) ^ 2 + (m₁ : ℝ) ^ 2 + (m₂ : ℝ) ^ 2
        - 2 * m₁ * m₂ * Real.cosh (dist (hpoint m₁ n₁ h₁) (hpoint m₂ n₂ h₂)) := by
  have hM₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast h₁
  have hM₂ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast h₂
  have hbra : ((m₁ : ℝ) ^ 2 + (n₁ : ℝ) ^ 2) * ((m₂ : ℝ) ^ 2 + (n₂ : ℝ) ^ 2)
      = ((m₁ : ℝ) * m₂ + (n₁ : ℝ) * n₂) ^ 2 + ((n₁ : ℝ) * m₂ - (n₂ : ℝ) * m₁) ^ 2 := by ring
  have e₁ : ((m₁ : ℝ) ^ 2 + (n₁ : ℝ) ^ 2) = (N : ℝ) := by exact_mod_cast hN₁
  have e₂ : ((m₂ : ℝ) ^ 2 + (n₂ : ℝ) ^ 2) = (N : ℝ) := by exact_mod_cast hN₂
  rw [cosh_dist_hpoint_hpoint m₁ n₁ m₂ n₂ h₁ h₂]
  rw [e₁, e₂] at hbra
  push_cast
  field_simp
  nlinarith [hbra]

/-- Lab note: the smallest collision, `65 = 8² + 1² = 7² + 4²`. The two nodes sit on the
hypercycles `arsinh 1` and `arsinh 4` of the `0`-star, and Euler's datum `G = 60` gives the
factor `gcd(65, 60) = 5`. -/
theorem collision_65_spokes :
    distVLine (hpoint 8 1 (by norm_num)) 0 = Real.arsinh 1 ∧
      distVLine (hpoint 7 4 (by norm_num)) 0 = Real.arsinh 4 ∧
      Nat.gcd 65 (8 * 7 + 1 * 4) = 5 := by
  refine ⟨?_, ?_, by norm_num⟩
  · rw [spoke_dist]; norm_num
  · rw [spoke_dist]; norm_num


/-! ## Part 8. Motion along a ray: the steps shrink but the ray is infinitely long

Iterating `B₃` slides a node along one hypercycle of the `0`-star. The hyperbolic step length
of that motion is given by an exact formula and tends to `0`: the nodes crowd together as the
ray approaches the boundary point `0`. Nevertheless the ray has infinite hyperbolic length. -/

/-- **Exact step length along a ray of the `0`-star.** -/
theorem cosh_step_along_spoke (m n : ℕ) (hm : 0 < m) (hm' : 0 < m + 2 * n) :
    Real.cosh (dist (hpoint m n hm) (hpoint (m + 2 * n) n hm'))
      = 1 + 2 * (n : ℝ) ^ 2 * ((n : ℝ) ^ 2 + 1) / ((m : ℝ) * ((m : ℝ) + 2 * n)) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  rw [cosh_dist_hpoint_hpoint m n (m + 2 * n) n hm hm']
  push_cast
  field_simp
  ring

/-- The step length along a ray tends to `0`: the picture shows the nodes accumulating. -/
theorem step_along_spoke_tendsto_zero (m n : ℕ) (hn : 0 < n) (hm : ∀ k : ℕ, 0 < m + 2 * k * n) :
    Filter.Tendsto
      (fun k : ℕ => dist (hpoint (m + 2 * k * n) n (hm k))
        (hpoint (m + 2 * (k + 1) * n) n (hm (k + 1)))) Filter.atTop (nhds 0) := by
  have hm0 : 0 < m := by have := hm 0; omega
  have hnR : (1 : ℝ) ≤ n := by exact_mod_cast hn
  -- the exact step formula, with the auxiliary quantity `t k`
  set t : ℕ → ℝ := fun k => 2 * (n : ℝ) ^ 2 * ((n : ℝ) ^ 2 + 1) /
      (((m + 2 * k * n : ℕ) : ℝ) * (((m + 2 * k * n : ℕ) : ℝ) + 2 * n)) with ht
  have hstep : ∀ k : ℕ, Real.cosh (dist (hpoint (m + 2 * k * n) n (hm k))
      (hpoint (m + 2 * (k + 1) * n) n (hm (k + 1)))) = 1 + t k := by
    intro k
    have hmk : 0 < m + 2 * k * n := hm k
    have hEq : m + 2 * (k + 1) * n = (m + 2 * k * n) + 2 * n := by ring
    have := cosh_step_along_spoke (m + 2 * k * n) n hmk (by omega)
    rw [ht]
    simpa [hEq] using this
  -- `t k → 0`
  have hbd : ∀ k : ℕ, |t k| ≤ 2 * (n : ℝ) ^ 2 * ((n : ℝ) ^ 2 + 1) / (2 * k + 1) := by
    intro k
    have hmk : (0 : ℝ) < ((m + 2 * k * n : ℕ) : ℝ) := by exact_mod_cast hm k
    have hge : (2 : ℝ) * k + 1 ≤ ((m + 2 * k * n : ℕ) : ℝ) := by
      have hkey : 1 + 2 * k ≤ m + 2 * k * n := by
        have : 2 * k * 1 ≤ 2 * k * n := Nat.mul_le_mul_left _ hn
        omega
      have := (Nat.cast_le (α := ℝ)).2 hkey
      push_cast at this ⊢
      linarith
    rw [ht]
    simp only
    rw [abs_of_nonneg (by positivity)]
    apply div_le_div_of_nonneg_left (by positivity) (by positivity)
    nlinarith [hmk, hnR]
  have htend0 : Filter.Tendsto t Filter.atTop (nhds 0) := by
    have hlim : Filter.Tendsto
        (fun k : ℕ => 2 * (n : ℝ) ^ 2 * ((n : ℝ) ^ 2 + 1) / (2 * k + 1)) Filter.atTop
        (nhds 0) := by
      have h1 : Filter.Tendsto (fun k : ℕ => (2 : ℝ) * k + 1) Filter.atTop Filter.atTop := by
        apply Filter.tendsto_atTop_add_const_right
        apply Filter.Tendsto.const_mul_atTop (by norm_num)
        exact tendsto_natCast_atTop_atTop
      exact Filter.Tendsto.div_atTop tendsto_const_nhds h1
    exact squeeze_zero_norm hbd hlim
  -- transfer to distances through monotonicity of `cosh`
  rw [Metric.tendsto_atTop]
  intro ε hε
  have hcε : (1 : ℝ) < Real.cosh ε := by
    have := Real.one_lt_cosh (x := ε)
    exact this.2 (ne_of_gt hε)
  have := (Metric.tendsto_atTop.1 htend0) (Real.cosh ε - 1) (by linarith)
  obtain ⟨K, hK⟩ := this
  refine ⟨K, fun k hk => ?_⟩
  have h1 : |t k - 0| < Real.cosh ε - 1 := hK k hk
  have h2 : Real.cosh (dist (hpoint (m + 2 * k * n) n (hm k))
      (hpoint (m + 2 * (k + 1) * n) n (hm (k + 1)))) < Real.cosh ε := by
    rw [hstep k]
    have : t k < Real.cosh ε - 1 := by
      have := abs_lt.1 h1
      linarith [this.2]
    linarith
  have h3 := Real.cosh_lt_cosh.1 h2
  rw [Real.dist_eq, sub_zero, abs_of_nonneg dist_nonneg]
  rw [abs_of_nonneg dist_nonneg, abs_of_pos hε] at h3
  exact h3

theorem cosh_le_exp_of_nonneg {x : ℝ} (hx : 0 ≤ x) : Real.cosh x ≤ Real.exp x := by
  rw [Real.cosh_eq]
  have h : Real.exp (-x) ≤ Real.exp x := Real.exp_le_exp.2 (by linarith)
  linarith

/-- A node of the tree is at hyperbolic distance at least `log (m/2)` from the base point. -/
theorem log_le_dist_hpoint (m n : ℕ) (hm : 0 < m) :
    Real.log ((m : ℝ) / 2) ≤ dist (hpoint m n hm) UpperHalfPlane.I := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hcosh : Real.cosh (dist (hpoint m n hm) UpperHalfPlane.I)
      = ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1) / (2 * m) := cosh_dist_hpoint_I m n hm
  have h1 : (m : ℝ) / 2 ≤ Real.cosh (dist (hpoint m n hm) UpperHalfPlane.I) := by
    rw [hcosh, le_div_iff₀ (by positivity)]
    nlinarith [sq_nonneg ((n : ℝ)), hM]
  have h2 : Real.cosh (dist (hpoint m n hm) UpperHalfPlane.I)
      ≤ Real.exp (dist (hpoint m n hm) UpperHalfPlane.I) := cosh_le_exp_of_nonneg dist_nonneg
  have h3 : (m : ℝ) / 2 ≤ Real.exp (dist (hpoint m n hm) UpperHalfPlane.I) := le_trans h1 h2
  have := Real.log_le_log (by positivity) h3
  rwa [Real.log_exp] at this

/-- **A ray of the `0`-star has infinite hyperbolic length.** Although the individual `B₃` steps
shrink to zero, the endpoints escape to infinity, so the total length of the ray is unbounded:
these Euclidean half-lines are genuine complete hypercycles running out to the boundary. -/
theorem spoke_ray_unbounded (m n : ℕ) (hn : 0 < n) (hm : ∀ k : ℕ, 0 < m + 2 * k * n) (L : ℝ) :
    ∃ k : ℕ, L ≤ dist (hpoint m n (by simpa using hm 0)) (hpoint (m + 2 * k * n) n (hm k)) := by
  have hm0 : 0 < m := by have := hm 0; omega
  set z₀ : ℍ := hpoint m n (by simpa using hm 0) with hz₀
  -- choose `k` so large that `log ((m + 2kn)/2)` exceeds `L + dist z₀ i`
  obtain ⟨k, hk⟩ : ∃ k : ℕ, Real.exp (L + dist z₀ UpperHalfPlane.I) * 2 ≤ ((m + 2 * k * n : ℕ) : ℝ) := by
    obtain ⟨k, hk⟩ := exists_nat_gt (Real.exp (L + dist z₀ UpperHalfPlane.I) * 2)
    refine ⟨k, ?_⟩
    have hkey : k ≤ m + 2 * k * n := by
      have : 2 * k * 1 ≤ 2 * k * n := Nat.mul_le_mul_left _ hn
      omega
    have : ((k : ℕ) : ℝ) ≤ ((m + 2 * k * n : ℕ) : ℝ) := by exact_mod_cast hkey
    linarith
  refine ⟨k, ?_⟩
  have hlog : L + dist z₀ UpperHalfPlane.I ≤
      dist (hpoint (m + 2 * k * n) n (hm k)) UpperHalfPlane.I := by
    refine le_trans ?_ (log_le_dist_hpoint (m + 2 * k * n) n (hm k))
    have hpos : (0 : ℝ) < Real.exp (L + dist z₀ UpperHalfPlane.I) := Real.exp_pos _
    have h2 : Real.exp (L + dist z₀ UpperHalfPlane.I) ≤ ((m + 2 * k * n : ℕ) : ℝ) / 2 := by
      linarith
    have := Real.log_le_log hpos h2
    rwa [Real.log_exp] at this
  have htri : dist (hpoint (m + 2 * k * n) n (hm k)) UpperHalfPlane.I
      ≤ dist (hpoint (m + 2 * k * n) n (hm k)) z₀ + dist z₀ UpperHalfPlane.I :=
    dist_triangle _ _ _
  have hfin := le_trans hlog htri
  rw [dist_comm z₀]
  linarith

/-! ## Part 9. Separation: how close two nodes of the picture can be -/

/-- **Uniform separation on a horocycle.** Two distinct nodes at the same height `1/m` (i.e. on
the same horocycle based at `∞`) are at hyperbolic distance at least `arcosh (3/2)`, the
distance from `i` to the root node `z(2,1)`. -/
theorem cosh_dist_same_height (m n n' : ℕ) (hm : 0 < m) (h : n ≠ n') :
    (3 : ℝ) / 2 ≤ Real.cosh (dist (hpoint m n hm) (hpoint m n' hm)) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hne : ((n : ℝ) - (n' : ℝ)) ^ 2 ≥ 1 := by
    rcases Nat.lt_or_ge n n' with hlt | hge
    · have hc : (n : ℝ) + 1 ≤ (n' : ℝ) := by exact_mod_cast hlt
      nlinarith
    · have hgt : n' < n := lt_of_le_of_ne hge (fun hh => h hh.symm)
      have hc : (n' : ℝ) + 1 ≤ (n : ℝ) := by exact_mod_cast hgt
      nlinarith
  rw [cosh_dist_hpoint_hpoint m n m n' hm hm, le_div_iff₀ (by positivity)]
  nlinarith [hne, hM, sq_nonneg ((m : ℝ))]

/-- **Separation of distinct nodes.** Any two distinct nodes satisfy
`cosh d ≥ 1 + 1/(2 m m')`. The bound degrades with depth, which is exactly why the picture
looks like a dense set of curves rather than a discrete cloud. -/
theorem cosh_dist_nodes_ge (m n m' n' : ℕ) (hm : 0 < m) (hm' : 0 < m')
    (h : (m, n) ≠ (m', n')) :
    1 + 1 / (2 * (m : ℝ) * m') ≤ Real.cosh (dist (hpoint m n hm) (hpoint m' n' hm')) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hM' : (0 : ℝ) < (m' : ℝ) := by exact_mod_cast hm'
  have hkey : (1 : ℝ) ≤ ((n : ℝ) * m' - (n' : ℝ) * m) ^ 2 + ((m : ℝ) - m') ^ 2 := by
    by_cases hmm : m = m'
    · subst hmm
      have hnn : n ≠ n' := by
        intro hn; exact h (by rw [hn])
      have hne : ((n : ℝ) - (n' : ℝ)) ^ 2 ≥ 1 := by
        rcases Nat.lt_or_ge n n' with hlt | hge
        · have hc : (n : ℝ) + 1 ≤ (n' : ℝ) := by exact_mod_cast hlt
          nlinarith
        · have hgt : n' < n := lt_of_le_of_ne hge (fun hh => hnn hh.symm)
          have hc : (n' : ℝ) + 1 ≤ (n : ℝ) := by exact_mod_cast hgt
          nlinarith
      have hM1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
      have hfac : ((n : ℝ) * m - (n' : ℝ) * m) ^ 2 = (m : ℝ) ^ 2 * ((n : ℝ) - (n' : ℝ)) ^ 2 := by
        ring
      rw [hfac]
      nlinarith [hne, hM1]
    · have hne : ((m : ℝ) - (m' : ℝ)) ^ 2 ≥ 1 := by
        rcases Nat.lt_or_ge m m' with hlt | hge
        · have hc : (m : ℝ) + 1 ≤ (m' : ℝ) := by exact_mod_cast hlt
          nlinarith
        · have hgt : m' < m := lt_of_le_of_ne hge (fun hh => hmm hh.symm)
          have hc : (m' : ℝ) + 1 ≤ (m : ℝ) := by exact_mod_cast hgt
          nlinarith
      nlinarith [sq_nonneg ((n : ℝ) * m' - (n' : ℝ) * m)]
  rw [cosh_dist_hpoint_hpoint m n m' n' hm hm', le_div_iff₀ (by positivity)]
  have hexp : (1 + 1 / (2 * (m : ℝ) * m')) * (2 * m * m')
      = 2 * (m : ℝ) * m' + 1 := by field_simp
  rw [hexp]
  nlinarith [hkey, hM, hM']


/-! ## Part 10. Diophantine avoidance and the bookkeeping of the two star indices -/

/-- **Nodes avoid every rational geodesic, quantitatively.** If the node `z(m,n)` does not lie on
the geodesic through the boundary point `p/q`, then it is at distance at least `arsinh (1/q)`
from it: the integrality of `qn - pm` forbids near misses. This is the hyperbolic form of the
elementary Diophantine gap `|n/m - p/q| ≥ 1/(qm)`. -/
theorem arsinh_inv_le_distVLine (m n : ℕ) (hm : 0 < m) (p : ℤ) (q : ℕ) (hq : 0 < q)
    (h : (q : ℤ) * n ≠ p * m) :
    Real.arsinh (1 / (q : ℝ)) ≤ distVLine (hpoint m n hm) ((p : ℝ) / q) := by
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  rw [distVLine_hpoint m n hm p q hq, Real.arsinh_le_arsinh]
  have hint : (1 : ℤ) ≤ |(q : ℤ) * n - p * m| := by
    rcases lt_trichotomy ((q : ℤ) * n - p * m) 0 with hlt | heq | hgt
    · rw [abs_of_neg hlt]; omega
    · exact absurd (by omega : (q : ℤ) * n = p * m) h
    · rw [abs_of_pos hgt]; omega
  have hreal : (1 : ℝ) ≤ |(q : ℝ) * n - (p : ℝ) * m| := by
    have := (Int.cast_le (R := ℝ)).2 hint
    rwa [Int.cast_abs, Int.cast_one, Int.cast_sub, Int.cast_mul, Int.cast_mul,
      Int.cast_natCast, Int.cast_natCast] at this
  exact (div_le_div_iff_of_pos_right hQ).mpr hreal

/-- The pair of star indices `(u, v) = (n, m - n)` — the distance parameters at the boundary
points `0` and `1` — transforms under the three Berggren moves by
`B₁ : (u,v) ↦ (u+v, v)`, `B₂ : (u,v) ↦ (u+v, 2u+v)`, `B₃ : (u,v) ↦ (u, 2u+v)`.
Each generator fixes exactly one of the two stars, and the pair evolves by a Stern–Brocot-like
system on `ℕ²`. -/
theorem star_indices_seedL (m n : ℕ) (h : n ≤ m) :
    ((seedL (m, n)).2, (seedL (m, n)).1 - (seedL (m, n)).2) = (m, m - n) := by
  simp only [seedL]
  refine Prod.ext rfl ?_
  simp only
  omega

theorem star_indices_seedM (m n : ℕ) :
    ((seedM (m, n)).2, (seedM (m, n)).1 - (seedM (m, n)).2) = (m, m + n) := by
  simp only [seedM]
  refine Prod.ext rfl ?_
  simp only
  omega

theorem star_indices_seedR (m n : ℕ) :
    ((seedR (m, n)).2, (seedR (m, n)).1 - (seedR (m, n)).2) = (n, m + n) := by
  simp only [seedR]
  refine Prod.ext rfl ?_
  simp only
  omega

end

end BerggrenHypercycleStars