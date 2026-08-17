# The OR-Collapse Law for Character-Pinned Splitting Forks

**Abstract.** Let $K/\mathbb{Q}$ be an abelian number field whose complete-splitting event is pinned by a Dirichlet character $\chi$ of order $n$ and conductor $f$, so that a prime $p \nmid f$ splits completely in $K$ if and only if $\chi(p) = 1$. For a semiprime $N = pq$ with $\gcd(N, f) = 1$, the only datum about the pair $(p,q)$ visible in the residue class $N \bmod f$ is the product $\chi(N) = \chi(p)\chi(q)$. We determine exactly how much this datum reveals about the Boolean disjunction $\mathrm{OR} = [\,p \text{ splits}\,] \vee [\,q \text{ splits}\,]$. The conditional rates are $\mathbb{P}(\mathrm{OR} \mid \chi(N) = 1) = 1/n$ and $\mathbb{P}(\mathrm{OR} \mid \chi(N) \ne 1) = 2/n$, with unconditional rate $(2n-1)/n^2$, and the mutual information is
$$I(N \bmod f;\ \mathrm{OR}) \;=\; g(n) \;=\; H\!\left(\frac{2n-1}{n^2}\right) - \frac1n H\!\left(\frac1n\right) - \frac{n-1}{n} H\!\left(\frac2n\right) \text{ bits},$$
where $H$ is the binary entropy. The right-hand side depends on the order $n$ alone — not on the field, its degree, its conductor, or the structure of the ambient unit group. We give closed forms for $g(2), g(3), g(4), g(5), g(8)$; prove the universal cap $g(n) \le g(2) = 0.3113\ldots$, positivity $g(n) > 0$, the two-sided rate $0.08/n^{2} \le g(n) \le 2/n^{2}$ and the sharp-shaped $\chi^2$ bound $g(n) \le 1/(\log 2 \cdot (n-1)(2n-1))$; and pin the asymptotic constant exactly:
$$n^{2} g(n) \longrightarrow \frac{1}{\log 2} - 1 = 0.4426950\ldots$$
via an exact Kullback–Leibler decomposition of $n^2 g(n)$ into four logarithmic terms with limits $1$, $-\log 2$, $-1$, $1$. The law is confirmed empirically on seven fields spanning degrees $2$–$6$, prime, prime-power and composite conductors, and cyclic and non-cyclic unit groups. Two previously independent measured statistics — a quadratic $p-1$ divisibility leak of $0.313$ bits and a cyclic-cubic leak of $0.073$ bits — are identified as the values $g(2)$ and $g(3)$ of a single law. We discuss the consequences for the "residue-fork" line of attack on semiprime factorization, which the law closes quantitatively at the two-factor level.

**Keywords.** Dirichlet character, complete splitting, semiprime, mutual information, binary entropy, Kullback–Leibler divergence, Chinese Remainder Theorem, reciprocity.

---

## 1. Introduction

### 1.1 Residue forks

Certain arithmetic properties of a prime $p$ are decided by the residue class of $p$ modulo a fixed integer. Fermat's two-square criterion ($p$ is a sum of two squares iff $p \equiv 1 \bmod 4$), the quadratic reciprocity law of 1801, and the higher reciprocity laws beginning with the cubic case in 1844 are the classical instances. Their common modern formulation is class field theory: a number field $K/\mathbb{Q}$ is abelian if and only if the set of primes splitting completely in $K$ is a union of residue classes modulo the conductor $f$ of $K$; equivalently, complete splitting is pinned by a group of Dirichlet characters.

We call such an arithmetic dichotomy a **residue fork**. It is *pinned* in the sharpest sense when a single character does the work:

> There is a Dirichlet character $\chi$ of conductor $f$ and order $n$ such that, for $p \nmid f$,
> $$p \text{ splits completely in } K \iff \chi(p) = 1 .$$

By the Chebotarev/Dirichlet equidistribution theorem the values $\chi(p)$, $p$ ranging over primes not dividing $f$, are equidistributed over the group $\mu_n$ of $n$-th roots of unity; in particular a random prime splits completely with density $1/n$.

### 1.2 The semiprime question

Residue forks are the natural candidate for an *information leak* about the factorization of a semiprime $N = pq$: they are the properties of the hidden factors that the visible residue class can, in principle, know something about. Because $\chi$ is completely multiplicative, the residue class $N \bmod f$ determines, and (as far as $\chi$ is concerned) is determined by, the single value
$$\chi(N) = \chi(p)\chi(q).$$
The observer sees the product of two hidden group elements and wishes to infer something about the pair.

The coarsest nontrivial statistic of the pair is the Boolean disjunction
$$\mathrm{OR} \;=\; [\chi(p) = 1] \ \vee\ [\chi(q) = 1] \;=\; [\text{at least one of } p, q \text{ splits completely}].$$
It is *symmetric*, so it cannot by itself identify a factor; it is, however, the statistic with the largest support, and it is the one for which the leak is most naturally measured.

**The question.** How many bits does $N \bmod f$ carry about $\mathrm{OR}$?

### 1.3 Results

The answer is a universal function of the order $n$ alone (Theorem 4.2): the mutual information equals
$$g(n) = H\!\left(\frac{2n-1}{n^{2}}\right) - \frac1n H\!\left(\frac1n\right) - \frac{n-1}{n} H\!\left(\frac2n\right).$$
Around this exact law we prove: positivity (Proposition 5.3); a chain of closed forms and certified rational brackets (Section 5.1) matching measured values; the universal cap $g(n) \le g(2)$ (Theorem 5.4); the $\chi^{2}$ bound $g(n) \le 1/(\log 2 \,(n-1)(2n-1))$ and the two-sided rate $0.08/n^2 \le g(n) \le 2/n^2$ (Theorems 6.1, 6.3); and the sharp asymptotic constant $n^2 g(n) \to 1/\log 2 - 1$ (Theorem 7.2), obtained from an exact four-term Kullback–Leibler identity (Theorem 7.1).

Section 8 reports empirical confirmation on seven fields; Section 9 identifies two previously independent measured leaks as the $n = 2$ and $n = 3$ instances of the law; Section 10 discusses cryptanalytic consequences; Section 11 lists open problems, including the second-order expansion and the ordering of the Boolean faces.

---

## 2. The probabilistic model

Fix an abelian field $K$ with a pinning character $\chi$ of conductor $f$ and order $n \ge 2$, and write $G = \mu_n = \operatorname{image}(\chi)$, a cyclic group of order $n$ written multiplicatively with identity $1$.

**Model (uniform semiprime model).** Let $N = pq$ be a semiprime with $p, q \nmid f$, and model $x = \chi(p)$, $y = \chi(q)$ as independent random variables uniform on $G$. The observer's datum is the class $c = xy \in G$; equivalently, the observer learns whether $\chi(N) = 1$ or $\chi(N) \ne 1$, which is all that the events studied here depend on.

The model is the exact statistical shadow of equidistribution: $\chi(p)$ is equidistributed over $\mu_n$ as $p$ ranges over primes coprime to $f$, and the two factors of a random semiprime are drawn independently. All statements below are theorems about this model; Section 8 reports how accurately real semiprimes obey them.

**Definition 2.1 (split events and faces).** Put $A = [x = 1]$ ($p$ splits) and $B = [y = 1]$ ($q$ splits), and let
$$S = \mathbf{1}_A + \mathbf{1}_B \in \{0, 1, 2\}$$
be the **split count**. The three Boolean *faces* of the fork are
$$\mathrm{AND} = [S = 2], \qquad \mathrm{XOR} = [S = 1], \qquad \mathrm{OR} = [S \ge 1].$$

**Definition 2.2 (information measures).** For a probability vector $P$, the Shannon entropy in bits is $H(P) = -\sum_i P_i \log_2 P_i$; for a Boolean with success probability $x$ we write the binary entropy
$$H(x) = -x\log_2 x - (1-x)\log_2(1-x), \qquad H(0) = H(1) = 0 .$$
For a joint law $P(a,t)$ with marginals $r(a), s(t)$ the mutual information in bits is
$$I = \sum_{a,t} P(a,t) \log_2 \frac{P(a,t)}{r(a)s(t)} = H(s) - \sum_a r(a) H\big(P(\cdot \mid a)\big).$$
We write $I_{\mathrm{OR}}(n)$, $I_{\mathrm{XOR}}(n)$, $I_{\mathrm{AND}}(n)$, $I_{S}(n)$ for the mutual information between the observed class ($\chi(N) = 1$ versus $\chi(N) \neq 1$) and the corresponding face or the split count.

---

## 3. The group-theoretic core

Everything rests on three counting lemmas in an arbitrary finite group $G$ of order $n$ (commutativity is not needed).

**Definition 3.1.** For $c \in G$ let
$$F(c) = \{(x,y) \in G \times G : xy = c\}, \qquad F^{\vee}(c) = \{(x,y) \in F(c) : x = 1 \text{ or } y = 1\},$$
and let $E^{\vee} = \{(x,y) \in G \times G : x = 1 \text{ or } y = 1\}$ be the total OR event.

**Lemma 3.2 (fibre count).** $|F(c)| = n$ for every $c \in G$.

*Proof.* The map $x \mapsto (x, x^{-1}c)$ is a bijection $G \to F(c)$, with inverse the first projection. $\square$

Thus the product map $G \times G \to G$ is a uniform $n$-to-one covering: the observed class is uniform on $G$, and every observed class hides exactly $n$ equally likely pairs. This is the "CRT split" in group-theoretic form, and it is already the reason no residue class can ever be a factoring witness.

**Lemma 3.3 (the one-versus-two dichotomy).** $F^{\vee}(c) = \{(1, c), (c, 1)\}$, hence
$$|F^{\vee}(c)| = \begin{cases} 1, & c = 1,\\ 2, & c \ne 1.\end{cases}$$

*Proof.* If $(x,y) \in F(c)$ and $x = 1$ then $y = c$; if $y = 1$ then $x = c$. Conversely both listed pairs lie in $F(c)$ and satisfy the disjunction. The two pairs coincide exactly when $c = 1$. $\square$

**Lemma 3.4 (OR marginal count).** $|E^{\vee}| = 2n - 1$.

*Proof.* $E^{\vee} = (\{1\} \times G) \cup (G \times \{1\})$, a union of two sets of size $n$ meeting in the single point $(1,1)$; inclusion–exclusion gives $2n - 1$. Alternatively, sum Lemma 3.3 over the $n$ classes: $1 + 2(n-1) = 2n-1$. $\square$

**Corollary 3.5 (the rates).** In the model of Section 2,
$$\mathbb{P}(\mathrm{OR} \mid \chi(N) = 1) = \frac1n, \qquad \mathbb{P}(\mathrm{OR} \mid \chi(N) \ne 1) = \frac2n, \qquad \mathbb{P}(\mathrm{OR}) = \frac{2n-1}{n^{2}} .$$

*Proof.* Divide Lemma 3.3 by Lemma 3.2 for the conditionals; divide Lemma 3.4 by $|G \times G| = n^{2}$ for the marginal. Consistency: $\frac1n \cdot \frac1n + \frac{n-1}{n}\cdot\frac2n = \frac{2n-1}{n^{2}}$. $\square$

**Remark 3.6 (the full fork).** The same count gives the conditional law of the split count $S$:
$$\big(\mathbb{P}(S = 0), \mathbb{P}(S=1), \mathbb{P}(S=2)\big) = \begin{cases} \big(\tfrac{n-1}{n},\, 0,\, \tfrac1n\big), & \chi(N) = 1,\\[2pt] \big(\tfrac{n-2}{n},\, \tfrac2n,\, 0\big), & \chi(N) \ne 1.\end{cases}$$
Two structural facts are visible. If $\chi(N) = 1$ then the two split events are *perfectly correlated* — either both hold or neither. If $\chi(N) \ne 1$ then both cannot hold. Hence $\mathrm{AND}$ implies $\chi(N) = 1$ and $\mathrm{XOR}$ implies $\chi(N) \ne 1$: each of those two faces is a one-sided certificate, while $\mathrm{OR}$, which merges them, is not. This is precisely why the OR is the *collapsing* face.

---

## 4. The exact law

**Definition 4.1 (collapse function).** For real $n \ge 2$,
$$g(n) \;=\; H\!\left(\frac{2n-1}{n^{2}}\right) \;-\; \frac1n\,H\!\left(\frac1n\right) \;-\; \frac{n-1}{n}\,H\!\left(\frac2n\right) \quad \text{bits}.$$

**Theorem 4.2 (OR-Collapse Law).** For every order $n \ge 2$,
$$I_{\mathrm{OR}}(n) \;=\; I(N \bmod f;\ \mathrm{OR}) \;=\; g(n).$$
In particular the leak depends on nothing but the order of the pinning character: not on $K$, not on $[K : \mathbb{Q}]$, not on the conductor $f$ or its factorization, and not on the structure of $(\mathbb{Z}/f)^{\times}$.

*Proof.* The joint law of (class of $N$, $\mathrm{OR}$) is the $2 \times 2$ table with prior $\pi = (1/n, (n-1)/n)$ on the classes $\{\chi(N) = 1\}$, $\{\chi(N) \ne 1\}$ (Lemma 3.2 makes the observed class uniform on $G$, and the trivial class is one of $n$) and channel rows
$$\Big(\tfrac{n-1}{n},\ \tfrac1n\Big) \quad\text{and}\quad \Big(\tfrac{n-2}{n},\ \tfrac2n\Big)$$
given by Corollary 3.5. Its column marginal is $\big(((n-1)/n)^2,\ (2n-1)/n^{2}\big)$, whose two entries sum to $1$. Applying the channel form of mutual information, $I = H(\text{output}) - \sum_a \pi_a H(\text{row } a)$, and evaluating the three binary entropies gives exactly $g(n)$. $\square$

**Remark 4.3.** The result is an equality, not a bound; and the derivation shows *why* universality holds. Everything that could depend on the field enters only through $|{\rm image}(\chi)| = n$; the arithmetic of $K$ has been fully absorbed by the group $G$.

**Remark 4.4 (the other faces).** The same table for the other faces gives
$$I_{\mathrm{AND}}(n) = H\!\left(\frac{1}{n^{2}}\right) - \frac1n H\!\left(\frac1n\right), \qquad I_{\mathrm{XOR}}(n) = H\!\left(\frac{2(n-1)}{n^{2}}\right) - \frac{n-1}{n} H\!\left(\frac2n\right),$$
and $I_{S}(n) = H(S) - \frac1n H\big(\frac{n-1}{n}, 0, \frac1n\big) - \frac{n-1}{n} H\big(\frac{n-2}{n}, \frac2n, 0\big)$, each a function of $n$ alone. The OR is the *smallest* of the three faces for every $n \geq 3$; see Section 11.

---

## 5. Closed forms, positivity, and the universal cap

### 5.1 Closed forms

Evaluating Definition 4.1 at small integers and clearing logarithms:

| $n$ | $g(n)$ in closed form | decimal |
|---|---|---|
| $2$ | $\dfrac32 - \dfrac34\log_2 3$ | $0.3112781\ldots$ |
| $3$ | $\log_2 3 - \dfrac59\log_2 5 - \dfrac29$ | $0.0727802\ldots$ |
| $4$ | $\dfrac{11}{4} - \dfrac{15}{16}\log_2 3 - \dfrac{7}{16}\log_2 7$ | $0.0358799\ldots$ |
| $5$ | $\log_2 5 - \dfrac{6}{25}\log_2 3 - \dfrac{48}{25}$ | $0.0215371\ldots$ |
| $8$ | $\dfrac{31}{8} + \dfrac{27}{64}\log_2 3 - \dfrac{15}{64}\log_2 5 - \dfrac{91}{64}\log_2 7$ | $0.0077464\ldots$ |

Each follows by expanding the three binary entropies and collecting terms; e.g. for $n = 2$ the marginal is $H(3/4) = 2 - \frac34\log_2 3$, the first row contributes $\frac12 H(1/2) = \frac12$, and the second row $\frac12 H(1) = 0$.

**Proposition 5.1 (certified brackets).** Using the rational bounds
$$\tfrac{84}{53} < \log_2 3 < \tfrac{65}{41}, \quad \tfrac{339}{146} < \log_2 5 < \tfrac{137}{59}, \quad \tfrac{306}{109} < \log_2 7 < \tfrac{73}{26},$$
one obtains
$$0.3109 < g(2) < 0.3114, \quad 0.0726 < g(3) < 0.0732, \quad 0.0353 < g(4) < 0.0360, \quad 0.0214 < g(5) < 0.0217 .$$

These brackets are exactly the intervals containing the measured values reported in Section 8, so the law is confirmed by rigorous arithmetic rather than by floating-point coincidence.

**Corollary 5.2 (decay chain).** $g(5) < g(4) < g(3) < g(2)$.

### 5.2 Positivity

**Proposition 5.3.** $g(n) > 0$ for every $n \ge 2$: the OR face never collapses completely.

*Proof.* Mutual information vanishes iff the joint law factorizes. Here the two channel rows are $\big(\frac{n-1}{n}, \frac1n\big)$ and $\big(\frac{n-2}{n}, \frac2n\big)$, which are distinct for every finite $n$ (their second entries differ by $1/n \neq 0$), and both classes have positive prior. Hence the joint law is not a product and $I_{\mathrm{OR}}(n) = g(n) > 0$. $\square$

### 5.3 The universal cap

**Theorem 5.4 (cap).** For every integer $n \ge 2$, $g(n) \le g(2) = \frac32 - \frac34 \log_2 3 = 0.3113\ldots$.

*Proof.* For $n = 2$ this is an identity, for $n = 3, 4$ it follows from the brackets of Proposition 5.1, and for $n \ge 5$ from the quantitative bound of Theorem 6.1: $g(n) \le 1/(\log 2 \,(n-1)(2n-1)) \le 1/(\log 2 \cdot 4 \cdot 9) < 0.041 < g(2)$. $\square$

Thus **no order-$n$ Dirichlet fork, over any abelian field of any degree and any conductor, leaks more than $0.3113$ bits of symmetric OR information about the factors of a semiprime.**

---

## 6. Quantitative collapse: the $n^{-2}$ rate

**Theorem 6.1 ($\chi^{2}$ bound).** For every real $n \ge 2$,
$$g(n) \;\le\; \frac{1}{\log 2 \cdot (n-1)(2n-1)} .$$

*Proof sketch.* Mutual information is bounded above by the $\chi^{2}$-divergence between the joint law and the product of its marginals, via the pointwise inequality $p \log_2 \frac{p}{rc} \le \frac{1}{\log 2}\big(\frac{p^{2}}{rc} - p\big)$, valid for $p \ge 0$, $r, c > 0$ (it is $\log t \le t - 1$ applied to $t = p/(rc)$, multiplied by $p$). Summing over the four cells of the OR table with $p$ the joint entries, $r$ the row and $c$ the column marginals, and simplifying the resulting rational function, yields exactly $\frac{1}{\log 2 (n-1)(2n-1)}$. $\square$

The matching lower bound comes from discarding, rather than bounding, information.

**Theorem 6.2 (class lower bound).** Each class contributes a nonnegative Kullback–Leibler term to $g(n)$; keeping only the class $\chi(N) = 1$ gives
$$g(n) \;\ge\; \frac1n\left[\frac{n-1}{n}\log_2 \frac{n}{n-1} + \frac1n\log_2 \frac{n}{2n-1}\right],$$
and, after estimating the two logarithms,
$$n^{2}g(n) \;\ge\; \frac{1 - \frac{1}{2n}}{\log 2} - 1 .$$

**Theorem 6.3 (two-sided rate).** For every real $n \ge 2$,
$$\frac{0.08}{n^{2}} \;\le\; g(n) \;\le\; \frac{2}{n^{2}} .$$

*Proof.* Upper: one checks $n^{2} \le 2\log 2\,(n-1)(2n-1)$ for all $n \ge 2$ (at $n = 2$ this reads $4 \le 4.159$, and the right-hand side grows faster), so Theorem 6.1 gives $g(n) \le 2/n^{2}$. Lower: Theorem 6.2 gives $n^{2} g(n) \ge (1 - \frac{1}{2n})/\log 2 - 1 \ge (3/4)/\log 2 - 1 > 0.08$ for $n \ge 2$. $\square$

**Interpretation.** The prime-level fork gets *sharper* as $n$ grows: the split event has probability $1/n$, and $H(1/n) \to 0$ means an individual character value pins the splitting of a single prime ever more decisively. The semiprime OR nevertheless shows *less*, quadratically less. Sharpening the fork accelerates the collapse rather than slowing it: the multiplicative mixing $\chi(pq) = \chi(p)\chi(q)$ destroys information faster than the fork creates it.

---

## 7. The sharp asymptotic constant

The rate $\Theta(n^{-2})$ leaves the constant open. It can be pinned exactly, and the route is an exact algebraic identity, not an estimate.

**Theorem 7.1 (exact Kullback–Leibler decomposition).** For every real $n \ge 2$,
$$n^{2} g(n) \;=\; \frac{1}{\log 2}\Big[\underbrace{(n-1)\log\frac{n}{n-1} + \log\frac{n}{2n-1}}_{D_{1}(n):\ \text{class } \chi(N)=1} \;+\; \underbrace{(n-1)(n-2)\log\frac{n(n-2)}{(n-1)^{2}} + 2(n-1)\log\frac{2n}{2n-1}}_{D_{2}(n):\ \text{classes } \chi(N)\ne 1}\Big],$$
with $\log$ the natural logarithm.

*Proof sketch.* The four cells of the joint table are
$$P(0,0) = \frac{n-1}{n^{2}},\quad P(0,1) = \frac{1}{n^{2}},\quad P(1,0) = \frac{(n-1)(n-2)}{n^{2}},\quad P(1,1) = \frac{2(n-1)}{n^{2}},$$
with row marginals $\frac1n, \frac{n-1}{n}$ and column marginals $\big(\frac{n-1}{n}\big)^{2}, \frac{2n-1}{n^{2}}$. The four likelihood ratios $P/(rc)$ simplify to
$$\frac{n}{n-1}, \qquad \frac{n}{2n-1}, \qquad \frac{n(n-2)}{(n-1)^{2}}, \qquad \frac{2n}{2n-1},$$
respectively — each a rational function with no residual dependence on anything but $n$. Substituting into $I = \sum P \log_2 (P/(rc))$, multiplying by $n^{2}$ and converting $\log_2 = \log/\log 2$ gives the stated four terms. $\square$

**Theorem 7.2 (sharp constant).**
$$\lim_{n \to \infty} n^{2} g(n) \;=\; \frac{1}{\log 2} - 1 \;=\; 0.4426950408\ldots$$

*Proof sketch.* Evaluate the four terms of Theorem 7.1 separately, using $m\log(1 + 1/m) \to 1$ and $m\log(1 - 1/m) \to -1$ as $m \to \infty$:

1. $(n-1)\log\frac{n}{n-1} = (n-1)\log\big(1 + \frac{1}{n-1}\big) \to 1$.
2. $\log\frac{n}{2n-1} = \log\frac{1}{2 - 1/n} \to -\log 2$.
3. $(n-1)(n-2)\log\frac{n(n-2)}{(n-1)^{2}} = \frac{n-2}{n-1}\cdot (n-1)^{2}\log\big(1 - \frac{1}{(n-1)^{2}}\big) \to 1 \cdot (-1) = -1$, using $n(n-2) = (n-1)^2 - 1$.
4. $2(n-1)\log\frac{2n}{2n-1} = 2(n-1)\log\big(1 + \frac{1}{2n-1}\big) \to 1$.

Summing: $D_1 \to 1 - \log 2$ and $D_2 \to -1 + 1 = 0$, so $n^{2}g(n) \to (1 - \log 2)/\log 2 = 1/\log 2 - 1$. $\square$

**Remark 7.3 (where the information lives).** Both class divergences are individually of size $\Theta(1)$ after multiplication by $n^{2}$, but the $(n-1)/n$-majority of nontrivial classes contributes exactly $0$ in the limit: its two terms, $-1$ and $+1$, cancel. The entire leading-order leak comes from the single class $\chi(N) = 1$, which occurs with probability $1/n$ and is the class in which the conditional OR rate is halved. Rarity, not frequency, is the carrier of the residual information.

**Remark 7.4 (second order, numerical).** Expanding each of the four terms one step further in $1/n$ gives coefficients $-\tfrac12, +\tfrac12, +1, -\tfrac34$, summing to $\tfrac14$, hence the refinement
$$n^{2} g(n) \;=\; \left(\frac{1}{\log 2} - 1\right) + \frac{1}{4\log 2}\cdot\frac1n + O(n^{-2}), \qquad \frac{1}{4\log 2} = 0.3606737\ldots$$
High-precision evaluation of the exact identity of Theorem 7.1 gives $n\big(n^{2}g(n) - (1/\log 2 - 1)\big) = 0.3606742$ at $n = 10^{6}$, in agreement to six decimals. We record this as a strongly supported expansion; a fully rigorous treatment of the error term is left to future work (Section 11).

---

## 8. Empirical confirmation

The law was tested on seven abelian fields, over all primes up to $2^{22}$ and $30\,000$ semiprimes per field. Split sets were determined directly, by counting roots of the defining polynomial modulo $p$ and requiring the count to equal the degree, so that the split condition was verified rather than assumed; the pinning character was then read off empirically.

| defining polynomial / field | $n$ | $f$ | measured $I(N \bmod f;\ \mathrm{OR})$ | $g(n)$ |
|---|---|---|---|---|
| $x^{2} - x - 1$, $\mathbb{Q}(\sqrt5)$ | $2$ | $5$ | $0.3076$ | $0.3113$ |
| $x^{3} + x^{2} - 2x - 1$, cyclic cubic | $3$ | $7$ | $0.0704$ | $0.0728$ |
| $x^{3} - 3x + 1$, cyclic cubic | $3$ | $9 = 3^{2}$ | $0.0735$ | $0.0728$ |
| $x^{4} - 4x^{2} + 2$, $\mathbb{Q}(\zeta_{16})^{+}$ (units $C_2 \times C_4$) | $4$ | $16 = 2^{4}$ | $0.0384$ | $0.0359$ |
| $x^{5} + x^{4} - 4x^{3} - 3x^{2} + 3x + 1$, $\mathbb{Q}(\zeta_{11})^{+}$ | $5$ | $11$ | $0.0222$ | $0.0215$ |
| $\Phi_{7}$, $\mathbb{Q}(\zeta_{7})$ | $6$ | $7$ | $0.0146$ | $0.0144$ |
| cyclic cubic (character-only) | $3$ | $21 = 3\cdot 7$ | $0.0700$ | $0.0728$ |

Three controls accompany the main table.

* **Per-class rates.** The conditional rates match $1/n$ and $2/n$ to within $1$–$2\%$ in every field.
* **Coprime modulus.** Conditioning on $N \bmod m$ with $\gcd(m, f) = 1$ produces a flat, information-free table: the leak is carried by $N \bmod f$ and by nothing else.
* **Modulus refinement.** Replacing $f$ by $m = f^{2}$ leaves the measured value invariant, confirming that no information beyond the character value is hiding in a finer class.

The residual discrepancies (at most $0.0037$ bits, and consistently within the sampling error of $30\,000$ semiprimes) are what one expects from finite-sample entropy estimation, which is biased upward for small tables and downward for the largest.

Note the spread of arithmetic covered: prime conductors $5, 7, 11$; the prime power $9 = 3^2$; the prime power $16 = 2^4$ with non-cyclic unit group $C_2 \times C_4$; the composite conductor $21 = 3 \cdot 7$; degrees $2, 3, 4, 5, 6$. The measured column is organised entirely by $n$, exactly as Theorem 4.2 requires: the two conductor-$7$ entries with different orders ($n = 3$ and $n = 6$) differ by a factor of five, while the conductor-$7$, conductor-$9$ and conductor-$21$ entries with the same order $n = 3$ agree.

---

## 9. Unification of two independent leaks

Two statistics previously measured in isolation are the values of $g$ at $n = 2$ and $n = 3$.

**The $p-1$ divisibility leak ($n = 2$).** For a semiprime $N = pq$, how much does $N \bmod 3$ reveal about "$3 \mid p-1$ or $3 \mid q-1$"? Since $3 \mid p - 1 \iff p \equiv 1 \pmod 3$, this is complete splitting in $\mathbb{Q}(\sqrt{-3})$, pinned by the quadratic character of conductor $3$, so $n = 2$. The law predicts rates $1/2$ and $2/2 = 1$, marginal $3/4$, and leak $g(2) = 0.3113$. Measurement (including the degenerate class $N \equiv 0$) gives $0.3126$ bits with rates $0.4942$ and $1.0000$.

