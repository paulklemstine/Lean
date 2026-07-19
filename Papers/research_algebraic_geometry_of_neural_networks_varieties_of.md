# Tropical Dequantization and Decision Stability in Max-Affine Neural Networks

**Aristotle**  
**July 19, 2026**

## Abstract

Max-affine expressions form the convex piecewise-linear sector of rectified neural computation and, simultaneously, finite binary tropical polynomials with affine leaves. This paper develops a self-contained comparison between their tropical evaluation and the smooth evaluation obtained by replacing every binary maximum with log-sum-exp. For an expression of depth $d$ and inverse temperature $\beta>0$, the smooth value lies above the tropical value by at most $d\log(2)/\beta$, uniformly over the input space. Consequently, binary classification is unchanged at every input whose tropical score has absolute value greater than this explicit error. The bound depends on computational depth rather than leaf count. We also solve the algebraic recurrence underlying the proposed budget $2^L\prod_i w_i$ and distinguish this identity from a universal geometric region theorem. Finally, two minimal counterexamples delimit broader claims: the zero set of scalar ReLU contains an open half-line, so arbitrary ReLU zero sets need not be hypersurfaces, and a width-one ReLU has a kink although the pair count $\binom{1}{2}$ vanishes. These results identify a rigorous tropical-to-analytic bridge for convex neural models while motivating tropical-rational representations, margin-stable topology, active-set singularity bounds, and arrangement-sensitive region estimates for broader architectures.

## 1. Introduction

A scalar neural classifier assigns a real score $F(x)$ to an input $x$ and places its decision threshold at zero. Its geometry is therefore governed by the score’s level sets, especially the zero set and the interface between positive and nonpositive predictions. Networks with rectified linear activation are piecewise affine, suggesting connections to polyhedral and tropical geometry. However, several distinct assertions are often compressed into this suggestion: that the score is tropical, that its raw zero set is a hypersurface, that architectural width directly controls the number of regions or singularities, and that a smooth approximation preserves the same decisions or topology. These assertions require separate hypotheses and separate proofs.

This paper isolates a setting in which the tropical description is exact. A **max-affine expression** is a finite binary tree whose leaves are real-valued affine functions and whose internal nodes compute maximum. Such an expression is a tropical polynomial written with binary bracketing. It also describes the convex sector of rectified neural computation: a ReLU gate is simply the maximum of zero and its input. The expression evaluates to a convex piecewise-affine function, the upper envelope of its affine leaves.

The main question is quantitative. Replace each hard maximum by the smooth log-sum-exp operation

$$
\operatorname{LSE}_\beta(a,b)
=
\frac{1}{\beta}\log\left(e^{\beta a}+e^{\beta b}\right),
\qquad \beta>0.
$$

How far can the resulting smooth function move from the original tropical function? The local error of one binary replacement is at most $\log(2)/\beta$. For a nested computation, a naive estimate might scale with the total number of gates or leaves. Instead, the exact compositional argument yields a bound proportional only to the deepest chain of maxima. If $d$ is the expression depth, then

$$
0\leq F_\beta(x)-F(x)\leq\frac{d\log 2}{\beta}
$$

for every input $x$. This produces a classification certificate: if $|F(x)|>d\log(2)/\beta$, hard and smooth evaluations have the same strict-positive label.

The distinction between depth and size is practically relevant. A balanced tree of depth $d$ may contain as many as $2^d$ leaves, yet the bound remains linear in $d$. The result is also independent of input dimension and of the coefficients of the affine leaves.

The second purpose of the paper is diagnostic. An exact algebraic identity shows that the recurrence multiplying a budget by $2w_i$ at layer $i$ unfolds to $2^L\prod_i w_i$. This does not establish that the recurrence is a valid universal count of realized linear regions. Geometry depends on arrangement rank and degeneracy. Two one-dimensional examples further show why unrestricted formulations fail: the raw zero set of ReLU has interior, and the narrowest possible ReLU network exhibits a kink invisible to a product of within-layer pair counts.

The resulting picture is disciplined. Max-affine neural functions are tropical objects; their log-sum-exp dequantizations are uniformly close with a sharp depth-dependent compositional estimate; and classifications are stable outside an explicit uncertainty band. Arbitrary signed ReLU networks and universal claims about hypersurfaces, regions, or singularities require richer invariants.

## 2. Max-affine expressions

Let $X$ be any set. In applications $X$ is typically $\mathbb{R}^n$, but the approximation theorem requires no vector-space structure beyond that needed to define the leaf functions.

**Definition 2.1 (Max-affine expression).** A max-affine expression on $X$ is defined recursively:

1. Every function $g:X\to\mathbb{R}$ designated as an affine leaf is a max-affine expression.
2. If $P$ and $Q$ are max-affine expressions, then $\max(P,Q)$ is a max-affine expression.

When $X=\mathbb{R}^n$, an affine leaf has the form

$$
g(x)=a\cdot x+b
$$

for $a\in\mathbb{R}^n$ and $b\in\mathbb{R}$.

**Definition 2.2 (Tropical evaluation).** The tropical evaluation $F_P:X\to\mathbb{R}$ of an expression $P$ is given by

$$
F_g(x)=g(x)
$$

at a leaf and

$$
F_{\max(P,Q)}(x)=\max(F_P(x),F_Q(x))
$$

at an internal node.

Thus $F_P$ is the upper envelope of all affine leaves occurring in $P$. Repeated leaves and binary bracketing can alter the expression tree without altering that hard evaluation, although they can affect the chosen dequantization because log-sum-exp counts multiplicity.

**Definition 2.3 (Depth).** The depth $d(P)$ counts the greatest number of maximum nodes on a path from the root to a leaf:

$$
d(g)=0,
\qquad
d(\max(P,Q))=1+\max(d(P),d(Q)).
$$

**Definition 2.4 (ReLU expression).** Given a max-affine expression $P$, its rectification is

$$
\operatorname{ReLU}(P)=\max(0,P),
$$

where $0$ denotes the constant zero affine function.

**Proposition 2.5 (Exact ReLU evaluation).** For every input $x$,

$$
F_{\operatorname{ReLU}(P)}(x)=\max(0,F_P(x)).
$$

**Proof sketch.** This is immediate from the recursive definition: rectification introduces a maximum node with children equal to the zero function and $P$. $\square$

When the leaves are affine, $F_P$ is convex and piecewise affine. The regions on which a single leaf dominates are polyhedral. Ties between active leaves form the tropical corner locus. This corner locus should not be confused with the zero level set $\{x:F_P(x)=0\}$: one records nondifferentiability of an upper envelope, while the other records a chosen score threshold.

## 3. Log-sum-exp dequantization

**Definition 3.1 (Smooth evaluation).** Fix $\beta>0$. The dequantized or smooth evaluation $S_{P,\beta}:X\to\mathbb{R}$ is defined recursively by

$$
S_{g,\beta}(x)=g(x)
$$

and

$$
S_{\max(P,Q),\beta}(x)
=
\frac{1}{\beta}
\log\left(
 e^{\beta S_{P,\beta}(x)}+e^{\beta S_{Q,\beta}(x)}
\right).
$$

The parameter $\beta$ is the inverse temperature. Increasing $\beta$ sharpens the smooth maximum.

The analysis starts with a standard two-variable estimate, included here for completeness.

**Lemma 3.2 (Binary log-sum-exp bounds).** For all $a,b\in\mathbb{R}$ and $\beta>0$,

$$
\max(a,b)
\leq
\frac{1}{\beta}\log(e^{\beta a}+e^{\beta b})
\leq
\max(a,b)+\frac{\log 2}{\beta}.
$$

**Proof sketch.** Put $m=\max(a,b)$. Factoring out $e^{\beta m}$ gives

$$
\frac{1}{\beta}\log(e^{\beta a}+e^{\beta b})
=
m+rac{1}{\beta}
\log\left(e^{\beta(a-m)}+e^{\beta(b-m)}\right).
$$

At least one exponent in parentheses is $1$, so the logarithmic correction is nonnegative. Both are at most $1$, so their sum is at most $2$. The correction therefore lies between $0$ and $\log(2)/\beta$. $\square$

The lower half of the global estimate follows by monotonicity.

**Lemma 3.3 (Dequantization dominates tropical evaluation).** For every max-affine expression $P$, every $x\in X$, and every $\beta>0$,

$$
F_P(x)\leq S_{P,\beta}(x).
$$

**Proof sketch.** Induct on the expression. Equality holds at a leaf. At an internal node, the induction hypotheses place both smooth child values above their tropical counterparts. Monotonicity of maximum and the lower binary log-sum-exp bound then place the smooth parent above the tropical parent. $\square$

The upper estimate requires tracking depth.

**Theorem 3.4 (Depth-controlled upper approximation).** For every max-affine expression $P$, every $x\in X$, and every $\beta>0$,

$$
S_{P,\beta}(x)
\leq
F_P(x)+\frac{d(P)\log 2}{\beta}.
$$

**Proof sketch.** Proceed by structural induction. At a leaf, $d(P)=0$ and the evaluations coincide. Suppose $P=\max(Q,R)$. By induction,

$$
S_{Q,\beta}(x)
\leq F_Q(x)+\frac{d(Q)\log 2}{\beta},
$$

and similarly for $R$. Let $D=\max(d(Q),d(R))$. Both smooth child values are then bounded above by their hard values plus $D\log(2)/\beta$. Translation equivariance and monotonicity of log-sum-exp imply

$$
S_{P,\beta}(x)
\leq
\operatorname{LSE}_\beta(F_Q(x),F_R(x))
+rac{D\log 2}{\beta}.
$$

Applying the binary upper bound adds one more $\log(2)/\beta$ and replaces the log-sum-exp of hard children by their maximum. Since $d(P)=D+1$, the result follows. $\square$

Combining the preceding lemmas gives the principal estimate.

**Theorem 3.5 (Two-sided dequantization error).** Let $P$ have depth $d$. For every $x\in X$ and $\beta>0$,

$$
0\leq S_{P,\beta}(x)-F_P(x)
\leq
\frac{d\log 2}{\beta}.
$$

This estimate is uniform in $x$. It does not depend on the dimension of $X$, the coefficients of the affine leaves, or the number of leaves. Its dependence on binary depth reflects compositional structure. For a balanced tree with $N$ leaves, $d$ may be of order $\log_2 N$; for a completely unbalanced tree it may be of order $N$.

**Corollary 3.6 (Uniform soft-ReLU bound).** For every $x\in\mathbb{R}$ and $\beta>0$,

$$
\max(0,x)
\leq
\frac{1}{\beta}\log(1+e^{\beta x})
\leq
\max(0,x)+\frac{\log 2}{\beta}.
$$

**Proof sketch.** Use the binary estimate with $a=0$ and $b=x$. Equivalently, apply Theorem 3.5 to a depth-one rectification expression. $\square$

### 3.1 Sharpness and representation dependence

At a single tie $a=b$, the binary error is exactly $\log(2)/\beta$, so the one-node constant cannot be improved uniformly. Along a nested expression, simultaneous ties can accumulate one unit of error at each level for suitable repeated or balanced values. Thus depth is a natural worst-case parameter for the chosen binary representation.

There is also a useful distinction between an expression and the function it represents. The hard maximum is associative and idempotent, whereas finite-temperature log-sum-exp is associative under an unnormalized sum over all leaves but is not idempotent with respect to repeated entries. Different trees representing the same tropical function can therefore lead to different smooth surrogates and different depth bounds. In algorithm design, balancing the tree can reduce the certified error budget for a given $\beta$.

## 4. Classification stability

Define the hard binary classifier

$$
C_P(x)=
\begin{cases}
1,&F_P(x)>0,\\
0,&F_P(x)\leq 0,
\end{cases}
$$

and its dequantized counterpart $C_{P,\beta}$ by replacing $F_P$ with $S_{P,\beta}$.

**Theorem 4.1 (Margin stability).** Let $P$ have depth $d$, let $\beta>0$, and let $x\in X$. If

$$
\frac{d\log 2}{\beta}<|F_P(x)|,
$$

then

$$
S_{P,\beta}(x)>0
\quad\Longleftrightarrow\quad
F_P(x)>0.
$$

**Proof sketch.** If $F_P(x)>0$, Lemma 3.3 gives $S_{P,\beta}(x)\geq F_P(x)>0$. If $F_P(x)<0$, the margin condition says

$$
F_P(x)+\frac{d\log 2}{\beta}<0.
$$

Theorem 3.4 then gives $S_{P,\beta}(x)<0$. The strict margin excludes $F_P(x)=0$. $\square$

**Corollary 4.2 (Temperature selection from a target margin).** If a collection $A\subseteq X$ satisfies $|F_P(x)|\geq m$ for every $x\in A$, where $m>0$, then hard and smooth classifications agree throughout $A$ whenever

$$
\beta>\frac{d\log 2}{m}.
$$

The theorem controls labels, not necessarily the topology of the zero sets. Uniformly close functions may have zero sets with different numbers of components if critical behavior occurs near zero. To infer ambient isotopy or another topological equivalence, one needs a transversality or critical-value exclusion hypothesis in the uncertainty band.

## 5. A layerwise budget identity

Consider a finite width sequence $w_1,\dots,w_L$ of nonnegative integers. Define a recursively generated budget by

$$
R([])=1
$$

and

$$
R([w_1,w_2,\dots,w_L])
=2w_1R([w_2,\dots,w_L]).
$$

**Theorem 5.1 (Closed form of the proposed recurrence).** For every finite width sequence,

$$
R([w_1,\dots,w_L])
=2^L\prod_{i=1}^{L}w_i.
$$

**Proof sketch.** Induct on $L$. The empty product is $1$, matching the base case. For a nonempty sequence, apply the recurrence and the induction hypothesis to obtain

$$
R=2w_1\left(2^{L-1}\prod_{i=2}^{L}w_i\right)
=2^L\prod_{i=1}^{L}w_i.
$$

$\square$

The theorem is an algebraic identity conditional on the recurrence. It should not be interpreted as a universal theorem that a ReLU network has exactly, or always at most, this many realized linear regions. A valid geometric recurrence must establish how many new regions each layer can cut from each incoming region. Raw width alone does not encode arrangement rank, input dimension, coincident hyperplanes, inactive units, or bottlenecks. The appropriate future bound is expected to involve arrangement growth functions evaluated at realized ranks.

## 6. Limitations of unrestricted hypersurface and singularity claims

### 6.1 The raw zero set may have interior

Define scalar ReLU by

$$
r(x)=\max(0,x).
$$

**Theorem 6.1 (Interior in a ReLU zero set).** The open negative half-line lies in the zero set of scalar ReLU:

$$
(-\infty,0)\subseteq\{x\in\mathbb{R}:r(x)=0\}.
$$

Indeed, the complete zero set is $(-\infty,0]$.

**Proof sketch.** If $x<0$, then $0>x$, so $\max(0,x)=0$. At $x=0$ the same equality holds; for $x>0$, $r(x)=x>0$. $\square$

A hypersurface in one dimension is expected to be zero-dimensional under standard nondegeneracy assumptions, whereas $(-\infty,0]$ contains an open interval. Thus the raw zero set of an arbitrary ReLU score need not be a piecewise-linear hypersurface. One can recover a boundary-like object by considering the topological boundary between strict label regions, or by imposing sign-changing and regularity assumptions on the zero level.

### 6.2 Pair counts can miss width-one kinks

The simplest within-layer pair count vanishes at width one:

$$
\binom{1}{2}=0.
$$

Nevertheless, scalar ReLU is nonsmooth at zero.

**Theorem 6.2 (Width-one singularity obstruction).** For every $\varepsilon>0$,

$$
r(-\varepsilon)=0,
\qquad
r(\varepsilon)=\varepsilon,
$$

while $\binom{1}{2}=0$.

**Proof sketch.** The two evaluations follow immediately from the sign of $\varepsilon$. On the negative side the slope is $0$; on the positive side it is $1$, so the origin is a genuine kink. The binomial coefficient is zero because no pair can be selected from a singleton. $\square$

Therefore an unguarded product such as $\prod_i\binom{w_i}{2}$ cannot serve as a universal detector or upper-bound mechanism for all relevant singular behavior: it vanishes whenever any $w_i=1$, even though such a layer may introduce a kink. A more faithful invariant must inspect active affine ties and their incidence in the realized upper envelope.

## 7. Algorithms

### 7.1 Recursive tropical and smooth evaluation

A max-affine expression can be evaluated by postorder traversal. At each leaf, compute $a\cdot x+b$. At each internal node, compute both children and then either their maximum or a numerically stable log-sum-exp. The latter should use

$$
\operatorname{LSE}_\beta(a,b)
=m+\frac{1}{\beta}\log\left(e^{\beta(a-m)}+e^{\beta(b-m)}\right),
$$

where $m=\max(a,b)$, to avoid overflow.

If the tree has $N$ nodes and the input has dimension $n$, evaluation costs $O(Nn)$ when every leaf dot product is computed directly, and $O(N)$ additional scalar operations. The recursion stack uses $O(d)$ memory, where $d$ is depth.

### 7.2 Certification of stable labels

Given a hard score $F_P(x)$, compute

$$
E=\frac{d(P)\log 2}{\beta}.
$$

If $|F_P(x)|>E$, return the hard label together with a stability certificate. Otherwise report the point as unresolved by this bound. This is a sufficient test, not a necessary one: classifications may agree inside the uncertainty band, but the theorem alone does not guarantee it.

### 7.3 Grid extraction of decision geometry

For visualization in two dimensions, evaluate $F_P$ and $S_{P,\beta}$ on a rectangular grid. Approximate zero contours by detecting sign changes along cell edges and interpolating crossing locations. Overlay the contours and color points according to whether $|F_P(x)|$ exceeds the certified error. With an $M\times M$ grid and an $N$-node tree, direct evaluation costs $O(M^2N)$ scalar tree operations, plus leaf-coordinate costs.

Grid extraction illustrates rather than proves topology. Resolution can miss small components, and the value theorem does not itself imply isotopy of contours.

## 8. Applications

The estimate applies wherever hard max-affine models are replaced by differentiable surrogates. In neural optimization, it calibrates softplus or nested log-sum-exp approximations. In energy-based models, $\beta$ acts as inverse temperature and the theorem bounds the gap between a zero-temperature tropical energy and its finite-temperature free-energy analogue. In robust classification, the margin theorem separates inputs whose labels are certified under smoothing from those near the decision level. In numerical continuation, the smooth family indexed by $\beta$ provides a controlled route toward a nonsmooth limit.

The depth dependence suggests architectural interventions. If a hard maximum over many leaves is implemented as a balanced tree, the certified compositional error can be much smaller than for a chain. Conversely, if the desired smooth semantics is the log of a sum over all leaf exponentials, tree structure and multiplicities should be chosen deliberately.

The counterexamples also affect data analysis. Plotting the raw zero set of a ReLU score may display filled regions rather than a boundary. A meaningful classifier boundary may instead be the boundary of the positive decision region. Similarly, singularity statistics should be measured from realized active sets and local slope changes, not inferred solely from nominal widths.

## 9. Discussion and future work

The present results establish a rigorous bridge for convex max-affine models but do not identify every ReLU classifier with a single tropical polynomial. Signed output weights and affine combinations can destroy convexity. A natural conjecture is that scalar feed-forward ReLU networks admit controlled representations as differences of two max-affine expressions. Their decision sets would then be equality loci of two tropical polynomials, a tropical-rational geometry.

A second direction is topological stability. The explicit band $d\log(2)/\beta$ controls values and labels away from zero. If a compact-domain classifier has no critical value in this band, one may expect the hard and smooth decision sets to be ambient isotopic. Establishing this requires geometric regularity beyond uniform approximation.

Third, singularity bounds should be arrangement-sensitive. In general position in $\mathbb{R}^n$, higher-order singular strata arise when several active affine leaves tie. Counting intersecting active $(n+1)$-subsets is more closely tied to the upper envelope than multiplying pair counts across layers.

Fourth, region recurrences should replace nominal width by the rank of the hyperplane arrangement induced on each inherited region. Products of arrangement growth functions could account for bottlenecks and degeneracy while retaining a layerwise interpretation.

Finally, capacity bounds may emerge from active-set compression. If a signed classifier can be represented as a difference of controlled max-affine expressions, the number and arrangement of active leaves may provide a geometric route to bounds on shattering and classification complexity.

## 10. Conclusion

Max-affine neural expressions admit an exact tropical interpretation and a quantitatively controlled smooth dequantization. For depth $d$ and inverse temperature $\beta>0$, the log-sum-exp evaluation differs from the tropical evaluation by a quantity in

$$
\left[0,\frac{d\log 2}{\beta}\right].
$$

Every point with hard-score magnitude exceeding this bound retains its binary classification. The estimate is uniform and scales with depth rather than leaf count. The recurrence multiplying by $2w_i$ has the closed form $2^L\prod_iw_i$, but converting that algebraic budget into a geometric region theorem requires additional arrangement hypotheses. Scalar ReLU supplies two decisive cautions: its zero set has interior, and its width-one kink survives despite a zero pair count. Together, these results replace an unrestricted slogan with a precise program: use tropical geometry exactly where max-affine structure is present, use explicit margin bounds to control smoothing, and use active arrangements rather than raw architecture to study regions and singularities.

The separation of analytic, combinatorial, and topological claims is essential. The dequantization estimate is unconditional within the max-affine class; the region identity is conditional on its stated recurrence; hypersurface and singularity interpretations need further geometric assumptions. Maintaining these distinctions provides a stable basis for extending the theory without attributing to architecture alone properties that depend on realized coefficients and active configurations.
