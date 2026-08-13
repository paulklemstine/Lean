import Pythagorean.FactoringBarriers.Dequant.TotalVariation

/-!
# Barrier IV, part 2: the comb, its spectrum, and its incompressibility

Shor's algorithm prepares (after measuring the second register) the *comb*
supported on an arithmetic progression of spacing `r` inside `{0, …, Q-1}`.  This
file computes its discrete Fourier transform exactly and derives the structural
facts on which every de-quantization attempt founders.

Main results.

* `Dequant.combSum_eq_ite` — **exact spectrum**: for `r ∣ Q`,
  `∑_{j < Q/r} e(2πi j r y / Q) = Q/r` if `(Q/r) ∣ y` and `0` otherwise.  The
  informative frequencies are exactly the multiples of `Q/r`.
* `Dequant.card_peaks` — there are exactly `r` such frequencies in `{0, …, Q-1}`:
  the number of peaks *is* the hidden parameter.
* `Dequant.combDist` / `Dequant.combDist_eq_normalized_spectrum` — the induced
  output distribution is *flat*: mass `1/r` on each peak, and it is literally the
  normalised squared spectrum.
* `Dequant.combDist_entropy` — the flat spectrum has Shannon entropy `log r`:
  the comb carries `log r` nats and no less.
* `Dequant.sparse_approx_lower_bound` — **incompressibility**: any distribution
  supported on `k` outcomes is at total variation `≥ 1 - k/r` from the comb.  A
  poly-size sparse/low-rank surrogate (`k = poly log N ≪ r`) is at distance
  `1 - o(1)`.
* `Dequant.peaks_disjoint_of_coprime` and `Dequant.no_order_free_sampler` — **no
  `r`-free classical sampler**: for `k` pairwise coprime candidate orders `≥ R`,
  every single distribution is at total variation `≥ 1 - 1/R - 1/k` from one of the
  candidate output distributions.
-/

namespace Dequant

open Finset

/-! ### Roots of unity -/

/-- `e(2πi k / m) = 1` exactly when `m ∣ k`. -/
theorem exp_eq_one_iff_dvd (m k : ℕ) (hm : 0 < m) :
    Complex.exp (2 * Real.pi * Complex.I * k / m) = 1 ↔ m ∣ k := by
  have hm' : (m : ℂ) ≠ 0 := by exact_mod_cast hm.ne'
  have hpi : (Real.pi : ℂ) ≠ 0 := by exact_mod_cast Real.pi_ne_zero
  rw [Complex.exp_eq_one_iff]
  constructor
  · rintro ⟨n, hn⟩
    field_simp at hn
    have h3 : (k : ℤ) = m * n := by exact_mod_cast hn
    exact Int.ofNat_dvd.mp ⟨n, h3⟩
  · rintro ⟨c, rfl⟩
    exact ⟨c, by push_cast; field_simp⟩

/-- The complete geometric sum of `m`-th roots of unity: `m` if the frequency is a
multiple of `m`, and `0` otherwise. -/
theorem root_of_unity_sum (m k : ℕ) (hm : 0 < m) :
    ∑ j ∈ Finset.range m, Complex.exp (2 * Real.pi * Complex.I * (j * k) / m)
      = if m ∣ k then (m : ℂ) else 0 := by
  have hm' : (m : ℂ) ≠ 0 := by exact_mod_cast hm.ne'
  set z : ℂ := Complex.exp (2 * Real.pi * Complex.I * k / m) with hz
  have hpow : ∀ j : ℕ, z ^ j = Complex.exp (2 * Real.pi * Complex.I * (j * k) / m) := by
    intro j
    rw [hz, ← Complex.exp_nat_mul]
    ring_nf
  have hsum : ∑ j ∈ Finset.range m, Complex.exp (2 * Real.pi * Complex.I * (j * k) / m)
      = ∑ j ∈ Finset.range m, z ^ j :=
    Finset.sum_congr rfl fun j _ => (hpow j).symm
  rw [hsum]
  by_cases h : m ∣ k
  · have hz1 : z = 1 := (exp_eq_one_iff_dvd m k hm).mpr h
    simp [hz1, h]
  · have hz1 : z ≠ 1 := fun hc => h ((exp_eq_one_iff_dvd m k hm).mp hc)
    have hzm : z ^ m = 1 := by
      rw [hz, ← Complex.exp_nat_mul]
      have hrw : (m : ℂ) * (2 * Real.pi * Complex.I * k / m)
          = (k : ℂ) * (2 * Real.pi * Complex.I) := by field_simp
      rw [hrw, Complex.exp_eq_one_iff]
      exact ⟨k, by push_cast; ring⟩
    rw [geom_sum_eq hz1, hzm]
    simp [h]

/-- Auxiliary: a cofactor of a positive number is positive. -/
theorem pos_of_factor {Q r m : ℕ} (hQ : 0 < Q) (hm : Q = r * m) : 0 < m := by
  rcases Nat.eq_zero_or_pos m with h | h
  · subst h; simp at hm; omega
  · exact h

/-! ### The comb and its spectrum -/

/-- The (unnormalised) discrete Fourier transform, at frequency `y`, of the comb
supported on the multiples of `r` inside `{0, …, Q-1}`. -/
noncomputable def combSum (Q r y : ℕ) : ℂ :=
  ∑ j ∈ Finset.range (Q / r), Complex.exp (2 * Real.pi * Complex.I * (j * r * y) / Q)

/-- **Exact spectrum of the comb.**  The transform is supported precisely on the
multiples of `Q/r`, where it takes the value `Q/r`. -/
theorem combSum_eq_ite {Q r : ℕ} (hr : 0 < r) (hQ : 0 < Q) (hdvd : r ∣ Q) (y : ℕ) :
    combSum Q r y = if (Q / r) ∣ y then ((Q / r : ℕ) : ℂ) else 0 := by
  obtain ⟨m, hm⟩ := hdvd
  have hQm : Q / r = m := by
    rw [hm]; exact Nat.mul_div_cancel_left m hr
  have hmpos : 0 < m := pos_of_factor hQ hm
  have hstep : ∀ j : ℕ, (2 * Real.pi * Complex.I * (j * r * y) / Q)
      = (2 * Real.pi * Complex.I * (j * y) / m) := by
    intro j
    have hQ' : (Q : ℂ) = (r : ℂ) * m := by exact_mod_cast hm
    have hr' : (r : ℂ) ≠ 0 := by exact_mod_cast hr.ne'
    have hm' : (m : ℂ) ≠ 0 := by exact_mod_cast hmpos.ne'
    rw [hQ']
    field_simp
  unfold combSum
  rw [hQm]
  rw [Finset.sum_congr rfl (fun j _ => by rw [hstep j])]
  rw [root_of_unity_sum m y hmpos]

/-- The peak set: the frequencies in `{0, …, Q-1}` at which the comb's spectrum is
nonzero, i.e. the multiples of `Q/r`. -/
def peaks (Q r : ℕ) : Finset ℕ := (Finset.range Q).filter (fun y => (Q / r) ∣ y)

theorem mem_peaks {Q r y : ℕ} : y ∈ peaks Q r ↔ y < Q ∧ (Q / r) ∣ y := by
  simp [peaks, Finset.mem_filter, Finset.mem_range]

/-- **The number of peaks is the hidden order.**  There are exactly `r` informative
frequencies in the window `{0, …, Q-1}`. -/
theorem card_peaks {Q r : ℕ} (hr : 0 < r) (hQ : 0 < Q) (hdvd : r ∣ Q) :
    (peaks Q r).card = r := by
  obtain ⟨m, hm⟩ := hdvd
  have hQm : Q / r = m := by rw [hm]; exact Nat.mul_div_cancel_left m hr
  have hmpos : 0 < m := pos_of_factor hQ hm
  have himg : peaks Q r = (Finset.range r).image (fun j => j * m) := by
    ext y
    rw [mem_peaks, hQm, Finset.mem_image]
    constructor
    · rintro ⟨hy, c, rfl⟩
      refine ⟨c, Finset.mem_range.mpr ?_, by ring⟩
      have h2 : m * c < m * r := by
        calc m * c < Q := hy
        _ = r * m := hm
        _ = m * r := by ring
      exact Nat.lt_of_mul_lt_mul_left h2
    · rintro ⟨j, hj, rfl⟩
      refine ⟨?_, ⟨j, by ring⟩⟩
      have hjr : j < r := Finset.mem_range.mp hj
      calc j * m < r * m := (Nat.mul_lt_mul_right hmpos).mpr hjr
      _ = Q := hm.symm
  rw [himg, Finset.card_image_of_injective _ (fun a b hab => by
      simpa [Nat.mul_left_cancel_iff, hmpos] using Nat.eq_of_mul_eq_mul_right hmpos hab),
    Finset.card_range]

/-! ### The output distribution: flat, `r`-parameterised, incompressible -/

/-- Shor's output distribution for hidden order `r` on the window `{0, …, Q-1}`:
uniform mass `1/r` on the `r` peaks. -/
noncomputable def combPMF (Q r : ℕ) : ℕ → ℝ :=
  fun y => if y ∈ peaks Q r then 1 / (r : ℝ) else 0

theorem combPMF_total {Q r : ℕ} (hr : 0 < r) (hQ : 0 < Q) (hdvd : r ∣ Q) :
    ∑ y ∈ Finset.range Q, combPMF Q r y = 1 := by
  have hsub : peaks Q r ⊆ Finset.range Q := Finset.filter_subset _ _
  unfold combPMF
  rw [Finset.sum_ite_mem, Finset.inter_eq_right.mpr hsub, Finset.sum_const,
    card_peaks hr hQ hdvd, nsmul_eq_mul]
  field_simp

/-- The comb's output distribution as a bona fide probability distribution. -/
noncomputable def combDist {Q r : ℕ} (hr : 0 < r) (hQ : 0 < Q) (hdvd : r ∣ Q) :
    DistOn (Finset.range Q) where
  p := combPMF Q r
  nonneg := by
    intro y _
    unfold combPMF
    split <;> positivity
  total := combPMF_total hr hQ hdvd

/-- **The distribution is the normalised squared spectrum.**  Dividing `|DFT|²` by
the Fourier normalisation `Q · (Q/r)` produces exactly the flat mass `1/r` on the
peaks: the output distribution is not an idealisation, it is the spectrum. -/
theorem combDist_eq_normalized_spectrum {Q r : ℕ} (hr : 0 < r) (hQ : 0 < Q)
    (hdvd : r ∣ Q) {y : ℕ} (hy : y < Q) :
    combPMF Q r y = ‖combSum Q r y‖ ^ 2 / ((Q : ℝ) * ((Q / r : ℕ) : ℝ)) := by
  obtain ⟨m, hm⟩ := hdvd
  have hQm : Q / r = m := by rw [hm]; exact Nat.mul_div_cancel_left m hr
  have hmpos : 0 < m := pos_of_factor hQ hm
  rw [combSum_eq_ite hr hQ ⟨m, hm⟩ y, combPMF]
  by_cases h : y ∈ peaks Q r
  · have hdy : (Q / r) ∣ y := (mem_peaks.mp h).2
    rw [if_pos h, if_pos hdy, hQm]
    have : ‖((m : ℕ) : ℂ)‖ = (m : ℝ) := by
      simp
    rw [this]
    have hQR : (Q : ℝ) = (r : ℝ) * m := by exact_mod_cast hm
    have hr' : (r : ℝ) ≠ 0 := by exact_mod_cast hr.ne'
    have hm' : (m : ℝ) ≠ 0 := by exact_mod_cast hmpos.ne'
    rw [hQR]
    field_simp
  · have hdy : ¬ (Q / r) ∣ y := by
      intro hc
      exact h (mem_peaks.mpr ⟨hy, hc⟩)
    rw [if_neg h, if_neg hdy]
    simp

/-- **Flat spectrum, maximal entropy.**  The Shannon entropy of the comb's output
distribution is exactly `log r`: the distribution carries the full `log r` of
information about the hidden order and admits no shorter description. -/
theorem combDist_entropy {Q r : ℕ} (hr : 0 < r) (hQ : 0 < Q) (hdvd : r ∣ Q) :
    ∑ y ∈ peaks Q r, (-(combPMF Q r y) * Real.log (combPMF Q r y)) = Real.log r := by
  have hr' : (r : ℝ) ≠ 0 := by exact_mod_cast hr.ne'
  have hterm : ∀ y ∈ peaks Q r,
      (-(combPMF Q r y) * Real.log (combPMF Q r y)) = (1 / (r : ℝ)) * Real.log r := by
    intro y hy
    simp only [combPMF, if_pos hy]
    rw [one_div, Real.log_inv]
    ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_const, card_peaks hr hQ hdvd, nsmul_eq_mul]
  field_simp

/-! ### Incompressibility: no sparse surrogate -/

/-- **Sparse surrogates fail.**  If a distribution `D` on the window is supported on
at most `k` outcomes, then it is at total variation at least `1 - k/r` from the comb
distribution.  With `k = poly(log N)` and `r` exponential this is `1 - o(1)`:
low-rank / sparse / bounded-bond-dimension emulations cannot approximate the
output of order finding. -/
theorem sparse_approx_lower_bound {Q r k : ℕ} (hr : 0 < r) (hQ : 0 < Q) (hdvd : r ∣ Q)
    (D : DistOn (Finset.range Q)) (S : Finset ℕ) (hcard : S.card ≤ k)
    (hsupp : ∀ y ∈ Finset.range Q, y ∉ S → D.p y = 0) :
    1 - (k : ℝ) / r ≤ tv (combDist hr hQ hdvd) D := by
  have hsub : peaks Q r \ S ⊆ Finset.range Q :=
    (Finset.sdiff_subset).trans (Finset.filter_subset _ _)
  have hD : ∑ y ∈ peaks Q r \ S, D.p y = 0 := by
    refine Finset.sum_eq_zero fun y hy => ?_
    obtain ⟨hyp, hyS⟩ := Finset.mem_sdiff.mp hy
    exact hsupp y (hsub hy) hyS
  have hcards : r - k ≤ (peaks Q r \ S).card := by
    have h1 : (peaks Q r).card ≤ (peaks Q r \ S).card + S.card :=
      Finset.card_le_card_sdiff_add_card
    rw [card_peaks hr hQ hdvd] at h1
    omega
  have hP : ((r : ℝ) - k) / r ≤ ∑ y ∈ peaks Q r \ S, (combDist hr hQ hdvd).p y := by
    have hval : ∑ y ∈ peaks Q r \ S, (combDist hr hQ hdvd).p y
        = ((peaks Q r \ S).card : ℝ) * (1 / r) := by
      simp only [combDist, combPMF]
      rw [Finset.sum_congr rfl (fun y hy => by
        rw [if_pos (Finset.mem_sdiff.mp hy).1]), Finset.sum_const, nsmul_eq_mul]
    rw [hval]
    have hr' : (0:ℝ) < r := by exact_mod_cast hr
    rw [div_le_iff₀ hr']
    have : ((r : ℝ) - k) ≤ ((peaks Q r \ S).card : ℝ) := by
      have : ((r - k : ℕ) : ℝ) ≤ ((peaks Q r \ S).card : ℝ) := by exact_mod_cast hcards
      have hcast : ((r : ℝ) - k) ≤ ((r - k : ℕ) : ℝ) := by
        rcases le_or_gt k r with h | h
        · rw [Nat.cast_sub h]
        · have h1 : ((r - k : ℕ) : ℝ) = 0 := by
            have : r - k = 0 := by omega
            simp [this]
          have : (r : ℝ) ≤ k := by exact_mod_cast h.le
          linarith
      linarith
    calc ((r:ℝ) - k) ≤ ((peaks Q r \ S).card : ℝ) := this
    _ = ((peaks Q r \ S).card : ℝ) * (1 / r) * r := by field_simp
  have hev := tv_ge_event (combDist hr hQ hdvd) D hsub
  rw [hD, sub_zero] at hev
  have hr' : (0:ℝ) < r := by exact_mod_cast hr
  have : 1 - (k:ℝ)/r = ((r:ℝ) - k)/r := by field_simp
  rw [this]
  linarith

/-! ### No order-free sampler -/

/-- Peak sets of coprime orders meet only at the trivial frequency `0`. -/
theorem peaks_disjoint_of_coprime {Q r s : ℕ} (hr : 0 < r) (hs : 0 < s)
    (hrQ : r ∣ Q) (hsQ : s ∣ Q) (hco : Nat.Coprime r s) :
    Disjoint (peaks Q r \ {0}) (peaks Q s \ {0}) := by
  rw [Finset.disjoint_left]
  intro y hy hy'
  obtain ⟨hyr, hy0⟩ := Finset.mem_sdiff.mp hy
  obtain ⟨hys, -⟩ := Finset.mem_sdiff.mp hy'
  have hy0' : y ≠ 0 := by simpa using hy0
  obtain ⟨hylt, hdr⟩ := mem_peaks.mp hyr
  obtain ⟨-, hds⟩ := mem_peaks.mp hys
  -- both `Q/r` and `Q/s` divide `y`, and their lcm is `Q`
  have hrs : r * s ∣ Q := Nat.Coprime.mul_dvd_of_dvd_of_dvd hco hrQ hsQ
  obtain ⟨a, ha⟩ := hrQ
  obtain ⟨b, hb⟩ := hsQ
  have hQa : Q / r = a := by rw [ha]; exact Nat.mul_div_cancel_left a hr
  have hQb : Q / s = b := by rw [hb]; exact Nat.mul_div_cancel_left b hs
  rw [hQa] at hdr
  rw [hQb] at hds
  have hlcm : Nat.lcm a b ∣ y := Nat.lcm_dvd hdr hds
  -- `lcm a b = Q`: write `Q = r s m`
  obtain ⟨m, hmm⟩ := hrs
  have hma : a = s * m := by
    have : r * a = r * (s * m) := by rw [← ha, hmm]; ring
    exact Nat.eq_of_mul_eq_mul_left hr this
  have hmb : b = r * m := by
    have : s * b = s * (r * m) := by rw [← hb, hmm]; ring
    exact Nat.eq_of_mul_eq_mul_left hs this
  have hlcmQ : Nat.lcm a b = Q := by
    rw [hma, hmb, Nat.lcm_mul_right, Nat.Coprime.lcm_eq_mul hco.symm, hmm]
    ring
  rw [hlcmQ] at hlcm
  have : Q ≤ y := Nat.le_of_dvd (Nat.pos_of_ne_zero hy0') hlcm
  omega

/-- **No order-free classical sampler.**  Let `r₁, …, r_k` be pairwise coprime
candidate orders, all at least `R ≥ 2` and all dividing the grid size `Q`.  Then for
*every* distribution `D` on the window — in particular every classical sampler that
is not allowed to depend on the hidden order — there is a candidate whose exact
Shor/Regev output distribution is at total variation at least `1 - 1/R - 1/k`
from `D`.  Sampling the output distribution therefore already requires knowing `r`. -/
theorem no_order_free_sampler {Q k R : ℕ} (hk : 0 < k) (hQ : 0 < Q) (hR : 0 < R)
    (r : Fin k → ℕ) (hrpos : ∀ i, 0 < r i) (hrR : ∀ i, R ≤ r i)
    (hrQ : ∀ i, r i ∣ Q) (hco : ∀ i j, i ≠ j → Nat.Coprime (r i) (r j))
    (D : DistOn (Finset.range Q)) :
    ∃ i, 1 - 1 / (R : ℝ) - 1 / k ≤ tv D (combDist (hrpos i) hQ (hrQ i)) := by
  have hmass : ∀ i, 1 - 1 / (R : ℝ) ≤
      ∑ y ∈ peaks Q (r i) \ {0}, (combDist (hrpos i) hQ (hrQ i)).p y := by
    intro i
    have hri : (0:ℝ) < r i := by exact_mod_cast hrpos i
    have hval : ∑ y ∈ peaks Q (r i) \ {0}, (combDist (hrpos i) hQ (hrQ i)).p y
        = ((peaks Q (r i) \ {0}).card : ℝ) * (1 / r i) := by
      simp only [combDist, combPMF]
      rw [Finset.sum_congr rfl (fun y hy => by
        rw [if_pos (Finset.mem_sdiff.mp hy).1]), Finset.sum_const, nsmul_eq_mul]
    have hcard : (peaks Q (r i) \ {0}).card = r i - 1 := by
      have h0 : (0 : ℕ) ∈ peaks Q (r i) := mem_peaks.mpr ⟨hQ, dvd_zero _⟩
      have : peaks Q (r i) \ {0} = (peaks Q (r i)).erase 0 := by
        ext y; simp [Finset.mem_sdiff, Finset.mem_erase, and_comm]
      rw [this, Finset.card_erase_of_mem h0, card_peaks (hrpos i) hQ (hrQ i)]
    rw [hval, hcard]
    have hRle : (R : ℝ) ≤ r i := by exact_mod_cast hrR i
    have hRpos : (0:ℝ) < R := by exact_mod_cast hR
    have h1 : ((r i - 1 : ℕ) : ℝ) = (r i : ℝ) - 1 := by
      have := hrpos i
      push_cast [Nat.cast_sub (by omega : 1 ≤ r i)]
      ring
    rw [h1]
    have heq : ((r i : ℝ) - 1) * (1 / r i) = 1 - 1 / (r i : ℝ) := by
      field_simp
    rw [heq]
    have hmono : 1 / (r i : ℝ) ≤ 1 / R := by
      apply one_div_le_one_div_of_le hRpos hRle
    linarith
  obtain ⟨i, hi⟩ := exists_far_candidate hk D
    (fun i => combDist (hrpos i) hQ (hrQ i)) (fun i => peaks Q (r i) \ {0})
    (fun i => (Finset.sdiff_subset).trans (Finset.filter_subset _ _))
    (fun i j hij => peaks_disjoint_of_coprime (hrpos i) (hrpos j) (hrQ i) (hrQ j)
      (hco i j hij))
    (1 - 1 / (R : ℝ)) hmass
  exact ⟨i, by linarith [hi]⟩

end Dequant