import Mathlib

/-!
# The Fibonacci rank of apparition

For a modulus `p ≥ 1`, the *rank of apparition* (entry point) of `p` is the least positive
index `n` with `p ∣ F n`.  This file provides the general theory used by the Carmichael and
primitive-divisor developments:

* `exists_pos_dvd_fib` — every positive modulus divides some Fibonacci number of positive
  index.  The proof is the classical pigeonhole argument: the pair `(F n, F (n+1))` mod `p`
  takes finitely many values, and the Fibonacci recursion can be run backwards, so the
  initial pair `(0, 1)` recurs.
* `fibRank` — the rank of apparition, defined by `Nat.find` when it exists and `0`
  otherwise, so that it is a total function.
* `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` — its defining properties.
* `fibRank_dvd_iff` — the *strong divisibility* characterisation `p ∣ F n ↔ fibRank p ∣ n`,
  a consequence of `Nat.fib_gcd`.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition when it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- **Every positive modulus divides a Fibonacci number of positive index.**

The pairs `(F n, F (n+1))` in `ZMod p × ZMod p` cannot be pairwise distinct, and the
recursion `F (n+2) = F n + F (n+1)` determines `F n` from the later pair, so a repetition can
be pushed back to index `0`; there `F 0 = 0`. -/
theorem exists_pos_dvd_fib (p : ℕ) (hp : 0 < p) : ∃ k, 0 < k ∧ p ∣ Nat.fib k := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set T : ℕ → ZMod p × ZMod p :=
    fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p)) with hT
  -- running the recursion backwards
  have hstep : ∀ i j : ℕ, T (i + 1) = T (j + 1) → T i = T j := by
    intro i j h
    have h1 : (Nat.fib (i + 1) : ZMod p) = (Nat.fib (j + 1) : ZMod p) := congrArg Prod.fst h
    have h2 : (Nat.fib (i + 2) : ZMod p) = (Nat.fib (j + 2) : ZMod p) := congrArg Prod.snd h
    have e1 : Nat.fib (i + 2) = Nat.fib i + Nat.fib (i + 1) := Nat.fib_add_two
    have e2 : Nat.fib (j + 2) = Nat.fib j + Nat.fib (j + 1) := Nat.fib_add_two
    rw [e1, e2] at h2
    push_cast at h2
    have hfib : (Nat.fib i : ZMod p) = (Nat.fib j : ZMod p) := by
      rw [h1] at h2
      exact add_right_cancel h2
    exact Prod.ext hfib h1
  have hshift : ∀ i d : ℕ, T i = T (i + d) → T 0 = T d := by
    intro i
    induction i with
    | zero => intro d h; simpa using h
    | succ i ih =>
        intro d h
        refine ih d (hstep i (i + d) ?_)
        simpa [Nat.succ_add, Nat.add_right_comm] using h
  obtain ⟨i, j, hij, hEq⟩ := Finite.exists_ne_map_eq_of_infinite T
  rcases Nat.lt_or_ge i j with hlt | hge
  · have hd : T i = T (i + (j - i)) := by
      rw [show i + (j - i) = j by omega]; exact hEq
    have h0 := hshift i (j - i) hd
    refine ⟨j - i, by omega, ?_⟩
    have hzero : (Nat.fib (j - i) : ZMod p) = 0 := by
      have hfst := congrArg Prod.fst h0
      simp [hT] at hfst
      simpa using hfst.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp hzero
  · have hji : j < i := by
      rcases Nat.lt_or_ge j i with h | h
      · exact h
      · exact absurd (le_antisymm hge h) hij.symm
    have hd : T j = T (j + (i - j)) := by
      rw [show j + (i - j) = i by omega]; exact hEq.symm
    have h0 := hshift j (i - j) hd
    refine ⟨i - j, by omega, ?_⟩
    have hzero : (Nat.fib (i - j) : ZMod p) = 0 := by
      have hfst := congrArg Prod.fst h0
      simp [hT] at hfst
      simpa using hfst.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp hzero

/-- Every positive modulus has a rank of apparition. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := exists_pos_dvd_fib p hp

open Classical in
/-- The rank of apparition of `p`: the least positive `n` with `p ∣ F n`, and `0` when no such
index exists (which happens only for `p = 0`). -/
noncomputable def fibRank (p : ℕ) : ℕ :=
  if h : HasFibRank p then Nat.find h else 0

theorem fibRank_eq_find {p : ℕ} (h : HasFibRank p) :
    fibRank p = Nat.find h := by
  rw [fibRank, dif_pos h]

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := by
  rw [fibRank_eq_find h]
  exact (Nat.find_spec h).1

/-- The modulus divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := by
  rw [fibRank_eq_find h]
  exact (Nat.find_spec h).2

/-- Minimality: no positive index below the rank of apparition works. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  have h : HasFibRank p := ⟨k, hk, hdvd⟩
  rw [fibRank_eq_find h] at hlt
  exact Nat.find_min h hlt ⟨hk, hdvd⟩

/-- **Strong divisibility.**  A modulus divides `F n` exactly when its rank of apparition
divides `n`.  The forward direction uses `Nat.fib_gcd` together with minimality. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hdvd
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    · have hgcd : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hdvd (dvd_fib_fibRank h)
      have hle : Nat.gcd n (fibRank p) ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have hgpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hn
      have heq : Nat.gcd n (fibRank p) = fibRank p := by
        rcases lt_or_eq_of_le hle with hlt | heq
        · exact absurd hgcd (fibRank_min hgpos hlt)
        · exact heq
      exact heq ▸ Nat.gcd_dvd_left _ _
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf