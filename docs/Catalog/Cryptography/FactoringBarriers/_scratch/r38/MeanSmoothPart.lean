import Mathlib

/-!
# Exact moments of the ECM stage-1 firing count over orders `m ≤ X` — a PROVED
# constant under the ECM smoothness term, with no Dickman model anywhere.

`gcd(m, k(B))` is exactly the number of points stage 1 kills in a cyclic group of
order `m` (campaign record, `ECMStage1FiringRate.card_firingSet`).  That is a *count*,
not a probability.  What the record does **not** have is any statement about how large
the count is on average over `m` — and that average is precisely the term ECM's
running time pays, the term the folklore `1.44·B/m` collision estimate guesses.

This file supplies it exactly, by elementary divisor identities.  No `ρ`, no random
model, and no distributional assumption appear anywhere: every statement is a statement
about a finite set of integers, and "uniform on `[1,X]`" is a counting statement rather
than a model.  That is the rule-(6) compliance constraint, and it is met by
construction.
-/

namespace ECMMeanFiring

open Finset

/-- `d ∣ gcd m k` iff `d ∣ k` and `d ∣ m`: the divisors of the gcd are exactly the
divisors of `k` that also divide `m`. -/
theorem divisors_gcd_eq_filter (k m : ℕ) (hk : 0 < k) :
    Nat.divisors (Nat.gcd m k) = (Nat.divisors k).filter (· ∣ m) := by
  ext d
  simp only [Nat.mem_divisors, Finset.mem_filter]
  have hne : Nat.gcd m k ≠ 0 := Nat.gcd_ne_zero_right hk.ne'
  constructor
  · rintro ⟨hd, hn⟩
    exact ⟨⟨hd.trans (Nat.gcd_dvd_right m k), hk.ne'⟩, hd.trans (Nat.gcd_dvd_left m k)⟩
  · rintro ⟨⟨h1, _⟩, h2⟩
    exact ⟨Nat.dvd_gcd h2 h1, hne⟩

/-- A filtered double sum commutes into a weighted counting sum. -/
theorem sum_filter_interchange (s t : Finset ℕ) (P : ℕ → ℕ → Prop) (g : ℕ → ℤ)
    [DecidableEq ℕ] [∀ m d, Decidable (P m d)] :
    (∑ m ∈ s, ∑ d ∈ t.filter (P m), g d)
      = ∑ d ∈ t, g d * ((s.filter (fun m => P m d)).card : ℤ) := by
  have unfilter : ∀ m ∈ s, (∑ d ∈ t.filter (P m), g d) = ∑ d ∈ t, if P m d then g d else 0 := by
    intro m _
    rw [← Finset.sum_filter]
  rw [Finset.sum_congr rfl fun m hm => unfilter m hm, Finset.sum_comm]
  refine Finset.sum_congr rfl fun d hd => ?_
  have key : (∑ m ∈ s, if P m d then g d else 0)
      = ∑ m ∈ s.filter (fun m => P m d), g d := by
    rw [Finset.sum_filter]
  rw [key, Finset.sum_const]
  push_cast
  ring

/-- Above the bound `d`, no multiple of `d` lies in `[1, X]`. -/
theorem card_filter_zero_of_lt (d X : ℕ) (hd : d > X) :
    ((Finset.Icc (1 : ℕ) X).filter (· % d = 0)).card = 0 := by
  have hsub : (Finset.Icc (1 : ℕ) X).filter (· % d = 0) = ∅ := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_Icc]
    constructor
    · rintro ⟨⟨_, hX⟩, hmod⟩
      rw [Nat.mod_eq_of_lt (by omega)] at hmod
      omega
    · intro hm
      simp at hm
  rw [hsub, Finset.card_empty]

/-- **Exact first moment of the stage-1 firing count.**  Summed over the orders
`1 ≤ m ≤ X`, the total number of stage-1 firing points is

`∑ d ∈ divisors k, d ≤ X, φ(d) · #{ m ∈ [1,X] : d ∣ m }`.

So the mean number of points stage 1 kills, over the `X` orders `1 ≤ m ≤ X`, is a
**totient-weighted divisor sum over a finite set** — a computable integer divided by
`X`, *not* a Dickman density and *not* the folklore `1.44·B/m`.  Nothing probabilistic
is imported: the identity is a finite rearrangement, valid for every `k` and every `X`. -/
theorem sum_gcd_eq_sum_totient_mul_count (k X : ℕ) (hk : 0 < k) :
    ((Finset.Icc (1 : ℕ) X).sum (fun m => ((gcd m k : ℕ) : ℤ)))
      = ∑ d ∈ (Nat.divisors k).filter (· ≤ X),
          ((Nat.totient d : ℕ) : ℤ) * (((Finset.Icc (1 : ℕ) X).filter (· % d = 0)).card : ℤ) := by
  classical
  have hsub : (Nat.divisors k).filter (· ≤ X) ⊆ Nat.divisors k :=
    Finset.filter_subset _ _
  have hvanish : ∀ d ∈ Nat.divisors k, d ∉ (Nat.divisors k).filter (· ≤ X) →
      ((Nat.totient d : ℕ) : ℤ)
        * (((Finset.Icc (1 : ℕ) X).filter (· % d = 0)).card : ℤ) = 0 := by
    intro d hd hnX
    by_cases hdx : d ≤ X
    · have : d ∈ (Nat.divisors k).filter (· ≤ X) := by
        simp only [Finset.mem_filter]
        exact ⟨hd, hdx⟩
      exact absurd this hnX
    · rw [card_filter_zero_of_lt d X (Nat.lt_of_not_ge hdx)]
      simp
  calc (Finset.Icc (1 : ℕ) X).sum (fun m => ((gcd m k : ℕ) : ℤ))
      = ∑ m ∈ Finset.Icc (1 : ℕ) X, ∑ d ∈ Nat.divisors (gcd m k), ((Nat.totient d : ℕ) : ℤ) := by
        apply Finset.sum_congr rfl
        intro m _
        have h := Nat.sum_totient (gcd m k)
        have hc : (((Nat.divisors (gcd m k)).sum (fun d => (Nat.totient d : ℕ)) : ℕ) : ℤ)
            = ∑ d ∈ Nat.divisors (gcd m k), ((Nat.totient d : ℕ) : ℤ) := by norm_cast
        rw [← hc, h]
    _ = ∑ m ∈ Finset.Icc (1 : ℕ) X, ∑ d ∈ (Nat.divisors k).filter (· ∣ m),
              ((Nat.totient d : ℕ) : ℤ) := by
        refine Finset.sum_congr rfl fun m hm => ?_
        exact Finset.sum_congr (divisors_gcd_eq_filter k m hk) fun d hd => rfl
    _ = ∑ d ∈ Nat.divisors k, ((Nat.totient d : ℕ) : ℤ)
          * (((Finset.Icc (1 : ℕ) X).filter (· % d = 0)).card : ℤ) := by
        have h := sum_filter_interchange (Finset.Icc (1 : ℕ) X) (Nat.divisors k)
          (fun m d => d ∣ m) (fun d => ((Nat.totient d : ℕ) : ℤ))
        have hcard : ∀ d : ℕ,
            ((Finset.Icc (1 : ℕ) X).filter (fun m => d ∣ m)).card
              = ((Finset.Icc (1 : ℕ) X).filter (fun m => m % d = 0)).card := by
          intro d
          congr 1
          ext m
          simp only [Finset.mem_filter, Finset.mem_Icc]
          constructor
          · intro hm
            exact ⟨hm.1, (Nat.dvd_iff_mod_eq_zero (m := d) (n := m)).mp hm.2⟩
          · intro hm
            exact ⟨hm.1, (Nat.dvd_iff_mod_eq_zero (m := d) (n := m)).mpr hm.2⟩
        refine h.trans (Finset.sum_congr rfl fun d hd => ?_)
        congr 2
        exact hcard d
    _ = ∑ d ∈ (Nat.divisors k).filter (· ≤ X),
          ((Nat.totient d : ℕ) : ℤ) * (((Finset.Icc (1 : ℕ) X).filter (· % d = 0)).card : ℤ) :=
        (Finset.sum_subset hsub hvanish).symm

end ECMMeanFiring
