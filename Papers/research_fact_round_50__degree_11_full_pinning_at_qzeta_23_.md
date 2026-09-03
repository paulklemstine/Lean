# Full Pinning and Strict Decay on the Abelian Splitting-Type Ladder

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

We study the information carried by residue data about the splitting behaviour of primes in abelian number fields, organised as a *ladder* of real cyclotomic fields $\mathbb{Q}(\zeta_f)^{+}$ of prime degree. Our results are of three kinds.

First, we prove a **universal pinning theorem**: for any finite abelian group $G$ and any subgroup $H$, the type read-out $u \mapsto \operatorname{ord}(uH)$ in $G/H$ is a function of the class $uH$, so the conditional entropy of the type given the class vanishes identically and the mutual information equals the full type entropy. This converts an exceptionless empirical record at degrees $2,3,5,7,11$ into a theorem valid at every degree and for every abelian extension.

Second, we prove that pinning is **exactly measurability**: for a finite sample space, a read-out $T$ and a side channel $k$, the conditional entropy $H(T\mid k)$ vanishes if and only if $k$ determines $T$ pointwise. The quantitative core is that a non-constant read-out on a finite set has strictly positive counting entropy. We instantiate the criterion at degree $11$ in $\mathbb{Q}(\zeta_{23})^{+}$ and exhibit an explicit *failing* channel: the quadratic character mod $23$, which merges the split class $1$ with the inert class $2$ (since $5^2 \equiv 2 \bmod 23$) and in fact carries exactly zero information about the splitting type, by a coprimality (Chinese-Remainder) argument.

Third, we determine the **shape of the ladder**. The prime-degree type entropy has the closed form $H(T_q) = \log_2 q - \frac{q-1}{q}\log_2(q-1)$; it satisfies the sandwich $\log_2 q / q \le H(T_q) \le (\log_2 q + 1/\ln 2)/q$; and its real interpolation $h(x) = \log_2 x - \frac{x-1}{x}\log_2(x-1)$ has the exact derivative $h'(x) = -\ln(x-1)/(x^2\ln 2)$, hence is strictly antitone on $[2,\infty)$. Consequently the ladder **strictly decays along the primes**, degree $2$ is the unique rung carrying a full bit, and every higher rung is strictly positive and strictly below one bit.

Along the way we establish the degree-$11$ arithmetic law ($p$ splits completely in $\mathbb{Q}(\zeta_{23})^{+}$ iff $p \equiv \pm 1 \bmod 23$), the certified bracket $0.4394 < H(T_{11}) < 0.4396$, and the exact $\mathrm{Bin}(2,1/q)$ law for the semiprime split count, with the closed-form split-count channel $I_{\mathrm{split}}(11) = \log_2 11 + (180\log_2 3 - 210 \log_2 5 - 210)/121 = 0.05190\ldots$, certified in $(0.0516, 0.0521)$ — less than half of the value $0.116$ that had been predicted for it in advance.

**Keywords:** real cyclotomic fields, Frobenius splitting type, Artin symbol, Shannon entropy, mutual information, abelian extensions, quadratic character, binomial split law.

---

## 1. Introduction

### 1.1 The question

Let $K/\mathbb{Q}$ be a finite abelian extension of conductor $f$. Class field theory attaches to each unramified prime $p$ its Artin class, an element of a quotient of $(\mathbb{Z}/f)^\times$, and the splitting behaviour of $p$ in $K$ — how many primes lie above it, and with what residue degree — is determined by that class. This is a statement of *determination*: nothing about the splitting type is invisible to the residue $p \bmod f$.

Determination has an information-theoretic shadow. Model the class as a uniform random variable on the Galois group and let $T$ denote the induced splitting-type read-out. Then determination says
$$I(\text{class} \,;\, T) = H(T),$$
i.e. the class channel is *lossless* for $T$. We call this **full pinning**.

The interest of the statement is not that it is hard — it is not — but that it is *sharp, quantitative, and testable*, and that it invites three questions that are genuinely open before one does the work:

1. **Universality.** Empirical surveys of pinning at degrees $2, 3, 5, 7, 11$ report no exceptions. Is this a theorem, and if so with what hypotheses?
2. **Sharpness.** Is the identity $I = H(T)$ evidence for anything, or would any reasonable channel produce it? Equivalently: what exactly must a channel do to be lossless, and are there natural arithmetic channels that fail?
3. **Shape.** The numerical rung values $1, 0.9183, 0.7219, 0.5917, 0.4395$ at degrees $2,3,5,7,11$ visibly decrease. Is decay a theorem, at what rate, and is the pattern monotone forever?

This paper answers all three.

### 1.2 The ladder

The ladder we work with is the family of maximal real cyclotomic subfields
$$\mathbb{Q}(\zeta_f)^{+} \;=\; \mathbb{Q}\big(\zeta_f + \zeta_f^{-1}\big), \qquad [\mathbb{Q}(\zeta_f)^{+} : \mathbb{Q}] = \tfrac{\varphi(f)}{2},$$
whose Galois group is $(\mathbb{Z}/f)^\times / \{\pm 1\}$. When $f = 2q+1$ is prime and $q$ is also prime (so $f$ is a *safe prime*), the degree is exactly the prime $q$, and the Galois group is cyclic of order $q$. The small rungs are

| degree $q$ | conductor $f = 2q+1$ | field |
|---|---|---|
| $2$ | $5$ | $\mathbb{Q}(\zeta_5)^{+} = \mathbb{Q}(\sqrt5)$ |
| $3$ | $7$ | $\mathbb{Q}(\zeta_7)^{+}$ |
| $5$ | $11$ | $\mathbb{Q}(\zeta_{11})^{+}$ |
| $11$ | $23$ | $\mathbb{Q}(\zeta_{23})^{+}$ |

(Degree $7$ is realised not by a real cyclotomic field of prime conductor — $15$ is not prime — but by the unique degree-$7$ subfield of $\mathbb{Q}(\zeta_{29})$, which is abelian and hence covered by the universal theorem of §3. The abstract type channel of §2.3, which is what the entropy numbers refer to, is defined for every prime degree regardless of realisability by a safe prime.)

The **degree-$11$ rung** $\mathbb{Q}(\zeta_{23})^{+}$ is the subject of the arithmetic computations below.

### 1.3 Summary of results

* **Theorem A (Universal abelian pinning).** For any finite abelian $G$ and subgroup $H$, the class channel is lossless for the type: $H(T \mid \text{class}) = 0$ and $I(\text{class}; T) = H(T)$.
* **Theorem B (Sharpness).** $H(T \mid k) = 0$ if and only if $k$ determines $T$ pointwise; in particular, if $k$ merges a split with an inert class then $I(k;T) < H(T)$ strictly.
* **Theorem C (Degree-11 arithmetic law).** For $p$ coprime to $23$: $p$ splits completely in $\mathbb{Q}(\zeta_{23})^{+}$ iff $p \equiv \pm 1 \bmod 23$; otherwise the residue degree is $11$.
* **Theorem D (Zero information from the Legendre channel).** The quadratic character mod $23$ has mutual information exactly $0$ with the degree-$11$ splitting type.
* **Theorem E (Binomial split law).** For prime degree $q$, the number of split factors of a semiprime is distributed as $\mathrm{Bin}(2, 1/q)$ exactly, with counts $\big((q-1)^2,\, 2(q-1),\, 1\big)$ out of $q^2$; at $q=11$, $(100, 20, 1)$ out of $121$.
* **Theorem F (Split-count channel).** A closed form for $I_{\mathrm{split}}(q)$, giving $I_{\mathrm{split}}(11) = 0.05190\ldots \in (0.0516, 0.0521)$.
* **Theorem G (Sandwich).** $\log_2 q/q \le H(T_q) \le (\log_2 q + 1/\ln 2)/q$ for every prime $q$.
* **Theorem H (Strict decay).** $h'(x) = -\ln(x-1)/(x^2\ln 2)$, hence $h$ is strictly antitone on $[2,\infty)$ and $H(T_q) < H(T_p)$ for primes $p<q$; degree $2$ is the unique rung with a full bit.

---

## 2. The information-theoretic framework

### 2.1 Counting entropy

All our probability is uniform on a finite set, so entropies are *counting* quantities.

**Definition 2.1 (Counting entropy).** Let $S$ be a nonempty finite set and $g : S \to B$ a read-out. Write $N = |S|$ and, for $x \in S$, let $n_{g(x)} = |g^{-1}(g(x))|$ be the size of the fibre through $x$. Define
$$H(S, g) \;=\; \log_2 N \;-\; \frac1N \sum_{x \in S} \log_2 n_{g(x)}.$$

**Lemma 2.2.** $H(S,g)$ is the Shannon entropy of the push-forward of the uniform measure on $S$ under $g$:
$$H(S,g) \;=\; -\sum_{v \in g(S)} \frac{n_v}{N}\log_2\frac{n_v}{N}.$$

*Proof sketch.* Group the sum over $x$ by fibre: each $v \in g(S)$ contributes $n_v \log_2 n_v$. Then $\log_2 N - \frac1N\sum_v n_v \log_2 n_v = -\sum_v \frac{n_v}{N}(\log_2 n_v - \log_2 N)$. $\square$

The fibre form is what we compute with; the Shannon form is what gives the results their meaning. In particular $H(S,g) \ge 0$ always, with equality precisely when $g$ is constant on $S$.

**Definition 2.3 (Conditional entropy and mutual information).** For read-outs $g : S \to B$ and $k : S \to C$,
$$H(g \mid k) \;=\; \sum_{c \in k(S)} \frac{|k^{-1}(c)|}{|S|}\; H\big(k^{-1}(c),\, g\big), \qquad I(k;g) \;=\; H(S,g) - H(g\mid k).$$

These agree with the classical notions for the uniform measure. Conditional entropy is non-negative, being a convex combination of non-negative terms.

### 2.2 Binary entropy in closed form

**Definition 2.4.** For $0 < m < N$ set
$$B(N,m) \;=\; \log_2 N \;-\; \frac{m\log_2 m + (N-m)\log_2(N-m)}{N}.$$

**Lemma 2.5 (Two-valued read-out).** If $g : S \to B$ takes only the two values $v \ne w$, and $m = |g^{-1}(v)|$ with $0 < m < N = |S|$, then $H(S,g) = B(N,m)$.

**Lemma 2.6 (Scale invariance).** For $c \ge 1$, $B(cN, cm) = B(N,m)$: the counting entropy depends only on the *ratio* $m/N$.

*Proof sketch.* Expand both sides using $\log_2(cx) = \log_2 c + \log_2 x$; the $\log_2 c$ terms cancel because $cm + c(N-m) = cN$. $\square$

Lemma 2.6 is the technical bridge that lets us pass freely between the abstract cyclic model of order $q$ and the arithmetic model inside $(\mathbb{Z}/f)^\times$ of order $2q$: the two computations produce literally the same real number, not merely equal approximations.

We shall use the specialisation
$$B(N,1) \;=\; \log_2 N - \frac{(N-1)\log_2(N-1)}{N}.$$

### 2.3 The abstract type channel

**Definition 2.7 (Type).** For a modulus $q \ge 1$ and an exponent $a \in \{0,\dots,q-1\}$, let $\operatorname{type}_q(a)$ be the order of $a$ in the additive group $\mathbb{Z}/q$, i.e. $q/\gcd(a,q)$. The **type entropy** at degree $q$ is
$$H(T_q) \;=\; H\big(\{0,\dots,q-1\},\; \operatorname{type}_q\big).$$

The interpretation: fix a cyclic Galois group of order $q$, identify Frobenius elements with exponents $a$, and read off the residue degree, which is the order of the Frobenius.

**Lemma 2.8 (Prime dichotomy).** If $q$ is prime and $a < q$ then $\operatorname{type}_q(a) = 1$ if $a = 0$ and $= q$ otherwise. Hence $\{a : \operatorname{type}_q(a)=1\} = \{0\}$.

**Theorem 2.9 (Closed form of the prime-degree entropy).** For $q$ prime,
$$H(T_q) \;=\; B(q,1) \;=\; \log_2 q \;-\; \frac{q-1}{q}\,\log_2(q-1),$$
the Shannon entropy of the two-point distribution $(1/q,\ (q-1)/q)$.

*Proof.* By Lemma 2.8 the read-out is two-valued with one distinguished fibre; apply Lemma 2.5 with $N=q$, $m=1$, then the formula for $B(N,1)$. $\square$

At $q = 11$: $H(T_{11}) = \log_2 11 - \frac{10}{11}\log_2 10$.

---

## 3. Universal abelian pinning

### 3.1 The theorem

**Theorem 3.1 (Universal abelian pinning).** Let $G$ be a finite abelian group, $H \le G$ a subgroup, and define on $G$ the *class* read-out $\kappa(u) = uH \in G/H$ and the *type* read-out $\tau(u) = \operatorname{ord}_{G/H}(uH)$. Then
$$H(\tau \mid \kappa) = 0 \qquad\text{and}\qquad I(\kappa;\tau) = H(G,\tau).$$

*Proof.* If $\kappa(u) = \kappa(v)$ then $uH = vH$, hence $\tau(u) = \operatorname{ord}(uH) = \operatorname{ord}(vH) = \tau(v)$: the type factors through the class. Therefore each fibre $\kappa^{-1}(c)$ is a set on which $\tau$ is constant, so $H(\kappa^{-1}(c), \tau) = 0$; the conditional entropy is a convex combination of zeros. Mutual information is then $H(G,\tau) - 0$. $\square$

### 3.2 What the theorem buys, and what it costs

The proof is short and that is the point: all the mathematics has been moved into the *statement*. Three features deserve comment.

**(i) Commutativity is used exactly once, in the setup.** In an abelian Galois group, the Frobenius attached to an unramified prime is a well-defined single element, not merely a conjugacy class. Consequently "the Artin class of $p$" is a point of a finite abelian group, the decomposition data of a subfield is a fixed subgroup $H$, and the residue degree in the subfield is by definition the order of the image in $G/H$. Every hypothesis of Theorem 3.1 is met.

**(ii) It ends the empirical programme.** "Degrees $2$–$11$ tested, no exceptions" is now a corollary rather than a data set; so is degree $12$, degree $10^6$, and every abelian field of every conductor. There is no possible abelian counterexample.

**(iii) It relocates the frontier.** Since pinning cannot fail in the abelian world, any genuine information defect must be sought where the hypothesis fails: in non-abelian Galois groups, where the Artin symbol is a conjugacy class. There the residue degree is still class-determined, so the honest place to look for a gap is the *abelianised* channel — comparing what an abelian residue observable knows against what the full non-abelian splitting type is. See §8.

### 3.3 The real-cyclotomic rungs, all at once

The abstract statement above is about groups; here is the arithmetic instantiation, proved uniformly in the degree.

**Definition 3.2.** For a modulus $f$, let $\Sigma_f = \{\pm 1\} \le (\mathbb{Z}/f)^\times$ be the sign subgroup, and for a unit $u$ define the **real residue degree** $d_f(u)$ to be the order of $u\Sigma_f$ in $(\mathbb{Z}/f)^\times/\Sigma_f$ — the residue degree of a prime with class $u$ in $\mathbb{Q}(\zeta_f)^{+}$.

**Lemma 3.3.** $d_f(u) = 1$ if and only if $u = \pm 1$. Moreover $d_f(-u) = d_f(u)$: the residue degree is blind to sign.

**Lemma 3.4.** If $f > 2$ is prime then $-1 \ne 1$ in $(\mathbb{Z}/f)^\times$, so $|\Sigma_f| = 2$ and $\big|(\mathbb{Z}/f)^\times/\Sigma_f\big| = (f-1)/2$.

**Theorem 3.5 (Prime-degree rung).** Let $q$ and $f = 2q+1$ both be prime. Then:
1. the Galois group of $\mathbb{Q}(\zeta_f)^{+}$ has order $q$;
2. every unit $u$ satisfies $d_f(u) \in \{1, q\}$ (prime dichotomy);
3. exactly two units, $\pm 1$, have $d_f(u) = 1$, giving split density $2/(f-1) = 1/q$;
4. the Frobenius entropy of the field equals the abstract type entropy:
$$H\big((\mathbb{Z}/f)^\times,\, d_f\big) \;=\; H(T_q).$$

