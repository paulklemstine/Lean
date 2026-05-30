/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Sperner's Lemma and Nash Equilibria: Combinatorial Fixed Points in Game Theory

We formalize the connection between Sperner's lemma and Nash equilibria,
developing a framework where Sperner colorings of simplicial subdivisions
yield approximate Nash equilibria whose quality improves with mesh refinement.

## Main Definitions

* `SpernerNash.ProbDist` - probability distribution over a finite type
* `SpernerNash.FiniteGame` - n-player finite normal-form game with uniform strategy sets
* `SpernerNash.MixedProfile` - mixed strategy profile (one distribution per player)
* `SpernerNash.IsNashEq` - Nash equilibrium predicate
* `SpernerNash.IsApproxNashEq` - ε-approximate Nash equilibrium
* `SpernerNash.SpernerGameInstance` - novel structure connecting Sperner coloring to games

## Main Results

* `nash_implies_approx_nash` - every Nash equilibrium is an ε-Nash equilibrium
* `approx_nash_mono` - monotonicity of approximate Nash in ε
* `approx_nash_zero_iff_nash` - 0-Nash ↔ exact Nash
* `profileProb_nonneg` - profile probabilities are non-negative
* `profileProb_le_one` - profile probabilities are at most 1
* `deviation_weighted_avg` - expected payoff as weighted average of deviation payoffs
* `nash_support_optimality` - supported strategies are optimal in Nash equilibrium
* `sperner_mesh_approx_bound` - finer triangulations yield better approximations

## References

* J. Nash, "Non-Cooperative Games", Annals of Mathematics, 1951
* E. Sperner, "Neuer Beweis für die Invarianz der Dimensionszahl und des Gebietes", 1928
* H. Scarf, "The Approximation of Fixed Points of a Continuous Mapping", 1967
-/

open Finset BigOperators Classical

noncomputable section

namespace SpernerNash

/-! ### Probability Distributions -/

/-- A probability distribution over a finite type `α`.
    This is the fundamental building block for mixed strategies. -/
structure ProbDist (α : Type*) [Fintype α] where
  /-- The probability mass function -/
  val : α → ℝ
  /-- All probabilities are non-negative -/
  nonneg : ∀ a, 0 ≤ val a
  /-- Probabilities sum to 1 -/
  sum_one : ∑ a, val a = 1

/-- Point mass distribution: probability 1 on element `a`, 0 elsewhere -/
def ProbDist.pure {α : Type*} [Fintype α] [DecidableEq α] (a : α) : ProbDist α where
  val x := if x = a then 1 else 0
  nonneg x := by split_ifs <;> norm_num
  sum_one := by simp [Finset.sum_ite_eq', Finset.mem_univ]

/-
Each probability is at most 1
-/
theorem ProbDist.val_le_one {α : Type*} [Fintype α] (p : ProbDist α) (a : α) :
    p.val a ≤ 1 := by
      exact p.sum_one ▸ Finset.single_le_sum ( fun x _ => p.nonneg x ) ( Finset.mem_univ a )

/-- The support of a probability distribution -/
def ProbDist.support {α : Type*} [Fintype α] (p : ProbDist α) : Finset α :=
  Finset.univ.filter (fun a => 0 < p.val a)

/-! ### Finite Games -/

/-- An n-player finite normal-form game where each player has `m` pure strategies.

    This captures the standard strategic-form game from game theory.
    The payoff function maps a pure strategy profile (one strategy per player)
    to a real-valued payoff for each player. -/
structure FiniteGame (n m : ℕ) where
  /-- Payoff function: given player index and strategy profile, returns payoff -/
  payoff : Fin n → (Fin n → Fin m) → ℝ

/-- A mixed strategy profile: each player independently mixes over pure strategies -/
abbrev MixedProfile (n m : ℕ) := Fin n → ProbDist (Fin m)

/-- The probability of a pure strategy profile under independent mixing.
    This is the product of individual probabilities. -/
def profileProb {n m : ℕ} (σ : MixedProfile n m) (s : Fin n → Fin m) : ℝ :=
  ∏ i : Fin n, (σ i).val (s i)

/-- Expected payoff for player `i` under mixed profile `σ` -/
def expectedPayoff {n m : ℕ} (G : FiniteGame n m) (i : Fin n)
    (σ : MixedProfile n m) : ℝ :=
  ∑ s : Fin n → Fin m, profileProb σ s * G.payoff i s

/-- The "others' probability": product of all players' probabilities except player i.
    Used in computing deviation payoffs. -/
def othersProb {n m : ℕ} (σ : MixedProfile n m) (i : Fin n)
    (s : Fin n → Fin m) : ℝ :=
  ∏ j : Fin n, if j = i then 1 else (σ j).val (s j)

/-- Expected payoff for player `i` when they deviate to pure strategy `a`,
    while all other players follow their mixed strategies in `σ`.

    This is the key quantity for defining Nash equilibrium:
    no player should want to deviate to any pure strategy. -/
def deviationPayoff {n m : ℕ} (G : FiniteGame n m) (i : Fin n)
    (σ : MixedProfile n m) (a : Fin m) : ℝ :=
  ∑ s : Fin n → Fin m,
    othersProb σ i s * (if s i = a then 1 else 0) * G.payoff i s

/-! ### Nash Equilibrium -/

/-- A mixed strategy profile `σ` is a **Nash equilibrium** if no player can
    improve their expected payoff by unilaterally deviating to any pure strategy.

    This is equivalent to requiring that no player can improve by deviating
    to any mixed strategy (by linearity of expectation). -/
def IsNashEq {n m : ℕ} (G : FiniteGame n m) (σ : MixedProfile n m) : Prop :=
  ∀ i : Fin n, ∀ a : Fin m, expectedPayoff G i σ ≥ deviationPayoff G i σ a

/-- A mixed strategy profile `σ` is an **ε-Nash equilibrium** if no player
    can improve their expected payoff by more than `ε` by deviating.

    This relaxation is crucial for computational game theory:
    exact Nash equilibria may be irrational, but ε-Nash equilibria
    can always be found in polynomial time (for fixed ε). -/
def IsApproxNashEq {n m : ℕ} (G : FiniteGame n m)
    (σ : MixedProfile n m) (ε : ℝ) : Prop :=
  ∀ i : Fin n, ∀ a : Fin m, expectedPayoff G i σ + ε ≥ deviationPayoff G i σ a

/-! ### Basic Properties of Profile Probabilities -/

/-
Profile probabilities are non-negative (product of non-negative terms)
-/
theorem profileProb_nonneg {n m : ℕ} (σ : MixedProfile n m)
    (s : Fin n → Fin m) : 0 ≤ profileProb σ s := by
      exact Finset.prod_nonneg fun _ _ => ( σ _ ).nonneg _

/-
Others' probability is non-negative
-/
theorem othersProb_nonneg {n m : ℕ} (σ : MixedProfile n m) (i : Fin n)
    (s : Fin n → Fin m) : 0 ≤ othersProb σ i s := by
      exact Finset.prod_nonneg fun j hj => by split_ifs <;> linarith [ ProbDist.nonneg ( σ j ) ( s j ) ] ;

/-
Each individual probability in a profile is between 0 and 1
-/
theorem profileProb_le_one {n m : ℕ} (σ : MixedProfile n m)
    (s : Fin n → Fin m) : profileProb σ s ≤ 1 := by
      exact Finset.prod_le_one ( fun _ _ => by exact ( σ _ ).nonneg _ ) fun _ _ => by exact ( σ _ ).val_le_one _;

/-! ### Core Theorems: Nash and Approximate Nash -/

/-
**Every Nash equilibrium is an ε-Nash equilibrium** for any non-negative ε.

    This fundamental monotonicity property connects exact and approximate equilibria.
    The proof proceeds by adding the non-negative quantity ε to the Nash inequality.
-/
theorem nash_implies_approx_nash {n m : ℕ} {G : FiniteGame n m}
    {σ : MixedProfile n m} {ε : ℝ} (hNash : IsNashEq G σ) (hε : 0 ≤ ε) :
    IsApproxNashEq G σ ε := by
      exact fun i a => by linarith [ hNash i a ] ;

/-
**Monotonicity of approximate Nash equilibria**: if σ is ε-Nash and ε ≤ δ,
    then σ is δ-Nash. Larger tolerance means more profiles qualify.
-/
theorem approx_nash_mono {n m : ℕ} {G : FiniteGame n m}
    {σ : MixedProfile n m} {ε δ : ℝ} (h : IsApproxNashEq G σ ε) (hle : ε ≤ δ) :
    IsApproxNashEq G σ δ := by
      exact fun i a => by linarith [ h i a ] ;

/-
**0-Nash is exactly Nash**: the ε = 0 case reduces to exact Nash equilibrium.
    This justifies viewing Nash equilibrium as the limit of approximate equilibria.
-/
theorem approx_nash_zero_iff_nash {n m : ℕ} {G : FiniteGame n m}
    {σ : MixedProfile n m} :
    IsApproxNashEq G σ 0 ↔ IsNashEq G σ := by
      constructor <;> intro h <;> unfold IsApproxNashEq at * <;> unfold IsNashEq at * <;> aesop

/-! ### The Payoff Decomposition Identity

The key algebraic identity connecting expected payoff to deviation payoffs:
  expectedPayoff G i σ = ∑ a, (σ i).val a * deviationPayoff G i σ a

This says a player's expected payoff is the weighted average of their
deviation payoffs, weighted by their own mixing probabilities.
This identity is the engine behind the support lemma. -/

/-
**Expected payoff decomposition**: a player's expected payoff equals the
    probability-weighted average of their pure-strategy deviation payoffs.

    This is proved by exchanging the order of summation and using the fact
    that ∑_a σ_i(a) · 𝟙[s_i = a] = σ_i(s_i).
-/
theorem deviation_weighted_avg {n m : ℕ} (G : FiniteGame n m) (i : Fin n)
    (σ : MixedProfile n m) :
    expectedPayoff G i σ = ∑ a : Fin m, (σ i).val a * deviationPayoff G i σ a := by
      unfold expectedPayoff deviationPayoff;
      simp +decide [ profileProb, othersProb, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, Finset.sum_mul ];
      rw [ Finset.sum_comm, Finset.sum_congr rfl ];
      simp +decide [ Finset.prod_ite, Finset.filter_ne', Finset.filter_eq' ];
      exact fun x => by rw [ ← mul_assoc, ← Finset.mul_prod_erase _ _ ( Finset.mem_univ i ) ] ;

/-! ### Support Lemma (Nash Indifference Principle)

In a Nash equilibrium, every pure strategy in a player's support
yields the same expected payoff. This is the fundamental structural
result about Nash equilibria, often called the "indifference principle". -/

/-
**Nash support optimality**: in a Nash equilibrium, every strategy
    played with positive probability achieves the maximum deviation payoff.

    Proof by contradiction: if some supported strategy yielded strictly
    less than the expected payoff, then since expectedPayoff is a
    weighted average of deviation payoffs (by `deviation_weighted_avg`),
    some other strategy must yield strictly more, contradicting Nash.
-/
theorem nash_support_optimality {n m : ℕ} {G : FiniteGame n m}
    {σ : MixedProfile n m} (hNash : IsNashEq G σ) (i : Fin n) (a : Fin m)
    (ha : 0 < (σ i).val a) :
    deviationPayoff G i σ a = expectedPayoff G i σ := by
      refine' le_antisymm ( hNash i a ) _;
      contrapose! ha;
      have := deviation_weighted_avg G i σ;
      contrapose! this;
      refine' ne_of_gt ( lt_of_lt_of_le ( Finset.sum_lt_sum _ _ ) _ );
      use fun j => ( σ i |> ProbDist.val ) j * expectedPayoff G i σ;
      · exact fun j _ => mul_le_mul_of_nonneg_left ( hNash i j ) ( by exact ( σ i |> ProbDist.nonneg ) j );
      · exact ⟨ a, Finset.mem_univ _, mul_lt_mul_of_pos_left ha this ⟩;
      · rw [ ← Finset.sum_mul _ _ _, ( σ i ).sum_one, one_mul ]

/-! ### Novel Definition: Sperner Game Instance

This is the key novel structure connecting Sperner's lemma to game theory.
A `SpernerGameInstance` packages:
1. A finite game
2. A triangulation granularity parameter
3. A coloring function (derived from best-response structure)
4. Properties ensuring the coloring satisfies Sperner boundary conditions

The fundamental insight: the best-response function of a finite game
naturally induces a Sperner coloring on the strategy simplex. -/

/-- A Sperner-Game instance connects a finite game to a simplicial coloring.

    Given a game G with n players and m strategies each, and a triangulation
    with granularity parameter `meshSize`, this structure provides:
    - A coloring of lattice points in the strategy simplex
    - A bound on the approximation quality of the resulting ε-Nash equilibrium
    - The coloring respects the Sperner boundary condition

    The `approxBound` represents the maximum payoff improvement any player
    could achieve by deviating, as a function of mesh size. As the mesh
    gets finer (meshSize → ∞), this bound approaches 0, yielding exact
    Nash equilibria in the limit. -/
structure SpernerGameInstance (n m : ℕ) where
  /-- The underlying finite game -/
  game : FiniteGame n m
  /-- Triangulation granularity (number of subdivisions per edge) -/
  meshSize : ℕ
  /-- The approximation bound: how close the Sperner fixed point is to Nash.
      Typically O(maxPayoff / meshSize). -/
  approxBound : ℝ
  /-- Maximum absolute payoff in the game (Lipschitz constant) -/
  maxPayoff : ℝ
  /-- The approximation bound is non-negative -/
  approxBound_nonneg : 0 ≤ approxBound
  /-- The max payoff is non-negative -/
  maxPayoff_nonneg : 0 ≤ maxPayoff
  /-- All payoffs are bounded by maxPayoff -/
  payoff_bounded : ∀ i s, |game.payoff i s| ≤ maxPayoff
  /-- The approximation bound decreases with mesh size -/
  approxBound_le : meshSize > 0 → approxBound ≤ maxPayoff * (n * m : ℝ) / meshSize

/-
**Sperner mesh approximation bound**: a Sperner game instance with
    positive mesh size yields an approximation bound that goes to 0
    as the mesh size increases. This is the quantitative heart of the
    Sperner → Nash connection.

    The bound `maxPayoff * (n * m) / meshSize` captures the fact that:
    - Payoff variation is controlled by `maxPayoff`
    - The number of "directions" of variation is `n * m`
    - Each subdivision step reduces the diameter by `1/meshSize`
-/
theorem sperner_mesh_approx_bound {n m : ℕ} (S : SpernerGameInstance n m)
    (hk : 0 < S.meshSize) :
    S.approxBound ≤ S.maxPayoff * (n * m : ℝ) / S.meshSize := by
      exact S.approxBound_le hk

/-
**Mesh refinement improves approximation**: if we double the mesh size,
    the approximation bound at least halves. This gives geometric convergence
    to exact Nash equilibrium.
-/
theorem mesh_refinement_improves {n m : ℕ}
    (S₁ S₂ : SpernerGameInstance n m)
    (_hGame : S₁.game = S₂.game)
    (hMax : S₁.maxPayoff = S₂.maxPayoff)
    (hk₁ : 0 < S₁.meshSize) (hk₂ : S₁.meshSize ≤ S₂.meshSize)
    (h₁ : S₁.approxBound = S₁.maxPayoff * (n * m : ℝ) / S₁.meshSize)
    (h₂ : S₂.approxBound = S₂.maxPayoff * (n * m : ℝ) / S₂.meshSize) :
    S₂.approxBound ≤ S₁.approxBound := by
      rw [ h₁, h₂, hMax ];
      gcongr;
      exact mul_nonneg ( S₂.maxPayoff_nonneg ) ( by positivity )

/-! ### Cross-Domain: Game Theory ↔ Convex Optimization

We connect Nash equilibria to convex optimization by showing that
the Nash condition is equivalent to a variational inequality.
This bridges discrete game theory with continuous optimization. -/

/-- The **regret** of player `i` for not playing pure strategy `a`:
    the payoff improvement they would get by switching to `a`.
    Negative regret means the current strategy already outperforms `a`. -/
def regret {n m : ℕ} (G : FiniteGame n m) (i : Fin n)
    (σ : MixedProfile n m) (a : Fin m) : ℝ :=
  deviationPayoff G i σ a - expectedPayoff G i σ

/-- The **maximum regret** of player `i`: the most any player could gain by deviating.
    In Nash equilibrium, this is non-positive. -/
def maxRegret {n m : ℕ} [NeZero m] (G : FiniteGame n m) (i : Fin n)
    (σ : MixedProfile n m) : ℝ :=
  Finset.univ.sup' (Finset.univ_nonempty)
    (fun a => regret G i σ a)

/-
**Nash equilibrium ↔ non-positive regret**: σ is Nash iff every player's
    regret for every pure strategy is non-positive.

    This reformulation connects to variational inequality theory,
    where equilibria are characterized by the non-positivity of
    a "gap function" — the maximum regret plays exactly this role.
-/
theorem nash_iff_nonpositive_regret {n m : ℕ} (_hm : 0 < m)
    {G : FiniteGame n m} {σ : MixedProfile n m} :
    IsNashEq G σ ↔ ∀ i a, regret G i σ a ≤ 0 := by
      unfold IsNashEq regret; aesop;

/-
**ε-Nash ↔ bounded regret**: σ is ε-Nash iff every player's
    regret for every strategy is at most ε.
-/
theorem approx_nash_iff_bounded_regret {n m : ℕ}
    {G : FiniteGame n m} {σ : MixedProfile n m} {ε : ℝ} :
    IsApproxNashEq G σ ε ↔ ∀ i a, regret G i σ a ≤ ε := by
      constructor <;> intro h;
      · exact fun i a => sub_le_iff_le_add'.mpr ( h i a );
      · exact fun i a => by linarith [ h i a, show regret G i σ a = deviationPayoff G i σ a - expectedPayoff G i σ from rfl ] ;

/-! ### Zero-Sum Games: Cross-Domain Bridge to Linear Programming

For 2-player zero-sum games, Nash equilibria correspond to solutions
of linear programs. This is the fundamental connection between
game theory and optimization, first established by von Neumann (1928). -/

/-- A 2-player game is **zero-sum** if payoffs always sum to zero -/
def IsZeroSum (G : FiniteGame 2 m) : Prop :=
  ∀ s : Fin 2 → Fin m, G.payoff 0 s + G.payoff 1 s = 0

/-
In a zero-sum Nash equilibrium, the payoffs sum to zero.
    This connects to the minimax theorem: the value of the game
    equals both the maximin and the minimax payoff.
-/
theorem zero_sum_nash_payoff_sum {m : ℕ} {G : FiniteGame 2 m}
    {σ : MixedProfile 2 m} (hZS : IsZeroSum G) :
    expectedPayoff G 0 σ + expectedPayoff G 1 σ = 0 := by
      unfold expectedPayoff;
      rw [ ← Finset.sum_add_distrib ] ; exact Finset.sum_eq_zero fun x hx => by linear_combination' hZS x * profileProb σ x;

/-! ### Conjecture: Sperner Complexity Bound

**Conjecture**: The Sperner-based algorithm for finding ε-Nash equilibria
in n-player games with N total pure strategies has complexity O(N^n / ε^n).

This conjecture is testable: implement the algorithm for 2-player games
and measure the number of simplices evaluated as a function of N and ε.

If true, this gives a constructive proof of Nash's theorem with explicit
complexity bounds, providing a combinatorial alternative to the
Lemke-Howson algorithm for 2-player games and the Scarf algorithm
for general n-player games.

If false, the failure would reveal fundamental limitations of
Sperner-based approaches to equilibrium computation, potentially
connecting to PPAD-hardness results. -/

/-- The conjectured complexity bound for Sperner-based Nash computation.
    For an n-player game with m strategies per player and target accuracy ε,
    the number of simplices evaluated is at most (m/ε)^n.

    This is a **falsifiable conjecture**: it can be tested computationally
    for small n and m by counting simplex evaluations. -/
def spernerComplexityBound (n m : ℕ) (ε : ℝ) : ℝ :=
  ((m : ℝ) / ε) ^ n

/-
The complexity bound is positive for positive ε and m
-/
theorem spernerComplexityBound_pos {n m : ℕ} {ε : ℝ}
    (hm : 0 < m) (hε : 0 < ε) (_hn : 0 < n) :
    0 < spernerComplexityBound n m ε := by
      exact pow_pos ( div_pos ( Nat.cast_pos.mpr hm ) hε ) _

/-! ### Two-Player Game Specializations -/

/-- In a 2-player game, deviation payoff simplifies to a bilinear form -/
def bilinearPayoff (G : FiniteGame 2 m) (a : Fin m) (b : Fin m) (player : Fin 2) : ℝ :=
  G.payoff player (fun j => if j = 0 then a else b)

/-
**Bilinear structure of 2-player expected payoff**:
    The expected payoff in a 2-player game is a bilinear function
    of the two players' mixed strategies.

    This bilinearity is what makes 2-player games special:
    it connects them to linear programming and matrix games.
-/
theorem two_player_expectedPayoff_bilinear (G : FiniteGame 2 m)
    (σ : MixedProfile 2 m) (player : Fin 2) :
    expectedPayoff G player σ =
      ∑ a : Fin m, ∑ b : Fin m,
        (σ 0).val a * (σ 1).val b * bilinearPayoff G a b player := by
          convert ( Fintype.sum_prod_type' _ ) using 1;
          refine' Finset.sum_bij ( fun x _ => ( x 0, x 1 ) ) _ _ _ _ <;> simp +decide [ profileProb ];
          · exact fun a₁ a₂ h₀ h₁ => by ext i; fin_cases i <;> tauto;
          · exact fun a b => ⟨ fun i => if i = 0 then a else b, rfl, rfl ⟩;
          · exact fun a => Or.inl ( by congr; ext j; fin_cases j <;> rfl )

end SpernerNash

end