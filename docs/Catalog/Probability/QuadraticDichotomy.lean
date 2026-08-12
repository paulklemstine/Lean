/-
# The Quadratic Multiplicative Dichotomy (Factoring Lab, Phase A v19c — cycle 2)

Partially closing **Conjecture 3** of `FUTURE_DIRECTIONS.md`.

The previous cycle proved the dichotomy for the *affine* family `f(r) = r + c`
(`FactoringLab.affine_invariant_dichotomy`): such an invariant is either `N` in
disguise (`c = 0`) or it hands over `p + q` and hence, by
`FactoringLab.recovery_from_sum`, the complete factorization.

Here the same dichotomy is established for the *entire quadratic family*: `f`
multiplicative with `f(r) = a r² + b r + c` at primes, so that
`T = f(N) = F(p) F(q)` for a semiprime `N = pq`.  The two sides are:

* **`FactoringLab.quadratic_invariant_N_only`** — in the degenerate case
  `a c = 0 ∧ a b N + b c = 0` the value is the explicit function
  `T = a²N² + b²N + c²` of `N` alone.  (The degenerate case is exactly
  "`F` is a monomial `a X²`, `b X` or `c`", which the proof extracts.)
* **`FactoringLab.quadratic_invariant_determines_sum`** — otherwise `p + q` is a
  root of the *explicit nonzero* integer polynomial
  `Q = (ac) X² + (abN + bc) X + (a²N² + (b² − 2ac)N + c² − T)`
  whose coefficients are computed from `N` and `T` only.  Since `deg Q ≤ 2`
  there are at most two candidate values of `p + q`, and each candidate yields
  a candidate factorization in closed form.

So the invariant is either `N`-only or a factoring algorithm in disguise,
with at most a factor-two search in between; there is no intermediate
"partially informative" behaviour in the quadratic family.  The key algebraic
step is the symmetric-function identity `quadratic_invariant_identity`, which
expresses `F(p)F(q)` in terms of `N = pq` and `s = p + q` alone — the exact
mechanism the conjecture predicted.
-/
import Mathlib
import Probability.SymmetryCircularity

open Polynomial

namespace FactoringLab

/-! ## 1.  The symmetric-function identity -/

/-- **The quadratic symmetric identity.**  For `F(X) = aX² + bX + c` the product
`F(p)F(q)` depends on `(p, q)` only through the elementary symmetric functions
`N = pq` and `s = p + q`, and it does so as an explicit polynomial of degree
`≤ 2` in `s`. -/
theorem quadratic_invariant_identity (a b c p q : ℤ) :
    (a * p ^ 2 + b * p + c) * (a * q ^ 2 + b * q + c)
      = a * c * (p + q) ^ 2 + (a * b * (p * q) + b * c) * (p + q)
        + (a ^ 2 * (p * q) ^ 2 + (b ^ 2 - 2 * (a * c)) * (p * q) + c ^ 2) := by
  ring

/-! ## 2.  The `N`-only side of the dichotomy -/

