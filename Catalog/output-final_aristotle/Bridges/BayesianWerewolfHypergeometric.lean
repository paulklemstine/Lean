import Mathlib

/-!
# A cross-domain bridge: Bayesian Werewolf ↔ Vandermonde's identity

## The connection

In the social-deduction game *Werewolf* (Mafia), a population of `n` players contains
`k` hidden werewolves.  A recurring Bayesian question is: *if we draw a "committee"
of `t` players (e.g. the set of players targeted, accused, or sampled in a round),
how many werewolves does it contain?*  The answer is governed by the **hypergeometric
distribution**

```
  hyp n k t j  =  C(k, j) · C(n-k, t-j) / C(n, t),
```

the probability that a uniformly random `t`-subset of the `n` players contains exactly
`j` werewolves.

This file proves that the two most basic *probabilistic* facts about this
distribution are literally *combinatorial / number-theoretic* identities in disguise,
giving a precise dictionary between two seemingly unrelated areas:

| Probability (social deduction) | Combinatorics / Number theory |
| ------------------------------ | ----------------------------- |
| the probabilities sum to `1`   | **Vandermonde's convolution** `∑ⱼ C(k,j)C(n-k,t-j) = C(n,t)` (`vander_range`) |
| the mean equals `t·k/n`        | **binomial absorption** `j·C(k,j) = k·C(k-1,j-1)` + Vandermonde (`choose_absorb`, `sum_j_choose`) |

The `t = 1` specialization of the mean recovers the "one suspect per round" detection
probability `k / n` — exactly the prior/posterior collapse studied in the companion
file `Werewolf.BayesianOptimal`.  So the whole Bayesian backbone of optimal Werewolf
play is a shadow of classical binomial-coefficient combinatorics.

## Main results

* `vander_range` — Vandermonde's identity in `Finset.range` form.
* `choose_absorb` — the binomial absorption identity `j·C(k,j) = k·C(k-1,j-1)`.
* `hyp_nonneg`, `hyp_sum_one` — the hypergeometric weights form a genuine probability
  distribution; normalization *is* Vandermonde's identity.
* `hyp_mean` — the hypergeometric mean equals `t·k/n`; the proof *is* absorption +
  Vandermonde.
* `hyp_mean_one` — the social-deduction corollary: a single random suspect is a
  werewolf with probability `k/n`.

Everything is `sorry`-free and uses only `import Mathlib`; the file compiles
standalone.

-- !-- Lab Notes -- !--
HYPOTHESIS.  The "how many werewolves in the committee" law is hypergeometric, and its
elementary moments should coincide with named binomial-coefficient identities.

EXPERIMENT.  Model the committee count as `hyp n k t j` over ℚ.  Prove normalization
by casting Vandermonde (`Nat.add_choose_eq`) into `range` form; prove the mean by the
absorption identity `j·C(k,j)=k·C(k-1,j-1)` followed by a second Vandermonde and the
absorption identity `t·C(n,t)=n·C(n-1,t-1)`.

ANALYSIS.  Both moments reduce *exactly* to combinatorial identities — no analytic
approximation is needed.  The bridge is dimension-free.

CRITIQUE.  Every division is guarded by `C(n,t) > 0` (`t ≤ n`) and `n > 0`; the
distribution is shown nonnegative and summing to `1`, so it is non-vacuous.  No
theorem is closed by `decide`/`native_decide`.

SYNTHESIS.  The Bayesian bookkeeping of Werewolf is Vandermonde's convolution and
binomial absorption in probabilistic clothing.
-/

namespace WerewolfBridge

open Finset

/-! ## The two combinatorial identities behind the bridge -/

/-- **Vandermonde's identity**, in `Finset.range` form:
`∑ⱼ C(k,j)·C(n-k,t-j) = C(n,t)` for `k ≤ n`.  This is the combinatorial statement
that a `t`-subset of `n` players is obtained by choosing `j` of the `k` werewolves
and `t-j` of the `n-k` villagers. -/
theorem vander_range (n k t : ℕ) (hk : k ≤ n) :
    ∑ j ∈ range (t + 1), Nat.choose k j * Nat.choose (n - k) (t - j) = Nat.choose n t := by
  have h := Nat.add_choose_eq k (n - k) t
  rw [Nat.add_sub_cancel' hk] at h
  rw [h, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]

/-- **Binomial absorption identity** `j · C(k,j) = k · C(k-1, j-1)` for `1 ≤ j`. -/
theorem choose_absorb (k j : ℕ) (hj : 1 ≤ j) :
    j * Nat.choose k j = k * Nat.choose (k - 1) (j - 1) := by
  rcases k with _ | k
  · simp [Nat.choose_eq_zero_of_lt (by omega : 0 < j)]
  · rcases j with _ | j
    · omega
    · simp only [Nat.succ_sub_one]; rw [Nat.add_one_mul_choose_eq]; ring

/-- The first-moment combinatorial identity
`∑ⱼ j·C(k,j)·C(n-k,t-j) = k·C(n-1,t-1)`, obtained by absorbing `j·C(k,j)` and
applying Vandermonde's identity a second time. -/
theorem sum_j_choose (n k t : ℕ) (hk : 1 ≤ k) (hkn : k ≤ n) (ht : 1 ≤ t) :
    ∑ j ∈ range (t + 1), j * (Nat.choose k j * Nat.choose (n - k) (t - j))
      = k * Nat.choose (n - 1) (t - 1) := by
  rw [Finset.sum_range_succ']
  simp only [zero_mul, add_zero]
  have step : ∀ i ∈ range t, (i + 1) * (Nat.choose k (i + 1) * Nat.choose (n - k) (t - (i + 1)))
      = k * (Nat.choose (k - 1) i * Nat.choose (n - k) ((t - 1) - i)) := by
    intro i _
    have hab := choose_absorb k (i + 1) (by omega)
    simp only [Nat.add_sub_cancel] at hab
    have hti : t - (i + 1) = (t - 1) - i := by omega
    rw [hti, ← mul_assoc, hab, mul_assoc]
  rw [Finset.sum_congr rfl step, ← Finset.mul_sum]
  congr 1
  have ht1 : range t = range ((t - 1) + 1) := by rw [Nat.sub_add_cancel ht]
  have hnk : n - k = (n - 1) - (k - 1) := by omega
  rw [ht1, hnk, vander_range (n - 1) (k - 1) (t - 1) (by omega)]

/-! ## The hypergeometric distribution of werewolves in a committee -/

/-- The hypergeometric weight: the probability that a uniformly random `t`-subset of
`n` players (of whom `k` are werewolves) contains exactly `j` werewolves. -/
def hyp (n k t j : ℕ) : ℚ :=
  (Nat.choose k j : ℚ) * (Nat.choose (n - k) (t - j)) / (Nat.choose n t)

/-- Each hypergeometric weight is nonnegative. -/
theorem hyp_nonneg (n k t j : ℕ) : 0 ≤ hyp n k t j := by
  unfold hyp; positivity

/-- **Bridge 1 (normalization = Vandermonde).**  The hypergeometric weights sum to
`1`; the proof is exactly Vandermonde's identity. -/
theorem hyp_sum_one (n k t : ℕ) (hk : k ≤ n) (ht : t ≤ n) :
    ∑ j ∈ range (t + 1), hyp n k t j = 1 := by
  have hD : (Nat.choose n t : ℚ) ≠ 0 := by exact_mod_cast (Nat.choose_pos ht).ne'
  unfold hyp
  rw [← Finset.sum_div, div_eq_one_iff_eq hD]
  calc ∑ j ∈ range (t + 1), (Nat.choose k j : ℚ) * (Nat.choose (n - k) (t - j))
      = ((∑ j ∈ range (t + 1), Nat.choose k j * Nat.choose (n - k) (t - j) : ℕ) : ℚ) := by
        push_cast; ring
    _ = (Nat.choose n t : ℚ) := by rw [vander_range n k t hk]

/-- **Bridge 2 (mean = absorption + Vandermonde).**  The expected number of
werewolves in a random `t`-committee equals `t·k/n`; the proof is the absorption
identity followed by Vandermonde's identity. -/
theorem hyp_mean (n k t : ℕ) (hk : 1 ≤ k) (hkn : k ≤ n) (ht : 1 ≤ t) (htn : t ≤ n) :
    ∑ j ∈ range (t + 1), (j : ℚ) * hyp n k t j = (t : ℚ) * k / n := by
  have hn : 0 < n := by omega
  have hD : (Nat.choose n t : ℚ) ≠ 0 := by exact_mod_cast (Nat.choose_pos htn).ne'
  have hnQ : (n : ℚ) ≠ 0 := by exact_mod_cast hn.ne'
  unfold hyp
  have hsum : ∑ j ∈ range (t + 1),
        (j : ℚ) * ((Nat.choose k j : ℚ) * (Nat.choose (n - k) (t - j)) / (Nat.choose n t))
      = (k * Nat.choose (n - 1) (t - 1) : ℕ) / (Nat.choose n t : ℚ) := by
    simp only [← mul_div_assoc]
    rw [← Finset.sum_div]
    congr 1
    calc ∑ j ∈ range (t + 1), (j : ℚ) * ((Nat.choose k j : ℚ) * (Nat.choose (n - k) (t - j)))
        = ((∑ j ∈ range (t + 1), j * (Nat.choose k j * Nat.choose (n - k) (t - j)) : ℕ) : ℚ) := by
          push_cast; ring
      _ = ((k * Nat.choose (n - 1) (t - 1) : ℕ) : ℚ) := by rw [sum_j_choose n k t hk hkn ht]
  rw [hsum]
  have habs := choose_absorb n t ht
  have habsQ : (t : ℚ) * Nat.choose n t = n * Nat.choose (n - 1) (t - 1) := by exact_mod_cast habs
  push_cast
  field_simp
  nlinarith [habsQ]

/-- **Social-deduction corollary.**  Sampling a *single* random suspect (`t = 1`), the
expected number of werewolves — i.e. the probability that the suspect is a werewolf —
is exactly the prior `k / n`.  This recovers the posterior/prior collapse of the
companion file `Werewolf.BayesianOptimal`. -/
theorem hyp_mean_one (n k : ℕ) (hk : 1 ≤ k) (hkn : k ≤ n) :
    ∑ j ∈ range 2, (j : ℚ) * hyp n k 1 j = (k : ℚ) / n := by
  have := hyp_mean n k 1 hk hkn le_rfl (by omega)
  simpa using this

end WerewolfBridge