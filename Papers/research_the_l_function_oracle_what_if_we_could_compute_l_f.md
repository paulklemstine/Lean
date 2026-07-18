# Exact Evaluation Oracles and Global Arithmetic Claims

**Aristotle**  
**18 July 2026**

## Abstract

We analyze the mathematical power of an ideal exact evaluator $E$ that returns a requested value of a complex function in constant oracle time. Motivated by proposals that instantaneous evaluation of $L$-functions should settle zero conjectures, analytic-rank questions, functorial identities, distribution laws, and integer factorization, we separate pointwise evaluation from the additional information required for global conclusions. The central negative result is a finite-observation interpolation theorem: for any function $f:\mathbb C\to\mathbb C$, any finite sample $S$, any fresh point $z\notin S$, and any prescribed value $T$, a polynomial perturbation produces a function agreeing with $f$ on $S$ and taking value $T$ at $z$. Hence a finite exact transcript alone cannot exclude an unseen zero or determine unrestricted global behavior. We then give positive transfer principles. Problems represented as output fibers admit one-query reductions; these reductions compose with many-one preprocessing; and a class reducing to one oracle-decidable hard target inherits one-query oracle decision procedures. For vanishing orders, we prove uniqueness of the first nonzero jet coefficient and show that a finite nonvanishing bound makes the order discoverable by bounded search. For factorization, we identify an explicit divisibility certificate as the condition that turns an oracle-derived decoder into a valid factor-search procedure. The resulting framework replaces informal claims of omnipotence by precise hypotheses: global certificates, effective bounds, restricted-family rigidity, and certified arithmetic decoders.

## 1. Introduction

An $L$-function packages arithmetic information into a complex analytic object. The zeros of the Riemann zeta function are linked to the distribution of primes; the central behavior of an elliptic-curve $L$-function is conjecturally linked to the rank of the curve; Euler factors encode local arithmetic data; and equalities of automorphic $L$-functions express instances of functorial transfer. This concentration of information invites an oracle thought experiment: suppose any value $L(s)$ could be returned exactly in $O(1)$ oracle time. What would follow?

Several attractive but logically distinct conclusions are often conflated. Point evaluation at a specified argument can decide whether that argument is a zero. The Riemann Hypothesis, however, classifies every nontrivial zero in an unbounded region. Exact access to Taylor coefficients can identify the first nonzero coefficient after it is encountered, but an algorithm requires a stopping guarantee. Exact local factors can contribute to a factoring algorithm, but only if a proved decoder converts them into a proper divisor. Equality of finitely many sampled values may suggest equality of two structured functions, but the inference requires a converse or rigidity theorem. Finally, an oracle can collapse classes relative to itself without proving an unconditional separation such as $P\ne NP$.

This paper develops a minimal framework for stating these distinctions precisely. The theory has two sides. The negative side is information-theoretic: finite values of an unrestricted complex function leave arbitrary freedom at every unsampled point. The positive side is reduction-theoretic and certificate-based: once a decision predicate, nonvanishing bound, or arithmetic decoder has been supplied, oracle evaluation can be composed with it in a mathematically transparent way.

The conclusions are deliberately conditional and exact. We do not claim that standard $L$-functions form an unrestricted family; they certainly do not. Instead, the interpolation obstruction shows that any valid local-to-global inference must use the structure distinguishing $L$-functions from arbitrary functions. It thereby locates the substantive work in prospective oracle arguments.

## 2. Evaluation oracles and decision problems

Let $Q$ be a query space, $A$ an answer space, and

$$
E:Q\to A
$$

an exact evaluator. The notation abstracts away from a particular representation of $L$-functions and complex arguments. An element of $Q$ may contain a description of a function together with an evaluation point; $A$ may be a field of exact symbolic values. Complexity claims concerning such an oracle depend on the representation and cost model, but the extensional reduction principles below do not.

Let $X$ be an input space and $D\subseteq X$ a decision problem.

**Definition 2.1 (One-query reducibility).** The problem $D$ is *one-query reducible* to $E$ if there exist a query map $q:X\to Q$ and an acceptance predicate $R:A\to\{\mathrm{true},\mathrm{false}\}$ such that for every $x\in X$,

$$
x\in D\quad\Longleftrightarrow\quad R(E(q(x)))=\mathrm{true}.
$$

The definition separates three ingredients: encoding the input as a query, evaluating the query, and interpreting the output. It does not silently assign a complexity bound to the first or third ingredient.

**Theorem 2.2 (Fiber reduction).** For every acceptance predicate $R$ on $A$, the selected output fiber

$$
D_R=\{q\in Q:R(E(q))=\mathrm{true}\}
$$

is one-query reducible to $E$.

**Proof sketch.** Use the identity map as the query map and $R$ as the acceptance predicate. Then membership in $D_R$ is, by definition, equivalent to acceptance of $E(q)$. $\square$

This elementary observation is important because it distinguishes a problem literally defined by an evaluator’s output from a problem merely believed to be encoded in that output.

We next recall the extensional notion of many-one preprocessing. Given problems $D\subseteq X$ and $T\subseteq Y$, a map $e:X\to Y$ is a many-one reduction when

$$
x\in D\quad\Longleftrightarrow\quad e(x)\in T
$$

for every $x\in X$.

**Theorem 2.3 (Composition with many-one preprocessing).** Suppose $D\subseteq X$ many-one reduces to $T\subseteq Y$, and $T$ is one-query reducible to $E$. Then $D$ is one-query reducible to $E$.

**Proof sketch.** Let $e:X\to Y$ be the many-one encoding. Let $q:Y\to Q$ and $R$ witness the one-query reduction of $T$. Define the query for $x$ to be $q(e(x))$. Then

$$
x\in D\Longleftrightarrow e(x)\in T
\Longleftrightarrow R(E(q(e(x))))=\mathrm{true}.
$$

Thus $q\circ e$ and $R$ provide the desired reduction. $\square$

**Corollary 2.4 (Oracle-class collapse through a hard target).** Let $\mathcal C$ be a class of decision problems on $X$, and let $T\subseteq X$ be a target to which every $D\in\mathcal C$ many-one reduces. If $T$ is one-query reducible to $E$, then every $D\in\mathcal C$ is one-query reducible to $E$.

**Proof sketch.** Apply Theorem 2.3 separately to each $D\in\mathcal C$. $\square$

This corollary is the precise abstract content of an oracle-relative collapse. It does not imply an unconditional equality or inequality between ordinary complexity classes. To derive an ordinary polynomial-time algorithm one must additionally show that query construction and output interpretation take polynomial time, that the query has polynomial representation length, and that the oracle is available in the chosen computational model. Nor does the presence of a strong oracle contradict a time-hierarchy theorem: relativized access changes the computational model.

## 3. The finite-observation interpolation obstruction

The principal obstacle to turning evaluation into global knowledge is already visible for arbitrary complex functions.

Let $S\subset\mathbb C$ be finite. Define its vanishing perturbation by

$$
P_S(w)=\prod_{a\in S}(w-a).
$$

For the empty set, the product is $1$. For nonempty $S$, it is the monic polynomial whose simple roots are exactly the elements of $S$.

**Lemma 3.1 (Vanishing on the sample).** If $w\in S$, then $P_S(w)=0$.

**Proof sketch.** The product contains the factor $w-w=0$. $\square$

**Lemma 3.2 (Nonvanishing off the sample).** If $z\notin S$, then $P_S(z)\ne0$.

**Proof sketch.** For every $a\in S$, the factor $z-a$ is nonzero. A finite product of nonzero complex numbers is nonzero. $\square$

These two facts yield the central theorem.

**Theorem 3.3 (Finite-observation interpolation obstruction).** Let $f:\mathbb C\to\mathbb C$, let $S\subset\mathbb C$ be finite, let $z\notin S$, and let $T\in\mathbb C$. There exists a function $g:\mathbb C\to\mathbb C$ such that

$$
g(w)=f(w)\quad\text{for every }w\in S,
$$

and

$$
g(z)=T.
$$

**Proof sketch.** By Lemma 3.2, $P_S(z)\ne0$. Set

$$
\lambda=\frac{T-f(z)}{P_S(z)}
$$

and define

$$
g(w)=f(w)+\lambda P_S(w).
$$

For $w\in S$, Lemma 3.1 gives $P_S(w)=0$, hence $g(w)=f(w)$. At $z$,

$$
g(z)=f(z)+\frac{T-f(z)}{P_S(z)}P_S(z)=T.
$$

$\square$

**Corollary 3.4 (A finite transcript cannot exclude a fresh zero).** Under the hypotheses of Theorem 3.3, there exists $g$ agreeing with $f$ throughout $S$ and satisfying $g(z)=0$.

**Proof sketch.** Take $T=0$ in Theorem 3.3. $\square$

The theorem concerns unrestricted functions, although its perturbation is polynomial and therefore entire whenever $f$ is entire. It should not be misread as asserting that the perturbation preserves functional equations, Euler products, growth conditions, prescribed Dirichlet coefficients, or membership in a standard $L$-function family. Its role is diagnostic: any successful finite-query theorem for a restricted arithmetic family must invoke restrictions that rule out these perturbations.

### 3.1. Consequences for zero classification

A point evaluator can decide the predicate $f(z)=0$ for a specified $z$ if equality in the answer space is decidable. It cannot, from finitely many values alone, prove that no unqueried point is a zero within an unrestricted domain. Global zero statements require a compactness argument, an analytic continuation principle combined with richer data, a contour certificate, or an effective zero-counting theorem.

For the Riemann zeta function, the Riemann Hypothesis states that every nontrivial zero $\rho$ satisfies

$$
\operatorname{Re}(\rho)=\frac12.
$$

Directly evaluating finitely many candidate points cannot quantify over all $\rho$. A certified argument-principle computation could count zeros in a bounded rectangle, but it additionally needs control of the function along an entire contour, certified approximation error, and a proof that the contour does not pass through a zero. Covering unbounded height then requires a further theorem or an unending sequence of certificates. Exact evaluation may assist this program, but does not itself supply its global steps.

### 3.2. Consequences for equality and functoriality

Suppose two functions agree at every point in a finite set. Their difference vanishes on that set, but this does not imply that the difference vanishes identically. The identity theorem for holomorphic functions requires agreement on a set with an accumulation point in the domain, not merely on a finite sample. Therefore a proposed proof of functoriality by comparing finitely many values needs a quantitative converse theorem: within a bounded arithmetic family, agreement of sufficiently many local factors or coefficients must force equality of the global objects. The force comes from family rigidity, not from evaluation alone.

### 3.3. Consequences for distribution laws

Distribution statements such as Sato–Tate concern limiting frequencies. If normalized local quantities $x_p$ are attached to primes, a typical conclusion has the form

$$
\lim_{X\to\infty}
\frac{\#\{p\le X:x_p\in I\}}
{\#\{p\le X\}}
=\mu(I)
$$

for suitable intervals $I$ and a probability measure $\mu$. Any finite prefix of $(x_p)$ is compatible with many different tails and therefore many limiting behaviors. Exact coefficient access becomes decisive only when paired with effective discrepancy bounds or tail estimates that control the unseen terms.

## 4. Orders of vanishing and bounded jets

Let $c:\mathbb N\to\mathbb C$ be a sequence, interpreted as a derivative or Taylor jet at a distinguished point. For an analytic function $F$ near $s_0$, one may take

$$
c_k=\frac{F^{(k)}(s_0)}{k!}.
$$

**Definition 4.1 (First nonzero jet index).** A natural number $k$ is a first nonzero index of $c$ when

$$
c_k\ne0
$$

and

$$
c_j=0\quad\text{for all }j<k.
$$

When $F$ is not identically zero near $s_0$, this index is the finite order of vanishing of $F$ at $s_0$.

**Theorem 4.2 (Uniqueness of the first nonzero index).** A jet has at most one first nonzero index.

**Proof sketch.** Suppose $k$ and $m$ are both first nonzero. If $k<m$, the condition for $m$ gives $c_k=0$, contradicting $c_k\ne0$. If $m<k$, the symmetric contradiction follows. Hence $k=m$. $\square$

**Theorem 4.3 (Finite-jet existence under bounded nonvanishing).** Let $B\in\mathbb N$. If

$$
\exists k\le B\quad c_k\ne0,
$$

then there exists a unique $k\le B$ that is the first nonzero index of $c$.

**Proof sketch.** Consider the finite set

$$
N_B=\{k\in\{0,1,\ldots,B\}:c_k\ne0\}.
$$

The hypothesis makes $N_B$ nonempty. By well-ordering, it has a least element $k$. This coefficient is nonzero, and minimality forces every earlier coefficient to vanish. Uniqueness follows from Theorem 4.2. $\square$

The theorem gives a correct bounded-search algorithm: inspect $c_0,c_1,\ldots,c_B$ and return the first nonzero coefficient. It performs at most $B+1$ oracle queries. The essential arithmetic hypothesis is not exactness but the existence of a known $B$ with guaranteed nonvanishing. In the elliptic-curve setting, using central vanishing order to infer algebraic rank also requires the independent bridge asserted by the Birch–Swinnerton-Dyer conjecture. Evaluation does not prove that bridge.

If all coefficients vanish, an analytic function is locally zero and hence, on a connected domain, identically zero. But a sequential evaluator cannot certify that every coefficient vanishes after inspecting only finitely many of them unless an effective structural theorem supplies a bound. Thus finite rank and infinite vanishing must be treated separately.

## 5. Certified factor extraction

A factor-search procedure is an algorithmic object with an arithmetic correctness condition.

**Definition 5.1 (Factor-search specification).** A function $F:\mathbb N\to\mathbb N$ is a valid factor-search procedure if, for every composite integer $n\ge2$,

$$
F(n)\mid n,\qquad 1<F(n),\qquad F(n)<n.
$$

No condition is imposed here on prime inputs. Complexity bounds are also separate from this extensional specification.

Suppose an evaluator $E:Q\to A$ is accompanied by a query constructor $q:\mathbb N\to Q$ and a decoder $d:\mathbb N\times A\to\mathbb N$. Define

$$
F(n)=d(n,E(q(n))).
$$

**Theorem 5.2 (Certified oracle decoder).** Assume that for every composite $n\ge2$, the value $d(n,E(q(n)))$ divides $n$, is greater than $1$, and is less than $n$. Then $F$ is a valid factor-search procedure.

**Proof sketch.** Substitute the definition of $F(n)$ into the three assumed certificate conditions. They are exactly the requirements of Definition 5.1. $\square$

The theorem deliberately exposes the proof obligation often hidden in an oracle proposal. To obtain a polynomial-time factoring result, one must also establish that $q(n)$ has polynomial length in $\log n$, that it can be constructed in polynomial time, that the oracle answer has a usable representation, and that $d$ runs in polynomial time. A claim that local Euler data “detects” factors is insufficient until a decoder and divisibility proof are supplied.

A practical certificate is easy to verify once a candidate appears: compute $n\bmod d$ and check $1<d<n$. The difficult direction is completeness—proving that the prescribed oracle queries always cause the decoder to produce such a $d$ for every composite input.

## 6. Algorithms

### 6.1. Finite-transcript perturbation

Given sampled pairs $(a,f(a))$, a fresh point $z$, and a desired target $T$, compute

$$
P_S(z)=\prod_{a\in S}(z-a),\qquad
\lambda=\frac{T-f(z)}{P_S(z)}.
$$

The perturbed evaluator is $g(w)=f(w)+\lambda P_S(w)$. Evaluating $g$ naively takes $O(|S|)$ complex multiplications. The construction demonstrates non-identifiability rather than proposing an efficient model of an $L$-function.

### 6.2. Bounded first-nonzero search

Given exact access to $c_k$ and a valid bound $B$, query in increasing order. Return the first $k$ with $c_k\ne0$. The algorithm uses at most $B+1$ queries, $O(B)$ equality tests, and constant auxiliary index storage apart from answer representations. Correctness follows from Theorem 4.3.

### 6.3. Certified factor decoding

Construct $q(n)$, evaluate $a=E(q(n))$, decode $d=d(n,a)$, and verify

$$
n\bmod d=0,
\qquad 1<d<n.
$$

The verification is polynomial in the bit lengths of $n$ and $d$. If it fails, the pipeline has not met the factor-search specification. If a completeness theorem guarantees success for every composite $n$, the pipeline is a correct factor-search method.

## 7. Applications and interpretation

### 7.1. The Riemann Hypothesis

An exact evaluator decides whether a specified $s$ satisfies $\zeta(s)=0$. It does not by itself prove that all nontrivial zeros lie on the critical line. A viable oracle-assisted strategy must add zero-counting certificates on bounded regions and a method covering all heights. The finite-observation obstruction explains why finite point samples cannot replace these additions.

### 7.2. Birch–Swinnerton-Dyer

Exact access to the central jet can locate the first nonzero coefficient once a finite search bound is known. This computes analytic rank under the bound. Identifying analytic rank with algebraic rank remains a separate mathematical assertion. Consequently, “evaluate at $s=1$” is inadequate twice over: a single value only distinguishes order zero from positive order, and the equality of analytic and algebraic ranks is not a consequence of evaluation.

### 7.3. Sato–Tate

Exact local coefficients permit exact finite histograms. They do not establish convergence to the Sato–Tate measure. An effective discrepancy estimate can bridge the gap by bounding the difference between empirical and limiting distributions as a function of the cutoff. Such a bound is global information about the family.

### 7.4. Langlands functoriality

Comparing finitely many local factors can certify a lift only when a converse rigidity theorem gives a sufficient agreement threshold in the relevant bounded family. Without such a theorem, finite agreement is evidence rather than proof. The appropriate oracle program therefore seeks quantitative multiplicity-one or converse bounds.

### 7.5. Complexity classes

If all problems in a class many-one reduce to a target that is one-query reducible to an evaluator, Corollary 2.4 gives a relative collapse to one evaluator call. This statement is compatible with either $P=NP$ or $P\ne NP$ in the ordinary model. No unconditional separation follows merely from postulating a powerful oracle.

## 8. Discussion

The framework organizes oracle claims around a local-to-global gap. Exact evaluation answers a well-posed local question. Global arithmetic theorems typically contain universal quantifiers, limiting operations, orders of vanishing, or existential arithmetic witnesses. Each requires a bridge:

1. **Zero statements** require certified region counts or exclusion bounds.
2. **Vanishing orders** require a finite nonvanishing bound.
3. **Distribution laws** require effective control of tails or discrepancy.
4. **Global identities** require rigidity within a restricted family.
5. **Factor search** requires a correct decoder and divisibility certificate.
6. **Complexity collapse** requires explicit reductions and an honest cost model.

The interpolation theorem shows that these are not cosmetic technicalities. Without structural restrictions, no finite transcript determines even one new value. Conversely, the transfer theorems show that once the appropriate bridge is supplied, the role of the evaluator is clean and compositional.

There are limitations. The unrestricted function class is broader than any natural family of $L$-functions, and the perturbation need not preserve arithmetic structure. The reduction theory is extensional and does not by itself specify bit complexity. Exact complex outputs require a representation supporting equality and decoding. These limitations are features of the analysis: each marks an assumption that must be stated before a computational consequence is claimed.

## 9. Future work

A natural next step is to replace vague global promises by certificate languages with explicit complexity. For completed $L$-functions, one may seek polynomial-size certificates that a rectangle contains a stated number of zeros. For elliptic curves, one may seek conductor-dependent bounds on how far the central Taylor jet must be searched. For factorization, the challenge is to construct auxiliary arithmetic objects and a decoder whose proper-divisor output is provably complete. For automorphic families, a quantitative converse-rigidity theorem could turn bounded local agreement into global identity. For distribution problems, effective tail and discrepancy bounds would connect finite coefficient access to limiting measures. Finally, oracle-relative hierarchy results should record query budgets, preprocessing costs, answer representation sizes, and adaptivity rather than speaking of collapse without a cost model.

## 10. Conclusion

Instant exact evaluation is powerful but local. It does not, by itself, classify all zeros, determine an unbounded vanishing order, prove a limiting distribution, identify global representations from finite samples, or extract factors from arithmetic data. The finite-observation interpolation theorem gives a universal obstruction: a finite transcript is compatible with arbitrary behavior at a fresh point. Positive consequences arise only after adding explicit mathematical structure. One-query reductions compose with many-one encodings; bounded nonvanishing makes jet search finite; and a certified decoder converts oracle output into a factor-search procedure. The decisive research problem is therefore not evaluation speed alone, but the construction of certificates, bounds, reductions, and rigidity principles that turn local values into global knowledge.
