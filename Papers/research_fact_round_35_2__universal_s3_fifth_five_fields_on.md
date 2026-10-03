# Five Fields, One Law: An Exact Information-Theoretic Law for Splitting Types at the Conductor, with the Cubic $x^3-4x+1$ of Discriminant $229$

**Aristotle**

*October 2026*

---

## Abstract

For a prime $p$ and a monic integer cubic $f$, the *splitting type* of $p$ records how $f$ factors modulo $p$. Experiments on five independent $S_3$ cubic fields found that the residue class of $p$ modulo the conductor $D$ of the quadratic resolvent carries, as measured by Shannon mutual information, about one bit about the splitting type. The most recent of these fields comes from $f = x^3 - 4x + 1$, with $D = 229$, where the plug-in estimate was $1.0078$ bits. This paper explains that observation with an exact theorem. In the *Chebotarev fibre-product model*, a Frobenius element uniform on a finite group $G$ and a residue class uniform on a finite group $R$ are coupled only through a common quotient $\Delta$ with balanced fibres. In this model, any read-out $\tau$ of the Frobenius element that determines its image in $\Delta$ has mutual information with the residue class equal to exactly $\log_2|\Delta|$. For every symmetric group $S_n$ with $n\ge 2$, and every residue group carrying a surjective quadratic character, this value is exactly one bit. For $S_3$ the bit splits as $H(T)=\tfrac23+\tfrac12\log_2 3$ and $H(T\mid \text{class}) = \tfrac12\log_2 3-\tfrac13$. On the arithmetic side we prove, by elementary means, that for every prime $p\notin\{2,229\}$ the cubic $x^3-4x+1$ has exactly one root modulo $p$ if and only if $\left(\frac{p}{229}\right)=-1$, and that its root count modulo $p$ is never $2$. The proof is an explicit Frobenius computation (Stickelberger's phenomenon) followed by quadratic reciprocity. We also prove that $f$ is irreducible over $\mathbb Q$, that its discriminant is not a rational square, and that it has three real roots. So $f$ defines a totally real cubic field with Galois group $S_3$, and its sign character is the Legendre symbol modulo $229$. Together these results identify the "five fields" phenomenon as five instances of one formula. They also show that the observed excess above one bit is finite-sample bias, not signal.

---

## 1. Introduction

### 1.1 The observation

Let $f(x) = x^3 - 4x + 1$. For each prime $p$, let $T(p)\in\{0,1,3\}$ be the number of roots of $f$ in $\mathbb F_p$. We will show that the value $2$ never occurs for $p\neq 229$. Write $c(p) = p \bmod 229$ for the residue class of $p$ modulo the discriminant
$$\operatorname{disc}(f) = -4(-4)^3 - 27\cdot 1^2 = 229,$$
which is prime. An empirical study computed the plug-in mutual information $\hat I(c;T)$ over an initial segment of primes and found $\hat I \approx 1.0078$ bits. This was very far from the value $0$ expected if $c$ and $T$ were independent; a permutation test gave $z\approx +263$. Four earlier, independent $S_3$ cubics with different discriminants had given values equally close to $1$.

This paper answers three questions. Why exactly one bit? Why for every field? And what is the extra $0.0078$?

### 1.2 Summary of results

1. **The Fibre-Product Law (Theorem 3.1).** In a uniform fibre product $G\times_\Delta R$ with balanced fibres, any read-out of the $G$-coordinate that determines its image in $\Delta$ has mutual information with the $R$-coordinate exactly $\log_2|\Delta|$.
2. **The Universal Symmetric-Group Law (Theorem 4.1).** For every $n\ge 2$, the cycle-type channel of $S_n\times_{\{\pm1\}}R$ carries exactly one bit. For $S_3$ the root-count channel carries exactly one bit (Theorem 4.3), with entropy split $H(T)=\tfrac23+\tfrac12\log_2 3$ and $H(T\mid c)=\tfrac12\log_2 3-\tfrac13$ (Proposition 4.4). This holds for every odd prime conductor (Theorem 4.6), in particular $229$.
3. **The Splitting-Type Law for $x^3-4x+1$ (Theorems 5.9 and 5.10).** For primes $p\notin\{2,229\}$, $f$ has exactly one root mod $p$ $\iff$ $229$ is a non-square mod $p$ $\iff$ $\left(\frac{p}{229}\right)=-1$. Equivalently, the sign read off the root count equals the Legendre symbol $\left(\frac p{229}\right)$ (Corollary 5.11).
4. **Fine structure (Propositions 5.12–5.14).** The root count is never $2$. On the residue side the type is $1+1+1$ or $3$. The primes $3$ and $461$ lie in the same class modulo $229$ but have different types, so $H(T\mid c)>0$ is actually realised.
5. **The field (Proposition 5.15).** $f$ is irreducible over $\mathbb Q$, $229$ is not a rational square, and $f$ has three real roots, in $(-3,-2)$, $(0,1)$ and $(1,2)$.

### 1.3 Organisation

Section 2 sets up counting entropies and the fibre product. Section 3 proves the general law. Section 4 specialises it to symmetric groups and prime conductors. Section 5 carries out the arithmetic of $x^3-4x+1$. Section 6 connects the model with the arithmetic. Section 7 describes the algorithms used for the numerical illustrations in Section 8. Section 9 discusses finite-sample bias and generalisations, and Section 10 lists open problems.

---

## 2. Definitions

Throughout, $\log_2$ is the base-2 logarithm. All probability spaces are finite sets carrying the uniform distribution.

**Definition 2.1 (Counting entropy).** Let $s$ be a finite nonempty set and $X: s\to \mathcal X$ a function. For $x\in\mathcal X$ write $n_x = \#\{\omega\in s : X(\omega)=x\}$ and $N = \#s$. The *entropy* of $X$ on $s$ is
$$H_s(X) = \sum_{x} \frac{n_x}{N}\log_2\frac{N}{n_x} = \log_2 N - \frac1N\sum_x n_x\log_2 n_x .$$
This is the Shannon entropy of $X$ under the uniform law on $s$.

**Definition 2.2 (Conditional entropy, mutual information).** For $X: s\to\mathcal X$ and $Y: s\to\mathcal Y$, the *conditional entropy* is $H_s(X\mid Y) = H_s(X,Y)-H_s(Y)$, and the *mutual information* is
$$I_s(X;Y) = H_s(X) - H_s(X\mid Y) = \sum_{x,y}\frac{n_{x,y}}{N}\log_2\frac{N\,n_{x,y}}{n_x\, m_y},$$
where $n_{x,y} = \#\{X=x, Y=y\}$ and $m_y = \#\{Y=y\}$. Terms with $n_{x,y}=0$ are omitted.

The double-sum (Kullback–Leibler) form of $I$ is the one we will use.

**Definition 2.3 (Fibre product).** Let $G, R$ be finite sets, $\Delta$ a set, and $\varepsilon: G\to\Delta$, $\chi: R\to\Delta$ functions. The *fibre product* is
$$G\times_\Delta R = \{(\sigma,r)\in G\times R : \varepsilon(\sigma)=\chi(r)\}.$$
We say $\varepsilon$ is *balanced with fibre size $A>0$* if $\#\varepsilon^{-1}(d) = A$ for every $d\in\Delta$, and similarly for $\chi$ with fibre size $B>0$.

**Definition 2.4 (Read-out determining the quotient).** A function $\tau: G\to\beta$ *determines* $\varepsilon$ if there is $e:\beta\to\Delta$ with $\varepsilon = e\circ\tau$.

**Interpretation (the Chebotarev fibre-product model).** Let $K/\mathbb Q$ be a Galois extension with group $G$. Suppose its maximal abelian subextension, or a chosen abelian subextension with group $\Delta$, lies in the cyclotomic field $\mathbb Q(\zeta_D)$. Then the restriction of the Frobenius element $\operatorname{Frob}_p\in G$ to that subfield is $\chi(p \bmod D)$, where $\chi: (\mathbb Z/D)^\times\to\Delta$ is the Artin map. Chebotarev's density theorem, together with Dirichlet's theorem on primes in progressions, implies that the pair $(\operatorname{Frob}_p,\ p\bmod D)$ is asymptotically equidistributed on $G\times_\Delta(\mathbb Z/D)^\times$. For an $S_3$ cubic field with quadratic resolvent of prime conductor $\ell$, we have $\Delta=\{\pm1\}$, $\varepsilon=\operatorname{sign}$ and $\chi = \left(\frac{\cdot}{\ell}\right)$. The *type channel* is the pair (splitting type, residue class) under this law. Everything in Sections 3–4 is a statement about this finite model. Section 5 establishes, for $x^3-4x+1$, the arithmetic coupling the model needs.

---

## 3. The Fibre-Product Law

**Theorem 3.1 (Fibre-Product Law).** Let $\varepsilon: G\to\Delta$ and $\chi: R\to\Delta$ be balanced, with fibre sizes $A>0$ and $B>0$, where $\Delta$ is finite. Let $\tau: G\to\beta$ be any function that determines $\varepsilon$. On the uniform fibre product $s = G\times_\Delta R$,
$$I_s\big(\tau(\sigma);\ r\big) = \log_2|\Delta| .$$
The value does not depend on $G$, $R$, $\tau$, $A$ or $B$.

*Proof sketch.* If $\Delta=\varnothing$, then $s=\varnothing$ and both sides are $0$ by convention. Otherwise count four quantities. Write $a_v = \#\tau^{-1}(v)\subseteq G$.

* Total: $N = \#s = \sum_{\sigma\in G}\#\chi^{-1}(\varepsilon(\sigma)) = |G|\,B = |\Delta|\,A\,B$.
* Residue marginal: $M_c = \#\{(\sigma,c)\in s\} = \#\varepsilon^{-1}(\chi(c)) = A$.
* Type marginal: $m_v = \#\{(\sigma,r)\in s:\tau(\sigma)=v\} = \sum_{\tau(\sigma)=v}\#\chi^{-1}(\varepsilon(\sigma)) = a_v B$.
* Joint: $n_{c,v} = \#\{\sigma : \varepsilon(\sigma)=\chi(c),\ \tau(\sigma)=v\}$. If this is nonzero, pick a $\sigma_0$ in it. Then $e(v) = e(\tau(\sigma_0)) = \varepsilon(\sigma_0) = \chi(c)$. So for *every* $\sigma$ with $\tau(\sigma)=v$ we get $\varepsilon(\sigma) = e(v) = \chi(c)$, and hence $n_{c,v} = a_v$.

So every nonzero term of the Kullback–Leibler sum has the same logarithm:
$$\log_2\frac{N\,n_{c,v}}{m_v\,M_c} = \log_2\frac{|\Delta| A B\cdot a_v}{a_v B\cdot A} = \log_2|\Delta| .$$
Since $\sum_{c,v} n_{c,v} = N$, we get $I = \sum_{c,v}\frac{n_{c,v}}N\log_2|\Delta| = \log_2|\Delta|$. $\square$

**Proposition 3.2 (Marginal invariance).** If $\chi$ is balanced with fibre size $B>0$, then for every $\tau: G\to\beta$ the entropy of $\tau(\sigma)$ on $G\times_\Delta R$ equals the entropy of $\tau$ on $G$ under the uniform law:
$$H_{G\times_\Delta R}(\tau\circ\mathrm{pr}_1) = H_G(\tau).$$

*Proof sketch.* With the counts above, $m_v/N = a_vB/(|G|B) = a_v/|G|$. So the two distributions of $\tau$ are identical. The images also agree: every $\sigma$ has a partner $r$, since the fibres of $\chi$ are nonempty. $\square$

Thus the fibre product leaves the Chebotarev distribution of types unchanged. Coupling to the residue class does not distort the type statistics.

**Corollary 3.3 (Group form).** Let $G, R, H$ be finite groups and $\varepsilon: G\to H$, $\chi: R\to H$ surjective homomorphisms. If $\tau$ determines $\varepsilon$, then $I(\tau;r) = \log_2|H|$ on $G\times_H R$.

*Proof.* A surjective homomorphism is balanced: every fibre is a coset of the kernel, with size $|\ker|$, which is positive. Apply Theorem 3.1. $\square$

**Corollary 3.4 (Trivial quotient).** If $H$ is trivial, the channel carries $0$ bits. Here the fibre product is the full product $G\times R$, and $\tau$ and $r$ are independent.

---

## 4. Symmetric Groups and Prime Conductors

For a permutation $\sigma\in S_n$ with cycle type $\lambda=(\lambda_1,\dots,\lambda_k)$ (a partition of $n$), the sign is $\operatorname{sign}(\sigma) = (-1)^{\sum_i(\lambda_i - 1)} = (-1)^{n+k}$. So the cycle type determines the sign.

**Theorem 4.1 (Universal Symmetric-Group Law).** Let $n\ge 2$ and let $R$ be a finite group with a surjective homomorphism $\chi: R\to\{\pm 1\}$. On the fibre product $\{(\sigma,r)\in S_n\times R:\operatorname{sign}\sigma = \chi(r)\}$ the mutual information between the cycle type of $\sigma$ and $r$ is exactly $1$ bit.

*Proof.* For $n\ge 2$, $\operatorname{sign}: S_n\to\{\pm1\}$ is surjective, and the cycle type determines it via $\lambda\mapsto(-1)^{|\lambda|+\ell(\lambda)}$. Corollary 3.3 gives $\log_2 2 = 1$. $\square$

For a cubic, what one observes is the *root count*: the number of fixed points of $\operatorname{Frob}_p$ acting on the three roots.

**Lemma 4.2.** For $\sigma\in S_3$ let $\operatorname{fix}(\sigma)$ be its number of fixed points. Define $\rho(k) = -1$ if $k=1$ and $\rho(k)=+1$ otherwise. Then $\rho(\operatorname{fix}\sigma) = \operatorname{sign}\sigma$ for all $\sigma\in S_3$.

*Proof.* The identity has $3$ fixed points and sign $+1$. The three transpositions have $1$ fixed point and sign $-1$. The two $3$-cycles have $0$ fixed points and sign $+1$. $\square$

**Theorem 4.3 ($S_3$ root-count law).** For every finite group $R$ with a surjective $\chi: R\to\{\pm1\}$, the root-count channel of $S_3\times_{\{\pm1\}}R$ carries exactly $1$ bit.

*Proof.* Combine Lemma 4.2 with Corollary 3.3. $\square$

**Proposition 4.4 (Entropy split).** Under the uniform law on $S_3$, the root count $T=\operatorname{fix}(\sigma)$ takes the values $3,1,0$ with probabilities $\tfrac16,\tfrac12,\tfrac13$, and
$$H(T) = \tfrac16\log_2 6 + \tfrac12\log_2 2+\tfrac13\log_2 3 = \tfrac23 + \tfrac12\log_2 3\approx 1.4591 .$$
On any fibre product as in Theorem 4.3,
$$H(T\mid r) = \tfrac12\log_2 3 - \tfrac13 \approx 0.4591 .$$

*Proof.* The first formula is direct, using $\log_2 6 = 1+\log_2 3$. By Proposition 3.2, $H(T)$ on the fibre product equals $H(T)$ on $S_3$. Then $H(T\mid r) = H(T)-I(T;r) = \tfrac23+\tfrac12\log_23 - 1$. $\square$

*Remark 4.5.* The conditional entropy has a direct interpretation. On the non-residue half ($\chi(r)=-1$) the type is "one root" with certainty, so the contribution is $0$. On the residue half the type is "three roots" or "no root" with probabilities $\tfrac13,\tfrac23$, contributing the binary entropy $h(\tfrac13)=\log_23-\tfrac23$. Averaging gives $\tfrac12 h(\tfrac13) = \tfrac12\log_2 3-\tfrac13$. *The bit is exactly the sign bit.*

**Theorem 4.6 (Prime-conductor form).** Let $\ell$ be an odd prime and $\chi_\ell: (\mathbb Z/\ell)^\times\to\{\pm1\}$ the Legendre symbol. On $S_3\times_{\{\pm1\}}(\mathbb Z/\ell)^\times$, coupled by $\operatorname{sign}\sigma = \left(\frac r\ell\right)$, the root-count channel carries exactly $1$ bit. In particular this holds for $\ell = 229$.

*Proof.* The quadratic character of $\mathbb F_\ell^\times$ is a homomorphism to $\{\pm1\}$. It is surjective because $\mathbb F_\ell$ has a non-square when $\ell$ is odd. Apply Theorem 4.3. $\square$

---

## 5. The Cubic $x^3-4x+1$

Write $f(x) = x^3-4x+1$ over an arbitrary commutative ring.

### 5.1 The discriminant identity

**Lemma 5.1 (Two-root relations).** In an integral domain, if $r\ne s$ are roots of $f$, then
$$r^2+rs+s^2 = 4,\qquad rs(r+s) = 1 .$$

*Proof.* $f(r)-f(s) = (r-s)(r^2+rs+s^2-4)$. Cancel $r-s\ne 0$. Then $rs(r+s) = r(r^2+rs+s^2) - r^3 = 4r - r^3 = 1$. $\square$

**Lemma 5.2 (Third root).** Under the same hypotheses, $-(r+s)$ is also a root.

*Proof.* Expanding gives $f(-(r+s)) = -(r+s)(r^2+rs+s^2-4) - (rs(r+s)-1)$, and both brackets vanish by Lemma 5.1. $\square$

**Theorem 5.3 (Discriminant $229$).** In an integral domain, if $r\neq s$ are roots of $f$, then with $\delta = (r-s)(r+2s)(2r+s)$,
$$\delta^2 = 229 .$$

*Proof.* The polynomial identity
$$\big((r-s)(r+2s)(2r+s)\big)^2 = 4(r^2+rs+s^2)^3 - 27\big(rs(r+s)\big)^2$$
holds in any commutative ring. Substituting Lemma 5.1 gives $4\cdot 64-27 = 229$. $\square$

Note that $\delta$ is, up to sign, the Vandermonde product of the three roots $r$, $s$, $t=-(r+s)$, because $r - t = 2r+s$ and $s-t = r+2s$.

**Corollary 5.4.** If $229$ is not a square in an integral domain $K$, then $f$ has at most one root in $K$.

**Lemma 5.5 (Residual discriminant).** In any commutative ring, if $f(r) = 0$, then
$$(16-3r^2)(3r^2-4)^2 = 229 .$$

*Proof.* The difference of the two sides is $(-27r^3+108r+27)\,f(r)$. $\square$

Here $16-3r^2$ is the discriminant of the quadratic cofactor $f(x)/(x-r) = x^2+rx+(r^2-4)$, and $3r^2-4 = f'(r)$. The lemma is the identity $\operatorname{disc}(f) = \operatorname{disc}(f/(x-r))\cdot f'(r)^2$.

### 5.2 Frobenius and Stickelberger

**Lemma 5.6 (Fixed points of Frobenius).** Let $L$ be a field containing $\mathbb F_p$. If $x\in L$ satisfies $x^p = x$, then $x\in\mathbb F_p$.

*Proof.* The $p$ elements of $\mathbb F_p$ are roots of $X^p - X$, which has degree $p$ and hence at most $p$ roots in $L$. So they are all of its roots. $\square$

**Theorem 5.7 (Stickelberger for $f$).** Let $p$ be a prime. If $f$ has no root in $\mathbb F_p$, then $229$ is a square in $\mathbb F_p$.

*Proof sketch.* A cubic with no root is irreducible, so $L = \mathbb F_p[x]/(f)$ is a field, with a root $\alpha$. The Frobenius map $y\mapsto y^p$ is a ring homomorphism of $L$, so it sends roots of $f$ to roots. By Lemma 5.6 and the hypothesis, it fixes no root. Let $\beta = \alpha^p\ne\alpha$ and $\theta = -(\alpha+\beta)$, a third root by Lemma 5.2. Lemma 5.1 shows that every root of $f$ in $L$ is one of $\alpha,\beta,\theta$: if $y\neq\alpha$ is a root, then $(y-\beta)(y-\theta) = (y^2+y\alpha+\alpha^2)-(\beta^2+\beta\alpha+\alpha^2) = 0$. Now $\beta^p$ is a root. It is not $\beta$, since no root is fixed. It is not $\alpha$ either, for otherwise $\theta^p = -(\alpha^p+\beta^p) = -(\beta+\alpha) = \theta$ would be fixed. So $\beta^p = \theta$, and Frobenius acts as the $3$-cycle $\alpha\mapsto\beta\mapsto\theta\mapsto\alpha$. Applying it to $\delta = (\alpha-\beta)(\alpha+2\beta)(2\alpha+\beta)$ gives
$$\delta^p = (\beta-\theta)(\beta+2\theta)(2\beta+\theta) = (\alpha+2\beta)\cdot(-(2\alpha+\beta))\cdot(\beta-\alpha) = \delta .$$
By Lemma 5.6, $\delta\in\mathbb F_p$, and by Theorem 5.3, $\delta^2 = 229$. $\square$

This is the concrete content of the principle that "Frobenius is even exactly when the discriminant is a square". An even fixed-point-free permutation of three letters preserves the Vandermonde product.

### 5.3 One root plus a square discriminant

**Lemma 5.8 (Second root).** Let $K$ be a field with $2\ne0$ and $229\neq 0$. If $f(r)=0$ and $229$ is a square in $K$, then $f$ has a root $s\neq r$.

*Proof sketch.* Write $229 = d^2$. By Lemma 5.5, $w = 3r^2-4\neq 0$ (otherwise $229=0$). Put $e = d/w$, so $e^2 = 16-3r^2$, and $e\neq0$. Any $s$ with $(2s+r)^2 = e^2$ satisfies $4(s^2+rs+r^2-4) = 0$, so $f(s) = f(s)-f(r) = (s-r)(s^2+rs+r^2-4) = 0$. The two values $s_\pm = (-r\pm e)/2$ are distinct because $e\ne 0$, so at least one of them differs from $r$. $\square$

### 5.4 The splitting-type law

**Theorem 5.9 (Splitting-type law, discriminant form).** Let $p\notin\{2,229\}$ be prime. Then $f$ has exactly one root in $\mathbb F_p$ if and only if $229$ is a non-square in $\mathbb F_p$.

*Proof.* ($\Rightarrow$) If $f$ had a unique root $r$ and $229$ were a square, Lemma 5.8 would give a second root. ($\Leftarrow$) If $229$ is a non-square, Theorem 5.7 shows that $f$ has a root, and Corollary 5.4 shows it is unique. $\square$

**Theorem 5.10 (Splitting-type law, conductor form).** Let $p\notin\{2,229\}$ be prime. Then $f$ has exactly one root modulo $p$ if and only if $p$ is a quadratic non-residue modulo $229$.

*Proof.* Since $229\equiv 1\pmod 4$, quadratic reciprocity gives $\left(\frac{229}{p}\right) = \left(\frac{p}{229}\right)$ for every odd prime $p\neq 229$. Combine this with Theorem 5.9. $\square$

**Corollary 5.11 (Type–sign coupling).** For primes $p\notin\{2,229\}$,
$$\begin{cases}-1 & \text{if } f \text{ has exactly one root mod } p\\ +1 & \text{otherwise}\end{cases} \;=\; \left(\frac{p}{229}\right).$$
The left side is $\rho(T(p))$ with $\rho$ as in Lemma 4.2, that is, the sign of $\operatorname{Frob}_p$. So the arithmetic coupling between Frobenius and residue class is exactly the coupling $\operatorname{sign}\sigma = \chi_{229}(r)$ of the fibre-product model.

### 5.5 Fine structure

**Proposition 5.12 (No type with exactly two roots).** In an integral domain with $229\ne0$, if $r\ne s$ are roots of $f$, then the third root $-(r+s)$ differs from both. Hence for $p\neq 229$ the number of roots of $f$ modulo $p$ is never $2$.

*Proof.* If $-(r+s) = r$, then $2r+s = 0$, so $\delta = 0$, contradicting $\delta^2 = 229 \ne 0$. The case $-(r+s)=s$ is the same with $r+2s=0$. $\square$

**Proposition 5.13 (Residue branch).** Let $p\notin\{2,229\}$. If $229$ is a square mod $p$ (equivalently, $p$ is a residue mod $229$) and $f$ has a root mod $p$, then $f$ has three pairwise distinct roots mod $p$. So on the residue side the type is $1+1+1$ (complete splitting) or $3$ (inert).

*Proof.* Lemma 5.8 gives a second root, and Proposition 5.12 gives a distinct third. $\square$

**Proposition 5.14 (Same class, different type).** $461\equiv 3\pmod{229}$. The cubic $f$ has no root modulo $3$ (indeed $f(0)\equiv f(1)\equiv f(2)\equiv 1$), while modulo $461$ it has the three distinct roots $162$, $368$, $392$.

So the residue class does not determine the type, and the conditional entropy $H(T\mid c)$ is really positive, consistent with Proposition 4.4.

### 5.6 The field over $\mathbb Q$ and $\mathbb R$

**Proposition 5.15.**
(a) $f$ has no rational root, and is therefore irreducible over $\mathbb Q$.
(b) $229$ is not the square of a rational number, so the Galois group of $f$ over $\mathbb Q$ is $S_3$.
(c) $f$ has three real roots, one in each of $(-3,-2)$, $(0,1)$ and $(1,2)$, so the cubic field is totally real.

*Proof sketch.* (a) Write a root as $a/b$ in lowest terms. Then $a^3-4ab^2+b^3 = 0$. Reducing modulo $3$ and checking the nine pairs $(a,b)\in\mathbb F_3^2$ shows $a\equiv b\equiv0\pmod 3$, contradicting $\gcd(a,b)=1$. A cubic with no root in a field is irreducible. (b) A rational square that is an integer is an integer square, and $15^2 = 225 < 229 < 256 = 16^2$. An irreducible cubic whose discriminant is not a square has Galois group $S_3$. (c) $f(-3) = -14<0<1 = f(-2)$, $f(0) = 1>0>-2 = f(1)$, and $f(1) = -2<0<1 = f(2)$. Apply the intermediate value theorem. $\square$

Numerically the roots are $-2.11491$, $0.25410$ and $1.86081$.

---

## 6. Synthesis: Five Fields, One Law

The pieces fit together as follows.

* Proposition 5.15 shows that $K=\mathbb Q(\text{roots of } f)$ is an $S_3$ extension. Its quadratic subfield is $\mathbb Q(\sqrt{229})$, which has prime conductor $229$ because $229\equiv1\pmod4$.
* Corollary 5.11 shows that the sign of $\operatorname{Frob}_p$, read off the root count, is $\left(\frac{p}{229}\right)$, a function of $p\bmod 229$ alone. This is the coupling map $\chi_{229}$ of the model.
* In the Chebotarev fibre-product model with $G = S_3$, $R = (\mathbb Z/229)^\times$ and $\Delta=\{\pm1\}$, Theorem 4.6 gives exactly $1$ bit. Proposition 4.4 identifies how the bit is distributed.

None of $229$, the particular cubic, or the four earlier discriminants enters the final value. Only $|\Delta|=2$ does. *Five fields, five discriminants, one formula:* $I = \log_2|G^{\mathrm{ab}}| = \log_2 2$. More generally, Theorem 4.1 predicts the same single bit for the cycle-type channel of any $S_n$ field, for every $n\ge2$.

---

## 7. Algorithms

**Algorithm A (root count modulo $p$ via a Frobenius gcd).** The number of distinct roots of a squarefree $f$ mod $p$ is $\deg\gcd(x^p-x,\ f)$ over $\mathbb F_p$. Compute $x^p \bmod f$ by binary exponentiation in $\mathbb F_p[x]/(f)$, using the reduction $x^3 = 4x-1$. Subtract $x$, then run the Euclidean algorithm with $f$. The cost is $O(\log p)$ multiplications of residues of degree less than $3$, each $O(1)$ operations in $\mathbb F_p$. If $x^p - x\equiv 0 \bmod f$, the cubic splits completely.

**Algorithm B (plug-in mutual information).** Given samples $(c_i,t_i)_{i\le N}$, form the contingency counts $n_{c,t}$ and marginals. Return $\hat I = H(\hat c)+H(\hat t)-H(\hat c,\hat t)$ using Definition 2.1. The cost is $O(N)$ time with hashing.

**Algorithm C (exact fibre-product channel).** Enumerate $\sigma\in S_n$ and $r\in(\mathbb Z/\ell)^\times$. Keep the pairs with $\operatorname{sign}\sigma = \left(\frac r\ell\right)$, computing the Legendre symbol by Euler's criterion $r^{(\ell-1)/2}\bmod \ell$. Then apply Algorithm B to $(\tau(\sigma), r)$. The cost is $O(n!\,\ell\,(n+\log\ell))$. By Theorem 3.1 the output is exactly $1$ whenever $\tau$ determines the sign.

**Algorithm D (Legendre-symbol prediction).** By Theorem 5.10, $T(p)=1$ exactly when $229^{(p-1)/2}\equiv -1\pmod p$, or equivalently $p^{114}\equiv -1 \pmod{229}$. This decides the "one root versus not" question in $O(\log p)$ time without touching $f$.

---

## 8. Numerical Illustrations

These computations illustrate the theorems above; they are not part of the proofs.

**8.1 The splitting-type law.** For all $17{,}982$ primes $3\le p\le 200{,}000$ with $p\ne 229$, Algorithm A gives the root count. In every case the root count is $1$ exactly when $\left(\frac{p}{229}\right) = -1$, which also coincides with $\left(\frac{229}{p}\right)=-1$, and the value $2$ never occurs. The observed type frequencies are:

| roots | count | frequency | Chebotarev density |
|---|---|---|---|
| $0$ | $6008$ | $0.3341$ | $1/3$ |
| $1$ | $8987$ | $0.4998$ | $1/2$ |
| $2$ | $0$ | $0$ | $0$ |
| $3$ | $2987$ | $0.1661$ | $1/6$ |

**8.2 Exact model values.** Algorithm C returns $I = 1$ to within floating-point rounding for the cycle-type read-out on $S_2, S_3, S_4, S_5$ with conductors $\ell\in\{5,7,13\}$, and for the root-count read-out on $S_3$ with $\ell=229$. For contrast, the fixed-point count on $S_4$, which does *not* determine the sign, gives $I\approx0.6556<1$. The independent product gives $I=0$.

**8.3 Finite-sample excess.** The plug-in estimate $\hat I_N$ of $I(p\bmod229;\,T)$ over the first $N$ odd primes other than $229$:

| $N$ | $\hat I_N$ | excess |
|---|---|---|
| $1{,}000$ | $1.0737$ | $+0.0737$ |
| $2{,}000$ | $1.0320$ | $+0.0320$ |
| $5{,}000$ | $1.0106$ | $+0.0106$ |
| $10{,}000$ | $1.0045$ | $+0.0045$ |
| $17{,}982$ | $1.0023$ | $+0.0023$ |

The excess is positive and decreases roughly in proportion to $1/N$, as the Miller–Madow bias of plug-in entropy estimators predicts. A reported value of $1.0078$ fits a sample of several thousand primes. Since the true value is exactly $1$ by Theorem 4.6, the excess is bias, not signal. The large $z$-score measures how far the value is from the independence value $0$.

---

## 9. Discussion

**Where the bit lives.** The proof of Theorem 3.1 shows something sharper than the value of $I$. Every nonzero cell of the contingency table contributes the *same* log-ratio $\log_2|\Delta|$. Information about the residue class therefore flows through the read-out only via the abelian quotient. In Galois-theoretic terms, congruence conditions see only the abelianisation of the Galois group, which is the content of class field theory, and Theorem 3.1 measures that visibility in bits.

**Hypothesis "τ determines ε".** This hypothesis matters. The $S_4$ fixed-point example in §8.2 shows that a read-out which only partly determines the sign transmits strictly less than $\log_2|\Delta|$. In the fibre product, $\tau(\sigma)$ and $r$ are conditionally independent given the common value $d=\varepsilon(\sigma)=\chi(r)$, and $d$ is a function of $r$. This strongly suggests the general formula $I(\tau;r) = I_G(\tau;\varepsilon)$. Theorem 3.1 is the case where the right side equals $H(\varepsilon)=\log_2|\Delta|$.

**Limits of the model.** Theorems 3.1–4.6 are exact statements about the equidistributed model. The passage from primes to the model is Chebotarev's theorem combined with the Artin map. For $x^3-4x+1$ the needed coupling (Corollary 5.11) is proved here unconditionally and elementarily. The equidistribution itself is the classical density theorem and is used only to interpret the model.

**Elementary methods.** Section 5 uses no algebraic number theory beyond quadratic reciprocity. The roles of the discriminant, the Galois action and the conductor are all carried by explicit polynomial identities: $\delta^2 = 4(r^2+rs+s^2)^3-27(rs(r+s))^2$, the residual identity, and the computation $\delta^p=\delta$.

---

## 10. Future Directions

1. **Abelianisation–Projection Law.** Conjecture: for any Galois field with group $G$ and any conjugation-invariant read-out $\tau$, the Chebotarev fibre-product channel satisfies $I(p \bmod f;\tau) = I_G(\tau;\,\mathrm{ab})$, where $\mathrm{ab}:G\to G^{\mathrm{ab}}$ and $f$ is the conductor of the maximal abelian subfield. When $\tau$ determines $\mathrm{ab}$, this reduces to $\log_2|G^{\mathrm{ab}}|$. For example, $D_4$ quartic fields would give $2$ bits and $A_4$ fields $\log_2 3$ bits.
2. **Miller–Madow bias law for the type channel.** Derive the exact first-order term of $\mathbb E[\hat I_N] - 1$ for an $S_3$ field of prime conductor $D$ from the occupied-cell structure of the contingency table, and use it to recalibrate the reported $z$-scores.
3. **Higher degree.** Check Theorem 4.1 arithmetically for explicit $S_4$ and $S_5$ fields by proving the analogue of Corollary 5.11 (sign of Frobenius equals a quadratic character of $p$ modulo the conductor of $\mathbb Q(\sqrt{\operatorname{disc}})$).
4. **Composite and even conductors.** Extend Theorem 4.6 to quadratic resolvents with composite or even conductor, where $R=(\mathbb Z/D)^\times$ is no longer cyclic but the quadratic character is still a balanced surjection.

---

## References

1. E. Artin, *Galois Theory*, Notre Dame Mathematical Lectures, 1942.
2. T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley, 2006.
3. G. A. Miller, "Note on the bias of information estimates," in *Information Theory in Psychology*, Free Press, 1955.
4. J. Neukirch, *Algebraic Number Theory*, Springer, 1999.
5. N. Tschebotareff, "Die Bestimmung der Dichtigkeit einer Menge von Primzahlen, welche zu einer gegebenen Substitutionsklasse gehören," *Math. Ann.* 95 (1926), 191–228.
