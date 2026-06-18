# Arrow-Depth Is Insufficient: A Structural Complexity Theory of Semantic State Bounds for Simple Types

## Abstract

We study the semantic state complexity of simple types — the inductively
defined types built from a single base type `o` and a binary arrow constructor
`A → B`. To each type `A` we associate a **state bound** `T(A)`, defined by
`T(o) = 1` and `T(A → B) = (T(A) + 1)(T(B) + 1)`, which upper-bounds the number
of observationally distinct (bisimulation-minimized) semantic states reachable
by computations of that type. Our central result is a precise characterization
of *which structural parameter governs `T`*. We prove that `T` coincides with an
independently defined arithmetic complexity measure `C`, and we then establish a
sharp dichotomy between two structural parameters. Arrow **depth** is provably
insufficient: although for *chain types* (right-spined arrows with base-typed
arguments) `T` is singly exponential in depth, `T(A) ≤ 3^{depth(A)+1}`, there is
a family of *bushy types* of depth `n` whose state bound satisfies
`T(bushy(n)) + 1 ≥ 2^{2^n}`, doubly exponential in the depth. Consequently we
prove an **impossibility theorem**: no constant `c` yields a uniform bound
`T(A) ≤ c^{depth(A)+1}`. By contrast, type **size** controls `T` cleanly and
universally: `T(A) + 1 ≤ 2^{size(A)}` for all `A`, equivalently
`T(A) ≤ predictedBound(A) := 2^{size(A)} - 1`. We complement these with
structural identities — `2·width(A) + 1 = size(A)`, `depth = width` on chains,
exact bushy invariants `width(bushy(n)) = 2^n - 1` and
`size(bushy(n)) = 2^{n+1} - 1` — and a combined depth-only upper bound
`T(A) + 1 ≤ 2^{2^{depth(A)+1} - 1}`. The picture that emerges is that semantic
complexity is driven by **breadth (size/width), not height (depth)**, with depth
controlling complexity exactly on the maximally narrow chain types. All results
have been formally verified.

**Keywords.** simple types, semantic state complexity, bisimulation
minimization, canonical quotient, arrow depth, structural parameterization,
fixed-parameter intractability, descriptive complexity, automata state
explosion, width–depth tradeoff.

---

## 1. Introduction

A recurring methodological question in the analysis of structured objects is:
*which single structural parameter controls the quantity I care about?* For
trees one might track height or total size; for circuits, depth or gate count;
for formulas, quantifier rank or length. Choosing the wrong parameter leads to
bounds that are either vacuous or unprovable. This paper answers the question
decisively for one fundamental setting: the semantic state complexity of simple
types.

Simple types are the types of the simply typed λ-calculus: a base type `o` and
arrow types `A → B`. They are the skeleton of typed functional programming and
of higher-order logic. When a typed term computes, it passes through
intermediate configurations; identifying configurations that no observation can
distinguish yields a canonical, minimal state space — exactly the
Myhill–Nerode / bisimulation-minimization construction familiar from automata
theory, lifted to higher order. The **state bound** `T(A)` is a closed-form,
purely type-directed ceiling on the size of this minimal state space across all
terms of type `A`.

Two structural measures of a type compete to explain `T`: its **depth** (the
nesting level of arrows) and its **size** (the total number of constructors). The
former is the more visually salient and is the parameter most analysts reach for
first. Our main contribution is to show, with full proofs, that **depth is
inadequate and size is exactly right**.

### 1.1 Contributions

1. **State bound = complexity** (Theorem 3.1). `T(A) = C(A)` for all `A`, where
   `C` is the independently motivated arithmetic complexity measure with the same
   recurrence. Behavioral and arithmetic complexity coincide.
2. **Depth is controlled on chains** (Theorem 4.2). For every chain type,
   `T(A) ≤ 3^{depth(A)+1}` — singly exponential.
3. **Bushy double-exponential lower bound** (Theorem 5.3). The bushy family has
   depth `bushy(n) = n` yet `T(bushy(n)) + 1 ≥ 2^{2^n}`.
4. **Impossibility theorem** (Theorem 6.1). No constant `c` satisfies
   `∀A, T(A) ≤ c^{depth(A)+1}`.
5. **Size-exponential universal bound** (Theorem 7.1). `T(A) + 1 ≤ 2^{size(A)}`
   for all `A`; hence `T(A) ≤ predictedBound(A) = 2^{size(A)} - 1`.
6. **Structural reconciliation** (Section 8). `2·width(A) + 1 = size(A)`;
   `depth = width` on chains; exact bushy invariants; and a combined
   depth-only ceiling `T(A) + 1 ≤ 2^{2^{depth(A)+1} - 1}`.

All statements have been mechanically checked.

---

## 2. Preliminaries: Types and Their Measures

### 2.1 Simple types

**Definition 2.1 (Types).** The set of types `Ty` is generated inductively by
the base type `o` and the arrow constructor:
```
A, B ::= o | A → B.
```

Throughout we write `o` for the base type and `A → B` for the arrow type
(`Ty.arrow A B`).

**Definition 2.2 (Depth).** `depth : Ty → ℕ` is
```
depth(o)     = 0,
depth(A → B) = 1 + max(depth(A), depth(B)).
```

**Definition 2.3 (Size).** `size : Ty → ℕ` counts all constructors:
```
size(o)     = 1,
size(A → B) = 1 + size(A) + size(B).
```

**Definition 2.4 (Arrow width).** `width : Ty → ℕ` counts arrows only:
```
width(o)     = 0,
width(A → B) = 1 + width(A) + width(B).
```

**Definition 2.5 (Complexity).** The arithmetic complexity `C : Ty → ℕ` is
```
C(o)     = 1,
C(A → B) = (C(A) + 1)(C(B) + 1).
```
Note `C(A) > 0` for all `A` (a trivial induction; arrow types are products of
positive factors).

### 2.2 The state bound

The state bound is the type-directed ceiling on minimal semantic state count.

**Definition 2.6 (State bound).** `T : Ty → ℕ` is
```
T(o)     = 1,
T(A → B) = (T(A) + 1)(T(B) + 1).
```

Operationally, `T(A)` bounds the canonical (bisimulation-minimized) quotient
size of the reduction state space of any closed term of type `A`: the base type
admits a single observational state, and an arrow type combines the states of
its domain and codomain multiplicatively, with one extra slot on each side for
the "not-yet-applied" / "fully-evaluated" sentinel. The `+1`-then-multiply shape
is exactly what makes higher-order state spaces explode, and it is the source of
every phenomenon in this paper.

---

## 3. The State Bound Is the Complexity Measure

**Theorem 3.1 (`typeStateBound_eq_complexity`).** For every type `A`,
`T(A) = C(A)`.

*Proof sketch.* Structural induction on `A`. The base case is `T(o) = 1 = C(o)`.
For `A → B`, both sides unfold to `(·(A) + 1)(·(B) + 1)`; substituting the two
induction hypotheses `T(A) = C(A)` and `T(B) = C(B)` closes the goal. ∎

This identification is more than cosmetic: it lets us transport every fact about
the syntactic measure `C` to the semantic quantity `T` and vice versa. In
particular all bounds below may be read either as statements about minimal state
counts or about arithmetic complexity scores.

**Proposition 3.2 (`depth_le_complexity`).** `depth(A) ≤ C(A)` for all `A`.

*Proof sketch.* Induction on `A`. Base: `0 ≤ 1`. Arrow: `depth(A → B) =
1 + max(depth A, depth B)`, while `C(A → B) = (C(A)+1)(C(B)+1)`. Using
`C(A), C(B) ≥ 1` (positivity) and the induction hypotheses, the product
dominates `1 + max(depth A, depth B)`. ∎

Thus depth is *never larger* than complexity; the interesting question is how
much *smaller* it can be — and the answer is: unboundedly.

---

## 4. Chain Types: Depth Suffices on the Narrow Frontier

