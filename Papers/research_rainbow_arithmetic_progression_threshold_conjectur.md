# The Rainbow Arithmetic-Progression Threshold: Exact Asymptotics of a Coupon-Collector Transition

**Author:** Aristotle
**Date:** 2026-08-10

---

## Abstract

Let $k \ge 2$ and consider uniformly random $k$-colourings of an interval of integers, decomposed into $m$ consecutive blocks of two adjacent integers. Each block carries one of the $k^2$ ordered colour pairs. Define the **rainbow pair-spectrum threshold** $T_k$ to be the least $m$ for which a strict majority of colourings realises *every* one of the $k^2$ pairs. We prove that $T_k$ has exact first-order asymptotics
$$T_k = 2k^2\log k + O(k^2), \qquad \lim_{k \to \infty}\frac{T_k}{k^2\log k} = 2,$$
with both the limit inferior and the limit superior equal to $2$, and with explicit non-asymptotic constants $c_1 = 1$, $c_2 = 4$ satisfying $c_1 k^2\log k \le T_k \le c_2 k^2 \log k$ for all $k \ge 2$ (and $1.9, 2.2$ respectively for $k \ge 100$). The proofs proceed through a general theory of **full-spectrum thresholds** for words over an arbitrary finite alphabet $\alpha$ with $N = |\alpha|$ letters, for which we establish: (i) an exact binomial-moment identity $\sum_f \binom{\mathrm{miss}(f)}{r} = \binom{N}{r}(N-r)^m$ valid for all orders $r$; (ii) a first-moment (union-bound) sufficient criterion and a second-moment (Cauchy–Schwarz) obstruction, which together sandwich the threshold as $(N-1)\log(N+1) \le T \le N\log(2N) + 1$, i.e. $|T - N\log N| \le N\log 2 + \log N + 1$; (iii) monotonicity of the surjective-majority property in the word length, so that the transition is a genuine phase transition crossed exactly once. We also give the combinatorial dictionary translating full spectra into genuine rainbow arithmetic progressions: when $l \le k$, a full-spectrum block word forces an injectively coloured $l$-term progression, and the corresponding $l$-pattern threshold satisfies $P(l,k) = \Theta(l\,k^l \log k)$ for all $l$. Verified small cases $T_2 \in [6,8]$, $T_3 \in [20,25]$, $T_4 \in [44,54]$ bracket the exact values $7, 23, 51$.

**Keywords.** rainbow Ramsey theory, arithmetic progressions, coupon collector's problem, sharp thresholds, binomial moments, second moment method, Poisson approximation.

---

## 1. Introduction

### 1.1 The question

Rainbow Ramsey theory (also called anti-Ramsey theory) studies conditions forcing a colouring to contain a *totally multicoloured*, or **rainbow**, copy of a prescribed structure. For arithmetic progressions the paradigm question is: given $k$ colours, how long must an interval of integers be before a typical, or every, $k$-colouring contains a rainbow $l$-term arithmetic progression?

We study a quantitatively sharper and more structured variant. Instead of asking for one rainbow progression, we ask for the **full spectrum**: every possible colour pattern on a progression must appear. Concretely, fix $l = 2$, decompose an interval into $m$ consecutive blocks $\{2t, 2t+1\}$, and observe the ordered colour pair on each block. There are $N = k^2$ possible pairs. Define

$$T_k = \min\Bigl\{ m : \text{strictly more than half of all } k\text{-colourings realise all } k^2 \text{ pairs on } [0,2m) \Bigr\}.$$

The conjecture motivating this work asserted $T_k = \Theta(k^2 \log k)$ with computable constants $c_1, c_2$ satisfying $0.1 \le c_1 \le c_2 \le 10$ and
$$\liminf_{k\to\infty} \frac{T_k}{k^2\log k} \ge c_1, \qquad \limsup_{k\to\infty}\frac{T_k}{k^2\log k} \le c_2.$$

We prove considerably more: the limit exists and equals $2$; the optimal constants coincide, $c_1 = c_2 = 2$; and admissible explicit constants are $c_1 = 1$, $c_2 = 4$, valid for all $k \ge 2$.

### 1.2 The reduction

Everything rests on a single reframing. A $k$-colouring of $[0, lm)$, read as $m$ consecutive $l$-term progressions of common difference $1$, is precisely a word of length $m$ over the alphabet of $l$-patterns, of which there are $N = k^l$. "Every pattern appears" is exactly "the word is surjective". Thus the rainbow-AP spectrum question *is* the coupon collector's problem, with the stopping rule "probability of completion exceeds $1/2$" rather than the more familiar expectation.

The classical coupon-collector heuristic gives completion time $N\log N$; with $N = k^2$ this is $k^2\log(k^2) = 2k^2\log k$, and the constant $2$ is nothing but the exponent $l = 2$ escaping from inside a logarithm. Our task is to make this rigorous with a two-sided bound whose error term is $O(N)$, a factor $\log N$ below the main term.

### 1.3 Organisation and summary of results

Section 2 sets up the general full-spectrum framework over an arbitrary finite alphabet. Section 3 proves the exact binomial-moment identity of all orders. Section 4 derives the two majority criteria. Section 5 proves monotonicity, establishing that the transition is genuine. Section 6 converts the criteria into analytic bounds and gives the sharp window. Section 7 specialises to pairs and proves the main asymptotic theorem. Section 8 gives verified small cases and numerics. Section 9 supplies the combinatorial dictionary back to rainbow progressions and the general $l$-pattern threshold. Section 10 discusses the second-order constant and a conjectural Poisson limit law. Section 11 lists future directions.

---

## 2. The full-spectrum framework

Throughout, $\alpha$ is a finite set (the **alphabet**) with $N = |\alpha| \ge 1$ letters, and $m \ge 0$ is an integer. A **word of length $m$** is a function $f : \{0,1,\dots,m-1\} \to \alpha$. There are $N^m$ words.

**Definition 2.1 (Missed letters).** For a word $f$ of length $m$, the set of missed letters is
$$\mathrm{Miss}(f) = \{ a \in \alpha : f(x) \ne a \text{ for all } x \},$$
and $\mathrm{miss}(f) = |\mathrm{Miss}(f)|$ is the **missed-letter count**.

**Lemma 2.2 (Full spectrum $=$ surjectivity).** $\mathrm{miss}(f) = 0$ if and only if $f$ is surjective.

*Proof sketch.* If $f$ is not surjective some $a$ is omitted, and that $a$ lies in $\mathrm{Miss}(f)$, which is therefore nonempty. Conversely if $\mathrm{Miss}(f)$ is nonempty, any of its elements is omitted. $\square$

**Definition 2.3 (Deficient words).** The set of **deficient** (non-surjective) words of length $m$ is
$$\mathcal{D}_m = \{ f : \mathrm{miss}(f) > 0 \}, \qquad D_m = |\mathcal{D}_m|,$$
and the set of **full-spectrum** words is $\mathcal{S}_m = \{f : \mathrm{miss}(f) = 0\}$, $S_m = |\mathcal{S}_m|$. Clearly $S_m + D_m = N^m$.

**Definition 2.4 (Full-spectrum threshold).** The **full-spectrum threshold** of $\alpha$ is
$$T(\alpha) = \min\{ m \ge 0 : 2 D_m < N^m \},$$
the least word length at which a strict majority of words is surjective. (Section 5 shows the defining set is upward closed, so the minimum is a genuine threshold; Section 6 shows it is nonempty for $N \ge 2$.)

Two elementary counting lemmas are used repeatedly.

**Lemma 2.5 (Avoiding a set).** For a set $S \subseteq \alpha$ with $|S| = r$, the number of words of length $m$ avoiding every letter of $S$ is $(N - r)^m$.

*Proof sketch.* Such words are exactly the words over the alphabet $\alpha \setminus S$, which has $N - r$ letters; the count of words of length $m$ over an $M$-letter alphabet is $M^m$. $\square$

**Lemma 2.6 (Subset criterion).** For a word $f$ and a set $S \subseteq \alpha$: $S \subseteq \mathrm{Miss}(f)$ if and only if $f(x) \notin S$ for all positions $x$.

*Proof sketch.* Both sides say "no position of $f$ carries a letter of $S$". $\square$

---

## 3. Exact moments of all orders

The engine of the whole theory is that every binomial moment of $\mathrm{miss}$ is exactly computable.

**Theorem 3.1 (Binomial Moment Identity).** For every $r \ge 0$ and every $m \ge 0$,
$$\sum_{f : \{0,\dots,m-1\} \to \alpha} \binom{\mathrm{miss}(f)}{r} \;=\; \binom{N}{r}\,(N - r)^m .$$

*Proof.* Both sides count the set
$$\mathcal{P} = \bigl\{ (f, S) : f \text{ a word of length } m,\; S \subseteq \alpha,\; |S| = r,\; S \subseteq \mathrm{Miss}(f) \bigr\}.$$
Fixing $f$ and counting the admissible $S$ gives $\binom{|\mathrm{Miss}(f)|}{r} = \binom{\mathrm{miss}(f)}{r}$, and summing over $f$ yields the left side. Fixing $S$ first: there are $\binom{N}{r}$ choices of an $r$-element subset $S$, and by Lemmas 2.5 and 2.6 the words $f$ with $S \subseteq \mathrm{Miss}(f)$ are exactly the words avoiding $S$, of which there are $(N-r)^m$. This yields the right side. $\square$

**Corollary 3.2 (First moment).** $\displaystyle \sum_f \mathrm{miss}(f) = N (N-1)^m .$

*Proof sketch.* Case $r = 1$, since $\binom{n}{1} = n$ and $\binom{N}{1} = N$. $\square$

**Corollary 3.3 (Second moment).** $\displaystyle \sum_f \mathrm{miss}(f)^2 = N(N-1)^m + N(N-1)(N-2)^m .$

*Proof sketch.* Combine $r = 1$ and $r = 2$ with the pointwise identity $n^2 = 2\binom{n}{2} + n$ (proved by induction on $n$, using $\binom{n+1}{2} = \binom{n}{2} + n$). One obtains
$$\sum_f \mathrm{miss}(f)^2 = 2\binom{N}{2}(N-2)^m + N(N-1)^m = N(N-1)(N-2)^m + N(N-1)^m. \square$$

An independent, direct proof of Corollary 3.3 goes by expanding $\mathrm{miss}(f)^2 = \sum_{a}\sum_{b} \mathbf 1[f \text{ avoids } a \text{ and } b]$, exchanging the order of summation, and splitting the inner sum into the diagonal terms $b = a$ (contributing $(N-1)^m$ each) and the $N-1$ off-diagonal terms (contributing $(N-2)^m$ each).

### 3.1 Probabilistic reading

Dividing Theorem 3.1 by $N^m$, for a uniformly random word $f$ of length $m$,
$$\mathbb{E}\binom{\mathrm{miss}}{r} = \binom{N}{r}\Bigl(1 - \frac r N\Bigr)^m .$$
With $m = N\log N + cN$ and $r$ fixed, as $N \to \infty$,
$$\binom{N}{r}\Bigl(1-\frac rN\Bigr)^m \sim \frac{N^r}{r!} e^{-rm/N} = \frac{1}{r!}\bigl(N e^{-m/N}\bigr)^r \to \frac{(e^{-c})^r}{r!},$$
which is exactly the $r$-th binomial moment of a Poisson random variable of mean $\lambda = e^{-c}$. Thus the missed-letter count is asymptotically $\mathrm{Poisson}(Ne^{-m/N})$, and the probability of full spectrum is asymptotically $\exp(-Ne^{-m/N})$. This heuristic predicts everything proved below, and more (Section 10).

---

## 4. Two majority criteria

### 4.1 First moment: a sufficient condition for full spectrum

**Lemma 4.1 (Union bound).** $D_m \le N(N-1)^m$.

*Proof.* Every deficient word satisfies $\mathrm{miss}(f) \ge 1$, so
$$D_m = \sum_{f \in \mathcal{D}_m} 1 \;\le\; \sum_{f \in \mathcal{D}_m} \mathrm{miss}(f) \;=\; \sum_{f} \mathrm{miss}(f) \;=\; N(N-1)^m,$$
where the middle equality holds because words outside $\mathcal{D}_m$ contribute $\mathrm{miss}(f) = 0$. $\square$

**Theorem 4.2 (Union-bound criterion).** If $2N(N-1)^m < N^m$, then $2D_m < N^m$: a strict majority of words of length $m$ has full spectrum.

*Proof.* $2D_m \le 2N(N-1)^m < N^m$ by Lemma 4.1. $\square$

### 4.2 Second moment: an obstruction

**Lemma 4.3 (Cauchy–Schwarz).** $\bigl(\sum_f \mathrm{miss}(f)\bigr)^2 \le D_m \cdot \sum_f \mathrm{miss}(f)^2$.

*Proof.* Since $\mathrm{miss}$ vanishes off $\mathcal{D}_m$, the left side equals $\bigl(\sum_{f \in \mathcal{D}_m}\mathrm{miss}(f)\bigr)^2$, which by Cauchy–Schwarz is at most $|\mathcal{D}_m| \sum_{f\in\mathcal{D}_m}\mathrm{miss}(f)^2 \le D_m \sum_f \mathrm{miss}(f)^2$. $\square$

**Theorem 4.4 (Second-moment criterion).** Let $N \ge 2$. If $N^m < (N+1)(N-1)^m$, then $N^m < 2D_m$: a strict majority of words of length $m$ is deficient.

*Proof.* Write $A = (N-1)^m$, $B = (N-2)^m$. By Corollaries 3.2–3.3 and Lemma 4.3,
$$(NA)^2 \le D_m\bigl(NA + N(N-1)B\bigr). \tag{4.1}$$
Two elementary estimates:

1. **$N^m B \le A^2$.** Indeed $N^m B = \bigl(N(N-2)\bigr)^m$ and $A^2 = \bigl((N-1)^2\bigr)^m$, and $N(N-2) = (N-1)^2 - 1 \le (N-1)^2$.
2. **$N^m A < (N+1)A^2$.** Multiply the hypothesis $N^m < (N+1)A$ by $A > 0$.

Combining,
$$N^m\bigl(NA + N(N-1)B\bigr) = N\cdot N^mA + N(N-1)\cdot N^m B < N(N+1)A^2 + N(N-1)A^2 = 2N^2A^2 = 2(NA)^2 .$$
Multiplying (4.1) by $N^m$ and comparing,
$$N^m (NA)^2 \le D_m \cdot N^m\bigl(NA + N(N-1)B\bigr) < D_m \cdot 2 (NA)^2 ,$$
and dividing by $(NA)^2 > 0$ gives $N^m < 2 D_m$. $\square$

The two criteria are complementary: the first is a first-moment upper bound on deficiency, the second a second-moment lower bound, and they differ only in the constants inside the logarithm once translated to word lengths (Section 6).

---

## 5. The transition is genuine

Definition 2.4 takes a minimum, which is a threshold only if the surjective-majority property is upward closed in $m$. It is, by a clean injection.

**Lemma 5.1 (Extension injection).** $N \cdot S_m \le S_{m+1}$.

*Proof.* Consider the map $(a, f) \mapsto f{\cdot}a$ that appends the letter $a$ to the word $f$, defined on $\alpha \times \mathcal{S}_m$. If $f$ is surjective then so is $f{\cdot}a$ (every letter attained by $f$ is still attained). The map is injective: from $f{\cdot}a$ one recovers $a$ as the last letter and $f$ by restriction. Hence $|\alpha \times \mathcal S_m| = N S_m \le |\mathcal S_{m+1}| = S_{m+1}$. $\square$

**Lemma 5.2 (One-step propagation).** Let $N \ge 1$. If $2 D_m < N^m$ then $2 D_{m+1} < N^{m+1}$.

*Proof.* From $S_m + D_m = N^m$ and $2D_m < N^m$ we get $N^m < 2 S_m$. Multiply by $N > 0$ and apply Lemma 5.1:
$$N^{m+1} = N\cdot N^m < 2 N S_m \le 2 S_{m+1} .$$
Since $S_{m+1} + D_{m+1} = N^{m+1}$, this rearranges to $2 D_{m+1} < N^{m+1}$. $\square$

**Theorem 5.3 (Monotonicity).** Let $N \ge 1$ and $m \le m'$. If $2D_m < N^m$, then $2D_{m'} < N^{m'}$.

*Proof sketch.* Induct on $m'$, using Lemma 5.2 at each step. $\square$

**Theorem 5.4 (Genuine phase transition).** Let $N \ge 2$ and suppose the defining set of Definition 2.4 is nonempty (guaranteed by Corollary 6.3). Then for every $m$,
$$2 D_m < N^m \iff m \ge T(\alpha).$$

*Proof.* ($\Rightarrow$) is the definition of a minimum. ($\Leftarrow$): $T(\alpha)$ itself lies in the set (minimum of a nonempty set of naturals), and Theorem 5.3 propagates the property upward from $T(\alpha)$ to $m$. $\square$

Thus the full-spectrum property crosses the one-half probability level exactly once, and $T(\alpha)$ is the location of that unique crossing.

---

## 6. Analytic bounds: the sharp window

We now convert Theorems 4.2 and 4.4 into bounds on the threshold.

**Lemma 6.1 (Lower criterion in analytic form).** Let $N \ge 2$ and let $m$ be an integer with $m < (N-1)\log(N+1)$. Then $N^m < (N+1)(N-1)^m$.

*Proof.* Let $x = N/(N-1) > 1$. Since $\log t \le t - 1$ for $t > 0$, we get $\log x \le x - 1 = 1/(N-1)$. Hence
$$m \log x \le \frac{m}{N-1} < \log(N+1),$$
using the hypothesis. Exponentiating, $x^m < N+1$, i.e. $N^m/(N-1)^m < N+1$, which is the claim. $\square$

**Lemma 6.2 (Upper criterion in analytic form).** Let $N \ge 2$ and let $m$ be an integer with $m > N\log(2N)$. Then $2N(N-1)^m < N^m$.

*Proof.* Since $1 + t \le e^t$ with $t = -1/N$,
$$\frac{N-1}{N} = 1 - \frac 1N \le e^{-1/N}, \quad\text{so}\quad \Bigl(\frac{N-1}{N}\Bigr)^m \le e^{-m/N}.$$
The hypothesis gives $m/N > \log(2N)$, hence $e^{-m/N} < e^{-\log(2N)} = 1/(2N)$. Therefore $(N-1)^m/N^m < 1/(2N)$, i.e. $2N(N-1)^m < N^m$. $\square$

**Corollary 6.3 (Nonemptiness).** For $N \ge 2$ the set $\{m : 2D_m < N^m\}$ is nonempty; indeed it contains $\lfloor N\log(2N)\rfloor + 1$.

*Proof sketch.* That integer exceeds $N\log(2N)$, so Lemma 6.2 and Theorem 4.2 apply. $\square$

**Theorem 6.4 (Two-sided bound).** For every finite alphabet with $N \ge 2$ letters,
$$(N-1)\log(N+1) \;\le\; T(\alpha) \;\le\; N \log(2N) + 1 .$$

*Proof.* *Upper bound.* Put $M = \lfloor N\log(2N)\rfloor + 1$. By Corollary 6.3, $T(\alpha) \le M \le N\log(2N) + 1$.

*Lower bound.* Suppose for contradiction $T(\alpha) < (N-1)\log(N+1)$. By Theorem 5.4 (or directly by minimality) we have $2D_{T} < N^{T}$ at $m = T := T(\alpha)$. But Lemma 6.1 applies at $m = T$, so Theorem 4.4 gives $N^{T} < 2D_{T}$ — a contradiction. $\square$

**Lemma 6.5.** For $N \ge 2$, $\log(N+1) \le \log N + 1$.

*Proof sketch.* $\log\frac{N+1}{N} \le \frac{N+1}{N} - 1 = \frac1N \le 1$. $\square$

**Theorem 6.6 (Sharp window).** For every finite alphabet with $N \ge 2$ letters,
$$\bigl| T(\alpha) - N\log N \bigr| \;\le\; N\log 2 + \log N + 1 .$$

*Proof.* From Theorem 6.4 and $\log(2N) = \log 2 + \log N$,
$$T(\alpha) \le N\log N + N\log 2 + 1,$$
giving the upper half. For the lower half, using $\log N \le \log(N+1)$ and Lemma 6.5,
$$(N-1)\log(N+1) \ge (N-1)\log N \ge N\log N - \log N,$$
hence $T(\alpha) \ge N\log N - \log N - 1$, and a fortiori $T(\alpha) \ge N\log N - (N\log 2 + \log N + 1)$. $\square$

The error term $N\log 2 + O(\log N)$ is $O(N)$, i.e. a factor $\log N$ below the main term $N\log N$; this is exactly what pins the leading constant.

---

## 7. The rainbow pair-spectrum threshold

**Definition 7.1.** For $k \ge 2$, let $T_k = T(\alpha)$ for the alphabet $\alpha$ of ordered colour pairs, so $N = |\alpha| = k^2$.

**Theorem 7.2 (Lower bound).** For all $k \ge 2$, $\;2k^2\log k - 2\log k \le T_k$.

*Proof.* Theorem 6.4 with $N = k^2$ gives $T_k \ge (k^2-1)\log(k^2+1)$. Since $\log(k^2+1) \ge \log(k^2) = 2\log k \ge 0$ and $k^2 - 1 \ge 1$,
$$(k^2-1)\log(k^2+1) \ge (k^2-1)\cdot 2\log k = 2k^2\log k - 2\log k. \square$$

**Theorem 7.3 (Upper bound).** For all $k \ge 2$, $\; T_k \le 2k^2\log k + k^2\log 2 + 1$.

*Proof.* Theorem 6.4 with $N = k^2$ gives $T_k \le k^2\log(2k^2) + 1 = k^2(\log 2 + 2\log k) + 1$. $\square$

**Theorem 7.4 (Sharp window for $T_k$).** For all $k \ge 2$,
$$\bigl|T_k - 2k^2\log k\bigr| \le k^2\log 2 + 2\log k + 1 .$$

*Proof.* Immediate from Theorems 7.2 and 7.3, both errors being nonnegative. $\square$

**Theorem 7.5 ($\Theta(k^2\log k)$ with explicit constants).** There exist constants $c_1 = 1$ and $c_2 = 4$ with $0.1 \le c_1 \le c_2 \le 10$ such that for all $k \ge 2$,
$$c_1\,k^2\log k \;\le\; T_k \;\le\; c_2\,k^2\log k .$$

*Proof.* *Lower.* By Theorem 7.2, $T_k \ge 2k^2\log k - 2\log k = k^2\log k + (k^2 - 2)\log k \ge k^2\log k$, since $k \ge 2$ implies $k^2 \ge 4 > 2$ and $\log k > 0$.

*Upper.* By Theorem 7.3 and $\log 2 \le \log k$ for $k \ge 2$, and $1 \le k^2\log k$ (since $k^2 \ge 4$ and $\log k \ge 0.69$),
$$T_k \le 2k^2\log k + k^2\log 2 + 1 \le 2k^2\log k + k^2\log k + k^2\log k = 4k^2\log k. \square$$

**Theorem 7.6 (Exact asymptotic constant).** $\displaystyle \lim_{k \to \infty}\frac{T_k}{k^2\log k} = 2$.

*Proof.* Dividing Theorems 7.2 and 7.3 by $k^2\log k > 0$ for $k \ge 2$,
$$2 - \frac{2}{k^2} \;\le\; \frac{T_k}{k^2\log k} \;\le\; 2 + \frac{\log 2}{\log k} + \frac{1}{k^2\log k}.$$
Both bounding sequences tend to $2$ (each error term tends to $0$ since $k^2 \to \infty$, $\log k \to \infty$, $k^2\log k \to \infty$). The squeeze theorem concludes. $\square$

**Corollary 7.7 (Limit inferior and superior).**
$$\liminf_{k\to\infty}\frac{T_k}{k^2\log k} = \limsup_{k\to\infty}\frac{T_k}{k^2\log k} = 2 .$$

*Proof sketch.* A convergent sequence has limit inferior and limit superior equal to its limit. $\square$

In particular the optimal constants of the original conjecture coincide: $c_1 = c_2 = 2$, and the demanded range $0.1 \le c_1 \le c_2 \le 10$ holds with room to spare.

**Theorem 7.8 (Sharpened constants for large $k$).** For all $k \ge 100$,
$$1.9\,k^2\log k \;\le\; T_k \;\le\; 2.2\,k^2\log k .$$

*Proof sketch.* For $k \ge 100$ one has $k^2 \ge 10^4$ and $\log k \ge 6\log 2 \approx 4.16$. The lower bound follows from $T_k \ge 2k^2\log k - 2\log k$ since $2\log k \le 0.1 k^2 \log k$ once $k^2 \ge 20$. For the upper bound, $T_k \le 2k^2\log k + k^2\log 2 + 1$ and $\log 2 \le \tfrac{1}{6}\log k \le 0.2 \log k$, while $1 \le 0.001 k^2 \log k$; summing, $T_k \le 2.2 k^2\log k$. $\square$

---

## 8. Small cases and numerical evidence

The two criteria, being purely arithmetic inequalities on integers, can be checked for concrete $k$ and $m$ by direct numeral computation. Combined with monotonicity (Theorem 5.4) they bracket $T_k$ exactly.

**Proposition 8.1 (Numerical criteria).** For $k \ge 2$ and $m \ge 0$:
- if $2k^2(k^2-1)^m < (k^2)^m$ then $T_k \le m$;
- if $(k^2)^m < (k^2+1)(k^2-1)^m$ then $m < T_k$.

*Proof sketch.* The first is Theorem 4.2 plus minimality; the second is Theorem 4.4 plus Theorem 5.4 (if $T_k \le m$, the majority would be surjective at $m$, contradicting the second-moment criterion). $\square$

**Theorem 8.2 (Verified windows).**
$$6 \le T_2 \le 8, \qquad 20 \le T_3 \le 25, \qquad 44 \le T_4 \le 54 .$$

*Proof sketch.* Apply Proposition 8.1 at $(k,m) = (2,5)$ and $(2,8)$; $(3,19)$ and $(3,25)$; $(4,43)$ and $(4,54)$; each inequality is a comparison of explicit integers. $\square$

Direct inclusion–exclusion, using $S_m = \sum_{j=0}^{N}(-1)^j\binom{N}{j}(N-j)^m$, gives the exact values, which lie inside these windows:

| $k$ | $N = k^2$ | $T_k$ | $T_k/(k^2\log k)$ | $(T_k - N\log N)/N$ |
|---|---|---|---|---|
| 2 | 4 | 7 | 2.525 | 0.3637 |
| 3 | 9 | 23 | 2.326 | 0.3583 |
| 4 | 16 | 51 | 2.299 | 0.4149 |
| 5 | 25 | 90 | 2.237 | 0.3811 |
| 6 | 36 | 142 | 2.201 | 0.3609 |
| 7 | 49 | 209 | 2.192 | 0.3735 |
| 8 | 64 | 290 | 2.179 | 0.3724 |

The fourth column decreases towards $2$ at the predicted rate $O(1/\log k)$. The fifth column is essentially constant near $0.366$, which is $\log(1/\log 2) = 0.36651\ldots$; see Section 10.

---

## 9. From full spectra to genuine rainbow progressions

We now make explicit the combinatorial content of the alphabet.

**Definition 9.1 (Block word).** Fix $k, l, m$ and a colouring $\chi : \mathbb{N} \to \{0,\dots,k-1\}$. The **block word** of $\chi$ is the word $W_\chi$ of length $m$ over the alphabet of $l$-patterns (functions $\{0,\dots,l-1\} \to \{0,\dots,k-1\}$, of which there are $k^l$) defined by
$$W_\chi(t) : j \longmapsto \chi(lt + j), \qquad 0 \le t < m,\; 0 \le j < l.$$
The $t$-th letter of $W_\chi$ records the colours of the $l$-term progression $lt, lt+1, \dots, lt+l-1$ of common difference $1$.

**Theorem 9.2 (Full spectrum forces a rainbow block).** Suppose $l \le k$. If a word $f$ of length $m$ over the $l$-pattern alphabet is surjective, then some letter $f(t)$ is an **injective** pattern.

*Proof.* Since $l \le k$, the pattern $p : j \mapsto j$ (interpreting each index $j < l \le k$ as a colour) is a legitimate letter of the alphabet, and it is injective. Surjectivity of $f$ produces a position $t$ with $f(t) = p$. $\square$

**Theorem 9.3 (Rainbow arithmetic progression).** Suppose $1 \le l \le k$ and $\chi$ is a $k$-colouring whose block word $W_\chi$ (of length $m$) has full spectrum. Then $\chi$ contains a rainbow $l$-term arithmetic progression inside $[0, lm)$: there exist $a$ and $d > 0$ with $a + (l-1)d < lm$ such that $j \mapsto \chi(a + jd)$ is injective on $\{0,\dots,l-1\}$.

*Proof.* By Theorem 9.2 choose $t < m$ with $W_\chi(t)$ injective. Take $a = lt$ and $d = 1$. Then $\chi(a + j\cdot 1) = \chi(lt+j) = W_\chi(t)(j)$, which is injective in $j$. The range condition holds since $a + (l-1) = lt + l - 1 = l(t+1) - 1 \le lm - 1 < lm$. $\square$

**Theorem 9.4 (Majority of colourings contain a rainbow progression).** Let $l \le k$, write $N = k^l$, and let $\mathcal{R}_m$ be the set of words of length $m$ over the $l$-pattern alphabet possessing an injective letter. If $2N(N-1)^m < N^m$, then
$$N^m < 2\,|\mathcal{R}_m| ,$$
i.e. a strict majority of all $k$-colourings of $[0, lm)$ contains a rainbow $l$-term progression there.

*Proof.* By Theorem 9.2, every surjective word lies in $\mathcal R_m$, so $\mathcal D_m \cup \mathcal R_m$ is all of the word space and $N^m \le D_m + |\mathcal R_m|$. The hypothesis and Theorem 4.2 give $2D_m < N^m$, so $N^m \le D_m + |\mathcal{R}_m| < \tfrac12 N^m + |\mathcal R_m|$, whence $N^m < 2|\mathcal R_m|$. $\square$

**Definition 9.5 ($l$-pattern threshold).** For $l, k$ with $k^l \ge 2$, let $P(l,k) = T(\alpha)$ for the alphabet of $l$-patterns, so $N = k^l$.

**Theorem 9.6 (Bounds across all pattern lengths).** If $k^l \ge 2$ then
$$(k^l - 1)\log(k^l + 1) \;\le\; P(l,k) \;\le\; k^l \log(2 k^l) + 1 .$$
In particular $P(l,k) = \Theta\bigl(k^l\log(k^l)\bigr) = \Theta\bigl(l\,k^l\log k\bigr)$ for each fixed $l \ge 2$, and $P(2,k) = T_k$ recovers the $\Theta(k^2\log k)$ regime.

*Proof sketch.* Theorem 6.4 with $N = k^l$. $\square$

Since a colouring covered by the $l$-pattern threshold occupies an interval of $l\,P(l,k)$ integers, the *interval length* forcing a rainbow $l$-term progression in a typical $k$-colouring is $\Theta(l^2 k^l \log k)$. For $l = 2$ this is $\Theta(k^2\log k)$; for $l = k$ it is $\Theta(k^3 k^k \log k)$.

---

## 10. Discussion: the second-order constant

The proved window (Theorem 6.6) has width $N\log 2 + O(\log N) \approx 0.693\,N$. Within it, the numerics of Section 8 place the truth at $N\log N + 0.3665\,N$, extremely stably across $k$. The Poisson heuristic of Section 3.1 explains this exactly: if $\mathrm{miss}$ is $\mathrm{Poisson}(\lambda)$ with $\lambda = Ne^{-m/N}$, then
$$\mathbb{P}(\text{full spectrum}) \approx e^{-\lambda} = \exp\bigl(-N e^{-m/N}\bigr),$$
which crosses $1/2$ precisely when $Ne^{-m/N} = \log 2$, i.e. at
$$m = N\log N + N\log\frac{1}{\log 2}, \qquad \log\frac{1}{\log 2} = 0.366513\ldots$$

Note the contrast with what a union bound alone can see: the first-moment criterion fires at $m \approx N\log N + N\log 2 = N\log N + 0.693\,N$, and the second-moment criterion stops obstructing at $m \approx N\log N$. The true constant $\log(1/\log 2)$ lies strictly between $0$ and $\log 2$; it is invisible to a union bound and to a bare Cauchy–Schwarz, but it is fully determined by the exact moment identity of Theorem 3.1.

Closing this gap should require only a Bonferroni expansion of order $3$: the inclusion–exclusion inequalities
$$\sum_{r=1}^{2j}(-1)^{r-1}\binom{N}{r}\Bigl(1-\frac rN\Bigr)^m \;\le\; \mathbb{P}(\mathrm{miss} \ge 1) \;\le\; \sum_{r=1}^{2j+1}(-1)^{r-1}\binom{N}{r}\Bigl(1-\frac rN\Bigr)^m$$
follow from Theorem 3.1 by the Bonferroni inequalities, and taking $j = 1$ already localises the crossing to $m = N\log N + N\log(1/\log 2) + O(\log N)$.

An even stronger conclusion is within reach: the *method of moments* applied to Theorem 3.1 in full generality should give a Poisson **limit law**, not merely a threshold. See Conjecture 2 in Section 11.

### 10.1 Relation to the classical coupon collector

The classical coupon-collector theorem states that the number of draws $C_N$ to collect all $N$ coupons satisfies $\mathbb E C_N = N H_N \sim N\log N$ and $\mathbb{P}(C_N > N\log N + cN) \to 1 - \exp(-e^{-c})$. Our $T(\alpha)$ is the **median** of $C_N$ rather than its mean, so it is located at $c = \log(1/\log 2)$ rather than at $c = \gamma$ (Euler's constant, $0.5772\ldots$, the mean correction). Theorem 6.6 is a fully explicit, non-asymptotic median bound, valid for every $N \ge 2$ rather than in a limit — which is what allows the rainbow application to carry explicit constants for every $k \ge 2$.

### 10.2 Why the constant is exactly $2$

It is worth emphasising the structural reason for the constant. The alphabet of pairs has $N = k^2$ letters, so the coupon-collector time is $N\log N = k^2 \cdot 2\log k$. The factor $2$ is the pattern length $l$, exiting from the exponent of $k^l$ via the logarithm. Theorem 9.6 makes this uniform: the leading constant of $P(l,k)$ in units of $k^l\log k$ is exactly $l$. Nothing about the rainbow condition itself enters the leading constant; the arithmetic structure of progressions enters only through the size of the pattern alphabet.

---

## 11. Future directions

**Conjecture 1 (Second-order constant; sharp median of the transition).** For a finite alphabet with $N$ letters,
$$T(\alpha) = N\log N + N\log\frac{1}{\log 2} + O(\log N),$$
equivalently
$$\Bigl| T_k - 2k^2\log k - k^2\log\frac{1}{\log 2}\Bigr| = O(\log k).$$
The key insight is that the number of missed letters is asymptotically Poisson with mean $Ne^{-m/N}$, so the majority threshold is located exactly where that mean equals $\log 2$, which pins the second-order term to $\log(1/\log 2) = 0.36651\ldots$ rather than to the $\log 2 = 0.69314\ldots$ that a union bound can see. The proved window already has width $N\log 2 + O(\log N)$, and the numerics sit at $0.3665N$ inside it; closing the gap requires only upgrading the Cauchy–Schwarz step to a Bonferroni expansion of order $3$, all of whose ingredients — the exact moment identities — are established here.

**Conjecture 2 (Poisson limit law, not just a threshold).** For $m = N\log N + cN$, the number of missed letters converges in distribution to $\mathrm{Poisson}(e^{-c})$; consequently
$$\frac{\#\{\text{full-spectrum words of length } m\}}{N^m} \longrightarrow \exp(-e^{-c}) \quad\text{as } N \to \infty.$$
The key insight is that the falling-factorial moments computed here extend to all orders as $\sum_f (\mathrm{miss}(f))_r = N^{(r)}(N-r)^m$, which is exactly the method of moments for a Poisson limit. The order-1 and order-2 identities are established and their proofs are uniform in the number of excluded letters, so the general identity is a direct induction; this would turn a threshold statement into a limit-law statement, the strongest form of the result.

**Conjecture 3 (Rainbow AP thresholds across all lengths: a single formula).** For $2 \le l \le k$,
$$P(l,k) = k^l\Bigl(l\log k + \log\frac{1}{\log 2}\Bigr) + O(l\log k),$$
and the least interval length forcing a rainbow $l$-term progression in a *typical* $k$-colouring is $l\,P(l,k) = \Theta(l^2 k^l \log k)$. In particular the $\Theta(k^2\log k)$ regime is exactly the case $l = 2$, and $l = k$ gives the doubly-exponential-looking $\Theta(k^3 k^k\log k)$. The key insight is that the rainbow-AP problem stratifies by pattern length: the alphabet of patterns has size $k^l$, so a single coupon-collector estimate — the one proved here uniformly in the alphabet — governs the entire hierarchy.

**Further directions.**
1. *Progressions of general common difference.* Our block decomposition uses difference $d = 1$ and disjoint blocks, which makes the pattern word a sequence of independent letters. Allowing all common differences inside an interval of length $n$ raises the number of available progressions from $n/l$ to $\Theta(n^2/l)$, but these overlap heavily and are far from independent. Quantifying the resulting saving — presumably via a second-moment computation over the dependency graph of overlapping progressions — would give the true threshold interval length, which is at most the $\Theta(l^2k^l\log k)$ obtained here and plausibly much smaller.
2. *Every colouring rather than a typical one.* The worst-case rainbow-AP problem (rainbow van der Waerden numbers) has no coupon-collector reduction; understanding how far the typical bound is from the extremal one is open even for $l = 3$.
3. *Concentration.* The window of Theorem 6.6 is $O(N)$; the true transition width, by the Poisson limit, should be $\Theta(N)$ as well (the transition is *not* sharp in the ratio sense: it takes $\Theta(N)$ additional letters to move the completion probability from $\epsilon$ to $1-\epsilon$). Making this precise, with matching constants, is Conjecture 2.
4. *Non-uniform palettes.* If colour $i$ has probability $p_i$, the missed-letter count has $r$-th binomial moment $\sum_{|S| = r}(1 - p_S)^m$ with $p_S = \sum_{i \in S}p_i$; the threshold becomes $\max_i p_i^{-1}\log(\cdot)$-driven, and the pair alphabet inherits products $p_ip_j$. Determining the exact leading constant in this weighted setting would cover biased random colourings.

---

## 12. Conclusion

By recasting the rainbow arithmetic-progression spectrum problem as a coupon-collector problem over the alphabet of colour patterns, we obtained exact first-order asymptotics for the pair-spectrum threshold:
$$T_k = 2k^2\log k + O(k^2), \qquad \frac{T_k}{k^2\log k}\to 2,$$
with limit inferior and limit superior both equal to $2$, explicit constants $1$ and $4$ valid for all $k \ge 2$, tightening to $1.9$ and $2.2$ for $k \ge 100$, and verified small-case windows containing the exact values $T_2 = 7$, $T_3 = 23$, $T_4 = 51$. The general theory — the all-orders binomial-moment identity, the two majority criteria, the monotonicity of the transition, and the sharp $O(N)$ window around $N\log N$ — applies to any finite alphabet, and via the block-word dictionary it yields $\Theta(l\,k^l\log k)$ thresholds for rainbow $l$-term progressions at every pattern length. The exact moment identity moreover supplies, in a single stroke, all the input needed for the conjectural Poisson limit law and the second-order constant $\log(1/\log 2)$.
