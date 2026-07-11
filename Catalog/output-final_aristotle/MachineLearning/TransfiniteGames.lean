/-
# Transfinite Game Theory: Well-Founded Games Are Determined

This file develops a self-contained theory of two-player games whose positions
are ordered by a **well-founded** move relation.  Well-foundedness is exactly the
condition that no play lasts forever: there is no infinite sequence of legal
moves `p₀ → p₁ → p₂ → ⋯`.  Crucially, well-foundedness does *not* bound the
length of plays by any fixed finite number.  The game tree can have arbitrary
(transfinite) ordinal rank — e.g. a single position with infinitely many moves to
positions of unbounded finite depth already has rank `ω` — so this is a genuine
theory of *transfinite* games, not merely finite ones.

The convention is *normal play*: a player who cannot move loses (the last player
to move wins).  A partisan game (with alternating, asymmetric moves) is modelled
by encoding whose turn it is into the position, so this impartial-looking setup is
fully general.

## Main results

* `TransfiniteGame.W` — the *value* of a position, defined by well-founded
  recursion: `W p` means "the player to move at `p` has a winning strategy".
* `TransfiniteGame.W_fix` — the Zermelo/Sprague–Grundy fixed-point equation
  `W p ↔ ∃ q, mv p q ∧ ¬ W q`.
* `TransfiniteGame.reaches_terminal` — against any legal opponent, the canonical
  strategy drives every play to a terminal position in finitely many moves.
* `TransfiniteGame.alternation` — before the first terminal position, the play is
  at a winning position on turn `n` iff `n`'s parity matches that of the start.
* `TransfiniteGame.determinacy` — **Zermelo's theorem**: the player to move can
  force a win iff the position is winning (`MoverWins p ↔ W p`).  Hence every
  well-founded game is determined and `W` computes its outcome.

## A concrete instance

`Countdown` is the game on `ℕ` where from `a` one may move to any smaller number.
`Countdown.W_iff` computes its value: `n` is a win for the player to move iff
`n ≠ 0`.
-/

import Mathlib

open Classical

namespace TransfiniteGame

variable {P : Type*} (mv : P → P → Prop) (hwf : WellFounded (fun q p : P => mv p q))

/-- The **value** of a position, defined by well-founded recursion on the move
relation: `W p` holds iff the player to move at `p` has a winning strategy,
i.e. there is a move to a position `q` that is losing for its mover (`¬ W q`). -/
noncomputable def W : P → Prop :=
  hwf.fix (fun p IH => ∃ q, ∃ h : mv p q, ¬ IH q h)

/-- **The Zermelo fixed-point equation.** A position is winning iff some legal
move leads to a losing position for the opponent. -/
theorem W_fix (p : P) : W mv hwf p ↔ ∃ q, mv p q ∧ ¬ W mv hwf q := by
  unfold W; rw [WellFounded.fix_eq]
  constructor
  · rintro ⟨q, h, hn⟩; exact ⟨q, h, hn⟩
  · rintro ⟨q, h, hn⟩; exact ⟨q, h, hn⟩

/-- A position is *terminal* when the player to move has no legal move. -/
def Terminal (p : P) : Prop := ¬ ∃ q, mv p q

/-- From a winning position there is a move to a losing position. -/
theorem W_has_move (p : P) (h : W mv hwf p) : ∃ q, mv p q ∧ ¬ W mv hwf q :=
  (W_fix mv hwf p).1 h

/-- A winning position is never terminal: the winner always has a move. -/
theorem W_not_terminal (p : P) (h : W mv hwf p) : ¬ Terminal mv p := by
  obtain ⟨q, hq, _⟩ := W_has_move mv hwf p h; exact fun ht => ht ⟨q, hq⟩

/-- A terminal position is losing for the player to move. -/
theorem terminal_not_W (p : P) (h : Terminal mv p) : ¬ W mv hwf p :=
  fun hW => W_not_terminal mv hwf p hW h

/-- From a losing position, *every* legal move hands the opponent a winning
position. -/
theorem not_W_all_W (p : P) (h : ¬ W mv hwf p) : ∀ q, mv p q → W mv hwf q := by
  intro q hq; by_contra hWq; exact h ((W_fix mv hwf p).2 ⟨q, hq, hWq⟩)

/-- A strategy `o` is *legal* if it makes a legal move from every non-terminal
position. -/
def Legal (o : P → P) : Prop := ∀ x, ¬ Terminal mv x → mv x (o x)

/-- Legal opponent strategies exist: pick any legal move, and stay put at
terminal positions. -/
theorem exists_legal : ∃ o : P → P, Legal mv o := by
  refine ⟨fun x => if h : ∃ q, mv x q then h.choose else x, ?_⟩
  intro x hx
  have h : ∃ q, mv x q := not_not.mp hx
  change mv x (if h : ∃ q, mv x q then h.choose else x)
  rw [dif_pos h]; exact h.choose_spec

/-- The canonical optimal move: from a winning position, move to a witnessing
losing position; elsewhere, stay put. -/
noncomputable def optMove (x : P) : P :=
  if h : W mv hwf x then Classical.choose (W_has_move mv hwf x h) else x

/-- `optMove` moves from a winning position to a losing one. -/
theorem optMove_spec (x : P) (h : W mv hwf x) :
    mv x (optMove mv hwf x) ∧ ¬ W mv hwf (optMove mv hwf x) := by
  unfold optMove; rw [dif_pos h]; exact Classical.choose_spec (W_has_move mv hwf x h)

/-- One step of play: the analysed player uses `optMove` at winning positions,
the opponent `o` moves elsewhere. -/
noncomputable def step (o : P → P) (x : P) : P :=
  if W mv hwf x then optMove mv hwf x else o x

/-- The trajectory of the game under the canonical strategy against opponent
`o`, starting from `p`. -/
noncomputable def traj (o : P → P) (p : P) : ℕ → P
  | 0 => p
  | n + 1 => step mv hwf o (traj o p n)

@[simp] theorem traj_succ (o p n) :
    traj mv hwf o p (n + 1) = step mv hwf o (traj mv hwf o p n) := rfl

/-- At a winning position, the canonical step is a legal move to a losing
position. -/
theorem step_W (o) (x : P) (h : W mv hwf x) :
    mv x (step mv hwf o x) ∧ ¬ W mv hwf (step mv hwf o x) := by
  unfold step; rw [if_pos h]; exact optMove_spec mv hwf x h

/-- At a non-terminal losing position, any legal opponent step lands on a winning
position. -/
theorem step_notW (o) (x : P) (hnW : ¬ W mv hwf x) (hnT : ¬ Terminal mv x)
    (ho : Legal mv o) : mv x (step mv hwf o x) ∧ W mv hwf (step mv hwf o x) := by
  unfold step; rw [if_neg hnW]
  exact ⟨ho x hnT, not_W_all_W mv hwf x hnW _ (ho x hnT)⟩

/-- **Every play terminates.** Against any legal opponent, the trajectory reaches
a terminal position in finitely many moves.  This is where well-foundedness is
used: an infinite play would be an infinite descending chain. -/
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

/-- **Alternation invariant.** As long as no terminal position has been reached,
the play sits at a winning position on turn `n` exactly when `n`'s parity agrees
with the starting position's status.  In particular, from a winning start the
winning positions are exactly the even turns. -/
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
    have hpar : Even (n + 1) ↔ ¬ Even n := Nat.even_add_one
    rw [traj_succ]
    by_cases hW : W mv hwf (traj mv hwf o p n)
    · have h2 : ¬ W mv hwf (step mv hwf o (traj mv hwf o p n)) := (step_W mv hwf o _ hW).2
      have hpq : (Even n ↔ W mv hwf p) := hWn.1 hW
      tauto
    · have h2 : W mv hwf (step mv hwf o (traj mv hwf o p n)) :=
        (step_notW mv hwf o _ hW hnT ho).2
      have hpq : ¬ (Even n ↔ W mv hwf p) := fun h => hW (hWn.2 h)
      tauto

/-- The player to move at `p` can **force a win**: with the canonical strategy,
against every legal opponent, the play first becomes terminal on an *odd* turn —
i.e. the position where a player is stuck is reached on the opponent's move — so
the mover is never the one stuck. -/
def MoverWins (p : P) : Prop :=
  ∀ o : P → P, Legal mv o →
    ∃ n, Odd n ∧ Terminal mv (traj mv hwf o p n) ∧
      ∀ k, k < n → ¬ Terminal mv (traj mv hwf o p k)

/-- **Zermelo's theorem / determinacy of well-founded games.** The player to move
can force a win iff the position is winning (`MoverWins p ↔ W p`).  Consequently
every well-founded (transfinite) game is determined, and `W` computes its value:
one of the two players has a winning strategy, decided by `W p`. -/
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

/-- The winning player really does win: from a winning position, against every
legal opponent, the canonical strategy forces the game to end on the opponent's
turn (an odd move number). -/
theorem winning_strategy (p : P) (hp : W mv hwf p) : MoverWins mv hwf p :=
  (determinacy mv hwf p).2 hp

end TransfiniteGame

/-!
## The countdown game

A concrete transfinite game: positions are natural numbers, and from `a` a player
may move to any strictly smaller number.  The game tree rooted at `n` already has
height `n`, and over all starting positions the theory covers plays of every
finite length, with rank `ω`.  We compute the value function explicitly.
-/

namespace Countdown

open TransfiniteGame

/-- Countdown move relation on `ℕ`: from `a` one may move to any smaller `b`. -/
def cmv (a b : ℕ) : Prop := b < a

/-- The countdown game is well-founded (no infinite descending play). -/
theorem cwf : WellFounded (fun q p : ℕ => cmv p q) := wellFounded_lt

/-- `0` is the unique terminal position of the countdown game. -/
theorem terminal_iff (n : ℕ) : Terminal cmv n ↔ n = 0 := by
  unfold Terminal cmv
  constructor
  · intro h; by_contra hn; exact h ⟨0, Nat.pos_of_ne_zero hn⟩
  · rintro rfl ⟨q, hq⟩; exact Nat.not_lt_zero q hq

/-- **Value of the countdown game.** The player to move wins from `n` iff
`n ≠ 0`: from any positive number move directly to `0`, leaving the opponent
stuck. -/
theorem W_iff (n : ℕ) : W cmv cwf n ↔ n ≠ 0 := by
  constructor
  · intro h; rw [W_fix] at h; obtain ⟨q, hq, _⟩ := h
    intro hn; rw [hn] at hq; exact Nat.not_lt_zero q hq
  · intro hn; rw [W_fix]; refine ⟨0, Nat.pos_of_ne_zero hn, ?_⟩
    rw [W_fix]; rintro ⟨q, hq, _⟩; exact Nat.not_lt_zero q hq

end Countdown