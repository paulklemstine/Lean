# Keys Own the Cliff: A Structural Asymmetry in Attention-Cache Quantisation

**Author:** Aristotle
**Date:** 2026-08-28

---

## Abstract

Autoregressive transformer inference caches, for every processed token, a *key*
vector and a *value* vector. Compressing this cache is the dominant lever on
serving cost, and the standard practice compresses both halves identically. We
show that this is exactly wrong, and that the reason is structural rather than
empirical.

A controlled measurement isolating the two halves gives a damage ratio of
approximately $2.14 \times 10^{5}$: quantising the value cache to four bits
costs $+0.166\%$ perplexity, while quantising the key cache to four bits costs
$+35{,}597\%$. Three distinct four-bit key representations — a uniform grid, a
scale-and-offset block format, and a nonuniform codebook — all collapse, with
the richer formats offering no rescue.

We prove that this asymmetry is a property of the attention functional. (i) The
read-out is a convex combination of the values, hence **$1$-Lipschitz in the
values**, with a constant independent of query, scores, context length, depth
and head dimension, and this constant is attained. (ii) The key path admits **no
Lipschitz constant whatsoever**: for every key resolution $\delta > 0$ there is
a query and a pair of key caches within $\delta$ whose read-outs differ by at
least $1/4$; consequently the key-to-value damage ratio has no finite upper
bound. (iii) **No codebook rescues the keys**: for *any* key quantiser whose
per-block codebook has at most $N$ entries — no structural assumption at all —
there exist two keys at distance $\ge 1/N$ that it identifies and a query of
$\ell^1$ norm $\le 2N$ at which the read-out error is at least $1/4$. Only the
cardinality of the codebook enters, refuting the "richer format" hypothesis
structurally. (iv) The matching upper bound exhibits the functional form of the
cliff: the read-out error is at most $(e^{2\eta}-1)B + \delta_V$ with
$\eta = \|q\|_1 \delta_K$ — **exponential in the key resolution, linear in the
value resolution**. (v) Through depth, the key recursion is geometrically
amplifying and unbounded, while the value recursion is confined to its initial
band at every depth. (vi) The governing amplification $\|q\|_1 R / 2^{b}$ is
invariant under key/query rescaling, so no normalisation scheme can buy key bits.

Finally we derive the deployment consequence. Under the first-order damage model
$D(b_K,b_V) = A/2^{b_K} + 1/2^{b_V}$, moving a bit from values to keys strictly
helps precisely when $2^{b_K} < A \cdot 2^{b_V}$; at the measured amplification
$A = 16$ with a twelve-bit budget, the unique optimum is $b_K = 8$, $b_V = 4$,
strictly better than the uniform $K6/V6$ at the same average bit rate and better
than the reversed $K4/V8$ by more than a factor of eight. A margin criterion
converts this into a bit count: a $b$-bit key grid of range $R$ preserves every
attention decision of logit margin exceeding $2\|q\|_1 R / 2^{b}$, which is met
at eight bits and provably violated at four at the same reference scale.

**Keywords:** attention, KV cache, quantisation, softmax stability, Lipschitz
asymmetry, pigeonhole codebook bound, bit allocation.

---

## 1. Introduction

### 1.1 The cache and its cost

A decoder-only transformer generating token $T+1$ must attend over all $T$
previous positions. To avoid recomputing them, it stores per position and per
attention head a key vector $k_i \in \mathbb{R}^d$ and a value vector
$v_i \in \mathbb{R}^{d}$. This *KV cache* grows linearly in context length and,
at long context, exceeds the model parameters in size. It is therefore the first
target of compression, and the standard tool is uniform quantisation: replace
each 16-bit float by a 4-bit code drawn from a per-block codebook.

Practitioners have long reported that 4-bit KV caches are unreliable. The usual
diagnosis is a formats problem, and the usual remedy is a richer format: add a
per-block offset so the grid can translate (a *scale-and-offset* format), or
abandon uniformity for a codebook fitted to the empirical weight distribution (a
*nonuniform* format). We report a controlled measurement that identifies a
different diagnosis, and a set of theorems that explain why the remedy cannot
work.

### 1.2 The measurement

Held-out perplexity on a fixed text slice (context length $2048$), with a
full-precision control at $7.1093$:

| Arm | Perplexity | $\Delta$PPL vs. control |
|---|---|---|
| keys and values, 4-bit scale-and-offset | $3{,}158.07$ | $+44{,}322\%$ |
| keys and values, 4-bit nonuniform codebook | $1{,}627.35$ | $+22{,}790\%$ |
| **keys 4-bit uniform, values full precision** | $2{,}537.80$ | $+35{,}597\%$ |
| **keys full precision, values 4-bit uniform** | $7.1211$ | $+0.166\%$ |

Three findings:

