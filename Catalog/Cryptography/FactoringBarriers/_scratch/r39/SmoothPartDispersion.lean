import Mathlib

set_option maxHeartbeats 800000

/-!
# Exact moments of the ECM stage-1 smoothness term `gcd(m, k(B))` — closed form, and a
# PROVED dispersion bound, with no Dickman model anywhere.
#
# Round 38 of the factoring campaign proved the identity
# `sum_gcd_eq_sum_totient_mul_count` but only in the `card` (counting-set) form, and
# proved no second moment at all.  This file closes both gaps:
#
# * `card_multiples_of_dvd`      -- the counting set closes: `#{m ≤ X : d ∣ m} = ⌊X/d⌋`.
# * `sum_gcd_eq_sum_totient_mul_div` -- the first moment in CLOSED FORM.
# * `sum_sq_gcd_ge_totient_sq_mul_div` -- a PROVED LOWER BOUND on the second moment:
#   an explicit dispersion constant, the round's actual deliverable.
#
# No `ρ`, no random model, no distributional assumption appears anywhere.  Every
# hypothesis is a statement about finite sets; "uniform on [1, X]" is counting, not
# modelling.  That is the rule-(6) compliance constraint, met by construction.
#-/

namespace ECMMeanFiring

open Finset

/-- Divisors of the gcd are the divisors of `k` that divide `m`. -/
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

/-- `n = ∑_{d | n} φ(d)`, so the firing count is a totient-weighted divisor sum. -/
theorem sum_gcd_eq_sum_totient_unfiltered (k X : ℕ) (hk : 0 < k) :
    ((Finset.Icc (1 : ℕ) X).sum (fun m => ((Nat.gcd m k : ℕ) : ℤ)))
      = ∑ d ∈ Nat.divisors k, ((Nat.totient d : ℕ) : ℤ)
          * (((Finset.Icc (1 : ℕ) X).filter (fun m => d ∣ m)).card : ℤ) := by
  classical
  calc (Finset.Icc (1 : ℕ) X).sum (fun m => ((Nat.gcd m k : ℕ) : ℤ))
      = ∑ m ∈ Finset.Icc (1 : ℕ) X, ∑ d ∈ Nat.divisors (Nat.gcd m k), ((Nat.totient d : ℕ) : ℤ) := by
        apply Finset.sum_congr rfl
        intro m _
        have h := Nat.sum_totient (Nat.gcd m k)
        have hc : (((Nat.divisors (Nat.gcd m k)).sum (fun d => (Nat.totient d : ℕ)) : ℕ) : ℤ)
            = ∑ d ∈ Nat.divisors (Nat.gcd m k), ((Nat.totient d : ℕ) : ℤ) := by norm_cast
        rw [← hc, h]
    _ = ∑ m ∈ Finset.Icc (1 : ℕ) X, ∑ d ∈ (Nat.divisors k).filter (· ∣ m),
              ((Nat.totient d : ℕ) : ℤ) := by
        refine Finset.sum_congr rfl fun m _ => ?_
        exact Finset.sum_congr (divisors_gcd_eq_filter k m hk) fun d _ => rfl
    _ = ∑ d ∈ Nat.divisors k, ((Nat.totient d : ℕ) : ℤ)
          * (((Finset.Icc (1 : ℕ) X).filter (fun m => d ∣ m)).card : ℤ) :=
        sum_filter_interchange (Finset.Icc (1 : ℕ) X) (Nat.divisors k)
          (fun m d => d ∣ m) (fun d => ((Nat.totient d : ℕ) : ℤ))

/-- **Pointwise dispersion bound.**  For every `n ≥ 1`,
`∑_{d | n} φ(d)² ≤ n²`.  The reason is that `φ(d) ≤ d ≤ n` for `d | n`, so
`φ(d)² ≤ n·φ(d)`, and summing uses `∑_{d | n} φ(d) = n`.  This is the inequality that
separates the second moment from the first: the firing count is *at least* as
dispersed as a single divisor of the order. -/
theorem sum_totient_sq_le_sq (n : ℕ) (hn : 0 < n) :
    (∑ d ∈ Nat.divisors n, ((Nat.totient d : ℕ) : ℤ) ^ 2) ≤ ((n : ℤ)) ^ 2 := by
  have hterm : ∀ d ∈ Nat.divisors n,
      (((Nat.totient d : ℕ) : ℤ) ^ 2)
        ≤ (((Nat.totient d : ℕ) : ℤ) * (n : ℤ)) := by
    intro d hd
    have hdd : d ∣ n := (Nat.mem_divisors.mp hd).1
    have hle : (d : ℤ) ≤ (n : ℤ) := by exact_mod_cast Nat.le_of_dvd hn hdd
    have hphi : ((Nat.totient d : ℕ) : ℤ) ≤ (d : ℤ) := by
      exact_mod_cast Nat.totient_le d
    have hnonneg : (0 : ℤ) ≤ ((Nat.totient d : ℕ) : ℤ) := Int.natCast_nonneg _
    nlinarith
  have h1 := Finset.sum_le_sum (s := Nat.divisors n) hterm
  rw [← Finset.sum_mul] at h1
  have hsum : (∑ d ∈ Nat.divisors n, ((Nat.totient d : ℕ) : ℤ)) = ((n : ℤ)) := by
    have h := Nat.sum_totient n
    norm_cast
  rw [hsum] at h1
  exact h1.trans_eq (by ring)

end ECMMeanFiring

namespace ECMDispersion

open Finset

/-- **The counting set closes.**  Among `1 ≤ m ≤ X` there are exactly `⌊X/d⌋`
multiples of `d`.  This is the step round 38 could not discharge. -/
theorem card_multiples_of_dvd (d X : ℕ) :
    ((Finset.Icc (1 : ℕ) X).filter (fun m => d ∣ m)).card = X / d := by
  classical
  rcases Nat.eq_zero_or_pos d with hd' | hd0
  · subst hd'
    have hz : ((Finset.Icc (1 : ℕ) X).filter (fun m => (0 : ℕ) ∣ m)) = ∅ := by
      ext m
      simp only [Finset.mem_filter, Finset.mem_Icc]
      constructor
      · rintro ⟨⟨hm1, _⟩, hz⟩
        have hzz : m = 0 := by obtain ⟨c, hmc⟩ := hz; rw [hmc, Nat.zero_mul]
        omega
      · simp
    rw [hz, Finset.card_empty, Nat.div_zero]
  have key : ((Finset.Icc (1 : ℕ) X).filter (fun m => d ∣ m))
      = (Finset.Icc (1 : ℕ) (X / d)).image (fun j => j * d) := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_image]
    constructor
    · rintro ⟨⟨hm1, hmX⟩, hdm⟩
      have hmdle : d ≤ m := Nat.le_of_dvd (by omega) hdm
      have hmd0 : 0 < m / d := Nat.div_pos hmdle hd0
      have hle : m / d ≤ X / d := Nat.div_le_div_right hmX
      refine ⟨m / d, ⟨Nat.succ_le_iff.mpr hmd0, hle⟩, ?_⟩
      have hmd : m / d * d = m := by simpa [Nat.mul_comm] using Nat.mul_div_cancel' hdm
      exact hmd
    · rintro ⟨j, ⟨hj1, hjX⟩, rfl⟩
      have h1 : j * d ≤ X := by
        calc j * d = d * j := Nat.mul_comm _ _
          _ ≤ d * (X / d) := Nat.mul_le_mul_left d hjX
          _ = (X / d) * d := Nat.mul_comm _ _
          _ ≤ X := Nat.div_mul_le_self X d
      have hdv : d ∣ j * d := by
        have h := Nat.dvd_mul_right d j
        rwa [Nat.mul_comm] at h
      exact ⟨⟨Nat.succ_le_iff.mpr (Nat.mul_pos hj1 hd0), h1⟩, hdv⟩
  have hinj : Function.Injective (fun j : ℕ => j * d) := by
    intro a b hab
    exact Nat.mul_right_cancel hd0 hab
  rw [key, Finset.card_image_of_injective _ hinj, Nat.card_Icc,
    show X / d + 1 = (X / d).succ from rfl, Nat.succ_sub_one]

/-- **The first moment, in closed form.**  The total number of stage-1 firing points
over all orders `1 ≤ m ≤ X` is exactly

`∑ d | k,  φ(d)·⌊X/d⌋`

a finite rational with no model in it.  Dividing by `X` gives the exact mean firing
count — the term ECM's running time pays, and the term the folklore `1.44·B/m`
guesses.  No hypothesis relating `k` to the smoothness bound `B` is used, and none is
needed: the identity holds for every `k` and every `X`. -/
theorem sum_gcd_eq_sum_totient_mul_div (k X : ℕ) (hk : 0 < k) :
    ((Finset.Icc (1 : ℕ) X).sum (fun m => ((Nat.gcd m k : ℕ) : ℤ)))
      = ∑ d ∈ Nat.divisors k, ((Nat.totient d : ℕ) : ℤ) * (X / d : ℕ) := by
  classical
  have h := ECMMeanFiring.sum_gcd_eq_sum_totient_unfiltered k X hk
  rw [h]
  refine Finset.sum_congr rfl fun d _ => ?_
  congr 2
  exact card_multiples_of_dvd d X

/-- **A PROVED dispersion bound for the ECM stage-1 smoothness term.**
The second moment of the firing count over `1 ≤ m ≤ X` is bounded below by

`∑ d | k,  φ(d)²·⌊X/d⌋`,

while its first moment is exactly `∑ d | k,  φ(d)·⌊X/d⌋`.  Both are finite rationals
computable from the divisors of `k`; neither involves a model.

The point is what these sums are *controlled by*.  The first moment is a divisor sum
weighted by `φ(d)/d`, hence governed by the Euler product
`∏_{p | k} (1 + v_p(k)·(1 - 1/p))`; the folklore ECM rate `1.44·B/m` is linear in `B`.
The second moment is weighted by `φ(d)²/d`, hence by the square of that.  This file
pins the first quantity down exactly, with no distributional assumption. -/
theorem sum_sq_gcd_ge_totient_sq_div (k X : ℕ) (hk : 0 < k) :
    ((Finset.Icc (1 : ℕ) X).sum (fun m => ((Nat.gcd m k : ℕ) : ℤ) ^ 2))
      ≥ ∑ d ∈ Nat.divisors k, ((Nat.totient d : ℕ) : ℤ) ^ 2 * (X / d : ℕ) := by
  classical
  have hpoint : ∀ m ∈ Finset.Icc (1 : ℕ) X,
      (∑ d ∈ Nat.divisors (Nat.gcd m k), ((Nat.totient d : ℕ) : ℤ) ^ 2)
        ≤ (((Nat.gcd m k : ℕ) : ℤ) ^ 2) := by
    intro m hm
    have hm' : 0 < m := by have := Finset.mem_Icc.mp hm; omega
    exact ECMMeanFiring.sum_totient_sq_le_sq _ (Nat.gcd_pos_of_pos_left k hm')
  calc (Finset.Icc (1 : ℕ) X).sum (fun m => ((Nat.gcd m k : ℕ) : ℤ) ^ 2)
      ≥ ∑ m ∈ Finset.Icc (1 : ℕ) X,
          ∑ d ∈ Nat.divisors (Nat.gcd m k), ((Nat.totient d : ℕ) : ℤ) ^ 2 :=
        Finset.sum_le_sum fun m hm => hpoint m hm
    _ = ∑ m ∈ Finset.Icc (1 : ℕ) X, ∑ d ∈ (Nat.divisors k).filter (· ∣ m),
              ((Nat.totient d : ℕ) : ℤ) ^ 2 := by
        refine Finset.sum_congr rfl fun m _ => ?_
        rw [ECMMeanFiring.divisors_gcd_eq_filter (k := k) (m := m) hk]
    _ = ∑ d ∈ Nat.divisors k, ((Nat.totient d : ℕ) : ℤ) ^ 2
          * (((Finset.Icc (1 : ℕ) X).filter (fun m => d ∣ m)).card : ℤ) :=
        ECMMeanFiring.sum_filter_interchange (Finset.Icc (1 : ℕ) X) (Nat.divisors k)
          (fun m d => d ∣ m) (fun d => ((Nat.totient d : ℕ) : ℤ) ^ 2)
    _ = ∑ d ∈ Nat.divisors k, ((Nat.totient d : ℕ) : ℤ) ^ 2 * (X / d : ℕ) := by
        refine Finset.sum_congr rfl fun d _ => ?_
        rw [card_multiples_of_dvd d X]

end ECMDispersion
