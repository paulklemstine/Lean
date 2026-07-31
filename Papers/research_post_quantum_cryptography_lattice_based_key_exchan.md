# Reconciliation and Common-Ideal Forward Secrecy in Finite LWE Key-Exchange Models

**Aristotle**  
**July 31, 2026**

## Abstract

This paper develops three self-contained components of an analysis of Learning With Errors key exchange. First, it introduces finite probability models for post-compromise protocol views and proves that closeness of both challenge branches to a common, challenge-independent ideal distribution implies quantitative forward secrecy. If the two hybrid losses are $\varepsilon_0$ and $\varepsilon_1$, the resulting $\ell^1$ distinguishing gap is at most $\varepsilon_0+\varepsilon_1$; equal branch losses $\varepsilon$ therefore yield a bound of $2\varepsilon$. Second, it proves a deterministic reconciliation criterion: if $m$ integer errors have magnitude at most $B$ and $4mB<q$, then their sum lies strictly inside the quarter-modulus decoding radius. Third, it checks a concrete profile with dimension $512$, prime modulus $12289$, $1024$ accumulated errors, and bound $3$. Here $4\cdot1024\cdot3=12288<12289$, so every admissible error vector satisfies the reconciliation criterion, while the raw secret-vector space has at least $2^{128}$ elements. The latter is explicitly interpreted only as a combinatorial parameter check, not as a complete concrete-security estimate. The results separate unconditional probability and arithmetic facts from the computational assumptions needed in a complete LWE protocol proof.

## 1. Introduction

Learning With Errors (LWE) turns approximate modular linear equations into a foundation for post-quantum cryptography. A typical sample consists of a public vector $a$, a secret vector $s$, and a value

$$
b=\langle a,s\rangle+e\pmod q,
$$

where $e$ is a small error. The error prevents direct recovery by ordinary linear algebra, while its smallness permits honest parties to reconcile nearby modular values. This dual role gives rise to two distinct proof obligations.

The first obligation is **correctness**. The protocol combines several noisy terms, and the resulting accumulated error must remain inside a decoding region. The present treatment uses a strict quarter-modulus condition. It is deterministic: every coordinatewise bounded error vector is covered.

The second obligation is **security after static-key compromise**. Once a long-term secret is exposed, the two challenge-session experiments should remain close. Hybrid arguments often establish this by replacing each challenge branch with a common ideal distribution. The essential mathematical step is then an $\ell^1$ triangle inequality.

This paper isolates these obligations without overstating their consequences. It proves:

1. the triangle inequality for finite-view $\ell^1$ gaps;
2. a common-ideal theorem yielding forward-secrecy loss $\varepsilon_0+\varepsilon_1$;
3. the symmetric corollary with loss $2\varepsilon$;
4. the accumulated error bound $|\sum_i e_i|\le mB$;
5. the reconciliation criterion $4mB<q$;
6. primality and arithmetic checks for $n=512$, $q=12289$, $m=1024$, and $B=3$;
7. the raw keyspace lower bound $2^{128}\le12289^{512}$.

The common-ideal premises are intended to be discharged by post-exposure decisional-LWE hybrid arguments in a complete instantiation. They are assumptions here, not consequences of the finite-distribution geometry alone. Likewise, the keyspace lower bound is not equated with a $128$-bit attack cost.

## 2. LWE setting and reconciliation

### 2.1 Modular noisy linear equations

Fix a modulus $q\ge2$ and dimension $n\ge1$. Let vectors be taken over $\mathbb Z/q\mathbb Z$. An LWE sample associated with secret $s$ has the form $(a,b)$, where $a$ is sampled according to a specified public distribution and

$$
b=\langle a,s\rangle+e\pmod q.
$$

The error $e$ is drawn from a narrow distribution over integers and then interpreted modulo $q$. Search-LWE asks for recovery of $s$ from samples; decisional-LWE asks for distinguishing such samples from a suitable ideal distribution, usually uniform modular data. A complete cryptographic theorem must define security-parameter-indexed distribution ensembles, efficient adversaries, and negligible advantage. The finite model below abstracts the output views after the required game hops have been established.

### 2.2 Centered errors and the quarter-modulus radius

Modular differences may be represented by centered integers. A reconciliation rule is correct whenever the difference between the two parties’ pre-key values lies strictly within a decoding cell. In the present criterion, the safe cell has radius $q/4$. Thus an accumulated integer error $E$ is safe if

$$
4|E|<q.
$$

This formulation avoids division and makes strictness explicit. It also gives a simple interface between coordinatewise noise assumptions and decoding correctness.

### 2.3 Accumulated error theorem

**Theorem 2.1 (Accumulated Error Bound).**  
Let $m$ be a nonnegative integer, let $e_1,\ldots,e_m$ be integers, and let $B$ be an integer such that $|e_i|\le B$ for every $i$. Then

$$
\left|\sum_{i=1}^{m}e_i\right|\le mB.
$$

**Proof sketch.** The triangle inequality gives

$$
\left|\sum_{i=1}^{m}e_i\right|
\le\sum_{i=1}^{m}|e_i|.
$$

The coordinatewise assumptions imply $\sum_i|e_i|\le\sum_iB=mB$. Chaining the inequalities proves the claim. Notice that the assumptions force $B\ge0$ whenever $m>0$; when $m=0$, both sums are zero. $\square$

The theorem is deliberately worst-case. It does not exploit cancellation and therefore applies uniformly to all admissible error vectors.

### 2.4 Reconciliation margin theorem

**Theorem 2.2 (Strict Quarter-Modulus Reconciliation Margin).**  
Let $q,m$ be nonnegative integers, let $B$ be an integer, and let $e_1,\ldots,e_m$ be integers satisfying $|e_i|\le B$. If

$$
4mB<q,
$$

then

$$
4\left|\sum_{i=1}^{m}e_i\right|<q.
$$

Consequently, the accumulated error lies strictly inside the quarter-modulus radius.

**Proof sketch.** By Theorem 2.1,

$$
\left|\sum_i e_i\right|\le mB.
$$

Multiplication by the nonnegative integer $4$ preserves the weak inequality, giving

$$
4\left|\sum_i e_i\right|\le4mB<q.
$$

Transitivity yields the desired strict inequality. $\square$

This theorem supplies a sufficient condition, not a necessary one. Actual errors may cancel, allowing successful reconciliation even if $4mB\ge q$. The point of the theorem is uniform certainty under only coordinatewise bounds.

## 3. Finite probability models for exposed views

### 3.1 Finite distributions

Let $\Omega$ be a finite set of complete protocol views. A finite probability mass function $P$ on $\Omega$ is a function $P:\Omega\to\mathbb R$ satisfying

$$
P(x)\ge0\quad\text{for all }x\in\Omega,
$$

and

$$
\sum_{x\in\Omega}P(x)=1.
$$

The set $\Omega$ may encode transcripts, public randomness, revealed static secrets, adversarial outputs, and any other finite data included in an experiment.

### 3.2 The $\ell^1$ distinguishing gap

For finite distributions $P$ and $Q$ on $\Omega$, define

$$
\Delta_1(P,Q)=\sum_{x\in\Omega}|P(x)-Q(x)|.
$$

This quantity lies between $0$ and $2$. It is twice the conventional total variation distance. The scaling is immaterial for the structural results, but all bounds in this paper use the unnormalized $\ell^1$ convention.

The gap is symmetric because $|u-v|=|v-u|$. It is zero exactly when the two mass functions agree pointwise. Most importantly, it obeys a triangle inequality.

**Theorem 3.1 (Triangle Inequality for Finite Protocol Views).**  
For finite probability distributions $P,Q,R$ on the same finite set $\Omega$,

$$
\Delta_1(P,R)\le\Delta_1(P,Q)+\Delta_1(Q,R).
$$

**Proof sketch.** For every $x\in\Omega$, the scalar triangle inequality gives

$$
|P(x)-R(x)|
=|(P(x)-Q(x))+(Q(x)-R(x))|
\le|P(x)-Q(x)|+|Q(x)-R(x)|.
$$

Summing over the finite view space proves the result. $\square$

### 3.3 Post-compromise experiments

Let $\mathcal K$ be the set of static keys and let $\Omega$ be the finite set of complete exposed views. A **post-compromise experiment** assigns, to every static key $k\in\mathcal K$ and challenge bit $b\in\{0,1\}$, a distribution $V_{k,b}$ on $\Omega$. The distribution is understood to describe everything visible after exposure of $k$, including the challenge session’s transcript and any experiment-specific auxiliary data.

**Definition 3.2 (Quantitative Forward Secrecy).**  
A post-compromise experiment is forward secure with $\ell^1$ loss at most $\varepsilon$ if, for every exposed static key $k$,

$$
\Delta_1(V_{k,0},V_{k,1})\le\varepsilon.
$$

This is a finite information-theoretic statement about the distributions supplied to the definition. In a computational protocol analysis, the distributions may represent games after conditioning or may be connected through efficient reductions. Such computational interpretation requires additional definitions beyond the finite inequality.

## 4. Common-ideal hybrid theorems

### 4.1 Asymmetric branch losses

The central security result passes through a distribution that is independent of the challenge bit.

**Theorem 4.1 (Forward Secrecy from a Common Ideal View).**  
Consider a post-compromise experiment with view distributions $V_{k,0}$ and $V_{k,1}$. Suppose that for every static key $k$ there is an ideal distribution $I_k$ on the same view space. The ideal may depend on $k$, but it does not depend on the challenge bit. If constants $\varepsilon_0$ and $\varepsilon_1$ satisfy

$$
\Delta_1(V_{k,0},I_k)\le\varepsilon_0
$$

and

$$
\Delta_1(V_{k,1},I_k)\le\varepsilon_1
$$

for every $k$, then the experiment is forward secure with loss at most $\varepsilon_0+\varepsilon_1$; that is,

$$
\Delta_1(V_{k,0},V_{k,1})\le\varepsilon_0+\varepsilon_1
$$

for every $k$.

**Proof sketch.** Fix $k$. Apply Theorem 3.1 with $P=V_{k,0}$, $Q=I_k$, and $R=V_{k,1}$:

$$
\Delta_1(V_{k,0},V_{k,1})
\le\Delta_1(V_{k,0},I_k)+\Delta_1(I_k,V_{k,1}).
$$

Symmetry gives $\Delta_1(I_k,V_{k,1})=\Delta_1(V_{k,1},I_k)$. The two hypotheses bound the right-hand side by $\varepsilon_0+\varepsilon_1$. Since $k$ was arbitrary, the statement holds after every static-key exposure. $\square$

The challenge independence of $I_k$ is essential. If one used unrelated ideals $I_{k,0}$ and $I_{k,1}$, closeness of each real branch to its own ideal would say nothing about the distance between the ideals.

### 4.2 Symmetric loss

**Corollary 4.2 (Symmetric LWE Hybrid Bound).**  
Under the setting of Theorem 4.1, suppose one constant $\varepsilon$ satisfies

$$
\Delta_1(V_{k,b},I_k)\le\varepsilon
$$

for every static key $k$ and both bits $b\in\{0,1\}$. Then

$$
\Delta_1(V_{k,0},V_{k,1})\le2\varepsilon
$$

for every $k$.

**Proof sketch.** Apply Theorem 4.1 with $\varepsilon_0=\varepsilon_1=\varepsilon$ and simplify $\varepsilon+\varepsilon=2\varepsilon$. $\square$

### 4.3 Cryptographic interpretation

In an LWE instantiation, a typical proof attempts to show that each real challenge branch is close to a common ideal experiment in which session-dependent LWE data have been replaced by challenge-independent data. The two hypotheses of Theorem 4.1 then correspond to two game hops justified by decisional LWE after static-key exposure.

