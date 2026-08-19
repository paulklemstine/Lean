import Mathlib

/-!
# The rank of apparition of a Fibonacci sequence

For a positive integer `p`, the *rank of apparition* (or Fibonacci entry point) of `p` is the
least positive index `n` with `p ∣ F n`.  This file develops the theory used by the
Carmichael entry-point files:

* `FibonacciApparitionSheaf.HasFibRank` : `p` divides some positive-index Fibonacci number;
* `FibonacciApparitionSheaf.hasFibRank_of_pos` : **every** positive `p` has this property.
  The proof is the Pisano argument: the state map `n ↦ (F n, F (n+1))` into `ZMod p × ZMod p`
  takes finitely many values, and the one-step transition `(a, b) ↦ (b, a + b)` is injective,
  so the state sequence is *purely* periodic and therefore returns to `(0, 1)`;
* `FibonacciApparitionSheaf.fibRank` : the rank itself, together with its defining
  minimality property `fibRank_min` and the divisibility `dvd_fib_fibRank`;
* `FibonacciApparitionSheaf.fibRank_dvd_iff` : the structural theorem
  `p ∣ F n ↔ fibRank p ∣ n`, obtained from `Nat.fib_gcd`.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: it divides `F n` for some `n > 0`. -/
def HasFibRank (p : ℕ) : Prop := ∃ n : ℕ, 0 < n ∧ p ∣ Nat.fib n

/-- The rank of apparition of `p`: the least positive `n` with `p ∣ F n`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n : ℕ | 0 < n ∧ p ∣ Nat.fib n}

/-! ## Existence of the rank -/

/-- The one-step transition of the Fibonacci state `(F n, F (n+1))`. -/
private def fibStep (p : ℕ) : ZMod p × ZMod p → ZMod p × ZMod p := fun q => (q.2, q.1 + q.2)

private theorem fibStep_injective (p : ℕ) : Function.Injective (fibStep p) := by
  rintro ⟨a, b⟩ ⟨a', b'⟩ h
  have h1 : b = b' := congrArg Prod.fst h
  have h2 : a + b = a' + b' := congrArg Prod.snd h
  have : a = a' := by
    have := h2
    rw [h1] at this
    exact add_right_cancel this
  simp [this, h1]

/-- The Fibonacci state sequence is the orbit of `(0, 1)` under `fibStep`. -/
private theorem fibState_iterate (p n : ℕ) :
    ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))
      = (fibStep p)^[n] ((Nat.fib 0 : ZMod p), (Nat.fib 1 : ZMod p)) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', ← ih]
      have : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
      simp [fibStep, this]

/-- **Every positive integer has a rank of apparition.**  This is the Pisano periodicity
argument: the state map has finite range and the transition is injective, so the state
sequence is purely periodic and returns to its initial value `(F 0, F 1) = (0, 1)`. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set g : ℕ → ZMod p × ZMod p :=
    fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p)) with hgdef
  obtain ⟨i, j, hij, hgij⟩ := Finite.exists_ne_map_eq_of_infinite g
  -- reduce to the case `i < j`
  wlog hlt : i < j generalizing i j
  · exact this j i (Ne.symm hij) hgij.symm (by omega)
  obtain ⟨d, hd, hjd⟩ : ∃ d, 0 < d ∧ j = i + d := ⟨j - i, by omega, by omega⟩
  have hiter : ∀ n, g n = (fibStep p)^[n] (g 0) := by
    intro n
    have := fibState_iterate p n
    simpa [hgdef] using this
  have hkey : (fibStep p)^[i] (g 0) = (fibStep p)^[i] ((fibStep p)^[d] (g 0)) := by
    rw [← Function.iterate_add_apply]
    have h1 : (fibStep p)^[i] (g 0) = g i := (hiter i).symm
    have h2 : (fibStep p)^[i + d] (g 0) = g j := by rw [hjd, ← hiter]
    rw [h1, h2]
    exact hgij
  have hfix : g 0 = g d := by
    have := (Function.Injective.iterate (fibStep_injective p) i) hkey
    rw [this, ← hiter]
  have hzero : (Nat.fib d : ZMod p) = 0 := by
    have := congrArg Prod.fst hfix
    simpa [hgdef] using this.symm
  exact ⟨d, hd, (ZMod.natCast_eq_zero_iff _ _).1 hzero⟩

/-! ## Basic properties of the rank -/

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem h

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- **Minimality of the rank**: `p` divides no earlier positive-index Fibonacci number. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  have : fibRank p ≤ k := Nat.sInf_le ⟨hk, hdvd⟩
  omega

/-! ## The divisibility criterion -/

/-- **The structure theorem for the rank of apparition.**  `p` divides `F n` exactly when the
rank of apparition of `p` divides `n`.  The forward direction uses `Nat.fib_gcd`: a common
divisor of `F n` and `F r` divides `F (gcd n r)`, and minimality of `r` then forces
`gcd n r = r`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    · have hr := dvd_fib_fibRank h
      have hgcd : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hn hr
      have hdpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hpos
      have hdle : Nat.gcd n (fibRank p) ≤ fibRank p :=
        Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right _ _)
      have hdeq : Nat.gcd n (fibRank p) = fibRank p := by
        by_contra hne
        exact fibRank_min hdpos (lt_of_le_of_ne hdle hne) hgcd
      exact hdeq ▸ Nat.gcd_dvd_left n (fibRank p)
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf