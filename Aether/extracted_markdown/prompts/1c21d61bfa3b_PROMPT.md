## Assignment: Algebra–EML–Logic Idempotent Stone Completeness via Closure Nuclei and Tropical Kripke Spectra

**Mode:** prove

Prove a genuinely new duality/completeness theorem package at the interface of idempotent algebra, closure/nucleus semantics, spectral topology, and positive modal logic. This should not be a variant of existing tropical Gödel semantics: the breakthrough is to make **closure operators themselves geometric**, via a prime-congruence spectrum whose stalk semantics yields a Stone-type completeness theorem and a finite-model decision pipeline.

The goal is a mathematically sharp, Lean-oriented theory for **finitely generated idempotent semirings with a nucleus-like closure**. The decisive innovation is that the semantic worlds are not arbitrary Kripke frames, but **prime closure-congruences** of the algebra itself. This is the idempotent/tropical analogue of Stone–Priestley–Esakia–locale semantics, but adapted to semiring congruences and closure nuclei.

---

## Core Objects

Let `S` be an idempotent semiring with order `x ≤ y :↔ x + y = y`. Equip `S` with a closure operator `c : S → S` satisfying:

1. **Inflationary:** `x ≤ c x`
2. **Monotone:** `x ≤ y → c x ≤ c y`
3. **Idempotent:** `c (c x) = c x`
4. **Join-stable:** `c (x + y) = c x + c y`
5. **Nucleus-type multiplicative law:** `c x * c y ≤ c (x * y)`

This is the correct algebraic abstraction of an EML-style closure/nucleus on an idempotent semiring.

Define a **`c`-congruence** to be a semiring congruence `≈` such that
`x ≈ y → c x ≈ c y`.

Define a **prime `c`-congruence** to be a proper `c`-congruence whose quotient carries the induced idempotent semiring order and satisfies the expected primeness/separation property appropriate to your congruence notion. The cleanest route is likely to formulate primeness through the quotient:
- the quotient is nontrivial,
- and for closed elements, multiplicative collapse implies one factor collapses,
or alternatively via a spectrum of prime kernels if that is easier to formalize.

Let `Spec_c(S)` be the set of prime `c`-congruences, topologized by basic opens
`D(a,b) := { P | ¬((c a) ≈_P (c b)) }`.

The central thesis: **`Spec_c(S)` is the canonical tropical Kripke space of `S`**, and the sheaf of local quotient-valuations over it provides complete semantics for a positive modal/tropical logic whose modal operator is interpreted by `c`.

---

## Precise Theorem Targets

You should aim to formalize a package of three theorems.

### Theorem 1: Spectral representation of closure-stable elements

For finitely generated `S`, construct a canonical presheaf/sheaf `𝒱_c` on `Spec_c(S)` whose stalk at `P` is the quotient by `P` (or the `c`-closed quotient, depending on which formalization is cleaner). Prove that the `c`-closed part of `S` embeds into global sections, and under the right separation hypotheses is isomorphic to them.

### Lean-style statement target
```lean
structure IsClosureNucleus (S : Type _) [Semiring S] [CanonicallyOrderedAddMonoid S] :=
  (c : S → S)
  (le_c : ∀ x, x ≤ c x)
  (mono_c : Monotone c)
  (idem_c : ∀ x, c (c x) = c x)
  (map_sup : ∀ x y, c (x + y) = c x + c y)
  (mul_sub : ∀ x y, c x * c y ≤ c (x * y))

def IsClosed {S} (C : IsClosureNucleus S) (x : S) : Prop := C.c x = x

-- schematic only: exact structures may vary with available Mathlib APIs
theorem closedElements_equiv_globalSections
  (S : Type _) [CommSemiring S] [CanonicallyOrderedAddMonoid S]
  (C : IsClosureNucleus S)
  [FiniteGeneration S]
  [EnoughPrimeClosureCongruences S C] :
  Nonempty (({x : S // IsClosed C x}) ≃+* GlobalSections (ClosureSpectrum.Sheaf S C))
```

### Exact mathematical content
Prove:

> **Representation Theorem.**  
> Let `S` be a finitely generated idempotent commutative semiring with closure nucleus `c`. Assume prime `c`-congruences separate `c`-closed elements:
> \[
> c(a)\neq c(b)\implies \exists P\in \operatorname{Spec}_c(S),\ (c(a)\not\equiv_P c(b)).
> \]
> Then the canonical map
> \[
> \eta:S^c \to \Gamma(\operatorname{Spec}_c(S),\mathcal V_c)
> \]
> from `c`-closed elements to global sections is injective; if local compatible sections glue uniquely from quotient representatives, then `η` is an isomorphism.

This is the algebraic heart of the project. It says closure-stable algebra is recoverable from its tropical spectral semantics.

---

### Theorem 2: Idempotent Stone completeness for positive modal/tropical logic

Define a positive modal language:
- variables,
- `⊤`, `⊥`,
- `∧`, `∨`,
- multiplicative conjunction/product if convenient,
- a modal/closure operator `□φ` interpreted as `c(⟦φ⟧)`.

Derivability should be in a Hilbert or sequent system capturing:
- positive distributive/idempotent laws,
- monotonicity of `□`,
- `φ ⊢ □φ`,
- `□□φ ⊢ □φ` and `□φ ⊢ □□φ`,
- `□(φ∨ψ) ⊣⊢ □φ∨□ψ`,
- and the multiplicative nucleus axiom reflected semantically.

### Lean-style statement target
```lean
theorem idempotentStone_completeness
  (L : PosModalFormula α)
  (S : Type _) [CommSemiring S] [CanonicallyOrderedAddMonoid S]
  (C : IsClosureNucleus S)
  [FiniteGeneration S]
  [EnoughPrimeClosureCongruences S C] :
  Derivable C.AxiomSet L ↔
    ValidInAllStalks (ClosureSpectrum.Sheaf S C) L
```

A more practical theorem for Lean may split into soundness and completeness:

```lean
theorem soundness_stalkSemantics ... :
  Derivable C.AxiomSet φ → ValidInAllStalks (ClosureSpectrum.Sheaf S C) φ

theorem completeness_stalkSemantics ... :
  ValidInAllStalks (ClosureSpectrum.Sheaf S C) φ → Derivable C.AxiomSet φ
```

### Exact mathematical content
Prove:

> **Idempotent Stone Completeness.**  
> For every formula `φ` in the positive modal fragment,
> \[
> \vdash \varphi \quad\Longleftrightarrow\quad
> \forall P\in \operatorname{Spec}_c(S),\ \mathcal V_{c,P}\models \varphi.
> \]
> Equivalently, derivability is the same as validity in all prime closure-congruence stalks.

This is the field-opening statement: logic is complete with respect to a semantics generated internally from idempotent algebra plus closure.

---

### Theorem 3: Finite decision pipeline via prime quotient reduction

For finitely generated finite or effectively presented `S`, prove that formula validity can be checked on a finite set of prime `c`-congruence quotients sufficient to separate relevant closed values.

### Lean-style statement target
```lean
theorem finite_validity_reduction
  (S : Type _) [Fintype S] [DecidableEq S]
  [CommSemiring S] [CanonicallyOrderedAddMonoid S]
  (C : IsClosureNucleus S) :
  ∃ (Ps : Finset (PrimeClosureCongruence S C)),
    ∀ φ : PosModalFormula α,
      ValidInAllModels C φ ↔ ∀ P ∈ Ps, ValidInStalk P φ
```

And algorithm extraction target:
```lean
def decideValidOnFiniteClosureSpectrum
  (φ : PosModalFormula α) : Decidable (ValidInAllModels C φ)
```

### Exact mathematical content
Prove:

> **Finite Prime Reduction Theorem.**  
> If `S` is finite (or finitely generated with effective finite prime spectrum under your hypotheses), then there exists a finite family of prime `c`-congruences `P₁,…,P_n` such that for every formula `φ`,
> \[
> \varphi \text{ valid } \Longleftrightarrow \bigwedge_{i=1}^n \varphi \text{ valid in } S/P_i.
> \]
> Hence validity in the positive modal fragment is decidable by quotient reduction.

This gives an algorithmic verification/proof-search mechanism, not just abstract semantics.

---

## Most Promising Formalization Shape

If full sheaf machinery becomes heavy, there is a strategically superior intermediate theorem:

1. Build the spectrum and quotient semantics.
2. Prove a **subdirect representation** of the `c`-closed quotient into the product of stalks.
3. Derive completeness from separation by prime `c`-congruences.
4. Only then package the result as global sections/sheaf semantics.

This lets you prove the deep mathematics without getting trapped in topological bureaucracy too early.

---

## Proof Strategy Options

### Strategy A: Quotient-first algebraic Stone duality
**Most promising.**

1. **Define `c`-closed quotient algebra.**  
   Replace `S` by the image/fixpoint algebra `S^c = {x | c x = x}` if operations can be induced cleanly; otherwise keep `S` and work with `c` as modality. Show `S^c` is a join-semilattice with multiplication inherited up to closure.

2. **Prime separation and subdirect embedding.**  
   Prove that if prime `c`-congruences separate closed elements, then the evaluation map
   \[
   x \mapsto ([x]_P)_P
   \]
   embeds `S^c` into the product of prime quotients. This is the idempotent semiring analogue of Stone/Priestley subdirect representation.

3. **Completeness via Lindenbaum algebra.**  
   Form the Lindenbaum algebra of the positive modal calculus. Show the canonical closure operator induced by `□` satisfies the nucleus laws. If a formula is not derivable, then two classes differ; by prime separation there is a prime `c`-congruence distinguishing them, yielding a falsifying stalk.

Why this is strongest: it reduces the topological theorem to algebraic separation, which is likely much easier in Lean than building sheaves first.

---

### Strategy B: Locale/sheaf route from basic opens `D(a,b)`
1. **Topology generation.**  
   Prove the `D(a,b)` form a basis: finite intersections refine to basic opens, and total space/empty set behave correctly. This likely needs closure identities such as
   `D(a,b) ∩ D(b,d) ⊆ D(a,d)`-style separation lemmas or a more algebraically natural basis.

2. **Canonical presheaf of quotients.**  
   Define sections over `U` as locally represented quotient classes compatible on overlaps. Show restriction maps and gluing.

3. **Global sections and completeness.**  
   Identify global sections with closure-stable elements; interpret formulas stalkwise and prove local truth is equivalent to derivability.

Why useful: this gives the strongest geometric result and makes the “tropical Kripke spectrum” literal. But it is technically heavier.

---

### Strategy C: Pointfree/locale reformulation
1. Construct a frame from closure-stable congruence conditions.
2. Show prime points of this frame correspond to prime `c`-congruences.
3. Use pointfree completeness and then recover the spectral space when enough points exist.

Why consider it: if topological points are awkward in Lean, a frame/locale argument may be more modular. This also aligns with nucleus theory in locale semantics. But it depends on how much frame theory is already convenient in Mathlib.

---

## Recommended Theorem Decomposition

To minimize sorrys, prove in the following order:

1. `IsClosureNucleus` basic lemmas:
   - `c` preserves order and fixed points
   - closed elements closed under `+`
   - `c x * c y ≤ c (x*y)` usable as semantic monotonicity

2. `PrimeClosureCongruence` API:
   - compatibility with `c`
   - quotient inherits idempotent semiring/order structure
   - basic separation lemmas

3. `ClosureSpectrum` topology:
   - define `D(a,b)`
   - prove basis/intersection lemmas
   - prove `Spec_c(S)` is `T₀` under separation assumptions

4. Algebraic representation:
   - map into product of quotients
   - injectivity from prime separation

5. Positive modal syntax/semantics:
   - formula interpretation into `S`
   - quotient/stalk semantics
   - soundness

6. Completeness:
   - Lindenbaum algebra
   - canonical prime quotient countermodel

7. Finite decision theorem:
   - finite spectrum or finite separating family
   - executable validity checker

---

## Cross-Domain Connections You Should Exploit

### 1. Tropical geometry and semiring spectra
This project is a new species of “spectrum” in idempotent mathematics: not prime ideals, but **prime closure-congruences**. That matters because congruences, not ideals, are often the right geometric invariants in semirings. This could open a tropical analogue of scheme semantics for modal logic.

### 2. EML / information bottleneck / closure semantics
The closure operator `c` is not cosmetic. It formalizes a notion of **information compression or abstraction**. Your theorem says compressed truths are exactly those visible as global sections over prime semantic viewpoints. This is a sheaf-theoretic semantics of abstraction.

### 3. Modal logic and Kripke semantics internalized in algebra
Instead of imposing an external accessibility relation, you derive worlds from algebraic congruence data. This is conceptually radical: **Kripke worlds become prime observational quotients of an idempotent algebra**.

### 4. Stone/Priestley/Esakia duality in nonclassical semiring form
This is an idempotent, positive, tropical version of duality theory. If it works, it suggests a whole family of dualities for semiring-valued and resource-sensitive logics.

### 5. Verification and certified proof search
The finite prime-reduction theorem yields a practical decision pipeline for finite models. This could become a certified checker for tropical/modal entailment, with applications to abstract interpretation, automata, and semiring semantics in program analysis.

---

## Application Keywords

tropical logic, idempotent semiring, closure nucleus, prime congruence spectrum, Stone completeness, Kripke semantics, sheaf semantics, spectral duality, positive modal logic, abstract interpretation, certified decision procedure, finite model property, semiring geometry, tropical verification, EML closure, information bottleneck semantics

---

## Suggested Lean 4 Type Signatures and Structures

These are schematic and should be adapted to Mathlib realities.

```lean
class IdempotentSemiring (S : Type _) extends Semiring S :=
  (add_idem : ∀ a : S, a + a = a)

def semiringOrder {S} [IdempotentSemiring S] : LE S :=
  ⟨fun a b => a + b = b⟩

structure IsClosureNucleus (S : Type _)
  [CommSemiring S] [CanonicallyOrderedAddMonoid S] where
  c : S → S
  le_c : ∀ x, x ≤ c x
  mono_c : Monotone c
  idem_c : ∀ x, c (c x) = c x
  map_sup : ∀ x y, c (x + y) = c x + c y
  mul_sub : ∀ x y, c x * c y ≤ c (x * y)

def IsClosed {S} [CommSemiring S] [CanonicallyOrderedAddMonoid S]
  (C : IsClosureNucleus S) (x : S) : Prop := C.c x = x

structure ClosureCongruence (S : Type _)
  [CommSemiring S] [CanonicallyOrderedAddMonoid S]
  (C : IsClosureNucleus S) where
  toCon : Con S
  closed_compat : ∀ {x y}, toCon x y → toCon (C.c x) (C.c y)

structure PrimeClosureCongruence (S : Type _)
  [CommSemiring S] [CanonicallyOrderedAddMonoid S]
  (C : IsClosureNucleus S) extends ClosureCongruence S C : Prop :=
  (proper : ¬ toCon 0 1)
  (prime_like :
    ∀ {a b},
      toCon (C.c (a * b)) 0 →
      toCon (C.c a) 0 ∨ toCon (C.c b) 0)

def D {S} ... (a b : S) : Set (PrimeClosureCongruence S C) :=
  {P | ¬ P.toClosureCongruence.toCon (C.c a) (C.c b)}
```

For formulas:
```lean
inductive PosModalFormula (α : Type _)
| var : α → PosModalFormula α
| top : PosModalFormula α
| bot : PosModalFormula α
| and : PosModalFormula α → PosModalFormula α → PosModalFormula α
| or  : PosModalFormula α → PosModalFormula α → PosModalFormula α
| box : PosModalFormula α → PosModalFormula α
```

Semantics:
```lean
def evalFormula ...
  (v : α → S) : PosModalFormula α → S
| var a => v a
| top => 1
| bot => 0
| and φ ψ => evalFormula v φ * evalFormula v ψ
| or φ ψ => evalFormula v φ + evalFormula v ψ
| box φ => C.c (evalFormula v φ)
```

Soundness/completeness targets:
```lean
theorem soundness_stalkSemantics ...
theorem completeness_stalkSemantics ...
theorem finite_validity_reduction ...
```

---

## Catalog-Building Blocks to Reuse

Use any existing congruence infrastructure, quotient semiring APIs, and closure/operator patterns already present in the catalog. In particular:

- Reuse **prime/congruence lemmas** from `AutoResearch/Basic.lean` or adjacent algebra files rather than rebuilding quotient infrastructure from scratch.
- Reuse **closure-capacity / closure-operator design patterns** from prior EML-related files: monotone/idempotent/inflationary operators and fixed-point substructures.
- If there are already verified tropical Gödel semantics results, use them as the **logic layer** and replace external semantic models with your new internal spectrum of prime closure-congruences.
- If there are verified spectral/topological basis lemmas elsewhere in the catalog, transport them to `D(a,b)`-opens rather than inventing a bespoke topology proof.

Do not merely cite these results—make them do work:
- congruence API for quotient/stalk semantics,
- closure operator API for the `□` modality,
- existing soundness infrastructure for the positive fragment,
- finite structure decidability patterns for the algorithmic theorem.

---

## Why This Is a Breakthrough

If successful, this creates a new research direction: **idempotent spectral logic**. The novelty is not just a completeness theorem; it is the identification of a canonical geometric object associated to closure-bearing semirings, with logic, representation theory, and computation all derived from the same spectrum.

This opens at least four fields at once:

1. **Tropical duality theory:** a prime-congruence Stone duality for semirings with nuclei.
2. **Semiring modal logic:** internal Kripke semantics from algebraic quotients.
3. **Certified abstract interpretation:** closure operators as semantic abstractions with completeness certificates.
4. **Algorithmic tropical verification:** finite quotient reduction as a practical decision method.

A mathematician seeing this should think: “I did not expect sheaf semantics, modal completeness, and EML closure to unify through tropical prime congruences.”

---

## Deliverables

1. Lean file(s) defining:
   - `IsClosureNucleus`
   - `ClosureCongruence`
   - `PrimeClosureCongruence`
   - `ClosureSpectrum`
   - positive modal syntax/semantics

2. Formal proofs of:
   - spectral separation/subdirect embedding theorem
   - soundness and completeness theorem
   - finite prime-reduction theorem

3. Minimal sorry count, with any remaining sorrys isolated to topological gluing lemmas if necessary.

4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - noncommutative closure spectra,
   - quantale-valued/modal enrichment,
   - tropical bisimulation via congruence spectra,
   - geometric completeness for enriched automata semantics,
   - idempotent topos-style semantics for resource logics.

Be specific in `FUTURE_DIRECTIONS.md`: each item should be a theorem-level next target, not a vague topic.

### Catalog Reference Files
@Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean
```lean
/-
  # Tropical Valuation Functor:
  # The Bridge Between Multiplicative Algebra, p-Adic Analysis,
  # and Post-Quantum Lattice Security

  ## Domain Bridge: Tropical Geometry ↔ p-Adic Analysis ↔ Lattice Cryptography ↔ Neural Network Robustness

  The central discovery: The p-adic valuation is a *functor* from multiplicative
  algebra to tropical (min-plus) algebra that preserves exactly the structure needed for:
  - Post-quantum lattice security reductions (hardness amplification)
  - Lipschitz-certified neural network robustness (composition bounds)
  - Algorithmic complexity classification (tropical circuit complexity)

  The valuation map v_p : (ℤ_p \ {0}, ×) → (ℤ, +) sends:
  - multiplication ↦ addition
  - divisibility ↦ order
  - gcd ↦ min (tropical multiplication)

  ## Main Results (35+ theorems, zero sorry)

  ## Structures (8 novel types)

  - `TropicalSemiringCertificate` — certified min-plus algebraic structure
  - `ValuationDepthMeasure` — complexity measure via p-adic depth
  - `LipschitzCompositionChain` — chain of Lipschitz maps with certified bound
  - `SpectralAmplificationCertificate` — spectral gap amplification bounds
  - `CertifiedRobustnessWitness` — end-to-end adversarial robustness certificate
  - `TropicalSecurityParameter` — post-quantum security from tropical rank
  - `TropicalHashFunction` — hash function with tropical collision resistance
  - `TropicalDistanceMetric` — tropical metric structure
-/

import Mathlib

open Finset BigOperators

noncomputable section

namespace TropicalValuationFunctor

/-! ## §1. Tropical Arithmetic Infrastructure

The tropical semiring (ℝ ∪ {+∞}, ⊕, ⊗) where:
  a ⊕ b = min(a, b)     (tropical addition)
  a ⊗ b = a + b          (tropical multiplication) -/

set_option checkBinderAnnotations false in
/-- **TropicalSemiringCertificate**: A certificate that a linearly ordered
    additive type carries tropical semiring structure.
    Bridge: connects abstract algebra to quantitative crypto bounds.
    Impact: post_quantum_security, lattice_crypto. -/
structure TropicalSemiringCertificate (α : Type*) [LinearOrder α] [Add α] where
  /-- Tropical addition (min) is commutative -/
  tropAdd_comm : ∀ a b : α, min a b = min b a
  /-- Tropical addition (min) is associative -/
  tropAdd_assoc : ∀ a b c : α, min (min a b) c = min a (min b c)
  /-- Tropical multiplication (add) is commutative -/
  tropMul_comm : ∀ a b : α, a + b = b + a
  /-- Tropical multiplication distributes over tropical addition -/
  tropDistrib : ∀ a b c : α, a + min b c = min (a + b) (a + c)

/-- **ℤ is a tropical semiring**. -/
def int_tropical_certificate : TropicalSemiringCertificate ℤ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **ℕ is a tropical semiring**. -/
def nat_tropical_certificate : TropicalSemiringCertificate ℕ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **ℝ is a tropical semiring**. -/
def real_tropical_certificate : TropicalSemiringCertificate ℝ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **Tropical commutativity is universal**: min is commutative in any linear order.
    Bridge: connects ordered algebra to tropical structure (Algebra ↔ Tropical). -/
theorem tropical_min_comm {α : Type*} [LinearOrder α] (a b : α) :
    min a b = min b a := min_comm a b

/-- **Tropical distributivity over ℤ**: a + min(b,c) = min(a+b, a+c). -/
theorem tropical_distrib_int (a b c : ℤ) :
    a + min b c = min (a + b) (a + c) := (min_add_add_left a b c).symm

/-- **Tropical distributivity over ℝ**: a + min(b,c) = min(a+b, a+c). -/
theorem tropical_distrib_real (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := (min_add_add_left a b c).symm

/-- **Tropical idempotency**: min(a, a) = a. Distinguishes tropical from classical. -/
theorem tropical_idempotent {α : Type*} [LinearOrder α] (a : α) :
    min a a = a := min_self a

/-- **Tropical absorption**: min(a, a + b) = a when b ≥ 0.
    Adding a non-negative "cost" never decreases the tropical sum. -/
theorem tropical_absorption (a b : ℤ) (hb : 0 ≤ b) :
    min a (a + b) = a := by simp [min_def]; omega

/-! ## §2. Valuation Depth Measure -/

/-- **ValuationDepthMeasure**: Complexity measure based on p-adic depth.
    Bridge: connects number theory to post-quantum security parameters.
    Impact: post_quantum_security, lattice_crypto. -/
structure ValuationDepthMeasure where
  /-- The prime base -/
  prime : ℕ
  /-- Primality certificate -/
  isPrime : Nat.Prime prime

/-- **Valuation additive on products**: v_p(ab) = v_p(a) + v_p(b).
    The *homomorphism property* making v_p a tropical functor.
    Bridge: connects multiplicative structure to tropical addition.
    Impact: tropical_hash_collision resistance bounds. -/
theorem valuation_additive_on_products (p a b : ℕ) (hp : Nat.Prime p)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.mul ha hb

/-- **Valuation of prime powers**: v_p(p^k) = k.
    Bridge: connects exponentiation to tropical scaling. -/
theorem valuation_prime_power (p k : ℕ) (hp : Nat.Prime p) :
    padicValNat p (p ^ k) = k := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.prime_pow k

/-- **Valuation of prime itself**: v_p(p) = 1. -/
theorem valuation_prime_self (p : ℕ) (hp : Nat.Prime p) :
    padicValNat p p = 1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.self hp.one_lt

/-- **Valuation of 1**: v_p(1) = 0. The unit maps to tropical zero. -/
theorem valuation_one (p : ℕ) : padicValNat p 1 = 0 := by simp

/-- **Valuation bounds power divisibility**: p^(v_p(n)) | n.
    Bridge: connects valuation to divisibility lattice. -/
theorem valuation_power_dvd (p n : ℕ) (hp : Nat.Prime p) :
    p ^ padicValNat p n ∣ n :=
  haveI : Fact (Nat.Prime p) := ⟨hp⟩; pow_padicValNat_dvd

/-- **Iterated valuation**: v_p(p^a · p^b) = a + b.
    Bridge: tropical multiplication = ordinary addition of exponents. -/
theorem valuation_iterated (p a b : ℕ) (hp : Nat.Prime p) :
-- ... (truncated, full file has 531 lines)
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
