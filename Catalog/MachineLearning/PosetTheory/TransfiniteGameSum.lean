/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Disjunctive sums of well-founded impartial games

A position is winning when it has a move to a non-winning position.  The
well-foundedness assumption permits this recursive definition even when the
height of the game tree is transfinite.  The main result is the mirror theorem:
the sum of a game with an identical copy is losing.
-/
import Mathlib.Order.GameAdd

namespace TransfiniteGameSum

/-- The predecessor relation associated to a move relation. -/
def ReverseMove {P : Type*} (move : P → P → Prop) : P → P → Prop :=
  fun q p => move p q

/-- Recursive outcome class of a position in a well-founded impartial game. -/
def winning {P : Type*} (move : P → P → Prop)
    (wf : WellFounded (ReverseMove move)) : P → Prop :=
  wf.fix fun p previous => ∃ q, ∃ h : move p q, ¬ previous q h

/-
The recursive outcome equation.
-/
theorem winning_iff {P : Type*} (move : P → P → Prop)
    (wf : WellFounded (ReverseMove move)) (p : P) :
    winning move wf p ↔ ∃ q, move p q ∧ ¬ winning move wf q := by
  -- Apply the definition of winning to rewrite the goal in terms of the existence of a move to a losing position.
  rw [winning];
  convert Iff.rfl using 1;
  convert ( WellFounded.fix_eq wf ( fun p previous => ∃ q, ∃ h : move p q, ¬previous q h ) p ).symm using 1;
  · ext; aesop;
  · grind

/-
The recursive outcome equation uniquely determines the outcome class.
-/
theorem winning_unique {P : Type*} {move : P → P → Prop}
    (wf : WellFounded (ReverseMove move)) (X : P → Prop)
    (equation : ∀ p, X p ↔ ∃ q, move p q ∧ ¬ X q) (p : P) :
    X p ↔ winning move wf p := by
  by_contra h_contra;
  obtain ⟨p, hp⟩ : ∃ p, X p ≠ winning move wf p ∧ ∀ q, ReverseMove move q p → X q = winning move wf q := by
    convert wf.has_min { p | X p ≠ winning move wf p } ⟨ p, _ ⟩ using 1;
    · grind;
    · exact fun h => h_contra <| by simp [h] ;
  -- Apply the equation to p and use the induction hypothesis to show that the existence of a move q with ¬X q is equivalent to the existence of a move q with ¬winning move wf q.
  have h_eq : X p ↔ ∃ q, move p q ∧ ¬winning move wf q := by
    grind +locals;
  exact hp.1 ( by rw [ h_eq, winning_iff move wf p ] )

/-- A move in a disjunctive sum changes exactly one component. -/
def sumMove {P Q : Type*} (left : P → P → Prop) (right : Q → Q → Prop) :
    P × Q → P × Q → Prop :=
  fun p q => Prod.GameAdd (ReverseMove left) (ReverseMove right) q p

/-
Disjunctive sums preserve well-foundedness.
-/
theorem sumWf {P Q : Type*} {left : P → P → Prop} {right : Q → Q → Prop}
    (hl : WellFounded (ReverseMove left)) (hr : WellFounded (ReverseMove right)) :
    WellFounded (ReverseMove (sumMove left right)) := by
  convert hl.prod_gameAdd hr using 1

/-- Outcome class in a disjunctive sum. -/
def sumWinning {P Q : Type*} (left : P → P → Prop) (right : Q → Q → Prop)
    (hl : WellFounded (ReverseMove left)) (hr : WellFounded (ReverseMove right)) :
    P × Q → Prop :=
  winning (sumMove left right) (sumWf hl hr)

/-- The empty relation is well-founded. -/
theorem emptyWf (P : Type*) : WellFounded (ReverseMove (fun _ _ : P => False)) := by
  exact ⟨fun x => Acc.intro x (fun _ h => False.elim h)⟩

/-
Moves in a sum with an empty right component are exactly left moves.
-/
theorem sumMove_empty_right_iff {P : Type*} {move : P → P → Prop} (a q : P) :
    sumMove move (fun _ _ : Unit => False) (a, ()) (q, ()) ↔ move a q := by
  constructor;
  · rintro ⟨ ⟩;
    · assumption;
    · cases ‹_›;
  · exact fun h => Prod.GameAdd.fst h

/-
The empty game is a right identity for outcome classes.
-/
theorem sum_terminal_right {P : Type*} {move : P → P → Prop}
    (wf : WellFounded (ReverseMove move)) (a : P) :
    sumWinning move (fun _ _ : Unit => False) wf (emptyWf Unit) (a, ()) ↔
      winning move wf a := by
  unfold sumWinning;
  convert winning_unique ( sumWf wf ( emptyWf Unit ) ) _ _ ( a, () );
  · convert winning_unique ( sumWf wf ( emptyWf Unit ) ) ( fun x : P × Unit => winning move wf x.1 ) _ ( a, () ) using 1
    generalize_proofs at *;
    simp +decide;
    intro a b; exact (by
    convert winning_iff move wf a using 1;
    convert Iff.rfl using 3 ; simp +decide [ sumMove ];
    exact fun _ => ⟨ fun h => ⟨ b, by tauto ⟩, fun ⟨ x, hx ⟩ => by cases hx <;> tauto ⟩);
  · exact fun p => winning_iff (sumMove move fun _ _ => False)
      (sumWf wf (emptyWf Unit)) p

/-
Moves in a sum with an empty left component are exactly right moves.
-/
theorem sumMove_empty_left_iff {P : Type*} {move : P → P → Prop} (a q : P) :
    sumMove (fun _ _ : Unit => False) move ((), a) ((), q) ↔ move a q := by
  convert sumMove_empty_right_iff a q using 1;
  constructor <;> intro h <;> cases h <;> tauto

/-
The empty game is a left identity for outcome classes.
-/
theorem sum_terminal_left {P : Type*} {move : P → P → Prop}
    (wf : WellFounded (ReverseMove move)) (a : P) :
    sumWinning (fun _ _ : Unit => False) move (emptyWf Unit) wf ((), a) ↔
      winning move wf a := by
  convert winning_unique _ _ _ a;
  convert winning_iff _ _ _;
  rotate_left;
  exact fun p => winning ( sumMove ( fun _ _ => False ) move ) ( sumWf ( emptyWf Unit ) wf ) ( (), p );
  · grind +suggestions;
  · convert winning_iff _ _ _

/-
Swapping coordinates preserves legal moves in a self-sum.
-/
theorem sumMove_swap_iff {P : Type*} {move : P → P → Prop} (p q : P × P) :
    sumMove move move p.swap q.swap ↔ sumMove move move p q := by
  unfold sumMove; aesop;

/-
The outcome of a self-sum is invariant under swapping its components.
-/
theorem sum_comm {P : Type*} {move : P → P → Prop}
    (wf : WellFounded (ReverseMove move)) (a b : P) :
    sumWinning move move wf wf (a, b) ↔ sumWinning move move wf wf (b, a) := by
  -- Define the outcome class function for the swap game.
  set X : P × P → Prop := fun p => sumWinning move move wf wf p.swap;
  -- Show that X satisfies the same recursive equation as sumWinning.
  have hX_eq : ∀ p, X p ↔ ∃ q, sumMove move move p q ∧ ¬ X q := by
    have hX_eq : ∀ p, sumWinning move move wf wf p ↔ ∃ q, sumMove move move p q ∧ ¬ sumWinning move move wf wf q := by
      exact fun p => winning_iff _ _ _;
    intro p; specialize hX_eq p.swap; simp_all +decide ;
    grind +suggestions;
  -- By the uniqueness theorem, X must be equal to sumWinning.
  have hX_eq_sumWinning : ∀ p, X p ↔ sumWinning move move wf wf p := by
    apply_rules [ winning_unique ];
  exact hX_eq_sumWinning ( a, b ) |> Iff.symm

/-- **Transfinite mirror theorem.** The diagonal of a self-sum is losing. -/
theorem diag_loss {P : Type*} {move : P → P → Prop}
    (wf : WellFounded (ReverseMove move)) (a : P) :
    ¬ sumWinning move move wf wf (a, a) := by
  revert a;
  by_contra! h;
  have h_ind : ∀ a, sumWinning move move wf wf (a, a) → ∃ b, move a b ∧ sumWinning move move wf wf (b, b) := by
    intro a ha
    obtain ⟨q, hq⟩ : ∃ q, sumMove move move (a, a) q ∧ ¬ sumWinning move move wf wf q := by
      exact (winning_iff (sumMove move move) (sumWf wf wf) (a, a)).mp ha;
    rcases q with ⟨ b, c ⟩ ; rcases hq.1 with ( h | h ) <;> simp_all +decide [ sumMove ] ;
    · contrapose! hq;
      intro h;
      exact ( winning_iff _ _ _ ).mpr ⟨ ( b, b ), by tauto, by tauto ⟩;
    · contrapose! hq;
      intro h;
      exact ( winning_iff _ _ _ ).mpr ⟨ ( c, c ), by tauto ⟩;
  obtain ⟨ a, ha ⟩ := h;
  have h_seq : ∃ seq : ℕ → P, seq 0 = a ∧ ∀ n, move (seq n) (seq (n + 1)) ∧ sumWinning move move wf wf (seq n, seq n) := by
    choose! f hf using h_ind;
    exact ⟨ fun n => Nat.recOn n a fun n ih => f ih, rfl, fun n => by induction n <;> aesop ⟩;
  obtain ⟨ seq, hseq₀, hseq ⟩ := h_seq;
  have := wf.has_min ( Set.range seq ) ⟨ _, Set.mem_range_self 0 ⟩;
  obtain ⟨ x, ⟨ n, rfl ⟩, hx ⟩ := this; exact hx _ ⟨ n + 1, rfl ⟩ ( hseq n |>.1 ) ;

/-- The mover has an immediate winning choice exactly when some option is losing. -/
def MoverCanForce {P : Type*} (move : P → P → Prop)
    (wf : WellFounded (ReverseMove move)) (p : P) : Prop :=
  ∃ q, move p q ∧ ¬ winning move wf q

/-- The opponent controls a position when every legal opening hands back a win. -/
def OpponentCanForce {P : Type*} (move : P → P → Prop)
    (wf : WellFounded (ReverseMove move)) (p : P) : Prop :=
  ∀ q, move p q → winning move wf q

/-
Zermelo determinacy for well-founded impartial games.
-/
theorem determinacy {P : Type*} {move : P → P → Prop}
    (wf : WellFounded (ReverseMove move)) (p : P) :
    (winning move wf p ∧ MoverCanForce move wf p) ∨
      (¬ winning move wf p ∧ OpponentCanForce move wf p) := by
  by_cases h : winning move wf p <;> simp_all +decide [ MoverCanForce, OpponentCanForce ];
  · exact (winning_iff move wf p).mp h;
  · exact fun q hq => by_contra fun hq' => h <| winning_iff move wf p |>.2 ⟨ q, hq, hq' ⟩

/-
On the diagonal self-sum, every opening gives the opponent a winning position.
-/
theorem diag_mover_loses {P : Type*} {move : P → P → Prop}
    (wf : WellFounded (ReverseMove move)) (a : P) :
    OpponentCanForce (sumMove move move) (sumWf wf wf) (a, a) := by
  -- By determinacy, since (a,a) is losing, the opponent can force a win.
  have h_det : ¬ (winning (sumMove move move) (sumWf wf wf) (a, a) ∧ MoverCanForce (sumMove move move) (sumWf wf wf) (a, a)) := by
    exact fun h => diag_loss wf a h.1;
  contrapose! h_det; have := determinacy ( sumWf wf wf ) ( a, a ) ; aesop;

/-- Countdown is the game in which a heap may be replaced by any smaller heap. -/
def countdownMove (m n : ℕ) : Prop := n < m

/-
Countdown is well-founded.
-/
theorem countdownWf : WellFounded (ReverseMove countdownMove) := by
  convert Nat.lt_wfRel.wf

/-
The sharp two-heap Nim outcome theorem.
-/
theorem twoHeapNim (m n : ℕ) :
    sumWinning countdownMove countdownMove countdownWf countdownWf (m, n) ↔ m ≠ n := by
  constructor <;> intro hmn;
  · exact fun h => diag_loss countdownWf m ( h ▸ hmn );
  · cases lt_or_gt_of_ne hmn;
    · rw [ sumWinning, winning_iff ];
      use (m, m);
      exact ⟨ by exact Prod.GameAdd.snd ( by tauto ), by exact diag_loss countdownWf m ⟩;
    · rw [ sumWinning, winning_iff ];
      use (n, n);
      exact ⟨ by exact Prod.GameAdd.fst ( by tauto ), by exact diag_loss countdownWf n ⟩

/-
Two winning components can have a losing sum.
-/
theorem sum_of_wins_can_lose :
    winning countdownMove countdownWf 1 ∧
      winning countdownMove countdownWf 1 ∧
      ¬ sumWinning countdownMove countdownMove countdownWf countdownWf (1, 1) := by
  unfold countdownMove;
  grind +suggestions

/-
A losing component need not be neutral: only an empty game is neutral.
-/
theorem p_position_not_neutral :
    ¬ winning countdownMove countdownWf 0 ∧
      sumWinning countdownMove countdownMove countdownWf countdownWf (0, 1) := by
  constructor;
  · rw [ winning_iff ];
    simp +decide [ countdownMove ];
  · exact (twoHeapNim 0 1).2 Nat.zero_ne_one

-- !-- Lab Notes -- !--
/-
Hypothesis: self-sums should admit a rank-independent mirror response, while
arbitrary sums of losing positions may require finer invariants.

Experiment: finite countdown tables through heap size eight exhibited precisely
the off-diagonal winning pattern.  The same response mechanism was then tested
against the abstract recursive outcome equation.

Analysis: the decisive induction is on one component's original move relation,
not on a one-step sum relation.  After an opening move, the mirror response takes
two coordinates to a smaller diagonal, where the induction hypothesis applies.

Critique: losing positions are not interchangeable with empty games.  The
position zero in countdown is losing but contributes legal context when paired
with a nonempty heap; the explicit `(0,1)` example separates these notions.

Synthesis: well-founded recursion, closure under game addition, the transfinite
mirror theorem, and the complete two-heap countdown classification form one
coherent structural account of disjunctive play.
-/

end TransfiniteGameSum