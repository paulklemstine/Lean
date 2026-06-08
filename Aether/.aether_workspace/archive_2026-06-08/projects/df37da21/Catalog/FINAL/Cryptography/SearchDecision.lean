import Mathlib
import Cryptography.LWE.Security
import Cryptography.ModuleLWE.Defs

/-!
# Basis-Free Search-to-Decision Reduction for Modules

This module generalizes the coordinate-based search-to-decision hybrid argument
from `Cryptography.LWE.Security` to an abstract finite module setting.
The key insight: LWE security proofs are not fundamentally about coordinates;
they are about **linear observables on finite modules**.

## Main Results

1. `abstract_hybrid_telescope`: Basis-free telescope bound over any finite index.
2. `search_advantage_le_sum`: Total search advantage bounded by coordinate sum.
3. `search_from_decision_as_special_case`: Shows the coordinate version is a corollary.

## Proof Strategy

We use a telescoping hybrid argument over the indexing set `S`.
The triangle inequality telescopes the total gap into per-coordinate
contributions, each bounded by `ε(s)`.
-/

open Finset BigOperators

noncomputable section

/-! ## Abstract Hybrid Telescope -/

/-
**Abstract hybrid telescope bound**: the total gap between start and end
of a hybrid sequence is bounded by the sum of adjacent gaps.

This is the basis-free version that works over any finite indexing set,
not just `Fin n`. Each element of `S` contributes one hybrid step.
-/
theorem abstract_hybrid_telescope
    {S : Type*} [Fintype S] [DecidableEq S]
    (hybrids : Fin (Fintype.card S + 1) → ℝ)
    (ε : S → ℝ)
    (hε : ∀ i : Fin (Fintype.card S),
      |hybrids i.castSucc - hybrids i.succ| ≤ ε ((Fintype.equivFin S).symm i)) :
    |hybrids 0 - hybrids (Fin.last _)| ≤ ∑ s : S, ε s := by
  -- Apply the triangle inequality to the entire range from 0 to `Fin.last (Fintype.card S)`.
  have h_triangle : |hybrids 0 - hybrids (Fin.last (Fintype.card S))| ≤ ∑ i : Fin (Fintype.card S), |hybrids i.castSucc - hybrids i.succ| := by
    have h_triangle : ∀ (n : ℕ) (f : Fin (n + 1) → ℝ), |f 0 - f (Fin.last n)| ≤ ∑ i : Fin n, |f i.castSucc - f i.succ| := by
      intro n f; induction' n with n ih <;> simp_all +decide [ Fin.sum_univ_castSucc ] ;
      have := ih ( fun i => f i.castSucc );
      exact le_trans ( abs_sub_le _ _ _ ) ( add_le_add this le_rfl );
    exact h_triangle _ _;
  refine' le_trans h_triangle ( le_trans ( Finset.sum_le_sum fun i _ => hε i ) _ );
  conv_rhs => rw [ ← Equiv.sum_comp ( Fintype.equivFin S ).symm ] ;

/-- **Search advantage bounded by sum of coordinate advantages**.

This is the module-theoretic generalization of `search_from_decision_coordinate`.
Given a hybrid sequence indexed by a finite type `S`, if each hybrid step's
gap is bounded by `ε(s)`, then the total advantage is bounded by `∑ s, ε s`. -/
theorem search_advantage_le_sum
    {S : Type*} [Fintype S] [DecidableEq S]
    (totalAdvantage : ℝ)
    (hybrids : Fin (Fintype.card S + 1) → ℝ)
    (hadv : totalAdvantage ≤ |hybrids 0 - hybrids (Fin.last _)|)
    (ε : S → ℝ)
    (hε : ∀ i : Fin (Fintype.card S),
      |hybrids i.castSucc - hybrids i.succ| ≤ ε ((Fintype.equivFin S).symm i)) :
    totalAdvantage ≤ ∑ s : S, ε s :=
  le_trans hadv (abstract_hybrid_telescope hybrids ε hε)

/-! ## Recovering the Coordinate-Based Version -/

/-
**The coordinate-based search-to-decision theorem is a special case**.

When `S = Fin n`, the abstract hybrid telescope specializes to the
statement that total advantage ≤ sum of coordinate advantages,
recovering `search_from_decision_coordinate` from the abstract framework.
-/
theorem search_from_decision_as_special_case
    {n : ℕ} (hn : 0 < n)
    (hybridProbs : Fin (n + 1) → ℝ)
    (coordAdvantage : Fin n → ℝ)
    (hcoord : ∀ i : Fin n,
      |hybridProbs i.castSucc - hybridProbs i.succ| ≤ coordAdvantage i) :
    |hybridProbs 0 - hybridProbs (Fin.last n)| ≤ ∑ i : Fin n, coordAdvantage i := by
  -- Apply the hybrid_telescope_bound from Cryptography.LWE.Security with k = n - 1.
  have h_telescope : |hybridProbs ⟨0, by omega⟩ - hybridProbs ⟨n, by omega⟩| ≤ ∑ i : Fin n, |hybridProbs i.castSucc - hybridProbs i.succ| := by
    -- Apply the hybrid_telescope_bound with k = n - 1.
    have := @hybrid_telescope_bound (n - 1);
    rcases n <;> aesop;
  exact h_telescope.trans ( Finset.sum_le_sum fun i _ => hcoord i )

/-! ## Conjecture: Quotient Security Monotonicity -/

/-- **Conjecture (Falsifiable)**: For kernel-invariant error distributions,
compression via a surjective linear map never increases the best distinguishing
advantage.

**Computational test**: Sample toy instances over ZMod q with small dimensions.
Enumerate all Boolean distinguishers. Compute the maximum advantage before and
after compression. Search for a counterexample where compression increases advantage. -/
def quotientSecurityMonotonicity_conjecture : Prop :=
  ∀ (q : ℕ) [NeZero q] (n : ℕ) (f : (Fin n → ZMod q) →ₗ[ZMod q] ZMod q)
    (χ : PMF (Fin n → ZMod q)),
    KernelInvariantError f χ →
    ∀ (D : ZMod q → Bool),
      ∃ (D' : (Fin n → ZMod q) → Bool),
        |acceptProb (PMF.map f χ) D - (1 : ℝ)/2| ≤
          |acceptProb χ D' - (1 : ℝ)/2|

end

/-! ## Axiom Verification -/
#print axioms abstract_hybrid_telescope
#print axioms search_advantage_le_sum
#print axioms search_from_decision_as_special_case