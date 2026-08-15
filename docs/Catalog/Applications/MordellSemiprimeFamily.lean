import Applications.MordellCoprimeToModulus

/-!
# A uniform family of semiprime-shaped counterexamples

Cycle 1 refuted the "only bad primes" conjecture with the single witness `N = 55 = 5·11`,
`P = (9,28)`, and produced, for each prime `ℓ ≥ 5`, *one* Mordell curve realising `ℓ` as a
good denominator prime (`good_prime_realised`, with `N = ℓ² − 1`).  This cycle upgrades that
to a two-parameter family which is simultaneously

* **unbounded**: `N = N(ℓ,t) = 4ℓ²t² − 1` grows without bound in `t`;
* **semiprime-shaped**: `N(ℓ,t) = (2ℓt − 1)(2ℓt + 1)` is always a product of two factors
  `1 < p < q`, and for suitable `t` the two factors are honest twin primes
  (`ℓ = 5, t = 3 : 899 = 29·31`; `ℓ = 7, t = 3 : 1763 = 41·43`;
  `ℓ = 11, t = 9 : 39203 = 197·199`);
* **maximally bad for the conjecture**: the good prime `ℓ` divides `den x(2P)` while *no*
  prime factor of `N` divides it — the denominator is coprime to `N`.

So on this family the denominator of `x(2P)` consists of good primes only: the conjecture does
not merely admit exceptional extra primes, its intended primes `p, q` are provably absent.

## Main results

* `famN_factor`, `famN_odd`, `famN_unbounded` : the shape of the family.
* `fam_dvd_den` : the good prime `ℓ` divides `den x(2P)`.
* `fam_no_bad_prime` : no prime factor of `N(ℓ,t)` divides `den x(2P)`.
* `semiprime_family_violation` : the packaged statement for one member of the family.
* `good_prime_violations_unbounded` : arbitrarily large members exist, for every `ℓ ≥ 5`.
* `counterexample_1763`, `counterexample_899`, `counterexample_39203` : the explicit genuine
  semiprimes, with the denominator computed exactly.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 6): the counterexample `N = 55` is the shadow of a
  two-parameter family; the correct normal form is `N = (m−1)(m+1)` with `m = 2ℓt`, whose
  integral point `(1, m)` has `ℓ ∣ y` by construction.
Experiment (Experimenter): `ℓ = 7, t = 3`: `N = 1763 = 41·43`, `P = (1,42)`,
  `x(2P) = (1 − 8·1763)/(4·42²) = −14103/7056 = −1567/784` with `784 = 2⁴·7²`.
  `ℓ = 5, t = 3`: `N = 899 = 29·31`, `x(2P) = −7191/3600 = −799/400`, `400 = 2⁴·5²`.
  In both cases the denominator's prime support is `{2, ℓ}` and misses `{p, q}` entirely.
Analysis (Analyst): the mechanism is the identity `x(2P) = (1 − 8N)/(4(N+1))` at the point
  `(1, √(N+1))`: the denominator divides `4(N+1)`, which is coprime to the odd `N`.  Good
  primes enter through `N + 1`, bad primes cannot enter at all.
Critique (Critic): "semiprime" in the general theorem means "product of two factors `1 < p < q`";
  proving both factors prime for infinitely many `t` is the twin prime conjecture, so the
  general statement is deliberately stated with a nontrivial factorisation and supplemented by
  three explicit genuinely semiprime instances, each verified by primality certificates.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## The family -/

/-- The family modulus `N(ℓ,t) = 4ℓ²t² − 1 = (2ℓt − 1)(2ℓt + 1)`. -/
def famN (l t : ℕ) : ℤ := 4 * (l : ℤ) ^ 2 * (t : ℤ) ^ 2 - 1

/-- The `y`-coordinate `2ℓt` of the integral point `(1, 2ℓt)` of `E_{N(ℓ,t)}`. -/
def famY (l t : ℕ) : ℤ := 2 * (l : ℤ) * (t : ℤ)

/-- The `x`-coordinate of `2P` for `P = (1, 2ℓt)` on `E_{N(ℓ,t)}`. -/
def famDouble (l t : ℕ) : ℚ :=
  ((((1 : ℤ)) : ℚ) ^ 4 - 8 * ((famN l t : ℤ) : ℚ) * (((1 : ℤ)) : ℚ)) /
    (4 * ((famY l t : ℤ) : ℚ) ^ 2)

/-- The nontrivial factorisation `N(ℓ,t) = (2ℓt − 1)(2ℓt + 1)`. -/
lemma famN_factor (l t : ℕ) : famN l t = (famY l t - 1) * (famY l t + 1) := by
  simp only [famN, famY]; ring

/-- The point `(1, 2ℓt)` lies on `E_{N(ℓ,t)}`. -/
lemma fam_equation (l t : ℕ) : famY l t ^ 2 = (1 : ℤ) ^ 3 + famN l t := by
  simp only [famN, famY]; ring

/-- `N(ℓ,t)` is odd. -/
lemma famN_odd (l t : ℕ) : Odd (famN l t) := ⟨2 * (l : ℤ) ^ 2 * (t : ℤ) ^ 2 - 1, by
  simp only [famN]; ring⟩

/-- `2` is coprime to `N(ℓ,t)`. -/
lemma famN_isCoprime_two (l t : ℕ) : IsCoprime (2 : ℤ) (famN l t) :=
  ⟨2 * (l : ℤ) ^ 2 * (t : ℤ) ^ 2, -1, by simp only [famN]; ring⟩

/-- The point is not `2`-torsion: `2ℓt ≠ 0`. -/
lemma famY_ne_zero {l t : ℕ} (hl : 0 < l) (ht : 0 < t) : famY l t ≠ 0 := by
  have hl' : (0 : ℤ) < (l : ℤ) := by exact_mod_cast hl
  have ht' : (0 : ℤ) < (t : ℤ) := by exact_mod_cast ht
  simp only [famY]
  positivity

/-- `ℓ` does not divide `N(ℓ,t)`: the family consists of curves with **good** reduction at `ℓ`. -/
lemma fam_not_dvd_N {l t : ℕ} (hl2 : 2 ≤ l) : ¬((l : ℤ)) ∣ famN l t := by
  intro hdvd
  have hmul : ((l : ℤ)) ∣ 4 * (l : ℤ) ^ 2 * (t : ℤ) ^ 2 := by
    exact Dvd.dvd.mul_right (Dvd.dvd.mul_left (dvd_pow_self _ (by norm_num)) 4) _
  have h1 : ((l : ℤ)) ∣ 1 := by
    have := dvd_sub hmul hdvd
    simpa [famN] using this
  have := Int.le_of_dvd (by norm_num) h1
  have : (l : ℤ) ≤ 1 := this
  have : l ≤ 1 := by exact_mod_cast this
  omega

/-- The curves of the family have good reduction at `ℓ`: `ℓ ∤ Δ = −432 N²`. -/
lemma fam_good_reduction {l t : ℕ} (hl : l.Prime) (hl5 : 5 ≤ l) :
    ¬((l : ℤ)) ∣ (mordell (famN l t)).Δ :=
  not_dvd_Δ hl hl5 (fam_not_dvd_N (by omega))

/-- **The good prime divides the denominator.**  `ℓ ∣ den x(2P)` for `P = (1, 2ℓt)`. -/
theorem fam_dvd_den {l t : ℕ} (hl : l.Prime) (hl5 : 5 ≤ l) (ht : 0 < t) :
    l ∣ (famDouble l t).den := by
  have hy : famY l t ≠ 0 := famY_ne_zero (by omega) ht
  have hdvdy : ((l : ℤ)) ∣ famY l t := ⟨2 * (t : ℤ), by simp only [famY]; ring⟩
  exact (dvd_den_double_iff (N := famN l t) (x := 1) (y := famY l t) (fam_equation l t) hy hl
    hl5 (fam_not_dvd_N (by omega))).mpr hdvdy

/-- **No bad prime divides the denominator.**  The denominator of `x(2P)` is coprime to
`N(ℓ,t)`, hence no prime factor of `N(ℓ,t)` divides it. -/
theorem fam_den_isCoprime {l t : ℕ} (hl : 0 < l) (ht : 0 < t) :
    IsCoprime (((famDouble l t).den : ℤ)) (famN l t) :=
  den_double_isCoprime_int (fam_equation l t) (famY_ne_zero hl ht) (famN_isCoprime_two l t)
    isCoprime_one_left

/-- No prime factor of `N(ℓ,t)` divides `den x(2P)`. -/
theorem fam_no_bad_prime {l t : ℕ} (hl : 0 < l) (ht : 0 < t) {p : ℕ} (hp : p.Prime)
    (hpN : (p : ℤ) ∣ famN l t) : ¬ p ∣ (famDouble l t).den := by
  intro hdvd
  have hcop := fam_den_isCoprime hl ht
  have hpd : ((p : ℤ)) ∣ (((famDouble l t).den : ℤ)) := by exact_mod_cast hdvd
  have hu : IsUnit ((p : ℤ)) := hcop.isUnit_of_dvd' hpd hpN
  rw [Int.isUnit_iff] at hu
  have := hp.one_lt
  omega

/-! ## The packaged statement -/

/-- **One member of the family.**  For every prime `ℓ ≥ 5` and every `t ≥ 1`, the modulus
`N = N(ℓ,t)` is an odd product of two factors `1 < p < q`, the curve `E_N` has good reduction
at `ℓ`, the integral point `P = (1, 2ℓt)` lies on it, the good prime `ℓ` divides `den x(2P)`,
and **no** prime factor of `N` divides `den x(2P)`. -/
theorem semiprime_family_violation {l t : ℕ} (hl : l.Prime) (hl5 : 5 ≤ l) (ht : 0 < t) :
    famN l t = (famY l t - 1) * (famY l t + 1) ∧
      1 < famY l t - 1 ∧ famY l t - 1 < famY l t + 1 ∧
      Odd (famN l t) ∧
      famY l t ^ 2 = (1 : ℤ) ^ 3 + famN l t ∧
      ¬((l : ℤ)) ∣ (mordell (famN l t)).Δ ∧
      l ∣ (famDouble l t).den ∧
      (∀ p : ℕ, p.Prime → (p : ℤ) ∣ famN l t → ¬ p ∣ (famDouble l t).den) := by
  have hl' : (5 : ℤ) ≤ (l : ℤ) := by exact_mod_cast hl5
  have ht' : (1 : ℤ) ≤ (t : ℤ) := by exact_mod_cast ht
  have hy3 : 3 ≤ famY l t := by
    simp only [famY]; nlinarith
  refine ⟨famN_factor l t, by omega, by omega, famN_odd l t, fam_equation l t,
    fam_good_reduction hl hl5, fam_dvd_den hl hl5 ht, ?_⟩
  intro p hp hpN
  exact fam_no_bad_prime (by omega) ht hp hpN

/-- The family is unbounded: `N(ℓ,t) → ∞` as `t → ∞`. -/
lemma famN_unbounded {l : ℕ} (hl5 : 5 ≤ l) (B : ℤ) : ∃ t : ℕ, 0 < t ∧ B < famN l t := by
  refine ⟨B.natAbs + 1, Nat.succ_pos _, ?_⟩
  have hl' : (5 : ℤ) ≤ (l : ℤ) := by exact_mod_cast hl5
  have hB : B ≤ (B.natAbs : ℤ) := Int.le_natAbs
  have hT : (1 : ℤ) ≤ ((B.natAbs + 1 : ℕ) : ℤ) := by push_cast; omega
  have hTB : ((B.natAbs : ℤ)) + 1 = ((B.natAbs + 1 : ℕ) : ℤ) := by push_cast; ring
  simp only [famN]
  nlinarith [sq_nonneg ((B.natAbs + 1 : ℕ) : ℤ)]

/-- **Arbitrarily large violations, for every good prime.**  For every prime `ℓ ≥ 5` and every
bound `B` there is an odd `N > B` with a nontrivial factorisation `N = p·q`, `1 < p < q`, such
that `E_N` has good reduction at `ℓ`, carries the integral point `(1, y)` with `y² = 1 + N`,
and the denominator of `x(2P)` is divisible by `ℓ` but by no prime factor of `N`. -/
theorem good_prime_violations_unbounded {l : ℕ} (hl : l.Prime) (hl5 : 5 ≤ l) (B : ℤ) :
    ∃ t : ℕ, 0 < t ∧ B < famN l t ∧
      famN l t = (famY l t - 1) * (famY l t + 1) ∧ 1 < famY l t - 1 ∧
      famY l t - 1 < famY l t + 1 ∧ Odd (famN l t) ∧
      famY l t ^ 2 = (1 : ℤ) ^ 3 + famN l t ∧
      ¬((l : ℤ)) ∣ (mordell (famN l t)).Δ ∧
      l ∣ (famDouble l t).den ∧
      (∀ p : ℕ, p.Prime → (p : ℤ) ∣ famN l t → ¬ p ∣ (famDouble l t).den) := by
  obtain ⟨t, ht, hB⟩ := famN_unbounded hl5 B
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8⟩ := semiprime_family_violation hl hl5 ht
  exact ⟨t, ht, hB, h1, h2, h3, h4, h5, h6, h7, h8⟩