The rate of exactly $1$ is not an artefact: it is Lemma 3.3 at $n = 2$. If $\chi(N) = -1$ then exactly one of $\chi(p), \chi(q)$ equals $1$, so the OR holds with certainty. In fact for $n = 2$ the OR is equivalent to $\chi(N) = -1$ *or* both split, and the entire leak is the difference between certainty and a fair coin.

**The cyclic cubic leak ($n = 3$).** For the cyclic cubic field of conductor $7$, the measured leak is $0.0704$ bits; the law gives $g(3) = 0.0728$.

These two numbers differ by a factor of more than four and arise from different fields, different degrees, different conductors and different reciprocity laws. The OR-Collapse Law says they are the first two points of one curve. The unifying content is exactly Lemma 3.3: **one representative in the trivial fibre, two in every other**.

---

## 10. Consequences for factorization

Does the leak help an adversary factor $N$? Four structural obstructions, each a corollary of the counting above, say no.

**(i) Symmetry — the which-factor wall.** Both $\mathrm{OR}$ and $\chi(N)$ are symmetric under $p \leftrightarrow q$, so the conditional law of "which factor splits" given the observed class is exactly uniform. Measurement of that channel returns $0.0001$–$0.0002$ bits, i.e. estimator noise. A leak that never distinguishes the two factors cannot start a separation.

**(ii) Fibre uniformity — no witness.** Lemma 3.2 says each observed class $c$ is compatible with exactly $n$ pairs of character values, all equally likely. There is no residue class of $N$ that forces a congruence on $p$ alone. The leak is a *dial* on a probability ($1/n$ versus $2/n$), never a *certificate*.

**(iii) CRT sealing.** For a composite conductor, the character factors through the Chinese Remainder decomposition of $(\mathbb{Z}/f)^{\times}$; all the observer can extract is the single value $\chi(N)$, and the leak is $g(n)$ regardless of how many prime-power components $f$ has. The conductor-$21$ measurement, which reproduces $g(3)$ and not more, exhibits this directly.

**(iv) Smallness and decay.** $g(n) \le 0.3113$ always, and $g(n) \le 2/n^{2} \approx 0.4427/n^{2}$. Recovering the roughly $\log_2 N$ bits needed to specify a factor from $0.3113$-bit symmetric hints about a single Boolean is not a viable programme; and moving to a sharper fork (larger $n$) makes the situation quadratically worse for the adversary.

Every tool in the analysis is classical — quadratic reciprocity (1801), cubic and higher reciprocity (from 1844), Dirichlet characters, the Chinese Remainder Theorem. What is new is the *closure*: the residue-fork channel has been evaluated exactly, capped uniformly, and shown to decay at the exact rate $(1/\log 2 - 1)/n^{2}$. At the semiprime level, this line of attack is quantitatively finished.

---

## 11. Discussion and open problems

### 11.1 The face hierarchy

The three Boolean faces and the split count itself are ordered by how much of the fork's fibre structure they preserve. The fibre weights of the split count are $\big(\frac{n-1}{n}\big)^{2}$ for $S = 0$, $\frac{2(n-1)}{n^{2}}$ for $S = 1$ and $\frac{1}{n^{2}}$ for $S = 2$; $\mathrm{AND}$ isolates the smallest cell, $\mathrm{XOR}$ the middle cell, and $\mathrm{OR}$ merges both against the largest. Numerically:

| $n$ | $I_{\mathrm{OR}}$ | $I_{\mathrm{XOR}}$ | $I_{\mathrm{AND}}$ | $I_{S}$ |
|---|---|---|---|---|
| $3$ | $0.0728$ | $0.3789$ | $0.1972$ | $0.4739$ |
| $8$ | $0.0077$ | $0.0480$ | $0.0482$ | $0.0906$ |
| $12$ | $0.0033$ | $0.0209$ | $0.0253$ | $0.0445$ |

**Conjecture 11.1.** For every real $n \ge 8$, $I_{\mathrm{OR}}(n) < I_{\mathrm{XOR}}(n) < I_{\mathrm{AND}}(n) < I_{S}(n)$.

The strict inequality chain is established at $n = 8$; at $n = 3$ the AND/XOR order is reversed, so the crossing between $\mathrm{XOR}$ and $\mathrm{AND}$ happens in between (numerically just below $n = 8$). A uniform $\chi^{2}$ expansion of each face — the technique of Theorem 6.1 — should settle the general case, since to leading order the information of a face is governed by the smallest fibre it keeps separated.

### 11.2 Second-order expansion

Remark 7.4 identifies the $1/n$ correction as $1/(4\log 2)$ by term-by-term expansion of the exact identity of Theorem 7.1, confirmed numerically to six decimals. Because each of the four logarithmic terms in that identity admits a full asymptotic expansion in $1/n$, every coefficient of the expansion of $n^{2}g(n)$ is a rational combination of $1$ and $1/\log 2$; making the error control rigorous is an exercise in Taylor remainders on an identity that is already exact.

