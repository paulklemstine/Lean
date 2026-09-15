import MachineLearning.BerggrenEuclidParam

/-!
# The area function of the Berggren tree and congruent numbers — definitions

The catalog contains a complete theory of the Berggren tree of primitive Pythagorean
triples (`MachineLearning/BerggrenEuclidParam.lean`): the tree's nodes are exactly the
triples `euclidTriple m n = (m² - n², 2mn, m² + n²)` with admissible Euclid parameters
`IsParam m n`, and the two seeds `(3,4,5)` and `(4,3,5)` together exhaust the positive
primitive Pythagorean triples (`isPPT_iff_node_or_swap`).

This file introduces the **area function** of the tree,

```
triArea (a, b, c) = a * b / 2,      euclidArea m n = m * n * (m² - n²),
```

and the classical notion of a **congruent number** (the area of a rational right
triangle), together with the elementary invariance properties that link them: the
congruent-number property only depends on the class of `N` modulo squares of nonzero
rationals.

## Main definitions

* `IsCongruentNumber N` — `N` is the area of a right triangle with positive rational legs.
* `euclidArea m n` — the area `mn(m² - n²)` of the Euclid seed `(m, n)`.
* `triArea v` — the area of a triple, as a rational number.

## Main results

* `triArea_euclidTriple` — the area of a tree node in Euclid coordinates.
* `isCongruentNumber_mul_sq_iff` — square-class invariance of congruence.
* `isCongruentNumber_euclidArea` — every Euclid seed area is a congruent number.
* `six_dvd_euclidArea` — every node area is divisible by 6.
-/

namespace BerggrenCongruent

open BerggrenStars

/-- `N` is a **congruent number**: it is the area of a right triangle all of whose sides
are positive rationals. -/
def IsCongruentNumber (N : ℚ) : Prop :=
  ∃ a b c : ℚ, 0 < a ∧ 0 < b ∧ 0 < c ∧ a ^ 2 + b ^ 2 = c ^ 2 ∧ a * b = 2 * N

/-- The area of the Euclid seed `(m, n)`, i.e. of the triple `(m²-n², 2mn, m²+n²)`. -/
def euclidArea (m n : ℤ) : ℤ := m * n * (m ^ 2 - n ^ 2)

/-- The area of an integer triple, as a rational number. -/
def triArea (v : Vec) : ℚ := (v.1 : ℚ) * (v.2.1 : ℚ) / 2

@[simp] theorem triArea_mk (a b c : ℤ) : triArea (a, b, c) = (a : ℚ) * b / 2 := rfl

/-- **The area function in Euclid coordinates.** -/
@[simp] theorem triArea_euclidTriple (m n : ℤ) :
    triArea (euclidTriple m n) = (euclidArea m n : ℚ) := by
  simp only [euclidTriple, triArea, euclidArea]
  push_cast
  ring

theorem euclidArea_pos {m n : ℤ} (hn : 0 < n) (hmn : n < m) : 0 < euclidArea m n := by
  have hm : 0 < m := lt_trans hn hmn
  have h1 : 0 < m ^ 2 - n ^ 2 := by nlinarith
  have : 0 < m * n := mul_pos hm hn
  exact mul_pos this h1

/-- A positive rational right triangle with integer sides exhibits its area as a
congruent number. -/
theorem isCongruentNumber_of_intTriple {x y z : ℤ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hpy : x ^ 2 + y ^ 2 = z ^ 2) : IsCongruentNumber (triArea (x, y, z)) := by
  refine ⟨(x : ℚ), (y : ℚ), (z : ℚ), by exact_mod_cast hx, by exact_mod_cast hy,
    by exact_mod_cast hz, ?_, ?_⟩
  · exact_mod_cast congrArg (fun t : ℤ => (t : ℚ)) hpy
  · simp only [triArea]
    ring

/-- Scaling a rational right triangle by `t` scales its area by `t²`: one direction of
square-class invariance. -/
theorem IsCongruentNumber.mul_sq {N : ℚ} (h : IsCongruentNumber N) {t : ℚ} (ht : 0 < t) :
    IsCongruentNumber (N * t ^ 2) := by
  obtain ⟨a, b, c, ha, hb, hc, hpy, harea⟩ := h
  refine ⟨a * t, b * t, c * t, mul_pos ha ht, mul_pos hb ht, mul_pos hc ht,
    by rw [mul_pow, mul_pow, mul_pow, ← add_mul, hpy], ?_⟩
  calc a * t * (b * t) = (a * b) * t ^ 2 := by ring
    _ = 2 * (N * t ^ 2) := by rw [harea]; ring

/-- **Square-class invariance.** `N` is congruent iff `N t²` is, for any nonzero rational
`t`.  In particular the congruent-number property of a positive integer only depends on
its squarefree part. -/
theorem isCongruentNumber_mul_sq_iff (N : ℚ) {t : ℚ} (ht : t ≠ 0) :
    IsCongruentNumber (N * t ^ 2) ↔ IsCongruentNumber N := by
  have habs : (0:ℚ) < |t| := abs_pos.mpr ht
  have hsq : |t| ^ 2 = t ^ 2 := sq_abs t
  constructor
  · intro h
    have := h.mul_sq (t := |t|⁻¹) (by positivity)
    have hrw : N * t ^ 2 * (|t|⁻¹) ^ 2 = N := by
      rw [inv_pow, hsq]
      field_simp
    rwa [hrw] at this
  · intro h
    have := h.mul_sq (t := |t|) habs
    rwa [hsq] at this

/-- Every Euclid seed with admissible parameters has congruent area. -/
theorem isCongruentNumber_euclidArea {m n : ℤ} (h : IsParam m n) :
    IsCongruentNumber ((euclidArea m n : ℤ) : ℚ) := by
  have hm : 0 < m := h.mpos
  have hx : 0 < m ^ 2 - n ^ 2 := by nlinarith [h.npos, h.lt]
  have hy : 0 < 2 * m * n := by nlinarith [h.npos]
  have hz : 0 < m ^ 2 + n ^ 2 := by nlinarith [h.npos]
  have hpy : (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring
  have key : triArea ((m ^ 2 - n ^ 2 : ℤ), (2 * m * n : ℤ), (m ^ 2 + n ^ 2 : ℤ))
      = ((euclidArea m n : ℤ) : ℚ) := by
    simp only [triArea, euclidArea]
    push_cast
    ring
  exact key ▸ isCongruentNumber_of_intTriple hx hy hz hpy

/-- **Every node area is divisible by 6.**  (The classical fact that the area of a
Pythagorean triangle is a multiple of 6, in Euclid coordinates.) -/
theorem six_dvd_euclidArea (m n : ℤ) : (6 : ℤ) ∣ euclidArea m n := by
  have hz : ((euclidArea m n : ℤ) : ZMod 6) = 0 := by
    simp only [euclidArea]
    push_cast
    generalize ((m : ℤ) : ZMod 6) = x
    generalize ((n : ℤ) : ZMod 6) = y
    revert x y
    decide
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ 6).mp hz

end BerggrenCongruent