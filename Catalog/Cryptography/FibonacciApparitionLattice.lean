import Cryptography.FibonacciDivisibilityLattice

/-!
# The Fibonacci Apparition Lattice: rank of apparition is a lattice homomorphism

This file extends the catalog development in
`Cryptography.FibonacciDivisibilityLattice` (the `FibLattice` namespace), which proved
that the Fibonacci sequence is a faithful **strong divisibility sequence** and constructed
the *rank of apparition* `FibLattice.entry m` — the least positive index `k` with
`m ∣ fib k` — together with the **apparition law**

  `FibLattice.fib_dvd_iff_entry_dvd : m ∣ fib n ↔ entry m ∣ n`.

That single bridge lemma is the engine of the whole apparition theory.  Here we show that
the rank of apparition is not merely a function but a **lattice homomorphism** from the
divisibility lattice of moduli into itself: it is monotone for divisibility and, most
importantly, sends `lcm` to `lcm`.  This is the structural fact underpinning the
Chinese-Remainder decomposition of Lucas-sequence primality tests: to find the order of a
modulus `m = p1^e1 * p2^e2 * ...` in the Fibonacci sequence it suffices to find it on each
prime power and take the lcm.

## Main results
* `FibLattice.entry_unique`        — the apparition law *characterizes* `entry`: any
                                     positive `d` whose multiples are exactly the apparition
                                     indices equals `entry m`.
* `FibLattice.entry_eq_one_iff`    — `entry m = 1 ↔ m = 1`.
* `FibLattice.entry_dvd_entry_of_dvd` — `entry` is **monotone for divisibility**:
                                     `m ∣ m' → entry m ∣ entry m'`.
* `FibLattice.entry_lcm`           — **the lattice homomorphism**: `entry` sends `lcm` to
                                     `lcm`: `entry (lcm m n) = lcm (entry m) (entry n)`.
* `FibLattice.entry_mul_coprime`   — **CRT corollary**: for coprime moduli,
                                     `entry (m*n) = lcm (entry m) (entry n)`.

-- !-- Lab Notebook -- !--
Hypothesis: The catalog apparition law `fib_dvd_iff_entry_dvd` is strong enough to make the
  rank of apparition a lattice homomorphism `(ℕ, ∣) → (ℕ, ∣)`, in particular `entry`
  commuting with `lcm`.  This would give a CRT decomposition of Fibonacci orders.
Result: Confirmed.  The apparition law turns every statement about `m ∣ fib k` into a
  statement about `entry m ∣ k`.  Since a natural number is determined by the set of its
  multiples (`Nat.dvd_antisymm`), and `lcm a b ∣ k ↔ a ∣ k ∧ b ∣ k`, the identity
  `entry (lcm m n) = lcm (entry m) (entry n)` falls out with no extra number theory.
Insight: `entry` is the inverse image of the *generator-of-multiple-set* operation.  Two
  divisors that divide exactly the same indices are equal; the apparition law identifies
  the multiple-set of `entry m` with the apparition set of `m`, so all of `entry`'s
  algebraic behaviour is forced by how apparition sets behave under `lcm`/`dvd`.
Failure analysis: the homomorphism is into the `lcm` (join) structure, NOT `gcd` (meet):
  `entry (gcd m n)` is *not* generally `gcd (entry m) (entry n)` because the apparition set
  of `gcd m n` is larger than the union of the two apparition sets.  The `lcm` direction is
  the one pinned down by the apparition law.
-/

open Nat

namespace FibLattice

-- !-- A natural number is determined by the set of its multiples: apply the hypothesis at
-- `n = d` and `n = e`, then `Nat.dvd_antisymm`. -- !--
/-- Two naturals dividing exactly the same set of naturals are equal. -/
lemma eq_of_dvd_iff_dvd {d e : ℕ} (h : ∀ n, d ∣ n ↔ e ∣ n) : d = e :=
  Nat.dvd_antisymm ((h _).2 (dvd_refl _)) ((h _).1 (dvd_refl _))

-- !-- Both `d ∣ n` and `entry m ∣ n` are equivalent to `m ∣ fib n` (via `hchar` and
-- `fib_dvd_iff_entry_dvd`), so `eq_of_dvd_iff_dvd` identifies them. -- !--
/-- **Characterization of the rank of apparition.**  `entry m` is the unique positive
number whose multiples are exactly the apparition indices of `m`. -/
theorem entry_unique (m : ℕ) (hm : 0 < m) (d : ℕ)
    (hchar : ∀ n, d ∣ n ↔ m ∣ fib n) : d = entry m hm :=
  eq_of_dvd_iff_dvd fun n => by rw [hchar, FibLattice.fib_dvd_iff_entry_dvd]

