/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Analytic Bridge for Combinatorial Species: Inversion, Differentiation, Pointing

This file extends `Catalog/Applications/CombinatorialSpecies.lean` along the
**combinatorial–categorical bridge** of Joyal.  The base file established that the
exponential generating function (EGF) `egf a = ∑ₙ (aₙ/n!) Xⁿ` is *additive* over the sum
of species (`egf_add`) and *multiplicative* over the structural (Day-convolution) product
(`egf_mul`, `egf_card_prodSpecies`).  Here we promote those scattered homomorphism
identities into the three structural pillars that make the EGF a genuine *analytic functor*:

* **Inversion / complete invariance** — `egf` is a bijection `(ℕ → ℚ) ≃ ℚ⟦X⟧` with the
  *explicit* inverse `seqOf f n = n! · coeff n f`.  Consequently two species with equal
  EGFs have equal counting sequences: the EGF is a complete invariant for labelled
  enumeration (`Species.EGF_inj`).
* **Differentiation** — the derivative species `F'[n] = F[n+1]` (adjoin a ghost label)
  maps under the EGF to the *formal derivative* `d/dX` of power series (`egf_seqDeriv`),
  and the pointed species `F^•[n] = n · F[n]` maps to `X · d/dX` (`egf_seqPoint`).
* **Leibniz** — the structural product rule `(F·G)' = F'·G + F·G'` holds at the level of
  counting sequences (`binConv_leibniz`), proved by transporting Mathlib's analytic
  Leibniz rule `derivativeFun_mul` across the bridge.

These close the species dictionary under the last basic operation (differentiation) and
turn the bridge from a merely algebraic correspondence into a *differential* one.

## Main results
* `egf_injective`, `egfEquiv`   — `egf` is a bijection with explicit inverse `seqOf`.
* `Species.EGF_inj`             — EGF is a complete invariant for labelled species.
* `egf_seqDeriv`                — EGF of the derivative species is `d/dX` of the EGF.
* `egf_seqPoint`                — EGF of the pointed species is `X · d/dX` of the EGF.
* `binConv_leibniz`             — the species product rule at sequence level.
* `egf_binConvOne`, `egf_zero`  — `egf` preserves the rig unit and zero.
-/
import Mathlib
import Applications.CombinatorialSpecies

open scoped BigOperators
open PowerSeries Finset

namespace CombinatorialSpecies

noncomputable section

/-! ### Inversion: `egf` is a bijection with an explicit inverse -/

-- !-- Lab Notebook -- !--
-- Hypothesis: `coeff n (egf a) = a n / n!` makes `a n` recoverable as `n! · coeff n (egf a)`,
--   so `egf` should be a *bijection* onto `ℚ⟦X⟧`, not merely a homomorphism.
-- Result: `seqOf` is a two-sided inverse (`seqOf_egf`, `egf_seqOf`); hence `egfEquiv`.
-- Insight: labelled enumeration loses *no* information — the EGF is a complete invariant.
-- Failure analysis: `field_simp` needs `n! ≠ 0`; `Nat.cast_ne_zero`/`factorial_ne_zero` supply it.

/-- The inverse of `egf`: recover the counting sequence from a power series by
`seqOf f n = n! · coeff n f`. -/
noncomputable def seqOf (f : ℚ⟦X⟧) (n : ℕ) : ℚ := n.factorial * PowerSeries.coeff n f

@[simp] lemma seqOf_egf (a : ℕ → ℚ) : seqOf (egf a) = a := by
  funext n; rw [seqOf, coeff_egf]; field_simp

@[simp] lemma egf_seqOf (f : ℚ⟦X⟧) : egf (seqOf f) = f := by
  ext n; rw [coeff_egf, seqOf]; field_simp

-- NOTE (build fix): `egf_injective` is already declared in
-- `Catalog/Applications/CombinatorialSpecies.lean` in this same namespace, so re-declaring it
-- here is a duplicate declaration that breaks compilation.  Commented out; all references below
-- resolve to `CombinatorialSpecies.egf_injective` from the imported base file.
-- /-- **Complete invariance.** `egf` is injective: distinct counting sequences have distinct
-- exponential generating functions. -/
-- theorem egf_injective : Function.Injective egf := by
--   intro a b h; rw [← seqOf_egf a, ← seqOf_egf b, h]

/-- **Surjectivity.** Every formal power series over `ℚ` is the EGF of some counting
sequence (namely `seqOf`). -/
theorem egf_surjective : Function.Surjective egf :=
  fun f => ⟨seqOf f, egf_seqOf f⟩

theorem egf_bijective : Function.Bijective egf :=
  ⟨egf_injective, egf_surjective⟩

/-- **The EGF dictionary as a bijection** `(ℕ → ℚ) ≃ ℚ⟦X⟧`, with explicit inverse `seqOf`.
This is the precise sense in which exponential generating functions *are* counting
sequences: nothing is lost or added in passing between the combinatorial and analytic
worlds. -/
noncomputable def egfEquiv : (ℕ → ℚ) ≃ ℚ⟦X⟧ where
  toFun := egf
  invFun := seqOf
  left_inv := seqOf_egf
  right_inv := egf_seqOf

/-- **EGF is a complete invariant for labelled species.** Two species have the same EGF
iff they have the same counting sequence `n ↦ |F[n]|`. -/
theorem Species.EGF_inj (F G : Species) :
    F.EGF = G.EGF ↔ F.coeffSeq = G.coeffSeq := by
  constructor
  · intro h
    have := egf_injective h
    funext n
    have := congrFun this n
    exact_mod_cast this
  · intro h; unfold Species.EGF; rw [h]

/-! ### The rig unit and zero -/

-- !-- coeff n of `egf 0` is `0/n! = 0`; the zero species maps to the zero series. -- !--
theorem egf_zero : egf (fun _ => (0 : ℚ)) = 0 := by
  ext n; simp [coeff_egf]

/-- The unit of the binomial-convolution product: the sequence `(1,0,0,…)` (one structure
on the empty label set, none otherwise — the species `1`). -/
def binConvOne : ℕ → ℚ := fun n => if n = 0 then 1 else 0

-- !-- Only the `n = 0` coefficient survives, giving `1/0! = 1`, i.e. the series `1`. -- !--
/-- The EGF of the rig unit `binConvOne` is the power-series unit `1`. -/
theorem egf_binConvOne : egf binConvOne = 1 := by
  ext n; rw [coeff_egf, binConvOne]
  cases n with
  | zero => simp
  | succ m => simp

/-! ### Differentiation and pointing -/

-- !-- Lab Notebook -- !--
-- Hypothesis: differentiating an EGF shifts `aₙ/n! ↦ a_{n+1}/n!`, which is the coefficient
--   sequence of the derivative species `F'[n] = F[n+1]`.
-- Result: `egf_seqDeriv` (derivative law) and `egf_seqPoint` (pointing, `X·d/dX`).
-- Insight: with Mathlib's formal derivative `derivativeFun` the analytic side is free, so
--   each law is a one-line coefficient computation on top of `coeff_egf`.
-- Failure analysis: `field_simp` already closes the goal; an extra `ring` over-solves
--   ("no goals"). The pointing law needs a split at `n = 0` (`coeff_zero_X_mul`).

/-- The derivative of a counting sequence: `(seqDeriv a)ₙ = a_{n+1}` (the derivative species
`F'[n] = F[n+1]`, obtained by adjoining a distinguished ghost label). -/
def seqDeriv (a : ℕ → ℚ) : ℕ → ℚ := fun n => a (n + 1)

/-- **Derivative law.** The EGF of the derivative species is the formal derivative `d/dX`
of the EGF. -/
theorem egf_seqDeriv (a : ℕ → ℚ) : egf (seqDeriv a) = (egf a).derivativeFun := by
  ext n
  simp only [seqDeriv, coeff_egf, coeff_derivativeFun, Nat.factorial_succ]
  push_cast; field_simp

/-- The pointing of a counting sequence: `(seqPoint a)ₙ = n · aₙ` (the pointed species
`F^•[n] = [n] × F[n]`, marking one of the `n` labels). -/
def seqPoint (a : ℕ → ℚ) : ℕ → ℚ := fun n => (n : ℚ) * a n

/-- **Pointing law.** The EGF of the pointed species is `X · d/dX` of the EGF. -/
theorem egf_seqPoint (a : ℕ → ℚ) : egf (seqPoint a) = X * (egf a).derivativeFun := by
  ext n
  cases n with
  | zero => simp [seqPoint, coeff_egf, coeff_zero_X_mul]
  | succ m =>
    simp only [seqPoint, coeff_egf, coeff_succ_X_mul, coeff_derivativeFun,
      Nat.factorial_succ]
    push_cast; field_simp

/-! ### The structural Leibniz rule -/

-- !-- Lab Notebook -- !--
-- Hypothesis: the species product rule `(F·G)' = F'·G + F·G'` should follow from the
--   analytic Leibniz rule by transporting along the (injective) EGF bridge.
-- Result: `binConv_leibniz` — a purely combinatorial identity on binomial convolutions,
--   proved with zero index manipulation by going to power series and back.
-- Insight: injectivity of `egf` upgrades every analytic identity into a combinatorial one;
--   `derivativeFun_mul` does the real work, `egf_mul`/`egf_add`/`egf_seqDeriv` translate.
-- Failure analysis: `derivativeFun_mul` is stated with `•`; rewrite `smul_eq_mul` and let
--   `ring` reconcile commutativity before applying `egf_injective`.

/-- **Structural product rule (Leibniz) for species.** At the level of counting sequences,
the derivative of a binomial convolution satisfies the Leibniz rule
`(a ⋆ b)' = a' ⋆ b + a ⋆ b'`.  This is the enumerative content of the species isomorphism
`(F·G)' ≅ F'·G + F·G'`, obtained by transporting Mathlib's analytic Leibniz rule across the
EGF bridge via `egf_injective`. -/
theorem binConv_leibniz (a b : ℕ → ℚ) :
    seqDeriv (binConv a b)
      = fun n => binConv (seqDeriv a) b n + binConv a (seqDeriv b) n := by
  apply egf_injective
  rw [egf_seqDeriv, egf_mul, derivativeFun_mul]
  rw [egf_add, egf_mul, egf_mul, egf_seqDeriv, egf_seqDeriv]
  simp only [smul_eq_mul]
  ring

end

end CombinatorialSpecies