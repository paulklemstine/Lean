## Assignment: Algebra–EML–Logic Closure Stone Spectrum Duality via Idempotent Theory Semimodules and Certified Finite Lindenbaum Reconstruction

**Mode:** `prove`

Prove a genuinely new finite duality theorem at the interface of algebra, EML, finite model logic, and spectral semantics. This is not a variant of generic closure reconstruction: the target is a **finite Stone/Lindenbaum spectral duality theorem with certified bidirectional reconstruction**, where the algebraic object is an idempotent theory semimodule of closure-valuations and the topological/logical object is the finite spectrum of prime closed theories.

Build explicitly on closure and algebraic infrastructure already present in the catalog, especially the closure-operator and duality patterns from `Bridges/AlgebraEMLTropical/PadicClosureInformationDuality` and any existing finite closure-lattice lemmas. Minimize `sorry`. If a prerequisite lemma is missing, isolate it as a reusable finite lattice/closure lemma rather than burying it inside the main proof.

---

## Breakthrough Objective

Establish that a finite logical consequence system can be recovered **canonically and algorithmically** from its semimodule of idempotent closure-valuations, and that the geometry of prime closed theories is not just representational but **computationally complete** for finite proof systems.

This would open a new bridge:
- from **closure logic** to **idempotent linear algebra**,
- from **finite Lindenbaum algebras** to **Stone/Priestley-style spectra**,
- from **semantic prime separation** to **certified proof compression**,
- and from **algebraic semantics** to **extractable reconstruction algorithms** in Lean.

If successful, this is the seed of a field: **idempotent spectral logic**, where consequence systems are analyzed via semimodule generators, prime spectra, and complexity invariants.

---

## Precise Mathematical Target

Let `Form σ` be a finite type of formulas over a finite signature `σ`. Let
`C : Set (Form σ) → Set (Form σ)` be a closure operator satisfying:

1. **Extensive:** `Γ ⊆ C Γ`
2. **Monotone:** `Γ ⊆ Δ → C Γ ⊆ C Δ`
3. **Idempotent:** `C (C Γ) = C Γ`

Let a **closed theory** be `T : Set (Form σ)` with `C T = T`.

Define the finite lattice of closed theories:
\[
\mathrm{Cl}(C) := \{ T \subseteq \mathrm{Form}(\sigma) \mid C(T)=T \}.
\]

Define a closed theory `P` to be **meet-prime** if for closed theories `A,B`,
\[
A \cap B \subseteq P \implies A \subseteq P \ \text{or}\ B \subseteq P.
\]
Equivalently in the finite lattice, `P` corresponds to a prime element of the opposite lattice; choose the formulation most compatible with Mathlib lattice APIs.

Define the **closure-Stone spectrum**
\[
\mathrm{Spec}_C := \{ P \in \mathrm{Cl}(C) \mid P \text{ is prime closed} \}
\]
with basic opens
\[
U_\varphi := \{ P \in \mathrm{Spec}_C \mid \varphi \notin P \}.
\]

Define the idempotent semiring `S` initially as `Bool` or `Fin 2`, and if the library permits, formulate the theorem over a finite idempotent commutative semiring `S` with order-compatible addition. Define the semimodule of closure-valuations `V_C` as the finitely generated `S`-semimodule of functions
\[
v : \mathrm{Form}(\sigma) \to S
\]
satisfying:
- closure invariance: `v` factors through closure equivalence / Lindenbaum classes,
- finite-support or finite-generation condition as appropriate,
- conjunction compatibility on the fragment formalized in the catalog:
  \[
  v(\varphi \wedge \psi)=v(\varphi)\otimes v(\psi),
  \]
- and indicator valuations from prime closed theories belong to `V_C`.

You should formalize the finite version in the strongest tractable form: if valuation-on-formulas is awkward, move to valuation-on-closed-theories or valuation-on-Lindenbaum classes, but preserve the theorem’s conceptual content.

---

## Main Theorem 1: Finite Closure–Spectrum Reconstruction Duality

### Mathematical statement

Assume:
- `Form σ` is finite,
- `C` is a finitary closure operator,
- the lattice of closed theories is finite,
- **compact generation**: every closed theory is the closure of a finite generator set,
- **prime separation**: for distinct closed theories `A ≠ B`, there exists a prime closed theory `P` separating them in the spectral sense,
- indicator valuations of prime closed theories generate `V_C`.

Then the closure system is recoverable from its valuation semimodule and spectrum:

1. The map sending a formula/theory to its evaluation profile on prime closed theories embeds the finite Lindenbaum algebra into the semimodule of indicator valuations.
2. The spectrum functor and valuation functor determine each other up to canonical equivalence.
3. There exist certified constructions
   - `reconstructSpectrum : ValuationSemimodule C → FiniteClosureSpectrum C`
   - `reconstructTheory : FiniteClosureSpectrum C → MinimalClosurePresentation C`
   such that the composites are canonically isomorphic to the originals.

### Lean-oriented theorem skeleton

You do not need to use these exact names, but aim for statements at this level of precision:

```lean
structure IsClosureOperator {α : Type _} (C : Set α → Set α) : Prop where
  extensive  : ∀ s, s ⊆ C s
  monotone   : Monotone C
  idempotent : ∀ s, C (C s) = C s

structure IsPrimeClosedTheory {α : Type _} (C : Set α → Set α) (P : Set α) : Prop where
  is_closed : C P = P
  prime_meet :
    ∀ ⦃A B : Set α⦄, C A = A → C B = B →
      A ∩ B ⊆ P → A ⊆ P ∨ B ⊆ P

structure FiniteClosureSpectrum (α : Type _) where
  carrier : Finset (Set α)
  isPrime : Set α → Prop
  basicOpen : α → Finset (Set α)
  basicOpen_spec :
    ∀ φ P, P ∈ basicOpen φ ↔ P ∈ carrier ∧ isPrime P ∧ φ ∉ P

structure MinimalClosurePresentation (α : Type _) where
  generators : Finset α
  entailment : Set α → Set α
  is_minimal : Prop

def closureValuationSemimodule
  (S : Type _) [Finite S] [CommSemiring S]
  [CanonicallyOrderedAddMonoid S] -- adjust if needed
  {α : Type _} (C : Set α → Set α) : Type _ := ...

def reconstructSpectrum
  {α S : Type _} [Fintype α] [Finite S] [CommSemiring S]
  (C : Set α → Set α) (V : closureValuationSemimodule S C) :
  FiniteClosureSpectrum α := ...

def reconstructTheory
  {α : Type _} [Fintype α]
  (X : FiniteClosureSpectrum α) :
  MinimalClosurePresentation α := ...
```

### Core equivalence theorem

```lean
theorem closure_spectrum_semimodule_duality
  {α S : Type _} [Fintype α] [DecidableEq α]
  [Finite S] [CommSemiring S]
  (C : Set α → Set α)
  (hC : IsClosureOperator C)
  (hfinite_closed : Finite {T : Set α // C T = T})
  (hcompact : CompactlyGeneratedClosure C)
  (hsep : PrimeSeparation C)
  (hgen : PrimeIndicatorGenerates S C) :
  Nonempty
    ((FiniteClosureSpectrum α) ≃
      SpectrumOfValuationSemimodule S C) ∧
  CanonicalReconstruction C S
    (reconstructSpectrum C (closureValuationSemimodule S C))
    (reconstructTheory
      (reconstructSpectrum C (closureValuationSemimodule S C)))
```

If the full equivalence type is too heavy, split it into:
- an embedding theorem,
- a surjectivity/reconstruction theorem,
- and a round-trip theorem.

---

## Main Theorem 2: Generator Rank = Number of Join-Irreducible Closed Theories

### Mathematical statement

Let `V_C` be the idempotent semimodule generated by prime-indicator valuations. Under the same hypotheses, the minimal number of semimodule generators of `V_C` equals the number of join-irreducible elements of the finite lattice of closed theories:
\[
\mathrm{genrank}(V_C)=\#\mathrm{JI}(\mathrm{Cl}(C)).
\]

This is the algebraic complexity invariant of the consequence system. It measures:
- minimal spectral data required to reconstruct the logic,
- minimal proof-compression basis,
- and intrinsic finite theory complexity.

### Lean-oriented signature

```lean
def joinIrreducibleClosedTheories
  {α : Type _} (C : Set α → Set α) : Finset (Set α) := ...

def semimoduleGeneratorRank
  {α S : Type _} [Fintype α] [Finite S] [CommSemiring S]
  (C : Set α → Set α) : Nat := ...

theorem generator_rank_eq_card_joinIrreducibles
  {α S : Type _} [Fintype α] [DecidableEq α]
  [Finite S] [CommSemiring S]
  (C : Set α → Set α)
  (hC : IsClosureOperator C)
  (hfinite_closed : Finite {T : Set α // C T = T})
  (hcompact : CompactlyGeneratedClosure C)
  (hsep : PrimeSeparation C)
  (hgen : PrimeIndicatorGenerates S C) :
  semimoduleGeneratorRank (S := S) C =
    (joinIrreducibleClosedTheories C).card
```

If exact equality of a preexisting notion of semimodule rank is too ambitious in current Mathlib, define a **certified constructive rank** as the cardinality of a minimal explicit generating family and prove equality with join-irreducibles.

---

## Most Promising Formalization Path

### Strategy A: Finite lattice duality first, semimodule second
This is likely the most promising path.

1. **Construct the finite lattice of closed theories**
   - Show closed theories under inclusion form a finite distributive lattice, or at least a finite meet-semilattice with enough joins induced by closure of unions.
   - Define join-irreducibles and prime closed theories internally.

2. **Apply finite Birkhoff/Priestley-style representation logic**
   - Prove that every closed theory is the intersection of prime closed theories containing it.
   - Use prime separation to embed the closure lattice into the powerset/topology of `Spec_C`.
   - This gives the spectral side with basic opens `U_φ`.

3. **Identify semimodule generators with prime indicators**
   - Define indicator valuations `1_{φ ∉ P}` or theory-indicators.
   - Show they separate Lindenbaum classes and generate the valuation semimodule.
   - Reconstruction then follows by reading off specialization/order/topology from these indicators.

Why this is promising: finite lattice arguments are robust in Lean, and the semimodule structure can be layered on top once the prime-spectrum representation is stable.

---

### Strategy B: Quotient by closure equivalence, then represent the finite Lindenbaum algebra
1. Define formula equivalence:
   \[
   \varphi \sim_C \psi \iff \varphi \in C(\{\psi\}) \land \psi \in C(\{\varphi\}).
   \]
   Or use a theory-based congruence if conjunction is available.

2. Build the finite Lindenbaum algebra of equivalence classes.
   - Show closure-valuations factor through this quotient.
   - Interpret `V_C` as semimodule of `S`-valued homomorphisms on the quotient algebra.

3. Recover prime theories as kernels / supports / prime points of valuations.
   - Reconstruct spectrum from extremal or indicator valuations.
   - Prove round-trip equivalence.

Why this is powerful: it makes the logic-algebra bridge explicit and gives a cleaner conceptual theorem. It is ideal if quotient support in Lean is manageable.

---

### Strategy C: Algorithm-first certified reconstruction
1. Define an explicit finite data structure for closure systems:
   - list of closed theories,
   - primality certificate,
   - basic open incidence matrix,
   - valuation incidence matrix.

2. Implement `reconstructSpectrum` by extracting prime-support patterns from generators of `V_C`.

3. Implement `reconstructTheory` by intersecting prime closed theories or recovering closure from spectral incidence:
   \[
   C(\Gamma)=\{ \varphi \mid \forall P \in \mathrm{Spec}_C,\ \Gamma \subseteq P \Rightarrow \varphi \in P \}.
   \]

Why this matters: this gives executable mathematics and can be used for certified minimization/proof compression. It is algorithmically strongest, but best pursued after Strategy A or B has supplied correctness lemmas.

---

## Key Intermediate Lemmas You Should Prove

These are likely the real engine of the development.

1. **Closed theories form a finite closure lattice**
```lean
theorem closed_theories_complete_lattice_finite
  {α : Type _} [Fintype α]
  (C : Set α → Set α) (hC : IsClosureOperator C) :
  Finite (ClosedTheories C)
```

2. **Join of closed theories is closure of union**
```lean
theorem sup_closed_eq_closure_union
  {α : Type _}
  (C : Set α → Set α) (hC : IsClosureOperator C)
  (A B : Set α) (hA : C A = A) (hB : C B = B) :
  closedSup C A B = C (A ∪ B)
```

3. **Prime representation / separation**
```lean
theorem closed_theory_eq_inter_prime_closed_over
  {α : Type _} [Fintype α] [DecidableEq α]
  (C : Set α → Set α)
  (hC : IsClosureOperator C)
  (hsep : PrimeSeparation C)
  {T : Set α} (hT : C T = T) :
  T =
    ⋂₀ {P | IsPrimeClosedTheory C P ∧ T ⊆ P}
```

4. **Indicator valuations separate non-equivalent formulas/theories**
```lean
theorem prime_indicator_separates
  {α S : Type _} [Fintype α] [DecidableEq α]
  [Finite S] [CommSemiring S]
  (C : Set α → Set α)
  (hsep : PrimeSeparation C) :
  SeparatesLindenbaumClasses (primeIndicatorValuations (S := S) C)
```

5. **Reconstruction by spectral entailment**
```lean
theorem reconstructTheory_correct
  {α : Type _} [Fintype α] [DecidableEq α]
  (C : Set α → Set α)
  (hC : IsClosureOperator C)
  (hsep : PrimeSeparation C) :
  reconstructClosureFromSpectrum (spectrumOf C) = C
```

6. **Generator rank equals join-irreducible count**
   First prove:
   - each join-irreducible closed theory yields an indispensable generator,
   - every generator family dominates one indexed by join-irreducibles.

---

## Certified Reconstruction Formula

A particularly important theorem to make executable is:

\[
\varphi \in C(\Gamma)
\iff
\forall P \in \mathrm{Spec}_C,\ \Gamma \subseteq P \Rightarrow \varphi \in P.
\]

This is the finite spectral completeness theorem for the closure system, and should become the correctness spec for `reconstructTheory`.

Lean target:

```lean
theorem mem_closure_iff_prime_closed_forall
  {α : Type _} [Fintype α] [DecidableEq α]
  (C : Set α → Set α)
  (hC : IsClosureOperator C)
  (hsep : PrimeSeparation C)
  (Γ : Set α) (φ : α) :
  φ ∈ C Γ ↔
    ∀ P, IsPrimeClosedTheory C P → Γ ⊆ P → φ ∈ P
```

This theorem is the hinge between logic, topology, and algorithmics.

---

## Cross-Domain Connections You Should Make Explicit in the Development

1. **Stone/Priestley duality**
   - Finite closure spectra are a logic-native analogue of finite Stone spaces / Priestley spaces.
   - The spectrum of prime closed theories should be understood as a semantic realization of the finite Lindenbaum algebra.

2. **Idempotent linear algebra / tropical semantics**
   - Indicator valuations over an idempotent semiring are tropical-style observables.
   - Generator rank is a tropical linear complexity invariant of a proof system.

3. **Abstract interpretation / static analysis**
   - Closure operators are abstract domains.
   - Prime closed theories correspond to extremal abstract states.
   - Reconstruction gives certified minimization of abstract domains.

4. **Formal concept analysis**
   - Closed theories are intents.
   - Prime closed theories and join-irreducibles correspond to canonical bases.
   - The reconstruction theorem is a logic-level Duquenne–Guigues-style phenomenon in spectral form.

5. **Finite model theory / proof complexity**
   - Minimal generator count measures compression of entailment structure.
   - This may become a certified invariant for finite proof search spaces.

6. **Algebraic semantics of logic**
   - This is a finite, constructive Lindenbaum–Stone duality inside Lean.
   - It suggests semiring-enriched semantics for nonclassical consequence systems.

---

## Implementation Guidance

Target file:
`Bridges/AlgebraEMLLogic/ClosureStoneSpectrumDuality.lean`

Potential supporting files if needed:
- `Bridges/AlgebraEMLLogic/FiniteClosureLattice.lean`
- `Bridges/AlgebraEMLLogic/PrimeClosedTheory.lean`
- `Bridges/AlgebraEMLLogic/ValuationSemimodule.lean`
- `Bridges/AlgebraEMLLogic/CertifiedTheoryReconstruction.lean`

Suggested structure:
1. Basic closure operator API specialized to finite formula universes.
2. Closed theory lattice and finite order lemmas.
3. Prime closed theories and spectrum.
4. Indicator valuations and semimodule generation.
5. Spectral reconstruction theorem.
6. Generator-rank theorem.
7. Executable reconstruction definitions with correctness proofs.

Prefer finite combinatorial definitions over abstract category machinery unless the latter is already strongly supported in the catalog.

---

## Application Keywords

`finite Stone duality`, `Lindenbaum algebra`, `closure operator semantics`, `idempotent semimodule`, `tropical logic`, `prime closed theory`, `proof compression`, `theory minimization`, `formal concept analysis`, `abstract interpretation`, `finite spectral semantics`, `certified reconstruction`, `semiring-valued logic`, `join-irreducible complexity`, `Lean verified logic infrastructure`

---

## Deliverables

1. A Lean development proving the main duality/reconstruction theorem and the generator-rank theorem.
2. Certified definitions of:
   - `FiniteClosureSpectrum`
   - `closureValuationSemimodule`
   - `reconstructSpectrum`
   - `reconstructTheory`
3. At least one executable example on a tiny finite consequence system showing the round-trip reconstruction.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - extend from finite closure systems to spectral sober spaces of infinitary consequence,
   - enrich from `Bool` to tropical semirings with entropy-like weights,
   - connect generator rank to proof width/length lower bounds,
   - develop a semiring-enriched Priestley duality for substructural logics,
   - classify which abstract interpretation domains arise as closure-Stone spectra.

Be bold: the goal is to make finite logical consequence systems into first-class spectral-algebraic objects with executable semantics and certified minimal presentations.

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