-- !-- `entry m = 1 ↔ entry m ∣ 1 ↔ m ∣ fib 1` by the apparition law at `n = 1`; and
-- `fib 1 = 1`, so `m ∣ fib 1 ↔ m = 1`. -- !--
/-- The rank of apparition equals `1` exactly for the modulus `1`. -/
theorem entry_eq_one_iff (m : ℕ) (hm : 0 < m) : entry m hm = 1 ↔ m = 1 := by
  constructor <;> intro h
  · have := entry_dvd_fib m hm; aesop
  · convert fib_dvd_iff_entry_dvd m hm 1
    aesop

-- !-- `entry m ∣ entry m' ↔ m ∣ fib (entry m')` by the apparition law; and
-- `m ∣ m' ∣ fib (entry m')` using `entry_dvd_fib`. -- !--
/-- **Monotonicity for divisibility.**  If `m ∣ m'` then `entry m ∣ entry m'`. -/
theorem entry_dvd_entry_of_dvd {m m' : ℕ} (hm : 0 < m) (hm' : 0 < m')
    (h : m ∣ m') : entry m hm ∣ entry m' hm' := by
  rw [← FibLattice.fib_dvd_iff_entry_dvd]
  exact dvd_trans h (FibLattice.entry_dvd_fib m' hm')

-- !-- For every `k`, both sides divide `k` iff `lcm m n ∣ fib k`: unfold both `lcm`s with
-- `Nat.lcm_dvd_iff`, rewrite each apparition via `fib_dvd_iff_entry_dvd`, and the goal
-- reduces to `Nat.lcm_dvd_iff` again.  Conclude with `eq_of_dvd_iff_dvd`. -- !--
/-- **The rank of apparition is a lattice homomorphism.**  It sends `lcm` to `lcm`:
`entry (lcm m n) = lcm (entry m) (entry n)`.  Equivalently, an index `k` is an apparition
index of `lcm m n` iff it is a common apparition index of `m` and `n`. -/
theorem entry_lcm (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    entry (Nat.lcm m n) (Nat.pos_of_ne_zero (by simp [Nat.lcm_ne_zero hm.ne' hn.ne']))
      = Nat.lcm (entry m hm) (entry n hn) := by
  apply eq_of_dvd_iff_dvd
  intro k
  rw [Nat.lcm_dvd_iff, ← fib_dvd_iff_entry_dvd, ← fib_dvd_iff_entry_dvd,
    ← fib_dvd_iff_entry_dvd]
  exact Nat.lcm_dvd_iff

-- !-- For coprime `m, n`, `lcm m n = m * n` (`Nat.Coprime.lcm_eq_mul`); rewrite the
-- modulus and apply `entry_lcm` (the positivity proof is irrelevant). -- !--
/-- **CRT decomposition of the Fibonacci order.**  For coprime moduli, the rank of
apparition of the product is the lcm of the two ranks. -/
theorem entry_mul_coprime (m n : ℕ) (hm : 0 < m) (hn : 0 < n) (hcop : Nat.Coprime m n) :
    entry (m * n) (Nat.mul_pos hm hn) = Nat.lcm (entry m hm) (entry n hn) := by
  convert entry_lcm m n hm hn using 2
  rw [hcop.lcm_eq_mul]

-- !-- `entry m` is `Nat.find` of the apparition predicate `fun k => 0 < k ∧ m ∣ fib k`,
-- so `Nat.find_eq_iff` says `entry m = n` iff `n` satisfies the predicate and no smaller
-- index does — which is exactly primitivity. -- !--
/-- **Bridge to the Carmichael primitive-divisor theory** (cf. `fib_carmichael_composite`
in `Shared.CarmichaelProof`).  The rank of apparition of `m` equals `n` exactly when `m`
is a *primitive* divisor of `fib n`: it divides `fib n` but none of the earlier Fibonacci
numbers.  For a prime `m = p` this is precisely the statement that `p` is a primitive prime
divisor of `fib n`, the object whose existence Carmichael's theorem asserts. -/
theorem entry_eq_iff_primitive (m : ℕ) (hm : 0 < m) (n : ℕ) (hn : 0 < n) :
    entry m hm = n ↔ (m ∣ fib n ∧ ∀ k, 0 < k → k < n → ¬ m ∣ fib k) := by
  rw [entry, Nat.find_eq_iff]
  constructor
  · rintro ⟨⟨-, hmn⟩, hlt⟩
    exact ⟨hmn, fun k hk hkn hmk => hlt k hkn ⟨hk, hmk⟩⟩
  · rintro ⟨hmn, hlt⟩
    exact ⟨⟨hn, hmn⟩, fun k hkn ⟨hk, hmk⟩ => hlt k hk hkn hmk⟩

end FibLattice