## Assignment: Algebra–Tropical–RepresentationTheory  
## Tropical Geometric Langlands via Idempotent Affine Grassmannian Semirings and Certified Mirković–Vilonen Polytope Reconstruction

**Mode: prove**

Build a genuinely new bridge on the `tropical_langlands` arc, decisively beyond the already-completed Tropical Satake Skeleton and Tropical Plancherel Reconstruction results. The goal is not another tropical shadow of a known correspondence, but a formal theorem that **recovers representation-theoretic geometry from idempotent convolution algebra**.

You should prove that, for a finitely generated idempotent spherical Hecke semiring with a valuation-compatible affine Grassmannian cell decomposition, **indecomposable finite semimodules are classified by tropical MV-type polytopes**, and that **convolution is transported to certified Minkowski composition**. Then prove an explicit **reconstruction theorem**: the extremal values of a semiring character on Hecke generators determine the associated tropical MV polytope, with correctness certified by a finite family of edge and tropical Plücker inequalities.

This would be a breakthrough because it upgrades tropical Satake from a coarse harmonic or skeletal correspondence to a **geometric representation classifier**. It would mean that in the idempotent world, one can recover the analog of highest-weight geometry not from linear categories or perverse sheaves directly, but from a finitely generated semiring plus certified extremal data. That is a new organizing principle for tropical geometric Langlands.

---

## Core theorem package to formalize and prove

Work in:

`Bridges/AlgebraTropicalRepresentationTheory/TropicalGeometricLanglandsMV.lean`

You may introduce any supporting files in the same namespace if the architecture becomes cleaner.

### 1. Classification theorem: indecomposable semimodules ↔ tropical MV polytopes

Formal target: define a structure of admissible tropical MV data over a finite chamber index type, and prove a classification equivalence with a class of finite indecomposable semimodules over an idempotent Hecke semiring.

A precise Lean-oriented theorem should look like this schematic form:

```lean
theorem tropical_mv_classification
  {ι Λ : Type*}
  [Fintype ι] [DecidableEq ι]
  [CanonicallyOrderedCommSemiring Λ]
  (H : Type*)
  [Semiring H] [OrderBot H]
  [CanonicallyOrderedCommSemiring H]
  (Cell : ι → H)
  (gen : Subsemiring.closure (Set.range Cell) = ⊤)
  (Conv : TropicalHeckeStructure H ι Λ)
  :
  Nonempty
    (SemimodulePolytopeEquiv H ι Λ)
```

But do not stop at `Nonempty`. The real target is an actual equivalence object or pair of inverse constructions. More explicitly, aim for something of the following shape:

```lean
def TropicalMVPolytope (ι Λ : Type*) [Fintype ι] [Preorder Λ] : Type := ...
def FiniteIndecHeckeSemimodule (H : Type*) [Semiring H] : Type := ...

def semimoduleToMV
  : FiniteIndecHeckeSemimodule H → TropicalMVPolytope ι Λ := ...

def mvToSemimodule
  : TropicalMVPolytope ι Λ → FiniteIndecHeckeSemimodule H := ...

theorem semimoduleToMV_left_inv
  : Function.LeftInverse mvToSemimodule semimoduleToMV := ...

theorem semimoduleToMV_right_inv
  : Function.RightInverse mvToSemimodule semimoduleToMV := ...

def tropical_mv_classification_equiv
  : FiniteIndecHeckeSemimodule H ≃ TropicalMVPolytope ι Λ := ...
```

### Mathematical statement
For a finitely generated idempotent spherical Hecke semiring `H_trop(G)` with finite dominant generator set and valuation-compatible affine Grassmannian cell structure, there is a canonical equivalence between:

1. finitely generated indecomposable semimodules satisfying a spectral simplicity condition, and  
2. admissible tropical MV polytopes, modeled as finitely supported chamber-weight functions satisfying:
   - normalization,
   - edge inequalities,
   - tropical Plücker-type relations,
   - finite support / boundedness.

Under this equivalence, the semiring character of the semimodule equals the support function of the associated tropical MV polytope on Hecke generators.

---

### 2. Monoidality theorem: convolution ↔ Minkowski composition

This is where the theorem becomes field-opening rather than classificatory bookkeeping.

You should prove a transport-of-structure theorem showing that convolution on the semimodule side corresponds to tropical Minkowski addition on the polytope side.

Lean-oriented statement:

```lean
def mvMinkowski
  (P Q : TropicalMVPolytope ι Λ) : TropicalMVPolytope ι Λ := ...

def semimoduleConvolution
  (M N : FiniteIndecHeckeSemimodule H) : FiniteHeckeSemimodule H := ...

theorem tropical_mv_convolution_minkowski
  (M N : FiniteIndecHeckeSemimodule H) :
  semimoduleToMV (semimoduleConvolution M N |> indecCore)
    = mvMinkowski (semimoduleToMV M) (semimoduleToMV N)
```

If indecomposability is not preserved on the nose, prove the theorem for a certified indecomposable core, spectral support, or extremal summand extractor. It is acceptable to define an auxiliary notion like `highestWeightCore` or `extremalComponent` if that is what makes the theorem true and formalizable.

### Mathematical statement
For indecomposable spectral semimodules `M, N`, the tropical MV polytope attached to their convolution is the Minkowski sum of the tropical MV polytopes attached to `M` and `N`, and character evaluation on generators is additive in the tropical sense. This is the tropical geometric analogue of tensor product → MV polytope addition.

---

### 3. Certified reconstruction theorem: character extremals determine the polytope

This theorem must be algorithmic and checkable by finite certificates.

Lean-oriented target:

```lean
def CharacterOnGenerators
  (ι Λ : Type*) [Fintype ι] : Type := ι → Λ

def reconstructMV
  (χ : CharacterOnGenerators ι Λ) : TropicalMVPolytope ι Λ := ...

def edgeInequalitiesHold
  (P : TropicalMVPolytope ι Λ) : Prop := ...

def tropicalPluckerHold
  (P : TropicalMVPolytope ι Λ) : Prop := ...

theorem reconstructMV_correct
  (χ : CharacterOnGenerators ι Λ)
  (hχ : AdmissibleCharacter χ) :
  let P := reconstructMV χ
  in edgeInequalitiesHold P ∧ tropicalPluckerHold P ∧
     semiringCharacter (mvToSemimodule P) = χ
```

And ideally a uniqueness statement:

```lean
theorem reconstructMV_unique
  (χ : CharacterOnGenerators ι Λ)
  (hχ : AdmissibleCharacter χ)
  {P : TropicalMVPolytope ι Λ}
  (hP : semiringCharacter (mvToSemimodule P) = χ) :
  P = reconstructMV χ
```

### Mathematical statement
Given the extremal values of a semiring character on a finite Hecke generator set, one can reconstruct the unique admissible tropical MV polytope by finite combinatorial propagation, and correctness is certified by edge inequalities and tropical Plücker relations. This is the tropical analogue of recovering geometric representation data from spectral character data.

---

## Suggested formal definitions

You will likely need a finite, combinatorial avatar of MV data rather than the full affine Grassmannian. That is a feature, not a compromise: the theorem should reveal that a finite idempotent encoding already contains the geometric content.

### Define:
- `TropicalHeckeStructure H ι Λ`  
  Encodes:
  - distinguished generators indexed by dominant coweights or chamber data,
  - idempotent addition,
  - convolution,
  - valuation-compatible order,
  - finite generation and monotonicity assumptions.

- `ChamberWeightData ι Λ := ι → Λ`

- `TropicalMVPolytope ι Λ` as a structure with fields like:
```lean
structure TropicalMVPolytope (ι Λ : Type*) [Fintype ι] [Preorder Λ] where
  weight : ι → Λ
  finite_support : ...
  edge_ok : Prop
  plucker_ok : Prop
  normalized : Prop
```

- `AdmissibleCharacter χ` meaning:
  - monotone on generators,
  - compatible with convolution,
  - satisfies finite extremal consistency axioms needed to reconstruct a polytope.

- `FiniteIndecHeckeSemimodule H` as a bundled object including:
  - a finite carrier,
  - semimodule action,
  - indecomposability,
  - spectral simplicity or extremal generation.

You do **not** need to formalize full reductive group theory unless the dynamic context already provides infrastructure. A finite chamber/coweight model is enough if the theorems are exact in that setting.

---

## How to build on catalog theorems

You already have certified tropical spectral and Satake-type ingredients. Use them as actual load-bearing beams, not citations.

### 1. `gl3_tropical_satake_certified_robustness_affine`
File: `Bridges/TropicalSatakeRobustness.lean`

Use this to justify and import:
- the finite affine/cell decomposition viewpoint,
- valuation-compatible robustness of tropical Satake data,
- a certified mechanism for passing from local cell data to stable global combinatorial invariants.

**How to build on it:**  
Abstract the robust affine cell machinery from the `GL₃` case into a typeclass or lemma family that feeds your `TropicalHeckeStructure`. If the existing theorem proves stability of tropical data under affine perturbation, use that to show your reconstructed MV polytope is **well-defined independent of cell representatives**.

A likely intermediate theorem:

```lean
theorem mv_reconstruction_cell_invariant
  ... :
  reconstructMV χ = reconstructMV χ'
```

whenever `χ, χ'` arise from affine-cell equivalent spectral data.

### 2. `finite_spectral_reconstruction_bridge`
File: `Bridges/ClosureKoopmanReconstruction.lean`

This theorem is especially important philosophically: it already says finite spectral data can reconstruct global structure.

**How to build on it:**  
Port its reconstruction architecture to the idempotent Hecke setting. The crucial move is to reinterpret spectral reconstruction not as linear eigenspace recovery, but as **extremal support-function recovery**. This is the conceptual leap. Use whatever certified finite reconstruction pattern exists there to structure:
- finite observation set,
- reconstruction operator,
- correctness theorem,
- uniqueness theorem.

### 3. Any certified robustness theorem in the catalog
Even from a different domain, use the proof architecture:
- define a finite certificate,
- prove local inequalities imply global admissibility,
- package correctness in a computable theorem.

This is exactly the right style for tropical Plücker verification.

---

## Proof strategy architecture

You must pursue at least two proof paths in parallel and choose the one that formalizes best.

### Strategy A: Support-function classification via extremal generators
This is likely the most Lean-friendly and most promising.

1. Define the tropical MV polytope by its support function on a finite chamber-weight index set.
2. Show every indecomposable finite Hecke semimodule determines such a support function via character evaluation on distinguished generators.
3. Prove the support function satisfies edge inequalities and tropical Plücker relations because semiring convolution and idempotency force the necessary submodular constraints.
4. Reconstruct a semimodule from admissible support data by taking a free finite semimodule quotient modulo the relations encoded by the polytope.
5. Prove the constructions are inverse.

**Why this is promising:**  
It avoids full geometric affine Grassmannian formalization and instead compresses geometry into finite support-function axioms. This aligns perfectly with Lean and with certified reconstruction.

---

### Strategy B: Convolution algebra first, geometry second
This is conceptually powerful if the semiring side is already well-developed.

1. Define a category or bundled type of finite Hecke semimodules and prove a spectral normal form for indecomposables.
2. Show the normal form is parameterized by extremal coweight data.
3. Identify the consistency conditions on extremal data with tropical MV inequalities.
4. Define Minkowski addition at the level of extremal data and prove compatibility with convolution.

**Why this is good:**  
It makes the classification feel intrinsic to algebra rather than imposed from outside.  
**Why it may be harder:**  
Normal forms for semimodules over idempotent semirings can become technically awkward in Lean.

---

### Strategy C: Certified polytope reconstruction by local-to-global inequalities
This is the theorem that can make the whole project computationally explosive.

1. Define a reconstruction algorithm from generator character values to chamber-weight values by iterative closure under edge moves / tropical exchange moves.
2. Prove termination using finiteness of the chamber index set.
3. Prove soundness: each generated inequality is valid for any semimodule-origin character.
4. Prove completeness: any admissible tropical MV polytope is recovered exactly.
5. Derive uniqueness and a finite certificate checker.

**Why this matters:**  
This turns the classification theorem into an executable tropical representation decoder.

---

## The deepest mathematical insight to emphasize

The breakthrough is that **MV geometry is being reconstructed from idempotent spectral data alone**. In ordinary geometric Satake, one passes through tensor categories, perverse sheaves, and representation categories. Here, the claim is that in a tropical/idempotent regime, the essential geometric data survives in the much leaner object of an idempotent Hecke semiring plus extremal characters. That is not merely a tropical analogue; it is a new thesis:

> In idempotent representation theory, geometry is the convex envelope of spectral extremals.

Your formalization should make this thesis precise.

This also suggests a structural lemma worth proving if feasible:

```lean
theorem tropical_character_eq_support_function
  (M : FiniteIndecHeckeSemimodule H) :
  ∃ P : TropicalMVPolytope ι Λ,
    semiringCharacter M = supportFunction P
```

This lemma is the conceptual heart of the bridge.

---

## Cross-domain connections you should exploit explicitly

Do not keep this isolated inside representation theory. The theorem is powerful because it connects multiple domains.

### Tropical geometry
MV polytopes become tropical convex objects with certified reconstruction.  
This suggests a new finite-certification framework for tropical moduli.

### Representation theory
Convolution ↔ Minkowski addition gives an idempotent shadow of tensor product multiplicative structure.  
This is a tropical highest-weight machine.

### Idempotent algebra / max-plus or min-plus spectral theory
Semiring characters behave like nonlinear eigenvalue/support-function probes.  
This links tropical Langlands to nonlinear Perron–Frobenius theory.

### Convex geometry
The classification turns semimodules into convex bodies via support functions.  
This opens a “convex representation theory” viewpoint.

### Algorithms / certified inference
The reconstruction theorem yields a finite, checkable decoding procedure for representation data from compressed spectral measurements.

### Sheaf-theoretic analogy
Even if full perverse sheaf formalization is absent, your theorem should be framed as recovering the **combinatorial shadow of perverse-sheaf data** from idempotent convolution.

### Potential physics analogy
Convolution-to-Minkowski transport resembles passage from microscopic composition laws to effective thermodynamic convex potentials. This may ultimately connect tropical geometric Langlands to statistical mechanics and integrable systems.

---

## Concrete intermediate lemmas worth proving

These can serve as the actual Lean stepping stones.

```lean
theorem character_submodular
  (M : FiniteIndecHeckeSemimodule H) :
  Submodular (semiringCharacter M)
```

```lean
theorem character_satisfies_edge_inequalities
  (M : FiniteIndecHeckeSemimodule H) :
  edgeInequalitiesHold (semimoduleToMV M)
```

```lean
theorem character_satisfies_tropical_plucker
  (M : FiniteIndecHeckeSemimodule H) :
  tropicalPluckerHold (semimoduleToMV M)
```

```lean
theorem reconstruct_from_character_left_inverse
  (M : FiniteIndecHeckeSemimodule H) :
  reconstructMV (semiringCharacter M) = semimoduleToMV M
```

```lean
theorem support_function_minkowski
  (P Q : TropicalMVPolytope ι Λ) :
  supportFunction (mvMinkowski P Q)
    = supportFunction P + supportFunction Q
```

where `+` is tropical/additive in the appropriate semiring sense.

```lean
theorem semiring_character_convolution
  (M N : FiniteIndecHeckeSemimodule H) :
  semiringCharacter (semimoduleConvolution M N |> indecCore)
    = semiringCharacter M + semiringCharacter N
```

These lemmas, once assembled, should make the main theorem almost inevitable.

---

## Lean 4 design guidance

Prefer finite combinatorial definitions over abstract geometric ones unless the latter already exist in Mathlib or the local codebase.

Recommended typeclass backbone:
- `Fintype`, `DecidableEq` for chamber indices,
- `CanonicallyOrderedCommSemiring` or `LinearOrder` where support-function inequalities are needed,
- finite maps / `Finset`-based support for algorithmic reconstruction.

If tropical arithmetic is easier over `ℕ∞`, `WithTop ℕ`, `ℤ`, or `ℚ`, choose the ambient coefficient type that minimizes friction. `ℤ` or `ℚ` may be easiest for polyhedral inequalities; `WithTop` may be useful if you need unreachable/extremal states.

If categorical equivalence is too heavy, a bundled `Equiv` between explicit structures is enough. The theorem is already revolutionary without category theory overhead.

Minimize sorry by proving the theorem first in a finite chamber model:
- finite set of chamber weights,
- finite generator set for the Hecke semiring,
- finite support tropical MV data.

If successful, leave generalization hooks in the API.

---

## Breakthrough significance

If you complete this, you open an entirely new program:

- **Tropical geometric Langlands with certified combinatorial avatars**
- **Convex classification of idempotent representations**
- **Executable reconstruction of geometric representation data**
- **Fast tropical spectral decoding from compressed observables**
- **A bridge from affine Grassmannian geometry to semiring algorithms**

This is not an incremental extension of tropical Satake. It is a claim that the next layer of geometry — the MV-polytope layer — is also formally reconstructible in the idempotent world, and reconstructible by finite certificates. That would create a credible foundation for tropical canonical bases, tropical crystal reconstruction, and eventually tropical automorphic inference.

---

## Application keywords

`tropical geometric Langlands`, `Mirković–Vilonen polytopes`, `idempotent Hecke semirings`, `affine Grassmannian skeleton`, `tropical Satake`, `certified reconstruction`, `support functions`, `Minkowski convolution`, `highest-weight decoding`, `nonlinear spectral theory`, `convex representation theory`, `finite certificate verification`, `tropical Plücker relations`, `algorithmic representation inference`

---

## Deliverables

1. The main Lean file:
   - `Bridges/AlgebraTropicalRepresentationTheory/TropicalGeometricLanglandsMV.lean`

2. Supporting definitions/lemmas in auxiliary files if needed.

3. At least one executable reconstruction definition and one correctness theorem.

4. A clear theorem namespace exposing:
   - classification equivalence,
   - convolution/Minkowski compatibility,
   - certified reconstruction correctness,
   - uniqueness if feasible.

5. **Mandatory:** produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, such as:
   - tropical crystal operators from MV edge moves,
   - tropical canonical basis reconstruction,
   - extension from finite chamber models to affine Coxeter data,
   - tropical automorphic packets from semiring characters,
   - certified comparison with ordinary MV polytopes via valuation functors.

Be bold: the point is to show that in the tropical world, representation geometry is not lost — it is compressed into convex semiring data and can be formally recovered.

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