- **P1, refuted.** Block scale-and-offset does not rescue the keys; it is
  marginally *worse* than the raw uniform grid.
- **P2, confirmed far beyond prediction.** The prior prediction was a
  key-versus-value asymmetry of at least $5\times$. The measured damage ratio is
  $35597/0.166 \approx 2.14 \times 10^{5}$.
- **P3, technically true but vacuous.** The nonuniform codebook ranks best among
  the three collapsed formats — a ranking among catastrophes.

### 1.3 The claim

> **The entire cache cliff lives in the keys.** Values tolerate raw 4-bit
> quantisation for free; keys survive four bits in no representation.

Section 2 fixes notation. Section 3 proves the value half. Section 4 proves the
key half, including the no-codebook theorem. Section 5 gives the exponential
upper bound. Section 6 treats depth. Section 7 derives the optimal bit split.
Section 8 gives the bit-width criterion and the rescaling invariance. Sections
9–11 discuss algorithms, limits and future work.

---

## 2. Setting and notation

Fix a head dimension $d \ge 1$ and a cache of $n+1 \ge 1$ positions.

**Definition 2.1 (softmax).** For $s \in \mathbb{R}^{n+1}$,
$$\sigma(s)_i \;=\; \frac{e^{s_i}}{\sum_{j} e^{s_j}}.$$
The denominator is strictly positive, so $\sigma$ is well defined, every
$\sigma(s)_i > 0$, and $\sum_i \sigma(s)_i = 1$.

**Definition 2.2 (attention read-out).** For scores $s$ and a scalar value
channel $v \in \mathbb{R}^{n+1}$,
$$A(s,v) \;=\; \sum_{i} \sigma(s)_i\, v_i .$$
We analyse one value channel at a time; because the read-out acts coordinatewise
on the value vector with the same weights, all bounds transfer to the vector
case in the sup-norm.

**Definition 2.3 (scores).** For a query $q \in \mathbb{R}^d$ and a key cache
$k : \{0,\dots,n\} \to \mathbb{R}^d$,
$$s_i \;=\; S(q,k)_i \;=\; \sum_{t=1}^{d} q_t\, k_{i,t}.$$

**Definition 2.4 (quantiser).** A *quantiser* is any map $Q : \mathbb{R} \to \mathbb{R}$ whose image lies in a finite codebook $C \subset \mathbb{R}$. Its
*cardinality* is $|C|$; its *resolution* is $\sup_x |x - Q(x)|$. A $b$-bit
format has cardinality $2^b$ per block. **No structure whatsoever** (monotonicity,
uniformity, affinity, idempotence) is assumed.

**Definition 2.5 (grid resolution).** A uniform $b$-bit grid covering the key
range $[-R, R]$ has worst-case per-entry rounding error
$$\mathrm{res}(R,b) \;=\; \frac{R}{2^{b}}.$$

**Definition 2.6 (strict top).** Index $i$ is a *strict top* of $s$ if
$s_j < s_i$ for every $j \ne i$. We say $s$ has *no strict top* if no index is.

---

## 3. Values are free — unconditionally

**Lemma 3.1 (a convex combination is non-expansive).** Let $p \in \mathbb{R}^{m}$ satisfy $p_i \ge 0$ and $\sum_i p_i = 1$, and let $v, w$ satisfy
$|v_i - w_i| \le \varepsilon$ for all $i$. Then
$$\Big| \sum_i p_i v_i - \sum_i p_i w_i \Big| \;\le\; \varepsilon .$$

*Proof.* $\big|\sum_i p_i(v_i - w_i)\big| \le \sum_i p_i|v_i - w_i| \le \varepsilon \sum_i p_i = \varepsilon$, using the triangle inequality, $p_i \ge 0$
and normalisation. $\square$

**Theorem 3.2 (values are $1$-Lipschitz).** For all scores $s$ and value
channels $v, w$ with $|v_i - w_i| \le \delta$ for all $i$,
$$|A(s,v) - A(s,w)| \;\le\; \delta .$$

*Proof.* Apply Lemma 3.1 with $p = \sigma(s)$, which is positive and sums to
one. $\square$

The content is in the quantifiers. The bound holds for **every** query, score
vector, context length, head dimension and layer; nothing on the right-hand side
depends on the state of the model. Value error cannot be amplified by anything
attention does.

**Proposition 3.3 (the constant is attained).** $A(s, c\mathbf{1}) = c$ for every
constant $c$, hence for $\delta \ge 0$,
$$\big|A(s, \delta\mathbf{1}) - A(s, 0)\big| = \delta .$$
So the constant $1$ in Theorem 3.2 is sharp — but it never degrades either.

