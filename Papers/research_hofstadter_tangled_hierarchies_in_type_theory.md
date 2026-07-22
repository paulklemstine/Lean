# Tangled Hierarchies, Predicative Levels, and the Diagonal Boundary

**Aristotle**  
**July 22, 2026**

## Abstract

Hierarchical systems often exhibit apparent feedback: an object may be re-expressed at a higher level and later recovered, while polymorphic operations recur across many levels. This paper separates such reversible changes of presentation from genuine cycles in strict dependency and from unrestricted semantic self-representation. For an arbitrary relation, a tangle is defined as a pair $x,y$ satisfying both $x\mathrel r y$ and $y\mathrel r x$. We prove that well-founded relations exclude tangles. More constructively, a natural-valued rank that strictly decreases along dependency edges establishes well-foundedness, forces strict rank descent along every nonempty finite path, and excludes finite cycles of every length. Applied to universe indices ordered by $<$, these results show that the hierarchy $\mathcal U_0,\mathcal U_1,\ldots$ is simultaneously well-founded, untangled, unbounded, and without a maximal level.

We then model universe raising as a higher-level copy $L(A)$ equivalent to $A$. Raising followed by lowering preserves every value, and iterated raising is coherent with iterated projection. Such round trips are presentation loops, not reverse edges in universe order. Finally, a Cantor--Lawvere diagonal argument shows that no set of codes can represent every predicate on itself. More generally, point-surjective self-representation $R:C\to(C\to O)$ forces every endomorphism of $O$ to possess a fixed point. These results identify three distinct logical strengths: cyclic dependency, reversible transport, and universal semantic coding. They locate a precise diagonal obstruction relevant to self-typing systems while making no claim that reversible lifting alone creates impredicativity or that the argument constitutes a complete derivation of paradox for every dependent calculus.

## 1. Introduction

Hierarchies organize dependency. In a stratified language, objects occupy levels; in recursive computation, calls descend through a measure; in a build graph, prerequisites precede their consumers. Yet sophisticated systems also contain feedback-like behavior. A program manipulates programs, a language describes its own expressions, or an object is transported to a larger ambient level and returned. These phenomena motivate the metaphor of a tangled hierarchy: movement that appears to go both upward and downward at once.

The metaphor is suggestive but mathematically underdetermined. At least three structures can look like loops:

1. a directed cycle in the strict dependency relation;
2. mutually inverse or retracting maps between two presentations of the same data;
3. an internal coding mechanism rich enough to represent all observations about its own codes.

Their logical behavior differs sharply. A directed dependency cycle contradicts any asymmetric hierarchy law. A reversible representation change can be entirely benign. Universal semantic representation supports diagonal substitution and may force impossible fixed points. The purpose of this paper is to state and prove these distinctions in a compact, reusable framework.

A terminological caution is essential. A strict partial order cannot contain $x<y$ and $y<x$, because strict orders are asymmetric. We therefore do not define a tangled hierarchy as a special partial order. We define tangling for an arbitrary binary relation and then prove its incompatibility with well-foundedness, rank descent, or asymmetry. This keeps the contradiction visible rather than hiding it in an inconsistent definition.

Our main contributions are as follows. First, we characterize a tangle as a directed closed walk of length two and exclude it in every well-founded relation. Second, we develop a rank certificate that excludes all finite dependency cycles, not only two-cycles. Third, we apply the theory to the natural-number indexing of predicative universes, establishing both untangledness and unboundedness. Fourth, we show that raising and lowering presentations is coherent and does not reverse level order. Fifth, we isolate the semantic boundary: point-surjective self-representation implies a universal fixed-point theorem, while truth-valued negation yields the impossibility of enumerating all predicates.

The resulting picture is deliberately modest and precise. It does not identify a lower universe with a higher one. It does not infer universal self-representation from polymorphic lifting. It also does not claim a full internal reconstruction of Girard’s paradox, which would require fixing a particular impredicative dependent calculus and studying its rules. Instead, it identifies a structural fragment common to diagonal paradoxes and explains why safe transport does not provide that fragment.

## 2. Relations, tangles, and hierarchy laws

### 2.1 Dependency relations

Let $X$ be a set or collection and let $r\subseteq X\times X$ be a binary relation. We read $x\mathrel r y$ as “$x$ depends strictly on $y$,” “$x$ is below $y$,” or “$x$ is a child of $y$.” The direction is chosen so that following dependency edges moves downward.

**Definition 2.1 (Tangle).** The relation $r$ is **tangled** if there exist $x,y\in X$ such that

$$
x\mathrel r y \quad\text{and}\quad y\mathrel r x.
$$

No transitivity, irreflexivity, or asymmetry is assumed in this definition.

**Proposition 2.2 (Two-cycle characterization).** A relation $r$ is tangled if and only if there exist $x_0,x_1,x_2\in X$ such that

$$
x_2=x_0,\qquad x_0\mathrel r x_1,\qquad x_1\mathrel r x_2.
$$

**Proof sketch.** Given a tangle $x\mathrel r y\mathrel r x$, choose $x_0=x$, $x_1=y$, and $x_2=x$. Conversely, substitute $x_2=x_0$ into the displayed closed walk to recover $x_0\mathrel r x_1$ and $x_1\mathrel r x_0$. $\square$

This elementary equivalence clarifies that tangling is a local, length-two condition. Longer cycles will be handled through ranks.

### 2.2 Well-foundedness and asymmetry

A relation $r$ is **well-founded** if every $x\in X$ is accessible: informally, every chain of recursive appeals to smaller elements eventually terminates. Equivalently in standard set-theoretic settings, there is no infinite sequence $x_0,x_1,\ldots$ satisfying $x_{n+1}\mathrel r x_n$ for all $n$. Well-founded strict relations are asymmetric.

**Theorem 2.3 (Well-founded relations are untangled).** If $r$ is well-founded, then there do not exist $x,y\in X$ with both $x\mathrel r y$ and $y\mathrel r x$.

**Proof sketch.** Well-foundedness implies asymmetry: if $x\mathrel r y$, then $y\mathrel r x$ is impossible. A tangle supplies exactly this forbidden reverse pair. Alternatively, alternating $x,y,x,y,\ldots$ constructs an infinite descending sequence. $\square$

Asymmetry itself is the exact local law at issue.

**Theorem 2.4 (A tangle forces hierarchy failure).** If $r$ is tangled, then $r$ cannot satisfy

$$
\forall x,y\in X,\quad x\mathrel r y\Longrightarrow \neg(y\mathrel r x).
$$

Consequently, asserting both this asymmetry law and the existence of a tangle yields a contradiction.

**Proof sketch.** Choose witnesses $x,y$ to the tangle. Applying asymmetry to $x\mathrel r y$ gives $\neg(y\mathrel r x)$, contrary to the second tangle edge. $\square$

Thus a consistent description cannot simultaneously retain a genuine two-cycle and call the same relation a strict asymmetric hierarchy. One must abandon the cycle, weaken the hierarchy law, or accept inconsistency.

## 3. Ranked hierarchies and finite-cycle exclusion

### 3.1 Natural-valued ranks

A practical way to certify well-foundedness is to map dependencies into a known well-founded order.

**Definition 3.1 (Natural-ranked hierarchy).** A natural-ranked hierarchy consists of a set $X$, a dependency relation $r$, and a rank function $\rho:X\to\mathbb N$ such that

$$
x\mathrel r y\Longrightarrow \rho(x)<\rho(y).
$$

Ranks need not distinguish unrelated objects. Their sole obligation is strict decrease along dependency edges.

**Theorem 3.2 (Rank descent implies well-foundedness).** Every natural-ranked hierarchy has a well-founded dependency relation.

**Proof sketch.** If there were an infinite dependency descent $x_0,x_1,\ldots$ with $x_{n+1}\mathrel r x_n$, then

$$
\rho(x_0)>\rho(x_1)>\rho(x_2)>\cdots
$$

would be an infinite strictly decreasing sequence of natural numbers, which does not exist. More structurally, $r$ is contained in the inverse image of $<$ under $\rho$, and well-foundedness is inherited by subrelations. $\square$

**Corollary 3.3 (Ranked hierarchies are untangled).** A natural-ranked hierarchy contains no pair $x,y$ with $x\mathrel r y$ and $y\mathrel r x$.

This follows immediately from Theorems 2.3 and 3.2. A direct proof would combine $\rho(x)<\rho(y)$ and $\rho(y)<\rho(x)$.

### 3.2 Paths and arbitrary finite cycles

Let a finite dependency path of length $n$ be a sequence $x_0,x_1,\ldots,x_n$ satisfying

$$
x_{i+1}\mathrel r x_i\qquad(0\le i<n).
$$

**Theorem 3.4 (Finite-path rank descent).** In a natural-ranked hierarchy, every finite dependency path of positive length satisfies

$$
\rho(x_n)<\rho(x_0).
$$

**Proof sketch.** Induct on $n$. For $n=1$, the conclusion is precisely the rank-decrease condition. For the induction step, the prefix gives $\rho(x_n)<\rho(x_0)$, while the last edge gives $\rho(x_{n+1})<\rho(x_n)$. Transitivity of $<$ yields $\rho(x_{n+1})<\rho(x_0)$. $\square$

**Theorem 3.5 (No positive-length finite cycle).** In a natural-ranked hierarchy, no dependency path of length $n>0$ satisfies $x_n=x_0$.

**Proof sketch.** Theorem 3.4 gives $\rho(x_n)<\rho(x_0)$. If $x_n=x_0$, substitution yields $\rho(x_0)<\rho(x_0)$, contradicting irreflexivity. $\square$

This result supplies an algorithmic certificate. To validate a proposed hierarchy, check each edge independently for strict rank decrease. If all checks pass, every finite cycle is excluded globally. For a graph with $|E|$ edges, verification takes $O(|E|)$ rank comparisons and $O(|V|)$ storage for the rank map. By contrast, discovering cycles without a supplied rank generally requires a graph traversal, still linear in $|V|+|E|$ but without the explanatory measure of descent.

The converse requires care. An acyclic finite graph always admits a natural rank, for example by topological depth. Infinite well-founded relations may require ordinal-valued ranks, especially when elements have unbounded finite heights beneath them. Therefore natural rankability is a stronger and more computationally concrete certificate than mere absence of cycles in arbitrary infinite systems.

## 4. Predicative universe levels

### 4.1 The level order

Model universe levels by $\mathbb N$. Define level $i$ to be below level $j$ precisely when

$$
i<j.
$$

This direction represents the strict stratification

$$
\mathcal U_0 : \mathcal U_1 : \mathcal U_2 : \cdots,
$$

where objects classified at one stage are discussed from a higher stage. The notation is schematic: the mathematical claim concerns indices and their strict order, not an identification of a universe with its successor.

**Theorem 4.1 (Well-foundedness of universe indices).** The relation $<$ on natural-number universe indices is well-founded in the dependency direction.

**Proof sketch.** Natural numbers admit no infinite strictly decreasing sequence. Equivalently, induction on $n$ establishes accessibility of every index $n$. $\square$

**Corollary 4.2 (Universe levels are untangled).** There are no natural-number levels $i,j$ such that both $i<j$ and $j<i$.

**Theorem 4.3 (Unboundedness of universe levels).** Every universe index has a strictly higher index:

$$
\forall i\in\mathbb N\ \exists j\in\mathbb N,\quad i<j.
$$

**Proof sketch.** Set $j=i+1$. $\square$

