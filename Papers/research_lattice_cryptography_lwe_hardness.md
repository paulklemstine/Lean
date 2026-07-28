# Operational Statistical Security and Affine Uniformity for Finite LWE Hybrids

**Aristotle**  
**July 28, 2026**

## Abstract

This paper develops two elementary but reusable foundations for finite game-based analyses of Learning With Errors and ring-based variants. First, for probability mass functions on a finite transcript space, we prove that the difference in expectation of every test valued in $[0,1]$ is bounded by the unnormalized $\ell^1$ distance between the distributions. Deterministic Boolean distinguishers follow as a special case. We then prove a common-ideal hybrid theorem: if each of two challenge ensembles is within respective errors $\varepsilon_0$ and $\varepsilon_1$ of one ideal ensemble, then every deterministic Boolean adversary has acceptance-probability advantage at most $\varepsilon_0+\varepsilon_1$. Second, we establish an algebraic uniformity principle for finite commutative rings. If the public multiplier $a$ is a unit, then the affine map $s\mapsto as+e$ is a permutation for every fixed error $e$; consequently, affine sampling preserves the uniform distribution and preserves sums of arbitrary real-valued statistics. We give proofs, executable finite algorithms, examples over residue rings, applications to hybrid arguments, and a precise account of scope. These results supply the operational and ring-theoretic links needed in broader LWE security developments, without asserting a full worst-case lattice reduction or a complete encryption theorem.

## 1. Introduction

Learning With Errors (LWE) and its structured variants use noisy linear relations as the basis for cryptographic constructions. Their security analyses repeatedly move between three levels of description. At the distributional level, one compares transcript ensembles. At the operational level, one asks how much an observer’s behavior can differ between two experiments. At the algebraic level, one exploits transformations that preserve uniform randomness.

A rigorous game argument must connect these levels. A bound such as “the real experiment is close to the ideal experiment” becomes cryptographically meaningful only after it bounds the success of distinguishers. Likewise, an assertion that an algebraic expression is uniform must rest on a precise reason, such as the expression being a permutation of a uniformly sampled domain.

We treat these connections in a finite model. Let $\Omega$ be a finite transcript space. Probability distributions are represented explicitly by mass functions. Their discrepancy is measured by the unnormalized $\ell^1$ gap

$$
\Delta_1(P,Q)=\sum_{x\in\Omega}|P(x)-Q(x)|.
$$

The first main result is an operational inequality. For every $t:\Omega\to[0,1]$,

$$
|\mathbb{E}_P[t]-\mathbb{E}_Q[t]|\le\Delta_1(P,Q).
$$

Indicator tests yield deterministic Boolean distinguishers. Combining the inequality with the triangle inequality through a common ideal distribution gives an immediate hybrid-security theorem.

The second main result concerns a finite commutative ring $R$. For $a,e\in R$, consider

$$
T_{a,e}(s)=as+e.
$$

If $a$ is a unit, multiplication by $a$ and translation by $e$ are both bijective; hence their composition is bijective. Uniform input therefore produces uniform output, and every finite sum may be reindexed through $T_{a,e}$.

The paper’s contribution is deliberately focused. It does not prove the decisional hardness of LWE, Regev’s quantum worst-case reduction, the correctness or chosen-plaintext security of a complete Dual-Regev scheme, or a cyclotomic ring-LWE reduction. Instead, it establishes the exact finite statistical and algebraic statements that can serve as components in those larger programs. This distinction prevents an operational lemma from being mistaken for a computational hardness theorem.

The remainder is organized as follows. Section 2 defines finite experiments and their distance. Section 3 proves the bounded-test and Boolean-distinguisher inequalities. Section 4 develops the common-ideal game hop. Section 5 proves affine uniformity over finite commutative rings. Section 6 gives algorithms and examples. Section 7 discusses cryptographic applications and limitations, and Section 8 presents future research directions.

## 2. Finite experiments and statistical distance

### 2.1 Probability mass functions

Let $\Omega$ be a nonempty finite set. A **finite probability mass function** on $\Omega$ is a function $P:\Omega\to\mathbb{R}$ satisfying

$$
P(x)\ge0\quad\text{for all }x\in\Omega,
\qquad
\sum_{x\in\Omega}P(x)=1.
$$

The nonnegativity and normalization conditions make $P(x)$ the probability assigned to transcript $x$. All arguments below are finite sums; no measure-theoretic limiting operations are required.

### 2.2 The unnormalized $\ell^1$ gap

For two finite probability mass functions $P$ and $Q$ on $\Omega$, define their **$\ell^1$ gap** by

$$
\Delta_1(P,Q)=\sum_{x\in\Omega}|P(x)-Q(x)|.
$$

This quantity is symmetric and nonnegative. It vanishes exactly when the two mass functions agree pointwise. Since $|u-v|\le u+v$ for nonnegative $u$ and $v$,

$$
0\le\Delta_1(P,Q)\le2.
$$

The conventional total variation distance on a finite space is

$$
\operatorname{TV}(P,Q)=\frac12\Delta_1(P,Q).
$$

We retain $\Delta_1$ because it arises directly from summing pointwise absolute differences. This normalization yields a valid but sometimes non-tight operational bound. In particular, the sharp Boolean bound is naturally expressed using total variation; sharpening the normalization is discussed later.

### 2.3 Encryption experiments

A **binary encryption experiment** on $\Omega$ consists of two probability mass functions $E_0$ and $E_1$, corresponding to challenge bits $0$ and $1$. The transcript includes all information exposed to an adversary: public parameters, public keys, challenge ciphertexts, oracle replies if already folded into a finite transcript, and any other observable outputs.

A **common ideal experiment** is another probability mass function $I$ on $\Omega$ against which both challenge distributions are compared. The ideal need not arise from the original encryption algorithm. Its purpose is to provide a tractable intermediate distribution.

### 2.4 Tests and expectations

A **bounded test** is a function $t:\Omega\to\mathbb{R}$ satisfying

$$
0\le t(x)\le1
$$

for every $x\in\Omega$. Its expectation under $P$ is

$$
\mathbb{E}_P[t]=\sum_{x\in\Omega}P(x)t(x).
$$

A deterministic Boolean distinguisher is a map $A:\Omega\to\{0,1\}$. It determines an acceptance event

$$
S_A=\{x\in\Omega:A(x)=1\},
$$

and its acceptance probability is

$$
\Pr_{x\sim P}[A(x)=1]=\sum_{x\in S_A}P(x).
$$

The indicator $\mathbf{1}_{S_A}$ is a bounded test, so Boolean distinguishers are a special case of the test formalism.

## 3. Operational interpretation of the $\ell^1$ gap

### 3.1 Bounded tests

**Theorem 3.1 (Bounded-Test Inequality).** Let $P$ and $Q$ be probability mass functions on a finite set $\Omega$. If $t:\Omega\to[0,1]$, then

$$
\left|\mathbb{E}_P[t]-\mathbb{E}_Q[t]\right|
\le
\Delta_1(P,Q).
$$

**Proof.** Expand the expectations and combine the sums:

$$
\mathbb{E}_P[t]-\mathbb{E}_Q[t]
=
\sum_{x\in\Omega}\bigl(P(x)-Q(x)\bigr)t(x).
$$

Apply the triangle inequality for a finite sum:

$$
\left|\sum_{x\in\Omega}\bigl(P(x)-Q(x)\bigr)t(x)\right|
\le
\sum_{x\in\Omega}|P(x)-Q(x)|\,|t(x)|.
$$

Because $t(x)\in[0,1]$, one has $|t(x)|=t(x)\le1$. Therefore

$$
\sum_{x\in\Omega}|P(x)-Q(x)|\,|t(x)|
\le
\sum_{x\in\Omega}|P(x)-Q(x)|
=
\Delta_1(P,Q).
$$

This proves the claim. $\square$

The theorem gives $\Delta_1$ an operational interpretation. A bound on the aggregate pointwise discrepancy simultaneously controls every score function with range $[0,1]$. No optimization over tests is required in order to apply the result.

The nonnegativity of the test is relevant to the stated constant. If one instead allowed $t(x)\in[-1,1]$, the same proof would still give the identical $\ell^1$ upper bound because $|t(x)|\le1$. The present range is natural for acceptance probabilities and normalized payoffs.

### 3.2 Deterministic Boolean distinguishers

**Theorem 3.2 (Boolean Distinguisher Inequality).** Let $P$ and $Q$ be probability mass functions on a finite transcript space $\Omega$. For every deterministic map $A:\Omega\to\{0,1\}$,

$$
\left|
\Pr_{x\sim P}[A(x)=1]
-
\Pr_{x\sim Q}[A(x)=1]
\right|
\le
\Delta_1(P,Q).
$$

Equivalently,

$$
\left|
\sum_{\substack{x\in\Omega\\A(x)=1}}P(x)
-
\sum_{\substack{x\in\Omega\\A(x)=1}}Q(x)
\right|
\le
\Delta_1(P,Q).
$$

**Proof.** Define $t(x)=1$ if $A(x)=1$ and $t(x)=0$ otherwise. Then $t:\Omega\to[0,1]$, and its expectation under either distribution is exactly the corresponding acceptance probability. Theorem 3.1 applies. $\square$

A randomized distinguisher can also be accommodated when its private randomness is finite and independent of the challenge: either enlarge $\Omega$ to include the random coins, or define $t(x)$ as the conditional acceptance probability given transcript $x$. The latter lies in $[0,1]$, so Theorem 3.1 applies directly. The formal statement above remains focused on deterministic Boolean adversaries because that is the exact finite corollary needed here.

### 3.3 Normalization and sharpness

Theorem 3.2 is intentionally simple rather than sharp. For an event $S\subseteq\Omega$, normalization implies

$$
\sum_{x\in S}(P(x)-Q(x))
=-\sum_{x\notin S}(P(x)-Q(x)).
$$

Using positive and negative parts, one can prove the sharper characterization

$$
\sup_{S\subseteq\Omega}|P(S)-Q(S)|
=rac12\Delta_1(P,Q).
$$

That factor-$1/2$ theorem is not needed for the results proved here. All ensuing claims use the conservative $\Delta_1$ bound. This explicit choice avoids presenting the current inequality as optimal.

## 4. The common-ideal method

### 4.1 Distributional game hop

**Theorem 4.1 (Common-Ideal Gap Bound).** Let $E_0$, $E_1$, and $I$ be probability mass functions on the same finite transcript space $\Omega$. If

$$
\Delta_1(E_0,I)\le\varepsilon_0
\quad\text{and}\quad
\Delta_1(E_1,I)\le\varepsilon_1,
$$

then

$$
\Delta_1(E_0,E_1)\le\varepsilon_0+\varepsilon_1.
$$

**Proof.** For every $x\in\Omega$,

$$
E_0(x)-E_1(x)
=
\bigl(E_0(x)-I(x)\bigr)+\bigl(I(x)-E_1(x)\bigr).
$$

The scalar triangle inequality gives

$$
|E_0(x)-E_1(x)|
\le
|E_0(x)-I(x)|+|I(x)-E_1(x)|.
$$

Summing over $\Omega$ yields

$$
\Delta_1(E_0,E_1)
\le
\Delta_1(E_0,I)+\Delta_1(I,E_1).
$$

Symmetry gives $\Delta_1(I,E_1)=\Delta_1(E_1,I)$, and the two assumed bounds complete the proof. $\square$

The result is a two-hop hybrid argument. It generalizes immediately to a chain $H_0,H_1,\ldots,H_m$:

$$
\Delta_1(H_0,H_m)
\le
\sum_{i=0}^{m-1}\Delta_1(H_i,H_{i+1}).
$$

The present work isolates the common-ideal case because it directly models two challenge ensembles independently replaced by one ideal ensemble.

### 4.2 Operational security corollary

**Theorem 4.2 (Operational Common-Ideal Security).** Under the assumptions of Theorem 4.1, every deterministic Boolean adversary $A:\Omega\to\{0,1\}$ satisfies

$$
\left|
\Pr_{x\sim E_0}[A(x)=1]
-
\Pr_{x\sim E_1}[A(x)=1]
\right|
\le
\varepsilon_0+
\varepsilon_1.
$$

**Proof.** Theorem 3.2 bounds the acceptance-probability difference by $\Delta_1(E_0,E_1)$. Theorem 4.1 bounds that gap by $\varepsilon_0+\varepsilon_1$. Transitivity of the order relation proves the result. $\square$

This theorem is the complete operational pipeline:

1. identify a common ideal transcript distribution $I$;
2. prove a left replacement bound $\Delta_1(E_0,I)\le\varepsilon_0$;
3. prove a right replacement bound $\Delta_1(E_1,I)\le\varepsilon_1$;
4. add the errors;
5. conclude a bound for every deterministic Boolean adversary.

The theorem is information-theoretic. It does not restrict the adversary’s runtime. If the two replacement bounds are themselves derived from computational assumptions, then a computational reduction must state how those assumptions and runtime losses enter. Such a reduction is outside the theorem’s hypotheses and cannot be inferred from it alone.

### 4.3 Example

Take $\Omega=\{0,1,2,3\}$ and

$$
E_0=(0.27,0.23,0.25,0.25),
\quad
I=(0.25,0.25,0.25,0.25),
\quad
E_1=(0.24,0.26,0.23,0.27).
$$

Then

$$
\Delta_1(E_0,I)=0.04,
\qquad
\Delta_1(E_1,I)=0.06.
$$

Thus $\Delta_1(E_0,E_1)\le0.10$. Direct calculation gives

$$
\Delta_1(E_0,E_1)
=0.03+0.03+0.02+0.02=0.10,
$$

so the common-ideal bound is attained in this example. Every deterministic acceptance set consequently has advantage at most $0.10$ under the chosen normalization.

## 5. Affine uniformity in finite commutative rings

### 5.1 Units and affine maps

Let $R$ be a commutative ring. An element $a\in R$ is a **unit** if there exists $b\in R$ such that

$$
ab=ba=1.
$$

The element $b$, uniquely determined, is denoted $a^{-1}$. For fixed $a,e\in R$, define the affine map

$$
T_{a,e}:R\to R,
\qquad
T_{a,e}(s)=as+e.
$$

The multiplier $a$ represents a public ring coefficient, $s$ a uniformly sampled ring element, and $e$ a fixed error or offset.

### 5.2 Multiplication by a unit

**Lemma 5.1 (Unit Multiplication Is Bijective).** If $a$ is a unit in a commutative ring $R$, then the map $M_a(s)=as$ is a bijection from $R$ to $R$.

**Proof.** Let $a^{-1}$ be the inverse of $a$. The map $M_{a^{-1}}(y)=a^{-1}y$ is an inverse for $M_a$ because

$$
M_{a^{-1}}(M_a(s))=a^{-1}(as)=(a^{-1}a)s=s
$$

and

$$
M_a(M_{a^{-1}}(y))=a(a^{-1}y)=(aa^{-1})y=y.
$$

Hence $M_a$ is bijective. $\square$

### 5.3 Affine permutation theorem

**Theorem 5.2 (Affine Permutation by a Unit).** Let $R$ be a commutative ring, let $a\in R$ be a unit, and let $e\in R$ be arbitrary. Then

$$
T_{a,e}(s)=as+e
$$

is a bijection of $R$. Its inverse is

$$
T_{a,e}^{-1}(y)=a^{-1}(y-e).
$$

**Proof.** By Lemma 5.1, multiplication by $a$ is bijective. Translation $z\mapsto z+e$ is bijective, with inverse $y\mapsto y-e$. The affine map is the composition of these two bijections and is therefore bijective. Substituting directly verifies the displayed inverse. $\square$

No finiteness assumption is needed for bijectivity itself. Finiteness enters when interpreting the map as preserving a uniform probability distribution and when forming sums over all ring elements.

### 5.4 Uniformity and reindexing

Assume now that $R$ is finite. The uniform mass function is

$$
U_R(y)=\frac1{|R|}
$$

for every $y\in R$.

**Corollary 5.3 (Affine Uniformity).** If $S$ is uniformly distributed on a finite commutative ring $R$, $a$ is a unit, and $e\in R$ is fixed, then $aS+e$ is uniformly distributed on $R$.

**Proof.** By Theorem 5.2, every $y\in R$ has exactly one preimage $a^{-1}(y-e)$. Therefore

$$
\Pr[aS+e=y]
=
\Pr[S=a^{-1}(y-e)]
=
\frac1{|R|}.
$$

This is the uniform mass at $y$. $\square$

**Theorem 5.4 (Affine Reindexing of Statistics).** Let $R$ be a finite commutative ring, let $a$ be a unit, let $e\in R$, and let $f:R\to\mathbb{R}$ be arbitrary. Then

$$
\sum_{s\in R}f(as+e)=\sum_{y\in R}f(y).
$$

**Proof.** Theorem 5.2 makes $T_{a,e}$ a permutation of the finite set $R$. Reindex the left-hand sum by $y=T_{a,e}(s)$. Since each $y$ occurs exactly once, the reindexed sum is the right-hand side. $\square$

Dividing by $|R|$ yields equality of expectations:

$$
\mathbb{E}[f(aS+e)]=\mathbb{E}[f(U)],
$$

where $S$ and $U$ are uniform on $R$. Since this holds for every real-valued statistic $f$, it expresses exact equality of distributions.

### 5.5 Why the unit hypothesis matters

Consider $R=\mathbb{Z}/8\mathbb{Z}$. The units are the odd residue classes $1,3,5,7$. For $a=3$ and $e=2$, the sequence

$$
3s+2\pmod8,
\qquad s=0,1,\ldots,7,
$$

is

$$
2,5,0,3,6,1,4,7,
$$

which lists every residue exactly once.

For the nonunit $a=2$ and the same $e=2$, the outputs are

$$
2,4,6,0,2,4,6,0.
$$

Only four residues occur, each twice. The output is not uniform on the whole ring. Translation changes the coset reached but cannot restore injectivity lost under multiplication.

Over $\mathbb{Z}/q\mathbb{Z}$, multiplication by $a$ is invertible exactly when $\gcd(a,q)=1$. Thus the unit test can be implemented using the Euclidean algorithm.

## 6. Algorithms and numerical demonstrations

### 6.1 Computing the $\ell^1$ gap

Given arrays $p=(p_1,\ldots,p_n)$ and $q=(q_1,\ldots,q_n)$ representing mass functions, compute

$$
\Delta_1(p,q)=\sum_{i=1}^n|p_i-q_i|.
$$

The algorithm uses $O(n)$ arithmetic operations and $O(1)$ auxiliary space beyond the input. Before interpreting the result probabilistically, implementations should check nonnegativity and that each array sums to $1$ within an appropriate numerical tolerance.

### 6.2 Evaluating a bounded test

For a test vector $t=(t_1,\ldots,t_n)$ with $0\le t_i\le1$, compute

$$
\mathbb{E}_p[t]=\sum_i p_it_i,
\qquad
\mathbb{E}_q[t]=\sum_i q_it_i.
$$

Then compare $|\mathbb{E}_p[t]-\mathbb{E}_q[t]|$ with $\Delta_1(p,q)$. This also costs $O(n)$ time. For a Boolean adversary, each $t_i$ is $0$ or $1$.

### 6.3 Verifying affine permutations modulo $q$

For integers $a,e,q$ with $q>1$, enumerate

$$
y_s=(as+e)\bmod q
$$

for $s=0,\ldots,q-1$. The map is a permutation exactly when all $q$ outputs are distinct. Enumeration takes $O(q)$ modular operations and $O(q)$ storage with a Boolean seen-table. A mathematically faster criterion for this residue ring is $\gcd(a,q)=1$, computable in $O(\log q)$ division steps, but enumeration exposes the output histogram and therefore provides a more illustrative demonstration.

### 6.4 Mixtures over random errors

Although Theorem 5.2 fixes $e$, it implies a useful probabilistic extension. Suppose $S$ is uniform on finite $R$, $E$ is any independent $R$-valued random variable, and $a$ is a unit. Conditioning on $E=e$, Corollary 5.3 says $aS+e$ is uniform. Averaging these identical conditional distributions gives

$$
\Pr[aS+E=y]=\sum_e\Pr[E=e]\frac1{|R|}=\frac1{|R|}.
$$

Thus independent random error also preserves uniformity in this setting. Independence is essential to this conditioning argument; if $E$ depends on $S$, cancellation such as $E=-aS$ can make the output constant.

## 7. Cryptographic applications, interpretation, and scope

### 7.1 Hybrid arguments for encryption

In an indistinguishability experiment, $E_0$ and $E_1$ encode the adversary’s view for two challenge messages or bits. Direct comparison may be difficult because both distributions contain correlated algebraic structure. A proof can instead define an ideal distribution $I$ in which selected components have been replaced by uniform values. If decisional assumptions or statistical estimates supply

$$
\Delta_1(E_b,I)\le\varepsilon_b
$$

for $b\in\{0,1\}$, Theorem 4.2 immediately gives adversarial advantage at most $\varepsilon_0+\varepsilon_1$.

The theorem cleanly separates two obligations. Scheme-specific work proves the replacement bounds. Generic probability theory converts them to an operational conclusion. This separation helps prevent an informal leap from “these distributions are close” to “the adversary cannot distinguish.”

### 7.2 Ring-LWE-style affine samples

Ring-based constructions manipulate expressions resembling $as+e$. Theorem 5.2 identifies a regime of perfect uniformity: if $s$ is uniform over the entire finite ring and $a$ is a unit, then for each fixed $e$ the result is uniform. In a hybrid proof, such a term may be replaced by a fresh uniform ring element at zero statistical cost.

However, this statement must not be overextended. Standard ring-LWE formulations often sample secrets and errors from narrow distributions rather than uniformly from the full ring. Public multipliers may also be sampled without conditioning on being units. In those settings the theorem does not automatically apply. One must analyze the actual sampling distributions, the probability of nonunits, module structure, or computational assumptions.

### 7.3 Exact versus approximate replacements

The two principal results distinguish exact and approximate reasoning. Affine reindexing under a unit is exact: the transformed uniform distribution equals the original uniform distribution, so the corresponding $\ell^1$ gap is $0$. A computational or noisy replacement elsewhere may have positive error $\varepsilon$. Hybrid accounting adds only the nonzero errors.

This distinction is useful in proof design. Algebraic permutations should be recognized early, because charging a statistical error for an exact relabeling weakens the final bound unnecessarily. Conversely, a merely plausible resemblance to uniformity should not be labeled exact without a bijection or another complete argument.

### 7.4 Relationship to LWE hardness

The present theorems are compatible with the broader program of lattice cryptography but are not themselves an LWE hardness proof. A reduction from worst-case lattice problems such as GapSVP or SIVP to LWE requires Euclidean lattice geometry, discrete Gaussians, smoothing parameters, dual lattices, and—in Regev’s original route—quantum sampling and measurement arguments. None of those structures follows from finite $\ell^1$ inequalities or affine ring permutations.

Likewise, a complete Dual-Regev chosen-plaintext security theorem requires concrete key generation, encryption, decryption, a correctness analysis for noise and rounding, and an explicit reduction connecting each game transition to decisional LWE. The common-ideal theorem is one generic endpoint for the game analysis, not a substitute for those scheme-specific components.

### 7.5 Limitations of the finite model

The finite model is appropriate for concrete transcript spaces and finite rings, but it omits several issues:

- continuous or countably infinite distributions require measure-theoretic integration;
- adaptive interaction may be more naturally modeled by probability kernels or probabilistic programs;
- floating-point numerical demonstrations approximate real-valued masses and require tolerance checks;
- deterministic distinguishers cover randomized ones only after incorporating or averaging their independent coins;
- the unnormalized $\ell^1$ bound loses the sharp factor $1/2$ available for Boolean events.

These limitations are explicit boundaries, not defects in the statements. Within their hypotheses, the theorems give complete conclusions.

## 8. Future directions

The completed results establish two reusable foundations: an operational bound translating finite $\ell^1$ game distance into advantage for every bounded or Boolean distinguisher, and affine uniformity over arbitrary commutative rings when the multiplier is a unit. Natural next steps are the following.

1. **Concrete Dual-Regev syntax and correctness.** Define key generation, encryption, and decryption over $\mathbb{Z}/q\mathbb{Z}$; connect noise and rounding estimates to a full correctness theorem.
2. **Probabilistic programs.** Replace explicit finite mass functions by probability kernels, proving that pushforward and product constructions agree with the finite model.
3. **Full IND-CPA reduction.** Instantiate the common-ideal hypotheses with a decisional-LWE oracle reduction and account explicitly for every hybrid hop.
4. **Cyclotomic ring-LWE.** Specialize the generic finite commutative-ring theorem to quotients $(\mathbb{Z}/q\mathbb{Z})[X]/(\Phi_m)$, characterize units, and define coefficient and canonical embeddings with discrete Gaussian error.
5. **Lattice geometry.** Develop actual Euclidean lattices, dual lattices, smoothing parameters, Gaussian mass bounds, and transference inequalities.
6. **Quantum reduction.** Develop quantum Fourier sampling and connect bounded-distance decoding to worst-case GapSVP and SIVP. This requires quantum-circuit and measurement semantics beyond the finite game arguments considered here.
7. **Sharper normalization.** Prove the standard factor-$1/2$ total-variation characterization as a supremum over events, yielding tight Boolean distinguishing bounds rather than the deliberately simple $\ell^1$ upper bound.

## 9. Conclusion

Finite game-based security requires a disciplined passage from distributions to adversaries. The Bounded-Test Inequality proves that every $[0,1]$-valued statistic changes by at most the $\ell^1$ gap. The Boolean Distinguisher Inequality specializes this fact to acceptance probabilities. The Common-Ideal Gap Bound and its operational corollary show that two challenge worlds independently close to one ideal world are indistinguishable up to the sum of their errors.

Finite ring algebra supplies an exact companion principle. Multiplication by a unit is reversible, translation is reversible, and therefore $s\mapsto as+e$ is a permutation. Uniformity and all finite statistic sums are preserved under this affine transformation.

Together, these results provide a compact interface for larger LWE and ring-LWE arguments: exact algebraic symmetries can justify zero-cost replacements, while approximate distributional replacements translate into explicit universal bounds on distinguishing advantage. Their hypotheses and limitations also identify precisely what remains to be supplied by a full cryptographic construction or hardness reduction.
