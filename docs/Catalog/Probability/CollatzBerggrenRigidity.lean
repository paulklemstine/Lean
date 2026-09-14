import Mathlib
import Probability.CollatzBerggrenWordIdentity

/-!
# The Collatz–Berggren bridge, III: invariant rigidity and growth windows

The Berggren tree carries two celebrated pieces of structure:

* a **conserved quadratic form**, the Lorentz form `Q(a,b,c) = a² + b² − c²`,
  preserved by each of the three Berggren letters (catalog theorems
  `bergA_preserves_Q`, `bergB_preserves_Q`, `bergC_preserves_Q`);
* an **exact growth exponent** along the Pell spine, the silver ratio squared
  `(1 + √2)² = 3 + 2√2`.

This file shows that neither can be transported to the Syracuse (odd-to-odd
Collatz) tree, and quantifies the Berggren side.

Main results.

* `no_nonconstant_polynomial_invariant` — **rigidity**: a polynomial over `ℚ`
  that is conserved along every Syracuse edge is constant.  So the Collatz tree
  admits no analogue of the Lorentz form, of any degree whatsoever — not just no
  quadratic one.  The proof uses the infinitude of the predecessor fibre of `1`
  established in `Probability.CollatzBerggrenBranching`.
* `no_quadratic_invariant` — the explicit degree-`≤ 2` version, with the three
  witnesses `1, 5, 21 ↦ 1`.
* `lorentz_conserved_and_nonconstant` — the contrast: on the Berggren side the
  Lorentz form *is* conserved and *is* nonconstant.
* `bHyp_silver_window` — the Berggren Pell spine grows in the window
  `5 · (29/5)^n ≤ cₙ ≤ 5 · 6ⁿ`, and `silver_sq_mem_window` places the silver
  ratio squared `(1+√2)² = 3 + 2√2` strictly inside it.
* `syr_edge_ratio_unbounded` — by contrast, Syracuse edges have unbounded
  expansion ratio (and the edge `1 → 1` has ratio `1`), so no Berggren-type
  growth exponent exists for the Collatz tree.
-/

namespace CollatzBerggren

open Polynomial

/-! ## Rigidity: no polynomial Collatz invariant -/

/-- The three smallest predecessors of `1`: `1`, `5` and `21`. -/
theorem syrPred_five_one : SyrPred 5 1 := ⟨odd_one, 4, by norm_num, by norm_num⟩

theorem syrPred_twentyone_one : SyrPred 21 1 := ⟨odd_one, 6, by norm_num, by norm_num⟩

/-- **Rigidity theorem.**  Any polynomial with rational coefficients that is
conserved along every edge of the inverse Syracuse tree is a constant.  In
particular the Collatz tree has no conserved quadratic form playing the role of
the Berggren Lorentz invariant. -/
theorem no_nonconstant_polynomial_invariant (P : ℚ[X])
    (hinv : ∀ m n : ℕ, SyrPred m n → P.eval (m : ℚ) = P.eval (n : ℚ)) :
    P = C (P.eval 1) := by
  have hS : (predSet 1).Infinite := predSet_infinite odd_one (by norm_num)
  set Q : ℚ[X] := P - C (P.eval 1) with hQ
  have himg : ((fun m : ℕ => (m : ℚ)) '' (predSet 1)).Infinite :=
    hS.image (Set.injOn_of_injective Nat.cast_injective)
  have hroots : {x : ℚ | Q.IsRoot x}.Infinite := by
    refine himg.mono ?_
    rintro x ⟨m, hm, rfl⟩
    have h := hinv m 1 hm
    simp only [Nat.cast_one] at h
    simp [hQ, Polynomial.IsRoot, h]
  have hzero : Q = 0 := Polynomial.eq_zero_of_infinite_isRoot Q hroots
  have := sub_eq_zero.1 hzero
  simpa [hQ] using this

/-- **Explicit quadratic rigidity.**  A quadratic `α x² + β x + γ` conserved
along Syracuse edges has `α = β = 0`.  The obstruction is already visible on the
three predecessors `1, 5, 21` of the node `1`. -/
theorem no_quadratic_invariant (α β γ : ℚ)
    (hinv : ∀ m n : ℕ, SyrPred m n →
      α * (m : ℚ) ^ 2 + β * (m : ℚ) + γ = α * (n : ℚ) ^ 2 + β * (n : ℚ) + γ) :
    α = 0 ∧ β = 0 := by
  have h5 := hinv 5 1 syrPred_five_one
  have h21 := hinv 21 1 syrPred_twentyone_one
  norm_num at h5 h21
  constructor <;> linarith

/-! ## The Berggren side: a genuine conserved form -/

/-- The Lorentz form as a function on triples. -/
def lorentzForm (t : ℤ × ℤ × ℤ) : ℤ := lorentzQ t.1 t.2.1 t.2.2

/-- **Contrast theorem.**  On the Berggren side the Lorentz form is conserved by
every letter of the ternary alphabet and is genuinely nonconstant — exactly the
structure the rigidity theorem above forbids on the Collatz side. -/
theorem lorentz_conserved_and_nonconstant :
    (∀ (s : BerggrenStep) (t : ℤ × ℤ × ℤ), lorentzForm (applyStep s t) = lorentzForm t) ∧
      ∃ t u : ℤ × ℤ × ℤ, lorentzForm t ≠ lorentzForm u := by
  constructor
  · rintro s ⟨a, b, c⟩
    cases s
    · exact bergA_preserves_Q a b c
    · exact bergB_preserves_Q a b c
    · exact bergC_preserves_Q a b c
  · exact ⟨(3, 4, 5), (1, 1, 1), by simp [lorentzForm, lorentzQ]⟩

