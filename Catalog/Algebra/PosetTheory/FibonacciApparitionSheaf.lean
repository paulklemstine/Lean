import Mathlib

/-!
# The Fibonacci rank of apparition

This module supplies the rank-of-apparition theory used by
`Shared/NumberTheory/CarmichaelCompositeEntryPoint.lean`.

For a positive integer `p` the *rank of apparition* (or Fibonacci entry point) is the
least positive index `n` with `p ∣ F n`.  The three facts that make the notion useful are

* `FibonacciApparitionSheaf.hasFibRank_of_pos` — the rank exists for every `p > 0`
  (proved by a pigeonhole argument on the pairs `(F n, F (n+1))` in `ZMod p`, using that
  the Fibonacci recursion is reversible, so the sequence is *purely* periodic);
* `FibonacciApparitionSheaf.fibRank_min` — minimality;
* `FibonacciApparitionSheaf.fibRank_dvd_iff` — `p ∣ F n ↔ fibRank p ∣ n`, which follows
  from the strong divisibility identity `gcd (F m) (F n) = F (gcd m n)`.
-/

namespace FibonacciApparitionSheaf

/-- `p` *has a Fibonacci rank of apparition* if it divides some Fibonacci number of
positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- The rank of apparition: the least positive index at which `p` divides a Fibonacci
number (junk value `0` when no such index exists). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

section Existence

variable {p : ℕ}

/-- The state map of the Fibonacci recursion modulo `p`. -/
private def fibState (p n : ℕ) : ZMod p × ZMod p :=
  ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))

/-- The Fibonacci recursion is reversible: equal successor states force equal states. -/
private theorem fibState_step_inj (a b : ℕ) (h : fibState p (a + 1) = fibState p (b + 1)) :
    fibState p a = fibState p b := by
  have h1 : ((Nat.fib (a + 1) : ZMod p)) = (Nat.fib (b + 1) : ZMod p) :=
    congrArg Prod.fst h
  have h2 : ((Nat.fib (a + 2) : ZMod p)) = (Nat.fib (b + 2) : ZMod p) :=
    congrArg Prod.snd h
  have ha : ((Nat.fib (a + 2) : ZMod p)) = (Nat.fib a : ZMod p) + (Nat.fib (a + 1) : ZMod p) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hb : ((Nat.fib (b + 2) : ZMod p)) = (Nat.fib b : ZMod p) + (Nat.fib (b + 1) : ZMod p) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have h0 : ((Nat.fib a : ZMod p)) = (Nat.fib b : ZMod p) := by
    have := h2
    rw [ha, hb, h1] at this
    exact add_right_cancel this
  exact Prod.ext h0 h1

/-- Purely periodic: a repetition after `d` steps starting at `a` already occurs at `0`. -/
private theorem fibState_shift (d : ℕ) :
    ∀ a : ℕ, fibState p a = fibState p (a + d) → fibState p 0 = fibState p d := by
  intro a
  induction a with
  | zero => intro h; simpa using h
  | succ n ih =>
      intro h
      have h' : fibState p (n + 1) = fibState p ((n + d) + 1) := by
        have : n + 1 + d = n + d + 1 := by omega
        rwa [this] at h
      exact ih (fibState_step_inj _ _ h')

/-- **Existence of the rank of apparition.**  Every positive integer divides some
Fibonacci number of positive index. -/
theorem exists_pos_dvd_fib (hp : 0 < p) : ∃ n, 0 < n ∧ p ∣ Nat.fib n := by
  haveI : NeZero p := ⟨hp.ne'⟩
  obtain ⟨i, j, hij, hfe⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fibState p)
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨j - i, by omega, ?_⟩
    have hd : j = i + (j - i) := by omega
    have h0 : fibState p 0 = fibState p (j - i) :=
      fibState_shift (j - i) i (by rw [← hd]; exact hfe)
    have : ((Nat.fib (j - i) : ZMod p)) = 0 := by
      have := congrArg Prod.fst h0
      simp [fibState] at this
      exact this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp this
  · refine ⟨i - j, by omega, ?_⟩
    have hd : i = j + (i - j) := by omega
    have h0 : fibState p 0 = fibState p (i - j) :=
      fibState_shift (i - j) j (by rw [← hd]; exact hfe.symm)
    have : ((Nat.fib (i - j) : ZMod p)) = 0 := by
      have := congrArg Prod.fst h0
      simp [fibState] at this
      exact this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp this

/-- Every positive integer has a rank of apparition. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := exists_pos_dvd_fib hp

end Existence

variable {p : ℕ}

/-- The rank of apparition is attained. -/
theorem fibRank_mem (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem h

/-- The rank of apparition is positive. -/
theorem fibRank_pos (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- **Minimality.**  `p` divides no Fibonacci number of smaller positive index. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  have hmem : k ∈ {n | 0 < n ∧ p ∣ Nat.fib n} := ⟨hk, hdvd⟩
  exact absurd (Nat.sInf_le hmem) (not_le.mpr hlt)

/-- **The divisibility criterion.**  `p ∣ F n` exactly when the rank of apparition
divides `n`.  (`n = 0` is included: `F 0 = 0`.) -/
theorem fibRank_dvd_iff (h : HasFibRank p) (n : ℕ) : p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hnpos
    · exact dvd_zero _
    · set r := fibRank p with hr
      have hrpos : 0 < r := fibRank_pos h
      have hg : p ∣ Nat.fib (Nat.gcd r n) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd (dvd_fib_fibRank h) hn
      have hgpos : 0 < Nat.gcd r n := Nat.gcd_pos_of_pos_left n hrpos
      have hgle : Nat.gcd r n ≤ r := Nat.le_of_dvd hrpos (Nat.gcd_dvd_left r n)
      have hgeq : Nat.gcd r n = r := by
        rcases lt_or_eq_of_le hgle with hlt | heq
        · exact absurd hg (fibRank_min hgpos (hr ▸ hlt))
        · exact heq
      exact hgeq ▸ Nat.gcd_dvd_right r n
  · intro hn
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hn)

end FibonacciApparitionSheaf