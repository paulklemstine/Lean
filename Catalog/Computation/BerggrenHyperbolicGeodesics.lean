import Mathlib

/-!
# Hyperbolic geometry of the Berggren / Barning–Hall tree of Pythagorean seeds

Plotting the Berggren tree of Euclid seeds `(m, n)` in the Poincaré disk produces a picture
that is visibly full of *straight lines*.  This file explains that picture with exact theorems.

## Set-up

A Euclid seed `(m, n)` (`0 < n < m`, `gcd (m,n) = 1`, `m + n` odd) is sent to the upper
half-plane point

  `z(m,n) = (n + i)/m`,

so `re = n/m`, `im = 1/m`.  The base point `i` is `z(1,0)`.  All statements below are about
the genuine hyperbolic metric of `UpperHalfPlane` from Mathlib.

## Main results

* `cosh_dist_node` — the **master identity**
  `cosh d(z(m,n), z(m',n')) = 1 + ((n m' - n' m)^2 + (m - m')^2) / (2 m m')`;
  the numerator contains the *determinant* `n m' - n' m` of the two seeds.
* `cosh_dist_base_node` — `cosh d(i, z(m,n)) = (m² + n² + 1)/(2m)`.
* `log_lt_dist_base_node`, `dist_base_node_lt_log` — the **ring theorem**: every seed satisfies
  `½ log c < d(i, z(m,n)) < ½ log (2c)` for `c = m² + n²` the hypotenuse of its triple, i.e.
  the residual `ρ = d - ½ log c` lies in the open interval `(0, ½ log 2)`.
* `gram`, `dist_lt_dist_add_dist_of_gram_pos`, `dist_add_dist_of_gram_zero` — a complete
  *collinearity calculus*: three points of `ℍ` are hyperbolically collinear iff the Gram
  invariant `Φ = 2c₁c₂c₃ - c₁² - c₂² - c₃² + 1` of their `cosh`-distances vanishes.
* `gram_eq_seedDet_sq` — the **arithmetic bridge**: for three seed nodes,
  `Φ = (Δ / (2 m₁m₂m₃))²` where `Δ` is the integer determinant of the rows
  `(nᵢ² + 1, nᵢmᵢ, mᵢ²)`.  Straightness is therefore an integer condition, and
  `gram_quantization` gives the resulting **gap theorem**: non-collinear integer seeds have
  `Φ ≥ 1/(2m₁m₂m₃)²`.
* `pell_collinear`, `dist_base_pellOrbit` — for every `k ≥ 1` the Pell-like conic
  `m² - k m n - n² = 1` carries an infinite orbit of seeds lying on **one exact geodesic**
  through the base point, equally spaced with step `arcosh (1 + k²/2) = 2 log λ_k`,
  `λ_k = (k + √(k²+4))/2` the `k`-th metallic ratio (`exp_step_eq_metallic_sq`).
  For even `k` all orbit points are genuine Euclid seeds (`pellSeeds_infinite`).
* `moveM_moveM_eq_pellStep_two` — the square of the Berggren middle move *is* the `k = 2`
  Pell automorphism, so the even part of the visible Pell spine is an exact geodesic, while
  `gram_middle_spine_eq_one` shows the *odd* part misses collinearity by the universal
  defect `Φ = 1` (`middle_spine_not_collinear`).
* `isLeast_dist_vline`, `isLeast_dist_vline_of_linear` — the **hypercycle theorem**: any
  integral linear relation `A n + B m + C = 0` among seed parameters forces the nodes onto a
  curve at *constant* distance `arsinh |C/A|` from the vertical geodesic `Re = -B/A`.
  Level sets of `n` (preserved by the Berggren right move) and the left spine `n = m - 1` are
  the two families of "straight lines" one sees first.

## Lab notes (numerical experiments preceding the proofs)

* master identity checked against the metric for all `1 ≤ m, m' ≤ 20`: max error `2.9e-15`.
* residual `ρ = d - ½ log c` over all seeds with `m ≤ 400`: range `[3.16e-6, 0.3453220…]`,
  against `½ log 2 = 0.3465735…` — sharp but never attained.
* Pell orbits: `k = 1 : (2,1),(5,3),(13,8),(34,21)`; `k = 2 : (5,2),(29,12),(169,70),(985,408)`;
  `k = 3 : (10,3),(109,33),(1189,360)`.  Collinearity defect `|d₁ + d₂ - d₃| ≤ 4.4e-16`,
  step `cosh` values `1.5, 3, 5.5, 9, 13.5 = 1 + k²/2`, `exp step = 2.618…, 5.828…` `= λ_k²`.
* Gram defect of `(i, (m,n), M(m,n))` on the odd Pell spine `(2,1),(12,5),(70,29),(408,169)`:
  exactly `1` in every case (rational arithmetic) — the source of `gram_middle_spine_eq_one`.
-/

noncomputable section

open UpperHalfPlane Real

namespace BerggrenHyperbolic

/-! ## 1. Seed nodes in the upper half-plane -/

/-- The Euclid seed `(m, n)` as the upper half-plane point `(n + i)/m`.
Junk value `i` when `m ≤ 0`. -/
def node (m n : ℝ) : ℍ :=
  if h : 0 < m then ⟨⟨n / m, 1 / m⟩, by simpa using by positivity⟩ else ⟨⟨0, 1⟩, by norm_num⟩

@[simp] lemma node_re {m : ℝ} (n : ℝ) (hm : 0 < m) : (node m n).re = n / m := by simp [node, hm]

@[simp] lemma node_im {m : ℝ} (n : ℝ) (hm : 0 < m) : (node m n).im = 1 / m := by simp [node, hm]

/-- The base point `i` of the disk picture. -/
def base : ℍ := node 1 0

lemma base_re : base.re = 0 := by simp [base]

lemma base_im : base.im = 1 := by simp [base]

/-- `cosh` of the hyperbolic distance in terms of real and imaginary parts. -/
lemma cosh_dist_re_im (z w : ℍ) :
    Real.cosh (dist z w) = 1 + ((z.re - w.re) ^ 2 + (z.im - w.im) ^ 2) / (2 * z.im * w.im) := by
  rw [UpperHalfPlane.cosh_dist, Complex.dist_eq_re_im, Real.sq_sqrt (by positivity)]
  rfl

/-- The arithmetic kernel attached to a pair of Euclid seeds. -/
def coshK (m n m' n' : ℝ) : ℝ := 1 + ((n * m' - n' * m) ^ 2 + (m - m') ^ 2) / (2 * (m * m'))

/-- **Master identity.**  The hyperbolic distance between two seed nodes is governed by the
determinant `n m' - n' m` of the two seeds together with the difference of their first
coordinates. -/
theorem cosh_dist_node (m n m' n' : ℝ) (hm : 0 < m) (hm' : 0 < m') :
    Real.cosh (dist (node m n) (node m' n')) = coshK m n m' n' := by
  rw [cosh_dist_re_im, node_re _ hm, node_im _ hm, node_re _ hm', node_im _ hm', coshK]
  have h1 : m ≠ 0 := ne_of_gt hm
  have h2 : m' ≠ 0 := ne_of_gt hm'
  field_simp
  ring

lemma one_le_coshK (m n m' n' : ℝ) (hm : 0 < m) (hm' : 0 < m') : 1 ≤ coshK m n m' n' := by
  have : 0 ≤ ((n * m' - n' * m) ^ 2 + (m - m') ^ 2) / (2 * (m * m')) := by positivity
  simpa [coshK] using this

theorem dist_node_eq_arcosh (m n m' n' : ℝ) (hm : 0 < m) (hm' : 0 < m') :
    dist (node m n) (node m' n') = arcosh (coshK m n m' n') := by
  rw [← cosh_dist_node m n m' n' hm hm', Real.arcosh_cosh dist_nonneg]

/-- Distance from the base point `i`: `cosh d = (m² + n² + 1)/(2m)`. -/
theorem cosh_dist_base_node (m n : ℝ) (hm : 0 < m) :
    Real.cosh (dist base (node m n)) = (m ^ 2 + n ^ 2 + 1) / (2 * m) := by
  rw [base, cosh_dist_node 1 0 m n one_pos hm, coshK]
  field_simp
  ring

/-! ## 2. The ring theorem: `½ log c < d(i, z) < ½ log 2c` -/

private lemma sqrt_lt_step (m n c t s : ℝ) (hn : 0 < n) (hm : n + 1 ≤ m) (hc : c = m ^ 2 + n ^ 2)
    (ht : t = (c + 1) / (2 * m)) (hs : s = Real.sqrt c) : s < t + Real.sqrt (t ^ 2 - 1) := by
  have hm0 : 0 < m := by linarith
  have hc0 : 0 < c := by nlinarith
  have hsq : s ^ 2 = c := by rw [hs]; exact Real.sq_sqrt hc0.le
  have hs0 : 0 < s := by rw [hs]; positivity
  have ht1 : 1 ≤ t := by rw [ht, le_div_iff₀ (by linarith)]; nlinarith [sq_nonneg (m - 1)]
  have hsm : m < s := by nlinarith
  have key : (s - t) ^ 2 < t ^ 2 - 1 := by
    have h2ts : s ^ 2 + 1 < 2 * t * s := by
      rw [ht, hsq, show 2 * ((c + 1) / (2 * m)) * s = (c + 1) * s / m by ring, lt_div_iff₀ hm0]
      nlinarith
    nlinarith
  have hpos : 0 < t ^ 2 - 1 := by nlinarith [sq_nonneg (s - t)]
  rcases le_or_gt (s - t) 0 with h | h
  · have : 0 < Real.sqrt (t ^ 2 - 1) := Real.sqrt_pos.2 hpos
    linarith
  · have := (Real.lt_sqrt h.le).2 key
    linarith

private lemma step_lt_sqrt (m n c t S : ℝ) (hn : 1 ≤ n) (hm : n + 1 ≤ m) (hc : c = m ^ 2 + n ^ 2)
    (ht : t = (c + 1) / (2 * m)) (hS : S = Real.sqrt (2 * c)) : t + Real.sqrt (t ^ 2 - 1) < S := by
  have hm0 : 0 < m := by linarith
  have hc0 : 0 < c := by nlinarith
  have hsq : S ^ 2 = 2 * c := by rw [hS]; exact Real.sq_sqrt (by linarith)
  have hS0 : 0 < S := by rw [hS]; positivity
  have ht1 : 1 ≤ t := by rw [ht, le_div_iff₀ (by linarith)]; nlinarith [sq_nonneg (m - 1)]
  have ht0 : 0 < t := by linarith
  have hpoly : 2 * c * (c + 1) ^ 2 < m ^ 2 * (2 * c + 1) ^ 2 := by
    have h1 : 2 * n + 1 ≤ m ^ 2 - n ^ 2 := by nlinarith
    have hcn : n ^ 2 < c := by nlinarith
    have hc1 : (1 : ℝ) ≤ c := by nlinarith
    have hmc : m ^ 2 + 2 * n ^ 2 ≤ 2 * c := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_left h1 (by positivity : (0 : ℝ) ≤ 2 * c ^ 2),
      mul_lt_mul_of_pos_left hcn (by positivity : (0 : ℝ) < 4 * c)]
  have hkey : 2 * t * S < 2 * c + 1 := by
    have h1 : (2 * t * S) ^ 2 < (2 * c + 1) ^ 2 := by
      have e : (2 * t * S) ^ 2 = 4 * t ^ 2 * S ^ 2 := by ring
      rw [e, hsq, ht, div_pow,
        show 4 * ((c + 1) ^ 2 / (2 * m) ^ 2) * (2 * c) = 2 * c * (c + 1) ^ 2 / m ^ 2 by
          field_simp; ring,
        div_lt_iff₀ (by positivity)]
      linarith [hpoly]
    nlinarith [mul_pos (mul_pos two_pos ht0) hS0]
  have hSt : t < S := by nlinarith
  have key : t ^ 2 - 1 < (S - t) ^ 2 := by nlinarith
  have := (Real.sqrt_lt' (by linarith : (0 : ℝ) < S - t)).2 key
  linarith

lemma exp_dist_base_node (m n : ℝ) (hm : 0 < m) :
    Real.exp (dist base (node m n)) =
      (m ^ 2 + n ^ 2 + 1) / (2 * m) + Real.sqrt (((m ^ 2 + n ^ 2 + 1) / (2 * m)) ^ 2 - 1) := by
  have ht1 : 1 ≤ (m ^ 2 + n ^ 2 + 1) / (2 * m) := by
    rw [le_div_iff₀ (by linarith)]; nlinarith [sq_nonneg (m - 1), sq_nonneg n]
  rw [← Real.exp_arcosh ht1, ← cosh_dist_base_node m n hm, Real.arcosh_cosh dist_nonneg]

/-- **Ring theorem, lower half.**  Every seed node sits strictly outside the hyperbolic circle of
radius `½ log c`, `c = m² + n²` being the hypotenuse of the corresponding Pythagorean triple. -/
theorem log_lt_dist_base_node (m n : ℝ) (hn : 0 < n) (hm : n + 1 ≤ m) :
    Real.log (m ^ 2 + n ^ 2) / 2 < dist base (node m n) := by
  have hm0 : 0 < m := by linarith
  have hc0 : 0 < m ^ 2 + n ^ 2 := by positivity
  have h := sqrt_lt_step m n (m ^ 2 + n ^ 2) ((m ^ 2 + n ^ 2 + 1) / (2 * m))
    (Real.sqrt (m ^ 2 + n ^ 2)) hn hm rfl rfl rfl
  rw [← exp_dist_base_node m n hm0] at h
  have := Real.log_lt_log (by positivity) h
  rwa [Real.log_exp, Real.log_sqrt hc0.le] at this

/-- **Ring theorem, upper half.**  Every seed node sits strictly inside the hyperbolic circle of
radius `½ log (2c)`; equivalently the residual `d - ½ log c` is `< ½ log 2`. -/
theorem dist_base_node_lt_log (m n : ℝ) (hn : 1 ≤ n) (hm : n + 1 ≤ m) :
    dist base (node m n) < Real.log (2 * (m ^ 2 + n ^ 2)) / 2 := by
  have hm0 : 0 < m := by linarith
  have hc0 : 0 < m ^ 2 + n ^ 2 := by positivity
  have h := step_lt_sqrt m n (m ^ 2 + n ^ 2) ((m ^ 2 + n ^ 2 + 1) / (2 * m))
    (Real.sqrt (2 * (m ^ 2 + n ^ 2))) hn hm rfl rfl rfl
  rw [← exp_dist_base_node m n hm0] at h
  have := Real.log_lt_log (Real.exp_pos _) h
  rwa [Real.log_exp, Real.log_sqrt (by positivity)] at this

/-- The residual `ρ = d - ½ log c` of a seed node lies in the open interval `(0, ½ log 2)`. -/
theorem residual_mem_Ioo (m n : ℝ) (hn : 1 ≤ n) (hm : n + 1 ≤ m) :
    dist base (node m n) - Real.log (m ^ 2 + n ^ 2) / 2 ∈ Set.Ioo 0 (Real.log 2 / 2) := by
  have hc0 : (0 : ℝ) < m ^ 2 + n ^ 2 := by nlinarith
  constructor
  · linarith [log_lt_dist_base_node m n (by linarith) hm]
  · have h := dist_base_node_lt_log m n hn hm
    rw [Real.log_mul two_ne_zero (by positivity)] at h
    linarith

/-! ## 3. A collinearity calculus: the Gram invariant -/

/-- The Gram (Cayley–Menger) invariant of three `cosh`-distances. -/
def gram (c₁ c₂ c₃ : ℝ) : ℝ := 2 * c₁ * c₂ * c₃ - c₁ ^ 2 - c₂ ^ 2 - c₃ ^ 2 + 1

lemma sinh_dist_eq (z w : ℍ) :
    Real.sinh (dist z w) = Real.sqrt (Real.cosh (dist z w) ^ 2 - 1) := by
  rw [show Real.cosh (dist z w) ^ 2 - 1 = Real.sinh (dist z w) ^ 2 by
    nlinarith [Real.cosh_sq_sub_sinh_sq (dist z w)]]
  exact (Real.sqrt_sq (sinh_nonneg_iff.mpr dist_nonneg)).symm

lemma cosh_dist_add (P Q R : ℍ) :
    Real.cosh (dist P Q + dist Q R)
      = Real.cosh (dist P Q) * Real.cosh (dist Q R)
        + Real.sqrt ((Real.cosh (dist P Q) ^ 2 - 1) * (Real.cosh (dist Q R) ^ 2 - 1)) := by
  rw [Real.cosh_add, sinh_dist_eq P Q, sinh_dist_eq Q R,
    ← Real.sqrt_mul (by nlinarith [Real.one_le_cosh (dist P Q)])]

/-- Positive Gram invariant means a genuine (non-degenerate) hyperbolic triangle: the triangle
inequality is strict. -/
theorem dist_lt_dist_add_dist_of_gram_pos (P Q R : ℍ)
    (h : 0 < gram (Real.cosh (dist P Q)) (Real.cosh (dist Q R)) (Real.cosh (dist P R))) :
    dist P R < dist P Q + dist Q R := by
  have h1 := Real.one_le_cosh (dist P Q)
  have h2 := Real.one_le_cosh (dist Q R)
  set c₁ := Real.cosh (dist P Q)
  set c₂ := Real.cosh (dist Q R)
  set c₃ := Real.cosh (dist P R)
  have hX : |c₃ - c₁ * c₂| ^ 2 < (c₁ ^ 2 - 1) * (c₂ ^ 2 - 1) := by
    rw [sq_abs]; simp only [gram] at h; nlinarith
  have hsqrt : |c₃ - c₁ * c₂| < Real.sqrt ((c₁ ^ 2 - 1) * (c₂ ^ 2 - 1)) :=
    (Real.lt_sqrt (abs_nonneg _)).2 hX
  have hlt : c₃ < Real.cosh (dist P Q + dist Q R) := by
    rw [cosh_dist_add]
    have := le_abs_self (c₃ - c₁ * c₂)
    linarith
  have h3 := Real.cosh_lt_cosh.1 hlt
  rwa [abs_of_nonneg dist_nonneg,
    abs_of_nonneg (by positivity : (0 : ℝ) ≤ dist P Q + dist Q R)] at h3

/-- Vanishing Gram invariant (with the correct ordering) means the three points are
hyperbolically collinear, `Q` lying on the geodesic segment from `P` to `R`. -/
theorem dist_add_dist_of_gram_zero (P Q R : ℍ)
    (h : gram (Real.cosh (dist P Q)) (Real.cosh (dist Q R)) (Real.cosh (dist P R)) = 0)
    (hle : Real.cosh (dist P Q) * Real.cosh (dist Q R) ≤ Real.cosh (dist P R)) :
    dist P Q + dist Q R = dist P R := by
  have h1 := Real.one_le_cosh (dist P Q)
  have h2 := Real.one_le_cosh (dist Q R)
  set c₁ := Real.cosh (dist P Q)
  set c₂ := Real.cosh (dist Q R)
  set c₃ := Real.cosh (dist P R)
  have hX : (c₁ ^ 2 - 1) * (c₂ ^ 2 - 1) = (c₃ - c₁ * c₂) ^ 2 := by
    simp only [gram] at h; nlinarith
  have hc : Real.cosh (dist P Q + dist Q R) = c₃ := by
    rw [cosh_dist_add, hX, Real.sqrt_sq (by linarith)]; ring
  exact Real.cosh_injOn (Set.mem_Ici.2 (by positivity)) (Set.mem_Ici.2 dist_nonneg) hc

/-- Conversely, collinear points have vanishing Gram invariant. -/
theorem gram_eq_zero_of_dist_add_dist (P Q R : ℍ) (h : dist P Q + dist Q R = dist P R) :
    gram (Real.cosh (dist P Q)) (Real.cosh (dist Q R)) (Real.cosh (dist P R)) = 0 := by
  have h1 := Real.one_le_cosh (dist P Q)
  have h2 := Real.one_le_cosh (dist Q R)
  have key := cosh_dist_add P Q R
  rw [h] at key
  set c₁ := Real.cosh (dist P Q)
  set c₂ := Real.cosh (dist Q R)
  set c₃ := Real.cosh (dist P R)
  have hp : (0 : ℝ) ≤ (c₁ ^ 2 - 1) * (c₂ ^ 2 - 1) := mul_nonneg (by nlinarith) (by nlinarith)
  have hs : Real.sqrt ((c₁ ^ 2 - 1) * (c₂ ^ 2 - 1)) = c₃ - c₁ * c₂ := by linarith
  have h4 := Real.sq_sqrt hp
  rw [hs] at h4
  simp only [gram]; nlinarith

/-! ## 4. The arithmetic bridge: straightness is an integer determinant -/

/-- The `3 × 3` determinant with rows `(nᵢ² + 1, nᵢ mᵢ, mᵢ²)` attached to three Euclid seeds.
It vanishes exactly when the three half-plane points lie on one circle centred on the real
axis, i.e. on one hyperbolic geodesic. -/
def seedDet (m₁ n₁ m₂ n₂ m₃ n₃ : ℝ) : ℝ :=
  (n₁ ^ 2 + 1) * ((n₂ * m₂) * m₃ ^ 2 - m₂ ^ 2 * (n₃ * m₃))
    - (n₁ * m₁) * ((n₂ ^ 2 + 1) * m₃ ^ 2 - m₂ ^ 2 * (n₃ ^ 2 + 1))
    + m₁ ^ 2 * ((n₂ ^ 2 + 1) * (n₃ * m₃) - (n₂ * m₂) * (n₃ ^ 2 + 1))

/-- **Arithmetic bridge.**  The (transcendentally defined) Gram invariant of three seed nodes is
the square of a purely arithmetic determinant, divided by `(2 m₁ m₂ m₃)²`. -/
theorem gram_eq_seedDet_sq (m₁ n₁ m₂ n₂ m₃ n₃ : ℝ) (h₁ : m₁ ≠ 0) (h₂ : m₂ ≠ 0) (h₃ : m₃ ≠ 0) :
    gram (coshK m₁ n₁ m₂ n₂) (coshK m₂ n₂ m₃ n₃) (coshK m₁ n₁ m₃ n₃)
      = (seedDet m₁ n₁ m₂ n₂ m₃ n₃ / (2 * m₁ * m₂ * m₃)) ^ 2 := by
  unfold gram coshK seedDet
  field_simp
  ring

/-- The Gram invariant of three seed nodes is always `≥ 0`. -/
theorem gram_nonneg_node (m₁ n₁ m₂ n₂ m₃ n₃ : ℝ) (h₁ : 0 < m₁) (h₂ : 0 < m₂) (h₃ : 0 < m₃) :
    0 ≤ gram (Real.cosh (dist (node m₁ n₁) (node m₂ n₂)))
      (Real.cosh (dist (node m₂ n₂) (node m₃ n₃)))
      (Real.cosh (dist (node m₁ n₁) (node m₃ n₃))) := by
  rw [cosh_dist_node _ _ _ _ h₁ h₂, cosh_dist_node _ _ _ _ h₂ h₃, cosh_dist_node _ _ _ _ h₁ h₃,
    gram_eq_seedDet_sq _ _ _ _ _ _ h₁.ne' h₂.ne' h₃.ne']
  positivity

/-- **Quantization of straightness.**  For *integer* seeds, either the three nodes are exactly
collinear, or their Gram defect is at least `1/(2m₁m₂m₃)²`: near-lines in the picture cannot be
arbitrarily close to lines without being lines. -/
theorem gram_quantization (m₁ n₁ m₂ n₂ m₃ n₃ : ℤ) (h₁ : 0 < m₁) (h₂ : 0 < m₂) (h₃ : 0 < m₃)
    (hne : seedDet (m₁ : ℝ) n₁ m₂ n₂ m₃ n₃ ≠ 0) :
    1 / (2 * (m₁ : ℝ) * m₂ * m₃) ^ 2 ≤
      gram (Real.cosh (dist (node (m₁ : ℝ) n₁) (node (m₂ : ℝ) n₂)))
        (Real.cosh (dist (node (m₂ : ℝ) n₂) (node (m₃ : ℝ) n₃)))
        (Real.cosh (dist (node (m₁ : ℝ) n₁) (node (m₃ : ℝ) n₃))) := by
  have e₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast h₁
  have e₂ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast h₂
  have e₃ : (0 : ℝ) < (m₃ : ℝ) := by exact_mod_cast h₃
  -- the determinant is an integer, hence `≥ 1` in absolute value once it is nonzero
  set Dz : ℤ := (n₁ ^ 2 + 1) * ((n₂ * m₂) * m₃ ^ 2 - m₂ ^ 2 * (n₃ * m₃))
    - (n₁ * m₁) * ((n₂ ^ 2 + 1) * m₃ ^ 2 - m₂ ^ 2 * (n₃ ^ 2 + 1))
    + m₁ ^ 2 * ((n₂ ^ 2 + 1) * (n₃ * m₃) - (n₂ * m₂) * (n₃ ^ 2 + 1)) with hDz
  have hcast : seedDet (m₁ : ℝ) n₁ m₂ n₂ m₃ n₃ = (Dz : ℝ) := by
    simp only [seedDet, hDz]; push_cast; ring
  have hDz0 : Dz ≠ 0 := by
    intro h; rw [h] at hcast; simp at hcast; exact hne hcast
  have h1le : (1 : ℝ) ≤ |(Dz : ℝ)| := by
    rw [← Int.cast_abs]
    exact_mod_cast Int.one_le_abs (by omega)
  rw [cosh_dist_node _ _ _ _ e₁ e₂, cosh_dist_node _ _ _ _ e₂ e₃, cosh_dist_node _ _ _ _ e₁ e₃,
    gram_eq_seedDet_sq _ _ _ _ _ _ e₁.ne' e₂.ne' e₃.ne', div_pow, hcast]
  have hpos : (0 : ℝ) < (2 * (m₁ : ℝ) * m₂ * m₃) ^ 2 := by positivity
  rw [div_le_div_iff_of_pos_right hpos]
  nlinarith [sq_abs ((Dz : ℝ)), abs_nonneg ((Dz : ℝ))]

/-! ## 5. Pell conics give exact geodesics through the base point -/

/-- The automorphism of the conic `m² - k m n - n² = 1`. -/
def pellStep (k : ℤ) (p : ℤ × ℤ) : ℤ × ℤ := ((k ^ 2 + 1) * p.1 + k * p.2, k * p.1 + p.2)

/-- The forward orbit of `(1,0)` (the base point) under `pellStep k`. -/
def pellOrbit (k : ℤ) : ℕ → ℤ × ℤ
  | 0 => (1, 0)
  | j + 1 => pellStep k (pellOrbit k j)

/-- Membership in the Pell-like conic `m² - k m n - n² = 1`. -/
def OnConic (k : ℤ) (p : ℤ × ℤ) : Prop := p.1 ^ 2 - k * p.1 * p.2 - p.2 ^ 2 = 1

theorem isCoprime_of_onConic {k : ℤ} {p : ℤ × ℤ} (h : OnConic k p) : IsCoprime p.1 p.2 :=
  ⟨p.1 - k * p.2, -p.2, by simp only [OnConic] at h; nlinarith [h]⟩

theorem onConic_pellStep {k : ℤ} {p : ℤ × ℤ} (h : OnConic k p) : OnConic k (pellStep k p) := by
  obtain ⟨m, n⟩ := p
  simp only [OnConic, pellStep] at *
  nlinarith [h]

theorem onConic_pellOrbit (k : ℤ) (j : ℕ) : OnConic k (pellOrbit k j) := by
  induction j with
  | zero => simp [OnConic, pellOrbit]
  | succ j ih => exact onConic_pellStep ih

theorem pellOrbit_pos (k : ℤ) (hk : 0 < k) (j : ℕ) :
    0 < (pellOrbit k j).1 ∧ 0 ≤ (pellOrbit k j).2 := by
  induction j with
  | zero => simp [pellOrbit]
  | succ j ih =>
      obtain ⟨h1, h2⟩ := ih
      exact ⟨by simp only [pellOrbit, pellStep]; positivity,
        by simp only [pellOrbit, pellStep]; positivity⟩

theorem pellOrbit_strictMono (k : ℤ) (hk : 0 < k) (j : ℕ) :
    (pellOrbit k j).1 < (pellOrbit k (j + 1)).1 := by
  obtain ⟨h1, h2⟩ := pellOrbit_pos k hk j
  simp only [pellOrbit, pellStep]
  nlinarith

/-- For even `k`, the Pell automorphism preserves the property of being a Euclid seed. -/
theorem pellStep_isSeed {k : ℤ} (hk : 0 < k) (hke : Even k) {p : ℤ × ℤ} (hc : OnConic k p)
    (hs : 0 < p.2 ∧ p.2 < p.1 ∧ Odd (p.1 + p.2)) :
    0 < (pellStep k p).2 ∧ (pellStep k p).2 < (pellStep k p).1 ∧
      Odd ((pellStep k p).1 + (pellStep k p).2) := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, ho⟩ := hs
  simp only at hn hlt ho
  obtain ⟨t, ht⟩ := ho
  obtain ⟨s, hs2⟩ := hke
  subst hs2
  have hm : 0 < m := lt_trans hn hlt
  have hs1 : 1 ≤ s := by omega
  have e1 : (0 : ℤ) ≤ (4 * s ^ 2 - 2 * s) * m := mul_nonneg (by nlinarith) hm.le
  have e2 : (0 : ℤ) ≤ (2 * s - 1) * n := mul_nonneg (by omega) hn.le
  refine ⟨by simp only [pellStep]; nlinarith, by simp only [pellStep]; nlinarith [e1, e2],
    ⟨t + (2 * s ^ 2 + s) * m + s * n, ?_⟩⟩
  simp only [pellStep]
  linear_combination ht

/-! ### Geometry of the Pell orbit -/

section PellGeometry

variable {k m n : ℝ}

lemma cosh_dist_base_conic (hm : 0 < m)
    (hc : m ^ 2 - k * m * n - n ^ 2 = 1) :
    Real.cosh (dist base (node m n)) = (2 * m - k * n) / 2 := by
  rw [cosh_dist_base_node m n hm, show m ^ 2 + n ^ 2 + 1 = m * (2 * m - k * n) by nlinarith]
  field_simp

lemma cosh_dist_pellStep (hk : 0 < k) (hm : 0 < m) (hn : 0 ≤ n)
    (hc : m ^ 2 - k * m * n - n ^ 2 = 1) :
    Real.cosh (dist (node m n) (node ((k ^ 2 + 1) * m + k * n) (k * m + n))) = (k ^ 2 + 2) / 2 := by
  have hm' : 0 < (k ^ 2 + 1) * m + k * n := by positivity
  rw [cosh_dist_node m n _ _ hm hm', coshK,
    show n * ((k ^ 2 + 1) * m + k * n) - (k * m + n) * m = -k by nlinarith,
    show m - ((k ^ 2 + 1) * m + k * n) = -(k * (k * m + n)) by ring,
    show m * ((k ^ 2 + 1) * m + k * n) = 1 + (k * m + n) ^ 2 by nlinarith]
  have h : (0 : ℝ) < 1 + (k * m + n) ^ 2 := by positivity
  field_simp
  ring

lemma cosh_dist_base_pellStep (hk : 0 < k) (hm : 0 < m) (hn : 0 ≤ n)
    (hc : m ^ 2 - k * m * n - n ^ 2 = 1) :
    Real.cosh (dist base (node ((k ^ 2 + 1) * m + k * n) (k * m + n)))
      = ((k ^ 2 + 2) * m + k * n) / 2 := by
  have hm' : 0 < (k ^ 2 + 1) * m + k * n := by positivity
  have hc' : ((k ^ 2 + 1) * m + k * n) ^ 2 - k * ((k ^ 2 + 1) * m + k * n) * (k * m + n)
      - (k * m + n) ^ 2 = 1 := by nlinarith
  rw [cosh_dist_base_conic hm' hc']
  ring

/-- **Pell collinearity.**  If `(m, n)` lies on the conic `m² - k m n - n² = 1`, then the base
point `i`, the node of `(m, n)` and the node of its Pell successor are hyperbolically collinear:
the distances add exactly. -/
theorem pell_collinear (hk : 0 < k) (hm : 0 < m) (hn : 0 ≤ n)
    (hc : m ^ 2 - k * m * n - n ^ 2 = 1) :
    dist base (node m n) + dist (node m n) (node ((k ^ 2 + 1) * m + k * n) (k * m + n))
      = dist base (node ((k ^ 2 + 1) * m + k * n) (k * m + n)) := by
  have h1 := cosh_dist_base_conic hm hc
  have h2 := cosh_dist_pellStep hk hm hn hc
  have h3 := cosh_dist_base_pellStep hk hm hn hc
  refine dist_add_dist_of_gram_zero _ _ _ ?_ ?_
  · rw [h1, h2, h3]
    simp only [gram]
    nlinarith [hc]
  · rw [h1, h2, h3]
    nlinarith [mul_nonneg hk.le hn]

end PellGeometry

/-- The constant step length of a Pell orbit. -/
def pellStepLength (k : ℝ) : ℝ := arcosh (1 + k ^ 2 / 2)

/-- The step length is twice the logarithm of the `k`-th metallic ratio
`λ_k = (k + √(k²+4))/2`, the root of `λ² = kλ + 1`. -/
theorem exp_step_eq_metallic_sq (k : ℝ) (hk : 0 < k) :
    Real.exp (pellStepLength k) = ((k + Real.sqrt (k ^ 2 + 4)) / 2) ^ 2 := by
  have h4 : Real.sqrt (k ^ 2 + 4) ^ 2 = k ^ 2 + 4 := Real.sq_sqrt (by positivity)
  have h1 : (1 : ℝ) ≤ 1 + k ^ 2 / 2 := by nlinarith
  rw [pellStepLength, Real.exp_arcosh h1,
    show (1 + k ^ 2 / 2) ^ 2 - 1 = (k * Real.sqrt (k ^ 2 + 4) / 2) ^ 2 by
      field_simp; nlinarith [h4],
    Real.sqrt_sq (by positivity)]
  nlinarith [h4]

lemma dist_pellStep_eq (k m n : ℝ) (hk : 0 < k) (hm : 0 < m) (hn : 0 ≤ n)
    (hc : m ^ 2 - k * m * n - n ^ 2 = 1) :
    dist (node m n) (node ((k ^ 2 + 1) * m + k * n) (k * m + n)) = pellStepLength k := by
  rw [← Real.arcosh_cosh (dist_nonneg (x := node m n)), cosh_dist_pellStep hk hm hn hc,
    pellStepLength]
  congr 1
  ring

/-- **The Pell orbit is a discrete geodesic ray.**  The `j`-th point of the orbit of the base
point under the conic automorphism sits at distance exactly `j` times the step length; all the
orbit points therefore lie on one geodesic through `i`, equally spaced. -/
theorem dist_base_pellOrbit (k : ℤ) (hk : 0 < k) (j : ℕ) :
    dist base (node ((pellOrbit k j).1 : ℝ) ((pellOrbit k j).2 : ℝ))
      = j * pellStepLength (k : ℝ) := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  induction j with
  | zero => simp [pellOrbit, base]
  | succ j ih =>
      obtain ⟨hp1, hp2⟩ := pellOrbit_pos k hk j
      have hm : (0 : ℝ) < ((pellOrbit k j).1 : ℝ) := by exact_mod_cast hp1
      have hn : (0 : ℝ) ≤ ((pellOrbit k j).2 : ℝ) := by exact_mod_cast hp2
      have hc : ((pellOrbit k j).1 : ℝ) ^ 2 - (k : ℝ) * ((pellOrbit k j).1 : ℝ)
          * ((pellOrbit k j).2 : ℝ) - ((pellOrbit k j).2 : ℝ) ^ 2 = 1 := by
        have := onConic_pellOrbit k j
        simp only [OnConic] at this
        exact_mod_cast congrArg (fun x : ℤ => (x : ℝ)) this
      have e1 : ((pellOrbit k (j + 1)).1 : ℝ)
          = ((k : ℝ) ^ 2 + 1) * ((pellOrbit k j).1 : ℝ) + (k : ℝ) * ((pellOrbit k j).2 : ℝ) := by
        simp only [pellOrbit, pellStep]; push_cast; ring
      have e2 : ((pellOrbit k (j + 1)).2 : ℝ)
          = (k : ℝ) * ((pellOrbit k j).1 : ℝ) + ((pellOrbit k j).2 : ℝ) := by
        simp only [pellOrbit, pellStep]; push_cast; ring
      rw [e1, e2, ← pell_collinear hkR hm hn hc, ih, dist_pellStep_eq _ _ _ hkR hm hn hc]
      push_cast
      ring

/-- For even `k ≥ 2`, every point of the Pell orbit (from the first one on) is a genuine Euclid
seed, so the geodesic through `i` of `pell_collinear` carries infinitely many seeds. -/
theorem pellOrbit_isSeed (k : ℤ) (hk : 0 < k) (hke : Even k) (j : ℕ) :
    0 < (pellOrbit k (j + 1)).2 ∧ (pellOrbit k (j + 1)).2 < (pellOrbit k (j + 1)).1 ∧
      Odd ((pellOrbit k (j + 1)).1 + (pellOrbit k (j + 1)).2) := by
  induction j with
  | zero =>
      obtain ⟨s, hs⟩ := hke
      refine ⟨by simp [pellOrbit, pellStep]; omega, by simp [pellOrbit, pellStep]; nlinarith,
        ⟨(k ^ 2 + k) / 2, ?_⟩⟩
      simp only [pellOrbit, pellStep]
      subst hs
      ring_nf
      omega
  | succ j ih => exact pellStep_isSeed hk hke (onConic_pellOrbit k (j + 1)) ih

/-- The seeds on the `k`-geodesic form an infinite set (`k` even, `k > 0`). -/
theorem pellSeeds_infinite (k : ℤ) (hk : 0 < k) (hke : Even k) :
    {p : ℤ × ℤ | OnConic k p ∧ 0 < p.2 ∧ p.2 < p.1 ∧ Odd (p.1 + p.2)}.Infinite := by
  have hmono : StrictMono fun j : ℕ => (pellOrbit k (j + 1)).1 := by
    apply strictMono_nat_of_lt_succ
    intro j
    exact pellOrbit_strictMono k hk (j + 1)
  refine Set.infinite_of_injective_forall_mem
    (f := fun j : ℕ => pellOrbit k (j + 1)) (fun a b hab => ?_) (fun j => ?_)
  · exact hmono.injective (congrArg Prod.fst hab)
  · exact ⟨onConic_pellOrbit k (j + 1), pellOrbit_isSeed k hk hke j⟩

/-! ## 6. The Berggren tree: moves, spines, and the exact/inexact lines -/

/-- Berggren left move on Euclid seeds. -/
def moveL (p : ℤ × ℤ) : ℤ × ℤ := (2 * p.1 - p.2, p.1)
/-- Berggren middle move on Euclid seeds. -/
def moveM (p : ℤ × ℤ) : ℤ × ℤ := (2 * p.1 + p.2, p.1)
/-- Berggren right move on Euclid seeds. -/
def moveR (p : ℤ × ℤ) : ℤ × ℤ := (p.1 + 2 * p.2, p.2)

/-- Being a Euclid seed: `0 < n < m`, coprime, opposite parity. -/
structure IsSeed (m n : ℤ) : Prop where
  npos : 0 < n
  lt : n < m
  cop : IsCoprime m n
  odd : Odd (m + n)

theorem isSeed_moveL {m n : ℤ} (h : IsSeed m n) : IsSeed (moveL (m, n)).1 (moveL (m, n)).2 := by
  obtain ⟨hn, hlt, ⟨a, b, hab⟩, ho⟩ := h
  refine ⟨by simp [moveL]; omega, by simp [moveL]; omega,
    ⟨-b, a + 2 * b, by simp [moveL]; ring_nf; linarith [hab]⟩, ?_⟩
  obtain ⟨t, ht⟩ := ho
  exact ⟨2 * m - t - 1, by simp [moveL]; omega⟩

theorem isSeed_moveM {m n : ℤ} (h : IsSeed m n) : IsSeed (moveM (m, n)).1 (moveM (m, n)).2 := by
  obtain ⟨hn, hlt, ⟨a, b, hab⟩, ho⟩ := h
  refine ⟨by simp [moveM]; omega, by simp [moveM]; omega,
    ⟨b, a - 2 * b, by simp [moveM]; ring_nf; linarith [hab]⟩, ?_⟩
  obtain ⟨t, ht⟩ := ho
  exact ⟨m + t, by simp [moveM]; omega⟩

theorem isSeed_moveR {m n : ℤ} (h : IsSeed m n) : IsSeed (moveR (m, n)).1 (moveR (m, n)).2 := by
  obtain ⟨hn, hlt, ⟨a, b, hab⟩, ho⟩ := h
  refine ⟨by simp [moveR]; omega, by simp [moveR]; omega,
    ⟨a, b - 2 * a, by simp [moveR]; ring_nf; linarith [hab]⟩, ?_⟩
  obtain ⟨t, ht⟩ := ho
  exact ⟨t + n, by simp [moveR]; omega⟩

/-- **The square of the Berggren middle move is the `k = 2` Pell automorphism.**  Hence every
second point of the visible "Pell spine" lies on one exact geodesic through `i`. -/
theorem moveM_moveM_eq_pellStep_two (p : ℤ × ℤ) : moveM (moveM p) = pellStep 2 p := by
  obtain ⟨m, n⟩ := p
  simp only [moveM, pellStep, Prod.mk.injEq]
  exact ⟨by ring, trivial⟩

/-- **Universal defect of the odd Pell spine.**  For a point of the *other* branch of the middle
spine (`m² - 2mn - n² = -1`), the triangle `(i, node, moveM node)` has Gram invariant exactly
`1` — the spine looks straight but misses collinearity by a universal quantum. -/
theorem gram_middle_spine_eq_one (m n : ℝ) (hm : 0 < m) (hn : 0 < n)
    (hc : m ^ 2 - 2 * m * n - n ^ 2 = -1) :
    gram (Real.cosh (dist base (node m n)))
      (Real.cosh (dist (node m n) (node (2 * m + n) m)))
      (Real.cosh (dist base (node (2 * m + n) m))) = 1 := by
  have hm' : (0 : ℝ) < 2 * m + n := by linarith
  have h1 : Real.cosh (dist base (node m n)) = n * (m + n) / m := by
    rw [cosh_dist_base_node m n hm, show m ^ 2 + n ^ 2 + 1 = 2 * n * (m + n) by nlinarith]
    field_simp
  have h2 : Real.cosh (dist (node m n) (node (2 * m + n) m)) = (m + n) / m := by
    rw [cosh_dist_node m n _ _ hm hm', coshK,
      show n * (2 * m + n) - m * m = 1 by nlinarith,
      show m - (2 * m + n) = -(m + n) by ring,
      show (1 : ℝ) ^ 2 + (-(m + n)) ^ 2 = 2 * n * (2 * m + n) by nlinarith]
    field_simp
  have h3 : Real.cosh (dist base (node (2 * m + n) m)) = m + n := by
    rw [cosh_dist_base_node _ _ hm',
      show (2 * m + n) ^ 2 + m ^ 2 + 1 = 2 * (2 * m + n) * (m + n) by nlinarith]
    field_simp
  have hid : gram (n * (m + n) / m) ((m + n) / m) (m + n) - 1
      = -(m + n) ^ 2 * (m ^ 2 - 2 * m * n - n ^ 2 + 1) / m ^ 2 := by
    simp only [gram]
    field_simp
    ring
  rw [hc] at hid
  rw [h1, h2, h3]
  simp only [neg_add_cancel, mul_zero, zero_div] at hid
  linarith

/-- Consequently the odd middle-spine triangle is genuinely non-degenerate. -/
theorem middle_spine_not_collinear (m n : ℝ) (hm : 0 < m) (hn : 0 < n)
    (hc : m ^ 2 - 2 * m * n - n ^ 2 = -1) :
    dist base (node (2 * m + n) m) < dist base (node m n) + dist (node m n) (node (2 * m + n) m) :=
  dist_lt_dist_add_dist_of_gram_pos _ _ _ (by rw [gram_middle_spine_eq_one m n hm hn hc]; norm_num)

/-! ## 7. Hypercycles: why linear relations among seeds look like straight lines -/

/-- The complete vertical geodesic `Re = a` of the upper half-plane. -/
def vline (a : ℝ) : Set ℍ := {w : ℍ | w.re = a}

/-- **Distance to a vertical geodesic.**  The infimum is attained and equals
`arsinh (|x - a| / y)`. -/
theorem isLeast_dist_vline (z : ℍ) (a : ℝ) :
    IsLeast ((fun w => dist z w) '' vline a) (arsinh (|z.re - a| / z.im)) := by
  have hy : 0 < z.im := z.2
  set D := z.re - a with hD
  set v₀ := Real.sqrt (D ^ 2 + z.im ^ 2) with hv₀
  have hv₀0 : 0 < v₀ := by rw [hv₀]; positivity
  have hv₀sq : v₀ ^ 2 = D ^ 2 + z.im ^ 2 := Real.sq_sqrt (by positivity)
  have hnn : (0 : ℝ) ≤ |D| / z.im := by positivity
  have hcosh_arsinh : Real.cosh (arsinh (|D| / z.im)) = v₀ / z.im := by
    rw [Real.cosh_arsinh, show 1 + (|D| / z.im) ^ 2 = (v₀ / z.im) ^ 2 by
      rw [div_pow, sq_abs, div_pow, hv₀sq]; field_simp; ring]
    exact Real.sqrt_sq (by positivity)
  constructor
  · refine ⟨⟨⟨a, v₀⟩, hv₀0⟩, rfl, ?_⟩
    have hc : Real.cosh (dist z (⟨⟨a, v₀⟩, hv₀0⟩ : ℍ)) = v₀ / z.im := by
      rw [cosh_dist_re_im]
      show 1 + ((z.re - a) ^ 2 + (z.im - v₀) ^ 2) / (2 * z.im * v₀) = v₀ / z.im
      rw [← hD]
      field_simp
      nlinarith [hv₀sq]
    exact Real.cosh_injOn (Set.mem_Ici.2 dist_nonneg)
      (Set.mem_Ici.2 (arsinh_nonneg_iff.2 hnn)) (by rw [hc, hcosh_arsinh])
  · rintro d ⟨w, hw, rfl⟩
    have hwre : w.re = a := hw
    have hwim : 0 < w.im := w.2
    have hge : Real.cosh (arsinh (|D| / z.im)) ≤ Real.cosh (dist z w) := by
      rw [hcosh_arsinh, cosh_dist_re_im, hwre, ← hD, div_le_iff₀ hy, ← sub_nonneg]
      have key : (1 + (D ^ 2 + (z.im - w.im) ^ 2) / (2 * z.im * w.im)) * z.im - v₀
          = (v₀ - w.im) ^ 2 / (2 * w.im) := by
        field_simp
        nlinarith [hv₀sq]
      rw [key]; positivity
    have h2 := Real.cosh_le_cosh.1 hge
    rwa [abs_of_nonneg (arsinh_nonneg_iff.2 hnn), abs_of_nonneg dist_nonneg] at h2

/-- **Hypercycle theorem.**  Any linear relation `A n + B m + C = 0` among the Euclid parameters
puts the corresponding node at the *constant* distance `arsinh |C/A|` from the vertical geodesic
`Re = -B/A`, independently of the node.  Such a level set is therefore an exact equidistant curve
— a curve of constant geodesic curvature, which is what "straight line" means in the picture. -/
theorem isLeast_dist_vline_of_linear (A B C m n : ℝ) (hA : A ≠ 0) (hm : 0 < m)
    (hrel : A * n + B * m + C = 0) :
    IsLeast ((fun w => dist (node m n) w) '' vline (-B / A)) (arsinh |C / A|) := by
  have h := isLeast_dist_vline (node m n) (-B / A)
  rwa [node_re _ hm, node_im _ hm,
    show |n / m - -B / A| / (1 / m) = |C / A| by
      rw [show n / m - -B / A = -(C / A) / m by field_simp; linarith]
      rw [abs_div, abs_neg, abs_of_pos hm]
      field_simp] at h

/-- Level sets of `n` (which the Berggren right move preserves) are exact hypercycles: every seed
with second coordinate `n ≥ 0` lies at distance exactly `arsinh n` from the geodesic `Re = 0`. -/
theorem isLeast_dist_vline_zero (m n : ℝ) (hm : 0 < m) (hn : 0 ≤ n) :
    IsLeast ((fun w => dist (node m n) w) '' vline 0) (arsinh n) := by
  have h := isLeast_dist_vline_of_linear 1 0 (-n) m n one_ne_zero hm (by ring)
  simpa [abs_of_nonneg hn] using h

/-- The Berggren right move slides a node along its hypercycle: the whole right spine of any node
stays at the same distance `arsinh n` from the geodesic `Re = 0`. -/
theorem moveR_dist_invariant (m n : ℝ) (hm : 0 < m) (hn : 0 ≤ n) :
    IsLeast ((fun w => dist (node (m + 2 * n) n) w) '' vline 0) (arsinh n) :=
  isLeast_dist_vline_zero (m + 2 * n) n (by linarith) hn

/-- The left spine `(m, m-1)` lies on the Euclidean line `x + y = 1` of the half-plane, i.e. at
constant distance `arsinh 1` from the geodesic `Re = 1`. -/
theorem left_spine_hypercycle (m : ℝ) (hm : 0 < m) :
    IsLeast ((fun w => dist (node m (m - 1)) w) '' vline 1) (arsinh 1) := by
  have h := isLeast_dist_vline_of_linear 1 (-1) 1 m (m - 1) one_ne_zero hm (by ring)
  simpa using h

end BerggrenHyperbolic