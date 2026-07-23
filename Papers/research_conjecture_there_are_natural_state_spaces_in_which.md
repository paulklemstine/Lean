# Robust Reconstruction Bounds for Functional Observation: A Metric Bridge Between Hidden Fibres and Statistical Risk

## Abstract

We study the following universal obstruction. Let a *functional observation* $F : X \to B$ record what an instrument can see about a state $x$ in a state space $X$, and let an *experience observable* $E : X \to Y$ record a hidden quantity of interest, where $B$ and $Y$ are metric (more precisely, pseudometric) spaces. A *reconstruction* is any map $R : B \to Y$ that attempts to recover the hidden value from the observation. We prove that whenever two states are close under $F$ but far under $E$, every Lipschitz reconstruction incurs a quantitatively forced error. Concretely, scoring the reconstruction by its expected loss on the uniform two-point distribution — the *pair risk* — we show that if $\operatorname{dist}(F(x),F(z)) \le \varepsilon$, $\operatorname{dist}(E(x),E(z)) \ge \delta$, and $R$ is $K$-Lipschitz, then the pair risk is at least $(\delta - K\varepsilon)/2$. Specializing to exact functional identity ($F(x)=F(z)$, equivalently $\varepsilon=0$) removes the Lipschitz hypothesis entirely and yields the clean impossibility bound $\delta/2$, together with a pointwise "worst-case" version guaranteeing that at least one state suffers error at least $\delta/2$. These statements require no compactness, finiteness, or structural assumption on $X$; they are pure consequences of the triangle inequality. We interpret the pair risk as a Bayes risk in statistical decision theory, thereby building a bridge from the geometry of observation fibres to lower bounds on reconstruction risk, and we discuss consequences for representation learning, lossy sensing, and the quantitative content of the "zombie twin" thought experiment.

**Keywords:** reconstruction risk, Lipschitz decoder, triangle inequality, metric geometry, functional observation, information bottleneck, minimax lower bound, pair risk, fibre obstruction.

## 1. Introduction

A recurring theme across mathematics, statistics, and the theory of computation is that *information discarded by a map cannot be recovered by anything applied after it*. In representation learning this is the intuition behind information bottlenecks; in statistics it is the data-processing inequality; in the philosophy of mind it appears dressed up as the "zombie twin," a being functionally identical to a conscious agent yet lacking inner experience. In each guise the underlying picture is the same: an *observation* map collapses states that a hidden *experience* map keeps distinct, and one asks how faithfully the hidden quantity can be reconstructed from the observation alone.

This paper isolates the metric core of that picture and proves that it is governed by a single, sharp, robust inequality. We deliberately work at the lowest possible level of structure — pseudometric target spaces and Lipschitz decoders — so that the resulting bounds apply uniformly to finite metric spaces, compact manifolds, function spaces, and abstract state spaces alike.

### Contributions

1. **A robust fibre–risk bridge (Theorem 3.1).** For any observation $F$, experience observable $E$, and $K$-Lipschitz reconstruction $R$, two states that are $\varepsilon$-close under $F$ but $\delta$-far under $E$ force pair risk at least $(\delta - K\varepsilon)/2$.
2. **An exact impossibility endpoint (Theorem 3.3).** When $F(x)=F(z)$, the Lipschitz hypothesis is unnecessary and the bound becomes $\delta/2$ for *every* reconstruction.
3. **A pointwise worst-case bound (Theorem 3.5).** Under $F(x)=F(z)$, the *maximum* of the two reconstruction errors is at least $\delta/2$: the error cannot be concentrated away from view.
4. **A decision-theoretic reading (Section 4).** The pair risk equals the Bayes risk of the uniform two-point experiment, so the bounds are genuine minimax-flavored lower bounds on reconstruction risk.

## 2. Setup and Definitions

Throughout, let $X$ be an arbitrary set (the *state space*; no topology or measure is assumed). Let $(B, \operatorname{dist}_B)$ and $(Y, \operatorname{dist}_Y)$ be pseudometric spaces; we drop the subscripts when the space is clear from context. Recall that a pseudometric satisfies all the axioms of a metric except that distinct points may have distance zero — this generality costs nothing in the proofs and broadens applicability.

**Definition 2.1 (Functional observation).** A *functional observation* is a map $F : X \to B$. Its value $F(x)$ models everything an admissible instrument can register about the state $x$. Two states with $F(x)$ near $F(z)$ are *functionally similar*; states with $F(x)=F(z)$ are *functionally identical* and are said to lie in a common *fibre* of $F$.

