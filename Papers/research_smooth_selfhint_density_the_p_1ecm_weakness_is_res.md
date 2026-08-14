# The Asymmetric/Symmetric Divisibility Dichotomy

### Residue invisibility of the $p-1$ weakness in semiprimes, with an exact information-theoretic rate

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Let $N = pq$ be a semiprime. The Pollard $p-1$ and elliptic-curve factoring methods succeed quickly precisely when a hidden factor $p$ has $p-1$ smooth. We ask whether membership in this weak instance class is detectable from $N$ alone — a *self-hint*. We answer in the negative, in every form, and we identify the exact structural reason.

The reason is a dichotomy between one-sided and two-sided conditions on a factorisation. Working in an arbitrary finite group $G$ (arithmetically, $G = (\mathbb{Z}/\ell)^\times$), we prove that for every subset $A \subseteq G$ and every $n \in G$ the number of ordered factorisations $n = ab$ with $a \in A$ equals $|A|$ — independent of $n$ — whereas the number with $a \in A$ *or* $b \in A$ equals $|A \cup nA^{-1}| = 2|A| - |A \cap nA^{-1}|$, which genuinely varies. In information-theoretic terms the asymmetric mutual information is *identically zero* for every finite group and every target, while the symmetric one is strictly positive for every nontrivial target.

We then compute the symmetric leak in closed form for the arithmetically relevant target $A = \{1\}$ (the event $\ell \mid x - 1$). In a group of order $d$ it equals an explicit function $I(d)$; at $\ell = 3$ this is exactly $\tfrac32 - \tfrac34\log_2 3 \in (0.30, 0.32)$ bits, at $\ell = 5$ it is certified in $(0.0355, 0.036)$, and in general $I(d) < 2/d^2$ with the sharp asymptotic
$$d^2 I(d) \longrightarrow \log_2 e - 1 = 0.442695\ldots$$
so the symmetric leak is asymptotically $(\log_2 e - 1)/(\ell-1)^2$ bits. These predicted values reproduce, to three decimals, the empirically measured leaks $0.313 / 0.036 / 0.015 / 0.005$ at $\ell = 3, 5, 7, 11$.

We classify the invisible targets: the symmetric leak vanishes exactly when the autocorrelation $n \mapsto |A \cap nA^{-1}|$ is constant (the perfect-difference-set condition), which in a finite *commutative* group happens only for $A = \emptyset$ and $A = G$; proper subgroups — hence quadratic-residue and $k$-th-power targets — are the most visible targets, not the least. Operationally, we show that positive information need not be actionable: for $\ell \ge 5$ no function of $N \bmod \ell$ predicts the symmetric event better than a constant guess, and the threshold $|G| \ge 4$ is sharp.

Finally we prove unconditional impossibility results: for every base $\ell > 2$ and *every* modulus $M$, no function of $N \bmod M$ decides $\ell \mid p-1$ (a Dirichlet swap construction), the same for three-factor moduli, no function of $N \bmod 1155$ decides $10$-smoothness of $p-1$, and the publicly computable smoothness bits of $N \pm 1$ are logically independent of the secret bit. A tropicalisation shows the dichotomy is a property of the fibration $G \times G \to G$ valued in an arbitrary commutative monoid, surviving into the min-plus semiring where the symmetric statistic becomes a cheapest-all-factors-cheap cost.

**Keywords:** semiprime factorisation, Pollard $p-1$, smoothness, mutual information, difference sets, autocorrelation, tropical semiring, residue invisibility.

---

## 1. Introduction

### 1.1 Weak instances and the self-hint question

The security of RSA-type systems rests on the difficulty of recovering $p$ and $q$ from $N = pq$. That difficulty is a statement about the *typical* instance. Certain instances are far easier, and the oldest such family is the one exploited by Pollard's $p-1$ method (1974) and, in a more robust form, by Lenstra's elliptic curve method (1987): if a factor $p$ satisfies that $p - 1$ is $B$-smooth — every prime divisor of $p-1$ is at most $B$ — then $p$ can be recovered from $N$ in time roughly $\tilde O(B)$ by computing $\gcd(a^{k} - 1, N)$ for a highly composite exponent $k$.

Empirically, this weakness is common at moderate sizes. In a sample of random $k$-bit semiprimes with $k \in \{14, 16, 18\}$ and up to $2 \times 10^5$ instances per size, between $60\%$ and $78\%$ have a factor $p$ with $p-1$ smooth to the bound $B = 1000$. The base rate agrees with an even-adjusted Dickman estimate $\rho_{\mathrm{even}}(\log(2^k/2)/\log B)$ to within about $0.04$ (the residual gap being a powers-of-two effect: $p-1$ is always even, and its $2$-adic valuation is biased).

This makes the *screening* question urgent. If a large fraction of keys are weak, and if weakness were detectable from the public modulus alone, then an adversary could sort a corpus of public keys and attack only the profitable ones. We call any statistic computable from $N$ and correlated with the secret weakness a **self-hint**. The question of this paper is whether one exists.

### 1.2 Summary of the answer

The answer is no, and the proof strategy is to descend to the atom of smoothness. Full $B$-smoothness of $p-1$ is a conjunction of many divisibility facts; the simplest of them is

$$
\ell \mid p - 1, \qquad \text{equivalently} \qquad p \equiv 1 \pmod \ell
$$

for a small prime $\ell$. If even this atom is invisible in $N$, no proxy assembled from atoms can be visible. And it is invisible — for a structural reason that also explains why a superficially similar question is *not* invisible.

The two questions are

* **asymmetric:** $\ell \mid p - 1$ (about a designated factor);
* **symmetric:** $\ell \mid p - 1$ or $\ell \mid q - 1$ (about the unordered pair).

The measured mutual informations against $N \bmod \ell$ are $0.0000$–$0.0005$ bits for the asymmetric event at every $\ell \in \{3,5,7,11\}$ and every key size, versus $0.313 / 0.036 / 0.015 / 0.005$ bits for the symmetric one. This paper proves that the first column is exactly zero and computes the second column in closed form.

### 1.3 Organisation

Section 2 sets up the group model. Section 3 proves the counting dichotomy. Section 4 converts it into information. Section 5 classifies the invisible targets. Section 6 gives the closed form and its sharp asymptotic. Section 7 treats prediction advantage. Section 8 gives unconditional impossibility results for arbitrary moduli, three-factor moduli, and smoothness itself. Section 9 tropicalises. Section 10 compares with the experimental record. Sections 11–12 discuss applications and open directions.

---

## 2. The model

### 2.1 Reduction to a finite group

Fix an odd prime $\ell$ and consider semiprimes $N = pq$ with $p, q \ne \ell$. Reducing modulo $\ell$ sends $p$ and $q$ to elements $a, b$ of the multiplicative group
$$
G = (\mathbb{Z}/\ell\mathbb{Z})^\times, \qquad |G| = \ell - 1,
$$
and sends $N$ to the product $n = ab$. The divisibility event $\ell \mid p - 1$ becomes $a = 1$, that is, $a \in A$ for the singleton target $A = \{1\}$.

Empirically the residues of random primes equidistribute over $G$, so the natural probabilistic model is:

> **Uniform ordered pair model.** Draw $(a,b)$ uniformly from $G \times G$ and set $n = ab$. The observable is $n$; the secret is a Boolean event determined by $(a,b)$.

All quantitative claims below are theorems in this model, stated for an arbitrary finite group $G$ and an arbitrary target $A \subseteq G$; the arithmetic reading is the special case $G = (\mathbb{Z}/\ell)^\times$, $A = \{1\}$.

### 2.2 Fibres

**Definition 2.1 (fibres).** For a finite group $G$, a subset $A \subseteq G$ and $n \in G$, define
$$
F^{\mathrm{asym}}_A(n) = \{(a,b) \in G\times G : ab = n,\ a \in A\},
$$
$$
F^{\mathrm{sym}}_A(n) = \{(a,b) \in G\times G : ab = n,\ a \in A \text{ or } b \in A\}.
$$

Since $n$ is the observable and the fibre over $n$ has exactly $|G|$ elements (each $a$ determines $b = a^{-1}n$), the conditional probability of the asymmetric (resp. symmetric) event given $n$ is $|F^{\mathrm{asym}}_A(n)|/|G|$ (resp. $|F^{\mathrm{sym}}_A(n)|/|G|$). Everything reduces to counting fibres.

---

## 3. The counting dichotomy

**Theorem 3.1 (asymmetric invisibility).** *For every finite group $G$, every $A \subseteq G$ and every $n \in G$,*
$$
\big|F^{\mathrm{asym}}_A(n)\big| = |A|.
$$
*In particular the count is independent of $n$.*

*Proof.* The map $(a,b) \mapsto a$ is a bijection from $F^{\mathrm{asym}}_A(n)$ to $A$. It lands in $A$ by definition; it is injective because $ab = a b'$ forces $b = b'$ by left cancellation; and it is surjective because for every $a \in A$ the pair $(a, a^{-1}n)$ lies in the fibre. $\square$

The content is that in the fibration $\mu : G\times G \to G$, $\mu(a,b) = ab$, the first-coordinate projection restricted to any fibre is a bijection onto $G$. A one-sided condition therefore pulls back to a set of constant size. The product knows nothing about a designated factor.

**Theorem 3.2 (symmetric count).** *For every finite group $G$, every $A \subseteq G$ and every $n \in G$,*
$$
\big|F^{\mathrm{sym}}_A(n)\big| \;=\; \big|A \cup nA^{-1}\big| \;=\; 2|A| - \big|A \cap nA^{-1}\big|,
$$
*where $nA^{-1} = \{na^{-1} : a \in A\}$.*

*Proof.* Again project to the first coordinate; injectivity is as before. A pair $(a, a^{-1}n)$ in the fibre satisfies the symmetric condition iff $a \in A$ or $a^{-1} n \in A$, and the latter says $a \in nA^{-1}$. So the image is exactly $A \cup nA^{-1}$. For the second equality, $b \mapsto nb^{-1}$ is injective, so $|nA^{-1}| = |A|$, and inclusion–exclusion applies. $\square$

**Definition 3.3 (autocorrelation).** $\alpha_A(n) := |A \cap nA^{-1}|$.

Thus the symmetric count is $2|A| - \alpha_A(n)$: it is constant precisely when the autocorrelation is constant. This is the pivot of the whole theory.

**Corollary 3.4 (the singleton case).** *For $A = \{1\}$,*
$$
\big|F^{\mathrm{asym}}_{\{1\}}(n)\big| = 1 \quad\text{for all } n, \qquad
\big|F^{\mathrm{sym}}_{\{1\}}(n)\big| = \begin{cases} 1 & n = 1,\\ 2 & n \ne 1.\end{cases}
$$

*Proof.* $A \cup nA^{-1} = \{1, n\}$, of size $1$ or $2$ according as $n = 1$ or not. $\square$

Corollary 3.4 *is* the dichotomy: a constant $1$ against a function that takes two values. Dividing by $|G| = \ell - 1$ gives the conditional probabilities

