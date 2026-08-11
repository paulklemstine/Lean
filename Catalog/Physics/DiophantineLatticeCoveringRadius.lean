import Physics.DiophantineLatticeBinaryEnumerator

/-!
# Cycle 11: the exact covering radius of a binary lattice

Cycle 10 proved the *strict* packing–covering inequality in rank two
(`rank_two_covering_strict` : `λ₁/4 < μ`) and bracketed the covering radius between
`(a − |b| + c)/4` and `(a + |b| + c)/4` (`reduced_covering_two_sided`).  This file removes the
brackets: for a reduced binary form

  `Q(x, y) = a x² + b x y + c y²`,  `0 ≤ b ≤ a ≤ c`,

the covering radius squared is the **exact rational function**

  `μ(Q) = a c (a − b + c) / (4 a c − b²)`  (`covRad`),

attained at the circumcentre `deepHole a b c` of the Delaunay triangle `{0, e₁, e₁ − e₂}`.

## Structure of the proof

* `covRad_shift` : the algebraic heart.  Translating by the deep hole turns the form into
  `Q(x, y) − a x − c y + μ`, i.e. `μ` is the *minimum* of the shifted paraboloid.
* `bq_ge_linear_int` : at every **integer** point `Q(p, q) ≥ a p + c q`.  Equivalently
  `a p(p−1) + c q(q−1) + b p q ≥ 0`; the only nontrivial case is `p q < 0`, where
  `b ≤ a ≤ c` and `|p|, |q| ≥ 1` win.  With `covRad_shift` this is exactly the statement that
  the deep hole has gap `≥ μ`, so `deepHole_isInhomMin` holds.
* `deepHole_weight_bound` : for *arbitrary* rationals `x, y`,
  `a x(1−x−y) + c y(1−x−y) + (a−b+c) x y ≤ μ`.  This is again `covRad_shift`, read as the
  statement that the concave paraboloid on the left has maximum `μ`.
* `bq_bary_lower`, `bq_bary_upper` : the Lagrange identity for a triangle — the weighted mean of
  the squared distances from a point to the three vertices of a Delaunay triangle, with
  barycentric weights, equals the left-hand side above.  Consequently one of the three vertices
  is at squared distance `≤ μ`.
* `binary_covering_le` : every rational point is within `μ` of the lattice, by reducing modulo
  `ℤ²` and splitting the unit cell along its short diagonal into the two Delaunay triangles.
* `binary_covering_radius_eq` : the two halves combined — `μ` is attained and is an upper bound
  for every inhomogeneous minimum.
* `covering_data_of_basis`, `bq_covering_radius_of_min`, `rank_two_covering_radius` : the
  reducedness hypothesis is then *removed*.  Using the reduction theorem `exists_reduced_basis`
  of cycle 10 (a shortest vector is primitive, a Bézout complement plus one shear), and flipping
  the sign of the second basis vector when the middle coefficient is negative, every
  positive-definite form on `ℤ²` with homogeneous minimum `λ₁` acquires reduced invariants
  `0 ≤ b ≤ λ₁ ≤ c` and covering radius² exactly `covRad λ₁ b c`.  The transport is unimodular in
  both directions: lattice points are pulled back by `int_coords_of_unimodular` and arbitrary
  rational shifts are pushed forward by the inverse matrix.

## Consequences

* `covRad_gt_quarter_min` : `μ − λ₁/4 = a (2c − b)² / (4(4ac − b²)) > 0`, a *quantitative* form
  of cycle 10's Conjecture C1.
* `covRad_ge_two_torsion` and `covRad_eq_two_torsion_iff` : the `2`-torsion value
  `(a − b + c)/4` of the covering weight enumerator equals the covering radius **iff** `b = 0`,
  i.e. iff the lattice is rectangular.  The hexagonal lattice is the extreme case:
  `hex_covRad` gives `μ = 1/3` while its whole `2`-torsion spectrum is `1/4`.
* `covRad_le_half_max` : `μ ≤ (a + c)/2`, and `square_covRad` recovers `μ(ℤ²) = 1/2`.
* `covRad_ge_third`, `covRad_eq_third_iff`, `rank_two_covering_ge_third` : the **sharp**
  packing–covering inequality in rank two, `μ ≥ λ₁/3`, replacing the constant `1/4` of
  `covering_ge_quarter_min`, with equality exactly at the hexagonal form.

## Lab notes

*Hypothesizer.*  Cycle 10 left a gap of `2|b|/4` between the two-sided bounds; the only shift
that could close it is the circumcentre of a Delaunay triangle, which for a reduced form is
`{0, e₁, e₁ − e₂}`.  Conjecture: `μ = a c (a − b + c)/(4ac − b²)` exactly.

*Experimenter.*  Exact rational evaluation: `(1,0,1) ↦ 1/2` (the deep hole `(½,½)` of `ℤ²`),
`(1,1,1) ↦ 1/3` (the hexagonal lattice, deep hole `(⅓,⅓)` — matches `hex_third_isInhomMin`
proved in cycle 10 by a congruence argument), `(2,1,3) ↦ 24/23`, `(1,0,5) ↦ 3/2`,
`(1,1,2) ↦ 4/7`.  In every case the value agrees with a brute-force minimisation over
`|p|, |q| ≤ 4`, and lies strictly between `(a−b+c)/4` and `(a+b+c)/4` unless `b = 0`.

*Analyst.*  The two bounds of cycle 10 differ by the *shape* of the Delaunay cell, and the
correct answer is a circumradius, hence the discriminant `4ac − b²` in the denominator — the
first place in this thread where the determinant of the form, rather than its coefficients,
governs a spectral invariant.  The proof splits into an "integer" half (lower bound: a
congruence-free inequality `a p(p−1) + c q(q−1) + b p q ≥ 0`) and a "convexity" half (upper
bound: the Lagrange barycentric identity plus concavity), which is exactly the packing/covering
dichotomy.

*Critic.*  Three checks.  (i) The upper bound must hold for **all** rational shifts, not only for
torsion ones; `binary_covering_le` quantifies over an arbitrary `t : Fin 2 → ℚ` and produces the
lattice point explicitly from `⌊t i⌋`.  (ii) The barycentric weights must be nonnegative — this
is why the unit cell is split along `x + y = 1`, and both triangles are handled
(`binary_covering_le` case split).  (iii) Reducedness is used twice and cannot be dropped:
`0 ≤ b` makes `e₁ − e₂` (not `e₁ + e₂`) the short diagonal, and `b ≤ a ≤ c` is what makes the
Delaunay triangle non-obtuse, i.e. makes the circumcentre lie inside it.

*PI.*  The covering radius of every binary lattice is now an explicit rational function of the
coefficients, closing the rank-two branch of Conjecture C quantitatively.
-/

namespace DiophantineLattice
namespace RankTwo

open Finset

/-! ## The covering radius and the deep hole -/

/-- The conjectured covering radius squared of the reduced binary form `(a, b, c)`: the
circumradius squared of the Delaunay triangle `{0, e₁, e₁ − e₂}`. -/
def covRad (a b c : ℚ) : ℚ := a * c * (a - b + c) / (4 * a * c - b ^ 2)

/-- The deep hole of the reduced binary form `(a, b, c)`: the circumcentre of the Delaunay
triangle, in the coordinates of the lattice basis. -/
def deepHole (a b c : ℚ) : Fin 2 → ℚ :=
  ![c * (2 * a - b) / (4 * a * c - b ^ 2), a * (2 * c - b) / (4 * a * c - b ^ 2)]

@[simp] lemma deepHole_zero (a b c : ℚ) :
    deepHole a b c 0 = c * (2 * a - b) / (4 * a * c - b ^ 2) := rfl

@[simp] lemma deepHole_one (a b c : ℚ) :
    deepHole a b c 1 = a * (2 * c - b) / (4 * a * c - b ^ 2) := rfl

/-- The discriminant of a reduced form is positive. -/
lemma disc_pos {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    0 < 4 * a * c - b ^ 2 := by nlinarith

/-- A form with nonnegative discriminant and positive leading coefficient is nonnegative. -/
lemma bq_nonneg {a b c : ℚ} (ha : 0 < a) (hd : 0 ≤ 4 * a * c - b ^ 2) (x y : ℚ) :
    0 ≤ bq a b c x y := by
  have h : 4 * a * bq a b c x y = (2 * a * x + b * y) ^ 2 + (4 * a * c - b ^ 2) * y ^ 2 := by
    unfold bq; ring
  nlinarith [sq_nonneg (2 * a * x + b * y), sq_nonneg y, mul_nonneg hd (sq_nonneg y)]

/-- The first stationarity relation of the deep hole: `2 a u + b v = a`. -/
lemma deepHole_rel_fst {a b c : ℚ} (hd : 4 * a * c - b ^ 2 ≠ 0) :
    2 * a * deepHole a b c 0 + b * deepHole a b c 1 = a := by
  have hd' : a * c * 4 - b ^ 2 ≠ 0 := fun h => hd (by linarith)
  simp only [deepHole_zero, deepHole_one]
  field_simp [hd, hd']
  ring

/-- The second stationarity relation of the deep hole: `b u + 2 c v = c`. -/
lemma deepHole_rel_snd {a b c : ℚ} (hd : 4 * a * c - b ^ 2 ≠ 0) :
    b * deepHole a b c 0 + 2 * c * deepHole a b c 1 = c := by
  have hd' : a * c * 4 - b ^ 2 ≠ 0 := fun h => hd (by linarith)
  have hd'' : c * a * 4 - b ^ 2 ≠ 0 := fun h => hd (by linarith)
  simp only [deepHole_zero, deepHole_one]
  field_simp [hd, hd', hd'']
  ring

/-- The form evaluated at the deep hole is the covering radius. -/
lemma deepHole_value {a b c : ℚ} (hd : 4 * a * c - b ^ 2 ≠ 0) :
    bq a b c (deepHole a b c 0) (deepHole a b c 1) = covRad a b c := by
  have hd' : a * c * 4 - b ^ 2 ≠ 0 := fun h => hd (by linarith)
  simp only [deepHole_zero, deepHole_one, covRad, bq]
  field_simp [hd, hd']
  ring

/-- Expansion of a translated binary form. -/
lemma bq_sub (a b c x y u v : ℚ) :
    bq a b c (x - u) (y - v)
      = bq a b c x y - (2 * a * u + b * v) * x - (b * u + 2 * c * v) * y + bq a b c u v := by
  unfold bq; ring

/-- **Translation by the deep hole.**  The form recentred at the deep hole is the original form
minus the linear functional `a x + c y`, plus the covering radius. -/
lemma covRad_shift {a b c : ℚ} (hd : 4 * a * c - b ^ 2 ≠ 0) (x y : ℚ) :
    bq a b c (x - deepHole a b c 0) (y - deepHole a b c 1)
      = bq a b c x y - a * x - c * y + covRad a b c := by
  rw [bq_sub, deepHole_rel_fst hd, deepHole_rel_snd hd, deepHole_value hd]

/-! ## The lower bound: the deep hole is a genuine hole -/

/-- `p (p − 1) ≥ 0` for an integer `p`, as a rational inequality. -/
lemma cast_sq_sub_self_nonneg (p : ℤ) : (0 : ℚ) ≤ (p : ℚ) ^ 2 - (p : ℚ) := by
  have h : (0 : ℤ) ≤ p ^ 2 - p := by
    rcases le_or_gt p 0 with hp | hp
    · nlinarith
    · nlinarith
  have h' : ((0 : ℤ) : ℚ) ≤ ((p ^ 2 - p : ℤ) : ℚ) := by exact_mod_cast h
  push_cast at h'
  linarith

/-- **The integral inequality behind the lower bound.**  For a reduced form and integers `p, q`,
`a p(p−1) + c q(q−1) + b p q ≥ 0`. -/
lemma int_shifted_nonneg {a b c : ℚ} (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) (p q : ℤ) :
    0 ≤ a * ((p : ℚ) ^ 2 - (p : ℚ)) + c * ((q : ℚ) ^ 2 - (q : ℚ)) + b * (p : ℚ) * (q : ℚ) := by
  have hp := cast_sq_sub_self_nonneg p
  have hq := cast_sq_sub_self_nonneg q
  rcases le_or_gt 0 (p * q) with hpq | hpq
  · have : (0 : ℚ) ≤ (p : ℚ) * (q : ℚ) := by
      have h' : ((0 : ℤ) : ℚ) ≤ ((p * q : ℤ) : ℚ) := by exact_mod_cast hpq
      push_cast at h'
      linarith
    nlinarith
  · -- `p q < 0`: opposite signs, and both have absolute value at least one
    rcases mul_neg_iff.1 hpq with ⟨hp0, hq0⟩ | ⟨hp0, hq0⟩
    · have hp1 : (1 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp0
      have hq1 : (q : ℚ) ≤ -1 := by
        have : q ≤ -1 := by omega
        exact_mod_cast this
      -- `a(p²−p) + c(q²−q) ≥ b[(p²−p) + (q²−q)] ≥ −b p q`
      nlinarith [mul_nonneg (sub_nonneg.2 hp1) (by linarith : (0 : ℚ) ≤ -(q : ℚ) - 1),
        sq_nonneg ((p : ℚ) + (q : ℚ)), mul_nonneg (sub_nonneg.2 hb) hp,
        mul_nonneg (sub_nonneg.2 (le_trans hb hc)) hq]
    · have hp1 : (p : ℚ) ≤ -1 := by
        have : p ≤ -1 := by omega
        exact_mod_cast this
      have hq1 : (1 : ℚ) ≤ (q : ℚ) := by exact_mod_cast hq0
      nlinarith [mul_nonneg (sub_nonneg.2 hq1) (by linarith : (0 : ℚ) ≤ -(p : ℚ) - 1),
        sq_nonneg ((p : ℚ) + (q : ℚ)), mul_nonneg (sub_nonneg.2 hb) hp,
        mul_nonneg (sub_nonneg.2 (le_trans hb hc)) hq]

/-- **The deep hole has gap exactly the covering radius.** -/
theorem deepHole_isInhomMin {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    IsInhomMin (binMat a b c) (deepHole a b c) (covRad a b c) := by
  have hd : 4 * a * c - b ^ 2 ≠ 0 := ne_of_gt (disc_pos ha hb0 hb hc)
  constructor
  · refine ⟨0, ?_⟩
    rw [binMat_value]
    have h0 : ((0 : Fin 2 → ℤ) 0 : ℚ) = 0 := by norm_num
    have h1 : ((0 : Fin 2 → ℤ) 1 : ℚ) = 0 := by norm_num
    rw [h0, h1]
    have := covRad_shift (a := a) (b := b) (c := c) hd 0 0
    simpa [bq, sub_zero] using this
  · intro m
    rw [binMat_value]
    have h := covRad_shift (a := a) (b := b) (c := c) hd ((m 0 : ℤ) : ℚ) ((m 1 : ℤ) : ℚ)
    have hsym : bq a b c ((deepHole a b c 0) - ((m 0 : ℤ) : ℚ))
        ((deepHole a b c 1) - ((m 1 : ℤ) : ℚ))
        = bq a b c (((m 0 : ℤ) : ℚ) - deepHole a b c 0) (((m 1 : ℤ) : ℚ) - deepHole a b c 1) := by
      unfold bq; ring
    rw [hsym, h]
    have hint := int_shifted_nonneg (a := a) (b := b) (c := c) hb0 hb hc (m 0) (m 1)
    unfold bq
    nlinarith [hint]

/-! ## The upper bound: every point is within the covering radius -/

/-- **Concavity bound.**  The weighted mean appearing in the Lagrange identity never exceeds the
covering radius. -/
lemma deepHole_weight_bound {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c)
    (x y : ℚ) :
    a * x * (1 - x - y) + c * y * (1 - x - y) + (a - b + c) * x * y ≤ covRad a b c := by
  have hdp := disc_pos ha hb0 hb hc
  have hd : 4 * a * c - b ^ 2 ≠ 0 := ne_of_gt hdp
  have h := covRad_shift (a := a) (b := b) (c := c) hd x y
  have hnn := bq_nonneg (a := a) (b := b) (c := c) ha (le_of_lt hdp)
    (x - deepHole a b c 0) (y - deepHole a b c 1)
  rw [h] at hnn
  unfold bq at hnn
  nlinarith [hnn]

/-- Given three nonnegative weights summing to one, one of the three values is at most the
weighted mean's upper bound. -/
lemma min_of_three_le {l₁ l₂ l₃ z₁ z₂ z₃ M : ℚ} (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (h₃ : 0 ≤ l₃)
    (hsum : l₁ + l₂ + l₃ = 1) (hle : l₁ * z₁ + l₂ * z₂ + l₃ * z₃ ≤ M) :
    z₁ ≤ M ∨ z₂ ≤ M ∨ z₃ ≤ M := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨g₁, g₂, g₃⟩ := hcon
  have hM : l₁ * M + l₂ * M + l₃ * M = M := by
    have : (l₁ + l₂ + l₃) * M = M := by rw [hsum]; ring
    linarith [this, (by ring : (l₁ + l₂ + l₃) * M = l₁ * M + l₂ * M + l₃ * M)]
  have e₁ : l₁ * M ≤ l₁ * z₁ := mul_le_mul_of_nonneg_left g₁.le h₁
  have e₂ : l₂ * M ≤ l₂ * z₂ := mul_le_mul_of_nonneg_left g₂.le h₂
  have e₃ : l₃ * M ≤ l₃ * z₃ := mul_le_mul_of_nonneg_left g₃.le h₃
  have hpos : 0 < l₁ ∨ 0 < l₂ ∨ 0 < l₃ := by
    rcases lt_or_eq_of_le h₁ with h | h
    · exact Or.inl h
    · rcases lt_or_eq_of_le h₂ with h' | h'
      · exact Or.inr (Or.inl h')
      · exact Or.inr (Or.inr (by linarith))
  rcases hpos with hp | hp | hp
  · have : l₁ * M < l₁ * z₁ := mul_lt_mul_of_pos_left g₁ hp
    linarith
  · have : l₂ * M < l₂ * z₂ := mul_lt_mul_of_pos_left g₂ hp
    linarith
  · have : l₃ * M < l₃ * z₃ := mul_lt_mul_of_pos_left g₃ hp
    linarith

/-- **Lagrange identity, lower triangle.**  Barycentric weights `(1−x−y, x, y)` for the triangle
`{0, e₁, e₂}`. -/
lemma bary_lower (a b c x y : ℚ) :
    (1 - x - y) * bq a b c x y + x * bq a b c (x - 1) y + y * bq a b c x (y - 1)
      = a * x * (1 - x - y) + c * y * (1 - x - y) + (a - b + c) * x * y := by
  unfold bq; ring

/-- **Lagrange identity, upper triangle.**  Barycentric weights `(1−y, 1−x, x+y−1)` for the
triangle `{e₁, e₂, e₁+e₂}`. -/
lemma bary_upper (a b c x y : ℚ) :
    (1 - y) * bq a b c (x - 1) y + (1 - x) * bq a b c x (y - 1)
        + (x + y - 1) * bq a b c (x - 1) (y - 1)
      = a * (1 - x) * (1 - (1 - x) - (1 - y)) + c * (1 - y) * (1 - (1 - x) - (1 - y))
        + (a - b + c) * (1 - x) * (1 - y) := by
  unfold bq; ring

/-- **The covering bound.**  Every rational point of the plane is within squared distance
`covRad a b c` of the lattice `ℤ²`. -/
theorem binary_covering_le {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c)
    (t : Fin 2 → ℚ) :
    ∃ m : Fin 2 → ℤ, form (binMat a b c) (fun i => t i - emb m i) ≤ covRad a b c := by
  set p : ℤ := ⌊t 0⌋ with hp
  set q : ℤ := ⌊t 1⌋ with hq
  set x : ℚ := t 0 - (p : ℚ) with hx
  set y : ℚ := t 1 - (q : ℚ) with hy
  have hx0' : 0 ≤ x := by
    rw [hx, sub_nonneg, hp]
    exact Int.floor_le _
  have hx1 : x < 1 := by
    rw [hx, sub_lt_iff_lt_add, hp]
    linarith [Int.lt_floor_add_one (t 0)]
  have hy0 : 0 ≤ y := by
    rw [hy, sub_nonneg, hq]
    exact Int.floor_le _
  have hy1 : y < 1 := by
    rw [hy, sub_lt_iff_lt_add, hq]
    linarith [Int.lt_floor_add_one (t 1)]
  have key : ∀ (m : Fin 2 → ℤ),
      form (binMat a b c) (fun i => t i - emb m i)
        = bq a b c (x - ((m 0 - p : ℤ) : ℚ)) (y - ((m 1 - q : ℤ) : ℚ)) := by
    intro m
    rw [binMat_value]
    push_cast
    rw [hx, hy]
    ring_nf
  rcases le_or_gt (x + y) 1 with hcase | hcase
  · -- lower triangle: vertices `0`, `e₁`, `e₂`
    have hbnd := deepHole_weight_bound ha hb0 hb hc x y
    rw [← bary_lower a b c x y] at hbnd
    have := min_of_three_le (l₁ := 1 - x - y) (l₂ := x) (l₃ := y)
      (by linarith) hx0' hy0 (by ring) hbnd
    rcases this with h | h | h
    · exact ⟨![p, q], by rw [key]; simpa using h⟩
    · exact ⟨![p + 1, q], by rw [key]; push_cast; simpa using h⟩
    · exact ⟨![p, q + 1], by rw [key]; push_cast; simpa using h⟩
  · -- upper triangle: vertices `e₁`, `e₂`, `e₁ + e₂`
    have hbnd := deepHole_weight_bound ha hb0 hb hc (1 - x) (1 - y)
    rw [← bary_upper a b c x y] at hbnd
    have := min_of_three_le (l₁ := 1 - y) (l₂ := 1 - x) (l₃ := x + y - 1)
      (by linarith) (by linarith) (by linarith) (by ring) hbnd
    rcases this with h | h | h
    · exact ⟨![p + 1, q], by rw [key]; push_cast; simpa using h⟩
    · exact ⟨![p, q + 1], by rw [key]; push_cast; simpa using h⟩
    · exact ⟨![p + 1, q + 1], by rw [key]; push_cast; simpa using h⟩

/-- **The covering radius of a reduced binary lattice, exactly.**  The deep hole realises the
value `a c (a − b + c)/(4ac − b²)`, and no shift has a larger gap. -/
theorem binary_covering_radius_eq {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a)
    (hc : a ≤ c) :
    IsInhomMin (binMat a b c) (deepHole a b c) (covRad a b c) ∧
      ∀ (t : Fin 2 → ℚ) (mu : ℚ), IsInhomMin (binMat a b c) t mu → mu ≤ covRad a b c := by
  refine ⟨deepHole_isInhomMin ha hb0 hb hc, ?_⟩
  intro t mu hmu
  obtain ⟨m, hm⟩ := binary_covering_le ha hb0 hb hc t
  exact le_trans (hmu.2 m) hm

/-! ## Consequences -/

/-- **Quantitative strictness of the packing–covering inequality in rank two.**
`μ − λ₁/4 = a (2c − b)²/(4(4ac − b²))`. -/
theorem covRad_sub_quarter_min {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    covRad a b c - a / 4 = a * (2 * c - b) ^ 2 / (4 * (4 * a * c - b ^ 2)) := by
  have hd : 4 * a * c - b ^ 2 ≠ 0 := ne_of_gt (disc_pos ha hb0 hb hc)
  have hd' : a * c * 4 - b ^ 2 ≠ 0 := fun h => hd (by linarith)
  unfold covRad
  field_simp [hd, hd']
  ring

/-- The covering radius of a binary lattice strictly exceeds a quarter of its minimum. -/
theorem covRad_gt_quarter_min {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    a / 4 < covRad a b c := by
  have hdp := disc_pos ha hb0 hb hc
  have h := covRad_sub_quarter_min ha hb0 hb hc
  have h2c : 0 < 2 * c - b := by linarith
  have hnum : 0 < a * (2 * c - b) ^ 2 := by positivity
  have : 0 < a * (2 * c - b) ^ 2 / (4 * (4 * a * c - b ^ 2)) := by positivity
  linarith [h ▸ this]

/-- The `2`-torsion entry of the covering weight enumerator never exceeds the covering radius. -/
theorem covRad_ge_two_torsion {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    (a - b + c) / 4 ≤ covRad a b c := by
  have hdp := disc_pos ha hb0 hb hc
  have hr : 0 ≤ a - b + c := by linarith
  rw [covRad, div_le_div_iff₀ (by norm_num : (0:ℚ) < 4) hdp]
  nlinarith [sq_nonneg b, mul_nonneg hr (sq_nonneg b)]

/-- The `2`-torsion shift is a deepest hole **iff** the lattice is rectangular. -/
theorem covRad_eq_two_torsion_iff {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a)
    (hc : a ≤ c) : covRad a b c = (a - b + c) / 4 ↔ b = 0 := by
  have hdp := disc_pos ha hb0 hb hc
  constructor
  · intro h
    rw [covRad, div_eq_div_iff (ne_of_gt hdp) (by norm_num : (4 : ℚ) ≠ 0)] at h
    by_contra hb'
    have hbpos : 0 < b := lt_of_le_of_ne hb0 (Ne.symm hb')
    nlinarith [sq_nonneg b, mul_pos hbpos hbpos]
  · rintro rfl
    rw [covRad]
    rw [div_eq_div_iff (ne_of_gt hdp) (by norm_num : (4 : ℚ) ≠ 0)]
    ring

/-- The covering radius never exceeds half the sum of the diagonal coefficients. -/
theorem covRad_le_half_max {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    covRad a b c ≤ (a + c) / 2 := by
  have hdp := disc_pos ha hb0 hb hc
  have hb2 : b ^ 2 ≤ a * c := by nlinarith
  rw [covRad, div_le_div_iff₀ hdp (by norm_num : (0:ℚ) < 2)]
  nlinarith [mul_nonneg (mul_nonneg ha.le hb0) (ha.le.trans hc),
    mul_nonneg (by linarith : (0:ℚ) ≤ a + c) (by linarith : (0:ℚ) ≤ 2 * a * c - b ^ 2)]

/-- The square lattice `ℤ²`: the covering radius squared is `1/2`, attained at `(½, ½)`. -/
theorem square_covRad : covRad 1 0 1 = 1 / 2 := by norm_num [covRad]

/-- The hexagonal lattice: the covering radius squared is `1/3`, four thirds of the value of any
`2`-torsion shift.  This matches `hex_third_isInhomMin` of cycle 10. -/
theorem hex_covRad : covRad 1 1 1 = 1 / 3 := by norm_num [covRad]

/-- The deep hole of the hexagonal lattice is the `3`-torsion point `(⅓, ⅓)`. -/
theorem hex_deepHole : deepHole 1 1 1 = ![1 / 3, 1 / 3] := by
  funext i
  fin_cases i <;> norm_num [deepHole]

/-- The hexagonal lattice is the *worst* binary lattice for covering relative to its minimum:
`μ/λ₁ = 1/3`, whereas the rectangular case gives `1/2`. -/
theorem hex_covering_ratio : covRad 1 1 1 * 3 = 1 := by norm_num [covRad]


/-! ## An arbitrary binary lattice: the covering radius exists and is a reduced invariant -/

/-- The covering bound, at the level of coefficient triples. -/
lemma bq_covering_le {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c)
    (s t : ℚ) : ∃ p q : ℤ, bq a b c (s - (p : ℚ)) (t - (q : ℚ)) ≤ covRad a b c := by
  obtain ⟨m, hm⟩ := binary_covering_le ha hb0 hb hc ![s, t]
  refine ⟨m 0, m 1, ?_⟩
  rw [binMat_value] at hm
  simpa using hm

/-- The deep hole bound, at the level of coefficient triples. -/
lemma bq_deepHole_lower {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c)
    (p q : ℤ) :
    covRad a b c ≤ bq a b c (deepHole a b c 0 - (p : ℚ)) (deepHole a b c 1 - (q : ℚ)) := by
  have h := (deepHole_isInhomMin ha hb0 hb hc).2 ![p, q]
  rw [binMat_value] at h
  simpa using h

/-- The value of the form at the deep hole. -/
lemma bq_deepHole_value {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    bq a b c (deepHole a b c 0) (deepHole a b c 1) = covRad a b c :=
  deepHole_value (ne_of_gt (disc_pos ha hb0 hb hc))

/-- A unimodular change of basis is surjective on lattice points. -/
lemma int_coords_of_unimodular {v0 v1 w0 w1 d : ℤ} (hdet : v0 * w1 - w0 * v1 = d)
    (hd : d * d = 1) (p q : ℤ) :
    ∃ p' q' : ℤ, (p : ℚ) = (v0 : ℚ) * (p' : ℚ) + (w0 : ℚ) * (q' : ℚ) ∧
      (q : ℚ) = (v1 : ℚ) * (p' : ℚ) + (w1 : ℚ) * (q' : ℚ) := by
  refine ⟨d * (w1 * p - w0 * q), d * (v0 * q - v1 * p), ?_, ?_⟩
  · have hz : v0 * (d * (w1 * p - w0 * q)) + w0 * (d * (v0 * q - v1 * p)) = p := by
      have : v0 * (d * (w1 * p - w0 * q)) + w0 * (d * (v0 * q - v1 * p))
          = d * (v0 * w1 - w0 * v1) * p := by ring
      rw [this, hdet]
      calc d * d * p = 1 * p := by rw [hd]
        _ = p := one_mul p
    exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hz.symm
  · have hz : v1 * (d * (w1 * p - w0 * q)) + w1 * (d * (v0 * q - v1 * p)) = q := by
      have : v1 * (d * (w1 * p - w0 * q)) + w1 * (d * (v0 * q - v1 * p))
          = d * (v0 * w1 - w0 * v1) * q := by ring
      rw [this, hdet]
      calc d * d * q = 1 * q := by rw [hd]
        _ = q := one_mul q
    exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hz.symm

/-- Sign change of the second basis vector. -/
lemma crossCoeff_neg (a b c v0 v1 w0 w1 : ℚ) :
    crossCoeff a b c v0 v1 (-w0) (-w1) = -crossCoeff a b c v0 v1 w0 w1 := by
  unfold crossCoeff; ring

lemma bq_neg (a b c x y : ℚ) : bq a b c (-x) (-y) = bq a b c x y := by unfold bq; ring

/-- **Transport of the covering data along a unimodular change of basis.**  If the form reads
`(lam, B', C')` in the basis `(v, u)` and that triple is reduced, then the covering radius data of
the reduced triple transports back to the original coordinates. -/
lemma covering_data_of_basis {a b c lam B' C' : ℚ} {v0 v1 u0 u1 e : ℤ}
    (hlam : 0 < lam) (hB'0 : 0 ≤ B') (hB'le : B' ≤ lam) (hC'ge : lam ≤ C')
    (hvlam : bq a b c (v0 : ℚ) (v1 : ℚ) = lam)
    (hB'def : crossCoeff a b c (v0 : ℚ) (v1 : ℚ) (u0 : ℚ) (u1 : ℚ) = B')
    (hC'def : bq a b c (u0 : ℚ) (u1 : ℚ) = C')
    (hdet : v0 * u1 - u0 * v1 = e) (hee : e * e = 1) :
    ∃ s t : ℚ, bq a b c s t = covRad lam B' C' ∧
      (∀ p q : ℤ, covRad lam B' C' ≤ bq a b c (s - (p : ℚ)) (t - (q : ℚ))) ∧
      (∀ s' t' : ℚ, ∃ p q : ℤ, bq a b c (s' - (p : ℚ)) (t' - (q : ℚ)) ≤ covRad lam B' C') := by
  have heeq : (e : ℚ) * (e : ℚ) = 1 := by exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hee
  have hchange : ∀ x y : ℚ,
      bq a b c ((v0 : ℚ) * x + (u0 : ℚ) * y) ((v1 : ℚ) * x + (u1 : ℚ) * y) = bq lam B' C' x y := by
    intro x y
    rw [bq_change, hvlam, hB'def, hC'def]
  set s0 : ℚ := deepHole lam B' C' 0 with hs0
  set t0 : ℚ := deepHole lam B' C' 1 with ht0
  refine ⟨(v0 : ℚ) * s0 + (u0 : ℚ) * t0, (v1 : ℚ) * s0 + (u1 : ℚ) * t0, ?_, ?_, ?_⟩
  · rw [hchange s0 t0]
    exact bq_deepHole_value hlam hB'0 hB'le hC'ge
  · intro p q
    obtain ⟨p', q', hp0, hq0⟩ := int_coords_of_unimodular hdet hee p q
    have hxx : (v0 : ℚ) * s0 + (u0 : ℚ) * t0 - (p : ℚ)
        = (v0 : ℚ) * (s0 - (p' : ℚ)) + (u0 : ℚ) * (t0 - (q' : ℚ)) := by rw [hp0]; ring
    have hyy : (v1 : ℚ) * s0 + (u1 : ℚ) * t0 - (q : ℚ)
        = (v1 : ℚ) * (s0 - (p' : ℚ)) + (u1 : ℚ) * (t0 - (q' : ℚ)) := by rw [hq0]; ring
    rw [hxx, hyy, hchange]
    exact bq_deepHole_lower hlam hB'0 hB'le hC'ge p' q'
  · intro s' t'
    set S : ℚ := (e : ℚ) * ((u1 : ℚ) * s' - (u0 : ℚ) * t') with hS
    set T : ℚ := (e : ℚ) * ((v0 : ℚ) * t' - (v1 : ℚ) * s') with hT
    have hdetq : (v0 : ℚ) * (u1 : ℚ) - (u0 : ℚ) * (v1 : ℚ) = (e : ℚ) := by
      exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hdet
    have hs' : (v0 : ℚ) * S + (u0 : ℚ) * T = s' := by
      rw [hS, hT]
      have h : (v0 : ℚ) * ((e : ℚ) * ((u1 : ℚ) * s' - (u0 : ℚ) * t'))
            + (u0 : ℚ) * ((e : ℚ) * ((v0 : ℚ) * t' - (v1 : ℚ) * s'))
          = (e : ℚ) * ((v0 : ℚ) * (u1 : ℚ) - (u0 : ℚ) * (v1 : ℚ)) * s' := by ring
      rw [h, hdetq, heeq, one_mul]
    have ht' : (v1 : ℚ) * S + (u1 : ℚ) * T = t' := by
      rw [hS, hT]
      have h : (v1 : ℚ) * ((e : ℚ) * ((u1 : ℚ) * s' - (u0 : ℚ) * t'))
            + (u1 : ℚ) * ((e : ℚ) * ((v0 : ℚ) * t' - (v1 : ℚ) * s'))
          = (e : ℚ) * ((v0 : ℚ) * (u1 : ℚ) - (u0 : ℚ) * (v1 : ℚ)) * t' := by ring
      rw [h, hdetq, heeq, one_mul]
    obtain ⟨p', q', hle⟩ := bq_covering_le hlam hB'0 hB'le hC'ge S T
    refine ⟨v0 * p' + u0 * q', v1 * p' + u1 * q', ?_⟩
    have hxx : s' - ((v0 * p' + u0 * q' : ℤ) : ℚ)
        = (v0 : ℚ) * (S - (p' : ℚ)) + (u0 : ℚ) * (T - (q' : ℚ)) := by
      rw [← hs']; push_cast; ring
    have hyy : t' - ((v1 * p' + u1 * q' : ℤ) : ℚ)
        = (v1 : ℚ) * (S - (p' : ℚ)) + (u1 : ℚ) * (T - (q' : ℚ)) := by
      rw [← ht']; push_cast; ring
    rw [hxx, hyy, hchange]
    exact hle

/-- **The covering radius of an arbitrary binary form.**  If `lam` is the homogeneous minimum,
realised by `v`, then there is a reduced triple `(lam, b', c')` with `0 ≤ b' ≤ lam ≤ c'` and a
shift `(s, t)` whose gap is `covRad lam b' c'`, and no point of the plane is further than
`covRad lam b' c'` from the lattice. -/
theorem bq_covering_radius_of_min {a b c lam : ℚ} (hlam : 0 < lam)
    (hlow : ∀ p q : ℤ, ¬(p = 0 ∧ q = 0) → lam ≤ bq a b c (p : ℚ) (q : ℚ))
    {v0 v1 : ℤ} (hv : ¬(v0 = 0 ∧ v1 = 0)) (hvlam : bq a b c (v0 : ℚ) (v1 : ℚ) = lam) :
    ∃ b' c' s t : ℚ, 0 ≤ b' ∧ b' ≤ lam ∧ lam ≤ c' ∧
      bq a b c s t = covRad lam b' c' ∧
      (∀ p q : ℤ, covRad lam b' c' ≤ bq a b c (s - (p : ℚ)) (t - (q : ℚ))) ∧
      (∀ s' t' : ℚ, ∃ p q : ℤ, bq a b c (s' - (p : ℚ)) (t' - (q : ℚ)) ≤ covRad lam b' c') := by
  obtain ⟨w0, w1, hdet, hBabs, hCge⟩ := exists_reduced_basis hlam hlow hv hvlam
  obtain ⟨hBlo, hBhi⟩ := abs_le.1 hBabs
  rcases le_or_gt 0 (crossCoeff a b c (v0 : ℚ) (v1 : ℚ) (w0 : ℚ) (w1 : ℚ)) with hsign | hsign
  · obtain ⟨s, t, h1, h2, h3⟩ :=
      covering_data_of_basis (a := a) (b := b) (c := c) (lam := lam)
        (B' := crossCoeff a b c (v0 : ℚ) (v1 : ℚ) (w0 : ℚ) (w1 : ℚ))
        (C' := bq a b c (w0 : ℚ) (w1 : ℚ)) (v0 := v0) (v1 := v1) (u0 := w0) (u1 := w1) (e := 1)
        hlam hsign hBhi hCge hvlam rfl rfl hdet (by norm_num)
    exact ⟨_, _, s, t, hsign, hBhi, hCge, h1, h2, h3⟩
  · have hcast0 : (((-w0 : ℤ)) : ℚ) = -(w0 : ℚ) := by push_cast; ring
    have hcast1 : (((-w1 : ℤ)) : ℚ) = -(w1 : ℚ) := by push_cast; ring
    have hBdef : crossCoeff a b c (v0 : ℚ) (v1 : ℚ) (((-w0 : ℤ)) : ℚ) (((-w1 : ℤ)) : ℚ)
        = -crossCoeff a b c (v0 : ℚ) (v1 : ℚ) (w0 : ℚ) (w1 : ℚ) := by
      rw [hcast0, hcast1, crossCoeff_neg]
    have hCdef : bq a b c (((-w0 : ℤ)) : ℚ) (((-w1 : ℤ)) : ℚ) = bq a b c (w0 : ℚ) (w1 : ℚ) := by
      rw [hcast0, hcast1, bq_neg]
    have hdetneg : v0 * (-w1) - (-w0) * v1 = -1 := by
      have : v0 * (-w1) - (-w0) * v1 = -(v0 * w1 - w0 * v1) := by ring
      rw [this, hdet]
    obtain ⟨s, t, h1, h2, h3⟩ :=
      covering_data_of_basis (a := a) (b := b) (c := c) (lam := lam)
        (B' := -crossCoeff a b c (v0 : ℚ) (v1 : ℚ) (w0 : ℚ) (w1 : ℚ))
        (C' := bq a b c (w0 : ℚ) (w1 : ℚ)) (v0 := v0) (v1 := v1) (u0 := -w0) (u1 := -w1) (e := -1)
        hlam (by linarith) (by linarith) hCge hvlam hBdef hCdef hdetneg (by norm_num)
    exact ⟨_, _, s, t, by linarith, by linarith, hCge, h1, h2, h3⟩

/-- **The covering radius of every binary lattice, in the vocabulary of the catalogue.**
For a positive-definite form on `ℤ²` with homogeneous minimum `lam` there are reduced invariants
`0 ≤ b ≤ lam ≤ c` and a shift `t` whose gap is `covRad lam b c`, and every other shift has a
smaller or equal gap: the covering radius² of the lattice is `lam · c · (lam − b + c)/(4 lam c − b²)`. -/
theorem rank_two_covering_radius {B : Matrix (Fin 2) (Fin 2) ℚ} (hpd : PosDef B) {lam : ℚ}
    (hmin : IsMinEnergy B lam) :
    ∃ (b c : ℚ) (t : Fin 2 → ℚ), 0 ≤ b ∧ b ≤ lam ∧ lam ≤ c ∧
      IsInhomMin B t (covRad lam b c) ∧
      ∀ (t' : Fin 2 → ℚ) (mu : ℚ), IsInhomMin B t' mu → mu ≤ covRad lam b c := by
  obtain ⟨⟨v, hv0, hvlam⟩, hlow⟩ := hmin
  have hlampos : 0 < lam := by rw [← hvlam]; exact hpd _ (emb_ne_zero hv0)
  have hvpair : ¬(v 0 = 0 ∧ v 1 = 0) := by
    rintro ⟨h0, h1⟩
    exact hv0 (funext fun i => by fin_cases i <;> simpa using ‹_›)
  have hlowbq : ∀ p q : ℤ, ¬(p = 0 ∧ q = 0) →
      lam ≤ bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) (p : ℚ) (q : ℚ) := by
    intro p q hpq
    have hne : (![p, q] : Fin 2 → ℤ) ≠ 0 := by
      intro hcon
      exact hpq ⟨by simpa using congrFun hcon 0, by simpa using congrFun hcon 1⟩
    have := hlow ![p, q] hne
    rwa [form_pair] at this
  have hvbq : bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) ((v 0 : ℤ) : ℚ) ((v 1 : ℤ) : ℚ) = lam := by
    rw [← hvlam, form_eq_bq]
    simp [emb]
  obtain ⟨b', c', s, t, hb0, hble, hcge, hval, hlower, hcover⟩ :=
    bq_covering_radius_of_min hlampos hlowbq hvpair hvbq
  have hform : ∀ (x y : ℚ) (m : Fin 2 → ℤ),
      form B (fun i => (![x, y] : Fin 2 → ℚ) i - emb m i)
        = bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) (x - ((m 0 : ℤ) : ℚ)) (y - ((m 1 : ℤ) : ℚ)) := by
    intro x y m
    rw [form_eq_bq]
    simp [emb]
  refine ⟨b', c', ![s, t], hb0, hble, hcge, ⟨⟨0, ?_⟩, ?_⟩, ?_⟩
  · rw [hform]
    have h0 : ((0 : Fin 2 → ℤ) 0 : ℚ) = 0 := by norm_num
    have h1 : ((0 : Fin 2 → ℤ) 1 : ℚ) = 0 := by norm_num
    rw [h0, h1, sub_zero, sub_zero]
    exact hval
  · intro m
    rw [hform]
    exact hlower (m 0) (m 1)
  · intro t' mu hmu
    obtain ⟨p, q, hpq⟩ := hcover (t' 0) (t' 1)
    have hval2 : form B (fun i => t' i - emb (![p, q] : Fin 2 → ℤ) i)
        = bq (B 0 0) (B 0 1 + B 1 0) (B 1 1) (t' 0 - (p : ℚ)) (t' 1 - (q : ℚ)) := by
      rw [form_eq_bq]
      simp [emb]
    have := hmu.2 ![p, q]
    rw [hval2] at this
    exact le_trans this hpq


/-! ## Sharp packing–covering constant in rank two -/

/-- **The hexagonal bound.**  For a reduced triple the covering radius is at least `a/3`, and the
difference is `a[(c − a)c + (2c − b)(c − b)]/(3(4ac − b²))`. -/
theorem covRad_ge_third {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    a / 3 ≤ covRad a b c := by
  have hdp := disc_pos ha hb0 hb hc
  rw [covRad, div_le_div_iff₀ (by norm_num : (0:ℚ) < 3) hdp]
  nlinarith [mul_nonneg (sub_nonneg.2 hc) (ha.le.trans hc), mul_nonneg
    (by linarith : (0:ℚ) ≤ 2 * c - b) (by linarith : (0:ℚ) ≤ c - b)]

/-- **Rigidity of the hexagonal bound.**  Equality `μ = λ₁/3` holds exactly at the hexagonal
form `a(x² + xy + y²)`. -/
theorem covRad_eq_third_iff {a b c : ℚ} (ha : 0 < a) (hb0 : 0 ≤ b) (hb : b ≤ a) (hc : a ≤ c) :
    covRad a b c = a / 3 ↔ (b = a ∧ c = a) := by
  have hdp := disc_pos ha hb0 hb hc
  have hcpos : 0 < c := lt_of_lt_of_le ha hc
  constructor
  · intro h
    rw [covRad, div_eq_div_iff (ne_of_gt hdp) (by norm_num : (3 : ℚ) ≠ 0)] at h
    have hprod : a * ((c - a) * c + (2 * c - b) * (c - b)) = 0 := by linear_combination h
    have hsum : (c - a) * c + (2 * c - b) * (c - b) = 0 := by
      rcases mul_eq_zero.1 hprod with h' | h'
      · exact absurd h' (ne_of_gt ha)
      · exact h'
    have h1 : 0 ≤ (c - a) * c := mul_nonneg (by linarith) hcpos.le
    have h2 : 0 ≤ (2 * c - b) * (c - b) := mul_nonneg (by linarith) (by linarith)
    have hca : c = a := by
      have : (c - a) * c = 0 := by linarith
      rcases mul_eq_zero.1 this with h' | h'
      · linarith
      · exact absurd h' (ne_of_gt hcpos)
    have hbc : b = c := by
      have : (2 * c - b) * (c - b) = 0 := by linarith
      rcases mul_eq_zero.1 this with h' | h'
      · linarith
      · linarith
    exact ⟨by rw [hbc, hca], hca⟩
  · rintro ⟨h1, h2⟩
    have hne : (3 : ℚ) * a ^ 2 ≠ 0 := by positivity
    rw [covRad, h1, h2, show (4 : ℚ) * a * a - a ^ 2 = 3 * a ^ 2 from by ring]
    rw [div_eq_div_iff hne (by norm_num : (3 : ℚ) ≠ 0)]
    ring

/-- **The sharp packing–covering inequality in rank two.**  Every binary lattice satisfies
`μ ≥ λ₁/3`, a strict improvement on `covering_ge_quarter_min`; the hexagonal lattice attains it
(`hex_covRad`). -/
theorem rank_two_covering_ge_third {B : Matrix (Fin 2) (Fin 2) ℚ} (hpd : PosDef B) {lam mu : ℚ}
    (hmin : IsMinEnergy B lam)
    (hcov : ∀ t : Fin 2 → ℚ, ∃ m : Fin 2 → ℤ, form B (fun i => t i - emb m i) ≤ mu) :
    lam / 3 ≤ mu := by
  obtain ⟨b, c, t, hb0, hble, hcge, hgap, _⟩ := rank_two_covering_radius hpd hmin
  obtain ⟨⟨v, hv0, hvlam⟩, _⟩ := hmin
  have hlampos : 0 < lam := by rw [← hvlam]; exact hpd _ (emb_ne_zero hv0)
  obtain ⟨m, hm⟩ := hcov t
  have h1 : covRad lam b c ≤ mu := le_trans (hgap.2 m) hm
  exact le_trans (covRad_ge_third hlampos hb0 hble hcge) h1

end RankTwo
end DiophantineLattice