import Mathlib

/-!
# The Fibonacci Divisibility Lattice

A first-principles development of the divisibility structure of the Fibonacci
sequence, built on the single catalog identity

  `Nat.fib_gcd : fib (gcd m n) = gcd (fib m) (fib n)`     ("Fib_gcd_identity").

The Fibonacci sequence is the prototypical **strong divisibility sequence**: it
carries the divisibility lattice of `ℕ` *faithfully* into the divisibility lattice
of its values.  Mathlib already proves the easy half (`Nat.fib_dvd : m ∣ n → fib m ∣ fib n`).
Here we prove the genuinely harder **converse**, which is *not* in Mathlib, together
with its coprimality counterpart and the rank-of-apparition theory.  These results are
the structural backbone of Lucas-sequence primality testing (the "rank of apparition"),
hence the Cryptography domain.

## Main results
* `FibLattice.fib_inj_iff`     — `fib` is injective on indices `≥ 2`.
* `FibLattice.fib_dvd_fib_iff` — **converse divisibility law**: for `3 ≤ m`,
                                  `fib m ∣ fib n ↔ m ∣ n`.
* `FibLattice.fib_coprime_iff` — `fib m, fib n` are coprime iff `gcd m n ∈ {1,2}`.
* `FibLattice.entry_exists`    — every modulus has a Fibonacci **entry point**
                                  (rank of apparition).
* `FibLattice.fib_dvd_iff_entry_dvd` — `m ∣ fib n ↔ entry m ∣ n`: the entry point
                                  generates the whole lattice of apparitions.

-- !-- Lab Notebook -- !--
Hypothesis: `Nat.fib_gcd` (the catalog Fib_gcd_identity) is strong enough to pin
  down the *entire* divisibility lattice of the Fibonacci sequence, not just the
  forward direction `Nat.fib_dvd` already in Mathlib.
Result: Confirmed.  Combining `fib_gcd` with strict monotonicity of `fib` on
  `Ici 2` yields the converse divisibility law and the coprimality criterion in a
  few lines each.  The rank-of-apparition existence follows from finiteness of the
  state `(fib k, fib k+1) mod m` plus invertibility of the recurrence step.
Insight: `gcd (fib m) (fib n) = fib (gcd m n)` is a *lattice homomorphism*; once
  `fib` is known injective above index 1, the homomorphism is faithful, so every
  divisibility/coprimality question downstairs is answered upstairs.
Failure analysis: the law fails for `m ≤ 2` (since `fib 1 = fib 2 = 1` divides
  everything), which is exactly why the hypothesis `3 ≤ m` is sharp.
-/

open Nat

namespace FibLattice

-- !-- `fib` is strictly monotone on `Ici 2` (`Nat.fib_strictMonoOn`), and a strictly
-- monotone function is injective there; specialize to `m, n ≥ 2`. -- !--
/-- `fib` is injective on indices `≥ 2`. -/
lemma fib_inj_iff {m n : ℕ} (hm : 2 ≤ m) (hn : 2 ≤ n) : fib m = fib n ↔ m = n := by
  refine ⟨?_, fun h => h ▸ rfl⟩
  exact fun h => Nat.fib_strictMonoOn.injOn (show m ∈ Set.Ici 2 from hm)
    (show n ∈ Set.Ici 2 from hn) h

-- !-- `fib k = 1` exactly at the two unit indices `1, 2`: check small cases, then use
-- `fib_pos` to rule out everything from index 3 onward (where `fib ≥ 2`). -- !--
/-- The Fibonacci value `1` is attained exactly at indices `1` and `2`. -/
lemma fib_eq_one_iff {k : ℕ} : fib k = 1 ↔ k = 1 ∨ k = 2 := by
  rcases k with (_ | _ | _ | k) <;> simp_all +arith +decide [Nat.fib_add_two]
  linarith [Nat.fib_pos.2 k.succ_pos]

-- !-- (←) is `Nat.fib_dvd`.  (→): `fib m ∣ fib n` gives `gcd (fib m) (fib n) = fib m`,
-- so by `fib_gcd`, `fib (gcd m n) = fib m`; `m ≥ 3` forces `gcd m n ≥ 2`, so inject via
-- `fib_inj_iff` to get `gcd m n = m`, i.e. `m ∣ n`. -- !--
/-- **Converse divisibility law.**  For `3 ≤ m`, Fibonacci divisibility is faithful:
`fib m ∣ fib n ↔ m ∣ n`.  (Not in Mathlib; only the forward `Nat.fib_dvd` is.) -/
theorem fib_dvd_fib_iff {m n : ℕ} (hm : 3 ≤ m) : fib m ∣ fib n ↔ m ∣ n := by
  refine ⟨fun h => ?_, fun h => Nat.fib_dvd _ _ h⟩
  have h_fib_gcd : fib (Nat.gcd m n) = fib m := by
    rw [← Nat.gcd_eq_left h, Nat.fib_gcd]
  have h_gcd_m_n_ge_2 : 2 ≤ Nat.gcd m n := by
    contrapose! h_fib_gcd
    interval_cases _ : Nat.gcd m n <;> simp_all +decide
    linarith [Nat.le_fib_add_one m]
  exact fib_inj_iff h_gcd_m_n_ge_2 (by linarith) |>.1 h_fib_gcd ▸ Nat.gcd_dvd_right _ _

