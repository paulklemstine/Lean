# Sharp Silent-Error Constants for Almost-Lossless Compression, and the Necessity of Abstention

**Author:** Aristotle

**Date:** 2026-09-03

---

## Abstract

We study almost-lossless source compression by 2-universal hashing with a decoder that is permitted to abstain, and we separate the error probability into two operationally distinct parts: *loud failure* (the decoder returns nothing, or returns nothing usable) and *silent corruption* (the decoder confidently returns a wrong source symbol). For a source $\mu$ on a finite alphabet, a codebook list $l$ of distinct symbols whose complement carries mass at most $\delta$, and a 2-universal family into $M$ codewords, we determine the exact frontier of constant pairs achievable by derandomization over the key space.

Our results are fourfold. First, an *achievability frontier*: for every $c>1$ a single explicit key attains silent-corruption probability at most $c\,\delta\,|l|/M$ and failure probability at most $\delta + \frac{c}{c-1}|l|/M$ at decoding cost exactly $|l|$; letting $c\downarrow 1$ pushes the silent constant to the first-moment optimum $1$. Second, an *exact optimum*: over the whole admissible region $\frac{1}{c_1}+\frac{1}{c_2}\le 1$ the total-error constant satisfies $c_2+c_1\delta \ge (1+\sqrt\delta)^2$, with equality precisely at $(c_1,c_2)=(1+\delta^{-1/2},\,1+\delta^{1/2})$; the resulting *$\sqrt\delta$-balanced scheme* achieves failure $\le \delta+(1+\sqrt\delta)|l|/M$, silent corruption $\le (\sqrt\delta+\delta)|l|/M$ and total error $\le \delta+(1+\sqrt\delta)^2|l|/M$, with both constants simultaneously optimal in the limit $\delta\to0^+$. Third, *sharpness of the method's boundary*: whenever $\frac1{c_1}+\frac1{c_2}>1$ (quantitatively $K(\frac1{c_1}+\frac1{c_2}-1)>1$) there exist bad-key sets of the permitted densities that cover the key space, so no union-bound argument at those thresholds can succeed. Fourth, a *scheme-level converse and separation*: for arbitrary encoder–decoder pairs over a code of size $M$, $\Pr[\text{silent}]+\Pr[\text{abstain}] \ge 1 - M p_{\max}$; hence a decoder that never abstains corrupts silently with probability at least $1-Mp_{\max}$, at least $\tfrac12$ in the compressive regime $Mp_{\max}\le\tfrac12$, while the balanced key attains silent-corruption probability $\le\varepsilon$ for any $\varepsilon$ reachable by the balanced bound. Silent corruption is therefore not an intrinsic cost of compressing below the min-entropy but an artefact of forcing the decoder to commit.

We further prove an $r$-region derandomization principle under $\sum_i 1/c_i\le1$, yielding *group-wise* (fair) silent-error control with a local per-group bound, and show that products of 2-universal families are 2-universal, so that an independently keyed $T$-valued tag divides the silent-error bound by $T$ at unchanged scan cost.

**Keywords:** almost-lossless compression, 2-universal hashing, derandomization, silent error, selective prediction, abstention, fractional covering, Cauchy–Schwarz optimality.

---

## 1. Introduction

### 1.1 Two kinds of being wrong

Compression below the information content of a source must sometimes be wrong. Classical almost-lossless source coding bounds the total error probability and stops there. Operationally, however, two failure modes with radically different consequences are being conflated.

A **loud failure** is a decoder that declines: it detects that the received codeword is ambiguous or unrecognised and reports so. Downstream systems can retransmit, fall back, or flag. A **silent corruption** is a decoder that confidently emits the wrong symbol. It is indistinguishable from success at the interface and propagates unchecked.

The distinction is exactly the *reject option* / *selective prediction* setting in machine learning, where a predictor may abstain rather than label an input. In coding it is the difference between a detected and an undetected error. This paper develops a sharp theory of the trade-off between these two events in the hashing-based almost-lossless setting, and proves that abstention is not a design convenience but a mathematical necessity.

### 1.2 Contributions

1. **Frontier achievability** (Theorem 5.1): every point $(c, c/(c-1))$ of the admissible hyperbola is realised by a single derandomized key, with scan cost exactly $|l|$. In particular the silent constant reaches $1+\varepsilon$ for every $\varepsilon>0$ (Corollary 5.2).
2. **Exact optimum of the method** (Theorem 4.1, Proposition 4.2): $c_2+c_1\delta\ge(1+\sqrt\delta)^2$ over the whole admissible region, attained exactly at the balanced point; equivalently the $\sqrt\delta$-balanced scheme (Theorem 4.4) is *the* optimum of the two-sided derandomization method, and an AM–GM computation (Theorem 4.3) identifies $\eta=1/\sqrt\delta$ as the exact minimiser of the one-parameter tunable family.
3. **Sharpness of the covering condition** (Theorem 6.1): the hypothesis $\frac1{c_1}+\frac1{c_2}\le1$ is the precise boundary of the counting method.
4. **Group-wise fairness** (Theorem 7.1, Theorem 7.2): $r$-region derandomization under $\sum1/c_i\le1$, giving one key with a *local* per-group silent-error bound.
5. **Tagging** (Theorem 8.1, Theorem 8.2): products of 2-universal families are 2-universal; an independently keyed $T$-valued tag divides the silent-error bound by $T$ at unchanged cost.
6. **Abstention converse and separation** (Theorem 9.1, Corollary 9.2, Theorem 9.4): $\Pr[\text{silent}]+\Pr[\text{abstain}]\ge1-Mp_{\max}$ for arbitrary schemes; committing decoders lie with probability $\ge\frac12$ in the compressive regime; the reject option is worth an unbounded factor.

---

## 2. Setting and definitions

Throughout, $\mathcal{X}$ is a finite nonempty alphabet with decidable equality.

**Definition 2.1 (Source).** A *source* is a probability distribution $\mu$ on $\mathcal{X}$: a nonnegative function with $\sum_{x\in\mathcal{X}}\mu(x)=1$. For $A\subseteq\mathcal{X}$ we write $\mu(A)=\sum_{x\in A}\mu(x)$ for the *mass* of $A$, and
$$p_{\max} \;=\; \max_{x\in\mathcal{X}}\mu(x)$$
for the largest atom. The quantity $-\log_2 p_{\max}$ is the *min-entropy* of $\mu$; $M p_{\max}$ compares the code size to it.

Mass is monotone ($A\subseteq B \Rightarrow \mu(A)\le\mu(B)$), subadditive ($\mu(A\cup B)\le\mu(A)+\mu(B)$), and normalised ($\mu(\mathcal{X})=1$). These three facts are all we use.

**Definition 2.2 (Scheme with abstention).** A *scheme* with code space $\mathcal{C}$ (finite) is a pair
$$\mathrm{enc}:\mathcal{X}\to\mathcal{C}, \qquad \mathrm{dec}:\mathcal{C}\to\mathcal{X}\cup\{\bot\},$$
where $\bot$ denotes *abstention*. For a source symbol $x$:
- the scheme **succeeds** at $x$ if $\mathrm{dec}(\mathrm{enc}(x))=x$;
- the scheme **corrupts silently** at $x$ if $\mathrm{dec}(\mathrm{enc}(x))=y$ for some $y\in\mathcal{X}$ with $y\ne x$;
- the scheme **abstains** at $x$ if $\mathrm{dec}(\mathrm{enc}(x))=\bot$.

Write $\mathrm{Succ}$, $\mathrm{Sil}$, $\mathrm{Abs}$ for the corresponding subsets of $\mathcal{X}$. These three sets are pairwise disjoint and cover $\mathcal{X}$: the *decoding trichotomy*. A scheme **never abstains** if $\mathrm{Abs}=\emptyset$.

We write the *failure probability* for $\mu(\mathcal{X}\setminus\mathrm{Succ}) = \mu(\mathrm{Sil})+\mu(\mathrm{Abs})$, the *silent-corruption probability* for $\mu(\mathrm{Sil})$, and the *abstention probability* for $\mu(\mathrm{Abs})$.

**Definition 2.3 (2-universal family).** A family $H_1,\dots,H_K:\mathcal{X}\to\{1,\dots,M\}$ is *2-universal* if for all $x\ne y$,
$$\#\{k\in\{1,\dots,K\} : H_k(x)=H_k(y)\}\cdot M \;\le\; K,$$
i.e. a uniformly random key makes any fixed pair collide with probability at most $1/M$. Affine maps over a prime field, $x\mapsto\big((ax+b)\bmod p\big)\bmod M$, form such a family.

**Definition 2.4 (Hash scheme with unique-match decoding).** Let $l=(x_1,\dots,x_n)$ be a list of *distinct* elements of $\mathcal{X}$ (the *codebook*) and let $h:\mathcal{X}\to\{1,\dots,M\}$. The scheme $\mathrm{HS}(l,h)$ is:
- $\mathrm{enc}(x)=h(x)$;
- $\mathrm{dec}(i)$ scans $l$ once, collecting $\{x_j\in l: h(x_j)=i\}$; if this set is a singleton $\{x_j\}$, output $x_j$; otherwise output $\bot$.

The decoding cost is exactly $n=|l|$ hash evaluations for every received codeword: the scan is oblivious, non-adaptive and data-independent.

**Definition 2.5 (Load and defect).** Write $L=|l|/M$ (the *load*) and let $\delta$ be any bound on the *codebook defect*,
$$\mu\big(\mathcal{X}\setminus l\big)\;\le\;\delta .$$

**Definition 2.6 (Collision set).** For a key $k$ and a set $S\subseteq\mathcal{X}$, say $x$ *collides with $S$ under $k$* if there is $y\in S$ with $y\ne x$ and $H_k(x)=H_k(y)$. Write $\mathrm{Coll}_k(S)$ for the set of such $x$.

Two structural facts drive everything.

**Lemma 2.7 (Success on the codebook).** If $x\in l$ and $x\notin\mathrm{Coll}_k(l)$ then $\mathrm{HS}(l,H_k)$ succeeds at $x$.

*Proof sketch.* $x$ is itself a match for $\mathrm{enc}(x)$, and no other codebook entry matches, so the match set is $\{x\}$. $\square$

**Lemma 2.8 (Silent errors are second-order).** If $\mathrm{HS}(l,H_k)$ corrupts silently at $x$ then (i) $x\notin l$, and (ii) $x\in\mathrm{Coll}_k(l)$.

*Proof sketch.* If $x\in l$ then $x$ belongs to the match set of $\mathrm{enc}(x)$, so the decoder either outputs $x$ or abstains; it cannot output $y\ne x$. And if the decoder outputs $y\ne x$ then $y\in l$ and $H_k(y)=H_k(x)$, so $x$ collides with $l$. $\square$

Lemma 2.8 is the reason silent corruption is cheap: it requires the *conjunction* of atypicality and collision, whereas failure requires only their disjunction. This is precisely what the two-region derandomization below exploits.

---

## 3. Averaging and thresholded Markov bounds

**Lemma 3.1 (First moment).** For a 2-universal family $H$, any $S\subseteq\mathcal{X}$ and any $A\subseteq\mathcal{X}$,
$$\frac{1}{K}\sum_{k=1}^{K} \mu\big(A\cap \mathrm{Coll}_k(S)\big) \;\le\; \frac{|S|}{M}\,\mu(A).$$

*Proof sketch.* Exchange the sum over keys with the sum over $x\in A$; for each $x$, the probability over a uniform key that $x$ collides with some $y\in S$ is, by the union bound and 2-universality, at most $|S|/M$. Weight by $\mu(x)$ and sum. $\square$

Averaging exhibits a good key *on average* but does not produce a fixed one. We threshold.

**Definition 3.2 (Bad keys at level $c$).** For a threshold $c>0$, a region $A$ and a codebook set $S$, let
$$\mathcal{B}_c(A) = \Big\{k : M\cdot\mu\big(A\cap\mathrm{Coll}_k(S)\big) > c\,|S|\,\mu(A)\Big\}.$$

**Lemma 3.3 (Strict Markov bound).** For every $c>0$, $\;|\mathcal{B}_c(A)|\cdot c < K$.

*Proof sketch.* Markov's inequality applied to Lemma 3.1 gives $|\mathcal{B}_c(A)|\cdot c\le K$; strictness comes from the fact that membership in $\mathcal{B}_c(A)$ requires a *strict* excess, so the total mass contributed by bad keys alone strictly exceeds $c$ times their share whenever $\mathcal{B}_c(A)$ is nonempty, while for $\mathcal{B}_c(A)=\emptyset$ the claim is $0<K$. $\square$

Strictness matters: it is what lets the covering condition be satisfied with *equality*, $\frac1{c_1}+\frac1{c_2}=1$, which is exactly where the optimum sits.

**Proposition 3.4 (Two-region derandomization).** Let $c_1,c_2>0$ satisfy $\frac1{c_1}+\frac1{c_2}\le1$. Then there exists a key $k$ that is simultaneously $c_2$-good on $\mathcal{X}$ and $c_1$-good on $\mathcal{X}\setminus l$.

*Proof sketch.* By Lemma 3.3 the two bad-key sets have cardinalities $< K/c_2$ and $< K/c_1$, whose sum is $\le K$; strictness of both makes the sum $<K$, so their union cannot be all of $\{1,\dots,K\}$. $\square$

Combining Proposition 3.4 with Lemmas 2.7 and 2.8 gives the **tunable scheme**: a single key with
$$\Pr[\text{failure}]\le \delta + c_2 L, \qquad \Pr[\text{silent}]\le c_1\,\delta\,L, \qquad \text{cost} = |l| .$$
Indeed, failure requires $x\notin l$ or $x\in\mathrm{Coll}_k(l)$ (Lemma 2.7), contributing $\delta$ and $c_2|l|/M$ respectively; silent corruption requires $x\in(\mathcal{X}\setminus l)\cap\mathrm{Coll}_k(l)$ (Lemma 2.8), whose mass is at most $c_1\,\frac{|l|}{M}\,\mu(\mathcal{X}\setminus l)\le c_1\delta L$.

The remainder of the paper answers: *which admissible $(c_1,c_2)$ is best, is the admissibility condition necessary, and how good can any scheme be?*

---

## 4. The exact optimum: Cauchy–Schwarz on the frontier

The total error of the $(c_1,c_2)$-scheme is $\delta + (c_2+c_1\delta)L$, so the design problem is
$$\min\Big\{\,c_2+c_1\delta \;:\; c_1,c_2>0,\ \tfrac1{c_1}+\tfrac1{c_2}\le 1 \,\Big\}.$$

**Theorem 4.1 (Frontier optimality).** For every $\delta\ge0$ and every $c_1,c_2>0$ with $\frac1{c_1}+\frac1{c_2}\le1$,
$$c_2 + c_1\delta \;\ge\; \big(1+\sqrt\delta\big)^2 .$$

*Proof.* Put $s=\sqrt\delta$, so $\delta=s^2$ with $s\ge0$. The algebraic identity
$$\big(c_2+c_1s^2\big)\Big(\frac1{c_1}+\frac1{c_2}\Big) \;=\; (1+s)^2 + \frac{(c_2-c_1 s)^2}{c_1c_2}$$
holds for all $c_1,c_2\ne0$ (clear denominators and expand). Since $c_2+c_1s^2>0$ and $\frac1{c_1}+\frac1{c_2}\le1$,
$$(1+s)^2 + \frac{(c_2-c_1s)^2}{c_1c_2} = \big(c_2+c_1s^2\big)\Big(\frac1{c_1}+\frac1{c_2}\Big) \le c_2+c_1s^2 ,$$
and the second term on the left is nonnegative because $c_1c_2>0$. Hence $(1+s)^2\le c_2+c_1s^2$. $\square$

The proof shows more than the inequality: the *excess* is a perfect square, so equality forces $c_2=c_1 s$ (the **balanced ray**) *and* $\frac1{c_1}+\frac1{c_2}=1$ (the boundary hyperbola). Intersecting the two determines the optimum uniquely.

**Proposition 4.2 (The balanced point attains the optimum).** For $\delta>0$, at $c_1=1+\frac{1}{\sqrt\delta}$ and $c_2=1+\sqrt\delta$ we have
$$\frac{1}{1+\frac{1}{\sqrt\delta}}+\frac{1}{1+\sqrt\delta}=1 \qquad\text{and}\qquad \big(1+\sqrt\delta\big) + \Big(1+\tfrac1{\sqrt\delta}\Big)\delta = \big(1+\sqrt\delta\big)^2 .$$

*Proof.* With $s=\sqrt\delta>0$: $\frac{1}{1+1/s}+\frac{1}{1+s}=\frac{s}{s+1}+\frac{1}{1+s}=1$, and $(1+s)+(1+\frac1s)s^2=(1+s)+(s^2+s)=(1+s)^2$. $\square$

A one-parameter reparametrisation of the boundary, $c_1=1+\eta$, $c_2=1+1/\eta$ for $\eta>0$, satisfies $\frac{1}{1+\eta}+\frac{1}{1+1/\eta}=1$ identically. Its total-error functional is
$$E(\eta) \;=\; \delta + \Big(1+\tfrac1\eta\Big)L + (1+\eta)\,\delta\,L .$$

**Theorem 4.3 (AM–GM converse within the tunable family).** For all $\delta,L\ge0$ and $\eta>0$,
$$E(\eta)\;\ge\;\delta+\big(1+\sqrt\delta\big)^2 L,$$
with equality at $\eta=1/\sqrt\delta$ when $\delta>0$.

*Proof.* Write $s=\sqrt\delta$. A direct computation gives the exact excess
$$\Big(1+\tfrac1\eta\Big)L+(1+\eta)s^2L-(1+s)^2L \;=\; \frac{L}{\eta}\,(1-\eta s)^2 \;\ge\;0 .$$
Equality holds iff $\eta s=1$, i.e. $\eta=1/\sqrt\delta$. Substituting that value into $E$ and simplifying yields exactly $\delta+(1+\sqrt\delta)^2L$. $\square$

So $\eta=1/\sqrt\delta$ is the exact minimiser of the family, and by Theorem 4.1 it is the exact minimiser of the *entire* two-parameter admissible region — the family loses nothing.

**Theorem 4.4 (The $\sqrt\delta$-balanced scheme).** Let $\mu$ be a source, $H$ a 2-universal family with $K\ge1$ keys into $M\ge1$ codewords, $l$ a codebook of distinct symbols, and $\delta>0$ with $\mu(\mathcal{X}\setminus l)\le\delta$. Then there exists a single key $k$ such that the scheme $\mathrm{HS}(l,H_k)$ satisfies
1. $\Pr[\text{failure}] \le \delta + (1+\sqrt\delta)\dfrac{|l|}{M}$;
2. $\Pr[\text{silent corruption}] \le (\sqrt\delta+\delta)\dfrac{|l|}{M}$;
3. $\Pr[\text{failure}]+\Pr[\text{silent}] \le \delta + (1+\sqrt\delta)^2\dfrac{|l|}{M}$;
4. the decoding cost is exactly $|l|$ hash evaluations for every codeword.

*Proof sketch.* Apply the tunable scheme at $\eta=1/\sqrt\delta$, i.e. $c_2=1+\eta^{-1}=1+\sqrt\delta$ and $c_1=1+\eta=1+\frac1{\sqrt\delta}$, noting $c_1\delta = \delta+\frac{\delta}{\sqrt\delta}=\sqrt\delta+\delta$. Item 3 is the sum of 1 and 2 together with the identity $(1+\sqrt\delta)^2=(1+\sqrt\delta)+(\sqrt\delta+\delta)$. Item 4 is the obliviousness of the codebook scan. $\square$

**Corollary 4.5 (Comparison and limits).**
- For all $\delta\le1$: $1+\sqrt\delta\le2$ and $(1+\sqrt\delta)^2\le4$, so the balanced scheme dominates the symmetric choice $c_1=c_2=2$.
- For $0\le\delta\le1$: $\sqrt\delta+\delta\le2\sqrt\delta$, so silent corruption is $O(\sqrt\delta\,|l|/M)$ — genuinely second order.
- As $\delta\to0^+$: $1+\sqrt\delta\to1$ and $\sqrt\delta+\delta\to0$. The failure constant attains the *first-moment optimum* $1$ in the limit, while the silent constant vanishes.

The last item is the conceptual payoff and cannot be achieved by any *fixed* point of the frontier: $c_2\to1$ forces $c_1\to\infty$. It is the $\delta$-dependent tuning $c_1=1+\delta^{-1/2}$ that makes both limits happen at once.

---

## 5. The whole frontier is achievable

**Theorem 5.1 (Frontier scheme).** Under the hypotheses of Theorem 4.4 (with $\delta\ge0$), for every $c>1$ there exists a key $k$ with
$$\Pr[\text{silent}]\le c\,\delta\,\frac{|l|}{M}, \qquad \Pr[\text{failure}]\le \delta+\frac{c}{c-1}\cdot\frac{|l|}{M},$$
and decoding cost exactly $|l|$.

*Proof sketch.* Set $\eta=c-1>0$ in the tunable scheme: $c_1=1+\eta=c$ and $c_2=1+\frac1\eta=\frac{c}{c-1}$. $\square$

The map $c\mapsto(c,\frac{c}{c-1})$ parametrises the boundary hyperbola $\frac1{c_1}+\frac1{c_2}=1$ for $c>1$; $c=2$ gives the symmetric point $(2,2)$, $c=1+\delta^{-1/2}$ gives the balanced point.

**Corollary 5.2 (Silent constant near the first-moment optimum).** For every $\varepsilon>0$ there is a key with
$$\Pr[\text{silent}]\le(1+\varepsilon)\,\delta\,\frac{|l|}{M}, \qquad \Pr[\text{failure}]\le\delta+\frac{1+\varepsilon}{\varepsilon}\cdot\frac{|l|}{M}.$$

*Proof.* Theorem 5.1 with $c=1+\varepsilon$. $\square$

Thus derandomization costs *nothing* asymptotically in the silent constant: the value $1$ of a freshly drawn random key is approached arbitrarily closely by a single fixed key. What one pays is the failure constant $\frac{1+\varepsilon}{\varepsilon}\to\infty$. The naive hope of the pair $(1,\delta)$ simultaneously is impossible for this method: $c_2=1$ forces $c_1=\infty$, and Theorem 4.1 forbids $c_2+c_1\delta<(1+\sqrt\delta)^2$ outright.

---

## 6. The covering condition is exactly the boundary of the method

Proposition 3.4 needs $\frac1{c_1}+\frac1{c_2}\le1$. Is this an artefact?

**Theorem 6.1 (Necessity of the covering condition).** Let $K\ge1$ and $c_1,c_2>0$ satisfy the *density excess* condition
$$1 \;<\; K\Big(\frac{1}{c_1}+\frac{1}{c_2}-1\Big).$$
Then there exist subsets $B_1,B_2\subseteq\{1,\dots,K\}$ with
$$|B_1|\,c_1 < K, \qquad |B_2|\,c_2 < K, \qquad B_1\cup B_2=\{1,\dots,K\}.$$

*Proof.* Let $x=K/c_1>0$ and $n=\lceil x\rceil-1$, so that $n<x$ and $n\ge x-1$. Take $B_1=\{k: k<n\}$ and $B_2=\{k: k\ge n\}$; they visibly cover.

For $B_1$: $|B_1|=\min(n,K)\le n$ and $n c_1 < x c_1 = K$, hence $|B_1|c_1<K$.

For $B_2$: if $n\ge K$ then $B_2=\emptyset$ and the claim is $0<K$. Otherwise $|B_2|=K-n$, and the density-excess hypothesis rearranges to $1<\frac{K}{c_1}+\frac{K}{c_2}-K$. Combined with $n\ge \frac{K}{c_1}-1$ this gives
$$K-n \;\le\; K-\frac{K}{c_1}+1 \;<\; \frac{K}{c_2},$$
so $|B_2|c_2 < K$. $\square$

Both blocks are *strictly* below the thresholds that Lemma 3.3 guarantees for genuine bad-key sets, yet they exhaust the key space. Therefore no argument that only knows the two Markov densities can produce a good key when $\frac1{c_1}+\frac1{c_2}>1$ and $K$ is large enough for the excess to exceed one key. The condition $\frac1{c_1}+\frac1{c_2}\le1$ is precisely the edge of the counting method, and by Theorem 4.1 the value $(1+\sqrt\delta)^2$ is precisely the best point on it.

---

## 7. Many regions: fair, group-wise silent-error control

Counting arguments are not restricted to two regions.

**Theorem 7.1 ($r$-region derandomization by fractional covering).** Let $A_i\subseteq\mathcal{X}$, $i\in T$ (a finite index set), and $c_i>0$ with $\sum_{i\in T}\frac{1}{c_i}\le1$. Then a single key $k$ is $c_i$-good on $A_i$ for *every* $i$:
$$M\cdot\mu\big(A_i\cap\mathrm{Coll}_k(S)\big) \;\le\; c_i\,|S|\,\mu(A_i) \quad\text{for all } i\in T.$$

*Proof sketch.* Each bad-key set $\mathcal{B}_{c_i}(A_i)$ has cardinality $<K/c_i$ (Lemma 3.3). If $T=\emptyset$ any key works. Otherwise, by subadditivity of cardinality over a union and strict summation, $\big|\bigcup_i\mathcal{B}_{c_i}(A_i)\big| < \sum_i K/c_i = K\sum_i 1/c_i \le K$, so some key lies outside every bad set. $\square$

The natural application is *fairness*. An aggregate silent-error rate says nothing about a subpopulation: a scheme with global silent rate $10^{-3}$ may be corrupting one protected group at rate $10^{-1}$. We ask for one key that controls every group.

**Theorem 7.2 (Group-wise silent-error control).** Let $G_1,\dots,G_r\subseteq\mathcal{X}$ be arbitrary, possibly overlapping, subpopulations. Under the hypotheses of Theorem 4.4 there exists a single key $k$ with
1. global failure probability $\le \delta + (r+1)\dfrac{|l|}{M}$;
2. for every group $g$,
$$\mu\big(\mathrm{Sil}\cap G_g\big) \;\le\; (r+1)\,\mu\big(G_g\setminus l\big)\,\frac{|l|}{M};$$
3. decoding cost exactly $|l|$.

*Proof sketch.* Apply Theorem 7.1 to the $r+1$ regions $\mathcal{X}$ (for the global failure event) and $(\mathcal{X}\setminus l)\cap G_g$ for $g=1,\dots,r$, all with the uniform threshold $c=r+1$; the covering sum is $\sum_{i=1}^{r+1}\frac{1}{r+1}=1$, exactly admissible. On the region $\mathcal{X}$ we get $\mu(\mathrm{Coll}_k(l))\le(r+1)|l|/M$, and the failure set is contained in $(\mathcal{X}\setminus l)\cup\mathrm{Coll}_k(l)$ by Lemma 2.7, giving 1. On the region $(\mathcal{X}\setminus l)\cap G_g$, Lemma 2.8 shows $\mathrm{Sil}\cap G_g\subseteq (\mathcal{X}\setminus l)\cap G_g\cap\mathrm{Coll}_k(l)$, giving 2. $\square$

The per-group bound is **local**: it is driven by $\mu(G_g\setminus l)$, the mass of the part of the group that the codebook misses, not by the worst group or the global defect. Since $\mu(G_g\setminus l)\le\mu(\mathcal{X}\setminus l)\le\delta$, each group's bound is at most $(r+1)\delta|l|/M$, so Theorem 7.2 is never weaker than the aggregate statement and is strictly stronger for well-covered groups.

**Corollary 7.3 (Individual coverage defects).** If $\mu(G_g\setminus l)\le\delta_g$ for each $g$, the same key gives $\mu(\mathrm{Sil}\cap G_g)\le(r+1)\,\delta_g\,\frac{|l|}{M}$: each subpopulation's silent-error rate is governed by *its own* coverage defect.

The entire price of controlling $r$ groups plus the global event with one key is the single covering factor $r+1$, growing linearly in the number of protected regions — the exact cost of fractional covering.

---

## 8. Tagged codewords: exponential suppression at no extra scan cost

A practical hardening is to append a short **tag**: a second hash, driven by an *independent* key, into $\{1,\dots,T\}$. A silent error then needs the codeword and the tag to collide simultaneously.

**Theorem 8.1 (Products of 2-universal families are 2-universal).** Let $H_1,\dots,H_K:\mathcal{X}\to\{1,\dots,M\}$ and $G_1,\dots,G_{K'}:\mathcal{X}\to\{1,\dots,T\}$ be 2-universal. Define the *tagged family* on the product key space $\{1,\dots,KK'\}$ by
$$\widetilde{H}_{(k,k')}(x) \;=\; \big(H_k(x),\,G_{k'}(x)\big)\ \in\ \{1,\dots,M\}\times\{1,\dots,T\}\ \cong\ \{1,\dots,MT\}.$$
Then $\widetilde{H}$ is 2-universal into $MT$ codewords.

*Proof sketch.* For $x\ne y$, $\widetilde H_{(k,k')}(x)=\widetilde H_{(k,k')}(y)$ iff $H_k(x)=H_k(y)$ *and* $G_{k'}(x)=G_{k'}(y)$. Hence the bad-key set of the product is the Cartesian product of the two bad-key sets, so its cardinality is the product $N\cdot N'$ where $NM\le K$ and $N'T\le K'$. Multiplying these two nonnegative inequalities gives $(NN')(MT)\le KK'$, which is 2-universality of $\widetilde H$. $\square$

Note this is *not* a relabelling of "use $MT$ codewords in the first place": the tag is produced by an independent key, so the key space grows multiplicatively while the universality constant is exactly $1/(MT)$.

