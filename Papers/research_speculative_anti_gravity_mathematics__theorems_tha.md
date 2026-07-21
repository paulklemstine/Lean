# Anti-Gravity Theorems in Finite Dependency Spaces

## Abstract

We introduce a graph-theoretic and topological framework for distinguishing the cost of proving a theorem from its downstream mathematical influence. A finite theorem collection is equipped with a directed dependency relation and a nonnegative integer proof-length function. The gravitational weight of a theorem is the number of direct users of that theorem, and an anti-gravity theorem is one whose weight exceeds a prescribed minimum while its proof length remains below a prescribed maximum. Reversing dependency edges from foundations to users and taking reflexive transitive reachability produces a support preorder. The upward-closed subsets of this preorder form an Alexandrov topology. Our principal structural result states that a class of theorems is dense in this topology if and only if every theorem supports a member of the class. Consequently, anti-gravity theorems are dense exactly under a dependency-cofinality condition. We complement this qualitative criterion with a quantitative counting result: if every theorem can be charged to an anti-gravity theorem and no anti-gravity theorem receives more than ten charges, then anti-gravity theorems constitute at least one tenth of the collection. Finally, an edgeless ten-theorem example shows that no unconditional ten-percent law can hold. The framework isolates the assumptions needed for empirical claims about concise, highly reusable mathematical results and suggests algorithms for measuring density, abundance, and structural robustness.

## 1. Introduction

The difficulty of a theorem and the influence of a theorem are different quantities. A long and technically demanding theorem may be used only once, while a short lemma may become indispensable throughout an entire subject. Traditional descriptions such as “fundamental,” “deep,” or “elementary” mix these dimensions. The purpose of this paper is to separate them.

We model a finite body of mathematics by a directed dependency network. Its vertices are theorems. An arrow records direct logical use. Each theorem also receives a proof cost, represented by a natural number. This minimal structure supports two measurements. First, the number of direct users measures local influence. Second, proof length measures local cost. A theorem is called anti-gravity when its influence is high and its cost is low relative to chosen thresholds.

The name is metaphorical, but the theory is precise. The dependency relation generates a reachability relation: a theorem supports every result that can be reached by repeatedly passing from a foundation to one of its users. Reachability, in turn, generates a topology. Open sets are upward-closed sets of results: if an open set contains a theorem, it contains everything downstream that the theorem supports.

This topology gives a rigorous interpretation to the statement that anti-gravity theorems are dense. In ordinary metric spaces, density means that every neighborhood contains a distinguished point. Here, the smallest neighborhood of a theorem is its downstream dependency cone. Density therefore becomes a cofinality statement: every theorem supports some anti-gravity theorem. This equivalence is the main conceptual result.

Topology alone does not control proportions. A dense class can be small. We therefore establish a separate finite counting principle based on bounded charging maps. When every theorem is assigned to an anti-gravity theorem and each target receives at most ten assignments, anti-gravity theorems occupy at least ten percent of the collection. The hypothesis is a certificate that can be checked algorithmically.

An unconditional percentage claim is false. Ten isolated theorems, each with a short proof but no users, contain no positive-weight theorem. This counterexample is essential: it separates the exact structural theorem from an empirical prediction that requires additional assumptions.

The paper proceeds from definitions to topology, then to counting, algorithms, applications, limitations, and future directions. Throughout, all collections are finite unless explicitly stated otherwise.

## 2. Finite theorem systems

### 2.1. Dependency data

A **finite theorem system** is a triple

$$
\mathcal{L}=(V,\to,\ell),
$$

where $V$ is a finite set, $\to$ is a binary relation on $V$, and $\ell:V\to\mathbb{N}$ is a proof-length function. The interpretation of

$$
u\to x
$$

is that theorem $u$ directly uses theorem $x$. Thus arrows point from users to foundations. No acyclicity assumption is required for the results below, although dependency systems arising from sequential mathematical development are typically acyclic after mutually dependent declarations are grouped.

The function $\ell$ may count symbols, lines, primitive inference steps, or weighted operations. The abstract results require only that it take values in $\mathbb{N}$. Any empirical use must specify the convention.

### 2.2. Gravitational weight and anti-gravity

**Definition 2.1 (Gravitational weight).** The gravitational weight of $x\in V$ is the number of direct users of $x$:

$$
w(x)=\bigl|\{u\in V:u\to x\}\bigr|.
$$

Fix a minimum-weight threshold $m\in\mathbb{N}$ and a maximum-length threshold $L\in\mathbb{N}$.

**Definition 2.2 (Anti-gravity theorem).** A theorem $x\in V$ is anti-gravity at thresholds $(m,L)$ if

$$
w(x)\ge m\quad\text{and}\quad \ell(x)\le L.
$$

The corresponding anti-gravity class is

$$
A_{m,L}=\{x\in V:w(x)\ge m\text{ and }\ell(x)\le L\}.
$$

The two inequalities serve different purposes. The first prevents unused short statements from being classified as influential. The second prevents highly reused but prohibitively expensive theorems from being classified as concise. Threshold dependence is intrinsic: increasing $m$ or decreasing $L$ can only shrink $A_{m,L}$.

**Lemma 2.3 (Threshold monotonicity).** If $m'\ge m$ and $L'\le L$, then

$$
A_{m',L'}\subseteq A_{m,L}.
$$

**Proof sketch.** If $x\in A_{m',L'}$, then $w(x)\ge m'\ge m$ and $\ell(x)\le L'\le L$. Hence $x\in A_{m,L}$.

This elementary observation is useful when exploring parameter grids: the anti-gravity classes form a nested family.

### 2.3. Support reachability

The dependency arrows point from a result to its foundations, but influence flows in the reverse direction. Define the one-step foundation-to-user relation by declaring that $x$ supports $u$ in one step when $u\to x$.

**Definition 2.4 (Support).** A theorem $x$ **supports** a theorem $y$, written $x\preceq y$, if there exists a finite sequence

$$
x=x_0,x_1,\ldots,x_r=y
$$

such that $x_{i+1}\to x_i$ for every $0\le i<r$. The case $r=0$ is allowed.

Thus every theorem supports itself. Concatenating support paths shows that support is transitive. It is therefore a preorder. Cycles can make two distinct theorems support each other, so antisymmetry is not assumed.

**Definition 2.5 (Dependency cone).** The cone above $x$ is

$$
C(x)=\{y\in V:x\preceq y\}.
$$

The cone is the full downstream region influenced by $x$, including $x$ itself.

## 3. The dependency topology

### 3.1. Open sets

**Definition 3.1 (Dependency-open set).** A subset $U\subseteq V$ is dependency-open if it is upward closed under support:

$$
x\in U\text{ and }x\preceq y\quad\Longrightarrow\quad y\in U.
$$

**Proposition 3.2 (Alexandrov topology).** The dependency-open subsets form a topology $\tau_{\preceq}$ on $V$. Moreover, arbitrary intersections of dependency-open sets are dependency-open, so $\tau_{\preceq}$ is an Alexandrov topology.

**Proof sketch.** Both $\varnothing$ and $V$ are upward closed. If $U$ and $W$ are upward closed, then membership in $U\cap W$ propagates upward in each set, hence in their intersection. If $x$ belongs to a union of upward-closed sets, it belongs to at least one member of the family; every theorem above $x$ belongs to that same member and hence to the union. The identical argument works for arbitrary intersections because membership in every set propagates upward.

**Proposition 3.3 (Cone neighborhoods).** For each $x\in V$, the cone $C(x)$ is dependency-open and contains $x$. It is the smallest dependency-open set containing $x$.

**Proof sketch.** Reflexivity gives $x\in C(x)$. If $y\in C(x)$ and $y\preceq z$, transitivity gives $x\preceq z$, so $z\in C(x)$. Thus $C(x)$ is open. If an open set $U$ contains $x$, upward closure forces it to contain every $y$ with $x\preceq y$, hence $C(x)\subseteq U$.

The topology is entirely determined by the support preorder. It contains no auxiliary metric and introduces no arbitrary notion of closeness. Two theorems are topologically related precisely through downstream dependence.

### 3.2. Density as dependency-cofinality

A subset $S\subseteq V$ is **dense** when every nonempty open set intersects $S$, equivalently when its closure is all of $V$.

**Theorem 3.4 (Dependency-Density Criterion).** For every subset $S\subseteq V$, the following conditions are equivalent:

1. $S$ is dense in $(V,\tau_{\preceq})$.
2. For every theorem $x\in V$, there exists $y\in S$ such that $x\preceq y$.

In words, a theorem class is dense exactly when every theorem supports a member of that class.

**Proof sketch.** Assume $S$ is dense and fix $x\in V$. The cone $C(x)$ is a nonempty open set because it contains $x$. Density implies $C(x)\cap S\ne\varnothing$. Any $y$ in this intersection satisfies $x\preceq y$ and $y\in S$.

Conversely, assume every $x$ supports some $y\in S$. Let $U$ be a nonempty open set and choose $x\in U$. By hypothesis, there is $y\in S$ with $x\preceq y$. Since $U$ is upward closed, $y\in U$. Thus $U\cap S\ne\varnothing$, proving density.

This criterion turns an apparently topological statement into an exact graph-reachability condition. It also clarifies that density is directional. It is not enough for every anti-gravity theorem to rest on some earlier theorem; every theorem must have an anti-gravity theorem somewhere in its downstream cone.

**Corollary 3.5 (Density of anti-gravity theorems).** Fix thresholds $(m,L)$. If

$$
\forall x\in V\;\exists y\in V:\quad x\preceq y,\quad w(y)\ge m,\quad \ell(y)\le L,
$$

then $A_{m,L}$ is dense in the dependency topology.

**Proof sketch.** The displayed hypothesis says exactly that every $x$ supports a member of $A_{m,L}$. Apply Theorem 3.4.

In fact, Theorem 3.4 also gives the converse: $A_{m,L}$ is dense only if the displayed cofinality condition holds. The corollary is therefore an equivalence when stated with “if and only if.”

### 3.3. Density and cardinality are independent

Topological density should not be confused with numerical prevalence. If a single theorem $a$ lies above every theorem in the support preorder, then $\{a\}$ is dense, regardless of the size of $V$. Conversely, a large subset may fail to be dense if it misses the entire cone above some theorem.

This distinction motivates a second, genuinely quantitative theorem.

## 4. Quantitative abundance by bounded charging

### 4.1. Charging maps

Let $A=A_{m,L}$. A **charging map** is a function

$$
c:V\to A.
$$

Equivalently, it is a function $c:V\to V$ whose image is contained in $A$. Each theorem is assigned to one anti-gravity theorem. For $a\in A$, the fiber

$$
c^{-1}(a)=\{x\in V:c(x)=a\}
$$

is the set of theorems charged to $a$.

**Theorem 4.1 (Ten-Percent Charging Theorem).** Suppose there exists a charging map $c:V\to A_{m,L}$ such that

$$
|c^{-1}(a)|\le 10
$$

for every $a\in A_{m,L}$. Then

$$
|V|\le 10|A_{m,L}|.
$$

Consequently,

$$
|A_{m,L}|\ge \frac{|V|}{10}
$$

in real-valued proportion, or equivalently $|A_{m,L}|\ge\lceil |V|/10\rceil$ in integer form.

**Proof sketch.** The fibers of $c$ are disjoint and cover $V$. Since $c$ maps into $A_{m,L}$,

$$
|V|=\sum_{a\in A_{m,L}}|c^{-1}(a)|.
$$

Each summand is at most $10$, so

$$
|V|\le\sum_{a\in A_{m,L}}10=10|A_{m,L}|.
$$

Rearranging gives the proportion bound.

**Corollary 4.2 (General bounded-fiber principle).** If $c:V\to A_{m,L}$ has fibers of size at most $k$, where $k\ge1$, then

$$
|V|\le k|A_{m,L}|,
$$

and the anti-gravity proportion is at least $1/k$.

**Proof sketch.** Replace $10$ by $k$ in the fiber sum.

The charging theorem is a sufficient condition, not an unconditional frequency law. It is particularly useful because its assumptions are constructive. A proposed assignment can be audited by checking image membership and maximum fiber size.

### 4.2. Relation to density

A charging map into $A_{m,L}$ does not by itself imply dependency density, because $c(x)$ need not lie in the cone $C(x)$. If one strengthens the definition by requiring

$$
x\preceq c(x)
$$

for every $x$, then the same certificate proves both results: its support condition gives density by Theorem 3.4, and its fiber bound gives abundance by Theorem 4.1.

This yields a useful combined certificate.

**Proposition 4.3 (Support-respecting charging certificate).** Suppose $c:V\to A_{m,L}$ satisfies $x\preceq c(x)$ for all $x$ and $|c^{-1}(a)|\le k$ for all $a\in A_{m,L}$. Then $A_{m,L}$ is dense and

$$
|A_{m,L}|\ge |V|/k.
$$

**Proof sketch.** The support condition witnesses dependency-cofinality, and the fiber condition supplies the counting inequality.

## 5. A sharp obstruction to universal percentages

**Theorem 5.1 (Edgeless Ten-Theorem Counterexample).** There exists a theorem system with ten theorems, each of proof length $1$, in which every theorem has gravitational weight $0$. Consequently, at thresholds $(1,1)$ there are no anti-gravity theorems.

**Construction and proof.** Let

$$
V=\{0,1,\ldots,9\},
$$

let the dependency relation be empty, and set $\ell(x)=1$ for every $x\in V$. Since there are no arrows, the direct-user set of every $x$ is empty. Hence

$$
w(x)=0
$$

for every $x$. Membership in $A_{1,1}$ requires $w(x)\ge1$, which fails universally. Therefore

$$
A_{1,1}=\varnothing.
$$

The anti-gravity proportion is $0/10=0$, so the claim that every ten-theorem system contains at least one positive-weight short theorem is false.

The counterexample remains valid for any positive minimum-weight threshold and any maximum-length threshold at least $1$. It shows that proof brevity cannot compensate for absent reuse. Any universal or empirical lower bound must posit nontrivial dependency structure, alter the weight threshold, or restrict the class of systems under consideration.

## 6. Algorithms

### 6.1. Weight and anti-gravity classification

Given $n=|V|$ vertices and $e$ dependency edges, direct weights can be computed by a single scan through the edge list. For each edge $u\to x$, increment the counter of $x$. Classification then checks two inequalities per vertex.

With adjacency lists, the running time is $O(n+e)$ and memory use is $O(n)$ beyond the input. With an adjacency matrix, a direct implementation takes $O(n^2)$ time.

### 6.2. Density testing

By Theorem 3.4, density testing reduces to determining whether every vertex can reach $A_{m,L}$ along foundation-to-user edges. Rather than running a search from every vertex, reverse the search perspective. Begin with all vertices in $A_{m,L}$ and traverse dependency arrows toward foundations. Every visited theorem supports at least one anti-gravity theorem. Density holds precisely when all vertices are visited.

This multi-source graph search takes $O(n+e)$ time and $O(n)$ auxiliary memory.

### 6.3. Charging verification

Given a proposed array $c(x)$, verify that every target lies in $A_{m,L}$ and count target frequencies. The certificate is valid with capacity $k$ precisely when every frequency is at most $k$. This takes $O(n)$ time after anti-gravity classification and $O(|A_{m,L}|)$ counting space.

Constructing a charging map is a capacitated assignment problem. If any theorem may charge to any anti-gravity theorem, existence is equivalent simply to $n\le k|A_{m,L}|$. If support-respecting assignments are required, create a bipartite graph from theorem vertices to reachable anti-gravity targets, give each target capacity $k$, and solve a maximum-flow problem. A flow of value $n$ provides a combined density-and-abundance certificate.

## 7. Examples

### 7.1. A hub-and-spokes system

Let $V$ contain one foundation $f$, two intermediate theorems $p$ and $q$, and eight later theorems. Suppose $p\to f$ and $q\to f$, while the later theorems are divided among direct users of $p$ and $q$. If $p$ and $q$ have short proofs and at least four direct users each, then they are anti-gravity at thresholds $(4,L)$ for suitable $L$.

The foundation $f$ supports both $p$ and $q$, each intermediate theorem supports itself, and every later theorem supports itself but may support no further theorem. Consequently, the anti-gravity set need not be dense: a terminal later theorem has a cone containing only itself. This example emphasizes that high influence near the bottom of a network does not automatically place an anti-gravity theorem above every terminal result.

### 7.2. A terminal anti-gravity layer

Suppose every theorem lies on a path to one of several concise, heavily reused synthesis theorems. Then those synthesis theorems form a dense class. If, additionally, at most ten starting theorems are assigned to each synthesis theorem, the class occupies at least ten percent of the collection. This is the ideal setting for a support-respecting charging certificate.

### 7.3. The edgeless boundary case

In the edgeless system, support reduces to equality, so the dependency topology is discrete: every subset is open. In a discrete topology, the only dense subset is all of $V$. At positive weight threshold, the anti-gravity class is empty. Thus both the topological and quantitative failures are immediate.

## 8. Applications and interpretation

### 8.1. Mathematical exposition

A high-weight, low-cost theorem is a natural candidate for early presentation. Once established, it can compress many later arguments. Weight measures immediate reuse, while the cone $C(x)$ measures the region of exposition influenced by $x$. Comparing the two can distinguish local workhorses from gateways to broad theories.

### 8.2. Curriculum design

Prerequisite graphs can be treated similarly. A concise result with many direct users may be pedagogically valuable, provided its proof cost is genuinely low for the intended audience. Density asks whether every topic eventually leads to such a result; a support-respecting charging map asks whether these moments are also sufficiently frequent.

### 8.3. Comparative proof organization

Different presentations of the same subject can induce different dependency networks. One organization may concentrate reuse in a handful of compact lemmas; another may duplicate arguments. Anti-gravity statistics can therefore quantify modularity and compression, although meaningful comparison requires stable conventions for theorem identity and proof length.

### 8.4. Knowledge-network analysis

The support preorder resembles reachability in citation and software-dependency networks, but the interpretation is logical rather than merely historical or operational. The framework can nevertheless import tools from network science: transitive influence, path-discounted centrality, bottleneck analysis, and robustness under node splitting.

## 9. Limitations

The direct-user weight $w(x)$ is presentation-sensitive. Introducing thin wrapper theorems can increase or redistribute direct uses without changing mathematical substance. Combining several statements into one can have the opposite effect. Proof length is equally sensitive to notation, background assumptions, and the granularity of accepted steps.

Thresholds $(m,L)$ must therefore be reported, not hidden. Absolute thresholds may be inappropriate across collections of very different sizes. Quantile thresholds, normalized proof costs, or scale-dependent parameters may be preferable in empirical studies.

Reachability also treats all paths alike. A theorem reached through one long chain and a theorem reached through many independent short chains both lie in the same cone. If multiplicity or distance matters, support can be supplemented by discounted path counts or centrality scores.

Finally, density and abundance answer different questions. Density is an order-theoretic coverage property. The charging bound is a cardinality property. Neither implies the other without extra compatibility, as Proposition 4.3 makes explicit.

## 10. Future work

Several directions follow naturally.

First, dependency graphs and proof-cost measurements can be extracted from substantial mathematical corpora to test threshold sensitivity and the prevalence of bounded charging certificates. Second, direct-user weight can be compared with transitive downstream counts, discounted paths, and standard centralities. Third, invariance under refactoring should be studied systematically, perhaps by quotienting harmless wrapper transformations or assigning them a penalty.

Fourth, one can seek structural hypotheses on growing theorem systems that force anti-gravity cofinality. Fifth, the finite charging theorem suggests empirical searches for ten-to-one assignments, preferably support-respecting ones. Sixth, sequences of expanding systems invite asymptotic notions such as lower anti-gravity density.

The topological construction also extends beyond finite systems. For an arbitrary preorder, upward-closed sets still form an Alexandrov topology, and the dependency-density criterion remains valid. Finiteness is needed here primarily for cardinal weights, computable proportions, and bounded-fiber counting.

## 11. Conclusion

A finite theorem system carries two distinct kinds of information: how expensive each theorem is to prove and how strongly later mathematics depends on it. Gravitational weight records direct reuse; anti-gravity selects theorems that are simultaneously influential and concise. Support reachability then transforms the dependency network into an Alexandrov space.

Within this space, density has an exact meaning: a theorem class is dense if and only if every theorem supports a member of that class. Anti-gravity density is therefore precisely dependency-cofinality. Quantitative prevalence requires more. A charging map with fibers bounded by ten proves a ten-percent lower bound, while a support-respecting charging map certifies both prevalence and density.

The edgeless ten-theorem system demonstrates why assumptions matter. Short proofs alone do not create influence, and no positive universal percentage survives without dependencies. The resulting framework replaces a suggestive slogan with three sharply separated statements: a topological equivalence, a conditional counting theorem, and an unconditional counterexample. Together they provide a foundation for studying the compact results on which large regions of mathematics depend.