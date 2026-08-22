# The Cyclic Cubic Type Channel: Exact Full Pinning at Conductor 7 and its Exactly Quantified Failure for Semiprimes

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Let $K = \mathbb{Q}(\zeta_7 + \zeta_7^{-1})$ be the real cyclic cubic field of conductor $7$, the splitting field of $f(x) = x^3 + x^2 - 2x - 1$. We study the *decomposition-type channel* of $K$: the stochastic map sending the residue class of an unramified prime $p$ modulo $7$ to its splitting type $T(p) \in \{\text{split}, \text{inert}\}$, with $p \bmod 7$ distributed uniformly on the six invertible classes as predicted by Dirichlet's theorem. We prove four exact results.

1. **(Two types and a deterministic law.)** For every prime $p \neq 7$, $f$ has a root modulo $p$ — equivalently $p$ splits completely in $K$, with residue degree $1$ — if and only if $p \equiv \pm 1 \pmod 7$; otherwise $f$ is irreducible modulo $p$ and $p$ is inert with residue degree $3$. Only two types occur, and the type is a *function* of the residue.

2. **(Full pinning.)** The type entropy is $H(T) = \log_2 3 - 2/3 = 0.918296\ldots$ bits, and the mutual information satisfies $I(p \bmod 7 \,;\, T) = \log_2 3 - 2/3 = H(T)$ exactly. We give two independent proofs: a computational one from closed-form entropies, and a structural one from a general saturation principle stating that a joint law supported on the graph of a function attains the data-processing ceiling $I \le H(Y)$ with equality.

3. **(Exactly one label is destroyed by multiplication.)** For a semiprime $N = pq$ with independent uniform factors, the residue $N \bmod 7$ transmits only $I = \log_2 3 - 10/9 = 0.473852\ldots$ bits about the unordered pair of factor types, whose entropy is $2\log_2 3 - 16/9$. The deficit is exactly $H(T) = \log_2 3 - 2/3$: multiplication destroys precisely one type label's worth of entropy.

4. **(Which-factor blindness.)** The ordered pair of types has entropy $2\log_2 3 - 4/3$, exceeding the unordered entropy by exactly $4/9$ bits, yet the residue transmits exactly the same $\log_2 3 - 10/9$ bits about the ordered pair as about the unordered pair. The which-factor information is *exactly zero*, a consequence of an exact swap symmetry of the factorisation counts.

We also record a conductor-free mechanism behind (1): the companion matrix of $Y^2 - xY + 1$ realises an order-$m$ element of $SL_2(\mathbb{F}_p)$ precisely when $x$ is a root of the Chebyshev-type system $A_m(x) = 0$, $A_{m-1}(x) = -1$, and such an element exists if and only if $m \mid p^2 - 1$. Specialising recovers the Fibonacci/golden-ratio criterion at conductor $5$, the cubic criterion at conductor $7$, and the quintic criterion at conductor $11$.

**Keywords:** cyclic cubic field, splitting law, Chebotarev density, mutual information, Shannon entropy, semiprime, data-processing inequality, Chebyshev polynomials.

---

## 1. Introduction

### 1.1 Motivation

Splitting laws in abelian number fields are usually stated qualitatively: *the decomposition type of an unramified prime depends only on its residue class modulo the conductor*. That is a statement about determination. It says nothing about *how much* is determined, nor about how the determination degrades under natural operations on the input.

The present paper takes the quantitative view. We treat the map
$$p \longmapsto T(p) = \text{decomposition type of } p \text{ in } K$$
as a communication channel whose input is the residue $p \bmod m$ and whose output is the type, and we compute its Shannon-theoretic invariants exactly, in bits, for the simplest cyclic cubic field: $K = \mathbb{Q}(\zeta_7 + \zeta_7^{-1})$, conductor $7$.

Three phenomena emerge, and all three are exact rational-plus-$\log_2 3$ expressions rather than numerical approximations:

* the channel achieves its information-theoretic ceiling exactly (*full pinning*);
* replacing the prime input by a product of two primes causes a loss of information equal, on the nose, to one type entropy;
* the loss is *entirely* concentrated in the "which factor is which" coordinate, which loses all of its information while the multiset coordinate retains the maximum possible.

### 1.2 Summary of results

Write $\mathbb{F}_7^\times = (\mathbb{Z}/7\mathbb{Z})^\times$ and $H = \{1, 6\} = \{\pm 1\}$, the unique subgroup of index $3$.

| Quantity | Exact value | Decimal |
|---|---|---|
| $H(T)$, type entropy | $\log_2 3 - 2/3$ | $0.918296$ |
| $H(R)$, residue entropy | $1 + \log_2 3$ | $2.584963$ |
| $H(R, T)$, joint | $1 + \log_2 3$ | $2.584963$ |
| $I(R;T)$ | $\log_2 3 - 2/3$ | $0.918296$ |
| $H(S)$, unordered semiprime type pair | $2\log_2 3 - 16/9$ | $1.392147$ |
| $H(R_N, S)$, joint | $2\log_2 3 + 1/3$ | $3.503258$ |
| $I(R_N; S)$ | $\log_2 3 - 10/9$ | $0.473851$ |
| $H(T_p, T_q)$, ordered type pair | $2\log_2 3 - 4/3$ | $1.836592$ |
| $H(R_N, (T_p,T_q))$, joint | $2\log_2 3 + 7/9$ | $3.947703$ |
| $I(R_N; (T_p,T_q))$ | $\log_2 3 - 10/9$ | $0.473851$ |
| Which-factor information | $0$ | $0.000000$ |
| Semiprime deficit $H(S) - I(R_N;S)$ | $\log_2 3 - 2/3$ | $0.918296$ |

Numerical bounds are anchored by the integer inequalities $2^{1584} < 3^{1000} < 2^{1585}$, which give $1.584 < \log_2 3 < 1.585$ and hence $0.917 < H(T) < 0.919$ and $0.472 < I(R_N;S) < 0.475$.

### 1.3 Organisation

Section 2 fixes notation and the entropy formalism. Section 3 proves the arithmetic splitting law and its conductor-free generalisation. Section 4 develops the general information-theoretic lemmas (ceiling and saturation). Section 5 computes the single-prime channel. Section 6 computes the semiprime channel and the exact deficit. Section 7 proves which-factor blindness. Section 8 discusses the pinning–abelianness dichotomy, applications, and limitations. Section 9 lists open problems.

---

## 2. Notation and the entropy formalism

### 2.1 Entropy

For $x \in \mathbb{R}$ set
$$\eta(x) = -x\log_2 x \quad (x > 0), \qquad \eta(0) = 0,$$
and for a finite index set $\Lambda$ and weight function $w : \Lambda \to \mathbb{R}_{\ge 0}$ put
$$H(w) = \sum_{\lambda \in \Lambda} \eta\!\left(w(\lambda)\right).$$
When $w$ is a probability vector this is the usual Shannon entropy in bits. We use $H$ on non-normalised nonnegative weights as well; the only property we need beyond the probability case is the **merging inequality**:

> **Lemma 2.1 (Merging loses entropy).** For nonnegative reals $w_1, \ldots, w_k$ with $\sum_i w_i \le 1$,
> $$\eta\!\left(\textstyle\sum_i w_i\right) \le \sum_i \eta(w_i).$$

*Proof sketch.* Write $s = \sum_i w_i$. Since $w_i \le s$ and $\eta$ is monotone in the relevant range through the inequality $-\log_2 w_i \ge -\log_2 s$, one has $\eta(w_i) = w_i(-\log_2 w_i) \ge w_i(-\log_2 s)$ for each $i$, and summing gives $\sum_i \eta(w_i) \ge s(-\log_2 s) = \eta(s)$. $\square$

Everything downstream — the ceiling $I \le H$, and hence the notion of "pinning" — is a fibrewise application of Lemma 2.1.

### 2.2 Joint laws and mutual information

For finite sets $A$, $B$ and a nonnegative weight $w : A \times B \to \mathbb{R}_{\ge 0}$, write the marginals
$$w_A(a) = \sum_{b \in B} w(a,b), \qquad w_B(b) = \sum_{a\in A} w(a,b),$$
and define the mutual information
$$I(w) = H(w_A) + H(w_B) - H(w).$$
For a probability law this is the standard $I(X;Y)$.

### 2.3 The two combinatorial models

Throughout, "uniform prime model" means: the residue $R = p \bmod 7$ is uniform on the six invertible classes. This is Dirichlet's theorem on primes in arithmetic progressions (equivalently, Chebotarev for $\mathbb{Q}(\zeta_7)/\mathbb{Q}$) in its natural-density form; it is the correct asymptotic model for the type statistics of primes.

"Uniform semiprime model" means: $p, q$ are independent, each uniform on the six invertible classes, and the observer sees $R_N = pq \bmod 7$. All $36$ ordered pairs are equally likely, so the induced law on $(R_N, \cdot)$ has denominators dividing $36$.

---

## 3. The arithmetic layer: two types and a deterministic law

### 3.1 The defining cubic

**Definition 3.1.** $f(x) = x^3 + x^2 - 2x - 1$, and $K = \mathbb{Q}[x]/(f)$.

**Proposition 3.2 (Cyclotomic substitution).** For any field $L$ and any nonzero $y \in L$,
$$y^3\, f\!\left(y + y^{-1}\right) = 1 + y + y^2 + y^3 + y^4 + y^5 + y^6.$$

*Proof.* Expand $(y+y^{-1})^3 + (y+y^{-1})^2 - 2(y+y^{-1}) - 1$ and multiply by $y^3$. $\square$

**Corollary 3.3.** If $y^7 = 1$ and $y \neq 1$, then $y + y^{-1}$ is a root of $f$. In particular $\zeta_7 + \zeta_7^{-1} = 2\cos(2\pi/7)$ is a root, and $f$ is its minimal polynomial over $\mathbb{Q}$; $f$ is irreducible over $\mathbb{Q}$ (indeed already modulo $2$), so $K$ is a cubic field, and $K = \mathbb{Q}(\zeta_7+\zeta_7^{-1})$ is the real subfield of $\mathbb{Q}(\zeta_7)$, cyclic of degree $3$ over $\mathbb{Q}$.

### 3.2 Splitting is all-or-nothing

**Definition 3.4 (Frobenius twist).** On roots of $f$, set $\tau(x) = x^2 - 2$. This is the polynomial shadow of $\zeta + \zeta^{-1} \mapsto \zeta^2 + \zeta^{-2}$.

**Lemma 3.5.** Over any commutative ring, if $f(x) = 0$ then $f(x^2-2) = 0$. If moreover $7$ is invertible (more precisely, if $7 \neq 0$ in an integral domain containing $x$), then $x^2 - 2 \neq x$ and $(x^2-2)^2 - 2 \neq x$.

*Proof sketch.* The first assertion is a polynomial identity: $f(x^2-2)$ lies in the ideal generated by $f(x)$, verified by expansion. For the second, $x^2 - 2 = x$ would force $x$ to satisfy $x^2 - x - 2 = 0$ simultaneously with $f(x) = 0$; eliminating gives $7 = 0$. The third is the analogous elimination with $\tau^2$. $\square$

**Theorem 3.6 (All-or-nothing splitting).** Let $D$ be an integral domain with $7 \neq 0$. If $f$ has one root $x \in D$, then $f$ has three distinct roots $x$, $\tau(x)$, $\tau^2(x)$ in $D$ and splits completely:
$$f(X) = (X - x)(X - \tau(x))(X - \tau^2(x)).$$

*Proof.* By Lemma 3.5 the three elements are roots and pairwise distinct (distinctness of $\tau(x)$ and $\tau^2(x)$ follows by applying the argument to $\tau(x)$). A monic cubic with three distinct roots in a domain factors as stated. $\square$

Consequently, for a prime $p \neq 7$, the factorisation type of $f$ modulo $p$ is either "three linear factors" or "irreducible": the residue degrees are all $1$ or all $3$. There is no $1+2$ pattern. (This is of course consistent with $\mathrm{Gal}(K/\mathbb{Q}) \cong \mathbb{Z}/3$ having no elements of order $2$, but the argument above is elementary and self-contained.)

### 3.3 The splitting criterion

**Theorem 3.7 (Cyclic cubic splitting criterion).** Let $p \neq 7$ be prime. Then
$$\exists\, x \in \mathbb{F}_p:\ f(x) = 0 \iff p \equiv \pm 1 \pmod 7 .$$
Equivalently, $p$ splits completely in $K$ (residue degree $1$) iff $p \equiv \pm 1 \pmod 7$, and is inert (residue degree $3$) otherwise.

*Proof sketch.* ($\Leftarrow$, case $p \equiv 1$.) Then $\mathbb{F}_p^\times$ is cyclic of order $p - 1$ divisible by $7$, so it contains an element $y$ of order $7$; by Corollary 3.3, $x = y + y^{-1}$ is a root.

($\Leftarrow$, case $p \equiv -1$.) Now $\mathbb{F}_p$ has no element of order $7$, but $\mathbb{F}_{p^2}$ does, because $7 \mid p^2 - 1$. Take $y \in \mathbb{F}_{p^2}$ of order $7$ and set $x = y + y^{-1}$. The Frobenius $z \mapsto z^p$ sends $y \mapsto y^p = y^{-1}$ (as $p \equiv -1 \bmod 7$), hence fixes $x$; so $x \in \mathbb{F}_p$ and is a root of $f$.

($\Rightarrow$.) Suppose $f(x) = 0$ with $x \in \mathbb{F}_p$. Let $M = \begin{pmatrix} x & -1\\ 1 & 0\end{pmatrix}$, the companion matrix of $Y^2 - xY + 1$: $\det M = 1$, $\operatorname{tr} M = x$, and $M^2 = xM - I$. Iterating yields $M^{n+1} = A_{n+1}(x) M - A_n(x) I$ with the Chebyshev-type recursion $A_0 = 0$, $A_1 = 1$, $A_{n+2} = t A_{n+1} - A_n$. One computes $A_7(t) = t^6 - 5t^4 + 6t^2 - 1$ and $A_6(t) = t^5 - 4t^3 + 3t$, and checks the polynomial identities
$$A_7(t) = -f(t)\,f(-t), \qquad A_6(t) + 1 = f(t)\cdot\left(t^2 - t - 1\right),$$
so that $f(x) = 0$ forces $A_7(x) = 0$ and $A_6(x) = -1$, i.e. $M^7 = I$ while $M \neq I$: $M$ has order exactly $7$ in $SL_2(\mathbb{F}_p)$. A non-scalar element of $SL_2(\mathbb{F}_p)$ of order $m$ coprime to $p$ satisfies $m \mid p^2 - 1$ (its eigenvalues are primitive $m$-th roots of unity in $\mathbb{F}_{p^2}^\times$, a cyclic group of order $p^2-1$). Hence $7 \mid (p-1)(p+1)$, i.e. $p \equiv \pm 1 \pmod 7$. $\square$

**Definition 3.8 (Type map).** For a nonzero residue $r \in \mathbb{Z}/7$ define the residue degree
$$d(r) = \begin{cases} 1 & r \in \{1, 6\},\\ 3 & \text{otherwise},\end{cases}$$
and the Boolean type $T(r) = [\,d(r) = 1\,] = [\,r \in \{\pm 1\}\,]$.

**Corollary 3.9 (Only two types; determinism).** $d(r) \in \{1, 3\}$ for all $r$, and if $p \equiv q \pmod 7$ then $d(p) = d(q)$. The type of an unramified prime is a *function* of its residue class. This is the fact that drives everything in Sections 5–7.

### 3.4 The conductor-free mechanism

The proof of the hard direction never used $7$. Define, for a commutative ring $R$ and $t \in R$, the sequence $A_n(t)$ as above, and let $C(t) = \begin{pmatrix} t & -1\\ 1 & 0\end{pmatrix}$.

**Theorem 3.10 (Trace-order criterion).** Let $p$ and $m$ be primes with $m$ odd and $m \neq p$. The following are equivalent:
1. there is $t \in \mathbb{F}_p$ with $A_m(t) = 0$ and $A_{m-1}(t) = -1$;
2. $C(t)$ has order exactly $m$ in $SL_2(\mathbb{F}_p)$ for some $t$;
3. $m \mid p^2 - 1$, i.e. $p \equiv \pm 1 \pmod m$.

*Proof sketch.* $(1) \Leftrightarrow (2)$ from $C(t)^{m} = A_m(t)C(t) - A_{m-1}(t)I$ together with $C(t) \neq I$ and $C(t)$ non-scalar. $(2) \Rightarrow (3)$: eigenvalues of an order-$m$ non-scalar element lie in $\mathbb{F}_{p^2}^\times$, cyclic of order $p^2-1$. $(3) \Rightarrow (2)$: take $y \in \mathbb{F}_{p^2}$ of order $m$ with $y + y^{-1} \in \mathbb{F}_p$ (Frobenius-stable since $y^p \in \{y, y^{-1}\}$), and use $t = y + y^{-1}$. $\square$

**Corollary 3.11 (Specialisations).** For $p \neq 5$: $x^2 + x - 1$ has a root mod $p$ iff $p \equiv \pm 1 \pmod 5$ (golden-ratio / Fibonacci criterion). For $p \neq 7$: $x^3 + x^2 - 2x - 1$ has a root mod $p$ iff $p \equiv \pm 1 \pmod 7$ (a second, independent proof of Theorem 3.7). For $p \neq 11$: $x^5 + x^4 - 4x^3 - 3x^2 + 3x + 1$, the minimal polynomial of $\zeta_{11}+\zeta_{11}^{-1}$, has a root mod $p$ iff $p \equiv \pm 1 \pmod{11}$.

In each case the bridge from Theorem 3.10 to the corollary is a pair of explicit polynomial identities over $\mathbb{Z}[t]$: a factorisation of $A_m(t)$ having the minimal polynomial $\Psi_m$ of $\zeta_m + \zeta_m^{-1}$ as one factor, and an identity expressing $A_{m-1}(t) + 1$ as $\Psi_m(t)$ times a cofactor coprime to $\Psi_m$ modulo every $p \nmid m$. Both were verified by direct expansion for $m = 5, 7, 11$; the uniform-in-$m$ statement is Conjecture 9.1 below.

---

## 4. The information-theoretic layer

The following two statements are completely general — they hold for arbitrary finite joint laws — and they are what turns the arithmetic determinism of Corollary 3.9 into a sharp information identity.

**Theorem 4.1 (Marginalisation decreases entropy).** Let $A$, $B$ be finite sets and $w : A\times B \to \mathbb{R}_{\ge 0}$ with $\sum w \le 1$. Then
$$H(w_A) \le H(w) \quad\text{and}\quad H(w_B) \le H(w).$$

*Proof.* Split the joint sum along fibres: $H(w) = \sum_{a\in A} \sum_{b \in B}\eta(w(a,b))$, and apply Lemma 2.1 in each fibre to get $\sum_b \eta(w(a,b)) \ge \eta(\sum_b w(a,b)) = \eta(w_A(a))$. Sum over $a$. The other statement is symmetric. $\square$

**Theorem 4.2 (Data-processing ceiling).** With $w$ as above,
$$I(w) \le H(w_A) \qquad\text{and}\qquad I(w) \le H(w_B).$$

*Proof.* $I(w) = H(w_A) + H(w_B) - H(w) \le H(w_A) + H(w_B) - H(w_B) = H(w_A)$ by Theorem 4.1 applied to the $B$-marginal; symmetrically for the other. $\square$

**Theorem 4.3 (Determinism saturates the ceiling).** Let $g : A \to B$ be any map and $v : A \to \mathbb{R}_{\ge 0}$ any weight. Define the joint law supported on the graph of $g$:
$$w(a,b) = \begin{cases} v(a) & b = g(a),\\ 0 & \text{otherwise.}\end{cases}$$
Then
$$I(w) = H(w_B) = H\!\left(b \mapsto \sum_{a : g(a) = b} v(a)\right).$$

*Proof.* The $A$-marginal is $w_A = v$, since exactly one $b$ contributes to each row. The joint entropy is $H(w) = \sum_a \sum_b \eta(w(a,b)) = \sum_a \eta(v(a)) = H(v)$, because all off-graph terms vanish and $\eta(0) = 0$. Hence
$$I(w) = H(v) + H(w_B) - H(v) = H(w_B). \qquad\square$$

Theorems 4.2 and 4.3 together say: *the mutual information of a channel is at most the entropy of its output, with equality whenever the output is a deterministic function of the input.* The converse also holds for strictly positive input weights (equality forces each row to be concentrated at a single output), so "fully pinned" and "deterministic" are the same condition.

---

## 5. The single-prime channel: full pinning

### 5.1 The joint law

**Definition 5.1.** Let $A = \mathbb{Z}/7$, $B = \{\text{split}, \text{inert}\}$ identified with $\{\mathrm{true}, \mathrm{false}\}$, and
$$w_{\mathrm{RT}}(n, b) = \begin{cases} 1/6 & n \neq 0 \text{ and } b = T(n),\\ 0 & \text{otherwise.}\end{cases}$$
This is the joint law of $(p \bmod 7, T(p))$ in the uniform prime model. It is a probability law: exactly six of the fourteen cells carry $1/6$.

**Lemma 5.2 (Marginals).** $w_A(n) = 1/6$ for $n \neq 0$ and $0$ for $n = 0$; $w_B(\text{split}) = 1/3$, $w_B(\text{inert}) = 2/3$.

*Proof.* Immediate: two of six invertible classes ($1$ and $6$) are of split type. $\square$

### 5.2 Exact entropies

**Theorem 5.3 (Type entropy).** $\displaystyle H(T) = \log_2 3 - \tfrac23 = 0.9182958\ldots$ bits.

*Proof.* $H(T) = \eta(1/3) + \eta(2/3) = \tfrac13\log_2 3 + \tfrac23\log_2\tfrac32 = \tfrac13\log_2 3 + \tfrac23(\log_2 3 - 1) = \log_2 3 - \tfrac23$. $\square$

**Theorem 5.4 (Residue and joint entropy).** $H(R) = \log_2 6 = 1 + \log_2 3$, and $H(R,T) = \log_2 6 = 1 + \log_2 3$.

*Proof.* Both distributions are uniform on six atoms of mass $1/6$: for the joint law this is precisely because exactly one type accompanies each invertible residue. $\square$

**Theorem 5.5 (Full Pinning Theorem).**
$$I(p \bmod 7\,;\,T) = \log_2 3 - \tfrac23 = H(T).$$
The residue channel of the conductor-$7$ cyclic cubic field is *fully pinned*: it transmits the entire entropy of its output and attains the ceiling of Theorem 4.2.

*Proof 1 (computational).* $I = H(R) + H(T) - H(R,T) = (1+\log_2 3) + (\log_2 3 - 2/3) - (1 + \log_2 3) = \log_2 3 - 2/3$, which is $H(T)$ by Theorem 5.3.

*Proof 2 (structural).* By Corollary 3.9 the type is a function of the residue, so $w_{\mathrm{RT}}$ is supported on the graph of $T$ with row weights $v(n) = 1/6$ for $n\neq 0$ and $v(0) = 0$. Theorem 4.3 applies verbatim and yields $I = H(w_B) = H(T)$, with no logarithm evaluated anywhere. $\square$

The second proof is the conceptual one. The numerical agreement of two closed forms in Proof 1 is not a coincidence of logarithms: it is forced by determinism.

**Theorem 5.6 (Numerical certification).** $1.584 < \log_2 3 < 1.585$, hence
$$0.917 < H(T) = I(p\bmod 7; T) < 0.919 .$$

*Proof.* $2^{1584} < 3^{1000} < 2^{1585}$ as integers; take $\log_2$ and divide by $1000$. $\square$

An empirical estimate of $H(T)$ from a sample of primes returns $0.9179$ bits, and the empirical mutual information equals it to the displayed precision, as full pinning demands. Because the type is a deterministic function of the residue, the corresponding separation statistic between the two classes grows without bound with the sample size; on the reference sample it exceeds $10^4$ standard deviations, i.e. the observed "wall" between split and inert residues is not a statistical artefact but the deterministic law of Theorem 3.7 seen through a finite window.

---

## 6. The semiprime channel: exactly one label destroyed

### 6.1 Setup

Let $p, q$ be independent and uniform on the six invertible classes and $N = pq$. The observer sees $R_N = N \bmod 7$. The hidden variable is the **unordered type pair**, recorded by the number of split factors
$$S = [\,T(p)\,] + [\,T(q)\,] \in \{0,1,2\}.$$

**Definition 6.1.** $w_{\mathrm{semi}}(n, k) = \frac{1}{36}\,\#\{(u,v) \in (\mathbb{F}_7^\times)^2 : uv = n,\ S(u,v) = k\}$.

### 6.2 The group-theoretic count

The key structural remark: $T(u) = [\,u \in H\,]$ where $H = \{\pm 1\}$ is the index-$3$ subgroup of the cyclic group $\mathbb{F}_7^\times$, and the quotient $G = \mathbb{F}_7^\times/H \cong \mathbb{Z}/3$ is where multiplication lives. Write $c(u) \in G$ for the coset.

**Lemma 6.2 (Exact counts).** Let $n \in \mathbb{F}_7^\times$. Among the six ordered factorisations $n = uv$:
* if $n \in H$ (i.e. $n \equiv \pm 1$): $2$ have $S = 2$ and $4$ have $S = 0$; none has $S = 1$;
* if $n \notin H$: $4$ have $S = 1$ and $2$ have $S = 0$; none has $S = 2$.

*Proof.* $c(u)c(v) = c(n)$. If $c(n) = 1$ the possibilities are $(1,1)$ — both split, and there are $|H|^2/|H| = 2$ such factorisations — or $(\omega, \omega^2)$, $(\omega^2,\omega)$ — neither splits, $4$ factorisations. If $c(n) = \omega$ the possibilities are $(1,\omega)$ and $(\omega,1)$ — exactly one splits, $2 + 2 = 4$ factorisations — or $(\omega^2,\omega^2)$ — neither splits, $2$ factorisations. $\square$

Hence the joint table (masses out of $36$): for the two residues $n \in H$, mass $4/36 = 1/9$ at $k=0$ and $2/36 = 1/18$ at $k=2$; for the four residues $n \notin H$, mass $1/9$ at $k=1$ and $1/18$ at $k=0$.

**Lemma 6.3 (Marginals).** $\Pr[R_N = n] = 1/6$ for each invertible $n$ (multiplication by a uniform element randomises), and
$$\Pr[S=2] = \tfrac19, \quad \Pr[S=1] = \tfrac49, \quad \Pr[S=0] = \tfrac49 .$$

### 6.3 Entropies

**Theorem 6.4.** $H(R_N) = 1 + \log_2 3$; $\;H(S) = 2\log_2 3 - \tfrac{16}{9}$; $\;H(R_N, S) = 2\log_2 3 + \tfrac13$.

*Proof.* The first is uniformity on six atoms. For the second, $H(S) = \eta(1/9) + 2\eta(4/9) = \tfrac{2\log_2 3}{9} + \tfrac{8}{9}\left(2\log_2 3 - 2\right) = 2\log_2 3 - \tfrac{16}{9}$. For the third, the joint table has six cells of mass $1/9$ and six of mass $1/18$, giving
$$H = 6\cdot\tfrac{2\log_2 3}{9} + 6\cdot\tfrac{1 + 2\log_2 3}{18} = \tfrac{4\log_2 3}{3} + \tfrac{1 + 2\log_2 3}{3} = 2\log_2 3 + \tfrac13. \qquad\square$$

**Theorem 6.5 (Semiprime Degradation Theorem).**
$$I(R_N \,;\, S) = \log_2 3 - \tfrac{10}{9} = 0.4738514\ldots \text{ bits},$$
and $I(R_N;S) < H(S)$ strictly: the semiprime channel is **not** pinned.

*Proof.* $I = (1 + \log_2 3) + (2\log_2 3 - 16/9) - (2\log_2 3 + 1/3) = \log_2 3 - 10/9$. Strictness: $H(S) - I = \log_2 3 - 2/3 > 0$ since $\log_2 3 > 1.584$. $\square$

**Theorem 6.6 (Exact Deficit Theorem).**
$$H(S) - I(R_N;S) = \log_2 3 - \tfrac23 = H(T).$$
The information the residue of a semiprime fails to convey about the unordered type pair of its factors is *exactly the entropy of one factor's type*. Multiplying two primes destroys precisely one label.

*Proof.* Subtract the closed forms of Theorems 6.4 and 6.5 and compare with Theorem 5.3. $\square$

**Corollary 6.7.** $0.917 < H(S) - I(R_N;S) < 0.919$, and $0.472 < I(R_N;S) < 0.475$.

The interpretation is worth stating carefully. In the single-prime channel the observer learns the coset $c(p) \in G$ and the type is the indicator of $c(p) = 1$: perfect. In the semiprime channel the observer learns only the product $c(p)c(q)$, i.e. the image of the pair under the multiplication map $G \times G \to G$. That map has fibres of size $3$, and $\log_2 3$ bits are lost from the pair's coset information; the observable $S$, being a coarsening of the pair, recovers part of it, and the arithmetic works out to a loss of exactly $H(T) = \log_2 3 - 2/3$.

---

## 7. Which-factor blindness

Let the observer now demand the **ordered** pair $(T(p), T(q)) \in \{0,1\}^2$.

**Definition 7.1.** $w_{\mathrm{ord}}(n, \beta) = \frac{1}{36}\,\#\{(u,v) : uv = n,\ (T(u),T(v)) = \beta\}$.

**Lemma 7.2 (Exact swap symmetry).** For every $n \in \mathbb{Z}/7$ and every $\beta = (\beta_1,\beta_2)$,
$$\#\{(u,v): uv = n,\ (T(u),T(v)) = \beta\} = \#\{(u,v): uv = n,\ (T(u),T(v)) = (\beta_2,\beta_1)\}.$$

*Proof.* The involution $(u,v)\mapsto (v,u)$ preserves the product $uv = n$ (commutativity) and exchanges the two type coordinates. $\square$

**Lemma 7.3 (Ordered counts).** For $n \in H$: $4$ factorisations with $\beta = (0,0)$, $2$ with $\beta = (1,1)$, none mixed. For $n \notin H$: $2$ with each of $(0,0)$, $(1,0)$, $(0,1)$; none with $(1,1)$. (Here $1 = $ split.) Consequently the ordered-pair marginal is
$$\Pr[(1,1)] = \tfrac19, \quad \Pr[(0,0)] = \tfrac49, \quad \Pr[(1,0)] = \Pr[(0,1)] = \tfrac29 .$$

**Theorem 7.4 (Ordered entropies).**
$$H(T_p,T_q) = 2\log_2 3 - \tfrac43, \qquad H\!\left(R_N, (T_p,T_q)\right) = 2\log_2 3 + \tfrac79 .$$

*Proof.* $H(T_p,T_q) = \eta(1/9) + \eta(4/9) + 2\eta(2/9) = \tfrac{2\log_2 3}{9} + \tfrac{4(2\log_2 3 - 2)}{9} + \tfrac{2\cdot 2(2\log_2 3 - 1)}{9} = 2\log_2 3 - \tfrac43$. For the joint law, two cells carry $1/9$ and fourteen carry $1/18$, giving $2\cdot\frac{2\log_2 3}{9} + 14\cdot\frac{1+2\log_2 3}{18} = 2\log_2 3 + \frac79$. $\square$

**Theorem 7.5 (Which-Factor Blindness Theorem).**
$$I\!\left(R_N ; (T_p,T_q)\right) = \log_2 3 - \tfrac{10}{9} = I(R_N; S),$$
hence
$$I\!\left(R_N ; (T_p,T_q)\right) - I(R_N ; S) = 0 \quad\text{exactly.}$$
The residue of a semiprime reveals the *multiset* of splitting types of its two factors as well as it possibly can, and nothing whatsoever about *which* factor carries which type.

*Proof.* $I = (1 + \log_2 3) + (2\log_2 3 - 4/3) - (2\log_2 3 + 7/9) = \log_2 3 - 10/9$, equal to Theorem 6.5. $\square$

**Theorem 7.6 (The which-factor bit is real but invisible).**
$$H(T_p,T_q) - H(S) = \tfrac49 \text{ bits} > 0 .$$

*Proof.* $\left(2\log_2 3 - \tfrac43\right) - \left(2\log_2 3 - \tfrac{16}{9}\right) = \tfrac49$; note this is $\eta$-free — the $\log_2 3$ terms cancel exactly, and $4/9$ is precisely $\frac{4}{9}\cdot 1$, the entropy of a fair coin flipped on the $4/9$-probability event $S = 1$. $\square$

So the pair carries $4/9$ bits of genuine which-factor uncertainty, and the residue channel transmits exactly $0$ of them. Lemma 7.2 explains why: the channel is invariant under an involution that acts freely on precisely the which-factor coordinate and fixes everything else, so it cannot distinguish the two branches. This is a symmetry argument, and it is exact rather than asymptotic.

---

## 8. Discussion

### 8.1 Pinning as a detector of abelianness

Theorem 4.3 and its converse identify full pinning with determinism: $I(p \bmod m ; T) = H(T)$ if and only if the type map factors through $(\mathbb{Z}/m)^\times$. For a Galois extension $K/\mathbb{Q}$, the decomposition type of $p$ is determined by the Frobenius conjugacy class, and this class is a function of $p \bmod m$ for some $m$ exactly when $K$ is abelian — that is the content of the Kronecker–Weber theorem read backwards. Hence:

> Full pinning of the residue channel for **some** modulus $\iff$ $K/\mathbb{Q}$ is abelian.

For a non-abelian field — the first case being an $S_3$ cubic such as $\mathbb{Q}[x]/(x^3 - x - 1)$, of discriminant $-23$ — every residue channel has a strictly positive, computable deficit $H(T) - I(p \bmod m; T) > 0$. Information theory therefore *detects* class field theory: the deficit is an information-theoretic obstruction to abelianness, and it is computable by a finite check for each modulus.

### 8.2 Cryptographic reading

The semiprime results have a precise cryptographic content. For a semiprime modulus $N$, the residue $N \bmod 7$ (a free computation) leaks $\log_2 3 - 10/9 \approx 0.474$ bits about the pair of splitting types of the factors in the conductor-$7$ cyclic cubic field. This is not an attack — the type is a one-bit-ish invariant of each factor, not the factor itself — but it is an exactly quantified side channel, and its exactness is unusual: the leak is a closed form, not a bound.

Equally precise is the *non*-leak. Which-factor information is exactly zero for structural reasons (commutativity), not merely small. Any attempt to extract asymmetry between $p$ and $q$ from $N \bmod 7$ alone is provably futile, and would remain futile with unbounded computation.

The exact deficit theorem, $H(S) - I = H(T)$, gives a way to speak about "how much a multiplication hides" in a currency that composes: one label per multiplication, at least in this model.

### 8.3 Scope and limitations

The information-theoretic results are theorems about the *models* of Section 2.3: the uniform prime model and the uniform independent semiprime model. Their arithmetic content depends on those models being the right idealisations, which for primes is Dirichlet's theorem (asymptotic equidistribution in the six invertible classes) and for semiprimes the independence of the two factors' residues in a suitable ensemble. For a fixed finite sample the empirical values approach but do not equal the closed forms; the reference sample gives $0.9179$ against $0.918296$, and $0.4747$ against $0.473851$.

The results are also specific to conductor $7$ in their numerics — but not in their mechanism. The two-type structure comes from $[\mathbb{F}_7^\times : \{\pm1\}] = 3$ being prime; for a general prime conductor $m$, the real subfield $\mathbb{Q}(\zeta_m + \zeta_m^{-1})$ has degree $(m-1)/2$ and the type spectrum is richer, but the pinning theorem (Theorem 4.3 applied to a deterministic type map) survives verbatim.

---

## 9. Open problems and future work

**Conjecture 9.1 (Chebyshev factorisation of the real cyclotomic tower).** For every odd prime $m$, the Chebyshev-type coefficient $A_m(t)$ (defined by $A_0 = 0$, $A_1 = 1$, $A_{n+2} = tA_{n+1} - A_n$) factors as
$$A_m(t) = \Psi_m(t)\cdot(-1)^{(m-1)/2}\Psi_m(-t),$$
where $\Psi_m$ is the minimal polynomial of $\zeta_m + \zeta_m^{-1}$; moreover $A_{m-1}(t) + 1 = \Psi_m(t)\cdot R_m(t)$ with $R_m$ coprime to $\Psi_m$ modulo every prime $p \nmid m$. Consequently $\Psi_m$ has a root modulo $p$ iff $p \equiv \pm 1 \pmod m$, uniformly in $m$.

The heuristic is that $A_m$ cuts out the "order-$m$ locus" of the trace map on $SL_2$, whose two branches correspond to $\zeta + \zeta^{-1}$ and $-(\zeta+\zeta^{-1})$; the side condition $A_{m-1} = -1$ discards the second branch. The statement is one about $\mathbb{Z}[t]$, amenable to a resultant computation, and it has been verified by direct expansion for $m = 5, 7, 11$, where the Bézout identity between the two spurious factors is integral.

**Conjecture 9.2 (Pinning–abelianness dichotomy).** Let $K/\mathbb{Q}$ be Galois and $T(p)$ the decomposition type of an unramified $p$. There exists a modulus $m$ with $I(p \bmod m ; T) = H(T)$ if and only if $K/\mathbb{Q}$ is abelian. For non-abelian $K$ — first case an $S_3$ cubic such as $x^3 - x - 1$ — every residue channel satisfies $I(p \bmod m; T) < H(T)$ strictly, with a computable positive deficit.

The forward direction is Theorem 4.3 plus Kronecker–Weber; the negative half is, for each $m$, a finite verification that the type map does not factor through $(\mathbb{Z}/m)^\times$, together with a uniform lower bound on the deficit.

**Problem 9.3 (Higher conductors and richer type spectra).** Compute the exact channel invariants for $\mathbb{Q}(\zeta_m + \zeta_m^{-1})$ for general prime $m$, where the type of $p$ is the order of $p$ in $\mathbb{F}_m^\times/\{\pm1\}$. One expects $H(T)$ to be the entropy of the order distribution in a cyclic group of order $(m-1)/2$, and full pinning to persist for all $m$.

**Problem 9.4 (Deficit under $k$-fold products).** Generalise Theorem 6.6: if $N = p_1\cdots p_k$ with independent uniform factors, is the deficit between the entropy of the unordered type multiset and the transmitted information again an exact multiple of a natural entropy? The $k = 2$ answer is exactly $H(T)$; the pattern for $k \ge 3$ is open.

**Problem 9.5 (Non-uniform inputs).** Replace the uniform prime model by a biased one (e.g. primes in a fixed short interval, or primes weighted by a smooth cutoff). Theorem 4.3 is distribution-free, so full pinning is unaffected; but the semiprime deficit is not, and its dependence on the input law is an explicit optimisation problem over the $6$-simplex.

---

## 10. Conclusion

For the conductor-$7$ cyclic cubic field, the passage from a prime's residue to its splitting behaviour is a perfect information channel: it delivers $\log_2 3 - 2/3 = 0.918296\ldots$ bits, which is exactly the entropy of what there is to know. The reason is structural — the law is a function, and functions saturate the data-processing ceiling — rather than a numerical coincidence between two logarithms. Feeding the channel a product of two primes degrades it by exactly one type entropy, leaving $\log_2 3 - 10/9 = 0.473851\ldots$ bits about the multiset of factor types, and by an exact symmetry it leaves precisely zero bits about which factor is which, even though $4/9$ of a bit of which-factor uncertainty is objectively present. Determinism, degradation, and blindness — all three in closed form.
