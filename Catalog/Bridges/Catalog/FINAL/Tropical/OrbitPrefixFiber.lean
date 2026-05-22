/-
# Fiber Bounds for Orbit-Prefix Maps of Tropical Matrix Actions

This file formalizes a family of theorems about fiber bounds for orbit-prefix
maps arising from tropical matrix split data. The core principle is:

> If a matrix-to-prefix map is combinatorially rich enough to hit many prefixes,
> then no single prefix fiber can be too large; conversely, explicit enumeration
> of tropical split data gives universal upper bounds on multiplicities.

## Main results

* `tropical_split_count` — The number of split choices at level `e` is `e + 1`.
* `splitDomain_card` — The split domain has cardinality `e + 1`.
* `prefix_fiber_card_exact` — Each prefix fiber in the canonical split model has exactly one element.
* `exists_large_prefix_fiber` — Pigeonhole: if `(e+1)²` codes map to `e+1` prefixes, some fiber has size ≥ `e+1`.
* `prefixSum_fiber_bound` — Two-step prefix fibers are bounded by `e + 1`.
* `prefixSum_fiber_card_exact` — Exact triangular law for two-step prefix fibers.
-/

import Mathlib

open Finset

/-! ## Basic split counting -/

/-- The number of ways to split energy `e` into two non-negative parts is `e + 1`. -/
theorem tropical_split_count (e : ℕ) : (Finset.range (e + 1)).card = e + 1 :=
  Finset.card_range (e + 1)

/-! ## Split domain and prefix maps -/

/-- The split domain: pairs `(a, b)` with `a + b = e`, encoded as `{(a, e - a) | a ∈ [0, e]}`. -/
def splitDomain (e : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range (e + 1)).map
    ⟨fun a => (a, e - a), by
      intro a b h
      simpa using (Prod.mk.inj h).1⟩

/-- The canonical prefix map: extract the first component. -/
def prefixOf : ℕ × ℕ → ℕ := fun x => x.1

/-
The split domain has cardinality `e + 1`.
-/
theorem splitDomain_card (e : ℕ) : (splitDomain e).card = e + 1 := by
  convert Finset.card_range ( e + 1 ) using 1;
  convert Finset.card_map _

/-
In the canonical split model, each admissible prefix has exactly one preimage.
-/
theorem prefix_fiber_card_exact (e a : ℕ) (ha : a ≤ e) :
    ((splitDomain e).filter fun x => prefixOf x = a).card = 1 := by
  unfold prefixOf splitDomain;
  rw [ Finset.card_eq_one ];
  use ( a, e - a ) ; ext ; aesop;

/-! ## Pigeonhole fiber bound -/

/-
If `(e+1)²` matrix codes map to `e+1` prefixes, some prefix fiber has size ≥ `e+1`.
-/
theorem exists_large_prefix_fiber
    (e : ℕ)
    (M P : Finset (ℕ × ℕ))
    (hM : M.card = (e + 1) ^ 2)
    (hP : P.card = e + 1)
    (φ : (ℕ × ℕ) → (ℕ × ℕ))
    (hφ : ∀ x ∈ M, φ x ∈ P) :
    ∃ p ∈ P, (M.filter fun x => φ x = p).card ≥ e + 1 := by
  by_contra hM;
  push_neg at hM;
  exact absurd ( Finset.card_le_card ( show M ⊆ Finset.biUnion P fun p => ( M.filter fun x => φ x = p ) from fun x hx => by aesop ) ) ( by rw [ Finset.card_biUnion ( by intros p hp q hq hpq; simp_all +decide [ Finset.disjoint_left ] ) ] ; exact by { exact not_le_of_gt ( lt_of_le_of_lt ( Finset.sum_le_sum fun i hi ↦ Nat.le_of_lt_succ ( hM i hi ) ) <| by simp +decide [ *, sq ] ) } )

/-! ## Two-step domain and prefix sum -/

/-- The two-step domain: all pairs of split data. -/
def twoStepDomain (e : ℕ) : Finset ((ℕ × ℕ) × (ℕ × ℕ)) :=
  (splitDomain e) ×ˢ (splitDomain e)

/-- The prefix sum statistic: sum of first components of a pair of split data. -/
def prefixSum : ((ℕ × ℕ) × (ℕ × ℕ)) → ℕ :=
  fun x => x.1.1 + x.2.1

/-
Two-step prefix fibers are bounded by `e + 1`.
-/
theorem prefixSum_fiber_bound (e s : ℕ) :
    ((twoStepDomain e).filter fun x => prefixSum x = s).card ≤ e + 1 := by
  have h_fiber_bound : Finset.card (Finset.image (fun x => x.1.1) ({x ∈ (twoStepDomain e) | (prefixSum x) = s})) ≤ e + 1 := by
    -- The image of the first component is a subset of the range {0, 1, ..., e}.
    have h_image_subset : Finset.image (fun x => x.1.1) ({x ∈ (twoStepDomain e) | (prefixSum x) = s}) ⊆ Finset.range (e + 1) := by
      simp +decide [ Finset.subset_iff, twoStepDomain ];
      unfold splitDomain; aesop;
    exact le_trans ( Finset.card_le_card h_image_subset ) ( by norm_num );
  rwa [ Finset.card_image_of_injOn ] at h_fiber_bound;
  intro x hx y hy; simp_all +decide [ twoStepDomain, splitDomain ] ;
  unfold prefixSum at *; aesop;

/-
Exact triangular law for two-step prefix fibers.
-/
theorem prefixSum_fiber_card_exact (e s : ℕ) :
    ((twoStepDomain e).filter fun x => prefixSum x = s).card =
      if s ≤ e then s + 1 else if s ≤ 2 * e then 2 * e - s + 1 else 0 := by
  -- The twoStepDomain e consists of pairs ((a₁, e-a₁), (a₂, e-a₂)) with a₁, a₂ ∈ {0,...,e}. The filter prefixSum = s selects those with a₁ + a₂ = s.
  -- We need to show that the cardinality of the set is given by the formula.
  have h_eq : {x ∈ twoStepDomain e | prefixSum x = s} = Finset.image (fun a => ((a, e - a), (s - a, e - (s - a)))) (Finset.Icc (max 0 (s - e)) (min s e)) := by
    ext ⟨ ⟨ a, b ⟩, ⟨ c, d ⟩ ⟩ ; simp +decide [ *, Finset.mem_image, Finset.mem_Icc ];
    unfold twoStepDomain prefixSum; simp +decide [ Finset.mem_product, Finset.mem_map, Function.Embedding.coeFn_mk ] ;
    unfold splitDomain; simp +decide [ Finset.mem_map, Function.Embedding.coeFn_mk ] ;
    grind;
  rw [ h_eq, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
  split_ifs <;> omega;