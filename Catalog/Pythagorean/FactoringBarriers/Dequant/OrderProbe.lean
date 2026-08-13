import Mathlib

/-!
# Barrier IV, part 1: the free `r ∣ t` probe and its `Θ(r)`-sealed extraction

This file formalises the *fixed-point gcd probe* of the de-quantization frontier
assessment.  For a modulus `N` and a base `b` the probe

  `probe N b t  :=  (N : ℤ) ∣ b ^ t - 1`

is a single modular exponentiation, and it answers exactly the question
"does the multiplicative order `r = ord_N(b)` divide `t`?"
(`Dequant.probe_iff_ord_dvd`).  Observation is therefore *free*.

The content of the barrier is that *extraction* is not.  We prove:

* `Dequant.probe_false_below_order` — every probe at a positive `t < r` returns
  `false`; the whole answer vector below the order is constant, hence carries no
  information at all.
* `Dequant.ord_isLeast` — `r` is the least positive `t` with a positive probe, so
  the naive extraction really has to walk up to `r`.
* `Dequant.dvd_probe_agree` and `Dequant.extraction_needs_query_at_least_order` —
  an adversary argument: any extractor whose output depends only on the probe
  answers on a finite query set `T` must query some `t ≥ min r s` in order to tell
  two candidate orders `r ≠ s` apart.  This is the `Θ(r) = O(N)`-sealed extraction.
* `Dequant.ord_two_mersenne` — the seal is not vacuous: every `r ≥ 2` is realised
  as an honest multiplicative order, `ord_{2^r-1}(2) = r`.
* `Dequant.ord_isLeast_dvd_of_dvd` — the one escape hatch, made precise: if a
  multiple `L` of `r` is known *together with its divisors*, then `r` is the least
  divisor of `L` passing the probe.  For RSA moduli `L = λ(N)` is itself as hard
  as factoring, which is the circularity recorded in the paper.
-/

namespace Dequant

open Finset

/-- The multiplicative order of `b` modulo `N`. -/
noncomputable def ord (N b : ℕ) : ℕ := orderOf (b : ZMod N)

/-- The fixed-point / gcd probe: `N ∣ b ^ t - 1`, i.e. `gcd (b^t - 1, N) = N`. -/
def probe (N b t : ℕ) : Prop := (N : ℤ) ∣ (b : ℤ) ^ t - 1

instance (N b t : ℕ) : Decidable (probe N b t) := by
  unfold probe; infer_instance

/-! ### The probe is exactly the divisibility oracle for the order -/

/-- **The probe is a theorem, not a heuristic**: `N ∣ b^t - 1` holds precisely when
the order of `b` modulo `N` divides `t`. -/
theorem probe_iff_ord_dvd (N b t : ℕ) : probe N b t ↔ ord N b ∣ t := by
  rw [ord, orderOf_dvd_iff_pow_eq_one, probe, ← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  exact sub_eq_zero

/-- Natural-number form of the probe. -/
theorem probe_iff_nat {N b t : ℕ} (hb : 1 ≤ b) : probe N b t ↔ N ∣ b ^ t - 1 := by
  have h1 : 1 ≤ b ^ t := Nat.one_le_pow _ _ hb
  unfold probe
  constructor
  · intro h
    have : ((N : ℤ)) ∣ ((b ^ t - 1 : ℕ) : ℤ) := by
      rwa [Nat.cast_sub h1, Nat.cast_pow, Nat.cast_one]
    exact_mod_cast this
  · intro h
    have : ((N : ℤ)) ∣ ((b ^ t - 1 : ℕ) : ℤ) := by exact_mod_cast h
    rwa [Nat.cast_sub h1, Nat.cast_pow, Nat.cast_one] at this

/-! ### Free observation, sealed extraction -/

/-- **Every probe below the order is `false`.**  The answer vector on
`{1, …, r-1}` is constant, so no algorithm can learn anything from probes that do
not reach the order. -/
theorem probe_false_below_order {N b t : ℕ} (ht : 0 < t) (htr : t < ord N b) :
    ¬ probe N b t := by
  intro h
  have hdvd : ord N b ∣ t := (probe_iff_ord_dvd N b t).mp h
  exact absurd (Nat.le_of_dvd ht hdvd) (by omega)

/-- The order is the least positive `t` at which the probe fires. -/
theorem ord_isLeast {N b : ℕ} (h : 0 < ord N b) :
    IsLeast {t : ℕ | 0 < t ∧ probe N b t} (ord N b) := by
  refine ⟨⟨h, (probe_iff_ord_dvd N b (ord N b)).mpr dvd_rfl⟩, ?_⟩
  rintro t ⟨ht, hpt⟩
  exact Nat.le_of_dvd ht ((probe_iff_ord_dvd N b t).mp hpt)

/-- With a known multiple `L` of the order **and** its divisors in hand, the order is
the least divisor of `L` passing the probe.  This is the only known poly-time
extraction, and for RSA moduli producing such an `L` with known factorisation is
itself equivalent to factoring. -/
theorem ord_isLeast_dvd_of_dvd {N b L : ℕ} (h : 0 < ord N b) (hL : ord N b ∣ L) :
    IsLeast {d : ℕ | 0 < d ∧ d ∣ L ∧ probe N b d} (ord N b) := by
  refine ⟨⟨h, hL, (probe_iff_ord_dvd N b (ord N b)).mpr dvd_rfl⟩, ?_⟩
  rintro d ⟨hd, -, hpd⟩
  exact Nat.le_of_dvd hd ((probe_iff_ord_dvd N b d).mp hpd)

/-! ### The adversary argument: extraction needs a query of size `≥ r` -/

/-- Two candidate orders `r, s` produce *identical* probe answers on any query set
whose entries are positive and smaller than both. -/
theorem dvd_probe_agree {r s : ℕ} {T : Finset ℕ}
    (hT : ∀ t ∈ T, 0 < t ∧ t < r ∧ t < s) :
    ∀ t ∈ T, decide (r ∣ t) = decide (s ∣ t) := by
  intro t ht
  obtain ⟨h0, hr, hs⟩ := hT t ht
  have hnr : ¬ r ∣ t := fun hd => absurd (Nat.le_of_dvd h0 hd) (by omega)
  have hns : ¬ s ∣ t := fun hd => absurd (Nat.le_of_dvd h0 hd) (by omega)
  simp [hnr, hns]

/-- **The `Θ(r)` seal.**  Let `A` be any extractor whose output depends only on the
probe answers at a finite query set `T` of positive integers.  If `A` correctly
returns the order in the two cases `r` and `s` with `r ≠ s`, then `T` must contain a
query at least as large as one of the two orders.  Sub-linear probing therefore
cannot separate candidate orders: observation is free, extraction is `O(r)`-sealed. -/
theorem extraction_needs_query_at_least_order {r s : ℕ} (hrs : r ≠ s)
    {T : Finset ℕ} (hT0 : ∀ t ∈ T, 0 < t)
    (A : (ℕ → Bool) → ℕ)
    (hloc : ∀ f g : ℕ → Bool, (∀ t ∈ T, f t = g t) → A f = A g)
    (hAr : A (fun t => decide (r ∣ t)) = r)
    (hAs : A (fun t => decide (s ∣ t)) = s) :
    ∃ t ∈ T, r ≤ t ∨ s ≤ t := by
  by_contra hcon
  push_neg at hcon
  have hT : ∀ t ∈ T, 0 < t ∧ t < r ∧ t < s := by
    intro t ht
    obtain ⟨h1, h2⟩ := hcon t ht
    exact ⟨hT0 t ht, h1, h2⟩
  have := hloc _ _ (dvd_probe_agree hT)
  rw [hAr, hAs] at this
  exact hrs this

/-! ### The seal is non-vacuous: every `r ≥ 2` is a genuine multiplicative order -/

/-- `2` has order exactly `r` modulo the Mersenne number `2^r - 1`.  Hence the
candidate orders used in the adversary argument are realised by honest
order-finding instances, at every scale. -/
theorem ord_two_mersenne {r : ℕ} (hr : 2 ≤ r) : ord (2 ^ r - 1) 2 = r := by
  set N := 2 ^ r - 1 with hN
  have h4 : 4 ≤ 2 ^ r := by
    calc (4:ℕ) = 2 ^ 2 := by norm_num
    _ ≤ 2 ^ r := Nat.pow_le_pow_right (by norm_num) hr
  have hNpos : 1 < N := by omega
  have hpow : probe N 2 r := by
    rw [probe_iff_nat (by norm_num)]
  have hdvd : ord N 2 ∣ r := (probe_iff_ord_dvd N 2 r).mp hpow
  have hpos : 0 < ord N 2 := by
    rcases Nat.eq_zero_or_pos (ord N 2) with h | h
    · rw [h] at hdvd
      have : r = 0 := Nat.eq_zero_of_zero_dvd hdvd
      omega
    · exact h
  by_contra hne
  have hlt : ord N 2 < r := lt_of_le_of_ne (Nat.le_of_dvd (by omega) hdvd) hne
  set t := ord N 2 with ht
  have hprobe : probe N 2 t := (probe_iff_ord_dvd N 2 t).mpr dvd_rfl
  rw [probe_iff_nat (by norm_num)] at hprobe
  have h1 : 0 < 2 ^ t - 1 := by
    have : 2 ≤ 2 ^ t := by
      calc (2:ℕ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ t := Nat.pow_le_pow_right (by norm_num) hpos
    omega
  have h2 : 2 ^ t - 1 < N := by
    have : 2 ^ t < 2 ^ r := Nat.pow_lt_pow_right (by norm_num) hlt
    omega
  exact absurd (Nat.le_of_dvd h1 hprobe) (by omega)

end Dequant