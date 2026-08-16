import Mathlib

/-! # The rank of apparition of a Fibonacci divisor

For every positive integer `p` the Fibonacci sequence is eventually `0` modulo `p`; the least
positive index at which this happens is the *rank of apparition* (also: entry point) of `p`.

This file supplies that theory:

* `FibonacciApparitionSheaf.HasFibRank p` — some positive Fibonacci number is divisible by `p`;
* `FibonacciApparitionSheaf.hasFibRank_of_pos` — this always holds for `p > 0`, proved by the
  pigeonhole principle on the pairs `(F n, F (n+1))` modulo `p` together with the reversibility
  of the Fibonacci recursion;
* `FibonacciApparitionSheaf.fibRank p` — the rank itself, together with its positivity,
  divisibility and minimality properties;
* `FibonacciApparitionSheaf.fibRank_dvd_iff` — `p ∣ F n ↔ fibRank p ∣ n`, the divisibility
  law that makes the rank useful; it follows from `Nat.fib_gcd`.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- **Existence of the rank of apparition.**  Every positive integer divides some Fibonacci
number of positive index. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set g : ℕ → ZMod p × ZMod p :=
    fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p)) with hg
  -- the Fibonacci recursion is reversible, so equal states have equal predecessors
  have hback : ∀ a b : ℕ, g (a + 1) = g (b + 1) → g a = g b := by
    intro a b hab
    have h1 : ((Nat.fib (a + 1) : ℕ) : ZMod p) = ((Nat.fib (b + 1) : ℕ) : ZMod p) :=
      congrArg Prod.fst hab
    have h2 : ((Nat.fib (a + 2) : ℕ) : ZMod p) = ((Nat.fib (b + 2) : ℕ) : ZMod p) :=
      congrArg Prod.snd hab
    have hfa : ((Nat.fib (a + 2) : ℕ) : ZMod p)
        = ((Nat.fib a : ℕ) : ZMod p) + ((Nat.fib (a + 1) : ℕ) : ZMod p) := by
      rw [Nat.fib_add_two]
      push_cast
      ring
    have hfb : ((Nat.fib (b + 2) : ℕ) : ZMod p)
        = ((Nat.fib b : ℕ) : ZMod p) + ((Nat.fib (b + 1) : ℕ) : ZMod p) := by
      rw [Nat.fib_add_two]
      push_cast
      ring
    have hfib : ((Nat.fib a : ℕ) : ZMod p) = ((Nat.fib b : ℕ) : ZMod p) := by
      have := h2
      rw [hfa, hfb, h1] at this
      exact add_right_cancel this
    exact Prod.ext hfib h1
  have hshift : ∀ d a b : ℕ, g (a + d) = g (b + d) → g a = g b := by
    intro d
    induction d with
    | zero => intro a b h; simpa using h
    | succ d ih =>
        intro a b h
        refine ih a b (hback (a + d) (b + d) ?_)
        have ha : a + d + 1 = a + (d + 1) := by ring
        have hb : b + d + 1 = b + (d + 1) := by ring
        rw [ha, hb]
        exact h
  obtain ⟨i, j, hij, heq⟩ : ∃ i j : ℕ, i ≠ j ∧ g i = g j :=
    Finite.exists_ne_map_eq_of_infinite g
  -- from a repetition we walk back to the initial state
  have key : ∀ i j : ℕ, i < j → g i = g j → p ∣ Nat.fib (j - i) := by
    intro i j hlt heq
    have hrw : g (0 + i) = g ((j - i) + i) := by
      have h1 : 0 + i = i := by omega
      have h2 : (j - i) + i = j := by omega
      rw [h1, h2]
      exact heq
    have h0 := hshift i 0 (j - i) hrw
    have hzero : ((Nat.fib (j - i) : ℕ) : ZMod p) = ((Nat.fib 0 : ℕ) : ZMod p) :=
      (congrArg Prod.fst h0).symm
    rw [Nat.fib_zero] at hzero
    have : ((Nat.fib (j - i) : ℕ) : ZMod p) = 0 := by simpa using hzero
    exact (ZMod.natCast_eq_zero_iff _ _).1 this
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · exact ⟨j - i, by omega, key i j hlt heq⟩
  · exact ⟨i - j, by omega, key j i hlt heq.symm⟩

/-- The rank of apparition of `p`: the least positive index at which `p` divides a Fibonacci
number (and `0` if there is none). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

variable {p : ℕ}

private lemma fibRank_mem (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) := by
  have hne : {n | 0 < n ∧ p ∣ Nat.fib n}.Nonempty := by
    obtain ⟨n, hn0, hnd⟩ := h
    exact ⟨n, hn0, hnd⟩
  exact Nat.sInf_mem hne

/-- The rank of apparition is positive. -/
theorem fibRank_pos (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **The divisibility law for the rank of apparition.**  `p` divides `F n` exactly when its
rank of apparition divides `n`. -/
theorem fibRank_dvd_iff (h : HasFibRank p) (n : ℕ) : p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hdvd
    rcases Nat.eq_zero_or_pos n with hn | hn
    · simp [hn]
    · have hg : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hdvd (dvd_fib_fibRank h)
      have hgpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hn
      have hgle : Nat.gcd n (fibRank p) ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have hgeq : Nat.gcd n (fibRank p) = fibRank p := by
        rcases eq_or_lt_of_le hgle with heq | hlt
        · exact heq
        · exact absurd hg (fibRank_min hgpos hlt)
      exact hgeq ▸ Nat.gcd_dvd_left n (fibRank p)
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf