import Mathlib

/-!
# Uniform Nash equilibria of finite games with constant strategy sums

This file *deepens* the "Sperner ⇒ Nash" development.  The earlier work established
the algebraic core of finite two–player games (mixed strategies, expected payoffs,
the pure–deviation principle) and verified two concrete games (Matching Pennies and
the Prisoner's Dilemma).  Here we go from *concrete examples* to a *general theorem*:

> **Uniform–equilibrium criterion.**  In a finite two–player game, if each row of
> player 1's payoff matrix has the same total `S1`, and each column of player 2's
> payoff matrix has the same total `S2`, then the *uniform* profile
> `(unif I, unif J)` is a Nash equilibrium, with value `S1 / |J|` to player 1 and
> `S2 / |I|` to player 2.

Against a uniformly randomising opponent, every pure strategy of a "row–constant"
player yields exactly the same payoff, so *every* strategy is a best response — in
particular the uniform one.  This is the finite, combinatorial analogue of the
symmetry argument behind mixed equilibria of symmetric games.

We then instantiate the criterion to obtain, as corollaries in a single stroke:

* Matching Pennies (`matchingPennies_uniform_isNash`),
* Rock–Paper–Scissors (`rps_uniform_isNash`), and
* a whole *parametric family* of cyclic zero–sum games on `ZMod n`
  (`cyclicGame_uniform_isNash`), for **any** payoff generator summing to zero — of
  which Matching Pennies (`n = 2`) and Rock–Paper–Scissors (`n = 3`) are special
  cases, together with the fact that the game value is `0` (`cyclicGame_value`).

## Main results

* `SpernerNashDeep.isNash_of_pure` — pure–deviation principle (chain foundation).
* `SpernerNashDeep.E1_pure_unif` / `E2_pure_unif` — pure payoff vs. a uniform
  opponent is the (normalised) row / column sum.
* `SpernerNashDeep.uniform_isNash_of_row_sum_const` — the general criterion.
* `SpernerNashDeep.E1_value_uniform` / `E2_value_uniform` — the equilibrium value.
* `SpernerNashDeep.cyclicGame_uniform_isNash` / `cyclicGame_value` — the cyclic
  family, its uniform equilibrium and its value.
* `SpernerNashDeep.matchingPennies_uniform_isNash`,
  `SpernerNashDeep.rps_uniform_isNash` — classical special cases.
-/

namespace SpernerNashDeep

open Finset

/-- A finite two–player game: finite strategy sets `I`, `J` and real payoff
matrices `u1`, `u2`. -/
structure FinGame (I J : Type*) [Fintype I] [Fintype J] where
  /-- Payoff to player 1 at the pure profile `(i, j)`. -/
  u1 : I → J → ℝ
  /-- Payoff to player 2 at the pure profile `(i, j)`. -/
  u2 : I → J → ℝ

variable {I J : Type*} [Fintype I] [Fintype J]

/-- A mixed strategy: a probability distribution over a strategy set. -/
def IsDist (p : I → ℝ) : Prop := (∀ i, 0 ≤ p i) ∧ ∑ i, p i = 1

/-- The pure strategy `a` viewed as a degenerate mixed strategy. -/
def pureDist [DecidableEq I] (a : I) : I → ℝ := fun i => if i = a then 1 else 0

/-- Expected payoff to player 1 under the mixed profile `(p, q)`. -/
def E1 (G : FinGame I J) (p : I → ℝ) (q : J → ℝ) : ℝ :=
  ∑ i, ∑ j, p i * q j * G.u1 i j

/-- Expected payoff to player 2 under the mixed profile `(p, q)`. -/
def E2 (G : FinGame I J) (p : I → ℝ) (q : J → ℝ) : ℝ :=
  ∑ i, ∑ j, p i * q j * G.u2 i j

/-- A profile `(p, q)` is a **Nash equilibrium**. -/
def IsNash (G : FinGame I J) (p : I → ℝ) (q : J → ℝ) : Prop :=
  IsDist p ∧ IsDist q ∧
    (∀ p', IsDist p' → E1 G p' q ≤ E1 G p q) ∧
    (∀ q', IsDist q' → E2 G p q' ≤ E2 G p q)

/-! ### Algebraic core (pure–deviation principle) -/

/-- The pure strategy distribution is a probability distribution. -/
theorem pureDist_isDist [DecidableEq I] (a : I) : IsDist (pureDist a) := by
  exact ⟨ fun _ ↦ by unfold pureDist; split_ifs <;> norm_num,
    by unfold pureDist; rw [ Finset.sum_eq_single a ] <;> aesop ⟩

/-- Player 1's expected payoff against `q` when playing pure strategy `a`. -/
theorem E1_pure [DecidableEq I] (G : FinGame I J) (a : I) (q : J → ℝ) :
    E1 G (pureDist a) q = ∑ j, q j * G.u1 a j := by
  unfold E1 pureDist
  rw [ Finset.sum_eq_single a ] <;> simp +contextual

/-- Player 2's expected payoff against `p` when playing pure strategy `b`. -/
theorem E2_pure [DecidableEq J] (G : FinGame I J) (p : I → ℝ) (b : J) :
    E2 G p (pureDist b) = ∑ i, p i * G.u2 i b := by
  unfold E2 pureDist
  simp +decide

/-- Linearity of `E1` in player 1's strategy. -/
theorem E1_linear_pure [DecidableEq I] (G : FinGame I J) (p' : I → ℝ) (q : J → ℝ) :
    E1 G p' q = ∑ i, p' i * E1 G (pureDist i) q := by
  simp only [E1_pure]
  simp +decide [ E1, Finset.mul_sum _ _ _, mul_assoc ]

/-- Linearity of `E2` in player 2's strategy. -/
theorem E2_linear_pure [DecidableEq J] (G : FinGame I J) (p : I → ℝ) (q' : J → ℝ) :
    E2 G p q' = ∑ j, q' j * E2 G p (pureDist j) := by
  simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, E2, pureDist ]
  exact Finset.sum_comm

/-- If no pure deviation of player 1 beats `p`, then no mixed deviation does. -/
theorem E1_le_of_pure_le [DecidableEq I] (G : FinGame I J) (p q : I → ℝ) (r : J → ℝ)
    (hpure : ∀ a, E1 G (pureDist a) r ≤ E1 G p r)
    (hq : IsDist q) : E1 G q r ≤ E1 G p r := by
  rw [ E1_linear_pure ]
  exact le_trans
    ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hpure i ) ( hq.1 i ) )
    ( by simp +decide [ ← Finset.sum_mul, hq.2 ] )

/-- If no pure deviation of player 2 beats `q`, then no mixed deviation does. -/
theorem E2_le_of_pure_le [DecidableEq J] (G : FinGame I J) (p : I → ℝ) (q q' : J → ℝ)
    (hpure : ∀ b, E2 G p (pureDist b) ≤ E2 G p q)
    (hq' : IsDist q') : E2 G p q' ≤ E2 G p q := by
  convert Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left ( hpure j ) ( hq'.1 j ) using 1
  convert E2_linear_pure G p q'
  rw [ ← Finset.sum_mul _ _ _, hq'.2, one_mul ]

/-- **Pure–deviation principle.**  A profile of distributions is a Nash equilibrium
provided neither player can gain by deviating to a *pure* strategy. -/
theorem isNash_of_pure [DecidableEq I] [DecidableEq J] (G : FinGame I J)
    (p : I → ℝ) (q : J → ℝ) (hp : IsDist p) (hq : IsDist q)
    (h1 : ∀ a, E1 G (pureDist a) q ≤ E1 G p q)
    (h2 : ∀ b, E2 G p (pureDist b) ≤ E2 G p q) :
    IsNash G p q :=
  ⟨hp, hq,
    fun p' hp' => E1_le_of_pure_le G p p' q h1 hp',
    fun q' hq' => E2_le_of_pure_le G p q q' h2 hq'⟩

/-! ### The uniform strategy -/

/-- The uniform mixed strategy on a finite strategy set. -/
noncomputable def unif (I : Type*) [Fintype I] : I → ℝ := fun _ => 1 / (Fintype.card I : ℝ)

/-- The uniform strategy is a probability distribution (on a nonempty set). -/
theorem unif_isDist [Nonempty I] : IsDist (unif I) := by
  refine ⟨fun i => by unfold unif; exact div_nonneg zero_le_one (by positivity), ?_⟩
  simp only [unif]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have : (Fintype.card I : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  field_simp

/-- Player 1's payoff of the pure strategy `a` against a uniform opponent is the
normalised `a`-th row sum. -/
theorem E1_pure_unif [DecidableEq I] (G : FinGame I J) (a : I) :
    E1 G (pureDist a) (unif J) = (∑ j, G.u1 a j) / (Fintype.card J : ℝ) := by
  rw [E1_pure]
  simp only [unif, ← Finset.mul_sum]
  ring

/-- Player 2's payoff of the pure strategy `b` against a uniform opponent is the
normalised `b`-th column sum. -/
theorem E2_pure_unif [DecidableEq J] (G : FinGame I J) (b : J) :
    E2 G (unif I) (pureDist b) = (∑ i, G.u2 i b) / (Fintype.card I : ℝ) := by
  rw [E2_pure]
  simp only [unif, ← Finset.mul_sum]
  ring

/-! ### The uniform–equilibrium criterion -/

/-- Player 1's value at the uniform profile equals `S1 / |J|` when every row sums
to `S1`. -/
theorem E1_value_uniform [DecidableEq I] [Nonempty I] (G : FinGame I J) (S1 : ℝ)
    (h1 : ∀ a, ∑ j, G.u1 a j = S1) :
    E1 G (unif I) (unif J) = S1 / (Fintype.card J : ℝ) := by
  rw [E1_linear_pure]
  simp only [E1_pure_unif, h1]
  rw [← Finset.sum_mul, (unif_isDist).2, one_mul]

/-- Player 2's value at the uniform profile equals `S2 / |I|` when every column
sums to `S2`. -/
theorem E2_value_uniform [DecidableEq J] [Nonempty J] (G : FinGame I J) (S2 : ℝ)
    (h2 : ∀ b, ∑ i, G.u2 i b = S2) :
    E2 G (unif I) (unif J) = S2 / (Fintype.card I : ℝ) := by
  rw [E2_linear_pure]
  simp only [E2_pure_unif, h2]
  rw [← Finset.sum_mul, (unif_isDist).2, one_mul]

/-- **Uniform–equilibrium criterion.**  If every row of player 1's matrix has the
same sum `S1` and every column of player 2's matrix has the same sum `S2`, then the
uniform profile is a Nash equilibrium.  (Against a uniform opponent every pure
strategy of a constant–sum player ties, so the uniform strategy is a best
response.) -/
theorem uniform_isNash_of_row_sum_const [DecidableEq I] [DecidableEq J]
    [Nonempty I] [Nonempty J] (G : FinGame I J) (S1 S2 : ℝ)
    (h1 : ∀ a, ∑ j, G.u1 a j = S1) (h2 : ∀ b, ∑ i, G.u2 i b = S2) :
    IsNash G (unif I) (unif J) := by
  apply isNash_of_pure
  · exact unif_isDist
  · exact unif_isDist
  · intro a
    exact le_of_eq (by rw [E1_pure_unif, h1, E1_value_uniform G S1 h1])
  · intro b
    exact le_of_eq (by rw [E2_pure_unif, h2, E2_value_uniform G S2 h2])

/-! ### The cyclic family of zero–sum games -/

/-- The cyclic zero–sum game on `ZMod n` with payoff generator `w`: player 1 gets
`w (i - j)` and player 2 gets `-w (i - j)`.  Matching Pennies (`n = 2`) and
Rock–Paper–Scissors (`n = 3`) are special cases. -/
def cyclicGame (n : ℕ) [NeZero n] (w : ZMod n → ℝ) : FinGame (ZMod n) (ZMod n) where
  u1 i j := w (i - j)
  u2 i j := - w (i - j)

/-- Every row of `cyclicGame n w` sums to the total mass `∑ k, w k`. -/
theorem cyclicGame_row_sum (n : ℕ) [NeZero n] (w : ZMod n → ℝ) (i : ZMod n) :
    ∑ j, (cyclicGame n w).u1 i j = ∑ k, w k := by
  simp only [cyclicGame]
  exact Equiv.sum_comp (Equiv.subLeft i) w

/-- Every column of `cyclicGame n w` sums to `-(∑ k, w k)`. -/
theorem cyclicGame_col_sum (n : ℕ) [NeZero n] (w : ZMod n → ℝ) (j : ZMod n) :
    ∑ i, (cyclicGame n w).u2 i j = - ∑ k, w k := by
  simp only [cyclicGame]
  rw [Finset.sum_neg_distrib]
  congr 1
  exact Equiv.sum_comp (Equiv.subRight j) w

/-- **Uniform equilibrium of the cyclic family.**  For *any* payoff generator `w`,
the uniform profile is a Nash equilibrium of `cyclicGame n w` (its rows and columns
have constant sums by translation invariance). -/
theorem cyclicGame_uniform_isNash (n : ℕ) [NeZero n] (w : ZMod n → ℝ) :
    IsNash (cyclicGame n w) (unif (ZMod n)) (unif (ZMod n)) := by
  exact uniform_isNash_of_row_sum_const (cyclicGame n w) (∑ k, w k) (-∑ k, w k)
    (cyclicGame_row_sum n w) (cyclicGame_col_sum n w)

/-- **The value of a zero–sum cyclic game is `0`.** -/
theorem cyclicGame_value (n : ℕ) [NeZero n] (w : ZMod n → ℝ) (hw : ∑ k, w k = 0) :
    E1 (cyclicGame n w) (unif (ZMod n)) (unif (ZMod n)) = 0 := by
  rw [E1_value_uniform (cyclicGame n w) (∑ k, w k) (cyclicGame_row_sum n w), hw]
  simp

/-! ### Classical special cases -/

/-- Matching Pennies as a cyclic game on `ZMod 2` with generator `w 0 = 1`,
`w 1 = -1`. -/
noncomputable def matchingPennies : FinGame (ZMod 2) (ZMod 2) :=
  cyclicGame 2 (fun k => if k = 0 then 1 else -1)

/-- **Matching Pennies has a uniform Nash equilibrium.** -/
theorem matchingPennies_uniform_isNash :
    IsNash matchingPennies (unif (ZMod 2)) (unif (ZMod 2)) := by
  unfold matchingPennies
  exact cyclicGame_uniform_isNash 2 _

/-- Rock–Paper–Scissors as a cyclic game on `ZMod 3`: you beat the previous
strategy (`w 1 = 1`), lose to the next (`w 2 = -1`), and tie yourself (`w 0 = 0`). -/
noncomputable def rps : FinGame (ZMod 3) (ZMod 3) :=
  cyclicGame 3 (fun k => if k = 1 then 1 else if k = 2 then -1 else 0)

/-- **Rock–Paper–Scissors has a uniform Nash equilibrium.** -/
theorem rps_uniform_isNash :
    IsNash rps (unif (ZMod 3)) (unif (ZMod 3)) := by
  unfold rps
  exact cyclicGame_uniform_isNash 3 _

end SpernerNashDeep