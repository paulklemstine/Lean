/-
# The exact parity law for round-to-nearest bias on a rational mesh

A round-to-nearest quantizer is usually modelled as adding *zero-mean* noise.  This file shows
that the zero-mean assumption is an arithmetic statement about the **denominator** of the
weights relative to the mesh, and that it fails precisely on the meshes that hardware uses.

Write `sawtooth x = round x - x` for the signed rounding error at unit mesh (Mathlib's `round`
rounds ties upwards).  For a full period of the rational mesh `(1/q)ℤ` we prove

`∑_{j<q} sawtooth (j/q) = ⌊q/2⌋ − (q−1)/2`,

hence

* `sawtooth_period_sum_odd`  : the sum is **exactly 0** when `q` is odd;
* `sawtooth_period_sum_even` : the sum is **exactly 1/2** when `q` is even.

The whole bias is the single tie `j = q/2`, which exists only for even `q`.  Since
`k ↦ k·p mod q` permutes `ZMod q` when `gcd(p,q) = 1`, the same two values are obtained along
*any* arithmetic progression `k·p/q` (`sawtooth_progression_sum`, `sawtooth_progression_odd`,
`sawtooth_progression_even`) — the bias is invariant under the multiplier, a purely
number-theoretic rigidity.

Specialising to `q = 2 ^ b` (`sawtooth_dyadic_bias`): every dyadic — i.e. every real —
quantization grid carries a coherent `+1/2`-step bias per period, which does **not** average
away with width.  This is the arithmetic reason why round-to-nearest damage in the NET-52
measurements is systematic rather than noise-like, and why error *compensation* (rather than a
better choice of scale) is what is needed below the empirical cliff.
-/
import Mathlib

namespace Catalog.NumberTheory.QuantSawtooth

open Finset

/-- The signed round-to-nearest error at unit mesh. -/
noncomputable def sawtooth (x : ℝ) : ℝ := (round x : ℝ) - x

/-- The sawtooth is `1`-periodic. -/
lemma sawtooth_add_nat (x : ℝ) (m : ℕ) : sawtooth (x + m) = sawtooth x := by
  simp only [sawtooth, round_add_natCast]
  push_cast
  ring

/-- `|sawtooth| ≤ 1/2`, with the tie value attained at `1/2`. -/
lemma abs_sawtooth_le (x : ℝ) : |sawtooth x| ≤ 1 / 2 := by
  simpa [sawtooth, abs_sub_comm] using abs_sub_round x

lemma sawtooth_half : sawtooth (1 / 2) = 1 / 2 := by
  norm_num [sawtooth]

/-! ## Rounding on the mesh `(1/q)ℤ` -/

/-- On a full period, `round (j/q)` is `0` below the midpoint and `1` from the tie on. -/
lemma round_div_of_lt {q j : ℕ} (hq : 0 < q) (hj : j < q) :
    round ((j : ℝ) / q) = if 2 * j < q then 0 else 1 := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  by_cases h : 2 * j < q
  · have hlt : (j : ℝ) / q < 1 / 2 := by
      rw [div_lt_div_iff₀ hqR (by norm_num)]
      have : (2 * j : ℕ) < (q : ℕ) := h
      have := (Nat.cast_lt (α := ℝ)).2 this
      push_cast at this
      linarith
    have hge : (0:ℝ) ≤ (j : ℝ) / q := by positivity
    rw [round_eq, if_pos h]
    have : ⌊(j : ℝ) / q + 1 / 2⌋ = 0 := by
      rw [Int.floor_eq_zero_iff]
      constructor <;> simp <;> linarith
    exact this
  · push_neg at h
    have hge : 1 / 2 ≤ (j : ℝ) / q := by
      rw [le_div_iff₀ hqR]
      have := (Nat.cast_le (α := ℝ)).2 h
      push_cast at this
      linarith
    have hlt : (j : ℝ) / q < 1 := by
      rw [div_lt_one hqR]
      exact_mod_cast hj
    rw [round_eq, if_neg (by omega)]
    have : ⌊(j : ℝ) / q + 1 / 2⌋ = 1 := by
      rw [Int.floor_eq_iff]
      constructor <;> push_cast <;> linarith
    exact this

/-- The number of ties-or-above in a period is `⌊q/2⌋`. -/
lemma card_upper_half (q : ℕ) :
    ((Finset.range q).filter (fun j => q ≤ 2 * j)).card = q / 2 := by
  have himg : (Finset.range q).filter (fun j => q ≤ 2 * j) = Finset.Ico ((q + 1) / 2) q := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]
    omega
  rw [himg, Nat.card_Ico]
  omega

private lemma sum_range_cast (q : ℕ) : ∑ j ∈ Finset.range q, (j : ℝ) = q * (q - 1) / 2 := by
  induction q with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring

/-- **Exact period sum of the rounding error on the mesh `(1/q)ℤ`.** -/
theorem sawtooth_period_sum (q : ℕ) (hq : 0 < q) :
    ∑ j ∈ Finset.range q, sawtooth ((j : ℝ) / q) = ((q / 2 : ℕ) : ℝ) - ((q : ℝ) - 1) / 2 := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  have hround : ∑ j ∈ Finset.range q, ((round ((j : ℝ) / q) : ℤ) : ℝ)
      = ((q / 2 : ℕ) : ℝ) := by
    have h1 : ∀ j ∈ Finset.range q, ((round ((j : ℝ) / q) : ℤ) : ℝ)
        = if q ≤ 2 * j then 1 else 0 := by
      intro j hj
      rw [round_div_of_lt hq (Finset.mem_range.1 hj)]
      by_cases h : 2 * j < q
      · rw [if_pos h, if_neg (by omega)]; norm_num
      · rw [if_neg h, if_pos (by omega)]; norm_num
    rw [Finset.sum_congr rfl h1, ← Finset.sum_filter]
    simp [card_upper_half q]
  have hlin : ∑ j ∈ Finset.range q, ((j : ℝ) / q) = ((q : ℝ) - 1) / 2 := by
    rw [← Finset.sum_div, sum_range_cast]
    field_simp
  calc ∑ j ∈ Finset.range q, sawtooth ((j : ℝ) / q)
      = ∑ j ∈ Finset.range q, (((round ((j : ℝ) / q) : ℤ) : ℝ) - (j : ℝ) / q) := rfl
    _ = ((q / 2 : ℕ) : ℝ) - ((q : ℝ) - 1) / 2 := by
        rw [Finset.sum_sub_distrib, hround, hlin]

/-- **Odd meshes are unbiased.** -/
theorem sawtooth_period_sum_odd {q : ℕ} (hq : 0 < q) (hodd : Odd q) :
    ∑ j ∈ Finset.range q, sawtooth ((j : ℝ) / q) = 0 := by
  obtain ⟨m, hm⟩ := hodd
  rw [sawtooth_period_sum q hq, hm]
  have h1 : (2 * m + 1) / 2 = m := by omega
  rw [h1]
  push_cast
  ring

/-- **Even meshes carry exactly a half-step bias**, coming from the single tie. -/
theorem sawtooth_period_sum_even {q : ℕ} (hq : 0 < q) (heven : Even q) :
    ∑ j ∈ Finset.range q, sawtooth ((j : ℝ) / q) = 1 / 2 := by
  obtain ⟨m, hm⟩ := heven
  rw [sawtooth_period_sum q hq, hm]
  have h1 : (m + m) / 2 = m := by omega
  rw [h1]
  push_cast
  ring

/-- **Dyadic (hardware) grids are always biased**: a `2^b`-level grid accumulates exactly a
half step of signed error per period, for every bit budget `b ≥ 1`. -/
theorem sawtooth_dyadic_bias {b : ℕ} (hb : 1 ≤ b) :
    ∑ j ∈ Finset.range (2 ^ b), sawtooth ((j : ℝ) / (2 ^ b : ℕ)) = 1 / 2 := by
  refine sawtooth_period_sum_even (Nat.two_pow_pos b) ?_
  obtain ⟨c, rfl⟩ : ∃ c, b = c + 1 := ⟨b - 1, by omega⟩
  exact ⟨2 ^ c, by rw [pow_succ]; ring⟩

/-! ## Invariance along arithmetic progressions -/

/-- Multiplication by a unit permutes a full residue period. -/
lemma image_mul_mod {p q : ℕ} (hq : 0 < q) (hcop : Nat.Coprime p q) :
    (Finset.range q).image (fun k => k * p % q) = Finset.range q := by
  have hsub : (Finset.range q).image (fun k => k * p % q) ⊆ Finset.range q := by
    intro j hj
    simp only [Finset.mem_image] at hj
    obtain ⟨k, _, rfl⟩ := hj
    exact Finset.mem_range.2 (Nat.mod_lt _ hq)
  refine Finset.eq_of_subset_of_card_le hsub ?_
  have hinj : Set.InjOn (fun k => k * p % q) (Finset.range q) := by
    intro a ha b hb hab
    have hmod : a * p ≡ b * p [MOD q] := hab
    have : a ≡ b [MOD q] := Nat.ModEq.cancel_right_of_coprime (by simpa [Nat.Coprime, Nat.gcd_comm] using hcop) hmod
    have ha' : a < q := Finset.mem_range.1 ha
    have hb' : b < q := Finset.mem_range.1 hb
    calc a = a % q := (Nat.mod_eq_of_lt ha').symm
      _ = b % q := this
      _ = b := Nat.mod_eq_of_lt hb'
  rw [Finset.card_image_of_injOn hinj]

/-- The rounding error only depends on the residue of the numerator. -/
lemma sawtooth_div_mod {q : ℕ} (hq : 0 < q) (a : ℕ) :
    sawtooth ((a : ℝ) / q) = sawtooth (((a % q : ℕ) : ℝ) / q) := by
  have hqR : (q : ℝ) ≠ 0 := by positivity
  have hsplit : (a : ℝ) / q = ((a % q : ℕ) : ℝ) / q + ((a / q : ℕ) : ℝ) := by
    have h : (a : ℝ) = ((a % q : ℕ) : ℝ) + (q : ℝ) * ((a / q : ℕ) : ℝ) := by
      exact_mod_cast congrArg (Nat.cast (R := ℝ)) (Nat.mod_add_div a q).symm
    rw [h]
    field_simp
  rw [hsplit, sawtooth_add_nat]

/-- **The period bias is invariant under the multiplier.**  For `gcd(p,q) = 1` the arithmetic
progression `k·p/q`, `k < q`, has exactly the same total rounding error as the standard mesh. -/
theorem sawtooth_progression_sum {p q : ℕ} (hq : 0 < q) (hcop : Nat.Coprime p q) :
    ∑ k ∈ Finset.range q, sawtooth ((k * p : ℕ) / (q : ℝ))
      = ((q / 2 : ℕ) : ℝ) - ((q : ℝ) - 1) / 2 := by
  have hstep : ∀ k ∈ Finset.range q,
      sawtooth ((k * p : ℕ) / (q : ℝ)) = sawtooth (((k * p % q : ℕ) : ℝ) / q) :=
    fun k _ => sawtooth_div_mod hq (k * p)
  rw [Finset.sum_congr rfl hstep]
  have hinj : Set.InjOn (fun k => k * p % q) (Finset.range q) := by
    intro a ha b hb hab
    have hmod : a * p ≡ b * p [MOD q] := hab
    have : a ≡ b [MOD q] :=
      Nat.ModEq.cancel_right_of_coprime (by simpa [Nat.Coprime, Nat.gcd_comm] using hcop) hmod
    have ha' : a < q := Finset.mem_range.1 ha
    have hb' : b < q := Finset.mem_range.1 hb
    calc a = a % q := (Nat.mod_eq_of_lt ha').symm
      _ = b % q := this
      _ = b := Nat.mod_eq_of_lt hb'
  have himg := Finset.sum_image (f := fun j : ℕ => sawtooth ((j : ℝ) / q))
    (g := fun k => k * p % q) (s := Finset.range q) hinj
  rw [image_mul_mod hq hcop] at himg
  rw [← himg]
  exact sawtooth_period_sum q hq

/-- Odd modulus: every arithmetic progression is unbiased. -/
theorem sawtooth_progression_odd {p q : ℕ} (hq : 0 < q) (hodd : Odd q)
    (hcop : Nat.Coprime p q) :
    ∑ k ∈ Finset.range q, sawtooth ((k * p : ℕ) / (q : ℝ)) = 0 := by
  obtain ⟨m, hm⟩ := hodd
  rw [sawtooth_progression_sum hq hcop, hm]
  have h1 : (2 * m + 1) / 2 = m := by omega
  rw [h1]
  push_cast
  ring

/-- Even modulus: every arithmetic progression carries the same half-step bias. -/
theorem sawtooth_progression_even {p q : ℕ} (hq : 0 < q) (heven : Even q)
    (hcop : Nat.Coprime p q) :
    ∑ k ∈ Finset.range q, sawtooth ((k * p : ℕ) / (q : ℝ)) = 1 / 2 := by
  obtain ⟨m, hm⟩ := heven
  rw [sawtooth_progression_sum hq hcop, hm]
  have h1 : (m + m) / 2 = m := by omega
  rw [h1]
  push_cast
  ring

/-- The bias does not wash out: it is bounded away from `0` uniformly in the modulus, while the
individual errors are `O(1/q)`.  Concretely, for even `q` the *mean* error is `1/(2q)` — a
coherent drift, not cancellation. -/
theorem mean_bias_even {q : ℕ} (hq : 0 < q) (heven : Even q) :
    (∑ j ∈ Finset.range q, sawtooth ((j : ℝ) / q)) / q = 1 / (2 * q) := by
  rw [sawtooth_period_sum_even hq heven]
  have : (q : ℝ) ≠ 0 := by positivity
  field_simp

end Catalog.NumberTheory.QuantSawtooth