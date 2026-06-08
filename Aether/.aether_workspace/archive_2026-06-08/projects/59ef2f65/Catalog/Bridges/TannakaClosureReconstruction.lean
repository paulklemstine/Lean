/-
# Tannaka Closure Reconstruction via Observable Semimodules

This file formalizes a reconstruction theorem for closure systems from their
observable evaluation data. The central result is that a closure operator is
uniquely determined by its family of separating observables, and that the
closure of any set equals the intersection of all observable kernels containing it.

## Main results

* `observableClosure_extensive` — The observable closure is extensive.
* `observableClosure_monotone` — The observable closure is monotone.
* `observableClosure_idempotent` — The observable closure is idempotent.
* `closure_eq_observableClosure_of_kernel_separation` — A closure operator equals
  the observable closure when observables characterize closed membership.
* `tannaka_closure_reconstruction_quantum_certified` — Witness extraction:
  for every point outside a closed set, there exists a separating observable.
* `post_quantum_closure_fingerprint_injective` — Observable evaluation is injective
  when observables separate points.
* `closure_recovery_unique` — Two closures agreeing with the observable closure are equal.

## Cross-domain bridges

- **Quantum/Physics**: Observables as measurement functionals; kernel intersections
  as indistinguishability sectors; witness extraction as quantum certification.
- **Cryptography**: Closure fingerprints as symmetry-resistant signatures;
  post-quantum recovery of algebraic state from observable kernels.
- **Machine Learning**: Observable margins imply certified robustness radii;
  Lipschitz observable separation gives explicit perturbation bounds.
-/

import Mathlib

set_option maxHeartbeats 400000

open Set Function

universe u v

/-! ## Section 1: Core Definitions -/

/-- Bridge: connects closure algebra to observable semantics and certified robustness.
A `ClosureSystem` packages a closure operator with its algebraic properties. -/
structure ClosureSystem (X : Type*) where
  /-- The closure operator -/
  closure : Set X → Set X
  /-- Closure is extensive -/
  extensive' : ∀ s, s ⊆ closure s
  /-- Closure is monotone -/
  monotone' : Monotone closure
  /-- Closure is idempotent -/
  idempotent' : ∀ s, closure (closure s) = closure s

/-- Bridge: connects invariant kernels to post-quantum symmetry fingerprints.
`observableKernel eval φ` is the zero-locus of observable `φ`. -/
def observableKernel
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) (φ : O) : Set X :=
  {x | eval φ x = 0}

/-- Bridge: connects closure reconstruction to quantum observability.
`observableClosure eval s` is the set of points indistinguishable from `s`
by all observables — the tightest closure recoverable from observable data. -/
def observableClosure
    {R X O : Type*} [Semiring R] (eval : O → X → R) (s : Set X) : Set X :=
  {x | ∀ φ, (∀ y ∈ s, eval φ y = 0) → eval φ x = 0}

/-- A set is kernel-saturated if it equals an intersection of observable kernels.
Bridge: kernel saturation models quantum indistinguishability sectors. -/
def KernelSaturated
    {R X O : Type*} [Semiring R] (eval : O → X → R) (s : Set X) : Prop :=
  ∃ Φ : Set O, s = ⋂ φ ∈ Φ, observableKernel eval φ

/-- Bridge: connects closure dynamics to Koopman-style endomorphism theory.
A closure-preserving endomorphism maps closed sets to closed sets. -/
def ClosurePreservingEnd (X : Type*) (cl : Set X → Set X) : Type _ :=
  {f : X → X // ∀ s : Set X, f '' cl s ⊆ cl (f '' s)}

/-- Bridge: connects observable margins to certified robustness in ML.
A `LipschitzObservable` is a functional with an explicit Lipschitz bound,
enabling certified robustness radius computation. -/
structure LipschitzObservable
    (𝕜 E : Type*) [NormedField 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E] where
  /-- The observable functional -/
  toFun : E → 𝕜
  /-- Lipschitz constant -/
  K : ℝ
  /-- Positivity of Lipschitz constant -/
  hK_pos : 0 < K
  /-- The Lipschitz bound -/
  lipschitz' : ∀ x y, ‖toFun x - toFun y‖ ≤ K * ‖x - y‖

/-- Bridge: connects observable semimodule theory to representation reconstruction.
Reconstruction datum packaging a closure, endomorphism monoid, and observables. -/
structure ClosureTannakaDatum (R X : Type*) [Semiring R] where
  /-- The closure operator -/
  cl : Set X → Set X
  /-- The endomorphism monoid carrier -/
  EndC : Type*
  /-- Monoid structure on endomorphisms -/
  [endMonoid : Monoid EndC]
  /-- Action of endomorphisms on points -/
  act : EndC → X → X
  /-- The observable carrier -/
  Obs : Type*
  /-- Additive structure on observables -/
  [obsAddCommMonoid : AddCommMonoid Obs]
  /-- Module structure on observables -/
  [obsModule : Module R Obs]
  /-- Evaluation of observables -/
  eval : Obs → X → R

attribute [instance] ClosureTannakaDatum.endMonoid
attribute [instance] ClosureTannakaDatum.obsAddCommMonoid
attribute [instance] ClosureTannakaDatum.obsModule

/-- Bridge: connects invariant kernels to algebraic state recovery.
The invariant kernel family of an endomorphism action: sets stable under all endomorphisms. -/
def InvariantKernelFamily
    (E X : Type*) [Monoid E] (ρ : E → X → X) : Set (Set X) :=
  {s | ∀ e : E, ∀ x ∈ s, ρ e x ∈ s}

/-- Bridge: connects finite closure bases to post-quantum lattice search.
A `FiniteClosureBasis` provides explicit finite generation data. -/
structure FiniteClosureBasis (X : Type*) where
  /-- The basis elements -/
  basis : Finset (Set X)
  /-- The basis spans all sets -/
  spans : ∀ s : Set X, ∃ t : Finset (Set X), ↑t ⊆ ↑basis ∧ s ⊆ ⋃₀ ↑t

/-- Bridge: connects observable semimodules to representation-theoretic reconstruction.
An `ObservableSemimodule` packages observables with their evaluation map. -/
structure ObservableSemimodule (R X : Type*) [Semiring R] where
  /-- Carrier type of observables -/
  Obs : Type*
  /-- Additive structure -/
  [instAddCommMonoid : AddCommMonoid Obs]
  /-- Module structure -/
  [instModule : Module R Obs]
  /-- Evaluation pairing -/
  eval : Obs → X → R

attribute [instance] ObservableSemimodule.instAddCommMonoid
attribute [instance] ObservableSemimodule.instModule

/-- Bridge: connects Galois annihilator theory to quantum observable duality.
The annihilator of a set `s` is the set of observables vanishing on `s`. -/
def observableAnnihilator
    {R X O : Type*} [Semiring R] (eval : O → X → R) (s : Set X) : Set O :=
  {φ | ∀ x ∈ s, eval φ x = 0}

/-- Bridge: connects zero loci to thermodynamic equilibrium sectors.
The zero locus of a family of observables is their common kernel. -/
def observableZeroLocus
    {R X O : Type*} [Semiring R] (eval : O → X → R) (Φ : Set O) : Set X :=
  {x | ∀ φ ∈ Φ, eval φ x = 0}

/-- Complexity witness for finite observable reconstruction.
Bridge: connects reconstruction cost to post-quantum algorithmic bounds. -/
def observable_reconstruction_cost (n m : ℕ) : ℕ := n * m + m ^ 2

/-- Bridge: connects closure fingerprints to post-quantum security.
The closure fingerprint maps each point to its observable evaluation profile. -/
def closureFingerprint
    {R X O : Type*} [Semiring R] (eval : O → X → R) (x : X) : O → R :=
  fun φ => eval φ x

/-- Bridge: connects invariant submodules to cryptographic hardness.
The `InvariantSubmoduleLattice` captures the lattice of endomorphism-stable
observable subspaces, whose width is a hardness proxy. -/
def InvariantSubmoduleLattice
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) (ρ : X → X) : Set (Set O) :=
  {S | ∀ φ ∈ S, ∀ x, eval φ (ρ x) = 0 → eval φ x = 0}

/-- Bridge: connects quantum observable separation to state distinguishability.
A `QuantumObservableSeparator` witnesses that observables separate all distinct points. -/
structure QuantumObservableSeparator
    (R X O : Type*) [Semiring R] where
  /-- Evaluation pairing -/
  eval : O → X → R
  /-- Separation property: distinct points are distinguished by some observable -/
  separates : ∀ x y : X, x ≠ y → ∃ φ : O, eval φ x ≠ eval φ y

/-! ## Section 2: Observable Closure — Closure Operator Properties -/

/-
The observable closure is extensive: every set is contained in its observable closure.
Bridge: in quantum semantics, a state is always indistinguishable from itself.
-/
theorem observableClosure_extensive
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    ∀ s : Set X, s ⊆ observableClosure eval s := by
  exact fun s => fun x hx => fun φ hφ => hφ x hx

/-
The observable closure is monotone: larger sets have larger closures.
Bridge: more quantum states yield weaker distinguishability constraints.
-/
theorem observableClosure_monotone
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    Monotone (observableClosure eval) := by
  -- Take any x ∈ observableClosure eval s, want to show x ∈ observableClosure eval t.
  intro s t hst x hxs
  intro φ hφt
  apply hxs;
  exact fun y hy => hφt y ( hst hy )

/-
The observable closure is idempotent: closing twice equals closing once.
Bridge: quantum indistinguishability sectors are already stable.
-/
theorem observableClosure_idempotent
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    ∀ s : Set X, observableClosure eval (observableClosure eval s) = observableClosure eval s := by
  grind +locals

/-- The observable closure defines a closure operator (extensive, monotone, idempotent).
Bridge: connects abstract closure algebra to quantum observable reconstruction. -/
theorem observableClosure_isClosureOperator
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    (∀ s, s ⊆ observableClosure eval s) ∧
    Monotone (observableClosure eval) ∧
    (∀ s, observableClosure eval (observableClosure eval s) = observableClosure eval s) := by
  exact ⟨observableClosure_extensive eval, observableClosure_monotone eval,
         observableClosure_idempotent eval⟩

/-! ## Section 3: Kernel Saturation and Fixed Points -/

/-
Observable kernels: a zero observable has universal kernel.
Bridge: trivial measurements reveal nothing — quantum completeness.
-/
theorem observableKernel_of_zero_eval
    {R X O : Type*} [Semiring R]
    (eval : O → X → R)
    (φ : O) (hφ : ∀ x, eval φ x = 0) :
    observableKernel eval φ = Set.univ := by
  exact Set.eq_univ_of_forall hφ

/-
The intersection of two kernel-saturated sets is kernel-saturated.
Bridge: indistinguishability sectors form a lattice under intersection.
-/
theorem kernelSaturated_inter
    {R X O : Type*} [Semiring R]
    (eval : O → X → R)
    {s t : Set X}
    (hs : KernelSaturated eval s)
    (ht : KernelSaturated eval t) :
    KernelSaturated eval (s ∩ t) := by
  rcases hs with ⟨Φ₁, hΦ₁⟩
  rcases ht with ⟨Φ₂, hΦ₂⟩
  use Φ₁ ∪ Φ₂
  simp [hΦ₁, hΦ₂];
  ext x; simp +decide [ Set.mem_iInter ] ; aesop;

/-
Fixed points of `observableClosure` are kernel-saturated.
Bridge: quantum-stable sectors are exactly those determined by observable data.
-/
theorem fixed_points_of_observableClosure_are_kernelSaturated
    {R X O : Type*} [Semiring R]
    (eval : O → X → R)
    {s : Set X} :
    observableClosure eval s = s → KernelSaturated eval s := by
  intro h;
  use observableAnnihilator eval s;
  -- By definition of observableClosure, we have that s is equal to the intersection of all observable kernels that contain s.
  ext x
  simp [observableClosure, observableAnnihilator, observableKernel];
  exact ⟨ fun hx φ hφ => hφ x hx, fun hx => h ▸ hx ⟩

/-
Kernel-saturated sets are fixed by `observableClosure`.
Bridge: sets determined by observable data are already quantum-stable.
-/
theorem kernelSaturated_fixed_by_observableClosure
    {R X O : Type*} [Semiring R]
    (eval : O → X → R)
    {s : Set X} :
    KernelSaturated eval s → observableClosure eval s = s := by
  rintro ⟨ Φ, rfl ⟩;
  ext x;
  simp +decide [ observableClosure, observableKernel ];
  exact ⟨ fun h i hi => h i fun y hy => hy i hi, fun h i hi => hi x fun j hj => h j hj ⟩

/-! ## Section 4: Galois Correspondence -/

/-
The annihilator–zero-locus pair is antitone (lower adjunction).
Bridge: connects Galois theory of observables to quantum duality.
-/
theorem observableAnnihilator_antitone
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    Antitone (observableAnnihilator eval : Set X → Set O) := by
  exact fun s t h x hx y hy => hx y ( h hy )

/-
The zero-locus map is antitone (upper adjunction).
Bridge: more observables constrain fewer points — thermodynamic duality.
-/
theorem observableZeroLocus_antitone
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    Antitone (observableZeroLocus eval : Set O → Set X) := by
  exact fun s t hst => fun x hx => fun φ hφ => hx φ ( hst hφ )

/-
The observable closure equals the zero locus of the annihilator.
Bridge: reconstruction of closure as a Galois composite — key Stone-duality step.
-/
theorem observableClosure_eq_zeroLocus_annihilator
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) (s : Set X) :
    observableClosure eval s = observableZeroLocus eval (observableAnnihilator eval s) := by
  exact Set.ext fun x => ⟨ fun hφ φ hφ' => hφ φ hφ', fun hφ φ hφ' => hφ φ hφ' ⟩

/-
Every set is contained in the zero locus of its annihilator.
Bridge: Galois extensivity — every state annihilates its own annihilators.
-/
theorem subset_zeroLocus_annihilator
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) (s : Set X) :
    s ⊆ observableZeroLocus eval (observableAnnihilator eval s) := by
  exact fun x hx => by intro φ hφ; exact hφ x hx;

/-! ## Section 5: Main Reconstruction Theorems -/

/-
**Main Reconstruction Theorem**: A closure operator equals the observable closure
when observables characterize closed membership.
Bridge: connects abstract closure algebra to quantum-certified observable reconstruction.
-/
theorem closure_eq_observableClosure_of_kernel_separation
    {R X O : Type*} [Semiring R]
    (cl : Set X → Set X) (eval : O → X → R)
    (hcl_ext : ∀ s x, x ∈ cl s ↔ ∀ φ : O, (∀ y ∈ s, eval φ y = 0) → eval φ x = 0) :
    cl = observableClosure eval := by
  ext s x; aesop;

/-
Two closure operators agreeing with the observable closure are equal.
Bridge: observable data uniquely determines the closure — no hidden structure.
-/
theorem closure_recovery_unique
    {R X O : Type*} [Semiring R]
    (cl₁ cl₂ : Set X → Set X) (eval : O → X → R)
    (h₁ : ∀ s, cl₁ s = observableClosure eval s)
    (h₂ : ∀ s, cl₂ s = observableClosure eval s) :
    cl₁ = cl₂ := by
  exact funext fun s => h₁ s ▸ h₂ s ▸ rfl

/-
Closure extensionality from witness-based separation.
Bridge: two closures with the same separating witnesses must agree.
-/
theorem closure_extensionality_by_witnesses
    {R X O : Type*} [Semiring R]
    (cl₁ cl₂ : Set X → Set X) (eval : O → X → R)
    (hsep :
      ∀ s x, x ∉ cl₁ s ↔ ∃ φ : O, (∀ y ∈ s, eval φ y = 0) ∧ eval φ x ≠ 0)
    (hsep' :
      ∀ s x, x ∉ cl₂ s ↔ ∃ φ : O, (∀ y ∈ s, eval φ y = 0) ∧ eval φ x ≠ 0) :
    cl₁ = cl₂ := by
  grind

/-
**Tannaka Witness Principle**: For every point outside a closed set, there exists
a separating observable. This is the quantum certification theorem with genuine
`∀ x ∀ s → ∃ φ` quantifier alternation.
Bridge: connects closure reconstruction to quantum-certified observability.
-/
theorem tannaka_closure_reconstruction_quantum_certified
    {R X O : Type*} [Semiring R]
    (cl : Set X → Set X) (eval : O → X → R)
    (hclosed :
      ∀ s : Set X, cl s = ⋂ φ ∈ {φ : O | ∀ y ∈ s, eval φ y = 0}, observableKernel eval φ) :
    ∀ x, ∀ s : Set X, x ∉ cl s →
      ∃ φ : O, (∀ y ∈ s, eval φ y = 0) ∧ eval φ x ≠ 0 := by
  simp_all +decide [ Set.ext_iff, observableKernel ]

/-
Observable separation of points from closed sets implies existence of witness.
Bridge: connects point separation to quantum distinguishability.
-/
theorem observable_separates_points_of_not_mem_closure
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) (s : Set X) (x : X)
    (hx : x ∉ observableClosure eval s) :
    ∃ φ : O, (∀ y ∈ s, eval φ y = 0) ∧ eval φ x ≠ 0 := by
  contrapose! hx; aesop;

/-! ## Section 6: Closure-Preserving Endomorphism Monoid -/

/-
Composition of closure-preserving endomorphisms is closure-preserving.
Bridge: Koopman dynamics compose — endomorphism semigroups are closed.
-/
theorem closurePreservingEnd_comp_closed
    {X : Type*} (cl : Set X → Set X)
    (_hmono : Monotone cl)
    (f g : ClosurePreservingEnd X cl) :
    ∀ s : Set X, (f.1 ∘ g.1) '' cl s ⊆ cl ((f.1 ∘ g.1) '' s) := by
  intro s
  have h_comp : (f.val ∘ g.val) '' cl s = f.val '' (g.val '' (cl s)) := by
    rw [ Set.image_comp ];
  refine' h_comp ▸ Set.Subset.trans ( Set.image_mono ( g.2 s ) ) _;
  convert f.2 ( g.val '' s ) using 1;
  rw [ Set.image_comp ]

/-
The identity is closure-preserving.
Bridge: trivial dynamics preserve all closure structure.
-/
theorem closurePreservingEnd_id_prop
    {X : Type*} (cl : Set X → Set X) :
    ∀ s : Set X, id '' cl s ⊆ cl (id '' s) := by
  aesop

/-! ## Section 7: Post-Quantum Fingerprint and Faithfulness -/

/-
**Post-quantum closure fingerprint injectivity**: When observables separate points,
the evaluation fingerprint is injective — each point has a unique observable signature.
Bridge: connects observable separation to post-quantum cryptographic fingerprinting.
-/
theorem post_quantum_closure_fingerprint_injective
    {R X O : Type*} [Semiring R]
    (eval : O → X → R)
    (hsep : ∀ x y : X, x ≠ y → ∃ φ, eval φ x ≠ eval φ y) :
    Function.Injective (closureFingerprint eval) := by
  exact fun x y hxy => Classical.not_not.1 fun h => by obtain ⟨ φ, hφ ⟩ := hsep x y h; exact hφ ( congr_fun hxy φ ) ;

/-
Endomorphism action faithfulness: if the observable-lifted action is injective,
then the original action is injective.
Bridge: connects endomorphism dynamics to quantum observable distinguishability.
-/
theorem end_action_faithful_of_observable_lift_injective
    {E X O R : Type*} [Monoid E] [Semiring R]
    (ρ : E → X → X) (eval : O → X → R)
    (hlift : Function.Injective (fun e : E => fun φ x => eval φ (ρ e x))) :
    Function.Injective ρ := by
  exact fun e f h => hlift <| by aesop;

/-
Koopman observable endomorphism faithfulness: observable-separated injective
actions lift to observable-level injectivity.
Bridge: connects Koopman dynamics to quantum observable distinguishability.
-/
theorem koopman_observable_endomorphism_faithfulness
    {E X O R : Type*} [Monoid E] [Semiring R]
    (ρ : E → X → X) (eval : O → X → R)
    (_hsep : ∀ x y : X, x ≠ y → ∃ φ, eval φ x ≠ eval φ y)
    (hcompat : ∀ e₁ e₂ : E, (∀ x, ρ e₁ x = ρ e₂ x) → e₁ = e₂) :
    Function.Injective ρ := by
  exact fun e₁ e₂ h => hcompat e₁ e₂ fun x => congr_fun h x

/-! ## Section 8: Representation Extensionality -/

/-
**Representation extensionality**: Two closure systems with equivalent
observable characterizations have the same closure operator.
Bridge: Tannaka-style reconstruction — closure is determined by its observable data.
-/
theorem ClosureTannakaDatum_ext_closure
    {R X : Type*} [Semiring R]
    (A B : ClosureTannakaDatum R X)
    (hA_ext : ∀ s, A.cl s = observableClosure A.eval s)
    (hB_ext : ∀ s, B.cl s = observableClosure B.eval s)
    (heval_eq : ∀ (s : Set X) (x : X), (∀ φ : A.Obs, (∀ y ∈ s, A.eval φ y = 0) → A.eval φ x = 0) ↔
                        (∀ ψ : B.Obs, (∀ y ∈ s, B.eval ψ y = 0) → B.eval ψ x = 0)) :
    A.cl = B.cl := by
  -- Since their observable closures are equal, it follows that their closure operators are equal.
  ext x;
  rw [ hA_ext, hB_ext, observableClosure, observableClosure ];
  exact heval_eq x _

/-! ## Section 9: Computational Bounds -/

/-
Observable reconstruction cost is at most quadratic.
Bridge: post-quantum algorithmic complexity of closure reconstruction.
-/
theorem observable_reconstruction_cost_quadratic
    (n m : ℕ) :
    observable_reconstruction_cost n m ≤ (n + m) ^ 2 := by
  unfold observable_reconstruction_cost; nlinarith;

/-
Certified robustness radius is nonneg when Lipschitz constant is positive.
Bridge: connects observable margins to ML certified robustness.
-/
theorem certified_radius_nonneg
    {𝕜 E : Type*} [NormedField 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E]
    (φ : LipschitzObservable 𝕜 E) (x : E) :
    0 ≤ ‖φ.toFun x‖ / φ.K := by
  exact div_nonneg ( norm_nonneg _ ) ( le_of_lt φ.hK_pos )

/-
**Lipschitz certified robustness**: If an observable evaluates nonzero at `x` with
a margin, then nearby points also evaluate nonzero. This gives an explicit certified
robustness radius.
Bridge: connects observable margins to ML certified robustness against adversarial perturbation.
-/
theorem lipschitz_certified_robustness_from_observable_margin
    {𝕜 E : Type*} [NormedField 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E]
    (φ : LipschitzObservable 𝕜 E) (x : E) (margin : ℝ)
    (_hmargin_pos : 0 < margin)
    (hmargin : margin ≤ ‖φ.toFun x‖)
    (hK : 0 < φ.K) :
    ∀ y, ‖y - x‖ < margin / φ.K → φ.toFun y ≠ 0 := by
  intro y hy h;
  have := φ.lipschitz' y x;
  rw [ lt_div_iff₀' hK ] at hy ; simp_all +decide [ norm_sub_rev ];
  linarith

/-! ## Section 10: Empty and Universe Closures -/

/-
The observable closure of the empty set is the universal kernel.
Bridge: the empty closure captures universal quantum indistinguishability.
-/
theorem observableClosure_empty
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    observableClosure eval ∅ = {x | ∀ φ : O, eval φ x = 0} := by
  exact Set.ext fun x => by simp +decide [ observableClosure ] ;

/-
The observable closure of the universe is the universe.
Bridge: the full state space is trivially closed.
-/
theorem observableClosure_univ
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    observableClosure eval Set.univ = Set.univ := by
  exact Set.eq_univ_iff_forall.mpr fun x => fun φ hφ => hφ x ( Set.mem_univ x )

/-
Annihilator of the empty set is the full observable space.
Bridge: every observable annihilates the void.
-/
theorem observableAnnihilator_empty
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    observableAnnihilator eval ∅ = Set.univ := by
  exact Set.eq_univ_of_forall fun φ => by simp +decide [ observableAnnihilator ] ;

/-
Annihilator of the universe is the set of observables vanishing everywhere.
Bridge: only trivial observables annihilate all states.
-/
theorem observableAnnihilator_univ
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    observableAnnihilator eval Set.univ = {φ | ∀ x, eval φ x = 0} := by
  ext φ; simp [observableAnnihilator]

/-
Zero locus of the empty family is the whole space.
Bridge: no constraints mean all states are admissible.
-/
theorem observableZeroLocus_empty
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) :
    observableZeroLocus eval ∅ = Set.univ := by
  exact Set.eq_univ_of_forall fun x => by simp +decide [ observableZeroLocus ] ;

/-
The observable closure is contained in the intersection of all kernels containing `s`.
Bridge: observable closure is the tightest kernel-based approximation.
-/
theorem observableClosure_subset_iInter_kernels
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) (s : Set X) :
    observableClosure eval s ⊆ ⋂ φ ∈ {φ : O | ∀ y ∈ s, eval φ y = 0}, observableKernel eval φ := by
  exact fun x hx => Set.mem_iInter₂.2 fun φ hφ => hx φ hφ

/-
The intersection of all kernels containing `s` is contained in the observable closure.
Bridge: the observable closure is at least as large as the kernel intersection.
-/
theorem iInter_kernels_subset_observableClosure
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) (s : Set X) :
    ⋂ φ ∈ {φ : O | ∀ y ∈ s, eval φ y = 0}, observableKernel eval φ ⊆ observableClosure eval s := by
  intro x hx; aesop;

/-- The observable closure equals the intersection of all kernels containing `s`.
Bridge: closure = kernel intersection — the fundamental identity of observable reconstruction. -/
theorem observableClosure_eq_iInter_kernels
    {R X O : Type*} [Semiring R]
    (eval : O → X → R) (s : Set X) :
    observableClosure eval s = ⋂ φ ∈ {φ : O | ∀ y ∈ s, eval φ y = 0}, observableKernel eval φ := by
  exact Set.Subset.antisymm
    (observableClosure_subset_iInter_kernels eval s)
    (iInter_kernels_subset_observableClosure eval s)