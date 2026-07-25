import Mathlib

/-!
# Recipe complexity as convex geometry

A finite menu is modeled by cooking and verification times.  If every dish has
positive verification time, the cooking/verification ratio of the entire menu is
not an arbitrary quotient: it is the barycenter of the individual ratios, weighted
by each dish's share of the total verification work.

This connects the culinary complexity metaphor to convex geometry.  The bridge has
real content: the weights are nonnegative and sum to one, so an aggregate menu
cannot have a ratio outside the range of its dishes.  Moreover, if every dish is
at least break-even (`V ≤ C`), equality at the boundary is rigid: an aggregate
ratio of one forces every individual ratio to be one.

No claim about actual complexity classes, Navier--Stokes, or soufflé hardness is
made: those would require a computational model and reductions not supplied by
timing data alone.
-/

namespace RecipeBarycenter

/-- A recipe represented by cooking time and verification time. -/
structure Recipe where
  cook : ℕ
  verify : ℕ

/-- Cooking-to-verification ratio. -/
noncomputable def ratio (R : Recipe) : ℚ := (R.cook : ℚ) / (R.verify : ℚ)

/-- Aggregate a finite menu by adding both resource costs. -/
noncomputable def aggregate {ι : Type*} [Fintype ι] (R : ι → Recipe) : Recipe where
  cook := ∑ i, (R i).cook
  verify := ∑ i, (R i).verify

/-- The verification-work share of dish `i`. -/
noncomputable def weight {ι : Type*} [Fintype ι] (R : ι → Recipe) (i : ι) : ℚ :=
  ((R i).verify : ℚ) / ((aggregate R).verify : ℚ)

/-
Positive individual verification times imply positive total verification time
when the menu is nonempty.
-/
lemma aggregate_verify_pos {ι : Type*} [Fintype ι] [Nonempty ι]
    (R : ι → Recipe) (hpos : ∀ i, 0 < (R i).verify) :
    0 < (aggregate R).verify := by
  exact Finset.sum_pos ( fun i _ => hpos i ) Finset.univ_nonempty

/-
Verification shares are nonnegative.
-/
lemma weight_nonneg {ι : Type*} [Fintype ι]
    (R : ι → Recipe) (i : ι) : 0 ≤ weight R i := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ )

/-
The verification shares form a partition of unity.
-/
theorem sum_weight_eq_one {ι : Type*} [Fintype ι] [Nonempty ι]
    (R : ι → Recipe) (hpos : ∀ i, 0 < (R i).verify) :
    ∑ i, weight R i = 1 := by
  unfold weight;
  rw [ ← Finset.sum_div _ _ _, div_eq_iff ] <;> norm_cast;
  · simp +decide [ aggregate ];
  · exact ne_of_gt ( aggregate_verify_pos R hpos )

/-
**Recipe--barycenter bridge.**  The aggregate ratio is the convex combination
of individual ratios weighted by verification work.
-/
theorem aggregate_ratio_eq_barycenter {ι : Type*} [Fintype ι] [Nonempty ι]
    (R : ι → Recipe) (hpos : ∀ i, 0 < (R i).verify) :
    ratio (aggregate R) = ∑ i, weight R i * ratio (R i) := by
  -- By definition of ratio and weight, we can rewrite the right-hand side.
  unfold ratio weight;
  simp +decide [div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, aggregate]
  simp +decide [ne_of_gt (hpos _)]
  rw [ Finset.sum_mul _ _ _ ]

/-
The barycenter cannot exceed a common upper bound for all dish ratios.
-/
theorem aggregate_ratio_le {ι : Type*} [Fintype ι] [Nonempty ι]
    (R : ι → Recipe) (hpos : ∀ i, 0 < (R i).verify)
    (b : ℚ) (hub : ∀ i, ratio (R i) ≤ b) :
    ratio (aggregate R) ≤ b := by
  convert Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hub i ) ( weight_nonneg R i );
  convert aggregate_ratio_eq_barycenter R hpos;
  rw [ ← Finset.sum_mul _ _ _, sum_weight_eq_one R hpos, one_mul ]

/-
The barycenter cannot fall below a common lower bound for all dish ratios.
-/
theorem le_aggregate_ratio {ι : Type*} [Fintype ι] [Nonempty ι]
    (R : ι → Recipe) (hpos : ∀ i, 0 < (R i).verify)
    (a : ℚ) (hlb : ∀ i, a ≤ ratio (R i)) :
    a ≤ ratio (aggregate R) := by
  rw [ aggregate_ratio_eq_barycenter R hpos ];
  refine' le_trans _ ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hlb i ) ( weight_nonneg R i ) );
  rw [ ← Finset.sum_mul _ _ _, sum_weight_eq_one R hpos, one_mul ]

/-
Hence the aggregate ratio lies in every interval containing all individual
ratios: a direct convex-hull statement in one dimension.
-/
theorem aggregate_ratio_mem_interval {ι : Type*} [Fintype ι] [Nonempty ι]
    (R : ι → Recipe) (hpos : ∀ i, 0 < (R i).verify)
    (a b : ℚ) (hmem : ∀ i, ratio (R i) ∈ Set.Icc a b) :
    ratio (aggregate R) ∈ Set.Icc a b := by
  convert Set.mem_Icc.mpr ( And.intro ( le_aggregate_ratio R hpos a fun i => ( hmem i ).1 ) ( aggregate_ratio_le R hpos b fun i => ( hmem i ).2 ) ) using 1

/-
A positive-time recipe has ratio one exactly when cooking and verification
costs agree.
-/
lemma ratio_eq_one_iff {R : Recipe} (hpos : 0 < R.verify) :
    ratio R = 1 ↔ R.cook = R.verify := by
  unfold ratio; rw [ div_eq_iff ] <;> norm_cast ; aesop;
  linarith

/-
**Boundary rigidity.**  If every dish is physical (`V ≤ C`) and every
verification time is positive, then a globally break-even menu is possible exactly
when every dish is individually break-even.  Convex-geometrically, a barycenter of
points in `[1,∞)` equals the boundary point `1` iff every positively weighted point
is `1`.
-/
theorem aggregate_ratio_eq_one_iff {ι : Type*} [Fintype ι] [Nonempty ι]
    (R : ι → Recipe) (hpos : ∀ i, 0 < (R i).verify)
    (hphysical : ∀ i, (R i).verify ≤ (R i).cook) :
    ratio (aggregate R) = 1 ↔ ∀ i, ratio (R i) = 1 := by
  constructor <;> intro h;
  · -- By definition of aggregate, we have that the total cooking time equals the total verification time.
    have h_total : ∑ i, (R i).cook = ∑ i, (R i).verify := by
      exact_mod_cast eq_of_div_eq_one h;
    -- By definition of aggregate, we have that each individual cooking time equals its verification time.
    have h_each : ∀ i, (R i).cook = (R i).verify := by
      exact fun i => le_antisymm ( le_of_not_gt fun hi => by have := Finset.sum_lt_sum ( fun a _ => hphysical a ) ⟨ i, Finset.mem_univ i, hi ⟩ ; aesop ) ( hphysical i );
    exact fun i => ratio_eq_one_iff ( hpos i ) |>.2 ( h_each i );
  · convert aggregate_ratio_eq_barycenter R hpos;
    simp +decide [ h, sum_weight_eq_one R hpos ]

/-- A concrete three-dish example illustrating the barycentric identity. -/
example :
    ratio (aggregate ![Recipe.mk 6 2, Recipe.mk 12 3, Recipe.mk 5 5]) =
      (2 / 10 : ℚ) * 3 + (3 / 10 : ℚ) * 4 + (5 / 10 : ℚ) * 1 := by
  norm_num [ratio, aggregate, Fin.sum_univ_succ]

end RecipeBarycenter