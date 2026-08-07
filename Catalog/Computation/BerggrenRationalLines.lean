import Computation.BerggrenHorocycleGap

/-!
# Cycle 6: the rational lines of the picture

Cycles 1–5 identified the *integral* straight lines of the Poincaré-disk picture of the Berggren
tree with the conics `m² - k m n - n² = 1`, `k ∈ ℕ`.  But the radial invariant
`ϱ(m,n) = (m² - n² - 1)/(m n)` is in general only a **rational** number, and the numerical census
shows heavily populated lines with non-integral `ϱ`, e.g.

`ϱ = 2/3 : (3,2), (25,18), (111,80), (949,684), …`,  `ϱ = 1/2 : (4,3), (41,32), (260,203), …`.

This file develops the general theory of those lines.  Write `ϱ = a/b`; the line is the conic

  `RatConic a b : b m² - a m n - b n² = b`.

## Main results

* `ratConic_ratStep` — the conic `a/b` is preserved by the explicit integral matrix
  `[[s, b u], [b u, s - a u]]` **exactly when** `s² - a s u - b² u² = 1` (`RatUnit`), i.e. exactly
  when `(s, b u)` is itself a point of the same line.  The line carries its own automorphism.
* `exists_ratUnit` — such a unit always exists (with `s, u > 0`) as soon as the discriminant
  `a² + 4b²` is not a perfect square; the proof feeds Mathlib's Pell solver
  `Pell.exists_of_not_isSquare` through the substitution `s = x + a y`, `u = 2 y`.
* `cosh_dist_ratStep`, `dist_ratStep_eq` — the automorphism is a hyperbolic translation of
  **constant** step length `arcosh (s - a u / 2)`, generalizing `pellStepLength k = arcosh(1+k²/2)`
  (the case `b = 1`, `(s,u) = (k²+1, k)`).
* `ratStep_collinear`, `dist_base_ratOrbit` — the base point and the whole orbit are exactly
  collinear, and the `j`-th orbit point sits at distance exactly `j · arcosh (s - a u/2)`: a
  rational line is again an isometric copy of `ℕ`.
* `ratConic_infinite` — consequently every rational line with non-square discriminant carries
  infinitely many integral points, all radially aligned with the centre (`radial_ratConic`).
* `ratConic_three_two_empty` — the boundary case: when `a² + 4b²` *is* a square the conic
  degenerates into a product of two linear forms and the line can be completely empty, as for
  `ϱ = 3/2` (discriminant `25`).

## Lab notes

Radial values with the most seeds among all Euclid seeds with `m ≤ 4000`:

| ϱ    | seeds found                                    | discriminant a²+4b² |
|------|------------------------------------------------|---------------------|
| 1    | (2,1), (13,8), (34,21), (233,144), (610,377)   | 5                   |
| 2/3  | (3,2), (25,18), (111,80), (949,684)            | 40                  |
| 1/2  | (4,3), (41,32), (260,203), (2705,2112)         | 17                  |
| 2    | (5,2), (29,12), (169,70), (985,408)            | 8                   |
| 1/3  | (6,5), (85,72), (870,737)                      | 37                  |
| 3/2  | none                                            | 25 = 5²             |

For `ϱ = 2/3` the driving unit is `(s,u) = (25,6)`: `25² - 2·25·6 - 9·36 = 1`, and the step
matrix `[[25,18],[18,13]]` sends `(3,2) ↦ (111,80)` and `(25,18) ↦ (949,684)`, exactly the
observed points.  The step length is `arcosh (25 - 6) = arcosh 19 = 3.6369…`, and the measured
distances from the centre are `1.4910, 3.6369, 5.1279, 7.2738, …` — two interleaved arithmetic
progressions of common difference `arcosh 19`.  The orbit of the centre itself is
`(1,0), (25,18), (949,684), (36037,25974)` at distances `0, 3.6369, 7.2738, 10.9107`, i.e.
exactly `j · arcosh 19`, as `dist_base_ratOrbit` predicts.
-/

