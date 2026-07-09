import Mathlib

/-!
# Gödel's Casino: Incomplete but Winnable Games

This file formalises a betting game — *Gödel's Casino* — over the sentences of a
formal theory `T`, and proves that a specific strategy has a **guaranteed positive
profit** on the interesting (undecidable-by-`T`) cards, strictly stronger than the
"positive expected value" originally conjectured.

## The mathematical core

We model a theory `T` abstractly by the data we actually need: a type of sentences,
a negation, a provability predicate `Provable` (`T ⊢ ·`), an arithmetic-truth
predicate `True_` (truth in the standard model `ℕ`), a `Σ₁`-classification predicate
`IsSigma1`, together with three standard facts taken as hypotheses:

* **soundness** — `T` proves only true sentences;
* **truth respects negation** — `True_ (¬s) ↔ ¬ True_ s`;
* **`Σ₁`-completeness** — every *true* `Σ₁` sentence is provable
  (the real theorem for recursively axiomatised extensions of Robinson arithmetic).

From these we derive the key facts driving the strategy:

* `Theory.pi1_indep_true`  — every `Π₁` sentence **independent** of `T` is TRUE;
* `Theory.sigma1_indep_false` — every `Σ₁` sentence **independent** of `T` is FALSE.

Note this *corrects* the mission's proposal to "bet FALSE on `Π₁` statements like
`Con(ZFC)`": independent `Π₁` sentences are in fact TRUE, so one must bet TRUE on
them. `Con(ZFC)` is a true `Π₁` sentence, and betting FALSE on it loses.

## The casino

* `Bet` — `betTrue | betFalse | hedge`.
* `payoff` — `+1` for a correct bet, `-1` for a wrong bet, `0` for a hedge.
* `stratBet` — the winning strategy: bet TRUE on `Π₁`, FALSE on `Σ₁`, hedge otherwise.
* `Card` — a sentence together with its known kind (`Σ₁`/`Π₁`/other), a proof that the
  sentence really has that kind, and a proof that it is independent of `T`.

Main results:

* `cardProfit_pi1`, `cardProfit_sigma1` — each decidable-shape card returns `+1`.
* `cardProfit_nonneg` — the strategy never loses on any single card.
* `deckProfit_nonneg` — the strategy never loses on a whole deck.
* `deckProfit_eq_count` — total profit equals the number of `Σ₁`/`Π₁` cards.
* `deckProfit_pos` — as soon as one decidable-shape card is dealt, profit `> 0`.
* `deckProfit_avg_third` — if `≥ 1/3` of the deck is decidable-shape, the average
  profit per round is `≥ 1/3` (a *guaranteed*, not merely expected, edge).
* `toy` example — a concrete non-vacuous instance with profit `1`.
-/

namespace GodelsCasino

open Classical

/-- Abstract model of a formal theory `T`, bundling the standard facts about
arithmetic truth and provability that the casino strategy relies on. -/
structure Theory where
  /-- The type of sentences of the theory. -/
  Sentence : Type
  /-- Syntactic negation of a sentence. -/
  neg : Sentence → Sentence
  /-- `Provable s` means `T ⊢ s`. -/
  Provable : Sentence → Prop
  /-- `True_ s` means `s` holds in the standard model `ℕ`. -/
  True_ : Sentence → Prop
  /-- `IsSigma1 s` means `s` is syntactically a `Σ₁` sentence. -/
  IsSigma1 : Sentence → Prop
  /-- Soundness: the theory proves only true sentences. -/
  sound : ∀ s, Provable s → True_ s
  /-- Arithmetic truth commutes with negation. -/
  true_neg : ∀ s, True_ (neg s) ↔ ¬ True_ s
  /-- `Σ₁`-completeness: every true `Σ₁` sentence is provable. -/
  sigma1_complete : ∀ s, IsSigma1 s → True_ s → Provable s

namespace Theory

variable (T : Theory)

/-- `s` is `Π₁` iff its negation is `Σ₁`. -/
def IsPi1 (s : T.Sentence) : Prop := T.IsSigma1 (T.neg s)

/-- `s` is independent of `T`: neither it nor its negation is provable. -/
def Indep (s : T.Sentence) : Prop := ¬ T.Provable s ∧ ¬ T.Provable (T.neg s)

/-- **Corrected house edge, `Π₁` case.** Every `Π₁` sentence independent of a
`Σ₁`-complete theory is TRUE. (In particular one should bet TRUE, not FALSE, on
independent `Π₁` sentences such as `Con(ZFC)`.) -/
theorem pi1_indep_true {s : T.Sentence} (hpi : T.IsPi1 s) (hindep : T.Indep s) :
    T.True_ s := by
  by_contra h
  have h1 : T.True_ (T.neg s) := (T.true_neg s).2 h
  have h2 : T.Provable (T.neg s) := T.sigma1_complete _ hpi h1
  exact hindep.2 h2

/-- **Corrected house edge, `Σ₁` case.** Every `Σ₁` sentence independent of a
`Σ₁`-complete theory is FALSE. -/
theorem sigma1_indep_false {s : T.Sentence} (hs : T.IsSigma1 s) (hindep : T.Indep s) :
    ¬ T.True_ s := by
  intro h
  exact hindep.1 (T.sigma1_complete _ hs h)

end Theory

/-- A bet the player can place on a card. -/
inductive Bet
  | betTrue
  | betFalse
  | hedge
  deriving DecidableEq, Repr

/-- The syntactic kind of a card the house may deal. -/
inductive Kind
  | sigma1
  | pi1
  | other
  deriving DecidableEq, Repr

/-- Payoff of a bet on sentence `s`: `+1` if correct, `-1` if wrong, `0` for a hedge. -/
noncomputable def payoff (T : Theory) (b : Bet) (s : T.Sentence) : ℤ :=
  match b with
  | Bet.betTrue  => if T.True_ s then 1 else -1
  | Bet.betFalse => if T.True_ s then -1 else 1
  | Bet.hedge    => 0

/-- The winning strategy: bet TRUE on `Π₁` cards, FALSE on `Σ₁` cards, hedge otherwise. -/
def stratBet : Kind → Bet
  | Kind.sigma1 => Bet.betFalse
  | Kind.pi1    => Bet.betTrue
  | Kind.other  => Bet.hedge

/-- The proposition asserting that sentence `s` genuinely has kind `k`. -/
def classHolds (T : Theory) : Kind → T.Sentence → Prop
  | Kind.sigma1, s => T.IsSigma1 s
  | Kind.pi1, s    => T.IsPi1 s
  | Kind.other, _  => True

/-- A card dealt by the house: a sentence, its known kind, a proof it has that kind,
and a proof it is independent of `T` (the undecidable regime that makes the game
interesting). -/
structure Card (T : Theory) where
  /-- The underlying sentence. -/
  s : T.Sentence
  /-- Its syntactic kind. -/
  kind : Kind
  /-- Proof the sentence really has that kind. -/
  cls : classHolds T kind s
  /-- Proof the sentence is independent of `T`. -/
  indep : T.Indep s

/-- Whether a card has a "decidable shape" (`Σ₁` or `Π₁`), i.e. the strategy bets on
it rather than hedging. -/
def Card.isDecidableShape {T : Theory} (c : Card T) : Bool :=
  match c.kind with
  | Kind.other => false
  | _ => true

/-- Profit obtained by playing the strategy on a single card. -/
noncomputable def cardProfit (T : Theory) (c : Card T) : ℤ :=
  payoff T (stratBet c.kind) c.s

/-- A `Σ₁` card returns `+1`: the strategy bets FALSE and independent `Σ₁` sentences
are false. -/
theorem cardProfit_sigma1 (T : Theory) (c : Card T) (h : c.kind = Kind.sigma1) :
    cardProfit T c = 1 := by
  obtain ⟨s, kind, cls, indep⟩ := c
  subst h
  have hfalse : ¬ T.True_ s := T.sigma1_indep_false cls indep
  simp [cardProfit, stratBet, payoff, hfalse]

/-- A `Π₁` card returns `+1`: the strategy bets TRUE and independent `Π₁` sentences
are true. -/
theorem cardProfit_pi1 (T : Theory) (c : Card T) (h : c.kind = Kind.pi1) :
    cardProfit T c = 1 := by
  obtain ⟨s, kind, cls, indep⟩ := c
  subst h
  have htrue : T.True_ s := T.pi1_indep_true cls indep
  simp [cardProfit, stratBet, payoff, htrue]

/-- An `other` card is hedged and returns `0`. -/
theorem cardProfit_other (T : Theory) (c : Card T) (h : c.kind = Kind.other) :
    cardProfit T c = 0 := by
  obtain ⟨s, kind, cls, indep⟩ := c
  subst h
  simp [cardProfit, stratBet, payoff]

/-- Every card's profit is `1` on decidable-shape cards and `0` otherwise. -/
theorem cardProfit_eq_ite (T : Theory) (c : Card T) :
    cardProfit T c = if c.isDecidableShape then (1 : ℤ) else 0 := by
  cases h : c.kind with
  | sigma1 => rw [cardProfit_sigma1 T c h]; simp [Card.isDecidableShape, h]
  | pi1    => rw [cardProfit_pi1 T c h];    simp [Card.isDecidableShape, h]
  | other  => rw [cardProfit_other T c h];  simp [Card.isDecidableShape, h]

/-- The strategy never loses on a single card. -/
theorem cardProfit_nonneg (T : Theory) (c : Card T) : 0 ≤ cardProfit T c := by
  rw [cardProfit_eq_ite]
  split <;> norm_num

/-- Total profit of the strategy over a whole deck. -/
noncomputable def deckProfit (T : Theory) (deck : List (Card T)) : ℤ :=
  (deck.map (cardProfit T)).sum

/-- The number of decidable-shape (`Σ₁`/`Π₁`) cards in a deck. -/
def numDecidable (T : Theory) (deck : List (Card T)) : ℕ :=
  (deck.filter (fun c => c.isDecidableShape)).length

/-- **The casino pays exactly the decidable count.** The strategy's total profit over a
deck equals the number of `Σ₁`/`Π₁` cards in it. -/
theorem deckProfit_eq_count (T : Theory) (deck : List (Card T)) :
    deckProfit T deck = (numDecidable T deck : ℤ) := by
  induction deck with
  | nil => simp [deckProfit, numDecidable]
  | cons c cs ih =>
    rw [deckProfit, List.map_cons, List.sum_cons, ← deckProfit, ih, cardProfit_eq_ite,
      numDecidable, numDecidable, List.filter_cons]
    by_cases h : c.isDecidableShape = true
    · rw [if_pos h, if_pos h, List.length_cons]; push_cast; ring
    · rw [if_neg h, if_neg h]; ring

/-- **The strategy never loses.** Total profit over any deck is nonnegative. -/
theorem deckProfit_nonneg (T : Theory) (deck : List (Card T)) :
    0 ≤ deckProfit T deck := by
  rw [deckProfit_eq_count]; positivity

/-- **A guaranteed win.** If the house deals at least one decidable-shape card, the
strategy's profit is strictly positive. -/
theorem deckProfit_pos (T : Theory) (deck : List (Card T))
    (h : ∃ c ∈ deck, c.isDecidableShape) : 0 < deckProfit T deck := by
  rw [deckProfit_eq_count]
  have : 0 < numDecidable T deck := by
    rw [numDecidable, List.length_filter_pos_iff]
    obtain ⟨c, hc, hd⟩ := h
    exact ⟨c, hc, hd⟩
  exact_mod_cast this

/-- **Guaranteed edge of `1/3`.** If at least a third of the deck has decidable shape
(the mission's arithmetic-hierarchy heuristic), then the average profit per round is at
least `1/3`, phrased integrally as `deck.length ≤ 3 · deckProfit`. -/
theorem deckProfit_avg_third (T : Theory) (deck : List (Card T))
    (h : deck.length ≤ 3 * numDecidable T deck) :
    (deck.length : ℤ) ≤ 3 * deckProfit T deck := by
  rw [deckProfit_eq_count]
  exact_mod_cast h

/-! ### The mission's original strategy loses exactly what ours wins

The mission proposed betting TRUE on `Σ₁` and FALSE on `Π₁` cards. On the
*independent* cards this is exactly wrong: independent `Σ₁` sentences are FALSE and
independent `Π₁` sentences are TRUE. So the naive strategy is the pointwise opposite
of the correct one on every decidable-shape card, and its total profit is the negation
of ours. -/

/-- The mission's originally-proposed (flawed) strategy: bet TRUE on `Σ₁`, FALSE on
`Π₁`, hedge otherwise. -/
def naiveBet : Kind → Bet
  | Kind.sigma1 => Bet.betTrue
  | Kind.pi1    => Bet.betFalse
  | Kind.other  => Bet.hedge

/-- Profit of the naive strategy on a single card. -/
noncomputable def naiveCardProfit (T : Theory) (c : Card T) : ℤ :=
  payoff T (naiveBet c.kind) c.s

/-- **The naive strategy is the exact opposite of the correct one, card by card.** -/
theorem naiveCardProfit_eq_neg (T : Theory) (c : Card T) :
    naiveCardProfit T c = - cardProfit T c := by
  obtain ⟨s, kind, cls, indep⟩ := c
  cases kind with
  | sigma1 =>
    have hfalse : ¬ T.True_ s := T.sigma1_indep_false cls indep
    simp [naiveCardProfit, cardProfit, naiveBet, stratBet, payoff, hfalse]
  | pi1 =>
    have htrue : T.True_ s := T.pi1_indep_true cls indep
    simp [naiveCardProfit, cardProfit, naiveBet, stratBet, payoff, htrue]
  | other =>
    simp [naiveCardProfit, cardProfit, naiveBet, stratBet, payoff]

/-- Total profit of the naive strategy over a deck. -/
noncomputable def naiveDeckProfit (T : Theory) (deck : List (Card T)) : ℤ :=
  (deck.map (naiveCardProfit T)).sum

/-- **The naive deck profit is exactly minus the correct deck profit.** -/
theorem naiveDeckProfit_eq_neg (T : Theory) (deck : List (Card T)) :
    naiveDeckProfit T deck = - deckProfit T deck := by
  induction deck with
  | nil => simp [naiveDeckProfit, deckProfit]
  | cons c cs ih =>
    rw [naiveDeckProfit, deckProfit, List.map_cons, List.map_cons, List.sum_cons,
      List.sum_cons, ← naiveDeckProfit, ← deckProfit, ih, naiveCardProfit_eq_neg]
    ring

/-- **The mission's strategy loses whatever the corrected strategy wins.** In
particular, as soon as one decidable-shape card is dealt, the naive strategy's profit
is strictly negative. -/
theorem naiveDeckProfit_neg (T : Theory) (deck : List (Card T))
    (h : ∃ c ∈ deck, c.isDecidableShape) : naiveDeckProfit T deck < 0 := by
  rw [naiveDeckProfit_eq_neg]
  simpa using deckProfit_pos T deck h

/-! ### A concrete, non-vacuous instance

To show the hypotheses are jointly satisfiable and the theorems are not vacuous, we
build a maximally-incomplete toy theory whose sentences are booleans (encoding their
truth value), which proves nothing, and in which the "true" atom is an independent
`Π₁` sentence. Betting TRUE on it wins `+1`. -/

/-- Toy theory: `Sentence = Bool` (a boolean encoding its own truth value), negation is
boolean `not`, the theory proves nothing, and `Σ₁` sentences are exactly the false
booleans (so every true boolean is an independent `Π₁` sentence). -/
def toyTheory : Theory where
  Sentence := Bool
  neg := not
  Provable := fun _ => False
  True_ := fun b => b = true
  IsSigma1 := fun b => b = false
  sound := by intro s h; exact h.elim
  true_neg := by intro s; cases s <;> simp
  sigma1_complete := by intro s h1 h2; simp_all

/-- The card `true`, an independent `Π₁` sentence of the toy theory. -/
def toyCard : Card toyTheory where
  s := true
  kind := Kind.pi1
  cls := rfl
  indep := ⟨fun h => h.elim, fun h => h.elim⟩

/-- A one-card deck for the toy theory. -/
def toyDeck : List (Card toyTheory) := [toyCard]

/-- The toy card is genuinely decidable-shape. -/
example : toyCard.isDecidableShape = true := rfl

/-- **Concrete win.** Playing the strategy on the toy deck returns a profit of `1`. -/
example : deckProfit toyTheory toyDeck = 1 := by
  rw [deckProfit_eq_count]
  rfl

/-- Concrete strict positivity, via the general theorem. -/
example : 0 < deckProfit toyTheory toyDeck :=
  deckProfit_pos toyTheory toyDeck ⟨toyCard, by simp [toyDeck], rfl⟩

end GodelsCasino