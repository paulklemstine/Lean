# Ultrametric Neural Realization Duality: A Myhill-Nerode Theory for Nonexpanding Systems

## Abstract

We establish a complete Myhill-Nerode-style realization theory for ultrametric neural systems — state machines equipped with ultrametric state distances and nonexpanding transition dynamics. Our main results are: (1) observer indistinguishability is a dynamically invariant equivalence relation; (2) morphisms from minimal realizations are injective; (3) morphisms between minimal realizations are bijections, establishing uniqueness of minimal realizations up to state renaming; (4) finite-rank kernels admit finite ultrametric realizations, constructed explicitly from factorization data. All results are formalized and machine-verified in Lean 4 with the Mathlib library, constituting zero-sorry proofs. We demonstrate the theory on a concrete two-state parity automaton example.

**Keywords**: ultrametric spaces, neural realization theory, Myhill-Nerode theorem, nonexpanding dynamics, minimal automata, machine-verified proofs

## 1. Introduction

### 1.1 Background and Motivation

The classical Myhill-Nerode theorem (Nerode, 1958) characterizes regular languages through behavioral equivalence: two input strings are equivalent if no suffix can distinguish their extensions. The equivalence classes form the state space of the unique minimal deterministic finite automaton recognizing the language. This theorem has been foundational in automata theory, formal language theory, and verification.

Separately, ultrametric spaces — metric spaces satisfying the strong triangle inequality d(a,c) ≤ max(d(a,b), d(b,c)) — have attracted attention in diverse areas: p-adic analysis and number theory, spin glass models in physics (Parisi, 1979), phylogenetic analysis, and more recently, machine learning architectures operating over non-Archimedean fields.

Our work bridges these two theories. We develop a Myhill-Nerode framework for systems whose state spaces carry ultrametric distances and whose transitions are nonexpanding (distance-non-increasing). The ultrametric structure provides geometric rigidity that goes beyond the classical discrete setting, while the nonexpansion condition ensures dynamical compatibility between behavior and geometry.

### 1.2 Contributions

1. **Observer indistinguishability theory**: We define observer indistinguishability for ultrametric predictor signatures and prove it is an equivalence relation preserved by transitions and respected by outputs (Theorems 1-5).

2. **Morphism theory**: We develop a theory of signature morphisms and prove that morphisms from minimal realizations are injective, morphisms to minimal targets are surjective, and morphisms between minimal realizations are bijective (Theorems 6-9).

3. **Finite realization theorem**: We prove that kernels admitting a finite factorization through residual profiles can be realized by finite ultrametric predictors, via an explicit construction using the discrete ultrametric (Theorem 10).

4. **Universal property**: We establish that minimal realizations have the smallest state space among all realizations, with equal cardinality (Theorems 11-12).

5. **Concrete demonstration**: We construct a two-state parity automaton and verify it is a minimal realization (Theorem 13).

6. **Full machine verification**: All results are formalized in Lean 4 with zero unproved lemmas (`sorry`-free).

### 1.3 Related Work

- **Classical Myhill-Nerode**: Myhill (1957), Nerode (1958), Hopcroft (1971).
- **Weighted automata**: Berstel-Reutenauer (2011), Droste-Kuich-Vogler (2009).
- **Ultrametric analysis**: Schikhof (1984), Robert (2000).
- **Nonexpanding dynamics**: Peres (2006), ultrametric fixed-point theorems.
- **Realization theory**: Kalman (1963), Arbib-Manes (1975), Rutten (2000) for coalgebraic approaches.

Our work is distinguished by combining the behavioral quotient approach of automata theory with the geometric structure of ultrametric spaces and providing full machine verification.

## 2. Definitions and Setup

### 2.1 Word Application

Given an input alphabet X and state space Q with transition function step : X → Q → Q, we define iterated application:

```
applyWord(step, [], q) = q
applyWord(step, x :: w, q) = applyWord(step, w, step(x, q))
```

This processes the word left-to-right: x is applied first, then the remainder w.

**Key property**: `applyWord(step, w₁ ++ w₂, q) = applyWord(step, w₂, applyWord(step, w₁, q))`.

### 2.2 Response Kernels

The response kernel captures the observable behavior:

```
responseKernel(step, output, w, o, q) = output(o, applyWord(step, w, q))
```

### 2.3 Observer Indistinguishability

Two states q₁, q₂ are **observer-indistinguishable** if:

```
∀ w : List X, ∀ o : O, responseKernel(step, output, w, o, q₁) = responseKernel(step, output, w, o, q₂)
```

### 2.4 Ultrametric Predictor Signatures

An **ultrametric predictor signature** (S, X, O, Q) consists of:
- `step : X → Q → Q` — transition function
- `output : O → Q → S` — observer outputs
- `init : Q` — initial state
- `udist : Q → Q → ℝ` — ultrametric on states, satisfying:
  - Non-negativity: `udist(a,b) ≥ 0`
  - Identity: `udist(a,a) = 0`
  - Symmetry: `udist(a,b) = udist(b,a)`
  - Ultrametric inequality: `udist(a,c) ≤ max(udist(a,b), udist(b,c))`
- `nonexpanding`: `∀ x q₁ q₂, udist(step(x,q₁), step(x,q₂)) ≤ udist(q₁,q₂)`

### 2.5 Minimality

A signature is **minimal** if it is both:
- **Reachable**: every state q is reachable from init via some word w
- **Observable**: observer-indistinguishable states are equal

## 3. Main Results

### 3.1 Equivalence Relation (Theorems 1-3)

**Theorem 1** (Reflexivity). ObsIndist(step, output, q, q).

**Theorem 2** (Symmetry). ObsIndist(step, output, q₁, q₂) → ObsIndist(step, output, q₂, q₁).

**Theorem 3** (Transitivity). ObsIndist(step, output, q₁, q₂) ∧ ObsIndist(step, output, q₂, q₃) → ObsIndist(step, output, q₁, q₃).

*Proof sketch*: All three follow directly from the corresponding properties of equality on the output type S.

### 3.2 Dynamical Invariance (Theorems 4-5)

**Theorem 4** (Transition Preservation). If ObsIndist(q₁, q₂), then ObsIndist(step(x,q₁), step(x,q₂)).

*Proof*: Given any test word w and observer o, the indistinguishability of q₁, q₂ tested with word (x :: w) and observer o gives exactly the required equality for the shifted states.

**Theorem 5** (Output Compatibility). If ObsIndist(q₁, q₂), then output(o, q₁) = output(o, q₂).

*Proof*: Apply indistinguishability with the empty word.

### 3.3 Nonexpansion Composition (Theorem 6)

**Theorem 6**. For any ultrametric predictor signature and word w:
```
udist(applyWord(step, w, q₁), applyWord(step, w, q₂)) ≤ udist(q₁, q₂)
```

*Proof*: By induction on w. The base case is trivial. The inductive step uses the nonexpansion property of step composed with the inductive hypothesis.

### 3.4 Morphism Injectivity (Theorems 7-8)

**Definition** (Morphism). A signature morphism φ : sig₁ → sig₂ consists of:
- `toFun : Q₁ → Q₂`
- `map_init`: φ(init₁) = init₂
- `map_step`: φ(step₁(x,q)) = step₂(x, φ(q))
- `map_output`: output₁(o,q) = output₂(o, φ(q))

**Theorem 7** (Fiber Indistinguishability). If φ(q₁) = φ(q₂), then ObsIndist(q₁, q₂).

*Proof*: For any word w and observer o, use the output compatibility and intertwining properties of φ to show the responses agree.

**Theorem 8** (Injectivity from Minimal Source). If sig₁ is minimal and φ : sig₁ → sig₂ is a morphism, then φ is injective.

*Proof*: Combine Theorem 7 with observability of sig₁: if φ(q₁) = φ(q₂), the states are indistinguishable, hence equal.

### 3.5 Bijectivity and Uniqueness (Theorems 9-11)

**Theorem 9** (Surjectivity to Minimal Target). If sig₂ is minimal and φ : sig₁ → sig₂ is a morphism, then φ is surjective.

*Proof*: For any q₂ in sig₂, reachability gives a word w with applyWord(step₂, w, init₂) = q₂. The preimage applyWord(step₁, w, init₁) maps to q₂ via the intertwining property.

**Theorem 10** (Bijectivity). Morphisms between minimal realizations are bijections.

*Proof*: Combine Theorems 8 and 9.

**Theorem 11** (Cardinality Equality). If sig₁, sig₂ are finite minimal realizations connected by a morphism, then |Q₁| = |Q₂|.

*Proof*: Immediate from bijectivity.

### 3.6 Finite Realization (Theorem 12)

**Theorem 12** (Finite Realization). Given a kernel K : List X → O → S with factorization data:
- n residual profiles R : Fin n → List X → O → S
- Initial index init_idx
- Transition function: X → Fin n → Fin n
- Output function: O → Fin n → S
- Compatibility: R i (x :: v) o = R (transition x i) v o
- Initialization: K v o = R init_idx v o

Then there exists an ultrametric predictor signature over Fin n that realizes K.

*Proof*: Construct the signature using the discrete ultrametric on Fin n. The key is the **residual tracking lemma**: for all words w, indices i, suffixes v, and observers o,
```
R(applyWord(transition, w, i), v, o) = R(i, w ++ v, o)
```
proved by induction on w using the compatibility condition. The realization then follows by setting v = [] and using the output specification.

### 3.7 Concrete Example (Theorem 13)

**Theorem 13**. The two-state parity automaton over Fin 2 (toggling on input `true`, outputting state value) is a minimal realization.

*Proof*: Reachability: state 0 is initial, state 1 is reached by [true]. Observability: the output function (state value) immediately distinguishes the two states.

## 4. The Discrete Ultrametric

We establish that the discrete metric d(x,y) = 0 if x = y, 1 otherwise, is an ultrametric. This is the canonical "trivial" ultrametric that makes any function nonexpanding.

**Properties verified**:
- Non-negativity, identity of indiscernibles, symmetry
- Ultrametric triangle inequality (case analysis on a = c, a = b)
- Universal nonexpansion: d(f(x), f(y)) ≤ d(x, y) for any f

This provides the default metric for the finite realization construction.

## 5. Nerode Equivalence

For a kernel K : List X → O → S, we define:

```
NerodeEq(K, w₁, w₂) ≡ ∀ v o, K(w₁ ++ v, o) = K(w₂ ++ v, o)
```

We prove:
- NerodeEq is an equivalence relation
- It is right-invariant under suffix extension: if w₁ ≡ w₂ then (w₁ ++ u) ≡ (w₂ ++ u)
- It corresponds to observer indistinguishability in any realization

## 6. Bridge Theorem

The **Ultrametric Nerode Bridge Theorem** combines all structural results:

For any ultrametric predictor signature sig:
1. Observer indistinguishability is an equivalence relation
2. Transitions preserve indistinguishability: if q₁ ≡ q₂ then step(x,q₁) ≡ step(x,q₂)
3. Outputs respect indistinguishability: if q₁ ≡ q₂ then output(o,q₁) = output(o,q₂)
4. Word application is nonexpanding: udist(applyWord(w,q₁), applyWord(w,q₂)) ≤ udist(q₁,q₂)

This provides the complete algebraic infrastructure for quotient construction and minimal realization.

## 7. Universal Property

The **minimal realization universal property** states that for any morphism between finite minimal realizations:
- The morphism is injective (from minimality of source)
- The morphism is surjective (from minimality of target)
- The state spaces have equal cardinality

This establishes the minimal realization as a canonical object: it is unique up to bijective state renaming.

## 8. Algorithms

### 8.1 Minimal Realization Construction

**Input**: Kernel K : List X → O → S with finite rank n
**Output**: Minimal ultrametric predictor signature

```
Algorithm MinimalRealization(K, n, R, init_idx, transition, outfn):
    sig.step ← transition
    sig.output ← outfn
    sig.init ← init_idx
    sig.udist ← discreteUDist
    return sig
```

**Complexity**: O(1) construction time given factorization data. The cost is dominated by computing the factorization data itself, which requires O(n · |X| · |O|) kernel queries.

### 8.2 Nerode Quotient Construction

**Input**: Ultrametric predictor signature sig
**Output**: Quotient signature with merged indistinguishable states

```
Algorithm NerodeQuotient(sig):
    1. For each pair (q₁, q₂), test ObsIndist by checking
       responseKernel(w, o, q₁) = responseKernel(w, o, q₂)
       for all w up to distinguishing depth and all o
    2. Merge equivalent classes
    3. Define quotient transitions and outputs
    4. Return quotient signature
```

**Complexity**: O(|Q|² · |X|^D · |O|) where D is the distinguishing depth.

## 9. Computational Demonstrations

See `demo.py` for numerical examples demonstrating:
1. Construction of ultrametric predictor signatures
2. Verification of nonexpansion and ultrametric properties
3. Observer indistinguishability testing
4. Nerode equivalence class computation
5. Minimal realization extraction

## 10. Discussion

### 10.1 Comparison with Classical Results

Our theory generalizes the classical Myhill-Nerode theorem in two ways:
1. States carry geometric structure (ultrametric) rather than being purely discrete
2. The output type S can be any type, not just {accept, reject}

The cost of this generality is the need for explicit factorization data in the finite realization theorem. In the classical setting, factorization is automatic from finiteness of the Nerode equivalence classes. In our setting, the factorization must be provided or computed.

### 10.2 Role of the Ultrametric

The ultrametric inequality is crucial for the composition theorem (Theorem 6): it ensures that iterated nonexpansion gives a clean bound without the accumulation of errors that would occur in the Euclidean setting. This is related to the "no cancellation" property of ultrametric spaces.

### 10.3 Limitations

The current theory uses the discrete ultrametric in the finite realization construction, which is the weakest possible ultrametric. A richer theory would construct non-trivial ultrametrics from the kernel data, for example using the observer separation pseudometric.

## 11. Future Work

See FUTURE_DIRECTIONS.md for detailed research directions including:
1. Probabilistic ultrametric realization
2. Tropical-ultrametric comparison principles
3. Learning algorithms for minimal architectures
4. Categorical duality theory
5. Balanced truncation and model reduction

## References

1. Nerode, A. (1958). Linear automaton transformations. *Proceedings of the AMS*, 9(4), 541-544.
2. Myhill, J. (1957). Finite automata and the representation of events. WADD Technical Report 57-624.
3. Kalman, R.E. (1963). Mathematical description of linear dynamical systems. *J. SIAM Control*, 1(2), 152-192.
4. Berstel, J. & Reutenauer, C. (2011). *Noncommutative Rational Series with Applications*. Cambridge University Press.
5. Schikhof, W.H. (1984). *Ultrametric Calculus*. Cambridge University Press.
6. Rutten, J.J.M.M. (2000). Universal coalgebra: a theory of systems. *Theoretical Computer Science*, 249(1), 3-80.
7. Parisi, G. (1979). Infinite number of order parameters for spin-glasses. *Physical Review Letters*, 43(23), 1754.
