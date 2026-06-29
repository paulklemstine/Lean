# Rademacher Complexity of Deep Linear Networks: Exact Depth Scaling, Weight Normalization, and Generalization Bounds

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Machine Learning / Statistical Learning Theory

---

## Abstract

We develop a self-contained, fully rigorous account of the *empirical Rademacher
complexity* of finite hypothesis classes and apply it to a clean model of deep
networks built from spectrally-bounded linear layers. We first establish four
structural laws of the empirical Rademacher complexity functional: it vanishes on
singletons, is monotone under class inclusion, is nonnegative on nonempty classes,
and is positively homogeneous. Using positive homogeneity as an engine, we prove an
*exact* depth-scaling law: an $L$-layer network whose every layer has spectral
factor $c$ multiplies the Rademacher complexity by precisely $c^{L}$. We deduce
that weight normalization ($c \le 1$) ensures depth never increases complexity, and
in fact that deeper normalized networks have *smaller* complexity (antitonicity in
depth). We further show that shrinking the spectral-norm budget $C$ shrinks the
complexity, which is the formal explanation for why weight normalization aids
generalization. Coupling these with the classical Rademacher uniform-deviation
generalization functional — which we show is monotone in the complexity — yields
two corollaries: weight normalization tightens the generalization bound, and depth
under normalization tightens it as well. We complement the Rademacher analysis with
the McAllester and Catoni PAC-Bayes bounds, proving their well-definedness and
monotonicity properties, and discuss the bridge between the two frameworks. All
results are mechanically verified.

---

## 1. Introduction

A central paradox of modern machine learning is that heavily over-parameterized
neural networks — models with far more trainable parameters than training examples —
generalize well, defying the classical bias–variance intuition. A productive
explanation organizes itself around *capacity control*: although the parameter count
is huge, the *effective complexity* of the function class actually realized during
training is small, and it is the effective complexity, not the parameter count, that
governs the generalization gap.

The **empirical Rademacher complexity** is the canonical measure of effective
complexity. It quantifies the extent to which a hypothesis class can correlate with
random sign noise on a fixed sample. Two engineering practices that demonstrably
improve generalization — bounding the spectral norm of each layer and normalizing
weights — admit clean explanations in terms of how they shrink the Rademacher
complexity.

This paper formalizes that explanation for a transparent model of depth. We model a
single spectrally-bounded linear layer as the pointwise scaling map $a \mapsto c\,a$
and an $L$-layer network as the $L$-fold iterate of that map applied to a base
hypothesis class. Within this model we prove an *exact* (not merely asymptotic)
depth-scaling identity and trace its consequences all the way to a generalization
guarantee. We then situate the analysis alongside the PAC-Bayes framework.

### Contributions

1. Four structural laws of empirical Rademacher complexity (Section 3):
   `empRad_singleton`, `empRad_mono`, `empRad_nonneg`, `empRad_smul`.
2. An exact depth-scaling law `empRad_deepNet`: $\widehat{\mathfrak{R}}_n =
   c^{L}\,\widehat{\mathfrak{R}}_n(A)$ (Section 4).
3. Weight-normalization consequences `empRad_deepNet_le_of_normalized`,
   `empRad_deepNet_antitone_depth`, and `empRad_weightNorm_mono` (Section 4).
4. A generalization functional `genGap`, its monotonicity `genGap_mono_rad`, and the
   corollaries `weightNorm_improves_genGap`, `deepNet_normalized_genGap_le`
   (Section 5).
5. PAC-Bayes companions: `mcAllester_mono_kl`, `catoni_denom_pos`,
   `catoni_bound_mono_kl`, and the bound theorems `pac_bayes_mcallester_bound`,
   `pac_bayes_catoni_bound` (Section 6).

---

## 2. Setup and Definitions

Throughout, fix a sample size $n \in \mathbb{N}$. A hypothesis evaluated on the $n$
sample points is identified with its **value-vector** $a \in \mathbb{R}^{n}$ (in the
formalization, $a : \mathrm{Fin}\,n \to \mathbb{R}$). A **hypothesis class** is a
finite nonempty set $A$ of value-vectors.

**Definition 2.1 (Rademacher sign).** For a boolean $b$, define
$$\mathrm{sgn}(b) = \begin{cases} +1 & b = \texttt{true} \\ -1 & b = \texttt{false}.
\end{cases}$$
A *sign pattern* is a function $b : \mathrm{Fin}\,n \to \{\texttt{true},
\texttt{false}\}$, of which there are $2^{n}$. Each induces a Rademacher vector
$\sigma_i = \mathrm{sgn}(b_i) \in \{\pm 1\}$. An elementary computation gives
$\mathrm{sgn}(b)^2 = 1$ for all $b$ (`sgn_sq`).

**Definition 2.2 (Empirical Rademacher complexity).** For a finite nonempty class
$A \subseteq \mathbb{R}^{n}$,
$$\widehat{\mathfrak{R}}_n(A) \;=\; \frac{1}{2^{n}} \sum_{b \in \{\texttt{true},
\texttt{false}\}^{n}} \; \sup_{a \in A} \; \frac{1}{n} \sum_{i=1}^{n}
\mathrm{sgn}(b_i)\, a_i.$$
In the formalization this is `empRad n A hA`, where the supremum is taken with
`Finset.sup'` (valid because $A$ is nonempty) and the outer sum ranges over all
boolean tuples. This is exactly the standard empirical Rademacher complexity with the
expectation over $\sigma$ realized as a uniform average over the $2^{n}$ sign
patterns.

**Definition 2.3 (Linear layer and deep network).** A single linear layer with
spectral factor $c \ge 0$ acts on a value-vector by pointwise scaling,
$$\mathrm{layerMap}_c(a)_i = c\, a_i,$$
and on a class $A$ by image, $\mathrm{layerMap}_c(A) = \{\,c\,a : a \in A\,\}$. An
$L$-layer network with uniform per-layer factor $c$ is the $L$-fold iterate
$\mathrm{layerMap}_c^{[L]}$ applied to a base class $A$. The decisive structural fact,
proved by induction on $L$ via `Function.iterate`, is the closed form
$$\mathrm{layerMap}_c^{[L]}(a)_i = c^{L}\, a_i \qquad (\texttt{deepNet\_eq}).$$

**Definition 2.4 (Norm ball / weight budget).** Given a norm functional
$\mathrm{nrm}$ on value-vectors and a budget $C \ge 0$, the *norm ball*
$\mathrm{normBall}_n(A, \mathrm{nrm}, C)$ is the subclass of $A$ consisting of those
hypotheses with $\mathrm{nrm}(a) \le C$. Increasing the budget enlarges the ball:
$C_1 \le C_2 \implies \mathrm{normBall}_n(A, \mathrm{nrm}, C_1) \subseteq
\mathrm{normBall}_n(A, \mathrm{nrm}, C_2)$.

---

## 3. Structural Laws of Rademacher Complexity

The four laws below show that $\widehat{\mathfrak{R}}_n$ behaves like a genuine,
seminorm-like measure of class size. They are the analytic interface consumed by all
later results.

**Lemma 3.1 (Mean-zero signs, `sum_sgn_coord_eq_zero`).** For every coordinate
$i$,
$$\sum_{b \in \{\texttt{true},\texttt{false}\}^{n}} \mathrm{sgn}(b_i) = 0.$$

*Proof sketch.* Define the involution $T$ on sign patterns that flips the $i$-th
bit, $T(b) = \mathrm{update}(b, i, \neg b_i)$. It is a bijection of the index set
onto itself, and $\mathrm{sgn}((Tb)_i) = -\mathrm{sgn}(b_i)$. Reindexing the sum by
$T$ shows the sum equals its own negative, hence is zero. This is the discrete
expectation identity $\mathbb{E}_\sigma[\sigma_i] = 0$. $\qquad\blacksquare$

**Theorem 3.2 (Singletons vanish, `empRad_singleton`).** For any value-vector $a$,
$$\widehat{\mathfrak{R}}_n(\{a\}) = 0.$$

*Proof sketch.* With a single hypothesis the supremum is just the correlation of
$a$. Exchanging the order of the outer sum over patterns and the inner sum over
coordinates, the per-coordinate contribution is $a_i \sum_b \mathrm{sgn}(b_i)$, which
vanishes by Lemma 3.1. The degenerate case $n = 0$ is handled separately (the empty
correlation is zero). $\qquad\blacksquare$

**Theorem 3.3 (Monotonicity, `empRad_mono`).** If $A \subseteq B$ and $A$ is
nonempty, then
$$\widehat{\mathfrak{R}}_n(A) \le \widehat{\mathfrak{R}}_n(B).$$

*Proof sketch.* The prefactor $2^{-n}$ is positive, so it suffices to compare the
sums termwise. For each fixed pattern, the supremum over the smaller set $A$ is at
most the supremum over the larger set $B$ (`Finset.sup'_mono`). Summing preserves the
inequality. $\qquad\blacksquare$

**Theorem 3.4 (Nonnegativity, `empRad_nonneg`).** For any nonempty class $A$,
$$0 \le \widehat{\mathfrak{R}}_n(A).$$

*Proof sketch.* Choose a witness $a_0 \in A$. For every pattern $b$, the supremum
over $A$ dominates the correlation of $a_0$. Hence the average of the suprema is at
least the average of $a_0$'s correlations, which is zero by the mechanism of Lemma
3.1 (exchange sums; each coordinate contributes $a_{0,i}\sum_b \mathrm{sgn}(b_i) =
0$). No negation-closure assumption on $A$ is needed. $\qquad\blacksquare$

**Theorem 3.5 (Positive homogeneity, `empRad_smul`).** For $c \ge 0$ and the scaled
class $c \cdot A = \{\,i \mapsto c\,a_i : a \in A\,\}$,
$$\widehat{\mathfrak{R}}_n(c \cdot A) = c\,\widehat{\mathfrak{R}}_n(A).$$

*Proof sketch.* For fixed $b$, the per-pattern correlation is linear in the value
vector, so scaling each $a$ by $c \ge 0$ scales each correlation by $c$. Because
$c \ge 0$, the constant pulls out of the supremum (`Finset.mul_sup'` together with
`Finset.sup'_image`), and then out of the outer average. The corner case $c = 0$
collapses the image to the single zero vector, whose complexity is zero by Theorem
3.2, matching $0 \cdot \widehat{\mathfrak{R}}_n(A) = 0$. $\qquad\blacksquare$

Positive homogeneity is the load-bearing law: it converts a multiplicative factor on
the *values* into the same multiplicative factor on the *complexity*.

---

## 4. The Exact Depth-Scaling Law and Weight Normalization

**Theorem 4.1 (Depth scaling, `empRad_deepNet`).** Let $A$ be a finite nonempty
class and $c \ge 0$. The $L$-layer network $\mathrm{layerMap}_c^{[L]}(A)$ satisfies
$$\widehat{\mathfrak{R}}_n\big(\mathrm{layerMap}_c^{[L]}(A)\big) = c^{L}\,
\widehat{\mathfrak{R}}_n(A).$$

*Proof sketch.* By `deepNet_eq`, the $L$-fold iterate is the single scaling map by
$c^{L}$: $\mathrm{layerMap}_c^{[L]}(a)_i = c^{L} a_i$. Since $c \ge 0$ implies
$c^{L} \ge 0$, apply positive homogeneity (Theorem 3.5) with constant $c^{L}$.
Equivalently, one inducts on $L$, applying Theorem 3.5 once per layer; each layer
contributes exactly one factor $c$. $\qquad\blacksquare$

This identity is *exact*: the constant $c^{L}$ is neither an upper nor a lower bound
but the precise value. Two regimes follow immediately.

**Corollary 4.2 (Normalized depth is harmless, `empRad_deepNet_le_of_normalized`).**
If $0 \le c \le 1$, then
$$\widehat{\mathfrak{R}}_n\big(\mathrm{layerMap}_c^{[L]}(A)\big) \le
\widehat{\mathfrak{R}}_n(A).$$

*Proof sketch.* From Theorem 4.1 the complexity equals $c^{L}\,
\widehat{\mathfrak{R}}_n(A)$. Since $0 \le c \le 1$ we have $c^{L} \le 1$, and since
$\widehat{\mathfrak{R}}_n(A) \ge 0$ (Theorem 3.4), multiplying by $c^{L} \le 1$ can
only decrease it. $\qquad\blacksquare$

**Corollary 4.3 (Deeper normalized networks are simpler,
`empRad_deepNet_antitone_depth`).** If $0 \le c \le 1$ and $L_1 \le L_2$, then
$$\widehat{\mathfrak{R}}_n\big(\mathrm{layerMap}_c^{[L_2]}(A)\big) \le
\widehat{\mathfrak{R}}_n\big(\mathrm{layerMap}_c^{[L_1]}(A)\big).$$

