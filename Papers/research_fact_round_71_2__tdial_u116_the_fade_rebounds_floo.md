# The Half-Amplitude Floor: Sharp Limits of Block-Balanced Estimation for Rebound Ladders

**Author:** Aristotle
**Date:** 2026-08-30

---

## Abstract

We study the estimation of the asymptotic floor $L$ of a fading measurement ladder $\rho_0,\rho_1,\rho_2,\dots$ whose residuals $s_k = \rho_k - L$ are bounded, $|s_k| \le \eta$, and whose sign pattern decomposes into $m$ maximal alternating constant-sign blocks of lengths $n_1,\dots,n_m$. The natural estimator that gives each block equal total weight — weight $1/n_i$ per rung of block $i$, so that the estimator is the arithmetic mean of the $m$ block means — was conjectured to achieve worst-case error $2\eta/m$, i.e. an $O(1/m)$ consistency rate in the number of blocks.

We prove the sharp law and refute the conjecture. The block-balanced estimator satisfies
$$\bigl|\widehat L_{\mathrm{bb}} - L\bigr| \;\le\; \frac{\eta\,\lceil m/2\rceil}{m},$$
a bound in which the block lengths do not appear at all, and this is an equality for an explicit admissible ladder. Consequently the worst-case error is at least $\eta/2$ for every $m$ — there is no decay — and from $m \ge 5$ onward it strictly exceeds the conjectured $2\eta/m$. The failure is structural, not a defect of the weights: for *any* nonnegative block weights summing to one, one of two explicit extremal ladders is estimated with error at least $\eta/2$. It is not a defect of linearity either: a single ladder of readings is realised exactly by the floor $L$ with saturating positive blocks and by the floor $L+\eta$ with saturating negative blocks, so every estimation procedure whatsoever errs by at least $\eta/2$ on one of the two worlds. The barrier is attained by the nonlinear midrange $\tfrac12(\max + \min)$, so the minimax floor error under bounded alternating residuals is *exactly* $\eta/2$.

The salvage is an exact-versus-bounded dichotomy. If the residuals have *exact* amplitude $\eta$ rather than being merely bounded by it, the block means are exactly $\pm\eta$, the alternating sum telescopes, and the very same estimator achieves $|\widehat L_{\mathrm{bb}} - L| \le \eta/m$ for arbitrary block lengths. At a fixed configuration the two statements read: error $\ge \eta/2$ under boundedness, error $\le \eta/m$ under saturation.

Applied to the motivating record — a rank-correlation ladder whose first positive step measured $+0.0226$, forcing $\eta \ge 0.0226$ — no number of blocks brings the worst-case block-balanced floor estimate below $\pm 0.0113$. This reproduces, by a purely combinatorial route making no reference to the fade ratio, a resolution floor previously derived from the analytic fade model.

**Keywords:** bounded noise, alternating sign patterns, minimax estimation, block reweighting, midrange estimator, asymptotic floor, sign changes, rank correlation ladders.

---

## 1. Introduction

### 1.1 The empirical setting

A dial experiment records a pooled rank correlation $\rho$ between two quantities as a discrete control parameter is increased. Successive rungs of the ladder read

$$0.5739,\quad 0.5436,\quad 0.5005,\quad 0.4880,\quad 0.4621,\quad 0.4847,$$

five decreases followed by a single increase of $+0.0226$. Two generative stories were in competition:

* a **pure multiplicative fade**, $\rho_{k+1} \le q\,\rho_k$ with $q < 1$ and $\rho_k \ge 0$ — a slide to zero;
* an **affine fade toward a positive floor with rebound noise**, $\rho_{k+1} - L = \lambda(\rho_k - L) + \varepsilon_k$ with $|\varepsilon_k| \le \eta$ and $|\lambda| < 1$.

The first story is refuted by a single positive step, with no statistics whatsoever: if $q \le 1$ and $\rho_k \ge 0$, then $\rho_{k+1} \le q\rho_k \le \rho_k$, so *no* step can be positive. In the second story the same step is informative rather than anomalous: in a non-expanding model ($\lambda \le 1$) sitting above its floor, a positive step of size $\delta$ forces $\eta \ge \delta$. The observed rebound therefore certifies a noise level $\eta \ge 0.0226$.

Accepting the floor story, the operative question is quantitative: **how accurately can $L$ be estimated from the ladder?** That is the question this paper answers, sharply and negatively, for the whole class of averaging procedures, and then in minimax form for all procedures.

### 1.2 Prior layers of the analysis

Three structural facts frame the present work; each is stated inline where used.

1. **Identifiability threshold.** If a single ladder is a noisy affine fade with ratio $\lambda$ and noise level $\eta$ for *both* floors $L_1$ and $L_2$, then $|1-\lambda|\,|L_1 - L_2| \le 2\eta$; conversely, whenever that inequality holds, an explicit constant ladder at the midpoint realises both models exactly. Hence two floors are confusable at noise $\eta$ *precisely* when $|1-\lambda|\,|L_1-L_2| \le 2\eta$, and the resolution of any floor measurement is $2\eta/|1-\lambda|$.

2. **Sign changes cap drift, under exact amplitude.** For a $\pm 1$ sign sequence $e_0,\dots,e_K$ with $c$ adjacent sign changes, $\bigl|\sum_{k\le K} e_k\bigr| \le (K+1) - c$, sharp at both extremes. Consequently the mean of $K+1$ residuals of amplitude *exactly* $\eta$ with $c$ sign changes is at most $\eta\,((K+1)-c)/(K+1)$: sign changes convert directly into accuracy.

3. **The majority-count drift law, under boundedness.** That conversion collapses when amplitudes are merely bounded. Writing $A$ for the number of rungs carrying the same sign as the last one and $B$ for the number carrying the opposite sign, the correct statement for $|s_k| \le \eta$ is $\bigl|\sum_k s_k\bigr| \le \eta\max(A,B)$, and it is attained. Since maximal constant-sign blocks alternate, $A$ and $B$ are precisely the two block-length sums. Explicitly, four residuals bounded by $1$ with three sign changes can drift by $3/2$, against the $1$ predicted by the exact-amplitude law. Half of each sign change survives: $\bigl|\sum_k s_k\bigr| \le \eta\bigl((K+1) - c/2\bigr)$, with the constant $1/2$ optimal.

Item 3 says the *unweighted* mean of $K+1$ rungs has worst-case error $\eta\max(A,B)/(K+1)$, which does not decay when the block pattern is unbalanced. That observation motivates the estimator studied here.

### 1.3 The conjecture and its fate

**Block-balanced reweighting.** Give each rung of a maximal constant-sign block of length $n_i$ the weight $1/n_i$, so that each of the $m$ blocks carries total weight $1$ and no long block can shout down a short one. Since long blocks are exactly what defeats the plain mean, one expects the imbalance to be neutralised and the alternation to produce genuine cancellation across blocks. The conjectured worst-case error was $2\eta/m$.

**Result.** The conjecture is false, and its failure is total. The exact worst case is $\eta\lceil m/2\rceil / m \ge \eta/2$: the estimator is not consistent in the number of blocks. Moreover no reweighting whatsoever, and indeed no estimation procedure whatsoever, does better than $\eta/2$; and the simplest possible nonlinear procedure attains it.

---

## 2. Setup and definitions

Throughout, $\eta \ge 0$ is a noise amplitude and $m \ge 1$ a number of blocks.

**Definition 2.1 (Block data).** A *block configuration* is a sequence of block lengths $n : \{0,1,\dots\} \to \mathbb{Z}_{>0}$, $n_i \ge 1$, together with a doubly-indexed residual array $s_{i,j} \in \mathbb{R}$, where $i$ indexes the block and $0 \le j < n_i$ indexes the rung inside block $i$. The associated readings are $\rho_{i,j} = L + s_{i,j}$ for an unknown floor $L$.

**Definition 2.2 (Admissibility).** Fix a starting sign $\epsilon \in \{+1,-1\}$. The array $s$ is *$(\eta,\epsilon)$-admissible* if

* (**boundedness**) $|s_{i,j}| \le \eta$ for all $i,j$; and
* (**weak alternation**) $\epsilon \, (-1)^i s_{i,j} \ge 0$ for all $i,j$.

Weak alternation says the residuals of block $i$ lie on the side of zero dictated by the parity of $i$, with the convention that $0$ lies on both sides. This is the honest formalisation of "the residuals change sign block by block": one cannot require strict positivity inside a block, because a residual may legitimately pass through zero, and it is precisely this slack that drives everything below.

**Definition 2.3 (Block sums and block means).** $S_i = \sum_{j<n_i} s_{i,j}$ and the block mean is $S_i / n_i$.

**Definition 2.4 (The block-balanced estimator).** With $\rho$ the readings, the block-balanced floor estimate is
$$\widehat L_{\mathrm{bb}} \;=\; \frac1m \sum_{i<m} \frac{1}{n_i}\sum_{j<n_i} \rho_{i,j},$$
i.e. the arithmetic mean of the $m$ block means of the readings. Its error is exactly the same functional applied to the residuals,
$$\widehat L_{\mathrm{bb}} - L \;=\; \mathrm{BB}(s) \;:=\; \frac1m \sum_{i<m} \frac{S_i}{n_i}.$$
All statements below are phrased for $\mathrm{BB}(s)$; they translate verbatim into statements about $\widehat L_{\mathrm{bb}} - L$.

**Definition 2.5 (General weighted block estimator).** For weights $w : \{0,\dots,m-1\} \to \mathbb{R}$,
$$\mathrm{W}_w(s) \;=\; \sum_{i<m} w_i\,\frac{S_i}{n_i}.$$
The block-balanced estimator is the uniform member: $\mathrm{BB} = \mathrm{W}_w$ with $w_i \equiv 1/m$.

**Definition 2.6 (The extremal ladders).** For $\eta \ge 0$ define two arrays with all blocks singletons ($n_i = 1$):
$$P_{i,j} = \begin{cases}\eta, & i \text{ even},\\ 0, & i \text{ odd},\end{cases}
\qquad
N_{i,j} = \begin{cases}0, & i \text{ even},\\ -\eta, & i \text{ odd}.\end{cases}$$
Both are $(\eta,+1)$-admissible: each entry has modulus at most $\eta$, and each entry lies weakly on the side prescribed by the parity of its block index. $P$ *saturates the positive blocks and silences the negative ones*; $N$ is its mirror image.

**Definition 2.7 (The midrange).** For readings $x : \mathbb{N}\to\mathbb{R}$ and window size $m+1$,
$$\mathrm{MR}(x,m) = \tfrac12\Bigl(\max_{k \le m} x_k + \min_{k\le m} x_k\Bigr).$$

---

## 3. Alternating sequences of bounded terms barely cancel

Everything rests on one elementary but easily mis-stated invariant. The exact-amplitude intuition — $\eta - \eta + \eta - \cdots$ telescopes to at most $\eta$ — is simply wrong for bounded terms, and the correct bound is larger by a factor of order $m$.

**Theorem 3.1 (Two-sided invariant for bounded alternating terms).** Let $a_0,a_1,\dots$ be real with $|a_i| \le \eta$ and $(-1)^i a_i \ge 0$ for all $i$. Then for every $m \ge 0$,
$$-\eta\left\lfloor \frac{m}{2}\right\rfloor \;\le\; \sum_{i<m} a_i \;\le\; \eta\left\lceil \frac{m}{2}\right\rceil .$$

*Proof sketch.* Note first $\eta \ge |a_0| \ge 0$. Induct on $m$, carrying **both** inequalities. Adding the term $a_m$:

* If $m$ is even, then $(-1)^m = 1$, so $0 \le a_m \le \eta$. The upper budget must grow: $\lceil (m+1)/2\rceil = \lceil m/2\rceil + 1$ absorbs the $+\eta$, while the lower bound is unchanged ($\lfloor (m+1)/2\rfloor = \lfloor m/2\rfloor$) and holds because $a_m \ge 0$ only helps.
* If $m$ is odd, then $(-1)^m = -1$, so $-\eta \le a_m \le 0$. Symmetrically the lower budget grows by one unit of $\eta$ and the upper bound is inherited.

The asymmetry between the two sides is exactly one half of the length, and it never collapses: a term of the "wrong" sign for the bound being tested may vanish, so there is no cancellation to harvest. $\square$

The floor and ceiling in Theorem 3.1 are attained separately by the ladders $P$ and $N$ of Definition 2.6 (with singleton blocks, $a_i = P_{i,0}$ gives the ceiling exactly).

**Corollary 3.2 (Sign-symmetric form).** If $|a_i| \le \eta$ and $\epsilon(-1)^i a_i \ge 0$ for all $i$, with $\epsilon \in \{\pm 1\}$, then
$$\Bigl|\sum_{i<m} a_i\Bigr| \;\le\; \eta \left\lceil \frac{m}{2}\right\rceil .$$

*Proof sketch.* Replace $a_i$ by $\epsilon a_i$, which preserves the bound $|\epsilon a_i| \le \eta$ and turns the hypothesis into the positive-first alternation of Theorem 3.1. Apply the theorem, use $\lfloor m/2\rfloor \le \lceil m/2\rceil$ to symmetrise the two sides, and undo the multiplication by $\epsilon$ using $|\epsilon| = 1$. $\square$

**Remark 3.3 (Contrast with the exact-amplitude case).** If instead $a_i = (-1)^i\eta$ exactly, then $\sum_{i<m} a_i \in \{0,\eta\}$ — bounded by $\eta$ uniformly in $m$. Corollary 3.2 is worse by the factor $\lceil m/2\rceil$, and Section 5 shows this loss is real, not an artefact.

---

## 4. The block-balanced law, and the refutation

**Lemma 4.1 (Block means inherit boundedness).** If $n_i \ge 1$ and $|s_{i,j}| \le \eta$ for all $j < n_i$, then $|S_i/n_i| \le \eta$.

*Proof sketch.* Triangle inequality gives $|S_i| \le \sum_{j<n_i}|s_{i,j}| \le n_i\eta$; divide by $n_i > 0$. $\square$

**Lemma 4.2 (Block means inherit the sign).** Under weak alternation with starting sign $\epsilon$, $\epsilon(-1)^i (S_i/n_i) \ge 0$ for every $i$.

*Proof sketch.* $\epsilon(-1)^i S_i = \sum_{j<n_i}\epsilon(-1)^i s_{i,j}$ is a sum of nonnegative terms, hence nonnegative; dividing by $n_i > 0$ preserves the sign. $\square$

These two lemmas say the block means form exactly the kind of sequence Corollary 3.2 governs — and nothing more. This is the crux: passing to block means *destroys all information about block lengths*, and retains only "modulus at most $\eta$, sign alternating". The next theorem and its sharpness statement show that this is a faithful reduction, not a lossy one.

**Theorem 4.3 (The block-balanced law).** Let $s$ be $(\eta,\epsilon)$-admissible on a block configuration $n$ with $n_i \ge 1$, and let $m \ge 1$. Then
$$\bigl|\mathrm{BB}(s)\bigr| \;\le\; \frac{\eta\,\lceil m/2\rceil}{m}.$$

*Proof sketch.* Apply Corollary 3.2 to $a_i = S_i/n_i$, legitimated by Lemmas 4.1 and 4.2, and divide by $m > 0$. $\square$

**Remark 4.4.** The block lengths $n_i$ have disappeared from the bound entirely: only their number matters. This is the precise sense in which block-balanced reweighting *does* solve the problem it was designed to solve — the imbalance $\max(A,B)$ of the majority-count law is gone — while failing to deliver consistency.

**Theorem 4.5 (Sharpness).** With singleton blocks $n_i \equiv 1$ and the extremal ladder $P$ of Definition 2.6,
$$\mathrm{BB}(P) \;=\; \frac{\eta\,\lceil m/2 \rceil}{m}.$$

*Proof sketch.* Each block mean is $P_{i,0} = \eta\,[\,i \text{ even}\,]$. An induction on $m$ (splitting on the parity of the new index) evaluates $\sum_{i<m}\eta[i \text{ even}] = \eta\lceil m/2\rceil$, since exactly $\lceil m/2\rceil$ of $0,\dots,m-1$ are even. Divide by $m$. $\square$

Thus Theorem 4.3 is exactly the worst case. Two consequences follow immediately.

**Theorem 4.6 (The conjectured rate is false).** For $\eta > 0$ and every $m \ge 5$,
$$\frac{2\eta}{m} \;<\; \mathrm{BB}(P) \;=\; \frac{\eta\lceil m/2\rceil}{m}.$$

*Proof sketch.* For $m \ge 5$ one has $\lceil m/2\rceil \ge 3 > 2$; multiply by $\eta/m > 0$. $\square$

**Theorem 4.7 (No decay).** For $\eta \ge 0$ and every $m \ge 1$,
$$\frac{\eta}{2} \;\le\; \mathrm{BB}(P) \;=\; \frac{\eta\lceil m/2\rceil}{m}.$$

*Proof sketch.* $m \le 2\lceil m/2\rceil$ for all $m$; divide by $2m$ and multiply by $\eta$. $\square$

The numerical picture:

