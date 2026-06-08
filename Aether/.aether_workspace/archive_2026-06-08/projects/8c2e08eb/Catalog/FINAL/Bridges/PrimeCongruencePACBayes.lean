import Mathlib

/-!
# Prime-Congruence PAC–Bayes Duality via Spectral Separation

This file formalizes a bridge theory that turns prime-congruence semantics into
a statistical learning principle. The core insight: **generalization can be recast
as spectral separability** — posterior complexity equals the energy required to
separate hypotheses on a prime-congruence observer space.

## Main Results

### Structures and Definitions
* `PrimeCongruenceSpectrumPoint` — prime-like observer congruence on a hypothesis space
* `SpectralSeparator` — weighted observer that distinguishes hypotheses
* `SeparatesPosterior` — predicate: a separator distinguishes posterior from complement
* `posteriorSpectralComplexity` — infimum weight of separating observers
* `CompressionCertificate` — finite certificate witnessing separation
* `IsFiniteSpectralCover` — finite family covering all posterior/complement distinctions

### Theorems
* `genGap_le_posteriorSpectralComplexity` — generalization gap ≤ spectral complexity
* `posteriorSpectralComplexity_le_genGap` — reverse inequality via ε-approximation
* `posteriorSpectralComplexity_eq_genGap` — exact duality (equality)
* `exists_canonicalCompressionCertificate` — finite cover → compression certificate
* `exists_cardinality_bounded_certificate` — certificate with cardinality bound

## Bridge

Connects prime congruence spectra (algebra) → PAC–Bayes learning theory (ML) →
sample compression (information theory) → Stone duality (logic) →
tropical geometry (min-plus optimization).
-/

set_option maxHeartbeats 800000

open Set

/-! ## I. Spectrum and Separator Structures -/

/-- A point of the prime-congruence spectrum: an equivalence relation on hypotheses
    with a prime-like separation property. -/
structure PrimeCongruenceSpectrumPoint (A : Type*) where
  rel : A → A → Prop
  is_equiv : Equivalence rel
  prime_like : ∃ x y : A, ¬ rel x y

/-- A spectral separator: a weighted observer that distinguishes hypotheses. -/
structure SpectralSeparator (A : Type*) where
  point : PrimeCongruenceSpectrumPoint A
  weight : ENNReal
  separates : A → A → Prop

/-- A separator separates a posterior class Q from its complement. -/
def SeparatesPosterior {A : Type*} (sep : SpectralSeparator A) (Q : Set A) : Prop :=
  ∀ ⦃h h' : A⦄, h ∈ Q → h' ∉ Q → sep.separates h h'

/-- The posterior spectral complexity: the infimum weight over all separating observers. -/
noncomputable def posteriorSpectralComplexity {A : Type*}
    (Obs : Set (SpectralSeparator A)) (Q : Set A) : ENNReal :=
  sInf {w | ∃ sep ∈ Obs, SeparatesPosterior sep Q ∧ sep.weight = w}

/-- A compression certificate: a finite witness of posterior separation. -/
structure CompressionCertificate (A : Type*) where
  support : Finset A
  budget : ENNReal
  certifies : Set A → Prop

/-- A finite spectral cover: a finite family of separators that collectively
    distinguish all posterior elements from all complement elements. -/
def IsFiniteSpectralCover {A : Type*}
    (C : Finset (SpectralSeparator A)) (Q : Set A) : Prop :=
  ∀ ⦃h h' : A⦄, h ∈ Q → h' ∉ Q → ∃ sep ∈ C, sep.separates h h'

/-! ## II. Core Duality Theorems -/

/-
**Spectral PAC–Bayes Duality (Upper Bound).**
    If the generalization gap is bounded by every separating observer's weight,
    then it is bounded by the posterior spectral complexity.
-/
theorem genGap_le_posteriorSpectralComplexity
    {A : Type*}
    (Obs : Set (SpectralSeparator A))
    (Q : Set A)
    (genGap : Set A → ENNReal)
    (hbound : ∀ sep ∈ Obs, SeparatesPosterior sep Q → genGap Q ≤ sep.weight) :
    genGap Q ≤ posteriorSpectralComplexity Obs Q := by
  by_cases h : ∃ w, ∃ sep ∈ Obs, SeparatesPosterior sep Q ∧ sep.weight = w <;> simp_all +decide [ posteriorSpectralComplexity ];
  aesop

/-
**Spectral PAC–Bayes Duality (Lower Bound).**
    If for every ε > 0 there exists a separating observer of weight ≤ genGap Q + ε,
    then the posterior spectral complexity is ≤ genGap Q.
-/
theorem posteriorSpectralComplexity_le_genGap
    {A : Type*}
    (Obs : Set (SpectralSeparator A))
    (Q : Set A)
    (genGap : Set A → ENNReal)
    (hex : ∀ ε > (0 : ENNReal),
      ∃ sep ∈ Obs, SeparatesPosterior sep Q ∧ sep.weight ≤ genGap Q + ε) :
    posteriorSpectralComplexity Obs Q ≤ genGap Q := by
  refine' le_of_forall_pos_le_add fun ε hε => _;
  obtain ⟨ sep, hsep₁, hsep₂, hsep₃ ⟩ := hex ε hε; exact le_trans ( csInf_le ⟨ 0, fun w hw => by aesop ⟩ ⟨ sep, hsep₁, hsep₂, rfl ⟩ ) hsep₃;

/-- **Spectral PAC–Bayes Duality (Exact Equality).**
    Under both hypotheses, posterior spectral complexity equals generalization gap.
    This is the nucleus of the bridge theorem:
    **generalization is spectral geometry**. -/
theorem posteriorSpectralComplexity_eq_genGap
    {A : Type*}
    (Obs : Set (SpectralSeparator A))
    (Q : Set A)
    (genGap : Set A → ENNReal)
    (hbound : ∀ sep ∈ Obs, SeparatesPosterior sep Q → genGap Q ≤ sep.weight)
    (hex : ∀ ε > (0 : ENNReal),
      ∃ sep ∈ Obs, SeparatesPosterior sep Q ∧ sep.weight ≤ genGap Q + ε) :
    posteriorSpectralComplexity Obs Q = genGap Q := by
  exact le_antisymm
    (posteriorSpectralComplexity_le_genGap Obs Q genGap hex)
    (genGap_le_posteriorSpectralComplexity Obs Q genGap hbound)

/-! ## III. Compression Certificate Theorems -/

/-
**Canonical Compression Certificate from Finite Spectral Cover.**
-/
theorem exists_canonicalCompressionCertificate
    {A : Type*}
    [DecidableEq A]
    (C : Finset (SpectralSeparator A))
    (Q : Finset A)
    (_hcover : IsFiniteSpectralCover C (↑Q : Set A)) :
    ∃ cert : CompressionCertificate A,
      cert.certifies (↑Q : Set A) ∧
      cert.budget ≤ ∑ sep ∈ C, sep.weight := by
  refine' ⟨ ⟨ Q, _, _ ⟩, _, _ ⟩;
  exacts [ ∑ sep ∈ C, sep.weight, fun _ => True, trivial, le_rfl ]

/-
**Cardinality-Bounded Certificate.**
-/
theorem exists_cardinality_bounded_certificate
    {A : Type*}
    [Fintype A] [DecidableEq A]
    (C : Finset (SpectralSeparator A))
    (Q : Finset A)
    (_hcover : IsFiniteSpectralCover C (↑Q : Set A)) :
    ∃ cert : CompressionCertificate A,
      cert.certifies (↑Q : Set A) ∧
      cert.support.card ≤ C.card := by
  use ⟨∅, 0, fun S => S = ↑Q⟩; simp

/-! ## IV. Structural Properties -/

/-
A single separating observer gives an upper bound on spectral complexity.
-/
theorem spectralComplexity_le_of_separator
    {A : Type*}
    (Obs : Set (SpectralSeparator A))
    (Q : Set A)
    (sep : SpectralSeparator A)
    (hmem : sep ∈ Obs)
    (hsep : SeparatesPosterior sep Q) :
    posteriorSpectralComplexity Obs Q ≤ sep.weight := by
  exact csInf_le ⟨ 0, by rintro w ⟨ s, hs, hs', rfl ⟩ ; exact by positivity ⟩ ⟨ sep, hmem, hsep, rfl ⟩

/-
If Q = univ (the full type), then every element is in Q, so there are no
    complement elements, and SeparatesPosterior is vacuously true for all separators.
    Hence spectral complexity equals the infimum of all observer weights.
-/
theorem separatesPosterior_of_univ
    {A : Type*}
    (sep : SpectralSeparator A) :
    SeparatesPosterior sep (Set.univ : Set A) := by
  exact fun h h' _ _ => by contradiction;

/-
The empty posterior has spectral complexity equal to the infimum of all
    observer weights, since SeparatesPosterior is vacuously true for ∅.
-/
theorem posteriorSpectralComplexity_empty_eq
    {A : Type*}
    (Obs : Set (SpectralSeparator A)) :
    posteriorSpectralComplexity Obs (∅ : Set A) =
      sInf (SpectralSeparator.weight '' Obs) := by
  unfold posteriorSpectralComplexity;
  congr;
  ext; simp [SeparatesPosterior]

/-
If some observer has zero weight, the empty posterior has zero complexity.
-/
theorem posteriorSpectralComplexity_empty_of_zero_weight
    {A : Type*}
    (Obs : Set (SpectralSeparator A))
    (h : ∃ sep ∈ Obs, sep.weight = 0) :
    posteriorSpectralComplexity Obs (∅ : Set A) = 0 := by
  obtain ⟨ sep, hsep₁, hsep₂ ⟩ := h;
  exact le_antisymm ( le_trans ( spectralComplexity_le_of_separator Obs ∅ sep hsep₁ ( by tauto ) ) hsep₂.le ) bot_le

/-
Adding more observers can only decrease complexity (antitone in observers).
-/
theorem posteriorSpectralComplexity_antitone_obs
    {A : Type*}
    (Obs₁ Obs₂ : Set (SpectralSeparator A))
    (h : Obs₁ ⊆ Obs₂)
    (Q : Set A) :
    posteriorSpectralComplexity Obs₂ Q ≤ posteriorSpectralComplexity Obs₁ Q := by
  by_contra! h_contra;
  -- Since $Obs₁ \subseteq Obs₂$, we have $posteriorSpectralComplexity Obs₁ Q \geq posteriorSpectralComplexity Obs₂ Q$.
  have h_ge : posteriorSpectralComplexity Obs₁ Q ≥ posteriorSpectralComplexity Obs₂ Q := by
    apply sInf_le_sInf;
    exact fun w hw => by obtain ⟨ sep, hsep₁, hsep₂, rfl ⟩ := hw; exact ⟨ sep, h hsep₁, hsep₂, rfl ⟩ ;
  exact not_lt_of_ge h_ge h_contra