# Invariance and Washout of a Character Information Channel on Finite Abelian Class Groups

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

We study a mutual-information statistic — the *dial* — attached to a probabilistic sampler whose outputs are labelled by elements of a finite abelian group $G$. Given a *class-rate profile* $s : G \to [0,1]$, the dial $T(s)$ is the mutual information between the class of a two-factor composite and the binary event that both of its factors are usable; its distribution is governed by the averaged convolution $s \star s$ and the binary entropy function. It is known that $T$ is bounded by the universal constant $C^{*} = h(1/4) - \tfrac12 h(1/2) = \tfrac32\log 2 - \tfrac34\log 3 \approx 0.21576$ nats, with equality exactly at indicators of cosets of index-two subgroups.

We establish four structural laws. **(i) Inflation invariance:** for any surjective homomorphism $f : G \to Q$ and any profile $s$ on $Q$, $T(s \circ f) = T(s)$, and the same holds for the $k$-factor dial $\Phi_k$; consequently the dial is constant along the "regime" and "bit-length" axes of an experimental grid, and every coset of an index-two subgroup, inflated to any larger group, sits exactly at $C^{*}$. **(ii) Washout dichotomy and parity criterion:** if the sampler pre-multiplies by a uniformly random element of a multiplier subgroup $H \le G$, then some admissible $H$-invariant profile attains $C^{*}$ if and only if $H$ lies in an index-two subgroup, if and only if $[G:H]$ is even; the mean rate is preserved exactly by the randomisation, so two profiles can share a mean while their dials differ by the full cap. **(iii) A continuous degradation law:** for the contrast family $s_t = (1 + t\chi)/2$ attached to a quadratic character $\chi$, the conditional no-fork probability is $(1 + t^2\chi(c))/4$ — the contrast enters squared — whence $T(s_t) = D(t^2)$ for the group-free function $D(u) = h(1/4) - \tfrac12[h((1+u)/4) + h((1-u)/4)]$, which is strictly increasing on $[0,1]$ with $D(0) = 0$, $D(1) = C^{*}$. **(iv) A budgeted-adversary threshold:** a maximal channel survives every multiplier group of order at most $B$ if and only if $B < 2^{v_2(|G|)}$; the defence depends only on the $2$-part of the class group order, not on its size. We also prove that channels of arbitrary character order $d \ge 2$ have strictly positive dial $h(1/d^2) - \tfrac1d h(1/d)$ and collapse to exactly zero under multiplier groups that generate all residues, and that the $k$-factor dial at a quadratic kernel is $h(2^{-k}) - \tfrac12 h(2^{-(k-1)}) > 0$ for every $k \ge 2$ while washing out to zero at every $k$.

These results explain three experimental observations on fixed-multiplier continued-fraction factoring ladders: the near-constancy of the dial across a regime $\times$ bit-length grid (Spearman correlations with the eventual rate of $0.686$, $0.656$, $0.553$, $0.561$), the uniform superiority of the dial over the raw count statistic ($+0.06$ to $+0.10$ in every cell), and the total destruction of the channel by multiplier-randomised samplers.

**Keywords:** finite abelian group, quadratic character, mutual information, binary entropy, convolution, class group, washout, Sylow $2$-subgroup, factoring ladder.

---

## 1. Introduction

### 1.1 Motivation

Sieve-style factoring computations spend most of their time producing candidate objects and testing them for a smoothness or splitting condition. Predicting, from a short pilot run, whether a given configuration will eventually succeed is therefore of practical value. The default predictor is the *count*: the empirical rate at which candidates pass the test.

Count discards all structural information. In the settings we have in mind, each candidate carries an additional label: the class it occupies in a finite abelian group $G$ — the form class group of the relevant discriminant, or the unit group of a modulus. If the pass/fail behaviour of a candidate is correlated with its class, then the class label is an information channel, and the strength of that channel is a statistic in its own right.

This paper analyses that statistic — the **dial** — and answers three questions about it that were raised empirically:

1. Why is the dial so nearly constant across sampling regimes and input sizes?
2. Why does it outperform the count statistic *systematically*, rather than occasionally?
3. Why does randomising the algorithm's auxiliary multiplier destroy it completely?

The answers are, respectively: because it is an invariant of a character quotient; because there exist profiles with identical counts whose dials differ by the entire admissible range; and because averaging a nontrivial character over a subgroup that escapes its kernel annihilates it exactly.

### 1.2 Empirical background

The experiments motivating this work ran a fixed-multiplier continued-fraction factoring ladder over a $2 \times 2$ grid: sampling regime (*balanced* or *uniform*) crossed with input bit-length ($44$ or $48$). In each cell, the Spearman rank correlation between the dial and the eventual relation rate was measured; the four values were

$$0.686,\quad 0.656,\quad 0.553,\quad 0.561,$$

with confidence intervals excluding zero in all four cells, and with the dial beating the count statistic by $+0.06$ to $+0.10$ in each. A companion pilot replaced the fixed multiplier $k = 1$ by a randomised multiplier; the channel disappeared entirely, while the measured rate was unaffected. These observations are the empirical anchor of the theory developed below; the theorems themselves are unconditional statements about finite abelian groups.

### 1.3 Contributions and organisation

Section 2 fixes notation and defines the dial. Section 3 proves inflation invariance and derives the uniformity of the experimental grid. Section 4 develops the multiplier-randomisation operator, proves count blindness and the washout dichotomy, and specialises to the character level. Section 5 converts the dichotomy into the parity criterion, which requires an index-two existence theorem for finite abelian groups of even order. Section 6 replaces the dichotomy by a continuous degradation law. Section 7 treats channels of arbitrary character order and arbitrary numbers of prime factors. Section 8 solves the budgeted-adversary optimisation. Section 9 gives algorithms and complexity. Section 10 discusses applications, limitations and open problems.

---

## 2. Setting and definitions

Throughout, $G$ is a finite abelian group, written multiplicatively, with identity $1$. All entropies are in nats.

**Definition 2.1 (Binary entropy).** For $x \in [0,1]$,
$$h(x) = -x\log x - (1-x)\log(1-x),$$
with $h(0) = h(1) = 0$. The function $h$ is continuous on $[0,1]$ and strictly concave.

**Definition 2.2 (Class-rate profile and mean rate).** A *profile* is a function $s : G \to \mathbb{R}$; it is *admissible* if $0 \le s(a) \le 1$ for all $a$. Its *mean rate* (the *count statistic*) is
$$\bar{s} = \frac{1}{|G|}\sum_{a \in G} s(a).$$
The interpretation is that a candidate landing in class $a$ is usable with probability $s(a)$.

**Definition 2.3 (Averaged convolution and no-fork profile).** For profiles $t, s$,
$$(t \star s)(c) = \frac{1}{|G|}\sum_{a \in G} t(a)\, s(c a^{-1}).$$
The *no-fork profile* of $s$ is $N_s = s \star s$; the *$k$-fold fork profile* is the convolution power $s^{\star k}$, defined by $s^{\star 1} = s$ and $s^{\star(k+1)} = s^{\star k} \star s$.

If $A, B$ are independent classes drawn uniformly from $G$ and each is independently declared usable with the probability given by $s$, then $N_s(c)$ is the conditional probability that both are usable given $AB = c$; averaging over $c$ returns $\bar{s}^{\,2}$, and more generally the average of $s^{\star k}$ is $\bar{s}^{\,k}$.

**Definition 2.4 (The dial).** The *semiprime dial* of an admissible profile $s$ is
$$T(s) \;=\; h\!\left(\bar{s}^{\,2}\right) \;-\; \frac{1}{|G|}\sum_{c \in G} h\bigl(N_s(c)\bigr),$$
and its *$k$-factor* generalisation is
$$\Phi_k(s) \;=\; h\!\left(\bar{s}^{\,k}\right) \;-\; \frac{1}{|G|}\sum_{c \in G} h\bigl(s^{\star k}(c)\bigr), \qquad k \ge 2,$$
so that $T = \Phi_2$.

$T(s)$ is exactly the mutual information $I(C; Y)$ where $C$ is uniform on $G$ and, conditionally on $C = c$, $Y$ is Bernoulli with parameter $N_s(c)$; the marginal parameter of $Y$ is $\bar{s}^{\,2}$. In particular $T(s) \ge 0$ by concavity of $h$, with equality iff $N_s$ is constant.

**Definition 2.5 (Subgroup profile, coset profile, quadratic character).** For $K \le G$, the *subgroup profile* is the indicator $1_K$, and for $x \in G$ the *coset profile* is $a \mapsto 1_K(x^{-1}a)$. If $[G:K] = 2$, the *quadratic character* of $K$ is
$$\chi_K(a) = \begin{cases} +1 & a \in K,\\ -1 & a \notin K,\end{cases}$$
a group homomorphism $G \to \{\pm 1\}$ satisfying $1_K = (1 + \chi_K)/2$.

We take as given the following two facts, established previously for this channel.

**Theorem 2.6 (Cap and rigidity).** For every finite abelian $G$ and every admissible $s$,
$$T(s) \le C^{*} := h\!\left(\tfrac14\right) - \tfrac12 h\!\left(\tfrac12\right) = \tfrac32\log 2 - \tfrac34\log 3 \approx 0.2157615543 \text{ nats} = 0.3112781245 \text{ bits},$$
with equality if and only if $s$ is the indicator of a coset of a subgroup of index two. Moreover $\Phi_k(s) \le C^{*}$ for every $k$, and for $[G:K] = 2$,
$$T(1_K) = h\!\left(\tfrac14\right) - \tfrac12 h\!\left(\tfrac12\right) = C^{*}, \qquad \Phi_k(1_K) = h\!\left(2^{-k}\right) - \tfrac12 h\!\left(2^{-(k-1)}\right),$$
and, for a subgroup of arbitrary index $d$, $T(1_K) = h(1/d^{2}) - \tfrac1d h(1/d)$.

**Lemma 2.7 (Positivity of the cap).** $C^{*} > 0$; numerically $C^{*} \approx 0.21576$ nats. *(Immediate from $\log 2 > 0.6931471803$ and $\log 3 \le \tfrac32 \log 2 + \tfrac1{16}$.)*

---

## 3. Inflation invariance: the dial sees only the character quotient

The first family of results explains the stability of the dial across the experimental grid. The key observation is that every ingredient of Definition 2.4 commutes with pull-back along a group surjection.

**Lemma 3.1 (Fibre counting).** Let $f : G \to Q$ be a surjective homomorphism of finite abelian groups and $F : Q \to \mathbb{R}$. Then
$$\sum_{a \in G} F(f(a)) = |\ker f| \cdot \sum_{b \in Q} F(b).$$

*Proof sketch.* Partition $G$ into the fibres of $f$. Each fibre over $b$ is a coset of $\ker f$, hence has exactly $|\ker f|$ elements, and $F \circ f$ is constant on it. $\square$

**Lemma 3.2 (Averages are inflation invariant).** With $f$ as above, $\overline{F \circ f} = \bar{F}$.

*Proof sketch.* By Lemma 3.1 the numerator gains a factor $|\ker f|$, and by Lagrange's theorem for a surjection, $|G| = |\ker f|\cdot|Q|$, so the denominator gains the same factor. $\square$

**Lemma 3.3 (Convolution commutes with pull-back).** For profiles $t, s$ on $Q$ and $c \in G$,
$$\bigl((t\circ f) \star (s \circ f)\bigr)(c) = (t \star s)(f(c)).$$

*Proof sketch.* Substituting $f(ca^{-1}) = f(c)f(a)^{-1}$ turns the summand into a function of $f(a)$ alone; apply Lemma 3.2. $\square$

**Lemma 3.4 (Convolution powers).** For every $k \ge 1$, $(s \circ f)^{\star k} = s^{\star k} \circ f$.

*Proof sketch.* Induction on $k$, using Lemma 3.3 at each step. $\square$

**Theorem 3.5 (Inflation invariance of the dial).** Let $f : G \to Q$ be a surjective homomorphism of finite abelian groups and let $s : Q \to \mathbb{R}$ be a profile. Then
$$T(s \circ f) = T(s), \qquad \Phi_k(s \circ f) = \Phi_k(s) \quad (k \ge 2).$$

*Proof sketch.* The mean rate term is Lemma 3.2 applied to $s$; the conditional term is Lemma 3.2 applied to $h \circ s^{\star k}$, whose pull-back is $h \circ (s\circ f)^{\star k}$ by Lemma 3.4. $\square$

**Corollary 3.6 (Regime invariance).** If $e : G \to Q$ is an isomorphism then $T(s \circ e) = T(s)$: relabelling the class group does not move the dial.

**Corollary 3.7 (Bit-length invariance).** For any finite abelian $Q$ and any profile $s$ on $G$, the profile $(a, q) \mapsto s(a)$ on $G \times Q$ has dial $T(s)$, and likewise for $\Phi_k$: crossing the class group with an arbitrary extra factor changes nothing.

*Proof sketch.* Apply Theorem 3.5 to the projection $G\times Q \to G$, which is surjective. $\square$

**Theorem 3.8 (The intersection cell).** Let $K \le G$ with $[G:K] = 2$, let $x \in G$ be arbitrary, and let $Q$ be an arbitrary finite abelian group. Then the profile
$$(a,q) \;\longmapsto\; 1_K(x^{-1}a) \quad \text{ on } G \times Q$$
has dial exactly $C^{*}$.

*Proof sketch.* Corollary 3.7 removes the factor $Q$; Theorem 2.6 evaluates the coset indicator at the cap, uniformly in the translate $x$. $\square$

**Interpretation.** Theorem 3.8 is the precise statement that the experimental grid is one cell. Increasing the bit-length enlarges the ambient class group — formally, replaces $G$ by a group surjecting onto $G$; changing the sampling regime relabels it or shifts the profile by a translate. Neither operation alters the *character quotient* through which the profile factors, and by Theorem 3.5 the dial is a function of that quotient alone. Four measurements of the same invariant should agree, and empirically they nearly did.

---

## 4. Multiplier randomisation: the washout dichotomy

### 4.1 The mixing operator

**Definition 4.1 (Multiplier randomisation).** For a subgroup $H \le G$ (the *multiplier group*) and a profile $s$, define
$$(\mathrm{mix}_H\, s)(a) = \frac{1}{|H|}\sum_{h \in H} s(ha).$$
This is the profile seen by a sampler that multiplies its input by a uniformly random $h \in H$ before reading off the class.

**Definition 4.2 ($H$-invariance).** A profile $s$ is *$H$-invariant* if $s(ha) = s(a)$ for all $h \in H$, $a \in G$.

**Lemma 4.3 (Basic properties).** For admissible $s$: (i) $\mathrm{mix}_H\, s$ is admissible; (ii) $\mathrm{mix}_H\, s$ is $H$-invariant; (iii) if $H \le H'$, every $H'$-invariant profile is $H$-invariant.

*Proof sketch.* (i) is convexity; (ii) re-indexes the sum by right translation by an element of $H$, a bijection of $H$; (iii) is immediate. $\square$

**Theorem 4.4 (Count blindness).** $\overline{\mathrm{mix}_H\, s} = \bar{s}$ for every profile $s$ and every $H \le G$.

*Proof sketch.* Exchange the order of summation: the average over $a \in G$ of $s(ha)$ equals $\bar s$ for each fixed $h$, since $a \mapsto ha$ is a bijection of $G$. Averaging $|H|$ copies of $\bar{s}$ returns $\bar{s}$. $\square$

Thus the count statistic is *by construction* incapable of detecting multiplier randomisation. Everything that follows measures what the dial detects instead.

**Lemma 4.5 (Total mixing).** $\mathrm{mix}_G\, s$ is the constant profile $\bar{s}$.

**Lemma 4.6 (Constant profiles are silent).** For any constant $t$, $T(\text{const } t) = 0$ and $\Phi_k(\text{const } t) = 0$ for all $k$.

*Proof sketch.* The convolution powers of a constant are constant, $(\text{const } t)^{\star k} = \text{const } t^{k}$, so the two terms of Definition 2.4 coincide. $\square$

**Corollary 4.7 (Total washout).** $T(\mathrm{mix}_G\, s) = 0$ and $\Phi_k(\mathrm{mix}_G\, s) = 0$ for every profile $s$ and every $k$.

### 4.2 The dichotomy

**Theorem 4.8 (Washout dichotomy).** Let $H \le G$. There exists an admissible $H$-invariant profile $s$ with $T(s) = C^{*}$ **if and only if** there exists $K \le G$ with $[G:K] = 2$ and $H \le K$.

*Proof sketch.* ($\Rightarrow$) By the rigidity half of Theorem 2.6, a maximiser must be a coset indicator $s = 1_{xK}$ with $[G:K] = 2$. Then $s(x) = 1$, and $H$-invariance gives $s(hx) = 1$ for every $h \in H$, i.e. $x^{-1}hx = h \in K$. Hence $H \le K$. ($\Leftarrow$) If $H \le K$ then $1_K$ is $H$-invariant (as $K$ absorbs $H$ on both sides of membership) and attains $C^{*}$ by Theorem 2.6. $\square$

**Corollary 4.9 (Odd index kills the cap).** If $[G:H]$ is odd, then every admissible $H$-invariant profile satisfies $T(s) < C^{*}$; in particular $T(\mathrm{mix}_H\, s) < C^{*}$ for every admissible $s$.

*Proof sketch.* If the cap were attained, Theorem 4.8 would give $K$ of index $2$ with $H \le K$, whence $2 = [G:K]$ divides $[G:H]$, contradicting oddness. $\square$

**Theorem 4.10 (Count-blind separation).** Let $[G:K] = 2$. Then
$$\overline{\mathrm{mix}_G\, 1_K} = \overline{1_K} = \tfrac12, \qquad T(1_K) - T(\mathrm{mix}_G\, 1_K) = C^{*} > 0.$$
Two admissible profiles thus exist with the same mean rate whose dials differ by the full admissible range.

*Proof sketch.* Combine Theorem 4.4, Lemma 4.5, Corollary 4.7 and Theorem 2.6. $\square$

Theorem 4.10 is the sharpest possible form of "the dial beats the count": on the pair $(1_K, \mathrm{mix}_G 1_K)$, the count statistic has zero discriminating power and the dial has the maximum possible.

### 4.3 The mechanism at the character level

The dichotomy is an existence statement; the following results identify the exact mechanism, which is character orthogonality.

**Theorem 4.11 (Character equidistribution).** Let $[G:K] = 2$ with character $\chi = \chi_K$, and let $H \le G$ with $H \not\le K$. Then
$$\sum_{h \in H} \chi(h) = 0.$$

*Proof sketch.* Pick $h_1 \in H \setminus K$, so $\chi(h_1) = -1$. Right translation by $h_1$ is a bijection of $H$, and $\chi(gh_1) = -\chi(g)$ because $\chi$ is a homomorphism. Hence the sum equals its own negative. $\square$

**Theorem 4.12 (One non-residue multiplier flattens the channel).** Under the hypotheses of Theorem 4.11,
$$\mathrm{mix}_H\, 1_K \equiv \tfrac12, \qquad T(\mathrm{mix}_H\, 1_K) = 0,$$
while the mean rate stays at $\tfrac12$.

*Proof sketch.* Write $1_K = (1 + \chi)/2$ and use multiplicativity: $\chi(ha) = \chi(h)\chi(a)$, so
$$(\mathrm{mix}_H\, 1_K)(a) = \tfrac12 + \tfrac{\chi(a)}{2|H|}\sum_{h\in H}\chi(h) = \tfrac12$$
by Theorem 4.11. Then apply Lemma 4.6. $\square$

The dial therefore does not degrade gracefully under a bad multiplier: a *single* multiplier outside the character kernel sends it to exactly zero. Combined with Theorem 4.4, this yields the *channel collapse* statement: same mean rate $\tfrac12$, dial $C^{*}$ before randomisation and $0$ after.

---

## 5. The parity criterion

Theorem 4.8 characterises survival in terms of subgroup containment. Over a finite abelian group this is equivalent to a statement about a single integer.

**Theorem 5.1 (Index-two existence).** Every finite abelian group $Q$ of even order has a subgroup of index two.

*Proof sketch.* We avoid the structure theorem. Write $|Q| = 2^{j}m'$ with $m'$ odd and $j \ge 1$. By Sylow's existence theorem there is a subgroup $M \le Q$ of order $2^{j-1}$, so $[Q : M] = 2m$ with $m = m'$ odd. Set $A = Q/M$, an abelian group of order $2m$. Consider the squaring homomorphism $\sigma : A \to A$, $\sigma(x) = x^{2}$ (a homomorphism because $A$ is abelian). Its kernel consists of elements of order dividing $2$, hence is a $2$-group; it is nontrivial by Cauchy's theorem, since $2 \mid |A|$; and its order cannot be $4$ or more, because the order of a subgroup divides $|A| = 2m$ and $4 \nmid 2m$. Therefore $|\ker\sigma| = 2$, and by the first isomorphism theorem $[A : \operatorname{im}\sigma] = |\ker \sigma| = 2$. Pulling $\operatorname{im}\sigma$ back along the quotient map $Q \to Q/M$ preserves the index and yields a subgroup of $Q$ of index two. $\square$

**Corollary 5.2.** For a finite abelian $G$ and $H \le G$: there exists $K$ of index two with $H \le K$ **iff** $[G:H]$ is even.

*Proof sketch.* ($\Leftarrow$) $|G/H| = [G:H]$ is even, so by Theorem 5.1 the quotient $G/H$ has an index-two subgroup $L$; its pre-image in $G$ has index two and contains $H$. ($\Rightarrow$) $[G:K] = 2$ divides $[G:H]$ whenever $H \le K$. $\square$

**Theorem 5.3 (Parity criterion for washout).** Let $G$ be a finite abelian group and $H \le G$ a multiplier group. Then
$$\exists \text{ admissible } H\text{-invariant } s \text{ with } T(s) = C^{*} \iff [G:H] \text{ is even}.$$

*Proof sketch.* Theorem 4.8 combined with Corollary 5.2. $\square$

**Corollary 5.4 (The two ends of the multiplier scale).** If $|G|$ is even then the trivial multiplier group $H = \{1\}$ (index $|G|$, even) supports a maximal channel — this is the *fixed multiplier* regime — while the full multiplier group $H = G$ (index $1$, odd) drives every profile's dial to exactly $0$.

**Corollary 5.5 (Arithmetic realisation).** For every odd prime $p$, the class group $(\mathbb{Z}/p)^{\times}$ (of even order $p-1$) admits a profile attaining $C^{*}$ — the Legendre-symbol coset indicator — while full multiplier randomisation drives every profile to dial value $0$.

This is the formal counterpart of the experimental requirement that the ladder be run with a fixed multiplier $k = 1$: the fixed-multiplier regime is exactly the extreme case $H = \{1\}$ of Theorem 5.3.

---

## 6. Partial washout: the degradation law

The dichotomy of Section 4 exhibits only two values, $C^{*}$ and (for the total-mixing case) $0$. This section shows that the intermediate values are all realised, by profiles with the *same* mean rate as the maximiser, and identifies the exact one-dimensional law.

**Definition 6.1 (Contrast family).** For $[G:K] = 2$ with character $\chi$, and $t \in \mathbb{R}$, let
$$s_t(a) = \frac{1 + t\,\chi(a)}{2}.$$
For $|t| \le 1$ this is admissible; $s_1 = 1_K$ and $s_0 \equiv \tfrac12$. Its mean rate is $\bar{s_t} = \tfrac12$ for every $t$, because $\sum_a \chi(a) = 0$.

**Theorem 6.2 (The contrast enters squared).** For $[G:K] = 2$ and every $c \in G$,
$$N_{s_t}(c) = \frac{1 + t^{2}\chi(c)}{4}.$$

*Proof sketch.* Expand $s_t(a)\,s_t(ca^{-1})$ using $\chi(ca^{-1}) = \chi(c)\chi(a)$ (valid since $\chi(a)^{-1} = \chi(a)$) and $\chi(a)^2 = 1$:
$$s_t(a)s_t(ca^{-1}) = \frac{1 + t^{2}\chi(c)}{4} + \frac{t\,(1 + \chi(c))}{4}\,\chi(a).$$
Averaging over $a$ kills the second term because $\chi$ has mean zero. $\square$

The squaring has an operational reading: the fork event pairs two independent draws, each contributing one factor of the contrast, so the contrast visible to the detector is $t^{2}$.

**Definition 6.3 (The degradation law).** For $u \in [0,1]$,
$$D(u) = h\!\left(\tfrac14\right) - \tfrac12\left[h\!\left(\tfrac{1+u}{4}\right) + h\!\left(\tfrac{1-u}{4}\right)\right].$$

**Theorem 6.4 (One-dimensional reduction).** For $[G:K] = 2$ and $|t| \le 1$, $T(s_t) = D(t^{2})$.

*Proof sketch.* $\bar{s_t} = \tfrac12$ gives the first term $h(1/4)$. By Theorem 6.2 the conditional entropy term is the average over $c$ of $h((1 + t^2\chi(c))/4)$; since $\chi$ takes the values $\pm 1$ equally often on an index-two kernel, this average is the arithmetic mean of the two evaluations. $\square$

**Theorem 6.5 (Strict monotonicity).** $D$ is strictly increasing on $[0,1]$, with $D(0) = 0$ and $D(1) = C^{*}$.

*Proof sketch.* Fix $0 \le u < v \le 1$ and set $\lambda = \tfrac12(1 + u/v) \in (0,1)$. Then
$$\lambda\cdot\tfrac{1+v}{4} + (1-\lambda)\cdot\tfrac{1-v}{4} = \tfrac{1+u}{4}, \qquad (1-\lambda)\cdot\tfrac{1+v}{4} + \lambda\cdot\tfrac{1-v}{4} = \tfrac{1-u}{4}.$$
Strict concavity of $h$ applied to each of these two convex combinations gives two strict inequalities; adding them, the coefficients of $h((1\pm v)/4)$ sum to $1$ on each side and one obtains
$$h\!\left(\tfrac{1+u}{4}\right) + h\!\left(\tfrac{1-u}{4}\right) > h\!\left(\tfrac{1+v}{4}\right) + h\!\left(\tfrac{1-v}{4}\right),$$
i.e. $D(u) < D(v)$. The endpoint values are direct computations: $D(0) = 0$ since both evaluations equal $h(1/4)$; and $D(1) = h(1/4) - \tfrac12 h(1/2) = C^{*}$, using $h(0) = 0$. $\square$

**Theorem 6.6 (Partial-washout continuum).** Let $[G:K] = 2$ and $0 < t < 1$. Then $s_t$ is admissible, has the same mean rate as the maximiser $1_K$, and satisfies
$$0 < T(s_t) < C^{*}.$$
Consequently every value in $(0, C^{*})$ arises as the dial of an admissible profile of mean rate $\tfrac12$, by continuity and strict monotonicity of $D$.

**Theorem 6.7 (Subgroup multipliers realise only the endpoints).** Let $[G:K] = 2$, $H \le G$, $|t| \le 1$. Then
$$\mathrm{mix}_H\, s_t = \begin{cases} s_t & \text{if } H \le K,\\[2pt] s_0 \equiv \tfrac12 & \text{if } H \not\le K.\end{cases}$$

*Proof sketch.* If $H \le K$ then $\chi(ha) = \chi(a)$ for $h \in H$, so $s_t$ is $H$-invariant. If $H \not\le K$, Theorem 4.11 gives $\sum_{h\in H}\chi(h) = 0$ and the computation of Theorem 4.12 applies verbatim with the extra factor $t$. $\square$

Theorems 6.6 and 6.7 together give the correct picture: the washout dichotomy is not a claim that intermediate channel strengths are impossible, but the statement that *subgroup* averaging can only realise the two endpoints of a genuine continuum. Adversaries restricted to subgroup multipliers therefore face an all-or-nothing decision; adversaries able to implement arbitrary contrast reduction can tune the channel continuously.

---

## 7. Beyond order two and beyond two factors

### 7.1 Residue channels of arbitrary order

**Theorem 7.1 (Positive dial at every order).** Let $K \le G$ with $[G:K] = d \ge 2$. Then
$$T(1_K) = h\!\left(\tfrac{1}{d^{2}}\right) - \tfrac1d\, h\!\left(\tfrac1d\right) \;>\; 0 .$$

*Proof sketch.* The value is Theorem 2.6. Positivity follows from sharpened tangent bounds on the binary entropy,
$$-x\log x + x(1-x) \;\le\; h(x) \;\le\; -x\log x + x \qquad (0 < x < 1),$$
the lower bound coming from $\log(1-x) \le -x$ and the upper bound from $\log(1-x) \ge -x/(1-x)$. Writing $x = 1/d \le 1/2$, the lower bound at $x^{2}$ and the upper bound at $x$ leave a residual $x^{2}\log 2 - O(x^{3})$, positive for $x \le 1/2$. $\square$

Numerically, $T(1_K) = 0.21576,\ 0.13666,\ 0.09321,\ 0.06786,\ 0.05184$ for $d = 2,3,4,5,6$.

**Theorem 7.2 (Collapse of an order-$d$ channel).** Let $K \le G$ and let $H \le G$ satisfy $H \vee K = G$ (the multipliers, together with $K$, generate everything — equivalently the multipliers hit every residue class modulo $K$). Then
$$\mathrm{mix}_H\, 1_K \equiv \frac{1}{[G:K]}, \qquad T(\mathrm{mix}_H\, 1_K) = 0, \qquad \overline{\mathrm{mix}_H\, 1_K} = \overline{1_K} = \frac{1}{[G:K]}.$$

*Proof sketch.* Constancy is a pure coset argument requiring no character theory: given $a, b \in G$, write $ab^{-1} = h_0 k$ with $h_0 \in H$, $k \in K$; then translating the summation index by $h_0$ matches the sums defining $(\mathrm{mix}_H 1_K)(a)$ and $(\mathrm{mix}_H 1_K)(b)$ term by term, because $1_K$ is invariant under right multiplication by $k \in K$. A constant profile equals its own mean, which is $\overline{1_K} = 1/[G:K]$ by Theorem 4.4. Lemma 4.6 finishes. $\square$

Thus the collapse phenomenon is a statement about characters of arbitrary order, not about parity. The parity criterion of Section 5 is specific to the *maximal* channel, which is necessarily quadratic; positivity and collapse are not.

### 7.2 Composites with more prime factors

**Theorem 7.3 (The multi-prime dial never dies).** Let $[G:K] = 2$. For every $k \ge 2$,
$$\Phi_k(1_K) = h\!\left(2^{-k}\right) - \tfrac12\, h\!\left(2^{-(k-1)}\right) \;>\; 0 .$$

*Proof sketch.* The value is Theorem 2.6; positivity again uses the sharpened tangent pair of Theorem 7.1, applied with $x = 2^{-(k-1)} \le 1/2$: the upper bound on $h(x)$ and the lower bound on $h(x/2)$ leave the strictly positive residual $2^{-k}\log 2 - O(4^{-k})$. $\square$

Numerically $\Phi_k(1_K) = 0.21576,\ 0.09560,\ 0.04541,\ 0.02216,\ 0.01095$ for $k = 2,\dots,6$: geometric decay, but never zero.

**Theorem 7.4 (Uniform multi-prime washout).** $\Phi_k(\mathrm{mix}_G\, s) = 0$ for every profile $s$ and every $k$, while $\overline{\mathrm{mix}_G\, s} = \bar{s}$. Combining with Theorem 7.3: at every number of prime factors, the quadratic-character profile carries strictly positive information, its randomised version carries exactly none, and the count statistic cannot tell them apart.

*Proof sketch.* Lemma 4.5, Lemma 4.6 (multi-prime version, using $(\text{const }t)^{\star k} = \text{const }t^{k}$), Theorem 4.4. $\square$

Together with Theorem 3.5 for $\Phi_k$, these results reproduce the full round of laws on the multi-prime axis: uniform in the ambient group, positive in $k$, and annihilated by randomisation at every $k$.

---

## 8. The budgeted multiplier adversary

Section 5 tells us which multiplier groups are fatal. The natural design question is the optimisation version: an adversary may randomise over *any* subgroup $H$ subject to a budget $|H| \le B$; when does a maximal channel survive every such attack?

**Definition 8.1 (Two-part).** For a finite group $G$, let $\tau(G) = 2^{v_2(|G|)}$, the largest power of two dividing $|G|$ — equivalently the order of a Sylow $2$-subgroup.

**Theorem 8.2 (Odd index equals full $2$-part).** For a finite group $G$ and $H \le G$,
$$[G:H] \text{ is odd} \iff \tau(G) \mid |H|.$$

*Proof sketch.* $|H| \cdot [G:H] = |G|$, so $v_2(|G|) = v_2(|H|) + v_2([G:H])$. The index is odd iff $v_2([G:H]) = 0$ iff $v_2(|H|) = v_2(|G|)$ iff $\tau(G) \mid |H|$. $\square$

**Theorem 8.3 (Budget criterion).** For a finite group $G$ and $B \in \mathbb{N}$,
$$\bigl(\forall H \le G,\; |H| \le B \Rightarrow [G:H] \text{ even}\bigr) \iff B < \tau(G).$$

*Proof sketch.* ($\Leftarrow$) If $[G:H]$ were odd, Theorem 8.2 would force $|H| \ge \tau(G) > B$. ($\Rightarrow$) Sylow's theorem provides $H$ with $|H| = \tau(G)$; if $B \ge \tau(G)$ this $H$ is within budget and has odd index by Theorem 8.2. $\square$

**Theorem 8.4 (Budgeted dial dichotomy).** Let $G$ be a finite abelian class group and $B \in \mathbb{N}$. Then every multiplier group $H$ with $|H| \le B$ admits an admissible $H$-invariant profile attaining $C^{*}$ **if and only if** $B < \tau(G) = 2^{v_2(|G|)}$.

*Proof sketch.* Combine the parity criterion (Theorem 5.3) with Theorem 8.3. $\square$

**Theorem 8.5 (The attack at threshold).** If $B \ge \tau(G)$, there is a single multiplier group $H$ with $|H| \le B$ — any Sylow $2$-subgroup — such that for *every* admissible profile $s$,
$$T(\mathrm{mix}_H\, s) < C^{*} \qquad\text{and}\qquad \overline{\mathrm{mix}_H\, s} = \bar{s}.$$

**Corollary 8.6 (Size is no defence).** If $|G| = 2m$ with $m$ odd, then $\tau(G) = 2$ and a budget of $2$ already breaks the channel, however large $m$ is.

**Corollary 8.7 (Unit groups).** On $(\mathbb{Z}/p)^{\times}$ the surviving-budget threshold is the $2$-part of $p - 1$. For instance: $p = 17$ gives threshold $16$; $p = 41$ gives $8$; $p = 13, 29, 37$ give $4$; and $p = 11, 19, 23, 31$ give the minimum possible threshold $2$.

The design rule is therefore sharp and slightly counter-intuitive: the resistance of a character channel to multiplier randomisation is measured by the $2$-adic valuation of the class number, and not at all by the class number itself.

---

## 9. Algorithms and complexity

Three computational tasks arise: evaluating the dial for a given profile, estimating it from a sample, and evaluating the design threshold.

### 9.1 Exact evaluation of the dial

**Input.** A finite abelian group $G$ given as $\mathbb{Z}/m_1 \times \cdots \times \mathbb{Z}/m_r$, a profile $s$, and $k \ge 2$.

**Method.**
1. Compute $\bar{s}$ in $O(|G|)$ operations.
2. Compute $s^{\star k}$ by $k-1$ convolutions. Direct convolution costs $O(|G|^{2})$ per step; using the fast Fourier transform on the character group of $G$, each convolution costs $O(|G|\log|G|)$, giving $O(k\,|G|\log|G|)$ overall.
3. Return $h(\bar{s}^{\,k}) - |G|^{-1}\sum_c h(s^{\star k}(c))$.

Numerical caution: entropies must be evaluated with the convention $h(0) = h(1) = 0$, and $s^{\star k}$ obtained by FFT should be clipped to $[0,1]$ to absorb rounding.

### 9.2 Estimating the dial from a sample

In an experiment the profile is not known; one observes pairs (class of composite, usable/not). The plug-in estimator replaces $N_s(c)$ by the empirical pass rate within class $c$ and $\bar{s}^{\,2}$ by the overall empirical pass rate. Two remarks matter in practice.

* **Bias.** Plug-in mutual information is biased upward by roughly $(|G| - 1)/(2n)$ nats for $n$ samples; since the signal is bounded by $C^{*} \approx 0.216$ nats, the bin count $|G|$ must be kept small relative to $n$. Theorem 3.5 is precisely the licence to do so: one may quotient the class group down to a small character quotient without changing the quantity being estimated. The natural choice is the quotient by the squares, whose order is the $2$-rank of $G$.
* **Aggregation across cells.** Since the dial is invariant under inflation and relabelling, measurements taken at different bit-lengths and regimes estimate the same population quantity and may legitimately be pooled — which is what makes a $2\times 2$ grid of correlations interpretable as four looks at one number.

### 9.3 Evaluating the design threshold

Given the class number $|G|$, the surviving-budget threshold of Theorem 8.4 is $\tau(G) = 2^{v_2(|G|)}$: strip factors of $2$ from $|G|$. This is $O(\log |G|)$ and requires no knowledge of the group structure beyond its order — a useful feature, since class numbers are often computable when class group structures are not.

---

## 10. Discussion

### 10.1 What the theory explains

Each of the three experimental observations has an exact counterpart.

* *Stability across the grid.* Theorem 3.5 and Theorem 3.8: the dial is a function of the character quotient, so enlarging the ambient class group (bit-length) and relabelling or translating it (regime) leave it fixed. The four measured correlations $0.686, 0.656, 0.553, 0.561$ are four estimates of one invariant; the residual spread is sampling noise and estimator bias, not structural drift.
* *Dial beats count.* Theorem 4.10 exhibits pairs with identical mean rate whose dials differ by the full $C^{*}$. The empirical margin of $+0.06$ to $+0.10$ in rank correlation is a diluted version of a separation that is, in the extremal case, total.
* *Multiplier randomisation destroys the channel.* Theorems 4.11, 4.12 and 5.3: averaging over multipliers equidistributes the character; a single multiplier outside the character kernel already sends the dial to exactly zero, while the mean rate is preserved to the last digit. The requirement that the ladder be run with a fixed multiplier is the case $H = \{1\}$ of the parity criterion.

### 10.2 Limitations

The model is idealised in three respects, each of which we state explicitly.

1. **Uniformity.** The class of a candidate is modelled as uniform on $G$ and independent across the factors of a composite. Real samplers produce classes with a mildly non-uniform, weakly dependent distribution.
2. **Subgroup multipliers.** Multiplier randomisation is modelled as averaging over a *subgroup*. A practical sampler draws multipliers from a finite set that need not be a subgroup; Theorem 6.7 shows that only subgroup averaging is confined to the endpoints, so general multiplier sets can in principle realise intermediate contrasts.
3. **Statistical versus structural claims.** All theorems here concern the population quantity $T(s)$. The reported rank correlations are properties of an estimator on finite samples; the bias discussion of Section 9.2 is the relevant caveat.

### 10.3 Relation to classical facts

Several ingredients are classical and used as such: character orthogonality over a subgroup (Theorem 4.11), Sylow existence and Cauchy's theorem (Theorem 5.1), the multiplicativity of $2$-adic valuation across the index formula (Theorem 8.2), and strict concavity of the binary entropy (Theorem 6.5). What appears to be new is the combination: an information-theoretic functional on profiles over a class group whose extremal set is exactly the quadratic characters, whose invariance group is exactly the inflations, and whose destruction under averaging is governed exactly by the $2$-part.

### 10.4 Open problems

1. **A Fourier bound for arbitrary profiles.** Theorem 6.4 computes the dial exactly along the one-parameter character family. For a general admissible profile, is there a bound of the shape $T(s) \le F\bigl(\max_{\psi \ne 1}|\hat{s}(\psi)|\bigr)$ with $F$ the natural analogue of $D$? Theorem 6.6 shows such a bound would be tight along the contrast family.
2. **Non-subgroup multiplier sets.** Characterise the achievable pairs (mean rate, dial) when the multiplier set is an arbitrary finite subset of $G$ rather than a subgroup. The endpoints are settled; the interior is not.
3. **Multi-prime degradation law.** Extend Theorem 6.4 to $\Phi_k$: presumably the conditional profile of $s_t$ is $(1 + t^{k}\chi(c))/2^{k}$, giving a $k$-indexed family of degradation laws with contrast exponent $k$. Both the exact statement and the resulting monotonicity in $k$ remain to be established.
4. **Adaptive adversaries.** Theorem 8.4 assumes a static multiplier group. If the adversary may adapt its multiplier distribution across rounds under a total budget, what is the optimal schedule, and does the $2$-part threshold survive?
5. **Estimator theory tuned to the invariance.** Design an estimator of $T$ that exploits Theorem 3.5 by first estimating the character quotient and then estimating the dial on it, and quantify the resulting variance reduction relative to the plug-in estimator on the full class group.

### 10.5 Future directions

The programme so far has established, for the semiprime and multi-prime channel with cap $C^{*} = h(1/4) - \tfrac12 h(1/2) = h(3/4) - \tfrac12 h(1/2)$, the following structural laws: inflation invariance, so that the dial is constant along the bit-length and regime axes; the washout dichotomy, so that an invariant profile attains the cap iff the multiplier group lies in an index-two subgroup; the parity criterion, so that over a finite abelian class group that condition is the arithmetic statement $2 \mid [G:H]$; count blindness, so that randomisation preserves the mean rate exactly while the dial falls from the cap to zero at every number of prime factors; and the extension to characters of any order $d \ge 2$, where the dial is strictly positive with fixed multipliers and exactly zero as soon as the multiplier group generates all residues.

Two directions previously open have since been closed. The first, a *quantitative* form of the washout, is now available as the degradation law of Section 6: the contrast family has conditional no-fork probability $(1 + t^2\chi(c))/4$, so the contrast enters squared, and the dial equals $D(t^2)$ for the group-free function $D$; strict concavity of the binary entropy makes $D$ strictly increasing with $D(0) = 0$ and $D(1) = C^{*}$, and for every $0 < t < 1$ there is an admissible profile with the same mean rate as the maximiser and a dial value strictly between zero and the cap. Subgroup multipliers realise only the two endpoints, so the earlier dichotomy is the endpoint statement of a genuine continuum. What remains open is a bound for arbitrary profiles in terms of Fourier data — open problem 1 above. The second closed direction is the budgeted adversary of Section 8: a subgroup has odd index iff its order is divisible by the full $2$-part, hence a maximal channel survives every multiplier group of order at most $B$ iff $B < 2^{v_2(|G|)}$, with a Sylow $2$-subgroup supplying the attack exactly at the threshold.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Inflation invariance | $T(s\circ f) = T(s)$ and $\Phi_k(s \circ f) = \Phi_k(s)$ for surjective $f : G \to Q$ |
| Intersection cell | Every coset indicator of an index-two subgroup, inflated to any $G \times Q$, has dial exactly $C^{*}$ |
| Count blindness | $\overline{\mathrm{mix}_H s} = \bar{s}$ for every $H$ and $s$ |
| Washout dichotomy | An $H$-invariant admissible profile attains $C^{*}$ iff $H$ lies in an index-two subgroup |
| Parity criterion | Equivalently, iff $[G:H]$ is even |
| Character collapse | If $H \not\le K$ with $[G:K]=2$ then $\mathrm{mix}_H 1_K \equiv \tfrac12$ and $T = 0$ exactly |
| Count-blind separation | $1_K$ and $\mathrm{mix}_G 1_K$ share the mean $\tfrac12$; their dials differ by $C^{*}$ |
| Degradation law | $T\bigl((1+t\chi)/2\bigr) = D(t^{2})$, $D$ strictly increasing, $D(0)=0$, $D(1)=C^{*}$ |
| Order-$d$ channels | $T(1_K) = h(1/d^{2}) - \tfrac1d h(1/d) > 0$; collapse to $0$ when $H \vee K = G$ |
| Multi-prime | $\Phi_k(1_K) = h(2^{-k}) - \tfrac12 h(2^{-(k-1)}) > 0$ for all $k \ge 2$; $\Phi_k(\mathrm{mix}_G s) = 0$ |
| Budgeted adversary | Channel survives all $|H| \le B$ iff $B < 2^{v_2(|G|)}$ |

Numerical values: $C^{*} = 0.2157615543$ nats $= 0.3112781245$ bits; $T(1_K)$ for $d = 2,\dots,6$ equals $0.21576, 0.13666, 0.09321, 0.06786, 0.05184$; $\Phi_k(1_K)$ for $k = 2,\dots,6$ equals $0.21576, 0.09560, 0.04541, 0.02216, 0.01095$; $D(t^{2})$ at $t = 0.5, 0.8, 0.9$ equals $0.01050, 0.07264, 0.12248$.