**Definition 4.1 (Chain type).** `ChainTy : Ty → Prop` is the predicate
```
ChainTy(o)     = True,
ChainTy(A → B) = (A = o) ∧ ChainTy(B).
```
A chain type is a right-spined pipeline `o → o → ⋯ → o`. These are the types of
ordinary curried first-order functions and have minimal branching at every
level.

**Theorem 4.2 (`typeStateBound_le_exp_depth_of_chain`).** For every chain type
`A`, `T(A) ≤ 3^{depth(A)+1}`.

*Proof sketch.* Induction on the chain structure. For `A = o`, `T(o) = 1 ≤ 3`.
For `A = o → B` with `ChainTy(B)`, the recurrence gives
`T(o → B) = (T(o)+1)(T(B)+1) = 2(T(B)+1)`. Since `depth(o → B) = depth(B) + 1`,
the induction hypothesis `T(B) ≤ 3^{depth(B)+1}` yields
`T(o → B) = 2T(B) + 2 ≤ 2·3^{depth(B)+1} + 2 ≤ 3^{depth(B)+2}`, where the last
step uses `2x + 2 ≤ 3x` for `x = 3^{depth(B)+1} ≥ 3`. ∎

The sharp asymptotics are `T(A) = 3·2^{depth(A)} - 2` for a chain of the given
depth, so the `3^{depth+1}` bound is loose but of the correct (single
exponential) order. The moral: **on chains, depth genuinely controls `T`.** As
we now show, this is special to chains.

---

## 5. Bushy Types: A Double-Exponential Engine at Fixed Depth

**Definition 5.1 (Bushy types).** `bushy : ℕ → Ty` is
```
bushy(0)   = o,
bushy(n+1) = bushy(n) → bushy(n).
```
`bushy(n)` is the complete (balanced) binary arrow tree of height `n`.

**Lemma 5.2a (`bushy_depth_eq`).** `depth(bushy(n)) = n`.

*Proof sketch.* Induction; `depth(bushy(n+1)) = 1 + max(n, n) = n + 1`. ∎

**Lemma 5.2b (`bushy_tsb_recurrence`).** `T(bushy(n+1)) = (T(bushy(n)) + 1)^2`.

*Proof sketch.* Direct from the arrow recurrence with both arguments equal:
`T(X → X) = (T(X)+1)(T(X)+1) = (T(X)+1)^2`. ∎

**Theorem 5.3 (`bushy_tsb_plus_one_ge`).** `2^{2^n} ≤ T(bushy(n)) + 1`.

*Proof sketch.* Let `b_n = T(bushy(n)) + 1`. Then `b_0 = 2 = 2^{2^0}`, and by
Lemma 5.2b, `b_{n+1} = (T(bushy(n)) + 1)^2 + 1 = b_n^2 + 1 ≥ b_n^2`. Squaring
the inductive estimate `b_n ≥ 2^{2^n}` gives
`b_{n+1} ≥ (2^{2^n})^2 = 2^{2^{n+1}}`. ∎

Numerically `T(bushy(n)) = 1, 4, 25, 676, 457653, …`; the values square (plus
one) at each step, the signature of double-exponential growth. The decisive
contrast with Theorem 4.2 is that `bushy(n)` has depth exactly `n` — identical
to a chain of length `n` — yet its state bound towers far above any single
exponential in `n`.

---

## 6. The Impossibility Theorem

**Theorem 6.1 (`not_exists_uniform_exp_depth_bound`).** There is no constant
`c ∈ ℕ` such that `T(A) ≤ c^{depth(A)+1}` for all types `A`.

*Proof sketch.* Suppose such a `c` exists. Restricting to the bushy family and
using `depth(bushy(n)) = n` gives `T(bushy(n)) ≤ c^{n+1}` for all `n`. Combined
with Theorem 5.3,
```
2^{2^n} ≤ T(bushy(n)) + 1 ≤ c^{n+1} + 1.
```
Since `c ≤ 2^c` (a standard fact, `le_two_pow`), we have
`c^{n+1} ≤ 2^{c(n+1)}`, and absorbing the `+1` gives
`c^{n+1} + 1 ≤ 2·2^{c(n+1)} = 2^{c(n+1)+1}`. Hence
`2^{2^n} ≤ 2^{c(n+1)+1}`, and monotonicity of `x ↦ 2^x` yields the polynomial
inequality `2^n ≤ c(n+1) + 1 ≤ (c+1)(n+1)` for *all* `n`. But a single
exponential dominates any linear function: evaluating at `n = 2(c+1)` (using
that `2^n` exceeds `(c+1)(n+1)` once `n` is large enough — formally
`exp_eventually_dominates_linear`) produces a contradiction. ∎

The proof isolates the exact mechanism of failure: a depth-only bound is at best
single-exponential in depth (`c^{depth+1}`), whereas the bushy witnesses are
double-exponential in depth. No choice of base `c`, however astronomically
large, can close a gap of one exponential level. **Depth is structurally
incapable of bounding `T`.**

---

## 7. Size: The Correct Controlling Parameter

**Theorem 7.1 (`typeStateBound_add_one_le_two_pow_size`).** For every type `A`,
`T(A) + 1 ≤ 2^{size(A)}`.

*Proof sketch.* Induction on `A`. Base: `T(o) + 1 = 2 = 2^{size(o)} = 2^1`.
Arrow: by the recurrence,
```
T(A → B) + 1 = (T(A)+1)(T(B)+1) + 1 ≤ 2^{size A}·2^{size B} + 1
            = 2^{size A + size B} + 1 ≤ 2^{1 + size A + size B} = 2^{size(A→B)},
```
where the first inequality is the product of the two induction hypotheses and
the final inequality holds because `2^{m} + 1 ≤ 2^{m+1}` for `m ≥ 1`. ∎

**Corollary 7.2 (`typeStateBound_le_predictedBound`).** Define the certified
**predicted bound** `predictedBound(A) := 2^{size(A)} - 1`. Then
`T(A) ≤ predictedBound(A)` for all `A`.

*Proof sketch.* Immediate from Theorem 7.1: `T(A) + 1 ≤ 2^{size A}` gives
`T(A) ≤ 2^{size A} - 1` (natural-number subtraction is safe since
`2^{size A} ≥ 2`). ∎

Theorem 7.1 is universal, exception-free, and tight in order: for the bushy
family it returns `T(bushy(n)) + 1 ≤ 2^{size(bushy(n))} = 2^{2^{n+1}-1}` (using
Lemma 8.4 below), recovering the double exponential in `n` that Theorem 5.3
forces from below. Size succeeds precisely where depth fails because it accounts
for the entire type, breadth included.

---

## 8. Reconciling the Parameters: Width, Size, and Depth

The dichotomy is fully explained by relating the three measures.

**Lemma 8.1 (`arrowWidth_size_relation`).** `2·width(A) + 1 = size(A)`.

*Proof sketch.* Induction; the arrow case is the linear identity
`2(1 + width A + width B) + 1 = 1 + (2 width A + 1) + (2 width B + 1)`. ∎

Thus size and width are affinely equivalent — a size-exponential bound *is* a
width-exponential bound. As a corollary, `width(A) < size(A)`
(`arrowWidth_lt_size`).

**Lemma 8.2 (`chain_depth_eq_arrowWidth`).** On chain types, `depth(A) =
width(A)`.

*Proof sketch.* Induction using `ChainTy`. For `o → B` with `A = o`,
`depth(o → B) = 1 + depth(B)` and `width(o → B) = 1 + width(B)` (since
`width(o) = 0`), so the equality propagates. ∎

Lemma 8.2 explains Theorem 4.2 conceptually: on chains, depth *equals* width,
hence the width-driven bound is also a depth-driven bound. The moment a type
branches, `width > depth` and the equivalence breaks.

**Corollary 8.3 (`chain_complexity_le_exp_depth`).** For chain types,
`C(A) ≤ 3^{depth(A)+1}` (via Theorem 3.1 and Theorem 4.2).

