import Mathlib
import Algebra.ZeroFitDialU72Parity
import Algebra.ZeroFitDialU64Replication
import Algebra.ZeroFitDialU64MedianCapacity
import Algebra.ZeroFitDialU64Aggregation

/-!
# Count parity forces dispersion, and dispersion forces decorrelation

## Research context

Fifth cycle on the `U64B-DIAL-HOLDS-COUNT-PARITY` record (exp 543).  Conjecture **D1** of
the thread asserted that a sub-threshold dial cell must have a *bimodal* seedwise advantage
distribution.  Cycle 2 proved a single instance of that (`six_seed_bimodality_gap`: a gap
of at least `0.016` between the third and fourth sorted advantages at bitlen 64), using the
recorded median.  What was missing was a **model-free** dispersion law: a statement that
uses only the published summary statistics — number of seeds, bar, mean, and how many seeds
clear the bar — and no order statistics or explicit witness at all.

That law is proved here, and it is then coupled to Layer 1 of the thread (the chord
geometry) to give the bridge theorem the thread has been aiming at since cycle 1.

## Main results

* `count_parity_variance_floor` — **the dispersion law.**  If `r` seeds have advantage mean
  `μ`, and some set `L` of `ℓ` of them sits at or below the bar `τ < μ`, then

  `∑ᵢ (aᵢ - μ)² ≥ r·ℓ/(r-ℓ) · (μ - τ)²`.

  Equivalently the advantage standard deviation is at least `√(ℓ/(r-ℓ)) · (μ - τ)`, and in
  the balanced case `ℓ = r/2` it is at least the excess `μ - τ` itself.  Nothing about the
  individual advantages is used: only the bar, the mean, and the count.  The losing seeds
  contribute `ℓ(μ-τ)²` termwise, and the winning seeds contribute `ℓ²(μ-τ)²/(r-ℓ)` through
  Cauchy–Schwarz applied to their forced surplus.
* `count_parity_energy_floor` — the same statement as a floor on the pooled advantage
  energy `∑ᵢ aᵢ²`, which is the quantity the chord budget controls.
* `count_parity_forces_decorrelation` — **the bridge.**  Combining the energy floor with
  the aggregated budget of `Algebra.ZeroFitDialU64Aggregation`, a count-parity record with
  reading products at least `P` forces

  `μ² + ℓ/(r-ℓ)·(μ-τ)² ≤ 2(1 - cmin)(1 - P)`,

  i.e. a decorrelation floor computed *from the summary statistics alone*.  This is what
  the thread's conjecture D5 was reaching for: a schema, not a numerical instance.
* `six_seed_count_parity_decorrelation` — instantiated on the record: six seeds, three at
  or below the bar `0.05`, mean `0.059`, reading products at least `1/3` force
  `cmin ≤ 1 - 5343/2000000`.
* `six_seed_dispersion_floor`, `balanced_sd_floor` — the record's advantage dispersion is
  at least `486/1000000` in total squared deviation, and in a balanced split the standard
  deviation is at least the excess `μ - τ`, here `0.009`.

## Scientific payload

D1 is *partly confirmed and partly reformulated*.  The bimodality it predicted is real and
provable, but the correct invariant is not a gap between adjacent order statistics — that
requires the median, an extra measurement — but the **variance**, which count parity alone
pins from below.  The `1/√2` deficit that D1 wanted as the driver does not appear: the
dispersion floor is driven by the *excess over the bar* and the *count split*, and it is
already nonzero for any record whose mean clears a bar that half its seeds miss.  This is
strictly more robust than the median route, since it survives any relabelling of the seeds.

Numerically the summary-statistics route certifies `1 - cmin ≥ 0.0026715`, while the
explicit realiser of `six_seed_aggregate_decorrelation` certifies `0.0035755`.  The gap
between the two is precisely the information carried by the individual seed values beyond
the published summary.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU64Dispersion

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialU64Replication
open Catalog.Algebra.ZeroFitDialU64MedianCapacity
open Catalog.Algebra.ZeroFitDialU64Aggregation

/-! ## 1. The dispersion law -/

/-- **Count parity forces dispersion.**  A record of `r` advantages with mean `mu`, of
which the `ℓ` members of `L` sit at or below the bar `tau < mu`, has total squared
deviation at least `r·ℓ/(r-ℓ)·(mu-tau)²`. -/
theorem count_parity_variance_floor {r : ℕ} (a : Fin r → ℝ) (L : Finset (Fin r))
    (mu tau : ℝ) (hL : ∀ i ∈ L, a i ≤ tau) (hmean : ∑ i, a i = (r : ℝ) * mu)
    (hlt : tau < mu) (hcard : L.card < r) (hpos : 0 < L.card) :
    (r : ℝ) * (L.card : ℝ) / ((r : ℝ) - (L.card : ℝ)) * (mu - tau) ^ 2
      ≤ ∑ i, (a i - mu) ^ 2 := by
  classical
  set l : ℝ := (L.card : ℝ) with hl
  have hlpos : (0 : ℝ) < l := by rw [hl]; exact_mod_cast hpos
  have hlr : l < (r : ℝ) := by rw [hl]; exact_mod_cast hcard
  have hrl : (0 : ℝ) < (r : ℝ) - l := by linarith
  have hexc : (0 : ℝ) < mu - tau := by linarith
  have hccard : ((Lᶜ.card : ℕ) : ℝ) = (r : ℝ) - l := by
    rw [Finset.card_compl, Fintype.card_fin, Nat.cast_sub (le_of_lt hcard), hl]
  -- the deviations total zero
  have htot0 : ∑ i, (a i - mu) = 0 := by
    rw [Finset.sum_sub_distrib, hmean, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]
    ring
  have hsplit : ∑ i ∈ L, (a i - mu) ^ 2 + ∑ i ∈ Lᶜ, (a i - mu) ^ 2 = ∑ i, (a i - mu) ^ 2 :=
    Finset.sum_add_sum_compl L _
  -- the losing seeds each deviate by at least the excess
  have hLbound : l * (mu - tau) ^ 2 ≤ ∑ i ∈ L, (a i - mu) ^ 2 := by
    have hterm : ∀ i ∈ L, (mu - tau) ^ 2 ≤ (a i - mu) ^ 2 := by
      intro i hi
      have h := hL i hi
      nlinarith [h, hexc]
    calc l * (mu - tau) ^ 2 = ∑ _i ∈ L, (mu - tau) ^ 2 := by
          rw [Finset.sum_const, nsmul_eq_mul, hl]
      _ ≤ ∑ i ∈ L, (a i - mu) ^ 2 := Finset.sum_le_sum hterm
  -- the winning seeds carry a forced surplus
  have hD : l * (mu - tau) ≤ ∑ i ∈ Lᶜ, (a i - mu) := by
    have hsum : ∑ i ∈ L, (a i - mu) + ∑ i ∈ Lᶜ, (a i - mu) = 0 := by
      rw [Finset.sum_add_sum_compl]; exact htot0
    have hLsum : ∑ i ∈ L, (a i - mu) ≤ l * (tau - mu) := by
      calc ∑ i ∈ L, (a i - mu) ≤ ∑ _i ∈ L, (tau - mu) :=
            Finset.sum_le_sum fun i hi => by linarith [hL i hi]
        _ = l * (tau - mu) := by rw [Finset.sum_const, nsmul_eq_mul, hl]
    linarith
  have hCS : (∑ i ∈ Lᶜ, (a i - mu)) ^ 2 ≤ ((Lᶜ.card : ℕ) : ℝ) * ∑ i ∈ Lᶜ, (a i - mu) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  rw [hccard] at hCS
  have hDsq : (l * (mu - tau)) ^ 2 ≤ (∑ i ∈ Lᶜ, (a i - mu)) ^ 2 := by
    nlinarith [hD, mul_pos hlpos hexc]
  have hCbound : l ^ 2 * (mu - tau) ^ 2 / ((r : ℝ) - l) ≤ ∑ i ∈ Lᶜ, (a i - mu) ^ 2 := by
    rw [div_le_iff₀ hrl]
    nlinarith [hCS, hDsq]
  have hrewrite : (r : ℝ) * l / ((r : ℝ) - l) * (mu - tau) ^ 2
      = l * (mu - tau) ^ 2 + l ^ 2 * (mu - tau) ^ 2 / ((r : ℝ) - l) := by
    field_simp
    ring
  rw [hrewrite, ← hsplit]
  linarith

/-- The dispersion law as a floor on the pooled advantage *energy*, which is the quantity
the chord budget of `Algebra.ZeroFitDialU64Replication` controls. -/
theorem count_parity_energy_floor {r : ℕ} (a : Fin r → ℝ) (L : Finset (Fin r))
    (mu tau : ℝ) (hL : ∀ i ∈ L, a i ≤ tau) (hmean : ∑ i, a i = (r : ℝ) * mu)
    (hlt : tau < mu) (hcard : L.card < r) (hpos : 0 < L.card) :
    (r : ℝ) * mu ^ 2 + (r : ℝ) * (L.card : ℝ) / ((r : ℝ) - (L.card : ℝ)) * (mu - tau) ^ 2
      ≤ ∑ i, a i ^ 2 := by
  have hvar := count_parity_variance_floor a L mu tau hL hmean hlt hcard hpos
  have hexpand : ∑ i, (a i - mu) ^ 2 = ∑ i, a i ^ 2 - (r : ℝ) * mu ^ 2 := by
    have hpt : ∀ i, (a i - mu) ^ 2 = a i ^ 2 - 2 * mu * a i + mu ^ 2 := fun i => by ring
    rw [Finset.sum_congr rfl fun i _ => hpt i]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, hmean,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  rw [hexpand] at hvar
  linarith

/-! ## 2. The bridge: dispersion forces decorrelation -/

/-- **The bridge theorem.**  A count-parity record — `r` replications with advantage mean
`mu`, at least one and at most `r-1` of them at or below the bar `tau`, all with reading
products in `[P, 1]` — forces a decorrelation floor computed from the *summary statistics
alone*: no individual seed value is used. -/
theorem count_parity_forces_decorrelation {r : ℕ} (a b c alpha : Fin r → ℝ)
    (L : Finset (Fin r)) (cmin mu tau P : ℝ) (hr : 0 < r)
    (hg : ∀ i, a i ^ 2 + b i ^ 2 + c i ^ 2 ≤ 1 + 2 * (a i * b i * c i))
    (hnn : ∀ i, 0 ≤ alpha i) (hab : ∀ i, alpha i ≤ a i - b i)
    (hprod : ∀ i, a i * b i ≤ 1) (hfloor : ∀ i, P ≤ a i * b i)
    (hcmin : ∀ i, cmin ≤ c i) (hcle : cmin ≤ 1)
    (hL : ∀ i ∈ L, alpha i ≤ tau) (hmean : ∑ i, alpha i = (r : ℝ) * mu)
    (hlt : tau < mu) (hcard : L.card < r) (hpos : 0 < L.card) :
    mu ^ 2 + (L.card : ℝ) / ((r : ℝ) - (L.card : ℝ)) * (mu - tau) ^ 2
      ≤ 2 * (1 - cmin) * (1 - P) := by
  have hrR : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr
  have hen := count_parity_energy_floor alpha L mu tau hL hmean hlt hcard hpos
  have hbud := aggregated_budget_worst_case a b c alpha cmin hg hnn hab hprod hcmin
  -- the reading products push the headroom down
  have hsum : (r : ℝ) * P ≤ ∑ i, a i * b i := by
    have hconst : ∑ _i : Fin r, P = (r : ℝ) * P := by
      rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    calc (r : ℝ) * P = ∑ _i : Fin r, P := hconst.symm
      _ ≤ ∑ i, a i * b i := Finset.sum_le_sum fun i _ => hfloor i
  have hhead : 2 * (1 - cmin) * ((r : ℝ) - ∑ i, a i * b i) ≤ 2 * (1 - cmin) * (1 - P) * (r : ℝ) := by
    have hc : (0 : ℝ) ≤ 2 * (1 - cmin) := by linarith
    nlinarith [hsum, hc]
  -- assemble and divide by r
  have hkey : (r : ℝ) * mu ^ 2
      + (r : ℝ) * (L.card : ℝ) / ((r : ℝ) - (L.card : ℝ)) * (mu - tau) ^ 2
      ≤ 2 * (1 - cmin) * (1 - P) * (r : ℝ) := by linarith
  have hrl : (0 : ℝ) < (r : ℝ) - (L.card : ℝ) := by
    have : ((L.card : ℕ) : ℝ) < (r : ℝ) := by exact_mod_cast hcard
    linarith
  have hfac : (r : ℝ) * mu ^ 2
      + (r : ℝ) * (L.card : ℝ) / ((r : ℝ) - (L.card : ℝ)) * (mu - tau) ^ 2
      = (r : ℝ) * (mu ^ 2 + (L.card : ℝ) / ((r : ℝ) - (L.card : ℝ)) * (mu - tau) ^ 2) := by
    field_simp
  rw [hfac] at hkey
  have := (mul_le_mul_iff_of_pos_left hrR).mp
    (by linarith [hkey] :
      (r : ℝ) * (mu ^ 2 + (L.card : ℝ) / ((r : ℝ) - (L.card : ℝ)) * (mu - tau) ^ 2)
        ≤ (r : ℝ) * (2 * (1 - cmin) * (1 - P)))
  exact this

/-! ## 3. The recorded cell -/

/-- **Summary-statistics decorrelation floor for the bitlen-64 record.**  Six seeds with
advantage mean `0.059`, three of them at or below the bar `0.05`, and reading products at
least `1/3`, force `cmin ≤ 1 - 5343/2000000` — using no seedwise value at all. -/
theorem six_seed_count_parity_decorrelation (a b c alpha : Fin 6 → ℝ) (L : Finset (Fin 6))
    (cmin : ℝ)
    (hg : ∀ i, a i ^ 2 + b i ^ 2 + c i ^ 2 ≤ 1 + 2 * (a i * b i * c i))
    (hnn : ∀ i, 0 ≤ alpha i) (hab : ∀ i, alpha i ≤ a i - b i)
    (hprod : ∀ i, a i * b i ≤ 1) (hfloor : ∀ i, (1 : ℝ) / 3 ≤ a i * b i)
    (hcmin : ∀ i, cmin ≤ c i) (hcle : cmin ≤ 1)
    (hLcard : L.card = 3) (hL : ∀ i ∈ L, alpha i ≤ 50 / 1000)
    (hmean : ∑ i, alpha i = 6 * (59 / 1000)) :
    cmin ≤ 1 - 5343 / 2000000 := by
  have hbridge := count_parity_forces_decorrelation a b c alpha L cmin (59 / 1000)
    (50 / 1000) (1 / 3) (by norm_num) hg hnn hab hprod hfloor hcmin hcle hL
    (by rw [hmean]; norm_num) (by norm_num) (by rw [hLcard]; norm_num)
    (by rw [hLcard]; norm_num)
  rw [hLcard] at hbridge
  norm_num at hbridge
  linarith

/-- The recorded six-seed advantage record has total squared deviation at least
`486/1000000` — the dispersion that count parity forces. -/
theorem six_seed_dispersion_floor (alpha : Fin 6 → ℝ) (L : Finset (Fin 6))
    (hLcard : L.card = 3) (hL : ∀ i ∈ L, alpha i ≤ 50 / 1000)
    (hmean : ∑ i, alpha i = 6 * (59 / 1000)) :
    (486 : ℝ) / 1000000 ≤ ∑ i, (alpha i - 59 / 1000) ^ 2 := by
  have h := count_parity_variance_floor alpha L (59 / 1000) (50 / 1000) hL
    (by rw [hmean]; norm_num) (by norm_num) (by rw [hLcard]; norm_num)
    (by rw [hLcard]; norm_num)
  rw [hLcard] at h
  norm_num at h ⊢
  linarith

/-- In the balanced case the dispersion law says the advantage standard deviation is at
least the excess of the mean over the bar. -/
theorem balanced_sd_floor {r : ℕ} (a : Fin r → ℝ) (L : Finset (Fin r)) (mu tau : ℝ)
    (hL : ∀ i ∈ L, a i ≤ tau) (hmean : ∑ i, a i = (r : ℝ) * mu) (hlt : tau < mu)
    (hbal : 2 * L.card = r) (hpos : 0 < L.card) :
    (r : ℝ) * (mu - tau) ^ 2 ≤ ∑ i, (a i - mu) ^ 2 := by
  have hcard : L.card < r := by omega
  have h := count_parity_variance_floor a L mu tau hL hmean hlt hcard hpos
  have hrl : ((r : ℕ) : ℝ) - (L.card : ℝ) = (L.card : ℝ) := by
    have : ((r : ℕ) : ℝ) = 2 * (L.card : ℝ) := by exact_mod_cast hbal.symm
    rw [this]; ring
  rw [hrl] at h
  have hlpos : (0 : ℝ) < (L.card : ℝ) := by exact_mod_cast hpos
  rwa [mul_div_assoc, div_self (ne_of_gt hlpos), mul_one] at h

end Catalog.Algebra.ZeroFitDialU64Dispersion