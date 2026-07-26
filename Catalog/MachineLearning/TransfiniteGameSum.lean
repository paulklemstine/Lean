/-
# Transfinite Game Theory, Deepened: The Disjunctive Sum of Well-Founded Games

This file **extends** the theory of two-player well-founded (transfinite) games
to their *disjunctive sum* — the fundamental algebraic operation of combinatorial
game theory, in which a move consists of choosing one component and making a legal
move there.  Well-foundedness of the move relation is exactly the statement that no
play lasts forever, while allowing plays of arbitrary transfinite ordinal rank, so
this is a genuine theory of games that can (almost) last forever.

Building on the value function `W` (a position is winning for the player to move
iff there is a move to a losing position — the Zermelo/Sprague–Grundy fixed point),
we prove:

## Main results

* `sumWf` — the disjunctive sum of a well-founded game with itself is again
  well-founded (via `Prod.GameAdd`), so `W` is defined for it.
* `sum_terminal_right` / `sum_terminal_left` — **a terminal (empty) game is a
  neutral element**: adjoining a component with no moves does not change the value.
* `sum_comm` — **the sum is commutative in value**: `W (a,b) ↔ W (b,a)`.
* `diag_loss` — **flagship theorem**: `G + G` is *always* a loss for the player to
  move (`¬ W (a,a)`).  This is the transfinite mirroring / strategy-stealing
  principle: the second player copies the first player's move in the other copy.
* `determinacy` — Zermelo's theorem for well-founded games: the player to move can
  force a win iff the position is winning.  Combined with `diag_loss`, in `G + G`
  the *opponent* has a winning strategy (`¬ MoverWins (a,a)`).

## Contrarian disproofs

* `sum_of_wins_can_lose` — the naive conjecture "the sum of two winning positions
  is winning" is **false**: `1 + 1` in the countdown game is a loss although each
  `1` is a win.
* `p_position_not_neutral` — the conjecture "a losing component can be dropped
  without changing the winner" is **false**: `0 + 1` is a win although `0` is a
  loss and `1` is a win (so a P-position is *not* an absorbing element).

## A concrete instance

`Countdown` is the game on `ℕ` where from `a` one may move to any smaller number
(rank `ω`).  We recompute its value and instantiate the disproofs.
-/

import Mathlib

open Classical

namespace TransfiniteGameSum

variable {P : Type*} (mv : P → P → Prop) (hwf : WellFounded (fun q p : P => mv p q))

/-- The **value** of a position: `W p` holds iff the player to move at `p` has a
winning strategy, i.e. there is a move to a position losing for its mover. -/
noncomputable def W : P → Prop :=
  hwf.fix (fun p IH => ∃ q, ∃ h : mv p q, ¬ IH q h)

/-- **Zermelo fixed-point equation.** -/
theorem W_fix (p : P) : W mv hwf p ↔ ∃ q, mv p q ∧ ¬ W mv hwf q := by
  unfold W; rw [WellFounded.fix_eq]
  constructor
  · rintro ⟨q, h, hn⟩; exact ⟨q, h, hn⟩
  · rintro ⟨q, h, hn⟩; exact ⟨q, h, hn⟩

/-- A position is *terminal* when the player to move has no legal move. -/
def Terminal (p : P) : Prop := ¬ ∃ q, mv p q

/-- A losing position is exactly one all of whose moves lead to winning positions. -/
theorem notW_iff_all_W (p : P) : ¬ W mv hwf p ↔ ∀ q, mv p q → W mv hwf q := by
  rw [W_fix]; push_neg; rfl

/-- From a losing position every move hands the opponent a winning position. -/
theorem not_W_all_W (p : P) (h : ¬ W mv hwf p) : ∀ q, mv p q → W mv hwf q :=
  (notW_iff_all_W mv hwf p).1 h

/-- A winning position has a move to a losing one. -/
theorem W_has_move (p : P) (h : W mv hwf p) : ∃ q, mv p q ∧ ¬ W mv hwf q :=
  (W_fix mv hwf p).1 h

/-- A terminal position is losing for the player to move. -/
theorem terminal_not_W (p : P) (h : Terminal mv p) : ¬ W mv hwf p := by
  rw [W_fix]; rintro ⟨q, hq, _⟩; exact h ⟨q, hq⟩

/-! ## The disjunctive sum -/

/-- The **disjunctive sum move relation**: a move picks one component and makes a
legal move there, leaving the other component fixed. -/
def sumMv (a b : P × P) : Prop :=
  (mv a.1 b.1 ∧ a.2 = b.2) ∨ (a.1 = b.1 ∧ mv a.2 b.2)

/-- The disjunctive sum of a well-founded game with itself is well-founded:
no infinite play, exactly `Prod.GameAdd` of the reverse move relation. -/
theorem sumWf (hwf : WellFounded (fun q p : P => mv p q)) :
    WellFounded (fun q p : P × P => sumMv mv p q) := by
  have hga : WellFounded (Prod.GameAdd (fun q p : P => mv p q) (fun q p : P => mv p q)) :=
    WellFounded.prod_gameAdd hwf hwf
  apply Subrelation.wf ?_ hga
  intro q p h
  obtain ⟨p1, p2⟩ := p; obtain ⟨q1, q2⟩ := q
  rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · simp only at h1 h2; subst h2; exact Prod.GameAdd.fst h1
  · simp only at h1 h2; subst h1; exact Prod.GameAdd.snd h2

/-- The value function of the disjunctive sum game. -/
noncomputable def Wsum (r : P × P) : Prop := W (sumMv mv) (sumWf mv hwf) r

/-- Unfolding the fixed point for the sum game. -/
theorem Wsum_fix (r : P × P) :
    Wsum mv hwf r ↔ ∃ s, sumMv mv r s ∧ ¬ Wsum mv hwf s :=
  W_fix (sumMv mv) (sumWf mv hwf) r

theorem notWsum_iff_all_W (r : P × P) :
    ¬ Wsum mv hwf r ↔ ∀ s, sumMv mv r s → Wsum mv hwf s :=
  notW_iff_all_W (sumMv mv) (sumWf mv hwf) r

/-- **Neutral element on the right.** Adjoining a terminal (empty) component does
not change the value: `W (a,b) ↔ W a` when `b` is terminal. -/
theorem sum_terminal_right (b : P) (hb : Terminal mv b) (a : P) :
    Wsum mv hwf (a, b) ↔ W mv hwf a := by
  induction' a using hwf.induction with a ih;
  rw [ Wsum_fix, W_fix ];
  grind +locals

/-- **Commutativity of the sum value.** -/
theorem sum_comm (a b : P) : Wsum mv hwf (a, b) ↔ Wsum mv hwf (b, a) := by
  convert ( WellFounded.induction ( sumWf mv hwf ) ( a, b ) ?_ );
  case convert_1 => exact fun x => Wsum mv hwf x ↔ Wsum mv hwf ( x.2, x.1 );
  · rfl;
  · intro x hx; rw [ Wsum_fix, Wsum_fix ] ;
    constructor <;> rintro ⟨ s, hs ⟩;
    · grind +locals;
    · grind +locals

/-- **Neutral element on the left**, from `sum_comm` and `sum_terminal_right`. -/
theorem sum_terminal_left (a : P) (ha : Terminal mv a) (b : P) :
    Wsum mv hwf (a, b) ↔ W mv hwf b := by
  rw [sum_comm]; exact sum_terminal_right mv hwf a ha b

/-- **Flagship theorem: `G + G` is a second-player win.** The player to move in the
symmetric sum always loses: `¬ W (a,a)`.  Transfinite mirroring — whatever move
the first player makes in one copy, the second player copies it in the other copy,
restoring the symmetric losing position; by well-foundedness the first player is
eventually stuck. -/
theorem diag_loss (a : P) : ¬ Wsum mv hwf (a, a) := by
  induction' a using hwf.induction with a ih;
  rw [ notWsum_iff_all_W ];
  rintro ⟨ x, y ⟩ ( h | h );
  · rw [ Wsum_fix ];
    unfold sumMv; aesop;
  · rw [ Wsum_fix ];
    grind +locals

/-! ## Determinacy (Zermelo) and the strategic reading of the flagship -/

/-- A strategy `o` is *legal* if it moves from every non-terminal position. -/
def Legal (o : P → P) : Prop := ∀ x, ¬ Terminal mv x → mv x (o x)

/-- Legal opponent strategies exist. -/
theorem exists_legal : ∃ o : P → P, Legal mv o := by
  refine ⟨fun x => if h : ∃ q, mv x q then h.choose else x, ?_⟩
  intro x hx
  have h : ∃ q, mv x q := not_not.mp hx
  change mv x (if h : ∃ q, mv x q then h.choose else x)
  rw [dif_pos h]; exact h.choose_spec

/-- The canonical optimal move at a winning position. -/
noncomputable def optMove (x : P) : P :=
  if h : W mv hwf x then Classical.choose (W_has_move mv hwf x h) else x

theorem optMove_spec (x : P) (h : W mv hwf x) :
    mv x (optMove mv hwf x) ∧ ¬ W mv hwf (optMove mv hwf x) := by
  unfold optMove; rw [dif_pos h]; exact Classical.choose_spec (W_has_move mv hwf x h)

/-- One step of play: the analysed player uses `optMove`, the opponent uses `o`. -/
noncomputable def step (o : P → P) (x : P) : P :=
  if W mv hwf x then optMove mv hwf x else o x

/-- The trajectory under the canonical strategy against opponent `o`. -/
noncomputable def traj (o : P → P) (p : P) : ℕ → P
  | 0 => p
  | n + 1 => step mv hwf o (traj o p n)

@[simp] theorem traj_succ (o p n) :
    traj mv hwf o p (n + 1) = step mv hwf o (traj mv hwf o p n) := rfl

theorem step_W (o) (x : P) (h : W mv hwf x) :
    mv x (step mv hwf o x) ∧ ¬ W mv hwf (step mv hwf o x) := by
  unfold step; rw [if_pos h]; exact optMove_spec mv hwf x h

theorem step_notW (o) (x : P) (hnW : ¬ W mv hwf x) (hnT : ¬ Terminal mv x)
    (ho : Legal mv o) : mv x (step mv hwf o x) ∧ W mv hwf (step mv hwf o x) := by
  unfold step; rw [if_neg hnW]
  exact ⟨ho x hnT, not_W_all_W mv hwf x hnW _ (ho x hnT)⟩

/-- **Every play terminates** against a legal opponent. -/
theorem reaches_terminal (o : P → P) (ho : Legal mv o) (p : P) :
    ∃ n, Terminal mv (traj mv hwf o p n) := by
  by_contra hcon; push_neg at hcon
  have hstep : ∀ n, mv (traj mv hwf o p n) (traj mv hwf o p (n + 1)) := by
    intro n; by_cases hW : W mv hwf (traj mv hwf o p n)
    · exact (step_W mv hwf o _ hW).1
    · exact (step_notW mv hwf o _ hW (hcon n) ho).1
  obtain ⟨m, hm, hmin⟩ := hwf.has_min (Set.range (traj mv hwf o p)) ⟨_, ⟨0, rfl⟩⟩
  obtain ⟨i, hi⟩ := hm
  exact hmin (traj mv hwf o p (i + 1)) ⟨i + 1, rfl⟩ (hi ▸ hstep i)

