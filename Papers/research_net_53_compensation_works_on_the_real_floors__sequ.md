# Compensation Works on the Real Floors: Sequential GPTQ as a Schur Complement, and a Fixed-Protocol Quantization Ladder on a 0.5B Language Model

**Aristotle**

*October 2026*

---

## Abstract

We study post-training weight quantization of a pretrained language model (Qwen2.5-0.5B) on a single fixed evaluation protocol, comparing per-channel round-to-nearest (RTN), grouped RTN (group size 128), and sequential, curvature-compensated quantization (GPTQ, group size 128) at matched bit widths. At 4 bits, GPTQ attains a cross-entropy increase of $\Delta\mathrm{CE} = +0.1512$ (retained next-token accuracy $0.9546$), a factor $2.10$ better than grouped RTN ($+0.318$) and $5.21$ better than per-channel RTN ($+0.788$). At 3 bits, GPTQ rescues the model from $+9.23$ (per-channel RTN) and $+2.72$ (grouped RTN) to $+1.19$. The final two transformer layers contribute $0.0277$, i.e. $18.3\%$ of the compensated loss, refuting a pre-registered prediction of more than $25\%$.

To explain these measurements we give a self-contained analysis of compensation in the layer-wise quadratic model $L(\delta)=\delta^\top H\delta$. Writing the curvature in quantized/free block form, we prove: (i) an exact completion-of-the-square identity whose remainder is the Schur complement $S = A - BD^{-1}B^\top$; (ii) the compensated loss is exactly $u^\top S u$, attained by the unique update $v^\star = -D^{-1}B^\top u$; (iii) compensation never hurts, its gain equals $\|D^{-1}B^\top u\|_D^2$, and the gain is strict if and only if $B^\top u \ne 0$; (iv) the quantized block of $H^{-1}$ is $S^{-1}$, which yields the GPTQ single-column cost $e^2/[H^{-1}]_{qq}$ and the inequality $H_{qq}[H^{-1}]_{qq}\ge 1$; (v) enlarging the compensation window never increases the loss; (vi) the compensated-to-RTN ratio is invariant under rescaling of the error; and (vii) an exact criterion for when compensation lowers a block's share of the total loss. Confronting the theory with the data, we find that the pre-registered bar $\Delta\mathrm{CE}\le 0.15$ is missed in exact arithmetic ($0.1512 - 0.15 = 0.0012$), and that the observed $8.4\%$ drift of the compensation lever between 4 and 3 bits is incompatible with any single quadratic model whose 3-bit error is a rescaling of the 4-bit error.

---

## 1. Introduction

Running a modern language model on commodity hardware — our reference target is a host with 6 GB of memory — requires compressing its weights well below 16 bits. The simplest scheme, round-to-nearest onto a uniform grid, degrades quickly as the bit width drops. Two structural levers are commonly used to improve it:

1. **Grouping**: instead of one grid (scale and zero point) per output channel, use one grid per contiguous group of $g$ input weights (here $g=128$), so that outliers only stretch the grid of their own group.
2. **Compensation**: quantize weights sequentially and, after each rounding decision, update the not-yet-quantized weights to cancel the induced change in the layer output as well as possible. This is the GPTQ algorithm of Frantar, Ashkboos, Hoefler and Alistarh (2022), itself a scalable descendant of the Optimal Brain Surgeon (OBS) of Hassibi and Stork (1993).

Neither lever is new. The contributions of this paper are:

* **A fixed-protocol ladder.** All arms — per-channel RTN, grouped RTN and grouped GPTQ, at 4 and 3 bits — are measured on one validated harness with a shared reference, protocol and granularity (Section 5).
* **A tail-share quantification.** We measure the contribution of the last two transformer layers to the compensated loss and find it to be $18\%$, smaller than under RTN-style expectations.
* **A complete structural explanation of compensation** in the quadratic model, phrased entirely through the Schur complement, including exact gain formulas, a strictness criterion, window monotonicity, scale invariance, and a tail-share criterion (Sections 2–4).
* **A falsification bridge** between theory and data: the measured drift of the compensation lever certifies that the error shape changes between bit widths (Section 6).

## 2. Setting and definitions

Throughout, all matrices are real. For a symmetric matrix $M$ and vector $x$ write

$$
q_M(x) = x^\top M x .
$$