**Theorem 8.2 (Tagged balanced scheme).** With $\delta>0$ and $\mu(\mathcal{X}\setminus l)\le\delta$, there is a single key pair $(k,k')$ whose tagged scheme achieves
$$\Pr[\text{silent}]\le(\sqrt\delta+\delta)\frac{|l|}{MT}, \qquad \Pr[\text{failure}]\le\delta+(1+\sqrt\delta)\frac{|l|}{MT},$$
with decoding cost still exactly $|l|$ evaluations of the tagged hash.

*Proof sketch.* Apply Theorem 4.4 to the tagged family, which is 2-universal into $MT$ codewords by Theorem 8.1. $\square$

With $T=2^t$, the silent-error bound improves by the factor $2^{-t}$: silent corruption is *exponentially rare in the tag length*, and the scan cost is unchanged. Quantitatively, for $T\ge1$, $(\sqrt\delta+\delta)\frac{|l|}{MT}\le(\sqrt\delta+\delta)\frac{|l|}{M}$, with the improvement factor exactly $1/T$. Operationally the tag converts would-be silent corruptions into detected failures — it moves mass from the "confident lie" bucket into the "I don't know" bucket, which the next section shows is the only place it can go.

---

## 9. Abstention is necessary: a converse and a separation

All of the above rests on a decoder that may answer $\bot$. Is abstention a convenience or a necessity? The answer is a scheme-level converse that applies to *arbitrary* encoder–decoder pairs.

**Lemma 9.0 (Pigeonhole on the success set).** For any scheme with code space $\mathcal{C}$, $\mu(\mathrm{Succ})\le|\mathcal{C}|\cdot p_{\max}$.

*Proof sketch.* On $\mathrm{Succ}$ the encoder is injective — if $\mathrm{enc}(x)=\mathrm{enc}(x')$ with $x,x'\in\mathrm{Succ}$ then $x=\mathrm{dec}(\mathrm{enc}(x))=\mathrm{dec}(\mathrm{enc}(x'))=x'$ — so $|\mathrm{Succ}|\le|\mathcal{C}|$, and each element carries mass at most $p_{\max}$. $\square$

**Theorem 9.1 (Abstention / silent-corruption trade-off).** For *every* scheme with code space of size $M$,
$$\mu(\mathrm{Sil}) \;+\; \mu(\mathrm{Abs}) \;\ge\; 1 - M\,p_{\max}.$$

*Proof.* By the decoding trichotomy, $\mathcal{X}=\mathrm{Succ}\cup\mathrm{Sil}\cup\mathrm{Abs}$, so by monotonicity and subadditivity of mass,
$$1=\mu(\mathcal{X})\le\mu(\mathrm{Succ})+\mu(\mathrm{Sil})+\mu(\mathrm{Abs}).$$
Apply Lemma 9.0 and rearrange. $\square$

This is a conservation law. Below the min-entropy of the source — precisely when $Mp_{\max}<1$ — the mass $1-Mp_{\max}$ that the code cannot carry must be spent on silent corruption or abstention. A decoder can suppress silent errors *only* by abstaining more.

**Corollary 9.2 (Committing decoders must lie).** If a scheme never abstains, then
$$\mu(\mathrm{Sil}) \;\ge\; 1 - M\,p_{\max}.$$

*Proof.* $\mu(\mathrm{Abs})=\mu(\emptyset)=0$ in Theorem 9.1. $\square$

The bound is pure pigeonhole and applies to arbitrary encoders and decoders — no code design, however clever, evades it.

**Corollary 9.3 (Half the mass).** If in addition $M p_{\max}\le\frac12$ — fewer codewords than half the "effective support" of the source, exactly the regime where compression is actually happening — then a committing decoder satisfies $\mu(\mathrm{Sil})\ge\frac12$.

**Theorem 9.4 (The abstention separation).** Fix a source $\mu$, a 2-universal family into $M$ codewords, a codebook $l$ of distinct symbols with $\mu(\mathcal{X}\setminus l)\le\delta$ for some $\delta>0$, a code size in the compressive regime $Mp_{\max}\le\frac12$, and a target level $\varepsilon$ reachable by the balanced bound, $(\sqrt\delta+\delta)\frac{|l|}{M}\le\varepsilon$. Then both of the following hold.

- **Achievability (with abstention):** there exists a key $k$ whose scheme satisfies
$$\mu(\mathrm{Sil})\le\varepsilon, \qquad \mu(\mathcal{X}\setminus\mathrm{Succ})\le\delta+(1+\sqrt\delta)\frac{|l|}{M}, \qquad \text{cost}=|l| .$$
- **Converse (without abstention):** *every* scheme over the same code space of size $M$ whose decoder never abstains satisfies $\mu(\mathrm{Sil})\ge\frac12$.

*Proof.* The first part is Theorem 4.4 combined with $(\sqrt\delta+\delta)\frac{|l|}{M}\le\varepsilon$; the second is Corollary 9.3. $\square$

The gap in silent-corruption probability between the two decoder classes is $\frac12-\varepsilon$, and $\varepsilon$ can be driven to $0$ by increasing $M$ (subject to remaining in the compressive regime, which is a condition on $Mp_{\max}$ and can be maintained by considering sources of growing support). The *ratio* is therefore unbounded.

**Interpretation.** Silent corruption is not an intrinsic cost of compressing below the min-entropy. It is entirely an artefact of forcing the decoder to answer. Given the reject option, silent corruption is a second-order event of order $\sqrt\delta\,|l|/M$; deny it, and silent corruption is a constant, at least $\frac12$.

---

## 10. Algorithms

Three procedures underlie the constructive results.

**(A) Key selection by bad-set elimination.** Given $\mu$, the family $H$, the codebook $l$, and thresholds $(c_1,c_2)$ with $\frac1{c_1}+\frac1{c_2}\le1$: for each key $k$, compute the collision mass $\mu(\mathrm{Coll}_k(l))$ and the atypical collision mass $\mu\big((\mathcal{X}\setminus l)\cap\mathrm{Coll}_k(l)\big)$; discard $k$ if either exceeds its threshold times the corresponding first moment; return any survivor. Theorem 3.4 guarantees a survivor exists. The naive cost is $O(K\cdot|\mathcal{X}|\cdot|l|)$ hash evaluations, reducible to $O(K(|\mathcal{X}|+M))$ by bucketing the codebook by hash value per key.

**(B) Balanced tuning.** Given $\delta$, set $c_1=1+\delta^{-1/2}$ and $c_2=1+\delta^{1/2}$ and run (A). By Theorem 4.1 and Proposition 4.2 this is the optimal admissible pair; by Theorem 4.4 it yields the closed-form guarantees.

**(C) Unique-match decoding.** Given a received codeword $i$, scan $l$ once maintaining a candidate and a match counter; return the candidate if the counter is exactly $1$, else $\bot$. Cost exactly $|l|$ hash evaluations, independent of the data — a fixed, predictable budget, which matters for constant-time and side-channel-sensitive deployments.

---

## 11. Applications

**Selective prediction and abstaining classifiers.** Theorem 9.1 is a hard lower bound on the price of a "no-abstain" policy in any system that maps inputs to a representation smaller than their information content: confident-error rate plus abstention rate is at least the mass the representation cannot carry. Theorem 9.4 says the reject option buys an unbounded factor in confident-error rate.

**Compressed model caches and retrieval.** Hash-bucketed key–value caches (compressed attention caches, learned index structures, deduplication tables) are exactly the setting of Definition 2.4. The balanced key gives an explicit, non-adaptive, fixed-cost scan with silent-collision rate $(\sqrt\delta+\delta)|l|/M$, and Theorem 8.2 makes it $2^{-t}$ times smaller for $t$ extra tag bits.

**Fairness auditing under compression.** Theorem 7.2 addresses the practical objection that an aggregate silent-error certificate hides subgroup harm: for $r$ audited groups, one key certifies each group locally at a cost factor $r+1$, and the certificate for a well-covered group is proportionally stronger.

**Error detection in storage and transport.** The tagged construction of Section 8 is a formal account of why an independent checksum multiplies detection power: it is the statement that the collision densities of independent universal families multiply exactly.

---

## 12. Discussion

Three boundaries have been located precisely.

*The optimum of the method.* Theorem 4.1 pins the best achievable total-error constant of the derandomization method at $(1+\sqrt\delta)^2$, and Proposition 4.2 shows the $\sqrt\delta$-balanced point attains it. The optimum is a genuine trade-off, not a corner: the ideal pair $(c_1,c_2)=(1,\delta)$ is unreachable, since $c_2=1$ forces $c_1=\infty$.

*The boundary of the method.* Theorem 6.1 shows the fractional-covering condition is exactly where union-bound derandomization stops working, by constructing bad-key sets of the permitted densities that cover the key space. Any improvement past $(1+\sqrt\delta)^2$ must therefore use structure beyond the two Markov densities — for instance second-moment or explicit-family arguments.

*The boundary of decoding.* Theorem 9.1 is a converse for *schemes*, not merely for the method: it holds for arbitrary encoders and decoders and is the first scheme-level statement in this line that constrains silent corruption directly. It is the right primitive for a genuine converse theory of silent errors.

A caveat worth stating: the constant $\frac12$ in Corollary 9.3 is not claimed sharp for every source, only for the regime $Mp_{\max}\le\frac12$; the exact statement is $\mu(\mathrm{Sil})\ge1-Mp_{\max}$, which degrades gracefully as the code approaches the min-entropy of the source and becomes vacuous above it, as it must.

---

## 13. Future directions

**A converse frontier for arbitrary schemes.** Theorem 9.1 constrains the pair $(\mu(\mathrm{Sil}),\mu(\mathrm{Abs}))$ by a single linear inequality. The natural next object is the full achievable region of the triple (silent, abstain, cost) for arbitrary schemes, and a matching converse to the $(1+\sqrt\delta)^2$ frontier at the level of schemes rather than of the method.

**Beyond union bounds.** Since Theorem 6.1 marks the exact boundary of fractional covering, improvements must exploit more structure: second-moment concentration over the key space, explicit algebraic families with better-than-universal collision behaviour, or list-decoding relaxations in which the decoder returns a short list rather than a single symbol or $\bot$.

**Sharper group-wise constants.** The factor $r+1$ in Theorem 7.2 is the exact cost of uniform fractional covering. Non-uniform thresholds $c_i$ optimised against the group masses $\mu(G_g\setminus l)$, subject to $\sum_i 1/c_i\le1$, should give a weighted frontier analogous to Theorem 4.1 — a group-wise Cauchy–Schwarz optimum.

**Tag-length optimisation.** Theorem 8.2 divides the silent bound by $T$ at fixed scan cost but at the cost of $\log_2 T$ stored bits per codeword. The rate-versus-silent-error trade-off $\big(\log_2(MT),\ (\sqrt\delta+\delta)|l|/(MT)\big)$ should be optimised against an explicit cost model for downstream silent errors.

**Adaptive codebooks.** Here $l$ and $\delta$ are given. Jointly optimising the codebook (which symbols to include) against the balanced constants — a covering-versus-load trade-off, since enlarging $l$ shrinks $\delta$ but raises $L=|l|/M$ — is the natural next design problem.
