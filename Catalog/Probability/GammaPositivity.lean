import Mathlib

/-!
# γ-positivity of symmetric (palindromic) polynomials

This file develops the elementary theory of **γ-positivity** for real polynomials,
the exact algebraic property appearing in the study of Ehrhart `h*`-polynomials of
symmetric edge polytopes.

For a degree parameter `n`, the *γ-basis* of the space of polynomials that are
symmetric about `n/2` is
`{ t^i (1+t)^(n-2i) : 0 ≤ i ≤ ⌊n/2⌋ }`.
A polynomial `p` is **γ-positive of order `n`** if it is a nonnegative real
combination of these basis elements.

The main results here:

* `gammaBasis_coeff` — closed form for the coefficients of a basis element in terms
  of binomial coefficients;
* `gammaBasis_palindromic` — each basis element is palindromic about `n/2`;
* `IsGammaPositive.palindromic` — **γ-positivity implies palindromicity** (symmetry
  of the coefficient sequence), the structural constraint underlying every
  `h*`-polynomial of a symmetric edge polytope;
* `IsGammaPositive.coeff_nonneg` — γ-positive polynomials have nonnegative
  coefficients.

## Reference frame

The catalog entries `ohsugi-tsuchiya-conj`, `higashitani-jochemko-michalek`, `gal`
and `branden-gamma` concern precisely the γ-positivity of these Ehrhart
`h*`-polynomials; the phenomenon that palindromicity is *necessary but not
sufficient* for γ-positivity is what makes the "minimal dimension 36" question
nontrivial (see `GammaPositivityCounterexample.lean`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): γ-positivity is a strict strengthening of palindromicity;
every γ-positive polynomial is palindromic and has nonnegative, unimodal coefficients,
but the converse fails already in very small degree.
Experiment (Experimenter): computed the coefficient vectors of `t^i(1+t)^(n-2i)` for
small `n`; each is a shifted binomial row, symmetric about `n/2`.
Analysis (Analyst): the symmetry `C(n-2i,k-i)=C(n-2i,(n-2i)-(k-i))` is the engine;
nonnegativity is immediate; unimodality needs the same-center superposition argument.
Critique (Critic): must guard `k ≤ n` for palindromicity, else Nat subtraction
`n - k` collapses to `0` and the identity is false.
Synthesis: the coefficient formula `gammaBasis_coeff` reduces both structural
theorems to binomial identities.
-/

namespace GammaPositivity

open Polynomial BigOperators

/-- The `i`-th element of the γ-basis in order `n`: `t^i (1+t)^(n-2i)`. -/
noncomputable def gammaBasis (n i : ℕ) : ℝ[X] := (1 + X) ^ (n - 2 * i) * X ^ i

/-- Closed form for the coefficients of a γ-basis element. -/
theorem gammaBasis_coeff (n i k : ℕ) :
    (gammaBasis n i).coeff k =
      if i ≤ k then ((n - 2 * i).choose (k - i) : ℝ) else 0 := by
  unfold gammaBasis
  rw [Polynomial.coeff_mul_X_pow']
  simp only [Polynomial.coeff_one_add_X_pow]


/-- The coefficients of a γ-basis element are nonnegative. -/
theorem gammaBasis_coeff_nonneg (n i k : ℕ) : 0 ≤ (gammaBasis n i).coeff k := by
  rw [gammaBasis_coeff]
  split
  · exact_mod_cast Nat.zero_le _
  · exact le_refl 0

/-- Each γ-basis element is palindromic about `n/2`: its coefficient sequence is
symmetric under `k ↦ n - k` for `k ≤ n`, provided `2 i ≤ n`. -/
theorem gammaBasis_palindromic (n i k : ℕ) (h2 : 2 * i ≤ n) (hk : k ≤ n) :
    (gammaBasis n i).coeff k = (gammaBasis n i).coeff (n - k) := by
  rw [gammaBasis_coeff, gammaBasis_coeff]
  by_cases hik : i ≤ k
  · by_cases hik2 : i ≤ n - k
    · simp only [hik, hik2, if_true]
      have hkm : k - i ≤ n - 2 * i := by omega
      have hrw : n - k - i = (n - 2 * i) - (k - i) := by omega
      rw [hrw, Nat.choose_symm hkm]
    · simp only [hik, hik2, if_true, if_false]
      rw [Nat.choose_eq_zero_of_lt (by omega)]; simp
  · by_cases hik2 : i ≤ n - k
    · simp only [hik, hik2, if_false, if_true]
      rw [Nat.choose_eq_zero_of_lt (by omega)]; simp
    · simp only [hik, hik2, if_false]

/-- A polynomial is **γ-positive of order `n`** if it is a nonnegative real
combination of the γ-basis elements `t^i (1+t)^(n-2i)` for `0 ≤ i ≤ ⌊n/2⌋`. -/
def IsGammaPositive (n : ℕ) (p : ℝ[X]) : Prop :=
  ∃ γ : ℕ → ℝ, (∀ i, 0 ≤ γ i) ∧
    p = ∑ i ∈ Finset.range (n / 2 + 1), C (γ i) * gammaBasis n i

/-- A polynomial is **palindromic of order `n`** if its coefficient sequence is
symmetric under `k ↦ n - k` on `{0, …, n}`. -/
def IsPalindromic (n : ℕ) (p : ℝ[X]) : Prop := ∀ k ≤ n, p.coeff k = p.coeff (n - k)

/-- **γ-positivity implies palindromicity.** This is the structural symmetry shared
by every Ehrhart `h*`-polynomial of a symmetric edge polytope. -/
theorem IsGammaPositive.palindromic {n : ℕ} {p : ℝ[X]} (hp : IsGammaPositive n p) :
    IsPalindromic n p := by
  obtain ⟨γ, hγ, rfl⟩ := hp
  intro k hk
  rw [Polynomial.finset_sum_coeff, Polynomial.finset_sum_coeff]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Polynomial.coeff_C_mul, Polynomial.coeff_C_mul]
  have hin : 2 * i ≤ n := by
    simp only [Finset.mem_range] at hi; omega
  rw [gammaBasis_palindromic n i k hin hk]

/-- γ-positive polynomials have nonnegative coefficients. -/
theorem IsGammaPositive.coeff_nonneg {n : ℕ} {p : ℝ[X]} (hp : IsGammaPositive n p)
    (k : ℕ) : 0 ≤ p.coeff k := by
  obtain ⟨γ, hγ, rfl⟩ := hp
  rw [Polynomial.finset_sum_coeff]
  apply Finset.sum_nonneg
  intro i _
  rw [Polynomial.coeff_C_mul]
  exact mul_nonneg (hγ i) (gammaBasis_coeff_nonneg n i k)

end GammaPositivity