import Mathlib
import Algebra.SurrealDyadic

/-!
# Infinite games against death

A survival strategy is measured by the supremum of the ordinal lengths of all
plays compatible with it.  This convention separates an unattained limit from
an individual play: finite computations can be cofinal in `ω` without any one
finite computation lasting `ω` steps.

Bounded nondeterminism is represented by a finite block budget.  A strategy
with budget `k` reaches the beginning of the `k`-th `ω`-block; allowing an
arbitrary finite budget gives a family cofinal in `ω²`.  This is the ordinal
clock pattern used by limit-stage models such as infinite-time machines, but no
claim about a particular machine instruction set is assumed here.
-/

namespace InfiniteGamesAgainstDeath

open Ordinal

/-- A deterministic finite-computation survival profile. -/
def FiniteStrategy := Nat → Ordinal

/-- The strategy forces survival up to `a` when its finite plays are cofinal in `a`. -/
def Forces (s : FiniteStrategy) (a : Ordinal) : Prop := a ≤ iSup s

/-- Mortal's canonical strategy asks for `n` further finite rounds. -/
def mortalFinite : FiniteStrategy := fun n => n

/-- A two-parameter strategy: a finite nondeterministic block budget and a
finite delay within the final block. -/
def BoundedStrategy := Nat → Nat → Ordinal

/-- Cofinality semantics for a family of finitely bounded choices. -/
def ForcesBounded (s : BoundedStrategy) (a : Ordinal) : Prop :=
  a ≤ ⨆ k : Nat, ⨆ n : Nat, s k n

/-- The canonical block strategy enters `k` limit blocks and then survives `n`
additional successor rounds. -/
def mortalBounded : BoundedStrategy := fun k n => omega0 * k + n

-- !-- Lab Notes -- !--
-- Hypothesis (ranked by prospective impact): (1) operational infinite-time
-- machine games support this cofinal-clock semantics; (2) d nested finite choice
-- layers are cofinal in omega^d; (3) arbitrary finite block budgets and finite
-- tails are cofinal in omega squared; (4) dyadic surreal birthdays realize the
-- first clock and its nested block lift; (5) every fixed block budget falls
-- short of omega squared; (6) cofinal survival can be replaced by one play of
-- limit length.
-- Experiment: the examples below instantiate delays 7 and 19 and block clocks
-- (0,5), (1,3), and (2,0); their values expose the noncommutativity of ordinal
-- multiplication and addition. No arXiv, OEIS, or LMFDB signal was supplied,
-- so target selection was driven by the existing dyadic-surreal result.
-- Analysis: conjectures (3)--(5) survive. The first supremum is the standard
-- characterization of omega. For each block budget k, finite tail delays
-- converge to omega*k + omega; varying k makes these successor blocks cofinal
-- in omega*omega. The birthday identity transfers both constructions to games.
-- Critique: conjecture (6) is false: no finite delay reaches omega. Conjecture
-- (1) needs a concrete machine transition and limit-update semantics, and (2)
-- remains a broader generalization. No fixed finite block bound reaches omega
-- squared. Thus “force” means a lower bound on the supremum of compatible play
-- lengths, not the existence of one play of that limit length. “Bounded” means
-- each individual choice has a finite bound; there is no single global bound.
-- Synthesis: ordinal arithmetic supplies one uniform algebraic account of
-- deterministic finite postponement, finitely bounded branching, and two
-- nested limit stages; finite birthdays of dyadic surreal games provide an
-- independent game-theoretic realization of the clocks.
-- !-- End Lab Notes -- !--

/-- Concrete finite-delay examples. -/
example : mortalFinite 7 = 7 := rfl
example : mortalFinite 19 = 19 := rfl

/-- Concrete block-clock examples. -/
example : mortalBounded 0 5 = 5 := by simp [mortalBounded]
example : mortalBounded 1 3 = omega0 + 3 := by simp [mortalBounded]
example : mortalBounded 2 0 = omega0 * 2 := by simp [mortalBounded]

/-
Finite computation lengths are cofinal in the first limit ordinal.
-/
theorem mortal_forces_omega : Forces mortalFinite omega0 := by
  convert Ordinal.iSup_natCast.ge

/-
No one finite computation realizes the limit promised by cofinality.
-/
theorem every_mortal_play_is_finite (n : Nat) : mortalFinite n < omega0 := by
  apply Ordinal.nat_lt_omega0

/-
Every proposed finite cap is defeated by requesting one more round.
-/
theorem no_finite_uniform_cap (N : Nat) :
    ∃ n, (N : Ordinal) < mortalFinite n := by
  -- Choose n = N + 1.
  use N + 1;
  simp +decide [ mortalFinite ]

/-
A fixed block bound remains strictly below `ω²`, even after any finite tail.
-/
theorem fixed_bound_below_omega_squared (k n : Nat) :
    mortalBounded k n < omega0 * omega0 := by
  simp [mortalBounded];
  refine' lt_of_lt_of_le _ ( mul_le_mul_right ( show ( k : Ordinal ) + 1 ≤ ω from _ ) _ );
  · simp [Ordinal.mul_succ];
  · exact_mod_cast Ordinal.nat_lt_omega0 ( k + 1 ) |> le_of_lt

/-
At a fixed block budget, finite tails have the exact successor-block
supremum `ωk + ω`.
-/
theorem fixed_budget_exact (k : Nat) :
    (⨆ n : Nat, mortalBounded k n) = omega0 * k + omega0 := by
  convert Ordinal.iSup_add_natCast ( Ordinal.omega0 * k ) using 1

/-
Finite block budgets with finite tails are cofinal in `ω²`.
-/
theorem bounded_nondeterminism_forces_omega_squared :
    ForcesBounded mortalBounded (omega0 * omega0) := by
  refine' le_trans _ ( Ordinal.iSup_le _ );
  rotate_left;
  exact Nat;
  exact fun n => omega0 * n;
  · intro k; exact le_trans ( by simp +decide [ mortalBounded ] ) ( le_ciSup ( Ordinal.bddAbove_of_small _ ) k |> le_trans ( le_ciSup ( Ordinal.bddAbove_of_small _ ) 0 ) ) ;
  · rw [ Ordinal.iSup_mul_natCast ]

/-
The bound is exact: the complete two-parameter clock has supremum `ω²`.
-/
theorem bounded_clock_exact :
    (⨆ k : Nat, ⨆ n : Nat, mortalBounded k n) = omega0 * omega0 := by
  refine' le_antisymm _ _;
  · exact ciSup_le fun k => ciSup_le fun n => le_of_lt ( fixed_bound_below_omega_squared k n );
  · convert bounded_nondeterminism_forces_omega_squared using 1

/-
The first limit-clock profile is also realized by birthdays of canonical
surreal dyadic units, connecting ordinal survival clocks with game birthdays.
-/
theorem dyadic_birthday_cofinal_omega :
    (⨆ n : Nat, SetTheory.PGame.birthday (SetTheory.PGame.powHalf n)) = omega0 := by
  refine' le_antisymm _ _;
  · refine' ciSup_le' fun n => _;
    rw [ SetTheory.PGame.birthday_powHalf ] ; norm_num;
  · refine' le_of_forall_lt fun a ha => _;
    rcases Ordinal.lt_omega0.1 ha with ⟨ n, rfl ⟩ ; exact lt_of_lt_of_le ( by simp +decide ) ( le_ciSup ( Ordinal.bddAbove_of_small _ ) n ) ;

/-
Nesting the dyadic birthday clock into finite blocks again yields `ω²`.
-/
theorem nested_dyadic_clock_cofinal_omega_squared :
    (⨆ k : Nat, omega0 *
      SetTheory.PGame.birthday (SetTheory.PGame.powHalf k)) = omega0 * omega0 := by
  convert Ordinal.iSup_mul_natCast omega0 using 1;
  simp +decide [ SetTheory.PGame.birthday_powHalf ];
  rw [ @ciSup_eq_of_forall_le_of_forall_lt_exists_gt ];
  · exact fun i => mul_le_mul_right ( Order.succ_le_of_lt ( Ordinal.nat_lt_omega0 i ) ) _;
  · intro w hw;
    contrapose! hw;
    rw [ ← Ordinal.iSup_mul_natCast ];
    refine' ciSup_le' fun n => _;
    induction n <;> simp_all +decide

end InfiniteGamesAgainstDeath