import Mathlib

/-!
# The Fibonacci rank of apparition

This module supplies the rank-of-apparition theory used by
`Shared.NumberTheory.CarmichaelCompositeEntryPoint`: for a modulus `p` the
*rank* `fibRank p` is the least positive index `n` with `p ∣ F n`.

Main results:

* `hasFibRank_of_pos` — every positive modulus divides some Fibonacci number of
  positive index.  The proof is the classical Pisano argument: the pair
  `(F n, F (n+1))` evolves in `ZMod p × ZMod p` under the invertible shift
  `(x, y) ↦ (y, x + y)`, and a finite state space forces a repetition, which by
  invertibility can be pushed back to the initial state `(0, 1)`.
* `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` — the defining properties of
  the rank.
* `fibRank_dvd_iff` — `p ∣ F n ↔ fibRank p ∣ n`, proved from
  `Nat.fib_gcd : gcd (F m) (F n) = F (gcd m n)` together with minimality.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a Fibonacci rank of apparition: it divides some Fibonacci number of
positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n : ℕ, 0 < n ∧ p ∣ Nat.fib n

/-- The Fibonacci shift on pairs of residues, an equivalence of `ZMod p × ZMod p`. -/
private def shift (p : ℕ) : (ZMod p × ZMod p) ≃ (ZMod p × ZMod p) where
  toFun z := (z.2, z.1 + z.2)
  invFun z := (z.2 - z.1, z.1)
  left_inv z := by simp
  right_inv z := by simp

/-- Iterating the shift from `(0, 1)` reproduces consecutive Fibonacci residues. -/
private theorem shift_iterate (p : ℕ) (n : ℕ) :
    (shift p)^[n] ((0 : ZMod p), (1 : ZMod p))
      = ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p)) := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply', ih]
      simp only [shift, Equiv.coe_fn_mk, Prod.mk.injEq]
      refine ⟨trivial, ?_⟩
      rw [Nat.fib_add_two]
      push_cast
      ring

/-- **Every positive modulus has a rank of apparition.** -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨by omega⟩
  obtain ⟨i, j, hij, heq⟩ :=
    Finite.exists_ne_map_eq_of_infinite
      (fun n : ℕ => (shift p)^[n] ((0 : ZMod p), (1 : ZMod p)))
  have key : ∀ i j : ℕ, i < j →
      (shift p)^[i] ((0 : ZMod p), (1 : ZMod p))
        = (shift p)^[j] ((0 : ZMod p), (1 : ZMod p)) → HasFibRank p := by
    intro i j hlt h
    obtain ⟨k, hk⟩ : ∃ k, j = i + k := ⟨j - i, by omega⟩
    subst hk
    have hk0 : 0 < k := by omega
    have h2 : (shift p)^[i] ((shift p)^[k] ((0 : ZMod p), (1 : ZMod p)))
        = (shift p)^[i] ((0 : ZMod p), (1 : ZMod p)) := by
      rw [← Function.iterate_add_apply]
      exact h.symm
    have h3 := ((shift p).injective.iterate i) h2
    rw [shift_iterate] at h3
    have h4 : ((Nat.fib k : ℕ) : ZMod p) = 0 := by
      have := congrArg Prod.fst h3
      simpa using this
    exact ⟨k, hk0, (ZMod.natCast_eq_zero_iff _ _).mp h4⟩
  rcases Nat.lt_or_ge i j with hlt | hge
  · exact key i j hlt heq
  · exact key j i (by omega) heq.symm

/-- The rank of apparition of `p`: the least positive index at which `p` divides
a Fibonacci number. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n : ℕ | 0 < n ∧ p ∣ Nat.fib n}

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) :
    0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) := by
  have hne : {n : ℕ | 0 < n ∧ p ∣ Nat.fib n}.Nonempty := by
    obtain ⟨n, hn⟩ := h
    exact ⟨n, hn⟩
  exact Nat.sInf_mem hne

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- Minimality of the rank. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  have : fibRank p ≤ k := Nat.sInf_le ⟨hk, hdvd⟩
  omega

/-- **The divisibility law of the rank of apparition:** `p ∣ F n` exactly when
the rank of `p` divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    · have hg : p ∣ Nat.fib (Nat.gcd (fibRank p) n) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd (dvd_fib_fibRank h) hpn
      have hgpos : 0 < Nat.gcd (fibRank p) n := Nat.gcd_pos_of_pos_right _ hn
      have hle : Nat.gcd (fibRank p) n ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_left _ _)
      have heq : Nat.gcd (fibRank p) n = fibRank p := by
        by_contra hne
        exact fibRank_min hgpos (lt_of_le_of_ne hle hne) hg
      rw [← heq]
      exact Nat.gcd_dvd_right _ _
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf