# The Fractal Dimension of Mathematical Truth: Prefix Geometry, Symbolic Counting, and Computability

**Aristotle**  
**19 July 2026**

## Abstract

We develop a self-contained model connecting binary truth assignments, prefix geometry, symbolic fractal dimension, real-number coding, and computability. An infinite theory is represented by a stream $x\in\{0,1\}^{\mathbb N}$. The weighted disagreement function

$$
d(x,y)=\sum_{n=0}^{\infty}\mathbf 1_{x_n\ne y_n}2^{-(n+1)}
$$

is shown to be a metric. We then study a paired truth language in which every even coordinate is fixed to $1$ and every odd coordinate is free. Its admissible prefixes of length $2n$ are in bijection with $n$ freely chosen bits, so their number is $2^n$, whereas the ambient prefix count is $2^{2n}$. The exact identity $(2^n)^2=2^{2n}$ yields symbolic prefix-counting dimension $1/2$, strictly between $0$ and $1$. Every stream also determines a binary real $R(x)=\sum_{n\ge0}x_n2^{-(n+1)}$. Its first $N$ terms approximate it from below with error at most $2^{-N}$, and agreement on the first $N$ bits implies real-value distance at most $2^{-N}$. Finally, we distinguish this universal approximation phenomenon from computability: halting truth for programs on a fixed input is undecidable but recursively enumerable. The construction therefore provides a rigorous bridge among symbolic geometry, analysis, and computability while avoiding the unsupported claim that all mathematical truth has a canonical dimension or that the elementary half-free model is itself uncomputable.

## 1. Introduction

A mathematical statement can be assigned a binary value: true or false. After choosing a language, semantics, foundational setting, and enumeration of statements, a complete assignment becomes an infinite binary stream. This elementary representation invites geometric questions. If two assignments agree for a long initial segment, should they count as close? If a family of assignments allows only a restricted number of prefixes, can its rate of prefix growth be interpreted as a dimension? If the bits are used as binary digits of a real number, how accurately do finite observations determine that real? Finally, what changes when the bits encode an undecidable predicate such as program halting?

These questions must be separated carefully. There is no canonical effective enumeration of all mathematical statements independent of syntax and foundations. Dimension also depends on a metric or covering convention. Moreover, geometric approximation of a real does not imply that the underlying bits are computable, and undecidability of one truth predicate does not transfer automatically to an unrelated language.

The purpose of this paper is to construct an explicit model in which each connection has a precise theorem. The paired truth language fixes one coordinate in each pair and leaves the other free. This gives exact prefix counts at all finite scales and an elementary symbolic dimension of $1/2$. The dimension is therefore sparse but nonzero. Independently, the binary-real map supplies certified lower approximations and a prefix continuity bound. A final computability section explains the exact status of halting truth: it is noncomputable as a decision predicate but recursively enumerable in the positive direction.

The main results are:

1. **Prefix Metric Theorem.** The geometrically weighted coordinate-disagreement sum defines a metric on infinite Boolean streams.
2. **Completion and Counting Theorem.** Every finite choice of $n$ odd bits extends injectively to a paired truth stream, and the number of admissible length-$2n$ prefixes is exactly $2^n$.
3. **Exact Half-Dimension Theorem.** At every even scale, the square of the admissible-prefix count equals the ambient-prefix count; consequently, the symbolic prefix-counting dimension is exactly $1/2$.
4. **Binary Approximation Theorem.** The first $N$ digits of any stream approximate its binary real from below with error at most $2^{-N}$.
5. **Prefix Stability Theorem.** Two streams agreeing on their first $N$ coordinates determine binary reals at distance at most $2^{-N}$.
6. **Halting Truth Theorem.** For any fixed input, halting as a predicate on program codes is undecidable but recursively enumerable.

The paired construction is deliberately a model rather than a claim about an invariant of mathematics as a whole. Its value lies in making the proposed bridges exact and auditable.

## 2. Binary theories and prefix geometry

### 2.1 Infinite theories

A **binary theory** is a function

$$
x:\mathbb N\to\{0,1\}.
$$

The bit $x_n=1$ means that the $n$th statement is accepted as true, while $x_n=0$ means that it is not. No closure axioms are imposed: the word “theory” here refers to a binary assignment, not necessarily a deductively closed formal theory.

For a proposition $P$, let $\mathbf 1_P$ denote its indicator, equal to $1$ when $P$ holds and $0$ otherwise.

### 2.2 Weighted disagreement distance

Define

$$
d(x,y)=\sum_{n=0}^{\infty}\mathbf 1_{x_n\ne y_n}2^{-(n+1)}.
$$

The series converges absolutely because each summand lies between $0$ and $2^{-(n+1)}$, and

$$
\sum_{n=0}^{\infty}2^{-(n+1)}=1.
$$

Although the distance aggregates all disagreements rather than recording only the first, it has the essential prefix behavior: later disagreements carry exponentially smaller weights.

### Theorem 2.1 (Prefix Metric Theorem)

For all binary theories $x,y,z$, the function $d$ satisfies:

1. $d(x,y)\ge0$;
2. $d(x,y)=0$ if and only if $x=y$;
3. $d(x,y)=d(y,x)$;
4. $d(x,z)\le d(x,y)+d(y,z)$.

Hence $d$ is a metric on $\{0,1\}^{\mathbb N}$.

#### Proof sketch

Nonnegativity follows term by term. Symmetry follows because $x_n\ne y_n$ is equivalent to $y_n\ne x_n$. If $x=y$, every indicator vanishes. Conversely, if $x\ne y$, there is an index $m$ with $x_m\ne y_m$, and the $m$th summand contributes $2^{-(m+1)}>0$; all other terms are nonnegative, so $d(x,y)>0$.

For the triangle inequality, at each coordinate one has

$$
\mathbf 1_{x_n\ne z_n}
\le \mathbf 1_{x_n\ne y_n}+\mathbf 1_{y_n\ne z_n}.
$$

Indeed, if $x_n\ne z_n$, the intermediate bit $y_n$ cannot equal both. Multiplication by the positive weight $2^{-(n+1)}$ and summation over $n$ give the result. $\square$

### Proposition 2.2 (Elementary bounds)

For all $x,y$,

$$
0\le d(x,y)\le1.
$$

If $x$ and $y$ agree in their first $N$ positions, then

$$
d(x,y)\le2^{-N}.
$$

#### Proof sketch

The first upper bound follows by replacing every indicator by $1$. Under prefix agreement, all terms with $n<N$ vanish, leaving the geometric tail

$$
\sum_{n=N}^{\infty}2^{-(n+1)}=2^{-N}.
$$

This proposition displays the topology implicit in the construction: long common prefixes force small metric distance.

## 3. The paired truth language

### 3.1 Definition

The **paired truth language** $\mathcal P$ consists of all binary theories satisfying

$$
x_{2k}=1\qquad\text{for every }k\in\mathbb N.
$$

Thus, in every pair $(x_{2k},x_{2k+1})$, the first bit is fixed and the second is free. This is a periodic subspace of the full binary shift.

A finite paired description at scale $n$ is a function

$$
p:\{0,1,\ldots,n-1\}\to\{0,1\}.
$$

It stores exactly the first $n$ odd-coordinate choices. An unrestricted binary prefix of length $m$ is similarly a function from $\{0,1,\ldots,m-1\}$ to $\{0,1\}$.

### 3.2 Completion

Given a finite paired description $p$ of length $n$, define a completed infinite stream $C_p$ by

$$
(C_p)_{2k+1}=p_k\quad(0\le k<n)
$$

and set every other coordinate equal to $1$. In particular, all even coordinates are $1$, so $C_p\in\mathcal P$.

### Lemma 3.1 (Completion Lemma)

Every finite paired description extends to a member of $\mathcal P$. The completion recovers each stored bit at its designated odd coordinate, and the map $p\mapsto C_p$ is injective.

#### Proof sketch

The construction explicitly makes every even coordinate $1$, proving membership. At coordinate $2k+1$ for $k<n$, the defining rule returns $p_k$. If $p\ne q$, choose $k$ with $p_k\ne q_k$; then $C_p$ and $C_q$ differ at $2k+1$, proving injectivity. $\square$

The lemma is stronger than a raw cardinality calculation: it proves that every finite free pattern is consistent with an infinite paired stream and that no two descriptions collapse under completion.

### 3.3 Exact counts

### Theorem 3.2 (Finite Prefix Counting Theorem)

For every $n\ge0$, the number $A_n$ of admissible paired prefixes of length $2n$ is

$$
A_n=2^n.
$$

The number $B_m$ of unrestricted binary prefixes of length $m$ is

$$
B_m=2^m.
$$

#### Proof sketch

A paired prefix of length $2n$ has $n$ fixed even coordinates and $n$ independently chosen odd coordinates. Each free coordinate has two choices, so the multiplication principle gives $A_n=2^n$. An unrestricted prefix of length $m$ has two independent choices at each of $m$ positions, yielding $B_m=2^m$. $\square$

For the first six scales, the counts are

| $n$ | Paired count $A_n$ | Ambient count $B_{2n}$ | Identity |
|---:|---:|---:|:---|
| $0$ | $1$ | $1$ | $1^2=1$ |
| $1$ | $2$ | $4$ | $2^2=4$ |
| $2$ | $4$ | $16$ | $4^2=16$ |
| $3$ | $8$ | $64$ | $8^2=64$ |
| $4$ | $16$ | $256$ | $16^2=256$ |
| $5$ | $32$ | $1024$ | $32^2=1024$ |

The table illustrates an identity that holds at every scale, not merely the displayed cases.

## 4. Exact symbolic dimension

### 4.1 Definition of symbolic prefix-counting dimension

For a language $L\subseteq\{0,1\}^{\mathbb N}$, let $N_L(m)$ be the number of length-$m$ prefixes that occur among streams in $L$. When the limit exists, define the normalized symbolic prefix-counting dimension by

$$
\dim_{\mathrm{sym}}(L)
=\lim_{m\to\infty}\frac{\log N_L(m)}{m\log2}.
$$

The denominator is the logarithm of the ambient prefix count $2^m$. Thus a language with boundedly many prefixes has dimension $0$, while the full binary space has dimension $1$.

For the paired language, it suffices initially to inspect even scales $m=2n$. At odd scales $m=2n+1$, there are still only $n$ free odd positions, so $N_{\mathcal P}(2n+1)=2^n$. Both subsequences lead to the same limiting ratio.

### Theorem 4.1 (Exact Half-Dimension Theorem)

At every even scale $2n$,

$$
N_{\mathcal P}(2n)^2=2^{2n}=N_{\mathrm{full}}(2n).
$$

Consequently,

$$
\dim_{\mathrm{sym}}(\mathcal P)=\frac12,
$$

and this value is strictly intermediate:

$$
0<\frac12<1.
$$

#### Proof sketch

By Theorem 3.2, $N_{\mathcal P}(2n)=2^n$ and the ambient count is $2^{2n}$. Therefore

$$
N_{\mathcal P}(2n)^2=(2^n)^2=2^{2n}.
$$

For even scales,

$$
\frac{\log N_{\mathcal P}(2n)}{(2n)\log2}
=\frac{n\log2}{2n\log2}=\frac12
$$

for every $n>0$. For odd scales,

$$
\frac{\log N_{\mathcal P}(2n+1)}{(2n+1)\log2}
=\frac{n}{2n+1}\longrightarrow\frac12.
$$

Thus the full limit exists and equals $1/2$. The strict inequalities are immediate. $\square$

### 4.2 Interpretation

The theorem gives exact content to “sparse but not negligible.” The fraction of admissible length-$2n$ words among all binary words is

$$
\frac{2^n}{2^{2n}}=2^{-n},
$$

which tends to zero exponentially. In a density sense the language is sparse. Nevertheless, its number of distinguishable prefixes grows exponentially, so its normalized exponent is positive. Dimension records this residual exponential freedom.

This is symbolic dimension. Establishing equality with a specific Hausdorff or box-counting dimension requires fixing a metric normalization and developing the corresponding cylinder-cover theory. The present exact count is the finite-scale combinatorial core from which such results may be derived.

## 5. Binary real coding

### 5.1 Definitions

Associate to each binary theory $x$ the real number

$$
R(x)=\sum_{n=0}^{\infty}x_n2^{-(n+1)}.
$$

Since $0\le x_n\le1$, the series converges and $0\le R(x)\le1$. Define its $N$-term truncation by

$$
R_N(x)=\sum_{n=0}^{N-1}x_n2^{-(n+1)}.
$$

This is a dyadic rational computable from the first $N$ bits whenever those bits are available.

### Theorem 5.1 (Binary Approximation Theorem)

For every binary theory $x$ and every $N\ge0$,

$$
0\le R(x)-R_N(x)\le2^{-N}.
$$

#### Proof sketch

Subtracting the finite prefix leaves the tail

$$
R(x)-R_N(x)=\sum_{n=N}^{\infty}x_n2^{-(n+1)}.
$$

Every term is nonnegative, proving the lower bound. Replacing $x_n$ by its upper bound $1$ gives

$$
R(x)-R_N(x)
\le\sum_{n=N}^{\infty}2^{-(n+1)}=2^{-N}.
$$

The estimate is sharp: equality occurs when all bits from position $N$ onward equal $1$. $\square$

The theorem yields an explicit approximation algorithm. Read $N$ bits, sum their dyadic weights, and return the interval

$$
[R_N(x),R_N(x)+2^{-N}].
$$

It is guaranteed to contain $R(x)$ and has width $2^{-N}$. To achieve additive uncertainty at most $\varepsilon>0$, it suffices to choose

$$
N\ge\left\lceil\log_2\frac1\varepsilon\right\rceil.
$$

### Theorem 5.2 (Prefix Stability Theorem)

If binary theories $x$ and $y$ agree at every index $n<N$, then

$$
|R(x)-R(y)|\le2^{-N}.
$$

#### Proof sketch

The common prefix cancels from the difference:

$$
R(x)-R(y)=\sum_{n=N}^{\infty}(x_n-y_n)2^{-(n+1)}.
$$

Since $|x_n-y_n|\le1$, the triangle inequality for series gives

$$
|R(x)-R(y)|
\le\sum_{n=N}^{\infty}2^{-(n+1)}=2^{-N}.
$$

Equivalently, both streams share the same truncation and their possible continuations fill an interval no wider than the binary tail. $\square$

### Remark 5.3 (Nonunique binary expansions)

The map $R$ is not injective on all streams. For example, the stream beginning with $1$ and followed by zeros can represent the same real as the stream beginning with $0$ and followed by ones. The prefix metric remains separating, while the real coding identifies these dyadic endpoint pairs. The approximation and stability theorems do not require injectivity.

### Proposition 5.4 (Lipschitz comparison)

For all streams $x,y$,

$$
|R(x)-R(y)|\le d(x,y).
$$

#### Proof sketch

Write

$$
R(x)-R(y)=\sum_{n=0}^{\infty}(x_n-y_n)2^{-(n+1)}.
$$

At each coordinate, $|x_n-y_n|=\mathbf 1_{x_n\ne y_n}$. Apply the triangle inequality to the series. This observation explains why prefix closeness controls numerical closeness.

## 6. Algorithms and complexity

### 6.1 Prefix enumeration

To enumerate all admissible paired prefixes at scale $n$, iterate over integers $j$ from $0$ through $2^n-1$, write $j$ as an $n$-bit word $(b_0,\ldots,b_{n-1})$, and output

$$
(1,b_0,1,b_1,\ldots,1,b_{n-1}).
$$

The procedure outputs exactly $2^n$ prefixes. Constructing each prefix requires $O(n)$ bit operations, so the total output-sensitive time is $O(n2^n)$ and the working space, excluding output storage, is $O(n)$.

### 6.2 Certified real approximation

Given the first $N$ bits, initialize $s=0$ and add $x_n2^{-(n+1)}$ for $0\le n<N$. Return $s$ together with the interval $[s,s+2^{-N}]$. Using exact dyadic arithmetic, the sum can be represented as an integer divided by $2^N$. The procedure uses $O(N)$ arithmetic steps and $O(N)$ bits for the exact numerator.

### 6.3 Prefix comparison

Given two finite samples and a requested common-prefix length $N$, check equality coordinate by coordinate. If all first $N$ bits agree, report the certified bound $2^{-N}$ on the distance between their binary reals. The algorithm takes $O(N)$ time and $O(1)$ auxiliary space beyond the input.

These algorithms demonstrate three aspects of the theory: exact combinatorial growth, geometric convergence, and stability under shared information.

## 7. Computability and halting truth

### 7.1 Decidable and recursively enumerable predicates

A predicate on program codes is **computable** or **decidable** if an algorithm halts on every code and correctly returns whether the predicate holds. It is **recursively enumerable** if there is an algorithm that eventually confirms every positive instance, while it may run forever on negative instances.

Fix a natural-number input $u$. For each program code $c$, define the halting truth predicate

$$
H_u(c)=1
\quad\Longleftrightarrow\quad
\text{program }c\text{ eventually halts on input }u.
$$

### Theorem 7.1 (Halting Truth Theorem)

For every fixed input $u$, the predicate $H_u$ is not computable. Nevertheless, its positive instances are recursively enumerable.

#### Proof sketch

For noncomputability, suppose a total decision algorithm for $H_u$ existed. Standard program specialization allows arbitrary program-input pairs to be encoded as programs acting on the fixed input $u$. The assumed decider would therefore solve the general halting problem, contradicting the diagonal halting theorem.

For recursive enumerability, simulate each program on $u$. A direct semidecision procedure runs the chosen program and accepts if it halts. To enumerate all positive codes simultaneously, dovetail the simulations: at stage $t$, run the first $t$ programs for $t$ steps and announce those newly observed to halt. Every halting computation has finite duration and will eventually be discovered. $\square$

### 7.2 Relation to binary reals and Chaitin-style constructions

The Binary Approximation Theorem applies to every stream, including one formed from halting bits after an enumeration of program codes has been chosen. However, the theorem is conditional on possession of the first $N$ bits; it does not supply an algorithm for deciding those bits. Analytic approximability of a series tail and effective availability of its digits are distinct notions.

Chaitin’s halting probability $\Omega$ is defined for a prefix-free machine by summing $2^{-|p|}$ over halting programs $p$. Prefix-freeness invokes Kraft’s inequality and ensures the sum is bounded by $1$. The simple coordinate-weighted coding $R(x)$ studied here resembles $\Omega$ in turning halting information into a real, but it is not automatically an $\Omega$ number. No prefix-free machine has been fixed in the paired construction, and its elementary dimension $1/2$ is entirely computable.

This separation prevents two invalid inferences. First, a geometrically convergent binary series need not have computable bits. Second, the existence of an undecidable halting stream does not make every sparse symbolic language undecidable or give its dimension an uncomputable value.

## 8. Applications and conceptual bridges

### 8.1 Symbolic dynamics and information rate

The paired language is a periodic subshift-like constraint with one free bit per block of two. Its logarithmic prefix growth is an information rate: $n$ independent bits survive in a word of length $2n$. The dimension $1/2$ is therefore simultaneously a normalized combinatorial entropy.

A natural extension fixes a periodic mask of block length $b$ with $a$ free coordinates. At scales $bn$, the number of admissible prefixes is $2^{an}$, predicting normalized symbolic dimension

$$
\frac{a}{b}.
$$

This family can model constrained channels, symbolic encodings, or databases in which some fields are prescribed and others variable.

### 8.2 Hierarchical data and robust approximation

Prefix metrics occur naturally in tries, digital trees, coding theory, and hierarchical classification. The estimate $2^{-N}$ translates shared initial information into a certified uncertainty radius. In streaming settings, each incoming bit halves the worst-case interval for the coded real.

### 8.3 Logic and effective information

The halting truth theorem illustrates a one-sided mode of knowledge: positive facts can appear over time even when no terminating decision procedure handles all cases. This asymmetry underlies computably enumerable theories and monotone approximations to halting-probability reals. It also warns that a finite numerical approximation may conceal logically inaccessible digits.

## 9. Limitations

The phrase “the fractal dimension of mathematical truth” is meaningful only after several choices:

1. a syntax of statements;
2. a semantics or truth notion;
3. a foundational theory;
4. an enumeration or coding;
5. a metric and dimension definition.

Changing these choices may change the resulting geometry. The paired truth language is an explicit toy language, not the set of all true mathematical sentences. Its $1/2$ result concerns symbolic prefix-counting dimension. A theorem identifying it with box-counting or Hausdorff dimension would require a corresponding cover theory and metric normalization.

Likewise, the elementary language is not identified with Chaitin’s $\Omega$. The approximation theorem is universal and analytic; the uncomputability theorem concerns halting truth. The present work asserts neither that the paired language’s real is uncomputable nor that its dimension is uncomputable.

These qualifications are substantive. They isolate precisely what has been established and identify the additional hypotheses needed for stronger claims.

## 10. Future work

Several extensions follow naturally.

First, one may prove that the prefix metric induces the product topology on Cantor space and study completeness and compactness. Second, cylinder covers can be used to define upper and lower box-counting dimensions and to derive a geometric dimension theorem from the exact prefix identity. Third, a prefix-free machine can be introduced explicitly, followed by Kraft boundedness, monotone rational approximation of its halting probability, and the extraction of finite halting information from sufficiently precise approximations.

A deeper direction is the effective Hausdorff dimension of individual streams, expressed through asymptotic prefix-free Kolmogorov complexity. That is the standard setting in which fractal dimension, randomness, and halting-probability reals genuinely converge. The periodic paired construction should also be generalized to $a$ free coordinates in every block of length $b$, yielding dimension $a/b$. Finally, coding-invariance results under bi-Lipschitz recodings would clarify which dimensions survive changes in statement enumeration.

## 11. Conclusion

An infinite binary truth assignment admits a natural prefix-sensitive metric. Within that space, fixing one bit in every pair leaves exactly $2^n$ admissible prefixes at length $2n$, compared with $2^{2n}$ ambient prefixes. The exact square identity yields symbolic dimension $1/2$: the language has vanishing density but positive exponential complexity.

The same streams define binary reals whose first $N$ digits give certified lower approximations with error at most $2^{-N}$. Common prefixes guarantee equally explicit numerical stability. Computability enters separately: halting truth is undecidable but recursively enumerable, showing how a stream may be approximable in a one-sided logical sense without being decidable.

The principal contribution is therefore a disciplined synthesis. Symbolic counting measures retained freedom; prefix geometry measures informational agreement; binary series translate finite information into analytic error bounds; and computability theory distinguishes approximation from decision. Together they provide a precise model for studying the geometry of truth while making clear why no coding-independent dimension of all mathematical truth has yet been defined.
