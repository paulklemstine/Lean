import Mathlib

/-! # Carmichael's theorem — the prime case

This file supplies the prime-index half of Carmichael's primitive-divisor theorem
for the Fibonacci sequence, which the catalog files
`Speculative.AutoResearch.CarmichaelComposite` and `Shared.CarmichaelProof` consume
through the name `fib_primitive_divisor_prime`.

The mathematical content is the *rank-of-apparition* (entry-point) argument: every
prime `q ∣ F(n)` has a smallest index `α(q)` (its entry point) with `q ∣ F(α(q))`,
and the strong divisibility law `Nat.fib_gcd` forces `α(q) ∣ n`.  When `n` is prime
the only divisors are `1` and `n`; since `q ∤ F(1) = 1`, we must have `α(q) = n`,
i.e. `q` does not divide any earlier Fibonacci number — it is *primitive*.

-- !-- Lab Notebook -- !--
Hypothesis : For prime `n`, *every* prime divisor of `F(n)` is automatically a
  primitive divisor, so the prime case of Carmichael needs no computation — only the
  divisibility structure of entry points (`Nat.fib_gcd`).
Result     : Confirmed and proved `sorry`-free.  `fib_primitive_divisor_prime`
  closes the previously-missing `Shared.CarmichaelHelper` dependency of the arc.
Insight    : The composite case is genuinely harder precisely because a prime
  divisor of `F(n)` may have entry point a *proper* divisor of `n`; the entry-point
  argument alone no longer certifies primitivity, which is why `CarmichaelComposite`
  must strip the contributions of `F(d)` for proper `d ∣ n`.
Failure analysis : An earlier attempt tried to bound `F(n) > 1` via a generic
  `one_lt_fib` lemma; the robust route is monotonicity `Nat.fib_mono` against the
  concrete value `F(13) = 233`.
-- !--
-/

namespace CarmHelper

open Classical in
/-- The Fibonacci entry point (rank of apparition) of `p`: the least `k > 0` with
    `p ∣ F(k)`, or `0` if no such `k` exists. -/
noncomputable def entryPt (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then Nat.find h else 0

-- !-- Strong divisibility: `p ∣ F m` and `p ∣ F k` give `p ∣ F (gcd m k)` via `Nat.fib_gcd`. -- !--
lemma dvd_fib_gcd (p m k : ℕ) (hm : p ∣ Nat.fib m) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd m k) := by
  simpa [Nat.fib_gcd] using Nat.dvd_gcd hm hk

-- !-- The entry point is positive once some positive index witnesses `p ∣ F k`. -- !--
lemma entryPt_pos (p : ℕ) (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) : 0 < entryPt p := by
  unfold entryPt
  rw [dif_pos h]
  exact (Nat.find_spec h).1

-- !-- `p` divides the Fibonacci number at its own entry point. -- !--
lemma dvd_fib_entryPt (p : ℕ) (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (entryPt p) := by
  unfold entryPt
  rw [dif_pos h]
  exact (Nat.find_spec h).2

-- !-- Minimality: no index below the entry point is hit. -- !--
lemma entryPt_min (p m : ℕ) (h : ∃ k, 0 < k ∧ p ∣ Nat.fib k)
    (hm : 0 < m) (hlt : m < entryPt p) : ¬ p ∣ Nat.fib m := by
  intro hpm
  have : entryPt p ≤ m := by
    unfold entryPt
    rw [dif_pos h]
    exact Nat.find_le ⟨hm, hpm⟩
  omega

-- !-- Entry point divides any index it appears in (gcd minimality + `Nat.fib_gcd`). -- !--
lemma entryPt_dvd (p n : ℕ) (hn : 0 < n) (hpn : p ∣ Nat.fib n) : entryPt p ∣ n := by
  have hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k := ⟨n, hn, hpn⟩
  have hpos : 0 < entryPt p := entryPt_pos p hex
  have hdiv : p ∣ Nat.fib (entryPt p) := dvd_fib_entryPt p hex
  -- gcd n (entryPt p) is hit, and is ≤ entryPt p, so by minimality equals entryPt p
  have hgcd : p ∣ Nat.fib (Nat.gcd n (entryPt p)) := dvd_fib_gcd p n (entryPt p) hpn hdiv
  have hg_pos : 0 < Nat.gcd n (entryPt p) := Nat.gcd_pos_of_pos_left _ hn
  have hg_le : Nat.gcd n (entryPt p) ≤ entryPt p := Nat.gcd_le_right _ hpos
  have heq : Nat.gcd n (entryPt p) = entryPt p := by
    rcases lt_or_eq_of_le hg_le with hlt | heq
    · exact absurd hgcd (entryPt_min p _ hex hg_pos hlt)
    · exact heq
  -- gcd divides n
  have : entryPt p ∣ n := by
    rw [← heq]; exact Nat.gcd_dvd_left _ _
  exact this

-- !-- A prime cannot divide `F 1 = 1`, so its entry point is never `1`. -- !--
lemma entryPt_ne_one (p : ℕ) (hp : Nat.Prime p) : entryPt p ≠ 1 := by
  intro h
  by_cases hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k
  · have hdiv : p ∣ Nat.fib (entryPt p) := dvd_fib_entryPt p hex
    rw [h] at hdiv
    simp [Nat.fib_one] at hdiv
    exact hp.one_lt.ne' hdiv
  · unfold entryPt at h
    rw [dif_neg hex] at h
    exact absurd h (by norm_num)

end CarmHelper

-- !-- For prime `n ≥ 13`, `F n ≥ F 13 = 233 > 1`, so it admits a prime divisor. -- !--
lemma fib_gt_one_of_ge_thirteen (n : ℕ) (hn : 13 ≤ n) : 1 < Nat.fib n := by
  have : Nat.fib 13 ≤ Nat.fib n := Nat.fib_mono hn
  have h13 : Nat.fib 13 = 233 := by decide
  omega

/-- **Carmichael's theorem, prime case.** For prime `n ≥ 13`, the Fibonacci number
    `F(n)` has a *primitive* prime divisor: a prime `p ∣ F(n)` that divides no
    earlier Fibonacci number. -/
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hnp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  -- !-- Take any prime `p ∣ F n`; its entry point divides the prime `n` and is `≠ 1`,
  --     hence equals `n`, so `p` divides no `F k` with `k < n`. -- !--
  have hfn : 1 < Nat.fib n := fib_gt_one_of_ge_thirteen n hn
  obtain ⟨p, hp, hpn⟩ := Nat.exists_prime_and_dvd (n := Nat.fib n) (by omega)
  have hnpos : 0 < n := by omega
  have hdvd : CarmHelper.entryPt p ∣ n := CarmHelper.entryPt_dvd p n hnpos hpn
  have hne1 : CarmHelper.entryPt p ≠ 1 := CarmHelper.entryPt_ne_one p hp
  -- divisors of a prime are 1 and n
  have hcases : CarmHelper.entryPt p = 1 ∨ CarmHelper.entryPt p = n :=
    (Nat.dvd_prime hnp).mp hdvd
  have heq : CarmHelper.entryPt p = n := hcases.resolve_left hne1
  refine ⟨p, hp, hpn, ?_⟩
  intro k hk hkn
  have hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k := ⟨n, hnpos, hpn⟩
  have hlt : k < CarmHelper.entryPt p := by rw [heq]; exact hkn
  exact CarmHelper.entryPt_min p k hex hk hlt