/-! ## Explicit genuine semiprimes -/

/-- **`N = 1763 = 41·43`, `ℓ = 7`.**  `P = (1,42)`, `x(2P) = −1567/784` with `784 = 2⁴·7²`:
the good prime `7` occurs in the denominator, while neither `41` nor `43` does. -/
theorem counterexample_1763 :
    famN 7 3 = 1763 ∧ (41 : ℕ).Prime ∧ (43 : ℕ).Prime ∧ 1763 = 41 * 43 ∧
      famDouble 7 3 = -1567 / 784 ∧ (famDouble 7 3).den = 2 ^ 4 * 7 ^ 2 ∧
      7 ∣ (famDouble 7 3).den ∧ ¬ (41 : ℕ) ∣ (famDouble 7 3).den ∧
      ¬ (43 : ℕ) ∣ (famDouble 7 3).den ∧ ¬((7 : ℤ)) ∣ (mordell (famN 7 3)).Δ := by
  refine ⟨by norm_num [famN], by norm_num, by norm_num, by norm_num, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num [famDouble, famN, famY]
  · norm_num [famDouble, famN, famY]
  · norm_num [famDouble, famN, famY]
  · norm_num [famDouble, famN, famY]
  · norm_num [famDouble, famN, famY]
  · exact fam_good_reduction (by norm_num) (by norm_num)

/-- **`N = 899 = 29·31`, `ℓ = 5`.**  `P = (1,30)`, `x(2P) = −799/400` with `400 = 2⁴·5²`. -/
theorem counterexample_899 :
    famN 5 3 = 899 ∧ (29 : ℕ).Prime ∧ (31 : ℕ).Prime ∧ 899 = 29 * 31 ∧
      famDouble 5 3 = -799 / 400 ∧ (famDouble 5 3).den = 2 ^ 4 * 5 ^ 2 ∧
      5 ∣ (famDouble 5 3).den ∧ ¬ (29 : ℕ) ∣ (famDouble 5 3).den ∧
      ¬ (31 : ℕ) ∣ (famDouble 5 3).den ∧ ¬((5 : ℤ)) ∣ (mordell (famN 5 3)).Δ := by
  refine ⟨by norm_num [famN], by norm_num, by norm_num, by norm_num, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num [famDouble, famN, famY]
  · norm_num [famDouble, famN, famY]
  · norm_num [famDouble, famN, famY]
  · norm_num [famDouble, famN, famY]
  · norm_num [famDouble, famN, famY]
  · exact fam_good_reduction (by norm_num) (by norm_num)

/-- **`N = 39203 = 197·199`, `ℓ = 11`.**  `P = (1,198)`; the good prime `11` divides
`den x(2P)` while the two prime factors of `N` do not. -/
theorem counterexample_39203 :
    famN 11 9 = 39203 ∧ (197 : ℕ).Prime ∧ (199 : ℕ).Prime ∧ 39203 = 197 * 199 ∧
      11 ∣ (famDouble 11 9).den ∧ ¬ (197 : ℕ) ∣ (famDouble 11 9).den ∧
      ¬ (199 : ℕ) ∣ (famDouble 11 9).den ∧ ¬((11 : ℤ)) ∣ (mordell (famN 11 9)).Δ := by
  refine ⟨by norm_num [famN], by norm_num, by norm_num, by norm_num,
    fam_dvd_den (by norm_num) (by norm_num) (by norm_num), ?_, ?_,
    fam_good_reduction (by norm_num) (by norm_num)⟩
  · exact fam_no_bad_prime (by norm_num) (by norm_num) (by norm_num) (by norm_num [famN])
  · exact fam_no_bad_prime (by norm_num) (by norm_num) (by norm_num) (by norm_num [famN])

end MordellDenominators