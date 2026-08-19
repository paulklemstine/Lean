# The Parity Gap of the Exponent Counter: Chebotarev's Theorem, Rigidity, and the Exact Width of Closure

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

Let $p$ be prime and let $S, T \colon \{1,\dots,n\} \to \mathbb{Z}/p$ be injective. To each permutation $\sigma$ of $\{1,\dots,n\}$ attach the *exponent* $E_\sigma = \sum_{j} S(\sigma(j))T(j) \in \mathbb{Z}/p$, and define the **parity-weighted exponent counter**
$$c_{S,T}(r) \;=\; \sum_{\sigma \,:\, E_\sigma = r} \operatorname{sgn}(\sigma), \qquad r \in \mathbb{Z}/p,$$
which records the excess of even over odd permutations realising the residue $r$. Since exactly half of the permutations of an $n$-element set are even for $n \geq 2$, the counter has total mass zero; the *parity-gap conjecture* asserts that it nevertheless never vanishes identically.

We prove this conjecture. The counter is the coefficient vector, in the basis of powers of a primitive $p$-th root of unity, of the determinant of the DFT minor $\bigl(\zeta^{S(j)T(k)}\bigr)_{j,k}$, so the statement is equivalent to Chebotarev's theorem on roots of unity. We give a self-contained proof working in the ring $\mathbb{Z}[\zeta_p] = \mathbb{Z}[X]/(\Phi_p)$ and its reduction at the totally ramified prime $\pi = \zeta - 1$: a hypothetical kernel vector, normalised to be $\pi$-primitive, becomes a sparse polynomial over $\mathbb{F}_p$ of degree less than $p$ with a root of multiplicity $n$ at $1$ and at most $n$ terms, contradicting a sparse-multiplicity lemma proved by descent on the formal derivative.

We then develop the surrounding theory. The counter carries a two-sided gap: some residue has strictly more even than odd realisations and some other residue strictly more odd than even, so at least two residues carry a nonzero count and the $\ell^2$ mass is at least $2$. We deduce Tao's additive uncertainty principle $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq p+1$ for all nonzero $f \colon \mathbb{Z}/p \to \mathbb{C}$, and with it the Donoho–Stark multiplicative bound. Conversely, we prove that the parity gap **closes** over every composite modulus, giving a characterisation of primality purely in terms of signed permutation exponents, and we determine the maximal width of closure exactly for even moduli: over even $m \geq 4$ the gap closes at width $n \geq 2$ if and only if $n \leq m-2$. Finally we prove a lower bound $\pi^{\binom n 2} \mid \det$ on the $\pi$-adic depth of a DFT minor, exact for $n=2$, and deduce a rigidity theorem: when $\binom n2 \geq p-1$ the counter is constant modulo $p$, whence in that regime it either has full support or attains absolute value at least $p$.

**Keywords:** parity gap, Chebotarev's theorem on roots of unity, discrete Fourier transform minors, cyclotomic ramification, uncertainty principle, sparse polynomials, Coxeter length, sign-reversing involution.

---

## 1. Introduction

### 1.1 The problem

Fix a modulus $m \geq 2$, an integer $n \geq 0$, and two maps $S, T \colon \{1,\dots,n\} \to \mathbb{Z}/m$. For a permutation $\sigma \in \mathfrak{S}_n$ define its **exponent**
$$E_\sigma \;=\; \sum_{j=1}^{n} S(\sigma(j)) \, T(j) \;\in\; \mathbb{Z}/m .$$

The exponent map $\sigma \mapsto E_\sigma$ sends $n!$ permutations into $m$ residues; when $n! \gg m$ its fibres are enormous. The object of study is the **parity-weighted exponent counter**
$$c_{S,T}(r) \;=\; \sum_{\substack{\sigma \in \mathfrak{S}_n \\ E_\sigma = r}} \operatorname{sgn}(\sigma) \;\in\; \mathbb{Z},$$
the signed cardinality of the fibre over $r$.

Two elementary facts frame the question. First, for $n \geq 2$ the symmetric group has equally many even and odd elements, whence
$$\sum_{r \in \mathbb{Z}/m} c_{S,T}(r) \;=\; \sum_{\sigma \in \mathfrak{S}_n} \operatorname{sgn}(\sigma) \;=\; 0 . \tag{1.1}$$
Global cancellation is automatic. Second, nothing in (1.1) forbids *local* cancellation: it is a priori possible that $c_{S,T}(r) = 0$ for every $r$. When this happens we say the **parity gap closes** for the pair $(S,T)$.

> **Conjecture A (parity-gap conjecture).** For all $n \geq 2$, all primes $p$, and all injective $S, T \colon \{1,\dots,n\} \to \mathbb{Z}/p$, the counter $c_{S,T}$ is nonzero somewhere; in fact $\max_r |c_{S,T}(r)| \geq 1$, attained at a residue of the form $E_\sigma$ for a permutation $\sigma$ of minimal Coxeter length among those realising its exponent.

This paper proves Conjecture A and maps out its boundary.

### 1.2 Why injectivity and primality

Both hypotheses are indispensable.

If $S$ is non-injective, say $S(i_1) = S(i_2)$ with $i_1 \neq i_2$, then composing $\sigma$ with the transposition $(i_1\,i_2)$ on the left preserves the exponent while reversing the sign, so every fibre cancels and $c_{S,T} \equiv 0$ identically. Injectivity is thus not a technicality but the exact condition under which the question is nontrivial.

If $m$ is composite the gap genuinely closes. The smallest example is $m=4$, $n=2$, $S = T = (0,2)$: both maps are injective, but every product $S(i)T(j)$ vanishes in $\mathbb{Z}/4$ (indeed $2\cdot 2 = 4 \equiv 0$), so both permutations have exponent $0$ and their signs $+1, -1$ cancel. Section 6 shows that this is the tip of a large phenomenon.

### 1.3 The determinant reformulation

Let $\zeta$ be a primitive $p$-th root of unity in any ring where such a thing exists, and let $M$ be the $n \times n$ matrix
$$M_{jk} = \zeta^{\,S(j) \cdot T(k)} .$$
This is the submatrix of the $p \times p$ DFT matrix $(\zeta^{ab})_{a,b \in \mathbb{Z}/p}$ with rows indexed by the (distinct) values $S(1),\dots,S(n)$ and columns by the (distinct) values $T(1),\dots,T(n)$. Expanding by Leibniz and grouping permutations according to their exponent gives the identity

$$\det M \;=\; \sum_{\sigma \in \mathfrak{S}_n} \operatorname{sgn}(\sigma) \prod_{j} \zeta^{S(\sigma(j))T(j)} \;=\; \sum_{\sigma} \operatorname{sgn}(\sigma)\, \zeta^{E_\sigma} \;=\; \sum_{r \in \mathbb{Z}/p} c_{S,T}(r)\, \zeta^{r}. \tag{1.2}$$

Since $\{1, \zeta, \dots, \zeta^{p-2}\}$ is a $\mathbb{Z}$-basis of $\mathbb{Z}[\zeta_p]$ and (1.1) pins the redundancy, (1.2) makes the equivalence transparent:

$$c_{S,T} \not\equiv 0 \iff \det M \neq 0 \iff \text{the DFT minor on rows } S, \text{ columns } T \text{ is nonsingular.}$$

The assertion that *every* such minor is nonsingular, for every $n$ and every pair of injective $S, T$, is **Chebotarev's theorem on roots of unity**. Conjecture A is precisely that theorem, dressed in combinatorial clothing.

### 1.4 Results

- **Theorem 4.4 (Chebotarev, integral form).** For prime $p$ and injective $S,T$, the matrix $\bigl(\zeta^{S(j)T(k)}\bigr)$ is nonsingular over $\mathbb{Z}[\zeta_p]$.
- **Theorem 4.5 (Conjecture A).** For prime $p$ and injective $S,T$, there is $r$ with $c_{S,T}(r) \neq 0$.
- **Theorem 5.3 (Conjecture A, literal form).** There is $\sigma \in \mathfrak{S}_n$ with $|c_{S,T}(E_\sigma)| \geq 1$, with $E_\sigma$ maximising $|c_{S,T}|$, and with $\ell(\sigma)$ minimal among permutations of the same exponent.
- **Theorem 5.5 (two-sided gap).** For $n \geq 2$ some residue has $c_{S,T} > 0$ and some other has $c_{S,T} < 0$; hence $|\operatorname{supp} c_{S,T}| \geq 2$ and $\sum_r c_{S,T}(r)^2 \geq 2$.
- **Theorem 6.4 (primality characterisation).** The parity gap closes for some injective pair of some width $n \geq 2$ over $\mathbb{Z}/m$ **iff** $m$ is composite.
- **Theorem 6.8 (exact width, even moduli).** For even $m \geq 4$ and $n \geq 2$: the gap closes at width $n$ **iff** $n \leq m-2$.
- **Theorem 7.1 (additive uncertainty).** For prime $p$ and nonzero $f \colon \mathbb{Z}/p \to \mathbb{C}$, $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \geq p+1$; consequently $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \geq p$.
- **Theorem 8.2 ($\pi$-adic depth).** $\pi^{\binom n 2}$ divides $\det M$, with equality of order for $n=2$.
- **Theorem 8.5 (rigidity).** If $\binom n2 \geq p-1$ then $c_{S,T}$ is constant modulo $p$; hence either $\operatorname{supp} c_{S,T} = \mathbb{Z}/p$ or $\max_r|c_{S,T}(r)| \geq p$.

---

## 2. The arithmetic setting: $\mathbb{Z}[\zeta_p]$ and its ramified prime

We build the coefficient ring by hand, so that no algebraic number theory is presupposed.

**Definition 2.1.** For a prime $p$ let $\Phi_p(X) = 1 + X + \dots + X^{p-1}$ be the $p$-th cyclotomic polynomial and set
$$R_p \;=\; \mathbb{Z}[X]/(\Phi_p), \qquad \zeta \;=\; \text{image of } X .$$

**Lemma 2.2.** $R_p$ is an integral domain, and it is Noetherian.

*Proof.* $\Phi_p$ is irreducible over $\mathbb{Z}$ (Eisenstein after $X \mapsto X+1$), hence prime in the UFD $\mathbb{Z}[X]$, hence generates a prime ideal; the quotient of a Noetherian ring by a prime ideal is a Noetherian domain. $\square$

**Lemma 2.3.** In $R_p$: (i) $\sum_{i<p}\zeta^i = 0$; (ii) $\zeta^p = 1$; (iii) $p \neq 0$; (iv) $\zeta \neq 1$; (v) $\zeta$ has order exactly $p$; consequently (vi) $\zeta^k = \zeta^{l}$ with $0 \le k,l < p$ forces $k=l$.

*Proof.* (i) is the defining relation. (ii): multiply (i) by $\zeta - 1$ and use $\bigl(\sum_{i<p}\zeta^i\bigr)(\zeta-1) = \zeta^p - 1$. (iii): if $p = 0$ in $R_p$ then $\Phi_p \mid p$ in $\mathbb{Z}[X]$, impossible by degrees since $\deg \Phi_p = p-1 \geq 1$ while $\deg p = 0$. (iv): if $\zeta = 1$ then (i) reads $p = 0$, contradicting (iii). (v): the order divides the prime $p$ by (ii), and is not $1$ by (iv). (vi) is immediate from (v). $\square$

**Definition 2.4 (reduction at the ramified prime).** Since $\Phi_p(1) = p \equiv 0 \pmod p$, evaluation at $X = 1$ followed by reduction mod $p$ descends to a ring homomorphism
$$\mathrm{red} \colon R_p \longrightarrow \mathbb{F}_p, \qquad \mathrm{red}(\zeta) = 1 .$$
Write $\pi = \zeta - 1 \in R_p$, so $\mathrm{red}(\pi) = 0$.

**Lemma 2.5.** $\pi \mid p$ in $R_p$, and $\ker(\mathrm{red}) = (\pi)$. Moreover $\pi \neq 0$ and $(\pi) \neq R_p$.

*Proof.* Since $X - 1 \mid \Phi_p(X) - \Phi_p(1) = \Phi_p(X) - p$ in $\mathbb{Z}[X]$, passing to $R_p$ gives $\pi \mid -p$, i.e. $\pi \mid p$. For the kernel: let $y = \bar F$ with $F \in \mathbb{Z}[X]$ and $\mathrm{red}(y) = 0$, i.e. $p \mid F(1)$ in $\mathbb{Z}$, say $F(1) = pm$. Then $X - 1 \mid F - F(1)$, so in $R_p$ we get $y = \pi q + pm$ for some $q$, and $\pi \mid p$ finishes. Finally $\pi \neq 0$ by Lemma 2.3(iv), and if $(\pi) = R_p$ then $\pi$ is a unit, so $\mathrm{red}(\pi) = 0$ would be a unit of $\mathbb{F}_p$ — absurd. $\square$

Thus reduction modulo $\pi$ is exactly the "collapse all $p$-th roots of unity to $1$" map. Its violence is the source of the proof: it turns $n$ distinct roots into a single root of multiplicity $n$.

**Lemma 2.6 (no infinite $\pi$-divisibility).** If $y \in R_p$ satisfies $\pi^m \mid y$ for every $m$, then $y = 0$.

*Proof.* Krull's intersection theorem: in a Noetherian domain, $\bigcap_{i} I^{i} = 0$ for any proper ideal $I$. Apply with $I = (\pi)$, proper by Lemma 2.5. $\square$

**Proposition 2.7 (primitive scaling).** Let $v \colon \{1,\dots,n\} \to R_p$ be a vector with some $v_{k} \neq 0$. Then there are $m \geq 0$ and $w$ with $v_k = \pi^{m} w_k$ for all $k$ and $\mathrm{red}(w_{k_0}) \neq 0$ for some $k_0$.

*Proof.* Let $P(m)$ be the statement "$\pi^m$ divides every $v_k$". $P(0)$ holds; by Lemma 2.6 applied to a nonzero coordinate, $P(m)$ fails for some $m$. Let $m_0$ be least with $\neg P(m_0)$; then $m_0 \geq 1$ and $P(m_0-1)$ holds, so we may write $v_k = \pi^{m_0-1}w_k$. If every $\mathrm{red}(w_k)$ were $0$, then $\pi \mid w_k$ for all $k$ by Lemma 2.5, giving $P(m_0)$ — contradiction. $\square$

---

## 3. Sparse polynomials in characteristic $p$

The finite-field engine of the proof is the following statement, of independent interest.

**Theorem 3.1 (sparse-multiplicity lemma).** Let $p$ be prime and $f \in \mathbb{F}_p[X]$ with $f \neq 0$ and $\deg f < p$. If $(X-1)^n \mid f$, then $f$ has strictly more than $n$ nonzero coefficients:
$$n \;<\; \#\{k : \operatorname{coeff}_k(f) \neq 0\}.$$

Two remarks before the proof. The degree hypothesis is essential: over $\mathbb{F}_p$ the polynomial $X^p - 1 = (X-1)^p$ has just two terms and a root of multiplicity $p$ at $1$. And the bound is sharp: $(X-1)^n$ itself has $n+1$ terms whenever $n < p$, since its binomial coefficients $\binom nk$ are then not all divisible by $p$ — more simply, take $f = (X-1)^n$ with $n < p$.

*Proof.* Induction on $n$.

*Base $n = 0$.* A nonzero polynomial has at least one nonzero coefficient.

*Step.* Assume the statement for $n$ and let $(X-1)^{n+1} \mid f$ with $f \neq 0$, $\deg f < p$.

**(a) Normalise the trailing degree.** Let $a$ be the trailing degree of $f$ and write $f = X^a h$. Multiplication by $X^a$ shifts exponents injectively, so $h$ and $f$ have the same number of terms; also $\deg h \le \deg f < p$, $h \neq 0$, and $h(0) \neq 0$ by construction. Since $X$ and $X-1$ are coprime (indeed $1\cdot X + (-1)(X-1) = 1$), $(X-1)^{n+1}$ is coprime to $X^a$, hence $(X-1)^{n+1} \mid h$.

**(b) $h$ is non-constant.** If $\deg h = 0$ then $h$ is a nonzero constant, which cannot be divisible by the degree-$(n+1)$ polynomial $(X-1)^{n+1}$.

**(c) Differentiate.** Put $g = h'$. Writing $h = (X-1)^{n+1}q$ and differentiating, $g = (n+1)(X-1)^{n}q + (X-1)^{n+1}q'$, so $(X-1)^n \mid g$.

**(d) $g \neq 0$.** Let $d = \deg h \geq 1$. The coefficient of $X^{d-1}$ in $g$ equals $d \cdot \operatorname{lc}(h)$. The leading coefficient is nonzero, and $d \not\equiv 0 \pmod p$ because $1 \le d < p$. Hence $g \neq 0$; also $\deg g < \deg h < p$.

**(e) $g$ has exactly one term fewer.** Every nonzero coefficient of $g$ at index $k$ comes from a nonzero coefficient of $h$ at index $k+1 \geq 1$ (as $\operatorname{coeff}_k(g) = (k+1)\operatorname{coeff}_{k+1}(h)$), so the support of $g$ injects into the support of $h$ with the index $0$ removed. Since $\operatorname{coeff}_0(h) \neq 0$ by (a), we get $\#\operatorname{supp}(g) + 1 \leq \#\operatorname{supp}(h)$.

**(f) Conclude.** By induction $n < \#\operatorname{supp}(g)$, hence $n+1 < \#\operatorname{supp}(g)+1 \le \#\operatorname{supp}(h) = \#\operatorname{supp}(f)$. $\square$

The hypothesis $\deg f < p$ enters at exactly one place, step (d)/(e): it guarantees no exponent occurring in $h$ is a multiple of $p$, so differentiation annihilates the constant term and *nothing else*. This is the whole reason the argument is genuinely characteristic-$p$ and not a transplanted characteristic-zero argument.

---

## 4. Chebotarev's theorem and Conjecture A

We also need an elementary divisibility fact.

**Lemma 4.1.** Let $A$ be an integral domain, $Z \subset A$ a finite subset and $f \in A[X]$ with $f(z) = 0$ for all $z \in Z$. Then $\prod_{z \in Z}(X - z) \mid f$.

*Proof.* Induction on $|Z|$. Empty case trivial. For $Z = \{a\} \sqcup Z'$: the factor theorem gives $f = (X-a)g$; for $z \in Z'$, $0 = f(z) = (z-a)g(z)$ and $z \neq a$, so $g(z) = 0$ since $A$ is a domain. Apply the induction hypothesis to $g$ and $Z'$. $\square$

**Definition 4.2.** For $r \in \mathbb{Z}/p$ write $\hat r \in \{0,\dots,p-1\}$ for its canonical representative and define the character $\chi(r) = \zeta^{\hat r} \in R_p$. Lemma 2.3 gives $\chi(r+s) = \chi(r)\chi(s)$, $\chi(rs) = \zeta^{\hat r \hat s}$, $\chi$ injective, and $\mathrm{red}\circ\chi \equiv 1$.

**Definition 4.3.** For $S,T \colon \{1,\dots,n\}\to\mathbb{Z}/p$ let $M(S,T)$ be the $n\times n$ matrix over $R_p$ with entries $M_{jk} = \chi\bigl(S(j)T(k)\bigr) = \zeta^{\widehat{S(j)}\,\widehat{T(k)}}$.

**Theorem 4.4 (Chebotarev's theorem, integral form).** If $S$ and $T$ are injective then $\det M(S,T) \neq 0$ in $R_p$.

*Proof.* Suppose $\det M = 0$. Since $R_p$ is a domain, a matrix over $R_p$ with zero determinant has a nonzero kernel vector $v$ (clear denominators from a kernel vector over the fraction field). By Proposition 2.7 write $v = \pi^{m}w$ with $\mathrm{red}(w_{k_0}) \neq 0$ for some $k_0$. Since $\pi^m \neq 0$ and $R_p$ is a domain, $Mw = 0$ too, i.e. for every row $j$,
$$\sum_{k=1}^{n} w_k \, \zeta^{\widehat{S(j)}\cdot\widehat{T(k)}} \;=\; 0. \tag{4.1}$$

Define the sparse polynomial
$$f(X) \;=\; \sum_{k=1}^{n} w_k \, X^{\widehat{T(k)}} \;\in\; R_p[X].$$
By (4.1), $f\bigl(\zeta^{\widehat{S(j)}}\bigr) = 0$ for every $j$. The evaluation points are pairwise distinct: $\zeta^{\widehat{S(j_1)}} = \zeta^{\widehat{S(j_2)}}$ forces $\widehat{S(j_1)} = \widehat{S(j_2)}$ by Lemma 2.3(vi), hence $j_1 = j_2$ by injectivity of $S$. Let $Z = \{\zeta^{\widehat{S(j)}} : j\}$, a set of exactly $n$ elements. Lemma 4.1 gives
$$\prod_{z \in Z}(X - z) \ \Big|\ f \quad \text{in } R_p[X].$$

Apply $\mathrm{red}$ coefficientwise, obtaining $\bar f \in \mathbb{F}_p[X]$. Each factor maps as $X - \zeta^{\widehat{S(j)}} \mapsto X - 1$, so
$$(X-1)^{n} \ \big|\ \bar f \quad \text{in } \mathbb{F}_p[X].$$
Now count:
- $\bar f \neq 0$, because its coefficient at $\widehat{T(k_0)}$ is $\mathrm{red}(w_{k_0}) \neq 0$ (distinct $k$ give distinct exponents $\widehat{T(k)}$ by injectivity of $T$, so no cancellation occurs among the terms);
- $\deg \bar f < p$, because every exponent $\widehat{T(k)}$ lies in $\{0,\dots,p-1\}$;
- $\#\operatorname{supp}\bar f \leq n$, because $\bar f$ is a sum of $n$ monomials.

Theorem 3.1 forces $n < \#\operatorname{supp}\bar f \le n$, a contradiction. $\square$

**Theorem 4.5 (Conjecture A: the parity gap never closes).** For prime $p$ and injective $S,T \colon \{1,\dots,n\}\to\mathbb{Z}/p$, there exists $r \in \mathbb{Z}/p$ with $c_{S,T}(r) \neq 0$.

*Proof.* By the Leibniz expansion (1.2), interpreted in $R_p$ via $\chi$,
$$\det M(S,T) \;=\; \sum_{\sigma}\operatorname{sgn}(\sigma)\,\chi(E_\sigma) \;=\; \sum_{r\in\mathbb{Z}/p} c_{S,T}(r)\,\chi(r),$$
the second equality by partitioning $\mathfrak S_n$ into the fibres of $\sigma \mapsto E_\sigma$. If $c_{S,T} \equiv 0$ the right-hand side is $0$, contradicting Theorem 4.4. $\square$

**Corollary 4.6 (analytic form).** Let $\omega = e^{2\pi i/p}$. For injective $S,T$ the complex matrix $\bigl(\omega^{S(j)T(k)}\bigr)_{j,k}$ is nonsingular. Equivalently, every square submatrix of the $p\times p$ DFT matrix of $\mathbb{Z}/p$ is nonsingular, in every size.

*Proof.* The complex minor has the same Leibniz expansion $\sum_r c_{S,T}(r)\,\omega^{\hat r}$. Suppose it vanishes. Then the integer polynomial $F(X) = \sum_r c_{S,T}(r)X^{\hat r}$, of degree $< p$, has $\omega$ as a root, so the minimal polynomial $\Phi_p$ of $\omega$ over $\mathbb{Q}$ divides $F$; comparing degrees, $F = \lambda\,\Phi_p$ for a constant $\lambda$, i.e. all the $c_{S,T}(r)$ are equal to $\lambda$. The mass identity (1.1) then gives $p\lambda = 0$, so $\lambda = 0$ and $c_{S,T}\equiv 0$, contradicting Theorem 4.5. Sizes $n \in \{0,1\}$ are immediate ($\det = 1$ and $\det = \omega^{S(1)T(1)} \neq 0$). $\square$

---

## 5. Coxeter length, the literal form, and the two-sided gap

### 5.1 Coxeter length

**Definition 5.1.** The **inversion set** of $\sigma \in \mathfrak S_n$ is $\operatorname{Inv}(\sigma) = \{(i,j) : j < i, \ \sigma(i) < \sigma(j)\}$, and the **Coxeter length** is $\ell(\sigma) = |\operatorname{Inv}(\sigma)|$. It equals the minimal number of adjacent transpositions needed to express $\sigma$ in the standard Coxeter presentation of $\mathfrak S_n$.

**Proposition 5.2.** $\operatorname{sgn}(\sigma) = (-1)^{\ell(\sigma)}$, and $\ell(\sigma) = 0$ iff $\sigma = \mathrm{id}$.

*Proof.* The sign is computed by the classical product $\prod_{j<i}\frac{\sigma(i)-\sigma(j)}{i-j}$ over ordered pairs, whose sign is $(-1)$ raised to the number of pairs with reversed order, i.e. $(-1)^{\ell(\sigma)}$. If $\ell(\sigma) = 0$ then $\sigma$ has no inversions, hence is strictly monotone, hence — being a bijection of a finite linear order — the identity. $\square$

### 5.2 The literal form of Conjecture A

**Theorem 5.3 (Conjecture A, literal form).** Let $p$ be prime and $S,T \colon \{1,\dots,n\}\to\mathbb{Z}/p$ injective. Then there exists $\sigma \in \mathfrak S_n$ such that
1. $\bigl|c_{S,T}(E_\sigma)\bigr| \geq 1$;
2. $\bigl|c_{S,T}(r)\bigr| \leq \bigl|c_{S,T}(E_\sigma)\bigr|$ for all $r \in \mathbb{Z}/p$;
3. $\ell(\sigma) \leq \ell(\tau)$ for every $\tau \in \mathfrak S_n$ with $E_\tau = E_\sigma$.

*Proof.* Since $c_{S,T}$ is integer-valued, a nonzero value has absolute value at least $1$. Choose $r_{\max} \in \mathbb{Z}/p$ maximising $|c_{S,T}|$; by Theorem 4.5 there is some $r_0$ with $c_{S,T}(r_0) \neq 0$, so $|c_{S,T}(r_{\max})| \geq |c_{S,T}(r_0)| \geq 1$ and in particular $c_{S,T}(r_{\max}) \neq 0$. Hence the fibre $F = \{\sigma : E_\sigma = r_{\max}\}$ is nonempty (an empty fibre would make the counter $0$ there). Choose $\sigma \in F$ minimising $\ell$; the three assertions hold by construction. $\square$

### 5.3 The gap is two-sided

**Lemma 5.4.** For $n \geq 2$, $\sum_{\sigma \in \mathfrak S_n}\operatorname{sgn}(\sigma) = 0$; hence $\sum_r c_{S,T}(r) = 0$ for every modulus and every $S,T$.

*Proof.* Right multiplication by a fixed transposition $\tau$ is a bijection of $\mathfrak S_n$ negating the sign, so the sum equals its own negative. $\square$

**Theorem 5.5 (two-sided gap).** For prime $p$, $n \geq 2$, and injective $S,T$: there exist $r_+$ with $c_{S,T}(r_+) > 0$ and $r_- $ with $c_{S,T}(r_-) < 0$. Consequently
$$\bigl|\operatorname{supp} c_{S,T}\bigr| \geq 2 \qquad\text{and}\qquad \sum_{r} c_{S,T}(r)^2 \geq 2 .$$

*Proof.* By Theorem 4.5 some value is nonzero; by Lemma 5.4 the values sum to zero, so both a strictly positive and a strictly negative value must occur. Two distinct residues therefore carry nonzero counts, and since the values are integers of absolute value at least $1$, the sum of squares is at least $2$. $\square$

Thus the parity gap is not merely nonzero; it is a genuine *gap*, with residues on both sides of the balance.

---

## 6. The converse: composite moduli and the exact width of closure

We now drop primality and ask when the gap *can* close. Write $\mathrm{GapCloses}(m,n)$ for the assertion that some injective pair $S,T \colon \{1,\dots,n\}\to\mathbb{Z}/m$ has $c_{S,T} \equiv 0$.

### 6.1 Closure by constant exponents

**Lemma 6.1.** If $S(i)T(j) = 0$ for all $i,j$, then all exponents are $0$; and if the exponent map is constant with $n\ge 2$, then $c_{S,T} \equiv 0$.

*Proof.* The first claim is immediate. For the second, if $E_\sigma = e$ for all $\sigma$, then $c_{S,T}(e) = \sum_\sigma \operatorname{sgn}(\sigma) = 0$ by Lemma 5.4, and $c_{S,T}(r) = 0$ trivially for $r \neq e$. $\square$

**Theorem 6.2 (annihilating progressions).** Let $m = ab$ and $2 \leq n \leq \min(a,b)$. Then the maps $S(i) = a\,i$, $T(j) = b\,j$ (indices $0,\dots,n-1$) are injective modulo $m$ and satisfy $c_{S,T}\equiv 0$.

*Proof.* Injectivity: $a i < ab = m$ for $i < b$, so distinct $i < n \le b$ give distinct residues; symmetrically for $T$. Annihilation: $S(i)T(j) = ab\,ij \equiv 0 \pmod m$. Apply Lemma 6.1. $\square$

**Corollary 6.3.** For $m = 4$, $S=T=(0,2)$ gives $c_{S,T}\equiv 0$: Conjecture A fails at the very first composite modulus.

**Theorem 6.4 (the parity gap detects primality).** For $m \geq 2$: $\mathrm{GapCloses}(m,n)$ holds for some $n \geq 2$ **iff** $m$ is composite.

*Proof.* ($\Leftarrow$) Write $m = ab$ with $a,b \geq 2$ and apply Theorem 6.2 with $n = 2 \le \min(a,b)$. ($\Rightarrow$) If $m = p$ is prime, Theorem 4.5 forbids closure at every $n$. $\square$

### 6.2 Closure by pigeonhole involution

Theorem 6.2 is inefficient: it only reaches $n \le \min(a,b) \le \sqrt m$, and for the trivial reason that all exponents coincide. A far better mechanism keeps the exponent map highly non-constant and cancels by a sign-reversing involution.

**Theorem 6.5 (pigeonhole criterion).** Let $S,T \colon \{1,\dots,n\}\to\mathbb{Z}/m$, let $J \subseteq \{1,\dots,n\}$ be a set of row indices, let $B \leq \mathbb{Z}/m$ be a subgroup, and let $\kappa$ be a map from columns to a finite set of "classes" such that:
1. for all $i, i' \in J$ and all $b \in B$: $(S(i) - S(i'))\, b = 0$;
2. columns with the same $\kappa$-value have $T$-values differing by an element of $B$;
3. the total number of $\kappa$-classes is strictly smaller than $|J|$, so that for every permutation $\sigma$ the $|J|$ columns of $\sigma^{-1}(J)$ must meet some class twice.

Then $c_{S,T} \equiv 0$.

*Proof.* Fix $\sigma$. By (3) there are two distinct columns $j_1 \neq j_2$ with $\sigma(j_1), \sigma(j_2) \in J$ and $\kappa(j_1) = \kappa(j_2)$. Then
$$\bigl(E_{\sigma\cdot(j_1 j_2)} - E_\sigma\bigr) = \bigl(S(\sigma(j_2)) - S(\sigma(j_1))\bigr)\bigl(T(j_1) - T(j_2)\bigr) = 0$$
by (1) and (2). So $\sigma \mapsto \sigma\cdot(j_1 j_2)$ (with $j_1, j_2$ chosen canonically, e.g. lexicographically least) is an involution on each fibre of $E$, without fixed points, reversing the sign. Signed fibre counts therefore vanish. $\square$

**Theorem 6.6 (wide closure).** Let $m = ab$ with $a,b \geq 2$ and $2 \leq n \leq m - a$. Then $\mathrm{GapCloses}(m,n)$.

*Sketch.* Take $B$ the subgroup of order $b$ generated by $a$; the multiples of $b$ annihilate $B$. Choose $J$ to consist of $n - (m-a-b+1)$-many, appropriately many, rows whose $S$-values are multiples of $b$, and index the columns by a "digit swap" enumeration of $\{0,\dots,m-1\}$ that groups residues by their class modulo $B$ into fewer than $|J|$ classes. The counting inequality $n \leq m - a$ is exactly what makes the pigeonhole hypothesis (3) hold. Apply Theorem 6.5. $\square$

**Corollary 6.7 (even moduli).** For even $m \geq 4$ and $2 \leq n \leq m-2$, the gap closes. (Take $a = 2$.) More generally, for composite $m$ with least prime factor $q$, the gap closes at every width $2 \le n \le m - q$.

### 6.3 The top two widths are always open

**Theorem 6.8 (maximal width, even moduli).** For even $m \geq 4$ and $n \geq 2$:
$$\mathrm{GapCloses}(m,n) \iff n \leq m-2 .$$

The forward direction is Corollary 6.7. The converse rests on two facts valid for every modulus $m$:

**(a) Full width $n = m$.** If $S, T \colon \{1,\dots,m\} \to \mathbb{Z}/m$ are injective they are bijections, and the matrix $(\omega^{S(j)T(k)})$ is, after permuting rows and columns, the full DFT matrix of $\mathbb{Z}/m$ — a Vandermonde matrix in the $m$ distinct $m$-th roots of unity $\omega^{0},\dots,\omega^{m-1}$, hence nonsingular. By the Leibniz expansion the counter cannot vanish identically.

**(b) Width $n = m-1$.** Suppose $c_{S,T}\equiv 0$ with $n = m-1$. Then the $(m-1)\times(m-1)$ minor of the DFT matrix on rows $\operatorname{im}S$ and columns $\operatorname{im}T$ is singular, so there is a nonzero vector $u$ supported on $\operatorname{im}T$ (a set of size $m-1$) whose Fourier transform vanishes on $\operatorname{im}S$, i.e. is supported on the single remaining frequency. A function whose spectrum is a single point is a nonzero multiple of a character, hence has *full* support $m$ — contradicting $|\operatorname{supp} u| \le m-1$. Equivalently, this is the classical uncertainty inequality $|\operatorname{supp} u| \cdot |\operatorname{supp} \hat u| \geq m$ for cyclic groups, applied with $|\operatorname{supp}\hat u| = 1$.

Together, no closure occurs at $n \in \{m-1, m\}$, and combined with Corollary 6.7 this pins the even case exactly. For general composite $m$ with least prime factor $q$ the maximal width lies in the window $[\,m-q,\ m-2\,]$.

---

## 7. The uncertainty principle

Let $\omega = e^{2\pi i /p}$ and let $\hat f(\xi) = \sum_{x\in\mathbb{Z}/p} f(x)\,\omega^{-x\xi}$ denote the DFT.

**Theorem 7.1 (additive uncertainty principle for prime moduli).** For every nonzero $f \colon \mathbb{Z}/p \to \mathbb{C}$,
$$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \;\geq\; p+1 .$$

*Proof.* Let $A = \operatorname{supp} f$ and $B = \operatorname{supp}\hat f$, and suppose $|A| + |B| \leq p$, i.e. $|A| \leq |B^{c}|$ where $B^c$ is the complement of $B$. Choose a subset $C \subseteq B^c$ with $|C| = |A| =: n$. The conditions "$f$ vanishes off $A$" and "$\hat f$ vanishes on $C$" say that the vector $(f(x))_{x \in A}$, which is nonzero, lies in the kernel of the $n\times n$ matrix $\bigl(\omega^{-x\xi}\bigr)_{\xi \in C,\, x \in A}$. Enumerating $A$ and $C$ by injective maps $T$ and $S$ respectively, this matrix is exactly a DFT minor $(\omega^{-S(j)T(k)})$, which Corollary 4.6 says is nonsingular. Hence $f = 0$, a contradiction. $\square$

**Corollary 7.2 (Donoho–Stark, prime case).** For nonzero $f$, $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \geq p$.

*Proof.* Write $|\operatorname{supp} f| = \alpha+1$, $|\operatorname{supp}\hat f| = \beta+1$ with $\alpha,\beta \geq 0$. Theorem 7.1 gives $\alpha+\beta \geq p-1$, so $(\alpha+1)(\beta+1) = \alpha\beta+\alpha+\beta+1 \geq p$. $\square$

The additive bound is strictly stronger than the multiplicative one and is *false* for composite moduli: over $\mathbb{Z}/m$ with $m=ab$, the indicator of the subgroup of order $a$ has $|\operatorname{supp} f| = a$ and $|\operatorname{supp}\hat f| = b$, so the sum $a+b$ can be as small as $2\sqrt m$. These extremal functions are exactly the objects produced by the closure constructions of Section 6 — the two failures are one and the same.

**Application (exact sparse recovery).** Say $f \colon \mathbb{Z}/p \to \mathbb{C}$ is *$k$-sparse* if $|\operatorname{supp} f| \leq k$. Theorem 7.1 implies: **a $k$-sparse signal on $\mathbb{Z}/p$ is uniquely determined by any $2k$ of its Fourier coefficients, provided $2k \leq p$.** Indeed if two $k$-sparse signals agree on a set $\Xi$ of $2k$ frequencies, their difference $g$ is $2k$-sparse with $\hat g$ vanishing on $\Xi$, so $|\operatorname{supp} g| + |\operatorname{supp} \hat g| \leq 2k + (p - 2k) = p < p+1$, forcing $g = 0$. Over composite moduli this fails for the reason just given: a subgroup indicator is sparse with a sparse spectrum.

---

## 8. $\pi$-adic depth and rigidity

Nonsingularity invites quantification: how deeply does $\pi$ divide $\det M(S,T)$?

**Theorem 8.1 (multilinear Taylor bound).** Let $A$ be a commutative ring and $t \in A$. Suppose the rows of an $n\times n$ matrix $M$ over $A$ can each be written as a polynomial expansion in powers of $t$ of the shape $M_{jk} = \sum_{l \geq 0} t^{l}\, c^{(j)}_{l}\, \beta_{lk}$ with the "order-$l$" contribution of row $j$ carrying the factor $t^l$. Then $t^{\,0+1+\dots+(n-1)}$ divides $\det M$.

*Proof.* Expand the determinant multilinearly in the rows, one Taylor order $l_j$ per row. A term in which two rows use the same order $l$ has two proportional row-contributions and vanishes by alternation. So each surviving term has pairwise distinct orders $l_1,\dots,l_n$, a set of $n$ distinct naturals, whose sum is at least $0+1+\dots+(n-1) = \binom n2$. Each such term is divisible by $t^{\sum l_j}$. $\square$

**Theorem 8.2 ($\pi$-adic depth of a DFT minor).** For any $S,T \colon \{1,\dots,n\}\to\mathbb{Z}/p$,
$$\pi^{\binom n 2} \ \Big|\ \det M(S,T) \quad\text{in } R_p .$$
For $n=2$ and injective $S,T$ the order is *exactly* $1 = \binom 22$.

*Proof.* Write $\zeta^{\widehat{S(j)}} = 1 + u_j$ with $u_j = \zeta^{\widehat{S(j)}} - 1$, divisible by $\pi$ since $\mathrm{red}(u_j)=0$. Then $M_{jk} = (1+u_j)^{\widehat{T(k)}} = \sum_{l} \binom{\widehat{T(k)}}{l} u_j^{\,l}$, which is a Taylor expansion of the shape required by Theorem 8.1 with $t = \pi$ (as $\pi^l \mid u_j^l$). This gives the divisibility.

For $n = 2$: $\det M = \zeta^{s_1t_1+s_2t_2} - \zeta^{s_1t_2+s_2t_1} = \zeta^{s_1t_2+s_2t_1}\bigl(\zeta^{d}-1\bigr)$ with $d \equiv (s_1-s_2)(t_1-t_2) \not\equiv 0 \pmod p$ by injectivity and primality. Now $\zeta^d - 1 = \pi\,(1+\zeta+\dots+\zeta^{d-1})$, and $\mathrm{red}(1+\zeta+\dots+\zeta^{d-1}) = d \neq 0$ in $\mathbb{F}_p$, so $\pi^2 \nmid \det M$. $\square$

**Remark 8.3.** Since $p$ is, up to a unit, $\pi^{p-1}$, Theorem 8.2 shows that $p \mid \det M$ as soon as $\binom n2 \geq p-1$. This is why Chebotarev's theorem cannot be proved by reduction modulo $p$: in the large-$n$ regime the entire minor lies in $p\,R_p$. The finer prime $\pi$ is indispensable.