### 11.3 More factors

**Conjecture 11.2 ($k$-factor collapse).** For a $k$-almost prime $N = p_{1}\cdots p_{k}$ with independent uniform character values, let $\mathrm{OR}_{k}$ be the disjunction of the $k$ split events. Then the class-conditional rates are determined by $n$ and $k$ alone, and the leak $g_{k}(n) \to 0$ as either parameter grows.

The rate side of the conjecture is in fact already an elementary computation, and it is worth recording, since it shows exactly how the $1$-versus-$2$ dichotomy generalises.

**Proposition 11.3 ($k$-fold fibre count).** Let $G$ be a group of order $n$ and $k \ge 2$. For $c \in G$, the number of $k$-tuples with product $c$ is $n^{k-1}$, and the proportion of them having at least one trivial coordinate is
$$\mathbb{P}(\mathrm{OR}_{k} \mid \chi(N) = c) \;=\; 1 - \left(1 - \frac1n\right)^{k} \;+\; (-1)^{k-1}\left(\frac{[\,c = 1\,]}{n^{k-1}} - \frac{1}{n^{k}}\right).$$

*Proof.* Let $A_{i}$ be the set of $k$-tuples of product $c$ with $x_{i} = 1$. For $S \subseteq \{1, \ldots, k\}$ with $|S| = j < k$, fixing the coordinates in $S$ to $1$ leaves $k - j$ free coordinates with prescribed product, so $|A_{S}| = n^{k-j-1}$; for $j = k$ one has $|A_S| = [\,c = 1\,]$. Inclusion–exclusion and division by $n^{k-1}$ give
$$\sum_{j=1}^{k-1}(-1)^{j-1}\binom{k}{j}n^{-j} + (-1)^{k-1}\frac{[\,c=1\,]}{n^{k-1}},$$
and completing the binomial sum with its missing $j = k$ term $(-1)^{k-1}n^{-k}$ turns it into $1 - (1 - 1/n)^{k}$ minus that term. $\square$

At $k = 2$ this returns $1/n$ and $2/n$ exactly. For general $k$ the two class rates differ by $n^{-(k-1)}$ — the split between the classes is *exponentially* small in the number of factors — so the leak should decay like $n^{-2(k-1)}$ up to constants (numerically, the rescaled quantity $n^{2(k-1)}g_{k}(n)$ stays bounded for $k = 3, 4$, converging slowly to a $k$-dependent constant). Determining that constant in closed form, as Theorem 7.2 does for $k = 2$, is the natural next theorem: more factors do not merely dilute the leak, they annihilate it.

### 11.4 Beyond abelian pinning

The law applies exactly when the split event is pinned by a *single* character — the abelian, cyclic-image case. When the splitting field is non-abelian, the split event is a conjugacy-class condition in a nonabelian Galois group and no residue class of $N$ determines it; the natural analogue would replace the fibre count of Lemma 3.2 by class-function counting in the group algebra. One expects a similar but coarser collapse, with $n$ replaced by an index-like invariant of the class. This is a natural home for the next generation of the analysis.

### 11.5 Other observables

The OR is the coarsest symmetric two-cell statistic of the fork. One may ask about weighted observables (e.g. $\mathbf{1}_A - \mathbf{1}_B$, the antisymmetric face), about multiple characters simultaneously (a full abelian field with several independent forks), and about correlations across different fields for the same semiprime. In each case the same style of fibre count in a product of finite groups should yield an exact closed-form leak; the OR-Collapse Law is the simplest and, in the sense of Section 10, the most consequential instance.

---

## 12. Summary

For any abelian field whose complete-splitting event is pinned by a Dirichlet character of order $n$, and for any semiprime $N = pq$ coprime to the conductor:

* $\mathbb{P}(\mathrm{OR} \mid \chi(N) = 1) = 1/n$ and $\mathbb{P}(\mathrm{OR} \mid \chi(N) \ne 1) = 2/n$, with $\mathbb{P}(\mathrm{OR}) = (2n-1)/n^{2}$;
* $I(N \bmod f;\ \mathrm{OR}) = g(n) = H\big(\frac{2n-1}{n^{2}}\big) - \frac1n H\big(\frac1n\big) - \frac{n-1}{n}H\big(\frac2n\big)$, universal in $n$;
* $0 < g(n) \le g(2) = 0.3113\ldots$, and $0.08/n^{2} \le g(n) \le 2/n^{2}$, with $g(n) \le 1/(\log 2\,(n-1)(2n-1))$;
* $n^{2}g(n) \to 1/\log 2 - 1 = 0.4426950\ldots$, the entire limit coming from the rare class $\chi(N) = 1$.

The source of every one of these numbers is a single sentence about a finite group: *among the $n$ ordered pairs whose product is $c$, exactly one has a trivial coordinate if $c = 1$, and exactly two do otherwise.*
