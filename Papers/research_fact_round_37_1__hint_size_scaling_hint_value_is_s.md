# The Hint Value Has No Size Law: Uniform-Fibre Transport, Residue Lifts, and Exact Plateaus for Semiprime Label Channels

**Author:** Aristotle

---

## Abstract

Let $N = pq$ be a semiprime, $m$ a modulus, and $L$ a *label*: an arithmetic invariant of the unordered pair $\{p,q\}$, such as the pair of root counts of a fixed polynomial modulo $p$ and modulo $q$. The **hint value**
$$\mathcal{H} \;=\; I\big(L;\,(p \bmod m,\, q \bmod m)\big) \;-\; I\big(L;\, N \bmod m\big)$$
measures how much a factor-level residue clue is worth beyond what the product already reveals. An experiment on four batteries ($S_3$ at conductor $31$, $C_3$ at $7$, $D_4$ at $8$, $C_5$ at $11$) found $\mathcal H$ flat to within $5.3\%$ across factor sizes $k = 14, 18, 22$, a $16{,}384$-fold span. There were two complications. The $S_3$ battery read anomalously high at $k = 10$. And a "which-factor wall" held only for a conditional test statistic.

We prove that each of these observations is a structural fact.

1. **Size-stability is an exact invariance.** Mutual information is invariant under uniform-fibre maps whose pointwise count ratios agree (*uniform-fibre transport*). Consequently, replicating every residue class by any number of prime identities leaves $\mathcal H$ exactly unchanged.
2. **Residue-lift theorem.** For any finite abelian conductor group $G$, any surjective dial $\psi: G \twoheadrightarrow H$, and any label that sees residues only through $\psi$ and an independent Frobenius coin, $\mathcal H$ equals its value on the small dial box $(H\times H)\times C$. The value is therefore independent of size *and* of conductor.
3. **Exact plateaus.** These are $\tfrac12$ ($S_3$, at every conductor), $\log_2 3 - \tfrac23$ ($C_3$), $\tfrac32 - \tfrac{9}{32}\log_2 3$ ($D_4$, with root-count labels of $x^4-2$), and $\log_2 5 - \tfrac{12}{25}\log_2 3 - \tfrac{16}{25}$ ($C_5$). The corresponding residual entropies are $\log_2 3 - \tfrac79$, $\tfrac{15}{32}$, $0$ and $0$.
4. **Pool-floor theorem.** $\mathcal H = H(L\mid N) - H(L\mid P)$. A pool that fails to resolve the residue classes can only inflate $\mathcal H$, and never beyond the ceiling $H(L\mid N)$, which a one-prime-per-class pool attains for every label.
5. **Which-factor wall.** For every swap-invariant population, every orientation bit $O$ and every swap-symmetric view $V$, $I(O;V)=0$ exactly. An explicit two-point population shows that the unconditional statistic can read a full bit.

The reported $S_3$ plateau of $\approx 0.54$ is the exact value $\tfrac12$ plus plug-in estimator bias, with Miller–Madow estimate $\approx 0.040$ bits.

---

## 1. Introduction

### 1.1 The question

Factoring a semiprime $N = pq$ is believed to be hard. Yet a great deal about $p$ and $q$ is visible through $N$ without factoring it. For example, $N \bmod m = (p \bmod m)(q \bmod m) \bmod m$ constrains the residues of the factors. A natural research programme asks: **which information about the factors is released by the product, and which is walled off?**

A quantitative instrument for this programme is the *hint value*. Fix a label $L$, a function of the unordered pair of primes. The hint value compares two channels: the factor-pair residue view $P = (p\bmod m, q \bmod m)$, which is not available from $N$, and the product view $N \bmod m$, which is. Its value is the excess information that $P$ carries about $L$.

Every practical measurement of $\mathcal H$ is made on random samples of semiprimes with factors of some modest size $k$ bits. For the programme to say anything about cryptographic sizes, one needs to know how $\mathcal H$ depends on $k$. This paper answers that question completely in the natural population model: **it does not depend on $k$ at all.**

### 1.2 The experiment

For each of four batteries, $n = 15{,}000$ semiprimes were sampled at each factor size, and $\mathcal H$ was estimated by plug-in (empirical-frequency) entropies. The readings, in bits:

| battery | label | $k=14$ | $k=18$ | $k=22$ |
|---|---|---|---|---|
| $S_3$ at $31$ | root counts of $x^3+x+1$ | 0.5584 | 0.5425 | 0.5415 |
| $C_3$ at $7$ | residue degrees in the cubic subfield of $\mathbb Q(\zeta_7)$ | 0.9115 | 0.9140 | 0.9169 |
| $D_4$ at $8$ | root counts of $x^4-2$ | 1.0540 | 1.0536 | 1.0507 |
| $C_5$ at $11$ | residue degrees in the quintic subfield of $\mathbb Q(\zeta_{11})$ | 0.9030 | 0.9190 | 0.9268 |

Three phenomena stood out.

- **Plateau.** Every row is flat to within $5.3\%$, and the abelian rows to within $1.6\%$ on the experiment's own summary statistic. For the abelian batteries, the empirical residual entropy $H(L\mid P)$ was exactly $0$ at every size.
- **Pool-floor exception.** At $k=10$ the $S_3$ battery read $0.7423$. The $10$-bit pool contained only $75$ primes, about $2.5$ per residue class mod $31$.
- **Which-factor wall.** A conditional orientation-permutation test held at all $16$ battery-by-size cells, with maximum $|z|=1.55$. The naive unconditional test would have signalled violation at up to $|z| = 4.7$.

### 1.3 Results in one paragraph

Mutual information on a finite uniform population is an average of a log-ratio of counts. Maps with uniform fibres rescale all counts by the same factor, so they leave every such average unchanged. This one observation drives the paper. It shows that changing the factor size, which amounts to replicating classes, changes nothing (§3). It shows that the full residue space may be replaced by a tiny dial box (§4), which makes the plateaus explicitly computable (§7). An elementary decomposition of $\mathcal H$ into two conditional entropies then explains the pool-floor exception (§5). Finally, a pairing argument proves the wall and shows why only the conditional instrument detects it (§6).

---

## 2. Definitions and the pointwise form

### 2.1 Counting entropies

Throughout, $\Omega$ is a finite nonempty set carrying the uniform probability measure. A *read-out* is any function $X:\Omega\to\mathcal X$ into a set with decidable equality. For $\omega\in\Omega$, write
$$n_X(\omega) = \#\{\omega' \in \Omega : X(\omega') = X(\omega)\},\qquad n_{X,Y}(\omega) = \#\{\omega' : X(\omega') = X(\omega),\ Y(\omega')=Y(\omega)\}.$$

**Definition 2.1 (entropies).** The *entropy* of $X$ is
$$H(X) = -\frac{1}{|\Omega|}\sum_{\omega\in\Omega}\log_2\frac{n_X(\omega)}{|\Omega|}.$$
The *conditional entropy* of $X$ given $Y$ is the average, over the fibres $\Omega_y = Y^{-1}(y)$, of the entropy of $X$ restricted to $\Omega_y$, weighted by $|\Omega_y|/|\Omega|$. The *mutual information* is $I(X;Y) = H(X) - H(X\mid Y)$.

When $\Omega$ is an empirical sample (a multiset), these are exactly the plug-in estimators. When $\Omega$ is a population, they are the true Shannon quantities of the uniform law. The same algebra serves both readings.

**Definition 2.2 (battery, hint value).** A *battery* is a quadruple $(\Omega, L, P, N)$ of a finite population with three read-outs: the label $L$, the pair view $P$ and the product view $N$. Its *hint value* is
$$\mathcal H(L,P,N) = I(L;P) - I(L;N).$$
Its *residual* is $H(L\mid P)$.

### 2.2 The pointwise form

**Proposition 2.3 (pointwise form).** For every finite nonempty $\Omega$ and read-outs $X, Y$,
$$I(X;Y) = \frac{1}{|\Omega|}\sum_{\omega\in\Omega} i(\omega),\qquad i(\omega) = \log_2\frac{|\Omega|\, n_{X,Y}(\omega)}{n_X(\omega)\, n_Y(\omega)}.$$

*Proof sketch.* Expand $I(X;Y)$ as a double sum over values $(x,y)$ weighted by joint cell counts. Then split the sum over $\omega$ fibrewise, first by $Y$ and then by $X$. On the cell $\{X = x, Y = y\}$ the summand $i(\omega)$ is constant. Summing it gives the cell count times the log-ratio, which is exactly the double-sum term. Every count appearing is positive at a sample point, so $\log_2$ of the ratio splits as $\log_2|\Omega| - \log_2 n_X - \log_2 n_Y + \log_2 n_{X,Y}$. $\square$

