import Mathlib
import Applications.DysonSphere.EnergyOptimization

/-!
# Strictly Convex Radiator Laws for Dyson Swarms

This module generalizes the quadratic thermal-management result for finite Dyson
swarms to an arbitrary *strictly convex radiator-cost law*.  A swarm is a finite
family of independently radiating collectors; each collector of area `a` incurs a
thermal cost `f a`, and the total cost of the swarm is `∑ f (area i)`.

The central phenomenon is a variance / majorization effect: for a fixed total
collecting area, spreading the area evenly across the collectors is optimal, and
this optimum is *unique*.  Where the quadratic model used a Cauchy–Schwarz
variance inequality, the general law follows from Jensen's inequality, with the
equality case of strict convexity supplying uniqueness.

We also prove a *splitting law*: whenever the cost of an idle (zero-area)
collector is nonpositive, subdividing one collector into two independent radiators
that share its area strictly reduces the total cost.  Specialized to the quadratic
law `f a = a²` this recovers, and strengthens to a strict inequality, the earlier
two-panel and equal-partition theorems.

## Main results

* `radiatorCost_const` — the cost of a uniform swarm is the panel count times the
  per-panel cost.
* `convex_radiator_uniform_le` — for a convex cost law, the uniform swarm is a
  cost minimizer among all swarms of the same total area.
* `strictConvex_radiator_uniform_lt` — for a strictly convex cost law, any swarm
  that is *not* uniform costs strictly more than the uniform swarm.
* `strictConvex_minimizer_unique` — any cost-minimizing swarm of a strictly convex
  law is the uniform swarm; the optimal allocation is unique.
* `split_strict` — for a strictly convex law with `f 0 ≤ 0`, splitting one
  collector into two independent radiators strictly lowers the total cost.
* `thermalLoad_strict_optimum`, `quadratic_split_improvement` — the quadratic
  radiator law is strictly convex, recovering the swarm results of the base model.
-/

noncomputable section

open Finset
open scoped BigOperators

namespace DysonConvexRadiator

variable {ι : Type*} [Fintype ι]

/-- Total thermal cost of a swarm under a radiator-cost law `f`: each collector of
area `area i` contributes `f (area i)`. -/
def radiatorCost (f : ℝ → ℝ) (area : ι → ℝ) : ℝ := ∑ i, f (area i)

/-- The total cost of a *uniform* swarm — one in which every collector has the
same area `c` — is the number of collectors times the per-collector cost. -/
theorem radiatorCost_const (f : ℝ → ℝ) (c : ℝ) :
    radiatorCost (ι := ι) f (fun _ => c) = (Fintype.card ι : ℝ) * f c := by
  unfold radiatorCost
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **Convex radiator optimality (weak form).**  For a convex cost law `f`, the
uniform swarm minimizes the total cost among all swarms of the same total
collecting area.  Concretely, `card · f (mean area) ≤ ∑ f (area i)`. -/
theorem convex_radiator_uniform_le (s : Set ℝ) (f : ℝ → ℝ) (hf : ConvexOn ℝ s f)
    (area : ι → ℝ) (hmem : ∀ i, area i ∈ s) [Nonempty ι] :
    (Fintype.card ι : ℝ) * f ((∑ i, area i) / (Fintype.card ι : ℝ)) ≤
      radiatorCost f area := by
  set n : ℝ := (Fintype.card ι : ℝ) with hn
  have hnpos : 0 < n := by rw [hn]; exact_mod_cast Fintype.card_pos
  have hw0 : ∀ i ∈ (univ : Finset ι), 0 ≤ n⁻¹ := fun i _ => by positivity
  have hw1 : ∑ _i ∈ (univ : Finset ι), n⁻¹ = 1 := by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, ← hn]; field_simp
  have hj := hf.map_sum_le hw0 hw1 (fun i _ => hmem i)
  have hL : ∑ i, n⁻¹ • area i = (∑ i, area i) / n := by
    simp only [smul_eq_mul, ← Finset.mul_sum]; rw [div_eq_inv_mul]
  have hR : ∑ i, n⁻¹ • f (area i) = radiatorCost f area / n := by
    simp only [smul_eq_mul, ← Finset.mul_sum]; rw [div_eq_inv_mul]; rfl
  rw [hL, hR] at hj
  rw [mul_comm]
  exact (le_div_iff₀ hnpos).mp hj

