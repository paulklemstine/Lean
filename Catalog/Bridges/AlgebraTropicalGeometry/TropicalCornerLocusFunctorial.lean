/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.AlgebraTropicalGeometry.TropicalValuationLimitBridge

/-!
# Functoriality of the tropical corner locus: scale-invariance and the union law

This file extends `TropicalValuationLimitBridge.lean` by establishing two structural
properties of the corner-locus predicate `AttainedAtLeastTwice` and of tropical
hypersurfaces.  These were recorded as **Direction 2** (scale invariance / the
"valuation -> infinity limit") and **Direction 3** (stable intersection / tropical Bezout via
the union law) in that file's future directions.

## Main results

* `attainedTwice_smul_iff` — **scale equivariance (Direction 2).**  Rescaling all weights by a
  positive constant does not move the corner locus: `AttainedAtLeastTwice (t * w) ↔
  AttainedAtLeastTwice w`.  This makes precise that the family `v_t = t·v` shares one fixed
  tropical shape, so "tropicalization is the t -> infinity limit" is an algebraic invariance
  rather than an analytic limit of moving sets.

* `attainedTwice_product_add_iff` — **corner of a separated sum.**  The minimum of
  `(i,k) ↦ f i + g k` is attained at least twice **iff** the minimum of `f` is, or the minimum
  of `g` is.  This is the combinatorial shadow of `TropPoly.eval_mul`: the minimizer set of a
  sum is the product of the minimizer sets.

* `TropPoly.tropHypersurface_mul` — **the union law (tropical Bezout engine).**  The tropical
  hypersurface of a product is the union of the hypersurfaces: `V(P ⊙ Q) = V(P) ∪ V(Q)`.  This
  is the analytic half of tropical Bezout, complementing the combinatorial lattice count.

See `FUTURE_DIRECTIONS.md` for the surrounding research narrative.
-/

open Finset TropicalValuationBridge

namespace TropicalValuationBridge

/-! ## §1. Scale equivariance of the corner locus (Direction 2) -/

-- !-- Lab Notebook: attainedTwice_smul_iff -- !--
-- !-- Hypothesis: The corner-locus predicate is invariant under positive rescaling of all -- !--
-- !-- weights, since a strictly increasing map preserves the "global minimiser" relation. -- !--
-- !-- Result: Proved. `t * a ≤ t * b ↔ a ≤ b` for `t > 0` transports each minimality -- !--
-- !-- condition, and the witnessing pair `(i, j)` is unchanged. -- !--
-- !-- Insight: The whole `v_t = t·v` family has one fixed tropical shape; the "limit" slogan -- !--
-- !-- is an algebraic homothety invariance, not an analytic set-convergence. -- !--
-- !-- Failure analysis: A naive `OrderIso`-transport overcomplicated things; a direct iff on -- !--
-- !-- the minimality clauses via positivity of `t` is cleaner. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Multiplying every weight by `t > 0` preserves `a ≤ b`, so the same witnessing indices -- !--
-- !-- `i ≠ j` realise the doubled minimum before and after scaling. -- !--
theorem attainedTwice_smul_iff {ι : Type*} (t : ℝ) (ht : 0 < t) (w : ι → ℝ) :
    AttainedAtLeastTwice (fun i => t * w i) ↔ AttainedAtLeastTwice w := by
  constructor <;> intro h
  · obtain ⟨i, j, hij, hi, hj⟩ := h
    exact ⟨i, j, hij, fun k => by nlinarith [hi k, hj k], fun k => by nlinarith [hi k, hj k]⟩
  · obtain ⟨i, j, hij, hi, hj⟩ := h
    exact ⟨i, j, hij, fun k => mul_le_mul_of_nonneg_left (hi k) ht.le,
      fun k => mul_le_mul_of_nonneg_left (hj k) ht.le⟩

/-! ## §2. Corner of a separated sum (combinatorial core of Direction 3) -/

-- !-- Lab Notebook: attainedTwice_product_add_iff -- !--
-- !-- Hypothesis: The minimum of `f i + g k` over a product is attained twice iff one -- !--
-- !-- factor's minimum is attained twice, because the minimiser set is the product of -- !--
-- !-- minimiser sets. -- !--
-- !-- Result: Proved. Forward: two distinct product-minimisers project to f-minimisers and -- !--
-- !-- g-minimisers; distinctness forces a repeat in one coordinate. Backward: pad a repeated -- !--
-- !-- minimiser of one factor with a fixed minimiser of the other. -- !--
-- !-- Insight: This is the exact pointwise reason `V(P⊙Q)=V(P)∪V(Q)`: corners of a sum of -- !--
-- !-- two convex PL functions occur where either summand has a corner. -- !--
-- !-- Failure analysis: Need finiteness/nonemptiness of BOTH factors for the backward -- !--
-- !-- direction (to produce a fixed minimiser of the passive coordinate). -- !--
-- !-- End Lab Notebook -- !--

-- !-- Forward: from two distinct minimisers of `f·+g·`, fix one coordinate to read off that -- !--
-- !-- the projections are minimisers of `f` and of `g`; distinctness yields a repeat in some -- !--
-- !-- coordinate. Backward: combine a doubled minimiser of one factor with any minimiser of -- !--
-- !-- the other (obtained via `Finite.exists_min`). -- !--
theorem attainedTwice_product_add_iff {ι κ : Type*} [Finite ι] [Nonempty ι] [Finite κ]
    [Nonempty κ] (f : ι → ℝ) (g : κ → ℝ) :
    AttainedAtLeastTwice (fun p : ι × κ => f p.1 + g p.2)
      ↔ AttainedAtLeastTwice f ∨ AttainedAtLeastTwice g := by
  constructor
  · intro h
    obtain ⟨p, q, hpq, h_min⟩ := h
    by_cases h_cases : p.1 = q.1
    · refine Or.inr ⟨p.2, q.2, ?_, ?_, ?_⟩ <;> simp_all +decide [Prod.ext_iff]
      all_goals exact fun k => by linarith [h_min.1 q.1 k, h_min.2 q.1 k]
    · left
      refine ⟨p.1, q.1, h_cases, fun k => ?_, fun k => ?_⟩
      · have := h_min.1 (k, p.2); have := h_min.2 (k, q.2); norm_num at *; linarith
      · have := h_min.1 (k, p.2); have := h_min.2 (k, q.2); norm_num at *; linarith
  · rintro (⟨i, j, hij, hi, hj⟩ | ⟨i, j, hij, hi, hj⟩)
    · obtain ⟨k, hk⟩ := Finite.exists_min g
      exact ⟨(i, k), (j, k), by aesop, fun p => by simpa using add_le_add (hi p.1) (hk p.2),
        fun p => by simpa using add_le_add (hj p.1) (hk p.2)⟩
    · obtain ⟨k, hk⟩ := Finite.exists_min f
      exact ⟨(k, i), (k, j), by aesop, fun p => by simpa using add_le_add (hk p.1) (hi p.2),
        fun p => by simpa using add_le_add (hk p.1) (hj p.2)⟩

/-! ## §3. The union law for tropical hypersurfaces (Direction 3) -/

/-- The tropical hypersurface (corner locus) of a tropical polynomial: the set of points where
the min-plus evaluation is non-smooth, i.e. its defining minimum is attained at least twice. -/
def TropPoly.tropHypersurface {ι : Type*} {n : ℕ} (P : TropPoly ι n) : Set (Fin n → ℝ) :=
  {x | AttainedAtLeastTwice (P.termVal x)}

-- !-- Each `(i,k)` monomial value of `P ⊙ Q` splits as `termVal P i + termVal Q k` by -- !--
-- !-- expanding `mul` and distributing the inner product. -- !--
theorem TropPoly.termVal_mul {ι κ : Type*} {n : ℕ} (P : TropPoly ι n) (Q : TropPoly κ n)
    (x : Fin n → ℝ) (p : ι × κ) :
    (P.mul Q).termVal x p = P.termVal x p.1 + Q.termVal x p.2 := by
  simp [TropPoly.termVal, TropPoly.mul, add_mul, Finset.sum_add_distrib]
  ring

-- !-- Lab Notebook: TropPoly.tropHypersurface_mul -- !--
-- !-- Hypothesis: The tropical hypersurface of a product is the union of the hypersurfaces. -- !--
-- !-- Result: Proved by combining `termVal_mul` (the monomial split) with -- !--
-- !-- `attainedTwice_product_add_iff` (corner of a separated sum). -- !--
-- !-- Insight: This is the analytic half of tropical Bezout; paired with the catalog lattice -- !--
-- !-- count `mixedLatticeIndex`, degrees multiply and hypersurfaces of products decompose. -- !--
-- !-- Failure analysis: The naive attempt to argue geometrically about PL graphs is replaced -- !--
-- !-- by the clean finite-combinatorial minimiser-set argument. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Rewrite the product's term values via `termVal_mul`, then the corner-of-a-sum iff -- !--
-- !-- `attainedTwice_product_add_iff` turns "corner of `P⊙Q`" into "corner of `P` or corner -- !--
-- !-- of `Q`", which is membership in the union. -- !--
theorem TropPoly.tropHypersurface_mul {ι κ : Type*} {n : ℕ} [Finite ι] [Nonempty ι] [Finite κ]
    [Nonempty κ] (P : TropPoly ι n) (Q : TropPoly κ n) :
    (P.mul Q).tropHypersurface = P.tropHypersurface ∪ Q.tropHypersurface := by
  ext x
  simp only [TropPoly.tropHypersurface, Set.mem_setOf_eq, Set.mem_union]
  convert attainedTwice_product_add_iff (P.termVal x) (Q.termVal x) using 1
  exact iff_of_eq (by congr; ext; exact TropPoly.termVal_mul P Q x _)

end TropicalValuationBridge