import Mathlib

/-!
# The Fibonacci rank of apparition

`Shared/NumberTheory/CarmichaelCompositeEntryPoint.lean` builds the theory of Fibonacci
entry points on top of a general "rank of apparition" interface, which this module
supplies.

For a modulus `m` the *rank of apparition* `fibRank m` is the least positive index `r`
with `m ∣ F r`.  The two facts that make the notion useful are:

* **existence** (`hasFibRank_of_pos`): every positive modulus divides some Fibonacci
  number of positive index.  We prove this by pigeonhole on the state pairs
  `n ↦ (F n, F (n+1))` in `ZMod m × ZMod m`: two states coincide, the Fibonacci
  recurrence is reversible, so the state at index `0` — namely `(0, 1)` — recurs at some
  positive index `d`, and then `m ∣ F d`.

* **the divisibility law** (`fibRank_dvd_iff`): `m ∣ F n ↔ fibRank m ∣ n`.  This is the
  strong divisibility property `Nat.fib_gcd` combined with minimality of the rank.

Together with `fibRank_min` these give the "sheaf of apparitions": the set of indices at
which `m` appears is exactly the set of multiples of a single number.
-/

namespace FibonacciApparitionSheaf

/-- A modulus `m` *has a rank of apparition* if it divides a Fibonacci number of positive
index. -/
def HasFibRank (m : ℕ) : Prop := ∃ n, 0 < n ∧ m ∣ Nat.fib n

/-- The rank of apparition of `m`: the least positive index `r` with `m ∣ F r`
(and `0` when no such index exists). -/
noncomputable def fibRank (m : ℕ) : ℕ := sInf {n | 0 < n ∧ m ∣ Nat.fib n}

section Existence

variable {m : ℕ}

/-- The Fibonacci state at index `n`, read modulo `m`. -/
private def st (m n : ℕ) : ZMod m × ZMod m := ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m))

/-- The Fibonacci recurrence is reversible: the state at `n+1` determines the state at
`n`. -/
private theorem st_of_st_succ {i j : ℕ} (h : st m (i + 1) = st m (j + 1)) :
    st m i = st m j := by
  have h1 : (Nat.fib (i + 1) : ZMod m) = (Nat.fib (j + 1) : ZMod m) := congrArg Prod.fst h
  have h2 : (Nat.fib (i + 2) : ZMod m) = (Nat.fib (j + 2) : ZMod m) := congrArg Prod.snd h
  have e1 : (Nat.fib (i + 2) : ZMod m) = (Nat.fib i : ZMod m) + (Nat.fib (i + 1) : ZMod m) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have e2 : (Nat.fib (j + 2) : ZMod m) = (Nat.fib j : ZMod m) + (Nat.fib (j + 1) : ZMod m) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have : (Nat.fib i : ZMod m) = (Nat.fib j : ZMod m) := by
    rw [e1, e2, h1] at h2
    exact add_right_cancel h2
  exact Prod.ext this h1

/-- Reversibility, iterated: a coincidence of states can be shifted all the way back. -/
private theorem st_of_st_add (k : ℕ) : ∀ {i j : ℕ}, st m (i + k) = st m (j + k) → st m i = st m j := by
  induction k with
  | zero => intro i j h; simpa using h
  | succ k ih =>
      intro i j h
      refine ih (i := i) (j := j) (st_of_st_succ (i := i + k) (j := j + k) ?_)
      have e1 : i + k + 1 = i + (k + 1) := by omega
      have e2 : j + k + 1 = j + (k + 1) := by omega
      rw [e1, e2]
      exact h

/-- **Existence of the rank of apparition.**  Every positive modulus divides a Fibonacci
number of positive index. -/
theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m := by
  haveI : NeZero m := ⟨hm.ne'⟩
  obtain ⟨i, j, hij, hst⟩ := Finite.exists_ne_map_eq_of_infinite (st m)
  -- swap so that `i < j`
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨j - i, by omega, ?_⟩
    have hshift : st m (0 + i) = st m ((j - i) + i) := by
      have : (j - i) + i = j := by omega
      simpa [this] using hst
    have h0 : st m 0 = st m (j - i) := st_of_st_add i hshift
    have : ((Nat.fib (j - i) : ℕ) : ZMod m) = 0 := by
      have := congrArg Prod.fst h0
      simpa [st] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp this
  · refine ⟨i - j, by omega, ?_⟩
    have hshift : st m (0 + j) = st m ((i - j) + j) := by
      have : (i - j) + j = i := by omega
      simpa [this] using hst.symm
    have h0 : st m 0 = st m (i - j) := st_of_st_add j hshift
    have : ((Nat.fib (i - j) : ℕ) : ZMod m) = 0 := by
      have := congrArg Prod.fst h0
      simpa [st] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp this

end Existence

variable {m : ℕ}

private theorem fibRank_mem (h : HasFibRank m) :
    fibRank m ∈ {n | 0 < n ∧ m ∣ Nat.fib n} :=
  Nat.sInf_mem h

/-- The rank of apparition is positive. -/
theorem fibRank_pos (h : HasFibRank m) : 0 < fibRank m := (fibRank_mem h).1

/-- `m` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank (h : HasFibRank m) : m ∣ Nat.fib (fibRank m) := (fibRank_mem h).2

/-- **Minimality of the rank.**  `m` divides no Fibonacci number of positive index below
its rank of apparition. -/
theorem fibRank_min {k : ℕ} (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **The divisibility law.**  `m` divides `F n` exactly when its rank of apparition
divides `n`. -/
theorem fibRank_dvd_iff (h : HasFibRank m) (n : ℕ) : m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  constructor
  · intro hn
    -- `m` divides `gcd (F n) (F r) = F (gcd n r)`, and `gcd n r ≤ r`, so minimality forces
    -- `gcd n r = r`.
    have hr := dvd_fib_fibRank h
    have hrpos := fibRank_pos h
    have hgcd : m ∣ Nat.fib (Nat.gcd n (fibRank m)) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd hn hr
    have hle : Nat.gcd n (fibRank m) ≤ fibRank m :=
      Nat.le_of_dvd hrpos (Nat.gcd_dvd_right _ _)
    have hpos : 0 < Nat.gcd n (fibRank m) := Nat.gcd_pos_of_pos_right _ hrpos
    have heq : Nat.gcd n (fibRank m) = fibRank m := by
      by_contra hne
      exact fibRank_min hpos (lt_of_le_of_ne hle hne) hgcd
    exact heq ▸ Nat.gcd_dvd_left n (fibRank m)
  · intro hn
    exact (dvd_fib_fibRank h).trans (Nat.fib_dvd _ _ hn)

end FibonacciApparitionSheaf