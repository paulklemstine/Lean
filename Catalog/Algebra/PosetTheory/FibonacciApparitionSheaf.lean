/-
# The Fibonacci rank of apparition

This module supplies the "rank of apparition" theory that
`Shared.NumberTheory.CarmichaelCompositeEntryPoint` builds on (the module it imports was
missing from the catalog, so the file could not be elaborated).

For a positive integer `p`, the *rank of apparition* `fibRank p` is the least `n > 0` with
`p ∣ F n`.  We prove:

* `hasFibRank_of_pos` : every positive integer divides some Fibonacci number `F n` with `n > 0`.
  The proof is the classical pigeonhole argument: the pair sequence `n ↦ (F n, F (n+1))` in
  `ZMod p × ZMod p` takes finitely many values, hence repeats, and the recursion is invertible
  backwards, so the repetition can be pushed back to the index `0`;
* `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` : `fibRank p` is the least positive index of
  apparition;
* `fibRank_dvd_iff` : `p ∣ F n ↔ fibRank p ∣ n`, from the strong divisibility property
  `F (gcd m n) = gcd (F m) (F n)`.
-/

import Mathlib

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- The Fibonacci rank of apparition of `p`: the least positive `n` with `p ∣ F n`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

/-- **Existence of the rank of apparition.**  Every positive integer divides a Fibonacci number
of positive index. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set F : ℕ → ZMod p × ZMod p := fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))
    with hF
  -- the Fibonacci recursion can be run backwards
  have hback : ∀ i j : ℕ, F (i + 1) = F (j + 1) → F i = F j := by
    intro i j h
    have h1 : (Nat.fib (i + 1) : ZMod p) = (Nat.fib (j + 1) : ZMod p) := congrArg Prod.fst h
    have h2 : (Nat.fib (i + 2) : ZMod p) = (Nat.fib (j + 2) : ZMod p) := congrArg Prod.snd h
    have e : ∀ n : ℕ, (Nat.fib n : ZMod p)
        = (Nat.fib (n + 2) : ZMod p) - (Nat.fib (n + 1) : ZMod p) := by
      intro n
      have hrec : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
      rw [hrec]
      push_cast
      ring
    apply Prod.ext
    · simp only [hF]
      rw [e i, e j, h1, h2]
    · simpa [hF] using h1
  -- a repetition can be pushed back to the index `0`
  have hshift : ∀ d i : ℕ, F i = F (i + d) → F 0 = F d := by
    intro d i
    induction i with
    | zero => intro h; simpa using h
    | succ n ih =>
        intro h
        refine ih (hback n (n + d) ?_)
        have hcomm : n + d + 1 = n + 1 + d := by omega
        rw [hcomm]
        exact h
  have key : ∀ i j : ℕ, i < j → F i = F j → HasFibRank p := by
    intro i j hij hFij
    refine ⟨j - i, by omega, ?_⟩
    have hji : j = i + (j - i) := by omega
    have h0 : F 0 = F (j - i) := hshift (j - i) i (by rw [← hji]; exact hFij)
    have hz : ((Nat.fib (j - i) : ℕ) : ZMod p) = 0 := by
      have hfst := congrArg Prod.fst h0
      simpa [hF] using hfst.symm
    exact (ZMod.natCast_eq_zero_iff _ p).mp hz
  obtain ⟨i, j, hij, hFij⟩ := Finite.exists_ne_map_eq_of_infinite F
  rcases lt_or_gt_of_ne hij with h | h
  · exact key i j h hFij
  · exact key j i h hFij.symm

section

variable {p : ℕ}

theorem fibRank_mem (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) := by
  obtain ⟨n, hn, hdvd⟩ := h
  exact Nat.sInf_mem (s := {n | 0 < n ∧ p ∣ Nat.fib n}) ⟨n, hn, hdvd⟩

/-- The rank of apparition is positive. -/
theorem fibRank_pos (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  have : fibRank p ≤ k := Nat.sInf_le (s := {n | 0 < n ∧ p ∣ Nat.fib n}) ⟨hk, hdvd⟩
  omega

/-- **The rank of apparition divides every index of apparition.**  This is the divisibility
form of the strong divisibility property of the Fibonacci sequence. -/
theorem fibRank_dvd_iff (h : HasFibRank p) (n : ℕ) : p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    have hgcd : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd hn (dvd_fib_fibRank h)
    rcases Nat.eq_zero_or_pos (Nat.gcd n (fibRank p)) with hz | hpos
    · have hrank : fibRank p = 0 := Nat.eq_zero_of_gcd_eq_zero_right hz
      exact absurd hrank (fibRank_pos h).ne'
    · have hle : Nat.gcd n (fibRank p) ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have heq : Nat.gcd n (fibRank p) = fibRank p := by
        by_contra hne
        exact fibRank_min hpos (lt_of_le_of_ne hle hne) hgcd
      exact heq ▸ Nat.gcd_dvd_left n (fibRank p)
  · intro hn
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hn)

end

end FibonacciApparitionSheaf