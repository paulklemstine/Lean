# The Geometry of the Retention Knee: Grids, Majorization, and a Collision-Entropy Dichotomy for Top-$k$ Attention Budgets

**Author:** Aristotle

**Date:** 2026-08-23

---

## Abstract

Limited-memory deployment of attention-based sequence models rests on a single scalar: the *retention knee* $k^*(g)$, the least number of top-weighted keys whose retained attention mass reaches a gate $g$. We develop a complete, assumption-explicit theory of this quantity for an arbitrary nonnegative weight profile, and use it to audit a concrete experimental reading — a fine sweep at context $2048$, gate $g = 0.98$, over the grid $\{20,24,28,32\}$ with retained masses $0.9793,\,0.9835,\,0.9854,\,0.9885$.

Four groups of results are established. **(1) Order and grid geometry.** The knee is well posed and characterized by a fail/pass certificate; a sweep restricted to a grid $G$ never under-reports ($k^* \le k^*_G$), refining a grid can only lower the report ($G \subseteq G' \Rightarrow k^*_{G'} \le k^*_G$), an on-grid knee is reported exactly, and on an arithmetic grid of spacing $s$ the report satisfies $k^* \le k^*_G < k^* + s$. The reported "$24$" is therefore exactly the bracket $20 < k^*(0.98) \le 24$. **(2) Majorization.** If a profile is majorized in the partial-sum order (longer context spreads mass), its knee is at least as large; with the strict variant this *forces* the deployment chain $16 < 20 < 24$ rather than fitting it, and the chain is realizable by honest sorted profiles. **(3) A negative result.** For sorted rows the retention curve is discretely concave, and averaging over windows preserves concavity; the four reported numbers violate discrete concavity ($0.0019$ then $0.0031$), so they cannot be window-averaged top-$k$ masses of sorted rows. The knee conclusion survives (it uses monotonicity only), but concavity-based extrapolation from the row is unlicensed. **(4) A collision-entropy floor and its exact scope.** Cauchy–Schwarz gives $g^2 \le k\,E(k)$ with $E(k)=\sum_{i<k}w_i^2$ the attention energy ($2^{-H_2}$), hence $k^*(g) \ge g^2/E$; read backwards, a certified knee $k^* \le K$ forces $E(K) \ge g^2/K$, giving for the round-16 reading the falsifiable prediction $E(24) > 0.04$, i.e. $H_2 < \log_2 25 < 4.65$ bits. The floor is attained on plateau profiles. On the geometric family $w_i=(1-a)a^i$ the knee-to-floor ratio is bounded by $(1+\log\frac{1}{1-g})/g^2$, a *gate-only* constant (below $6$ at $g=0.98$), refuting the natural conjecture that it diverges as $a \to 1^-$. On the spike-plus-plateau family the same ratio is unbounded at fixed gate. Hence: exponential decay, not sortedness, is what makes an entropy measurement predictive of a key budget.

Combining the floor with a geometric-tail ceiling pins the knee two-sidedly, $g^2/E \le k^*(g) \le N$ whenever $1-M(k) \le Cr^k$ and $Cr^N \le 1-g$, and yields a consistency test $g^2/E \le N$ on any reported (gate, energy, tail) triple.

**Keywords:** retention knee, top-$k$ attention, collision entropy, Rényi-2, Cauchy–Schwarz, majorization, discrete concavity, grid refinement, key–value cache budget.

---

## 1. Introduction

### 1.1 The object of study

Let $w : \mathbb{N} \to \mathbb{R}$ be a nonnegative weight profile — in the motivating application, a row of an attention matrix sorted in nonincreasing order, so that $w_0 \ge w_1 \ge \cdots \ge 0$ and $\sum_i w_i = 1$. Define the **retained mass**

$$M_w(k) \;=\; \sum_{i<k} w_i ,$$

the total attention weight carried by the $k$ heaviest keys, and, for a **gate** $g \in (0,1)$, the **retention knee**

$$k^*_w(g) \;=\; \min\{\,k \in \mathbb{N} : M_w(k) \ge g\,\}$$

(with the convention $k^* = 0$ when the defining set is empty, i.e. when the gate is never met; all substantive statements carry an explicit hypothesis $\exists k,\ g \le M_w(k)$).

The knee is the scalar that limited-memory deployment tables report: "at context $C$, keep $k^*$ keys and you retain a fraction $g$ of the attention mass." It controls the size of the key–value cache, hence memory footprint, hence what runs on constrained hardware.

### 1.2 The experimental reading being audited

The concrete data set motivating this development is a fine sweep at context $2048$ on a fixed corpus, gate $g = 0.98$ exact, averaged over $12$ evaluation windows:

| $k$ | $20$ | $24$ | $28$ | $32$ |
|---|---|---|---|---|
| retained | $0.9793$ ✗ | $0.9835$ ✓ | $0.9854$ ✓ | $0.9885$ ✓ |

together with the deployment chain: knees $16$, $20$, $24$ at contexts $512$, $1024$, $2048$ respectively, all inside a $\approx 30$-key budget. A previous coarser sweep had reported $28$ at context $2048$.

Our aim is not to re-derive these numbers but to determine **exactly what they entail**, with all hypotheses explicit. This yields three kinds of statement: what is *proved* by the data (the bracket, the chain), what is *predicted* by the data (an entropy ceiling on the underlying rows), and what is *refuted* (the implicit concave model behind the four numbers).

### 1.3 Contributions

1. A well-posedness and grid-geometry theory of $k^*$ (Section 3): fail/pass certificates, bracketing, and four theorems governing the difference between the true knee and the knee a grid sweep reports, including the sharp one-step bound $k^* \le k^*_G < k^* + s$ for arithmetic grids of spacing $s$.
2. A majorization theorem (Section 4) explaining why the deployment chain is strictly monotone, plus realizability: every positive integer is the knee of an honest sorted profile, so the chain $16<20<24$ is non-vacuous.
3. A discrete-concavity obstruction (Section 5): the reported four-number row is not a window-averaged top-$k$ mass curve of sorted rows. This is a "different definition needed" result, not a falsification of the knee.
4. A Cauchy–Schwarz collision-entropy floor $k^*(g) \ge g^2/E$ with its backward reading as an entropy ceiling, sharpness on plateaus, and a two-sided sandwich with the geometric-tail budget (Section 6).
5. A complete determination of the floor's scope (Sections 7–8): bounded knee-to-floor ratio on the geometric family with a gate-only constant (refuting a natural blow-up conjecture), unbounded ratio on the spike-plus-plateau family at fixed gate.

---

## 2. Definitions and basic structure

Throughout, $w, v, u : \mathbb{N} \to \mathbb{R}$ are weight profiles and $g \in \mathbb{R}$ a gate.

**Definition 2.1 (Retained mass).** $M_w(k) = \sum_{i<k} w_i$.

**Definition 2.2 (Knee).** $k^*_w(g) = \inf\{k : g \le M_w(k)\}$, the infimum taken in $\mathbb{N}$.

**Definition 2.3 (Attention energy).** $E_w(k) = \sum_{i<k} w_i^2$. For a probability profile this is the *collision probability*, i.e. $E = 2^{-H_2}$ where $H_2$ is the Rényi-2 entropy.

**Definition 2.4 (Grid knee).** For a set $G \subseteq \mathbb{N}$ of tested key counts, $k^*_{w,G}(g) = \inf\{k : k \in G \text{ and } g \le M_w(k)\}$.

**Definition 2.5 (Window average).** For rows $W_0,\dots,W_{m-1}$, $\overline{M}(k) = \frac1m\sum_{j<m} M_{W_j}(k)$.

**Definition 2.6 (Model profiles).**
- *Plateau (step) profile*: $S_{K,c}(i) = c$ for $i < K$ and $0$ otherwise.
- *Geometric row*: $\gamma_a(i) = (1-a)a^i$ for $a \in [0,1)$; a probability profile.
- *Spike-plus-plateau row*: $\sigma_m(0) = \tfrac12$, $\sigma_m(i) = \tfrac1{4m}$ for $1 \le i \le 2m$, and $\sigma_m(i)=0$ beyond; a sorted probability profile for $m \ge 1$.

**Lemma 2.7 (Elementary properties).** If $w_i \ge 0$ for all $i$ then $M_w$ is monotone nondecreasing, and $E_w$ is monotone nondecreasing for any $w$. Moreover $M_w(k+1) = M_w(k) + w_k$, and $M_w$ is linear in $w$: $M_{au+bv} = a M_u + b M_v$.

*Proof.* Immediate from the definitions; monotonicity is summation over a larger index set with nonnegative (resp. squared, hence nonnegative) summands. $\square$

**Lemma 2.8 (Block increments of a sorted row).** If $w$ is antitone ($w$ nonincreasing) and $k \le k'$, then for every block width $d$,
$$M_w(k'+d) - M_w(k') \;\le\; M_w(k+d) - M_w(k).$$

*Proof.* Both sides are sums of $d$ terms, $\sum_{j<d} w_{k'+j}$ and $\sum_{j<d} w_{k+j}$; termwise $w_{k'+j} \le w_{k+j}$ since $k+j \le k'+j$ and $w$ is antitone. $\square$

Lemma 2.8 is the *discrete concavity* of the retention curve: equal-width blocks contribute nonincreasing amounts as one moves right.

---

## 3. Well-posedness and grid geometry

### 3.1 Certificates

**Proposition 3.1 (Pass/knee duality).** (i) If $g \le M_w(k)$ then $k^*_w(g) \le k$. (ii) If some $k$ satisfies $g \le M_w(k)$, then $g \le M_w(k^*_w(g))$. (iii) If $k < k^*_w(g)$ then $M_w(k) < g$. (iv) If $w \ge 0$ and the gate is attainable, then for all $k$: $g \le M_w(k) \iff k^*_w(g) \le k$.

*Proof.* (i) and (ii) are the defining properties of the infimum of a nonempty set of naturals. (iii) is the contrapositive of (i). (iv) combines (i) with monotonicity of $M_w$ (Lemma 2.7). $\square$

**Proposition 3.2 (Fail/pass certificate).** Let $w \ge 0$, $k \ge 1$, $M_w(k-1) < g \le M_w(k)$. Then $k^*_w(g) = k$.

*Proof.* $\le$ is Proposition 3.1(i). If $k^*_w(g) < k$ then $k^*_w(g) \le k-1$, and by Proposition 3.1(ii) plus monotonicity $g \le M_w(k-1)$, contradicting the failure. $\square$

**Theorem 3.3 (Bracketing).** Let $w \ge 0$ and $M_w(a) < g \le M_w(b)$. Then $a < k^*_w(g) \le b$.

*Proof.* As in Proposition 3.2: if $k^*_w(g) \le a$ then monotonicity forces $g \le M_w(a)$. The upper bound is Proposition 3.1(i). $\square$

**Corollary 3.4 (The round-16 reading, exactly).** Any nonnegative profile with $M_w(20) = 0.9793$ and $M_w(24) = 0.9835$ satisfies
$$20 < k^*_w(0.98) \le 24 .$$
Moreover the reported margin structure is $M(24)-0.98 = 0.0035$ and $0.98 - M(20) = 0.0007$, so the pass margin is exactly **five times** the fail deficit.

Also elementary: **the knee is monotone in the gate**, $g_1 \le g_2 \Rightarrow k^*_w(g_1) \le k^*_w(g_2)$ (whenever $g_2$ is attainable).

### 3.2 What a sweep can report

An experiment evaluates $M_w$ at finitely many $k$ and reports the least tested value that passes: $k^*_{w,G}(g)$. The following four statements govern the relation between report and truth.

**Theorem 3.5 (No under-reporting).** If some $k \in G$ passes, then $k^*_w(g) \le k^*_{w,G}(g)$.

*Proof.* The grid knee passes the gate, so Proposition 3.1(i) applies. $\square$

**Theorem 3.6 (Refinement lowers the report).** If $G \subseteq G'$ and some $k \in G$ passes, then $k^*_{w,G'}(g) \le k^*_{w,G}(g)$.

*Proof.* The minimizer for $G$ lies in $G'$ and passes, so it is a candidate for the $G'$-infimum. $\square$

**Theorem 3.7 (On-grid landing).** If $k^*_w(g) \in G$ and the gate is attainable, then $k^*_{w,G}(g) = k^*_w(g)$. Conversely, if $k^*_w(g) \notin G$ and some grid point passes, then $k^*_w(g) < k^*_{w,G}(g)$ strictly.

*Proof.* Under the hypothesis the true knee is itself an admissible grid candidate, giving $\le$; Theorem 3.5 gives $\ge$. For the converse, Theorem 3.5 gives $\le$, and equality would place the true knee in $G$. $\square$

**Theorem 3.8 (Quantitative grid bias).** Let $w \ge 0$, let $s \ge 1$, and let $G$ contain the arithmetic progression $\{a + sj : j \in \mathbb{N}\}$ with $a \le k^*_w(g)$, the gate being attainable. Then
$$k^*_w(g) \;\le\; k^*_{w,G}(g) \;<\; k^*_w(g) + s .$$

*Proof.* Choose $j$ with $k^*_w(g) - a \le sj < (k^*_w(g)-a) + s$ (ceiling division). Then $a+sj$ is a grid point $\ge k^*_w(g)$, so it passes by monotonicity, giving $k^*_{w,G}(g) \le a+sj < k^*_w(g)+s$. The left inequality is Theorem 3.5. $\square$

**Interpretation.** Theorems 3.5–3.8 dissolve the apparent conflict between a coarse sweep reporting $28$ and a fine sweep reporting $24$: neither is wrong. By Theorem 3.6 refinement can only lower the report, and by Theorem 3.8 a grid of spacing $s$ localizes the truth only to a window of width $s$. Spacing $4$ yields the bracket $20 < k^* \le 24$; spacing $16$ yields nothing better than a $16$-wide window, which is entirely consistent with a coarse reading of $28$ or $32$.

**Example 3.9 (A genuine coarse-grid over-provision).** Let $w_i = 2^{-(i+1)}$, so $M_w(k) = 1-2^{-k}$. Then $M_w(5) = 0.96875 < 0.98 \le 0.984375 = M_w(6)$, so $k^*_w(0.98) = 6$ by Proposition 3.2. On the power-of-two grid $\{2,4,8,16\}$ the sweep reports $8$ — a $33\%$ over-provision. Adjoining the single point $6$ recovers the truth exactly (Theorem 3.7).

---

## 4. Majorization: why the deployment chain climbs

Say $w$ **majorizes** $v$ in the partial-sum order if $M_v(k) \le M_w(k)$ for every $k$. For sorted probability rows this is the classical majorization preorder, and it formalizes "$v$ is a more spread-out attention distribution than $w$".

**Theorem 4.1 (Majorization $\Rightarrow$ knee monotonicity).** If $M_v(k) \le M_w(k)$ for all $k$ and the gate is attainable for $v$, then $k^*_w(g) \le k^*_v(g)$.

*Proof.* $g \le M_v(k^*_v(g)) \le M_w(k^*_v(g))$, so Proposition 3.1(i) gives $k^*_w(g) \le k^*_v(g)$. $\square$

**Theorem 4.2 (Strict version).** Let $v \ge 0$ with attainable gate. If $M_v(k^*_w(g)) < g$ — the flatter profile *still fails* at the peakier profile's knee — then $k^*_w(g) < k^*_v(g)$.

*Proof.* If not, $k^*_v(g) \le k^*_w(g)$, so monotonicity gives $g \le M_v(k^*_v(g)) \le M_v(k^*_w(g)) < g$, absurd. $\square$

**Theorem 4.3 (The deployment chain, derived).** Let $w_{512}, w_{1024}, w_{2048} \ge 0$ satisfy the measured certificates
$$M_{512}(15) < g \le M_{512}(16),\quad M_{1024}(19) < g \le M_{1024}(20),\quad M_{2048}(23) < g \le M_{2048}(24).$$
Then $k^*_{512}(g)=16$, $k^*_{1024}(g)=20$, $k^*_{2048}(g)=24$; the chain is strictly increasing; and $k^*_{2048}(g) \le 30$.

*Proof.* Three applications of Proposition 3.2, then arithmetic. $\square$

**Theorem 4.4 (The chain is forced, not fitted).** If each longer-context profile is nonnegative with attainable gate and still fails the gate at the previous context's knee, then $k^*_{512}(g) < k^*_{1024}(g) < k^*_{2048}(g)$.

*Proof.* Two applications of Theorem 4.2. $\square$

The point of Theorem 4.4 is structural: strict monotonicity of the deployment chain is not a numerical coincidence of the three measured values but a consequence of a single qualitative fact — lengthening the context spreads attention mass — together with the observation that the previous budget no longer suffices.

**Theorem 4.5 (Realizability).** For every gate $g>0$ and every $K \ge 1$ there is a nonnegative, antitone profile $w$ with $M_w(K-1) < g \le M_w(K)$ and $k^*_w(g) = K$; namely the plateau $S_{K,\,g/K}$. Consequently there exist honest sorted profiles realizing the certificates of Theorem 4.3 at $K = 16, 20, 24$ with $g = 0.98$: the chain is not vacuous.

*Proof.* $M_{S_{K,c}}(k) = c\min(k,K)$. With $c = g/K$ this equals $g\min(k,K)/K$, which is $g\frac{K-1}{K} < g$ at $k=K-1$ and exactly $g$ at $k=K$. Apply Proposition 3.2. $\square$

**Theorem 4.6 (Mixtures: averaging heads never costs keys).** Let $u,v \ge 0$ with attainable gates and $\lambda \in [0,1]$. Then
$$k^*_{\lambda u + (1-\lambda)v}(g) \;\le\; \max\{k^*_u(g),\,k^*_v(g)\}.$$

*Proof.* Put $K$ for the maximum. Monotonicity gives $g \le M_u(K)$ and $g \le M_v(K)$; linearity of mass (Lemma 2.7) gives $M_{\lambda u + (1-\lambda)v}(K) = \lambda M_u(K) + (1-\lambda)M_v(K) \ge g$. Apply Proposition 3.1(i). $\square$

This is the multi-head budgeting statement: provisioning for the worst individual head covers every convex blend of heads.

---

## 5. A concavity obstruction: what the reported row cannot be

**Theorem 5.1 (Window averaging preserves discrete concavity).** Let $W_0,\dots,W_{m-1}$ be antitone rows and $\overline{M}$ their window-averaged retention curve. Then for $k \le k'$ and any $d$,
$$\overline{M}(k'+d) - \overline{M}(k') \;\le\; \overline{M}(k+d) - \overline{M}(k).$$

*Proof.* Sum the per-row inequality of Lemma 2.8 over $j$ and divide by $m$ (the case $m=0$ being trivial). $\square$

**Theorem 5.2 (Obstruction).** There is no $m \in \mathbb{N}$ and no family of antitone rows $W_0,\dots,W_{m-1}$ whose window-averaged retention curve takes the values
$$\overline{M}(20)=0.9793,\quad \overline{M}(24)=0.9835,\quad \overline{M}(28)=0.9854,\quad \overline{M}(32)=0.9885 .$$

*Proof.* Apply Theorem 5.1 with $k=24$, $k'=28$, $d=4$: it requires
$$\overline{M}(32)-\overline{M}(28) \;\le\; \overline{M}(28)-\overline{M}(24),$$
i.e. $0.0031 \le 0.0019$, which is false. $\square$

**Discussion.** Theorem 5.2 is a *modelling* refutation, not an empirical one. What fails is the identification of the reported numbers with window-averaged top-$k$ masses of sorted rows: some step in the measurement (unsorted or re-normalized rows, differing window lengths, shard boundaries, or a different averaging convention) breaks the assumption. The consequences are sharply delimited:

- **Survives.** Every conclusion in Sections 3 and 4, since those use only monotonicity of $M$ and the fail/pass pattern. In particular the bracket $20 < k^*(0.98) \le 24$ and the strict chain stand.
- **Fails.** Any *extrapolation* premised on a concave retention curve: interpolating $k^*$ at a finer gate from the four values, estimating a knee between grid points by fitting a concave curve, or projecting a larger model's cell from a smaller model's curve.

This is a useful negative result precisely because it draws the line between the two.

---

## 6. The collision-entropy floor

Sections 3–5 are order-theoretic and can only certify sufficiency of a budget. We now obtain a *lower* bound on the knee, from an $\ell^2$ inequality rather than from any ordering hypothesis.

**Theorem 6.1 (Cauchy–Schwarz for the retention curve).** Let $g \ge 0$ and suppose $g \le M_w(k)$. Then
$$g^2 \;\le\; k \, E_w(k).$$

*Proof.* Cauchy–Schwarz on $\mathbb{R}^k$ with the all-ones vector gives $\left(\sum_{i<k}w_i\right)^2 \le k\sum_{i<k}w_i^2$, i.e. $M_w(k)^2 \le k E_w(k)$. Since $0 \le g \le M_w(k)$ we have $g^2 \le M_w(k)^2$. $\square$

**Theorem 6.2 (Entropy floor for the knee).** Let $g \ge 0$, $E > 0$, and suppose $E_w(k) \le E$ for every $k$ and the gate is attainable. Then
$$\frac{g^2}{E} \;\le\; k^*_w(g).$$

*Proof.* Apply Theorem 6.1 at $k = k^*_w(g)$, which passes the gate: $g^2 \le k^* E_w(k^*) \le k^* E$. Divide by $E>0$. $\square$

Since $E = 2^{-H_2}$ for a probability row, Theorem 6.2 reads: *a row of collision entropy at least $H_2$ needs at least $g^2 2^{H_2}$ keys to reach the gate.* Flat rows are expensive; this is the quantitative form of that intuition.

**Theorem 6.3 (Backward reading: a measured knee caps the entropy).** Let $w \ge 0$, $g \ge 0$, $K \ge 1$, the gate attainable, and suppose a sweep certifies $k^*_w(g) \le K$. Then
$$E_w(K) \;\ge\; \frac{g^2}{K}.$$

*Proof.* $g \le M_w(k^*) \le M_w(K)$ by monotonicity, so Theorem 6.1 at $k=K$ gives $g^2 \le K E_w(K)$. $\square$

**Corollary 6.4 (A falsifiable prediction from the round-16 reading).** Any nonnegative attention profile with $k^*_w(0.98) \le 24$ satisfies
$$E_w(24) \;>\; 0.04,$$
equivalently its collision entropy over those keys obeys $H_2 < \log_2 25 \approx 4.644$ bits.

*Proof.* Theorem 6.3 gives $E_w(24) \ge 0.98^2/24 = 0.9604/24 = 0.04001\overline{6} > 0.04$. $\square$

This is not a restatement of the sweep: it is a constraint on the *rows*, which the sweep never reported. A measured row flatter than $\approx 4.64$ bits of collision entropy is incompatible with a knee of $24$ at gate $0.98$.

**Theorem 6.5 (Sharpness).** The plateau profile $S_{24,\,0.98/24}$ is nonnegative and antitone, has knee exactly $24$ at gate $0.98$, and energy exactly
$$E(24) = \frac{0.98^2}{24} = 0.04001\overline{6}.$$
Hence the constant in Corollary 6.4 cannot be increased, and its hypotheses are satisfiable.

*Proof.* $E_{S_{K,c}}(k) = c^2\min(k,K)$ (the square of a step profile is a step profile), so $E_{S_{24,0.98/24}}(24) = (0.98/24)^2\cdot 24 = 0.98^2/24$. The knee is $24$ by Theorem 4.5. $\square$

**Theorem 6.6 (Peak / $\ell^\infty$ bound).** If $w_i \le M$ for all $i$ with $M>0$ and the gate is attainable, then $k^*_w(g) \ge g/M$.

*Proof.* $g \le M_w(k^*) \le k^* M$. $\square$

**Theorem 6.7 (Near-sharpness on the uniform row).** For the uniform profile over $n$ keys, $u = S_{n,1/n}$, one has $E_u(n) = 1/n$; the $\ell^2$ floor of Theorem 6.2 reads $k^*_u(g) \ge g^2 n$, while the truth is $k^*_u(g) \ge g n$. Thus the floor is lossy by exactly one factor of the gate, and no bound of this shape can be improved by more than $1/g$.

*Proof.* $E_u(n) = (1/n)^2 \cdot n = 1/n$. For the truth, $M_u(k) = \min(k,n)/n \le k/n$, so passing the gate at $k$ forces $g \le k/n$, i.e. $k \ge gn$. For the floor, $E_u(k) \le 1/n$ for all $k$, so Theorem 6.2 applies with $E=1/n$. $\square$

At $g = 0.98$ the loss factor is $1/g = 1.0204$: the floor is essentially exact at high gates on uniform rows.

**Theorem 6.8 (Two-sided sandwich).** Suppose $E_w(k) \le E$ for all $k$ with $E>0$, and the un-retained tail obeys $1 - M_w(k) \le C r^k$ for all $k$. If $N$ satisfies $C r^N \le 1-g$, then
$$\frac{g^2}{E} \;\le\; k^*_w(g) \;\le\; N .$$

*Proof.* Upper: $1 - M_w(N) \le Cr^N \le 1-g$ gives $M_w(N) \ge g$, so $k^* \le N$ by Proposition 3.1(i). Lower: Theorem 6.2, whose attainability hypothesis is supplied by the same computation. $\square$

The upper half is the geometric-tail budget: an exponentially decaying tail always yields a finite knee (given $r<1$, $C>0$, $g<1$, choose $N$ with $r^N < (1-g)/C$), and the "$\approx 30$ keys" deployment budget is the instance $N=30$ with certificate $Cr^{30} \le 1-g$.

**Corollary 6.9 (Consistency test).** Any reported triple (gate $g$, energy bound $E$, tail certificate $Cr^N \le 1-g$) must satisfy
$$\frac{g^2}{E} \;\le\; N .$$
A report violating this inequality is internally inconsistent regardless of the sweep output.

*Proof.* Chain the two halves of Theorem 6.8. $\square$

At $g=0.98$, $N=30$, the test demands $E \ge 0.9604/30 \approx 0.032$; the round-16 reading (which forces $E \ge 0.0400$ by Corollary 6.4) clears it.

---

## 7. How lossy is the floor? The geometric family

Fix $a \in (0,1)$ and consider the geometric row $\gamma_a(i) = (1-a)a^i$, a probability profile that is the canonical model of an exponentially decaying attention row.

**Lemma 7.1 (Closed-form retention).** $M_{\gamma_a}(k) = 1 - a^k$.

*Proof.* Induction on $k$: $M(k+1) = (1-a^k) + (1-a)a^k = 1-a^{k+1}$. $\square$

**Lemma 7.2 (Exact energy bound).** For $a \in [0,1)$ and every $k$,
$$E_{\gamma_a}(k) \;\le\; \mathcal{E}(a) \;:=\; \frac{1-a}{1+a},$$
with $\mathcal{E}(a) > 0$, and the bound is the exact total energy $\sum_{i\ge 0}(1-a)^2a^{2i} = (1-a)^2/(1-a^2)$.

*Proof.* $E_{\gamma_a}(k) = (1-a)^2\sum_{i<k}a^{2i} = (1-a)^2\frac{1-a^{2k}}{1-a^2} \le \frac{(1-a)^2}{1-a^2} = \frac{1-a}{1+a}$. $\square$

**Theorem 7.3 (Power certificate).** $a^N \le 1-g$ implies $k^*_{\gamma_a}(g) \le N$; conversely, if $a<1$ and $g<1$ then $a^{k^*_{\gamma_a}(g)} \le 1-g$.

*Proof.* By Lemma 7.1, $M(N) \ge g \iff a^N \le 1-g$; the gate is attainable because $a^N \to 0$. $\square$

**Theorem 7.4 (Logarithmic knee ceiling).** For $0 < a < 1$ and $0 \le g < 1$,
$$k^*_{\gamma_a}(g) \;\le\; 1 + \frac{\log\frac{1}{1-g}}{1-a}.$$

*Proof.* Write $L = \log\frac{1}{1-g} \ge 0$ and let $N = \lceil L/(1-a)\rceil$. Since $\log a \le a-1$, we have $-\log a \ge 1-a$, hence $N(-\log a) \ge N(1-a) \ge L$, i.e. $N\log a \le -L = \log(1-g)$, i.e. $a^N \le 1-g$. Theorem 7.3 gives $k^* \le N < L/(1-a) + 1$. $\square$

**Theorem 7.5 (Floor for geometric rows).** For $0 \le a < 1$, $0 \le g < 1$,
$$\frac{g^2}{\mathcal{E}(a)} \;=\; \frac{g^2(1+a)}{1-a} \;\le\; k^*_{\gamma_a}(g).$$

*Proof.* Theorem 6.2 with $E = \mathcal{E}(a)$, admissible by Lemma 7.2 and attainable by Theorem 7.3. $\square$

Both bounds diverge like $1/(1-a)$ as $a \to 1^-$: the ceiling like $L/(1-a)$, the floor like $g^2(1+a)/(1-a)$. It is therefore natural to conjecture that the ratio (truth)/(floor) also diverges — the true knee being logarithmic in the gate deficit while the floor is not. That conjecture is false, and the two divergences cancel exactly.

**Theorem 7.6 (Flatness bound; refutation of the blow-up conjecture).** For every $a \in (0,1)$ and $g \in (0,1)$,
$$k^*_{\gamma_a}(g) \;\le\; \underbrace{\frac{1+\log\frac{1}{1-g}}{g^2}}_{\text{gate only}} \cdot \frac{g^2}{\mathcal{E}(a)} .$$
Consequently there is a constant $C(g) > 0$, independent of $a$, with $k^*_{\gamma_a}(g) \le C(g)\,g^2/\mathcal{E}(a)$ for **all** geometric rows: the knee-to-floor ratio does not blow up as $a \to 1^-$.

*Proof.* With $L = \log\frac1{1-g} \ge 0$ the right-hand side simplifies to $(1+L)(1+a)/(1-a)$. By Theorem 7.4 it suffices to show
$$1 + \frac{L}{1-a} \;\le\; \frac{(1+L)(1+a)}{1-a},$$
i.e., multiplying by $1-a > 0$, $\;(1-a) + L \le (1+L)(1+a)$. Expanding the right side gives $1 + a + L + La$, and $(1-a) + L \le 1 + a + L + La$ reduces to $-a \le a + La$, true for $a \in (0,1)$, $L \ge 0$. $\square$

**Corollary 7.7 (Explicit constant at the round-16 gate).** For every $a \in (0,1)$,
$$k^*_{\gamma_a}(0.98) \;\le\; 6 \cdot \frac{0.98^2}{\mathcal{E}(a)} .$$

*Proof.* $\log\frac{1}{1-0.98} = \log 50 < 4$ (since $e^4 > 50$), so $C(0.98) = (1+\log 50)/0.9604 < 5/0.9604 < 6$. $\square$

So on the entire exponentially decaying family, a collision-entropy measurement determines the key budget up to a factor of six at a $98\%$ gate — and the true constant is $\approx 5.11$.

**Example 7.8 (Dyadic row).** For $a = 1/2$: $\mathcal{E} = (1/2)/(3/2) = 1/3$; the knee at gate $0.98$ is exactly $6$ (since $M(5) = 1-2^{-5} = 0.96875 < 0.98 \le 0.984375 = M(6)$); the floor is $0.9604 \times 3 = 2.8812$. The ratio is $6/2.8812 = 2.08$, comfortably inside the constant $6$.

---

## 8. The dichotomy: where the floor fails

Theorem 7.6 might suggest that the collision-entropy floor is tight, up to gate-dependent constants, for all sorted rows. It is not; the geometric result is a theorem *about exponential decay*.

Consider the spike-plus-plateau row $\sigma_m$: one key of weight $\tfrac12$, then $2m$ keys of weight $\tfrac1{4m}$, then zeros.

**Lemma 8.1 ($\sigma_m$ is an honest sorted probability row).** For $m \ge 1$, $\sigma_m \ge 0$ is antitone (since $\tfrac1{4m} \le \tfrac12$) and $\sum_i \sigma_m(i) = \tfrac12 + 2m\cdot\tfrac1{4m} = 1$. Its retention curve is
$$M_{\sigma_m}(k) = \tfrac12 + \tfrac{k-1}{4m} \qquad (1 \le k \le 2m+1).$$

**Theorem 8.2 (Knee grows linearly in plateau length).** For $m \ge 1$, at gate $g = \tfrac34$,
$$k^*_{\sigma_m}(3/4) \;=\; m+1 .$$

*Proof.* $M_{\sigma_m}(m+1) = \tfrac12 + \tfrac{m}{4m} = \tfrac34$ exactly, and $M_{\sigma_m}(m) = \tfrac12 + \tfrac{m-1}{4m} < \tfrac34$ since $\tfrac{m-1}{4m} < \tfrac14$. Apply Proposition 3.2. $\square$

**Theorem 8.3 (Energy is pinned).** For $m \ge 1$ and every $k$,
$$\tfrac14 \le E_{\sigma_m}(k) \quad (k \ge 1), \qquad E_{\sigma_m}(k) \;\le\; \tfrac14 + \tfrac1{8m} .$$
In particular the Rényi-2 entropy of $\sigma_m$ never exceeds $2$ bits, however long the plateau.

*Proof.* Lower: $E(1) = (1/2)^2 = 1/4$ and $E$ is monotone. Upper: the total energy is $\tfrac14 + 2m\left(\tfrac1{4m}\right)^2 = \tfrac14 + \tfrac{2m}{16m^2} = \tfrac14 + \tfrac1{8m}$, and $E$ is monotone with this as its limit. $\square$

**Theorem 8.4 (Floor is bounded while the knee is not).** For $m \ge 1$,
$$\frac{(3/4)^2}{\tfrac14 + \tfrac1{8m}} \;\le\; \frac94 ,$$
whereas $k^*_{\sigma_m}(3/4) = m+1$.

*Proof.* The left side is $\frac{9/16}{1/4 + 1/(8m)} \le \frac{9/16}{1/4} = \frac94$. $\square$

**Theorem 8.5 (Unbounded loss).** For every $R \in \mathbb{R}$ there exist a nonnegative antitone probability row $w$ and an energy bound $E>0$ with $E_w(k) \le E$ for all $k$, the gate $3/4$ attainable, and
$$R \cdot \frac{(3/4)^2}{E} \;<\; k^*_w(3/4).$$

*Proof.* Choose $m > \tfrac94|R|$ and take $w = \sigma_m$, $E = \tfrac14 + \tfrac1{8m}$. By Theorem 8.4 the floor is at most $\tfrac94$, so $R\cdot(3/4)^2/E \le |R|\cdot\tfrac94 < m < m+1 = k^*_w(3/4)$ by Theorem 8.2. $\square$

**Theorem 8.6 (Tightness dichotomy).** At the gate $g = 3/4$:

1. **Bounded on geometric rows.** There is $C>0$ with $k^*_{\gamma_a}(3/4) \le C\,\frac{(3/4)^2}{\mathcal{E}(a)}$ for every $a \in (0,1)$.
2. **Unbounded on spike rows.** For every $C$ there is a sorted probability row $w$ with energy bound $E$ such that $C\,\frac{(3/4)^2}{E} < k^*_w(3/4)$.

*Proof.* (1) is Theorem 7.6 at $g=3/4$; (2) is Theorem 8.5. $\square$

**Interpretation.** The determining structure is *exponential decay*, not sortedness. A Rényi-2 (collision) entropy measurement alone can never **certify** a key budget: it yields a lower bound that may under-estimate the truth by an arbitrarily large factor, even for a perfectly sorted probability row, even at a fixed gate. The upper half of any honest bracket must come from a decay/tail hypothesis — Theorem 6.8 — and the gate-only constant of Corollary 7.7 is a statement about the geometric family, not a universal law.

---

## 9. Algorithms

We record the three procedures implicit in the theory. Throughout, $n$ denotes the number of stored weights.

**Algorithm A (Exact knee by prefix scan).** Sort the row nonincreasingly and accumulate until the running sum reaches $g$; return the index. Correctness is Proposition 3.2 (the scan produces exactly a fail/pass certificate). Cost: $O(n\log n)$ for the sort, $O(n)$ for the scan, $O(1)$ extra memory. If the row is pre-sorted, $O(k^*)$ suffices — one need not scan past the knee.

**Algorithm B (Grid sweep with certified bracket).** Given a grid $G = \{k_1 < \cdots < k_r\}$, evaluate $M(k_j)$ (a prefix sum) until the first pass at $k_j$; report the bracket $(k_{j-1}, k_j]$. By Theorems 3.5 and 3.8 the report is never below the truth and, on an arithmetic grid of spacing $s$, never more than $s-1$ above it. Cost: $O(k_j)$ additions after sorting. Optionally bisect within the bracket for the exact knee at $O(\log s)$ further prefix evaluations.

**Algorithm C (Two-sided budget certificate).** Given a row (or an energy bound $E$ and a fitted tail $(C,r)$), report the sandwich $\lceil g^2/E\rceil \le k^* \le N$ where $N$ is least with $Cr^N \le 1-g$, and flag inconsistency if $g^2/E > N$ (Corollary 6.9). Cost: $O(n)$ for the energy, $O(\log_{1/r}\frac{C}{1-g})$ for $N$.

---

## 10. Applications

**Key–value cache provisioning.** The bracket, not the point estimate, is the deployable object. Theorem 3.8 converts a grid-spacing choice into an over-provision guarantee: sweeping with spacing $s$ costs at most $s-1$ extra keys of memory relative to the exact knee, so $s$ is a tunable trade-off between sweep cost and cache waste.

**Context scaling laws.** Theorem 4.4 says that if longer contexts spread attention (a majorization statement testable directly from partial sums, without knowing the knees) then the budget chain is strictly increasing. That converts a table of measurements into a structural prediction: no context length may be cheaper than a shorter one, and any measured non-monotonicity indicates a pipeline artifact.

**Multi-head and mixture serving.** Theorem 4.6 shows that provisioning the worst head suffices for all convex blends, so per-head budgets can be aggregated by a maximum rather than by a sum.

**Entropy-based diagnostics, with a caveat.** Corollary 6.4 turns a knee measurement into a testable claim about row entropies, and Corollary 7.7 shows that on exponentially decaying rows an entropy measurement predicts the budget within a small constant. Theorem 8.6 delimits this: entropy alone is never a certificate. A practical protocol therefore measures both the collision entropy (for the floor) and a tail fit (for the ceiling), then reports the sandwich of Theorem 6.8 and runs the consistency test of Corollary 6.9.

**Audit of published tables.** Theorem 5.2 illustrates a cheap and surprisingly powerful audit: check reported retention curves for discrete concavity. Equal-width block increments must be nonincreasing for window-averaged sorted rows; a violation localizes an error in the measurement convention without any access to the raw data.

---

## 11. Discussion

The theory separates cleanly into three registers, and it is worth being explicit about which hypotheses each requires.

*Order-theoretic (Sections 3–4).* Needs only $w \ge 0$. Everything about brackets, grids, majorization and chains lives here. These results are robust to almost any pipeline detail because they use no structure beyond monotone partial sums.

*Shape-theoretic (Section 5).* Needs antitone rows. This is where the reported four-number row breaks, and it breaks precisely the inferences that need shape (extrapolation, interpolation, projection across model sizes).

*Information-theoretic (Sections 6–8).* Needs a second moment. This is the only source of a *lower* bound on the knee, and it is exactly as strong as Cauchy–Schwarz — sharp on plateaus (Theorem 6.5), near-sharp on uniform rows (Theorem 6.7), tight up to a gate-only constant on geometric rows (Theorem 7.6), and arbitrarily lossy on spike-plus-plateau rows (Theorem 8.5).

Two conclusions deserve emphasis. First, **the disagreement between a coarse sweep and a fine sweep is not an empirical disagreement**; Theorem 3.6 says refinement can only lower the report, so a coarse $28$ and a fine $24$ are compatible readings of the same row, and Theorem 3.8 quantifies exactly how compatible. Any remaining disagreement across corpora is therefore a question about the *rows*, not about the sweeps. Second, **the natural blow-up conjecture for the entropy floor is false in the direction one expects it to be true and true in a direction one might not expect**: it does *not* blow up as an exponentially decaying row flattens (the knee and the floor diverge at the identical rate $1/(1-a)$), but it *does* blow up when the row acquires a heavy spike over a long shelf. Flatness per se is not the enemy of the floor; a mixture of scales is.

**Limitations.** The theory is about a single fixed weight profile; questions about sampling error across windows, or about the distribution of knees across rows of a layer, are outside its scope. The tail hypothesis $1-M(k)\le Cr^k$ is an assumption about the data that must be fitted and validated, not derived. And the definition of $k^*$ presupposes a fixed gate; the trade-off curve $g \mapsto k^*(g)$ is monotone but otherwise unconstrained by anything proved here beyond what shape hypotheses supply.

---

## 12. Future directions

Derived from the development above.

**What survived.** Every order-theoretic statement about the knee: monotonicity in the gate, the fail/pass certificate, the two grid inequalities, majorization monotonicity, the geometric-tail budget, and the entropy floor. The reported conclusion "the knee at context $2048$ is $24$" at gate $0.98$ survives as the bracket $20 < k^* \le 24$; nothing finer is deducible from a grid of spacing $4$.

**What failed.** The implicit model behind the reported row: the four numbers $0.9793,\,0.9835,\,0.9854,\,0.9885$ cannot be window-averaged top-$k$ masses of sorted attention rows, because their equal-width block increments increase at the last step. This is "needs a different definition", not "false": the knee statement is fine, but any extrapolation that assumes a concave retention curve — estimating $k^*$ at a finer gate by interpolation, or projecting a larger model's cell from a smaller model's curve — is unlicensed by this data.

**A refuted conjecture.** It was conjectured that on geometric rows the ratio (true knee)/($\ell^2$ floor) grows without bound as $a \to 1^-$. This is refuted: both quantities diverge at the same rate $1/(1-a)$ — the knee like $\log\frac{1}{1-g}/(1-a)$, the floor like $g^2(1+a)/(1-a)$ — so their ratio is bounded by $(1+\log\frac1{1-g})/g^2$, a function of the gate alone.

**Open directions.**

1. *Fine sweeps on further corpora.* The bracket $20 < k^* \le 24$ was obtained on one corpus. A second corpus whose coarse grid reported $32$ should be swept at spacing $4$; by Theorem 3.6 the refined report can only fall, and Theorem 3.8 says the outcome is decided within a window of four.
2. *Domain-jump corpora.* Test the majorization hypothesis directly (compare partial-sum curves across domains) rather than testing knees; Theorem 4.1 then predicts the knee ordering without further sweeps.
3. *Larger model cells.* Projecting a budget from a smaller model's curve requires shape assumptions that Theorem 5.2 shows are not available for the current data. Establishing (or refuting) concavity of the retention curve directly on raw rows is a prerequisite.
4. *A tail-exponent measurement protocol.* Because entropy alone cannot certify a budget (Theorem 8.6), a deployable pipeline must fit $(C,r)$ in $1-M(k) \le Cr^k$ and report the sandwich of Theorem 6.8. Quantifying the fit's uncertainty and propagating it to the budget is the natural next step.
5. *Interpolating families.* The geometric and spike-plus-plateau families are the two extremes of the dichotomy. A one-parameter family interpolating between them would locate the exact structural threshold at which the knee-to-floor ratio ceases to be bounded, presumably in terms of a scale-mixture or a regular-variation index of the row.
6. *Quantization of the grid.* The observed contrast between smooth bracketing at one context and exact on-grid landing at another (Theorem 3.7) suggests studying the distribution of $k^* \bmod s$ across rows — an on-grid landing rate — as a diagnostic of how informative a fixed sweep grid is for a given model.

---

## 13. Conclusion

A single number in a deployment table — "$24$ keys at context $2048$" — has been resolved into its exact logical content. It is a bracket, $20 < k^*(0.98) \le 24$, whose width is the grid spacing and no smaller. It sits in a chain $16 < 20 < 24$ that is forced by majorization rather than fitted to data. It predicts, without further measurement, that the underlying attention rows carry collision entropy below $\log_2 25 \approx 4.64$ bits. It comes with an obstruction warning that the reported curve cannot be a window-averaged sorted retention curve, so no concave extrapolation from it is licensed. And it sits inside a two-sided sandwich, floored by Cauchy–Schwarz and capped by exponential decay — a floor that is tight to a factor $\approx 5$ on exponentially decaying rows at a $98\%$ gate, and arbitrarily lossy on rows with a spike over a long shelf.

The last of these is the durable lesson: entropy bounds the budget from below, decay bounds it from above, and neither alone is the answer.
