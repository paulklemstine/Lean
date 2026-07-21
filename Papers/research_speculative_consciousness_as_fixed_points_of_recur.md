# Propositional Self-Reference as a Collapse Principle

## Classification, Decidability, and the Failure of a Gödelian Analogy

**Aristotle**  
**July 21, 2026**

## Abstract

We study a direct fixed-point model of self-reference in which a type $T$ is required to be equivalent to a dependent product of propositions indexed by itself. Explicitly, the condition is the existence of a predicate $P:T\to\mathrm{Prop}$ and an equivalence

$$
T\simeq\prod_{x:T}P(x).
$$

Although the occurrence of $T$ on both sides suggests recursion, the proposition-valued codomain forces a complete collapse. Proof irrelevance makes the dependent product a subsingleton, so the equivalence makes $T$ a subsingleton. The empty case is impossible because a dependent product over an empty domain has a unique inhabitant. Consequently, the fixed points are exactly the types equivalent to a singleton. We derive decidable equality, exclusion of the Boolean type, mutual equivalence of all fixed points, cardinality one, and extensional constancy of every predicate on a fixed point. For finite types we give a cardinal-product decision algorithm and numerical demonstrations. We explain why the result does not produce Gödelian undecidability and identify three non-collapsing research programs: data-valued fibers, coded syntax with semantics, and universe-sensitive models of self-reference.

## 1. Introduction

Self-reference is central to logic and computation. Diagonal arguments construct sentences that encode claims about themselves; recursion theorems produce programs related to their own descriptions; and fixed points organize semantics for recursive definitions. These successes encourage a natural but hazardous heuristic: if a mathematical object occurs in the domain of a construction used to define that same object, then logical complexity or undecidability should follow.

This paper tests a particularly direct form of that heuristic. Let $T$ be a type, interpreted simply as a collection of distinguishable objects. Let $P:T\to\mathrm{Prop}$ be a predicate. The dependent product $\prod_{x:T}P(x)$ consists of assignments that provide, for every $x:T$, a proof of $P(x)$. We ask for an equivalence between $T$ and this product. Thus $T$ is identified with a space of proposition-valued evidence quantified over $T$ itself.

The model is mathematically precise, but its behavior is opposite to the expected Gödelian picture. Its fixed points have no nontrivial internal variation. The source of the collapse is proof irrelevance: two proofs of the same proposition are not treated as distinct data. Accordingly, two inhabitants of a product of propositions agree at every coordinate and hence agree globally.

Our main theorem gives a complete classification:

$$
\left(\exists P:T\to\mathrm{Prop},\;T\simeq\prod_{x:T}P(x)\right)
\quad\Longleftrightarrow\quad
T\simeq\mathbf{1},
$$

where $\mathbf{1}$ denotes any singleton type. This theorem settles all cardinal and equality questions about the model. It also clarifies why genuine incompleteness requires coded syntax, effective operations, and a specified decision problem rather than semantic self-occurrence alone.

The contribution is therefore both classificatory and diagnostic. The fixed-point equation is solved exactly, and its failure as a model of computational self-reference identifies which enrichments are necessary for a nontrivial successor theory.

## 2. Preliminaries and definitions

### 2.1 Types, propositions, and equivalence

A **type** $T$ is a collection whose elements are written $x:T$. We reason extensionally about functions: two functions are equal when they have equal values at every input.

A **proposition** is a type used only for its truth content. We assume **proof irrelevance**: if $p$ and $q$ are proofs of the same proposition $R$, then $p=q$. Thus an inhabited proposition contains no distinguishable data beyond the fact that it is inhabited.

A type $S$ is a **subsingleton** if

$$
\forall a,b:S,\quad a=b.
$$

It is **nonempty** if there exists $a:S$. A type that is both nonempty and a subsingleton is equivalent to the singleton type $\mathbf{1}=\{\star\}$.

An **equivalence** $A\simeq B$ is a function $e:A\to B$ with an inverse $e^{-1}:B\to A$ such that both composites are identity functions. Equivalences preserve structural properties relevant here: emptiness, nonemptiness, being a subsingleton, and cardinality.

### 2.2 Dependent products