The theorem performs the loss accounting once those hops are available. It does not establish decisional LWE, a worst-case reduction from GapSVP, or the security of a complete key-exchange protocol. A full computational claim must additionally specify:

- security-parameter-indexed ensembles;
- probabilistic polynomial-time adversaries and reductions;
- negligible functions;
- complete key generation and session algorithms;
- an active or passive network model;
- session partnering and freshness;
- erasure of ephemeral state;
- the timing and adaptivity of corruptions.

Thus the theorem is best viewed as a reusable bridge from branchwise LWE hybrids to a post-compromise conclusion.

## 5. Concrete parameter profile

### 5.1 Parameters

Consider

$$
n=512,\qquad q=12289,\qquad m=1024,\qquad B=3.
$$

Here $n$ is the secret-vector dimension, $q$ is the modulus, $m$ is the number of bounded error terms entering the reconciliation sum, and $B$ is the maximum magnitude of each integer error.

### 5.2 Prime modulus

**Proposition 5.1 (Primality of the Concrete Modulus).**  
The integer $12289$ is prime.

**Proof sketch.** A primality test needs only check divisibility by primes not exceeding $\sqrt{12289}<111$. Trial division by those primes finds no divisor, so $12289$ is prime. $\square$

Primality means that $\mathbb Z/12289\mathbb Z$ is a field. In particular, every nonzero residue has an inverse, a property used in standard prime-modulus affine rerandomization arguments.

### 5.3 Raw secret-space check

**Proposition 5.2 (Raw Keyspace Lower Bound).**  
The number of vectors in $(\mathbb Z/12289\mathbb Z)^{512}$ is at least $2^{128}$:

$$
2^{128}\le12289^{512}.
$$

**Proof sketch.** Since $2\le12289$, exponentiation gives $2^{128}\le12289^{128}$. Since $12289\ge1$ and $128\le512$, monotonicity in the exponent gives $12289^{128}\le12289^{512}$. $\square$

This proposition checks only cardinality. It must not be interpreted as a complete $128$-bit security theorem. Structured attacks can be much faster than exhaustive search, and their costs depend on the full LWE parameter set and attack model.

### 5.4 Concrete reconciliation inequality

**Proposition 5.3 (Concrete Strict Margin).**  
For $q=12289$, $m=1024$, and $B=3$,

$$
4mB<q.
$$

More explicitly,

$$
4\cdot1024\cdot3=12288<12289.
$$

**Proof sketch.** Direct integer arithmetic gives $1024\cdot3=3072$ and $4\cdot3072=12288$, which is one less than $12289$. $\square$

**Theorem 5.4 (Concrete Reconciliation Correctness).**  
Let $e_1,\ldots,e_{1024}$ be integers satisfying $|e_i|\le3$ for every $i$. Then

$$
4\left|\sum_{i=1}^{1024}e_i\right|<12289.
$$

Equivalently,

$$
\left|\sum_{i=1}^{1024}e_i\right|<\frac{12289}{4}.
$$

**Proof sketch.** Theorem 2.1 gives

$$
\left|\sum_{i=1}^{1024}e_i\right|\le1024\cdot3=3072.
$$

Therefore

$$
4\left|\sum_i e_i\right|\le4\cdot3072=12288<12289.
$$

This is also an immediate application of Theorem 2.2 and Proposition 5.3. $\square$

The worst-case margin is exact at integer scale: $q-4mB=1$. Consequently, increasing $B$ to $4$, increasing $m$, or decreasing $q$ can invalidate this particular uniform criterion. That sensitivity is useful for design exploration.

## 6. Algorithms

### 6.1 Deterministic reconciliation audit

The reconciliation theorem yields a constant-time parameter audit, excluding the time needed to read or validate an explicit error vector.

**Input:** integers $q,m,B$.  
**Output:** whether the sufficient condition $4mB<q$ holds, together with the scaled margin $q-4mB$.

The procedure computes $w=mB$, $s=4w$, and returns the predicate $s<q$. With arbitrary-precision integers of bit length $L$, a conservative schoolbook analysis gives $O(L^2)$ bit operations for multiplication, while multiplication by $4$ and comparison are linear in $L$. Modern multiplication improves this bound.

If an explicit vector is supplied, a second audit checks each $|e_i|\le B$, computes $E=\sum_i e_i$, and verifies $4|E|<q$. This takes $O(m)$ arithmetic operations and distinguishes the theorem’s worst-case certificate from the observed sum.

### 6.2 Finite hybrid-loss audit

For explicit finite mass functions $P,Q,R$, compute

$$
\Delta_1(P,Q)=\sum_x|P(x)-Q(x)|,
$$

and similarly for the other pairs. The algorithm verifies

$$
\Delta_1(P,R)\le\Delta_1(P,Q)+\Delta_1(Q,R)
$$

and reports the common-ideal upper bound. For a view space of size $N$, each gap costs $O(N)$ arithmetic operations and $O(1)$ auxiliary space beyond the distributions.

When probabilities are represented as binary floating-point numbers, equality and inequality checks should use a numerical tolerance. Exact rational masses remove rounding ambiguity at the cost of larger integer arithmetic.

## 7. Numerical examples

### 7.1 Worst-case aligned errors

If all $1024$ errors equal $3$, then

$$
E=1024\cdot3=3072,
$$

and

$$
4|E|=12288<12289.
$$

This saturates the accumulated-error upper bound while retaining the strict decoding margin.

### 7.2 Cancellation

If $512$ errors equal $3$ and $512$ equal $-3$, then $E=0$. The deterministic bound remains $|E|\le3072$, but the actual error is much smaller. This illustrates why the theorem is sufficient rather than necessary.

### 7.3 A common-ideal distribution

Take a two-element view space $\Omega=\{A,B\}$. Let

$$
V_0=(0.55,0.45),\qquad I=(0.50,0.50),\qquad V_1=(0.48,0.52).
$$

Then

$$
\Delta_1(V_0,I)=0.10,
$$

and

$$
\Delta_1(V_1,I)=0.04.
$$

The common-ideal theorem gives

$$
\Delta_1(V_0,V_1)\le0.14.
$$

Direct calculation yields

$$
\Delta_1(V_0,V_1)=|0.55-0.48|+|0.45-0.52|=0.14,
$$

so the triangle bound is tight in this example.

## 8. Design sensitivity and interpretation

The concrete profile sits at a sharp deterministic boundary. Its scaled margin is

$$
q-4mB=12289-12288=1.
$$

This means the sufficient certificate is sensitive to any increase in the worst-case budget. Holding $q=12289$ and $B=3$ fixed while increasing the count to $m=1025$ gives

$$
4\cdot1025\cdot3=12300>12289,
$$

so the uniform criterion no longer applies. Holding $m=1024$ fixed while increasing $B$ to $4$ similarly gives $16384>12289$.

Neither failed comparison proves that a particular exchange decodes incorrectly. The actual error sum may exhibit cancellation, and a probabilistic noise model may assign tiny probability to aligned extreme vectors. Rather, failure means that the assumptions $|e_i|\le B$ alone cannot certify every admissible vector. One must then enlarge $q$, reduce $m$ or $B$, exploit additional structure, or analyze a nonzero failure probability.

The common-ideal theorem has an analogous sensitivity. Its loss is additive and can be tight, as the two-point example shows. A long hybrid chain therefore requires explicit accounting for every hop. If $r$ successive replacements have gaps $\delta_1,\ldots,\delta_r$, repeated use of the triangle inequality gives total gap at most

$$
\sum_{j=1}^{r}\delta_j.
$$

This observation explains why protocol analyses seek economical hybrid sequences and negligible per-hop losses.

The ideal distribution may depend on the exposed key $k$. That is appropriate because the adversary receives $k$ in the experiment. It must not depend on the challenge bit: two separate ideals could be far apart even when each real branch is close to its own ideal. A shared ideal is what makes the two hybrid paths meet.

## 9. Applications and limitations

### 9.1 Protocol design

The reconciliation theorem provides a transparent design rule. Given a modulus and a bound on the number and magnitude of accumulated errors, a protocol designer can test whether all admissible vectors lie within the decoding radius. The rule is especially useful for conservative audits where deterministic correctness is preferred to a small decryption-failure probability.

### 9.2 Hybrid accounting

The common-ideal theorem modularizes security proofs. A protocol-specific analysis may focus on showing that each challenge branch is close to a bit-independent ideal view. The generic theorem then composes the losses and yields the post-compromise gap.

This separation also improves comparative analysis. Two protocol variants may use different transcript formats or reconciliation mechanisms while sharing the same finite-distribution argument once their real views reach a common ideal. Conversely, identical arithmetic parameters do not guarantee identical post-compromise security: the relevant question is whether exposure leaves session-specific data that prevent a challenge-independent replacement. The theorem therefore supplies an interface between protocol semantics and distributional accounting rather than a protocol-independent hardness claim.

### 9.3 Conservative implementation audits

An implementation can use the deterministic margin as a startup or configuration check. The check is simple enough to recompute from declared parameters and to report the signed quantity $q-4mB$, not merely a Boolean result. Reporting the margin makes boundary sensitivity visible and helps detect accidental changes in the number of terms or the noise bound. Such an audit does not replace constant-time programming, entropy validation, side-channel defenses, or failure-probability analysis; it certifies only the stated integer inequality.

### 9.4 Scope of the results

Several broader claims suggested by the general LWE program are not established by these results alone:

- no worst-case GapSVP- or SIVP-to-LWE reduction is proved here;
- no complete Regev encryption scheme or IND-CPA experiment is instantiated;
- no authenticated, active, multi-session key-exchange protocol is modeled;
- no polynomial-time or negligible-function framework is supplied;
- no concrete lattice-attack estimator justifies a $128$-bit work factor.

The results should therefore be read as exact lemmas and parameter checks that a larger analysis can use, rather than as an end-to-end security certification.

## 10. Future work

A full geometric reduction would replace abstract hardness interfaces with Euclidean lattices, dual lattices, successive minima, smoothing parameters, and discrete-Gaussian sampling, followed by the required transference estimates.

A full complexity-theoretic treatment would define search-LWE and decisional-LWE as distribution ensembles indexed by a security parameter, formalize efficient reductions and negligible functions, and connect algebraic rerandomization arguments to a reduction theorem.

For encryption, one would instantiate complete Regev key generation, encryption, and decryption distributions, prove correctness from explicit noise bounds, and justify every common-ideal IND-CPA game hop from decisional LWE.

For key exchange, one would add authentication, multiple sessions, partnering, active adversaries, ephemeral-state erasure, and adaptive corruption. The common-ideal assumptions would then need derivation from session-specific LWE assumptions.

Finally, the raw keyspace check should be replaced by a concrete estimator covering primal, dual, and decoding attacks, together with operation-cost models and decryption-failure analysis. Only then could one connect the minimum estimated work factor to a stated $128$-bit target.

## 11. Conclusion

The analysis establishes two reusable principles. Deterministically bounded errors reconcile whenever $4mB<q$, and finite post-compromise challenge views are within $\varepsilon_0+\varepsilon_1$ whenever both are respectively within $\varepsilon_0$ and $\varepsilon_1$ of one common ideal distribution. For $m=1024$, $B=3$, and prime modulus $q=12289$, the reconciliation condition becomes the exact strict inequality $12288<12289$. At dimension $512$, the raw vector space also exceeds $2^{128}$ elements.

These conclusions are mathematically precise and intentionally scoped. They explain how bounded noise supports correctness, how hybrid losses compose after exposure, and what the concrete arithmetic guarantees—while leaving the computational LWE reductions and complete protocol models as explicit future obligations.
