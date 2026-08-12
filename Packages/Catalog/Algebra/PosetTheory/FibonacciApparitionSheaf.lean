import Mathlib

/-!
# The Fibonacci rank of apparition

`Shared.NumberTheory.CarmichaelCompositeEntryPoint` develops the theory of Fibonacci entry
points on top of a general "rank of apparition" interface, but the module providing that
interface is missing from this snapshot.  This file restores it.

For a positive integer `p` the *rank of apparition* `fibRank p` is the least positive index
`k` with `p ∣ F k`.  It exists for every `p > 0`: the pairs `(F n mod p, F (n+1) mod p)` take
finitely many values, so two of them coincide, and the Fibonacci recurrence is invertible, so
the pair `(0, 1)` recurs — that is, some positive Fibonacci index is divisible by `p`.

Main results:

* `hasFibRank_of_pos` — existence of the rank for every positive `p`;
* `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` — the defining minimality properties;
* `fibRank_dvd_iff` — `p ∣ F n ↔ fibRank p ∣ n`, via the strong divisibility property
  `gcd (F m) (F n) = F (gcd m n)`.
-/

namespace FibonacciApparitionSheaf

open Nat

/-- `p` admits a Fibonacci rank of apparition: some positive Fibonacci index is divisible
by `p`. -/
def HasFibRank (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ Nat.fib k

/-- **Existence of the rank of apparition.**  Pigeonhole on the pairs
`(F n mod p, F (n+1) mod p)` together with invertibility of the Fibonacci recurrence. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ (fib i % p = fib j % p) ∧
      (fib (i + 1) % p = fib (j + 1) % p) := by
    have h_finite : Set.Finite (Set.range fun n => (fib n % p, fib (n + 1) % p)) := by
      exact Set.finite_iff_bddAbove.mpr ⟨⟨p - 1, p - 1⟩, by
        rintro a ⟨n, rfl⟩
        exact ⟨Nat.le_sub_one_of_lt (Nat.mod_lt _ hp), Nat.le_sub_one_of_lt (Nat.mod_lt _ hp)⟩⟩
    contrapose! h_finite
    exact Set.infinite_range_of_injective fun i j hij =>
      le_antisymm (le_of_not_gt fun hi => h_finite _ _ hi (by aesop) (by aesop))
        (le_of_not_gt fun hj => h_finite _ _ hj (by aesop) (by aesop))
  obtain ⟨i, j, hij, hi, hj⟩ := h_pigeonhole
  induction' i with i ih generalizing j
  · induction' j with j ihj
    · aesop
    · exact ⟨j + 1, Nat.succ_pos _, Nat.dvd_of_mod_eq_zero <| by simpa using hi.symm⟩
  · specialize ih (j - 1) (Nat.lt_pred_iff.mpr hij)
    rcases j <;> simp_all +arith +decide [Nat.fib_add_two, Nat.add_mod]
    simp_all +decide [← ZMod.natCast_eq_natCast_iff']

/-- The rank of apparition of `p`: the least positive `k` with `p ∣ F k`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {k | 0 < k ∧ p ∣ Nat.fib k}

theorem fibRank_spec {p : ℕ} (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem h

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_spec h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_spec h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **`p ∣ F n` exactly when the rank of apparition divides `n`.** -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    have hgcd : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd hpn (dvd_fib_fibRank h)
    have hpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hn
    have hle : Nat.gcd n (fibRank p) ≤ fibRank p :=
      Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
    have heq : Nat.gcd n (fibRank p) = fibRank p := by
      by_contra hne
      exact fibRank_min hpos (lt_of_le_of_ne hle hne) hgcd
    exact heq ▸ Nat.gcd_dvd_left _ _
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf