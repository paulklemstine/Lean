# Seed-Compressible Data: Detection, Identification and Exact Seed Recovery for Pseudo-Random Streams

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

A substantial amount of real-world data is not merely *random-looking* but
literally the output of a deterministic pseudo-random generator: procedurally
generated game content, simulation traces, synthetic benchmark corpora,
scrambled transport streams. Such data is statistically incompressible yet has
description complexity equal to that of its seed. We develop the exact
mathematics of exploiting this: detection, identification, and lossless seed
recovery with a bit-exact replay guarantee.

We work with streams over a commutative ring that obey a linear recurrence
$x_{n+L} = \sum_{i<L} c_i x_{n+i}$, the model underlying linear feedback shift
registers, and we prove five groups of results.

1. **Exact replay.** A stream obeying an order-$L$ recurrence is reproduced bit
   for bit by rerunning the register from its own first $L$ symbols; storage of
   $(\text{taps}, \text{seed})$ is lossless.
2. **Sample complexity.** Introducing the $F[X]$-module structure on streams
   induced by the shift operator, we show that a stream obeys a recurrence
   exactly when the recurrence's characteristic polynomial annihilates it; that
   every monic polynomial is realized as such a characteristic polynomial; that
   linear complexity is subadditive; and hence that **two streams of linear
   complexity at most $L$ agreeing on their first $2L$ symbols agree
   identically**. A $2L$-symbol observation window is therefore sufficient, and
   we exhibit witnesses showing it is necessary.
3. **Well-posedness.** Recovery of the taps has a unique answer **if and only
   if** the state windows of the stream span $F^{L}$. Both directions are
   proved; the all-zero stream shows the criterion cannot be dropped.
4. **Family collapse.** Every linear congruential stream $x_{n+1} = a x_n + b$
   satisfies the order-$2$ linear recurrence with taps $(-a, 1+a)$, so one
   detector covers both families. Seeds are recovered exactly by backward
   modular inversion and, on finite state spaces with invertible multiplier, by
   *forward* iteration, since every orbit is purely periodic.
5. **Census and limits.** At most $4^{L}$ files of any length are $L$-seed
   compressible, and never that many: the bound improves to $4^L - 2^L + 1$
   because all zero-seed registers collapse. Seed-compressible files are a
   $2^{2L-N}$ fraction of length-$N$ files. Finally, for *any* fixed
   decompressor on the model branch, there are files that are neither
   seed-compressible nor model-compressible: a two-box router cannot cover file
   space, and the pigeonhole bound survives the addition of generator
   detection.

We also report an exact census of distinct binary streams of complexity at most
$L$ for $L \le 8$, which matches $\tfrac{1}{3}(2 \cdot 4^{L} + 1)$ in every
case; this regularity is an empirical observation and is stated as a
conjecture.

**Keywords:** linear feedback shift register, linear complexity,
Berlekamp–Massey, seed recovery, linear congruential generator, shift operator,
Hankel rank, description complexity, lossless compression.

---

## 1. Introduction

### 1.1 The phenomenon

Compression exploits structure. Classical compressors exploit *statistical*
structure — repeated substrings, skewed symbol frequencies, local correlation —
and are defeated by data whose statistics are flat. But flat statistics do not
imply high information content. The output of a well-chosen shift register of
$32$ cells passes standard randomness tests while being determined by $64$ bits.
A megabyte of such data has description complexity $64$ bits and statistical
compressibility zero.

Such data is not rare in the wild. Procedural game worlds are generated from
seeds and stored as assets; simulation studies persist their random streams for
reproducibility; synthetic corpora are generated to benchmark databases;
transport-layer scramblers XOR real payloads with register output. Whenever the
generator and the seed are known or recoverable, the correct compressed
representation of such a file is the seed.

This paper develops the mathematics of that pipeline: **fingerprint** (which
generator family produced this stream?), **identify** (which parameters?),
**recover** (what seed?), **verify** (does replay reproduce the file exactly?),
and **bound** (how much data can possibly be handled this way?).

### 1.2 Contribution and structure

Section 2 fixes the model. Section 3 proves the exact-replay theorem and the
rigidity lemma underlying it. Section 4 develops the polynomial-module
machinery and proves the $2L$ sample-complexity theorem, with a matching
lower-bound witness. Section 5 characterizes well-posedness of tap recovery by a
spanning (Hankel-rank) criterion. Section 6 treats congruential generators.
Section 7 quantifies the population of seed-compressible files, proves the
router dichotomy, and reports the census. Section 8 gives algorithms; Section 9
applications; Section 10 discussion and future work.

Throughout, the falsifiability standard is absolute: a compression claim is
accepted only when the decoder, run on the claimed program, reproduces the file
**bit for bit**. No statistical similarity, prefix agreement, or approximate
match is admitted.

---

## 2. The model

Let $F$ be a commutative ring (we specialize to a field, and often to
$\mathrm{GF}(2)$, where noted). A **stream** is a function
$x : \mathbb{N} \to F$, written $x_n$ for $x(n)$.

> **Definition 2.1 (Linear recurrence / LFSR stream).** For $L \in \mathbb{N}$
> and a **tap vector** $c : \{0,\dots,L-1\} \to F$, the stream $x$ *obeys the
> order-$L$ recurrence with taps $c$* if
> $$x_{n+L} \;=\; \sum_{i=0}^{L-1} c_i \, x_{n+i} \qquad \text{for all } n \in \mathbb{N}.$$

> **Definition 2.2 (The generator).** Given taps $c$ and a **seed**
> $s : \{0,\dots,L-1\} \to F$, the register output $R(c,s) : \mathbb{N} \to F$ is
> defined by strong recursion:
> $$R(c,s)_n = \begin{cases} s_n, & n < L,\\[2pt] \displaystyle\sum_{i=0}^{L-1} c_i\, R(c,s)_{n-L+i}, & n \ge L.\end{cases}$$

The recursion is well-founded because $n - L + i < n$ for $i < L$ and $n \ge L$.

> **Proposition 2.3.** $R(c,s)$ obeys the order-$L$ recurrence with taps $c$, and
> $R(c,s)_n = s_n$ for $n < L$.

*Proof.* For $n \ge L$ the defining clause is exactly the recurrence, re-indexed
by $n \mapsto n + L$; the initial clause is the second claim. $\square$

> **Definition 2.4 (State window).** The **window** of $x$ at time $n$ is the
> vector $w_n(x) = (x_n, x_{n+1}, \dots, x_{n+L-1}) \in F^{L}$.

> **Definition 2.5 (Linear complexity).** A stream $x$ has **complexity at most
> $L$** if some tap vector $c \in F^{L}$ exists with $x$ obeying the order-$L$
> recurrence with taps $c$. The **linear complexity** $\mathrm{lc}(x)$ is the
> least such $L$ (infinite if none exists).

The property is upward closed: if $c$ generates $x$ at order $L$, then
$(0, c_0, \dots, c_{L-1})$ generates $x$ at order $L+1$, since the order-$L$
recurrence at index $n+1$ is the order-$(L+1)$ recurrence at index $n$. Hence
"$x$ has complexity at most $L$" is equivalent to $\mathrm{lc}(x) \le L$, and we
use the two phrasings interchangeably.

---

## 3. Exact replay: the compression guarantee

The recurrence has no memory beyond its window, so agreement on one full window
propagates forever.

> **Theorem 3.1 (Rigidity).** Let $x$ and $y$ both obey the order-$L$ recurrence
> with the *same* taps $c$, and suppose $x_i = y_i$ for all $i < L$. Then
> $x = y$.

*Proof.* Strong induction on $n$. For $n < L$ this is the hypothesis. For
$n \ge L$ write $n = m + L$. Then
$x_{m+L} = \sum_i c_i x_{m+i}$ and $y_{m+L} = \sum_i c_i y_{m+i}$, and each
index $m + i$ with $i < L$ satisfies $m + i < n$, so the inductive hypothesis
gives $x_{m+i} = y_{m+i}$ and the two sums coincide. $\square$

> **Theorem 3.2 (Exact replay / the seed-recovery gate).** If $x$ obeys the
> order-$L$ recurrence with taps $c$, then
> $$x \;=\; R\bigl(c,\; (x_0, x_1, \dots, x_{L-1})\bigr).$$
> That is, the pair (taps, first $L$ symbols) is a **lossless** representation of
> the entire infinite stream.

*Proof.* Both sides obey the order-$L$ recurrence with taps $c$ (hypothesis and
Proposition 2.3) and agree on indices $< L$ (Proposition 2.3 again). Apply
Theorem 3.1. $\square$

> **Corollary 3.3 (Functional dependence).** If $x$ and $y$ both obey the
> order-$L$ recurrence with taps $c$ and agree on the first $L$ symbols, they are
> equal. Hence the stream is a *function* of the pair (taps, window).

> **Proposition 3.4 (The zero-seed degeneracy).** For every tap vector $c$,
> $R(c, 0) = 0$.

*Proof.* Strong induction: below $L$ the output is the zero seed; above, it is a
linear combination of earlier outputs, all zero by hypothesis. $\square$

Proposition 3.4 is the germ of two later results: it is the obstruction to
uniqueness of the taps (Section 5) and it is why the naive parameter count of
seed-compressible files is never tight (Section 7).

### 3.1 Periodic data as register output

> **Definition 3.5.** For $p \ge 1$, the **recirculating taps** are
> $u^{(p)} = (1, 0, 0, \dots, 0) \in F^{p}$.

> **Theorem 3.6 (Periodicity is a linear recurrence).** For $p \ge 1$, a stream
> $x$ obeys the order-$p$ recurrence with taps $u^{(p)}$ **iff**
> $x_{n+p} = x_n$ for all $n$. Moreover $R(u^{(p)}, s)_n = s_{n \bmod p}$.

*Proof.* The sum $\sum_{i<p} u^{(p)}_i x_{n+i}$ collapses to the single term
$i = 0$, giving $x_n$; so the recurrence reads $x_{n+p} = x_n$. The formula for
$R$ follows by strong induction, using $n \bmod p = (n-p) \bmod p$ for
$n \ge p$. $\square$

Thus every $p$-periodic file is seed-compressible with a $2p$-symbol
description. Padding regions, fill patterns, repeated headers and tiled texture
data therefore fall inside the detector's reach.

---

## 4. Sample complexity: $2L$ symbols suffice, and no fewer

Detection is harder than replay because the taps are unknown and rival
candidate registers compete. The identification question is: after how many
observations is the answer unique inside the complexity-$\le L$ class? We prove
the answer is $2L$.

### 4.1 Streams as a module over the polynomial ring

> **Definition 4.1 (Shift operator).** $S : (\mathbb{N} \to F) \to (\mathbb{N} \to F)$,
> $(S x)_n = x_{n+1}$.

$S$ is $F$-linear, and $(S^k x)_n = x_{n+k}$ by induction on $k$. Consequently
evaluation at $S$ makes the space of streams a module over the polynomial ring
$F[X]$, with $X$ acting as $S$: for $r = \sum_k r_k X^k$,
$$\bigl(r(S)\,x\bigr)_n \;=\; \sum_k r_k \, x_{n+k}.$$

> **Definition 4.2 (Characteristic polynomial).** The order-$L$ recurrence with
> taps $c$ has characteristic polynomial
> $$\chi_c(X) \;=\; X^{L} - \sum_{i=0}^{L-1} c_i X^{i} \in F[X],$$
> which is monic of degree $L$.

> **Lemma 4.3 (Residual formula).** For every stream $x$ and index $n$,
> $$\bigl(\chi_c(S)\, x\bigr)_n \;=\; x_{n+L} - \sum_{i=0}^{L-1} c_i\, x_{n+i}.$$

*Proof.* Immediate from $(S^k x)_n = x_{n+k}$ and linearity of $r \mapsto r(S)$
applied termwise to $\chi_c$. $\square$

> **Theorem 4.4 (Annihilation criterion).** A stream $x$ obeys the order-$L$
> recurrence with taps $c$ **iff** $\chi_c(S)\,x = 0$.

*Proof.* Both statements say the residual of Lemma 4.3 vanishes for every $n$.
$\square$

The dictionary runs the other way too.

> **Theorem 4.5 (Every monic polynomial is characteristic).** Let $r \in F[X]$
> be monic with $\deg r = m$. Define the order-$m$ tap vector
> $c^{(r)}_i = -r_i$ (minus the degree-$i$ coefficient of $r$), $i < m$. Then
> $\chi_{c^{(r)}} = r$.

*Proof sketch.* Compare coefficients of $X^k$ on both sides of
$\chi_{c^{(r)}} = X^{m} - \sum_{i<m} c^{(r)}_i X^{i} = X^m + \sum_{i<m} r_i X^i$.
For $k < m$ only the summation contributes, giving $r_k$. For $k = m$ the
monomial $X^m$ contributes $1$, which equals $r_m$ by monicity. For $k > m$ both
sides vanish since $\deg r = m$. $\square$

> **Corollary 4.6.** If a monic $r$ of degree $m$ annihilates $z$ (i.e.
> $r(S)z = 0$), then $z$ has complexity at most $m$. Conversely, over a
> nontrivial ring, a stream of complexity at most $L$ is annihilated by a monic
> polynomial of degree $L$, namely the characteristic polynomial of any tap
> vector generating it.

### 4.2 Subadditivity of linear complexity

> **Theorem 4.7 (Subadditivity).** Suppose $F$ has no zero divisors. If $x$ has
> complexity at most $L$ and $y$ complexity at most $M$, then $x + y$ and
> $x - y$ have complexity at most $L + M$.

*Proof.* Pick monic annihilators $p$ (degree $L$) of $x$ and $q$ (degree $M$) of
$y$, which exist by Corollary 4.6. The product $pq$ is monic of degree $L + M$
(no zero divisors, so degrees add). Since $F[X]$ is commutative and the module
action is by algebra evaluation, $(pq)(S) = p(S)q(S) = q(S)p(S)$; hence
$(pq)(S)x = q(S)\bigl(p(S)x\bigr) = 0$ and likewise $(pq)(S)y = 0$. Therefore
$(pq)(S)(x+y) = 0$, and Corollary 4.6 gives complexity at most $L + M$. For the
difference, note $-y$ has the same annihilators as $y$. $\square$

The interpretation is operationally important: **mixing two register streams
cannot hide them**. A superposition of a complexity-$L$ and a complexity-$M$
source is still detectable by a search up to order $L + M$.

### 4.3 The $2L$ theorem

> **Lemma 4.8 (Vanishing initial segment).** If $z$ has complexity at most $m$
> and $z_i = 0$ for all $i < m$, then $z = 0$.

*Proof.* The zero stream obeys every recurrence; $z$ and $0$ obey the same
order-$m$ recurrence and agree below $m$, so Theorem 3.1 gives $z = 0$.
$\square$

> **Theorem 4.9 ($2L$ samples determine the stream).** Let $F$ be a nontrivial
> ring without zero divisors. If $x$ and $y$ both have complexity at most $L$ and
> $x_i = y_i$ for all $i < 2L$, then $x = y$.

*Proof.* By Theorem 4.7, $z = x - y$ has complexity at most $L + L = 2L$; by
hypothesis $z_i = 0$ for $i < 2L$; by Lemma 4.8, $z = 0$. $\square$

Two consequences drive the pipeline.

> **Corollary 4.10 (Detector soundness).** Suppose a file (as a prefix of a
> stream) truly is generated by *some* order-$L$ register, and a candidate
> register of order $L$ reproduces its first $2L$ symbols. Then the candidate
> reproduces the whole file. Fitting on a $2L$-symbol window is therefore not
> merely a heuristic: it is a proof of global agreement.

> **Corollary 4.11 (No shorter window).** Two order-$L$ registers with different
> output streams already differ at some index $< 2L$. Hence the observation
> window cannot be shortened below $2L$ without introducing genuine ambiguity.

### 4.4 Sharpness

Corollary 4.11 says the window is at least *as short as possible given the
class*; here is a concrete witness that $2L - 1$ symbols do not suffice. Over
$\mathrm{GF}(2)$ with $L = 3$, take
$$x = 0\,0\,1\,0\,0\,0\,0\,0\dots \qquad\text{and}\qquad y = 0\,0\,1\,0\,0\,1\,0\,0\,1\dots$$
Both have complexity at most $3$: $x$ is generated by the register with zero
taps and seed $(0,0,1)$ (which shifts a single one out and then emits zeros),
and $y$ is $3$-periodic, hence generated by the recirculating taps
$u^{(3)} = (1,0,0)$ with seed $(0,0,1)$ (Theorem 3.6). They agree on indices
$0,\dots,4$, i.e. on $2L - 1 = 5$ symbols, and differ at index $5 = 2L - 1$.

An exhaustive scan over all $4^{3} = 64$ binary order-$3$ parameter pairs
confirms both halves of the picture: grouping the emitted streams by their first
$2L = 6$ symbols yields $43$ groups, each containing exactly one stream (no
ambiguity, as Theorem 4.9 requires), whereas grouping by the first $2L-1 = 5$
symbols produces groups containing distinct streams.

---

## 5. Well-posedness: when are the taps unique?

Theorem 4.9 identifies the *stream*. It does not identify the *register*, and in
general nothing does: by Proposition 3.4 the all-zero stream is emitted by every
order-$L$ register. Any assertion that "the taps are determined by the stream"
is false as stated. The correct statement replaces the assertion by a criterion.

Assume now $F$ is a field.

> **Definition 5.1 (Window span).** For a stream $x$ and order $L$, let
> $W(x, L) = \mathrm{span}_F\{\, w_n(x) : n \in \mathbb{N} \,\} \le F^{L}$
> be the subspace spanned by all state windows. Equivalently, $W(x,L)$ is the row
> space of the infinite Hankel matrix $H_{n,i} = x_{n+i}$.

> **Theorem 5.2 (Uniqueness from spanning).** If $W(x, L) = F^{L}$ and both tap
> vectors $c$ and $d$ generate $x$, then $c = d$.

*Proof.* Let $e = c - d$ and let $\langle e, \cdot\rangle$ be the associated
linear functional $v \mapsto \sum_{i<L} e_i v_i$ on $F^L$. Subtracting the two
recurrences at time $n$ gives
$$\langle e, w_n(x)\rangle = \sum_{i<L} c_i x_{n+i} - \sum_{i<L} d_i x_{n+i} = x_{n+L} - x_{n+L} = 0 .$$
So the functional vanishes on every window, hence on their span, which by
hypothesis is all of $F^L$. A functional vanishing identically has zero
coefficient vector (test against the standard basis), so $e = 0$. $\square$

> **Corollary 5.3 (Finite certificate).** It suffices that the first $L$ windows
> $w_0(x), \dots, w_{L-1}(x)$ span $F^L$ — a condition testable on the first
> $2L-1$ observed symbols by a rank computation.

The converse holds, and this is what makes spanning the *right* hypothesis
rather than a convenient one.

> **Theorem 5.4 (Spanning from uniqueness).** Let $x$ obey the order-$L$
> recurrence with taps $c$ and suppose $c$ is the *only* such tap vector. Then
> $W(x, L) = F^{L}$.

*Proof.* Contrapositive. If $W(x,L) \ne F^{L}$, then, $W(x,L)$ being a proper
subspace of a finite-dimensional space, there is a nonzero linear functional
$\varphi$ on $F^L$ vanishing on $W(x,L)$. Writing $\varphi$ in coordinates as
$\varphi(v) = \sum_{i<L} e_i v_i$ with $e \ne 0$ (take $e_i = \varphi(\delta_i)$
on the standard basis and expand any $v$ in that basis), we get
$\sum_{i<L} e_i x_{n+i} = 0$ for all $n$. Adding this identity to the recurrence
shows that the tap vector $c + e$ also generates $x$. Since $e \ne 0$, this is a
second, different tap vector, contradicting uniqueness. $\square$

> **Theorem 5.5 (Characterization).** For a stream $x$ generated by the order-$L$
> tap vector $c$:
> $$c \text{ is the unique generating tap vector} \iff W(x, L) = F^{L}.$$

Quantitatively, over $\mathrm{GF}(2)$ the solution set of the linear system
"tap vector consistent with the observed windows" is an affine subspace of
dimension $L - \mathrm{rank}$, so exactly $2^{L - \mathrm{rank}}$ tap vectors are
consistent. Exhaustive verification at $L = 4$ over binary streams confirms this:
a maximal-length register gives window rank $4$ and a unique tap vector; the
all-zero stream gives rank $0$ and all $16$ tap vectors; a period-$2$ stream
embedded at order $4$ gives rank $4$ and again a unique answer.

**Methodological remark.** The naive conjecture "tap recovery is unique" is
false, and the repair was not a stronger proof but a *better definition*. The
Hankel spanning condition is not an extra hypothesis inserted to save a theorem;
by Theorem 5.5 it is logically equivalent to the desired conclusion. When a
plausible statement resists proof, the productive move is often to look for the
invariant that the statement is really about.

---

## 6. Linear congruential generators: one detector, two families

> **Definition 6.1.** Over a commutative ring $R$, the LCG with multiplier $a$,
> increment $b$ and seed $s$ emits
> $$\mathrm{lcg}(a,b,s)_0 = s, \qquad \mathrm{lcg}(a,b,s)_{n+1} = a\,\mathrm{lcg}(a,b,s)_n + b .$$

The affine map $x \mapsto ax + b$ is not linear, so an LCG is not literally a
shift register. Differencing removes the increment.

> **Theorem 6.2 (Family collapse).** Every LCG stream obeys the order-$2$ linear
> recurrence with tap vector $(-a,\; 1+a)$:
> $$x_{n+2} = (1+a)\,x_{n+1} - a\,x_n .$$

*Proof.* $x_{n+2} = a x_{n+1} + b$ and $x_{n+1} = a x_n + b$. Subtracting,
$x_{n+2} - x_{n+1} = a(x_{n+1} - x_n)$, i.e.
$x_{n+2} = (1+a)x_{n+1} - a x_n$. $\square$

Consequently the entire theory of Sections 3–5 applies to congruential data with
$L = 2$: four observations identify the stream (Theorem 4.9), replay is exact,
and the uniqueness criterion is a $2 \times 2$ rank condition. No second
detector is required, and no second correctness proof.

> **Theorem 6.3 (Recurrence implies exact replay).** If a stream $x$ satisfies
> $x_{n+1} = a x_n + b$ for all $n$, then $x = \mathrm{lcg}(a, b, x_0)$.

*Proof.* Induction on $n$: the base case is definitional, and the step applies
the recursion to both sides. $\square$

### 6.1 Seed recovery, backward and forward

> **Definition 6.4.** If $a$ has an inverse $a^{-1}$ in $R$, the **inverse step**
> is $\mathrm{unstep}(y) = a^{-1}(y - b)$.

> **Theorem 6.5 (Backward recovery).** If $a^{-1}a = 1$ then $\mathrm{unstep}$ is
> a two-sided inverse of $x \mapsto ax+b$, that map is a bijection of $R$, and
> for all $n$
> $$\mathrm{unstep}^{\,n}\bigl(\mathrm{lcg}(a,b,s)_n\bigr) = s .$$

*Proof.* $\mathrm{unstep}(ax + b) = a^{-1}(ax + b - b) = x$ and
$a\,\mathrm{unstep}(y) + b = a a^{-1}(y-b) + b = y$; bijectivity follows. The
displayed identity is induction on $n$, each step peeling one application.
$\square$

This is exact and search-free: no approximation, no lattice reduction, no
guessing. Over $\mathbb{Z}/m$ with $\gcd(a,m)=1$ the inverse is computed by the
extended Euclidean algorithm in $O(\log m)$ steps.

The forward statement is subtler and dispenses with inversion entirely.

> **Theorem 6.6 (Pure periodicity).** Let $R$ be finite and $a$ invertible. Then
> the step map is a permutation of $R$, hence has finite order $p > 0$ with
> $(x \mapsto ax+b)^{p} = \mathrm{id}$. Consequently
> $\mathrm{lcg}(a,b,s)_{n+p} = \mathrm{lcg}(a,b,s)_n$ for all $n$ and
> $\mathrm{lcg}(a,b,s)_{kp} = s$ for all $k$: the orbit is *purely* periodic,
> with no transient prefix.

*Proof.* Bijectivity is Theorem 6.5; a bijection of a finite set is a
permutation and has finite order $p$ in the symmetric group, so its $p$-th
iterate is the identity. The stream is the orbit of $s$ under iteration, so
shifting the index by $p$ leaves it unchanged; taking $n = 0$ and iterating
gives the multiple-of-$p$ statement. $\square$

> **Corollary 6.7 (Forward recovery).** Under the hypotheses of Theorem 6.6, for
> any observed state $\mathrm{lcg}(a,b,s)_n$ there exists $k \ge 0$ with
> $\mathrm{lcg}\bigl(a, b, \mathrm{lcg}(a,b,s)_n\bigr)_k = s$; explicitly
> $k = np - n$ works. The seed is reachable by running the generator *forward*.

*Proof.* Restarting the generator at a later state continues the same stream, so
the displayed value is $\mathrm{lcg}(a,b,s)_{n+k}$; with $k = np - n$ (valid as
$n \le np$ for $p \ge 1$) this is $\mathrm{lcg}(a,b,s)_{np} = s$ by Theorem 6.6.
$\square$

Operationally, an adversary or a compressor equipped only with the forward
generator — no modular inverse routine, no algebraic solver — can still recover
the seed. Rewinding is a special case of fast-forwarding.

### 6.2 Congruential data is rare

> **Theorem 6.8 (Three parameters).** Over $\mathbb{Z}/m$, the set of length-$N$
> prefixes producible by *some* LCG has at most $m^{3}$ elements, for every $N$.

*Proof.* The prefix is the image of the triple $(a, b, s) \in (\mathbb{Z}/m)^3$
under a fixed map; the image of a set of size $m^3$ has size at most $m^3$.
$\square$

> **Corollary 6.9.** If $m \ge 2$ and $N > 3$ then some length-$N$ stream over
> $\mathbb{Z}/m$ is produced by no LCG at all, since $m^{3} < m^{N}$. A sound
> detector must reject it, and the false-positive budget of any detector is
> $m^{3-N}$.

---

## 7. The census: how much data is seed-compressible?

We now quantify the population. Fix the binary field and model a file as a
bitstring $w \in \{0,1\}^{N}$.

> **Definition 7.1 ($L$-seed compressibility).** $w$ is **$L$-seed compressible**
> if there exist binary taps $c$ and seed $s$ of length $L$ such that
> $w_i = R(c,s)_i$ for every $i < N$, where the register runs over
> $\mathrm{GF}(2)$.

> **Definition 7.2 (The seed decoder).** Fix $N, L$. The decoder $D_{N,L}$ reads
> a program $p \in \{0,1\}^{*}$, interprets its first $L$ bits as taps and its
> next $L$ bits as a seed (missing bits default to $0$), runs the register, and
> outputs the first $N$ symbols.

> **Theorem 7.3 (The falsifiability gate).** $w$ is $L$-seed compressible **iff**
> there is a program $p$ with $D_{N,L}(p) = w$ exactly. The witnessing program is
> the concatenation of the tap bits and the seed bits and has length exactly
> $2L$.

*Proof.* ($\Rightarrow$) Given $(c,s)$, the concatenated program is read back
correctly by the decoder's indexing, so $D_{N,L}(p)$ is the register output,
which equals $w$ on the first $N$ positions. ($\Leftarrow$) Given $p$, extract
its first $L$ and next $L$ bits as $(c,s)$; unfolding the decoder's definition
shows $w = D_{N,L}(p)$ is the corresponding register output. $\square$

> **Corollary 7.4 (Description complexity).** Let $KC_D(w)$ denote the length of
> the shortest program $p$ with $D(p) = w$. If $w$ is $L$-seed compressible then
> $KC_{D_{N,L}}(w) \le 2L$, *independently of $N$*.

This is the payoff: a gigabyte generated by an order-$32$ register has a
$64$-bit description. And it is verifiable — the claim is refuted by a single
mismatching bit.

### 7.1 Upper bounds on the population

> **Theorem 7.5 (Parameter bound).** For all $N, L$, the number of $L$-seed
> compressible files of length $N$ is at most $4^{L}$.

*Proof.* Each such file is the image of a pair (taps, seed) under the map
sending parameters to the length-$N$ prefix of the register output. There are
$2^L \cdot 2^L = 4^L$ pairs, and the image of a finite set is no larger.
$\square$

> **Theorem 7.6 (The parameter bound is never tight).** For all $N, L$, the
> number of $L$-seed compressible files of length $N$ is at most
> $4^{L} - 2^{L} + 1$.

*Proof.* Partition the parameter pairs into those with zero seed ($2^{L}$ of
them, one per tap vector) and the rest. By Proposition 3.4 all zero-seed pairs
map to the single all-zero file. So the image is contained in
$\{\,0^N\,\} \cup \{\text{images of the } 4^L - 2^L \text{ remaining pairs}\}$,
of size at most $1 + (4^L - 2^L)$. $\square$

> **Theorem 7.7 (Exponential rarity).** If $2L \le N$, the number of $L$-seed
> compressible files of length $N$ is at most $2^{2L}$, i.e. a fraction
> $2^{2L-N}$ of all $2^{N}$ files.

*Proof.* $4^{L} = 2^{2L}$; multiply Theorem 7.5 by $2^{N-2L}$. $\square$

> **Corollary 7.8 (Non-vacuity of the classifier).** If $2L < N$ then some
> length-$N$ file is *not* $L$-seed compressible: otherwise all $2^{N}$ files
> would lie in a set of size at most $2^{2L} < 2^{N}$.

### 7.2 The exact census

How far below $4^L$ is the truth? By Theorem 4.9 two distinct streams of
complexity at most $L$ differ within the first $2L$ symbols, so counting
distinct prefixes of length $2L$ counts distinct *infinite* streams exactly.
Exhaustive enumeration over $\mathrm{GF}(2)$ gives:

| $L$ | distinct streams | $\tfrac{1}{3}(2\cdot 4^{L}+1)$ | proved bound $4^L-2^L+1$ | naive $4^L$ |
|----:|-----------------:|------------------------------:|-------------------------:|------------:|
| 1 | 3 | 3 | 3 | 4 |
| 2 | 11 | 11 | 13 | 16 |
| 3 | 43 | 43 | 57 | 64 |
| 4 | 171 | 171 | 241 | 256 |
| 5 | 683 | 683 | 993 | 1024 |
| 6 | 2731 | 2731 | 4033 | 4096 |
| 7 | 10923 | 10923 | 16257 | 16384 |
| 8 | 43691 | 43691 | 65281 | 65536 |

> **Conjecture 7.9 (Exact census).** The number of distinct binary streams of
> linear complexity at most $L$ is exactly $\tfrac{1}{3}\bigl(2\cdot 4^{L}+1\bigr)$;
> equivalently, the realizable fraction of the $4^{L}$ parameter pairs tends to
> $2/3$.

The conjecture is supported by exhaustive computation for $L \le 8$ and is not
proved here. The structural reason to expect a clean formula is that a stream is
determined by its *minimal* connection polynomial together with a numerator, so
the map (taps, seed) $\mapsto$ stream factors through pairs (minimal polynomial,
residue class) and the fibre over a stream is the set of registers whose
characteristic polynomial is a multiple of the minimal one — a count of monic
cofactors of the appropriate degree. Making this precise requires divisibility
bookkeeping on top of the polynomial–register dictionary of Theorems 4.4 and
4.5.

Note in passing that the census refutes the naive expectation that the count is
$\Theta(2^{L})$: the realizable streams have positive density $2/3$ in parameter
space, so the count is $\Theta(4^{L})$, and the improvement over the naive bound
is a constant factor, not an exponential one.

### 7.3 The router dichotomy

The practical proposal is a **router**: classify each file as either
*seed-compressible* (recover the seed; pay $2L$ bits) or *model-compressible*
(hand it to a general-purpose decompressor $D$; demand a gain of $d$ bits, i.e.
$KC_D(w) + d \le N$). We show the two boxes cannot cover file space.

The model branch is limited by the counting bound behind every incompressibility
theorem: for a fixed decompressor $D$ the number of files with
$KC_D(w) \le N - d$ is at most the number of programs of length $\le N-d$,
namely $2^{N-d+1} - 1$; equivalently $2^{d}\,\#\{w : KC_D(w) + d \le N\} \le 2^{N+1}$.

> **Theorem 7.10 (Router dichotomy).** Let $D : \{0,1\}^{*} \to \{0,1\}^{N}$ be
> any surjective decompressor and let $L, d \ge 0$ satisfy
> $$2^{d}\,2^{2L} \;+\; 2^{N+1} \;<\; 2^{d}\,2^{N}.$$
> Then there is a file $w \in \{0,1\}^{N}$ that is **neither** $L$-seed
> compressible **nor** $d$-bit compressible under $D$.

*Proof.* Let $A$ be the set of $L$-seed compressible files, so
$|A| \le 2^{2L}$ by Theorem 7.7, and $B = \{w : KC_D(w) + d \le N\}$, so
$2^{d}|B| \le 2^{N+1}$ by the counting bound. Then
$$2^{d}\bigl(|A| + |B|\bigr) \;\le\; 2^{d}2^{2L} + 2^{N+1} \;<\; 2^{d}2^{N},$$
so $|A| + |B| < 2^{N}$ and $|A \cup B| < |\{0,1\}^{N}|$. Any file outside
$A \cup B$ works. $\square$

> **Corollary 7.11 (Concrete instance).** Among $64$-bit files, whatever
> decompressor is installed on the model branch, some file is neither the output
> of an order-$8$ register (a $16$-bit seed) nor compressible by $4$ bits:
> the hypothesis reads $2^{4}2^{16} + 2^{65} < 2^{4}2^{64}$, which holds.

The lesson is not that detection is worthless but that it is *selective*.
Detection changes **which** files sit on the compressible side of the pigeonhole
bound, not **how many**. Its value is that the files it moves — statistically
flat, computationally trivial — are exactly those every statistical compressor
misses.

---

## 8. Algorithms

### 8.1 Berlekamp–Massey (identification)

Given an observation window $s_0, \dots, s_{n-1}$ over a field, the
Berlekamp–Massey algorithm returns the minimal $L$ and a connection polynomial
$C(X) = 1 + C_1X + \dots + C_LX^{L}$ with
$s_j = \sum_{i=1}^{L} C_i s_{j-i}$ for all $j \ge L$ (over $\mathrm{GF}(2)$ the
signs are immaterial). It maintains a current candidate $C$, the previous
candidate $B$ from the last length change, and a discrepancy; when the
discrepancy is nonzero the candidate is corrected by a shifted multiple of $B$,
and the register length is increased when necessary. Complexity: $O(n^{2})$
field operations and $O(n)$ storage.

Its correctness *as a detector* is exactly Corollary 4.10: if the data really
has complexity at most $L$ and the algorithm is given $2L$ symbols, its output
reproduces the entire stream, not merely the window. The paper's tap convention
is recovered by reversing: $c_i = C_{L-i}$.

### 8.2 The detection and recovery pipeline

Given a file $w$ of length $N$ and a maximum order $L_{\max} \le N/2$:

1. Run Berlekamp–Massey on the first $2L_{\max}$ symbols; obtain $L$ and taps
   $c$.
2. If $2L \ge N$, reject (no compression gain: the description is as large as
   the data).
3. Replay: compute $R(c, (w_0,\dots,w_{L-1}))$ for $N$ steps.
4. **Gate:** compare with $w$ bit for bit. On any mismatch, reject and route to
   the model branch. On exact match, accept and emit the $2L$-bit program.
5. Optionally test for the congruential signature: if $L = 2$ with taps
   $(-a, 1+a)$, report multiplier $a$, recover $b = w_1 - a w_0$, and the seed is
   $w_0$; verify by replay.

The gate in step 4 makes false acceptance impossible. Steps 1 and 3 cost
$O(L^2)$ and $O(NL)$ respectively.

### 8.3 Well-posedness test

Assemble the Hankel matrix of the first windows and compute its rank $r$ over
the field. By Theorem 5.5 the taps are unique iff $r = L$; over
$\mathrm{GF}(2)$ the number of consistent tap vectors is exactly $2^{L-r}$. Cost:
$O(L^{3})$ field operations, or $O(L^{3}/64)$ machine words with bit-packing.

### 8.4 Seed recovery for congruential data

With a state $x_n$ and known $(a,b,m)$ and $\gcd(a,m)=1$: compute $a^{-1}$ by
the extended Euclidean algorithm and apply $y \mapsto a^{-1}(y-b)$ exactly $n$
times (Theorem 6.5); or, avoiding inversion, run the generator forward from
$x_n$ until the state repeats (Corollary 6.7). Backward recovery costs
$O(n)$ multiplications, or $O(\log n)$ if the affine map is exponentiated by
repeated squaring using $x_n = a^{n}s + b\frac{a^{n}-1}{a-1}$.

---

## 9. Applications

**Archival of procedurally generated assets.** Game terrain, foliage placement,
noise textures and dungeon layouts are typically generated from a seed and then
persisted. When the generator is a linear recurrence or a congruential map, the
asset compresses to its seed with the exact-replay guarantee.

**Simulation reproducibility.** Monte Carlo studies persist random streams to
allow exact re-running. Those streams are seed-compressible by construction and
the gate certifies bit-exactness, which is precisely what reproducibility
requires.

**Cryptanalytic hygiene.** The $2L$ theorem is the classical warning against
using a bare shift register as a keystream: $2L$ known plaintext symbols suffice
to recover the register and hence the entire keystream. The uniqueness
characterization (Theorem 5.5) sharpens this by identifying exactly when the
recovered register is the true one, versus when the observed data is degenerate.

**Corpus triage.** The router of Section 7.3 is deployable: detect, gate,
compress or fall through. Theorem 7.10 sets expectations honestly — the
seed-compressible fraction is $2^{2L-N}$ — while Theorem 3.6 identifies a real
and common corpus that is caught: periodic and tiled data.

**Scrambled transport streams.** Ethernet, SONET and satellite links scramble
payloads by XOR-ing with register output. Given known or guessable plaintext,
the same identification and recovery machinery strips the scrambler.

---

## 10. Discussion and future work

Three themes emerge.

*First, the change of language does the work.* Recasting streams as a module
over the polynomial ring, with the shift operator playing the indeterminate,
converts "obeys a recurrence" into "is annihilated by a polynomial". Subadditive
complexity is then just the statement that annihilators multiply, and the $2L$
bound is degree arithmetic. This is the standard payoff of finding the right
algebraic home for a computational problem.

*Second, degeneracy is data, not noise.* The failed conjecture "the taps are
determined by the stream" was repaired not by working harder but by identifying
the invariant that governs the phenomenon — the rank of the Hankel window
matrix — and the repair turned out to be an exact characterization, not merely a
sufficient condition.

*Third, counting is unforgiving.* Every result about what detection can achieve
is bracketed by a result about how little of the universe it reaches. This is not
a shortcoming of the method; it is the shape of all lossless compression.

### Future directions

**C1. The exact census of seed-compressible files.** Prove Conjecture 7.9. The
map (taps, seed) $\mapsto$ stream factors through the pair (minimal connection
polynomial, residue class), so the fibre over a stream consists of the registers
whose characteristic polynomial is a multiple of the minimal one, i.e. of the
monic cofactors of the appropriate degree. The polynomial–register dictionary
(Theorems 4.4 and 4.5) is in place; what is missing is the divisibility
bookkeeping and a clean handling of the degenerate strata. Measured data:
$43$ distinct streams from the $64$ order-$3$ parameter pairs, against the proved
bound $57$; the sequence continues $171, 683, 2731, 10923, 43691$.

**C2. Minimal complexity as a computable invariant, and sharpness of the $2L$
bound.** Prove that for every $L$ there exist two streams of complexity exactly $L$ agreeing on
the first $2L-1$ symbols and differing at index $2L-1$, upgrading the concrete
witnesses of Section 4.4 to a uniform family and establishing that the
observation window of Theorem 4.9 cannot be shortened for any $L$. A companion
goal is to prove that Berlekamp–Massey computes $\mathrm{lc}$ exactly, closing
the loop between the algorithm and the invariant.

**C3. Non-linear families.** Extend detection beyond linear recurrences to
Mersenne-Twister-style tempered linear generators (linear over
$\mathrm{GF}(2)$ in a high-dimensional state, so in principle within reach of the
same theory at large $L$), to permuted congruential generators, and to
counter-based constructions. Each requires either an enlarged linear model or a
solver-based inversion, and each needs its own well-posedness criterion.

**C4. Robust detection under corruption.** Real files interleave generator
output with headers, checksums and edits. The natural generalization is
approximate linear complexity: the least $L$ such that some order-$L$ register
agrees with the data outside a set of $k$ positions. Combined with an error
budget in the gate, this would extend the router to partially seed-compressible
files while keeping the bit-exact verification (store the seed plus the list of
corrections).

**C5. Quantifying real corpora.** Instrument the pipeline over public corpora
and measure what fraction of real files is seed-compressible at practical
orders. Theorem 7.7 predicts the fraction is negligible for random files; the
empirical question is how much *structured* real data (padding, tiles,
scrambled regions) is caught, and at what order.

---

## Appendix: summary of results

| Result | Statement |
|---|---|
| Rigidity (3.1) | Same taps + agreement on one length-$L$ window $\Rightarrow$ identical streams |
| Exact replay (3.2) | A recurrence-obeying stream equals its own replay from its first $L$ symbols |
| Zero-seed collapse (3.4) | Every register emits the zero stream from the zero seed |
| Periodicity (3.6) | $p$-periodic $\iff$ generated by the recirculating order-$p$ register |
| Annihilation (4.4) | Obeys a recurrence $\iff$ killed by its characteristic polynomial via the shift |
| Realization (4.5) | Every monic degree-$m$ polynomial is a characteristic polynomial |
| Subadditivity (4.7) | $\mathrm{lc}(x \pm y) \le \mathrm{lc}(x) + \mathrm{lc}(y)$ |
| $2L$ theorem (4.9) | Complexity $\le L$ + agreement on $2L$ symbols $\Rightarrow$ equality |
| Detector soundness (4.10) | Fitting $2L$ symbols fits the whole stream |
| Uniqueness (5.5) | Taps unique $\iff$ state windows span $F^{L}$ |
| Family collapse (6.2) | Every congruential stream is an order-$2$ linear recurrence, taps $(-a, 1+a)$ |
| Backward recovery (6.5) | $n$ inverse steps from the time-$n$ state return the seed exactly |
| Pure periodicity (6.6) | Finite state + invertible multiplier $\Rightarrow$ no transient |
| Forward recovery (6.7) | The seed is reachable by running the generator forward |
| Congruential rarity (6.8) | At most $m^{3}$ congruential prefixes over $\mathbb{Z}/m$, any length |
| Falsifiability gate (7.3) | Seed compressible $\iff$ a $2L$-bit program decodes the file exactly |
| Complexity bound (7.4) | Seed-compressible files have description length $\le 2L$, independent of $N$ |
| Population bounds (7.5–7.7) | At most $4^{L}$, in fact at most $4^{L}-2^{L}+1$; a $2^{2L-N}$ fraction |
| Router dichotomy (7.10) | Some file is neither seed- nor model-compressible, for any decompressor |
