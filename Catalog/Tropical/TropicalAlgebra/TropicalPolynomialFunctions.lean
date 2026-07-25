import Mathlib

/-! # One-variable max-plus tropical polynomial functions

This file develops the elementary theory of the one-variable max-plus tropical
polynomial over `ℝ`:
```
tropPoly c x = max_{i : Fin (d+1)} (c i + (i : ℝ) * x).
```

We model the finite maximum with a small reusable helper `finMax` built on
`Finset.sup'` over the nonempty type `Fin (n+1)`, prove the basic
characterization lemmas for `finMax`, and then derive the core properties of
`tropPoly`: the monomial bounds, the maximum-attainment statement, the
upper-bound characterization, monotonicity, (Jensen-form) convexity,
leading-term dominance (pointwise and a threshold version), and the explicit
degree-1 and degree-2 expansions.

All results are fully proved; there are no `sorry`s. -/

namespace TropicalPolynomialFunctions

/-! ## Finite maximum helper over `Fin (n+1)` -/

/-- The maximum of a real-valued function on the nonempty type `Fin (n+1)`. -/
noncomputable def finMax {n : ℕ} (f : Fin (n + 1) → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty f

/-- Every value is bounded above by the finite maximum. -/
theorem le_finMax {n : ℕ} (f : Fin (n + 1) → ℝ) (i : Fin (n + 1)) :
    f i ≤ finMax f :=
  Finset.le_sup' f (Finset.mem_univ i)

/-- The finite maximum is attained at some index. -/
theorem exists_finMax_eq {n : ℕ} (f : Fin (n + 1) → ℝ) :
    ∃ i, finMax f = f i := by
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty) f
  exact ⟨i, hi⟩

/-- Upper-bound characterization of the finite maximum. -/
theorem finMax_le_iff {n : ℕ} (f : Fin (n + 1) → ℝ) (y : ℝ) :
    finMax f ≤ y ↔ ∀ i, f i ≤ y := by
  rw [finMax, Finset.sup'_le_iff]
  constructor
  · intro h i; exact h i (Finset.mem_univ i)
  · intro h i _; exact h i

/-! ## The tropical polynomial -/

/-- The one-variable max-plus tropical polynomial with coefficients
`c : Fin (d+1) → ℝ`, evaluated at `x`, using the real slopes `(i : ℝ)`. -/
noncomputable def tropPoly {d : ℕ} (c : Fin (d + 1) → ℝ) (x : ℝ) : ℝ :=
  finMax (fun i => c i + (i : ℝ) * x)

/-- Every monomial lies below the tropical polynomial. -/
theorem tropPoly_monomial_le {d : ℕ} (c : Fin (d + 1) → ℝ) (x : ℝ)
    (i : Fin (d + 1)) : c i + (i : ℝ) * x ≤ tropPoly c x := by
  rw [tropPoly]; exact le_finMax (fun j => c j + (j : ℝ) * x) i

/-- For every `x`, some monomial attains the maximum. -/
theorem tropPoly_eq_monomial {d : ℕ} (c : Fin (d + 1) → ℝ) (x : ℝ) :
    ∃ i, tropPoly c x = c i + (i : ℝ) * x :=
  exists_finMax_eq _

/-- Upper-bound characterization of the tropical polynomial. -/
theorem tropPoly_le_iff {d : ℕ} (c : Fin (d + 1) → ℝ) (x y : ℝ) :
    tropPoly c x ≤ y ↔ ∀ i, c i + (i : ℝ) * x ≤ y :=
  finMax_le_iff _ y

/-! ## Monotonicity -/

/-- The tropical polynomial is monotone: nonnegative slopes only increase. -/
theorem tropPoly_mono {d : ℕ} (c : Fin (d + 1) → ℝ) {x y : ℝ} (hxy : x ≤ y) :
    tropPoly c x ≤ tropPoly c y := by
  rw [tropPoly_le_iff]
  intro i
  have hi : (0 : ℝ) ≤ (i : ℝ) := by positivity
  have : c i + (i : ℝ) * x ≤ c i + (i : ℝ) * y := by
    have := mul_le_mul_of_nonneg_left hxy hi
    linarith
  exact this.trans (tropPoly_monomial_le c y i)

/-! ## Convexity (Jensen inequality form) -/

/-- The tropical polynomial is convex (elementary Jensen form). -/
theorem tropPoly_convex {d : ℕ} (c : Fin (d + 1) → ℝ) (x y t : ℝ)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    tropPoly c (t * x + (1 - t) * y) ≤ t * tropPoly c x + (1 - t) * tropPoly c y := by
  rw [tropPoly_le_iff]
  intro i
  have hsplit : c i + (i : ℝ) * (t * x + (1 - t) * y)
      = t * (c i + (i : ℝ) * x) + (1 - t) * (c i + (i : ℝ) * y) := by ring
  rw [hsplit]
  have h1 : t * (c i + (i : ℝ) * x) ≤ t * tropPoly c x :=
    mul_le_mul_of_nonneg_left (tropPoly_monomial_le c x i) ht0
  have h2 : (1 - t) * (c i + (i : ℝ) * y) ≤ (1 - t) * tropPoly c y :=
    mul_le_mul_of_nonneg_left (tropPoly_monomial_le c y i) (by linarith)
  linarith

/-! ## Leading-term dominance -/

/-- Pointwise leading-term dominance: if the leading monomial dominates all
monomials at `x`, then the tropical polynomial equals the leading monomial. -/
theorem tropPoly_eq_leading {d : ℕ} (c : Fin (d + 1) → ℝ) (x : ℝ)
    (h : ∀ i, c i + (i : ℝ) * x ≤ c (Fin.last d) + (d : ℝ) * x) :
    tropPoly c x = c (Fin.last d) + (d : ℝ) * x := by
  apply le_antisymm
  · rw [tropPoly_le_iff]; exact h
  · have := tropPoly_monomial_le c x (Fin.last d)
    simpa using this

/-- Threshold leading-term dominance: if the leading monomial dominates all
others at a threshold `T`, then it dominates for every `x ≥ T`. -/
theorem tropPoly_eq_leading_threshold {d : ℕ} (c : Fin (d + 1) → ℝ) (T x : ℝ)
    (hT : ∀ i, c i + (i : ℝ) * T ≤ c (Fin.last d) + (d : ℝ) * T)
    (hx : T ≤ x) :
    tropPoly c x = c (Fin.last d) + (d : ℝ) * x := by
  apply tropPoly_eq_leading
  intro i
  have hid : (i : ℝ) ≤ (d : ℝ) := by exact_mod_cast i.is_le
  have hxT : (0 : ℝ) ≤ x - T := by linarith
  have hslope : (0 : ℝ) ≤ (d : ℝ) - (i : ℝ) := by linarith
  have key : c i + (i : ℝ) * x
      = (c i + (i : ℝ) * T) + (i : ℝ) * (x - T) := by ring
  have hlead : c (Fin.last d) + (d : ℝ) * x
      = (c (Fin.last d) + (d : ℝ) * T) + (d : ℝ) * (x - T) := by ring
  rw [key, hlead]
  have h1 := hT i
  have h2 : (i : ℝ) * (x - T) ≤ (d : ℝ) * (x - T) :=
    mul_le_mul_of_nonneg_right hid hxT
  linarith

/-! ## Degree-1 and degree-2 expansions -/

/-- Degree-1 expansion: `tropPoly c x = max (c 0) (c 1 + x)`. -/
theorem tropPoly_deg1 (c : Fin 2 → ℝ) (x : ℝ) :
    tropPoly c x = max (c 0) (c 1 + x) := by
  apply le_antisymm
  · rw [tropPoly_le_iff]
    intro i
    fin_cases i
    · simp
    · simp
  · apply max_le
    · have := tropPoly_monomial_le c x 0
      simpa using this
    · have := tropPoly_monomial_le c x 1
      simpa using this

/-- Degree-2 expansion: `tropPoly c x = max (c 0) (max (c 1 + x) (c 2 + 2*x))`. -/
theorem tropPoly_deg2 (c : Fin 3 → ℝ) (x : ℝ) :
    tropPoly c x = max (c 0) (max (c 1 + x) (c 2 + 2 * x)) := by
  apply le_antisymm
  · rw [tropPoly_le_iff]
    intro i
    fin_cases i
    · simp
    · simp
    · simp
  · apply max_le
    · have := tropPoly_monomial_le c x 0
      simpa using this
    · apply max_le
      · have := tropPoly_monomial_le c x 1
        simpa using this
      · have := tropPoly_monomial_le c x 2
        simpa using this

end TropicalPolynomialFunctions