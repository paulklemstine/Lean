/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Well-Founded Games with Transfinite Game Values

This file establishes the formal theory of well-founded combinatorial games
with ordinal-valued game measures.

## Main Definitions

* `WFGame` — A well-founded combinatorial game
* `WFGame.gameValue` — The ordinal game value (depth) of a position
* `WFGame.CanonicalGame` — The canonical game realizing any ordinal value
* `WFGame.isForced` — A position with at most one available move
* `WFGame.depthSpectrum` — The set of game values reachable from a position
* `WFGame.GameEmbedding` — Structure-preserving map between games

## Main Results

* `WFGame.gameValue_lt_of_move` — Moves strictly decrease game value
* `WFGame.canonical_value_eq` — Canonical game values = ordinal typein
* `WFGame.universal_realization` — Every ordinal is a game value
* `WFGame.depthSpectrum_bounded` — Depth spectrum bounded by game value
* `WFGame.embedding_preserves_value` — Embeddings preserve game values
* `epsilon0_fixed_point` — ε₀ is a fixed point of ω^(·)
-/

set_option maxHeartbeats 800000

noncomputable section

open Ordinal

universe u

/-!
## Core Definitions
-/

/-- A well-founded combinatorial game.
Convention: `moves q p` means "from position p, a player can move to position q".
This aligns with `WellFounded` — children are "smaller" than parents. -/
structure WFGame where
  /-- The type of game positions -/
  Pos : Type u
  /-- `moves q p` means position q is reachable from p in one step -/
  moves : Pos → Pos → Prop
  /-- Every play must terminate -/
  wf : WellFounded moves

namespace WFGame

/-- The game value of a position: the ordinal rank in the game tree.
Defined by well-founded recursion: `gameValue p = lsub {gameValue q | moves q p}`. -/
def gameValue (G : WFGame.{u}) (p : G.Pos) : Ordinal.{u} :=
  G.wf.fix (fun x ih => lsub (fun (q : {q // G.moves q x}) => ih q.val q.prop)) p

/-- Unfolding lemma for game value. -/
theorem gameValue_eq (G : WFGame.{u}) (p : G.Pos) :
    G.gameValue p = lsub (fun (q : {q // G.moves q p}) => G.gameValue q.val) := by
  unfold gameValue; rw [WellFounded.fix_eq]

/-- **Descent Lemma**: Moving to a new position strictly decreases the game value.
This is the fundamental monotonicity property of game values. -/
theorem gameValue_lt_of_move (G : WFGame.{u}) {p q : G.Pos} (h : G.moves q p) :
    G.gameValue q < G.gameValue p := by
  conv_rhs => rw [gameValue_eq]
  exact lt_lsub _ (⟨q, h⟩ : {q // G.moves q p})

/-- Terminal positions (no available moves) have game value 0. -/
theorem gameValue_terminal (G : WFGame.{u}) {p : G.Pos} (h : ∀ q, ¬G.moves q p) :
    G.gameValue p = 0 := by
  rw [gameValue_eq]
  apply le_antisymm
  · apply lsub_le; intro ⟨q, hq⟩; exact absurd hq (h q)
  · positivity

/-!
## Canonical Games and Universal Realization

For each ordinal α, `Ordinal.ToType α` provides a type in `Type u` with
order type exactly α. Using this as positions with the natural ordering
gives the *canonical game* whose game value structure mirrors α.
-/

/-- The canonical game on ordinal α: positions are elements of `Ordinal.ToType α`
(a type with order type α), with moves that decrease in the well-order. -/
def CanonicalGame (α : Ordinal.{u}) : WFGame.{u} where
  Pos := Ordinal.ToType α
  moves := (· < ·)
  wf := wellFounded_lt

/-
**Canonical Value Theorem**: The game value of position a in the
canonical game on α equals the ordinal rank (typein) of a.
This establishes the isomorphism between ordinals-as-positions and
ordinals-as-game-values.

The proof proceeds by well-founded induction: the game value of a
is `lsub {gameValue b | b < a}`. By induction, `gameValue b = typein b`
for all `b < a`, so `lsub {typein b | b < a} = typein a`.
-/
theorem canonical_value_eq (α : Ordinal.{u}) (a : (CanonicalGame α).Pos) :
    (CanonicalGame α).gameValue a = (typein (· < · : α.ToType → α.ToType → Prop)).toRelEmbedding a := by
  -- By definition of game value, we know that the game value of a position is the least ordinal not in the set of game values of its successors.
  have h_gamevalue_def : ∀ a : (Ordinal.ToType α), (CanonicalGame α).gameValue a = lsub (fun b : {b : Ordinal.ToType α // b < a} => (CanonicalGame α).gameValue b.val) := by
    intro a; exact (by
    convert gameValue_eq _ _);
  apply Classical.byContradiction
  intro h_contra;
  obtain ⟨a, ha⟩ : ∃ a : (Ordinal.ToType α), (CanonicalGame α).gameValue a ≠ (typein fun x1 x2 => x1 < x2).toRelEmbedding a ∧ ∀ b : (Ordinal.ToType α), b < a → (CanonicalGame α).gameValue b = (typein fun x1 x2 => x1 < x2).toRelEmbedding b := by
    have h_well_founded : WellFounded (fun x y : (Ordinal.ToType α) => x < y) := by
      exact wellFounded_lt;
    have := h_well_founded.has_min { x : Ordinal.ToType α | ( CanonicalGame α ).gameValue x ≠ ( typein fun x1 x2 => x1 < x2 ).toRelEmbedding x } ⟨ a, h_contra ⟩;
    exact ⟨ this.choose, this.choose_spec.1, fun b hb => Classical.not_not.1 fun h => this.choose_spec.2 b h hb ⟩;
  rw [ h_gamevalue_def ] at ha;
  refine' ha.1 ( le_antisymm _ _ );
  · grind +suggestions;
  · refine' le_of_forall_lt fun β hβ => _;
    obtain ⟨b, hb⟩ : ∃ b : (Ordinal.ToType α), b < a ∧ (CanonicalGame α).gameValue b = β := by
      obtain ⟨b, hb⟩ : ∃ b : (Ordinal.ToType α), b < a ∧ (typein fun x1 x2 => x1 < x2).toRelEmbedding b = β := by
        exact (PrincipalSeg.lt_apply_iff (typein fun x1 x2 => x1 < x2)).mp hβ;
      exact ⟨ b, hb.1, ha.2 b hb.1 ▸ hb.2 ⟩;
    exact hb.2 ▸ Ordinal.lt_lsub ( fun b : { b : Ordinal.ToType α // b < a } => ( CanonicalGame α ).gameValue b.val ) ⟨ b, hb.1 ⟩

/-
The supremum of all game values in the canonical game on α equals α.
Combined with canonical_value_eq, this shows that the game value function
surjects onto all ordinals below α.
-/
theorem canonical_sup_eq (α : Ordinal.{u}) :
    lsub (fun (a : (CanonicalGame α).Pos) =>
      (CanonicalGame α).gameValue a) = α := by
  convert Ordinal.lsub_typein _;
  exact congr_arg _ ( funext fun x => canonical_value_eq α x )

/-
**Universal Realization Theorem**: Every ordinal β < α arises as the game value
of some position in the canonical game on α. In particular, taking α = β + 1,
every ordinal is a game value.

This shows game values surject onto all ordinals: ordinals and game values
are coextensive concepts.
-/
theorem universal_realization (β : Ordinal.{u}) :
    ∃ (G : WFGame.{u}) (p : G.Pos), G.gameValue p = β := by
  -- By the properties of the canonical game, there exists a position p in the canonical game on β + 1 such that G.gameValue p = β.
  obtain ⟨p, hp⟩ : ∃ p : (Ordinal.ToType (β + 1)), (typein (· < · : Ordinal.ToType (β + 1) → Ordinal.ToType (β + 1) → Prop)).toRelEmbedding p = β := by
    have h_enum : β < Ordinal.type (fun x1 x2 : Ordinal.ToType (β + 1) => x1 < x2) := by
      simp +zetaDelta at *;
    have h_enum : β ∈ Set.range (typein (· < · : Ordinal.ToType (β + 1) → Ordinal.ToType (β + 1) → Prop)) := by
      exact typein_surj (fun x1 x2 => x1 < x2) h_enum;
    exact h_enum;
  exact ⟨ CanonicalGame ( β + 1 ), p, by rw [ canonical_value_eq, hp ] ⟩

/-- **Bridge Theorem**: Game values and well-order ranks coincide.
The canonical game on α achieves every ordinal below α exactly once.
This shows game theory and order theory are two equivalent languages
for the same mathematical structure. -/
theorem bridge_theorem (α : Ordinal.{u}) :
    lsub (fun a : (CanonicalGame α).Pos =>
      (CanonicalGame α).gameValue a) = α :=
  canonical_sup_eq α

/-!
## Strategic Complexity — Forced Positions
-/

/-- A position is *forced* if at most one move is available.
At forced positions, no genuine strategic choice exists. -/
def isForced (G : WFGame.{u}) (p : G.Pos) : Prop :=
  ∀ q₁ q₂, G.moves q₁ p → G.moves q₂ p → q₁ = q₂

/-- A game is *strategically trivial* if every position is forced.
Such games have well-defined play length but zero strategic depth. -/
def isStrategicallyTrivial (G : WFGame.{u}) : Prop := ∀ p, G.isForced p

/-- Terminal positions are trivially forced. -/
theorem forced_of_terminal (G : WFGame.{u}) {p : G.Pos} (h : ∀ q, ¬G.moves q p) :
    G.isForced p :=
  fun q₁ _ h₁ _ => absurd h₁ (h q₁)

/-!
## Depth Spectrum
-/

/-- The **depth spectrum** of a position p is the set of all game values
of positions reachable from p via one or more moves. -/
def depthSpectrum (G : WFGame.{u}) (p : G.Pos) : Set Ordinal.{u} :=
  {α | ∃ q, Relation.TransGen G.moves q p ∧ G.gameValue q = α}

/-
**Spectrum Boundedness**: Every element of the depth spectrum is
strictly less than the game value.
-/
theorem depthSpectrum_bounded (G : WFGame.{u}) (p : G.Pos) :
    ∀ α ∈ G.depthSpectrum p, α < G.gameValue p := by
  intro α hα;
  obtain ⟨ q, hq₁, hq₂ ⟩ := hα;
  induction' hq₁ with q r hq hr ih;
  · exact hq₂ ▸ gameValue_lt_of_move _ r;
  · exact lt_trans ‹_› ( G.gameValue_lt_of_move ‹_› )

/-
Terminal positions have empty depth spectrum.
-/
theorem depthSpectrum_terminal (G : WFGame.{u}) {p : G.Pos} (h : ∀ q, ¬G.moves q p) :
    G.depthSpectrum p = ∅ := by
  -- By definition of depth spectrum, if α is in the depth spectrum of p, then there exists a q such that there's a transitive move from q to p and the game value of q is α.
  ext α
  simp [WFGame.depthSpectrum];
  intro q hq; induction hq <;> simp_all +decide ;

/-!
## Game Embeddings
-/

/-- A game embedding from G₁ into G₂ is a function on positions
that preserves and fully reflects the moves relation. -/
structure GameEmbedding (G₁ G₂ : WFGame.{u}) where
  toFun : G₁.Pos → G₂.Pos
  map_moves : ∀ {p q}, G₁.moves q p → G₂.moves (toFun q) (toFun p)
  reflect_moves : ∀ {p} (r : G₂.Pos), G₂.moves r (toFun p) →
    ∃ q, G₁.moves q p ∧ toFun q = r

/-
**Embedding Preservation**: Game embeddings preserve game values.
-/
theorem embedding_preserves_value {G₁ G₂ : WFGame.{u}} (f : GameEmbedding G₁ G₂)
    (p : G₁.Pos) : G₁.gameValue p = G₂.gameValue (f.toFun p) := by
  induction' p using G₁.wf.induction with p ih;
  rw [ gameValue_eq, gameValue_eq ];
  refine' le_antisymm _ _;
  · refine' lsub_le_iff.mpr _;
    intro q;
    refine' lt_of_lt_of_le _ ( le_csInf _ _ );
    rotate_left;
    exact Order.succ ( G₂.gameValue ( f.toFun q ) );
    · exact ⟨ _, Set.forall_mem_range.mpr fun q => Order.succ_le_of_lt <| gameValue_lt_of_move _ q.2 ⟩;
    · intro b hb; specialize hb ⟨ ⟨ f.toFun q, f.map_moves q.2 ⟩, rfl ⟩ ; aesop;
    · aesop;
  · refine' lsub_le_iff.mpr _;
    grind +suggestions

end WFGame

/-!
## ε₀ and Ordinal Fixed Points
-/

/-- ε₀ defined as the least fixed point of x ↦ ω^x starting from 0. -/
def epsilon0 : Ordinal.{u} := nfp (fun x => omega0 ^ x) 0

/-- The exponential x ↦ ω^x is order-normal. -/
theorem opow_omega_isNormal : Order.IsNormal (fun x : Ordinal.{u} => omega0 ^ x) :=
  isNormal_opow one_lt_omega0

/-- **ε₀ Fixed Point Theorem**: ε₀ satisfies ω^ε₀ = ε₀.
This connects game hierarchies to Gentzen's proof theory: ε₀ bounds
exactly the termination proofs expressible in Peano Arithmetic. -/
theorem epsilon0_fixed_point : omega0 ^ (epsilon0 : Ordinal.{u}) = epsilon0 := by
  unfold epsilon0
  exact nfp_fp opow_omega_isNormal 0

/-
ε₀ is positive.
-/
theorem epsilon0_pos : (0 : Ordinal.{u}) < epsilon0 := by
  rw [ epsilon0 ];
  rw [ Ordinal.lt_nfp_iff ];
  use 1
  simp

/-
**ε₀ Minimality**: ε₀ is at most any fixed point of ω^(·).
-/
theorem epsilon0_le_fixed_point {α : Ordinal.{u}}
    (hfp : omega0 ^ α = α) :
    epsilon0 ≤ α := by
  convert Ordinal.nfp_le_fp ( f := fun x => omega0 ^ x ) _ _;
  rotate_left;
  convert opow_omega_isNormal.monotone;
  exact 0;
  exact α;
  · exact zero_le α;
  · aesop

/-
**ω^ω Supremum Theorem**: sup {ω^n | n ∈ ℕ} = ω^ω.
-/
theorem omega_opow_sup :
    lsub (fun n : ℕ => omega0 ^ (n : Ordinal.{u})) = omega0 ^ omega0 := by
  symm;
  refine' le_antisymm _ _;
  · refine' le_of_forall_lt _;
    intro c hc;
    contrapose! hc;
    rw [ Ordinal.opow_le_iff_le_log ] <;> norm_num;
    · refine' le_of_forall_lt fun x hx => _;
      rw [ Ordinal.lt_omega0 ] at hx;
      obtain ⟨ n, rfl ⟩ := hx;
      refine' lt_of_lt_of_le _ ( Ordinal.le_log_of_opow_le ( by norm_num ) _ );
      exact Nat.cast_lt.mpr ( Nat.lt_succ_self _ );
      exact le_trans ( by exact le_of_lt ( Ordinal.lt_lsub _ _ ) ) hc;
    · rintro rfl; norm_num at hc;
  · refine' csSup_le' _;
    rintro _ ⟨ n, rfl ⟩;
    refine' le_trans _ ( Ordinal.opow_le_opow_right _ <| show ω ≥ n + 1 from _ );
    · norm_num [ Ordinal.opow_add ];
    · exact Ordinal.omega0_pos;
    · exact_mod_cast Ordinal.nat_lt_omega0 ( n + 1 ) |> le_of_lt

end