import Mathlib

/-!
# Fibonacci rank of apparition

This file supplies the rank-of-apparition theory used by
`Shared.NumberTheory.CarmichaelCompositeEntryPoint`.

For `p > 0` the Fibonacci sequence is eventually zero modulo `p` at a positive
index: the pairs `(F n, F (n+1))` live in the finite set `ZMod p × ZMod p`, the
recurrence is reversible, so a repetition propagates backwards to the initial
pair `(0, 1)`.  The least positive index at which `p` divides a Fibonacci
number is the **rank of apparition** `fibRank p`, and `p ∣ F n` holds exactly
when `fibRank p ∣ n`.

Main results:
* `hasFibRank_of_pos`  : every positive `p` divides some positive-index Fibonacci number;
* `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` : `fibRank p` is the least such index;
* `fibRank_dvd_iff`    : `p ∣ F n ↔ fibRank p ∣ n`.
-/

namespace FibonacciApparitionSheaf

/-- `p` admits a Fibonacci rank of apparition: it divides some Fibonacci number
of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- Every positive integer divides a Fibonacci number of positive index.  The
proof is the classical pigeonhole argument on the pairs `(F n, F (n+1))` modulo
`p`, using reversibility of the Fibonacci recurrence. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set g : ℕ → ZMod p × ZMod p :=
    fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p)) with hg
  -- the recurrence is reversible, so equal states propagate backwards
  have hback : ∀ k i j, g (i + k) = g (j + k) → g i = g j := by
    intro k
    induction k with
    | zero => intro i j h; simpa using h
    | succ k ih =>
        intro i j h
        refine ih i j ?_
        have h' : g (i + k + 1) = g (j + k + 1) := by
          have e1 : i + (k + 1) = i + k + 1 := by omega
          have e2 : j + (k + 1) = j + k + 1 := by omega
          rw [e1, e2] at h; exact h
        have h1 : ((Nat.fib (i + k + 1) : ZMod p)) = (Nat.fib (j + k + 1) : ZMod p) :=
          congrArg Prod.fst h'
        have h2 : ((Nat.fib (i + k + 2) : ZMod p)) = (Nat.fib (j + k + 2) : ZMod p) := by
          have := congrArg Prod.snd h'
          simpa [hg, show i + k + 1 + 1 = i + k + 2 by omega,
            show j + k + 1 + 1 = j + k + 2 by omega] using this
        have hfi : ((Nat.fib (i + k + 2) : ZMod p))
            = (Nat.fib (i + k) : ZMod p) + (Nat.fib (i + k + 1) : ZMod p) := by
          rw [show i + k + 2 = (i + k) + 2 by omega, Nat.fib_add_two]; push_cast; ring
        have hfj : ((Nat.fib (j + k + 2) : ZMod p))
            = (Nat.fib (j + k) : ZMod p) + (Nat.fib (j + k + 1) : ZMod p) := by
          rw [show j + k + 2 = (j + k) + 2 by omega, Nat.fib_add_two]; push_cast; ring
        have hfirst : ((Nat.fib (i + k) : ZMod p)) = (Nat.fib (j + k) : ZMod p) := by
          rw [hfi, hfj, h1] at h2
          exact add_right_cancel h2
        exact Prod.ext hfirst h1
  obtain ⟨i, j, hij, hgij⟩ := Finite.exists_ne_map_eq_of_infinite g
  rcases lt_or_gt_of_ne hij with h | h
  · have key : g 0 = g (j - i) := by
      refine hback i 0 (j - i) ?_
      have e : (j - i) + i = j := by omega
      rw [e]
      simpa using hgij
    refine ⟨j - i, by omega, ?_⟩
    have h0 : ((Nat.fib (j - i) : ZMod p)) = 0 := by
      have := congrArg Prod.fst key
      simp [hg] at this
      exact this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).1 h0
  · have key : g 0 = g (i - j) := by
      refine hback j 0 (i - j) ?_
      have e : (i - j) + j = i := by omega
      rw [e]
      simpa using hgij.symm
    refine ⟨i - j, by omega, ?_⟩
    have h0 : ((Nat.fib (i - j) : ZMod p)) = 0 := by
      have := congrArg Prod.fst key
      simp [hg] at this
      exact this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).1 h0

/-- The **rank of apparition** of `p`: the least positive index at which `p`
divides a Fibonacci number (`0` if there is none). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) :
    0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) := by
  obtain ⟨n, hn, hd⟩ := h
  exact Nat.sInf_mem (s := {n | 0 < n ∧ p ∣ Nat.fib n}) ⟨n, hn, hd⟩

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hd⟩

theorem fibRank_le {p k : ℕ} (hk : 0 < k) (hd : p ∣ Nat.fib k) : fibRank p ≤ k :=
  Nat.sInf_le ⟨hk, hd⟩

/-- `p` divides `F n` exactly when the rank of apparition of `p` divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    · have hr : p ∣ Nat.fib (fibRank p) := dvd_fib_fibRank h
      have hgcd : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hn hr
      have hdpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hpos
      have hle : Nat.gcd n (fibRank p) ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have heq : Nat.gcd n (fibRank p) = fibRank p := by
        rcases lt_or_eq_of_le hle with hlt | heq
        · exact absurd hgcd (fibRank_min hdpos hlt)
        · exact heq
      exact heq ▸ Nat.gcd_dvd_left n (fibRank p)
  · intro hdvd
    exact (dvd_fib_fibRank h).trans (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf