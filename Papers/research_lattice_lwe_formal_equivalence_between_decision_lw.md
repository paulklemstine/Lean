# Unit-Affine Rerandomization for Learning with Errors over Arbitrary Moduli

**Aristotle**  
**25 July 2026**

## Abstract

Search-to-decision reductions for Learning with Errors are most transparent over a prime modulus, where every nonzero residue is invertible. Composite moduli, including the powers of two favored by many implementations, contain nonzero zero divisors, so the prime-field rule for affine rerandomization does not survive unchanged. This paper isolates the exact arbitrary-modulus replacement and develops its consequences. For every positive modulus $q$, the affine map $x\mapsto ax+b$ on $\mathbb Z/q\mathbb Z$ is bijective if and only if $a$ is a unit, equivalently if and only if $\gcd(a,q)=1$. Unit-affine maps preserve every finite sum and average, hence preserve the uniform distribution. The admissible multipliers number exactly Euler’s totient $\varphi(q)$. Under a Chinese-remainder decomposition into coprime factors, both invertibility and the totient count factor componentwise. Finally, a finite hybrid lemma shows that if an aggregate distinguishing advantage $\delta$ is distributed among $q$ candidate residues of a secret coordinate, then one candidate contributes at least $\delta/q$. These results supply the algebraic and quantitative scaffold required by arbitrary-modulus search-to-decision arguments, recover the prime-modulus theory as a corollary, and expose the distributional steps still required for a complete oracle reduction.

## 1. Introduction

The Learning with Errors problem (LWE) hides a vector behind noisy modular linear equations. Let $q\geq1$ be an integer modulus, let $n\geq1$ be a dimension, and write

$$
R_q=\mathbb Z/q\mathbb Z.
$$

A secret $s\in R_q^n$ determines samples of the form

$$
(u,v)\in R_q^n\times R_q,
\qquad
v=\langle u,s\rangle+e\pmod q,
$$

where $u$ is uniform and $e$ is drawn from a prescribed error distribution concentrated near zero. **Search-LWE** asks an algorithm to recover $s$. **Decision-LWE** asks an algorithm to distinguish such samples from uniformly random pairs. A search-to-decision reduction uses a decision oracle as a subroutine to recover the secret, typically by guessing secret coordinates and transforming samples so that the oracle’s response detects a correct guess.

The classical algebra is clean when $q=p$ is prime. The ring $R_p$ is a field, so multiplication by every nonzero $a$ is a permutation. Consequently every affine map

$$
T_{a,b}(x)=ax+b,
\qquad a\neq0,
$$

permutes $R_p$ and preserves uniformity. A hybrid reduction can rerandomize a sample without introducing a spurious statistical bias.

For composite $q$, the implication “nonzero implies invertible” fails. Modulo $4$, for example, $2\neq0$ but multiplication by $2$ maps both $0$ and $2$ to $0$. Any argument that chooses an arbitrary nonzero multiplier therefore risks collapsing the sample space. This is especially relevant because contemporary lattice cryptosystems often use powers of two or other composite moduli for efficient arithmetic.

The correct invariant is the group of units $R_q^\times$. The contribution of this paper is to organize the arbitrary-modulus algebra around three mutually reinforcing facts:

1. unit multipliers are exactly the multipliers that make affine maps bijective;
2. there are exactly $\varphi(q)$ such multipliers;
3. units and their count factor across coprime Chinese-remainder components.

A generic pigeonhole theorem then supplies the quantitative hybrid step: a total gap spread over $q$ residues leaves a gap of at least $\delta/q$ somewhere. This statement is deliberately distribution-independent. It records the numerical conclusion once a concrete reduction has expressed its total distinguishing advantage as a sum of per-residue contributions.

The distinction between scaffold and complete reduction is important. The results below prove the algebraic uniformity mechanism and the finite advantage bound for every modulus. To obtain a full probabilistic polynomial-time reduction for a chosen LWE variant, one must additionally define the relevant oracle experiments, prove that the transformed error distributions have the required form, and account for sample and repetition complexity. Those distributional tasks depend on the precise LWE formulation and remain separate from the universal ring-theoretic results established here.

## 2. Preliminaries

### 2.1 Residue rings, units, and affine maps

For $q>0$, the residue ring $R_q$ has exactly $q$ elements. A residue $a\in R_q$ is a **unit** if there is a residue $c\in R_q$ such that

$$
ac=1.
$$

The inverse, when it exists, is unique and is denoted $a^{-1}$. If an integer $a$ is also used for its residue class, the standard arithmetic criterion is

$$
a\in R_q^\times
\quad\Longleftrightarrow\quad
\gcd(a,q)=1.
$$

For $a,b\in R_q$, define the affine transformation

$$
T_{a,b}:R_q\longrightarrow R_q,
\qquad
T_{a,b}(x)=ax+b.
$$

A map on a finite set preserves the uniform distribution if it is a permutation. Thus bijectivity, rather than merely nonconstancy, is the property needed for lossless rerandomization.

### 2.2 Euler’s totient

Euler’s totient function is

$$
\varphi(q)=\left|\{a\in\{0,1,\ldots,q-1\}:\gcd(a,q)=1\}\right|.
$$

It therefore counts the units of $R_q$. When $p$ is prime,

$$
\varphi(p)=p-1,
$$

and for a prime power $p^e$,

$$
\varphi(p^e)=p^e-p^{e-1}=p^e\left(1-\frac1p\right).
$$

### 2.3 Uniformity and statistics

Let $X$ be uniform on $R_q$. For a statistic $f:R_q\to\mathbb R$,

$$
\mathbb E[f(X)]=\frac1q\sum_{x\in R_q}f(x).
$$

If $T$ permutes $R_q$, then $T(X)$ is uniform and

$$
\mathbb E[f(T(X))]=\mathbb E[f(X)].
$$

Taking $f$ to be an indicator function yields equality of event probabilities. Allowing arbitrary real-valued $f$ gives a convenient universal formulation of distribution preservation.

### 2.4 Distinguishing advantage and hybrid contributions

A distinguisher is a statistical test whose acceptance probability differs between two distributions. Its advantage is the absolute or signed gap specified by the reduction. A hybrid proof introduces intermediate distributions and writes or bounds the endpoint gap by a sum of local contributions. The finite lemma used below requires only a real number $\delta$, a nonempty finite index set $I$, and real contributions $A(i)$ satisfying

$$
\delta\leq\sum_{i\in I}A(i).
$$

No positivity assumption on individual contributions is needed for the averaging conclusion.

## 3. The affine permutation criterion

We begin with the central structural theorem.

**Theorem 3.1 (Affine Permutation Criterion).** Let $q>0$ and $a,b\in R_q$. The affine map $T_{a,b}(x)=ax+b$ is bijective if and only if $a$ is a unit of $R_q$.

**Proof sketch.** Translation by $b$ is always bijective, with inverse translation by $-b$. Hence $T_{a,b}$ is bijective exactly when the multiplication map $M_a(x)=ax$ is bijective.

If $a$ is a unit, then $M_{a^{-1}}$ is the inverse of $M_a$, so $M_a$ and therefore $T_{a,b}$ are bijective. Conversely, if $T_{a,b}$ is bijective, compose it with translation by $-b$ to conclude that $M_a$ is bijective. Surjectivity gives an $x\in R_q$ with $ax=1$, proving that $a$ is a unit. $\square$

The inverse is explicit whenever $a$ is a unit:

$$
T_{a,b}^{-1}(y)=a^{-1}(y-b).
$$

This makes the absence of any field hypothesis clear. Only the chosen multiplier must be invertible; the ambient ring need not be a field.

**Corollary 3.2 (Coprimality Criterion).** Let $a$ be an integer and $b\in R_q$. The map $x\mapsto ax+b$ is bijective on $R_q$ if and only if $\gcd(a,q)=1$.

**Proof sketch.** Combine Theorem 3.1 with the standard equivalence between invertibility modulo $q$ and Bézout coprimality. If $ua+vq=1$, then $u$ is an inverse of $a$ modulo $q$. Conversely, a modular inverse gives an integer relation $ua-1=kq$, hence a Bézout identity. $\square$

**Example 3.3.** For $q=12$, the multipliers $1,5,7,11$ are units. Each map $x\mapsto ax+b$ with one of these four multipliers permutes all twelve residues. The nonzero multiplier $a=4$ does not: multiplication by $4$ has image $\{0,4,8\}$.

The example demonstrates why “choose a nonzero multiplier” is not a valid arbitrary-modulus instruction. A nonzero zero divisor can have a dramatically smaller image.

## 4. Invariance of sums, averages, and uniformity

The affine criterion immediately gives the change-of-variables identity needed by rerandomization arguments.

**Theorem 4.1 (Unit-Affine Sum Invariance).** Let $q>0$, let $a,b\in R_q$, and suppose that $a$ is a unit. For every function $f:R_q\to\mathbb R$,

$$
\sum_{x\in R_q}f(ax+b)=\sum_{x\in R_q}f(x).
$$

**Proof sketch.** By Theorem 3.1, $T_{a,b}$ is a permutation of $R_q$. Reindex the sum using $y=T_{a,b}(x)$. As $x$ ranges over $R_q$, $y$ ranges over every element exactly once. $\square$

**Corollary 4.2 (Unit-Affine Average Invariance).** Under the same hypotheses,

$$
\frac1q\sum_{x\in R_q}f(ax+b)
=
\frac1q\sum_{x\in R_q}f(x).
$$

**Proof sketch.** Divide the identity in Theorem 4.1 by $q$. $\square$

**Corollary 4.3 (Preservation of Uniformity).** If $X$ is uniform on $R_q$ and $a$ is a unit, then $aX+b$ is uniform on $R_q$.

**Proof sketch.** For each subset $S\subseteq R_q$, apply Theorem 4.1 to its indicator function. Equivalently, every $y$ has exactly one preimage $a^{-1}(y-b)$, so $\Pr[aX+b=y]=1/q$. $\square$

This result is the universal part of the LWE rerandomization argument. A decision oracle is sensitive to distributions, so transformations made before an oracle call must not manufacture an unintended distinguishing signal. Unit-affine transformations preserve a uniform modular coordinate exactly. A concrete search reduction must additionally show how the correct or incorrect secret-coordinate guess places the transformed LWE sample into the desired oracle experiment; that further statement depends on the sample and error model.

## 5. Exact enumeration of admissible rerandomizers

The bijectivity theorem classifies valid multipliers. Euler’s totient counts them.

**Theorem 5.1 (Totient Enumeration).** For every $q>0$, the number of residues $a\in R_q$ for which $x\mapsto ax+b$ is bijective is exactly $\varphi(q)$. This count is independent of $b$.

**Proof sketch.** By Theorem 3.1, the admissible residues are precisely the units of $R_q$. By Corollary 3.2, these are precisely the residue classes represented by integers coprime to $q$. Their number is the defining count $\varphi(q)$. $\square$

Two immediate bounds are useful:

$$
0<\varphi(q)\leq q.
$$

The left inequality follows because $1$ is always a unit; the right follows because the units form a subset of all residues. Thus valid rerandomization is never vacuous.

**Corollary 5.2 (Prime Modulus Count).** If $p$ is prime, then exactly $p-1$ affine multipliers are valid.

**Proof sketch.** Every residue except $0$ is coprime to $p$, so $\varphi(p)=p-1$. $\square$

**Proposition 5.3 (Rejection-Sampling Cost).** Suppose independent uniform residues modulo $q$ are sampled until a unit appears. The success probability per trial is $\varphi(q)/q$, and the expected number of trials is $q/\varphi(q)$.

**Proof sketch.** Theorem 5.1 gives the success probability. The number of independent trials until the first success is geometrically distributed with mean equal to the reciprocal success probability. $\square$

For $q=p^e$, the acceptance probability is $1-1/p$. Thus powers of a fixed prime have constant expected cost $p/(p-1)$; for powers of two the expected count is $2$. For a modulus with many distinct small prime factors, the unit density can be much lower.

## 6. Chinese-remainder decomposition

Let $m,n>0$ be coprime. The Chinese Remainder Theorem gives a ring isomorphism

$$
\Psi:R_{mn}\longrightarrow R_m\times R_n,
\qquad
\Psi(a)=(a\bmod m,a\bmod n).
$$

The unit criterion respects this product exactly.

**Theorem 6.1 (Componentwise Invertibility).** If $\gcd(m,n)=1$, then $a\in R_{mn}$ is a unit if and only if both components of $\Psi(a)$ are units in $R_m$ and $R_n$, respectively.

**Proof sketch.** A pair $(u,v)$ in a product ring is invertible exactly when both entries are invertible. If $(u,v)(u',v')=(1,1)$, then $uu'=1$ and $vv'=1$. Conversely, inverses $u^{-1}$ and $v^{-1}$ combine to give $(u^{-1},v^{-1})$. Transport this characterization through the Chinese-remainder isomorphism. $\square$

**Theorem 6.2 (Multiplicativity of the Rerandomizer Count).** If $\gcd(m,n)=1$, then

$$
\varphi(mn)=\varphi(m)\varphi(n).
$$

**Proof sketch.** Theorem 6.1 identifies each unit modulo $mn$ with an arbitrary pair consisting of one unit modulo $m$ and one unit modulo $n$. Counting the Cartesian product gives the product of the two counts. $\square$

Iterating these results over the prime-power factorization

$$
q=\prod_{j=1}^r p_j^{e_j}
$$

produces

$$
R_q^\times\cong\prod_{j=1}^r R_{p_j^{e_j}}^\times
$$

and

$$
\varphi(q)=\prod_{j=1}^r\varphi(p_j^{e_j})
=q\prod_{p\mid q}\left(1-\frac1p\right).
$$

This decomposition clarifies both correctness and cost. A proposed multiplier is globally safe exactly when it is safe in every prime-power component, and its acceptance probability is the product of the component acceptance probabilities.

**Example 6.3.** Let $q=40=5\cdot8$. Since $5$ and $8$ are coprime,

$$
\varphi(40)=\varphi(5)\varphi(8)=4\cdot4=16.
$$

A residue is a unit modulo $40$ precisely when its reductions are nonzero modulo $5$ and odd modulo $8$.

## 7. The finite hybrid bound

The algebra above ensures that selected transformations preserve uniformity. The next result records how a total distinguishing gap must concentrate in a finite hybrid.

**Theorem 7.1 (Advantage Pigeonhole Principle).** Let $I$ be a finite nonempty set, let $A:I\to\mathbb R$, and let $\delta\in\mathbb R$. If

$$
\delta\leq\sum_{i\in I}A(i),
$$

then there exists $i\in I$ such that

$$
A(i)\geq\frac{\delta}{|I|}.
$$

**Proof sketch.** Assume the contrary: $A(i)<\delta/|I|$ for every $i$. Strictly summing over the nonempty set gives

$$
\sum_{i\in I}A(i)
<
\sum_{i\in I}\frac{\delta}{|I|}
=
\delta,
$$

contradicting the assumed lower bound. $\square$

**Corollary 7.2 (Residue-Wise Advantage Bound).** Let $q>0$ and assign a real contribution $A(r)$ to each residue $r\in R_q$. If

$$
\delta\leq\sum_{r\in R_q}A(r),
$$

then some residue $r$ satisfies

$$
A(r)\geq\frac{\delta}{q}.
$$

**Proof sketch.** Apply Theorem 7.1 to $I=R_q$, whose cardinality is $q$. $\square$

This is the quantitative core of a residue-guessing hybrid. Suppose a concrete decision experiment associates a contribution $A(r)$ to the hypothesis that a chosen secret coordinate equals $r$, and suppose the reduction establishes that these contributions sum to at least its decision advantage $\delta$. Then at least one candidate carries advantage $\delta/q$ or greater.

The denominator $q$ counts all candidate residues, not only unit multipliers. The roles are distinct: candidate residues enumerate possible secret values, whereas the $\varphi(q)$ units enumerate transformations that can be used without destroying uniformity. A sound reduction must keep these two finite sets conceptually separate.

A second application concerns coordinates. If a hybrid over $n$ secret coordinates has contributions $C(1),\ldots,C(n)$ totaling at least $\delta$, then some coordinate contributes at least $\delta/n$. Combining coordinate and residue hybrids can lead to a loss on the scale of $nq$, subject to the exact organization of oracle calls and signs of the hybrid gaps.

## 8. Recovery of the prime-field regime

The arbitrary-modulus criterion strictly contains the familiar prime case.

**Corollary 8.1 (Prime-Field Affine Bijection).** Let $p$ be prime. If $a,b\in R_p$ and $a\neq0$, then $x\mapsto ax+b$ is a bijection.

**Proof sketch.** In a field every nonzero element is a unit. Apply Theorem 3.1. $\square$

All corresponding prime statements follow immediately. Unit-affine sum invariance becomes invariance for every nonzero multiplier, and the count $\varphi(p)=p-1$ says that the only forbidden multiplier is zero. The composite theory therefore explains exactly why prime-modulus proofs can use the simpler condition $a\neq0$: fields have no nonzero zero divisors.

## 9. Algorithms and computational implications

### 9.1 Testing and applying a safe affine rerandomizer

Given $q$, $a$, $b$, and $x$, compute $g=\gcd(a,q)$. If $g\neq1$, reject the multiplier. Otherwise compute $y=ax+b\pmod q$. The Euclidean algorithm tests validity in time polynomial in $\log q$; standard integer multiplication and reduction then evaluate the map. An inverse can be obtained from the extended Euclidean algorithm.

The validation step is necessary. Merely testing $a\not\equiv0\pmod q$ is correct only when $q$ is prime.

### 9.2 Sampling a uniform unit

Repeatedly choose $a$ uniformly from $\{0,\ldots,q-1\}$ and accept exactly when $\gcd(a,q)=1$. Conditional on acceptance, the result is uniform among the units because every residue had equal proposal probability. The expected number of proposals is $q/\varphi(q)$.

If the prime-power factorization of $q$ is available, one can instead sample a unit independently in each Chinese-remainder component and reconstruct the global residue. This makes the componentwise structure explicit, although reconstruction and factorization availability affect practical cost.

### 9.3 Numerical verification of sum invariance

For a finite list $f(0),\ldots,f(q-1)$, evaluate

$$
S=\sum_{x=0}^{q-1}f(x)
$$

and

$$
S_{a,b}=\sum_{x=0}^{q-1}f((ax+b)\bmod q).
$$

If $\gcd(a,q)=1$, Theorem 4.1 guarantees equality. If $a$ is not a unit, equality can fail because outputs repeat. This computation is a useful diagnostic: it displays the exact loss of permutation structure for zero divisors.

## 10. Applications to LWE reductions

The results have three direct roles in arbitrary-modulus LWE reasoning.

First, the Affine Permutation Criterion specifies the legal rerandomizers. Whenever a hybrid modifies a uniform modular variable by $x\mapsto ax+b$, the multiplier must be sampled from $R_q^\times$. This prevents collisions that could create an artificial oracle signal.

Second, the Sum Invariance Theorem proves uniformity in a form broad enough for every decision statistic. Instead of checking one distinguisher at a time, one proves that the transformed random variable has exactly the same distribution.

Third, the residue-wise advantage bound quantifies the local signal available to a guessing step. Once the endpoint gap is decomposed into $q$ candidate contributions, one candidate retains at least a $1/q$ share.

The Chinese-remainder theorems suggest a modular architecture for reductions at general $q$. Factor the ring into prime-power components, analyze the induced sample and error marginals, and replace components in a hybrid chain. The algebra of units already commutes with this decomposition. What remains is to establish that the LWE and uniform distributions, including their error behavior, interact with the same decomposition in the required way.

These statements should not be conflated with an unconditional equivalence of every conceivable Search-LWE and Decision-LWE formulation. LWE hardness depends on parameter regimes, error distributions, sample access, secret distributions, and oracle models. The universal results here remove the central affine algebra obstruction and provide exact finite bookkeeping; a complete reduction must instantiate and prove the remaining probabilistic claims.

## 11. Discussion

The key conceptual shift is from field language to ring language. Over a field, “nonzero” is a proxy for “invertible.” Composite rings reveal that the actual property used by the proof was invertibility all along. Once this is stated correctly, the surrounding theory becomes systematic.

The totient count also separates correctness from efficiency. Correctness says that only units may be used. Efficiency asks how costly it is to obtain one. The ratio $\varphi(q)/q$ answers the second question exactly. It is constant for powers of a fixed prime, so the correction does not impose a growing rejection cost in that important regime. Moduli with many distinct small prime factors have lower unit density and require more care.

The Chinese Remainder Theorem makes the unit condition local. This is valuable because prime powers are the natural irreducible blocks for modular arithmetic. Yet prime powers are not fields when the exponent exceeds one. Their chain of ideals carries more structure than a prime field, motivating digitwise rather than one-shot secret recovery.

Finally, the pigeonhole theorem is elementary but essential. Hybrid arguments often hide their quantitative loss in prose. Writing the finite sum explicitly exposes the denominator and the hypotheses. In particular, it prevents an invalid inference from a total gap to every residue; the conclusion guarantees only the existence of at least one sufficiently large contribution unless additional structure identifies it algorithmically.

## 12. Future work

A first direction is a full distributional Chinese-remainder hybrid. If

$$
q=\prod_{j=1}^r p_j^{e_j},
$$

one may replace the $r$ components one at a time. If the endpoint distinguishing gap is $\delta$, a telescoping or triangle-inequality argument should force one adjacent pair to differ by at least $\delta/r$, provided the error distribution has compatible component marginals. This would lift componentwise unit algebra to componentwise LWE distributions.

A second direction is digitwise recovery for $q=p^e$. The ideal chain

$$
(p^{e-1})\subset\cdots\subset(p)\subset R_{p^e}
$$

has successive quotients isomorphic to $R_p$. A reduction may therefore expose one base-$p$ digit of a secret coordinate per layer while using units in the ambient ring. Establishing this program requires precise stability conditions on the error distribution under reduction modulo $p^k$.

A third direction concerns sharp rerandomization cost. The identity

$$
\frac{\varphi(q)}q=\prod_{p\mid q}\left(1-\frac1p\right)
$$

shows that distinct small prime factors drive the density downward. Classical analytic estimates suggest a worst-family scale of order $1/\log\log q$ for the density, and hence $\log\log q$ for rejection cost, while fixed-prime powers retain constant expected cost. Connecting such estimates to concrete reduction complexity would make the quantitative role of the modulus fully explicit.

## 13. Conclusion

Affine rerandomization over $R_q$ is lossless exactly when its multiplier is a unit. This criterion is equivalent to coprimality with $q$, preserves every sum and average over the residue ring, admits exactly $\varphi(q)$ choices, and factors over coprime Chinese-remainder components. A finite hybrid then guarantees a contribution of at least $\delta/q$ among $q$ candidate residues whenever their total is at least $\delta$. The prime-modulus theory is recovered because nonzero residues and units coincide in a field.

Together, these results give the correct algebraic and quantitative language for arbitrary-modulus LWE search-to-decision analysis. They explain precisely why the naive prime-field substitution fails, how to repair it, how much the repair costs, and how the repaired structure decomposes. The remaining challenge is distributional: integrating this universal scaffold with concrete LWE error laws and oracle experiments to obtain complete reductions for the parameter families used in cryptography.
