import Mathlib

/-! # The rank of apparition of a Fibonacci divisor

For a positive integer `p`, the *rank of apparition* (or *Fibonacci entry point*)
of `p` is the least positive index `n` with `p ∣ F n`.  This file develops the
theory from scratch:

* `HasFibRank p` — `p` divides some positive-index Fibonacci number;
* `hasFibRank_of_pos` — **every** positive `p` has a rank of apparition.  The
  proof is the Pisano-period argument: the state map
  `(F n, F (n+1)) ↦ (F (n+1), F n + F (n+1))` is a *bijection* of the finite set
  `(ZMod p)²`, so the orbit of the initial state `(0, 1)` is purely periodic and
  returns to `(0, 1)`, i.e. `p ∣ F N` for some `N > 0`;
* `fibRank p` — the rank itself, together with its defining minimality property
  (`fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min`);
* `fibRank_dvd_iff` — the *sheaf-like* divisibility law `p ∣ F n ↔ fibRank p ∣ n`,
  proved from the strong divisibility property `gcd (F m) (F n) = F (gcd m n)`.

This is the general theory underlying `Shared.NumberTheory.CarmichaelCompositeEntryPoint`.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- **Existence of the rank of apparition.**  Every positive integer divides some
Fibonacci number of positive index. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  -- the Fibonacci state map, an equivalence of the finite type `(ZMod p)²`
  set T : ZMod p × ZMod p ≃ ZMod p × ZMod p :=
    { toFun := fun x => (x.2, x.1 + x.2)
      invFun := fun y => (y.2 - y.1, y.1)
      left_inv := by intro x; simp
      right_inv := by intro y; simp } with hT
  set F : ℕ → ZMod p × ZMod p :=
    fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p)) with hF
  have hstep : ∀ n, F n = (T^[n]) (F 0) := by
    intro n
    induction n with
    | zero => simp
    | succ k ih =>
        rw [Function.iterate_succ_apply', ← ih, hF, hT]
        simp [Nat.fib_add_two]
  -- two equal states force a return to the initial state
  have key : ∀ i j : ℕ, i < j → F i = F j → p ∣ Nat.fib (j - i) := by
    intro i j hlt heq
    have hA : F j = (T^[i]) (F (j - i)) := by
      conv_lhs => rw [show j = i + (j - i) by omega]
      rw [hstep (i + (j - i)), Function.iterate_add_apply, ← hstep (j - i)]
    have h1 : (T^[i]) (F 0) = (T^[i]) (F (j - i)) := by rw [← hstep i, heq, hA]
    have h2 : F 0 = F (j - i) := (Function.Injective.iterate T.injective i) h1
    have h3 : ((Nat.fib (j - i) : ZMod p)) = 0 := by
      have := congrArg Prod.fst h2
      simp [hF] at this
      simpa using this.symm
    exact (ZMod.natCast_eq_zero_iff _ p).mp h3
  obtain ⟨i, j, hij, hFij⟩ := Finite.exists_ne_map_eq_of_infinite F
  rcases lt_or_gt_of_ne hij with h | h
  · exact ⟨j - i, by omega, key i j h hFij⟩
  · exact ⟨i - j, by omega, key j i h hFij.symm⟩

/-- The rank of apparition of `p`: the least positive `n` with `p ∣ F n`
(and `0` when no such `n` exists). -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) :
    0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem (show {n | 0 < n ∧ p ∣ Nat.fib n}.Nonempty from h)

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- Minimality: below the rank of apparition, `p` divides no Fibonacci number of
positive index. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact absurd (Nat.sInf_le (show k ∈ {n | 0 < n ∧ p ∣ Nat.fib n} from ⟨hk, hdvd⟩))
    (not_le.mpr hlt)

/-- **The divisibility law for ranks of apparition.**  `p` divides `F n` exactly
when its rank of apparition divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    -- `p` divides `F (gcd (fibRank p) n)`, and that gcd is positive and at most the rank
    have hgcd : p ∣ Nat.fib (Nat.gcd (fibRank p) n) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd (dvd_fib_fibRank h) hpn
    have hgpos : 0 < Nat.gcd (fibRank p) n := Nat.gcd_pos_of_pos_right _ hn
    have hle : Nat.gcd (fibRank p) n ≤ fibRank p :=
      Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_left _ _)
    have heq : Nat.gcd (fibRank p) n = fibRank p := by
      by_contra hne
      exact fibRank_min hgpos (lt_of_le_of_ne hle hne) hgcd
    exact heq ▸ Nat.gcd_dvd_right (fibRank p) n
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf