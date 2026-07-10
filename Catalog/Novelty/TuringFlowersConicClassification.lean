import Mathlib

/-!
# Turing's Flowers II: The General Conic Classification of Morphogenesis

This file deepens the algebraic-geometry view of Turing patterns developed in
`TuringFlowersAlgebraicGeometry.lean`.  There the boundedness dichotomy separating
*spots* from *labyrinths* was established for the **axis-aligned** conics
`{a x² + b y² = c}` (no cross term) and for single Fourier modes.  The morphology of
a real reaction–diffusion pattern, however, is generically an **anisotropic** conic
carrying a genuine cross term `b x y`: rotating the coordinate frame mixes the two
spatial directions.  The correct invariant is therefore not the sign pattern of the
diagonal coefficients but the **discriminant** of the quadratic form,

```
    Δ = b² − 4 a c .
```

The classical real classification of conics states that the level set of
`q(x,y) = a x² + b x y + c y²` is

* an **ellipse** (bounded — a spot) when the form is positive definite, i.e.
  `a > 0` and `Δ < 0`;
* a **hyperbola** (unbounded — a labyrinth) when the form is indefinite, i.e.
  `Δ > 0`.

We prove both halves of this dichotomy *with the cross term present*, then upgrade the
bounded half to a genuine **topological** statement — the spot level set is
**compact** — bridging the algebraic invariant `Δ` to Heine–Borel compactness.  On the
mode-counting side we sharpen the "modes = degree" correspondence to **products** and
**superpositions** of modes: a product of an `m`-mode and an `n`-mode is a polynomial
of degree *exactly* `m + n`, and a two-mode superposition with a nonzero top harmonic
has degree *exactly* the top mode number.

-- !-- Lab Notes -- !--

**Hypothesis.**  The spot/labyrinth dichotomy is governed entirely by the sign of the
discriminant `Δ = b² − 4ac` of the pattern's leading quadratic form, independently of
the coordinate frame; the bounded (spot) case is not merely metrically bounded but
*compact*, and the "modes = degree" law is stable under both multiplication and
addition of modes.

**Experiment.**  We completed the square in the rotation-invariant identity
`4a·q = (2ax+by)² + Δ'·y²` (with `Δ' = 4ac − b² = −Δ`).  When `Δ' > 0` this bounds
both coordinates and yields compactness via Heine–Borel; when `Δ' < 0` it produces an
explicit one-parameter family `x(s) = (√(Δ'·s²+4ak)+... )/(2a)`, `y = s` lying on the
level set with `‖·‖ → ∞`.  For the degree laws we used the Chebyshev correspondence
`cos(nθ) = Tₙ(cos θ)` together with `deg(Tₘ·Tₙ) = m+n` and the additivity of degree
under a strictly dominant leading term.

**Analysis.**  The discriminant is the right invariant: the proofs never assume the
frame is aligned, so they survive an arbitrary rotation.  The compactness upgrade is
clean because the level set is a closed condition and the completed-square bound is a
closed ball.  The product/superposition degree laws show the correspondence is a ring
homomorphism phenomenon, not an accident of single modes.

**Critique.**  None of the results is vacuous: boundedness exhibits an explicit radius,
unboundedness an explicit escaping family, and the capstone `spot_ne_labyrinth_general`
proves an honest inequality of subsets of the plane by pitting compactness against an
escaping point.  The degree statements assert equalities (`= m+n`, `= n`), not merely
inequalities, so no degenerate collapse can hide inside them.

**Synthesis.**  Anisotropic morphogenesis is discriminant geometry: `Δ < 0` compact
spots, `Δ > 0` unbounded labyrinths, with the number of modes reading off as an exact
polynomial degree that is additive under products and stable under superposition.
-/

open Polynomial

namespace TuringFlowersConic

/-! ## Positive-definite forms: spots are compact -/

/-- A quadratic form with `a > 0` and non-negative discriminant complement
`4ac ≥ b²` is **positive semidefinite**: it never takes a negative value.  This is the
algebraic core of the spot (bounded) regime. -/
theorem posdef_quadratic_nonneg (a b c x y : ℝ) (ha : 0 < a) (hD : b ^ 2 ≤ 4 * a * c) :
    0 ≤ a * x ^ 2 + b * x * y + c * y ^ 2 := by
  have h4a : (0 : ℝ) < 4 * a := by linarith
  have hkey : 0 ≤ 4 * a * (a * x ^ 2 + b * x * y + c * y ^ 2) := by
    nlinarith [sq_nonneg (2 * a * x + b * y), sq_nonneg y]
  nlinarith

/-- **Spots are bounded (anisotropic form).**  If the leading quadratic form is
positive definite — `a > 0` and `b² < 4ac` — then every level set
`{a x² + b x y + c y² = k}` is contained in a disc of explicit squared radius
`4k(a+c)/(4ac − b²)`.  This generalises the axis-aligned ellipse bound to forms with a
cross term, i.e. to ellipses in *any* orientation. -/
theorem posdef_quadratic_bounded (a b c k : ℝ) (ha : 0 < a) (hD : b ^ 2 < 4 * a * c) :
    ∃ R : ℝ, ∀ p : ℝ × ℝ,
      a * p.1 ^ 2 + b * p.1 * p.2 + c * p.2 ^ 2 = k → p.1 ^ 2 + p.2 ^ 2 ≤ R := by
  have hc : 0 < c := by nlinarith [sq_nonneg b]
  have hD' : 0 < 4 * a * c - b ^ 2 := by linarith
  refine ⟨4 * k * (a + c) / (4 * a * c - b ^ 2), ?_⟩
  intro p hp
  have hy : (4 * a * c - b ^ 2) * p.2 ^ 2 ≤ 4 * a * k := by
    nlinarith [sq_nonneg (2 * a * p.1 + b * p.2)]
  have hx : (4 * a * c - b ^ 2) * p.1 ^ 2 ≤ 4 * c * k := by
    nlinarith [sq_nonneg (b * p.1 + 2 * c * p.2)]
  rw [le_div_iff₀ hD']
  nlinarith

/-- **Spots are compact.**  For a positive-definite leading form (`a > 0`, `b² < 4ac`)
the level set `{a x² + b x y + c y² = k}` is a *compact* subset of the plane.  The
level set is closed (a level set of a continuous polynomial map) and bounded (previous
theorem), so compactness follows from Heine–Borel.  This lifts the metric spot/labyrinth
dichotomy to a topological invariant: spots are compact, labyrinths are not. -/
theorem posdef_level_set_isCompact (a b c k : ℝ) (ha : 0 < a) (hD : b ^ 2 < 4 * a * c) :
    IsCompact {p : ℝ × ℝ | a * p.1 ^ 2 + b * p.1 * p.2 + c * p.2 ^ 2 = k} := by
  have hc : 0 < c := by nlinarith [sq_nonneg b]
  have hD' : 0 < 4 * a * c - b ^ 2 := by linarith
  have hclosed : IsClosed {p : ℝ × ℝ | a * p.1 ^ 2 + b * p.1 * p.2 + c * p.2 ^ 2 = k} := by
    apply isClosed_eq
    · fun_prop
    · fun_prop
  rw [Metric.isCompact_iff_isClosed_bounded]
  refine ⟨hclosed, ?_⟩
  rw [Metric.isBounded_iff_subset_closedBall (0 : ℝ × ℝ)]
  refine ⟨Real.sqrt (4 * k * (a + c) / (4 * a * c - b ^ 2)), ?_⟩
  intro p hp
  simp only [Set.mem_setOf_eq] at hp
  rw [Metric.mem_closedBall]
  set B := 4 * k * (a + c) / (4 * a * c - b ^ 2) with hB
  have hbound : p.1 ^ 2 + p.2 ^ 2 ≤ B := by
    have hy : (4 * a * c - b ^ 2) * p.2 ^ 2 ≤ 4 * a * k := by
      nlinarith [sq_nonneg (2 * a * p.1 + b * p.2)]
    have hx : (4 * a * c - b ^ 2) * p.1 ^ 2 ≤ 4 * c * k := by
      nlinarith [sq_nonneg (b * p.1 + 2 * c * p.2)]
    rw [hB, le_div_iff₀ hD']; nlinarith
  have hknn : 0 ≤ B := le_trans (by positivity) hbound
  rw [dist_eq_norm, sub_zero, Prod.norm_def]
  apply max_le
  · rw [Real.norm_eq_abs, ← Real.sqrt_sq_eq_abs]
    apply Real.sqrt_le_sqrt; nlinarith [sq_nonneg p.2]
  · rw [Real.norm_eq_abs, ← Real.sqrt_sq_eq_abs]
    apply Real.sqrt_le_sqrt; nlinarith [sq_nonneg p.1]

/-! ## Indefinite forms: labyrinths are unbounded -/

/-- **Labyrinths are unbounded (anisotropic form).**  If the leading quadratic form is
indefinite — positive discriminant `b² − 4ac > 0` with `a > 0` — then for *every*
target value `k` the level set `{a x² + b x y + c y² = k}` contains points of
arbitrarily large norm.  The witness is the explicit family `y = s`,
`x = (√(Δ·s² + 4ak) − b s)/(2a)` with `Δ = b² − 4ac`, obtained from the completed
square `4a·q = (2ax+by)² − Δ·y²`.  This is the algebraic hallmark of a space-filling
labyrinth and generalises the axis-aligned hyperbola to any orientation. -/
theorem indefinite_quadratic_unbounded (a b c k : ℝ) (ha : 0 < a) (hD : 0 < b ^ 2 - 4 * a * c) :
    ∀ R : ℝ, ∃ p : ℝ × ℝ,
      a * p.1 ^ 2 + b * p.1 * p.2 + c * p.2 ^ 2 = k ∧ R < p.1 ^ 2 + p.2 ^ 2 := by
  intro R
  set D := b ^ 2 - 4 * a * c with hDdef
  set s := Real.sqrt (|R| + |4 * a * k / D| + 1) with hs
  have hs2 : s ^ 2 = |R| + |4 * a * k / D| + 1 := Real.sq_sqrt (by positivity)
  set W := D * s ^ 2 + 4 * a * k with hW
  have hWpos : 0 < W := by
    rw [hW, hs2]
    have h1 : D * |4 * a * k / D| = |4 * a * k| := by
      rw [abs_div, abs_of_pos hD]; field_simp
    nlinarith [abs_nonneg R, le_abs_self (4 * a * k), neg_abs_le (4 * a * k),
      mul_pos hD (show (0 : ℝ) < |R| + 1 by positivity)]
  have hsqW : Real.sqrt W ^ 2 = W := Real.sq_sqrt (le_of_lt hWpos)
  refine ⟨((Real.sqrt W - b * s) / (2 * a), s), ?_, ?_⟩
  · have key : 2 * a * ((Real.sqrt W - b * s) / (2 * a)) + b * s = Real.sqrt W := by
      field_simp; ring
    have hq : 4 * a * (a * ((Real.sqrt W - b * s) / (2 * a)) ^ 2
          + b * ((Real.sqrt W - b * s) / (2 * a)) * s + c * s ^ 2)
        = (2 * a * ((Real.sqrt W - b * s) / (2 * a)) + b * s) ^ 2 - D * s ^ 2 := by
      field_simp; ring
    rw [key, hsqW] at hq
    have heq : 4 * a * (a * ((Real.sqrt W - b * s) / (2 * a)) ^ 2
        + b * ((Real.sqrt W - b * s) / (2 * a)) * s + c * s ^ 2) = 4 * a * k := by
      rw [hq, hW]; ring
    have h4a : (4 : ℝ) * a ≠ 0 := by positivity
    have := mul_left_cancel₀ h4a heq
    convert this using 2
  · simp only []
    have hRs : R < s ^ 2 := by rw [hs2]; nlinarith [abs_nonneg (4 * a * k / D), le_abs_self R]
    nlinarith [sq_nonneg ((Real.sqrt W - b * s) / (2 * a))]

/-! ## Modes and degree: products and superpositions -/

/-- **Products of modes multiply degree.**  The product of an `m`-mode and an `n`-mode,
`θ ↦ cos(mθ)·cos(nθ)`, is a real polynomial of degree *exactly* `m + n` in the cosine
coordinate `X = cos θ`.  Thus mode multiplication corresponds to degree addition,
extending the single-mode "modes = degree" law to interacting modes. -/
theorem mode_product_degree (m n : ℕ) :
    ∃ P : Polynomial ℝ, P.natDegree = m + n ∧
      ∀ θ : ℝ, P.eval (Real.cos θ) = Real.cos (m * θ) * Real.cos (n * θ) := by
  have hTne : ∀ j : ℕ, (Polynomial.Chebyshev.T ℝ (j : ℤ)) ≠ 0 := by
    intro j h
    have := Polynomial.Chebyshev.T_real_cos 0 (j : ℤ)
    rw [h] at this; simp at this
  refine ⟨Polynomial.Chebyshev.T ℝ (m : ℤ) * Polynomial.Chebyshev.T ℝ (n : ℤ), ?_, ?_⟩
  · rw [Polynomial.natDegree_mul (hTne m) (hTne n),
      Polynomial.Chebyshev.natDegree_T, Polynomial.Chebyshev.natDegree_T]
    simp
  · intro θ
    rw [Polynomial.eval_mul, Polynomial.Chebyshev.T_real_cos, Polynomial.Chebyshev.T_real_cos]
    push_cast; ring_nf

/-- **Superposition is degree-stable.**  A two-mode superposition
`θ ↦ α·cos(mθ) + β·cos(nθ)` with `m < n` and a nonzero top harmonic `β ≠ 0` is a
polynomial of degree *exactly* `n`: the highest active mode fixes the algebraic degree
regardless of the lower-mode amplitude `α`.  This is the linear-superposition form of
the "modes = degree" correspondence. -/
theorem two_mode_superposition_degree (m n : ℕ) (α β : ℝ) (hmn : m < n) (hβ : β ≠ 0) :
    ∃ P : Polynomial ℝ, P.natDegree = n ∧
      ∀ θ : ℝ, P.eval (Real.cos θ) = α * Real.cos (m * θ) + β * Real.cos (n * θ) := by
  refine ⟨C α * Polynomial.Chebyshev.T ℝ (m : ℤ) + C β * Polynomial.Chebyshev.T ℝ (n : ℤ), ?_, ?_⟩
  · have hright : (C β * Polynomial.Chebyshev.T ℝ (n : ℤ)).natDegree = n := by
      rw [Polynomial.natDegree_C_mul hβ, Polynomial.Chebyshev.natDegree_T]; simp
    have hleft : (C α * Polynomial.Chebyshev.T ℝ (m : ℤ)).natDegree ≤ m := by
      calc (C α * Polynomial.Chebyshev.T ℝ (m : ℤ)).natDegree
          ≤ (Polynomial.Chebyshev.T ℝ (m : ℤ)).natDegree := Polynomial.natDegree_C_mul_le _ _
        _ = m := by rw [Polynomial.Chebyshev.natDegree_T]; simp
    rw [natDegree_add_eq_right_of_natDegree_lt (by rw [hright]; omega), hright]
  · intro θ
    simp [Polynomial.Chebyshev.T_real_cos]

/-! ## Capstone: spots and labyrinths are genuinely different varieties -/

/-- **Discriminant morphological dichotomy.**  A positive-definite (spot) level set
and an indefinite (labyrinth) level set at the same value `k` are never the same subset
of the plane.  The spot set is bounded while the labyrinth set contains points of
arbitrarily large norm, so no orientation or amplitude can identify the two.  This is
the coordinate-free, cross-term-aware form of the spot/labyrinth dichotomy, keyed on
the sign of the discriminant. -/
theorem spot_ne_labyrinth_general
    (a b c a' b' c' k : ℝ) (ha : 0 < a) (hD : b ^ 2 < 4 * a * c)
    (ha' : 0 < a') (hD' : 0 < b' ^ 2 - 4 * a' * c') :
    {p : ℝ × ℝ | a * p.1 ^ 2 + b * p.1 * p.2 + c * p.2 ^ 2 = k}
      ≠ {p : ℝ × ℝ | a' * p.1 ^ 2 + b' * p.1 * p.2 + c' * p.2 ^ 2 = k} := by
  obtain ⟨R, hR⟩ := posdef_quadratic_bounded a b c k ha hD
  intro heq
  obtain ⟨q, hq_lab, hq_big⟩ := indefinite_quadratic_unbounded a' b' c' k ha' hD' R
  have hmem : q ∈ {p : ℝ × ℝ | a' * p.1 ^ 2 + b' * p.1 * p.2 + c' * p.2 ^ 2 = k} := hq_lab
  rw [← heq] at hmem
  simp only [Set.mem_setOf_eq] at hmem
  have := hR q hmem
  linarith

end TuringFlowersConic