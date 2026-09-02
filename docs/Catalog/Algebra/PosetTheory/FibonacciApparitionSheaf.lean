import Mathlib

/-!
# The Fibonacci rank of apparition

This module supplies the rank-of-apparition theory that
`Shared.NumberTheory.CarmichaelCompositeEntryPoint` builds on: for a positive modulus `p`
the Fibonacci sequence is purely periodic modulo `p`, hence `p` divides `F n` for some
`n > 0`, and the least such `n` — the *rank of apparition* `fibRank p` — controls all the
Fibonacci indices at which `p` appears:

```
p ∣ F n  ↔  fibRank p ∣ n.
```

Existence is the classical pigeonhole argument on the pairs `(F n, F (n+1))` in `ZMod p`:
the shift `(a, b) ↦ (b, a + b)` is injective on the finite type `ZMod p × ZMod p`, so the
orbit of `(0, 1)` is purely periodic and returns to `(0, 1)`.  The divisibility criterion
then follows from `Nat.fib_gcd` together with minimality of the rank.
-/

namespace FibonacciApparitionSheaf

open Nat

/-- `p` has a Fibonacci rank of apparition if it divides some Fibonacci number of positive
index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- The Fibonacci rank of apparition: the least positive index `n` with `p ∣ F n`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

/-! ### Existence of the rank -/

/-- The Fibonacci shift on pairs, read modulo `p`. -/
private def shift (p : ℕ) : ZMod p × ZMod p → ZMod p × ZMod p := fun x => (x.2, x.1 + x.2)

private lemma shift_injective (p : ℕ) : Function.Injective (shift p) := by
  rintro ⟨a, b⟩ ⟨c, d⟩ h
  simp only [shift, Prod.mk.injEq] at h
  obtain ⟨h1, h2⟩ := h
  subst h1
  have hac : a = c := add_right_cancel h2
  simp [hac]

/-- The state of the Fibonacci recursion at time `n`, read in `ZMod p`. -/
private def fibPair (p n : ℕ) : ZMod p × ZMod p :=
  ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))

private lemma fibPair_succ (p n : ℕ) : fibPair p (n + 1) = shift p (fibPair p n) := by
  have h : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
  have h2 : ((Nat.fib (n + 1 + 1) : ℕ) : ZMod p)
      = ((Nat.fib n : ℕ) : ZMod p) + ((Nat.fib (n + 1) : ℕ) : ZMod p) := by
    rw [show n + 1 + 1 = n + 2 from rfl, h]
    push_cast
    ring
  simp only [fibPair, shift, h2]

private lemma fibPair_cancel (p : ℕ) : ∀ k a b : ℕ,
    fibPair p (a + k) = fibPair p (b + k) → fibPair p a = fibPair p b := by
  intro k
  induction k with
  | zero => intro a b h; simpa using h
  | succ k ih =>
      intro a b h
      refine ih a b ?_
      apply shift_injective p
      rw [← fibPair_succ, ← fibPair_succ]
      exact h

/-- Every positive modulus divides some Fibonacci number of positive index. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  obtain ⟨i, j, hij, hEq⟩ := Finite.exists_ne_map_eq_of_infinite (fibPair p)
  -- extract a positive period `d` from any repetition of the state
  have key : ∀ a d : ℕ, 0 < d → fibPair p a = fibPair p (a + d) → HasFibRank p := by
    intro a d hd0 hrep
    have hshift : fibPair p (0 + a) = fibPair p (d + a) := by
      rw [Nat.zero_add, Nat.add_comm d a]
      exact hrep
    have h0 : fibPair p 0 = fibPair p d := fibPair_cancel p a 0 d hshift
    have h1 : ((Nat.fib 0 : ℕ) : ZMod p) = ((Nat.fib d : ℕ) : ZMod p) := congrArg Prod.fst h0
    have hz : ((Nat.fib d : ℕ) : ZMod p) = 0 := by simpa using h1.symm
    exact ⟨d, hd0, (ZMod.natCast_eq_zero_iff _ _).mp hz⟩
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine key i (j - i) (by omega) ?_
    rw [show i + (j - i) = j by omega]
    exact hEq
  · refine key j (i - j) (by omega) ?_
    rw [show j + (i - j) = i by omega]
    exact hEq.symm

/-! ### Basic properties of the rank -/

private lemma fibRank_mem {p : ℕ} (h : HasFibRank p) :
    fibRank p ∈ {n | 0 < n ∧ p ∣ Nat.fib n} :=
  Nat.sInf_mem h

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- Minimality of the rank: `p` divides no Fibonacci number of smaller positive index. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **The apparition law.**  `p` divides `F n` exactly when its rank of apparition
divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    · have hg : p ∣ Nat.fib (Nat.gcd (fibRank p) n) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd (dvd_fib_fibRank h) hn
      have hgpos : 0 < Nat.gcd (fibRank p) n := Nat.gcd_pos_of_pos_right _ hpos
      have hle : fibRank p ≤ Nat.gcd (fibRank p) n := by
        by_contra hlt
        exact fibRank_min hgpos (not_le.mp hlt) hg
      have hge : Nat.gcd (fibRank p) n ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_left _ _)
      have hEq : Nat.gcd (fibRank p) n = fibRank p := le_antisymm hge hle
      exact hEq ▸ Nat.gcd_dvd_right (fibRank p) n
  · intro hd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hd)

end FibonacciApparitionSheaf