/-- In the degenerate case the coefficient vector forces `F` to be a monomial. -/
theorem quadratic_degenerate_monomial {a b c N : ℤ} (hN : N ≠ 0)
    (h1 : a * c = 0) (h2 : a * b * N + b * c = 0) :
    (a = 0 ∧ b = 0) ∨ (a = 0 ∧ c = 0) ∨ (b = 0 ∧ c = 0) := by
  rcases mul_eq_zero.1 h1 with ha | hc
  · subst ha
    by_cases hb : b = 0
    · exact Or.inl ⟨rfl, hb⟩
    · have : b * c = 0 := by simpa using h2
      rcases mul_eq_zero.1 this with hb' | hc'
      · exact absurd hb' hb
      · exact Or.inr (Or.inl ⟨rfl, hc'⟩)
  · subst hc
    by_cases hb : b = 0
    · exact Or.inr (Or.inr ⟨hb, rfl⟩)
    · have : a * b * N = 0 := by simpa using h2
      rcases mul_eq_zero.1 this with hab | hN'
      · rcases mul_eq_zero.1 hab with ha' | hb'
        · exact Or.inr (Or.inl ⟨ha', rfl⟩)
        · exact absurd hb' hb
      · exact absurd hN' hN

/-- **The `N`-only side.**  If the `s`-coefficients of the identity vanish then
the invariant is an explicit function of `N` alone — it carries no information
about the individual factors beyond `N`. -/
theorem quadratic_invariant_N_only {a b c p q : ℤ} (hN : p * q ≠ 0)
    (h1 : a * c = 0) (h2 : a * b * (p * q) + b * c = 0) :
    (a * p ^ 2 + b * p + c) * (a * q ^ 2 + b * q + c)
      = a ^ 2 * (p * q) ^ 2 + b ^ 2 * (p * q) + c ^ 2 := by
  rcases quadratic_degenerate_monomial hN h1 h2 with ⟨ha, hb⟩ | ⟨ha, hc⟩ | ⟨hb, hc⟩
  · subst ha; subst hb; ring
  · subst ha; subst hc; ring
  · subst hb; subst hc; ring

/-! ## 3.  The recovery side: an explicit quadratic for `p + q` -/

/-- The candidate polynomial for `p + q`: its coefficients are computed from the
public data `N` and `T = f(N)` (and the fixed `a, b, c`) alone. -/
noncomputable def sumCandidatePoly (a b c N T : ℤ) : Polynomial ℤ :=
  C (a * c) * X ^ 2 + C (a * b * N + b * c) * X
    + C (a ^ 2 * N ^ 2 + (b ^ 2 - 2 * (a * c)) * N + c ^ 2 - T)

theorem sumCandidatePoly_natDegree_le (a b c N T : ℤ) :
    (sumCandidatePoly a b c N T).natDegree ≤ 2 := by
  unfold sumCandidatePoly
  compute_degree

theorem sumCandidatePoly_coeff_two (a b c N T : ℤ) :
    (sumCandidatePoly a b c N T).coeff 2 = a * c := by
  simp only [sumCandidatePoly, coeff_add, coeff_C_mul, coeff_X_pow, coeff_C, coeff_X]
  norm_num

theorem sumCandidatePoly_coeff_one (a b c N T : ℤ) :
    (sumCandidatePoly a b c N T).coeff 1 = a * b * N + b * c := by
  simp only [sumCandidatePoly, coeff_add, coeff_C_mul, coeff_X_pow, coeff_C, coeff_X]
  norm_num

/-- Nondegeneracy makes the candidate polynomial nonzero. -/
theorem sumCandidatePoly_ne_zero {a b c N T : ℤ}
    (hnd : a * c ≠ 0 ∨ a * b * N + b * c ≠ 0) : sumCandidatePoly a b c N T ≠ 0 := by
  intro h
  rcases hnd with h2 | h1
  · exact h2 (by rw [← sumCandidatePoly_coeff_two a b c N T, h, coeff_zero])
  · exact h1 (by rw [← sumCandidatePoly_coeff_one a b c N T, h, coeff_zero])

/-- The true sum of the factors is a root of the candidate polynomial. -/
theorem sumCandidatePoly_eval (a b c p q : ℤ) :
    (sumCandidatePoly a b c (p * q)
        ((a * p ^ 2 + b * p + c) * (a * q ^ 2 + b * q + c))).eval (p + q) = 0 := by
  simp only [sumCandidatePoly, eval_add, eval_mul, eval_pow, eval_C, eval_X]
  ring

/-- **The recovery side.**  Outside the degenerate case the sum `p + q` is a
root of an explicit nonzero polynomial of degree `≤ 2` whose coefficients are
computed from the public data `(N, T)`; hence there are at most two candidate
sums, and the search for the factorization is a two-element search. -/
theorem quadratic_invariant_determines_sum {a b c p q : ℤ}
    (hnd : a * c ≠ 0 ∨ a * b * (p * q) + b * c ≠ 0) :
    let N := p * q
    let T := (a * p ^ 2 + b * p + c) * (a * q ^ 2 + b * q + c)
    let Q := sumCandidatePoly a b c N T
    Q ≠ 0 ∧ Q.natDegree ≤ 2 ∧ (p + q) ∈ Q.roots ∧ Multiset.card Q.roots ≤ 2 := by
  intro N T Q
  have hQ : Q ≠ 0 := sumCandidatePoly_ne_zero hnd
  have hdeg : Q.natDegree ≤ 2 := sumCandidatePoly_natDegree_le a b c N T
  refine ⟨hQ, hdeg, ?_, le_trans (card_roots' Q) hdeg⟩
  rw [mem_roots hQ]
  simpa [IsRoot, Q, N, T] using sumCandidatePoly_eval a b c p q

/-! ## 4.  The dichotomy -/

/-- **The quadratic multiplicative dichotomy.**  Let `f` be the multiplicative
invariant with `f(r) = a r² + b r + c` at primes, and let `N = pq` (`p ≤ q`) be
a semiprime with value `T = f(N) = F(p)F(q)`.  Exactly one of the following
happens.

* *Degenerate case* (`ac = 0` and `abN + bc = 0`, i.e. `F` a monomial):
  `T = a²N² + b²N + c²` is a function of `N` alone and carries no information
  about the factorization.
* *Nondegenerate case*: `p + q` is one of at most two roots of the explicit
  polynomial `Q` built from `(N, T)`, and from the correct root the factors are
  recovered in closed form as `(s ∓ √(s² − 4N))/2`.

There is no intermediate behaviour: a quadratic multiplicative invariant is
either `N` in disguise or a factoring algorithm in disguise (up to a two-way
branch). -/
theorem quadratic_multiplicative_dichotomy {a b c p q : ℤ} (hpq : p ≤ q) (hN : p * q ≠ 0) :
    let N := p * q
    let T := (a * p ^ 2 + b * p + c) * (a * q ^ 2 + b * q + c)
    ((a * c = 0 ∧ a * b * N + b * c = 0) → T = a ^ 2 * N ^ 2 + b ^ 2 * N + c ^ 2) ∧
      (¬ (a * c = 0 ∧ a * b * N + b * c = 0) →
        let Q := sumCandidatePoly a b c N T
        Q ≠ 0 ∧ Multiset.card Q.roots ≤ 2 ∧ (p + q) ∈ Q.roots ∧
          ((p + q) - (Int.sqrt ((p + q) ^ 2 - 4 * N) : ℤ)) / 2 = p ∧
          ((p + q) + (Int.sqrt ((p + q) ^ 2 - 4 * N) : ℤ)) / 2 = q) := by
  intro N T
  constructor
  · rintro ⟨h1, h2⟩
    exact quadratic_invariant_N_only hN h1 h2
  · intro hnd
    have hnd' : a * c ≠ 0 ∨ a * b * N + b * c ≠ 0 := by
      by_contra h
      push_neg at h
      exact hnd ⟨h.1, h.2⟩
    obtain ⟨hQ, _, hroot, hcard⟩ := quadratic_invariant_determines_sum (a := a) (b := b) (c := c)
      (p := p) (q := q) hnd'
    obtain ⟨_, h1, h2⟩ := recovery_from_sum hpq (rfl : N = p * q) (rfl : p + q = p + q)
    exact ⟨hQ, hcard, hroot, h1, h2⟩

/-! ## 5.  The affine and linear families as special cases -/

/-- The linear family `f(r) = b r + c` (the case `a = 0`): the invariant is
`N`-only exactly when `bc = 0`, and otherwise `p + q` is recovered by a single
division — no branching at all. -/
theorem linear_invariant_dichotomy {b c p q : ℤ} :
    ((b * c = 0) → (b * p + c) * (b * q + c) = b ^ 2 * (p * q) + c ^ 2) ∧
      (b * c ≠ 0 →
        ((b * p + c) * (b * q + c) - b ^ 2 * (p * q) - c ^ 2) / (b * c) = p + q) := by
  constructor
  · intro h
    rcases mul_eq_zero.1 h with hb | hc
    · subst hb; ring
    · subst hc; ring
  · intro h
    have : (b * p + c) * (b * q + c) - b ^ 2 * (p * q) - c ^ 2 = b * c * (p + q) := by ring
    rw [this, Int.mul_ediv_cancel_left _ h]

end FactoringLab