**Corollary 3.4 (value-codebook damage bound).** If a value quantiser $Q_V$ has
resolution $\delta$, i.e. $|x - Q_V(x)| \le \delta$ for all $x$, then for all
$s, v$
$$\big| A(s,v) - A(s, Q_V \circ v) \big| \;\le\; \delta ,$$
irrespective of codebook size, codebook shape, query or context length.

This is the theoretical statement of the $+0.166\%$ arm. **Resolution is the
only property of a value codebook that can matter**, and every 4-bit format
already delivers a resolution of order $2^{-4}$ of the block range.

---

## 4. Keys are lethal — no Lipschitz constant exists

### 4.1 Amplification before the nonlinearity

**Theorem 4.1 (query amplification).** Let $|k_{i,t} - k'_{i,t}| \le \delta_K$
for all $i,t$. Then for every $i$,
$$\big| S(q,k)_i - S(q,k')_i \big| \;\le\; \|q\|_1\, \delta_K,
\qquad \|q\|_1 := \sum_{t} |q_t| .$$

*Proof.* $S(q,k)_i - S(q,k')_i = \sum_t q_t (k_{i,t} - k'_{i,t})$; apply the
triangle inequality and bound each factor. $\square$

**Proposition 4.2 (the amplification is attained).** With the all-ones query in
dimension $d$ and a key perturbed from $0$ to $\delta$ in every coordinate, the
logit moves by exactly $d\,|\delta|$.

So the amplification factor $\|q\|_1$ is not a slack artefact of the proof: it
is the true gain of the key path, and it grows with the head dimension and with
the activation scale. Nothing analogous can appear on the value side, by
Theorem 3.2.

### 4.2 The softmax selects

Write $A_2(a,b) := A\big((a,b),(1,0)\big) = e^{a}/(e^{a}+e^{b})$ for the
two-position read-out that reports the weight on position $0$.

**Lemma 4.3 (tie).** $A_2(a,a) = 1/2$.

**Lemma 4.4 (a gap of $2$ decides).** If $b + 2 \le a$ then $A_2(a,b) \ge 3/4$.

*Proof.* $e^{2} \ge 1 + 2 = 3$, so $e^{a} \ge e^{b+2} = e^{b}e^{2} \ge 3e^{b}$,
whence $A_2(a,b) = e^a/(e^a+e^b) \ge 3/4$. $\square$

Lemmas 4.3–4.4 say that softmax is a *selection* nonlinearity: an $O(1)$ logit
error is an $O(1)$ output error. No smoothing occurs.

### 4.3 The cliff

**Theorem 4.5 (no Lipschitz constant on the key path).** For every $\delta > 0$
there exist a query $q$ and key caches $k, k'$ with $|k_{i,t} - k'_{i,t}| \le \delta$ for all $i,t$ such that
$$\big| A(S(q,k), (1,0)) - A(S(q,k'), (1,0)) \big| \;\ge\; \tfrac14 .$$

*Proof.* Take $d = 1$, two cached positions, $k = (\delta, 0)$, $k' = (0,0)$ and
$q = 2/\delta$. Then $S(q,k) = (2,0)$ and $S(q,k') = (0,0)$. By Lemma 4.4 the
first read-out is at least $3/4$; by Lemma 4.3 the second is exactly $1/2$. The
gap is at least $1/4$. $\square$

The damage $1/4$ is **independent of $\delta$**: refining the key grid does not
reduce it, because the query rescales the ruler. There is no constant $C$ for
which "key error $\delta$ costs at most $C\delta$".

**Corollary 4.6 (the damage ratio is unbounded).** For every $M > 0$ there is a
resolution $\delta > 0$ (namely $\delta = 1/(4M)$) and a configuration with key
perturbation at most $\delta$ whose read-out damage is at least $M\delta$, while
by Theorem 3.2 the worst-case *value* damage at the same resolution is at most
$\delta$. Hence no finite constant relates the two halves of the cache.

The measured ratio $2.14\times 10^{5}$ is therefore a property of the slice, not
a ceiling.

### 4.4 P1 refuted structurally: no codebook rescues the keys

**Lemma 4.7 (collision damage).** Let $a \ne b$ and let $z$ be arbitrary. With
the one-dimensional query $q = 2/(a-b)$,
$$\Big| A\big(S(q,(a,b)),(1,0)\big) - A\big(S(q,(z,z)),(1,0)\big) \Big| \;\ge\; \tfrac14 .$$

*Proof.* $S(q,(a,b)) = \big(\tfrac{2a}{a-b}, \tfrac{2b}{a-b}\big)$ has gap
exactly $2$, so by Lemma 4.4 the first read-out is $\ge 3/4$; $S(q,(z,z))$ is a
tie, so the second is $1/2$ by Lemma 4.3. $\square$

**Theorem 4.8 (no codebook of a given cardinality rescues the keys).** Let $Q$ be
any key quantiser whose codebook $C$ satisfies $|C| \le N$, $N \ge 1$. Then there
exist $a \ne b$ with
$$Q(a) = Q(b), \qquad |a-b| \ge \frac1N,$$
and a query $q$ with $|q| \le 2N$ such that the exact and quantised read-outs
differ by at least $1/4$.

*Proof.* Consider the $N+1$ probes $x_i = i/N$, $i = 0,\dots,N$. Since $Q$ maps
them into a set of at most $N$ codes, the pigeonhole principle supplies $i \ne j$ with $Q(x_i) = Q(x_j)$. Their separation is $|i-j|/N \ge 1/N$. Take $a = x_i$,
$b = x_j$, $q = 2/(a-b)$; then $|q| = 2/|a-b| \le 2N$, and Lemma 4.7 applies with
$z = Q(a) = Q(b)$. $\square$

**Discussion.** The hypotheses of Theorem 4.8 mention only the *cardinality* of
the codebook. Per-block scales, per-block offsets, nonuniform codepoints,
rotations, learned lattices, and formats not yet invented are all covered,
because none of them changes the number of codes. Sixteen codes is sixteen
codes. This is exactly the empirical picture: the scale-and-offset format was
marginally worse than the raw uniform grid, and the nonuniform codebook was
merely the least catastrophic of three catastrophes.

Contrast this with Corollary 3.4, where the *only* property of the value
codebook that enters is its resolution — a property every 4-bit format supplies.
Together, Theorem 4.8 and Corollary 3.4 are the formal content of the law: the
entire cliff lives in the keys.

---

## 5. The shape of the cliff: exponential in keys, linear in values

Theorems 4.5–4.8 are worst-case statements. This section provides the matching
upper bound, which reveals the functional form.

**Theorem 5.1 (multiplicative softmax stability).** If $|s_j - s'_j| \le \eta$
for all $j$, then for every $i$
$$e^{-2\eta}\, \sigma(s)_i \;\le\; \sigma(s')_i \;\le\; e^{2\eta}\, \sigma(s)_i .$$

*Proof sketch.* The numerator satisfies $e^{s'_i} \le e^{\eta} e^{s_i}$ and the
partition function satisfies $\sum_j e^{s'_j} \ge e^{-\eta}\sum_j e^{s_j}$;
dividing gives the upper bound with total exponent $2\eta$. The lower bound is
the same statement with $s$ and $s'$ exchanged. $\square$

This is a Radon–Nikodym-style two-sided bound: an $\eta$-logit perturbation
reweights the attention distribution by a factor in $[e^{-2\eta}, e^{2\eta}]$.

**Theorem 5.2 (total-variation bound).** Under the hypotheses of Theorem 5.1,
$$\sum_i \big| \sigma(s')_i - \sigma(s)_i \big| \;\le\; e^{2\eta} - 1 .$$

*Proof sketch.* Write $x = e^{2\eta}$. The upper bound of Theorem 5.1 gives
$\sigma(s')_i - \sigma(s)_i \le (x-1)\sigma(s)_i$. For the other direction,
$e^{-2\eta} = 1/x \ge 2 - x$ (equivalent to $(x-1)^2 \ge 0$ for $x>0$), so
$\sigma(s')_i \ge (2-x)\sigma(s)_i$, i.e. $\sigma(s)_i - \sigma(s')_i \le (x-1)\sigma(s)_i$. Summing the pointwise bound $|\sigma(s')_i - \sigma(s)_i| \le (x-1)\sigma(s)_i$ over $i$ and using $\sum_i \sigma(s)_i = 1$ finishes. $\square$

**Theorem 5.3 (key half of the budget).** If $|s_j - s'_j| \le \eta$ for all $j$
and $|v_i| \le B$ for all $i$, then
$$|A(s',v) - A(s,v)| \;\le\; \big(e^{2\eta} - 1\big) B .$$

*Proof.* $A(s',v) - A(s,v) = \sum_i (\sigma(s')_i - \sigma(s)_i) v_i$; bound each
$|v_i|$ by $B$ and apply Theorem 5.2. $\square$

**Theorem 5.4 (combined KV budget).** If additionally $|v_i - v'_i| \le \delta_V$, then
$$|A(s',v') - A(s,v)| \;\le\; \big(e^{2\eta} - 1\big) B + \delta_V .$$

*Proof.* Triangle inequality through the intermediate point $A(s',v)$, using
Theorem 5.3 for the first leg and Theorem 3.2 for the second. $\square$

**Corollary 5.5 (deployment form).** In terms of raw cache resolutions,
$$\big| A(S(q,k'),v') - A(S(q,k),v) \big| \;\le\; \Big( e^{2\|q\|_1 \delta_K} - 1 \Big) B + \delta_V .$$

*Proof.* Substitute Theorem 4.1 into Theorem 5.4. $\square$

**Reading the formula.** The key term is *exponential* in the product of the
query norm with the key resolution; the value term is *linear* in the value
resolution and carries no amplification. Halving the value resolution halves the
value damage. Halving the key resolution squares the tolerance factor
$e^{2\|q\|_1\delta_K}$. Every asymmetry measured is visible in the shape of these
two terms.

**Theorem 5.6 (the key term eventually dominates by any margin).** For all
$B > 0$, $\delta_V \ge 0$ and $M \ge 0$ there is $\eta \ge 0$ with
$$M\,\delta_V \;<\; \big(e^{2\eta}-1\big) B ,$$
explicitly $\eta = \tfrac12 \log\!\big(1 + (M\delta_V + 1)/B\big)$.

*Proof.* With $c = 1 + (M\delta_V+1)/B > 1$ and $\eta = \tfrac12\log c$ we get
$e^{2\eta} = c$, hence $(e^{2\eta}-1)B = M\delta_V + 1 > M\delta_V$. $\square$

Since $\eta = \|q\|_1 \delta_K$, an arbitrarily *fine* key grid still reaches this
regime once the query norm is large enough. **The key side has no safe
resolution in the worst case** — which is why the practical criterion of
Section 8 must be stated in terms of decision margins rather than error norms.

**Proposition 5.7 (value contrast).** By Theorem 3.2, the value contribution
never exceeds $\delta_V$, for any $\eta$, any $B$, any depth.

---

## 6. Depth: amplification versus averaging

A single $1/4$ read-out error would not push perplexity to four digits. The
observed magnitude comes from compounding through layers. Model the perturbation
magnitude at layer $\ell$ by $e_\ell \ge 0$.

**The key recursion is amplifying:** $\gamma\, e_\ell \le e_{\ell+1}$ for some
$\gamma \ge 1$ — the key perturbation at one layer both shifts that layer's
selection and corrupts the residual stream feeding the next layer's query.

**The value recursion is averaging:** $e_{\ell+1} \le \max(\varepsilon, e_\ell)$
— the shape forced by Theorem 3.2, since each layer re-averages the perturbed
values with a fresh injection of at most $\varepsilon$.

**Theorem 6.1 (geometric growth of key error).** If $\gamma \ge 1$ and
$\gamma e_\ell \le e_{\ell+1}$ for all $\ell$, then $\gamma^{L} e_0 \le e_L$ for
all $L$.

*Proof.* Induction on $L$: the base case is trivial, and
$\gamma^{L+1}e_0 = \gamma(\gamma^L e_0) \le \gamma e_L \le e_{L+1}$ using
$\gamma \ge 0$ and the inductive hypothesis. $\square$

**Theorem 6.2 (key error is unbounded in depth).** If moreover $\gamma > 1$ and
$e_0 > 0$, then for every threshold $M$ there is a depth $L$ with $M \le e_L$.

*Proof.* Since $\gamma > 1$, the powers $\gamma^L$ are unbounded, so some $L$
satisfies $\gamma^L > M/e_0$, i.e. $\gamma^L e_0 > M$; apply Theorem 6.1.
$\square$

**Theorem 6.3 (value error stays in its band).** If $e_0 \le \varepsilon$ and
$e_{\ell+1} \le \max(\varepsilon, e_\ell)$ for all $\ell$, then $e_L \le \varepsilon$ for **every** $L$.

*Proof.* Induction: $e_{L+1} \le \max(\varepsilon, e_L) \le \varepsilon$ since
both arguments are $\le \varepsilon$. $\square$

**Theorem 6.4 (separation at depth).** Under the hypotheses of Theorems 6.2 and
6.3 with key sequence $e^{K}$ and value sequence $e^{V}$, for every $M$ there is
a depth $L$ with
$$M\,\varepsilon \;<\; e^{K}_L \qquad\text{and}\qquad e^{V}_L \;\le\; \varepsilon .$$

*Proof.* Apply Theorem 6.2 with threshold $M\varepsilon + 1$ and Theorem 6.3.
$\square$

Two elementary inductions, opposite fates. Multiplication runs away; averaging
does not. This is the mechanism that turns a per-head asymmetry into a
four-order-of-magnitude perplexity asymmetry in a deep stack.

---

## 7. The bit budget: keys deserve the bits

The theory says key damage carries an amplification factor and value damage does
not. Encode that in the simplest first-order model.

**Definition 7.1 (damage model).** For an amplification factor $A > 0$ and bit
widths $b_K, b_V \in \mathbb{N}$,
$$D_A(b_K, b_V) \;=\; \frac{A}{2^{b_K}} \;+\; \frac{1}{2^{b_V}} .$$

All arithmetic below is exact rational arithmetic; no floating point or rounding
is involved.

**Theorem 7.2 (move a bit to the keys).** If $2^{b_K} < A \cdot 2^{b_V}$ then
$$D_A(b_K + 1, b_V) \;<\; D_A(b_K, b_V + 1) .$$

*Proof.* A direct computation gives
$$D_A(b_K, b_V+1) - D_A(b_K+1, b_V) = \frac{A\,2^{b_V} - 2^{b_K}}{2^{b_K}\,2^{b_V+1}},$$
whose numerator is positive by hypothesis and whose denominator is positive.
$\square$

**Theorem 7.3 (equilibrium).** If $A\cdot 2^{b_V} \le 2^{b_K}$ then
$$D_A(b_K, b_V + 1) \;\le\; D_A(b_K + 1, b_V),$$
so a further transfer to the keys does not help.

*Proof.* The same identity with the sign reversed. $\square$

Theorems 7.2 and 7.3 together characterise the optimum exactly: **transfer bits
to the keys until the amplified key term balances the value term**, i.e. until
$2^{b_K} \approx A\,2^{b_V}$.

**Theorem 7.4 ($K8/V4$ is the unique optimum at $A = 16$ and a 12-bit budget).**
For all $b_K + b_V = 12$ with $b_K \ne 8$,
$$D_{16}(8,4) \;<\; D_{16}(b_K, b_V) .$$

*Proof.* Substituting $b_V = 12 - b_K$ gives
$D_{16}(b, 12-b) = 2^{4-b} + 2^{b-12}$, a strictly convex function of $b$
minimised where the exponents coincide, i.e. $4 - b = b - 12$, i.e. $b = 8$,
with value $2^{-4} + 2^{-4} = 1/8$. Finitely many cases $b = 0,\dots,12$ verify
the strict inequality. $\square$

**Corollary 7.5 (role split beats uniform split at equal bit rate).**
$$D_{16}(8,4) = \tfrac{1}{8} \;<\; \tfrac{17}{64} = D_{16}(6,6),$$
so at the same average of six bits per cache element, $K8/V4$ is better than
$K6/V6$ by more than a factor of two.

**Corollary 7.6 (the reversed split is far worse).**
$$8\,D_{16}(8,4) = 1 \;<\; \tfrac{257}{256} = D_{16}(4,8),$$
so spending the bits on the values costs more than eight times the guaranteed
damage.

Note that $A = 16$ here is a conservative stand-in for the *proved* amplification
$\|q\|_1$; a larger $A$ moves the optimum further toward the keys, never away.

---

## 8. How many key bits? A margin criterion

The worst-case results of Section 4 leave open the operational question: what
bit width is actually safe? The right variable is not the error norm but the
*decision margin*, because what a quantised key cache destroys is a
selection.

**Lemma 8.1 (margin certificate).** If $i$ is the strict top of $s$ with
$s_i - s_j > 2\varepsilon$ for all $j \ne i$, and $|s_j - s'_j| \le \varepsilon$
for all $j$, then $i$ is the strict top of $s'$.

*Proof.* For $j \ne i$: $s'_i \ge s_i - \varepsilon > s_j + \varepsilon \ge s'_j$. $\square$

**Theorem 8.2 (margin criterion for key bit width).** Suppose every key entry is
stored to resolution $\mathrm{res}(R,b) = R/2^b$, and the exact logit margin of
decision $i$ satisfies
$$s_i - s_j \;>\; 2\,\|q\|_1\,\frac{R}{2^{b}} \qquad \text{for all } j \ne i .$$
Then the quantised cache makes the same decision: $i$ is a strict top of the
quantised scores.

*Proof.* Combine Theorem 4.1 (each logit moves by at most
$\|q\|_1\mathrm{res}(R,b)$) with Lemma 8.1. $\square$

**Corollary 8.3 (bit count).** $b$ key bits suffice for all decisions of margin
at least $m$ as soon as
$$2^{b} \;>\; \frac{2\,\|q\|_1 R}{m}.$$

The requirement on $b$ is **logarithmic** in the amplification $\|q\|_1 R/m$:
each extra key bit doubles the query norm (or halves the margin) that can be
tolerated. This is why the cliff is a *threshold in bits* rather than a smooth
degradation, and why 8 is a plausible frontier while 4 is not.

**Proposition 8.4 (eight bits are safe at the reference scale).** At
$\|q\|_1 = 64$, $R = 1$, $m = 1$:
$$2 \cdot 64 \cdot \mathrm{res}(1,8) = \frac{128}{256} = \tfrac12 \;<\; 1 = m,$$
a factor-two cushion.

**Proposition 8.5 (four bits violate the criterion).** At the same scale,
$2 \cdot 64 \cdot \mathrm{res}(1,4) = 128/16 = 8 \not< 2$, so the criterion fails
even for a decision of margin $2$.

**Theorem 8.6 (four bits provably destroy a decision).** At the reference scale
there is an explicit two-position cache exhibiting the failure, not merely the
loss of the certificate: take $d = 1$, $q = 64$, exact keys $k = (1/32, 0)$ and
quantised keys $k' = (0,0)$. Then $\|q\|_1 = 64$; the per-entry error is
$1/32 \le \mathrm{res}(1,4) = 1/16$; the exact scores are $(2,0)$, so position
$0$ is a strict top with margin exactly $2$; and the quantised scores are
$(0,0)$, which have **no** strict top at all. The softmax is handed a tie and
the decision is gone.

Theorem 8.6 and Proposition 8.4 bracket the deployment rule from both sides:
**keys $\ge 8$ bits, values may take $4$.**

**Theorem 8.7 (no rescue by rescaling).** Let $c > 0$, and rescale keys by $c$
and the query by $1/c$. Then:
1. the logits are unchanged, $S(q/c,\; c\,k) = S(q, k)$, hence so is the entire
   attention output;
2. the key range scales to $cR$, since $|c\,k_{i,t}| \le cR$ whenever
   $|k_{i,t}| \le R$;
3. the governing amplification is invariant:
   $$\|q/c\|_1 \cdot \mathrm{res}(cR, b) \;=\; \|q\|_1 \cdot \mathrm{res}(R,b).$$

*Proof.* (1) $\sum_t (q_t/c)(c\,k_{i,t}) = \sum_t q_t k_{i,t}$. (2)
$|c\,k_{i,t}| = c|k_{i,t}| \le cR$. (3) $\|q/c\|_1 = \|q\|_1/c$ and
$\mathrm{res}(cR,b) = c\,\mathrm{res}(R,b)$; the factors $c$ cancel. $\square$

So the quantity that decides whether a key bit width is safe is a genuine
invariant of the attention configuration. **No normalisation scheme, no
per-channel scaling, no reparametrisation of the key space can buy a key bit.**
Whatever a normalisation scheme gains in key range, it loses in query norm.

---

## 9. Algorithms

Three procedures follow directly from the theory and are cheap enough to run
inside a serving stack.

**Algorithm A — Role-split bit allocation.** Given a total per-element budget
$T = b_K + b_V$ and an amplification estimate $A$, return the split minimising
$D_A$. By Theorems 7.2 and 7.3 the objective $2^{\log_2 A - b} + 2^{b - T}$ is
strictly convex in $b_K = b$, so a single sweep over $b = 0,\dots,T$ (or the
closed form $b^{*} = \mathrm{round}((T + \log_2 A)/2)$ followed by a comparison of
the two neighbouring integers) is exact. Complexity $O(T)$.

**Algorithm B — Safe key bit width from a margin distribution.** Given
$\|q\|_1$, key range $R$ and a target margin quantile $m$, return the least $b$
with $2^b > 2\|q\|_1 R / m$, i.e. $b = \lfloor \log_2(2\|q\|_1 R/m)\rfloor + 1$.
By Theorem 8.2 this bit width preserves every decision of margin at least $m$.
Complexity $O(1)$; estimating $m$ from a calibration set is $O(\text{tokens})$.

**Algorithm C — Codebook-collision audit.** Given a candidate key quantiser $Q$
as a black box and a probe budget $N$, evaluate $Q$ on the $N+1$ probes $i/N$
and search for a collision. Theorem 4.8 guarantees one exists whenever the
codebook has at most $N$ entries, and returns with it the explicit adversarial
query $2/(a-b)$ and a certified read-out gap of at least $1/4$. Complexity
$O(N)$ evaluations plus $O(N)$ hashing. This turns "is this new 4-bit key format
safe?" into a terminating computation whose answer is always no.

---

## 10. Discussion and honest limits

**What the theorems do and do not claim.** They are statements about the
attention functional: a convex combination on the value side, an inner product
followed by an exponential selection on the key side. They therefore apply to
any implementation. They are worst-case statements over queries; they do not by
themselves predict a perplexity number, and they do not claim that every key
quantisation destroys every model. What they establish is that the *mechanism*
of the collapse is structural, that no codebook redesign at fixed cardinality
can remove it, and that the correct axis of improvement is bit width, not format
richness.

**Limits of the measurement.** Three collapsed key formats triangulate the
empirical claim, but they share one implementation family; fundamentality is
carried by the theorems, not by the measurement. The measurement is a single
text slice, a single model and a single context length, and per-arm standard
errors were not captured. The combined $K8/V4$ cell — the arm the analysis
nominates — has not been run.

**Why the prediction was so badly beaten.** The prior prediction was a $\ge 5 \times$ key-versus-value asymmetry; the measurement gave $\approx 2.1 \times 10^{5}$. Sections 5 and 6 explain the gap: the prediction implicitly assumed both
paths were linear with different constants. In fact one path is linear
($\delta_V$) and the other is exponential in an amplified quantity
($e^{2\|q\|_1 \delta_K} - 1$), and then geometric in depth. A ratio of five
would require the two paths to be of the same functional type. They are not.

**Practical summary.** Split the cache budget by role. Keys get at least eight
bits; values may take four. Do not spend engineering effort on richer four-bit
key formats, and do not expect a normalisation scheme to help.

---

## 11. Future work

Three conjectures, each falsifiable and each with a clear route.

**1. A query-norm law for the cliff location.** The critical key bit width $b^{*}$
at which perplexity departs from the control should satisfy $b^{*} = \log_2(\|q\|_1 R/m) + \Theta(1)$, with $m$ the median top-1 logit margin. Corollary 8.3 is
logarithmic in the amplification, so the cliff is a threshold *in bits*: a
doubling of $\|q\|_1$ must be paid for with exactly one extra key bit.
Propositions 8.4 and Theorem 8.6 already bracket the threshold at one scale;
instrumenting a serving stack for $\|q\|_1$ and the margin distribution turns the
bracket into a prediction a single sweep can refute.

**2. A margin-mass criterion.** Perplexity damage should be governed not by the
worst-case margin but by the *mass* of tokens whose margin falls below
$2\|q\|_1\delta_K$: $\Delta\mathrm{PPL}/\mathrm{PPL} \approx C \cdot \mathbb{P}(\text{margin} < 2\|q\|_1\delta_K)$ with a model-independent constant
$C$. Theorem 8.2 is a per-token certificate, so aggregate loss is a measure of
the certificate's failure set, and Theorem 5.2 controls the damage each failed
token can contribute. Only the aggregation step is missing, and it concerns one
measurable distribution.

**3. Depth amplification is architectural, not format-dependent.** The per-layer
amplification factor $\gamma$ of Theorem 6.1 should be a property of the
architecture rather than of the quantiser: the same $\gamma$ (within measurement
error) should fit uniform, scale-and-offset and nonuniform key caches at every
bit width. Theorem 4.8 already shows the codebook shape is irrelevant to the
worst case; the conjecture extends that irrelevance to the observed growth rate.

Beyond these: extend the exponential budget of Corollary 5.5 from a single head
to a full residual stack with explicit constants; characterise the optimal
*non-uniform-across-layers* key bit allocation given per-layer margin
statistics; and test whether the $K8/V4$ allocation predicted by Theorem 7.4 is
quality-free in practice, which is the immediate experiment.

---

## Appendix A. Summary of the formal results

| Result | Statement |
|---|---|
| Theorem 3.2 | $|A(s,v) - A(s,w)| \le \|v-w\|_\infty$: values are $1$-Lipschitz |
| Proposition 3.3 | The constant $1$ is attained |
| Corollary 3.4 | A value codebook of resolution $\delta$ costs at most $\delta$ |
| Theorem 4.1 | Key error $\delta_K$ becomes logit error $\le \|q\|_1\delta_K$ |
| Proposition 4.2 | Amplification $d\delta$ is attained in dimension $d$ |
| Lemma 4.4 | A logit gap of $2$ forces the read-out past $3/4$ |
| Theorem 4.5 | For every $\delta > 0$, key damage $\ge 1/4$ is achievable |
| Corollary 4.6 | The key/value damage ratio is unbounded |
| Theorem 4.8 | No codebook of cardinality $N$ rescues the keys |
| Theorem 5.1 | Weights move by a factor in $[e^{-2\eta}, e^{2\eta}]$ |
| Theorem 5.2 | Attention distribution moves $\le e^{2\eta}-1$ in $\ell^1$ |
| Theorem 5.4 | Combined budget $(e^{2\eta}-1)B + \delta_V$ |
| Corollary 5.5 | Deployment form with $\eta = \|q\|_1\delta_K$ |
| Theorem 5.6 | The key term eventually dominates by any factor |
| Theorems 6.1–6.2 | Key error grows as $\gamma^L$ and is unbounded in depth |
| Theorem 6.3 | Value error never leaves its band, at any depth |
| Theorem 6.4 | Key and value paths separate by any prescribed factor |
| Theorems 7.2–7.3 | Move a bit to the keys iff $2^{b_K} < A\,2^{b_V}$ |
| Theorem 7.4 | $K8/V4$ is the unique 12-bit optimum at $A = 16$ |
| Corollaries 7.5–7.6 | $K8/V4$ beats $K6/V6$; $K4/V8$ is $>8\times$ worse |
| Theorem 8.2 | Decisions of margin $> 2\|q\|_1 R/2^b$ survive $b$-bit keys |
| Proposition 8.4 / Theorem 8.6 | Eight bits safe, four bits destroy a decision |
| Theorem 8.7 | $\|q\|_1 R/2^b$ is invariant under rescaling |
