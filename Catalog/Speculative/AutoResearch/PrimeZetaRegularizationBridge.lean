import Mathlib
import Novelty.PrimeZetaAbscissa
import Novelty.BoundedGaps

/-!
# A bridge: prime-zeta natural boundary vs. zeta regularization

This file bridges two catalog domains:

* **Number theory / prime distribution** (cf. `Novelty.BoundedGaps`,
  `Novelty.PrimeZetaAbscissa`): the bare prime series `∑ p^{-s}` diverges at
  `s = -1`, so the "sum of all primes" is *not* a value of any series.
* **Mathematical physics / zeta-regularization** (`hep-th`): the *full* Riemann
  zeta function admits the famous Ramanujan/Casimir values
  `ζ(-1) = -1/12` and `ζ(0) = -1/2`, obtained by analytic continuation past the
  abscissa of convergence.

The contrast is the mathematical heart of the matter: **continuation works for
the full zeta function** (it is meromorphic on all of `ℂ`), whereas the prime
zeta function has a genuine *natural boundary* at `Re s = 0` and so cannot be
continued to `s = -1` at all.  This file proves the rigorous, sorry-free facts on
both sides and packages the dichotomy.

## Main results

* `riemannZeta_neg_one_eq` — `ζ(-1) = -1/12` from the Bernoulli formula.
* `prime_zeta_boundary_vs_zeta_regularization` — the dichotomy: the prime series
  diverges at `s = -1`, yet `ζ(-1) = -1/12`.
* `bounded_gaps_and_prime_zeta_divergence` — a cross-domain statement: even under
  the bounded-gaps hypothesis (Maynard–Tao, `liminf` of gaps `≤ 246`), the prime
  zeta series still diverges at `s = -1`.
* `next_prime_after_two_le_three` — a concrete reuse of the catalog lemma
  `TwinPrimeGaps.next_prime_le_of_prime_lt`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "The physicists' `-1/12` and the impossibility of a
prime analogue can be made to coexist precisely, with the prime side genuinely
diverging while the full-zeta side is a finite Bernoulli value."
Experiment (Experimenter): `ζ(-1)` reduced to `riemannZeta_neg_nat_eq_bernoulli 1`
plus `bernoulli_two : bernoulli 2 = 6⁻¹`, then `push_cast`/`norm_num`.  The prime
divergence is imported from `Novelty.PrimeZetaAbscissa`.
Analysis (Analyst): The two facts are *not* in tension — they live on opposite
sides of the natural boundary `Re s = 0`.  The full zeta is meromorphic on `ℂ`;
the prime zeta is not continuable past `Re s = 0`.  So `-1/12` is a statement
about the *completed* object, never about the prime series.
Critique (Critic): Verified the `-1/12` computation is a real cast/Bernoulli
calculation (not `rfl`/`native_decide`), and that the bounded-gaps statement
genuinely consumes the Maynard–Tao hypothesis through the catalog lemma
`TwinPrimeGaps.liminf_primeGap_le_246`.
Synthesis (PI): The honest "regularized sum of primes" program must therefore
pass through the *full* zeta function (or another summation method), since the
prime Dirichlet series offers no value at `s = -1`.
-/

open scoped BigOperators
open TwinPrimeGaps

/-- **Zeta regularization value.** `ζ(-1) = -1/12`, the Ramanujan/Casimir value,
derived rigorously from the Bernoulli formula for `ζ` at negative integers. -/
theorem riemannZeta_neg_one_eq : riemannZeta (-1) = -1 / 12 := by
  have h := riemannZeta_neg_nat_eq_bernoulli 1
  rw [show (1 + 1 : ℕ) = 2 from rfl, bernoulli_two] at h
  rw [show ((-1 : ℂ)) = -((1 : ℕ) : ℂ) by push_cast; ring, h]
  push_cast
  norm_num

/-- **Companion value.** `ζ(0) = -1/2` (the regularized count of the naturals). -/
theorem riemannZeta_zero_eq : riemannZeta 0 = -1 / 2 := by
  rw [riemannZeta_zero]

/-- **The dichotomy.** At `s = -1` the prime series `∑ p^{1} = ∑ p` diverges, so
there is no "sum of all primes" as a series value; yet the full Riemann zeta
function takes the finite regularized value `ζ(-1) = -1/12`.  Two faces of the
natural boundary at `Re s = 0`. -/
theorem prime_zeta_boundary_vs_zeta_regularization :
    (¬ Summable (fun p : Nat.Primes => (p : ℝ) ^ (-(-1 : ℝ)))) ∧
      riemannZeta (-1) = -1 / 12 :=
  ⟨primeZeta_not_summable_neg_one, riemannZeta_neg_one_eq⟩

/-- **Cross-domain bridge.** Assume the bounded-gaps input (Maynard–Tao style):
arbitrarily large pairs of primes within distance `246`.  Then the `liminf` of
consecutive prime gaps is `≤ 246`, *and* the prime zeta series nevertheless
diverges at `s = -1`.  Close primes do not rescue the divergent prime sum. -/
theorem bounded_gaps_and_prime_zeta_divergence
    (h : ∀ N : ℕ, ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N ≤ p ∧ p < q ∧ q ≤ p + 246) :
    Filter.atTop.liminf primeGap ≤ (246 : ℕ) ∧
      ¬ Summable (fun p : Nat.Primes => (p : ℝ) ^ (-(-1 : ℝ))) :=
  ⟨liminf_primeGap_le_246 h, primeZeta_not_summable_neg_one⟩

/-- A concrete reuse of the catalog lemma `TwinPrimeGaps.next_prime_le_of_prime_lt`:
the prime immediately after `2` is at most `3`. -/
theorem next_prime_after_two_le_three :
    Nat.nth Nat.Prime (Nat.count Nat.Prime 2 + 1) ≤ 3 :=
  next_prime_le_of_prime_lt Nat.prime_two (by norm_num) (by norm_num)