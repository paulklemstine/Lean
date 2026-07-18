# Normalized Fractal Dimension of Binary Search Trees: Periodic Realization, Exact Benchmarks, and Limits of Complexity Inference

**Aristotle**  
**July 18, 2026**

## Abstract

We study the exponential geometry of a binary search process through the number of viable decision prefixes at each depth. If $N(n)$ denotes the number of length-$n$ prefixes that remain extendable to a successful outcome, the finite-depth normalized estimate is $d_n=\log_2 N(n)/n$, and the upper asymptotic search dimension is $D=\limsup_{n\to\infty}d_n$. The normalization makes the full binary tree have dimension $1$. We prove that every binary search profile satisfies $D\leq1$, so a proposed super-unit regime is impossible within this model. We then analyze periodically pruned trees. If exactly $p$ of every $q$ decision levels are free, then $D=p/q$; consequently every rational number in $[0,1]$ is realized. At every positive complete-period depth $qk$, the finite estimate equals $p/q$ exactly. The codimension $1-D$ is the density of constrained levels. Finally, we show that dimension, even together with an exact finite-depth benchmark, does not determine a separately specified shortest-solution length: every rational dimension and complete-period estimate can coexist with every natural length. The results isolate viable-prefix geometry from exploration policy and terminal semantics, providing controlled benchmarks for richer theories of search cost.

## 1. Introduction

Many searches can be represented as rooted trees. A node records a partial sequence of decisions, and its children represent admissible next steps. Examples include derivation search, combinatorial optimization, symbolic execution, planning, program synthesis, and constraint solving. Such a tree has at least two distinct aspects. Its **geometry** describes how many partial routes survive as depth increases. Its **dynamics** describes the order and cost with which a procedure explores those routes. These aspects interact in applications, but they should not be conflated.

This paper develops a minimal geometric model for binary search. At depth $n$, every possible decision history is a word in $\{0,1\}^n$. A search profile selects a collection of successful, or viable, prefixes: words that remain compatible with eventual success. Let $N(n)$ be their number. The logarithm $\log_2N(n)$ converts multiplicative branching into additive information, while division by $n$ normalizes against depth. Thus

$$
d_n=\frac{\log_2N(n)}{n}
$$

is the average number of surviving binary choice bits per level. Its upper limiting value is a box-dimension analogue for the boundary of the search tree.

Three questions motivate the analysis.

1. What range of dimensions is possible inside a fixed binary tree?
2. Can explicit families realize prescribed dimensions and permit exact finite measurements?
3. Does this geometric invariant control familiar complexity quantities such as shortest-solution length?

The answers draw a sharp boundary. First, normalized binary dimension never exceeds $1$. Second, periodically pruning decision levels realizes every rational dimension in $[0,1]$, and complete periods yield exact finite-depth values. Third, dimension alone does not constrain shortest-solution length when that length is independent semantic data. Even fixing both the asymptotic dimension and an exact finite observation leaves the length arbitrary.

The periodic construction is elementary but expressive. In a period of $q$ levels, designate $p$ levels as free, with both choices available, and force a single choice at the other $q-p$ levels. Each free level doubles the number of viable prefixes. The resulting growth is controlled by the count of free levels, reducing dimension to an asymptotic density. This model also supplies benchmark instances whose target dimension is known without approximation.

The non-determination result clarifies the scope of the invariant. Dimension measures exponential abundance, not search order, failed-branch cost, or terminal placement. Those ingredients must be represented explicitly before one can infer running time or shortest-solution depth.

## 2. Binary search profiles and normalized dimension

### 2.1 Prefix trees

Let $\{0,1\}^{<\mathbb N}$ denote the set of all finite binary words, and let $\{0,1\}^n$ denote the words of length $n$. A **binary search profile** is a prefix-closed set $S\subseteq\{0,1\}^{<\mathbb N}$. Prefix closure means that if $w\in S$, then every initial segment of $w$ also lies in $S$. Members of $S$ are interpreted as viable decision prefixes.

For each $n\geq0$, define the level set

$$
S_n=S\cap\{0,1\}^n
$$

and the successful-prefix count

$$
N_S(n)=|S_n|.
$$

We focus on profiles with at least one viable word at every level, so that the logarithm below is defined. The same conclusions can be extended to extinct profiles by adopting a conventional value for the logarithm of zero, but extinction is not needed for the present benchmark family.

### 2.2 Finite estimate and asymptotic dimension

For $n\geq1$, the **finite-depth dimension estimate** is

$$
d_S(n)=\frac{\log_2N_S(n)}{n}.
$$

The **normalized upper search dimension** is

$$
D(S)=\limsup_{n\to\infty}d_S(n)
=\limsup_{n\to\infty}\frac{\log_2N_S(n)}{n}.
$$

When the ordinary limit exists, it agrees with $D(S)$. The base-$2$ logarithm is natural because the ambient alphabet is binary. It makes the full tree satisfy $N_S(n)=2^n$ and hence $d_S(n)=1$ at every positive depth.

The dimension admits an information interpretation. Since $\log_2N_S(n)$ is the number of bits needed to index the viable prefixes at depth $n$, $d_S(n)$ is the average viable information per decision level. It also has a fractal interpretation: viable infinite paths form a subset of binary sequence space, and the level-$n$ cylinders provide covers at scale $2^{-n}$.

### 2.3 Ambient bound

**Theorem 2.1 (Binary Search Dimension Bound).** For every binary search profile $S$,

$$
D(S)\leq1.
$$

**Proof sketch.** At depth $n$, there are exactly $2^n$ binary words. Therefore $N_S(n)\leq2^n$, and monotonicity of the logarithm gives

$$
d_S(n)=\frac{\log_2N_S(n)}{n}\leq\frac{\log_2(2^n)}{n}=1.
$$

Taking the upper limit preserves the inequality. $\square$

**Corollary 2.2 (No Super-Unit Regime).** For every binary search profile $S$ and every real $\varepsilon>0$,

$$
D(S)\neq1+\varepsilon.
$$

**Proof sketch.** The value $1+\varepsilon$ is strictly greater than $1$, contradicting Theorem 2.1. $\square$

The corollary is a constraint on classification schemes. Under the present metric and normalization, a threshold that labels $D>1$ as a hard regime has an empty upper class. Super-unit values require a different ambient alphabet without corresponding renormalization, a different metric, or an invariant other than normalized dimension.

## 3. Periodically pruned search profiles

### 3.1 Construction

Fix an integer period $q\geq1$ and a set of residues

$$
R\subseteq\{0,1,\ldots,q-1\}.
$$

A level $j\geq0$ is called **free** when $j\bmod q\in R$, and **constrained** otherwise. At a free level, both bits $0$ and $1$ may be appended to every viable prefix. At a constrained level, only a fixed bit, say $0$, may be appended. The resulting prefix-closed tree is the **periodically pruned profile** associated with $(q,R)$.

Let

$$
p=|R|
$$

be the number of free residue classes per period. Define the free-level counting function

$$
F_{q,R}(n)=\bigl|\{j:0\leq j<n,\ j\bmod q\in R\}\bigr|.
$$

The first $n$ levels contain exactly $F_{q,R}(n)$ independent binary choices.

### 3.2 Exact counting

**Lemma 3.1 (Free-Level Counting Formula).** For the periodically pruned profile determined by $(q,R)$,

$$
N_S(n)=2^{F_{q,R}(n)}
$$

for every $n\geq0$.

**Proof sketch.** Start from the empty prefix. At every free level the number of viable prefixes doubles, while at every constrained level it remains unchanged. After $n$ levels, doubling has occurred exactly $F_{q,R}(n)$ times. $\square$

Writing $n=qk+r$ with $0\leq r<q$ gives a more explicit formula. Every complete period contributes $p$ free levels, while the final partial period contributes

$$
a_R(r)=|R\cap\{0,1,\ldots,r-1\}|.
$$

Therefore

$$
F_{q,R}(n)=pk+a_R(r).
$$

Since $0\leq a_R(r)\leq p\leq q$, the deviation from the linear term $(p/q)n$ is uniformly bounded. In particular,

$$
\left|F_{q,R}(n)-\frac{p}{q}n\right|<q.
$$

This bounded discrepancy drives both the asymptotic theorem and finite-sample estimates.

### 3.3 Dimension equals free-level density

**Theorem 3.2 (Periodic Density Theorem).** Let $S$ be a periodically pruned binary profile with period $q\geq1$ and $p$ free residue classes. Then the limit defining the normalized search dimension exists and

$$
D(S)=\lim_{n\to\infty}d_S(n)=\frac{p}{q}.
$$

**Proof sketch.** By Lemma 3.1,

$$
d_S(n)=\frac{F_{q,R}(n)}{n}.
$$

For $n=qk+r$, the numerator is $pk+a_R(r)$. Dividing by $qk+r$ and letting $n$ tend to infinity makes the bounded remainder negligible, leaving $p/q$. $\square$

This theorem turns an exponential growth invariant into a frequency: dimension is the long-run density of levels at which choice survives.

**Corollary 3.3 (Rational Realization Theorem).** For every pair of integers $p,q$ satisfying $0\leq p\leq q$ and $q\geq1$, there exists a periodically pruned binary profile $S$ such that

$$
D(S)=\frac{p}{q}.
$$

**Proof sketch.** Choose any $p$ residues in a period of length $q$, for example $R=\{0,1,\ldots,p-1\}$. Theorem 3.2 gives the stated dimension. $\square$

Thus the realizable dimensions contain every rational point of the unit interval. The endpoint $0$ is a single forced ray, while the endpoint $1$ is the full binary tree.

### 3.4 Codimension as pruning density

Define the **normalized codimension** of a profile by

$$
C(S)=1-D(S).
$$

**Theorem 3.4 (Periodic Codimension Theorem).** If a periodic profile has $p$ free levels and $q-p$ constrained levels per period, then

$$
C(S)=1-D(S)=\frac{q-p}{q}.
$$

**Proof sketch.** Substitute $D(S)=p/q$ from Theorem 3.2 and simplify:

$$
1-\frac{p}{q}=\frac{q-p}{q}.
$$

The numerator counts the constrained residue classes. $\square$

Codimension therefore measures the asymptotic density of decisions removed by pruning. This interpretation is exact in the periodic model.

## 4. Exact finite-depth benchmarks

Asymptotic invariants are often difficult to estimate from finite data. Periodicity creates a distinguished family of depths at which no approximation is required.

**Lemma 4.1 (Complete-Period Free Count).** For every integer $k\geq1$,

$$
F_{q,R}(qk)=pk.
$$

**Proof sketch.** The first $qk$ levels consist of $k$ disjoint complete periods, each containing exactly $p$ free residue classes. $\square$

**Theorem 4.2 (Exact Complete-Period Estimate).** Let $S$ be a period-$q$ profile with $p$ free levels per period. For every $k\geq1$,

$$
d_S(qk)=\frac{p}{q}=D(S).
$$

**Proof sketch.** Lemma 4.1 and the exact counting formula yield

$$
N_S(qk)=2^{pk}.
$$

Therefore

$$
d_S(qk)=\frac{\log_2(2^{pk})}{qk}
=\frac{pk}{qk}
=\frac{p}{q}.
$$

Theorem 3.2 identifies this value with the limit. $\square$

**Theorem 4.3 (Periodic Benchmark Theorem).** Given integers $p,q,k$ satisfying $0\leq p\leq q$, $q\geq1$, and $k\geq1$, there exists a binary search profile $S$ for which

$$
D(S)=\frac{p}{q}
\qquad\text{and}\qquad
 d_S(qk)=\frac{p}{q}.
$$

**Proof sketch.** Select the first $p$ residues in a period of length $q$ as free. Theorem 3.2 supplies the asymptotic equality, and Theorem 4.2 supplies the exact finite-depth equality. $\square$

The theorem produces controlled instances for numerical studies. One may prescribe a rational target, choose any positive number of periods, and know both the limiting invariant and the finite measurement at the chosen depth.

A useful bound also follows from the bounded remainder in Section 3. Although not needed for exact period boundaries, it explains convergence away from them:

$$
\left|d_S(n)-\frac{p}{q}\right|
=\frac{1}{n}\left|F_{q,R}(n)-\frac{p}{q}n\right|
<\frac{q}{n}.
$$

The dependence on the period can be sharpened by examining the locations of residues, but the displayed estimate already gives an $O(q/n)$ envelope.

### 4.1 Example

Take $q=3$ and $R=\{0,1\}$, so the pattern is free, free, constrained. Then $p=2$, and Theorem 3.2 gives $D(S)=2/3$. At depth $12=3\cdot4$, exactly $8$ levels are free, so

$$
N_S(12)=2^8=256
$$

and

$$
d_S(12)=\frac{\log_2 256}{12}=\frac{8}{12}=\frac{2}{3}.
$$

At non-boundary depths, the estimate depends on the partial period. For example, at depth $4$ there are $3$ free levels and $d_S(4)=3/4$, while at depth $6$ there are $4$ free levels and the estimate returns exactly to $2/3$.

## 5. What dimension cannot determine

### 5.1 Search instances and terminal data

The prefix profile contains geometric information but does not, by itself, specify a completed solution. To expose this distinction, define a **search instance** to be a pair

$$
I=(S,L),
$$

where $S$ is a binary search profile and $L\in\mathbb N$ is a designated shortest-solution length. In this abstract model, no compatibility axiom ties $L$ to the profile. This is deliberate: it tests exactly what follows from geometry alone.

**Theorem 5.1 (Non-Determination of Shortest Length).** Let $p,q,L$ be integers with $0\leq p\leq q$, $q\geq1$, and $L\geq0$. There exists a search instance $I=(S,L)$ such that

$$
D(S)=\frac{p}{q}.
$$

Equivalently, every rational normalized dimension in $[0,1]$ can coexist with every natural shortest-solution length.

**Proof sketch.** By Corollary 3.3, choose a periodic profile $S$ with dimension $p/q$. Pair this profile with the prescribed value $L$. Since $L$ is independent data in the definition of a search instance, the resulting pair has both required properties. $\square$

The theorem is a non-identifiability statement. If two instances share the same profile but carry different values of $L$, every dimension statistic computed from that profile is identical, while their designated shortest lengths differ.

### 5.2 Exact measurements do not repair non-identifiability

One might hope that supplementing the asymptotic dimension with an exact finite-depth observation would constrain $L$. It does not.

**Theorem 5.2 (Strengthened Non-Determination at a Benchmark Depth).** Given integers $p,q,k,L$ with $0\leq p\leq q$, $q\geq1$, $k\geq1$, and $L\geq0$, there exists a search instance $I=(S,L)$ satisfying

$$
D(S)=\frac{p}{q},
\qquad
d_S(qk)=\frac{p}{q},
\qquad\text{and}\qquad
\text{shortest length}(I)=L.
$$

**Proof sketch.** Use Theorem 4.3 to construct a periodic profile whose dimension and complete-period estimate both equal $p/q$. Pair that profile with the arbitrary prescribed length $L$. $\square$

The result is stronger than merely observing that a limit omits finite behavior. Here an exact finite statistic and the asymptotic statistic are both fixed, yet the terminal length remains arbitrary.

### 5.3 Interpretation

The theorem does not claim that shortest-solution length is unrelated to prefix structure in every concrete search problem. Rather, it proves that such a relation cannot be derived from the present definitions alone. To obtain one, a model must add assumptions connecting viable prefixes to terminal nodes. Possible additions include:

- a requirement that the profile consist exactly of prefixes of successful terminal paths;
- an explicit set of terminal nodes;
- lower or upper bounds on terminal density;
- an exploration order;
- costs for expanding nodes and rejecting failed branches;
- probabilistic laws governing success and failure.

Without these ingredients, dimension measures abundance but not discovery time.

## 6. Algorithms and numerical methodology

### 6.1 Counting without enumerating prefixes

A naive computation generates all $2^n$ binary words and tests viability, requiring exponential time. Periodicity makes enumeration unnecessary.

Given $q$, a residue set $R$, and depth $n$, compute the quotient and remainder $n=qk+r$. Then

$$
F_{q,R}(n)=k|R|+|R\cap\{0,\ldots,r-1\}|.
$$

The viable-prefix count is $2^{F_{q,R}(n)}$, and the finite estimate is $F_{q,R}(n)/n$. With a boolean table or sorted residue set, preprocessing takes $O(q)$ time and each query can be answered in $O(1)$ time using prefix sums. The count itself may contain $\Theta(n)$ bits, so returning the exact integer has output-sensitive cost; returning only the logarithmic estimate avoids constructing that integer.

### 6.2 Benchmark synthesis

To synthesize a profile of rational dimension $p/q$, verify $0\leq p\leq q$ and choose

$$
R=\{0,1,\ldots,p-1\}.
$$

This takes $O(p)$ space if residues are listed explicitly, or $O(1)$ space if the contiguous rule is represented symbolically. At a requested complete-period depth $qk$, return the exact free count $pk$, prefix count $2^{pk}$, and estimate $p/q$.

### 6.3 Empirical protocol

For a visual convergence study, evaluate $d_S(n)$ over $1\leq n\leq N$. Plot the staircase-like estimate against depth and add the horizontal target $p/q$. Highlight depths divisible by $q$; every highlighted point lies exactly on the target. A second plot can show $N_S(n)$ on a logarithmic scale, where its slope is governed by $p/q$.

For a non-determination experiment, hold $(q,R)$ fixed and attach several values of $L$. The entire dimension curve remains unchanged. This visually demonstrates why geometric measurements cannot identify independent terminal metadata.

## 7. Applications

### 7.1 Derivation and theorem search

A partial derivation may be represented by a bit string when each step offers two abstract alternatives. The dimension measures how rapidly potentially completable derivations proliferate. A low-dimensional profile is strongly pruned; a high-dimensional profile retains many possibilities. Yet search effort also depends on which alternatives are explored first and how quickly failed derivations are detected.

### 7.2 Program synthesis and symbolic execution

In program synthesis, prefixes may encode partial programs. Tests and type constraints prune the tree. Dimension quantifies the residual exponential design space. In symbolic execution, prefixes represent branch decisions, and constraints eliminate infeasible paths. Periodic profiles serve as synthetic workloads with tunable path-growth rates.

### 7.3 Planning and decision processes

A planner may retain only action prefixes compatible with a goal. The free-level density describes how often meaningful alternatives remain. But physical costs, heuristic priorities, and terminal rewards are external to that density. Two planners can face the same viable-prefix geometry and experience different running times because their policies differ.

### 7.4 Information and coding viewpoint

The value $\log_2N_S(n)$ is the information needed to identify a viable prefix at depth $n$. Thus $D(S)$ is an asymptotic information rate. Periodic pruning behaves like a deterministic channel that transmits one free bit at selected times and no information at constrained times. Codimension is the fraction of times at which the channel is frozen.

## 8. Discussion

The normalized dimension is both robust and limited. It is robust because it compresses exponential growth into a bounded scale and because periodic instances admit exact analysis. It is limited because many operationally important features disappear under counting.

The ambient bound $D\leq1$ is not a weakness of the invariant; it is the point of normalization. A value near $1$ indicates growth close to the full binary capacity, while a value near $0$ indicates a narrow surviving set. Any use of a super-unit threshold in this setting confuses normalized dimension with an unnormalized growth rate.

The realization theorem shows that the scale is not degenerate. Rational values are attained by transparent constructions. Since rationals are dense in $[0,1]$, periodic profiles approximate any desired real target arbitrarily closely, although exact realization of arbitrary irrational dimensions requires aperiodic free-level sets.

The benchmark theorem has methodological value. Measurements taken at complete periods are exactly calibrated, so discrepancies in software or experiments can be attributed to implementation, sampling, or model mismatch rather than finite-depth bias. Away from those depths, the remainder term supplies an interpretable oscillation.

The non-determination theorems are equally central. They identify a missing causal bridge: viable-prefix counts do not encode terminal depth. More generally, no scalar summary of level counts can recover independent metadata. Search complexity should therefore be modeled by at least two layers: a geometric layer describing the state space and a dynamic-semantic layer describing exploration and success.

## 9. Future work

Several extensions arise naturally.

1. **Variable branching alphabets.** Generalize binary profiles to a fixed $b$-ary alphabet and normalize by $\log b$. The ambient dimension should again be bounded by $1$, while free-level densities should realize rational values.

2. **Aperiodic pruning.** Replace periodic residue sets by arbitrary sets of free levels. Upper search dimension should correspond to the limsup of free-level densities, and lower search dimension to the liminf. Oscillation then becomes an intrinsic feature rather than a bounded periodic remainder.

3. **Search policy and cost.** Enrich a search instance with an exploration order, failed-branch costs, and terminal nodes. The non-determination results show that these semantic data are necessary before dimension can imply search time or shortest-solution length.

4. **Finite-sample bounds.** Develop sharp error estimates at arbitrary depths. The periodic free-count decomposition suggests errors of order $|R|/n$ or $q/n$, depending on how residue placement is parameterized.

5. **Entropy formulation.** For nonuniform profiles, replace raw counts by weighted or probabilistic entropy and investigate subadditive conditions under which a limiting normalized entropy exists.

6. **Monotonicity under pruning.** Define intersection, union, and levelwise restriction operations on profiles and prove dimension inequalities, enabling modular comparison of search strategies.

## 10. Conclusion

Binary viable-prefix geometry has a natural normalized dimension

$$
D(S)=\limsup_{n\to\infty}\frac{\log_2N_S(n)}{n}.
$$

Its ambient upper bound is $1$, excluding a super-unit regime. Periodic pruning gives the invariant a direct combinatorial interpretation: if $p$ of every $q$ levels are free, then the dimension is $p/q$, the codimension is $(q-p)/q$, and every rational point of the unit interval is realized. At every depth $qk$, the finite estimate equals the limit exactly.

These exact constructions also expose the invariant’s boundary. Neither dimension nor an exact complete-period measurement determines an independently designated shortest-solution length. Geometry describes how possibilities proliferate; it does not describe how they are traversed or where success terminates. A complete theory of search complexity must combine fractal or entropic growth with policy, cost, and terminal structure.
