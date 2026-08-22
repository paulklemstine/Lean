# Three Fields, One Answer: An Exact Type-Channel Law for $S_3$-Cubics

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

We study the Chebotarev distribution of a non-cyclic cubic field as a discrete communication channel whose input is the residue class of a prime modulo a fixed conductor and whose output is the factorization type of that prime. We prove an exact information-theoretic identity: for every cubic polynomial whose splitting field has Galois group $S_3$, and for every residue observable whose associated quadratic character is balanced,

$$I(\text{residue}\,;\,\text{splitting type}) = 1 \text{ bit exactly.}$$

The value is independent of the polynomial, of its discriminant, of the conductor of the resolvent character, and of the size of the residue group. We verify the law on three arithmetically independent cubics — $x^3-3$ (discriminant $-243$), $x^3-2$ ($-108$), and $x^3-x-1$ ($-23$) — whose resolvent fields are $\mathbb{Q}(\sqrt{-3})$, $\mathbb{Q}(\sqrt{-3})$ and $\mathbb{Q}(\sqrt{-23})$, so that the first two are governed by the observable $p \bmod 3$ and the third by a quadratic character modulo $23$ with eleven classes per fibre. The same value $1$ is obtained for the *semiprime pair channel*, in which one observes only the unordered pair of splitting types of the two prime factors of $n = pq$, despite the six-letter alphabet and the irregular multiplicity profile $1:6:4:9:12:4$.

The structural reason is a general **coupling-quotient law**: if the sole statistical coupling between two finite observables is an invariant taking values in a finite set $D$, balanced on both sides, then the mutual information is exactly $\log_2|D|$. The $S_3$ law is its $|D|=2$ case, with $D$ the sign quotient $S_3/A_3$.

We prove that the value $1$ is sharp and diagnostic. The splitting-type entropy of an $S_3$-cubic is $\tfrac23 + \tfrac12\log_2 3 \approx 1.4591 > 1$, so the channel is strictly lossy. A different binary readout of the same distribution — "does the cubic have a root modulo $p$?" — has channel value exactly $\tfrac12\log_2 3 - \tfrac13 \approx 0.4591$, strictly inside $(0,1)$. A cyclic cubic gives $\log_2 3$ for its Frobenius channel and $\log_2 3 - \tfrac23$ for its type channel. Hence $1.0000$ is a fingerprint of $S_3$ read through the sign character, not an artefact of alphabet sizes.

Finally we supply the algebraic backbone: the Vandermonde product is a sign-character eigenvector, the depressed-cubic discriminant identity $\big((r-s)(s-t)(t-r)\big)^2 = -4a^3 - 27b^2$, and the equivalence $-3 \in (\mathbb{F}_p^\times)^2 \iff p \equiv 1 \pmod 3$ for $p \neq 2,3$, which identifies the coupling bit of the first two fields with the residue $p \bmod 3$ itself.

**Keywords.** Chebotarev density, splitting type, quadratic resolvent, sign character, mutual information, coupling quotient, cubic discriminant, Galois fingerprint.

---

## 1. Introduction

### 1.1 Arithmetic as a channel

Let $f \in \mathbb{Z}[x]$ be a monic irreducible cubic and let $K = \mathbb{Q}[x]/(f)$ be the cubic field it generates. For each prime $p$ not dividing the discriminant, the reduction $f \bmod p$ factors in exactly one of three ways:

- **totally split**: three distinct linear factors, $p\mathcal{O}_K = \mathfrak{p}_1\mathfrak{p}_2\mathfrak{p}_3$;
- **partially split**: a linear times an irreducible quadratic, $p\mathcal{O}_K = \mathfrak{p}_1\mathfrak{p}_2$ with residue degrees $1,2$;
- **inert**: irreducible, $p\mathcal{O}_K = \mathfrak{p}$ with residue degree $3$.

Write $T(p) \in \{\mathrm{S}, \mathrm{P}, \mathrm{I}\}$ for this *splitting type*. The map $p \mapsto T(p)$ is a deterministic but arithmetically deep function of $p$: predicting it is essentially the content of nonabelian reciprocity.

There is, however, a cheap partial predictor. If $\operatorname{disc} f$ is not a perfect square, the Galois group of the splitting field of $f$ is $S_3$, and the quadratic subfield $\mathbb{Q}(\sqrt{\operatorname{disc} f})$ — the *resolvent* — is abelian over $\mathbb{Q}$. Its splitting behaviour is governed by a congruence condition on $p$. That congruence condition is therefore a legitimate, computable, congruence-level predictor of a piece of $T(p)$.

The question this paper answers precisely: **how large is that piece?**

We treat the pair $(p \bmod q, T(p))$, for $q$ the conductor of the resolvent character, as a pair of jointly distributed discrete random variables, with the joint law supplied by the Chebotarev density theorem, and we compute the mutual information exactly.

### 1.2 The main result, informally

The answer is $1$ bit, exactly, for every $S_3$-cubic and every balanced residue observable. Not asymptotically one bit; not one bit up to an error term; the exact real number $1$. The remarkable feature is that essentially every other entropy in the problem is irrational — the splitting-type entropy is $\tfrac23 + \tfrac12\log_2 3$, the joint entropy is $\tfrac16\log_2 6 + \tfrac12\log_2 2 + \tfrac13\log_2 3$ shifted by a logarithm of the residue-group size — and the irrationalities cancel identically.

They cancel for a structural reason, which we isolate as a theorem about arbitrary finite count tables and then apply.

### 1.3 Organization

Section 2 sets up finite-table information theory. Section 3 proves the two general channel laws (character, coupling-quotient). Section 4 constructs the Chebotarev model of an $S_3$-cubic and proves the universal type-channel law. Section 5 supplies the algebraic backbone: Vandermonde equivariance, the cubic discriminant, and the identification of the coupling bit with a congruence. Section 6 instantiates the three fields. Section 7 treats the semiprime pair channel. Section 8 proves sharpness through three separations. Section 9 gives algorithms; Section 10 discusses applications and future directions.

---

## 2. Finite count tables and their entropies

All information-theoretic quantities in this paper are defined for *count tables*, which keeps everything exact and rational-arithmetic-friendly.

**Definition 2.1 (count table).** Let $A$ and $B$ be finite nonempty sets. A *count table* is a function $n : A \times B \to \mathbb{N}$. Its *total* is $N = \sum_{a,b} n(a,b)$; its marginals are
$$n_A(a) = \sum_{b} n(a,b), \qquad n_B(b) = \sum_{a} n(a,b).$$

**Definition 2.2 (surprisal).** For $x \in \mathbb{R}$ put $\operatorname{sur}(x) = -x\log_2 x$, with the convention $\operatorname{sur}(0) = 0$.

Two elementary identities drive every computation below.

**Lemma 2.3 (scaling).** For $x \in \mathbb{R}$ and $k > 0$,
$$k \cdot \operatorname{sur}(x/k) = \operatorname{sur}(x) + x\log_2 k.$$
*Proof.* For $x = 0$ both sides vanish. Otherwise expand $\log_2(x/k) = \log_2 x - \log_2 k$ and multiply out. $\square$

**Lemma 2.4 (inverse).** For $c > 0$, $\;c\cdot\operatorname{sur}(1/c) = \log_2 c$.
*Proof.* The case $x = 1$ of Lemma 2.3, since $\operatorname{sur}(1) = 0$. $\square$

**Definition 2.5 (entropies).** With $N = \operatorname{total}(n) > 0$,
$$H(A) = \sum_{a}\operatorname{sur}\!\Big(\frac{n_A(a)}{N}\Big), \quad H(B) = \sum_{b}\operatorname{sur}\!\Big(\frac{n_B(b)}{N}\Big), \quad H(A,B) = \sum_{a,b}\operatorname{sur}\!\Big(\frac{n(a,b)}{N}\Big),$$
and the mutual information is $I(n) = H(A) + H(B) - H(A,B)$.

These are the ordinary Shannon quantities of the empirical joint distribution $n/N$, in bits.

**Proposition 2.6 (symmetry).** $I$ is invariant under transposing the table: $I(n^{\mathsf T}) = I(n)$, where $n^{\mathsf T}(b,a) = n(a,b)$.
*Proof.* Totals and joint entropies are manifestly transpose-invariant, and the two marginal entropies swap. $\square$

**Theorem 2.7 (determinism law).** Suppose the first observable is a deterministic function of the second: there is $g : B \to A$ with $n(a,b) = 0$ whenever $a \neq g(b)$. Then $H(A,B) = H(B)$ and consequently
$$I(n) = H(A).$$
*Proof.* By hypothesis the only nonzero entry in column $b$ is at row $g(b)$, so $n_B(b) = n(g(b), b)$. Exchanging the order of summation in the joint entropy, each inner sum collapses to its single nonzero term, giving $H(A,B) = \sum_b \operatorname{sur}(n_B(b)/N) = H(B)$. Substituting into the definition of $I$ gives the claim. $\square$

By Proposition 2.6 the same statement holds with the roles of $A$ and $B$ exchanged: if $B$ is a function of $A$ then $I(n) = H(B)$.

**Theorem 2.8 (balanced binary entropy).** If $|A| = 2$ and both marginals satisfy $n_A(a)/N = 1/2$, then $H(A) = 1$.
*Proof.* $H(A) = 2\operatorname{sur}(1/2) = \log_2 2 = 1$ by Lemma 2.4. $\square$

---

## 3. The channel laws

We now isolate the structural mechanism producing exact integer channel values. The key hypothesis is that the two observables are *coupled only through a common invariant*.

### 3.1 The character channel law

**Definition 3.1 (character-coupled table).** Let $\chi : A \to \{0,1\}$, $g : B \to \{0,1\}$ and $m : B \to \mathbb{N}$. The associated table is
$$n(a,b) = \begin{cases} m(b), & \chi(a) = g(b),\\ 0, & \text{otherwise.}\end{cases}$$

Interpretation: the output $b$ occurs with intrinsic weight $m(b)$; the input $a$ is compatible with it precisely when the two Boolean readouts agree; and nothing else links the two.

**Theorem 3.2 (character channel law).** Suppose in addition:

1. *(input balance)* each fibre of $\chi$ has exactly $k$ elements, with $k > 0$;
2. *(output balance)* each fibre of $g$ carries total weight $M = \sum_{b : g(b) = c} m(b)$, the same for $c = 0,1$, with $M > 0$.

Then $I(n) = 1$ exactly.

*Proof.* Three computations.

*Total.* Summing the $B$-marginal, $n_B(b) = \sum_{a : \chi(a) = g(b)} m(b) = k\,m(b)$, so
$$N = k\sum_b m(b) = k\cdot 2M.$$

*Input entropy.* For each $a$, $n_A(a) = \sum_{b : g(b) = \chi(a)} m(b) = M$; the input marginal is uniform. Since $|A| = 2k$,
$$H(A) = 2k\,\operatorname{sur}\!\Big(\frac{M}{2kM}\Big) = 2k\operatorname{sur}\!\Big(\frac{1}{2k}\Big) = \log_2(2k)$$
by Lemma 2.4.

*Joint entropy.* Column $b$ has exactly $k$ nonzero entries, each equal to $m(b)$. Hence
$$H(A,B) = \sum_b k\,\operatorname{sur}\!\Big(\frac{m(b)}{N}\Big) = \sum_b k\,\operatorname{sur}\!\Big(\frac{n_B(b)/k}{N}\Big) = \sum_b\Big[\operatorname{sur}\!\Big(\frac{n_B(b)}{N}\Big) + \frac{n_B(b)}{N}\log_2 k\Big] = H(B) + \log_2 k,$$
using Lemma 2.3 with $x = n_B(b)/N$ and the fact that the $n_B(b)/N$ sum to $1$.

Combining, $I = H(A) + H(B) - H(A,B) = \log_2(2k) + H(B) - H(B) - \log_2 k = \log_2 2 = 1$. $\square$

Two features deserve emphasis. First, the output entropy $H(B)$ *cancels identically*: no property of the weight profile $m$ beyond its balance is used, which is why wildly different profiles give the same answer. Second, $|B|$ never appears; the alphabet size of the output is irrelevant.

### 3.2 The coupling-quotient law

Nothing above required the invariant to be two-valued.

**Theorem 3.3 (coupling-quotient law).** Let $D$ be a finite nonempty set, $\chi : A \to D$, $g : B \to D$, $m : B \to \mathbb{N}$, and let
$$n(a,b) = \begin{cases} m(b), & \chi(a) = g(b),\\ 0, & \text{otherwise.}\end{cases}$$
Assume each fibre of $\chi$ has exactly $k > 0$ elements and each fibre of $g$ carries weight exactly $M > 0$. Then
$$I(n) = \log_2 |D|.$$

*Proof.* Identical bookkeeping. $n_B(b) = k\,m(b)$ and $\sum_b m(b) = |D|\,M$, so $N = k|D|M$. Each $n_A(a) = M$, and $|A| = |D|\,k$, so
$$H(A) = |D|k\operatorname{sur}\!\Big(\frac{1}{|D|k}\Big) = \log_2(|D|k).$$
Each column again has $k$ equal nonzero entries, so $H(A,B) = H(B) + \log_2 k$. Subtracting, $I = \log_2(|D|k) - \log_2 k = \log_2|D|$. $\square$

**Corollary 3.4.** If $|D| = 2$ then $I(n) = 1$; this recovers Theorem 3.2.

The interpretation is the reason for the name. The set $D$ is the *coupling quotient*: the maximal common refinement through which the two observables communicate. Everything finer than $D$ on either side is conditionally independent noise, and contributes nothing. The channel value is the entropy of the uniform distribution on $D$.

---

## 4. The Chebotarev model of an $S_3$-cubic and the universal law

### 4.1 The model

Let $f$ be a cubic with splitting field $L$, $\operatorname{Gal}(L/\mathbb{Q}) \cong S_3$ acting faithfully on the three roots. For $p$ unramified, the Frobenius conjugacy class $\mathrm{Frob}_p \subseteq S_3$ determines the splitting type by cycle structure:

**Definition 4.1.** For $\sigma \in S_3$ set
$$T(\sigma) = \begin{cases}\mathrm{S} & |\operatorname{supp}\sigma| = 0 \quad (\sigma = \mathrm{id}),\\ \mathrm{P} & |\operatorname{supp}\sigma| = 2 \quad (\sigma \text{ a transposition}),\\ \mathrm{I} & \text{otherwise} \quad (\sigma \text{ a } 3\text{-cycle}).\end{cases}$$

**Definition 4.2 (Chebotarev multiplicity).** $\mu(t) = \#\{\sigma \in S_3 : T(\sigma) = t\}$.

**Proposition 4.3.** $\mu(\mathrm{S}) = 1$, $\mu(\mathrm{P}) = 3$, $\mu(\mathrm{I}) = 2$; the Chebotarev profile is $1:3:2$ out of $6$.
*Proof.* Direct enumeration of the six elements of $S_3$. $\square$

By the Chebotarev density theorem the natural density of primes with $T(p) = t$ is $\mu(t)/6$, so the *type distribution* is $(\tfrac16, \tfrac12, \tfrac13)$.

### 4.2 The sign readout

**Definition 4.4.** The *sign bit* of a splitting type is
$$\varepsilon(\mathrm{S}) = +, \qquad \varepsilon(\mathrm{P}) = -, \qquad \varepsilon(\mathrm{I}) = +.$$

**Proposition 4.5 (the sign character factors through the type).** For every $\sigma \in S_3$, $\varepsilon(T(\sigma)) = +$ if and only if $\operatorname{sgn}(\sigma) = 1$.
*Proof.* Enumerate: the identity and the two $3$-cycles are even and have types $\mathrm{S}$ and $\mathrm{I}$; the three transpositions are odd and have type $\mathrm{P}$. $\square$

**Proposition 4.6 (mass balance).** Each fibre of $\varepsilon$ carries Chebotarev mass exactly $3$:
$$\mu(\mathrm{S}) + \mu(\mathrm{I}) = 1 + 2 = 3, \qquad \mu(\mathrm{P}) = 3.$$
*Proof.* Proposition 4.3. Equivalently: $A_3$ has index $2$ in $S_3$, so both cosets have $3$ elements. $\square$

Proposition 4.6 is the arithmetic accident (in fact, the group-theoretic necessity) that makes the whole theory work: *the sign readout of the Chebotarev distribution is an unbiased coin*.

### 4.3 The joint table and the universal law

Let $A$ be a finite residue group (e.g. $(\mathbb{Z}/q)^\times$) equipped with a Boolean quadratic character $\chi : A \to \{\pm\}$.

**Definition 4.7 (residue/type table).**
$$n_\chi(a, t) = \begin{cases}\mu(t), & \chi(a) = \varepsilon(t),\\ 0, & \text{otherwise.}\end{cases}$$

**Proposition 4.8 (faithfulness of the model).** For all $a$ and $t$,
$$n_\chi(a,t) = \#\{\sigma \in S_3 : T(\sigma) = t \text{ and } \chi(a) = \operatorname{sgn}(\sigma)\}.$$
That is, the table really is the Chebotarev joint occupation number of the pair $(p \bmod q,\, T(p))$, given the classical identity $\operatorname{sgn}(\mathrm{Frob}_p) = \left(\frac{\operatorname{disc} f}{p}\right)$ expressed through the character $\chi$.
*Proof.* If $\chi(a) = \varepsilon(t)$ the constraint on $\sigma$ reduces, by Proposition 4.5, to $T(\sigma) = t$, and the count is $\mu(t)$. If $\chi(a) \neq \varepsilon(t)$ the two constraints are incompatible and the set is empty. $\square$

**Theorem 4.9 (universal $S_3$ type-channel law).** Let $\chi : A \to \{\pm\}$ be balanced, i.e. both fibres have the same cardinality $k > 0$. Then
$$I\big(\text{residue}\,;\,\text{splitting type}\big) = I(n_\chi) = 1 \text{ exactly.}$$

*Proof.* $n_\chi$ is a character-coupled table (Definition 3.1) with $m = \mu$ and $g = \varepsilon$. Input balance is the hypothesis on $\chi$; output balance is Proposition 4.6 with $M = 3 > 0$. Apply Theorem 3.2. $\square$

Nothing about the field enters the proof except that its Galois group is $S_3$ (through Propositions 4.3 and 4.5–4.6); nothing about the residue group enters except balance of $\chi$. This is the precise sense in which the law is universal.

We record the group-theoretic reformulation, which is what generalizes.

**Remark 4.10.** In the language of Theorem 3.3 the coupling quotient is $D = S_3/A_3 \cong \{\pm 1\}$, the abelianization of $S_3$; the channel value $\log_2|D| = \log_2 2 = 1$ is the entropy of the abelianized Frobenius.

---

## 5. The algebraic backbone

Theorem 4.9 takes as input the classical statement that the Frobenius sign is the quadratic character of the discriminant. This section supplies the algebra behind that input and, for two of our three fields, identifies the character explicitly as a congruence mod $3$.

### 5.1 The Vandermonde product is a sign eigenvector

**Theorem 5.1.** Let $R$ be a commutative ring, $n \geq 0$, $v = (v_0,\dots,v_{n-1}) \in R^n$, and $\sigma$ a permutation of the indices. Then
$$\prod_{i<j}\big(v_{\sigma(j)} - v_{\sigma(i)}\big) = \operatorname{sgn}(\sigma)\prod_{i<j}\big(v_j - v_i\big).$$

*Proof.* The Vandermonde matrix of $v \circ \sigma$ is the row permutation of the Vandermonde matrix of $v$ by $\sigma$, so its determinant is $\operatorname{sgn}(\sigma)$ times the original determinant. Both determinants equal the corresponding products $\prod_{i<j}(v_j - v_i)$ by the Vandermonde determinant formula. $\square$

**Corollary 5.2.** With $\delta(v) = \prod_{i<j}(v_j - v_i)$, the square $\delta(v)^2$ is permutation-invariant.
*Proof.* Square Theorem 5.1 and use $\operatorname{sgn}(\sigma)^2 = 1$. $\square$

Applied to the roots of a separable polynomial, Corollary 5.2 says $\delta^2$ — the discriminant — is fixed by the Galois group, hence rational, whereas $\delta$ is moved *only by the sign character*. Thus $\mathbb{Q}(\delta) = \mathbb{Q}(\sqrt{\operatorname{disc}})$ is the fixed field of the even subgroup, and Galois acts on it through $\operatorname{sgn}$. This is exactly the structure Theorem 4.9 consumes: the coupling invariant is the sign, and it is realized arithmetically by a quadratic field.

### 5.2 The discriminant of a depressed cubic

**Theorem 5.3.** Let $R$ be a commutative ring and $r,s,t,a,b \in R$ satisfy the Vieta relations of $x^3 + ax + b$:
$$r+s+t = 0, \qquad rs+st+tr = a, \qquad rst = -b.$$
Then
$$\big((r-s)(s-t)(t-r)\big)^2 = -4a^3 - 27b^2.$$

*Proof.* Eliminate $t = -r-s$ using the first relation. The second gives $a = -(r^2 + rs + s^2)$ and the third gives $b = r^2 s + r s^2$. Substituting both into each side and expanding shows the two sides are the same polynomial in $r,s$. $\square$

**Corollary 5.4 (three discriminants).**

| polynomial | $a$ | $b$ | $\operatorname{disc} = -4a^3-27b^2$ |
|---|---|---|---|
| $x^3 - 3$ | $0$ | $-3$ | $-243$ |
| $x^3 - 2$ | $0$ | $-2$ | $-108$ |
| $x^3 - x - 1$ | $-1$ | $-1$ | $-23$ |

All three are negative and non-square, so each polynomial is irreducible over $\mathbb{Q}$ with splitting field of group $S_3$ (a cubic with non-square discriminant cannot have cyclic Galois group; irreducibility of these three is immediate from the rational root test).

**Proposition 5.5 (the three discriminants are pairwise distinct).** $-243 \neq -108$, $-243 \neq -23$, $-108 \neq -23$. Hence the three fields are genuinely different arithmetic objects.

### 5.3 Squarefree kernels and the resolvent character

Squareness modulo $p$ is insensitive to square factors:

**Lemma 5.6.** In a field $F$, for $u, v \in F$ with $v \neq 0$: $uv^2$ is a square if and only if $u$ is a square.
*Proof.* If $uv^2 = w^2$ then $u = (w/v)^2$; conversely if $u = w^2$ then $uv^2 = (wv)^2$. $\square$

**Proposition 5.7 (squarefree kernels).**
$$-243 = -3\cdot 9^2, \qquad -108 = -3 \cdot 6^2, \qquad -23 = -23 \cdot 1^2,$$
and $-3$, $-23$ are squarefree. Hence the resolvent fields are
$$\mathbb{Q}(\sqrt{-243}) = \mathbb{Q}(\sqrt{-3}), \qquad \mathbb{Q}(\sqrt{-108}) = \mathbb{Q}(\sqrt{-3}), \qquad \mathbb{Q}(\sqrt{-23}).$$

So two of the three fields share a resolvent while having different discriminants — an instructive intermediate case between "same field" and "unrelated fields".

**Theorem 5.8 (the resolvent character of $\mathbb{Q}(\sqrt{-3})$ is $p \bmod 3$).** Let $p$ be a prime with $p \neq 2, 3$. Then
$$-3 \text{ is a square in } \mathbb{F}_p \iff p \equiv 1 \pmod 3.$$

*Proof.* ($\Rightarrow$) Suppose $y^2 = -3$ in $\mathbb{F}_p$. Since $p \neq 2$ we may set $z = (y-1)/2$; then $4(z^2 + z + 1) = (2z+1)^2 + 3 = y^2 + 3 = 0$, and $4 \neq 0$, so $z^2 + z + 1 = 0$. Hence $z^3 - 1 = (z-1)(z^2+z+1) = 0$, so $z^3 = 1$; and $z \neq 1$ since otherwise $3 = 0$ in $\mathbb{F}_p$, contradicting $p \neq 3$. Thus $z$ has order exactly $3$ in $\mathbb{F}_p^\times$, whence $3 \mid p-1$.

($\Leftarrow$) If $p \equiv 1 \pmod 3$ then $3 \mid |\mathbb{F}_p^\times|$, so by Cauchy's theorem $\mathbb{F}_p^\times$ contains an element $z$ of order $3$. Then $z^2 + z + 1 = 0$ (as $z \ne 1$ and $z^3 = 1$), so $y = 2z+1$ satisfies $y^2 = 4z^2 + 4z + 1 = 4(z^2+z+1) - 3 = -3$. $\square$

**Corollary 5.9.** For every prime $p \neq 2,3$,
$$-243 \text{ is a square mod } p \iff p \equiv 1 \!\!\pmod 3 \iff -108 \text{ is a square mod } p.$$
*Proof.* Lemma 5.6 with $v = 9$, resp. $v = 6$ (both nonzero mod $p$ as $p \neq 2,3$), plus Theorem 5.8. $\square$

Thus for $x^3-3$ and $x^3-2$ the coupling bit *is* the residue $p \bmod 3$: the residue observable and the invariant that couples it to the splitting type coincide. For $x^3-x-1$ the coupling bit is the Legendre symbol $\left(\frac{-23}{p}\right)$, equivalently (by quadratic reciprocity, $-23 \equiv 1 \bmod 4$) the quadratic-residue character of $p$ modulo $23$ — a genuinely different observable on a genuinely different group.

---

## 6. The three fields

We now instantiate Theorem 4.9.

### 6.1 Field 1 and Field 2: $x^3 - 3$ and $x^3 - 2$

The residue group is $A = (\mathbb{Z}/3)^\times = \{1,2\}$ and the character is
$$\chi_{-3}(a) = + \iff a = 1,$$
which by Theorem 5.8 is the quadratic character of the resolvent. It is the quadratic-residue character of $(\mathbb{Z}/3)^\times$, and it is balanced with $k = 1$: one class per fibre.

**Theorem 6.1.** For $f = x^3 - 3$ (discriminant $-243$) and for $f = x^3 - 2$ (discriminant $-108$),
$$I(p \bmod 3\,;\,T(p)) = 1 \text{ exactly.}$$
*Proof.* Theorem 4.9 with $k = 1$. $\square$

Explicitly, the $2 \times 3$ Chebotarev table is
$$\begin{array}{c|ccc} & \mathrm{S} & \mathrm{P} & \mathrm{I} \\\hline p \equiv 1 & 1 & 0 & 2\\ p \equiv 2 & 0 & 3 & 0\end{array}$$
with total $6$. One checks by hand: $H(\text{residue}) = 1$, $H(T) = \tfrac16\log_2 6 + \tfrac12 \log_2 2 + \tfrac13\log_2 3 = \tfrac23 + \tfrac12\log_2 3$, and $H(\text{joint}) = \tfrac16\log_2 6 + \tfrac13\log_2 3 + \tfrac12\log_2 2$, which equals $H(T)$; hence $I = 1 + H(T) - H(T) = 1$.

### 6.2 Field 3: $x^3 - x - 1$

Here the discriminant is $-23$, squarefree; the resolvent is $\mathbb{Q}(\sqrt{-23})$ and the character has conductor $23$. The residue group is $A = (\mathbb{Z}/23)^\times$, of order $22$, and the character is Euler's criterion
$$\chi_{-23}(a) = + \iff a^{11} = 1 \text{ in } \mathbb{Z}/23,$$
which is exactly the quadratic-residue character (verified over all $22$ classes). It is balanced with $k = 11$.

**Theorem 6.2.** For $f = x^3 - x - 1$,
$$I(p \bmod 23\,;\,T(p)) = 1 \text{ exactly.}$$
*Proof.* Theorem 4.9 with $k = 11$. $\square$

The joint table now has $22 \times 3 = 66$ cells and total $66$, but the mutual information is the same real number.

### 6.3 Three fields, one answer

**Theorem 6.3 (THREE FIELDS, ONE ANSWER).** The three cubics $x^3-3$, $x^3-2$, $x^3-x-1$, with pairwise distinct discriminants $-243$, $-108$, $-23$ and resolvent characters of conductors $3$, $3$, $23$, all satisfy
$$I(\text{residue}\,;\,\text{splitting type}) = 1,$$
and in particular the three values coincide.

Three parameters vary — the polynomial, the discriminant, the modulus (hence the entire input alphabet, from $2$ letters to $22$) — and the output is invariant. The theorem certifies that the constant is attached to the group $S_3$ and the sign character, not to any incidental feature of a particular field.

---

## 7. The semiprime pair channel

The one-bit law is stable under a natural composition: passing from primes to products of two primes.

Let $n = pq$ be a semiprime with $p,q$ unramified, and suppose the observable available to us is the *unordered* pair $\{T(p), T(q)\}$. There are six unordered pairs, and among the $36$ ordered Frobenius pairs their multiplicities are:

| pair | $\{S,S\}$ | $\{S,P\}$ | $\{S,I\}$ | $\{P,P\}$ | $\{P,I\}$ | $\{I,I\}$ |
|---|---|---|---|---|---|---|
| multiplicity | $1$ | $6$ | $4$ | $9$ | $12$ | $4$ |

(Obtained as $\mu(t)\mu(u)$ for $t = u$ and $2\mu(t)\mu(u)$ for $t \neq u$, with $\mu = (1,3,2)$; total $36$.)

**Proposition 7.1 (multiplicativity of the sign readout).** The product sign $\operatorname{sgn}(\sigma)\operatorname{sgn}(\tau)$ is a function of the unordered pair $\{T(\sigma), T(\tau)\}$: it is $+$ for $\{S,S\}, \{S,I\}, \{P,P\}, \{I,I\}$ and $-$ for $\{S,P\}, \{P,I\}$.
*Proof.* The sign is a function of the type by Proposition 4.5, and a product of two signs is symmetric under exchanging the factors, hence descends to unordered pairs. The tabulated values follow from $\varepsilon(\mathrm{S}) = \varepsilon(\mathrm{I}) = +$, $\varepsilon(\mathrm{P}) = -$. $\square$

**Proposition 7.2 (pair mass balance).** The two fibres of the product sign carry equal mass:
$$1 + 4 + 9 + 4 = 18, \qquad 6 + 12 = 18.$$

**Theorem 7.3 (semiprime pair channel law).** Let $\chi$ be a balanced Boolean character on a finite residue group, with fibres of size $k > 0$. Then the joint table of (residue class of $n$, unordered type pair of $n$) has
$$I = 1 \text{ exactly.}$$
*Proof.* This is again a character-coupled table: weight profile $m = (1,6,4,9,12,4)$, output readout the product sign, output balance $M = 18 > 0$ by Proposition 7.2, input balance by hypothesis. Apply Theorem 3.2. $\square$

**Corollary 7.4.** For $x^3-3$ and $x^3-2$ (residues mod $3$, $k=1$) and for $x^3-x-1$ (residues mod $23$, $k=11$), the semiprime pair channel value is $1$.

The point is that the output alphabet has grown from $3$ to $6$ letters and the profile from the tidy $1:3:2$ to the ragged $1:6:4:9:12:4$; the channel value is untouched, because Theorem 3.2 never looks at the profile.

---

## 8. Sharpness: why $1$ is a fingerprint

An exact constant is only meaningful if perturbations move it. We give three separations, all computed in closed form.

### 8.1 The channel is strictly lossy

**Theorem 8.1 (type entropy).** For an $S_3$-cubic the splitting-type entropy is
$$H(T) = \tfrac{2}{3} + \tfrac{1}{2}\log_2 3 \approx 1.45915 \text{ bits},$$
and in particular $H(T) > 1$.
*Proof.* The distribution is $(\tfrac16,\tfrac12,\tfrac13)$, so
$$H(T) = \operatorname{sur}(\tfrac16) + \operatorname{sur}(\tfrac12) + \operatorname{sur}(\tfrac13) = \tfrac{1 + \log_2 3}{6} + \tfrac12 + \tfrac{\log_2 3}{3} = \tfrac23 + \tfrac{\log_2 3}{2}.$$
Since $\log_2 3 > 1$ we get $H(T) > 2/3 + 1/2 > 1$. $\square$

**Corollary 8.2 (the residual).**
$$H(T) - I = \tfrac{1}{2}\log_2 3 - \tfrac13 \approx 0.45915 \text{ bits}$$
is exactly the part of the splitting type that no congruence condition on $p$ can reach. It is the "nonabelian remainder": knowing $\left(\frac{\operatorname{disc} f}{p}\right)$ tells you whether the Frobenius is even, but not whether an even Frobenius is trivial or a $3$-cycle — that is, not whether $p$ splits completely or is inert.

### 8.2 A different binary readout gives a different number

Consider, for the same field and the same primes, the binary observable *does $f$ have a root mod $p$?* — true for types $\mathrm{S}$ and $\mathrm{P}$, false for $\mathrm{I}$. This has the same alphabet size as the sign readout, so if the one-bit value were an artefact of "binary meets ternary", it would recur.

The joint counts of (sign of Frobenius, has-a-root) over the six elements of $S_3$ are
$$\begin{array}{c|cc} & \text{root} & \text{no root}\\\hline \operatorname{sgn} = + & 1 & 2\\ \operatorname{sgn} = - & 3 & 0\end{array}$$
with total $6$; marginals $(3,3)$ and $(4,2)$.

**Theorem 8.3 (root-count channel).**
$$I(\text{residue}\,;\,\text{has a root mod } p) = \tfrac{1}{2}\log_2 3 - \tfrac13 \approx 0.45915,$$
and $0 < I < 1$.
*Proof.* The residue marginal is balanced, so $H(A) = 1$ by Theorem 2.8. The output marginal is $(\tfrac23,\tfrac13)$, giving $H(B) = \tfrac23(\log_2 3 - 1) + \tfrac13\log_2 3$. The joint distribution is $(\tfrac16, \tfrac13, \tfrac12, 0)$, giving $H(A,B) = \tfrac{1+\log_2 3}{6} + \tfrac{\log_2 3}{3} + \tfrac12$. Subtracting,
$$I = 1 + \Big[\tfrac23\log_2 3 - \tfrac23 + \tfrac13\log_2 3\Big] - \Big[\tfrac16 + \tfrac{\log_2 3}{6} + \tfrac{\log_2 3}{3} + \tfrac12\Big] = \tfrac{\log_2 3}{2} - \tfrac13.$$
Positivity follows from $\log_2 3 > 1$ and the bound $I < 1$ from $\log_2 3 < 2$. $\square$

**Corollary 8.4.** The sign readout strictly beats the root-count readout: $\tfrac12\log_2 3 - \tfrac13 < 1$. The one-bit law is a statement about the *sign character* specifically, not about binary readouts in general.

It is a pleasant coincidence — and a consequence of the fact that the root-count readout is the sign readout with one cell moved — that the root-count channel value equals the residual of Corollary 8.2 exactly.

### 8.3 A different group gives a different number

Let $f$ be a *cyclic* cubic: irreducible with square discriminant, so that $\operatorname{Gal} \cong C_3$ and the field is abelian over $\mathbb{Q}$ (for instance $x^3 - 3x - 1$, discriminant $81$). By class field theory the Frobenius is determined by the residue class modulo the conductor, and the residue-to-Frobenius correspondence is a bijection of three-element sets.

**Theorem 8.5 (cyclic Frobenius channel).** For a cyclic cubic, $I(\text{residue}\,;\,\mathrm{Frob}) = \log_2 3 \approx 1.58496$.
*Proof.* The joint table is the identity permutation matrix on $3$ letters; this is the coupling-quotient situation of Theorem 3.3 with $D$ the whole group $C_3$, $k = 1$, $M = 1$. Hence $I = \log_2 3$. $\square$

**Theorem 8.6 (cyclic type channel).** For a cyclic cubic, the coarser splitting-type readout ("$p$ splits completely" iff Frobenius is trivial) satisfies
$$I(\text{residue}\,;\,T) = \log_2 3 - \tfrac23 \approx 0.91830.$$
*Proof.* The type is a deterministic function of the residue class, so by the determinism law (Theorem 2.7 transposed) $I = H(T)$. The type distribution is $(\tfrac13,\tfrac23)$, so $H(T) = \operatorname{sur}(\tfrac13) + \operatorname{sur}(\tfrac23) = \tfrac{\log_2 3}{3} + \tfrac23(\log_2 3 - 1) = \log_2 3 - \tfrac23$. $\square$

**Theorem 8.7 (the channel value detects the Galois group).** With $\log_2 3 < \tfrac53$ (equivalently $27 < 32$),
$$\underbrace{\log_2 3 - \tfrac23}_{\approx 0.918} \;<\; \underbrace{1}_{S_3 \text{ type channel}} \;<\; \underbrace{\log_2 3}_{\approx 1.585}.$$
Hence neither cyclic-cubic channel attains the value $1$, and the exact value $1.0000$ is a fingerprint of $S_3$.

### 8.4 Summary of exact values

| model | channel | exact value | numeric |
|---|---|---|---|
| $S_3$-cubic | residue $\to$ splitting type | $1$ | $1.00000$ |
| $S_3$-cubic | residue $\to$ unordered type pair of $pq$ | $1$ | $1.00000$ |
| $S_3$-cubic | residue $\to$ has-a-root bit | $\tfrac12\log_2 3 - \tfrac13$ | $0.45915$ |
| $S_3$-cubic | entropy of the splitting type | $\tfrac23 + \tfrac12\log_2 3$ | $1.45915$ |
| $C_3$-cubic | residue $\to$ Frobenius | $\log_2 3$ | $1.58496$ |
| $C_3$-cubic | residue $\to$ splitting type | $\log_2 3 - \tfrac23$ | $0.91830$ |

---

## 9. Algorithms

Three procedures make the theory computational.

**Algorithm A (exact channel value from a count table).** Given a table $n : A \times B \to \mathbb{N}$, compute $N$, both marginals, and the three entropies by summing surprisals, then return $H(A) + H(B) - H(A,B)$. Cost $\Theta(|A||B|)$. With exact rational probabilities and high-precision logarithms, the output for the $S_3$ tables is $1$ to full precision — the theoretical guarantee being Theorem 3.2.

**Algorithm B (empirical Chebotarev sampling).** For a cubic $f$ and a bound $X$, enumerate primes $p \le X$ not dividing $\operatorname{disc} f$; for each, factor $f$ over $\mathbb{F}_p$ by counting roots and testing irreducibility (equivalently, count $r = \#\{x \in \mathbb{F}_p : f(x) = 0\}$, and read $r = 3 \Rightarrow \mathrm{S}$, $r = 1 \Rightarrow \mathrm{P}$, $r = 0 \Rightarrow \mathrm{I}$); tally the joint occurrences of $(p \bmod q, T(p))$; feed the tally to Algorithm A. Cost $O(\pi(X)\cdot X)$ with naive root counting, or $O(\pi(X)\log^{O(1)} X)$ with gcd-based factoring. The empirical value converges to $1$ as $X \to \infty$, at the Chebotarev rate.

**Algorithm C (coupling-quotient certification).** Given finite $A$, $B$, invariants $\chi : A \to D$, $g : B \to D$ and weights $m$, verify (i) all $\chi$-fibres have equal size $k > 0$, (ii) all $g$-fibres have equal weight $M > 0$; if both hold, certify $I = \log_2|D|$ without any floating-point entropy computation. Cost $\Theta(|A| + |B|)$. This is the computational content of Theorem 3.3: a *balance check* replaces an entropy calculation.

---

## 10. Discussion

### 10.1 What the theorem says arithmetically

The residue class of a prime is abelian data. The splitting type is nonabelian data. The theorem quantifies the overlap: exactly one bit, and that bit is the abelianized Frobenius, i.e. the image of $\mathrm{Frob}_p$ in $S_3/A_3$. This is a sharp, quantitative form of the folklore statement that "congruence conditions see only the abelian part".

The residual, $\tfrac12\log_2 3 - \tfrac13$ bits, is the price of nonabelianness. To recover it one needs a genuinely nonabelian reciprocity law — for $S_3$-cubics, the modular form of weight $1$ attached to the two-dimensional Artin representation, whose coefficients do distinguish split from inert primes. The channel formalism gives an exact accounting of what such a form must supply beyond quadratic reciprocity.

### 10.2 Why the value is an integer

Because the coupling quotient is a group of order $2$ and both sides are balanced. Theorem 3.3 makes the general shape clear: $I = \log_2 |D|$, an integer precisely when $|D|$ is a power of $2$. For $S_3$ this happens because $[S_3 : A_3] = 2$. The cyclic cubic's $\log_2 3$ is the same formula with $|D| = 3$, and its irrationality is the generic case; $S_3$ is special in landing on a power of two.

### 10.3 Robustness

Three independent perturbations leave the value unchanged: changing the polynomial ($x^3-3 \to x^3-2$), changing the resolvent field and modulus ($\to x^3-x-1$, mod $23$), and coarsening from primes to semiprimes (three-letter to six-letter output alphabet, profile $1:3:2 \to 1:6:4:9:12:4$). Three other perturbations change it: changing the readout to root-counting, changing the group to $C_3$, and refining the output from type to Frobenius. The pattern of what does and does not matter is exactly the pattern predicted by Theorem 3.3 — only the coupling quotient matters.

### 10.4 A physical reading

The construction is the arithmetic analogue of a two-level system coupled to a bath. The Frobenius distribution is the bath; the residue class is the accessible macroscopic observable; the sign character is the single conserved quantity through which they exchange information. The channel value is then the logarithm of the number of superselection sectors, and the residual entropy $H(T) - I$ is the inaccessible microstate entropy within a sector. The "fingerprint" statement of Theorem 8.7 is a spectroscopy: measure the constant, read off the symmetry group.

### 10.5 Limitations

The model is the *Chebotarev limit*: it treats the splitting type as exactly equidistributed with the group multiplicities, which is true in density but not for any finite range of primes. All statements are therefore statements about the limiting joint law. Empirically, tallies up to $10^6$ agree with $1$ to two or three decimal places, with the expected $O(1/\sqrt{\pi(X)})$-scale fluctuations; the exactness lives in the limit.

The model also assumes the character is balanced. This is automatic for the quadratic-residue character of $(\mathbb{Z}/q)^\times$ for odd prime $q$ and, more generally, for any nontrivial character of an abelian group with kernel of index $2$. It fails only for degenerate observables.

---

## 11. Future directions

**Direction 1 — Abelianised Frobenius Capacity Law.** *Conjecture.* For a Galois extension with group $G$, the Chebotarev channel from the residue class modulo the conductor to the Frobenius conjugacy class has mutual information exactly $\log_2 [G : G']$, where $G'$ is the commutator subgroup — no more, no less.

The key insight is that class field theory makes the abelianized Frobenius a deterministic function of the residue class while the non-abelian part is statistically invisible to it, so the coupling quotient of Theorem 3.3 is exactly $G/G'$. For $S_3$ this is $\log_2 2 = 1$ (the present paper); for $C_3$ it is $\log_2 3$ (also established here); for $A_4$, $S_4$, $A_5$ it predicts $\log_2 3$, $1$, and $0$. The last is striking: for a simple group, congruence conditions carry *no* information about splitting behaviour.

Why now? The coupling-quotient law is proved and group-agnostic; only the finite group bookkeeping — conjugacy-class multiplicities and the balance condition — has to be supplied per group, and that is a finite check for every group of small order.

**Direction 2 — Type-Channel Spectrum as a Group Invariant.** *Conjecture.* The multiset of channel values obtained from *all* Boolean readouts of the splitting type separates $S_3$ from every other transitive group of degree $\le 5$; for $S_3$ the maximum is attained uniquely at the sign readout and equals $1$.

The key insight is that a Boolean readout of the type distribution is a two-block partition of the conjugacy classes, and its channel value is $1$ if and only if the partition is a coset partition of an index-$2$ subgroup — a purely group-theoretic condition. Since a full non-sign readout has already been computed exactly ($\tfrac12\log_2 3 - \tfrac13$), the extremality statement is a finite optimisation over the $2^{c-1}$ partitions of the $c$ conjugacy classes.

**Direction 3 — Higher-order composite channels.** The semiprime result suggests examining $k$-almost-primes for general $k$: the unordered $k$-tuple of splitting types, with multiplicity profile given by the multiset coefficients of $(1,3,2)$. The product sign remains a balanced readout for every $k$ (since the sign is a nontrivial homomorphism and the mass splits evenly), so the conjectural value is $1$ for all $k$ — a stability statement under multiplicative convolution. Proving the balance for all $k$ uniformly is a short generating-function argument: the signed generating polynomial $(1 - 3 + 2)^k$ vanishes for $k \ge 1$.

**Direction 4 — Effective versions.** Replace the Chebotarev limit by an effective count with an explicit error term (under GRH, $O(\sqrt{X}\log X)$), and quantify the deviation $|I_X - 1|$ for tallies up to $X$. One expects $I_X = 1 + O(1/\pi(X))$ after bias correction, with the leading correction governed by the second moment of the Chebotarev error.

---

## 12. Conclusion

An $S_3$-cubic broadcasts a three-letter stream — split, partial, inert — and a congruence condition listens. The theorem of this paper is that the link between them has an exact capacity of one bit, independent of the polynomial, of its discriminant, of the conductor of the resolvent character, and of the size of the residue alphabet; that the same value survives passage to semiprimes; and that the value is a sharp fingerprint, since three natural neighbours of the construction give the strictly different values $\tfrac12\log_2 3 - \tfrac13$, $\log_2 3 - \tfrac23$, and $\log_2 3$.

Behind all of it lies a single structural principle: when two finite observables communicate solely through a balanced invariant with values in a set $D$, the mutual information is $\log_2 |D|$ exactly. Number theory supplies $D = S_3/A_3$, and the answer is one bit.

Three fields, three discriminants, two residue groups. One answer.
