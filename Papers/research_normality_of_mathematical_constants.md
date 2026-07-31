# From Multiplicative Orbits to Normal Digit Statistics

**Aristotle**  
**31 July 2026**

## Abstract

Normality in an integer base expresses the asymptotic uniformity of every finite block in a real number’s positional expansion. This paper gives a self-contained derivation of a structural criterion for normality: if the fractional parts of the multiplicative orbit $b^n x$ are equidistributed in the unit interval, then $x$ is normal in base $b$. The proof rests on an exact correspondence between a length-$k$ digit block and membership of $\{b^n x\}$ in one of the $b^k$ equal half-open subintervals of $[0,1)$. We formulate empirical frequencies, interval equidistribution, block extraction, and base normality; prove the floor–interval correspondence; and derive the connector theorem by comparing interval length with expected block frequency. We then present numerical algorithms for finite experiments, explain their complexity and limitations, and discuss the relation to dynamical systems, symbolic coding, probability, and Weyl sums. The criterion deliberately does not claim normality for $\pi$, $e$, or $\sqrt2$: establishing the required orbit estimates for these constants remains open. The result instead isolates the exact analytic input that such a proof would require and clarifies why irrationality, algebraicity, transcendence, and algebraic independence do not by themselves provide it.

## 1. Introduction

Let $b\ge 2$ be an integer. The fractional expansion of a real number $x$ in base $b$ is an infinite word over the alphabet $\{0,1,\ldots,b-1\}$. The number is normal in base $b$ if every word of length $k$ appears with limiting frequency $b^{-k}$, for every positive integer $k$. Thus normality is a precise statement that finite digit patterns obey the uniform probability law suggested by independent draws from $b$ equally likely symbols.

The digits of familiar constants such as $\pi$, $e$, and $\sqrt2$ appear irregular in extensive computations. Nevertheless, no proof is known that any of these constants is normal in a familiar integer base. Their arithmetic classifications do not settle the issue. Rationality prevents normality because rational expansions are eventually periodic, but irrationality does not ensure balanced digits. Algebraic irrationality is also insufficient with present knowledge: normality of $\sqrt2$ remains unknown. Transcendence of $\pi$ and $e$, and even stronger statements excluding polynomial relations among constants, do not directly control their digit frequencies.

A productive reformulation replaces the digit string by a dynamical orbit. Multiplication by $b$ shifts the radix point one place. Consequently, the fractional part

$$
u_n=\{b^n x\}
$$

encodes the tail of the base-$b$ expansion beginning at position $n+1$. The first $k$ digits of that tail are determined by which one of the $b^k$ equal subintervals of $[0,1)$ contains $u_n$. Digit statistics can therefore be read as visit statistics of the orbit $(u_n)$.

The main theorem states that interval equidistribution of this orbit implies base-$b$ normality. This implication is classical in spirit, but its careful formulation exposes several useful points. The coding uses half-open intervals so that boundary points are assigned uniquely. The block is represented by an integer from $0$ to $b^k-1$, thereby treating leading zeroes correctly. Finally, the proof compares empirical frequencies directly, avoiding any probabilistic independence assumption.

The paper proceeds as follows. Section 2 introduces fractional parts and empirical frequencies. Section 3 defines digit blocks and normality. Section 4 proves the exact floor–interval correspondence. Section 5 establishes the main connector theorem. Section 6 gives finite algorithms and examples. Sections 7 and 8 discuss applications, limitations, and the frontier posed by named constants. Section 9 presents future directions.

## 2. Preliminaries

### 2.1. Fractional parts and the base map

For $y\in\mathbb R$, define its fractional part by

$$
\{y\}=y-\lfloor y\rfloor.
$$

Then $0\le \{y\}<1$. Fix an integer base $b\ge 2$ and define the transformation

$$
T_b:[0,1)\to[0,1),\qquad T_b(t)=\{bt\}.
$$

Iteration gives

$$
T_b^n(\{x\})=\{b^n x\}.
$$

If $x$ has fractional expansion

$$
\{x\}=0.d_1d_2d_3\cdots{}_b
=\sum_{j=1}^{\infty}\frac{d_j}{b^j},
$$

then, away from the standard ambiguity between terminating expansions and expansions ending in repeated digits $b-1$,

$$
T_b^n(\{x\})=0.d_{n+1}d_{n+2}d_{n+3}\cdots{}_b.
$$

The half-open interval conventions below select a consistent coding even at boundaries.

### 2.2. Empirical frequencies

Let $P(n)$ be a property of nonnegative integers. Its empirical frequency among the first $N$ indices is

$$
F_N(P)=\frac{1}{N}\#\{n\in\mathbb N:0\le n<N\text{ and }P(n)\},
$$

for $N\ge 1$. Values at $N=0$ play no role in asymptotic statements.

For a sequence $(u_n)$ and set $E$, we abbreviate

$$
F_N(u;E)=\frac{1}{N}\#\{0\le n<N:u_n\in E\}.
$$

This is the mass assigned to $E$ by the empirical probability measure

$$
\mu_N=\frac{1}{N}\sum_{n=0}^{N-1}\delta_{u_n},
$$

where $\delta_t$ denotes a unit point mass at $t$.

### 2.3. Interval equidistribution

**Definition 2.1 (Interval equidistribution).** A sequence $(u_n)_{n\ge 0}$ in $[0,1)$ is interval-equidistributed if, for every pair $a,c\in\mathbb R$ satisfying $0\le a<c\le 1$,

$$
\lim_{N\to\infty}F_N(u;[a,c))=c-a.
$$

The limiting value is Lebesgue length. The use of all half-open intervals makes the definition directly compatible with positional partitions.

Equidistribution is stronger than density. Density only says that every nonempty open interval contains some terms of the sequence. Equidistribution prescribes the asymptotic proportion of terms in every interval. A sequence may be dense while spending an overwhelmingly large proportion of its indices in a small region; such a sequence is not equidistributed.

## 3. Digit blocks and normality

### 3.1. Integer coding of blocks

Fix $k\ge 1$. A block $(d_1,\ldots,d_k)$ with $0\le d_j<b$ is encoded by

$$
A=d_1b^{k-1}+d_2b^{k-2}+\cdots+d_k.
$$

This gives a bijection between length-$k$ blocks and integers $A$ satisfying $0\le A<b^k$. Leading zeroes are retained because the length $k$ is fixed: for example, in base ten the code $7$ at length three denotes the block $007$.

**Definition 3.1 (Block extractor).** For $b\ge 2$, $k\ge 1$, $x\in\mathbb R$, and $n\ge 0$, define

$$
D_{b,k}(x,n)=\left\lfloor b^k\{b^n x\}\right\rfloor.
$$

Since $0\le \{b^n x\}<1$, one has

$$
0\le D_{b,k}(x,n)<b^k.
$$

The extractor returns the integer code of the first $k$ base-$b$ digits in the tail represented by $\{b^n x\}$.

### 3.2. Base normality

**Definition 3.2 (Base-$b$ normality).** Let $b\ge 2$. A real number $x$ is normal in base $b$ if, for every integer $k\ge 1$ and every code $A$ with $0\le A<b^k$,

$$
\lim_{N\to\infty}
\frac{1}{N}\#\{0\le n<N:D_{b,k}(x,n)=A\}
=rac{1}{b^k}.
$$

This overlapping-block definition counts a block at every starting position. It requires simultaneous asymptotic uniformity at all finite lengths. In particular, normality implies simple normality, which is the corresponding statement only for $k=1$. The converse is false in general: equal single-digit frequencies need not imply equal frequencies of pairs or longer words.

The target frequency $b^{-k}$ is forced by the number of possible blocks. There are $b^k$ codes, and the events $D_{b,k}(x,n)=A$ partition the set of indices for any fixed $n$. Uniformity therefore assigns equal mass $1/b^k$ to each code.

## 4. The geometric coding lemma

For $0\le A<b^k$, define the base-$b$ cylinder interval

$$
I_{A,k}=\left[\frac{A}{b^k},\frac{A+1}{b^k}\right).
$$

These $b^k$ intervals form a disjoint partition of $[0,1)$. Each has length $b^{-k}$.

**Lemma 4.1 (Floor–interval correspondence).** Let $b\ge 2$, let $k,n\ge 0$, let $x\in\mathbb R$, and let $A$ be a nonnegative integer. Then

$$
D_{b,k}(x,n)=A
$$

if and only if

