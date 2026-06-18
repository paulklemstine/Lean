# Future Directions: Tropical Envelope Canonicalization Program

## Overview

The envelope canonicalization theorem establishes that the lower-envelope support of a tropical polynomial is the exact semantic core governing minimal realization. This opens a systematic research program connecting tropical geometry, weighted automata theory, and optimization. Below are five concrete breakthrough directions, each building on the verified results from this cycle.

---

## Direction 1: Multivariate Envelope Canonicalization via Newton Polytope Faces

### Precise Conjecture

For a multivariate tropical polynomial $p(x_1, \ldots, x_d) = \min_i (c_i + e_{i,1} x_1 + \cdots + e_{i,d} x_d)$, define the envelope-canonical form as the set of monomials that attain the minimum at some point in $\mathbb{N}^d$. Then:

**Conjecture.** Under a suitable multivariate generic position condition, the envelope-canonical monomials correspond exactly to the vertices of the lower face of the Newton polytope of $p$, and this set is the unique minimum-cardinality support preserving the weighted language $\mathbb{N}^d \to \mathbb{R}$.

### Why Nontrivial

In one variable, the lower envelope is piecewise linear with breakpoints determined by pairwise crossings. In $d$ variables, the envelope becomes a polyhedral subdivision of $\mathbb{R}^d$, and the combinatorics of which monomials appear on which faces is governed by the secondary polytope / tropical hypersurface structure. The passage from "pairwise crossing" to "polyhedral face enumeration" is a genuine dimensional increase in complexity.

### Building On

- `eval_envelopeCanonical_eq` (semantics preservation) — the same proof structure should generalize
- `envelope_unique_witness_of_generic` (strict witness) — needs extension to multivariate genericity
- The existing `Mono` structure with single `exp : ℕ` generalizes to `exp : Fin d → ℕ`

### New Connections

- Links to tropical intersection theory and stable intersections
- Connects to integer programming: integer points in polytope faces
- Opens applications to multi-parameter optimization

---

## Direction 2: Tropical Myhill–Nerode Theory via Envelope Regions

### Precise Conjecture

Define the *envelope region* of a monomial $m$ in polynomial $p$ as $R_m = \{n \in \mathbb{N} : m(n) = \text{polyEval}(p, n)\}$. Define a tropical Nerode equivalence: $i \sim j$ iff for all $k \in \mathbb{N}$, the minimizer at $i + k$ and $j + k$ is the same monomial.

**Conjecture.** The number of equivalence classes of $\sim$ equals $|\text{EnvelopeCanonical}(p)|$ under distinct slopes. Moreover, this equivalence is the coarsest right-congruence refining the weighted language, making it the tropical analogue of the classical Myhill-Nerode equivalence.

### Why Nontrivial

The classical Myhill-Nerode theorem works with *equality* of residual languages (Boolean test). The tropical version must work with *identity of extremal behaviors* (real-valued test), which requires understanding the geometry of which monomial dominates in which region. The regions $R_m$ are intervals on $\mathbb{N}$ whose structure is determined by the crossing points of adjacent affine functions.

### Building On

- `envelopeCanonical_is_minimal_support` — provides the cardinality to match
- `envelope_unique_witness_of_generic` — each equivalence class should contain a strict witness
- The `NerodeEquiv` definition already in the codebase

### New Connections

- Establishes a formal Galois connection between tropical geometry and automata theory
- Could generalize to weighted automata over arbitrary semirings
- Connects to the Hankel matrix theory of weighted languages

---

## Direction 3: Hankel Rank = Envelope Cardinality

### Precise Conjecture

For a tropical polynomial $p$ with weighted language $L : \mathbb{N} \to \mathbb{R}$, define the tropical Hankel matrix $H_{i,j} = L(i + j)$. Define the *tropical rank* of $H$ as the minimum number of "tropical rank-1 matrices" (of the form $a_i + b_j$) whose entrywise minimum equals $H$.

**Conjecture.** Under generic position, $\text{trop-rank}(H) = |\text{EnvelopeCanonical}(p)|$.

### Why Nontrivial

Tropical matrix rank is not the same as classical rank. The min-plus factorization problem is NP-hard in general. However, for Hankel matrices arising from tropical polynomials, the structure should force a clean answer. The challenge is showing that the Hankel structure interacts well with the envelope decomposition.

### Building On

- `envelopeCanonical_lower_bound` — provides the lower bound direction
- `hankel_distinct_rows_eq_minimal_states` from the existing Hecke-Crystal duality file
- `realizes_unique_implies_minimal` from persistence realization duality

### New Connections

- Bridges tropical linear algebra (Develin-Santos-Sturmfels) with automata minimality
- Could provide efficient algorithms: Hankel computation → envelope extraction
- Links to tensor decomposition and nonnegative matrix factorization

---

## Direction 4: Envelope Minimality for Weighted Transducers

### Precise Conjecture

A tropical weighted transducer computes a function $f : \Sigma^* \to \mathbb{R}$ by processing input symbols through state transitions. Each state contributes an affine cost depending on the input history.

**Conjecture.** For a transducer computing a rational tropical series, the minimal number of states equals the cardinality of a suitably defined "multi-word envelope" — the set of states that are the unique minimizer for some input word.

### Why Nontrivial

Transducers process sequences of arbitrary length, not single integers. The "envelope" must be defined over an infinite set of inputs (all words), and the minimality argument must handle composition of state transitions. The single-variable theory gives the base case (single-letter alphabet), but the extension to multi-letter alphabets requires handling non-commutative composition.

### Building On

- `envelopeCanonical_is_minimal_support` — the single-letter case
- `minimal_states_bound` from Closure-Kolmogorov realization
- `reconstruction_correct` from the transducer reconstruction theory

### New Connections

- Would provide a geometric minimization algorithm for weighted transducers
- Connects to the Schützenberger-Fliess realization theory
- Applications to weighted parsing, speech recognition, and bioinformatics

---

## Direction 5: Tropical Pruning Theory for Neural Architectures

### Precise Conjecture

A deep ReLU network with $L$ layers computes a function that is piecewise linear with pieces determined by the composition of tropical polynomials. Define the *layer-wise envelope* as the set of neurons at each layer that contribute to the output for some input.

**Conjecture.** The layer-wise envelope can be computed in polynomial time and gives the exact minimal network (fewest total neurons) computing the same function, under a suitable genericity condition on the weights.

### Why Nontrivial

Single-layer pruning is our Theorem 5 (envelope = minimal support). Multi-layer pruning is harder because:
1. Removing a neuron at layer $\ell$ changes the activation patterns at layer $\ell + 1$
2. The "witness" for a neuron at layer $\ell$ depends on the composition of all subsequent layers
3. The genericity condition must account for the compositional structure

The difficulty is that layer-wise envelope computation must be done bottom-up (from output to input), and each layer's envelope depends on the next layer's structure.

### Building On

- `eval_envelopeCanonical_eq` — semantics preservation at each layer
- `envelope_monomial_indispensable` — indispensability transfers through composition
- `essential_not_dominated` from the attention realization duality

### New Connections

- Provides a mathematically principled alternative to magnitude pruning
- Connects tropical geometry to neural architecture search
- Could yield provable compression bounds: "this network can be compressed to exactly $k$ neurons"
- Links to lottery ticket hypothesis: envelope neurons are the "winning ticket"

---

## Research Team Directive

Each direction should be pursued by a team that:

1. **States 3-5 precise lemmas** that decompose the conjecture into formally provable pieces
2. **Validates computationally** with examples in Python before attempting formal proofs
3. **Builds on existing verified infrastructure** — do not re-prove what is already available
4. **Identifies the bridge theorems** in the existing catalog that provide the most leverage
5. **Iterates weekly** with updated proof attempts and counterexample searches

Priority order: Direction 2 (Myhill-Nerode) first (most likely to yield to current methods), then Direction 3 (Hankel), then Direction 5 (neural pruning, highest impact), then Directions 1 and 4.

---

## Cross-Cutting Themes

All five directions share common technical challenges:

- **Genericity management**: defining and verifying the right "general position" conditions
- **Strict witness extraction**: converting weak minimizers to unique strict minimizers
- **Compositional structure**: building multi-step arguments from single-step lemmas
- **Finite vs infinite domains**: handling evaluation on ℕ, ℤ, ℝ, or Σ*
- **Computational complexity**: ensuring that the canonical forms are efficiently computable

The envelope canonicalization theorem provides the template: define the semantic core, prove it sufficient, prove it necessary, conclude minimality. Each direction instantiates this template in a richer setting.
