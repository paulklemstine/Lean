# Complementation Orbits in Finite Framed Jigsaw Assembly Spaces

## Abstract

We study global tab–blank complementation for finite framed jigsaw puzzles. The geometric input is deliberately minimal: a puzzle has a finite set of complete assemblies, a complemented puzzle is obtained by reversing all non-flat edge polarities, and this operation induces a bijection between the two complete assembly spaces. From this input we derive the full orbit structure on their tagged disjoint union. The induced complement map is an involution, has no fixed points, and partitions the combined space into two-element orbits. Hence the original and complemented assembly spaces have equal cardinality, while their tagged union has even cardinality. Contrary to a natural preliminary conjecture, no non-self-duality hypothesis is needed: even when a puzzle is isomorphic to its complement, the side tag changes under complementation and rules out fixed points. A singleton self-dual system demonstrates the sharp distinction between a tagged coproduct and an untagged identification. We also give enumeration and validation algorithms, explain the role of the result in parsimonious reductions and counting problems, and identify the geometric realization of the assembly bijection as the principal next step.

## 1. Introduction

A framed edge-matching jigsaw consists of pieces whose sides carry local compatibility data. In the motivating model, every side is flat, a colored tab, or a colored blank. A tab fits a blank when their colors agree; equal polarities do not fit. Pieces may be constrained not to rotate, and a fixed rectangular frame prescribes the exterior boundary. Such systems are geometric constraint networks: a complete assembly is a global witness assembled from locally compatible contacts.

Global complementation reverses the polarity of every non-flat edge. Tabs become blanks, blanks become tabs, and colors and positions are retained. Since complementing both edges at an interior contact preserves the relation “opposite polarity with equal color,” one expects complete assemblies of a puzzle to correspond to complete assemblies of its complement. The essential geometric task in any concrete model is to establish this correspondence as a bijection.

This paper isolates and solves the consequences once that bijection is available. The isolation is useful for two reasons. First, it separates model-dependent geometry from model-independent orbit theory. Second, it exposes a subtle error in an otherwise plausible conjecture: freeness of complementation on the combined solution space does not require the puzzle to be non-self-dual, provided that the combination is a tagged disjoint union.

The principal results are as follows.

1. Complementation on the tagged union is an involution.
2. It has no fixed points because it changes the side tag.
3. Every orbit consists of exactly two elements.
4. The two assembly spaces have equal finite cardinality.
5. Their tagged union has even cardinality.
6. All five conclusions remain valid for self-dual puzzles.

The distinction between tagged and untagged spaces is mathematically decisive. If the original and complemented copies are identified through a chosen self-duality, fixed points may appear after identification. Before quotienting, the tags force a free action.

The argument belongs to the elementary theory of finite involutions, yet it has consequences for geometric counting, parsimonious reductions, exhaustive-search validation, and symmetry handling. It also identifies precisely what must be proved in a future concrete treatment of colored, non-rotatable square pieces: a polynomially describable, multiplicity-respecting bijection between complete placements.

## 2. Framed puzzles and assembly spaces

We begin with definitions broad enough to cover many geometric encodings.

### Definition 2.1 (Finite framed puzzle system)

A **finite framed puzzle system** consists of:

- a collection $\mathcal P$ of puzzles;
- for each puzzle $P\in\mathcal P$, a finite set $A(P)$ of complete framed assemblies;
- a complement operation $P\mapsto P^c$ on puzzles;
- for each $P$, a bijection

$$
c_P:A(P)\longrightarrow A(P^c);
$$

- the requirement that puzzle complementation has order two, so $(P^c)^c=P$.

The map $c_P$ is called the **assembly-complement bijection**. In a concrete edge puzzle, it is expected to reverse tabs and blanks throughout a completed placement while preserving colors, locations, multiplicities, and flat exterior edges.

The orbit results below require only the displayed bijection. The order-two property on puzzles expresses the intended geometry and ensures that the complementary construction itself is coherent. The inverse of $c_P$ supplies transport from $A(P^c)$ back to $A(P)$ whether or not one separately identifies it with $c_{P^c}$.

### Definition 2.2 (Tagged combined assembly space)

For a fixed puzzle $P$, define

$$
C(P)=\bigl(\{L\}\times A(P)\bigr)\sqcup
\bigl(\{R\}\times A(P^c)\bigr).
$$

The symbols $L$ and $R$ are tags. An element $(L,a)$ records an assembly $a$ of the original puzzle, while $(R,b)$ records an assembly $b$ of the complemented puzzle. Even if the underlying puzzles or assemblies are isomorphic, elements with different tags remain distinct.

### Definition 2.3 (Tagged complement transformation)

Define $T_P:C(P)\to C(P)$ by

$$
T_P(L,a)=(R,c_P(a))
$$

and

$$
T_P(R,b)=(L,c_P^{-1}(b)).
$$

Thus complementation transports an assembly to the opposite side and changes its tag. On the right side, the inverse bijection is used so that a second application returns to the starting point.

### Definition 2.4 (Involution, fixed point, and free action)

A map $T:X\to X$ is an **involution** if $T(T(x))=x$ for every $x\in X$. A point $x$ is a **fixed point** if $T(x)=x$. The involution acts **freely** if it has no fixed points. The orbit of $x$ under an involution is the set

$$
\operatorname{Orb}_T(x)=\{x,T(x)\}.
$$

If $T$ is free, this set has exactly two elements.

## 3. Local geometric motivation

Although our theorems use an abstract bijection, it is helpful to describe the concrete mechanism that should generate it.

Consider a non-rotatable square piece with an ordered edge tuple

$$
(e_N,e_E,e_S,e_W).
$$

Each edge is either flat or carries a pair $(\kappa,\sigma)$, where $\kappa$ is a color and $\sigma\in\{+1,-1\}$ is a polarity. Interpret $+1$ as a tab and $-1$ as a blank. Define edge complementation by

$$
(\kappa,\sigma)^c=(\kappa,-\sigma),
$$

while a flat edge remains flat. Complement a piece componentwise without changing edge order. This is important when pieces cannot rotate: north remains north, east remains east, and so forth.

Two non-flat edges are compatible when their colors agree and their polarities sum to zero. If $(\kappa,\sigma)$ meets $(\kappa,-\sigma)$, then after complementation the pair becomes $(\kappa,-\sigma)$ and $(\kappa,\sigma)$, which is still compatible. Hence simultaneous complementation preserves every interior contact. A consistently complemented frame preserves boundary contacts as well.

This local argument suggests a map on complete placements. To prove it is a bijection in a detailed geometric model, one must additionally verify that piece identities or multiplicities are transported correctly, that no rotations or reflections are introduced, and that the frame convention is preserved. Involutivity then gives injectivity and surjectivity at once: applying the same edgewise operation twice restores every piece and placement.

## 4. Main orbit theorems

### Theorem 4.1 (Involutivity of tagged complementation)

For every puzzle $P$ in a finite framed puzzle system, the transformation $T_P$ is an involution on $C(P)$.

#### Proof sketch

Take an element on the left, $(L,a)$. One application yields $(R,c_P(a))$. The second uses the inverse bijection and gives

$$
T_P^2(L,a)=(L,c_P^{-1}(c_P(a)))=(L,a).
$$

For an element $(R,b)$, the two applications give

$$
T_P^2(R,b)=(R,c_P(c_P^{-1}(b)))=(R,b).
$$

The two cases exhaust the tagged union. Therefore $T_P^2$ is the identity. $\square$

### Theorem 4.2 (Fixed-point freeness)

For every puzzle $P$ and every $x\in C(P)$,

$$
T_P(x)\ne x.
$$

Thus tagged complementation acts freely.

#### Proof sketch

If $x=(L,a)$, then $T_P(x)$ has tag $R$, so the two tagged elements cannot be equal. If $x=(R,b)$, its image has tag $L$ and again cannot equal $x$. No property of $a$, $b$, $P$, or $P^c$ is required beyond membership in the corresponding side. $\square$

This theorem is the conceptual core of the paper. Freeness follows from the coproduct tag rather than from a geometric asymmetry between the puzzle and its complement.

### Theorem 4.3 (Two-element orbit theorem)

For every $x\in C(P)$, the complementation orbit

$$
\operatorname{Orb}_{T_P}(x)=\{x,T_P(x)\}
$$

has cardinality $2$.

#### Proof sketch

An involution can produce only an orbit of size one or two: after $x$ and $T_P(x)$, the next iterate is $x$. By Theorem 4.2, the two displayed elements are distinct. Hence the orbit has exactly two elements. $\square$

### Theorem 4.4 (Equality of assembly counts)

For every finite framed puzzle $P$,

$$
|A(P)|=|A(P^c)|.
$$

#### Proof sketch

The map $c_P$ is a bijection between the two finite sets. Finite sets related by a bijection have equal cardinality. $\square$

### Theorem 4.5 (Parity of the tagged combined space)

For every finite framed puzzle $P$, the cardinality of $C(P)$ is even. More precisely,

$$
|C(P)|=2|A(P)|=2|A(P^c)|.
$$

#### Proof sketch

Cardinality is additive on tagged disjoint unions, so

$$
|C(P)|=|A(P)|+|A(P^c)|.
$$

By Theorem 4.4, the two summands are equal. Therefore

$$
|C(P)|=2|A(P)|,
$$

which is even. Equivalently, Theorem 4.3 partitions $C(P)$ into disjoint two-element orbits. $\square$

### Corollary 4.6 (Orbit count)

The number of complementation orbits in $C(P)$ is exactly $|A(P)|$, and equally $|A(P^c)|$.

#### Proof sketch

Every orbit contains one left-tagged and one right-tagged element. Selecting the left member gives a bijection from the set of orbits to $A(P)$. $\square$

### Corollary 4.7 (Solvability equivalence)

The original puzzle has a complete assembly if and only if its complement has a complete assembly.

#### Proof sketch

A bijection preserves emptiness and nonemptiness. This corollary is weaker than Theorem 4.4 because it forgets the number and identity of witnesses. $\square$

## 5. Self-duality and the role of the coproduct

### Definition 5.1 (Self-dual puzzle)

A puzzle $P$ is **self-dual** if it is isomorphic, under the chosen notion of puzzle equivalence, to its complement $P^c$. Self-duality may arise from relabeling pieces, geometric symmetry, or an explicit identification of the two puzzle descriptions.

A natural but incorrect conjecture is that non-self-duality is needed to ensure that complementation acts freely. The error is that the claim does not specify whether the two solution spaces have first been identified.

### Theorem 5.2 (Freeness does not require non-self-duality)

The tagged complement transformation $T_P$ acts freely on $C(P)$ even when $P$ is self-dual.

#### Proof sketch

The proof is exactly that of Theorem 4.2. Self-duality may identify underlying puzzle structures, but it does not identify the formal tags $L$ and $R$ in the disjoint union. Since $T_P$ exchanges these tags, no tagged element is fixed. $\square$

### Example 5.3 (The self-dual singleton)

Let there be one puzzle $P$, let $P^c=P$, and let its assembly set be the singleton

$$
A(P)=\{\ast\}.
$$

Take $c_P$ to be the identity on this singleton. The puzzle is maximally self-dual. Its tagged combined space is

$$
C(P)=\{(L,\ast),(R,\ast)\},
$$

and complementation swaps the two elements. Thus $|C(P)|=2$ and the action is free.

On the untagged singleton $A(P)$, by contrast, the identity map fixes $\ast$. This example shows that the tag is not cosmetic: it changes the fixed-point theory.

### Proposition 5.4 (Fixed points may appear after untagging)

Suppose $P$ is self-dual and choose a bijection $s:A(P^c)\to A(P)$ to identify the right assembly space with the left one. The induced untagged transformation on $A(P)$ is

$$
U=s\circ c_P.
$$

There is no general reason for $U$ to be fixed-point-free.

#### Proof sketch

In the singleton example, both $s$ and $c_P$ are the identity, so $U$ is the identity and has a fixed point. More generally, fixed points of $U$ satisfy $s(c_P(a))=a$, a condition not excluded by the tagged theory. $\square$

The correct conclusion is therefore precise: complementation is always free on the tagged coproduct, but freeness on a quotient or identified space requires additional hypotheses about the chosen identification.

## 6. Algorithms and computational consequences

### 6.1 Complement transport algorithm

Assume an assembly is represented as a list of $m$ placed pieces, each carrying four ordered edges. The complement transport algorithm preserves every placement and replaces each non-flat edge polarity $\sigma$ by $-\sigma$.

**Input:** a complete assembly of $P$.

**Output:** the corresponding complete assembly of $P^c$.

**Procedure:** traverse all placed pieces; for each ordered edge, leave flat edges unchanged and negate the polarity of colored edges.

With constant-size edge records, the running time is $O(m)$ and the output space is $O(m)$. Applying the procedure twice returns the original representation. If assemblies of $P$ have already been enumerated, this algorithm enumerates those of $P^c$ without further combinatorial search.

### 6.2 Orbit enumeration algorithm

Given explicit lists of $A(P)$ and $A(P^c)$ and a bijection $c_P$, one may enumerate each orbit exactly once by iterating only over $A(P)$. For every $a\in A(P)$, output

$$
\{(L,a),(R,c_P(a))\}.
$$

If evaluating $c_P$ costs $q$, the total running time is $O(|A(P)|q)$ plus output cost. No visited-set is necessary because every orbit contains exactly one left-tagged assembly.

### 6.3 Consistency audit

The theorems yield a practical audit for exhaustive enumeration. Given finite lists and purported forward and inverse complement maps, check:

1. every forward image lies in the right list;
2. every inverse image lies in the left list;
3. each inverse-after-forward composition returns its input;
4. each forward-after-inverse composition returns its input;
5. the two lists have equal length;
6. their combined length is even.

The composition checks establish bijectivity directly. The count checks are then redundant mathematically but useful for detecting implementation or data errors. For hashable canonical assembly encodings, membership and duplicate checks can be performed in expected linear time in the total number of listed assemblies, apart from the cost of complement evaluation.

### 6.4 Small finite instances

If either assembly space has size $n$, the exact formulas are

$$
|A(P^c)|=n,\qquad |C(P)|=2n,\qquad
|C(P)/\langle T_P\rangle|=n.
$$

The first six values are:

| $n$ | $|A(P^c)|$ | $|C(P)|$ | number of orbits |
|---:|---:|---:|---:|
| $0$ | $0$ | $0$ | $0$ |
| $1$ | $1$ | $2$ | $1$ |
| $2$ | $2$ | $4$ | $2$ |
| $3$ | $3$ | $6$ | $3$ |
| $4$ | $4$ | $8$ | $4$ |
| $5$ | $5$ | $10$ | $5$ |

These values illustrate a theorem rather than support an extrapolated conjecture.

## 7. Applications

### 7.1 Counting complexity and parsimonious reductions

In decision complexity, a reduction often needs only to preserve whether a witness exists. Counting complexity asks for the number of witnesses. A bijection of witness spaces is therefore stronger than equisatisfiability and is the natural target of a parsimonious reduction.

Suppose a family of framed puzzles encodes Boolean formulas so that complete assemblies correspond bijectively to satisfying assignments. Complementation then transports the entire witness set to the complemented puzzle with no change in cardinality. Any discrepancy in a concrete gadget construction must arise before the orbit theorem applies—through gadget automorphisms, interchangeable copies, unintended assemblies, or lost boundary constraints.

### 7.2 Symmetry-aware enumeration

The tagged involution allows one to store a single representative per orbit. Choosing the left-tagged member as canonical reduces storage for the combined space by exactly a factor of two, excluding representation overhead. Unlike symmetry breaking based on arbitrary lexicographic choices, this representative rule is intrinsic to the tag.

### 7.3 Testing puzzle solvers

Complementary instances form metamorphic test pairs. A solver should report identical counts for $P$ and $P^c$. A generator that outputs all tagged assemblies should output an even number. These are exact invariants that require no independently known answer. Failures can expose asymmetric treatment of tabs and blanks, inconsistent frame conversion, orientation errors, or duplicate handling.

### 7.4 Statistical observables

If a statistic $f$ on the combined space is antisymmetric under complementation,

$$
f(T_P(x))=-f(x),
$$

then its sum over the finite combined space vanishes:

$$
\sum_{x\in C(P)}f(x)=0.
$$

Indeed, each two-element orbit contributes $f(x)+f(T_P(x))=0$. This extends the parity argument from counting points to cancelling signed quantities, such as net polarity scores defined on complementary pairs.

## 8. Scope and limitations

The abstract result should not be mistaken for a complete geometric realization of every jigsaw model. Several assumptions require care in applications.

First, assembly spaces must be finite for cardinal parity to have its ordinary finite meaning. A finite board and finite multiset of pieces normally ensure this after placements are discretized.

Second, the edgewise operation must define a true bijection on complete assemblies. If only pieces but not the frame are complemented, valid boundary contacts may fail. If rotation is allowed on one side but not the other, admissible placements may differ. If colors themselves have directed semantics, retaining color may be wrong. If indistinguishable pieces are quotient objects, the complement operation must respect that quotient.

Third, the result is about a tagged disjoint union. Passing to an untagged quotient can collapse paired points and alter orbit sizes. Any theorem after quotienting must analyze stabilizers and fixed points anew.

Finally, parity alone does not imply the existence of a geometrically natural complement map. An even total count could occur accidentally. The bijection is the substantive structural input; parity is one of its consequences.

## 9. Future research directions

The immediate geometric objective is to define a concrete model of non-rotatable square pieces with flat, colored-tab, and colored-blank edges, piece multiplicities, rectangular placements, and a rigid frame. One should then prove that componentwise edge complementation maps complete placements bijectively to placements of the complemented instance. This would instantiate the abstract theory without changing any orbit argument.

A second direction concerns quotients by interchangeable pieces and geometric symmetries. The tagged theorem survives whenever complementation descends to a bijection on equivalence classes, but orbit freeness after additional identifications is subtler. Classifying exactly which quotients preserve two-element orbits would clarify the boundary between harmless representation choices and symmetry-induced fixed points.

A third direction is parsimonious geometric complexity. Planar wire, crossover, fan-out, and clause gadgets should be designed so that the number of rectangular assemblies equals the number of satisfying assignments, perhaps up to a formula-independent and efficiently computable symmetry factor. Complement transport then supplies paired counting instances automatically.

A fourth direction extends local cancellation to topology. On an orientable surface, signed edge potentials may define a cohomology class. Pairing interior edges enforces a discrete divergence law, while noncontractible cycles can carry residual flux. On a torus, two independent cycle directions suggest two flux obstructions beyond rectangular tab–blank conservation.

Finally, one may study the topology of solution complexes rather than their vertex sets alone. If single-variable flips correspond to bounded local rearrangements, a gadget construction could preserve adjacency, connected components, or homotopy type. The present bijection controls vertices; the next challenge is to transport reconfiguration structure.

## 10. Conclusion

Global tab–blank complementation has a complete and rigid orbit theory once it induces a bijection between finite assembly spaces. On the tagged union of original and complemented assemblies, the induced map is an involution without fixed points. Every orbit has two elements, the two sides have equal cardinality, and the combined count is even.

The strongest conceptual point is negative as well as positive: non-self-duality is not needed. A self-dual puzzle may have fixed assemblies after the two sides are identified, but it cannot have a fixed point in the tagged coproduct because complementation changes the tag. The singleton example shows both phenomena in their simplest form.

This separation of geometry from orbit theory makes the result reusable. Concrete models bear one burden: construct the assembly-complement bijection. Once that is achieved, witness transport, equal counting, two-element pairing, and parity follow together.