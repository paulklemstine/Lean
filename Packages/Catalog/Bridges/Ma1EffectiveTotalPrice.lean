import Bridges.Ma1EffectiveEntropy

/-!
# The total information price of MA-1 across all scales, and quadratic readouts

Fourth cycle of the MA-1 effectivization loop.  Cycles 1–3
(`Bridges.Ma1EffectiveEquidistribution`, `Bridges.Ma1EffectiveScaleDecay`,
`Bridges.Ma1EffectiveEntropy`) price the equidistribution assumption *at one scale*: an
order-theoretic factor `(1+ε)/(1−ε)`, an additive cap excess `(8/3)ε/(1−ε)`, and an
information cost `2ε/(1−ε)` nats.  This file closes two of the open directions recorded at
the end of cycle 3.

* **Total price (direction "Summable Entropy Price Across Dyadic Scales").**  Kullback–Leibler
  divergence from uniform is nonnegative (`klFromUniform_nonneg`, a Gibbs inequality proved
  from `log t ≤ t − 1`), so the per-scale prices form a nonnegative sequence.  Under the
  geometric decay of the certificates observed in H3 the sequence is summable and the *total*
  information ever lost to MA-1, over all dyadic scales at once, is at most
  `4·ε₀/(1−ρ)` nats (`kl_summable_of_geom`, `total_information_price_le`).  At the recorded
  `ε₀ = 0.000446` with halving certificates this total is below `0.00357` nats
  (`exp509_total_information_price_le`) — the assumption is not merely cheap at `x = 2^30`,
  its whole future cost is bounded.

* **Quadratic transfer (direction "Quadratic Transfer for Non-Monotone Readouts").**  The
  linear-in-`ε` cost of cycle 1 is a feature of *monotone* readouts.  A readout controlled by
  the deviation energy — i.e. bounded by `L·Σ(f a − c)²` for some reference `c` — pays only
  `O(ε²)` (`quadratic_transfer`).  The empirical variance is such a readout
  (`quadOnDeviations_tss`), and at the recorded `ε` the quadratic price is below `2·10⁻⁷`
  relative (`exp509_quadratic_price`), five significant figures rather than three.  The two
  regimes are genuinely different: `ratio_bound_sharp` shows the linear cost is attained.
-/

namespace Ma1Effective

open Finset

variable {ι : Type*} [Fintype ι] {N : ι → ℝ} {μ ε : ℝ}

/-! ## Gibbs' inequality: the information price is never negative -/

section Gibbs

variable [Nonempty ι]