| $m$ | worst case $/\eta$ | conjectured $2/m$ | verdict |
|---|---|---|---|
| $1$ | $1$ | $2.000$ | conjecture holds |
| $2$ | $1/2$ | $1.000$ | conjecture holds |
| $3$ | $2/3 \approx 0.667$ | $0.667$ | boundary |
| $4$ | $1/2$ | $0.500$ | boundary |
| $5$ | $3/5 = 0.600$ | $0.400$ | **conjecture false** |
| $6$ | $1/2 = 0.500$ | $0.333$ | **conjecture false** |
| $10$ | $3/5 \to 1/2$ | $0.200$ | **conjecture false** |
| $m\to\infty$ | $\to 1/2$ | $\to 0$ | **no decay** |

---

## 5. The salvage: exact amplitude restores the decay

**Theorem 5.1 (Exact-amplitude decay).** Fix any block configuration $n$ with $n_i \ge 1$, let $\eta \ge 0$ and $m \ge 1$, and take the *saturated* residual array $s_{i,j} = (-1)^i\eta$. Then
$$\bigl|\mathrm{BB}(s)\bigr| \;\le\; \frac{\eta}{m}.$$

*Proof sketch.* Each block mean is exactly $(-1)^i\eta$, independently of $n_i$: the block sum is $n_i(-1)^i\eta$ and dividing by $n_i$ restores $(-1)^i\eta$. Hence $\mathrm{BB}(s) = \frac{\eta}{m}\sum_{i<m}(-1)^i$, and the alternating partial sum $\sum_{i<m}(-1)^i$ equals $0$ for even $m$ and $1$ for odd $m$. In either case the modulus is at most $\eta/m$. $\square$

**Theorem 5.2 (The dichotomy at a fixed configuration).** Fix $\eta \ge 0$ and $m \ge 1$, and take singleton blocks. Then simultaneously
$$\mathrm{BB}(P) \;\ge\; \frac{\eta}{2}
\qquad\text{and}\qquad
\bigl|\mathrm{BB}\bigl((-1)^i\eta\bigr)\bigr| \;\le\; \frac{\eta}{m}.$$

Same number of blocks, same block lengths, same amplitude bound $\eta$, same estimator — and errors differing by a factor $m/2$ that grows without bound. The relevant question about rebound noise is therefore not "how large is it?" but "**is it saturated?**" A bound $|s| \le \eta$ leaves the adversary the freedom to silence every second block, and silence is what destroys cancellation. An equality $|s| = \eta$ removes that freedom entirely.

---

## 6. The failure is not about the weights

One might suspect that $1/n_i$ is simply the wrong weighting. It is not; nothing is.

**Theorem 6.1 (No weighting beats half).** Let $\eta \ge 0$, $m \ge 1$, and let $w_0,\dots,w_{m-1} \ge 0$ satisfy $\sum_{i<m} w_i = 1$. Then, with $P$ and $N$ the extremal ladders of Definition 2.6 (singleton blocks),
$$\frac{\eta}{2} \;\le\; \max\Bigl( \bigl|\mathrm{W}_w(P)\bigr|,\ \bigl|\mathrm{W}_w(N)\bigr| \Bigr).$$

*Proof sketch.* Compute $\mathrm{W}_w(P) = \sum_{i<m} w_i\,\eta\,[\,i\text{ even}\,] =: \Pi$ and $\mathrm{W}_w(N) = -\sum_{i<m} w_i\,\eta\,[\,i\text{ odd}\,] =: -\mathrm{N}$. Both $\Pi$ and $\mathrm{N}$ are nonnegative because the weights are. Pointwise, $w_i\eta[i\text{ even}] + w_i\eta[i\text{ odd}] = w_i\eta$, so summing and using $\sum_i w_i = 1$ gives $\Pi + \mathrm{N} = \eta$. Two nonnegative reals summing to $\eta$ cannot both be $< \eta/2$; hence $\max(\Pi, \mathrm{N}) \ge \eta/2$, which is the claim after taking absolute values. $\square$

The structure of the proof is worth isolating: the two extremal ladders *partition the total weight*. Whatever mass a weighting puts on even-indexed blocks is exactly what it loses on $P$; whatever it puts on odd-indexed blocks is exactly what it loses on $N$; and the two masses add to one. No allocation escapes.

Theorem 6.1 subsumes Theorem 4.7 (take $w_i \equiv 1/m$) and rules out length-proportional weighting, exponential discounting, trimmed weighting, and every other nonnegative scheme.

---

## 7. The barrier is information-theoretic, and the midrange attains it

Theorem 6.1 still assumes linearity in the block means. That assumption can be discarded, because the obstruction lies in the data rather than in the estimator.

