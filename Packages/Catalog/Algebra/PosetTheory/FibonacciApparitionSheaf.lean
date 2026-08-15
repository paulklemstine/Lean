/-
# The rank of apparition of a Fibonacci divisor

For every positive `m` there is a positive index `n` with `m ∣ F n`; the least
such index is the **rank of apparition** (the *entry point*) of `m`.  This file
develops that theory:

* `HasFibRank m` — `m` divides some Fibonacci number of positive index;
* `hasFibRank_of_pos` — every positive `m` has a rank of apparition.  The proof
  is a pigeonhole argument on the pair `(F k, F (k+1))` in `(ZMod m)²`, together
  with the observation that the Fibonacci recursion can be run *backwards*, so a
  repetition anywhere forces a repetition starting at `0`;
* `fibRank m` — the rank of apparition itself, with its defining properties
  `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min`;
* `fibRank_dvd_iff` — the sheaf-like statement that the set of indices at which
  `m` appears is exactly the set of multiples of `fibRank m`; it follows from
  `Nat.fib_gcd`, i.e. from the fact that `n ↦ F n` turns `gcd` into `gcd`.

This is the general theory behind the Fibonacci entry point used in
`Shared.NumberTheory.CarmichaelCompositeEntryPoint`.
-/
import Mathlib

namespace FibonacciApparitionSheaf

/-- `m` divides some Fibonacci number of positive index. -/
def HasFibRank (m : ℕ) : Prop := ∃ n, 0 < n ∧ m ∣ Nat.fib n

/-! ## 1. Existence of a rank of apparition -/

section Existence

variable {m : ℕ} [NeZero m]

/-- The state of the Fibonacci recursion mod `m`. -/
private def fibState (m k : ℕ) : ZMod m × ZMod m := ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m))

omit [NeZero m] in
/-- The Fibonacci recursion mod `m` can be run backwards: a repetition of the
state at index `i` forces a repetition of the state at index `0`. -/
private lemma fibState_zero_of_eq (d : ℕ) :
    ∀ i : ℕ, fibState m i = fibState m (i + d) → fibState m 0 = fibState m d := by
  intro i
  induction i with
  | zero => intro h; simpa using h
  | succ i ih =>
      intro h
      refine ih ?_
      have h1 : (Nat.fib (i + 1) : ZMod m) = (Nat.fib (i + 1 + d) : ZMod m) :=
        congrArg Prod.fst h
      have h2 : (Nat.fib (i + 2) : ZMod m) = (Nat.fib (i + 2 + d) : ZMod m) := by
        have := congrArg Prod.snd h
        simpa [fibState, show i + 1 + 1 = i + 2 from rfl,
          show i + 1 + d + 1 = i + 2 + d from by ring] using this
      have e1 : (Nat.fib (i + 2) : ZMod m) = (Nat.fib i : ZMod m) + (Nat.fib (i + 1) : ZMod m) := by
        push_cast [Nat.fib_add_two]; ring
      have e2 : (Nat.fib (i + 2 + d) : ZMod m)
          = (Nat.fib (i + d) : ZMod m) + (Nat.fib (i + 1 + d) : ZMod m) := by
        have : i + 2 + d = (i + d) + 2 := by ring
        rw [this]
        push_cast [Nat.fib_add_two]
        ring_nf
      have hfst : (Nat.fib i : ZMod m) = (Nat.fib (i + d) : ZMod m) := by
        have := h2
        rw [e1, e2, h1] at this
        linear_combination this
      simp only [fibState, Prod.mk.injEq, show i + d + 1 = i + 1 + d from by ring]
      exact ⟨hfst, h1⟩

/-- **Every positive `m` has a rank of apparition**: it divides some Fibonacci
number of positive index. -/
theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m := by
  haveI : NeZero m := ⟨hm.ne'⟩
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fibState m)
  -- put the two indices in order
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨j - i, by omega, ?_⟩
    have h : fibState m i = fibState m (i + (j - i)) := by
      rw [show i + (j - i) = j from by omega]; exact hfe
    have h0 := fibState_zero_of_eq (m := m) (j - i) i h
    have : (Nat.fib (j - i) : ZMod m) = 0 := by
      have := congrArg Prod.fst h0
      simpa [fibState] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).1 this
  · refine ⟨i - j, by omega, ?_⟩
    have h : fibState m j = fibState m (j + (i - j)) := by
      rw [show j + (i - j) = i from by omega]; exact hfe.symm
    have h0 := fibState_zero_of_eq (m := m) (i - j) j h
    have : (Nat.fib (i - j) : ZMod m) = 0 := by
      have := congrArg Prod.fst h0
      simpa [fibState] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).1 this

end Existence

/-! ## 2. The rank of apparition and its defining properties -/

/-- The rank of apparition of `m`: the least positive index at which `m` divides
a Fibonacci number (and `0` if there is none). -/
noncomputable def fibRank (m : ℕ) : ℕ := sInf {n | 0 < n ∧ m ∣ Nat.fib n}

variable {m k : ℕ}

/-- The rank of apparition is positive. -/
theorem fibRank_pos (h : HasFibRank m) : 0 < fibRank m :=
  (Nat.sInf_mem (s := {n | 0 < n ∧ m ∣ Nat.fib n}) h).1

/-- `m` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank (h : HasFibRank m) : m ∣ Nat.fib (fibRank m) :=
  (Nat.sInf_mem (s := {n | 0 < n ∧ m ∣ Nat.fib n}) h).2

/-- Minimality: `m` divides no Fibonacci number of smaller positive index. -/
theorem fibRank_min (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **The apparition set is the set of multiples of the rank.** -/
theorem fibRank_dvd_iff (h : HasFibRank m) (n : ℕ) : m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    -- `m` divides `F (gcd n (fibRank m))`, and the gcd is a positive index
    have hg : m ∣ Nat.fib (Nat.gcd n (fibRank m)) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd hn (dvd_fib_fibRank h)
    have hgpos : 0 < Nat.gcd n (fibRank m) := Nat.gcd_pos_of_pos_left _ hpos
    have hle : Nat.gcd n (fibRank m) ≤ fibRank m :=
      Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
    have heq : Nat.gcd n (fibRank m) = fibRank m := by
      rcases lt_or_eq_of_le hle with hlt | heq
      · exact absurd hg (fibRank_min hgpos hlt)
      · exact heq
    exact heq ▸ Nat.gcd_dvd_left n (fibRank m)
  · intro hn
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hn)

end FibonacciApparitionSheaf