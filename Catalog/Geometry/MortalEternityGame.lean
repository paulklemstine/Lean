/-
  # Mortal-Eternity Games: Transfinite Survival Strategies

  We formalize a two-player game between Mortal (finite computation) and
  Eternity (transfinite computation). The key structure is a **strategy tree**
  encoding Mortal's decisions: at each node, Eternity responds with a natural
  number, and the tree branches accordingly.

  Main results:
  1. `rank_depthTree`: trees of finite depth `n` have rank `n`
  2. `rank_omegaTree`: the diagonal tree has rank `ω`
  3. `rank_addFinite`: finite lifting adds to rank
  4. `rank_omegaMulTree`: iterated diagonal gives rank `ω · n`
  5. `rank_omegaSqTree`: double diagonal gives rank `ω²`
  6. `guaranteedSurvival_depthTree`: bridge between strategy trees and game values
-/
import Mathlib

open Ordinal

/-! ## Strategy Trees -/

/-- A strategy tree for a Mortal-Eternity game.
    - `done`: Mortal concedes (game over)
    - `play f`: Mortal survives this round; Eternity picks `n : ℕ`,
      and play continues with subtree `f n` -/
inductive StratTree : Type where
  | done : StratTree
  | play : (ℕ → StratTree) → StratTree

namespace StratTree

/-! ## Ordinal Rank -/

/-- The ordinal rank of a strategy tree: measures guaranteed survival rounds. -/
noncomputable def rank : StratTree → Ordinal
  | .done => 0
  | .play f => ⨆ n : ℕ, (f n).rank + 1

@[simp] theorem rank_done : rank done = 0 := rfl

theorem rank_play (f : ℕ → StratTree) :
    rank (play f) = ⨆ n : ℕ, (f n).rank + 1 := rfl

/-! ## Finite Depth Trees -/

/-- A strategy tree of exactly depth `n`. -/
def depthTree : ℕ → StratTree
  | 0 => .done
  | n + 1 => .play (fun _ => depthTree n)

/-
**Theorem**: The rank of `depthTree n` is exactly `n`.
-/
theorem rank_depthTree : ∀ n : ℕ, (depthTree n).rank = (n : Ordinal) := by
  intro n;
  induction' n with n ih;
  · rfl;
  · rw [ depthTree, StratTree.rank_play ];
    aesop

/-! ## The Omega Strategy Tree -/

/-- The omega strategy tree: Eternity picks `n`, Mortal plays `depthTree n`. -/
def omegaTree : StratTree := .play (fun n => depthTree n)

/-
**Theorem (Mortal forces ω)**: The omega tree has rank exactly `ω`.
-/
theorem rank_omegaTree : omegaTree.rank = omega0 := by
  refine' le_antisymm _ _;
  · refine' ciSup_le fun n => _;
    rw [ rank_depthTree ];
    exact_mod_cast Ordinal.nat_lt_omega0 ( n + 1 ) |> le_of_lt;
  · refine' le_of_forall_lt _;
    intro c hc; rw [ omegaTree, rank_play ] ;
    obtain ⟨ n, rfl ⟩ := Ordinal.lt_omega0.1 hc; exact lt_of_lt_of_le ( by simp +decide [ rank_depthTree ] ) ( le_ciSup ( Ordinal.bddAbove_of_small _ ) n ) ;

/-! ## Finite Rank Addition

Adding `k` uniform levels to a tree increases its rank by exactly `k`.
This uses constant branching (all children identical), so `ciSup_const`
gives exact control. -/

/-- Add `k` uniform levels to a tree: at each level, all of Eternity's
    choices lead to the same subtree. -/
def addFinite : StratTree → ℕ → StratTree
  | t, 0 => t
  | t, k + 1 => .play (fun _ => addFinite t k)

/-
**Key Lemma**: Adding `k` uniform levels adds exactly `k` to the rank.
-/
theorem rank_addFinite (t : StratTree) :
    ∀ k : ℕ, (addFinite t k).rank = t.rank + (k : Ordinal) := by
  intro k;
  induction' k with k ih generalizing t;
  · aesop;
  · convert rank_play _;
    simp +decide [ ih, add_assoc ]

/-! ## Trees of Rank ω · n

To reach rank `ω · n`, we use iterated diagonal construction.
At each level, Eternity picks `k`, and Mortal plays from a tree of
rank `ω · (n-1) + k`. The `+k` is achieved via `addFinite`. -/

/-- Strategy tree with rank `ω · n`. -/
def omegaMulTree : ℕ → StratTree
  | 0 => done
  | n + 1 => .play (fun k => addFinite (omegaMulTree n) k)

/-
**Theorem**: `omegaMulTree n` has rank exactly `ω · n`.
-/
theorem rank_omegaMulTree :
    ∀ n : ℕ, (omegaMulTree n).rank = omega0 * (n : Ordinal) := by
  intro n;
  induction' n with n ih;
  · aesop;
  · convert rank_play _;
    simp +decide [ih, rank_addFinite];
    rw [@ciSup_eq_of_forall_le_of_forall_lt_exists_gt] <;> norm_num [Ordinal.mul_succ];
    intro w hw;
    rw [ Ordinal.lt_add_iff ] at hw;
    · rcases hw with ⟨ d, hd, hw ⟩ ; rcases Ordinal.lt_omega0.1 hd with ⟨ i, rfl ⟩ ; exact ⟨ i, hw ⟩ ;
    · exact Ordinal.omega0_ne_zero

/-! ## The Omega-Squared Strategy Tree -/

/-- The omega-squared strategy tree: Eternity picks `n`, Mortal plays
    `omegaMulTree n`. -/
def omegaSqTree : StratTree := .play (fun n => omegaMulTree n)

/-
**Theorem (Mortal forces ω²)**: With bounded nondeterminism,
    Mortal's survival time reaches `ω²`.
-/
theorem rank_omegaSqTree : omegaSqTree.rank = omega0 ^ 2 := by
  rw [ sq, omegaSqTree, StratTree.rank_play ];
  refine' le_antisymm _ _ <;> norm_num [rank_omegaMulTree] at *;
  · refine' ciSup_le' _;
    intro i; rw [Order.succ_le_iff]; simp +decide;
  · refine' le_of_forall_lt fun x hx => _;
    -- Since $x < \omega \cdot \omega$, there exists some $n$ such that $x < \omega \cdot n$.
    obtain ⟨n, hn⟩ : ∃ n : ℕ, x < Ordinal.omega0 * n := by
      contrapose! hx;
      convert ciSup_le fun n => hx n using 1;
      exact Eq.symm (iSup_mul_natCast ω);
    exact lt_of_lt_of_le hn ( le_trans ( le_of_lt ( Order.lt_succ _ ) ) ( le_ciSup ( Ordinal.bddAbove_of_small _ ) n ) )

/-! ## Game-Theoretic Framework -/

/-- A Mortal-Eternity game position. Mortal has `k+1` choices;
    for each choice, Eternity responds from `ℕ`. -/
inductive GamePos : Type where
  | terminal : GamePos
  | active : (k : ℕ) → (Fin (k + 1) → ℕ → GamePos) → GamePos

/-- The game value: Mortal maximizes, Eternity minimizes survival time. -/
noncomputable def gameValue : GamePos → Ordinal
  | .terminal => 0
  | .active k f => ⨆ i : Fin (k + 1), ⨅ j : ℕ, gameValue (f i j) + 1

@[simp] theorem gameValue_terminal : gameValue GamePos.terminal = 0 := rfl

/-- Every strategy tree induces a single-choice game position. -/
def stratToGame : StratTree → GamePos
  | .done => .terminal
  | .play f => .active 0 (fun _ n => stratToGame (f n))

/-- The guaranteed survival of a strategy tree under worst-case
    Eternity play (infimum of child survivals). -/
noncomputable def guaranteedSurvival : StratTree → Ordinal
  | .done => 0
  | .play f => ⨅ n : ℕ, (f n).guaranteedSurvival + 1

/-
For constant-branching trees (like `depthTree`), the guaranteed
    survival equals the rank.
-/
theorem guaranteedSurvival_depthTree :
    ∀ n : ℕ, (depthTree n).guaranteedSurvival = (n : Ordinal) := by
  intro n;
  induction' n with n ih;
  · rfl;
  · convert congr_arg ( · + 1 ) ih using 1;
    exact ciInf_const

/-
Deterministic Mortal can achieve any finite game value.
-/
theorem deterministic_reaches_finite (n : ℕ) :
    ∃ pos : GamePos, gameValue pos ≥ (n : Ordinal) := by
  revert n;
  intro n; use stratToGame (depthTree n); induction n <;> simp_all +decide [ depthTree ] ;
  refine' lt_of_le_of_lt ‹_› _;
  refine' lt_of_lt_of_le _ ( le_ciSup _ ⟨ 0, Nat.succ_pos _ ⟩ ) <;> norm_num [ stratToGame ]

/-! ## Transfinite Game Certificates -/

/-- A game certificate witnesses that Mortal can survive at least `α` rounds. -/
structure GameCertificate (α : Ordinal.{0}) where
  tree : StratTree
  rank_ge : tree.rank ≥ α

theorem certificate_nat (n : ℕ) : Nonempty (GameCertificate (n : Ordinal)) :=
  ⟨⟨depthTree n, by rw [rank_depthTree]⟩⟩

theorem certificate_omega : Nonempty (GameCertificate omega0) :=
  ⟨⟨omegaTree, by rw [rank_omegaTree]⟩⟩

theorem certificate_omega_sq : Nonempty (GameCertificate (omega0 ^ 2)) :=
  ⟨⟨omegaSqTree, by rw [rank_omegaSqTree]⟩⟩

/-! ## ITTM Connection -/

/-- An ITTM computation stage. -/
structure ITTMStage where
  clock : Ordinal.{0}
  tape : ℕ → Bool
  halted : Bool

/-- The ITTM computation length induced by a strategy tree. -/
noncomputable def stratToITTMLength (t : StratTree) : Ordinal := t.rank

/-- ITTM length of the ω²-strategy equals ω². -/
theorem ittm_length_omega_sq :
    stratToITTMLength omegaSqTree = omega0 ^ 2 :=
  rank_omegaSqTree

/-! ## Conjecture -/

/-- Every ordinal below ω^ω is realizable as a strategy tree rank. -/
def universalRealizabilityBelow : Prop :=
  ∀ α : Ordinal.{0}, α < omega0 ^ omega0 → ∃ t : StratTree, t.rank = α

end StratTree