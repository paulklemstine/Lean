/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sheaf-Theoretic Data Integration

This file formalizes a sheaf-theoretic theory of data integration for databases
with missing entries.

## Main definitions

* `Database α n k` — a table with `n` columns and `k` rows, each entry `Option α`.
* `Database.partialSection` — the partial section recording observed values.
* `DataSection D R` — sections of the data sheaf over a finite set of rows `R`:
  total assignments to the cells of the rows in `R` extending the partial section.
* `restrictSec` — the restriction maps of the presheaf.
* `numConstraints n k` — the number of pairwise-overlap constraints.

## Main results

* `restrictSec_self`, `restrictSec_comp` — presheaf functoriality (identity / composition).
* `DataSheaf.locality` — the locality (separation) sheaf axiom.
* `DataSheaf.gluing` — the gluing sheaf axiom.
* `numConstraints_eq` — closed form `C(n,k) = C(k,2)·C(n,2)·2^(n-2)`.
* `consistency_probability` — `P(consistent) = q ^ C` via `iIndepSet.meas_biInter`.
* `imputation_cycle_path_independent` — Čech cycle identity ⟹ path-independent imputation.
* `sheaf_prob_tendsto_zero` — as `r → 1`, `P(sheaf) → 0`.
* `sheaf_prob_decay_in_constraints` — exponential decay of `q ^ C`.
-/

import Mathlib
import Catalog.MachineLearning.CechComplex

noncomputable section

open Finset Function MeasureTheory ProbabilityTheory
open scoped ENNReal

namespace DataSheafIntegration

/-! ## §1. Databases and partial sections -/

/-- A **database** with `n` columns and `k` rows, where each cell is either an
observed value `some a` or a missing value `none`. -/
structure Database (α : Type*) (n k : ℕ) where
  /-- `entry i j` is the content of row `i`, column `j`. -/
  entry : Fin k → Fin n → Option α

variable {α : Type*} {n k : ℕ}

/-- The set of **observed** (non-missing) cells of a database. -/
def Database.observed (D : Database α n k) : Set (Fin k × Fin n) :=
  {p | (D.entry p.1 p.2).isSome}

/-- The **partial section** of a database: the function defined on the observed
(non-missing) cells returning the observed value. -/
def Database.partialSection (D : Database α n k) :
    ∀ p : Fin k × Fin n, (D.entry p.1 p.2).isSome → α :=
  fun p h => (D.entry p.1 p.2).get h

/-! ## §2. The data sheaf and its sheaf axioms -/

/-- A **section** of the data sheaf over a finite set of rows `R`: a total
assignment of a value in `α` to every cell of every row in `R`, agreeing with
the observed values of the database (extending the partial section). -/
abbrev DataSection (D : Database α n k) (R : Finset (Fin k)) : Type _ :=
  { g : R → Fin n → α //
      ∀ (i : R) (j : Fin n) (h : (D.entry (i : Fin k) j).isSome),
        (D.entry (i : Fin k) j).get h = g i j }

/-- The **restriction map** of the data presheaf, from a section over `R` to a
section over a smaller row set `R' ⊆ R`. -/
def restrictSec (D : Database α n k) {R R' : Finset (Fin k)} (h : R' ⊆ R)
    (s : DataSection D R) : DataSection D R' :=
  ⟨fun i => s.1 ⟨(i : Fin k), h i.2⟩,
   fun i j hj => s.2 ⟨(i : Fin k), h i.2⟩ j hj⟩

/-- **Identity axiom**: restricting along the identity inclusion does nothing. -/
theorem restrictSec_self (D : Database α n k) (R : Finset (Fin k))
    (s : DataSection D R) : restrictSec D (le_refl R) s = s := by
  convert rfl

/-- **Functoriality**: restriction is compatible with composition of inclusions. -/
theorem restrictSec_comp (D : Database α n k) {R R' R'' : Finset (Fin k)}
    (h1 : R'' ⊆ R') (h2 : R' ⊆ R) (s : DataSection D R) :
    restrictSec D h1 (restrictSec D h2 s) = restrictSec D (h1.trans h2) s := by
  rfl

/-- **Locality / separation axiom**: if two global sections over `R` restrict to
equal sections on every member of a cover of `R`, then they are equal. -/
theorem DataSheaf.locality (D : Database α n k) (R : Finset (Fin k)) {ι : Type*}
    (cover : ι → Finset (Fin k)) (hsub : ∀ a, cover a ⊆ R)
    (hcov : ∀ i ∈ R, ∃ a, i ∈ cover a) (s t : DataSection D R)
    (h : ∀ a, restrictSec D (hsub a) s = restrictSec D (hsub a) t) : s = t := by
  refine' Subtype.ext ( funext fun i => _ );
  obtain ⟨ a, ha ⟩ := hcov i i.2;
  convert congr_arg Subtype.val ( h a ) |> congr_arg ( fun f => f ⟨ i, ha ⟩ ) using 1

/-- **Gluing axiom**: a compatible family of local sections over a cover of `R`
glues to a (global) section over `R` restricting to each. -/
theorem DataSheaf.gluing (D : Database α n k) (R : Finset (Fin k)) {ι : Type*}
    (cover : ι → Finset (Fin k)) (hsub : ∀ a, cover a ⊆ R)
    (hcov : ∀ i ∈ R, ∃ a, i ∈ cover a) (s : ∀ a, DataSection D (cover a))
    (hcompat : ∀ (a b : ι) (i : Fin k) (hia : i ∈ cover a) (hib : i ∈ cover b),
        (s a).1 ⟨i, hia⟩ = (s b).1 ⟨i, hib⟩) :
    ∃ g : DataSection D R, ∀ a, restrictSec D (hsub a) g = s a := by
  refine' ⟨ ⟨ fun i => ( s ( Classical.choose ( hcov i i.2 ) ) |> Subtype.val ) ⟨ i, Classical.choose_spec ( hcov i i.2 ) ⟩, _ ⟩, _ ⟩;
  exact fun i j hj => ( s ( Classical.choose ( hcov i i.2 ) ) ).2 ⟨ i, Classical.choose_spec ( hcov i i.2 ) ⟩ j hj ▸ rfl;
  intro a; ext i; exact (by
  exact hcompat _ _ _ ( Classical.choose_spec ( hcov _ ( hsub _ i.2 ) ) ) i.2 ▸ rfl);

/-! ## §3. Overlap constraints and their count -/

/-- The number of **pairwise-overlap constraints**: for each unordered pair of
rows `{i,j}` and each subset `S` of columns with `|S| ≥ 2`, there are `C(|S|,2)`
pairwise agreement constraints among the columns of `S`. -/
def numConstraints (n k : ℕ) : ℕ :=
  ∑ _P ∈ (Finset.univ : Finset (Fin k)).powersetCard 2,
    ∑ S ∈ (Finset.univ : Finset (Fin n)).powerset.filter (fun S => 2 ≤ S.card),
      Nat.choose S.card 2

/-- The **column part** of the constraint count has closed form `C(n,2)·2^(n-2)`. -/
theorem columnConstraints_eq (n : ℕ) :
    ∑ S ∈ (Finset.univ : Finset (Fin n)).powerset.filter (fun S => 2 ≤ S.card),
      Nat.choose S.card 2 = Nat.choose n 2 * 2 ^ (n - 2) := by
  by_cases hn : n < 2;
  · interval_cases n <;> trivial;
  · -- For $n \geq 2$, we can use the identity $\sum_{j=2}^{n} \binom{n}{j} \binom{j}{2} = \binom{n}{2} \sum_{j=2}^{n} \binom{n-2}{j-2}$.
    have h_identity : ∑ j ∈ Finset.Icc 2 n, Nat.choose n j * Nat.choose j 2 = Nat.choose n 2 * ∑ j ∈ Finset.Icc 2 n, Nat.choose (n - 2) (j - 2) := by
      rw [ Finset.mul_sum _ _ _ ] ; refine' Finset.sum_congr rfl fun x hx => _ ; rcases n with ( _ | _ | n ) <;> rcases x with ( _ | _ | x ) <;> simp_all +decide ; ring;
      rw [ Nat.add_comm 2 n, Nat.add_comm 2 x, Nat.choose_mul ];
      · rfl;
      · grind;
    convert h_identity using 1;
    · rw [ show ( Finset.univ.powerset.filter fun S => 2 ≤ Finset.card S ) = Finset.biUnion ( Finset.Icc 2 n ) fun j => Finset.powersetCard j Finset.univ from ?_, Finset.sum_biUnion ];
      · exact Finset.sum_congr rfl fun x hx => by rw [ Finset.sum_congr rfl fun y hy => by rw [ Finset.mem_powersetCard.mp hy |>.2 ] ] ; simp +decide [ Finset.card_univ ] ;
      · exact fun i hi j hj hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| by rw [ Finset.mem_powersetCard ] at hx₁ hx₂; aesop;
      · ext; simp [Finset.mem_biUnion, Finset.mem_powersetCard];
        exact fun _ => le_trans ( Finset.card_le_univ _ ) ( by simp );
    · erw [ Finset.sum_Ico_eq_sum_range ];
      simp +arith +decide;
      exact Or.inl ( by rw [ ← Nat.sum_range_choose ] ; rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Finset.sum_range_succ ] )

/-- **Closed form for the constraint count**: `C(n,k) = C(k,2)·C(n,2)·2^(n-2)`. -/
theorem numConstraints_eq (n k : ℕ) :
    numConstraints n k = Nat.choose k 2 * (Nat.choose n 2 * 2 ^ (n - 2)) := by
  unfold numConstraints; simp +decide;
  exact Or.inl <| columnConstraints_eq n

/-! ## §4. Consistency probability -/

/-
**Consistency probability**: if the per-constraint satisfaction events `E i`
are independent and each has probability `q`, then the probability that *all*
`C` constraints are satisfied simultaneously is `q ^ C`.
-/
theorem consistency_probability {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    {C : ℕ} (E : Fin C → Set Ω) (q : ℝ≥0∞)
    (hindep : iIndepSet E μ) (hmeas : ∀ i, μ (E i) = q) :
    μ (⋂ i, E i) = q ^ C := by
  convert hindep.meas_biInter ( Finset.univ : Finset ( Fin C ) );
  · simp +decide;
  · simp +decide [ hmeas ]

/-! ## §5. Path independence via the Čech complex -/

open CechCausalComplex

/-
**Telescoping cycle identity for coboundaries**: the sum of pairwise
differences of a 0-cochain around a closed cycle is zero.
-/
theorem coboundary_cycle_sum_zero (m : ℕ) (f : CechZeroCochain m) (L : ℕ)
    (v : ℕ → Fin m) (hcyc : v L = v 0) :
    ∑ t ∈ Finset.range L, coboundaryZero m f (v t) (v (t + 1)) = 0 := by
  convert Finset.sum_range_sub ( fun t => f ( v t ) ) L using 1;
  rw [ hcyc, sub_self ]

/-
**Path-independent imputation**: when the sheaf condition holds (`H¹ = 0`,
i.e. the imputation discrepancy cochain is a cocycle), the sum of pairwise
imputation differences around any closed cycle of rows vanishes. Thus imputation
is path independent: the accumulated discrepancy depends only on the endpoints.
-/
theorem imputation_cycle_path_independent (m : ℕ) (hm : 0 < m)
    (g : CechOneCochain m) (hg : IsOneCocycle m g) (L : ℕ) (v : ℕ → Fin m)
    (hcyc : v L = v 0) :
    ∑ t ∈ Finset.range L, g (v t) (v (t + 1)) = 0 := by
  have := CechCausalComplex.cocycle_eq_coboundary_on_total m hm g hg;
  obtain ⟨ f, rfl ⟩ := this; exact coboundary_cycle_sum_zero m f L v hcyc;

/-- **Čech triangle identity** specialized to imputation: for a cocycle the
pairwise differences around a triangle sum to zero. -/
theorem imputation_triangle_identity (m : ℕ) (g : CechOneCochain m)
    (hg : IsOneCocycle m g) (i j l : Fin m) :
    g i j + g j l + g l i = 0 :=
  cocycle_triangle_sum_zero m g hg i j l

/-! ## §6. Limit behavior as the missing rate approaches 1 -/

/-- The probability that all constraints hold (hence that the imputation sheaf is
consistent), as a function of the missing rate `r`, with `q = 1 - r`. -/
def sheafProb (C : ℕ) (r : ℝ) : ℝ := (1 - r) ^ C

/-
**Limit behavior**: for any positive number of constraints, as the missing
rate `r → 1`, the sheaf-consistency probability tends to `0`.
-/
theorem sheaf_prob_tendsto_zero (C : ℕ) (hC : 0 < C) :
    Filter.Tendsto (fun r : ℝ => sheafProb C r) (nhds 1) (nhds 0) := by
  convert Filter.Tendsto.pow ( tendsto_const_nhds.sub Filter.tendsto_id ) C using 2;
  · norm_num [ hC.ne' ];
  · infer_instance;
  · infer_instance

/-- **Exponential decay**: for a fixed per-constraint success probability
`0 ≤ q < 1`, the joint probability `q ^ C` decays to `0` (exponentially) as the
number of constraints `C → ∞`. -/
theorem sheaf_prob_decay_in_constraints {q : ℝ} (hq0 : 0 ≤ q) (hq1 : q < 1) :
    Filter.Tendsto (fun C : ℕ => q ^ C) Filter.atTop (nhds 0) :=
  tendsto_pow_atTop_nhds_zero_of_lt_one hq0 hq1

end DataSheafIntegration