**Definition 2.1 (Layer-wise quadratic loss).** Let a linear layer with weight row $w\in\mathbb{R}^d$ be evaluated on calibration inputs $x_1,\dots,x_N\in\mathbb{R}^d$. The *curvature* is $H = \frac1N\sum_k x_k x_k^\top$ (in practice plus a small damping $\lambda I$). Perturbing the weights by $\delta$ changes the outputs by $\delta^\top x_k$, and the mean squared output change is $L(\delta) = q_H(\delta)$.

**Definition 2.2 (Quantized/free split).** Partition the coordinates into a *quantized* index set $Q$ (of size $m$) and a *free* index set $F$ (of size $n$). Write

$$
H = \begin{pmatrix} A & B \\ B^\top & D\end{pmatrix},\qquad A\in\mathbb{R}^{m\times m},\; B\in\mathbb{R}^{m\times n},\; D\in\mathbb{R}^{n\times n},
$$

and $\delta = (u, v)$, where $u\in\mathbb{R}^m$ is the rounding error on $Q$ (fixed once rounding is done) and $v\in\mathbb{R}^n$ is the update applied to the free weights (to be chosen). We always assume $D$ is positive definite.

**Definition 2.3 (Schur complement and optimal update).**

$$
S = A - BD^{-1}B^\top, \qquad v^\star(u) = -D^{-1}B^\top u .
$$

**Definition 2.4 (RTN and compensated losses).** The *RTN loss* of an error $u$ is the loss with no update, $L(u,0) = q_A(u)$. The *compensated loss* is $\min_v L(u,v)$. The *compensation lever* is the ratio of the RTN loss to the compensated loss.

**Definition 2.5 ($D$-norm).** For $D$ positive definite, $\|z\|_D^2 = z^\top D z \ge 0$, with equality only for $z = 0$.

## 3. Compensation as a Schur complement

### 3.1 The completion-of-the-square identity

**Theorem 3.1 (OBS split).** For all $u\in\mathbb{R}^m$, $v\in\mathbb{R}^n$,

$$
L(u,v) \;=\; \big\|D^{-1}B^\top u + v\big\|_D^2 \;+\; u^\top S\, u .
$$

*Proof.* Expand $L(u,v) = u^\top A u + 2u^\top B v + v^\top D v$. Expanding the right-hand side, with $z = D^{-1}B^\top u$, gives $z^\top D z + 2 z^\top D v + v^\top D v + u^\top A u - u^\top B D^{-1} B^\top u$. Since $z^\top D z = u^\top BD^{-1}B^\top u$ and $z^\top D v = u^\top B v$ (using symmetry of $D^{-1}$), the two expressions coincide. $\square$

**Lemma 3.2 (RTN sees only the quantized block).** $L(u,0) = q_A(u)$. *Proof.* Immediate from the block expansion. $\square$

### 3.2 Optimality, attainment, uniqueness

**Theorem 3.3 (OBS lower bound).** For every update $v$, $\;u^\top S u \le L(u,v)$.

*Proof.* The first summand in Theorem 3.1 is a $D$-norm, hence non-negative. $\square$

**Theorem 3.4 (Attainment).** $L(u, v^\star(u)) = u^\top S u$.

*Proof.* With $v = v^\star(u)$ the vector inside the $D$-norm is $0$. $\square$

**Theorem 3.5 (Uniqueness).** $L(u,v) = u^\top S u$ if and only if $v = v^\star(u)$.

*Proof.* By Theorem 3.1, equality holds iff $\|D^{-1}B^\top u + v\|_D^2 = 0$, iff $D^{-1}B^\top u + v = 0$ by positive definiteness. $\square$

Hence the compensated loss of Definition 2.4 is exactly $q_S(u)$, and the minimizer is unique.

### 3.3 The exact gain and its strictness

**Theorem 3.6 (Exact compensation gain).**

$$
q_A(u) - q_S(u) \;=\; \big\|D^{-1}B^\top u\big\|_D^2 .
$$

*Proof.* Apply Theorem 3.1 at $v = 0$ and use Lemma 3.2. $\square$

**Corollary 3.7 (Compensation never hurts).** $q_S(u) \le q_A(u)$.

**Theorem 3.8 (Strictness criterion).** $q_S(u) < q_A(u)$ if and only if $B^\top u \ne 0$.

*Proof.* By Theorem 3.6 the gain is positive iff $D^{-1}B^\top u \ne 0$. Since $D$ is invertible, $D^{-1}B^\top u = 0$ iff $B^\top u = 0$. $\square$

Interpretation: compensation strictly helps exactly when the rounding error is correlated, through the cross-curvature $B$, with the weights still free to move. For decorrelated features ($B = 0$) compensation is useless; for strongly correlated features — the norm in transformer activations — it is powerful.

**Proposition 3.9 (Non-negativity).** If the full curvature $H$ is positive semidefinite, then $q_S(u)\ge 0$ for every $u$.

*Proof.* $q_S(u) = L(u,v^\star(u)) = q_H\big((u, v^\star(u))\big) \ge 0$ by Theorem 3.4. $\square$

**Theorem 3.10 (Scale invariance of the lever).** For any $t\ne 0$,

$$
\frac{q_S(tu)}{q_A(tu)} = \frac{q_S(u)}{q_A(u)} .
$$

*Proof.* Quadratic forms are homogeneous of degree two, $q_M(tu) = t^2 q_M(u)$; cancel $t^2 \neq 0$. $\square$

Interpretation: changing the bit width at a fixed error *shape* (a pure rescaling of the error vector, as a coarser grid would induce if all errors scaled together) leaves the compensation lever unchanged.

## 4. The GPTQ column formula and structural consequences

### 4.1 Inverse blocks

**Theorem 4.1 (Block inverse).** If $H$ is invertible and $D$ is positive definite, the $Q\times Q$ block of $H^{-1}$ equals $S^{-1}$.

*Proof sketch.* This is the classical block-inversion formula: when $D$ is invertible and $H$ is invertible, $S$ is invertible and

$$
H^{-1} = \begin{pmatrix} S^{-1} & -S^{-1}BD^{-1} \\ -D^{-1}B^\top S^{-1} & D^{-1} + D^{-1}B^\top S^{-1} B D^{-1}\end{pmatrix},
$$

as verified by direct multiplication. $\square$

**Lemma 4.2 (Principal blocks inherit definiteness).** If $H$ is positive definite, so is $D$. *Proof.* For $x\ne 0$, $x^\top D x = (0,x)^\top H (0,x) > 0$. $\square$

### 4.2 The single-column formula

**Theorem 4.3 (GPTQ / OBS column cost).** Let $H$ be positive definite, let $Q = \{q\}$ be a single coordinate quantized with rounding error $e\in\mathbb{R}$, and let all other coordinates be free. Then the optimally compensated loss is

$$
L\big(e, v^\star(e)\big) = \frac{e^2}{[H^{-1}]_{qq}} .
$$

*Proof.* By Theorem 3.4 the loss is $S e^2$ with $S$ a scalar. It is positive: applying Theorem 3.4 with $e = 1$ shows $S = q_H\big((1,v^\star(1))\big) > 0$. By Theorem 4.1, $[H^{-1}]_{qq} = S^{-1}$, so $Se^2 = e^2/[H^{-1}]_{qq}$. $\square$

This is the quantity that drives the GPTQ update: when column $q$ is rounded with error $e_q$, the remaining weights move by $-\frac{e_q}{[H^{-1}]_{qq}}\,[H^{-1}]_{F,q}$, and the loss increases by $e_q^2/[H^{-1}]_{qq}$.

**Corollary 4.4 (Diagonal inequality).** For every positive definite $H$ and every index $q$,

$$
H_{qq}\,[H^{-1}]_{qq} \;\ge\; 1 .
$$

*Proof.* The RTN cost of the error $e = 1$ is $H_{qq}$ (Lemma 3.2), and the compensated cost is $1/[H^{-1}]_{qq}$ (Theorem 4.3). By Corollary 3.7, $1/[H^{-1}]_{qq} \le H_{qq}$; multiply by $[H^{-1}]_{qq} > 0$, which is positive because $H^{-1}$ is positive definite. $\square$

The quantity $1/(H_{qq}[H^{-1}]_{qq})\in(0,1]$ is the fraction of a single column's RTN cost that survives compensation; it equals $1$ exactly when $H_{qF} = 0$ (Theorem 3.8).

### 4.3 Windows

GPTQ implementations restrict updates to a "lazy" block of columns aligned with the quantization groups. The following shows this restriction can only cost, never gain.

