# Cubical Recipe Spaces: Fibers, Substitution Paths, and Parity Classification

**Aristotle**  
**30 July 2026**

## Abstract

We introduce a finite combinatorial framework for studying recipe variation over a fixed observable flavor profile. A recipe is decomposed into a core component, representing its measured flavor, and an optional component, representing ingredient choices ignored by that measurement. The fiber over any fixed flavor is shown to be naturally equivalent to the optional state space. Consequently, one binary option yields exactly two recipe states, while $n$ independent binary substitutions yield the $2^n$ vertices of an $n$-cube.

Substitution methods are modeled as finite lists of coordinate toggles. We define the parity signature of a method and prove an endpoint formula: executing a method from a binary recipe state is coordinatewise exclusive-or with its signature. It follows that two methods have the same endpoint from a fixed recipe if and only if their signatures agree. Independent substitutions form commuting squares, repeated substitutions cancel, loops are exactly the methods of zero signature, and every method followed by its reversal is a loop. These results provide the elementary path and square structure of a cubical recipe model. We distinguish this proved finite framework from stronger topological claims, explain when a two-state cookie model represents $S^0$, and specify the additional structure required for nontrivial fundamental groups or data-driven homology. Algorithms, complexity bounds, constrained variants, and applications to substitution planning are discussed.

## 1. Introduction

Recipes are commonly represented as linear instructions, but variation among recipes is inherently spatial. Optional ingredients create alternative states; substitutions create transitions; independent substitutions create squares; and sequences of reversible changes create loops. A mathematical treatment should therefore distinguish at least three objects: an observable dish, the family of recipes that realize it, and the methods that transform one recipe into another.

The language of fibers and paths provides this distinction. A flavor map sends each recipe to its observable flavor profile. Recipes with the same profile form a fiber. Within a discrete combinatorial model, substitutions connect recipe states by edges and longer methods trace edge paths. This paper develops that model completely for independent binary choices.

The model is intentionally finite and exact. It does not assume that actual culinary flavor is binary, that optional ingredients are perceptually invisible, or that every substitution preserves flavor. Instead, it isolates the consequences of a declared abstraction. Once a modeler has chosen which data constitute the core and which choices are optional, the fiber theorem identifies all recipes over a fixed core. Once binary choices and coordinate toggles are selected, parity completely classifies method endpoints.

The main contributions are as follows.

1. We prove that the fiber over a fixed flavor is naturally equivalent to the optional ingredient state space.
2. We derive exact cardinalities: one binary option gives two states, and $n$ independent binary options give $2^n$ states.
3. We prove the endpoint formula $\operatorname{follow}(r,p)=r\oplus\sigma(p)$.
4. We obtain a complete endpoint classification by parity signatures.
5. We establish the commuting-square, backtracking, loop, and reversal laws.
6. We give linear-time algorithms for signatures, endpoint evaluation, loop detection, and endpoint comparison.
7. We clarify the topological interpretation: a discrete two-state fiber realizes $S^0$, whereas a full cube is contractible, and nontrivial fundamental groups require constrained or cyclic spaces.

## 2. The fiber model of flavor

### 2.1 Core and optional data

Let $C$ be a set of observable core states and let $O$ be a set of optional ingredient states. A **recipe** is an ordered pair

$$
R=(c,o)\in C\times O.
$$

The word “optional” is relative to the chosen observation. It means that the flavor map described below does not inspect this component; it does not claim that the ingredient has no physical or sensory effect in reality.

**Definition 2.1 (Flavor map).** The flavor map is the projection

$$
F:C\times O\longrightarrow C,\qquad F(c,o)=c.
$$

For $d\in C$, the recipes observed as $d$ form a fiber.

**Definition 2.2 (Flavor fiber).** The flavor fiber over $d$ is

$$
\mathcal F_d=\{(c,o)\in C\times O:F(c,o)=d\}.
$$

Equivalently, $\mathcal F_d$ consists of all pairs whose first coordinate is $d$.

### 2.2 Classification of fixed-flavor recipes

**Theorem 2.3 (Fiber Equivalence Theorem).** For every $d\in C$, the flavor fiber $\mathcal F_d$ is naturally in bijection with $O$.

**Proof sketch.** Define $\Phi:\mathcal F_d\to O$ by $\Phi(c,o)=o$. Since membership in $\mathcal F_d$ implies $c=d$, define the inverse $\Psi:O\to\mathcal F_d$ by $\Psi(o)=(d,o)$. Then $\Phi(\Psi(o))=o$. Conversely, if $(c,o)\in\mathcal F_d$, then $c=d$, so $\Psi(\Phi(c,o))=(d,o)=(c,o)$. Thus $\Phi$ and $\Psi$ are mutually inverse. $\square$

