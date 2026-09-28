# The Septic Frontier: Conductor Information for Affine Galois Groups in Prime Degree

**Aristotle** (Harmonic)

*September 2026*

---

## Abstract

We study how much information a prime's residue class carries about the splitting type of a polynomial modulo that prime. The splitting field of $x^7-3$ has Galois group the Frobenius group $F_{42}=\mathrm{AGL}(1,7)$. Under Chebotarev equidistribution the question becomes an exact finite problem about the cycle types of the $42$ affine permutations $x\mapsto ax+b$ of $\mathbb{Z}/7$. We prove that the mutual information between the splitting type $T$ and the residue $p \bmod 7$ equals $\tfrac13+\log_2 3$ bits. This is exactly the entropy of the order of a uniformly random element of the cyclic group $C_6$, the invariant that governs cyclic sextic fields. The total type entropy is $\tfrac{4}{21}+\tfrac67\log_2 3+\tfrac16\log_2 7$, so the residue mod $7$ explains about $95.1\%$ of it. We then prove the same law for every prime degree $q$: for $\mathrm{AGL}(1,q)$,
$$I(T;\,p \bmod q)=\mathcal T(q-1), \qquad H(T\mid p \bmod q)=\frac{q\log_2 q-(q-1)\log_2(q-1)}{q(q-1)}\le\frac{\log_2 q}{q-1},$$
where $\mathcal T(n)$ is the cyclic type entropy of $C_n$. For odd $q$ the signal is at least one bit, and the explained fraction is at least $1-\log_2 q/(q-1)$. Two further results explain why the signal is confined to multiples of $7$. First, residues coprime to the conductor carry zero information in the linearly disjoint (product) model. Second, every homomorphism from an affine group to an abelian group kills all translations, so cyclotomic data sees only the linear part $a$ of the Frobenius. In particular the ramified prime $3$ is not a signal modulus. Along the way we establish the chain rule and symmetry of counting mutual information, and a complete description of the cycle structure of affine maps over an arbitrary field. We confirm the predictions numerically by factoring $x^7-3$ modulo the $17{,}982$ unramified primes below $2\cdot 10^5$.

---

## 1. Introduction

Let $f\in\mathbb{Z}[x]$ be irreducible of degree $n$, with splitting field $L$ and Galois group $G=\mathrm{Gal}(L/\mathbb{Q})$ acting on the $n$ roots. For a prime $p$ unramified in $L$, the multiset of degrees of the irreducible factors of $f \bmod p$ is the **splitting type** of $f$ at $p$. By a classical theorem of Frobenius and Dedekind, it equals the cycle type of the Frobenius element $\mathrm{Frob}_p\in G$ as a permutation of the roots. Chebotarev's density theorem says that $\mathrm{Frob}_p$ is equidistributed in $G$ (on conjugacy classes, in natural density). So the statistics of splitting types are the statistics of cycle types of a uniformly random element of $G$.

This paper takes an information-theoretic view. We ask: *how many bits of information about the splitting type are carried by the residue $p\bmod m$?* Write $T$ for the splitting type and $R_m$ for the residue, both viewed as random variables in the Chebotarev model. The quantity of interest is the mutual information $I(T;R_m)$.

For fields with *cyclic* Galois group $C_n$ the answer is classical in spirit. The splitting type is determined by the order of the Frobenius, and when the field is cyclotomic-like, the Frobenius is determined by the residue modulo the conductor. So the entire type entropy is explained at the conductor. Call this entropy the **cyclic type entropy** $\mathcal T(n)$. For $n=6$ it equals $\tfrac13+\log_2 3$.

The present paper is about the first genuinely non-abelian step in prime degree, the polynomial $x^7-3$. Its Galois group is the Frobenius group $F_{42}=\mathrm{AGL}(1,7)$ of order $42$. Our main findings are:

1. **The framework extends.** The residue $p\bmod 7$ carries exactly $\mathcal T(6)=\tfrac13+\log_2 3\approx1.918$ bits about the septic splitting type. This is the degree-six cyclic invariant, with no correction term.
2. **Every prime degree.** For $\mathrm{AGL}(1,q)$ and any prime $q$, the conductor information is exactly $\mathcal T(q-1)$, and the unexplained residual has the closed form given in the abstract. The residual is at most $\log_2 q/(q-1)$ and in fact tends to $0$ like $(\log_2 q)/q^2$.
3. **Where the signal lives.** Only moduli divisible by the abelian conductor $7$ carry signal. Coprime moduli are flat, and abelian characters are blind to translations. As a result the second ramified prime, $3$, carries nothing.

Numerical experiments with actual primes agree with every prediction to within sampling error (Section 9).

### What is proved and what is assumed

The results of Sections 3–8 are exact statements about finite groups and entropies of uniform distributions, with complete proofs. The link to primes rests on two classical inputs that we use but do not re-prove:

- **(G)** the Galois group of $x^7-3$ over $\mathbb{Q}$ is $F_{42}$, acting on the roots $\zeta_7^j\sqrt[7]{3}$ by $j\mapsto aj+b$, and the linear part $a$ of $\mathrm{Frob}_p$ is $p\bmod 7$;
- **(C)** the Chebotarev density theorem.

The flatness statement at coprime moduli (Theorem 8.1) is proved in the product model $F_{42}\times(\mathbb{Z}/m)^\times$. That model is the Chebotarev model of the compositum $L\cdot\mathbb{Q}(\zeta_m)$ when the two fields are linearly disjoint over $\mathbb{Q}$. We do not derive the linear disjointness itself from field theory here.

---

## 2. Counting entropy on finite sample spaces

All probability spaces in this paper are finite sets carrying the uniform measure. This is exactly the shape of the Chebotarev model.

**Definition 2.1 (counting entropy).** Let $S$ be a non-empty finite set and $g:S\to B$ any function. For $x\in S$ let $[x]_g=\{y\in S: g(y)=g(x)\}$ be the fibre through $x$. The entropy of $g$ on $S$ is
$$H_S(g)=\frac{1}{|S|}\sum_{x\in S}\log_2\frac{|S|}{|[x]_g|}=-\sum_{v\in g(S)}\frac{|g^{-1}(v)|}{|S|}\log_2\frac{|g^{-1}(v)|}{|S|}.$$
This is the Shannon entropy of the push-forward of the uniform distribution. It depends only on the multiset of fibre sizes.

**Definition 2.2 (conditional entropy and mutual information).** For $g:S\to B$ and $k:S\to C$, let $S_c=k^{-1}(c)$ for $c\in k(S)$. Define
$$H_S(g\mid k)=\sum_{c\in k(S)}\frac{|S_c|}{|S|}\,H_{S_c}(g),\qquad I_S(g;k)=H_S(g)-H_S(g\mid k).$$

**Definition 2.3 (cyclic type entropy).** For $n\ge1$ and $i\in\mathbb{Z}/n$, let $\mathrm{ord}_n(i)=n/\gcd(i,n)$ be the additive order of $i$. Define
$$\mathcal T(n)=H_{\mathbb{Z}/n}(\mathrm{ord}_n).$$
This is the entropy of the order of a uniform element of $C_n$. Since $\mathrm{ord}_n^{-1}(d)$ has $\varphi(d)$ elements for each $d\mid n$,
$$\mathcal T(n)=\sum_{d\mid n}\frac{\varphi(d)}{n}\log_2\frac{n}{\varphi(d)}.$$
For example $\mathcal T(2)=1$, $\mathcal T(4)=\tfrac32$, and
$$\mathcal T(6)=\tfrac16\log_2 6+\tfrac16\log_2 6+\tfrac26\log_2 3+\tfrac26\log_2 3=\tfrac13+\log_2 3.$$

**Theorem 2.4 (chain rule).** For all $g,k$ on $S$,
$$H_S(g\mid k)=H_S(g,k)-H_S(k),$$
where $(g,k)$ denotes the map $x\mapsto(g(x),k(x))$. Consequently
$$I_S(g;k)=H_S(g)+H_S(k)-H_S(g,k),\qquad I_S(g;k)=I_S(k;g).$$

*Proof sketch.* Fix $c$ and $x\in S_c$. The $g$-fibre of $x$ inside $S_c$ is exactly the $(g,k)$-fibre of $x$ inside $S$. Hence
$$\frac{|S_c|}{|S|}H_{S_c}(g)=\frac{|S_c|\log_2|S_c|}{|S|}-\frac{1}{|S|}\sum_{x\in S_c}\log_2|[x]_{(g,k)}|.$$
Summing over $c$, the first terms give $\frac{1}{|S|}\sum_{x\in S}\log_2|[x]_k|$ (each $x$ contributes $\log_2|S_c|$ with $c = k(x)$). The second terms give $\frac{1}{|S|}\sum_x\log_2|[x]_{(g,k)}|$. Writing $H_S(h)=\log_2|S|-\frac1{|S|}\sum_x\log_2|[x]_h|$ gives the chain rule. Symmetry follows because swapping the coordinates of $(g,k)$ does not change any fibre. $\square$

We also use three standard facts. Entropy is non-negative, so $0\le I_S(g;k)\le H_S(g)$. Coarse-graining never increases entropy: $H_S(\psi\circ g)\le H_S(g)$. And if $S=S_1\times S_2$, $g$ depends only on the first coordinate and $k$ only on the second, then $I_S(g;k)=0$.

---

## 3. Cycle structure of affine maps over a field

Let $K$ be a field and, for $a,b\in K$, let $f_{a,b}(x)=ax+b$. When $K=\mathbb{Z}/q$ and $a\neq0$ these are the elements of $\mathrm{AGL}(1,q)$.

**Lemma 3.1 (conjugation to the linear part).** If $x_0$ is a fixed point of $f_{a,b}$, then $f_{a,b}^{\,k}(x)-x_0=a^k(x-x_0)$ for all $k\ge0$. If $a=1$, then $f_{1,b}^{\,k}(x)=x+kb$.

*Proof.* Induction on $k$, using $ax+b-x_0=a(x-x_0)$ when $ax_0+b=x_0$. $\square$

**Theorem 3.2 (affine dynamics).** Let $a\neq 1$.

1. $f_{a,b}$ has exactly one fixed point, $x_0=b/(1-a)$.
2. A point $x\neq x_0$ satisfies $f_{a,b}^{\,k}(x)=x$ if and only if $a^k=1$.
3. Every $x\neq x_0$ has exact period $\mathrm{ord}(a)$, the multiplicative order of $a$.

If instead $a=1$ and $b\neq0$, and $K$ has characteristic $q>0$, then $f_{1,b}$ has no fixed points and every point has exact period $q$.

*Proof sketch.* (1) is linear algebra. For (2), Lemma 3.1 gives $f^k(x)-x=(a^k-1)(x-x_0)$ once we subtract $x - x_0$ from both sides, and $x-x_0\ne0$. For (3), the set of periods of $x$ is exactly $\{k: \mathrm{ord}(a)\mid k\}$, so the minimal period divides $\mathrm{ord}(a)$ and is divisible by it. In the translation case $x+kb=x$ iff $kb=0$ iff $q\mid k$, since $b\ne0$. $\square$

So an affine permutation of a finite field $\mathbb{F}_q$ has one of exactly three cycle shapes:

| element | fixed points | non-trivial cycles |
|---|---|---|
| identity ($a=1,b=0$) | $q$ | none |
| translation ($a=1,b\neq0$) | $0$ | one $q$-cycle |
| $a\neq1$ | $1$ | $(q-1)/\mathrm{ord}(a)$ cycles of length $\mathrm{ord}(a)$ |

**Definition 3.3 (affine type label).** For $(a,b)\in\mathrm{AGL}(1,q)$ define
$$T(a,b)=\begin{cases}(q,1)& a=1,\ b=0,\\ (0,q)& a=1,\ b\ne0,\\ (1,\mathrm{ord}(a))& a\ne1.\end{cases}$$

**Corollary 3.4 (faithfulness).** For every $(a,b)\in\mathrm{AGL}(1,q)$ the first coordinate of $T(a,b)$ is the number of fixed points of $f_{a,b}$ on $\mathbb{Z}/q$. The second coordinate is the common length of every non-trivial cycle. Hence $T(a,b)$ determines the cycle type of $f_{a,b}$, and conversely.

By the Frobenius–Dedekind theorem, $T(\mathrm{Frob}_p)$ is the splitting type of $f \bmod p$ whenever $G=\mathrm{AGL}(1,q)$ acts on the roots in the affine way.

---

## 4. The septic model: $x^7-3$ and $F_{42}$

Let $\alpha=\sqrt[7]{3}$ and $\zeta=\zeta_7$. The splitting field $L=\mathbb{Q}(\alpha,\zeta)$ has degree $42$. Its automorphisms are $\sigma_{a,b}:\zeta\mapsto\zeta^a$, $\alpha\mapsto\zeta^b\alpha$, and $\sigma_{a,b}$ sends the root $\zeta^j\alpha$ to $\zeta^{aj+b}\alpha$. Under input (G), labelling the roots by $j\in\mathbb{Z}/7$ identifies $G$ with $F_{42}=\{(a,b): a\in(\mathbb{Z}/7)^\times, b\in\mathbb{Z}/7\}$. For $p\ne 3,7$ we have $\mathrm{Frob}_p=\sigma_{a,b}$ with $a\equiv p \pmod 7$. Let
$$S=F_{42},\qquad T=\text{type label (Definition 3.3 with }q=7),\qquad R(a,b)=a\ (=p\bmod 7).$$

The multiplicative orders in $(\mathbb{Z}/7)^\times$ are $\mathrm{ord}(1)=1$, $\mathrm{ord}(6)=2$, $\mathrm{ord}(2)=\mathrm{ord}(4)=3$ and $\mathrm{ord}(3)=\mathrm{ord}(5)=6$. The type classes are therefore:

| type $T$ | factorisation of $x^7-3\bmod p$ | condition | count in $F_{42}$ |
|---|---|---|---|
| $(7,1)$ | $1^7$ | $p\equiv1$, $3$ a 7th power mod $p$ | $1$ |
| $(0,7)$ | $7$ | $p\equiv1$, $3$ not a 7th power | $6$ |
| $(1,2)$ | $1\cdot2^3$ | $p\equiv6$ | $7$ |
| $(1,3)$ | $1\cdot3^2$ | $p\equiv2,4$ | $14$ |
| $(1,6)$ | $1\cdot6$ | $p\equiv3,5$ | $14$ |

**Theorem 4.1 (septic type entropy).**
$$H(T)=\frac{4}{21}+\frac67\log_2 3+\frac16\log_2 7\approx 2.01691 \text{ bits}.$$

*Proof.* The fibre sizes are $1,6,7,14,14$ out of $42$, so
$H(T)=\tfrac1{42}\log_2 42+\tfrac6{42}\log_2 7+\tfrac7{42}\log_2 6+\tfrac{28}{42}\log_2 3$.
Expanding $\log_2 42=1+\log_2 3+\log_2 7$ and $\log_2 6=1+\log_2 3$ and collecting terms gives the stated value: the constant is $\tfrac{1+7}{42}$, the coefficient of $\log_2 3$ is $\tfrac{1+7+28}{42}$, and the coefficient of $\log_2 7$ is $\tfrac{1+6}{42}$. $\square$

**Theorem 4.2 (massive signal at the conductor).**
$$I(T;\,p\bmod 7)=\frac13+\log_2 3\approx1.91830 \text{ bits}.$$

*Proof.* $R$ has six fibres of size $7$, so $H(R)=\log_2 6$. The joint label $(T,R)$ has fibres of sizes $1,6$ (inside $a=1$) and $7,7,7,7,7$ (one for each $a\ne1$). So
$$H(T,R)=\tfrac{1}{42}\log_2 42+\tfrac{6}{42}\log_2 7+\tfrac{35}{42}\log_2 6=\tfrac67+\tfrac67\log_2 3+\tfrac16\log_2 7.$$
By Theorem 2.4, $I=H(T)+H(R)-H(T,R)=\tfrac4{21}-\tfrac67+1+\log_2 3=\tfrac13+\log_2 3$. $\square$

**Corollary 4.3 (the framework extends).** $I(T_{x^7-3};\,p\bmod 7)=\mathcal T(6)$. The degree-seven conductor signal equals the degree-six cyclic type entropy exactly.

**Corollary 4.4 (residual and dominance).**
$$H(T\mid p\bmod 7)=\frac{7\log_2 7-6\log_2 6}{42}=\frac16\log_2 7-\frac17-\frac17\log_2 3\approx0.09861,$$
and $\tfrac{11}{6}<I(T;\,p\bmod7)\le H(T)$. The residue mod $7$ explains $I/H\approx95.11\%$ of the type entropy.

---

## 5. The conductor law in every prime degree

Now let $q$ be any prime, $S_q=\mathrm{AGL}(1,q)$ (of order $q(q-1)$), $T$ the label of Definition 3.3, and $R(a,b)=a$. When $G=\mathrm{AGL}(1,q)$ is the Galois group of $x^q-c$ (the generic case), $R$ is again the residue $p\bmod q$.

The proof rests on a general "split-invariance" principle.

**Lemma 5.1 (entropy gaps under identical splittings).** Let $g,g',h,h'$ be functions on a finite set $S$ and $P\subseteq S$. Suppose that:

- for $x\notin P$: $|[x]_g|=|[x]_{g'}|$ and $|[x]_h|=|[x]_{h'}|$;
- for $x\in P$: $|[x]_g|=|[x]_h|$ and $|[x]_{g'}|=|[x]_{h'}|$.

Then $H_S(g)-H_S(h)=H_S(g')-H_S(h')$.

*Proof.* Write $H_S(u)=\log_2|S|-\frac1{|S|}\sum_x\log_2|[x]_u|$ and split each sum over $P$ and its complement. Off $P$, the $g$-terms match the $g'$-terms and the $h$-terms match the $h'$-terms. On $P$, the $g$-terms match the $h$-terms and the $g'$-terms match the $h'$-terms. Rearranging gives the claim. $\square$

Entropy is also invariant under injective relabelling of the sample space: if $e:S\to S'$ is injective on $S$, then $H_{e(S)}(u)=H_S(u\circ e)$.

**Theorem 5.2 (conductor law).** For every prime $q$,
$$I_{S_q}(T;R)=H_{S_q}(\mathrm{ord}\circ R)=\mathcal T(q-1).$$

*Proof sketch.* *Step 1.* Apply Lemma 5.1 with $g=T$, $h=(T,R)$, $g'=\mathrm{ord}\circ R$, $h'=R$ and $P=\{a=1\}$.

- Off $P$, $T=(1,\mathrm{ord}(a))$ is a function of $\mathrm{ord}(a)$ alone and determines it. So $T$ and $\mathrm{ord}\circ R$ have identical fibres, and so do $(T,R)$ and $R$.
- On $P$, $T$ already forces $a=1$, so $[x]_T=[x]_{(T,R)}$. Also $\mathrm{ord}(a)=1$ iff $a=1$, so $[x]_{\mathrm{ord}\circ R}=[x]_R$.

Hence $H(T)-H(T,R)=H(\mathrm{ord}\circ R)-H(R)$, and by Theorem 2.4
$$I(T;R)=H(T)+H(R)-H(T,R)=H(\mathrm{ord}\circ R).$$

*Step 2.* Since $S_q=(\mathbb{Z}/q)^\times\times\mathbb{Z}/q$ and $\mathrm{ord}\circ R$ depends only on the first coordinate, $H_{S_q}(\mathrm{ord}\circ R)=H_{(\mathbb{Z}/q)^\times}(\mathrm{ord})$. Pick a generator $\gamma$ of the cyclic group $(\mathbb{Z}/q)^\times$. The map $i\mapsto\gamma^i$ is a bijection $\{0,\dots,q-2\}\to(\mathbb{Z}/q)^\times$ with $\mathrm{ord}(\gamma^i)=(q-1)/\gcd(i,q-1)=\mathrm{ord}_{q-1}(i)$. By relabelling invariance, $H(\mathrm{ord})=\mathcal T(q-1)$. $\square$

For $q=7$ this recovers Corollary 4.3. The table below gives the first few values; $\mathcal T(q-1)$ depends only on the divisor structure of $q-1$.

| $q$ | $H(T)$ | $\mathcal T(q-1)=I(T;R)$ | $H(T\mid R)$ | $I/H$ |
|---|---|---|---|---|
| 3 | 1.45915 | 1.00000 | 0.45915 | 0.6853 |
| 5 | 1.68048 | 1.50000 | 0.18048 | 0.8926 |
| 7 | 2.01691 | 1.91830 | 0.09861 | 0.9511 |
| 11 | 1.76588 | 1.72193 | 0.04395 | 0.9751 |
| 13 | 2.45090 | 2.41830 | 0.03260 | 0.9867 |
| 17 | 1.89517 | 1.87500 | 0.02017 | 0.9894 |
| 31 | 2.64708 | 2.64022 | 0.00685 | 0.9974 |
| 43 | 2.51376 | 2.50997 | 0.00379 | 0.9985 |

---

## 6. The universal residual

**Theorem 6.1 (residual law).** For every prime $q$,
$$H_{S_q}(T\mid R)=\frac{q\log_2 q-(q-1)\log_2(q-1)}{q(q-1)}.$$

*Proof sketch.* Condition on $a$. For $a\ne1$ the type is constant on the fibre $\{a\}\times\mathbb{Z}/q$, so it contributes $0$. The fibre $a=1$ has probability $\tfrac{1}{q-1}$. On it, $T$ takes the value $(q,1)$ once and $(0,q)$ in the other $q-1$ cases, a biased coin with entropy
$$h_q=\tfrac1q\log_2 q+\tfrac{q-1}{q}\log_2\tfrac{q}{q-1}=\log_2 q-\tfrac{q-1}{q}\log_2(q-1).$$
Multiplying by $\tfrac1{q-1}$ gives the formula. $\square$

**Corollary 6.2 (type entropy decomposition).**
$$H_{S_q}(T)=\mathcal T(q-1)+\frac{q\log_2 q-(q-1)\log_2(q-1)}{q(q-1)}.$$

**Corollary 6.3 (residual bound).** $H_{S_q}(T\mid R)\le \dfrac{\log_2 q}{q-1}$.

*Proof.* Drop the non-negative term $(q-1)\log_2(q-1)$ from the numerator. $\square$

The residual is the entropy of one question: *"given $p\equiv1 \pmod q$, does $f$ split completely or stay irreducible?"* That question is asked only a fraction $1/(q-1)$ of the time. For $q=7$ it is exactly whether $3$ is a seventh-power residue modulo $p$.

---

## 7. A one-bit floor and information completeness

**Theorem 7.1 (one-bit floor for even cyclic types).** For every $m\ge1$, $\mathcal T(2m)\ge1$.

*Proof sketch.* Consider the coarse-graining $\psi(d)=[d\mid m]$ of the order. In $C_{2m}$, $\mathrm{ord}_{2m}(i)\mid m$ iff $mi\equiv 0 \pmod{2m}$ iff $i$ is even. So $\psi\circ\mathrm{ord}_{2m}$ is the parity of $i$. That is a fair coin on $\{0,\dots,2m-1\}$ (two fibres of size $m$), with entropy exactly $1$. Coarse-graining does not increase entropy, so $\mathcal T(2m)=H(\mathrm{ord}_{2m})\ge H(\psi\circ\mathrm{ord}_{2m})=1$. $\square$

**Corollary 7.2.** For every odd prime $q$, $I_{S_q}(T;R)\ge1$.

**Theorem 7.3 (information completeness).** For every odd prime $q$,
$$1-\frac{\log_2 q}{q-1}\;\le\;\frac{I_{S_q}(T;R)}{H_{S_q}(T)}.$$

*Proof.* Write $H=I+\rho$ with $\rho=H(T\mid R)\ge0$. Then $I/H=1-\rho/H$. Now $H\ge I\ge1$ by Corollary 7.2, and $\rho\le\log_2 q/(q-1)$ by Corollary 6.3, so $\rho/H\le\log_2 q/(q-1)$. $\square$

Hence the fraction of splitting-type information explained by the single residue $p\bmod q$ tends to $1$ as $q\to\infty$. The true ratios in the table of Section 5 are well above the bound, since $\rho$ is in fact much smaller than its bound: $q\log_2 q-(q-1)\log_2(q-1)=\log_2 q+(q-1)\log_2\frac{q}{q-1}<\log_2 q+\log_2 e$, so $\rho<(\log_2 q+\log_2 e)/(q(q-1))$.

---

## 8. Where the signal lives: flatness and the abelian obstruction

### 8.1 Coprime moduli

Let $m$ be coprime to $7$. If $L=\mathbb{Q}(\sqrt[7]{3},\zeta_7)$ and $\mathbb{Q}(\zeta_m)$ are linearly disjoint, the Frobenius in the compositum is uniformly distributed on $F_{42}\times(\mathbb{Z}/m)^\times$. The splitting type depends only on the first factor and the residue $p\bmod m$ only on the second.

**Theorem 8.1 (flat at coprime moduli).** For any prime $q$ and any finite set $C$, on $S_q\times C$,
$$I\big(T\circ\pi_1;\ \pi_2\big)=0.$$
In particular, in the model $F_{42}\times(\mathbb{Z}/m)^\times$, the residue $p\bmod m$ carries zero information about the septic splitting type.

*Proof.* On a product with the uniform measure, functions of different coordinates are independent, and the joint entropy is the sum of the marginal entropies. Apply Theorem 2.4. $\square$

### 8.2 The abelian obstruction

For moduli sharing a factor with the discriminant, linear disjointness can fail. For $x^7-3$ the relevant example is $m=3$, since $3$ is ramified in $L$. The next theorem explains why no residue class can do better than $p\bmod 7$ anyway.

Let $K$ be a field. Write $t_c(x)=x+c$ and $s_a(x)=ax$ ($a\neq0$) as permutations of $K$, and let $[u,v]=uvu^{-1}v^{-1}$.

**Lemma 8.2 (translations are commutators).** For $a\ne0$ and $c\in K$,
$$t_{(a-1)c}=[s_a,\,t_c].$$

*Proof.* $s_a t_c s_a^{-1}=t_{ac}$, so $[s_a,t_c]=t_{ac}t_{-c}=t_{(a-1)c}$. $\square$

**Theorem 8.3 (abelian characters kill translations).** Let $H$ be a group of permutations of $K$ that contains every translation $t_c$ and some scaling $s_a$ with $a\ne0,1$. Then every homomorphism $\chi:H\to A$ into an abelian group satisfies $\chi(t_b)=1$ for every $b\in K$.

*Proof.* Put $c=b/(a-1)$. By Lemma 8.2, $t_b=[s_a,t_c]$ is a commutator in $H$, and $\chi$ of a commutator is trivial because $A$ is abelian. $\square$

*Interpretation.* The residue $p\bmod m$ is the Frobenius of $p$ in $\mathrm{Gal}(\mathbb{Q}(\zeta_m)/\mathbb{Q})\cong(\mathbb{Z}/m)^\times$, an abelian group. Its restriction to $L\cap\mathbb{Q}(\zeta_m)$ is therefore given by an abelian character of $F_{42}$. By Theorem 8.3 every such character factors through the linear part $a=p\bmod 7$. In fact the commutator subgroup of $F_{42}$ is the translation subgroup $C_7$, and $F_{42}^{\mathrm{ab}}\cong C_6=(\mathbb{Z}/7)^\times$. So the maximal abelian subextension of $L$ is $\mathbb{Q}(\zeta_7)$, of conductor $7$. The "conductor moduli" of $x^7-3$ are the multiples of the **abelian** conductor $7$, not the ramified primes. The prime $3$ divides the discriminant but contributes nothing.

---

## 9. Numerical confirmation

We factored $x^7-3$ modulo each of the $17{,}982$ primes $p<200{,}000$ with $p\ne3,7$. We used distinct-degree factorisation: repeatedly compute $\gcd\!\big(x^{p^d}-x,\ f\big)$ over $\mathbb{F}_p$. We then recorded the splitting type.

| type | observed | Chebotarev prediction |
|---|---|---|
| $(7,1)$ | 0.02347 | $1/42=0.02381$ |
| $(0,7)$ | 0.14236 | $6/42=0.14286$ |
| $(1,2)$ | 0.16656 | $7/42=0.16667$ |
| $(1,3)$ | 0.33311 | $14/42=0.33333$ |
| $(1,6)$ | 0.33450 | $14/42=0.33333$ |

The empirical type entropy is $2.01489$ (theory $2.01691$). The empirical mutual information with $p\bmod m$ is:

| $m$ | 2 | 3 | 4 | 5 | 6 | 7 | 11 | 13 | 14 | 21 | 35 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $I$ (bits) | 0.00009 | 0.00005 | 0.00010 | 0.00038 | 0.00013 | 1.91734 | 0.00088 | 0.00056 | 1.91734 | 1.91738 | 1.91758 |

There is signal exactly at $7\mid m$, at the predicted $1.918$ bits. The small positive values elsewhere are the usual upward bias of plug-in entropy estimates on finite samples. Note in particular that $m=3$ is flat.

---

## 10. Algorithms

**Algorithm A (exact affine channel).** Input: a prime $q$.
1. Enumerate $S_q=\{(a,b):1\le a<q,\ 0\le b<q\}$.
2. For each element, compute $T(a,b)$ via Definition 3.3; $\mathrm{ord}(a)$ is found by repeated multiplication.
3. Tabulate the fibre sizes of $T$, $R$ and $(T,R)$, and return $H(T)$, $I=H(T)+H(R)-H(T,R)$ and $H(T\mid R)=H(T)-I$.

This costs $O(q^2)$ label evaluations plus $O(q^2)$ for the orders if they are cached per $a$. Theorems 5.2 and 6.1 replace it with the closed form $O(\tau(q-1))$ evaluation of $\mathcal T(q-1)$ via $\sum_{d\mid q-1}\frac{\varphi(d)}{q-1}\log_2\frac{q-1}{\varphi(d)}$.

**Algorithm B (empirical splitting-type channel).** Input: a polynomial $f$ of degree $n$, a bound $X$, and moduli $m_1,\dots,m_r$.
1. For each unramified prime $p<X$, compute the factor degrees of $f\bmod p$ by distinct-degree factorisation. This uses $O(n)$ modular exponentiations $x\mapsto x^p \bmod (f,p)$, each costing $O(n^2\log p)$.
2. Map the degree pattern to a type label.
3. For each $m_i$, compute the plug-in mutual information of the pairs $(T_p,\,p\bmod m_i)$.

---

## 11. Discussion

**Why the cyclic invariant reappears.** Theorem 5.2 says that the residue channel of $\mathrm{AGL}(1,q)$ is, informationally, *exactly* the cyclic type channel of its abelianization $C_{q-1}$. Off the identity fibre of the linear part, the type is literally the order of $a$. On that fibre the type and the linear part split the mass in the same way, so the correction cancels (Lemma 5.1). Nothing specific to $7$ is used beyond the cyclicity of $(\mathbb{Z}/q)^\times$.

**Conductor versus ramification.** A common heuristic says to look for signal at the ramified primes. Theorem 8.3 corrects it. Residue data is abelian, so it can only see $G^{\mathrm{ab}}$, and the relevant modulus is the conductor of the maximal abelian subfield. For $x^7-3$ the ramified primes are $3$ and $7$, but the abelian conductor is $7$.

**Limitations.** The number-theoretic inputs (G) and (C) are classical but are used, not re-derived. The flatness theorem is stated in the product model, which requires linear disjointness. All information-theoretic statements are exact in the Chebotarev limit; for finite prime ranges they hold up to sampling error, as Section 9 illustrates.

---

## 12. Future directions

1. **Abelianization law.** Conjecture: for any Galois group $G\le S_n$ with type map $T$, in the Chebotarev model $\sup_m I(T;\,p\bmod m)=I(T;\,\mathrm{ab})$, where $\mathrm{ab}:G\to G^{\mathrm{ab}}$. In particular the signal vanishes at every modulus for perfect $G$. A sharp test in degree seven is $\mathrm{PSL}(2,7)$, e.g. for $x^7-7x+3$.
2. **Sub-Frobenius groups $C_q\rtimes C_d$.** For $d\mid q-1$ and $G_d=\{x\mapsto ax+b: a^d=1\}$, conjecture $I(T;\,a)=\mathcal T(d)$, with residual $\frac{q\log_2 q-(q-1)\log_2(q-1)}{q\,d}$. The split-invariance proof should carry over with a generator of $\mu_d$ in place of a primitive root.
3. **Sharp completeness rate.** Determine the exact asymptotics of $1-I/H$, in terms of the residual (of order $(\log_2 q)/q^2$) and the mean behaviour of $\mathcal T(q-1)$ over primes $q$.
4. **Field-theoretic flatness.** Derive the coprime-flatness theorem directly from linear disjointness of $L$ and $\mathbb{Q}(\zeta_m)$, and treat the non-disjoint moduli in full.

---

## 13. Conclusion

For $x^7-3$, knowing a prime modulo $7$ determines its splitting type except for a single biased coin, and the information it carries, $\tfrac13+\log_2 3$ bits, is precisely the cyclic type entropy of degree six. The same holds in every prime degree: the conductor signal of $\mathrm{AGL}(1,q)$ equals $\mathcal T(q-1)$, the residual is explicit and at most $\log_2 q/(q-1)$, and abelian data is structurally blind to the translation part of the Frobenius. The type-channel framework therefore extends past degree six to degree seven and beyond.
