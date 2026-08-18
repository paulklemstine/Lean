import Mathlib

/-! # Rank of apparition of a Fibonacci sequence

This module supplies the rank-of-apparition ("Fibonacci entry point") theory that
`Shared.NumberTheory.CarmichaelCompositeEntryPoint` builds on:

* `HasFibRank p` — `p` divides some Fibonacci number of positive index;
* `hasFibRank_of_pos` — every positive `p` has this property (the Fibonacci pairs
  `(F n, F (n+1))` are eventually repeating modulo `p`, and the recursion is
  invertible, so the pair `(0, 1)` itself recurs);
* `fibRank p` — the least positive index of apparition;
* `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` — its defining properties;
* `fibRank_dvd_iff` — `p ∣ F n ↔ fibRank p ∣ n`, deduced from
  `Nat.fib_gcd : F (gcd m n) = gcd (F m) (F n)`.

Everything is proved; there are no `sorry`s and no new axioms.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ Nat.fib k

/-- **Existence of the rank of apparition.**  Every positive `p` divides some Fibonacci
number with positive index.  The pair map `n ↦ (F n, F (n+1))` into `ZMod p × ZMod p`
cannot be injective, and the two-term recursion can be run backwards, so a repetition
propagates down to the initial pair `(0, 1)`. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set g : ℕ → ZMod p × ZMod p := fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))
    with hg
  obtain ⟨i, j, hij, hgij⟩ := Finite.exists_ne_map_eq_of_infinite g
  have key : ∀ a b : ℕ, a ≤ b → g a = g b → g 0 = g (b - a) := by
    intro a
    induction a with
    | zero => intro b _ h; simpa using h
    | succ a ih =>
      intro b hb h
      obtain ⟨c, rfl⟩ : ∃ c, b = c + 1 := ⟨b - 1, by omega⟩
      have hac : a ≤ c := by omega
      have h1 : (Nat.fib (a + 1) : ZMod p) = (Nat.fib (c + 1) : ZMod p) := congrArg Prod.fst h
      have h2 : (Nat.fib (a + 2) : ZMod p) = (Nat.fib (c + 2) : ZMod p) := congrArg Prod.snd h
      have hfa : (Nat.fib (a + 2) : ZMod p)
          = (Nat.fib a : ZMod p) + (Nat.fib (a + 1) : ZMod p) := by
        rw [Nat.fib_add_two]; push_cast; ring
      have hfc : (Nat.fib (c + 2) : ZMod p)
          = (Nat.fib c : ZMod p) + (Nat.fib (c + 1) : ZMod p) := by
        rw [Nat.fib_add_two]; push_cast; ring
      have hga : g a = g c := by
        have hfib : (Nat.fib a : ZMod p) = (Nat.fib c : ZMod p) := by
          rw [hfa, hfc] at h2
          linear_combination h2 - h1
        exact Prod.ext hfib h1
      simpa using ih c hac hga
  have main : ∀ a b : ℕ, a < b → g a = g b → HasFibRank p := by
    intro a b hab h
    have h0 := key a b hab.le h
    refine ⟨b - a, by omega, ?_⟩
    have hz : ((Nat.fib (b - a) : ℕ) : ZMod p) = 0 := by
      have := congrArg Prod.fst h0
      simpa [hg] using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp hz
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · exact main i j hlt hgij
  · exact main j i hlt hgij.symm

/-- The rank of apparition of `p`: the least positive index `k` with `p ∣ F k`
(and `0` if there is none, which by `hasFibRank_of_pos` happens only for `p = 0`). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {k | 0 < k ∧ p ∣ Nat.fib k}

lemma fibRank_mem {p : ℕ} (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) := by
  obtain ⟨k, hk⟩ := h
  exact Nat.sInf_mem (s := {k | 0 < k ∧ p ∣ Nat.fib k}) ⟨k, hk⟩

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- Minimality: `p` divides no Fibonacci number of positive index below its rank. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf (s := {k | 0 < k ∧ p ∣ Nat.fib k}) hlt ⟨hk, hdvd⟩

/-- **Divisibility criterion.**  `p` divides `F n` exactly when its rank of apparition
divides `n`.  The forward direction uses `F (gcd m n) = gcd (F m) (F n)` together with the
minimality of the rank. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    have hr : 0 < fibRank p := fibRank_pos h
    have hgcd : p ∣ Nat.fib (Nat.gcd (fibRank p) n) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd (dvd_fib_fibRank h) hpn
    have hdpos : 0 < Nat.gcd (fibRank p) n := Nat.gcd_pos_of_pos_left n hr
    have hdle : Nat.gcd (fibRank p) n ≤ fibRank p := Nat.le_of_dvd hr (Nat.gcd_dvd_left _ _)
    have hdeq : Nat.gcd (fibRank p) n = fibRank p := by
      rcases lt_or_eq_of_le hdle with hlt | heq
      · exact absurd hgcd (fibRank_min hdpos hlt)
      · exact heq
    rw [← hdeq]
    exact Nat.gcd_dvd_right _ _
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf