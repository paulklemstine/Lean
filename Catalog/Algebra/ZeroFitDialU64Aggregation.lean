import Mathlib
import Algebra.ZeroFitDialU72Parity
import Algebra.ZeroFitDialParityCapacity
import Algebra.ZeroFitDialU64Replication
import Algebra.ZeroFitDialU64MedianCapacity

/-!
# Extremiser classification and the aggregated decorrelation budget

## Research context

Third cycle on the `U64B-DIAL-HOLDS-COUNT-PARITY` record (exp 543).  Cycle 1
(`Algebra.ZeroFitDialU64Replication`) gave the chord form of Gram positivity and the
*mean/count* rigidity of the six-seed record; cycle 2
(`Algebra.ZeroFitDialU64MedianCapacity`) gave the interpolating capacity law
`k·ρ² ≤ 1 + (k-1)γ`, its equidistant realisers, and — in a later pass —
`capacity_extremal_forces_equidistant`, which pins every off-diagonal Gram entry of an
extremal family to `γ`.

Two directions were left open by that state of the thread.

* **D4′ (rigidity of the extremisers).**  The Gram half was settled, but the conjecture
  also asserted that the *response* of an extremal family is the normalised sum of the
  family and that every reading is exactly `ρ`.  Those are the statements proved here, so
  D4′ closes completely.
* **D5 (aggregated decorrelation budget).**  The conjecture was that `r` replications with
  pooled readings `ρ_i`, advantages `α_i` and mean mutual correlation `c̄` satisfy
  `∑ α_i² ≤ 2(1 - c̄)(r - ∑ ρ_i(ρ_i - α_i))`.  This file shows that the conjecture as
  stated is **false**, exhibits the obstruction, and repairs it in two ways.

## Main results

### 1. The extremiser classification (closes D4′)

* `capacity_extremal_response_parallel` — if a `γ`-family of `k ≥ 1` unit statistics all
  reading at least `ρ ≥ 0` saturates `k·ρ² = 1 + (k-1)γ`, then pointwise
  `∑ᵢ uᵢ(x) = k·ρ·w(x)`: the response is *exactly* proportional to the sum of the family.
  The proof does not go through an abstract Cauchy–Schwarz equality case; it squeezes the
  three inequalities of the capacity proof into equalities and then shows that the residual
  vector `S - kρ·w` has zero norm.
* `capacity_extremal_response_is_normalised_sum` — for `ρ > 0` this reads
  `w = (kρ)⁻¹ · ∑ᵢ uᵢ`, i.e. the response is the *normalised* sum.
* `capacity_extremal_readings_exact` — extremality also upgrades the hypothesis
  `ρ ≤ ⟨uᵢ, w⟩` to the equality `⟨uᵢ, w⟩ = ρ` for every `i`.

Combined with `capacity_extremal_forces_equidistant` this classifies the extremisers of
the capacity sheet completely: Gram matrix `(1-γ)I + γJ`, response the normalised sum,
readings all equal.

### 2. The aggregated budget (refutes and repairs D5)

* `aggregated_budget_needs_ordering` — an explicit two-replication record satisfying every
  hypothesis of D5 and **violating** its conclusion (`1.96 > 1.49`).  The mechanism is
  transparent: D5 silently assumes that the per-replication decorrelation `1 - c_i` and the
  per-replication headroom `1 - a_i b_i` are *oppositely* ordered, whereas the
  counterexample makes them vary together.  So the budgets of independent replications do
  **not** simply average.
* `aggregated_budget_worst_case` — the unconditional repair: with `c_i ≥ cmin` for all `i`,
  `∑ α_i² ≤ 2(1 - cmin)(r - ∑ a_i b_i)`.  The mean must be replaced by the minimum.
* `aggregated_budget_chebyshev` — the conditional repair, which recovers D5 *verbatim*
  under the missing hypothesis: if `(1 - c_i)` antivaries with `(1 - a_i b_i)`, then
  `∑ α_i² ≤ 2(1 - c̄)(r - ∑ a_i b_i)` with the mean `c̄`.  So D5 is exactly a Chebyshev sum
  inequality away from being true, and `aggregated_budget_needs_ordering` shows the
  hypothesis cannot be dropped.

### 3. Applied to the six-seed record

* `six_seed_aggregate_decorrelation` — with the explicit six-seed advantage record
  `advSeed` (the witness of `six_seed_record_consistent`) and reading products at least
  `1/3`, the *most correlated* seed in the whole record still satisfies
  `cmin ≤ 1 - 7151/2000000`.  A meta-analysis of the six seeds therefore certifies a
  decorrelation floor that no single seed's budget provides.
* `six_seed_aggregate_mean_decorrelation` — the sharper Chebyshev form: under the
  antivariation hypothesis the same bound holds for the *mean* mutual correlation.

## Scientific payload

The negative result is the interesting one.  Layer 1 of the thread (chord geometry) is
per-replication and Layer 2 (order statistics) is across replications; D5 proposed that
the two layers commute with averaging.  They do not.  Averaging a family of budgets is
only legitimate when the cheap replications are the ones with the most headroom, which is
precisely antivariation.  The count-parity phenomenon — a few seeds carrying the whole
advantage — is exactly the *monovariant* regime where the naive average over-credits the
record, which is a structural reason to distrust pooled advantage estimates in a bimodal
cell.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU64Aggregation

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialParityCapacity
open Catalog.Algebra.ZeroFitDialU64Replication
open Catalog.Algebra.ZeroFitDialU64MedianCapacity

variable {n k : ℕ}

/-! ## 1. The extremiser classification -/

/-- Expansion of the square norm of a residual `S - c·w`. -/
lemma dot_sub_smul_self (S w : Fin n → ℝ) (c : ℝ) :
    dot (fun x => S x - c * w x) (fun x => S x - c * w x)
      = dot S S - 2 * c * dot S w + c ^ 2 * dot w w := by
  have hpt : ∀ x, (S x - c * w x) * (S x - c * w x)
      = S x * S x - (2 * c) * (S x * w x) + c ^ 2 * (w x * w x) := fun x => by ring
  simp only [dot, hpt, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]

/-- **Extremal families have their response parallel to the family sum.**  If a
`gamma`-family of `k ≥ 1` unit statistics, each reading at least `rho ≥ 0` against a unit
response `w`, saturates the capacity bound, then `∑ᵢ uᵢ = k·rho·w` pointwise. -/
theorem capacity_extremal_response_parallel {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ}
    {gamma rho : ℝ} (hu : IsGammaFamily u gamma) (hw : dot w w = 1) (hrho : 0 ≤ rho)
    (hk : 1 ≤ k) (hread : ∀ i, rho ≤ dot (u i) w)
    (hextremal : (k : ℝ) * rho ^ 2 = 1 + ((k : ℝ) - 1) * gamma) :
    ∀ x, ∑ i, u i x = (k : ℝ) * rho * w x := by
  classical
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  set S : Fin n → ℝ := fun x => ∑ i, (1 : ℝ) * u i x with hS
  have hSw : dot S w = ∑ i, dot (u i) w := by
    rw [hS, dot_sum_left]
    exact Finset.sum_congr rfl fun i _ => one_mul _
  have hlow : (k : ℝ) * rho ≤ dot S w := by
    rw [hSw]
    calc (k : ℝ) * rho = ∑ _i : Fin k, rho := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      _ ≤ ∑ i, dot (u i) w := Finset.sum_le_sum fun i _ => hread i
  have hSStop : (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma = ((k : ℝ) * rho) ^ 2 := by
    have hfac : (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma
        = (k : ℝ) * (1 + ((k : ℝ) - 1) * gamma) := by ring
    rw [hfac, ← hextremal]; ring
  have hSS : dot S S ≤ ((k : ℝ) * rho) ^ 2 := by
    rw [← hSStop]; exact dot_sum_sum_le hu
  have hcs : dot S w ^ 2 ≤ dot S S := by
    have := dot_sq_le S w; rw [hw, mul_one] at this; exact this
  have hknn : (0 : ℝ) ≤ (k : ℝ) * rho := mul_nonneg (by linarith) hrho
  have hub : dot S w ≤ (k : ℝ) * rho := by nlinarith [hcs, hSS, hlow, hknn]
  have hSweq : dot S w = (k : ℝ) * rho := le_antisymm hub hlow
  have hSSeq : dot S S = ((k : ℝ) * rho) ^ 2 := by
    refine le_antisymm hSS ?_
    rw [← hSweq]; exact hcs
  have hzero : dot (fun x => S x - ((k : ℝ) * rho) * w x)
      (fun x => S x - ((k : ℝ) * rho) * w x) = 0 := by
    rw [dot_sub_smul_self, hSSeq, hSweq, hw]; ring
  intro x
  have hres := eq_zero_of_dot_self_eq_zero hzero x
  simp only at hres
  have hSx : S x = ∑ i, u i x := by simp [hS]
  rw [hSx] at hres
  linarith

/-- For a positive reading level, the response of an extremal family is the *normalised*
sum of the family. -/
theorem capacity_extremal_response_is_normalised_sum {u : Fin k → (Fin n → ℝ)}
    {w : Fin n → ℝ} {gamma rho : ℝ} (hu : IsGammaFamily u gamma) (hw : dot w w = 1)
    (hrho : 0 < rho) (hk : 1 ≤ k) (hread : ∀ i, rho ≤ dot (u i) w)
    (hextremal : (k : ℝ) * rho ^ 2 = 1 + ((k : ℝ) - 1) * gamma) :
    ∀ x, w x = ((k : ℝ) * rho)⁻¹ * ∑ i, u i x := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hpos : (0 : ℝ) < (k : ℝ) * rho := mul_pos (by linarith) hrho
  intro x
  rw [capacity_extremal_response_parallel hu hw hrho.le hk hread hextremal x,
    ← mul_assoc, inv_mul_cancel₀ (ne_of_gt hpos), one_mul]

/-- Extremality upgrades the reading *lower bound* to an equality: every statistic in an
extremal family reads exactly `rho`. -/
theorem capacity_extremal_readings_exact {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ}
    {gamma rho : ℝ} (hu : IsGammaFamily u gamma) (hw : dot w w = 1) (hrho : 0 ≤ rho)
    (hk : 1 ≤ k) (hread : ∀ i, rho ≤ dot (u i) w)
    (hextremal : (k : ℝ) * rho ^ 2 = 1 + ((k : ℝ) - 1) * gamma) :
    ∀ i, dot (u i) w = rho := by
  classical
  have hpar := capacity_extremal_response_parallel hu hw hrho hk hread hextremal
  -- the total reading is pinned at `k·rho`
  have htot : ∑ i, dot (u i) w = (k : ℝ) * rho := by
    have hexp : ∑ i, dot (u i) w = ∑ x, (∑ i, u i x) * w x := by
      simp only [dot, Finset.sum_mul]
      exact Finset.sum_comm
    rw [hexp]
    have : ∀ x ∈ (univ : Finset (Fin n)), (∑ i, u i x) * w x
        = (k : ℝ) * rho * (w x * w x) := fun x _ => by rw [hpar x]; ring
    rw [Finset.sum_congr rfl this, ← Finset.mul_sum]
    have : ∑ x, w x * w x = 1 := hw
    rw [this, mul_one]
  -- a family of numbers each at least `rho` whose total is `k·rho` is constant
  have hneg := eq_of_sum_saturates (univ : Finset (Fin k))
    (fun i => -dot (u i) w) (-rho) (fun i _ => neg_le_neg (hread i)) ?_
  · intro i
    have := hneg i (Finset.mem_univ i)
    simpa using this
  · rw [Finset.card_univ, Fintype.card_fin]
    have : ∑ i, -dot (u i) w = -∑ i, dot (u i) w := by
      simp [Finset.sum_neg_distrib]
    rw [this, htot]; ring

/-! ## 2. The aggregated decorrelation budget -/

/-- **The aggregated budget, worst-case form.**  For `r` replications each satisfying Gram
positivity, with advantages `alpha i ≥ 0` bought at reading gap `a i - b i` and reading
products at most `1`, a *uniform lower bound* `cmin` on the mutual correlations gives a
single pooled budget. -/
theorem aggregated_budget_worst_case {r : ℕ} (a b c alpha : Fin r → ℝ) (cmin : ℝ)
    (hg : ∀ i, a i ^ 2 + b i ^ 2 + c i ^ 2 ≤ 1 + 2 * (a i * b i * c i))
    (halpha : ∀ i, 0 ≤ alpha i) (hab : ∀ i, alpha i ≤ a i - b i)
    (hprod : ∀ i, a i * b i ≤ 1) (hcmin : ∀ i, cmin ≤ c i) :
    ∑ i, alpha i ^ 2 ≤ 2 * (1 - cmin) * ((r : ℝ) - ∑ i, a i * b i) := by
  have hstep : ∀ i : Fin r, alpha i ^ 2 ≤ 2 * (1 - cmin) * (1 - a i * b i) := by
    intro i
    have hb := decorrelation_budget (hg i) (halpha i) (hab i)
    have hhead : (0 : ℝ) ≤ 1 - a i * b i := by linarith [hprod i]
    nlinarith [hcmin i, hhead, hb]
  calc ∑ i, alpha i ^ 2 ≤ ∑ i, 2 * (1 - cmin) * (1 - a i * b i) :=
        Finset.sum_le_sum fun i _ => hstep i
    _ = 2 * (1 - cmin) * ∑ i, (1 - a i * b i) := by rw [← Finset.mul_sum]
    _ = 2 * (1 - cmin) * ((r : ℝ) - ∑ i, a i * b i) := by
        congr 1
        rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
          nsmul_eq_mul, mul_one]

/-- **The aggregated budget, Chebyshev form** — conjecture D5 verbatim, under the
antivariation hypothesis it was missing.  If the per-replication decorrelation `1 - c i`
antivaries with the per-replication headroom `1 - a i * b i`, then the *mean* mutual
correlation `cbar` controls the pooled budget. -/
theorem aggregated_budget_chebyshev {r : ℕ} (a b c alpha : Fin r → ℝ) (cbar : ℝ)
    (hr : 0 < r)
    (hg : ∀ i, a i ^ 2 + b i ^ 2 + c i ^ 2 ≤ 1 + 2 * (a i * b i * c i))
    (halpha : ∀ i, 0 ≤ alpha i) (hab : ∀ i, alpha i ≤ a i - b i)
    (hmean : ∑ i, c i = (r : ℝ) * cbar)
    (hanti : Antivary (fun i => 1 - c i) (fun i => 1 - a i * b i)) :
    ∑ i, alpha i ^ 2 ≤ 2 * (1 - cbar) * ((r : ℝ) - ∑ i, a i * b i) := by
  classical
  have hrR : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr
  have hcard : ((univ : Finset (Fin r)).card : ℝ) = (r : ℝ) := by
    rw [Finset.card_univ, Fintype.card_fin]
  have hcheb := (hanti.antivaryOn (univ : Finset (Fin r))).card_mul_sum_le_sum_mul_sum
  rw [hcard] at hcheb
  have hsumf : ∑ i, (1 - c i) = (r : ℝ) * (1 - cbar) := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul, mul_one, hmean]
    ring
  have hsumg : ∑ i, (1 - a i * b i) = (r : ℝ) - ∑ i, a i * b i := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul, mul_one]
  rw [hsumf, hsumg] at hcheb
  have hkey : ∑ i, (1 - c i) * (1 - a i * b i)
      ≤ (1 - cbar) * ((r : ℝ) - ∑ i, a i * b i) := by
    have := hcheb
    nlinarith [hrR, this]
  have hstep : ∀ i : Fin r, alpha i ^ 2 ≤ 2 * ((1 - c i) * (1 - a i * b i)) := by
    intro i
    have hb := decorrelation_budget (hg i) (halpha i) (hab i)
    linarith [hb]
  calc ∑ i, alpha i ^ 2 ≤ ∑ i, 2 * ((1 - c i) * (1 - a i * b i)) :=
        Finset.sum_le_sum fun i _ => hstep i
    _ = 2 * ∑ i, (1 - c i) * (1 - a i * b i) := by rw [← Finset.mul_sum]
    _ ≤ 2 * ((1 - cbar) * ((r : ℝ) - ∑ i, a i * b i)) := by linarith
    _ = 2 * (1 - cbar) * ((r : ℝ) - ∑ i, a i * b i) := by ring

/-- **Conjecture D5 is false as stated.**  Two replications satisfying Gram positivity,
nonnegativity of the advantages, the reading-gap bound and the reading-product bound, whose
mean mutual correlation is `1/2`, but whose pooled advantage energy `1.96` exceeds the
conjectured mean-based budget `1.49`.  The first replication is fully decorrelated with a
large reading gap; the second is fully correlated with no headroom, so decorrelation and
headroom *monovary* — the exact opposite of the hypothesis of
`aggregated_budget_chebyshev`. -/
theorem aggregated_budget_needs_ordering :
    ∃ (a b c alpha : Fin 2 → ℝ) (cbar : ℝ),
      (∀ i, a i ^ 2 + b i ^ 2 + c i ^ 2 ≤ 1 + 2 * (a i * b i * c i)) ∧
      (∀ i, 0 ≤ alpha i) ∧ (∀ i, alpha i ≤ a i - b i) ∧ (∀ i, a i * b i ≤ 1) ∧
      (∑ i, c i = (2 : ℝ) * cbar) ∧
      2 * (1 - cbar) * ((2 : ℝ) - ∑ i, a i * b i) < ∑ i, alpha i ^ 2 := by
  refine ⟨![7/10, 1], ![-7/10, 1], ![0, 1], ![14/10, 0], 1/2, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro i; fin_cases i <;> norm_num
  · intro i; fin_cases i <;> norm_num
  · intro i; fin_cases i <;> norm_num
  · intro i; fin_cases i <;> norm_num
  · rw [Fin.sum_univ_two]; norm_num
  · rw [Fin.sum_univ_two, Fin.sum_univ_two]; norm_num

/-! ## 3. The six-seed record -/

/-- The six-seed advantage record of `six_seed_record_consistent`, over `ℝ`. -/
noncomputable def advSeed : Fin 6 → ℝ :=
  ![16/1000, 100/1000, 106/1000, 16/1000, 50/1000, 66/1000]

lemma advSeed_eq_witness (i : Fin 6) :
    advSeed i = ((Catalog.Algebra.ZeroFitDialU64MedianCapacity.witness i : ℚ) : ℝ) := by
  fin_cases i <;>
    simp [advSeed, Catalog.Algebra.ZeroFitDialU64MedianCapacity.witness]

lemma advSeed_nonneg (i : Fin 6) : 0 ≤ advSeed i := by
  fin_cases i <;> norm_num [advSeed]

/-- The pooled advantage energy of the recorded six-seed split. -/
lemma advSeed_sq_sum : ∑ i, advSeed i ^ 2 = 28604 / 1000000 := by
  rw [Fin.sum_univ_six]
  simp [advSeed]
  norm_num

/-- **Meta-analytic decorrelation floor for the six-seed record.**  If every seed realises
at least the recorded advantage at a reading product in `[1/3, 1]`, then the *most
correlated* seed of the whole record has mutual correlation at most `1 - 7151/2000000`.
No single seed's budget gives this: it is the pooled advantage energy that forces it. -/
theorem six_seed_aggregate_decorrelation (a b c : Fin 6 → ℝ) (cmin : ℝ)
    (hg : ∀ i, a i ^ 2 + b i ^ 2 + c i ^ 2 ≤ 1 + 2 * (a i * b i * c i))
    (hadv : ∀ i, advSeed i ≤ a i - b i)
    (hfloor : ∀ i, (1 : ℝ) / 3 ≤ a i * b i) (hprod : ∀ i, a i * b i ≤ 1)
    (hcmin : ∀ i, cmin ≤ c i) (hc1 : ∀ i, c i ≤ 1) :
    cmin ≤ 1 - 7151 / 2000000 := by
  have hbud := aggregated_budget_worst_case a b c advSeed cmin hg advSeed_nonneg hadv hprod hcmin
  rw [advSeed_sq_sum] at hbud
  have hsum : (2 : ℝ) ≤ ∑ i, a i * b i := by
    have hconst : ∑ _i : Fin 6, (1 : ℝ) / 3 = 2 := by
      rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]; norm_num
    calc (2 : ℝ) = ∑ _i : Fin 6, (1 : ℝ) / 3 := hconst.symm
      _ ≤ ∑ i, a i * b i := Finset.sum_le_sum fun i _ => hfloor i
  have hcle : cmin ≤ 1 := le_trans (hcmin 0) (hc1 0)
  have hcast : ((6 : ℕ) : ℝ) = 6 := by norm_num
  rw [hcast] at hbud
  nlinarith [hbud, hsum, hcle]

/-- The Chebyshev form applied to the record: under antivariation of decorrelation and
headroom, the same floor holds for the *mean* mutual correlation across the six seeds. -/
theorem six_seed_aggregate_mean_decorrelation (a b c : Fin 6 → ℝ) (cbar : ℝ)
    (hg : ∀ i, a i ^ 2 + b i ^ 2 + c i ^ 2 ≤ 1 + 2 * (a i * b i * c i))
    (hadv : ∀ i, advSeed i ≤ a i - b i)
    (hfloor : ∀ i, (1 : ℝ) / 3 ≤ a i * b i)
    (hmean : ∑ i, c i = (6 : ℝ) * cbar) (hcbar : cbar ≤ 1)
    (hanti : Antivary (fun i => 1 - c i) (fun i => 1 - a i * b i)) :
    cbar ≤ 1 - 7151 / 2000000 := by
  have hbud := aggregated_budget_chebyshev a b c advSeed cbar (by norm_num) hg
    advSeed_nonneg hadv (by rw [hmean]; norm_num) hanti
  rw [advSeed_sq_sum] at hbud
  have hsum : (2 : ℝ) ≤ ∑ i, a i * b i := by
    have hconst : ∑ _i : Fin 6, (1 : ℝ) / 3 = 2 := by
      rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]; norm_num
    calc (2 : ℝ) = ∑ _i : Fin 6, (1 : ℝ) / 3 := hconst.symm
      _ ≤ ∑ i, a i * b i := Finset.sum_le_sum fun i _ => hfloor i
  have hcast : ((6 : ℕ) : ℝ) = 6 := by norm_num
  rw [hcast] at hbud
  nlinarith [hbud, hsum, hcbar]

end Catalog.Algebra.ZeroFitDialU64Aggregation