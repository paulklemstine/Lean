/-
# Transfinite Game Values and Pythagorean Descent

This module formalizes the theory of well-founded game trees with ordinal-like
rank functions, and connects it to number theory through Pythagorean triple
descent and to tropical geometry through min-plus valuations on game values.

## Main Results

- `GameTree`: Inductive type for finite well-founded game trees
- `gameRank`: The game-theoretic rank measuring game complexity
- Pythagorean descent game: A game based on Pythagorean triple leg-descent
- `TropicalGameValue`: Tropical (min-plus) algebraic structure on game values
- `gameRank_children_lt`: Children have strictly smaller rank (by induction)
- `pythagorean_descent_wellfounded`: The descent game terminates
- Tropical semiring laws: commutativity, associativity, distributivity
-/

import Mathlib

open Finset BigOperators

/-! ## Part 1: Well-Founded Game Trees -/

/-- A finite well-founded game tree. Each node has a list of children (available moves).
    A leaf node (no children) represents a terminal/losing position. -/
inductive GameTree : Type where
  | leaf : GameTree
  | node : List GameTree → GameTree
  deriving BEq

namespace GameTree

mutual
  /-- The game-theoretic rank of a game tree.
      For a leaf, rank = 0. For a node, rank = max over children of (child rank + 1). -/
  def gameRank : GameTree → ℕ
    | leaf => 0
    | node children => gameRankList children

  /-- Auxiliary: compute game rank from a list of children. -/
  def gameRankList : List GameTree → ℕ
    | [] => 0
    | c :: cs => max (gameRank c + 1) (gameRankList cs)
end

mutual
  /-- Whether a position is winning for the player to move.
      Leaf = losing (no moves). Node = winning iff some child is losing. -/
  def isWinning : GameTree → Bool
    | leaf => false
    | node children => isWinningList children

  /-- Auxiliary: check if any child position is losing. -/
  def isWinningList : List GameTree → Bool
    | [] => false
    | c :: cs => (!isWinning c) || isWinningList cs
end

mutual
  /-- The height (longest path to a leaf) of a game tree. -/
  def height : GameTree → ℕ
    | leaf => 0
    | node children => 1 + heightList children

  /-- Auxiliary: max height over a list of children. -/
  def heightList : List GameTree → ℕ
    | [] => 0
    | c :: cs => max (height c) (heightList cs)
end

mutual
  /-- The size (total number of nodes) of a game tree. -/
  def treeSize : GameTree → ℕ
    | leaf => 1
    | node children => 1 + treeSizeList children

  /-- Auxiliary: sum of sizes over a list of children. -/
  def treeSizeList : List GameTree → ℕ
    | [] => 0
    | c :: cs => treeSize c + treeSizeList cs
end

/-- The number of available moves from a position. -/
def numMoves : GameTree → ℕ
  | leaf => 0
  | node children => children.length

/-- Construct a linear chain game tree with exactly the given rank. -/
def ofRank : ℕ → GameTree
  | 0 => GameTree.leaf
  | n + 1 => GameTree.node [GameTree.ofRank n]

/-- Construct a "wide" game tree with n children, each a leaf. -/
def wideTree (n : ℕ) : GameTree :=
  GameTree.node (List.replicate n GameTree.leaf)

end GameTree

/-! ## Part 2: Fundamental Theorems on Game Rank -/

@[simp]
theorem gameRank_leaf : GameTree.gameRank GameTree.leaf = 0 := rfl

@[simp]
theorem gameRankList_nil : GameTree.gameRankList [] = 0 := rfl

@[simp]
theorem gameRankList_cons (c : GameTree) (cs : List GameTree) :
    GameTree.gameRankList (c :: cs) =
      max (c.gameRank + 1) (GameTree.gameRankList cs) := rfl

/-
Size of a game tree is always positive.
-/
theorem gameTree_size_pos : ∀ (t : GameTree), 0 < t.treeSize := by
  intro t;
  induction' t using GameTree.recOn with t ih;
  all_goals norm_cast;
  exact Nat.add_pos_left ( by norm_num ) _

/-
A node with a single child of rank n has rank n + 1.
-/
theorem gameRank_singleton (c : GameTree) :
    (GameTree.node [c]).gameRank = c.gameRank + 1 := by
  convert gameRankList_cons c [ ] using 1

/-
For any child in a node's children list, the child's rank is
    strictly less than the node's rank. Uses induction on the list structure.
-/
theorem gameRankList_mem_lt (children : List GameTree) (c : GameTree)
    (hc : c ∈ children) :
    c.gameRank < GameTree.gameRankList children := by
  induction' children with c' cs ih generalizing c;
  · contradiction;
  · grind +locals

/-
Corollary: children have rank strictly less than their parent node.
-/
theorem gameRank_children_lt (children : List GameTree) (c : GameTree)
    (hc : c ∈ children) :
    c.gameRank < (GameTree.node children).gameRank := by
  convert gameRankList_mem_lt children c hc using 1

/-
The game rank is bounded by the height (uses mutual induction).
-/
theorem gameRank_le_height : ∀ (t : GameTree), t.gameRank ≤ t.height := by
  intro t;
  induction' t using GameTree.recOn with t ih;
  all_goals norm_cast;
  grind +locals

/-
The constructed chain game tree has exactly the prescribed rank.
-/
theorem gameRank_ofRank (n : ℕ) : (GameTree.ofRank n).gameRank = n := by
  induction' n with n ih;
  · rfl;
  · exact Nat.succ_inj.mpr ih

/-
The game rank function is surjective onto ℕ.
-/
theorem gameRank_surjective : Function.Surjective GameTree.gameRank := by
  intro n;
  exact ⟨ _, gameRank_ofRank n ⟩

/-
A wide tree of n ≥ 1 leaves has rank exactly 1.
-/
theorem gameRank_wideTree (n : ℕ) (hn : 0 < n) :
    (GameTree.wideTree n).gameRank = 1 := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
  induction n <;> simp_all +arith +decide [ GameTree.wideTree ];
  simp_all +arith +decide [ List.replicate ];
  simp_all +arith +decide [ GameTree.gameRank, GameTree.gameRankList ]

/-! ## Part 3: Winning Strategy Theory -/

@[simp]
theorem leaf_is_losing : GameTree.isWinning GameTree.leaf = false := rfl

/-
A node with a single losing child is winning.
-/
theorem node_with_losing_child_is_winning :
    GameTree.isWinning (GameTree.node [GameTree.leaf]) = true := by
  rfl

/-
The negation/parity principle: in a linear chain of depth n,
    even depth = losing, odd depth = winning.
-/
theorem chain_parity (n : ℕ) :
    (GameTree.ofRank n).isWinning = decide (n % 2 = 1) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ GameTree.ofRank ];
  -- By definition of `isWinning`, we know that `isWinning (node [c])` is true if and only if `isWinning c` is false.
  have h_isWinning_node : ∀ c : GameTree, (GameTree.node [c]).isWinning = (!c.isWinning) := by
    intros c
    simp [GameTree.isWinning, GameTree.isWinningList];
  grind

/-! ## Part 4: Pythagorean Descent Game -/

/-- A Pythagorean triple (a, b, c) with a² + b² = c². -/
structure PythTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  pythagorean : a ^ 2 + b ^ 2 = c ^ 2
  a_pos : 0 < a
  b_pos : 0 < b

/-- The Pythagorean descent relation: m descends from n if m < n and
    m appears as a leg in some Pythagorean triple with hypotenuse n. -/
def pythDescent (m n : ℕ) : Prop :=
  m < n ∧ ∃ k : ℕ, 0 < k ∧ m ^ 2 + k ^ 2 = n ^ 2

/-
The Pythagorean descent is well-founded (each move strictly decreases).
-/
theorem pythagorean_descent_wellfounded : WellFounded pythDescent := by
  exact ( wellFounded_lt.mono fun m n h => h.1 )

/-
3 is a valid descent move from 5 (since 3² + 4² = 5²).
-/
theorem three_descends_from_five : pythDescent 3 5 := by
  exact ⟨ by decide, 4, by decide, by decide ⟩

/-
4 is a valid descent move from 5 (since 4² + 3² = 5²).
-/
theorem four_descends_from_five : pythDescent 4 5 := by
  use by decide, 3
  norm_num

/-
No Pythagorean descent moves exist from 0.
-/
theorem no_descent_from_zero : ∀ m, ¬ pythDescent m 0 := by
  exact fun m => fun h => by linarith [ h.1 ] ;

/-
Note: pythDescent 0 1 holds (0² + 1² = 1²), so we cannot prove
no_descent_from_one in general. Instead we prove a corrected version:

No *positive* descent moves exist from 1: if m > 0, there is no
    Pythagorean descent from 1 to m.
-/
theorem no_pos_descent_from_one : ∀ m, 0 < m → ¬ pythDescent m 1 := by
  exact fun m hm => fun h => by linarith [ h.1 ] ;

/-
The only descent move from 1 is to 0.
-/
theorem descent_from_one_eq_zero : ∀ m, pythDescent m 1 → m = 0 := by
  exact fun m hm => by linarith [ hm.1 ] ;

/-
A leg of a Pythagorean triple is strictly less than the hypotenuse.
-/
theorem pyth_leg_lt_hyp (t : PythTriple) : t.a < t.c := by
  nlinarith [ t.pythagorean, t.b_pos ]

/-
Both legs of a Pythagorean triple are less than the hypotenuse.
-/
theorem pyth_both_legs_lt_hyp (t : PythTriple) : t.a < t.c ∧ t.b < t.c := by
  constructor <;> nlinarith [ t.pythagorean, t.a_pos, t.b_pos ]

/-! ## Part 5: Tropical Game Valuation (Cross-Domain Bridge)

The tropical (min-plus) semiring provides a natural algebraic framework
for game values. Under this structure, game composition corresponds
to tropical multiplication (addition of values), and game choice
corresponds to tropical addition (minimum of values). -/

/-- The tropical game value: a pair encoding game complexity in the
    tropical (min-plus) semiring. -/
@[ext]
structure TropicalGameValue where
  val : ℕ
  depth : ℕ
  deriving BEq, DecidableEq

namespace TropicalGameValue

/-- Tropical addition (minimum) on game values. -/
def tropAdd (a b : TropicalGameValue) : TropicalGameValue :=
  if a.val ≤ b.val then a else b

/-- Tropical multiplication (ordinary addition) on game values. -/
def tropMul (a b : TropicalGameValue) : TropicalGameValue :=
  ⟨a.val + b.val, a.depth + b.depth⟩

/-- The tropical multiplicative identity. -/
def tropOne : TropicalGameValue := ⟨0, 0⟩

end TropicalGameValue

/-
Tropical multiplication is commutative.
-/
theorem tropical_mul_comm (a b : TropicalGameValue) :
    TropicalGameValue.tropMul a b = TropicalGameValue.tropMul b a := by
  exact (by rw [TropicalGameValue.tropMul, TropicalGameValue.tropMul]; exact (by ext <;> simp [add_comm]))

/-
Tropical multiplication is associative.
-/
theorem tropical_mul_assoc (a b c : TropicalGameValue) :
    TropicalGameValue.tropMul (TropicalGameValue.tropMul a b) c =
    TropicalGameValue.tropMul a (TropicalGameValue.tropMul b c) := by
  -- By definition of tropical multiplication, we have:
  simp [TropicalGameValue.tropMul];
  grind

/-
The tropical game valuation is additive under tropical multiplication.
-/
theorem tropical_game_val_additive (a b : TropicalGameValue) :
    (TropicalGameValue.tropMul a b).val = a.val + b.val := by
  rfl

/-
Tropical addition is idempotent: min(a, a) = a.
-/
theorem tropical_add_idempotent (a : TropicalGameValue) :
    TropicalGameValue.tropAdd a a = a := by
  -- By definition of tropical addition, we have tropAdd a a = if a.val ≤ a.val then a else a.
  simp [TropicalGameValue.tropAdd]

/-
Tropical multiplicative identity is neutral.
-/
theorem tropical_mul_one (a : TropicalGameValue) :
    TropicalGameValue.tropMul a TropicalGameValue.tropOne = a := by
  cases a ; aesop

/-
Tropical multiplication distributes over tropical addition
    when the minimum is determined by the first argument.
-/
theorem tropical_mul_distrib_left (a b c : TropicalGameValue)
    (hab : a.val ≤ b.val) :
    TropicalGameValue.tropMul (TropicalGameValue.tropAdd a b) c =
    TropicalGameValue.tropAdd (TropicalGameValue.tropMul a c)
      (TropicalGameValue.tropMul b c) := by
  -- By definition of tropical multiplication and addition, we can expand both sides of the equation.
  simp [TropicalGameValue.tropMul, TropicalGameValue.tropAdd, hab]

/-! ## Part 6: Game Complexity Hierarchy -/

/-- The game complexity class: all game trees with rank at most k. -/
def GameComplexityClass (k : ℕ) : Set GameTree :=
  { t | t.gameRank ≤ k }

/-
Complexity classes form an ascending chain.
-/
theorem complexity_class_monotone {j k : ℕ} (h : j ≤ k) :
    GameComplexityClass j ⊆ GameComplexityClass k := by
  exact fun t ht => le_trans ht h

/-
Every finite game tree is in its own complexity class.
-/
theorem every_game_in_some_class (t : GameTree) :
    t ∈ GameComplexityClass t.gameRank := by
  exact Set.mem_setOf.mpr ( by rfl )

/-! ## Conjecture: Pythagorean Game Density

**Conjecture**: The number of Pythagorean hypotenuses up to N grows as
Θ(N / √(log N)), following the Landau–Ramanujan theorem for sums of two squares.

**Testable prediction**: For N = 100, the count of numbers that appear
as hypotenuses of Pythagorean triples should be between 10 and 30.

This connects number theory (distribution of Pythagorean triples)
to combinatorial game theory (game value distribution in the descent game). -/

/-- The set of Pythagorean hypotenuses up to n. -/
def pythHypotenuses (n : ℕ) : Finset ℕ :=
  Finset.filter (fun c =>
    ∃ a ∈ Finset.range c, ∃ b ∈ Finset.range c,
      0 < a ∧ 0 < b ∧ a ^ 2 + b ^ 2 = c ^ 2)
    (Finset.range (n + 1))

/-
5 is a Pythagorean hypotenuse (since 3² + 4² = 5²).
-/
theorem five_is_hypotenuse : 5 ∈ pythHypotenuses 5 := by
  native_decide