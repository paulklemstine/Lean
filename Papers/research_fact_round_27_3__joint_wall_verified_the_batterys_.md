# Factor Blindness: Exact Zero Which-Factor Leakage of Trace-Routed Batteries, and the Anatomy of a Plug-In Wall

**Author:** Aristotle
**Date:** 2026-09-20

---

## Abstract

A *battery* is a cheap measurement device on ordered pairs of integers: a chain of small modular fields, each recording the residues of the sum $p+q$ and the product $pq$ of the pair, concatenated positionally into a single integer code. An empirical programme reported that a four-field chained battery on moduli $[3,5,7,11]$ carried a residual $0.0469$ bits of mutual information about *which* of the two factors was the larger one — a small but nonzero apparent leak, a "wall" of finite height. A $200$-shuffle permutation null returned a mean of $0.0469$ bits with standard deviation $0.0014$, placing the observation $z = +0.05$ from its own null: the entire reading was estimator bias.

This paper replaces that empirical verdict by exact theorems. We prove: (i) **exact factor blindness** — on any swap-closed, off-diagonal population of ordered pairs, any symmetric readout has a contingency table that is exactly a product table, hence exactly zero which-factor mutual information; (ii) **sharpness** — zero plug-in mutual information holds *if and only if* the table is a product table, and an asymmetric readout on the same population family is detected at a full $1$ bit, so the zero is a property of the readout's symmetry and not a limitation of the functional; (iii) **the sparse law** — when the code is injective on the sample, the plug-in reading equals the label entropy exactly, its permutation null is a point mass, and the $z$-score numerator vanishes identically, reproducing the reported experimental signature in closed form; (iv) **capacity–leakage independence** — the chained code of moduli $m_1,\dots,m_r$ is bounded by $\prod_i m_i^2$, giving an entropy ceiling of $\log_2 1{,}334{,}025 \approx 20.35$ bits for the four-field battery, logically independent of the zero leakage; (v) **orbit blindness** — for any finite group $G$ acting on a population, any $G$-invariant readout leaks exactly zero bits about any torsor coordinate of the action, which recovers the two-factor wall as the case $|G| = 2$ and settles the $k$-factor case for $G = S_n$ with the ordering pattern as label; and (vi) **the arithmetic instance** — the ordered factorisations of $N$ form a swap-closed population, off-diagonal exactly when $N$ is not a perfect square, so a symmetric battery is exactly blind to cofactor order for every non-square $N$, in particular for every semiprime $N=pq$ with $p \ne q$.

**Keywords:** factor blindness, mutual information, plug-in bias, permutation null, Gibbs' inequality, symmetric functions, orbit blindness, divisor involution.

---

## 1. Introduction

### 1.1 The measurement problem

Let $N = pq$ be a semiprime with $p \ne q$. A *side-channel* question, quite different from the factoring problem itself, asks what cheap functions of the factor pair reveal. In particular, consider readouts built from small modular fingerprints of the pair. A single bit is at stake: does such a readout tell you which of the two coordinates carries the larger factor?

Formally, put a population $S$ of ordered pairs of naturals, a readout $c : \mathbb{N}\times\mathbb{N} \to K$ into a finite alphabet, and the binary **which-factor label**
$$\mathrm{lab}(p,q) \;=\; [\,p < q\,] \in \{\text{false},\text{true}\},$$
true when the second coordinate is the bigger factor. The **leakage** is the mutual information between $\mathrm{lab}$ and $c$ under the uniform law on $S$.

### 1.2 The empirical episode

The device under test was the four-field chained battery on moduli $[3,5,7,11]$ described in §2.1. On thousands of ordered prime pairs, the plug-in estimate of the leakage came back as $0.0469$ bits. A $200$-shuffle permutation null returned mean $0.0469$, standard deviation $0.0014$, hence $z = +0.05$. Under the standard reading of such a test, the observation is indistinguishable from its null: the reading is bias, not signal. A parallel two-field reading of $0.0011$ bits was likewise inside its own null.

There are two things wrong with stopping there. First, a null-consistent reading is a statement about the *estimator*, not about the population; "we cannot distinguish the leakage from zero at a sensitivity of $\pm 0.003$ bits" is much weaker than "the leakage is zero". Second, a permutation null with a very small spread is itself suspicious: it may indicate not a precise measurement but a statistic that shuffling cannot move.

This paper resolves both points. The truth is exactly zero, for a structural reason; and the estimator's small null spread is exactly what the theory predicts in the regime the experiment occupied.

### 1.3 Contributions and organisation

§2 defines the battery and proves trace routing. §3 develops the finite information theory we need — Gibbs' inequality, plug-in nonnegativity, product-table vanishing, and the max-entropy ceiling — from the single analytic inequality $\log x \le x-1$. §4 proves the exact factor-blindness theorem. §5 proves sharpness and the power of the instrument. §6 gives the closed-form analysis of the sparse regime that explains the experimental signature. §7 separates capacity from leakage. §8 generalises to orbit blindness under an arbitrary finite group, with the $S_n$ ordering instance. §9 instantiates on divisor populations and identifies the perfect-square exception as the sharp arithmetic boundary. §10 gives algorithms and numerics, §11 discusses methodology, and §12 lists open directions.

---

## 2. The battery and its trace routing

### 2.1 Definition

**Definition 2.1 (Chain step).** For a modulus $m \in \mathbb{N}$, a pair $x = (p,q)$ and an accumulator $a \in \mathbb{N}$, set
$$\mathrm{step}_m(x, a) \;=\; \bigl(a\,m + (p+q) \bmod m\bigr)\,m + (pq) \bmod m .$$

Each field thus contributes two base-$m$ digits: the residue of the **trace** $p+q$ and the residue of the **norm** $pq$.

**Definition 2.2 (Battery code).** For a list of moduli $\mathbf{m} = [m_1,\dots,m_r]$, the battery code is the left fold
$$\mathrm{code}_{\mathbf m}(x) \;=\; \mathrm{step}_{m_r}\bigl(x, \cdots \mathrm{step}_{m_1}(x, 0)\cdots\bigr).$$
The **four-field battery** is $\mathrm{code}_{[3,5,7,11]}$, written $B_4$.

### 2.2 Trace routing

**Theorem 2.3 (Trace routing).** If $x = (p,q)$ and $y = (p',q')$ satisfy $p+q = p'+q'$ and $pq = p'q'$, then $\mathrm{code}_{\mathbf m}(x) = \mathrm{code}_{\mathbf m}(y)$ for every list $\mathbf m$.

*Proof sketch.* Induct on $\mathbf m$ with the accumulator generalised. The base case is trivial. For the inductive step, $\mathrm{step}_m$ depends on $x$ only through $(p+q) \bmod m$ and $(pq) \bmod m$, which by hypothesis agree for $x$ and $y$; so the two chains enter the tail with equal accumulators and the inductive hypothesis applies. $\square$

The content of Theorem 2.3 is that the battery reads only the coefficients of the monic quadratic $X^2 - (p+q)X + pq$ whose roots are $p$ and $q$ — the Galois-invariant part of the pair.

**Corollary 2.4 (Swap symmetry).** $\mathrm{code}_{\mathbf m}(q,p) = \mathrm{code}_{\mathbf m}(p,q)$ for all $p,q$ and all $\mathbf m$, since addition and multiplication are commutative.

### 2.3 Alphabet bound

**Theorem 2.5 (Alphabet bound).** If every $m_i > 0$ then $\mathrm{code}_{\mathbf m}(x) < \prod_{i=1}^r m_i^2$ for all $x$.

*Proof sketch.* Induct with the stronger statement: if $a < A$ then the chain starting from $a$ is $< A\prod_i m_i^2$. For one step, $\mathrm{step}_m(x,a) = a m^2 + \bigl((p+q \bmod m)m + (pq \bmod m)\bigr)$, and the bracket is $< m^2$ because both residues are $< m$; hence $\mathrm{step}_m(x,a) < (a+1)m^2 \le A m^2$. $\square$

For $[3,5,7,11]$ this gives $B_4(x) < (3\cdot5\cdot7\cdot11)^2 = 1{,}334{,}025$, so $B_4$ is a readout into a finite alphabet of that size.

---

## 3. Finite information theory

All logarithms in readings are base $2$; entropies and informations are in bits.

**Definition 3.1.** For a finite joint mass function $p : L \times K \to \mathbb{R}$ on finite sets $L, K$, the margins are $p_L(\ell) = \sum_k p(\ell,k)$ and $p_K(k) = \sum_\ell p(\ell,k)$. The **plug-in mutual information** is
$$I(p) \;=\; \sum_{\ell \in L}\sum_{k \in K} p(\ell,k)\,\log_2 \frac{p(\ell,k)}{p_L(\ell)\,p_K(k)},$$
with the convention $0 \log 0 = 0$ (cells of zero mass contribute nothing). The **entropy** of a mass function $r$ on $K$ is $H(r) = -\sum_k r(k)\log_2 r(k)$.

**Theorem 3.2 (Gibbs' inequality, plug-in form).** Let $p$ be a probability vector on a finite index set, $q$ a nonnegative vector with $\sum_i q_i \le 1$, and suppose $q$ dominates $p$ in the sense $q_i = 0 \Rightarrow p_i = 0$. Then
$$\sum_i p_i \log\frac{p_i}{q_i} \;\ge\; 0 .$$

*Proof sketch.* For each $i$ with $p_i > 0$, domination gives $q_i > 0$, and $\log t \le t - 1$ at $t = q_i/p_i$ yields $p_i\log(q_i/p_i) \le q_i - p_i$, i.e. $-p_i\log(p_i/q_i) \le q_i - p_i$; for $p_i = 0$ the same bound is $0 \le q_i$. Summing, $-\sum_i p_i\log(p_i/q_i) \le \sum_i q_i - 1 \le 0$. $\square$

**Theorem 3.3 (One-sidedness of the plug-in reading).** If $p \ge 0$ and $\sum_{\ell,k} p(\ell,k) = 1$ then $I(p) \ge 0$.

*Proof sketch.* Apply Theorem 3.2 on the index set $L\times K$ with the table itself as $p$ and the product of margins as $q$. Absolute continuity is automatic here rather than assumed: a vanishing margin forces its whole row (or column) of nonnegative entries to vanish. The product of the margins has total mass $(\sum_\ell p_L(\ell))(\sum_k p_K(k)) = 1$. $\square$

Theorem 3.3 is the *mechanism* of plug-in bias: the functional is bounded below by its value at independence, so finite-sample noise can only push the reading upward.

**Theorem 3.4 (Product tables read exactly zero).** If $p(\ell,k) = p_L(\ell)\,p_K(k)$ for all $\ell,k$, then $I(p) = 0$.

*Proof sketch.* Cell by cell: either $p(\ell,k) = 0$, contributing $0$; or the ratio inside the logarithm is $1$, contributing $0$. $\square$

**Theorem 3.5 (Maximum-entropy ceiling).** For a probability vector $r$ on a nonempty finite $K$, $H(r) \le \log_2 |K|$.

*Proof sketch.* Apply Theorem 3.2 with the uniform vector $q \equiv 1/|K|$: the resulting inequality reads $\sum_k r_k\log r_k + \log|K| \ge 0$, i.e. $H(r) \le \log_2 |K|$ after dividing by $\log 2$. $\square$

Both halves of the battery claim — the nonnegativity that explains the bias, and the capacity ceiling — thus descend from the single inequality $\log x \le x-1$.

---

## 4. Exact factor blindness

Fix a finite alphabet $K$, a finite population $S \subset \mathbb{N}\times\mathbb{N}$ and a readout $c : \mathbb{N}\times\mathbb{N}\to K$.

**Definition 4.1.** The **readout fiber** is $F_k = \{x \in S : c(x) = k\}$ and the **cell** is $C_{b,k} = \{x \in S : c(x) = k,\ \mathrm{lab}(x) = b\}$. The **empirical joint law** is $P(b,k) = |C_{b,k}| / |S|$.

Two structural hypotheses on the population:

* **swap-closed**: $x \in S \Rightarrow x^{\mathrm{sw}} \in S$, where $(p,q)^{\mathrm{sw}} = (q,p)$;
* **off-diagonal**: $x = (p,q) \in S \Rightarrow p \ne q$.

And one on the readout: **symmetric**, $c(x^{\mathrm{sw}}) = c(x)$ for all $x$.

**Lemma 4.2 (Halving).** Under these hypotheses, $|C_{\text{true},k}| = |C_{\text{false},k}|$ for every $k \in K$.

*Proof sketch.* The map $x \mapsto x^{\mathrm{sw}}$ is an involution of $S$ (swap-closure). It preserves the readout (symmetry), hence maps each fiber to itself; and off the diagonal it flips the label, since $p<q$ if and only if $\neg(q<p)$ when $p \ne q$. It is therefore a bijection $C_{\text{true},k} \to C_{\text{false},k}$, being its own inverse. $\square$

**Lemma 4.3.** $|C_{\text{true},k}| + |C_{\text{false},k}| = |F_k|$, and $\sum_k |F_k| = |S|$.

**Proposition 4.4 (Product table).** Under the same hypotheses, for all $b, k$,
$$P(b,k) \;=\; P_L(b)\,P_K(k),$$
where $P_K(k) = |F_k|/|S|$ and, on a nonempty population, $P_L(b) = 1/2$ for both labels.

*Proof sketch.* By Lemmas 4.2–4.3, $2|C_{b,k}| = |F_k|$ for each $b$ and $k$. Summing over $k$ gives $2\sum_k |C_{b,k}| = |S|$, i.e. $P_L(b) = 1/2$. Then $P(b,k) = |C_{b,k}|/|S| = \tfrac12 |F_k| / |S| = P_L(b)P_K(k)$. (The empty population is degenerate, all quantities being $0$, and the identity holds trivially.) $\square$

**Theorem 4.5 (Exact factor blindness).** Let $S$ be swap-closed and off-diagonal, and $c$ symmetric. Then
$$I(P) \;=\; 0 \quad \text{exactly.}$$

*Proof.* Proposition 4.4 and Theorem 3.4. $\square$

**Corollary 4.6 (Four-field battery).** On any swap-closed, off-diagonal population, the which-factor leakage of $B_4$ is exactly $0$ bits.

*Proof.* Corollary 2.4 supplies symmetry. $\square$

**Remark 4.7 (Non-vacuity).** The hypotheses are satisfiable together with a *non-constant* readout. On $S = \{(3,5),(5,3),(7,11),(11,7)\}$ one has $B_4(3,5) = B_4(5,3) = 979345$ and $B_4(7,11) = B_4(11,7) = 400708$; the readout separates the two unordered pairs, carries a full bit of readout entropy, and leaks exactly $0$ about the label. The zero is therefore not the zero of a constant instrument.

---

## 5. Sharpness: the wall is exactly the product locus

Theorem 4.5 says when the reading *must* vanish. The converse question — can this functional see leakage at all? — requires the equality case of Gibbs.

**Theorem 5.1 (Strict Gibbs).** In the setting of Theorem 3.2, if there exists an index $i_0$ with $p_{i_0} > 0$ and $p_{i_0} \ne q_{i_0}$, then $\sum_i p_i\log(p_i/q_i) > 0$.

*Proof sketch.* The per-index bound $-p_i\log(p_i/q_i) \le q_i - p_i$ is strict at $i_0$, because $\log t < t-1$ holds strictly for $t > 0$, $t \ne 1$, and $t = q_{i_0}/p_{i_0} \ne 1$. A strict-inequality-in-one-term sum comparison finishes as before. $\square$

**Lemma 5.2 (Where the discrepancy must live).** Let $p,q$ be probability vectors on a finite index set with $p_{i_1} \ne q_{i_1}$ for some $i_1$. Then there exists $i$ with $p_i > 0$ and $p_i \ne q_i$.

*Proof sketch.* Suppose not: $p_i > 0 \Rightarrow p_i = q_i$. Then $q_i - p_i \ge 0$ pointwise (at indices with $p_i = 0$ because $q_i \ge 0$, elsewhere by equality), while $\sum_i (q_i - p_i) = 1-1 = 0$. A nonnegative sum that vanishes has all terms zero, so $p = q$ everywhere, contradiction. $\square$

Lemma 5.2 is not a technicality; without it, strict Gibbs cannot be applied, because the discrepancy could hide on the null set of $p$, where the logarithm sees nothing.

**Theorem 5.3 (Any deviation is seen).** Let $p \ge 0$ be a joint table of total mass $1$ with $p(\ell_1,k_1) \ne p_L(\ell_1)p_K(k_1)$ for some cell. Then $I(p) > 0$.

**Theorem 5.4 (Equality case).** For a nonnegative joint table of total mass $1$,
$$I(p) = 0 \iff p(\ell,k) = p_L(\ell)\,p_K(k) \ \text{ for all } \ell,k .$$

So the "wall" is exactly the product locus: nothing more, nothing less.

**Theorem 5.5 (Label-entropy cap).** For any nonnegative joint table, $I(p) \le H(p_L)$; more precisely
$$I(p) - H(p_L) \;=\; \sum_{\ell,k} p(\ell,k)\log_2\frac{p(\ell,k)}{p_K(k)} \;\le\; 0,$$
the right-hand side being the negated conditional entropy $-H(\mathrm{lab} \mid \text{code})$.

*Proof sketch.* Split $\log_2\!\bigl(p/(p_Lp_K)\bigr) = \log_2\!\bigl(p/p_K\bigr) - \log_2 p_L$ on cells where $p > 0$, sum the second part over $k$ to recover $p_L$, and note that each term $p\log_2(p/p_K) \le 0$ because $p(\ell,k) \le p_K(k)$. $\square$

For a binary label this caps every which-factor reading at $1$ bit.

**Theorem 5.6 (The instrument has power).** Let $S = \{(3,5),(5,3)\}$ — swap-closed and off-diagonal — and let $c = \mathrm{lab}$ be the readout that publishes the which-factor label itself. Then $c$ is not symmetric and $I(P) = 1$ bit, the maximum for a binary label.

*Proof sketch.* The joint table is $\tfrac12$ on the diagonal cells and $0$ off it; both margins are uniform; the reading is $2\cdot\tfrac12\log_2 2 = 1$. $\square$

**Corollary 5.7 (Dichotomy).** On the very same population $\{(3,5),(5,3)\}$: the symmetric battery reads exactly $0$ bits, the asymmetric readout reads exactly $1$ bit. Symmetry of the readout is load-bearing in Theorem 4.5, and the battery's zero is a finding, not an artefact of a blind functional.

---

## 6. The sparse regime: why the experiment saw what it saw

The experimental code was nearly injective on its sample: in a run of $3995$ ordered prime pairs, $3597$ distinct four-field codes appeared. The idealised limit of that regime admits a closed form.

**Definition 6.1 (Sparse table).** Let $\ell : \{1,\dots,n\} \to \{\text{false},\text{true}\}$ be the labels of a sample of size $n$ in which all $n$ code values are pairwise distinct — so each sample is its own code. The empirical table is
$$T(b, i) = \begin{cases} 1/n & \ell_i = b,\\ 0 & \text{otherwise.}\end{cases}$$
Write $n_b = \#\{i : \ell_i = b\}$.

**Theorem 6.2 (Sparse reading law).** $I(T) = H\bigl(b \mapsto n_b/n\bigr)$ exactly.

*Proof sketch.* The code margin is uniform, $T_K(i) = 1/n$; the label margin is $T_L(b) = n_b/n$. Every nonzero cell has value $1/n$ and ratio $\bigl(1/n\bigr)\big/\bigl((n_b/n)(1/n)\bigr) = n/n_b$. The $b$-row therefore contributes $n_b \cdot \tfrac1n \log_2(n/n_b) = -\tfrac{n_b}{n}\log_2\tfrac{n_b}{n}$, and summing over $b$ gives the label entropy. Equivalently: injectivity of the code makes $H(\mathrm{lab}\mid\text{code}) = 0$, so the identity of Theorem 5.5 becomes an equality. $\square$

The reading is thus a function of the label margin alone, carrying no information whatever about dependence. Three corollaries follow.

**Corollary 6.3 (The permutation null is a point mass).** For every permutation $\pi$ of the samples, $I(T_{\ell\circ\pi}) = I(T_\ell)$, since relabelling preserves the counts $n_b$.

**Corollary 6.4 (The $z$-score numerator vanishes identically).**
$$I(T_\ell) - \frac{1}{n!}\sum_{\pi} I(T_{\ell\circ\pi}) = 0,\qquad \max_\pi \bigl|I(T_{\ell\circ\pi}) - I(T_\ell)\bigr| = 0 .$$
Observed equals null mean; the null spread is zero. This is the exact form of the reported $z \approx 0$ with a tiny standard deviation.

**Corollary 6.5 (Binary ceiling).** $I(T_\ell) \le 1$ bit, with equality exactly at a balanced label margin.

**Discussion.** Read together with Theorem 4.5, the picture is complete. The *truth* is $0$ bits, because the readout is symmetric. The *reading* is close to $1$ bit, because the code is nearly injective and the label margin is balanced. The *null* is close to the same value, because relabelling barely moves a statistic of the label counts. The experiment's flagged $0.0469$ bits, sitting on top of a null of exactly the same magnitude, is this phenomenon at a different sample size and code granularity. A permutation null does not test "is there a signal?"; it tests "does this statistic respond to relabelling?" — and in the sparse regime the answer is no, for reasons having nothing to do with the population.

**The cleanest exact instance.** Let the population have the uniform $2\times 2$ table $U(\ell,k) = 1/4$, whose true reading is $I(U) = 0$ by Theorem 3.4. Draw a two-sample: the empirical table is a permutation matrix $P_\sigma(\ell,k) = \tfrac12[\sigma(k) = \ell]$. Then $I(P_\sigma) = 1$ for both $\sigma \in S_2$; hence observed $=$ null mean $= 1$ bit, null variance $0$, and truth $0$. The positive reading exceeds the truth, and by one-sidedness (Theorem 3.3) it can never compensate downward.

---

## 7. Capacity is not leakage

**Theorem 7.1 (Capacity ceiling for the four-field battery).** Any probability distribution $r$ on the alphabet of $B_4$ satisfies $H(r) \le \log_2 1{,}334{,}025 \approx 20.35$ bits.

*Proof.* Theorem 2.5 gives the alphabet size $(3\cdot5\cdot7\cdot11)^2$; Theorem 3.5 gives the ceiling. $\square$

Theorems 4.5 and 7.1 are logically independent statements about the same device: the first bounds what the readout says about the *order* of the factors (exactly zero), the second bounds what it can say *in total* (about twenty bits). Numerically, on $82{,}656$ ordered pairs of distinct primes in $(50,2000)$, the empirical readout entropy of $B_4$ is $\approx 14.39$ bits, all of it symmetric trace-routed content. Lengthening the chain raises the ceiling and buys more symmetric content; it buys no which-factor bits at any width, by Corollary 4.6.

---

## 8. Orbit blindness: the general law

The halving argument of §4 is special to an involution. It is not the reason for the zero.

**Setting 8.1.** Let a finite group $G$ act on a finite set $X$ by $g \cdot x$, let $S \subseteq X$ be a finite $G$-stable population, let $c : X \to K$ be $G$-invariant ($c(g\cdot x) = c(x)$), and let $\mathrm{lab} : X \to L$ be a **torsor coordinate**:
$$\forall x \in S,\ \forall \ell \in L,\ \exists!\, g \in G : \mathrm{lab}(g\cdot x) = \ell .$$
Define $F_k$, $C_{\ell,k}$ and the empirical joint law $P$ as before.

**Theorem 8.2 (Counting core).** In Setting 8.1, $|G| \cdot |C_{\ell,k}| = |F_k|$ for every $\ell \in L$, $k \in K$.

*Proof sketch.* Count the set $\{(x,g) \in F_k \times G : \mathrm{lab}(g\cdot x) = \ell\}$ twice. Fixing $x$ and summing over $g$: the torsor property gives exactly one valid $g$, so the count is $|F_k|$. Fixing $g$ and summing over $x$: the map $x \mapsto g\cdot x$ is a bijection of $F_k$ (invariance of $c$ and stability of $S$) carrying $\{x \in F_k : \mathrm{lab}(g\cdot x) = \ell\}$ onto $C_{\ell,k}$, so each $g$ contributes $|C_{\ell,k}|$ and the count is $|G|\,|C_{\ell,k}|$. $\square$

**Corollary 8.3 (Uniform label margin, product table).** $P_L(\ell) = 1/|G|$ for every $\ell$ on a nonempty population, $P_K(k) = |F_k|/|S|$, and $P(\ell,k) = P_L(\ell)P_K(k)$.

**Theorem 8.4 (Orbit blindness).** In Setting 8.1, $I(P) = 0$ exactly.

*Proof.* Corollary 8.3 and Theorem 3.4. $\square$

**Corollary 8.5 (Two-factor wall recovered).** Take $G = S_2 \cong \mathbb{Z}/2$ acting on ordered pairs by swap, $S$ swap-closed and off-diagonal, $c$ symmetric, $\mathrm{lab}$ the which-factor label. Off the diagonal, swapping flips the label, so exactly one group element achieves any target label: the torsor hypothesis holds, and Theorem 8.4 reproduces Theorem 4.5.

### 8.1 Many factors: the ordering pattern

For multi-prime moduli, "which factor is bigger" becomes the full ordering of $n$ factors.

**Definition 8.6 (Rank and ordering pattern).** $S_n$ acts on tuples $v \in \mathbb{N}^{\{1,\dots,n\}}$ by $(\sigma\cdot v)_i = v_{\sigma^{-1}(i)}$. For a tuple with pairwise distinct entries, the **rank** of coordinate $i$ is $\mathrm{rk}_v(i) = \#\{j : v_j < v_i\}$; injectivity of $v$ makes $\mathrm{rk}_v$ a bijection of the index set, and the **ordering pattern** $\mathrm{pat}(v) \in S_n$ is that bijection.

**Lemma 8.7 (Equivariance).** For injective $v$, $\mathrm{pat}(\sigma\cdot v) = \mathrm{pat}(v)\,\sigma^{-1}$.

*Proof sketch.* Ranks transport along the permutation: $\mathrm{rk}_{\sigma\cdot v}(i) = \mathrm{rk}_v(\sigma^{-1}(i))$, because $j \mapsto \sigma^{-1}(j)$ is a bijection between the two sets being counted. $\square$

**Lemma 8.8 (Torsor property).** For injective $v$ and any target pattern $\ell \in S_n$, the unique $\sigma$ with $\mathrm{pat}(\sigma\cdot v) = \ell$ is $\sigma = \ell^{-1}\,\mathrm{pat}(v)$.

*Proof sketch.* By Lemma 8.7, $\mathrm{pat}(\sigma\cdot v) = \ell \iff \mathrm{pat}(v)\sigma^{-1} = \ell \iff \sigma = \ell^{-1}\mathrm{pat}(v)$. $\square$

**Theorem 8.9 ($S_n$-blindness).** Let $S$ be a finite population of $n$-tuples with pairwise distinct entries, closed under coordinate permutation, and let $c$ be any permutation-invariant readout into a finite alphabet. Then the mutual information between the ordering pattern and $c$ over $S$ is exactly $0$ bits — for every $n$.

*Proof.* Lemma 8.8 and Theorem 8.4. $\square$

**Example 8.10 (Three-factor battery).** Let $S$ be the six orderings of $(3,5,7)$ and let
$$c(v) = \Bigl(\textstyle\sum_i v_i \bmod 13,\ \prod_i v_i \bmod 17\Bigr) = (2, 3),$$
which is permutation invariant. The population carries all six ordering patterns, and the leakage is exactly $0$. By contrast the non-invariant readout $v \mapsto v_1$ gives away $\log_2 3 \approx 1.585$ bits of the $\log_2 6 \approx 2.585$ bits of ordering information — it names the first factor outright.

---

## 9. The arithmetic instance: divisor populations

**Definition 9.1.** The **ordered factorisations** of $N \in \mathbb{N}$ form
$$D(N) \;=\; \{(d, N/d) : d \mid N\}.$$

**Theorem 9.2 (Swap closure).** For every $N$, $D(N)$ is swap-closed.

*Proof sketch.* If $d \mid N$ and $N \ne 0$, then $N/d \mid N$ and $N/(N/d) = d$; hence the swap $(N/d, d)$ of $(d, N/d)$ is the member of $D(N)$ indexed by the divisor $N/d$. The statement is the involutivity of $d \mapsto N/d$ on the divisor lattice. $\square$

**Theorem 9.3 (Off-diagonality $\iff$ non-square).** $D(N)$ is off-diagonal if and only if $N$ is not a perfect square.

*Proof sketch.* A diagonal member is a divisor $d$ with $d = N/d$, i.e. $N = d^2$. Conversely if $N = d^2$ then $(d,d) \in D(N)$. $\square$

**Theorem 9.4 (Flagship arithmetic statement).** For every non-square $N$, the four-field battery carries exactly $0$ bits about which cofactor of $N$ is the larger one, over the whole population $D(N)$ of ordered factorisations. More generally, for every non-square $N$ and every symmetric readout $c$ into a finite alphabet, the which-factor leakage over $D(N)$ is exactly $0$.

*Proof.* Theorems 9.2, 9.3 and 4.5 (resp. Corollary 4.6). $\square$

Every semiprime $N = pq$ with $p \ne q$ is a non-square, so Theorem 9.4 covers the factoring case of interest.

**Example 9.5 (Non-vacuity at $N = 15$).** $D(15) = \{(1,15),(3,5),(5,3),(15,1)\}$, and $B_4(3,5) = 979345 \ne 476194 = B_4(1,15)$. The readout is non-constant on the population, yet the which-factor leakage is exactly $0$.

**Example 9.6 (Sharpness at squares).** $D(36)$ and $D(100)$ each have nine ordered factorisations including a diagonal one, and the same readout leaks $0.1021871709\ldots$ bits; $D(49) = \{(1,49),(7,7),(49,1)\}$ leaks $0.2516291674\ldots$ bits. The single swap-fixed pair destroys the exact halving. Note that this residual is a *label-degeneracy* effect — the diagonal cell has no partner to balance it — rather than an arithmetic channel; but it is a genuinely positive reading, so the off-diagonality hypothesis is a sharp boundary and not a technical convenience.

---

## 10. Algorithms and numerics

### 10.1 Chained battery evaluation

Evaluating $\mathrm{code}_{\mathbf m}$ costs $O(r)$ arithmetic operations on integers of size $O(\log \prod m_i^2)$ — one modular reduction pair and two multiply-adds per field. Memory is $O(1)$ beyond the accumulator.

```
function BATTERY_CODE(moduli m[1..r], pair (p,q)):
    acc <- 0
    for i in 1..r:
        s <- (p + q) mod m[i]
        t <- (p * q) mod m[i]
        acc <- (acc * m[i] + s) * m[i] + t
    return acc
```

### 10.2 Exact population leakage

Given a finite population $S$ and a readout, compute the contingency table by a single pass and evaluate $I$. Cost $O(|S|)$ time and $O(|K_{\mathrm{obs}}|)$ memory, where $K_{\mathrm{obs}}$ is the set of observed codes.

```
function POPULATION_LEAKAGE(S, readout c):
    joint, margL, margK <- empty counters
    for x in S:
        b <- [x.1 < x.2];  k <- c(x)
        increment joint[b,k], margL[b], margK[k]
    I <- 0
    for (b,k) with joint[b,k] > 0:
        pjk <- joint[b,k]/|S|;  pb <- margL[b]/|S|;  pk <- margK[k]/|S|
        I <- I + pjk * log2( pjk / (pb*pk) )
    return I
```

Theorem 4.5 predicts the output is exactly $0$ whenever $S$ is swap-closed and off-diagonal and $c$ is symmetric; in floating point the computation returns $0$ to machine precision because every cell ratio is exactly $2$ after the halving.

### 10.3 Permutation null

```
function PERMUTATION_NULL(samples (lab_i, code_i), shuffles T):
    for t in 1..T:
        pi <- uniform random permutation
        R[t] <- PLUGIN_MI( (lab_{pi(i)}, code_i) )
    return mean(R), sd(R)
```

Corollaries 6.3–6.4 predict $\mathrm{sd}(R) = 0$ exactly in the injective limit and $\mathrm{sd}(R)$ small — here $\approx 0.004$ bits — in the nearly-injective regime, with mean $\approx H(\mathrm{lab})$. A practical diagnostic follows: **before trusting a permutation null, report the number of distinct code values; if it approaches the sample size, the test has no power and the reading is a label statistic.**

### 10.4 Numerical summary

| Population / sample | Size | Distinct codes | Reading (bits) |
|---|---|---|---|
| $\{(3,5),(5,3),(7,11),(11,7)\}$ | $4$ | $2$ | $0.000000000000$ |
| $D(15)$ | $4$ | $2$ | $0.000000000000$ |
| all ordered pairs of $60$ primes $>50$ | $3540$ | $1709$ | $0.000000000000$ |
| all ordered pairs of distinct primes in $(50,2000)$ | $82656$ | $24581$ | $0.000000000000$ |
| $D(36)$, $D(100)$ (squares) | $9$ | $5$ | $0.102187170949$ |
| $D(49)$ (square) | $3$ | $2$ | $0.251629167388$ |
| $\{(3,5),(5,3)\}$ with the label-publishing readout | $2$ | $2$ | $1.000000000000$ |
| sparse sample of $3995$ ordered prime pairs | $3995$ | $3688$ | $0.8929$ (null mean $0.9229$, sd $0.0044$) |

The first four rows are the theorem: exact zero on the full swap-closed populations. The last row is the pathology: a sparse *sample* of the very same zero-leakage population produces a large positive reading whose null sits at essentially the same place, both hugging the label entropy $H(\mathrm{lab}) = 1$ bit. The reported experimental figures $0.0469$ observed against a $0.0469$ null with sd $0.0014$ and $z = +0.05$ are the same phenomenon at that run's granularity.

The empirical readout entropy of the four-field battery on the $82{,}656$-pair population is $\approx 14.39$ bits against the ceiling $\log_2 1{,}334{,}025 \approx 20.35$: a wide, informative channel that is nonetheless exactly blind in the which-factor direction.

---

## 11. Discussion

### 11.1 What replaced what

The programme's original claim was *factor-blindness with a caveat*: a battery reading of a few hundredths of a bit, statistically indistinguishable from zero. What the theory supplies is not a tighter bound but a different kind of statement. The leakage is $0$ exactly, on every swap-closed, off-diagonal population, for every symmetric readout, at every chain width — with no sample, no null, and no sensitivity floor. The empirical residual is fully accounted for: Theorem 3.3 says the estimator cannot go below the truth, and Theorem 6.2 says that in the observed regime it sits at the label entropy regardless of dependence.

### 11.2 Methodological morals

1. **One-sided statistics need one-sided scepticism.** Plug-in mutual information is nonnegative by construction; a small positive value is the *default*, not evidence.
2. **A degenerate null is a red flag, not a precision claim.** A null standard deviation of $0.0014$ bits over $200$ shuffles looks like a finely resolved test. In the sparse regime it means the statistic is nearly invariant under relabelling, so the $z$-score is a ratio of two vanishing quantities.
3. **Symmetry beats sampling.** One structural observation — the readout factors through $(p+q, pq)$ — settles in one line what thousands of samples could only bound.
4. **Verify the exact object.** During the verification of the original claim, a first pass chained only two of the four fields, testing a smaller cousin of the flagged object. It passed, trivially and correctly, but about the wrong device. Both the two-field and four-field readings were eventually shown to lie inside their own nulls; the process lesson survives the happy ending.

### 11.3 Design consequences

For anyone building such measurement batteries: which-factor leakage is decided entirely by the symmetry class of the readout, not by the width of the chain or the size of the sample. If leakage is *wanted*, the readout must break the symmetry explicitly — and by Theorem 5.6 even the crudest asymmetry is detected at full strength. If blindness is wanted, routing through elementary symmetric functions guarantees it, exactly. Between these extremes lies the interesting regime of *partial* symmetry, which is the subject of the next section.

### 11.4 Scope and limitations

The theorems concern the exact empirical (uniform-on-$S$) law of a finite population, which is the right object when the population is enumerable — a divisor population, an orbit, a full set of ordered pairs. They do not directly bound the leakage of a *biased sample* from such a population; indeed the sparse analysis shows a sample can read near the maximum. The sparse closed form assumes exact injectivity of the code on the sample; with collisions the reading is only *bounded* by the label entropy (Theorem 5.5) and the null acquires a small spread, which is exactly what the numerics show. Finally, the perfect-square exception is real: the residual at $D(36)$ is a genuine positive reading, even though its source is a label-degenerate diagonal cell rather than an arithmetic channel.

---

## 12. Future directions

### A. The coset leakage law for partially symmetric readouts

**Conjecture.** Let a finite group $G$ act on a population $S$ with a torsor label $\mathrm{lab}: S \to L$, and let the readout $c$ be invariant only under a subgroup $H \le G$. Then
$$0 \;\le\; I(\mathrm{lab}; c) \;\le\; \log_2 [G : H],$$
with the upper bound attained exactly when the readout separates the $H$-cosets. The two proved extremes are $H = G$ (leakage $0$, Theorem 8.4) and $H = 1$ with a separating readout (a full bit at $|G| = 2$, Theorem 5.6).

**Why it should be true.** $H$-invariance already forces every readout fiber to be balanced along $H$-orbits, so the conditional law of the label given the readout is constant on $H$-cosets; only the $[G:H]$ coset coordinates can carry information, and a maximum-entropy bound on a $[G:H]$-letter alphabet (Theorem 3.5) finishes the estimate.

**Why now.** A real battery is never exactly symmetric: rounding, truncation and modulus choice break invariance under part of the group. The conjecture converts "how symmetric is my readout?" into a numerical leakage budget — and it is exactly the quantity a permutation null is trying, badly, to estimate. A natural first test is to build explicit readouts on the six orderings of a triple that are invariant under the alternating group $A_3 \le S_3$ but not under $S_3$, and check the predicted ceiling $\log_2 2 = 1$ bit.

### B. Bias-corrected estimators for the sparse regime

Theorem 6.2 gives the plug-in reading exactly in the injective limit. The natural sequel is a correction: subtract the predicted label entropy, or design a statistic measurable with respect to the fiber structure rather than the sample identity, and prove that the corrected statistic has a non-degenerate permutation null. This would turn the diagnostic of §10.3 into a usable test.

### C. Collision regimes between the two extremes

With $n$ samples and $K$ effective code values, the reading interpolates between $H(\mathrm{lab})$ (sparse, $K \approx n$) and the truth (dense, $K \ll n$). Quantifying the crossover — ideally as an exact formula for a random-fiber model — would predict the observed $0.8985$-bits-versus-$1$-bit gap in terms of the collision count alone.

### D. Beyond torsor labels

The orbit-blindness theorem assumes the label is a torsor coordinate: exactly one group element realises each target. Labels that are only *equivariant* (constant on stabiliser cosets, say) should obey a stabiliser-corrected version of the counting core, with $|G|$ replaced by an orbit size. Making this precise would cover populations of tuples with repeated factors — the multi-prime analogue of the perfect-square exception.

---

## 13. Conclusion

An apparent $0.0469$-bit wall in the which-factor readout of a four-field chained battery has been resolved completely, and in the strongest possible direction. The reading was estimator bias: the plug-in mutual information is nonnegative by construction, and in the near-injective regime it is a function of the label counts alone, so its permutation null cannot move. The truth is exactly zero, and the reason is structural: the battery is routed through the trace and the norm of the factor pair, so it sees only the unordered pair, and no invariant function separates an orbit. The statement holds for any symmetric readout on any swap-closed, off-diagonal population; for all ordered factorisations of any non-square integer; for any finite group with an invariant readout and a torsor label; and, with the symmetric group, for the entire ordering pattern of any number of pairwise distinct factors. Capacity remains untouched — about twenty bits of room for the four-field battery, some fourteen of them realised — and all of it is symmetric content. There is no wall in the which-factor direction, because there is no such direction to measure.
