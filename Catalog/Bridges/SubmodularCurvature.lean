/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Submodular Curvature and Threshold Rounding

This file establishes the **curvature-gap theorem** for threshold rounding of
submodular objectives on hypergraphs. The central result shows that for a monotone
submodular function `f` with curvature `κ < 1` on a hypergraph of rank `d`,
threshold rounding produces a set `S` satisfying:

  `f(S) ≤ d / (1 - κ) · F(x)`

where `F(x)` is the finite multilinear extension of `f` at the fractional point `x`.

## Mathematical Overview

The proof proceeds in three stages:

1. **Submodular telescope** (curvature-free): `f(A) ≤ ∑_{v ∈ A} f({v})`
2. **Curvature lower bound**: `f(A) ≥ (1 - κ) · ∑_{v ∈ A} f({v})`
3. **Multilinear extension lower bound**: `F(x) ≥ (1 - κ) · ∑_v x_v · f({v})`

Combined with the weighted threshold rounding bound from the catalog:
  `∑_{v ∈ S} w(v) ≤ d · ∑_v x_v · w(v)`

this yields the curvature-gap theorem.

## Main Definitions

* `IsMonotoneSubmodular` — monotonicity + lattice submodularity
* `singletonWeight` — the map `v ↦ f({v})`
* `totalCurvatureBound` — total curvature predicate
* `HasCurvatureModularUpperBound` — modular upper bound from curvature
* `bernoulliProductMass` — Bernoulli product measure on subsets
* `finiteMultilinearExtension` — finite multilinear extension of a set function

## Main Results

* `submodular_telescope_singletons` — `f(A) ≤ ∑_{v∈A} f({v})`
* `curvature_lower_bound` — `f(A) ≥ (1-κ) ∑_{v∈A} f({v})`
* `multilinear_lower_bound` — `F(x) ≥ (1-κ) ∑_v x_v f({v})`
* `threshold_submodular_bound` — the main curvature-gap theorem

## Cross-Domain Applications

The curvature-gap theorem connects to:
- **Feature selection**: coverage objectives with diminishing returns
- **Influence maximization**: independent cascade submodular spread
- **Welfare economics**: utility aggregation under diminishing marginal returns
- **Statistical physics**: comparison of stochastic and deterministic ground states

## References

* Conforti, Cornuéjols, "Submodular set functions, matroids and the greedy algorithm" (1984)
* Vondrák, "Optimal approximation for the submodular welfare problem" (2008)
* Sviridenko, Vondrák, Ward, "Optimal approximation for submodular and supermodular
  optimization with bounded curvature" (2017)
-/

open Finset BigOperators

/-! ### Core Definitions -/

/-- A set function is monotone submodular if it is monotone (with respect to inclusion)
and satisfies the lattice submodularity inequality `f(A) + f(B) ≥ f(A ∪ B) + f(A ∩ B)`. -/
def IsMonotoneSubmodular
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) : Prop :=
  (∀ A B : Finset V, A ⊆ B → f A ≤ f B) ∧
  (∀ A B : Finset V, f A + f B ≥ f (A ∪ B) + f (A ∩ B))

/-- The singleton weight of element `v` under set function `f`. -/
def singletonWeight
    {V : Type*} [DecidableEq V]
    (f : Finset V → ℝ) (v : V) : ℝ :=
  f ({v})

/-- Total curvature bound: for every element with positive singleton value,
the marginal gain at the full set is at least `(1 - κ)` times the singleton value.
When `κ = 0`, all marginals equal singleton values (modular function).
When `κ → 1`, marginals at the full set vanish (extreme submodularity). -/
def totalCurvatureBound
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ) : Prop :=
  ∀ v : V, 0 < singletonWeight f v →
    (1 - κ) * singletonWeight f v ≤
      f Finset.univ - f (Finset.univ.erase v)

/-- A monotone submodular function with curvature `κ` is pointwise dominated by
a modular function scaled by `1/(1-κ)`. -/
def HasCurvatureModularUpperBound
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ) : Prop :=
  ∀ A : Finset V,
    f A ≤ (1 / (1 - κ)) * ∑ v ∈ A, f ({v})

/-- The Bernoulli product mass: the probability that the random set equals exactly `A`
when each element `v` is included independently with probability `x v`. -/
noncomputable def bernoulliProductMass
    {V : Type*} [Fintype V] [DecidableEq V]
    (x : V → ℝ) (A : Finset V) : ℝ :=
  (∏ v ∈ A, x v) * (∏ v ∈ Aᶜ, (1 - x v))

/-- The finite multilinear extension of a set function `f` at fractional point `x`.
This is `E[f(R_x)]` where `R_x` is a random set with each element included
independently with probability `x v`. Defined combinatorially as a sum over
all subsets. -/
noncomputable def finiteMultilinearExtension
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (x : V → ℝ) : ℝ :=
  ∑ A ∈ Finset.univ.powerset, bernoulliProductMass x A * f A

/-- The threshold rounding operator: given a fractional assignment `x` and
threshold `θ`, produce the finset `{v | θ ≤ x v}`. -/
noncomputable def thresholdSet
    {α : Type*} [Fintype α] [DecidableEq α]
    (x : α → ℝ) (θ : ℝ) : Finset α :=
  Finset.univ.filter (fun v => θ ≤ x v)

/-- A fractional transversal of an indexed hypergraph: `x` is nonneg and covers
every edge (the sum over each edge is at least 1). -/
def fractionalTransversal
    {V E : Type*} [Fintype V] [DecidableEq V] [Fintype E]
    (Inc : E → Finset V) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e : E, 1 ≤ ∑ v ∈ Inc e, x v

/-! ### Diminishing Returns from Lattice Submodularity -/

/-
Submodularity in lattice form implies the diminishing returns property:
if `A ⊆ B` and `v ∉ B`, then the marginal gain of `v` at `A` is at least
the marginal gain at `B`.
-/
theorem submodular_diminishing_returns
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ)
    (hsub : ∀ A B : Finset V, f A + f B ≥ f (A ∪ B) + f (A ∩ B))
    (A B : Finset V) (v : V)
    (hAB : A ⊆ B) (hv : v ∉ B) :
    f (B ∪ {v}) - f B ≤ f (A ∪ {v}) - f A := by
  have := hsub ( A ∪ { v } ) B;
  simp_all +decide [ Finset.inter_eq_left.mpr hAB, Finset.insert_union, Finset.union_assoc ];
  rw [ show insert v ( A ∪ B ) = insert v B by ext x; by_cases hx : x = v <;> aesop ] at this ; linarith

/-
The marginal gain of element `v` to any set `A` (with `v ∉ A`) is at most `f({v})`,
for normalized monotone submodular functions.
-/
theorem marginal_le_singleton
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (A : Finset V) (v : V) (hv : v ∉ A) :
    f (A ∪ {v}) - f A ≤ f ({v}) := by
  convert submodular_diminishing_returns f hsub.2 ∅ A v _ _ using 1 <;> simp +decide [ * ]

/-! ### Theorem 1: Submodular Telescope (Curvature-Free Upper Bound) -/

/-
**Submodular telescope by singletons.** For any normalized monotone submodular `f`,
the value `f(A)` is bounded above by the sum of singleton values.
This is the curvature-zero baseline.

Proof by induction on `A`: decompose `A = insert v B`, use diminishing returns to
bound the marginal `f(insert v B) - f(B) ≤ f({v})`, and sum over elements.
-/
theorem submodular_telescope_singletons
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0) :
    ∀ A : Finset V, f A ≤ ∑ v ∈ A, f ({v}) := by
  have := @marginal_le_singleton;
  intro A;
  induction' A using Finset.induction with v A hv ih;
  simpa [ hnorm ];
  specialize this f hsub hnorm A v hv ; simp_all +decide [ Finset.sum_insert, sub_le_iff_le_add' ];
  linarith

/-! ### Curvature Lower Bound on Marginals -/

/-
The marginal gain of `v` added to `A ⊆ V\{v}` is at least the marginal at `V\{v}`,
by the diminishing returns property of submodularity.
-/
theorem marginal_ge_marginal_at_full
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ)
    (hsub : IsMonotoneSubmodular f)
    (A : Finset V) (v : V) (hv : v ∉ A) :
    f Finset.univ - f (Finset.univ.erase v) ≤ f (insert v A) - f A := by
  have := submodular_diminishing_returns f hsub.2 A ( Finset.univ.erase v ) v ?_ ?_;
  · convert this using 2 <;> simp +decide [ Finset.union_comm, hv ];
  · exact fun x hx => Finset.mem_erase_of_ne_of_mem ( by aesop ) ( Finset.mem_univ x );
  · grind +splitImp

/-
**Curvature controls marginals.** For a monotone submodular function with
curvature bound `κ`, the marginal gain of any element `v` to any set not containing it
is at least `(1-κ) · f({v})`.
-/
theorem curvature_controls_marginal
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (hk1 : κ < 1)
    (hcurv : totalCurvatureBound f κ) :
    ∀ (A : Finset V) (v : V), v ∉ A →
      (1 - κ) * f ({v}) ≤ f (insert v A) - f A := by
  intro A v hv;
  by_cases h : 0 < f { v } <;> simp_all +decide [ totalCurvatureBound ];
  · exact le_trans ( hcurv v h ) ( marginal_ge_marginal_at_full f hsub A v hv );
  · exact le_trans ( mul_nonpos_of_nonneg_of_nonpos ( sub_nonneg.2 hk1.le ) h ) ( sub_nonneg.2 ( hsub.1 _ _ ( Finset.subset_insert _ _ ) ) )

/-! ### Theorem 2: Curvature Lower Bound -/

/-
**Curvature lower bound.** For a normalized monotone submodular function with
curvature `κ`, the function value on any set is at least `(1-κ)` times the sum of
singleton values.

Proof by induction on `A`: decompose `A = insert v B`, use the curvature marginal
bound `f(insert v B) - f(B) ≥ (1-κ) f({v})`, and sum.
-/
theorem curvature_lower_bound
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (κ : ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (hk1 : κ < 1)
    (hcurv : totalCurvatureBound f κ) :
    ∀ A : Finset V, (1 - κ) * ∑ v ∈ A, f ({v}) ≤ f A := by
  intro A; induction' A using Finset.induction_on with v A hv ih; aesop;
  have := curvature_controls_marginal f κ hsub hnorm hk1 hcurv A v hv;
  rw [ Finset.sum_insert hv ] ; linarith

/-! ### Bernoulli Product Measure Properties -/

/-
The Bernoulli product masses sum to 1 over all subsets (it is a probability
distribution).
-/
theorem bernoulli_total_mass
    {V : Type*} [Fintype V] [DecidableEq V]
    (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v) (hx1 : ∀ v, x v ≤ 1) :
    ∑ A ∈ Finset.univ.powerset, bernoulliProductMass x A = 1 := by
  -- The sum of the Bernoulli product masses over all subsets is equal to the product of the sums of the probabilities for each element.
  have h_sum : ∑ A ∈ Finset.powerset (Finset.univ : Finset V), (∏ v ∈ A, x v) * (∏ v ∈ (Finset.univ : Finset V) \ A, (1 - x v)) = ∏ v : V, (x v + (1 - x v)) := by
    exact?;
  unfold bernoulliProductMass; aesop;

/-
The marginal probability of element `v` under the Bernoulli product measure
equals `x v`.
-/
theorem bernoulli_marginal
    {V : Type*} [Fintype V] [DecidableEq V]
    (x : V → ℝ) (v : V)
    (hx0 : ∀ v, 0 ≤ x v) (hx1 : ∀ v, x v ≤ 1) :
    ∑ A ∈ (Finset.univ.powerset.filter (fun A => v ∈ A)), bernoulliProductMass x A = x v := by
  -- By grouping the terms in the sum, we can rewrite the summation to focus on the element $v$.
  have h_group : ∑ A ∈ Finset.univ.powerset with v ∈ A, bernoulliProductMass x A = ∑ B ∈ Finset.univ.powerset with v ∉ B, bernoulliProductMass x (insert v B) := by
    refine' Finset.sum_bij ( fun A hA => A.erase v ) _ _ _ _ <;> simp_all +decide [ Finset.mem_powerset ];
    · intro a₁ ha₁ a₂ ha₂ h; rw [ ← Finset.insert_erase ha₁, ← Finset.insert_erase ha₂, h ] ;
    · exact fun b hb => ⟨ Insert.insert v b, Finset.mem_insert_self _ _, by rw [ Finset.erase_insert hb ] ⟩;
  -- By definition of product over a subset, we can rewrite the sum as:
  have h_prod_subset : ∑ B ∈ Finset.univ.powerset with v ∉ B, bernoulliProductMass x (insert v B) = x v * ∑ B ∈ Finset.univ.powerset with v ∉ B, (∏ v ∈ B, x v) * (∏ v ∈ (Finset.univ \ (insert v B)), (1 - x v)) := by
    simp +decide only [bernoulliProductMass, sdiff_insert, Finset.mul_sum _ _ _];
    refine' Finset.sum_congr rfl fun B hB => _;
    simp +decide [ ← mul_assoc, Finset.compl_eq_univ_sdiff, Finset.sdiff_insert, Finset.sdiff_singleton_eq_erase, Finset.prod_erase ];
    exact Or.inl ( Finset.prod_insert ( by aesop ) );
  -- Apply the total mass identity to rewrite the sum as 1.
  have h_total_mass : ∑ B ∈ Finset.univ.powerset with v ∉ B, (∏ v ∈ B, x v) * (∏ v ∈ (Finset.univ \ (insert v B)), (1 - x v)) = ∑ B ∈ Finset.powerset (Finset.univ \ {v}), (∏ v ∈ B, x v) * (∏ v ∈ (Finset.univ \ {v}) \ B, (1 - x v)) := by
    refine' Finset.sum_bij ( fun B hB => B ) _ _ _ _ <;> simp +contextual [ Finset.subset_iff ];
    simp +contextual [ Finset.sdiff_insert, Finset.sdiff_singleton_eq_erase ];
    exact fun a ha => Or.inl ( by rw [ Finset.sdiff_eq_filter, Finset.sdiff_eq_filter ] ; congr; ext; aesop ) ;
  have h_total_mass : ∑ B ∈ Finset.powerset (Finset.univ \ {v}), (∏ v ∈ B, x v) * (∏ v ∈ (Finset.univ \ {v}) \ B, (1 - x v)) = ∏ v ∈ Finset.univ \ {v}, (x v + (1 - x v)) := by
    rw [ Finset.prod_add ];
  aesop

/-
The Bernoulli product mass is nonneg when all probabilities are in [0,1].
-/
theorem bernoulli_mass_nonneg
    {V : Type*} [Fintype V] [DecidableEq V]
    (x : V → ℝ) (A : Finset V)
    (hx0 : ∀ v, 0 ≤ x v) (hx1 : ∀ v, x v ≤ 1) :
    0 ≤ bernoulliProductMass x A := by
  exact mul_nonneg ( Finset.prod_nonneg fun _ _ => hx0 _ ) ( Finset.prod_nonneg fun _ _ => sub_nonneg.2 ( hx1 _ ) )

/-! ### Multilinear Extension of Modular Functions -/

/-
**Bernoulli expectation of modular weights.** The multilinear extension of a
modular (additive) function equals the expected modular value. This is a finite
combinatorial version of linearity of expectation.
-/
theorem finiteMultilinear_modular_eq
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → ℝ) (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v) (hx1 : ∀ v, x v ≤ 1) :
    finiteMultilinearExtension (fun A => ∑ v ∈ A, w v) x
      = ∑ v : V, x v * w v := by
  convert bernoulli_marginal x using 1;
  constructor <;> intro h;
  · exact?;
  · -- By Fubini's theorem, we can interchange the order of summation.
    have h_fubini : ∑ A ∈ Finset.powerset (Finset.univ : Finset V), bernoulliProductMass x A * ∑ v ∈ A, w v = ∑ v, w v * ∑ A ∈ Finset.powerset (Finset.univ : Finset V), (if v ∈ A then bernoulliProductMass x A else 0) := by
      simp +decide only [Finset.mul_sum _ _ _, mul_comm];
      rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop;
    simp_all +decide [ mul_comm, Finset.sum_ite ];
    exact h_fubini

/-! ### Theorem 3: Multilinear Extension Lower Bound -/

/-
**Multilinear extension lower bound from curvature.** For a normalized monotone
submodular function with curvature `κ`, the multilinear extension is bounded below
by `(1-κ)` times the modular expectation.

This combines the pointwise curvature lower bound `f(A) ≥ (1-κ) ∑_{v∈A} f({v})`
with linearity of expectation for Bernoulli products.
-/
theorem multilinear_lower_bound
    {V : Type*} [Fintype V] [DecidableEq V]
    (f : Finset V → ℝ) (x : V → ℝ) (κ : ℝ)
    (hx0 : ∀ v, 0 ≤ x v) (hx1 : ∀ v, x v ≤ 1)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (hk1 : κ < 1)
    (hcurv : totalCurvatureBound f κ) :
    (1 - κ) * ∑ v : V, x v * f ({v}) ≤ finiteMultilinearExtension f x := by
  -- By curvature_lower_bound: for all A, (1-κ) * Σ_{v∈A} f({v}) ≤ f(A). Therefore:
  have h_sum : ∑ A ∈ Finset.univ.powerset, bernoulliProductMass x A * (1 - κ) * ∑ v ∈ A, f {v} ≤ ∑ A ∈ Finset.univ.powerset, bernoulliProductMass x A * f A := by
    refine Finset.sum_le_sum fun A _ => ?_;
    rw [ mul_assoc ];
    exact mul_le_mul_of_nonneg_left ( curvature_lower_bound f κ hsub hnorm hk1 hcurv A ) ( bernoulli_mass_nonneg x A hx0 hx1 );
  convert h_sum using 1;
  convert congr_arg ( fun y => ( 1 - κ ) * y ) ( finiteMultilinear_modular_eq ( fun v => f { v } ) x hx0 hx1 |> Eq.symm ) using 1;
  unfold finiteMultilinearExtension; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-! ### The Main Curvature-Gap Theorem -/

/-
**Curvature-gap threshold bound (main theorem).**

Let `H` be a hypergraph with maximum edge size `d`, `x` a feasible fractional
transversal in `[0,1]^V`, and `f` a normalized monotone submodular function with
curvature `κ < 1`. Then threshold rounding at `1/d` produces a set `S` with:

  `f(S) ≤ (d / (1-κ)) · F(x)`

where `F(x)` is the finite multilinear extension of `f` at `x`.

**Proof strategy:**
1. By `submodular_telescope_singletons`: `f(S) ≤ ∑_{v ∈ S} f({v})`.
2. By the catalog's `threshold_weighted_sum_bound` with `w = f({·})`:
   `∑_{v ∈ S} f({v}) ≤ d · ∑_v x_v · f({v})`.
3. By `multilinear_lower_bound`: `(1-κ) · ∑_v x_v · f({v}) ≤ F(x)`,
   hence `∑_v x_v · f({v}) ≤ F(x) / (1-κ)`.
4. Combining: `f(S) ≤ d / (1-κ) · F(x)`.
-/
theorem threshold_submodular_curvature_gap_bound
    {V E : Type*} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (Inc : E → Finset V)
    (d : ℕ)
    (hd : ∀ e : E, (Inc e).card ≤ d)
    (hd_pos : 0 < d)
    (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v)
    (hx1 : ∀ v, x v ≤ 1)
    (htrans : fractionalTransversal Inc x)
    (f : Finset V → ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (hfnn : ∀ v, 0 ≤ f ({v}))
    (κ : ℝ)
    (hk0 : 0 ≤ κ)
    (hk1 : κ < 1)
    (hcurv : totalCurvatureBound f κ) :
    f (thresholdSet x ((1 : ℝ) / d)) ≤
      (d : ℝ) / (1 - κ) * finiteMultilinearExtension f x := by
  -- By the catalog's `threshold_weighted_sum_bound` with `w = f({·})`:
  have threshold_sum : ∑ v ∈ thresholdSet x (1 / d), f { v } ≤ (d : ℝ) * ∑ v : V, x v * f { v } := by
    have h_sum : ∑ v ∈ thresholdSet x (1 / d), f {v} ≤ d * ∑ v ∈ thresholdSet x (1 / d), (1 / d) * f {v} := by
      simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, hd_pos.ne' ];
    refine' le_trans h_sum ( mul_le_mul_of_nonneg_left _ ( Nat.cast_nonneg _ ) );
    refine' le_trans _ ( Finset.sum_le_sum fun v _ => mul_le_mul_of_nonneg_right ( show x v ≥ 1 / d * ( if v ∈ thresholdSet x ( 1 / d ) then 1 else 0 ) from _ ) ( hfnn v ) );
    · simp +decide [ Finset.sum_ite, Finset.filter_mem_eq_inter, Finset.filter_not ];
    · split_ifs <;> simp_all +decide [ thresholdSet ];
  convert le_trans _ ( mul_le_mul_of_nonneg_left ( multilinear_lower_bound f x κ hx0 hx1 hsub hnorm hk1 hcurv ) ( show 0 ≤ ( d : ℝ ) / ( 1 - κ ) by exact div_nonneg ( Nat.cast_nonneg _ ) ( by linarith ) ) ) using 1;
  rw [ ← mul_assoc, div_mul_cancel₀ _ ( by linarith ) ];
  exact le_trans ( submodular_telescope_singletons f hsub hnorm _ ) threshold_sum

/-! ### Corollary: Modular Surrogate Bound (no multilinear extension needed) -/

/-
The modular surrogate bound: `f(S) ≤ d · ∑_v x_v f({v})`.
This is the curvature-free version using only submodularity.
-/
theorem threshold_submodular_modular_bound
    {V E : Type*} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (Inc : E → Finset V)
    (d : ℕ)
    (_hd : ∀ e : E, (Inc e).card ≤ d)
    (hd_pos : 0 < d)
    (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v)
    (_htrans : fractionalTransversal Inc x)
    (f : Finset V → ℝ)
    (hsub : IsMonotoneSubmodular f)
    (hnorm : f ∅ = 0)
    (hfnn : ∀ v, 0 ≤ f ({v})) :
    f (thresholdSet x ((1 : ℝ) / d)) ≤
      (d : ℝ) * ∑ v : V, x v * f ({v}) := by
  -- Apply the submodular telescope lemma to the set $S = \text{thresholdSet } x (1 / d)$.
  have h_telescope : f (thresholdSet x (1 / d)) ≤ ∑ v ∈ thresholdSet x (1 / d), f {v} := by
    convert submodular_telescope_singletons f hsub hnorm ( thresholdSet x ( 1 / ( d : ℝ ) ) ) using 1;
  -- Since $S = \text{thresholdSet } x (1 / d)$, we have $f({v}) \leq d \cdot (f({v}) \cdot x v)$ for each $v \in S$.
  have h_bound : ∀ v ∈ thresholdSet x (1 / d), f {v} ≤ d * (f {v} * x v) := by
    intro v hv
    have h_bound : 1 ≤ d * x v := by
      simp_all +decide [ thresholdSet ];
      rwa [ inv_eq_one_div, div_le_iff₀' ( by positivity ) ] at hv;
    nlinarith only [ h_bound, hfnn v ];
  refine' le_trans h_telescope ( le_trans ( Finset.sum_le_sum h_bound ) _ );
  simp +decide only [mul_comm, Finset.mul_sum _ _ _];
  exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => mul_nonneg ( Nat.cast_nonneg _ ) ( mul_nonneg ( hx0 _ ) ( hfnn _ ) )

/-! ### Specialization: Cardinality Objective -/

/-
When `f = card`, the curvature is zero and the bound reduces to the classical
threshold cardinality bound from the catalog.
-/
theorem curvature_gap_specializes_to_card
    {V E : Type*} [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    (Inc : E → Finset V)
    (d : ℕ)
    (hd : ∀ e : E, (Inc e).card ≤ d)
    (hd_pos : 0 < d)
    (x : V → ℝ)
    (hx0 : ∀ v, 0 ≤ x v)
    (htrans : fractionalTransversal Inc x) :
    ((thresholdSet x ((1 : ℝ) / d)).card : ℝ) ≤
      (d : ℝ) * ∑ v : V, x v := by
  convert threshold_submodular_modular_bound Inc d hd hd_pos x hx0 htrans ( fun A => Finset.card A ) _ _ _ using 1 <;> norm_num;
  constructor;
  · exact fun A B hAB => Nat.cast_le.mpr ( Finset.card_le_card hAB );
  · simp +decide [ ← Nat.cast_add, Finset.card_union_add_card_inter ]