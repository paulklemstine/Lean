import Mathlib

/-!
# Ranks of apparition of the Fibonacci sequence

`Shared/NumberTheory/CarmichaelCompositeEntryPoint.lean` is written against a theory of
Fibonacci ranks of apparition that was absent from this repository, so that file did not
compile.  This module supplies it.

For `p > 0` the Fibonacci sequence always meets a multiple of `p`
(`hasFibRank_of_pos`): the pairs `(F k, F (k+1))` take finitely many values modulo `p`,
so two of them coincide, and running the recursion backwards shows that `F` vanishes
modulo `p` at the difference of the two indices.  The least positive index at which this
happens is the **rank of apparition** `fibRank p`, and it controls the whole divisibility
pattern: `p ∣ F n` **iff** `fibRank p ∣ n` (`fibRank_dvd_iff`), which follows from
`Nat.fib_gcd` and minimality.
-/

namespace FibonacciApparitionSheaf

open Nat

/-- `p` has a rank of apparition: it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ Nat.fib k

/-- The **rank of apparition** of `p`: the least positive index `k` with `p ∣ F k`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {k | 0 < k ∧ p ∣ Nat.fib k}

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) (hdvd : p ∣ Nat.fib k) :
    False := by
  have hle : fibRank p ≤ k := Nat.sInf_le (show k ∈ {k | 0 < k ∧ p ∣ Nat.fib k} from ⟨hk, hdvd⟩)
  omega

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) :
    0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) := by
  have hne : {k | 0 < k ∧ p ∣ Nat.fib k}.Nonempty := h
  exact Nat.sInf_mem hne

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) :=
  (fibRank_mem h).2

/-- Backwards step of the Fibonacci recursion modulo `p`: if the states at `i` and `j`
agree then `p` divides `F (j - i)`. -/
theorem dvd_fib_sub_of_state_eq (p : ℕ) :
    ∀ i j : ℕ, i ≤ j →
      ((Nat.fib i : ZMod p) = (Nat.fib j : ZMod p) ∧
        (Nat.fib (i + 1) : ZMod p) = (Nat.fib (j + 1) : ZMod p)) →
      p ∣ Nat.fib (j - i) := by
  intro i
  induction i with
  | zero =>
      intro j _ h
      have h0 : (Nat.fib j : ZMod p) = 0 := by
        have := h.1
        simpa using this.symm
      simpa using (ZMod.natCast_eq_zero_iff _ _).mp h0
  | succ i ih =>
      intro j hj h
      obtain ⟨j', rfl⟩ : ∃ j', j = j' + 1 := ⟨j - 1, by omega⟩
      have hij : i ≤ j' := by omega
      have h2 : (Nat.fib (i + 2) : ZMod p) = (Nat.fib (j' + 2) : ZMod p) := h.2
      have hrec : ∀ t : ℕ, (Nat.fib (t + 2) : ZMod p)
          = (Nat.fib t : ZMod p) + (Nat.fib (t + 1) : ZMod p) := by
        intro t
        rw [Nat.fib_add_two]
        push_cast
        ring
      have hfirst : (Nat.fib i : ZMod p) = (Nat.fib j' : ZMod p) := by
        have hi := hrec i
        have hj2 := hrec j'
        have := h.1
        rw [hi, hj2] at h2
        linear_combination h2 - this
      have hsecond : (Nat.fib (i + 1) : ZMod p) = (Nat.fib (j' + 1) : ZMod p) := h.1
      have := ih j' hij ⟨hfirst, hsecond⟩
      simpa using this

/-- **Existence of the rank of apparition.**  Every positive `p` divides a Fibonacci
number of positive index. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨by omega⟩
  have hfin : ¬ Function.Injective
      (fun k : ℕ => ((Nat.fib k : ZMod p), (Nat.fib (k + 1) : ZMod p))) := by
    intro hinj
    haveI : Finite ℕ := Finite.of_injective _ hinj
    exact not_finite ℕ
  rw [Function.not_injective_iff] at hfin
  obtain ⟨a, b, hab, hne⟩ := hfin
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · refine ⟨b - a, by omega, ?_⟩
    exact dvd_fib_sub_of_state_eq p a b (by omega)
      ⟨congrArg Prod.fst hab, congrArg Prod.snd hab⟩
  · refine ⟨a - b, by omega, ?_⟩
    exact dvd_fib_sub_of_state_eq p b a (by omega)
      ⟨(congrArg Prod.fst hab).symm, (congrArg Prod.snd hab).symm⟩

/-- **The rank of apparition governs divisibility**: `p ∣ F n` exactly when the rank
divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · set r := fibRank p with hr
      have hgcd : p ∣ Nat.fib (Nat.gcd n r) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hpn (dvd_fib_fibRank h)
      have hgpos : 0 < Nat.gcd n r := Nat.gcd_pos_of_pos_left _ hn
      have hle : r ≤ Nat.gcd n r :=
        Nat.sInf_le (show Nat.gcd n r ∈ {k | 0 < k ∧ p ∣ Nat.fib k} from ⟨hgpos, hgcd⟩)

      have hdvd : Nat.gcd n r ∣ r := Nat.gcd_dvd_right n r
      have hge : Nat.gcd n r ≤ r := Nat.le_of_dvd (fibRank_pos h) hdvd
      have hEq : Nat.gcd n r = r := le_antisymm hge hle
      exact hEq ▸ Nat.gcd_dvd_left n r
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf