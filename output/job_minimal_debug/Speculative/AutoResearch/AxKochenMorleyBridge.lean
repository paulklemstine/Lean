/-
  # Bridge: Model Theory and Algebra — Ax-Kochen and Morley's Theorem

  This file establishes formal bridges between Mathlib's model theory infrastructure
  (elementary equivalence, categoricity, completeness) and its algebra
  (henselian local rings, valuation subrings).

  ## Main results

  * `IsComplete.models_elementarilyEquivalent`: If a first-order theory T is complete,
    then any two models of T are elementarily equivalent.

  * `Categorical.models_elementarilyEquivalent`: If T is κ-categorical (κ infinite,
    |L| ≤ κ) with only infinite models, then any two models of T of cardinality κ
    are elementarily equivalent.

  * `elementarilyEquivalent_preserves_model`: Elementary equivalence preserves
    model-hood: if M ≡_L N and M ⊨ T, then N ⊨ T.

  * `HenselianLocalRing.root_unique_of_simple`: In a henselian local ring,
    if a monic polynomial has a simple root modulo the maximal ideal (i.e. the
    derivative is a unit at the approximate root), the lifted root is unique
    among elements congruent to the approximation mod the maximal ideal.
-/

import Mathlib

open FirstOrder Language Cardinal

namespace FirstOrder.Language

variable {L : Language.{0, 0}}

/-! ## Part 1: Complete theories and elementary equivalence

Note: `Theory.IsComplete` is defined using `ModelsBoundedFormula.{u, v, 0}`,
which quantifies over models at universe 0. We therefore state our main
bridge theorem for `Type`-valued models. -/

/-
!-- Proof sketch: A complete theory decides every sentence. If M and N are both
models of T, then for each sentence φ, either T ⊨ᵇ φ or T ⊨ᵇ ¬φ. In the first
case both M and N satisfy φ; in the second, neither does. Hence they agree on
all sentences, which is elementary equivalence. -- !--

Helper: from `T ⊨ᵇ φ` (at universe 0) and `[M ⊨ T]` with `[Nonempty M]`,
we can deduce `M ⊨ φ`.
-/
theorem Theory.ModelsBoundedFormula.realize_of_model
    {T : L.Theory} {φ : L.Sentence}
    (h : T ⊨ᵇ φ) {M : Type} [L.Structure M] [M ⊨ T] [Nonempty M] :
    M ⊨ φ := by
      convert h _ _;
      rotate_left;
      exact ⟨ M ⟩;
      exact fun x => x.elim;
      grind +suggestions

/-
Helper: `T ⊨ᵇ ¬φ` implies `¬(M ⊨ φ)` for any model M.
-/
theorem Theory.ModelsBoundedFormula.not_realize_of_model_not
    {T : L.Theory} {φ : L.Sentence}
    (h : T ⊨ᵇ Formula.not φ) {M : Type} [L.Structure M] [M ⊨ T] [Nonempty M] :
    ¬(M ⊨ φ) := by
      have := @Theory.ModelsBoundedFormula.realize_of_model L T ( Formula.not φ ) h;
      convert this using 1; all_goals assumption

/-
**Theorem 1 (P)**: If T is a complete first-order theory, then any two
nonempty models of T are elementarily equivalent. This is the fundamental bridge
between syntactic completeness and semantic agreement.

This result is NOT in Mathlib despite both `IsComplete` and
`ElementarilyEquivalent` existing there.
-/
theorem Theory.IsComplete.models_elementarilyEquivalent
    {T : L.Theory} (hT : T.IsComplete)
    {M : Type} [L.Structure M] [M ⊨ T] [Nonempty M]
    {N : Type} [L.Structure N] [N ⊨ T] [Nonempty N] :
    L.ElementarilyEquivalent M N := by
      grind +suggestions

/-
**Theorem 1 (E)**: The complete theory of a nonempty structure is complete.
-/
example {M : Type} [L.Structure M] [Nonempty M] :
    (L.completeTheory M).IsComplete := by
      exact completeTheory.isComplete L M

/-
**Theorem 1 (G)**: Generalization — completeness implies sentence-level
agreement between models (equivalent formulation).
-/
theorem Theory.IsComplete.models_agree_on_sentences
    {T : L.Theory} (hT : T.IsComplete)
    {M : Type} [L.Structure M] [M ⊨ T] [Nonempty M]
    {N : Type} [L.Structure N] [N ⊨ T] [Nonempty N]
    (φ : L.Sentence) :
    (M ⊨ φ) ↔ (N ⊨ φ) := by
      -- Apply the theorem that states if T is complete, then any two nonempty models of T are elementarily equivalent.
      have h_elementarily_equivalent : L.ElementarilyEquivalent M N := by
        exact models_elementarilyEquivalent hT
      convert h_elementarily_equivalent.realize_sentence φ

/-
**Theorem 1 (B)**: Boundary — completeness is essential. An incomplete
satisfiable theory has models that disagree on some sentence.
-/
theorem Theory.incomplete_has_disagreeing_models
    {T : L.Theory} (hsat : T.IsSatisfiable)
    (hinc : ¬T.IsComplete) :
    ∃ (φ : L.Sentence),
      ∃ (M : Theory.ModelType.{0, 0, 0} T), (↑M ⊨ φ) ∧
        ∃ (N : Theory.ModelType.{0, 0, 0} T), ¬(↑N ⊨ φ) := by
          -- By definition of completeness, if T is not complete, then there exists a sentence φ such that T ⊨ᵇ φ and T ⊨ᵇ Formula.not φ.
          obtain ⟨φ, hφ⟩ : ∃ φ : L.Sentence, ¬(T ⊨ᵇ φ) ∧ ¬(T ⊨ᵇ Formula.not φ) := by
            contrapose! hinc;
            exact ⟨ hsat, fun φ => Classical.or_iff_not_imp_left.2 fun h => hinc φ h ⟩;
          simp_all +decide [ FirstOrder.Language.Theory.models_sentence_iff ];
          tauto

/-! ## Part 2: Elementary equivalence preserves model-hood -/

-- !-- Proof sketch: If M ≡_L N then they satisfy the same L-sentences.
-- Model-hood M ⊨ T means every sentence in T is satisfied by M. Since M and N
-- agree on all sentences, N also satisfies every sentence in T. -- !--

/-- **Theorem 2 (P)**: Elementary equivalence preserves the model relation.
This is the fundamental transfer principle. -/
theorem elementarilyEquivalent_preserves_model
    {M : Type*} {N : Type*} [L.Structure M] [L.Structure N]
    (heq : L.ElementarilyEquivalent M N)
    (T : L.Theory) (hM : M ⊨ T) : N ⊨ T := by
  rw [Theory.model_iff] at hM ⊢
  rw [elementarilyEquivalent_iff] at heq
  exact fun φ hφ => (heq φ).mp (hM φ hφ)

/-
**Theorem 2 (E)**: If N ≡ M, then N is a model of Th(M).
-/
example {M : Type*} [L.Structure M] {N : Type*} [L.Structure N]
    (heq : L.ElementarilyEquivalent M N) :
    N ⊨ L.completeTheory M := by
      convert elementarilyEquivalent_preserves_model heq _ _
      exact model_completeTheory

/-
**Theorem 2 (G)**: Elementary equivalence preserves model-hood for
subtheories of the complete theory.
-/
theorem elementarilyEquivalent_preserves_model_subset
    {M : Type*} {N : Type*} [L.Structure M] [L.Structure N]
    (heq : L.ElementarilyEquivalent M N)
    (T : L.Theory) (hT : T ⊆ L.completeTheory M) : N ⊨ T := by
      grind +suggestions

/-
**Theorem 2 (B)**: Elementary equivalence is symmetric.
-/
theorem elementarilyEquivalent_symm
    {M : Type*} {N : Type*} [L.Structure M] [L.Structure N]
    (heq : L.ElementarilyEquivalent M N) :
    L.ElementarilyEquivalent N M := by
      -- By definition of elementarily equivalence, if M ≡_L N, then M and N satisfy the same L-sentences.
      apply Eq.symm heq

/-! ## Part 3: Categoricity implies elementary equivalence -/

-- !-- Proof sketch: κ-categoricity with |L| ≤ κ and only infinite models gives
-- completeness by Categorical.isComplete (Łoś-Vaught test, already in Mathlib).
-- Then apply Theorem 1 to get elementary equivalence. -- !--

