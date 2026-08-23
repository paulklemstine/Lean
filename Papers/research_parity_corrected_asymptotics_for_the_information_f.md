# Parity-Corrected Asymptotics for the Information-Free Village Game

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We analyse the *information-free* version of the classical village-versus-wolves elimination game, in which the daily vote is a uniform draw over the surviving population and the wolves eliminate one villager each night. The structural observation driving the whole analysis is that the total population decreases by exactly two per round regardless of the outcome of the vote, so that the parity of the initial population $n$ is a conserved quantity of the dynamics, propagated unchanged until absorption.

We prove that this conserved parity is not washed out in the large-population limit. Writing $p_k(n)$ for the probability that the wolves win a game with initial population $n$ containing $k$ wolves, we show that for every fixed $k \ge 1$ the rescaled sequence $\sqrt{n}\,p_k(n)$ **does not converge**; instead it has two distinct subsequential limits,
$$\sqrt{n}\,p_k(n) \longrightarrow k\sqrt{2/\pi} \quad (n \text{ even}), \qquad \sqrt{n}\,p_k(n) \longrightarrow k\sqrt{\pi/2} \quad (n \text{ odd}),$$
whose ratio is exactly $\pi/2$, independently of $k$. Equivalently, the village win probability admits two asymptotic expansions with a common leading term $1$ and different first-order coefficients:
$$1 - k\sqrt{2/\pi}\,n^{-1/2} + o(n^{-1/2}) \quad (n\text{ even}), \qquad 1 - k\sqrt{\pi/2}\,n^{-1/2} + o(n^{-1/2}) \quad (n\text{ odd}).$$

The mechanism is an exact pair of identities relating the two parity subsequences of a single survival product $s(n)$: their pointwise product is $1/(n+1)$ and their pointwise ratio is a Wallis partial product. We also give a non-asymptotic form of the dichotomy valid at *every* population — the quantity $n\,s(n)^2$ lies strictly below $1$ for even $n$ and at or above $1$ for odd $n$, the separator $1$ being exactly the geometric mean of the two limiting constants — and a sharp quantitative control of the union bound, $0 \le k\,s(n) - p_k(n) \le \binom{k}{2}/n$, with the constant $\binom{k}{2}$ attained. Finally we solve the two-wolf game in closed form and compute the exact $1/n$ coefficient of the union-bound defect for two, three and four wolves, exhibiting a second-order parity split that is *rational* on the odd fibre and *transcendental* (Wallis-valued) on the even fibre.

**Keywords:** conserved parity, Wallis product, elimination games, union bound, absorbing Markov chain, subsequential limits, second-order asymptotics.

---

## 1. Introduction

### 1.1 The model

Fix two non-negative integers $v$ and $k$: the number of villagers and the number of wolves. The total population is $n = v + k$. Play proceeds in rounds, each consisting of a day followed by a night.

* **Day.** One living player, drawn uniformly at random from all $n$ living players, is eliminated. The uniformity is the *information-free* assumption: no player possesses any information distinguishing wolves from villagers, so the vote is a pure random draw.
* **Night.** If at least one wolf survives the day, the wolves eliminate one villager.

The **village wins** as soon as every wolf has been eliminated; the **wolves win** as soon as every villager has been eliminated. Both absorbing events are reached in finitely many rounds, so the game terminates almost surely.

Let $F(v,k)$ denote the probability that the wolves win, starting from $v$ villagers and $k$ wolves at the beginning of a day. Conditioning on the day vote gives the defining recursion.

> **Definition 1.1 (wolf-win probability).** $F(0,0) = 0$; $F(0,k) = 1$ for $k \ge 1$; $F(v,0) = 0$ for all $v$; and for $v, k \ge 1$,
> $$F(v,k) \;=\; \frac{k}{v+k}\,F(v-1,\,k-1) \;+\; \frac{v}{v+k}\,F(v-2,\,k),$$
> with $F(-1,k)$ read as $F(0,k)$. The **village win probability** is $V(v,k) = 1 - F(v,k)$.

The two branches encode the two possible outcomes of the day. With probability $k/(v+k)$ the vote *hits* a wolf; that wolf dies by day, and at night one villager is eaten (if any wolf remains), so the state becomes $(v-1, k-1)$. With probability $v/(v+k)$ the vote *misses*; a villager dies by day, another is eaten by night, so the state becomes $(v-2,k)$.

It is immediate from the recursion by induction that $0 \le F(v,k) \le 1$.

When we wish to index by population rather than by villager count we write
$$p_k(n) \;=\; F(n-k,\,k), \qquad n \ge k,$$
for the wolf-win probability of a population of $n$ containing $k$ wolves.

### 1.2 The conserved parity

**Observation 1.2.** *In every round, hit or miss, the total population decreases by exactly two.*

Indeed, on a hit the state goes from $(v,k)$ to $(v-1,k-1)$, and on a miss from $(v,k)$ to $(v-2,k)$; in both cases $v+k$ drops by $2$. Consequently the game visits only the populations
$$n, \; n-2, \; n-4, \; \dots$$
and **the parity of $n$ is a conserved quantity of the dynamics**, preserved until absorption. The two parity classes are dynamically disjoint: no trajectory ever crosses between them.

The whole content of this paper is that this microscopic conservation law survives the limit $n \to \infty$, producing two genuinely different asymptotic regimes.

### 1.3 Motivation and prior expectation

The information-free game is the natural null model for the family of social-deduction elimination games. Numerically, exact evaluation of $F$ for populations $7$ through $20$ shows a stable even/odd oscillation in the rescaled quantities, which no single smooth scaling in $n$ can reproduce. The purpose of this paper is to explain that oscillation exactly, identify both limits, prove that the oscillation is genuine (i.e. that no parity-blind limit exists), and quantify the corrections.

### 1.4 Summary of results

Throughout, $s(n)$ denotes the single-wolf survival product of Definition 2.1.

1. **(Theorem 2.3)** $p_1(n) = s(n)$ exactly, for every $n \ge 1$.
2. **(Theorem 2.4, Theorem 3.2)** $s(n)s(n+1) = 1/(n+1)$ and $s(2m+1) = W_m\,s(2m)$, where $W_m$ is the $m$-th Wallis partial product.
3. **(Theorem 3.3)** $(2m+1)s(2m+1)^2 = W_m$ and $(2m+1)s(2m)^2 W_m = 1$.
4. **(Theorem 3.5)** $\sqrt{n}\,s(n) \to \sqrt{2/\pi}$ along even $n$ and $\to \sqrt{\pi/2}$ along odd $n$.
5. **(Theorem 4.1)** $p_k(n) \le k\,s(n)$ for all $n, k$.
6. **(Theorem 4.4, Theorem 4.5)** The defect $D_k(n) = k\,s(n) - p_k(n)$ satisfies $0 \le n\,D_k(n) \le \binom{k}{2}$, and the constant is attained for $k = 2, 3$ at every odd population.
7. **(Theorem 5.2, Corollary 5.3)** $\sqrt{n}\,p_k(n) \to k\sqrt{2/\pi}$ (evens) and $\to k\sqrt{\pi/2}$ (odds); the ratio is $\pi/2$ for every $k \ge 1$; and $\sqrt{n}\,p_k(n)$ has no limit.
8. **(Theorem 6.2)** The finite-$n$ separator: $n\,s(n)^2 < 1$ for even $n$, $\ge 1$ for odd $n$.
9. **(Theorem 7.1, Theorem 7.3)** Exact closed forms for $k \le 4$, in particular the complete solution of the two-wolf game, and the second-order parity split.

---

## 2. The survival product and the one-wolf game

### 2.1 Definition

> **Definition 2.1 (survival product).** Define $s : \mathbb{N} \to \mathbb{Q}$ by
> $$s(0) = s(1) = 1, \qquad s(n) = s(n-2)\cdot\frac{n-1}{n} \quad (n \ge 2).$$

Unfolding the recursion,
$$s(2m) \;=\; \prod_{j=1}^{m} \frac{2j-1}{2j} \;=\; \frac{1}{4^m}\binom{2m}{m}, \qquad s(2m+1) \;=\; \prod_{j=1}^{m} \frac{2j}{2j+1} \;=\; \frac{4^m}{(2m+1)\binom{2m}{m}}.$$

The probabilistic meaning is exactly what one wants: $s(n)$ is the probability that a designated player survives every day vote in a game whose population follows the deterministic ladder $n, n-2, n-4, \dots$, since the survival probability on the round starting at population $j$ is $1 - 1/j = (j-1)/j$.

**Lemma 2.2.** $0 < s(n) \le 1$ for all $n$, and $s$ is non-increasing along each parity class: $s(n+2) \le s(n)$.

*Proof.* Positivity and the bound $s(n) \le 1$ follow by two-step induction from $s(n+2) = s(n)(n+1)/(n+2)$ and $(n+1)/(n+2) < 1$; monotonicity along a parity class is the same factor. $\square$

### 2.2 One wolf

> **Theorem 2.3 (exact one-wolf formula).** For every $v \ge 0$,
> $$F(v,1) \;=\; s(v+1), \qquad\text{i.e.}\qquad p_1(n) = s(n).$$

*Proof sketch.* With a single wolf the wolves win if and only if that wolf is never selected by a day vote (once the wolf is lynched the village has won; while the wolf lives, villagers keep dying, and the wolves win when the last one is gone). Since the population is deterministic on the one-wolf ladder — it is $n$, then $n-2$, etc., irrespective of what happens — the survival events are independent draws and the probability is the product $\prod (1 - 1/n_i) = s(n)$.

Formally: for $v = 0$ both sides are $1$, for $v = 1$ both sides are $1/2$, and for $v \ge 2$ the recursion gives
$$F(v,1) = \frac{1}{v+1}\cdot 0 + \frac{v}{v+1}\,F(v-2,1) = \frac{v}{v+1}\,s(v-1) = s(v+1),$$
using $F(\cdot,0) = 0$ and the defining recursion for $s$. $\square$

Thus the one-wolf game *is* the survival product, and all the asymptotic subtlety of the general game is already present in the arithmetic of $s$.

### 2.3 The parity coupling identity

> **Theorem 2.4 (parity coupling).** For every $n \ge 0$,
> $$s(n)\,s(n+1) \;=\; \frac{1}{n+1}.$$

*Proof.* Induction on $n$. For $n=0$ both sides are $1$. Assume the identity at $n$. Then
$$s(n+1)\,s(n+2) \;=\; s(n+1)\cdot s(n)\cdot\frac{n+1}{n+2} \;=\; \frac{1}{n+1}\cdot\frac{n+1}{n+2} \;=\; \frac{1}{n+2}. \qquad\square$$

This identity is the reason the two parity subsequences cannot be studied independently: their product is pinned exactly. It says that the even and odd survival products are exact reciprocals of one another up to the factor $n+1$, and it will supply one of the two equations determining both parity constants.

---

## 3. Wallis identities and the two square-root limits

> **Definition 3.1 (Wallis partial product).** $\displaystyle W_m \;=\; \prod_{j=1}^{m}\frac{(2j)^2}{(2j-1)(2j+1)}$, with $W_0 = 1$.

Wallis's classical 1656 result is that $W_m \uparrow \pi/2$ as $m \to \infty$. We use only this fact about $\pi$.

> **Theorem 3.2 (Wallis ratio).** For every $m \ge 0$,
> $$s(2m+1) \;=\; W_m\, s(2m).$$

*Proof.* Induction on $m$. At $m=0$ both sides equal $1$. For the step, use $s(2m+3) = s(2m+1)\frac{2m+2}{2m+3}$, $s(2m+2) = s(2m)\frac{2m+1}{2m+2}$, and $W_{m+1} = W_m\cdot\frac{(2m+2)^2}{(2m+1)(2m+3)}$; substituting the inductive hypothesis and clearing denominators gives an algebraic identity. $\square$

Combining Theorems 2.4 and 3.1 — a product identity and a ratio identity for the same pair — determines each parity subsequence separately.

> **Theorem 3.3 (exact squared identities).** For every $m \ge 0$,
> $$(2m+1)\,s(2m+1)^2 \;=\; W_m, \qquad (2m+1)\,s(2m)^2\,W_m \;=\; 1.$$

*Proof.* Theorem 2.4 at $n = 2m$ reads $s(2m)s(2m+1)(2m+1) = 1$. Substituting $s(2m+1) = W_m s(2m)$ from Theorem 3.2 gives $(2m+1)W_m s(2m)^2 = 1$, the second identity. Substituting instead $s(2m) = s(2m+1)/W_m$ gives $(2m+1)s(2m+1)^2/W_m = 1$, the first. $\square$

These identities are *exact for every $m$*: no error terms, no asymptotics. They are the arithmetic heart of the paper, and the two asymptotic constants fall out of them by a single application of Wallis's theorem.

> **Theorem 3.4 (odd-population limit).** $\displaystyle \lim_{m \to \infty} \sqrt{2m+1}\; s(2m+1) \;=\; \sqrt{\pi/2}.$

*Proof.* By Theorem 3.3, $\sqrt{2m+1}\,s(2m+1) = \sqrt{W_m}$ (both sides being non-negative). Continuity of $\sqrt{\cdot}$ and $W_m \to \pi/2$ finish the argument. $\square$

> **Theorem 3.5 (even-population limit).** $\displaystyle \lim_{m \to \infty} \sqrt{2m}\; s(2m) \;=\; \sqrt{2/\pi}.$

*Proof.* By the second identity of Theorem 3.3, $(2m+1)s(2m)^2 = 1/W_m \to 2/\pi$. In particular $(2m+1)s(2m)^2$ is bounded, so $s(2m)^2 = \bigl[(2m+1)s(2m)^2\bigr]\cdot(2m+1)^{-1} \to 0$, whence
$$2m\,s(2m)^2 \;=\; (2m+1)s(2m)^2 - s(2m)^2 \;\longrightarrow\; \frac{2}{\pi} - 0 \;=\; \frac{2}{\pi}.$$
Taking square roots (again both sides non-negative) gives the claim. $\square$

> **Corollary 3.6 (the two constants and their ratio).**
> $$\frac{\sqrt{\pi/2}}{\sqrt{2/\pi}} \;=\; \frac{\pi}{2}, \qquad \sqrt{\tfrac{2}{\pi}}\cdot\sqrt{\tfrac{\pi}{2}} \;=\; 1, \qquad \frac{2}{\pi}\cdot\frac{\pi}{2} = 1.$$

*Proof.* $\sqrt{\pi/2}/\sqrt{2/\pi} = \sqrt{(\pi/2)/(2/\pi)} = \sqrt{(\pi/2)^2} = \pi/2$, since $\pi/2 > 0$. The other two are immediate. $\square$

Numerically $\sqrt{2/\pi} = 0.797884\ldots$, $\sqrt{\pi/2} = 1.253314\ldots$, and $\pi/2 = 1.570796\ldots$.

**Remark 3.7.** The appearance of $\pi$ has a transparent source: $s(2m) = 4^{-m}\binom{2m}{m}$, and Stirling's formula gives $4^{-m}\binom{2m}{m} \sim (\pi m)^{-1/2}$, i.e. $\sqrt{2m}\,s(2m) \to \sqrt{2/\pi}$. The route through Wallis's product taken above is preferable because it is *exact at every $m$*, and because it exhibits the ratio $\pi/2$ as a single algebraic object $W_m$ rather than as a quotient of two independent asymptotic estimates.

---

## 4. The union bound and its sharp defect

For $k \ge 2$ the game is no longer a single survival product, and we must control the discrepancy.

> **Theorem 4.1 (union bound).** For all $v, k \ge 0$,
> $$F(v,k) \;\le\; k\,s(v+k), \qquad\text{i.e.}\qquad p_k(n) \le k\,s(n).$$

*Proof.* The probabilistic content is the union bound: the wolves win only if some wolf is never lynched, and each individual wolf is never lynched with probability $s(n)$, the population ladder being deterministic. Formally, induct along the ladder.

*Base cases.* $k=0$: both sides are $0$. $v=0$: the claim is $1 \le k\,s(k)$, which is the elementary bound $n\,s(n) \ge 1$ (proved by two-step induction from $s(n+2)=s(n)\frac{n+1}{n+2}$). $v=1$: a direct computation from the recursion.

*Inductive step.* Let $v \ge 0$, $k \ge 0$, and put $N = v+k+3$, the population of the state $(v+2,k+1)$. The recursion gives
$$N\,F(v+2,k+1) \;=\; (k+1)F(v+1,k) \;+\; (v+2)F(v,k+1).$$
By the inductive hypotheses $F(v+1,k) \le k\,s(N-2)$ and $F(v,k+1) \le (k+1)s(N-2)$, so
$$N\,F(v+2,k+1) \;\le\; s(N-2)\bigl[(k+1)k + (v+2)(k+1)\bigr] \;=\; (k+1)\,s(N-2)\,(N-1),$$
using $k + v + 2 = N-1$. On the other hand $s(N) = s(N-2)\frac{N-1}{N}$, so the target bound multiplied by $N$ is exactly
$$N\cdot(k+1)s(N) \;=\; (k+1)\,s(N-2)\,(N-1).$$
The two agree, so $F(v+2,k+1) \le (k+1)s(N)$. $\square$

Note that the step is an *equality* between the two upper bounds: the union bound is exactly reproduced by the recursion, which is why it is asymptotically sharp.

> **Definition 4.2 (defect).** $D_k(n) \;=\; k\,s(n) - p_k(n) \;\ge\; 0$.

> **Theorem 4.3 (defect recursion).** For all $v, k \ge 0$, writing everything in population variables with $n = v+k+3$,
> $$n\,D_{k+1}(n) \;=\; (k+1)\,D_{k}(n-2) \;+\; (n-k-1)\,D_{k+1}(n-2).$$

*Proof.* Write $v = n-k-3$, so the state in question is $(v+2,k+1)$ with population $n$, and the two states on the right, $(v+1,k)$ and $(v,k+1)$, both have population $n-2$. Expanding the definition of $D$:
$$n\,D_{k+1}(n) \;=\; n(k+1)s(n) \;-\; \bigl[(k+1)F(v+1,k) + (v+2)F(v,k+1)\bigr],$$
using the recursion $n\,F(v+2,k+1) = (k+1)F(v+1,k) + (v+2)F(v,k+1)$; and
$$(k+1)D_k(n-2) + (n-k-1)D_{k+1}(n-2) \;=\; s(n-2)\bigl[(k+1)k + (v+2)(k+1)\bigr] - \bigl[(k+1)F(v+1,k) + (v+2)F(v,k+1)\bigr],$$
since $n-k-1 = v+2$. The bracketed probability terms are identical on both sides, so it remains to check the survival terms:
$$s(n-2)\,(k+1)(k+v+2) \;=\; (k+1)\,s(n-2)\,(n-1) \;=\; n(k+1)\,s(n),$$
the last step by $s(n) = s(n-2)\frac{n-1}{n}$. Hence the two sides agree identically. $\square$

The cancellation in Theorem 4.3 is the structural reason the defect is easier to bound than the probability: the survival ladder and the population ladder step in lockstep, so the leading $n^{-1/2}$ behaviour drops out entirely and one is left with a homogeneous linear recursion.

> **Theorem 4.4 (sharp defect bound).** For all $v, k \ge 0$ with $n = v+k$,
> $$n\,D_k(n) \;\le\; \binom{k}{2} \;=\; \frac{k(k-1)}{2}.$$
> Equivalently, $k\,s(n) - \dfrac{k(k-1)/2}{n} \;\le\; p_k(n) \;\le\; k\,s(n)$ for $n \ge 1$.

*Proof sketch.* Set $g_k(n) = n\,D_k(n)$. Dividing Theorem 4.3 by $n-2$ turns it into
$$g_{k+1}(n) \;=\; \frac{(k+1)\,g_k(n-2) + (n-k-1)\,g_{k+1}(n-2)}{n-2}.$$
The constant profile $g_k \equiv \binom{k}{2}$ is an exact fixed point of this operator: substituting $g_k(n-2)=\binom{k}{2}$ and $g_{k+1}(n-2)=\binom{k+1}{2}$ and using Pascal's rule $\binom{k+1}{2} = \binom{k}{2}+k$, the numerator becomes
$$(k+1)\binom{k}{2} + (n-k-1)\Bigl[\binom{k}{2}+k\Bigr] \;=\; n\binom{k}{2} + k(n-k-1) \;=\; (n-2)\binom{k+1}{2}.$$
Hence induction on $k$, with an inner induction along the population ladder, propagates the bound provided the two base populations ($v=0$ and $v=1$) satisfy it. Those are handled by the elementary estimates $k\,s(k) \le (k+1)/2$ and $n\,s(n)^2 \le 2$ (the latter a purely rational consequence of Theorem 2.4 and $s(2m) \le s(2m+1)$). $\square$

> **Theorem 4.5 (optimality of $\binom{k}{2}$).** For $k = 2$ and $k = 3$, the bound of Theorem 4.4 is attained *exactly* at every odd population:
> $$n\,D_2(n) = 1 \ \ (n \text{ odd}), \qquad n\,D_3(n) = 3 \ \ (n \text{ odd}).$$

This follows from the closed forms of Section 7. In particular the constant $\binom{k}{2}$ in Theorem 4.4 cannot be improved.

**Remark 4.6 (why not a uniform constant).** The bound necessarily degrades in $k$. At $v = 0$ the wolves win outright, $p_k(k) = 1$, while $k\,s(k) \asymp \sqrt{k}$, so $n D_k(n)$ already grows like $k^{3/2}$ there. The point of Theorem 4.4 is that for each *fixed* $k$ the defect is $O(1/n)$ uniformly, hence negligible against the $n^{-1/2}$ leading term.

---

## 5. The main theorem: two asymptotic expansions

We now transport the parity-split limits of Section 3 from $k=1$ to arbitrary $k$.

> **Theorem 5.1 (transfer principle).** Let $k \ge 0$ be fixed and let $(n_m)$ be any sequence of populations with $n_m \to \infty$, $n_m \ge k$ eventually, and
> $$\sqrt{n_m}\,s(n_m) \longrightarrow L.$$
> Then $\sqrt{n_m}\,p_k(n_m) \longrightarrow kL$.

*Proof.* By Theorem 4.4, for each $m$,
$$k\,s(n_m) - \frac{\binom{k}{2}}{n_m} \;\le\; p_k(n_m) \;\le\; k\,s(n_m).$$
Multiply by $\sqrt{n_m} > 0$:
$$k\,\sqrt{n_m}\,s(n_m) - \binom{k}{2}\frac{1}{\sqrt{n_m}} \;\le\; \sqrt{n_m}\,p_k(n_m) \;\le\; k\,\sqrt{n_m}\,s(n_m).$$
Both outer terms converge to $kL$, since $n_m^{-1/2} \to 0$. The squeeze theorem concludes. $\square$

> **Theorem 5.2 (main theorem: the parity dichotomy).** Fix $k \ge 1$. Then:
>
> 1. **(Common leading behaviour.)** Along both parity classes, $p_k(n) \to 0$ and the village win probability $V \to 1$.
> 2. **(Two first-order constants.)**
> $$\lim_{\substack{n \to \infty \\ n \text{ even}}} \sqrt{n}\,p_k(n) \;=\; k\sqrt{\frac{2}{\pi}}, \qquad \lim_{\substack{n \to \infty \\ n \text{ odd}}} \sqrt{n}\,p_k(n) \;=\; k\sqrt{\frac{\pi}{2}}.$$
> 3. **(Universal ratio.)** The two constants are distinct and their ratio is
> $$\frac{k\sqrt{\pi/2}}{k\sqrt{2/\pi}} \;=\; \frac{\pi}{2},$$
> *independently of $k$*.
> 4. **(No parity-blind limit.)** The sequence $\bigl(\sqrt{n}\,p_k(n)\bigr)_{n}$ does not converge.

*Proof.* Item 2 is Theorem 5.1 applied to $n_m = 2m$ with $L = \sqrt{2/\pi}$ (Theorem 3.5) and to $n_m = 2m+1$ with $L = \sqrt{\pi/2}$ (Theorem 3.4). Item 3 is Corollary 3.6 together with $\pi/2 > 1$, which gives $\sqrt{2/\pi} < \sqrt{\pi/2}$ (indeed $2/\pi < \pi/2$ because $\pi^2 > 4$). Item 1 follows from item 2 by dividing by $\sqrt{n} \to \infty$. Item 4: if $\sqrt{n}\,p_k(n) \to L$ then both subsequential limits would equal $L$, contradicting item 3 for $k \ge 1$. $\square$

> **Corollary 5.3 (the two expansions of the village win probability).** For every fixed $k \ge 1$, writing $V_k(n) = 1 - p_k(n)$,
> $$V_k(n) \;=\; 1 - k\sqrt{\tfrac{2}{\pi}}\;n^{-1/2} + o(n^{-1/2}) \quad (n \text{ even}),$$
> $$V_k(n) \;=\; 1 - k\sqrt{\tfrac{\pi}{2}}\;n^{-1/2} + o(n^{-1/2}) \quad (n \text{ odd}).$$
> The leading terms agree; the first-order coefficients differ by the factor $\pi/2$.

> **Theorem 5.4 (explicit error bound).** For all $v,k$ with $n = v+k \ge 1$,
> $$\left|\sqrt{n}\,p_k(n) \;-\; k\,\sqrt{n}\,s(n)\right| \;\le\; \frac{k(k-1)/2}{\sqrt{n}}.$$

*Proof.* Immediate from Theorem 4.4 after multiplying by $\sqrt{n}$. $\square$

Theorem 5.4 makes the convergence in Theorem 5.2 quantitative: the deviation of the scaled wolf-win probability from $k$ times the scaled survival product is $O(k^2 n^{-1/2})$. This explains the numerically observed fact that the odd-population convergence for larger $k$ is visibly slower: at $k=3$ and $n = 1281$ the defect contributes $3/\sqrt{1281} \approx 0.0838$, which accounts almost exactly for the observed gap between $\sqrt{n}\,p_3(n) = 3.6754$ and the limit $3\sqrt{\pi/2} = 3.7599$.

---

## 6. The dichotomy at finite population

The results above are asymptotic. Remarkably, the parity separation is already exact at every finite population, with a completely elementary certificate and no appeal to $\pi$.

> **Lemma 6.1 (termwise comparison).** For every $m \ge 0$, $s(2m) \le s(2m+1)$.

*Proof.* Induction on $m$, or directly: the $j$-th factors are $\frac{2j-1}{2j}$ and $\frac{2j}{2j+1}$, and $(2j-1)(2j+1) = 4j^2-1 < 4j^2$, so each factor of the even product is strictly smaller than the corresponding factor of the odd product; the odd product also has the same number of factors. $\square$

> **Theorem 6.2 (finite-population separator).** For every $n \ge 1$,
> $$n\,s(n)^2 < 1 \ \ (n \text{ even}), \qquad n\,s(n)^2 \ge 1 \ \ (n \text{ odd}).$$
> Consequently, for the one-wolf game, $n\,p_1(n)^2 < 1$ for even $n$ and $\ge 1$ for odd $n$.

*Proof.* By Lemma 6.1 and Theorem 2.4,
$$s(2m)^2 \;\le\; s(2m)s(2m+1) \;=\; \frac{1}{2m+1} \;\le\; s(2m+1)^2 .$$
Multiplying by $2m+1 > 0$ gives $(2m+1)s(2m)^2 \le 1 \le (2m+1)s(2m+1)^2$. The odd case is the right-hand inequality. For the even case, $2m\,s(2m)^2 < (2m+1)s(2m)^2 \le 1$ since $s(2m) > 0$. Finally $p_1(n) = s(n)$ by Theorem 2.3. $\square$

> **Corollary 6.3 (the separator is the geometric mean).** The threshold $1$ in Theorem 6.2 is exactly the geometric mean of the two asymptotic values of $n\,s(n)^2$:
> $$\frac{2}{\pi}\cdot\frac{\pi}{2} \;=\; 1.$$

Thus the two parity subsequences of $n\,s(n)^2$ approach their respective limits $2/\pi$ and $\pi/2$ from the same side of $1$ that they eventually occupy, without ever crossing. The data:

| $n$ | $n\,s(n)^2$ (exact) | decimal | side |
|---:|---:|---:|:---|
| 7 | $256/175$ | 1.462857 | $\ge 1$ |
| 8 | $1225/2048$ | 0.598145 | $< 1$ |
| 9 | $16384/11025$ | 1.486077 | $\ge 1$ |
| 10 | $19845/32768$ | 0.605621 | $< 1$ |
| 11 | $65536/43659$ | 1.501088 | $\ge 1$ |
| 12 | $160083/262144$ | 0.610668 | $< 1$ |
| 19 | $4294967296/2807136475$ | 1.530017 | $\ge 1$ |
| 20 | $10667118605/17179869184$ | 0.620908 | $< 1$ |

---

## 7. Exact closed forms and the second-order parity split

For small wolf counts the recursion can be solved in closed form. All statements below are exact for every admissible population.

> **Theorem 7.1 (the two-wolf game, solved).** For every population $n \ge 2$,
> $$p_2(n) \;=\; \begin{cases} 2\,s(n), & n \text{ even},\\[6pt] 2\,s(n) - \dfrac{1}{n}, & n \text{ odd}. \end{cases}$$

*Proof sketch.* Both statements are proved by induction along the population ladder, using the recursion for $F$, the exact one-wolf formula $F(v,1) = s(v+1)$ of Theorem 2.3, and $s(n) = s(n-2)(n-1)/n$. In the even case the base is $F(0,2) = 1 = 2\,s(2)$; in the odd case, $F(1,2) = 2/3 = 2\,s(3) - 1/3$. Each inductive step reduces, after clearing denominators, to a polynomial identity. $\square$

Theorem 7.1 says that for two wolves at **even** population the union bound is exactly attained ($D_2 = 0$), and at **odd** population it is missed by exactly $1/n$ ($n\,D_2(n) = 1$). This is the crispest possible form of the parity asymmetry: at even $n$ the double-counted event "both wolves survive" has probability exactly zero contribution, while at odd $n$ it contributes exactly $1/n$.

> **Theorem 7.2 (three and four wolves).** For every admissible population,
> $$p_3(n) = 3\,s(n) - \frac{3}{n} \quad (n \text{ odd}), \qquad p_3(n) = \frac{3n-4}{n-1}\,s(n) \quad (n \text{ even}),$$
> $$p_4(n) = \frac{4n-8}{n-1}\,s(n) \quad (n \text{ even}).$$
> The even prefactors are rational functions of $n$ increasing to $3$ and $4$ respectively, so the union bound is approached but never attained for $k \ge 3$.

> **Theorem 7.3 (second-order parity split).** With $D_k(n) = k\,s(n) - p_k(n)$:
>
> | wolves $k$ | $n$ even | $n$ odd |
> |---|---|---|
> | $2$ | $n\,D_2(n) = 0$ | $n\,D_2(n) = 1$ |
> | $3$ | $n\,D_3(n) = s(n-2) \to 0$ | $n\,D_3(n) = 3$ |
> | $4$ | $n\,D_4(n) = 4\,s(n-2) \to 0$ | — |
>
> In particular the scaled defect is a *rational constant* on the odd fibre and a *Wallis-valued*, $\Theta(n^{-1/2})$, quantity on the even fibre.

*Proof.* Each entry follows by substituting the closed forms of Theorems 7.1, 7.2 into the definition of $D_k$ and simplifying with $s(n) = s(n-2)(n-1)/n$. For instance, at even $n$ with $k=3$,
$$D_3(n) = 3s(n) - \frac{3n-4}{n-1}s(n) = s(n)\cdot\frac{3(n-1)-(3n-4)}{n-1} = \frac{s(n)}{n-1} = \frac{s(n-2)}{n},$$
using $s(n)/(n-1) = s(n-2)/n$. That the even-fibre quantities tend to $0$ is Theorem 3.5 (indeed $s(n) \to 0$ like $n^{-1/2}$ along either parity). $\square$

This is a genuine *second-order* parity dichotomy, and it is qualitatively richer than the first-order one: the first-order constants differ by a factor, but the second-order terms differ in kind — an exact rational number on one fibre, an irrational Wallis-type product on the other.

---

## 8. Algorithms

Three algorithms suffice to reproduce every numerical statement in this paper in exact arithmetic.

### 8.1 Exact wolf-win table (dynamic programming)

Fill a table $F[v][k]$ for $0 \le v \le V$, $0 \le k \le K$ using Definition 1.1, in increasing order of $v$ and $k$. Each entry costs $O(1)$ rational operations. With rationals of bit-size $O(n\log n)$ (denominators divide $\mathrm{lcm}$'s of the population ladder), the total cost is $O(VK\,M(n))$ where $M$ is the cost of a rational multiply. In floating point the whole table for $V = 10^4$, $K = 10$ is instantaneous.

### 8.2 Survival ladder and Wallis product

$s(n)$ is computed by a single downward loop over the ladder, $O(n)$ rational multiplications. $W_m$ likewise. Both are needed only to verify identities: for the asymptotics, Theorem 3.3 lets one obtain $s$ from $W$ and vice versa.

### 8.3 Parity-split limit estimator with Richardson-type correction

Given the exact table, estimate the two constants by evaluating $\sqrt{n}\,p_k(n)$ at large $n$ of each parity. Theorem 5.4 shows the error is $\binom{k}{2}n^{-1/2} + O(\text{Wallis tail})$, so the *corrected* estimator
$$\widehat{c}(n) \;=\; \sqrt{n}\,p_k(n) + \frac{\binom{k}{2}}{\sqrt{n}}$$
removes the dominant defect error and converges markedly faster on the odd fibre (where the defect is exactly $\binom{k}{2}/n$ for $k \le 3$, making the correction exact).

---

## 9. Discussion

### 9.1 Interpretation: a superselection rule

The population parity is a discrete conserved quantity that partitions the state space into two dynamically disconnected sectors. This is precisely the structure that produces sublattice oscillations in statistical mechanics: a system whose update rule preserves a $\mathbb{Z}/2$ invariant can have a well-defined limit *within* each sector while possessing no limit overall. The village game is a fully solvable instance of this phenomenon, in which both sector limits can be computed in closed form and the ratio between them identified exactly.

It is worth emphasising what does *not* happen. One might expect the memory of the initial parity to fade: after all, the game is stochastic, the number of rounds is random in the sense that the identity of the victims is random, and the absorption time varies. But the *population* trajectory is deterministic — always $-2$ per round — and it is the population, not the composition, that carries the parity. Randomness never touches the conserved quantity.

### 9.2 Consequences for model fitting

Suppose an analyst possesses only the numerical values $p_k(n)$ and attempts the natural fit $p_k(n) \approx c\,n^{-1/2}$. The residuals will alternate in sign at every step with an amplitude that does *not* decay relative to the signal — the two curves differ by a fixed factor of $\pi/2$, forever. Attempting to absorb this into higher-order terms ($c_1 n^{-1/2} + c_2 n^{-1} + \cdots$) cannot succeed, since no such expansion oscillates. Theorem 5.2(4) is the formal statement that the exercise is impossible: the correct model is *two* expansions indexed by a conserved discrete label.

### 9.3 Relation to the null-model programme

Any assertion of the form "informed play improves the village's odds by $\Delta$" implicitly compares against a baseline. This paper supplies that baseline to second order, and shows that it depends on a variable — the parity of the roster — that is not normally recorded. For $k$ wolves and $n$ players the correct baseline village win probability is $1 - k\sqrt{2/\pi}\,n^{-1/2}$ or $1 - k\sqrt{\pi/2}\,n^{-1/2}$, a difference of $k(\sqrt{\pi/2} - \sqrt{2/\pi})\,n^{-1/2} \approx 0.455\,k\,n^{-1/2}$, which for a village of $25$ with $3$ wolves is a substantial $27$ percentage points of baseline. Comparisons across rosters of different parity are therefore not directly meaningful without correction.

### 9.4 Why $\pi$

There is no geometry in the model. The constant enters through $s(2m) = 4^{-m}\binom{2m}{m}$, the central binomial coefficient — a purely combinatorial object whose asymptotics involve $\pi$ via Stirling's formula, or equivalently via Wallis's product. The present treatment prefers the Wallis route because it is exact at every stage (Theorem 3.3), so the two parity constants are not two independent asymptotic estimates but the two solutions of a single exactly-determined $2 \times 2$ system: product $= 1/(n+1)$, ratio $= W_m$.

---

## 10. Future directions

**Direction 1 — a rational-function ladder for odd-population defects.** Exact computation suggests that for every $k \ge 2$ there is a rational function $R_k$, of degree $\lceil (k-2)/2\rceil$ over degree $\lceil (k-2)/2\rceil$, with
$$n\,D_k(n) \;=\; R_k(n) \quad\text{for every odd } n \ge k, \qquad R_k(\infty) = \binom{k}{2}.$$
The first instances are
$$R_2 = 1,\quad R_3 = 3,\quad R_4(n) = \frac{6n-13}{n-2},\quad R_5(n) = \frac{10n-25}{n-2},\quad R_6(n) = \frac{15n^2-105n+183}{(n-2)(n-4)},$$
with limits $1, 3, 6, 10, 15 = \binom{k}{2}$. The mechanism suggested by Theorem 4.3 is that on the odd fibre the survival-valued inhomogeneity is absent, so the defect recursion closes inside the field of rational functions of $n$, with degree growing by one every two steps. If true, the odd-population game is solved in closed form for every fixed $k$, and $n\,D_k(n) \to \binom{k}{2}$ upgrades Theorem 4.4 from inequality to asymptotic equality.

**Direction 2 — a Wallis obstruction on the even fibre.** Conversely, on the even fibre one expects no rational description: for every $k \ge 3$,
$$n\,D_k(n) \;=\; S_k(n)\,s(n-2)$$
with $S_k$ rational and $S_k(\infty) = c_k > 0$, so that the even-population defect is $\Theta(n^{-1/2})$ and is *not* a rational function of $n$. The cases established here are $S_2 = 0$, $S_3 = 1$, $S_4 = 4$ (Theorem 7.3). Proving this would establish that the parity split changes the arithmetic *nature* of the correction, not merely its constant.

**Further questions.** (i) Does the parity dichotomy persist when the wolves' nightly kill is randomised, or when the day vote is replaced by a non-uniform distribution with a fixed bias? (ii) What is the joint asymptotics in the regime $k = k(n) \to \infty$, e.g. $k \asymp \sqrt{n}$, where the union bound ceases to be sharp? (iii) Is there a third-order term, and does it split further?

---

## 11. Conclusion

The information-free village game carries a conserved $\mathbb{Z}/2$ label — the parity of the initial population — that is never destroyed by the dynamics, because the population decreases by exactly two per round whatever happens. We have shown that this label survives into the asymptotics: for every fixed wolf count $k \ge 1$ there are two distinct asymptotic expansions of the win probabilities, sharing the leading term but with first-order coefficients $k\sqrt{2/\pi}$ and $k\sqrt{\pi/2}$ whose ratio is exactly $\pi/2$, independently of $k$; consequently no single parity-blind scaling limit exists. The dichotomy is already exact at every finite population, separated by the threshold $1$, which is precisely the geometric mean of the two limiting constants. Quantitatively, the union bound $k\,s(n)$ is correct to within $\binom{k}{2}/n$, an estimate attained on the odd fibre for two and three wolves; and for two wolves the game is solved outright, $p_2(n) = 2s(n)$ at even $n$ and $2s(n) - 1/n$ at odd $n$. The second-order structure splits again, and this time by kind: rational on the odd fibre, Wallis-valued on the even one.