An immediate consequence: $H(X\mid X)=0$, so $H(X) = I(X;X)$; entropy is self-information.

---

## 3. Uniform-fibre transport and size-stability

### 3.1 Transport

**Lemma 3.1 (uniform fibres).** Let $f:\Omega\to\Omega'$ satisfy $|f^{-1}(y)| = K$ for every $y\in\Omega'$. Then:
1. $|\Omega| = K\,|\Omega'|$;
2. for every predicate $Q$ on $\Omega'$, $\#\{\omega : Q(f(\omega))\} = K\,\#\{y : Q(y)\}$;
3. for every function $F:\Omega'\to\mathbb R$, $\sum_{\omega}F(f(\omega)) = K\sum_{y}F(y)$.

*Proof.* Partition $\Omega$ into the fibres of $f$. $\square$

**Theorem 3.2 (uniform-fibre transport).** Let $f:\Omega\to\Omega'$ have all fibres of the same size $K>0$. Let $X,Y$ be read-outs on $\Omega$ and $X',Y'$ read-outs on $\Omega'$. Suppose that at every $\omega\in\Omega$ the pointwise ratios agree:
$$\frac{|\Omega|\,n_{X,Y}(\omega)}{n_X(\omega)\,n_Y(\omega)} \;=\; \frac{|\Omega'|\,n_{X',Y'}(f\omega)}{n_{X'}(f\omega)\,n_{Y'}(f\omega)}.$$
Then $I(X;Y) = I(X';Y')$.

*Proof sketch.* By Proposition 2.3 the left side is $|\Omega|^{-1}\sum_\omega i(\omega)$. By hypothesis $i(\omega) = i'(f\omega)$. Lemma 3.1(3) turns the sum into $K\sum_y i'(y)$, and Lemma 3.1(1) turns $|\Omega|$ into $K|\Omega'|$. The factor $K$ cancels. $\square$

**Corollary 3.3 (entropy transport).** If $f$ has uniform fibres and $X'$ is a read-out on $\Omega'$, then $H(X'\circ f) = H(X')$.

*Proof.* Apply Theorem 3.2 with $X=Y=X'\circ f$, $X'=Y'$, using $H = I(\cdot\,;\cdot)$ and Lemma 3.1(2) to verify the ratio condition. $\square$

### 3.2 Size-stability

In the population model, going to larger factor sizes keeps the law of the class-level data unchanged and only increases the number of distinct primes realising each class. We model this as replication.

**Theorem 3.4 (size-stability).** Let $(\Omega, L, P, N)$ be a battery and $F$ any finite nonempty set. On $\Omega\times F$, define $\tilde L(\omega,j)=L(\omega)$, and similarly $\tilde P$ and $\tilde N$. Then for all read-outs,
$$I(\tilde L;\tilde P) = I(L;P),\qquad \mathcal H(\tilde L,\tilde P,\tilde N) = \mathcal H(L,P,N).$$

*Proof.* The projection $\Omega\times F\to\Omega$ has all fibres of size $|F|$. Every count pulled back along it is multiplied by $|F|$, as is $|\Omega|$, so the pointwise ratios agree. Apply Theorem 3.2 twice. $\square$

**Interpretation.** The hint value is a functional of the class-level law alone. *There is no size law to find.* Measured drift across sizes can come from only two sources: finite-sample estimator bias, or departures of the actual prime pool from the class law (§5).

---

## 4. The residue-lift theorem

### 4.1 Setting

Let $G$ be a finite abelian group, the conductor group. The guiding example is $G=(\mathbb Z/m)^\times$. Let $H$ be a finite abelian group and $\psi: G\to H$ a **surjective** homomorphism, the *dial*. Let $C$ be a finite set, the *Frobenius coin*, and $\Lambda$ a label alphabet. Given a function $\ell: H\times H\times C\to\Lambda$, define:

- the **residue space** $\Omega_G = (G\times G)\times C$, with label $L_G(a,b,c) = \ell(\psi a, \psi b, c)$, pair view $P(a,b,c) = (a,b)$ and product view $N(a,b,c) = ab$;
- the **dial box** $\Omega_H = (H\times H)\times C$, with label $L_H(h_1,h_2,c)=\ell(h_1,h_2,c)$, pair view $(h_1,h_2)$ and product view $h_1h_2$;
- the **dial map** $\delta: \Omega_G\to\Omega_H$, $\delta(a,b,c) = (\psi a, \psi b, c)$.

The population model is the uniform measure on $\Omega_G$. Residues are uniform on the unit group (Dirichlet), and the coin is uniform and independent of the residues given the dial (Chebotarev). The label sees the residues only through the dial.

### 4.2 Two counting lemmas

Let $\kappa = |\ker\psi|$.

**Lemma 4.1 (dial fibres).** Every fibre of $\psi$ has exactly $\kappa$ elements. Consequently $|G| = \kappa|H|$, and every fibre of $\delta$ has exactly $\kappa^2$ elements.

*Proof.* Each fibre of a surjective homomorphism is a coset of the kernel. The fibre of $\delta$ over $(h_1,h_2,c)$ is $\psi^{-1}(h_1)\times\psi^{-1}(h_2)\times\{c\}$. $\square$

**Lemma 4.2 (factorisation count).** For $n\in G$ and $h_1,h_2\in H$ with $h_1h_2=\psi(n)$,
$$\#\{(a,b)\in G\times G:\ ab = n,\ \psi a = h_1,\ \psi b = h_2\} = \kappa.$$

*Proof.* The map $(a,b)\mapsto a$ is a bijection onto $\psi^{-1}(h_1)$, with inverse $a\mapsto (a, a^{-1}n)$. The condition $\psi(a^{-1}n) = h_1^{-1}\psi(n) = h_2$ is automatic. Then apply Lemma 4.1. $\square$

### 4.3 The theorem

**Theorem 4.3 (residue lift).** In the setting above,
$$I(L_G;\, P) = I(L_H;\, P_H),\qquad I(L_G;\,N) = I(L_H;\,N_H),$$
and hence
$$\mathcal H\big(L_G, P, N\big) = \mathcal H\big(L_H, P_H, N_H\big).$$

*Proof sketch.* Apply Theorem 3.2 to the dial map $\delta$, which has uniform fibres of size $\kappa^2$ by Lemma 4.1. In both rows the label counts satisfy $n_{L_G}(x) = \kappa^2 n_{L_H}(\delta x)$, and $|\Omega_G| = \kappa^2|\Omega_H|$.

*Pair row.* Fixing $P=(a,b)$ fixes $(\psi a,\psi b)$, so $n_P(x) = |C| = n_{P_H}(\delta x)$. Inside that cell the label depends only on the coin, so $n_{L,P}(x) = n_{L_H,P_H}(\delta x)$. The two ratios are then identical.

*Product row.* For $N = n$ we have $n_N(x) = |G|\,|C|$, while $n_{N_H}(\delta x) = |H|\,|C|$. The joint count $n_{L,N}(x)$ is a sum over the pairs $(h_1,h_2)$ with $h_1h_2=\psi(n)$. Each term is the number of factorisations, $\kappa$ by Lemma 4.2, times the number of coins giving the target label. Hence $n_{L,N}(x)=\kappa\, n_{L_H,N_H}(\delta x)$. The ratio upstairs is
$$\frac{\kappa^2|\Omega_H|\cdot\kappa\, n_{L_H,N_H}}{\kappa|H||C|\cdot\kappa^2 n_{L_H}} = \frac{|\Omega_H|\, n_{L_H,N_H}}{|H||C|\, n_{L_H}},$$
which is the ratio downstairs. $\square$

**Corollary 4.4 (conductor universality).** The population hint value depends only on the dial group $H$, the coin $C$ and the dial-level label $\ell$. In particular it is the same for every conductor group admitting a surjection onto $H$ that carries the label.

Corollary 3.3 likewise gives $H(L_G) = H(L_H)$. Together with the two mutual-information rows, every residual and ceiling transports to the dial box as well.

---

## 5. Residuals and the pool-floor exception

**Proposition 5.1 (hint as released minus residual).** For every battery,
$$\mathcal H(L,P,N) \;=\; H(L\mid N) \;-\; H(L\mid P).$$

*Proof.* Expand $I(L;P) - I(L;N) = (H(L) - H(L\mid P)) - (H(L)-H(L\mid N))$. $\square$

**Lemma 5.2.** Conditional entropy is nonnegative. If $L = \lambda\circ P$ on $\Omega$ for some function $\lambda$, then $H(L\mid P)=0$. The same holds if $P$ is injective on $\Omega$.

*Proof.* On each fibre of $P$, the label is constant (or the fibre is a singleton), so its entropy there is $0$. $\square$

**Theorem 5.3 (pool-floor theorem).** For every battery:
1. **Ceiling.** $\mathcal H(L,P,N)\le H(L\mid N)$.
2. **Residue-function labels.** If $L$ is a function of $P$, then $\mathcal H = H(L\mid N)$.
3. **Unresolved pools.** If $P$ is injective, as happens when each residue-pair class contains at most one sample, then $\mathcal H = H(L\mid N)$ for *every* label $L$. The excess over a population value whose residual is $H(L\mid P)>0$ is exactly that residual.

*Proof.* Combine Proposition 5.1 with Lemma 5.2. $\square$

**Interpretation.** Real prime pools at small $k$ are thin. With $r$ primes per residue class, the pair residue partially identifies the prime, and the prime determines its type. This *prime-identity leakage* lowers the empirical residual $H(L\mid P)$ and so raises $\mathcal H$, never lowers it, and by at most the residual. For abelian dials the label is a residue function already (Theorem 5.3(2)), so the residual is $0$ at every size and nothing can leak. That explains the experiment's exact-zero abelian residuals and their immunity to the pool floor.

For the $S_3$ battery (§7) the population plateau is $\tfrac12$ and the ceiling is $\log_2 3 - \tfrac5{18}\approx 1.3072$. The anomalous $k=10$ reading satisfies
$$\tfrac12 < 0.7423 < \log_2 3 - \tfrac{5}{18},$$
lying strictly inside the window that the pool-floor diagnosis permits. The experiment found the plateau restored once the pool reached about $30$ primes per class.

*Caveat.* Theorem 3.4 concerns uniform replication. Real pools whose classes are *unequally* populated are covered by the inequality of Theorem 5.3(1), but not by an exact equality.

---

## 6. The which-factor wall

Let $\sigma:\Omega\to\Omega$ be an involution, the factor swap $(p,q)\mapsto(q,p)$ on an ordered population closed under swapping. An **orientation bit** is a Boolean read-out $O$ with $O\circ\sigma = \neg O$, for example $O = [p<q]$. A **symmetric view** is a read-out $V$ with $V\circ\sigma = V$, for example $V = (N \bmod m,\ \{p\bmod m, q \bmod m\},\ \text{unordered type pair})$.

**Lemma 6.1 (orientation halves invariant events).** If $Q$ is a $\sigma$-invariant predicate, then for each $b\in\{0,1\}$,
$$2\,\#\{\omega: Q(\omega),\ O(\omega)=b\} = \#\{\omega: Q(\omega)\}.$$

*Proof.* $\sigma$ is a bijection from $\{Q, O=b\}$ to $\{Q, O=\neg b\}$, and these two sets partition $\{Q\}$. $\square$

**Theorem 6.2 (which-factor wall).** For every involution $\sigma$, orientation bit $O$ and symmetric view $V$,
$$I(O;V) = 0.$$

*Proof.* By Proposition 2.3 it suffices to show that every pointwise ratio equals $1$. Lemma 6.1 with $Q\equiv\text{true}$ gives $2n_O = |\Omega|$. With $Q = [V = V(\omega)]$ it gives $2n_{V,O} = n_V$. Hence $|\Omega|\,n_{V,O}/(n_O n_V) = 1$. $\square$

Theorem 6.2 is the exact null hypothesis of the *conditional* orientation-permutation test, which holds the symmetric data fixed and permutes orientations.

**Proposition 6.3 (the naive instrument fails).** On the two-point population $\{(2,3),(3,2)\}$ with $O=[p<q]$:
$$I\big(O;\ p\bmod 5\big) = 1,\qquad I\big(O;\ (pq\bmod 5,\ \min(p,q)\bmod 5,\ \max(p,q) \bmod 5)\big)=0.$$

*Proof.* The residue $p \bmod 5$ takes distinct values on the two points, so it determines $O$, which is a fair bit. The second view is symmetric, so Theorem 6.2 applies. $\square$

An unconditional statistic built from an *asymmetric* view is not protected by the wall. Its departures from zero say nothing about whether symmetric data leak the orientation. This explains the experiment's false alarms at $|z|$ up to $4.7$ under the naive test, against $\max|z| = 1.55$ under the conditional test.

---

## 7. Exact plateaus

We now evaluate the four batteries on their dial boxes. All logarithms are base $2$.

### 7.1 $S_3$ at conductor $31$

The cubic $f = x^3+x+1$ has discriminant $-31$, and its splitting field has Galois group $S_3$ with quadratic subfield $\mathbb Q(\sqrt{-31})$. The dial is the Legendre symbol $\psi = \left(\frac{\cdot}{31}\right): (\mathbb Z/31)^\times\to\{\pm1\}$, which is surjective (for example, $3$ is a non-residue mod $31$). Chebotarev's law gives:

- if $\psi(p) = -1$, Frobenius is a transposition and $f$ has exactly $1$ root mod $p$ (probability $\tfrac12$);
- if $\psi(p) = +1$, Frobenius is the identity ($3$ roots, probability $\tfrac16$) or a $3$-cycle ($0$ roots, probability $\tfrac13$).

We encode this with a coin $c\in\{0,1,2\}$: on residues, $c=0$ gives $3$ roots and $c\neq 0$ gives $0$ roots. The rule "exactly one root iff $p$ is a non-residue mod $31$, and otherwise $0$ or $3$ roots" was confirmed by direct computation for every prime $p<200$. The label is the unordered pair of root counts mod $p$ and mod $q$. The dial box has $2\cdot 2\cdot 9 = 36$ points.

**Conditional entropies on the dial box.** Write $h(\tfrac13) = \log 3 - \tfrac23$ for the binary entropy of $\tfrac13$.

- Given $P=(-,-)$ the label is $(1,1)$, with entropy $0$. Given $P = (\pm,\mp)$ the label is $(0,1)$ or $(1,3)$ with probabilities $\tfrac23,\tfrac13$, entropy $h(\tfrac13)$. Given $P=(+,+)$ the label is $(0,0),(0,3),(3,3)$ with probabilities $\tfrac49,\tfrac49,\tfrac19$, entropy $2\log 3 - \tfrac{16}9$. Averaging,
$$H(L\mid P) = \tfrac12\big(\log 3-\tfrac23\big) + \tfrac14\big(2\log3 - \tfrac{16}9\big) = \log 3 - \tfrac79.$$
- Given $N=-1$ the label is $(0,1)$ or $(1,3)$, entropy $h(\tfrac13)$. Given $N=+1$ the label is $(1,1),(0,0),(0,3),(3,3)$ with probabilities $\tfrac12,\tfrac29,\tfrac29,\tfrac1{18}$, entropy $\log 3+\tfrac19$. Averaging,
$$H(L\mid N) = \log 3 - \tfrac5{18}.$$

Also $H(L) = \log 3+\tfrac{13}{18}$, $I(L;P) = \tfrac32$ and $I(L;N)=1$.

**Theorem 7.1 ($S_3$ plateau).** The $S_3$ battery at conductor $31$ has population hint value exactly
$$\mathcal H_{S_3} = \tfrac12,$$
residual $H(L\mid P) = \log_2 3 - \tfrac79 > 0$, and ceiling $H(L\mid N) = \log_2 3-\tfrac5{18}$. The same value $\tfrac12$ holds:
- (*universality*) for every finite abelian conductor group with a surjective quadratic dial carrying the same label;
- (*size-stability*) after replication of the residue space by any finite nonempty set.

*Proof.* Theorem 4.3 reduces the computation on the $8100$-point residue space to the $36$-point box, where $\mathcal H = I(L;P) - I(L;N) = \tfrac32 - 1$. Universality is Corollary 4.4, and size-stability is Theorem 3.4. The residual and ceiling transport by Corollary 3.3 and Theorem 4.3. $\square$

### 7.2 $D_4$ at conductor $8$

For $x^4-2$, the root count mod an odd prime $p$ depends on $p \bmod 8$ and a coin $c\in\{0,1\}$:

| $p\bmod 8$ | root count |
|---|---|
| $1$ | $4$ (if $c=0$) or $0$ (if $c=1$) |
| $7$ | $2$ |
| $3, 5$ | $0$ |

This law was confirmed by direct computation for every odd prime $p<200$. The label is again the unordered pair of root counts. The dial is the identity of $(\mathbb Z/8)^\times$, so the box has $4\cdot4\cdot4 = 64$ points.

**Theorem 7.2 ($D_4$ plateau).**
$$\mathcal H_{D_4} = \tfrac32 - \tfrac{9}{32}\log_2 3 \approx 1.05423,\qquad H(L\mid P) = \tfrac{15}{32}.$$

*Proof sketch.* Exact counting on the box gives $H(L) = 6 - \tfrac{33}{32} - \tfrac54\log 5$, $I(L;P) = \tfrac92 - \tfrac54\log5$ and $I(L;N) = 3-\tfrac54\log 5+\tfrac{9}{32}\log 3$. Subtract. $\square$

The positive residual shows that $D_4$ is *not* an abelian dial: the coin at $p\equiv1 \pmod 8$ is invisible to residues mod $8$. Encoding the $D_4$ labels instead as unordered pairs of *cycle types* gives $1.1936$ on the same box, which is incompatible with the experimental $1.0540/1.0536$. So the experiment's labels are root counts.

### 7.3 The abelian batteries $C_3$ at $7$ and $C_5$ at $11$

Let $K_n\subset\mathbb Q(\zeta_f)$ be the subfield of degree $n$ fixed by $\{\pm1\}\subset(\mathbb Z/f)^\times$ (here $(n,f) = (3,7)$ or $(5,11)$). A prime $p\nmid f$ splits completely in $K_n$ when $p\equiv\pm1\pmod f$, and is otherwise inert of degree $n$. The label is the unordered pair of residue degrees. Since it is a *function of the pair view*, the residual is $0$ (Lemma 5.2), and $\mathcal H = H(L\mid N)$ by Theorem 5.3(2).

**Theorem 7.3 (abelian plateaus).**
$$\mathcal H_{C_3} = \log_2 3 - \tfrac23\approx 0.91830,\qquad \mathcal H_{C_5} = \log_2 5 - \tfrac{12}{25}\log_2 3 - \tfrac{16}{25}\approx 0.92115,$$
with residual exactly $0$ at every size and every conductor.

*Proof sketch for $C_3$.* Take $p$ uniform in $(\mathbb Z/7)^\times$ and $q = N/p$. If $N\equiv\pm1$, then $p\in\{\pm1\}\iff q\in\{\pm1\}$, so the label is $(1,1)$ or $(3,3)$ with probabilities $\tfrac13,\tfrac23$. If $N\not\equiv\pm1$, at most one of $p,q$ lies in $\{\pm1\}$: the label is $(1,3)$ with probability $\tfrac23$ and $(3,3)$ with probability $\tfrac13$. Either way $H(L\mid N=n) = h(\tfrac13) = \log 3-\tfrac23$. The $C_5$ computation is the same on the $100$-point box. $\square$

These values coincide with the cyclic exponent-model hint values for $n=3$ and $n=5$.

### 7.4 Summary

| battery | exact $\mathcal H$ | numeric | residual | reported $k=14/18/22$ | dev. at $k=22$ |
|---|---|---|---|---|---|
| $S_3@31$ | $\tfrac12$ | 0.50000 | $\log_23-\tfrac79\approx0.807$ | 0.5584/0.5425/0.5415 | $+8.3\%$ |
| $C_3@7$ | $\log_23-\tfrac23$ | 0.91830 | $0$ | 0.9115/0.9140/0.9169 | $-0.2\%$ |
| $D_4@8$ | $\tfrac32-\tfrac9{32}\log_23$ | 1.05423 | $\tfrac{15}{32}$ | 1.0540/1.0536/1.0507 | $-0.3\%$ |
| $C_5@11$ | $\log_25-\tfrac{12}{25}\log_23-\tfrac{16}{25}$ | 0.92115 | $0$ | 0.9030/0.9190/0.9268 | $+0.6\%$ |

---

## 8. Statistics: where the remaining deviation comes from

Since the population value is fixed exactly, any deviation of a reading from the table above is due to estimation. Plug-in entropy estimators are biased downward by roughly $(\text{support}-1)/(2n\ln 2)$ bits (the Miller–Madow correction). A mutual information inherits a positive bias from the joint table. For the $S_3$ battery at $m=31$ with $\varphi(31) = 30$:

- joint support of $(L,P)$: $|J_P| = 2\varphi^2 = 1800$; pair-view support $|V_P| = \varphi^2 = 900$;
- joint support of $(L,N)$: $|J_N| = 3\varphi = 90$; product-view support $|V_N| = \varphi = 30$.

The first-order bias of $\hat{\mathcal H}$ is
$$\frac{(|J_P|-|V_P|) - (|J_N| - |V_N|)}{2n\ln 2} = \frac{840}{2\cdot15000\cdot\ln 2}\approx 0.0404 \text{ bits},$$
predicting a reading of $\approx 0.540$. This matches the reported $0.5425/0.5415$. Seeded simulations of the ideal law at $n=15000$ give readings in the range $0.544$–$0.553$. The abelian and $D_4$ batteries have far smaller joint tables, so their bias is an order of magnitude smaller, which is consistent with their tighter agreement.

---

## 9. Algorithms

**Algorithm A (exact hint on a finite population).** Input: a list $\Omega$ and read-outs $L,P,N$.
1. Tabulate the counts of $L$, $P$, $N$, $(L,P)$ and $(L,N)$ in one pass, using hash maps.
2. Compute $H(X) = \log_2|\Omega| - |\Omega|^{-1}\sum_x c_x\log_2 c_x$ for each table.
3. Return $\mathcal H = [H(L,N)-H(N)] - [H(L,P) - H(P)] = H(L\mid N) - H(L\mid P)$.

The cost is $O(|\Omega|)$ time and $O(\text{support})$ memory.

**Algorithm B (residue lift).** Instead of enumerating $(G\times G)\times C$ with $|G|^2|C|$ points, enumerate the dial box $(H\times H)\times C$ with $|H|^2|C|$ points and apply Algorithm A. By Theorem 4.3 the outputs agree. For $S_3$ at $31$ this is $36$ points instead of $8100$, and for a conductor near $10^6$ it is still $36$ points.

**Algorithm C (conditional wall test).** Group the ordered sample by the symmetric view $V$. Within each group, compute the orientation imbalance. Calibrate against random orientation flips inside groups, which is the exact null by Theorem 6.2. Report $z$-scores. Never calibrate against an unconditional null built from an asymmetric statistic (Proposition 6.3).

---

## 10. Discussion

**What is proved, and what is modelled.** The theorems of §§2–6 are exact statements about finite populations. The identification of a real semiprime battery with the residue-space population of §4 is the Dirichlet–Chebotarev limit: residues uniform on units, and Frobenius coins uniform and independent of residues given the dial. That is a modelling assumption about the distribution of primes, not a theorem about any finite pool. The specific dial laws for $x^3+x+1$ and $x^4-2$ were checked on all primes below $200$.

**Consequences for the programme.** Hint values transfer across factor sizes wherever the prime pool resolves the conductor's residue classes. The observed floor was about $30$ primes per class. Toy-scale measurements therefore extrapolate safely. When the pool is too thin, the error has a known sign (upward) and a known bound (the residual). The which-factor barrier holds exactly along the size axis, provided it is tested with the conditional instrument.

**Limitations.** The size-stability theorem is exact for uniform replication only. Unbalanced pools are controlled by an inequality. The bias analysis of §8 is first-order.

---

## 11. Future directions

1. **Plug-in bias law.** Conjecture: the expected plug-in $S_3$ hint at sample size $n$ is $\tfrac12 + \frac{(|J_P|-|V_P|)-(|J_N|-|V_N|)}{2n\ln2}+O(n^{-2})$, predicting $0.5404\pm0.004$ at $m=31$, $n=15000$.
2. **Dihedral universality.** Conjecture: for every dihedral field $D_n$ whose dial is the quadratic resolvent, with root-count labels, the hint value is $\tfrac12$ for odd $n$, and an explicit rational combination of $\log_23$ and $\log_25$ for even $n$. The residue lift reduces every conductor to one dial box.
3. **Pool-resolution threshold.** Conjecture: with $r$ primes per class and Chebotarev-random types, the expected hint value is $\tfrac12 + H(L\mid P)\cdot\mathbb E[\mathrm{leak}(r)]$ with $\mathrm{leak}(r) = \Theta(1/r)$, interpolating between the plateau ($r\to\infty$) and the ceiling ($r=1$).

---

## Appendix: notation

| symbol | meaning |
|---|---|
| $p, q$ | the prime factors; $N = pq$ |
| $m$, $G$ | conductor; conductor group, e.g. $(\mathbb Z/m)^\times$ |
| $\psi: G\twoheadrightarrow H$ | the dial (e.g. a Legendre symbol) |
| $C$ | Frobenius coin set |
| $L$, $P$, $N$ | label, pair view $(p \bmod m, q\bmod m)$, product view $N\bmod m$ |
| $\mathcal H$ | hint value $I(L;P) - I(L;N)$ |
| $H(L\mid P)$ | residual |
| $H(L\mid N)$ | ceiling |
| $\kappa$ | $\lvert\ker\psi\rvert$ |
