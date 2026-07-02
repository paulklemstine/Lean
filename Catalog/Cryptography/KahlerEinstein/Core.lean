import Mathlib

/-!
# Kähler–Einstein Metrics and K-Stability: the Toric Futaki / Barycenter Core

This file formalizes the *computable algebraic core* of the Yau–Tian–Donaldson (YTD)
picture for **toric Fano manifolds**.  For toric Fano varieties the analytic and
algebraic existence problems both collapse to a single, fully combinatorial
condition on the moment polytope:

> (Wang–Zhu / Mabuchi / Berman, toric YTD)
> A toric Fano manifold admits a Kähler–Einstein metric  ⟺  the *barycenter* of its
> moment polytope lies at the origin  ⟺  the *Futaki invariant* vanishes in every
> toric direction (toric K-polystability).

We model the relevant data as a finite indexed family of weighted lattice points
`(pt i, wt i)` (the vertices / lattice points of the polytope, with Lebesgue or
lattice weights).  We define:

* `weightedSum` — the unnormalised moment / Futaki vector `∑ wt i • pt i`;
* `barycenter`  — its normalisation by the total weight;
* `futaki ξ`    — the classical Futaki invariant paired against a direction `ξ`,
  `∑ wt i * ⟨pt i, ξ⟩`;
* `AdmitsKE`    — the Wang–Zhu existence condition `barycenter = 0`;
* `KPolystable` — vanishing of the Futaki invariant in every direction.

and prove:

* `futaki_eq_dot` — the Futaki invariant is the dot product of `weightedSum` with `ξ`;
* `kpolystable_iff_weightedSum_zero` — toric K-polystability ⟺ `weightedSum = 0`
  (nondegeneracy of the pairing);
* `ytd_toric` — the toric YTD equivalence `AdmitsKE ⟺ KPolystable`;
* `futaki_symmetry` / `weightedSum_zero_of_no_fixed_vector` — the **Matsushima-type
  obstruction theorem**: a linear symmetry of the datum fixes the Futaki vector, so a
  symmetry with no nonzero fixed vector forces a Kähler–Einstein metric to exist.

## Application Keywords
Kähler–Einstein, K-stability, K-polystability, Yau–Tian–Donaldson, Futaki invariant,
Donaldson–Futaki, toric Fano, moment polytope, barycenter, Wang–Zhu, Matsushima,
reductive automorphism, reflexive polytope.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): For toric Fano data the three a-priori-different notions
"admits KE" (analytic, Wang–Zhu barycenter), "K-polystable" (algebro-geometric,
Futaki vanishing), and "moment vector vanishes" coincide, and symmetry alone can
force them.  Bold form: a finite symmetry group acting on the polytope with only the
trivial fixed vector *guarantees* a KE metric, with no curvature estimate needed.

Experiment (Stage 2): Model the polytope datum combinatorially over ℚ; prove the
pairing is nondegenerate so Futaki vanishing ⟺ moment vector vanishing; prove the
symmetry-invariance of the moment vector via an `Equiv` reindexing.

Analysis (Stage 3): The barycenter normalisation (dividing by total weight) is the
only place positivity of the weight is needed; the *direction* of the obstruction is
weight-independent.  This cleanly separates the linear-algebra core (always true) from
the convex-geometry input (total weight > 0).

Critique (Stage 4): Guarded the YTD equivalence so it is NOT a definitional `rfl`:
`AdmitsKE` is phrased via the normalised barycenter and `KPolystable` via a universally
quantified pairing, and the bridge genuinely uses nondegeneracy + a nonzero scalar.

Synthesis (Stage 5): The symmetry theorem is the reusable kernel; concrete Fano
examples (ℙⁿ, obstructed surfaces) live in `Examples.lean`.
-/

open scoped BigOperators

namespace KahlerEinstein

/-- A *toric Fano datum* in dimension `d`: a finite indexed family of `m` weighted
lattice points, modelling the vertices / lattice points of the moment polytope of a
toric Fano variety together with their (Lebesgue or lattice) weights. -/
structure ToricFanoDatum (d : ℕ) (m : ℕ) where
  /-- The lattice points (polytope vertices), as rational vectors. -/
  pt : Fin m → (Fin d → ℚ)
  /-- The weight attached to each point. -/
  wt : Fin m → ℚ

namespace ToricFanoDatum

variable {d m : ℕ} (D : ToricFanoDatum d m)

/-- The unnormalised moment / Futaki vector `∑ wt i • pt i`. -/
def weightedSum : Fin d → ℚ := ∑ i, D.wt i • D.pt i

/-- The total weight `∑ wt i`. -/
def totalWeight : ℚ := ∑ i, D.wt i

/-- The barycenter of the polytope: the moment vector normalised by total weight. -/
noncomputable def barycenter : Fin d → ℚ := (D.totalWeight)⁻¹ • D.weightedSum

/-- The classical Futaki invariant paired against a direction `ξ`:
`∑ wt i * ⟨pt i, ξ⟩`. -/
def futaki (ξ : Fin d → ℚ) : ℚ := ∑ i, D.wt i * (∑ j, D.pt i j * ξ j)

/-- Wang–Zhu existence criterion: a KE metric exists iff the barycenter is the origin. -/
def AdmitsKE : Prop := D.barycenter = 0

/-- Toric K-polystability: the Futaki invariant vanishes in every direction. -/
def KPolystable : Prop := ∀ ξ : Fin d → ℚ, D.futaki ξ = 0

/-
Coordinatewise value of the moment vector.
-/
theorem weightedSum_apply (j : Fin d) :
    D.weightedSum j = ∑ i, D.wt i * D.pt i j := by
  convert Finset.sum_apply ?_ ?_ ?_

/-
The Futaki invariant is the dot product of the moment vector with the direction.
-/
theorem futaki_eq_dot (ξ : Fin d → ℚ) :
    D.futaki ξ = ∑ j, D.weightedSum j * ξ j := by
  simp +decide [ ToricFanoDatum.futaki, ToricFanoDatum.weightedSum, Finset.mul_sum _ _ _, Finset.sum_mul ];
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring )

/-
Nondegeneracy bridge: toric K-polystability is equivalent to vanishing of the
moment vector.
-/
theorem kpolystable_iff_weightedSum_zero :
    D.KPolystable ↔ D.weightedSum = 0 := by
  refine' ⟨ fun h => funext fun j => _, fun h' => _ ⟩;
  · simpa [ futaki_eq_dot ] using h ( fun i => if i = j then 1 else 0 );
  · intro ξ; rw [ futaki_eq_dot ] ; simp +decide [ h' ]

/-
If the total weight is nonzero, the barycenter vanishes iff the moment vector does.
-/
theorem barycenter_zero_iff_weightedSum_zero (hw : D.totalWeight ≠ 0) :
    D.barycenter = 0 ↔ D.weightedSum = 0 := by
  simp +decide [ funext_iff, ToricFanoDatum.barycenter, hw ]

/-
**Toric Yau–Tian–Donaldson equivalence.**  For a toric Fano datum with positive
total weight, a Kähler–Einstein metric exists iff the variety is K-polystable.
-/
theorem ytd_toric (hw : D.totalWeight ≠ 0) :
    D.AdmitsKE ↔ D.KPolystable := by
  rw [ToricFanoDatum.AdmitsKE, barycenter_zero_iff_weightedSum_zero D hw,
    kpolystable_iff_weightedSum_zero D]

/-
**Symmetry invariance of the Futaki vector.**  If a `ℚ`-linear map `σ` permutes the
datum (via the reindexing `e`, preserving weights and sending each point to another
point of the family by `σ`), then `σ` fixes the moment vector.
-/
theorem futaki_symmetry (σ : (Fin d → ℚ) →ₗ[ℚ] (Fin d → ℚ)) (e : Fin m ≃ Fin m)
    (hw : ∀ i, D.wt (e i) = D.wt i) (hp : ∀ i, σ (D.pt i) = D.pt (e i)) :
    σ D.weightedSum = D.weightedSum := by
  unfold ToricFanoDatum.weightedSum;
  simp +decide [ map_sum, hp ];
  conv_rhs => rw [ ← Equiv.sum_comp e ] ; simp +decide [ hw ] ;

/-
**Matsushima-type obstruction theorem.**  If the datum has a linear symmetry `σ`
whose only fixed vector is the origin, then the moment vector vanishes — so a
Kähler–Einstein metric exists.  This is the combinatorial avatar of the fact that a
sufficiently large reductive symmetry kills the Futaki invariant.
-/
theorem weightedSum_zero_of_no_fixed_vector (σ : (Fin d → ℚ) →ₗ[ℚ] (Fin d → ℚ))
    (e : Fin m ≃ Fin m) (hw : ∀ i, D.wt (e i) = D.wt i)
    (hp : ∀ i, σ (D.pt i) = D.pt (e i))
    (hfix : ∀ x : Fin d → ℚ, σ x = x → x = 0) :
    D.weightedSum = 0 := by
  exact hfix _ ( futaki_symmetry D σ e hw hp )

end ToricFanoDatum

end KahlerEinstein