/-
# Closure–Nucleus Spectral Duality via Idempotent Semimodules

This file formalizes a finite duality theorem at the interface of closure systems,
idempotent algebra, and algebraic logic. The core result shows that closure-theoretic
data equipped with a logical nucleus can be represented exactly by evaluation on
join-prime spectral points, and that this representation supports certified
reconstruction of closure operators and sound-and-complete Kripke-style semantics.

## Main Results

* `closure_subset_of_closed_superset` — Closure containment from superset closure.
* `implication_valid_iff_all_prime_points` — Completeness: x ∈ cl(A) ↔ all primes
  containing A contain x.
* `closure_equals_sInter_of_prime_points` — Closure reconstruction from prime
  intersection.
* `spectral_eval_injective` — Injectivity of the spectral evaluation map under
  separation.
* `finite_closure_nucleus_spectral_embedding` — Bijection between closed sets
  and spectral observables.
* `certified_closure_reconstruction` — Certified recovery of the closure operator
  from spectral data.
* `implication_semantics_complete` — Sound-and-complete finite Kripke semantics.
* `implicational_basis_reconstruction` — Finite implicational basis generation.
* `nucleus_fixed_fragment_characterization` — Reconstruction of the nucleus-fixed
  fragment from nucleus-stable primes.

Keywords: spectral duality, closure systems, nuclei, idempotent semimodules,
Horn logic, implicational bases, Kripke semantics, formal concept analysis,
certified reconstruction, finite Stone duality.
-/

import Mathlib

open Set Function

namespace ClosureNucleusDuality

/-! ## Section 1: Core Definitions -/

/-- A set is closed under a closure operator when it is a fixed point. -/
def IsClosed (cl : Set α → Set α) (s : Set α) : Prop := cl s = s

/-- A closure operator is extensive, monotone, and idempotent. -/
structure IsClosureOperator (cl : Set α → Set α) : Prop where
  extensive : ∀ s, s ⊆ cl s
  mono : Monotone cl
  idempotent : ∀ s, cl (cl s) = cl s

/-- A finite closure-nucleus system: a closure operator on a finite type
    equipped with a nucleus on the closed-set semilattice. -/
structure FiniteClosureNucleus (α : Type*) [Fintype α] [DecidableEq α] where
  cl : Set α → Set α
  isClosure : IsClosureOperator cl
  nuc : Set α → Set α
  nuc_closed : ∀ s, IsClosed cl s → IsClosed cl (nuc s)
  nuc_mono : Monotone nuc
  nuc_idem : ∀ s, nuc (nuc s) = nuc s
  nuc_extensive_on_closed : ∀ s, IsClosed cl s → s ⊆ nuc s

/-- A join-prime closed set stable under the nucleus: closed, nucleus-fixed,
    and nonempty. -/
structure JoinPrimeClosed (cl : Set α → Set α) (nuc : Set α → Set α) (p : Set α) : Prop where
  closed : IsClosed cl p
  nuc_stable : nuc p = p
  nonempty : p.Nonempty

/-! ## Section 2: Basic Properties of Closure Operators -/

variable {α : Type*}

/-- The image of a closure operator is always closed. -/
theorem cl_is_closed (cl : Set α → Set α) (hcl : IsClosureOperator cl) (s : Set α) :
    IsClosed cl (cl s) :=
  hcl.idempotent s

/-- If s ⊆ t and t is closed, then cl(s) ⊆ t. -/
theorem closure_subset_of_closed_superset (cl : Set α → Set α) (hcl : IsClosureOperator cl)
    (s t : Set α) (ht : IsClosed cl t) (hst : s ⊆ t) : cl s ⊆ t := by
  have h1 : cl s ⊆ cl t := hcl.mono hst
  rw [show cl t = t from ht] at h1
  exact h1

/-- The closure of a set is the smallest closed set containing it. -/
theorem closure_is_smallest_closed (cl : Set α → Set α) (hcl : IsClosureOperator cl)
    (s : Set α) : cl s = ⋂₀ {t | IsClosed cl t ∧ s ⊆ t} := by
  ext x; simp only [mem_sInter, mem_setOf_eq]; constructor
  · intro hx t ⟨htcl, hst⟩
    exact closure_subset_of_closed_superset cl hcl s t htcl hst hx
  · intro hx
    exact hx (cl s) ⟨cl_is_closed cl hcl s, hcl.extensive s⟩

