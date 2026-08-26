import Mathlib
import Algebra.ZeroFitDialU72Parity
import Algebra.ZeroFitDialParityCapacity
import Algebra.ZeroFitDialU64MedianCapacity
import Algebra.ZeroFitDialU64CapacityJump
import Algebra.ZeroFitDialU64ExtremalDimension

/-!
# The exact capacity law and the mean-correlation floor

## Research context

Seventh cycle on the `U64B-DIAL-HOLDS-COUNT-PARITY` record (exp 543).  Conjecture **N2′**
of the thread observed that the uniform cap `γ` in `correlated_family_capacity` is only the
crudest possible estimate of the quadratic form `𝟙ᵀG𝟙` of the Gram matrix, and asked for
the sharp version.  This file isolates the *master* inequality that every capacity
statement in the thread is a corollary of, and derives from it a strictly stronger floor at
the recorded cell.

## Main results

* `capacity_exact_law` — **the master law.**  For any family `u` and any unit response `w`
  with all readings at least `ρ ≥ 0`,

  `(k·ρ)² ≤ ∑ᵢ ∑ⱼ ⟨uᵢ, uⱼ⟩`.

  There are no hypotheses on the family at all — the statistics need not be normalised and
  their correlations need not be bounded.  Everything else in the thread's capacity theory
  is an estimate of the right-hand side.
* `capacity_row_sum_law` — bounding each Gram row by `R` gives `k·ρ² ≤ R`, which
  immediately recovers the interpolating law (`capacity_recovers_uniform_law`) with
  `R = 1 + (k-1)γ`.  The row-sum version is strictly more general: it needs no uniform cap,
  only a bound on the total influence of each statistic.
* `capacity_frobenius_law` — the estimate through the Frobenius norm:
  `(k·ρ²)² ≤ ∑ᵢ ∑ⱼ ⟨uᵢ, uⱼ⟩²`.  This is the form that survives when a measured correlation
  matrix has a few large entries and many small ones, where the uniform cap is hopeless.
* `offdiag_correlation_floor` — read on the off-diagonal: a unit family reading `ρ` has
  `k²ρ² - k ≤ ∑ᵢ ∑_{j ≠ i} ⟨uᵢ, uⱼ⟩`, so the *total* correlation, not merely the maximum, is
  forced up.
* `capacity_exact_law_sharp` — the master law is attained: the equidistant realiser in its
  minimal ambient dimension turns it into an equality for every `(k, γ)`.
* `u64b_triple_mean_correlation_floor` — **the sharpened record floor.**  Three unit
  statistics all reading the replicated dial value `0.641` must have
  `⟨u₀,u₁⟩ + ⟨u₀,u₂⟩ + ⟨u₁,u₂⟩ ≥ 697929/2000000`, i.e. **mean** pairwise correlation at
  least `0.1163215`.  The earlier `u64b_triple_correlation_floor` only forced *some* pair
  to reach that value; here every configuration must reach it on average, so a triple
  cannot buy its admissibility with one strongly correlated pair and two nearly orthogonal
  ones.

## Scientific payload

The uniform capacity law, the parity ceiling and the orthonormal ceiling are all
one-parameter shadows of a single inequality that involves nothing but the total of the
Gram matrix.  Once that is visible, the recorded cell's constraint sharpens for free from a
statement about the worst pair to a statement about the average pair — which is the
quantity an experiment actually measures.  The Frobenius form indicates where the next
sharpening lies: a measured correlation matrix is never flat, and its energy, not its
maximum, is what the dial reading pays for.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU64ExactCapacity

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialParityCapacity
open Catalog.Algebra.ZeroFitDialU64MedianCapacity
open Catalog.Algebra.ZeroFitDialU64ExtremalDimension

variable {n k : ℕ}

/-! ## 1. The master law -/

/-- **The exact capacity law.**  A family of statistics all reading at least `rho ≥ 0`
against a unit response satisfies `(k·rho)² ≤ 𝟙ᵀG𝟙`, the total of its Gram matrix.  No
hypothesis is placed on the family. -/
theorem capacity_exact_law {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ} {rho : ℝ}
    (hw : dot w w = 1) (hrho : 0 ≤ rho) (hread : ∀ i, rho ≤ dot (u i) w) :
    ((k : ℝ) * rho) ^ 2 ≤ ∑ i, ∑ j, dot (u i) (u j) := by
  classical
  set S : Fin n → ℝ := fun x => ∑ i, (1 : ℝ) * u i x with hS
  have hSw : dot S w = ∑ i, dot (u i) w := by
    rw [hS, dot_sum_left]
    exact Finset.sum_congr rfl fun i _ => one_mul _
  have hlow : (k : ℝ) * rho ≤ dot S w := by
    rw [hSw]
    calc (k : ℝ) * rho = ∑ _i : Fin k, rho := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      _ ≤ ∑ i, dot (u i) w := Finset.sum_le_sum fun i _ => hread i
  have hcs : dot S w ^ 2 ≤ dot S S := by
    have := dot_sq_le S w; rw [hw, mul_one] at this; exact this
  have hknn : (0 : ℝ) ≤ (k : ℝ) * rho := mul_nonneg (Nat.cast_nonneg k) hrho
  have hsq : ((k : ℝ) * rho) ^ 2 ≤ dot S w ^ 2 := by nlinarith [hlow, hknn]
  rw [← dot_sum_self_eq u]
  linarith

/-- **Row-sum form.**  A bound on every Gram row bounds the capacity.  This needs no
uniform cap on the individual correlations. -/
theorem capacity_row_sum_law {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ} {rho R : ℝ}
    (hw : dot w w = 1) (hrho : 0 ≤ rho) (hk : 1 ≤ k) (hread : ∀ i, rho ≤ dot (u i) w)
    (hrow : ∀ i, ∑ j, dot (u i) (u j) ≤ R) :
    (k : ℝ) * rho ^ 2 ≤ R := by
  have hkpos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hex := capacity_exact_law hw hrho hread
  have htot : ∑ i, ∑ j, dot (u i) (u j) ≤ (k : ℝ) * R := by
    calc ∑ i, ∑ j, dot (u i) (u j) ≤ ∑ _i : Fin k, R := Finset.sum_le_sum fun i _ => hrow i
      _ = (k : ℝ) * R := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  nlinarith [hex, htot, hkpos]

/-- The interpolating capacity law of `Algebra.ZeroFitDialU64MedianCapacity` is the
row-sum law applied with the uniform bound `1 + (k-1)γ`. -/
theorem capacity_recovers_uniform_law {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ}
    {gamma rho : ℝ} (hu : IsGammaFamily u gamma) (hw : dot w w = 1) (hrho : 0 ≤ rho)
    (hk : 1 ≤ k) (hread : ∀ i, rho ≤ dot (u i) w) :
    (k : ℝ) * rho ^ 2 ≤ 1 + ((k : ℝ) - 1) * gamma :=
  capacity_row_sum_law hw hrho hk hread fun i => gamma_family_row_le hu i

/-- **Frobenius form.**  The capacity is bounded by the *energy* of the Gram matrix, which
is the estimate that survives when the correlation matrix is far from flat. -/
theorem capacity_frobenius_law {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ} {rho : ℝ}
    (hw : dot w w = 1) (hrho : 0 ≤ rho) (hk : 1 ≤ k) (hread : ∀ i, rho ≤ dot (u i) w) :
    ((k : ℝ) * rho ^ 2) ^ 2 ≤ ∑ i, ∑ j, dot (u i) (u j) ^ 2 := by
  classical
  have hkpos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hex := capacity_exact_law hw hrho hread
  -- Cauchy–Schwarz on the rows, then on each row
  have hrow : ∀ i : Fin k, (∑ j, dot (u i) (u j)) ^ 2 ≤ (k : ℝ) * ∑ j, dot (u i) (u j) ^ 2 := by
    intro i
    have := sq_sum_le_card_mul_sum_sq (s := (univ : Finset (Fin k)))
      (f := fun j => dot (u i) (u j))
    rwa [Finset.card_univ, Fintype.card_fin] at this
  have houter : (∑ i, ∑ j, dot (u i) (u j)) ^ 2
      ≤ (k : ℝ) * ∑ i, (∑ j, dot (u i) (u j)) ^ 2 := by
    have := sq_sum_le_card_mul_sum_sq (s := (univ : Finset (Fin k)))
      (f := fun i => ∑ j, dot (u i) (u j))
    rwa [Finset.card_univ, Fintype.card_fin] at this
  have hinner : ∑ i, (∑ j, dot (u i) (u j)) ^ 2
      ≤ (k : ℝ) * ∑ i, ∑ j, dot (u i) (u j) ^ 2 := by
    calc ∑ i, (∑ j, dot (u i) (u j)) ^ 2
        ≤ ∑ i, (k : ℝ) * ∑ j, dot (u i) (u j) ^ 2 := Finset.sum_le_sum fun i _ => hrow i
      _ = (k : ℝ) * ∑ i, ∑ j, dot (u i) (u j) ^ 2 := by rw [← Finset.mul_sum]
  have hchain : (∑ i, ∑ j, dot (u i) (u j)) ^ 2
      ≤ (k : ℝ) ^ 2 * ∑ i, ∑ j, dot (u i) (u j) ^ 2 := by nlinarith [houter, hinner, hkpos]
  have hnn : (0 : ℝ) ≤ ((k : ℝ) * rho) ^ 2 := sq_nonneg _
  have hsq : (((k : ℝ) * rho) ^ 2) ^ 2 ≤ (∑ i, ∑ j, dot (u i) (u j)) ^ 2 := by
    nlinarith [hex, hnn]
  have hkk : (0 : ℝ) < (k : ℝ) ^ 2 := by positivity
  have hid : (((k : ℝ) * rho) ^ 2) ^ 2 = (k : ℝ) ^ 2 * ((k : ℝ) * rho ^ 2) ^ 2 := by ring
  have hfin : (k : ℝ) ^ 2 * ((k : ℝ) * rho ^ 2) ^ 2
      ≤ (k : ℝ) ^ 2 * ∑ i, ∑ j, dot (u i) (u j) ^ 2 := by
    rw [← hid]; linarith [hsq, hchain]
  exact (mul_le_mul_iff_of_pos_left hkk).mp hfin

/-! ## 2. The off-diagonal floor -/

/-- **Total correlation floor.**  For a family of *unit* statistics all reading `rho`, the
sum of all off-diagonal Gram entries is at least `k²ρ² - k`. -/
theorem offdiag_correlation_floor {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ} {rho : ℝ}
    (hunit : ∀ i, dot (u i) (u i) = 1) (hw : dot w w = 1) (hrho : 0 ≤ rho)
    (hread : ∀ i, rho ≤ dot (u i) w) :
    (k : ℝ) ^ 2 * rho ^ 2 - (k : ℝ) ≤ ∑ i, ∑ j ∈ univ.erase i, dot (u i) (u j) := by
  classical
  have hex := capacity_exact_law hw hrho hread
  have hsplit : ∑ i, ∑ j, dot (u i) (u j)
      = (k : ℝ) + ∑ i, ∑ j ∈ univ.erase i, dot (u i) (u j) := by
    have hrow : ∀ i : Fin k, ∑ j, dot (u i) (u j)
        = 1 + ∑ j ∈ univ.erase i, dot (u i) (u j) := by
      intro i
      rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i), hunit i]
    rw [Finset.sum_congr rfl fun i _ => hrow i, Finset.sum_add_distrib, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]
  rw [hsplit] at hex
  nlinarith [hex]

/-! ## 3. Sharpness -/

/-- The master law has no slack: the equidistant realiser in its minimal ambient dimension
turns it into an equality for every admissible `(k, gamma)`. -/
theorem capacity_exact_law_sharp {gamma : ℝ} (hk : 1 ≤ k) (hg1 : gamma ≤ 1)
    (hgk : 0 ≤ 1 + ((k : ℝ) - 1) * gamma) :
    ∃ (u : Fin k → (Fin k → ℝ)) (w : Fin k → ℝ) (rho : ℝ),
      dot w w = 1 ∧ 0 ≤ rho ∧ (∀ i, rho ≤ dot (u i) w) ∧
        ((k : ℝ) * rho) ^ 2 = ∑ i, ∑ j, dot (u i) (u j) := by
  classical
  obtain ⟨u, w, hdiag, hoff, hww, hread⟩ := equidistant_realizable_dimension_k hk hg1 hgk
  have hkpos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  refine ⟨u, w, Real.sqrt ((1 + ((k : ℝ) - 1) * gamma) / (k : ℝ)), hww, Real.sqrt_nonneg _,
    fun i => le_of_eq (hread i).symm, ?_⟩
  have hrho2 : Real.sqrt ((1 + ((k : ℝ) - 1) * gamma) / (k : ℝ)) ^ 2
      = (1 + ((k : ℝ) - 1) * gamma) / (k : ℝ) :=
    Real.sq_sqrt (div_nonneg hgk (le_of_lt hkpos))
  have hrow : ∀ i : Fin k, ∑ j, dot (u i) (u j) = 1 + ((k : ℝ) - 1) * gamma := by
    intro i
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i), hdiag i]
    have hall : ∀ j ∈ univ.erase i, dot (u i) (u j) = gamma :=
      fun j hj => hoff i j (Ne.symm (Finset.ne_of_mem_erase hj))
    rw [Finset.sum_congr rfl hall, Finset.sum_const, nsmul_eq_mul, erase_univ_card i]
  rw [Finset.sum_congr rfl fun i _ => hrow i, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, mul_pow, hrho2]
  field_simp

/-! ## 4. The recorded cell -/

/-- **The sharpened floor at bitlen 64.**  Three unit statistics all reading the replicated
dial value `0.641` against a unit response must have total pairwise correlation at least
`697929/2000000`, i.e. *mean* pairwise correlation at least `0.1163215`.  This strictly
strengthens `u64b_triple_correlation_floor`, which only forced one pair to that level. -/
theorem u64b_triple_mean_correlation_floor {u : Fin 3 → (Fin n → ℝ)} {w : Fin n → ℝ}
    (hunit : ∀ i, dot (u i) (u i) = 1) (hw : dot w w = 1)
    (hread : ∀ i, (641 : ℝ) / 1000 ≤ dot (u i) w) :
    697929 / 2000000 ≤ dot (u 0) (u 1) + dot (u 0) (u 2) + dot (u 1) (u 2) := by
  have hex := capacity_exact_law (k := 3) hw (by norm_num) hread
  rw [Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three] at hex
  rw [hunit 0, hunit 1, hunit 2, dot_comm (u 1) (u 0), dot_comm (u 2) (u 0),
    dot_comm (u 2) (u 1)] at hex
  norm_num at hex
  linarith

end Catalog.Algebra.ZeroFitDialU64ExactCapacity