/-
# The rank of apparition of a modulus in the Fibonacci sequence

This module supplies the `fibRank` API that the Carmichael entry-point files
(`Combinatorics.CarmichaelCompositeEntryPoint`,
`Shared.NumberTheory.CarmichaelCompositeEntryPoint`) build on.

For a modulus `p > 0` the Fibonacci sequence contains a positive index `n` with
`p ∣ F n`: the pairs `(F n, F (n+1))` live in the finite set `ZMod p × ZMod p`,
so two of them coincide, and the recurrence is *invertible*
(`F m = F (m+2) − F (m+1)`), which lets the coincidence be pushed back to index
`0`.  The least such positive index is the *rank of apparition* `fibRank p`.

Main results.

* `FibonacciApparitionSheaf.hasFibRank_of_pos` — every positive modulus appears.
* `FibonacciApparitionSheaf.dvd_fib_fibRank`, `.fibRank_pos`, `.fibRank_min` —
  the defining properties of the rank.
* `FibonacciApparitionSheaf.fibRank_dvd_iff` — `p ∣ F n ↔ fibRank p ∣ n`, the
  strong-divisibility (`Nat.fib_gcd`) rigidity of the rank.
-/
import Mathlib

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: some positive Fibonacci number is divisible
by `p`. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- The rank of apparition of `p`: the least positive index `n` with
`p ∣ F n` (and `0` if no such index exists). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

section Existence

variable {p : ℕ}

/-- The Fibonacci state `(F n, F (n+1))` read modulo `p`. -/
private def state (p n : ℕ) : ZMod p × ZMod p := ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))

/-- The recurrence is invertible: equal successor states have equal states. -/
private theorem state_inj_step (p m n : ℕ) (h : state p (m + 1) = state p (n + 1)) :
    state p m = state p n := by
  have h1 : ((Nat.fib (m + 1) : ZMod p)) = (Nat.fib (n + 1) : ZMod p) :=
    congrArg Prod.fst h
  have h2 : ((Nat.fib (m + 2) : ZMod p)) = (Nat.fib (n + 2) : ZMod p) := by
    simpa using congrArg Prod.snd h
  have hm : ((Nat.fib (m + 2) : ZMod p)) = (Nat.fib m : ZMod p) + (Nat.fib (m + 1) : ZMod p) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hn : ((Nat.fib (n + 2) : ZMod p)) = (Nat.fib n : ZMod p) + (Nat.fib (n + 1) : ZMod p) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have h0 : ((Nat.fib m : ZMod p)) = (Nat.fib n : ZMod p) := by
    have := h2
    rw [hm, hn, h1] at this
    exact add_right_cancel this
  exact Prod.ext h0 h1

/-- Equal states after a common shift force equal states. -/
private theorem state_inj_shift (p : ℕ) :
    ∀ k m n : ℕ, state p (m + k) = state p (n + k) → state p m = state p n := by
  intro k
  induction k with
  | zero => intro m n h; simpa using h
  | succ k ih =>
      intro m n h
      exact ih m n (state_inj_step p (m + k) (n + k) h)

/-- **Existence of the rank of apparition.**  Every positive modulus divides
some positive Fibonacci number. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  haveI : Fintype (ZMod p) := ZMod.fintype p
  obtain ⟨a, b, hab, hfab⟩ := Finite.exists_ne_map_eq_of_infinite (state p)
  rcases Nat.lt_or_ge a b with hlt | hge
  · refine ⟨b - a, by omega, ?_⟩
    have hshift : state p (0 + a) = state p ((b - a) + a) := by
      simpa [Nat.sub_add_cancel hlt.le] using hfab
    have h0 := state_inj_shift p a 0 (b - a) hshift
    have : ((Nat.fib (b - a) : ZMod p)) = (Nat.fib 0 : ZMod p) := (congrArg Prod.fst h0).symm
    rw [Nat.fib_zero] at this
    exact (ZMod.natCast_eq_zero_iff _ _).mp (by simpa using this)
  · have hlt : b < a := by omega
    refine ⟨a - b, by omega, ?_⟩
    have hshift : state p (0 + b) = state p ((a - b) + b) := by
      simpa [Nat.sub_add_cancel hlt.le] using hfab.symm
    have h0 := state_inj_shift p b 0 (a - b) hshift
    have : ((Nat.fib (a - b) : ZMod p)) = (Nat.fib 0 : ZMod p) := (congrArg Prod.fst h0).symm
    rw [Nat.fib_zero] at this
    exact (ZMod.natCast_eq_zero_iff _ _).mp (by simpa using this)

end Existence

variable {p : ℕ}

/-- The rank of apparition is attained: `p` divides `F (fibRank p)`. -/
theorem dvd_fib_fibRank (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (Nat.sInf_mem h).2

/-- The rank of apparition is positive. -/
theorem fibRank_pos (h : HasFibRank p) : 0 < fibRank p :=
  (Nat.sInf_mem h).1

/-- **Minimality.**  No positive index below the rank works. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **Rigidity of the rank.**  `p` divides `F n` exactly when the rank divides
`n`; the forward direction is the strong divisibility `F (gcd m n) =
gcd (F m) (F n)`. -/
theorem fibRank_dvd_iff (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    · by_contra hnd
      have hgcd : p ∣ Nat.fib (Nat.gcd (fibRank p) n) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd (dvd_fib_fibRank h) hn
      have hgpos : 0 < Nat.gcd (fibRank p) n :=
        Nat.gcd_pos_of_pos_right _ hpos
      have hglt : Nat.gcd (fibRank p) n < fibRank p := by
        rcases lt_or_eq_of_le (Nat.gcd_le_left (m := fibRank p) n (fibRank_pos h)) with hlt | heq
        · exact hlt
        · exact absurd (heq ▸ Nat.gcd_dvd_right (fibRank p) n) hnd
      exact fibRank_min hgpos hglt hgcd
  · intro hn
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hn)

end FibonacciApparitionSheaf