**Definition 7.1 (Colliding observation).** For $L \in \mathbb{R}$, $\eta \ge 0$ define the ladder of readings
$$x_k \;=\; \begin{cases} L + \eta, & k \text{ even},\\[2pt] L, & k \text{ odd}.\end{cases}$$

**Lemma 7.2 (Two exact readings of one ladder).** For every $k$,
$$x_k \;=\; L + P_{k,0} \qquad\text{and}\qquad x_k \;=\; (L+\eta) + N_{k,0},$$
where $P$ and $N$ are the extremal ladders of Definition 2.6.

*Proof sketch.* Split on the parity of $k$ and evaluate both sides: for even $k$, $L+\eta = L+\eta = (L+\eta)+0$; for odd $k$, $L = L + 0 = (L+\eta) - \eta$. $\square$

So one and the same observation is an *exact* realisation of the floor $L$ with $(\eta,+1)$-admissible residuals, and of the floor $L+\eta$ with $(\eta,+1)$-admissible residuals. The two hypotheses are $\eta$ apart and produce literally identical data.

**Theorem 7.3 (Half-amplitude minimax barrier).** Let $E$ be *any* map from ladders of readings to real numbers — linear or not, measurable or not, deterministic. Then
$$\frac{\eta}{2} \;\le\; \max\Bigl( \bigl|E(x) - L\bigr|,\ \bigl|E(x) - (L+\eta)\bigr| \Bigr),$$
where $x$ is the colliding observation of Definition 7.1.

*Proof sketch.* Write $y = E(x)$. If $|y - L| \ge \eta/2$ we are done. Otherwise $-\eta/2 < y - L < \eta/2$, whence $(L+\eta) - y > \eta/2$, so $|y - (L+\eta)| \ge \eta/2$. $\square$

This removes the linearity hypothesis from Theorem 6.1 and identifies the true nature of the obstacle: the class of admissible worlds is not separated by the data. No procedure — no estimator, no algorithm, no amount of prior knowledge short of extra assumptions on the residuals — can achieve worst-case error below $\eta/2$.

The barrier is achieved, and by an estimator that ignores almost all the data.

**Theorem 7.4 (The midrange attains the barrier).** Let $L\in\mathbb{R}$, $\eta \ge 0$, and let $s_0,s_1,\dots$ satisfy $|s_k| \le \eta$ and $(-1)^k s_k \ge 0$ for all $k$. Then for every window size $m \ge 1$,
$$\bigl|\mathrm{MR}\bigl((L+s_k)_k,\, m\bigr) - L\bigr| \;\le\; \frac{\eta}{2}.$$

*Proof sketch.* Let $M$ and $\mu$ be the maximum and minimum of $L+s_k$ over $0 \le k \le m$. Boundedness gives $M \le L+\eta$ and $\mu \ge L-\eta$. Alternation gives $s_0 \ge 0$ and $s_1 \le 0$, and since $0,1$ are both in the window, $M \ge L+s_0 \ge L$ and $\mu \le L+s_1 \le L$. Hence
$$L \le M \le L+\eta, \qquad L-\eta \le \mu \le L,$$
so $\tfrac12(M+\mu) \in [L - \eta/2,\ L + \eta/2]$. $\square$

**Corollary 7.5 (Exact minimax rate).** The minimax worst-case error of floor estimation from a ladder with $(\eta,\epsilon)$-admissible residuals containing at least one rung of each sign is exactly $\eta/2$: no procedure achieves less (Theorem 7.3), and the midrange achieves it (Theorem 7.4), while every nonnegative weighted mean of block means fails to (Theorem 6.1).

There is a pleasant methodological moral. The optimal procedure here discards all but two data points, whereas the estimators that use all the data optimally in a Gaussian world are exactly the ones that fail. Under bounded, adversarial, sign-structured noise, *extremes carry the information and averages destroy it*: the maximum reading brackets the floor from above at distance $\le \eta$, the minimum brackets it from below at distance $\le \eta$, and averaging the brackets halves the interval. Averaging the *data* instead merely averages the adversary's chosen bias, which he has arranged not to cancel.

---

## 8. Application to the recorded ladder

**Proposition 8.1 (Floor resolution of the recorded dial).** The recorded rebound step is $0.4847 - 0.4621 = 0.0226$, and in any non-expanding affine floor model sitting above its floor a positive step of size $\delta$ forces $\eta \ge \delta$; take therefore $\eta = 0.0226$. Then for every $m \ge 1$,
$$\mathrm{BB}(P) \;\ge\; \frac{0.0226}{2} \;=\; 0.0113 .$$
No number of blocks brings the worst-case block-balanced floor estimate below $\pm 0.0113$.

*Proof sketch.* Theorem 4.7 with $\eta = 226/10000$. $\square$

Two independent confirmations converge on the same number.

* **Analytic route.** The identifiability threshold of Section 1.2 says two floors are confusable at noise $\eta$ exactly when $|1-\lambda|\,|L_1-L_2| \le 2\eta$, so resolution is $2\eta/|1-\lambda|$; with $|\lambda| \le 1$ and $\eta \ge 0.0226$ this is $\ge 0.0226$, i.e. $\pm 0.0113$. This argument knows about the contraction ratio $\lambda$.
* **Combinatorial route.** Proposition 8.1 never mentions $\lambda$, uses no model of the fade at all, and reaches the same $\pm 0.0113$.

The agreement is not a coincidence but a sign that $\eta/2$ is the intrinsic content of a rebound of size $\eta$: a rebound simultaneously *proves* that the noise is at least as large as the rebound and *caps* the achievable resolution at half that size.

**Calibration against the pre-registration.** The experiment pre-registered the floor window $[0.46,\,0.49]$, of width $0.03$. The theory certifies that no honest window can be narrower than about $0.0226$. Two structurally different point estimates — a three-point extrapolation fit giving $\approx 0.474169$, and the plain mean of the last three rungs giving $\approx 0.478267$ — both land inside the pre-registered window and agree with each other to within $0.0041$, comfortably inside the resolution. The pre-registered claim was therefore not over-precise; it was slightly conservative relative to the theoretical limit.

---

## 9. Algorithms

Three computations are needed in practice, all elementary and all cheap.

**Algorithm A: block decomposition.** Given readings $\rho_0,\dots,\rho_K$ and a floor hypothesis $L$, form residuals $s_k = \rho_k - L$ and split $0,\dots,K$ into maximal runs on which $\operatorname{sign}(s_k)$ is constant (treating $0$ as compatible with either neighbour). Output the block lengths $n_1,\dots,n_m$ and block sums. Cost: $O(K)$ time, $O(m)$ space.

**Algorithm B: the block-balanced estimate and its certified error bar.** From the block data compute $\widehat L_{\mathrm{bb}} = \frac1m\sum_i \bar\rho_i$ where $\bar\rho_i$ is the mean of block $i$, and attach the certified two-sided bar $\pm\,\eta\lceil m/2\rceil/m$. Cost: $O(K)$. The bar is *sharp*: it is attained by the extremal ladder, so it cannot be tightened without extra hypotheses.

**Algorithm C: the minimax-optimal midrange with its bar.** Return $\tfrac12(\max_k \rho_k + \min_k \rho_k)$ with the bar $\pm\eta/2$, valid as soon as the window contains at least one rung on each side of the floor. Cost: $O(K)$ time, $O(1)$ space, single pass. By Corollary 7.5 no procedure has a smaller worst-case bar.

**Algorithm D: adversarial verification.** To confirm that a proposed estimator does not beat the barrier, evaluate it on the pair $(L, P)$ and $(L+\eta, N)$ — equivalently, on the single colliding ladder $x$ — and record $\max(|E(x) - L|, |E(x)-(L+\eta)|)$. Theorem 7.3 guarantees this is at least $\eta/2$; any implementation reporting less contains a bug. Cost: $O(K)$ per estimator.

---

## 10. Discussion

**What went wrong with the conjecture.** The conjecture $2\eta/m$ silently imported the exact-amplitude intuition. Under saturation, an alternating sum of $m$ terms of size exactly $\eta$ telescopes and the mean decays like $1/m$; under mere boundedness the same sum can be $\eta\lceil m/2\rceil$, because the adversary sets the "wrong-signed" terms to zero. Sign structure alone constrains the *direction* of the error and not its *magnitude*, and cancellation needs magnitude.

**Where the block-balanced estimator does succeed.** Theorem 4.3 is not vacuous. The majority-count law gives the plain mean an error $\eta\max(A,B)/(K+1)$ which tends to $\eta$ for lopsided patterns — arbitrarily close to the trivial bound. Block balancing caps the error at $\eta\lceil m/2\rceil/m \le \eta$ with equality only at $m=1$, and removes the block lengths from the bound entirely. It buys a guaranteed factor of at most two away from $\eta/2$, uniformly over all block-length profiles. It just cannot buy consistency, because consistency is not for sale.

**Why the midrange wins.** Bounded noise is a *set-membership* (rather than distributional) uncertainty model, and in such models the optimal estimator is the Chebyshev centre of the feasible set. Here the feasible set of floors compatible with readings $\rho$ and level $\eta$, given at least one rung on each side, is essentially the interval $[\max_k \rho_k - \eta,\ \min_k \rho_k + \eta]$, whose centre is the midrange and whose half-width is $\le \eta/2$. Corollary 7.5 is the concrete instance of that general principle, made sharp by an explicit collision.

**Practical reading.** For an experimenter facing a rebound ladder, the results say three concrete things. (i) A rebound of size $\delta$ is a *proof* of noise $\eta \ge \delta$ and simultaneously caps floor resolution at $\pm\delta/2$. (ii) Collecting more rungs of the same ladder does not sharpen the floor; the only levers are reducing $\eta$ or changing the physics so that residuals saturate. (iii) If one must quote a single floor number with a defensible bar, quote the midrange with $\pm\eta/2$: it is minimax-optimal, it is a one-line computation, and no weighted average can match it.

**Scope and limitations.** The results are worst-case over the admissible class. Under a genuine stochastic model — independent, zero-mean residuals, say — averaging recovers its usual $1/\sqrt{K}$ behaviour, because independence is exactly the extra hypothesis that forbids the adversary's coordinated silencing. The theorems here should be read as delimiting what can be claimed *without* such a hypothesis. Likewise, weak alternation allows zeros; if one could certify strict amplitudes bounded *below* by $\eta' > 0$, an intermediate rate interpolating between $\eta/2$ and $\eta/m$ should be available.

---

## 11. Future directions

**1. Joint identifiability.** The identifiability threshold $|1-\lambda|\,|L_1-L_2| \le 2\eta$ treats $\lambda$ as known. The natural next object is the joint feasible set of pairs $(L,\lambda)$ compatible with a finite ladder at noise $\eta$ — presumably a curved two-dimensional region — together with its Chebyshev centre and diameter in each coordinate.

**2. A lower-amplitude hypothesis.** Assume $\eta' \le |s_k| \le \eta$ with $0 < \eta' \le \eta$. The extremal ladder $P$ becomes inadmissible, and one expects the worst case of $\mathrm{BB}$ to interpolate between $\eta/2$ (at $\eta' = 0$) and $\eta/m$-like decay (at $\eta' = \eta$). Determining the exact interpolant would complete the exact-versus-bounded dichotomy.

**3. Optimal windowing for the midrange.** Theorem 7.4 needs only one rung of each sign. In a genuine fade, early rungs are far from the floor and violate $|s_k| \le \eta$; the practical question is how to choose a trailing window that is long enough to contain both signs and short enough that the transient is negligible, and what error bar the resulting adaptive procedure certifies.

**4. Multi-dial pooling.** Several dials sharing an unknown common floor, each with its own alternating pattern, plausibly permit a genuine decay in the number of *dials* — independent collisions cannot be aligned across dials the way blocks can within one. Quantifying that gain would identify replication, rather than depth, as the lever that beats the half-amplitude barrier.

**5. Randomised procedures.** Theorem 7.3 is stated for deterministic estimators. A randomised estimator faces the same two-point collision, so the same $\eta/2$ should hold in expectation over the estimator's own randomness; making that precise, and checking whether randomisation buys anything at all in this set-membership model, is a short but worthwhile addition.

---

## 12. Conclusion

A single positive step in a fading ladder refutes the slide-to-zero story outright and pins a noise level. Once a floor model is accepted, the natural block-balanced estimator obeys the sharp law $|\widehat L_{\mathrm{bb}} - L| \le \eta\lceil m/2\rceil/m$ — block lengths irrelevant, bound attained — which never decays below $\eta/2$ and from five blocks on exceeds the conjectured $2\eta/m$. No nonnegative weighting improves on $\eta/2$, and no procedure of any kind does, because two floors $\eta$ apart generate literally the same admissible ladder. The nonlinear midrange attains $\eta/2$ exactly, so the minimax rate is settled. Decay returns only under exact amplitude, where the same estimator achieves $\eta/m$. For the recorded dial, with a measured rebound of $+0.0226$, the floor cannot be resolved better than $\pm 0.0113$ by any number of rungs — a limit reached here combinatorially, and matching the one obtained from the analytic fade model.
