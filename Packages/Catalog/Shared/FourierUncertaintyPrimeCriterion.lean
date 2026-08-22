/-
# The additive uncertainty principle characterises primality

`FourierCyclic.uncertainty_sum_zmod` proves the additive (Tao) uncertainty bound

  `|supp f| + |supp f̂| ≥ p + 1`

for `p` prime.  Here we show the converse: the bound **fails** for every composite modulus,
so it is not merely a theorem about primes but an exact characterisation of them.

The witness for a composite `n = d * e` (with `d, e ≥ 2`) is the indicator of the subgroup
`d · ZMod n`.  Its support has `e` elements, its Fourier transform is (a multiple of) the
indicator of the annihilator subgroup `e · ZMod n`, which has `d` elements, and
`d + e ≤ d * e = n < n + 1` precisely because `(d - 1)(e - 1) ≥ 1`.

Main results:

* `FourierCyclic.subgroupIndicator` : the indicator of `d · ZMod n`.
* `FourierCyclic.dftZMod_subgroupIndicator` : its Fourier transform.
* `FourierCyclic.uncertainty_sum_fails_of_composite` : failure for composite moduli.
* `FourierCyclic.uncertainty_sum_iff_prime` : the additive bound holds for all nonzero `f`
  iff the modulus is prime.
-/

import Mathlib
import Catalog.Shared.FourierCyclic
import Catalog.Shared.FourierUncertaintySum

open Finset FourierFA

namespace FourierCyclic

/-! ## The subgroup `d · ZMod n` and its indicator -/

/-- The indicator function of the subgroup `d · ZMod n ⊆ ZMod n`. -/
noncomputable def subgroupIndicator (n d : ℕ) : ZMod n → ℂ :=
  fun x => if d ∣ x.val then 1 else 0

/-- The set of elements of `ZMod n` divisible by `d`, when `n = d * e`, is the image of
`range e` under `j ↦ d * j`. -/
theorem filter_dvd_val_eq_image {n d e : ℕ} [NeZero n] (h : n = d * e) :
    Finset.univ.filter (fun x : ZMod n => d ∣ x.val)
      = (Finset.range e).image (fun j => ((d * j : ℕ) : ZMod n)) := by
  have hd : 0 < d := by
    rcases Nat.eq_zero_or_pos d with hd | hd
    · exact absurd h (by simp [hd, NeZero.ne n])
    · exact hd
  ext x
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image, Finset.mem_range]
  constructor
  · rintro ⟨c, hc⟩
    refine ⟨c, ?_, ?_⟩
    · have hlt : d * c < d * e := by
        rw [← hc, ← h]; exact ZMod.val_lt x
      exact lt_of_mul_lt_mul_left hlt (Nat.zero_le d)
    · rw [← hc]
      simp [ZMod.natCast_val, ZMod.cast_id]
  · rintro ⟨j, hj, rfl⟩
    have hlt : d * j < n := by
      rw [h]; exact Nat.mul_lt_mul_of_pos_left hj hd
    rw [ZMod.val_natCast_of_lt hlt]
    exact ⟨j, rfl⟩

/-- The map `j ↦ d * j` is injective from `range e` into `ZMod n` when `n = d * e`. -/
theorem injOn_mul_cast {n d e : ℕ} [NeZero n] (h : n = d * e) :
    Set.InjOn (fun j : ℕ => ((d * j : ℕ) : ZMod n)) (Finset.range e) := by
  have hd : 0 < d := by
    rcases Nat.eq_zero_or_pos d with hd | hd
    · exact absurd h (by simp [hd, NeZero.ne n])
    · exact hd
  intro i hi j hj hij
  simp only [Finset.coe_range, Set.mem_Iio] at hi hj
  have hli : d * i < n := by rw [h]; exact Nat.mul_lt_mul_of_pos_left hi hd
  have hlj : d * j < n := by rw [h]; exact Nat.mul_lt_mul_of_pos_left hj hd
  have : d * i = d * j := by
    have := congrArg ZMod.val hij
    rwa [ZMod.val_natCast_of_lt hli, ZMod.val_natCast_of_lt hlj] at this
  exact Nat.eq_of_mul_eq_mul_left hd this

/-- The support of the subgroup indicator has exactly `e` elements. -/
theorem supp_subgroupIndicator (n d : ℕ) [NeZero n] :
    supp (subgroupIndicator n d) = Finset.univ.filter (fun x : ZMod n => d ∣ x.val) := by
  ext x
  simp [supp, subgroupIndicator]

theorem card_supp_subgroupIndicator {n d e : ℕ} [NeZero n] (h : n = d * e) :
    (supp (subgroupIndicator n d)).card = e := by
  rw [supp_subgroupIndicator n d, filter_dvd_val_eq_image h,
    Finset.card_image_of_injOn (injOn_mul_cast h), Finset.card_range]

/-! ## The Fourier transform of the subgroup indicator -/

variable {n : ℕ} [NeZero n]

/-- `f̂(k) = ∑_{j < e} ω^j` with `ω = ζ^{k·d}`. -/
theorem dftZMod_subgroupIndicator_eq_geom {d e : ℕ} (h : n = d * e) (k : ZMod n) :
    dftZMod (subgroupIndicator n d) k = ∑ j ∈ Finset.range e, (zetaNeg n ^ (k.val * d)) ^ j := by
  have hd : 0 < d := by
    rcases Nat.eq_zero_or_pos d with hd | hd
    · exact absurd h (by simp [hd, NeZero.ne n])
    · exact hd
  rw [dftZMod_eq_sum_finset (subgroupIndicator n d) k
      (S := Finset.univ.filter (fun x : ZMod n => d ∣ x.val))
      (le_of_eq (supp_subgroupIndicator n d))]
  rw [filter_dvd_val_eq_image h, Finset.sum_image (fun i hi j hj hij => injOn_mul_cast h hi hj hij)]
  refine Finset.sum_congr rfl fun j hj => ?_
  have hj' : j < e := Finset.mem_range.1 hj
  have hlt : d * j < n := by rw [h]; exact Nat.mul_lt_mul_of_pos_left hj' hd
  rw [ZMod.val_natCast_of_lt hlt]
  have hdvd : d ∣ d * j := ⟨j, rfl⟩
  simp only [subgroupIndicator, ZMod.val_natCast_of_lt hlt, hdvd, if_pos, mul_one]
  rw [← pow_mul]
  ring_nf

/-- `ζ^{k·d} = 1` exactly when `e ∣ k`. -/
theorem zetaNeg_pow_eq_one_iff {d e : ℕ} (h : n = d * e) (k : ZMod n) :
    zetaNeg n ^ (k.val * d) = 1 ↔ e ∣ k.val := by
  have hd : 0 < d := by
    rcases Nat.eq_zero_or_pos d with hd | hd
    · exact absurd h (by simp [hd, NeZero.ne n])
    · exact hd
  rw [(zetaNeg_isPrimitiveRoot (Nat.pos_of_ne_zero (NeZero.ne n))).pow_eq_one_iff_dvd]
  constructor
  · rintro ⟨c, hc⟩
    refine ⟨c, ?_⟩
    have hn' : n * c = d * (e * c) := by rw [h]; ring
    have h2 : d * k.val = d * (e * c) := by rw [mul_comm]; exact hc.trans hn'
    exact Nat.eq_of_mul_eq_mul_left hd h2
  · rintro ⟨c, hc⟩
    have hn2 : ∀ v : ℕ, n * v = d * (e * v) := fun v => by rw [h]; ring
    exact ⟨c, by rw [hn2, hc]; ring⟩

/-- The Fourier transform of the subgroup indicator is `e` on the annihilator and `0` elsewhere. -/
theorem dftZMod_subgroupIndicator {d e : ℕ} (h : n = d * e) (k : ZMod n) :
    dftZMod (subgroupIndicator n d) k = if e ∣ k.val then (e : ℂ) else 0 := by
  rw [dftZMod_subgroupIndicator_eq_geom h k]
  set w : ℂ := zetaNeg n ^ (k.val * d) with hw
  by_cases hcase : e ∣ k.val
  · have hw1 : w = 1 := (zetaNeg_pow_eq_one_iff h k).2 hcase
    simp [hw1, hcase]
  · have hw1 : w ≠ 1 := fun hc => hcase ((zetaNeg_pow_eq_one_iff h k).1 hc)
    have hwe : w ^ e = 1 := by
      rw [hw, ← pow_mul]
      have key : ∀ v : ℕ, v * d * e = n * v := fun v => by rw [h]; ring
      rw [key k.val, pow_mul, (zetaNeg_isPrimitiveRoot (Nat.pos_of_ne_zero (NeZero.ne n))).pow_eq_one,
        one_pow]
    rw [geom_sum_eq hw1, hwe, sub_self, zero_div, if_neg hcase]

/-- The Fourier support of the subgroup indicator has exactly `d` elements. -/
theorem card_supp_dft_subgroupIndicator {d e : ℕ} (h : n = d * e) (he : 0 < e) :
    (supp (dftZMod (subgroupIndicator n d))).card = d := by
  have hcast : (e : ℂ) ≠ 0 := Nat.cast_ne_zero.2 he.ne'
  have hset : supp (dftZMod (subgroupIndicator n d))
      = Finset.univ.filter (fun k : ZMod n => e ∣ k.val) := by
    ext k
    simp [supp, dftZMod_subgroupIndicator h k, hcast]
  rw [hset]
  have h' : n = e * d := by rw [h]; ring
  rw [filter_dvd_val_eq_image h', Finset.card_image_of_injOn (injOn_mul_cast h'),
    Finset.card_range]

/-! ## Failure of the additive bound for composite moduli -/

/-- For a composite modulus `n = d * e` with `d, e ≥ 2`, the subgroup indicator is a nonzero
function with `|supp f| + |supp f̂| = d + e ≤ n < n + 1`, so the additive uncertainty
principle fails. -/
theorem uncertainty_sum_fails_of_composite {d e : ℕ} (h : n = d * e) (hd : 2 ≤ d) (he : 2 ≤ e) :
    subgroupIndicator n d ≠ 0 ∧
      (supp (subgroupIndicator n d)).card + (supp (dftZMod (subgroupIndicator n d))).card < n + 1 := by
  have hne : subgroupIndicator n d ≠ 0 := by
    intro hzero
    have h0 : subgroupIndicator n d (0 : ZMod n) = 0 := by rw [hzero]; rfl
    simp [subgroupIndicator, ZMod.val_zero] at h0
  refine ⟨hne, ?_⟩
  rw [card_supp_subgroupIndicator (e := e) h,
    card_supp_dft_subgroupIndicator h (by omega)]
  have hprod : d + e ≤ d * e := by nlinarith
  omega

/-- **The additive uncertainty principle characterises primality.**  For `n ≥ 2`, the bound
`|supp f| + |supp f̂| ≥ n + 1` holds for every nonzero `f : ZMod n → ℂ` if and only if `n` is
prime.  (The multiplicative bound `|supp f| · |supp f̂| ≥ n` holds for every modulus, so this
is a genuine separation between the two uncertainty principles.) -/
theorem uncertainty_sum_iff_prime (hn : 2 ≤ n) :
    (∀ f : ZMod n → ℂ, f ≠ 0 → n + 1 ≤ (supp f).card + (supp (dftZMod f)).card) ↔ n.Prime := by
  constructor
  · intro hbound
    by_contra hnp
    obtain ⟨d, hdvd, hd2, hdn⟩ := Nat.exists_dvd_of_not_prime2 hn hnp
    obtain ⟨e, he⟩ := hdvd
    have he2 : 2 ≤ e := by
      rcases Nat.lt_or_ge e 2 with h1 | h1
      · interval_cases e <;> omega
      · exact h1
    obtain ⟨hne, hlt⟩ := uncertainty_sum_fails_of_composite he hd2 he2
    exact absurd (hbound _ hne) (by omega)
  · intro hp f hf
    exact uncertainty_sum_zmod hp f hf

end FourierCyclic