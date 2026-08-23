# Known versus Unresolved Cards: An Exact Calculus of Certainty, Fair Odds, and the Value of Information

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We develop an exact, finite, distribution-free calculus for prediction games that mix cards *known with certainty* with cards that must be *guessed*. The central object is a splitting principle: if $d$ of the cards in a finite menu are resolved and each pays one unit, and every remaining card is fair — meaning it has zero mean under the ambient law — then the expected total payoff is exactly $d$, irrespective of correlations among the cards and irrespective of the guessing rule. Uncertainty supplies no positive edge.

We then instantiate this principle in four increasingly adversarial settings and, in each, isolate precisely what does and does not survive.

1. **Shuffled decks.** For a uniformly random bijection between $u$ slots and $u$ cards and an *arbitrary* (not necessarily injective) calling strategy $g$, we prove the master slot formula $\mathbb{E}[\text{slot score}] = (w-\ell)/u + \ell$ and hence the block value $(w-\ell) + \ell u$. We obtain a **rigidity theorem**: the block is edge-free for one strategy if and only if $w = \ell(1-u)$, i.e. exactly at the honest $(u-1):1$ quote, and then it is edge-free for all strategies. We record the **counting anomaly**: naive unit scoring exhibits a spurious edge of exactly $+1$, for every strategy and every $u$.

2. **Second moments.** The mean score is strategy-invariant, but the variance is not. We prove the exact **collision formula** $\operatorname{Var}[\text{hits}] = D(g)/(u(u-1))$, where $D(g)$ is the number of ordered pairs of slots receiving distinct calls, which interpolates continuously between $0$ (constant strategy) and $1$ (injective strategy). This locates the exact boundary of strategy invariance.

3. **Feedback.** With per-card feedback and unit scoring, the value of the unresolved block jumps from $1$ to the harmonic number $H_u$, which is unbounded; yet at stagewise fair odds the value remains exactly $0$ for every admissible feedback strategy. Information changes the price, not the edge.

4. **Learning theory and betting systems.** The No-Free-Lunch theorem is exhibited as an instance of the splitting principle via a fixed-point-free label-flip involution, with a $k$-ary generalisation driven by the free action of $\mathbb{Z}/k\mathbb{Z}$; and no adaptive, stopped betting system on a fair $\pm 1$ sequence has nonzero expected gain — including the doubling system, which wins with probability $1 - 2^{-n}$ and gains exactly $0$.

All results are exact identities over the rationals on finite sample spaces; no asymptotics, no measure-theoretic limits, no independence assumptions.

**Keywords:** fair odds, random permutations, fixed points, No Free Lunch, optional stopping, harmonic numbers, collision profile, variance decomposition.

---

## 1. Introduction

### 1.1 The question

A prediction problem rarely presents itself as pure uncertainty. Typically some part of the answer is *known* — determined by counting, by constraint, by prior observation — and the rest is genuinely open. It is tempting to believe that the open part, being open, is where the value lies: that a sufficiently clever allocation of guesses across the unknown region converts uncertainty into expected profit.

The results below say, in four different languages, that it does not. Priced honestly, the open part contributes exactly zero, and the value of the game is exactly the number of things you already know.

What makes the statement worth proving carefully rather than waving at is the number of places where it *appears* to fail. It appears to fail when the scoring rule is not a fair book (the counting anomaly, §4). It appears to fail when a high win probability is mistaken for a positive expectation (the doubling system, §8). It appears to fail when strategies with equal means but different variances are compared (the collision formula, §5). And it appears to fail when the player acquires information (feedback, §6). Each of these is resolved exactly, and the resolutions are quantitatively different from each other.

### 1.2 Contributions

- A splitting theorem for arbitrary finite index sets and arbitrary correlation structures (§3).
- Factorial-free fibre counting for the symmetric group via transposition symmetry, and its consequences for the first two moments of a general calling strategy (§4–§5).
- A rigidity characterisation of fair odds (§4.3), which upgrades "no edge" from an observation to a definition.
- An exact collision formula for the variance of a general strategy (§5.2).
- A dichotomy for feedback: the unit-scoring value is $H_u$ and unbounded; the fair-odds value is $0$ (§6).
- A proof of No Free Lunch by a fixed-point-free involution, its $\mathbb{Z}/k\mathbb{Z}$ generalisation, and a sharpness counterexample (§7).
- A finite-horizon optional stopping theorem and a quantitative resolution of the doubling paradox (§8).

### 1.3 Notation

All payoffs are rational. $\Omega$ denotes a nonempty finite sample space carrying the uniform law, and for $f : \Omega \to \mathbb{Q}$ we write

$$\mathbb{E}[f] = \frac{1}{|\Omega|}\sum_{\omega \in \Omega} f(\omega), \qquad \operatorname{Var}[f] = \mathbb{E}[f^2] - \mathbb{E}[f]^2 .$$

$H_n = \sum_{j=1}^{n} 1/j$ is the $n$-th harmonic number, $H_0 = 0$. $\mathfrak{S}_u$ is the symmetric group on $u$ letters.

---

## 2. The abstract game

**Definition 2.1 (Card).** A *card* on $\Omega$ is a function $p : \Omega \to \mathbb{Q}$, interpreted as a payoff.

**Definition 2.2 (Resolved).** A card $p$ is *resolved with value $c$* if $p(\omega) = c$ for every $\omega \in \Omega$. The predictor knows the card and collects $c$ in every state of the world.

**Definition 2.3 (Fair).** A card $p$ is *fair* if $\mathbb{E}[p] = 0$: the odds offered exactly compensate the residual uncertainty.

Two remarks on the level of generality. First, "fair" is a property of the single card's marginal, not of the joint law; nothing is assumed about the dependence structure. Second, the definition of resolved is pointwise, not almost-sure; on a finite uniform space the distinction is immaterial, and the pointwise form is what one verifies in practice.

**Lemma 2.4.** $\mathbb{E}$ is linear: $\mathbb{E}[f+g] = \mathbb{E}[f] + \mathbb{E}[g]$, $\mathbb{E}[cf] = c\,\mathbb{E}[f]$, $\mathbb{E}[c] = c$, and for any finite family $(f_i)_{i \in S}$,
$$\mathbb{E}\Big[\sum_{i \in S} f_i\Big] = \sum_{i \in S} \mathbb{E}[f_i].$$

*Proof.* Immediate from the definition; the family version follows by induction on $|S|$. $\square$

**Lemma 2.5.** If $p$ is resolved with value $c$ then $\mathbb{E}[p] = c$.

---

## 3. The splitting theorem

**Theorem 3.1 (Splitting theorem, weighted form).** Let $\iota$ be a finite index set, $(p_i)_{i \in \iota}$ a family of cards on $\Omega$, $K \subseteq \iota$ a subset, and $(c_i)_{i \in K}$ rationals. Suppose

- $p_i$ is resolved with value $c_i$ for every $i \in K$, and
- $p_i$ is fair for every $i \notin K$.

Then
$$\mathbb{E}\Big[\sum_{i \in \iota} p_i\Big] = \sum_{i \in K} c_i .$$

*Proof sketch.* By linearity, $\mathbb{E}[\sum_i p_i] = \sum_i \mathbb{E}[p_i]$. Split the index set as $K \sqcup (\iota \setminus K)$. On $K$, Lemma 2.5 replaces each term by $c_i$. On $\iota \setminus K$, each term is $0$ by fairness. $\square$

**Corollary 3.2 (Headline form).** If every card of $K$ is resolved with value $1$ and every card outside $K$ is fair, then $\mathbb{E}[\sum_i p_i] = |K|$. Writing $d = |K|$: *$d$ cards predicted with certainty and any number of fair guesses are worth exactly $d$.*

**Corollary 3.3 (No edge from uncertainty alone).** If every card is fair then $\mathbb{E}[\sum_i p_i] = 0$, regardless of how the cards are correlated and how the guesses were chosen.

Corollary 3.3 is the take $K = \emptyset$ of Corollary 3.2 and is the formal content of the slogan. It is worth emphasising that it is *not* a statement about independent bets: linearity of expectation is indifferent to dependence, and every application below involves heavily dependent cards.

---

## 4. Shuffled decks: the blind game

### 4.1 The model and two counting identities

Let $\alpha$ be a finite set of size $u = |\alpha| \geq 1$, whose elements serve simultaneously as *slots* and as *cards*. The true arrangement is a uniformly random $\sigma \in \mathfrak{S}_\alpha$ (so $\Omega = \mathfrak{S}_\alpha$, $|\Omega| = u!$). A *strategy* is an arbitrary function $g : \alpha \to \alpha$: in slot $i$ the predictor calls card $g(i)$. Non-injective strategies are permitted.

**Definition 4.1.** For $i, a \in \alpha$ let $F(i,a) = \{\sigma : \sigma(i) = a\}$, and for $i,j,a,b$ let $F_2(i,j,a,b) = \{\sigma : \sigma(i) = a,\ \sigma(j) = b\}$.

**Theorem 4.2 (First counting identity).** $u \cdot |F(i,a)| = |\mathfrak{S}_\alpha|$ for all $i,a$.

*Proof sketch.* For $a,b \in \alpha$, the map $\sigma \mapsto \tau_{a b} \circ \sigma$, where $\tau_{ab}$ is the transposition exchanging $a$ and $b$, is a bijection $F(i,a) \to F(i,b)$ with inverse itself. Hence all $u$ sets $F(i,a)$, $a \in \alpha$, have the same cardinality; they are pairwise disjoint and their union is $\mathfrak{S}_\alpha$, because every $\sigma$ sends $i$ to exactly one card. $\square$

**Theorem 4.3 (Second counting identity).** For $i \neq j$ and $a \neq b$,
$$(u-1)\cdot|F_2(i,j,a,b)| = |F(i,a)| .$$

*Proof sketch.* Fix $i$ and $a$ and work inside $F(i,a)$. For $b, b' \in \alpha \setminus \{a\}$, left composition with $\tau_{b b'}$ maps $F_2(i,j,a,b)$ bijectively onto $F_2(i,j,a,b')$, and it preserves the constraint $\sigma(i)=a$ because $\tau_{bb'}$ fixes $a$. These $u-1$ classes partition $F(i,a)$, since $\sigma(j) \ne \sigma(i) = a$. $\square$

Neither proof mentions a factorial. This is not affectation: the transposition-symmetry form generalises verbatim to $j$-fold constraints, which is the route to higher moments (§9).

### 4.2 The slot formula and the block value

**Definition 4.4.** The *slot score* with hit payoff $w$ and miss payoff $\ell$ is
$$s_{w,\ell}(i,a;\sigma) = \begin{cases} w & \sigma(i) = a,\\ \ell & \text{otherwise.}\end{cases}$$
The *deck score* of strategy $g$ is $S_{w,\ell}(g;\sigma) = \sum_{i \in \alpha} s_{w,\ell}(i, g(i); \sigma)$, and the *hit count* is $\mathrm{hits}(g;\sigma) = \#\{i : \sigma(i) = g(i)\}$, so that $S_{1,0}(g;\sigma) = \mathrm{hits}(g;\sigma)$.

**Theorem 4.5 (Master slot formula).** For every $i, a \in \alpha$,
$$\mathbb{E}\big[s_{w,\ell}(i,a;\cdot)\big] = \frac{w-\ell}{u} + \ell .$$

*Proof sketch.* Write $s_{w,\ell}(i,a;\sigma) = (w-\ell)\mathbf{1}[\sigma(i)=a] + \ell$. Summing over $\sigma$ gives $(w-\ell)|F(i,a)| + \ell\,|\mathfrak{S}_\alpha|$; divide by $|\mathfrak{S}_\alpha|$ and apply Theorem 4.2, which says $|F(i,a)|/|\mathfrak{S}_\alpha| = 1/u$. $\square$

The right-hand side does not depend on $i$ or on $a$. Summing over the $u$ slots:

**Theorem 4.6 (Block value).** For every strategy $g$,
$$\mathbb{E}\big[S_{w,\ell}(g;\cdot)\big] = (w-\ell) + \ell u .$$

**Corollary 4.7 (Strategy invariance of the mean).** $\mathbb{E}[\mathrm{hits}(g;\cdot)] = 1$ for every $g$; equivalently $\sum_{\sigma} \mathrm{hits}(g;\sigma) = |\mathfrak{S}_\alpha|$.

For $g = \mathrm{id}$ this is the classical statement that a uniform random permutation has one fixed point in expectation. The content here is that the same holds for *every* $g$, including constant ones.

### 4.3 Rigidity of fair odds

**Theorem 4.8 (Rigidity).** For any strategy $g$,
$$\mathbb{E}\big[S_{w,\ell}(g;\cdot)\big] = 0 \iff w = \ell\,(1-u).$$

*Proof.* By Theorem 4.6 the expectation is $(w - \ell) + \ell u$, which vanishes iff $w = \ell - \ell u = \ell(1-u)$. $\square$

Because the criterion does not involve $g$, the block is edge-free for *one* strategy exactly when it is edge-free for *all* of them. Setting $\ell = -1$ gives $w = u-1$: the $(u-1):1$ quote, which is the honest price when $u$ candidates are equally likely. Fairness is thus characterised rather than assumed. Conversely, any $(w,\ell)$ with $w \ne \ell(1-u)$ endows every strategy with the same nonzero edge $(w-\ell)+\ell u$; the edge belongs to the book, not to the player.

**Corollary 4.9.** $\mathbb{E}[S_{u-1,-1}(g;\cdot)] = 0$ for every $g$.

### 4.4 The full deck and the counting anomaly

**Definition 4.10.** The *deck game* with $d$ resolved cards consists of the menu indexed by $\{1,\dots,d\} \sqcup \alpha$, where each resolved card pays the constant $1$ and the card at slot $i \in \alpha$ pays $s_{u-1,-1}(i, g(i); \sigma)$.

**Theorem 4.11 (Known versus unresolved cards).** For every $d \geq 0$ and every strategy $g$,
$$\mathbb{E}\Big[\sum_{c} \mathrm{payoff}(c)\Big] = d .$$

*Proof sketch.* Apply Theorem 3.1 with $K$ the copy of $\{1,\dots,d\}$: those cards are resolved with value $1$ by construction, and the cards of $\alpha$ are fair by Corollary 4.9 — but note that fairness is required *cardwise*, and Theorem 4.5 with $w = u-1$, $\ell = -1$ gives exactly $\mathbb{E}[s] = (u-1+1)/u - 1 = 0$ for each individual slot. $\square$

**Theorem 4.12 (Counting anomaly).** Under unit scoring the same deck yields
$$\mathbb{E}\big[d + S_{1,0}(g;\cdot)\big] = d + 1$$
for every $d$, every $g$, and every $u \geq 1$.

The discrepancy between Theorems 4.11 and 4.12 is exactly one card, uniformly in every parameter. It is entirely a pricing artefact: unit scoring rewards hits without charging for misses, and by Theorem 4.8 it is not a fair book unless $u = 1$. Any inference of an "edge from uncertainty" that is calibrated on hit counts rather than on a fair book will report exactly this $+1$, and will report it no matter how large the unresolved region is.

---

## 5. Second moments: what strategy does control

### 5.1 The injective and constant extremes

**Theorem 5.1.** If $u \ge 2$ and $g$ is injective, then $\sum_\sigma \mathrm{hits}(g;\sigma)^2 = 2\,|\mathfrak{S}_\alpha|$, i.e. $\mathbb{E}[\mathrm{hits}^2] = 2$ and $\operatorname{Var}[\mathrm{hits}] = 1$.

**Theorem 5.2.** If $g \equiv a$ is constant then $\mathrm{hits}(g;\sigma) = 1$ for every $\sigma$; hence $\mathbb{E}[\mathrm{hits}^2] = 1$ and $\operatorname{Var}[\mathrm{hits}] = 0$.

*Proof of 5.2.* $\{i : \sigma(i) = a\} = \{\sigma^{-1}(a)\}$ is a singleton. $\square$

Theorem 5.2 is a pleasing degenerate case: naming the same card in every slot yields exactly one correct call with probability one. The score is deterministic, not merely mean-one.

**Corollary 5.3 (Second-moment dichotomy).** For $u \ge 2$ and any $a \in \alpha$, the identity strategy and the constant-$a$ strategy have equal means and unequal variances:
$$\mathbb{E}[\mathrm{hits}(\mathrm{id})] = \mathbb{E}[\mathrm{hits}(a)] = 1, \qquad \operatorname{Var}[\mathrm{hits}(\mathrm{id})] = 1 \ne 0 = \operatorname{Var}[\mathrm{hits}(a)].$$

### 5.2 The collision formula

**Definition 5.4.** The *collision profile* of $g$ is the number of ordered pairs of slots receiving distinct calls,
$$D(g) = \#\{(i,j) \in \alpha \times \alpha : g(i) \ne g(j)\} = \sum_{i \in \alpha} \#\{j : g(i) \ne g(j)\}.$$
Thus $D(g) = u(u-1)$ if $g$ is injective and $D(g) = 0$ if $g$ is constant.

**Theorem 5.5 (Exact second moment).** For every strategy $g$ on a block of size $u$,
$$u(u-1)\sum_{\sigma}\mathrm{hits}(g;\sigma)^2 = \big(u(u-1) + D(g)\big)\,|\mathfrak{S}_\alpha| .$$

*Proof sketch.* Expand $\mathrm{hits}^2 = \sum_{i}\sum_{j}\mathbf{1}[\sigma(i)=g(i)]\mathbf{1}[\sigma(j)=g(j)]$ and sum over $\sigma$. The diagonal terms $i = j$ contribute $\sum_i |F(i,g(i))| = u \cdot |\mathfrak{S}_\alpha|/u = |\mathfrak{S}_\alpha|$ by Theorem 4.2. For $i \ne j$, the term is $|F_2(i,j,g(i),g(j))|$, which is $0$ when $g(i) = g(j)$ (a permutation cannot place one card in two slots) and equals $|F(i,g(i))|/(u-1) = |\mathfrak{S}_\alpha|/(u(u-1))$ when $g(i) \ne g(j)$, by Theorem 4.3. Counting the surviving off-diagonal pairs gives exactly $D(g)$ of them, whence the identity. $\square$

**Theorem 5.6 (Collision formula for the variance).** For $u \ge 2$ and every strategy $g$,
$$\operatorname{Var}\big[\mathrm{hits}(g;\cdot)\big] = \frac{D(g)}{u(u-1)} \in [0,1].$$

*Proof.* Divide Theorem 5.5 by $u(u-1)|\mathfrak{S}_\alpha|$ to get $\mathbb{E}[\mathrm{hits}^2] = 1 + D(g)/(u(u-1))$, and subtract $\mathbb{E}[\mathrm{hits}]^2 = 1$ from Corollary 4.7. $\square$

Theorems 5.1 and 5.2 are the endpoints $D = u(u-1)$ and $D = 0$. The formula is exact for every strategy, not merely for the extremes, and it makes precise the boundary of strategy invariance: **the first moment cannot see the strategy at all; the second moment sees precisely and only its pattern of repeated calls, normalised by the number of ordered slot pairs.**

The practical reading is that in a fairly priced game, choosing a strategy is choosing a risk profile. Maximal hedging (a constant call) delivers certainty of exactly one hit; maximal spread (an injective call) delivers a Poisson-like fluctuation of variance $1$; intermediate patterns of repeated calls interpolate linearly in $D(g)$.

---

## 6. Feedback: the value of information

### 6.1 The sequential model

Let $\alpha$ be a finite set with decidable equality. In the *feedback game* the predictor plays through the unresolved block one card at a time, and after each call the card is revealed. The only relevant state is the set $S$ of still-unseen cards.

**Definition 6.1.** A *feedback strategy* is a map $g : \mathcal{P}_{\mathrm{fin}}(\alpha) \to \alpha$. It is *admissible* if $g(S) \in S$ for every nonempty $S$ — it never names a card already seen.

**Definition 6.2.** Given payoff schedules $\mathrm{hit}, \mathrm{miss} : \mathbb{N} \to \mathbb{Q}$ (depending on the number of live cards), the value $V(S)$ of the game on live set $S$ is defined by $V(\emptyset) = 0$ and, for $S \ne \emptyset$,
$$V(S) = \frac{1}{|S|}\sum_{a \in S}\Big[\big(\mathrm{hit}(|S|)\ \text{if } g(S)=a\ \text{else}\ \mathrm{miss}(|S|)\big) + V(S \setminus \{a\})\Big].$$
The recursion terminates because $|S \setminus \{a\}| < |S|$.

**Lemma 6.3 (One-stage recursion).** If $S \ne \emptyset$ and $g(S) \in S$, then
$$V(S) = \frac{|S|\,\mathrm{miss}(|S|) + \big(\mathrm{hit}(|S|)-\mathrm{miss}(|S|)\big) + \sum_{a \in S} V(S\setminus\{a\})}{|S|}.$$

