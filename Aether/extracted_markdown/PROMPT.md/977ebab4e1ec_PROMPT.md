## Assignment: Algebra–EML–Cryptography Closure Secret-Sharing Duality via Idempotent Access Semimodules and Certified Minimal Monotone Span Reconstruction

**Mode:** prove

Build a new bridge, not a variant: secret-sharing access structures as **closure semantics** and as **idempotent semimodule reachability**, with a certified minimal reconstruction object extracted from the closure itself. The target is a theorem family that turns finite EML closure systems into idealized cryptographic access structures and back, with a canonical minimal witness of reconstruction. This is not the extractor/syndrome/one-way story; it is a new algebraic semantics for authorization.

### Why this is a breakthrough
If you can certify that finite accessible closure operators are *exactly* the same data as finite monotone access structures realizable by idempotent semimodules, then closure theory becomes a semantic language for secret-sharing, while cryptographic reconstruction becomes an algebraic minimality problem in tropical/idempotent linear algebra. That opens:

- a semantics-first theory of authorization,
- a tropical/EML replacement for classical monotone span program realization,
- canonical minimal reconstruction certificates,
- algorithmic extraction of authorized bases from closure data,
- a path toward complexity-theoretic lower bounds via closure rank, semimodule dimension, and hypergraph certificates.

This would create a field-opening interface between:
- **closure systems / finite lattices,**
- **idempotent algebra / tropical semimodules,**
- **secret-sharing / monotone span programs,**
- **hypergraph reconstruction / Tanner-style incidence certificates,**
- **certified algorithm extraction in Lean.**

---

## Precise theorem targets

Work in:

`Bridges/AlgebraEMLCryptography/ClosureSecretSharingDuality.lean`

and build explicitly on:

- `finite_access_structure_has_closure_capacity_realization`
  from `Bridges/AlgebraEMLCryptography/ClosureCapacitySecretSharingDuality.lean`
- `certified_gibbs_reconstruction_from_boundary_partition`
  (use its certified minimal reconstruction pattern, even if the object type differs)

You should introduce a finite-access closure package and an idempotent access semimodule package, then prove a realization/minimality duality.

---

## Core mathematical definitions to formalize

Let `X` be a finite type of participants.

Let `cl : Set X → Set X` satisfy `IsClosureOperator cl`.

Let `t : X` be a distinguished secret generator, or more generally let the closure act on a finite ambient type `Y` containing participant generators and a secret element `t : Y`.

Define the induced access structure:
\[
\mathcal A_t(cl) := \{ S \subseteq X \mid t \in cl(\iota(S)) \},
\]
where `ι : X → Y` is the participant embedding if needed.

You should define:

1. **Finite accessible closure access profile**
   - monotone authorization,
   - upward closure,
   - finite accessibility / basis property:
     every authorized coalition contains a minimal authorized subcoalition.

2. **IdempotentAccessSemimodule**
   over an idempotent semiring `R` and semimodule `M`, with:
   - participant labeling `ρ : X → M`,
   - secret target `t : M`,
   - authorization of `S` witnessed by existence of a finite idempotent linear combination of `ρ(x)` for `x ∈ S` dominating/reaching `t`.

3. **Minimal reconstruction certificate**
   as one of:
   - minimal support witness,
   - monotone span certificate,
   - hypergraph/Tanner incidence reconstruction object,
   together with correctness and minimality theorems.

The key idea: in the idempotent setting, “reconstruction” is reachability/domination in the semimodule order, and minimal authorized coalitions become minimal supports of semimodule witnesses.

---

## Main theorem family

### Theorem A: Closure-to-access monotonicity and finite basis

For finite accessible closure operators, the induced authorization family is an upward-closed finite access structure with a minimal authorized basis.

Suggested Lean target:

```lean
theorem closure_access_is_finite_access_structure
  {X Y : Type*} [Fintype X] [DecidableEq X] [DecidableEq Y]
  (ι : X → Y) (t : Y) (cl : Set Y → Set Y)
  (hcl : IsClosureOperator cl)
  (hfinacc : ∀ A : Set X, t ∈ cl (ι '' A) →
    ∃ B : Finset X, (↑B : Set X) ⊆ A ∧ t ∈ cl (ι '' (↑B : Set X)))
  :
  IsUpwardClosed
    {A : Set X | t ∈ cl (ι '' A)}
  ∧
  ∀ A : Set X, t ∈ cl (ι '' A) →
    ∃ B : Finset X,
      (↑B : Set X) ⊆ A ∧
      t ∈ cl (ι '' (↑B : Set X)) ∧
      ∀ C : Finset X, (↑C : Set X) ⊆ (↑B : Set X) →
        t ∈ cl (ι '' (↑C : Set X)) → C = B
```

This theorem says the closure semantics already gives a finite idealized access structure with certified minimal witnesses.

---

### Theorem B: Realization theorem — finite accessible closure profiles are exactly idempotent semimodule access structures

This is the central breakthrough statement.

Mathematically:

> For every finite closure operator `cl` with monotone extensivity, intersection stability, and finite accessibility, the induced access profile is representable by an idempotent access semimodule. Conversely, every finite idealized idempotent access semimodule induces a closure operator whose authorized coalitions are exactly the coalitions reconstructing the secret.

Suggested Lean formulation in two halves.

#### B1. Closure realizes an idempotent access semimodule

```lean
theorem finite_accessible_closure_has_idempotent_semimodule_realization
  {X Y : Type*} [Fintype X] [DecidableEq X] [DecidableEq Y]
  (ι : X → Y) (t : Y) (cl : Set Y → Set Y)
  (hcl : IsClosureOperator cl)
  (hinter : ∀ A B : Set Y, cl (A ∩ B) = cl A ∩ cl B)
  (hfinacc : ∀ A : Set X, t ∈ cl (ι '' A) →
    ∃ B : Finset X, (↑B : Set X) ⊆ A ∧ t ∈ cl (ι '' (↑B : Set X)))
  :
  ∃ (R : Type*) (_ : IdempotentSemiring R)
    (M : Type*) (_ : AddCommMonoid M) (_ : Module R M)
    (S : IdempotentAccessSemimodule R M X),
    ∀ A : Set X,
      (t ∈ cl (ι '' A)) ↔ S.Authorized A
```

You may need to replace `Module` by a custom semimodule class already present or easier to define over idempotent semirings.

#### B2. Every finite idempotent access semimodule induces a closure operator

```lean
theorem idempotent_access_semimodule_induces_closure
  {R M X : Type*}
  [Fintype X] [DecidableEq X]
  [IdempotentSemiring R] [AddCommMonoid M] [Module R M]
  (S : IdempotentAccessSemimodule R M X) :
  ∃ cl : Set X → Set X,
    IsClosureOperator cl ∧
    ∀ A : Set X, S.Authorized A ↔ S.secret ∈ cl A
```

If the codomain of `cl` should be `Set M` or `Set (X ⊕ Unit)` rather than `Set X`, do that. What matters is exact authorization equivalence.

---

### Theorem C: Certified minimal monotone span / Tanner-style reconstruction

This theorem should extract from the closure or semimodule realization a **minimal reconstruction object**, prove it reconstructs exactly the authorized coalitions, and prove minimality/canonicity.

A strong target is:

```lean
theorem exists_certified_minimal_reconstruction
  {X Y : Type*} [Fintype X] [DecidableEq X] [DecidableEq Y]
  (ι : X → Y) (t : Y) (cl : Set Y → Set Y)
  (hcl : IsClosureOperator cl)
  (hfinacc : ∀ A : Set X, t ∈ cl (ι '' A) →
    ∃ B : Finset X, (↑B : Set X) ⊆ A ∧ t ∈ cl (ι '' (↑B : Set X)))
  :
  ∃ C : MinimalReconstructionCertificate X,
    (∀ A : Set X, C.Reconstructs A ↔ t ∈ cl (ι '' A)) ∧
    C.CertifiedMinimal ∧
    C.CanonicalUpToIso
```

If `CanonicalUpToIso` is too ambitious initially, prove:
- existence,
- correctness,
- support-minimality,
- uniqueness of the family of minimal authorized sets.

A more concrete theorem would identify the certificate with the antichain of minimal authorized coalitions:

```lean
theorem minimal_authorized_basis_exists_unique
  {X Y : Type*} [Fintype X] [DecidableEq X] [DecidableEq Y]
  (ι : X → Y) (t : Y) (cl : Set Y → Set Y)
  (hcl : IsClosureOperator cl)
  (hfinacc : ∀ A : Set X, t ∈ cl (ι '' A) →
    ∃ B : Finset X, (↑B : Set X) ⊆ A ∧ t ∈ cl (ι '' (↑B : Set X)))
  :
  ∃! B : Finset (Finset X),
    (∀ U : Finset X, U ∈ B ↔
      t ∈ cl (ι '' (↑U : Set X)) ∧
      ∀ V : Finset X, (↑V : Set X) ⊂ (↑U : Set X) →
        t ∉ cl (ι '' (↑V : Set X))) ∧
    ∀ A : Set X, t ∈ cl (ι '' A) ↔
      ∃ U ∈ B, (↑U : Set X) ⊆ A
```

This is already a major theorem: the closure profile is represented by a unique antichain basis, and that basis is a certified minimal monotone reconstruction object.

---

## Recommended proof architecture

### Strategy 1: Antichain basis first, semimodule realization second
**Most promising.**

1. **Extract the minimal authorized basis from finite accessibility.**
   - Prove authorization is upward closed using monotonicity of `cl`.
   - On a finite type, use finite accessibility plus well-foundedness of strict subset on finite sets to obtain minimal authorized coalitions.
   - Show the family of minimal authorized coalitions is an antichain and generates all authorized coalitions by upward closure.

2. **Build an idempotent semimodule from the antichain basis.**
   - Use a free idempotent semimodule on the set of basis certificates or authorized atoms.
   - Map each participant `x` to the join/sum of basis atoms containing `x`.
   - Let the secret target `t` be the join of all basis atoms.
   - Show a coalition authorizes iff its generated element dominates `t`, equivalently iff it contains some minimal authorized coalition.

3. **Certify minimality and uniqueness.**
   - Minimal supports in the semimodule correspond exactly to minimal authorized coalitions.
   - The antichain basis is unique because minimal elements of an upward-closed family are unique as a set.
   - Package this as `MinimalReconstructionCertificate`.

Why this is strongest: it reduces the deep theorem to finite order theory plus a canonical free construction. It is likely easiest to formalize and gives the cleanest canonicity result.

---

### Strategy 2: Closure lattice / Moore family route
1. View closed sets as a finite Moore family.
2. Define authorization through the principal upset determined by `t`.
3. Use Birkhoff-style finite representation heuristics: finite closure systems correspond to meet-subsemilattices of powersets.
4. Realize authorization by generators in an idempotent semimodule of indicator vectors / tropical incidence profiles.
5. Extract minimal reconstruction from join-irreducibles or meet-prime cuts.

Why it is interesting: it connects to lattice theory and may give stronger structural invariants such as “closure rank” or canonical dimension.  
Why it is less immediate: more abstraction overhead in Lean.

---

### Strategy 3: Hypergraph/Tanner incidence certificate route
1. Define the hypergraph whose edges are minimal authorized coalitions.
2. Show authorization is exactly hyperedge containment.
3. Build a Tanner-style reconstruction object from the incidence matrix of this hypergraph.
4. Interpret the incidence object as an idempotent monotone span program.
5. Prove minimality via irredundancy of hyperedges.

Why it matters: this gives a combinatorial certificate with direct cryptographic meaning.  
Why it is useful: it interfaces naturally with coding theory and monotone span programs.  
Why it may be best as a second layer: hypergraph extraction is easiest after the antichain basis theorem is already proved.

---

## How to build on the catalog theorems

### 1. Use `finite_access_structure_has_closure_capacity_realization`
Do not merely cite it. Use it as a transfer principle:

- It already says finite access structures admit a closure/capacity style realization.
- Your theorem should **upgrade** this from capacity-style realization to **idempotent semimodule realization with minimal reconstruction certificate**.
- Concretely:
  - first derive the finite access structure from `cl`,
  - then compare your semimodule realization against the existing capacity realization,
  - prove that your realization preserves the same authorized family,
  - use this to justify that the semimodule model is not ad hoc but canonically aligned with the previously verified closure-capacity semantics.

A valuable intermediate theorem would be:

```lean
theorem closure_capacity_and_idempotent_realizations_agree_on_authorization
  ...
  : ∀ A : Set X, CapacityAuthorized A ↔ SemimoduleAuthorized A
```

This theorem is conceptually important: it says the new semimodule realization is the algebraic shadow of the earlier closure-capacity realization.

### 2. Use `certified_gibbs_reconstruction_from_boundary_partition`
The object is different, but the pattern is gold:
- certified reconstruction object,
- correctness theorem,
- minimality theorem,
- potentially canonicality up to equivalence.

Imitate that architecture:
- define a reconstruction certificate datatype,
- produce it algorithmically from finite closure data,
- prove `sound`,
- prove `complete`,
- prove `minimal`.

This should give a reusable theorem schema for future cryptographic reconstruction objects in the catalog.

---

## Concrete intermediate lemmas worth proving

These will likely be the engine room.

```lean
theorem closure_access_upward_closed
  {X Y : Type*} [DecidableEq X]
  (ι : X → Y) (t : Y) (cl : Set Y → Set Y)
  (hcl : IsClosureOperator cl) :
  IsUpwardClosed {A : Set X | t ∈ cl (ι '' A)}
```

```lean
theorem finite_authorized_set_contains_minimal_authorized_subset
  {X Y : Type*} [Fintype X] [DecidableEq X] [DecidableEq Y]
  (ι : X → Y) (t : Y) (cl : Set Y → Set Y)
  (hcl : IsClosureOperator cl)
  (hfinacc : ...)
  :
  ∀ A : Set X, t ∈ cl (ι '' A) →
    ∃ B : Finset X,
      (↑B : Set X) ⊆ A ∧
      t ∈ cl (ι '' (↑B : Set X)) ∧
      ∀ C : Finset X, (↑C : Set X) ⊂ (↑B : Set X) →
        t ∉ cl (ι '' (↑C : Set X))
```

```lean
theorem authorized_iff_contains_minimal_basis_member
  {X Y : Type*} [Fintype X] [DecidableEq X] [DecidableEq Y]
  ...
  :
  ∀ A : Set X, t ∈ cl (ι '' A) ↔
    ∃ B ∈ minimalAuthorizedBasis ι t cl, (↑B : Set X) ⊆ A
```

```lean
theorem free_idempotent_semimodule_realizes_basis
  {X : Type*} [Fintype X] [DecidableEq X]
  (B : Finset (Finset X)) :
  ∃ (R : Type*) (_ : IdempotentSemiring R)
    (M : Type*) (_ : AddCommMonoid M) (_ : Module R M)
    (S : IdempotentAccessSemimodule R M X),
    ∀ A : Set X,
      S.Authorized A ↔ ∃ U ∈ B, (↑U : Set X) ⊆ A
```

```lean
theorem minimal_supports_correspond_to_minimal_authorized_coalitions
  ...
  :
  SupportMinimalInSemimodule ↔ SetMinimalAuthorized
```

These are not just helper lemmas—they are the modular skeleton of the field.

---

## Cross-domain connections to exploit

### 1. Monotone span programs and secret-sharing
Your idempotent semimodule realization should be framed as a tropical/idempotent analogue of monotone span programs:
- classical MSP: linear reconstruction over fields,
- your setting: idempotent linear reconstruction via domination/join reachability,
- minimal supports become authorized basis elements.

If you can formalize this analogy, you open a route to tropical lower bounds for secret-sharing complexity.

### 2. Hypergraphs and Tanner-style reconstruction
Minimal authorized coalitions form a hypergraph:
- vertices = participants,
- hyperedges = minimal authorized sets,
- authorization = containment of a hyperedge.

This turns closure semantics into a hypergraph semantics and the certificate into an incidence object. This is ideal for extraction, algorithmics, and future coding-theoretic interpretations.

### 3. Lattice theory / formal concept analysis
Closed sets of a closure operator form a Moore family; minimal authorization relative to `t` is a principal region in that lattice. This suggests:
- closure dimension,
- join-irreducible decomposition,
- concept lattice semantics for secret-sharing roles.

This could become a new semantics for role-based cryptography.

### 4. Tropical geometry / idempotent algebra
If authorization is reachability under idempotent combinations, then access structures become tropical convexity shadows. This is a radical viewpoint:
- secret reconstruction as tropical dominance,
- minimal coalitions as extreme generators,
- canonical certificate as a tropical convex hull basis.

### 5. Complexity theory
Once minimal authorized bases are canonical and certified, you can define:
- closure rank,
- semimodule realization dimension,
- reconstruction support complexity,
- hypergraph width invariants.

These are candidate lower-bound measures for secret-sharing complexity.

---

## Lean 4 implementation guidance

Define small, reusable structures. For example:

```lean
structure IdempotentAccessSemimodule
  (R M X : Type*) [IdempotentSemiring R] [AddCommMonoid M] [Module R M] where
  share    : X → M
  secret   : M
  Authorized : Set X → Prop
  auth_iff_reaches :
    ∀ A : Set X,
      Authorized A ↔
      ∃ w : X →₀ R,
        (∀ x, w x ≠ 0 → x ∈ A) ∧
        secret ≤ finsuppLinearCombination w share
```

If order on `M` is inconvenient, define a reachability predicate primitive and axiomatize enough to prove monotonicity.

For the certificate:

```lean
structure MinimalReconstructionCertificate (X : Type*) [DecidableEq X] where
  basis : Finset (Finset X)
  antichain :
    ∀ U ∈ basis, ∀ V ∈ basis, (↑U : Set X) ⊆ (↑V : Set X) → U = V
  Reconstructs : Set X → Prop
  reconstructs_iff :
    ∀ A : Set X, Reconstructs A ↔ ∃ U ∈ basis, (↑U : Set X) ⊆ A
  CertifiedMinimal :
    ∀ U ∈ basis, ∀ V : Finset X, (↑V : Set X) ⊂ (↑U : Set X) → ¬ Reconstructs (↑V : Set X)
  CanonicalUpToIso : Prop
```

You can postpone a sophisticated `CanonicalUpToIso` and initially define it as extensional uniqueness of `basis`.

---

## What would count as a genuinely strong final theorem

The strongest version would say:

> The category of finite accessible closure access profiles is equivalent to the category of finite upward-closed access structures with unique minimal antichain bases, and every object in this category admits a canonical idempotent semimodule realization whose minimal supports are exactly the basis elements.

Even if you do not package the categorical equivalence fully, proving the object-level equivalence with canonical reconstruction is already paradigm-shifting.

---

## Minimal acceptable theorem package

If time forces prioritization, prove in this order:

1. `closure_access_is_finite_access_structure`
2. `minimal_authorized_basis_exists_unique`
3. `free_idempotent_semimodule_realizes_basis`
4. `finite_accessible_closure_has_idempotent_semimodule_realization`
5. `exists_certified_minimal_reconstruction`

That sequence is coherent, publishable, and expandable.

---

