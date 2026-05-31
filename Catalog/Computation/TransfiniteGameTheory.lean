import Mathlib

/-! # Transfinite Game Theory: Games That Last Forever

We develop a rigorous theory of two-player perfect-information games,
from finite game trees (Zermelo's theorem) through infinite sequential games
to transfinite ordinal-indexed games. We formalize:

1. **Zermelo's Theorem**: Every finite game tree is determined.
2. **Value Correctness**: The minimax value identifies the winner.
3. **Strategic Exclusivity**: Both players cannot simultaneously have winning strategies.
4. **Determinacy under AD**: The Axiom of Determinacy implies exact winner identification.
5. **Determinacy Rank** (novel): An ordinal measure of strategic complexity.
6. **Determinacy Hierarchy** (novel): A framework connecting game complexity to
   set-theoretic strength.

## References

- Zermelo, E. (1913). "Über eine Anwendung der Mengenlehre auf die Theorie des Schachspiels"
- Martin, D.A. (1975). "Borel Determinacy"
- Moschovakis, Y. (1980). "Descriptive Set Theory"
-/

noncomputable section
open Classical

namespace TransfiniteGameTheory

/-! ## Part 1: Finite Game Trees and Zermelo's Theorem -/

/-- A finite two-player game tree with binary branching. -/
inductive GameTree where
  | leaf (winner : Bool)
  | nodeI (left right : GameTree)
  | nodeII (left right : GameTree)
deriving Inhabited

/-- The depth of a game tree. -/
def GameTree.depth : GameTree → ℕ
  | .leaf _ => 0
  | .nodeI l r => max l.depth r.depth + 1
  | .nodeII l r => max l.depth r.depth + 1

/-- The minimax value of a game tree. -/
def GameTree.value : GameTree → Bool
  | .leaf w => w
  | .nodeI l r => l.value || r.value
  | .nodeII l r => l.value && r.value

/-- Player I can force the outcome to be `v`. -/
def GameTree.canForceI : GameTree → Bool → Prop
  | .leaf w, v => w = v
  | .nodeI l r, v => l.canForceI v ∨ r.canForceI v
  | .nodeII l r, v => l.canForceI v ∧ r.canForceI v

/-- Player II can force the outcome to be `v`. -/
def GameTree.canForceII : GameTree → Bool → Prop
  | .leaf w, v => w = v
  | .nodeI l r, v => l.canForceII v ∧ r.canForceII v
  | .nodeII l r, v => l.canForceII v ∨ r.canForceII v

/-- The number of internal nodes. -/
def GameTree.size : GameTree → ℕ
  | .leaf _ => 0
  | .nodeI l r => l.size + r.size + 1
  | .nodeII l r => l.size + r.size + 1

/-- The number of leaves. -/
def GameTree.numLeaves : GameTree → ℕ
  | .leaf _ => 1
  | .nodeI l r => l.numLeaves + r.numLeaves
  | .nodeII l r => l.numLeaves + r.numLeaves

/-
**Zermelo's Theorem**: Every finite two-player game of perfect information
    is determined — either Player I can force a win, or Player II can.
-/
theorem zermelo_det (t : GameTree) : t.canForceI true ∨ t.canForceII false := by
  induction' t with l r ihl ihr;
  · cases l <;> tauto;
  · unfold GameTree.canForceI GameTree.canForceII; aesop;
  · rename_i l r ihl ihr;
    cases ihl <;> cases ihr <;> simp_all +decide [ GameTree.canForceI, GameTree.canForceII ]

/-
The minimax value correctly characterizes Player I's forcing power.
-/
theorem value_eq_true_iff_canForceI (t : GameTree) :
    t.value = true ↔ t.canForceI true := by
  induction' t with l r ihl ihr;
  · cases l <;> tauto;
  · cases r.value <;> cases ihl.value <;> simp_all +decide [ GameTree.value, GameTree.canForceI ];
  · unfold GameTree.value GameTree.canForceI; aesop;

/-
The minimax value correctly characterizes Player II's forcing power.
-/
theorem value_eq_false_iff_canForceII (t : GameTree) :
    t.value = false ↔ t.canForceII false := by
  induction t <;> simp_all +decide [ GameTree.canForceII ];
  · rfl;
  · simp_all +decide [ GameTree.value ];
  · simp_all +decide [ GameTree.value ];
    grind

/-
**Strategic Exclusivity**: Both players cannot simultaneously force
    their preferred outcomes.
-/
theorem forces_exclusive (t : GameTree) :
    ¬(t.canForceI true ∧ t.canForceII false) := by
  rw [ ← value_eq_true_iff_canForceI, ← value_eq_false_iff_canForceII ];
  grind

/-
The number of leaves equals size + 1 for binary game trees.
-/
theorem numLeaves_eq_size_succ (t : GameTree) :
    t.numLeaves = t.size + 1 := by
  induction' t with t ih;
  · rfl;
  · simp +arith +decide [ *, GameTree.numLeaves, GameTree.size ];
  · simp +arith +decide [ *, GameTree.numLeaves, GameTree.size ]

/-! ## Part 2: Infinite Sequential Games -/

/-- Build the history of moves from two strategies up to step n. -/
def playHistory (sI sII : List Bool → Bool) : ℕ → List Bool
  | 0 => []
  | n + 1 =>
    let hist := playHistory sI sII n
    hist ++ [if n % 2 = 0 then sI hist else sII hist]

/-- The move at position n. -/
def playMove (sI sII : List Bool → Bool) (n : ℕ) : Bool :=
  if n % 2 = 0 then sI (playHistory sI sII n)
  else sII (playHistory sI sII n)

/-- The full infinite play as a sequence. -/
def fullPlay (sI sII : List Bool → Bool) : ℕ → Bool :=
  playMove sI sII

/-- Player I has a winning strategy in game A. -/
def hasWinningI (A : Set (ℕ → Bool)) : Prop :=
  ∃ sI : List Bool → Bool, ∀ sII : List Bool → Bool, fullPlay sI sII ∈ A

/-- Player II has a winning strategy. -/
def hasWinningII (A : Set (ℕ → Bool)) : Prop :=
  ∃ sII : List Bool → Bool, ∀ sI : List Bool → Bool, fullPlay sI sII ∉ A

/-- A game is determined if one player has a winning strategy. -/
def isDetermined (A : Set (ℕ → Bool)) : Prop :=
  hasWinningI A ∨ hasWinningII A

/-
The history at step n has exactly n elements.
-/
theorem playHistory_length (sI sII : List Bool → Bool) (n : ℕ) :
    (playHistory sI sII n).length = n := by
  induction' n with n ih;
  · rfl;
  · rw [ playHistory ] ; aesop

/-
The history grows: step n is a prefix of step n+1.
-/
theorem playHistory_prefix (sI sII : List Bool → Bool) (n : ℕ) :
    playHistory sI sII n <+: playHistory sI sII (n + 1) := by
  exact ⟨ [ if n % 2 = 0 then sI ( playHistory sI sII n ) else sII ( playHistory sI sII n ) ], by aesop ⟩

/-
**Infinite Game Exclusivity**: At most one player can have a winning strategy.
-/
theorem winning_exclusive (A : Set (ℕ → Bool)) :
    ¬(hasWinningI A ∧ hasWinningII A) := by
  rintro ⟨ ⟨ sI, hsI ⟩, ⟨ sII, hsII ⟩ ⟩;
  exact hsII sI ( hsI sII )

/-! ## Part 3: Axiom of Determinacy and Consequences -/

/-- **The Axiom of Determinacy**: Every game on Cantor space is determined. -/
def AD : Prop := ∀ A : Set (ℕ → Bool), isDetermined A

/-
Under AD, every game has exactly one player with a winning strategy.
-/
theorem ad_exactly_one_winner (hAD : AD) (A : Set (ℕ → Bool)) :
    (hasWinningI A ∧ ¬hasWinningII A) ∨ (¬hasWinningI A ∧ hasWinningII A) := by
  have := hAD A;
  exact this.elim ( fun h => Or.inl ⟨ h, fun h' => TransfiniteGameTheory.winning_exclusive A ⟨ h, h' ⟩ ⟩ ) fun h => Or.inr ⟨ fun h' => TransfiniteGameTheory.winning_exclusive A ⟨ h', h ⟩, h ⟩

/-- Under AD, the complement of any game is also determined. -/
theorem ad_complement_determined (hAD : AD) (A : Set (ℕ → Bool)) :
    isDetermined Aᶜ := by
  exact hAD Aᶜ

/-
The empty game is determined: Player II wins trivially.
-/
theorem empty_game_determined : isDetermined (∅ : Set (ℕ → Bool)) := by
  -- Since the empty set has no elements, any play will not be in it. Therefore, Player II can always win by choosing any strategy.
  right
  use fun _ => false
  simp [fullPlay]

/-
The universal game is determined: Player I wins trivially.
-/
theorem univ_game_determined : isDetermined (Set.univ : Set (ℕ → Bool)) := by
  -- Let player I choose any strategy sI.
  left; use fun _ => true; intro sII; simp [fullPlay]

/-! ## Part 4: Determinacy Rank — A Novel Ordinal Measure

The **determinacy rank** measures how deep strategic analysis must go to
determine the winner. A tree where one branch is immediately winning has
low rank even if the other branch is deep. This captures the intuition
that some games are "strategically simple" despite many possible moves.
-/

/-- The determinacy rank: depth of strategic analysis needed. -/
def GameTree.detRank : GameTree → ℕ
  | .leaf _ => 0
  | .nodeI l r =>
    if l.value || r.value then  -- Player I wins
      if l.value && r.value then min l.detRank r.detRank
      else if l.value then l.detRank
      else r.detRank
    else max l.detRank r.detRank + 1  -- Player II wins, must check both
  | .nodeII l r =>
    if l.value && r.value then  -- Player I wins, must check both
      max l.detRank r.detRank + 1
    else  -- Player II wins
      if !l.value && !r.value then min l.detRank r.detRank
      else if !l.value then l.detRank
      else r.detRank

/-
The determinacy rank is bounded by the tree depth.
-/
theorem detRank_le_depth (t : GameTree) : t.detRank ≤ t.depth := by
  induction' t using GameTree.recOn with t ih;
  · exact Nat.zero_le _;
  · unfold GameTree.detRank GameTree.depth;
    grind;
  · unfold GameTree.detRank GameTree.depth;
    grind

/-- A tree is uniform if all leaves have the same value. -/
def GameTree.isUniform : GameTree → Prop
  | .leaf _ => True
  | .nodeI l r => l.isUniform ∧ r.isUniform ∧ l.value = r.value
  | .nodeII l r => l.isUniform ∧ r.isUniform ∧ l.value = r.value

/-- Leaves always have determinacy rank 0: terminal positions require no analysis. -/
theorem detRank_leaf (w : Bool) : (GameTree.leaf w).detRank = 0 := rfl

/-
When the moving player at a nodeI wins (value = true), the determinacy
    rank does not increase beyond the children's ranks. The winning player's
    analysis avoids the +1 penalty that the losing player would incur.
-/
theorem detRank_nodeI_win (l r : GameTree) (hv : l.value || r.value = true) :
    (GameTree.nodeI l r).detRank ≤ max l.detRank r.detRank := by
  rw [ GameTree.detRank ];
  aesop

/-
When the moving player at a nodeII loses (value = false), the determinacy
    rank does not increase beyond the children's ranks.
-/
theorem detRank_nodeII_loss (l r : GameTree) (hv : l.value && r.value = false) :
    (GameTree.nodeII l r).detRank ≤ max l.detRank r.detRank := by
  rw [ GameTree.detRank ];
  grind

/-! ## Part 5: Determinacy Hierarchy

The `DeterminacyLevel` captures a class of games provably determined at
a given set-theoretic strength. Different axiom systems prove determinacy
for progressively larger classes:
- ZFC proves open/closed determinacy
- ZFC proves Borel determinacy (Martin 1975)
- Large cardinals prove projective determinacy
- AD proves universal determinacy
-/

/-- A determinacy level specifies a class of determined games with
    closure properties. -/
structure DeterminacyLevel where
  /-- The class of games determined at this level. -/
  gameClass : Set (ℕ → Bool) → Prop
  /-- Every game in the class is determined. -/
  det : ∀ A, gameClass A → isDetermined A
  /-- Closure under complements. -/
  compl_closed : ∀ A, gameClass A → gameClass Aᶜ
  /-- Contains the empty game. -/
  has_empty : gameClass ∅
  /-- Contains the universal game. -/
  has_univ : gameClass Set.univ

/-- A payoff set is open if membership is witnessed by a finite prefix. -/
def IsOpenPayoff (A : Set (ℕ → Bool)) : Prop :=
  ∀ x ∈ A, ∃ n : ℕ, ∀ y : ℕ → Bool, (∀ i < n, x i = y i) → y ∈ A

/-- A payoff set is closed if its complement is open. -/
def IsClosedPayoff (A : Set (ℕ → Bool)) : Prop :=
  IsOpenPayoff Aᶜ

/-- A payoff set is clopen if it is both open and closed. -/
def IsClopenPayoff (A : Set (ℕ → Bool)) : Prop :=
  IsOpenPayoff A ∧ IsClosedPayoff A

/-- The empty set is open. -/
theorem empty_isOpen : IsOpenPayoff (∅ : Set (ℕ → Bool)) := by
  intro x hx; exact hx.elim

/-- The universal set is open. -/
theorem univ_isOpen : IsOpenPayoff (Set.univ : Set (ℕ → Bool)) := by
  intro _ _; exact ⟨0, fun _ _ => Set.mem_univ _⟩

/-- One determinacy level is at most as strong as another. -/
def DeterminacyLevel.le (L₁ L₂ : DeterminacyLevel) : Prop :=
  ∀ A, L₁.gameClass A → L₂.gameClass A

instance : LE DeterminacyLevel := ⟨DeterminacyLevel.le⟩

/-- The AD level: all games are determined. -/
def adLevel (hAD : AD) : DeterminacyLevel where
  gameClass := fun _ => True
  det := fun A _ => hAD A
  compl_closed := fun _ _ => trivial
  has_empty := trivial
  has_univ := trivial

/-- The AD level is maximal. -/
theorem ad_level_maximal (hAD : AD) (L : DeterminacyLevel) :
    L ≤ adLevel hAD := by
  intro _ _; trivial

/-! ## Part 6: Transfinite Game Extensions -/

/-- A transfinite game: players alternate moves for ordinal-many steps. -/
structure OrdinalGame where
  /-- The ordinal length of the game -/
  len : Ordinal
  /-- The payoff predicate on complete plays -/
  payoff : (Ordinal → Bool) → Prop

/-- The game length hierarchy: games of length ≤ α. -/
def gamesBoundedBy (α : Ordinal) : Set OrdinalGame :=
  { G | G.len ≤ α }

/-
Finite games are contained in omega-length games.
-/
theorem finite_subset_omega (n : ℕ) :
    gamesBoundedBy (↑n) ⊆ gamesBoundedBy Ordinal.omega0 := by
  intro G hG;
  exact le_trans hG ( mod_cast Ordinal.nat_lt_omega0 n |> le_of_lt )

/-
The game length hierarchy is monotone.
-/
theorem games_bounded_mono {α β : Ordinal} (h : α ≤ β) :
    gamesBoundedBy α ⊆ gamesBoundedBy β := by
  exact fun G hG => le_trans hG h

/-! ## Part 7: Game Tree Transformations -/

/-- Swap the roles of Player I and Player II. -/
def GameTree.swap : GameTree → GameTree
  | .leaf w => .leaf (!w)
  | .nodeI l r => .nodeII l.swap r.swap
  | .nodeII l r => .nodeI l.swap r.swap

/-
Swapping negates the game value.
-/
theorem swap_value (t : GameTree) : t.swap.value = !t.value := by
  induction' t with l r ihl ihr;
  · cases l <;> rfl;
  · simp_all +decide [ GameTree.swap, GameTree.value ];
  · simp_all +decide [ GameTree.swap, GameTree.value ]

/-
Swapping preserves depth.
-/
theorem swap_depth (t : GameTree) : t.swap.depth = t.depth := by
  induction' t with t ih;
  · rfl;
  · unfold GameTree.swap; simp +decide [ *, GameTree.depth ] ;
  · simp +arith +decide [ *, GameTree.swap, GameTree.depth ]

/-
Swapping is an involution.
-/
theorem swap_swap (t : GameTree) : t.swap.swap = t := by
  induction t;
  · cases ‹Bool› <;> rfl;
  · grind +locals;
  · simp_all +decide [ GameTree.swap ]

/-
Swapping exchanges forcing: I can force v in t ↔ II can force !v in t.swap.
-/
theorem swap_forces_I_II (t : GameTree) (v : Bool) :
    t.canForceI v ↔ t.swap.canForceII (!v) := by
  -- We proceed by induction on the structure of the game tree.
  induction' t with l r ihl ihr generalizing v;
  · cases l <;> cases v <;> simp +decide [ GameTree.canForceI, GameTree.canForceII, GameTree.swap ];
  · cases v <;> simp +decide [ *, GameTree.canForceI, GameTree.canForceII, GameTree.swap ];
  · cases v <;> simp_all +decide [ GameTree.canForceI, GameTree.canForceII, GameTree.swap ]

/-! ## Part 8: Balanced Trees and Computational Predictions -/

/-- A balanced game tree of depth n with leaf values from a function.
    Player I moves at even depths, Player II at odd depths. -/
def balancedTree : (n : ℕ) → (Fin (2 ^ n) → Bool) → GameTree
  | 0, f => .leaf (f 0)
  | n + 1, f =>
    let left := balancedTree n (fun i => f ⟨i.val, by omega⟩)
    let right := balancedTree n (fun i => f ⟨i.val + 2 ^ n, by omega⟩)
    if n % 2 = 0 then .nodeI left right
    else .nodeII left right

/-
Balanced trees have the expected depth.
-/
theorem balancedTree_depth (n : ℕ) (f : Fin (2 ^ n) → Bool) :
    (balancedTree n f).depth = n := by
  induction' n with n ih;
  · rfl;
  · unfold balancedTree;
    unfold GameTree.depth; aesop;

/-! ## Conjecture: Determinacy Rank Growth Rate

**Conjecture**: For random balanced binary game trees of depth d (with
uniform random leaf values), the expected determinacy rank grows as
Θ(d / log d) as d → ∞.

**Testable prediction**: For depth d = 4 (2^16 = 65536 possible trees),
the average determinacy rank over all leaf assignments should be
approximately 4 / log₂(4) = 2.0. This can be verified by exhaustive
enumeration.

**Computational test**: Enumerate all balanced trees of depth 3
(2^8 = 256 cases) and compute the mean determinacy rank. The conjecture
predicts approximately 3 / log₂(3) ≈ 1.89. If the actual value differs
by more than 20%, the conjecture is falsified for the rate constant.
-/

end TransfiniteGameTheory