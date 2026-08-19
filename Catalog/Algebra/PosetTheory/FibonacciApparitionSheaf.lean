import Mathlib

/-!
# The Fibonacci rank of apparition

For a positive modulus `p` the set of indices `n` with `p ∣ F n` is nonempty (Pisano
periodicity) and, because `gcd (F m) (F n) = F (gcd m n)`, it is exactly the set of multiples
of its least positive element.  That least element is the *rank of apparition* `fibRank p`.

This module supplies the general theory used by the entry-point files of the catalog:

* `FibonacciApparitionSheaf.HasFibRank` — `p` divides some Fibonacci number of positive index;
* `FibonacciApparitionSheaf.hasFibRank_of_pos` — every positive modulus has a rank
  (pigeonhole on the pairs `(F n, F (n+1))` in `ZMod p`, run backwards along the recurrence);
* `FibonacciApparitionSheaf.fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` — the defining
  minimality package;
* `FibonacciApparitionSheaf.fibRank_dvd_iff` — the divisibility criterion
  `p ∣ F n ↔ fibRank p ∣ n`.
-/

namespace FibonacciApparitionSheaf

open Nat

/-- `HasFibRank p`: the modulus `p` divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- The state of the Fibonacci recurrence modulo `p`, as a pair of consecutive values. -/
private noncomputable def fibState (p : ℕ) : ℕ → ZMod p × ZMod p :=
  fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))

/-- The Fibonacci recurrence is invertible: equal states at `i+1` force equal states at `i`. -/
private lemma fibState_step {p i d : ℕ} (h : fibState p (i + 1) = fibState p (i + 1 + d)) :
    fibState p i = fibState p (i + d) := by
  have h1 : ((Nat.fib (i + 1) : ZMod p)) = (Nat.fib (i + 1 + d) : ZMod p) := congrArg Prod.fst h
  have h2 : ((Nat.fib (i + 2) : ZMod p)) = (Nat.fib (i + 1 + d + 1) : ZMod p) := congrArg Prod.snd h
  have e1 : Nat.fib (i + 2) = Nat.fib i + Nat.fib (i + 1) := Nat.fib_add_two
  have e2 : Nat.fib (i + d + 2) = Nat.fib (i + d) + Nat.fib (i + d + 1) := Nat.fib_add_two
  have hi : i + 1 + d + 1 = i + d + 2 := by ring
  have hj : i + 1 + d = i + d + 1 := by ring
  rw [hi] at h2
  rw [hj] at h1
  have hfst : ((Nat.fib i : ZMod p)) = (Nat.fib (i + d) : ZMod p) := by
    rw [e1, e2] at h2
    push_cast at h2 h1 ⊢
    linear_combination h2 - h1
  exact Prod.ext hfst h1

/-- Running the recurrence backwards: a repetition after `d` steps starting anywhere is a
repetition after `d` steps starting at `0`. -/
private lemma fibState_down {p : ℕ} :
    ∀ i d : ℕ, fibState p i = fibState p (i + d) → fibState p 0 = fibState p d := by
  intro i
  induction i with
  | zero => intro d h; simpa using h
  | succ n ih => intro d h; exact ih d (fibState_step h)

/-- **Every positive modulus has a rank of apparition.**  Pigeonhole on the finitely many
states `(F n, F (n+1))` in `ZMod p` produces a repetition, and the recurrence is invertible,
so the initial state `(0, 1)` recurs; the recurrence time is a positive index at which `p`
divides the Fibonacci number. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  have hnotinj : ¬ Function.Injective (fibState p) := not_injective_infinite_finite _
  obtain ⟨i, j, hFij, hij⟩ := Function.not_injective_iff.mp hnotinj
  rcases lt_or_gt_of_ne hij with h | h
  · refine ⟨j - i, by omega, ?_⟩
    have hd : j = i + (j - i) := by omega
    rw [hd] at hFij
    have h0 : (Nat.fib (j - i) : ZMod p) = 0 := by
      have := congrArg Prod.fst (fibState_down i (j - i) hFij)
      simpa [fibState] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp h0
  · refine ⟨i - j, by omega, ?_⟩
    have hd : i = j + (i - j) := by omega
    rw [hd] at hFij
    have h0 : (Nat.fib (i - j) : ZMod p) = 0 := by
      have := congrArg Prod.fst (fibState_down j (i - j) hFij.symm)
      simpa [fibState] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp h0

open Classical in
/-- The rank of apparition of `p`: the least positive index `n` with `p ∣ F n` (and `0` for
the degenerate moduli that divide no Fibonacci number of positive index). -/
noncomputable def fibRank (p : ℕ) : ℕ :=
  if h : HasFibRank p then Nat.find h else 0

private lemma fibRank_eq_find {p : ℕ} (h : HasFibRank p) : fibRank p = Nat.find h := by
  simp [fibRank, h]

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := by
  rw [fibRank_eq_find h]
  exact (Nat.find_spec h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := by
  rw [fibRank_eq_find h]
  exact (Nat.find_spec h).2

/-- Minimality of the rank of apparition: no positive index below it works. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  have h : HasFibRank p := ⟨k, hk, hdvd⟩
  rw [fibRank_eq_find h] at hlt
  exact Nat.find_min h hlt ⟨hk, hdvd⟩

/-- **The divisibility criterion.**  `p` divides `F n` exactly when the rank of apparition
divides `n`.  The forward direction uses `Nat.fib_gcd` together with minimality; the
backward direction is `Nat.fib_dvd`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    · have hgcd : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hpn (dvd_fib_fibRank h)
      have hpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hn
      have hle : Nat.gcd n (fibRank p) ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have heq : Nat.gcd n (fibRank p) = fibRank p := by
        rcases lt_or_eq_of_le hle with hlt | heq
        · exact absurd hgcd (fibRank_min hpos hlt)
        · exact heq
      exact heq ▸ Nat.gcd_dvd_left n (fibRank p)
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf