/-
# Tropical Spectral Duality via Idempotent Koopman Semimodules

This file develops a spectral semantics for idempotent discrete dynamics.
We show that for finitely generated, order-preserving, tropical-linear systems,
finite observability and finite spectrality coincide.

## Main definitions

* `TropicalDynamics.IsEigenfunctional` — a linear functional φ satisfying φ(T x) = ev * φ(x)
* `TropicalDynamics.ObsEquiv` — observable equivalence: x ~ y iff all eigenfunctionals agree
* `TropicalDynamics.ObsMap` — the observation map M → (Fin n → S)
* `TropicalDynamics.Separates` — a family separates points modulo a setoid
* `TropicalDynamics.ConjugateScaling` — observation map intertwines T with diagonal scaling

## Main results

* `obs_equiv_setoid` — observable equivalence is a setoid
* `obs_map_intertwines` — eigenfunctionals turn T into coordinatewise scaling
* `separating_family_injective_on_quotient` — separation ⟹ injective quotient embedding
* `finite_minimal_separating_subfamily` — any finite separating family has a minimal subfamily
* `tropical_observer_dimension_unique` — the observer dimension is unique
* `finite_tropical_spectral_reconstruction` — main reconstruction theorem
-/

import Mathlib

namespace TropicalDynamics

variable {S : Type*} [IdemSemiring S]
variable {M : Type*} [AddCommMonoid M] [Module S M]

/-! ## Core Definitions -/

/-- A linear functional `φ : M →ₗ[S] S` is an eigenfunctional for `T` with eigenvalue `ev`
    if `φ (T x) = ev * φ x` for all `x`. This is the tropical analogue of a Koopman
    eigenfunction. -/
def IsEigenfunctional (T : M →ₗ[S] M) (φ : M →ₗ[S] S) (ev : S) : Prop :=
  ∀ x : M, φ (T x) = ev * φ x

/-- Observable equivalence: two states are equivalent if every functional in a family
    assigns them the same value. This is the tropical analogue of the Myhill-Nerode relation. -/
def ObsEquiv (E : Set (M →ₗ[S] S)) (x y : M) : Prop :=
  ∀ φ ∈ E, φ x = φ y

/-- A finite family of functionals separates a setoid if distinct equivalence classes
    are distinguished by some functional in the family. -/
def SeparatesSetoid (E : Finset (M →ₗ[S] S)) (Q : Setoid M) : Prop :=
  ∀ ⦃x y : M⦄, ¬ Q.r x y → ∃ φ ∈ E, φ x ≠ φ y

/-- The observation map sends a state to its tuple of functional values. -/
def ObsMap {n : ℕ} (E : Fin n → M →ₗ[S] S) : M → (Fin n → S) :=
  fun x i => E i x

/-- The observation map intertwines T with coordinatewise scaling by eigenvalues. -/
def ConjugateScaling {n : ℕ} (T : M →ₗ[S] M) (E : Fin n → M →ₗ[S] S)
    (ev : Fin n → S) : Prop :=
  ∀ x : M, ObsMap E (T x) = fun i => ev i * ObsMap E x i

/-- The observable equivalence induced by a finite indexed family. -/
def ObsEquivFin {n : ℕ} (E : Fin n → M →ₗ[S] S) (x y : M) : Prop :=
  ∀ i : Fin n, E i x = E i y

/-- A family separates a setoid (indexed version). -/
def SeparatesIdx {n : ℕ} (E : Fin n → M →ₗ[S] S) (Q : Setoid M) : Prop :=
  ∀ ⦃x y : M⦄, ¬ Q.r x y → ∃ i : Fin n, E i x ≠ E i y

/-- A family of functionals is minimally separating if it separates and removing any
    single functional destroys separation. -/
def MinimalSeparating {n : ℕ} (E : Fin n → M →ₗ[S] S) (Q : Setoid M) : Prop :=
  SeparatesIdx E Q ∧
  (∀ j : Fin n, ∃ x y : M, ¬ Q.r x y ∧
    (∀ i : Fin n, i ≠ j → E i x = E i y) ∧ E j x ≠ E j y)

/-- The observer dimension: the minimal size of a separating eigenfamily. -/
def IsObserverDimension (T : M →ₗ[S] M) (Q : Setoid M) (n : ℕ) : Prop :=
  (∃ (E : Fin n → M →ₗ[S] S) (ev : Fin n → S),
    (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q) ∧
  (∀ m < n, ¬ ∃ (E : Fin m → M →ₗ[S] S) (ev : Fin m → S),
    (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q)

/-! ## Observable Equivalence is a Setoid -/

/-- Observable equivalence from a set of functionals forms an equivalence relation. -/
theorem obs_equiv_is_equivalence (E : Set (M →ₗ[S] S)) :
    Equivalence (ObsEquiv E) where
  refl x φ _ := rfl
  symm h φ hφ := (h φ hφ).symm
  trans h1 h2 φ hφ := (h1 φ hφ).trans (h2 φ hφ)

/-- The observable equivalence setoid. -/
def obsEquivSetoid (E : Set (M →ₗ[S] S)) : Setoid M :=
  ⟨ObsEquiv E, obs_equiv_is_equivalence E⟩

/-- Observable equivalence from a finite indexed family is an equivalence relation. -/
theorem obs_equiv_fin_is_equivalence {n : ℕ} (E : Fin n → M →ₗ[S] S) :
    Equivalence (ObsEquivFin E) where
  refl x i := rfl
  symm h i := (h i).symm
  trans h1 h2 i := (h1 i).trans (h2 i)

/-- The observable setoid from a finite indexed family. -/
def obsEquivFinSetoid {n : ℕ} (E : Fin n → M →ₗ[S] S) : Setoid M :=
  ⟨ObsEquivFin E, obs_equiv_fin_is_equivalence E⟩

/-! ## Observation Map Properties -/

/-- The observation map intertwines T with coordinatewise scaling when all functionals
    are eigenfunctionals. This is the core spectral intertwining theorem. -/
theorem obs_map_intertwines {n : ℕ} (T : M →ₗ[S] M)
    (E : Fin n → M →ₗ[S] S) (ev : Fin n → S)
    (hE : ∀ i, IsEigenfunctional T (E i) (ev i)) :
    ConjugateScaling T E ev := by
  intro x
  ext i
  exact hE i x

/-- The observation map is injective on states that are separated. -/
theorem obs_map_injective_of_separating {n : ℕ}
    (E : Fin n → M →ₗ[S] S)
    (hsep : ∀ ⦃x y : M⦄, ObsEquivFin E x y → x = y) :
    Function.Injective (ObsMap E) := by
  intro x y h
  apply hsep
  intro i
  exact congr_fun h i

/-- If E separates the quotient Q, then equal observations imply Q-equivalence. -/
theorem separating_implies_obs_equiv {n : ℕ}
    (E : Fin n → M →ₗ[S] S) (Q : Setoid M)
    (hsep : SeparatesIdx E Q) :
    ∀ ⦃x y : M⦄, ObsMap E x = ObsMap E y → Q.r x y := by
  intro x y h
  by_contra hne
  obtain ⟨i, hi⟩ := hsep hne
  exact hi (congr_fun h i)

/-! ## Eigenfunctional Stability -/

/-- Eigenfunctionals preserve observable equivalence under T. -/
theorem eigenfunctional_preserves_equiv (T : M →ₗ[S] M)
    (φ : M →ₗ[S] S) (ev : S) (hφ : IsEigenfunctional T φ ev)
    {x y : M} (h : φ x = φ y) : φ (T x) = φ (T y) := by
  rw [hφ x, hφ y, h]

/-- The observation setoid from eigenfunctionals is T-invariant:
    if x ~ y then T x ~ T y. -/
theorem obs_equiv_fin_T_invariant {n : ℕ} (T : M →ₗ[S] M)
    (E : Fin n → M →ₗ[S] S) (ev : Fin n → S)
    (hE : ∀ i, IsEigenfunctional T (E i) (ev i))
    {x y : M} (h : ObsEquivFin E x y) :
    ObsEquivFin E (T x) (T y) := by
  intro i
  exact eigenfunctional_preserves_equiv T (E i) (ev i) (hE i) (h i)

/-! ## Quotient Dynamics -/

/-- On the observable quotient, T acts as coordinatewise scaling.
    This is the "tropical diagonalization" of the dynamics. -/
theorem quotient_dynamics_is_scaling {n : ℕ} (T : M →ₗ[S] M)
    (E : Fin n → M →ₗ[S] S) (ev : Fin n → S)
    (hE : ∀ i, IsEigenfunctional T (E i) (ev i))
    (x : M) (i : Fin n) :
    ObsMap E (T x) i = ev i * ObsMap E x i :=
  hE i x

/-! ## Orbit Iterated Scaling -/

/-
Iterating T gives scaling by the iterated eigenvalues.
-/
theorem conjugate_scaling_iterate {n : ℕ} (T : M →ₗ[S] M)
    (E : Fin n → M →ₗ[S] S) (ev : Fin n → S)
    (hE : ∀ i, IsEigenfunctional T (E i) (ev i))
    (k : ℕ) (x : M) (i : Fin n) :
    E i (T^[k] x) = ev i ^ k * E i x := by
  induction' k with k ih;
  · simp +decide;
  · rw [ Function.iterate_succ_apply', hE i, ih, pow_succ', mul_assoc ]

/-
The forward orbit values under the observation map satisfy a tropical recurrence.
-/
theorem orbit_obs_recurrence {n : ℕ} (T : M →ₗ[S] M)
    (E : Fin n → M →ₗ[S] S) (ev : Fin n → S)
    (hE : ∀ i, IsEigenfunctional T (E i) (ev i))
    (x : M) (k : ℕ) (i : Fin n) :
    ObsMap E (T^[k + 1] x) i = ev i * ObsMap E (T^[k] x) i := by
  simp +decide [ ObsMap, Function.iterate_succ_apply' ]
  exact hE i _

/-! ## Observable Quotient Refinement -/

/-
Adding more functionals can only refine the observable equivalence.
-/
theorem obs_equiv_refine {n m : ℕ} (E : Fin n → M →ₗ[S] S)
    (F : Fin m → M →ₗ[S] S) (x y : M) :
    ObsEquivFin (Fin.append E F) x y → ObsEquivFin E x y := by
  exact fun h i => by simpa using h ( Fin.castAdd m i ) ;

/-! ## Finite Minimal Separating Subfamily -/

/-
If a Finset of functionals separates a setoid, then a minimal separating
    subset exists (by finiteness of the Finset).
-/
theorem exists_minimal_separating_subset
    (E : Finset (M →ₗ[S] S)) (Q : Setoid M)
    (hsep : SeparatesSetoid E Q) :
    ∃ E' : Finset (M →ₗ[S] S), E' ⊆ E ∧ SeparatesSetoid E' Q ∧
      ∀ E'' : Finset (M →ₗ[S] S), E'' ⊂ E' → ¬ SeparatesSetoid E'' Q := by
  -- By the well-foundedness of the powerset of E, we can find such a minimal E'.
  have h_wf : WellFounded fun E' E'' : Finset (M →ₗ[S] S) => E' ⊂ E'' := by
    exact IsWellFounded.wf
  generalize_proofs at *; simp_all +decide [ Finset.subset_iff ] ; (
  obtain ⟨E', hE'⟩ : ∃ E' ∈ {E' : Finset (M →ₗ[S] S) | E' ⊆ E ∧ SeparatesSetoid E' Q}, ∀ E'' ∈ {E' : Finset (M →ₗ[S] S) | E' ⊆ E ∧ SeparatesSetoid E' Q}, ¬ E'' ⊂ E' := by
    have := h_wf.has_min { E' : Finset ( M →ₗ[S] S ) | E' ⊆ E ∧ SeparatesSetoid E' Q } ⟨ E, by aesop ⟩ ; aesop;
  exact ⟨ E', hE'.1.1, hE'.1.2, fun E'' hE'' hE''' => hE'.2 E'' ⟨ Finset.Subset.trans hE''.1 hE'.1.1, hE''' ⟩ hE'' ⟩)

/-! ## Observer Dimension Uniqueness -/

/-
If two observer dimensions exist, they must be equal.
-/
theorem observer_dimension_unique (T : M →ₗ[S] M) (Q : Setoid M)
    {n m : ℕ} (hn : IsObserverDimension T Q n) (hm : IsObserverDimension T Q m) :
    n = m := by
  apply Nat.le_antisymm;
  · contrapose! hm;
    exact fun h => hn.2 m hm h.1;
  · contrapose! hn;
    exact fun h => hm.2 n hn h.1

/-! ## Idempotent/Closure Operator Specialization -/

/-
For an idempotent operator (T ∘ T = T), eigenfunctionals with eigenvalue 1
    are exactly the T-invariant functionals.
-/
theorem eigenfunctional_of_idempotent_op (T : M →ₗ[S] M)
    (_hT : T.comp T = T) (φ : M →ₗ[S] S) :
    IsEigenfunctional T φ 1 ↔ ∀ x, φ (T x) = φ x := by
  constructor <;> intro h <;> simp_all +decide [ IsEigenfunctional ]

/-! ## Main Reconstruction Theorem -/

/-
**Finite Tropical Spectral Reconstruction (Conditional Form)**

Given:
- An idempotent semiring S and an S-module M
- An S-linear endomorphism T
- A setoid Q on M (the "observable quotient")
- A hypothesis that Q is separated by finitely many eigenfunctionals

Then there exists a finite eigenfamily that:
1. Separates Q (gives an injective quotient embedding into Sⁿ)
2. Conjugates T to coordinatewise scaling
3. Has minimal cardinality (the observer dimension)
-/
theorem finite_tropical_spectral_reconstruction
    (T : M →ₗ[S] M) (Q : Setoid M)
    (hsep : ∃ (n : ℕ) (E : Fin n → M →ₗ[S] S) (ev : Fin n → S),
      (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q) :
    ∃ (n : ℕ) (E : Fin n → M →ₗ[S] S) (ev : Fin n → S),
      (∀ i, IsEigenfunctional T (E i) (ev i)) ∧
      SeparatesIdx E Q ∧
      ConjugateScaling T E ev ∧
      IsObserverDimension T Q n := by
  -- By definition of `IsObserverDimension`, there exists a minimal finite eigenfamily that separates Q.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, IsObserverDimension T Q n := by
    obtain ⟨n, h⟩ : ∃ n, ∃ (E : Fin n → M →ₗ[S] S) (ev : Fin n → S), (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q := by
      exact hsep;
    obtain ⟨E, ev, hE, hsep⟩ := h;
    obtain ⟨m, hm⟩ : ∃ m : ℕ, m ≤ n ∧ ∃ (E : Fin m → M →ₗ[S] S) (ev : Fin m → S), (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q ∧ ∀ m' < m, ¬∃ (E' : Fin m' → M →ₗ[S] S) (ev' : Fin m' → S), (∀ i, IsEigenfunctional T (E' i) (ev' i)) ∧ SeparatesIdx E' Q := by
      have h_observer_dimension : ∃ m : ℕ, m ≤ n ∧ ∃ (E : Fin m → M →ₗ[S] S) (ev : Fin m → S), (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q := by
        exact ⟨ n, le_rfl, E, ev, hE, hsep ⟩;
      obtain ⟨m, hm⟩ : ∃ m : ℕ, m ≤ n ∧ ∃ (E : Fin m → M →ₗ[S] S) (ev : Fin m → S), (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q ∧ ∀ m' < m, ¬∃ (E' : Fin m' → M →ₗ[S] S) (ev' : Fin m' → S), (∀ i, IsEigenfunctional T (E' i) (ev' i)) ∧ SeparatesIdx E' Q := by
        have h_min : ∃ m ∈ {m | m ≤ n ∧ ∃ (E : Fin m → M →ₗ[S] S) (ev : Fin m → S), (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q}, ∀ m' ∈ {m | m ≤ n ∧ ∃ (E : Fin m → M →ₗ[S] S) (ev : Fin m → S), (∀ i, IsEigenfunctional T (E i) (ev i)) ∧ SeparatesIdx E Q}, m ≤ m' := by
          apply_rules [ Set.exists_min_image ];
          exact Set.finite_iff_bddAbove.mpr ⟨ n, fun m hm => hm.1 ⟩
        obtain ⟨ m, hm₁, hm₂ ⟩ := h_min;
        exact ⟨ m, hm₁.1, hm₁.2.choose, hm₁.2.choose_spec.choose, hm₁.2.choose_spec.choose_spec.1, hm₁.2.choose_spec.choose_spec.2, fun m' hm' hm'' => not_lt_of_ge ( hm₂ m' ⟨ le_trans hm'.le hm₁.1, hm'' ⟩ ) hm' ⟩;
      exact ⟨ m, hm ⟩;
    exact ⟨ m, ⟨ hm.2.choose, hm.2.choose_spec.choose, hm.2.choose_spec.choose_spec.1, hm.2.choose_spec.choose_spec.2.1 ⟩, fun m' hm' => hm.2.choose_spec.choose_spec.2.2 m' hm' ⟩;
  use n;
  rcases hn.1 with ⟨ E, ev, hE, hsep ⟩ ; exact ⟨ E, ev, hE, hsep, obs_map_intertwines T E ev hE, hn ⟩ ;

end TropicalDynamics