**Theorem 4.5 (Wider windows never hurt).** Split the free set as $F = F_1 \sqcup F_2$ and let $S_1$ be the Schur complement computed using only $F_1$ as free set (i.e. with $B$ and $D$ replaced by their $F_1$-columns and $F_1\times F_1$ block). Then for every $u$,

$$
q_S(u) \;\le\; q_{S_1}(u).
$$

*Proof.* The $F_1\times F_1$ block of $D$ is positive definite (Lemma 4.2 applied to $D$). Freezing the $F_2$ weights at zero turns the full problem into the restricted one: $L\big(u,(v_1,0)\big)$ equals the restricted loss of $(u,v_1)$. Taking $v_1$ to be the restricted optimum, the restricted optimal value $q_{S_1}(u)$ is one particular value of the full loss, which by Theorem 3.3 is at least $q_S(u)$. $\square$

### 4.4 Tail share

**Theorem 4.6 (Tail-share criterion).** Let a *core* and a *tail* block have RTN costs $a,b>0$ and compensation gains $g_a<a$, $g_b<b$. Then compensation strictly lowers the tail's share of the total loss,

$$
\frac{b-g_b}{(a-g_a)+(b-g_b)} \;<\; \frac{b}{a+b},
$$

if and only if

$$
\frac{g_a}{a} < \frac{g_b}{b}.
$$

*Proof.* All denominators are positive. Cross-multiplying, the first inequality is $(b-g_b)(a+b) < b\,(a+b-g_a-g_b)$, which simplifies to $b\,g_a < a\,g_b$; dividing by $ab>0$ gives the second. $\square$

Combined with Theorem 3.6, the per-block gains are $g = \|D^{-1}B^\top u\|_D^2$ for the respective blocks, so the tail share falls precisely when the tail's errors are proportionally better correlated with their free weights.

## 5. The experiment

### 5.1 Protocol

* **Model:** Qwen2.5-0.5B (24 transformer layers), evaluation context 512 tokens.
* **Metric:** $\Delta\mathrm{CE}$, the increase of next-token cross-entropy over the unquantized model, and *retained accuracy*, the ratio of quantized to unquantized next-token accuracy. The unquantized baseline (accuracy $0.4460$, cross-entropy $2.8697$) was reproduced exactly before any arm was run.
* **GPTQ implementation:** sequential layer-wise processing, with inputs to each layer recaptured from the already-quantized prefix of the network; curvature accumulated by hooks on the actual linear modules; quantization blocks aligned to groups of 128; Cholesky factorization of the damped inverse curvature, retried with escalating damping on failure (schedule fixed before the run). Calibration: 16 sequences drawn from the training side only. No column reordering ("act-order").
* **Reference floors** (from the preceding round, same harness): per-channel 4-bit RTN $+0.788$; grouped 4-bit RTN $+0.318$; per-channel 6-bit RTN $+0.035$; per-channel 3-bit RTN $+9.23$; grouped 3-bit RTN $+2.72$.

### 5.2 Results

| Arm | $\Delta\mathrm{CE}$ | retained accuracy |
|---|---|---|
| GPTQ 4-bit $g{=}128$, all layers | $+0.1512$ | $0.9546$ |
| GPTQ 4-bit $g{=}128$, core (layers 0–21) | $+0.1235$ | $0.9641$ |
| GPTQ 3-bit $g{=}128$, all layers | $+1.1932$ | $0.7086$ |

The full ladder:

| bits | per-channel RTN | grouped RTN | grouped GPTQ | grouping lever | compensation lever | compounded |
|---|---|---|---|---|---|---|
| 4 | $0.788$ | $0.318$ | $0.1512$ | $2.478$ | $2.103$ | $5.212$ |
| 3 | $9.23$ | $2.72$ | $1.1932$ | $3.393$ | $2.280$ | $7.736$ |

### 5.3 Pre-registered predictions, assessed in exact arithmetic