$$
\Pr\big[\ell \mid p-1 \;\big|\; N \equiv n\big] = \frac{1}{\ell - 1} \quad \text{for every } n,
$$
$$
\Pr\big[\ell \mid p-1 \text{ or } \ell \mid q-1 \;\big|\; N \equiv n\big] = \frac{1}{\ell-1} \text{ or } \frac{2}{\ell-1},
$$
the latter according as $n = 1$ or not. At $\ell = 3$ the second value is $2/2 = 1$: certainty.

### 3.1 The exact $\ell = 3$ mechanism, arithmetically

**Theorem 3.5 (forcing modulo 3).** *Let $p, q$ be primes with $p \ne 3 \ne q$ and $N = pq \equiv 2 \pmod 3$. Then $3 \mid p - 1$ or $3 \mid q-1$.*

*Proof.* Neither $p$ nor $q$ is divisible by $3$, so $p, q \equiv 1$ or $2 \pmod 3$. If both are $\equiv 2$ then $N \equiv 4 \equiv 1$, contradiction. Hence at least one is $\equiv 1$, i.e. divisible-by-$3$ predecessor. $\square$

This is the theoretical form of the reported $\Pr(\text{OR}) = 1.000$. The complementary class is genuinely ambiguous: $55 = 5 \cdot 11 \equiv 1 \pmod 3$ has neither factor $\equiv 1$, while $91 = 7 \cdot 13 \equiv 1 \pmod 3$ has both.

**Theorem 3.6 (no residue dial at $\ell = 3$).** *There is no function $f$ with $\big(3 \mid p-1\big) \iff f(N \bmod 3)$ valid for all semiprimes $N = pq$, $p < q$, $p,q \ne 3$.*

*Proof.* $77 = 7\cdot 11$ and $65 = 5 \cdot 13$ are both $\equiv 2 \pmod 3$; $3 \mid 7 - 1$ but $3 \nmid 5 - 1$. $\square$

Both residue classes carry both outcomes — $(77, 65)$ in class $2$ and $(91, 55)$ in class $1$ — so the failure is per-class, not merely on average.

**Remark 3.7 (the $\ell = 3$ forcing is exceptional).** At $\ell = 5$ no residue class forces the symmetric event: $91 = 7\cdot 13 \equiv 1$, $247 = 13 \cdot 19 \equiv 2$, $133 = 7\cdot 19 \equiv 3$, $119 = 7 \cdot 17 \equiv 4$ modulo $5$, and none of these has a factor $\equiv 1 \pmod 5$. Forcing at $\ell = 3$ happens because the fibre has only two elements and the symmetric event occupies two of them.

---

## 4. Information

### 4.1 Mutual information of a finite joint law

**Definition 4.1.** For a joint probability mass function $P$ on a product of finite sets $X \times Y$, the mutual information in bits is
$$
I(P) \;=\; \sum_{x \in X}\sum_{y \in Y} P(x,y) \,\log_2 \frac{P(x,y)}{P_X(x)\,P_Y(y)},
$$
with $P_X(x) = \sum_y P(x,y)$, $P_Y(y) = \sum_x P(x,y)$, and the convention $0\log 0 = 0$.

**Proposition 4.2 (product laws).** *If $P(x,y) = r(x)c(y)$ with $\sum r = \sum c = 1$, then $I(P) = 0$.*

**Proposition 4.3 (Gibbs).** *$I(P) \ge 0$ for every joint law, with strict inequality as soon as $P(x_0,y_0) \ne P_X(x_0)P_Y(y_0)$ for some cell.*

*Proof sketch.* Pointwise, $-P\log\frac{P}{rc} \le rc - P$ from $\log t \le t-1$; summing, the right side telescopes to $1 - 1 = 0$, giving $I \ge 0$. If some cell is off-product the corresponding inequality is strict, so the sum is strictly positive. $\square$

### 4.2 The asymmetric leak is exactly zero

**Definition 4.4.** In the uniform ordered pair model, the joint law of (secret bit "$a \in A$", observable $n = ab$) is
$$
P^{\mathrm{asym}}_A(\varepsilon, n) = \frac{|F^{\mathrm{asym}}_{A_\varepsilon}(n)|}{|G|^2}, \qquad A_{\text{true}} = A,\ A_{\text{false}} = G \setminus A.
$$

**Theorem 4.5 (zero asymmetric leak).** *For every finite group $G$ and every $A \subseteq G$,*
$$
I\big(P^{\mathrm{asym}}_A\big) = 0 \quad \text{exactly}.
$$

*Proof.* By Theorem 3.1, $|F^{\mathrm{asym}}_{A}(n)| = |A|$ and $|F^{\mathrm{asym}}_{G\setminus A}(n)| = |G| - |A|$ for every $n$. Hence
$$
P^{\mathrm{asym}}_A(\varepsilon, n) = \underbrace{\frac{|A_\varepsilon|}{|G|}}_{\text{depends only on }\varepsilon} \cdot \underbrace{\frac{1}{|G|}}_{\text{depends only on } n},
$$
a product law, and Proposition 4.2 applies. $\square$

This is the theoretical counterpart of the measured $0.0000$–$0.0005$ bits: the measurement is not "small", it is structurally zero, and no amount of data would change it. Note the generality — *any* property of the designated factor, not just divisibility.

### 4.3 The $\ell = 3$ tables

At $\ell = 3$ the group is $\{1,-1\}$ and the two $2\times 2$ joint laws are the normalised fibre counts:

$$
P^{\mathrm{asym}} = \begin{pmatrix} 1/4 & 1/4 \\ 1/4 & 1/4\end{pmatrix}, \qquad
P^{\mathrm{sym}} = \begin{pmatrix} 1/4 & 1/4 \\ 1/2 & 0\end{pmatrix},
$$

