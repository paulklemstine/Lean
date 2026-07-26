/-
Copyright (c) 2026. All rights reserved.

# Escher Staircases in Algebra: Infinite Ascending Chains That Loop Back

An *Escher staircase* is an infinite, strictly ascending chain of ideals
`I₀ ⊊ I₁ ⊊ I₂ ⊊ ⋯` in a commutative ring.  The evocative "impossible staircase"
picture asks how such a chain can nevertheless "loop back" to its starting point.
This file makes the phenomenon precise and completely resolves the apparent
paradox.

## Main results

* `Escher.Staircase.iInf_eq_first` — the **loop-back lemma**: the infinite
  intersection `⨅ n, Iₙ` of an *ascending* chain is exactly its first term `I₀`.
  The staircase always "loops back" to where it started; there is nothing
  paradoxical about it.
* `Escher.not_isNoetherianRing_of_staircase` — a ring carrying an Escher staircase
  is not Noetherian.
* `Escher.nonempty_staircase_of_not_isNoetherianRing` — conversely, every
  non-Noetherian ring carries an Escher staircase.
* `Escher.nonempty_staircase_iff_not_isNoetherianRing` — the **characterization**:
  a commutative ring admits an Escher staircase iff it is not Noetherian.  Thus
  the existence of an Escher staircase is a faithful witness of non-Noetherianity.

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
The description frames an Escher staircase as an ascending chain whose infinite
intersection "loops back" to `I₁`.  Conjecture set:
  (H1) For any ascending chain, `⨅ Iₙ = I₀` automatically (loop-back is free).
  (H2) A ring has such a *strict* ascending chain iff it is non-Noetherian.
  (H3) [surprising] The advertised `Int(ℤ)` example `Iₙ = {f : f(ℤ) ⊆ 2ⁿℤ}` is
       *descending*, not ascending — so the headline example is mislabelled.

## Experiment (Experimenter)
Computed small cases in the Boolean ring `ℕ → 𝔽₂` (see `BooleanRing.lean`).  The
"support < n" ideals give a genuine strict ascending chain with `⨅ = ⊥`, i.e.
`I₀ = ⊥`, confirming (H1).  For `Int(ℤ)`, `2ⁿ⁺¹ℤ ⊆ 2ⁿℤ` forces `I_{n+1} ⊆ Iₙ`,
confirming (H3): the classic example is a *descending* Anti-Escher chain, matching
`Logic/ChainInvariants.lean`.

## Analysis (Analyst)
(H1) is a one-line lattice fact once phrased correctly.  (H2) is the substantive
theorem: it identifies "carries an Escher staircase" with `¬ IsNoetherianRing`,
turning an evocative picture into a lattice-theoretic invariant.  The forward
direction extracts a strict chain from the failure of the ascending chain
condition via `RelEmbedding.wellFounded_iff_isEmpty`.

## Critique (Critic)
The loop-back lemma alone is near-trivial, so it is *not* a main theorem; the
main result is the biconditional characterization.  We guard against vacuity by
also exhibiting a concrete non-Noetherian model (`BooleanRing.lean`) and by
contrasting with the ℤ Anti-Escher theorem imported from the catalog.

## Synthesis
"Escher staircase" = strict ascending ideal chain = certificate of
non-Noetherianity; the loop-back is automatic and the paradox dissolves.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace Escher

variable {R : Type*} [CommRing R]

/-- An **Escher staircase** in a commutative ring `R`: an infinite strictly
ascending chain of ideals `I₀ ⊊ I₁ ⊊ I₂ ⊊ ⋯`. -/
structure Staircase (R : Type*) [CommRing R] where
  /-- The ideals of the chain. -/
  I : ℕ → Ideal R
  /-- The chain is strictly ascending. -/
  strict : StrictMono I

namespace Staircase

/-- **Loop-back lemma.** The infinite intersection of an ascending chain of ideals
is precisely its first term.  The Escher staircase always "loops back" to where it
started, so there is nothing paradoxical about the intersection. -/
theorem iInf_eq_first (S : Staircase R) : ⨅ n, S.I n = S.I 0 := by
  refine' le_antisymm ( iInf_le _ _ ) ( le_iInf _ );
  exact fun n => S.strict.monotone n.zero_le

end Staircase

/-- A ring carrying an Escher staircase fails the ascending chain condition, hence
is not Noetherian. -/
theorem not_isNoetherianRing_of_staircase (S : Staircase R) :
    ¬ IsNoetherianRing R := by
  intro hN;
  exact not_strictMono_of_wellFoundedGT S.I S.strict

/-- Every non-Noetherian commutative ring carries an Escher staircase. -/
theorem nonempty_staircase_of_not_isNoetherianRing (h : ¬ IsNoetherianRing R) :
    Nonempty (Staircase R) := by
  -- By definition of `IsNoetherianRing`, there exists a strictly ascending chain of ideals in `R`.
  have h_chain : ∃ f : ℕ → Ideal R, (∀ n, f n < f (n + 1)) := by
    contrapose! h;
    rw [ isNoetherianRing_iff ];
    rw [ isNoetherian_iff ];
    rw [ WellFounded.wellFounded_iff_has_min ];
    intro s hs;
    contrapose! h;
    choose! f hf using h;
    exact ⟨ fun n => Nat.recOn n hs.some fun n ih => f ih, fun n => hf _ ( show Nat.recOn n hs.some ( fun n ih => f ih ) ∈ s from Nat.recOn n hs.choose_spec fun n ih => hf _ ih |>.1 ) |>.2 ⟩;
  exact ⟨ ⟨ h_chain.choose, strictMono_nat_of_lt_succ h_chain.choose_spec ⟩ ⟩

/-- **Characterization of non-Noetherianity by Escher staircases.**  A commutative
ring admits an Escher staircase (a strictly ascending infinite chain of ideals) iff
it is not Noetherian.  The existence of the "impossible staircase" is exactly the
failure of the ascending chain condition. -/
theorem nonempty_staircase_iff_not_isNoetherianRing :
    Nonempty (Staircase R) ↔ ¬ IsNoetherianRing R :=
  ⟨fun ⟨S⟩ => not_isNoetherianRing_of_staircase S,
    nonempty_staircase_of_not_isNoetherianRing⟩

end Escher