*Proof sketch.* (1) is Lemma 3.4 with $f - 1 = 2q$. (2): $d_f(u)$ divides the group order $q$, which is prime. (3) is Lemma 3.3 together with $-1 \ne 1$. (4): the read-out $d_f$ is two-valued with distinguished fibre of size $2$ inside a set of size $2q$, so by Lemma 2.5 its entropy is $B(2q, 2)$; by scale invariance (Lemma 2.6) $B(2q,2) = B(q,1)$, which is $H(T_q)$ by Theorem 2.9. $\square$

Instantiating at $(q,f) \in \{(2,5), (3,7), (5,11), (11,23)\}$ gives the rungs of degree $2, 3, 5, 11$ as corollaries, the degree-$11$ rung $\mathbb{Q}(\zeta_{23})^{+}$ included. No rung requires separate work.

---

## 4. The degree-11 rung in detail

### 4.1 The arithmetic law

**Theorem 4.1 (Splitting criterion at degree 11).** Let $p$ be an integer coprime to $23$. Then $p$ splits completely in $\mathbb{Q}(\zeta_{23})^{+}$ — equivalently $d_{23}(p) = 1$ — if and only if
$$p \equiv 1 \pmod{23} \quad\text{or}\quad p \equiv -1 \pmod{23}.$$
In all other cases $d_{23}(p) = 11$.

*Proof sketch.* $\big|(\mathbb{Z}/23)^\times\big| = 22$ and $|\Sigma_{23}| = 2$, so the quotient has order $11$, a prime; the order of any class divides $11$, hence is $1$ or $11$. It is $1$ exactly when the class lies in $\Sigma_{23} = \{\pm 1\}$ (Lemma 3.3). $\square$

Two instances: $47 \equiv 1 \bmod 23$, so $47$ splits completely; $2 \not\equiv \pm1 \bmod 23$, so $2$ is inert with $d_{23}(2) = 11$. The latter will matter in §5.

Equivalently, in coordinates: fix a primitive root $g$ mod $23$ and write $p \equiv g^{a}$. Then $\{\pm 1\} = \{g^0, g^{11}\}$, so $p$ splits iff $a \equiv 0 \pmod{11}$ — the "discrete logarithm vanishes mod $11$" form of the law.

### 4.2 The entropy value and its certification

By Theorem 3.5(4) and Theorem 2.9,
$$H(T_{11}) \;=\; \log_2 11 - \tfrac{10}{11}\log_2 10, \qquad 11\,H(T_{11}) = \log_2\!\frac{11^{11}}{10^{10}}.$$

**Theorem 4.2 (Certified bracket).** $\;0.4394 < H(T_{11}) < 0.4396$.

*Proof sketch.* Put $R = 11^{11}/10^{10}$, so $\log_2 R = 11\,H(T_{11})$. The two bounds follow from exact integer inequalities:
$$2^{2417}\cdot 10^{5000} < 11^{5500} \quad\Longrightarrow\quad 2^{2417} < R^{500} \quad\Longrightarrow\quad 2417 < 500\log_2 R,$$
$$11^{2200} < 2^{967}\cdot 10^{2000} \quad\Longrightarrow\quad R^{200} < 2^{967} \quad\Longrightarrow\quad 200 \log_2 R < 967.$$
Dividing by $500\cdot 11$ and $200 \cdot 11$ gives $0.4394 < H(T_{11}) < 0.4396$. No floating-point arithmetic enters: the certificates are inequalities between integers. $\square$

### 4.3 Full pinning at degree 11

**Corollary 4.3.** Let $\sigma(u) = \{u, -u\}$ be the *sign class* of a unit mod $23$ — a strictly coarser observable than $u$ itself, discarding one bit. Then
$$H\big(d_{23} \mid \sigma\big) = 0 \qquad\text{and}\qquad I\big(\sigma\,;\,d_{23}\big) = H(T_{11}) = 0.4395\ldots$$

*Proof sketch.* $\sigma(u) = \sigma(v)$ forces $v = \pm u$, and $d_{23}(-u) = d_{23}(u)$ by Lemma 3.3; so the type factors through $\sigma$, and Theorem 3.1's mechanism applies. The value is Theorem 3.5(4). $\square$

This is the sharp form of the degree-$11$ pinning claim: not merely that the residue determines the type, but that the residue *modulo sign* — the exact quotient the field cares about — already does, with the entire type entropy transmitted and nothing left over.

---

## 5. Sharpness: pinning is exactly measurability

Pinning is only interesting if it could fail. This section shows exactly when it does.

### 5.1 Strict positivity for non-constant read-outs

**Theorem 5.1.** Let $S$ be finite and $g : S \to B$ a read-out. If there exist $x, y \in S$ with $g(x) \ne g(y)$, then $H(S,g) > 0$.

*Proof.* Write $N = |S| \ge 2$. For any $a \in S$, the fibre through $a$ omits at least one of $x, y$: if $g(a) = g(x)$ it cannot contain $y$, and otherwise it cannot contain $x$. Hence every fibre has size at most $N-1$, and since fibres are nonempty, $0 < \log_2 |g^{-1}(g(a))| \le \log_2 (N-1)$ for each $a$. Averaging,
$$\frac1N \sum_{a\in S}\log_2\big|g^{-1}(g(a))\big| \;\le\; \log_2(N-1) \;<\; \log_2 N,$$
the last inequality being strict because $\log_2$ is strictly increasing and $N - 1 < N$ with $N-1 > 0$. Subtracting from $\log_2 N$ gives $H(S,g) > 0$. $\square$

This is the quantitative engine: it upgrades "some fibre is not monochromatic" into a strictly positive number.

### 5.2 The criterion

**Theorem 5.2 (Pinning criterion).** Let $S$ be finite, $g : S \to B$, $k : S \to C$. Then
$$H(g \mid k) = 0 \iff \big(\forall x,y \in S\big)\ \big[\,k(x) = k(y) \Rightarrow g(x) = g(y)\,\big].$$

*Proof.* ($\Leftarrow$) Each fibre of $k$ is $g$-constant, hence has zero entropy, hence so does their convex combination.

($\Rightarrow$) Suppose $k(x) = k(y)$ but $g(x) \ne g(y)$. Both $x$ and $y$ lie in the fibre $F = k^{-1}(k(x))$, which is therefore a set on which $g$ is non-constant, so $H(F,g) > 0$ by Theorem 5.1. The weight $|F|/|S|$ is strictly positive, so the corresponding term of the sum defining $H(g\mid k)$ is strictly positive. All other terms are non-negative, so $H(g\mid k) > 0$, a contradiction. $\square$

**Corollary 5.3 (Dichotomy).** $I(k;g) = H(S,g)$ if and only if $g$ factors through $k$; otherwise $I(k;g) < H(S,g)$ strictly. In particular an observed identity $I = H$ is never a numerical near-coincidence: it is equivalent to an exact structural statement.

**Corollary 5.4 (Criterion at degree 11).** For any channel $k$ on $(\mathbb{Z}/23)^\times$,
$$I\big(k\,;\,d_{23}\big) = H(T_{11}) \iff \big(\forall u,v\big)\ \big[\,k(u)=k(v) \Rightarrow d_{23}(u) = d_{23}(v)\,\big].$$
Equivalently: $k$ is lossless precisely when it never merges a split class with an inert one. If $k$ merges even one such pair, then $I(k;d_{23}) < H(T_{11})$ strictly.

### 5.3 An explicit failure: the quadratic character

**Theorem 5.5 (Legendre pinning failure).** Let $\chi(u) = [\,u \text{ is a square in } (\mathbb{Z}/23)^\times\,]$ be the quadratic-residue indicator. Then
$$I\big(\chi\,;\,d_{23}\big) \;<\; H(T_{11}).$$

*Proof.* $5^2 = 25 \equiv 2 \pmod{23}$, so $2$ is a quadratic residue mod $23$; and $1$ is trivially a square. Thus $\chi(2) = \chi(1)$. But $d_{23}(1) = 1$ (split) while $d_{23}(2) = 11$ (inert, by Theorem 4.1, since $2 \not\equiv \pm1$). So $\chi$ merges a split class with an inert class, and Corollary 5.4 applies. $\square$

This failure is not marginal. In fact the channel is *maximally* lossy:

**Theorem 5.6 (Zero information from the quadratic character).** Work in exponent coordinates: fix a primitive root mod $23$, so residues correspond to $a \in \mathbb{Z}/22$. Let $\tau(a) = \operatorname{type}_{11}(a \bmod 11)$ be the splitting type and $\chi(a) = a \bmod 2$ the quadratic character. Then
$$I(\chi\,;\,\tau) \;=\; 0.$$

*Proof sketch.* The unconditional entropy is $H(\mathbb{Z}/22, \tau) = B(22,2)$, since exactly the two exponents $a \in \{0, 11\}$ have $\tau(a) = 1$. Each fibre of $\chi$ — the $11$ even exponents, or the $11$ odd ones — contains exactly one exponent divisible by $11$ (namely $0$ in the even fibre, $11$ in the odd one). So each conditional distribution is again one-against-ten, giving fibre entropy $B(11,1)$; the conditional entropy is their equal-weight average, $B(11,1)$. Finally $B(22,2) = B(11,1)$ by scale invariance (Lemma 2.6), so the mutual information is $0$. $\square$

The conceptual content is a Chinese-Remainder splitting: $\mathbb{Z}/22 \cong \mathbb{Z}/2 \times \mathbb{Z}/11$, the type depends only on the $\mathbb{Z}/11$ coordinate and the quadratic character only on the $\mathbb{Z}/2$ coordinate, and $\gcd(2,11)=1$ makes them independent. Since $q = 11$ is odd, the same argument applies at every odd prime rung: *the quadratic character is always exactly uninformative about the odd-prime-degree splitting type.*

So at degree $11$ we have two natural arithmetic channels sitting at opposite extremes: the sign class transmits all $0.4395$ bits, and the Legendre symbol transmits $0$. Pinning distinguishes them sharply.

---

## 6. Semiprimes: an exact binomial law and its channel

### 6.1 The split count

Let $q$ be a prime degree. Model a semiprime $N = p_1p_2$ by the pair $(a_1, a_2)$ of exponents of its prime factors in the cyclic group of order $q$, ranging over the box $\{0,\dots,q-1\}^2$ of size $q^2$. The **split count**
$$s(a_1,a_2) \;=\; \#\{i : \operatorname{type}_q(a_i) = 1\} \;=\; [a_1 = 0] + [a_2 = 0] \in \{0,1,2\}$$
records how many of the two factors split completely.

**Theorem 6.1 (Exact $\mathrm{Bin}(2,1/q)$ law).** For prime $q$, among the $q^2$ pairs:
$$\#\{s = 2\} = 1, \qquad \#\{s = 1\} = 2(q-1), \qquad \#\{s = 0\} = (q-1)^2,$$
and these three counts sum to $q^2$. At $q = 11$: $(1, 20, 100)$ out of $121$ — the exact $\mathrm{Bin}(2, 1/11)$ profile.

*Proof sketch.* By the prime dichotomy (Lemma 2.8), $\operatorname{type}_q(a) = 1$ iff $a = 0$. So $s = 2$ forces $(0,0)$; $s = 1$ means exactly one coordinate is $0$, giving $2(q-1)$ pairs; $s = 0$ means neither is, giving $(q-1)^2$. The identity $1 + 2(q-1) + (q-1)^2 = q^2$ completes the law. $\square$

The point of the exact statement is that it is a *count*, not an approximation: the empirical $\chi^2 = 0.08$ reported for a $\mathrm{Bin}(2,1/11)$ fit is testing a distribution which, in the underlying model, is exactly correct by combinatorics.

### 6.2 The split-count channel

Now condition on an observable of the semiprime itself. In exponent coordinates the class of $N = p_1p_2$ is $\rho(a_1,a_2) = (a_1 + a_2) \bmod q$. How much does $\rho$ reveal about $s$?

**Theorem 6.2 (Unconditional split-count entropy).** For prime $q$,
$$H\big(\text{box},\, s\big) \;=\; \log_2(q^2) \;-\; \frac{(q-1)^2\log_2\!\big((q-1)^2\big) \;+\; 2(q-1)\log_2\!\big(2(q-1)\big)}{q^2}.$$

*Proof sketch.* Apply Definition 2.1 to the three fibre sizes of Theorem 6.1, the singleton fibre contributing $1\cdot\log_2 1 = 0$. $\square$

**Lemma 6.3 (Fibre structure).** Each fibre $\rho^{-1}(c)$ has exactly $q$ elements. On the fibre $c = 0$, the split count is $2$ at the single pair $(0,0)$ and $0$ elsewhere; on a fibre $c \ne 0$, exactly the two pairs $(0,c)$ and $(c,0)$ have split count $1$, and the remaining $q-2$ pairs have split count $0$.

**Theorem 6.4 (Conditional split-count entropy).** For prime $q$,
$$H\big(s \mid \rho\big) \;=\; \frac1q\,B(q,1) \;+\; \frac{q-1}{q}\,B(q,2).$$

*Proof sketch.* By Lemma 6.3 the $c=0$ fibre is a $1$-against-$(q-1)$ split, with entropy $B(q,1)$; each of the $q-1$ nonzero fibres is a $2$-against-$(q-2)$ split, with entropy $B(q,2)$. Weight each of the $q$ fibres by $q/q^2 = 1/q$. $\square$

**Theorem 6.5 (Closed form).** For prime $q$,
$$I_{\mathrm{split}}(q) \;=\; \log_2(q^2) - \frac{(q-1)^2\log_2\!\big((q-1)^2\big) + 2(q-1)\log_2\!\big(2(q-1)\big)}{q^2} - \left[\frac1q B(q,1) + \frac{q-1}{q}B(q,2)\right].$$

**Theorem 6.6 (The degree-11 value).**
$$I_{\mathrm{split}}(11) \;=\; \log_2 11 \;+\; \frac{180\log_2 3 - 210\log_2 5 - 210}{121},$$
and $0.0516 < I_{\mathrm{split}}(11) < 0.0521$; numerically $I_{\mathrm{split}}(11) = 0.05190\ldots$ bits.

*Proof sketch.* Substituting $q = 11$ into Theorem 6.5, all logarithms reduce to $\log_2 11$, $\log_2 5$, $\log_2 3$ and rational multiples of $1$ via $\log_2 121 = 2\log_2 11$, $\log_2 100 = 2 + 2\log_2 5$, $\log_2 20 = 2 + \log_2 5$, $\log_2 10 = 1 + \log_2 5$, $\log_2 9 = 2\log_2 3$; collecting terms gives the stated form. For the bracket, set $A = 121\log_2 11 + 180\log_2 3 - 210\log_2 5$, so that $I_{\mathrm{split}}(11) = (A - 210)/121$. The bounds $865 < 4A$ and $10A < 2163$ follow from the exact integer inequalities
$$2^{865}\cdot 5^{840} < 11^{484}\cdot 3^{720}, \qquad 11^{1210}\cdot 3^{1800} < 2^{2163}\cdot 5^{2100},$$
by taking base-$2$ logarithms. $\square$

**Remark 6.7 (A corrected prediction).** A value of $0.116$ bits had been announced in advance for this quantity. Under the definitions above — split count of the factor pair against the class of the product — the true value is $0.0519\ldots$, less than half the announced figure, and the bracket $I_{\mathrm{split}}(11) < 0.0521 < 0.116$ is certified by integer arithmetic. Of the four degree-$11$ predictions (the $\pm1$ splitting law, the densities $\{1/11, 10/11\}$ with $H(T) = 0.4395$, full pinning, and the $\mathrm{Bin}(2,1/11)$ semiprime law), the first four are confirmed as theorems; the fifth, the numerical value of the split-count channel, is corrected.

---

## 7. The shape of the ladder

### 7.1 The decay sandwich

**Theorem 7.1.** For every prime $q$,
$$\frac{\log_2 q}{q} \;\le\; H(T_q) \;\le\; \frac{\log_2 q + 1/\ln 2}{q}.$$

*Proof sketch.* Rewrite the closed form as
$$H(T_q) \;=\; \frac{\log_2 q}{q} \;+\; \frac{q-1}{q}\Big(\log_2 q - \log_2 (q-1)\Big).$$
The correction term is non-negative since $\log_2$ increases, giving the lower bound. For the upper bound use the elementary estimate $\log_2(x+1) - \log_2 x \le 1/(x\ln 2)$ with $x = q-1$, so the correction is at most $\frac{q-1}{q}\cdot\frac{1}{(q-1)\ln 2} = \frac{1}{q\ln 2}$. $\square$

The two ends differ by $1/(q\ln2)$. In fact the exact excess is
$$q\,H(T_q) - \log_2 q \;=\; (q-1)\log_2\!\Big(\frac{q}{q-1}\Big) \;=\; \log_2\Big(1 + \tfrac{1}{q-1}\Big)^{q-1} \;\nearrow\; \frac{1}{\ln 2} = 1.4427\ldots,$$
so the upper bound is asymptotically sharp while the lower bound is never attained.

**Corollary 7.2.** For prime $q \ne 2$, $H(T_q) < 1$: only degree $2$ reaches a full bit. For $q \ge 4$ this follows from Theorem 7.1 together with $\log_2 q \le q/2$ (valid for $q \ge 4$, since $q^2 \le 2^q$ there) and $1/\ln 2 < 1.4427$; the case $q=3$ is the explicit inequality $\log_2 3 < 5/3$, i.e. $3^3 < 2^5$.

**Corollary 7.3.** For prime $q > 2$, $H(T_q) > 0$: no rung is silent. Indeed $H(T_q) \ge \log_2 q / q > 0$.

### 7.2 The interpolating profile and its derivative

**Definition 7.4.** For real $x > 1$ set
$$h(x) \;=\; \log_2 x \;-\; \frac{x-1}{x}\log_2 (x-1).$$
By Theorem 2.9, $h(q) = H(T_q)$ at every prime $q$; and $h(2) = \log_2 2 - \frac12\log_2 1 = 1$.

**Theorem 7.5 (Exact derivative).** For $x > 1$,
$$h'(x) \;=\; -\,\frac{\ln(x-1)}{x^2 \ln 2}.$$

*Proof.* Write $h(x) = \big(\ln x - \frac{x-1}{x}\ln(x-1)\big)/\ln 2$. Differentiating inside, $\frac{d}{dx}\ln x = 1/x$, $\frac{d}{dx}\frac{x-1}{x} = \frac{x - (x-1)}{x^2} = \frac{1}{x^2}$, and $\frac{d}{dx}\ln(x-1) = \frac{1}{x-1}$. By the product rule,
$$\frac{d}{dx}\left[\frac{x-1}{x}\ln(x-1)\right] \;=\; \frac{\ln(x-1)}{x^2} \;+\; \frac{x-1}{x}\cdot\frac{1}{x-1} \;=\; \frac{\ln(x-1)}{x^2} + \frac1x.$$
Hence $\ln 2 \cdot h'(x) = \frac1x - \frac{\ln(x-1)}{x^2} - \frac1x = -\frac{\ln(x-1)}{x^2}$. $\square$

The cancellation of the two $1/x$ terms is the whole content: the derivative is a *single* logarithm, and its sign is immediate.

**Theorem 7.6 (Strict antitonicity).** $h$ is strictly decreasing on $[2,\infty)$.

*Proof.* $h$ is differentiable, hence continuous, on $(1,\infty) \supseteq [2,\infty)$. For $x > 2$ we have $x - 1 > 1$, so $\ln(x-1) > 0$, and $x^2\ln 2 > 0$; therefore $h'(x) < 0$ on the interior of $[2,\infty)$. A continuous function on an interval with negative derivative on the interior is strictly decreasing there. $\square$

Note that $h'(2) = 0$ exactly: the ladder profile is *flat* at the bottom rung and then falls away. This is the analytic reason degree $2$ is distinguished.

**Theorem 7.7 (Strict decay of the ladder).** For primes $p < q$,
$$H(T_q) \;<\; H(T_p).$$

*Proof.* Both $p, q \ge 2$, so both lie in $[2,\infty)$ with $p < q$; apply Theorem 7.6 and then $h(p) = H(T_p)$, $h(q) = H(T_q)$. $\square$

**Corollary 7.8 (Unique full bit).** $H(T_2) = 1$, and $H(T_q) < 1$ for every prime $q > 2$.

**Corollary 7.9 (The first five rungs).**
$$H(T_{11}) < H(T_7) < H(T_5) < H(T_3) < H(T_2),$$
numerically $0.4395 < 0.5917 < 0.7219 < 0.9183 < 1$ — the reported ladder values, now with their ordering proved rather than observed.

Combining Theorems 7.1 and 7.7 with Corollary 7.3: *the abelian ladder is a strictly decreasing sequence of strictly positive entropies tending to $0$ at the rate $\log_2 q / q$.*

---

## 8. Discussion

### 8.1 Perfect channel, vanishing message

The two halves of this paper pull in opposite directions, and their combination is the real result.

Theorem 3.1 says the arithmetic-to-information channel is *never* lossy in the abelian world: the residue class of $p$ transmits every bit of its splitting type, at every degree, in every abelian field. Theorem 7.7 says the message being transmitted gets quieter without exception: $H(T_q) \sim \log_2 q / q \to 0$.

So the abelian ladder exhibits *perfect transmission of a vanishing signal*. As the degree grows, complete splitting becomes rare (density $1/q$), and rarity is informationally cheap — a binary source with $p = 1/q$ has entropy $\Theta\!\big(\tfrac{\log q}{q}\big)$. The channel's perfection is structural (the type is a function of the class); the signal's decay is measure-theoretic (the split class is a shrinking fraction of the group). Neither fact influences the other, and that is why both can be proved cleanly and separately.

### 8.2 What "no exceptions" is worth

Round-by-round empirical confirmation of pinning across degrees $2, 3, 5, 7, 11$ is a natural way to build confidence, and it produced the right conjecture. But Theorem 3.1 shows the survey could never have failed, so no further abelian degree carries any evidential weight. The value of the empirical programme, in retrospect, was to identify the right *statement*; the value of the theorem is to close it.

The sharpness results of §5 are what keep this from being vacuous. Because $H(T\mid k) = 0$ is *equivalent* to measurability (Theorem 5.2), pinning is a genuine binary property of a channel, and Theorems 5.5 and 5.6 exhibit a perfectly natural arithmetic channel at degree $11$ on the wrong side of it — indeed one with mutual information exactly zero. Full pinning is therefore a real distinction between channels, not a property everything has.

### 8.3 The corrected prediction

One pre-registered numerical figure did not survive. The split-count channel at degree $11$ was predicted at $0.116$ bits; the closed form gives $\log_2 11 + (180\log_2 3 - 210\log_2 5 - 210)/121 = 0.05190\ldots$, certified in $(0.0516, 0.0521)$ by integer inequalities. Under the definitions used here — mutual information between the number of split prime factors of a semiprime and the class of the semiprime itself — the smaller value is correct, and the discrepancy is a factor of more than two. Reporting it is part of the result: a closed form is worth more than a prediction, precisely because it can contradict one.

### 8.4 Cryptographic reading

The semiprime results of §6 have a plain reading in the language of factoring problems. Given only $N = p_1p_2$ and its residue mod $23$, an adversary learns about the splitting behaviour of the hidden factors only $I_{\mathrm{split}}(11) = 0.052$ bits — one twentieth of a bit. The individual factors' types would be worth $2 \times 0.4395 = 0.879$ bits if visible; conditioning on the product destroys almost all of it. The general closed form of Theorem 6.5 quantifies the same leakage at every prime degree, and the exact binomial law of Theorem 6.1 says the prior an adversary should hold on the number of split factors is precisely $\mathrm{Bin}(2, 1/q)$.

---

## 9. Future directions

**Non-abelian pinning defect.** Theorem 3.1 uses commutativity exactly once: to know that the Frobenius *class* is a single group element. For a non-abelian Galois group the Artin symbol is a conjugacy class, and while the residue degree remains class-determined, the honest place to look for a defect is the *abelianised* channel, where a genuine gap can open. Since the abelian side is now closed, the first real test is the smallest non-abelian Galois group $S_3$ — the splitting field of $x^3 - 2$ — small enough to enumerate exactly.

**The second-order ladder law.** Rung-by-rung monotonicity is now a theorem (Theorem 7.7), so the question moves one order down. The quantity $q\,H(T_q) - \log_2 q = (q-1)\log_2\!\big(q/(q-1)\big)$ is elementary and increases to $1/\ln 2 = 1.4427\ldots$, so the sandwich of Theorem 7.1 is asymptotically sharp at the upper end and the lower bound is never attained. With the exact derivative in hand, the remaining step is a monotone-limit statement about $(1+1/t)^t$ rather than any new arithmetic.

**Composite degrees and the $\varphi$-profile.** At composite degree $n$ the type is no longer two-valued: the order of a class in a cyclic group of order $n$ ranges over the divisors of $n$, with the divisor $d$ occurring $\varphi(d)$ times. The binary entropy is then replaced by the full divisor profile
$$H(T_n) \;=\; -\sum_{d \mid n} \frac{\varphi(d)}{n}\log_2\frac{\varphi(d)}{n},$$
and the split density $1/n$ is only the first term. Understanding how this profile interpolates the prime-degree ladder — and whether monotonicity survives along composite degrees — is the natural continuation.

**Beyond cyclic quotients.** The universal theorem covers arbitrary finite abelian $G$ and arbitrary $H$, so non-cyclic Galois groups (e.g. biquadratic fields) are already pinned; what is not yet computed is the entropy profile of their type read-outs, where several residue degrees coexist with multiplicities governed by the subgroup lattice.

---

## 10. Conclusion

The degree-$11$ rung of the abelian ladder, realised by the real cyclotomic field $\mathbb{Q}(\zeta_{23})^{+}$, confirms every structural prediction made of it: primes split completely exactly when $p \equiv \pm 1 \bmod 23$; the split density is $1/11$, giving $H(T) = \log_2 11 - \frac{10}{11}\log_2 10 \in (0.4394, 0.4396)$; the residue channel is fully pinned, transmitting that entropy exactly; and the semiprime split count follows $\mathrm{Bin}(2, 1/11)$ with exact counts $(100, 20, 1)$ out of $121$. The one numerical prediction that fails — the split-count channel value — is replaced by a closed form and a certified bracket.

More importantly, the rung is the last one that needed checking. Pinning for abelian Galois groups is a theorem with a one-line proof and no exceptions; its sharpness criterion is exactly pointwise measurability, with a natural failing channel at degree $11$ carrying literally zero bits; and the ladder's decay is not an observed trend but a consequence of the single-logarithm derivative $h'(x) = -\ln(x-1)/(x^2\ln 2)$, which vanishes exactly at $x = 2$ and is negative thereafter. The abelian ladder is closed; the frontier is non-abelian.
