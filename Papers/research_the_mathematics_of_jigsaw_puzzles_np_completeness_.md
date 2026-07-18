# Exact Solution-Space Correspondences for Logic-Encoded Jigsaw Puzzles

**Aristotle**  
**July 18, 2026**

## Abstract

We study an abstract jigsaw construction associated with finite Boolean formulas. Variables are represented by complementary assignment choices, clauses by components that fit exactly when at least one incident literal is true, and two additional pieces enforce the designated boundary. The principal result is a canonical bijection between satisfying assignments on a fixed finite variable set and valid assembly recipes. This strengthens equisatisfiability to parsimony: the construction preserves the exact number of witnesses and, in particular, preserves uniqueness. A second result identifies a global involution. Simultaneously negating every assigned Boolean value and every literal polarity preserves literal, clause, and formula satisfaction; on puzzle interfaces this corresponds to globally exchanging tabs and blanks. We illustrate the theory on the formula $(x_0\lor x_1\lor\neg x_2)\land(\neg x_0\lor x_2)$, whose construction has ten pieces and five assembly recipes. We separate these established results from the broader conjecture that unrestricted geometric rectangular jigsaw assembly is NP-complete. The latter still requires polynomial-size planar gadgets, rigid framing, and control of geometric automorphisms. The exact witness correspondence isolates those geometric tasks and motivates extensions to counting complexity, involutive symmetry, boundary cohomology, and the topology of solution complexes.

## 1. Introduction

Jigsaw assembly and Boolean satisfiability share a common logical form. A candidate is assembled from local choices, while validity requires all local constraints to hold simultaneously. In a jigsaw, adjacent edges must be complementary and the boundary must close. In a Boolean formula in conjunctive normal form, at least one literal must satisfy each clause. This resemblance suggests reductions between the two settings, but a useful reduction must answer more than whether the two problems feel alike.

There are several levels at which a correspondence may operate. An existence-preserving reduction shows only that one side has a solution if and only if the other does. A witness-preserving reduction maps individual solutions. A parsimonious reduction does better still: it gives a bijection of complete solution spaces, preserving exact counts and uniqueness. The construction studied here reaches this third level for an abstract formula-indexed assembly model.

The model deliberately isolates logical compatibility from unrestricted Euclidean placement. Each variable contributes two assignment pieces, each clause contributes a clause piece, and two further pieces designate opposite corners of the boundary. The decisive local rule states that a clause piece fits a chosen assignment exactly when the clause contains a true literal. Once that rule is built into the construction, a satisfying assignment itself is an assembly recipe, and conversely.

Our first theorem makes this identity of witnesses explicit. For $n$ declared variables and a formula $F$, assignments are functions from $\{0,\ldots,n-1\}$ to the Boolean set $\{0,1\}$; values outside that finite set are fixed to false. The finite set of satisfying assignments is canonically bijective with the finite set of valid assembly recipes. Exact cardinality and uniqueness follow immediately.

Our second theorem concerns complementation. Negating an assignment alone generally changes satisfaction. Negating every literal polarity alone does as well. Performing both operations simultaneously, however, preserves the truth of each literal. The preservation propagates through disjunctions and conjunctions, producing a bijection between the solution spaces of $F$ and its literalwise complement. Under the edge interpretation, this is the global tab–blank symmetry.

These results clarify the status of complexity claims. They establish the logical core of a parsimonious reduction, but not NP-completeness for unrestricted geometric jigsaw puzzles. A geometric theorem requires a finite encoding of positions and edge types, a polynomial construction, planar wires and clauses, management of crossover and fan-out, and a proof that the frame removes unintended motions and symmetries. We therefore state the established abstract results precisely and treat geometric hardness as a future direction.

## 2. Boolean and assembly preliminaries

### 2.1 Assignments, literals, clauses, and formulas

Let $\mathbb{B}=\{0,1\}$, where $0$ denotes false and $1$ denotes true. An **assignment** is a function

$$
a:\mathbb{N}\to\mathbb{B}.
$$

A **literal** is a pair $\ell=(i,p)$ consisting of a variable index $i\in\mathbb{N}$ and a polarity $p\in\mathbb{B}$. We interpret $(i,1)$ as the positive literal $x_i$ and $(i,0)$ as the negative literal $\neg x_i$. The literal is satisfied by $a$ precisely when

$$
a(i)=p.
$$

A **clause** is a finite list of literals. It is satisfied by $a$ when at least one of its literals is satisfied. Thus, for a clause $C$,

$$
\operatorname{SatClause}(a,C)
\quad\Longleftrightarrow\quad
\exists(i,p)\in C\text{ such that }a(i)=p.
$$

A **formula** $F$ is a finite list of clauses. It is satisfied by $a$ when every clause is satisfied:

$$
\operatorname{Sat}(a,F)
\quad\Longleftrightarrow\quad
\forall C\in F,\ \operatorname{SatClause}(a,C).
$$

The formula is **satisfiable** when some assignment satisfies it.

Fix a declared variable count $n$. A finite assignment is a function

$$
b:\{0,1,\ldots,n-1\}\to\mathbb{B}.
$$

Its canonical extension $\widetilde b:\mathbb{N}\to\mathbb{B}$ is

$$
\widetilde b(i)=
\begin{cases}
b(i),&i<n,\\0,&i\ge n.
\end{cases}
$$

Fixing out-of-range values makes the finite solution set unambiguous even if a malformed formula mentions an undeclared index. In ordinary applications all variable indices in $F$ are less than $n$, so the second branch is never consulted.

### 2.2 The abstract jigsaw construction

A physical jigsaw edge may be flat, a protruding tab, or a receiving blank. A tab and blank are complementary. The abstract construction uses this complementarity to represent Boolean compatibility while suppressing irrelevant metric details.

For a formula with $n$ variables and $m$ clauses, the inventory contains:

1. two assignment pieces for each variable, corresponding to true and false;
2. one clause piece for each clause;
3. a designated top-left boundary piece; and
4. a designated bottom-right boundary piece.

The total number of pieces is therefore

$$
N=2n+m+2.
$$

The construction is governed by the following interface property.

**Clause-Fit Property.** Let $a$ be an assignment and let $C$ be a clause. The clause piece associated with $C$ fits the assignment interfaces selected by $a$ if and only if $C$ is satisfied by $a$.

Equivalently,

$$
\operatorname{Fits}(a,C)
\quad\Longleftrightarrow\quad
\exists(i,p)\in C\text{ such that }a(i)=p.
$$

This property is the logical specification of the clause component. It says that the component accepts exactly the assignments under which at least one input literal is active.

A **valid assembly recipe** for $F$ is a finite assignment $b$ on the declared variables such that every clause piece fits under $\widetilde b$:

$$
\operatorname{Assembled}(b,F)
\quad\Longleftrightarrow\quad
\forall C\in F,\ \operatorname{Fits}(\widetilde b,C).
$$

The puzzle associated with $F$ is **solvable** when at least one valid assembly recipe exists. This definition captures assignment-level assembly. It does not claim that arbitrary polygonal or square pieces can be placed in the plane according to this predicate without further gadget construction.

### 2.3 Finite solution spaces

Define the satisfying-assignment space

$$
\mathcal{S}_n(F)=
\left\{b:\{0,\ldots,n-1\}\to\mathbb{B}
\mid \operatorname{Sat}(\widetilde b,F)\right\}
$$

and the assembly-recipe space

$$
\mathcal{A}_n(F)=
\left\{b:\{0,\ldots,n-1\}\to\mathbb{B}
\mid \operatorname{Assembled}(b,F)\right\}.
$$

Both sets are finite because each is a subset of the $2^n$ Boolean assignments.

## 3. Exact preservation of the solution space

### 3.1 Canonical bijection

**Theorem 1 (Assembly–Assignment Correspondence).** For every $n\in\mathbb{N}$ and every finite Boolean formula $F$, there is a canonical bijection

$$
\Phi_{n,F}:\mathcal{A}_n(F)\longrightarrow\mathcal{S}_n(F).
$$

The bijection preserves the underlying assignment: $\Phi_{n,F}(b)=b$.

**Proof sketch.** Let $b\in\mathcal{A}_n(F)$. By definition, every clause piece fits under $\widetilde b$. By the Clause-Fit Property, each clause contains a literal satisfied by $\widetilde b$. Thus every clause is satisfied, and $b\in\mathcal{S}_n(F)$.

Conversely, let $b\in\mathcal{S}_n(F)$. Every clause of $F$ has a literal satisfied by $\widetilde b$. Applying the reverse implication of the Clause-Fit Property shows that every corresponding clause piece fits. Hence $b\in\mathcal{A}_n(F)$.

Both maps retain $b$ unchanged. Their composites are therefore identity maps, proving bijectivity. $\square$

The theorem is stronger than equisatisfiability. It does not merely construct some assembly from some satisfying assignment; it identifies the two witness sets assignment by assignment.

### 3.2 Exact counting

**Corollary 2 (Exact Solution Count).** For every $n$ and $F$,

$$
|\mathcal{A}_n(F)|=|\mathcal{S}_n(F)|.
$$

**Proof sketch.** Finite sets related by a bijection have equal cardinality. Apply Theorem 1. $\square$

This equality is parsimonious: there is no formula-dependent or formula-independent multiplicative factor. In a later geometric realization, factors might arise from rotations, reflections, interchangeable copies, or frame symmetries. The abstract model contains none of those duplications.

### 3.3 Preservation of uniqueness

**Corollary 3 (Uniqueness Preservation).** The assembly-recipe space $\mathcal{A}_n(F)$ has exactly one element if and only if the satisfying-assignment space $\mathcal{S}_n(F)$ has exactly one element.

**Proof sketch.** A bijection transports existence and equality of elements in both directions. Thus one side is a singleton exactly when the other is. $\square$

This consequence distinguishes forced puzzles from ambiguous ones. If a formula has a unique satisfying assignment, then every assignment choice in the associated recipe is forced. Conversely, any second satisfying assignment produces a distinct assembly recipe.

### 3.4 Solvability

**Corollary 4 (Existence Preservation).** The abstract puzzle associated with $F$ is solvable if and only if $F$ has a satisfying assignment on its declared variables.

**Proof sketch.** A finite set is nonempty exactly when any set bijective to it is nonempty. Apply Theorem 1. $\square$

Existence preservation is therefore only the coarsest shadow of the full correspondence.

## 4. Global complementation

### 4.1 Definitions

For an assignment $a$, define its **complement** $\bar a$ by

$$
\bar a(i)=1-a(i).
$$

For a literal $\ell=(i,p)$, define

$$
\bar\ell=(i,1-p).
$$

For a clause $C$, let $\bar C$ be obtained by complementing every literal in $C$. For a formula $F$, let $\bar F$ be obtained by complementing every clause, equivalently every literal polarity in the formula.

Each operation is involutive:

$$
\bar{\bar a}=a,\qquad
\bar{\bar\ell}=\ell,\qquad
\bar{\bar C}=C,\qquad
\bar{\bar F}=F.
$$

### 4.2 Preservation from literals to formulas

**Lemma 5 (Literal Complementation).** For every assignment $a$ and literal $\ell$,

$$
\operatorname{SatLiteral}(\bar a,\bar\ell)
\quad\Longleftrightarrow\quad
\operatorname{SatLiteral}(a,\ell).
$$

**Proof sketch.** Write $\ell=(i,p)$. The left side says $1-a(i)=1-p$, which is equivalent to $a(i)=p$. $\square$

**Lemma 6 (Clause Complementation).** For every assignment $a$ and clause $C$,

$$
\operatorname{SatClause}(\bar a,\bar C)
\quad\Longleftrightarrow\quad
\operatorname{SatClause}(a,C).
$$

**Proof sketch.** A literal belongs to $C$ if and only if its complement belongs to $\bar C$. Lemma 5 preserves satisfaction for each paired literal. Hence an existential witness on either side transports to one on the other. $\square$

**Theorem 7 (Formula Complementation).** For every assignment $a$ and formula $F$,

$$
\operatorname{Sat}(\bar a,\bar F)
\quad\Longleftrightarrow\quad
\operatorname{Sat}(a,F).
$$

**Proof sketch.** A formula is satisfied exactly when each clause is satisfied. Pair every clause $C$ of $F$ with $\bar C$ in $\bar F$ and apply Lemma 6. $\square$

Because complementation is its own inverse, Theorem 7 gives a bijection between the satisfying assignments of $F$ and those of $\bar F$. It consequently preserves exact solution counts, although the primary puzzle statement below requires only nonemptiness.

### 4.3 Tab–blank symmetry

**Theorem 8 (Tab–Blank Solvability Symmetry).** The abstract puzzle associated with $\bar F$ is solvable if and only if the abstract puzzle associated with $F$ is solvable.

**Proof sketch.** If the puzzle for $F$ is solvable, Corollary 4 gives a satisfying assignment $a$. Theorem 7 shows that $\bar a$ satisfies $\bar F$, and Corollary 4 then gives an assembly recipe for the complemented puzzle. The reverse implication is identical because complementation is involutive. $\square$

Under the interface interpretation, changing a positive requirement into a negative one while negating the selected truth value exchanges the roles of tab and blank. The theorem expresses a global order-two symmetry of solvability.

One must distinguish this transport between two solution spaces from a free action on one solution space. If $F$ is identified with $\bar F$ through a relabeling or geometric symmetry, exceptional self-dual configurations may occur. Freeness requires an explicit non-self-duality hypothesis and is not asserted here.

## 5. Algorithms

### 5.1 Satisfaction and recipe testing

Given an assignment and a formula, evaluate each literal by comparing its assigned value with its polarity. A clause passes when any comparison succeeds; the formula passes when all clauses pass. By the Clause-Fit Property, the same procedure tests whether the assignment is an assembly recipe.

If $L$ is the total number of literal occurrences,

$$
L=\sum_{C\in F}|C|,
$$

then testing one assignment takes $O(L)$ time and $O(1)$ auxiliary space apart from the input representation.

### 5.2 Exhaustive enumeration

Enumerate all $2^n$ assignments, test each, and retain the successful ones. This computes both $\mathcal{S}_n(F)$ and, through Theorem 1, $\mathcal{A}_n(F)$. Its running time is

$$
O(2^nL),
$$

and storing all solutions requires $O(nK)$ bits when $K$ solutions are found. Counting alone can use $O(n)$ working space.

### 5.3 Complement transport

To transport a solution, flip each of its $n$ bits and flip the polarity of each of the $L$ literal occurrences. This costs $O(n+L)$ time. Applying the operation twice returns the original data exactly.

## 6. Running example

Consider

$$
F=(x_0\lor x_1\lor\neg x_2)\land(\neg x_0\lor x_2).
$$

Here $n=3$ and $m=2$, so the piece inventory has

$$
2n+m+2=2(3)+2+2=10
$$

pieces.

Take the assignment

$$
a=(0,1,0).
$$

The literal $x_1$ satisfies the first clause, and $\neg x_0$ satisfies the second. Thus $a$ satisfies $F$. The Assembly–Assignment Correspondence turns the same assignment into a valid recipe: each clause piece fits because the stated literal supplies an active interface.

Exhaustive enumeration gives the five satisfying assignments

$$
(0,0,0),\quad
(0,1,0),\quad
(0,1,1),\quad
(1,0,1),\quad
(1,1,1).
$$

For instance, when $x_0=0$ and $x_2=0$, the second clause is satisfied by $\neg x_0$, while the first requires either $x_1=1$ or $\neg x_2=1$; the latter already holds, giving $(0,0,0)$ and $(0,1,0)$. Similar case analysis yields the remaining three assignments. Corollary 2 implies that the associated abstract puzzle has exactly five assembly recipes.

The complemented formula is

$$
\bar F=(\neg x_0\lor\neg x_1\lor x_2)\land(x_0\lor\neg x_2).
$$

Complementation maps the displayed witness $(0,1,0)$ to $(1,0,1)$. Indeed, $\neg x_1$ satisfies the first complemented clause and $x_0$ satisfies the second. More generally, complementing each of the five solutions of $F$ gives all five solutions of $\bar F$.

## 7. Complexity interpretation and limitations

The correspondence has the form desired for a parsimonious reduction: witnesses map bijectively and can be evaluated with local clause checks. Nevertheless, an abstract assembly predicate is not yet a complete geometric decision problem.

To establish NP-completeness for rectangular assembly by four-sided pieces, one must specify a finite input encoding and prove two directions. Membership in NP requires polynomial-size certificates—typically placements and orientations—and polynomial-time verification of boundary and adjacency conditions. NP-hardness requires translating a formula to a polynomial number of pieces such that geometric assemblies correspond to satisfying assignments.

Several geometric obstacles remain:

1. **Signal transmission.** Wire gadgets must carry a chosen Boolean state over distance without allowing a third state.
2. **Fan-out.** A variable occurring many times must feed multiple clause inputs consistently.
3. **Planarity.** Logical incidence graphs need crossings unless crossover gadgets or planar variants are supplied.
4. **Clause realization.** A physical component must accept exactly those boundary patterns with at least one true input.
5. **Rigid framing.** The outer frame must prohibit translation, rotation, reflection, and unintended boundary placements.
6. **Parsimony.** Internal gadget configurations and interchangeable copies must not multiply witnesses unpredictably.

The present bijection isolates these as the missing burdens. If geometric gadgets realize the Clause-Fit Property uniquely and compose without automorphisms, the assignment-level argument immediately supplies witness preservation. If each logical witness generates a fixed number $q$ of geometric assemblies, counting is preserved up to that computable symmetry factor.

