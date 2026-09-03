# Full Pinning at the First Composite-Order Rung: The Type Channel of $\mathbb{Q}(\zeta_{56})^{+}$ and Entropic Detection of Non-Cyclicity

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

We study the *type channel* of a real cyclotomic field: the map sending a prime
$p$, unramified in $\mathbb{Q}(\zeta_f)$, to its residue degree in the maximal
real subfield $\mathbb{Q}(\zeta_f)^{+}$. At conductor $f = 56$ this channel sits
at the first rung of the abelian ladder whose Galois group has composite order
and is **not cyclic**.

We establish the following. (i) $[\mathbb{Q}(\zeta_{56}):\mathbb{Q}] = 24$, the
involution attached to $-1$ has order $2$, and its fixed field
$\mathbb{Q}(\zeta_{56})^{+}$ has degree exactly $12$ over $\mathbb{Q}$.
(ii) There is an explicit isomorphism
$\operatorname{Gal}\big(\mathbb{Q}(\zeta_{56})^{+}/\mathbb{Q}\big)\cong C_6\times C_2$,
constructed from the basis $\{3,\,13,\,-1\}$ of
$(\mathbb{Z}/56)^\times\cong C_6\times C_2\times C_2$; in particular the group is
abelian of order $12$ and non-cyclic.
(iii) The residue degree of a prime equals the order of its Frobenius class, and
the resulting type densities are $\{1/12,\,1/4,\,1/6,\,1/2\}$, coinciding exactly
with the order statistics of $C_6\times C_2$ (a Chebotarev match).
(iv) *Full pinning* holds as a theorem about deterministic channels: for any
finite sample set $S$ and any map $\varphi$ on it, the mutual information between
a uniform input and its image equals the output entropy, so the pinning gap
vanishes identically; the exact value at conductor $56$ is
$$H(T) \;=\; \tfrac43 + \tfrac{1}{4}\log_2 3 \;=\; 1.72957\ldots \text{ bits},$$
rigorously bracketed by $1.7295 < H(T) < 1.7296$, with strictly positive residual
uncertainty $H(X\mid T) = \tfrac53 + \tfrac34\log_2 3$.
(v) Orbit purity: translation orbits in a finite abelian group all have length
$\operatorname{ord}(g)$, giving the decomposition law $f\cdot g = 12$ with the
four shapes $(1,12),(2,6),(3,4),(6,2)$.
(vi) A translation-invariant pair law
$\#\{(u,v): T(uv)=t\} = |S|\cdot\#\{w : T(w)=t\}$, so a semiprime carries exactly
the same type distribution — and the same $1.72957\ldots$ bits — as a prime.
(vii) **Entropic separation:** the order-profile entropies of the two abelian
groups of order $12$ are $H(C_{12}) = \tfrac56 + \log_2 3 > 2 > \tfrac43 +
\tfrac14\log_2 3 = H(C_6\times C_2)$, so the single measured number $1.7296$
certifies non-cyclicity of the Galois group.

**Keywords:** real cyclotomic field, residue degree, Frobenius class, Chebotarev
density, Shannon entropy, mutual information, deterministic channel, abelian
Galois group, order profile.

---

## 1. Introduction

### 1.1 The abelian ladder and the problem of the rung

Let $f\ge 3$ and let $\zeta_f = e^{2\pi i/f}$. The cyclotomic field
$\mathbb{Q}(\zeta_f)$ is abelian over $\mathbb{Q}$ with Galois group canonically
$(\mathbb{Z}/f)^\times$, via the cyclotomic character
$\sigma\mapsto a_\sigma$ determined by $\sigma(\zeta_f) = \zeta_f^{a_\sigma}$.
The maximal real subfield

$$\mathbb{Q}(\zeta_f)^{+} \;=\; \mathbb{Q}\!\left(\zeta_f + \zeta_f^{-1}\right)$$

is the fixed field of complex conjugation, the automorphism attached to $-1$; its
Galois group is the quotient $G^{+} = (\mathbb{Z}/f)^\times/\{\pm 1\}$, of order
$\varphi(f)/2$ whenever $f > 2$.

Consider now the *ladder* of these real fields, indexed by increasing degree
$n = \varphi(f)/2$. For small $n$ the group $G^{+}$ is forced to be cyclic simply
by having prime order, or by the accident that the relevant unit groups happen to
be cyclic. Degree $12$ is the first place where an abelian group of that order
need not be cyclic: the abelian groups of order $12$ are $C_{12}$ and
$C_6\times C_2$, and both are realised as $G^{+}$ for suitable conductors.

We therefore ask: **is there an intrinsic, measurable quantity — computable from
prime data alone — that determines which of the two occurs?**

The answer developed here is yes, and the quantity is a single real number: the
Shannon entropy of the residue-degree (type) distribution. At conductor $56$ it
equals $\tfrac43 + \tfrac14\log_2 3 = 1.7296\ldots$ bits, and the *entropy
separation theorem* (Theorem 7.3) shows this value is incompatible with the
cyclic group.

### 1.2 Why conductor $56$

Exactly ten conductors satisfy $\varphi(f) = 24$, namely
$$f \in \{35,\,39,\,45,\,52,\,56,\,70,\,72,\,78,\,84,\,90\},$$
of which $70, 78, 90$ define the same fields as $35, 39, 45$ respectively
(since $\mathbb{Q}(\zeta_{2m}) = \mathbb{Q}(\zeta_m)$ for odd $m$). Among the
seven distinct fields, four have cyclic $G^{+}$ ($f = 35, 39, 45, 52$) and three
have $G^{+}\cong C_6\times C_2$ ($f = 56, 72, 84$). Conductor $56$ is the
smallest with non-cyclic $G^{+}$, and is the one treated here.

The structural reason is transparent: $56 = 2^3\cdot 7$, so
$(\mathbb{Z}/56)^\times \cong (\mathbb{Z}/8)^\times\times(\mathbb{Z}/7)^\times
\cong (C_2\times C_2)\times C_6$. Quotienting the $\{\pm 1\}$ factor leaves
$C_2\times C_6$, whose exponent $6$ is strictly less than its order $12$.

### 1.3 Summary of contributions

1. An explicit basis $\{3, 13, -1\}$ realising
   $(\mathbb{Z}/56)^\times\cong C_6\times C_2\times C_2$, with the third factor
   equal to $\{\pm 1\}$, hence an explicit isomorphism $G^{+}\cong C_6\times C_2$.
2. The field-theoretic verification that $\mathbb{Q}(\zeta_{56})^{+}$, defined as
   the fixed field of the conjugation involution, has degree $12$, and that its
   Galois group is isomorphic to $C_6\times C_2$ and non-cyclic.
3. The identification of the elementary "type" function
   $T(a) = \min\{k\ge 1 : a^k \equiv \pm 1\}$ with the order of the Frobenius
   class, and the exact type census $2, 6, 4, 12$ out of $24$.
4. A general finite information calculus with a clean determinism theorem
   ("full pinning") and an exact closed-form entropy at conductor $56$, with
   rigorous rational bracketing.
5. A general orbit-purity theorem in finite abelian groups yielding the $efg$
   law $1\cdot f\cdot g = 12$.
6. A general translation-invariant pair law explaining the equality of the prime
   and semiprime type profiles.
7. The order-profile entropy separation of $C_{12}$ from $C_6\times C_2$ across
   the threshold $2$, giving an entropic certificate of non-cyclicity.

---

## 2. Notation and basic objects

Throughout, $\log_2$ is the binary logarithm and all entropies are in bits.

**Definition 2.1 (Reduced residues mod 56).** Let
$$U_{56} \;=\; \{a \in \mathbb{Z}/56 \;:\; \gcd(a, 56) = 1\}$$
be the set of reduced residue classes.

**Lemma 2.2 (Three equivalent descriptions).** For $a\in\mathbb{Z}/56$ the
following are equivalent: (i) $a\in U_{56}$; (ii) $a$ is a unit, i.e. $ab = 1$
for some $b$; (iii) $a^6 = 1$.

*Proof sketch.* (ii) $\Rightarrow$ (i) and (i) $\Rightarrow$ (ii) are the standard
characterisation of units in $\mathbb{Z}/m$. For (i) $\Leftrightarrow$ (iii):
by the Chinese Remainder Theorem $(\mathbb{Z}/56)^\times\cong
(\mathbb{Z}/8)^\times\times(\mathbb{Z}/7)^\times$ has exponent
$\operatorname{lcm}(2,6) = 6$, so every unit satisfies $a^6 = 1$; conversely if
$a^6 = 1$ then $a\cdot a^5 = 1$, so $a$ is a unit. Both directions are finite
checks over the $56$ residues. $\square$

**Corollary 2.3.** $|U_{56}| = \varphi(56) = 24$, and $U_{56}$ has exponent $6$.

**Lemma 2.4 (Primes land in $U_{56}$).** If $p$ is prime and $p\notin\{2,7\}$
then $p \bmod 56 \in U_{56}$. The excluded primes are exactly the ramified ones.

*Proof sketch.* $p$ is coprime to $56 = 2^3\cdot 7$ unless $p\mid 56$, i.e.
$p\in\{2,7\}$. $\square$

**Definition 2.5 (Type / residue degree).** For $a \in U_{56}$ set
$$T(a) \;=\; \min\{k\ge 1 \;:\; a^k = 1 \text{ or } a^k = -1\}.$$
Equivalently $T(a)$ is the order of the class of $a$ in
$G^{+} = U_{56}/\{\pm 1\}$.

Since the exponent of $U_{56}$ is $6$, the minimum is always attained with
$T(a)\mid 6$; concretely $T$ takes values in $\{1,2,3,6\}$ and is characterised
by the cascade
$$T(a) = \begin{cases}
1, & a = \pm 1,\\
2, & a^2 = \pm 1 \text{ and } a\ne\pm 1,\\
3, & a^3 = \pm 1 \text{ and neither of the above},\\
6, & \text{otherwise.}
\end{cases}$$

**Lemma 2.6 (Basic properties of $T$).**
(a) $T(a)$ satisfies the minimality property defining it: $a^{T(a)} = \pm 1$ and
no $1\le k < T(a)$ has $a^k = \pm 1$.
(b) $T(-a) = T(a)$ for all $a\in U_{56}$, so $T$ descends to $G^{+}$.
(c) $T(a)\in\{1,2,3,6\}$ for all $a\in U_{56}$.
(d) **(Pinning hypothesis)** If $p\equiv q \pmod{56}$ then $T(p) = T(q)$: the type
of an integer depends only on its residue class mod $56$.

*Proof sketch.* (a)–(c) are finite verifications over the $24$ residues. (b) holds
because $(-a)^k = \pm a^k$. (d) is immediate: $T$ is defined on $\mathbb{Z}/56$
and $p\equiv q$ means they have the same image there. $\square$

Property (d) is deceptively trivial in this formulation, and it is the whole
arithmetic input to the information-theoretic story: the type of a prime is a
*deterministic function of its remainder*. That is a theorem of class field
theory in general (the splitting of $p$ in an abelian extension of conductor $f$
depends only on $p \bmod f$), and here it is available by construction.

---

## 3. Structure of the unit group and of $G^{+}$

**Definition 3.1 (Basis parametrisation).** Define
$$\beta : C_6\times C_2\times C_2 \longrightarrow \mathbb{Z}/56, \qquad
\beta(i,j,k) \;=\; 3^{\,i}\cdot 13^{\,j}\cdot(-1)^{k},$$
where $i$ is read mod $6$ and $j,k$ mod $2$ (all exponents taken as
representatives in $[0,6)$, $[0,2)$).

**Theorem 3.2 (Basis theorem).** $\beta$ is injective, its image is exactly
$U_{56}$, and $\beta(t + s) = \beta(t)\beta(s)$. Hence
$$(\mathbb{Z}/56)^\times \;\cong\; C_6\times C_2\times C_2,$$
with the three factors generated by $3$ (order $6$), $13$ (order $2$) and $-1$
(order $2$).

*Proof sketch.* The order of $3$ mod $56$ is $6$ (indeed $3^6 = 729 = 13\cdot 56 +
1$, and no proper divisor of $6$ works); $13^2 = 169 = 3\cdot 56 + 1$; and
$(-1)^2 = 1$. Homomorphy is commutativity of $\mathbb{Z}/56$. Injectivity is a
finite check on the $24$ triples, and since $|U_{56}| = 24$ injectivity forces
surjectivity onto $U_{56}$. Structurally, this is the Chinese Remainder
decomposition $(\mathbb{Z}/8)^\times\times(\mathbb{Z}/7)^\times$ written in a
basis adapted to $\{\pm 1\}$: $3$ generates the $C_6$ arising from
$(\mathbb{Z}/7)^\times$ together with a sign twist, while $13$ and $-1$ span the
$(\mathbb{Z}/8)^\times$ part. $\square$

**Definition 3.3 (The $\pm$-free part).** Write
$$c : C_6\times C_2 \to U_{56}, \qquad c(i,j) = 3^{\,i}\cdot 13^{\,j}.$$

**Proposition 3.4 (Splitting of $G^{+}$).**
(a) $c$ is a homomorphism from $(C_6\times C_2, +)$ to $(U_{56},\cdot)$ with
$c(0) = 1$.
(b) $c$ is injective *modulo signs*: if $c(g) = \pm c(h)$ then $g = h$.
(c) Every $a\in U_{56}$ equals $c(g)$ or $-c(g)$ for a (unique) $g$.
Consequently the $12$ classes $\{\pm c(g)\}$ partition $U_{56}$, and
$$G^{+} \;=\; U_{56}/\{\pm 1\} \;\cong\; C_6\times C_2, \qquad |G^{+}| = 12.$$

*Proof sketch.* Immediate from Theorem 3.2 by discarding the third coordinate;
(b) says precisely that the third coordinate is the only source of sign
ambiguity, and (c) that $\beta$ is onto. $\square$

**Theorem 3.5 (Degree twelve).** Let $L = \mathbb{Q}(\zeta_{56})$ and let
$\iota\in\operatorname{Gal}(L/\mathbb{Q})$ be the automorphism corresponding to
$-1$ under the cyclotomic character. Then:
(a) $[L:\mathbb{Q}] = \varphi(56) = 24$;
(b) $\iota$ has order $2$;
(c) the fixed field $\mathbb{Q}(\zeta_{56})^{+} = L^{\langle\iota\rangle}$
satisfies $[L : \mathbb{Q}(\zeta_{56})^{+}] = 2$ and
$$\big[\mathbb{Q}(\zeta_{56})^{+} : \mathbb{Q}\big] \;=\; 12.$$

*Proof sketch.* (a) The $56$-th cyclotomic polynomial is irreducible over
$\mathbb{Q}$ of degree $\varphi(56) = 24$. (b) The cyclotomic character is an
isomorphism onto $(\mathbb{Z}/56)^\times$, and $-1$ has order $2$ there (it is
not $1$ since $56 > 2$). (c) $L/\mathbb{Q}$ is Galois, so by Artin's theorem
$[L : L^{\langle\iota\rangle}] = |\langle\iota\rangle| = 2$; multiplicativity of
degrees in the tower $\mathbb{Q}\subseteq \mathbb{Q}(\zeta_{56})^{+}\subseteq L$
gives $12\cdot 2 = 24$. $\square$

**Theorem 3.6 (The Galois group of the real field).** There is an isomorphism
$$\operatorname{Gal}\big(\mathbb{Q}(\zeta_{56})^{+}/\mathbb{Q}\big)
\;\cong\; (\mathbb{Z}/56)^\times/\{\pm 1\} \;\cong\; C_6\times C_2 .$$
In particular the group has order $12$ and is **not cyclic**.

*Proof sketch.* $\langle\iota\rangle$ is normal (the ambient group is abelian), so
the Galois correspondence gives
$\operatorname{Gal}(\mathbb{Q}(\zeta_{56})^{+}/\mathbb{Q})\cong
\operatorname{Gal}(L/\mathbb{Q})/\langle\iota\rangle$; transporting along the
cyclotomic character turns the right-hand side into
$(\mathbb{Z}/56)^\times/\{\pm 1\}$, which Proposition 3.4 identifies with
$C_6\times C_2$. Non-cyclicity: every $g\in C_6\times C_2$ satisfies $6g = 0$, so
the exponent divides $6 < 12$; a generator of a cyclic group of order $12$ would
have order $12$, a contradiction. $\square$

This is the first rung of the ladder at which $G^{+}$ is both of composite order
and non-cyclic: precisely the phenomenon the rest of the paper measures.

---

## 4. Types are Frobenius orders

**Theorem 4.1 (Type $=$ order).** For every $g\in C_6\times C_2$,
$$\operatorname{ord}(g) \;=\; T\big(c(g)\big).$$
That is, under the identification $G^{+}\cong C_6\times C_2$, the type of a
residue is exactly the order of the corresponding group element, and the residue
degree of an unramified prime $p$ in $\mathbb{Q}(\zeta_{56})^{+}$ is the order of
its Frobenius class.

*Proof sketch.* Fix $g$ and set $m = T(c(g))$. By Lemma 2.6(a), $c(g)^m = \pm 1$,
i.e. $c(mg) = \pm c(0)$; by Proposition 3.4(b) this forces $mg = 0$. Conversely if
$0 < k < m$ had $kg = 0$ then $c(g)^k = c(kg) = 1$, contradicting minimality of
$m$. Hence $m$ is the least positive integer annihilating $g$, i.e.
$\operatorname{ord}(g) = m$. $\square$

**Definition 4.2 (Type census).** For $d\ge 1$ put
$N(d) = \#\{a\in U_{56} : T(a) = d\}$ and
$M(d) = \#\{g\in C_6\times C_2 : \operatorname{ord}(g) = d\}$.

**Theorem 4.3 (Chebotarev match).** For every $d$,
$$N(d) \;=\; 2\,M(d).$$
Explicitly,
$$\big(N(1),N(2),N(3),N(6)\big) = (2,\,6,\,4,\,12), \qquad
\big(M(1),M(2),M(3),M(6)\big) = (1,\,3,\,2,\,6),$$
all other values being $0$, and $N(1)+N(2)+N(3)+N(6) = 24$. The type densities are
$$\Big(\tfrac{1}{12},\ \tfrac14,\ \tfrac16,\ \tfrac12\Big),$$
which are exactly the order-statistics densities of $C_6\times C_2$.

*Proof sketch.* Each $g\in C_6\times C_2$ lifts to exactly two residues
$\pm c(g)$, which have the same type by Lemma 2.6(b) and type
$\operatorname{ord}(g)$ by Theorem 4.1; the fibres of $T$ therefore double the
fibres of $\operatorname{ord}$. For $d$ outside $\{1,2,3,6\}$ both sides vanish
because every type and every order divides the exponent $6$. The explicit counts
are a finite enumeration: the identity, the three involutions
$(3,0), (0,1), (3,1)$, the two elements of order $3$, namely $(2,0),(4,0)$, and
the remaining six of order $6$. $\square$

**Remark 4.4 (Chebotarev in the analytic sense).** Because $T(p)$ depends only on
$p \bmod 56$ (Lemma 2.6(d)) and the Frobenius class of $p$ in $G^{+}$ is the class
of $p \bmod 56$, Chebotarev's density theorem — equivalently, here, Dirichlet's
theorem on primes in arithmetic progressions — implies that the natural density
of primes of type $d$ equals $N(d)/24$. Empirically, over the $17\,982$ primes
below $200\,000$ other than $2$ and $7$, the observed type frequencies are
$0.08247,\ 0.24992,\ 0.16466,\ 0.50295$, against the predicted
$0.08333,\ 0.25,\ 0.16667,\ 0.5$.

---

## 5. A finite information calculus and the full-pinning theorem

We now formulate the information-theoretic layer in complete generality, so that
none of the statements depend on the number $56$.

Let $S$ be a nonempty finite set, $\varphi : S\to \mathcal{T}$ any function into a
finite set of symbols, and let $X$ be uniformly distributed on $S$.

**Definition 5.1.** For $t\in\mathcal{T}$ let $F_t = \{a\in S : \varphi(a) = t\}$
be the *fibre*, and $\Pr[T = t] = |F_t| / |S|$. Write, with the convention
$0\log_2 0 = 0$,
$$H(X) = \log_2|S|, \qquad
H(T) = \sum_{t\in\varphi(S)} -\Pr[T=t]\log_2\Pr[T=t],$$
$$H(X,T) = \sum_{(a,t)\in S\times\varphi(S)} -q(a,t)\log_2 q(a,t), \qquad
q(a,t) = \begin{cases} |S|^{-1}, & \varphi(a) = t,\\ 0,&\text{otherwise,}\end{cases}$$
$$I(X;T) = H(X) + H(T) - H(X,T), \qquad H(X\mid T) = H(X,T) - H(T).$$

**Theorem 5.2 (Determinism collapses the joint entropy).**
$H(X,T) = H(X) = \log_2|S|$.

*Proof sketch.* For each fixed $a\in S$, the inner sum over $t$ has exactly one
nonzero term, at $t = \varphi(a)$, contributing $|S|^{-1}\log_2|S|$; the other
terms vanish by the convention $0\log_2 0 = 0$. Summing over the $|S|$ elements
gives $\log_2|S|$. $\square$

**Theorem 5.3 (Full pinning).** For every nonempty finite $S$ and every function
$\varphi$,
$$I\big(X;\varphi(X)\big) \;=\; H\big(\varphi(X)\big),$$
equivalently the *pinning gap* $H(T) - I(X;T)$ is identically $0$.

*Proof sketch.* Substitute Theorem 5.2 into
$I = H(X) + H(T) - H(X,T)$. $\square$

**Corollary 5.4 (Exact loss).** $H(X\mid T) = H(X) - H(T) = \log_2|S| - H(T)$.

Theorem 5.3 deserves a word of interpretation. In empirical channel analysis one
measures $I(X;T)$ and compares it to $H(T)$; a positive gap indicates that the
output is not a function of the input (noise, or hidden variables). The theorem
says the converse is exact: *a channel is fully pinned if and only if it is
deterministic*. Consequently the substantive content of the statement
"$I(p\bmod 56; T) = H(T)$ with gap $0$" is not information-theoretic at all — it
is the arithmetic assertion, Lemma 2.6(d), that the splitting type of a prime is
a function of its residue class. The entropy calculus then converts that
qualitative fact into a *quantitative* one: the exact number of bits transmitted.

---

## 6. The exact entropy at conductor $56$

**Theorem 6.1 (Closed form).** With $S = U_{56}$ and $\varphi = T$,
$$H(T) \;=\; \frac{1}{12}\log_2 12 + \frac14 \log_2 4 + \frac16\log_2 6 +
\frac12\log_2 2 \;=\; \frac43 + \frac{\log_2 3}{4}.$$

*Proof sketch.* By Theorem 4.3 the four fibres have sizes $2, 6, 4, 12$ out of
$24$, i.e. probabilities $\tfrac1{12}, \tfrac14, \tfrac16, \tfrac12$. Each Shannon
term with probability $1/x$ contributes $\tfrac1x\log_2 x$. Expanding
$\log_2 12 = 2 + \log_2 3$, $\log_2 6 = 1 + \log_2 3$, $\log_2 4 = 2$,
$\log_2 2 = 1$ and collecting,
$$H(T) = \tfrac16 + \tfrac{\log_2 3}{12} + \tfrac12 + \tfrac16 +
\tfrac{\log_2 3}{6} + \tfrac12 = \tfrac43 + \tfrac{\log_2 3}{4}. \qquad\square$$

**Lemma 6.2 (Rigorous bracketing of $\log_2 3$).**
$$\frac{84}{53} \;<\; \log_2 3 \;<\; \frac{233}{147}.$$

*Proof sketch.* The two integer inequalities $2^{84} < 3^{53}$ and
$3^{147} < 2^{233}$ are finite computations; take logarithms and divide by
$53\log 2$, respectively $147\log 2$. (These are the convergents of the continued
fraction of $\log_2 3 = 1.5849625\ldots$, so the bracket is tight to about
$10^{-4}$.) $\square$

**Theorem 6.3 (Numerical value).**
$$1.7295 \;<\; H(T) \;<\; 1.7296 .$$
Thus the type channel of $\mathbb{Q}(\zeta_{56})^{+}$ transmits $1.7296$ bits to
four decimal places (true value $1.7295739\ldots$).

*Proof sketch.* Combine Theorem 6.1 with Lemma 6.2: $\tfrac43 + \tfrac{84}{212} =
1.72955\ldots$ and $\tfrac43 + \tfrac{233}{588} = 1.72959\ldots$. $\square$

**Theorem 6.4 (Full pinning at conductor 56).**
$$I\big(p \bmod 56\,;\,T\big) \;=\; H(T) \;=\; \frac43 + \frac{\log_2 3}{4},
\qquad H(T) - I \;=\; 0 .$$

*Proof sketch.* Theorem 5.3 applied to $S = U_{56}$, $\varphi = T$, together with
Theorem 6.1. $\square$

**Theorem 6.5 (Fully pinned but strictly lossy).**
$$H(X) = \log_2 24 = 3 + \log_2 3 \approx 4.58496,\qquad
H(X\mid T) = \frac53 + \frac34\log_2 3 \approx 2.85539 \;>\; 0.$$

*Proof sketch.* Corollary 5.4 with $|S| = 24$ and Theorem 6.1; positivity from
Lemma 6.2. $\square$

Theorems 6.4 and 6.5 together give the precise statement of the phenomenon: the
type map is a *deterministic coarsening*. It leaks nothing (gap $0$) yet retains
only $1.73$ of the $4.58$ bits present in the residue. Roughly $38\%$ of the
arithmetic information in $p \bmod 56$ is visible in the splitting type.

---

## 7. Entropic separation: reading the group off the number

The value $1.7296$ is a measurement. What does it determine?

**Definition 7.1 (Order-profile entropy).** For a finite group $A$ let
$$H(A) \;=\; -\sum_{d} \frac{M_A(d)}{|A|}\log_2\frac{M_A(d)}{|A|}, \qquad
M_A(d) = \#\{x\in A : \operatorname{ord}(x) = d\},$$
the Shannon entropy of the order of a uniformly random element.

**Theorem 7.2 (The two order-$12$ profiles).**
$$H(C_{12}) = \frac56 + \log_2 3 = 2.41830\ldots, \qquad
H(C_6\times C_2) = \frac43 + \frac{\log_2 3}{4} = 1.72957\ldots$$

*Proof sketch.* In $C_{12}$ the element orders $1,2,3,4,6,12$ occur with
multiplicities $\varphi(d)$, that is $1,1,2,2,2,4$, giving probabilities
$\tfrac1{12},\tfrac1{12},\tfrac16,\tfrac16,\tfrac16,\tfrac13$; summing
$\tfrac1x\log_2 x$ terms gives
$2\cdot\tfrac1{12}\log_2 12 + 3\cdot\tfrac16\log_2 6 + \tfrac13\log_2 3 =
\tfrac56 + \log_2 3$. In $C_6\times C_2$ the orders $1,2,3,6$ occur with
multiplicities $1,3,2,6$, and the computation is Theorem 6.1. $\square$

**Theorem 7.3 (Entropy separation at order twelve).**
$$H(C_{12}) \;>\; 2 \;>\; H(C_6\times C_2),$$
so in particular $H(C_{12})\ne H(C_6\times C_2)$: the order-profile entropy is a
complete isomorphism invariant among abelian groups of order $12$.

*Proof sketch.* By Lemma 6.2, $\tfrac56 + \log_2 3 > \tfrac56 + \tfrac{84}{53} =
2.4182\ldots > 2$ and $\tfrac43 + \tfrac14\cdot\tfrac{233}{147} = 1.72959\ldots <
2$. $\square$

**Corollary 7.4 (Entropic certificate of non-cyclicity).** If an abelian group of
order $12$ has order-profile entropy $H < 2$, it is not isomorphic to $C_{12}$;
hence it is isomorphic to $C_6\times C_2$.

**Theorem 7.5 (Channel transfer).** The *arithmetic* channel (residues mod $56$
$\to$ types) and the *group-theoretic* channel (elements of $C_6\times C_2$ $\to$
their orders) have equal entropy:
$$H(T) \;=\; H(C_6\times C_2) \;=\; \frac43 + \frac{\log_2 3}{4}.$$

*Proof sketch.* Both equal the same closed form, by Theorems 6.1 and 7.2; the
underlying reason is Theorem 4.3, which shows the two distributions are literally
equal (the arithmetic fibres are doubles of the group fibres, so the normalised
distributions coincide). $\square$

Putting the chain together: measure the type frequencies of primes; compute their
entropy; obtain $1.7296 < 2$; conclude by Corollary 7.4 that
$\operatorname{Gal}(\mathbb{Q}(\zeta_{56})^{+}/\mathbb{Q})$ is the non-cyclic
group $C_6\times C_2$. The conclusion agrees with the structural derivation of
Theorem 3.6 — two independent routes to the same isomorphism class, one algebraic
and one measurement-based.

---

## 8. Orbit purity and the decomposition law

Frobenius acts on the $12$ cosets by translation by its own class. We record the
general principle and its specialisation.

Let $A$ be a finite abelian group (written additively) and $g\in A$.

**Definition 8.1.** The *translation orbit* of $x$ under $g$ is
$$\mathcal{O}_g(x) \;=\; \{\,k g + x \;:\; 0\le k < \operatorname{ord}(g)\,\}.$$

**Theorem 8.2 (Orbit purity).** $|\mathcal{O}_g(x)| = \operatorname{ord}(g)$ for
every $x\in A$; orbits are equal or disjoint; and
$$\big(\#\text{orbits}\big)\cdot \operatorname{ord}(g) \;=\; |A| .$$

*Proof sketch.* Injectivity of $k\mapsto kg + x$ on $0\le k <
\operatorname{ord}(g)$ is exactly the statement that $kg = k'g$ forces
$k\equiv k'$ mod $\operatorname{ord}(g)$. Since $\mathcal{O}_g(x)$ is a coset of
the cyclic subgroup $\langle g\rangle$, membership determines the orbit
($y\in\mathcal{O}_g(x)\Rightarrow \mathcal{O}_g(y) = \mathcal{O}_g(x)$), so the
orbits partition $A$ into blocks of equal size; counting elements fibrewise gives
the product formula. $\square$

**Corollary 8.3 (The $efg$ law at conductor 56).** For a prime $p$ unramified in
$\mathbb{Q}(\zeta_{56})^{+}$ (i.e. $p\ne 2,7$), with $f = T(p)$ the residue degree
and $g$ the number of primes above $p$,
$$e\cdot f\cdot g \;=\; 1\cdot f\cdot g \;=\; 12, \qquad
(f, g)\in\{(1,12),\,(2,6),\,(3,4),\,(6,2)\}.$$
Every orbit has the same length: there are no short or mixed orbits ("orbit
purity", $12/12$).

*Proof sketch.* Apply Theorem 8.2 with $A = C_6\times C_2$, $|A| = 12$, and
$\operatorname{ord}(g) = T(p)$ by Theorem 4.1; the four values of $T$ are
$1,2,3,6$ by Theorem 4.3 and $g = 12/f$. Unramifiedness gives $e = 1$. $\square$

Orbit purity is the structural reason the type census is meaningful. In a
non-abelian setting, or for a non-Galois extension, orbits of different lengths
can coexist above a single prime, and a single number $f$ would not determine the
factorisation shape. Here it does.

---

## 9. The semiprime pair channel

A recurring practical question: if one can only observe products of two primes,
does the channel degrade? The answer is a general counting law.

**Theorem 9.1 (Translation-invariant pair law).** Let $S$ be a finite subset of a
monoid such that for each $u\in S$ the map $v\mapsto uv$ is injective and maps
$S$ onto $S$. Then for any function $\varphi$ on $S$ and any value $t$,
$$\#\{(u,v)\in S\times S : \varphi(uv) = t\} \;=\; |S|\cdot\#\{w\in S : \varphi(w) = t\}.$$

*Proof sketch.* Fix $u$. Since $v\mapsto uv$ is a bijection of $S$ onto itself,
$\#\{v\in S : \varphi(uv) = t\} = \#\{w\in S : \varphi(w) = t\}$, independently of
$u$. Summing over the $|S|$ choices of $u$ gives the claim. $\square$

**Theorem 9.2 (Semiprime channel at conductor 56).** $U_{56}$ satisfies the
hypotheses of Theorem 9.1 (it is a group), so for every $d$
$$\#\{(u,v)\in U_{56}^2 : T(uv) = d\} \;=\; 24\cdot N(d),$$
explicitly $48, 144, 96, 288$ for $d = 1,2,3,6$ out of $576$ ordered pairs.
Dividing by $|U_{56}|^2 = 576$ recovers the densities
$\tfrac1{12},\tfrac14,\tfrac16,\tfrac12$: the type profile of a semiprime $pq$
coincides exactly with that of a prime. Consequently the semiprime channel
transmits exactly
$$H(T) \;=\; \frac43 + \frac{\log_2 3}{4} \;=\; 1.72957\ldots \text{ bits.}$$

*Proof sketch.* Theorem 9.1 with $S = U_{56}$, $\varphi = T$, then Theorem 4.3
and Theorem 6.1. $\square$

Two comments. First, the law is exact enumeration, not an asymptotic: no error
term appears. Second, it is *not* a triviality about entropies — the pair channel
has a much larger input space ($576$ pairs versus $24$ residues), and yet its
output distribution is identical. Multiplying two independent uniform draws from
a finite group returns a uniform draw; the type profile inherits the invariance.

---

## 10. Algorithms

We describe the computations underlying the results in algorithmic form.

### 10.1 Type computation

**Input:** modulus $m$, residue $a$ coprime to $m$.
**Output:** $T(a) = \min\{k\ge 1 : a^k\equiv\pm 1\}$.
Iterate $x\leftarrow a, a^2, a^3,\dots$ modulo $m$, stopping at the first $k$ with
$x\in\{1, m-1\}$. Each step costs one modular multiplication; the loop terminates
in at most $\lambda(m)$ steps, where $\lambda$ is the Carmichael function, so the
cost is $O(\lambda(m)\log^2 m)$ bit operations. For $m = 56$ this is at most six
multiplications.

### 10.2 Type census and densities

Enumerate $a = 0,\dots,m-1$, keep those with $\gcd(a,m) = 1$, and tabulate
$T(a)$. Cost $O(m\,\lambda(m))$ modular operations; for $m = 56$, trivial. Output:
the map $d\mapsto N(d)$ and the densities $N(d)/\varphi(m)$.

### 10.3 Entropy and mutual information of a finite channel

Given a list of pairs $(x_i, t_i)$, form the empirical marginals and joint
distribution and evaluate
$$I = \sum_{x,t} \hat p(x,t)\log_2\frac{\hat p(x,t)}{\hat p(x)\hat p(t)},
\qquad H(T) = -\sum_t \hat p(t)\log_2 \hat p(t) .$$
Cost $O(n)$ for $n$ samples using hash tables. For a deterministic channel the
computed $I$ and $H(T)$ agree to machine precision — this is Theorem 5.3 in
floating point, and the observed discrepancy of order $10^{-16}$ is exactly
rounding.

### 10.4 Frobenius orbit decomposition

Given a finite abelian group $A$ (as a product of cyclic factors) and $g\in A$,
repeatedly translate an unvisited element by $g$ until it returns, collecting the
orbit; repeat until all elements are visited. Cost $O(|A|)$ group operations, and
the output certifies both the common orbit length $f$ and the orbit count
$g = |A|/f$.

### 10.5 Group-order-profile entropy

For $A = \prod_i C_{n_i}$, compute the order of each element as the lcm of the
coordinate orders, tabulate, and apply the entropy formula. Cost $O(|A|)$. Used
to compare $C_{12}$ with $C_6\times C_2$.

### 10.6 Conductor selection

For a target degree $n$, enumerate $f$ with $\varphi(f) = 2n$, compute the
exponent of $(\mathbb{Z}/f)^\times/\{\pm 1\}$, and classify each conductor as
cyclic (exponent $= n$) or non-cyclic. Cost $O(f\lambda(f))$ per conductor. At
$n = 12$ this yields the ten conductors $35, 39, 45, 52, 56, 70, 72, 78, 84, 90$
and identifies $56$ as the smallest with non-cyclic $G^{+}$.

---

## 11. Applications and discussion

### 11.1 Structure detection from prime statistics

The pipeline "count prime types $\to$ compute entropy $\to$ compare to a table of
group entropies" is a *measurement procedure for Galois groups*. In the case at
hand its verdict is provably correct (Corollary 7.4), and it uses no field
arithmetic whatsoever: only remainders. Its practical appeal is that prime
statistics are cheap while explicit Galois-group computation is not.

### 11.2 Sharpness of the pinning statement

The vanishing of the pinning gap is a theorem about determinism, not a
coincidence of the conductor. It is worth stating the contrapositive as a
diagnostic: if an empirically estimated $I$ falls measurably below the
empirically estimated $H(T)$ in a setting where both are computed from the same
finite sample, the discrepancy is either sampling noise or a sign that the
purported channel is not a function. In the arithmetic setting the second
possibility is excluded by class field theory; hence the gap is a pure
finite-sample diagnostic, and its exact vanishing (to $10^{-16}$) on the full
residue system is a consistency check on the whole pipeline.

### 11.3 The loss term as a measure of coarseness

$H(X\mid T) = \tfrac53 + \tfrac34\log_2 3 \approx 2.855$ quantifies how much
coarser the type is than the residue. Its ratio to $H(X)$,
$$\frac{H(T)}{H(X)} = \frac{\tfrac43 + \tfrac14\log_2 3}{3 + \log_2 3}
\approx 0.377,$$
is the *efficiency* of the splitting-type observable. For a cyclic rung of the
same degree the efficiency would be higher ($H(C_{12})/\log_2 24 \approx 0.527$):
non-cyclicity costs observability, because a group with small exponent has fewer
distinct element orders to report.

### 11.4 Semiprimes and computational number theory

Theorem 9.2 says that observing $pq$ instead of $p$ loses nothing at the level of
type statistics. This is a structural fact about translation invariance and it
applies verbatim to any conductor. Its practical reading: type-based statistics
cannot distinguish primes from semiprimes, so such statistics are useless as a
primality signal — and, conversely, remain fully usable when the observed
integers are known only up to factorisation into two parts.

### 11.5 Scope and limitations

All results are exact statements about finite objects and about the specific
field $\mathbb{Q}(\zeta_{56})^{+}$. The passage from residue-class densities to
*densities among primes* uses Dirichlet/Chebotarev, which is classical; the
finite computations here are unconditional. The entropy invariant is proved to be
complete only at order $12$; see the conjecture below.

---

## 12. Future directions

**(1) Entropy injectivity for abelian rungs.** *Conjecture.* For abelian groups
$A, B$ of the same order $n\le 100$, the order-profile entropies agree if and only
if $A\cong B$; i.e. the type entropy is a complete isomorphism invariant in that
range.

The key insight is that the order profile of an abelian group is the multiset
determined by the numbers $\varphi(d)\cdot(\text{count of cyclic factors admitting
order } d)$, and the entropy is a $\mathbb{Q}$-linear combination of $\log_2 p$
over the primes $p\mid n$, whose coefficients are $\mathbb{Q}$-independent unless
the profiles coincide. Linear independence of $\{\log_2 p\}$ over $\mathbb{Q}$ —
available from unique factorisation for rational combinations — then converts an
analytic coincidence into a combinatorial one. The present cycle shows the
invariant is not vacuous at $n = 12$, the first order where two abelian groups
exist.

**(2) A universal pinning statement for deterministic arithmetic channels.**
*Conjecture.* For every modulus $m$, every $\{\pm 1\}$-stable channel
$T : (\mathbb{Z}/m)^\times \to \mathbb{N}$ factoring through
$(\mathbb{Z}/m)^\times/\{\pm 1\}$ satisfies $I = H(T)$ and
$$H(T) \;\le\; \log_2\big(\#\text{divisors of the exponent}\big),$$
with equality if and only if $T$ is the order function of an elementary abelian
group. The upper bound is the uniform-distribution bound over the possible types;
equality demands maximal spread of the order profile, which is exactly the
elementary abelian situation.

**(3) Higher rungs and non-abelian analogues.** The orbit-purity and pair laws
were proved for arbitrary finite abelian groups, so they transfer unchanged to
every conductor. Extending the entropy invariant beyond the abelian case requires
replacing "order of the Frobenius element" by "conjugacy class of the Frobenius",
and the corresponding class-profile entropy is the natural candidate invariant.

**(4) Effective versions.** How many primes are needed before the empirical type
entropy is provably within $\varepsilon$ of the exact value? Effective Chebotarev
bounds would turn the certificate of Corollary 7.4 into a finite, verifiable
computation over an explicit prime range.

---

## 13. Conclusion

At conductor $56$ the abelian ladder reaches, for the first time, a rung whose
Galois group is of composite order and not cyclic. We have shown that
$\mathbb{Q}(\zeta_{56})^{+}$ has degree $12$ with Galois group $C_6\times C_2$;
that the splitting type of a prime is the order of its Frobenius class, with
densities $\tfrac1{12}, \tfrac14, \tfrac16, \tfrac12$; that the residue-to-type
channel is deterministic and therefore fully pinned, transmitting exactly
$\tfrac43 + \tfrac14\log_2 3 = 1.7296$ bits with zero gap and strictly positive
residual uncertainty; that all Frobenius orbits are pure, giving $f\cdot g = 12$
with four shapes; that semiprimes reproduce the prime profile exactly; and,
finally, that this single measured number lies below the threshold $2$, which no
cyclic group of order $12$ can achieve.

The last point is the conceptual payoff. A quantity computed from prime
remainders — a Shannon entropy, a real number with a closed form — determines the
isomorphism class of a Galois group. Whether that phenomenon persists up the
ladder is precisely the content of the entropy-injectivity conjecture, and it is
the natural next rung to climb.
