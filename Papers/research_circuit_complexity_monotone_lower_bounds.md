# A Formal Toolkit for Monotone Circuit Lower Bounds: Relevant Variables, the Approximation Method, and Karchmer–Wigderson

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Computational Complexity (Novelty)

## Abstract

We develop a self-contained mathematical framework for proving lower bounds on the complexity of *monotone Boolean circuits* — circuits built from AND and OR gates with no negation. We formalize monotone circuits over an arbitrary index type of input variables, together with their evaluation, size, depth, and the set of variables they read. On this foundation we prove three complementary lower-bound techniques. First, the **relevant-variable bound**: the size of a circuit is at least the number of input variables that genuinely influence the function it computes; we instantiate this to show that any monotone circuit computing the 2-CLIQUE function on $m$ vertices has size at least $\binom{m}{2}$. Second, the abstract engine of **Razborov's approximation method**: modeling gate-wise approximation by an arbitrary rounding operator, we prove that approximation error accumulates *linearly* in the number of gates, and derive the conditional size lower bound $\text{size} \ge E/\delta$ relating global far-ness $E$ to per-gate error $\delta$. Third, the constructive half of the **Karchmer–Wigderson correspondence**: a depth-$d$ monotone circuit yields a $d$-bit communication protocol that solves the monotone Karchmer–Wigderson relation, exposing a coordinate that separates a positive input from a negative one. All results are established by structural induction and elementary finite combinatorics, and are stated so as to be directly reusable in sharper lower-bound arguments.

## 1. Introduction

Proving that explicit Boolean functions require large circuits is among the central goals of complexity theory and remains largely out of reach for general (non-monotone) circuits. The **monotone** restriction — circuits using only AND and OR gates — is a rare and celebrated success story: here we possess techniques powerful enough to prove *exponential* lower bounds for natural functions such as CLIQUE (Razborov, 1985), and a clean structural correspondence between circuit depth and communication complexity (Karchmer–Wigderson, 1988).

This paper assembles a compact, rigorous toolkit covering the three pillars of monotone lower-bound theory:

1. **The relevant-variable method** (Section 3–4): an elementary but exact counting bound, instantiated for 2-CLIQUE.
2. **The approximation method** (Section 5): the abstract error-accumulation engine underlying Razborov's exponential bound.
3. **The Karchmer–Wigderson connection** (Section 6): the algorithmic translation of circuit depth into communication cost.

Our contribution is to isolate the *structural core* of each technique — the part that is provable cleanly and independently of any particular hard function — and to state each result in maximal generality so that the problem-specific combinatorial estimates (e.g., the sunflower lemma) plug directly into a proven scaffold.

## 2. Monotone circuits

Throughout, let $\iota$ be an arbitrary type of variable indices.

**Definition 2.1 (Monotone circuit).** The type $\mathrm{MCircuit}(\iota)$ of monotone Boolean circuits is generated inductively by:
- $\mathsf{var}\,i$ for $i : \iota$ (an input variable),
- $\top$ (the constant true) and $\bot$ (the constant false),
- $\mathsf{and}\,a\,b$ and $\mathsf{or}\,a\,b$ for subcircuits $a, b$.

**Definition 2.2 (Evaluation).** Given an assignment $x : \iota \to \mathrm{Bool}$, the value $\mathrm{eval}\,C\,x$ is defined by recursion:
$$\mathrm{eval}(\mathsf{var}\,i)\,x = x_i, \quad \mathrm{eval}\,\top\,x = \text{true}, \quad \mathrm{eval}\,\bot\,x = \text{false},$$
$$\mathrm{eval}(\mathsf{and}\,a\,b)\,x = \mathrm{eval}\,a\,x \wedge \mathrm{eval}\,b\,x, \quad \mathrm{eval}(\mathsf{or}\,a\,b)\,x = \mathrm{eval}\,a\,x \vee \mathrm{eval}\,b\,x.$$

**Definition 2.3 (Size, depth, variables).**
$$\mathrm{size}(\mathsf{var}\,i) = \mathrm{size}\,\top = \mathrm{size}\,\bot = 1, \quad \mathrm{size}(\mathsf{and}\,a\,b) = \mathrm{size}(\mathsf{or}\,a\,b) = \mathrm{size}\,a + \mathrm{size}\,b + 1.$$
$$\mathrm{depth}(\mathsf{var}\,i) = \mathrm{depth}\,\top = \mathrm{depth}\,\bot = 0, \quad \mathrm{depth}(\mathsf{and}\,a\,b) = \mathrm{depth}(\mathsf{or}\,a\,b) = \max(\mathrm{depth}\,a, \mathrm{depth}\,b) + 1.$$
For decidable $\iota$, the variable set is $\mathrm{vars}(\mathsf{var}\,i) = \{i\}$, $\mathrm{vars}\,\top = \mathrm{vars}\,\bot = \emptyset$, and $\mathrm{vars}(\mathsf{and}\,a\,b) = \mathrm{vars}(\mathsf{or}\,a\,b) = \mathrm{vars}\,a \cup \mathrm{vars}\,b$.

**Theorem 2.4 (Monotonicity, `eval_monotone`).** For every circuit $C$ and assignments $x, y$ with $x_i = \text{true} \Rightarrow y_i = \text{true}$ for all $i$, we have $\mathrm{eval}\,C\,x = \text{true} \Rightarrow \mathrm{eval}\,C\,y = \text{true}$.

*Proof sketch.* Induction on $C$. Variables and constants are immediate. For $\mathsf{and}\,a\,b$, a true output means both children are true on $x$; by induction both are true on $y$, hence so is the AND. The $\mathsf{or}$ case is symmetric. $\square$

This theorem certifies that $\mathrm{MCircuit}$ is the correct syntactic class for the monotone functions: every circuit computes a monotone function.

## 3. Variables, dependence, and the relevant-variable bound

**Lemma 3.1 (Locality, `eval_eq_of_agree_on_vars`).** If $x_i = y_i$ for all $i \in \mathrm{vars}\,C$, then $\mathrm{eval}\,C\,x = \mathrm{eval}\,C\,y$.

*Proof sketch.* Induction on $C$. At $\mathsf{var}\,i$, agreement on $\{i\}$ gives $x_i = y_i$. At a gate, the variable set is the union of the children's, so agreement restricts to each child, and the inductive hypotheses combine. $\square$

**Definition 3.2 (Relevant variable, `DependsOn`).** A variable $i$ is *relevant* to a function $f : (\iota \to \mathrm{Bool}) \to \mathrm{Bool}$ if there exists an assignment $x$ with
$$f(x[i \mapsto \text{true}]) \neq f(x[i \mapsto \text{false}]),$$
where $x[i \mapsto b]$ denotes $x$ with coordinate $i$ overwritten by $b$.

**Theorem 3.3 (Relevance forces occurrence, `dependsOn_mem_vars`).** If $i$ is relevant to $\mathrm{eval}\,C$, then $i \in \mathrm{vars}\,C$.

*Proof sketch.* Contrapositive. If $i \notin \mathrm{vars}\,C$, then for any $x$ the two updated assignments $x[i \mapsto \text{true}]$ and $x[i \mapsto \text{false}]$ agree on every variable in $\mathrm{vars}\,C$ (they differ only at $i$). By Lemma 3.1 the circuit gives the same value on both, contradicting relevance. $\square$

**Theorem 3.4 (Variable count bounds size, `card_vars_le_size`).** For every $C$, $|\mathrm{vars}\,C| \le \mathrm{size}\,C$.

*Proof sketch.* Induction. A variable contributes $|\{i\}| = 1 = \mathrm{size}$; constants contribute $0$. At a gate, $|\mathrm{vars}\,a \cup \mathrm{vars}\,b| \le |\mathrm{vars}\,a| + |\mathrm{vars}\,b| \le \mathrm{size}\,a + \mathrm{size}\,b \le \mathrm{size}\,a + \mathrm{size}\,b + 1$. $\square$

**Theorem 3.5 (Relevant-variable lower bound, `card_le_size_of_relevant`).** Let $R$ be a finite set of variables, each relevant to $\mathrm{eval}\,C$. Then $|R| \le \mathrm{size}\,C$.

*Proof sketch.* By Theorem 3.3 each $i \in R$ lies in $\mathrm{vars}\,C$, so $R \subseteq \mathrm{vars}\,C$ and $|R| \le |\mathrm{vars}\,C| \le \mathrm{size}\,C$ by Theorem 3.4. $\square$

## 4. CLIQUE and a quadratic monotone bound

We model a graph on vertex set $\mathrm{Fin}\,m$ by its edge indicator $g : \mathrm{Sym2}(\mathrm{Fin}\,m) \to \mathrm{Bool}$, where $\mathrm{Sym2}$ is the type of unordered pairs. The inputs of a monotone circuit are then exactly the edge variables.

**Definition 4.1 (CLIQUE function, `cliqueFn`).**
$$\mathrm{cliqueFn}(m, k, g) = \big[\, \exists\, S \subseteq \mathrm{Fin}\,m,\ |S| = k \ \wedge\ \forall u, v \in S,\ u \neq v \Rightarrow g(\{u,v\}) = \text{true} \,\big].$$

**Theorem 4.2 (CLIQUE is monotone, `cliqueFn_monotone`).** If $g(e) = \text{true} \Rightarrow g'(e) = \text{true}$ for every edge $e$, then $\mathrm{cliqueFn}(m,k,g) = \text{true} \Rightarrow \mathrm{cliqueFn}(m,k,g') = \text{true}$.

*Proof sketch.* A witnessing $k$-clique $S$ of $g$ has all its internal edges present in $g$, hence in $g'$; so $S$ also witnesses a clique of $g'$. $\square$

**Theorem 4.3 (Every edge is relevant for $k=2$, `cliqueFn_two_dependsOn`).** For any non-loop edge $e$ (i.e. $e$ is not a diagonal pair), $e$ is relevant to $\mathrm{cliqueFn}(m, 2)$.

*Proof sketch.* Take the base assignment to be the all-false (empty) graph. With $e$ off, there is no edge and hence no 2-clique, so the function is false. With $e = \{a,b\}$ on ($a \neq b$), the set $\{a,b\}$ is a 2-clique, so the function is true. The two updated assignments differ in value, witnessing dependence. $\square$

**Lemma 4.4 (Edge count, `card_offDiag_eq_choose`).** The number of non-loop edges on $\mathrm{Fin}\,m$ equals $\binom{m}{2}$.

*Proof sketch.* The non-diagonal elements of $\mathrm{Sym2}(\mathrm{Fin}\,m)$ are in bijection with unordered pairs of distinct vertices, counted by $\binom{m}{2}$. $\square$

**Theorem 4.5 (Quadratic lower bound for 2-CLIQUE, `clique2_size_ge_choose`).** Any monotone circuit $C$ with $\mathrm{eval}\,C\,g = \mathrm{cliqueFn}(m, 2, g)$ for all $g$ satisfies
$$\mathrm{size}\,C \ge \binom{m}{2}.$$

*Proof sketch.* Let $R$ be the set of all $\binom{m}{2}$ non-loop edges (Lemma 4.4). By Theorem 4.3 each is relevant to $\mathrm{eval}\,C$ (since $\mathrm{eval}\,C = \mathrm{cliqueFn}(m,2)$). Apply Theorem 3.5: $\binom{m}{2} = |R| \le \mathrm{size}\,C$. $\square$

This bound is exact and unconditional, though only quadratic. Pushing to *exponential* bounds for general $k$ requires the approximation method of the next section.

## 5. The approximation method: abstract error accumulation

Razborov's approximation method replaces each gate by an approximator from a restricted family and tracks the error introduced. We formalize the *structural core* — error accumulation — independently of the function being analyzed, by modeling approximation as an arbitrary **rounding operator** $R$ on Boolean functions.

**Definition 5.1 (Internal gate count, `numGates`).**
$$\mathrm{numGates}(\mathsf{var}\,i) = \mathrm{numGates}\,\top = \mathrm{numGates}\,\bot = 0,$$
$$\mathrm{numGates}(\mathsf{and}\,a\,b) = \mathrm{numGates}(\mathsf{or}\,a\,b) = \mathrm{numGates}\,a + \mathrm{numGates}\,b + 1.$$

**Lemma 5.2 (`numGates_le_size`).** $\mathrm{numGates}\,C \le \mathrm{size}\,C$ for all $C$, by a routine induction.

**Definition 5.3 (Approximate evaluation, `approxEval`).** Given a rounding operator $R : ((\iota \to \mathrm{Bool}) \to \mathrm{Bool}) \to ((\iota \to \mathrm{Bool}) \to \mathrm{Bool})$, define $\mathrm{approxEval}\,R$ exactly as $\mathrm{eval}$, but apply $R$ to the function computed at each gate:
$$\mathrm{approxEval}\,R\,(\mathsf{and}\,a\,b)\,x = R\big(z \mapsto \mathrm{approxEval}\,R\,a\,z \wedge \mathrm{approxEval}\,R\,b\,z\big)(x),$$
and analogously for $\mathsf{or}$, with variables and constants evaluated as in $\mathrm{eval}$. Taking $R = \mathrm{id}$ recovers $\mathrm{eval}$ exactly, so the construction loses no generality.

**Theorem 5.4 (Error accumulation, `approx_error_bound`).** Let $R$ be any rounding operator, $T$ a finite set of test inputs, and $\delta \in \mathbb{N}$. Suppose every single rounding step is $\delta$-accurate on $T$:
$$\forall g,\quad \big|\{\, x \in T : R(g)(x) \neq g(x) \,\}\big| \le \delta.$$
Then for every circuit $C$,
$$\big|\{\, x \in T : \mathrm{eval}\,C\,x \neq \mathrm{approxEval}\,R\,C\,x \,\}\big| \le \mathrm{numGates}(C) \cdot \delta.$$

*Proof sketch.* Induction on $C$. Variables and constants are evaluated identically by both, so the error set is empty and the bound holds with $\mathrm{numGates} = 0$. For $C = \mathsf{and}\,a\,b$, consider an input $x \in T$ where $\mathrm{eval}\,C\,x \neq \mathrm{approxEval}\,R\,C\,x$. Writing $g(z) = \mathrm{approxEval}\,R\,a\,z \wedge \mathrm{approxEval}\,R\,b\,z$, the true value is $\mathrm{eval}\,a\,x \wedge \mathrm{eval}\,b\,x$ and the approximate value is $R(g)(x)$. Any disagreement must be witnessed by at least one of:
- a disagreement in the left child ($\mathrm{eval}\,a\,x \neq \mathrm{approxEval}\,R\,a\,x$),
- a disagreement in the right child ($\mathrm{eval}\,b\,x \neq \mathrm{approxEval}\,R\,b\,x$), or
- a local rounding error ($R(g)(x) \neq g(x)$).

Hence the error set is contained in the union of these three sets, and by the union bound (`Finset.card_union_le`) its cardinality is at most the sum of the three. The first two are bounded by $\mathrm{numGates}\,a \cdot \delta$ and $\mathrm{numGates}\,b \cdot \delta$ (induction), the third by $\delta$ (hypothesis). Summing,
$$\le \mathrm{numGates}\,a\cdot\delta + \mathrm{numGates}\,b\cdot\delta + \delta = (\mathrm{numGates}\,a + \mathrm{numGates}\,b + 1)\cdot\delta = \mathrm{numGates}(C)\cdot\delta.$$
The $\mathsf{or}$ case is identical with $\wedge$ replaced by $\vee$. $\square$

**Theorem 5.5 (Approximation-method size lower bound, `approx_method_size_lb`).** Under the hypotheses of Theorem 5.4, suppose additionally that the rounded circuit is *$E$-far* from the true circuit on $T$:
$$\big|\{\, x \in T : \mathrm{eval}\,C\,x \neq \mathrm{approxEval}\,R\,C\,x \,\}\big| \ge E.$$
Then
$$E \le \mathrm{numGates}(C)\cdot\delta \le \mathrm{size}(C)\cdot\delta, \qquad\text{equivalently}\qquad \mathrm{size}(C) \ge \frac{E}{\delta}.$$

*Proof sketch.* Chain the far-ness lower bound, Theorem 5.4, and Lemma 5.2. $\square$

This is precisely the master inequality of the approximation method. The full Razborov argument supplies, for monotone circuits computing $k$-CLIQUE, a rounding operator $R$ built from sunflower-plucked clique indicators, a per-gate budget $\delta$, and a far-ness budget $E$ with $E/\delta$ exponential in a power of $k$; substituting these into Theorem 5.5 yields $\mathrm{size}(C) = 2^{\Omega(\sqrt{k})}$. The structural engine above is the function-agnostic scaffold into which those two combinatorial estimates plug.

## 6. The Karchmer–Wigderson connection

The Karchmer–Wigderson theorem equates the minimal *depth* of a circuit for $f$ with the deterministic *communication complexity* of the KW relation. In the monotone setting: Alice holds $x$ with $f(x) = 1$, Bob holds $y$ with $f(y) = 0$, and they must find a coordinate $i$ with $x_i = 1$ and $y_i = 0$. We formalize the constructive (upper-bound) direction.

**Definition 6.1 (KW protocol, `kwFind`).** A partial function returning the separating coordinate, defined by descent:
$$\mathrm{kwFind}(\mathsf{var}\,i)\,x\,y = \mathrm{some}\,i, \qquad \mathrm{kwFind}\,\top = \mathrm{kwFind}\,\bot = \mathrm{none},$$
$$\mathrm{kwFind}(\mathsf{and}\,a\,b)\,x\,y = \begin{cases} \mathrm{kwFind}\,a\,x\,y & \text{if } \mathrm{eval}\,a\,y = \text{false} \\ \mathrm{kwFind}\,b\,x\,y & \text{otherwise} \end{cases}$$
$$\mathrm{kwFind}(\mathsf{or}\,a\,b)\,x\,y = \begin{cases} \mathrm{kwFind}\,a\,x\,y & \text{if } \mathrm{eval}\,a\,x = \text{true} \\ \mathrm{kwFind}\,b\,x\,y & \text{otherwise} \end{cases}$$

**Definition 6.2 (Communication cost, `kwCost`).** Identical recursion, counting one bit per gate traversed: $\mathrm{kwCost}$ of a leaf is $0$, and at each gate it is $1$ plus the cost of the chosen child.

**Theorem 6.3 (Protocol correctness, `kwFind_spec`).** If $\mathrm{eval}\,C\,x = \text{true}$ and $\mathrm{eval}\,C\,y = \text{false}$, then there exists $i$ with $\mathrm{kwFind}\,C\,x\,y = \mathrm{some}\,i$, $x_i = \text{true}$, and $y_i = \text{false}$.

*Proof sketch.* Induction on $C$ maintaining the invariant "$\mathrm{eval}\,C\,x = \text{true}$ and $\mathrm{eval}\,C\,y = \text{false}$." The constants are excluded by the invariant ($\top$ is never false, $\bot$ never true). At $\mathsf{var}\,i$ the invariant directly gives $x_i = \text{true}, y_i = \text{false}$. At an AND gate, $\mathrm{eval}\,C\,y = \text{false}$ forces some child to be false on $y$ — the protocol routes to it — while $\mathrm{eval}\,C\,x = \text{true}$ keeps both children true on $x$; the invariant is preserved for the chosen child. The OR gate is dual. $\square$

**Theorem 6.4 (Depth bounds communication, `kwCost_le_depth`).** For all $x, y$, $\mathrm{kwCost}\,C\,x\,y \le \mathrm{depth}\,C$.

*Proof sketch.* Induction: at a gate the cost is $1 + (\text{cost of one child}) \le 1 + \max(\mathrm{depth}\,a, \mathrm{depth}\,b) = \mathrm{depth}\,C$. $\square$

**Corollary 6.5 (Monotone separator existence, `monotone_separator_exists`).** If $\mathrm{eval}\,C\,x = \text{true}$ and $\mathrm{eval}\,C\,y = \text{false}$, there exists $i$ with $x_i = \text{true}$ and $y_i = \text{false}$.

*Proof sketch.* Discard the coordinate-returning data of Theorem 6.3. $\square$

Theorems 6.3–6.4 together say: a depth-$d$ monotone circuit computing $f$ gives a $d$-bit deterministic protocol for the monotone KW relation of $f$. Consequently, a *lower bound* on the communication complexity of that relation is a lower bound on monotone depth — the standard route to depth lower bounds.

## 7. Discussion

The three techniques are complementary and mutually reinforcing. The relevant-variable bound (Section 3) is exact but limited to the number of essential inputs, yielding only polynomial bounds (Section 4). The approximation method (Section 5) breaks this barrier by tracking *errors* rather than *variables*, and its structural core — linear error accumulation — is fully general; only the two combinatorial inputs ($E$ and $\delta$) are function-specific. The Karchmer–Wigderson connection (Section 6) addresses depth rather than size, reducing depth lower bounds to communication lower bounds.

A notable design choice is to keep the rounding operator $R$ in Section 5 entirely abstract. This makes Theorem 5.4 non-vacuous and reusable: the hypothesis $\delta$-accuracy is a genuine quantitative constraint, and the conclusion is a real bound that holds for *any* approximation scheme. The exponential CLIQUE bound is then a corollary obtained by supplying a specific sunflower-based $R$.

## 8. Future work

Three concrete directions emerge directly from the gaps these results expose.

**Conjecture 8.1 (Sunflower instantiation).** There is a rounding operator $R$ built from sunflower-plucked clique indicators, a test set $T$ of cliques-versus-colourings, a per-gate budget $\delta$, and a far-ness budget $E$ with $E/\delta$ exponential in $m$, satisfying the hypotheses of Theorem 5.5 for any monotone circuit computing $\mathrm{cliqueFn}(m, k)$. Hence every such circuit has size $2^{\Omega(\sqrt{k})}$. Because Theorem 5.5 already reduces the exponential bound to two purely combinatorial cardinality estimates, the remaining work is to supply those counts, not to redo any induction.

**Conjecture 8.2 (Converse Karchmer–Wigderson).** Every deterministic protocol of cost $c$ for the monotone KW relation of $f$ compiles into a monotone circuit of depth $\le c$ computing $f$; combined with Theorem 6.4 this makes monotone depth and monotone KW communication complexity *equal*. A protocol tree is itself a circuit skeleton: each communicated bit becomes an AND or OR gate, inverting the descent in $\mathrm{kwFind}$.

**Conjecture 8.3 (Tightness of the relevant-variable bound).** Characterize exactly when Theorem 3.5 is an equality (size equal to the number of relevant variables) — conjecturally for "read-once-ish" circuits where every gate reads disjoint variable sets.

## References

The results formalized here are the classical theorems of monotone circuit complexity: the relevant-variable counting bound (folklore), Razborov's approximation method (A. A. Razborov, *Lower bounds on the monotone complexity of some Boolean functions*, 1985), and the Karchmer–Wigderson depth–communication correspondence (M. Karchmer and A. Wigderson, *Monotone circuits for connectivity require super-logarithmic depth*, 1988). This paper isolates and re-proves their structural cores in a self-contained, generic form.
