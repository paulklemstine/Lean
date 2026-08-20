import Mathlib

/-!
# The rank of apparition of a natural number in the Fibonacci sequence

For a positive natural number `m` there is always a positive index `k` with `m ∣ F k`;
the least such index is the *rank of apparition* (or *entry point*) of `m`.

This module provides the general theory used by the Fibonacci entry-point files of the
catalog:

* `FibonacciApparitionSheaf.HasFibRank` — the predicate "`m` divides some positive-index
  Fibonacci number";
* `FibonacciApparitionSheaf.hasFibRank_of_pos` — every positive `m` has a rank, proved by a
  pigeonhole argument on the pairs `(F k, F (k+1))` in `ZMod m` together with the
  *backwards* determinacy of the Fibonacci recursion;
* `FibonacciApparitionSheaf.fibRank` — the rank itself, with its defining properties
  (`fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min`);
* `FibonacciApparitionSheaf.fibRank_dvd_iff` — the fundamental divisibility criterion
  `m ∣ F n ↔ fibRank m ∣ n`, deduced from `Nat.fib_gcd`.
-/

namespace FibonacciApparitionSheaf

open Nat

/-- `HasFibRank m` states that `m` divides some Fibonacci number of positive index. -/
def HasFibRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k

/-- The state of the Fibonacci recursion modulo `m` after `k` steps. -/
private def fibPair (m k : ℕ) : ZMod m × ZMod m :=
  ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m))

/-- The Fibonacci recursion is invertible: equal states one step later force equal states
now. -/
private theorem fibPair_step {m i j : ℕ} (h : fibPair m (i + 1) = fibPair m (j + 1)) :
    fibPair m i = fibPair m j := by
  have h1 : ((Nat.fib (i + 1) : ℕ) : ZMod m) = ((Nat.fib (j + 1) : ℕ) : ZMod m) :=
    congrArg Prod.fst h
  have h2 : ((Nat.fib (i + 2) : ℕ) : ZMod m) = ((Nat.fib (j + 2) : ℕ) : ZMod m) :=
    congrArg Prod.snd h
  have hi : ((Nat.fib (i + 2) : ℕ) : ZMod m)
      = (Nat.fib i : ZMod m) + (Nat.fib (i + 1) : ZMod m) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hj : ((Nat.fib (j + 2) : ℕ) : ZMod m)
      = (Nat.fib j : ZMod m) + (Nat.fib (j + 1) : ZMod m) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hfib : (Nat.fib i : ZMod m) = (Nat.fib j : ZMod m) := by
    have := h2
    rw [hi, hj, h1] at this
    exact add_right_cancel this
  exact Prod.ext hfib h1

/-- A repetition of the state after `d` further steps propagates back to the start. -/
private theorem fibPair_shift {m : ℕ} :
    ∀ i d : ℕ, fibPair m i = fibPair m (i + d) → fibPair m 0 = fibPair m d := by
  intro i
  induction i with
  | zero => intro d h; simpa using h
  | succ i ih =>
      intro d h
      refine ih d (fibPair_step ?_)
      have : i + 1 + d = i + d + 1 := by omega
      rwa [this] at h

/-- **Existence of the rank of apparition.**  Every positive natural number divides a
Fibonacci number of positive index. -/
theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m := by
  haveI : NeZero m := ⟨hm.ne'⟩
  obtain ⟨i, j, hij, hfij⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fun k : ℕ => fibPair m k)
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨j - i, by omega, ?_⟩
    have h : fibPair m i = fibPair m (i + (j - i)) := by
      have : i + (j - i) = j := by omega
      rw [this]; exact hfij
    have h0 := fibPair_shift i (j - i) h
    have := congrArg Prod.fst h0
    simp only [fibPair, Nat.fib_zero, Nat.cast_zero] at this
    exact (ZMod.natCast_eq_zero_iff _ _).1 this.symm
  · refine ⟨i - j, by omega, ?_⟩
    have h : fibPair m j = fibPair m (j + (i - j)) := by
      have : j + (i - j) = i := by omega
      rw [this]; exact hfij.symm
    have h0 := fibPair_shift j (i - j) h
    have := congrArg Prod.fst h0
    simp only [fibPair, Nat.fib_zero, Nat.cast_zero] at this
    exact (ZMod.natCast_eq_zero_iff _ _).1 this.symm

/-- The rank of apparition of `m`: the least positive index at which `m` divides a
Fibonacci number (and `0` when there is none, which never happens for `m > 0`). -/
noncomputable def fibRank (m : ℕ) : ℕ := sInf {k | 0 < k ∧ m ∣ Nat.fib k}

private theorem fibRank_mem {m : ℕ} (h : HasFibRank m) :
    fibRank m ∈ {k | 0 < k ∧ m ∣ Nat.fib k} :=
  Nat.sInf_mem h

/-- The rank of apparition is positive. -/
theorem fibRank_pos {m : ℕ} (h : HasFibRank m) : 0 < fibRank m := (fibRank_mem h).1

/-- `m` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {m : ℕ} (h : HasFibRank m) : m ∣ Nat.fib (fibRank m) :=
  (fibRank_mem h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {m k : ℕ} (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k := by
  intro hdvd
  exact absurd (Nat.sInf_le (show k ∈ {k | 0 < k ∧ m ∣ Nat.fib k} from ⟨hk, hdvd⟩))
    (not_le.2 hlt)

/-- **The divisibility criterion.**  `m` divides `F n` exactly when the rank of apparition
of `m` divides `n`. -/
theorem fibRank_dvd_iff {m : ℕ} (h : HasFibRank m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    · have hgcd : m ∣ Nat.fib (Nat.gcd n (fibRank m)) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hn (dvd_fib_fibRank h)
      have hle : Nat.gcd n (fibRank m) ≤ fibRank m :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have heq : Nat.gcd n (fibRank m) = fibRank m := by
        rcases lt_or_eq_of_le hle with hlt | heq
        · exact absurd hgcd (fibRank_min (Nat.gcd_pos_of_pos_left _ hpos) hlt)
        · exact heq
      exact heq ▸ Nat.gcd_dvd_left n (fibRank m)
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf