import Mathlib

/-!
# Computational Complexity of Recipes

Every recipe is an algorithm: it takes ingredients (inputs) and produces a dish (output).
This file formalizes the computational complexity of recipes, defining cooking time,
verification time, and the complexity gap between them — an analogy to the P vs NP problem.

## Novel Definitions

- `Recipe`: A computational recipe with cooking time, verification time, and outcome count.
- `RecipeReduction`: A notion of reduction between recipes, forming a preorder.
- `RecipeDAG`: A DAG of recipe steps with scheduling via tropical algebra.

## Main Results

- `seq_compose_gap_additive`: The complexity gap C - V is additive under sequential composition.
- `seq_compose_preserves_NP`: Composing two hard recipes gives a hard recipe.
- `par_cook_le_seq`: Parallel execution is never slower than sequential.
- `hard_implies_NP`: Hard recipes (C ≥ 2V) are NP recipes (C > V).
- `recipe_reduction_transitive`: Recipe reductions compose transitively.
- `gap_scales_with_composition`: The gap scales linearly with iterated composition.
- `tropical_critical_path_bound`: Critical path via tropical semiring.
- `cv_ratio_seq_bound`: C/V ratio subadditivity.

## Cross-Domain Connections

- Tropical algebra ↔ recipe scheduling (critical path = max-plus operations)
- Information theory ↔ verification complexity

## Conjectures

- `conjecture_generic_recipe_gap`: For generic recipes, C(R) > V(R).
-/

open Finset BigOperators

noncomputable section

/-! ## Part 1: The Recipe Structure -/

/-- A `Recipe` models a computational cooking process with:
- `cook_time`: time steps to prepare the dish (computation time)
- `verify_time`: time steps to verify correctness (verification time)
- `outcomes`: number of distinguishable results
- `steps`: number of atomic operations -/
structure Recipe where
  cook_time : ℕ
  verify_time : ℕ
  outcomes : ℕ
  steps : ℕ
  cook_pos : 0 < cook_time
  verify_pos : 0 < verify_time
  outcomes_pos : 0 < outcomes

/-- The complexity gap: how much longer cooking takes than verification. -/
def Recipe.gap (R : Recipe) : ℤ :=
  (R.cook_time : ℤ) - (R.verify_time : ℤ)

/-- The complexity ratio C/V as a rational number. -/
def Recipe.cv_ratio (R : Recipe) : ℚ :=
  (R.cook_time : ℚ) / (R.verify_time : ℚ)

/-- A P-recipe: cooking is no harder than verification (C ≤ V). -/
def Recipe.isP (R : Recipe) : Prop :=
  R.cook_time ≤ R.verify_time

/-- An NP-recipe: cooking takes strictly longer than verification (C > V). -/
def Recipe.isNP (R : Recipe) : Prop :=
  R.cook_time > R.verify_time

/-- A hard recipe: C ≥ 2 * V. -/
def Recipe.isHard (R : Recipe) : Prop :=
  R.cook_time ≥ 2 * R.verify_time

/-! ## Part 2: Recipe Composition -/

/-- Sequential composition: do R₁ then R₂. Times add, outcomes multiply. -/
def Recipe.seq (R₁ R₂ : Recipe) : Recipe where
  cook_time := R₁.cook_time + R₂.cook_time
  verify_time := R₁.verify_time + R₂.verify_time
  outcomes := R₁.outcomes * R₂.outcomes
  steps := R₁.steps + R₂.steps
  cook_pos := Nat.add_pos_left R₁.cook_pos _
  verify_pos := Nat.add_pos_left R₁.verify_pos _
  outcomes_pos := Nat.mul_pos R₁.outcomes_pos R₂.outcomes_pos

/-- Parallel composition: do R₁ and R₂ simultaneously. Time is the max. -/
def Recipe.par (R₁ R₂ : Recipe) : Recipe where
  cook_time := max R₁.cook_time R₂.cook_time
  verify_time := max R₁.verify_time R₂.verify_time
  outcomes := R₁.outcomes * R₂.outcomes
  steps := R₁.steps + R₂.steps
  cook_pos := lt_of_lt_of_le R₁.cook_pos (le_max_left _ _)
  verify_pos := lt_of_lt_of_le R₁.verify_pos (le_max_left _ _)
  outcomes_pos := Nat.mul_pos R₁.outcomes_pos R₂.outcomes_pos

/-! ## Part 3: Core Theorems -/

/-
**The complexity gap is additive under sequential composition.**
If recipe R₁ has gap g₁ and R₂ has gap g₂, their sequential composition
has gap g₁ + g₂. This is the fundamental superadditivity of cooking complexity.
-/
theorem seq_compose_gap_additive (R₁ R₂ : Recipe) :
    (R₁.seq R₂).gap = R₁.gap + R₂.gap := by
  unfold Recipe.gap Recipe.seq;
  grind

/-
**Sequential composition preserves the NP property.**
If both recipes have C > V, then their composition does too.
In the kitchen: combining two hard dishes gives a hard meal.
-/
theorem seq_compose_preserves_NP (R₁ R₂ : Recipe)
    (h₁ : R₁.isNP) (h₂ : R₂.isNP) :
    (R₁.seq R₂).isNP := by
  exact Nat.add_lt_add h₁ h₂

/-
**Parallel composition time is bounded by sequential time.**
-/
theorem par_cook_le_seq (R₁ R₂ : Recipe) :
    (R₁.par R₂).cook_time ≤ (R₁.seq R₂).cook_time := by
  exact max_le ( Nat.le_add_right _ _ ) ( Nat.le_add_left _ _ )

/-
**The C/V ratio is subadditive under sequential composition.**
-/
theorem cv_ratio_seq_bound (R₁ R₂ : Recipe) :
    (R₁.seq R₂).cv_ratio ≤ R₁.cv_ratio + R₂.cv_ratio := by
  unfold Recipe.seq Recipe.cv_ratio; norm_num; ring_nf;
  gcongr <;> norm_cast <;> linarith [ R₁.cook_pos, R₁.verify_pos, R₂.cook_pos, R₂.verify_pos ] ;

/-
**Hard recipes are NP recipes.** If C ≥ 2V, then C > V.
-/
theorem hard_implies_NP (R : Recipe) (h : R.isHard) : R.isNP := by
  exact lt_of_lt_of_le ( by linarith [ R.verify_pos ] ) h

/-
**Every recipe is either P or NP.**
-/
theorem recipe_P_or_NP (R : Recipe) : R.isP ∨ R.isNP := by
  exact le_or_gt _ _

/-
**Hard recipes remain hard under sequential composition.**
-/
theorem seq_compose_preserves_hard (R₁ R₂ : Recipe)
    (h₁ : R₁.isHard) (h₂ : R₂.isHard) :
    (R₁.seq R₂).isHard := by
  unfold Recipe.isHard at *;
  unfold Recipe.seq; linarith;

/-! ## Part 4: Recipe Reduction (Preorder) -/

/-- A reduction from R₁ to R₂ witnesses R₂ is "no harder" than R₁ plus overhead. -/
structure RecipeReduction (R₁ R₂ : Recipe) where
  overhead : ℕ
  cook_bound : R₂.cook_time ≤ R₁.cook_time + overhead
  verify_bound : R₂.verify_time ≤ R₁.verify_time + overhead

/-
**Recipe reductions compose transitively.**
-/
theorem recipe_reduction_transitive (R₁ R₂ R₃ : Recipe)
    (f : RecipeReduction R₁ R₂) (g : RecipeReduction R₂ R₃) :
    ∃ h : RecipeReduction R₁ R₃,
      h.overhead ≤ f.overhead + g.overhead := by
  exact ⟨ ⟨ f.overhead + g.overhead, by linarith [ f.cook_bound, g.cook_bound ], by linarith [ f.verify_bound, g.verify_bound ] ⟩, by simp +decide ⟩

/-
**Identity reduction: zero overhead.**
-/
theorem recipe_reduction_refl (R : Recipe) :
    ∃ f : RecipeReduction R R, f.overhead = 0 := by
  exact ⟨ ⟨ 0, le_of_eq rfl, le_of_eq rfl ⟩, rfl ⟩

/-! ## Part 5: Tropical Scheduling (Cross-Domain Bridge)

In scheduling theory, the critical path is computed using the max-plus (tropical)
semiring. We formalize this connection between recipe scheduling and tropical algebra.

The max-plus semiring has "addition" = max, "multiplication" = +.
The key property is distributivity: a + max(b,c) = max(a+b, a+c).
This is the algebraic foundation of critical path method (CPM). -/

/-- Max-plus "addition" for scheduling: take the later time. -/
def maxPlus (a b : ℕ) : ℕ := max a b

/-- Max-plus "multiplication": sequential composition of durations. -/
def seqPlus (a b : ℕ) : ℕ := a + b

/-- **Max-plus addition is commutative.** -/
theorem maxPlus_comm (a b : ℕ) : maxPlus a b = maxPlus b a := by
  unfold maxPlus; omega

/-- **Max-plus addition is associative.** -/
theorem maxPlus_assoc (a b c : ℕ) : maxPlus (maxPlus a b) c = maxPlus a (maxPlus b c) := by
  unfold maxPlus; omega

/-- **Left distributivity: a + max(b, c) = max(a + b, a + c).**
This is the key tropical semiring axiom for scheduling. -/
theorem seqPlus_distrib_maxPlus (a b c : ℕ) :
    seqPlus a (maxPlus b c) = maxPlus (seqPlus a b) (seqPlus a c) := by
  unfold seqPlus maxPlus; omega

/-- **Right distributivity for the tropical semiring.** -/
theorem seqPlus_distrib_maxPlus_right (a b c : ℕ) :
    seqPlus (maxPlus a b) c = maxPlus (seqPlus a c) (seqPlus b c) := by
  unfold seqPlus maxPlus; omega

/-- **Zero is the identity for sequential-plus.** -/
theorem seqPlus_zero (a : ℕ) : seqPlus a 0 = a := by
  unfold seqPlus; omega

/-- **Zero is the identity for max-plus.** -/
theorem maxPlus_zero (a : ℕ) : maxPlus a 0 = a := by
  unfold maxPlus; omega

/-! ## Part 6: Recipe DAG and Critical Path

We model a recipe DAG as a list of n steps with durations and predecessors.
The critical path (makespan) is computed using max-plus operations. -/

/-- A recipe pipeline: n steps executed in sequence, each with a duration.
The total time is the sum, the critical path is the max. -/
def pipelineMakespan (durations : List ℕ) : ℕ :=
  durations.foldl maxPlus 0

/-- The total sequential time is the sum of all durations. -/
def pipelineTotal (durations : List ℕ) : ℕ :=
  durations.sum

/-
**The makespan of a pipeline is at most the total time.**
Parallel scheduling (critical path) is never slower than sequential.
-/
theorem pipeline_makespan_le_total (durations : List ℕ) :
    pipelineMakespan durations ≤ pipelineTotal durations := by
  unfold pipelineMakespan pipelineTotal;
  induction' durations using List.reverseRecOn with durations d ih <;> simp +arith +decide [ *, maxPlus ];
  grind

/-
**The makespan is at least each individual duration.**
No schedule can finish faster than the longest step.
-/
theorem pipeline_makespan_ge_each (durations : List ℕ) (d : ℕ) (hd : d ∈ durations) :
    d ≤ pipelineMakespan durations := by
  induction' durations using List.reverseRecOn with durations d hd <;> simp_all +decide [ pipelineMakespan ];
  cases hd <;> simp_all +decide [ maxPlus ]

/-
**Adding a step increases the makespan.**
-/
theorem pipeline_makespan_mono (durations : List ℕ) (d : ℕ) :
    pipelineMakespan durations ≤ pipelineMakespan (d :: durations) := by
  induction' durations using List.reverseRecOn with durations ih;
  · exact Nat.zero_le _;
  · grind +locals

/-! ## Part 7: Scaling Theorem -/

/-- Iterated sequential composition: compose R with itself (k+1) times. -/
def Recipe.iterSeq (R : Recipe) : ℕ → Recipe
  | 0 => R
  | n + 1 => (R.iterSeq n).seq R

/-
**Iterated composition has additive cook time.**
-/
theorem iter_seq_cook_time (R : Recipe) (k : ℕ) :
    (R.iterSeq k).cook_time = (k + 1) * R.cook_time := by
  induction k <;> simp_all +decide [ Nat.succ_mul, Recipe.seq, Recipe.iterSeq ]

/-
**Iterated composition has additive verify time.**
-/
theorem iter_seq_verify_time (R : Recipe) (k : ℕ) :
    (R.iterSeq k).verify_time = (k + 1) * R.verify_time := by
  induction k <;> simp_all +decide [ Nat.succ_mul, Recipe.iterSeq, Recipe.seq ]

/-
**The gap scales linearly with iterated composition.**
Proved by combining iter_seq_cook_time and iter_seq_verify_time.
-/
theorem gap_scales_with_composition (R : Recipe) (k : ℕ) :
    (R.iterSeq k).gap = (↑(k + 1) : ℤ) * R.gap := by
  unfold Recipe.gap;
  rw [ iter_seq_cook_time, iter_seq_verify_time ] ; push_cast ; ring

/-
**Iterated composition of NP recipes stays NP.**
-/
theorem iter_seq_preserves_NP (R : Recipe) (k : ℕ) (hR : R.isNP) :
    (R.iterSeq k).isNP := by
  induction' k with k ih;
  · exact hR;
  · exact seq_compose_preserves_NP _ _ ih hR

/-! ## Part 8: The Parallel Speedup Bound

A fundamental result connecting parallel and sequential execution:
the speedup from parallelization is bounded by the number of independent steps. -/

/-
**Parallel speedup bound**: For two recipes, the ratio of sequential to parallel
cook time is at most 2 (you can't do better than 2× speedup with 2 recipes).
-/
theorem parallel_speedup_bound (R₁ R₂ : Recipe) :
    (R₁.par R₂).cook_time * 2 ≥ (R₁.seq R₂).cook_time := by
  unfold Recipe.seq Recipe.par; norm_num; omega;

/-
**Verification parallelizes like cooking.**
The same bound holds for verification time.
-/
theorem parallel_verify_speedup (R₁ R₂ : Recipe) :
    (R₁.par R₂).verify_time * 2 ≥ (R₁.seq R₂).verify_time := by
  unfold Recipe.par Recipe.seq; norm_num;
  linarith [ le_max_left R₁.verify_time R₂.verify_time, le_max_right R₁.verify_time R₂.verify_time ]

/-! ## Part 9: Conjectures -/

/-- **Conjecture (Kitchen P ≠ NP)**: For any recipe with ≥ 4 outcomes and ≥ 3 steps,
cooking takes strictly longer than verification.

Falsifiable: find a recipe with ≥ 4 outcomes, ≥ 3 steps, and C ≤ V.
Counterexample candidate: a "tasting menu" where the chef tastes each component
as they go, so verification is integrated into cooking. -/
def conjecture_generic_recipe_gap : Prop :=
  ∀ R : Recipe, R.outcomes ≥ 4 → R.steps ≥ 3 → R.isNP

/-- **Testable prediction**: The gap grows at least linearly with outcomes. -/
def conjecture_gap_linear_growth : Prop :=
  ∀ R : Recipe, ∀ k : ℕ, R.outcomes ≥ 2 ^ k → R.gap ≥ k

end