## Application keywords
closure operator semantics; secret-sharing; access structures; monotone span programs; idempotent semimodules; tropical linear algebra; minimal authorized coalitions; hypergraph reconstruction; Tanner certificates; finite Moore families; formal cryptography; certified reconstruction; canonical antichain basis; closure rank; reconstruction complexity

---

## Deliverables
1. The Lean file:
   - `Bridges/AlgebraEMLCryptography/ClosureSecretSharingDuality.lean`

2. A theorem chain with minimized sorry count, prioritizing the five theorems above.

3. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough next steps**, for example:
   - lower bounds via semimodule dimension,
   - tropical monotone span complexity,
   - role-hierarchy closure semantics,
   - probabilistic/weighted access via valuation semirings,
   - categorical equivalence between closure profiles and reconstruction certificates.

Do not make `FUTURE_DIRECTIONS.md` generic; make it operational and theorem-grade.

### Catalog Reference Files
@Bridges/AlgebraEMLTropical/PadicClosureInformationDuality.lean
```lean
/-
# Non-Archimedean Information Duality via p-adic Closure Capacities and Min-Plus Rate Functions

This file formalizes a duality between closure-stable ultrametric capacities on finite
closure lattices and tropical min-plus information functionals. The valuation scale
is `WithTop ℕ` (equivalently `ℕ∞`), capturing the essential non-Archimedean structure:
`0` = trivial (empty set), finite values = finite information cost, `⊤` = impossible.

## Main Results (all sorry-free)

- `closureCapacity_tropicalizes` — Every closure capacity yields tropical info.
- `tropicalization_canonical_on_closure_classes` — Constant on closure classes.
- `closureCapacity_residuated_of_fintype` — Residuation automatic from finiteness.
- `tropicalInformation_reconstructs_unique_capacity` — Unique reconstruction.
- `capacity_info_equiv` — Type equivalence ClosureCapacity ≃ TropicalClosureInformation.
- `closureMorphism_information_contraction` — Data processing inequality.
- `ultrametricInfoDist_triangle` — Ultrametric triangle inequality for info distance.
- `closure_class_iInf_eq` — Infimum over closure class is attained.
- `isClosureMorphism_comp` — Closure morphisms compose.
- `pullback_comp_eq` — Pullback is functorial.
- `ultrametric_ternary_join` — Three-way ultrametric bound.

## Bridges

- **Algebra ↔ Information Theory**: Ultrametric capacities ↔ tropical information
- **Valuation Theory ↔ Optimization**: p-adic valuations ↔ min-plus shortest paths
- **EML Semantics ↔ Tropical Geometry**: Closure lattices ↔ idempotent semimodules
- **Category Theory ↔ Data Processing**: Closure morphisms ↔ information contraction
-/

import Mathlib

open Set Classical

noncomputable section

namespace Bridges.AlgebraEMLTropical.PadicClosureInformationDuality

/-! ## §1. Closure Operator Axiomatics -/

/-- A closure operator on `Set α`: monotone, extensive, idempotent. -/
structure IsClosureOperator {α : Type*} (cl : Set α → Set α) : Prop where
  idempotent : ∀ s, cl (cl s) = cl s
  monotone : ∀ ⦃s t : Set α⦄, s ⊆ t → cl s ⊆ cl t
  extensive : ∀ s, s ⊆ cl s

/-- The subtype of closed sets under a closure operator. -/
def ClosedSets {α : Type*} (cl : Set α → Set α) := {s : Set α // cl s = s}

/-! ## §2. Closure Capacity

A normalized, monotone, closure-invariant function from sets to the tropical
valuation scale `WithTop ℕ`, satisfying the ultrametric join inequality. -/

structure ClosureCapacity
    (α : Type*) [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) : Type _ where
  toFun : Set α → WithTop ℕ
  closed_invariant : ∀ s : Set α, toFun (cl s) = toFun s
  monotone : ∀ ⦃s t : Set α⦄, s ⊆ t → toFun s ≤ toFun t
  normalized_bot : toFun ∅ = 0
  ultrametric_join :
    ∀ s t : Set α, toFun (cl (s ∪ t)) ≤ max (toFun s) (toFun t)

@[ext]
theorem ClosureCapacity.ext' {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {v w : ClosureCapacity α cl}
    (h : v.toFun = w.toFun) : v = w := by
  cases v; cases w; congr

/-! ## §3. Tropical Closure Information

Extends ClosureCapacity with residuation: every closure class has a least-cost
representative. -/

structure TropicalClosureInformation
    (α : Type*) [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) : Type _ where
  toFun : Set α → WithTop ℕ
  closed_invariant : ∀ s, toFun (cl s) = toFun s
  monotone : ∀ ⦃s t : Set α⦄, s ⊆ t → toFun s ≤ toFun t
  normalized_bot : toFun ∅ = 0
  ultrametric_join :
    ∀ s t, toFun (cl (s ∪ t)) ≤ max (toFun s) (toFun t)
  residuated :
    ∀ s, ∃ t, cl t = cl s ∧ ∀ u, cl u = cl s → toFun t ≤ toFun u

@[ext]
theorem TropicalClosureInformation.ext' {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {v w : TropicalClosureInformation α cl}
    (h : v.toFun = w.toFun) : v = w := by
  cases v; cases w; congr

/-! ## §4. Closure Morphisms -/

/-- `f : α → β` is a closure morphism if `f '' (clα s) ⊆ clβ (f '' s)`. -/
def IsClosureMorphism
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (clα : Set α → Set α) (clβ : Set β → Set β) (f : α → β) : Prop :=
  ∀ s : Set α, f '' (clα s) ⊆ clβ (f '' s)

/-! ## §5. Decomposition Cost -/

/-- Infimum of `I t` over all `t` with `cl t = cl s`. -/
def DecompCost {α : Type*} [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) (I : Set α → WithTop ℕ) (s : Set α) : WithTop ℕ :=
  ⨅ (t : Set α) (_ : cl t = cl s), I t

/-! ## §6. Unit-Shift Equivalence -/

/-- Two functions differ by a global additive constant. -/
def EquivalentUpToUnitShift {α : Type*}
    (f g : Set α → WithTop ℕ) : Prop :=
  ∃ c : ℕ, ∀ s, g s = f s + ↑c

/-! ## §7. Theorem A: Tropicalization -/

/-- **Theorem A**: Every closure capacity IS a tropical information functional. -/
theorem closureCapacity_tropicalizes
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (_hcl : IsClosureOperator cl)
    (v : ClosureCapacity α cl) :
    ∃ I : Set α → WithTop ℕ,
      (∀ s, I (cl s) = I s) ∧
      (∀ ⦃s t : Set α⦄, s ⊆ t → I s ≤ I t) ∧
      (∀ s t, I (cl (s ∪ t)) ≤ max (I s) (I t)) ∧
      I ∅ = 0 :=
  ⟨v.toFun, v.closed_invariant, v.monotone, v.ultrametric_join, v.normalized_bot⟩

/-! ## §8. Closure Class Invariance -/

/-- A closure capacity is constant on closure classes. Generalizes
`quantum_thermodynamic_certified_capacity_invariant_under_closure_equiv`. -/
theorem tropicalization_canonical_on_closure_classes
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) :
    ∀ s t : Set α, cl s = cl t → v.toFun s = v.toFun t := by
  intro s t h
  calc v.toFun s = v.toFun (cl s) := (v.closed_invariant s).symm
    _ = v.toFun (cl t) := by rw [h]
    _ = v.toFun t := v.closed_invariant t

/-! ## §9. Residuation from Finiteness -/

/-- On a finite type, every closure capacity satisfies residuation automatically. -/
theorem closureCapacity_residuated_of_fintype
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
-- ... (truncated, full file has 493 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py, diagram.svg

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Structure it with specific theorem statements, proof strategies, and
            cross-domain connections.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
