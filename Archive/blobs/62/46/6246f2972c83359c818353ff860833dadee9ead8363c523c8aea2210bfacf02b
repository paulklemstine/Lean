/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Homotopy Cardinality of Species: the EGF Coefficient as a Groupoid Cardinality

This file extends the combinatorial–categorical bridge of
`Catalog/Applications/CombinatorialSpecies.lean` (and its analytic / ring-theoretic
siblings `SpeciesAnalyticBridge.lean`, `SpeciesConvolutionRing.lean`) in a genuinely
*homotopical* direction.

The base files established the exponential generating function (EGF)
`egf a = ∑ₙ (aₙ/n!) Xⁿ` as a ring isomorphism `(ℕ → ℚ, ⋆) ≃+* ℚ⟦X⟧`.  But the EGF
coefficient `aₙ/n! = |F[n]|/n!` carries a deeper meaning that the algebraic bridge does
not see: it is the **homotopy (groupoid) cardinality** of the *action groupoid*
`F[n] ⫽ Sₙ` — the homotopy quotient of the structure set `F[n]` by the relabelling action
of the symmetric group `Sₙ = Perm (Fin n)`.

Recall the homotopy cardinality of a finite groupoid `𝒢` is
`|𝒢| = ∑_{[x]∈π₀𝒢} 1 / |Aut(x)|`, the sum over isomorphism classes of the reciprocal of
the automorphism group.  For an action groupoid `X ⫽ G`, isomorphism classes are orbits and
automorphism groups are stabilizers, so

  `|X ⫽ G| = ∑_{orbits ω} 1 / |Stab(ω)| = |X| / |G|`        (`groupoidCard_eq`)

the last equality being orbit–stabilizer + the orbit decomposition.  Specialized to the
relabelling action of `Sₙ` on `F[n]` (cardinality `n!`), this gives the central identity

  `coeff n (EGF F) = |F[n]| / n! = |F[n] ⫽ Sₙ|`             (`Species.EGF_coeff_eq_actionGroupoidCard`)

i.e. **the EGF is the homotopy-cardinality generating function**: the analytic functor of
Joyal's theory is literally counting structures *up to homotopy* (relabelling), with each
structure weighted by the reciprocal of its symmetry group.  This is the homotopy-theoretic
content underlying the `1/n!` in every exponential generating function.

As payoff we read off two emblematic homotopy cardinalities:

* the species of sets `E` has `|E[n] ⫽ Sₙ| = 1/n!` (a single structure with full symmetry
  `Sₙ`), recovering `coeff n (exp ℚ)` — the homotopy meaning of `EGF_setSpecies`;
* the species of linear orders `L` has `|L[n] ⫽ Sₙ| = 1` (the relabelling action is a
  *torsor*: free and transitive, so the homotopy quotient is contractible / a single point),
  the homotopy meaning of `egf_linearOrderSpecies`.

## Main results
* `groupoidCard_eq`                              — homotopy cardinality of an action groupoid
                                                   `= |X|/|G|` (orbit–stabilizer, in `ℚ`).
* `Species.actionGroupoidCard_eq`                — `|F[n] ⫽ Sₙ| = |F[n]|/n!`.
* `Species.EGF_coeff_eq_actionGroupoidCard`      — the EGF coefficient *is* the homotopy
                                                   cardinality of the action groupoid.
* `setSpecies_actionGroupoidCard`                — `|E[n] ⫽ Sₙ| = 1/n!` (full symmetry).
* `linearOrderSpecies_actionGroupoidCard`        — `|L[n] ⫽ Sₙ| = 1` (torsor / contractible).
-/
import Mathlib
import Catalog.Applications.SpeciesConvolutionRing

open scoped BigOperators
open PowerSeries Finset MulAction

namespace CombinatorialSpecies

noncomputable section

/-! ### Homotopy cardinality of an action groupoid -/

-- !-- Lab Notebook -- !--
-- Hypothesis: the homotopy cardinality `∑_{orbits} 1/|Stab|` of the action groupoid `X ⫽ G`
--   should equal the "naive" cardinality ratio `|X|/|G|` for any finite group action — the
--   homotopy-theoretic refinement of Lagrange's theorem / orbit counting.
-- Result: `groupoidCard_eq`, proved in `ℚ` from `card_orbit_mul_card_stabilizer_eq_card_group`
--   (orbit–stabilizer) and `selfEquivSigmaOrbits` (orbit decomposition `X ≃ Σ_ω orbit ω`).
-- Insight: `1/|Stab(ω)| = |orbit ω|/|G|` per orbit (orbit–stabilizer), and summing the orbit
--   sizes rebuilds `|X|`; the `1/|Stab|` weighting is exactly homotopy cardinality.
-- Failure analysis: `orbit G ω.out` lacked a `Fintype` instance under a generic `[Fintype β]`;
--   supplied it noncomputably via `Fintype.ofFinite`. `div_eq_div_iff` + `exact_mod_cast`
--   discharges the per-orbit identity without `field_simp` over-solving.

/-- **Homotopy (groupoid) cardinality of an action groupoid.** For a finite group `G` acting
on a finite type `β`, the homotopy cardinality of the action groupoid `β ⫽ G`, namely the sum
over orbits of the reciprocal stabilizer size `∑_ω 1/|Stab(ω)|`, equals `|β|/|G|`.  This is
the homotopy-theoretic refinement of orbit counting: the orbit–stabilizer theorem
`|orbit| · |Stab| = |G|` turns each summand into `|orbit ω|/|G|`, and the orbit decomposition
`β ≃ Σ_ω orbit ω` sums these back to `|β|/|G|`. -/
theorem groupoidCard_eq (G β : Type*) [Group G] [Fintype G] [MulAction G β] [Fintype β]
    [Fintype (orbitRel.Quotient G β)] [∀ b : β, Fintype (stabilizer G b)] :
    ∑ ω : orbitRel.Quotient G β, (1 : ℚ) / Fintype.card (stabilizer G ω.out)
      = (Fintype.card β : ℚ) / Fintype.card G := by
  classical
  letI : ∀ b : β, Fintype (orbit G b) := fun _ => Fintype.ofFinite _
  have hcard : (Fintype.card β : ℚ)
      = ∑ ω : orbitRel.Quotient G β, (Fintype.card (orbit G ω.out) : ℚ) := by
    rw [← Nat.cast_sum]; congr 1; rw [← Fintype.card_sigma]
    exact Fintype.card_congr (selfEquivSigmaOrbits G β)
  rw [hcard, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro ω _
  have h := card_orbit_mul_card_stabilizer_eq_card_group G ω.out
  have hst : (Fintype.card (stabilizer G ω.out) : ℚ) ≠ 0 := by positivity
  have hG : (Fintype.card G : ℚ) ≠ 0 := by positivity
  rw [div_eq_div_iff hst hG, one_mul]; exact_mod_cast h.symm

/-! ### The action groupoid of a species and its homotopy cardinality -/

-- !-- The relabelling hom `Sₙ →* Perm (F[n])` is exactly a `MulAction` of `Sₙ` on `F[n]`. -- !--
/-- The relabelling action of `Sₙ = Perm (Fin n)` on the structure set `F[n]`, read off from
the functoriality hom `F.act n : Perm (Fin n) →* Perm (F[n])`.  This is the action whose
homotopy quotient `F[n] ⫽ Sₙ` is the groupoid of `F`-structures up to relabelling. -/
noncomputable def Species.actMulAction (F : Species) (n : ℕ) :
    MulAction (Equiv.Perm (Fin n)) (F.obj n) :=
  MulAction.compHom (F.obj n) (F.act n)

/-- The **homotopy cardinality of the action groupoid** `F[n] ⫽ Sₙ`: the sum over orbits
(isomorphism classes of `F`-structures on `n` labels) of the reciprocal automorphism-group
size.  This is the homotopy-theoretic count of `F`-structures up to relabelling. -/
noncomputable def Species.actionGroupoidCard (F : Species) (n : ℕ) : ℚ :=
  letI := F.actMulAction n
  letI : Fintype (orbitRel.Quotient (Equiv.Perm (Fin n)) (F.obj n)) := Fintype.ofFinite _
  letI : ∀ b : F.obj n, Fintype (stabilizer (Equiv.Perm (Fin n)) b) := fun _ => Fintype.ofFinite _
  ∑ ω : orbitRel.Quotient (Equiv.Perm (Fin n)) (F.obj n),
      (1 : ℚ) / Fintype.card (stabilizer (Equiv.Perm (Fin n)) ω.out)

-- !-- Lab Notebook -- !--
-- Hypothesis: specializing `groupoidCard_eq` to `G = Sₙ`, `β = F[n]` should give
--   `|F[n] ⫽ Sₙ| = |F[n]|/n!`, since `|Sₙ| = |Perm (Fin n)| = n!`.
-- Result: `Species.actionGroupoidCard_eq`, an immediate corollary via `Fintype.card_perm`,
--   `Fintype.card_fin`.
-- Insight: the homotopy quotient's cardinality is the EGF denominator `n!` made manifest —
--   the `1/n!` of an EGF is the reciprocal of `|Sₙ|`, i.e. the symmetry being quotiented out.
-- Failure analysis: instance defeq — the `letI` Fintype choices in `actionGroupoidCard` must
--   be re-established in the proof so the rewrite by `groupoidCard_eq` matches the body.

/-- **The action-groupoid cardinality of a species is `|F[n]|/n!`.** Specializing the
orbit–stabilizer homotopy-cardinality formula to the relabelling action of `Sₙ` (of order
`n!`) on `F[n]`. -/
theorem Species.actionGroupoidCard_eq (F : Species) (n : ℕ) :
    F.actionGroupoidCard n = (Fintype.card (F.obj n) : ℚ) / n.factorial := by
  letI := F.actMulAction n
  letI : Fintype (orbitRel.Quotient (Equiv.Perm (Fin n)) (F.obj n)) := Fintype.ofFinite _
  letI : ∀ b : F.obj n, Fintype (stabilizer (Equiv.Perm (Fin n)) b) := fun _ => Fintype.ofFinite _
  have key := groupoidCard_eq (Equiv.Perm (Fin n)) (F.obj n)
  rw [Fintype.card_perm, Fintype.card_fin] at key
  exact key

/-! ### The EGF coefficient is the homotopy cardinality -/

-- !-- Lab Notebook -- !--
-- Hypothesis: combining `actionGroupoidCard_eq` (= |F[n]|/n!) with `coeff_egf`
--   (`coeff n (EGF F) = coeffSeq n / n! = |F[n]|/n!`) should identify the EGF coefficient
--   with the homotopy cardinality of the action groupoid.
-- Result: `Species.EGF_coeff_eq_actionGroupoidCard` — the EGF *is* the homotopy-cardinality
--   generating function of the species.
-- Insight: this is the conceptual unification — Joyal's "analytic functor" is the homotopy
--   cardinality of the groupoid of labelled structures, and the `1/n!` is the homotopy
--   quotient by `Sₙ`, not a mere normalization.
-- Failure analysis: `Species.coeffSeq` is definitionally `Fintype.card (F.obj n)`, so the two
--   `|F[n]|/n!` shapes agree after `coeff_egf`, `Species.EGF`, `Species.coeffSeq` unfold.

/-- **The EGF coefficient is a homotopy cardinality.** The `n`-th coefficient of the
exponential generating function of a species equals the homotopy (groupoid) cardinality of
the action groupoid `F[n] ⫽ Sₙ` of `F`-structures up to relabelling.  This is the homotopy
interpretation of Joyal's analytic functor: the EGF counts structures up to homotopy, each
weighted by the reciprocal of its automorphism group. -/
theorem Species.EGF_coeff_eq_actionGroupoidCard (F : Species) (n : ℕ) :
    PowerSeries.coeff (R := ℚ) n F.EGF = F.actionGroupoidCard n := by
  rw [Species.actionGroupoidCard_eq, Species.EGF, coeff_egf]
  norm_num [Species.coeffSeq]

/-! ### Two emblematic homotopy cardinalities -/

-- !-- `|E[n]| = |Unit| = 1`, so `actionGroupoidCard_eq` gives `1/n!`: one structure, full
--     symmetry `Sₙ`.  Matches `coeff n (exp ℚ)` (cf. `EGF_setSpecies`). -- !--
/-- **Species of sets: full symmetry.** The action groupoid `E[n] ⫽ Sₙ` of the species of
sets has homotopy cardinality `1/n!` — a single structure (the unique set structure) whose
automorphism group is the entire symmetric group `Sₙ`.  This is the homotopy meaning of
`coeff n (exp ℚ) = 1/n!` (cf. `EGF_setSpecies`). -/
theorem setSpecies_actionGroupoidCard (n : ℕ) :
    setSpecies.actionGroupoidCard n = 1 / n.factorial := by
  rw [Species.actionGroupoidCard_eq]
  simp [setSpecies]

-- !-- `|L[n]| = |Perm (Fin n)| = n!`, so `actionGroupoidCard_eq` gives `n!/n! = 1`: the
--     regular `Sₙ`-action is a torsor, the homotopy quotient is contractible. -- !--
/-- **Species of linear orders: a torsor.** The action groupoid `L[n] ⫽ Sₙ` of the species
of linear orders has homotopy cardinality `1`: the relabelling action of `Sₙ` on the `n!`
linear orders is free and transitive (a torsor), so the homotopy quotient is contractible —
a single point with trivial automorphisms.  This is the homotopy meaning of
`(1 - X) · EGF(L) = 1` (cf. `egf_linearOrderSpecies`). -/
theorem linearOrderSpecies_actionGroupoidCard (n : ℕ) :
    linearOrderSpecies.actionGroupoidCard n = 1 := by
  rw [Species.actionGroupoidCard_eq]
  have h : Fintype.card (linearOrderSpecies.obj n) = n.factorial := by
    simp [linearOrderSpecies, Fintype.card_perm]
  rw [h, div_self]
  exact_mod_cast n.factorial_ne_zero

end

end CombinatorialSpecies