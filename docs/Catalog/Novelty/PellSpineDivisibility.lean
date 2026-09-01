/-
# Strong divisibility on the Pell spine — and four conjectures it kills

Building on `Novelty.PellSpineCore`, this file proves that the Pell numbers form a
**strong divisibility sequence**,

`gcd (P m) (P n) = P (gcd m n)`,

and then uses that theorem as a *falsification engine*: four natural strengthenings of
it are each destroyed by a single explicit counterexample, all of them living inside the
first eight Pell numbers.

## Proved

* `pellP_gcd_step`   — the Euclidean step `gcd (P (m+n)) (P n) = gcd (P m) (P n)`;
* `pellP_gcd`        — **strong divisibility** `gcd (P m) (P n) = P (gcd m n)`;
* `pellP_dvd_iff`    — `m ∣ n ↔ P m ∣ P n`, with no side condition at all;
* `pellP_prime_index`— if `P n` is prime then `n` is prime;
* `pellQ_dvd_odd_multiple` — the *guarded* companion statement `Q n ∣ Q ((2k+1) * n)`.

## Refuted (each by one counterexample)

* `not_pellP_prime_of_prime_index`  — `n` prime does **not** force `P n` prime: `P 7 = 169 = 13²`;
* `not_pellP_squarefree`            — Pell numbers are **not** all squarefree: again `P 7 = 13²`
  (the exact analogue for Fibonacci numbers is a well-known open problem, and here it is
  false at the seventh term);
* `not_pellQ_strong_divisibility`   — the companion sequence is **not** a strong divisibility
  sequence: `gcd (Q 3) (Q 6) = gcd 7 99 = 1 ≠ 7 = Q 3`, even though `3 ∣ 6`;
* `not_prime_dvd_pellP_pred`        — the naive Fermat-style law `p ∣ P (p-1)` fails: `3 ∤ P 2 = 2`
  (the correct exponent is `p - (2/p)`, and `2` is a non-residue mod `3`).

The moral, extracted in `FUTURE_DIRECTIONS.md`: strong divisibility is a property of the
*norm-form solution* sequence `P`, not of the *trace* sequence `Q`, and it degrades to a
`2k+1`-graded statement on `Q`.
-/
import Novelty.PellSpineCore

namespace Catalog.Novelty.PellSpine

/-! ## The Euclidean step -/

/-- One Euclidean step: `gcd (P (m+n)) (P n) = gcd (P m) (P n)`.
The addition law turns `P (m+n)` into `P m * Q n + Q m * P n`; the second summand is
killed modulo `P n`, and `Q n` is coprime to `P n`. -/
theorem pellP_gcd_step (m n : ℕ) :
    Nat.gcd (pellP (m + n)) (pellP n) = Nat.gcd (pellP m) (pellP n) := by
  have hco : Nat.Coprime (pellQ n) (pellP n) :=
    Nat.Coprime.symm (pellP_coprime_pellQ n)
  calc Nat.gcd (pellP (m + n)) (pellP n)
      = Nat.gcd (pellP m * pellQ n + pellP n * pellQ m) (pellP n) := by
        rw [pellP_add]; ring_nf
    _ = Nat.gcd (pellP m * pellQ n) (pellP n) :=
        Nat.gcd_add_mul_left_left _ _ _
    _ = Nat.gcd (pellP m) (pellP n) := hco.gcd_mul_right_cancel _

/-- Iterated Euclidean step: multiples of the index may be discarded. -/
theorem pellP_gcd_mul_step (q m r : ℕ) :
    Nat.gcd (pellP (m * q + r)) (pellP m) = Nat.gcd (pellP r) (pellP m) := by
  induction q with
  | zero => simp
  | succ q ih =>
      have : m * (q + 1) + r = (m * q + r) + m := by ring
      rw [this, pellP_gcd_step, ih]

/-! ## Strong divisibility -/

/-- **Strong divisibility of the Pell spine**: `gcd (P m) (P n) = P (gcd m n)`.
The proof mirrors the Euclidean algorithm itself, by strong induction on the first index. -/
theorem pellP_gcd (m n : ℕ) : Nat.gcd (pellP m) (pellP n) = pellP (Nat.gcd m n) := by
  induction m using Nat.strong_induction_on generalizing n with
  | _ m ih =>
      rcases Nat.eq_zero_or_pos m with rfl | hm
      · simp
      · have hr : n % m < m := Nat.mod_lt _ hm
        have hsplit : m * (n / m) + n % m = n := by
          rw [Nat.mul_comm]; exact Nat.div_add_mod' n m
        calc Nat.gcd (pellP m) (pellP n)
            = Nat.gcd (pellP n) (pellP m) := Nat.gcd_comm _ _
          _ = Nat.gcd (pellP (m * (n / m) + n % m)) (pellP m) := by rw [hsplit]
          _ = Nat.gcd (pellP (n % m)) (pellP m) := pellP_gcd_mul_step _ _ _
          _ = pellP (Nat.gcd (n % m) m) := ih _ hr m
          _ = pellP (Nat.gcd m n) := by rw [← Nat.gcd_rec]

/-- Divisibility transfers *exactly*: `m ∣ n ↔ P m ∣ P n`, with no side condition
(the degenerate case `m = 0` works because `P n = 0` only for `n = 0`). -/
theorem pellP_dvd_iff (m n : ℕ) : m ∣ n ↔ pellP m ∣ pellP n := by
  constructor
  · intro h
    have : Nat.gcd (pellP m) (pellP n) = pellP m := by
      rw [pellP_gcd, Nat.gcd_eq_left_iff_dvd.mpr h]
    exact Nat.gcd_eq_left_iff_dvd.mp this
  · intro h
    have h1 : Nat.gcd (pellP m) (pellP n) = pellP m := Nat.gcd_eq_left_iff_dvd.mpr h
    rw [pellP_gcd] at h1
    have : Nat.gcd m n = m := pellP_injective h1
    exact Nat.gcd_eq_left_iff_dvd.mp this

/-- A prime Pell number forces a prime index. -/
theorem pellP_prime_index {n : ℕ} (h : Nat.Prime (pellP n)) : Nat.Prime n := by
  by_contra hn
  have hn2 : 2 ≤ n := by
    by_contra hlt
    interval_cases n <;> simp_all [pellP]
  obtain ⟨a, hadvd, ha2, halt⟩ := Nat.exists_dvd_of_not_prime2 hn2 hn
  have hdvd : pellP a ∣ pellP n := (pellP_dvd_iff a n).mp hadvd
  have h2 : 2 ≤ pellP a := two_le_pellP ha2
  have hlt : pellP a < pellP n := pellP_strictMono halt
  rcases (Nat.Prime.eq_one_or_self_of_dvd h _ hdvd) with h1 | h1 <;> omega

/-! ## The guarded companion statement -/

/-- `Q n` divides `P (2n)`: doubling always produces a factor of the companion term. -/
theorem pellQ_dvd_pellP_two_mul (n : ℕ) : pellQ n ∣ pellP (2 * n) := by
  rw [pellP_two_mul]
  exact ⟨2 * pellP n, by ring⟩

/-- **Guarded companion divisibility**: `Q n ∣ Q ((2k+1) * n)`.  Only *odd* multiples work
— see `not_pellQ_strong_divisibility` for the failure at the even multiple `6 = 2 * 3`. -/
theorem pellQ_dvd_odd_multiple (n k : ℕ) : pellQ n ∣ pellQ ((2 * k + 1) * n) := by
  induction k with
  | zero => simp
  | succ k ih =>
      have hidx : (2 * (k + 1) + 1) * n = (2 * k + 1) * n + 2 * n := by ring
      rw [hidx, pellQ_add]
      exact Dvd.dvd.add (ih.mul_right _)
        (Dvd.dvd.mul_left ((pellQ_dvd_pellP_two_mul n).mul_left _) 2)

/-! ## Numerical anchors for the counterexamples -/

theorem pellP_seven : pellP 7 = 169 := by decide
theorem pellQ_three : pellQ 3 = 7 := by decide
theorem pellQ_six : pellQ 6 = 99 := by decide
theorem pellP_two : pellP 2 = 2 := by decide

/-! ## Four refutations -/

/-- **Refutation 1.** A prime index does *not* force a prime Pell number: `P 7 = 169 = 13²`.
So `pellP_prime_index` is a strict one-way implication. -/
theorem not_pellP_prime_of_prime_index :
    ¬ ∀ n : ℕ, Nat.Prime n → Nat.Prime (pellP n) := by
  intro h
  have h7 : Nat.Prime (pellP 7) := h 7 (by norm_num)
  rw [pellP_seven] at h7
  norm_num at h7

/-- **Refutation 2.** The Pell numbers are not all squarefree: `P 7 = 169 = 13²`.
(The corresponding question for Fibonacci numbers is open; on the Pell spine the answer
is a flat *no*, and already at the seventh term.) -/
theorem not_pellP_squarefree : ¬ ∀ n : ℕ, Squarefree (pellP n) := by
  intro h
  have h7 := h 7
  rw [pellP_seven] at h7
  have := h7 13 (by norm_num)
  rw [Nat.isUnit_iff] at this
  omega

/-- **Refutation 3.** The companion sequence is *not* a strong divisibility sequence:
`3 ∣ 6` but `gcd (Q 3) (Q 6) = gcd 7 99 = 1`, whereas `Q (gcd 3 6) = Q 3 = 7`. -/
theorem not_pellQ_strong_divisibility :
    ¬ ∀ m n : ℕ, Nat.gcd (pellQ m) (pellQ n) = pellQ (Nat.gcd m n) := by
  intro h
  have h36 := h 3 6
  rw [pellQ_three, pellQ_six] at h36
  norm_num [pellQ_three] at h36

/-- **Refutation 4.** The naive Fermat-style law `p ∣ P (p-1)` for odd primes is false:
`p = 3` gives `P 2 = 2`.  (The true statement involves the Legendre symbol `(2/p)`, and
`2` is a non-residue mod `3`; indeed `3 ∣ P 4 = 12`.) -/
theorem not_prime_dvd_pellP_pred :
    ¬ ∀ p : ℕ, Nat.Prime p → 2 < p → p ∣ pellP (p - 1) := by
  intro h
  have h3 := h 3 (by norm_num) (by norm_num)
  norm_num [pellP_two] at h3

/-- **Refutation 5.**  "No Pell number past the first is a perfect square" is false:
`P 7 = 169 = 13²`.  (Ljunggren's theorem says `169` is the *only* such value, but a single
counterexample already kills the conjecture — and it is the same term `P 7` that kills
squarefreeness and primality above.) -/
theorem not_pellP_never_square : ¬ ∀ n : ℕ, 2 ≤ n → ¬ IsSquare (pellP n) := by
  intro h
  exact h 7 (by norm_num) ⟨13, by rw [pellP_seven]⟩

/-- The repaired form of Refutation 4 at `p = 3`: the rank of apparition of `3` is `4`,
which divides `p + 1`, not `p - 1`. -/
theorem three_dvd_pellP_four : 3 ∣ pellP 4 := by decide

end Catalog.Novelty.PellSpine