$$
\{b^n x\}\in
\left[\frac{A}{b^k},\frac{A+1}{b^k}\right).
$$

**Proof sketch.** Set $t=\{b^n x\}$. By definition,

$$
D_{b,k}(x,n)=\lfloor b^k t\rfloor.
$$

For every real $z$ and integer $A$, the equality $\lfloor z\rfloor=A$ is equivalent to

$$
A\le z<A+1.
$$

Apply this with $z=b^k t$. Because $b^k>0$, division preserves both inequalities and yields

$$
\frac{A}{b^k}\le t<\frac{A+1}{b^k}.
$$

This is exactly membership in the stated half-open interval. Conversely, multiplying the interval inequalities by $b^k$ gives $A\le b^k t<A+1$, so the floor equals $A$. $\square$

The lemma is elementary but decisive. It equates two predicates index by index, not merely in the limit. Consequently, their finite counts and empirical frequencies are identical for every $N$.

**Corollary 4.2 (Equality of empirical counts).** Under the assumptions of Lemma 4.1, for every $N\ge 1$,

$$
\#\{0\le n<N:D_{b,k}(x,n)=A\}
=
\#\{0\le n<N:\{b^n x\}\in I_{A,k}\}.
$$

**Proof sketch.** Lemma 4.1 gives equivalence of the two membership conditions for each index $n$. Hence the two finite index sets are equal and have equal cardinality. $\square$

### 4.1. Boundary conventions

Half-open intervals are not cosmetic. If both endpoints were included, adjacent cells would overlap. If both were excluded, boundary points would belong to neither cell. The partition

$$
[0,1)=\bigsqcup_{A=0}^{b^k-1}I_{A,k}
$$

assigns each fractional part exactly one code.

The familiar dual representation of a terminating expansion causes no difficulty for this formulation. For example, a rational point may be written with a terminating tail of zeroes or a nonterminating tail of digits $b-1$. The floor-based block extractor and half-open partition make one consistent choice. Normality itself is unaffected by changing finitely many digits, since finite changes contribute at most a vanishing $O(1/N)$ amount to empirical frequencies.

## 5. Main theorem

**Theorem 5.1 (Normality from interval equidistribution).** Let $b\ge 2$ be an integer and let $x\in\mathbb R$. Suppose the sequence

$$
u_n=\{b^n x\},\qquad n\ge 0,
$$

is interval-equidistributed in $[0,1)$. Then $x$ is normal in base $b$.

**Proof.** Fix an arbitrary block length $k\ge 1$ and an arbitrary block code $A$ satisfying $0\le A<b^k$. The corresponding cylinder interval is

$$
I_{A,k}=\left[\frac{A}{b^k},\frac{A+1}{b^k}\right).
$$

Its endpoints satisfy

$$
0\le \frac{A}{b^k}<\frac{A+1}{b^k}\le 1,
$$

where the final inequality follows from $A+1\le b^k$. Thus the interval lies in $[0,1)$ and the equidistribution hypothesis applies.

By Corollary 4.2, the empirical frequency of the block code $A$ is exactly the empirical frequency with which $u_n$ visits $I_{A,k}$. Interval equidistribution gives

$$
\lim_{N\to\infty}
\frac{1}{N}\#\{0\le n<N:D_{b,k}(x,n)=A\}
=
|I_{A,k}|.
$$

The interval length is

$$
|I_{A,k}|
=
\frac{A+1}{b^k}-\frac{A}{b^k}
=
\frac{1}{b^k}.
$$

Therefore the block $A$ has the required limiting frequency. Since both $k$ and $A$ were arbitrary, every finite base-$b$ block has limiting frequency $b^{-k}$. Hence $x$ is normal in base $b$. $\square$

### 5.1. Interpretation as a pushforward of empirical measures

The theorem can be expressed in the language of probability measures. Equidistribution says that the empirical measures

$$
\mu_N=\frac{1}{N}\sum_{n=0}^{N-1}\delta_{\{b^n x\}}
$$

converge on intervals to Lebesgue measure $\lambda$. Define the coding map

$$
C_k(t)=\lfloor b^k t\rfloor,
\qquad 0\le t<1.
$$

The inverse image of a code $A$ is precisely $I_{A,k}$. Pushing $\mu_N$ forward through $C_k$ gives the empirical distribution of length-$k$ block codes, while pushing Lebesgue measure forward gives the uniform distribution on $\{0,\ldots,b^k-1\}$. The main theorem therefore says that convergence of the continuous-state orbit distribution yields convergence of every finite symbolic observation.

This viewpoint is useful beyond positional notation. Whenever a dynamical system is observed through a finite measurable partition, visit frequencies to partition atoms become symbol frequencies. Here the partition atoms happen to be equal intervals, so their Lebesgue measures are exactly the probabilities required for normality.

## 6. Algorithms and numerical demonstrations

Finite computation cannot prove an asymptotic statement quantified over all block lengths, but it can demonstrate the exact coding identity and measure discrepancies at selected scales. Exact rational arithmetic is preferable when the input is rational because it avoids cumulative floating-point error.

### 6.1. Direct orbit histogram

Given a rational approximation $x=p/q$, base $b$, block length $k$, and sample size $N$, compute the orbit recursively:

$$
t_0=\{x\},\qquad t_{n+1}=\{bt_n\}.
$$

At each step set

$$
A_n=\lfloor b^k t_n\rfloor
$$

and increment the count for code $A_n$. The recursion is mathematically equivalent to evaluating $\{b^n x\}$ but avoids constructing the enormous integer $b^n$.

With an array of $b^k$ counters, the time complexity is $O(N+b^k)$ and the memory complexity is $O(b^k)$, excluding the growth cost of exact rational numerators and denominators. For a fixed rational denominator, modular arithmetic offers an even more economical implementation: if $x=p/q$, then

$$
\{b^n x\}=\frac{b^n p\bmod q}{q}
$$

when the remainder is chosen in $\{0,\ldots,q-1\}$. Updating the remainder by multiplication modulo $q$ keeps integer sizes bounded.

### 6.2. Discrepancy statistic

Let $C_A(N)$ be the number of occurrences of code $A$ among the first $N$ positions. Define the equal-cell discrepancy at level $k$ by

$$
\Delta_{b,k}(N)
=
\max_{0\le A<b^k}
\left|\frac{C_A(N)}{N}-\frac{1}{b^k}\right|.
$$

If the orbit is interval-equidistributed, then for every fixed $k$,

$$
\lim_{N\to\infty}\Delta_{b,k}(N)=0.
$$

This follows because there are only finitely many codes at fixed $k$, and each individual frequency converges to $b^{-k}$. Small finite discrepancy is a diagnostic, not a certificate of the limit.

A related chi-square statistic is

$$
\chi^2_{b,k}(N)
=
\sum_{A=0}^{b^k-1}
\frac{(C_A(N)-N/b^k)^2}{N/b^k}.
$$

It summarizes deviations across all cells. Classical statistical interpretations assume a random sampling model, whereas the orbit is deterministic, so the statistic should be used descriptively unless additional hypotheses justify probabilistic calibration.

### 6.3. Exact verification of the coding identity

For each sampled index, one may compute both sides of the correspondence:

1. the code $A_n=\lfloor b^k t_n\rfloor$;
2. the unique interval index $A$ satisfying $A/b^k\le t_n<(A+1)/b^k$.

Exact arithmetic shows equality at every index. This verifies the computational implementation of the lemma and explains why block histograms and equal-cell orbit histograms coincide.

### 6.4. Important numerical limitation for rational inputs

Every finite decimal supplied to a program is rational. For a rational $x=p/q$, the sequence $b^n p\bmod q$ eventually repeats because it takes values in a finite set. Thus the orbit is eventually periodic and cannot provide a proof of normality. A high-precision truncation of $\pi$ may mimic its initial digits for a while, but the truncated rational ultimately exhibits periodic dynamics. Numerical demonstrations must therefore be presented as finite illustrations of the connector, not as evidence capable of deciding the open problem.

## 7. Applications and mathematical context

### 7.1. Symbolic dynamics

The map $T_b(t)=\{bt\}$ expands distances locally by a factor of $b$ and folds the interval back onto itself. Partitioning $[0,1)$ into the $b$ intervals

$$
\left[\frac{j}{b},\frac{j+1}{b}\right),
\qquad 0\le j<b,
$$

produces one digit per iterate. Refining to length-$k$ cylinders records $k$ successive symbols. The normality criterion is thus an instance of a general principle: a generic orbit for an invariant measure yields symbol frequencies equal to the measures of cylinder sets.

Lebesgue measure is invariant under $T_b$. Indeed, each interval has $b$ inverse branches, each scaled by $1/b$, and their total measure equals the original interval length. Ergodicity of this map, together with a pointwise ergodic theorem, explains why almost every starting point is normal in base $b$. That broad measure-theoretic theorem is distinct from the pointwise connector proved here: the connector assumes equidistribution for one specified orbit and converts it into normality for that specified number.

### 7.2. Probability without independence

The expected frequency $b^{-k}$ resembles the probability of a prescribed $k$-letter word in independent uniform trials. However, the theorem does not assume that the digits are random or independent. The sequence is deterministic. Equidistribution supplies the relevant one-dimensional visit frequencies directly.

Moreover, all overlapping blocks are included. Consecutive block events share $k-1$ digits and are therefore not independent even in a genuinely random digit model. The proof bypasses dependence questions because each block occurrence is simply a membership event for one orbit point.

### 7.3. Weyl’s criterion

A major route to equidistribution is Weyl’s criterion. For a sequence $(u_n)$ in $[0,1)$, equidistribution is equivalent to the vanishing of all nontrivial Fourier averages

$$
\lim_{N\to\infty}
\frac{1}{N}\sum_{n=0}^{N-1}e^{2\pi i m u_n}=0
$$

for every nonzero integer $m$. Applied to $u_n=\{b^n x\}$, the exponential is unchanged if the fractional-part braces are removed, giving sums

$$
\frac{1}{N}\sum_{n=0}^{N-1}e^{2\pi i m b^n x}.
$$

Therefore suitable cancellation estimates for every $m\ne 0$ would imply interval equidistribution and, by Theorem 5.1, base-$b$ normality. This identifies an analytic target for any attempt to prove normality of a specific constant.

The sequence $b^n$ is lacunary: successive frequencies grow geometrically. For almost-everywhere results, lacunarity often produces random-like behavior. For a named value of $x$, however, proving the required cancellation can be extremely difficult because one needs detailed arithmetic control of the phases $m b^n x$ modulo one.

### 7.4. Random-number assessment

Normality is relevant to the appearance of pseudorandomness, but it is not a complete notion of randomness and is not a cryptographic guarantee. A computable number can be normal, and normality only prescribes limiting frequencies of finite blocks. It does not imply unpredictability, resistance to reconstruction, or computational security.

Nevertheless, the orbit-block dictionary is useful in diagnostics. Histogramming $\{b^n x\}$ over equal cells is exactly the same finite test as histogramming length-$k$ digit blocks. The geometric language may make discrepancies and multiscale structure easier to visualize.

## 8. Boundaries of the result

### 8.1. No claim for specific famous constants

The theorem is conditional. It says:

$$
\text{equidistribution of }\{b^n x\}
\quad\Longrightarrow\quad
\text{normality of }x\text{ in base }b.
$$

It does not establish the premise for $x=\pi$, $e$, or $\sqrt2$. Normality of each of these constants in standard bases remains open. A faithful interpretation of the theorem must preserve this distinction.

### 8.2. Irrationality and normality

Every base-$b$ normal number is irrational, since a rational base-$b$ expansion is eventually periodic and cannot realize all blocks with the required frequencies. The converse fails dramatically. One can construct irrational numbers whose expansions omit a digit or contain long deterministic stretches, making them nonnormal.

Hence a proof of irrationality supplies only a necessary condition, not the orbit estimates demanded by the connector theorem.

### 8.3. Algebraicity and transcendence

Algebraic and transcendental classifications concern polynomial equations with rational or integer coefficients. Normality concerns the statistical distribution of positional digits, equivalently the orbit $\{b^n x\}$. No general implication currently turns the algebraicity of an irrational into normality. In particular, the algebraic irrational $\sqrt2$ is not known to be normal in any familiar base.

Likewise, transcendence does not imply normality. There are explicitly constructible transcendental numbers with highly sparse or biased digit expansions. Thus the transcendence of $\pi$ and $e$ does not provide the Fourier cancellation required by Weyl’s criterion.

Algebraic independence is stronger than individual transcendence in a different direction: it excludes polynomial relations among several numbers. Yet it still does not directly estimate the sequence of fractional parts $\{b^n x\}$. The logical boundary is important. Algebraic complexity and digit-statistical uniformity are distinct properties, and known methods do not bridge them for the celebrated constants.

### 8.4. Base dependence

Normality is defined relative to a base. A number may be normal in one base without a known proof of normality in another. A number normal in every integer base $b\ge 2$ is called absolutely normal. Measure theory shows that almost every real number is absolutely normal, because one may intersect the full-measure normality sets over the countably many bases. This does not identify whether any particular familiar constant belongs to that intersection.

## 9. Converse questions and extensions

The proved implication uses equidistribution on every interval although normality directly supplies frequencies only for aligned base-$b$ cylinder intervals. A natural converse strategy has two stages.

First, uniform frequencies for every block imply the correct limiting visit frequency for every $b$-adic interval of the form

$$
\left[\frac{A}{b^k},\frac{A+1}{b^k}\right).
$$

Finite disjoint unions then give the correct frequency for intervals whose endpoints lie on a common $b$-adic grid. Second, an arbitrary interval $[a,c)$ can be approximated from inside and outside by such grid intervals. The difference in lengths can be made arbitrarily small as $k$ grows. A squeeze argument should then yield interval equidistribution.

This would establish the equivalence between base-$b$ normality and equidistribution of the multiplicative orbit. The forward direction proved in this paper is the direct and exact half of that equivalence; the converse adds an approximation argument.

Another extension concerns quantitative rates. Suppose one has a discrepancy estimate

$$
\left|F_N(u;[a,c))-(c-a)\right|\le E(N)
$$

uniformly over all intervals, where $E(N)\to 0$. Applying it to $I_{A,k}$ immediately yields

$$
\left|
\frac{C_A(N)}{N}-\frac{1}{b^k}
\right|
\le E(N).
$$

Thus quantitative equidistribution transfers without loss to quantitative block-frequency bounds. If the interval estimate is only available for a restricted family or has endpoint-dependent constants, the transfer can still be made cell by cell.

## 10. Future work

Several directions emerge naturally.

1. **Converse criterion.** Prove that uniform frequencies of all aligned base-$b$ cylinder intervals imply interval equidistribution of $\{b^n x\}$, first for $b$-adic intervals and then for arbitrary intervals by approximation.

2. **Weyl criterion.** Connect interval equidistribution to vanishing exponential sums

   $$
   \frac{1}{N}\sum_{n<N}\exp(2\pi i m b^n x)
   $$

   for every nonzero integer $m$.

3. **Measure-theoretic normality.** Use ergodicity of the map $x\mapsto\{bx\}$ and a pointwise ergodic theorem to prove that almost every real is base-$b$ normal.

4. **Absolute normality.** Intersect the full-measure normality sets over all integer bases to show that almost every real is absolutely normal.

5. **Specific constants.** A proof for $\pi$, $e$, or $\sqrt2$ would require genuinely new number theory. Normality of each in every familiar base remains open, and known algebraic classifications do not supply the exponential-sum bounds needed by Weyl’s criterion.

6. **Algebraic independence boundary.** Develop precise statements describing the limited implications between digit statistics and algebraic properties. Rational numbers are not normal in any base, but familiar algebraic irrationals such as $\sqrt2$ are not known to be normal. Transcendence and algebraic independence do not by themselves provide the orbit estimates required for normality of constants such as $\pi$ and $e$.

## 11. Conclusion

The relation between digit blocks and multiplicative dynamics is exact. The length-$k$ block beginning at position $n$ is the integer

$$
\left\lfloor b^k\{b^n x\}\right\rfloor,
$$

and the event that this code equals $A$ is precisely the event that the orbit point $\{b^n x\}$ lies in the equal cell $[A/b^k,(A+1)/b^k)$. If the orbit visits every interval according to its length, then it visits this cell with limiting frequency $b^{-k}$. Arbitrary choice of $k$ and $A$ gives normality.

This connector separates a simple structural deduction from a difficult arithmetic premise. It explains why equidistribution is the right dynamical target, why finite-block frequencies inherit the uniform law, and why computations can illustrate but not prove the claim. Most importantly, it locates the unresolved challenge for named constants: one must control the long-term distribution, or equivalently the Fourier cancellation, of their exponentially magnified fractional parts.