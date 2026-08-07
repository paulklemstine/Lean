import Mathlib

/-! # The rank of apparition of a Fibonacci divisor

For a positive integer `p`, the *rank of apparition* (or entry point) `fibRank p` is the
least positive index `k` with `p ∣ F k`.  This file develops the theory that the entry-point
files of the catalogue build on:

* `hasFibRank_of_pos` — **every** positive integer divides some positive-index Fibonacci
  number, so the rank exists.  The proof is the standard pigeonhole argument run through the
  bijection `(a, b) ↦ (b, a + b)` of `ZMod p × ZMod p`, whose iterates from `(0, 1)` are the
  consecutive Fibonacci pairs.
* `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min` — the defining properties.
* `fibRank_dvd_iff` — the key structural theorem: `p ∣ F n ↔ fibRank p ∣ n`; the set of
  indices at which `p` appears is exactly the set of multiples of the rank.  Both directions
  come from `Nat.fib_gcd`, i.e. from the fact that Fibonacci divisibility is a "sheaf" over
  the divisibility poset of ℕ.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ Nat.fib k

/-- The rank of apparition (entry point) of `p`: the least positive `k` with `p ∣ F k`
(and `0` if there is none). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {k | 0 < k ∧ p ∣ Nat.fib k}

/-! ## Existence of the rank -/

/-- The Fibonacci shift on pairs, `(a, b) ↦ (b, a + b)`. -/
private def fibStep (p : ℕ) : ZMod p × ZMod p → ZMod p × ZMod p := fun x => (x.2, x.1 + x.2)

private theorem fibStep_injective (p : ℕ) : Function.Injective (fibStep p) := by
  rintro ⟨a, b⟩ ⟨c, d⟩ h
  simp only [fibStep, Prod.mk.injEq] at h
  obtain ⟨h1, h2⟩ := h
  subst h1
  refine Prod.ext ?_ rfl
  simpa using add_right_cancel h2

private theorem fibStep_iterate (p n : ℕ) :
    (fibStep p)^[n] ((0 : ZMod p), (1 : ZMod p))
      = ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p)) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih]
    simp only [fibStep, Nat.fib_add_two]
    refine Prod.ext rfl ?_
    push_cast
    ring

/-- **Every positive integer has a rank of apparition.**  This is the Fibonacci
pigeonhole theorem: the pair sequence `(F n, F (n+1))` is eventually periodic modulo `p`,
and the shift is invertible, so the period returns to `(0, 1)`. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  have hfin : Finite (ZMod p × ZMod p) := inferInstance
  obtain ⟨i, j, hij, hEq⟩ :
      ∃ i j : ℕ, i ≠ j ∧ (fibStep p)^[i] ((0 : ZMod p), 1) = (fibStep p)^[j] ((0 : ZMod p), 1) :=
    Finite.exists_ne_map_eq_of_infinite fun n => (fibStep p)^[n] ((0 : ZMod p), 1)
  -- reduce to the case `i < j`
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨j - i, by omega, ?_⟩
    have hsplit : (fibStep p)^[j] ((0 : ZMod p), 1)
        = (fibStep p)^[i] ((fibStep p)^[j - i] ((0 : ZMod p), 1)) := by
      rw [← Function.iterate_add_apply]
      congr 1
      omega
    have hinj : Function.Injective (fibStep p)^[i] :=
      Function.Injective.iterate (fibStep_injective p) i
    have : ((0 : ZMod p), (1 : ZMod p)) = (fibStep p)^[j - i] ((0 : ZMod p), 1) := by
      apply hinj
      rw [← hsplit, ← hEq]
    rw [fibStep_iterate] at this
    have h0 : ((Nat.fib (j - i) : ZMod p)) = 0 := by
      have := congrArg Prod.fst this
      simpa using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp h0
  · refine ⟨i - j, by omega, ?_⟩
    have hsplit : (fibStep p)^[i] ((0 : ZMod p), 1)
        = (fibStep p)^[j] ((fibStep p)^[i - j] ((0 : ZMod p), 1)) := by
      rw [← Function.iterate_add_apply]
      congr 1
      omega
    have hinj : Function.Injective (fibStep p)^[j] :=
      Function.Injective.iterate (fibStep_injective p) j
    have : ((0 : ZMod p), (1 : ZMod p)) = (fibStep p)^[i - j] ((0 : ZMod p), 1) := by
      apply hinj
      rw [← hsplit, hEq]
    rw [fibStep_iterate] at this
    have h0 : ((Nat.fib (i - j) : ZMod p)) = 0 := by
      have := congrArg Prod.fst this
      simpa using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp h0

/-! ## Basic properties of the rank -/

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p :=
  (Nat.sInf_mem h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (Nat.sInf_mem h).2

/-- Minimality of the rank: below it, `p` divides no Fibonacci number of positive index. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact absurd (Nat.sInf_le (show k ∈ {k | 0 < k ∧ p ∣ Nat.fib k} from ⟨hk, hdvd⟩))
    (not_le.mpr hlt)

theorem fibRank_le {p k : ℕ} (hk : 0 < k) (hdvd : p ∣ Nat.fib k) : fibRank p ≤ k :=
  Nat.sInf_le ⟨hk, hdvd⟩

/-! ## The structure theorem -/

/-- **The indices of apparition are exactly the multiples of the rank.** -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    have hg : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd hn (dvd_fib_fibRank h)
    have hgpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hpos
    have hle : Nat.gcd n (fibRank p) ≤ fibRank p :=
      Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
    have heq : Nat.gcd n (fibRank p) = fibRank p := by
      by_contra hne
      exact fibRank_min hgpos (lt_of_le_of_ne hle hne) hg
    exact heq ▸ Nat.gcd_dvd_left n (fibRank p)
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

/-- The rank of apparition of a prime divides every index at which the prime appears. -/
theorem fibRank_dvd_of_dvd_fib {p n : ℕ} (h : HasFibRank p) (hn : p ∣ Nat.fib n) :
    fibRank p ∣ n :=
  (fibRank_dvd_iff h n).mp hn

end FibonacciApparitionSheaf