import Mathlib

/-!
# Ranks of apparition for Fibonacci numbers

This module supplies the "rank of apparition" theory that the entry-point files
(`Shared/NumberTheory/CarmichaelCompositeEntryPoint.lean` and
`Bridges/CarmichaelCompositeEntryPoint.lean`) are stated in terms of.  It was
referenced by those files but absent from the repository, so it is reconstructed
and proved here from scratch.

## Main results

* `hasFibRank_of_pos` — every positive `p` divides some positive-index Fibonacci
  number.  The proof is the classical pigeonhole argument: the pair
  `(F n, F (n+1))` takes finitely many values in `ZMod p`, and the Fibonacci step
  map `(x, y) ↦ (y, x + y)` is injective, so the pair sequence is *purely*
  periodic and returns to `(F 0, F 1) = (0, 1)`.
* `fibRank` — the rank of apparition, the least positive index at which `p`
  appears, with `fibRank_pos`, `dvd_fib_fibRank` and the minimality property
  `fibRank_min`.
* `fibRank_dvd_iff` — `p ∣ F n ↔ fibRank p ∣ n`, deduced from
  `Nat.fib_gcd` together with minimality.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- The rank of apparition of `p`: the least positive index `n` with `p ∣ F n`
(and `0` if no such index exists). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

/-- **Every positive integer has a rank of apparition.**  The pair `(F n, F (n+1))`
mod `p` takes finitely many values and the Fibonacci step map is injective, so the
pair sequence is purely periodic; its period is an index where `p ∣ F n`. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set f : ℕ → ZMod p × ZMod p := fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))
    with hf
  set S : ZMod p × ZMod p → ZMod p × ZMod p := fun q => (q.2, q.1 + q.2) with hS
  have hstep : ∀ n, f (n + 1) = S (f n) := by
    intro n
    simp only [hf, hS, Nat.fib_add_two]
    push_cast
    simp
  have hiter : ∀ k n, f (n + k) = S^[k] (f n) := by
    intro k
    induction k with
    | zero => intro n; simp
    | succ k ih =>
        intro n
        have h : n + (k + 1) = (n + k) + 1 := by ring
        rw [h, hstep (n + k), ih n, Function.iterate_succ_apply']
  have hSinj : Function.Injective S := by
    intro a b hab
    simp only [hS, Prod.mk.injEq] at hab
    obtain ⟨h1, h2⟩ := hab
    have h3 : a.1 = b.1 := by
      rw [h1] at h2
      exact add_right_cancel h2
    exact Prod.ext h3 h1
  have key : ∀ i j : ℕ, i < j → f i = f j → HasFibRank p := by
    intro i j hij hfij
    refine ⟨j - i, by omega, ?_⟩
    have h1 : f (0 + i) = S^[i] (f 0) := hiter i 0
    have h2 : f ((j - i) + i) = S^[i] (f (j - i)) := hiter i (j - i)
    have hji : (j - i) + i = j := by omega
    rw [hji] at h2
    have h3 : S^[i] (f 0) = S^[i] (f (j - i)) := by
      rw [← h1, ← h2]
      simpa using hfij
    have hf0 := (Function.Injective.iterate hSinj i) h3
    have h4 : ((Nat.fib (j - i) : ℕ) : ZMod p) = 0 := by
      have h5 := congrArg Prod.fst hf0
      simp [hf] at h5
      exact h5.symm
    exact (ZMod.natCast_eq_zero_iff _ p).mp h4
  obtain ⟨i, j, hne, hfij⟩ := Finite.exists_ne_map_eq_of_infinite f
  rcases lt_or_gt_of_ne hne with h | h
  · exact key i j h hfij
  · exact key j i h hfij.symm

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p :=
  (Nat.sInf_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (Nat.sInf_mem h).2

/-- Minimality: `p` divides no Fibonacci number of smaller positive index. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **Divisibility criterion**: `p ∣ F n` exactly when the rank of apparition divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hdvd
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    · have hg : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hdvd (dvd_fib_fibRank h)
      have hgpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hn
      have hgle : Nat.gcd n (fibRank p) ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have hgeq : Nat.gcd n (fibRank p) = fibRank p := by
        rcases lt_or_eq_of_le hgle with hlt | heq
        · exact absurd hg (fibRank_min hgpos hlt)
        · exact heq
      exact hgeq ▸ Nat.gcd_dvd_left n (fibRank p)
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf