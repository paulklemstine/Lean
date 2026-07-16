# Shifted Triangular Values and Square Spectra in the Displayed Anti-Fibonacci Sequence

**Aristotle**  
**July 16, 2026**

## Abstract

We analyze the integer sequence displayed as $1,1,2,4,7,11,16,\ldots$ in a proposed anti-Fibonacci construction. The literal greedy description “choose the smallest positive integer unequal to the sum of the preceding two terms” does not generate these data. We therefore isolate the mathematically coherent object forced by the displayed values: $A(0)=1$ and $A(n+1)=A(n)+n$. We derive the exact formula

$$
A(n)=1+\frac{n(n-1)}2,
$$

which implies quadratic growth with leading coefficient $1/2$, not $1/4$. Consecutive values satisfy the exact shifted-square identity

$$
A(n)+A(n+1)=n^2+2,
$$

and the individual value spectrum is characterized by

$$
8A(n)-7=(2n-1)^2.
$$

We prove that gaps are exactly linear and arbitrarily large, that the error from every quarter-square bounded approximation is unbounded, and that $A(1{,}000{,}000)=499{,}999{,}500{,}001$. We also show that the odd-index Fibonacci sequence strictly dominates $A(n)$ for every $n\ge 6$; hence any combinatorial row-sum model equal to $F_{2n+1}$ has the same domination property. Algorithms for evaluation, membership, spectral testing, and numerical exploration follow directly from the identities. The results replace an inconsistent avoidance narrative with an exact theory of shifted triangular numbers, sparse spectra, and quadratic Diophantine structure.

## 1. Introduction

The Fibonacci numbers $F_0=0$, $F_1=1$, and

$$
F_{k+2}=F_{k+1}+F_k
$$

are the archetype of additive recurrence. Their exponential growth, neighboring-ratio limit, tiling interpretations, and appearances in combinatorial arrays make them a natural target for “anti” constructions. One proposed anti-Fibonacci sequence was presented as

$$
1,1,2,4,7,11,16,\ldots,
$$

with an informal rule asking each term to avoid equality with the sum of its two predecessors. Conjectures attached to that proposal included quarter-square growth, bounded error from $\lfloor n^2/4\rfloor$, nonconvergent neighboring ratios, and density-zero behavior.

The first task is logical rather than asymptotic: one must check that the rule generates the data. It does not. If only one positive integer is forbidden at each stage, the smallest admissible positive integer is generally $1$, so the displayed sequence cannot arise from that literal rule. A theorem about the displayed list must therefore begin by defining the list independently of the incompatible prose.

The first differences reveal the intended structure:

$$
A(1)-A(0)=0,
$$

$$
A(2)-A(1)=1,
$$

$$
A(3)-A(2)=2,
$$

and in general the evident continuation is

$$
A(n+1)-A(n)=n.
$$

This recurrence places the sequence among shifted triangular numbers. Its exact tractability allows us to distinguish which conjectures survive correction and which fail. In particular, density-zero behavior survives for the value set, but the proposed leading coefficient and ratio oscillation do not.

The central positive discovery is a square-spectrum identity: every consecutive sum is exactly two more than a square, and every shifted square of that form occurs. A second square identity characterizes individual sequence values. Together these facts turn recurrence questions into perfect-square tests and expose a Diophantine structure suitable for further study.

Our approach is deliberately elementary and exact. We begin with finite differences, derive a closed form, and use it to settle the asymptotic claims before developing the two spectra. We then extract consequences for gaps and density, compare the sequence with odd-index Fibonacci growth, and translate the identities into practical algorithms. This order keeps each conclusion traceable to a single explicit polynomial formula while preserving the combinatorial interpretation behind it.

## 2. Definitions and preliminary identities

### Definition 2.1 (The displayed anti-Fibonacci sequence)

For every nonnegative integer $n$, define $A(n)$ recursively by

$$
A(0)=1,
\qquad
A(n+1)=A(n)+n.
$$

The terminology “displayed anti-Fibonacci sequence” refers only to this recurrence. It must not be confused with the distinct greedy process that excludes a single preceding sum.

The first terms are

$$
A(0)=1,
A(1)=1,
A(2)=2,
A(3)=4,
A(4)=7,
A(5)=11,
A(6)=16.
$$

### Lemma 2.2 (Exact first differences)

For every nonnegative integer $n$,

$$
A(n+1)-A(n)=n.
$$

**Proof sketch.** This is the defining recurrence rearranged. Since $A(n+1)\ge A(n)$, ordinary integer subtraction introduces no truncation issue. The identity records that the gap after the $n$th term is exactly $n$. $\square$

### Theorem 2.3 (Closed form)

For every nonnegative integer $n$,

$$
A(n)=1+\frac{n(n-1)}2.
$$

Equivalently,

$$
2A(n)+n=n^2+2.
$$

**Proof sketch.** Iterating the recurrence gives

$$
A(n)=A(0)+\sum_{k=0}^{n-1}k
=1+\frac{n(n-1)}2.
$$

Alternatively, induction starts at $A(0)=1$. If the formula holds at $n$, then

$$
A(n+1)=1+\frac{n(n-1)}2+n
=1+\frac{n(n+1)}2,
$$

which is the required formula at $n+1$. Multiplication by $2$ and rearrangement yield the equivalent polynomial identity. $\square$

This formula identifies $A(n)$ as the triangular number $\binom n2$ shifted by one:

$$
A(n)=1+\binom n2.
$$

Thus $A(n)$ may be interpreted as the number of unordered pairs in an $n$-element set, together with one distinguished extra object.

### Corollary 2.4 (Asymptotic growth)

The sequence has exact expansion

$$
A(n)=\frac12n^2-\frac12n+1,
$$

and therefore

$$
\lim_{n\to\infty}\frac{A(n)}{n^2}=\frac12.
$$

**Proof sketch.** Divide the closed form by $n^2$ for $n>0$:

$$
\frac{A(n)}{n^2}=\frac12-\frac{1}{2n}+\frac{1}{n^2}.
$$

The last two terms tend to zero. $\square$

### Corollary 2.5 (Neighboring-ratio limit)

The successive ratios converge to $1$:

$$
\lim_{n\to\infty}\frac{A(n+1)}{A(n)}=1.
$$

**Proof sketch.** The closed form gives

$$
\frac{A(n+1)}{A(n)}
=
\frac{n^2+n+2}{n^2-n+2}.
$$

Dividing numerator and denominator by $n^2$ gives the limit $1$. In particular, the ratios do not oscillate between $1$ and $2$. $\square$

## 3. The consecutive-sum square spectrum

### Theorem 3.1 (Shifted-Square Consecutive-Sum Theorem)

For every nonnegative integer $n$,

$$
A(n)+A(n+1)=n^2+2.
$$

**Proof sketch.** Apply Theorem 2.3 at $n$ and $n+1$:

$$
A(n)=1+\frac{n(n-1)}2,
\qquad
A(n+1)=1+\frac{n(n+1)}2.
$$

Adding gives

$$
A(n)+A(n+1)
=2+\frac{n(n-1)+n(n+1)}2
=2+n^2.
$$

Geometrically, two consecutive triangular arrangements combine into an $n\times n$ square, while the two unit shifts contribute the extra $2$. $\square$

The first values are

$$
2,3,6,11,18,27,38,\ldots,
$$

corresponding to $n=0,1,2,3,4,5,6$.

### Theorem 3.2 (Exact consecutive-sum spectrum)

For a nonnegative integer $m$, the following conditions are equivalent:

1. There exists a nonnegative integer $n$ such that $m=A(n)+A(n+1)$.
2. There exists a nonnegative integer $n$ such that $m=n^2+2$.
3. The integer $m-2$ is a perfect square.

**Proof sketch.** The equivalence of the first two statements is exactly Theorem 3.1 in both directions: each index produces $n^2+2$, and every number $n^2+2$ is produced at that same index. The third condition is simply a restatement of the second. $\square$

This theorem yields a constant-space membership algorithm. For $m<2$, return false. Otherwise compute $r=\lfloor\sqrt{m-2}\rfloor$ and test whether $r^2=m-2$. With an integer square-root routine, the bit complexity is governed by square-root computation rather than by generating all preceding sequence values.

## 4. The individual-value square spectrum

The same quadratic formula gives a second, independent square relation.

### Theorem 4.1 (Odd-Square Value Criterion)

For every nonnegative integer $n$,

$$
8A(n)-7=(2n-1)^2.
$$

Consequently, a positive integer $m$ is a value of the sequence if and only if $8m-7$ is the square of an odd integer. The initial repetition $A(0)=A(1)=1$ means that the value $1$ has two indices; every value $A(n)$ with $n\ge 1$ has a unique positive index.

**Proof sketch.** Substitute the closed form:

$$
8A(n)-7
=8\left(1+\frac{n(n-1)}2\right)-7
=4n^2-4n+1
=(2n-1)^2.
$$

Conversely, suppose $8m-7=q^2$ for an odd integer $q$. Since $q$ may be replaced by $|q|$, write $q=2n-1$ with $n\ge 1$. Rearranging the equation gives

$$
m=1+\frac{n(n-1)}2=A(n).
$$

The recurrence has strictly positive gaps for $n\ge 1$, so values after the repeated initial $1$ are distinct. $\square$

Theorem 4.1 supplies a second exact membership algorithm: compute $D=8m-7$, take its integer square root, and check whether the result squares back to $D$. Oddness is automatic when $D\equiv1\pmod 8$, but may also be tested explicitly.

The coexistence of the two square spectra is especially useful. Individual values are transformed odd squares, while consecutive sums are squares shifted by $2$. Requiring a number to belong to both classes leads to an affine quadratic equation. After completing squares, such intersections naturally become Pell-type Diophantine problems. A complete classification is not asserted here, but the reduction identifies a concrete direction for further work.

## 5. Gaps, sparsity, and counting

### Theorem 5.1 (Arbitrarily large gaps)

For every nonnegative integer $C$, there exists a nonnegative integer $n$ such that

$$
A(n+1)-A(n)>C.
$$

Indeed, every $n>C$ has this property.

**Proof sketch.** By Lemma 2.2, the left side equals $n$. Taking $n=C+1$ gives the result. $\square$

Thus the absolute separation between adjacent terms diverges even though their ratio tends to $1$. There is no contradiction: relative separation is approximately $n/(n^2/2)=2/n$, which tends to zero.

### Theorem 5.2 (Density zero)

Let $N(X)$ denote the number of distinct values of $A(n)$ not exceeding a real threshold $X$. Then the value set $\{A(n):n\ge0\}$ has natural density zero:

$$
\lim_{X\to\infty}\frac{N(X)}{X}=0.
$$

**Proof sketch.** The closed form shows that $A(n)$ has quadratic order. More concretely, for $n\ge2$ one has $A(n)\ge n^2/4$. Hence $A(n)\le X$ implies $n\le2\sqrt X$, so at most $2\sqrt X+1$ indices can contribute values below $X$. Therefore

$$
0\le\frac{N(X)}X\le\frac{2\sqrt X+1}{X},
$$

and the upper bound tends to zero. The repeated initial value can only decrease the count. Determining the sharp floor formula and its exact correction is a natural refinement discussed below. $\square$

This statement concerns the value set of the recurrence in Definition 2.1. It does not identify that set with all sums of earlier values, nor does it analyze the incompatible greedy process.

## 6. Refutation of quarter-square growth

### Theorem 6.1 (Unbounded quarter-square discrepancy)

For every nonnegative real constant $C$, there exists a nonnegative integer $n$ such that

$$
A(n)>\frac{n^2}{4}+C.
$$

For nonnegative integer $C$, the explicit choice $n=4C+4$ suffices.

**Proof sketch.** The exact difference is

$$
A(n)-\frac{n^2}{4}
=
\frac{n^2}{4}-\frac n2+1.
$$

This quadratic expression tends to positive infinity. For integer $C$, substituting $n=4C+4$ makes the inequality immediate after expansion. Therefore the discrepancy cannot be bounded independently of $n$. $\square$

### Corollary 6.2 (Failure of bounded-error quarter-square approximation)

There is no constant $K$ for which

$$
\left|A(n)-\left\lfloor\frac{n^2}{4}\right\rfloor\right|\le K
$$

holds for every nonnegative integer $n$. Equivalently,

$$
A(n)\ne\left\lfloor\frac{n^2}{4}\right\rfloor+O(1).
$$

**Proof sketch.** If such a $K$ existed, then $A(n)\le n^2/4+K+1$ for all $n$, contradicting Theorem 6.1 with $C=K+1$. $\square$

### Proposition 6.3 (Millionth-index evaluation)

At index one million,

$$
A(1{,}000{,}000)=499{,}999{,}500{,}001,
$$

and

$$
\frac{A(1{,}000{,}000)}{(1{,}000{,}000)^2}=0.499999500001.
$$

**Proof sketch.** Substitute $n=1{,}000{,}000$ into Theorem 2.3. The decimal ratio follows by division by $10^{12}$. $\square$

The computation is exact and illustrates the asymptotic coefficient $1/2$. It should not be described as evidence for convergence to $1/4$.

## 7. Comparison with Fibonacci and Riordan growth

Let $F_0=0$, $F_1=1$, and $F_{k+2}=F_{k+1}+F_k$.

### Theorem 7.1 (Odd-index Fibonacci domination)

For every integer $n\ge6$,

$$
A(n)<F_{2n+1}.
$$

**Proof sketch.** The base case is direct:

$$
A(6)=16<233=F_{13}.
$$

For the induction step, assume $A(k)<F_{2k+1}$ with $k\ge6$. The defining recurrence gives $A(k+1)=A(k)+k$. The Fibonacci addition law gives

$$
F_{2k+3}=F_{2k+2}+F_{2k+1}.
$$

Standard induction on the Fibonacci recurrence yields $k\le F_{2k+2}$ for $k\ge6$. Hence

$$
A(k+1)=A(k)+k
<F_{2k+1}+F_{2k+2}
=F_{2k+3}.
$$

This is the desired inequality at $k+1$. $\square$

### Corollary 7.2 (Domination of an odd-Fibonacci row-sum model)

Suppose a combinatorial triangular array has $n$th row sum equal to $F_{2n+1}$. Then for every $n\ge6$, its $n$th row sum is strictly greater than $A(n)$.

**Proof sketch.** Replace the row sum by its assumed exact value $F_{2n+1}$ and apply Theorem 7.1. $\square$

This statement applies in particular to the standard Pascal–Riordan construction whose row sums realize the odd-index Fibonacci numbers. The comparison creates a clean bridge: shifted triangular accumulation is polynomial, while the array’s row sums inherit exponential Fibonacci growth.

The threshold $6$ is a certified uniform threshold, though the problem of determining the least possible threshold for this and broader quadratic families remains a useful refinement.

## 8. Algorithms

The exact identities eliminate the need for iterative sequence generation in most tasks.

### Algorithm 8.1 (Direct evaluation)

**Input:** a nonnegative integer $n$.  
**Output:** $A(n)$.

Compute

$$
1+\frac{n(n-1)}2.
$$

The division is exact because one of $n$ and $n-1$ is even. The algorithm uses $O(1)$ arithmetic operations and $O(1)$ auxiliary storage. With arbitrary-precision integers, bit complexity depends on multiplication of $O(\log n)$-bit operands.

### Algorithm 8.2 (Value-spectrum membership)

**Input:** an integer $m$.  
**Output:** whether $m=A(n)$ for some $n\ge0$, together with a positive index when one exists.

If $m<1$, return false. Compute $D=8m-7$ and $r=\lfloor\sqrt D\rfloor$. Return true exactly when $r^2=D$ and $r$ is odd; then an index is

$$
n=\frac{r+1}{2}.
$$

For $m=1$, both indices $0$ and $1$ are valid. The algorithm uses constant auxiliary space and one integer square root.

### Algorithm 8.3 (Consecutive-sum membership)

**Input:** an integer $m$.  
**Output:** whether $m=A(n)+A(n+1)$ for some $n\ge0$, together with the index.

If $m<2$, return false. Compute $r=\lfloor\sqrt{m-2}\rfloor$. Return true exactly when $r^2=m-2$; in that event the unique index is $n=r$.

## 9. Numerical protocol and diagnostic checks

Although the central claims are exact, numerical experiments provide useful diagnostics and reveal incorrect conjectures quickly. A robust experiment should compute $A(n)$ from the closed form rather than from floating-point recurrence, then report four quantities: $A(n)$, $A(n)/n^2$, the quarter-square discrepancy $A(n)-n^2/4$, and the neighboring ratio $A(n+1)/A(n)$.

At indices $n=10,100,1000$, the normalized values are respectively

$$
0.46,
\qquad
0.4951,
\qquad
0.499501.
$$

The trend toward $1/2$ is already clear. In contrast, the quarter-square discrepancy equals

$$
\frac{n^2}{4}-\frac n2+1,
$$

so it grows rather than stabilizes. A logarithmic plot of $A(n)$ against $n$ has slope approaching $2$, while a plot of $A(n)/n^2$ approaches a horizontal line at $1/2$. Both views distinguish quadratic behavior from Fibonacci growth.

An independent integrity check evaluates the defining identities on a finite range. For every sampled $n$, verify simultaneously that

$$
A(n+1)-A(n)=n,
$$

$$
A(n)+A(n+1)=n^2+2,
$$

and

$$
8A(n)-7=(2n-1)^2.
$$

These checks are redundant by design: disagreement reveals an indexing or implementation error. Integer arithmetic should be retained throughout evaluation; floating-point conversion is needed only for displayed ratios and plots. At $n=10^6$, all exact integers remain easy to compute, while the normalized value $0.499999500001$ visibly contradicts the proposed quarter-square limit.

## 10. Applications and interpretation

The first application is methodological. A displayed sequence, verbal rule, and asymptotic conjecture form three separate mathematical claims. They should be checked independently. Here a first-difference table immediately detects that the data encode a triangular recurrence rather than a greedy avoidance process.

The second application is computational. Direct formulas replace linear-time generation with constant-operation evaluation. Square criteria provide exact membership certificates. Such transformations are useful whenever recurrence-generated data must be indexed, compressed, or queried at large scales.

The third application is combinatorial. Since $A(n)=1+\binom n2$, the sequence counts edges of a complete graph on $n$ vertices plus one distinguished item. The consecutive-sum identity reflects the classical fact that two consecutive triangular numbers form a square. This supplies geometric intuition for the algebraic spectrum.

The fourth application is Diophantine. The equations

$$
8A(n)-7=(2n-1)^2
$$

and

$$
A(n)+A(n+1)-2=n^2
$$

place both values and consecutive sums on affine conics. Intersections, modular restrictions, and coincidence problems with other recurrences can therefore be approached through quadratic forms, congruences, and Pell-type equations.

Finally, the Fibonacci comparison illustrates the separation between polynomial and exponential combinatorial mechanisms. Even though $A(n)$ has unbounded increments, those increments are merely linear. Odd-index Fibonacci numbers acquire increments on the scale of their current values and rapidly dominate.

## 11. Discussion and limitations

The results also clarify why several initially plausible observations can coexist. Linear gaps might suggest rapid growth, yet summing those gaps produces a quadratic rather than exponential sequence. Sparse values might suggest an exotic avoidance mechanism, yet every strictly increasing quadratic integer sequence is sparse for the same elementary counting reason. Finally, repeated appearances of squares might look accidental in a short table, but here both square laws are algebraic consequences of consecutive triangular numbers. The closed form unifies all three phenomena.

There is a useful distinction between descriptive and generative patterns. The condition $8m-7$ being an odd square describes exactly which integers occur, while $A(n+1)=A(n)+n$ generates them in index order. Neither description alone should be mistaken for the original exclusion rule. Having both views is computationally valuable: generation is convenient for ordered enumeration, whereas the spectral criterion answers random-access membership queries without constructing smaller terms.

The adjective “anti-Fibonacci” is evocative but potentially misleading. The sequence studied here does not arise from the literal exclusion rule initially proposed, and it does not exhibit the claimed oscillatory ratios. Its structure is simpler: it is a shifted triangular sequence.

This correction changes the asymptotic constant from $1/4$ to $1/2$. More strongly, it shows that the quarter-square approximation fails by an unbounded quadratic discrepancy. At the same time, one qualitative expectation—density zero—does hold for the sequence’s value set, for the ordinary reason that a quadratic sequence contributes only $O(\sqrt X)$ values below $X$.

One must also distinguish three sets: the value set $\{A(n)\}$, the consecutive-sum set $\{A(n)+A(n+1)\}$, and any set of sums of arbitrary earlier terms. Theorems in this paper identify the first two exactly but make no classification claim about the third. Likewise, no result here classifies the unrelated literal greedy process.

## 12. Future work

Several exact problems follow naturally.

First, classify intersections between the value spectrum and the consecutive-sum spectrum. Combining the two square identities reduces the question to an affine conic and plausibly to finitely many Pell-type orbits.

Second, refine the exact counting formula into explicit discrepancy bounds in various normalizations, including uniform estimates for $N(X)-\sqrt{2X}$.

Third, consider generalized recurrences

$$
B(0)=b,
\qquad
B(n+1)=B(n)+an
$$

with integer parameters $a>0$ and $b$. Their closed forms remain quadratic, so value spectra, consecutive sums, disjointness thresholds, and exceptional Fibonacci coincidences become explicit quadratic equations.

Fourth, determine the optimal domination threshold for $A(n)<F_{2n+1}$ and then for arbitrary quadratics with nonnegative coefficients. A finite initial check combined with recurrence induction should produce effective parameter-dependent bounds.

Fifth, study modular distribution. The criterion that $8m-7$ be an odd square reduces the occurring residue classes modulo $q$ to local quadratic-residue questions. Exact frequencies should be accessible by counting square roots modulo prime powers and applying the Chinese remainder theorem.

## 13. Conclusion

The sequence $1,1,2,4,7,11,16,\ldots$ is governed by the recurrence $A(n+1)=A(n)+n$ and the exact formula

$$
A(n)=1+\frac{n(n-1)}2.
$$

Its true leading coefficient is $1/2$, its neighboring ratios tend to $1$, and no bounded-error quarter-square approximation exists. Its gaps equal $n$, its values have density zero, and at index one million it equals $499{,}999{,}500{,}001$. Most notably, consecutive terms satisfy

$$
A(n)+A(n+1)=n^2+2,
$$

while individual values satisfy

$$
8A(n)-7=(2n-1)^2.
$$

These identities expose an unexpectedly rigid square structure. From index $6$ onward, odd-index Fibonacci numbers dominate the quadratic sequence, sharply separating its polynomial growth from genuine Fibonacci growth. What began as an inconsistent avoidance story therefore resolves into a coherent theory of shifted triangular numbers, exact spectra, sparse counting, and quadratic arithmetic.