noncomputable section

open UpperHalfPlane Real

namespace BerggrenHyperbolic

/-! ## 1. Rational lines, their units and their automorphisms -/

/-- The rational line of radial value `a/b`: the conic `b m² - a m n - b n² = b`. -/
def RatConic (a b : ℤ) (p : ℤ × ℤ) : Prop := b * p.1 ^ 2 - a * p.1 * p.2 - b * p.2 ^ 2 = b

/-- A unit for the line `a/b`: an integral solution of `s² - a s u - b² u² = 1`.  Equivalently
`(s, b u)` is a point of the line itself. -/
def RatUnit (a b s u : ℤ) : Prop := s ^ 2 - a * s * u - b ^ 2 * u ^ 2 = 1

/-- The automorphism attached to a unit: the matrix `[[s, b u], [b u, s - a u]]`. -/
def ratStep (a b s u : ℤ) (p : ℤ × ℤ) : ℤ × ℤ :=
  (s * p.1 + b * u * p.2, b * u * p.1 + (s - a * u) * p.2)

/-- A unit of the line `a/b` is the same thing as a point `(s, b u)` of the line. -/
theorem ratUnit_iff_ratConic {a b s u : ℤ} (hb : b ≠ 0) :
    RatUnit a b s u ↔ RatConic a b (s, b * u) := by
  simp only [RatUnit, RatConic]
  constructor <;> intro h
  · have : b * (s ^ 2 - a * s * u - b ^ 2 * u ^ 2) = b * 1 := by rw [h]
    nlinarith [this]
  · have hb2 : b * (s ^ 2 - a * s * u - b ^ 2 * u ^ 2 - 1) = 0 := by nlinarith [h]
    rcases mul_eq_zero.1 hb2 with h1 | h1
    · exact absurd h1 hb
    · linarith

/-- **The line carries its own automorphism.**  `ratStep` preserves the conic exactly because of
the unit equation. -/
theorem ratConic_ratStep {a b s u : ℤ} (hu : RatUnit a b s u) {p : ℤ × ℤ}
    (hp : RatConic a b p) : RatConic a b (ratStep a b s u p) := by
  simp only [RatConic, ratStep, RatUnit] at *
  linear_combination (s ^ 2 - a * s * u - b ^ 2 * u ^ 2) * hp + b * hu

/-- **Existence of a unit.**  If the discriminant `a² + 4b²` is not a perfect square, the line
`a/b` has a nontrivial automorphism.  (Mathlib's Pell solver supplies `x² - D y² = 1`; the
substitution `s = x + a y`, `u = 2 y` converts it into the unit equation.) -/
theorem exists_ratUnit {a b : ℤ} (ha : 0 ≤ a) (hb : 0 < b)
    (hD : ¬ IsSquare (a ^ 2 + 4 * b ^ 2)) :
    ∃ s u : ℤ, 0 < s ∧ 0 < u ∧ RatUnit a b s u := by
  obtain ⟨x, y, hxy, hy⟩ := Pell.exists_of_not_isSquare (by positivity) hD
  refine ⟨|x| + a * |y|, 2 * |y|, ?_, ?_, ?_⟩
  · have h1 : 0 < |x| := by
      rcases eq_or_lt_of_le (abs_nonneg x) with h | h
      · exfalso
        have hx0 : x = 0 := abs_eq_zero.1 h.symm
        rw [hx0] at hxy
        nlinarith [sq_nonneg y, (abs_pos.2 hy)]
      · exact h
    have h2 : 0 ≤ a * |y| := mul_nonneg ha (abs_nonneg y)
    linarith
  · have := abs_pos.2 hy
    linarith
  · simp only [RatUnit]
    have hx2 : |x| ^ 2 = x ^ 2 := sq_abs x
    have hy2 : |y| ^ 2 = y ^ 2 := sq_abs y
    nlinarith [hxy, hx2, hy2]

/-- The base point of the picture lies on every rational line. -/
theorem ratConic_base (a b : ℤ) : RatConic a b (1, 0) := by
  simp [RatConic]

/-- A unit has `0 < s - a u`: the second diagonal entry of the step matrix is positive. -/
theorem ratUnit_sub_pos {a b s u : ℤ} (hs : 0 < s) (hu : RatUnit a b s u) : 0 < s - a * u := by
  simp only [RatUnit] at hu
  nlinarith [sq_nonneg (b * u), hs]

theorem ratStep_pos {a b s u : ℤ} (hb : 0 < b) (hs : 0 < s) (hupos : 0 < u)
    (hu : RatUnit a b s u) {p : ℤ × ℤ} (hm : 0 < p.1) (hn : 0 ≤ p.2) :
    0 < (ratStep a b s u p).1 ∧ 0 < (ratStep a b s u p).2 := by
  have hsub := ratUnit_sub_pos hs hu
  constructor
  · simp only [ratStep]
    nlinarith [mul_nonneg (mul_nonneg hb.le hupos.le) hn]
  · simp only [ratStep]
    nlinarith [mul_pos (mul_pos hb hupos) hm, mul_nonneg hsub.le hn]

theorem ratStep_fst_lt {a b s u : ℤ} (hb : 0 < b) (hs : 0 < s) (hupos : 0 < u)
    {p : ℤ × ℤ} (hm : 0 < p.1) (hn : 0 < p.2) :
    p.1 < (ratStep a b s u p).1 := by
  simp only [ratStep]
  nlinarith [mul_pos (mul_pos hb hupos) hn]

/-- The orbit of a point of the line under its automorphism. -/
def ratOrbit (a b s u : ℤ) (p : ℤ × ℤ) : ℕ → ℤ × ℤ
  | 0 => p
  | j + 1 => ratStep a b s u (ratOrbit a b s u p j)

theorem ratConic_ratOrbit {a b s u : ℤ} (hu : RatUnit a b s u) {p : ℤ × ℤ}
    (hp : RatConic a b p) (j : ℕ) : RatConic a b (ratOrbit a b s u p j) := by
  induction j with
  | zero => exact hp
  | succ j ih => exact ratConic_ratStep hu ih

theorem ratOrbit_pos {a b s u : ℤ} (hb : 0 < b) (hs : 0 < s) (hupos : 0 < u)
    (hu : RatUnit a b s u) {p : ℤ × ℤ} (hm : 0 < p.1) (hn : 0 < p.2) (j : ℕ) :
    0 < (ratOrbit a b s u p j).1 ∧ 0 < (ratOrbit a b s u p j).2 := by
  induction j with
  | zero => exact ⟨hm, hn⟩
  | succ j ih => exact ratStep_pos hb hs hupos hu ih.1 ih.2.le

theorem ratOrbit_base_pos {a b s u : ℤ} (hb : 0 < b) (hs : 0 < s) (hupos : 0 < u)
    (hu : RatUnit a b s u) (j : ℕ) :
    0 < (ratOrbit a b s u (1, 0) j).1 ∧ 0 ≤ (ratOrbit a b s u (1, 0) j).2 := by
  induction j with
  | zero => exact ⟨one_pos, le_rfl⟩
  | succ i ihi =>
      have h := ratStep_pos hb hs hupos hu ihi.1 ihi.2
      exact ⟨h.1, h.2.le⟩

/-- **Rational lines are infinite.**  Whenever the discriminant `a² + 4b²` is not a perfect
square, the line of radial value `a/b` carries infinitely many integral points with positive
coordinates. -/
theorem ratConic_infinite {a b : ℤ} (ha : 0 ≤ a) (hb : 0 < b)
    (hD : ¬ IsSquare (a ^ 2 + 4 * b ^ 2)) :
    {q : ℤ × ℤ | RatConic a b q ∧ 0 < q.1 ∧ 0 < q.2}.Infinite := by
  obtain ⟨s, u, hs, hupos, hu⟩ := exists_ratUnit ha hb hD
  set p : ℤ × ℤ := ratStep a b s u (1, 0) with hp
  have hpc : RatConic a b p := ratConic_ratStep hu (ratConic_base a b)
  have hp1 : 0 < p.1 := by
    simp only [hp, ratStep]
    nlinarith
  have hp2 : 0 < p.2 := by
    simp only [hp, ratStep]
    nlinarith
  have hmono : StrictMono fun j : ℕ => (ratOrbit a b s u p j).1 := by
    refine strictMono_nat_of_lt_succ fun j => ?_
    obtain ⟨h1, h2⟩ := ratOrbit_pos hb hs hupos hu hp1 hp2 j
    exact ratStep_fst_lt hb hs hupos h1 h2
  refine Set.infinite_of_injective_forall_mem
    (f := fun j : ℕ => ratOrbit a b s u p j) (fun i j hij => ?_) (fun j => ?_)
  · exact hmono.injective (congrArg Prod.fst hij)
  · exact ⟨ratConic_ratOrbit hu hpc j, ratOrbit_pos hb hs hupos hu hp1 hp2 j⟩

/-! ## 2. The geometry: constant step length and exact collinearity -/

section RatGeometry

variable {a b s u m n : ℝ}

/-- Real form of the conic relation, as used by the geometric lemmas. -/
theorem ratConic_real_div (hb : 0 < b) (hc : b * m ^ 2 - a * m * n - b * n ^ 2 = b) :
    m ^ 2 - (a / b) * m * n - n ^ 2 = 1 := by
  field_simp
  linarith

/-- The image of a point of the line under the step matrix is again on the line. -/
theorem ratConic_step_real (hc : b * m ^ 2 - a * m * n - b * n ^ 2 = b)
    (hu : s ^ 2 - a * s * u - b ^ 2 * u ^ 2 = 1) :
    b * (s * m + b * u * n) ^ 2 - a * (s * m + b * u * n) * (b * u * m + (s - a * u) * n)
      - b * (b * u * m + (s - a * u) * n) ^ 2 = b := by
  linear_combination (s ^ 2 - a * s * u - b ^ 2 * u ^ 2) * hc + b * hu