rows indexed by $n \in \{1,-1\}$ and columns by (event true, event false). The zero in the corner of $P^{\mathrm{sym}}$ is Theorem 3.5: at $n \equiv -1$ every factorisation has a factor equal to $1$.

**Theorem 4.6.** $I(P^{\mathrm{asym}}) = 0$ *and*
$$
I(P^{\mathrm{sym}}) = \tfrac32 - \tfrac34\log_2 3 = 0.311278\ldots \in (0.30, 0.32).
$$

*Proof.* The first table is the product of two uniform marginals. For the second, the row marginals are $(1/2, 1/2)$ and the column marginals are $(3/4, 1/4)$; expanding the four terms and using $\log_2(2/3) = 1 - \log_2 3$, $\log_2(4/3) = 2 - \log_2 3$ gives the closed value. The numerical bracket follows from the certified rational bounds $19/12 < \log_2 3 < 27/17$ (equivalently $2^{19} = 524288 < 531441 = 3^{12}$ and $3^{17} = 129140163 < 134217728 = 2^{27}$). $\square$

The measurement was $0.313$ bits.

### 4.4 Positivity for every $\ell$

**Theorem 4.7 (general positivity).** *For every odd prime $\ell$, the joint law of $(N \bmod \ell,\ \ell \mid p-1 \text{ or } \ell \mid q-1)$ in the uniform ordered pair model has strictly positive mutual information, while the asymmetric law has mutual information exactly $0$.*

*Proof.* By Corollary 3.4 the symmetric count takes two distinct values, so the joint law is not a product of its marginals in the cell $n = 1$; Proposition 4.3 gives strict positivity. The asymmetric half is Theorem 4.5. $\square$

This is the **information dichotomy**: for every modulus, one question leaks nothing and the other leaks something.

---

## 5. Which targets are invisible?

Theorem 4.5 is uniform in $A$; the symmetric side is not, so it invites a classification.

**Theorem 5.1 (classification by fibre constancy).** *For a finite group $G$ and $A \subseteq G$, the symmetric leak vanishes if and only if $|F^{\mathrm{sym}}_A(n)|$ is independent of $n$; equivalently, by Theorem 3.2, if and only if the autocorrelation $\alpha_A(n) = |A \cap nA^{-1}|$ is constant.*

*Proof sketch.* If the count is a constant $k$, the joint law factors as $(\text{uniform in } n) \times (\text{Bernoulli } k/|G|)$ and Proposition 4.2 applies. Conversely, if two counts differ, the joint law is off-product in the corresponding cell and Proposition 4.3 gives $I > 0$. $\square$

Constant autocorrelation is the defining property of a **perfect difference set**: a rare and highly structured configuration. Invisibility is therefore a design condition, not a default.

**Theorem 5.2 (subgroups always leak).** *Let $H \le G$ be a proper subgroup. Then*
$$
\big|F^{\mathrm{sym}}_H(n)\big| = \begin{cases} |H|, & n \in H,\\ 2|H|, & n \notin H,\end{cases}
$$
*so the leak is strictly positive.*

*Proof.* $H \cup nH^{-1} = H \cup nH$. If $n \in H$ this is $H$; otherwise the coset $nH$ is disjoint from $H$ and the union has $2|H|$ elements. Theorem 5.1 finishes. $\square$

This refutes the natural guess that cosets of subgroups are invisible: they are the *most* visible targets, with fibre counts differing by a factor of two. Special cases of arithmetic interest: "$\ell \mid x - 1$" ($H$ trivial), "$x$ is a $k$-th power mod $\ell$", and "$x$ is a quadratic residue mod $\ell$".

**Theorem 5.3 (abelian classification).** *Let $G$ be a finite commutative group and $A \subseteq G$. Then $\alpha_A$ is constant if and only if $A = \emptyset$ or $A = G$. Consequently the symmetric leak is strictly positive for every nontrivial $A$.*

*Proof sketch.* Write $r_A(n) = \#\{(a,b) \in A\times A : ab = n\}$, the representation function; a change of variables shows $\alpha_A = r_A$. For an additive character $\psi$ of $G$ put $S(\psi) = \sum_{a\in A}\psi(a)$. Expanding,
$$
S(\psi)^2 = \sum_{n \in G} r_A(n)\,\psi(n).
$$
If $r_A \equiv c$ then the right side is $c\sum_n \psi(n)$, which vanishes for every nontrivial $\psi$; hence $S(\psi) = 0$ for all $\psi \ne 1$. Fourier inversion of the indicator $\mathbf{1}_A$ then yields $|G|\cdot\mathbf{1}_A(g) = S(1) = |A|$ for every $g$, forcing $|A| \in \{0, |G|\}$. $\square$

**Corollary 5.4 (sharp dichotomy in the abelian case).** *In a finite commutative group, for every target $A$ the asymmetric leak is $0$, and for every nontrivial target the symmetric leak is $>0$.*

Since $(\mathbb{Z}/\ell)^\times$ is cyclic, Corollary 5.4 settles the arithmetic situation completely: **no** nontrivial divisibility-type event on the factors is symmetrically invisible, and **every** event on a designated factor is asymmetrically invisible.

---

## 6. The exact size of the leak, and its rate

### 6.1 Closed form

**Theorem 6.1 (closed form).** *Let $G$ be a finite group of order $d \ge 2$ and $A = \{1\}$. Then the symmetric mutual information equals $I(d)$, where*
$$
I(d) = \frac{1}{d^2}\left[
\log_2\frac{d}{2d-1}
+ (d-1)\log_2\frac{d}{d-1}
+ 2(d-1)\log_2\frac{2d}{2d-1}
+ (d-1)(d-2)\log_2\frac{d(d-2)}{(d-1)^2}
\right].
$$

*Proof sketch.* By Corollary 3.4 the fibre counts are $1$ over $n = 1$ and $2$ over the other $d - 1$ elements. Hence the joint law has cells
$$
\Big(\tfrac{1}{d^2}, \tfrac{d-1}{d^2}\Big) \text{ over } n = 1, \qquad \Big(\tfrac{2}{d^2}, \tfrac{d-2}{d^2}\Big) \text{ over each } n \ne 1,
$$
row marginals $1/d$, and column marginals $\frac{2d-1}{d^2}$ (event true) and $\frac{(d-1)^2}{d^2}$ (event false). Substituting into Definition 4.1 and collecting the four cell types gives exactly the four bracketed terms. $\square$

**Corollary 6.2 (arithmetic instance).** *For every odd prime $\ell$, the mutual information between $N \bmod \ell$ and the symmetric divisibility event is exactly $I(\ell - 1)$.*

### 6.2 Certified values

| $\ell$ | $d = \ell-1$ | exact / certified value | decimal | measured |
|---|---|---|---|---|
| $3$ | $2$ | $\tfrac32 - \tfrac34 \log_2 3$ | $0.311278$ | $0.313$ |
| $5$ | $4$ | $\tfrac{1}{16}(44 - 7\log_2 7 - 15 \log_2 3) \in (0.0355, 0.036)$ | $0.035880$ | $0.036$ |
| $7$ | $6$ | $I(6)$ | $0.014393$ | $0.015$ |
| $11$ | $10$ | $I(10)$ | $0.004837$ | $0.005$ |

The $d = 2$ value coincides with the independently computed $\ell=3$ table value of Theorem 4.6, a consistency check on the closed form. The $d = 4$ bracket uses the certified rational bounds $233/83 < \log_2 7 < 73/26$ and $84/53 < \log_2 3 < 149/94$.

### 6.3 Decay

**Theorem 6.3 (quadratic decay).** *For $d \ge 2$, $I(d) < 2/d^2$; for $d \ge 3$, $I(d) > -3/d^2$; hence $I(d) \to 0$ as $d \to \infty$.*

**Theorem 6.4 (sharp rate).** 
$$
\lim_{d\to\infty} d^2\, I(d) \;=\; \log_2 e - 1 \;=\; 0.442695\ldots
$$

*Proof sketch.* Multiply through by $d^2$ and use the two-sided estimate $\frac{a-b}{a} \le \log\frac{a}{b} \le \frac{a-b}{b}$ (both directions of $\log t \le t-1$) on each of the four logarithms. The dominant contributions come from the third and fourth terms. Writing $\log_2 x = \log x/\log 2$, one obtains the explicit envelope, valid for $d \ge 3$,
$$
-1 + \Big(1 - \frac{1}{2d}\Big)\log_2 e \;\le\; d^2 I(d) \;\le\; -1 + \Big(1 + \frac{1}{d-1}\Big)\log_2 e,
$$
whose two ends both converge to $\log_2 e - 1$. The squeeze theorem finishes. $\square$

Numerically $d^2 I(d) = 1.2451,\ 0.5741,\ 0.5181,\ 0.4837,\ 0.4463,\ 0.4431$ at $d = 2, 4, 6, 10, 100, 1000$, converging to the stated constant from above.

**Interpretation.** The symmetric leak in modulus $\ell$ is asymptotically
$$
I(\ell-1) \sim \frac{\log_2 e - 1}{(\ell-1)^2}\ \text{bits}.
$$
The visible half of the dichotomy is itself asymptotically invisible. The striking $0.313$ bits at $\ell = 3$ is an artefact of $d = 2$, where the two-element fibre is exhausted by a two-element event; the rate $c/d^2$, not $c/d$, is the truth.

---

## 7. Information versus advantage

Mutual information measures correlation, not exploitability. The operational question is whether reading $N \bmod \ell$ lets an adversary *guess* the secret event more accurately than by always answering with the majority.

**Definition 7.1.** Let $s : G \to \mathbb{N}$ record the number of pairs in the fibre over $n$ on which the event holds. A *residue-reading predictor* is a function $f : G \to \{\text{true},\text{false}\}$; its score is
$$
\mathrm{score}(f) = \sum_{n \in G} \begin{cases} s(n), & f(n) = \text{true},\\ |G| - s(n), & f(n) = \text{false},\end{cases}
$$
the number of ordered pairs it classifies correctly out of $|G|^2$.

**Theorem 7.2 (asymmetric: zero advantage).** *For every target $A$, no predictor for the asymmetric event scores more than the better of the two constant predictors.*

*Proof.* By Theorem 3.1, $s \equiv |A|$ is constant, so the pointwise optimum $\max(s(n), |G|-s(n))$ is achieved by a constant predictor. $\square$

**Theorem 7.3 (symmetric: zero advantage above order three).** *Let $A = \{1\}$ and $|G| \ge 4$. Then no predictor for the symmetric event scores more than the constant-false predictor.*

*Proof sketch.* Here $s(n) \in \{1,2\}$ while $|G| - s(n) \ge |G| - 2 \ge 2 \ge s(n)$, so answering "false" is pointwise at least as good in every fibre; summing gives the claim. $\square$

**Theorem 7.4 (sharpness).** *If $|G| = 3$ the Bayes predictor $n \mapsto [n \ne 1]$ scores $6$, strictly beating both constants (which score $5$ and $4$).*

**Corollary 7.5 (positive information, zero advantage).** *For every prime $\ell \ge 5$: the symmetric divisibility event leaks a strictly positive number of bits about $N \bmod \ell$ (Theorem 4.7), and yet no function of $N \bmod \ell$ predicts it better than the trivial constant guess.*

The two statements are not in conflict: the residue shifts the posterior from $\frac{2}{\ell-1}$ to $\frac{1}{\ell-1}$ in one class, but both remain below $\tfrac12$ for $\ell \ge 5$, so the *arg max* never moves. The leaked bits are real and unspendable — a clean separation between information-theoretic correlation and decision-theoretic advantage.

---

## 8. Unconditional impossibility

The results so far concern the ordered-pair model. We now prove impossibility statements about genuine primes, with no probabilistic modelling.

### 8.1 Any modulus

**Theorem 8.1 (swap construction).** *For every $\ell > 2$ and every modulus $M \ge 1$ there exist primes $p_1 < q_1 < p_2 < q_2$ with*
$$
p_1q_1 \equiv p_2q_2 \pmod M, \qquad \ell \mid p_1 - 1, \qquad \ell \nmid p_2 - 1.
$$

*Proof sketch.* Put $Q = \ell M$. Since $\gcd(Q-1, Q) = 1$, Dirichlet's theorem on primes in arithmetic progressions supplies infinitely many primes in each of the classes $1$ and $-1$ modulo $Q$; choose $p_1 \equiv 1$, then $q_1 \equiv -1$ larger, then $p_2 \equiv -1$ larger, then $q_2 \equiv 1$ larger still. Then $p_1q_1 \equiv -1 \equiv p_2q_2 \pmod Q$, hence also modulo $M$. And $\ell \mid Q$, so $p_1 \equiv 1 \pmod \ell$ while $p_2 \equiv -1 \not\equiv 1 \pmod \ell$ (using $\ell > 2$). $\square$

**Theorem 8.2 (no residue self-hint at any modulus).** *For every $\ell > 2$ and every $M \ge 1$ there is no function $f$ with*
$$
\big(\ell \mid p - 1\big) \iff f(N \bmod M) \quad \text{for all semiprimes } N = pq,\ p < q.
$$

*Proof.* The two semiprimes of Theorem 8.1 have equal residues modulo $M$ and opposite secret bits. $\square$

Note that primality of $\ell$ is not needed, and $M$ is arbitrary: no smart choice of modulus, however large or however composite, can help. Specialising to $M = 1155 = 3\cdot 5\cdot 7\cdot 11$ recovers the exact residue tested experimentally.

**Conceptual reading.** The residue of $N$ depends only on the *unordered multiset* $\{p,q\}$ through its product; the asymmetric question depends on the *labelling*. Multiplication destroys the labelling; no post-processing can restore it.

### 8.2 Three factors

Multi-prime moduli behave identically. In a finite group,
$$
\#\{(a,b,c) : abc = n,\ a \in A\} = |A|\cdot|G| \qquad \text{for every } n,
$$
by the bijection $(a,b,c) \mapsto (a,b)$ onto $A \times G$. The symmetric count, by contrast, varies: over $(\mathbb{Z}/3)^\times$ it is $4$ at $n = 1$ and $3$ at $n = -1$.

**Theorem 8.3.** *For every $\ell > 2$ and every $M \ge 1$ there is no function of $N \bmod M$ deciding $\ell \mid p-1$ for three-factor moduli $N = pqr$ with $p<q<r$.*

*Proof sketch.* Extend the swap construction with a third prime chosen $\equiv 1 \pmod{\ell M}$ in both instances, preserving both the residue collision and the disagreement on the secret bit. $\square$

### 8.3 Smoothness itself

**Definition 8.4.** $n$ is *$B$-smooth* if every prime divisor of $n$ is at most $B$.

**Theorem 8.5 (completion lemma).** *For any modulus $M$ and any $u, v$ coprime to $M$, one can complete $u$ and $v$ to semiprimes $u u'$ and $v v'$ that are congruent modulo $M$.*

*Proof sketch.* Dirichlet supplies primes $u' \equiv u^{-1}w$ and $v' \equiv v^{-1}w \pmod M$ for a common target residue $w$. $\square$

**Theorem 8.6 (smoothness is not a residue function).** *No function of $N \bmod 1155$ decides whether $p-1$ is $10$-smooth, for semiprimes $N = pq$ with $p<q$.*

*Proof sketch.* Apply Theorem 8.5 with smaller factors chosen so that one has $p-1$ $10$-smooth (e.g. $p - 1 \mid 2^a3^b5^c7^d$) and the other does not (e.g. $p-1$ divisible by a prime $>10$), completing both to semiprimes with the same residue. $\square$

**Theorem 8.7 (the $N\pm1$ heuristic fails logically).** *All four combinations of the public bit "$N-1$ is $10$-smooth" and the secret bit "$p-1$ is $10$-smooth" occur, witnessed by $N = 253, 1081, 143, 667$. Moreover the full pair of public bits ("$N-1$ smooth?", "$N+1$ smooth?") is insufficient: $253 = 11\cdot 23$ and $1081 = 23 \cdot 47$ share the pair $(\text{true},\text{false})$ and disagree on the secret bit.*

Here $253 - 1 = 252 = 2^2\cdot3^2\cdot7$ is $10$-smooth and $p - 1 = 10$ is $10$-smooth; $1081 - 1 = 1080 = 2^3 3^3 5$ is $10$-smooth while $p - 1 = 22 = 2\cdot 11$ is not. The public bits are not merely weakly correlated with the secret one, as the measured correlations $\le 0.014$ suggest — they are *logically independent* of it.

---

## 9. Tropicalisation

Counting is one evaluation of a fibre among many. The dichotomy is more robust than the counting formulation suggests.

**Theorem 9.1 (fibre transform of a one-sided weight).** *Let $G$ be a finite group, $M$ any commutative monoid, and $f : G \to M$. Then for every $n \in G$,*
$$
\sum_{ab = n} f(a) \;=\; \sum_{a \in G} f(a),
$$
*independent of $n$ (the sum taken in $M$).*

*Proof.* The projection $(a,b)\mapsto a$ is a bijection from the fibre onto $G$; reindex. $\square$

Taking $M = (\mathbb{N},+)$ and $f = \mathbf{1}_A$ recovers Theorem 3.1. Taking $M$ to be the min-plus (tropical) semiring — where "addition" is $\min$ and "multiplication" is $+$ — gives:

**Corollary 9.2 (tropical asymmetric invariance).** *For any cost function $f : G \to \mathbb{N}\cup\{\infty\}$,*
$$
\min_{ab = n} f(a) \;=\; \min_{a \in G} f(a) \qquad \text{for every } n.
$$
*The cheapest factorisation cost measured on the first factor alone does not depend on the product.*

**Theorem 9.3 (tropical symmetric variance).** *The symmetric min-plus statistic*
$$
W_f(n) = \min_{ab=n}\ \max\big(f(a), f(b)\big)
$$
*does depend on $n$: already for $G = (\mathbb{Z}/3)^\times$ with $f(1) = 1$, $f(-1) = 0$, one has $W_f(1) = 0$ and $W_f(-1) = 1$.*

The statistic $W_f$ is exactly the tropical shadow of a smoothness profile: it asks for a factorisation *all of whose factors are cheap*, which is what "$B$-smooth" means when "cheap" means "small prime". So the dichotomy is not an artefact of counting or of Shannon entropy — it is a property of the fibration $\mu : G \times G \to G$ that survives evaluation in any commutative monoid, in particular in the tropical semiring where cost-optimisation lives.

---

## 10. Agreement with the experimental record

The theory above was developed against a measurement campaign on random $k$-bit semiprimes, $k \in \{14, 16, 18\}$, up to $2\times 10^5$ samples per size, with smoothness data obtained by full factorisation of $p-1$, $q-1$, $N-1$, $N+1$, per-prime and joint mutual informations estimated against shuffled-label nulls, and conditional densities tabulated per residue class. Its findings, and their theoretical explanations:

1. **Asymmetric leak $= 0.0000$–$0.0005$ bits** for $\ell = 3,5,7,11$ at every $k$, at the shuffled-null level. *Explanation:* Theorem 4.5 — exactly zero, for every group and every target.
2. **Symmetric leak $= 0.313 / 0.036 / 0.015 / 0.005$ bits**, stable across $k$. *Explanation:* Theorem 6.1 predicts $0.31128 / 0.03588 / 0.01439 / 0.00484$. Stability across $k$ is automatic: the closed form depends only on $\ell$.
3. **Forcing at $\ell = 3$:** $\Pr(\text{OR} \mid N \equiv 2) = 1.000$, while $\Pr(p \equiv 1 \mid N \bmod 3) = 0.497 / 0.501$ against a base rate of $0.499$. *Explanation:* Theorem 3.5 (a theorem, not a statistic) and Theorem 3.1 (the constant $1/(\ell-1)$).
4. **Full smoothness undetectable:** $I(S_{1000}; N \bmod 1155) = 0.006$ bits against a shuffled null of $0.005$. *Explanation:* Theorem 8.6 — no function of $N \bmod 1155$ decides smoothness at all, so any measured signal is estimator bias.
5. **No instance-class self-hint from $N \pm 1$:** correlation $\le 0.014$, $I \le 0.0001$. *Explanation:* Theorem 8.7 — logical independence.
6. **Density is conditioning-invariant:** $\Pr[L(p-1) \le B \mid N \equiv n]$ equals the base rate for every $n$, and the base rate matches an even-adjusted Dickman value to within $\approx 0.04$. *Explanation:* Theorem 3.1 applied to the target $A = \{x : x-1 \text{ smooth}\}$ — the conditional density of *any* property of the designated factor is the unconditional one.
7. **$60$–$78\%$ of these semiprimes are $1000$-weak.** This is why $p-1$ works at all, and it makes the negative result meaningful rather than vacuous: the weak class is large, and still unflaggable.

---

## 11. Discussion and applications

### 11.1 What the dichotomy says

A product remembers the multiset of its factors and forgets the labels. Formally, the fibre of $\mu : G\times G \to G$ over any $n$ is a free orbit of $G$ under $a \mapsto (a, a^{-1}n)$, and any condition depending on a single coordinate pulls back to a set of size independent of $n$. Conditions invariant under the coordinate swap survive, and their visibility is measured by an autocorrelation. This is a very general principle; the arithmetic content lies in identifying $G = (\mathbb{Z}/\ell)^\times$ and $A = \{1\}$.

### 11.2 Cryptographic reading

Three practical consequences:

* **No weak-key screening.** No residue statistic, at any modulus, flags $p-1$ smoothness. An adversary sorting public keys cannot prioritise. The only way to learn whether a key is $p-1$-weak is to run the attack.
* **Positive leaks may be inert.** The symmetric event leaks measurably, yet for $\ell \ge 5$ it confers no prediction advantage at all. Reporting mutual information alone overstates exposure; advantage against the best constant strategy is the operationally meaningful metric.
* **Structured targets are the leaky ones.** Quadratic-residue and $k$-th-power conditions on the factors are, in symmetric form, maximally visible (fibre counts $|H|$ versus $2|H|$). Protocols that expose symmetric predicates of the factors should assume those predicates are partly public; protocols exposing only asymmetric ones lose nothing.

