import Algebra.ReciprocalZeroHarmonics.Core

/-!
# Reciprocal-Zero Harmonics V: prime-indexed harmonic statistics

Direction 5 of the programme asks for an indexing rule that encodes prime structure, and asks
whether *multiplication of integers corresponds to addition of harmonic statistics*.

The reciprocal-root statistic of the degree-one Euler factor `1 - u/p` of the Riemann zeta
function is `1/p` (its unique zero is `u = p`).  Weighting each prime by its multiplicity in `n`
gives the **prime chord**

  `primeChord n = Σ_{p^k ‖ n} k/p`,

the multiplicity-sensitive harmonic statistic indexed by the primes dividing `n`.

## Main results

* `primeChord_mul` — **multiplication ↦ addition, without any coprimality hypothesis.**  For all
  nonzero `m, n`, `primeChord (m·n) = primeChord m + primeChord n`.  The answer to Direction 5 is
  therefore affirmative for the multiplicity-sensitive convention (and would be *false* for the
  set-valued convention `Σ_{p ∣ n} 1/p`, which is only additive on coprime arguments).
* `primeChord_prime_eq_harmonicSum` — the statistic is the `Core.harmonicSum` of the zero of the
  `p`-th Euler factor, so it is an instance of the same reciprocal-zero construction.
* `primeChord_prime_injective` — the statistic separates *primes*: `primeChord p = primeChord q`
  forces `p = q`.
* `primeChord_not_injective` — but it does **not** separate integers: `primeChord 4 = primeChord
  27 = 1`.  Any prime-indexed encoding built from this statistic alone necessarily identifies
  `2²` with `3³`; a faithful encoding must retain more than the harmonic value.
* `primeChord_mono_of_dvd` — divisibility monotonicity, an immediate structural consequence of
  additivity and nonnegativity.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** A prime-indexed harmonic statistic should convert multiplication
  into addition and should distinguish the primes.
* **Experiment (Experimenter).** Additivity is `Nat.factorization_mul` combined with
  `Finsupp.sum_add_index'`; the failure of injectivity was found by searching for coincidences
  of `k/p`, the first being `2/2 = 3/3 = 1`, i.e. `4` and `27`.
* **Analysis (Analyst).** Additivity holds *because* the statistic is a completely additive
  arithmetic function; the collision `4 ↔ 27` is unavoidable for any completely additive function
  taking rational values with small denominators.  "True but incomplete": the encoding is a
  homomorphism `(ℕ_{>0}, ·) → (ℝ, +)` and homomorphisms onto a one-dimensional target cannot be
  injective on a free monoid of infinite rank.
* **Critique (Critic).** The nonvanishing hypotheses `m, n ≠ 0` are essential
  (`Nat.factorization 0 = 0`, which would make the identity false at `0`).  The negative result
  is a genuine counterexample, not an unproved claim.
-/

namespace ReciprocalZeroHarmonics

/-- The **prime chord** of `n`: the multiplicity-weighted sum of the reciprocal zeros of the
Euler factors of `ζ` at the primes dividing `n`, `Σ_{p^k ‖ n} k/p`. -/
noncomputable def primeChord (n : ℕ) : ℝ := n.factorization.sum fun p k => (k : ℝ) / p

@[simp] theorem primeChord_one : primeChord 1 = 0 := by simp [primeChord]

theorem primeChord_nonneg (n : ℕ) : 0 ≤ primeChord n := by
  unfold primeChord
  refine Finsupp.sum_nonneg fun p _ => by positivity

/-- **Multiplication becomes addition.**  The prime chord is a completely additive arithmetic
function: no coprimality hypothesis is needed. -/
theorem primeChord_mul (m n : ℕ) (hm : m ≠ 0) (hn : n ≠ 0) :
    primeChord (m * n) = primeChord m + primeChord n := by
  unfold primeChord
  rw [Nat.factorization_mul hm hn,
    Finsupp.sum_add_index' (by intro a; simp) (by intro a b1 b2; push_cast; ring)]

theorem primeChord_prime_pow (p k : ℕ) (hp : p.Prime) : primeChord (p ^ k) = (k : ℝ) / p := by
  unfold primeChord
  rw [Nat.Prime.factorization_pow hp, Finsupp.sum_single_index (by simp)]

theorem primeChord_prime (p : ℕ) (hp : p.Prime) : primeChord p = 1 / p := by
  simpa using primeChord_prime_pow p 1 hp

/-- The prime chord of a prime is the harmonic sum of the zero `u = p` of the Euler factor
`1 - u/p`: the prime-indexed statistic is an instance of the reciprocal-zero construction. -/
theorem primeChord_prime_eq_harmonicSum (p : ℕ) (hp : p.Prime) :
    ((primeChord p : ℝ) : ℂ) = harmonicSum {(p : ℂ)} := by
  rw [primeChord_prime p hp]
  simp [harmonicSum]

/-- **The statistic separates primes.** -/
theorem primeChord_prime_injective {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h : primeChord p = primeChord q) : p = q := by
  rw [primeChord_prime p hp, primeChord_prime q hq] at h
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have : (p : ℝ) = q := by
    field_simp at h
    linarith
  exact_mod_cast this

/-- **But it does not separate integers.**  `4 = 2²` and `27 = 3³` have the same prime chord `1`,
so no injective prime-indexed encoding can be built from this harmonic value alone. -/
theorem primeChord_not_injective : primeChord 4 = 1 ∧ primeChord 27 = 1 ∧ (4 : ℕ) ≠ 27 := by
  refine ⟨?_, ?_, by norm_num⟩
  · rw [show (4 : ℕ) = 2 ^ 2 by norm_num, primeChord_prime_pow 2 2 (by norm_num)]
    norm_num
  · rw [show (27 : ℕ) = 3 ^ 3 by norm_num, primeChord_prime_pow 3 3 (by norm_num)]
    norm_num

/-- Divisibility monotonicity, a structural consequence of complete additivity. -/
theorem primeChord_mono_of_dvd {m n : ℕ} (hn : n ≠ 0) (hmn : m ∣ n) :
    primeChord m ≤ primeChord n := by
  obtain ⟨c, rfl⟩ := hmn
  have hm : m ≠ 0 := by rintro rfl; simp at hn
  have hc : c ≠ 0 := by rintro rfl; simp at hn
  rw [primeChord_mul m c hm hc]
  linarith [primeChord_nonneg c]

/-- Positivity: every integer `≥ 2` has a strictly positive prime chord, so the statistic
detects nontriviality. -/
theorem primeChord_pos {n : ℕ} (hn : 2 ≤ n) : 0 < primeChord n := by
  obtain ⟨p, hp, hpn⟩ := Nat.exists_prime_and_dvd (show n ≠ 1 by omega)
  have hn0 : n ≠ 0 := by omega
  have h1 : primeChord p ≤ primeChord n := primeChord_mono_of_dvd hn0 hpn
  have h2 : 0 < primeChord p := by
    rw [primeChord_prime p hp]
    have : (0 : ℝ) < p := by exact_mod_cast hp.pos
    positivity
  linarith

end ReciprocalZeroHarmonics