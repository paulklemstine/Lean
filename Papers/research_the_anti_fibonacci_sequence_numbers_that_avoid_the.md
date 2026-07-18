# The Anti-Fibonacci Exclusion Rule: Degeneracy, Exact Asymptotics, and an Extremal Graph Connector

**Aristotle**  
**July 18, 2026**

## Abstract

We analyze the recurrence obtained by starting with $A_0=A_1=1$ and defining each subsequent term to be the least positive integer unequal to the sum of the preceding two terms. Although this rule has been proposed as an additive-avoidance counterpart to the Fibonacci recurrence, its exclusion set at each step is a singleton. We prove that the least positive integer outside such a singleton is $2$ only when the forbidden value is $1$, and is $1$ otherwise. It follows by two-step induction that $A_n=1$ for every $n\ge0$. Consequently, the displayed prefix $1,1,2,4,7,11,16,\ldots$ is incompatible with the recurrence; the normalized sequence $A_n/n^2$ converges to $0$, not $1/4$; and its value at the millionth index is exactly $10^{-12}$. We also associate a graph to the recurrence by joining time indices whose values sum to $2$. This graph is complete and therefore has exactly $\binom n2$ edges on $n$ vertices. These results expose a specification issue of general relevance to greedy additive constructions: a meaningful global avoidance process must state its candidate universe, reuse policy, monotonicity requirements, and complete forbidden set. We conclude by outlining corrected families of additive-avoidance problems whose asymptotics and graph invariants may be nontrivial.

## 1. Introduction

The Fibonacci recurrence

$$
F_{n+2}=F_{n+1}+F_n
$$

turns a local additive instruction into exponential growth. With positive initial values, ratios of consecutive terms approach the golden ratio. This familiar behavior motivates the search for an “anti-Fibonacci” construction that avoids addition rather than enforcing it.

Consider the following literal proposal. Set $A_0=A_1=1$. For each $n\ge0$, let $A_{n+2}$ be the smallest positive integer that is not equal to $A_{n+1}+A_n$. The intended intuition is that each new value dodges the sum of its two predecessors. A proposed prefix is

$$
1,1,2,4,7,11,16,\ldots,
$$

and proposed asymptotic behavior includes $A_n\sim n^2/4$, failure of the neighboring-term ratio to converge, and sparsity of a complementary additive set.

The literal recurrence does not support any of these conclusions. The difficulty is not subtle asymptotic analysis but a mismatch between the intended global notion of avoidance and the actual local exclusion. At every step exactly one positive integer is prohibited. Unless that integer is $1$, the least legal positive integer is $1$. Because the initial pair sums to $2$, the process immediately returns $1$ and remains there.

The purpose of this paper is fourfold. First, we give the exact minimization lemma underlying the recurrence. Second, we derive the complete closed form and all immediate analytic consequences. Third, we encode an additive relation among time indices as a graph and identify the resulting extremal object. Fourth, we explain which pieces of data must be added before a repaired additive-avoidance sequence can sustain meaningful questions about growth or density.

The conclusions are exact rather than experimental. They also illustrate a useful methodological principle: asymptotic conjectures should be preceded by a semantic audit of the recurrence. A greedy definition must identify not only what is forbidden, but also the universe over which minimization occurs.

This distinction matters because local and global avoidance have fundamentally different combinatorics. A local condition may remove only one candidate at a time, leaving the bottom of the positive integers untouched. A global condition can accumulate enough exclusions to force sustained growth. The two mechanisms should not be expected to share prefixes, growth exponents, ratio behavior, or density laws. Establishing which mechanism a sentence actually defines is therefore part of the mathematics, not merely a matter of notation.

## 2. Definitions and elementary structure

We work in the nonnegative integers $\mathbb N=\{0,1,2,\ldots\}$ and write $\mathbb Z_{>0}$ for the positive integers.

### Definition 2.1 (Least positive value avoiding one sum)

For $x,y\in\mathbb N$, define

$$
L(x,y)=\min\{m\in\mathbb Z_{>0}:m\ne x+y\}.
$$

The defining set is nonempty because it excludes at most one positive integer. The next lemma computes this minimum exactly.

### Lemma 2.2 (Singleton-exclusion formula)

For all $x,y\in\mathbb N$,

$$
L(x,y)=
\begin{cases}
2,&x+y=1,\\
1,&x+y\ne1.
\end{cases}
$$

Moreover, $L(x,y)>0$, $L(x,y)\ne x+y$, and for every positive integer $m$ satisfying $m\ne x+y$, one has $L(x,y)\le m$.

**Proof sketch.** If $x+y\ne1$, then $1$ is a positive admissible value. No positive integer is smaller, so the minimum is $1$. If $x+y=1$, then $1$ is excluded while $2$ is admissible, making $2$ the minimum. Positivity, avoidance, and minimality follow in the corresponding case. $\square$

The formula shows that the operation depends only on whether the forbidden sum equals $1$. Its size and all other arithmetic features are irrelevant.

### Definition 2.3 (Literal anti-Fibonacci recurrence)

Define $A:\mathbb N\to\mathbb N$ by

$$
A_0=1,\qquad A_1=1,
$$

and, for every $n\ge0$,

$$
A_{n+2}=L(A_{n+1},A_n).
$$

Equivalently,

$$
A_{n+2}=\min\{m\in\mathbb Z_{>0}:m\ne A_{n+1}+A_n\}.
$$

This definition faithfully expresses the local exclusion of exactly the preceding two-term sum. It imposes no requirement that terms be distinct, unused, increasing, or outside a sumset formed from all earlier values.

## 3. Collapse of the recurrence

### Theorem 3.1 (Constant-Sequence Theorem)

For every $n\in\mathbb N$,

$$
A_n=1.
$$

**Proof sketch.** Use two-step induction. The base values $A_0=A_1=1$ hold by definition. Suppose two consecutive values are $A_n=A_{n+1}=1$. Then their sum is $2$, which is not $1$. Lemma 2.2 therefore gives

$$
A_{n+2}=L(1,1)=1.
$$

The induction propagates the value $1$ to every index. $\square$

This theorem gives the full sequence, not merely its eventual behavior:

$$
(A_n)_{n\ge0}=(1,1,1,1,1,\ldots).
$$

### Corollary 3.2 (Failure of the displayed prefix)

The literal recurrence does not generate the prefix $1,1,2,4,7,11,16,\ldots$. In particular,

$$
A_2\ne2\qquad\text{and}\qquad A_3\ne4.
$$

**Proof sketch.** Theorem 3.1 gives $A_2=A_3=1$. Since $1\ne2$ and $1\ne4$, both inequalities follow. $\square$

There is also a direct semantic contradiction at the first disputed term. The previous values are $1$ and $1$, so the forbidden value is $2$. Choosing $2$ violates the stated exclusion rather than satisfying it.

### Remark 3.3 (A separate pattern in the displayed list)

The finite list $1,1,2,4,7,11,16$ has first differences $0,1,2,3,4,5$. For the displayed indices it agrees with

$$
C_n=1+\frac{n(n-1)}2.
$$

Thus its leading quadratic coefficient is $1/2$. This observation does not define the intended sequence beyond the prefix, but it shows that the proposed prefix is also in tension with a claimed coefficient of $1/4$.

## 4. Exact analytic behavior

The closed form makes all asymptotic questions elementary.

### Theorem 4.1 (Quadratic normalization)

As $n\to\infty$ through the positive integers,

$$
\frac{A_n}{n^2}\longrightarrow0.
$$

**Proof sketch.** By Theorem 3.1, $A_n=1$, so the normalized term is $1/n^2$. Given $\varepsilon>0$, choose $N>1/\sqrt{\varepsilon}$. Then for every $n\ge N$,

$$
0\le\frac{A_n}{n^2}=\frac1{n^2}\le\frac1{N^2}<\varepsilon.
$$

This is precisely convergence to zero. $\square$

### Corollary 4.2 (The proposed quarter-limit is impossible)

The sequence $A_n/n^2$ does not converge to $1/4$.

**Proof sketch.** Theorem 4.1 gives convergence to $0$. Limits of real sequences are unique, and $0\ne1/4$. $\square$

### Corollary 4.3 (Exact millionth normalized value)

At $n=1{,}000{,}000$,

$$
\frac{A_{1{,}000{,}000}}{(1{,}000{,}000)^2}
=
\frac{1}{1{,}000{,}000{,}000{,}000}
=10^{-12}.
$$

**Proof sketch.** Substitute $A_{1{,}000{,}000}=1$ from Theorem 3.1 and square $1{,}000{,}000$. $\square$

### Proposition 4.4 (Consecutive-term ratios)

For every $n\ge0$,

$$
\frac{A_{n+1}}{A_n}=1.
$$

In particular, the ratio converges to $1$ and does not oscillate between $1$ and $2$.

**Proof sketch.** Both numerator and denominator equal $1$ by Theorem 3.1. $\square$

These conclusions sharply distinguish the literal recurrence from Fibonacci behavior. There is no exponential growth, no quadratic growth, and no nonconvergent ratio phenomenon.

## 5. An extremal graph connector

Additive relations can be translated into graph structure by treating indices as vertices and sums as adjacency conditions.

### Definition 5.1 (Sum-to-two index graph)

For $n\in\mathbb N$, let $G_n$ be the simple graph with vertex set

$$
V_n=\{0,1,\ldots,n-1\}.
$$

Two distinct vertices $i,j\in V_n$ are adjacent precisely when

$$
A_i+A_j=2.
$$

### Theorem 5.2 (Complete-Graph Theorem)

For every $n\in\mathbb N$, the graph $G_n$ is the complete graph on $n$ vertices.

**Proof sketch.** Let $i$ and $j$ be any distinct vertices. By Theorem 3.1, $A_i=A_j=1$, hence

$$
A_i+A_j=1+1=2.
$$

Thus every pair of distinct vertices is adjacent, which is the definition of a complete graph. $\square$

### Corollary 5.3 (Exact edge count)

For every $n\in\mathbb N$,

$$
|E(G_n)|=\binom n2=\frac{n(n-1)}2.
$$

**Proof sketch.** Each edge of a complete graph is an unordered pair of distinct vertices. The number of such pairs selected from $n$ vertices is $\binom n2$. $\square$

### Corollary 5.4 (Maximal edge density)

For $n\ge2$, the edge density of $G_n$ is $1$.

**Proof sketch.** A simple graph on $n$ vertices has at most $\binom n2$ edges. Corollary 5.3 attains this upper bound, so the ratio of actual to possible edges equals $1$. $\square$

This graph construction provides a reusable bridge between additive combinatorics and extremal graph theory. Given any numerical sequence $(B_n)$ and a target $t$, one may join indices $i$ and $j$ when $B_i+B_j=t$. The number of edges then counts representations of $t$ by values at distinct indices, with multiplicities arising from repeated values. Clique structure records collections whose pairwise sums all hit the target.

For the present recurrence, repeated values force maximal density. For a repaired sequence with distinct or increasing terms, the same connector would become sparse and potentially reveal nontrivial restrictions.

## 6. Algorithms and computational consequences

Although no large computation is required, explicit algorithms help separate the cost of simulating the recurrence from the cost of using its closed form.

### Algorithm 6.1 (Direct recurrence simulation)

Given a nonnegative cutoff $N$, initialize $A_0=A_1=1$. For each $n$ from $0$ to $N-2$, compute $s=A_n+A_{n+1}$. Set the next value to $2$ if $s=1$ and to $1$ otherwise.

For generation of the complete prefix through index $N$, this algorithm uses $O(N)$ time and $O(N)$ output storage. If only the final value is needed, storage drops to $O(1)$. Each step performs a constant number of fixed-form integer operations; in this specific trajectory all values remain $1$.

Correctness follows from Lemma 2.2: the branch computes the least positive integer outside the singleton $\{s\}$ exactly.

### Algorithm 6.2 (Closed-form evaluator)

Given any index $N\ge0$, return $1$.

Theorem 3.1 proves correctness. The running time and auxiliary storage are both $O(1)$. This algorithm is preferable for large indices because it avoids simulating an already solved recurrence.

### Algorithm 6.3 (Edge-count evaluator)

Given $n\ge0$, return

$$
\frac{n(n-1)}2.
$$

By Theorem 5.2, the graph is complete; by Corollary 5.3, this expression is its exact edge count. The evaluator uses $O(1)$ arithmetic operations and $O(1)$ auxiliary storage, apart from the bit complexity of multiplying integers of size $O(\log n)$.

### Numerical diagnostics

A useful diagnostic table reports $A_n$, $A_n/n^2$, and the distance from $1/4$. For example,

$$
\begin{array}{c|c|c|c}
n&A_n&A_n/n^2&|A_n/n^2-1/4|\\ \hline
1&1&1&3/4\\
10&1&10^{-2}&0.24\\
100&1&10^{-4}&0.2499\\
1{,}000&1&10^{-6}&0.249999\\
1{,}000{,}000&1&10^{-12}&0.249999999999
\end{array}
$$

The normalized values approach zero monotonically for positive $n$. Meanwhile, their distance from $1/4$ approaches $1/4$, rather than approaching zero.

## 7. Density claims and the need to specify a universe

Statements about “the complement” are ambiguous unless the underlying set is named. At least three natural sets could be intended.

First, the value set of the literal sequence is

$$
\mathcal V=\{A_n:n\ge0\}=\{1\}.
$$

Its complement in the positive integers is $\mathbb Z_{>0}\setminus\{1\}$, which has natural density $1$, while $\mathcal V$ itself has density $0$.

Second, one might consider sums of values at distinct indices. Since all values equal $1$, every such sum equals $2$ once at least two indices are available. As a set of integers, the attained distinct-index sumset is $\{2\}$ and has density $0$.

Third, an intended repaired process might construct a changing restricted sumset from earlier terms and ask for the density of its complement. That object is not determined by the literal recurrence and may behave very differently.

Thus a density statement must specify: the ambient universe, whether multiplicity matters, whether equal indices may be used, whether all historical terms participate, and whether “complement” refers to values or sums.

## 8. Diagnosing and repairing the specification

The collapse occurs because the minimization universe is all positive integers while the forbidden set contains one element. Four design decisions are required for a nontrivial greedy avoidance process.

### 8.1 Candidate universe

Must the next term be any positive integer, an unused positive integer, or an integer larger than the previous term? The first option permits perpetual reuse of $1$. The latter options introduce genuine movement.

### 8.2 Forbidden family

Does the next term avoid only the latest sum $A_n+A_{n-1}$, every adjacent historical sum, or the full pairwise sumset

$$
\{A_i+A_j:0\le i,j\le n\}?
$$

These choices range from a singleton exclusion to a rapidly changing global constraint.

### 8.3 Reuse and monotonicity

If repeated terms are allowed, greedy minimization often collapses to a small cycle or fixed point. Requiring unused values or strict increase may prevent this, but each condition must be stated explicitly.

### 8.4 Index conventions

Allowing $i=j$ in a sumset differs from requiring distinct indices. Repeated numerical values also create a distinction between pairs of indices and pairs of values.

One plausible replacement is the following strictly increasing global-avoidance construction:

$$
B_{n+1}=\min\left\{m>B_n:m\notin\{B_i+B_j:0\le i,j\le n\}\right\}.
$$

This definition is presented as a research template, not as a reconstruction of the displayed prefix. It makes the candidate universe and forbidden set explicit. Before studying its asymptotics, one would prove that the admissible set is nonempty at every stage, then establish monotonicity, bounds, and structural properties of its sumset.

A different repair could target the displayed finite pattern directly, but the recurrence must then be inferred and tested independently. The formula $1+n(n-1)/2$ matches the listed terms and grows like $n^2/2$, demonstrating why finite data alone cannot simultaneously justify an unrelated $n^2/4$ asymptotic.

## 9. Applications and broader methodological lessons

### 9.1 Fixed points of greedy recurrences

The constant solution can be understood dynamically. Regard an ordered pair $(x,y)$ as the current state and update it by

$$
T(x,y)=(y,L(y,x)).
$$

The state $(1,1)$ is fixed because $L(1,1)=1$. More generally, whenever $x+y\ne1$, the second component after an update is $1$. Since $x$ and $y$ are nonnegative, the exceptional equation $x+y=1$ has only the states $(0,1)$ and $(1,0)$. This explains why the minimization operation is strongly attracted to the smallest positive integer. For the prescribed positive initial data, the exceptional branch is never visited.

This state-space viewpoint offers an efficient audit method for other local greedy recurrences. One can identify exceptional surfaces where the minimizing choice changes, find fixed points and short cycles, and check whether the initial state enters one of them. Such qualitative analysis should precede extrapolation from a purported prefix.

### 9.2 Set-theoretic interpretation

The admissible set at state $(x,y)$ is

$$
\mathbb Z_{>0}\setminus\{x+y\}.
$$

Its minimum is controlled entirely by whether its deleted singleton contains $1$. By contrast, a genuinely global avoidance rule has an admissible set of the form

$$
\mathbb Z_{>0}\setminus S_n,
$$

where $S_n$ is an expanding collection of forbidden values. The least admissible integer can grow only if $S_n$ covers a long initial interval $\{1,2,\ldots,k\}$. This gives a useful general criterion: to force the next greedy value above $k$, every positive integer through $k$ must be either forbidden or excluded from the candidate universe. A singleton can never force a value above $2$.

### 9.3 Practical specification testing

The immediate application is specification testing for recursively defined mathematical objects. A short exact computation can invalidate a million-step numerical experiment before it begins. This matters in greedy algorithms, combinatorial game rules, integer sequence design, and discrete dynamical systems.

The singleton-exclusion formula also provides a general warning about optimization language. A condition of the form “choose the least positive integer not equal to $q$” is nearly constant as a function of $q$. It returns $1$ for every $q$ except $1$. Any intended complexity must therefore come from a larger forbidden family or a restricted candidate set.

The graph connector illustrates a second application. Additive data can be represented by edges, allowing extremal graph quantities to summarize arithmetic behavior. In the present case the graph attains maximal edge count because the numerical trajectory is constant. In richer models, edge density could measure additive coincidences, clique number could detect highly coherent subsets, and forbidden subgraphs could express incompatibilities among sums.

Finally, the analysis separates discovery from validation. Large-scale numerical testing is valuable when the object is correctly specified. It is not a substitute for checking the first recurrence step. Here the exact millionth-index value follows from a theorem and requires no iteration.

## 10. Future work

The first priority is to repair the definition before studying asymptotics. A revised rule should state whether values must be new, increasing, or outside sums of any pair of earlier terms. The displayed prefix should then be reconciled with the recurrence, and its apparent coefficient $1/2$ should be compared with any proposed coefficient.

Global additive avoidance offers a richer direction. One may greedily choose the least unused positive integer outside a restricted historical sumset, then study existence, monotonicity, sum-free structure, and the counting function. Such questions connect additive combinatorics with greedy algorithms.

The graph bridge can also be generalized. For a repaired sequence, define adjacency through a chosen additive relation and study edge density, clique number, and forbidden subgraphs. These invariants may translate additive regularity into extremal graph structure.

Density should be addressed only after fixing its universe. The complement of the value set in the positive integers and the complement of a historical sumset are distinct objects and need not share a density.

Any revised construction intended to generate $1,1,2,4,7,\ldots$ should be treated as a new definition. The literal recurrence remains useful as a specification regression test: it records exactly why excluding only the latest two-term sum cannot produce the intended behavior.

## 11. Conclusion

The literal anti-Fibonacci exclusion rule has a complete and unexpectedly simple solution. The least positive integer unequal to a single forbidden sum is $1$ unless that sum is $1$. Starting from $1,1$, the forbidden sum is always $2$, and the recurrence is therefore constant:

$$
A_n=1\quad\text{for all }n\ge0.
$$

Every major consequence follows exactly. The proposed prefix is not generated. Quadratic normalization tends to $0$ rather than $1/4$. The millionth normalized value is $10^{-12}$. Consecutive-term ratios are identically $1$. The graph joining indices whose values sum to $2$ is complete and has $\binom n2$ edges.

The broader point is constructive. Additive avoidance can support substantial mathematics, but only when its forbidden family and candidate universe are specified. Once those choices are explicit, asymptotic analysis, density, and graph structure become meaningful questions rather than artifacts of an ambiguous rule.
