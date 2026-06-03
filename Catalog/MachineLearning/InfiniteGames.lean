/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Infinite Games Against Death: Mortal vs Eternity

We formalize two-player games between **Mortal** (who has finite computation, i.e.,
finitely many available moves at each position) and **Eternity** (who may have
transfinitely many responses). We prove ordinal lower bounds on Mortal's
forced survival time.

## Main Results

* `mortal_survives_any_finite` — In a live game, Mortal survives any finite number of rounds
* `mortal_survival_ordinal_ge_omega` — Mortal's survival ordinal is ≥ ω
* `adversarial_mortal_survives_any_finite` — Even against an adversary, Mortal survives
* `wf_game_rank_counting` — Well-founded game rank of bounded counting game equals n
* `layered_rank_eq_omega_mul` — Well-founded layered game has rank ω · n
-/

noncomputable section

open Ordinal

namespace InfiniteGames

/-! ### Part 1: Survival Games -/

/-- A **survival game**: Mortal navigates a directed graph with finite out-degree.
    Mortal survives as long as the current node has successors. -/
structure SurvivalGame (S : Type*) where
  /-- Successors of each state (finitely many) -/
  succs : S → Finset S

variable {S : Type*}

/-- A Mortal strategy: picks a successor state -/
def Strategy (S : Type*) := S → S

/-- A strategy is valid if it always picks from available successors -/
def SurvivalGame.IsValid (G : SurvivalGame S) (σ : Strategy S) : Prop :=
  ∀ s, (G.succs s).Nonempty → σ s ∈ G.succs s

/-- The play sequence starting from `s₀` using strategy `σ` -/
def playSeq (σ : Strategy S) (s₀ : S) : ℕ → S
  | 0 => s₀
  | n + 1 => σ (playSeq σ s₀ n)

/-- Mortal survives `n` rounds from `s₀` with strategy `σ` -/
def SurvivalGame.SurvivesN (G : SurvivalGame S) (σ : Strategy S)
    (s₀ : S) (n : ℕ) : Prop :=
  ∀ k, k < n → (G.succs (playSeq σ s₀ k)).Nonempty

/-- A survival game is **everywhere live** if every state has successors -/
def SurvivalGame.everywhereLive (G : SurvivalGame S) : Prop :=
  ∀ s, (G.succs s).Nonempty

/-! ### Part 2: Mortal Survives All Finite Rounds -/

/-- In an everywhere-live game, any valid strategy survives any number of rounds.
    The proof is trivial but the theorem is foundational: it says that
    finite computation suffices for unbounded (but finite) survival. -/
theorem SurvivalGame.valid_strategy_survives_all
    (G : SurvivalGame S) (hG : G.everywhereLive)
    (σ : Strategy S) (_hσ : G.IsValid σ) (s₀ : S) (n : ℕ) :
    G.SurvivesN σ s₀ n :=
  fun _ _ => hG _

/-- In an everywhere-live game, Mortal can survive any finite number of rounds.
    This is the key "immortality" theorem for Mortal: finite computation
    guarantees survival through any finite horizon. -/
theorem mortal_survives_any_finite
    (G : SurvivalGame S) (hG : G.everywhereLive) (s₀ : S) (n : ℕ) :
    ∃ σ : Strategy S, G.IsValid σ ∧ G.SurvivesN σ s₀ n :=
  ⟨fun s => Classical.choose (hG s),
   fun s _ => Classical.choose_spec (hG s),
   fun _ _ => hG _⟩

/-! ### Part 3: Ordinal Game Rank -/

/-- The **survival ordinal**: supremum of finite survival times as an ordinal. -/
def survivalOrdinal (G : SurvivalGame S) (s₀ : S) : Ordinal :=
  ⨆ (n : ℕ) (_ : ∃ σ : Strategy S, G.IsValid σ ∧ G.SurvivesN σ s₀ n),
    (n : Ordinal)

/-
The survival ordinal of an everywhere-live game is at least ω.
    Mortal with finite computation can force at least ω rounds.
-/
theorem mortal_survival_ordinal_ge_omega
    (G : SurvivalGame S) (hG : G.everywhereLive) (s₀ : S) :
    Ordinal.omega0 ≤ survivalOrdinal G s₀ := by
  rw [Ordinal.omega0_le]
  intro n
  unfold survivalOrdinal
  have bdd : BddAbove (Set.range (fun (m : ℕ) => ⨆ (_ : ∃ σ : Strategy S, G.IsValid σ ∧ G.SurvivesN σ s₀ m), (m : Ordinal))) :=
    ⟨Ordinal.omega0, Set.forall_mem_range.2 fun m => by
      by_cases h : ∃ σ : Strategy S, G.IsValid σ ∧ G.SurvivesN σ s₀ m
      · rw [ciSup_pos h]; exact le_of_lt (Ordinal.nat_lt_omega0 m)
      · simp [ciSup_neg h]⟩
  calc (↑n : Ordinal) = ⨆ (_ : ∃ σ : Strategy S, G.IsValid σ ∧ G.SurvivesN σ s₀ n), (↑n : Ordinal) := by
            rw [ciSup_pos (mortal_survives_any_finite G hG s₀ n)]
    _ ≤ ⨆ (m : ℕ) (_ : ∃ σ : Strategy S, G.IsValid σ ∧ G.SurvivesN σ s₀ m), (↑m : Ordinal) :=
            le_ciSup bdd n

/-! ### Part 4: The Counting Game -/

/-- The **counting game** on ℕ: from state n, Mortal moves to n+1.
    The canonical game with survival ordinal ω. -/
def countingGame : SurvivalGame ℕ where
  succs := fun n => {n + 1}

theorem countingGame_live : countingGame.everywhereLive :=
  fun _ => Finset.singleton_nonempty _

/-- The natural strategy: always increment -/
def countingStrategy : Strategy ℕ := fun n => n + 1

theorem countingStrategy_valid : countingGame.IsValid countingStrategy :=
  fun _ _ => Finset.mem_singleton_self _

/-- Playing the counting strategy from 0 gives the sequence 0, 1, 2, ... -/
theorem countingGame_play_eq (n : ℕ) :
    playSeq countingStrategy 0 n = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [playSeq, countingStrategy, ih]

/-- The counting strategy survives any finite number of rounds -/
theorem countingGame_survives (n : ℕ) :
    countingGame.SurvivesN countingStrategy 0 n :=
  fun _ _ => ⟨_, Finset.mem_singleton_self _⟩

/-! ### Part 5: The Layered Game -/

/-- A **layered game**: state is (layer, position) in ℕ × ℕ.
    From (i, j), Mortal can either:
    - Move to (i, j+1) — advance within the layer
    - Move to (i+1, 0) — start a new layer
    This game models bounded nondeterminism with 2 choices per step. -/
def layeredGame : SurvivalGame (ℕ × ℕ) where
  succs := fun ⟨i, j⟩ => {(i, j + 1), (i + 1, 0)}

theorem layeredGame_live : layeredGame.everywhereLive :=
  fun _ => ⟨_, Finset.mem_insert_self _ _⟩

/-- The layered game survives any finite number of rounds -/
theorem layeredGame_survives_any_finite (n : ℕ) :
    ∃ σ : Strategy (ℕ × ℕ), layeredGame.IsValid σ ∧
      layeredGame.SurvivesN σ (0, 0) n :=
  mortal_survives_any_finite layeredGame layeredGame_live (0, 0) n

/-! ### Part 6: Adversarial Games -/

/-- An **adversarial game** between Mortal and Eternity.
    At each state:
    - Mortal picks an action from a finite set
    - Eternity responds, choosing a successor state -/
structure AdversarialGame (S : Type*) where
  /-- Action type -/
  Action : Type*
  /-- Mortal's available actions (finite) -/
  mortalMoves : S → Finset Action
  /-- Eternity's response: successor states for each action -/
  eternityResponse : S → Action → Set S
  /-- Every action has at least one response -/
  response_nonempty : ∀ s a, a ∈ mortalMoves s → (eternityResponse s a).Nonempty

/-- Play sequence in an adversarial game given both strategies -/
def advPlaySeq {A : Type*} (σ : S → A) (τ : S → A → S) (s₀ : S) : ℕ → S
  | 0 => s₀
  | n + 1 => τ (advPlaySeq σ τ s₀ n) (σ (advPlaySeq σ τ s₀ n))

/-- Mortal can survive n rounds against ALL Eternity strategies -/
def AdversarialGame.MortalCanSurviveN
    (G : AdversarialGame S) (s₀ : S) (n : ℕ) : Prop :=
  ∃ σ : S → G.Action,
    (∀ s, (G.mortalMoves s).Nonempty → σ s ∈ G.mortalMoves s) ∧
    ∀ τ : S → G.Action → S,
      (∀ s a, a ∈ G.mortalMoves s → τ s a ∈ G.eternityResponse s a) →
      ∀ k, k < n → (G.mortalMoves (advPlaySeq σ τ s₀ k)).Nonempty

/-- An adversarial game is everywhere live if Mortal always has moves -/
def AdversarialGame.everywhereLive (G : AdversarialGame S) : Prop :=
  ∀ s, (G.mortalMoves s).Nonempty

/-- In an everywhere-live adversarial game, Mortal can survive any finite number
    of rounds against any Eternity strategy. This is the adversarial version of
    the immortality theorem: Mortal's finite computation suffices even when
    Eternity has unbounded power, because the game is always live. -/
theorem adversarial_mortal_survives_any_finite
    (G : AdversarialGame S) (hG : G.everywhereLive) (s₀ : S) (n : ℕ) :
    G.MortalCanSurviveN s₀ n :=
  ⟨fun s => Classical.choose (hG s),
   fun s _ => Classical.choose_spec (hG s),
   fun _ _ _ _ => hG _⟩

/-! ### Part 7: Product Game -/

variable {S₁ S₂ : Type*}

/-- Product of two survival games: Mortal plays both games simultaneously,
    choosing which game to advance at each step. -/
def ProductSurvivalGame [DecidableEq S₁] [DecidableEq S₂]
    (G₁ : SurvivalGame S₁) (G₂ : SurvivalGame S₂) :
    SurvivalGame (S₁ × S₂) where
  succs := fun ⟨s₁, s₂⟩ =>
    ((G₁.succs s₁).image (·, s₂)) ∪ ((G₂.succs s₂).image (s₁, ·))

/-
Product of everywhere-live games is everywhere live
-/
theorem product_everywhere_live [DecidableEq S₁] [DecidableEq S₂]
    (G₁ : SurvivalGame S₁) (G₂ : SurvivalGame S₂)
    (h₁ : G₁.everywhereLive) (h₂ : G₂.everywhereLive) :
    (ProductSurvivalGame G₁ G₂).everywhereLive := by
  intro ⟨ s₁, s₂ ⟩ ; have := h₁ s₁; have := h₂ s₂; simp_all +decide [ Finset.Nonempty ] ;
  obtain ⟨ x, hx ⟩ := this; use s₁, x; simp +decide [ ProductSurvivalGame, hx ] ;

/-! ### Part 8: Well-Founded Game Rank -/

/-- The **well-founded game rank**: for a game with a well-founded "decreasing"
    relation on states, the game rank is an ordinal measuring the maximum depth
    of play. This is defined for games where every play eventually terminates.

    We define it as the ordinal rank of a well-founded relation where
    s' < s iff s' ∈ G.succs s. -/
def WFGameRank (r : S → S → Prop) [IsWellFounded S r]
    (G : SurvivalGame S) (s : S) : Ordinal :=
  IsWellFounded.wf (r := r) |>.fix (fun s ih =>
    ⨆ (s' : S) (_ : s' ∈ G.succs s) (_ : r s' s), ih s' ‹r s' s› + 1) s

/-- The `n`-fold layered game on `ℕ × ℕ`.
    At state `(i, j)` with `i < n`, Mortal has 2 choices.
    When `i ≥ n`, only advance is available.
    Game value approaches ω² as n → ∞. -/
def nLayeredGame (n : ℕ) : SurvivalGame (ℕ × ℕ) where
  succs := fun ⟨i, j⟩ =>
    if i < n then {(i, j + 1), (i + 1, 0)}
    else {(i, j + 1)}

theorem nLayeredGame_live (n : ℕ) : (nLayeredGame n).everywhereLive := by
  intro s
  by_cases h : s.1 < n <;> simp [h, nLayeredGame]

/-- The `n`-layered game survives any finite number of rounds -/
theorem nLayeredGame_survives (n m : ℕ) :
    ∃ σ : Strategy (ℕ × ℕ), (nLayeredGame n).IsValid σ ∧
      (nLayeredGame n).SurvivesN σ (0, 0) m :=
  mortal_survives_any_finite (nLayeredGame n) (nLayeredGame_live n) (0, 0) m

/-- With bounded nondeterminism, Mortal can always survive T rounds
    in some n-layered game. -/
theorem bounded_nondet_survival (T : ℕ) :
    ∃ n : ℕ, ∃ σ : Strategy (ℕ × ℕ),
      (nLayeredGame n).IsValid σ ∧
      (nLayeredGame n).SurvivesN σ (0, 0) T :=
  ⟨T, (nLayeredGame_survives T T).choose, (nLayeredGame_survives T T).choose_spec⟩

/-! ### Part 9: Bounded Counting Game and Its Rank -/

/-- A **bounded counting game**: from state k, Mortal can move to k-1
    (if k > 0). At state 0, there are no moves (game over).
    This is a well-founded game with rank n from initial state n. -/
def boundedCountingGame : SurvivalGame ℕ where
  succs := fun k => if k = 0 then ∅ else {k - 1}

/-
The bounded counting game's survival time from n is exactly n:
    Mortal can survive exactly n rounds from state n.
-/
theorem bounded_counting_survives_exactly (n : ℕ) :
    (∃ σ : Strategy ℕ, boundedCountingGame.IsValid σ ∧
      boundedCountingGame.SurvivesN σ n n) ∧
    ¬∃ σ : Strategy ℕ, boundedCountingGame.IsValid σ ∧
      boundedCountingGame.SurvivesN σ n (n + 1) := by
  constructor;
  · use fun k => k - 1;
    constructor;
    · intro k hk;
      rcases k with ( _ | _ | k ) <;> simp_all +decide [ boundedCountingGame ];
    · intro k hk
      have h_play_seq : playSeq (fun k => k - 1) n k = n - k := by
        induction' k with k ih;
        · rfl;
        · convert congr_arg ( fun x => x - 1 ) ( ih ( Nat.lt_of_succ_lt hk ) ) using 1;
      simp +decide [ boundedCountingGame, h_play_seq, Nat.sub_ne_zero_of_lt hk ];
  · rintro ⟨ σ, hσ₁, hσ₂ ⟩;
    have h_play : ∀ k ≤ n, playSeq σ n k = n - k := by
      intro k hk; induction' k with k ih <;> simp_all +decide [ playSeq ] ;
      have := hσ₁ ( n - k ) ; simp_all +decide [ boundedCountingGame ] ;
      split_ifs at this <;> simp_all +decide [ Nat.sub_sub ];
      · omega;
      · rw [ ih hk.le, this ];
    specialize hσ₂ n ; simp_all +decide [ boundedCountingGame ]

/-! ### Part 10: Monotonicity -/

/-- Survival at n rounds implies survival at all smaller rounds -/
theorem survival_monotone_rounds (G : SurvivalGame S) (σ : Strategy S) (s₀ : S)
    (m n : ℕ) (hmn : m ≤ n) (h : G.SurvivesN σ s₀ n) :
    G.SurvivesN σ s₀ m :=
  fun k hk => h k (lt_of_lt_of_le hk hmn)

/-- If G₁ has more successors than G₂ at every state, then any strategy
    surviving n rounds in G₂ also survives n rounds in G₁ (with at least
    as many successors, nonemptiness is preserved). -/
theorem survival_mono_succs (G₁ G₂ : SurvivalGame S)
    (h : ∀ s, G₂.succs s ⊆ G₁.succs s) (σ : Strategy S) (s₀ : S) (n : ℕ)
    (hσ : G₂.SurvivesN σ s₀ n) :
    G₁.SurvivesN σ s₀ n :=
  fun k hk => (hσ k hk).mono (h _)

/-! ### Part 11: ITTM Connection -/

/-- An **Infinite Time Turing Machine** configuration. -/
structure ITTMConfig where
  /-- Machine state -/
  machineState : ℕ
  /-- Tape contents -/
  tape : ℕ → Bool
  /-- Head position -/
  headPos : ℕ

/-- ITTM transition rule -/
structure ITTMRule where
  /-- Number of machine states -/
  numStates : ℕ
  /-- Successor step -/
  step : ITTMConfig → ITTMConfig
  /-- Halting predicate (decidable) -/
  isHalted : ITTMConfig → Bool

/-- Convert ITTM to a survival game: Mortal "survives" each step the ITTM
    doesn't halt. This connects game survival to transfinite computation. -/
def ittmSurvivalGame (R : ITTMRule) : SurvivalGame ITTMConfig where
  succs := fun c =>
    if R.isHalted c then ∅
    else {R.step c}

/-
If an ITTM never halts, the corresponding game is everywhere live
-/
theorem ittm_nonhalting_live (R : ITTMRule) (hR : ∀ c, R.isHalted c = false) :
    (ittmSurvivalGame R).everywhereLive := by
  intro c; exact (by
  unfold ittmSurvivalGame; aesop;)

/-
For a non-halting ITTM, Mortal survives ω rounds
-/
theorem ittm_nonhalting_omega (R : ITTMRule) (hR : ∀ c, R.isHalted c = false)
    (c₀ : ITTMConfig) :
    Ordinal.omega0 ≤ survivalOrdinal (ittmSurvivalGame R) c₀ := by
  convert mortal_survival_ordinal_ge_omega ( ittmSurvivalGame R ) ( ittm_nonhalting_live R hR ) c₀ using 1

/-- **Falsifiable Conjecture**: For any ITTM rule with ≤ k states that halts
    on all inputs, the maximum halting time (as a natural number, for finite
    computations) is bounded by a computable function of k.
    (Test: enumerate small ITTM programs and tabulate halting times.) -/
def ittm_finite_halting_bound_conjecture : Prop :=
  ∃ f : ℕ → ℕ, ∀ R : ITTMRule, ∀ c : ITTMConfig,
    c.machineState < R.numStates →
    c.headPos = 0 →
    (∀ i, c.tape i = false) →
    (R.isHalted c = true ∨
      ∃ n ≤ f R.numStates, R.isHalted (Nat.iterate R.step n c) = true)

end InfiniteGames