*Proof sketch.* Write the bracketed payoff as $\mathrm{miss}(|S|) + (\mathrm{hit}(|S|)-\mathrm{miss}(|S|))\mathbf{1}[g(S)=a]$ and use that exactly one $a \in S$ satisfies $g(S) = a$, by admissibility. $\square$

Admissibility is exactly the hypothesis that makes the indicator sum to $1$; for an inadmissible call the indicator sums to $0$ and the player scores a certain miss.

### 6.2 The unit-scoring value is harmonic

**Theorem 6.4.** With $\mathrm{hit} \equiv 1$ and $\mathrm{miss} \equiv 0$, every admissible feedback strategy satisfies
$$V(S) = H_{|S|}$$
for every finite $S$.

*Proof sketch.* Strong induction on $|S|$. For $S \ne \emptyset$ with $|S| = m$, Lemma 6.3 gives $V(S) = \big(1 + \sum_{a\in S} V(S \setminus\{a\})\big)/m$. Each erased set has $m-1$ elements, so by induction each $V(S\setminus\{a\}) = H_{m-1}$, and the sum over the $m$ choices of $a$ is $m H_{m-1}$. Hence $V(S) = 1/m + H_{m-1} = H_m$. $\square$

The value is thus *independent of the admissible strategy*: cleverness is irrelevant provided one never re-calls a seen card. Compare Corollary 4.7: a blind pass scores exactly $1$.

**Theorem 6.5 (Oresme bound).** $1 + n/2 \le H_{2^n}$ for every $n \ge 0$.

*Proof sketch.* Induction, using $\sum_{j=m+1}^{2m} 1/j \ge m \cdot \frac{1}{2m} = \frac12$ for $m \ge 1$. $\square$

**Corollary 6.6 (Unbounded advantage).** For every $C \in \mathbb{Q}$ and every admissible feedback strategy there is a finite live set $S$ with $V(S) > C$ under unit scoring. Meanwhile every blind strategy scores exactly $1$.

**Corollary 6.7 (Blind versus informed, quantitatively).** For $u \ge 2$, every blind strategy $g$ and every admissible feedback strategy $g_f$,
$$\mathbb{E}[\mathrm{hits}(g;\cdot)] = 1 < H_u = V(\alpha),$$
since $H_2 = 3/2$ and $H$ is monotone.

So feedback is worth exactly $H_u - 1 \sim \log u$ additional correct calls.

### 6.3 Fair odds are information-proof

**Theorem 6.8.** With the *stagewise fair* schedule $\mathrm{hit}(m) = m - 1$ and $\mathrm{miss}(m) = -1$, every admissible feedback strategy satisfies $V(S) = 0$ for every finite $S$.

*Proof sketch.* Strong induction on $|S|$. For $|S| = m \ge 1$, Lemma 6.3 gives
$$V(S) = \frac{m\cdot(-1) + \big((m-1) - (-1)\big) + \sum_{a \in S} V(S\setminus\{a\})}{m} = \frac{-m + m + 0}{m} = 0,$$
using the inductive hypothesis $V(S \setminus \{a\}) = 0$ for each of the $m$ successors. $\square$

**Corollary 6.9 (Both games are worth zero).** For a nonempty finite $\alpha$, every blind strategy $g$ and every admissible feedback strategy $g_f$,
$$\mathbb{E}[S_{u-1,-1}(g;\cdot)] = 0 \quad\text{and}\quad V_{\text{fair}}(\alpha) = 0 .$$

**Corollary 6.10 (Full deck with feedback).** $d$ resolved cards plus a feedback-played unresolved block at stagewise fair odds is worth exactly $d$.

The pair (Theorem 6.4, Theorem 6.8) is the sharpest statement in the paper. Information is genuinely valuable — worth an unbounded number of cards — but only against a static, mispriced book. Against a book that reprices at each stage to the honest $(m-1):1$ given $m$ live candidates, information is worth exactly nothing. What information buys is not an edge but a change in the fair price; it becomes an edge only when someone fails to update.

---

## 7. The learning-theoretic incarnation

### 7.1 Setup

Let $X$ be a finite domain. A *target* is a function $f : X \to \{\text{false},\text{true}\}$, drawn uniformly from the $2^{|X|}$ possibilities. A *learner* is a map $L$ from targets to hypotheses, $L(f) : X \to \{\text{false},\text{true}\}$. Fix a training set $T \subseteq X$ and impose:

- **(Blindness)** $L(f) = L(f')$ whenever $f$ and $f'$ agree on $T$;
- **(Consistency)** $L(f)(y) = f(y)$ for every $y \in T$ and every $f$.

Score each point $y$ by $+1$ if $L(f)(y) = f(y)$ and $-1$ otherwise. This is exactly the fair $(k-1):1$ book at $k = 2$.

### 7.2 The flip involution

**Definition 7.1.** For $x \in X$, let $\mathrm{flip}_x(f)$ agree with $f$ everywhere except at $x$, where it takes the opposite value.

**Lemma 7.2.** $\mathrm{flip}_x$ is an involution of the target space with no fixed points, and $\mathrm{flip}_x(f)$ agrees with $f$ on $X \setminus \{x\}$.

**Theorem 7.3 (Off-training cards are fair).** If $x \notin T$ and $L$ is blind, then
$$\sum_{f} \big(\mathbf{1}[L(f)(x) = f(x)] - \mathbf{1}[L(f)(x) \ne f(x)]\big) = 0 ,$$
i.e. the $\pm 1$ score at $x$ has mean zero.

*Proof sketch.* Since $x \notin T$, the targets $f$ and $\mathrm{flip}_x(f)$ agree on $T$; by blindness $L(\mathrm{flip}_x(f)) = L(f)$, so the *prediction* at $x$ is unchanged, while the *truth* at $x$ is flipped. Hence the score at $x$ under $\mathrm{flip}_x(f)$ is the negative of the score under $f$. As $\mathrm{flip}_x$ is a fixed-point-free involution, it pairs the target space into two-element orbits on which the scores cancel; summing over orbits gives $0$. $\square$

### 7.3 No Free Lunch

**Theorem 7.4 (No Free Lunch).** For every blind, consistent learner $L$,
$$\mathbb{E}\Big[\sum_{y \in X}\big(\pm 1 \text{ score at } y\big)\Big] = |T| .$$

*Proof sketch.* Apply Theorem 3.1 with cards indexed by $X$: for $y \in T$, consistency makes the card resolved with value $1$; for $y \notin T$, Theorem 7.3 makes it fair. $\square$

**Corollary 7.5 (Chance level off-sample).** The expected number of correctly predicted points is
$$|T| + \frac{|X| - |T|}{2} = \frac{|T| + |X|}{2}.$$

*Proof.* The $\{0,1\}$ accuracy indicator is $\tfrac12(1 + \text{the } \pm1 \text{ score})$; apply Theorem 7.4 and linearity. $\square$

**Theorem 7.6 (Sharpness).** Blindness cannot be dropped. With $T = \emptyset$, the "learner" $L(f) = f$ is consistent (vacuously) and achieves expected $\pm 1$ score $|X| \ne 0 = |T|$.

### 7.4 The $k$-ary generalisation

Let $k \ge 1$ and let labels take values in $\mathbb{Z}/k\mathbb{Z}$. Price a card at fair odds $(k-1):1$: score $k-1$ for a correct label and $-1$ otherwise. Replace the flip by $\mathrm{shift}_{x,t}(f)$, which adds $t \in \mathbb{Z}/k\mathbb{Z}$ to the label at $x$ and leaves all other labels alone.

**Theorem 7.7.** If $x \notin T$ and $L$ is blind, then $\sum_f \big((k-1)\mathbf{1}[L(f)(x)=f(x)] - \mathbf{1}[L(f)(x)\ne f(x)]\big) = 0$.

*Proof sketch.* The maps $\{\mathrm{shift}_{x,t}\}_{t}$ form a free action of $\mathbb{Z}/k\mathbb{Z}$ on target space whose orbits have size exactly $k$, all members of an orbit agreeing off $x$ and taking all $k$ values at $x$. Blindness makes the prediction at $x$ constant along an orbit, so exactly one member of each orbit is a hit, scoring $k-1$, and the other $k-1$ members each score $-1$. Each orbit contributes $(k-1) - (k-1) = 0$. $\square$

**Theorem 7.8 ($k$-ary No Free Lunch).** For every blind, consistent learner over a $k$-letter alphabet,
$$\mathbb{E}\Big[\sum_{y\in X}\big(\text{fair score at } y\big)\Big] = (k-1)\,|T| .$$

The orbit argument is the precise generalisation of the involution: at $k=2$ the group $\mathbb{Z}/2\mathbb{Z}$ acts by the flip and the fair odds $(k-1):1$ reduce to $\pm 1$. The interpretation is unchanged: training points are known cards paying the full $k-1$; off-training points are unresolved cards paying zero on average.

**Discussion.** The theorem does not say that learning is futile; it says that the uniform prior over targets is exactly an unresolved block. All generalisation performance of a working algorithm is borrowed from the fact that empirical targets are not uniformly distributed — from structure, from smoothness, from an inductive bias that is itself a form of resolved information. In the vocabulary of this paper: real problems have $d > |T|$.

---

## 8. No betting system beats a fair book

### 8.1 Adaptive stakes

Let the player observe a sequence of independent fair $\pm 1$ tosses, encoded as a finite history $h$ of booleans. A *betting system* is an arbitrary function $\mathrm{stake} : \{\text{histories}\} \to \mathbb{Q}$: before the next toss, the player stakes $\mathrm{stake}(h)$, winning that amount on heads and losing it on tails. Negative stakes are allowed (she may switch sides), unbounded stakes are allowed, and a stake of $0$ encodes "quit", so optional stopping is subsumed.

**Definition 8.1.** The expected net gain over a horizon of $n$ further tosses from history $h$ is defined by $G(0,h) = 0$ and
$$G(n+1, h) = \tfrac12\Big[\big(\mathrm{stake}(h) + G(n, h\!\frown\!\mathrm{H})\big) + \big(-\mathrm{stake}(h) + G(n, h\!\frown\!\mathrm{T})\big)\Big].$$

**Theorem 8.2 (No betting system).** $G(n,h) = 0$ for every system, every $n$, and every $h$.

*Proof.* Induction on $n$. The base case is by definition. For the step, the two occurrences of $\mathrm{stake}(h)$ cancel and both continuation values vanish by the inductive hypothesis, which applies to *every* history — including the two extensions. $\square$

**Corollary 8.3 (Optional stopping).** For any stopping rule, betting $\mathrm{bet}(h)$ until the rule fires and $0$ thereafter yields expected gain $0$ over every finite horizon.

The theorem is the finite-horizon optional stopping theorem, obtained here without measure theory: the sample space at each horizon is finite and the argument is a two-line induction. Its force is that adaptivity is fully general — the stake may depend on the entire past in an arbitrary, even non-measurable-looking, way, and the conclusion is unchanged.

### 8.2 The doubling paradox

**Definition 8.4.** The *doubling system* stakes $1$; after $k$ consecutive losses it stakes $2^k$; on the first win it stops.

**Lemma 8.5.** $2^k - \sum_{j=0}^{k-1} 2^j = 1$ for every $k \ge 0$.

*Proof.* Geometric sum: $\sum_{j<k} 2^j = 2^k - 1$. $\square$

Thus after $k$ losses the player is down $2^k - 1$, stakes $2^k$, and a win leaves her exactly one unit ahead.

**Definition 8.6.** Over a horizon of $n$ tosses the net gain of the doubling system is
$$D_n(w) = \begin{cases} -(2^n - 1) & \text{if every toss in } w \text{ is a loss},\\ +1 & \text{otherwise.}\end{cases}$$

**Theorem 8.7.** $\sum_{w \in \{\mathrm{H},\mathrm{T}\}^n} D_n(w) = 0$; equivalently $\mathbb{E}[D_n] = 0$.

*Proof sketch.* There are $2^n$ outcomes, exactly one of which is all-tails. Hence the sum is $(2^n - 1)\cdot 1 + \big(-(2^n-1)\big) = 0$. $\square$

**Theorem 8.8.** $\mathbb{P}[D_n > 0] = 1 - 2^{-n}$.

**Theorem 8.9 (Doubling paradox, resolved).** For every $\varepsilon > 0$ there is an $n$ with
$$\mathbb{E}[D_n] = 0 \quad\text{and}\quad \mathbb{P}[D_n > 0] > 1 - \varepsilon .$$

*Proof sketch.* Combine Theorems 8.7 and 8.8 and choose $n$ with $2^{-n} < \varepsilon$. $\square$

The resolution is quantitative and complete: the rare loss $-(2^n-1)$ is exactly as large as the frequent gain $+1$ is likely. **A high win rate is not an edge**, and Theorem 8.2 says the same in full generality: *any* system that wins small amounts almost always must be financing them with a rare loss of exactly compensating expected magnitude.

---

## 9. Algorithms

Three routines suffice to verify every identity above on concrete instances, and each is worth stating for its own sake.

**A. Exact block enumeration.** Enumerate $\mathfrak{S}_u$ and accumulate the exact rational moments of $\mathrm{hits}(g;\cdot)$ for a given $g$. Cost $O(u! \cdot u)$ time, $O(u)$ space. Feasible to $u \approx 9$ and sufficient to confirm the slot formula, the block value, the counting anomaly and the collision formula on the nose, with no floating-point error, since all quantities are rational with denominator dividing $u!$.

**B. Collision profile.** Compute $D(g) = \sum_i \#\{j : g(i)\ne g(j)\}$ in $O(u)$ time by tallying the multiset of call multiplicities: if the distinct called cards have multiplicities $m_1,\dots,m_r$ with $\sum m_t = u$, then $D(g) = u^2 - \sum_t m_t^2$. Combined with Theorem 5.6 this evaluates the exact variance in linear time, replacing an $O(u!)$ enumeration.

**C. Feedback recursion.** Evaluate $V(S)$ by the one-stage recursion of Lemma 6.3. Naively this is $O(u!)$, but under any admissible strategy the value depends on $S$ only through $|S|$, collapsing the recursion to the scalar iteration $V(m) = \big(m\cdot\mathrm{miss}(m) + \mathrm{hit}(m) - \mathrm{miss}(m)\big)/m + V(m-1)$ in $O(u)$ arithmetic operations. Instantiating $\mathrm{hit} \equiv 1, \mathrm{miss}\equiv 0$ gives $V(m) = 1/m + V(m-1) = H_m$; instantiating $\mathrm{hit}(m) = m-1$, $\mathrm{miss}(m)=-1$ gives $V(m) = 0 + V(m-1) = 0$.

---

## 10. Applications

**Calibration of predictive scores.** Theorem 4.8 gives an operational test for whether a scoring rule is a fair book: compute $(w-\ell) + \ell u$. If it is nonzero, every submission — including a degenerate one — earns the same spurious edge, and the leaderboard is measuring the rule rather than the predictors. Theorem 4.12 quantifies the most common failure mode, accuracy-style scoring, at exactly one unit.

**Card counting and information pricing.** Theorem 4.11 says that the value of tracked information is exactly the number of cards it resolves, and Theorem 6.8 says that this remains true when information arrives sequentially, provided the counterparty reprices. Real advantage therefore requires a *pricing lag*, and Corollary 6.6 bounds what that lag can be worth in the unit-scoring caricature: $H_u - 1$.

**Benchmark design in learning.** Corollary 7.5 says that the uniform-target average accuracy of *any* blind consistent learner is $(|T|+|X|)/2$. A benchmark that averages over unstructured targets therefore cannot distinguish algorithms at all; observed differences on real benchmarks measure the match between an algorithm's inductive bias and the structure of the target distribution, not a generic learning capability.

**Risk shaping under a fair book.** Theorem 5.6 gives an exact, linear-time knob: to attain variance $v \in [0,1]$ on the unresolved block, choose a calling pattern with $D(g) = v\,u(u-1)$, e.g. by partitioning the slots into groups that share a call. The mean is unaffected. This is a clean finite instance of the general principle that in a fair market only the risk profile is choosable.

**Money management.** Theorem 8.2 and Theorem 8.9 are the exact statements behind the standard warning about progression systems: any staking scheme, however adaptive, has zero expected gain at fair odds, and the systems that look best in short samples are precisely those whose losses are rarest and largest.

---

## 11. Discussion

Three themes recur.

**Linearity is enough, and it is indifferent to dependence.** Every application here involves strongly dependent cards — a permutation forbids repeated placements, a target's labels are shared by all points, a betting history conditions all future stakes. None of the proofs needs independence, because none of them needs anything beyond linearity of expectation and the cardwise fairness hypothesis. This is why the splitting theorem can be stated once and instantiated four times.

**"No edge" is a characterisation of fairness, not a corollary of it.** Theorem 4.8 is the pivot: the equation $w = \ell(1-u)$ is forced by demanding zero expectation for a single strategy, and it then delivers zero expectation for all. The same rigidity holds stagewise in the feedback game, where the schedule $\mathrm{hit}(m) = m-1$, $\mathrm{miss}(m) = -1$ is exactly the pointwise fair price given $m$ live candidates.

**The first moment is blind; the second moment is not.** Corollary 4.7 and Theorem 5.6 together delimit exactly how much of a strategy is visible to the payoff distribution. Nothing about $g$ is visible in the mean; precisely the equivalence relation "same call" is visible in the variance, through $D(g)$ and nothing else. It is an appealing state of affairs: the quantity a player cares about (return) is beyond her control, and the quantity she can control (risk) is described by a single combinatorial statistic she can compute in linear time.

A limitation worth stating plainly: everything here is exact and finite, and deliberately avoids limits. There are no central limit theorems, no concentration bounds, no infinite-horizon martingale convergence. Theorem 8.2 is a finite-horizon statement, and the doubling paradox is resolved *within* a finite horizon — which is in fact the honest setting, since the paradox's usual "resolution" by appeal to infinite time obscures that even at horizon $n$ the expectation is already exactly zero.

---

## 12. Future directions

Two questions stand out.

**A Bell-number moment hierarchy.** The two counting identities of §4.1 are the first two rungs of a ladder: the number of permutations pinned on a $j$-element set of slots ought to be $|\mathfrak{S}_u|/(u)_j$ where $(u)_j = u(u-1)\cdots(u-j+1)$, provable by the same transposition-symmetry argument applied $j$ times. Expanding $\mathrm{hits}^k$ over $k$-tuples of slots and grouping the tuples by the partition they induce should then yield, for an injective strategy $g$ and every $k \le u$,
$$\mathbb{E}\big[\mathrm{hits}(g;\cdot)^k\big] = B_k,$$
the $k$-th Bell number — since each set partition of $\{1,\dots,k\}$ into $j$ blocks contributes exactly $1$. That would say the hit count of a blind injective strategy is *exactly* Poisson$(1)$ in all moments up to order $u$, not merely asymptotically. For non-injective $g$ the moments should be strictly smaller for $k \ge 2$ and determined entirely by the set-partition statistics of the fibres of $g$, generalising Theorem 5.6. The missing ingredient is bookkeeping over set partitions, not new combinatorics.

**Sequential rigidity of fair odds.** Theorem 4.8 characterises fair odds in the one-shot game. Its sequential analogue is a conjecture: a history-dependent pricing $(w_S, \ell_S)$ makes the feedback game a zero-expectation bet for *every* admissible strategy if and only if $w_S = \ell_S(1 - |S|)$ at every reachable state $S$. The forward direction is Theorem 6.8 with general $\ell_S$; the converse requires exhibiting, at each state where the identity fails, a strategy that detects the discrepancy, which the one-stage recursion of Lemma 6.3 should supply by backward induction from the deepest violating state.

A third, more speculative direction: the collision profile $D(g)$ is a single scalar summarising the fibre structure of $g$. The Bell-number hierarchy suggests that the whole moment sequence is a function of the fibre *partition* of $g$, i.e. of an integer partition of $u$. Identifying which partitions are extremal for the $k$-th moment — a discrete optimisation over Young diagrams — would give a complete description of the achievable risk profiles in a fair blind prediction game.

---

## 13. Conclusion

We have given an exact calculus for prediction games mixing certainty with uncertainty, and shown that the value of such a game is precisely the number of cards known with certainty. The result is stable under everything one might hope would break it: arbitrary correlation, arbitrary and even degenerate strategies, sequential information, and unboundedly adaptive staking. It fails only when the book is mispriced, and then it fails by an amount that is a property of the book: exactly $+1$ for accuracy-style scoring in the blind game, exactly $H_u - 1$ for accuracy-style scoring in the feedback game. Where the player retains genuine freedom is in the second moment, where the exact collision formula $\operatorname{Var} = D(g)/(u(u-1))$ shows that she controls the risk of a fairly priced game completely, and its return not at all.
