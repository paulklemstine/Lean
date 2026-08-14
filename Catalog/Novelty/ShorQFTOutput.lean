import Novelty.ShorCombState

/-! # The QFT output of the comb: exactly `r` flat peaks, and why truncation fails

This file computes the *output* of the quantum Fourier transform on the periodic
comb `[x ≡ x₀ mod r]` of a register of size `Q = r * m`, and derives the
sampling-level obstruction to any classical emulation that keeps only
polynomially many amplitudes.

Main results:

* `combDFT_eq` : the Fourier sum of the comb,
  `∑_{t<m} ζ_Q^{(j + r t) y} = m ζ_Q^{j y}` if `m ∣ y` and `0` otherwise:
  the output is supported on the `r` multiples of `m = Q / r` and nowhere else;
* `norm_combDFT` : all `r` surviving amplitudes have the *same* modulus `m` —
  the output comb is flat, not "nearly a single basis state";
* `qftCombProb_apply` and `sum_qftCombProb` : the measured output distribution
  is uniform on those `r` frequencies;
* `tvDist_ge_sum_sub` and `tvDist_qftComb_ge` : **any** classical sampler whose
  output distribution is supported on a set `S` differs from the ideal Shor
  output distribution in total variation by at least `1 - |S| / r`; with
  `2 * |S| ≤ r` the distance is at least `1/2`
  (`tvDist_qftComb_ge_half`).  A truncated emulation fails catastrophically
  rather than approximately.
-/

open Finset
open scoped Real

namespace ShorIrreducible

/-! ## The Fourier transform of a comb -/

/-- The standard primitive `n`-th root of unity. -/
noncomputable def zeta (n : ℕ) : ℂ := Complex.exp (2 * ↑Real.pi * Complex.I / n)

lemma isPrimitiveRoot_zeta {n : ℕ} (hn : n ≠ 0) : IsPrimitiveRoot (zeta n) n :=
  Complex.isPrimitiveRoot_exp n hn

lemma zeta_pow_eq_one {n : ℕ} (hn : n ≠ 0) : zeta n ^ n = 1 :=
  (isPrimitiveRoot_zeta hn).pow_eq_one

/-- Raising the `Q`-th root of unity to the power `r` gives the `m`-th root,
where `Q = r * m`. -/
lemma zeta_pow_block {r m : ℕ} (hr : r ≠ 0) : zeta (r * m) ^ r = zeta m := by
  rw [zeta, zeta, ← Complex.exp_nat_mul]
  congr 1
  have hrC : (r : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hr
  push_cast
  field_simp

/-- The Fourier sum of the comb `{ j + r t : t < m }` at frequency `y`. -/
noncomputable def combDFT (r m j y : ℕ) : ℂ :=
  ∑ t ∈ Finset.range m, zeta (r * m) ^ ((j + r * t) * y)

/-- **The Fourier transform of a periodic comb is a periodic comb.**  The
amplitude vanishes unless the frequency is a multiple of `m = Q / r`, and on
each of those `r` frequencies it has modulus `m`. -/
theorem combDFT_eq {r m j y : ℕ} (hr : r ≠ 0) (hm : m ≠ 0) :
    combDFT r m j y = if m ∣ y then (m : ℂ) * zeta (r * m) ^ (j * y) else 0 := by
  have hsplit : ∀ t ∈ Finset.range m,
      zeta (r * m) ^ ((j + r * t) * y) = zeta (r * m) ^ (j * y) * (zeta m ^ y) ^ t := by
    intro t _
    rw [← zeta_pow_block (m := m) hr, ← pow_mul, ← pow_mul, ← pow_add]
    congr 1
    ring
  rw [combDFT, Finset.sum_congr rfl hsplit, ← Finset.mul_sum]
  by_cases hdvd : m ∣ y
  · have hone : zeta m ^ y = 1 := by
      obtain ⟨k, rfl⟩ := hdvd
      rw [pow_mul, zeta_pow_eq_one hm, one_pow]
    rw [hone, if_pos hdvd]
    simp [mul_comm]
  · have hne : zeta m ^ y ≠ 1 := fun hcon =>
      hdvd (((isPrimitiveRoot_zeta hm).pow_eq_one_iff_dvd y).mp hcon)
    have hgeom : (∑ t ∈ Finset.range m, (zeta m ^ y) ^ t) = 0 := by
      have hmul := geom_sum_mul (x := zeta m ^ y) (n := m)
      have hzero : (zeta m ^ y) ^ m - 1 = 0 := by
        rw [← pow_mul, mul_comm y m, pow_mul, zeta_pow_eq_one hm, one_pow, sub_self]
      rw [hzero] at hmul
      rcases mul_eq_zero.mp hmul with h | h
      · exact h
      · exact absurd (sub_eq_zero.mp h) hne
    rw [hgeom, if_neg hdvd, mul_zero]

/-- All surviving output amplitudes have the same modulus: the QFT output of a
comb is *flat*. -/
theorem norm_combDFT {r m j y : ℕ} (hr : r ≠ 0) (hm : m ≠ 0) :
    ‖combDFT r m j y‖ = if m ∣ y then (m : ℝ) else 0 := by
  have hQ : r * m ≠ 0 := Nat.mul_ne_zero hr hm
  have hunit : ‖zeta (r * m) ^ (j * y)‖ = 1 := by
    rw [norm_pow, (isPrimitiveRoot_zeta hQ).norm'_eq_one hQ, one_pow]
  rw [combDFT_eq hr hm]
  by_cases hdvd : m ∣ y
  · rw [if_pos hdvd, if_pos hdvd, norm_mul, hunit, mul_one, Complex.norm_natCast]
  · rw [if_neg hdvd, if_neg hdvd, norm_zero]

/-! ## The output distribution of Shor's algorithm -/

/-- The measurement distribution of the QFT output of the comb: uniform on the
`r` multiples of `m = Q / r`. -/
noncomputable def qftCombProb (r m : ℕ) : ℕ → ℝ := fun y => if m ∣ y then (r : ℝ)⁻¹ else 0

/-- The probability of the frequency `y` is the squared modulus of the
normalized output amplitude `(r m²)^{-1/2} · combDFT`. -/
theorem qftCombProb_apply {r m j y : ℕ} (hr : r ≠ 0) (hm : m ≠ 0) :
    ((Real.sqrt ((r : ℝ) * m * m))⁻¹ * ‖combDFT r m j y‖) ^ 2 = qftCombProb r m y := by
  have hrpos : (0 : ℝ) < r := by
    exact_mod_cast Nat.pos_of_ne_zero hr
  have hmpos : (0 : ℝ) < m := by
    exact_mod_cast Nat.pos_of_ne_zero hm
  have hprod : (0 : ℝ) < (r : ℝ) * m * m := by positivity
  rw [norm_combDFT hr hm, qftCombProb]
  by_cases hdvd : m ∣ y
  · rw [if_pos hdvd, if_pos hdvd, mul_pow, inv_pow, Real.sq_sqrt hprod.le]
    field_simp
  · rw [if_neg hdvd, if_neg hdvd, mul_zero]
    ring

/-- There are exactly `r` frequencies below `Q = r * m` that are multiples of
`m`. -/
lemma card_multiples_range {r m : ℕ} (hm : 0 < m) :
    ((Finset.range (r * m)).filter fun y => m ∣ y).card = r := by
  classical
  have himg : ((Finset.range (r * m)).filter fun y => m ∣ y)
      = (Finset.range r).image (fun k => m * k) := by
    ext y
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_image]
    constructor
    · rintro ⟨hy, k, rfl⟩
      refine ⟨k, ?_, rfl⟩
      by_contra hk
      push_neg at hk
      have : r * m ≤ m * k := by
        calc r * m = m * r := by ring
          _ ≤ m * k := Nat.mul_le_mul_left m hk
      omega
    · rintro ⟨k, hk, rfl⟩
      refine ⟨?_, ⟨k, rfl⟩⟩
      calc m * k < m * r := by
            exact mul_lt_mul_of_pos_left hk hm
        _ = r * m := by ring
  rw [himg, Finset.card_image_of_injective _ (fun a b hab => Nat.eq_of_mul_eq_mul_left hm hab),
    Finset.card_range]

/-- The output distribution is a probability distribution: exactly `r` peaks of
weight `1 / r`. -/
theorem sum_qftCombProb {r m : ℕ} (hr : 0 < r) (hm : 0 < m) :
    ∑ y ∈ Finset.range (r * m), qftCombProb r m y = 1 := by
  classical
  simp only [qftCombProb]
  rw [← Finset.sum_filter, Finset.sum_const, card_multiples_range hm, nsmul_eq_mul]
  have : (r : ℝ) ≠ 0 := by exact_mod_cast hr.ne'
  field_simp

/-! ## Total-variation failure of any small-support sampler -/

/-- Total variation distance between two mass functions on a finite type. -/
noncomputable def tvDist {ι : Type*} [Fintype ι] (p q : ι → ℝ) : ℝ :=
  (1 / 2) * ∑ i, |p i - q i|

/-- The total variation distance dominates the discrepancy on every event. -/
theorem tvDist_ge_sum_sub {ι : Type*} [Fintype ι] [DecidableEq ι] {p q : ι → ℝ}
    (hp : ∑ i, p i = 1) (hq : ∑ i, q i = 1) (A : Finset ι) :
    ∑ i ∈ A, (p i - q i) ≤ tvDist p q := by
  classical
  have hzero : ∑ i, (p i - q i) = 0 := by
    rw [Finset.sum_sub_distrib, hp, hq, sub_self]
  have hsplit : ∑ i ∈ A, (p i - q i) + ∑ i ∈ Aᶜ, (p i - q i) = 0 := by
    rw [Finset.sum_add_sum_compl A (fun i => p i - q i)]
    exact hzero
  have h1 : ∑ i ∈ A, (p i - q i) ≤ ∑ i ∈ A, |p i - q i| :=
    Finset.sum_le_sum fun i _ => le_abs_self _
  have h2 : -∑ i ∈ Aᶜ, (p i - q i) ≤ ∑ i ∈ Aᶜ, |p i - q i| := by
    rw [← Finset.sum_neg_distrib]
    exact Finset.sum_le_sum fun i _ => neg_le_abs _
  have h3 : ∑ i ∈ A, |p i - q i| + ∑ i ∈ Aᶜ, |p i - q i| = ∑ i, |p i - q i| :=
    Finset.sum_add_sum_compl A _
  rw [tvDist]
  linarith

/-- The `r` peak frequencies, as a subset of the register. -/
noncomputable def peakSet (r m : ℕ) : Finset (Fin (r * m)) :=
  (univ : Finset (Fin (r * m))).filter fun y => m ∣ (y : ℕ)

lemma card_peakSet {r m : ℕ} (hm : 0 < m) : (peakSet r m).card = r := by
  classical
  have himg : (peakSet r m).image (fun y : Fin (r * m) => (y : ℕ))
      = (Finset.range (r * m)).filter fun y => m ∣ y := by
    ext y
    simp only [peakSet, Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and,
      Finset.mem_range]
    constructor
    · rintro ⟨z, hz, rfl⟩
      exact ⟨z.isLt, hz⟩
    · rintro ⟨hy, hdvd⟩
      exact ⟨⟨y, hy⟩, hdvd, rfl⟩
  rw [← Finset.card_image_of_injective _ (Fin.val_injective), himg, card_multiples_range hm]

/-- **Every small-support classical sampler is far from Shor's output
distribution.**  If a purported classical emulation only ever outputs
frequencies in a set `S`, its total variation distance from the ideal QFT output
distribution is at least `1 - |S| / r`. -/
theorem tvDist_qftComb_ge {r m : ℕ} (hr : 0 < r) (hm : 0 < m) (q : Fin (r * m) → ℝ)
    (hq : ∑ y, q y = 1) (S : Finset (Fin (r * m))) (hsupp : ∀ y ∉ S, q y = 0) :
    1 - (S.card : ℝ) / r ≤ tvDist (fun y : Fin (r * m) => qftCombProb r m (y : ℕ)) q := by
  classical
  set p : Fin (r * m) → ℝ := fun y => qftCombProb r m (y : ℕ) with hp
  have hpsum : ∑ y, p y = 1 := by
    rw [hp, ← sum_qftCombProb hr hm, Fin.sum_univ_eq_sum_range (fun y => qftCombProb r m y)]
  set A : Finset (Fin (r * m)) := peakSet r m \ S with hA
  have hqA : ∀ y ∈ A, q y = 0 := by
    intro y hy
    exact hsupp y (Finset.mem_sdiff.mp hy).2
  have hpA : ∀ y ∈ A, p y = (r : ℝ)⁻¹ := by
    intro y hy
    have := (Finset.mem_filter.mp (Finset.mem_sdiff.mp hy).1).2
    rw [hp]
    simp only [qftCombProb, if_pos this]
  have hsum : ∑ y ∈ A, (p y - q y) = (A.card : ℝ) * (r : ℝ)⁻¹ := by
    rw [Finset.sum_congr rfl (fun y hy => by rw [hpA y hy, hqA y hy, sub_zero]),
      Finset.sum_const, nsmul_eq_mul]
  have hcard : (r : ℝ) ≤ (A.card : ℝ) + (S.card : ℝ) := by
    have hnat : r ≤ A.card + S.card := by
      calc r = (peakSet r m).card := (card_peakSet hm).symm
        _ ≤ (peakSet r m \ S).card + S.card := Finset.card_le_card_sdiff_add_card
        _ = A.card + S.card := by rw [hA]
    exact_mod_cast hnat
  have hrpos : (0 : ℝ) < r := by exact_mod_cast hr
  have hkey : 1 - (S.card : ℝ) / r ≤ ∑ y ∈ A, (p y - q y) := by
    rw [hsum, ← div_eq_mul_inv, le_div_iff₀ hrpos, sub_mul, one_mul,
      div_mul_cancel₀ _ hrpos.ne']
    linarith
  exact le_trans hkey (tvDist_ge_sum_sub hpsum hq A)

/-- **Catastrophic, not approximate, failure.**  A sampler supported on at most
`r / 2` frequencies is at total variation distance at least `1/2` from Shor's
output distribution — the "TV ≈ 0.5" regime.  For factoring-relevant orders `r`
this rules out every emulation with a polynomially bounded output support. -/
theorem tvDist_qftComb_ge_half {r m : ℕ} (hr : 0 < r) (hm : 0 < m) (q : Fin (r * m) → ℝ)
    (hq : ∑ y, q y = 1) (S : Finset (Fin (r * m))) (hsupp : ∀ y ∉ S, q y = 0)
    (hS : 2 * S.card ≤ r) :
    1 / 2 ≤ tvDist (fun y : Fin (r * m) => qftCombProb r m (y : ℕ)) q := by
  have hrpos : (0 : ℝ) < r := by exact_mod_cast hr
  have hS' : 2 * (S.card : ℝ) ≤ (r : ℝ) := by exact_mod_cast hS
  have hd : (S.card : ℝ) / r ≤ 1 / 2 := by
    rw [div_le_iff₀ hrpos]
    linarith
  have hstep : (1 : ℝ) / 2 ≤ 1 - (S.card : ℝ) / r := by linarith
  exact le_trans hstep (tvDist_qftComb_ge hr hm q hq S hsupp)

end ShorIrreducible