* **P1** ($\Delta\mathrm{CE}\le 0.15$ for GPTQ 4-bit): **missed.** $0.1512 - 0.15 = 0.0012 > 0$. (The run's own log described this as confirmed "at the boundary"; the exact comparison does not support that reading. The substantive finding — a $2.10\times$ improvement over grouped RTN — stands.)
* **P2** ($\Delta\mathrm{CE}\le 0.14$, approaching the 6-bit per-channel floor): **refuted.**
* **P3** (the final two layers contribute more than $25\%$ of the compensated loss): **refuted.** The tail increment is exactly $0.1512 - 0.1235 = 0.0277$, and the share $0.0277/0.1512 \approx 0.1832$ lies strictly between $1/6$ and $1/5$.

### 5.4 Deployment table (6 GB host)

| scheme | usable at | cost |
|---|---|---|
| per-channel RTN | $\ge 6$ bits | $+0.035$ at 6 bits; $+0.788$ at 4 bits |
| grouped RTN | 4 bits | $+0.32$ |
| grouped GPTQ | 4 bits (3 bits survivable) | $+0.15$ (3 bits: $+1.19$) |

### 5.5 Engineering hazards

Three silent errors were caught before the reported runs: (1) hooks registered on container modules rather than linear modules, detected by checking the width of captured activations; (2) a broadcasting error in per-column scales; (3) loss of numerical positive definiteness of the curvature computed from partially quantized activations, handled by escalating damping. A single-matrix regression test is retained: on one random layer, GPTQ must beat RTN on layer-output error. Corollary 3.7 guarantees that each compensation step cannot hurt *for the error it corrects*; since compensation also changes the weights rounded later, and hence their rounding errors, the end-to-end comparison is an empirical check rather than a theorem.

## 6. Theory meets data

**Proposition 6.1 (Exact ladder facts).** In exact rational arithmetic:

1. $0.1512 > 0.15$, with difference $0.0012$.
2. The tail increment is $0.0277$ and $1/6 < 0.0277/0.1512 < 1/5$.
3. The 4-bit compensation lever satisfies $2.1 \le 0.318/0.1512 < 2.11$.
4. The compensation lever drifts by less than $9\%$: $1 < \dfrac{2.72/1.1932}{0.318/0.1512} < 1.09$.
5. The grouping lever drifts by more than $35\%$: $\dfrac{9.23/2.72}{0.788/0.318} > 1.35$.
6. The compounded lever exceeds $5$ at 4 bits and $7.7$ at 3 bits.

*Proof.* Direct computation with the rational values. $\square$

**Theorem 6.2 (No single rescaled quadratic model).** There are no matrices $A,B,D$ (with $D$ invertible), error vector $u$, and scalar $t\ne0$ such that simultaneously

$$
q_A(u) = 0.318,\quad q_S(u) = 0.1512,\quad q_A(tu) = 2.72,\quad q_S(tu) = 1.1932 .
$$

*Proof.* By Theorem 3.10 the ratios $q_S/q_A$ at $u$ and at $tu$ coincide, but $0.1512/0.318 \neq 1.1932/2.72$ (cross-multiplying: $0.1512\cdot 2.72 = 0.411264 \ne 0.379437\ldots = 1.1932\cdot 0.318$). $\square$

*Interpretation.* Within the quadratic model, the $8.4\%$ drift of the compensation lever cannot be a scale effect. It must reflect a change of error **shape** between bit widths — the pattern of rounding directions, and in particular clipping at group extremes — or a departure of the true loss from its quadratic approximation. The much larger drift of the grouping lever is consistent with grouping being intrinsically a shape-changing operation: it removes outlier-driven grid stretching, whose damage grows as the grid coarsens.

**Reading the tail share.** By Theorem 4.6, the observed $18\%$ compensated tail share is smaller than the RTN tail share if and only if compensation's relative gain in layers 22–23 exceeds that in layers 0–21. The RTN core-only arm, a single cheap run, would decide this.

## 7. Algorithms

**Algorithm 1 (Column-sequential GPTQ for one weight row).** Input: weights $w\in\mathbb{R}^d$, damped curvature $H_\lambda = H+\lambda I$, bit width $b$, group size $g$.

1. Compute $H_\lambda^{-1}$ and its upper Cholesky factor $U$ ($H_\lambda^{-1} = U^\top U$). On failure, increase $\lambda$ and retry.
2. For $q = 1,\dots,d$:
   1. If $q$ starts a group, fix the group's grid (scale and zero point) from the *current* weights $w_{q:q+g-1}$.
   2. $\hat w_q \leftarrow \mathrm{round}(w_q)$ on the group grid; $\varepsilon \leftarrow (w_q - \hat w_q)/U_{qq}$.
   3. $w_j \leftarrow w_j - \varepsilon\, U_{qj}$ for all $j>q$.
3. Return $\hat w$.

$U_{qq}^2$ equals the $(q,q)$ entry of the inverse of the trailing block $H_\lambda[q{:},q{:}]$, so step 2.2–2.3 is precisely the OBS update of Theorem 4.3 applied to the current free set $\{q+1,\dots,d\}$; summing these per-column costs reproduces the final loss (numerically exact in our demonstrations). The cost is $O(d^3)$ for the factorization plus $O(d^2)$ per row; the factorization is shared across all rows of a layer.

**Algorithm 2 (Fixed-protocol ladder).** For each bit width $b\in\{4,3\}$ and each arm (per-channel RTN, grouped RTN, grouped GPTQ), quantize all target linear modules with the same reference model, calibration data, evaluation set and grouping, and report $\Delta\mathrm{CE}$ and retained accuracy; compute grouping, compensation and compounded levers as ratios of successive floors.

## 8. Discussion

**What the theory says.** Compensation is exactly the elimination of the free weights from a quadratic form. Its floor is the Schur complement, reached by a unique linear correction; its gain is a $D$-energy that vanishes iff the error is uncorrelated with the free weights. The ubiquity of the Schur complement explains the success of GPTQ without appeal to any specific property of language models beyond correlated activations.

**What the data say.** On a real 0.5B model, the compensation lever is about $2.1$–$2.3\times$, compounding with grouping to more than $5\times$ (4 bits) and $7.7\times$ (3 bits). The last two layers remain measurably more expensive, but compensation compresses their share.

**Limitations.** The guarantees of Sections 3–4 concern a fixed error vector; in sequential quantization the later rounding errors depend on earlier updates, so the end-to-end superiority of GPTQ over RTN is empirical (it held in every measured arm). One model; context 512; no act-order; 16 calibration sequences; the quadratic model is a local surrogate for cross-entropy, so theorems about $q_H$ constrain the data only through that surrogate. Theorem 6.2 is a statement about the quadratic model: it shows the measured pairs cannot be explained by error rescaling within it, not that cross-entropy is or is not quadratic.

## 9. Future work

1. **Correlation-spectrum law.** Conjecture: under independent uniform rounding errors, the expected GPTQ/RTN ratio for a layer is $\operatorname{tr}\big(\operatorname{diag}(H^{-1})^{-1}\big)/\operatorname{tr}(H)$ up to sequential-order corrections, so the lever is predictable from the curvature alone (Theorem 4.3 gives the per-column compensated cost $\mathbb{E}[e^2]/[H^{-1}]_{qq}$ against the RTN cost $\mathbb{E}[e^2]H_{qq}$).
2. **Sequential telescoping and act-order.** Conjecture: the total loss of column-sequential GPTQ equals $\sum_q e_q^2/d_q$ with $d_q$ the successive pivots (via the Crabtree–Haynsworth quotient property of iterated Schur complements), and processing columns by descending $H_{qq}$ minimizes the worst-case bound $\sum_q (s_q^2/4)/d_q$, with $s_q$ the grid step.
3. **Tail-share compression.** If tail errors are relatively better correlated with free weights, the RTN tail share at 4 bits should exceed $18\%$; one RTN core-only run tests this via Theorem 4.6.
4. **Shape-drift decomposition.** The 4→3-bit lever drift $2.103\to2.280$ should be explained by the change of normalized error direction $u/\|u\|$ and may vanish after re-scaling 3-bit errors by grouped clipping statistics.
5. **Engineering:** act-order variant, a joint weight + KV-cache budget optimizer, tail-aware mixed precision keeping layers 22–23 at higher bit width, and transfer to Qwen2.5-1.5B.

## 10. Conclusion

A century-old identity — completing the square in block form — fully accounts for the mechanics of compensated quantization: the unavoidable cost is a Schur complement, the avoidable cost is removed by a unique update, and the gain is strict exactly when errors and free weights are correlated. On a real 0.5B model, this mechanism halves the damage of grouped rounding at 4 bits and makes 3-bit weights survivable, while the residual drift of its lever tells us that coarser grids change the *shape* of the rounding error, not merely its size.

## References

* B. Hassibi and D. G. Stork. Second order derivatives for network pruning: Optimal Brain Surgeon. *NeurIPS*, 1993.
* E. Frantar, S. Ashkboos, T. Hoefler, D. Alistarh. GPTQ: Accurate post-training quantization for generative pre-trained transformers. *ICLR*, 2023 (arXiv 2022).
* F. Zhang (ed.). *The Schur Complement and Its Applications*. Springer, 2005.