### 11.3 Barriers

The results quantify a known obstruction at the level of divisibility: from public data one can access only swap-invariant functions of the factor pair. The dichotomy makes this precise and gives it an exact price tag: $|A \cup nA^{-1}|$ factorisations visible, $(\log_2 e - 1)/(\ell-1)^2$ bits leaked asymptotically, zero prediction advantage above the smallest modulus. Together with parallel negative results for quadratic-residue leaks, threshold dials, and interval filters, the search for a self-hint — a hint about the secret derived from the public data itself — closes: useful hints must come from genuinely external information.

---

## 12. Future directions

Beyond the results proved here, several directions are natural.

1. **Non-uniform factor distributions.** The uniform ordered-pair model matches equidistribution of prime residues. Chebyshev-type biases in prime residue distributions perturb the marginals; the asymmetric leak should stay zero (the bijection argument is distribution-free once the two factors are exchangeable and independent), but the symmetric leak acquires correction terms worth computing.
2. **Beyond divisibility atoms.** Full $B$-smoothness corresponds to a target set $A_B \subseteq (\mathbb{Z}/M)^\times$ that is not a subgroup. Theorem 5.3 shows it leaks symmetrically; computing $|A_B \cup nA_B^{-1}|$ for realistic $B$ would give the exact symmetric leak of the smoothness event, of which our $\ell$-atoms are the crudest approximation.
3. **Sharper asymptotics for general targets.** We have the exact rate for $A = \{1\}$. For $|A| = m$ fixed, an analogous expansion should give a leak of order $m^2/d^2$ with a computable constant; for $|A| \asymp d/2$ the behaviour is presumably different.
4. **Difference-set targets.** Theorem 5.1 says invisibility is exactly the perfect-difference-set condition, and Theorem 5.3 says this is impossible nontrivially in abelian groups. Nonabelian groups admit nontrivial examples; describing the invisible targets there is a clean combinatorial problem.
5. **Tropical smoothness profiles.** The statistic $W_f(n) = \min_{ab=n}\max(f(a),f(b))$ is the tropical form of smoothness. Its distribution over $n$, for cost functions modelling largest-prime-factor size, is a min-plus analogue of the Dickman function and deserves its own study.

*Directions identified in the course of the present work, restated for completeness:*

- **Fibre dichotomy:** in any finite group, a one-sided condition on a factorisation $n = ab$ has an $n$-independent count $|A|$, while the two-sided condition has count $|A \cup nA^{-1}| = 2|A| - |A \cap nA^{-1}|$.
- **Information form:** the asymmetric mutual information is exactly $0$ for every finite group and every $A$; the symmetric one is $3/2 - (3/4)\log_2 3 \in (0.30, 0.32)$ bits at $\ell = 3$ and strictly positive for every odd prime.
- **Classification:** the symmetric leak vanishes iff the autocorrelation $n \mapsto |A \cap nA^{-1}|$ is constant — the perfect difference-set condition.
- **Unconditional impossibility:** no function of $N \bmod M$ — for any $M$, and for two- or three-factor moduli — computes $\ell \mid p-1$, nor $10$-smoothness of $p-1$; and the $N \pm 1$ smoothness bits are logically independent of the secret bit.
- **Tropicalisation:** the dichotomy is a property of the fibration $G \times G \to G$ valued in an arbitrary commutative monoid, so it survives into the min-plus semiring, where the symmetric statistic becomes a *cheapest factorisation with all factors cheap* cost.
- **Closed form and decay:** the symmetric leak in a finite group of order $d$ equals $I(d)$ exactly; at $\ell = 5$ this is certified in $(0.0355, 0.036)$, matching the measured $0.036$; and $I(d) = O(1/d^2) \to 0$, so the visible half of the dichotomy is itself asymptotically invisible.
- **The sharp rate:** $d^2 I(d) \to \log_2 e - 1 = 0.442695\ldots$, so the symmetric leak is asymptotically exactly $(\log_2 e - 1)/(\ell-1)^2$ bits.
- **Subgroup targets always leak:** for any proper subgroup $H \lneq G$ the symmetric fibre count is $|H|$ on $H$ and $2|H|$ off it, so the leak is strictly positive.

---

## 13. Conclusion

The question "can a semiprime betray that it is $p-1$-weak?" has a complete answer: no. Not through a residue at any modulus, not through the smoothness of $N\pm1$, not through any statistic of the public data, and not for two-factor or three-factor moduli. The reason is structural rather than computational: multiplication in a group destroys the labelling of factors, and every one-sided condition therefore has an $n$-independent fibre count and exactly zero mutual information with the product.

What survives is the symmetric shadow, and it survives in a completely understood way. The symmetric count is $|A \cup nA^{-1}|$; the leak vanishes exactly for perfect difference sets, hence never nontrivially in abelian groups; for the arithmetic target it equals $I(\ell-1)$, which is $0.311$ bits at $\ell = 3$ and decays like $(\log_2 e-1)/(\ell-1)^2$; and for $\ell \ge 5$ it confers no prediction advantage whatsoever. The dichotomy is not confined to counting either: it is a statement about a group fibration, and it reads equally well in the min-plus semiring, where the symmetric statistic becomes the cost of the cheapest factorisation all of whose factors are cheap.

Weakness is common. Weakness is invisible. Both facts are now theorems.
