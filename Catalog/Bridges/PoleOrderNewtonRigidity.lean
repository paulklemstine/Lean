import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.PoleOrderObstructionSymmetric
import Bridges.PoleOrderNewtonLevelK
import Bridges.PoleOrderNewtonSymmetricBridge

/-!
# Cycle 7: invertibility of the level-`k` recursion — power sums are a complete invariant

Cycle 5 proved the level-`k` Newton recursion for a product of `m` normalized
`q`-series `fᵢ = q⁻¹ + a₀ + a₁q + ⋯`,
```
(k+1) c_{k+1} = ∑_{j ≤ k} c_j p_{k-j},   c_j = coeff (j - m) (∏ fᵢ),
                                          p_r = ∑ᵢ coeff r (uᵢ'/uᵢ),
```
with `uᵢ = q·fᵢ` the unit parts.  Cycle 6 turned it into the classical Newton
identities.  This cycle *inverts* it.

Over a field of characteristic zero the leading factor `k+1` is invertible, so
the recursion determines `c_{k+1}` from `c_0, …, c_k` and `p_0, …, p_k` — and
`c_0 = 1` always (the pole coefficient).  Hence:

* `coeff_eq_of_powerSum_eq` — **rigidity**: two Monster-type products whose
  logarithmic power sums agree in all degrees `< K` have the *same* Laurent
  coefficients in all levels `≤ K`.  The number of factors, and the factors
  themselves, are irrelevant: only the power sums matter.
* `esymm_eq_of_psum_eq` — the classical specialization: two finite families of
  complex numbers with equal power sums `p₁, …, p_K` have equal elementary
  symmetric functions `e₀, …, e_K`.  (This is the invertibility of Newton's
  identities in characteristic zero; the proof here goes through Laurent series
  and never touches symmetric-function combinatorics.)
* `monster_rigidity` — the Monster instance: the head of the Moonshine product
  is determined by the power sums of the logarithmic derivatives of the `194`
  unit parts.

The mechanism is a strong induction whose base case is the pole coefficient
`c₀ = 1` (`level_zero_pole`) and whose step is the level-`k` recursion divided
by `k+1`.  Characteristic zero is essential and is used exactly once, in
`Nat.cast_add_one_ne_zero`.
-/

namespace PoleOrderObstruction

open HahnSeries Finset PowerSeries

variable {ι κ : Type*} [DecidableEq ι] [DecidableEq κ]

/-- The `r`-th **logarithmic power sum** of a family of normalized series: the
`r`-th coefficient of `∑ᵢ uᵢ'/uᵢ`, where `uᵢ = q · fᵢ` is the unit part. -/
noncomputable def logPowerSum (s : Finset ι) (f : ι → LC) (r : ℕ) : ℂ :=
  ∑ i ∈ s, PowerSeries.coeff r (psLogDeriv (normalizedPart (f i)))

/-- The level-`k` recursion, written with `logPowerSum`. -/
theorem newton_recursion_logPowerSum (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (k : ℕ) :
    ((k : ℂ) + 1) * (∏ i ∈ s, f i).coeff (((k : ℤ) + 1) - (s.card : ℤ))
      = ∑ j ∈ Finset.range (k + 1),
          (∏ i ∈ s, f i).coeff ((j : ℤ) - (s.card : ℤ)) * logPowerSum s f (k - j) :=
  newton_recursion_normalized s f h k

/-- **Rigidity of the level-`k` coefficients.**  If two Monster-type products
have the same logarithmic power sums in all degrees `< K`, then they have the
same Laurent coefficients at all levels `j ≤ K` — regardless of how many factors
each product has. -/
theorem coeff_eq_of_powerSum_eq (s : Finset ι) (f : ι → LC) (hf : ∀ i ∈ s, IsNormalized (f i))
    (t : Finset κ) (g : κ → LC) (hg : ∀ i ∈ t, IsNormalized (g i)) (K : ℕ)
    (hp : ∀ r < K, logPowerSum s f r = logPowerSum t g r) :
    ∀ j ≤ K, (∏ i ∈ s, f i).coeff ((j : ℤ) - (s.card : ℤ))
      = (∏ i ∈ t, g i).coeff ((j : ℤ) - (t.card : ℤ)) := by
  intro j
  induction j using Nat.strong_induction_on with
  | _ j ih =>
      intro hjK
      match j with
      | 0 =>
          rw [Nat.cast_zero, zero_sub, zero_sub, level_zero_pole s f hf,
            level_zero_pole t g hg]
      | (k + 1) =>
          have hcast : (((k + 1 : ℕ) : ℤ)) - (s.card : ℤ) = ((k : ℤ) + 1) - (s.card : ℤ) := by
            push_cast; ring
          have hcast' : (((k + 1 : ℕ) : ℤ)) - (t.card : ℤ) = ((k : ℤ) + 1) - (t.card : ℤ) := by
            push_cast; ring
          have hs := newton_recursion_logPowerSum s f hf k
          have ht := newton_recursion_logPowerSum t g hg k
          have hsum : ∑ i ∈ Finset.range (k + 1),
                (∏ x ∈ s, f x).coeff ((i : ℤ) - (s.card : ℤ)) * logPowerSum s f (k - i)
              = ∑ i ∈ Finset.range (k + 1),
                (∏ x ∈ t, g x).coeff ((i : ℤ) - (t.card : ℤ)) * logPowerSum t g (k - i) := by
            refine Finset.sum_congr rfl fun i hi => ?_
            have hik : i < k + 1 := Finset.mem_range.mp hi
            have hle : i ≤ K := by omega
            rw [ih i (by omega) hle, hp (k - i) (by omega)]
          have hne : ((k : ℂ) + 1) ≠ 0 := by
            exact_mod_cast Nat.cast_add_one_ne_zero (R := ℂ) k
          have := hs.trans (hsum.trans ht.symm)
          rw [hcast, hcast']
          exact mul_left_cancel₀ hne this

/-- **Classical corollary: power sums determine the elementary symmetric
functions.**  If two finite families of complex numbers have the same power sums
`p₁, …, p_K`, then they have the same elementary symmetric functions
`e₀, …, e_K`.  The proof is the invertibility of the level-`k` Laurent recursion;
no symmetric-function combinatorics is used. -/
theorem esymm_eq_of_psum_eq (s : Finset ι) (a : ι → ℂ) (t : Finset κ) (b : κ → ℂ) (K : ℕ)
    (hp : ∀ r < K, ∑ i ∈ s, a i ^ (r + 1) = ∑ i ∈ t, b i ^ (r + 1)) :
    ∀ j ≤ K, ∑ u ∈ s.powersetCard j, ∏ i ∈ u, a i
      = ∑ u ∈ t.powersetCard j, ∏ i ∈ u, b i := by
  have hps : ∀ r < K, logPowerSum s (fun i => linTrace (a i)) r
      = logPowerSum t (fun i => linTrace (b i)) r := by
    intro r hr
    have hA : logPowerSum s (fun i => linTrace (a i)) r
        = (-1 : ℂ) ^ r * ∑ i ∈ s, a i ^ (r + 1) := by
      rw [logPowerSum, Finset.mul_sum]
      exact Finset.sum_congr rfl fun i _ => coeff_psLogDeriv_normalizedPart_linTrace (a i) r
    have hB : logPowerSum t (fun i => linTrace (b i)) r
        = (-1 : ℂ) ^ r * ∑ i ∈ t, b i ^ (r + 1) := by
      rw [logPowerSum, Finset.mul_sum]
      exact Finset.sum_congr rfl fun i _ => coeff_psLogDeriv_normalizedPart_linTrace (b i) r
    rw [hA, hB, hp r hr]
  have hmain := coeff_eq_of_powerSum_eq s (fun i => linTrace (a i))
    (fun i _ => isNormalized_linTrace (a i)) t (fun i => linTrace (b i))
    (fun i _ => isNormalized_linTrace (b i)) K hps
  intro j hj
  have h := hmain j hj
  rwa [coeff_prod_linTrace s a j, coeff_prod_linTrace t b j] at h

set_option maxRecDepth 10000 in
set_option maxHeartbeats 1000000 in
/-- **Monster rigidity.**  The head of the Moonshine product is a function of the
logarithmic power sums alone: two families of McKay–Thompson-shaped series with
the same power sums below degree `K` produce the same Laurent coefficients up to
level `K`. -/
theorem monster_rigidity (c d : Fin monsterClassCount → ℕ → ℂ) (K : ℕ)
    (hp : ∀ r < K, logPowerSum Finset.univ (fun i => traceLaurent (c i)) r
      = logPowerSum Finset.univ (fun i => traceLaurent (d i)) r) :
    ∀ j ≤ K, (∏ i, traceLaurent (c i)).coeff ((j : ℤ) - 194)
      = (∏ i, traceLaurent (d i)).coeff ((j : ℤ) - 194) := by
  have h := coeff_eq_of_powerSum_eq (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i))
    (Finset.univ : Finset (Fin monsterClassCount)) (fun i => traceLaurent (d i))
    (fun i _ => isNormalized_traceLaurent (d i)) K hp
  intro j hj
  have hj' := h j hj
  rw [Finset.card_univ, Fintype.card_fin,
    show ((monsterClassCount : ℕ) : ℤ) = (194 : ℤ) from by norm_num [monsterClassCount]] at hj'
  exact hj'

/-! ## Lab note

The rigidity theorem is sharp in the following sense: knowledge of the power
sums only up to degree `< K` controls the coefficients only up to level `K`.
The families `a = (1)` and `b = (0, 1)` (padded with a zero) have equal power
sums in every degree, and indeed equal elementary symmetric functions; but
`a = (2)` and `b = (1, 1)` have `p₁ = 2` equal while `p₂ = 4 ≠ 2`, and already
`e₂` differs (`0` versus `1`).  The following instance records the first
half of that computation as a check of `esymm_eq_of_psum_eq` at `K = 1`. -/

/-- Lab note: `K = 1` rigidity for `a = (2)` versus `b = (1,1)`: equal `p₁`
forces equal `e₀` and `e₁`. -/
theorem lab_note_rigidity_K_one :
    ∀ j ≤ 1, ∑ u ∈ (Finset.univ : Finset (Fin 1)).powersetCard j, ∏ i ∈ u, (![2] : Fin 1 → ℂ) i
      = ∑ u ∈ (Finset.univ : Finset (Fin 2)).powersetCard j, ∏ i ∈ u, (![1, 1] : Fin 2 → ℂ) i := by
  refine esymm_eq_of_psum_eq (Finset.univ : Finset (Fin 1)) ![2]
    (Finset.univ : Finset (Fin 2)) ![1, 1] 1 ?_
  intro r hr
  interval_cases r
  norm_num [Fin.sum_univ_two]

end PoleOrderObstruction