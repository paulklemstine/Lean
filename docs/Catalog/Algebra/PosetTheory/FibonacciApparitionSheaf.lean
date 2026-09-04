import Mathlib

/-!
# The Fibonacci rank of apparition

Two catalog files (`Shared.NumberTheory.CarmichaelCompositeEntryPoint` and
`MachineLearning.Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers`)
build on the rank-of-apparition theory through the module path
`Shared.PosetTheory.FibonacciApparitionSheaf`, which was missing from the
repository, so those two modules could not be compiled at all.  This file supplies
the theory they use, from scratch:

* `HasFibRank p` — `p` divides some Fibonacci number of positive index;
* `hasFibRank_of_pos` — this holds for **every** positive modulus, proved by
  pigeonhole on the pairs `(F k, F (k+1))` in `ZMod p` together with the
  reversibility of the Fibonacci recursion;
* `fibRank p` — the least such index (the rank of apparition);
* `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` — its defining properties;
* `fibRank_dvd_iff` — the divisibility criterion `p ∣ F n ↔ fibRank p ∣ n`,
  proved from `Nat.fib_gcd`.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: it divides a Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ Nat.fib k

/-- **Every positive modulus has a rank of apparition.**  The pair
`(F k, F (k+1))` takes finitely many values in `ZMod p`, so it repeats; the
Fibonacci recursion is reversible, so the repetition can be pushed back to index
`0`, where `F 0 = 0`. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set f : ℕ → ZMod p × ZMod p :=
    fun k => ((Nat.fib k : ZMod p), (Nat.fib (k + 1) : ZMod p)) with hf
  have step : ∀ i j : ℕ, f (i + 1) = f (j + 1) → f i = f j := by
    intro i j h
    have h1 : ((Nat.fib (i + 1) : ZMod p)) = (Nat.fib (j + 1) : ZMod p) :=
      congrArg Prod.fst h
    have h2 : ((Nat.fib (i + 2) : ZMod p)) = (Nat.fib (j + 2) : ZMod p) :=
      congrArg Prod.snd h
    have e : ∀ m : ℕ,
        ((Nat.fib m : ZMod p)) = (Nat.fib (m + 2) : ZMod p) - (Nat.fib (m + 1) : ZMod p) := by
      intro m
      rw [Nat.fib_add_two]
      push_cast
      ring
    have : ((Nat.fib i : ZMod p)) = (Nat.fib j : ZMod p) := by
      rw [e i, e j, h1, h2]
    simp only [hf, Prod.mk.injEq]
    exact ⟨this, h1⟩
  have key : ∀ i j : ℕ, i ≤ j → f i = f j → f 0 = f (j - i) := by
    intro i
    induction i with
    | zero => intro j _ h; simpa using h
    | succ i ih =>
        intro j hij h
        obtain ⟨j', rfl⟩ : ∃ j', j = j' + 1 := ⟨j - 1, by omega⟩
        have hstep := step i j' h
        have h2 := ih j' (by omega) hstep
        simpa [Nat.succ_sub_succ] using h2
  obtain ⟨a, b, hab, hfab⟩ := Finite.exists_ne_map_eq_of_infinite f
  rcases lt_or_gt_of_ne hab with hlt | hlt
  · refine ⟨b - a, by omega, ?_⟩
    have h0 := key a b hlt.le hfab
    have : ((Nat.fib (b - a) : ZMod p)) = 0 := by
      have := congrArg Prod.fst h0
      simp only [hf] at this
      simpa using this.symm
    exact (ZMod.natCast_eq_zero_iff _ p).mp this
  · refine ⟨a - b, by omega, ?_⟩
    have h0 := key b a hlt.le hfab.symm
    have : ((Nat.fib (a - b) : ZMod p)) = 0 := by
      have := congrArg Prod.fst h0
      simp only [hf] at this
      simpa using this.symm
    exact (ZMod.natCast_eq_zero_iff _ p).mp this

/-- The rank of apparition of `p`: the least positive index `k` with `p ∣ F k`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {k | 0 < k ∧ p ∣ Nat.fib k}

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) := by
  obtain ⟨k, hk⟩ := h
  exact Nat.sInf_mem (⟨k, hk⟩ : {k | 0 < k ∧ p ∣ Nat.fib k}.Nonempty)

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **The divisibility criterion**: `p` divides `F n` exactly when its rank of
apparition divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  constructor
  · intro hdvd
    have hgcd : p ∣ Nat.gcd (Nat.fib n) (Nat.fib (fibRank p)) :=
      Nat.dvd_gcd hdvd (dvd_fib_fibRank h)
    have hfib : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
      rw [Nat.fib_gcd]; exact hgcd
    have hpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hn
    have hle : Nat.gcd n (fibRank p) ≤ fibRank p :=
      Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
    have heq : Nat.gcd n (fibRank p) = fibRank p := by
      rcases lt_or_eq_of_le hle with hlt | heq
      · exact absurd hfib (fibRank_min hpos hlt)
      · exact heq
    exact heq ▸ Nat.gcd_dvd_left _ _
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf