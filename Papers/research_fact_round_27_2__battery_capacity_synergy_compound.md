# Joint Capacity of Dial Batteries: Compounding Synergy, Two Ceilings, and Purely Higher-Order Information

**Author:** Aristotle
**Date:** 2026-09-18

---

## Abstract

We develop a finitary, counting-based theory of the information that a *battery* of residue dials carries about a hidden label on a finite population, and use it to analyse a measured phenomenon we call **synergy compounding**. For a four-dial battery of pairwise-coprime moduli $31, 23, 9, 8$ — jointly, the Chinese-Remainder code of modulus $51{,}336$ — read against a shared population of thirty thousand semiprimes, the joint capacity is $I = 8.2246$ bits while the additive prediction obtained by summing the four single-dial capacities is only $\Sigma = 3.9099$ bits. The synergy $I - \Sigma = +4.3147$ bits therefore exceeds the additive prediction itself, and the joint reading comes within $1.3$ bits of the label-entropy ceiling $H(L) = 9.5276$ bits. Decomposed by order, the total synergy at order two (six pairs) is $+0.244$ bits, at order three (four triples) $+3.822$ bits, and at order four $+4.315$ bits: pairwise interactions carry $6\%$ of the effect.

On the theoretical side we build the calculus that makes these numbers meaningful. From the inequality $\log t \le t-1$ we derive a log-sum inequality in counting form, and from it the exact cell decomposition of empirical conditional entropy and a **data processing inequality for mutual information** on empirical populations. This yields: vanishing capacity of the empty battery; **monotonicity of joint capacity** in the set of dials; the **label-entropy ceiling** $\mathrm{info}(S) \le H(L)$; the **code ceilings** $\mathrm{info}(S) \le H\big((d_i)_{i\in S}\big) \le \log_2 \prod_{i\in S} m_i$ and $\mathrm{info}(S) \le \log_2 |\Omega|$; two-sided bounds on synergy; and a **synergy budget** $\mathrm{syn}(S) \le \sum_{i \in S}\big(H(d_i) - \mathrm{info}(\{i\})\big)$. We then prove that higher-order synergy is not an artefact of the particular moduli: for the $k$-dial parity battery on $\{0,1\}^k$, *every* proper sub-battery carries exactly $0$ bits while the full battery carries exactly $1$ bit, its ceiling. Consequently no inequality of the form $\mathrm{info}(S) \le c\sum_{i\in S}\mathrm{info}(\{i\})$ holds for any constant $c$, and no control of synergies of order below $k$ constrains the joint synergy. Batteries are super-additive systems, unboundedly so; the only universal constraints are monotonicity, the ceilings, and the budget.

**Keywords:** mutual information, synergy, higher-order interaction, Chinese Remainder Theorem, data processing inequality, empirical entropy, parity, feature selection.

---

## 1. Introduction

### 1.1 The question

Suppose a hidden structure on a finite population is probed by several coarse measurements, each of which is individually almost uninformative. How much does the ensemble know? The naive answer — add up what each probe knows — is a *lower bound intuition* that is not even an inequality: ensembles can know far more than the sum of their parts, and can also know less (when probes duplicate each other).

The concrete setting that motivated this work is arithmetic. Let $\Omega$ be a population of semiprimes $N = pq$. A **dial** of modulus $m$ reads $N \bmod m$. A **battery** is a finite family of dials; by the Chinese Remainder Theorem, a battery of pairwise-coprime moduli $m_1,\dots,m_k$ is the same thing as the single dial of modulus $M = \prod_i m_i$. The hidden **label** we probe is a function of the *factors*, not of the product: for each modulus, the unordered pair of residues $\{p \bmod m_i, q \bmod m_i\}$ that the two primes leave. The question is how much of that hidden label the visible residues of the product can recover.

### 1.2 The measurement

On one shared population of thirty thousand semiprimes, with the four-dial battery $m = (31,23,9,8)$, $M = 51{,}336$:

| quantity | measured value |
|---|---|
| joint capacity $I$ | $8.2246$ bits |
| additive prediction $\Sigma$ (sum of four marginals) | $3.9099$ bits |
| synergy $I - \Sigma$ | $+4.3147$ bits |
| label-entropy ceiling $H(L)$ | $9.5276$ bits |
| total order-2 synergy (six pairs) | $+0.244$ bits |
| total order-3 synergy (four triples) | $+3.822$ bits |
| total order-4 synergy (the battery) | $+4.315$ bits |

Two features stand out. First, **the joint capacity more than doubles the additive prediction**: $2\Sigma = 7.8198 < 8.2246 = I$. Second, **the synergy is genuinely higher-order**: the pairwise table, which a previous round of analysis treated as the substance of the interaction, accounts for $0.244 / 4.315 \approx 5.7\%$ of the total.

The mechanism is structural. A single dial $N \bmod 31$ exposes one residue of the product, which is consistent with many residue pairs of the factors. The Chinese-Remainder joint code exposes all four residues at once — $\log_2 51{,}336 \approx 15.65$ binary units of distinguishing power — against which each dial's residue-pair label becomes nearly fully determined. Determination is a joint event; it has no pairwise shadow.

### 1.3 Contributions

1. **A finitary mutual-information calculus** on empirical populations (Section 3): the log-sum inequality in counting form, an exact cell decomposition of conditional entropy, and from them a data processing inequality for empirical mutual information — strictly stronger than data processing for entropy alone.
2. **Capacity arithmetic for batteries** (Section 4): the definitions of joint capacity, synergy and total pairwise synergy; monotonicity; the label-entropy ceiling; the code and sparse-table ceilings; two-sided synergy bounds; the synergy budget; and the extreme regime in which capacity *is* synergy.
3. **Two witnesses that synergy is genuinely higher-order** (Section 5): a three-dial battery with all marginals and all pairwise capacities zero and full capacity equal to its $1$-bit ceiling; and, for every width $k$, a $k$-dial battery in which every proper sub-battery is blind and the full battery saturates its ceiling.
4. **Consistency certificates and honest error analysis** (Sections 6 and 7): verification that the measured table obeys every proven ceiling and fits within the proven budget, together with a sparse-table analysis identifying one reported statistic ($0.0469$ bits of *which-factor* information on the full joint code) as suspected plug-in bias rather than signal.

---

## 2. Setting and definitions

Throughout, $\Omega$ is a finite non-empty population with $N = |\Omega|$, and all statistics are arbitrary functions out of $\Omega$ into finite-image types. Logarithms written $\log$ are natural; quantities in **bits** are those divided by $\log 2$, and we write them with $\log_2$. All quantities are *empirical* (plug-in): they are computed from counts on $\Omega$, with $\Omega$ carrying the uniform weighting. No probability space beyond the counting measure is required, and no limits are taken.

**Definition 2.1 (Cells, counts, empirical entropy).** For a statistic $f : \Omega \to A$ and a value $a$, the *fibre* is $f^{-1}(a)$ and the *count* is $c_f(a) = |f^{-1}(a)|$. The *image* $\mathrm{img}(f)$ is the finite set of values actually attained. The **empirical entropy** of $f$ is
$$H(f) \;=\; \sum_{a \in \mathrm{img}(f)} \frac{c_f(a)}{N}\,\Big(\log N - \log c_f(a)\Big),$$
and the entropy in bits is $H_2(f) = H(f)/\log 2$.

Two immediate facts are used constantly: $H$ is monotone under refinement, i.e. $H(g \circ f) \le H(f)$ for any post-processing $g$ (coarsening merges cells and cannot raise entropy), and $H$ depends only on the partition of $\Omega$ into fibres, so a statistic may be replaced by any injective re-coding of it. If $f$ takes $m$ values with all fibres of equal size $k$, then $H(f) = \log m = \log N - \log k$.

**Definition 2.2 (Paired statistic, conditional entropy, trace information).** For a label $L : \Omega \to \Lambda$ and a statistic $f : \Omega \to A$, write $(L,f) : x \mapsto (L(x), f(x))$. The **conditional entropy** is
$$H(L \mid f) \;=\; H\big((L,f)\big) - H(f),$$
and the **trace information** (mutual information) is
$$I(L;f) \;=\; H(L) - H(L\mid f) \;=\; H(L) + H(f) - H\big((L,f)\big).$$
In bits, $I_2(L;f) = I(L;f)/\log 2$.

**Definition 2.3 (Dial, battery, joint reading).** A **dial** on $\Omega$ is a pair consisting of a modulus $m \ge 1$ and a reading $r : \Omega \to \{0,1,\dots,m-1\}$. A **battery** indexed by $\iota$ is a family $d = (d_i)_{i \in \iota}$ of dials. For a finite $S \subseteq \iota$, the **joint reading** $r_S$ is the tuple $x \mapsto (r_i(x))_{i \in S}$, and the **code entropy** of the sub-battery is $\mathrm{cap}(S) = H_2(r_S)$.

**Definition 2.4 (Joint capacity, synergy, pairwise total).** For a battery $d$ and label $L$:
$$\mathrm{info}(S) \;=\; I_2\big(L ; r_S\big), \qquad
\mathrm{syn}(S) \;=\; \mathrm{info}(S) - \sum_{i\in S}\mathrm{info}(\{i\}),$$
$$\mathrm{pairsyn}(S) \;=\; \sum_{\substack{T \subseteq S \\ |T| = 2}} \mathrm{syn}(T).$$
The quantity $\mathrm{info}(S)$ is the *joint capacity in bits* of the sub-battery $S$; $\mathrm{syn}(S)$ is its excess over the additive prediction; $\mathrm{pairsyn}(S)$ is the order-two total.

Two conventions deserve comment. First, $\mathrm{syn}$ compares against *single-dial* marginals, not against a Möbius-style interaction decomposition; this is the quantity the experiment reports, and it has the advantage of being defined without any inclusion–exclusion over an entire lattice. Second, "order-$k$ total synergy" in the measured table means $\sum_{|T| = k} \mathrm{syn}(T)$, so that the order-$k$ line aggregates all sub-batteries of exactly that width.

---

## 3. A finitary mutual-information calculus

The results of Section 4 all rest on one inequality and one identity.

### 3.1 The log-sum inequality

**Theorem 3.1 (Log-sum inequality).** Let $t$ be a finite index set, $a_i \ge 0$ and $b_i > 0$ for $i \in t$. Then
$$\sum_{i \in t} a_i\big(\log b_i - \log a_i\big) \;\le\; \Big(\sum_{i\in t} a_i\Big)\Big(\log \sum_{i \in t} b_i - \log \sum_{i\in t} a_i\Big),$$
with the convention $0 \cdot \log 0 = 0$ (automatic, since the coefficient is the vanishing $a_i$).

*Proof sketch.* Write $A = \sum a_i$ and $B = \sum b_i$. If $A = 0$ both sides vanish. Otherwise $B > 0$, and for each $i$ with $a_i > 0$ apply $\log t \le t - 1$ at $t = b_i A/(a_i B) > 0$:
$$\log b_i - \log a_i - (\log B - \log A) \;\le\; \frac{b_i A}{a_i B} - 1 .$$
Multiplying by $a_i > 0$ gives $a_i(\log b_i - \log a_i) \le a_i(\log B - \log A) + \big(\tfrac{A}{B}b_i - a_i\big)$; for $a_i = 0$ the same bound holds trivially since its right side is nonnegative. Summing over $i$, the correction terms telescope: $\sum_i \big(\tfrac{A}{B}b_i - a_i\big) = \tfrac{A}{B}B - A = 0$. $\square$

### 3.2 Cell contributions and their merging

**Definition 3.2.** For a population of size $N$, a cell of size $c$ inside a block of size $C$ contributes
$$\psi(N; c, C) \;=\; \frac{c}{N}\big(\log C - \log c\big)$$
to the conditional entropy.

Two elementary identities make $\psi$ the right bookkeeping device. Writing $\varphi(N;c) = \tfrac{c}{N}(\log N - \log c)$ for the entropy contribution of a cell, one has $\psi(N;c,C) = \varphi(N;c) + \tfrac{c}{N}(\log C - \log N)$ and hence, for any family of counts $c_i$ summing to $C$,
$$\sum_i \psi(N; c_i, C) \;=\; \Big(\sum_i \varphi(N; c_i)\Big) - \varphi(N; C). \tag{3.1}$$
Equation (3.1) says exactly that the conditional-entropy contribution of a block is the entropy defect created by splitting the block into its cells.

**Theorem 3.3 (Counting log-sum inequality).** For finite families of counts $c_i \ge 0$ and $C_i > 0$,
$$\sum_{i} \psi(N; c_i, C_i) \;\le\; \psi\Big(N; \sum_i c_i, \sum_i C_i\Big).$$

*Proof sketch.* Apply Theorem 3.1 with $a_i = c_i$, $b_i = C_i$, and scale by $1/N$. $\square$

Interpretation: **merging cells can only raise the conditional-entropy contribution.** This is the engine of everything below.

### 3.3 Conditional entropy as a double sum

**Theorem 3.4 (Cell decomposition).** For any label $L$ and statistic $f$,
$$H(L \mid f) \;=\; \sum_{a \in \mathrm{img}(f)} \ \sum_{\ell \in \mathrm{img}(L)} \psi\big(N; \,c_{(L,f)}(\ell,a),\ c_f(a)\big).$$

*Proof sketch.* Expand $H((L,f))$ as a double sum of $\varphi$-contributions over the product of images, note that for each $a$ the joint counts $c_{(L,f)}(\ell, a)$ over $\ell$ sum to the marginal count $c_f(a)$, and apply (3.1) blockwise; subtracting $H(f) = \sum_a \varphi(N; c_f(a))$ leaves exactly the stated double sum. $\square$

### 3.4 Data processing

**Theorem 3.5 (Data processing for conditional entropy).** For any post-processing $g$ of the reading,
$$H(L \mid f) \;\le\; H(L \mid g \circ f).$$

*Proof sketch.* Group the values $a \in \mathrm{img}(f)$ by their image $b = g(a)$. Within the group over $b$, the joint counts satisfy $c_{(L,\,g\circ f)}(\ell, b) = \sum_{a : g(a) = b} c_{(L,f)}(\ell, a)$ and the marginals satisfy $c_{g\circ f}(b) = \sum_{a: g(a) = b} c_f(a)$. Apply Theorem 3.3 inside each group and each label value $\ell$, then sum over $\ell$ and $b$; by Theorem 3.4 the left side reassembles to $H(L\mid f)$ and the right side to $H(L \mid g\circ f)$. $\square$

**Corollary 3.6 (Data processing for trace information).** $I(L; g\circ f) \le I(L; f)$, and likewise in bits.

This is the statement that makes joint capacity monotone in the battery, and it is *not* a consequence of the entropy-level inequality $H(g\circ f) \le H(f)$: entropy monotonicity says the coarsened code is smaller, which by itself is compatible with it being *more* informative about the label.

### 3.5 Two further structural facts

**Theorem 3.7 (Capacity depends only on the partition).** If two statistics $f, g$ induce the same partition of $\Omega$ — i.e. $f(x) = f(y) \iff g(x) = g(y)$ for all $x,y$ — then $H(f) = H(g)$ and $I(L;f) = I(L;g)$ for every label $L$.

*Proof sketch.* Under the hypothesis each of $f,g$ factors through the other, so entropy monotonicity under post-processing applies in both directions; the same argument applied to the paired statistics $(L,f)$ and $(L,g)$ gives the second claim through $I = H(L) + H(f) - H((L,f))$. $\square$

This licenses the computational practice of replacing a Chinese-Remainder residue vector by the single integer $N \bmod M$ — or by any injective numerical code — without changing any measured capacity.

**Theorem 3.8 (The ceiling is attained by determination).** If the reading determines the label — $f(x) = f(y) \Rightarrow L(x) = L(y)$ — then $I(L;f) = H(L)$.

*Proof sketch.* Under the hypothesis $(L,f)$ and $f$ induce the same partition, so $H((L,f)) = H(f)$ and $I(L;f) = H(L) + H(f) - H(f)$. $\square$

**Theorem 3.9 (Incremental bound).** For statistics $f$ and $g$, $I\big(L;(f,g)\big) \le I(L;f) + H(g)$.

*Proof sketch.* Sub-additivity $H((f,g)) \le H(f) + H(g)$ plus the coarsening inequality $H((L,f)) \le H\big((L,(f,g))\big)$, substituted into the $I = H(L)+H(\cdot)-H((L,\cdot))$ expansion. $\square$

Theorem 3.9 is the seed of the synergy budget of Section 4.

---

## 4. Capacity arithmetic for batteries

Fix a battery $d = (d_i)$ on $\Omega$ with moduli $m_i$, and a label $L$.

**Theorem 4.1 (Nonnegativity).** $\mathrm{info}(S) \ge 0$ for every $S$.

*Proof sketch.* $H(L\mid r_S) \le H(L)$ by sub-additivity of entropy for the paired statistic. $\square$

**Theorem 4.2 (The empty battery carries nothing).** $\mathrm{info}(\emptyset) = 0$, hence $\mathrm{syn}(\emptyset) = 0$.

*Proof sketch.* The empty joint reading is a constant statistic. A constant $f$ has a single fibre, so $H(f) = 0$, and $(L,f)$ induces the same partition as $L$, so $H((L,f)) = H(L)$; thus $I(L;f) = H(L)+0-H(L) = 0$. $\square$

Capacity is therefore built entirely by adding dials: there is no capacity in the frame itself.

**Theorem 4.3 (Monotone capacity).** If $S \subseteq T$ then $\mathrm{info}(S) \le \mathrm{info}(T)$. In particular $\mathrm{info}(\{i\}) \le \mathrm{info}(S)$ for every $i \in S$.

*Proof sketch.* The joint reading $r_S$ equals $\rho \circ r_T$ where $\rho$ is the coordinate restriction $(v_j)_{j\in T} \mapsto (v_j)_{j \in S}$. Apply Corollary 3.6. $\square$

**Theorem 4.4 (Label-entropy ceiling).** $\mathrm{info}(S) \le H_2(L)$ for every $S$.

*Proof sketch.* $I = H(L) - H(L \mid r_S)$ and conditional entropy is nonnegative, because $H(f) \le H((L,f))$ by coarsening. $\square$

**Theorem 4.5 (Code ceilings).** For every $S$,
$$\mathrm{info}(S) \;\le\; \mathrm{cap}(S) \;\le\; \log_2\prod_{i \in S} m_i, \qquad \text{and} \qquad \mathrm{info}(S)\;\le\;\log_2 N .$$

*Proof sketch.* The first inequality is $I(L;f) \le H(f)$, i.e. $H(L) \le H((L,f))$ by coarsening. The second is the code bound: a joint reading takes at most $\prod_{i\in S} m_i$ values and entropy is at most the logarithm of the number of values. The third is the same bound with the trivial estimate that a statistic on $N$ individuals has at most $N$ non-empty cells. $\square$

For the round-27 battery the code ceiling is $\log_2(31\cdot 23\cdot 9\cdot 8) = \log_2 51{,}336 \approx 15.647$ bits, and the sparse-table ceiling with $N = 30{,}000$ is $\approx 14.87$ bits.

**Theorem 4.6 (Two-sided synergy bounds).** For every $S$,
$$\max_{i \in S}\ \Big(\mathrm{info}(\{i\}) - \sum_{j\in S}\mathrm{info}(\{j\})\Big)\;\le\;\mathrm{syn}(S)\;\le\;H_2(L).$$

*Proof sketch.* Upper: $\mathrm{info}(S) \le H_2(L)$ and the marginal sum is nonnegative. Lower: $\mathrm{info}(S) \ge \mathrm{info}(\{i\})$ by monotonicity, then subtract the marginal sum. $\square$

The lower bound quantifies how much redundancy can cost: a battery of $k$ dials each carrying $c$ bits, all of them the *same* $c$ bits, has $\mathrm{syn} = c - kc = -(k-1)c$, which is exactly the lower bound. Redundancy is bounded; super-additivity is bounded only by the label entropy.

**Theorem 4.7 (Synergy budget).** $\displaystyle \mathrm{syn}(S) \;\le\; \sum_{i\in S}\Big( \mathrm{cap}(\{i\}) - \mathrm{info}(\{i\})\Big)$, where $\mathrm{cap}(\{i\}) = H_2(r_i)$ is the code entropy of the single dial.

*Proof sketch.* Sub-additivity of entropy gives $\mathrm{cap}(S) \le \sum_{i\in S}\mathrm{cap}(\{i\})$; combine with $\mathrm{info}(S) \le \mathrm{cap}(S)$ and subtract $\sum_i \mathrm{info}(\{i\})$ from both sides. $\square$

Interpretation: **synergy is paid for out of unused code capacity.** A dial whose entire code entropy already shows up as label information has nothing left to contribute jointly; a dial with a wide code and negligible marginal information is a prime synergy contributor. For the measured battery the budget is at most $15.647 - 3.9099 \approx 11.74$ bits, against a measured $+4.3147$.

**Theorem 4.8 (Pure-synergy regime).** If $\mathrm{info}(\{i\}) = 0$ for every $i \in S$, then $\mathrm{syn}(S) = \mathrm{info}(S)$; in particular $\mathrm{syn}(S) > 0$ as soon as the battery carries anything.

*Proof sketch.* Immediate from the definition. $\square$

---

## 5. Higher-order synergy is real: two witnesses

The measured order decomposition assigns $94\%$ of the effect to orders three and four. One might hope this is a quantitative accident of the arithmetic population and that pairwise information is generically a decent proxy. It is not, and the following two constructions settle it in the strongest form.

### 5.1 The three-dial parity witness

Let $\Omega = \{0,1\}^3$ with the uniform counting measure ($N = 8$), let the battery consist of the three coordinate dials, each of modulus $2$ (dial $i$ reads $x_i$), and let the label be the parity $L(x) = x_1 \oplus x_2 \oplus x_3 \in \{0,1\}$.

**Theorem 5.1 (Capacity entirely of order three).**
1. $H_2(L) = 1$.
2. $\mathrm{info}(\{i\}) = 0$ for each $i$.
3. $\mathrm{info}(S) = 0$ for every $S$ with $|S| = 2$; hence every pairwise synergy is zero and $\mathrm{pairsyn} = 0$.
4. $\mathrm{info}(\{1,2,3\}) = 1 = H_2(L)$, the label-entropy ceiling, and $\mathrm{syn}(\{1,2,3\}) = 1$.

*Proof sketch.* All entropies here are entropies of statistics with equal fibre sizes on eight individuals, so each is the logarithm of the number of cells attained. The label is balanced: $H(L) = \log 2$. A single coordinate is balanced: $H(r_i) = \log 2$; the pair $(L, r_i)$ takes four values with two individuals each, so $H((L,r_i)) = \log 4$, whence $I = \log 2 + \log 2 - \log 4 = 0$. For a pair of distinct coordinates, the joint reading takes four values with two individuals each, $H = \log 4$, while $(L, r_{\{i,j\}})$ separates all eight individuals, $H = \log 8$; hence $I = \log 2 + \log 4 - \log 8 = 0$. Finally the three coordinates determine the individual and therefore the label, so by Theorem 3.8 $I = H(L)$, i.e. $1$ bit. Converting to bits and subtracting the vanishing marginals gives the synergy claims. $\square$

Two consequences are worth stating as such.

**Corollary 5.2.** No inequality $\mathrm{info}(S) \le c \sum_{i\in S}\mathrm{info}(\{i\})$ holds for any constant $c$, over all populations, labels and batteries.

**Corollary 5.3.** No bound on the pairwise synergies constrains the joint synergy: here every pairwise synergy is $0$ while the joint synergy is $1$ bit, the maximum permitted by the label-entropy ceiling.

### 5.2 The $k$-dial parity battery

Fix $k \ge 1$ and let $\Omega = \{0,1\}^k$ ($N = 2^k$), let dial $i$ read the $i$-th bit (modulus $2$), and let the label be the total parity $L(x) = \sum_i x_i \bmod 2$.

**Theorem 5.4 (Blindness of every proper sub-battery).** For $k \ge 1$ and every $S \subsetneq \{1,\dots,k\}$, $\mathrm{info}(S) = 0$. For $k \ge 1$, $\mathrm{info}(\{1,\dots,k\}) = 1 = H_2(L)$.

*Proof sketch.* Fix $S$ and $a \in \Omega$. The fibre of the joint reading $r_S$ through $a$ is the *agreement class* $\{x : x_i = a_i \ \forall i \in S\}$, which is a subcube of size $2^{\,k - |S|}$; hence all fibres of $r_S$ have the same size and $H(r_S) = |S|\log 2$. If $S$ is proper, pick $j \notin S$ and let $\sigma_j$ be the involution flipping bit $j$. It preserves every agreement class of $S$ and toggles the parity, so it is a bijection between the even-parity and odd-parity halves of the class: every fibre of $r_S$ splits exactly in half by label. Therefore all fibres of $(L, r_S)$ have size $2^{\,k-|S|-1}$ and $H((L,r_S)) = (|S|+1)\log 2$, giving
$$I(L;r_S) = \log 2 + |S|\log 2 - (|S|+1)\log 2 = 0 .$$
For $S = \{1,\dots,k\}$ the reading determines the individual, hence the label, and Theorem 3.8 gives $I = H(L) = \log 2$, i.e. exactly $1$ bit. $\square$

**Corollary 5.5 (Synergy of pure order $k$).** For $k \ge 2$: every dial carries $0$ bits, so the additive prediction is $0$; every sub-battery of width $< k$ has capacity $0$ and synergy $0$; the full battery has capacity $1$ bit, its ceiling, and synergy $1$ bit. Hence for every $k$ there exist batteries all of whose information is of order exactly $k$, and no bookkeeping over sub-batteries of bounded order can predict joint capacity.

The picture that emerges is a *scale* of batteries. At one end sit redundant batteries, with synergy as negative as $-(k-1)\max_i \mathrm{info}(\{i\})$. In the middle sit additive batteries, with synergy $0$. At the other end sit parity-like batteries, with all marginals $0$ and all the capacity concentrated at the top order. The measured semiprime battery sits far towards the parity end — $4.31$ bits of synergy against $3.91$ bits of marginals, with $94\%$ of the synergy above order two — without reaching the extreme.

---

## 6. Consistency of the measured table

The measured numbers can now be checked against the proven structure rather than merely reported.

**Proposition 6.1.** The round-27 table satisfies all of the following:
1. $I = 8.2246 \le 9.5276 = H_2(L)$: below the label-entropy ceiling, with a deficit of $1.3030$ bits.
2. $8.2246 \le \log_2 51{,}336$: below the Chinese-Remainder code ceiling. (Indeed $\log_2 51{,}336 \ge \log_2 2^{15} = 15$.)
3. $I - \Sigma = 8.2246 - 3.9099 = 4.3147$: the reported synergy is exactly the excess over the additive prediction.
4. $2\Sigma = 7.8198 < 8.2246 = I$: the joint capacity more than doubles the additive prediction.
5. $0.244 < 0.06 \cdot 4.3147 = 0.2589$: the pairwise total is under $6\%$ of the joint synergy.
6. $4.3147 \le \log_2 51{,}336 - 3.9099$: the synergy fits inside the budget of Theorem 4.7, which is at most $11.74$ bits.

Each item is an arithmetic verification against an inequality proved in Sections 3–4; items 2 and 6 use only the crude estimate $\log_2 51{,}336 \ge 15$, which already suffices.

### 6.1 An exact companion computation

Because the theory is finitary, it can also be evaluated *exactly* on a population enumerated in full, where no estimation question arises at all. Take the population of all $34{,}191$ semiprimes $N = pq$ with $1000 < p < q < 3000$, the same four dials $31,23,9,8$, and as hidden label the smaller prime factor $p$. Then, exactly:

| quantity | value (bits) |
|---|---|
| marginal capacities of the four dials | $0.0574,\ 0.0585,\ 0.0157,\ 0.0013$ |
| additive prediction $\Sigma$ | $0.1328$ |
| joint capacity $I$ | $6.2828$ |
| synergy $I - \Sigma$ | $+6.1500$ (a factor $47$ over $\Sigma$) |
| label-entropy ceiling $H_2(L)$ | $7.7520$ |
| order-2 total synergy (six pairs) | $+3.5588$ (mean $+0.5931$ per pair) |
| order-3 total synergy (four triples) | $+12.1119$ (mean $+3.0280$ per triple) |
| order-4 synergy | $+6.1500$ |

Every structural inequality of Sections 3–4 is satisfied, and the qualitative picture is the reported one in a sharper form: the marginals are negligible, the per-sub-battery synergy grows steeply with order ($0.59 \to 3.03 \to 6.15$ bits), and the joint capacity climbs to within $1.47$ bits of the label-entropy ceiling. The mechanism is visible: a single residue of the product constrains the factor pair hardly at all, while the joint Chinese-Remainder code, with $15.65$ bits of resolution, nearly pins the product and hence the factorisation.

---

## 7. Sparse-table bias and an honest caveat

The same experiment reports a *which-factor* statistic — an attempt to read, from the joint code, which of the two primes plays which role — at $0.0469$ bits on the full joint code, a value above every threshold established by the pairwise analysis. We do not claim this as signal, for a reason the theory above makes precise.

Empirical (plug-in) mutual information is biased upward when the contingency table is sparse. The bias is governed by the effective number of occupied cells relative to the sample size: in the classical regime with $R$ occupied reading-columns and $|\Lambda|$ label values on $N$ samples, the plug-in estimate of $I$ exceeds the truth by roughly $\frac{(R-1)(|\Lambda|-1)}{2N\log 2}$ bits even when the true value is zero. Here $R$ can be as large as $51{,}336$ against $N = 30{,}000$ samples: **most residue columns contain zero or one individual**, and a column containing one individual is, tautologically, perfectly predictive of that individual's label. The sparse-table ceiling $\mathrm{info}(S) \le \log_2 N$ of Theorem 4.5 is precisely the statement that all such "information" is bounded by the sample's own naming entropy: there is no way to distinguish, at this resolution, genuine dependence from the fact that each sample names itself.

Accordingly, the appropriate reading of the $0.0469$-bit figure is *suspected plug-in bias*, not a factor-dependence signal. The substantive factor-blindness claim rests on the well-conditioned strata — sub-batteries whose code size is small relative to $N$, where the bias term is negligible — together with the ceiling analysis above. Stating this explicitly is part of the result: a theory of joint capacity must come with a theory of when a joint measurement is even estimable.

The practical corollary is a design rule: a battery whose code entropy exceeds $\log_2 N$ cannot be evaluated honestly at full resolution on $N$ samples. One must either enlarge the population, coarsen the code (which, by data processing, yields a valid lower bound on the true capacity), or use a bias-corrected estimator.

---

## 8. Algorithms

We record the three procedures needed to reproduce and extend the analysis.

### 8.1 Empirical joint capacity of a sub-battery

**Input:** a population $x_1,\dots,x_N$; a label function $L$; readings $r_i$ for $i \in S$.
**Output:** $\mathrm{info}(S)$ in bits.

Build a hash table of counts for the joint reading $r_S$, one for the label $L$, and one for the pair $(L, r_S)$; then return $\big(H(L) + H(r_S) - H((L,r_S))\big)/\log 2$ where each $H$ is evaluated by the count formula of Definition 2.1. The cost is $O(N|S|)$ time and $O(\min(N, \prod_{i\in S}m_i))$ space. Note that only *occupied* cells enter the sums, so the implementation never materialises the $\prod m_i$ columns.

### 8.2 Order decomposition of synergy

**Input:** a battery of $k$ dials, a label.
**Output:** the table of totals $\big(\sum_{|T| = j}\mathrm{syn}(T)\big)_{j=2}^{k}$.

Compute the $k$ marginals once, then iterate over subsets $T$ of size $j$ for each $j$, computing $\mathrm{info}(T)$ by §8.1 and subtracting $\sum_{i\in T}\mathrm{info}(\{i\})$. The cost is $O(2^k N k)$ in the worst case, and $O\big(\binom{k}{j} N j\big)$ for a single order. For $k = 4$ this is fifteen passes over the population.

### 8.3 Ceiling audit

**Input:** measured $\mathrm{info}$ values, moduli, population size, label entropy.
**Output:** a pass/fail report on monotonicity in $S$, the label-entropy ceiling, the code ceiling $\log_2\prod_{i\in S}m_i$, the sparse-table ceiling $\log_2 N$, the two-sided synergy bounds, and the synergy budget.

Each check is a constant-time comparison once the capacities are in hand; the value of the audit is that a violation is proof of an implementation bug, since each inequality is a theorem.

---

## 9. Applications

**Feature and sensor selection.** Ranking candidate measurements by individual informativeness and taking the top $k$ is the default in practice. Corollary 5.2 says the loss can be total: in the parity battery every candidate scores exactly zero, and the optimal set is all of them. Weaker but more useful, Theorem 4.7 gives a *cheap, computable* upper bound on how much synergy a candidate set can possibly hide — namely the unused code capacity $\sum_i (H_2(r_i) - \mathrm{info}(\{i\}))$ — and hence a screening rule: sets whose members are individually near-saturated cannot surprise you.

**Auditing information leakage.** In side-channel and privacy settings, one asks whether a collection of observable statistics reveals a hidden attribute. The results here say that per-channel audits are unsound: each channel can be certified at zero leakage while the ensemble leaks everything. The corresponding positive tool is the ceiling structure: monotonicity means the leakage of any subset lower-bounds the leakage of the whole, so coarse audits produce valid lower bounds, while the label-entropy and code ceilings produce valid upper bounds without any measurement at all.

**Arithmetic statistics.** In the motivating setting the message is that a Chinese-Remainder battery approaches determination of factor-side residue labels *collectively*. Each added coprime modulus multiplies the number of distinguishable columns; the deficit against the label ceiling shrinks. With four dials the deficit is already down to $1.30$ bits out of $9.53$.

**Estimation practice.** Section 7 is itself an application: the sparse-table ceiling converts a vague worry about small-sample bias into a hard inequality that any reported number must satisfy, and flags the regime where reported numbers are not to be trusted.

---

## 10. Discussion

The revision this work forces on the naive picture is not that batteries are super-additive — that was already visible in the pairwise table of an earlier round — but a matter of *scale and order*. The pairwise picture suggested a mild correction to additive bookkeeping. The measured decomposition says the correction is larger than the thing it corrects, and that almost all of it lives above order two. The parity witnesses say this is not a quirk: for every width $k$ there are batteries whose capacity is *entirely* of order $k$, so the pairwise correction can be exactly zero while the joint effect is maximal.

What survives from the naive picture is only what is proved here: capacity starts at zero, grows monotonically with the battery, and is bounded by the label entropy, by the joint code entropy, by $\log_2 N$, and in its synergy by the unused code capacity. Those five facts are the whole of the universal theory. Everything quantitative must be measured on the joint code.

It is worth being precise about what the parity examples do and do not show. They do not show that real batteries have zero marginals — the measured one has $3.91$ bits of them. They show that *no theorem* can bound joint capacity in terms of marginals or low-order interactions, and therefore that the observed $94\%$ high-order share cannot be argued away as a measurement artefact by any general principle. A general principle that would do so does not exist.

---

## 11. Future directions

**Ceiling-approach law for Chinese-Remainder batteries.** *Conjecture.* For a battery of pairwise-coprime moduli $m_1,\dots,m_k$ on a population with label entropy $H_2(L)$, the capacity deficit $H_2(L) - \mathrm{info}(S)$ decays at least geometrically in the number of dials, provided each added dial separates a constant fraction of the currently confused pairs:
$$H_2(L) - \mathrm{info}(S \cup \{i\}) \;\le\; (1-c)\,\big(H_2(L) - \mathrm{info}(S)\big).$$
The key insight is that the deficit is exactly the conditional entropy $H_2(L \mid r_S)$, and each new dial refines the fibre partition, so a uniform separation rate should convert into a uniform multiplicative decay of that conditional entropy — a Doob-style martingale contraction in a purely finitary setting. The monotone decay is already available (Theorem 3.5); only the rate is missing, and the measurement $8.2246$ against a ceiling of $9.5276$ after four dials is exactly a measurement of that rate.

**Order-profile rigidity.** *Conjecture.* For every $k$ and every profile of nonnegative reals $(s_2,\dots,s_k)$ with $\sum_r s_r \le H_2(L)$, there is a battery of $k$ binary dials whose total synergy at order $r$ equals $s_r$ for each $r$. The parity family realises the extreme profiles $(0,\dots,0,1)$; independent-copy constructions realise profiles concentrated at order two; the general interpolation is open. A positive answer would say that the order profile is an unconstrained invariant subject only to the ceiling, completing the classification of what capacity arithmetic can look like.

**Bias-corrected joint estimation.** Extend the sparse-table ceiling into a quantitative estimator guarantee: given $N$ samples and a code of $R$ columns, produce a confidence *interval* for $\mathrm{info}$ whose width degrades gracefully in $R/N$, so that measurements in the regime of Section 7 can be reported rather than merely flagged.

**Optimal battery design.** Given a budget $\prod_i m_i \le M$, which pairwise-coprime multiset of moduli maximises joint capacity for a given arithmetic label? The budget theorem bounds the payoff; the extremal problem is untouched.

---

## 12. Conclusion

A battery of coarse dials is not the sum of its dials. On a shared population of semiprimes, four residue dials that individually contribute $3.9099$ bits about a hidden factor-side label contribute $8.2246$ bits jointly — a synergy of $+4.3147$ bits, more than doubling the additive prediction, and within $1.3$ bits of the $9.5276$-bit label-entropy ceiling. Pairwise interactions account for $6\%$ of that synergy; the rest appears only at orders three and four.

Behind the measurement lies a rigid but permissive theory. Joint capacity vanishes on the empty battery, is monotone under adding dials, is capped by the label entropy, by the joint code entropy, by $\log_2$ of the population size, and has its synergy capped by the code capacity its dials leave unused. Beyond those constraints nothing general is true: parity batteries of every width have every proper sub-battery blind and the full battery at its ceiling, so capacity can be entirely of top order and no constant multiple of the marginals bounds it.

The operational conclusion is one sentence. **Capacity must be computed jointly; marginal bookkeeping is not an approximation to it, but a different and unrelated quantity.**
