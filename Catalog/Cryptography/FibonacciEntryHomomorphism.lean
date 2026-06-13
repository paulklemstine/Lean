import Mathlib
import Cryptography.FibonacciDivisibilityLattice

/-!
# The Fibonacci Entry-Point Map is a Lattice Homomorphism

This file extends the rank-of-apparition theory of
`Cryptography.FibonacciDivisibilityLattice` (the catalog `FibLattice` namespace,
built on the catalog identity `Nat.fib_gcd`, the "Fib_gcd_identity").

`FibLattice.entry m` is the *rank of apparition* of `m`: the least positive index
`k` with `m ∣ fib k`.  The catalog already proved the **apparition law**
`FibLattice.fib_dvd_iff_entry_dvd : m ∣ fib n ↔ entry m ∣ n`, i.e. the apparition
indices of `m` form the principal ideal `(entry m)` of `(ℕ, ∣)`.

We use this law as a *black box* to expose the algebraic structure of the map
`m ↦ entry m` from `(ℕ_{>0}, ∣)` to `(ℕ_{>0}, ∣)`:

* `FibEntry.entry_one`         — `entry 1 = 1` (the map is unital).
* `FibEntry.entry_dvd_of_dvd`  — `a ∣ b → entry a ∣ entry b` (it is *monotone*
                                  for the divisibility order).
* `FibEntry.entry_lcm`         — `entry (lcm a b) = lcm (entry a) (entry b)`:
                                  the map is a **join (lcm) homomorphism**.
* `FibEntry.entry_fib`         — `entry (fib k) = k` for `3 ≤ k`: the map is a
                                  one-sided inverse of `fib`, so `fib` embeds
                                  `(ℕ_{≥3}, ∣)` as a sub-poset on which `entry`
                                  retracts.

None of these structural results are in Mathlib.  The join-homomorphism law
`entry (lcm a b) = lcm (entry a) (entry b)` is the central new statement: it says
the rank of apparition transports the *least common apparition* of two moduli to
the lcm of their individual ranks — the exact fact one needs to compute combined
Pisano/apparition data of a composite modulus from its prime-power parts, which is
the structural core of Lucas-sequence primality certificates (Cryptography).

-- !-- Lab Notebook -- !--
Hypothesis: the catalog apparition law `fib_dvd_iff_entry_dvd` (`m ∣ fib n ↔
  entry m ∣ n`) is by itself strong enough to force `entry` to be a lattice
  homomorphism, with NO further appeal to the Fibonacci recurrence.
Result: Confirmed.  Every theorem below is proved purely by translating a
  divisibility question about `fib` into one about indices via the apparition law,
  then using elementary `ℕ`-divisibility (`Nat.dvd_antisymm`, `Nat.lcm_dvd_iff`).
Insight: `entry` is the "Galois adjoint" presentation of `fib`: the apparition law
  literally says `entry m ∣ n ↔ m ∣ fib n`, an adjunction between `(ℕ_{>0},∣)` and
  itself.  An adjoint preserves *all* joins that exist, which is exactly why the
  lcm law holds for free — and why the gcd/meet law does NOT (apparition is a left
  adjoint, so it need not preserve meets, matching the known failure of
  `entry (gcd a b) = gcd (entry a) (entry b)`).
Failure analysis: `entry_fib` needs `3 ≤ k`; at `k = 1, 2` we have `fib k = 1`,
  whose apparition rank is `1 ≠ k`, so the retraction `entry ∘ fib = id` is sharp
  exactly where `fib` stops being injective (cf. `FibLattice.fib_eq_one_iff`).
-/

open Nat

namespace FibEntry

open FibLattice

-- !-- Two positive naturals with the same principal divisibility ideal are equal:
-- `x ∣ y` (take the witness `n = y`) and `y ∣ x` (take `n = x`), then antisymmetry. -- !--
/-- A divisibility-ideal extensionality principle: if `x` and `y` have the same
multiples, they are equal. -/
lemma dvd_ext {x y : ℕ} (h : ∀ n, x ∣ n ↔ y ∣ n) : x = y :=
  Nat.dvd_antisymm ((h y).2 dvd_rfl) ((h x).1 dvd_rfl)

-- !-- `1 ∣ fib k` for all `k`, so the apparition law gives `entry 1 ∣ n` for all `n`;
-- specialised at `n = 1` with `entry 1 > 0` this pins `entry 1 = 1`. -- !--
/-- The rank of apparition of `1` is `1`: the map is unital. -/
theorem entry_one : entry 1 (by norm_num) = 1 := by
  unfold entry;
  simp +decide [ Nat.find_eq_iff ]

-- !-- By the apparition law `entry a ∣ entry b ↔ a ∣ fib (entry b)`; the right side
-- holds since `a ∣ b ∣ fib (entry b)` (`entry_dvd_fib`). -- !--
/-- The rank of apparition is monotone for divisibility: `a ∣ b → entry a ∣ entry b`. -/
theorem entry_dvd_of_dvd {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (hab : a ∣ b) :
    entry a ha ∣ entry b hb := by
      exact FibLattice.fib_dvd_iff_entry_dvd a ha ( entry b hb ) |>.1 ( dvd_trans hab ( FibLattice.entry_dvd_fib b hb ) )

-- !-- For each `n`, chase the apparition law and `Nat.lcm_dvd_iff`:
-- `entry (lcm a b) ∣ n ↔ lcm a b ∣ fib n ↔ (a ∣ fib n ∧ b ∣ fib n)
-- ↔ (entry a ∣ n ∧ entry b ∣ n) ↔ lcm (entry a) (entry b) ∣ n`; then `dvd_ext`. -- !--
/-- **Join homomorphism law.**  The rank of apparition turns least-common-apparition
into lcm of ranks: `entry (lcm a b) = lcm (entry a) (entry b)`. -/
theorem entry_lcm {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    entry (Nat.lcm a b) (Nat.pos_of_ne_zero fun h => by
      rcases Nat.eq_zero_of_lcm_eq_zero h with h | h <;> omega)
      = Nat.lcm (entry a ha) (entry b hb) := by
        apply dvd_ext
        simp only [Nat.lcm_dvd_iff]
        intro n
        rw [← fib_dvd_iff_entry_dvd, ← fib_dvd_iff_entry_dvd, ← fib_dvd_iff_entry_dvd]
        simp +decide [Nat.lcm_dvd_iff]

-- !-- `entry (fib k) ∣ k` from the apparition law at `n = k` (since `fib k ∣ fib k`),
-- and `k ∣ entry (fib k)` from the catalog converse law `fib_dvd_fib_iff` applied to
-- `fib k ∣ fib (entry (fib k))` (which is `entry_dvd_fib`); antisymmetry finishes. -- !--
/-- `entry` retracts `fib` on indices `≥ 3`: `entry (fib k) = k`. -/
theorem entry_fib {k : ℕ} (hk : 3 ≤ k) :
    entry (fib k) (Nat.fib_pos.mpr (by omega)) = k := by
      refine' Nat.dvd_antisymm _ _;
      · exact FibLattice.fib_dvd_iff_entry_dvd _ ( by linarith [ Nat.fib_pos.2 ( by linarith : 0 < k ) ] ) _ |>.1 ( dvd_refl _ );
      · exact FibLattice.fib_dvd_fib_iff hk |>.1 ( FibLattice.entry_dvd_fib _ _ )

end FibEntry