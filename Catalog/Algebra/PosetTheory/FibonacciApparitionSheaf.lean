/-
# The Fibonacci rank of apparition

NOTE (restored module).  `Shared/NumberTheory/CarmichaelCompositeEntryPoint.lean` is written
against this module, which was missing from the catalogue, so it did not compile.  This file
restores the rank-of-apparition interface it uses, with complete proofs.

For a modulus `p ≥ 1`, the *rank of apparition* `fibRank p` is the least positive index `n`
with `p ∣ F n`.  It exists for every positive modulus (`hasFibRank_of_pos`, proved by a
pigeonhole argument on the pairs `(F n, F (n+1))` in `ZMod p` together with backwards
invertibility of the Fibonacci recurrence), and it governs divisibility completely:
`p ∣ F n ↔ fibRank p ∣ n` (`fibRank_dvd_iff`).
-/
import Mathlib

namespace FibonacciApparitionSheaf

/-- `p` has a Fibonacci rank of apparition: it divides some Fibonacci number of positive
index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- **Existence of the rank of apparition.**  Every positive modulus divides some Fibonacci
number of positive index.  The pairs `(F n, F (n+1))` in `ZMod p` cannot all be distinct, and
the Fibonacci recurrence can be run backwards, so the initial pair `(0, 1)` recurs. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set g : ℕ → ZMod p × ZMod p := fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))
    with hg
  have hstep : ∀ n m : ℕ, g (n + 1) = g (m + 1) → g n = g m := by
    intro n m h
    have h1 : ((Nat.fib (n + 1) : ZMod p)) = (Nat.fib (m + 1) : ZMod p) := congrArg Prod.fst h
    have h2 : ((Nat.fib (n + 2) : ZMod p)) = (Nat.fib (m + 2) : ZMod p) := by
      simpa using congrArg Prod.snd h
    have h3 : ((Nat.fib n : ZMod p)) = (Nat.fib m : ZMod p) := by
      have e1 : ((Nat.fib (n + 2) : ZMod p))
          = (Nat.fib n : ZMod p) + (Nat.fib (n + 1) : ZMod p) := by
        rw [Nat.fib_add_two]; push_cast; ring
      have e2 : ((Nat.fib (m + 2) : ZMod p))
          = (Nat.fib m : ZMod p) + (Nat.fib (m + 1) : ZMod p) := by
        rw [Nat.fib_add_two]; push_cast; ring
      rw [e1, e2, h1] at h2
      exact add_right_cancel h2
    exact Prod.ext h3 h1
  have hdown : ∀ d i : ℕ, g i = g (i + d) → g 0 = g d := by
    intro d i
    induction i with
    | zero => exact fun h => by simpa using h
    | succ i ih =>
      intro h
      refine ih (hstep i (i + d) ?_)
      rw [show i + 1 + d = i + d + 1 by omega] at h
      exact h
  have key : ∀ d : ℕ, g 0 = g d → p ∣ Nat.fib d := by
    intro d hd
    have h0 : ((Nat.fib d : ZMod p)) = 0 := by
      have h1 := congrArg Prod.fst hd
      simp only [hg] at h1
      simpa using h1.symm
    exact (ZMod.natCast_eq_zero_iff _ p).mp h0
  obtain ⟨i, j, hij, hgij⟩ := Finite.exists_ne_map_eq_of_infinite g
  rcases lt_or_gt_of_ne hij with h | h
  · exact ⟨j - i, by omega,
      key _ (hdown (j - i) i (by rw [show i + (j - i) = j by omega]; exact hgij))⟩
  · exact ⟨i - j, by omega,
      key _ (hdown (i - j) j (by rw [show j + (i - j) = i by omega]; exact hgij.symm))⟩

/-- The **rank of apparition** of `p`: the least positive index `n` with `p ∣ F n`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) :
    0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem h

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- **Minimality**: `p` divides no Fibonacci number of positive index below its rank. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **The apparition law**: `p` divides `F n` exactly at the multiples of its rank. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    set r := fibRank p with hr
    have hrpos : 0 < r := fibRank_pos h
    set d := Nat.gcd r n with hd
    have hdpos : 0 < d := Nat.gcd_pos_of_pos_right r hn
    have hdvd : p ∣ Nat.fib d := by
      rw [hd, Nat.fib_gcd]
      exact Nat.dvd_gcd (dvd_fib_fibRank h) hpn
    have hdr : d ∣ r := Nat.gcd_dvd_left r n
    have hdle : d ≤ r := Nat.le_of_dvd hrpos hdr
    have hdeq : d = r := by
      by_contra hne
      exact fibRank_min hdpos (lt_of_le_of_ne hdle hne) hdvd
    exact hdeq ▸ Nat.gcd_dvd_right r n
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf