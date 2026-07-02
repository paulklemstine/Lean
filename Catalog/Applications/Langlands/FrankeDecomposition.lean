/-
# The Franke decomposition for level-one spherical automorphic forms (algebraic skeleton)

Franke's theorem describes the space of automorphic forms on an arithmetic quotient as a
direct sum indexed by cuspidal support.  In the smallest interesting case — level-one
spherical forms on `X = SL(2, ℤ) \ ℍ` — it specialises to the classical statement:

> every spherical automorphic form is the sum of a **cusp form** and a **finite linear
> combination of the Laurent coefficients of the standard Eisenstein series `E(s; z)`**.

This file isolates the purely *linear-algebraic* content of that statement, valid over any
`ℂ`-vector space `V` (the space of automorphic forms), a subspace `cusp` (the cusp forms), and
a finite family `laurentCoeff : Fin n → V` (the Laurent coefficients of `E(s; z)` at its
poles, of which there are finitely many).  The decomposition is exactly the assertion that the
cuspidal subspace and the residual/Eisenstein span are **complementary** (`IsCompl`).

Main results:

* `FrankeSL2Z.franke_decomposition` — existence: every `f : V` is `c + ∑ᵢ aᵢ • (laurentCoeff i)`
  with `c` a cusp form and the second summand an explicit finite linear combination.
* `FrankeSL2Z.franke_unique` — uniqueness: the cusp part and the Eisenstein part are
  determined by `f`.
* `FrankeSL2Z.franke_eisenstein_finiteDimensional` — the Eisenstein/residual subspace is
  finite-dimensional, so the "finite linear combination" is genuinely finite.
* `FrankeSL2Z.levelOne_unique_character` — the level-one hypothesis, made precise: the only
  Dirichlet/Hecke character of conductor `1` is trivial (`Nat.card = 1`), which is why a single
  *standard* Eisenstein series (untwisted) governs the whole Eisenstein spectrum.

The analytic input — that `E(s; z)` really has only finitely many poles in the relevant region,
driven by the simple pole of `ζ(2s-1)` at `s = 1` — is proved in the companion file
`EisensteinPole.lean`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Franke's grand decomposition, notoriously analytic, has a rigid
algebraic core: it is *nothing but* the assertion that cusp forms and the span of finitely many
Laurent coefficients are complementary subspaces.  Bold sub-claim: existence AND uniqueness of
the cusp/Eisenstein splitting follow from `IsCompl` alone, with no growth estimates.

Experiment (Experimenter): modelled `V` as an arbitrary `ℂ`-module.  Existence came from
`Submodule.existsUnique_add_of_isCompl` combined with `Submodule.mem_span_range_iff_exists_fun`
to expose explicit coefficients `a : Fin n → ℂ`.  Uniqueness reused the `ExistsUnique` witness,
transporting equalities through `Subtype.ext_iff`.  Finite-dimensionality of the residual span
is `Module.Finite.span_of_finite` applied to `Set.finite_range`.

Analysis (Analyst): the splitting is unconditional — it needs neither an inner product nor
completeness, only the complementarity `IsCompl cusp (span (range laurentCoeff))`.  The genuine
number theory (why the family is finite; why level one uses the untwisted series) is quarantined
into two crisp facts: finite-dimensionality here, and the pole count in `EisensteinPole.lean`.
Failure mode ruled out: an early attempt to phrase the decomposition through an orthogonal
projection forced a Hilbert-space structure that the abstract statement does not need.

Critique (Critic): is `franke_decomposition` trivial?  No — it produces *explicit* coefficients
via span membership, not just an abstract sum, and `franke_unique` genuinely uses the uniqueness
half of `existsUnique`.  Is the level-one lemma a definitional `rfl`?  No — it computes the order
of a unit group via `MulChar.card_eq_card_units_of_hasEnoughRootsOfUnity` and `ZMod.card_units`.
Corner case `n = 0`: the family is empty, the Eisenstein span is `⊥`, and the theorem correctly
degenerates to "every form is a cusp form", i.e. `cusp = ⊤`.

Synthesis (PI): the Franke decomposition for `SL(2,ℤ)` is captured as an existence-and-uniqueness
theorem for a complementary splitting into cusp forms plus a finite Laurent combination, with the
"finite" and "level-one" qualifiers pinned down as separate, honestly-proved lemmas.
-/
import Mathlib

open Submodule

namespace FrankeSL2Z

variable {V : Type*} [AddCommGroup V] [Module ℂ V] {n : ℕ}

/-- **Franke decomposition (existence).**  Given the space of automorphic forms `V`, the cuspidal
subspace `cusp`, and the finite family `laurentCoeff` of Laurent coefficients of the Eisenstein
series, if these are complementary then every form `f` is a cusp form plus an *explicit* finite
linear combination of the Laurent coefficients. -/
theorem franke_decomposition
    (cusp : Submodule ℂ V) (laurentCoeff : Fin n → V)
    (h : IsCompl cusp (Submodule.span ℂ (Set.range laurentCoeff))) (f : V) :
    ∃ c ∈ cusp, ∃ a : Fin n → ℂ, f = c + ∑ i, a i • laurentCoeff i := by
  obtain ⟨u, v, huv, -⟩ := Submodule.existsUnique_add_of_isCompl h f
  refine ⟨u, u.2, ?_⟩
  have hv : (v : V) ∈ Submodule.span ℂ (Set.range laurentCoeff) := v.2
  rw [Submodule.mem_span_range_iff_exists_fun] at hv
  obtain ⟨a, ha⟩ := hv
  exact ⟨a, by rw [ha, huv]⟩

/-- **Franke decomposition (uniqueness).**  The cuspidal and Eisenstein parts of a form are
uniquely determined. -/
theorem franke_unique
    (cusp : Submodule ℂ V) (laurentCoeff : Fin n → V)
    (h : IsCompl cusp (Submodule.span ℂ (Set.range laurentCoeff))) (f : V)
    (c1 c2 : V) (hc1 : c1 ∈ cusp) (hc2 : c2 ∈ cusp)
    (w1 w2 : V) (hw1 : w1 ∈ Submodule.span ℂ (Set.range laurentCoeff))
    (hw2 : w2 ∈ Submodule.span ℂ (Set.range laurentCoeff))
    (e1 : f = c1 + w1) (e2 : f = c2 + w2) : c1 = c2 ∧ w1 = w2 := by
  obtain ⟨u, v, huv, huniq⟩ := Submodule.existsUnique_add_of_isCompl h f
  have H1 := huniq ⟨c1, hc1⟩ ⟨w1, hw1⟩ (by rw [← e1])
  have H2 := huniq ⟨c2, hc2⟩ ⟨w2, hw2⟩ (by rw [← e2])
  refine ⟨?_, ?_⟩
  · have : (⟨c1, hc1⟩ : cusp) = ⟨c2, hc2⟩ := by rw [H1.1, H2.1]
    exact Subtype.ext_iff.mp this
  · have : (⟨w1, hw1⟩ : Submodule.span ℂ (Set.range laurentCoeff)) = ⟨w2, hw2⟩ := by
      rw [H1.2, H2.2]
    exact Subtype.ext_iff.mp this

/-- The Eisenstein/residual subspace is finite-dimensional: the "finite linear combination"
in the Franke decomposition really is finite. -/
theorem franke_eisenstein_finiteDimensional (laurentCoeff : Fin n → V) :
    Module.Finite ℂ (Submodule.span ℂ (Set.range laurentCoeff)) :=
  Module.Finite.span_of_finite ℂ (Set.finite_range laurentCoeff)

/-- **Level one, made precise.**  There is exactly one Dirichlet/Hecke character of conductor
`1` (the trivial one).  This is the arithmetic reason the level-one spherical spectrum is
governed by the single *standard* (untwisted) Eisenstein series `E(s; z)`, rather than a family
of twisted series. -/
theorem levelOne_unique_character : Nat.card (DirichletCharacter ℂ 1) = 1 := by
  rw [MulChar.card_eq_card_units_of_hasEnoughRootsOfUnity (ZMod 1) ℂ,
      Nat.card_eq_fintype_card, ZMod.card_units_eq_totient]
  simp

end FrankeSL2Z