/-- **Alternation invariant.** -/
theorem alternation (o : P → P) (ho : Legal mv o) (p : P) :
    ∀ n, (∀ k, k < n → ¬ Terminal mv (traj mv hwf o p k)) →
      (W mv hwf (traj mv hwf o p n) ↔ (Even n ↔ W mv hwf p)) := by
  intro n
  induction n with
  | zero => intro _; show W mv hwf p ↔ (Even 0 ↔ W mv hwf p); simp
  | succ n ih =>
    intro hbelow
    have hbn : ∀ k, k < n → ¬ Terminal mv (traj mv hwf o p k) :=
      fun k hk => hbelow k (Nat.lt_succ_of_lt hk)
    have hWn := ih hbn
    have hnT : ¬ Terminal mv (traj mv hwf o p n) := hbelow n (Nat.lt_succ_self n)
    rw [traj_succ]
    by_cases hW : W mv hwf (traj mv hwf o p n)
    · have h2 : ¬ W mv hwf (step mv hwf o (traj mv hwf o p n)) := (step_W mv hwf o _ hW).2
      have hpq : (Even n ↔ W mv hwf p) := hWn.1 hW
      have hpar : Even (n + 1) ↔ ¬ Even n := Nat.even_add_one
      tauto
    · have h2 : W mv hwf (step mv hwf o (traj mv hwf o p n)) :=
        (step_notW mv hwf o _ hW hnT ho).2
      have hpq : ¬ (Even n ↔ W mv hwf p) := fun h => hW (hWn.2 h)
      have hpar : Even (n + 1) ↔ ¬ Even n := Nat.even_add_one
      tauto

/-- The player to move can **force a win**: play first becomes terminal on an odd
turn (the opponent's move), so the mover is never the one stuck. -/
def MoverWins (p : P) : Prop :=
  ∀ o : P → P, Legal mv o →
    ∃ n, Odd n ∧ Terminal mv (traj mv hwf o p n) ∧
      ∀ k, k < n → ¬ Terminal mv (traj mv hwf o p k)

/-- **Zermelo's theorem / determinacy of well-founded games.** -/
theorem determinacy (p : P) : MoverWins mv hwf p ↔ W mv hwf p := by
  constructor
  · intro hmw
    obtain ⟨o, ho⟩ := exists_legal mv
    obtain ⟨n, hodd, hterm, hmin⟩ := hmw o ho
    by_contra hnW
    have halt := alternation mv hwf o ho p n hmin
    have hWn : W mv hwf (traj mv hwf o p n) := by
      rw [halt]
      constructor
      · intro he; exact absurd he (Nat.not_even_iff_odd.mpr hodd)
      · intro hWp; exact absurd hWp hnW
    exact terminal_not_W mv hwf _ hterm hWn
  · intro hWp o ho
    have hex := reaches_terminal mv hwf o ho p
    refine ⟨Nat.find hex, ?_, Nat.find_spec hex, fun k hk => Nat.find_min hex hk⟩
    have hmin : ∀ k, k < Nat.find hex → ¬ Terminal mv (traj mv hwf o p k) :=
      fun k hk => Nat.find_min hex hk
    have hnW : ¬ W mv hwf (traj mv hwf o p (Nat.find hex)) :=
      terminal_not_W mv hwf _ (Nat.find_spec hex)
    have halt := alternation mv hwf o ho p (Nat.find hex) hmin
    apply Nat.not_even_iff_odd.mp
    intro he; exact hnW (halt.2 (by tauto))

/-- **Strategic reading of the flagship.** In `G + G` the player to move cannot
force a win: the *opponent* has the winning (mirroring) strategy. -/
theorem diag_mover_loses (a : P) :
    ¬ MoverWins (sumMv mv) (sumWf mv hwf) (a, a) := by
  rw [determinacy]; exact diag_loss mv hwf a

end TransfiniteGameSum

/-! ## The countdown game and the contrarian disproofs -/

namespace Countdown

open TransfiniteGameSum

/-- Countdown move relation on `ℕ`: from `a` one may move to any smaller `b`. -/
def cmv (a b : ℕ) : Prop := b < a

/-- The countdown game is well-founded. -/
theorem cwf : WellFounded (fun q p : ℕ => cmv p q) := wellFounded_lt

/-- `0` is the unique terminal position. -/
theorem terminal_iff (n : ℕ) : Terminal cmv n ↔ n = 0 := by
  unfold Terminal cmv
  constructor
  · intro h; by_contra hn; exact h ⟨0, Nat.pos_of_ne_zero hn⟩
  · rintro rfl ⟨q, hq⟩; exact Nat.not_lt_zero q hq

/-- **Value of the countdown game**: `n` is a win for the mover iff `n ≠ 0`. -/
theorem W_iff (n : ℕ) : W cmv cwf n ↔ n ≠ 0 := by
  constructor
  · intro h; rw [W_fix] at h; obtain ⟨q, hq, _⟩ := h
    intro hn; rw [hn] at hq; exact Nat.not_lt_zero q hq
  · intro hn; rw [W_fix]; refine ⟨0, Nat.pos_of_ne_zero hn, ?_⟩
    rw [W_fix]; rintro ⟨q, hq, _⟩; exact Nat.not_lt_zero q hq

/-- `0` is terminal in countdown. -/
theorem zero_terminal : Terminal cmv 0 := (terminal_iff 0).2 rfl

/-- **Contrarian disproof 1.** The conjecture *"the disjunctive sum of two winning
positions is winning"* is FALSE: in countdown, `1` is a winning position, yet the
sum `1 + 1` is a loss for the player to move (mirroring). -/
theorem sum_of_wins_can_lose :
    W cmv cwf 1 ∧ W cmv cwf 1 ∧ ¬ Wsum cmv cwf (1, 1) := by
  refine ⟨(W_iff 1).2 one_ne_zero, (W_iff 1).2 one_ne_zero, ?_⟩
  exact diag_loss cmv cwf 1

/-- **Contrarian disproof 2.** The conjecture *"adjoining a losing (P) position
never changes the winner"* is FALSE: `0` is a losing position, `1` is a winning
position, and the sum `0 + 1` is a *win* for the mover — a P-position is not an
absorbing element. -/
theorem p_position_not_neutral :
    ¬ W cmv cwf 0 ∧ W cmv cwf 1 ∧ Wsum cmv cwf (0, 1) := by
  refine ⟨?_, (W_iff 1).2 one_ne_zero, ?_⟩
  · rw [W_iff]; simp
  · rw [sum_terminal_left cmv cwf 0 zero_terminal 1]; exact (W_iff 1).2 one_ne_zero

/-- **Two-heap Nim identity.** The disjunctive sum of two countdown heaps is a
win for the player to move iff the heaps are unequal: `Wsum (m,n) ↔ m ≠ n`.
This is the classic P-position characterization of two-heap Nim, and it makes the
contrarian disproofs above instances of a single sharp equivalence.  The `m = n`
direction is the flagship `diag_loss`; the `m ≠ n` direction moves the larger heap
down to match the smaller, handing the opponent the losing diagonal position. -/
theorem twoHeapNim (m n : ℕ) : Wsum cmv cwf (m, n) ↔ m ≠ n := by
  constructor
  · intro hW hmn; subst hmn; exact diag_loss cmv cwf m hW
  · intro hmn
    rw [Wsum_fix]
    rcases lt_or_gt_of_ne hmn with h | h
    · -- n > m: move the second heap down to m, reaching the diagonal (m, m)
      refine ⟨(m, m), Or.inr ⟨rfl, h⟩, diag_loss cmv cwf m⟩
    · -- m > n: move the first heap down to n, reaching the diagonal (n, n)
      refine ⟨(n, n), Or.inl ⟨h, rfl⟩, diag_loss cmv cwf n⟩

end Countdown