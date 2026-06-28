/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Applications.InseparableBaseChange.Invariance

/-!
# Consequences of `m_f`-invariance: the splitting criterion is intrinsic to `L/K`

Building on `InseparableBaseChange.mInvariant_base_change`, this file records the structural
consequences of the invariance of `m_f = (minpoly K θ).natSepDegree` under purely inseparable base
change.  The headline consequence is that the *purely inseparable* nature of the simple compositum
`N(θ)/N` is decided entirely by `L = K(θ)/K`, independently of the purely inseparable extension
`N/K` used to base change.  This is the precise sense in which the criterion
`NL = (NL)^{pi}(NL)^{sep}` "depends only on `L/K`".

## Main results

* `InseparableBaseChange.mInvariant_eq_one_iff_isPurelyInseparable` — `m_f = 1` characterises the
  purely inseparable simple extensions.
* `InseparableBaseChange.isPurelyInseparable_simple_base_change_iff`
    (**Criterion invariance**) — `N(θ)/N` is purely inseparable iff `K(θ)/K` is; the
    purely-inseparable/separable splitting type of the simple extension is preserved.
* `InseparableBaseChange.mInvariant_dvd_natDegree` — `m_f` divides `deg f`, so the inseparable
  degree `deg f / m_f` is the complementary `p`-power factor.
* `InseparableBaseChange.natDegree_minpoly_base_change_of_separable` — when `θ` is *separable*
  over `K`, the *entire* degree is preserved: `[N(θ):N] = [K(θ):K]`.  Contrast this with the
  inseparable case, where the degree can strictly drop (see Lab Notes).

## Lab Notes

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).**  If `m_f` is base-change invariant (proved in `Invariance.lean`),
then every criterion phrased purely in terms of `m_f` is automatically intrinsic to `L/K`.  Bold
sub-conjecture: the *full degree* `[L:K]` is generally **not** invariant, so the splitting
criterion genuinely needs the separable refinement `m_f` rather than the raw degree.

**Experiment (Experimenter).**  `mInvariant_eq_one_iff_isPurelyInseparable` plus the main theorem
gives `isPurelyInseparable_simple_base_change_iff` in one rewrite.  For the degree: when `θ` is
separable, `minpoly.map_eq_of_isSeparable_of_isPurelyInseparable` shows the minimal polynomial
simply base-changes, so `natDegree` is preserved — proving
`natDegree_minpoly_base_change_of_separable`.  The inseparable example `K = 𝔽_p(a)`,
`θ = a^{1/p}`, `N = K(a^{1/p})` makes `[K(θ):K] = p` collapse to `[N(θ):N] = 1`, witnessing that
the raw degree is **not** invariant.

**Analysis (Analyst).**  The dichotomy is clean: the *separable* part of the degree (`m_f`) is
rigid under purely inseparable base change, while the *inseparable* part (`deg f / m_f`, a power of
`p`) is malleable and can be partially or wholly absorbed by `N`.  This is exactly why the paper's
criterion is stated with `m_f`: it isolates the rigid invariant.

**Critique (Critic).**  None of these are definitional: (criterion) routes through the separable
degree comparison; (degree-of-separable) routes through the minimal-polynomial base-change theorem;
(divisibility) uses irreducibility of `minpoly`.  The separability hypothesis in
`natDegree_minpoly_base_change_of_separable` is load-bearing — drop it and the conclusion is false
by the collapsing example above.

**Synthesis (PI).**  The separable degree `m_f` is the unique base-change-invariant numerical datum
of a simple extension; the splitting criterion built from it is therefore intrinsic to `L/K`.
-- !-- Lab Notes -- !--
-/

open IntermediateField Field Polynomial

namespace InseparableBaseChange

set_option maxHeartbeats 1200000

variable {K M : Type*} [Field K] [Field M] [Algebra K M]

/-- The invariant `m_f` equals `1` exactly when the simple extension `K(θ)/K` is purely
inseparable (equivalently, `f` has a single distinct root). -/
theorem mInvariant_eq_one_iff_isPurelyInseparable (θ : M) :
    mInvariant K θ = 1 ↔ IsPurelyInseparable K K⟮θ⟯ :=
  (IntermediateField.isPurelyInseparable_adjoin_simple_iff_natSepDegree_eq_one K M).symm

/-- **Criterion invariance.**  Whether the simple compositum `N(θ)/N` is purely inseparable is
decided by `L = K(θ)/K` alone: it holds iff `K(θ)/K` is purely inseparable, independently of the
purely inseparable base extension `N/K`. -/
theorem isPurelyInseparable_simple_base_change_iff
    (N : Type*) [Field N] [Algebra K N] [Algebra N M] [IsScalarTower K N M]
    [IsPurelyInseparable K N] (θ : M) (hθ : IsAlgebraic K θ) :
    IsPurelyInseparable N N⟮θ⟯ ↔ IsPurelyInseparable K K⟮θ⟯ := by
  rw [← mInvariant_eq_one_iff_isPurelyInseparable (K := N),
      ← mInvariant_eq_one_iff_isPurelyInseparable (K := K),
      mInvariant_base_change N θ hθ]

/-- `m_f` divides the degree of `f`; the quotient `deg f / m_f` is the inseparable degree, a power
of the characteristic. -/
theorem mInvariant_dvd_natDegree (θ : M) (hθ : IsAlgebraic K θ) :
    mInvariant K θ ∣ (minpoly K θ).natDegree :=
  (minpoly.irreducible hθ.isIntegral).natSepDegree_dvd_natDegree

/-- When `θ` is *separable* over `K`, the full degree is preserved under purely inseparable base
change: `[N(θ):N] = [K(θ):K]`.  (In the inseparable case the degree can strictly drop, so this is
genuinely a feature of separability — see the Lab Notes.) -/
theorem natDegree_minpoly_base_change_of_separable
    (N : Type*) [Field N] [Algebra K N] [Algebra N M] [IsScalarTower K N M]
    [IsPurelyInseparable K N] (θ : M) (hsep : IsSeparable K θ) :
    (minpoly N θ).natDegree = (minpoly K θ).natDegree := by
  rw [← minpoly.map_eq_of_isSeparable_of_isPurelyInseparable N θ hsep, natDegree_map]

end InseparableBaseChange