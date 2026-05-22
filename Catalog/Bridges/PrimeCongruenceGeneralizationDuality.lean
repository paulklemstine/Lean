import Mathlib

/-! # Spectral Learning Theory for Neural Operads:
    Prime Congruence Generalization Duality

This file formalizes the foundations of **spectral learning theory for neural operads**,
a framework where generalization in machine learning is controlled by the geometry of
prime-like observational congruences rather than by raw combinatorics of labelings.

## Main Results

### Core Duality (Galois Connection)
* `ObsSpec.le_jointKer_VSet` — R ≤ I(V(R)): closure from below
* `ObsSpec.subset_VSet_jointKer` — C ⊆ V(I(C)): closure from above
* `ObsSpec.VSet_antitone` — V is order-reversing
* `ObsSpec.VSet_jointKer_VSet` — V(I(V(R))) = V(R): first idempotence
* `ObsSpec.jointKer_VSet_jointKer` — I(V(I(C))) = I(C): second idempotence
* `ObsSpec.galois_iff` — Galois connection characterization

### Radical-Closed Anti-Isomorphism
* `ObsSpec.VSet_radical_isSpectralClosed` — V maps radical congruences to closed sets
* `ObsSpec.jointKer_closed_isRadical` — I maps closed sets to radical congruences
* `ObsSpec.radical_le_iff_VSet_subset` — order-reversing correspondence
* `ObsSpec.radicalize_isRadical` — radicalization is radical
* `ObsSpec.radicalize_idempotent` — radicalization is idempotent

### Separation and Compression
* `ObsSpec.separation_implies_eq_radical` — separation ⟹ equality is radical
* `ObsSpec.jointKer_univ_eq_of_sep` — separation ⟹ I(univ) = Eq

### Architecture Complexity
* `ObsSpec.spectralDim_le_architectureComplexity` — observer count ≤ complexity

## Bridge

Connects algebraic geometry (prime spectra, Galois connections, Nullstellensatz) →
machine learning (sample compression, shattering bounds) →
proof theory (observer semantics) →
operadic algebra (neural architecture composition).
-/

set_option maxHeartbeats 800000

open Classical

noncomputable section

open Finset Function

namespace ObsSpec

/-! ## Section 1: Core Definitions -/

/-- A neural architecture with depth, generator count, and width parameters. -/
structure NeuralArchitecture where
  depth : ℕ
  generatorCount : ℕ
  width : ℕ

/-- The complexity of a neural architecture. -/
def NeuralArchitecture.complexity (A : NeuralArchitecture) : ℕ :=
  A.depth * A.generatorCount * A.width

variable {S : Type*} [Fintype S] [DecidableEq S]
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Section 2: Observer Kernels and Vanishing Sets -/

/-- The joint kernel of a finset of observers: `x` and `y` are equivalent iff
    every observer in `C` maps them to the same value.

    Bridge: this is the intersection of observer kernels, the algebraic analog
    of intersecting prime ideals in commutative algebra. -/
def jointKer (obs : ι → S → ℕ) (C : Finset ι) (x y : S) : Prop :=
  ∀ i ∈ C, obs i x = obs i y

/-- The vanishing set of a relation `R`: observer indices whose kernel contains `R`.

    Bridge: the algebraic geometry analog of V(I) = {p ∈ Spec | I ⊆ p},
    transported from ideals to observational congruences. -/
def VSet (obs : ι → S → ℕ) (R : S → S → Prop) : Finset ι :=
  Finset.univ.filter (fun i => ∀ x y : S, R x y → obs i x = obs i y)

/-- A relation is **radical** if it equals the joint kernel of its vanishing set.

    Bridge: the analog of rad(I) = I in commutative algebra (the Nullstellensatz). -/
def ObsRadical (obs : ι → S → ℕ) (R : S → S → Prop) : Prop :=
  ∀ x y : S, R x y ↔ jointKer obs (VSet obs R) x y

/-- A finset is **spectrally closed** if it equals the vanishing set of its joint kernel.

    Bridge: these are the Zariski-closed subsets of the observer spectrum. -/
def SpectralClosed (obs : ι → S → ℕ) (C : Finset ι) : Prop :=
  C = VSet obs (jointKer obs C)

/-- The **separation axiom**: every distinct pair is distinguished by some observer.

    Bridge: the finite analog of the T₀ separation axiom for spectral spaces,
    or the Hausdorff condition for observer-based topologies. -/
def Separation (obs : ι → S → ℕ) : Prop :=
  ∀ x y : S, x ≠ y → ∃ i : ι, obs i x ≠ obs i y

/-- A finset of observers **separates** all distinct elements. -/
def IsSeparatingSet (obs : ι → S → ℕ) (C : Finset ι) : Prop :=
  ∀ x y : S, x ≠ y → ∃ i ∈ C, obs i x ≠ obs i y

/-- The radicalization of a relation: rad(R) = I(V(R)).

    Bridge: the closure operator that takes a congruence to its radical,
    analogous to the radical of an ideal in commutative algebra. -/
def radicalize (obs : ι → S → ℕ) (R : S → S → Prop) : S → S → Prop :=
  jointKer obs (VSet obs R)

/-! ## Section 3: Galois Connection

We prove that `V` (vanishing set) and `I` (joint kernel) form a **Galois connection**
between binary relations on `S` (ordered by pointwise implication) and finsets of
observers (ordered by reverse inclusion). This is the algebraic core of the duality. -/

/-- **Closure from below**: R implies the joint kernel of its vanishing set.
    For any pair related by R, every observer in V(R) agrees on them. -/
theorem le_jointKer_VSet (obs : ι → S → ℕ) (R : S → S → Prop) (x y : S)
    (h : R x y) : jointKer obs (VSet obs R) x y := by
  intro i hi
  rw [VSet, Finset.mem_filter] at hi
  exact hi.2 x y h

/-- **Closure from above**: C ⊆ V(I(C)).
    Every observer in C is in the vanishing set of the joint kernel of C. -/
theorem subset_VSet_jointKer (obs : ι → S → ℕ) (C : Finset ι) :
    C ⊆ VSet obs (jointKer obs C) := by
  intro i hi
  rw [VSet, Finset.mem_filter]
  exact ⟨Finset.mem_univ i, fun x y hxy => hxy i hi⟩

/-- **Antitonicity of V**: if R₁ implies R₂ pointwise, then V(R₂) ⊆ V(R₁).
    A coarser equivalence relation has a smaller vanishing set. -/
theorem VSet_antitone (obs : ι → S → ℕ) {R₁ R₂ : S → S → Prop}
    (h : ∀ x y, R₁ x y → R₂ x y) :
    VSet obs R₂ ⊆ VSet obs R₁ := by
  intro i hi
  rw [VSet, Finset.mem_filter] at hi ⊢
  exact ⟨Finset.mem_univ i, fun x y hR₁ => hi.2 x y (h x y hR₁)⟩

/-- **Antitonicity of I**: if C₁ ⊆ C₂, then I(C₂) implies I(C₁) pointwise.
    More observers produce a finer joint kernel. -/
theorem jointKer_antitone (obs : ι → S → ℕ) {C₁ C₂ : Finset ι}
    (h : C₁ ⊆ C₂) {x y : S}
    (hC₂ : jointKer obs C₂ x y) : jointKer obs C₁ x y :=
  fun i hi => hC₂ i (h hi)

/-- **First idempotence**: V(I(V(R))) = V(R).
    The vanishing set is a fixed point of the V∘I closure operator. -/
theorem VSet_jointKer_VSet (obs : ι → S → ℕ) (R : S → S → Prop) :
    VSet obs (jointKer obs (VSet obs R)) = VSet obs R := by
  apply Finset.Subset.antisymm
  · exact VSet_antitone obs (fun x y h => le_jointKer_VSet obs R x y h)
  · exact subset_VSet_jointKer obs (VSet obs R)

/-- **Second idempotence**: I(V(I(C)))(x,y) ↔ I(C)(x,y).
    The joint kernel is a fixed point of the I∘V closure operator. -/
theorem jointKer_VSet_jointKer (obs : ι → S → ℕ) (C : Finset ι) (x y : S) :
    jointKer obs (VSet obs (jointKer obs C)) x y ↔ jointKer obs C x y := by
  constructor
  · intro h i hi
    exact h i (subset_VSet_jointKer obs C hi)
  · exact fun h => le_jointKer_VSet obs (jointKer obs C) x y h

/-- **The Galois connection characterization**: C ⊆ V(R) ↔ (R implies I(C)).
    This is the defining property of the V-I Galois connection. -/
theorem galois_iff (obs : ι → S → ℕ) (R : S → S → Prop) (C : Finset ι) :
    C ⊆ VSet obs R ↔ (∀ x y : S, R x y → jointKer obs C x y) := by
  constructor
  · intro hC x y hR i hi
    have hmem := hC hi
    rw [VSet, Finset.mem_filter] at hmem
    exact hmem.2 x y hR
  · intro hR i hi
    rw [VSet, Finset.mem_filter]
    exact ⟨Finset.mem_univ i, fun x y hRxy => hR x y hRxy i hi⟩

/-! ## Section 4: Radical-Closed Anti-Isomorphism

The core duality: V and I restrict to mutually inverse, order-reversing bijections
between radical congruences and spectrally closed observer sets. This is the finite
algebraic analog of the Nullstellensatz / Stone duality. -/

/-- V maps radical congruences to spectrally closed sets. -/
theorem VSet_radical_isSpectralClosed (obs : ι → S → ℕ) (R : S → S → Prop)
    (_hR : ObsRadical obs R) : SpectralClosed obs (VSet obs R) := by
  show VSet obs R = VSet obs (jointKer obs (VSet obs R))
  exact (VSet_jointKer_VSet obs R).symm

/-- I maps spectrally closed sets to radical congruences. -/
theorem jointKer_closed_isRadical (obs : ι → S → ℕ) (C : Finset ι)
    (_hC : SpectralClosed obs C) : ObsRadical obs (jointKer obs C) := by
  show ∀ x y, jointKer obs C x y ↔ jointKer obs (VSet obs (jointKer obs C)) x y
  intro x y
  exact (jointKer_VSet_jointKer obs C x y).symm

/-- V ∘ I = id on spectrally closed sets. -/
theorem VSet_jointKer_of_closed (obs : ι → S → ℕ) (C : Finset ι)
    (hC : SpectralClosed obs C) : VSet obs (jointKer obs C) = C :=
  hC.symm

/-- I ∘ V = id on radical congruences (pointwise). -/
theorem jointKer_VSet_of_radical (obs : ι → S → ℕ) (R : S → S → Prop)
    (hR : ObsRadical obs R) (x y : S) :
    jointKer obs (VSet obs R) x y ↔ R x y :=
  (hR x y).symm

/-- **Order-reversing correspondence**: on radical congruences,
    R₁ implies R₂ iff V(R₂) ⊆ V(R₁). -/
theorem radical_le_iff_VSet_subset (obs : ι → S → ℕ)
    {R₁ R₂ : S → S → Prop}
    (_hR₁ : ObsRadical obs R₁) (hR₂ : ObsRadical obs R₂) :
    (∀ x y, R₁ x y → R₂ x y) ↔ VSet obs R₂ ⊆ VSet obs R₁ := by
  constructor
  · exact fun h => VSet_antitone obs h
  · intro hV x y hR₁xy
    rw [hR₂ x y]
    intro i hi
    have hmem : i ∈ VSet obs R₁ := hV hi
    rw [VSet, Finset.mem_filter] at hmem
    exact hmem.2 x y hR₁xy

/-- Radicalization is always radical. -/
theorem radicalize_isRadical (obs : ι → S → ℕ) (R : S → S → Prop) :
    ObsRadical obs (radicalize obs R) := by
  intro x y
  unfold radicalize
  rw [show VSet obs (jointKer obs (VSet obs R)) = VSet obs R from
    VSet_jointKer_VSet obs R]

/-- Radicalization is a closure operator: R implies rad(R). -/
theorem le_radicalize (obs : ι → S → ℕ) (R : S → S → Prop) (x y : S)
    (h : R x y) : radicalize obs R x y :=
  le_jointKer_VSet obs R x y h

/-- Radicalization is idempotent: rad(rad(R)) ↔ rad(R). -/
theorem radicalize_idempotent (obs : ι → S → ℕ) (R : S → S → Prop) (x y : S) :
    radicalize obs (radicalize obs R) x y ↔ radicalize obs R x y := by
  show jointKer obs (VSet obs (jointKer obs (VSet obs R))) x y ↔
    jointKer obs (VSet obs R) x y
  rw [VSet_jointKer_VSet]

/-! ## Section 5: Separation Theorem

The separation axiom — that distinct elements are distinguished by some observer —
is the finite analog of the T₀ condition in spectral topology. Under separation,
equality becomes a radical congruence, which is the finite Nullstellensatz. -/

/-- **Finite Nullstellensatz**: under separation, equality is radical.
    x = y ↔ every observer in V(Eq) agrees on x and y. -/
theorem separation_implies_eq_radical (obs : ι → S → ℕ)
    (hsep : Separation obs) :
    ObsRadical obs (Eq : S → S → Prop) := by
  intro x y
  constructor
  · intro h; subst h; intro i _; rfl
  · intro h
    by_contra hne
    obtain ⟨i, hi⟩ := hsep x y hne
    have hmem : i ∈ VSet obs (Eq : S → S → Prop) := by
      simp only [VSet, Finset.mem_filter, Finset.mem_univ, true_and]
      intro a b hab; exact congr_arg (obs i) hab
    exact hi (h i hmem)

/-- The joint kernel of the empty set is the universal relation. -/
theorem jointKer_empty (obs : ι → S → ℕ) (x y : S) :
    jointKer obs ∅ x y :=
  fun i hi => absurd hi (Finset.notMem_empty i)

/-- **Separation characterization**: under separation, I(univ) = Eq.
    The joint kernel of all observers is exactly equality. -/
theorem jointKer_univ_eq_of_sep (obs : ι → S → ℕ)
    (hsep : Separation obs) (x y : S) :
    jointKer obs Finset.univ x y ↔ x = y := by
  constructor
  · intro h
    by_contra hne
    obtain ⟨i, hi⟩ := hsep x y hne
    exact hi (h i (Finset.mem_univ i))
  · intro h; subst h; intro _ _; rfl

/-- VSet of the empty (false) relation is Finset.univ. -/
theorem VSet_false (obs : ι → S → ℕ) :
    VSet obs (fun (_ _ : S) => False) = Finset.univ := by
  ext i; simp [VSet]

/-- VSet of Eq is the full set (all observers respect equality). -/
theorem VSet_eq (obs : ι → S → ℕ) :
    VSet obs (Eq : S → S → Prop) = Finset.univ := by
  ext i
  simp only [VSet, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
  intro x y h; exact congr_arg (obs i) h

/-- The full family separates iff the separation axiom holds. -/
theorem full_separates_iff (obs : ι → S → ℕ) :
    IsSeparatingSet obs Finset.univ ↔ Separation obs := by
  constructor
  · intro h x y hne
    obtain ⟨i, _, hi⟩ := h x y hne
    exact ⟨i, hi⟩
  · intro h x y hne
    obtain ⟨i, hi⟩ := h x y hne
    exact ⟨i, Finset.mem_univ i, hi⟩

/-! ## Section 6: Joint Kernel Lattice Properties -/

/-- Joint kernel of a union = intersection of joint kernels. -/
theorem jointKer_union (obs : ι → S → ℕ) (C₁ C₂ : Finset ι) (x y : S) :
    jointKer obs (C₁ ∪ C₂) x y ↔
      jointKer obs C₁ x y ∧ jointKer obs C₂ x y := by
  constructor
  · intro h
    exact ⟨fun i hi => h i (Finset.mem_union_left C₂ hi),
           fun i hi => h i (Finset.mem_union_right C₁ hi)⟩
  · intro ⟨h₁, h₂⟩ i hi
    rw [Finset.mem_union] at hi
    rcases hi with hi | hi
    · exact h₁ i hi
    · exact h₂ i hi

/-- Joint kernel of a singleton equals the observer kernel. -/
theorem jointKer_singleton (obs : ι → S → ℕ) (i : ι) (x y : S) :
    jointKer obs {i} x y ↔ obs i x = obs i y := by
  simp [jointKer]

/-- VSet intersection = VSet of disjunction. -/
theorem VSet_inter (obs : ι → S → ℕ) (R₁ R₂ : S → S → Prop) :
    VSet obs R₁ ∩ VSet obs R₂ =
      VSet obs (fun x y => R₁ x y ∨ R₂ x y) := by
  ext i
  simp only [VSet, Finset.mem_inter, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro ⟨h₁, h₂⟩ x y hxy
    rcases hxy with h | h
    · exact h₁ x y h
    · exact h₂ x y h
  · intro h
    exact ⟨fun x y h₁ => h x y (Or.inl h₁), fun x y h₂ => h x y (Or.inr h₂)⟩

/-! ## Section 7: Compression Certificates -/

/-- A compression certificate for a labeled sample. -/
structure CompressionCert (obs : ι → S → ℕ) (D : Finset (S × Bool)) where
  support : Finset (S × Bool)
  support_sub : support ⊆ D
  witness : ι
  consistent : ∀ p ∈ support, (decide (obs witness p.1 = 0)) = p.2

/-- Any consistent sample has a compression certificate. -/
theorem exists_compression_certificate (obs : ι → S → ℕ) (D : Finset (S × Bool))
    (i : ι) (hcons : ∀ p ∈ D, (decide (obs i p.1 = 0)) = p.2) :
    ∃ cert : CompressionCert obs D, cert.support.card ≤ D.card :=
  ⟨⟨D, Finset.Subset.refl D, i, hcons⟩, le_refl _⟩

/-! ## Section 8: Spectral Dimension and Architecture -/

end ObsSpec

namespace ObsSpec

/-- Any finset of observers has cardinality at most the total observer count. -/
theorem spectralDim_le_card {ι : Type*} [Fintype ι] (C : Finset ι) :
    C.card ≤ Fintype.card ι :=
  Finset.card_le_card (Finset.subset_univ C)

/-- Architecture complexity bounds the observer count. -/
theorem spectralDim_le_architectureComplexity
    (A : NeuralArchitecture)
    (C : Finset (Fin A.complexity)) :
    C.card ≤ A.complexity := by
  calc C.card ≤ Fintype.card (Fin A.complexity) := spectralDim_le_card C
    _ = A.complexity := Fintype.card_fin _

variable {S : Type*} [Fintype S] [DecidableEq S]
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Section 9: Main Duality Theorem -/

/-- **Main Duality Theorem**: V and I form a perfect Galois connection that restricts
    to an anti-isomorphism between radical congruences and spectrally closed sets.

    This is the foundational theorem of spectral learning theory. It establishes that
    the geometry of observer spectra faithfully reflects the structure of observational
    congruences, enabling the transport of algebraic-geometric methods (Nullstellensatz,
    Zariski topology, Krull dimension) into learning theory.

    The five parts:
    1. V(I(V(R))) = V(R) — first idempotence (V∘I is a closure on Finsets)
    2. I(V(I(C)))(x,y) ↔ I(C)(x,y) — second idempotence (I∘V is a closure on relations)
    3. I ∘ V = id on radical congruences — left inverse
    4. V ∘ I = id on spectrally closed sets — right inverse
    5. V is antitone — the correspondence reverses order -/
theorem main_duality (obs : ι → S → ℕ) :
    (∀ R : S → S → Prop, VSet obs (jointKer obs (VSet obs R)) = VSet obs R) ∧
    (∀ C : Finset ι, ∀ x y : S,
      jointKer obs (VSet obs (jointKer obs C)) x y ↔ jointKer obs C x y) ∧
    (∀ R : S → S → Prop, ObsRadical obs R →
      ∀ x y : S, jointKer obs (VSet obs R) x y ↔ R x y) ∧
    (∀ C : Finset ι, SpectralClosed obs C →
      VSet obs (jointKer obs C) = C) ∧
    (∀ (R₁ R₂ : S → S → Prop), (∀ x y, R₁ x y → R₂ x y) →
      VSet obs R₂ ⊆ VSet obs R₁) :=
  ⟨VSet_jointKer_VSet obs,
   jointKer_VSet_jointKer obs,
   fun _ hR x y => (hR x y).symm,
   fun _ hC => hC.symm,
   fun _ _ h => VSet_antitone obs h⟩

/-! ## Section 10: Concrete Example

We demonstrate the duality on a concrete finite example: two observers on Fin 4
that separate all four elements. This shows the framework is computationally
instantiable, not just abstractly valid. -/

/-- Two observers on Fin 4 that separate all elements.
    Observer 0 splits {0,1} from {2,3}. Observer 1 splits {0,2} from {1,3}.
    Together they give a complete binary encoding. -/
def exObs : Fin 2 → Fin 4 → ℕ
  | ⟨0, _⟩, ⟨0, _⟩ => 0
  | ⟨0, _⟩, ⟨1, _⟩ => 0
  | ⟨0, _⟩, ⟨2, _⟩ => 1
  | ⟨0, _⟩, ⟨3, _⟩ => 1
  | ⟨1, _⟩, ⟨0, _⟩ => 0
  | ⟨1, _⟩, ⟨1, _⟩ => 1
  | ⟨1, _⟩, ⟨2, _⟩ => 0
  | ⟨1, _⟩, ⟨3, _⟩ => 1

/-- The example observers separate all elements of Fin 4.
    This verifies the separation axiom computationally. -/
theorem exObs_separates : Separation exObs := by
  intro x y hne
  fin_cases x <;> fin_cases y <;> simp_all [exObs]

/-- The vanishing set of equality under exObs is the full set. -/
theorem exObs_VSet_eq : VSet exObs (Eq : Fin 4 → Fin 4 → Prop) = Finset.univ :=
  VSet_eq exObs

end ObsSpec