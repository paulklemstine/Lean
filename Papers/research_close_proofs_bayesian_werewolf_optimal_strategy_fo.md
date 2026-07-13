# A Combinatorial Bridge Between Bayesian Werewolf and Vandermonde's Convolution

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

We establish a precise, dimension-free correspondence between the elementary probabilistic structure of a social-deduction game and two classical binomial-coefficient identities. In the game of Werewolf (Mafia), a population of $n$ players hides $k$ werewolves among $n-k$ villagers. Modeling the number of werewolves in a uniformly random committee of $t$ players by the hypergeometric distribution, we prove that its two most basic moments are *exactly* named combinatorial identities rather than approximations of them. Specifically: (i) the normalization of the distribution is Vandermonde's convolution $\sum_j \binom{k}{j}\binom{n-k}{t-j} = \binom{n}{t}$; and (ii) the mean $t\,k/n$ is the binomial absorption identity $j\binom{k}{j}=k\binom{k-1}{j-1}$ followed by a second application of Vandermonde. Specializing to a single suspect ($t=1$) recovers the prior detection probability $k/n$ that underlies Bayesian analysis of optimal play. All results hold over the rationals with no analytic approximation, giving a clean dictionary between social-deduction probability and classical enumeration.

## 1. Introduction

Werewolf (also known as Mafia) is a social-deduction game in which a hidden minority of "werewolves" seeks to eliminate an uninformed majority of "villagers" through a nightly-elimination and daily-voting cycle. Optimal play is fundamentally a problem of Bayesian inference: each player maintains a belief distribution over the hidden role assignment and updates it as evidence accrues. A recurring quantitative primitive in this analysis is the question:

> If we scrutinize a committee of $t$ players — the set accused, targeted, or sampled in a round — how many of them are werewolves?

When the committee is drawn uniformly at random, the count of werewolves it contains follows the **hypergeometric distribution**, the canonical law of sampling without replacement. The purpose of this paper is to show that the two foundational facts about this distribution — that its weights sum to one, and that its mean is the "expected fraction" $t\,k/n$ — are not merely *consequences* of combinatorial identities but are *literally* those identities, restated in probabilistic language. This yields an exact dictionary between the Bayesian bookkeeping of the game and classical enumeration.

The correspondence is exact (no limits, no asymptotics) and dimension-free (independent of the sizes involved). We regard it as a compact illustration of how a modern applied question — inference in a game of deception — can be a faithful re-encoding of eighteenth-century combinatorics.

## 2. Definitions and combinatorial preliminaries

Throughout, $n, k, t, j$ denote natural numbers with the conventions $\binom{a}{b} = 0$ when $b > a$, and all arithmetic identities on natural numbers are understood with truncated subtraction where noted. Probabilities and moments are computed over the rationals $\mathbb{Q}$.

**Definition 2.1 (Setup).** A *Werewolf population* consists of $n$ players of whom $k$ are werewolves and $n-k$ are villagers, with $k \le n$. A *committee* is a subset of the players; a committee of size $t$ (with $t \le n$) is drawn uniformly at random from all $\binom{n}{t}$ such subsets.

**Definition 2.2 (Hypergeometric weight).** For $n,k,t,j \in \mathbb{N}$, the *hypergeometric weight* is the rational number
$$
h(n,k,t,j) \;=\; \frac{\binom{k}{j}\,\binom{n-k}{t-j}}{\binom{n}{t}} \;\in\; \mathbb{Q}.
$$
When $t \le n$ the denominator $\binom{n}{t}$ is a positive integer, so the quotient is well defined. Interpreted probabilistically, $h(n,k,t,j)$ is the probability that a uniformly random committee of $t$ players contains exactly $j$ werewolves.

We isolate the two combinatorial identities that power everything that follows.

**Lemma 2.3 (Vandermonde's convolution, range form).** For all $n,k,t \in \mathbb{N}$ with $k \le n$,
$$
\sum_{j=0}^{t} \binom{k}{j}\,\binom{n-k}{t-j} \;=\; \binom{n}{t}.
$$

*Proof sketch.* This is the additive form of the Chu–Vandermonde identity applied to the disjoint union of $k$ werewolves and $n-k$ villagers (whose sizes sum to $n$ because $k \le n$). Combinatorially: every $t$-subset of the $n$ players decomposes uniquely as a $j$-subset of the werewolves together with a $(t-j)$-subset of the villagers, for a unique $j$; summing over the antidiagonal $j + (t-j) = t$ and re-indexing over $j \in \{0, \dots, t\}$ gives the claim. $\square$

**Lemma 2.4 (Binomial absorption).** For all $k,j \in \mathbb{N}$ with $j \ge 1$,
$$
j\,\binom{k}{j} \;=\; k\,\binom{k-1}{j-1}.
$$

*Proof sketch.* Both sides count the number of ways to choose a $j$-element team from $k$ people and mark one member as leader. The left side chooses the team ($\binom{k}{j}$ ways) then the leader ($j$ ways); the right side chooses the leader ($k$ ways) then the remaining $j-1$ teammates from the other $k-1$ people ($\binom{k-1}{j-1}$ ways). Algebraically it follows from $ (k+1)\binom{k}{j} $-type recurrences after handling the edge cases $k=0$ and $j=0$. $\square$

**Lemma 2.5 (First-moment convolution).** For all $n,k,t \in \mathbb{N}$ with $1 \le k \le n$ and $1 \le t$,
$$
\sum_{j=0}^{t} j\,\binom{k}{j}\,\binom{n-k}{t-j} \;=\; k\,\binom{n-1}{t-1}.
$$

*Proof sketch.* The $j=0$ term vanishes. For $j \ge 1$ apply absorption (Lemma 2.4) to rewrite $j\binom{k}{j} = k\binom{k-1}{j-1}$, factor out $k$, re-index $i = j-1$, and observe that $n-k = (n-1)-(k-1)$ and $t-j = (t-1)-i$. The remaining sum is exactly Vandermonde's convolution (Lemma 2.3) applied to $n-1$ players with $k-1$ werewolves and committee size $t-1$, giving $\binom{n-1}{t-1}$. Multiplying back the factor $k$ completes the proof. $\square$

## 3. Main results

### 3.1 The distribution is genuine

**Proposition 3.1 (Nonnegativity).** For all $n,k,t,j \in \mathbb{N}$, $h(n,k,t,j) \ge 0$.

*Proof.* Each binomial coefficient is a nonnegative integer and $\binom{n}{t} \ge 0$; a quotient of nonnegatives is nonnegative. $\square$

**Theorem 3.2 (Bridge 1: normalization is Vandermonde).** For all $n,k,t \in \mathbb{N}$ with $k \le n$ and $t \le n$,
$$
\sum_{j=0}^{t} h(n,k,t,j) \;=\; 1.
$$

*Proof.* Since $t \le n$, the denominator $D = \binom{n}{t}$ is a positive integer, hence nonzero in $\mathbb{Q}$. Factoring $D$ out of the sum,
$$
\sum_{j=0}^{t} \frac{\binom{k}{j}\binom{n-k}{t-j}}{D} = \frac{1}{D}\sum_{j=0}^{t} \binom{k}{j}\binom{n-k}{t-j} = \frac{1}{D}\cdot\binom{n}{t} = 1,
$$
where the middle equality is exactly Vandermonde's convolution (Lemma 2.3). $\square$

Together with Proposition 3.1, Theorem 3.2 confirms that $\{h(n,k,t,j)\}_{j=0}^{t}$ is a genuine, non-vacuous probability distribution on the possible werewolf-counts $\{0, 1, \dots, t\}$.

### 3.2 The mean is the expected fraction

**Theorem 3.3 (Bridge 2: mean is absorption + Vandermonde).** For all $n,k,t \in \mathbb{N}$ with $1 \le k \le n$ and $1 \le t \le n$,
$$
\sum_{j=0}^{t} j\,h(n,k,t,j) \;=\; \frac{t\,k}{n}.
$$

*Proof.* With $D = \binom{n}{t} \ne 0$ and $n \ge 1$, pull $D$ out of the sum and apply the first-moment convolution (Lemma 2.5):
$$
\sum_{j=0}^{t} j\,h(n,k,t,j) = \frac{1}{D}\sum_{j=0}^{t} j\,\binom{k}{j}\binom{n-k}{t-j} = \frac{k\,\binom{n-1}{t-1}}{\binom{n}{t}}.
$$
Now apply absorption (Lemma 2.4) to the denominator in the form $t\,\binom{n}{t} = n\,\binom{n-1}{t-1}$, i.e. $\binom{n-1}{t-1} = \tfrac{t}{n}\binom{n}{t}$. Substituting,
$$
\frac{k\,\binom{n-1}{t-1}}{\binom{n}{t}} = \frac{k\cdot \tfrac{t}{n}\binom{n}{t}}{\binom{n}{t}} = \frac{t\,k}{n}. \qquad\square
$$

The value $t\,k/n$ is precisely the "expected fraction" heuristic: a committee occupying a fraction $t/n$ of the population should, on average, capture the same fraction of the $k$ werewolves. Theorem 3.3 proves this heuristic is exact.

### 3.3 The detection prior

**Corollary 3.4 (Single-suspect prior).** For all $n,k \in \mathbb{N}$ with $1 \le k \le n$,
$$
\sum_{j=0}^{1} j\,h(n,k,1,j) \;=\; \frac{k}{n}.
$$

*Proof.* Specialize Theorem 3.3 to $t = 1$: the mean equals $1\cdot k/n = k/n$. $\square$

**Interpretation.** A one-element committee contains either $0$ or $1$ werewolf, so its mean equals the probability that the single sampled player is a werewolf. Corollary 3.4 states that, absent any other evidence, a uniformly chosen suspect is a werewolf with probability $k/n$ — the *prior* detection probability. In a full Bayesian treatment of the game, every accusation and behavioral cue updates this prior via Bayes' rule; Corollary 3.4 identifies the baseline from which all such updates proceed, and exhibits the "prior/posterior collapse" that occurs when no discriminating evidence is available.

## 4. Algorithmic content

The proofs are constructive and translate directly into exact rational-arithmetic algorithms.

**Algorithm A (Hypergeometric weights).** Given $(n,k,t)$, compute the vector $\big(h(n,k,t,j)\big)_{j=0}^{t}$ by evaluating each binomial coefficient exactly (e.g. via Pascal recurrence or multiplicative formula) and dividing by $\binom{n}{t}$. Complexity $O(t)$ rational operations after an $O(n)$ precomputation of factorials. Theorem 3.2 furnishes a self-check: the returned weights must sum to exactly $1$.

**Algorithm B (Exact mean via the bridge).** Rather than summing $\sum_j j\,h(n,k,t,j)$, return $t\,k/n$ directly (Theorem 3.3), an $O(1)$ computation. Comparing the two provides an end-to-end numerical validation of the identity.

**Algorithm C (Vandermonde verification).** For fixed $(n,k,t)$, evaluate both sides of $\sum_j \binom{k}{j}\binom{n-k}{t-j} = \binom{n}{t}$ in exact integer arithmetic. This certifies Lemma 2.3 for concrete parameters and doubles as a normalization test for Algorithm A.

## 5. Applications

- **Bayesian game analysis.** Corollary 3.4 supplies the prior for posterior belief updates during play. The committee-count distribution $h$ models the "suspicion mass" over any scrutinized subset, and its mean quantifies expected werewolf presence in an accused group.
- **Sampling and auditing.** The hypergeometric law governs any sampling-without-replacement audit: quality control (defective items in a lot), election recounts, and ecological mark-recapture all share the identical moment structure, so the same bridge lemmas certify their expectations.
- **Pedagogy.** The correspondence gives a concrete, game-flavored motivation for Vandermonde's convolution and binomial absorption, two identities usually presented in the abstract.

## 6. Discussion

The central conceptual point is that the correspondence is *definitional*, not asymptotic. Normalization does not merely follow from Vandermonde's identity — it **is** Vandermonde's identity divided by $\binom{n}{t}$. The mean does not approximate $t\,k/n$ — the absorption identity makes it exactly $t\,k/n$. Because no limiting or continuity argument intervenes, the bridge holds verbatim for every admissible $(n,k,t)$, from a five-player parlor game to a population of millions.

All divisions are guarded: $\binom{n}{t} > 0$ whenever $t \le n$, and $n > 0$ in the mean, so no result is vacuous or ill-defined. The distribution is shown nonnegative and to sum to one, so it is a bona fide law on $\{0,\dots,t\}$.

## 7. Future directions

1. **Second moment / variance.** Establish a closed form for $\sum_j j^2\,h(n,k,t,j)$ and derive the hypergeometric variance
$$
\operatorname{Var}(J) = t\cdot\frac{k}{n}\cdot\frac{n-k}{n}\cdot\frac{n-t}{n-1}.
$$
The engine is the same: the second-order absorption $j^2\binom{k}{j} = k\,j\,\binom{k-1}{j-1}$ plus a further absorption and Vandermonde. This extends the dictionary to "detection confidence" — the spread of suspicion around its mean.
2. **Falling-factorial moments.** Generalize to
$$
\sum_j (j)_r\,h(n,k,t,j) = \frac{(t)_r\,(k)_r}{(n)_r},
$$
unifying all moments through a single $r$-fold absorption identity — a clean, fully combinatorial family.
3. **Measure-theoretic upgrade.** Package $h$ as a genuine probability mass function / measure on $\{0, \dots, t\}$ using nonnegativity and normalization, connecting the moments to the standard probability API so that the mean becomes a statement about expectation of a random variable.
4. **Link to the game recursion.** A full model of Werewolf samples one uniform removal per round; expressing each round's transition kernel via $h$ (with $t = 1$) would fuse the committee model with the round-by-round consensus-elimination dynamics into a single probabilistic model.
5. **Negative-hypergeometric variants.** The same absorption-plus-Vandermonde toolkit should yield closed forms for sampling-until-first-werewolf (the number of draws until the first werewolf appears), bridging to the geometric and beta-binomial worlds.

## 8. Conclusion

The Bayesian backbone of optimal Werewolf play — the probability that a scrutinized group harbors werewolves, and how many on average — is Vandermonde's convolution and binomial absorption in probabilistic clothing. The bridge is exact, dimension-free, and free of analytic approximation. A game of firelit deception and a pair of centuries-old counting identities turn out to be the same mathematics seen from two sides.