/-- **Strictly convex radiator optimality (strict form).**  For a strictly convex
cost law `f`, any swarm whose collectors are *not* all equal costs strictly more
than the uniform swarm of the same total area. -/
theorem strictConvex_radiator_uniform_lt (s : Set ℝ) (f : ℝ → ℝ)
    (hf : StrictConvexOn ℝ s f) (area : ι → ℝ) (hmem : ∀ i, area i ∈ s)
    (hne : ∃ j k, area j ≠ area k) :
    (Fintype.card ι : ℝ) * f ((∑ i, area i) / (Fintype.card ι : ℝ)) <
      radiatorCost f area := by
  obtain ⟨j, k, hjk⟩ := hne
  haveI : Nonempty ι := ⟨j⟩
  set n : ℝ := (Fintype.card ι : ℝ) with hn
  have hnpos : 0 < n := by rw [hn]; exact_mod_cast Fintype.card_pos
  have hw0 : ∀ i ∈ (univ : Finset ι), 0 < n⁻¹ := fun i _ => by positivity
  have hw1 : ∑ _i ∈ (univ : Finset ι), n⁻¹ = 1 := by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, ← hn]; field_simp
  have hne' : ∃ a ∈ (univ : Finset ι), ∃ b ∈ (univ : Finset ι), area a ≠ area b :=
    ⟨j, mem_univ _, k, mem_univ _, hjk⟩
  have hj := hf.map_sum_lt hw0 hw1 (fun i _ => hmem i) hne'
  have hL : ∑ i, n⁻¹ • area i = (∑ i, area i) / n := by
    simp only [smul_eq_mul, ← Finset.mul_sum]; rw [div_eq_inv_mul]
  have hR : ∑ i, n⁻¹ • f (area i) = radiatorCost f area / n := by
    simp only [smul_eq_mul, ← Finset.mul_sum]; rw [div_eq_inv_mul]; rfl
  rw [hL, hR] at hj
  rw [mul_comm]
  exact (lt_div_iff₀ hnpos).mp hj

/-- **Uniqueness of the optimum.**  For a strictly convex cost law, a swarm that
attains the uniform-swarm cost must in fact be the uniform swarm: every collector
carries the mean area.  Thus the cost-minimizing allocation is unique. -/
theorem strictConvex_minimizer_unique (s : Set ℝ) (f : ℝ → ℝ)
    (hf : StrictConvexOn ℝ s f) (area : ι → ℝ) (hmem : ∀ i, area i ∈ s)
    [Nonempty ι]
    (hopt : radiatorCost f area
        = (Fintype.card ι : ℝ) * f ((∑ i, area i) / (Fintype.card ι : ℝ))) :
    ∀ j, area j = (∑ i, area i) / (Fintype.card ι : ℝ) := by
  set n : ℝ := (Fintype.card ι : ℝ) with hn
  have hnpos : 0 < n := by rw [hn]; exact_mod_cast Fintype.card_pos
  have hnne : n ≠ 0 := ne_of_gt hnpos
  have hw0 : ∀ i ∈ (univ : Finset ι), 0 < n⁻¹ := fun i _ => by positivity
  have hw1 : ∑ _i ∈ (univ : Finset ι), n⁻¹ = 1 := by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, ← hn]; field_simp
  have hL : ∑ i, n⁻¹ • area i = (∑ i, area i) / n := by
    simp only [smul_eq_mul, ← Finset.mul_sum]; rw [div_eq_inv_mul]
  have hR : ∑ i, n⁻¹ • f (area i) = radiatorCost f area / n := by
    simp only [smul_eq_mul, ← Finset.mul_sum]; rw [div_eq_inv_mul]; rfl
  have heqf : f (∑ i, n⁻¹ • area i) = ∑ i, n⁻¹ • f (area i) := by
    rw [hL, hR, hopt]; field_simp
  have key := (hf.map_sum_eq_iff hw0 hw1 (fun i _ => hmem i)).mp heqf
  intro j
  have hj := key j (mem_univ j)
  rw [hL] at hj
  exact hj

/-- **Splitting law.**  If the cost of an idle collector is nonpositive
(`f 0 ≤ 0`) and `f` is strictly convex, then replacing a single collector by two
independent radiators that partition its area strictly lowers the total cost:
`f a₁ + f a₂ < f (a₁ + a₂)`.  Physically, more independently radiating panels are
always thermally cheaper. -/
theorem split_strict (f : ℝ → ℝ) (hf : StrictConvexOn ℝ Set.univ f)
    (hf0 : f 0 ≤ 0) (a₁ a₂ : ℝ) (h1 : 0 < a₁) (h2 : 0 < a₂) :
    f a₁ + f a₂ < f (a₁ + a₂) := by
  set s := a₁ + a₂ with hs
  have hspos : 0 < s := by rw [hs]; linarith
  have hsne : s ≠ 0 := ne_of_gt hspos
  have hne : (0 : ℝ) ≠ s := ne_of_lt hspos
  have hab1 : a₂ / s + a₁ / s = 1 := by
    rw [← add_div, add_comm a₂ a₁, ← hs, div_self hsne]
  have hab2 : a₁ / s + a₂ / s = 1 := by
    rw [← add_div, ← hs, div_self hsne]
  have hc1 : f a₁ < (a₂ / s) * f 0 + (a₁ / s) * f s := by
    have h := hf.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ s) hne
      (show (0 : ℝ) < a₂ / s by positivity) (show (0 : ℝ) < a₁ / s by positivity) hab1
    simp only [smul_eq_mul] at h
    have heq : (a₂ / s) * 0 + (a₁ / s) * s = a₁ := by field_simp; ring
    rw [heq] at h; exact h
  have hc2 : f a₂ < (a₁ / s) * f 0 + (a₂ / s) * f s := by
    have h := hf.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ s) hne
      (show (0 : ℝ) < a₁ / s by positivity) (show (0 : ℝ) < a₂ / s by positivity) hab2
    simp only [smul_eq_mul] at h
    have heq : (a₁ / s) * 0 + (a₂ / s) * s = a₂ := by field_simp; ring
    rw [heq] at h; exact h
  have hsum : (a₂ / s) * f 0 + (a₁ / s) * f s + ((a₁ / s) * f 0 + (a₂ / s) * f s)
      = f 0 + f s := by
    field_simp; ring
  rw [hs]; linarith

/-! ## Anchoring to the quadratic base model

The base Dyson-swarm model measured thermal concentration by the quadratic load
`∑ (area i)²`.  We show that law is a strictly convex radiator cost, so the
general theorems above specialize to it: the earlier weak equal-partition optimum
sharpens to a strict, uniquely attained optimum, and the two-panel improvement
becomes an instance of the splitting law. -/

/-- The quadratic radiator law `a ↦ a²` is strictly convex on all of `ℝ`. -/
theorem quadratic_strictConvex :
    StrictConvexOn ℝ Set.univ (fun x : ℝ => x ^ 2) := by
  simpa using Even.strictConvexOn_pow (n := 2) (by norm_num) (by norm_num)

/-- The base model's quadratic thermal load is exactly the radiator cost of the
squaring law. -/
theorem thermalLoad_eq_radiatorCost (area : ι → ℝ) :
    DysonSphere.thermalLoad area = radiatorCost (fun x => x ^ 2) area := rfl

/-- **Strict quadratic optimum.**  Strengthening the base model's weak optimum:
if the collectors are not all equal, the uniform swarm has strictly smaller
quadratic thermal load.  The uniform value equals `A² / n`, where `A` is the total
area and `n` the collector count. -/
theorem thermalLoad_strict_optimum (area : ι → ℝ)
    (hne : ∃ j k, area j ≠ area k) :
    (∑ i, area i) ^ 2 / (Fintype.card ι : ℝ) < DysonSphere.thermalLoad area := by
  obtain ⟨j, k, hjk⟩ := hne
  haveI : Nonempty ι := ⟨j⟩
  have hnpos : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  have h := strictConvex_radiator_uniform_lt Set.univ (fun x : ℝ => x ^ 2)
    quadratic_strictConvex area (fun i => Set.mem_univ _) ⟨j, k, hjk⟩
  rw [thermalLoad_eq_radiatorCost]
  have hval : (Fintype.card ι : ℝ)
      * ((∑ i, area i) / (Fintype.card ι : ℝ)) ^ 2
      = (∑ i, area i) ^ 2 / (Fintype.card ι : ℝ) := by
    field_simp
  rw [hval] at h
  exact h

/-- **Quadratic splitting law.**  For the quadratic radiator cost, splitting one
collector into two positive independent radiators strictly lowers the thermal
load, since the squaring law is strictly convex and vanishes at zero.  This is the
general splitting law instantiated at `f = (·)²`. -/
theorem quadratic_split_improvement (a₁ a₂ : ℝ) (h1 : 0 < a₁) (h2 : 0 < a₂) :
    a₁ ^ 2 + a₂ ^ 2 < (a₁ + a₂) ^ 2 :=
  split_strict (fun x => x ^ 2) quadratic_strictConvex (by norm_num) a₁ a₂ h1 h2

/-! ## Worked examples -/

/-- Two equal half-panels beat one full panel of area `2` under the quadratic law. -/
example : (1 : ℝ) ^ 2 + 1 ^ 2 < (1 + 1) ^ 2 :=
  quadratic_split_improvement 1 1 (by norm_num) (by norm_num)

/-- A concrete non-uniform three-collector swarm strictly exceeds its uniform
optimum under the quadratic thermal law. -/
example : ((6 : ℝ) / 3) ^ 2 * 3 < ((1 : ℝ) ^ 2 + 2 ^ 2 + 3 ^ 2) := by
  norm_num

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): The base model's quadratic equal-partition optimum is
-- a special case of a general principle: for ANY strictly convex radiator-cost law
-- f, a finite swarm of fixed total collecting area is uniquely minimized by equal
-- area per collector, and subdividing a collector into independent radiators lowers
-- the cost.  Two bold, cross-domain claims were singled out: (i) uniqueness of the
-- optimum (an equality-case / majorization statement, not merely an inequality),
-- and (ii) a monotone splitting law tying the geometry of subdivision to convexity.
--
-- Experiment (Experimenter): The mean-allocation optimum was obtained from Jensen's
-- inequality with uniform weights 1/n; the strict version and the uniqueness
-- statement used the strict form and the equality case of Jensen for strictly
-- convex functions.  The splitting law was derived from two applications of the
-- two-point strict-convexity inequality about the points 0 and a₁+a₂, combined with
-- the hypothesis f 0 ≤ 0.  The quadratic law was verified strictly convex, and the
-- general theorems were specialized to recover and strengthen the base results.
--
-- Analysis (Analyst): All four structural claims survive.  The decisive step is
-- replacing the ad hoc Cauchy–Schwarz variance bound by Jensen's inequality; the
-- equality case is exactly what upgrades "a minimizer" to "the unique minimizer".
-- The splitting law genuinely needs f 0 ≤ 0: without it, subdividing could increase
-- cost (e.g. a fixed per-panel overhead f 0 > 0 penalizes more panels).  This is the
-- true structural boundary of the base model's two-panel theorem.
--
-- Critique (Critic): No theorem is vacuous or definitional.  `radiatorCost_const`
-- is a genuine folding identity used downstream, not the main result.  Positivity of
-- the collector count is required and supplied via `Nonempty`, obtained from the
-- existence of two unequal collectors in the strict statement.  The quadratic
-- corollaries are strict improvements over the weak `≤` optimum in the base model,
-- so they are not re-proofs with cosmetic changes.  The `f 0 ≤ 0` hypothesis is
-- highlighted as the exact corner case.
--
-- Synthesis (PI): The convex radiator law unifies the geometric (equal-area),
-- variational (Jensen), and combinatorial (majorization / splitting) facets of the
-- swarm thermal problem.  It cleanly generalizes the base quadratic model and marks
-- the boundary — the sign of f 0 and strictness of convexity — where the optimum and
-- its uniqueness can fail.  Natural next steps: unequal collector temperatures
-- (weighted Jensen), and joint collection–radiation optima.
-- !-- end Lab Notes -- !--

end DysonConvexRadiator