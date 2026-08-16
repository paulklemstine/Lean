# The Geometry of Attention Sparsification: Concentration Floors, Tail Ceilings, and the Concavity of the Selection Gap

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

Top-$k$ attention replaces each row of an attention matrix by its $k$ largest entries, trading accuracy for a cost reduction of $\mathrm{ctx}/k$. The width at which a model's accuracy first clears a fixed bar — the *knee* $k^{*}$ — is an empirical quantity, but the laws that constrain it are not. We develop a self-contained mathematical theory of the knee for a single attention row, viewed as a probability vector $p$ on $n$ keys, and of the *selection gap* $G(k) = M(k) - k/n$ separating the optimal width-$k$ selection from a uniformly random one.

Five structural results anchor the theory. (i) **Concentration floor:** any width reaching captured mass $\tau$ satisfies $k \ge \tau^2 \cdot \mathrm{eff}(p)$, where $\mathrm{eff}(p) = 1/\sum_i p_i^2$ is the participation ratio; the exponent $2$ cannot be improved, as an explicit five-key spike profile shows. (ii) **Tail ceiling:** if the sorted weights obey $p_{(i)} \le c\,i^{-\alpha}$ with $\alpha > 1$, then $M(k) \ge 1 - \frac{c}{\alpha-1}k^{1-\alpha}$ and hence $k^{*} \le \big(\tfrac{c}{(\alpha-1)(1-\tau)}\big)^{1/(\alpha-1)}$; the analytic engine is a discrete tangent-line (Bernoulli) step, which replaces the exact telescoping available only at $\alpha = 2$. (iii) **Exact random control:** the expected captured mass of a uniformly random width-$k$ key set is exactly $k/n$, by a double count. (iv) **Concavity and unimodality:** a one-step exchange argument shows $M(k+2) + M(k) \le 2M(k+1)$, so $G$ is a concave sequence; concave sequences are unimodal, which re-derives $G \ge 0$ from shape alone and yields a falsifiable chord extrapolation of measured gaps. (v) **Peak location and total variation:** $G$ attains its maximum exactly at $k = |\{i : p_i > 1/n\}|$, with height $\sum_i (p_i - 1/n)^+ = \mathrm{TV}(p,\mathrm{unif})$; consequently no selection scheme can beat a random control by more than the total-variation distance to uniform, at any width, and if accuracy is $L$-Lipschitz in captured mass the accuracy gap is at most $L \cdot \mathrm{TV}$.

We also analyse the measurement protocol: pass predicates that are upward closed have a well-defined least passing width; a fail/pass pair brackets it; and when the bracket contains a unique sweep-grid point, two independent runs bracketed alike must report an identical knee, with a stated grid resolution $(1 - 1/\rho)b$ that is attained by an explicit step-shaped accuracy curve. Finally, we analyse the concave depth law $k^{*}(d) = C d^{2/3}$: it is concave and subadditive, has per-doubling factor $2^{2/3} \in (1.58, 1.59) < 2$, and forces any affine model calibrated on shallower rungs to over-predict on extrapolation.

We instantiate the theory at a measured cell — depth $d = 32$, context $\mathrm{ctx} = 512$ — where the knee is $k^{*} = 256$ at two independent seeds, effective support is $\approx 216.92$, and top-$256$ mass is $\approx 0.922$. The concentration floor independently forces $k > 183$; the total-variation floor forces $\mathrm{TV} \ge 0.422$; the fitted law predicts $24.7 \cdot 32^{2/3} \in (248.9, 249)$, within $3\%$ of the measured knee, while the affine alternative $8d + 32 = 288$ over-predicts by more than $11\%$ and the product law $k = \mathrm{ctx}$ yields a speedup of exactly $1$. The deployable speedup at the measured knee is exactly $2.0\times$.

**Keywords:** attention sparsification, top-$k$ selection, participation ratio, concave sequences, unimodality, total variation distance, power-law tails, scaling laws.

---

## 1. Introduction

### 1.1 The problem

A causal transformer at context length $\mathrm{ctx}$ evaluates, for every query position, a score against every admissible key position, and normalises the result into a probability vector. The dominant cost is the number of score evaluations, which is quadratic in the context. *Top-$k$ attention* keeps, for each row, only the $k$ largest entries; the cost becomes $\mathrm{ctx} \cdot k$ score evaluations instead of $\mathrm{ctx}^2$, and the speedup is exactly $\mathrm{ctx}/k$.

The engineering question is where to set $k$. The empirical answer is a *sweep*: measure a downstream metric at a grid of widths and report the smallest width whose metric clears a bar (typically a fixed fraction of the full-attention metric). The resulting width is the **knee** $k^{*}$.

The mathematical question — the subject of this paper — is what constrains the knee. Three sorts of constraint turn out to be provable.

* **Geometric constraints on a single attention row.** How much mass can $k$ keys carry? Bounded below by tail decay, bounded above by concentration. These pin $k^{*}$ into a sandwich.
* **Constraints on the control experiment.** A sparsification claim is meaningless without a baseline: how well does a *random* width-$k$ set do? Here the answer is exact, and the gap between the two has a rich and provable shape.
* **Constraints on the protocol.** A sweep on a coarse grid reports a number with a resolution. When is "the two seeds agree exactly" a fact about the runs, and when is it a fact about the grid?

We treat all three, then instantiate the theory at a concrete measured cell.

### 1.2 The measured cell

Throughout, the running numerical instance is a $32$-layer causal transformer ($d_{\text{model}} = 64$, $4$ heads, vocabulary $4097$, $2000$ optimiser steps on a public-domain text corpus) at context $\mathrm{ctx} = 512$, swept over widths
$$\mathcal{G} = \{96, 128, 160, 192, 224, 240, 256, 288, 320, 384, 512\}.$$

| quantity | seed 1 | seed 2 |
|---|---|---|
| full accuracy | $0.1353$ | $0.1350$ |
| full loss | $5.6281$ | $5.6482$ |
| accuracy bar ($0.98 \times$ full) | — | $0.1323$ |
| knee $k^{*}$ | $256$ | $256$ |
| knee bracket | $(224, 256]$ | $(240, 256]$ |
| effective support $\mathrm{eff}$ | $218.46$ | $216.92$ |
| top-$256$ mass | $0.921$ | $0.922$ |
| random-$k$ accuracy gap at $k=256$ | (not measured) | $+2.6$ |
| random-$k$ accuracy gap at $k=384$ | (not measured) | $+1.7$ |
| accuracy ratio at $k = 512$ | $1.000$ | $1.000$ |

At the second seed, width $240$ fails (ratio $0.978$ against bar $0.98$) and width $256$ passes (ratio $0.982$). Concentration reproduces to about $0.7\%$ across seeds.

None of these numbers is a theorem. Everything proved below is a *structural* statement, true of every attention row, together with arithmetic consequences of the reported numbers. That division is deliberate and is the honest way to read the results.

---

## 2. Setup and basic selection geometry

### 2.1 Definitions

**Definition 2.1 (attention row).** An *attention row* on $n$ keys is a vector $p = (p_1, \dots, p_n)$ with $p_i \ge 0$ and $\sum_{i=1}^n p_i = 1$.

**Definition 2.2 (admissible selections and captured mass).** For $k \in \mathbb{N}$, the *admissible width-$k$ selections* are the key sets $S$ with $|S| \le k$. The mass captured by $S$ is $\sum_{i \in S} p_i$. The *top-$k$ mass* is
$$M(k) \ = \ \max_{|S| \le k} \ \sum_{i \in S} p_i .$$
(The maximum is over a nonempty finite family, since $S = \emptyset$ is always admissible; hence $M$ is well defined, and $M(0) = 0$.)

**Definition 2.3 (effective support).** $\displaystyle \mathrm{eff}(p) = \frac{1}{\sum_i p_i^2}$, the participation ratio. It satisfies $1 \le \mathrm{eff}(p) \le n$, with the right extreme at the uniform row and the left at a point mass.

**Definition 2.4 (selection gap).** $\displaystyle G(k) = M(k) - \frac{k}{n}$. Proposition 4.2 justifies the subtracted term: $k/n$ is *exactly* the expected mass of a uniformly random width-$k$ selection.

**Definition 2.5 (cost and speedup).** The cost of top-$k$ causal attention at context $\mathrm{ctx}$ is $\mathrm{ctx}\cdot k$ score evaluations, and the speedup over full attention is $\mathrm{spd}(\mathrm{ctx}, k) = \mathrm{ctx}/k$.

### 2.2 Optimality of top-$k$

**Proposition 2.6 (selection optimality).** For every $S$ with $|S| \le k$, $\sum_{i \in S} p_i \le M(k)$. Consequently $0 \le M(k) \le 1$ and $M$ is nondecreasing in $k$.

*Proof.* Immediate from the definition of $M$ as a maximum over a family that is nonempty and grows with $k$; $M(k) \le 1$ because all weights are nonnegative and sum to one. $\square$

**Proposition 2.7 (strict improvement by swap).** If $|S| \le k$, $j \in S$, $i \notin S$, and $p_i > p_j$, then $\sum_{x \in S} p_x < M(k)$.

*Proof.* The set $S' = (S \setminus \{j\}) \cup \{i\}$ has $|S'| \le k$ and mass $\sum_{x\in S} p_x + (p_i - p_j) > \sum_{x \in S} p_x$; apply Proposition 2.6 to $S'$. $\square$

Proposition 2.7 is the precise sense in which any control that "misses a heavier key" is strictly suboptimal. It is the qualitative half of the random-control analysis; Section 4 supplies the quantitative half.

---

## 3. Two-sided bounds on the knee

### 3.1 The concentration floor

**Theorem 3.1 (Chebyshev bound on selected mass).** For every $k$,
$$M(k)^2 \ \le\ k \sum_{i} p_i^2 .$$

*Proof.* Let $S$ attain the maximum, so $M(k) = \sum_{i \in S} p_i$ and $|S| \le k$. Cauchy–Schwarz gives $\big(\sum_{i \in S} p_i\big)^2 \le |S| \sum_{i \in S} p_i^2$. Enlarging the second sum to all of $\{1,\dots,n\}$ (all terms nonnegative) and replacing $|S|$ by $k$ finishes the proof. $\square$

**Theorem 3.2 (concentration floor on the knee).** If $\tau \ge 0$ and $M(k) \ge \tau$, then
$$k \ \ge\ \tau^2 \cdot \mathrm{eff}(p).$$

*Proof.* Squaring the hypothesis (legitimate since $M(k) \ge \tau \ge 0$) and combining with Theorem 3.1 gives $\tau^2 \le k \sum_i p_i^2$; divide by the strictly positive quantity $\sum_i p_i^2$. $\square$

No selection rule whatsoever — greedy, learned, or oracular — can beat this floor. It converts a *measured* concentration statistic into a *proved* lower bound on the knee.

**Corollary 3.3 (instance).** With $\mathrm{eff}(p) = 216.92$, any width reaching mass $0.92$ satisfies $k > 183$.

*Proof.* $0.92^2 \cdot 216.92 = 0.8464 \cdot 216.92 > 183$. $\square$

The measured knee $256$ sits comfortably above this floor, and any claim of a knee near $96$ at this cell is refuted outright.

### 3.2 Sharpness of the floor

**Definition 3.4 (spike profile).** Let $q = (\tfrac12, \tfrac18, \tfrac18, \tfrac18, \tfrac18)$ on five keys.

**Theorem 3.5 (the square is necessary).** For the spike profile, $\sum_i q_i^2 = \tfrac14 + 4 \cdot \tfrac1{64} = \tfrac{5}{16}$, so $\mathrm{eff}(q) = \tfrac{16}{5}$, and $M(1) = \tfrac12$. Hence at $\tau = \tfrac12$ and $k = 1$:
$$\tau^2 \cdot \mathrm{eff}(q) = \tfrac{4}{5} \le 1 = k, \qquad\text{but}\qquad \tau \cdot \mathrm{eff}(q) = \tfrac{8}{5} > 1 = k .$$
Therefore Theorem 3.2 cannot be strengthened by replacing $\tau^2$ with $\tau$.

*Proof.* Direct computation; $M(1) = \max_i q_i = \tfrac12$. $\square$

**Theorem 3.6 (the floor is loose on flat rows).** For the uniform row on $n$ keys, $M(k) = k/n$ for $k \le n$ and $\mathrm{eff} = n$. Thus the true minimal width for target $\tau$ is $\lceil \tau n \rceil$, while the floor only certifies $\tau^2 n$ — a slack factor of $1/\tau$.

*Proof.* Every key carries $1/n$, so any $k$ keys carry $k/n$; and $\sum_i n^{-2} = 1/n$. $\square$

Theorems 3.5 and 3.6 bracket the quality of the floor: exactly tight in exponent, and quantitatively loose precisely when the row is flat — which is the regime where the knee is uninteresting anyway.

### 3.3 The tail ceiling

The complementary direction assumes decay of the sorted weights.

**Lemma 3.7 (tangent-line step).** For real $\alpha > 1$ and $x \ge 1$,
$$(\alpha - 1)(x+1)^{-\alpha} \ \le\ x^{1-\alpha} - (x+1)^{1-\alpha}.$$

*Proof sketch.* The right-hand side is $\int_x^{x+1} (\alpha-1) t^{-\alpha}\,dt$, and $t \mapsto t^{-\alpha}$ is decreasing, so the integral is at least $(\alpha-1)(x+1)^{-\alpha}$. Discretely and without integration, the inequality is Bernoulli's $1 + \alpha s \le (1+s)^\alpha$ at $s = 1/x$, rearranged: convexity of $t \mapsto t^{1-\alpha}$ supplies exactly the slack that the exact telescoping at $\alpha = 2$ supplies for free. $\square$

**Lemma 3.8 (power-tail sum bound).** For $\alpha > 1$ and $1 \le k \le n$,
$$\sum_{j=k}^{n-1} (j+1)^{-\alpha} \ \le\ \frac{k^{1-\alpha}}{\alpha - 1}.$$

*Proof.* Multiply Lemma 3.7 by $(\alpha-1)^{-1}$ and telescope over $x = k, k+1, \dots, n-1$: the sum is at most $\frac{1}{\alpha-1}\big(k^{1-\alpha} - n^{1-\alpha}\big) \le \frac{k^{1-\alpha}}{\alpha-1}$. $\square$

**Theorem 3.9 (mass bound under a power tail).** Suppose the keys can be ranked (by a permutation $\sigma$) so that $p_{\sigma(i)} \le c\,(i+1)^{-\alpha}$ for all $i = 0, 1, \dots, n-1$, with $c \ge 0$ and $\alpha > 1$. Then for $k \ge 1$,
$$M(k) \ \ge\ 1 - \frac{c}{\alpha - 1}\, k^{1-\alpha}.$$

*Proof.* Take $S$ to be the set of keys ranked in the first $k$ positions; $|S| \le k$, so $M(k) \ge \sum_{i \in S} p_i = 1 - \sum_{i \notin S} p_i$. The omitted keys are those at ranks $j \ge k$, and their total weight is at most $c \sum_{j=k}^{n-1}(j+1)^{-\alpha} \le \frac{c}{\alpha-1}k^{1-\alpha}$ by Lemma 3.8. $\square$

**Theorem 3.10 (tail ceiling on the knee).** Under the hypotheses of Theorem 3.9 and for a target $\tau < 1$, every width $k \ge 1$ with
$$k \ \ge\ \Big(\frac{c}{(\alpha-1)(1-\tau)}\Big)^{\!1/(\alpha-1)}$$
already satisfies $M(k) \ge \tau$; hence the knee for target $\tau$ obeys the same upper bound.

*Proof.* The stated inequality is equivalent, on raising to the power $\alpha - 1 > 0$, to $\frac{c}{\alpha-1}k^{1-\alpha} \le 1-\tau$; combine with Theorem 3.9. $\square$

For $\alpha = 2$ this reads $k^{*} \le c/(1-\tau)$, with the elementary telescoping bound $\sum_{j\ge k}(j+1)^{-2} \le 1/k$ in place of Lemma 3.8.

**Corollary 3.11 (instances at the measured cell, $n = 512$).**
*(a)* An inverse-square tail with $c = 20$ gives $M(256) \ge 1 - 20/256 \ge 0.92$.
*(b)* The much heavier tail $\alpha = 3/2$ with $c = 0.6$ gives $M(256) \ge 1 - \frac{0.6}{1/2}\,256^{-1/2} = 1 - 1.2/16 = 0.925 \ge 0.92$.
Both certify the measured top-$256$ mass $0.922$. Heavier tails do not obstruct a finite knee ceiling; they change only the rate.

**Theorem 3.12 (two-sided knee law).** Fix $\tau \in [0,1)$ and suppose a power (in particular inverse-square) tail with constant $c$. Then
$$\tau^2 \cdot \mathrm{eff}(p) \ \le\ k^{*}(\tau) \ \le\ \Big(\frac{c}{(\alpha-1)(1-\tau)}\Big)^{1/(\alpha-1)} .$$

*Proof.* Left: Theorem 3.2 applied to any passing width. Right: Theorem 3.10. $\square$

**Theorem 3.13 (comparison principle).** If two rows $p, q$ on the same key set satisfy $M_p(k) \ge M_q(k)$ for all $k$, then for every target $\tau$ the knee of $p$ is at most the knee of $q$: more concentrated rows have smaller knees.

*Proof.* Any width passing for $q$ passes for $p$; the knee is the least passing width. $\square$

---

## 4. The random control and the selection gap

### 4.1 Exact expected mass

**Lemma 4.1 (degree count).** For $1 \le k \le n$ and a fixed key $i$, the number of $k$-element key sets containing $i$ is $\binom{n-1}{k-1}$.

**Proposition 4.2 (expected mass of a random width-$k$ selection).** For $1 \le k \le n$, averaging over the $\binom{n}{k}$ subsets of size exactly $k$, chosen uniformly,
$$\mathbb{E}\Big[\sum_{i \in R} p_i\Big] \ = \ \frac{k}{n} .$$

*Proof.* Sum the captured mass over all $k$-subsets and exchange the order of summation: each key $i$ is counted once for each $k$-subset containing it, i.e. $\binom{n-1}{k-1}$ times, so the total is $\binom{n-1}{k-1}\sum_i p_i = \binom{n-1}{k-1}$. Dividing by $\binom{n}{k}$ and using $\binom{n-1}{k-1}/\binom{n}{k} = k/n$ gives the claim. $\square$

The identity is *exact* and *distribution-free*: the random control's expected captured mass does not depend on $p$ at all. This is precisely what makes it a legitimate baseline, and it justifies Definition 2.4.

**Corollary 4.3 (nonnegativity of the gap, by averaging).** $M(k) \ge k/n$ for $1 \le k \le n$, i.e. $G(k) \ge 0$: the maximum of a family is at least its average.

**Corollary 4.4 (instance).** At $(n,k) = (512, 256)$ the random control captures expected mass exactly $\tfrac12$; with measured $M(256) \ge 0.922$ the mass-level gap is at least $0.42$.

Measured *accuracy* gaps at the second seed were $+2.6$ at $k = 256$ and $+1.7$ at $k = 384$: positive, and diluting with width. The remainder of this section explains the sign, the dilution, the peak, and the ceiling.

### 4.2 Concavity by exchange

**Theorem 4.5 (concavity of the top-$k$ mass curve).** For every $k \ge 0$,
$$M(k+2) + M(k) \ \le\ 2\,M(k+1).$$

*Proof.* Choose optimal sets $S$ (with $|S| \le k+2$) and $T$ (with $|T| \le k$) attaining $M(k+2)$ and $M(k)$ respectively.

*Case 1: $|S| \le k+1$.* Then both $S$ and $T$ are admissible at width $k+1$, so $M(k+2) = \sum_{S} p \le M(k+1)$ and $M(k) = \sum_T p \le M(k+1)$; add.

*Case 2: $|S| = k+2$.* Then $|T| \le k < |S|$, so $S \not\subseteq T$ and there is $x \in S \setminus T$. The sets $S \setminus \{x\}$ and $T \cup \{x\}$ have cardinalities $|S| - 1 \le k+1$ and $|T| + 1 \le k+1$, hence are both admissible at width $k+1$, and
$$\Big(\sum_{S} p - p_x\Big) + \Big(p_x + \sum_T p\Big) = M(k+2) + M(k).$$
Each summand is at most $M(k+1)$, so the total is at most $2M(k+1)$. $\square$

The argument is a single exchange; no ordering, no analysis, no assumption on $p$ beyond nonnegativity.

**Definition 4.6 (concave sequence).** $f : \mathbb{N} \to \mathbb{R}$ is *concave* if $f(k+2) + f(k) \le 2f(k+1)$ for all $k$.

**Corollary 4.7.** $M$ is a concave sequence, and so is $G(k) = M(k) - k/n$, since subtracting an affine function preserves the defining inequality.

### 4.3 Concave sequences are unimodal

**Lemma 4.8 (antitone increments).** If $f$ is concave then $k \mapsto f(k+1) - f(k)$ is nonincreasing.

*Proof.* The defining inequality rearranges to $f(k+2) - f(k+1) \le f(k+1) - f(k)$; conclude by induction. $\square$

**Lemma 4.9 (telescoping).** $f(m+t) = f(m) + \sum_{s<t}\big(f(m+s+1) - f(m+s)\big)$.

**Lemma 4.10 (chord comparison).** If $f$ is concave and $i \le j$, then for every $t \ge 0$,
$$f(j+t) - f(j) \ \le\ f(i+t) - f(i).$$

*Proof.* Write both differences as sums of $t$ consecutive increments (Lemma 4.9) and compare them termwise using Lemma 4.8, since $i + s \le j + s$. $\square$

