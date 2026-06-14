import Mathlib

/-! # A computable primitive-divisor criterion for strong divisibility sequences

Domain: Number Theory / Algebra (Applications) — Adversarial Ground-Truth cycle.

## What this file adds to the catalog

The catalog already contains two complementary strands of the Fibonacci primitive-divisor
program:

* `Catalog/Applications/StrongDivisibilitySequences.lean` (`StrongDivSeq.IsStrongDivSeq`) lifts the
  *structural* primitivity/apparition theory (uniqueness, the meet/join laws, apparition counting)
  to abstract strong divisibility sequences `u (gcd m n) = gcd (u m) (u n)`.
* `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` contains a *computational* engine —
  the "coprime part" `fibCoprimePart` together with `primitive_of_fibCoprimePart_pos` — but it is
  hard-wired to `Nat.fib` and only ever applied to Fibonacci.

This file fuses the two: it lifts the **computational engine itself** to the abstract
`IsStrongDivSeq` setting.  The single criterion `primitive_of_coprimePart_pos` then specializes,
with *no extra work*, both to

* **Fibonacci** (`fib_carmichael_band` — Carmichael's primitive-divisor theorem, verified uniformly
  over primes and composites on `13 ≤ n ≤ 1000`), and to
* **Mersenne / `aⁿ − 1`** (`mersenne_bang_band` — Bang's primitive-divisor theorem for `2ⁿ − 1`,
  verified on `2 ≤ n ≤ 120`, with the unique exception `n = 6` automatically isolated).

That a *single* `native_decide`-backed inequality on the computable `coprimePart` discharges two
classically separate theorems (Carmichael 1913 for Fibonacci, Bang 1886 for `2ⁿ − 1`) is the
cross-domain payoff: the engine never touches a Fibonacci identity — only strong divisibility.

This realizes **Direction 4** ("Generalize the criterion to arbitrary strong-divisibility
sequences") of the previous cycle's `FUTURE_DIRECTIONS.md`.

## Main results

* `dvd_index_gcd`                 — `p ∣ u m → p ∣ u n → p ∣ u (gcd m n)` from strong divisibility.
* `primitive_of_coprimePart_pos`  — **the engine**: if the computable witness `coprimePart u n > 1`
  then `u n` has a primitive prime divisor (a prime dividing `u n` but no earlier `u k`).
* `fib_carmichael_band`           — Carmichael verified, `sorry`-free, on `13 ≤ n ≤ 1000`.
* `mersenne_bang_band`            — Bang verified, `sorry`-free, on `2 ≤ n ≤ 120`, `n ≠ 6`.
-/

namespace StrongDivCriterion

/-- A **strong divisibility sequence**: `u (gcd m n) = gcd (u m) (u n)`.  This is the *only*
property of the underlying sequence used anywhere below. -/
def IsStrongDivSeq (u : ℕ → ℕ) : Prop :=
  ∀ m n, u (Nat.gcd m n) = Nat.gcd (u m) (u n)

/-! ## §1. The one structural lemma: strong divisibility descends to the gcd of indices -/

/-
!-- Lab Notebook: dvd_index_gcd -- !--
!-- Hypothesis: For a strong divisibility sequence, a common divisor of `u m` and `u n`
already divides `u (gcd m n)`. -- !--
!-- Result: Proved in one line by rewriting with the defining law and `Nat.dvd_gcd`. -- !--
!-- Insight: This is the *entire* number-theoretic content of the primitive-divisor engine;
everything else is computable bookkeeping that is sequence-agnostic. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- Rewrite `u (gcd m n) = gcd (u m) (u n)` and apply `Nat.dvd_gcd`. -- !--
theorem dvd_index_gcd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p m n : ℕ}
    (hm : p ∣ u m) (hn : p ∣ u n) : p ∣ u (Nat.gcd m n) := by
  rw [hu m n]; exact Nat.dvd_gcd hm hn

/-! ## §2. The computable "coprime part" and its basic algebra (sequence-independent) -/

/-- `removePrimesOf a b` strips from `a` every prime that it shares with `b`, by repeatedly
dividing out `gcd a b`.  The result divides `a` and is coprime to `b`. -/
def removePrimesOf (a b : ℕ) : ℕ :=
  if ha : a = 0 then 0
  else
    let g := Nat.gcd a b
    if hg : g ≤ 1 then a
    else
      have : a / g < a := Nat.div_lt_self (Nat.pos_of_ne_zero ha) (by omega)
      removePrimesOf (a / g) b
termination_by a

/-- The coprime part of `u n` relative to all *proper* divisors `d ∣ n`: start from `u n` and strip
out every prime shared with any `u d`.  If the result exceeds `1`, a primitive prime survives. -/
def coprimePart (u : ℕ → ℕ) (n : ℕ) : ℕ :=
  let properDivs := (List.range n).filter (fun d => 0 < d && n % d == 0)
  properDivs.foldl (fun acc d => removePrimesOf acc (u d)) (u n)

/-
!-- Lab Notebook: removePrimesOf_* -- !--
!-- Hypothesis: `removePrimesOf a b` divides `a`, is coprime to `b` (for `a > 0`), and stays
positive (for `a > 0`). -- !--
!-- Result: All three proved by strong induction on `a` along the `a / gcd a b` recursion. -- !--
!-- Insight: These facts never mention `u`; the engine is purely about integers, which is exactly
why it transplants from Fibonacci to any sequence. -- !--
!-- Failure analysis: positivity needs `a > 0`; `removePrimesOf 0 b = 0` is the only zero case. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- Strong induction on `a`; the recursive branch divides `a / gcd a b ∣ a`. -- !--
lemma removePrimesOf_dvd (a b : ℕ) : removePrimesOf a b ∣ a := by
  induction' a using Nat.strong_induction_on with a ih generalizing b
  unfold removePrimesOf
  split_ifs <;> simp_all +decide
  split_ifs
  · norm_num
  · exact dvd_trans (ih _ (Nat.div_lt_self (Nat.pos_of_ne_zero ‹_›) (lt_of_not_ge ‹_›)) _)
      (Nat.div_dvd_of_dvd (Nat.gcd_dvd_left _ _))

-- !-- Strong induction on `a`; either `gcd a b ≤ 1` already, or recurse on `a / gcd a b`. -- !--
lemma removePrimesOf_coprime (a b : ℕ) (ha : 0 < a) :
    Nat.Coprime (removePrimesOf a b) b := by
  induction' a using Nat.strong_induction_on with a ih generalizing b
  unfold removePrimesOf
  split_ifs <;> simp_all +decide [Nat.Coprime, Nat.gcd_comm]
  split_ifs
  · exact Nat.Coprime.symm (Nat.le_antisymm ‹_› (Nat.gcd_pos_of_pos_left _ ha))
  · exact ih _ (Nat.div_lt_self ha (lt_of_not_ge ‹_›)) _
      (Nat.div_pos (Nat.le_of_dvd ha (Nat.gcd_dvd_left _ _)) (Nat.gcd_pos_of_pos_left _ ha))

-- !-- A positive divisor of a positive number is positive. -- !--
lemma removePrimesOf_pos (a b : ℕ) (ha : 0 < a) : 0 < removePrimesOf a b :=
  Nat.pos_of_dvd_of_pos (removePrimesOf_dvd a b) ha

-- !-- Fold right-to-left; each step's `removePrimesOf` divides its accumulator, which divides `u n`. -- !--
lemma coprimePart_dvd (u : ℕ → ℕ) (n : ℕ) : coprimePart u n ∣ u n := by
  unfold coprimePart
  induction (List.filter (fun d => decide (0 < d) && n % d == 0) (List.range n))
      using List.reverseRecOn with
  | nil => simp
  | append_singleton l d ih =>
      simp [List.foldl_append]; exact dvd_trans (removePrimesOf_dvd _ _) ih

-- !-- `removePrimesOf 0 _ = 0`, so the whole fold collapses to `0`. -- !--
lemma foldl_removePrimesOf_zero (l : List ℕ) (f : ℕ → ℕ) :
    l.foldl (fun acc d => removePrimesOf acc (f d)) 0 = 0 := by
  induction l with
  | nil => rfl
  | cons d l ih =>
      simp only [List.foldl_cons]
      rw [show removePrimesOf 0 (f d) = 0 from by unfold removePrimesOf; simp]; exact ih

-- !-- If `u n = 0` the fold collapses to `0`, contradicting `coprimePart u n > 1`. -- !--
lemma un_pos_of_coprimePart_pos {u : ℕ → ℕ} {n : ℕ} (hcp : 1 < coprimePart u n) : 0 < u n := by
  by_contra h
  have hz : u n = 0 := by omega
  unfold coprimePart at hcp
  rw [hz, foldl_removePrimesOf_zero] at hcp
  omega

/-! ## §3. The engine: a positive coprime part forces a primitive prime divisor -/

/-
!-- Lab Notebook: primitive_of_coprimePart_pos -- !--
!-- Hypothesis: If the computable `coprimePart u n > 1`, then `u n` has a primitive prime divisor
(a prime `p ∣ u n` with `p ∤ u k` for every `0 < k < n`). -- !--
!-- Result: Proved for ALL strong divisibility sequences. The coprime part is coprime to `u d` for
every proper divisor `d ∣ n`; any prime `p` of it divides `u n` but, were `p ∣ u k`, then
`p ∣ u (gcd n k)` (by `dvd_index_gcd`) with `gcd n k` a proper divisor — contradiction. -- !--
!-- Insight: This is the catalog's `primitive_of_fibCoprimePart_pos` with `Nat.fib` erased; the only
non-bookkeeping step, `dvd_index_gcd`, uses strong divisibility alone. The criterion is therefore a
theorem about strong divisibility, not about Fibonacci. -- !--
!-- Failure analysis: the fold-positivity sub-induction needs `0 < u n`, recovered from
`un_pos_of_coprimePart_pos`; without it `removePrimesOf_coprime`'s hypothesis fails. -- !--
!-- End Lab Notebook -- !--
-/
theorem primitive_of_coprimePart_pos {u : ℕ → ℕ} (hu : IsStrongDivSeq u) (n : ℕ) (hn : 0 < n)
    (hcp : 1 < coprimePart u n) :
    ∃ p, Nat.Prime p ∧ p ∣ u n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ u k) := by
  have hun : 0 < u n := un_pos_of_coprimePart_pos hcp
  -- The coprime part is genuinely coprime to `u d` for every proper divisor `d ∣ n`.
  have h_coprime : ∀ d, d ∣ n → 0 < d → d < n → Nat.Coprime (coprimePart u n) (u d) := by
    intros d hd hdn hdn'
    have h_fold_coprime : ∀ (ds : List ℕ), d ∈ ds →
        Nat.Coprime (List.foldl (fun acc d => removePrimesOf acc (u d)) (u n) ds) (u d) := by
      intros ds hds
      induction' ds using List.reverseRecOn with ds e ih
      · simp at hds
      · rw [List.foldl_append]
        simp only [List.foldl_cons, List.foldl_nil]
        rcases List.mem_append.mp hds with h | h
        · exact Nat.Coprime.coprime_dvd_left (removePrimesOf_dvd _ _) (ih h)
        · simp only [List.mem_singleton] at h
          subst h
          apply removePrimesOf_coprime
          clear ih hds
          induction' ds using List.reverseRecOn with ds e2 ih2
          · simpa using hun
          · rw [List.foldl_append]; simp only [List.foldl_cons, List.foldl_nil]
            exact removePrimesOf_pos _ _ ih2
    apply h_fold_coprime
    simp [List.mem_filter, List.mem_range, hdn', hdn, Nat.dvd_iff_mod_eq_zero.mp hd]
  -- Pick a prime of the (still `> 1`) coprime part.
  obtain ⟨p, hp_prime, hp_dvd⟩ : ∃ p, Nat.Prime p ∧ p ∣ coprimePart u n :=
    Nat.exists_prime_and_dvd hcp.ne'
  have hp_dvd_un : p ∣ u n := dvd_trans hp_dvd (coprimePart_dvd u n)
  refine ⟨p, hp_prime, hp_dvd_un, fun k hk₁ hk₂ hk₃ => ?_⟩
  -- If `p ∣ u k`, then `p ∣ u (gcd n k)` with `gcd n k` a proper divisor, contradicting coprimality.
  contrapose! h_coprime
  refine ⟨Nat.gcd n k, Nat.gcd_dvd_left _ _, Nat.gcd_pos_of_pos_left _ hn, ?_, ?_⟩
  · exact lt_of_le_of_lt (Nat.le_of_dvd hk₁ (Nat.gcd_dvd_right _ _)) hk₂
  · exact fun hcoer =>
      hp_prime.not_dvd_one <| hcoer ▸ Nat.dvd_gcd hp_dvd (dvd_index_gcd hu hp_dvd_un hk₃)

/-! ## §4. Two concrete strong divisibility sequences -/

/-
!-- Lab Notebook: instances -- !--
!-- Hypothesis: `Nat.fib` and `n ↦ aⁿ − 1` are strong divisibility sequences. -- !--
!-- Result: Proved from `Nat.fib_gcd` and `Nat.pow_sub_one_gcd_pow_sub_one` respectively. -- !--
!-- Insight: These are the *only* Fibonacci/Mersenne-specific inputs in the entire file; the engine
above is fed exactly one fact per family. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- This is exactly `Nat.fib_gcd`. -- !--
theorem fib_isStrongDivSeq : IsStrongDivSeq Nat.fib := fun m n => Nat.fib_gcd m n

-- !-- This is `Nat.pow_sub_one_gcd_pow_sub_one`, with the `a = 0` edge case by `decide`. -- !--
theorem mersenne_isStrongDivSeq (a : ℕ) : IsStrongDivSeq (fun n => a ^ n - 1) := by
  intro m n; by_cases ha : a = 0 <;> simp_all +decide [Nat.pow_sub_one_gcd_pow_sub_one]

/-! ## §5. Carmichael (Fibonacci) and Bang (`2ⁿ − 1`) from one engine -/

/-
!-- Lab Notebook: fib_carmichael_band -- !--
!-- Hypothesis: For every `13 ≤ n ≤ 1000`, `F n` has a primitive prime divisor — uniformly for
primes and composites, with no case split. -- !--
!-- Result: Proved. `native_decide` certifies `coprimePart Nat.fib n > 1` across the band; the engine
converts that into a primitive divisor. -- !--
!-- Insight: Unlike the catalog's split (prime case via entry points, composite via a separate
verification), the coprime part handles both at once: a prime `n`'s only proper divisor is `1`,
whose `F 1 = 1` removes nothing, so `coprimePart = F n > 1`. -- !--
!-- Failure analysis: `n ≤ 12` is genuinely excluded — `F 6 = 8`, `F 12 = 144` have no primitive
divisor, so `coprimePart` there is `1`; the bound `13 ≤ n` is sharp. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- `native_decide` the band inequality, then feed it to `primitive_of_coprimePart_pos`. -- !--
theorem fib_carmichael_band : ∀ n, 13 ≤ n → n ≤ 1000 →
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  have key : ∀ n ∈ Finset.Icc 13 1000, 1 < coprimePart Nat.fib n := by native_decide
  intro n h1 h2
  exact primitive_of_coprimePart_pos fib_isStrongDivSeq n (by omega)
    (key n (Finset.mem_Icc.mpr ⟨h1, h2⟩))

/-
!-- Lab Notebook: mersenne_bang_band -- !--
!-- Hypothesis: For every `2 ≤ n ≤ 120` with `n ≠ 6`, `2ⁿ − 1` has a primitive prime divisor
(Bang 1886 / Zsygmondy base 2). -- !--
!-- Result: Proved by the SAME engine: `native_decide` certifies `coprimePart (2ⁿ−1) n > 1` except
at the single value `n = 6`, where `2⁶−1 = 63 = 7·3²` has `7 ∣ 2³−1` and `3 ∣ 2²−1`. -- !--
!-- Insight: One inequality on `coprimePart` discharges two historically distinct primitive-divisor
theorems; the exceptional set `{6}` for base 2 emerges automatically from the computation, mirroring
the Fibonacci exceptions `{1,2,6,12}`. -- !--
!-- Failure analysis: `n = 1` excluded (`2¹−1 = 1`); `n = 6` is the lone Zsygmondy exception. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- `native_decide` gives `n = 6 ∨ coprimePart > 1`; resolve `n = 6`, then run the engine. -- !--
theorem mersenne_bang_band : ∀ n, 2 ≤ n → n ≤ 120 → n ≠ 6 →
    ∃ p, Nat.Prime p ∧ p ∣ (2 ^ n - 1) ∧ ∀ k, 0 < k → k < n → ¬(p ∣ (2 ^ k - 1)) := by
  have key : ∀ n ∈ Finset.Icc 2 120, n = 6 ∨ 1 < coprimePart (fun k => 2 ^ k - 1) n := by
    native_decide
  intro n h1 h2 h3
  have hpos : 1 < coprimePart (fun k => 2 ^ k - 1) n :=
    (key n (Finset.mem_Icc.mpr ⟨h1, h2⟩)).resolve_left h3
  exact primitive_of_coprimePart_pos (mersenne_isStrongDivSeq 2) n (by omega) hpos

end StrongDivCriterion