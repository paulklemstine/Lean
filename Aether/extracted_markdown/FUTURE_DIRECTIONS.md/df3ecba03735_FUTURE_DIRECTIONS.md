# Future Directions

## 1. Extend Guarded Trace to Semiring-Enriched Monoidal Categories

The current formalization uses cartesian products (×) for the tensor. The natural
generalization replaces this with an arbitrary monoidal category enriched over
an idempotent semiring. In this setting:

- Morphisms become weighted relations `X → Y → S` with `S` an idempotent semiring
- Composition is semiring matrix multiplication
- The guarded trace becomes a Kleene-star-like closure operation
- The finite unrolling invariance theorem generalizes to: trace equivalence
  equals equality of all finite powers in the semiring

This would unify our fixed-point semantics with the tropical/min-plus algebra
framework, connecting circuit equivalence to shortest-path and optimization problems.

## 2. Full Conway Axiomatization and Traced Identity Derivation

Prove that the guarded fixed-point operator satisfies the full set of Conway
identities (naturality, dinaturality, superposing, yanking) and derive all
traced monoidal category axioms from them. This would:

- Establish that our construction is an instance of a traced monoidal category
- Enable compositional reasoning about feedback circuits
- Connect to Hasegawa's uniformity principle and Simpson-Plotkin adequacy
- Allow mechanical derivation of circuit identities from the axioms

## 3. Semiring-Weighted Partial Isomorphisms and Trace Conservation

Formalize the notion of a *semiring-weighted partial isomorphism*: a morphism
`f : X → Y → S` with a partial inverse `g : Y → X → S` such that their
composition yields the identity weighted by a conservation factor. Then prove:

- Reversibility implies trace conservation (the total weight is preserved
  through feedback)
- For Boolean semirings, this recovers classical reversible circuit theory
- For tropical semirings, this gives energy-conservation laws for min-plus circuits
- The Bekič decomposition preserves the partial-isomorphism structure

## 4. Tropical Linear Systems and Min-Plus Circuit Analysis

Connect the guarded finite-unrolling semantics to tropical linear algebra:

- Interpret the iteration chain as a sequence of tropical matrix powers
- Show that the guarded fixed point corresponds to the tropical Kleene star
- Prove that finite-unrolling equivalence reduces to equality of tropical
  eigenvalues for circuits with eventually periodic behavior
- Extract an efficient algorithm (polynomial in circuit size) for deciding
  equivalence of a restricted class of guarded reversible circuits

## 5. Executable Normalization for Finite Guarded Reversible Circuits

Build a certified decision procedure for circuit equivalence:

- For circuits over finite state spaces, the iteration chain stabilizes in
  finitely many steps (bounded by |σ|)
- Formalize this stabilization theorem and extract a computable decision
  procedure via `Decidable` instances
- Implement the procedure as a verified Lean function using `#eval`
- Benchmark against existing circuit equivalence checkers
- Extend to parametric families of circuits using symbolic computation