This theorem is structural rather than numerical. It says that the optional state space exactly parametrizes recipe variation left invisible by the flavor map.

**Corollary 2.4 (One binary option).** If $O=\{0,1\}$, then every flavor fiber contains exactly two recipes.

**Proof sketch.** Apply the Fiber Equivalence Theorem and count the two elements of $O$. $\square$

This is the minimal cookie model: one may let $0$ denote “without nuts” and $1$ denote “with nuts,” provided the selected core observation assigns both recipes the same flavor $d$.

**Corollary 2.5 (Independent binary options).** If

$$
O=\{0,1\}^n,
$$

then every flavor fiber has cardinality

$$
|\mathcal F_d|=2^n.
$$

**Proof sketch.** The fiber is in bijection with $O$. A binary function on $n$ coordinates has two independent values at each coordinate, hence $2^n$ assignments. $\square$

## 3. The Boolean cube of recipes

Fix a nonnegative integer $n$. Let

$$
Q_n=\{0,1\}^n
$$

be the set of binary recipe states. We regard $Q_n$ as the vertex set of the $n$-dimensional cube. Coordinate $i$ records the status of the $i$th optional choice.

### 3.1 Coordinate toggles

**Definition 3.1 (Toggle).** For a coordinate $i\in\{1,\ldots,n\}$, define $T_i:Q_n\to Q_n$ by

$$
(T_i r)_j=
\begin{cases}
1-r_j,&j=i,\\
r_j,&j\ne i.
\end{cases}
$$

Equivalently, using Boolean exclusive-or,

$$
(T_i r)_j=r_j\oplus [j=i],
$$

where $[j=i]$ equals $1$ when $j=i$ and $0$ otherwise.

**Lemma 3.2 (Commutativity of toggles).** For all coordinates $i,j$ and states $r$,

$$
T_i(T_j(r))=T_j(T_i(r)).
$$

**Proof sketch.** Evaluate both sides at an arbitrary coordinate $k$. Each side equals

$$
r_k\oplus[k=j]\oplus[k=i].
$$

Associativity and commutativity of exclusive-or make the expressions equal. The argument also covers $i=j$. $\square$

**Lemma 3.3 (Involutivity).** For every coordinate $i$ and state $r$,

$$
T_i(T_i(r))=r.
$$

**Proof sketch.** At coordinate $j$, the result is

$$
r_j\oplus[j=i]\oplus[j=i]=r_j,
$$

because a Boolean value exclusive-or itself is $0$. $\square$

### 3.2 Methods and execution

**Definition 3.4 (Substitution method).** A method is a finite list of coordinates

$$
p=[i_1,i_2,\ldots,i_k].
$$

Its length $k$ is the number of substitution steps, including steps that may later cancel.

**Definition 3.5 (Following a method).** Execution proceeds from left to right. The empty method leaves $r$ unchanged, and a nonempty method begins by applying its first toggle:

$$
\operatorname{follow}(r,[])=r,
$$

$$
\operatorname{follow}(r,[i_1,\ldots,i_k])
=\operatorname{follow}(T_{i_1}(r),[i_2,\ldots,i_k]).
$$

**Lemma 3.6 (Concatenation law).** If $p$ and $q$ are methods and $p\mathbin{+\!+}q$ denotes list concatenation, then

$$
\operatorname{follow}(r,p\mathbin{+\!+}q)
=\operatorname{follow}(\operatorname{follow}(r,p),q).
$$

**Proof sketch.** Induct on the length of $p$. The empty case is immediate. For a method beginning with $i$, execute $T_i$ first and apply the induction hypothesis to the remaining list. $\square$

The concatenation law states that execution respects temporal composition: completing $p$ and then $q$ is equivalent to executing their concatenated instruction list.

## 4. Parity signatures and endpoint classification

### 4.1 Signatures

**Definition 4.1 (Parity signature).** The signature of a method $p$ is the vector $\sigma(p)\in Q_n$ whose $j$th coordinate is

$$
\sigma(p)_j=\#\{t:i_t=j\}\pmod 2.
$$

Thus $\sigma(p)_j=1$ exactly when coordinate $j$ occurs an odd number of times in $p$.

The empty method has zero signature. Prefixing a method by $i$ toggles the $i$th bit of its signature.

### 4.2 Endpoint formula

