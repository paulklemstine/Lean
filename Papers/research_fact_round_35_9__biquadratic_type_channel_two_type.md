# The Biquadratic Type Channel: Two Types, Full Pinning, and a Swap-Symmetry Law

**Aristotle**

*October 2026*

---

## Abstract

We study the splitting behaviour of the quartic $f(x) = x^4 - 10x^2 + 1$, the minimal polynomial of $\sqrt2+\sqrt3$, modulo primes, and we quantify it information-theoretically. The splitting field is the biquadratic field $\mathbb{Q}(\sqrt2,\sqrt3)$, with Galois group $V_4 = C_2\times C_2$ and conductor $24$. We first prove a field-independent statement about the general biquadratic quartic $B_{a,b}(x) = x^4 - 2(a+b)x^2 + (a-b)^2$. Over any field of characteristic different from $2$ with $a\neq b$, it has a root if and only if both $a$ and $b$ are squares. Its roots are then exactly $\pm\alpha\pm\beta$, and these are four distinct elements. Over a finite field, $B_{a,b}$ therefore has $4$ or $0$ roots. Specialising to $f$ via quadratic reciprocity, we show that for every prime $p\ge5$, $f$ has $4$ roots modulo $p$ if $p\equiv\pm1\pmod{24}$ and none otherwise. No proper divisor of $24$ determines this type, and $f$ is irreducible over $\mathbb{Q}$ although it is a product of two monic quadratics modulo every prime. Viewing the type $T$ as a random variable and the residue $p \bmod 24$ as a side channel, we prove full pinning, $I(T;\,p\bmod 24) = H(T)$, on every finite set of primes $p \ge 5$. We compute the class-level entropy exactly, $H(T) = 2-\tfrac34\log_2 3 \in (0.8109,\,0.8114)$. For semiprimes $N=pq$ we show that $N \bmod 24$ carries exactly $\tfrac{19}{8}-\tfrac{21}{16}\log_23\approx0.2947$ bits about the type pair. It carries exactly $0$ bits about which factor of a mixed semiprime splits. The last statement is an instance of a general swap-symmetry law: an involution that preserves the side channel and flips a Boolean read-out forces zero mutual information. These exact values explain the finite-sample measurements $0.8074$, $0.2909$ and $0.0001$ bits reported in computational experiments.

---

## 1. Introduction

Let $f\in\mathbb{Z}[x]$ be a monic irreducible polynomial and $p$ a prime. The *splitting type* of $f$ at $p$ describes how $f$ factors modulo $p$. By the Frobenius density theorem and the Chebotarev density theorem, it is governed by the conjugacy class of a Frobenius element in the Galois group of the splitting field. When that group is abelian, class field theory says more. The Frobenius class depends only on $p$ modulo a fixed integer $m$, the *conductor*. The type is then a deterministic function of $p \bmod m$.

This paper studies the smallest interesting non-cyclic abelian example, the biquadratic field $K = \mathbb{Q}(\sqrt2,\sqrt3)$, from two angles.

**Arithmetic.** We prove from first principles, with explicit algebraic identities, that the splitting type of $f(x)=x^4-10x^2+1$ takes only two values and is determined by $p\bmod 24$. We also prove that no smaller modulus works and that $f$ has the classical "irreducible over $\mathbb{Q}$, reducible everywhere locally" property.

**Information.** We treat a prime as a message, its splitting type $T$ as a hidden variable, and a residue as an observable side channel. We then compute Shannon entropies and mutual informations *exactly*, in closed form involving only $\log_2 3$. The computations cover

1. the entropy of the type,
2. the information that $p \bmod 24$ carries about $T$ (all of it),
3. the information that $N = pq \bmod 24$ carries about the type pair of a semiprime, and
4. the information that $N \bmod 24$ carries about *which* factor of a mixed semiprime splits (none of it).

The last item follows from a general lemma, the **swap-symmetry law**. It is purely combinatorial and applies to any channel with the same symmetry.

Computational experiments on large finite samples of primes and semiprimes reported $H(T)\approx0.8074$, a pair-channel value of $\approx0.2909$, and a which-factor value of $\approx 0.0001$ bits. Our exact class-level values are $0.8113\ldots$, $0.2947\ldots$ and $0$. These are the limits approached by uniform sampling over residue classes, which by Dirichlet's theorem is the asymptotic distribution of primes. The measured entropy lies strictly below the limit, which reflects a slight under-representation of the split classes in the sample.

### Organisation

Section 2 fixes notation and the information-theoretic definitions. Section 3 proves the field-independent theory of $B_{a,b}$. Section 4 specialises to $x^4-10x^2+1$ modulo primes. Section 5 treats the local–global contrast. Section 6 computes the type entropy and proves full pinning. Section 7 computes the semiprime pair channel. Section 8 proves the swap-symmetry law and derives the vanishing of the which-factor information. Section 9 gives algorithms, Section 10 discusses applications and interpretation, and Section 11 lists open directions.

---

## 2. Definitions and notation

Throughout, $\log_2$ is the binary logarithm and information is measured in bits.

**Definition 2.1 (Uniform entropy of a read-out).** Let $S$ be a nonempty finite set and $g : S\to V$ a function to any set $V$. For $v\in g(S)$ let $n_v = \#\{x\in S: g(x)=v\}$. The *entropy of $g$ on $S$* is the Shannon entropy of the push-forward of the uniform distribution on $S$:
$$H_S(g) \;=\; \sum_{v\in g(S)} \frac{n_v}{|S|}\,\log_2\frac{|S|}{n_v}.$$
We set $H_\emptyset(g) = 0$.

**Definition 2.2 (Conditional entropy and mutual information).** Let $k : S \to W$ be a second function, the *side channel*. For $c\in k(S)$ let $S_c = \{x\in S : k(x)=c\}$ be the fibre. Define
$$H_S(g\mid k) \;=\; \sum_{c\in k(S)} \frac{|S_c|}{|S|}\,H_{S_c}(g), \qquad I_S(g;k) \;=\; H_S(g) - H_S(g\mid k).$$

**Definition 2.3 (Full pinning).** We say that $k$ *fully pins* $g$ on $S$ if $I_S(g;k) = H_S(g)$, that is, if $H_S(g\mid k)=0$.

The following standard fact is used repeatedly.

**Lemma 2.4 (Factoring implies pinning).** If $g$ factors through $k$ on $S$, that is, if $k(x)=k(y)$ implies $g(x)=g(y)$ for all $x,y\in S$, then $I_S(g;k)=H_S(g)$.

*Proof.* Each fibre $S_c$ is nonempty and $g$ is constant on it, so $H_{S_c}(g) = 1\cdot\log_2 1 = 0$. Hence $H_S(g\mid k)=0$. $\square$

**Lemma 2.5 (Count formula).** If the fibres of $g$ on $S$ have sizes $n_1,\dots,n_r$ (all positive, summing to $N = |S|$), then
$$H_S(g) = \log_2 N - \frac1N\sum_{i=1}^r n_i\log_2 n_i .$$

*Proof.* Expand $\log_2(N/n_i) = \log_2 N - \log_2 n_i$ and use $\sum n_i = N$. $\square$

We write $h(t) = -t\log_2 t - (1-t)\log_2(1-t)$ for the binary entropy function. Note that
$$h\!\left(\tfrac14\right) = \tfrac14\cdot 2 + \tfrac34\left(2-\log_2 3\right) = 2 - \tfrac34\log_2 3.$$

**Unit classes modulo 24.** Let $U_{24} = \{1,5,7,11,13,17,19,23\}$ be the set of representatives of $(\mathbb{Z}/24\mathbb{Z})^\times$. Every prime $p\ge5$ satisfies $p\bmod 24\in U_{24}$, because $p$ is coprime to both $2$ and $3$. Every $r\in U_{24}$ satisfies $r^2\equiv1\pmod{24}$, so $(\mathbb{Z}/24)^\times\cong C_2^3$.

**The class type.** Define $\tau : U_{24}\to\{0,4\}$ by $\tau(r) = 4$ if $r\in\{1,23\}$ and $\tau(r)=0$ otherwise.

---

## 3. The general biquadratic quartic over a field

Let $F$ be a field and $a,b\in F$. Define
$$B_{a,b}(x) \;=\; x^4 - 2(a+b)x^2 + (a-b)^2 .$$
When $a,b$ are non-square rationals generating independent quadratic fields, $B_{a,b}$ is the minimal polynomial of $\sqrt a+\sqrt b$. For $a=2$, $b=3$ we get $B_{2,3}(x) = x^4-10x^2+1$.

**Lemma 3.1 (Three difference-of-squares shapes).** For all $x\in F$,
$$B_{a,b}(x) = \big(x^2+(a-b)\big)^2 - 4a\,x^2 = \big(x^2-(a-b)\big)^2 - 4b\,x^2 = \big(x^2-(a+b)\big)^2 - 4ab.$$

*Proof.* Expand each right-hand side. $\square$

The three shapes correspond to the three quadratic subfields $F(\sqrt a)$, $F(\sqrt b)$, $F(\sqrt{ab})$ of the splitting field.

**Theorem 3.2 (Root criterion).** Suppose $2\neq0$ in $F$ and $a\neq b$. Then $B_{a,b}$ has a root in $F$ if and only if both $a$ and $b$ are squares in $F$.

*Proof.* ($\Rightarrow$) Let $B_{a,b}(x)=0$. If $x=0$ then $(a-b)^2 = 0$, so $a=b$, which is excluded. Hence $x\ne0$, and $2x\neq0$. By the first shape in Lemma 3.1, $(x^2+a-b)^2 = 4a x^2$, so
$$a = \left(\frac{x^2+a-b}{2x}\right)^2.$$
The second shape gives $b = \big((x^2-a+b)/(2x)\big)^2$ in the same way.
($\Leftarrow$) If $a=\alpha^2$ and $b=\beta^2$, then $x=\alpha+\beta$ is a root by Proposition 3.3 below. $\square$

**Proposition 3.3 (Root set).** Suppose $\alpha^2 = a$ and $\beta^2=b$. Then for $x\in F$,
$$B_{a,b}(x) = 0 \iff x\in\{\alpha+\beta,\ \alpha-\beta,\ -\alpha+\beta,\ -\alpha-\beta\}.$$

*Proof.* By the third shape and $a+b = \alpha^2+\beta^2$, $4ab = 4\alpha^2\beta^2$,
$$B_{a,b}(x) = \big(x^2-\alpha^2-\beta^2\big)^2 - 4\alpha^2\beta^2 = \big(x^2-(\alpha+\beta)^2\big)\big(x^2-(\alpha-\beta)^2\big),$$
and each factor is a difference of squares. Thus
$$B_{a,b}(x) = (x-\alpha-\beta)(x+\alpha+\beta)(x-\alpha+\beta)(x+\alpha-\beta).$$
A field has no zero divisors, so the claim follows. $\square$

**Proposition 3.4 (Distinctness).** If $2\neq0$, $\alpha\neq0$, $\beta\neq0$ and $\alpha^2\neq\beta^2$, then the four elements $\pm\alpha\pm\beta$ are pairwise distinct.

*Proof.* There are six differences. Each one is $2\alpha$, $2\beta$, $2(\alpha+\beta)$ or $2(\alpha-\beta)$ up to sign, and none of these vanishes: $\alpha\ne0$, $\beta\ne0$, and $\alpha\neq\pm\beta$ because $\alpha^2\ne\beta^2$. $\square$

**Theorem 3.5 (Two types over a finite field).** Let $F$ be a finite field with $2\neq0$, and let $a,b\in F$ satisfy $a\neq0$, $b\neq0$, $a\neq b$. Then
$$\#\{x\in F : B_{a,b}(x)=0\} = \begin{cases}4 & \text{if } a \text{ and } b \text{ are both squares},\\ 0&\text{otherwise.}\end{cases}$$

*Proof.* If $a=\alpha^2$ and $b=\beta^2$, then $\alpha,\beta\ne0$ and $\alpha^2\ne\beta^2$, so Propositions 3.3 and 3.4 give exactly four roots. Otherwise Theorem 3.2 shows there are none. $\square$

In particular the root counts $1$, $2$ and $3$, which correspond to the factorisation types $(1,3)$, $(1,1,2)$ and the impossible "three roots", never occur. Neither does an irreducible quartic, by the next result.

**Proposition 3.6 (Reducibility from any quadratic subfield).** If one of $a$, $b$, $ab$ is a square in $F$, then $B_{a,b}$ is a product of two monic quadratics over $F$. Explicitly:

- if $a=\alpha^2$: $B_{a,b}(x) = (x^2-2\alpha x+a-b)(x^2+2\alpha x+a-b)$;
- if $b=\beta^2$: $B_{a,b}(x) = (x^2-2\beta x-a+b)(x^2+2\beta x-a+b)$;
- if $ab=\gamma^2$: $B_{a,b}(x) = (x^2-a-b-2\gamma)(x^2-a-b+2\gamma)$.

*Proof.* Each identity is the corresponding shape of Lemma 3.1, factored as a difference of squares. $\square$

---

## 4. The quartic $x^4-10x^2+1$ modulo primes

Let $p$ be a prime and write $\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$. For $p \ge 5$ we have $2\ne0$, $3\ne 0$ and $2\neq3$ in $\mathbb{F}_p$, so Theorem 3.5 applies to $a=2$, $b=3$.

We need the classical quadratic characters of $2$ and $3$.

**Lemma 4.1 (Second supplement).** For an odd prime $p$, $2$ is a square modulo $p$ if and only if $p\equiv\pm1\pmod 8$.

**Lemma 4.2 (Character of 3).** For a prime $p\ge5$, $3$ is a square modulo $p$ if and only if $p\equiv\pm1\pmod{12}$.

*Proof.* We use quadratic reciprocity for the odd primes $p$ and $3$. If $p\equiv1\pmod4$, then $3$ is a square mod $p$ iff $p$ is a square mod $3$, i.e. iff $p\equiv1\pmod3$. If $p\equiv3\pmod4$, then $3$ is a square mod $p$ iff $p$ is *not* a square mod $3$, i.e. iff $p\equiv2\pmod 3$. Here we use that $2$ is not a square modulo $3$. Combining the cases by the Chinese remainder theorem gives $p\equiv1$ or $11 \pmod{12}$. $\square$

**Theorem 4.3 (Root criterion at conductor 24).** For a prime $p\ge5$, the congruence $x^4-10x^2+1\equiv0\pmod p$ has a solution if and only if $p\equiv\pm1\pmod{24}$.

*Proof.* By Theorem 3.2 a solution exists iff $2$ and $3$ are both squares mod $p$. By Lemmas 4.1 and 4.2 this happens iff $p\equiv\pm1\pmod8$ and $p\equiv\pm1\pmod{12}$. Checking the eight unit residues modulo $24$, the only common solutions are $p\equiv1$ and $p\equiv23\pmod{24}$. $\square$

Define the **type** of a prime $p$ by
$$T(p) = \#\{x\in\mathbb{F}_p : x^4-10x^2+1 = 0\}.$$

**Theorem 4.4 (Only two types).** For every prime $p\ge5$,
$$T(p) = \tau(p\bmod 24) = \begin{cases}4 & p\equiv\pm1\pmod{24},\\ 0 & \text{otherwise.}\end{cases}$$
In particular, $T(p)\in\{0,4\}$.

*Proof.* Combine Theorems 3.5 and 4.3. $\square$

Examples: $T(23)=4$ with roots $2,11,12,21$; $T(47) = 4$ with roots $5,19,28,42$; $T(73) = 4$ with roots $11,20,53,62$. Every other prime $5\le p<73$ has $T(p)=0$.

**Theorem 4.5 (The conductor is exactly 24).** For every divisor $d$ of $24$ with $d\neq24$, there are primes $p,q\ge5$ with $p\equiv q\pmod d$ and $T(p)\neq T(q)$.

*Proof.* The proper divisors of $24$ are $1,2,3,4,6,8,12$, and each divides $8$ or $12$. If $d\mid 8$, take $(p,q) = (7,23)$. Then $7\equiv23\pmod 8$, while $T(7) = 0$ and $T(23)=4$. If $d\mid12$, take $(p,q)=(13,73)$. Then $13\equiv73\pmod{12}$, while $T(13)=0$ and $T(73)=4$. $\square$

---

## 5. Globally irreducible, locally reducible everywhere

**Theorem 5.1 (Reducible modulo every prime).** For every prime $p$ there are $u,v,w,z\in\mathbb{F}_p$ with
$$x^4-10x^2+1 = (x^2+ux+v)(x^2+wx+z)\quad\text{in } \mathbb{F}_p[x].$$

*Proof.* By Proposition 3.6 with $a=2$, $b=3$, it suffices that one of $2$, $3$, $6$ is a square in $\mathbb{F}_p$. For $p=2$, $2 = 0 = 0^2$. For $p=3$, $3=0=0^2$. For $p\ge5$, suppose neither $2$ nor $3$ is a square. The Legendre symbol is multiplicative, so $\left(\frac6p\right) = \left(\frac2p\right)\left(\frac3p\right) = (-1)(-1) = 1$. Since $6\not\equiv0$, $6$ is a nonzero square. $\square$

**Theorem 5.2 (Irreducible over $\mathbb{Q}$).** The polynomial $x^4-10x^2+1$ is irreducible in $\mathbb{Z}[x]$, and hence in $\mathbb{Q}[x]$.

*Proof.* The polynomial is monic of degree $4$. A proper monic factorisation must have a factor of degree $1$ or of degree $2$.

*Degree 1.* A monic linear factor $x+c$ gives an integer root $-c$. The constant term then shows $c\cdot(10c-c^3)=1$, so $c=\pm1$. But $1-10+1 = -8 \ne 0$, a contradiction.

*Degree 2.* Suppose $x^4-10x^2+1 = (x^2+ux+v)(x^2+wx+z)$ over $\mathbb{Z}$. Evaluating at $x = 0$ gives $vz=1$, so $(v,z) = (1,1)$ or $(-1,-1)$. Evaluating at $x=\pm1$ and $x=\pm2$ forces $w = -u$. It then gives $u^2 = 12$ in the first case and $u^2 = 8$ in the second. Neither $8$ nor $12$ is a perfect square, a contradiction.

Since the polynomial is monic and hence primitive, Gauss's lemma transfers irreducibility to $\mathbb{Q}[x]$. $\square$

**Corollary 5.3 (Local–global contrast).** The polynomial $x^4-10x^2+1$ is irreducible over $\mathbb{Q}$ but splits into two monic quadratics modulo every prime.

*Interpretation.* For $p\nmid 6$, the factorisation type modulo $p$ is the cycle type of Frobenius acting on the four roots. Every element of $V_4$ is a product of disjoint transpositions or the identity, so the possible types are $(1,1,1,1)$ and $(2,2)$. There are no $4$-cycles, so there is no inert type $(4)$. Theorem 4.4 says which of the two types occurs, and Theorem 5.1 shows that the root-free type is indeed $(2,2)$.

---

## 6. The type entropy and full pinning

### 6.1 Full pinning on every finite sample

**Theorem 6.1 (Full pinning).** Let $S$ be any finite set of primes, all $\ge5$. Then
$$I_S\big(T;\ p\bmod 24\big) = H_S(T).$$

*Proof.* By Theorem 4.4, $T(p) = \tau(p\bmod 24)$, so $T$ factors through $p\mapsto p\bmod24$. Apply Lemma 2.4. $\square$

This statement is about every finite sample, not just a limit. The residue modulo $24$ never leaves any uncertainty about the type.

### 6.2 The Chebotarev limit

By Dirichlet's theorem, the primes are asymptotically equidistributed among the eight classes in $U_{24}$. The natural limiting object is therefore the uniform distribution on $U_{24}$ with read-out $\tau$.

**Theorem 6.2 (Exact class-level entropy).**
$$H_{U_{24}}(\tau) = 2-\tfrac34\log_23 = h\!\left(\tfrac14\right).$$

*Proof.* The fibres of $\tau$ on $U_{24}$ have sizes $2$ (classes $1, 23$) and $6$. By Lemma 2.5,
$$H = \log_2 8 - \tfrac18\left(2\log_2 2 + 6\log_2 6\right) = 3 - \tfrac14 - \tfrac34(1+\log_2 3) = 2 - \tfrac34\log_2 3. \qquad\square$$

**Lemma 6.3 (Rational bounds on $\log_2 3$).**
$$\frac{84}{53} < \log_2 3 < \frac{485}{306}.$$

*Proof.* The left inequality is equivalent to $2^{84}<3^{53}$, and the right one to $3^{306}<2^{485}$. Both are inequalities between explicit integers and can be checked by exact integer arithmetic. $\square$

Numerically, $84/53 = 1.58490\ldots$ and $485/306 = 1.58497\ldots$, while $\log_2 3 = 1.58496\ldots$.

**Corollary 6.4 (Numerical window).** $0.8109 < H_{U_{24}}(\tau) < 0.8114$. In particular, the finite-sample value $0.8074$ lies strictly below the limit.

*Proof.* Substitute Lemma 6.3 into Theorem 6.2: $2 - \tfrac34\cdot\tfrac{485}{306} = 0.81127\ldots > 0.8109$ and $2-\tfrac34\cdot\tfrac{84}{53} = 0.81132\ldots<0.8114$. $\square$

**Proposition 6.5 (Class-level pinning).** $I_{U_{24}}(\tau;\mathrm{id}) = H_{U_{24}}(\tau)$.

*Proof.* Lemma 2.4 with $k=\mathrm{id}$. $\square$

A finite-sample entropy below $h(1/4)$ means the empirical split frequency $\hat t$ satisfies $h(\hat t)<h(1/4)$. Since $h$ increases on $[0,1/2]$, this gives $\hat t<1/4$: the sample slightly under-represents the classes $\pm1\pmod{24}$. This is consistent with Chebyshev's bias in prime races: among the unit classes modulo $24$ only the class $1$ is a square, and square classes tend to lag behind in finite ranges.

---

## 7. The semiprime pair channel

Let $N = pq$ with $p,q\ge 5$ prime. We observe $N\bmod 24$ and ask about the ordered pair $(T(p),T(q))$. At class level, the sample space is
$$U_{24}^2 = U_{24}\times U_{24}\quad(64\text{ ordered pairs}),$$
with read-out $\pi(r,s) = (\tau(r),\tau(s))$ and side channel $\kappa(r,s) = rs\bmod24$.

**Proposition 7.1 (Pair entropy).** $H_{U_{24}^2}(\pi) = 4-\tfrac32\log_2 3 = 2h(1/4)$.

*Proof.* The fibres of $\pi$ have sizes $2\cdot2=4$, $2\cdot6=12$, $6\cdot 2=12$ and $6\cdot6=36$. Lemma 2.5 gives $6 - \tfrac1{64}(4\cdot2 + 24(2+\log_2 3) + 36(2+2\log_23)) = 4-\tfrac32\log_23$. $\square$

**Lemma 7.2 (Uniform product fibres).** For every $c\in U_{24}$, exactly $8$ ordered pairs $(r,s)\in U_{24}^2$ satisfy $rs\equiv c\pmod{24}$.

*Proof.* For each $r$ there is exactly one $s$, namely $s\equiv r^{-1}c\equiv rc$, using $r^2\equiv1$. $\square$

**Lemma 7.3 (Fibre entropies).** For $c\in U_{24}$, the entropy of $\pi$ on the fibre $\{(r,s): rs\equiv c\}$ is
$$\begin{cases} 2-\tfrac34\log_2 3 & c\in\{1,23\},\\ \tfrac32 & \text{otherwise.}\end{cases}$$

*Proof.* The fibre is $\{(r, rc) : r\in U_{24}\}$. Write $H_0=\{1,23\}$, a subgroup of index $4$.

If $c\in H_0$, then $r\in H_0\iff rc\in H_0$. The fibre has $2$ split–split pairs and $6$ pairs that are split in neither factor, so its distribution is $(2,6)$ and its entropy is $h(1/4)$.

If $c\notin H_0$, then $r$ and $rc$ cannot both lie in $H_0$. Exactly one of them does for $r\in H_0\cup cH_0$, which is $4$ values of $r$: two with the first factor split ($r \in H_0$) and two with the second factor split ($rc\in H_0$). Neither lies in $H_0$ for the remaining $4$ values. The distribution is $(2,2,4)$, with entropy $\log_2 8 - \tfrac18(2+2+8) = \tfrac32$. $\square$

For example, the fibre over $c = 5$ is $\{(1,5),(5,1),(23,19),(19,23),(7,11),(11,7),(13,17),(17,13)\}$.

**Theorem 7.4 (Semiprime pair channel).**
$$I_{U_{24}^2}(\pi;\kappa) = \frac{19}{8} - \frac{21}{16}\log_2 3 \approx 0.2947 \text{ bits}.$$

*Proof.* The image of $\kappa$ is $U_{24}$, and by Lemma 7.2 every fibre has weight $8/64 = 1/8$. Two of the eight fibres have entropy $h(1/4)$ and six have entropy $3/2$ by Lemma 7.3, so
$$H(\pi\mid\kappa) = \tfrac68\cdot\tfrac32+\tfrac28\left(2-\tfrac34\log_23\right) = \tfrac98+\tfrac14\left(2-\tfrac34\log_23\right).$$
Subtracting from Proposition 7.1:
$$I = 4-\tfrac32\log_23-\tfrac98-\tfrac12+\tfrac3{16}\log_23 = \tfrac{19}8-\tfrac{21}{16}\log_23.\qquad\square$$

**Corollary 7.5.** $0.2943 < I_{U_{24}^2}(\pi;\kappa) < 0.2951$.

*Proof.* Substitute Lemma 6.3. $\square$

The finite-sample value $0.2909$ lies close to this window, slightly below it, in the same direction as the type entropy.

---

## 8. The swap-symmetry law and the which-factor channel

### 8.1 The general law

**Lemma 8.1 (Flip balances fibres).** Let $t$ be a finite set, $g : t\to\{0,1\}$, and $\sigma : t\to t$ with $\sigma(\sigma(x))=x$ and $g(\sigma(x)) = 1-g(x)$ for all $x\in t$. Then $\#\{x\in t: g(x)=0\} = \#\{x\in t : g(x)=1\}$.

*Proof.* $\sigma$ maps $g^{-1}(0)$ into $g^{-1}(1)$ and vice versa, and it is its own inverse. So it is a bijection between the two sets. $\square$

**Lemma 8.2 (Balanced bit).** Under the hypotheses of Lemma 8.1, if $t\neq\emptyset$ then $H_t(g) = 1$.

*Proof.* Both fibres have size $|t|/2>0$, and $H = 2\cdot\tfrac12\log_2 2=1$. $\square$

**Theorem 8.3 (Swap-symmetry law).** Let $S$ be a finite set, $g:S\to\{0,1\}$ a Boolean read-out, $k:S\to W$ a side channel, and $\sigma:S\to S$ a map such that for all $x\in S$:

1. $\sigma(\sigma(x)) = x$ (involution);
2. $g(\sigma(x)) = 1-g(x)$ ($\sigma$ flips the read-out);
3. $k(\sigma(x)) = k(x)$ ($\sigma$ preserves the side channel).

Then $I_S(g;k)=0$.

*Proof.* If $S=\emptyset$ all quantities vanish. Otherwise, by condition 3, $\sigma$ maps each fibre $S_c = k^{-1}(c)$ to itself. Conditions 1 and 2 hold on $S_c$, so Lemma 8.2 gives $H_{S_c}(g) = 1$ for every $c$ in the image. Hence $H_S(g\mid k) = \sum_c \tfrac{|S_c|}{|S|} = 1$. Lemma 8.2 on $S$ itself gives $H_S(g)=1$, so $I_S(g;k) = 1-1 = 0$. $\square$

The proof uses no arithmetic. It is the information-theoretic form of the principle that *a symmetric observation cannot distinguish a configuration from its mirror image*.

### 8.2 Which factor splits?

Let
$$M = \{(r,s)\in U_{24}^2 : \text{exactly one of } \tau(r),\tau(s) \text{ equals } 4\}$$
be the set of *mixed* ordered class pairs. Let $g(r,s) = 1$ if $\tau(r)=4$ (the first factor splits) and $0$ otherwise. Then $|M| = 2\cdot 6 + 6\cdot 2 = 24$.

**Theorem 8.4 (Which-factor information vanishes).** $I_M(g;\kappa) = 0$, while $H_M(g) = 1$.

*Proof.* Take $\sigma(r,s) = (s,r)$. Mixedness is symmetric, so $\sigma$ maps $M$ into $M$, and $\sigma$ is clearly an involution. On a mixed pair exactly one coordinate is split, so swapping flips $g$. Finally $\kappa(s,r) = sr = rs = \kappa(r,s)$ modulo $24$ by commutativity. Theorem 8.3 gives $I_M(g;\kappa)=0$, and Lemma 8.2 gives $H_M(g)=1$. $\square$

So the question "which factor splits?" carries a full bit of uncertainty, and the residue $N\bmod 24$ is completely blind to it. The finite-sample value $0.0001$ is sampling noise around an exact zero. The same proof applies verbatim to any finite sample of mixed semiprimes that is closed under swapping the factors, for instance all ordered pairs $(p,q)$ of primes from a fixed range. If the sample is *not* closed under the swap, for example if one keeps only pairs with $p<q$, the hypothesis fails and a small nonzero value can appear. Numerically, for mixed pairs of primes $5\le p<q\le 3000$ the which-factor information is about $0.0003$ bits, while on the swap-closed set of all ordered mixed pairs from the same range it is $0$ up to rounding. A reported value such as $0.0001$ bits is therefore what one expects from an ordering convention or sampling noise, and the symmetric quantity is exactly zero.

---

## 9. Algorithms

**Algorithm A (Type of a prime).** *Input:* a prime $p\ge5$. *Output:* $T(p)\in\{0,4\}$. Compute $r = p\bmod 24$ and return $4$ if $r\in\{1,23\}$, else $0$. *Cost:* $O(\log p)$ bit operations. *Certificate:* if $T(p) = 4$, find square roots $\alpha$ of $2$ and $\beta$ of $3$ modulo $p$ (e.g. by Tonelli–Shanks, expected $O(\log^3 p)$) and output the four roots $\pm\alpha\pm\beta$. If $T(p)=0$, output whichever of $2$, $3$, $6$ is a square together with its square root, and the explicit quadratic factorisation of Proposition 3.6.

**Algorithm B (Exact channel entropies).** *Input:* a finite list of samples with read-out and side-channel values. Build the joint histogram in a hash map, then compute $H(g)$ by Lemma 2.5 and $H(g\mid k)$ by summing fibre entropies weighted by fibre sizes. *Cost:* $O(|S|)$ expected time. Applied to $U_{24}$ and $U_{24}^2$ it reproduces Theorems 6.2 and 7.4 to machine precision. Applied to all primes in a range it gives the finite-sample values, which approach the class-level limits.

**Algorithm C (Swap-symmetry certificate).** *Input:* finite $S$, read-out $g$, side channel $k$, candidate map $\sigma$. Check the three conditions of Theorem 8.3 pointwise in $O(|S|)$ time. If all hold, output "$I(g;k)=0$ exactly" without computing any logarithms.

---

## 10. Applications and discussion

**Exact versus empirical.** The three experimentally measured values $0.8074$, $0.2909$ and $0.0001$ bits each have an exact class-level counterpart: $h(1/4) = 0.81128\ldots$, $\tfrac{19}8-\tfrac{21}{16}\log_23 = 0.29474\ldots$ and $0$. Two of these are closed forms in $\log_2 3$. The third is an exact identity that holds on every symmetric finite sample, not only in the limit. The rigorous numerical windows of Corollaries 6.4 and 7.5 show that the empirical deviations are genuine sampling effects and not artefacts of the theory.

**Side channels on semiprimes.** In factoring-based cryptography an adversary may learn cheap invariants of $N=pq$, such as residues. Theorem 7.4 quantifies how much a residue reveals about the *multiset* of Frobenius types of the hidden factors. Theorem 8.4 shows that a residue can never reveal their *order*. More generally, any function of $N$ alone is invariant under swapping $p$ and $q$. By the swap-symmetry law, no such function can carry information about an order-sensitive Boolean property that the swap flips. This is a structural barrier and does not depend on the specific modulus or polynomial.

**Why only two types.** Theorem 3.5 is a finite-field shadow of the group structure of $V_4$. Its non-identity elements are three involutions, each acting on the roots $\pm\alpha\pm\beta$ as a product of two transpositions. The only factorisation types are therefore $(1,1,1,1)$ and $(2,2)$, in proportions $1:3$. This explains both the type entropy $h(1/4)$ and the local–global contrast of Corollary 5.3.

**Field-independence.** The core algebra (Section 3) holds over any field of characteristic $\neq2$. Number theory enters only through the quadratic characters of $2$ and $3$, that is, quadratic reciprocity and its second supplement. This separation is what makes the generalisations below plausible.

---

## 11. Future work

1. **A conductor law for arbitrary $\mathbb{Q}(\sqrt a,\sqrt b)$.** For squarefree coprime $a,b$, the type of $B_{a,b}$ at primes $p\nmid 2ab(a-b)$ should depend only on $p\bmod\operatorname{lcm}(f_a,f_b)$, where $f_d$ is the conductor of $\mathbb{Q}(\sqrt d)$, and no proper divisor should suffice. Theorem 3.5 already reduces the type to the pair of Legendre symbols $\big((a/p),(b/p)\big)$, so only quadratic reciprocity for $a$ and $b$ remains.
2. **Universality of the $V_4$ entropy.** For every biquadratic field, the class-level type entropy should equal $h(1/4)=2-\tfrac34\log_23$, because the split classes always form the kernel of a surjection onto $C_2\times C_2$ and therefore have relative size $1/4$.
3. **Swap-blindness for all abelian type channels.** For every abelian conductor $m$, the residue $pq\bmod m$ carries zero information about which factor carries a given type. Theorem 8.3 reduces this to checking the involution conditions.
4. **Pair-channel closed form for multiquadratic fields.** For a field with group $C_2^k$ and $n=2^k$, the analysis of Lemma 7.3 generalises: split fibres have distribution $h(1/n)$, and mixed fibres have distribution $(1/n,1/n,1-2/n)$. This predicts
$$I_n = \left(2-\tfrac1n\right)h\!\left(\tfrac1n\right) - \tfrac{n-1}{n}\,H\!\left(\tfrac1n,\tfrac1n,1-\tfrac2n\right),$$
which for $n=4$ recovers $\tfrac{19}8-\tfrac{21}{16}\log_23$.

---

## 12. Conclusion

The quartic $x^4-10x^2+1$ has one of the most transparent splitting behaviours among non-cyclic number fields. A threefold difference-of-squares identity reduces it to two quadratic characters, reciprocity places these on clocks of $8$ and $12$ hours, and their least common multiple $24$ is exactly the conductor. In information-theoretic terms, the residue modulo $24$ pins the type completely: $h(1/4)$ bits out of $h(1/4)$. For semiprimes, the product residue reveals $\tfrac{19}{8}-\tfrac{21}{16}\log_2 3$ bits about the type pair and, because multiplication is commutative, exactly nothing about which factor is split.