@Speculative/AutoResearch/ClosureMatroidDuality.lean
```lean
/-
# Closure–Matroid Duality via Idempotent Dependency Presentations

This file formalizes the structural equivalence between finite exchange closure
systems and finitely generated dependency presentations. The core theorem shows
that on finite ground sets, exchange-closure systems are equivalent to dependency
presentations with basis-independent rank.

## Main results

* `ExchangeClosureSystem` — bundled closure operator with exchange property
* `DepPresentation` — finite dependency presentation with targeted dependencies
* `exchangeClosure_of_matroid` — Matroid → ExchangeClosureSystem
* `canonical_cl_eq` — round-trip closure recovery
* `canonical_dep_iff` — dependent sets match between representations
* `basis_card_eq` — basis independence of rank
* `exchangeRank_le_card` — rank bounded by cardinality
* `circuit_nonempty` — circuits are nonempty
* `cl_mem_flats`, `univ_mem_flats` — flat structure
-/

import Mathlib

set_option maxHeartbeats 800000
set_option linter.unusedSectionVars false

open Set Function Finset

universe u

/-! ## §1. Exchange Closure Systems -/

/-- A finite exchange closure system: a closure operator satisfying
extensivity, monotonicity, idempotence, and Steinitz–Mac Lane exchange. -/
structure ExchangeClosureSystem (X : Type u) [Fintype X] where
  cl : Set X → Set X
  extensive : ∀ A, A ⊆ cl A
  mono : ∀ ⦃A B : Set X⦄, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A, cl (cl A) = cl A
  exchange : ∀ ⦃A : Set X⦄ ⦃x y : X⦄,
    y ∈ cl (A ∪ {x}) → y ∉ cl A → x ∈ cl (A ∪ {y})

namespace ExchangeClosureSystem
variable {X : Type u} [Fintype X]

def IsClosed (C : ExchangeClosureSystem X) (S : Set X) : Prop := C.cl S = S

theorem cl_isClosed (C : ExchangeClosureSystem X) (A : Set X) :
    C.IsClosed (C.cl A) := C.idempotent A

end ExchangeClosureSystem

/-! ## §2. Construction from Mathlib Matroids -/

/-- Every Matroid with ground set univ yields an ExchangeClosureSystem. -/
noncomputable def exchangeClosure_of_matroid {X : Type u} [Fintype X]
    (M : Matroid X) (hE : M.E = Set.univ) : ExchangeClosureSystem X where
  cl := M.closure
  extensive A := M.subset_closure A (by rw [hE]; exact Set.subset_univ _)
  mono {A B} hAB := M.closure_subset_closure hAB
  idempotent A := M.closure_closure A
  exchange {A x y} hyx hyA := by
    rw [Set.union_singleton] at hyx ⊢
    exact (M.closure_exchange_iff.mp ⟨hyx, hyA⟩).1

/-! ## §3. Dependency Presentations -/

/-- A finitely generated dependency presentation on a finite type X.
Each dependency has a support set and a designated target element.
The target is determined by the rest of the support. -/
structure DepPresentation (X : Type u) [Fintype X] [DecidableEq X] where
  Dep : Type u
  [instFinDep : Fintype Dep]
  support : Dep → Finset X
  tgt : Dep → X
  tgt_mem : ∀ d, tgt d ∈ support d
  support_nonempty : ∀ d, (support d).Nonempty

attribute [instance] DepPresentation.instFinDep

variable {X : Type u} [Fintype X] [DecidableEq X]

namespace DepPresentation

/-- Induced closure: x ∈ cl(A) iff x ∈ A or there is a dependency targeting x
with all other support elements in A (i.e., support \ {x} ⊆ A). -/
def cl (S : DepPresentation X) (A : Set X) : Set X :=
  {x | x ∈ A ∨ ∃ d, S.tgt d = x ∧ ∀ y ∈ S.support d, y ≠ x → y ∈ A}

/-- Qualified: target t is in cl(Q) -/
def Qualified (S : DepPresentation X) (t : X) (Q : Finset X) : Prop :=
  t ∈ S.cl (↑Q)

/-- Minimally qualified -/
def MinQualified (S : DepPresentation X) (t : X) (Q : Finset X) : Prop :=
  S.Qualified t Q ∧ ∀ Q' : Finset X, Q' ⊂ Q → ¬S.Qualified t Q'

/-- Extractor witness -/
def ExtractorWit (S : DepPresentation X) (A : Finset X) (x : X) : Prop :=
  x ∈ S.cl (↑A)

end DepPresentation

/-! ## §4. Rank Structure -/

/-- Matroid-style rank axioms. -/
structure MatroidRankFn (X : Type u) [Fintype X] [DecidableEq X] where
  r : Finset X → ℕ
  rank_bounded : ∀ A, r A ≤ A.card
  rank_mono : ∀ ⦃A B⦄, A ⊆ B → r A ≤ r B
  rank_submod : ∀ A B, r (A ∪ B) + r (A ∩ B) ≤ r A + r B
  rank_unit : ∀ A x, r A ≤ r (insert x A) ∧ r (insert x A) ≤ r A + 1

namespace MatroidRankFn

def RankIndep (R : MatroidRankFn X) (A : Finset X) : Prop := R.r A = A.card

def RankBasis (R : MatroidRankFn X) (I B : Finset X) : Prop :=
  I ⊆ B ∧ R.RankIndep I ∧ R.r I = R.r B

def RankCircuit (R : MatroidRankFn X) (C : Finset X) : Prop :=
  R.r C < C.card ∧ ∀ D : Finset X, D ⊂ C → R.r D = D.card

end MatroidRankFn

/-! ## §5. Induced Closure Properties -/

theorem cl_extensive (S : DepPresentation X) (A : Set X) :
    A ⊆ S.cl A := fun _ hx => Or.inl hx

theorem cl_mono_dep (S : DepPresentation X) {A B : Set X} (h : A ⊆ B) :
    S.cl A ⊆ S.cl B := by
  intro x hx
  rcases hx with hxA | ⟨d, htgt, hsup⟩
  · exact Or.inl (h hxA)
  · exact Or.inr ⟨d, htgt, fun y hy hne => h (hsup y hy hne)⟩

/-! ## §6. Canonical Construction -/

/-- The canonical closure from an exchange closure system: x ∈ canonicalCl C A
iff x ∈ A or x ∈ cl(B) for some B ⊆ A with x ∉ B. -/
def canonicalCl (C : ExchangeClosureSystem X) (A : Set X) : Set X :=
  {x | x ∈ A ∨ ∃ B : Finset X, x ∈ C.cl (↑B) ∧ x ∉ (↑B : Set X) ∧ (↑B : Set X) ⊆ A}

/-- cl(A) ⊆ canonicalCl(A) -/
theorem canonical_cl_supset (C : ExchangeClosureSystem X) (A : Finset X) :
    C.cl (↑A) ⊆ canonicalCl C (↑A) := by
  intro x hx
  by_cases hxA : x ∈ (↑A : Set X)
  · exact Or.inl hxA
-- ... (truncated, full file has 342 lines)
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
