/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Conditional Consequences of Schanuel's Conjecture

This file derives transcendence results conditionally on Schanuel's conjecture.

## Main Results

* `schanuel_implies_exp_transcendental` — Schanuel ⇒ exp(nonzero algebraic) is transcendental
* `schanuel_implies_e_transcendental` — Schanuel ⇒ e is transcendental
* `schanuel_implies_lw_weak` — Schanuel ⇒ weak Lindemann–Weierstrass

## Proof Strategy

For a single nonzero algebraic number `z`:
1. `{z}` is ℚ-linearly independent (since z ≠ 0).
2. Schanuel gives `trdeg(ℚ(z, exp z)) ≥ 1`.
3. If `exp z` were algebraic, then since `z` is algebraic, all generators of
   `ℚ(z, exp z)` are algebraic, so the subalgebra is algebraic over ℚ.
4. An algebraic extension has transcendence degree 0, contradicting step 2.

For the weak Lindemann–Weierstrass, we apply the same argument to each
coordinate individually using `SchanuelProp 1`.
-/

import Mathlib
import Logic.Defs

open Complex Schanuel
open scoped BigOperators

namespace Schanuel

/-! ## Key algebraic lemma: algebraic generators ⇒ trdeg = 0 -/

/-
If every element of a generating set `S` is algebraic over `ℚ`, then
the subalgebra `ℚ[S]` has transcendence degree 0 over `ℚ`.
-/
theorem trdeg_adjoin_eq_zero_of_forall_isAlgebraic (S : Set ℂ)
    (hS : ∀ x ∈ S, IsAlgebraic ℚ x) :
    Algebra.trdeg ℚ (Algebra.adjoin ℚ S) = 0 := by
  have h_algebraic : ∀ x ∈ Algebra.adjoin ℚ S, IsAlgebraic ℚ x := by
    refine' fun x hx => Algebra.adjoin_induction _ _ _ _ hx;
    · assumption;
    · exact fun r => isAlgebraic_algebraMap r;
    · exact fun x y hx hy hx' hy' => hx'.add hy';
    · exact fun x y hx hy hx' hy' => hx'.mul hy';
  convert trdeg_eq_zero
  exact (Subalgebra.isAlgebraic_iff (Algebra.adjoin ℚ S)).mp h_algebraic

/-! ## n = 1 consequence: nonzero algebraic input gives transcendental output -/

/-
A single nonzero element is ℚ-linearly independent as a `Fin 1 → ℂ` family.
-/
theorem linearIndependent_fin_one {z : ℂ} (hz : z ≠ 0) :
    LinearIndependent ℚ (fun _ : Fin 1 => z) := by
  -- Since $z \neq 0$, the kernel of the map $c : \mathbb{Q} \to \mathbb{C}$ given by $c \mapsto cz$ is trivial.
  simp [hz]

/-
The adjoined set for a constant `Fin 1` family `fun _ => z` contains `z` and `exp z`.
-/
theorem adjoinedSet_fin_one (z : ℂ) :
    adjoinedSet (fun _ : Fin 1 => z) = {z, exp z} := by
  unfold adjoinedSet;
  simp +decide;
  exact Set.pair_comm _ _

/-
**Schanuel implies exp of nonzero algebraic is transcendental.**
This is the n = 1 consequence of Schanuel's conjecture.
-/
theorem schanuel_implies_exp_transcendental
    (hSC : SchanuelConjecture)
    {z : ℂ}
    (hz_alg : IsAlgebraic ℚ z)
    (hz_ne : z ≠ 0) :
    Transcendental ℚ (exp z) := by
  have := hSC 1;
  contrapose! this;
  unfold Transcendental at this;
  simp_all +decide [ SchanuelProp ];
  refine' ⟨ fun _ => z, _, _ ⟩ <;> simp_all +decide [ adjoinedAlgebra ];
  convert trdeg_adjoin_eq_zero_of_forall_isAlgebraic _ _;
  unfold adjoinedSet; aesop;

/-! ## Corollary: e is transcendental -/

/-- One is a nonzero algebraic number over ℚ. -/
theorem isAlgebraic_one : IsAlgebraic ℚ (1 : ℂ) := by
  rw [show (1 : ℂ) = algebraMap ℚ ℂ 1 from by simp]
  exact isAlgebraic_algebraMap _

/-- **Schanuel implies e = exp(1) is transcendental over ℚ.** -/
theorem schanuel_implies_e_transcendental
    (hSC : SchanuelConjecture) :
    Transcendental ℚ (exp (1 : ℂ)) := by
  exact schanuel_implies_exp_transcendental hSC isAlgebraic_one one_ne_zero

/-! ## Weak Lindemann–Weierstrass -/

/-
**Weak Lindemann–Weierstrass from Schanuel:**
If `a₁, …, aₙ` are algebraic numbers that are ℚ-linearly independent,
then each `exp(aᵢ)` is transcendental over ℚ.

This is weaker than the full Lindemann–Weierstrass theorem (which asserts
algebraic independence of the exponentials), but already implies key
transcendence results.
-/
theorem schanuel_implies_lw_weak
    (hSC : SchanuelConjecture)
    {n : ℕ} (a : Fin n → ℂ)
    (ha_alg : ∀ i, IsAlgebraic ℚ (a i))
    (ha_lin : LinearIndependent ℚ a) :
    ∀ i, Transcendental ℚ (exp (a i)) := by
  exact fun i => schanuel_implies_exp_transcendental hSC ( ha_alg i ) ( by simpa using ha_lin.ne_zero i )

/-! ## Algebraic-dependence obstruction -/

/-
**Algebraic dependence obstruction from Schanuel:**
Under Schanuel's conjecture, if all `z i` and `exp(z i)` are algebraic over ℚ,
then the family `z` cannot be ℚ-linearly independent (for `n ≥ 1`).
-/
theorem schanuel_algebraic_obstruction
    (hSC : SchanuelConjecture)
    {n : ℕ} (z : Fin n → ℂ)
    (hz_alg : ∀ i, IsAlgebraic ℚ (z i))
    (hexp_alg : ∀ i, IsAlgebraic ℚ (exp (z i)))
    (hn : 0 < n) :
    ¬ LinearIndependent ℚ z := by
  intro h_lin_ind
  have h_trdeg : (n : Cardinal) ≤ Algebra.trdeg ℚ (Algebra.adjoin ℚ (adjoinedSet z)) := by
    exact hSC n z h_lin_ind;
  have h_trdeg_zero : Algebra.trdeg ℚ (Algebra.adjoin ℚ (adjoinedSet z)) = 0 := by
    apply trdeg_adjoin_eq_zero_of_forall_isAlgebraic;
    rintro x ( ⟨ i, rfl ⟩ | ⟨ i, rfl ⟩ ) <;> [ exact hz_alg i; exact hexp_alg i ];
  exact absurd h_trdeg ( by rw [ h_trdeg_zero ] ; norm_cast; linarith )

end Schanuel