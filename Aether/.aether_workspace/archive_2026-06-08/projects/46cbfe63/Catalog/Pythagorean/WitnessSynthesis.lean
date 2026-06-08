import Mathlib

/-!
# Compositional Witness Synthesis for Pythagorean Triples

## Overview

This file establishes the algorithmic theory of **witness synthesis** for Pythagorean
triples: given structural parameters, we constructively produce triples (a, b, c) with
a² + b² = c², and prove that the synthesis is correct, compositional, and satisfies
tight size bounds.

## Key Results

1. **Parametric witness correctness** (`parametric_witness_correct`):
   The classical parametrization (m² - n², 2mn, m² + n²) always yields a valid
   Pythagorean triple.

2. **Berggren compositional synthesis** (`berggren_compose_preserves_pyth`):
   Applying any Berggren matrix to a Pythagorean triple yields another Pythagorean
   triple — the synthesis is *compositional*.

3. **Berggren Lorentz invariance** (`berggren_lorentz_invariant`):
   The Lorentz form a² + b² - c² is preserved by all Berggren transformations.

4. **Path synthesis correctness** (`path_synthesis_correct`):
   Every triple synthesized via any Berggren path from (3,4,5) is Pythagorean.

5. **Witness Gaussian composition** (`witness_gaussian_composition`):
   Two Pythagorean triples can be composed via the Brahmagupta–Fibonacci identity
   to produce a new Pythagorean triple.

6. **No isosceles Pythagorean triple** (`no_isosceles_pythagorean_triple`):
   There is no triple (a, a, c) — a consequence of the irrationality of √2.
-/

open Finset BigOperators

/-! ## §1. Parametric Witness Construction -/

/-- A Pythagorean triple is a triple of integers (a, b, c) with a² + b² = c². -/
def IsPythagoreanTriple (a b c : ℤ) : Prop :=
  a ^ 2 + b ^ 2 = c ^ 2

/-- The parametric witness: given m, n, produces (m² - n², 2mn, m² + n²). -/
def parametricWitness (m n : ℤ) : ℤ × ℤ × ℤ :=
  (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

/-- **Theorem (Parametric Witness Correctness):**
    For any integers m, n, the parametric family (m² - n², 2mn, m² + n²)
    satisfies the Pythagorean equation. -/
theorem parametric_witness_correct (m n : ℤ) :
    IsPythagoreanTriple (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  unfold IsPythagoreanTriple; ring

/-- The witness components satisfy the Pythagorean equation (tuple form). -/
theorem parametric_witness_is_pyth (m n : ℤ) :
    let w := parametricWitness m n
    w.1 ^ 2 + w.2.1 ^ 2 = w.2.2 ^ 2 := by
  simp [parametricWitness]; ring

/-! ## §2. Witness Size Bounds -/

/-- The hypotenuse of a parametric witness is m² + n². -/
theorem witness_hypotenuse_eq (m n : ℤ) :
    (parametricWitness m n).2.2 = m ^ 2 + n ^ 2 := by
  simp [parametricWitness]

/-- **Theorem (Hypotenuse Upper Bound):**
    For m > n > 0, the hypotenuse satisfies c ≤ 2m². -/
theorem witness_hypotenuse_bound (m n : ℤ) (hmn : n < m) (hn : 0 < n) :
    (parametricWitness m n).2.2 ≤ 2 * m ^ 2 := by
  simp [parametricWitness]
  nlinarith [sq_nonneg n, sq_nonneg (m - n)]

/-- The hypotenuse is at least m². -/
theorem witness_hypotenuse_lower (m n : ℤ) :
    m ^ 2 ≤ (parametricWitness m n).2.2 := by
  simp [parametricWitness]
  nlinarith [sq_nonneg n]

/-- Both legs are strictly less than the hypotenuse when m > n > 0. -/
theorem witness_leg_bounds (m n : ℤ) (_hm : 0 < m) (hmn : 0 < n) (h : n < m) :
    (parametricWitness m n).1 < (parametricWitness m n).2.2 ∧
    (parametricWitness m n).2.1 < (parametricWitness m n).2.2 := by
  constructor <;> simp [parametricWitness] <;> nlinarith [sq_nonneg m, sq_nonneg n, sq_nonneg (m - n)]

/-- The first leg m² - n² is positive when m > n > 0. -/
theorem witness_first_leg_pos (m n : ℤ) (hmn : n < m) (hn : 0 < n) :
    0 < (parametricWitness m n).1 := by
  simp [parametricWitness]; nlinarith [sq_nonneg (m - n)]

/-- The second leg 2mn is positive when m, n > 0. -/
theorem witness_second_leg_pos (m n : ℤ) (hm : 0 < m) (hn : 0 < n) :
    0 < (parametricWitness m n).2.1 := by
  simp [parametricWitness]; nlinarith

/-! ## §3. Compositional Berggren Synthesis -/

/-- The three Berggren matrices as functions on integer triples. -/
def berggrenMatrix : Fin 3 → (ℤ × ℤ × ℤ → ℤ × ℤ × ℤ)
  | 0 => fun ⟨a, b, c⟩ => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | 1 => fun ⟨a, b, c⟩ => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | 2 => fun ⟨a, b, c⟩ => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- **Theorem (Berggren Lorentz Invariant):**
    The Lorentz form a² + b² - c² is preserved by all Berggren matrices.
    This is the deep geometric reason: Berggren matrices lie in O(2,1;ℤ). -/
theorem berggren_lorentz_invariant (i : Fin 3) (a b c : ℤ) :
    let t := berggrenMatrix i (a, b, c)
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  fin_cases i <;> simp [berggrenMatrix] <;> ring

/-- **Theorem (Berggren Compositional Synthesis):**
    Each Berggren transformation preserves the Pythagorean property. -/
theorem berggren_compose_preserves_pyth (i : Fin 3) (a b c : ℤ)
    (h : IsPythagoreanTriple a b c) :
    let t := berggrenMatrix i (a, b, c)
    IsPythagoreanTriple t.1 t.2.1 t.2.2 := by
  unfold IsPythagoreanTriple at *
  have inv := berggren_lorentz_invariant i a b c
  linarith

/-- The root triple (3, 4, 5) is a Pythagorean triple. -/
theorem root_is_pythagorean : IsPythagoreanTriple 3 4 5 := by
  unfold IsPythagoreanTriple; norm_num

/-- A Berggren path: sequence of matrix choices from {0, 1, 2}. -/
def BerggrenPath := List (Fin 3)

/-- The triple produced by following a Berggren path from root (3,4,5). -/
def synthFromPath : BerggrenPath → ℤ × ℤ × ℤ
  | [] => (3, 4, 5)
  | i :: rest => berggrenMatrix i (synthFromPath rest)

/-- **Theorem (Path Synthesis Correctness):**
    Every triple synthesized via a Berggren path is Pythagorean. -/
theorem path_synthesis_correct (path : BerggrenPath) :
    let t := synthFromPath path
    IsPythagoreanTriple t.1 t.2.1 t.2.2 := by
  induction path with
  | nil => exact root_is_pythagorean
  | cons i rest ih => exact berggren_compose_preserves_pyth i _ _ _ ih

/-- The hypotenuse of the root triple is 5. -/
theorem root_hypotenuse : (synthFromPath []).2.2 = 5 := by
  simp [synthFromPath]

/-! ## §4. Berggren Hypotenuse Growth -/

/-- Applying Berggren matrix B increases the hypotenuse when legs are positive. -/
theorem berggren_B_hyp_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (berggrenMatrix 1 (a, b, c)).2.2 := by
  simp [berggrenMatrix]; linarith

/-! ## §5. Scaling and Algebraic Properties -/

/-- **Theorem (Scaling Preservation):**
    If (a, b, c) is Pythagorean, so is (ka, kb, kc). -/
theorem scaling_preserves_pythagorean (a b c k : ℤ) (h : IsPythagoreanTriple a b c) :
    IsPythagoreanTriple (k * a) (k * b) (k * c) := by
  unfold IsPythagoreanTriple at *; nlinarith [sq_nonneg k, h]

/-- **Theorem (Sum of Consecutive Odds):**
    1 + 3 + 5 + ... + (2n-1) = n², connecting Pythagorean triples
    to the geometry of square numbers. -/
theorem sum_consecutive_odds (n : ℕ) :
    ∑ i ∈ range n, (2 * (i : ℤ) + 1) = (n : ℤ) ^ 2 := by
  induction n with
  | zero => simp
  | succ k ih => simp [Finset.sum_range_succ, ih]; ring

/-- Different single-step Berggren applications from root produce distinct triples. -/
theorem berggren_root_children_distinct :
    synthFromPath [0] ≠ synthFromPath [1] ∧
    synthFromPath [1] ≠ synthFromPath [2] ∧
    synthFromPath [0] ≠ synthFromPath [2] := by
  simp [synthFromPath, berggrenMatrix]

/-- **Corollary:** If a² + b² = c², then the Berggren image also satisfies it
    (via Lorentz form = 0). -/
theorem berggren_pyth_from_lorentz (i : Fin 3) (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 - c ^ 2 = 0) :
    let t := berggrenMatrix i (a, b, c)
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 = 0 := by
  have := berggren_lorentz_invariant i a b c; linarith

/-! ## §6. Parametric Witnesses — ℕ Version -/

/-- For natural numbers with m > n, the parametric family satisfies a² + b² = c² in ℕ. -/
theorem parametric_nat_pythagorean (m n : ℕ) (hmn : n < m) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  have h1 : n ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left (le_of_lt hmn) 2
  zify [h1]; ring

/-! ## §7. Concrete Witness Examples -/

/-- (3, 4, 5) via m=2, n=1. -/
theorem witness_3_4_5 : parametricWitness 2 1 = (3, 4, 5) := by native_decide

/-- (5, 12, 13) via m=3, n=2. -/
theorem witness_5_12_13 : parametricWitness 3 2 = (5, 12, 13) := by native_decide

/-- (15, 8, 17) via m=4, n=1. -/
theorem witness_8_15_17 : parametricWitness 4 1 = (15, 8, 17) := by native_decide

/-- (7, 24, 25) via m=4, n=3. -/
theorem witness_7_24_25 : parametricWitness 4 3 = (7, 24, 25) := by native_decide

/-! ## §8. Berggren Path Composition -/

/-- Applying matrix i after following path p is synthFromPath (i :: p). -/
theorem berggren_path_cons (i : Fin 3) (p : BerggrenPath) :
    berggrenMatrix i (synthFromPath p) = synthFromPath (i :: p) := by
  simp [synthFromPath]

/-! ## §9. The Brahmagupta–Fibonacci Identity and Witness Composition -/

/-- **Theorem (Brahmagupta–Fibonacci Two-Square Identity):**
    The product of two sums of two squares is itself a sum of two squares.
    This is the multiplicative structure underlying witness composition. -/
theorem brahmagupta_fibonacci (a₁ b₁ a₂ b₂ : ℤ) :
    (a₁ ^ 2 + b₁ ^ 2) * (a₂ ^ 2 + b₂ ^ 2) =
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 := by ring

/-- **Theorem (Witness Gaussian Composition):**
    Two Pythagorean triples compose into a new one via the
    Brahmagupta–Fibonacci identity / Gaussian integer multiplication. -/
theorem witness_gaussian_composition (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : IsPythagoreanTriple a₁ b₁ c₁)
    (h₂ : IsPythagoreanTriple a₂ b₂ c₂) :
    IsPythagoreanTriple (a₁ * a₂ - b₁ * b₂) (a₁ * b₂ + b₁ * a₂) (c₁ * c₂) := by
  unfold IsPythagoreanTriple at *
  have := brahmagupta_fibonacci a₁ b₁ a₂ b₂
  nlinarith

/-- **Theorem (Difference of Squares Factoring):**
    In a Pythagorean triple, a² = (c - b)(c + b). -/
theorem pyth_difference_factoring (a b c : ℤ) (h : IsPythagoreanTriple a b c) :
    a ^ 2 = (c - b) * (c + b) := by
  unfold IsPythagoreanTriple at h; nlinarith

/-! ## §10. Witness Bounds -/

/-- The hypotenuse satisfies c = m² + n² ≤ (m + n)². -/
theorem witness_quadratic_bound (m n : ℤ) (hm : 0 ≤ m) (hn : 0 ≤ n) :
    (parametricWitness m n).2.2 ≤ (m + n) ^ 2 := by
  simp [parametricWitness]; nlinarith [sq_nonneg m, sq_nonneg n]

/-- c = m² + n² ≥ max(m², n²). -/
theorem witness_lower_bound_max (m n : ℤ) :
    m ^ 2 ≤ (parametricWitness m n).2.2 ∧
    n ^ 2 ≤ (parametricWitness m n).2.2 := by
  simp [parametricWitness]
  constructor <;> nlinarith [sq_nonneg m, sq_nonneg n]

/-! ## §11. No Isosceles Pythagorean Triple (Irrationality of √2) -/

/-
**Theorem (No Isosceles Pythagorean Triple):**
    There is no Pythagorean triple of the form (a, a, c) with a > 0.
    Equivalently, √2 is irrational: 2a² = c² has no positive integer solutions.
-/
theorem no_isosceles_pythagorean_triple (a c : ℤ) (ha : 0 < a) :
    ¬ IsPythagoreanTriple a a c := by
  -- Assume there exists an integer c such that 2a² = c².
  by_contra h_contra
  obtain ⟨c, hc⟩ : ∃ c : ℤ, c^2 = 2 * a^2 := by
    exact ⟨ c, by linarith [ h_contra.symm ] ⟩;
  -- Since $a$ and $c$ are integers and $2a^2 = c^2$, it follows that $c = \pm a\sqrt{2}$.
  have h_c_eq : c = a * Real.sqrt 2 ∨ c = -a * Real.sqrt 2 := by
    exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ ( sub_ne_zero_of_ne h ) <| by ring_nf; norm_num; norm_cast; linarith;
  rcases h_c_eq with h | h <;> [ exact irrational_sqrt_two <| ⟨ c / a, by push_cast [ h ] ; rw [ mul_div_cancel_left₀ _ ( by positivity ) ] ⟩ ; exact irrational_sqrt_two <| ⟨ -c / a, by push_cast [ h ] ; rw [ div_eq_iff ( by positivity ) ] ; ring ⟩ ]