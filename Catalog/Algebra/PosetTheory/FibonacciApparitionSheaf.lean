import Mathlib

/-!
# The rank of apparition of a modulus in the Fibonacci sequence

For a positive modulus `p` the set of indices `n` with `p ∣ F n` is a *subgroup pattern* of
`ℕ`: it is exactly the set of multiples of a single index, the **rank of apparition**
`fibRank p`.  This file develops that structure, which is the local datum ("stalk") attached
to `p` in the divisibility poset of Fibonacci indices.

* `HasFibRank p` — some positive index has `p ∣ F n`;
* `hasFibRank_of_pos` — every positive `p` has a rank of apparition.  The proof is a
  pigeonhole on the pairs `(F n, F (n+1))` in `ZMod p × ZMod p`, run *backwards* to the pair
  `(F 0, F 1) = (0, 1)`: the Fibonacci recursion is invertible, so a repetition anywhere
  forces a repetition at the origin;
* `dvd_fib_fibRank`, `fibRank_pos`, `fibRank_min` — the defining minimality properties;
* `fibRank_dvd_iff` — **the structure theorem**: `p ∣ F m ↔ fibRank p ∣ m`.  The proof uses
  the strong divisibility `Nat.fib_gcd` to close the apparition set under `gcd`.

Downstream, `Physics.Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers` uses this
to characterise primitive prime divisors as those primes whose rank equals the index.
-/

namespace FibonacciApparitionSheaf

open Nat

/-- The apparition set of `p`: the positive indices at which `p` divides a Fibonacci number. -/
def fibApparitionSet (p : ℕ) : Set ℕ := {n | 0 < n ∧ p ∣ Nat.fib n}

/-- `p` appears in the Fibonacci sequence: some positive index has `p ∣ F n`. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- The **rank of apparition** of `p`: the least positive index `n` with `p ∣ F n`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

theorem hasFibRank_iff_nonempty {p : ℕ} :
    HasFibRank p ↔ {n | 0 < n ∧ p ∣ Nat.fib n}.Nonempty := Iff.rfl

/-- The rank of apparition is itself an apparition index. -/
theorem fibRank_spec {p : ℕ} (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem h

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_spec h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_spec h).2

/-- Minimality: no positive index below the rank is an apparition index. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) (hdvd : p ∣ Nat.fib k) : False :=
  Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

theorem fibRank_le {p n : ℕ} (hn : 0 < n) (hdvd : p ∣ Nat.fib n) : fibRank p ≤ n :=
  Nat.sInf_le ⟨hn, hdvd⟩

/-- Characterisation of the rank by its two defining properties. -/
theorem fibRank_eq_of {p r : ℕ} (hr : 0 < r) (hdvd : p ∣ Nat.fib r)
    (hmin : ∀ k, 0 < k → k < r → ¬ p ∣ Nat.fib k) : fibRank p = r := by
  refine le_antisymm (fibRank_le hr hdvd) ?_
  by_contra hcon
  have hlt : fibRank p < r := by omega
  have hex : HasFibRank p := ⟨r, hr, hdvd⟩
  exact hmin _ (fibRank_pos hex) hlt (dvd_fib_fibRank hex)

/-- **Every positive modulus appears.**  Pigeonhole on the state pairs `(F n, F (n+1))` modulo
`p`, transported back to the initial pair by invertibility of the Fibonacci recursion. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  set g : ℕ → ZMod p × ZMod p := fun n => ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))
    with hg
  -- the recursion can be run backwards
  have back : ∀ a b : ℕ, g (a + 1) = g (b + 1) → g a = g b := by
    intro a b hab
    simp only [hg, Prod.mk.injEq] at hab ⊢
    obtain ⟨h1, h2⟩ := hab
    refine ⟨?_, h1⟩
    have ha : Nat.fib (a + 1 + 1) = Nat.fib a + Nat.fib (a + 1) := Nat.fib_add_two
    have hb : Nat.fib (b + 1 + 1) = Nat.fib b + Nat.fib (b + 1) := Nat.fib_add_two
    rw [ha, hb] at h2
    push_cast at h2
    rw [h1] at h2
    exact add_right_cancel h2
  have shift : ∀ k a b : ℕ, g (a + k) = g (b + k) → g a = g b := by
    intro k
    induction k with
    | zero => intro a b h; simpa using h
    | succ k ih =>
        intro a b h
        refine ih a b (back (a + k) (b + k) ?_)
        have e1 : a + k + 1 = a + (k + 1) := by omega
        have e2 : b + k + 1 = b + (k + 1) := by omega
        rw [e1, e2]; exact h
  have key : ∀ i j : ℕ, i < j → g i = g j → p ∣ Nat.fib (j - i) := by
    intro i j hlt hEq
    have h0 : g 0 = g (j - i) := by
      refine shift i 0 (j - i) ?_
      have e1 : 0 + i = i := by omega
      have e2 : j - i + i = j := by omega
      rw [e1, e2]; exact hEq
    have hz : ((Nat.fib (j - i) : ℕ) : ZMod p) = 0 := by
      have := congrArg Prod.fst h0
      simp only [hg] at this
      simpa using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).mp hz
  obtain ⟨i, j, hij, hEq⟩ := Finite.exists_ne_map_eq_of_infinite g
  rcases lt_or_gt_of_ne hij with h1 | h1
  · exact ⟨j - i, by omega, key i j h1 hEq⟩
  · exact ⟨i - j, by omega, key j i h1 hEq.symm⟩

theorem hasFibRank_of_prime {p : ℕ} (hp : Nat.Prime p) : HasFibRank p :=
  hasFibRank_of_pos p hp.pos

/-- The apparition set is closed under `gcd`, by strong divisibility of the Fibonacci
sequence. -/
theorem dvd_fib_gcd {p m n : ℕ} (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n) := by
  rw [Nat.fib_gcd]
  exact Nat.dvd_gcd hm hn

/-- **Structure theorem for the apparition set.**  `p` divides `F m` exactly when the rank of
apparition divides `m`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (m : ℕ) :
    p ∣ Nat.fib m ↔ fibRank p ∣ m := by
  constructor
  · intro hdvd
    rcases Nat.eq_zero_or_pos m with hm | hm
    · simp [hm]
    · set r := fibRank p with hr
      have hgcd : p ∣ Nat.fib (Nat.gcd r m) := dvd_fib_gcd (dvd_fib_fibRank h) hdvd
      have hgpos : 0 < Nat.gcd r m := Nat.gcd_pos_of_pos_right _ hm
      have hle : r ≤ Nat.gcd r m := by
        by_contra hcon
        exact fibRank_min hgpos (by omega) hgcd
      have : Nat.gcd r m = r :=
        le_antisymm (Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_left _ _)) hle
      exact this ▸ Nat.gcd_dvd_right r m
  · intro hdvd
    exact (dvd_fib_fibRank h).trans (Nat.fib_dvd _ _ hdvd)

/-- The rank of apparition of a prime `p` is the unique index whose Fibonacci multiples are
exactly the indices it divides. -/
theorem fibRank_eq_of_forall_dvd_iff {p r : ℕ} (h : HasFibRank p)
    (hiff : ∀ m, p ∣ Nat.fib m ↔ r ∣ m) : fibRank p = r := by
  have h1 : fibRank p ∣ r := (fibRank_dvd_iff h r).mp ((hiff r).mpr dvd_rfl)
  have h2 : r ∣ fibRank p := (hiff (fibRank p)).mp (dvd_fib_fibRank h)
  exact Nat.dvd_antisymm h1 h2

end FibonacciApparitionSheaf