/-- **Gibbs' inequality.**  The Kullback–Leibler divergence of a probability vector from the
uniform distribution on the classes is nonnegative.  The proof is `log t ≤ t − 1` applied to
`t = (n·p a)⁻¹`. -/
theorem klFromUniform_nonneg {p : ι → ℝ} (hpos : ∀ a, 0 < p a) (hsum : ∑ a, p a = 1) :
    0 ≤ klFromUniform p := by
  have hc : (0 : ℝ) < (Fintype.card ι : ℝ) := card_pos_real (ι := ι)
  have key : ∀ a : ι,
      -(p a * Real.log ((Fintype.card ι : ℝ) * p a)) ≤ 1 / (Fintype.card ι : ℝ) - p a := by
    intro a
    have hpa := hpos a
    have hx : (0 : ℝ) < ((Fintype.card ι : ℝ) * p a)⁻¹ := by positivity
    have hlog := Real.log_le_sub_one_of_pos hx
    have hinv : Real.log (((Fintype.card ι : ℝ) * p a)⁻¹)
        = -Real.log ((Fintype.card ι : ℝ) * p a) := Real.log_inv _
    rw [hinv] at hlog
    have hmul := mul_le_mul_of_nonneg_left hlog (le_of_lt hpa)
    have hval : p a * (((Fintype.card ι : ℝ) * p a)⁻¹ - 1) = 1 / (Fintype.card ι : ℝ) - p a := by
      field_simp
    calc -(p a * Real.log ((Fintype.card ι : ℝ) * p a))
        = p a * (-Real.log ((Fintype.card ι : ℝ) * p a)) := by ring
      _ ≤ p a * (((Fintype.card ι : ℝ) * p a)⁻¹ - 1) := hmul
      _ = 1 / (Fintype.card ι : ℝ) - p a := hval
  have hsumle : ∑ a, -(p a * Real.log ((Fintype.card ι : ℝ) * p a))
      ≤ ∑ a : ι, (1 / (Fintype.card ι : ℝ) - p a) :=
    Finset.sum_le_sum fun a _ => key a
  have hright : ∑ a : ι, (1 / (Fintype.card ι : ℝ) - p a) = 0 := by
    rw [Finset.sum_sub_distrib, hsum, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp
    norm_num
  rw [hright] at hsumle
  have hneg : ∑ a, -(p a * Real.log ((Fintype.card ι : ℝ) * p a)) = -klFromUniform p := by
    unfold klFromUniform
    rw [← Finset.sum_neg_distrib]
  rw [hneg] at hsumle
  linarith

/-- The per-scale information price in its simplest linear form: for `ε ≤ 1/2` the divergence
is at most `4ε` nats. -/
theorem kl_le_four_eps (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε ≤ 1 / 2) :
    klFromUniform (classDist N) ≤ 4 * ε := by
  have hε0 : 0 ≤ ε := eps_nonneg_of_equiCert h hμ
  have hlt : ε < 1 := by linarith
  have hbase := kl_le_of_equiCert h hμ hlt hε0
  have h1e : (0 : ℝ) < 1 - ε := by linarith
  have : 2 * ε / (1 - ε) ≤ 4 * ε := by
    rw [div_le_iff₀ h1e]
    nlinarith
  linarith

end Gibbs

/-! ## The total price across all scales -/

section TotalPrice

variable [Nonempty ι]

/-- Along a geometrically decaying family of certificates every scale has `e k ≤ 1/2`. -/
theorem eps_le_half_of_geom {e : ℕ → ℝ} {ρ : ℝ} (hnn : ∀ k, 0 ≤ e k) (hρ0 : 0 ≤ ρ)
    (hρ1 : ρ < 1) (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (he0 : e 0 ≤ 1 / 2) (k : ℕ) :
    e k ≤ 1 / 2 := by
  have hgeom := eps_geom_bound e ρ hρ0 hstep k
  have h1 : ρ ^ k * e 0 ≤ 1 * e 0 :=
    mul_le_mul_of_nonneg_right (pow_le_one₀ hρ0 (le_of_lt hρ1)) (hnn 0)
  linarith

/-- The per-scale prices are dominated by a geometric sequence. -/
theorem kl_le_geom {Nf : ℕ → ι → ℝ} {m : ℕ → ℝ} {e : ℕ → ℝ} {ρ : ℝ}
    (hcert : ∀ k, EquiCert (Nf k) (m k) (e k)) (hm : ∀ k, 0 < m k) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (he0 : e 0 ≤ 1 / 2) (k : ℕ) :
    klFromUniform (classDist (Nf k)) ≤ 4 * e 0 * ρ ^ k := by
  have hnn : ∀ j, 0 ≤ e j := fun j => eps_nonneg_of_equiCert (hcert j) (hm j)
  have hhalf := eps_le_half_of_geom hnn hρ0 hρ1 hstep he0 k
  have hkl := kl_le_four_eps (hcert k) (hm k) hhalf
  have hgeom := eps_geom_bound e ρ hρ0 hstep k
  nlinarith [hnn k]

/-- Each scale's price is nonnegative. -/
theorem kl_nonneg_of_equiCert (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) :
    0 ≤ klFromUniform (classDist N) :=
  klFromUniform_nonneg (fun a => classDist_pos h hμ hε a) (classDist_sum_one h hμ hε)

/-- **The information price is summable.**  Geometrically decaying certificates make the
sequence of per-scale Kullback–Leibler prices summable. -/
theorem kl_summable_of_geom {Nf : ℕ → ι → ℝ} {m : ℕ → ℝ} {e : ℕ → ℝ} {ρ : ℝ}
    (hcert : ∀ k, EquiCert (Nf k) (m k) (e k)) (hm : ∀ k, 0 < m k) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (he0 : e 0 ≤ 1 / 2) :
    Summable fun k => klFromUniform (classDist (Nf k)) := by
  have hnn : ∀ j, 0 ≤ e j := fun j => eps_nonneg_of_equiCert (hcert j) (hm j)
  have hmaj : Summable fun k : ℕ => 4 * e 0 * ρ ^ k :=
    (summable_geometric_of_lt_one hρ0 hρ1).mul_left _
  refine Summable.of_nonneg_of_le (fun k => ?_) (fun k => ?_) hmaj
  · have hhalf := eps_le_half_of_geom hnn hρ0 hρ1 hstep he0 k
    exact kl_nonneg_of_equiCert (hcert k) (hm k) (by linarith)
  · exact kl_le_geom hcert hm hρ0 hρ1 hstep he0 k

/-- **The total information price of MA-1.**  Summed over all dyadic scales, the information
lost to the equidistribution assumption is at most `4ε₀/(1−ρ)` nats: a single finite constant
bounds the entire future cost of the assumption. -/
theorem total_information_price_le {Nf : ℕ → ι → ℝ} {m : ℕ → ℝ} {e : ℕ → ℝ} {ρ : ℝ}
    (hcert : ∀ k, EquiCert (Nf k) (m k) (e k)) (hm : ∀ k, 0 < m k) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (he0 : e 0 ≤ 1 / 2) :
    ∑' k, klFromUniform (classDist (Nf k)) ≤ 4 * e 0 / (1 - ρ) := by
  have hsum := kl_summable_of_geom hcert hm hρ0 hρ1 hstep he0
  have hmaj : Summable fun k : ℕ => 4 * e 0 * ρ ^ k :=
    (summable_geometric_of_lt_one hρ0 hρ1).mul_left _
  have hle : ∑' k, klFromUniform (classDist (Nf k)) ≤ ∑' k : ℕ, 4 * e 0 * ρ ^ k :=
    Summable.tsum_le_tsum (fun k => kl_le_geom hcert hm hρ0 hρ1 hstep he0 k) hsum hmaj
  have hgeom : ∑' k : ℕ, 4 * e 0 * ρ ^ k = 4 * e 0 * (1 - ρ)⁻¹ := by
    rw [tsum_mul_left, tsum_geometric_of_lt_one hρ0 hρ1]
  rw [hgeom] at hle
  calc ∑' k, klFromUniform (classDist (Nf k)) ≤ 4 * e 0 * (1 - ρ)⁻¹ := hle
    _ = 4 * e 0 / (1 - ρ) := by rw [div_eq_mul_inv]

/-- **The numeric payload.**  At the recorded `ε₀ = 0.000446`, with certificates that at
worst halve from one dyadic scale to the next, the total information ever lost to MA-1 is
below `0.00357` nats. -/
theorem exp509_total_information_price_le {Nf : ℕ → ι → ℝ} {m : ℕ → ℝ} {e : ℕ → ℝ}
    (hcert : ∀ k, EquiCert (Nf k) (m k) (e k)) (hm : ∀ k, 0 < m k)
    (hstep : ∀ k, e (k + 1) ≤ (1 / 2) * e k) (he0 : e 0 ≤ 0.000446) :
    ∑' k, klFromUniform (classDist (Nf k)) ≤ 0.00357 := by
  have hbase :=
    total_information_price_le (ρ := 1 / 2) hcert hm (by norm_num) (by norm_num) hstep
      (by linarith)
  have : 4 * e 0 / (1 - 1 / 2) ≤ 0.00357 := by
    rw [div_le_iff₀ (by norm_num : (0:ℝ) < 1 - 1 / 2)]
    linarith
  linarith

end TotalPrice

/-! ## Quadratic readouts pay only `ε²` -/

section Quadratic

open QRResidual

/-- A readout controlled by the deviation energy around some reference level: `|Φ f|` is at
most `L` times the sum of squared deviations of `f` from any constant `c`.  Such a readout
vanishes on constant vectors, which is exactly why its transfer cost is quadratic. -/
def QuadOnDeviations (Φ : (ι → ℝ) → ℝ) (L : ℝ) : Prop :=
  ∀ (f : ι → ℝ) (c : ℝ), |Φ f| ≤ L * ∑ a, (f a - c) ^ 2

/-- **Quadratic transfer.**  A deviation-energy readout pays only `O(ε²)` for the
equidistribution assumption, in contrast with the sharp linear cost `(1+ε)/(1−ε)` that
monotone positively homogeneous readouts pay (`ratio_bound_sharp`). -/
theorem quadratic_transfer {Φ : (ι → ℝ) → ℝ} {L : ℝ} (hL : 0 ≤ L)
    (hΦ : QuadOnDeviations Φ L) (h : EquiCert N μ ε) :
    |Φ N| ≤ L * ((Fintype.card ι : ℝ) * (ε * μ) ^ 2) := by
  refine (hΦ N μ).trans ?_
  exact mul_le_mul_of_nonneg_left (sum_sq_le_of_equiCert h) hL

/-- The empirical variance is a deviation-energy readout with constant `1`. -/
theorem quadOnDeviations_tss [Nonempty ι] : QuadOnDeviations (tss (ι := ι)) 1 := by
  intro f c
  have hnn : 0 ≤ tss f := by
    have : tss f = ∑ a, (f a - mean f) ^ 2 := by simp [tss, sqNorm, Pi.sub_apply]
    rw [this]
    exact Finset.sum_nonneg fun a _ => sq_nonneg _
  rw [abs_of_nonneg hnn, one_mul]
  exact tss_le_sum_sq f c

/-- **The variance-type price at the recorded deviation.**  With `ε = 0.000446` the total sum
of squares of the class counts is below `2·10⁻⁷·n·μ²`: on the quadratic side the
equidistribution assumption is accurate to five significant figures, not three. -/
theorem exp509_quadratic_price [Nonempty ι] (h : EquiCert N μ 0.000446) :
    tss N ≤ 0.0000002 * ((Fintype.card ι : ℝ) * μ ^ 2) := by
  have hq := quadratic_transfer (Φ := tss (ι := ι)) (L := 1) zero_le_one quadOnDeviations_tss h
  have hnn : 0 ≤ tss N := by
    have : tss N = ∑ a, (N a - mean N) ^ 2 := by simp [tss, sqNorm, Pi.sub_apply]
    rw [this]
    exact Finset.sum_nonneg fun a _ => sq_nonneg _
  rw [abs_of_nonneg hnn, one_mul] at hq
  have hc : (0 : ℝ) ≤ (Fintype.card ι : ℝ) := Nat.cast_nonneg _
  have hkey : (Fintype.card ι : ℝ) * ((0.000446 : ℝ) * μ) ^ 2
      ≤ 0.0000002 * ((Fintype.card ι : ℝ) * μ ^ 2) := by
    have hsq : (0 : ℝ) ≤ μ ^ 2 := sq_nonneg μ
    nlinarith
  linarith

end Quadratic

end Ma1Effective