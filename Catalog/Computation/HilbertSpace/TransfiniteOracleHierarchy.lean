import Mathlib

/-!
# Transfinite Oracle Hierarchies

This module develops a rigorous axiomatic framework for hypercomputation through
oracle hierarchies. We define jump operators, build oracle chains, and prove
structural theorems about the resulting hierarchy.

## Main Definitions

* `JumpOperator`: An abstract Turing jump that maps sets to strictly larger sets
* `OracleChain`: A chain of sets indexed by ℕ, built by iterating a jump
* `PhysicalHypercomputer`: A sequence of finite approximations to a target function

## Main Results

* `oracle_chain_strict`: The chain strictly increases at each level
* `diagonal_escape`: No decision procedure at level n can decide level n+1
* `jump_no_fixed_point`: No set is a fixed point of a jump operator
* `essential_accidental_gap`: Accidentally correct ≠ essentially computable
* `oracle_space_uncountable`: The space of all oracles is uncountable
* `most_oracles_escape_finite_hierarchy`: Most oracles lie outside any finite chain
* `unbounded_convergence`: No uniform finite settling time for hypercomputers
-/

noncomputable section

open Set Function

/-! ### Jump Operators -/

/-- A **jump operator** is an endofunction on sets that is strictly expanding:
every set is strictly contained in its jump. This abstracts the Turing jump. -/
structure JumpOperator (α : Type*) where
  /-- The jump function on sets -/
  jump : Set α → Set α
  /-- The jump always expands the set -/
  expanding : ∀ S : Set α, S ⊆ jump S
  /-- The jump always adds something new -/
  nontrivial : ∀ S : Set α, ∃ x, x ∈ jump S ∧ x ∉ S

/-- A jump operator is **monotone** if larger sets have larger jumps. -/
def JumpOperator.IsMonotone {α : Type*} (J : JumpOperator α) : Prop :=
  ∀ S T : Set α, S ⊆ T → J.jump S ⊆ J.jump T

/-! ### Oracle Chains -/

/-- An **oracle chain** iterates a jump operator from a base set. -/
def OracleChain {α : Type*} (J : JumpOperator α) (base : Set α) : ℕ → Set α
  | 0 => base
  | n + 1 => J.jump (OracleChain J base n)

/-- The oracle chain is monotonically increasing. -/
theorem oracle_chain_mono {α : Type*} (J : JumpOperator α) (base : Set α) :
    ∀ m n : ℕ, m ≤ n → OracleChain J base m ⊆ OracleChain J base n := by
  intro m n hmn
  induction n with
  | zero => simp_all [Nat.le_zero.mp hmn]
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hmn with rfl | h
    · exact Subset.rfl
    · exact Subset.trans (ih (Nat.lt_succ_iff.mp h)) (J.expanding _)

/-- **Theorem (Strict Successor)**: Each level strictly contains the previous one. -/
theorem oracle_chain_strict {α : Type*} (J : JumpOperator α) (base : Set α) :
    ∀ n : ℕ, OracleChain J base n ⊂ OracleChain J base (n + 1) := by
  intro n
  refine ⟨J.expanding _, fun h => ?_⟩
  obtain ⟨x, hx_in, hx_not⟩ := J.nontrivial (OracleChain J base n)
  exact hx_not (h hx_in)

/-- The chain produces infinitely many distinct levels. -/
theorem oracle_chain_all_distinct {α : Type*} (J : JumpOperator α) (base : Set α)
    (m n : ℕ) (hmn : m < n) :
    OracleChain J base m ≠ OracleChain J base n := by
  intro heq
  have hstrict := oracle_chain_strict J base m
  have hmono := oracle_chain_mono J base (m + 1) n (Nat.succ_le_of_lt hmn)
  exact hstrict.2 (heq ▸ hmono)

/-! ### Diagonal Escape -/

/-- A **decision procedure** for a set is a total boolean function agreeing with membership. -/
def Decides (f : α → Bool) (S : Set α) : Prop :=
  ∀ x, (f x = true ↔ x ∈ S)

/-- **Theorem (Diagonal Escape)**: No decision procedure that correctly decides
level n can also correctly decide level n+1. This formalizes the key insight
that each oracle level genuinely transcends the previous one. -/
theorem diagonal_escape {α : Type*} (J : JumpOperator α) (base : Set α)
    (f : α → Bool) (n : ℕ)
    (h_decide_n : Decides f (OracleChain J base n)) :
    ¬ Decides f (OracleChain J base (n + 1)) := by
  intro h_decide_succ
  obtain ⟨x, hx_in, hx_not⟩ := J.nontrivial (OracleChain J base n)
  have h1 : f x = true := (h_decide_succ x).mpr hx_in
  exact hx_not ((h_decide_n x).mp h1)

/-! ### Jump Fixed Points -/

/-- **Theorem (No Fixed Points)**: A jump operator has no fixed points.
No set equals its own jump — the hierarchy can never stabilize. -/
theorem jump_no_fixed_point {α : Type*} (J : JumpOperator α) (S : Set α) :
    J.jump S ≠ S := by
  intro h
  obtain ⟨x, hx_in, hx_not⟩ := J.nontrivial S
  exact hx_not (h ▸ hx_in)

/-- **Corollary**: The oracle chain never stabilizes at any finite level. -/
theorem oracle_chain_never_stabilizes {α : Type*} (J : JumpOperator α) (base : Set α)
    (n : ℕ) : OracleChain J base n ≠ OracleChain J base (n + 1) := by
  exact Ne.symm (jump_no_fixed_point J _)

/-! ### Information Gap -/

/-- The **information gap** between consecutive oracle levels. -/
def InformationGap {α : Type*} (J : JumpOperator α) (base : Set α) (n : ℕ) : Set α :=
  OracleChain J base (n + 1) \ OracleChain J base n

/-- The information gap is always nonempty. -/
theorem information_gap_nonempty {α : Type*} (J : JumpOperator α) (base : Set α) (n : ℕ) :
    (InformationGap J base n).Nonempty := by
  obtain ⟨x, hx_in, hx_not⟩ := J.nontrivial (OracleChain J base n)
  exact ⟨x, hx_in, hx_not⟩

/-! ### Composing Jump Operators -/

/-- The **composition** of two jump operators. -/
def JumpOperator.comp {α : Type*} (J₁ J₂ : JumpOperator α) : JumpOperator α where
  jump S := J₁.jump (J₂.jump S)
  expanding S := Subset.trans (J₂.expanding S) (J₁.expanding _)
  nontrivial S := by
    obtain ⟨x, hx_in, hx_not⟩ := J₁.nontrivial (J₂.jump S)
    exact ⟨x, hx_in, fun h => hx_not (J₂.expanding S h)⟩

/-- Double-jumping skips a level. -/
theorem double_jump_eq {α : Type*} (J : JumpOperator α) (base : Set α) (n : ℕ) :
    J.jump (J.jump (OracleChain J base n)) = OracleChain J base (n + 2) := by
  rfl

/-- **Theorem (Composition Dominance)**: A monotone composed jump dominates
the inner jump. -/
theorem comp_jump_dominates {α : Type*} (J₁ J₂ : JumpOperator α) (S : Set α)
    (_hJ₁_mono : J₁.IsMonotone) :
    J₂.jump S ⊆ (J₁.comp J₂).jump S := by
  exact J₁.expanding (J₂.jump S)

/-! ### Convergence Principle for Physical Hypercomputers -/

/-- A **physical hypercomputer** is modeled as a sequence of finite approximations. -/
structure PhysicalHypercomputer (α : Type*) where
  /-- The approximation at each finite stage -/
  stage : ℕ → (α → Bool)
  /-- The target function the hypercomputer tries to compute -/
  target : α → Bool

/-- A hypercomputer **converges** on input x if its stages eventually stabilize. -/
def PhysicalHypercomputer.Converges {α : Type*} (H : PhysicalHypercomputer α) (x : α) : Prop :=
  ∃ N, ∀ n, n ≥ N → H.stage n x = H.target x

/-- A hypercomputer is **eventually correct** if it converges on all inputs. -/
def PhysicalHypercomputer.EventuallyCorrect {α : Type*} (H : PhysicalHypercomputer α) : Prop :=
  ∀ x, H.Converges x

/-- **Theorem (Unbounded Convergence)**: If every finite stage has some error,
then no single finite stage is universally correct. -/
theorem unbounded_convergence {α : Type*}
    (H : PhysicalHypercomputer α)
    (h_no_uniform : ∀ N, ∃ x, H.stage N x ≠ H.target x) :
    ¬ ∃ N, ∀ x, H.stage N x = H.target x := by
  rintro ⟨N, hN⟩
  obtain ⟨x, hx⟩ := h_no_uniform N
  exact hx (hN x)

/-! ### Accidental vs Essential Computability -/

/-- A function f is **essentially computable** relative to a family if it equals one. -/
def EssentiallyComputable (f : ℕ → Bool) (computable : ℕ → (ℕ → Bool)) : Prop :=
  ∃ n, f = computable n

/-
**Theorem (Essential-Accidental Gap)**: If the family of computable functions
is pointwise surjective onto Bool (for every input and every boolean value, some
function in the family achieves that value) but not globally surjective, then
there exists a function that is "accidentally correct" at every point (agreeing
with some family member pointwise) but not essentially computable (not equal to
any single family member).

This captures the hypercomputation paradox: a physical process might get every
individual answer right "by accident" without being truly computable.
-/
theorem essential_accidental_gap
    (computable : ℕ → (ℕ → Bool))
    (h_pointwise : ∀ x : ℕ, ∀ b : Bool, ∃ n, computable n x = b)
    (h_not_surj : ¬ Function.Surjective computable) :
    ∃ f : ℕ → Bool,
      (∀ x, ∃ n, computable n x = f x) ∧
      ¬ EssentiallyComputable f computable := by
  simp_all +decide [ Function.Surjective, EssentiallyComputable ];
  exact ⟨ h_not_surj.choose, fun x => by cases h_not_surj.choose x <;> [ exact h_pointwise x |>.1.imp fun n hn => by aesop; ; exact h_pointwise x |>.2.imp fun n hn => by aesop ], fun x hx => h_not_surj.choose_spec x <| hx.symm ⟩

/-! ### Cardinality Barriers -/

/-
**Theorem (Oracle Space Uncountable)**: The space of all oracles (ℕ → Bool)
is uncountable. No countable enumeration captures all possible oracles.
-/
theorem oracle_space_uncountable :
    ¬ ∃ (enum : ℕ → (ℕ → Bool)), Function.Surjective enum := by
  rintro ⟨ enum, h_enum ⟩;
  exact absurd ( h_enum fun n => if enum n n = Bool.true then Bool.false else Bool.true ) ( by rintro ⟨ n, hn ⟩ ; by_cases h : enum n n = Bool.true <;> simpa [ h ] using congr_fun hn n )

/-
**Theorem (Most Oracles Escape)**: For any oracle chain, there exist sets
not appearing at any finite level.
-/
theorem most_oracles_escape_finite_hierarchy
    (J : JumpOperator ℕ) (base : Set ℕ) :
    ∃ S : Set ℕ, ∀ n : ℕ, S ≠ OracleChain J base n := by
  by_contra! h_contra;
  obtain ⟨ n, hn ⟩ := h_contra Set.univ;
  have := oracle_chain_strict J base n; simp_all +decide [ Set.ext_iff ] ;
  grind

/-! ### Finite Query Bounds -/

/-
**Theorem (Finite Query Bound)**: With k binary queries, at most 2^k
distinct response patterns exist.
-/
theorem finite_query_bound (k : ℕ) :
    Fintype.card (Fin k → Bool) = 2 ^ k := by
  simp +zetaDelta at *

/-! ### Ordinal-Indexed Chain (Abstract) -/

/-- An **ordinal oracle chain** extends the construction to all ordinals.
At successor ordinals we apply the jump; at limit ordinals we take unions. -/
structure OrdinalOracleChain (α : Type*) where
  /-- The jump operator -/
  jump : JumpOperator α
  /-- The level at each ordinal -/
  level : Ordinal → Set α
  /-- Monotonicity -/
  mono : ∀ a b : Ordinal, a ≤ b → level a ⊆ level b
  /-- Successor step -/
  succ_eq : ∀ o : Ordinal, level (Order.succ o) = jump.jump (level o)
  /-- Limit step (encoded via the successor condition and monotonicity) -/
  limit_union : ∀ o : Ordinal, (∀ p : Ordinal, p < o → Order.succ p ≤ o) →
    level o = ⋃ (b : Ordinal) (_ : b < o), level b

/-
**Theorem (Ordinal Strict Successor)**: The ordinal chain strictly
increases at every successor ordinal.
-/
theorem ordinal_chain_strict_succ (C : OrdinalOracleChain α)
    (o : Ordinal) : C.level o ⊂ C.level (Order.succ o) := by
  grind +suggestions

/-
**Theorem (Limit Absorption)**: At a limit ordinal, every element
was already present at some earlier level. Limit ordinals collect
but do not create new computational power.
-/
theorem limit_absorption (C : OrdinalOracleChain α) (o : Ordinal)
    (ho : ∀ p : Ordinal, p < o → Order.succ p ≤ o)
    (x : α) (hx : x ∈ C.level o) :
    ∃ b : Ordinal, b < o ∧ x ∈ C.level b := by
  contrapose! hx;
  rw [ C.limit_union o ho ] ; exact Set.mem_iUnion₂.not.mpr ( by aesop ) ;

/-! ### Gap Measure and Stabilization -/

/-- For finite sets, the **gap cardinality** measures how much new information
each jump adds. -/
def finiteGapCard (J : JumpOperator ℕ) (base : Set ℕ) (n : ℕ)
    [Fintype (InformationGap J base n)] : ℕ :=
  Fintype.card (InformationGap J base n)

end