-- !-- `Coprime (fib m) (fib n)` is `gcd (fib m) (fib n) = 1`; rewrite by `← fib_gcd`
-- to `fib (gcd m n) = 1` and apply `fib_eq_one_iff`. -- !--
/-- Fibonacci coprimality criterion: `fib m` and `fib n` are coprime exactly when
the index gcd is `1` or `2`.  (No positivity hypotheses are needed.) -/
theorem fib_coprime_iff {m n : ℕ} :
    Nat.Coprime (fib m) (fib n) ↔ Nat.gcd m n = 1 ∨ Nat.gcd m n = 2 := by
  convert fib_eq_one_iff using 1
  rw [Nat.Coprime, ← fib_gcd]

/-! ## Rank of apparition (entry point) -/

-- !-- The pair `(fib k, fib (k+1)) mod m` ranges over the finite set `[0,m)²`, so by
-- pigeonhole it repeats at some `i < j`; the recurrence step is invertible, so running
-- back from `j` to `0` yields `fib (j-i) ≡ 0 (mod m)` with `j-i > 0`. -- !--
/-- Every positive modulus divides some positive-index Fibonacci number: the
**entry point** (rank of apparition) exists. -/
theorem entry_exists (m : ℕ) (hm : 0 < m) : ∃ k, 0 < k ∧ m ∣ fib k := by
  by_contra! h_contra
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧
      (fib i % m = fib j % m ∧ fib (i + 1) % m = fib (j + 1) % m) := by
    have h_pigeonhole : Set.Finite (Set.range (fun k => (fib k % m, fib (k + 1) % m))) := by
      exact Set.finite_iff_bddAbove.mpr ⟨⟨m - 1, m - 1⟩, by
        rintro a ⟨k, rfl⟩
        exact ⟨Nat.le_sub_one_of_lt (Nat.mod_lt _ hm), Nat.le_sub_one_of_lt (Nat.mod_lt _ hm)⟩⟩
    contrapose! h_pigeonhole
    exact Set.infinite_range_of_injective fun i j hij => le_antisymm
      (le_of_not_gt fun hi => h_pigeonhole _ _ hi (by aesop) (by aesop))
      (le_of_not_gt fun hj => h_pigeonhole _ _ hj (by aesop) (by aesop))
  induction' i with i ih generalizing j <;> simp_all +decide [Nat.fib_add_two]
  · exact h_contra j hij (Nat.dvd_of_mod_eq_zero h_eq.1.symm)
  · specialize ih (j - 1) (Nat.lt_pred_iff.mpr hij)
    rcases j <;> simp_all +decide [Nat.fib_add_two, Nat.add_mod]
    simp_all +decide [← ZMod.natCast_eq_natCast_iff']
    exact ih (by linear_combination' h_eq.2 - h_eq.1)

/-- The Fibonacci entry point (rank of apparition) of `m`: the least positive index
`k` with `m ∣ fib k`. -/
noncomputable def entry (m : ℕ) (hm : 0 < m) : ℕ :=
  Nat.find (entry_exists m hm)

lemma entry_pos (m : ℕ) (hm : 0 < m) : 0 < entry m hm :=
  (Nat.find_spec (entry_exists m hm)).1

lemma entry_dvd_fib (m : ℕ) (hm : 0 < m) : m ∣ fib (entry m hm) :=
  (Nat.find_spec (entry_exists m hm)).2

-- !-- (←): `entry m ∣ n` ⇒ `fib (entry m) ∣ fib n` (`Nat.fib_dvd`) and `m ∣ fib (entry m)`.
-- (→): `m ∣ fib n` gives `m ∣ gcd (fib (entry m)) (fib n) = fib (gcd (entry m) n)`, so
-- `gcd (entry m) n` is an apparition index `≤ entry m`; `Nat.find` minimality forces
-- `gcd (entry m) n = entry m`, i.e. `entry m ∣ n`. -- !--
/-- **Apparition law.**  The entry point generates the whole set of apparition indices:
`m ∣ fib n ↔ entry m ∣ n`. -/
theorem fib_dvd_iff_entry_dvd (m : ℕ) (hm : 0 < m) (n : ℕ) :
    m ∣ fib n ↔ entry m hm ∣ n := by
  set k := entry m hm with hk
  constructor
  · intro hmn
    have h_div : m ∣ fib (Nat.gcd k n) := by
      rw [Nat.fib_gcd]; exact Nat.dvd_gcd (entry_dvd_fib m hm) hmn
    have h_gcd_le : Nat.gcd k n ≤ k :=
      Nat.le_of_dvd (entry_pos m hm) (Nat.gcd_dvd_left _ _)
    have h_gcd_eq : Nat.gcd k n = k :=
      le_antisymm h_gcd_le
        (Nat.find_min' (entry_exists m hm) ⟨Nat.gcd_pos_of_pos_left _ (entry_pos m hm), h_div⟩)
    exact h_gcd_eq ▸ Nat.gcd_dvd_right _ _
  · exact fun h => dvd_trans (entry_dvd_fib m hm) (Nat.fib_dvd _ _ h)

end FibLattice