**Theorem 4.2 (Endpoint Formula).** For every state $r\in Q_n$, method $p$, and coordinate $j$,

$$
\operatorname{follow}(r,p)_j=r_j\oplus\sigma(p)_j.
$$

Equivalently,

$$
\operatorname{follow}(r,p)=r\oplus\sigma(p),
$$

where exclusive-or is applied coordinatewise.

**Proof sketch.** Induct on $p$. For the empty list, $\operatorname{follow}(r,[])=r$ and $\sigma([])=0$, so the claim is immediate. Suppose $p$ begins with coordinate $i$ and has tail $p'$. By definition, execution first replaces $r$ by $T_i(r)$ and then follows $p'$. The induction hypothesis gives

$$
\operatorname{follow}(T_i(r),p')_j
=(T_i(r))_j\oplus\sigma(p')_j.
$$

The toggle formula replaces $(T_i(r))_j$ by $r_j\oplus[j=i]$. Meanwhile, the signature of the prefixed method is $[j=i]\oplus\sigma(p')_j$. Associativity and commutativity of exclusive-or identify the two expressions. $\square$

This theorem compresses an arbitrarily long history into $n$ bits. The final state depends on how many times each coordinate was toggled only modulo $2$.

### 4.3 Complete classification

**Theorem 4.3 (Endpoint Classification Theorem).** Fix $r\in Q_n$. For any methods $p$ and $q$,

$$
\operatorname{follow}(r,p)=\operatorname{follow}(r,q)
\quad\Longleftrightarrow\quad
\sigma(p)=\sigma(q).
$$

**Proof sketch.** If the signatures agree, the Endpoint Formula gives the same coordinatewise exclusive-or with $r$, hence equal endpoints. Conversely, suppose the endpoints agree. For every coordinate $j$,

$$
r_j\oplus\sigma(p)_j=r_j\oplus\sigma(q)_j.
$$

Cancellation of the common Boolean term $r_j$ yields $\sigma(p)_j=\sigma(q)_j$. Therefore the signatures agree in every coordinate. $\square$

The theorem is stronger than a one-way invariant statement: signature is not merely preserved by endpoint equality; it is complete for endpoint equality.

## 5. Cubical path laws

### 5.1 Commuting squares

**Theorem 5.1 (Substitution Square).** For every state $r$ and coordinates $i,j$,

$$
\operatorname{follow}(r,[i,j])
=
\operatorname{follow}(r,[j,i]).
$$

**Proof sketch.** The left side is $T_j(T_i(r))$ and the right side is $T_i(T_j(r))$. They agree by commutativity of toggles. Alternatively, both methods have the same signature. $\square$

When $i\ne j$, the two methods trace the two sides of a square from one vertex to the opposite vertex. This is the elementary two-dimensional cell structure generated by independent substitutions.

### 5.2 Immediate cancellation

**Theorem 5.2 (Backtracking Law).** For every state $r$ and coordinate $i$,

$$
\operatorname{follow}(r,[i,i])=r.
$$

**Proof sketch.** The execution is $T_i(T_i(r))$, which equals $r$ by involutivity. $\square$

### 5.3 Loop criterion

**Definition 5.3 (Loop at a recipe).** A method $p$ is a loop based at $r$ if

$$
\operatorname{follow}(r,p)=r.
$$

**Theorem 5.4 (Zero-Signature Loop Criterion).** A method $p$ is a loop at $r$ if and only if

$$
\sigma(p)=0.
$$

Equivalently, every coordinate occurs in $p$ an even number of times.

**Proof sketch.** The empty method has endpoint $r$ and zero signature. Apply the Endpoint Classification Theorem to $p$ and the empty method. $\square$

An immediate consequence is that loophood is independent of the base recipe in the full cube. If a method is a loop at one vertex, its zero signature makes it a loop at every vertex.

### 5.4 Reversal loops

Let $p^{\mathrm{rev}}$ denote the reversal of $p$.

**Theorem 5.5 (Method-Reversal Theorem).** For every state $r$ and method $p$,

$$
\operatorname{follow}(r,p\mathbin{+\!+}p^{\mathrm{rev}})=r.
$$

**Proof sketch.** Every occurrence in $p$ appears once more in $p^{\mathrm{rev}}$, so every coordinate has even total multiplicity and the concatenated signature is zero. The Loop Criterion then applies. One may also prove the result inductively: remove the first toggle and matching final toggle, use the induction hypothesis for the interior path, and cancel the outer pair by involutivity. $\square$

This theorem formalizes retracing a method. Since each toggle is its own inverse, reversing the order gives the inverse path.

## 6. Algorithms

The theory yields direct algorithms for finite recipe systems.

### 6.1 Signature computation

Given $n$ and a method $p$ of length $k$, initialize an $n$-bit zero vector. Scan $p$ from left to right and flip the bit indexed by each coordinate. The final vector is $\sigma(p)$.

The running time is $O(k)$, since each method entry causes one constant-time bit flip. The storage requirement is $O(n)$ for an explicit vector, or $O(m)$ with a sparse representation when only $m$ distinct coordinates occur.

### 6.2 Endpoint computation

Compute $\sigma(p)$ and exclusive-or it with $r$. This takes $O(k+n)$ time with an explicit output vector and $O(n)$ memory. A direct simulation also takes $O(k+n)$ when the state is mutable, but the signature representation is reusable across many starting recipes.

### 6.3 Same-endpoint and loop tests

Two methods have the same endpoint from any fixed state exactly when their signatures match. Compute both signatures in $O(|p|+|q|)$ time and compare them in $O(n)$ time. A method is a loop exactly when its signature is the zero vector, so loop detection takes $O(k+n)$ time.

### 6.4 Canonical representative

Each endpoint class has a short representative: list each coordinate whose signature bit is $1$ exactly once, in increasing order. This representative has length equal to the Hamming weight $|\sigma(p)|$. It reaches the same endpoint as $p$ and is shortest among coordinate-toggle methods, since every changed coordinate must be toggled at least once.

**Proposition 6.1 (Shortest parity representative).** Let $p$ be a method. The increasing list of coordinates on which $\sigma(p)$ equals $1$ reaches the same endpoint as $p$ from every starting state and has minimal possible length among all methods with that endpoint action.

**Proof sketch.** The listed coordinates produce signature $\sigma(p)$, so endpoint equality follows from the classification theorem. Any method with this signature must mention every coordinate having signature bit $1$ at least once; hence its length is at least the signature’s Hamming weight. The proposed representative achieves that bound. $\square$

## 7. Topological interpretation

### 7.1 The discrete cookie fiber

A one-choice fiber has two elements. If no substitution edge is included, its geometric realization is two isolated points, homeomorphic to the zero-sphere $S^0$. This interpretation is faithful only under the discrete adjacency rule.

If the nut toggle is included as an edge, the two vertices and their connecting edge form a closed interval. That space is contractible, not $S^0$. Therefore the set of states alone does not determine the topology; one must also specify allowed edges and higher cells.

### 7.2 Full cubes

For $n$ independent choices, adding every toggle edge gives the one-skeleton of an $n$-cube. Adding a square for each pair of independent toggles and, more generally, higher cells for mutually independent toggles gives the full cubical complex. Its geometric realization is the ordinary cube $[0,1]^n$, which is contractible.

The commuting-square theorem supplies the elementary boundary equality expected of each square. It shows that order-$i$-then-$j$ and order-$j$-then-$i$ share endpoints. To pass from endpoint equality to a complete path-homotopy theory, one additionally declares these square boundaries to be filled and specifies path reductions.

### 7.3 Constrained subspaces

Nontrivial topology naturally arises when constraints remove vertices, edges, or higher cells. Let $A\subseteq Q_n$ be the set of admissible recipes, perhaps determined by allergies, ingredient compatibility, availability, cost, or flavor tolerance. Retain a toggle edge only when both endpoints are admissible. The resulting induced cubical subspace may be disconnected or may contain cycles not filled by squares.

For example, removing the center-filling structure associated with constraints can leave a cyclic graph. Such a graph has a nontrivial fundamental group. The relevant topological invariant is then a property of the declared constrained space, not of the unconstrained Boolean state set alone.

### 7.4 Requirements for an integer winding number

A claim that a recipe space has fundamental group $\mathbb Z$ requires a specified circle-like model. One construction is a finite cycle graph with oriented edges representing stages such as increasing spice, simmering, adding coconut milk, and returning through a balancing step. After defining edge paths, immediate backtracking reduction, and homotopy, one can assign each loop an integer winding number. Proving that winding number classifies loops would establish a fundamental group isomorphic to $\mathbb Z$.

The present cube model does not imply that conclusion. In the full cube, commuting squares fill elementary cycles and the realization is contractible. The distinction prevents a suggestive culinary narrative from being mistaken for a topological theorem without an explicit space.

## 8. Applications

### 8.1 Constraint-aware substitution planning

A recipe assistant can represent optional decisions as coordinates and constraints as an admissibility predicate. In the unconstrained case, the signature gives a shortest transformation immediately. In the constrained case, graph search can seek a legal path while parity supplies a necessary endpoint condition and a useful state summary.

### 8.2 Comparing culinary methods

Two instruction sequences may look different while inducing the same net optional changes. Signature comparison detects this equivalence at the endpoint level. It is useful for deduplicating transformation plans, simplifying generated instructions, and explaining why reorderings of independent substitutions do not alter the result.

### 8.3 Reproducible analysis of recipe datasets

For measured data, let each recipe have a flavor vector in $\mathbb R^m$. Choose a distance, such as Euclidean distance, and a tolerance $\varepsilon$. One may connect two recipes when their distance is at most $\varepsilon$, or build a simplicial complex by a declared neighborhood rule. Connected components and persistent homology can then be computed across scales. The metric, threshold, and simplex rule are essential parts of the experiment; without them, a claim about the topology of “the recipe space” is underdetermined.

### 8.4 Multi-state ingredients

Binary coordinates can be replaced by finite sets $O_i$. The optional state space becomes

$$
O=\prod_{i=1}^n O_i,
$$

and the fiber cardinality becomes

$$
|\mathcal F_d|=\prod_{i=1}^n |O_i|.
$$

Substitutions may act by cyclic increments or by permutations of ingredient states. Boolean parity is then replaced by the algebra of the acting cyclic or permutation groups. The binary theory is the special case in which each coordinate carries the two-element group.

## 9. Discussion and limitations

The framework separates three levels that are often conflated. First, the fiber theorem concerns a projection model: once a recipe is defined as core plus optional data, the fixed-core fiber is exactly the optional space. Second, the parity theorems concern a chosen action of coordinate toggles on binary states. Third, topological conclusions concern the edges and cells used to realize those states geometrically.

This separation gives the model both clarity and limits. “Same flavor” means equality in the declared core space, not sensory identity certified by experiment. Independence means that every binary assignment is permitted and every coordinate toggle acts without changing other coordinates. Real substitutions may interact, making the Boolean cube an approximation. Furthermore, endpoint classification is not itself classification of paths up to homotopy. To obtain the latter, one must define a rewriting or cell-based equivalence on methods.

Within those boundaries, the results are complete. Every endpoint action is represented by one of $2^n$ signatures. The coordinate toggles generate an abelian group in which each generator has order two, isomorphic to $(\mathbb Z/2\mathbb Z)^n$. The recipe cube is a torsor for this group: each signature acts on each state by exclusive-or, freely and transitively. This algebraic viewpoint explains cancellation, commutation, and endpoint classification in a single structure.

## 10. Future work

A first extension is to define the full cubical set explicitly, with vertices given by binary assignments, edges by single toggles, and higher cubes by sets of independent toggles. Its geometric realization should recover the contractible cube, while selected discrete fibers can realize $S^0$.

A second direction is a rewriting theory of methods. Generate an equivalence by deleting adjacent duplicate toggles and swapping adjacent independent toggles. One expects two methods to be equivalent exactly when their signatures agree. This would strengthen endpoint classification to a normal-form theorem about transformations themselves.

Third, constrained recipe predicates should be studied systematically. Induced subcomplexes can model allergies, incompatibilities, availability, cost bounds, and flavor preservation. Finite algorithms can compute connected components, shortest legal paths, cycle ranks, and higher-dimensional features.

Fourth, a genuine circle model can be built for cyclic culinary processes. A finite cyclic substitution graph, together with edge-path reduction and winding number, would support a precise theorem that loop classes form $\mathbb Z$.

Fifth, empirical flavor maps should be integrated only with reproducible choices of measurement, distance, threshold, and complex construction. Persistent homology can then distinguish robust structure from sampling noise.

Finally, non-binary ingredient states lead from Boolean cubes to products of finite state spaces and from parity actions to cyclic and permutation-group actions. This generalization may capture ordered spice levels, preparation states, and interchangeable ingredient families.

## 11. Conclusion

A finite recipe model already supports a precise geometry. Fixing the observed flavor leaves exactly the optional ingredient data. Independent binary choices create the vertices of a cube. Substitution methods become paths generated by coordinate toggles, and their endpoints are classified completely by parity signatures. Commuting squares record independent orderings, duplicate toggles cancel, zero signatures characterize loops, and reversal retraces every method.

The framework does not assign topology to cuisine by metaphor alone. It identifies the data needed to do so: states, allowed substitutions, higher cells, constraints, and empirical flavor rules. With those choices made explicit, recipe variation becomes a tractable setting in which combinatorics, algebra, geometry, and computation meet.
