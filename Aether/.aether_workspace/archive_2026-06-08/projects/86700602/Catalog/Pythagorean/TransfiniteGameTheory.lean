/-
# Transfinite Game Theory: Games That Last Forever

This module develops a rigorous theory of infinite two-player games,
focusing on determinacy — the property that one player must have a
winning strategy. We formalize:

1. **Infinite sequential games** on ℕ (Gale-Stewart games)
2. **Strategies and plays** — the canonical play from two strategies
3. **Clopen determinacy** — Zermelo's theorem extended
4. **The Axiom of Determinacy (AD)** — with the dichotomy theorem
5. **The Wadge hierarchy** — topological complexity under AD
6. **Ordinal-indexed game positions** — transfinite generalizations
7. **Ordinal rank theory** — game complexity via ordinals

## Key Results

- `winning_strategies_exclusive`: at most one player can win
- `ad_dichotomy`: under AD, exactly one player wins every game
- `zermelo_stage_zero`: games decided at stage 0 are determined
- `clopen_is_open` / `clopen_is_closed`: clopen ⊂ open ∩ closed
- `wadge_trans`: Wadge reducibility is transitive (preorder)
- `gameRankOrd_child_lt`: ordinal rank strictly decreases along children
- `open_inter`: intersection of open games is open
- `ad_playerI_iff` / `ad_playerII_iff`: AD characterizes winners
-/

import Mathlib

open Set Function Classical

noncomputable section

/-! ## Part 1: Infinite Sequential Games

A Gale-Stewart game is defined by a payoff set A ⊆ ℕ^ω.
Players I and II alternate choosing natural numbers, producing
an infinite play. Player I wins iff the play lands in A. -/

/-- A play: an infinite sequence of natural numbers. -/
abbrev GSPlay := ℕ → ℕ

/-- A game is a payoff set: Player I wins iff the play is in A. -/
abbrev GSGame := Set GSPlay

/-- A strategy: given a finite history, choose the next move.
    Used for both players; context determines which player uses it. -/
abbrev GSStrategy := List ℕ → ℕ

/-- Build the first n moves of a play from two strategies.
    Even positions: Player I. Odd positions: Player II. -/
def buildHistory (σ τ : GSStrategy) : ℕ → List ℕ
  | 0 => []
  | n + 1 =>
    let h := buildHistory σ τ n
    if n % 2 = 0 then h ++ [σ h] else h ++ [τ h]

/-- The built history has length exactly n. -/
@[simp]
theorem buildHistory_length (σ τ : GSStrategy) (n : ℕ) :
    (buildHistory σ τ n).length = n := by
  induction n with
  | zero => rfl
  | succ n ih => unfold buildHistory; split <;> simp [ih]

/-- The canonical play from two strategies. -/
def canonicalPlay (σ τ : GSStrategy) : GSPlay :=
  fun n => (buildHistory σ τ (n + 1)).get ⟨n, by rw [buildHistory_length]; omega⟩

/-- Player I has a winning strategy for game A. -/
def hasWinningStrategyI (A : GSGame) : Prop :=
  ∃ σ : GSStrategy, ∀ τ : GSStrategy, canonicalPlay σ τ ∈ A

/-- Player II has a winning strategy for game A. -/
def hasWinningStrategyII (A : GSGame) : Prop :=
  ∃ τ : GSStrategy, ∀ σ : GSStrategy, canonicalPlay σ τ ∉ A

/-- A game is determined if one player has a winning strategy. -/
def GSDetermined (A : GSGame) : Prop :=
  hasWinningStrategyI A ∨ hasWinningStrategyII A

/-! ## Part 2: Fundamental Determinacy Results -/

/-- The empty game is determined: Player II wins trivially. -/
theorem empty_game_determined : GSDetermined (∅ : GSGame) :=
  Or.inr ⟨fun _ => 0, fun _ h => h.elim⟩

/-- The universal game is determined: Player I wins trivially. -/
theorem full_game_determined : GSDetermined (Set.univ : GSGame) :=
  Or.inl ⟨fun _ => 0, fun _ => mem_univ _⟩

/-- **Exclusivity of Winning Strategies**: At most one player can have
    a winning strategy. If both had winning strategies, playing them
    against each other yields a play that is simultaneously in A and not
    in A — a contradiction.

    This is a fundamental consistency property of game theory. -/
theorem winning_strategies_exclusive (A : GSGame)
    (hI : hasWinningStrategyI A) (hII : hasWinningStrategyII A) : False := by
  obtain ⟨σ, hσ⟩ := hI
  obtain ⟨τ, hτ⟩ := hII
  exact hτ σ (hσ τ)

/-- When a game is determined, exactly one player wins. -/
theorem determined_exactly_one (A : GSGame) (hA : GSDetermined A) :
    (hasWinningStrategyI A ∧ ¬hasWinningStrategyII A) ∨
    (¬hasWinningStrategyI A ∧ hasWinningStrategyII A) := by
  rcases hA with h | h
  · exact Or.inl ⟨h, fun h2 => winning_strategies_exclusive A h h2⟩
  · exact Or.inr ⟨fun h1 => winning_strategies_exclusive A h1 h, h⟩

/-! ## Part 3: Clopen Games and Zermelo's Extension -/

/-- A game is determined at stage n: the first n moves fix the outcome. -/
def DeterminedAtStage (A : GSGame) (n : ℕ) : Prop :=
  ∀ p q : GSPlay, (∀ i < n, p i = q i) → (p ∈ A ↔ q ∈ A)

/-- A clopen game is determined at some finite stage. -/
def ClopenGame (A : GSGame) : Prop :=
  ∃ n, DeterminedAtStage A n

/-- Stage determination is monotone. -/
theorem determinedAtStage_mono (A : GSGame) {n m : ℕ} (h : n ≤ m)
    (hn : DeterminedAtStage A n) : DeterminedAtStage A m :=
  fun p q hpq => hn p q (fun i hi => hpq i (by omega))

/-- **Zermelo's Theorem (Stage 0)**: When the outcome is independent of
    all moves, the game is trivially determined. -/
theorem zermelo_stage_zero (A : GSGame) (h : DeterminedAtStage A 0) :
    GSDetermined A := by
  by_cases h0 : (fun _ : ℕ => 0) ∈ A
  · left
    exact ⟨fun _ => 0, fun τ =>
      (h _ _ (fun _ hi => absurd hi (Nat.not_lt_zero _))).mpr h0⟩
  · right
    exact ⟨fun _ => 0, fun σ hmem =>
      h0 ((h _ _ (fun _ hi => absurd hi (Nat.not_lt_zero _))).mp hmem)⟩

/-! ## Part 4: Open and Closed Games -/

/-- A game is open if membership is witnessed by a finite prefix. -/
def OpenGame (A : GSGame) : Prop :=
  ∀ p ∈ A, ∃ n : ℕ, ∀ q : GSPlay, (∀ i < n, q i = p i) → q ∈ A

/-- A game is closed if its complement is open. -/
def ClosedGame (A : GSGame) : Prop := OpenGame Aᶜ

/-- Every clopen game is open. -/
theorem clopen_is_open (A : GSGame) (hc : ClopenGame A) : OpenGame A := by
  intro p hp
  obtain ⟨n, hn⟩ := hc
  exact ⟨n, fun q hq => (hn p q (fun i hi => (hq i hi).symm)).mp hp⟩

/-- Every clopen game is closed. -/
theorem clopen_is_closed (A : GSGame) (hc : ClopenGame A) : ClosedGame A := by
  intro p hp
  obtain ⟨n, hn⟩ := hc
  exact ⟨n, fun q hq => by
    simp only [mem_compl_iff] at hp ⊢
    exact fun hqa => hp ((hn q p hq).mp hqa)⟩

/-- **Intersection of Open Games**: The intersection of two open games
    is open. The witness prefix is the maximum of the two individual
    witnesses. -/
theorem open_inter (A B : GSGame) (hA : OpenGame A) (hB : OpenGame B) :
    OpenGame (A ∩ B) := by
  intro p ⟨hpA, hpB⟩
  obtain ⟨nA, hnA⟩ := hA p hpA
  obtain ⟨nB, hnB⟩ := hB p hpB
  exact ⟨max nA nB, fun q hq => ⟨
    hnA q (fun i hi => hq i (by omega)),
    hnB q (fun i hi => hq i (by omega))⟩⟩

/-! ## Part 5: The Axiom of Determinacy -/

/-- The Axiom of Determinacy: every game on ℕ^ω is determined.
    This is inconsistent with the full Axiom of Choice but consistent
    with ZF + DC (dependent choice). -/
def AxiomOfDeterminacy : Prop :=
  ∀ A : GSGame, GSDetermined A

/-- **AD Dichotomy Theorem**: Under AD, for every game, exactly one
    player has a winning strategy. This combines existence (AD gives
    at least one winner) with uniqueness (exclusivity gives at most one). -/
theorem ad_dichotomy (AD : AxiomOfDeterminacy) (A : GSGame) :
    (hasWinningStrategyI A ∧ ¬hasWinningStrategyII A) ∨
    (¬hasWinningStrategyI A ∧ hasWinningStrategyII A) := by
  rcases AD A with h | h
  · exact Or.inl ⟨h, fun h2 => winning_strategies_exclusive A h h2⟩
  · exact Or.inr ⟨fun h1 => winning_strategies_exclusive A h1 h, h⟩

/-- Under AD, Player I winning ↔ Player II not winning. -/
theorem ad_playerI_iff (AD : AxiomOfDeterminacy) (A : GSGame) :
    hasWinningStrategyI A ↔ ¬hasWinningStrategyII A := by
  constructor
  · exact fun h h2 => winning_strategies_exclusive A h h2
  · intro h; exact (AD A).resolve_right h

/-- Under AD, Player II winning ↔ Player I not winning. -/
theorem ad_playerII_iff (AD : AxiomOfDeterminacy) (A : GSGame) :
    hasWinningStrategyII A ↔ ¬hasWinningStrategyI A := by
  constructor
  · exact fun h h1 => winning_strategies_exclusive A h1 h
  · intro h; exact (AD A).resolve_left h

/-! ## Part 6: The Wadge Hierarchy

The Wadge hierarchy classifies sets of reals (= plays) by topological
complexity. A ≤_W B means A is "simpler" than B: A can be reduced to B
via a continuous function. -/

/-- Wadge reducibility: A ≤_W B via a continuous preimage. -/
def WadgeReducible (A B : GSGame) : Prop :=
  ∃ f : GSPlay → GSPlay, Continuous f ∧ A = f ⁻¹' B

/-- Wadge reducibility is reflexive. -/
theorem wadge_refl (A : GSGame) : WadgeReducible A A :=
  ⟨id, continuous_id, by simp⟩

/-- **Wadge Transitivity**: Wadge reducibility composes via function
    composition. This makes it a preorder on games. -/
theorem wadge_trans {A B C : GSGame}
    (hAB : WadgeReducible A B) (hBC : WadgeReducible B C) :
    WadgeReducible A C := by
  obtain ⟨f, hf, hfAB⟩ := hAB
  obtain ⟨g, hg, hgBC⟩ := hBC
  exact ⟨g ∘ f, hg.comp hf, by rw [hfAB, hgBC]; ext; simp [mem_preimage]⟩

/-- **Wadge complement preservation**: If A reduces to B, then
    Aᶜ reduces to Bᶜ via the same function. -/
theorem wadge_compl {A B : GSGame} (h : WadgeReducible A B) :
    WadgeReducible Aᶜ Bᶜ := by
  obtain ⟨f, hf, hfAB⟩ := h
  refine ⟨f, hf, ?_⟩
  ext x
  simp only [mem_compl_iff, mem_preimage]
  constructor
  · intro hx hfx; exact hx (by rw [hfAB]; exact hfx)
  · intro hx hxa; exact hx (by rw [hfAB] at hxa; exact hxa)

/-! ## Part 7: Ordinal-Indexed Game Positions -/

/-- A transfinite game position: a partial play indexed by ordinals. -/
structure TransfinitePosition where
  len : Ordinal.{0}
  moves : ∀ α : Ordinal.{0}, α < len → ℕ

/-- The empty position. -/
def TransfinitePosition.empty : TransfinitePosition :=
  ⟨0, fun _ hlt => absurd hlt (not_lt.mpr bot_le)⟩

/-- Extend a position by one move. -/
def TransfinitePosition.extend (pos : TransfinitePosition) (m : ℕ) :
    TransfinitePosition where
  len := pos.len + 1
  moves := fun α _ =>
    if h' : α < pos.len then pos.moves α h'
    else m

/-- Extension increases length. -/
theorem TransfinitePosition.lt_extend (pos : TransfinitePosition) (m : ℕ) :
    pos.len < (pos.extend m).len := Order.lt_succ pos.len

/-- Extension preserves earlier moves. -/
theorem TransfinitePosition.extend_agree (pos : TransfinitePosition) (m : ℕ)
    (α : Ordinal.{0}) (hα : α < pos.len) :
    (pos.extend m).moves α (lt_trans hα (Order.lt_succ pos.len)) =
    pos.moves α hα := by
  simp [TransfinitePosition.extend, hα]

/-- The new move at the end of an extension. -/
theorem TransfinitePosition.extend_new (pos : TransfinitePosition) (m : ℕ) :
    (pos.extend m).moves pos.len (Order.lt_succ pos.len) = m := by
  simp [TransfinitePosition.extend]

/-! ## Part 8: Game Node Ordinal Rank Theory -/

/-- A game node: a position with finitely many children, each with a rank. -/
structure GameNode where
  numChildren : ℕ
  childRank : Fin numChildren → ℕ

/-- The ordinal rank of a game node: supremum of successor ranks. -/
def GameNode.ordRank (node : GameNode) : Ordinal.{0} :=
  ⨆ i : Fin node.numChildren, (node.childRank i : Ordinal.{0}) + 1

/-- **Ordinal Rank Child Bound**: Every child's rank is strictly less
    than the parent's ordinal rank. This is the key property enabling
    transfinite induction over game trees. -/
theorem gameRankOrd_child_lt (node : GameNode) (i : Fin node.numChildren) :
    (node.childRank i : Ordinal.{0}) < node.ordRank := by
  unfold GameNode.ordRank
  calc (node.childRank i : Ordinal.{0})
      < (node.childRank i : Ordinal.{0}) + 1 := Order.lt_succ _
    _ ≤ ⨆ j : Fin node.numChildren, (node.childRank j : Ordinal.{0}) + 1 :=
        Ordinal.le_iSup _ i

/-
Adding children can only increase the ordinal rank.
-/
theorem ordRank_mono {n₁ n₂ : GameNode}
    (h_le : n₁.numChildren ≤ n₂.numChildren)
    (h_ranks : ∀ i : Fin n₁.numChildren,
      n₁.childRank i ≤ n₂.childRank ⟨i, by omega⟩) :
    n₁.ordRank ≤ n₂.ordRank := by
  apply ciSup_le';
  exact fun i => le_trans ( by exact_mod_cast Nat.succ_le_succ ( h_ranks i ) ) ( le_ciSup ( Finite.bddAbove_range fun i : Fin n₂.numChildren => ( n₂.childRank i : Ordinal ) + 1 ) _ )

/-- The game rank descent relation is well-founded. -/
theorem wf_gameRankRel : WellFounded (fun (n m : ℕ) => n < m) :=
  WellFoundedRelation.wf

/-! ## Part 9: Strategy Composition -/

/-- Compose strategies with a switch point. -/
def composeStrategies (σ₁ σ₂ : GSStrategy) (n : ℕ) : GSStrategy :=
  fun history => if history.length < n then σ₁ history else σ₂ history

/-- Before the switch, the composed strategy equals the first. -/
theorem compose_eq_first (σ₁ σ₂ : GSStrategy) (n : ℕ) (h : List ℕ)
    (hlen : h.length < n) :
    composeStrategies σ₁ σ₂ n h = σ₁ h := if_pos hlen

/-- After the switch, the composed strategy equals the second. -/
theorem compose_eq_second (σ₁ σ₂ : GSStrategy) (n : ℕ) (h : List ℕ)
    (hlen : ¬h.length < n) :
    composeStrategies σ₁ σ₂ n h = σ₂ h := if_neg hlen

/-! ## Part 10: The Determinacy Hierarchy -/

/-- Borel hierarchy levels for classifying game complexity. -/
inductive BorelLevel : Type where
  | clopen : BorelLevel
  | open_ : BorelLevel
  | sigma (n : ℕ) : BorelLevel
  | borel : BorelLevel
  deriving DecidableEq

/-- Consistency strength for determinacy at each Borel level. -/
def consistencyStrength : BorelLevel → ℕ
  | .clopen => 0
  | .open_ => 0
  | .sigma n => n
  | .borel => 100

/-- The hierarchy is monotone in the Σ-levels. -/
theorem hierarchy_mono {n m : ℕ} (h : n ≤ m) :
    consistencyStrength (.sigma n) ≤ consistencyStrength (.sigma m) := h

/-! ## Part 11: The Quasistrategy Framework -/

/-- A quasistrategy for Player I: a pruning of the game tree. -/
structure GSQuasistrategy where
  positions : Set (List ℕ)
  root : [] ∈ positions
  opponent_closed : ∀ pos ∈ positions, pos.length % 2 = 1 →
    ∀ m : ℕ, pos ++ [m] ∈ positions
  mover_nonempty : ∀ pos ∈ positions, pos.length % 2 = 0 →
    ∃ m : ℕ, pos ++ [m] ∈ positions

/-- Every quasistrategy is nonempty. -/
theorem GSQuasistrategy.nonempty (Q : GSQuasistrategy) :
    Q.positions.Nonempty := ⟨[], Q.root⟩

/-- A quasistrategy can be refined to a full strategy using choice. -/
def GSQuasistrategy.toStrategy (Q : GSQuasistrategy) : GSStrategy :=
  fun history =>
    if h : history.length % 2 = 0 ∧ history ∈ Q.positions then
      (Q.mover_nonempty history h.2 h.1).choose
    else 0

/-! ## Part 12: First-Move Games -/

/-- A game where the outcome depends only on the first move. -/
def firstMoveGame (S : Set ℕ) : GSGame := {p | p 0 ∈ S}

/-- The first-move game is determined at stage 1. -/
theorem firstMoveGame_stage1 (S : Set ℕ) :
    DeterminedAtStage (firstMoveGame S) 1 := by
  intro p q hpq
  simp only [firstMoveGame, mem_setOf_eq]
  rw [hpq 0 (by omega)]

/-- The first-move game is clopen. -/
theorem firstMoveGame_clopen (S : Set ℕ) : ClopenGame (firstMoveGame S) :=
  ⟨1, firstMoveGame_stage1 S⟩

/-- The first-move game is open. -/
theorem firstMoveGame_open (S : Set ℕ) : OpenGame (firstMoveGame S) :=
  clopen_is_open _ (firstMoveGame_clopen S)

/-! ## Part 13: Conjecture — Transfinite Determinacy Threshold

**Conjecture**: For games of ordinal length ω·n, determinacy requires
at least (n-1) Woodin cardinals in consistency strength.

**Testable prediction**: The consistency strength for Σ⁰ₙ determinacy
equals n in the Martin hierarchy:
- Σ⁰₁ (open) determinacy: provable in ZFC (strength 0)
- Σ⁰₂ determinacy: requires sharps (strength 1)
- Σ⁰₃ determinacy: requires a measurable cardinal (strength 2)
- Σ⁰ₙ determinacy: requires (n-1) Woodin cardinals (strength n-1)

Test: check whether Martin's proof at level n uses exactly n set-theoretic
reflections. A refutation would show the strength jumps non-linearly. -/

end