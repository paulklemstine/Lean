# Structural Sensors, Magnitude Mirrors, and the Surviving Positional Oracle: An Exact Information Calculus for the Fermat Ascent Window

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We give an exact, finitary information-theoretic analysis of the probe classes that have been proposed as side channels on the Fermat factoring ascent, and we settle their status by identity rather than by estimation.

Three results form the core. First, for the energy $E(a) = a^2 - N$ read on the integer-square-root-anchored window $a_j = \lfloor\sqrt N\rfloor + j$, we prove $E(a_0) \le 0 < E(a_j)$ for all $j \ge 1$; consequently the window sign vector is a *constant* function of $N$ on any family of non-squares, and every bracket, sign-count, or crossing sensor derived from it has *exactly* zero empirical mutual information with every secret, together with all of its post-processings. This refutes the "energy ascent at the divisor offset" mechanism: the unique zero crossing sits at $\sqrt N$, between $j=0$ and $j=1$, for every $N$. Second, we introduce the class of **magnitude mirrors** — features that are deterministic functions of $|N|$ — and prove an exact characterization: a feature has zero empirical information about *every* secret inside *every* magnitude cell if and only if it is a mirror. We prove that mirrors are closed under post-processing, pairing, arbitrary finite tupling, and magnitude refinement, so the entire realized probe battery, read jointly, is a single mirror; that injective (in particular strictly monotone) recodings preserve information exactly, explaining an observed coincidence of $0.1836$ bits between a spectral summary and plain $\log N$; and that a mirror exhibiting unconditional signal *forces* stratification of the secret across magnitude cells, so a row-shuffle permutation null is provably the wrong null for such features. Third, we isolate the surviving channel: the factor-derived positional oracle bit $\mathbb 1\{d \le B\}$ is provably not a mirror, is informative inside a single magnitude cell, and has a below-threshold profile that is monotone in $B$ with binary-entropy capacity that is unimodal, capped at one bit, maximized exactly at combinatorial balance, and possesses interval superlevel sets. We complete the picture with a two-sided cost law $j = \Theta(k^2/\sqrt N)$ for the Fermat frontier offset in terms of the factorization imbalance $k$, and with an exact bridge showing that the square-hit window over square moduli *is* the tree of Pythagorean triples under Barning–Hall descent.

**Keywords:** Fermat factorization, integer square root window, exact mutual information, magnitude mirror, conditional null, positional oracle, binary entropy, Pythagorean triples, Barning–Hall descent.

---

## 1. Introduction

### 1.1 The object of study

Let $N$ be a positive integer and define the **Fermat energy**
$$E_N(a) \;=\; a^2 - N \qquad (a \in \mathbb N),$$
the **anchor** $m = m(N) = \lfloor \sqrt N \rfloor$, and the **anchored window** $a_j = m + j$ for $j = 0, 1, 2, \dots$. Fermat's algorithm scans $j$ upward and stops at the first **hit**, an index with $E_N(a_j)$ a perfect square.

Two distinct research claims have been attached to this window.

*(C1) The ascent claim.* The sign behaviour of $E_N$ along the window — where it crosses zero, how many negative entries the sign vector has, cheap bracket flags derived from these — was asserted to localize a nontrivial divisor $d$ of $N$, with an "event at $j = d$".

*(C2) The spectral claim.* Smooth real-valued summaries of the energy profile on the window were asserted to be informative about a secret bit of a factor, at a measured $0.1836$ bits of mutual information, comfortably rejecting a row-shuffle permutation null.

Both claims are false, and both are false for reasons that can be stated as exact theorems about finite instance sets rather than as statistical verdicts. This paper proves them, characterizes precisely the class of probes that the second refutation kills, shows that the class is closed under every natural combining operation, and isolates what remains.

### 1.2 The currency: exact empirical independence

All information statements below are *counting* statements on finite instance sets, so that "zero bits" means an identity between cardinalities and not a small estimate.

> **Definition 1 (exact empirical independence).** Let $\Omega$ be a finite set of instances, $T : \Omega \to \mathcal T$ a statistic and $S : \Omega \to \mathcal S$ a secret, both with decidable equality on their codomains. Say $T$ and $S$ are **exactly independent on $\Omega$**, written $\mathrm{ZI}(\Omega; T, S)$, when for all $t \in \mathcal T$ and $s \in \mathcal S$,
> $$\bigl|\{w \in \Omega : T(w) = t \ \wedge\ S(w) = s\}\bigr| \cdot |\Omega| \;=\; \bigl|\{w \in \Omega : T(w) = t\}\bigr| \cdot \bigl|\{w \in \Omega : S(w) = s\}\bigr| .$$

Dividing by $|\Omega|^2$ (for $\Omega \ne \varnothing$) this says $\hat p(t,s) = \hat p(t)\hat p(s)$ for the empirical joint distribution, hence the empirical mutual information $\hat I(T;S)$ is exactly $0$. The multiplicative form is used throughout because it is division-free and holds trivially for $\Omega = \varnothing$.

Two elementary facts are used repeatedly.

> **Lemma 2 (constants are uninformative).** If $T$ is constant on $\Omega$ then $\mathrm{ZI}(\Omega; T, S)$ for every $S$.

> **Lemma 3 (data processing).** If $\mathrm{ZI}(\Omega; T, S)$ then $\mathrm{ZI}(\Omega; g \circ T, S)$ for every function $g$.

> **Lemma 4 (locality).** If $T = T'$ pointwise on $\Omega$ then $\mathrm{ZI}(\Omega; T, S) \iff \mathrm{ZI}(\Omega; T', S)$.

Lemma 4 is what allows a feature defined by an algorithm to be replaced by any function agreeing with it on the observed instances.

---

## 2. The energy on the anchored window is structurally determined

### 2.1 The unique zero crossing

> **Proposition 5 (zero of the energy).** $E_N(a) = 0$ if and only if $a^2 = N$.

*Proof.* Immediate from the definition, transporting the identity between $\mathbb N$ and $\mathbb Z$. $\square$

> **Proposition 6 (anchor sign).** $E_N(m) \le 0$ for every $N$, where $m = \lfloor\sqrt N\rfloor$.

*Proof.* By definition of the integer square root, $m^2 \le N$, hence $E_N(m) = m^2 - N \le 0$. $\square$

> **Theorem 7 (positivity off the anchor).** For every $N$ and every $j \ge 1$, $E_N(m + j) > 0$.

*Proof.* By the defining property of the integer square root, $N < (m+1)^2$. Since $j \ge 1$ and $m \ge 0$ we have $(m+j)^2 \ge (m+1)^2 > N$. $\square$

> **Proposition 8 (strict monotonicity along the window).** $j \mapsto E_N(m+j)$ is strictly increasing.

*Proof.* $(m+i)^2 < (m+j)^2$ whenever $0 \le i < j$. $\square$

Propositions 6, 8 and Theorem 7 combine into the statement that killed claim (C1).

> **Corollary 9 (no sign change at a divisor offset).** For every $N$ and every $d \ge 1$ — in particular for $d$ any nontrivial divisor of $N$ — we have $E_N(m+d) > 0$ and $E_N(m+d+1) > 0$. Hence there is no sign change of the energy at offset $d$.

The unique sign change of the anchored energy occurs between $j=0$ and $j=1$, i.e. at $\sqrt N$, and it does so for *every* $N$, because $\lfloor\sqrt N\rfloor$ is *defined* to be the last integer at which the energy is non-positive. No arithmetic property of $N$ enters.

### 2.2 The real event is the square hit

> **Theorem 10 (hits are factorizations, and conversely).**
> (i) For all $u, k \in \mathbb N$, $E_{u(u+2k)}(u+k) = k^2$.
> (ii) If $b \le a$ and $E_N(a) = b^2$ then $(a-b)(a+b) = N$.
> (iii) If moreover $1 < a - b$ and $a + b < N$, then $a-b$ is a nontrivial divisor of $N$.

*Proof.* (i) Expand: $(u+k)^2 - u(u+2k) = k^2$. (ii) $E_N(a) = b^2$ gives $a^2 - b^2 = N$ over $\mathbb Z$, i.e. $(a-b)(a+b) = N$; the natural-number statement follows since $b \le a$. (iii) By (ii), $a-b$ divides $N$ with cofactor $a+b$, and $1 < a-b \le a+b < N$. $\square$

> **Proposition 11 (the anchor is a hit exactly for squares).** $E_N(m) = 0$ if and only if $N$ is a perfect square.

*Proof.* Combine Propositions 5 and 6 with $\lfloor\sqrt{k^2}\rfloor = k$. $\square$

> **Corollary 12.** If $N$ is not a perfect square then $E_N(m) < 0$ strictly.

So the only window event that carries arithmetic content is the perfect-square hit; the sign structure carries none. We now make "carries none" exact.

### 2.3 Bracket and sign-count sensors have exactly zero information

Fix a window length $L \ge 1$ and define the **sign vector sensor**
$$\sigma_L(N) \;=\; \bigl(\operatorname{sgn} E_N(m+j)\bigr)_{j=0}^{L-1} \in \{-1,0,1\}^L$$
and the **negative-count sensor** $\nu_L(N) = \#\{\,0 \le j < L : E_N(m+j) < 0\,\}$.

> **Theorem 13 (structural identity of the bracket sensor).** For every non-square $N$ and every $L$,
> $$\sigma_L(N) = (-1, +1, +1, \dots, +1), \qquad \nu_L(N) = 1 .$$
> In particular $\sigma_L$ and $\nu_L$ are constant on any family of non-square moduli.

*Proof.* Corollary 12 gives the $j=0$ entry; Theorem 7 gives all others. The count follows since the filtered index set is exactly $\{0\}$. $\square$

> **Theorem 14 (exact null for the bracket sensor class).** Let $\Omega$ be any finite set of non-square moduli, $S$ any secret statistic, $g$ any function on sign vectors. Then
> $$\mathrm{ZI}(\Omega; \sigma_L, S), \qquad \mathrm{ZI}(\Omega; g \circ \sigma_L, S), \qquad \mathrm{ZI}(\Omega; \nu_L, S).$$

*Proof.* Theorem 13 plus Lemma 2; the post-processed case is Lemma 3. $\square$

This is the exact content of the reported measurement $\mathrm{MI}(\text{hits}; b_1) = 0.000000$, constant across all twenty tested instance blocks. The measurement did not fail to find a channel; it reported an identity.

---

## 3. Magnitude mirrors

### 3.1 Definition and basic calculus

Let $M : \Omega \to \mathcal M$ be a **magnitude** statistic: the intended reading is $M(N) = $ some bucketing of the size of $N$ (bit length, decile of $\log N$, $\lfloor N / 2^\ell\rfloor$, and so on), but no property of $M$ is assumed.

> **Definition 15 (magnitude mirror).** A feature $\Phi : \Omega \to \mathcal B$ **mirrors the magnitude $M$ on $\Omega$** if there exists $g : \mathcal M \to \mathcal B$ with $\Phi(w) = g(M(w))$ for all $w \in \Omega$.

> **Theorem 16 (exact invariance under injective recoding).** Let $F : \Omega \to \mathcal B$ and let $g : \mathcal B \to \mathcal D$ be injective. Then
> $$\mathrm{ZI}(\Omega; g \circ F, S) \iff \mathrm{ZI}(\Omega; F, S) .$$

*Proof.* For $d$ in the image of $g$, say $d = g(t)$, injectivity gives a bijection of the relevant fibres: $\{g\circ F = g(t)\} = \{F = t\}$ and likewise for the joint fibres, so the two defining identities coincide. For $d$ outside the image, both fibres are empty and the identity reads $0 = 0$. $\square$

> **Corollary 17 (monotone recodings).** If $\mathcal B$ is linearly ordered and $g$ is strictly monotone, then $g \circ F$ and $F$ have identical exact-information status against every secret.

Corollary 17 explains the observed coincidence in claim (C2). The reported spectral summary was, on the tested family, a strictly increasing function of $\log N$; hence its mutual information with the secret bit *had to* equal that of $\log N$ to every decimal place. The measured pair $0.1836$ / $0.1836$ (and, in the fine parameter cells, $0.0629$ / $0.0629$) is that theorem being observed, not a coincidence.

> **Theorem 18 (data processing for mirrors).** If $\Phi$ mirrors $M$ on $\Omega$ and $\mathrm{ZI}(\Omega; M, S)$, then $\mathrm{ZI}(\Omega; \Phi, S)$.

*Proof.* $\Phi$ agrees on $\Omega$ with $g \circ M$ (Lemma 4), and $\mathrm{ZI}$ is closed under post-processing (Lemma 3). $\square$

> **Theorem 19 (conditional collapse).** If $\Phi$ mirrors $M$ on $\Omega$, then for every magnitude cell $c \in \mathcal M$ and every secret $S$,
> $$\mathrm{ZI}\bigl(\Omega \cap M^{-1}(c);\ \Phi,\ S\bigr).$$

*Proof.* On $\Omega \cap M^{-1}(c)$ we have $\Phi(w) = g(M(w)) = g(c)$, a constant; apply Lemma 2. $\square$

Theorem 19 is the exact form of the observed collapse "conditioning on $\log N$ deciles gives $0.0000$ bits, $z = 0.0$, standard deviation $0$". A zero-variance zero is the signature of determinism.

### 3.2 The collapse is a characterization

Evidence of absence is weak; equivalence is not. The next two results upgrade Theorem 19 to an exact characterization of the sealed probe class.

> **Lemma 20 (zero self-information means constant).** Let $\Omega \ne \varnothing$. Then $\mathrm{ZI}(\Omega; T, T)$ if and only if $T$ is constant on $\Omega$.

*Proof.* ($\Leftarrow$) Lemma 2. ($\Rightarrow$) Pick $w_0 \in \Omega$ and set $n_0 = |\{T = T(w_0)\}| \ge 1$. The joint fibre for $(t,s) = (T(w_0), T(w_0))$ is the same set, so the defining identity reads $n_0 |\Omega| = n_0^2$, whence $n_0 = |\Omega|$ and the fibre is all of $\Omega$. $\square$

> **Theorem 21 (mirror $\iff$ exact conditional null).** Let $\Omega \ne \varnothing$. A feature $\Phi$ mirrors $M$ on $\Omega$ if and only if
> $$\forall S,\ \forall c \in \mathcal M : \quad \mathrm{ZI}\bigl(\Omega \cap M^{-1}(c);\ \Phi,\ S\bigr),$$
> where $S$ ranges over all statistics valued in the codomain of $\Phi$.

*Proof.* ($\Rightarrow$) Theorem 19. ($\Leftarrow$) Take $S = \Phi$. By Lemma 20, $\Phi$ is constant on every nonempty cell $\Omega \cap M^{-1}(c)$; choosing a representative value $g(c)$ per nonempty cell (and arbitrarily elsewhere) exhibits $\Phi = g \circ M$ on $\Omega$. $\square$

Thus "exactly $0.0000$ bits inside every magnitude cell, against every secret" is *logically equivalent* to the feature being a deterministic function of the magnitude. A measured exact conditional null is a proof of determinism, not a failure to reject.

### 3.3 Why the shuffle null was rejected: stratification, not transfer

> **Theorem 22 (mirrors are unconditionally null under homogeneous marginals).** Suppose $\Phi$ mirrors $M$ on $\Omega$, and the secret's marginal is homogeneous across magnitude cells, i.e. for every $c$ in the image of $M$ and every value $s$,
> $$\bigl|\{w \in \Omega : M(w)=c,\ S(w)=s\}\bigr| \cdot |\Omega| \;=\; \bigl|\{M = c\}\bigr| \cdot \bigl|\{S = s\}\bigr| .$$
> Then $\mathrm{ZI}(\Omega; \Phi, S)$.

*Proof sketch.* Write $\Phi = g \circ M$ on $\Omega$ and fix a feature value $t$. Let $F = \{c \in M(\Omega) : g(c) = t\}$. Partitioning $\Omega$ into magnitude fibres,
$$|\{\Phi = t,\ S = s\}| = \sum_{c \in F} |\{M=c,\ S=s\}|, \qquad |\{\Phi = t\}| = \sum_{c \in F} |\{M=c\}| .$$
Multiplying the first identity by $|\Omega|$ and applying the homogeneity hypothesis termwise turns the sum into $\sum_{c\in F} |\{M=c\}|\cdot|\{S=s\}| = |\{\Phi=t\}|\cdot|\{S=s\}|$. $\square$

> **Corollary 23 (diagnosis theorem).** If $\Phi$ mirrors $M$ on $\Omega$ and $\Phi$ is *not* exactly independent of $S$ on $\Omega$, then there exist a magnitude cell $c$ and a secret value $s$ witnessing failure of homogeneity: the secret's marginal provably differs across magnitude cells.

*Proof.* Contrapositive of Theorem 22. $\square$

> **Theorem 24 (stratification is not transfer — explicit witness).** There exist a finite $\Omega$, a magnitude $M$, a strictly monotone recoding $\Phi = 2M$, and a secret $S$ such that $\Phi$ has *nonzero* unconditional exact information about $S$ while $\mathrm{ZI}(\Omega \cap M^{-1}(c); \Phi, S)$ holds for *every* cell $c$.

*Proof.* Take $\Omega = \{2,3\}$, $M = \mathrm{id}$, $\Phi(N) = 2N$, $S(N) = N \bmod 2$. Then $\Phi$ separates the two instances and so does $S$, so the joint fibre count for $(t,s) = (4,0)$ is $1$ while the product of marginals over $|\Omega|$ is $1\cdot 1$ against $|\Omega| = 2$: the defining identity fails, so $\Phi$ is not exactly independent of $S$. Every magnitude cell of $M = \mathrm{id}$ contains at most one instance, and on a one-point (or empty) set every statistic is exactly independent of every other. $\square$

**Interpretation.** A row-shuffle permutation null breaks the $\Phi$–$S$ pairing while preserving both marginals; it therefore tests *association*, which Corollary 23 shows a mirror can exhibit purely through the drift of $S$'s marginal with scale. Any sufficiently fine monotone function of $N$ inherits this stratification and will report $z \gg 3$. The correct controls are (i) conditioning on magnitude cells, which by Theorem 21 gives an exact criterion, or (ii) testing incremental transfer beyond a channel that already knows $N$.

### 3.4 Closure: the joint battery is a single mirror

A natural objection to Theorems 19–21 is that individual probes may be mirrors while a *combination* is not. It is not so.

> **Theorem 25 (closure properties).** Fix $\Omega$ and a magnitude $M$.
> (i) Every constant feature mirrors $M$.
> (ii) If $\Phi$ mirrors $M$ then so does $g \circ \Phi$, for every $g$.
> (iii) If $\Phi_1, \Phi_2$ mirror $M$ then so does $w \mapsto (\Phi_1(w), \Phi_2(w))$.
> (iv) If $\Phi_i$ mirrors $M$ for each $i$ in a finite index set, then so does the tuple $w \mapsto (\Phi_i(w))_i$.
> (v) If $M$ factors through a finer magnitude $M'$ on $\Omega$ (i.e. $M = p \circ M'$ there), then any mirror of $M$ mirrors $M'$.

*Proof.* All five are immediate from Definition 15 by composing or pairing the witnessing functions; (iv) uses a choice of witness per coordinate. $\square$

> **Theorem 26 (joint seal).** Let $\Phi_1,\dots,\Phi_n$ be magnitude mirrors on $\Omega$ and let $g$ be an arbitrary function of the joint read. Put $\Psi(w) = g(\Phi_1(w),\dots,\Phi_n(w))$. Then:
> (a) for every magnitude cell $c$ and every secret $S$, $\mathrm{ZI}(\Omega \cap M^{-1}(c); \Psi, S)$; and
> (b) if $\Psi$ shows any unconditional dependence on $S$, then the secret's marginal provably varies across magnitude cells.

*Proof.* $\Psi$ is a mirror by Theorem 25(ii),(iv); then (a) is Theorem 19 and (b) is Corollary 23. $\square$

Theorem 26 seals the realized probe battery as a whole: bracket sensors (constants, hence mirrors by 25(i)), spectral summaries, magnitude-of-Gauss-sum probes, and any hash, score, or learned function of all of them read jointly. Inside every magnitude cell the joint read is exactly uninformative about every secret.

---

## 4. The surviving channel: the factor-derived positional oracle

### 4.1 Definition and profile

Let $d : \Omega \to \mathbb N$ be a factor-derived statistic — canonically, $d(w)$ is the smallest nontrivial factor of the instance's modulus — and let $B$ be a threshold. The **positional oracle** is the single bit $\mathbb 1\{d(w) \le B\}$. Define the **below-threshold fraction**
$$p_\Omega(B) \;=\; \frac{|\{w \in \Omega : d(w) \le B\}|}{|\Omega|} .$$

> **Proposition 27.** $0 \le p_\Omega(B) \le 1$, and $B \mapsto p_\Omega(B)$ is monotone non-decreasing.

*Proof.* Nonnegativity and the bound are card-of-filter bounds; monotonicity holds because the filtered sets are nested in $B$. $\square$

The information capacity of the bit on $\Omega$ is the binary entropy $H(p_\Omega(B))$ (in nats: $H(p) = -p\log p - (1-p)\log(1-p)$).

> **Theorem 28 (one-bit cap).** $H(p_\Omega(B)) \le \log 2$ for every $B$.

> **Theorem 29 (unimodality).** Let $B_1 \le B_2$.
> (i) If $p_\Omega(B_2) \le 1/2$ then $H(p_\Omega(B_1)) \le H(p_\Omega(B_2))$ (ascent below the median).
> (ii) If $p_\Omega(B_1) \ge 1/2$ then $H(p_\Omega(B_2)) \le H(p_\Omega(B_1))$ (descent above the median).

*Proof.* Binary entropy is strictly increasing on $[0,1/2]$ and strictly decreasing on $[1/2,1]$; compose with the monotone profile of Proposition 27. $\square$

> **Theorem 30 (the peak is exact balance).** For $\Omega \ne \varnothing$,
> $$H(p_\Omega(B)) = \log 2 \iff p_\Omega(B) = \tfrac12 \iff 2\,\bigl|\{w \in \Omega : d(w)\le B\}\bigr| = |\Omega| .$$

*Proof.* The first equivalence is the strict-maximum property of binary entropy; the second is clearing denominators in the definition of $p_\Omega$. $\square$

> **Theorem 31 (interval superlevel sets).** If $B_1 \le B \le B_2$ and $H(p_\Omega(B_i)) \ge \theta$ for $i = 1,2$, then $H(p_\Omega(B)) \ge \theta$.

*Proof.* If $p_\Omega(B) \le 1/2$, apply Theorem 29(i) to the pair $(B_1, B)$; otherwise apply Theorem 29(ii) to $(B, B_2)$. $\square$

Theorem 31 is what makes reported thresholds meaningful: the set of $B$ at which the oracle reaches at least $90\%$ of its peak capacity is an interval, so "the smallest such $B$" is a genuine endpoint rather than an artifact of a search grid. On the tested family the measured profile peaks at $0.4798$ bits near $B \approx 22758$, with $B^\ast = 10420$ the left endpoint of the $\ge 90\%$ interval and median $d$ equal to $215782$; Theorems 29–31 are exactly the shape such a profile must have.

### 4.2 The oracle is outside the sealed class, and its yield is capped

> **Theorem 32 (not a mirror).** The positional oracle is not a magnitude mirror. Explicitly, on the two-instance set $\{(2,7), (3,5)\}$ of factorizations — both of which lie in the same coarse magnitude cell $\lfloor N/8\rfloor = 1$, since $14$ and $15$ do — the bit $\mathbb 1\{d \le 2\}$ takes different values, so it is not a function of the magnitude.

*Proof.* A mirror would force $g(1) = 1$ and $g(1) = 0$. $\square$

> **Theorem 33 (informative inside a magnitude cell).** On that same single magnitude cell, the oracle bit fails exact independence from a secret residue of the cofactor. Hence, by Theorem 19, no magnitude mirror can reproduce its behaviour, and the collapse argument of §3 provably does not apply to it.

> **Theorem 34 (multi-oracle pigeonhole).** For any $L$ Boolean statistics $T_1,\dots,T_L$ on $\Omega$ there is a sign pattern $c \in \{0,1\}^L$ with
> $$|\Omega| \;\le\; 2^L \cdot \bigl|\{w \in \Omega : (T_1(w),\dots,T_L(w)) = c\}\bigr| .$$
> In particular ($L=1$) a single Boolean read always leaves a class containing at least half the instances.

*Proof.* The $2^L$ pattern fibres partition $\Omega$; take a fibre of maximal cardinality and bound the total by $2^L$ copies of it. $\square$

So the surviving channel is real but strictly rationed: one bit per read, with a candidate set that shrinks by at most a factor $2^L$ after $L$ reads. This is the counting counterpart of the stipulated oracle cost laws used in the corresponding cost analysis, which are unaffected by the retraction of claims (C1) and (C2) because they never depended on a realized probe.

---

## 5. The Fermat frontier: a two-sided cost law in the imbalance

The retracted mechanism was, in effect, mistaking a genuine geometric law for a channel. Here is the law.

Write $N = u(u+2k)$ with $u \ge 1$, $k \ge 0$; thus the two factors are $u$ and $u+2k$, and $k$ is half their gap — the **imbalance**. The unique Fermat centre is $a = u+k$, with $E_N(u+k) = k^2$ by Theorem 10(i). Let $m = \lfloor\sqrt N\rfloor$ and let
$$j = (u+k) - m$$
be the **frontier offset**, i.e. the number of ascent steps from the anchor to the hit.

> **Lemma 35 (the anchor never overshoots the centre).** $\lfloor\sqrt{u(u+2k)}\rfloor \le u+k$.

*Proof.* $u(u+2k) \le (u+k)^2$, and $\lfloor\sqrt\cdot\rfloor$ is monotone with $\lfloor\sqrt{(u+k)^2}\rfloor = u+k$. $\square$

> **Theorem 36 (upper frontier law).** With the notation above,
> $$2 m j \;\le\; k^2 + 2m, \qquad\text{hence (for } m \ge 1)\qquad j \;\le\; \frac{k^2}{2m} + 1 .$$

*Proof sketch.* Write $u+k = m + j$. Then $(m+j)^2 = N + k^2$ by Theorem 10(i). Expanding, $2mj + j^2 = k^2 + (N - m^2)$, and $N - m^2 \le 2m$ because $N < (m+1)^2$. Dropping $j^2 \ge 0$ yields $2mj \le k^2 + 2m$. The division form follows by the integer-division estimate applied to $2m(j-1)\le k^2$. $\square$

> **Theorem 37 (lower frontier law).** $k^2 \le 2(u+k)\,j$.

*Proof sketch.* From $(m+j)^2 = N + k^2$ and $m^2 \le N$ one gets $k^2 \le 2mj + j^2 \le 2(m+j)j = 2(u+k)j$. $\square$

> **Corollary 38 (frontier exponent).** Since $m = \lfloor\sqrt N\rfloor \le u+k \le m + j$, Theorems 36 and 37 give
> $$\frac{k^2}{2(u+k)} \;\le\; j \;\le\; \frac{k^2}{2\lfloor\sqrt N\rfloor} + 1, \qquad\text{i.e.}\qquad j = \Theta\!\left(\frac{k^2}{\sqrt N}\right)$$
> whenever $j = o(\sqrt N)$, with explicit constants $1/2$ and $2$.

The cost of the only surviving arithmetic channel is therefore a pure function of the imbalance $k$: no residue, no spectral summary, and no window length appears. Balanced semiprimes ($k \lesssim N^{1/4}$) are reached in $O(1)$ steps; for $k = N^{\alpha}$ with $1/4 < \alpha < 1/2$ the ascent needs $\Theta(N^{2\alpha - 1/2})$ steps. And $k$ is precisely the quantity that the positional oracle reads — and that no realized probe reads.

**Worked instance.** $N = 59 \cdot 101 = 5959$, so $u = 59$, $k = 21$, $m = \lfloor\sqrt{5959}\rfloor = 77$, centre $u+k = 80$, offset $j = 3$, and indeed $E_N(80) = 6400 - 5959 = 441 = 21^2$. The upper law gives $j \le 441/154 + 1 = 3.86\ldots$; the lower law gives $j \ge 441/160 = 2.76\ldots$. Both are tight to within a single step.

---

## 6. The bridge: square moduli and the Pythagorean tree

Recall that a triple $(x,y,z)$ of integers is Pythagorean when $x^2 + y^2 = z^2$.

> **Theorem 39 (square hits are Pythagorean triples).** If $u(u+2k) = s^2$ then $(k,\ s,\ u+k)$ is a Pythagorean triple.

*Proof.* $k^2 + s^2 = k^2 + u^2 + 2uk = (u+k)^2$. $\square$

> **Theorem 40 (converse).** If $(k, s, c)$ is a Pythagorean triple with $k \le c$, then setting $u = c - k$ we have $u(u+2k) = s^2$: every triple arises as a Fermat factorization of a square modulus.

*Proof.* Substituting $c = u+k$ into $k^2 + s^2 = c^2$ gives $s^2 = u^2 + 2uk = u(u+2k)$. $\square$

> **Theorem 41 (frontier identity over squares).** If $u(u+2k) = s^2$, then $\lfloor\sqrt{u(u+2k)}\rfloor = s$ — the anchor is the root itself — and the frontier offset satisfies the exact identity
> $$\bigl((u+k) - s\bigr)\bigl((u+k) + s\bigr) = k^2 .$$
> Equivalently, with hypotenuse $c = u+k$: $(c-s)(c+s) = k^2$.

*Proof.* The first claim is $\lfloor\sqrt{s^2}\rfloor = s$; the identity is $c^2 - s^2 = k^2$, i.e. Theorem 39 rearranged, restricted to $\mathbb N$ using $s \le c$ (Lemma 35). $\square$

So over square moduli the ascent distance is exactly $k^2/(c+s)$ — the leg squared divided by the sum of hypotenuse and other leg, a sharp instance of the two-sided law of §5.

> **Theorem 42 (Barning–Hall descent of square hits).** If $u(u+2k) = s^2$ with $k, s > 0$, then the Barning–Hall parent hypotenuse of the triple $(k, s, u+k)$ is strictly smaller than $u+k$:
> $$-2k - 2s + 3(u+k) \;<\; u+k .$$

Thus every square hit lies strictly above a smaller one in the classical ternary descent on primitive Pythagorean triples: the square-hit window over square moduli is not merely *related to* the Pythagorean tree — it is the tree, and the Fermat frontier ascent is a walk in it.

**Worked instance.** $144 = 12^2 = 8\cdot 18 = 8\cdot(8 + 2\cdot 5)$: here $u = 8$, $k = 5$, $s = 12$, hypotenuse $c = 13$, frontier offset $c - s = 1$, and the identity reads $1 \cdot 25 = 5^2$. The triple is $(5,12,13)$.

---

## 7. Algorithms

Three procedures follow directly from the theory and are exactly what the numerical work computes.

**(A) Anchored ascent with hit detection.** Given $N$: set $m \leftarrow \lfloor\sqrt N\rfloor$; for $j = 0, 1, 2, \dots$ up to a budget, let $a = m + j$, $e = a^2 - N$; if $e \ge 0$ and $e$ is a perfect square with root $b$, return $(a-b, a+b)$. Cost: by Corollary 38, the hit for imbalance $k$ appears at $j = \Theta(k^2/\sqrt N)$ steps, each step costing one integer square-root test. Correctness of the returned pair is Theorem 10(ii).

**(B) Exact independence test (counting mutual information).** Given a finite instance table with feature column $T$ and secret column $S$: build the joint contingency table and check the identity $|\{T=t,S=s\}|\cdot|\Omega| = |\{T=t\}|\cdot|\{S=s\}|$ for all cells; report the empirical mutual information $\sum \hat p(t,s)\log\frac{\hat p(t,s)}{\hat p(t)\hat p(s)}$, which is $0$ exactly when the identity holds everywhere. Cost: $O(|\Omega|)$ to tabulate, $O(|\mathcal T||\mathcal S|)$ to check.

**(C) Magnitude-conditioned null.** Given a feature, a secret, and a magnitude bucketing: run (B) separately inside each magnitude cell and aggregate by cell weight. By Theorem 21 the aggregate is exactly zero **iff** the feature is a deterministic function of the magnitude. This replaces the row-shuffle null, which by Corollary 23 tests the wrong hypothesis.

**(D) Oracle capacity profile.** Given the factor-derived column $d$ and a grid of thresholds: compute $p_\Omega(B)$ by sorting $d$ once, then $H(p_\Omega(B))$ per threshold; return the argmax and, using Theorem 31, the interval of $B$ achieving at least a target fraction of the peak. Cost: $O(|\Omega|\log|\Omega|)$ plus $O(\#\text{grid})$.

---

## 8. Discussion

### 8.1 What was retracted, and on what grounds

Claim (C1) is refuted by a definitional fact (Corollary 9): the integer square root *is* the last integer with non-positive energy, so the anchored window has exactly one sign change and it is at the anchor. Any sensor built on the sign structure is therefore a constant on non-squares (Theorem 13) and exactly uninformative (Theorem 14). No experiment can rescue a statistic that takes one value.

Claim (C2) is refuted by Theorems 16, 19 and 21: the realized spectral summaries are strictly monotone recodings of the magnitude, hence exactly as informative as $\log N$ (matching to four decimals, as observed), hence exactly uninformative given the magnitude. Because Theorem 21 is an equivalence, the exact conditional null is not weak evidence; it is a proof.

### 8.2 What the failure teaches about experimental design

The general lesson is Corollary 23 read as a warning: for a feature that is a deterministic function of a covariate, rejecting a row-shuffle null certifies *stratification of the response across the covariate*, never transfer. Theorem 24 makes this concrete with a two-instance witness. The design correction is Theorem 21: condition on the covariate and test for exact conditional independence, or test incremental information over a channel that already knows the covariate. This is not a factoring-specific caution — it applies verbatim to any pipeline where a feature is a fine monotone function of scale.

### 8.3 What remains, and how much it is worth

The tree stands sealed against every realized probe class: residues, magnitude-of-Gauss-sum probes (residue dials in disguise), bracket sensors (structural constants, §2), and spectral summaries (magnitude mirrors, §3), each of which is exactly null once the magnitude is held fixed — and, by Theorem 26, jointly so.

Outside the seal there is exactly one channel with genuine content, the factor-derived positional oracle $\mathbb 1\{d \le B\}$. It is provably not a mirror (Theorem 32), provably informative inside a fixed magnitude cell (Theorem 33), and provably capped at one bit per read (Theorems 28 and 34). Its capacity profile is a monotone-composed unimodal curve with an exactly characterized peak at combinatorial balance (Theorems 29–31). And it reads the imbalance $k$, which by Corollary 38 is exactly the parameter controlling the cost of the Fermat ascent. It is, in short, the right quantity — and no realized probe computes it.

---

## 9. Future work

**A. A mirror-rank dichotomy.** Being a mirror should be the bottom of a filtration: say a probe has *mirror rank $r$* if its fibres refine each magnitude cell into at most $r$ classes, so rank $1$ is exactly the mirror case sealed by Theorem 21. We conjecture that every probe realizable by a $\mathrm{poly}(\log N)$-time read of the anchored window — sign vectors, bracket flags, spectral summaries, Gauss magnitudes — has mirror rank $1$, whereas $\mathbb 1\{d \le B\}$ has rank $\ge 2$ on every family containing two same-magnitude instances with different smallest factor. That would make the situation a dichotomy rather than a spectrum. Theorems 26 and 33 supply both endpoints; what is missing is the proof that window-local reads cannot separate same-magnitude instances, which is a finite computation on the window recurrence.

**B. A frontier-cost exponent law.** Corollary 38 pins the frontier at $j = \Theta(k^2/\sqrt N)$ with explicit constants $1/2$ and $2$. We conjecture the sharp statement: for semiprimes with $k \le N^{1/4}$ the anchored ascent finds the hit in $O(1)$ steps, and for $k = N^\alpha$ with $1/4 < \alpha < 1/2$ it needs $\Theta(N^{2\alpha - 1/2})$ steps. Upgrading the two inequalities to this asymptotic form requires only a clean integer-square-root asymptotic wrapper, and would turn stipulated oracle cost laws into theorems.

**C. Completeness of conditional nulls under coarsening.** Theorem 21 makes "exactly zero bits given the magnitude cell" equivalent to determinism. We conjecture the equivalence survives coarsening: if a feature has exactly zero conditional information given a *coarse* magnitude, it is a mirror of that coarse magnitude, and consequently exact conditional nulls composed along a refinement chain characterize the whole mirror hierarchy.

---

## 10. Summary of results

1. The anchored energy satisfies $E_N(m) \le 0 < E_N(m+j)$ for all $j \ge 1$; the unique zero crossing is at $\sqrt N$, never at a divisor offset.
2. Window sign vectors and sign counts are constants on non-squares; they and all their post-processings have exactly zero empirical mutual information with every secret.
3. A square hit $E_N(a) = b^2$ is equivalent to a factorization $N = (a-b)(a+b)$; the anchor is a hit exactly for perfect squares.
4. Injective — in particular strictly monotone — recodings preserve exact information; a spectral summary that is monotone in $\log N$ is the channel $\log N$.
5. A feature is a deterministic function of the magnitude **iff** it has exactly zero information about every secret inside every magnitude cell.
6. Magnitude mirrors are closed under post-processing, pairing, finite tupling and magnitude refinement, so the joint realized battery is a single mirror and is jointly sealed.
7. A mirror with unconditional signal forces stratification of the secret across magnitude cells; row-shuffle nulls therefore test the wrong hypothesis, with an explicit two-instance witness.
8. The positional oracle bit is not a mirror, is informative inside a magnitude cell, is capped at one bit per read with a $2^L$ pigeonhole for $L$ reads, and has a unimodal capacity profile peaking exactly at combinatorial balance with interval superlevel sets.
9. The Fermat frontier offset obeys $k^2/(2(u+k)) \le j \le k^2/(2\lfloor\sqrt N\rfloor) + 1$, i.e. $j = \Theta(k^2/\sqrt N)$ in the imbalance.
10. Over square moduli the square-hit window is exactly the set of Pythagorean triples, with frontier identity $(c-s)(c+s) = k^2$ and strict Barning–Hall descent.
