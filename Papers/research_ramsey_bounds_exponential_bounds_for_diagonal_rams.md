# Exponential Normalization for Diagonal Ramsey Bounds

**Aristotle**  
**August 1, 2026**

## Abstract

Diagonal Ramsey numbers measure how large a two-colored complete graph must be before it necessarily contains a monochromatic clique of prescribed size. Improvements over the classical exponential base $4$ are naturally produced in several forms: a proportional saving $(4q)^k$ with $q<1$, an exponentially damped estimate $(4e^{-\delta})^k$, or a bound $k^d(4q)^k$ carrying a fixed polynomial loss. This paper develops a self-contained analytic interface among these formulations for an arbitrary nonnegative integer sequence $r(k)$. We prove that an eventual bound $(4-\varepsilon)^k$ with $0<\varepsilon<4$ is equivalent to an eventual proportional-saving bound $(4q)^k$ with $0<q<1$, with exact change of variables $\varepsilon=4(1-q)$. Exponential damping yields the explicit gap $\varepsilon=4(1-e^{-\delta})$. Proportional bounds are monotone under enlarging the saving factor. Finally, every fixed polynomial loss can be absorbed into a slightly larger exponential base: from $r(k)\le k^d(4q)^k$ eventually, one obtains a pure sub-four estimate, for example with $q'=(q+1)/2$ and $\varepsilon=2(1-q)$. The results isolate the final quantitative step needed whenever a combinatorial argument supplies a uniform exponential saving.

## 1. Introduction

For positive integers $s$ and $t$, the Ramsey number $R(s,t)$ is the least integer $N$ such that every red-blue coloring of the edges of the complete graph on $N$ vertices contains either a red complete subgraph on $s$ vertices or a blue complete subgraph on $t$ vertices. The diagonal quantity $R(k,k)$ is the symmetric case. It records a fundamental inevitability: beyond a sufficiently large scale, complete disorder in a binary relation cannot avoid a homogeneous configuration of size $k$.

The quantitative growth of $R(k,k)$ is a central problem in extremal combinatorics. A classical upper-bound scale is exponential with base $4$, up to lower-order factors. Consequently, an estimate of the form

$$
R(k,k)\le(4-\varepsilon)^k
$$

for one fixed $\varepsilon>0$ and all sufficiently large $k$ represents a genuine exponential improvement. Indeed, relative to $4^k$, the ratio is

$$
\left(1-\frac{\varepsilon}{4}\right)^k,
$$

which tends to zero exponentially.

The combinatorial machinery that produces such a saving need not state its conclusion in this canonical form. It may naturally output

$$
R(k,k)\le(4q)^k,
$$

where $q$ is a fixed number below $1$. Analytic estimates may instead produce $q=e^{-\delta}$. Intermediate counting arguments often carry a polynomial overhead and yield

$$
R(k,k)\le k^d(4q)^k.
$$

The purpose of this paper is to establish, exactly and without hidden asymptotic assumptions, how these formulations are related. Since the conversion depends only on inequalities between real powers, we work with an arbitrary sequence $r:\mathbb N\to\mathbb N$. This abstraction makes clear that the argument is an analytic endpoint, independent of the particular combinatorial construction that supplies the initial estimate.

The main conclusions are as follows.

1. An additive gap below $4$ and a proportional saving from $4$ are equivalent, with the exact substitutions

   $$
   \varepsilon=4(1-q),\qquad q=1-\frac{\varepsilon}{4}.
   $$

2. A damping factor $e^{-\delta}$ with $\delta>0$ gives the explicit gap

   $$
   \varepsilon=4(1-e^{-\delta}).
   $$

3. A valid proportional estimate remains valid after $q$ is replaced by any larger factor $q'$, provided positivity is retained.

4. A fixed polynomial factor $k^d$ does not destroy a strict exponential saving. Choosing

   $$
   q'=\frac{q+1}{2}
   $$

   absorbs the polynomial eventually and yields the explicit gap $\varepsilon=2(1-q)$.

The fourth statement is the main stability result. It formalizes the familiar principle that exponentials dominate polynomials, while tracking enough quantitative information to retain a base strictly below $4$.

## 2. Preliminaries and definitions

Throughout, $\mathbb N=\{0,1,2,\ldots\}$, and $r:\mathbb N\to\mathbb N$ is a nonnegative integer sequence. All inequalities involving $r(k)$ and real expressions use the natural inclusion of nonnegative integers into the real numbers.

An assertion $P(k)$ holds **eventually** if there exists $k_0\in\mathbb N$ such that $P(k)$ holds for every $k\ge k_0$. The threshold may depend on the fixed parameters of the assertion, such as $q$ and $d$, but not on $k$.

### Definition 2.1. Eventual sub-four upper bound

The sequence $r$ has an **eventual sub-four upper bound** if there exist $\varepsilon\in\mathbb R$ and $k_0\in\mathbb N$ such that

$$
0<\varepsilon<4
$$

and

$$
r(k)\le(4-\varepsilon)^k
$$

for every $k\ge k_0$.

The restriction $\varepsilon<4$ keeps the base $4-\varepsilon$ positive. This is the natural regime for comparing exponential growth rates of nonnegative sequences.

### Definition 2.2. Proportional saving

The sequence $r$ has a **proportional saving from base four** if there exist $q\in\mathbb R$ and $k_0\in\mathbb N$ such that

$$
0<q<1
$$

and

$$
r(k)\le(4q)^k
$$

for every $k\ge k_0$.

The value $q$ is dimensionless. It records what proportion of the reference base remains after the improvement.

### Remark 2.3. Uniformity

The fixed nature of $q$ and $\varepsilon$ is essential. A family of estimates involving $q_k<1$ for each $k$ need not imply a fixed sub-four base if $q_k\to1$. For example, $q_k=1-1/k$ gives

$$
(4q_k)^k=4^k\left(1-\frac1k\right)^k,
$$

which improves $4^k$ only by an asymptotically constant factor rather than by a new exponential base. The theory below begins after a uniform saving has been established.

## 3. Exact normalization of the base

The elementary identity underlying the conversion is

$$
4q=4-4(1-q).
$$

Its role is structural: it identifies the same positive base in two coordinate systems.

### Lemma 3.1. Change of variables

For every real number $q$,

$$
4q=4-4(1-q).
$$

**Proof sketch.** Expand the right-hand side:

$$
4-4(1-q)=4-4+4q=4q.
$$

No inequalities are required. $\square$

### Theorem 3.2. From proportional saving to an additive gap

Let $r:\mathbb N\to\mathbb N$. Suppose there exist $q$ and $k_0$ with $0<q<1$ such that

$$
r(k)\le(4q)^k
$$

for every $k\ge k_0$. Then $r$ has an eventual sub-four upper bound. More precisely, one may take

$$
\varepsilon=4(1-q).
$$

**Proof sketch.** Since $q<1$, one has $1-q>0$, hence $\varepsilon>0$. Since $q>0$, one has $1-q<1$, hence $\varepsilon<4$. Lemma 3.1 gives $4q=4-\varepsilon$. Therefore the assumed inequality is exactly

$$
r(k)\le(4-\varepsilon)^k
$$

with the same threshold $k_0$. $\square$

### Theorem 3.3. From an additive gap to proportional saving

Let $r:\mathbb N\to\mathbb N$. Suppose there exist $\varepsilon$ and $k_0$ with $0<\varepsilon<4$ such that

$$
r(k)\le(4-\varepsilon)^k
$$

for every $k\ge k_0$. Then $r$ has a proportional saving. More precisely, one may take

$$
q=\frac{4-\varepsilon}{4}=1-\frac{\varepsilon}{4}.
$$

**Proof sketch.** The inequality $\varepsilon<4$ implies $q>0$, while $\varepsilon>0$ implies $q<1$. By construction, $4q=4-\varepsilon$, so the given estimate is exactly $r(k)\le(4q)^k$ for the same values of $k$. $\square$

### Corollary 3.4. Equivalence of formulations

A sequence $r:\mathbb N\to\mathbb N$ has an eventual sub-four upper bound if and only if it has a proportional saving from base four.

**Proof sketch.** Apply Theorem 3.2 in one direction and Theorem 3.3 in the other. $\square$

### Discussion

The correspondence is bijective between the parameter intervals $q\in(0,1)$ and $\varepsilon\in(0,4)$. It is order-reversing: a smaller $q$ represents a stronger saving and corresponds to a larger $\varepsilon$. The conversion neither changes the threshold nor weakens the numerical bound. Thus the choice between the two forms can be made solely according to the needs of the argument.

The proportional variable is often more natural during a multiplicative proof, whereas the additive-gap variable makes the phrase “strictly below four” explicit. Corollary 3.4 provides a lossless interface between them.

## 4. Exponential damping

Analytic and probabilistic arguments frequently generate factors of the form $e^{-\delta}$. Positivity of $\delta$ is exactly the condition required for a strict saving.

### Theorem 4.1. Exponential damping gives an explicit sub-four gap

Let $r:\mathbb N\to\mathbb N$, let $\delta>0$, and suppose there exists $k_0\in\mathbb N$ such that

$$
r(k)\le\left(4e^{-\delta}\right)^k
$$

for every $k\ge k_0$. Then $r$ has an eventual sub-four upper bound with

$$
\varepsilon=4\left(1-e^{-\delta}\right).
$$

In particular,

$$
4-\varepsilon=4e^{-\delta}.
$$

**Proof sketch.** Since $\delta>0$, the exponent $-\delta$ is negative, and monotonicity of the exponential function gives $e^{-\delta}<1$. Positivity of the exponential gives $e^{-\delta}>0$. Thus $q=e^{-\delta}$ lies in $(0,1)$. Theorem 3.2 applies and gives $\varepsilon=4(1-q)=4(1-e^{-\delta})$. The identity of bases follows immediately. $\square$

### Remark 4.2. Small-damping behavior

As $\delta\to0^+$, the Taylor expansion $e^{-\delta}=1-\delta+O(\delta^2)$ gives

$$
\varepsilon=4\delta+O(\delta^2).
$$

This approximation is useful for intuition, but Theorem 4.1 uses the exact expression and requires no smallness assumption beyond $\delta>0$.

### Example 4.3

If $\delta=0.05$, then

$$
q=e^{-0.05}\approx0.951229,
$$

and

$$
\varepsilon=4(1-e^{-0.05})\approx0.195082.
$$

Thus the base $4e^{-0.05}$ is approximately $3.804918$, exactly equal to $4-\varepsilon$.

## 5. Monotonicity and conservative rounding

An estimate with a smaller positive base implies the corresponding estimate with a larger base. This permits exact constants to be rounded in a conservative direction.

### Theorem 5.1. Monotonicity of proportional bounds

Let $r:\mathbb N\to\mathbb N$, and let $q,q'\in\mathbb R$ satisfy

$$
0<q\le q'.
$$

Suppose there exists $k_0$ such that

$$
r(k)\le(4q)^k
$$

for every $k\ge k_0$. Then

$$
r(k)\le(4q')^k
$$

for every $k\ge k_0$.

**Proof sketch.** Positivity and $q\le q'$ imply $0<4q\le4q'$. For every natural number $k$, the map $x\mapsto x^k$ is monotone on the nonnegative reals, so $(4q)^k\le(4q')^k$. Combining this with the assumed bound proves the result without changing the threshold. $\square$

### Corollary 5.2. Safe simplification of constants

If a proportional-saving estimate holds for $q\in(0,1)$ and $q'$ is chosen with $q\le q'<1$, then the estimate with $q'$ remains a proportional saving and therefore yields the additive gap $4(1-q')>0$.

**Proof sketch.** Theorem 5.1 supplies the new bound, and Theorem 3.2 normalizes it. $\square$

The condition $q'<1$ is not needed merely for the monotone inequality, but it is needed to retain a strict improvement over base $4$.

## 6. Absorbing fixed polynomial losses

We now consider estimates with a polynomial prefactor. The key analytic fact is that any exponential growth with base greater than $1$ eventually dominates every fixed power.

### Lemma 6.1. Exponential domination of a fixed power

Let $d\in\mathbb N$ and $a>1$. Then there exists $N\in\mathbb N$ such that

$$
k^d\le a^k
$$

for every $k\ge N$.

**Proof sketch.** Taking logarithms for $k\ge1$, the desired inequality is equivalent to

$$
d\log k\le k\log a.
$$

Since $\log a>0$ and $\log k/k\to0$, there exists $N$ such that

$$
\frac{d\log k}{k}\le\log a
$$

for every $k\ge N$. Exponentiating gives the claim. Equivalently, one may use the standard limit $k^d/a^k\to0$. $\square$

### Theorem 6.2. Polynomial-loss absorption

Let $r:\mathbb N\to\mathbb N$, let $d\in\mathbb N$, and let $q$ satisfy $0<q<1$. Suppose there exists $k_0\in\mathbb N$ such that

$$
r(k)\le k^d(4q)^k
$$

for every $k\ge k_0$. Then $r$ has an eventual sub-four upper bound.

More explicitly, define

$$
q'=\frac{q+1}{2}.
$$

Then $q<q'<1$, and there exists $K\ge k_0$ such that

$$
r(k)\le(4q')^k=(4-\varepsilon)^k
$$

for every $k\ge K$, where

$$
\varepsilon=4(1-q')=2(1-q)>0.
$$

**Proof sketch.** Because $0<q<1$, the midpoint $q'=(q+1)/2$ satisfies $q<q'<1$. Set $a=q'/q>1$. By Lemma 6.1, there exists $N$ such that $k^d\le a^k$ for all $k\ge N$. Therefore, whenever $k\ge\max\{N,k_0\}$,

$$
\begin{aligned}
r(k)
&\le k^d(4q)^k\\
&\le\left(\frac{q'}q\right)^k(4q)^k\\
&=(4q')^k.
\end{aligned}
$$

Since $q'<1$, Theorem 3.2 converts this to a sub-four bound with $\varepsilon=4(1-q')$. Substituting the midpoint value gives $\varepsilon=2(1-q)$. $\square$

### Remark 6.3. The midpoint is convenient, not optimal

Any fixed $q'$ with $q<q'<1$ can absorb the polynomial. The resulting gap is $4(1-q')$. Choosing $q'$ close to $q$ preserves more of the original saving but generally pushes the absorption threshold higher, because the ratio $q'/q$ approaches $1$. Choosing $q'$ closer to $1$ weakens the final base but can lower the threshold. The midpoint is a canonical compromise and provides the simple explicit gap $2(1-q)$.

### Remark 6.4. Threshold dependence

The theorem asserts the existence of an absorption threshold, not a universal threshold independent of $d$ and $q$. Such uniformity is impossible. As $q'\downarrow q$, the exponential ratio $q'/q$ approaches $1$, and increasingly large values of $k$ may be needed before it dominates $k^d$. Likewise, increasing $d$ enlarges the polynomial loss.

### Example 6.5

Let $q=0.9$ and $d=3$. The midpoint choice is $q'=0.95$, so the original and target bases are $3.6$ and $3.8$. Polynomial absorption reduces to finding $N$ such that

$$
k^3\le\left(\frac{0.95}{0.9}\right)^k
=\left(\frac{19}{18}\right)^k
$$

for every $k\ge N$. Once this inequality holds, one has

$$
k^3(3.6)^k\le(3.8)^k.
$$

The final additive gap is $\varepsilon=4-3.8=0.2$, agreeing with $2(1-q)$.

## 7. An algorithmic normalization pipeline

The theorems yield a simple procedure for converting quantitative estimates into a standard sub-four statement.

### Algorithm 7.1. Direct proportional normalization

**Input:** A factor $q$ satisfying $0<q<1$ and a threshold $k_0$ for which $r(k)\le(4q)^k$ whenever $k\ge k_0$.

**Output:** The additive gap

$$
\varepsilon=4(1-q)
$$

and the unchanged threshold $k_0$.

The arithmetic cost is constant. The output bound is exactly equal to the input bound, not merely asymptotically comparable.

### Algorithm 7.2. Exponential-damping normalization

**Input:** A number $\delta>0$ and a threshold $k_0$ for which $r(k)\le(4e^{-\delta})^k$ whenever $k\ge k_0$.

**Output:**

$$
q=e^{-\delta},\qquad
\varepsilon=4(1-e^{-\delta}),
$$

with the same threshold. Numerical evaluation of the exponential has the complexity of the chosen floating-point or arbitrary-precision library; mathematically, the transformation is exact.

### Algorithm 7.3. Polynomial-loss absorption by threshold search

**Input:** A fixed degree $d$, factors $0<q<q'<1$, and an initial validity threshold $k_0$ for

$$
r(k)\le k^d(4q)^k.
$$

**Goal:** Find an absorption threshold $N$ such that

$$
k^d\le(q'/q)^k
$$

for all $k\ge N$.

A robust numerical search compares logarithms:

$$
d\log k\le k\log(q'/q).
$$

To certify persistence beyond a candidate threshold, one may use monotonicity of

$$
f(x)=x\log(q'/q)-d\log x.
$$

Its derivative is

$$
f'(x)=\log(q'/q)-\frac d x,
$$

so $f$ is increasing once

$$
x\ge\frac d{\log(q'/q)}.
$$

It therefore suffices to search at or beyond this monotonicity threshold until $f(k)\ge0$. Then the inequality holds for every larger real $x$, hence for every larger integer $k$. The final threshold is $K=\max\{k_0,N\}$, and the gap is $\varepsilon=4(1-q')$.

This logarithmic method avoids overflow from computing large powers. A linear search takes $O(N)$ evaluations in the simplest implementation; exponential bracketing followed by binary search reduces the search phase to $O(\log N)$ evaluations once monotonicity is available.

## 8. Applications and interpretation

### 8.1. Diagonal Ramsey numbers

Set $r(k)=R(k,k)$. If a combinatorial argument establishes one fixed $q\in(0,1)$ and one threshold $k_0$ such that

$$
R(k,k)\le(4q)^k
$$

for every $k\ge k_0$, Corollary 3.4 immediately gives

$$
R(k,k)\le(4-\varepsilon)^k,
\qquad
\varepsilon=4(1-q)>0.
$$

If the argument instead produces a fixed polynomial prefactor, Theorem 6.2 removes it at the expense of weakening the saving by a controlled amount. Thus the analytic endpoint does not require the combinatorial estimate to arrive in a pristine pure-exponential form.

### 8.2. Separation of combinatorial and analytic tasks

The results identify a clean division of labor. The combinatorial task is to obtain a **uniform** strict saving. The analytic task is to normalize that saving. The latter can tolerate conservative rounding and fixed polynomial losses. It cannot create uniformity when none is present.

This separation improves modularity. Different combinatorial methods can target whichever quantitative form is most natural, knowing that a common final statement follows from the interface developed here.

### 8.3. Broader exponential-rate arguments

Nothing in the proofs uses a special property of the number $4$ except positivity. With a reference base $B>0$, the same change of variables is

$$
Bq=B-B(1-q),
$$

and the additive gap is $B(1-q)$. Likewise, if $0<q<q'<1$, then a fixed polynomial factor can be absorbed from $(Bq)^k$ into $(Bq')^k$. The framework therefore applies to counting problems, coding bounds, probabilistic estimates, and statistical-mechanical partition functions whenever a dominant exponential rate is decorated by subexponential terms.

## 9. Limitations

The analysis deliberately addresses the normalization step rather than the production of the initial saving. It assumes a bound valid for all sufficiently large $k$. It does not determine exact Ramsey numbers, optimize the combinatorial constant $q$, or supply a threshold when the initial theorem gives only existential asymptotics.

The polynomial-loss theorem treats a fixed degree $d$. If the degree grows with $k$, the prefactor may cease to be subexponential. For example, $k^k=e^{k\log k}$ cannot be absorbed into $(q'/q)^k$ for fixed $q'/q$. The decisive property is not “polynomial” as a label but subexponential growth relative to $k$.

Finally, an eventual result does not automatically cover small $k$. Extending an inequality to all $k\ge2$ requires separate finite information and may force a smaller gap.

## 10. Future work

The preceding results also suggest a quantitative optimization problem. For fixed $q$ and $d$, every choice $q'\in(q,1)$ trades final strength against onset time. The gap $4(1-q')$ becomes larger as $q'$ approaches $q$, but the ratio $q'/q$ then approaches $1$ and may require a very large absorption threshold. Given a desired range of $k$, one could optimize $q'$ to minimize the pure exponential envelope on that range rather than selecting the midpoint automatically. Such finite-scale optimization complements the asymptotic theorem without changing its conclusion.

It would also be useful to derive explicit analytic upper bounds for the first valid absorption threshold in terms of $d$, $q$, and $q'$. The logarithmic inequality $d\log k\le k\log(q'/q)$ can be inverted using standard estimates or the Lambert $W$ function. Explicit thresholds would make the interface directly usable in quantitative applications where “sufficiently large” must be replaced by a concrete integer.

A first objective is to pair the analytic interface with a complete combinatorial estimate for diagonal Ramsey numbers that supplies explicit values of $q$ and $k_0$. A rational value of $q$ would be particularly useful for transparent numerical comparison.

A second objective is threshold elimination: once an eventual sub-four estimate is known, one may ask whether an explicit gap can be chosen so that the inequality holds for every $k\ge2$. This requires combining asymptotic reasoning with finite Ramsey data.

A third direction is asymmetric Ramsey theory. Bounds for $R(s,t)$ depend on the ratio $s/(s+t)$ and on entropy-like reference bases. One may seek uniform equivalence between proportional and additive savings when this ratio ranges over a compact subinterval of $(0,1)$.

The most direct analytic generalization replaces $k^d$ by a nonnegative subexponential sequence $L(k)$. Suppose that for every $\eta>0$ there is a threshold beyond which

$$
L(k)\le e^{\eta k}.
$$

Given $0<q<1$, one expects that an eventual estimate

$$
r(k)\le L(k)(4q)^k
$$

still implies a sub-four upper bound. Choose $q'$ with $q<q'<1$ and then choose $\eta<\log(q'/q)$. Eventually $L(k)\le e^{\eta k}<(q'/q)^k$, which reduces the claim to the same absorption argument as before. This would characterize the true scope of the stability principle: every subexponential loss is harmless to a fixed strict exponential saving.

## 11. Conclusion

A sub-four Ramsey estimate can be expressed through an additive gap, a proportional saving, or exponential damping. These are not merely asymptotically related: their bases agree exactly under explicit changes of variables. Moreover, proportional estimates are monotone under conservative weakening, and fixed polynomial prefactors can be absorbed into a slightly larger base that remains strictly below $4$.

The central formulas are

$$
\varepsilon=4(1-q),
$$

$$
\varepsilon=4(1-e^{-\delta}),
$$

and, after absorbing a fixed polynomial using $q'=(q+1)/2$,

$$
\varepsilon=2(1-q).
$$

Together they provide a robust endpoint for exponential improvements in diagonal Ramsey bounds. Once a combinatorial argument produces one uniform factor below $1$, changes of notation, fixed polynomial overhead, and conservative simplification cannot erase the strict exponential gain.