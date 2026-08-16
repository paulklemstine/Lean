import Mathlib

/-! # The Fibonacci rank of apparition

For a positive modulus `p` the *rank of apparition* (or *Fibonacci entry point*)
`fibRank p` is the least positive index `n` with `p ∣ F n`.

This file supplies the theory used by
`Shared.NumberTheory.CarmichaelCompositeEntryPoint`:

* existence of a rank for every positive modulus (`hasFibRank_of_pos`), proved by
  pigeonhole on the pairs `(F n, F (n+1))` in `ZMod p` together with the
  reversibility of the Fibonacci recursion;
* minimality (`fibRank_min`) and the divisibility criterion
  `p ∣ F n ↔ fibRank p ∣ n` (`fibRank_dvd_iff`), proved from
  `Nat.fib_gcd`.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a Fibonacci rank of apparition if it divides some positive-index
Fibonacci number. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- Reversibility of the Fibonacci recursion modulo `p`: if the pair
`(F a, F (a+1))` repeats after `d` steps, then already the pair `(F 0, F 1)` does. -/
private theorem fib_back (p : ℕ) (d : ℕ) :
    ∀ a : ℕ, (Nat.fib a : ZMod p) = Nat.fib (a + d) →
      (Nat.fib (a + 1) : ZMod p) = Nat.fib (a + 1 + d) →
      (Nat.fib 0 : ZMod p) = Nat.fib d := by
  intro a
  induction a with
  | zero => intro h _; simpa using h
  | succ a ih =>
    intro h1 h2
    have hrec : (Nat.fib a : ZMod p) = Nat.fib (a + d) := by
      have e1 : (Nat.fib (a + 2) : ZMod p) = Nat.fib a + Nat.fib (a + 1) := by
        rw [Nat.fib_add_two]; push_cast; ring
      have e2 : (Nat.fib (a + d + 2) : ZMod p)
          = Nat.fib (a + d) + Nat.fib (a + d + 1) := by
        rw [Nat.fib_add_two]; push_cast; ring
      have h2' : (Nat.fib (a + 2) : ZMod p) = Nat.fib (a + d + 2) := by
        have : a + 1 + 1 + d = a + d + 2 := by ring
        simpa [this, show a + 1 + 1 = a + 2 from rfl] using h2
      have h1' : (Nat.fib (a + 1) : ZMod p) = Nat.fib (a + d + 1) := by
        have : a + 1 + d = a + d + 1 := by ring
        simpa [this] using h1
      have := h2'
      rw [e1, e2] at this
      have := add_right_cancel (a := (Nat.fib a : ZMod p)) (b := (Nat.fib (a+1) : ZMod p))
        (c := (Nat.fib (a + d) : ZMod p)) (by rw [h1'] at this ⊢; exact this)
      exact this
    exact ih hrec h1

/-- Every positive modulus has a rank of apparition. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  obtain ⟨i, j, hij, hfeq⟩ :=
    Finite.exists_ne_map_eq_of_infinite
      (fun n : ℕ => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p)))
  -- normalise so that `i < j`
  rcases lt_or_gt_of_ne hij with h | h
  · refine ⟨j - i, by omega, ?_⟩
    have hd : i + (j - i) = j := by omega
    have h1 : (Nat.fib i : ZMod p) = Nat.fib (i + (j - i)) := by
      rw [hd]; exact congrArg Prod.fst hfeq
    have h2 : (Nat.fib (i + 1) : ZMod p) = Nat.fib (i + 1 + (j - i)) := by
      have : i + 1 + (j - i) = j + 1 := by omega
      rw [this]; exact congrArg Prod.snd hfeq
    have := fib_back p (j - i) i h1 h2
    simp only [Nat.fib_zero, Nat.cast_zero] at this
    exact (ZMod.natCast_eq_zero_iff _ _).1 this.symm
  · refine ⟨i - j, by omega, ?_⟩
    have hd : j + (i - j) = i := by omega
    have h1 : (Nat.fib j : ZMod p) = Nat.fib (j + (i - j)) := by
      rw [hd]; exact (congrArg Prod.fst hfeq).symm
    have h2 : (Nat.fib (j + 1) : ZMod p) = Nat.fib (j + 1 + (i - j)) := by
      have : j + 1 + (i - j) = i + 1 := by omega
      rw [this]; exact (congrArg Prod.snd hfeq).symm
    have := fib_back p (i - j) j h1 h2
    simp only [Nat.fib_zero, Nat.cast_zero] at this
    exact (ZMod.natCast_eq_zero_iff _ _).1 this.symm

/-- The Fibonacci rank of apparition of `p`: the least positive `n` with `p ∣ F n`
(and `0` when no such `n` exists). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

private theorem fibRank_mem {p : ℕ} (h : HasFibRank p) :
    fibRank p ∈ {n | 0 < n ∧ p ∣ Nat.fib n} :=
  Nat.sInf_mem h

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **Divisibility criterion.**  `p` divides `F n` exactly when its rank of
apparition divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    · set r := fibRank p with hr
      have hrpos : 0 < r := fibRank_pos h
      have hgcd : p ∣ Nat.fib (Nat.gcd n r) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hn (dvd_fib_fibRank h)
      have hdpos : 0 < Nat.gcd n r := Nat.gcd_pos_of_pos_left _ hpos
      have hle : Nat.gcd n r ≤ r := Nat.le_of_dvd hrpos (Nat.gcd_dvd_right _ _)
      have heq : Nat.gcd n r = r := by
        by_contra hne
        exact fibRank_min hdpos (lt_of_le_of_ne hle hne) hgcd
      exact heq ▸ Nat.gcd_dvd_left n r
  · intro hn
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hn)

end FibonacciApparitionSheaf