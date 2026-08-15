import Geometry.PowerSumCarmichaelPeriod

/-!
# Cycle 2: the first hit, an unconditional reveal, and the density of good exponents

The master formula of `Geometry.PowerSumFactorReveal` says that, for `N = p*q` with
`p ≠ q` prime and `k ≥ 1`,

`gcd (powerSum N k) N = (if (p-1) ∣ k then 1 else p) * (if (q-1) ∣ k then 1 else q)`.

Three consequences are proved here.

* **Unconditional reveal.**  If `p < q` then the side condition `(q-1) ∤ (p-1)` of
  Theorem 1 is *automatic*, so `gcd (powerSum N (p-1)) N = q` with no extra hypothesis.
  (This strengthens the original statement of Theorem 1.)
* **First hit.**  The least exponent `k ≥ 1` at which the gcd is not the trivial value
  `N` is exactly `k* = min (p-1) (q-1)`, and `(k*+1)^2 ≤ N`, i.e. `k* < √N`.
  At `k = k*` the gcd is already a *proper* factor.
* **Density of good exponents.**  Inside one Carmichael period `λ = lcm (p-1) (q-1)`
  the number of exponents that reveal a proper factor is exactly
  `λ/(p-1) + λ/(q-1) - 2`.  So the useful exponents are a `(1/(p-1) + 1/(q-1))`-fraction
  of the period: sparse, which is the quantitative form of the "period-finding barrier".

## Main results

* `PowerSumReveal.gcd_powerSum_eq_self_iff`
* `PowerSumReveal.powerSum_factor_reveal_of_lt` — unconditional Theorem 1.
* `PowerSumReveal.first_hit_isLeast` — first hit at `min (p-1) (q-1)`.
* `PowerSumReveal.first_hit_sq_le` — `k* < √N`.
* `PowerSumReveal.card_revealing_exponents` — density inside one period.
-/

namespace PowerSumReveal

open Finset

variable {p q : ℕ}

/-! ## A value table for the gcd -/

/-- The gcd is the whole modulus exactly when neither `p-1` nor `q-1` divides `k`. -/
theorem gcd_powerSum_eq_self_iff (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {k : ℕ}
    (hk : k ≠ 0) :
    Nat.gcd (powerSum (p * q) k) (p * q) = p * q ↔ (¬ (p - 1) ∣ k ∧ ¬ (q - 1) ∣ k) := by
  have h2 := hp.two_le
  have h3 := hq.two_le
  rw [gcd_powerSum_semiprime hp hq hpq hk]
  constructor
  · intro h
    by_cases hA : (p - 1) ∣ k
    · exfalso
      by_cases hB : (q - 1) ∣ k
      · rw [if_pos hA, if_pos hB, one_mul] at h; nlinarith
      · rw [if_pos hA, if_neg hB, one_mul] at h; nlinarith
    · by_cases hB : (q - 1) ∣ k
      · exfalso; rw [if_neg hA, if_pos hB, mul_one] at h; nlinarith
      · exact ⟨hA, hB⟩
  · rintro ⟨hA, hB⟩
    rw [if_neg hA, if_neg hB]

/-! ## The unconditional reveal at the smaller exponent -/

/-- If `p < q` are primes then `(q-1) ∤ (p-1)`: the side condition of Theorem 1 is
automatic at the smaller exponent. -/
theorem not_dvd_pred_of_lt (hp : p.Prime) (hlt : p < q) : ¬ (q - 1) ∣ (p - 1) := by
  have h1 := hp.two_le
  intro hd
  have := Nat.le_of_dvd (by omega) hd
  omega

/-- **Unconditional Theorem 1.**  For distinct primes with `p < q`, the exponent `p-1`
always reveals the larger factor `q`; no divisibility side condition is needed. -/
theorem powerSum_factor_reveal_of_lt (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    Nat.gcd (powerSum (p * q) (p - 1)) (p * q) = q :=
  powerSum_factor_reveal hp hq (by omega) (not_dvd_pred_of_lt hp hlt)

/-! ## The first hit -/

/-- **First hit.**  `min (p-1) (q-1)` is the least positive exponent at which the gcd
differs from the trivial value `N = p*q`. -/
theorem first_hit_isLeast (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    IsLeast {k : ℕ | 0 < k ∧ Nat.gcd (powerSum (p * q) k) (p * q) ≠ p * q}
      (min (p - 1) (q - 1)) := by
  have h2 := hp.two_le
  have h3 := hq.two_le
  have hmin : 0 < min (p - 1) (q - 1) := by omega
  constructor
  · refine ⟨hmin, ?_⟩
    intro hcon
    rw [gcd_powerSum_eq_self_iff hp hq hpq hmin.ne'] at hcon
    rcases Nat.le_total (p - 1) (q - 1) with h | h
    · exact hcon.1 (by simp [min_eq_left h])
    · exact hcon.2 (by simp [min_eq_right h])
  · rintro k ⟨hk0, hk⟩
    rw [Ne, gcd_powerSum_eq_self_iff hp hq hpq hk0.ne'] at hk
    push_neg at hk
    by_cases hA : (p - 1) ∣ k
    · exact le_trans (min_le_left _ _) (Nat.le_of_dvd hk0 hA)
    · exact le_trans (min_le_right _ _) (Nat.le_of_dvd hk0 (hk hA))

/-- At the first hit the gcd is a *proper* divisor: neither `1` nor `N`. -/
theorem first_hit_proper (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    Nat.gcd (powerSum (p * q) (min (p - 1) (q - 1))) (p * q) = q := by
  have h2 := hp.two_le
  have hmin : min (p - 1) (q - 1) = p - 1 := min_eq_left (by omega)
  rw [hmin]
  exact powerSum_factor_reveal_of_lt hp hq hlt

/-- **`k* < √N`.**  The first hit happens below the square root of the modulus. -/
theorem first_hit_sq_le (hp : p.Prime) (hq : q.Prime) :
    (min (p - 1) (q - 1) + 1) ^ 2 ≤ p * q := by
  have h2 := hp.two_le
  have h3 := hq.two_le
  rcases Nat.le_total p q with h | h
  · have : min (p - 1) (q - 1) + 1 = p := by omega
    rw [this]
    nlinarith
  · have : min (p - 1) (q - 1) + 1 = q := by omega
    rw [this]
    nlinarith

/-! ## Density of revealing exponents inside one period -/

/-- The exponents in `(0, λ]` that reveal a proper factor are exactly those divisible by
exactly one of `p-1`, `q-1`. -/
theorem revealing_eq_sdiff_union (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    {k ∈ Finset.Ioc 0 (carmichael p q) |
        Nat.gcd (powerSum (p * q) k) (p * q) ≠ 1 ∧
          Nat.gcd (powerSum (p * q) k) (p * q) ≠ p * q}
      = ({x ∈ Finset.Ioc 0 (carmichael p q) | (p - 1) ∣ x} \
            {x ∈ Finset.Ioc 0 (carmichael p q) | (q - 1) ∣ x}) ∪
          ({x ∈ Finset.Ioc 0 (carmichael p q) | (q - 1) ∣ x} \
            {x ∈ Finset.Ioc 0 (carmichael p q) | (p - 1) ∣ x}) := by
  ext k
  simp only [Finset.mem_filter, Finset.mem_Ioc, Finset.mem_union, Finset.mem_sdiff,
    Finset.mem_filter]
  constructor
  · rintro ⟨hk, h1, h2⟩
    have hk0 : k ≠ 0 := by omega
    rw [Ne, gcd_powerSum_eq_one_iff hp hq hpq hk0, carmichael, Nat.lcm_dvd_iff] at h1
    rw [Ne, gcd_powerSum_eq_self_iff hp hq hpq hk0] at h2
    push_neg at h1 h2
    by_cases hA : (p - 1) ∣ k
    · exact Or.inl ⟨⟨hk, hA⟩, fun h => (h1 hA) h.2⟩
    · exact Or.inr ⟨⟨hk, h2 hA⟩, fun h => hA h.2⟩
  · intro h
    have hk : 0 < k ∧ k ≤ carmichael p q := by
      rcases h with ⟨h, -⟩ | ⟨h, -⟩ <;> exact h.1
    have hk0 : k ≠ 0 := by omega
    refine ⟨hk, ?_, ?_⟩
    · rw [Ne, gcd_powerSum_eq_one_iff hp hq hpq hk0, carmichael, Nat.lcm_dvd_iff]
      push_neg
      rcases h with ⟨⟨-, hA⟩, hB⟩ | ⟨⟨-, hB⟩, hA⟩
      · intro _; exact fun hb => hB ⟨hk, hb⟩
      · intro ha; exact absurd ⟨hk, ha⟩ hA
    · rw [Ne, gcd_powerSum_eq_self_iff hp hq hpq hk0]
      push_neg
      rcases h with ⟨⟨-, hA⟩, -⟩ | ⟨⟨-, hB⟩, -⟩
      · intro hcon; exact absurd hA hcon
      · intro _; exact hB

/-- Inside `(0, λ]` the multiples of `p-1` and of `q-1` meet only at `λ`. -/
theorem inter_multiples_eq_singleton (hp : p.Prime) (hq : q.Prime) :
    {x ∈ Finset.Ioc 0 (carmichael p q) | (p - 1) ∣ x} ∩
        {x ∈ Finset.Ioc 0 (carmichael p q) | (q - 1) ∣ x}
      = {carmichael p q} := by
  have hpos := carmichael_pos hp hq
  ext k
  simp only [Finset.mem_inter, Finset.mem_filter, Finset.mem_Ioc, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨⟨hk0, hkle⟩, hA⟩, ⟨-, hB⟩⟩
    have : carmichael p q ∣ k := Nat.lcm_dvd hA hB
    exact Nat.le_antisymm hkle (Nat.le_of_dvd hk0 this)
  · rintro rfl
    exact ⟨⟨⟨hpos, le_rfl⟩, dvd_carmichael_left⟩, ⟨⟨hpos, le_rfl⟩, dvd_carmichael_right⟩⟩

/-- **Density of revealing exponents.**  In one Carmichael period there are exactly
`λ/(p-1) + λ/(q-1) - 2` exponents that expose a proper factor of `N`. -/
theorem card_revealing_exponents (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    ({k ∈ Finset.Ioc 0 (carmichael p q) |
        Nat.gcd (powerSum (p * q) k) (p * q) ≠ 1 ∧
          Nat.gcd (powerSum (p * q) k) (p * q) ≠ p * q}).card
      = carmichael p q / (p - 1) + carmichael p q / (q - 1) - 2 := by
  classical
  have hA : ({x ∈ Finset.Ioc 0 (carmichael p q) | (p - 1) ∣ x}).card
      = carmichael p q / (p - 1) := Nat.Ioc_filter_dvd_card_eq_div _ _
  have hB : ({x ∈ Finset.Ioc 0 (carmichael p q) | (q - 1) ∣ x}).card
      = carmichael p q / (q - 1) := Nat.Ioc_filter_dvd_card_eq_div _ _
  set A := {x ∈ Finset.Ioc 0 (carmichael p q) | (p - 1) ∣ x} with hAdef
  set B := {x ∈ Finset.Ioc 0 (carmichael p q) | (q - 1) ∣ x} with hBdef
  have hinter : A ∩ B = {carmichael p q} := inter_multiples_eq_singleton hp hq
  have hinter' : B ∩ A = {carmichael p q} := by rw [Finset.inter_comm]; exact hinter
  have e1 : (A \ B).card + 1 = A.card := by
    have := Finset.card_sdiff_add_card_inter A B
    rwa [hinter, Finset.card_singleton] at this
  have e2 : (B \ A).card + 1 = B.card := by
    have := Finset.card_sdiff_add_card_inter B A
    rwa [hinter', Finset.card_singleton] at this
  have hdisj : Disjoint (A \ B) (B \ A) := disjoint_sdiff_sdiff
  rw [revealing_eq_sdiff_union hp hq hpq, ← hAdef, ← hBdef,
    Finset.card_union_of_disjoint hdisj]
  omega

end PowerSumReveal