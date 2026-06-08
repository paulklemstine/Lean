/-
# Infinite Chess: Transfinite Game Values

We formalize the theory of two-player games with ordinal game values,
motivated by infinite chess positions where checkmate can require
transfinitely many moves.

## Mathematical Background

In infinite chess (chess on ℤ×ℤ), Evans and Hamkins (2014) showed that
game values of positions can be any countable ordinal. A position P has
game value v(P) = α if White can force checkmate in at most α moves,
and α is the smallest such ordinal.
-/
import Mathlib

open Ordinal

/-! ## Part 1: Abstract Game Trees with Ordinal Values -/

/-- A `WFGame` represents a well-founded two-player game.
  `Pos` is the type of positions.
  `moves` gives the set of positions reachable from a given position.
  `wf` ensures the game is well-founded (every play terminates). -/
structure WFGame where
  Pos : Type
  moves : Pos → Set Pos
  wf : WellFounded (fun q p => q ∈ moves p)

/-- The game value (ordinal rank) of a position in a well-founded game.
  Defined by transfinite recursion: value = sup of (succ of successor values). -/
noncomputable def WFGame.gameValue (G : WFGame) : G.Pos → Ordinal :=
  G.wf.fix fun p ih =>
    ⨆ q : { q // q ∈ G.moves p }, Order.succ (ih q.1 q.2)

/-
The game value satisfies its defining recursion.
-/
theorem WFGame.gameValue_eq (G : WFGame) (p : G.Pos) :
    G.gameValue p = ⨆ q : { q // q ∈ G.moves p }, Order.succ (G.gameValue q.1) := by
  convert G.wf.fix_eq _ p using 1

/-
A position with no moves has game value 0.
-/
theorem WFGame.gameValue_terminal (G : WFGame) (p : G.Pos)
    (h : G.moves p = ∅) : G.gameValue p = 0 := by
  convert gameValue_eq G p;
  convert ( ciSup_of_empty _ ) |> Eq.symm;
  grind +suggestions

/-
Game value is strictly greater than the value of any successor position.
-/
theorem WFGame.gameValue_lt_of_move (G : WFGame) {p q : G.Pos}
    (h : q ∈ G.moves p) : G.gameValue q < G.gameValue p := by
  convert Order.lt_succ ( G.gameValue q ) |> lt_of_lt_of_le <| ?_;
  convert le_ciSup ( show BddAbove ( Set.range fun x : { q // q ∈ G.moves p } => Order.succ ( G.gameValue x.1 ) ) from ?_ ) ⟨ q, h ⟩;
  · convert WFGame.gameValue_eq G p;
  · exact Ordinal.bddAbove_of_small _

/-! ## Part 2: Basic Game Constructions -/

/-- A game with exactly one terminal position. -/
def trivialGame : WFGame where
  Pos := Unit
  moves := fun _ => ∅
  wf := by
    constructor
    intro x; constructor
    intro y hy; exact absurd hy (by simp)

/-
The trivial game has value 0.
-/
theorem trivialGame_value : trivialGame.gameValue () = 0 := by
  convert WFGame.gameValue_terminal trivialGame () _;
  rfl

/-- A finite chain game: positions are {0, ..., n} with move i → i-1.
    Uses ℕ with a bound, terminal at 0. -/
def chainGame (n : ℕ) : WFGame where
  Pos := { k : ℕ // k ≤ n }
  moves := fun ⟨k, _⟩ =>
    if h : 0 < k then {⟨k - 1, by omega⟩}
    else ∅
  wf := by
    apply WellFounded.intro
    intro ⟨k, hk⟩
    induction k with
    | zero =>
      constructor; intro ⟨j, hj⟩ hmem
      dsimp at hmem; simp at hmem
    | succ m ih =>
      constructor; intro ⟨j, hj⟩ hmem
      dsimp at hmem; simp at hmem
      obtain rfl := hmem
      exact ih (by omega)

/-
In chainGame n, position k has value k.
-/
theorem chainGame_value_at (n k : ℕ) (hk : k ≤ n) :
    (chainGame n).gameValue ⟨k, hk⟩ = (k : Ordinal) := by
  induction' k with k ih generalizing n <;> simp_all +decide [ chainGame ];
  · convert WFGame.gameValue_terminal _ _ _ ; aesop;
  · rw [ ← ih n ( by linarith ), WFGame.gameValue_eq ];
    convert ciSup_eq_of_forall_le_of_forall_lt_exists_gt _ _ <;> norm_num

/-- The chain game of length n has value n at position n. -/
theorem chainGame_value (n : ℕ) :
    (chainGame n).gameValue ⟨n, le_refl n⟩ = (n : Ordinal) :=
  chainGame_value_at n n (le_refl n)

/-! ## Part 3: Ordinal Arithmetic for Game Values -/

/-- omega0 is the supremum of all natural numbers as ordinals. -/
theorem omega0_eq_iSup_nat : omega0 = ⨆ n : ℕ, (n : Ordinal) :=
  Ordinal.iSup_natCast.symm

/-- For any natural number n, n < ω. -/
theorem nat_lt_omega0' (n : ℕ) : (n : Ordinal) < omega0 :=
  Ordinal.nat_lt_omega0 n

/-- ω · 2 = ω + ω -/
theorem omega0_mul_two : omega0 * 2 = omega0 + omega0 := by
  have : (2 : Ordinal) = 1 + 1 := by norm_num
  rw [this, mul_add, mul_one]

/-- ω² = ω · ω -/
theorem omega0_sq : omega0 ^ 2 = omega0 * omega0 := by
  rw [sq]

/-
ω is a limit ordinal: it is not a successor.
-/
theorem omega0_not_succ : ∀ α : Ordinal, omega0 ≠ Order.succ α := by
  intro α h; have := congr_arg Ordinal.card h; norm_num at this;
  contrapose! this;
  refine' ne_of_gt _;
  refine' Cardinal.add_lt_aleph0 _ _ <;> aesop

/-
ω^ω is strictly greater than ω^n for any finite n.
-/
theorem omega0_pow_omega0_gt_pow_nat (n : ℕ) :
    omega0 ^ (n : Ordinal) < omega0 ^ omega0 := by
  refine' lt_of_le_of_lt _ ( Ordinal.opow_lt_opow_iff_right ( by { exact Ordinal.one_lt_omega0 } ) |>.2 _ );
  convert le_rfl
  exact nat_lt_omega0' n

/-
ω^ω is the supremum of ω^n over all natural numbers n.
-/
theorem omega0_pow_omega0_eq_iSup :
    omega0 ^ omega0 = ⨆ n : ℕ, omega0 ^ (n : Ordinal) := by
  refine' le_antisymm _ _;
  · refine' le_of_forall_lt fun x hx => _;
    rw [ Ordinal.lt_iSup_iff ];
    contrapose! hx;
    rw [ Ordinal.opow_le_iff_le_log ] <;> norm_num;
    · refine' le_of_forall_lt fun y hy => _;
      refine' lt_of_lt_of_le _ ( Ordinal.le_log_of_opow_le ( by norm_num ) ( hx ( Nat.find ( show ∃ n : ℕ, y < ( n : Ordinal ) from by rcases Ordinal.lt_omega0.1 hy with ⟨ n, rfl ⟩ ; exact ⟨ n + 1, by simp +decide ⟩ ) ) ) );
      grind;
    · exact ne_of_gt ( lt_of_lt_of_le ( by simp +decide ) ( hx 1 ) );
  · refine' ciSup_le' fun n => _;
    exact_mod_cast Ordinal.opow_le_opow_right Ordinal.omega0_pos ( Ordinal.nat_lt_omega0 n |> le_of_lt )

/-! ## Part 4: Cross-Domain Bridge — Game Trees ↔ Well-Founded Order Rank

This section establishes the fundamental correspondence between
game-theoretic complexity (how many moves to force a win) and
order-theoretic rank (height of a well-ordered structure).
This bridge connects combinatorial game theory to set theory. -/

/-- The ordinal rank of a well-founded relation at a point. -/
noncomputable def wfRank {α : Type} {r : α → α → Prop} (wf : WellFounded r) : α → Ordinal :=
  wf.fix fun a ih => ⨆ b : { b // r b a }, Order.succ (ih b.1 b.2)

/-
The rank function equals the game value.
-/
theorem wfRank_eq_gameValue (G : WFGame) (p : G.Pos) :
    wfRank G.wf p = G.gameValue p := by
  convert rfl

/-- A well-founded tree: rooted tree where every descending path terminates. -/
structure WFTree where
  Node : Type
  root : Node
  children : Node → Set Node
  wf : WellFounded (fun c p => c ∈ children p)

/-- Height of a well-founded tree = ordinal rank at the root. -/
noncomputable def WFTree.height (T : WFTree) : Ordinal :=
  wfRank T.wf T.root

/-- Every well-founded game induces a well-founded tree from any position. -/
def WFGame.toTree (G : WFGame) (start : G.Pos) : WFTree where
  Node := G.Pos
  root := start
  children := G.moves
  wf := G.wf

/-
The height of the game tree equals the game value.
-/
theorem WFGame.tree_height_eq_gameValue (G : WFGame) (p : G.Pos) :
    (G.toTree p).height = G.gameValue p := by
  convert wfRank_eq_gameValue G p using 1

/-! ## Part 5: Existence of Games with Prescribed Ordinal Values -/

/-
For any natural number n, there exists a game with game value n.
-/
theorem exists_game_value_nat (n : ℕ) :
    ∃ G : WFGame, ∃ p : G.Pos, G.gameValue p = (n : Ordinal) := by
  exact ⟨ chainGame n, ⟨ n, le_refl n ⟩, chainGame_value n ⟩

/-
**Bridge to Order Theory**: The game value is order-reversing
    on the reachability relation.
-/
theorem gameValue_antitone (G : WFGame) {p q : G.Pos}
    (h : q ∈ G.moves p) :
    G.gameValue q < G.gameValue p :=
  WFGame.gameValue_lt_of_move G h

/-! ## Part 6: Ordinal Game Construction -/

/-- The ordinal game: given an ordinal α, construct a WFGame whose positions
    are the elements of α.out and whose moves go to smaller elements.
    The game value at position p equals typein p. -/
noncomputable def ordinalGame (α : Ordinal.{0}) : WFGame where
  Pos := α.out.α
  moves := fun p => { q | α.out.r q p }
  wf := α.out.wo.wf

/-
The game value of ordinalGame at position p equals the typein of p.
-/
theorem ordinalGame_gameValue (α : Ordinal.{0}) (p : α.out.α) :
    (ordinalGame α).gameValue p = Ordinal.typein α.out.r p := by
  -- By induction on the game value, we can show that the game value at position p is � equal� to� the typein of p.
  have h_ind : ∀ p, (ordinalGame α).gameValue p = typein (Quotient.out α).r p := by
    -- Apply induction on the well-founded relation to show that the game value equals the typein function.
    have h_ind : WellFounded (fun c p => c ∈ (ordinalGame α).moves p) := by
      exact α.out.wo.wf;
    refine' h_ind.fix _;
    intro x hx; rw [ WFGame.gameValue_eq ] ; simp +decide [ hx ] ;
    refine' le_antisymm _ _;
    · refine' ciSup_le' _;
      aesop;
    · have h_exists_q : ∀ β < typein (Quotient.out α).r x, ∃ q : { q : (Quotient.out α).α // q ∈ (ordinalGame α).moves x }, β < Order.succ (typein (Quotient.out α).r q.1) := by
        intro β hβ
        obtain ⟨q, hq⟩ : ∃ q : (Quotient.out α).α, (typein (Quotient.out α).r) q = β := by
          apply Ordinal.typein_surj;
          exact hβ.trans_le ( le_of_lt ( Ordinal.typein_lt_type _ _ ) );
        use ⟨q, by
          exact Ordinal.typein_lt_typein ( Quotient.out α ).r |>.1 ( by aesop )⟩
        generalize_proofs at *;
        aesop;
      contrapose! h_exists_q;
      exact ⟨ _, h_exists_q, fun q => le_ciSup ( Ordinal.bddAbove_of_small _ ) q ⟩;
  exact h_ind p

/-
For any ordinal β < α, there is a position in ordinalGame α with value β.
-/
theorem ordinalGame_realizes (α β : Ordinal.{0}) (hβ : β < α) :
    ∃ p : (ordinalGame α).Pos, (ordinalGame α).gameValue p = β := by
  constructor;
  rw [ ordinalGame_gameValue, Ordinal.typein_enum ];
  convert hβ using 1;
  convert Quotient.out_eq α

/-! ## Part 7: The Transfinite Chess Hierarchy

**Theorem**: For every natural number n, there exists a well-founded game whose
game value at some position equals exactly ω^n.

Testable prediction: For n=0 the value is 1, for n=1 the value is ω.
A disproof would show that some ω^n cannot be a game value. -/

theorem transfinite_hierarchy_conjecture (n : ℕ) :
    ∃ G : WFGame, ∃ p : G.Pos, G.gameValue p = (omega0 ^ (n : Ordinal.{0}) : Ordinal.{0}) := by
  exact ⟨ordinalGame (Order.succ (omega0 ^ (n : Ordinal))),
         ordinalGame_realizes (Order.succ (omega0 ^ (n : Ordinal))) (omega0 ^ (n : Ordinal)) (Order.lt_succ _)⟩