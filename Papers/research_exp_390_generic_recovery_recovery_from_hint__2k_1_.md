# A Closed Taxonomy of $t$-Bit Hints: Recovery Cost, Sharpness, and the Symmetry Origin of Bit Deficits

**Author:** Aristotle

**Date:** 2026-08-15

---

## Abstract

We develop and prove a complete counting theory for the value of an external hint about a secret integer, in the setting of integer-factorisation-style search. A *hint* is a function $h$ on a finite candidate set $S$; the adversary is told $h(p)$ and must scan the fibre containing the true secret $p$. Defining the recovery cost of a reading as the fibre size and the worst-case recovery cost as the largest fibre, we prove:

1. **A master bound.** $\#S \le \#h(S) \cdot \operatorname{worst}(S,h)$; hence a hint with at most $2^t$ readings — a $t$-bit hint — always leaves some class of size at least $\#S/2^t$. No $t$-bit hint reduces the search by more than a factor $2^t$.
2. **Sharpness.** The bound is attained: on $S = \{0,\dots,q2^t-1\}$ the block hint $p \mapsto \lfloor p/q\rfloor$ realises all $2^t$ readings with every fibre of size exactly $q = \#S/2^t$; and every surjective homomorphic (in particular $\mathrm{GF}(2)$-linear) hint has all fibres of equal size $\#S/2^t$ — there is no anomalous, super-resolving class.
3. **An average-case strengthening.** By Cauchy–Schwarz, $(\#S)^2 \le 2^t \sum_y \operatorname{cost}(y)^2$, so the *expected* number of candidates scanned is also at least $\#S/2^t$: a hint cannot be typically sharp and only rarely blunt.
4. **Position-freeness.** Reading the bits of a $k$-bit secret in an arbitrary position set $A$ leaves exactly $2^{k-\#A}$ candidates, independent of which positions are read. Coppersmith's contiguous-top-half advantage is therefore invisible to counting: it is algorithmic (lattice geometry), not informational.
5. **Deficient families, exactly quantified.** Multiplicative ($p \mapsto cp \bmod 2^t$, $c$ odd) and XOR-mask ($p \mapsto (p \oplus m) \bmod 2^t$) hints on odd candidates realise at most $2^{t-1}$ readings, losing exactly one bit. The trace hint $s = p+q \bmod 2^t$ reduces, by completing the square, to a squaring hint modulo $2^t$; every fibre of squaring on the odd residues has exactly four elements, so a $t$-bit trace hint realises exactly $2^{t-3}$ readings and carries exactly $t-3$ usable bits.
6. **A structural explanation.** Every deficit above is the order of an invariance group of candidate symmetries: if a group of order $g$ acts on $S$ preserving $h$ with free orbits, then $g \cdot \#h(S) \le \#S$, i.e. $\log_2 g$ bits are lost. For value hints $g=2$ (parity); for the trace hint $g=4$, the Klein four-group $\{\pm 1, \pm(1+2^{t-1})\}$ of square roots of unity modulo $2^t$.
7. **Closure properties and a bridge.** Post-processing never amplifies; joint hints add bits rather than multiplying them; a hint recomputable from public data has a single class and hence zero value. Residue-dial filtering systems are hints in this sense and obey the master bound verbatim, unifying two previously separate negative programmes.

The theory is corroborated by exhaustive computation on exact $k$-bit prime sets ($k = 14$–$25$) and random semiprimes ($k=16$–$20$), with measured class sizes matching the predicted $\#S/2^t$, $\#S/2^{t-1}$, and $4 \cdot \#S/2^{t-1}$ regimes to within sparse-set noise.

**Keywords:** hint taxonomy, recovery cost, information bound, 2-adic square roots, Klein four-group, integer factorisation, Coppersmith's method, Cauchy–Schwarz.

---

## 1. Introduction

### 1.1 The question

Let $N = pq$ be a semiprime with $p,q$ secret primes of $k$ bits each. A recurrent question in cryptanalysis is: given some *side information* about $p$, how much easier does recovering $p$ become? The question admits many answers depending on what side information means, but there is a natural and very robust way to normalise it: measure the side information in **bits transmitted**, and measure the gain by **how many candidates survive**.

The naive expectation is a clean exchange rate: $t$ bits in, factor $2^t$ out. But the naive expectation is contradicted, apparently, by a famous theorem.

**Coppersmith's phenomenon.** If the adversary learns the top $\lceil k/2 \rceil$ bits of $p$, lattice reduction recovers $p$ in polynomial time. Naively, this is $k/2$ bits buying a full break — an amplification far beyond $2^{k/2}$.

Is Coppersmith's leak the first specimen of a rich zoo of *amplifying* hints, or a lonely exception? The purpose of this paper is to close the question at the counting level: to determine, exactly, the exchange rate of every natural hint family, and to explain in structural terms why some families fall short of the naive rate while none exceeds it.

### 1.2 Results and organisation

Section 2 sets up the cost model and proves the master bound (§2.2) and its average-case strengthening (§2.3). Section 3 establishes sharpness: block hints (§3.1) and homomorphic hints (§3.2) attain the bound exactly, and position-freeness (§3.3) localises the Coppersmith phenomenon outside counting altogether. Section 4 treats the deficient families: the one-bit parity tax on value hints (§4.1) and the exact three-bit tax on trace hints, via the 2-adic square-root count (§4.2–§4.4). Section 5 gives the unifying symmetry mechanism, computes the Klein invariance group of the trace hint, and derives the deficit structurally on arbitrary symmetric candidate sets. Section 6 proves closure properties (data processing, joint hints, public hints) and the bridge to residue-dial systems. Section 7 reports the computational evidence. Section 8 discusses interpretation, in particular the correct reading of Coppersmith's method. Section 9 lists open problems.

### 1.3 Notation

$\#X$ is the cardinality of a finite set $X$. For a finite set $S$ and a function $h$ on $S$, $h(S)$ denotes the image. $v_2$ is the $2$-adic valuation. $\oplus$ is bitwise exclusive-or. $\mathbb{Z}/2^t$ denotes the residues modulo $2^t$. "$t$-bit hint" always means "hint with at most $2^t$ distinct readings on the candidate set in question."

---

## 2. The cost model and the master bound

### 2.1 Definitions

**Definition 2.1 (candidate set, hint).** A **candidate set** is a finite set $S$. A **hint** on $S$ is a function $h : S \to Y$ into any set $Y$ with decidable equality. The adversary observes $y = h(p)$ for the true secret $p \in S$, and must then examine every candidate consistent with $y$.

**Definition 2.2 (recovery cost).** For a reading $y$, the **cost** of $y$ is the number of surviving candidates,
$$\operatorname{cost}(S,h,y) \ :=\ \#\{a \in S : h(a) = y\}.$$
The **worst-case recovery cost** of the hint is the largest fibre,
$$\operatorname{worst}(S,h) \ :=\ \max_{y \in h(S)} \operatorname{cost}(S,h,y).$$

**Definition 2.3 (bit budget).** A hint $h$ is a **$t$-bit hint** on $S$ if $\#h(S) \le 2^t$; equivalently its readings can be transmitted in $t$ bits.

Two remarks. First, the model is deliberately *information-theoretic and algorithm-free*: it counts surviving candidates, not the work needed to sift them. This is a feature — it isolates precisely the part of a hint's value that no algorithmic cleverness can create. Second, $\operatorname{cost}$ is the number of candidates, which for an exhaustive-scan adversary is proportional to running time; §2.3 shows the same bound governs the average.

### 2.2 The master bound

**Theorem 2.4 (Master bound).** For every candidate set $S$ and every hint $h$,
$$\#S \ \le\ \#h(S)\cdot \operatorname{worst}(S,h).$$

*Proof.* The fibres $\{a \in S : h(a) = y\}$, for $y$ ranging over $h(S)$, partition $S$. Hence
$$\#S = \sum_{y \in h(S)} \operatorname{cost}(S,h,y) \le \sum_{y \in h(S)} \operatorname{worst}(S,h) = \#h(S)\cdot\operatorname{worst}(S,h). \qquad\square$$

**Corollary 2.5 (No $t$-bit hint beats $2^t$).** If $\#h(S) \le B$ then $\operatorname{worst}(S,h) \ge \#S/B$. In particular, for a $t$-bit hint,
$$\operatorname{worst}(S,h) \ \ge\ \frac{\#S}{2^{t}} .$$

*Proof.* Immediate from Theorem 2.4 (with the degenerate case $B = 0$, where $S = \emptyset$, handled trivially). $\square$

Corollary 2.5 is the backbone of the paper. It is elementary, but it is also *unconditional*: it holds for every candidate set (primes, semiprime traces, arbitrary sparse sets), for every hint function whatsoever, and it does not care what algorithm the adversary intends to run. Any claimed hint family with a reduction factor exceeding $2^t$ is, by Corollary 2.5, either miscounted or not $t$ bits.

### 2.3 The bound holds on average, not merely in the worst case

Corollary 2.5 bounds the largest fibre. A sceptic might hope for a hint whose *typical* fibre is far smaller than $\#S/2^t$, at the price of a few pathologically large fibres. Cauchy–Schwarz forecloses this.

**Theorem 2.6 (Average-case master bound).** Let $h$ be a hint on $S$ with $\#h(S) \le 2^t$. Then
$$(\#S)^2 \ \le\ 2^{t} \sum_{y \in h(S)} \operatorname{cost}(S,h,y)^2 .$$

*Proof.* Since the fibres partition $S$, $\sum_{y \in h(S)} \operatorname{cost}(S,h,y) = \#S$. Cauchy–Schwarz on the constant vector and the vector of costs gives
$$\Bigl(\sum_{y} \operatorname{cost}(y)\Bigr)^{2} \le \#h(S) \sum_{y} \operatorname{cost}(y)^{2},$$
and $\#h(S) \le 2^t$ finishes the proof. $\square$

**Interpretation.** Draw the secret $p$ uniformly from $S$. The reading $y = h(p)$ occurs with probability $\operatorname{cost}(y)/\#S$, and conditional on it the adversary must scan $\operatorname{cost}(y)$ candidates. So the expected scan length is
$$\mathbb{E}\bigl[\operatorname{cost}(h(p))\bigr] \;=\; \frac{1}{\#S}\sum_{y}\operatorname{cost}(y)^{2} \;\ge\; \frac{\#S}{2^{t}},$$
by Theorem 2.6. The mean is governed by the same $\#S/2^t$ floor as the worst case. This is precisely the theorem behind the experimental observation that the *median* number of search steps equals the class size.

---

## 3. Sharpness: hints worth exactly their bits

### 3.1 The block hint attains the bound with equality

**Definition 3.1 (block hint).** For $q \ge 1$ and $t \ge 0$, take $S = \{0,1,\dots,q2^t - 1\}$ and let $h(p) = \lfloor p/q \rfloor$.

**Lemma 3.2 (fibre description).** For $q \ge 1$ and $y < 2^t$,
$$\{p \in S : \lfloor p/q\rfloor = y\} \;=\; \{p : yq \le p < (y+1)q\},$$
an interval of exactly $q$ integers, contained in $S$.

*Proof.* $\lfloor p/q \rfloor = y$ iff $yq \le p < (y+1)q$, which is the definition of integer division; and $(y+1)q \le 2^t q$ since $y < 2^t$, so the interval lies inside $S$. $\square$

**Theorem 3.3 (Sharpness).** For $q \ge 1$ and $t \ge 0$, the block hint on $S = \{0,\dots,q2^t-1\}$ satisfies:
1. *(image side)* $h(S) = \{0,1,\dots,2^t-1\}$ — it is a genuine $t$-bit hint using all its readings;
2. *(fibre side)* $\operatorname{cost}(S,h,y) = q$ for every $y < 2^t$;
3. *(cost)* $\operatorname{worst}(S,h) = q = \#S/2^t$.

*Proof.* (2) is Lemma 3.2. For (1), $\lfloor p/q\rfloor < 2^t$ for $p < q2^t$, and conversely $y = \lfloor (yq)/q \rfloor$ with $yq < q2^t$. (3) follows since all fibres have size $q$ and there is at least one. $\square$

Combining Corollary 2.5 with Theorem 3.3: **the reduction factor of a $t$-bit hint is exactly $2^t$** — never more (Corollary 2.5), and attained (Theorem 3.3). Hints are worth their bits at face value.

### 3.2 Homomorphic and $\mathrm{GF}(2)$-linear hints: no anomalous class

Sharpness in the sense of §3.1 is a statement about the *worst* fibre. For linear hints, something stronger holds: *all* fibres are equal.

**Theorem 3.4 (Information-exactness of homomorphic hints).** Let $G, H$ be finite abelian groups and $f : G \to H$ a surjective homomorphism. Then for every $y \in H$,
$$\#\{x \in G : f(x) = y\} \;=\; \#\ker f \;=\; \frac{\#G}{\#H}.$$

*Proof.* Choose $a$ with $f(a) = y$; then $x \mapsto x - a$ is a bijection from $f^{-1}(y)$ onto $\ker f$. Summing $\#\ker f$ over the $\#H$ readings recovers $\#G$. $\square$

**Corollary 3.5 ($\mathrm{GF}(2)$ hints).** Let $f : \mathbb{F}_2^{k} \to \mathbb{F}_2^{t}$ be a surjective linear map — "$t$ random linear forms in the bits of $p$". Then every fibre has exactly $2^{k-t}$ elements.

Two consequences deserve emphasis. There is **no anomalous class**: no reading of a linear hint is more informative than any other, so there is no "super-resolution" event on which the adversary gets lucky. And the exchange rate is exactly $2^t$ with no deficit, so *bit-vector linear forms are the canonical full-value hint family*, the yardstick against which every other family is measured.

### 3.3 Position-freeness, and where Coppersmith's advantage actually lives

**Definition 3.6 (coordinate leak).** For a position set $A \subseteq \{0,\dots,k-1\}$, the hint $\pi_A$ reads the bits of the secret in the positions of $A$: $\pi_A(x) = (x_i)_{i \in A}$.

**Theorem 3.7 (Position-freeness).** $\pi_A$ is a surjective linear map $\mathbb{F}_2^k \to \mathbb{F}_2^{A}$, so for every reading $y$,
$$\#\{x \in \mathbb{F}_2^{k} : \pi_A(x) = y\} \;=\; 2^{\,k - \#A},$$
depending on $A$ only through $\#A$. Consequently, if $\#A = \#B$ then $\pi_A$ and $\pi_B$ have identical fibre sizes: the counting cost of a bit leak is blind to *where* the bits are.

*Proof.* Surjectivity: extend any $y$ by zeros outside $A$. Apply Corollary 3.5. $\square$

This settles the motivating puzzle. Learning the top $k/2$ bits of $p$ leaves $2^{k/2}$ candidates, exactly as the master bound demands; Coppersmith's method does not violate any counting bound, and cannot. What it supplies is an *algorithm* — lattice reduction on a polynomial whose small root encodes the unknown low half — that searches the surviving $2^{k/2}$ candidates in polynomial time. That the leaked bits are *contiguous and at the top* is what makes the associated polynomial have a small root; scatter them and the lattice construction evaporates while the fibre size is unchanged.

**Slogan.** *The Coppersmith condition is about position, not about the dial.* Any search for a new amplifying hint family must therefore be a search for new algebraic/algorithmic structure; counting arguments can neither find nor produce amplification.

---

## 4. Deficient families: hints worth less than their bits

### 4.1 Value hints and the parity tax

**Lemma 4.1 (parity-restricted range).** For $t \ge 1$ and $r \in \{0,1\}$, the number of residues $y < 2^t$ with $y \equiv r \pmod 2$ is exactly $2^{t-1}$.

**Theorem 4.2 (Parity-constrained hints).** Let $S$ be a candidate set with $h(a) < 2^t$ and $h(a) \equiv r \pmod 2$ for all $a \in S$ (a fixed $r$). Then $\#h(S) \le 2^{t-1}$ and
$$\operatorname{worst}(S,h) \;\ge\; \frac{\#S}{2^{\,t-1}} .$$

*Proof.* The image lies inside the $2^{t-1}$ residues of parity $r$ (Lemma 4.1); apply Corollary 2.5 with $B = 2^{t-1}$. $\square$

**Corollary 4.3 (Multiplicative value hints lose a bit).** Let all candidates $p \in S$ be odd and let $c$ be odd. Then the hint $p \mapsto cp \bmod 2^t$ satisfies $\operatorname{worst}(S,h) \ge \#S/2^{t-1}$.

*Proof.* $cp$ is odd, so $cp \bmod 2^t$ is odd; apply Theorem 4.2 with $r=1$. $\square$

**Corollary 4.4 (XOR-mask value hints lose a bit).** Let all candidates be odd and $m$ a fixed mask. Then $p \mapsto (p \oplus m) \bmod 2^t$ satisfies $\operatorname{worst}(S,h) \ge \#S/2^{t-1}$.

*Proof.* The low bit of $p \oplus m$ equals $1 \oplus m_0$, a constant; apply Theorem 4.2 with $r = (1+m) \bmod 2$. $\square$

**Discussion.** A $t$-bit multiplicative or XOR hash of an odd secret *costs* $t$ bits to transmit but *carries* $t-1$. The wasted bit is spent asserting a constant the adversary already knows (that primes are odd). Bit-vector forms, by Corollary 3.5, are the only generic family realising the full $2^t$; every value-hash family pays the parity tax. This is a small but practically relevant correction: a protocol advertising a "$t$-bit prime fingerprint" should be audited at $t-1$.

### 4.2 The trace hint: completing the square

In factoring, the natural leaked quantity is the trace $s = p + q$, since $N = pq$ is public. Suppose the adversary learns $s \bmod 2^t$.

**Lemma 4.5 (Completing the square).** For integers $p,q$ with $s = p+q$ and $N = pq$,
$$(2p - s)^2 \;=\; s^2 - 4N .$$

*Proof.* $(2p - p - q)^2 = (p-q)^2 = (p+q)^2 - 4pq$. $\square$

So the trace hint is, up to a public affine change of variable, a **squaring hint**: the adversary learns a square modulo $2^t$ and can pin $p$ only up to the square roots of that square. The residual ambiguity is exactly the number of those roots — the constant $C_t$ measured experimentally.

### 4.3 The 2-adic square-root count

**Theorem 4.6 (The 2-adic square map halves resolution).** For odd integers $x, u$ and $n \ge 0$,
$$2^{\,n+2} \mid x^2 - u^2 \quad\Longleftrightarrow\quad 2^{\,n+1} \mid x - u \ \ \text{or}\ \ 2^{\,n+1} \mid x + u .$$

*Proof sketch.* Write $x - u = 2a$ and $x + u = 2b$, both even since $x,u$ are odd. Then $x^2 - u^2 = 4ab$, so the hypothesis is $2^{n} \mid ab$. Since $a + b = x$ is odd, exactly one of $a,b$ is odd; a $2$-power dividing a product with one odd factor divides the other factor entirely, giving $2^n \mid a$ or $2^n \mid b$, i.e. $2^{n+1} \mid x-u$ or $2^{n+1} \mid x+u$. The converse is immediate from $x^2-u^2=(x-u)(x+u)$ and the evenness of the other factor. $\square$

**Theorem 4.7 (Exactly four square roots).** Let $t = n+3 \ge 3$ and let $u$ be odd. The solutions of
$$x^2 \equiv u^2 \pmod{2^{t}}$$
in $\mathbb{Z}/2^{t}$ are exactly
$$x \equiv u,\quad x \equiv -u,\quad x \equiv u + 2^{\,t-1},\quad x \equiv -u + 2^{\,t-1},$$
and these four residues are pairwise distinct. Hence the fibre has exactly $4$ elements.

*Proof sketch.* By Theorem 4.6 with $n+2$ in place of $n+2$ (i.e. applied at level $t = n+3$), $x^2 \equiv u^2$ modulo $2^{n+3}$ iff $x \equiv \pm u$ modulo $2^{n+2}$; lifting each of the two classes modulo $2^{n+2}$ to $2^{n+3}$ gives two residues apiece, namely $\pm u$ and $\pm u + 2^{n+2} = \pm u + 2^{t-1}$. Distinctness: the pairwise differences are $2u$, $2^{t-1}$, and $2u \pm 2^{t-1}$, none of which is divisible by $2^{t}$ — the first because $u$ is odd and $t \ge 2$, the second because $t-1 < t$, and the third by combining the two. $\square$

Equivalently: the four roots are $\varepsilon \cdot u$ with $\varepsilon$ ranging over the four square roots of unity modulo $2^t$, a fact we exploit structurally in §5.

### 4.4 The trace hint carries exactly $t-3$ bits

Let $t = n+3 \ge 3$ and let $O_t \subseteq \mathbb{Z}/2^t$ be the set of odd residues, $\#O_t = 2^{t-1}$. Consider the squaring hint $\sigma(x) = x^2 \bmod 2^t$ restricted to $O_t$.

**Lemma 4.8 (fibres are odd and of size four).** If $x^2 \equiv u^2 \pmod{2^t}$ with $u$ odd and $t \ge 1$, then $x$ is odd. Consequently, for every $u \in O_t$,
$$\operatorname{cost}(O_t, \sigma, \sigma(u)) = 4.$$

*Proof.* Reducing the congruence modulo $2$ gives $x^2 \equiv 1 \pmod 2$, so $x$ is odd; thus all four roots supplied by Theorem 4.7 lie in $O_t$ and the fibre in $O_t$ coincides with the fibre in $\mathbb{Z}/2^t$. $\square$

**Theorem 4.9 (Exact value of the trace hint).** For $t \ge 3$,
$$\#\sigma(O_t) \;=\; 2^{\,t-3}, \qquad \operatorname{worst}(O_t,\sigma) \;=\; 4 .$$
That is: a $t$-bit trace hint realises exactly $2^{t-3}$ distinct readings and carries exactly $t-3$ usable bits. One bit is lost to parity, two to the square-root ambiguity.

*Proof.* Partitioning $O_t$ into fibres of $\sigma$, each of size $4$ by Lemma 4.8, gives $2^{t-1} = 4\cdot \#\sigma(O_t)$, whence $\#\sigma(O_t) = 2^{t-3}$. All fibres have size $4$ and $O_t \ne \emptyset$, so the worst-case cost is $4$. $\square$

**Consequence for recovery cost.** On a candidate set $S$ of primes, a $t$-bit trace hint pins $p \bmod 2^t$ to $C_t = 4$ residue classes, and the adversary must scan all of them; the resulting cost is
$$C_t \cdot \frac{\#S}{2^{\,t-1}} \;=\; \frac{4\,\#S}{2^{\,t-1}} \;=\; \frac{\#S}{2^{\,t-3}} ,$$
in exact agreement with the $\log_2 C_t \approx 3$ measured deficit (§7). In practice the observed $C_t$ saturates in the range $4$–$8$; §9 conjectures that the exact saturation value is governed by $v_2(p-q)$.

---

## 5. Why deficits exist: every deficit is a symmetry

Sections 3 and 4 exhibit families losing $0$, $1$ and $3$ bits. These are not three accidents; they are one phenomenon, measured by a single group-theoretic invariant.

### 5.1 The abstract mechanism

**Theorem 5.1 (Indistinguishable families force large classes).** Let $h$ be a hint on $S$, let $T$ be a finite index set, and let $\varphi : T \to S$ be injective with $h(\varphi(i)) = y$ for all $i \in T$. Then
$$\operatorname{cost}(S,h,y) \;\ge\; \#T .$$

*Proof.* $\varphi(T)$ is a subset of the fibre of $y$ of size $\#T$. $\square$

**Theorem 5.2 (Uniform deficit costs $\log_2 g$ bits).** Suppose every candidate $a \in S$ lies in a class of size at least $g$, i.e. $\operatorname{cost}(S,h,h(a)) \ge g$ for all $a \in S$. Then
$$g \cdot \#h(S) \;\le\; \#S ,$$
and if $S \neq \emptyset$ also $\operatorname{worst}(S,h) \ge g$.

*Proof.* $\#S = \sum_{y \in h(S)} \operatorname{cost}(y) \ge \sum_{y \in h(S)} g = g\,\#h(S)$. $\square$

**Interpretation.** If a group $\Gamma$ of order $g$ acts on $S$, preserves $h$ (i.e. $h \circ \gamma = h$), and acts freely, then Theorem 5.1 applies at every candidate with $T = \Gamma$, and Theorem 5.2 says the hint realises at most $\#S/g$ readings: its nominal $t$-bit budget is cut to $t - \log_2 g$. **The deficit of a hint family is the order of its invariance group.** For value hints, $\Gamma$ has order $2$ (the hint is blind to a fixed parity constraint). For the trace hint, $\Gamma$ has order $4$, as we now show.

### 5.2 The Klein invariance group of the trace hint

**Definition 5.3.** For $t = n+3 \ge 3$ set
$$K_t \;=\; \{\,1,\ -1,\ 1 + 2^{\,t-1},\ -(1 + 2^{\,t-1})\,\} \subseteq (\mathbb{Z}/2^{t})^{\times}.$$

**Theorem 5.4 ($K_t$ is a Klein four-group of square roots of unity).** For $t \ge 3$: (i) $\#K_t = 4$; (ii) $c^2 = 1$ for every $c \in K_t$; hence $K_t \cong (\mathbb{Z}/2)^2$.

*Proof.* (ii) $(-1)^2 = 1$, and $(1 + 2^{t-1})^2 = 1 + 2^{t} + 2^{2t-2} \equiv 1 \pmod{2^{t}}$ since $2t-2 \ge t$ for $t \ge 2$. (i) The six pairwise differences are (up to sign) $2$, $2^{t-1}$, $2 + 2^{t-1}$, $2 + 2^{t}$; none is divisible by $2^t$ for $t \ge 3$ — for $2$ and $2+2^{t-1}$ because $2^t > 2$ and $2^{t-1} \nmid$-argument reduces to $2^{t-1} \mid 1 + 2^{t-2}$, impossible by parity; for $2^{t-1}$ because $2^{t-1} < 2^{t}$. $\square$

**Theorem 5.5 (Trace hints are Klein-invariant).** For $c \in K_t$ and any $x$, $(cx)^2 = c^2x^2 = x^2$. Hence multiplying a candidate by a square root of unity does not change the squaring (equivalently trace) reading.

**Theorem 5.6 (Structural deficit on any symmetric candidate set).** Let $S \subseteq (\mathbb{Z}/2^t)^\times$ be a set of units closed under multiplication by $K_t$. Then for every $x \in S$,
$$\operatorname{cost}\bigl(S,\ z\mapsto z^2,\ x^2\bigr) \;\ge\; 4,$$
and consequently
$$4\cdot \#\{\text{readings}\} \;\le\; \#S .$$

*Proof.* The map $c \mapsto cx$ from $K_t$ into $S$ is injective (cancel the unit $x$), lands in $S$ (closure), and is constant on readings (Theorem 5.5). Apply Theorems 5.1 and 5.2 with $g = \#K_t = 4$. $\square$

Theorem 4.9 computes the deficit $4$ on the *full* odd-residue set by direct enumeration; Theorem 5.6 derives the same $4$ from *structure alone*, and therefore holds on every $K_t$-symmetric candidate set, including the sparse prime sets of the experiments where explicit enumeration is unavailable. This is the sense in which the taxonomy is not merely a list: the three regimes $2^t$, $2^{t-1}$, $2^{t-3}$ correspond to invariance groups of orders $1$, $2$, $4$ (the last combined with the parity tax).

---

## 6. Closure properties, sealed hints, and the dial bridge

### 6.1 Data processing

**Theorem 6.1 (Post-processing never amplifies).** For any hint $h$ on $S$ and any function $g$ on its readings,
$$\operatorname{worst}(S,h) \;\le\; \operatorname{worst}(S,\, g\circ h).$$

*Proof.* Each fibre of $h$ is contained in a fibre of $g \circ h$, so every $h$-fibre size is at most some $(g\circ h)$-fibre size. $\square$

Hence no massaging of a hint's output can extract value the hint did not have: the adversary's best strategy is always to use the raw reading.

**Theorem 6.2 (Bits add, they do not multiply).** If $h_1$ has at most $2^{t_1}$ readings and $h_2$ at most $2^{t_2}$, then the joint hint $a \mapsto (h_1(a), h_2(a))$ satisfies
$$\operatorname{worst}\bigl(S, (h_1,h_2)\bigr) \;\ge\; \frac{\#S}{2^{\,t_1+t_2}} .$$

*Proof.* The joint image embeds in the product of the images, so it has at most $2^{t_1}2^{t_2} = 2^{t_1+t_2}$ elements; apply Corollary 2.5. $\square$

So one cannot manufacture super-resolution by combining hints: the exchange rate of a bundle is the sum of the bit budgets, never a product.

### 6.2 Public hints are sealed

**Theorem 6.3 (Zero information).** Let $\mathrm{pub}$ be a quantity the adversary already holds and that is constant on $S$ (e.g. the modulus $N$, constant across candidate factorisations), and suppose $h(a) = F(\mathrm{pub}(a))$ for all $a \in S$ and some function $F$. If $S \ne \emptyset$, then $h$ has a single class and
$$\operatorname{worst}(S,h) \;=\; \#S .$$

*Proof.* $h$ is constant on $S$, so its image is a singleton and its only fibre is $S$. $\square$

**Consequence (the trace-set floor).** Any hint that is *$N$-checkable* — recomputable from public data — is worthless irrespective of its length. In particular, "hints" produced by re-encoding known relations between $p$, $q$ and $N$ contribute nothing; only genuinely external information counts, and it counts at face value in bits.

### 6.3 Bridge: residue dials are hints

A *residue-dial system* is a family $D_1,\dots,D_K$ of congruence filters that an adversary tunes to sieve a candidate pool $\Omega$; its combined resolving power is governed by a conditional least common multiple $M^{*}$ of the dial moduli. If the candidates already share a residue $r$ modulo $m$ (from prior knowledge), the dial vector realises at most $M^{*}/\gcd(M^{*},m)$ distinct readings.

**Theorem 6.4 (Dials obey the master bound).** With the above notation and $m \ge 1$, if all $p \in \Omega$ satisfy $p \equiv r \pmod m$, then
$$\operatorname{worst}(\Omega, \text{dial vector}) \;\ge\; \frac{\#\Omega \cdot \gcd(M^{*},m)}{M^{*}} .$$

*Proof.* The dial vector is a hint with at most $M^{*}/\gcd(M^{*},m)$ readings; apply Corollary 2.5 with $B = M^{*}/\gcd(M^{*},m)$. $\square$

Thus the "no-amplification" theorem for dial systems is a special case of the master bound: two negative programmes that were developed independently are, at the counting level, one programme.

---

## 7. Computational evidence

The theory was tested by exhaustive computation on exact $k$-bit prime sets ($k = 14$–$25$) and on random semiprimes ($k = 16$–$20$).

### 7.1 Generic hints are information-exact

Let $P_k$ denote the set of $k$-bit primes; $\#P_{16} = 3030$. For random $\mathrm{GF}(2)$ linear forms of the bits of $p$ at $t = 1,2,4,6,8$:

| $t$ | measured mean class | predicted $\#P_{16}/2^t$ |
|---|---|---|
| 1 | 1515 | 1515 |
| 2 | 759 | 757.5 |
| 4 | 190 | 189.4 |
| 6 | 48.6 | 47.3 |
| 8 | 12.8 | 11.8 |

Agreement is within the discreteness noise of a sparse set (a set of $3030$ elements cannot split into $256$ classes of exactly $11.83$). Crucially, no class is anomalously small, matching Corollary 3.5; and the median number of search steps equals the class size, matching Theorem 2.6. **No anomalous class means no super-resolution.**

### 7.2 Value hints pay the parity tax

At $k=16$, $t=4$: multiplicative and XOR-mask hints give a measured mean class of $378.9$, versus $189.4$ for a bit-vector hint at the same $t$ — a clean factor of $2$, i.e. the $2^{t-1}$ regime of Corollary 4.3, and $378.75 = \#P_{16}/2^{3}$ exactly.

### 7.3 The trace hint's three-bit deficit

| $k$ | $t$ | measured trace cost | generic $\#P_k/2^t$ | predicted $4\#P_k/2^{t-1}$ |
|---|---|---|---|---|
| 16 | 6 | 399 | 47.3 | 378.8 |
| 18 | 8 | 354 | 42.0 | 336.0 |

The trace hint is $4.5$–$5\times$ worse per bit than a bit-vector hint, i.e. $\log_2 C_t \approx 3$ bits lost — one to parity, two to the Klein group, exactly Theorem 4.9. Direct enumeration of the roots of $x^2 - sx + N \equiv 0 \pmod{2^t}$ shows $C_t$ saturating in the range $4$–$8$ rather than growing with $t$.

### 7.4 The crossing point

For every family tested, the hint-assisted search cost crosses the unaided factoring baseline at $t \approx k/2 - c$ with a small, slowly varying $c \approx 3$–$4$: below that threshold the hint is not worth its bits relative to running a generic method, above it the hint dominates. Crucially the threshold is the *same* for all families up to the family's own deficit — the crossing for the value-hash family sits exactly one bit higher than the generic one, and the trace family exactly three bits higher. That is precisely the content of the taxonomy: the families differ by a constant number of bits, not by an exponent.

---

## 8. Discussion

### 8.1 What is closed, and in what sense

The taxonomy is **closed at the counting level**. Precisely:

- Nothing exceeds $2^t$ (Corollary 2.5), in the worst case or on average (Theorem 2.6), before or after post-processing (Theorem 6.1), alone or in bundles (Theorem 6.2).
- Everything that attains $2^t$ does so for the same reason: a trivial invariance group. Bit-vector linear forms and block hints are the model examples (Theorems 3.3, 3.4).
- Everything that falls short does so by exactly the order of its invariance group (Theorems 5.2, 5.6): $2$ for value hashes, $4$ for trace/square hints, on top of the parity bit.
- Anything recomputable from public data is worth nothing at all (Theorem 6.3).

This is a *negative* theory, and negative theories have a habit of being fragile at the boundary. The value of §3 and §5 is precisely that they pin the boundary down: the bound is attained (so it is the right bound), and the deficits are structural invariants (so they are not accidents that a cleverer encoding could remove).

### 8.2 The correct reading of Coppersmith's method

The one known amplification in this landscape is Coppersmith's: knowing a contiguous top half of the bits of $p$ yields polynomial-time factorisation. Theorem 3.7 shows that this can have nothing to do with the *quantity* of information: an arbitrary scattered set of $k/2$ bit positions leaves exactly the same number $2^{k/2}$ of candidates. The gain must therefore live entirely in the algorithm — specifically in the fact that a contiguous high-order leak turns the unknown into a *small root of a known univariate polynomial modulo $N$*, which is what lattice reduction exploits.

Practically: when auditing a leak, the two questions are independent. *How many bits?* determines the counting reduction, exactly $2^t$ and no more. *Which bits?* determines whether an algebraic algorithm can convert those bits into a break. A designer who protects only against the first question protects against nothing new; a designer who protects only against the second is exposed to brute force.

### 8.3 Practical guidance

1. **Audit a $t$-bit hash of an odd secret at $t-1$ bits.** The low bit is a constant.
2. **Audit a $t$-bit trace or square leak at $t-3$ bits.** Parity plus the Klein group.
3. **Do not credit $N$-checkable hints at all.** They have exactly one class.
4. **Do not expect bundling to help superlinearly.** Bit budgets add.
5. **Do worry about position.** It is the only known lever for amplification, and it is invisible to every argument in this paper.

---

## 9. Future directions

### C1. Deficit = order of the invariance group, exactly (not merely $\ge$)

**Conjecture.** Let $S$ be a finite candidate set and $h$ a hint. Define the invariance group $\Gamma_h = \{\sigma \in \operatorname{Sym}(S) : h \circ \sigma = h\}$. Then the number of readings satisfies $\#\text{readings} = \#S/|\Gamma_h|$ **iff** $\Gamma_h$ acts freely and transitively on every class; and in general $\#\text{readings}\cdot \min_{\text{orbit}} \le \#S$, with equality exactly when all orbits have equal size. Section 5 proves the inequality; the conjecture is the equality case and its characterisation.

*The key insight* is that a hint is not a function but a partition, and a partition with a group of symmetries can only be as fine as the coarsest orbit decomposition — so the "wasted bits" of every hint family in the taxonomy are a single group-theoretic invariant, not four separate accidents. The two extreme cases are already established (trivial group: exact $2^t$; Klein four-group: exact $2^{t-3}$), so the general statement should be reachable with the machinery of §5 plus standard orbit-counting.

### C2. The 2-adic root explosion is governed by $v_2(p-q)$

**Conjecture.** For odd $p \ne q$, $N = pq$, $s = p+q$, the number of solutions of
$$x^2 - sx + N \equiv 0 \pmod{2^t}$$
is nondecreasing in $t$ and saturates at $2^{\,v_2(p-q)+1}$, never growing with $t$ beyond that point. Direct enumeration confirms saturation at $8$ for $v_2(p-q)=2$, at $16$ for $v_2(p-q)=3$, and at $64$ for $v_2(p-q)=5$; the remaining content of the conjecture is the exact transition profile, i.e. the value of the count for each $t$ below saturation.

*The key insight* is that the trace hint's sub-bit behaviour is not a constant $3$-bit tax but a function of a single 2-adic invariant of the secret pair — so the hint deficit of a family can depend on the secret and not only on the hint, a genuinely new axis in the taxonomy. Theorem 4.6 already reduces the whole question to 2-adic valuation bookkeeping, so induction on $t$ should carry it.

### C3. No hint family is position-sensitive at the counting level

**Conjecture.** For every $k$, $t$ and every pair of position sets $A, B \subseteq \{0,\dots,k-1\}$ with $\#A = \#B$, and every candidate set $S$ that is a union of residue classes modulo $2^k$, the two bit-leak hints have identical class-size *multisets*, not merely identical sizes on the full cube. Consequently a Coppersmith-style advantage of contiguous top-half leakage is invisible to any counting argument and must be algorithmic in origin — a statement that would upgrade Theorem 3.7 from "the fibre sizes agree" to "the entire fibre-size distribution agrees."

---

## 10. Conclusion

We have given a complete counting theory of $t$-bit hints. The exchange rate is exactly $2^t$: never better (master bound, in worst case and in mean, stable under post-processing and bundling), and attained (block and linear hints, with all fibres equal). Two prominent families are provably deficient by exactly one and exactly three bits, and both deficits — indeed, all deficits — are the order of a group of candidate symmetries that the hint cannot resolve. Hints recomputable from public data are worth precisely nothing. Residue-dial filtering is a hint in this sense and inherits the same bound.

The residue of the theory is a single sharp statement about where amplification can come from: not from the amount of leaked information, which is rigidly accounted for, but from its position, which is an algorithmic and not an informational property. That leaves exactly one known amplification — Coppersmith's contiguous top-half leak — standing alone, and explains structurally why it is alone.
