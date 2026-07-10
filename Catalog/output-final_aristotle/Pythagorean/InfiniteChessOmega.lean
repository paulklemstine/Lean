/-
# Infinite Chess: Checkmate in Omega Moves — Transfinite Game Values

Infinite chess is chess on an infinite board.  A striking phenomenon is that
there are positions from which White can *force* checkmate, yet every forcing
strategy requires transfinitely many moves.  The **game value** `v(P)` of a
winning position `P` is the least ordinal `α` such that White can force mate in
at most `α` moves.  It is defined by transfinite recursion on the game tree:

* a delivered checkmate has value `0`;
* at a node where the *winner* (White) is to move, the value is the *infimum*
  over White's moves of `1 + (value of the resulting position)` — White plays
  optimally, minimising the remaining length;
* at a node where the *loser* (Black) is to move, the value is the *supremum*
  over Black's moves of `1 + (value of the resulting position)` — Black delays
  as long as possible.

This file develops an abstract, faithful model of such winning game trees and
proves that arbitrarily large transfinite game values are realised.  Concretely
we build explicit positions with values

* `ω`         (the classical "mate in omega"),
* `ω ^ n`     for every natural number `n`,
* `ω ^ ω`,

and we show these values form a strictly increasing transfinite hierarchy with
`ω ^ ω` strictly above every `ω ^ n`.

To keep the combinatorics of an infinite board out of the way while retaining
full mathematical honesty about the *ordinal analysis*, we model the game trees
directly.  Every node is one of:

* `mate`  — checkmate delivered (a leaf, value `0`);
* `step g` — a White node with a *unique* forced continuation `g` (White is one
  move from `g`); its value is `value g + 1`;
* `bsup f` — a Black node offering the countable family of continuations
  `f : ℕ → Game`; Black chooses, so its value is `⨆ n, (value (f n) + 1)`.

`step` (a single-child winner move) and `bsup` (a countably-branching loser
move) already suffice to realise every ordinal below `ω ^ ω`, which is exactly
the range of values the mission targets.
-/
import Mathlib

open Ordinal Order

namespace InfiniteChessOmega

/-- A winning game tree.  See the module docstring. -/
inductive Game where
  /-- Checkmate delivered: a leaf of value `0`. -/
  | mate : Game
  /-- A winner (White) node with a unique forced continuation. -/
  | step : Game → Game
  /-- A loser (Black) node offering a countable family of continuations. -/
  | bsup : (ℕ → Game) → Game

/-- The game value (least number of moves in which White forces mate). -/
noncomputable def value : Game → Ordinal
  | .mate => 0
  | .step g => value g + 1
  | .bsup f => ⨆ n, (value (f n) + 1)

@[simp] lemma value_mate : value .mate = 0 := rfl
@[simp] lemma value_step (g : Game) : value (.step g) = value g + 1 := rfl
lemma value_bsup (f : ℕ → Game) : value (.bsup f) = ⨆ n, (value (f n) + 1) := rfl

/-! ### Left addition commutes with the relevant suprema -/

/-
Left addition by a fixed ordinal commutes with a supremum over `ℕ`.
-/
lemma add_iSup_nat (a : Ordinal) (f : ℕ → Ordinal) :
    a + ⨆ n, f n = ⨆ n, (a + f n) :=
  (isNormal_add_right a).map_iSup (Ordinal.bddAbove_range f)

/-! ### Sequential composition (grafting) of games and additivity of value -/

/-- `graft A B` plays `A` to completion and, at every checkmate leaf of `A`,
continues instead with a fresh copy of `B`.  Sequentially, "first solve `A`,
then solve `B`". -/
def graft : Game → Game → Game
  | .mate, B => B
  | .step g, B => .step (graft g B)
  | .bsup f, B => .bsup (fun n => graft (f n) B)

@[simp] lemma graft_mate (B : Game) : graft .mate B = B := rfl
@[simp] lemma graft_step (g B : Game) : graft (.step g) B = .step (graft g B) := rfl
@[simp] lemma graft_bsup (f : ℕ → Game) (B : Game) :
    graft (.bsup f) B = .bsup (fun n => graft (f n) B) := rfl

/-
**Additivity of game value.**  Solving `A` then `B` takes `value B + value A`
moves, i.e. ordinal addition (with the outer game `A` contributing on the
right, as ordinal addition demands).
-/
theorem value_graft (A B : Game) : value (graft A B) = value B + value A := by
  induction' A with A ih generalizing B;
  · aesop;
  · simp +arith +decide [ *, add_assoc ];
  · simp +decide [ *, add_iSup_nat, value_bsup ];
    simp +decide [ Ordinal.add_succ ]

/-! ### Value `ω`: the classical "mate in omega" -/

/-- `stepN n g` prefixes `n` forced White moves before `g`. -/
def stepN : ℕ → Game → Game
  | 0, g => g
  | (n + 1), g => .step (stepN n g)

lemma value_stepN (n : ℕ) (g : Game) : value (stepN n g) = value g + n := by
  induction n <;> simp_all +decide [ stepN ];
  simp +decide [ Ordinal.add_succ ]

/-- A finite game requiring exactly `n` moves. -/
def finGame (n : ℕ) : Game := stepN n .mate

lemma value_finGame (n : ℕ) : value (finGame n) = (n : Ordinal) := by
  convert value_stepN n .mate using 1;
  norm_num [ value_mate ]

/-- The classical mate-in-`ω` position: Black chooses a natural number `n`, after
which White mates in `n` further forced moves. -/
def omegaGame : Game := .bsup finGame

/-
The game value of `omegaGame` is exactly `ω`.
-/
theorem value_omegaGame : value omegaGame = ω := by
  rw [omegaGame];
  rw [value_bsup];
  rw [ @ciSup_eq_of_forall_le_of_forall_lt_exists_gt ];
  · intro i; rw [ value_finGame ] ; norm_num;
  · intro w hw;
    rcases Ordinal.lt_omega0.1 hw with ⟨ n, rfl ⟩ ; use n ; simp +decide [ value_finGame ]

/-
`omegaGame` genuinely has *infinite* value: White forces mate, but not in any
finite number of moves.
-/
theorem omegaGame_value_infinite : ¬ ∃ n : ℕ, value omegaGame = (n : Ordinal) := by
  simp [value_omegaGame];
  exact fun n => ne_of_gt ( Ordinal.nat_lt_omega0 n )

/-! ### Values `ω ^ n`: iterating the construction -/

/-- `graftN k A` is `k` sequential copies of `A`. -/
def graftN : ℕ → Game → Game
  | 0, _ => .mate
  | (k + 1), A => graft A (graftN k A)

lemma value_graftN (k : ℕ) (A : Game) : value (graftN k A) = value A * k := by
  induction' k with k ih;
  · aesop;
  · rw [ Nat.cast_succ, mul_add, mul_one ];
    rw [ ← ih, show graftN ( k + 1 ) A = graft A ( graftN k A ) by rfl, value_graft ]

/-
A supremum lemma powering the inductive step for `ω ^ (n+1)`.
-/
lemma iSup_mul_succ (v : Ordinal) (hv : 0 < v) :
    ⨆ k : ℕ, (v * (k : Ordinal) + 1) = v * ω := by
  refine' le_antisymm _ _;
  · refine' ciSup_le fun n => _;
    refine' le_trans _ ( mul_le_mul_right ( show ( n : Ordinal ) + 1 ≤ ω from _ ) _ );
    · rw [ mul_add ];
      simpa using hv;
    · exact_mod_cast Ordinal.nat_lt_omega0 ( n + 1 ) |> le_of_lt;
  · have h_nf : ∀ k : ℕ, v * (k : Ordinal) ≤ ⨆ k : ℕ, v * (k : Ordinal) + 1 := by
      exact fun k => le_trans ( by exact le_self_add ) ( le_ciSup ( Ordinal.bddAbove_range _ ) k );
    simpa using Ordinal.iSup_le h_nf

/-- The explicit position of value `ω ^ n`.  For `n+1`, Black chooses `k`, after
which White must solve `k` sequential copies of the `ω ^ n` position. -/
def opowGame : ℕ → Game
  | 0 => .step .mate
  | (n + 1) => .bsup (fun k => graftN k (opowGame n))

/-
The game value of `opowGame n` is exactly `ω ^ n`.
-/
theorem value_opowGame (n : ℕ) : value (opowGame n) = ω ^ n := by
  induction n <;> simp_all +decide [ pow_succ' ];
  · convert value_step _;
    rw [ value_mate, zero_add ];
  · convert iSup_mul_succ _ _ using 1;
    convert value_bsup _ using 3;
    rw [ value_graftN ];
    · rw [ ‹value ( opowGame _ ) = _›, ← pow_succ' ];
      rw [ pow_succ ];
    · aesop

/-! ### Value `ω ^ ω`: the diagonal position -/

/-
A supremum lemma powering the value of the diagonal position.
-/
lemma iSup_opow_succ : ⨆ n : ℕ, ((ω : Ordinal) ^ n + 1) = ω ^ (ω : Ordinal) := by
  refine' le_antisymm _ _;
  · refine' ciSup_le fun n => _;
    refine' le_trans _ ( Ordinal.opow_le_opow_right Ordinal.omega0_pos <| show n + 1 ≤ ω from _ );
    · norm_num [ pow_succ' ];
    · exact_mod_cast Ordinal.nat_lt_omega0 ( n + 1 ) |> le_of_lt;
  · refine' le_of_forall_lt fun x hx => _;
    -- Since $x < \omega^\omega$, there exists some $n$ such that $x < \omega^n$.
    obtain ⟨n, hn⟩ : ∃ n : ℕ, x < ω ^ n := by
      contrapose! hx;
      convert Ordinal.iSup_le hx;
      convert ( isNormal_opow ( by simp +decide : 1 < ω ) ).map_iSup _;
      rotate_left;
      rotate_left;
      exact ⟨ 0 ⟩;
      exact fun n => n;
      · exact ⟨ _, Set.forall_mem_range.2 fun n => Ordinal.nat_lt_omega0 n |> le_of_lt ⟩;
      · grind +suggestions;
      · norm_cast;
    exact lt_of_lt_of_le hn ( le_trans ( le_add_of_nonneg_right zero_le_one ) ( le_ciSup ( Ordinal.bddAbove_of_small _ ) n ) )

/-- The diagonal position: Black chooses `n`, after which White must solve the
`ω ^ n` position. -/
def omegaOmegaGame : Game := .bsup opowGame

/-
The game value of the diagonal position is exactly `ω ^ ω`.
-/
theorem value_omegaOmegaGame : value omegaOmegaGame = ω ^ (ω : Ordinal) := by
  convert iSup_opow_succ using 1;
  exact congr_arg _ ( funext fun n => congr_arg₂ _ ( value_opowGame n ) rfl )

/-! ### The transfinite hierarchy -/

/-- Every power `ω ^ n` is realised as the value of an explicit position. -/
theorem exists_value_opow (n : ℕ) : ∃ P : Game, value P = ω ^ n :=
  ⟨opowGame n, value_opowGame n⟩

/-
The values `ω ^ n` are strictly increasing in `n`.
-/
theorem value_opowGame_strictMono : StrictMono (fun n : ℕ => value (opowGame n)) := by
  simp +decide [ StrictMono, value_opowGame ];
  exact fun a b h => by simpa using pow_lt_pow_right₀ ( show 1 < ω from by exact Ordinal.one_lt_omega0 ) h;

/-
The diagonal position strictly dominates every finite power: `ω ^ n < ω ^ ω`
for all `n`, so the value `ω ^ ω` cannot be achieved by any of the positions in
the finite hierarchy.
-/
theorem value_opowGame_lt_omegaOmega (n : ℕ) :
    value (opowGame n) < value omegaOmegaGame := by
  rw [value_opowGame, value_omegaOmegaGame];
  rw [ ← Ordinal.opow_natCast ];
  exact Ordinal.opow_lt_opow_iff_right ( by norm_num ) |>.2 ( by exact Ordinal.nat_lt_omega0 n )

end InfiniteChessOmega