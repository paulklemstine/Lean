# Finite Products of Moonshine-Type Series: Pole Aggregation, Weight Obstructions, and Character Reconstruction

**Aristotle**  
**18 July 2026**

## Abstract

Motivated by the $194$ conjugacy classes of the Monster group and their McKay–Thompson series, we isolate the algebraic mechanisms governing finite products of normalized moonshine-type expansions. A normalized factor is written as $T_c(q)=q^{-1}R_c(q)$ with $R_c(0)=1$. For every finite index set $S$, the product factors exactly as $q^{-|S|}\prod_{c\in S}R_c(q)$; hence principal exponents add and the displayed leading term cannot cancel. We next prove that finite products of invariant functions remain invariant. Consequently, a product of weight-zero modular functions cannot acquire a nontrivial positive modular weight merely through multiplication: at every nonzero point, any competing factor of automorphy must equal $1$. A compensating function transfers its own transformation factor to the invariant product and is therefore the precise mechanism required to change weight. Finally, we formulate coefficient recovery as an injectivity problem for character evaluation. Injectivity recovers graded multiplicities degree by degree, while every collision produces distinct gradings with indistinguishable coefficient functions. These results clarify which parts of the proposed “Monster as a modular form” picture follow from finite algebra and which require additional analytic or representation-theoretic input. We provide convolution and reconstruction algorithms, complexity estimates, finite examples, applications to identifiability, and an analytic program for common-level modular products.

## 1. Introduction

The Monster group $\mathbb M$ is the largest sporadic finite simple group. Its order is

$$
|\mathbb M|=2^{46}3^{20}5^9 7^6 11^2 13^3 17\,19\,23\,29\,31\,41\,47\,59\,71,
$$

approximately $8\times10^{53}$. Monstrous moonshine connects graded representations of $\mathbb M$ to modular functions. The classical point of entry is

$$
j(\tau)-744=q^{-1}+196884q+21493760q^2+\cdots,
\qquad q=e^{2\pi i\tau},
$$

whose coefficients decompose into dimensions of Monster representations. More generally, for each conjugacy class represented by $g\in\mathbb M$, a McKay–Thompson series has the form

$$
T_g(q)=\sum_{n\ge -1}a_n(g)q^n,
$$

where the coefficient $a_n(g)$ is interpreted as a graded trace.

The Monster has $194$ conjugacy classes. This invites the proposal that the product of all class-indexed series should itself encode the entire group, perhaps as a modular form of large positive weight. Several logically distinct assertions are hidden in that proposal:

1. the principal parts of normalized series should combine predictably;
2. modular transformation laws should survive multiplication;
3. coefficient functions should recover representation multiplicities;
4. a finite algebraic product should extend to a meromorphic modular object on a common analytic domain.

The first three questions admit general answers independent of the detailed construction of the Monster. The fourth requires additional analytic data. The purpose of this paper is to state the general answers precisely and to mark the boundary between established algebra and the remaining moonshine-specific work.

The central distinction is between indexing by conjugacy classes and indexing by group elements. If one normalized series is attached to each class, there are $194$ factors and the aggregate displayed exponent is $-194$. If a product is literally taken over every element of $\mathbb M$, class functions repeat according to class size and the aggregate exponent is $-|\mathbb M|$. These products cannot be interchanged.

A second distinction concerns modular weight. The McKay–Thompson series are modular functions, hence weight-zero objects, for suitable groups. Multiplication preserves weight zero on the common symmetry group. A nonzero weight cannot appear without an additional factor, multiplier, or modified operation.

A third distinction concerns encoding. Classwise traces determine graded multiplicities when the character-evaluation operator is injective. The criterion is exact: noninjectivity creates indistinguishable multiplicity assignments.

## 2. Algebraic setting

### 2.1 Laurent expansions and normalization

Let $R$ be a commutative semiring and let $R[q,q^{-1}]$ denote the Laurent polynomial ring. Let $C$ be an index set, usually interpreted as a set of conjugacy classes.

**Definition 2.1 (Normalized family).** A normalized family indexed by $C$ consists of Laurent polynomials $R_c(q)\in R[q,q^{-1}]$ satisfying

$$
R_c(0)=1
$$

for every $c\in C$, together with the associated series

$$
T_c(q)=q^{-1}R_c(q).
$$

Here $R_c(0)$ means the coefficient of $q^0$. The adjective “regular” refers to the intended analytic case, where $R_c$ has no negative powers. The algebraic factorization below needs only the displayed normalization.

The condition $R_c(0)=1$ has two effects. It guarantees that $R_c$ is nonzero whenever $1\neq0$ in $R$, and it fixes the leading coefficient of the product’s regular factor.

**Lemma 2.2 (Nonvanishing of regular factors).** If $R$ is nontrivial and $R_c(0)=1$, then $R_c\neq0$.

**Proof sketch.** If $R_c$ were the zero Laurent polynomial, its coefficient at $q^0$ would be $0$, contradicting $R_c(0)=1$. $\square$

### 2.2 Finite products

Let $S\subset C$ be finite. The basic product law is independent of character theory and modular analysis.

**Theorem 2.3 (Normalized Product Factorization).** For every finite $S$,

$$
\prod_{c\in S}T_c(q)
=q^{-|S|}\prod_{c\in S}R_c(q).
$$

If every $R_c$ is regular at $q=0$, then the rightmost product has constant coefficient $1$. Consequently, the product has a pole of exact order $|S|$ at $q=0$ and leading coefficient $1$.

**Proof sketch.** For the empty set, both sides equal $1$. For the inductive step, adjoining an index $a$ multiplies the existing product by $q^{-1}R_a(q)$. The monomial exponents add:

$$
q^{-|S|}q^{-1}=q^{-(|S|+1)}.
$$

Commutativity permits all regular factors to be collected. If the factors are regular, the constant coefficient of their product is the product of their constant coefficients, namely $1$. Therefore the coefficient of $q^{-|S|}$ is $1$, so cancellation is impossible. $\square$

**Corollary 2.4 (Nonvanishing of normalized products).** If $R$ is an integral domain, then

$$
\prod_{c\in S}T_c(q)\neq0.
$$

**Proof sketch.** The monomial $q^{-|S|}$ is nonzero. Every regular factor is nonzero by Lemma 2.2, and a finite product of nonzero elements in a domain is nonzero. $\square$

**Example 2.5.** The symmetric group $S_3$ has three conjugacy classes: the identity class, the transpositions, and the $3$-cycles. Any normalized family indexed by these classes satisfies

$$
T_1(q)T_2(q)T_3(q)=q^{-3}R_1(q)R_2(q)R_3(q).
$$

This example separates the number of factors, $3$, from the group order, $6$.

**Corollary 2.6 (Class-indexed Monster exponent).** For a normalized family indexed once by each of the $194$ Monster conjugacy classes, the displayed product factor is $q^{-194}$. Subject to regularity at the infinite cusp, the pole there has exact order $194$.

This corollary is conditional only in its analytic wording: the Laurent factorization itself is exact. Establishing that the actual McKay–Thompson regular factors share the needed analytic domain and cusp parameter is a separate task.

## 3. Transformation laws and modular weight

### 3.1 Invariance

Let a transformation $\gamma$ act on a set $X$, and let functions take values in a commutative monoid $A$.

**Definition 3.1 (Invariance).** A function $f:X\to A$ is invariant under $\gamma$ if

$$
f(\gamma x)=f(x)
$$

for every $x\in X$.

**Theorem 3.2 (Finite-Product Invariance).** Let $S$ be finite and let $F_c:X\to A$ be invariant under $\gamma$ for every $c\in S$. Then

$$
P(x)=\prod_{c\in S}F_c(x)
$$

is invariant under $\gamma$.

**Proof sketch.** At each $x$,

$$
P(\gamma x)=\prod_{c\in S}F_c(\gamma x)
=\prod_{c\in S}F_c(x)=P(x).
$$

Only finiteness and commutative multiplication are used. $\square$

For modular functions, let $X$ be the upper half-plane and let $\gamma=\begin{psmallmatrix}a&b\\c&d\end{psmallmatrix}$ act by $\tau\mapsto(a\tau+b)/(c\tau+d)$. A weight-zero modular function is invariant under the relevant subgroup. If factors are modular for groups $\Gamma_c$, their product is invariant under the intersection

$$
\Gamma=\bigcap_{c\in S}\Gamma_c.
$$

Because $S$ is finite, the analytic product itself raises no infinite-product convergence issue. The substantive questions are meromorphy, the finite index of $\Gamma$, multiplier compatibility, and cusp divisors.

### 3.2 The weight obstruction

Suppose $K$ is a field and an invariant function is also alleged to satisfy a weighted law.

**Theorem 3.3 (Weight Obstruction).** Let $P,J:X\to K$. Assume

$$
P(\gamma x)=P(x)
$$

and

$$
P(\gamma x)=J(x)P(x)
$$

for all $x$. At every point where $P(x)\neq0$, one has $J(x)=1$.

**Proof sketch.** Equating the two expressions for $P(\gamma x)$ gives

$$
J(x)P(x)=P(x).
$$

Cancellation by the nonzero field element $P(x)$ gives $J(x)=1$. $\square$

For an integral modular weight $k$, a typical factor is $J(x)=(c\tau+d)^k$, possibly multiplied by a character or multiplier. The theorem implies that an invariant product cannot simultaneously transform by a genuinely nontrivial such factor wherever the product is nonzero. Thus a finite product of weight-zero functions remains weight zero; its weight is not $|\mathbb M|/24$, $194/24$, or any other positive number merely because many factors were multiplied.

The nonzero hypothesis is essential. If $P(x)=0$, both laws yield $P(\gamma x)=0$ regardless of $J(x)$. Globally, however, a nonzero meromorphic function is nonzero on an open dense subset, so agreement of transformation laws there strongly constrains the factor of automorphy.

### 3.3 Compensators

**Theorem 3.4 (Compensator Transfer).** Let $P$ be invariant under $\gamma$, and suppose $A:X\to A$ satisfies

$$
A(\gamma x)=J(x)A(x).
$$

Then the product $A P$ satisfies

$$
(A P)(\gamma x)=J(x)(A P)(x).
$$

**Proof sketch.** Substitute both transformation laws and reassociate:

$$
A(\gamma x)P(\gamma x)
=J(x)A(x)P(x).
$$

$\square$

The theorem identifies the correct repair for a desired positive-weight moonshine product. One must supply a compensator carrying that weight. In analytic terms, finding a canonical compensator becomes a divisor problem on the relevant modular curve. Its zeros and poles must adjust the divisor of the invariant product while respecting the desired multiplier system.

If $A(q)=q^{-r}B(q)$ and $B(0)=1$, then multiplying by $A$ also adds the principal exponent $-r$. Weight and pole order are therefore distinct bookkeeping variables: the compensator controls both according to its own transformation law and divisor.

## 4. Character evaluation and reconstruction

### 4.1 The encoding map

Let $\mathcal R$ index irreducible representations and let $\mathcal C$ index conjugacy classes. Over a field $K$, a multiplicity vector is a function $m:\mathcal R\to K$. Character evaluation is the linear map

$$
E:K^{\mathcal R}\longrightarrow K^{\mathcal C},
\qquad
(Em)(c)=\sum_{r\in\mathcal R}m(r)\chi_r(c).
$$

A graded multiplicity assignment is a sequence $m_n\in K^{\mathcal R}$. The observed coefficient function at degree $n$ is $a_n=E(m_n)$. In moonshine, $a_n(c)$ is the trace of a representative of class $c$ on the degree-$n$ graded piece.

**Definition 4.1 (Identifiable character encoding).** The encoding is identifiable if $E$ is injective on the allowed multiplicity space. This may be the whole vector space, an integral lattice, or a cone of nonnegative vectors.

### 4.2 Exact recovery criterion

**Theorem 4.2 (Graded Character Reconstruction).** Suppose $E$ is injective. If two graded multiplicity assignments $m_n$ and $m'_n$ satisfy

$$
E(m_n)(c)=E(m'_n)(c)
$$

for every degree $n$ and class $c$, then

$$
m_n=m'_n
$$

for every $n$.

**Proof sketch.** Fix $n$. Equality at every class means $E(m_n)=E(m'_n)$. Injectivity gives $m_n=m'_n$. Since $n$ was arbitrary, the complete assignments agree. $\square$

**Theorem 4.3 (Collision Produces Indistinguishable Gradings).** Suppose there exist $u\neq v$ with $E(u)=E(v)$. Define constant graded assignments by $m_n=u$ and $m'_n=v$ for every $n$. Then $m\neq m'$ but

$$
E(m_n)=E(m'_n)
$$

for every degree $n$.

**Proof sketch.** The assignments differ already in degree $0$ because $u\neq v$. Their images agree in every degree by the assumed collision. $\square$

Together, Theorems 4.2 and 4.3 show that injectivity is not merely sufficient but the exact boundary for unrestricted recovery.

### 4.3 Matrix formulation

For finite $\mathcal R$ and $\mathcal C$, write the character matrix as

$$
X_{c,r}=\chi_r(c).
$$

Then $a_n=Xm_n$. Injectivity is equivalent to full column rank. If $X$ is square and invertible,

$$
m_n=X^{-1}a_n.
$$

For a complete complex character table, irreducible characters form a basis of class functions, so the square character table is invertible. When only selected classes or approximate coefficients are used, full rank may fail or numerical conditioning may be poor. If multiplicities must be nonnegative integers, uniqueness can sometimes hold on that discrete cone even when unrestricted linear injectivity fails; this is a sharper finite-data question.

### 4.4 What products retain

Character reconstruction uses the family of coefficient functions, not merely their product. Multiplication is a nonlinear compression. If

$$
T_c(q)=q^{-1}+a_0(c)+a_1(c)q+\cdots,
$$

then coefficients of $\prod_cT_c(q)$ are convolutions mixing classes and degrees. Without additional labels or factorization uniqueness, the single aggregate series does not automatically recover each $T_c$, much less the entire character table. Therefore “the product encodes everything” is a conjectural decoding claim that requires its own injectivity theorem.

## 5. Algorithms

### 5.1 Truncated normalized product

Suppose each regular factor is known through degree $N$:

$$
R_c(q)=\sum_{k=0}^{N}r_{c,k}q^k+O(q^{N+1}),
\qquad r_{c,0}=1.
$$

The product through degree $N$ is computed by repeated truncated convolution. Initialize $p_0=1$ and $p_k=0$ for $k>0$. For each class $c$, replace

$$
p'_k=\sum_{i=0}^{k}p_i r_{c,k-i},
\qquad 0\le k\le N.
$$

After all $m=|S|$ factors, return

$$
q^{-m}\sum_{k=0}^{N}p_kq^k.
$$

The direct algorithm uses $O(mN^2)$ arithmetic operations and $O(N)$ working memory. Fast polynomial multiplication can reduce the asymptotic cost for large $N$, but direct convolution is transparent and exact for the first hundred coefficients.

The invariant checks supplied by Theorem 2.3 are useful computational diagnostics: the shift must be $-m$, and the regular constant coefficient must remain $1$.

### 5.2 Character multiplicity recovery

Given a full-column-rank character matrix $X$ and coefficient vectors $a_0,\ldots,a_N$, precompute a left inverse $L$ satisfying $LX=I$. Then compute

$$
m_n=La_n
$$

for each degree. For a square $r\times r$ table, Gaussian elimination costs $O(r^3)$ once and each degree costs $O(r^2)$. With exact rational or cyclotomic arithmetic, one can verify integrality and nonnegativity of recovered multiplicities.

A rank test must precede inversion. If $\operatorname{rank}(X)<r$, compute a nonzero kernel vector $z$. Then $m$ and $m+z$ have identical classwise evaluations whenever both are admissible. This kernel certificate witnesses nonidentifiability.

### 5.3 Transformation-law audit

A proposed product law can be audited symbolically:

1. identify the common subgroup under which every factor is invariant;
2. conclude that the finite product is invariant on that subgroup;
3. compare any claimed factor $J(\gamma,\tau)$ with $1$ at a point where the product is nonzero;
4. if $J\neq1$, reject the law or introduce a compensator carrying $J$;
5. track the compensator’s zeros, poles, and principal exponent separately.

The audit is logically prior to numerical coefficient testing. Agreement of many coefficients cannot repair an incompatible transformation law.

## 6. Applications and examples

### 6.1 A three-factor convolution

Take

$$
R_1(q)=1+q,
\qquad
R_2(q)=1+2q,
\qquad
R_3(q)=1-q+q^2.
$$

Then

$$
R_1(q)R_2(q)R_3(q)=1+2q+q^3+2q^4,
$$

and therefore

$$
T_1(q)T_2(q)T_3(q)
=q^{-3}+2q^{-2}+2q^{-1}+1+2q.
$$

The pole order is exactly $3$, regardless of the higher coefficients.

### 6.2 An invertible character encoding

Consider

$$
X=\begin{pmatrix}1&1\\1&-1\end{pmatrix}.
$$

For multiplicities $m=(3,2)^T$, the coefficient vector is

$$
a=Xm=(5,1)^T.
$$

Since

$$
X^{-1}=\frac12\begin{pmatrix}1&1\\1&-1\end{pmatrix},
$$

reconstruction returns $m=(3,2)^T$. This is the elementary two-character analogue of inversion using a full character table.

### 6.3 A collision

If only the first row is observed, the encoding is

$$
E(x,y)=x+y.
$$

Then $(3,2)$ and $(4,1)$ are distinct but both map to $5$. Repeating either vector in every degree produces indistinguishable graded coefficient data. The example shows why merely collecting coefficients does not ensure recovery; the measurement map must separate the unknowns.

### 6.4 Relation to machine learning

The character map $E$ can be viewed as a linear observation layer. Multiplicity vectors are latent variables and classwise traces are features. Full column rank gives identifiability. A kernel vector is an adversarial ambiguity invisible to the observations. Nonnegativity and integrality are structural priors, while selecting conjugacy classes resembles experimental design: one seeks a small set of rows retaining injectivity and favorable conditioning.

The product operation is a separate aggregator. In logarithmic coordinates it turns products into sums, so principal valuations add. Yet aggregation sacrifices labels. Recovering all factors from one aggregate requires additional structure, just as recovering individual data points from a pooled statistic requires a strong generative model.

## 7. Analytic scope and limitations

The algebraic product theorem applies to Laurent polynomials and finite truncations. For genuine McKay–Thompson series, a complete analytic theorem should establish the following.

First, every factor must be meromorphic on the upper half-plane and at the cusps of an appropriate finite-index subgroup. Second, if factors are attached to different groups, one must work on a common intersection subgroup and account for cusp widths. Third, the divisor of the product is the sum of the pulled-back divisors of the factors. Fourth, normalized expansions at the infinite cusp must use compatible local parameters before pole orders are added.

Because the class family is finite, no infinite-product convergence theorem is needed. The phrase “prove the product converges” should be replaced by “prove that every factor is meromorphic in a common setting and determine the resulting divisor.”

The present results do not establish genus-zero properties for the common subgroup, reconstruct maximal subgroups from coefficients, or show that one aggregate product uniquely determines all $194$ factors. They also do not identify a canonical positive-weight compensator. Each is a meaningful additional theorem rather than a consequence of multiplication alone.

## 8. Future research

### 8.1 Class-indexed pole order for the Monster

Construct all $194$ normalized McKay–Thompson series in one analytic setting and prove that their class-indexed product has a pole of exact order $194$ at the infinite cusp, with no cancellation of the leading coefficient. Normalized principal parts aggregate additively, so the indexing convention leaves an observable signature in the pole order.

### 8.2 Minimal compensator for positive weight

Determine whether a canonical meromorphic compensator turns the classwise invariant product into a modular form of prescribed positive weight. Classify the smallest possible compensator divisor on the relevant modular curve. The weight obstruction reduces this to a precise repair problem.

### 8.3 Finite coefficient threshold for character recovery

Find the least $N$ such that coefficient functions through degree $N$ uniquely determine the intended irreducible characters and all multiplicities through that degree. This is an injectivity problem for a truncated evaluation operator, refined by positivity and integrality. A decisive counterexample would be two distinct nonnegative integral multiplicity tables with identical traces through degree $N$.

### 8.4 Analytic finite-product theorem across levels

For finitely many meromorphic modular functions attached to possibly different finite-index subgroups, prove that their product is a weight-zero meromorphic modular function for the intersection subgroup and compute its complete cusp divisor from the individual divisors. Applying this theorem to compatible McKay–Thompson families would bridge the finite algebraic factorization with genuine analytic moonshine.

### 8.5 Stable numerical reconstruction

Exact injectivity does not guarantee numerical stability. Study singular values and condition numbers of truncated or row-restricted character matrices, and design class-sampling schemes that preserve both rank and robust recovery under coefficient noise.

## 9. Discussion

Three independent conservation laws organize the theory. Valuations add under multiplication. Weight-zero invariance is preserved under finite products. Information is preserved under character evaluation exactly when the evaluation map is injective. Confusing these laws leads to overstatements: the number of factors does not create modular weight, a product does not automatically retain the labels of its factors, and coefficient data do not decode themselves.

The refined moonshine picture is nevertheless substantial. A class-indexed product has a predictable pole signature. Its common modular symmetry can be determined from the factors. A compensator offers a controlled route to nonzero weight. Classwise coefficients provide an exact representation-theoretic encoding whenever the character map is injective. These are reusable principles for finite groups beyond the Monster and for other settings where graded traces meet automorphic functions.

## 10. Conclusion

For a finite normalized family $T_c(q)=q^{-1}R_c(q)$, multiplication yields the exact factor $q^{-|S|}$, and normalization prevents cancellation of the displayed leading term. A finite product of invariant functions remains invariant, so it cannot acquire a nontrivial modular weight at nonzero points without an additional compensating factor. Finally, coefficient functions recover graded multiplicities precisely at the injectivity boundary of character evaluation; collisions produce indistinguishable gradings.

Thus the claim that the Monster “is a modular form” should be read not as an automatic consequence of multiplying $194$ functions, but as a program requiring explicit choices of indexing, common modular symmetry, compensator, and decoding map. The algebraic results presented here supply the bookkeeping and obstruction theory needed to pursue that program without conflating pole order, modular weight, and recoverable information.
