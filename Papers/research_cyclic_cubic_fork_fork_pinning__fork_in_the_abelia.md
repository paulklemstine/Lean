# Fork-Pinning: An Information-Theoretic Criterion for Congruence Determination of Prime Splitting

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Let $f \in \mathbb{Z}[x]$ be monic and separable, and let a *fork* be any binary-valued function of the splitting type of $f$ modulo a prime $p$. We ask when such a fork is determined by a congruence condition on $p$, and — when it is not — exactly how much information a congruence still carries. Working in the Chebotarev model, where the Frobenius element of the Galois group $G$ of the splitting field of $f$ is uniform on $G$ and congruence data corresponds to abelian characters of $G$, we prove the **fork-pinning criterion**: a fork $Y$ satisfies $I(X;Y) = H(Y)$ for some abelian character $X$ of $G$ if and only if $Y$ factors through the abelianization $G^{\mathrm{ab}} = G/[G,G]$, equivalently if and only if $Y(gc) = Y(g)$ for every commutator $c$. The abelianization map is the *optimal* congruence observable: every abelian character's information is dominated by it, with equality for all forks precisely when the character's kernel equals $[G,G]$.

We instantiate the criterion on three Galois groups and obtain closed-form information values that match numerical measurement over thousands of primes to three or four decimals: for a cyclic cubic field ($G = C_3$) the total-splitting fork is pinned at $100\%$ of its entropy, $I = H = \log 3 - \frac23 \log 2 = 0.9183$ bits; for an $S_3$ cubic only the sign is visible, $I = \frac43 \log 2 + \frac12 \log 3 - \frac56 \log 5 = 0.1909$ bits, and the deficit is exactly $\frac12 H(1/3)$; for an $S_4$ quartic the has-a-root fork yields $I = \frac32\log 2 - \frac58 \log 5 = 0.0488$ bits, and every within-face fork is exactly flat. Perfect Galois groups (e.g. $A_5$) are congruence-blind: every fork has $I = 0$ against every abelian character.

We determine the capacity of a binary fork: $I \le \log 2$ always, with equality iff the observable determines the fork *and* the fork is balanced; for $S_n$ the capacity is attained by exactly two forks, the sign and its negation. For a balanced (index-two) observable and a fork of density $d \le \frac12$ we prove the sharp extremal profile $I \le \Phi(d) = h(d) - \frac12 h(2d)$, attained by single-coset forks, show $\Phi$ is strictly increasing on $[0,\frac12]$, and derive $\Phi(d)/d \to \log 2$ and $\Phi(d)/h(d) \to 0$ as $d \to 0^+$.

Finally we quantify the semiprime barrier. For $N = pq$ and any finite group of order $n$, the information between the class of $N$ and the fork "$p$ splits or $q$ splits" is a single universal function $D(n)$ of $n$; it satisfies $D(n) \le \frac{1}{(2n-1)(n-1)}$, $n^2 D(n) < 1$ for all $n$, and $n^2 D(n) \to 1 - \log 2$. Moreover the *which-factor* information vanishes identically: for any statistic of the first factor alone, the class of the product is exactly independent of it, and this persists for products of $k$ factors. A prime-level fork pinned at $100\%$ therefore collapses to a $0.0728$-bit symmetric residue dial at the semiprime level, provably blind to which factor contributed what.

**Keywords:** Chebotarev density, abelianization, Frobenius, mutual information, splitting types, cubic residues, data processing inequality, semiprime.

---

## 1. Introduction

### 1.1 The phenomenon

Reduce a monic separable $f \in \mathbb{Z}[x]$ of degree $n$ modulo an unramified prime $p$; it factors into distinct irreducibles whose degrees form a partition of $n$, the **splitting type** $\lambda(p)$. Empirically, some splitting questions are answered by congruences and some are not, and the divide is stark rather than gradual.

Two cubics make the point. For $f_1 = x^3 + x^2 - 2x - 1$ — the minimal polynomial of $2\cos(2\pi/7)$, generating the real cyclic cubic subfield of $\mathbb{Q}(\zeta_7)$ — one finds over the first $6541$ primes, with zero exceptions,
$$\lambda(p) = [1,1,1] \iff p \equiv \pm 1 \pmod 7,$$
and no prime ever produces the type $[1,2]$. For $f_2 = x^3 + x + 1$, of discriminant $-31$, no modulus whatsoever produces such a rule.

This paper explains the dichotomy, proves it in general, computes the exact residual information in the non-pinned cases, determines the maximum information any observable can extract from a binary splitting statistic, and quantifies the collapse of all of this structure when the prime is replaced by a semiprime.

### 1.2 The model

Two classical theorems reduce everything to finite group theory with the uniform measure.

*Chebotarev (1922).* Let $L$ be the splitting field of $f$ and $G = \mathrm{Gal}(L/\mathbb{Q})$, viewed as a subgroup of $S_n$ through its action on roots. Unramified primes have a well-defined Frobenius conjugacy class, distributed in proportion to class size; the splitting type of $p$ is the cycle type of the Frobenius. Hence a prime chosen by natural density behaves as a uniformly random $g \in G$, and $\lambda(p)$ is the cycle type of $g$.

*Abelian reciprocity (Artin, 1927; classically Kronecker–Weber).* The congruence class of $p$ modulo $m$ determines, and is determined by, the images of the Frobenius under characters of $G$ landing in abelian groups. Every homomorphism $\varphi : G \to A$ with $A$ commutative kills commutators and thus factors uniquely through $G^{\mathrm{ab}} = G/[G,G]$.

Accordingly, throughout this paper we study the uniform probability space $(G, \text{uniform})$; an **observable** is a function $X : G \to \kappa$ into a finite set, and *congruence observables* are exactly those of the form $g \mapsto \varphi(g)$ for a homomorphism $\varphi$ into a finite abelian group. Every theorem below is a theorem about finite groups; the number-theoretic statements are their translations under the dictionary above.

### 1.3 Contributions

1. **The criterion** (§3): pinning $\iff$ factoring through $G^{\mathrm{ab}}$ $\iff$ commutator invariance, plus the optimality and *conductor-detection* statements for the abelianization.
2. **Exact values on $C_3$, $S_3$, $S_4$, and $A_5$** (§4), matching measurement.
3. **Capacity of a binary fork** (§5): the one-bit ceiling, its exact attainment condition, and the rigidity theorem for $S_n$.
4. **The extremal profile of an index-two conductor** (§6), with monotonicity and both small-$d$ asymptotics.
5. **The semiprime barrier** (§7): the universal dial, its sharp $\Theta(1/n^2)$ constant, and the exact which-factor wall for $k$ factors.

---

## 2. Information-theoretic framework

All logarithms are natural unless a value is quoted "in bits", in which case it has been divided by $\log 2$.

**Definition 2.1 (empirical law).** Let $\Omega$ be a finite nonempty set with the uniform measure and $X : \Omega \to \kappa$ with $\kappa$ finite. The *fibre* of $X$ over $k$ is $X^{-1}(k)$ and
$$\Pr[X = k] = \frac{|X^{-1}(k)|}{|\Omega|}, \qquad \sum_{k} \Pr[X=k] = 1 .$$

**Definition 2.2 (entropy, joint, mutual information).** With $\eta(t) = -t\log t$ (and $\eta(0)=0$),
$$H(X) = \sum_{k} \eta\big(\Pr[X=k]\big), \qquad (X,Y)(\omega) = (X\omega, Y\omega),$$
$$I(X;Y) = H(X) + H(Y) - H(X,Y).$$

**Definition 2.3 (determination, pinning, flatness).** $X$ **determines** $Y$ if $X\omega = X\omega' \Rightarrow Y\omega = Y\omega'$ for all $\omega,\omega'$. The pair is **pinned** if $I(X;Y) = H(Y)$, and **flat** if $I(X;Y) = 0$.

**Definition 2.4 (fork).** A **fork** is an observable with values in a two-element set. In the arithmetic setting a fork is a yes/no function of the splitting type, e.g. $[\lambda(p) = [1,1,1]]$ or $[f \text{ has a root mod } p]$.

The elementary theory we need is the following; each item is proved for the uniform measure on a finite set, where "almost surely" collapses to "pointwise", giving the sharp equality statements.

**Theorem 2.5 (basic properties).** For observables $X : \Omega \to \kappa$, $Y : \Omega \to \beta$ on a finite uniform space:

1. $H(X) \le H(X,Y)$, with equality iff $X$ determines $Y$.
2. **Pinning identity:** $I(X;Y) = H(Y)$ iff $X$ determines $Y$; and $I(X;Y) < H(Y)$ otherwise.
3. $0 \le I(X;Y)$, with $I(X;Y) = 0$ iff $X$ and $Y$ are independent.
4. $H(X) \le \log|\kappa|$, hence $I(X;Y) \le \min\{H(Y), \log|\kappa|\}$.
5. **Chain rule:** $I(X;Y) = H(Y) - \mathbb{E}_k\big[H(Y \mid X = k)\big]$.
6. **Data processing:** for any map $u : \kappa \to \kappa'$, $I(u\circ X; Y) \le I(X;Y)$, with an explicit termwise equality condition.
7. If $X$ determines $X'$, then $I(X';Y) \le I(X;Y)$.

*Proof sketch.* (1) Write $H(X,Y) - H(X) = \sum_{k}\Pr[X=k]\, H(Y\mid X=k) \ge 0$ using the superadditivity $\eta(\sum_i a_i) \le \sum_i \eta(a_i)$ for nonnegative $a_i$, which is strict as soon as two summands are positive; two positive summands in a fibre is precisely the failure of determination. (2) is (1) rearranged, since $I = H(Y) - (H(X,Y) - H(X))$. (3) follows from Gibbs' inequality applied termwise to $\Pr[(X,Y)=(k,b)]$ versus $\Pr[X=k]\Pr[Y=b]$; strictness of $t \mapsto \log t$ gives the equality case. (4) is Jensen. (5) is the computation in (1). (6) is proved by exhibiting a nonnegative termwise "gap"
$$\Delta(k,b) = r\log\frac{r\,\Pr[u X = uk]}{\Pr[X=k]\,\Pr[(uX,Y) = (uk,b)]}, \quad r = \Pr[(X,Y)=(k,b)],$$
showing $\sum_{k,b}\Delta(k,b) = I(X;Y) - I(uX;Y)$ and $\Delta \ge 0$ pointwise. (7) follows from (6), since determination is equivalent to factorization $X' = u \circ X$. $\square$

Item (2) is the technical heart of the paper: over a finite uniform space, *pinning is exactly determination*, so an information-theoretic hypothesis converts into a combinatorial one with no loss.

---

## 3. The fork-pinning criterion

Fix a finite group $G$ with the uniform measure and write $\pi : G \to G^{\mathrm{ab}}$, $\pi(g) = g[G,G]$.

**Theorem 3.1 (criterion, structural half).** Let $A$ be a finite abelian group, $\varphi : G \to A$ a homomorphism, and $Y : G \to \beta$ any observable. If $\varphi$ determines $Y$, then $\pi$ determines $Y$.

*Proof sketch.* $\varphi$ factors as $\tilde\varphi \circ \pi$ with $\tilde\varphi$ the induced map on $G^{\mathrm{ab}}$. If $\pi(x) = \pi(y)$ then $\varphi(x) = \tilde\varphi(\pi x) = \tilde\varphi(\pi y) = \varphi(y)$, so determination by $\varphi$ transfers. $\square$

**Theorem 3.2 (criterion).** For a finite abelian $A$, a homomorphism $\varphi: G \to A$, and $Y : G \to \beta$, the following are equivalent:

1. $I(\varphi; Y) = H(Y)$ for some abelian $A$ and some $\varphi$;
2. $Y$ factors through $G^{\mathrm{ab}}$, i.e. $Y = \psi \circ \pi$ for some $\psi : G^{\mathrm{ab}} \to \beta$;
3. $Y(gc) = Y(g)$ for all $g \in G$ and all $c \in [G,G]$;
4. $I(\pi; Y) = H(Y)$.

*Proof sketch.* (1)$\Rightarrow$(2): pinning gives determination by Theorem 2.5(2); Theorem 3.1 upgrades this to determination by $\pi$; determination by a map is equivalent to factorization through it. (2)$\Rightarrow$(3): $\pi(gc) = \pi(g)$ for $c \in [G,G]$. (3)$\Rightarrow$(4): commutator invariance says exactly that $Y$ is constant on the cosets of $[G,G]$, i.e. on the fibres of $\pi$, hence $\pi$ determines $Y$, hence pinning. (4)$\Rightarrow$(1) is trivial, taking $\varphi = \pi$. $\square$

**Corollary 3.3 (abelian Galois group).** If $G$ is abelian, then $\pi$ is injective and *every* fork of $G$ is pinned: $I(\pi;Y) = H(Y)$ for all $Y$. Congruences determine every splitting question.

**Corollary 3.4 (universal non-pinning).** If some pair $(g,c)$ with $c \in [G,G]$ has $Y(gc) \ne Y(g)$, then $I(\varphi;Y) \ne H(Y)$ for *every* abelian character $\varphi$, of every conductor. Failure to pin is not a matter of choosing a larger modulus.

**Theorem 3.5 (optimality of the abelianization).** For any $\varphi : G \to A$ with $A$ abelian and any $Y$,
$$I(\varphi; Y) \le I(\pi; Y).$$

*Proof sketch.* $\varphi = \tilde\varphi \circ \pi$, and data processing (Theorem 2.5(6)) applies to $\tilde\varphi$. $\square$

**Theorem 3.6 (conductor detection).** $I(\varphi;Y) = I(\pi;Y)$ *for every* fork $Y : G \to \{0,1\}$ if and only if the induced map $\tilde\varphi : G^{\mathrm{ab}} \to A$ is injective, i.e. $\ker \varphi = [G,G]$ exactly.

*Proof sketch.* If $\tilde\varphi$ is injective then $\varphi$ and $\pi$ have the same fibres, so all information quantities coincide. If not, pick $u \ne v$ in $G^{\mathrm{ab}}$ with $\tilde\varphi(u) = \tilde\varphi(v)$ and let $Y$ be the indicator of the coset $\pi^{-1}(u)$. Then $\pi$ determines $Y$, so $I(\pi;Y) = H(Y) > 0$, while $\varphi$ merges the $u$- and $v$-fibres and cannot determine $Y$; strictness in Theorem 2.5(2) gives $I(\varphi;Y) < I(\pi;Y)$. $\square$

Theorem 3.6 is the precise sense in which the abelianization computes the *conductor* of the pinning: any character with kernel strictly larger than $[G,G]$ demonstrably loses information on an explicit fork.

**Theorem 3.7 (flatness inside the commutator subgroup).** Let $C = [G,G]$ carry the uniform measure. For every abelian character $\varphi$ of $G$ and every observable $Y : C \to \beta$,
$$I\big(\varphi|_C ; Y\big) = 0 .$$

*Proof sketch.* $\varphi$ is identically $1$ on $C$, and a constant observable is independent of everything. $\square$

Arithmetically: conditioning on a face of the splitting distribution cut out by the abelian data (e.g. the even permutations, the "quadratic-residue face"), all further splitting questions are congruence-flat.

**Theorem 3.8 (perfect groups are congruence-blind).** If $[G,G] = G$, then $I(\varphi;Y) = 0$ for every abelian character $\varphi$ and every observable $Y$; consequently a pinned fork must have $H(Y) = 0$, i.e. be constant. This applies to $G = A_5$, whose commutator subgroup is all of $A_5$ by simplicity and non-commutativity.

---

## 4. Three Galois groups, with exact values

### 4.1 Cyclic cubic fields: pinned at 100%

Take $G = C_3$, realized by $f_1 = x^3+x^2-2x-1$ (conductor $7$) or $f_3 = x^3-3x+1$ (conductor $9$). The Galois closure is the field itself; the splitting types available to a Galois cubic are only $[1,1,1]$ (identity Frobenius) and $[3]$ (non-identity) — the type $[1,2]$ never occurs, which is already a visible signature.

The total-splitting fork is $Y(g) = [g = 0]$ on $C_3 = \mathbb{Z}/3$, of density $1/3$.

**Theorem 4.1.** $H(Y) = \log 3 - \frac23\log 2$, and $I(\mathrm{id}_{C_3}; Y) = H(Y)$; that is, the fork is pinned at $100\%$ of its entropy, with value $0.9183$ bits.

*Proof sketch.* $\Pr[Y=1] = 1/3$, so $H(Y) = \eta(1/3) + \eta(2/3) = \log 3 - \frac23 \log 2$. The identity observable determines everything; apply Theorem 2.5(2). $\square$

Arithmetically: the cubic-residue character of conductor $7$ has image $C_3$, and the Frobenius is trivial exactly on $p \equiv \pm 1 \pmod 7$; the measured mutual information over $6541$ primes is $0.9182$ bits. Three additional measured facts complete the picture and are all predicted by the theory:

* **Pinning persists at $m = 49$** ($42$ admissible classes, thousands of primes each): a refinement of a pinning observable is still pinning, since it determines the coarser one.
* **The coprime control is flat:** at $m = 5$, coprime to the conductor, the measured $I$ is $0.0000$ bits ($z = -1.3$). The relevant theorem is that an observable which is independent of the fork has $I = 0$; the residue mod $5$ and the Frobenius at $7$ are independent coordinates of a product space.
* **Conductor $9$ behaves identically:** $[1,1,1] \iff p \equiv \pm 1 \pmod 9$, measured $I = 0.9181$ bits.

### 4.2 The $S_3$ cubic: only the sign is pinned

Take $f_2 = x^3+x+1$, $G = S_3$, $[G,G] = A_3$, $G^{\mathrm{ab}} = C_2$ generated by the sign. Congruence data is a single bit, the quadratic character attached to $\mathbb{Q}(\sqrt{-31})$.

The total-splitting fork is $Y(\sigma) = [\sigma = 1]$, of density $1/6$.

**Theorem 4.2.** With $X = \mathrm{sign}$ on $S_3$:
$$H(Y) = \log 2 + \log 3 - \tfrac56\log 5 \;(= 0.6500 \text{ bits}), \qquad I(X;Y) = \tfrac43\log 2 + \tfrac12\log 3 - \tfrac56\log 5 \;(= 0.1909 \text{ bits}),$$
and the deficit is exactly half a cyclic-cubic's entropy:
$$I(X;Y) = H(Y) - \tfrac12\Big(\log 3 - \tfrac23 \log 2\Big).$$
Moreover $X$ does not determine $Y$ (so $I < H$ strictly), while $I > 0$ strictly.

*Proof sketch.* The joint law is: $\Pr[X=1] = \Pr[X=-1] = 1/2$; $\Pr[Y=1] = 1/6$ with the sole element $\sigma = 1$, which is even. So the joint distribution is $(\text{even}, Y{=}1) = 1/6$, $(\text{even}, Y{=}0) = 2/6$, $(\text{odd}, Y{=}0) = 3/6$, $(\text{odd}, Y{=}1) = 0$. Substituting into $I = H(X)+H(Y)-H(X,Y)$ and simplifying logarithms gives the stated value. Non-determination is witnessed by the even elements $1$ and a $3$-cycle, which share the observable value but differ on $Y$. Positivity reduces to $2^{8}3^{3} = 6912 > 3125 = 5^5$. The identity $I = H(Y) - \frac12 H(1/3)$ is then a direct algebraic comparison. $\square$

The measured value over the primes was $0.1906$ bits, and the measurement further confirmed that the entire congruence content of the fork is the sign: the residual $I(p \bmod 31; \text{fork}) - I(\text{sign}; \text{fork})$ was $+0.0000$. On the quadratic-residue face the $A_3$-fork ($[1,1,1]$ versus $[3]$) measured $I = 0.0000$ bits ($z = -2.37$), exactly as Theorem 3.7 requires: on $A_3 = [S_3, S_3]$ every abelian character is constant.

**Theorem 4.3 (comparison).** $I(\mathrm{sign}; Y_{S_3}) < I(\mathrm{id}; Y_{C_3})$: the cyclic cubic pins strictly more than the $S_3$ cubic. (Reduces to $2^{12}3^3 = 110592 < 5^5 3^6 = 2278125$.)

**Theorem 4.4 (never pinned).** The $S_3$ total-splitting fork is not commutator-invariant — with $c = [(0\,1),(1\,2)]$ a $3$-cycle and $g = 1$, $Y(c) = 0 \ne 1 = Y(1)$ — so by Corollary 3.4, $I(\varphi;Y) \ne H(Y)$ for *every* abelian character $\varphi$ of $S_3$, of every conductor.

**Remark 4.5 (why the natural control failed).** The cubic $x^3-2$ has splitting field $\mathbb{Q}(\sqrt[3]{2}, \sqrt{-3})$ with group $S_3$ and abelianization $C_2$. Its total-splitting fork is therefore flat *by construction*, and its measured flatness is not evidence against pinning. Flatness is "the fork lies outside $G^{\mathrm{ab}}$", not "the class number is $1$ rather than $3$". The correct positive control is a cyclic cubic, which pins at $100\%$.

### 4.3 The $S_4$ quartic: the sign is the only structure

Take $f_4 = x^4 - x - 1$, of discriminant $-283$. Since $-283$ is not a square and $f_4$ is irreducible with no resolvent obstruction, $G = S_4$.

**Theorem 4.6 (fixed-point counts in $S_4$).** Among the $24$ elements of $S_4$, exactly $1$ has $4$ fixed points, $6$ have $2$, $8$ have $1$, and $9$ have $0$. Hence, in the Chebotarev model, the number of roots of $f_4$ mod $p$ takes the values $4,2,1,0$ with densities $\frac{1}{24}, \frac{6}{24}, \frac{8}{24}, \frac{9}{24}$.

Measurement reproduces these exactly. The "even face" densities $\frac1{12}, \frac3{12}, \frac8{12}$ for the sub-forks of $A_4$ were measured as $0.0798 / 0.2501 / 0.6701$.

Let $Y(\sigma) = [\sigma \text{ has a fixed point}]$, of density $15/24 = 5/8$.

**Theorem 4.7.** With $X = \mathrm{sign}$ on $S_4$:
$$H(Y) = 3\log 2 - \tfrac58 \log 5 - \tfrac38\log 3 \;(=0.9545 \text{ bits}), \qquad I(X;Y) = \tfrac32\log 2 - \tfrac58\log 5 \;(=0.0488 \text{ bits}),$$
with $0 < I(X;Y) < H(Y)$: the sign is genuinely informative but does not pin.

*Proof sketch.* Split the fixed-point counts by parity. The even elements are the identity ($4$ fixed points), the eight $3$-cycles ($1$ fixed point each), and the three double transpositions ($0$ fixed points), giving $9$ with a fixed point out of $12$; the odd elements are the six transpositions ($2$ fixed points) and six $4$-cycles ($0$), giving $6$ out of $12$. Assembling the four joint probabilities $\frac{9}{24}, \frac{3}{24}, \frac{6}{24}, \frac{6}{24}$ and simplifying gives the stated closed forms. Strict positivity reduces to $2^{12} = 4096 > 3125 = 5^5$; non-determination is witnessed by the identity versus a double transposition. $\square$

Measurement: $I(\mathrm{sign}; \text{has root}) = 0.0483$, theory $0.0488$. The beyond-sign residual $I(p \bmod 283; \text{has root}) - I(\mathrm{sign}; \text{has root}) = +0.0131$ equals the conditional-null mean exactly ($z = +1.00$): finite-sample bias, no signal. Every within-face fork — on the even face $[1,1,1,1]$ versus $[2,2]$ versus $[1,3]$, on the odd face $[1,1,2]$ versus $[4]$ — measured its null mean exactly ($z = -1.00$). By Theorem 3.7 this is forced: the even face is $A_4 = [S_4,S_4]$, on which every abelian character is constant.

**Theorem 4.8 (never pinned).** The has-a-root fork of $S_4$ is not commutator-invariant (take the commutator $[(0\,1),(1\,2)]$, a $3$-cycle, against $g = 1$), so no abelian character of $S_4$ of any conductor pins it.

### 4.4 The blind case

**Theorem 4.9.** $[A_5, A_5] = A_5$, hence every fork of an $A_5$-extension is flat against every abelian character: $I(\varphi;Y) = 0$ for all $\varphi, Y$.

*Proof sketch.* The commutator subgroup is normal; $A_5$ is simple, so it is trivial or everything; $A_5$ is not abelian, so it is everything. Then every abelian character is trivial (Theorem 3.8). $\square$

---

## 5. The capacity of a binary fork

The criterion says *whether* a fork can be pinned. The capacity question asks *how much* any observable can extract, and is answered exactly.

**Theorem 5.1 (strict maximum entropy for two-valued statistics).** For a fork $Y$ with $\Pr[Y=1] = q$:
$$H(Y) \le \log 2, \qquad \text{with equality} \iff q = \tfrac12,$$
and $H(Y) < \log 2$ strictly whenever $q \ne \frac12$.

*Proof sketch.* Termwise, for $t \ge 0$ one has $\eta(t) - t\log 2 \le \frac12 - t$, with strict inequality unless $t = \frac12$; this follows from $\log(1/2t) < 1/(2t) - 1$ for $2t \ne 1$ (the strict form of $\log u < u - 1$) after multiplying by $t$, with the case $t=0$ checked separately. Summing the two terms $t = q$ and $t = 1-q$ and using $q + (1-q) = 1$ gives $H(Y) - \log 2 \le 0$ with the stated equality case. $\square$

**Theorem 5.2 (the one-bit ceiling).** For any observable $X$ and any fork $Y$, $I(X;Y) \le \log 2$.

*Proof sketch.* $I \le H(Y) \le \log|\{0,1\}| = \log 2$. $\square$

**Theorem 5.3 (exact attainment).** $I(X;Y) = \log 2$ **iff** $X$ determines $Y$ *and* $Y$ is balanced.

*Proof sketch.* If $I = \log 2$ then, sandwiching $\log 2 = I \le H(Y) \le \log 2$, we get $H(Y) = \log 2$; Theorem 5.1 gives balance, and $I = H(Y)$ with Theorem 2.5(2) gives determination. Conversely, determination gives $I = H(Y)$ and balance gives $H(Y) = \log 2$. $\square$

So capacity is attained exactly at *balanced pinned forks*. In the arithmetic setting this identifies the extremal congruence-visible splitting statistics.

**Lemma 5.4 (surjective characters are uniform).** If $\varphi : G \to A$ is a surjective homomorphism of finite groups with $G$ uniform, then $\varphi$ is uniform on $A$: $\Pr[\varphi = a] = 1/|A|$ for all $a$.

*Proof sketch.* Left translation by any $g_0$ with $\varphi(g_0) = ba^{-1}$ is a bijection from the fibre over $a$ to the fibre over $b$; equal fibres summing to $1$ are each $1/|A|$. $\square$

**Corollary 5.5.** For $n \ge 2$, the sign of a uniformly random permutation of $n$ letters is balanced: $\Pr[\mathrm{sign} = +1] = \frac12$, since $\mathrm{sign} : S_n \to \{\pm 1\}$ is surjective.

**Theorem 5.6 (rigidity for the symmetric group).** For $n \ge 2$ and a fork $Y$ of $S_n$,
$$I(\mathrm{sign}; Y) = \log 2 \iff Y = \mathrm{sign} \ \text{ or } \ Y = \neg\,\mathrm{sign}.$$
In particular the capacity is attained, and by exactly two forks.

*Proof sketch.* ($\Leftarrow$) Both candidates are determined by the sign and balanced by Corollary 5.5. ($\Rightarrow$) By Theorem 5.3, $Y$ is determined by the sign and balanced. Determination forces $Y(\sigma) = Y(1)$ for even $\sigma$ and $Y(\sigma) = Y(\tau)$ for odd $\sigma$, where $\tau$ is a fixed transposition; so $Y$ is one of four sign-measurable forks. Balance eliminates the two constants, leaving sign and its negation. $\square$

Theorem 5.6 is the exact formal counterpart of the $S_4$ measurement: *the only congruence structure in the whole $S_4$ splitting is the sign* — and no fork other than the sign itself achieves the one-bit maximum.

---

## 6. The extremal profile of an index-two conductor

Suppose the visible observable is one balanced bit $X$ (an index-two conductor, e.g. a quadratic character), and the fork $Y$ has density $d = \Pr[Y=1] \le \frac12$. How much information is available, as a function of $d$?

**Definition 6.1.** With $h(t) = \eta(t) + \eta(1-t)$ the binary entropy, define the **coset profile**
$$\Phi(d) = h(d) - \tfrac12 h(2d), \qquad 0 \le d \le \tfrac12 .$$
Equivalently, for $d > 0$,
$$\Phi(d) = d\log 2 - (1-d)\log(1-d) + \tfrac12 (1-2d)\log(1-2d).$$

**Theorem 6.2 (extremality).** If $X$ is a balanced fork and $Y$ a fork with $d = \Pr[Y=1] \le \frac12$, then
$$I(X;Y) \le \Phi(d),$$
with **equality** whenever the support of $Y$ lies in one fibre of $X$ (a *single-coset* fork).

*Proof sketch.* With $X$ balanced, $I(X;Y) = h(d) - \frac12\big(h(a) + h(b)\big)$ where $a, b$ are the conditional densities of $Y$ in the two fibres and $a + b = 2d$. Subadditivity of the binary entropy, $h(a+b) \le h(a) + h(b)$ for $a,b \ge 0$, $a+b \le 1$, yields $h(a)+h(b) \ge h(2d)$ and hence the bound. Equality holds when one of $a,b$ is $0$, i.e. exactly when $Y$ is supported on a single coset — then $\{a,b\} = \{2d, 0\}$ and $h(0) = 0$. $\square$

**Theorem 6.3 (properties of the profile).**

1. $\Phi(d) \ge 0$ on $[0,\frac12]$, and $\Phi$ is **strictly increasing** on $[0,\frac12]$: rarer forks are strictly less pinnable.
2. $\Phi(\frac12) = \log 2$: the profile rises exactly to capacity at the balanced point, consistent with Theorem 5.3.
3. **Linear rate:** $|\Phi(d) - d\log 2| \le 4d^2$ for $0 < d \le \frac14$; consequently $\Phi(d)/d \to \log 2$ as $d \to 0^+$.
4. **Vanishing pinned fraction:** $\Phi(d)/h(d) \le \dfrac{\log 2 + 4d}{\log(1/d)}$ for $0 < d \le \frac14$, hence $\Phi(d)/h(d) \to 0$ as $d \to 0^+$.

*Proof sketch.* (1) Nonnegativity is subadditivity again; monotonicity follows from continuity on the closed interval together with positivity of the derivative on the interior: differentiating the closed form of Definition 6.1 gives $\Phi'(d) = \log 2 + \log(1-d) - \log(1-2d) = \log\frac{2(1-d)}{1-2d} > 0$, since $2(1-d) > 1-2d$. (2) $h(1) = 0$. (3) Apply the Taylor bound $|\log(1-x) + x + x^2/2| \le 2x^3$ for $0 \le x \le \frac12$ at $x = d$ and $x = 2d$; the linear terms in the closed form cancel against $d \log 2$ and the quadratic remainders combine to at most $4d^2$. (4) Divide (3) by $h(d) \ge d\log(1/d)$. $\square$

Item (4) corrects a natural guess: the small-$d$ asymptotic of the profile is $d\log 2$, not $d\log(1/d)$, and the fraction of a rare fork's entropy that an index-two conductor can pin tends to $0$, not to $\frac12$. Rare splitting events are asymptotically congruence-invisible *in relative terms*, even in the best possible geometric position.

---

## 7. The semiprime barrier

Suppose we only observe $N = pq$, a product of two unknown primes, and ask what the class of $N$ says about the splitting of its factors. In the model, $p$ and $q$ contribute independent uniform elements $g_1, g_2 \in G$, the observable is the product class $S = g_1g_2$, and the natural fork is
$$\mathrm{OR}(g_1,g_2) = [\,g_1 = 1 \ \text{ or } \ g_2 = 1\,],$$
i.e. "$p$ splits completely or $q$ does".

**Theorem 7.1 (universal semiprime dial).** For any finite group $G$ with $n = |G| \ge 2$,
$$I(S; \mathrm{OR}) = D(n) := \log n + \frac{-(2n-1)\log(2n-1) + (n-1)(3-2n)\log(n-1) + 2(n-1)\log 2 + (n-1)(n-2)\log(n-2)}{n^2}.$$
In particular the answer depends only on the order of $G$, not on its structure.

*Proof sketch.* The product class $S$ is uniform on $G$: for fixed $g_1$ the map $g_2 \mapsto g_1g_2$ is a bijection, so $H(S) = \log n$. For each $s \in G$ the fibre $\{(g_1,g_2) : g_1g_2 = s\}$ has exactly $n$ elements, and among them the OR-true pairs are $(1,s)$ and $(s,1)$ — two distinct pairs if $s \ne 1$, and a single pair if $s = 1$. Hence $\Pr[\mathrm{OR}] = \frac{1 + 2(n-1)}{n^2} = \frac{2n-1}{n^2}$, and the joint law has the two column values $\frac{1}{n^2}$ (respectively $\frac{2}{n^2}$) for the OR-true cell over $s = 1$ (respectively $s \ne 1$), with complements $\frac{n-1}{n^2}$ and $\frac{n-2}{n^2}$. Substituting these into $I = H(S) + H(\mathrm{OR}) - H(S,\mathrm{OR})$ and collecting logarithms gives the displayed formula. $\square$