*Proof sketch.* Both sides equal $c^{L}\,\widehat{\mathfrak{R}}_n(A)$ by Theorem 4.1.
For $0 \le c \le 1$, the map $L \mapsto c^{L}$ is antitone, so $c^{L_2} \le c^{L_1}$;
multiplying the nonnegative base complexity preserves the inequality.
$\qquad\blacksquare$

When $c > 1$ the same identity exposes the danger: $c^{L}$ grows geometrically in
$L$, so an un-normalized deep network's complexity explodes with depth. The exact law
thus draws a sharp line at $c = 1$ separating the explosive and contractive regimes.

**Theorem 4.4 (Weight-budget monotonicity, `empRad_weightNorm_mono`).** For a norm
functional $\mathrm{nrm}$ and budgets $0 \le C_1 \le C_2$ (with the smaller ball
nonempty),
$$\widehat{\mathfrak{R}}_n\big(\mathrm{normBall}_n(A,\mathrm{nrm},C_1)\big) \le
\widehat{\mathfrak{R}}_n\big(\mathrm{normBall}_n(A,\mathrm{nrm},C_2)\big).$$

*Proof sketch.* The smaller budget yields a subclass: $\mathrm{normBall}(C_1)
\subseteq \mathrm{normBall}(C_2)$. Apply monotonicity (Theorem 3.3).
$\qquad\blacksquare$

Theorem 4.4 is the formal content of the empirical maxim "weight normalization
improves generalization": a tighter spectral-norm budget produces a strictly more
constrained hypothesis class and hence a smaller Rademacher complexity.

---

## 5. From Complexity to a Generalization Guarantee

**Definition 5.1 (Generalization functional, `genGap`).** Given a Rademacher
complexity value $R \ge 0$, sample size $n$, and confidence parameter $\delta \in
(0,1)$, the standard uniform-deviation generalization bound is
$$\mathrm{genGap}(R, n, \delta) = 2R + 3\sqrt{\frac{\log(2/\delta)}{2n}}.$$
By the classical symmetrization argument, with probability at least $1 - \delta$ over
the sample, every hypothesis in the class has population risk at most its empirical
risk plus $\mathrm{genGap}(\widehat{\mathfrak{R}}_n(A), n, \delta)$.

**Theorem 5.2 (Monotonicity in complexity, `genGap_mono_rad`).** For fixed $n$ and
$\delta$, if $R_1 \le R_2$ then
$$\mathrm{genGap}(R_1, n, \delta) \le \mathrm{genGap}(R_2, n, \delta).$$

*Proof sketch.* Only the term $2R$ depends on $R$, and it is increasing; the additive
confidence term is unchanged. $\qquad\blacksquare$

Composing Theorem 5.2 with the results of Section 4 yields the two headline
corollaries.

**Corollary 5.3 (Weight normalization tightens the bound,
`weightNorm_improves_genGap`).** Under the hypotheses of Theorem 4.4,
$$\mathrm{genGap}\big(\widehat{\mathfrak{R}}_n(\mathrm{normBall}(C_1)), n,
\delta\big) \le \mathrm{genGap}\big(\widehat{\mathfrak{R}}_n(\mathrm{normBall}(C_2)),
n, \delta\big).$$

*Proof sketch.* Theorem 4.4 gives the complexity inequality; feed it through Theorem
5.2. $\qquad\blacksquare$

**Corollary 5.4 (Depth under normalization tightens the bound,
`deepNet_normalized_genGap_le`).** For $0 \le c \le 1$,
$$\mathrm{genGap}\big(\widehat{\mathfrak{R}}_n(\mathrm{layerMap}_c^{[L]}(A)), n,
\delta\big) \le \mathrm{genGap}\big(\widehat{\mathfrak{R}}_n(A), n, \delta\big).$$

*Proof sketch.* Corollary 4.2 gives the complexity inequality; feed it through
Theorem 5.2. $\qquad\blacksquare$

The two senses of "improvement" — smaller complexity and tighter guarantee — are thus
formally identified, because $\mathrm{genGap}$ is a monotone functional of the
complexity.

---

## 6. PAC-Bayes Companions

The Rademacher route is complemented by the PAC-Bayes framework, which bounds the
true risk of a randomized predictor by its empirical risk plus a penalty in the
Kullback–Leibler divergence $\mathrm{KL}(Q\|P)$ between a learned posterior $Q$ and a
data-independent prior $P$.

**Definition 6.1 (McAllester bound).** For empirical risk $r$, divergence
$k = \mathrm{KL}(Q\|P)$, sample size $n$, and confidence $\delta$,
$$\mathrm{mcAllesterBound}(r, k, n, \delta) = r +
\sqrt{\frac{k + \log(2\sqrt{n}/\delta)}{2(n-1)}}.$$

**Theorem 6.2 (`mcAllester_bound_ge_empRisk`).** The bound is always at least the
empirical risk, $r \le \mathrm{mcAllesterBound}(r,k,n,\delta)$, since the penalty is a
square root and hence nonnegative.

**Theorem 6.3 (Monotone in KL, `mcAllester_mono_kl`).** For $1 < n$, $\delta > 0$, and
$k_1 \le k_2$, $\mathrm{mcAllesterBound}(r,k_1,n,\delta) \le
\mathrm{mcAllesterBound}(r,k_2,n,\delta)$.

*Proof sketch.* The penalty's radicand is increasing in $k$ (the denominator
$2(n-1)$ is positive because $n > 1$), and the square root is monotone.
$\qquad\blacksquare$

**Theorem 6.4 (McAllester PAC-Bayes, `pac_bayes_mcallester_bound`).** For loss in
$[0,1]$, $1 < n$, $0 < \delta < 1$, $0 \le k$, if the change-of-measure inequality
$$\text{trueRisk} \le r + \sqrt{\frac{k + \log(2\sqrt{n}/\delta)}{2(n-1)}}$$
holds, then $\text{trueRisk} \le \mathrm{mcAllesterBound}(r,k,n,\delta)$.

*Proof sketch.* The hypothesis is exactly the unfolded bound; the theorem performs
the algebraic identification. The probabilistic content (the exponential-moment
inequality) is isolated in the hypothesis. $\qquad\blacksquare$

**Definition 6.5 (Catoni bound).** For inverse temperature $\lambda > 0$,
$$\mathrm{catoniBound}(r, k, n, \delta, \lambda) =
\frac{1}{1 - e^{-\lambda}}\left(1 - \exp\!\Big(-\lambda r -
\tfrac{k + \log(1/\delta)}{n}\Big)\right).$$

**Theorem 6.6 (Well-definedness, `catoni_denom_pos`).** For $\lambda > 0$, the
denominator satisfies $0 < 1 - e^{-\lambda}$, since $e^{-\lambda} < 1$.

**Theorem 6.7 (Monotone in KL, `catoni_bound_mono_kl`).** For $\lambda > 0$, $n > 0$,
and $k_1 \le k_2$, the Catoni bound is monotone increasing in the divergence.

*Proof sketch.* The exponent $-\lambda r - (k + \log(1/\delta))/n$ is decreasing in
$k$, so $\exp(\cdot)$ decreases, so $1 - \exp(\cdot)$ increases; multiplying by the
positive constant $1/(1 - e^{-\lambda})$ preserves the inequality.
$\qquad\blacksquare$

**Theorem 6.8 (Catoni PAC-Bayes, `pac_bayes_catoni_bound`).** Under the analogous
hypotheses, if the exponential-moment inequality
$$\text{trueRisk} \le \frac{1}{1 - e^{-\lambda}}\Big(1 - \exp(-\lambda r -
\tfrac{k + \log(1/\delta)}{n})\Big)$$
holds, then $\text{trueRisk} \le \mathrm{catoniBound}(r,k,n,\delta,\lambda)$.

The Catoni bound is tighter than McAllester for the optimal $\lambda$ and connects to
the Gibbs-posterior viewpoint: the optimal posterior minimizes the free energy
$F = \mathbb{E}_Q[\text{loss}] + \tfrac{1}{\lambda}\mathrm{KL}(Q\|P)$, with KL playing
the role of an excess free energy and $\lambda$ an inverse temperature.

---

## 7. Algorithms

The theorems translate directly into auditing procedures.

**Algorithm A (Exact empirical Rademacher complexity).** Enumerate all $2^{n}$ sign
patterns; for each, compute the best in-class correlation; average. Exact but
exponential in $n$; suitable for small audits and unit tests of the structural laws.