/-- The conserved value along the whole Berggren tree is `0`: every node of the
tree is a null vector of the Lorentz form. -/
theorem lorentzForm_applyPath (path : List BerggrenStep) :
    lorentzForm (applyPath path) = 0 := by
  induction path using List.reverseRecOn with
  | nil => simp [lorentzForm, lorentzQ, applyPath]
  | append_singleton l s ih =>
      rw [applyPath_concat]
      rw [(lorentz_conserved_and_nonconstant.1) s (applyPath l)]
      exact ih

/-! ## Growth: the silver window on the Berggren spine -/

theorem bHyp_pos (n : ℕ) : 0 < bHyp n := by
  have h : ∀ n, 0 < bHyp n ∧ bHyp n < bHyp (n + 1) := by
    intro n
    induction n with
    | zero => norm_num [bHyp]
    | succ i ih =>
        refine ⟨by linarith [ih.1, ih.2], ?_⟩
        rw [bHyp_recurrence i]
        linarith [ih.1, ih.2]
  exact (h n).1

/-- The Pell spine expands by a factor at least `29/5 = 5.8` at each step. -/
theorem bHyp_ratio_lower (n : ℕ) : 29 * bHyp n ≤ 5 * bHyp (n + 1) := by
  induction n with
  | zero => norm_num [bHyp]
  | succ i ih =>
      have hpos := bHyp_pos i
      have hrec : bHyp (i + 2) = 6 * bHyp (i + 1) - bHyp i := bHyp_recurrence i
      -- from `29 cᵢ ≤ 5 cᵢ₊₁` we get `5 cᵢ ≤ cᵢ₊₁`, hence `29 cᵢ₊₁ ≤ 5 cᵢ₊₂`
      have h5 : 5 * bHyp i ≤ bHyp (i + 1) := by linarith
      rw [hrec]
      linarith

/-- Exponential lower bound with base `29/5`, in integral form. -/
theorem bHyp_lower (n : ℕ) : 5 * 29 ^ n ≤ 5 ^ n * bHyp n := by
  induction n with
  | zero => norm_num [bHyp]
  | succ i ih =>
      have h := bHyp_ratio_lower i
      have hp : (0 : ℤ) < 5 ^ i := by positivity
      have h1 : 29 * (5 * 29 ^ i) ≤ 29 * (5 ^ i * bHyp i) := by linarith
      have h2 : 29 * (5 ^ i * bHyp i) = 5 ^ i * (29 * bHyp i) := by ring
      have h3 : 5 ^ i * (29 * bHyp i) ≤ 5 ^ i * (5 * bHyp (i + 1)) :=
        mul_le_mul_of_nonneg_left h (le_of_lt hp)
      calc 5 * 29 ^ (i + 1) = 29 * (5 * 29 ^ i) := by ring
        _ ≤ 5 ^ i * (5 * bHyp (i + 1)) := by linarith
        _ = 5 ^ (i + 1) * bHyp (i + 1) := by ring

/-- Exponential upper bound with base `6`. -/
theorem bHyp_upper (n : ℕ) : bHyp n ≤ 5 * 6 ^ n := by
  have key : ∀ n, bHyp n ≤ 5 * 6 ^ n ∧ bHyp (n + 1) ≤ 5 * 6 ^ (n + 1) := by
    intro n
    induction n with
    | zero => exact ⟨by norm_num [bHyp], by norm_num [bHyp]⟩
    | succ i ih =>
        refine ⟨ih.2, ?_⟩
        have hrec : bHyp (i + 2) = 6 * bHyp (i + 1) - bHyp i := bHyp_recurrence i
        have hpos := bHyp_pos i
        have : bHyp (i + 2) ≤ 6 * (5 * 6 ^ (i + 1)) := by
          rw [hrec]; linarith [ih.2]
        calc bHyp (i + 1 + 1) ≤ 6 * (5 * 6 ^ (i + 1)) := this
          _ = 5 * 6 ^ (i + 1 + 1) := by ring
  exact (key n).1

/-- **Silver window for the Berggren spine.** -/
theorem bHyp_silver_window (n : ℕ) : 5 * 29 ^ n ≤ 5 ^ n * bHyp n ∧ bHyp n ≤ 5 * 6 ^ n :=
  ⟨bHyp_lower n, bHyp_upper n⟩

/-- `(1 + √2)² = 3 + 2√2`, the silver ratio squared. -/
theorem silver_sq : (1 + Real.sqrt 2) ^ 2 = 3 + 2 * Real.sqrt 2 := by
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  nlinarith [h]

/-- The silver ratio squared lies strictly inside the proved growth window
`(29/5, 6)` of the Berggren Pell spine. -/
theorem silver_sq_mem_window :
    (29 : ℝ) / 5 < (1 + Real.sqrt 2) ^ 2 ∧ (1 + Real.sqrt 2) ^ 2 < 6 := by
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hpos : 0 < Real.sqrt 2 := Real.sqrt_pos.2 (by norm_num)
  rw [silver_sq]
  constructor <;> nlinarith [h, hpos]

/-! ## No growth exponent on the Collatz side -/

/-- **Unbounded expansion.**  For every bound `C` the node `1` has a predecessor
exceeding `C`, while `1` is also its own predecessor.  Hence Syracuse edges have
no uniform expansion factor: there is no Collatz analogue of the silver-ratio
growth law. -/
theorem syr_edge_ratio_unbounded (C : ℕ) : ∃ m, SyrPred m 1 ∧ C < m := by
  have hS : (predSet 1).Infinite := predSet_infinite odd_one (by norm_num)
  obtain ⟨m, hm, hlt⟩ := hS.exists_gt C
  exact ⟨m, hm, hlt⟩

end CollatzBerggren