import Cryptography.UniversalPosets.ExactSmall

/-!
# Logarithmic form of the bounds: `2^{(n-1)/4} ≤ U(n) ≤ 2^n`

The counting bound of `Bounds.lean` was stated for an even number of points
(`2 ^ m ≤ U(2m)^2`).  Here it is upgraded to **every** `n`, by splitting `n`
points into parts of sizes `⌊n/2⌋` and `⌈n/2⌉`, and then converted into the
logarithmic form in which the problem is usually phrased:

`(n-1)/4 ≤ log₂ U(n) ≤ n`.

The motivating paper ("Even smaller universal posets") proves
`log₂ U(n) ≤ (1+η)n/2` for large `n`; the exponent of `U(n)` therefore lies in
`[1/4, 1/2]`, and the two ends of that interval are exactly the two bounds
formalised in this project.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  The parity restriction in `2 ^ m ≤ U(2m)^2` is an
artefact of the balanced bipartite family, not of the mathematics: the unbalanced
family with parts `⌊n/2⌋`, `⌈n/2⌉` gives `2^{⌊n/2⌋⌈n/2⌉} ≤ U(n)^n`, whose
logarithm is `⌊n/2⌋⌈n/2⌉/n ≥ (n-1)/4`.

Experiment (Experimenter).  At `n = 3` the bound gives `log₂ U(3) ≥ 1/2`, i.e.
`U(3) ≥ 2`, far weaker than the exact value `5` proved in `ExactSmall.lean`; at
`n = 40` it gives `U(40) ≥ 2^{9.75} > 860`, far stronger than the linear bound
`79`.  The crossover between the two lower bounds is near `n = 20`.

Analysis (Analyst).  The two lower bounds are genuinely complementary: the
structural one is sharp for `n ≤ 3` and useless asymptotically, the counting one
is vacuous for `n ≤ 4` and dominant afterwards.  `max_lower_bound_le_logb`
records both against the same quantity.

Critique (Critic).  All statements are about `Real.logb 2 (U n)` with `U n ≥ 1`,
so no logarithm of `0` occurs; the case `n = 0` is excluded exactly where it must
be (`U 0 = 0`), and the bounds are stated with explicit hypotheses `1 ≤ n`.
-/

namespace UniversalPosets

open Real

/-- Splitting `n` points into parts of size `⌊n/2⌋` and `⌈n/2⌉`. -/
theorem two_pow_le_minUniversalSize_pow (n : ℕ) :
    2 ^ (n / 2 * (n - n / 2)) ≤ (minUniversalSize n) ^ n := by
  classical
  obtain ⟨H, hH, hu⟩ := isUniversalPosetOfSize_minUniversalSize n
  letI : LE (Pt (minUniversalSize n)) := ⟨H⟩
  have huniv : IsUniversalHost (Pt (minUniversalSize n)) (Fin n) := hu
  have hsplit : n / 2 + (n - n / 2) = n := by omega
  let e : Fin (n / 2) ⊕ Fin (n - n / 2) ≃ Fin n := finSumFinEquiv.trans (finCongr hsplit)
  have hbip : IsBipartiteUniversal (Pt (minUniversalSize n)) (n / 2) (n - n / 2) :=
    isBipartiteUniversal_of_isUniversalHost (huniv.congr e)
  have := two_pow_mul_le_card_pow hbip
  rwa [card_Pt, hsplit] at this

/-- The counting bound in logarithmic form: `(n-1)/4 ≤ log₂ U(n)`. -/
theorem logb_minUniversalSize_lower (n : ℕ) (hn : 1 ≤ n) :
    ((n : ℝ) - 1) / 4 ≤ Real.logb 2 (minUniversalSize n) := by
  set K : ℕ := n / 2 * (n - n / 2) with hK
  have hU : 1 ≤ minUniversalSize n := le_trans hn (self_le_minUniversalSize n)
  have hUR : (1 : ℝ) ≤ (minUniversalSize n : ℝ) := by exact_mod_cast hU
  have h1 : ((2 : ℝ) ^ K : ℝ) ≤ ((minUniversalSize n : ℝ)) ^ n := by
    exact_mod_cast two_pow_le_minUniversalSize_pow n
  have h2 : (K : ℝ) ≤ (n : ℝ) * Real.logb 2 (minUniversalSize n) := by
    have hpos : (0 : ℝ) < (2 : ℝ) ^ K := by positivity
    have hmono := Real.logb_le_logb_of_le (b := 2) (by norm_num) hpos h1
    rwa [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one] at hmono
  -- `⌊n/2⌋·⌈n/2⌉ ≥ n(n-1)/4`
  have hnat : n * (n - 1) ≤ 4 * K := by
    rw [hK]
    rcases Nat.even_or_odd n with ⟨m, hm⟩ | ⟨m, hm⟩
    · subst hm
      have e1 : (m + m) / 2 = m := by omega
      have e2 : m + m - m = m := by omega
      rw [e1, e2]
      calc (m + m) * (m + m - 1) ≤ (m + m) * (m + m) :=
            Nat.mul_le_mul_left _ (Nat.sub_le _ _)
        _ = 4 * (m * m) := by ring
    · subst hm
      have e1 : (2 * m + 1) / 2 = m := by omega
      have e2 : 2 * m + 1 - m = m + 1 := by omega
      have e3 : 2 * m + 1 - 1 = 2 * m := by omega
      rw [e1, e2, e3]
      nlinarith
  have hcast : (n : ℝ) * ((n : ℝ) - 1) ≤ 4 * (K : ℝ) := by
    have h4 : ((n * (n - 1) : ℕ) : ℝ) ≤ ((4 * K : ℕ) : ℝ) := by exact_mod_cast hnat
    rwa [Nat.cast_mul, Nat.cast_mul, Nat.cast_sub hn, Nat.cast_one, Nat.cast_ofNat] at h4
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  rw [div_le_iff₀ (by norm_num : (0 : ℝ) < 4)]
  nlinarith [h2, hcast, hnpos]

/-- The naive upper bound in logarithmic form: `log₂ U(n) ≤ n`. -/
theorem logb_minUniversalSize_upper (n : ℕ) (hn : 1 ≤ n) :
    Real.logb 2 (minUniversalSize n) ≤ n := by
  have hU : (minUniversalSize n : ℝ) ≤ (2 : ℝ) ^ n := by
    exact_mod_cast minUniversalSize_le_two_pow n
  have h1 : (0 : ℝ) < (minUniversalSize n : ℝ) := by
    have := le_trans hn (self_le_minUniversalSize n)
    exact_mod_cast lt_of_lt_of_le Nat.zero_lt_one this
  have hmono := Real.logb_le_logb_of_le (b := 2) (by norm_num) h1 hU
  rwa [Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one] at hmono

/--
**Both lower bounds at once.**  The structural bound `2n - 1` and the counting
bound `2^{(n-1)/4}` are complementary: the first is sharp for `n ≤ 3`, the second
dominates for large `n`.
-/
theorem minUniversalSize_bounds (n : ℕ) (hn : 1 ≤ n) :
    ((2 * n - 1 : ℕ) : ℝ) ≤ (minUniversalSize n : ℝ) ∧
      ((n : ℝ) - 1) / 4 ≤ Real.logb 2 (minUniversalSize n) ∧
      Real.logb 2 (minUniversalSize n) ≤ n := by
  refine ⟨?_, logb_minUniversalSize_lower n hn, logb_minUniversalSize_upper n hn⟩
  exact_mod_cast two_mul_sub_one_le_minUniversalSize n

end UniversalPosets