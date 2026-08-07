/-
  The Fibonacci rank of apparition.

  This module supplies the general rank-of-apparition theory used by
  `Shared/NumberTheory/CarmichaelCompositeEntryPoint.lean`:

  * `HasFibRank p` — `p` divides some Fibonacci number of positive index;
  * `hasFibRank_of_pos` — every positive `p` has a rank of apparition, proved by a
    pigeonhole argument on the pairs `(F n, F (n+1))` modulo `p` together with backwards
    propagation of the Fibonacci recurrence;
  * `fibRank p` — the least such index, with its positivity, divisibility and minimality
    properties;
  * `fibRank_dvd_iff` — `p ∣ F n ↔ fibRank p ∣ n`, from the strong divisibility property
    `F (gcd m n) = gcd (F m) (F n)`.
-/

import Mathlib

namespace FibonacciApparitionSheaf

/-- The pair of consecutive Fibonacci residues modulo `p`. -/
private def fibPair (p n : ℕ) : ZMod p × ZMod p :=
  ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))

/-- If the Fibonacci residue pair repeats after `d` steps, then `p ∣ F d`: the recurrence
can be run *backwards*, so the repetition propagates down to the index `0`. -/
private theorem dvd_fib_of_period {p : ℕ} [NeZero p] {i d : ℕ}
    (h : fibPair p i = fibPair p (i + d)) : p ∣ Nat.fib d := by
  have key : ∀ k, k ≤ i → fibPair p (i - k) = fibPair p (i - k + d) := by
    intro k
    induction k with
    | zero => intro _; simpa using h
    | succ k ih =>
      intro hk
      have hIH := ih (by omega)
      have hn : i - k = (i - (k + 1)) + 1 := by omega
      rw [hn] at hIH
      set n := i - (k + 1) with hn2
      have h1 : (Nat.fib (n + 1) : ZMod p) = (Nat.fib (n + 1 + d) : ZMod p) :=
        congrArg Prod.fst hIH
      have h2 : (Nat.fib (n + 1 + 1) : ZMod p) = (Nat.fib (n + 1 + d + 1) : ZMod p) :=
        congrArg Prod.snd hIH
      have e1 : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
      have e2 : Nat.fib (n + d + 2) = Nat.fib (n + d) + Nat.fib (n + d + 1) := Nat.fib_add_two
      have h1' : (Nat.fib (n + 1) : ZMod p) = (Nat.fib (n + d + 1) : ZMod p) := by
        have hx : n + 1 + d = n + d + 1 := by ring
        rwa [hx] at h1
      have h2' : (Nat.fib (n + 2) : ZMod p) = (Nat.fib (n + d + 2) : ZMod p) := by
        have hx : n + 1 + 1 = n + 2 := by ring
        have hy : n + 1 + d + 1 = n + d + 2 := by ring
        rwa [hx, hy] at h2
      rw [e1, e2] at h2'
      push_cast at h2'
      have h3 : (Nat.fib n : ZMod p) = (Nat.fib (n + d) : ZMod p) := by
        rw [h1'] at h2'
        linear_combination h2'
      show fibPair p n = fibPair p (n + d)
      refine Prod.ext h3 ?_
      simpa [Nat.add_right_comm] using h1'
  have h0 := key i le_rfl
  simp only [Nat.sub_self] at h0
  have hz : ((Nat.fib 0 : ℕ) : ZMod p) = ((Nat.fib (0 + d) : ℕ) : ZMod p) := congrArg Prod.fst h0
  simp at hz
  exact (ZMod.natCast_eq_zero_iff _ _).1 hz.symm

/-- **Existence of a rank of apparition.**  Every positive natural number divides some
Fibonacci number of positive index. -/
theorem exists_pos_dvd_fib (p : ℕ) (hp : 0 < p) : ∃ n, 0 < n ∧ p ∣ Nat.fib n := by
  haveI : NeZero p := ⟨hp.ne'⟩
  obtain ⟨i, j, hij, hFij⟩ := Finite.exists_ne_map_eq_of_infinite (fibPair p)
  rcases lt_or_gt_of_ne hij with h | h
  · refine ⟨j - i, by omega, dvd_fib_of_period (i := i) ?_⟩
    have hji : i + (j - i) = j := by omega
    rw [hji]
    exact hFij
  · refine ⟨i - j, by omega, dvd_fib_of_period (i := j) ?_⟩
    have hji : j + (i - j) = i := by omega
    rw [hji]
    exact hFij.symm

/-- `p` **has a rank of apparition**: it divides a Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- Every positive natural number has a rank of apparition. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p :=
  exists_pos_dvd_fib p hp

/-- The **rank of apparition** of `p`: the least positive index `n` with `p ∣ F n`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

private theorem fibRank_mem {p : ℕ} (h : HasFibRank p) :
    fibRank p ∈ {n | 0 < n ∧ p ∣ Nat.fib n} :=
  Nat.sInf_mem (by obtain ⟨n, hn, hd⟩ := h; exact ⟨n, hn, hd⟩)

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- **Minimality.**  No positive index below the rank of apparition works. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p)
    (hdvd : p ∣ Nat.fib k) : False :=
  absurd (Nat.sInf_le (show k ∈ {n | 0 < n ∧ p ∣ Nat.fib n} from ⟨hk, hdvd⟩)) (not_le.2 hlt)

/-- **Divisibility criterion.**  `p` divides `F n` exactly when its rank of apparition
divides `n`.  The forward direction uses the strong divisibility property of the Fibonacci
sequence, `F (gcd m n) = gcd (F m) (F n)`, together with minimality of the rank. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  set r : ℕ := fibRank p with hr
  have hrpos : 0 < r := fibRank_pos h
  have hrdvd : p ∣ Nat.fib r := dvd_fib_fibRank h
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with hn0 | hn0
    · simp [hn0]
    have hg : p ∣ Nat.fib (Nat.gcd r n) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd hrdvd hn
    have hgpos : 0 < Nat.gcd r n := Nat.gcd_pos_of_pos_left _ hrpos
    have hgle : Nat.gcd r n ≤ r := Nat.le_of_dvd hrpos (Nat.gcd_dvd_left r n)
    have hgeq : Nat.gcd r n = r := by
      by_contra hne
      exact fibRank_min hgpos (lt_of_le_of_ne hgle hne) hg
    exact hgeq ▸ Nat.gcd_dvd_right r n
  · intro hn
    exact dvd_trans hrdvd (Nat.fib_dvd _ _ hn)

end FibonacciApparitionSheaf