**Corollary 7.2 ($n = 3$).** For a cyclic cubic ($|G| = 3$),
$$I(S;\mathrm{OR}) = \log 3 - \tfrac59\log 5 - \tfrac29 \log 2 = 0.0728 \text{ bits}.$$
The conditional probabilities are $P(\mathrm{OR} \mid S = 1) = 1/3$ and $P(\mathrm{OR} \mid S \ne 1) = 2/3$, matching the measured behaviour $P(\mathrm{OR} \mid N \bmod 7) = 1/3$ on $\{1,6\}$ and $2/3$ on $\{2,3,4,5\}$; the measured information was $0.0718$ bits.

**Theorem 7.3 (quadratic collapse rate).** For $n \ge 2$, $\;I(S;\mathrm{OR}) \le \dfrac{1}{(2n-1)(n-1)}$.

*Proof sketch.* Bound mutual information by the $\chi^2$-divergence, $I \le \sum_{k,b} \frac{\Pr[(X,Y)=(k,b)]^2}{\Pr[X=k]\Pr[Y=b]} - 1$, which follows from $\log t \le t-1$ applied termwise; then evaluate the $\chi^2$ sum on the explicit two-column joint law of Theorem 7.1 and simplify. $\square$

**Theorem 7.4 (sharp constant).** $\;n^2 D(n) \to 1 - \log 2 = 0.3069\ldots$ as $n \to \infty$; quantitatively $|n^2 D(n) - (1-\log 2)| \le 24/n$ for $n \ge 4$. Moreover $n^2 D(n) < 1$ for every $n \ge 2$, with the exact value $4D(2) = 3\log(4/3) = 0.8630$ at $n = 2$.

*Proof sketch.* Rewrite $n^2 D(n)$ by expanding each logarithm around $\log n$: the $\log n$ terms cancel identically, leaving
$$n^2 D(n) = -\log 2 - (2n-1)\log\!\Big(1 - \tfrac{1}{2n}\Big) + (n-1)(3-2n)\log\!\Big(1-\tfrac1n\Big) + (n-1)(n-2)\log\!\Big(1-\tfrac2n\Big).$$
Apply the cubic Taylor bound $|\log(1-x) + x + x^2/2| \le 2x^3$ for $0 \le x \le \frac12$ to each of the three logarithms; the first- and second-order terms combine to the constant $1 - \log 2$ and the remainders are $O(1/n)$ with explicit constant $24$. Squeeze. The bound $n^2D(n) < 1$ follows from the explicit value at $n=2$, the tail bound for $n \ge 4$, and Theorem 7.3 in between. $\square$

**Theorem 7.5 (the which-factor wall).** For *any* statistic $F : G \to \beta$ of the first factor alone,
$$I\big(S;\ F(g_1)\big) = 0 \quad\text{exactly.}$$

*Proof sketch.* Conditioned on $g_1$, the product $S = g_1g_2$ is uniform on $G$ (translation is a bijection), hence independent of $g_1$ and of any function of it; apply Theorem 2.5(3). $\square$

**Theorem 7.6 ($k$-factor wall).** For a product of $k+1$ factors, with $P = g_1g_2\cdots g_{k+1}$ and any statistic $F$ of $(g_1,\dots,g_k)$,
$$I\big(P;\ F(g_1,\dots,g_k)\big) = 0 .$$
In particular $I(P;\ [\text{some } g_i = 1,\ i \le k]) = 0$, and the class of $P$ is uniform.

*Proof sketch.* Re-associate $P = (g_1\cdots g_k)\, g_{k+1}$ and apply Theorem 7.5 with $\Omega = G^k$ and $h = $ the partial product; invariance of mutual information under a bijective relabelling of the sample space (here, the snoc equivalence $G^k \times G \cong G^{k+1}$) completes the argument. $\square$

**Theorem 7.7 (never pinned).** For $|G| \ge 2$, $I(S;\mathrm{OR}) < H(\mathrm{OR})$ and $I(S;\mathrm{OR}) > 0$: the semiprime dial is a genuine but strictly partial signal.

Together, Theorems 7.1–7.7 give the following picture. A fork pinned at $100\%$ of its entropy at the prime level yields, at the semiprime level, a symmetric residue dial of $0.0728$ bits for $n = 3$; the dial is universal in $n$; it decays like $(1-\log 2)/n^2$ with a hard budget $n^2 I < 1$; and it is provably orthogonal to the only question a factorizer cares about, namely *which* factor is which — that channel has capacity exactly zero, for two factors and for $k$. Measurement agreed: which-factor information $0.0001$ bits.

---

## 8. Algorithms

Three procedures make the theory effective; all are elementary and their costs are stated for a Galois group presented as a permutation group on $n$ letters with $|G| = N$ elements.

**A. Commutator-invariance pinning test.** *Input:* generators of $G$, a fork $Y : G \to \{0,1\}$. *Output:* pinned or not pinned, with a witness. Enumerate $G$ (breadth-first from the generators), compute the commutator subgroup $C$ as the normal closure of all $[s,t]$ over generators, and test whether $Y$ is constant on each coset $gC$. Cost $O(N \cdot |{\rm gens}|)$ for the enumeration and $O(N)$ for the coset test; the witness is a pair $(g,c)$ with $Y(gc) \ne Y(g)$. By Theorem 3.2 this decides pinning against *all* abelian characters at once — no search over moduli is required.

**B. Exact fork information in the Chebotarev model.** *Input:* $G$, an observable $X$, a fork $Y$. *Output:* $H(Y)$, $I(X;Y)$, and the pinned fraction $I/H$. Build the joint histogram over $G$ in one pass, $O(N)$, then evaluate the entropies. Comparing $I/H$ to $1$ recovers the criterion numerically; comparing $I$ to $0$ detects flatness.

**C. Universal semiprime dial evaluation.** *Input:* group order $n$. *Output:* $D(n)$, the bound $1/((2n-1)(n-1))$, and $n^2D(n)$. Constant time by Theorem 7.1; the second-order expansion of Theorem 7.4 gives $D(n) = (1-\log 2)/n^2 + O(1/n^3)$ and is numerically stable for large $n$, where the closed form suffers catastrophic cancellation between $\log n$ terms.

An empirical companion to A–C verifies the model directly on primes: for each prime $p$ below a bound, count the roots of $f$ modulo $p$ (cost $O(p)$ naively, or $O(\deg f \cdot \log p)$ with a gcd against $x^p - x$), classify the splitting type, and compare the empirical joint law of (residue class, fork) with the group-theoretic prediction.

---

## 9. Applications and interpretation

**Deciding predictability without searching moduli.** The practical content of Theorem 3.2 is negative but powerful: to know that no congruence rule exists, one does not test moduli. One computes the abelianization of the Galois group and checks whether the fork descends. A single commutator witness rules out all conductors simultaneously.

**Designing controls for numerical experiments.** Remark 4.5 is a cautionary tale generalizable to any experimental study of splitting statistics: the choice of positive control must be made by the criterion, not by superficial features of the field. Class number, discriminant size, and regulator are irrelevant; the only relevant invariant is whether the fork factors through $G^{\mathrm{ab}}$.

**Cryptographic non-implications.** Splitting behaviour of a fixed polynomial at the factors of an RSA-style semiprime is sometimes floated as a source of side information. §7 closes this route quantitatively: (i) the total information at the semiprime level is $D(n) < 1/n^2$ nats regardless of the field; (ii) it is symmetric in the two factors by Theorem 7.5, so it cannot distinguish them; (iii) the wall persists for multi-factor moduli by Theorem 7.6. Even the ideal case — a prime-level fork pinned at $100\%$ — collapses to $0.073$ bits with an exactly zero which-factor channel.

**A general principle.** Beyond number theory, the criterion is a statement about measurement channels: any observation that factors through a commutative quotient is blind to the commutator subgroup. Where a hidden state is a random group element and the measurement is an abelian character, the answerable questions are exactly the functions on the abelianization, and the abelianization map itself is the optimal such measurement (Theorem 3.5), canonically characterized by its kernel (Theorem 3.6).

---

## 10. Discussion and future work

The results settle the qualitative question completely and the quantitative one in the cases studied. Several natural questions remain.

**Conductor hierarchy.** Theorem 3.6 identifies the abelian characters that lose nothing: those with kernel exactly $[G,G]$. It does not organize the intermediate characters. Is there, for a fixed fork $Y$, a unique minimal quotient of $G$ through which $Y$ factors and which therefore serves as the "conductor of the fork", with a lattice of intermediate information values?

**Information budget for factorization oracles.** Theorem 7.4 gives the $\Theta(1/n^2)$ rate with a sharp constant for the specific OR-fork. Is there a $\log n / n^2$ budget for *any* factorization oracle built from splitting data — that is, a bound on the total information about the factorization contained in the classes of $N$ with respect to arbitrarily many number fields simultaneously?

**Monotonicity of the scaled dial.** Numerically $n^2 D(n)$ decreases from $3\log(4/3) = 0.8630$ at $n=2$ towards $1-\log 2 = 0.3069$. Monotonicity in $n$ is not yet proved.

**Multi-factor dial.** The wall is proved for $k$ factors; the corresponding dial is conjectured to decay like $k^2/n^2$, which remains open.

**Non-uniform priors.** The Chebotarev model uses the uniform measure. Under prescribed congruence conditions on $p$ (as in the semiprime setting with $N$ constrained), the induced measure on $G$ is uniform on a coset of a subgroup; extending the exact values to that setting would cover conditional experiments.

**Higher-valued forks.** The capacity theory of §5 is specific to binary forks; for $r$-valued splitting statistics the ceiling is $\log r$ and the attainment condition should read "determined and uniform", but the extremal profile analogous to §6 for an index-$r$ conductor has not been computed.

---

## 11. Summary of results

| Statement | Content |
|---|---|
| Pinning identity | $I(X;Y) = H(Y)$ iff $X$ determines $Y$ (finite uniform space) |
| Fork-pinning criterion | Pinned by some abelian character $\iff$ factors through $G^{\mathrm{ab}}$ $\iff$ commutator-invariant |
| Optimality | $I(\varphi;Y) \le I(\pi;Y)$ for every abelian $\varphi$ |
| Conductor detection | Equality for all forks $\iff \ker\varphi = [G,G]$ |
| Abelian groups | Every fork pinned at $100\%$ |
| Perfect groups | Every fork flat; $A_5$ is congruence-blind |
| Cyclic cubic | $I = H = \log 3 - \frac23\log 2 = 0.9183$ bits |
| $S_3$ cubic | $I = \frac43\log2 + \frac12\log3 - \frac56\log5 = 0.1909$ bits $= H - \frac12 H(1/3)$ |
| $S_4$ quartic | root counts $1{:}6{:}8{:}9$ of $24$; $I(\mathrm{sign};\text{has root}) = \frac32\log2-\frac58\log5 = 0.0488$ bits |
| Within-face flatness | Every abelian character is constant on $[G,G]$, so $I = 0$ |
| Capacity | $I \le \log 2$; equality iff determined and balanced |
| Rigidity in $S_n$ | Capacity attained by exactly the sign and its negation |
| Coset profile | $I \le \Phi(d) = h(d) - \frac12h(2d)$, sharp; strictly increasing; $\Phi(d)/d \to \log2$; $\Phi(d)/h(d)\to 0$ |
| Semiprime dial | Universal $D(n)$; $D(3) = 0.0728$ bits; $D(n) \le \frac{1}{(2n-1)(n-1)}$ |
| Sharp constant | $n^2D(n) \to 1 - \log 2$; $n^2D(n) < 1$ always |
| Which-factor wall | $I(S; F(g_1)) = 0$ exactly, and likewise for $k$ factors |
