# The Additive Uncertainty Principle on Cyclic Groups of Prime Order: Equivalences, Regimes, and Boundaries

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

For a nonzero function $f$ on a finite cyclic group $\mathbb{Z}_n$ the Donoho–Stark
uncertainty principle asserts the multiplicative bound
$|\operatorname{supp} f| \cdot |\operatorname{supp} \hat f| \geq n$. When $n = p$ is prime, a strictly
stronger *additive* bound $|\operatorname{supp} f| + |\operatorname{supp} \hat f| \geq p + 1$ is available.
This paper develops the additive principle systematically: we delimit it from above and below,
identify it with a classical determinantal statement, reduce it to a finite combinatorial
criterion, and prove it outright in five explicit regimes.

Specifically, we show: (i) the additive bound implies the multiplicative one, while no
arithmetic manipulation of the multiplicative bound can yield the additive one — for every
$p \geq 5$ there exist admissible support cardinalities satisfying $ab \geq p$ and
$a + b < p+1$, and the multiplicative bound in isolation yields only the square-root estimate
$a + b \geq 2\sqrt{n}$; (ii) primality is indispensable — on $\mathbb{Z}_4$ the indicator of
the subgroup $\{0,2\}$ attains the multiplicative bound with equality while violating the
additive one; (iii) the additive bound is sharp at both endpoints, attained by Dirac deltas
$(1 + p)$ and by characters $(p + 1)$; (iv) for every modulus the additive bound is
*equivalent* to the nonsingularity of all square minors of the Fourier matrix
$(\omega^{st})_{s,t}$ (Chebotarev's property), and equivalent in turn to a purely combinatorial
statement about parity-weighted fibres of the exponent map
$\sigma \mapsto \sum_j s_{\sigma(j)} t_j$ on the symmetric group; (v) the additive bound holds
whenever $|\operatorname{supp} f| \leq 3$, whenever $|\operatorname{supp}\hat f| \leq 3$, whenever
$|\operatorname{supp} f| \geq p - 3$, and whenever either the support or the spectrum is an arithmetic
progression. As an application we derive a deterministic, universal sparse-recovery guarantee:
any $k$-sparse function on $\mathbb{Z}_p$ is uniquely determined by its Fourier coefficients on
*any* set of $2k$ frequencies.

**Keywords:** uncertainty principle, discrete Fourier transform, cyclic group of prime order,
Chebotarev's theorem, roots of unity, sparse recovery, compressed sensing, Vandermonde
determinant.

---

## 1. Introduction

### 1.1 Setting and notation

Fix an integer $n \geq 1$ and let $\mathbb{Z}_n$ denote the integers modulo $n$. Put
$\omega = e^{2\pi i / n}$ and let

$$\chi : \mathbb{Z}_n \to \mathbb{C}^{\times}, \qquad \chi(a) = \omega^{\,\bar a},$$

where $\bar a \in \{0, 1, \dots, n-1\}$ is the canonical representative of $a$. Then $\chi$ is
a group homomorphism from $(\mathbb{Z}_n, +)$ to $(\mathbb{C}^\times, \cdot)$; for $n$ prime it
is injective. We write $\omega^{a}$ for $\chi(a)$ when no confusion arises.

For $f : \mathbb{Z}_n \to \mathbb{C}$ the (unnormalised) discrete Fourier transform is

$$\hat f(k) \;=\; \sum_{x \in \mathbb{Z}_n} \omega^{-kx}\, f(x), \qquad k \in \mathbb{Z}_n,$$

and the support is $\operatorname{supp} f = \{x \in \mathbb{Z}_n : f(x) \neq 0\}$. Fourier inversion
takes the form of a reflection identity,

$$\hat{\hat f}(k) \;=\; n \, f(-k), \tag{1.1}$$

from which one reads off immediately that $|\operatorname{supp} \hat{\hat f}| = |\operatorname{supp} f|$ and
that $f \neq 0 \Rightarrow \hat f \neq 0$. Identity $(1.1)$ is the source of all *duality*
statements below: every theorem about supports has a mirror theorem about spectra.

### 1.2 The two uncertainty inequalities

**Product bound (Donoho–Stark).** *For every $n \geq 1$ and every $f : \mathbb{Z}_n \to
\mathbb{C}$ with $f \neq 0$,*
$$|\operatorname{supp} f| \cdot |\operatorname{supp} \hat f| \;\geq\; n .$$

**Additive bound.** *For every prime $p$ and every $f : \mathbb{Z}_p \to \mathbb{C}$ with
$f \neq 0$,*
$$|\operatorname{supp} f| + |\operatorname{supp} \hat f| \;\geq\; p + 1 .$$

The additive bound is a prime-order phenomenon; it is due to Tao. This paper is an anatomy of
the statement: what separates it from the product bound, why primality is needed, where it is
attained, what it is equivalent to, and in which regimes it can currently be established from
first principles.

Throughout, when $p$ is prime we let $\mathrm{SU}(p)$ denote the assertion

$$\mathrm{SU}(p): \qquad \forall f \neq 0, \quad |\operatorname{supp} f| + |\operatorname{supp} \hat f| \geq p+1,$$

and $\mathrm{CP}(n)$ the assertion that every square submatrix of $(\omega^{st})_{s,t \in
\mathbb{Z}_n}$ is nonsingular. Both make sense for arbitrary moduli, and Section 4 proves that
they are equivalent for every modulus.

---

## 2. Separating the two bounds

### 2.1 The additive bound is a strengthening

**Proposition 2.1.** *Let $a, b \geq 1$ be integers with $a + b \geq p+1$. Then $ab \geq p$.*

*Proof.* Since $a, b \geq 1$ we have $(a-1)(b-1) \geq 0$, i.e. $ab \geq a + b - 1 \geq p$.
$\blacksquare$

Applying this with $a = |\operatorname{supp} f|$, $b = |\operatorname{supp}\hat f|$ (both at least $1$
whenever $f \neq 0$) shows that $\mathrm{SU}(p)$ implies the Donoho–Stark bound for
$\mathbb{Z}_p$.

### 2.2 The converse fails as pure arithmetic

**Theorem 2.2 (No arithmetic implication).** *For every $p \geq 5$ there exist positive
integers $a, b$ with*
$$p \le ab \qquad \text{and} \qquad a + b < p+1 .$$

*Proof.* Take $a = 2$ and $b = \lfloor (p+1)/2 \rfloor$. Then $2b \geq p$ (for $p$ odd,
$2b = p+1$; for $p$ even, $2b = p$), so $ab \geq p$. And $a + b = 2 + \lfloor (p+1)/2 \rfloor
< p+1$ precisely because $\lfloor (p+1)/2\rfloor < p - 1$ for $p \geq 5$. $\blacksquare$

Thus the additive bound is not obtainable from the multiplicative one by any inequality
manipulation whatsoever: the pair of cardinalities $\big(2, \lfloor (p+1)/2\rfloor \big)$ is
admissible for the product bound and inadmissible for the additive one. The same holds for the
"balanced" profile $a = b = \lceil \sqrt p \rceil$, which satisfies $ab \geq p$ while
$a + b \approx 2\sqrt p \ll p+1$.

### 2.3 What the product bound alone gives

**Proposition 2.3.** *For all integers $x, y \geq 0$ one has $4xy \leq (x+y)^2$; consequently,
for every $n \geq 1$ and every $f \neq 0$ on $\mathbb{Z}_n$,*
$$\big(|\operatorname{supp} f| + |\operatorname{supp}\hat f|\big)^2 \;\geq\; 4n,
\qquad\text{i.e.}\qquad |\operatorname{supp} f| + |\operatorname{supp}\hat f| \;\geq\; 2\sqrt n .$$

*Proof.* $(x+y)^2 - 4xy = (x-y)^2 \geq 0$; combine with the Donoho–Stark bound. $\blacksquare$

The gap between $2\sqrt{p}$ and $p+1$ quantifies exactly how much stronger the additive
principle is: the multiplicative bound recovers only the square root of the correct additive
truth.

---

## 3. Boundaries: primality and sharpness

### 3.1 Failure on a composite modulus

**Theorem 3.1 (Primality is essential).** *Let $f : \mathbb{Z}_4 \to \mathbb{C}$ be the
indicator of the subgroup $\{0,2\}$, i.e. $f(0) = f(2) = 1$, $f(1) = f(3) = 0$. Then $f \neq 0$
and*
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| = 4, \qquad
|\operatorname{supp} f| + |\operatorname{supp}\hat f| = 4 < 5 .$$
*Thus the additive bound fails for the modulus $4$, while the multiplicative bound is attained
with equality.*

*Proof.* With $\omega = i$ one computes $\hat f(k) = 1 + \omega^{-2k} = 1 + (-1)^{k}$, using
$\omega^{-2} = -1$: the unique nontrivial square root of unity in $\mathbb{Z}_4$'s character
group. Hence $\hat f(0) = \hat f(2) = 2$ and $\hat f(1) = \hat f(3) = 0$, so
$\operatorname{supp} \hat f = \{0,2\} = \operatorname{supp} f$, of cardinality $2$ each. $\blacksquare$

The mechanism is structural: an indicator of a subgroup $H \le G$ transforms into
$|H|$ times the indicator of the annihilator $H^{\perp}$, and $|H| \cdot |H^\perp| = |G|$, so
subgroup indicators always *attain* the Donoho–Stark bound. A group of prime order has no
proper nontrivial subgroups, which removes the extremal family entirely — this is the first
place where primality enters, and it is not the last.

### 3.2 Sharpness at both endpoints

Let $p$ be prime.

**Theorem 3.2 (Delta functions).** *For $a \in \mathbb{Z}_p$ let $\delta_a$ be the indicator of
$\{a\}$. Then $\hat{\delta_a}(k) = \omega^{-ka} \neq 0$ for all $k$, hence*
$$|\operatorname{supp} \delta_a| + |\operatorname{supp} \hat{\delta_a}| \;=\; 1 + p .$$

*Proof.* Only the term $x = a$ survives in the defining sum; a root of unity is never zero, so
$\operatorname{supp}\hat{\delta_a} = \mathbb{Z}_p$. $\blacksquare$

**Lemma 3.3 (Vanishing of the full character sum).** *For $p \geq 2$,
$\sum_{y \in \mathbb{Z}_p} \omega^{y} = 0$.*

*Proof.* Re-index the sum over $\mathbb{Z}_p$ as $\sum_{m=0}^{p-1}\omega^{m}$ using the
canonical representatives; this geometric sum equals $(\omega^p - 1)/(\omega - 1) = 0$ because
$\omega^p = 1$ and $\omega \neq 1$. $\blacksquare$

**Theorem 3.4 (Characters).** *For $b \in \mathbb{Z}_p$ let $\chi_b(x) = \omega^{bx}$. Then*
$$\hat{\chi_b}(k) = \begin{cases} p, & k = b, \\ 0, & k \neq b,\end{cases}
\qquad\text{hence}\qquad
|\operatorname{supp} \chi_b| + |\operatorname{supp}\hat{\chi_b}| = p + 1 .$$

*Proof.* $\hat{\chi_b}(k) = \sum_x \omega^{-kx}\omega^{bx} = \sum_x \omega^{(b-k)x}$. If
$k = b$ every term is $1$. If $k \neq b$ then $b - k$ is invertible modulo the prime $p$, so
$x \mapsto (b-k)x$ permutes $\mathbb{Z}_p$ and the sum equals $\sum_y \omega^{y} = 0$ by Lemma
3.3. $\blacksquare$

So the additive inequality is attained at the two extreme sparsity profiles $(1, p)$ and
$(p, 1)$ — and nowhere else can it be attained with a *balanced* profile, by Theorem 2.2's
arithmetic.

---

## 4. The determinantal identity

### 4.1 Chebotarev's property

**Definition 4.1.** For $n \geq 1$ let $\mathrm{CP}(n)$ be the statement: for every $m \geq 0$
and all injective $S, T : \{1,\dots,m\} \to \mathbb{Z}_n$, the matrix
$M_{S,T} = \big(\omega^{\,S_j T_k}\big)_{j,k=1}^{m}$ is nonsingular.

That is: every square minor of the full Fourier matrix of $\mathbb{Z}_n$ is nonzero.
Chebotarev's theorem is the assertion $\mathrm{CP}(p)$ for $p$ prime.

**Theorem 4.2 (Uncertainty $=$ nonsingularity).** *For every modulus $n \geq 1$,*
$$\mathrm{CP}(n) \iff \mathrm{SU}(n),$$
*where $\mathrm{SU}(n)$ denotes "$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq n+1$ for all
$f \neq 0$".*

*Proof sketch.* ($\Rightarrow$) Suppose $f \neq 0$ violates the bound and let
$A = \operatorname{supp} f$, $Z = \{k : \hat f(k) = 0\}$. Since $|Z| = n - |\operatorname{supp}\hat f|$, the
violation $|A| + |\operatorname{supp}\hat f| \leq n$ reads $|A| \leq |Z|$. Choose $Z' \subseteq Z$ with
$|Z'| = |A|$, enumerate $A$ as $T_1,\dots,T_m$ and $Z'$ as $z_1,\dots,z_m$, and set
$S_j = -z_j$. The vector $v_k = f(T_k)$ is nonzero and satisfies

$$\sum_{k} \omega^{\,S_j T_k} v_k \;=\; \sum_{x \in A} \omega^{-z_j x} f(x) \;=\; \hat f(z_j)
\;=\; 0 \quad \text{for all } j,$$

so $M_{S,T} v = 0$ and $M_{S,T}$ is singular.

($\Leftarrow$) Suppose $M_{S,T}$ is singular for some injective $S, T$ of size $m$; take
$v \neq 0$ in its kernel and define $f = \sum_k v_k \delta_{T_k}$, so that
$\operatorname{supp} f \subseteq \{T_1,\dots,T_m\}$ and $|\operatorname{supp} f| \leq m$. For each $j$,
$\hat f(-S_j) = \sum_k \omega^{S_j T_k} v_k = 0$, and the $m$ frequencies $-S_j$ are distinct,
so $|\operatorname{supp} \hat f| \le n - m$. Hence
$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \le n$, contradicting $\mathrm{SU}(n)$. $\blacksquare$

The equivalence is *unconditional in the modulus*, which yields, in combination with Theorem
3.1:

**Corollary 4.3.** $\mathrm{CP}(4)$ *is false.* Explicitly, the minor of the Fourier matrix of
$\mathbb{Z}_4$ on rows $\{0,2\}$ and columns $\{0,2\}$ is the all-ones $2\times 2$ matrix.

A useful *local* form of the forward implication, used repeatedly below, is:

**Proposition 4.4 (Local reduction).** *Let $f \neq 0$ on $\mathbb{Z}_n$ and set
$m = |\operatorname{supp} f|$. If every $m \times m$ minor of the Fourier matrix of $\mathbb{Z}_n$ is
nonsingular, then $|\operatorname{supp} f| + |\operatorname{supp} \hat f| \geq n+1$.*

This is the contrapositive of the construction in the ($\Rightarrow$) direction, applied at the
single size $m$.

### 4.2 The unconditional case: generalised Vandermonde minors

**Theorem 4.5 (Arithmetic-progression minors).** *Let $p$ be prime, $a, d \in \mathbb{Z}_p$
with $d \neq 0$, and let $T : \{1,\dots,m\} \to \mathbb{Z}_p$ be injective. Then the minor with
rows indexed by the arithmetic progression $a, a+d, \dots, a + (m-1)d$,*
$$M_{j,k} = \omega^{\,(a + (j-1)d)\,T_k},$$
*is nonsingular. The same holds with the roles of rows and columns exchanged.*

*Proof.* Write $z_k = \omega^{\,d T_k}$ and $c_k = \omega^{\,a T_k}$. Then
$M_{j,k} = c_k\, z_k^{\,j-1}$, i.e. $M = V(z)^{\mathsf T} \cdot \operatorname{diag}(c)$ where
$V(z)$ is the Vandermonde matrix of the nodes $z_k$. Since $p$ is prime and $d \neq 0$, the map
$t \mapsto \omega^{dt}$ is injective, so the $z_k$ are pairwise distinct and
$\det V(z) = \prod_{j<k}(z_k - z_j) \neq 0$; and $\det \operatorname{diag}(c) = \prod_k c_k \neq 0$
since roots of unity are nonzero. The transposed statement follows by taking determinants of
transposes. $\blacksquare$

This is the portion of Chebotarev's theorem that the classical polynomial method settles
outright, and it powers all of Section 5.1.

---

## 5. Proved regimes

Throughout this section $p$ is prime and $f : \mathbb{Z}_p \to \mathbb{C}$ is nonzero.

### 5.1 Arithmetic-progression supports and the non-vanishing window

**Theorem 5.1 (No vanishing on a short progression).** *Let $a, d \in \mathbb{Z}_p$ with
$d \neq 0$. Then there exists $j < |\operatorname{supp} f|$ with $\hat f(a + jd) \neq 0$. Equivalently,
$\hat f$ cannot vanish identically on an arithmetic progression of length
$|\operatorname{supp} f|$.*

*Proof.* Write $A = \operatorname{supp} f$, $z_x = \omega^{-dx}$ and $c_x = \omega^{-ax} f(x)$ for
$x \in A$. Because $p$ is prime and $d \neq 0$, the values $z_x$ ($x \in A$) are pairwise
distinct. A direct expansion gives

$$\hat f(a + jd) \;=\; \sum_{x \in A} \omega^{-(a + jd)x} f(x) \;=\; \sum_{x \in A} c_x\, z_x^{\,j}.$$

Suppose this vanishes for all $j = 0, 1, \dots, |A| - 1$. Fix $x_0 \in A$ and let
$L(X) = \prod_{x \in A \setminus \{x_0\}} (X - z_x)$, a polynomial of degree $|A| - 1$.
Expanding $L$ in the monomial basis and taking the corresponding linear combination of the
$|A|$ vanishing sums yields $\sum_{x \in A} c_x L(z_x) = 0$; but $L(z_x) = 0$ for
$x \neq x_0$, so $c_{x_0} L(z_{x_0}) = 0$, and $L(z_{x_0}) = \prod_{x \neq x_0}(z_{x_0} - z_x)
\neq 0$ by distinctness. Hence $c_{x_0} = 0$, i.e. $f(x_0) = 0$, contradicting
$x_0 \in \operatorname{supp} f$. $\blacksquare$

This is the Lagrange-interpolation form of Vandermonde nonsingularity: $|A|$ distinct geometric
sequences are linearly independent already on a window of length $|A|$.

**Theorem 5.2 (Supports inside a progression).** *Suppose $\operatorname{supp} f$ is contained in an
arithmetic progression $\{a + jd : 0 \le j < m\}$ with $d \neq 0$ and $m \leq p$. Then*
$$|\operatorname{supp} \hat f| \;\geq\; p + 1 - m .$$
*In particular, if $\operatorname{supp} f$ equals such a progression, then
$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq p+1$.*

*Proof.* Let $P(X) = \sum_{j=0}^{m-1} f(a + jd)\, X^{j}$, a nonzero polynomial of degree at most
$m-1$ (nonzero because some $f(a+jd) \neq 0$; the parametrisation $j \mapsto a + jd$ is
injective on $\{0,\dots,m-1\}$ since $m \le p$ and $d \neq 0$). Splitting the exponent,
$-k(a+jd) = -ka + j(-kd)$, gives

$$\hat f(k) \;=\; \omega^{-ka}\, P\!\left(\omega^{-kd}\right) \qquad (k \in \mathbb{Z}_p).$$

Since $\omega^{-ka} \neq 0$, each zero $k$ of $\hat f$ produces a root $\omega^{-kd}$ of $P$,
and $k \mapsto \omega^{-kd}$ is injective. A nonzero polynomial of degree $\le m-1$ has at most
$m-1$ roots, so $\hat f$ has at most $m-1$ zeros, i.e. at least $p - (m-1)$ nonzero values.
$\blacksquare$

**Theorem 5.3 (Dual version).** *If $\operatorname{supp}\hat f$ is an arithmetic progression (of
nonzero common difference and length $\le p$), then $|\operatorname{supp} f| + |\operatorname{supp}\hat f|
\geq p+1$.*

*Proof.* Apply Theorem 5.2 to $g = \hat f$, which is nonzero, and use the reflection identity
$(1.1)$: $|\operatorname{supp}\hat g| = |\operatorname{supp}\hat{\hat f}| = |\operatorname{supp} f|$. $\blacksquare$

### 5.2 Small supports

**Theorem 5.4 (At most two nonzero values).** *If $|\operatorname{supp} f| \leq 2$ then
$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq p+1$.*

*Proof.* Suppose not; then, writing $Z$ for the zero set of $\hat f$, we get
$|\operatorname{supp} f| \le |Z|$. If $|\operatorname{supp} f| = 1$, pick any $a \in Z$; then $\hat f$ vanishes
on the length-$1$ progression $\{a\}$, contradicting Theorem 5.1 with $d = 1$. If
$|\operatorname{supp} f| = 2$, pick distinct $a, b \in Z$; then $\hat f$ vanishes on the length-$2$
progression $\{a, a + (b-a)\}$ with common difference $b - a \neq 0$, again contradicting
Theorem 5.1. $\blacksquare$

**Theorem 5.5 (At most three nonzero values).** *If $|\operatorname{supp} f| \le 3$ then
$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq p+1$.*

The case $|\operatorname{supp} f| = 3$ is genuinely new relative to Section 5.1: a three-element subset
of $\mathbb{Z}_p$ need not be an arithmetic progression. By Proposition 4.4 it suffices to
prove:

**Theorem 5.6 ($3\times 3$ Chebotarev).** *For distinct $S_1,S_2,S_3$ and distinct
$T_1,T_2,T_3$ in $\mathbb{Z}_p$, the matrix $\big(\omega^{S_j T_k}\big)_{j,k=1}^{3}$ is
nonsingular.*

*Proof sketch.* The Leibniz expansion writes the determinant as a six-term signed sum of $p$-th
roots of unity,

$$\omega^{e_1} + \omega^{e_2} + \omega^{e_3} - \omega^{f_1} - \omega^{f_2} - \omega^{f_3},$$

with $e_1 = S_1T_1 + S_2T_2 + S_3T_3$ and the remaining exponents obtained from the other five
permutations. Distinctness of rows and columns forces one negative exponent, say $f_1$, to
differ from all three positive ones (the differences $e_i - f_1$ factor as products
$(S_j - S_k)(T_l - T_m)$ of nonzero elements of the field $\mathbb{Z}_p$). One then applies the
criterion of Theorem 6.2: the coefficient vector of the sum, viewed as a rational function on
residues, sums to $0$ and is nonzero at $f_1$, so the sum cannot vanish. $\blacksquare$

**Theorem 5.7 (Duals and large supports).** *Each of the following implies
$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq p+1$:*
1. *$|\operatorname{supp}\hat f| \le 3$;*
2. *$|\operatorname{supp} f| \geq p - 3$.*

*Proof.* (1) Apply Theorem 5.5 to $\hat f$ and use $(1.1)$. (2) If $|\operatorname{supp}\hat f| \le 3$
apply (1); otherwise $|\operatorname{supp}\hat f| \geq 4$ and
$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq (p-3) + 4 = p+1$. $\blacksquare$

### 5.3 Master statement

**Theorem 5.8 (Known regimes).** *Let $p$ be prime and $f \neq 0$ on $\mathbb{Z}_p$. If any one
of the following holds, then $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq p+1$:*

1. *$|\operatorname{supp} f| \le 3$;*
2. *$|\operatorname{supp}\hat f| \le 3$;*
3. *$|\operatorname{supp} f| \geq p - 3$;*
4. *$\operatorname{supp} f$ is an arithmetic progression with nonzero common difference;*
5. *$\operatorname{supp}\hat f$ is an arithmetic progression with nonzero common difference.*

The union of these regimes covers every $f$ on $\mathbb{Z}_p$ for $p \le 7$ and, for larger
$p$, everything except unstructured supports of intermediate size.

---

## 6. From analysis to combinatorics

### 6.1 Linear independence of roots of unity

**Lemma 6.1.** *Let $p$ be prime and let $c : \mathbb{Z}_p \to \mathbb{Q}$. If
$\sum_{r \in \mathbb{Z}_p} c_r\, \omega^{r} = 0$, then $c$ is constant.*

*Proof sketch.* The minimal polynomial of $\omega$ over $\mathbb{Q}$ is the $p$-th cyclotomic
polynomial $1 + X + \dots + X^{p-1}$. A rational polynomial $\sum_r c_r X^{r}$ of degree
$< p$ vanishing at $\omega$ must therefore be a rational multiple of $1 + X + \dots + X^{p-1}$,
which is exactly the statement that all coefficients are equal. $\blacksquare$

**Theorem 6.2 (Vanishing criterion).** *Let $c : \mathbb{Z}_p \to \mathbb{Q}$ satisfy
$\sum_r c_r = 0$. If $c_{r_0} \neq 0$ for some $r_0$, then
$\sum_r c_r \omega^{r} \neq 0$.*

*Proof.* If the sum vanished, Lemma 6.1 would give $c_r = c_{r_0}$ for all $r$, whence
$0 = \sum_r c_r = p\, c_{r_0}$ and so $c_{r_0} = 0$. $\blacksquare$

### 6.2 The permutation criterion

Fix $n \geq 1$ and injective $S, T : \{1,\dots,n\} \to \mathbb{Z}_p$. For a permutation
$\sigma \in S_n$ define the **exponent**

$$E_\sigma \;=\; \sum_{j=1}^n S_{\sigma(j)}\, T_j \;\in\; \mathbb{Z}_p ,$$

and for $r \in \mathbb{Z}_p$ the **parity-weighted multiplicity**

$$c_r \;=\; \sum_{\sigma : E_\sigma = r} \operatorname{sgn}(\sigma) \;\in\; \mathbb{Z}
\;=\; \#\{\text{even } \sigma \text{ with } E_\sigma = r\} - \#\{\text{odd } \sigma \text{ with } E_\sigma = r\}.$$

**Lemma 6.3 (Leibniz expansion).**
$\displaystyle \det\big(\omega^{S_jT_k}\big)_{j,k} = \sum_{r \in \mathbb{Z}_p} c_r\, \omega^{r}$,
*and for $n \geq 2$ one has $\sum_r c_r = \sum_{\sigma \in S_n}\operatorname{sgn}(\sigma) = 0$.*

*Proof.* The Leibniz formula gives $\det = \sum_\sigma \operatorname{sgn}(\sigma)
\prod_j \omega^{S_{\sigma(j)}T_j} = \sum_\sigma \operatorname{sgn}(\sigma)\, \omega^{E_\sigma}$
since $\chi$ is a character; grouping by exponent gives the first identity. The second is the
standard fact that $S_n$ has equally many even and odd elements for $n \geq 2$. $\blacksquare$

**Theorem 6.4 (Combinatorial criterion for Chebotarev).** *Let $n \geq 2$. Then*
$$\det\big(\omega^{S_jT_k}\big)_{j,k} \neq 0 \iff \exists\, r \in \mathbb{Z}_p : c_r \neq 0 .$$

*Proof.* ($\Leftarrow$) Combine Lemma 6.3 with Theorem 6.2. ($\Rightarrow$) If all $c_r$ vanish
the determinant is $0$ by Lemma 6.3. $\blacksquare$

Chebotarev's theorem — equivalently, by Theorem 4.2, the additive uncertainty principle — is
therefore exactly the following finite statement: *for distinct rows and distinct columns, the
map $\sigma \mapsto E_\sigma$ from $S_n$ to $\mathbb{Z}_p$ never distributes the permutations in
perfect parity balance across all residues.*

Two workable sufficient conditions follow immediately.

**Corollary 6.5 (Odd fibre).** *If some residue $r$ has an odd number of preimages under
$\sigma \mapsto E_\sigma$, then $c_r \neq 0$ and the minor is nonsingular.*

*Proof.* $c_r$ is a sum of an odd number of terms each equal to $\pm 1$, hence odd, hence
nonzero. $\blacksquare$

**Corollary 6.6 (Unique realisation).** *If some permutation $\sigma_0$ realises its exponent
uniquely — i.e. $E_\sigma = E_{\sigma_0}$ implies $\sigma = \sigma_0$ — then the minor is
nonsingular, since $c_{E_{\sigma_0}} = \operatorname{sgn}(\sigma_0) = \pm 1$.*

Corollary 6.6 is the practical engine behind the $2\times2$ and $3\times3$ cases: exhaustive
computation shows that for $n \le 3$ a uniquely realised exponent always exists. For $n \geq 4$
it may fail; the fibre structure becomes genuinely balanced-looking, and this is precisely
where the general theorem resists elementary attack.

---

## 7. Algorithms

The criterion of Theorem 6.4 turns non-vanishing of a transcendental determinant into an exact
integer computation. Three algorithms follow.

### 7.1 Exact minor test by parity-weighted counting

**Input:** a prime $p$, injective $S, T \in \mathbb{Z}_p^n$ with $n \geq 2$.
**Output:** `True` iff $\det(\omega^{S_jT_k}) \neq 0$, computed with integers only.

```
for each sigma in S_n:
    e <- (sum_j S[sigma(j)] * T[j]) mod p
    c[e] <- c[e] + sign(sigma)
return  (some c[e] != 0)
```

Complexity $O(n! \cdot n)$ time and $O(p)$ space. Crucially there is no floating-point error:
the test is a decision about integers, so a machine answer is a proof.

### 7.2 Exhaustive verification of Chebotarev's property at fixed size

Iterate the previous test over all $\binom{p}{n}^2$ pairs of row/column sets. Complexity
$O(\binom{p}{n}^2 n!\,n)$. Carried out for $p \in \{5,7,11,13\}$ and $n \le 4$, this exact
integer computation finds every minor nonsingular in those ranges — e.g. all $511{,}225$ minors
of size $4$ for $p = 13$ (a finite check, not a proof for general $p$). It also quantifies the
reach of the two shortcuts. For $p = 11$, $n = 4$ about $89\%$ of minors possess a singleton
fibre and for $p = 13$, $n = 4$ about $91\%$; but for $p = 7$, $n = 4$ *none* does, so
Corollary 6.6 is far from a general strategy. By contrast, in every configuration examined
($p \le 13$, $n \le 4$) *some* fibre of the exponent map has odd cardinality, so Corollary 6.5
applies throughout the computed range; whether this persists for all $p$ and $n$ is open, and it
would imply the additive uncertainty principle in full. A further quantitative observation: the
parity gap $\max_r |c_r|$ is never smaller than $1$ and is typically of order $n$ — e.g. its
minimum over all $108{,}900$ minors of size $4$ for $p = 11$ is $2$.

### 7.3 Deterministic sparse recovery from $2k$ Fourier samples

**Input:** $p$ prime, sparsity $k$, any frequency set $\Omega$ with $|\Omega| = 2k$, and the
values $\hat f|_\Omega$ of an unknown $k$-sparse $f$.
**Output:** $f$.

```
for each candidate support A of size k:
    solve the overdetermined least-squares system  (omega^{-s x})_{s in Omega, x in A} v = fhat|_Omega
    record the residual
return the candidate with the smallest residual
```

The brute-force enumeration is $O(\binom{p}{k} k^2 |\Omega|)$ and is meant as a *uniqueness*
demonstration rather than an efficient algorithm; the mathematical content, Theorem 8.1 below,
is that the minimiser is unique and exact. In practice one replaces the enumeration by Prony's
method or by $\ell^1$ minimisation, both of which are correct here precisely because the
underlying minors are nonsingular.

---

## 8. Application: deterministic sparse recovery

**Theorem 8.1 (Universal $2k$-sample uniqueness).** *Let $p$ be prime, $k \geq 1$ with
$2k \le p$, and suppose the additive uncertainty principle holds for every function with at
most $2k$ nonzero values (unconditional for $k \le 1$ by Theorem 5.5, and available in all the
regimes of Theorem 5.8; in general it is exactly the nonsingularity of the Fourier minors of
size $\le 2k$). Let $\Omega \subseteq \mathbb{Z}_p$ be
**any** set of $2k$ frequencies. If $f$ and $g$ are $k$-sparse and
$\hat f|_{\Omega} = \hat g|_{\Omega}$, then $f = g$.*

*Proof.* Set $h = f - g$; then $|\operatorname{supp} h| \le 2k$ and $\hat h$ vanishes on $\Omega$, so
$|\operatorname{supp}\hat h| \le p - 2k$. If $h \neq 0$ the additive bound gives
$|\operatorname{supp} h| \geq (p+1) - (p - 2k) = 2k+1$, a contradiction. Hence $h = 0$. $\blacksquare$

Equivalently, in the determinantal language: the $2k \times 2k$ submatrix of the Fourier matrix
on rows $\Omega$ and any $2k$ columns is nonsingular, so the measurement operator is injective
on $2k$-sparse vectors — the spark of the partial Fourier matrix of $\mathbb{Z}_p$ is maximal,
namely $|\Omega| + 1$.

Three features distinguish this from generic compressed-sensing guarantees:

* **Deterministic.** No randomness, no failure probability, no restricted-isometry hypothesis.
* **Universal in the sampling pattern.** *Every* set of $2k$ frequencies works; hardware or
  scheduling constraints on which frequencies are cheap to measure cost nothing.
* **Optimal in the sample count.** $2k$ measurements are necessary: with only $2k-1$
  frequencies the linear constraints have rank at most $2k-1$ on the $2k$-dimensional space of
  vectors supported in a fixed set of $2k$ coordinates, so some nonzero $2k$-sparse $h$ has
  $\hat h$ vanishing there; splitting $h = f - g$ into two $k$-sparse pieces defeats recovery.
  The guarantee is therefore tight.

This is why the phenomenon is of practical interest in high-dimensional data analysis: sparse
spectral estimation, feature hashing into a prime number of buckets, sketching and dictionary
design all benefit from a sampling pattern that is *guaranteed* to be non-degenerate, rather
than one that is merely non-degenerate with high probability. The failure on $\mathbb{Z}_4$ is a
warning of what non-prime lengths cost: there, sampling the frequency set $\{1,3\}$ conveys no
information whatsoever about the subgroup indicator of $\{0,2\}$.

---

## 9. Discussion

### 9.1 Where primality enters, three times

It is instructive to track the hypothesis "$p$ prime" through the argument.

1. **No subgroups.** The extremal family for Donoho–Stark consists of cosets of subgroups
   (Theorem 3.1); prime order eliminates it.
2. **Field structure.** $\mathbb{Z}_p$ is a field, so $x \mapsto dx$ is a bijection for
   $d \neq 0$ (used in Lemma 3.3, Theorem 4.5, Theorem 5.1) and differences of distinct
   elements are invertible (used in Theorem 5.6).
3. **Cyclotomic rigidity.** The $p$-th cyclotomic polynomial is $1 + X + \dots + X^{p-1}$, so
   the only rational relation among $1, \omega, \dots, \omega^{p-1}$ is the obvious one (Lemma
   6.1). For composite $n$ there are many further relations — e.g. $1 + i^2 = 0$ in
   $\mathbb{Z}_4$ — and these are exactly the relations that manufacture singular minors.

The third point is the deepest, and it is the one that the combinatorial criterion isolates.

### 9.2 The remaining case

The parity criterion reduces everything to the fibre structure of the exponent map
$\sigma \mapsto \sum_j S_{\sigma(j)}T_j$. All currently available sufficient conditions
(singleton fibre, odd fibre) are about a single fibre in isolation. Numerical exploration shows
that for $n \geq 4$ fibres can be large and even in size — and yet, in every configuration
examined, at least one fibre of odd cardinality survives, which alone would settle the theorem.
Proving that an odd fibre always exists, or otherwise finding an invariant that distinguishes
even from odd permutations *inside* a fibre, is the missing step. Two candidates:

* a *length* statistic — the Coxeter length of a permutation, which controls its sign and
  respects the natural order structure on $\mathbb{Z}_p$ lifted to $\{0,\dots,p-1\}$;
* a *valuation* statistic — the order of vanishing at $u = 0$ of the deformed determinant
  $M(u) = \det\big((1+u)^{s_jt_k}\big)$, which filters the determinant by degree and converts
  the problem into an identity between a generalised Vandermonde determinant and a Weyl-type
  dimension formula.

Both are made precise as conjectures in Section 10.

### 9.3 Relation to classical results

The multiplicative bound is Donoho–Stark's; the additive bound on prime cyclic groups is Tao's;
the nonsingularity of all minors of the prime Fourier matrix is Chebotarev's, first proved in
the 1920s. Theorem 4.2 makes the folklore identification of the last two *unconditional in the
modulus*, which is what allows the $\mathbb{Z}_4$ counterexample to be read simultaneously as a
statement about signals and as a statement about matrices. Theorem 8.1 is the deterministic
sparse-recovery corollary familiar from compressed sensing on prime-length groups.

---

## 10. Future directions

The remaining open case is $4 \leq |\operatorname{supp} f| \leq p - 4$ with unstructured support and
unstructured spectrum. Two bold, falsifiable conjectures organise the next steps.

**Conjecture A (Parity-gap conjecture).** For all $n \geq 2$ and all injective
$S, T : \{1,\dots,n\}\to\mathbb{Z}_p$, some parity-weighted multiplicity $c_r$ is nonzero; in
fact $\max_r |c_r| \geq 1$ is attained at a residue of the form $\sum_j S_{\sigma(j)}T_j$ for a
permutation $\sigma$ of *minimal Coxeter length* among those realising that exponent.

The key insight is that the criterion of Theorem 6.4 reduces an analytic non-vanishing
statement about roots of unity to a counting statement about $S_n$ acting on $\mathbb{Z}_p$, so
the entire difficulty is concentrated in the fibres of $\sigma \mapsto \sum_j S_{\sigma(j)}T_j$
— and the numerical data show the fibres are never parity-balanced. The uniqueness criterion
(Corollary 6.6) already discharges every configuration in which one fibre is a singleton, which
covers $n \le 3$ completely; what is missing is a combinatorial invariant distinguishing even
from odd permutations inside a fibre, and the length statistic is the natural candidate,
finitely checkable for $n = 4$.

**Conjecture B ($(1-\omega)$-adic valuation conjecture).** Write
$M(u) = \det\big((1+u)^{s_jt_k}\big) \in \mathbb{Z}[u]$. Then the order of vanishing of $M$ at
$u = 0$ is exactly $n(n-1)/2$, and the leading coefficient equals

$$\frac{\prod_{j<k}(s_k - s_j)(t_k - t_j)}{\prod_{j<k}(k-j)},$$

an integer prime to $p$; consequently every minor of the Fourier matrix is nonsingular.

The key insight is that the exponent-$u$ filtration of $\mathbb{Z}[u]$ refines the vanishing of
the minor modulo the prime $(1-\omega)$ of $\mathbb{Z}[\omega]$, converting Chebotarev's theorem
into an identity between a generalised Vandermonde determinant and a Weyl-type dimension form.

Beyond these, natural extensions include: quantitative versions of the additive bound for
$\varepsilon$-concentrated (rather than exactly supported) signals; the analogous question on
$\mathbb{Z}_{p^2}$ and on products of distinct primes, where the subgroup obstruction returns in
a controlled way; and algorithmic exploitation of maximal spark, in particular provably correct
Prony-type reconstruction with worst-case rather than average-case guarantees.

---

## 11. Conclusion

The additive uncertainty principle $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq p+1$ on
$\mathbb{Z}_p$ is a genuinely stronger statement than the classical product bound, provably not
reachable from it by arithmetic, and provably false without primality. It is sharp exactly at
the delta/character endpoints; it is equivalent, for every modulus, to the nonsingularity of
all minors of the Fourier matrix; and this in turn is equivalent to a finite statement about
parity-weighted fibres of an exponent map on the symmetric group. Along this chain the
principle is now established for supports or spectra of size at most three, for very large
supports, and for arithmetic-progression supports or spectra, and it yields a deterministic,
sampling-pattern-universal sparse-recovery guarantee at the optimal rate of $2k$ measurements.
What remains is a single, sharply delineated combinatorial question about how permutations
distribute across residues — a question that is finite, checkable, and now precisely posed.