Accordingly, the established statement should not be paraphrased as a proof that unrestricted commercial jigsaws are NP-complete. It is an exact theorem about a formula-indexed abstract puzzle model and a foundation for the geometric conjecture.

## 8. Applications and broader structures

### 8.1 Counting and uniqueness

Because cardinalities are preserved, any method that counts assembly recipes also counts satisfying assignments for the encoded formula. Conversely, known distinctions among zero, one, and many satisfying assignments transfer directly to the puzzle. This makes the construction relevant to counting complexity and unique-solution questions, provided a later geometric implementation controls symmetries.

### 8.2 Symmetry reduction

Complementation partitions paired formula-solution data into orbits of size at most two. For non-self-dual framed puzzles, one expects a free involution on the disjoint union of a puzzle’s assembly space and that of its complement. Such a theorem would force the combined cardinality to be even. The proven solvability symmetry supplies the transport map; classifying self-dual exceptions remains necessary.

### 8.3 Boundary conservation and surfaces

Assign a sign or potential to each oriented edge type, with complementary tab and blank values summing to zero. Interior matches then cancel pairwise. On a rectangle, the resulting conservation law constrains the exposed boundary. On an orientable surface with noncontractible cycles, residual signed flux may define a cohomology class. A torus should exhibit two independent flux coordinates corresponding to its two fundamental directions. This proposed extension translates local edge cancellation into a global topological obstruction.

### 8.4 Solution complexes

The finite solution set can be enriched geometrically. Make satisfying assignments vertices and connect two vertices when they differ in one variable. Whenever $k$ variable flips can be performed independently while remaining satisfying, fill the resulting $k$-dimensional cube. The resulting cubical solution complex records connectivity, bottlenecks, and higher-dimensional families of choices. A sufficiently rigid parsimonious puzzle construction may preserve this complex up to deformation retraction, strengthening cardinality preservation to topological preservation.

## 9. Discussion

The most important structural fact is that the proof of parsimony is local. The global bijection follows by applying one equivalence—the Clause-Fit Property—to every clause. This modularity is valuable for design: a geometric implementation need not re-prove the logical theorem from scratch. It must instead realize each interface equivalence and show that composition creates no unintended degrees of freedom.

The fixed extension outside $\{0,\ldots,n-1\}$ is another small but useful design choice. It makes the finite witness spaces precise for every formula, including formulas that mention undeclared indices. For well-scoped formulas it is invisible, but it prevents an implicit infinite family of irrelevant assignment values from contaminating cardinality statements.

The complement theorem is similarly local. Its content is already present at the level of a single literal, where the Boolean identity

$$
1-a(i)=1-p\quad\Longleftrightarrow\quad a(i)=p
$$

holds. Existential quantification lifts the identity to clauses, universal quantification lifts it to formulas, and the assembly correspondence transports it to puzzles. This layered argument explains why tab–blank exchange is not an accidental visual analogy but the edge-level manifestation of Boolean negation.

## 10. Future work

The immediate goal is a polynomial-size geometric realization with non-rotatable square pieces, finitely many colored edge types, and a fixed outer frame. A successful construction should be tested not merely for equisatisfiability but for parsimony. Gadget automorphisms should be catalogued and either eliminated or factored into a formula-independent multiplicity.

A second direction is the exact involutive structure of complementation. For a puzzle not isomorphic to its global tab–blank complement, one expects complementation to act freely on the disjoint union of the two assembly spaces. Self-dual puzzles require a classification of possible fixed configurations.

A third direction develops homology-valued edge invariants on orientable surfaces. Signed local cancellation suggests discrete divergence laws, while nontrivial first homology should record global flux that interior pairings cannot erase.

Finally, witness preservation invites the study of solution complexes rather than solution sets. The target is a gadget family for which single-variable flips correspond to local assembly moves and the resulting cubical assembly complex deformation-retracts onto the Boolean solution complex.

## 11. Conclusion

For the abstract logic-encoded jigsaw construction, assembly recipes and satisfying assignments are the same finite witnesses viewed through two vocabularies. Their canonical bijection preserves existence, exact count, and uniqueness. Simultaneous complementation of assignments and literal polarities preserves satisfaction and induces a global tab–blank symmetry of solvability. The three-variable example exhibits the correspondence concretely with ten pieces and five solutions.

These results do not complete the geometric NP-completeness program, but they identify its exact logical foundation. What remains is geometry: planar communication, rigid boundaries, controlled symmetries, and faithful clause gadgets. That separation turns an appealing analogy into a precise mathematical agenda linking satisfiability, parsimonious reductions, edge complementarity, and topology.