**Theorem 4.11 (unimodality).** If $f$ is concave and $i \le j \le m$, then
$$\min\big(f(i), f(m)\big) \ \le\ f(j).$$

*Proof.* If $f(i) \le f(j)$ we are done. Otherwise $f(j) < f(i)$, so not all increments on $[i, j)$ are nonnegative (else $f(i) \le f(j)$ by Lemma 4.9); pick $s$ with $f(i+s+1) - f(i+s) < 0$. By Lemma 4.8, every increment at an index $\ge i+s$ is $\le 0$; in particular all increments on $[j, m)$ are $\le 0$, so $f(m) \le f(j)$ by telescoping. $\square$

Informally: a concave sequence rises, then falls, and can never dip below both of its ends.

### 4.4 Consequences for the gap

**Theorem 4.12 (gap is concave and unimodal).** $G$ is a concave sequence, hence unimodal: $\min(G(i), G(m)) \le G(j)$ whenever $i \le j \le m$.

**Lemma 4.13 (endpoints).** $G(0) = 0$ and $G(n) = 0$.

*Proof.* $M(0) = 0$; and $M(n) = 1$ since all keys are admissible, while $n/n = 1$. $\square$

**Theorem 4.14 (nonnegativity from shape alone).** For $0 \le k \le n$, $G(k) \ge 0$.

*Proof.* Apply Theorem 4.12 with $i = 0$, $j = k$, $m = n$ and use Lemma 4.13. $\square$

This is a second, structurally different proof of Corollary 4.3: the first was a double count, this one uses only concavity and the two endpoint values. That two independent arguments agree is a useful consistency check on the modelling of the control.

**Theorem 4.15 (chord extrapolation; a falsifiable prediction).** Let $f$ be any concave sequence with $f(256) = 2.6$ and $f(384) = 1.7$. Then $f(512) \le 0.8$.

*Proof.* Lemma 4.10 with $i = 256$, $j = 384$, $t = 128$ gives $f(512) - f(384) \le f(384) - f(256) = -0.9$, so $f(512) \le 1.7 - 0.9 = 0.8$. $\square$

Applied to the measured accuracy gaps, this says: *if* the accuracy gap curve is concave, then the gap at full width $512$ is at most $+0.8$. A measured value above $0.8$ would refute concavity of the accuracy gap. (For the *mass* gap concavity is unconditional, by Theorem 4.5; the accuracy gap inherits it under the transfer hypothesis of Section 6.) At $k = n$ the gap is in fact $0$, since both selections take everything.

---

## 5. Where the peak sits: total variation

**Definition 5.1 (above-average keys, excess mass).** Let $A = \{i : p_i > 1/n\}$ and
$$E(p) \ = \ \sum_{i} \Big(p_i - \frac{1}{n}\Big)^{+} .$$

**Theorem 5.2 (excess mass is total variation).** $\displaystyle E(p) = \frac{1}{2}\sum_i \Big|p_i - \frac1n\Big| = \mathrm{TV}(p, \mathrm{unif})$.

*Proof.* The signed deviations $p_i - 1/n$ sum to $0$, so the total positive part equals the total negative part; each is half the sum of absolute values. Formally, $|x| = x^+ + x^-$ and $x = x^+ - x^-$ give $\sum |x_i| = 2\sum x_i^+$ when $\sum x_i = 0$. $\square$

**Lemma 5.3 (uniform-discounted mass).** For every key set $S$, $\displaystyle \sum_{i \in S} p_i - \frac{|S|}{n} \le E(p)$.

*Proof.* The left side is $\sum_{i \in S}(p_i - 1/n) \le \sum_{i \in S}(p_i - 1/n)^+ \le E(p)$. $\square$

**Theorem 5.4 (width-free ceiling on the gap).** For every $k$, $G(k) \le E(p) = \mathrm{TV}(p, \mathrm{unif})$.

*Proof.* Let $S$ attain $M(k)$, so $|S| \le k$ and $G(k) = \sum_{i\in S} p_i - k/n \le \sum_{i \in S} p_i - |S|/n \le E(p)$ by Lemma 5.3. $\square$

**Theorem 5.5 (the peak, exactly).** $G(|A|) = E(p)$; consequently $G$ attains its maximum at $k = |A|$, the number of above-average keys, and the maximum value is $\mathrm{TV}(p, \mathrm{unif})$.

*Proof.* Off $A$ the positive part vanishes, so $E(p) = \sum_{i \in A}(p_i - 1/n) = \sum_{i\in A} p_i - |A|/n \le M(|A|) - |A|/n = G(|A|)$, using admissibility of $A$ at width $|A|$. The reverse inequality is Theorem 5.4. Maximality follows since $G(k) \le E(p) = G(|A|)$ for all $k$. $\square$

**Theorem 5.6 (the peak is interior).** $|A| < n$: at least one key carries at most the uniform share.

*Proof.* If every key exceeded $1/n$ the weights would sum to more than $1$. $\square$

**Theorem 5.7 (total-variation floor on the knee).** If $M(k) \ge \tau$ then
$$k \ \ge\ n\big(\tau - \mathrm{TV}(p,\mathrm{unif})\big).$$

*Proof.* From Theorem 5.4, $\tau - k/n \le M(k) - k/n \le \mathrm{TV}$; rearrange. $\square$

This is a genuinely different floor from Theorem 3.2: one is driven by the participation ratio, the other by distance to uniform. Rows near uniform cannot have small knees, regardless of their participation ratio.

**Corollary 5.8 (instance).** With $n = 512$ and $M(256) \ge 0.922$, Theorem 5.4 forces
$$\mathrm{TV}(p, \mathrm{unif}) \ \ge\ 0.922 - \tfrac{256}{512} \ = \ 0.422 .$$
The measured concentration is thus, quantitatively, a statement that attention rows sit at total-variation distance at least $0.422$ from uniform attention.

---

## 6. From captured mass to accuracy

The measured quantity is accuracy, not captured mass. The bridge is a monotone concave response.

**Theorem 6.1 (concavity transfer).** If $f$ is a concave sequence and $g : \mathbb{R} \to \mathbb{R}$ is concave and nondecreasing, then $k \mapsto g(f(k))$ is a concave sequence.

*Proof.* Concavity of $f$ gives $\tfrac12 f(k+2) + \tfrac12 f(k) \le f(k+1)$; monotonicity of $g$ then gives $g\big(\tfrac12 f(k+2) + \tfrac12 f(k)\big) \le g(f(k+1))$, and concavity of $g$ gives $\tfrac12 g(f(k+2)) + \tfrac12 g(f(k)) \le g\big(\tfrac12 f(k+2) + \tfrac12 f(k)\big)$. Chain and multiply by $2$. $\square$

**Corollary 6.2 (shape of the sweep curve).** If accuracy is a concave nondecreasing function $g$ of captured mass, then $k \mapsto g(M(k))$ is concave, hence unimodal, with nonincreasing increments: each additional unit of width buys no more accuracy than the previous one did.

This is exactly the shape a knee sweep presupposes. Without it, "the smallest passing width" would not be a stable summary of the curve; with it, the pass predicate is upward closed and the protocol of Section 7 applies.

**Theorem 6.3 (Lipschitz ceiling on the accuracy gap).** Suppose accuracy responds to captured mass through $g$ with $g(x) - g(y) \le L(x - y)$ for $y \le x$ and some $L \ge 0$. Then for every $k \le n$,
$$g\big(M(k)\big) - g\big(k/n\big) \ \le\ L \cdot \mathrm{TV}(p, \mathrm{unif}) .$$

*Proof.* By Theorem 4.14, $k/n \le M(k)$, so the Lipschitz hypothesis applies and bounds the left side by $L\,G(k)$; then apply Theorem 5.4. $\square$

So a single classical statistical distance caps the entire Part-B-style control experiment, uniformly in the width: whatever the sparsification, its accuracy advantage over a random control cannot exceed $L$ times the distance from the attention row to uniform.

---

## 7. The measurement protocol: knees, brackets, grids

### 7.1 Knees

**Definition 7.1.** A predicate $P$ on widths is *upward closed* if $P(a)$ and $a \le b$ imply $P(b)$. Given that some width passes, the *knee* is $\min\{k : P(k)\}$.

**Proposition 7.2.** If $r$ is a nondecreasing accuracy curve and $\mathrm{bar}$ is a threshold, then $P(k) \equiv (r(k) \ge \mathrm{bar})$ is upward closed. Under Corollary 6.2 this hypothesis is not an assumption of convenience but a consequence of monotone concave response.

**Theorem 7.3 (bracket lemma).** If $P$ is upward closed, $\neg P(a)$, and $P(b)$, then the knee lies in $(a, b]$.

*Proof.* $P(b)$ gives knee $\le b$. If knee $\le a$ then upward closure would give $P(a)$, a contradiction; so knee $> a$. $\square$

### 7.2 Exact two-seed agreement is a grid theorem

**Lemma 7.4 (unique grid point).** On the sweep grid $\mathcal{G} = \{96, 128, 160, 192, 224, 240, 256, 288, 320, 384, 512\}$, the only element of $(240, 256]$ is $256$.

**Theorem 7.5 (two-seed exact agreement).** Let two runs have upward-closed pass predicates $P$ and $Q$ whose knees are grid points. If both fail at $240$ and both pass at $256$, then both knees equal $256$; in particular they are equal.

*Proof.* By Theorem 7.3 each knee lies in $(240, 256]$; by Lemma 7.4 the only grid point there is $256$. $\square$

The point is epistemic. At this resolution, "the two seeds reproduce exactly" is guaranteed by the bracket, not by an unlikely coincidence — which is exactly why the residual resolution must be reported alongside.

**Theorem 7.6 (grid resolution).** Suppose consecutive grid points $a < b$ with $b \le \rho a$ for a ratio $\rho \ge 1$, and suppose the true knee $k$ satisfies $a < k \le b$. Then
$$|b - k| \ \le\ \Big(1 - \frac{1}{\rho}\Big) b .$$

*Proof.* $b/\rho \le a < k \le b$, so $0 \le b - k < b - b/\rho = (1 - 1/\rho)b$. $\square$

**Corollary 7.7 (instance).** With $a = 240$, $b = 256$, $\rho = 16/15$, a knee reported as $256$ carries at most $16$ of absolute uncertainty; and two seeds bracketed in $(240, 256]$ have knees differing by strictly less than $16$.

**Theorem 7.8 (the resolution bound is attained).** For any $a < b$ let $r(k) = \mathbf{1}[k > a]$. Then $r$ is nondecreasing, fails at $a$, passes at $b$, and its true knee is $a+1$. A grid containing $a$ and $b$ but nothing between them can only report $b$, so the residual uncertainty $b - a - 1$ is realised exactly.

*Proof.* $r$ is a step function, hence monotone; $r(a) = 0 < 1 \le r(b)$; the least $k$ with $r(k) \ge 1$ is $a+1$. $\square$

---

## 8. The depth law

Sweeping the knee across model depths $d$ suggests a concave power law.

**Definition 8.1.** $k^{*}_{\text{law}}(d) = C\, d^{2/3}$, with fitted constant $C = 24.7$.

**Theorem 8.2 (shape).** For $C \ge 0$ the law is concave on $[0,\infty)$, and it is subadditive: $k^{*}_{\text{law}}(d_1 + d_2) \le k^{*}_{\text{law}}(d_1) + k^{*}_{\text{law}}(d_2)$ for $d_1, d_2 \ge 0$.

*Proof.* $d \mapsto d^{2/3}$ is concave for exponent in $[0,1]$; a concave function vanishing at $0$ is subadditive. $\square$

**Theorem 8.3 (per-doubling factor).** $k^{*}_{\text{law}}(2d) = 2^{2/3}\,k^{*}_{\text{law}}(d)$, and
$$1.58 \ <\ 2^{2/3}\ <\ 1.59, \qquad 2^{2/3} < 2 .$$

*Proof.* The identity is homogeneity of the power. For the bounds, cube: $(2^{2/3})^3 = 4$, and $1.58^3 = 3.944\ldots < 4 < 4.019\ldots = 1.59^3$; strict monotonicity of cubing on positives transfers the bounds. Since $2^3 = 8 > 4$, also $2^{2/3} < 2$. $\square$

So the depth leg is strictly sub-linear: doubling depth multiplies the knee by about $1.587$, not by $2$.

**Theorem 8.4 (affine extrapolation of a concave law over-predicts).** Let $f$ be concave on an interval and let $\ell$ be the affine function agreeing with $f$ at two calibration points $d_1 < d_2$. Then $\ell(d) \ge f(d)$ for every $d$ outside $[d_1, d_2]$ on the far side — in particular for $d > d_2$. Extrapolating an affine fit outward from a concave truth necessarily over-predicts.

*Proof.* Concavity says $f$ lies above its chords inside $[d_1,d_2]$ and below the extension of any chord outside it. Concretely, writing $d_2$ as a convex combination of $d_1$ and $d > d_2$, concavity gives $f(d_2) \ge \lambda f(d_1) + (1-\lambda) f(d)$ with $\lambda = (d - d_2)/(d - d_1)$; solving for $f(d)$ yields $f(d) \le \ell(d)$. $\square$

**Corollary 8.5 (numerics at the deepest rung).**
*(a)* $32^{2/3} \in (10.079, 10.080)$, hence $24.7 \cdot 32^{2/3} \in (248.9, 249)$: the concave law predicts $249$ against a measured knee of $256$, within $3\%$.
*(b)* The affine model $8d + 32$ predicts $288 > 1.11 \cdot 256$: an over-prediction exceeding $11\%$, which Theorem 8.4 shows to be structurally forced rather than accidental.
*(c)* The product law $k^{*} = \mathrm{ctx} = 512$ over-predicts by a factor of $2$.

**Theorem 8.6 (empirical exponent bracket).** The three measured per-doubling ratios $1.50$, $1.58$, $1.68$ have product $3.9816$. If an exponent $a$ reproduces them in the sense $2^{3a} = 3.9816$, then
$$0.6 \ <\ a\ <\ \tfrac23 .$$

*Proof.* Upper bound: $3.9816 < 4 = 2^2$, and $x \mapsto 2^x$ is strictly increasing, so $3a < 2$. Lower bound: $2^{9/5} < 3.9816$, since $\big(2^{9/5}\big)^5 = 2^9 = 512$ while $3.98^5 = 998.0\ldots > 512$; hence $3a > 9/5$. $\square$

The measured depth leg is therefore sub-linear and sits just below the fitted $2/3$ envelope — consistent with the fit, and a sharper falsifiable statement than "sub-linear".

---

## 9. Cost arithmetic

**Theorem 9.1.** With cost $\mathrm{ctx}\cdot k$ and speedup $\mathrm{spd}(\mathrm{ctx},k) = \mathrm{ctx}/k$:
*(a)* the product-law prescription $k = \mathrm{ctx}$ gives $\mathrm{spd} = 1$ — no saving whatsoever;
*(b)* $\mathrm{spd}(512, 256) = 2$ exactly;
*(c)* any knee with $2k \le \mathrm{ctx}$ gives $\mathrm{spd} \ge 2$.

*Proof.* Direct computation; (c) is $\mathrm{ctx}/k \ge 2 \iff 2k \le \mathrm{ctx}$ for $k > 0$. $\square$

This is where the mathematics pays rent. The distinction between a knee at $256$ and a knee at $512$ is precisely the distinction between a $2.0\times$ saving and none; and the concentration floor of Corollary 3.3 rules out any wishful knee below $184$ that would promise more than $2.8\times$ at this cell.

---

## 10. Algorithms

Three computational procedures accompany the theory.

**Algorithm A (top-$k$ mass curve and selection gap).** Sort the row descending, form prefix sums $M(k)$, and subtract $k/n$. Cost $O(n\log n)$ time, $O(n)$ space. Output: the full curves $M$ and $G$; the concavity of $M$ (Theorem 4.5) is a testable invariant of the output, as is the peak location $|A|$ (Theorem 5.5).

**Algorithm B (certified knee bracket).** Given a monotone pass oracle and a grid $\mathcal{G}$, binary search for the least passing grid point $b$ and its predecessor $a$. Returns the certified bracket $(a, b]$ and the resolution $(1 - 1/\rho)b$ with $\rho = b/a$ (Theorems 7.3 and 7.6). Cost $O(\log|\mathcal{G}|)$ oracle calls.