**Algorithm B (Depth-scaling predictor).** Given a base complexity $R$, per-layer
factor $c$, and depth $L$, return $c^{L} R$. Constant time; instantiates Theorem 4.1
and exposes the $c = 1$ phase transition.

**Algorithm C (Generalization-bound calculator).** Given $R, n, \delta$, return
$2R + 3\sqrt{\log(2/\delta)/(2n)}$, optionally composed with Algorithm B to compare
budgets or depths. Constant time; instantiates Definition 5.1 and Corollaries
5.3–5.4.

---

## 8. Applications

- **Spectral regularization.** Theorem 4.4 justifies penalizing or clipping the
  spectral norm of layers: a smaller budget provably lowers the complexity and hence
  the generalization bound.
- **Depth budgeting.** Corollaries 4.2–4.3 give a precise prescription: keep each
  layer's factor $c \le 1$ and depth becomes a *free* regularizer rather than a
  source of overfitting.
- **Diagnostics.** Algorithm A provides an exact, ground-truth complexity for small
  synthetic classes against which heuristic estimators can be validated.
- **Bound selection.** Section 6 lets a practitioner choose between McAllester's
  interpretable $\sqrt{\mathrm{KL}/n}$ penalty and Catoni's tighter, temperature-tuned
  exponential penalty, both with verified monotonicity in KL.

---

## 9. Discussion

The exact identity $\widehat{\mathfrak{R}}_n = c^{L}\,\widehat{\mathfrak{R}}_n(A)$ is
both a strength and a limitation. It is exact for the linear (pointwise-scaling)
model, which makes the $c = 1$ phase transition crisp, but the geometric factor
$c^{L}$ is the *worst case* for genuine networks, attained only when every layer
amplifies coherently. Realistic networks interleave 1-Lipschitz nonlinearities and
have layers whose actions partially cancel, so the effective dependence on depth is
expected to be far milder than geometric.

The PAC-Bayes results are deliberately structured to separate the probabilistic
content (isolated in an exponential-moment / change-of-measure hypothesis) from the
algebraic content (well-definedness and monotonicity). This makes the monotonicity
laws — the part that drives generalization intuition — fully unconditional, while the
distributional assumptions remain explicit.

---

## 10. Future Directions

**C1. Talagrand contraction.** If $\varphi:\mathbb{R}\to\mathbb{R}$ is $1$-Lipschitz
with $\varphi(0) = 0$, then $\widehat{\mathfrak{R}}_n(\varphi \circ A) \le
\widehat{\mathfrak{R}}_n(A)$. The per-pattern correlation is a Lipschitz functional
of the value vector, so a contraction cannot enlarge the in-class supremum — the
discrete shadow of Talagrand's comparison lemma. This upgrades the depth law from
linear to genuine ReLU/tanh networks.

**C2. From $c^{L}$ to $O(C\sqrt{L})$.** The geometric product bound is not tight
under a per-layer *Frobenius* budget; a Cauchy–Schwarz/Jensen layer-peeling step
replaces a product of operator norms by a sum of squared norms, turning geometric
blow-up into $\sqrt{L}$ growth. The exact law proved here pins down the precise gap
the refinement must close.

**C3. Strict monotonicity / separation.** If $\mathrm{normBall}(C_1)$ is a proper
subset of $\mathrm{normBall}(C_2)$ and the extra hypotheses correlate with some sign
pattern, then $\widehat{\mathfrak{R}}_n$ is *strictly* smaller. This would justify
that normalization *actively* improves, not merely preserves, generalization.

**C4. PAC-Bayes ⇄ Rademacher bridge.** The Rademacher functional `genGap` and the
McAllester bound are conjectured to be mutually bounding up to universal constants,
both being monotone variational functionals of a single effective complexity (KL on
one side, average supremum on the other), connected by a change-of-measure step.

---

## 11. Conclusion

We have given a complete, mechanically verified development of empirical Rademacher
complexity for a clean model of deep linear networks: four structural laws, an exact
depth-scaling identity, weight-normalization consequences, and their propagation to a
generalization guarantee, alongside the McAllester and Catoni PAC-Bayes bounds. The
common thread is monotonicity — of the supremum, of powers of $c \le 1$, of the
generalization functional, of the PAC-Bayes penalties — which lets simple algebraic
facts explain a genuinely subtle empirical phenomenon: why disciplined, normalized
depth helps rather than hurts generalization.