**Lemma 8.4.** Over $\mathbb{F}_p$ one has $(X-1)^{p-1} = 1 + X + \dots + X^{p-1}$.

*Proof.* Multiply both sides by $X-1$: the left becomes $(X-1)^p = X^p - 1$ by the Frobenius/freshman's dream, and the right becomes $X^p-1$ by the geometric sum identity. Since $\mathbb{F}_p[X]$ is a domain and $X-1 \neq 0$, cancel. $\square$

**Theorem 8.5 (mod-$p$ rigidity).** Suppose $\binom n2 \geq p-1$. Then for all $S,T$ and all $r, r' \in \mathbb{Z}/p$,
$$c_{S,T}(r) \equiv c_{S,T}(r') \pmod p .$$

*Proof.* Let $F(X) = \sum_{r\in\mathbb{Z}/p} c_{S,T}(r)\,X^{\hat r} \in \mathbb{Z}[X]$, of degree $< p$. By (1.2), $\det M(S,T)$ is the image of $F$ in $R_p = \mathbb{Z}[X]/(\Phi_p)$. Theorem 8.2 gives $\pi^{p-1} \mid \det M$. Since $\pi$ is the image of $X-1$, this says $F \in \bigl((X-1)^{p-1}, \Phi_p\bigr)$ in $\mathbb{Z}[X]$; reducing modulo $p$ and using Lemma 8.4 (which also identifies $\Phi_p \bmod p$ with $(X-1)^{p-1}$), we get
$$(X-1)^{p-1} \ \big|\ \bar F \quad\text{in } \mathbb{F}_p[X].$$
But $(X-1)^{p-1} = 1+X+\dots+X^{p-1}$ has degree $p-1$ and $\deg \bar F < p$, so $\bar F = \lambda\,(1+X+\dots+X^{p-1})$ for a scalar $\lambda \in \mathbb{F}_p$ (comparing degrees: the quotient is a constant). Hence all coefficients of $\bar F$ are equal to $\lambda$, i.e. all $c_{S,T}(r)$ are congruent mod $p$. $\square$

**Theorem 8.6 (dichotomy in the rigid regime).** Let $p$ be prime, $S,T$ injective, and $\binom n2 \geq p-1$. Then either
- $c_{S,T}(r) \neq 0$ for **every** $r \in \mathbb{Z}/p$ (full support), or
- $\max_r |c_{S,T}(r)| \geq p$.

*Proof.* By Theorem 8.5 all values share a common residue $\lambda$ modulo $p$. If $\lambda \neq 0$ then no value is zero: full support. If $\lambda = 0$ then every value is a multiple of $p$; by Theorem 4.5 some value is nonzero, hence has absolute value at least $p$. $\square$

**Theorem 8.7 (general support-or-height dichotomy).** For all $n$ and injective $S,T$: either
$$\bigl|\operatorname{supp} c_{S,T}\bigr| \;>\; \min\Bigl(\tbinom n2,\ p-1\Bigr) \qquad\text{or}\qquad \max_r|c_{S,T}(r)| \;\geq\; p .$$

*Sketch.* Let $d = \min(\binom n2, p-1)$. Theorem 8.2 gives $\pi^{d}\mid\det M$, which as in Theorem 8.5 yields $(X-1)^{d}\mid \bar F$ over $\mathbb{F}_p$. If $\bar F \neq 0$, the sparse-multiplicity lemma (Theorem 3.1) applies (as $\deg\bar F < p$) and gives $\#\operatorname{supp}\bar F > d$; and $\operatorname{supp}\bar F \subseteq \operatorname{supp} c_{S,T}$. If $\bar F = 0$, every $c_{S,T}(r)$ is divisible by $p$, and Theorem 4.5 supplies a nonzero one. $\square$

Theorem 8.7 is a satisfying unification: the *same* sparse-multiplicity lemma that proves nonvanishing also, applied to the counter itself rather than to a hypothetical kernel vector, forces the counter to be spread out or tall.

---

## 9. Algorithms

Three computational tasks arise naturally.

**(A) Direct enumeration of the counter.** For small $n$, iterate over all $n!$ permutations, compute $E_\sigma$ in $O(n)$ arithmetic operations, and accumulate $\operatorname{sgn}(\sigma)$ into a table indexed by $\mathbb{Z}/m$. Cost $\Theta(n!\cdot n)$ time and $\Theta(m)$ space. This is the definitional algorithm and the ground truth for testing.

**(B) Permanent-free determinant evaluation over a cyclotomic ring.** Instead of enumerating permutations, compute the whole counter as a single determinant of a matrix over $\mathbb{Z}[X]/(X^p-1)$: form $M_{jk} = X^{\widehat{S(j)}\widehat{T(k)}\bmod p}$ and evaluate $\det M$ by fraction-free Gaussian elimination (Bareiss) in the *polynomial* ring, reducing exponents modulo $p$ at every step. Cost $O(n^3)$ ring operations, each $O(p\log p)$ by cyclic convolution; total $\tilde O(n^3 p)$, an exponential saving over (A). The output is the vector $\bigl(c_{S,T}(r)\bigr)_{r}$, up to the single relation $\sum_r c_{S,T}(r)=0$ coming from $X^p-1 = (X-1)\Phi_p$.

An alternative, numerically simpler route is to evaluate the *complex* determinant $\det(\omega^{S(j)T(k)})$ in $O(n^3)$ floating-point operations. This certifies nonvanishing but does not recover the individual integers $c_{S,T}(r)$.

**(C) Minimal-length witness search.** Given the counter, locate $r_{\max} = \arg\max_r|c_{S,T}(r)|$, then find the permutation of least Coxeter length in the fibre over $r_{\max}$. Brute force costs $\Theta(n!\,n\log n)$ (inversion counting by merge sort). A better approach for moderate $n$ is best-first search over the symmetric group in the weak Bruhat order: process permutations in nondecreasing length, generated by appending adjacent transpositions, and stop at the first one whose exponent is $r_{\max}$; this returns the minimal-length witness without exhausting the group.

**(D) Certifying closure over composite moduli.** To exhibit closure at width $n$ over $\mathbb{Z}/m$ with $m$ composite, one does not enumerate: apply the pigeonhole criterion. Choose the least prime factor $q$ of $m$, set $B = \langle q\rangle$, choose the rows $J$ among the multiples of $m/q$, and choose the columns so that their classes modulo $B$ number fewer than $|J|$. Verification is $O(n^2)$ arithmetic — checking hypotheses (1)–(3) of Theorem 6.5 — with no permutation enumeration at all. This is how widths as large as $m-2$ are certified.

---

## 10. Discussion

### 10.1 Where the difficulty lies

The proof of Theorem 4.4 is short, but each ingredient is load-bearing.

*Why not reduce mod $p$ directly?* Because, by Remark 8.3, the determinant is divisible by $p$ once $\binom n2 \geq p-1$. Any argument that only sees $\det M$ modulo $p$ is blind in the large-$n$ regime. The ramified prime $\pi$, with $p \sim \pi^{p-1}$, resolves $p$ into $p-1$ finer layers, and Proposition 2.7 lets us descend to the layer where information survives.

*Why does the collapse help?* Reduction at $\pi$ destroys all Fourier structure — every $\zeta^a$ becomes $1$ — but it converts *separation* into *multiplicity*. Before reduction we have $n$ distinct roots and $n$ terms, a perfectly balanced situation. After reduction we have one root of multiplicity $n$ and still $n$ terms, and *that* is out of balance in characteristic $p$ by Theorem 3.1. The proof is essentially an exchange of one resource (distinctness of roots) for another (multiplicity), across a map that is favourable for the exchange.

*Why is primality needed?* At two independent points. First, $\Phi_p$ is irreducible and $\zeta$ has order exactly $p$, so the $n$ evaluation points are distinct. Second, and more importantly, $\deg\bar f < p$ in Theorem 3.1: the exponents $\widehat{T(k)}$ live in $\{0,\dots,p-1\}$ precisely because $T$ takes values in $\mathbb{Z}/p$, and it is this bound that keeps differentiation from destroying terms. For composite $m$ the ring $\mathbb{Z}[X]/(X^m-1)$ has zero divisors, several primes above the factors of $m$, and no analogue of the total ramification — and indeed the theorem is false.

### 10.2 Relation to classical results

Chebotarev's theorem on roots of unity dates from the 1920s and has attracted many proofs, notably a resultant-based one and a short argument of Tao using a discriminant-like auxiliary polynomial. The route taken here is closest in spirit to the arguments that pass through $\mathbb{Z}[\zeta_p]/\pi$, but the finite-field input is isolated as the standalone sparse-multiplicity lemma, which does not mention roots of unity at all. That modularity is what makes the rigidity results of Section 8 come for free: the same lemma, applied to the counter polynomial rather than to a kernel vector, yields Theorem 8.7.

The equivalence with the additive uncertainty principle (Theorem 7.1) is due to Tao and is what carried Chebotarev's theorem into harmonic analysis and signal processing. The multiplicative bound (Corollary 7.2) is Donoho–Stark and holds over all cyclic groups; the additive strengthening is exactly the prime phenomenon.

### 10.3 The shape of the composite theory

Section 6 gives an unexpectedly complete picture on the composite side. For $m$ composite with least prime factor $q$, define
$$W(m) = \max\{\,n \geq 2 : \mathrm{GapCloses}(m,n)\,\}.$$
Then
$$m - q \;\leq\; W(m) \;\leq\; m-2 ,$$
with equality on the right for all even $m \geq 4$ (where $q=2$ makes the two bounds coincide). For odd composite $m$, say $m = 9$ (with $q=3$), the bracket is $6 \leq W(9) \leq 7$, and determining $W$ exactly for odd composites is open. It is tempting to conjecture $W(m) = m-q$ always, i.e. that the pigeonhole construction is optimal; deciding this requires a lower bound on minors of the DFT matrix of a composite cyclic group of size between $m-q+1$ and $m-2$, which is a genuinely new question about Fourier minors of non-cyclic-prime groups.

### 10.4 Interpretation as a probabilistic statement

There is a probabilistic reading that explains the placement of the result. Sample a uniformly random permutation $\sigma \in \mathfrak S_n$ and let $\epsilon = \operatorname{sgn}(\sigma) \in \{\pm1\}$ and $E = E_\sigma \in \mathbb{Z}/p$. Then $\mathbb{E}[\epsilon] = 0$, and the counter is $n!$ times the "signed law" of $E$:
$$c_{S,T}(r) = n!\cdot \mathbb{E}\bigl[\epsilon \cdot \mathbf 1\{E = r\}\bigr].$$
Conjecture A says that sign and exponent are **never** independent: one cannot have $\mathbb{E}[\epsilon \mid E = r] = 0$ for all $r$. Equivalently, the sign of a random permutation always leaks some information about its exponent, no matter which injective $S,T$ one uses. Theorem 8.5 quantifies the leak from the other side: in the rigid regime the leak is uniform modulo $p$ across all residues, so it is either everywhere or very large somewhere. Over composite moduli the leak can be made to vanish completely, and Section 6 shows exactly how wide a system one can build before it must reappear.

---

## 11. Future directions

The theorems above leave five sharp questions.

**1. Exact $\pi$-adic depth.** For every prime $p$, every $n \leq p$, and all injective $S,T$, is
$$v_\pi\bigl(\det(\zeta^{S(j)T(k)})\bigr) \;=\; \binom n2 \;?$$
The lower bound is Theorem 8.2 and finiteness is Theorem 4.4; the case $n=2$ is settled. The key insight is that in the multilinear Taylor expansion the *unique* minimal term is the one with orders $\{0,1,\dots,n-1\}$, with coefficient the bialternant
$$\frac{\prod_{i<j}(S(j)-S(i))(T(j)-T(i))}{\prod_{k<n}k!},$$
whose denominator is invertible mod $p$ exactly because $n \leq p$. So the whole obstruction is a single Vandermonde-versus-superfactorial computation, i.e. the determinant of the binomial matrix $\bigl(\binom{T(k)}{l}\bigr)_{k,l}$ — an entirely finite identity.

**2. Rigidity modulo $p^m$.** If $\binom n2 \geq m(p-1)$, is the counter constant modulo $p^m$, and is $\bigl\lfloor \binom n2 / (p-1)\bigr\rfloor$ the largest such $m$? The case $m=1$ is Theorem 8.5, whose consequence (Theorem 8.6) is the full-support-or-large-gap dichotomy. The general case needs a higher-order version of the transfer between divisibility by $\pi^{k}$ in $\mathbb{Z}[\zeta_p]$ and divisibility by $(X-1)^{k}$ over $\mathbb{Z}/p^m$.

**3. Exact maximal closure width for odd composite moduli.** Is $W(m) = m - q$ with $q$ the least prime factor, for every composite $m$? Equivalently, does the pigeonhole construction of Theorem 6.6 already achieve the optimum? The even case is settled (Theorem 6.8); the first open case is $m=9$.

**4. Effective lower bounds on $\max_r|c_{S,T}(r)|$.** Theorem 5.3 gives only $\geq 1$; Theorem 8.6 gives $\geq p$ in a degenerate branch. Is there a growing bound in $n$, e.g. $\max_r|c_{S,T}(r)| \gg n!/p$ for generic $S,T$? Equivalently, how large is the sup-norm of a DFT minor determinant's coefficient vector?

**5. Structure of the extremal witnesses.** Theorem 5.3 produces a minimal-Coxeter-length permutation realising the extremal residue. Is there a closed-form description of that permutation for structured $S,T$ (arithmetic or geometric progressions), and does its length grow like $\binom n2/2$, the average over $\mathfrak S_n$?