**Algorithm C (two-sided knee sandwich).** From a row, compute $\mathrm{eff}$ and the concentration floor $\tau^2\mathrm{eff}$; fit a power tail $(c, \alpha)$ to the sorted weights and compute the ceiling $\big(\tfrac{c}{(\alpha-1)(1-\tau)}\big)^{1/(\alpha-1)}$; report the interval (Theorem 3.12). Cost $O(n \log n)$.

---

## 11. Applications

**Deployment sizing.** The concentration floor gives an *a priori* refutation of over-optimistic widths from a statistic ($\mathrm{eff}$) computable from a single forward pass, with no retraining. The tail ceiling gives the complementary sufficient width from a two-parameter fit of the sorted attention profile.

**Designing the control.** Proposition 4.2 makes the random-$k$ control exactly calibrated: its expected captured mass is $k/n$ with no dependence on the model. Theorem 5.4 then caps how large the measured advantage can possibly be, so an implausibly large reported gap is a signal of an instrumentation bug rather than of a strong result.

**Diagnostics from shape.** Concavity of the mass curve and (under monotone concave response) of the accuracy curve gives cheap sanity checks on a sweep: increments must be nonincreasing, the curve must be unimodal, and the gap must vanish at full width. Theorem 4.15 turns two measured gaps into a bound on a third.

**Interpreting concentration.** Theorem 5.2 identifies the maximal achievable selection advantage with the total-variation distance to uniform, converting an engineering statistic into a classical statistical distance — and, via Theorem 5.7, into a second knee floor.

---

## 12. Discussion and limitations

The theory is exact and assumption-light, but it is a theory of a *single attention row*, whereas a model has many rows, heads, and layers, and its accuracy depends on all of them jointly. Bridging that gap requires the monotone concave response hypothesis of Section 6, which is a modelling assumption, not a theorem: it is what converts mass-level statements into accuracy-level ones. We have been careful to state which results depend on it (Corollary 6.2, Theorem 6.3, and the applied reading of Theorem 4.15) and which do not (everything in Sections 2–5, 7–9).

The empirical numbers are measurements at a small scale — a $32$-layer model with $d_{\text{model}} = 64$ at context $512$, trained for $2000$ steps. What the mathematics contributes is not confirmation of those numbers but their interpretation: which of them are constrained by structure (the sign of the gap, the shape of the curve, the bracket arithmetic, the over-prediction of affine extrapolation) and which are free (the constant $C$, the tail parameters, the accuracy bar).

Finally, resolution. Reporting a knee of $256$ from a grid whose local ratio is $16/15$ means, honestly, "$k^{*} \in (240, 256]$", and Theorem 7.8 shows this cannot be sharpened without a finer grid: an adversarial step curve puts the true knee at $241$. Two-seed agreement at this resolution is therefore evidence of stability, not of a precisely reproduced integer.

---

## 13. Future directions

**Sharper tail models.** The power-tail ceiling is driven by a single exponent. Stretched-exponential or log-normal profiles fit real attention rows better in some regimes; the tangent-line technique of Lemma 3.7 should adapt, replacing $t^{-\alpha}$ by any convex-integrable decreasing majorant.

**Multi-row aggregation.** A model's accuracy depends on all rows simultaneously. A natural next object is the *joint* gap, $\sum_{\text{rows}} G_r(k)$, whose concavity is inherited termwise but whose peak is governed by an averaged total-variation distance. Locating that peak, and bounding the discrepancy between per-row and global knees, is open.

**Learned selection versus top-$k$.** Theorem 5.4 caps every selection scheme by $\mathrm{TV}(p,\mathrm{unif})$, and top-$k$ attains the cap at $k = |A|$. Off the peak, top-$k$ is strictly below the cap; quantifying the shortfall as a function of the tail exponent would say precisely when a cheaper approximate selector loses nothing.

**Depth law at deeper rungs.** The measured exponent bracket $0.6 < a < 2/3$ is derived from three doublings. Extending the ladder tests whether the exponent drifts — the concave law predicts a fixed $2/3$; a drifting exponent would indicate that the depth law is itself a local linearisation of something slower.

**Verifying the chord prediction.** Theorem 4.15 predicts an accuracy gap of at most $+0.8$ at full width from measured gaps of $+2.6$ and $+1.7$. Measuring it is a cheap, direct test of the monotone concave response hypothesis.

---

## 14. Conclusion

The width of attention is governed by geometry that is, gratifyingly, elementary. Cauchy–Schwarz floors the knee at $\tau^2$ times the participation ratio, with the square provably necessary. A discrete tangent-line estimate ceilings it under any power tail with exponent above one. A double count makes the random control exactly $k/n$, and a one-step exchange argument makes the mass curve concave — from which unimodality, nonnegativity of the selection gap, diminishing returns, and a falsifiable chord bound all follow. The peak of the gap sits exactly at the above-average keys, and its height is exactly the total-variation distance to uniform, which also caps the accuracy advantage of any selection scheme under a Lipschitz response.

On top of this geometry, the measurement protocol becomes analysable: upward-closed pass predicates have least passing widths, fail/pass pairs bracket them, and a bracket containing a unique grid point makes exact cross-seed agreement a theorem about the grid with an explicit, attained resolution. At the deepest measured rung — depth $32$, context $512$ — the knee is $256$ at two seeds, the concentration floor independently forces it above $183$, the attention rows lie at total-variation distance at least $0.422$ from uniform, the concave law $24.7\,d^{2/3}$ predicts $249$, the affine alternative over-predicts by more than $11\%$ by a structural necessity, the product law would deliver a speedup of exactly $1$, and the measured knee delivers exactly $2.0\times$.
