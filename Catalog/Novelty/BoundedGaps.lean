/-
# From bounded prime pairs to bounded consecutive gaps

The Zhang–Maynard–Tao breakthrough proves that there are infinitely many pairs of
primes differing by at most a fixed constant `B` (Zhang: `B = 7·10⁷`; Maynard–Tao:
`B = 246`).  The deduction
```
infinitely many bounded prime *pairs*  ⟹  liminf (p_{n+1} − p_n) ≤ B
```
is a clean elementary reduction, and it is exactly this reduction that turns the
sieve theorem into the headline statement about *consecutive* primes.  This file
proves that reduction with no sorries.

Let `p_n = nth Nat.Prime n` be the increasing enumeration of the primes and let
`primeGap n = p_{n+1} − p_n`.  We show:

* `exists_index_gap_le` : if for arbitrarily large `N` there exist primes
  `p < q ≤ p + B` with `N ≤ p`, then for every `M` there is an index `n ≥ M` with
  `primeGap n ≤ B`.  (Between such a pair lies a *consecutive* gap `≤ B`.)
* `liminf_primeGap_le` : the genuine `Filter.liminf` statement, `liminf primeGap ≤ B`.
* `liminf_primeGap_le_246` : the Maynard–Tao numerical corollary (`B = 246`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): a bounded prime *pair* `p < q ≤ p+B` forces a bounded
*consecutive* gap, because the next prime after `p` cannot exceed `q`.
Experiment (Experimenter): the next prime after `p = p_n` is `p_{n+1}`; we proved
`p_{n+1} ≤ q` by counting primes: `count Prime (q+1) ≥ n+2`, then `lt_nth_iff_count_lt`.
Analysis (Analyst): the index of `p` is `count Prime p`; the bound `q ≤ p+B` transfers
directly to `p_{n+1} − p_n ≤ B`.  No analytic input is needed for this step — all the
difficulty is hidden in the *hypothesis* (Zhang/Maynard).
Critique (Critic): we keep `liminf` honest by using `Filter.liminf_le_of_frequently_le`
rather than redefining liminf; the boundedness side-condition is discharged for ℕ.
Synthesis (PI): this is the "output" half of the bounded-gaps program; `Admissible.lean`
is the "input" half; `MaynardTao.lean` joins them.
-- !-- end Lab Notes -- !--
-/
import Mathlib

namespace TwinPrimeGaps

open Filter Nat

/-- The `n`-th prime gap, `p_{n+1} − p_n`, with `p_n = nth Nat.Prime n`. -/
noncomputable def primeGap (n : ℕ) : ℕ :=
  Nat.nth Nat.Prime (n + 1) - Nat.nth Nat.Prime n

/-
Key counting step: if `p` and `q` are primes with `p < q`, then the prime
immediately following `p` (namely `nth Nat.Prime (count Nat.Prime p + 1)`) is at most
`q`.
-/
theorem next_prime_le_of_prime_lt {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p < q) :
    Nat.nth Nat.Prime (Nat.count Nat.Prime p + 1) ≤ q := by
  -- By definition of `nth Nat.Prime`, we know that `nth Nat.Prime (count Nat.Prime p + 1)` is the smallest prime greater than `p`.
  have h_nth : nth Nat.Prime (count Nat.Prime p + 1) ≤ q := by
    have h_count : count Nat.Prime q > count Nat.Prime p := by
      grind +suggestions
    refine' Nat.le_of_lt_succ ( Nat.nth_lt_of_lt_count _ );
    rw [ Nat.count_succ ] ; aesop;
  assumption

/-
If arbitrarily large bounded prime pairs exist, then there are infinitely many
indices `n` with consecutive prime gap `≤ B`.
-/
theorem exists_index_gap_le (B : ℕ)
    (h : ∀ N : ℕ, ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N ≤ p ∧ p < q ∧ q ≤ p + B) :
    ∀ M : ℕ, ∃ n ≥ M, primeGap n ≤ B := by
  intro M
  obtain ⟨p, q, hp, hq, hN, hpq, hqle⟩ := h (Nat.nth Nat.Prime M + 1)
  use Nat.count (Nat.Prime) p
  have hn_ge_M : Nat.count (Nat.Prime) p ≥ M := by
    refine' le_of_not_gt fun h => _;
    linarith [ Nat.nth_count hp, Nat.nth_monotone ( Nat.infinite_setOf_prime ) h.le ]
  exact ⟨hn_ge_M, by
    exact le_trans ( Nat.sub_le_sub_right ( next_prime_le_of_prime_lt hp hq hpq ) _ ) ( by rw [ Nat.nth_count hp ] ; omega )⟩

/-
**Main reduction.** Infinitely many bounded prime pairs (gap `≤ B`) imply that the
`liminf` of consecutive prime gaps is at most `B`.
-/
theorem liminf_primeGap_le (B : ℕ)
    (h : ∀ N : ℕ, ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N ≤ p ∧ p < q ∧ q ≤ p + B) :
    Filter.atTop.liminf primeGap ≤ B := by
  refine' csSup_le _ _ <;> norm_num;
  · exact ⟨ 0, ⟨ 0, fun _ _ => Nat.zero_le _ ⟩ ⟩;
  · intro b x hx; have := exists_index_gap_le B h; obtain ⟨ n, hn₁, hn₂ ⟩ := this x; linarith [ hx n hn₁ ] ;

/-- **Maynard–Tao corollary.** The bounded-gaps theorem with constant `246` yields
`liminf (p_{n+1} − p_n) ≤ 246`. -/
theorem liminf_primeGap_le_246
    (h : ∀ N : ℕ, ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N ≤ p ∧ p < q ∧ q ≤ p + 246) :
    Filter.atTop.liminf primeGap ≤ 246 :=
  liminf_primeGap_le 246 h

end TwinPrimeGaps