import Mathlib

/-!
# The P vs NP of Cooking: A Complexity Theory of Recipes

This file develops a small, self-contained algebraic theory formalizing the metaphor
"every recipe is an algorithm".  A recipe `R` is modelled by two natural numbers:

* `R.cook`   — the *cooking time* `C(R)` (time to prepare the dish), and
* `R.verify` — the *verification time* `V(R)` (time to taste and judge the dish).

We classify recipes exactly as one classifies decision problems by the relationship
between solving and verifying:

* **Quick** (`P = NP` in the kitchen): `C(R) = V(R)` — assemble-and-serve dishes.
* **Traditional** (`P ≠ NP` in the kitchen): `V(R) < C(R)` — cooking beats tasting.
* **Overhard** (`NP`-hard in the kitchen): `C(R) < V(R)` — verifying is *harder*
  than cooking (e.g. the soufflé: you can only check it by destroying it).

Recipes compose *sequentially* (`seq`, cook one dish after another), giving a
commutative monoid.  Cooking time, verification time and *speedup* `C - V` are all
additive.  The development culminates in the **Batch Quickness Theorem**: a menu of
*physical* recipes (`V ≤ C`) is globally quick iff every dish on it is quick — a
kitchen analogue of the fact that a sum of non-negative slacks vanishes iff each
slack vanishes.

Every theorem below is used by a later one, forming a single chain from the trichotomy
of recipe classes up to the batch and rational-ratio characterizations.
-/

namespace RecipeComplexity

/-- A recipe, modelled by its cooking time `C(R)` and verification time `V(R)`. -/
structure Recipe where
  /-- Cooking time `C(R)`: how long it takes to prepare the dish. -/
  cook : ℕ
  /-- Verification time `V(R)`: how long it takes to taste and judge the dish. -/
  verify : ℕ
deriving DecidableEq

/-- Two recipes are equal exactly when their cooking and verification times agree. -/
@[ext] theorem Recipe.ext' {R S : Recipe} (hc : R.cook = S.cook) (hv : R.verify = S.verify) :
    R = S := by
  cases R; cases S; simp_all

/-! ## Classification of recipes (`P = NP`, `P ≠ NP`, and `NP`-hard) -/

/-- A **quick** recipe: cooking time equals verification time (`P = NP` in the kitchen). -/
def IsQuick (R : Recipe) : Prop := R.cook = R.verify

/-- A **traditional** recipe: verifying is strictly faster than cooking (`P ≠ NP`). -/
def IsTraditional (R : Recipe) : Prop := R.verify < R.cook

/-- An **overhard** recipe: verifying is strictly *harder* than cooking (`NP`-hard). -/
def IsOverhard (R : Recipe) : Prop := R.cook < R.verify

/-- A **physical** recipe: you can always verify at most as slowly as you cook. -/
def IsPhysical (R : Recipe) : Prop := R.verify ≤ R.cook

/-- **Trichotomy of recipes.** Every recipe is exactly one of quick, traditional, or
overhard.  This is the culinary shadow of the trichotomy `C = V`, `V < C`, `C < V`. -/
theorem recipe_trichotomy (R : Recipe) :
    (IsQuick R ∧ ¬ IsTraditional R ∧ ¬ IsOverhard R) ∨
    (¬ IsQuick R ∧ IsTraditional R ∧ ¬ IsOverhard R) ∨
    (¬ IsQuick R ∧ ¬ IsTraditional R ∧ IsOverhard R) := by
  unfold IsQuick IsTraditional IsOverhard
  omega

/-- A recipe is physical iff it is not overhard: physicality rules out the `NP`-hard
regime, using the trichotomy. -/
theorem isPhysical_iff_not_overhard (R : Recipe) : IsPhysical R ↔ ¬ IsOverhard R := by
  unfold IsPhysical IsOverhard; omega

/-- A physical recipe is either quick or traditional (never overhard). -/
theorem IsPhysical.quick_or_traditional {R : Recipe} (h : IsPhysical R) :
    IsQuick R ∨ IsTraditional R := by
  unfold IsPhysical at h; unfold IsQuick IsTraditional; omega

/-- Quick recipes are physical. -/
theorem IsQuick.isPhysical {R : Recipe} (h : IsQuick R) : IsPhysical R := by
  unfold IsQuick at h; unfold IsPhysical; omega

/-- Traditional recipes are physical. -/
theorem IsTraditional.isPhysical {R : Recipe} (h : IsTraditional R) : IsPhysical R := by
  unfold IsTraditional at h; unfold IsPhysical; omega

/-! ## Sequential composition of recipes forms a commutative monoid -/

/-- Cook one recipe, then the other: cooking and verification times both add. -/
def seq (R S : Recipe) : Recipe := ⟨R.cook + S.cook, R.verify + S.verify⟩

/-- The empty recipe (cook nothing, verify nothing): the identity for `seq`. -/
def empty : Recipe := ⟨0, 0⟩

@[simp] theorem seq_cook (R S : Recipe) : (seq R S).cook = R.cook + S.cook := rfl
@[simp] theorem seq_verify (R S : Recipe) : (seq R S).verify = R.verify + S.verify := rfl
@[simp] theorem empty_cook : empty.cook = 0 := rfl
@[simp] theorem empty_verify : empty.verify = 0 := rfl

/-- `seq` is associative. -/
theorem seq_assoc (R S T : Recipe) : seq (seq R S) T = seq R (seq S T) := by
  ext <;> simp [Nat.add_assoc]

/-- `seq` is commutative: the order of two independent dishes is immaterial for the
total cooking and verification budgets. -/
theorem seq_comm (R S : Recipe) : seq R S = seq S R := by
  ext <;> simp [Nat.add_comm]

/-- The empty recipe is a left identity for `seq`. -/
theorem empty_seq (R : Recipe) : seq empty R = R := by ext <;> simp

/-- The empty recipe is a right identity for `seq`. -/
theorem seq_empty (R : Recipe) : seq R empty = R := by ext <;> simp

/-- Recipes under sequential composition form a commutative monoid.  (This packages the
associativity, identity and commutativity lemmas above.) -/
instance : CommMonoid Recipe where
  mul := seq
  one := empty
  mul_assoc := seq_assoc
  one_mul := empty_seq
  mul_one := seq_empty
  mul_comm := seq_comm

/-! ## Closure of the recipe classes under composition -/

/-- The sequential composition of two quick recipes is quick: `P = NP` recipes are
closed under composition. -/
theorem IsQuick.seq {R S : Recipe} (hR : IsQuick R) (hS : IsQuick S) : IsQuick (seq R S) := by
  unfold IsQuick at *; simp [hR, hS]

/-- Composing a traditional recipe with a physical recipe stays traditional: a genuine
kitchen slowdown cannot be undone by a well-behaved companion dish. -/
theorem IsTraditional.seq_physical {R S : Recipe} (hR : IsTraditional R) (hS : IsPhysical S) :
    IsTraditional (seq R S) := by
  unfold IsTraditional at *; unfold IsPhysical at hS; simp; omega

/-- The sequential composition of two physical recipes is physical. -/
theorem IsPhysical.seq {R S : Recipe} (hR : IsPhysical R) (hS : IsPhysical S) :
    IsPhysical (seq R S) := by
  unfold IsPhysical at *; simp; omega

/-! ## Speedup: the additive slack `C - V` -/

/-- The **speedup** of a recipe: how much faster tasting is than cooking, `C(R) - V(R)`
(truncated subtraction on `ℕ`). -/
def speedup (R : Recipe) : ℕ := R.cook - R.verify

/-- A recipe is quick iff it is physical with zero speedup. -/
theorem isQuick_iff_physical_speedup_zero (R : Recipe) :
    IsQuick R ↔ IsPhysical R ∧ speedup R = 0 := by
  unfold IsQuick IsPhysical speedup; omega

/-- **Speedup is additive over physical recipes.**  The slack of a two-course meal is
the sum of the individual slacks (this needs physicality so that no truncation occurs). -/
theorem speedup_seq {R S : Recipe} (hR : IsPhysical R) (hS : IsPhysical S) :
    speedup (seq R S) = speedup R + speedup S := by
  unfold speedup IsPhysical at *; simp; omega

/-! ## Repeating a recipe (cooking many servings) -/

/-- Cook `n` copies of a recipe in sequence. -/
def repeatRecipe : ℕ → Recipe → Recipe
  | 0,     _ => empty
  | n + 1, R => seq R (repeatRecipe n R)

@[simp] theorem repeatRecipe_zero (R : Recipe) : repeatRecipe 0 R = empty := rfl
@[simp] theorem repeatRecipe_succ (n : ℕ) (R : Recipe) :
    repeatRecipe (n + 1) R = seq R (repeatRecipe n R) := rfl

/-- Cooking `n` servings takes `n` times the cooking time of one serving. -/
theorem repeatRecipe_cook (n : ℕ) (R : Recipe) : (repeatRecipe n R).cook = n * R.cook := by
  induction n with
  | zero => simp
  | succ k ih => simp [ih]; ring

/-- Verifying `n` servings takes `n` times the verification time of one serving. -/
theorem repeatRecipe_verify (n : ℕ) (R : Recipe) :
    (repeatRecipe n R).verify = n * R.verify := by
  induction n with
  | zero => simp
  | succ k ih => simp [ih]; ring

/-- Repeating a quick recipe stays quick (uses `repeatRecipe_cook`/`repeatRecipe_verify`). -/
theorem IsQuick.repeatRecipe {R : Recipe} (h : IsQuick R) (n : ℕ) :
    IsQuick (repeatRecipe n R) := by
  unfold IsQuick at *
  rw [repeatRecipe_cook, repeatRecipe_verify, h]

/-- Repeating a traditional recipe a positive number of times stays traditional. -/
theorem IsTraditional.repeatRecipe {R : Recipe} (h : IsTraditional R) {n : ℕ} (hn : 0 < n) :
    IsTraditional (repeatRecipe n R) := by
  unfold IsTraditional at *
  rw [repeatRecipe_cook, repeatRecipe_verify]
  exact (Nat.mul_lt_mul_left hn).mpr h

/-! ## Batches (menus): folding a whole list of recipes -/

/-- The **batch** recipe of a menu: cook every recipe in the list, one after another. -/
def batch (L : List Recipe) : Recipe := L.foldr seq empty

@[simp] theorem batch_nil : batch [] = empty := rfl
@[simp] theorem batch_cons (R : Recipe) (L : List Recipe) :
    batch (R :: L) = seq R (batch L) := rfl

/-- The total cooking time of a batch is the sum of the individual cooking times. -/
theorem batch_cook (L : List Recipe) : (batch L).cook = (L.map Recipe.cook).sum := by
  induction L with
  | nil => simp
  | cons R L ih => simp [ih]

/-- The total verification time of a batch is the sum of the individual verification times. -/
theorem batch_verify (L : List Recipe) : (batch L).verify = (L.map Recipe.verify).sum := by
  induction L with
  | nil => simp
  | cons R L ih => simp [ih]

/-- A batch of physical recipes is physical (uses `IsPhysical.seq`). -/
theorem batch_physical {L : List Recipe} (h : ∀ R ∈ L, IsPhysical R) : IsPhysical (batch L) := by
  induction L with
  | nil => simp [batch]; unfold IsPhysical; simp
  | cons R L ih =>
      rw [batch_cons]
      exact (h R (by simp)).seq (ih (fun S hS => h S (by simp [hS])))

/-- A batch of quick recipes is quick (uses `IsQuick.seq`). -/
theorem batch_quick_of_all {L : List Recipe} (h : ∀ R ∈ L, IsQuick R) : IsQuick (batch L) := by
  induction L with
  | nil => unfold IsQuick; simp [batch]
  | cons R L ih =>
      rw [batch_cons]
      exact (h R (by simp)).seq (ih (fun S hS => h S (by simp [hS])))

/-- **Batch Quickness Theorem (the capstone).**  A menu consisting entirely of
*physical* recipes is globally quick (`C = V` for the whole batch) **iff every single
dish on it is quick.**

The forward direction is the interesting one: it says the non-negative slacks
`C(Rᵢ) − V(Rᵢ)` cannot secretly cancel, because for physical recipes there is nothing
to cancel with — a globally break-even menu must be break-even course by course.  This
fails without the physicality hypothesis, where an overhard dish could be masked by an
extra-fast one. -/
theorem batch_quick_iff {L : List Recipe} (h : ∀ R ∈ L, IsPhysical R) :
    IsQuick (batch L) ↔ ∀ R ∈ L, IsQuick R := by
  constructor
  · intro hquick
    induction L with
    | nil => simp
    | cons R L ih =>
        rw [batch_cons] at hquick
        have hRphys : IsPhysical R := h R (by simp)
        have hLphys : ∀ S ∈ L, IsPhysical S := fun S hS => h S (by simp [hS])
        have hbatchLphys : IsPhysical (batch L) := batch_physical hLphys
        -- From C(R)+C(batch L) = V(R)+V(batch L) with both slacks ≥ 0, both slacks are 0.
        unfold IsQuick IsPhysical at *
        simp only [seq_cook, seq_verify] at hquick
        have hRq : R.cook = R.verify := by omega
        have hLq : (batch L).cook = (batch L).verify := by omega
        intro S hS
        rcases List.mem_cons.mp hS with rfl | hSL
        · exact hRq
        · exact ih hLphys hLq S hSL
  · intro hall
    exact batch_quick_of_all hall

/-! ## The cooking ratio `C(R) / V(R)` -/

/-- The **cooking ratio** `C(R) / V(R)` as a rational number. -/
noncomputable def ratio (R : Recipe) : ℚ := (R.cook : ℚ) / (R.verify : ℚ)

/-- A quick recipe with positive verification time has cooking ratio exactly `1`
(`C = V`): the "`P = NP`" recipes sit exactly on the diagonal. -/
theorem IsQuick.ratio_eq_one {R : Recipe} (h : IsQuick R) (hv : 0 < R.verify) :
    ratio R = 1 := by
  unfold IsQuick at h
  unfold ratio
  rw [h]
  have : (R.verify : ℚ) ≠ 0 := by exact_mod_cast hv.ne'
  field_simp

/-- A traditional recipe with positive verification time has cooking ratio strictly
greater than `1` (`C > V`): "`P ≠ NP`" recipes lie strictly above the diagonal. -/
theorem IsTraditional.ratio_gt_one {R : Recipe} (h : IsTraditional R) (hv : 0 < R.verify) :
    1 < ratio R := by
  unfold IsTraditional at h
  unfold ratio
  have hvq : (0 : ℚ) < (R.verify : ℚ) := by exact_mod_cast hv
  rw [lt_div_iff₀ hvq, one_mul]
  exact_mod_cast h

/-- An overhard recipe has cooking ratio strictly less than `1` (`C < V`): the
`NP`-hard dishes fall strictly below the diagonal.  Verification really is the
bottleneck. -/
theorem IsOverhard.ratio_lt_one {R : Recipe} (h : IsOverhard R) :
    ratio R < 1 := by
  unfold IsOverhard at h
  unfold ratio
  have hvq : (0 : ℚ) < (R.verify : ℚ) := by
    have : 0 < R.verify := lt_of_le_of_lt (Nat.zero_le _) h
    exact_mod_cast this
  rw [div_lt_iff₀ hvq, one_mul]
  exact_mod_cast h

/-! ## Worked examples: a salad, a stew and a soufflé -/

/-- A salad: chop and toss.  Tasting takes as long as assembling — a quick recipe. -/
def salad : Recipe := ⟨5, 5⟩

/-- A beef stew: hours of cooking, a moment to taste — a traditional recipe. -/
def stew : Recipe := ⟨180, 3⟩

/-- A soufflé: quick to combine, but you can only *verify* it has risen by cutting it
open, which is expensive — an overhard (`NP`-hard) recipe. -/
def souffle : Recipe := ⟨20, 45⟩

example : IsQuick salad := by unfold IsQuick salad; rfl
example : IsTraditional stew := by unfold IsTraditional stew; decide
example : IsOverhard souffle := by unfold IsOverhard souffle; decide

/-- The soufflé is *not* physical: no matter how cleverly you plan, tasting outpaces
cooking. -/
example : ¬ IsPhysical souffle := by
  rw [isPhysical_iff_not_overhard, not_not]
  unfold IsOverhard souffle; decide

/-- Three salads still make a quick recipe (via `IsQuick.repeatRecipe`). -/
example : IsQuick (repeatRecipe 3 salad) := (by unfold IsQuick salad; rfl : IsQuick salad).repeatRecipe 3

/-- A menu of a salad and a stew is traditional overall: the stew's overhead dominates
(via `IsTraditional.seq_physical`). -/
example : IsTraditional (batch [stew, salad]) := by
  rw [batch_cons, batch_cons, batch_nil, seq_empty]
  exact (by unfold IsTraditional stew; decide : IsTraditional stew).seq_physical
    (by unfold IsPhysical salad; decide)

end RecipeComplexity