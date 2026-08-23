import Mathlib
import Algebra.ZeroFitDialU72Parity

/-!
# Parity capacity: how many mutually decorrelated statistics can read the same dial value

Cycle 2 of the round-63 (bitlen-72, `U72-DIAL-HOLDS-COUNT-PARITY`) investigation.

`Algebra.ZeroFitDialU72Parity` proves the **parity threshold**: two decorrelated statistics
cannot both correlate above `√2/2 ≈ 0.70711` with a shared response, and every level below
that threshold is realised by an explicit configuration.  The recorded bitlen-72 reading
`0.605` sits below the threshold — count parity there is *free* — while the bitlen-44
reading `0.78` sits above it and forces the two statistics to be mutually correlated.

The obvious next question is quantitative: parity is a statement about **two** statistics,
but a research programme that keeps adding baselines is really asking how many mutually
decorrelated statistics can all read the same value.  This file answers it exactly.

## Main results

* `bessel_ineq` — Bessel's inequality for the elementary `Fin n → ℝ` inner product: for a
  finite orthonormal family `u`, `Σᵢ ⟪uᵢ,w⟫² ≤ ⟪w,w⟫`, proved by expanding the squared
  norm of the residual `w - Σᵢ ⟪uᵢ,w⟫uᵢ`.
* `bessel_corr` — its correlation form `Σᵢ corr(uᵢ,w)² ≤ 1`.
* `parity_capacity_ceiling` — the **capacity law**: if `k` mutually decorrelated statistics
  all read at least `rho ≥ 0` against a shared response then `k·rho² ≤ 1`, i.e.
  `rho ≤ 1/√k`.  For `k = 2` this recovers the parity threshold `√2/2`.
* `parity_capacity_realizable` — sharpness: whenever `k·t² ≤ 1` there is an explicit
  orthonormal family of `k` statistics in dimension `k+1` all reading exactly `t`.  The
  capacity bound is therefore an equality, not merely a bound.
* `u72_capacity_two` — the payload for the recorded measurement: **two** mutually
  decorrelated statistics may both read the bitlen-72 value `0.605` (and do, in an explicit
  configuration), but **three** cannot: `3·0.605² = 1.098 > 1`.
* `u72_third_baseline_forced_correlated` — restated as a prediction about the experiment:
  any third baseline that also reads `0.605` at bitlen 72 must be measurably correlated
  with one of the first two.
* `dial44_capacity_one` — at the bitlen-44 end of the dial the capacity is already `1`:
  no *pair* of decorrelated statistics can both read `0.78`.

## The scientific payload

Count parity is not a curiosity of the two particular statistics involved; it is the `k=2`
instance of a hard geometric budget `Σᵢ ρᵢ² ≤ 1` on the correlations of any decorrelated
family with a single response.  The budget decreases as the dial value grows, so the
observed monotone decline of the dial (`0.78 → 0.605`) is exactly the regime in which the
parity capacity rises from `1` to `2` — which is when a second statistic *can* start
matching the dial, i.e. when count parity becomes possible at all.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialParityCapacity

open Catalog.Algebra.ZeroFitDialU72Parity

variable {n k : ℕ}

/-! ## 1. Bessel's inequality -/

/-- A family of vectors is orthonormal for `dot` when distinct members are orthogonal and
each has unit square-norm. -/
def IsOrthonormal (u : Fin k → (Fin n → ℝ)) : Prop :=
  (∀ i, dot (u i) (u i) = 1) ∧ ∀ i j, i ≠ j → dot (u i) (u j) = 0

lemma dot_sum_left (c : Fin k → ℝ) (u : Fin k → (Fin n → ℝ)) (w : Fin n → ℝ) :
    dot (fun x => ∑ i, c i * u i x) w = ∑ i, c i * dot (u i) w := by
  simp only [dot, Finset.sum_mul]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun i _ => by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun x _ => by ring

lemma dot_sum_sum (c : Fin k → ℝ) (u : Fin k → (Fin n → ℝ)) (hu : IsOrthonormal u) :
    dot (fun x => ∑ i, c i * u i x) (fun x => ∑ i, c i * u i x) = ∑ i, c i ^ 2 := by
  rw [dot_sum_left]
  refine Finset.sum_congr rfl fun i _ => ?_
  have hi : dot (u i) (fun x => ∑ j, c j * u j x) = c i := by
    rw [dot_comm, dot_sum_left]
    rw [Finset.sum_eq_single i]
    · rw [hu.1 i]; ring
    · intro j _ hj
      rw [dot_comm, hu.2 i j (Ne.symm hj)]
      ring
    · intro h; exact absurd (Finset.mem_univ i) h
  rw [hi]; ring

/-- **Bessel's inequality** for the coordinate inner product. -/
theorem bessel_ineq (u : Fin k → (Fin n → ℝ)) (hu : IsOrthonormal u) (w : Fin n → ℝ) :
    ∑ i, dot (u i) w ^ 2 ≤ dot w w := by
  set c : Fin k → ℝ := fun i => dot (u i) w with hc
  set P : Fin n → ℝ := fun x => ∑ i, c i * u i x with hP
  have hPP : dot P P = ∑ i, c i ^ 2 := dot_sum_sum c u hu
  have hwP : dot P w = ∑ i, c i ^ 2 := by
    rw [hP, dot_sum_left]
    exact Finset.sum_congr rfl fun i _ => by rw [hc]; ring
  have hres : 0 ≤ dot (fun x => w x - P x) (fun x => w x - P x) :=
    dot_self_nonneg _
  have hexp : dot (fun x => w x - P x) (fun x => w x - P x)
      = dot w w - 2 * dot w P + dot P P := by
    rw [dot, Finset.sum_congr rfl (fun x _ => (pow_two (w x - P x)).symm)]
    exact dot_expand_sub w P
  rw [hexp, hPP, dot_comm w P, hwP] at hres
  linarith

/-- Correlation form of Bessel's inequality: a decorrelated family of statistics has a
total correlation budget of `1` against any single response. -/
theorem bessel_corr (u : Fin k → (Fin n → ℝ)) (hu : IsOrthonormal u) (w : Fin n → ℝ)
    (hw : dot w w ≠ 0) :
    ∑ i, corr (u i) w ^ 2 ≤ 1 := by
  have hwpos : 0 < dot w w := lt_of_le_of_ne (dot_self_nonneg w) (Ne.symm hw)
  have hsq : ∀ i, corr (u i) w ^ 2 = dot (u i) w ^ 2 / dot w w := by
    intro i
    rw [corr_sq (u i) w, hu.1 i, one_mul]
  rw [Finset.sum_congr rfl fun i _ => hsq i, ← Finset.sum_div, div_le_one hwpos]
  exact bessel_ineq u hu w

/-! ## 2. The capacity law -/

/-- **The parity capacity law.**  If `k` mutually decorrelated statistics all correlate at
level at least `rho ≥ 0` with a shared response, then `k·rho² ≤ 1`.  At `k = 2` this is the
parity threshold `rho ≤ √2/2` of `Algebra.ZeroFitDialU72Parity`. -/
theorem parity_capacity_ceiling (u : Fin k → (Fin n → ℝ)) (hu : IsOrthonormal u)
    (w : Fin n → ℝ) (hw : dot w w ≠ 0) {rho : ℝ} (hrho : 0 ≤ rho)
    (hread : ∀ i, rho ≤ corr (u i) w) :
    (k : ℝ) * rho ^ 2 ≤ 1 := by
  have hterm : ∀ i ∈ (univ : Finset (Fin k)), rho ^ 2 ≤ corr (u i) w ^ 2 := by
    intro i _
    have := hread i
    nlinarith [hrho, this]
  have hsum : (k : ℝ) * rho ^ 2 ≤ ∑ i, corr (u i) w ^ 2 := by
    have := Finset.sum_le_sum hterm
    simpa [Finset.sum_const, Finset.card_univ, mul_comm] using this
  exact le_trans hsum (bessel_corr u hu w hw)

/-- The capacity law in `1/√k` form. -/
theorem parity_capacity_sqrt (u : Fin k → (Fin n → ℝ)) (hu : IsOrthonormal u)
    (w : Fin n → ℝ) (hw : dot w w ≠ 0) {rho : ℝ} (hrho : 0 ≤ rho) (hk : 1 ≤ k)
    (hread : ∀ i, rho ≤ corr (u i) w) :
    rho ≤ 1 / Real.sqrt k := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hcap := parity_capacity_ceiling u hu w hw hrho hread
  have hs : Real.sqrt k ^ 2 = (k : ℝ) := Real.sq_sqrt (by linarith)
  have hspos : 0 < Real.sqrt k := Real.sqrt_pos.mpr (by linarith)
  rw [le_div_iff₀ hspos]
  nlinarith [hcap, hs, hspos, hrho]

/-! ## 3. Sharpness: the capacity is attained -/

/-- **Sharpness of the capacity law.**  Whenever `k·t² ≤ 1` there is an explicit orthonormal
family of `k` statistics in dimension `k+1`, and a response, with every reading equal to
`t`.  Hence the bound `k·rho² ≤ 1` is exactly the constraint, with nothing to spare. -/
theorem parity_capacity_realizable {t : ℝ} (ht : (k : ℝ) * t ^ 2 ≤ 1) :
    ∃ (u : Fin k → (Fin (k + 1) → ℝ)) (w : Fin (k + 1) → ℝ),
      IsOrthonormal u ∧ dot w w = 1 ∧ ∀ i, corr (u i) w = t := by
  classical
  set s : ℝ := Real.sqrt (1 - k * t ^ 2) with hs
  have hs2 : s ^ 2 = 1 - k * t ^ 2 := Real.sq_sqrt (by linarith)
  set uv : Fin k → (Fin (k + 1) → ℝ) := fun i x => if x = i.castSucc then 1 else 0 with huv
  set wv : Fin (k + 1) → ℝ := fun x => if x = Fin.last k then s else t with hwv
  have hcast : ∀ x : Fin k, (x.castSucc : Fin (k + 1)) ≠ Fin.last k :=
    fun x => (Fin.castSucc_lt_last x).ne
  have hu1 : ∀ i, dot (uv i) (uv i) = 1 := by
    intro i
    rw [dot, Finset.sum_eq_single i.castSucc]
    · simp [huv]
    · intro b _ hb; simp [huv, hb]
    · intro h; exact absurd (mem_univ _) h
  have huw : ∀ i, dot (uv i) wv = t := by
    intro i
    rw [dot, Finset.sum_eq_single i.castSucc]
    · simp [huv, hwv, hcast i]
    · intro b _ hb; simp [huv, hb]
    · intro h; exact absurd (mem_univ _) h
  have hww : dot wv wv = 1 := by
    rw [dot, Fin.sum_univ_castSucc]
    have hterm : ∀ x : Fin k, wv x.castSucc * wv x.castSucc = t * t := by
      intro x; simp [hwv, hcast x]
    rw [Finset.sum_congr rfl (fun x _ => hterm x)]
    have hlast : wv (Fin.last k) * wv (Fin.last k) = s * s := by simp [hwv]
    rw [hlast, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    nlinarith [hs2]
  refine ⟨uv, wv, ⟨hu1, ?_⟩, hww, ?_⟩
  · intro i j hij
    have hne : (i.castSucc : Fin (k + 1)) ≠ j.castSucc :=
      fun h => hij (Fin.castSucc_injective _ h)
    rw [dot]
    refine Finset.sum_eq_zero fun x _ => ?_
    rcases eq_or_ne x i.castSucc with h | h
    · subst h; simp [huv, hne]
    · simp [huv, h]
  · intro i
    rw [corr, huw i, nrm, nrm, hu1 i, hww, Real.sqrt_one]
    norm_num

/-! ## 4. The recorded bitlen-72 measurement -/

open Catalog.Algebra.ZeroFitDialU72Parity in
/-- **Capacity two at bitlen 72.**  Two mutually decorrelated statistics can both read the
recorded value `0.605` — an explicit configuration exists — but three cannot. -/
theorem u72_capacity_two :
    (∃ (u : Fin 2 → (Fin 3 → ℝ)) (w : Fin 3 → ℝ),
        IsOrthonormal u ∧ dot w w = 1 ∧ ∀ i, corr (u i) w = (pooled72 : ℝ)) ∧
    ∀ (m : ℕ) (u : Fin 3 → (Fin m → ℝ)) (w : Fin m → ℝ), IsOrthonormal u → dot w w ≠ 0 →
      ¬ (∀ i, (pooled72 : ℝ) ≤ corr (u i) w) := by
  constructor
  · have hval : (pooled72 : ℝ) = 605 / 1000 := by norm_num [pooled72]
    have ht : ((2 : ℕ) : ℝ) * (pooled72 : ℝ) ^ 2 ≤ 1 := by rw [hval]; norm_num
    exact parity_capacity_realizable ht
  · intro m u w hu hw hread
    have hrho : (0 : ℝ) ≤ (pooled72 : ℝ) := by norm_num [pooled72]
    have hcap := parity_capacity_ceiling u hu w hw hrho hread
    have hval : (pooled72 : ℝ) = 605 / 1000 := by norm_num [pooled72]
    rw [hval] at hcap
    norm_num at hcap

open Catalog.Algebra.ZeroFitDialU72Parity in
/-- Restated as an experimental prediction: a third baseline reading the bitlen-72 dial
value cannot be decorrelated from the other two. -/
theorem u72_third_baseline_forced_correlated {m : ℕ} (u : Fin 3 → (Fin m → ℝ))
    (w : Fin m → ℝ) (hu : IsOrthonormal u) (hw : dot w w ≠ 0)
    (h0 : (pooled72 : ℝ) ≤ corr (u 0) w) (h1 : (pooled72 : ℝ) ≤ corr (u 1) w)
    (h2 : (pooled72 : ℝ) ≤ corr (u 2) w) : False := by
  refine u72_capacity_two.2 m u w hu hw ?_
  intro i
  fin_cases i
  · exact h0
  · exact h1
  · exact h2

open Catalog.Algebra.ZeroFitDialU72Parity in
/-- **Capacity one at bitlen 44.**  At the high end of the dial not even a *pair* of
decorrelated statistics can both read `0.78`: the parity regime has not opened yet. -/
theorem dial44_capacity_one {m : ℕ} (u : Fin 2 → (Fin m → ℝ)) (w : Fin m → ℝ)
    (hu : IsOrthonormal u) (hw : dot w w ≠ 0) :
    ¬ (∀ i, (dial44 : ℝ) ≤ corr (u i) w) := by
  intro hread
  have hrho : (0 : ℝ) ≤ (dial44 : ℝ) := by norm_num [dial44]
  have hcap := parity_capacity_ceiling u hu w hw hrho hread
  have hval : (dial44 : ℝ) = 78 / 100 := by norm_num [dial44]
  rw [hval] at hcap
  norm_num at hcap

/-- The capacity threshold sequence: the largest dial value compatible with `k` mutually
decorrelated statistics is `1/√k`, so the recorded readings partition by capacity —
`0.78 > 1/√2` (capacity 1), `1/√3 < 0.605 ≤ 1/√2` (capacity 2). -/
theorem capacity_window :
    Real.sqrt 2 / 2 < (dial44 : ℝ) ∧
    (pooled72 : ℝ) ≤ 1 / Real.sqrt 2 ∧ 1 / Real.sqrt 3 < (pooled72 : ℝ) := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h2pos : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  have h3pos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  have hd : (dial44 : ℝ) = 78 / 100 := by norm_num [dial44]
  have hp : (pooled72 : ℝ) = 605 / 1000 := by norm_num [pooled72]
  refine ⟨?_, ?_, ?_⟩
  · rw [hd]; nlinarith [h2, h2pos]
  · rw [hp, le_div_iff₀ h2pos]; nlinarith [h2, h2pos]
  · rw [hp, div_lt_iff₀ h3pos]; nlinarith [h3, h3pos]

end Catalog.Algebra.ZeroFitDialParityCapacity