**Definition 2.2 (Experience observable).** An *experience observable* is a map $E : X \to Y$. Its value $E(x)$ models the hidden quantity of interest — an inner experience, a true label, or any target property not directly accessible to the instrument.

**Definition 2.3 (Reconstruction / decoder).** A *reconstruction* is a map $R : B \to Y$. Given an observation $b = F(x)$, the value $R(b)$ is the decoder's estimate of the experience. The *reconstruction error at $x$* is $\operatorname{dist}\big(E(x), R(F(x))\big)$.

**Definition 2.4 (Lipschitz reconstruction).** For $K \ge 0$, a reconstruction $R$ is *$K$-Lipschitz* if $\operatorname{dist}(R(b), R(b')) \le K\, \operatorname{dist}(b, b')$ for all $b, b' \in B$. This is a stability requirement: the decoder amplifies input discrepancies by a factor of at most $K$.

**Definition 2.5 (Pair risk).** For states $x, z \in X$, the *pair risk* of a reconstruction $R$ is
$$\operatorname{pairRisk}(F, E, R; x, z) \;=\; \frac{\operatorname{dist}\big(E(x), R(F(x))\big) + \operatorname{dist}\big(E(z), R(F(z))\big)}{2}.$$
Equivalently, it is the expected reconstruction error when the state is drawn uniformly from $\{x, z\}$, i.e. the risk of $R$ under the uniform two-point probability distribution on those states.

## 3. Main Results

### 3.1 The robust reconstruction lower bound

**Theorem 3.1 (Robust fibre–risk bridge).** Let $F : X \to B$, $E : X \to Y$, and $R : B \to Y$ with $B, Y$ pseudometric. Fix states $x, z \in X$, a Lipschitz constant $K \ge 0$, and reals $\varepsilon, \delta$. Suppose
$$R \text{ is } K\text{-Lipschitz}, \qquad \operatorname{dist}(F(x), F(z)) \le \varepsilon, \qquad \delta \le \operatorname{dist}(E(x), E(z)).$$
Then
$$\frac{\delta - K\varepsilon}{2} \;\le\; \operatorname{pairRisk}(F, E, R; x, z).$$

*Proof.* Write $a = E(x)$, $c = E(z)$, $p = R(F(x))$, $q = R(F(z))$. Since $R$ is $K$-Lipschitz and $\operatorname{dist}(F(x),F(z)) \le \varepsilon$,
$$\operatorname{dist}(p, q) = \operatorname{dist}(R(F(x)), R(F(z))) \le K\,\operatorname{dist}(F(x),F(z)) \le K\varepsilon. \tag{1}$$
By the (four-point) triangle inequality applied to the chain $a \to p \to q \to c$,
$$\operatorname{dist}(a, c) \le \operatorname{dist}(a, p) + \operatorname{dist}(p, q) + \operatorname{dist}(q, c). \tag{2}$$
Combining $\delta \le \operatorname{dist}(a,c)$ with (1) and (2), and using symmetry $\operatorname{dist}(q,c) = \operatorname{dist}(c,q)$,
$$\delta \le \operatorname{dist}(a,p) + K\varepsilon + \operatorname{dist}(c, q).$$
Hence $\operatorname{dist}(a,p) + \operatorname{dist}(c,q) \ge \delta - K\varepsilon$. Dividing by $2$ gives exactly $\operatorname{pairRisk} \ge (\delta - K\varepsilon)/2$. $\qquad\blacksquare$

**Remark 3.2 (Budget interpretation).** Read $\delta$ as the total experiential contrast to be reconstructed. The term $K\varepsilon$ is the maximal contrast a stable decoder can *legitimately* produce from an observation discrepancy of size $\varepsilon$. The residual $\delta - K\varepsilon$ is forced into reconstruction error and split, evenly in the worst case, between the two states. When $\delta \le K\varepsilon$ the bound is vacuous (non-positive) — precisely the regime in which the instrument's resolution is fine enough to account for the contrast on its own. No assumption on $X$ (compactness, finiteness, topology) is used anywhere.

### 3.2 The exact endpoint

**Theorem 3.3 (Exact reconstruction lower bound).** With notation as above, suppose $F(x) = F(z)$ and $\delta \le \operatorname{dist}(E(x), E(z))$. Then for *every* reconstruction $R$ (Lipschitz or not),
$$\frac{\delta}{2} \;\le\; \operatorname{pairRisk}(F, E, R; x, z).$$

*Proof.* Since $F(x)=F(z)$, we have $R(F(x)) = R(F(z)) =: g$. The triangle inequality on $E(x) \to g \to E(z)$ gives
$$\delta \le \operatorname{dist}(E(x),E(z)) \le \operatorname{dist}(E(x), g) + \operatorname{dist}(g, E(z)) = \operatorname{dist}(E(x), R(F(x))) + \operatorname{dist}(E(z), R(F(z))),$$
using symmetry in the last step. Dividing by $2$ yields the claim. $\qquad\blacksquare$

**Corollary 3.4.** Theorem 3.3 is the $\varepsilon = 0$ case of Theorem 3.1 with the Lipschitz hypothesis dropped: when $F(x)=F(z)$ one may take $\varepsilon = 0$, and the term $K\varepsilon$ vanishes regardless of $K$, so no stability assumption on $R$ is needed.

### 3.3 The pointwise worst-case bound

**Theorem 3.5 (Worst-case leakage).** Suppose $F(x) = F(z)$ and $\delta \le \operatorname{dist}(E(x), E(z))$. Then
$$\frac{\delta}{2} \;\le\; \max\Big(\operatorname{dist}(E(x), R(F(x))),\ \operatorname{dist}(E(z), R(F(z)))\Big).$$

*Proof.* Let $g = R(F(x)) = R(F(z))$. As in Theorem 3.3, $\delta \le \operatorname{dist}(E(x), g) + \operatorname{dist}(E(z), g)$. If both summands were strictly below $\delta/2$ their sum would be below $\delta$, a contradiction; hence at least one is at least $\delta/2$, which is the maximum. $\qquad\blacksquare$

**Remark 3.6.** Theorem 3.5 strengthens the *average* bound of Theorem 3.3 into an $\ell^\infty$ statement: the reconstruction error cannot be swept into a single unobserved state while keeping the other exact. This distinction matters when the loss criterion is worst-case rather than average.

### 3.4 Sharpness

The constant $\tfrac12$ is attained. Take $Y = \mathbb{R}$ with the usual metric, $E(x) = 0$, $E(z) = \delta$, and $F(x) = F(z)$. The best constant decoder outputs the midpoint $g = \delta/2$, achieving $\operatorname{dist}(E(x), g) = \operatorname{dist}(E(z), g) = \delta/2$ and hence pair risk exactly $\delta/2$. Thus Theorem 3.3 is tight, and — letting the two functional readouts separate to distance $\varepsilon$ and choosing a decoder with $\operatorname{dist}(R(F(x)), R(F(z))) = K\varepsilon$ — Theorem 3.1 is tight as well.

## 4. A Decision-Theoretic Bridge

The pair risk is not an ad hoc score. Consider the statistical experiment in which nature selects a state $S \in \{x, z\}$ uniformly at random, an instrument reports the observation $F(S)$, and a decision rule $R$ must output an estimate of the experience $E(S)$, incurring metric loss $\operatorname{dist}(E(S), R(F(S)))$. The frequentist risk of $R$ in this experiment is
$$\mathbb{E}\big[\operatorname{dist}(E(S), R(F(S)))\big] = \tfrac12\operatorname{dist}(E(x),R(F(x))) + \tfrac12\operatorname{dist}(E(z),R(F(z))) = \operatorname{pairRisk}(F,E,R;x,z).$$
Theorems 3.1 and 3.3 are therefore lower bounds on the Bayes risk of this two-point experiment that hold *uniformly over the entire decoder class* (all maps, or all $K$-Lipschitz maps). This places the results squarely in the tradition of minimax lower bounds: they certify that no estimator — regardless of sample size, model capacity, or training procedure — can beat $(\delta - K\varepsilon)/2$ once the observation channel $F$ has been fixed. Crucially, the bound is *constructive and adversary-free*: it follows from exhibiting a single hard pair $(x,z)$, not from a two-point Le Cam argument invoking hypothesis testing.

## 5. Algorithms

Although the theorems are existential lower bounds, they are eminently computable and yield practical diagnostics for representation quality. We describe two.

### 5.1 Certified reconstruction floor for a lossy channel

Given finite samples of states with their observations $F(x)$ and experiences $E(x)$, one can *certify* a lower bound on the achievable reconstruction risk of any $K$-Lipschitz decoder by searching for the pair maximizing $\delta - K\varepsilon$.

```
Input: finite states x_1,...,x_n; maps F, E; distances dist_B, dist_E; constant K
Output: certified pair-risk floor
best <- -infinity
for each pair (i, j) with i < j:
    eps   <- dist_B(F(x_i), F(x_j))
    delta <- dist_E(E(x_i), E(x_j))
    floor <- (delta - K*eps) / 2
    if floor > best: best <- floor, argbest <- (i, j)
return max(best, 0), argbest
```
This runs in $O(n^2)$ distance evaluations and returns a witness pair together with the guaranteed floor $\max(0, (\delta - K\varepsilon)/2)$.

### 5.2 Optimal two-point decoder value

For a witnessed pair in $Y = \mathbb{R}^d$ under the Euclidean metric, the best constant decoder value $g$ minimizing the pair risk on a functionally-identical pair is the midpoint $g = \tfrac12(E(x)+E(z))$, giving pair risk exactly $\tfrac12\|E(x)-E(z)\|$. This confirms tightness numerically and provides the exact optimum against which any learned decoder can be compared.

## 6. Applications

- **Representation learning.** If a feature map $F$ (an encoder) merges two inputs whose labels differ by $\delta$ while its readouts differ by at most $\varepsilon$, then any $K$-Lipschitz predictor $R$ (a stable decoder head) suffers average error at least $(\delta - K\varepsilon)/2$. The bottleneck is provably in the *representation*, not the *head*: no amount of additional model capacity downstream can help. This gives a per-pair, certificate-style diagnostic complementing global information-theoretic bounds.

- **Lossy sensing and quantization.** When $F$ is a quantizer or a bandwidth-limited sensor, $\varepsilon$ is its resolution. The theorem converts resolution directly into an unavoidable reconstruction-risk floor for any stable reconstruction algorithm, independent of post-processing.

- **Fairness and calibration.** If protected-group membership plays the role of $E$ and an audited feature vector plays the role of $F$, functionally-close individuals with divergent hidden attributes impose an irreducible calibration error on any Lipschitz scoring rule.

- **Philosophy of mind, made quantitative.** If experience genuinely varies over functionally identical states, then any theory reconstructing experience from function must average at least $\delta/2$ error on such pairs. The "zombie twin" impossibility acquires a number.

## 7. Discussion

The results are striking for how little they assume and how widely they apply. The only ingredients are a triangle inequality in the target space and, in the robust case, a Lipschitz stability bound on the decoder. There is no measure theory, no compactness, no dimension, and no probabilistic independence — yet the conclusion is a genuine statistical risk bound. The exact case is a crisp impossibility theorem (a hidden contrast forces half itself into error); the robust case is its engineering refinement, in which blindness is a matter of degree $\varepsilon$ and the floor degrades linearly, vanishing exactly when the channel's resolution suffices to explain the contrast.

Two features deserve emphasis. First, *pseudometric generality*: allowing $\operatorname{dist}(b,b')=0$ for distinct $b,b'$ lets $B$ model equivalence-class readouts (instruments that genuinely cannot separate certain states) without special-casing. Second, *the average-to-worst-case ladder*: Theorem 3.3 controls the mean and Theorem 3.5 controls the maximum, so both risk conventions are covered by the same elementary geometry.

## 8. Future Directions

**From two-point risk to distributional lower bounds.** The two-state theorem is a local obstruction. Integrating it over couplings of states whose observations are close but whose experiences are separated should produce lower bounds on expected reconstruction loss in terms of an optimal-transport discrepancy between the experiential and functional geometries.

**Sharp constants and minimax reconstruction.** The factor $\tfrac12$ arises from splitting a hidden contrast across two errors. Characterizing equality and then optimizing over Lipschitz decoders would upgrade the bound to a full minimax theorem. Finite metric spaces are a tractable first setting, where the decoder problem connects to metric extension and facility-location problems.

**Noisy and randomized decoders.** A randomized reconstruction is a Markov kernel from observations to distributions over experiences. Replacing metric loss by Wasserstein loss should retain the same triangle-inequality obstruction, linking hidden fibres to statistical experiments and data-processing inequalities.

**Nontrivial coverings.** The robust inequality does not require a globally split state space, so it applies locally to nontrivial finite coverings. A complementary topological development would construct an explicit connected two-sheeted cover exhibiting local sheet swaps but no continuous global fibrewise choice of the opposite sheet.

**Effective reconstruction.** The present results bound accuracy once a decoder is supplied; the definability question asks when a decoder exists *computably*. A useful next theorem would separate fibre constancy from uniform effective representative selection on the range of the functional map.

## 9. Conclusion

We have shown that a lossy observation channel imposes a precise, robust floor on the accuracy of any stable reconstruction of a hidden quantity. The floor is $(\delta - K\varepsilon)/2$ in general and $\delta/2$ in the exact case, it is attained, and it is nothing more than the triangle inequality interpreted as statistical risk. The same inequality speaks to representation learning, lossy sensing, fairness auditing, and the philosophy of mind — a reminder that some of the sharpest limits on inference are, at bottom, elementary facts about distance.
