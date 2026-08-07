/-
# The Fibonacci rank of apparition

This module was missing from the catalog although
`Shared/NumberTheory/CarmichaelCompositeEntryPoint.lean` imports it and uses its
API; the library therefore did not build.  It is reconstructed here, with full
proofs, as the general *rank of apparition* theory that the entry-point file
consumes.

## Main results

* `HasFibRank p` — some positive Fibonacci index is divisible by `p`.
* `hasFibRank_of_pos` — every positive `p` has a rank of apparition.  The proof
  is the pigeonhole/reversibility argument: the state pairs
  `(F k, F (k+1)) mod p` take finitely many values, the recursion is invertible,
  so the pair sequence is *purely* periodic and the initial state `(0, 1)`
  recurs; the recurrence index `d > 0` satisfies `p ∣ F d`.
* `fibRank p` — the least positive index of apparition,
  with `fibRank_pos`, `dvd_fib_fibRank` and the minimality lemma `fibRank_min`.
* `fibRank_dvd_iff` — the key divisibility criterion `p ∣ F n ↔ fibRank p ∣ n`,
  a consequence of the strong divisibility property `Nat.fib_gcd`.
-/
import Mathlib

namespace FibonacciApparitionSheaf

/-- `p` has a *rank of apparition*: some positive Fibonacci index is divisible by `p`. -/
def HasFibRank (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ Nat.fib k

/-- The state pair of the Fibonacci recursion, read modulo `p`. -/
private def fibPair (p k : ℕ) : ZMod p × ZMod p :=
  ((Nat.fib k : ZMod p), (Nat.fib (k + 1) : ZMod p))

/-- The Fibonacci recursion is invertible: equal successor states force equal states. -/
private theorem fibPair_step {p a b : ℕ} (h : fibPair p (a + 1) = fibPair p (b + 1)) :
    fibPair p a = fibPair p b := by
  have h1 : (Nat.fib (a + 1) : ZMod p) = (Nat.fib (b + 1) : ZMod p) := congrArg Prod.fst h
  have h2 : (Nat.fib (a + 2) : ZMod p) = (Nat.fib (b + 2) : ZMod p) := congrArg Prod.snd h
  have ha : (Nat.fib (a + 2) : ZMod p) = (Nat.fib a : ZMod p) + (Nat.fib (a + 1) : ZMod p) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hb : (Nat.fib (b + 2) : ZMod p) = (Nat.fib b : ZMod p) + (Nat.fib (b + 1) : ZMod p) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hfa : (Nat.fib a : ZMod p) = (Nat.fib b : ZMod p) := by
    rw [ha, hb, h1] at h2; exact add_right_cancel h2
  exact Prod.ext hfa h1

/-- Any recurrence of the state pair can be shifted back to the initial state. -/
private theorem fibPair_shift {p : ℕ} : ∀ i j : ℕ, i ≤ j → fibPair p i = fibPair p j →
    fibPair p 0 = fibPair p (j - i) := by
  intro i
  induction i with
  | zero => intro j _ h; simpa using h
  | succ i ih =>
    intro j hij h
    obtain ⟨j', rfl⟩ : ∃ j', j = j' + 1 := ⟨j - 1, by omega⟩
    have := ih j' (by omega) (fibPair_step h)
    simpa [Nat.succ_sub_succ] using this

private theorem dvd_of_fibPair_eq_zero {p d : ℕ} (h : fibPair p 0 = fibPair p d) :
    p ∣ Nat.fib d := by
  have h0 : ((Nat.fib d : ℕ) : ZMod p) = 0 := by
    have := congrArg Prod.fst h
    simpa [fibPair] using this.symm
  exact (ZMod.natCast_eq_zero_iff _ _).mp h0

/-- **Existence of the rank of apparition.**  Every positive `p` divides some positive
Fibonacci number. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fibPair p)
  rcases lt_or_gt_of_ne hij with h | h
  · exact ⟨j - i, by omega, dvd_of_fibPair_eq_zero (fibPair_shift i j h.le hfe)⟩
  · exact ⟨i - j, by omega, dvd_of_fibPair_eq_zero (fibPair_shift j i h.le hfe.symm)⟩

/-- The rank of apparition: the least positive index `k` with `p ∣ F k`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {k | 0 < k ∧ p ∣ Nat.fib k}

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem h

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **Divisibility criterion.**  `p` divides `F n` exactly when the rank of apparition
of `p` divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    · set r := fibRank p with hr
      have hg : p ∣ Nat.fib (Nat.gcd n r) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hpn (dvd_fib_fibRank h)
      have hgpos : 0 < Nat.gcd n r := Nat.gcd_pos_of_pos_left _ hn
      have hgle : Nat.gcd n r ≤ r := Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have hgr : Nat.gcd n r = r := by
        by_contra hne
        exact fibRank_min hgpos (lt_of_le_of_ne hgle hne) hg
      exact hgr ▸ Nat.gcd_dvd_left n r
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf