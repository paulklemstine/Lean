/-
# Cryptographic Closure Hulls

A formalization of secure key spaces as a Moore family (closure system),
with a canonical closure operator and characterization theorems showing
exactly when cryptographic closure preserves norm boundedness.

## Main Results

* `SecureKeySpace` — predicate for sets that contain zero, are reduction-invariant,
  and satisfy a uniform norm bound.
* `secureKeySpace_inter` — binary intersection closure.
* `secureKeySpace_sInter` — arbitrary intersection closure (Moore family property).
* `secureClosure` — the canonical closure hull operator.
* `subset_secureClosure` — seed inclusion in the closure.
* `secureClosure_is_secure` — the closure is itself a secure key space.
* `secureClosure_least` — the closure is the least secure superset.
* `exists_secureKeySpace_iff` — a bounded secure superset exists iff the seed is bounded.
* `secureClosure_mono` — monotonicity of the closure operator.
* `secureClosure_idem` — idempotence of the closure operator.
* `secureClosure_eq_iff` — fixed-point characterization.
* `no_secureKeySpace_of_unbounded_seed` — impossibility corollary.
* `RedOrbitClosure` — constructive inductive hull.
* `redOrbitClosure_is_secure` — the inductive hull is a secure key space.
* `redOrbitClosure_eq_secureClosure` — equivalence of constructive and impredicative closures.
-/

import Mathlib

open Set

variable {V : Type*} [NormedAddCommGroup V]

/-- A `SecureKeySpace red B S` is a set `S` that:
1. Contains the zero vector (identity element).
2. Is closed under the reduction operator `red`.
3. Has all elements bounded in norm by `B`. -/
def SecureKeySpace (red : V → V) (B : ℝ) (S : Set V) : Prop :=
  (0 : V) ∈ S ∧
  (∀ ⦃v : V⦄, v ∈ S → red v ∈ S) ∧
  ∀ ⦃v : V⦄, v ∈ S → ‖v‖ ≤ B

/-
Binary intersection of secure key spaces is a secure key space.
-/
theorem secureKeySpace_inter
    (red : V → V) (B : ℝ) {S T : Set V}
    (hS : SecureKeySpace red B S) (hT : SecureKeySpace red B T) :
    SecureKeySpace red B (S ∩ T) := by
  exact ⟨ ⟨ hS.1, hT.1 ⟩, fun v hv => ⟨ hS.2.1 hv.1, hT.2.1 hv.2 ⟩, fun v hv => hS.2.2 hv.1 ⟩

/-
**Moore family property**: Arbitrary nonempty intersection of secure key spaces is a secure
key space. The nonemptiness condition is essential: `⋂₀ ∅ = univ`, which is unbounded.
This is the fundamental structural theorem establishing `SecureKeySpace red B` as a closure system.
-/
theorem secureKeySpace_sInter
    (red : V → V) (B : ℝ) (C : Set (Set V)) (hne : C.Nonempty)
    (hC : ∀ S ∈ C, SecureKeySpace red B S) :
    SecureKeySpace red B (⋂₀ C) := by
  exact ⟨ fun S hS => ( hC S hS ).1, fun v hv S hS => ( hC S hS ).2.1 ( hv S hS ), fun v hv => ( hC _ hne.some_mem ).2.2 ( hv _ hne.choose_spec ) ⟩

/-- The canonical closure hull: the intersection of all secure key spaces containing `A`. -/
def secureClosure (red : V → V) (B : ℝ) (A : Set V) : Set V :=
  ⋂₀ {S : Set V | A ⊆ S ∧ SecureKeySpace red B S}

/-
The seed set is contained in its secure closure.
-/
theorem subset_secureClosure
    (red : V → V) (B : ℝ) (A : Set V) :
    A ⊆ secureClosure red B A := by
  exact Set.subset_sInter fun S hS => hS.1

/-
The secure closure is itself a secure key space, provided at least one secure superset exists.
-/
theorem secureClosure_is_secure
    (red : V → V) (B : ℝ) (A : Set V)
    (hex : ∃ S : Set V, A ⊆ S ∧ SecureKeySpace red B S) :
    SecureKeySpace red B (secureClosure red B A) := by
  -- The hypothesis hC gives us the existence of at least one secure superset.
  -- Therefore, the general family of all secure supersets is nonempty.
  let C := {S : Set V | A ⊆ S ∧ SecureKeySpace red B S}
  obtain hne : C.Nonempty := by
    obtain ⟨S, hAS, hsecure⟩ := hex
    exact ⟨S, hAS, hsecure⟩

    -- Apply the pure subset closure theorem to the family of secure supersets.
  apply secureKeySpace_sInter red B C hne
  intro S hS
  exact hS.right

/-
The secure closure is the least secure key space containing the seed.
-/
theorem secureClosure_least
    (red : V → V) (B : ℝ) (A S : Set V)
    (hS : A ⊆ S) (hsec : SecureKeySpace red B S) :
    secureClosure red B A ⊆ S := by
  exact Set.sInter_subset_of_mem ⟨ hS, hsec ⟩

/-
**Existence characterization**: Under a bound-preserving reduction fixing zero
with nonnegative security radius, a seed admits a bounded secure closure if and only if
the seed is already bounded. The `0 ≤ B` condition is necessary: when `B < 0`, no secure
key space exists (since `0` must belong to any secure key space and `‖0‖ = 0 > B`).
This is the conceptual heart of the theory.
-/
theorem exists_secureKeySpace_iff
    (red : V → V) (B : ℝ) (A : Set V)
    (hB : 0 ≤ B)
    (_hred0 : red 0 = 0)
    (hred_bound : ∀ v, ‖v‖ ≤ B → ‖red v‖ ≤ B) :
    (∃ S : Set V, A ⊆ S ∧ SecureKeySpace red B S) ↔
    (∀ v ∈ A, ‖v‖ ≤ B) := by
  constructor
  · rintro ⟨S, hAS, hS⟩ v hv
    exact hS.2.2 (hAS hv)
  · exact fun h => ⟨{v | ‖v‖ ≤ B}, h, by simpa using hB, fun v hv => hred_bound v hv, fun v hv => hv⟩

/-
**Impossibility corollary**: If any seed element exceeds the bound,
no secure key space can contain the seed.
-/
theorem no_secureKeySpace_of_unbounded_seed
    (red : V → V) (B : ℝ) (A : Set V)
    (hv : ∃ v ∈ A, B < ‖v‖) :
    ¬∃ S : Set V, A ⊆ S ∧ SecureKeySpace red B S := by
  grind +locals

/-
Monotonicity of the closure operator.
-/
theorem secureClosure_mono
    (red : V → V) (B : ℝ) {A₁ A₂ : Set V}
    (h : A₁ ⊆ A₂) :
    secureClosure red B A₁ ⊆ secureClosure red B A₂ := by
  apply Set.sInter_subset_sInter;
  exact fun S hS => ⟨ h.trans hS.1, hS.2 ⟩

/-
Idempotence of the closure operator.
-/
theorem secureClosure_idem
    (red : V → V) (B : ℝ) (A : Set V)
    (hex : ∃ S : Set V, A ⊆ S ∧ SecureKeySpace red B S) :
    secureClosure red B (secureClosure red B A) = secureClosure red B A := by
  refine' Set.Subset.antisymm ( _ ) ( _ );
  · apply secureClosure_least;
    · exact Set.Subset.rfl;
    · exact secureClosure_is_secure red B A hex;
  · apply subset_secureClosure _ _

/-
Fixed-point characterization: `secureClosure red B S = S` iff `S` is already secure.
-/
theorem secureClosure_eq_iff
    (red : V → V) (B : ℝ) (S : Set V)
    (hex : ∃ T : Set V, S ⊆ T ∧ SecureKeySpace red B T) :
    secureClosure red B S = S ↔ SecureKeySpace red B S := by
  constructor <;> intro h;
  · exact h ▸ secureClosure_is_secure red B S hex;
  · exact Set.Subset.antisymm ( secureClosure_least _ _ _ _ ( Set.Subset.refl _ ) h ) ( subset_secureClosure _ _ _ )

/-! ## Constructive Inductive Hull

An alternative, constructive definition of the closure via reduction orbits. -/

/-- The inductive reduction orbit closure: the smallest set containing `A`, `0`,
and closed under `red`. -/
inductive RedOrbitClosure (red : V → V) (A : Set V) : V → Prop
  | base {v} : v ∈ A → RedOrbitClosure red A v
  | zero : RedOrbitClosure red A 0
  | step {v} : RedOrbitClosure red A v → RedOrbitClosure red A (red v)

/-
The inductive orbit closure is a secure key space when the seed is bounded
and reduction preserves the bound.
-/
theorem redOrbitClosure_is_secure
    (red : V → V) (B : ℝ) (A : Set V)
    (hB : 0 ≤ B)
    (_hred0 : red 0 = 0)
    (hred_bound : ∀ v, ‖v‖ ≤ B → ‖red v‖ ≤ B)
    (hA : ∀ v ∈ A, ‖v‖ ≤ B) :
    SecureKeySpace red B {v | RedOrbitClosure red A v} := by
  refine ⟨RedOrbitClosure.zero, fun v hv => RedOrbitClosure.step hv, fun v hv => ?_⟩
  induction hv with
  | base h => exact hA _ h
  | zero => simpa using hB
  | step _ ih => exact hred_bound _ ih

/-
Any secure key space containing `A` contains the orbit closure.
-/
theorem redOrbitClosure_subset_secure
    (red : V → V) (B : ℝ) (A S : Set V)
    (hAS : A ⊆ S) (hsec : SecureKeySpace red B S) :
    {v | RedOrbitClosure red A v} ⊆ S := by
  -- By definition of `RedOrbitClosure`, we know that every element in the orbit closure is in `S`.
  intros v hv
  induction' hv with v hv ih;
  · exact hAS hv;
  · exact hsec.1;
  · exact hsec.2.1 ‹_›

/-
The inductive orbit closure equals the impredicative secure closure
when the seed is bounded and reduction preserves the bound.
-/
theorem redOrbitClosure_eq_secureClosure
    (red : V → V) (B : ℝ) (A : Set V)
    (hB : 0 ≤ B)
    (hred0 : red 0 = 0)
    (hred_bound : ∀ v, ‖v‖ ≤ B → ‖red v‖ ≤ B)
    (hA : ∀ v ∈ A, ‖v‖ ≤ B) :
    {v | RedOrbitClosure red A v} = secureClosure red B A := by
  refine' Set.Subset.antisymm _ _;
  · refine' redOrbitClosure_subset_secure red B A _ _ _;
    · exact subset_secureClosure red B A
    · exact secureClosure_is_secure red B A ((exists_secureKeySpace_iff red B A hB hred0 hred_bound).2 hA)
  · apply secureClosure_least
    · exact fun v hv => RedOrbitClosure.base hv
    · exact redOrbitClosure_is_secure red B A hB hred0 hred_bound hA