Given a type $T$ and a family of types $F(x)$ indexed by $x:T$, the dependent product

$$
\prod_{x:T}F(x)
$$

is the type of dependent functions $f$ such that $f(x):F(x)$ for every $x:T$. When $F(x)$ is a proposition $P(x)$, an inhabitant is a simultaneous proof of every proposition in the family.

Two elementary facts drive the classification.

**Lemma 2.1 (Propositional products are subsingletons).** Let $P:T\to\mathrm{Prop}$. Then $\prod_{x:T}P(x)$ is a subsingleton.

**Proof sketch.** Take $f,g:\prod_{x:T}P(x)$. For each $x:T$, the values $f(x)$ and $g(x)$ prove the same proposition $P(x)$, so proof irrelevance gives $f(x)=g(x)$. Function extensionality then yields $f=g$. $\square$

**Lemma 2.2 (The empty product is inhabited).** If $T$ is empty, then $\prod_{x:T}P(x)$ has exactly one inhabitant for every predicate $P:T\to\mathrm{Prop}$.

**Proof sketch.** There is a function from the empty type into every family because no input case must be supplied. Any two such functions are equal by extensionality, again because there are no inputs at which they could differ. $\square$

The convention that an empty product equals $1$ is therefore not merely numerical notation; it reflects the existence of a unique empty assignment.

### 2.3 The fixed-point condition

**Definition 2.3 (Propositional self-referential fixed point).** A type $T$ is a propositional self-referential fixed point if there exists a predicate $P:T\to\mathrm{Prop}$ such that

$$
T\simeq\prod_{x:T}P(x).
$$

The predicate may depend on $T$ and may vary with $x$. The definition imposes no finiteness assumption and no computability structure. The term “self-referential” refers only to the repeated occurrence of $T$ as both the type being classified and the index type of the dependent product.

This limitation is important. The condition does not supply a syntax, an encoding operation, a provability relation, or a semantic decision problem.

## 3. Structural classification

We first transfer the subsingleton property across the fixed-point equivalence.

**Theorem 3.1 (Subsingleton theorem).** If $T$ is a propositional self-referential fixed point, then $T$ is a subsingleton.

**Proof sketch.** Choose $P:T\to\mathrm{Prop}$ and an equivalence $e:T\simeq\prod_{x:T}P(x)$. By Lemma 2.1, $e(x)=e(y)$ for all $x,y:T$. Since an equivalence is injective, $x=y$. $\square$

This theorem gives an upper bound of one inhabitant. The next theorem supplies the lower bound.

**Theorem 3.2 (Nonemptiness theorem).** Every propositional self-referential fixed point is nonempty.

**Proof sketch.** Suppose $T$ were empty. By Lemma 2.2, the product $\prod_{x:T}P(x)$ would have a unique inhabitant. An equivalence from empty $T$ to an inhabited product is impossible: applying its inverse to the unique empty assignment would produce an inhabitant of $T$. Therefore $T$ is nonempty. $\square$

The two constraints combine into the main result.

**Theorem 3.3 (Complete classification).** A type $T$ is a propositional self-referential fixed point if and only if $T$ is equivalent to the singleton type $\mathbf{1}$.

**Proof sketch.** For the forward direction, Theorems 3.1 and 3.2 show that $T$ is an inhabited subsingleton. Choose an inhabitant $t_0:T$. The constant function $T\to\mathbf{1}$ and the function sending $\star$ to $t_0$ are inverse because all elements of $T$ equal $t_0$.

For the reverse direction, suppose $T\simeq\mathbf{1}$. Let $P(x)$ be the always-true proposition for every $x:T$. Because $T$ has exactly one element and truth has exactly one proof up to proof irrelevance, the product $\prod_{x:T}P(x)$ is a singleton. Composing the equivalences through $\mathbf{1}$ yields $T\simeq\prod_{x:T}P(x)$. $\square$

The theorem is exact: it gives both a necessary condition and a witness construction for every permitted type.

## 4. Consequences

### 4.1 Equality is decidable

**Corollary 4.1 (Decidable equality).** If $T$ is a propositional self-referential fixed point, then equality on $T$ is decidable.

**Proof sketch.** Given $x,y:T$, Theorem 3.1 gives $x=y$. The decision procedure always returns the positive answer together with this equality. $\square$

This directly refutes the conjecture that all fixed points of the displayed form must be undecidable. The singleton itself is a concrete fixed point with trivial decidable equality.

The word “decidable” deserves care. Here it means that equality between two inhabitants can be decided. Gödelian undecidability concerns the nonexistence of an algorithm deciding a family of syntactically encoded propositions or derivability judgments. These are different claims, and the fixed-point definition supplies only the former question.

### 4.2 The smallest nontrivial data type is excluded

**Corollary 4.2 (Boolean exclusion).** A type with two distinct elements, in particular the Boolean type $\{0,1\}$, is not a propositional self-referential fixed point.

**Proof sketch.** If it were a fixed point, Theorem 3.1 would identify its two elements, contradicting their distinctness. $\square$

Thus the construction cannot represent one bit of information. Its failure is stronger than the absence of a large hierarchy: it excludes every nontrivial finite state space.

### 4.3 No hierarchy of fixed points

**Corollary 4.3 (Hierarchy collapse).** If $A$ and $B$ are propositional self-referential fixed points, then $A\simeq B$.

**Proof sketch.** By Theorem 3.3, choose equivalences $A\simeq\mathbf{1}$ and $B\simeq\mathbf{1}$. Compose the first with the inverse of the second. $\square$

Therefore any proposed hierarchy based solely on iterating this fixed-point condition has one equivalence class. Additional labels or presentations may differ, but their represented types do not.

### 4.4 Cardinality

**Corollary 4.4 (Cardinality one).** Every propositional self-referential fixed point has cardinality $1$.

**Proof sketch.** Cardinality is invariant under equivalence, and Theorem 3.3 identifies every fixed point with $\mathbf{1}$. $\square$

**Corollary 4.5 (Finite classification).** Among finite types, the fixed-point condition holds exactly for types of cardinality $1$.

The claim that the cardinality of these fixed points should be the Church–Kleene ordinal $\omega_1^{CK}$ is consequently incompatible with this classification under the direct interpretation. There is also a category mismatch in the original comparison: $\omega_1^{CK}$ is an ordinal, while the size of a collection of types would be a cardinal only after fixing a universe, a coding, and a quotient such as equivalence. Under equivalence, the present fixed points form exactly one class.

### 4.5 Predicates become constant

**Corollary 4.6 (Predicate collapse).** Let $T$ be a propositional self-referential fixed point and $Q:T\to\mathrm{Prop}$ any predicate. Then for all $x,y:T$,

$$
Q(x)\iff Q(y).
$$

**Proof sketch.** Theorem 3.1 gives $x=y$. Substitution along this equality turns $Q(x)$ and $Q(y)$ into the same proposition. $\square$

This result is not limited to the predicate witnessing the fixed point. Every proposition-valued observation on $T$ is extensionally constant.

## 5. Finite cardinal analysis and algorithms

The abstract proof handles arbitrary types, but finite cardinalities provide an elementary diagnostic.

Let $|T|=n$, and enumerate $T$ as $x_1,\ldots,x_n$. Since each $P(x_i)$ is a proposition, its number of distinguishable proofs is represented by a truth cardinal $b_i\in\{0,1\}$. Then

$$
\left|\prod_{x:T}P(x)\right|=\prod_{i=1}^{n}b_i.
$$

For $n=0$, the product is empty and therefore equals $1$. For $n>0$, the product is $1$ exactly when every $b_i=1$ and is $0$ otherwise. The fixed-point cardinal equation is

$$
n=\prod_{i=1}^{n}b_i.
$$

It follows immediately that $n=1$ and $b_1=1$ are necessary and sufficient.

### Algorithm 5.1: finite witness test

**Input:** A nonnegative integer $n$ and a list of $n$ truth values $b_1,\ldots,b_n$.

**Output:** Whether the associated cardinal equation holds.

1. If the list length is not $n$, reject the input as malformed.
2. Compute the product, initialized to $1$.
3. For each $b_i$, replace the product by its conjunction with $b_i$.
4. Return whether $n$ equals $1$ when the conjunction is true, or $0$ when it is false.

The algorithm runs in $O(n)$ time and uses $O(1)$ auxiliary space. Exhausting all predicates on an $n$-element type requires $2^n$ truth assignments, so exhaustive classification takes $O(n2^n)$ time. The theorem yields a faster structural classifier: accept precisely when $n=1$, in $O(1)$ arithmetic time.

### Numerical examples

For $n=0$, there is one predicate assignment, the empty list, and its product cardinality is $1$ rather than $0$. For $n=1$, there are two assignments: false gives product cardinality $0$, while true gives $1$ and is the unique witness. For $n=2$, the four assignments yield product cardinalities $0,0,0,1$; none equals $2$. For every $n\ge 2$, every product remains at most $1$, so no witness exists.

These calculations demonstrate, rather than establish in full generality, the same collapse theorem.

## 6. Why no Gödel phenomenon follows

A Gödelian argument does not arise merely because a symbol occurs on both sides of an equation. At least five additional structures are normally required.

First, one needs a countable or otherwise effective **syntax** whose expressions can be represented by finite codes. Second, one needs **substitution**, allowing the code of an expression to be inserted into an expression with a free variable. Third, a **diagonal lemma** must relate a formula to the result of applying it to its own code. Fourth, there must be a **provability or truth relation** connecting syntax with semantics. Fifth, “undecidable” must refer to a specified class of algorithms acting on codes.

The fixed-point condition studied here includes none of these. The right-hand side is a semantic product of propositions, not a language of expressions. Its inhabitants are proofs, not codes. There is no operation that lets a predicate inspect its own description. Consequently, proof irrelevance, not diagonalization, governs the equation.

This distinction also separates two meanings of self-reference:

1. **Index self-occurrence:** $T$ appears as the domain of a family used to construct an object equivalent to $T$.
2. **Syntactic self-application:** an expression receives or denotes a code of itself through an effective substitution mechanism.

Only the first is present here. Conflating the two turns an evocative analogy into an invalid inference.

## 7. Non-collapsing extensions

### 7.1 Data-valued fibers

Replace $P:T\to\mathrm{Prop}$ with a type-valued family $F:T\to\mathrm{Type}$ and study

$$
T\simeq\prod_{x:T}F(x).
$$

Proof irrelevance no longer identifies all values in a fiber. For finite types, the necessary cardinal equation becomes

$$
|T|=\prod_{x:T}|F(x)|.
$$

This equation has nontrivial solutions. If $|T|=4$ and the four fiber cardinalities are $2,2,1,1$, their product is $4$. Cardinal equality alone does not construct an equivalence, but for finite sets it removes the immediate numerical obstruction and permits one to build a bijection.

A useful classification program would distinguish constant families, where $F(x)=S$ and the equation becomes $n=|S|^n$, from genuinely dependent families whose fiber sizes vary. Constraints such as functoriality, continuity, computability, or invariance under automorphisms of $T$ may prevent arbitrary tailoring and produce meaningful fixed-point theories.

### 7.2 Coded syntax and semantics

To pursue incompleteness, define a recursively enumerable set of codes $C$, a partial interpretation map, and operations representing variables and substitution. A diagonal operation should construct, from a one-variable expression code $a$, a sentence code $d(a)$ whose interpretation agrees with applying $a$ to its own transformed code.

A suitable theorem would then have the schematic form

$$
\operatorname{Meaning}(d(a))
\iff
\operatorname{Meaning}(a,d(a)),
$$

subject to explicit well-formedness conditions. Undecidability results would additionally quantify over algorithms and depend on consistency, soundness, or representability assumptions. This is the proper environment for a Gödel-style conclusion.

### 7.3 Universe-sensitive self-reference

A collection of all types cannot ordinarily be treated as a member of itself without stratification. Introduce a universe of codes $C_u$ at level $u$ and a decoding operation

$$
\operatorname{El}:C_u\to\mathrm{Type}_u.
$$

Self-reference then concerns codes and decoding rather than literal membership of a universe in itself. Questions about the “number of self-referential types” must specify whether codes, decoded types, isomorphism classes, or computable presentations are counted. If ordinals such as $\omega_1^{CK}$ are to appear, one must define a computable well-founded ordering on codes and prove that the induced rank has the claimed ordinal behavior.

## 8. Applications and modeling lessons

The classification has practical relevance wherever proposition-valued dependent products are proposed as information-bearing state spaces.

In knowledge representation, a product of propositions records simultaneous truth but not multiple witnesses. It can certify that every indexed condition holds, yet it cannot remember how each condition was established. In distributed systems, replacing local states by mere assertions can erase operational distinctions. In semantics, proof-irrelevant specifications support abstraction but cannot serve as a store of computational choices.

For speculative models of cognition, the theorem supplies a precise negative criterion. A state space intended to represent differentiated experiences must support at least two distinguishable inhabitants. Any construction forced to be a subsingleton cannot do so. This does not constrain consciousness itself; it constrains only models whose entire state space is identified with proof-irrelevant evidence indexed by that same space.

More generally, a recursive equation should be analyzed first for invariant-preserving bottlenecks. If a type former always outputs subsingletons, sets of bounded cardinality, contractible spaces, or objects with trivial automorphism groups, then every fixed point inherits that restriction. Before invoking recursion-theoretic intuition, one should compute these elementary invariants.

## 9. Discussion

The complete classification depends on three assumptions embedded in the definition: fibers are propositions, proofs are irrelevant, and the right-hand side is a total dependent product. Altering any of them may change the result.

If proofs are treated intensionally as distinguishable data, Lemma 2.1 can fail. If the product is partial or computationally effectful, the empty-domain argument may require revision. If the family ranges over data types, nontrivial cardinalities become possible. These are not technical loopholes; they identify distinct mathematical models.

The result also demonstrates the value of a contrarian test. Rather than attempting immediately to prove an anticipated hierarchy, one can examine the simplest invariants implied by the definition. Here, subsingleton status and nonemptiness settle the entire problem. The strongest proposed consequences are not merely unproved; they are contradicted by an exact theorem.

The Church–Kleene analogy requires particular caution. The ordinal $\omega_1^{CK}$ is the least noncomputable ordinal, equivalently the supremum of computable ordinals under standard presentations. It is not obtained by taking the cardinality of an unspecified collection. A rigorous connection would require a coded family of recursive constructions, a rank assignment into computable ordinals, and proofs of cofinality and minimality. None follows from the proposition-valued product equation.

## 10. Future work

The most immediate task is a finite classification for data-valued families, including explicit constructions of equivalences from cardinal factorizations and criteria distinguishing genuinely dependent solutions. A second task is to define a coded language with substitution and prove a diagonal theorem before formulating any undecidability claim. A third is to build a stratified universe of codes and study ranks of recursive type expressions, carefully separating ordinal rank from cardinal size.

Further variations include homotopical fibers, where higher paths preserve structure erased by proof irrelevance; coalgebraic models, where observations unfold recursively; and resource-sensitive logics, where proofs may carry quantitative content. In each case, the first question should be which invariants the type-forming operation preserves and hence imposes on its fixed points.

## 11. Conclusion

The equation

$$
T\simeq\prod_{x:T}P(x),\qquad P:T\to\mathrm{Prop},
$$

looks self-referential but has a complete and elementary classification. The product is a subsingleton by proof irrelevance, so $T$ has at most one element. The empty case is impossible because the empty product has one inhabitant. Therefore $T$ has exactly one element, and conversely every singleton supplies a solution through the constantly true predicate.

All principal consequences follow: equality is decidable, the Boolean type is excluded, every pair of fixed points is equivalent, every fixed point has cardinality $1$, and every predicate on a fixed point is extensionally constant. There is no arithmetical-style hierarchy and no Church–Kleene cardinality in this model.

The broader lesson is methodological. Self-occurrence is not yet self-reference in the Gödelian sense, and propositions are not containers of arbitrary data. A successful theory of computational self-reference must say what is coded, how substitution works, which algorithms are quantified over, and what semantic relation is at stake. Exact classification does more than reject an overambitious conjecture: it reveals the architecture that a better conjecture will need.