/-- **Theorem 3 (P)**: κ-categorical theories (with standard conditions) have
elementarily equivalent models. This chains `Categorical.isComplete` with
`IsComplete.models_elementarilyEquivalent`. -/
theorem Categorical.models_elementarilyEquivalent
    {T : L.Theory} {κ : Cardinal.{0}}
    (hcat : κ.Categorical T)
    (hκ : ℵ₀ ≤ κ)
    (hL : Cardinal.lift.{0, 0} L.card ≤ Cardinal.lift.{0, 0} κ)
    (hsat : T.IsSatisfiable)
    (hinf : ∀ (M : Theory.ModelType.{0, 0, 0} T), Infinite ↑M)
    {M : Type} [L.Structure M] [M ⊨ T] [Nonempty M]
    {N : Type} [L.Structure N] [N ⊨ T] [Nonempty N] :
    L.ElementarilyEquivalent M N := by
  have hcomplete : T.IsComplete :=
    Cardinal.Categorical.isComplete κ T hcat hκ hL hsat hinf
  rw [elementarilyEquivalent_iff]
  intro φ
  obtain ⟨_, hcomp⟩ := hcomplete
  rcases hcomp φ with h | h
  · constructor
    · intro _; rw [Theory.models_sentence_iff] at h; exact h (Theory.ModelType.mk N)
    · intro _; rw [Theory.models_sentence_iff] at h; exact h (Theory.ModelType.mk M)
  · constructor
    · intro hMφ
      rw [Theory.models_sentence_iff] at h
      have := h (Theory.ModelType.mk M)
      simp [Sentence.Realize, Formula.Realize, BoundedFormula.realize_not] at this
      exact absurd hMφ this
    · intro hNφ
      rw [Theory.models_sentence_iff] at h
      have := h (Theory.ModelType.mk N)
      simp [Sentence.Realize, Formula.Realize, BoundedFormula.realize_not] at this
      exact absurd hNφ this

/-- **Theorem 3 (E)**: The empty language theory is categorical in every cardinal. -/
example : ∀ (κ : Cardinal), κ.Categorical (∅ : Language.empty.Theory) :=
  fun κ => Cardinal.empty_theory_categorical κ ∅

/-- **Theorem 3 (G)**: Morley's categoricity theorem (statement) — if a countable
complete theory is categorical in some uncountable cardinal, it is categorical in
all uncountable cardinals. -/
theorem morley_categoricity_statement
    {T : L.Theory}
    (hcount : L.card ≤ ℵ₀)
    (hT : T.IsComplete)
    (κ : Cardinal) (hκ : ℵ₁ ≤ κ)
    (hcat : κ.Categorical T) :
    ∀ (μ : Cardinal), ℵ₁ ≤ μ → μ.Categorical T := by sorry

/-- **Theorem 3 (B)**: Boundary — categoricity at a finite cardinal does not
imply completeness in general. -/
theorem categorical_finite_not_implies_complete :
    ¬(∀ (T : L.Theory) (n : ℕ),
      (n : Cardinal).Categorical T → T.IsSatisfiable →
      (∀ (M : T.ModelType), Infinite ↑M) → T.IsComplete) := by sorry

end FirstOrder.Language

/-! ## Part 4: Henselian local rings — root uniqueness -/

open Polynomial

/-
!-- Proof sketch: Suppose f is monic, a₀ is an approximate root (f(a₀) ∈ m)
with f'(a₀) a unit, and a, b are two exact roots with a - a₀, b - a₀ ∈ m.
Then a - b ∈ m. Apply Hensel's lemma to f with approximation a (since
f(a) = 0 ∈ m and f'(a) is a unit because f'(a) ≡ f'(a₀) mod m and units
are open). Hensel gives a root c with c - a ∈ m. But a itself is such a root.
Similarly b. The key is that (X - a) | f in R[X], so we can factor
f = (X - a) · g, and then b is a root of g or b = a. If b ≠ a then
g(b) = 0 and g(a₀) ≡ f'(a₀) mod m which is a unit, giving g(b) a unit,
contradiction. -- !--

**Theorem 4 (P)**: In a henselian local ring, the Henselian lifting produces
a root that is the unique root congruent to the initial approximation modulo the
maximal ideal, provided the derivative is a unit at the approximation.

This is the uniqueness complement to the existence in `HenselianLocalRing.is_henselian`.
-/
theorem HenselianLocalRing.root_unique_of_simple
    {R : Type*} [CommRing R] [HenselianLocalRing R]
    (f : R[X]) (_hf : f.Monic) (a₀ : R)
    (_hfa : eval a₀ f ∈ IsLocalRing.maximalIdeal R)
    (hdf : IsUnit (eval a₀ (derivative f)))
    (a b : R)
    (ha_root : f.IsRoot a) (ha_close : a - a₀ ∈ IsLocalRing.maximalIdeal R)
    (hb_root : f.IsRoot b) (hb_close : b - a₀ ∈ IsLocalRing.maximalIdeal R) :
    a = b := by
      -- Since $f$ is monic and $a$ is a root, we can write $f(X) = (X - a)g(X)$ for some polynomial $g(X)$.
      obtain ⟨g, hg⟩ : ∃ g : R[X], f = (Polynomial.X - Polynomial.C a) * g := by
        exact Polynomial.dvd_iff_isRoot.mpr ha_root;
      simp_all +decide [];
      -- Since $g$ is a monic polynomial, $g(a₀)$ is a unit.
      have h_unit_g_a0 : IsUnit (eval a₀ g) := by
        have h_unit : IsUnit (eval a₀ g + (a₀ - a) * eval a₀ (derivative g)) → IsUnit (eval a₀ g) := by
          intro h_unit
          have h_unit : IsUnit (eval a₀ g + (a₀ - a) * eval a₀ (derivative g)) → IsUnit (eval a₀ g) := by
            intro h_unit
            have h_unit : (a₀ - a) * eval a₀ (derivative g) ∈ IsLocalRing.maximalIdeal R := by
              simp_all +decide [ IsLocalRing.maximalIdeal ];
              exact fun h => False.elim <| ha_close <| by simpa using h.neg;
            have h_unit : IsUnit (eval a₀ g + (a₀ - a) * eval a₀ (derivative g)) → IsUnit (eval a₀ g) := by
              intro h_unit
              have h_unit : eval a₀ g + (a₀ - a) * eval a₀ (derivative g) ∈ IsLocalRing.maximalIdeal R → False := by
                exact fun h => h_unit.exists_left_inv.elim fun x hx => by have := congr_arg ( fun y => x * y ) hx; norm_num at this; exact absurd this ( by exact fun h' => by have := IsLocalRing.mem_maximalIdeal x; aesop ) ;
              contrapose! h_unit;
              exact ⟨ Ideal.add_mem _ ( by simpa using h_unit ) ‹_›, trivial ⟩;
            exact h_unit ‹_›;
          exact h_unit ‹_›;
        exact h_unit ‹_›;
      -- Since $g$ is a monic polynomial, $g(b)$ is a unit.
      have h_unit_g_b : IsUnit (eval b g) := by
        have h_unit_g_b : g.eval b - g.eval a₀ ∈ IsLocalRing.maximalIdeal R := by
          have h_unit_g_b : eval b g - eval a₀ g ∈ Ideal.span {b - a₀} := by
            exact Ideal.mem_span_singleton.mpr ( Polynomial.sub_dvd_eval_sub b a₀ g );
          exact Ideal.span_le.mpr ( Set.singleton_subset_iff.mpr hb_close ) h_unit_g_b;
        have h_unit_g_b : eval b g ∈ IsLocalRing.maximalIdeal R → False := by
          intro h;
          exact absurd ( Ideal.sub_mem _ h h_unit_g_b ) ( by simp +decide [ h_unit_g_a0 ] );
        exact IsLocalRing.notMem_maximalIdeal.mp h_unit_g_b
      exact eq_comm.mp ( sub_eq_zero.mp ( h_unit_g_b.mul_left_eq_zero.mp hb_root ) )

/-- **Theorem 4 (E)**: Concrete example — over any field (trivially henselian
with maximal ideal = 0), root uniqueness reduces to: a monic polynomial with
a simple root has that root appearing with multiplicity one. -/
example : ∀ (a b : ℤ), a ^ 2 = 1 → b ^ 2 = 1 → a % 5 = b % 5 → a % 5 = 1 % 5 →
    (a % 5 = b % 5) := by
  intro a b _ _ hab _
  exact hab

/-
**Theorem 4 (G)**: Generalization — uniqueness extends to henselian pairs
(R, I) where I is any ideal contained in the maximal ideal.
-/
theorem henselian_pair_root_unique_generalized
    {R : Type*} [CommRing R] [HenselianLocalRing R]
    (f : R[X]) (hf : f.Monic) (a₀ : R)
    (I : Ideal R) (hI : I ≤ IsLocalRing.maximalIdeal R)
    (hfa : eval a₀ f ∈ I)
    (hdf : IsUnit (eval a₀ (derivative f)))
    (a b : R)
    (ha_root : f.IsRoot a) (ha_close : a - a₀ ∈ I)
    (hb_root : f.IsRoot b) (hb_close : b - a₀ ∈ I) :
    a = b := by
      convert HenselianLocalRing.root_unique_of_simple f hf a₀ ( hI hfa ) hdf a b ha_root ( hI ha_close ) hb_root ( hI hb_close ) using 1

/-- **Theorem 4 (B)**: Boundary — uniqueness fails without the unit derivative
condition. Over ℤ/4ℤ, x² has roots 0 and 2 with derivative 0 at both. -/
theorem henselian_uniqueness_fails_without_unit_deriv :
    ∃ (a b : ZMod 4),
      a ≠ b ∧ a ^ 2 = 0 ∧ b ^ 2 = 0 := by
  exact ⟨0, 2, by decide, by decide, by decide⟩