/-- **Constant step length.**  Along the line `a/b` the automorphism attached to the unit
`(s,u)` moves every node by the *same* hyperbolic distance, with `cosh = s - a u / 2`.  For
`b = 1` and `(s,u) = (k²+1, k)` this is `1 + k²/2`, the integral case. -/
theorem cosh_dist_ratStep (hb : 0 < b) (hm : 0 < m) (hn : 0 ≤ n) (hs : 0 < s) (hupos : 0 < u)
    (hc : b * m ^ 2 - a * m * n - b * n ^ 2 = b)
    (hu : s ^ 2 - a * s * u - b ^ 2 * u ^ 2 = 1) :
    Real.cosh (dist (node m n) (node (s * m + b * u * n) (b * u * m + (s - a * u) * n)))
      = s - a * u / 2 := by
  have hm' : 0 < s * m + b * u * n := by
    have : 0 ≤ b * u * n := by positivity
    nlinarith
  rw [cosh_dist_node _ _ _ _ hm hm', coshK]
  have hnum : (n * (s * m + b * u * n) - (b * u * m + (s - a * u) * n) * m) ^ 2
      + (m - (s * m + b * u * n)) ^ 2 = (2 * s - 2 - a * u) * (m * (s * m + b * u * n)) := by
    linear_combination (u ^ 2 * (b * m ^ 2 - a * m * n - b * n ^ 2)) * hc + (-m ^ 2) * hu
  rw [hnum]
  field_simp
  ring

/-- The step length of the rational line `a/b` driven by the unit `(s,u)`. -/
def ratStepLength (a s u : ℝ) : ℝ := arcosh (s - a * u / 2)

theorem dist_ratStep_eq (hb : 0 < b) (hm : 0 < m) (hn : 0 ≤ n) (hs : 0 < s) (hupos : 0 < u)
    (hc : b * m ^ 2 - a * m * n - b * n ^ 2 = b)
    (hu : s ^ 2 - a * s * u - b ^ 2 * u ^ 2 = 1) :
    dist (node m n) (node (s * m + b * u * n) (b * u * m + (s - a * u) * n))
      = ratStepLength a s u := by
  rw [← Real.arcosh_cosh (dist_nonneg (x := node m n)),
    cosh_dist_ratStep hb hm hn hs hupos hc hu, ratStepLength]

/-- **Exact collinearity.**  The centre, a node of the rational line and its image under the
automorphism are hyperbolically collinear: the distances add exactly. -/
theorem ratStep_collinear (ha : 0 ≤ a) (hb : 0 < b) (hm : 1 ≤ m) (hn : 0 ≤ n) (hs : 0 < s)
    (hupos : 0 < u) (hc : b * m ^ 2 - a * m * n - b * n ^ 2 = b)
    (hu : s ^ 2 - a * s * u - b ^ 2 * u ^ 2 = 1) :
    dist base (node m n)
        + dist (node m n) (node (s * m + b * u * n) (b * u * m + (s - a * u) * n))
      = dist base (node (s * m + b * u * n) (b * u * m + (s - a * u) * n)) := by
  have hm0 : 0 < m := by linarith
  have hm' : 0 < s * m + b * u * n := by
    have : 0 ≤ b * u * n := by positivity
    nlinarith
  have hdet : seedDet 1 0 m n (s * m + b * u * n) (b * u * m + (s - a * u) * n) = 0 := by
    refine seedDet_eq_zero_of_onConic (a / b) 1 0 m n _ _ (by ring) (ratConic_real_div hb hc) ?_
    exact ratConic_real_div hb (ratConic_step_real hc hu)
  rw [base]
  refine dist_add_dist_of_seedDet_zero 1 0 m n _ _ one_pos hm0 hm' hdet ?_
  -- the ordering condition `cosh d₁ · cosh d₂ ≤ cosh d₃`
  rw [coshK, coshK, coshK]
  have e1 : (1 : ℝ) + ((0 * m - n * 1) ^ 2 + (1 - m) ^ 2) / (2 * (1 * m))
      = (m ^ 2 + n ^ 2 + 1) / (2 * m) := by field_simp; ring
  have e2 : (1 : ℝ) + ((n * (s * m + b * u * n) - (b * u * m + (s - a * u) * n) * m) ^ 2
        + (m - (s * m + b * u * n)) ^ 2) / (2 * (m * (s * m + b * u * n)))
      = s - a * u / 2 := by
    have := cosh_dist_ratStep hb hm0 hn hs hupos hc hu
    rwa [cosh_dist_node _ _ _ _ hm0 hm', coshK] at this
  have e3 : (1 : ℝ) + ((0 * (s * m + b * u * n) - (b * u * m + (s - a * u) * n) * 1) ^ 2
        + (1 - (s * m + b * u * n)) ^ 2) / (2 * (1 * (s * m + b * u * n)))
      = ((s * m + b * u * n) ^ 2 + (b * u * m + (s - a * u) * n) ^ 2 + 1)
          / (2 * (s * m + b * u * n)) := by
    field_simp; ring
  rw [e1, e2, e3, div_mul_eq_mul_div, div_le_div_iff₀ (by positivity) (by positivity)]
  have key : ((s * m + b * u * n) ^ 2 + (b * u * m + (s - a * u) * n) ^ 2 + 1) * (2 * m)
      - (m ^ 2 + n ^ 2 + 1) * (s - a * u / 2) * (2 * (s * m + b * u * n))
      = a ^ 2 * m * n ^ 2 * u ^ 2 + a * m * s * u * (m ^ 2 + 3 * n ^ 2 - 1)
          + 4 * b ^ 2 * m * n ^ 2 * u ^ 2 + 4 * b * n ^ 3 * s * u + 4 * b * n * s * u := by
    linear_combination (-a * n * u ^ 2 + 2 * b * m * u ^ 2 + 6 * n * s * u) * hc
      + (-2 * m) * hu
  have hpos : 0 ≤ a ^ 2 * m * n ^ 2 * u ^ 2 + a * m * s * u * (m ^ 2 + 3 * n ^ 2 - 1)
      + 4 * b ^ 2 * m * n ^ 2 * u ^ 2 + 4 * b * n ^ 3 * s * u + 4 * b * n * s * u := by
    have t1 : 0 ≤ a ^ 2 * m * n ^ 2 * u ^ 2 := by positivity
    have t2 : 0 ≤ a * m * s * u * (m ^ 2 + 3 * n ^ 2 - 1) := by
      have : 0 ≤ m ^ 2 + 3 * n ^ 2 - 1 := by nlinarith
      have h0 : 0 ≤ a * m * s * u := by positivity
      exact mul_nonneg h0 this
    have t3 : 0 ≤ 4 * b ^ 2 * m * n ^ 2 * u ^ 2 := by positivity
    have t4 : 0 ≤ 4 * b * n ^ 3 * s * u := by positivity
    have t5 : 0 ≤ 4 * b * n * s * u := by positivity
    linarith
  linarith [key, hpos]

end RatGeometry

/-! ## 3. Distance quantization along a rational line -/

/-- **The orbit of the centre is a discrete geodesic ray.**  The `j`-th point of the orbit of the
base point `(1,0)` under the automorphism of the rational line `a/b` sits at distance exactly
`j · arcosh (s - a u/2)` from the centre.  Hence a rational line, like an integral one, is an
isometric copy of `ℕ`. -/
theorem dist_base_ratOrbit {a b s u : ℤ} (ha : 0 ≤ a) (hb : 0 < b) (hs : 0 < s) (hupos : 0 < u)
    (hu : RatUnit a b s u) (j : ℕ) :
    dist base (node ((ratOrbit a b s u (1, 0) j).1 : ℝ) ((ratOrbit a b s u (1, 0) j).2 : ℝ))
      = j * ratStepLength (a : ℝ) (s : ℝ) (u : ℝ) := by
  have haR : (0 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha
  have hbR : (0 : ℝ) < (b : ℝ) := by exact_mod_cast hb
  have hsR : (0 : ℝ) < (s : ℝ) := by exact_mod_cast hs
  have huR : (0 : ℝ) < (u : ℝ) := by exact_mod_cast hupos
  have huR' : (s : ℝ) ^ 2 - (a : ℝ) * s * u - (b : ℝ) ^ 2 * u ^ 2 = 1 := by
    simp only [RatUnit] at hu
    exact_mod_cast congrArg (fun x : ℤ => (x : ℝ)) hu
  induction j with
  | zero => simp [ratOrbit, base]
  | succ j ih =>
      obtain ⟨hp1, hp2⟩ := ratOrbit_base_pos hb hs hupos hu j
      have hm1 : (1 : ℝ) ≤ ((ratOrbit a b s u (1, 0) j).1 : ℝ) := by exact_mod_cast hp1
      have hn0 : (0 : ℝ) ≤ ((ratOrbit a b s u (1, 0) j).2 : ℝ) := by exact_mod_cast hp2
      have hcj : (b : ℝ) * ((ratOrbit a b s u (1, 0) j).1 : ℝ) ^ 2
            - (a : ℝ) * ((ratOrbit a b s u (1, 0) j).1 : ℝ)
              * ((ratOrbit a b s u (1, 0) j).2 : ℝ)
            - (b : ℝ) * ((ratOrbit a b s u (1, 0) j).2 : ℝ) ^ 2 = (b : ℝ) := by
        have := ratConic_ratOrbit hu (ratConic_base a b) j
        simp only [RatConic] at this
        exact_mod_cast congrArg (fun x : ℤ => (x : ℝ)) this
      have e1 : ((ratOrbit a b s u (1, 0) (j + 1)).1 : ℝ)
          = (s : ℝ) * ((ratOrbit a b s u (1, 0) j).1 : ℝ)
            + (b : ℝ) * (u : ℝ) * ((ratOrbit a b s u (1, 0) j).2 : ℝ) := by
        simp only [ratOrbit, ratStep]; push_cast; ring
      have e2 : ((ratOrbit a b s u (1, 0) (j + 1)).2 : ℝ)
          = (b : ℝ) * (u : ℝ) * ((ratOrbit a b s u (1, 0) j).1 : ℝ)
            + ((s : ℝ) - (a : ℝ) * (u : ℝ)) * ((ratOrbit a b s u (1, 0) j).2 : ℝ) := by
        simp only [ratOrbit, ratStep]; push_cast; ring
      rw [e1, e2, ← ratStep_collinear haR hbR hm1 hn0 hsR huR hcj huR', ih,
        dist_ratStep_eq hbR (by linarith) hn0 hsR huR hcj huR']
      push_cast
      ring

/-! ## 4. The radial invariant of a rational line, and the degenerate case -/

/-- Every point of the rational line `a/b` has radial invariant exactly `a/b`; combined with
`seedDet_base_eq_zero_iff_radial` this says that the whole line is radially aligned with the
centre of the picture. -/
theorem radial_ratConic {a b m n : ℝ} (hb : 0 < b) (hm : 0 < m) (hn : 0 < n)
    (hc : b * m ^ 2 - a * m * n - b * n ^ 2 = b) : radial m n = a / b := by
  rw [radial, div_eq_div_iff (by positivity) (by positivity)]
  nlinarith [hc]

/-- Two points of the same rational line are radially aligned with the base point. -/
theorem seedDet_base_eq_zero_ratConic {a b m₁ n₁ m₂ n₂ : ℝ} (hb : 0 < b) (hm₁ : 0 < m₁)
    (hn₁ : 0 < n₁) (hm₂ : 0 < m₂) (hn₂ : 0 < n₂)
    (hc₁ : b * m₁ ^ 2 - a * m₁ * n₁ - b * n₁ ^ 2 = b)
    (hc₂ : b * m₂ ^ 2 - a * m₂ * n₂ - b * n₂ ^ 2 = b) :
    seedDet 1 0 m₁ n₁ m₂ n₂ = 0 := by
  rw [seedDet_base_eq_zero_iff_radial m₁ n₁ m₂ n₂ hm₁ hn₁ hm₂ hn₂,
    radial_ratConic hb hm₁ hn₁ hc₁, radial_ratConic hb hm₂ hn₂ hc₂]

/-- **The degenerate case.**  When the discriminant `a² + 4b²` is a perfect square the conic
factors into two linear forms and the line may be empty.  For `ϱ = 3/2` (discriminant `25`) the
factorization `2m² - 3mn - 2n² = (2m + n)(m - 2n)` shows there is no node at all. -/
theorem ratConic_three_two_empty :
    {q : ℤ × ℤ | RatConic 3 2 q ∧ 0 < q.1 ∧ 0 < q.2} = ∅ := by
  ext ⟨m, n⟩
  simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, not_and]
  rintro hc hm hn
  simp only [RatConic] at hc
  have hfac : (2 * m + n) * (m - 2 * n) = 2 := by linarith [hc]
  have h1 : 3 ≤ 2 * m + n := by omega
  have h2 : 0 < m - 2 * n := by nlinarith
  nlinarith [hfac, h1, h2]

end BerggrenHyperbolic