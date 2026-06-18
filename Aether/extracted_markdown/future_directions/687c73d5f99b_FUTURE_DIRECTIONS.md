# Future Directions: Semantic Cubical Foundations in Lean 4

## Overview

This document identifies 5 concrete breakthrough research directions opened by the current work on semantic cubical interfaces in Lean 4. Each direction includes a precise theorem statement, a Lean-style signature, a proof strategy sketch, and cross-domain connections.

---

## Direction 1: Cubical Transport over Dependent Sums

### Problem Statement

Extend the path formalism with a transport operation for dependent types. Given a path in a base type and a fibered type over it, transport elements from the fiber over the start point to the fiber over the endpoint.

### Lean Signature

```lean
class CubicalTransport (I : Type u) extends CubicalInterval I where
  transport : {A : I → Type v} → (∀ i, A i) → A i0 → A i1

def sigma_transport {I : Type u} [CubicalTransport I]
    {A : Type v} {B : A → Type w} {a₀ a₁ : A}
    (p : PathOver (I := I) A a₀ a₁)
    (b : B a₀) : B a₁ := ...

theorem sigma_path {I : Type u} [CubicalTransport I]
    {A : Type v} {B : A → Type w}
    {s t : (a : A) × B a}
    (p : PathOver (I := I) A s.1 t.1)
    (q : PathOver (I := I) (B t.1) (sigma_transport p s.2) t.2) :
    PathOver (I := I) ((a : A) × B a) s t
```

### Proof Strategy

1. Define `CubicalTransport` extending `CubicalInterval` with a `transport` operation satisfying `transport (reflPath a) b = b`.
2. For the Bool interval, transport is trivially defined since a path `PathOver A a₀ a₁` with `I = Bool` carries a function `Bool → A` and we can use the fiber equivalence.
3. For sigma types, use the pair construction: `⟨λ i, (p.val i, ...), ...⟩` where the second component uses transport along the path.
4. Prove the beta rule: transport along a reflexivity path is the identity.

### Cross-Domain Connections

- **Category theory:** Transport corresponds to functorial action of the base change functor in fibered categories. The sigma path theorem is the total space functor's action on morphisms.
- **Physics:** Transport along paths in a fibration models parallel transport in gauge theory. The base type is spacetime, fibers are internal spaces, and paths are worldlines.
- **Programming languages:** Transport over dependent sums corresponds to coercion in gradual type systems: when a base type evolves, dependent data must be coerced along the type change.

---

## Direction 2: Composition and Kan Filling Operations

### Problem Statement

Extend the cubical interval with connection operations (meet/join) and a composition operation enabling path concatenation and Kan-style filling.

### Lean Signature

```lean
class CubicalComposition (I : Type u) extends CubicalInterval I where
  meet : I → I → I  -- ∧
  join : I → I → I  -- ∨
  meet_i0_left  : ∀ j, meet i0 j = i0
  meet_i1_left  : ∀ j, meet i1 j = j
  join_i0_left  : ∀ j, join i0 j = j
  join_i1_left  : ∀ j, join i1 j = i1

def pathTrans {I : Type u} [CubicalComposition I]
    {A : Type v} {a b c : A}
    (p : PathOver (I := I) A a b) (q : PathOver (I := I) A b c) :
    PathOver (I := I) A a c := ...

theorem pathTrans_assoc {I : Type u} [CubicalComposition I]
    {A : Type v} {a b c d : A}
    (p : PathOver A a b) (q : PathOver A b c) (r : PathOver A c d) :
    pathTrans (pathTrans p q) r = pathTrans p (pathTrans q r)
```

### Proof Strategy

1. Define meet/join satisfying De Morgan algebra axioms on the interval.
2. Define `pathTrans` using the connection operations: `(pathTrans p q).val i := if meet(i, ...) then ... else ...` (following the cubical composition formula).
3. For the Bool interval, the connection structure is trivial (meet = ∧, join = ∨), and path composition reduces to transitivity.
4. Associativity follows from the associativity of meet/join.
5. Instantiate with a concrete three-element interval `{0, ½, 1}` for a non-trivial model.

### Cross-Domain Connections

- **Algebraic topology:** Composition corresponds to concatenation of paths in a topological space. Associativity up to homotopy is the foundation of ∞-groupoid structure.
- **Concurrency theory:** Path composition models sequential composition of processes. The interval connections model parallel composition (meet) and choice (join).
- **Temporal logic:** Meet/join on the interval correspond to temporal operators "always" (∧) and "eventually" (∨) in linear temporal logic.

---

## Direction 3: Synthetic π₁(S¹) ≅ ℤ via a Non-Trivially-Truncated Circle Model

### Problem Statement

Construct a circle model with non-trivial loop space and prove that its fundamental group is isomorphic to the integers.

### Lean Signature

```lean
-- Model S¹ via ℤ-torsor
def S1Model := ℤ  -- universal cover
def S1Base : S1Model := 0
def S1Loop : S1Base = S1Base := ... -- NOT rfl; use quotient

-- Alternatively: model as BZ (delooping of ℤ)
def LoopSpace (X : Type) (x : X) := { p : x = x }

theorem pi1_circle_iso_Z :
    LoopSpace S1Model S1Base ≃ ℤ
```

### Proof Strategy

1. Model the circle as the quotient `ℤ / trivial` is wrong (gives a point). Instead, model the *loop space* directly: define `ΩS¹` as the type of automorphisms of the universal cover fiber over the base point.
2. The universal cover of S¹ is ℝ → S¹ with fiber ℤ. Model this as the type of ℤ-valued winding numbers.
3. Define the loop as the successor automorphism `n ↦ n + 1`.
4. Prove that every automorphism of ℤ (as a ℤ-torsor) is given by addition of a fixed integer.
5. This gives `ΩS¹ ≅ ℤ` without requiring higher inductive types—only the algebraic structure of ℤ-torsors.

### Cross-Domain Connections

- **Algebraic topology:** This is the first non-trivial homotopy group calculation in synthetic homotopy theory.
- **Number theory:** The fundamental group ℤ of the circle relates to the theory of covering spaces, which connects to Galois theory via the étale fundamental group.
- **Signal processing:** Winding numbers of the circle correspond to frequency components in Fourier analysis.

---

## Direction 4: Normalization-by-Evaluation for Universe Codes

### Problem Statement

Extend the weak univalence framework with a normalization-by-evaluation (NbE) algorithm that normalizes universe codes by evaluating them into a semantic domain and reading back canonical forms.

### Lean Signature

```lean
-- Extend UCode with function types
inductive UCodeExt : Type
  | base : UCode → UCodeExt
  | arrow : UCodeExt → UCodeExt → UCodeExt

def ElExt : UCodeExt → Type
def cardExt : UCodeExt → ℕ  -- partial: arrow types have infinite cardinality

-- NbE for the finite fragment
def reify : (n : ℕ) → Fin n → UCode  -- read-back from semantic domain
def reflect : UCode → (Fin (card c) → Fin (card c))  -- evaluation

theorem nbe_correct (c : UCode) :
    normalize c = reify (card c) (reflect c)

theorem nbe_idempotent (c : UCode) :
    reify (card (reify n f)) (reflect (reify n f)) = reify n f
```

### Proof Strategy

1. The semantic domain for finite types is `Fin n` for appropriate `n`.
2. `reflect` maps a code `c` to the identity permutation on `Fin (card c)`.
3. `reify n` reads back any function `Fin n → Fin n` to the canonical code for `n`.
4. Correctness: `reify (card c) id = canonical (card c) = normalize c`.
5. Extend to handle isomorphism: if `f : Fin n ≃ Fin m`, then `n = m` by `Fin.equiv_iff_eq`.

### Cross-Domain Connections

- **Programming language semantics:** NbE is a standard technique for normalizing lambda terms by evaluating into a semantic domain.
- **Proof theory:** The normalization theorem corresponds to cut-elimination for a propositional logic.
- **Compiler design:** Type normalization algorithms are used in optimizing compilers for dependently-typed languages.

---

## Direction 5: Path Semantics for Concurrent Processes via Interval Reparametrization

### Problem Statement

Use the path reparametrization framework to model concurrent process semantics. Paths represent process executions, reparametrizations model time rescaling, and path equivalence classes represent observational equivalence of processes.

### Lean Signature

```lean
-- Processes as paths in a state space
structure Process (S : Type) (s₀ s₁ : S) where
  execution : PathOver (I := UnitInterval) S s₀ s₁
  -- UnitInterval = [0,1] ⊂ ℝ with appropriate CubicalInterval instance

-- Observational equivalence via reparametrization
def ObsEquiv {S : Type} {s₀ s₁ : S}
    (p q : Process S s₀ s₁) : Prop :=
  ∃ (φ : UnitInterval → UnitInterval),
    Monotone φ ∧
    φ 0 = 0 ∧ φ 1 = 1 ∧
    pathReparam p.execution φ ... = q.execution

-- Parallel composition via product paths
def parallel {S T : Type} {s₀ s₁ : S} {t₀ t₁ : T}
    (p : Process S s₀ s₁) (q : Process T t₀ t₁) :
    Process (S × T) (s₀, t₀) (s₁, t₁) := ...

theorem parallel_comm {S T} (p : Process S s₀ s₁) (q : Process T t₀ t₁) :
    ObsEquiv (parallel p q) (parallel q p)  -- up to product swap
```

### Proof Strategy

1. Define `UnitInterval` as `Set.Icc (0 : ℝ) 1` with appropriate `CubicalInterval` instance.
2. Observational equivalence is the quotient by monotone reparametrizations (time rescaling).
3. Parallel composition uses the product path construction: `(p ∥ q)(t) = (p(t), q(t))`.
4. Commutativity of parallel composition follows from commutativity of products.
5. Connect to trace semantics: a trace is a path in the state space, and trace equivalence is reparametrization equivalence.

### Cross-Domain Connections

- **Concurrency theory:** This connects cubical path semantics to Pratt's higher-dimensional automata and Goubault's directed algebraic topology.
- **Distributed systems:** Reparametrization invariance models the independence of observations from clock synchronization.
- **Relativity:** The analogy with spacetime intervals becomes precise: observational equivalence of processes under time reparametrization mirrors the invariance of spacetime intervals under Lorentz boosts.
- **Music theory:** Tempo-invariant musical analysis uses exactly this reparametrization framework—two performances of the same piece at different tempos are "equivalent" in the relevant sense.

---

## Summary

| # | Direction | Key Theorem | Difficulty | Impact |
|---|-----------|-------------|------------|--------|
| 1 | Dependent sum transport | sigma_path | Medium | Enables dependent type manipulation |
| 2 | Composition & Kan filling | pathTrans_assoc | Hard | Unlocks ∞-groupoid structure |
| 3 | π₁(S¹) ≅ ℤ | pi1_circle_iso_Z | Hard | First synthetic homotopy computation |
| 4 | NbE for codes | nbe_correct | Medium | Connects to PL semantics |
| 5 | Process semantics | parallel_comm | Medium | Bridges to concurrency theory |

Each direction is immediately actionable with the current codebase as a foundation. The most impactful next step is **Direction 2** (composition), as it unlocks path concatenation and enables all subsequent homotopical constructions.
