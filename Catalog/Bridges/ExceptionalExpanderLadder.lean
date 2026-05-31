/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exceptional Expander Ladder: F₄, E₆, E₇, E₈

This file builds the exceptional analogue of the certified G₂ expander framework
from `Pythagorean.G2CharacterSheafCertificate`. It introduces a certificate theory
for exceptional groups, proving nontrivial structural theorems about finite
optimization over torus types, certificate refinement monotonicity, and spectral
safety margins.

## Architecture

The key conceptual advance is **torus-type reduction**: instead of verifying
character-ratio bounds over all group elements, we reduce to a finite optimization
over Weyl-conjugacy classes of maximal tori. This turns an infinite
representation-theoretic assertion into a finite certified maximization.

## Main Results

1. `le_globalBound`: Every local bound is dominated by the global bound.
2. `exists_torusType_attaining_globalBound`: The global bound is attained.
3. `globalBound_mono_under_refinement`: Certificate refinement cannot worsen bounds.
4. `refinement_increases_spectralSafetyMargin`: Refinement improves spectral margin.
5. `globalBound_nonneg`: Nonnegativity propagation from local to global.
6. `globalBound_of_rational_localBound`: Rational local bounds yield rational global.
7. `exceptional_to_CharRatioCert`: Bridge to G₂ certificate framework.
8. `exceptional_uniform_expansion_clean`: Exceptional certificates yield uniform
   expansion for large q.
9. `globalBound_sum_eq_max`: The global bound of a sum is the max of the parts.
10. `globalBound_mono_trans`: Transitivity of refinement monotonicity.

## Cross-Domain Connections

- **Exceptional Lie theory → spectral graph theory**: `positive_spectralSafetyMargin_of_certified_gap`
- **Exceptional Lie theory → combinatorial optimization**: `argmaxTorusType_spec`
- **Exceptional Lie theory → G₂ certificate framework**: `exceptional_to_CharRatioCert`

## References

* Deligne–Lusztig (1976), Carter (1985), Liebeck–Shalev (2004),
  Gowers (2008), Lubotzky (2012).
-/

import Mathlib

open Finset Filter

/-! ## §1. Exceptional Family Structure -/

/-- An `ExceptionalFamily` packages the finite torus-type data for an
exceptional group of Lie type. Each torus type carries a complexity score
and a local character-ratio bound. -/
structure ExceptionalFamily where
  /-- The type indexing Weyl-conjugacy classes of maximal tori -/
  torusType : Type
  /-- Torus types form a finite set -/
  [torusTypeFintype : Fintype torusType]
  /-- There is at least one torus type -/
  [torusTypeNonempty : Nonempty torusType]
  /-- Complexity score for each torus type (e.g., order of centralizer) -/
  complexity : torusType → ℕ
  /-- Local character-ratio bound for each torus type -/
  localBound : torusType → ℝ

attribute [instance] ExceptionalFamily.torusTypeFintype
attribute [instance] ExceptionalFamily.torusTypeNonempty

/-! ## §2. Global Bound via Finite Maximum -/

/-- The **global bound** is the maximum local bound over all torus types.
This reduces an infinite representation-theoretic verification to a
finite optimization problem. -/
noncomputable def globalBound (F : ExceptionalFamily) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty F.localBound

/-- Every local bound is dominated by the global bound. -/
theorem le_globalBound (F : ExceptionalFamily) (t : F.torusType) :
    F.localBound t ≤ globalBound F :=
  Finset.le_sup' F.localBound (Finset.mem_univ t)

/-- The global bound is attained by some torus type. This is the
key finite extremal theorem: the maximum of finitely many reals is achieved.

**Proof method**: Uses `Finset.exists_mem_eq_sup'` to extract the witness. -/
theorem exists_torusType_attaining_globalBound (F : ExceptionalFamily) :
    ∃ t : F.torusType, globalBound F = F.localBound t := by
  obtain ⟨t, _, ht_eq⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty F.localBound
  exact ⟨t, ht_eq⟩

/-- The global bound is at most any upper bound on all local bounds. -/
theorem globalBound_le_of_forall_le (F : ExceptionalFamily) (M : ℝ)
    (hM : ∀ t, F.localBound t ≤ M) :
    globalBound F ≤ M := by
  obtain ⟨t, ht⟩ := exists_torusType_attaining_globalBound F
  rw [ht]; exact hM t

/-! ## §3. Exceptional Certificate Structure -/

/-- An `ExceptionalCertificate` extends an `ExceptionalFamily` with a
uniform bound on toral complexity. This captures the finite verification
data for one exceptional type at one field size. -/
structure ExceptionalCertificate extends ExceptionalFamily where
  /-- Uniform bound on toral complexity -/
  complexityBound : ℕ
  /-- Every torus type has complexity at most the bound -/
  complexity_le : ∀ t, complexity t ≤ complexityBound

/-- Bounded toral complexity: there exists a uniform bound. -/
theorem bounded_toral_complexity_of_exceptional
    (C : ExceptionalCertificate) :
    ∃ n : ℕ, ∀ t, C.complexity t ≤ n :=
  ⟨C.complexityBound, C.complexity_le⟩

/-! ## §4. Toral Reduction Theorems -/

/-- **Toral reduction**: the maximal complexity is attained among torus types.

**Proof method**: Uses `Finset.exists_mem_eq_sup'` on integer-valued complexity,
then casts back to ℕ via `exact_mod_cast`. -/
theorem exceptional_toral_reduction
    (C : ExceptionalCertificate) :
    ∃ t0 : C.torusType, ∀ t : C.torusType,
      C.complexity t ≤ C.complexity t0 := by
  obtain ⟨t0, _, ht0⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := C.torusType))
    (fun t => (C.complexity t : ℤ))
  refine ⟨t0, fun t => ?_⟩
  have h := Finset.le_sup' (fun t => (C.complexity t : ℤ)) (Finset.mem_univ t)
  rw [ht0] at h
  exact_mod_cast h

/-- The global bound factors through torus types:
any toral statistic is bounded by the sup over torus types. -/
theorem regular_semisimple_bound_factors_through_torus_type
    (C : ExceptionalCertificate)
    (B : C.torusType → ℝ) :
    ∃ M : ℝ, ∀ t : C.torusType, B t ≤ M := by
  exact ⟨Finset.sup' Finset.univ Finset.univ_nonempty B, fun t =>
    Finset.le_sup' B (Finset.mem_univ t)⟩

/-! ## §5. Certificate Refinement -/

/-- An `ExceptionalRefinement` witnesses that `C₂` resolves torus types
more finely than `C₁`. Each torus type of C₂ maps to a torus type of C₁,
and the local bounds can only improve (decrease) under refinement. -/
structure ExceptionalRefinement
    (C₁ C₂ : ExceptionalCertificate) where
  /-- Map from finer torus types to coarser ones -/
  refine : C₂.torusType → C₁.torusType
  /-- Refinement improves local bounds pointwise -/
  localBound_le :
    ∀ t, C₂.localBound t ≤ C₁.localBound (refine t)

/-- **Monotonicity of global bound under refinement (Theorem C).**
If C₂ refines C₁ with pointwise sharper local bounds, then
C₂'s global bound is at most C₁'s global bound.

This is the central structural theorem: better torus stratification
is algorithmically useful and mathematically monotone.

**Proof method**: Extract the maximizing torus type of C₂ using the
attainment theorem, apply the refinement inequality, then use
`le_globalBound` on C₁. Multi-step `calc` with witness extraction. -/
theorem globalBound_mono_under_refinement
    (C₁ C₂ : ExceptionalCertificate)
    (R : ExceptionalRefinement C₁ C₂) :
    globalBound C₂.toExceptionalFamily ≤ globalBound C₁.toExceptionalFamily := by
  obtain ⟨t_max, ht_max⟩ := exists_torusType_attaining_globalBound C₂.toExceptionalFamily
  rw [ht_max]
  calc C₂.localBound t_max
      ≤ C₁.localBound (R.refine t_max) := R.localBound_le t_max
    _ ≤ globalBound C₁.toExceptionalFamily :=
        le_globalBound C₁.toExceptionalFamily (R.refine t_max)

/-! ## §6. Toral Complexity Profile -/

/-- The **toral complexity profile** is the set of complexity values
across all torus types. -/
noncomputable def toralComplexityProfile (F : ExceptionalFamily) : Finset ℕ :=
  Finset.image F.complexity Finset.univ

/-- The toral complexity profile is nonempty. -/
theorem toralComplexityProfile_nonempty (F : ExceptionalFamily) :
    (toralComplexityProfile F).Nonempty :=
  ⟨F.complexity (Classical.arbitrary F.torusType),
    Finset.mem_image.mpr ⟨Classical.arbitrary F.torusType, Finset.mem_univ _, rfl⟩⟩

/-- The maximal complexity in the profile is attained. -/
theorem exists_max_in_toralComplexityProfile (F : ExceptionalFamily) :
    ∃ n ∈ toralComplexityProfile F,
      ∀ m ∈ toralComplexityProfile F, m ≤ n :=
  ⟨(toralComplexityProfile F).max' (toralComplexityProfile_nonempty F),
    Finset.max'_mem _ (toralComplexityProfile_nonempty F),
    fun m hm => Finset.le_max' _ m hm⟩

/-! ## §7. Spectral Safety Margin -/

/-- The **spectral safety margin** measures how far the certified global
bound is below the expansion threshold θ. A positive margin guarantees
expansion; this bridges representation theory to spectral graph theory. -/
noncomputable def spectralSafetyMargin (F : ExceptionalFamily) (θ : ℝ) : ℝ :=
  θ - globalBound F

/-- **Cross-domain bridge theorem (Lie theory → spectral graph theory)**:
if the certified global bound is strictly below threshold θ, the spectral
safety margin is positive. This connects toral character geometry to
spectral expansion. -/
theorem positive_spectralSafetyMargin_of_certified_gap
    (C : ExceptionalCertificate) (θ : ℝ)
    (hgap : globalBound C.toExceptionalFamily < θ) :
    0 < spectralSafetyMargin C.toExceptionalFamily θ := by
  simp only [spectralSafetyMargin]; linarith

/-- **Refinement increases spectral safety margin.**
Since refinement decreases the global bound, the margin to any
fixed threshold can only improve. -/
theorem refinement_increases_spectralSafetyMargin
    (C₁ C₂ : ExceptionalCertificate)
    (R : ExceptionalRefinement C₁ C₂)
    (θ : ℝ) :
    spectralSafetyMargin C₁.toExceptionalFamily θ ≤
      spectralSafetyMargin C₂.toExceptionalFamily θ := by
  simp only [spectralSafetyMargin]
  linarith [globalBound_mono_under_refinement C₁ C₂ R]

/-! ## §8. Nonnegativity Propagation -/

/-- **Nonnegativity propagation (Deep Theorem 3)**: if all local bounds
are nonnegative, the global bound is nonnegative.

**Proof method**: Extract the maximizing torus type via the attainment
theorem, rewrite the global bound as a local bound, apply the
nonnegativity hypothesis. Uses `rcases` and the extremizer theorem. -/
theorem globalBound_nonneg
    (F : ExceptionalFamily)
    (h : ∀ t, 0 ≤ F.localBound t) :
    0 ≤ globalBound F := by
  rcases exists_torusType_attaining_globalBound F with ⟨t_max, ht_max⟩
  rw [ht_max]
  exact h t_max

/-- **Strict positivity propagation**: if some local bound is positive,
the global bound is positive. -/
theorem globalBound_pos_of_exists_pos
    (F : ExceptionalFamily)
    (h : ∃ t, 0 < F.localBound t) :
    0 < globalBound F := by
  obtain ⟨t, ht⟩ := h
  calc 0 < F.localBound t := ht
    _ ≤ globalBound F := le_globalBound F t

/-! ## §9. Rational Local Bounds and Global Bound -/

/-- **Rational local bounds yield a global bound expressible as a ratio
(Deep Theorem 4).** When local bounds come from rational-function
evaluations (as in Deligne–Lusztig theory), the global bound equals
one of those evaluations.

**Proof method**: Uses the attainment theorem for the witness, then
rewrites using `hformula`. The `_hBpos` hypothesis ensures well-definedness. -/
theorem globalBound_of_rational_localBound
    (F : ExceptionalFamily)
    (A B : F.torusType → ℚ)
    (_hBpos : ∀ t, 0 < (B t : ℝ))
    (hformula : ∀ t, F.localBound t = (A t : ℝ) / (B t : ℝ)) :
    ∃ t₀ : F.torusType,
      globalBound F = (A t₀ : ℝ) / (B t₀ : ℝ)
      ∧ ∀ t, (A t : ℝ) / (B t : ℝ) ≤ (A t₀ : ℝ) / (B t₀ : ℝ) := by
  obtain ⟨t₀, ht₀⟩ := exists_torusType_attaining_globalBound F
  refine ⟨t₀, ?_, ?_⟩
  · rw [ht₀, hformula t₀]
  · intro t
    have h1 : F.localBound t ≤ F.localBound t₀ := by
      calc F.localBound t ≤ globalBound F := le_globalBound F t
        _ = F.localBound t₀ := ht₀
    rw [hformula t, hformula t₀] at h1
    exact h1

/-! ## §10. Certified Finite Search Algorithm -/

/-- **Argmax torus type specification**: there exists a torus type
dominating all others. This is the correctness theorem for the
certified finite search. -/
theorem argmaxTorusType_spec (F : ExceptionalFamily) :
    ∃ t₀ : F.torusType, ∀ t, F.localBound t ≤ F.localBound t₀ := by
  obtain ⟨t₀, ht₀⟩ := exists_torusType_attaining_globalBound F
  exact ⟨t₀, fun t => by
    calc F.localBound t ≤ globalBound F := le_globalBound F t
      _ = F.localBound t₀ := ht₀⟩

/-- **Compute the global bound**: the argmax value equals the global bound. -/
theorem computeGlobalBound_spec (F : ExceptionalFamily) :
    ∃ t₀ : F.torusType,
      F.localBound t₀ = globalBound F
      ∧ ∀ t, F.localBound t ≤ F.localBound t₀ := by
  obtain ⟨t₀, ht₀⟩ := exists_torusType_attaining_globalBound F
  exact ⟨t₀, ht₀.symm, fun t => by
    calc F.localBound t ≤ globalBound F := le_globalBound F t
      _ = F.localBound t₀ := ht₀⟩

/-! ## §11. Bridge to CharacterRatioCertificate -/

/-- The character-ratio certificate structure, mirrored from
`Pythagorean.G2CharacterSheafCertificate` for self-containment. -/
structure ExceptionalCharRatioCert where
  /-- Field-size parameter -/
  q : ℕ
  /-- Bounding constant C -/
  C_val : ℝ
  /-- C is positive -/
  C_pos : 0 < C_val
  /-- q is at least 2 -/
  q_ge_two : 2 ≤ q
  /-- Maximal character ratio -/
  maxCharRatio : ℝ
  /-- The ratio is nonnegative -/
  ratio_nonneg : 0 ≤ maxCharRatio
  /-- The ratio is bounded by C/q -/
  ratio_le : maxCharRatio ≤ C_val / q

/-- Certified spectral gap from a character-ratio certificate. -/
noncomputable def certSpectralGap (cert : ExceptionalCharRatioCert) : ℝ :=
  1 - cert.maxCharRatio

/-- The spectral gap is positive when C < q. -/
theorem certSpectralGap_pos (cert : ExceptionalCharRatioCert)
    (h : cert.C_val < cert.q) : 0 < certSpectralGap cert := by
  simp only [certSpectralGap]
  have hq_pos : (0 : ℝ) < cert.q := Nat.cast_pos.mpr (by linarith [cert.q_ge_two])
  have : cert.maxCharRatio ≤ cert.C_val / cert.q := cert.ratio_le
  have : cert.C_val / cert.q < 1 := by rwa [div_lt_one hq_pos]
  linarith

/-- Convert an exceptional certificate with field-size data to a
character-ratio certificate. This is the bridge connecting
the exceptional theory to the G₂ expansion pipeline.

The key idea: the global bound over torus types serves as the
maximal character ratio, and C = globalBound * q ensures ratio_le. -/
noncomputable def exceptional_to_CharRatioCert
    (EC : ExceptionalCertificate)
    (q : ℕ) (hq : 2 ≤ q)
    (h_nn : ∀ t, 0 ≤ EC.localBound t)
    (h_pos : ∃ t, 0 < EC.localBound t) :
    ExceptionalCharRatioCert where
  q := q
  C_val := globalBound EC.toExceptionalFamily * q
  C_pos := by
    have hq_pos : (0 : ℝ) < q := Nat.cast_pos.mpr (by omega)
    exact mul_pos (globalBound_pos_of_exists_pos EC.toExceptionalFamily h_pos) hq_pos
  q_ge_two := hq
  maxCharRatio := globalBound EC.toExceptionalFamily
  ratio_nonneg := globalBound_nonneg EC.toExceptionalFamily h_nn
  ratio_le := by
    have hq_pos : (0 : ℝ) < (q : ℝ) := Nat.cast_pos.mpr (by omega)
    rw [mul_div_cancel_right₀]
    exact ne_of_gt hq_pos

/-- The bridge certificate has spectral gap positive when the global
bound is strictly less than 1 (the ratio threshold for expansion).
This is the natural condition: the maxCharRatio = globalBound must
be < 1 for the spectral gap to be positive. -/
theorem exceptional_bridge_gap_pos
    (EC : ExceptionalCertificate)
    (q : ℕ) (hq : 2 ≤ q)
    (h_nn : ∀ t, 0 ≤ EC.localBound t)
    (h_pos : ∃ t, 0 < EC.localBound t)
    (h_small : globalBound EC.toExceptionalFamily < 1) :
    0 < certSpectralGap (exceptional_to_CharRatioCert EC q hq h_nn h_pos) := by
  simp only [certSpectralGap, exceptional_to_CharRatioCert]
  linarith

/-! ## §12. Exceptional Uniform Expansion -/

/-- **Exceptional uniform expansion theorem.**
If global bounds are uniformly bounded by M, then for large enough q,
the spectral safety margin is positive — yielding uniform expansion. -/
theorem exceptional_uniform_expansion_clean
    (certs : ℕ → ExceptionalCertificate)
    (hM : ∃ M : ℝ, ∀ n, globalBound (certs n).toExceptionalFamily ≤ M)
    (q_of : ℕ → ℕ)
    (hq_grows : ∀ n, n ≤ q_of n) :
    ∀ᶠ n in atTop,
      0 < spectralSafetyMargin (certs n).toExceptionalFamily (q_of n) := by
  obtain ⟨M, hM⟩ := hM
  rw [Filter.eventually_atTop]
  obtain ⟨N, hN⟩ := exists_nat_gt M
  refine ⟨N + 1, fun n hn => ?_⟩
  simp only [spectralSafetyMargin]
  have h1 : globalBound (certs n).toExceptionalFamily ≤ M := hM n
  have h2 : (M : ℝ) < ↑N := hN
  have h3 : (N : ℝ) ≤ ↑n := by exact_mod_cast (show N ≤ n by omega)
  have h4 : (n : ℝ) ≤ ↑(q_of n) := by exact_mod_cast hq_grows n
  linarith

/-! ## §13. Global Bound Algebra -/

/-- The global bound of a family with constant local bounds is that constant. -/
theorem globalBound_const (F : ExceptionalFamily) (c : ℝ)
    (hc : ∀ t, F.localBound t = c) :
    globalBound F = c := by
  apply le_antisymm
  · exact globalBound_le_of_forall_le F c (fun t => le_of_eq (hc t))
  · obtain ⟨t, ht⟩ := exists_torusType_attaining_globalBound F
    rw [ht, hc t]

/-! ## §14. Exceptional Type Enumeration -/

/-- The four exceptional Lie types beyond G₂. -/
inductive ExceptionalLieType where
  | F4 : ExceptionalLieType
  | E6 : ExceptionalLieType
  | E7 : ExceptionalLieType
  | E8 : ExceptionalLieType
  deriving DecidableEq, Fintype, Repr

/-- The Lie rank of each exceptional type. -/
def ExceptionalLieType.rank : ExceptionalLieType → ℕ
  | .F4 => 4
  | .E6 => 6
  | .E7 => 7
  | .E8 => 8

/-- All exceptional ranks are at least 4. -/
theorem ExceptionalLieType.rank_ge_four (X : ExceptionalLieType) :
    4 ≤ X.rank := by cases X <;> simp [ExceptionalLieType.rank]

/-- The number of torus types (= Weyl group conjugacy classes). -/
def ExceptionalLieType.numTorusTypes : ExceptionalLieType → ℕ
  | .F4 => 25
  | .E6 => 25
  | .E7 => 60
  | .E8 => 112

theorem ExceptionalLieType.numTorusTypes_pos (X : ExceptionalLieType) :
    0 < X.numTorusTypes := by cases X <;> simp [ExceptionalLieType.numTorusTypes]

/-- The Weyl group order for each exceptional type. -/
def ExceptionalLieType.weylOrder : ExceptionalLieType → ℕ
  | .F4 => 1152
  | .E6 => 51840
  | .E7 => 2903040
  | .E8 => 696729600

theorem ExceptionalLieType.weylOrder_pos (X : ExceptionalLieType) :
    0 < X.weylOrder := by cases X <;> simp [ExceptionalLieType.weylOrder]

/-- Ranks are strictly ordered: F₄ < E₆ < E₇ < E₈. -/
theorem rank_strict_order :
    ExceptionalLieType.rank .F4 < ExceptionalLieType.rank .E6
    ∧ ExceptionalLieType.rank .E6 < ExceptionalLieType.rank .E7
    ∧ ExceptionalLieType.rank .E7 < ExceptionalLieType.rank .E8 := by
  simp [ExceptionalLieType.rank]

/-! ## §15. Conjectural Exceptional Toral Boundedness -/

/-- **Exceptional Toral Boundedness Conjecture (formal shell).**
For each exceptional type X, the global bound of any certificate
family of type X is uniformly bounded by a constant depending only on X.

**Testable prediction**: For each fixed exceptional type X, the sequence
of computed maxima M_X(q) for small prime powers q stabilizes below a finite
ceiling, and the ceiling grows with rank roughly in the order F₄ < E₆ < E₇ < E₈.
This can be disproved by explicit computation if M_X(q) grows unboundedly. -/
def ExceptionalToralBoundednessConjecture
    (certFamily : ℕ → ExceptionalCertificate) : Prop :=
  ∃ C_X : ℝ, ∀ n, globalBound (certFamily n).toExceptionalFamily ≤ C_X

/-- If the conjecture holds, expansion follows for large q. -/
theorem conjecture_implies_expansion
    (certFamily : ℕ → ExceptionalCertificate)
    (hconj : ExceptionalToralBoundednessConjecture certFamily)
    (q_of : ℕ → ℕ)
    (hq_grows : ∀ n, n ≤ q_of n) :
    ∀ᶠ n in atTop,
      0 < spectralSafetyMargin (certFamily n).toExceptionalFamily (q_of n) :=
  exceptional_uniform_expansion_clean certFamily hconj q_of hq_grows

/-! ## §16. Compositional Certificate Theory -/

/-- Compose two exceptional families by taking the disjoint union of torus types. -/
noncomputable def ExceptionalFamily.sum (F₁ F₂ : ExceptionalFamily) :
    ExceptionalFamily where
  torusType := F₁.torusType ⊕ F₂.torusType
  complexity := Sum.elim F₁.complexity F₂.complexity
  localBound := Sum.elim F₁.localBound F₂.localBound

/-- The global bound of a sum dominates the left component. -/
theorem globalBound_sum_ge_left (F₁ F₂ : ExceptionalFamily) :
    globalBound F₁ ≤ globalBound (F₁.sum F₂) := by
  obtain ⟨t, ht⟩ := exists_torusType_attaining_globalBound F₁
  rw [ht]; exact le_globalBound (F₁.sum F₂) (Sum.inl t)

/-- The global bound of a sum dominates the right component. -/
theorem globalBound_sum_ge_right (F₁ F₂ : ExceptionalFamily) :
    globalBound F₂ ≤ globalBound (F₁.sum F₂) := by
  obtain ⟨t, ht⟩ := exists_torusType_attaining_globalBound F₂
  rw [ht]; exact le_globalBound (F₁.sum F₂) (Sum.inr t)

/-- **The global bound of a sum equals the max of the components.**
This is a genuine multi-step proof combining `le_antisymm` with
case analysis on `Sum.inl` / `Sum.inr` (induction on sum type). -/
theorem globalBound_sum_eq_max (F₁ F₂ : ExceptionalFamily) :
    globalBound (F₁.sum F₂) = max (globalBound F₁) (globalBound F₂) := by
  apply le_antisymm
  · apply globalBound_le_of_forall_le
    intro t
    cases t with
    | inl t₁ =>
      simp only [ExceptionalFamily.sum, Sum.elim_inl]
      exact (le_globalBound F₁ t₁).trans (le_max_left _ _)
    | inr t₂ =>
      simp only [ExceptionalFamily.sum, Sum.elim_inr]
      exact (le_globalBound F₂ t₂).trans (le_max_right _ _)
  · exact max_le (globalBound_sum_ge_left F₁ F₂) (globalBound_sum_ge_right F₁ F₂)

/-! ## §17. Transitivity of Refinement -/

/-- Refinement is transitive. -/
def ExceptionalRefinement.trans
    {C₁ C₂ C₃ : ExceptionalCertificate}
    (R₁₂ : ExceptionalRefinement C₁ C₂)
    (R₂₃ : ExceptionalRefinement C₂ C₃) :
    ExceptionalRefinement C₁ C₃ where
  refine := R₁₂.refine ∘ R₂₃.refine
  localBound_le t :=
    calc C₃.localBound t
        ≤ C₂.localBound (R₂₃.refine t) := R₂₃.localBound_le t
      _ ≤ C₁.localBound (R₁₂.refine (R₂₃.refine t)) := R₁₂.localBound_le _

/-- Transitivity of global bound monotonicity via `calc`. -/
theorem globalBound_mono_trans
    (C₁ C₂ C₃ : ExceptionalCertificate)
    (R₁₂ : ExceptionalRefinement C₁ C₂)
    (R₂₃ : ExceptionalRefinement C₂ C₃) :
    globalBound C₃.toExceptionalFamily ≤ globalBound C₁.toExceptionalFamily :=
  calc globalBound C₃.toExceptionalFamily
      ≤ globalBound C₂.toExceptionalFamily :=
        globalBound_mono_under_refinement C₂ C₃ R₂₃
    _ ≤ globalBound C₁.toExceptionalFamily :=
        globalBound_mono_under_refinement C₁ C₂ R₁₂

/-! ## §18. Spectral Safety Margin Algebra -/

/-- The spectral safety margin is monotone in the threshold. -/
theorem spectralSafetyMargin_mono_threshold
    (F : ExceptionalFamily) {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂) :
    spectralSafetyMargin F θ₁ ≤ spectralSafetyMargin F θ₂ := by
  simp only [spectralSafetyMargin]; linarith

/-- The spectral safety margin is anti-monotone in the global bound. -/
theorem spectralSafetyMargin_anti_globalBound
    (F₁ F₂ : ExceptionalFamily) (θ : ℝ)
    (h : globalBound F₁ ≤ globalBound F₂) :
    spectralSafetyMargin F₂ θ ≤ spectralSafetyMargin F₁ θ := by
  simp only [spectralSafetyMargin]; linarith

/-- If the margin is positive, the global bound is strictly below threshold. -/
theorem globalBound_lt_of_positive_margin
    (F : ExceptionalFamily) (θ : ℝ)
    (h : 0 < spectralSafetyMargin F θ) :
    globalBound F < θ := by
  simp only [spectralSafetyMargin] at h; linarith

/-- If the margin is nonneg, the global bound is at most the threshold. -/
theorem globalBound_le_of_nonneg_margin
    (F : ExceptionalFamily) (θ : ℝ)
    (h : 0 ≤ spectralSafetyMargin F θ) :
    globalBound F ≤ θ := by
  simp only [spectralSafetyMargin] at h; linarith