Theorems 4.1--4.3 jointly show that the standard level hierarchy is infinite but untangled. It has no maximal index, yet its dependency direction is well-founded. “There is always a higher level” does not imply “levels eventually return to themselves.” An unbounded ascending ladder and a descending well-founded order coexist without tension.

### 4.2 Why polymorphism does not collapse levels

A universe-polymorphic construction can be instantiated at many levels. Reuse of one schematic operation does not identify those levels. The distinction resembles a formula $n\mapsto n+1$ used for every $n$: the operation is uniform, but $n$ and $n+1$ remain unequal.

This observation becomes concrete through lifting. For a type or collection $A$ at one level, define a lifted presentation $L(A)$ at a higher level. Each $a\in A$ has a wrapped representative $\operatorname{up}(a)\in L(A)$, and each lifted value has an underlying value obtained by $\operatorname{down}:L(A)\to A$. The maps exhibit an equivalence of represented data.

**Theorem 4.4 (Single-lift coherence).** For every $a\in A$,

$$
\operatorname{down}(\operatorname{up}(a))=a.
$$

**Proof sketch.** The lowering map is defined as the inverse of the canonical raising map on the lifted copy, so the inverse law applies. $\square$

**Theorem 4.5 (Double-lift coherence).** For every $a\in A$, two lifts followed by two projections recover $a$:

$$
\operatorname{down}\!\left(\operatorname{down}\!\left(
\operatorname{up}(\operatorname{up}(a))\right)\right)=a.
$$

**Proof sketch.** Apply single-lift coherence first to the outer wrapper, leaving $\operatorname{down}(\operatorname{up}(a))$, and apply it again. $\square$

These equalities produce closed paths among presentations. They do not produce a closed path in the strict order on indices. The upward operation changes the ambient presentation; the downward operation forgets a wrapper. Neither theorem asserts that a higher index is below a lower index. Hence reversible transport is compatible with predicative stratification.

A useful categorical formulation is that an equivalence or retraction concerns morphisms between representations, whereas strict level dependency concerns an external grading. A graded category may contain isomorphic objects represented at different administrative grades without admitting grade inequalities in both directions. The grade and the object-level morphism are distinct data.

## 5. Universal self-representation and diagonalization

### 5.1 Predicates cannot all be internally indexed

Let $C$ be a set of codes. A predicate on $C$ is a map $P:C\to\mathsf{Prop}$, where $\mathsf{Prop}$ denotes truth values. A representation scheme is a map

$$
R:C\to(C\to\mathsf{Prop}).
$$

It is **unrestricted** if $R$ is surjective: every predicate $P$ equals $R(c)$ for some $c\in C$.

**Theorem 5.1 (No unrestricted predicate self-representation).** For every set $C$, there is no surjective map

$$
R:C\to(C\to\mathsf{Prop}).
$$

**Proof sketch.** Suppose $R$ is surjective. Define the diagonal predicate

$$
D(c)\;\Longleftrightarrow\;\neg R(c)(c).
$$

By surjectivity, choose $d\in C$ with $R(d)=D$. Evaluating both sides at $d$ yields

$$
R(d)(d)\;\Longleftrightarrow\;D(d)\;\Longleftrightarrow\;\neg R(d)(d),
$$

which is impossible. $\square$

The theorem is a semantic version of Cantor diagonalization. It does not say that no syntax can encode predicates. Countable languages routinely encode countably many formulas. It says that no code set can surject onto **all** predicates on itself. Restrictions on definability, stratification, or evaluation are therefore not incidental; they prevent the universal surjectivity required by the diagonal.

### 5.2 The fixed-point boundary

The predicate theorem is an instance of a more general result. Let $C$ be a set of codes, $O$ a set of observations, and

$$
R:C\to(C\to O)
$$

an evaluator assigning to each code a function from codes to observations. Say $R$ is point-surjective when every function $C\to O$ is represented by some code.

**Theorem 5.2 (Self-representation fixed-point theorem).** If $R:C\to(C\to O)$ is surjective, then every transformation $t:O\to O$ has a fixed point. That is, for every $t$ there exists $o\in O$ such that

$$
t(o)=o.
$$

**Proof sketch.** Define $g:C\to O$ by

$$
g(c)=t(R(c)(c)).
$$

Surjectivity provides $d\in C$ such that $R(d)=g$. Let $o=R(d)(d)$. Then

$$
o=R(d)(d)=g(d)=t(R(d)(d))=t(o).
$$

Thus $o$ is a fixed point of $t$. $\square$

For $O=\mathsf{Prop}$, take $t$ to be negation. Negation has no fixed truth value, so the hypothesized surjection cannot exist, recovering Theorem 5.1.

This theorem pinpoints the true diagonal boundary. Self-reference alone is not enough. The argument requires a representation mechanism covering every map $C\to O$, together with diagonal evaluation $R(c)(c)$. Reversible universe lifting offers neither such surjectivity nor such universal semantic evaluation. It preserves a given value; it does not enumerate a function space.

## 6. Algorithms and computational diagnostics

The theoretical distinctions suggest three diagnostics for finite models.

### 6.1 Rank-certificate validation

Given vertices $V$, directed dependency edges $E$, and a proposed rank $\rho:V\to\mathbb N$, inspect each edge $(c,p)\in E$. Reject if $\rho(c)\ge\rho(p)$; otherwise accept. Acceptance certifies well-foundedness for the finite graph and excludes all directed cycles by Theorem 3.5. The running time is $O(|E|)$ and memory is $O(|V|)$ for stored ranks.

### 6.2 Direct two-cycle detection

Store all edges in a hash set. For each $(x,y)$, test whether $(y,x)$ is present. A match is a tangle witness. Expected running time is $O(|E|)$ with hashing and memory $O(|E|)$. This detects exactly Definition 2.1 but does not detect longer cycles. It is therefore a local diagnostic rather than a complete acyclicity test.

### 6.3 Finite diagonal construction

For a finite code set of size $n$, represent a candidate evaluator by an $n\times n$ Boolean table. Its $i$th row is the predicate represented by code $i$. Construct the diagonal complement $D_i=\neg R_{ii}$. Compare $D$ with every row. It differs from row $i$ at coordinate $i$, so it is absent. Construction takes $O(n)$ time; explicit comparison with all rows takes $O(n^2)$ time. The table gives a visible finite analogue of Theorem 5.1.

These algorithms do not replace the general theorems. They illustrate their mechanisms: local rank inequalities aggregate into global acyclicity, reversed edges witness tangles, and diagonal complement escapes any proposed finite list.

## 7. Applications

### 7.1 Terminating recursion and rewriting

A recursive call graph is safe when each call decreases a natural measure such as input size, syntax depth, or remaining fuel. Theorem 3.4 explains why a chain of calls makes aggregate progress, and Theorem 3.5 excludes recursive return to the same state through a positive path. For rewriting systems, ranks can encode term size or a more refined termination ordering.

### 7.2 Build graphs and package dependencies

A build system may assign stages to targets. If every target depends only on a lower-stage prerequisite—or, with the orientation used here, every dependency child has lower rank than its parent—the rank certificate excludes circular builds. A detected two-cycle immediately falsifies asymmetry, while a longer cycle falsifies any proposed strictly decreasing rank.

### 7.3 Staged languages and metaprogramming

Quotation and evaluation often create apparent up-and-down movement between object language and metalanguage. The lifting analysis warns against reading reversible conversions as hierarchy collapse. Safety depends on preserving the external grade and restricting semantic evaluation sufficiently to avoid universal self-coding.

### 7.4 Reflective systems

A system can represent many of its expressions and still avoid contradiction. The diagonal theorem applies only when every predicate or observation function is represented. Practical reflective systems evade the theorem through partial evaluators, stratified truth predicates, restricted code spaces, intensional distinctions, or failure of surjectivity. The fixed-point theorem gives a concise audit question: if an evaluator were point-surjective, which fixed-point-free transformation would refute it?

## 8. Discussion: the boundary of the conclusions

The established results support a three-axis classification.

**Dependency axis.** A true tangle is a pair of reverse edges in one strict relation. Well-foundedness and asymmetry exclude it. Natural rank descent excludes every finite cycle.

**Presentation axis.** A value may have equivalent copies at different ambient levels. Raising and lowering can form a closed route on represented values. This is compatible with an acyclic index order because presentation maps are not level inequalities.

**Semantic axis.** A representation system may attempt to cover all maps from its codes to an observation space. Point-surjectivity activates diagonalization and forces fixed points for all endomorphisms of observations. Truth-valued negation then gives contradiction.

The axes should not be conflated. In particular, double-lift coherence does not imply predicate-space surjectivity. Conversely, the impossibility of universal predicate representation does not prohibit ordinary coding, reflection, or polymorphism. It prohibits a specific totality claim.

The relation to self-typing universes must also be stated carefully. A slogan such as $\mathcal U:\mathcal U$ can bundle several principles: self-classification, dependent-product closure, impredicative quantification, decoding, and extensionality. Theorem 5.1 establishes a diagonal obstruction whenever those principles yield unrestricted predicate representation. It is not by itself a complete syntactic derivation of Girard’s paradox for an unspecified calculus. Determining the minimal contradictory package requires defining the calculus and proving that its rules derive the representation interface used here.

A second limitation concerns ranks. Natural-valued ranks are sufficient for the hierarchies considered and ideal for computation. They do not characterize every well-founded relation. Transfinite ordinal ranks may be necessary where predecessors have unbounded heights. The conceptual invariant is descent into some well-founded order; $\mathbb N$ is the simplest and most algorithmically accessible instance.

## 9. Future research

Several directions follow naturally.

First, one may seek conditions under which well-founded dependency implies natural rankability. For countable relations with finite predecessor sets, finite branching may bound the height under each node; without it, ordinal ranks are the appropriate generalization.

Second, coherent transport can be extended from repeated lifts to a compositional language of lifts, projections, products, and dependent sums. A normalization theorem should show that every closed transport loop acts identically on represented values while the level graph remains acyclic.

Third, the diagonal interface can be derived within explicitly defined impredicative calculi. The key question is whether closure under dependent products and an internal decoding operation entail point-surjective evaluation, and hence fixed points for every truth-value transformation.

Fourth, a minimal boundary for Girard-style contradiction should separate self-typing, dependent-product closure, and extensionality. Removing any one principle may admit a normalizing model; establishing sharp necessity would distinguish hierarchy collapse from harmless recursive syntax.

Finally, ordinal height may quantify the cost of untangling a dependency network. The least decreasing ordinal rank could serve as an invariant under suitable edge-preserving transformations and compare alternative stratifications.

## 10. Conclusion

A hierarchy can look tangled for three very different reasons. It may contain a genuine dependency cycle; it may support reversible movement between presentations; or it may claim universal power to represent its own semantics. The mathematics separates them cleanly.

Well-foundedness excludes two-cycles. A natural-valued rank proves more: rank decreases along every positive finite dependency path, so no such path returns to its source. Natural-number universe indices therefore form an infinite, unbounded, but untangled hierarchy. Universe raising preserves values under projection, even through repeated lifts, because it changes presentation rather than reversing level order. Universal semantic self-representation is stronger: by diagonalization it forces every observation transformation to have a fixed point, and it becomes impossible for predicates because negation has none.

The resulting boundary is both conceptual and practical. Safe self-reference preserves a decreasing rank, separates grades from representation maps, or restricts semantic coverage. Contradiction appears only when distinctions are collapsed strongly enough to create reverse strict edges or unrestricted diagonal coding. The ladder may carry travelers up and down; what it cannot consistently do is make each rung strictly below itself or list every possible truth about its own list.
