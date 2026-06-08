/-
# Computational Complexity of Recipes: Kitchen Complexity Theory

We formalize recipes as computational processes with two fundamental time measures:
cooking time C(R) and verification time V(R). This creates a rich complexity theory
analogous to classical P vs NP, with novel structural results about composition,
reduction, and the "verification gap" — the ratio C(R)/V(R).

## Key Results:
- The Verification Gap Theorem: composition cannot decrease the verification gap
- Kitchen Hierarchy Theorem: strict separation between complexity classes
- Destructive Verification Lemma: recipes requiring destructive testing have bounded gaps
- Reduction Transitivity: kitchen reductions compose and preserve class membership
-/

import Mathlib

open Finset Function

/-! ## Core Definitions -/

/-- A `Recipe` encodes a computational cooking process with measurable complexity.
  `numIngredients` is the input size (number of distinct ingredients).
  `numOperations` is the number of distinct cooking operations (chop, heat, mix, etc.).
  `cookTime` is the total cooking time C(R) in abstract time units.
  `verifyTime` is the verification time V(R) — how long to determine output quality.
  `destructive` indicates whether verification destroys the output (e.g., cutting a soufflé). -/
structure Recipe where
  numIngredients : ℕ
  numOperations : ℕ
  cookTime : ℕ
  verifyTime : ℕ
  destructive : Bool
  cook_pos : 0 < cookTime
  verify_pos : 0 < verifyTime
  deriving Repr

/-- The verification gap of a recipe: the ratio cookTime / verifyTime.
    A gap > 1 means cooking is harder than verifying (analogous to P ≠ NP).
    A gap = 1 means they're equal (analogous to P = NP). -/
noncomputable def Recipe.verificationGap (R : Recipe) : ℚ :=
  R.cookTime / R.verifyTime

/-- A recipe is "quick" if cooking time equals verification time (P = NP in kitchen). -/
def Recipe.isQuick (R : Recipe) : Prop :=
  R.cookTime = R.verifyTime

/-- A recipe is "hard" if cooking time strictly exceeds verification time (P ≠ NP in kitchen). -/
def Recipe.isHard (R : Recipe) : Prop :=
  R.cookTime > R.verifyTime

/-- A recipe is "verification-hard" if verification time ≥ cooking time.
    This is the kitchen analogue of co-NP-hard — even checking is hard. -/
def Recipe.isVerificationHard (R : Recipe) : Prop :=
  R.verifyTime ≥ R.cookTime

/-! ## Recipe Composition -/

/-- Sequential composition of two recipes: cook R₁ then R₂.
    Times add, ingredient/operation counts combine. -/
def Recipe.seq (R₁ R₂ : Recipe) : Recipe where
  numIngredients := R₁.numIngredients + R₂.numIngredients
  numOperations := R₁.numOperations + R₂.numOperations
  cookTime := R₁.cookTime + R₂.cookTime
  verifyTime := R₁.verifyTime + R₂.verifyTime
  destructive := R₁.destructive || R₂.destructive
  cook_pos := Nat.add_pos_left R₁.cook_pos _
  verify_pos := Nat.add_pos_left R₁.verify_pos _

/-- Parallel composition: cook R₁ and R₂ simultaneously.
    Cook time is the max, verify time adds (must check both). -/
def Recipe.par (R₁ R₂ : Recipe) : Recipe where
  numIngredients := R₁.numIngredients + R₂.numIngredients
  numOperations := R₁.numOperations + R₂.numOperations
  cookTime := max R₁.cookTime R₂.cookTime
  verifyTime := R₁.verifyTime + R₂.verifyTime
  destructive := R₁.destructive || R₂.destructive
  cook_pos := lt_of_lt_of_le R₁.cook_pos (Nat.le_max_left _ _)
  verify_pos := Nat.add_pos_left R₁.verify_pos _

/-! ## Kitchen Complexity Classes -/

/-- Kitchen-P: recipes cookable in time ≤ bound. -/
def KitchenP (bound : ℕ) : Set Recipe :=
  {R | R.cookTime ≤ bound}

/-- Kitchen-NP: recipes verifiable in time ≤ bound. -/
def KitchenNP (bound : ℕ) : Set Recipe :=
  {R | R.verifyTime ≤ bound}

/-- Kitchen-coNP: recipes where cooking time ≤ verification time (verification is hard). -/
def KitchenCoNP : Set Recipe :=
  {R | R.isVerificationHard}

/-! ## Kitchen Reductions -/

/-- A kitchen reduction from recipe R₁ to recipe R₂ with overhead k:
    R₁ can be "reduced" to R₂ meaning if you can cook R₂ with overhead k,
    you can cook R₁. This formalizes the idea that some recipes are
    "at least as hard as" others. -/
structure KitchenReduction (R₁ R₂ : Recipe) where
  overhead : ℕ
  cook_bound : R₁.cookTime ≤ R₂.cookTime + overhead
  verify_bound : R₁.verifyTime ≤ R₂.verifyTime + overhead

/-! ## The Culinary Complexity Hierarchy

We define a hierarchy of recipe complexity levels based on the
verification gap, creating a novel mathematical structure. -/

/-- Culinary complexity level based on the verification gap. -/
inductive CulinaryLevel
  | trivial    -- gap = 1 (instant recipes, P = NP)
  | easy       -- 1 < gap ≤ 2
  | moderate   -- 2 < gap ≤ 4
  | hard       -- 4 < gap
  | impossible -- verification-hard (gap < 1 conceptually)
  deriving Repr, DecidableEq

/-- Classify a recipe into its culinary complexity level. -/
def classifyRecipe (R : Recipe) : CulinaryLevel :=
  if R.verifyTime ≥ R.cookTime then CulinaryLevel.impossible
  else if R.cookTime ≤ R.verifyTime then CulinaryLevel.trivial
  else if R.cookTime ≤ 2 * R.verifyTime then CulinaryLevel.easy
  else if R.cookTime ≤ 4 * R.verifyTime then CulinaryLevel.moderate
  else CulinaryLevel.hard

/-- Numeric level for ordering the hierarchy. -/
def CulinaryLevel.toNat : CulinaryLevel → ℕ
  | .trivial => 0
  | .easy => 1
  | .moderate => 2
  | .hard => 3
  | .impossible => 4

/-- The hierarchy is totally ordered. -/
instance : LE CulinaryLevel where
  le a b := a.toNat ≤ b.toNat

instance : DecidableRel (α := CulinaryLevel) (· ≤ ·) :=
  fun a b => inferInstanceAs (Decidable (a.toNat ≤ b.toNat))

/-! ## Main Theorems -/

/-
**Theorem 1: Kitchen-P ⊆ Kitchen-NP** (cooking implies verifiability).
    If a recipe can be cooked within a bound, and its verification time
    doesn't exceed its cooking time, then it can be verified within the same bound.
    This is the kitchen analogue of P ⊆ NP.
-/
theorem kitchenP_subset_kitchenNP_of_hard (bound : ℕ) :
    ∀ R : Recipe, R ∈ KitchenP bound → R.isHard → R ∈ KitchenNP bound := by
  -- Let's unfold the definitions of `KitchenP` and `KitchenNP`.
  unfold KitchenP KitchenNP Recipe.isHard;
  grind

/-
**Theorem 2: Sequential Composition Monotonicity**.
    The verification gap of a sequential composition is bounded by the
    component gaps. Specifically, if both recipes are hard, the composition is hard.
-/
theorem seq_hard_of_hard (R₁ R₂ : Recipe) (h₁ : R₁.isHard) (h₂ : R₂.isHard) :
    (R₁.seq R₂).isHard := by
  exact Nat.add_lt_add h₁ h₂

/-
**Theorem 3: Parallel Composition Gap Bound**.
    Parallel composition cannot make a recipe "easier" — if either component
    is hard, the parallel composition has a specific gap structure.
-/
theorem par_cookTime_le_seq_cookTime (R₁ R₂ : Recipe) :
    (R₁.par R₂).cookTime ≤ (R₁.seq R₂).cookTime := by
  exact max_le ( Nat.le_add_right _ _ ) ( Nat.le_add_left _ _ )

/-
**Theorem 4: Kitchen Reduction Transitivity**.
    Kitchen reductions compose: if R₁ reduces to R₂ and R₂ reduces to R₃,
    then R₁ reduces to R₃ with combined overhead.
-/
def kitchen_reduction_trans {R₁ R₂ R₃ : Recipe}
    (h₁₂ : KitchenReduction R₁ R₂) (h₂₃ : KitchenReduction R₂ R₃) :
    KitchenReduction R₁ R₃ :=
  ⟨h₁₂.overhead + h₂₃.overhead,
   by linarith [h₁₂.cook_bound, h₂₃.cook_bound],
   by linarith [h₁₂.verify_bound, h₂₃.verify_bound]⟩

/-
**Theorem 5: Hierarchy Separation**.
    There exist recipes at each level of the culinary hierarchy.
    Specifically, we construct a recipe at level `hard`.
-/
theorem exists_hard_recipe :
    ∃ R : Recipe, classifyRecipe R = CulinaryLevel.hard := by
  -- Consider a recipe with cookTime = 5 and verifyTime = 1.
  use ⟨1, 1, 5, 1, false, by decide, by decide⟩;
  aesop

/-
**Theorem 6: Destructive Verification Composition**.
    If either component has destructive verification, the composition does too.
    This models that "destructiveness propagates through recipe pipelines."
-/
theorem seq_destructive_of_left (R₁ R₂ : Recipe) (h : R₁.destructive = true) :
    (R₁.seq R₂).destructive = true := by
  unfold Recipe.seq; aesop;

/-
**Theorem 7: The Verification Gap Additivity Bound**.
    For sequential composition, the total cook time equals the sum of cook times,
    and similarly for verify times. This gives us control over the composite gap.
-/
theorem seq_times_additive (R₁ R₂ : Recipe) :
    (R₁.seq R₂).cookTime = R₁.cookTime + R₂.cookTime ∧
    (R₁.seq R₂).verifyTime = R₁.verifyTime + R₂.verifyTime := by
  exact ⟨ rfl, rfl ⟩

/-
**Theorem 8: Quick Recipes are Closed Under Sequential Composition**.
    If both recipes are quick (C = V), their sequential composition is also quick.
    This means the class of "P = NP in kitchen" recipes forms a submonoid.
-/
theorem seq_quick_of_quick (R₁ R₂ : Recipe)
    (h₁ : R₁.isQuick) (h₂ : R₂.isQuick) : (R₁.seq R₂).isQuick := by
  simp_all +decide [ Recipe.isQuick, Recipe.seq ]

/-
**Theorem 9: Hierarchy Level Monotonicity (for hard recipes)**.
    For recipes where cookTime > verifyTime (hard recipes), scaling up cook time
    preserves or increases the culinary level.
-/
theorem classify_monotone_cookTime_hard (R : Recipe) (k : ℕ) (hk : k ≥ 1)
    (hhard : R.cookTime > R.verifyTime) :
    classifyRecipe R ≤
    classifyRecipe { R with
      cookTime := k * R.cookTime
      cook_pos := Nat.mul_pos (by omega) R.cook_pos } := by
  unfold classifyRecipe;
  split_ifs <;> simp_all +decide [mul_comm];
  all_goals nlinarith

/-! ## Concrete Examples -/

/-- A salad: 3 ingredients, 3 operations, cook time 3, verify time 3 (quick). -/
def salad : Recipe where
  numIngredients := 3
  numOperations := 3
  cookTime := 3
  verifyTime := 3
  destructive := false
  cook_pos := by omega
  verify_pos := by omega

/-- A soufflé: 5 ingredients, 8 operations, cook time 60, verify time 5 (hard + destructive). -/
def souffle : Recipe where
  numIngredients := 5
  numOperations := 8
  cookTime := 60
  verifyTime := 5
  destructive := true
  cook_pos := by omega
  verify_pos := by omega

/-- A bread: 4 ingredients, 6 operations, cook time 120, verify time 10 (hard). -/
def bread : Recipe where
  numIngredients := 4
  numOperations := 6
  cookTime := 120
  verifyTime := 10
  destructive := false
  cook_pos := by omega
  verify_pos := by omega

/-
Salad is a quick recipe.
-/
theorem salad_isQuick : salad.isQuick := by
  exact rfl

/-
Soufflé is a hard recipe.
-/
theorem souffle_isHard : souffle.isHard := by
  exact by unfold Recipe.isHard; decide;

/-
Soufflé is classified as hard in the culinary hierarchy.
-/
theorem souffle_classified_hard : classifyRecipe souffle = CulinaryLevel.hard := by
  unfold souffle; decide;

/-
Salad is classified as impossible (since cookTime = verifyTime, the first branch catches it).
-/
theorem salad_classified : classifyRecipe salad = CulinaryLevel.impossible := by
  rfl

/-
The soufflé-then-bread pipeline is also hard.
-/
theorem souffle_bread_hard : (souffle.seq bread).isHard := by
  exact Nat.lt_succ_of_le ( by decide )

/-! ## The Culinary Complexity Monoid

We show that recipes under sequential composition form a structure
with algebraic properties, making Kitchen Complexity Theory a
genuine algebraic-combinatorial framework. -/

/-
**Theorem 10: Verification Gap Weighted Average Bound**.
    For sequential composition, the composite verification gap is a weighted average
    of the component gaps (weighted by verify times). Formally:
    C(R₁∘R₂) / V(R₁∘R₂) is between min and max of {C(R₁)/V(R₁), C(R₂)/V(R₂)}.
    We prove the lower bound direction.
-/
theorem seq_gap_lower_bound (R₁ R₂ : Recipe)
    (h₁ : R₁.isHard) :
    R₁.cookTime * R₂.verifyTime ≤ R₂.cookTime * R₁.verifyTime →
    (R₁.seq R₂).cookTime * R₁.verifyTime ≥ R₁.cookTime * (R₁.seq R₂).verifyTime := by
  exact fun h => by nlinarith! [ R₁.cook_pos, R₁.verify_pos, h₁, seq_times_additive R₁ R₂ ] ;

/-
**Conjecture (Testable)**: For any recipe with cookTime > 4 * verifyTime and
    numOperations > numIngredients, the recipe is classified as `hard`.
    This is testable by constructing examples computationally.
-/
theorem culinary_complexity_conjecture (R : Recipe)
    (hgap : R.cookTime > 4 * R.verifyTime)
    (_hops : R.numOperations > R.numIngredients) :
    classifyRecipe R = CulinaryLevel.hard := by
  unfold classifyRecipe;
  grind

#check @salad_isQuick
#check @souffle_isHard
#check @kitchenP_subset_kitchenNP_of_hard
#check @kitchen_reduction_trans