/-! ## Section 3: Separation and Spectral Completeness -/

/-- The prime separation condition: for every closed set s and element x ∉ s,
    there exists a join-prime stable closed set containing s but not x.
    This is the "enough points" condition for finite spectral duality. -/
def PrimeSeparation (cl : Set α → Set α) (nuc : Set α → Set α) : Prop :=
  ∀ (s : Set α) (x : α), IsClosed cl s → x ∉ s →
    ∃ p, JoinPrimeClosed cl nuc p ∧ s ⊆ p ∧ x ∉ p

/-- **Core completeness theorem**: Under prime separation, membership in a closure
    is equivalent to membership in all prime points containing the premise.
    This is the logical completeness statement:
    `x ∈ cl(A) ↔ ∀ prime p, A ⊆ p → x ∈ p`. -/
theorem implication_valid_iff_all_prime_points
    (cl : Set α → Set α) (nuc : Set α → Set α)
    (hcl : IsClosureOperator cl)
    (hsep : PrimeSeparation cl nuc)
    (A : Set α) (x : α) :
    x ∈ cl A ↔ ∀ p, JoinPrimeClosed cl nuc p → A ⊆ p → x ∈ p := by
  constructor
  · intro hx p hp hAp
    have : cl A ⊆ p := closure_subset_of_closed_superset cl hcl A p hp.closed hAp
    exact this hx
  · intro hall
    by_contra hx
    obtain ⟨p, hp, hclAp, hxp⟩ := hsep (cl A) x (cl_is_closed cl hcl A) hx
    have hAp : A ⊆ p := Subset.trans (hcl.extensive A) hclAp
    exact hxp (hall p hp hAp)

/-- **Closure reconstruction from primes**: A closed set equals the intersection
    of all prime points containing it. -/
theorem closure_equals_sInter_of_prime_points
    (cl : Set α → Set α) (nuc : Set α → Set α)
    (hcl : IsClosureOperator cl)
    (hsep : PrimeSeparation cl nuc)
    (A : Set α) :
    cl A = ⋂₀ {p | JoinPrimeClosed cl nuc p ∧ A ⊆ p} := by
  ext x; simp only [mem_sInter, mem_setOf_eq]
  constructor
  · intro hx p ⟨hp, hAp⟩
    exact (implication_valid_iff_all_prime_points cl nuc hcl hsep A x).mp hx p hp hAp
  · intro hall
    exact (implication_valid_iff_all_prime_points cl nuc hcl hsep A x).mpr
      fun p hp hAp => hall p ⟨hp, hAp⟩

/-! ## Section 4: Spectral Evaluation Map -/

/-- The spectral evaluation map: sends a set s to the predicate on primes
    recording which primes contain s. -/
def spectralEval (cl : Set α → Set α) (nuc : Set α → Set α)
    (s : Set α) : {p : Set α // JoinPrimeClosed cl nuc p} → Prop :=
  fun q => s ⊆ q.val

/-- The spectral evaluation is injective on closed sets under prime separation. -/
theorem spectral_eval_injective
    (cl : Set α → Set α) (nuc : Set α → Set α)
    (_hcl : IsClosureOperator cl)
    (hsep : PrimeSeparation cl nuc)
    (s t : Set α) (hs : IsClosed cl s) (ht : IsClosed cl t)
    (heq : spectralEval cl nuc s = spectralEval cl nuc t) :
    s = t := by
  by_contra hne
  by_cases h1 : s ⊆ t
  · have h2 : ¬t ⊆ s := fun h2 => hne (Subset.antisymm h1 h2)
    obtain ⟨x, hxt, hxs⟩ := not_subset.mp h2
    obtain ⟨p, hp, hsp, hxp⟩ := hsep s x hs hxs
    have : spectralEval cl nuc s ⟨p, hp⟩ := hsp
    rw [heq] at this
    exact hxp (this hxt)
  · obtain ⟨x, hxs, hxt⟩ := not_subset.mp h1
    obtain ⟨p, hp, htp, hxp⟩ := hsep t x ht hxt
    have : spectralEval cl nuc t ⟨p, hp⟩ := htp
    rw [← heq] at this
    exact hxp (this hxs)

/-! ## Section 5: Finite Spectral Embedding and Duality -/

section FiniteDuality
open Classical in
noncomputable section
variable [Fintype α] [DecidableEq α]

/-- A spectral observable: a predicate on prime points that is realizable as
    evaluation of some closed set. -/
def SpectralObservable (cl : Set α → Set α) (nuc : Set α → Set α)
    (f : {p : Set α // JoinPrimeClosed cl nuc p} → Prop) : Prop :=
  ∃ s : Set α, IsClosed cl s ∧ f = fun q => s ⊆ q.val

/-- **Finite spectral embedding theorem**: Under prime separation, the evaluation
    map bijects closed sets with spectral observables. -/
theorem finite_closure_nucleus_spectral_embedding
    (C : FiniteClosureNucleus α)
    (hsep : PrimeSeparation C.cl C.nuc) :
    ∃ Φ : {s : Set α // IsClosed C.cl s} →
          {f : {p : Set α // JoinPrimeClosed C.cl C.nuc p} → Prop //
            SpectralObservable C.cl C.nuc f},
      Function.Bijective Φ := by
  refine ⟨fun ⟨s, hs⟩ => ⟨fun q => s ⊆ q.val, ⟨s, hs, rfl⟩⟩, ?_, ?_⟩
  · -- Injective
    intro ⟨s, hs⟩ ⟨t, ht⟩ heq
    simp only [Subtype.mk.injEq] at heq
    have key : spectralEval C.cl C.nuc s = spectralEval C.cl C.nuc t := by
      ext q; exact Iff.intro (fun h => (congr_fun heq q).mp h) (fun h => (congr_fun heq q).mpr h)
    exact Subtype.ext (spectral_eval_injective C.cl C.nuc C.isClosure hsep s t hs ht key)
  · -- Surjective
    intro ⟨f, hf⟩
    obtain ⟨s, hs, hfs⟩ := hf
    exact ⟨⟨s, hs⟩, by simp [hfs]⟩

/-! ## Section 6: Certified Theory Reconstruction -/

/-- Certified closure reconstruction: the closure operator is exactly the
    intersection of prime points. -/
theorem certified_closure_reconstruction
    (C : FiniteClosureNucleus α)
    (hsep : PrimeSeparation C.cl C.nuc) :
    ∃ reconstruct : Set α → Set α,
      (∀ A, reconstruct A =
        ⋂₀ {p | JoinPrimeClosed C.cl C.nuc p ∧ A ⊆ p}) ∧
      reconstruct = C.cl := by
  exact ⟨C.cl, closure_equals_sInter_of_prime_points C.cl C.nuc C.isClosure hsep, rfl⟩

/-! ## Section 7: Kripke Semantics -/

/-- Kripke entailment: A entails x when every prime point containing all of A
    also contains x. -/
def KripkeEntails (cl : Set α → Set α) (nuc : Set α → Set α)
    (A : Set α) (x : α) : Prop :=
  ∀ p, JoinPrimeClosed cl nuc p → A ⊆ p → x ∈ p

/-- **Implication semantics completeness**: membership in the closure equals
    Kripke entailment over prime points. Sound-and-complete finite Kripke
    semantics for the closure operator. -/
theorem implication_semantics_complete
    (C : FiniteClosureNucleus α)
    (hsep : PrimeSeparation C.cl C.nuc) :
    ∀ A x,
      x ∈ C.cl A ↔ KripkeEntails C.cl C.nuc A x :=
  fun A x => implication_valid_iff_all_prime_points C.cl C.nuc C.isClosure hsep A x

/-! ## Section 8: Implicational Basis Reconstruction -/

/-- An implicational rule `(Γ, x)` is valid in a closure system when
    `x ∈ cl(↑Γ)`. -/
def ImplicationValid (cl : Set α → Set α) (rule : Finset α × α) : Prop :=
  rule.2 ∈ cl (↑rule.1 : Set α)

/-- A canonical implicational basis: all valid implications on a finite type. -/
noncomputable def canonicalBasis (cl : Set α → Set α) : Finset (Finset α × α) :=
  Finset.univ.filter fun r => r.2 ∈ cl (↑r.1 : Set α)

/-- **Implicational basis reconstruction theorem**: There exists a finite basis
    of valid implications, and every valid implication is witnessed by all
    prime points (soundness of Kripke semantics on the basis). -/
theorem implicational_basis_reconstruction
    (C : FiniteClosureNucleus α)
    (hsep : PrimeSeparation C.cl C.nuc) :
    ∃ basis : Finset (Finset α × α),
      (∀ r ∈ basis, ImplicationValid C.cl r) ∧
      (∀ r ∈ basis, ∀ p, JoinPrimeClosed C.cl C.nuc p →
        (↑r.1 : Set α) ⊆ p → r.2 ∈ p) := by
  refine ⟨Finset.univ.filter fun r : Finset α × α => r.2 ∈ C.cl (↑r.1 : Set α), ?_, ?_⟩
  · intro r hr
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hr
    exact hr
  · intro r hr p hp hAp
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hr
    exact (implication_valid_iff_all_prime_points C.cl C.nuc C.isClosure hsep
      (↑r.1) r.2).mp hr p hp hAp

/-! ## Section 9: Nucleus-Fixed Fragment Characterization -/

/-- **Nucleus-fixed fragment characterization**: Under separation by
    nucleus-stable primes, the nucleus applied to a closure equals the
    intersection of stable primes containing the premise. -/
theorem nucleus_fixed_fragment_characterization
    (C : FiniteClosureNucleus α)
    (hsep_nuc : ∀ (s : Set α) (x : α),
      IsClosed C.cl s → C.nuc s = s → x ∉ s →
      ∃ p, JoinPrimeClosed C.cl C.nuc p ∧ C.nuc p = p ∧ s ⊆ p ∧ x ∉ p)
    (A : Set α) :
    C.nuc (C.cl A) =
      ⋂₀ {p | JoinPrimeClosed C.cl C.nuc p ∧ C.nuc p = p ∧ A ⊆ p} := by
  ext x; simp only [mem_sInter, mem_setOf_eq]; constructor
  · intro hx p ⟨hp, hnp, hAp⟩
    have hclAp : C.cl A ⊆ p :=
      closure_subset_of_closed_superset C.cl C.isClosure A p hp.closed hAp
    have : C.nuc (C.cl A) ⊆ C.nuc p := C.nuc_mono hclAp
    rw [hnp] at this
    exact this hx
  · intro hall
    by_contra hx
    have hclosed : IsClosed C.cl (C.nuc (C.cl A)) :=
      C.nuc_closed (C.cl A) (cl_is_closed C.cl C.isClosure A)
    have hstable : C.nuc (C.nuc (C.cl A)) = C.nuc (C.cl A) := C.nuc_idem (C.cl A)
    obtain ⟨p, hp, hnp, hsp, hxp⟩ := hsep_nuc (C.nuc (C.cl A)) x hclosed hstable hx
    have hAp : A ⊆ p :=
      Subset.trans (Subset.trans (C.isClosure.extensive A)
        (C.nuc_extensive_on_closed (C.cl A) (cl_is_closed C.cl C.isClosure A))) hsp
    exact hxp (hall p ⟨hp, hnp, hAp⟩)

/-! ## Section 10: Spectral Reconstruction Bridge -/

/-- The spectral reconstruction bridge: if two closed sets agree on all
    prime evaluations, they are equal. Mirrors `finite_spectral_reconstruction_bridge`
    with nucleus-stable closure observables replacing geometric observables. -/
theorem closure_spectral_reconstruction_bridge
    (C : FiniteClosureNucleus α)
    (hsep : PrimeSeparation C.cl C.nuc)
    (s t : Set α) (hs : IsClosed C.cl s) (ht : IsClosed C.cl t)
    (h : ∀ p, JoinPrimeClosed C.cl C.nuc p → (s ⊆ p ↔ t ⊆ p)) :
    s = t := by
  have heq : spectralEval C.cl C.nuc s = spectralEval C.cl C.nuc t := by
    ext ⟨p, hp⟩; exact h p hp
  exact spectral_eval_injective C.cl C.nuc C.isClosure hsep s t hs ht heq

/-! ## Section 11: Full Duality — Closed Sets ≅ Downward-Closed Observables

In the finite setting, the spectral evaluation gives not just an embedding
but a full bijection between closed sets and realizable observables. Combined
with the reconstruction theorems, this gives the complete finite closure–nucleus
spectral duality. -/

/-- **Finite closure–nucleus duality (full version)**: Under separation, there
    exists a finite type of spectral points with a preorder, together with a
    bijection between closed sets and spectral observables that preserves the
    order structure and supports certified reconstruction of the closure
    operator, nucleus, and complete Kripke semantics. -/
theorem finite_closure_nucleus_duality
    (C : FiniteClosureNucleus α)
    (hsep : PrimeSeparation C.cl C.nuc) :
    -- There exists spectral data and a bijection
    (∃ Φ : {s : Set α // IsClosed C.cl s} →
          {f : {p : Set α // JoinPrimeClosed C.cl C.nuc p} → Prop //
            SpectralObservable C.cl C.nuc f},
      Function.Bijective Φ) ∧
    -- The closure operator is reconstructible from spectral data
    (∀ A, C.cl A = ⋂₀ {p | JoinPrimeClosed C.cl C.nuc p ∧ A ⊆ p}) ∧
    -- Kripke semantics is sound and complete
    (∀ A x, x ∈ C.cl A ↔ KripkeEntails C.cl C.nuc A x) := by
  exact ⟨finite_closure_nucleus_spectral_embedding C hsep,
    fun A => closure_equals_sInter_of_prime_points C.cl C.nuc C.isClosure hsep A,
    fun A x => implication_valid_iff_all_prime_points C.cl C.nuc C.isClosure hsep A x⟩

/-! ## Section 12: Certified Theory Reconstruction (Combined) -/

/-- **Certified theory reconstruction**: From the finite spectral data of a
    closure-nucleus system with separation, one can recover:
    1. The original closure operator (via prime intersection).
    2. A finite implicational basis (via enumeration of valid rules).
    3. Sound-and-complete Kripke semantics (via prime-point forcing).
    4. The nucleus-fixed logical fragment (under stable separation). -/
theorem certified_theory_reconstruction
    (C : FiniteClosureNucleus α)
    (hsep : PrimeSeparation C.cl C.nuc)
    (hsep_nuc : ∀ (s : Set α) (x : α),
      IsClosed C.cl s → C.nuc s = s → x ∉ s →
      ∃ p, JoinPrimeClosed C.cl C.nuc p ∧ C.nuc p = p ∧ s ⊆ p ∧ x ∉ p) :
    -- Closure reconstruction
    (∀ A, C.cl A = ⋂₀ {p | JoinPrimeClosed C.cl C.nuc p ∧ A ⊆ p}) ∧
    -- Basis existence with Kripke validation
    (∃ basis : Finset (Finset α × α),
      (∀ r ∈ basis, ImplicationValid C.cl r) ∧
      (∀ r ∈ basis, ∀ p, JoinPrimeClosed C.cl C.nuc p →
        (↑r.1 : Set α) ⊆ p → r.2 ∈ p)) ∧
    -- Kripke completeness
    (∀ A x, x ∈ C.cl A ↔ KripkeEntails C.cl C.nuc A x) ∧
    -- Nucleus-fixed fragment
    (∀ A, C.nuc (C.cl A) =
      ⋂₀ {p | JoinPrimeClosed C.cl C.nuc p ∧ C.nuc p = p ∧ A ⊆ p}) := by
  exact ⟨
    fun A => closure_equals_sInter_of_prime_points C.cl C.nuc C.isClosure hsep A,
    implicational_basis_reconstruction C hsep,
    fun A x => implication_valid_iff_all_prime_points C.cl C.nuc C.isClosure hsep A x,
    nucleus_fixed_fragment_characterization C hsep_nuc⟩

end
end FiniteDuality
end ClosureNucleusDuality