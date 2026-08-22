import Mathlib

/-!
# The Fibonacci rank of apparition

For a positive integer `p`, the *rank of apparition* (or Fibonacci entry point) of `p`
is the least positive index `n` with `p ∣ F n`.  This file develops the basic theory:

* `HasFibRank p` — `p` divides some positive-index Fibonacci number;
* `hasFibRank_of_pos` — **every** positive `p` has a rank of apparition.  The proof is
  the Pisano periodicity argument: the shift `(a, b) ↦ (b, a + b)` is a *permutation* of
  the finite set `ZMod p × ZMod p`, hence has finite order `k > 0`, and iterating it `k`
  times from `(F 0, F 1)` returns to `(0, 1)`, so `p ∣ F k`;
* `fibRank p` — the rank itself, defined as an infimum, with its minimality property;
* `fibRank_dvd_iff` — the divisibility law `p ∣ F n ↔ fibRank p ∣ n`, proved from
  `Nat.fib_gcd` (`F (gcd m n) = gcd (F m) (F n)`) together with minimality.

This is the "rank-of-apparition theory" consumed by
`Shared.NumberTheory.CarmichaelCompositeEntryPoint`.
-/

namespace FibonacciApparitionSheaf

open Nat

/-- `p` has a Fibonacci rank of apparition: it divides `F n` for some `n > 0`. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

section Pisano

variable (p : ℕ)

/-- The Fibonacci shift `(a, b) ↦ (b, a + b)` as a permutation of `ZMod p × ZMod p`.
Its inverse is `(c, d) ↦ (d - c, c)`, so it really is bijective. -/
def fibShift : Equiv.Perm (ZMod p × ZMod p) where
  toFun v := (v.2, v.1 + v.2)
  invFun v := (v.2 - v.1, v.1)
  left_inv := by rintro ⟨a, b⟩; simp
  right_inv := by rintro ⟨c, d⟩; simp

/-- The pair of consecutive Fibonacci numbers, read modulo `p`. -/
def fibPair (n : ℕ) : ZMod p × ZMod p := ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))

lemma fibShift_fibPair (n : ℕ) : fibShift p (fibPair p n) = fibPair p (n + 1) := by
  have h : ((Nat.fib (n + 1 + 1) : ℕ) : ZMod p)
      = (Nat.fib n : ZMod p) + (Nat.fib (n + 1) : ZMod p) := by
    rw [show n + 1 + 1 = n + 2 from rfl, Nat.fib_add_two]
    push_cast
    ring
  unfold fibShift fibPair
  simp only [Equiv.coe_fn_mk]
  rw [h]

lemma fibShift_pow_fibPair_zero (n : ℕ) : (fibShift p ^ n) (fibPair p 0) = fibPair p n := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hsplit : (fibShift p) ^ (n + 1) = fibShift p * (fibShift p) ^ n :=
        pow_succ' (fibShift p) n
      rw [hsplit, Equiv.Perm.mul_apply, ih, fibShift_fibPair]

end Pisano

/-- **Every positive integer has a rank of apparition.**  This is the existence half of
Pisano periodicity: the Fibonacci shift is a permutation of the finite set
`ZMod p × ZMod p`, so some positive power of it is the identity, and applying that power
to `(F 0, F 1) = (0, 1)` returns `(0, 1)`. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set k := orderOf (fibShift p) with hk
  have hkpos : 0 < k := orderOf_pos _
  have hid : (fibShift p) ^ k = 1 := pow_orderOf_eq_one _
  have hpair : fibPair p k = fibPair p 0 := by
    rw [← fibShift_pow_fibPair_zero p k, hid, Equiv.Perm.one_apply]
  have h0 : (Nat.fib k : ZMod p) = 0 := by
    have := congrArg Prod.fst hpair
    simpa [fibPair] using this
  exact ⟨k, hkpos, (ZMod.natCast_eq_zero_iff _ _).mp h0⟩

/-- The Fibonacci rank of apparition of `p`: the least positive index at which `p`
divides a Fibonacci number (and `0` if there is none). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

lemma fibRank_mem {p : ℕ} (h : HasFibRank p) :
    0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) := by
  obtain ⟨n, hn1, hn2⟩ := h
  have hne : Set.Nonempty {n | 0 < n ∧ p ∣ Nat.fib n} := ⟨n, hn1, hn2⟩
  exact Nat.sInf_mem hne

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- Minimality: `p` divides no Fibonacci number at a positive index below its rank. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k :=
  fun hd => Nat.notMem_of_lt_sInf hlt ⟨hk, hd⟩

/-- **The divisibility law for the rank of apparition**: `p` divides `F n` exactly when
its rank divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    set r := fibRank p with hr
    have hrpos : 0 < r := fibRank_pos h
    have hdvdr : p ∣ Nat.fib r := dvd_fib_fibRank h
    -- `p` divides `gcd (F r) (F n) = F (gcd r n)`
    have hgcd : p ∣ Nat.fib (Nat.gcd r n) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd hdvdr hn
    have hdpos : 0 < Nat.gcd r n := Nat.gcd_pos_of_pos_left n hrpos
    have hle : Nat.gcd r n ≤ r := Nat.le_of_dvd hrpos (Nat.gcd_dvd_left r n)
    have heq : Nat.gcd r n = r := by
      rcases lt_or_eq_of_le hle with hlt | heq
      · exact absurd hgcd (fibRank_min hdpos (hr ▸ hlt))
      · exact heq
    exact heq ▸ Nat.gcd_dvd_right r n
  · intro hn
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hn)

end FibonacciApparitionSheaf