import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.PoleOrderObstructionSymmetric

/-!
# Cycle 5: the level-`k` Newton identities for Monster-type Laurent products

Earlier cycles established the *pole-order obstruction* for products of
normalized `q`-series `f = q⁻¹ + a₀ + a₁ q + ⋯`:

* `Shared.PoleOrderObstruction` — a product of `m` such series has a pole of
  order exactly `m`, and the corrected product `q ^ m · ∏ fᵢ` is the image of a
  **unit of `ℂ⟦X⟧`** (`isUnit_normalizedProduct`);
* `Shared.PoleOrderObstructionSymmetric` — the master shift identity
  `coeff (k - m) (∏ fᵢ) = coeff k (∏ normalizedPart fᵢ)`.

On the *coefficient* side only two instances were known: level `1`
(`coeff_prod_normalized_subleading`: the coefficient in degree `1 - m` is
`∑ᵢ a₀(fᵢ)`) and level `2` (`coeff_prod_normalized_subsubleading`, a Newton
identity in `a₀` and `a₁`).  The general level `k` was open except in the
degenerate "linear" case `fᵢ = q⁻¹ + aᵢ`, where the answer is the elementary
symmetric function `e_k` (`coeff_prod_linTrace`).

This file closes the level-`k` problem, in three independent ways.

## 1. Closed formula (multi-Cauchy form)

`coeff_prod_normalized_level`:
```
(∏ i ∈ s, f i).coeff (k - |s|) = ∑_{ν ∈ finsuppAntidiag s k} ∏_{i ∈ s} (f i).coeff (ν i - 1)
```
The formula is *uniform*: no case distinction is needed, because for a
normalized series the value `f.coeff (-1) = 1` is exactly the neutral element
supplied by the exponents `ν i = 0`.  This is the arithmetic shadow of the
factorization `∏ fᵢ = q⁻ᵐ · (unit of ℂ⟦X⟧)`.

## 2. Locality: at most `k` factors are excited

`finsuppAntidiag_support_card_le` and `coeff_prod_normalized_level_local` refine
the sum into a sum over *subsets* `t ⊆ s` with `|t| ≤ k`.  Thus the coefficient
in degree `k - m` is a universal polynomial in the tails of at most `k` of the
`m` factors — for the Monster (`m = 194`) an enormous reduction, and the exact
generalization of "`e_k` only sees `k`-subsets" from the linear case.
`coeff_prod_normalized_level_congr` is the companion truncation statement: the
level-`k` coefficient depends only on the coefficients of the factors in degrees
`< k`.

## 3. Newton recursion via the logarithmic derivative

`newton_recursion_normalized` proves the genuine Newton-type recursion
```
(k+1) · c_{k+1} = ∑_{j ≤ k} c_j · p_{k-j},    p_r := ∑_i coeff r (fᵢ'/fᵢ)
```
where `c_j = coeff (j - m) (∏ fᵢ)` and the "power sums" `p_r` are the
coefficients of the logarithmic derivative of the unit parts.  This is the exact
analogue of Newton's identity `k eₖ = ∑ (-1)^{j-1} e_{k-j} p_j`, valid for
arbitrary tails.  The engine is `derivative_prod_logDeriv`, the statement that
the logarithmic derivative turns products of units of `ℂ⟦X⟧` into sums.

## 4. Consistency and lab notes

`level_one_consistency` and `level_two_consistency` show that the new closed
formula reproduces, at `k = 1` and `k = 2`, exactly the two identities proved in
the earlier cycles; `level_linear_consistency` shows it reproduces the
elementary symmetric functions in the linear case.  `newton_level_one` recovers
level `1` from the Newton recursion instead.  Section 6 contains two explicit
numerical instances checked inside Lean.
-/

namespace PoleOrderObstruction

open HahnSeries Finset PowerSeries

variable {ι : Type*} [DecidableEq ι]

/-! ## 1. The level-`k` closed formula -/

/-- **Level-`k` master formula.**  For a family of `m = |s|` normalized Laurent
series the coefficient in degree `k - m` is the multi-Cauchy sum
`∑_{ν} ∏ᵢ (fᵢ).coeff (νᵢ - 1)` over all ways `ν` of distributing `k` among the
factors.  Note that the formula needs no case distinction: an unexcited factor
contributes `f.coeff (-1) = 1`. -/
theorem coeff_prod_normalized_level (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℕ) :
    (∏ i ∈ s, f i).coeff ((k : ℤ) - (s.card : ℤ))
      = ∑ ν ∈ s.finsuppAntidiag k, ∏ i ∈ s, (f i).coeff ((ν i : ℤ) - 1) := by
  rw [coeff_prod_normalized_shift s f h k, PowerSeries.coeff_prod]
  exact Finset.sum_congr rfl fun ν _ =>
    Finset.prod_congr rfl fun i hi => coeff_normalizedPart (h i hi) (ν i)

/-- Each exponent occurring in the level-`k` sum is at most `k`. -/
theorem finsuppAntidiag_le {s : Finset ι} {k : ℕ} {ν : ι →₀ ℕ}
    (hν : ν ∈ s.finsuppAntidiag k) {i : ι} (hi : i ∈ s) : ν i ≤ k := by
  rw [Finset.mem_finsuppAntidiag] at hν
  rw [← hν.1]
  exact Finset.single_le_sum (f := fun j => ν j) (fun _ _ => Nat.zero_le _) hi

/-- **Locality bound.**  A term of the level-`k` sum excites at most `k` of the
factors: the support of the exponent vector has at most `k` elements. -/
theorem finsuppAntidiag_support_card_le {s : Finset ι} {k : ℕ} {ν : ι →₀ ℕ}
    (hν : ν ∈ s.finsuppAntidiag k) : ν.support.card ≤ k := by
  rw [Finset.mem_finsuppAntidiag] at hν
  obtain ⟨hsum, hsupp⟩ := hν
  have hres : ∑ i ∈ ν.support, ν i = k := by
    rw [← hsum]
    exact Finset.sum_subset hsupp (by
      intro x _ hx
      simpa using hx)
  calc ν.support.card = ∑ _i ∈ ν.support, 1 := by simp
    _ ≤ ∑ i ∈ ν.support, ν i :=
        Finset.sum_le_sum fun i hi => Nat.one_le_iff_ne_zero.mpr (by simpa using hi)
    _ = k := hres

omit [DecidableEq ι] in
/-- Unexcited factors contribute the neutral value `f.coeff (-1) = 1`, so the
product in the level-`k` sum ranges effectively over the support of `ν`. -/
theorem prod_coeff_eq_prod_support {s : Finset ι} {f : ι → LC}
    (h : ∀ i ∈ s, IsNormalized (f i)) {ν : ι →₀ ℕ} (hsupp : ν.support ⊆ s) :
    ∏ i ∈ s, (f i).coeff ((ν i : ℤ) - 1) = ∏ i ∈ ν.support, (f i).coeff ((ν i : ℤ) - 1) := by
  refine (Finset.prod_subset hsupp ?_).symm
  intro i hi hzero
  have h0 : ν i = 0 := by simpa using hzero
  rw [h0]
  simpa using (h i hi).coeff_neg_one

/-- **Level-`k` locality decomposition.**  The level-`k` coefficient splits as a
sum over the subsets `t ⊆ s` of size at most `k` of the contributions of the
exponent vectors supported exactly on `t`.  In particular, for the Monster-sized
product only `≤ k` of the `194` factors interact at level `k`. -/
theorem coeff_prod_normalized_level_local (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℕ) :
    (∏ i ∈ s, f i).coeff ((k : ℤ) - (s.card : ℤ))
      = ∑ t ∈ s.powerset with t.card ≤ k,
          ∑ ν ∈ s.finsuppAntidiag k with ν.support = t,
            ∏ i ∈ t, (f i).coeff ((ν i : ℤ) - 1) := by
  rw [coeff_prod_normalized_level s f h k]
  have hmaps : ∀ ν ∈ s.finsuppAntidiag k,
      ν.support ∈ {t ∈ s.powerset | t.card ≤ k} := by
    intro ν hν
    simp only [Finset.mem_filter, Finset.mem_powerset]
    exact ⟨(Finset.mem_finsuppAntidiag.mp hν).2, finsuppAntidiag_support_card_le hν⟩
  rw [← Finset.sum_fiberwise_of_maps_to hmaps
    (fun ν => ∏ i ∈ s, (f i).coeff ((ν i : ℤ) - 1))]
  refine Finset.sum_congr rfl fun t _ => Finset.sum_congr rfl fun ν hν => ?_
  rw [Finset.mem_filter] at hν
  rw [prod_coeff_eq_prod_support h (Finset.mem_finsuppAntidiag.mp hν.1).2, hν.2]

/-- **Truncation locality.**  The level-`k` coefficient of a product of
normalized series depends only on the coefficients of the factors in degrees
`< k`; everything deeper in the tails is invisible. -/
theorem coeff_prod_normalized_level_congr (s : Finset ι) (f g : ι → LC)
    (hf : ∀ i ∈ s, IsNormalized (f i)) (hg : ∀ i ∈ s, IsNormalized (g i)) (k : ℕ)
    (hagree : ∀ i ∈ s, ∀ j : ℕ, j < k → (f i).coeff (j : ℤ) = (g i).coeff (j : ℤ)) :
    (∏ i ∈ s, f i).coeff ((k : ℤ) - (s.card : ℤ))
      = (∏ i ∈ s, g i).coeff ((k : ℤ) - (s.card : ℤ)) := by
  rw [coeff_prod_normalized_level s f hf k, coeff_prod_normalized_level s g hg k]
  refine Finset.sum_congr rfl fun ν hν => Finset.prod_congr rfl fun i hi => ?_
  rcases Nat.eq_zero_or_pos (ν i) with h0 | hpos
  · rw [h0]
    have h1 := (hf i hi).coeff_neg_one
    have h2 := (hg i hi).coeff_neg_one
    simp only [Nat.cast_zero, zero_sub]
    rw [h1, h2]
  · obtain ⟨r, hr⟩ : ∃ r : ℕ, ν i = r + 1 := ⟨ν i - 1, by omega⟩
    have hrk : r < k := by
      have := finsuppAntidiag_le hν hi
      omega
    have hcast : ((ν i : ℤ)) - 1 = (r : ℤ) := by rw [hr]; push_cast; ring
    rw [hcast]
    exact hagree i hi r hrk

/-! ## 2. Consistency with the level `0`, `1` and `2` identities -/

/-- The level-`k` formula at `k = 0`: the pole coefficient of a product of `m`
normalized series, in degree `-m`, is `1`.  The single exponent vector `ν = 0`
contributes `∏ᵢ fᵢ.coeff (-1) = 1`. -/
theorem level_zero_pole (s : Finset ι) (f : ι → LC) (h : ∀ i ∈ s, IsNormalized (f i)) :
    (∏ i ∈ s, f i).coeff (-(s.card : ℤ)) = 1 := by
  have h0 := coeff_prod_normalized_level s f h 0
  rw [Nat.cast_zero, zero_sub, Finset.finsuppAntidiag_zero, Finset.sum_singleton] at h0
  rw [h0]
  refine Finset.prod_eq_one fun i hi => ?_
  simp only [Finsupp.coe_zero, Pi.zero_apply, Nat.cast_zero, zero_sub]
  exact (h i hi).coeff_neg_one

/-- The level-`k` formula at `k = 1` reproduces cycle 1's subleading identity:
the sum over the `|s|` one-element exponent vectors is `∑ᵢ a₀(fᵢ)`. -/
theorem level_one_consistency (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    ∑ ν ∈ s.finsuppAntidiag (1 : ℕ), ∏ i ∈ s, (f i).coeff ((ν i : ℤ) - 1)
      = ∑ i ∈ s, (f i).coeff 0 := by
  have h1 := coeff_prod_normalized_level s f h 1
  have h2 := coeff_prod_normalized_subleading s f h
  rw [show ((1 : ℕ) : ℤ) - (s.card : ℤ) = 1 - (s.card : ℤ) by push_cast; ring] at h1
  rw [← h1, h2]

/-- The level-`k` formula at `k = 2` reproduces cycle 2's Newton identity in the
first two tail coefficients. -/
theorem level_two_consistency (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    2 * ∑ ν ∈ s.finsuppAntidiag (2 : ℕ), ∏ i ∈ s, (f i).coeff ((ν i : ℤ) - 1)
      = 2 * (∑ i ∈ s, (f i).coeff 1)
        + (∑ i ∈ s, (f i).coeff 0) ^ 2
        - ∑ i ∈ s, ((f i).coeff 0) ^ 2 := by
  have h1 := coeff_prod_normalized_level s f h 2
  have h2 := coeff_prod_normalized_subsubleading s f h
  rw [show ((2 : ℕ) : ℤ) - (s.card : ℤ) = 2 - (s.card : ℤ) by push_cast; ring] at h1
  rw [← h1, h2]

/-- In the linear case `fᵢ = q⁻¹ + aᵢ` the level-`k` formula collapses to the
`k`-th elementary symmetric function: all exponents are `0` or `1`. -/
theorem level_linear_consistency (s : Finset ι) (a : ι → ℂ) (k : ℕ) :
    ∑ ν ∈ s.finsuppAntidiag k, ∏ i ∈ s, (linTrace (a i)).coeff ((ν i : ℤ) - 1)
      = ∑ t ∈ s.powersetCard k, ∏ i ∈ t, a i := by
  have h1 := coeff_prod_normalized_level s (fun i => linTrace (a i))
    (fun i _ => isNormalized_linTrace (a i)) k
  rw [← h1, coeff_prod_linTrace s a k]

/-! ## 3. The logarithmic derivative and the Newton recursion -/

/-- The logarithmic derivative `g'/g` of a power series over `ℂ`. -/
noncomputable def psLogDeriv (g : PowerSeries ℂ) : PowerSeries ℂ :=
  (PowerSeries.derivative ℂ) g * g⁻¹

/-- **The logarithmic derivative linearizes products of units.**  For a finite
family of power series with nonzero constant term,
`(∏ gᵢ)' = (∏ gᵢ) · ∑ᵢ gᵢ'/gᵢ`. -/
theorem derivative_prod_logDeriv (s : Finset ι) (g : ι → PowerSeries ℂ)
    (h : ∀ i ∈ s, PowerSeries.constantCoeff (g i) ≠ 0) :
    (PowerSeries.derivative ℂ) (∏ i ∈ s, g i)
      = (∏ i ∈ s, g i) * ∑ i ∈ s, psLogDeriv (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      have hsub : ∀ i ∈ s, PowerSeries.constantCoeff (g i) ≠ 0 :=
        fun i hi => h i (Finset.mem_insert_of_mem hi)
      have hu : g a * (g a)⁻¹ = 1 :=
        PowerSeries.mul_inv_cancel _ (h a (Finset.mem_insert_self a s))
      rw [Finset.prod_insert ha, Finset.sum_insert ha, Derivation.leibniz, smul_eq_mul,
        smul_eq_mul, ih hsub, psLogDeriv]
      linear_combination
        (-(∏ i ∈ s, g i) * ((PowerSeries.derivative ℂ) (g a))) * hu

/-- **Newton recursion at level `k` for a product of unit power series.**  With
`c_j` the coefficients of the product and `p_r = ∑ᵢ coeff r (gᵢ'/gᵢ)` the power
sums of the logarithmic derivatives,
`(k+1) c_{k+1} = ∑_{j ≤ k} c_j p_{k-j}`. -/
theorem newton_recursion_powerSeries (s : Finset ι) (g : ι → PowerSeries ℂ)
    (h : ∀ i ∈ s, PowerSeries.constantCoeff (g i) ≠ 0) (k : ℕ) :
    ((k : ℂ) + 1) * PowerSeries.coeff (k + 1) (∏ i ∈ s, g i)
      = ∑ j ∈ Finset.range (k + 1),
          PowerSeries.coeff j (∏ i ∈ s, g i) *
            ∑ i ∈ s, PowerSeries.coeff (k - j) (psLogDeriv (g i)) := by
  have hmul : PowerSeries.coeff k ((∏ i ∈ s, g i) * ∑ i ∈ s, psLogDeriv (g i))
      = ∑ j ∈ Finset.range (k + 1),
          PowerSeries.coeff j (∏ i ∈ s, g i) *
            ∑ i ∈ s, PowerSeries.coeff (k - j) (psLogDeriv (g i)) := by
    rw [PowerSeries.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]
    exact Finset.sum_congr rfl fun j _ => by rw [map_sum]
  have hderiv : PowerSeries.coeff k ((PowerSeries.derivative ℂ) (∏ i ∈ s, g i))
      = PowerSeries.coeff (k + 1) (∏ i ∈ s, g i) * ((k : ℂ) + 1) :=
    PowerSeries.coeff_derivative _ _
  rw [derivative_prod_logDeriv s g h, hmul] at hderiv
  rw [mul_comm]
  exact hderiv.symm

/-- **Newton recursion at level `k` for Monster-type Laurent products.**  Write
`c_j = coeff (j - m) (∏ fᵢ)` for the Laurent coefficients of a product of `m`
normalized series, and `p_r = ∑ᵢ coeff r (uᵢ'/uᵢ)` for the power sums of the
logarithmic derivatives of the unit parts `uᵢ = q · fᵢ`.  Then
`(k+1) c_{k+1} = ∑_{j ≤ k} c_j p_{k-j}`.

This is the level-`k` Newton identity that cycles 1 and 2 verified only for
`k = 0` and `k = 1`. -/
theorem newton_recursion_normalized (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℕ) :
    ((k : ℂ) + 1) * (∏ i ∈ s, f i).coeff (((k : ℤ) + 1) - (s.card : ℤ))
      = ∑ j ∈ Finset.range (k + 1),
          (∏ i ∈ s, f i).coeff ((j : ℤ) - (s.card : ℤ)) *
            ∑ i ∈ s, PowerSeries.coeff (k - j) (psLogDeriv (normalizedPart (f i))) := by
  have hconst : ∀ i ∈ s, PowerSeries.constantCoeff (normalizedPart (f i)) ≠ 0 := by
    intro i hi
    rw [constantCoeff_normalizedPart (f i) (h i hi)]
    exact one_ne_zero
  have hmain := newton_recursion_powerSeries s (fun i => normalizedPart (f i)) hconst k
  have hshift : ∀ j : ℕ, (∏ i ∈ s, f i).coeff ((j : ℤ) - (s.card : ℤ))
      = PowerSeries.coeff j (∏ i ∈ s, normalizedPart (f i)) :=
    fun j => coeff_prod_normalized_shift s f h j
  rw [show ((k : ℤ) + 1) - (s.card : ℤ) = ((k + 1 : ℕ) : ℤ) - (s.card : ℤ) by push_cast; ring,
    hshift (k + 1)]
  rw [hmain]
  exact Finset.sum_congr rfl fun j _ => by rw [hshift j]

/-- The constant term of the logarithmic derivative of the unit part of a
normalized series is its constant Laurent coefficient `a₀`. -/
theorem coeff_zero_psLogDeriv_normalizedPart {f : LC} (h : IsNormalized f) :
    PowerSeries.coeff 0 (psLogDeriv (normalizedPart f)) = f.coeff 0 := by
  have hc : PowerSeries.constantCoeff (normalizedPart f) = 1 :=
    constantCoeff_normalizedPart f h
  rw [psLogDeriv, PowerSeries.coeff_zero_eq_constantCoeff, map_mul,
    PowerSeries.constantCoeff_inv, hc, inv_one, mul_one,
    ← PowerSeries.coeff_zero_eq_constantCoeff, PowerSeries.coeff_derivative]
  rw [coeff_one_normalizedPart f h]
  norm_num

/-- **Level `1` from the Newton recursion.**  Specializing the recursion to
`k = 0` recovers cycle 1's identity `c₁ = ∑ᵢ a₀(fᵢ)` — an independent proof
through the logarithmic derivative rather than through the Cauchy product. -/
theorem newton_level_one (s : Finset ι) (f : ι → LC) (h : ∀ i ∈ s, IsNormalized (f i)) :
    (∏ i ∈ s, f i).coeff (1 - (s.card : ℤ)) = ∑ i ∈ s, (f i).coeff 0 := by
  have hk := newton_recursion_normalized s f h 0
  rw [Finset.range_one, Finset.sum_singleton] at hk
  norm_num at hk
  rw [hk, level_zero_pole s f h, one_mul]
  refine Finset.sum_congr rfl fun i hi => ?_
  rw [← PowerSeries.coeff_zero_eq_constantCoeff]
  exact coeff_zero_psLogDeriv_normalizedPart (h i hi)

/-! ## 4. The Monster instance -/

/-- **Level-`k` closed formula for the Monstrous-Moonshine product.**  For the
`194` McKay–Thompson-shaped series the Laurent coefficient at degree `k - 194` is
the multi-Cauchy sum over exponent vectors of total weight `k`. -/
theorem coeff_prod_traceLaurent_194_level (c : Fin monsterClassCount → ℕ → ℂ) (k : ℕ) :
    (∏ i, traceLaurent (c i)).coeff ((k : ℤ) - 194)
      = ∑ ν ∈ (Finset.univ : Finset (Fin monsterClassCount)).finsuppAntidiag k,
          ∏ i, (traceLaurent (c i)).coeff ((ν i : ℤ) - 1) := by
  have h := coeff_prod_normalized_level (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i)) k
  rw [Finset.card_univ, Fintype.card_fin] at h
  simpa [monsterClassCount] using h

/-- **Monster locality.**  At level `k` at most `k` of the `194` McKay–Thompson
series interact. -/
theorem coeff_prod_traceLaurent_194_local (c : Fin monsterClassCount → ℕ → ℂ) (k : ℕ) :
    (∏ i, traceLaurent (c i)).coeff ((k : ℤ) - 194)
      = ∑ t ∈ (Finset.univ : Finset (Fin monsterClassCount)).powerset with t.card ≤ k,
          ∑ ν ∈ (Finset.univ : Finset (Fin monsterClassCount)).finsuppAntidiag k with
              ν.support = t,
            ∏ i ∈ t, (traceLaurent (c i)).coeff ((ν i : ℤ) - 1) := by
  have h := coeff_prod_normalized_level_local (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i)) k
  rw [Finset.card_univ, Fintype.card_fin,
    show ((monsterClassCount : ℕ) : ℤ) = (194 : ℤ) from by norm_num [monsterClassCount]] at h
  exact h

/-- **Monster Newton recursion.**  The Laurent coefficients of the full
Monstrous-Moonshine product satisfy the level-`k` Newton recursion. -/
theorem newton_recursion_traceLaurent_194 (c : Fin monsterClassCount → ℕ → ℂ) (k : ℕ) :
    ((k : ℂ) + 1) * (∏ i, traceLaurent (c i)).coeff (((k : ℤ) + 1) - 194)
      = ∑ j ∈ Finset.range (k + 1),
          (∏ i, traceLaurent (c i)).coeff ((j : ℤ) - 194) *
            ∑ i, PowerSeries.coeff (k - j)
              (psLogDeriv (normalizedPart (traceLaurent (c i)))) := by
  have h := newton_recursion_normalized (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i)) k
  rw [Finset.card_univ, Fintype.card_fin,
    show ((monsterClassCount : ℕ) : ℤ) = (194 : ℤ) from by norm_num [monsterClassCount]] at h
  exact h

/-! ## 5. Two-factor form and lab notes

The two-factor case of the level-`k` formula is a plain Cauchy convolution of
shifted coefficients; it is the smallest instance in which the interaction of
two full tails (not just constant terms) is visible. -/

/-- The level-`k` formula for two factors, in convolution form. -/
theorem coeff_mul_normalized_level (f g : LC) (hf : IsNormalized f) (hg : IsNormalized g)
    (k : ℕ) :
    (f * g).coeff ((k : ℤ) - 2)
      = ∑ j ∈ Finset.range (k + 1), f.coeff ((j : ℤ) - 1) * g.coeff (((k - j : ℕ) : ℤ) - 1) := by
  have hpow : HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f * normalizedPart g)
      = qSeries ^ 2 * (f * g) := by
    rw [map_mul, ofPowerSeries_normalizedPart f hf, ofPowerSeries_normalizedPart g hg]
    ring
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (normalizedPart f * normalizedPart g)).coeff
      ((k : ℕ) : ℤ) = PowerSeries.coeff k (normalizedPart f * normalizedPart g) :=
    HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) _ k
  rw [hpow, qSeries_pow, HahnSeries.coeff_single_mul, one_mul] at hcoe
  rw [show ((k : ℤ) - 2) = ((k : ℕ) : ℤ) - ((2 : ℕ) : ℤ) by push_cast; ring, hcoe,
    PowerSeries.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]
  exact Finset.sum_congr rfl fun j _ => by
    rw [coeff_normalizedPart hf j, coeff_normalizedPart hg (k - j)]

/-- Lab note: for `f = q⁻¹ + 2 + 3q` and `g = q⁻¹ + 5 + 7q` the coefficient of
`q` in `f · g` (level `k = 3`, pole order `2`) is
`1·0 + 2·7 + 3·5 + 0·1 = 29`. -/
theorem lab_note_level_three :
    (traceLaurent (fun n => if n = 0 then 2 else if n = 1 then 3 else 0) *
      traceLaurent (fun n => if n = 0 then 5 else if n = 1 then 7 else 0)).coeff (1 : ℤ)
      = 29 := by
  set a : ℕ → ℂ := fun n => if n = 0 then 2 else if n = 1 then 3 else 0 with ha
  set b : ℕ → ℂ := fun n => if n = 0 then 5 else if n = 1 then 7 else 0 with hb
  have h := coeff_mul_normalized_level (traceLaurent a) (traceLaurent b)
    (isNormalized_traceLaurent a) (isNormalized_traceLaurent b) 3
  rw [show ((3 : ℕ) : ℤ) - 2 = (1 : ℤ) by norm_num] at h
  rw [h]
  have hm1 : ∀ c : ℕ → ℂ, (traceLaurent c).coeff (-1 : ℤ) = 1 :=
    fun c => (isNormalized_traceLaurent c).coeff_neg_one
  have hc0 : ∀ c : ℕ → ℂ, (traceLaurent c).coeff (0 : ℤ) = c 0 := fun c => by
    have := coeff_traceLaurent c 0
    rwa [Nat.cast_zero] at this
  have hc1 : ∀ c : ℕ → ℂ, (traceLaurent c).coeff (1 : ℤ) = c 1 := fun c => by
    have := coeff_traceLaurent c 1
    rwa [Nat.cast_one] at this
  have hc2 : ∀ c : ℕ → ℂ, (traceLaurent c).coeff (2 : ℤ) = c 2 := fun c => by
    have := coeff_traceLaurent c 2
    norm_num at this
    exact this
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_one]
  norm_num [hm1, hc0, hc1, hc2, ha, hb]

end PoleOrderObstruction