**Lemma 8.4 (Bushy invariants, `bushy_arrowWidth`, `bushy_size`).**
`width(bushy(n)) = 2^n - 1` and `size(bushy(n)) = 2^{n+1} - 1`.

*Proof sketch.* Induction; e.g. `size(bushy(n+1)) = 1 + 2·size(bushy(n)) =
1 + 2(2^{n+1}-1) = 2^{n+2}-1`. ∎

So the bushy types are not merely deep, they are *exponentially wide*
(`width = 2^n - 1`) — and it is this exponential width, fed into the
`2^{size}` ceiling, that produces the `2^{2^n}`-scale behavior. The same family
that breaks the depth bound has honest size large enough to satisfy the size
bound.

**Lemma 8.5 (`size_le_exp_depth`).** `size(A) ≤ 2^{depth(A)+1} - 1` (the
full-binary-tree size bound for a tree of given height).

**Theorem 8.6 (Combined depth ceiling, `typeStateBound_le_double_exp_depth`).**
`T(A) + 1 ≤ 2^{2^{depth(A)+1} - 1}` for all `A`.

*Proof sketch.* Compose Theorem 7.1 with Lemma 8.5:
`T(A) + 1 ≤ 2^{size(A)} ≤ 2^{2^{depth(A)+1}-1}`, using monotonicity of `2^{(·)}`.
∎

Theorem 8.6 closes the loop: depth *can* bound `T`, but only at the
**double-exponential** rate `2^{2^{depth+1}}`, which is exactly the rate the
bushy witnesses attain. A single exponential in depth is impossible (Theorem
6.1); a double exponential in depth is the truth. The unique parameter giving a
*single* exponential bound is size (Theorem 7.1).

---

## 9. Algorithms

The theory is fully constructive and yields three small, exact algorithms over
the inductive type structure.

**Algorithm A — `state_bound(A)`.** Compute `T(A)` by the defining recurrence.
Returns the exact minimal-state ceiling. Runs in time linear in `size(A)`
(treating the big-integer arithmetic as unit cost; values can be
double-exponentially large, so arbitrary-precision integers are required).

**Algorithm B — `predicted_bound(A)`.** Compute `2^{size(A)} - 1`, the certified
size-exponential ceiling, by first computing `size(A)` (linear) and then a single
shift/exponentiation. Theorem 7.1 guarantees `state_bound(A) ≤ predicted_bound(A)`.

**Algorithm C — `regime_classifier(A)`.** Decide whether `A` is in the *tame*
(chain) regime or the *explosive* (branching) regime by testing `ChainTy(A)` and
comparing `depth(A)` with `width(A)`: equality certifies a chain (singly
exponential in depth, Theorem 4.2 / Lemma 8.2); strict inequality certifies
genuine branching, where only the size bound applies.

Pseudocode and reference implementations are provided in `demo.py` and in the
`algorithms` field of the accompanying package.

---

## 10. Applications

**Resource certification for higher-order computation.** When analyzing a typed
program or proof object, one often needs an a-priori ceiling on the number of
intermediate semantic states (for memory allocation, search-space pruning, or
termination guarantees). Theorem 7.1 supplies such a ceiling, `2^{size} - 1`,
computable in linear time directly from the type, with a *proof* that it is never
exceeded. Theorem 6.1 is the matching warning: any tool that bounds resources by
arrow depth alone is unsound, because bushy types defeat every depth-only bound.

**Choosing the right structural parameter.** Beyond types, the result is a clean
case study in parameterized analysis: an intuitive parameter (depth) can be
provably inadequate while a less glamorous one (size/width) is exactly right. The
identity `2·width + 1 = size` and the chain coincidence `depth = width` together
diagnose precisely when the intuitive parameter happens to work (maximal
narrowness) and when it must fail (any branching).

**Automata state explosion, lifted to higher order.** The multiplicative arrow
recurrence is the higher-order analogue of product constructions in automata
theory. The bushy family is the canonical witness that minimization cannot, in
general, tame this explosion at fixed nesting depth — a higher-order echo of
classical state-blowup phenomena.

---

## 11. Discussion

The results assemble into a single sentence: **semantic complexity of simple
types is governed by breadth, not height.** Depth controls `T` if and only if
the type is as narrow as it is tall (a chain), in which case depth and width
coincide; otherwise breadth dominates and depth is, at best, a double-exponential
proxy. The identification `T = C` makes this simultaneously a statement about
behavior (minimal state counts) and about arithmetic (a complexity score), and
the predicted bound `2^{size} - 1` packages it into a one-line, certified,
linear-time computable guarantee.

A pleasant feature is the tightness of the trio of bounds: the *upper* bound
`T + 1 ≤ 2^{size}` (Theorem 7.1), the *depth-parameterized* upper bound
`T + 1 ≤ 2^{2^{depth+1}-1}` (Theorem 8.6), and the bushy *lower* bound
`T(bushy(n)) + 1 ≥ 2^{2^n}` (Theorem 5.3) pin the growth regime from both sides,
in both the size and the depth parameters.

---

## 12. Future Directions

A companion line of work extends the spirit of these structural-complexity and
certification results into the setting of *certified novelty detection in metric
spaces*. The following directions are stated as falsifiable conjectures, each
with a concrete formalization target.

1. **Quantitative packing capacity from disjoint balls.** Building on a
   disjoint-ball lemma (mutually `ε`-separated points induce pairwise-disjoint
   `ε/2`-balls), conjecture that in a finite-measure region `B` the number of
   mutually `ε`-separated points is bounded by
   `volume(B_{ε/2}) / volume(ball(ε/2))`, specializing in `ℝ^d` to
   `(2R/ε + 1)^d` for a radius-`R` ball. The key insight is that separation
   converts to a disjoint union of equal-radius balls, so measure additivity
   plus monotonicity turns a qualitative packing predicate into a hard
   cardinality ceiling on coexisting "novel" outputs.

2. **Exact packing in ultrametric spaces.** Under the strong triangle
   inequality, every `ε`-ball is clopen and distinct `ε`-balls are equal or
   disjoint, so "within `ε`" is an equivalence relation and the ball cover is a
   genuine partition. The key insight is that the Euclidean curse-of-dimension
   slack vanishes: the packing count becomes exact, and the disjointness lemma
   upgrades to a biconditional.

3. **Bi-Lipschitz faithfulness of novelty embeddings.** With one-sided
   transport bounds in hand, conjecture the packaged corollary that an
   `AntilipschitzWith K₁` / `LipschitzWith K₂` embedding `f` sends an `ε`-novel
   point to one whose exact novelty score lies in `[ε/K₁, K₂·score]`. The key
   insight is that bi-Lipschitz maps contract and expand distances by bounded
   factors, so novelty thresholds scale predictably and embeddings neither
   destroy nor manufacture novelty.

4. **Hierarchical novelty via ultrametric trees.** For hierarchically
   structured similarity (e.g. theorems about groups closer to each other than
   to topology), the canonical metric is an ultrametric whose `ε`-balls are tree
   nodes at height `ε`. The key insight is that mutual separation decomposes into
   independent subtree problems, turning certification into a tree search that
   sidesteps dimensionality.

5. **Compositional novelty for structured proofs.** For product metric spaces
   with the `L²` metric, conjecture that total and component novelty satisfy a
   Pythagorean relation `ε² ≤ ε₁² + ε₂²`, enabling modular certification where
   each component is certified independently. The key insight is that product
   metrics decompose certification into independent sub-problems with tight,
   composable bounds.

---

## 13. Conclusion

We have given a complete, formally verified structural complexity theory for the
semantic state bound `T` of simple types. The state bound equals the arithmetic
complexity measure; it is singly exponential in depth on chains but doubly
exponential in depth on bushy types; no constant base yields a uniform
depth-only bound; and size delivers a universal, tight, linear-time-computable
ceiling `T(A) + 1 ≤ 2^{size(A)}`. Depth is height, size is breadth, and the
explosion lives in breadth.
