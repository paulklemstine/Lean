# Finite Prefixes Determine No Asymptotic Digit Law

### Frequency, normality and autocorrelation indeterminacy for decimal expansions, with explicit lacunary witnesses

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We prove, in complete generality and with explicit constructions, that no finite prefix of the decimal expansion of a real number constrains the asymptotic behaviour of that expansion. Precisely: for every real $x \ge 0$ and every $n \in \mathbb{N}$ there exist real numbers $y$, $z$, $w$ agreeing with $x$ in the first $n$ decimal digits such that $y$ is irrational with nonzero-digit density $0$, $z$ is irrational with nonzero-digit density $1$, $w$ is rational, and none of the three is simply normal in base ten. The same prefix therefore decides neither rationality, nor any digit frequency, nor normality. We prove a companion statement for the second-order statistic: for every $x$ and $n$ there are irrational numbers sharing the first $n$ digits of $x$ whose lag-$r$ digit agreement densities are, respectively, $0$ at lag $1$ and $1$ at lag $2$, or $1$ at every lag $r$ simultaneously. We further show the witness set is uncountable for every prefix, that every nonnegative real is an $\varepsilon$-limit of both such irrational witnesses and of rationals with the same prefix, and — on the positive side — that irrationality has exactly one digit-theoretic consequence: for $x \in [0,1)$, $x$ is irrational if and only if its digit sequence is not eventually periodic.

The technical core is a toolkit for prescribing decimal expansions: an exact head/tail decomposition of $10^n \cdot \sum d_m 10^{-(m+1)}$, a digit-recovery theorem valid precisely when the digit $9$ is excluded, a Liouville-type gap criterion for irrationality, and a grafting operator that transplants an arbitrary tail onto an arbitrary prefix. The witnesses are lacunary: their designed digits sit at the positions $2^i - 1$, whose counting function $\log_2 M + 1$ is simultaneously large enough to break periodicity and small enough to have density zero.

**Keywords:** decimal expansion, normality, simple normality, digit frequency, autocorrelation, lacunary series, irrationality criteria, Liouville argument, prefix indeterminacy.

---

## 1. Introduction

### 1.1 The folklore claim and what is wrong with it

It is a commonplace that the decimal digits of $\pi$, of $e$ and of $\sqrt 2$ "behave randomly". The commonplace is supported by computation: billions of digits have been produced and subjected to frequency tests, block tests, gap tests, autocorrelation tests, and all of them are passed. The commonplace is also supported, at a distance, by measure theory: almost every real number is normal in every base, in the sense of Borel.

Neither support gives a theorem about $\pi$. The measure-theoretic statement is about a full-measure set to which no specific constant is known to belong. The computational statement is about a finite word. The purpose of this paper is to show that the second gap is not merely an unclosed one but a structurally unclosable one: the map

$$\text{(first $n$ digits of $x$)} \ \longmapsto \ \text{(asymptotic digit statistics of $x$)}$$

is not a function, and this can be witnessed by explicit, elementary, completely controlled counterexamples, uniformly in $n$.

### 1.2 What irrationality does and does not buy

Irrationality is not vacuous for digits. The classical dichotomy — recalled and proved below as Theorem 5.1 — says that for $x \in [0,1)$,

$$x \text{ irrational} \iff \text{the digit sequence of } x \text{ is not eventually periodic}.$$

This is the exact digit content of irrationality, and it is a genuine constraint: no eventually repeating block. It is also *all* of the digit content. Every asymptotic frequency statement, every autocorrelation statement, every normality statement is logically independent of it, as our witnesses demonstrate: two of our irrational numbers have nonzero-digit densities $0$ and $1$ respectively, both maximally far from the value $9/10$ forced by simple normality.

### 1.3 Results

Fix the digit function $d_m(x) = \lfloor x \cdot 10^{m+1} \rfloor \bmod 10$ for $x \ge 0$.

1. **(Digit Recovery, Theorem 2.4.)** A digit sequence avoiding the digit $9$ is realised exactly: the digits of its value are the prescribed digits. The hypothesis is necessary.
2. **(Gap Criterion, Theorem 2.6.)** A digit sequence avoiding $9$, with arbitrarily long runs of zeros and infinitely many nonzero digits, has irrational value.
3. **(Prefix Indeterminacy, Theorem 4.1.)** For every $x \ge 0$ and $n$: three numbers with the prefix of $x$, respectively irrational of nonzero-density $0$, irrational of nonzero-density $1$, and rational; none simply normal; pairwise distinguished at digit $n$.
4. **(Autocorrelation Indeterminacy, Theorem 6.5.)** For every $x$ and $n$: two irrational numbers with the prefix of $x$, one with lag-$1$ agreement density $0$ and lag-$2$ agreement density $1$, the other with agreement density $1$ at every lag.
5. **(Cardinal strengthening, Theorem 4.4.)** The set of irrational, non-simply-normal numbers sharing any given prefix is uncountable.
6. **(Metric strengthening, Theorem 4.3.)** Every $x \ge 0$ is approximated to within any $\varepsilon > 0$ both by irrational non-normal witnesses and by rationals, all sharing an arbitrarily long prefix of $x$.
7. **(Periodicity Dichotomy, Theorem 5.1.)** The positive counterpart described above.

Specialising 3 and 4 to $x = \sqrt 2$, $x = \pi$, $x = e$ yields the concrete statements about the classical constants.

### 1.4 Method

Everything rests on two operations. **Prescription** builds a real number from a designed digit sequence and guarantees the design is what one gets (Theorem 2.4). **Grafting** replaces the tail of a number beyond position $n$ by a designed tail while leaving the first $n$ digits untouched (Section 3). The designs themselves are *lacunary*: the interesting digits sit on the set

$$\Lambda = \{\, m \in \mathbb{N} : m+1 \text{ is a power of } 2 \,\} = \{0,1,3,7,15,31,63,\dots\},$$

a set with two contradictory-sounding virtues. It is *sparse*, with $\#(\Lambda \cap [0,M)) \le \log_2 M + 1$, so anything supported on it has density zero; and it is *spread*, with unbounded gaps, so anything supported on it defeats periodicity through the Liouville estimate. That tension is the engine of the entire paper.

---

## 2. Prescribing decimal expansions

### 2.1 Values of digit sequences

**Definition 2.1.** For a sequence $d = (d_m)_{m \ge 0}$ with $d_m \in \{0,\dots,9\}$, set
$$\mathrm{val}(d) \;=\; \sum_{m=0}^{\infty} \frac{d_m}{10^{\,m+1}} \in [0,1].$$
The series converges absolutely, being dominated by $\sum 9 \cdot 10^{-(m+1)} = 1$.

**Lemma 2.2 (Bounds).** If $d_m \le 8$ for all $m$ then $\mathrm{val}(d) \le 8/9 < 1$. If $d_j \ne 0$ for some $j$ then $\mathrm{val}(d) > 0$.

*Proof.* Termwise comparison with the geometric series $\sum_m \tfrac{8}{10}\cdot 10^{-m} = \tfrac89$ gives the first claim; the second follows since all terms are nonnegative and the $j$-th is strictly positive. $\square$

**Lemma 2.3 (Head/tail decomposition).** Write $H_n(d)$ for the natural number whose base-ten representation is $d_0 d_1 \cdots d_{n-1}$, defined recursively by $H_0(d) = 0$ and $H_{n+1}(d) = 10\,H_n(d) + d_n$. Then for every $n$,
$$10^n \cdot \mathrm{val}(d) \;=\; H_n(d) \;+\; \mathrm{val}\big(\sigma^n d\big), \qquad \sigma^n d := (d_{n}, d_{n+1}, d_{n+2}, \dots).$$

*Proof.* Split the series at index $n$ and multiply by $10^n$. The tail is $10^n \sum_{m \ge n} d_m 10^{-(m+1)} = \mathrm{val}(\sigma^n d)$ after reindexing. For the head one proves $10^n \sum_{i<n} d_i 10^{-(i+1)} = H_n(d)$ by induction on $n$, the inductive step being exactly the recursion $H_{n+1} = 10 H_n + d_n$. $\square$

A useful corollary: if the first $L$ digits vanish, then $\mathrm{val}(d) = 10^{-L}\,\mathrm{val}(\sigma^L d)$.

### 2.2 Digit recovery and the role of the digit $9$

**Theorem 2.4 (Digit Recovery).** Let $d$ be a digit sequence with $d_m \le 8$ for every $m$. Then
$$d_k\big(\mathrm{val}(d)\big) = d_k \qquad \text{for all } k \ge 0 .$$

*Proof.* Fix $k$ and apply Lemma 2.3 with $n = k+1$:
$$\mathrm{val}(d)\cdot 10^{k+1} = H_{k+1}(d) + T, \qquad T = \mathrm{val}(\sigma^{k+1} d).$$
By Lemma 2.2 applied to the tail, $0 \le T \le 8/9 < 1$; since $H_{k+1}(d)$ is a natural number,
$$\big\lfloor \mathrm{val}(d) \cdot 10^{k+1} \big\rfloor = H_{k+1}(d) = 10\,H_k(d) + d_k .$$
Reducing modulo $10$ and using $d_k < 10$ gives $d_k(\mathrm{val}(d)) = d_k$. $\square$

**Remark 2.5 (Necessity).** Some hypothesis excluding $9$ is unavoidable. For $d = (9,9,9,\dots)$ one has $\mathrm{val}(d) = 1$, whose digit sequence is $(0,0,0,\dots)$. More generally the $0.999\ldots = 1.000\ldots$ collision is the unique obstruction to recovery, and forbidding the digit $9$ is the cleanest hypothesis that kills it. All designs below use digits in $\{0,1,2,3\}$, so the hypothesis is free.

### 2.3 Irrationality from gaps

**Theorem 2.6 (Gap Criterion).** Let $d$ be a digit sequence with $d_m \le 8$ for all $m$. Suppose that for every $L \in \mathbb{N}$ there is a $k$ with
$$d_j = 0 \ \text{ for } k \le j < k+L, \qquad\text{and}\qquad d_j \ne 0 \ \text{ for some } j \ge k+L.$$
Then $\mathrm{val}(d)$ is irrational.

*Proof.* Suppose $\mathrm{val}(d) = p/q$ in lowest terms, $q \ge 1$. Apply the hypothesis with $L = q + 1$, obtaining $k$ as above, and set $T = \mathrm{val}(\sigma^k d)$. By Lemma 2.3,
$$T = 10^k\,\mathrm{val}(d) - H_k(d),$$
so $N := q\,T = 10^k p - q\,H_k(d)$ is an **integer**.

*Positivity.* Some digit $d_j$ with $j \ge k + L > k$ is nonzero, so by Lemma 2.2 the tail $T$ is strictly positive, whence $N \ge 1$.

*Smallness.* The first $L$ entries of $\sigma^k d$ vanish, so by the corollary to Lemma 2.3 and Lemma 2.2,
$$T = 10^{-L}\,\mathrm{val}(\sigma^{k+L}d) \le \tfrac89 \cdot 10^{-L}.$$
Since $q < 2^{q} \le 2^{L} \le 10^{L}$, we get $N = qT \le \tfrac89 \cdot q\,10^{-L} < 1$.

An integer $N$ with $1 \le N < 1$ is a contradiction. $\square$

This is a Liouville-type argument in the sharpest possible form: rational numbers have a scale below which their nonzero tails cannot go, and long digit gaps push the tail below that scale.

### 2.4 Rationality from periodicity, and digitwise addition

**Theorem 2.7 (Eventual periodicity $\Rightarrow$ rational).** If $d$ satisfies $d_{i + p + n} = d_{i+n}$ for all $i$, with $p \ge 1$, then $\mathrm{val}(d) \in \mathbb{Q}$.

*Proof.* Let $e = \sigma^n d$ and $u = \mathrm{val}(e)$. Periodicity means $\sigma^p e = e$, so Lemma 2.3 gives $10^p u = H_p(e) + u$, i.e. $u = H_p(e)/(10^p - 1) \in \mathbb{Q}$. Applying Lemma 2.3 once more, $\mathrm{val}(d) = \big(H_n(d) + u\big)/10^n \in \mathbb{Q}$. $\square$

**Lemma 2.8 (Digitwise additivity).** If $c$, $d$, $e$ are digit sequences with $e_m = c_m + d_m$ for all $m$ (no carrying, all sums being at most $9$), then $\mathrm{val}(e) = \mathrm{val}(c) + \mathrm{val}(d)$.

*Proof.* All three series converge absolutely, and the summands add termwise. $\square$

Lemma 2.8 is the mechanism by which we manufacture irrational numbers with prescribed *patterns*: add a lacunary irrational perturbation to a periodic rational pattern. The pattern survives away from the lacunary positions; the irrationality is inherited from the perturbation.

---

## 3. Lacunary witnesses and the grafting operator

### 3.1 The lacunary position set

**Definition 3.1.** Say $m \in \mathbb{N}$ is *lacunary* if $m+1$ is a power of two, and write $\Lambda$ for the set of lacunary positions, $\Lambda = \{0, 1, 3, 7, 15, 31, 63, 127, \dots\}$.

**Lemma 3.2 (Counting bound).** For every $M \ge 0$, $\ \#\big(\Lambda \cap [0,M)\big) \le \log_2 M + 1$ (with $\log_2$ the integer logarithm, and the empty count for $M=0$).

*Proof.* The map $m \mapsto \log_2(m+1)$ is injective on $\Lambda$ (it inverts $m \mapsto 2^{\log_2(m+1)} - 1$) and sends $\Lambda \cap [0,M)$ into $\{0, 1, \dots, \log_2 M\}$, because $m+1 \le M$ forces $\log_2 (m+1) \le \log_2 M$. $\square$

**Lemma 3.3 (Unbounded gaps).** For every $L$ there is an interval of length $L$ of consecutive non-lacunary positions, followed later by a lacunary position. Indeed, between $2^N - 1$ and $2^{N+1} - 1$ there is no lacunary position, and these gaps grow without bound; lacunary positions themselves exist arbitrarily far out, at $2^M - 1$ for every $M$.

Lemmas 3.2 and 3.3 are the two faces of lacunarity: sparse enough for density zero, spread enough for irrationality.

Two elementary logarithm facts will be needed in the autocorrelation section, where exceptional sets get shifted:

**Lemma 3.4.** For $K \ge 1$: $\ \log_2(K+1) \le \log_2 K + 1$, and consequently $\log_2(K + r) \le \log_2 K + r$ for all $r \ge 0$.

*Proof.* $K + 1 \le 2K$ and $\log_2 (2K) = \log_2 K + 1$; then induct on $r$. $\square$

**Lemma 3.5 (Density criteria).** Let $f : \mathbb{N} \to \mathbb{N}$ and $a, c \in \mathbb{N}$.
1. If $f(M) \le a + c \log_2 M$ for all $M \ge 1$, then $f(M)/M \to 0$.
2. If $f(M) \le M$ for all $M$ and $M \le f(M) + a + c\log_2 M$ for all $M \ge 1$, then $f(M)/M \to 1$.

*Proof.* (1) is a squeeze against $c\,(\log_2 M)/M + a/M \to 0$. (2) apply (1) to $g(M) = M - f(M)$ and use $f(M)/M = 1 - g(M)/M$. $\square$

### 3.2 The three primary witnesses

**Definition 3.6.** Define digit sequences and their values:

| name | digit at $m \in \Lambda$ | digit at $m \notin \Lambda$ | value |
|---|---|---|---|
| sparse | $1$ | $0$ | $S = 0.1101000100000001000\ldots$ |
| dense | $2$ | $1$ | $D = 0.2212111211111112111\ldots$ |
| alternating | $2$ if $m$ even, $3$ if $m$ odd | $1$ if $m$ even, $2$ if $m$ odd | $A = 0.2313121312121213121\ldots$ |

All digits used lie in $\{0,1,2,3\}$, so Theorem 2.4 applies and each number's decimal digits are exactly the prescribed sequence.

**Theorem 3.7.** $S$ is irrational, and the density of its nonzero digits is $0$.

*Proof.* Irrationality: by Lemma 3.3 the sequence has arbitrarily long runs of zeros followed by later nonzero digits, so Theorem 2.6 applies. Density: the nonzero digits of $S$ below $M$ are exactly $\Lambda \cap [0,M)$, of size at most $\log_2 M + 1$ by Lemma 3.2, so Lemma 3.5(1) gives density $0$. $\square$

**Theorem 3.8.** $D = S + \tfrac19$; $D$ is irrational; every digit of $D$ is nonzero, so its nonzero-digit density is $1$.

*Proof.* The digit sequence of $D$ is that of $S$ plus the constant sequence $1$, whose value is $\sum_m 10^{-(m+1)} = \tfrac19$; apply Lemma 2.8. Irrationality follows since $S$ is irrational and $\tfrac19$ rational. No digit of $D$ is $0$. $\square$

**Theorem 3.9.** $A = \tfrac{4}{33} + S$ and $A$ is irrational.

*Proof.* The alternating base pattern $1,2,1,2,\dots$ has period $2$, hence by Theorem 2.7 its value is rational; explicitly it equals $0.\overline{12} = 12/99 = 4/33$. The digit sequence of $A$ is the base pattern plus the sparse sequence (each lacunary digit bumped by one), so Lemma 2.8 gives $A = \tfrac4{33} + S$, an irrational plus a rational. $\square$

**Corollary 3.10 (Irrationality does not imply normality).** Call $x$ *simply normal in base ten* if for every digit $c$ the frequency $\#\{m<M : d_m(x)=c\}/M$ tends to $\tfrac1{10}$. Simple normality forces nonzero-digit density $\tfrac9{10}$. Hence neither $S$ (density $0$) nor $D$ (density $1$) is simply normal, although both are irrational.

### 3.3 Grafting

**Definition 3.11.** For $x \ge 0$, $n \in \mathbb{N}$ and $t \in [0,1)$, the *graft* is
$$G(x,n,t) \;=\; \frac{\lfloor x \cdot 10^n \rfloor + t}{10^n}.$$

**Theorem 3.12 (Graft properties).** Let $x \ge 0$, $n \in \mathbb{N}$, $t \in [0,1)$. Then
1. **(prefix)** $d_k\big(G(x,n,t)\big) = d_k(x)$ for every $k < n$;
2. **(tail)** $d_{n+m}\big(G(x,n,t)\big) = d_m(t)$ for every $m \ge 0$;
3. **(irrationality transfer)** $G(x,n,t)$ is irrational if and only if $t$ is;
4. **(proximity)** $\big|G(x,n,t) - x\big| < 10^{-n}$.

*Proof.* (1) Write $n = k+1+j$. A direct computation gives
$$G(x,n,t)\cdot 10^{k+1} = \frac{\lfloor x 10^n\rfloor + t}{10^{j}}, \qquad x \cdot 10^{k+1} = \frac{x \cdot 10^n}{10^{j}} .$$
Since $0 \le t < 1$, $\lfloor \lfloor x 10^n\rfloor + t\rfloor = \lfloor x 10^n \rfloor$, and the identity $\lfloor \alpha / N \rfloor = \lfloor \lfloor \alpha\rfloor / N\rfloor$ for a positive integer $N$ makes both floors equal to $\lfloor x 10^n\rfloor / 10^j$ (integer division). Hence the digits agree at $k$.

(2) Compute $G(x,n,t)\cdot 10^{n+m+1} = t\cdot 10^{m+1} + \lfloor x 10^n\rfloor \cdot 10^{m+1}$. The second summand is an integer divisible by $10$, so taking floors and reducing modulo $10$ leaves $\lfloor t\,10^{m+1}\rfloor \bmod 10 = d_m(t)$.

(3) $G(x,n,t)$ is an integer translate of $t$ divided by the nonzero integer $10^n$; both operations preserve irrationality and rationality.

(4) Both $x$ and $G(x,n,t)$ lie in the interval $\big[\lfloor x 10^n\rfloor 10^{-n}, (\lfloor x 10^n\rfloor + 1)10^{-n}\big)$ of length $10^{-n}$. $\square$

Write $S_{x,n} = G(x,n,S)$, $D_{x,n} = G(x,n,D)$, $A_{x,n} = G(x,n,A)$, $R_{x,n} = G(x,n,0)$ for the four grafts used below.

---

## 4. Prefix indeterminacy for first-order statistics

**Lemma 4.1 (Statistics of the grafts).** For every $x \ge 0$ and $n, M \in \mathbb{N}$:
1. the number of nonzero digits of $S_{x,n}$ below $M$ is at most $n + \log_2 M + 1$;
2. the number of zero digits of $D_{x,n}$ below $M$ is at most $n$;
3. $R_{x,n} = \lfloor x 10^n\rfloor/10^n$ is rational, and all its digits from position $n$ on vanish.

*Proof.* By Theorem 3.12(2) the digits of $S_{x,n}$ at positions $m \ge n$ equal the digits of $S$ at $m - n$, nonzero only when $m-n \in \Lambda$; below $M$ there are at most $\log_2 M + 1$ such $m$ by Lemma 3.2, and at most $n$ positions $m < n$. Similarly the digits of $D_{x,n}$ at $m \ge n$ are digits of $D$, all nonzero, so zeros can only occur among the $n$ prefix positions. (3) is immediate. $\square$

**Theorem 4.2 (No finite prefix determines any digit law).** Let $x \ge 0$ and $n \in \mathbb{N}$. Then there exist real numbers $y, z, w$ with
$$d_k(y) = d_k(z) = d_k(w) = d_k(x) \qquad \text{for all } k < n,$$
such that

* $y$ is irrational and its nonzero-digit density is $0$;
* $z$ is irrational and its nonzero-digit density is $1$;
* $w$ is rational;
* none of $y,z,w$ is simply normal in base ten;
* $d_n(y) = 1$, $d_n(z) = 2$, $d_n(w) = 0$, so the three are pairwise distinct.

*Proof.* Take $y = S_{x,n}$, $z = D_{x,n}$, $w = R_{x,n}$. The prefix statement is Theorem 3.12(1). Irrationality of $y$ and $z$, and rationality of $w$, follow from Theorem 3.12(3) together with Theorems 3.7 and 3.8. The densities follow from Lemma 4.1 and Lemma 3.5: part (1) of the lemma with $a = n+1$, $c = 1$ gives density $0$ for $y$; part (2) with the zero-count bound $n$ gives density $1$ for $z$. Simple normality would force nonzero-digit density $9/10$ (Corollary 3.10), excluded in all three cases. Finally $0 \in \Lambda$, so the digit of each graft at position $n$ is the $0$-th digit of the corresponding tail, namely $1$, $2$ and $0$. $\square$

**Theorem 4.3 (Metric form).** Let $x \ge 0$ and $\varepsilon > 0$. Then there exist an irrational, non-simply-normal $y$ and a rational $w$ with $|y - x| < \varepsilon$ and $|w - x| < \varepsilon$, both agreeing with $x$ in as long a prefix as desired.

*Proof.* Choose $n$ with $10^{-n} < \varepsilon$ and apply Theorem 4.2 together with Theorem 3.12(4). $\square$

Thus the witnesses are not exotic points far away in $\mathbb{R}$; every real number is an accumulation point of witnesses of every type, and the prefix that they share can be made arbitrarily long.

**Theorem 4.4 (Cardinal form).** For every $x \ge 0$ and every $n$, the set
$$\big\{\, y \in \mathbb{R} : d_k(y) = d_k(x) \text{ for all } k < n,\ y \text{ irrational},\ y \text{ not simply normal} \,\big\}$$
is uncountable.

*Proof.* For a bit stream $b = (b_i)_{i \ge 0} \in \{0,1\}^{\mathbb{N}}$ define the digit sequence
$$\beta_b(m) = \begin{cases} 1 & m \in \Lambda \text{ and } b_{\log_2(m+1)} = 1,\\ 2 & m \in \Lambda \text{ and } b_{\log_2(m+1)} = 0,\\ 0 & m \notin \Lambda,\end{cases}$$
and let $B(b) = \mathrm{val}(\beta_b)$. All digits are $\le 8$, so Theorem 2.4 recovers them. Every $\beta_b$ has the same support $\Lambda$ as the sparse sequence, so Lemma 3.3 and Theorem 2.6 make $B(b)$ irrational, and Lemma 3.2 with Lemma 3.5(1) make its nonzero-digit density $0$, hence it is not simply normal. Grafting, $b \mapsto G(x,n,B(b))$ preserves all of these properties (Theorem 3.12) and is injective, because the bit stream can be read back off the digits at the positions $n + (2^i - 1)$. An injection from $\{0,1\}^{\mathbb{N}}$ into the set therefore exhibits it as uncountable — indeed of cardinality the continuum. $\square$

**Corollary 4.5 (The classical constants).** For every $n$, each of $\sqrt 2$, $\pi$ and $e$ admits three numbers sharing its first $n$ decimal digits which are respectively irrational of nonzero-digit density $0$, irrational of nonzero-digit density $1$, and rational, none of them simply normal; and continuum many irrational non-simply-normal numbers share those $n$ digits.

---

## 5. The positive side: irrationality is exactly aperiodicity

The indeterminacy theorems say that irrationality does not constrain asymptotic digit statistics. It is worth stating precisely what it *does* constrain, so that the negative results are correctly calibrated.

**Theorem 5.1 (Periodicity Dichotomy).** Let $x \in [0,1)$. Then $x$ is irrational if and only if its digit sequence $(d_m(x))_{m\ge0}$ is *not* eventually periodic, i.e. there are no $n \ge 0$ and $p \ge 1$ with $d_{m+p}(x) = d_m(x)$ for all $m \ge n$.

*Proof sketch.* ($\Leftarrow$) is Theorem 2.7 in contrapositive form, once one knows $x = \mathrm{val}(d(x))$ for $x \in [0,1)$, which is the standard fact that reading a number's digits and summing them back returns the number.

($\Rightarrow$) Suppose $x = p/q$ is rational. Cutting the expansion at position $k$ replaces $x$ by the fractional part of $10^k x$: precisely, $d_{k+j}(x) = d_j(\{10^k x\})$ for all $j$. The orbit $\{\,\{10^k x\} : k \ge 0\,\}$ consists of rationals with denominator dividing $q$ in $[0,1)$, hence is finite; so there are $k < k'$ with $\{10^k x\} = \{10^{k'} x\}$, and then $d_{m + (k'-k)}(x) = d_m(x)$ for all $m \ge k$. $\square$

**Corollary 5.2.** The sparse witness $S$ is irrational, hence its digit sequence is not eventually periodic — even though $99.99\%$ of its digits, in the limit all of them in density, are zeros. Aperiodicity is compatible with total statistical degeneracy.

Theorem 5.1 draws the line sharply. Irrationality is a statement about *exact repetition of blocks*, a rigid combinatorial property. Normality, digit frequency and autocorrelation are statements about *densities*, which are insensitive to any zero-density modification. The lacunary set $\Lambda$ lives exactly in the gap: modifying a sequence on $\Lambda$ is invisible to densities and lethal to periodicity.

---

## 6. Second-order statistics: autocorrelation indeterminacy

### 6.1 The autocorrelation counting function

Frequency is only the first-order statistic. Empirical "randomness" claims about $\pi$ also concern correlations between digits at a fixed distance.

**Definition 6.1.** For $x \ge 0$ and $r, M \in \mathbb{N}$, put
$$A_r(x,M) \;=\; \#\big\{\, m < M \ : \ d_m(x) = d_{m+r}(x) \,\big\},$$
the *lag-$r$ agreement count*. Say $x$ has *lag-$r$ agreement density* $\alpha$ if $A_r(x,M)/M \to \alpha$ as $M \to \infty$.

For a heuristically "random" digit sequence one expects $\alpha = 1/10$ for every $r \ge 1$. Observe the trivial complementarity $A_r(x,M) + \#\{m<M : d_m(x)\ne d_{m+r}(x)\} = M$, which is what converts an upper bound on the disagreement count into a density-one statement via Lemma 3.5(2).

### 6.2 The exceptional-set lemma

Both grafted witnesses have digits that are governed by a periodic pattern *away from* the prefix and from the lacunary positions. Consequently the positions where an agreement statement can fail are confined to a small, explicitly bounded set — and it is here that the shift by $r$ enters.

**Lemma 6.2 (Exceptional-set bound).** Let $n, r, M \in \mathbb{N}$ with $M \ge 1$, and let $E \subseteq [0,M)$ be a finite set such that every $m \in E$ satisfies
$$m < n \quad\text{or}\quad m - n \in \Lambda \quad\text{or}\quad (m-n) + r \in \Lambda .$$
Then
$$\#E \ \le\ n + \big(\log_2 M + 1\big) + \big(\log_2 M + r + 1\big).$$

*Proof.* Cover $E$ by three sets: the $n$ positions below $n$; the image of $\Lambda \cap [0,M)$ under $p \mapsto n+p$, of size at most $\log_2 M + 1$ by Lemma 3.2; and the image of $\Lambda \cap [0, M+r)$ under $p \mapsto n + p - r$, of size at most $\log_2(M+r) + 1 \le \log_2 M + r + 1$ by Lemmas 3.2 and 3.4. Subadditivity of cardinality under unions and images finishes. $\square$

The appearance of $\log_2(M+r)$ — the second, shifted copy of the lacunary set — is precisely the technical point that makes the lag-$r$ argument nontrivial compared to the frequency argument, and Lemma 3.4 is what tames it. The bound is of the form $a + 2\log_2 M$, so Lemma 3.5 applies with $c = 2$.

### 6.3 The alternating witness has a rigid, lag-dependent correlation profile

**Theorem 6.3.** Let $x \ge 0$ and $n \in \mathbb{N}$, and let $y = A_{x,n} = G(x,n,A)$ be the graft of the alternating witness. Then $y$ is irrational and
$$\lim_{M\to\infty}\frac{A_1(y,M)}{M} = 0, \qquad \lim_{M\to\infty}\frac{A_2(y,M)}{M} = 1 .$$

*Proof.* Irrationality is Theorem 3.9 with Theorem 3.12(3).

*Lag $1$.* Suppose $m \ge n$, and suppose neither $m-n$ nor $(m-n)+1$ is lacunary. Then by Theorem 3.12(2) the digits of $y$ at $m$ and $m+1$ are the *base* alternating digits at $m-n$ and $(m-n)+1$, which are $1$ and $2$ in some order, hence different. So every $m$ counted by $A_1(y,M)$ satisfies $m < n$, or $m - n \in \Lambda$, or $(m-n)+1 \in \Lambda$; Lemma 6.2 with $r=1$ bounds $A_1(y,M) \le n + 4 + 2\log_2 M$, and Lemma 3.5(1) gives density $0$.

*Lag $2$.* Symmetrically, if $m \ge n$ and neither $m-n$ nor $(m-n)+2$ is lacunary, the digits of $y$ at $m$ and $m+2$ are base digits at positions of the same parity, hence *equal*. So every *disagreement* position lies in the exceptional set, which Lemma 6.2 with $r=2$ bounds by $n + 5 + 2\log_2 M$; Lemma 3.5(2) gives agreement density $1$. $\square$

**Theorem 6.4.** Let $x \ge 0$, $n \in \mathbb{N}$ and $z = D_{x,n} = G(x,n,D)$ be the graft of the dense witness. Then $z$ is irrational and for **every** lag $r \ge 0$,
$$\lim_{M\to\infty}\frac{A_r(z,M)}{M} = 1 .$$

*Proof.* If $m \ge n$ and neither $m-n$ nor $(m-n)+r$ is lacunary, then both digits equal $1$, so they agree. Disagreement positions therefore lie in the exceptional set of Lemma 6.2, bounded by $n + r + 3 + 2\log_2 M$, and Lemma 3.5(2) applies. $\square$

### 6.4 The main autocorrelation theorem

**Theorem 6.5 (No finite prefix determines an autocorrelation law).** Let $x \ge 0$ and $n \in \mathbb{N}$. Then there exist **irrational** numbers $y$ and $z$ with
$$d_k(y) = d_k(z) = d_k(x) \qquad \text{for all } k < n,$$
such that

* $y$ has lag-$1$ agreement density $0$ and lag-$2$ agreement density $1$;
* $z$ has agreement density $1$ at every lag $r$.

Consequently neither the value of the autocorrelation at a given lag, nor its functional dependence on the lag, is determined by any finite decimal prefix.

*Proof.* Take $y = A_{x,n}$ and $z = D_{x,n}$ and combine Theorems 3.12, 6.3, 6.4. $\square$

**Corollary 6.6.** Specialising to $x = \sqrt 2$: for every $n$ there are irrational numbers sharing the first $n$ decimal digits of $\sqrt 2$ whose autocorrelation profiles are, respectively, the strongly lag-dependent profile $(0, 1, \dots)$ and the constant profile $1$. The same holds for $\pi$ and $e$.

---

## 7. Algorithms

The constructions are effective, and the following procedures make them so. Throughout, "position" means index into the digit sequence after the decimal point.

**Algorithm A (Lacunary digit generation).** Given a pattern rule and a bound $M$, emit the first $M$ digits of a witness. Membership in $\Lambda$ is tested by the bit trick "$m+1$ is a power of two iff $(m+1)\ \&\ m = 0$", so the whole sequence is produced in $O(M)$ integer operations and $O(1)$ memory beyond the output.

**Algorithm B (Exact grafting).** Given a rational or high-precision approximation $x$, a length $n$ and a witness digit rule, output the grafted number as an exact fraction $\big(\lfloor x 10^n\rfloor \cdot 10^{K} + \text{tail}_K\big)/10^{\,n+K}$ truncated at $K$ tail digits, together with a certified error bound $10^{-(n+K)}$. Cost: $O(n + K)$ digit operations with big-integer arithmetic.

**Algorithm C (Statistic evaluation).** Given a digit array of length $M$, compute the nonzero-digit count, the ten digit frequencies, and the lag-$r$ agreement counts for $r$ in a range $R$, in $O(M\,|R|)$ time. Comparing against the certified bounds $n + \log_2 M + 1$ (nonzero count of the sparse graft) and $n + r + 3 + 2\log_2 M$ (disagreement count of the dense graft) turns the theorems into checkable numerical statements at each finite $M$.

**Algorithm D (Bit-stream witness).** Given a finite bit prefix $b_0,\dots,b_{k-1}$, emit the digits of $B(b)$ up to $M$: digit $1$ or $2$ at position $2^i-1$ according to $b_i$, digit $0$ elsewhere. Distinct bit prefixes are distinguished at position $2^i - 1$, which realises the injection of Theorem 4.4 constructively and shows that the exceptional set of Theorem 4.4 is not only uncountable but *effectively parameterised*.

---

## 8. Numerical illustration

Direct computation with the witness sequences confirms the theorems at accessible scales and shows how tight the bounds are.

**Sparse witness, nonzero-digit count versus the certified bound $\log_2 M + 1$:**

| $M$ | $10$ | $100$ | $1000$ | $10000$ |
|---|---|---|---|---|
| nonzero count | $4$ | $7$ | $10$ | $14$ |
| bound $\log_2 M + 1$ | $4$ | $7$ | $10$ | $14$ |

The bound is attained exactly at these scales: the sparse witness is extremal for the lacunary counting estimate.

**Agreement counts.** For the alternating witness the lag-$1$ agreement count is $0$ at $M = 100$ and $0$ at $M = 1000$ — the anticorrelation is not merely asymptotic, it is total at these scales — while the lag-$2$ agreement counts are $90$ and $984$, i.e. ratios $0.900$ and $0.984$ climbing to $1$. For the dense witness the lag-$1$, lag-$3$ and lag-$7$ agreement counts at $M = 1000$ are $983$, $984$ and $985$: density $1$ at every lag, with the deficits exactly the logarithmically many lacunary collisions.

The two witnesses hence differ in measured autocorrelation at lag $1$ by essentially the maximum possible amount ($0.000$ versus $0.983$ at $M = 1000$) while, after grafting, sharing any prescribed number of leading digits.

---

## 9. Discussion

### 9.1 What the theorems do and do not say

They do **not** say $\pi$ is abnormal, or that its digits are structured. Almost every real is normal; $\pi$ is conjectured to be; every computation is consistent with it. What they say is that the computation cannot be the ground of the belief. The inference "the first $N$ digits are equidistributed, therefore the digits are equidistributed" fails not marginally but catastrophically: the conclusion can be replaced by its extreme negation while the premise is held fixed, for every $N$, by uncountably many witnesses, arbitrarily close to the original number.

### 9.2 Why normality proofs are hard, structurally

Theorem 4.2 explains the shape of the difficulty. A proof that $\sqrt 2$ is normal must use a property of $\sqrt 2$ that is *not* a property of its truncations — its algebraicity, the equation $y^2 = 2$, the dynamics of the orbit $\{10^k\sqrt2\}$ on the circle, or a Diophantine input. Any argument whose only input is "the digits computed so far look like this" is provably insufficient, because the grafts satisfy that input and violate the conclusion.

### 9.3 The role of lacunarity

The set $\Lambda = \{2^i - 1\}$ is chosen to sit in the gap between the two notions:

* *Density-invisible.* Its counting function is $O(\log M)$, so any modification supported on $\Lambda$ changes no asymptotic frequency.
* *Periodicity-lethal.* Its gaps grow geometrically, so the Liouville estimate of Theorem 2.6 forbids the tail from ever being rational.

This is exactly the tension exploited in Theorems 3.7–3.9: the same perturbation that guarantees irrationality is invisible to every density statistic. Note that it is also *sharp* in the sense of the observed data: at $M = 10, 100, 1000, 10000$ the sparse witness's nonzero count equals $\log_2 M + 1$ on the nose.

### 9.4 The autocorrelation half

The autocorrelation results are not a formal restatement of the frequency results. The counting argument genuinely changes: the exceptional positions for lag $r$ are governed by two *shifted* copies of the lacunary set, so one needs the comparison $\log_2(M+r) \le \log_2 M + r$ to keep the bound logarithmic in $M$ uniformly over the lag. Furthermore the alternating witness shows that a fixed number can exhibit *radically different* densities at different lags — $0$ at lag $1$, $1$ at lag $2$ — so no single scalar summarises the correlation structure, and an experimenter measuring lag $1$ alone would draw the opposite conclusion from one measuring lag $2$.

### 9.5 Relation to the classical picture

Nothing here contradicts Borel's theorem (almost every number is normal), nor the known constructions of explicitly normal numbers such as Champernowne's constant $0.123456789101112\ldots$. Those constructions determine their statistics by prescribing the *entire* expansion. Our point is dual: prescribing a *finite* portion determines nothing. The two facts coexist because the space of continuations of a finite word is, as Theorem 4.4 makes precise, of full cardinality and of full statistical variety.

---

## 10. Future directions

**Sub-logarithmic rigidity of lacunary witnesses.** Our witnesses are extremal: the measured nonzero-digit count of the sparse witness equals the proved bound $\log_2 M + 1$ exactly at $M = 10, 100, 1000, 10000$. Conjecture: this is forced — for *any* real whose digit support has counting function $o(\log M)$ the number is rational. The key insight is that a digit support sparser than logarithmic forces gaps so long that the Liouville-type tail estimate degenerates into a transcendence estimate, and the number becomes a Liouville number rather than merely irrational — so the dividing line between "irrational" and "transcendental" for lacunary expansions is a growth condition on the support, not an arithmetic one. The tail estimate transfers verbatim from the head/tail decomposition; only the Liouville exponent bookkeeping is new.

**Prescribed frequency vector at a prescribed prefix.** We realise the nonzero-digit densities $0$ and $1$. Conjecture: for every prefix of every $x \ge 0$ and every probability vector $(p_0,\dots,p_9)$ with rational entries there is an irrational number with that prefix whose digit-$c$ frequency is exactly $p_c$ for all $c$. The key insight is that a Champernowne-style block construction, spliced onto the graft and perturbed at lacunary positions, decouples "which frequencies are attained" (a combinatorial block-length computation) from "is the number irrational" (a gap condition that the lacunary perturbation supplies for free). Grafting already isolates the prefix, and digitwise additivity lets one add a lacunary perturbation to a rational block pattern without recomputing any digit.

**Full autocorrelation spectrum realisation.** We produce a number whose lag-$1$ autocorrelation is $0$ and lag-$2$ autocorrelation $1$. Conjecture: every function $A : \mathbb{N}_{\ge 1} \to \{0,1\}$ that is realisable by a periodic pattern is realisable by an *irrational* number with any prescribed decimal prefix; and the set of realisable autocorrelation profiles is exactly the set of profiles of finite words under the natural equivalence. The alternating witness is the case of the period-two word $12$; a general periodic word of period $p$ should give the profile "$1$ exactly at the lags divisible by the word's period structure", and the lacunary perturbation should again supply irrationality for free.

**Beyond base ten.** Every argument here is base-independent up to replacing "digit $\le 8$" by "digit $\le b-2$" and $\log_2$ by the same integer logarithm; a uniform treatment over all bases $b \ge 2$, and the interaction between prefixes in different bases, is a natural next step.

**Quantitative indeterminacy.** One can ask for the *rate*: given a prefix of length $n$, how far out must one look before two witnesses become statistically distinguishable? Our proofs give explicit thresholds ($n + O(\log M)$ exceptional positions), which suggests a sharp form: the empirical frequency of any witness is determined to within $O((n + \log M)/M)$ by the design, so distinguishing requires $M \gg n$ and nothing more — the prefix's influence on any density decays like $n/M$.

---

## 11. Conclusion

The decimal expansion of a real number carries exactly one piece of information about its arithmetic nature — whether the expansion is eventually periodic — and that piece is invisible to every density statistic. Conversely, every density statistic is invisible to every finite prefix. Formally: for each $x \ge 0$ and each $n$, the fibre of the "first $n$ digits" map contains rationals, contains irrationals with nonzero-digit density $0$, contains irrationals with nonzero-digit density $1$, contains irrationals whose digit autocorrelation vanishes at lag $1$ and is total at lag $2$, contains irrationals whose autocorrelation is total at every lag, and contains continuum many pairwise distinct irrational non-simply-normal numbers besides.

Whatever a computation of the first $n$ digits of $\pi$ reveals, it reveals it about those $n$ digits.
