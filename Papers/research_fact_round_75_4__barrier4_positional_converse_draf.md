# The Positional/Magnitude Stratum of the Barrier-4 Converse

### Certified silence, adaptive saturation, and a strict SET/COST dichotomy for search pipelines

**Author:** Aristotle
**Date:** 2026-08-29
**Domain:** Tropical geometry and search complexity

---

## Abstract

We develop a complete cost calculus for a class of *hint-assisted search* problems, in the min-plus ("tropical") setting used to study factor location on the divisor hyperbola $X \odot Y = N$. The calculus has three strata, and we resolve all three.

In the **fixed-window** stratum we prove that the correct law for a committed oracle protocol is the *certified-silence law*
$$S_A(\mu,P) \;=\; \frac{1}{\mu P + (1-P)(1-\mu)},$$
which strictly supersedes the previously drafted *fire-or-silent* law $1/\bigl(1-(1-\mu)P\bigr)$. We show that the certified law, the fire-or-silent law, and the naive re-scan protocol $S_B = 1/(1+\mu-P)$ lie in arithmetic progression with common gap $\mu(1-P)$: each non-certifying silence costs exactly one block measure. We prove that block-first ordering dominates unconditionally for the certified protocol but *if and only if* $\mu \le P$ for the re-scan protocol, explaining the empirical observation that every violation had $P<\mu$. We correct the cap: $S_A \le 1/\mu$ holds only in the regime $\mu \le 1/2$ (it fails at $\mu = 9/10, P=0$, where $S_A = 10 > 10/9$), the honest bound being $S_A \le 1/\min(\mu,1-\mu)$; and we exhibit a degeneracy overlooked in the draft, namely that at $\mu=1/2$ the certified cost equals $1/2$ for *every* $P$, so oracle accuracy is informationally worthless at a balanced block. No constant caps $S_A$.

In the **adaptive** stratum we prove exact saturation: the query-then-scan cost curve $\mathrm{cost}(W,k) = W/2^{k+1} + k$ is exactly the value of the $k$-fold halving process, and on dyadic windows $W=2^m$ its pinned value is $\log_2 W + \tfrac12$, the unique fixed point of $V(2W)=V(W)+1$, $V(1)=\tfrac12$. We prove the exact *net* marginal-value identity $\mathrm{cost}(k)-\mathrm{cost}(k+1) = W/2^{k+2} - 1$ and refute the drafted *gross* form by an explicit cell. We prove that the pin is **not** the argmin: on dyadic windows the curve's minimum is $\log_2 W$, attained at both offsets $-1$ and $-2$, exactly half a query below the pin. Finally we prove the two-sided bracket $\log_2 W - \tfrac12 \le \min_k \mathrm{cost}(W,k) \le \log_2 W + \tfrac12$ for all $W\ge 1$, with the upper bound attained on dyadic $W$.

In the **dichotomy** stratum we prove that pipeline speedups factor, $S(R\circ F) = S(R)\,S(F)$; that the COST-class (residue-filter) factor has $4/3$ as a *greatest element*, attained exactly at density $\theta = 1/2$; that this $4/3$ is the maximum of the diagonal slice $P=\mu=\theta$ of the fixed-window surface, welding the two strata; and that the SET-class (positional) factor obeys a Cauchy–Schwarz bits cap $S(R) \le n \le 2^k$ which is attained exactly at the uniform partition. Four measured anchors ($5.19\times$, $6.91\times$, $4.35\times$, $29.1\times$) are identified as exact rationals $400/77$, $200000/28943$, $200000/45986$, $500000/17203$; all exceed $4/3$ yet all factor legally within the positional budget. Exceeding $4/3$ is therefore **class-crossing, not cap-breaking**. Applied at the corner window $[1,\sqrt N]$ of the divisor hyperbola, where a semiprime $N=pq$ has exactly one nontrivial witness, the calculus yields the barrier: any pipeline composed of a positional stage of cost at least $1/\sqrt N$ with an arbitrary residue filter has speedup at most $\tfrac43\sqrt N$. Residue sieving buys a constant, never an exponent.

**Keywords:** tropical geometry, search complexity, certified silence, adaptive saturation, SET/COST dichotomy, residue cap, factor-location barrier.

---

## 1. Introduction

### 1.1 The question

How much is a hint worth?

Fix a search space normalized to total measure $1$, containing a single target distributed uniformly. An algorithm proceeds by *scanning*: examining a subset of relative measure $m$ costs $m$. Exhaustive scan costs $1$; we define the **speedup** of a protocol of expected cost $c$ to be $S = 1/c$.

A *hint* is any structure that lets the algorithm scan less. Two kinds of hint recur across the literature on search barriers:

* a **positional** hint, which tells you *where* the target is — it names a region and certifies membership or non-membership;
* a **magnitude** or **residue** hint, which tells you *what the target looks like* — it eliminates candidates by an arithmetic condition, such as a congruence class.

The central empirical puzzle motivating this work is that these two behave completely differently under composition, and that measured speedups in concrete pipelines routinely exceed what a residue hint could possibly deliver. This paper builds the calculus that separates them, proves the laws exactly, and locates every measured value inside the resulting map.

### 1.2 Setting: the tropical corner

The concrete instance is factor location. The divisor relation $xy = N$ is, in min-plus arithmetic, the tropical line $X \odot Y = N$; the search for a nontrivial factor of $N$ is the search for a lattice point on this curve. Every nontrivial factorization has a factor in the **corner window** $[1,\sqrt N]$, and for a semiprime the corner window is maximally sparse: it contains exactly one nontrivial witness. This makes the corner the canonical hard instance against which any hint calculus should be tested, and Section 6 does exactly that.

### 1.3 Status of the results

The three strata below were first recorded as a draft with caveats and subsequently subjected to a full independent recheck of every algebraic step and every numerical claim. That recheck was not cosmetic: it found fourteen algebra failures in the fixed-window stratum, forcing the replacement of the drafted fire-or-silent law by the certified-silence law; it found that the drafted *gross* marginal identity fails on 231 of 250 test cells and must be replaced by the *net* form; and it found the cap $S_A \le 1/\mu$ to be false outside the small-block regime. All statements in this paper are the corrected ones. Three named gaps remain open and are stated honestly in Section 8.

### 1.4 Contributions

1. **Certified silence (Theorems 2.2–2.6).** The three-law arithmetic progression, the supersession of the fire-or-silent law, the corrected cap and its sharpness, the balanced-block degeneracy, and the absence of any constant cap.
2. **Ordering criteria (Theorems 2.9–2.10).** Unconditional block-first dominance for the certified protocol; an exact iff-criterion $\mu \le P$ for the re-scan protocol.
3. **Adaptive saturation (Theorems 3.2–3.9).** The cost curve as the value of the halving process; exact dyadic saturation at $\log_2 W + \tfrac12$; the exact net marginal identity and refutation of the gross form; pin-versus-argmin separation with an exact half-query gap; the general-$W$ bracket.
4. **The dichotomy (Theorems 4.2–5.6).** Pipeline factorization; the residue cap as a greatest element with a uniqueness clause; its identification with a diagonal slice of the fixed-window surface; the Cauchy–Schwarz bits cap with an attainment-rigidity clause; exact rational anchors; and the class-crossing theorem.
5. **The corner barrier (Theorems 6.1–6.3).** The $\tfrac43\sqrt N$ ceiling for arbitrary residue-plus-position pipelines at a semiprime.

---

## 2. Stratum T1: the fixed-window oracle

### 2.1 The model

**Definition 2.1 (fixed-window instance).** A *fixed-window instance* is a pair $(\mu,P)$ with $0 \le \mu \le 1$ and $0 \le P \le 1$. The search space has measure $1$; a distinguished **block** $B$ has relative measure $\mu$; and an oracle *fires* with probability $P$, firing being a truthful announcement that the target lies in $B$. The oracle is *committed*: its policy is fixed in advance and known to the algorithm, so silence is itself an observation with a known meaning.

Three protocols, and hence three cost laws, arise.

**Definition 2.2 (the three laws).**

* **Certified silence (protocol A).** On firing, scan $B$ (cost $\mu$); on silence, the commitment certifies the target lies in the complement, so scan the complement (cost $1-\mu$):
  $$c_{\mathrm{cert}}(\mu,P) \;=\; \mu P + (1-P)(1-\mu).$$
* **Fire-or-silent (the drafted law).** On firing, scan $B$; on silence, treat silence as void and scan everything:
  $$c_{\mathrm{fos}}(\mu,P) \;=\; \mu P + (1-P)\cdot 1 \;=\; 1 - (1-\mu)P.$$
* **Block-first re-scan (protocol B).** Always scan $B$ first (cost $\mu$); if the oracle did not fire, re-scan the whole space:
  $$c_{\mathrm{rescan}}(\mu,P) \;=\; \mu + (1-P).$$

Two complement-first variants are also needed:
$$c_{\mathrm{cert}}^{\mathrm{comp}}(\mu,P) = P + (1-P)(1-\mu), \qquad c_{\mathrm{rescan}}^{\mathrm{comp}}(\mu,P) = (1-\mu) + P.$$

Speedups are $S = 1/c$ throughout; we write $S_A = 1/c_{\mathrm{cert}}$ and $S_B = 1/c_{\mathrm{rescan}} = 1/(1+\mu-P)$.

**Proposition 2.1 (positivity).** For $0<\mu<1$ and $0\le P\le 1$, $\;c_{\mathrm{cert}}(\mu,P) \ge \min(\mu,1-\mu) > 0$, so $S_A$ is well defined.

*Proof.* Write $\min(\mu,1-\mu) = \min(\mu,1-\mu)P + \min(\mu,1-\mu)(1-P)$ and bound each summand by the corresponding term of $c_{\mathrm{cert}}$. $\square$

### 2.2 The three laws are equally spaced

**Theorem 2.2 (arithmetic progression).** For all real $\mu,P$,
$$c_{\mathrm{fos}}(\mu,P) - c_{\mathrm{cert}}(\mu,P) \;=\; \mu(1-P) \;=\; c_{\mathrm{rescan}}(\mu,P) - c_{\mathrm{fos}}(\mu,P).$$

*Proof.* Both differences expand to $\mu - \mu P$ by direct algebra. $\square$

This identity is the structural heart of T1. The common gap $\mu(1-P)$ is *the block measure times the probability of silence* — literally the expected amount of block that a non-certifying protocol re-scans needlessly. The three protocols are therefore not three unrelated heuristics but three consecutive points on a line, each step discarding exactly one unit of certificate.

**Corollary 2.3 (ordering).** For $0\le\mu$ and $P \le 1$: $c_{\mathrm{cert}} \le c_{\mathrm{fos}} \le c_{\mathrm{rescan}}$, hence $S_B \le S_A$: protocol B never beats protocol A.

**Theorem 2.4 (the drafted law is superseded).** For $0<\mu<1$ and $0\le P<1$,
$$\frac{1}{c_{\mathrm{fos}}(\mu,P)} \;<\; \frac{1}{c_{\mathrm{cert}}(\mu,P)} .$$
That is, the fire-or-silent form strictly understates the achievable speedup for every nondegenerate block and imperfect oracle.

*Proof.* Theorem 2.2 gives $c_{\mathrm{cert}} < c_{\mathrm{fos}}$ strictly when $\mu>0, P<1$; invert, using Proposition 2.1. $\square$

### 2.3 The cap, its regime, and its failure

**Theorem 2.5 (cap in the small-block regime).** If $0<\mu\le \tfrac12$ and $0\le P\le 1$ then $\mu \le c_{\mathrm{cert}}(\mu,P)$, hence
$$S_A(\mu,P) \;\le\; \frac{1}{\mu}.$$
Moreover $c_{\mathrm{cert}}(\mu,1)=\mu$, so the cap is attained at a perfect oracle; and for $\mu<\tfrac12$, equality $c_{\mathrm{cert}}(\mu,P)=\mu$ forces $P=1$.

*Proof.* $c_{\mathrm{cert}}(\mu,P) - \mu = (1-P)(1-2\mu) \ge 0$ under the hypotheses, with the product vanishing only if $P=1$ or $\mu = \tfrac12$. $\square$

The displayed identity $c_{\mathrm{cert}} - \mu = (1-P)(1-2\mu)$ is worth pausing on: it exposes $\mu = 1/2$ as the exact sign change, and hence exactly where the cap must fail.

**Theorem 2.6 (sharpness: the cap is false for large blocks).** At $\mu = 9/10$, $P=0$ we have $c_{\mathrm{cert}} = 1/10$ and therefore
$$S_A \;=\; 10 \;>\; \frac{1}{\mu} \;=\; \frac{10}{9}.$$
The honest general bound is
$$S_A(\mu,P) \;\le\; \frac{1}{\min(\mu,\,1-\mu)},$$
which is Proposition 2.1 restated.

The mechanism is transparent once stated: certified silence about a *huge* block is itself powerful information, because it localizes the target inside a tiny complement. The $1/\mu$ form was an artifact of implicitly assuming that the useful certificate always points into the block.

**Theorem 2.7 (balanced-block degeneracy).** $c_{\mathrm{cert}}(\tfrac12,P) = \tfrac12$ for every $P$. Hence $S_A = 2$ identically on the balanced block: the oracle's accuracy is informationally worthless there.

*Proof.* $\tfrac12 P + (1-P)\tfrac12 = \tfrac12$. $\square$

This degeneracy is invisible in the fire-or-silent law (where $c_{\mathrm{fos}}(\tfrac12,P) = 1-\tfrac{P}{2}$ does depend on $P$) and was not named in the draft. It is the boundary case of:

**Proposition 2.8 (strict monotonicity below the balance point).** For $\mu < \tfrac12$ and $P<Q$, $\;c_{\mathrm{cert}}(\mu,Q) < c_{\mathrm{cert}}(\mu,P)$, since the difference equals $(Q-P)(1-2\mu)$.

**Theorem 2.9 (no constant cap).** For every $C \in \mathbb R$ there exist $0<\mu<\tfrac12$ and $P\in[0,1]$ with $S_A(\mu,P) > C$.

*Proof.* Take $\mu = 1/(|C|+3)$ and $P=1$; then $S_A = |C|+3 > C$. $\square$

This is the assertion that a positional resource is *unbounded*, and it is precisely what will separate the SET class from the COST class in Section 5.

### 2.4 Scan ordering

**Theorem 2.10 (unconditional block-first dominance for protocol A).** For $\mu \le 1$ and $P \ge 0$,
$$c_{\mathrm{cert}}^{\mathrm{comp}}(\mu,P) - c_{\mathrm{cert}}(\mu,P) \;=\; P(1-\mu) \;\ge\; 0,$$
strictly positive when $\mu<1$ and $P>0$. Block-first is therefore always at least as good, and strictly better whenever the oracle can fire.

**Theorem 2.11 (exact criterion for protocol B).**
$$c_{\mathrm{rescan}}(\mu,P) \;\le\; c_{\mathrm{rescan}}^{\mathrm{comp}}(\mu,P) \iff \mu \le P.$$

*Proof.* The inequality reads $\mu + 1 - P \le 1-\mu+P$, i.e. $2\mu \le 2P$. $\square$

This resolves an empirical puzzle. Exhaustive sweeps of scan orders together with insertion sweeps over window sizes $M \in \{16,33,64\}$ produced twelve configurations in which block-first *lost* under protocol B; every one had $P<\mu$. Theorem 2.11 explains this exactly: the violating region is $\{P<\mu\}$ and nothing else. A representative witness: $\mu = \tfrac12$, $P=\tfrac14$ gives $c_{\mathrm{rescan}} = \tfrac54 > \tfrac34 = c^{\mathrm{comp}}_{\mathrm{rescan}}$.

### 2.5 The uninformative point

**Definition 2.3.** The **uninformative point** of the fixed-window surface is the diagonal $P=\mu$: the oracle fires exactly as often as the block is large, so firing conveys no information beyond the block's own measure.

**Theorem 2.12.** On the diagonal the fire-or-silent law collapses to a pure residue law,
$$c_{\mathrm{fos}}(\mu,\mu) \;=\; 1-\mu(1-\mu),$$
and the certified law satisfies $S_A(\mu,\mu) \le 2$ for $0<\mu<1$, since $c_{\mathrm{cert}}(\mu,\mu) - \tfrac12 = 2(\mu-\tfrac12)^2 \ge 0$.

Theorem 2.12 is the hinge on which Section 5 turns: the residue cap $4/3$ that governs the COST class is nothing other than the extremum of this diagonal slice.

---

## 3. Stratum T2: adaptive saturation

### 3.1 The halving process

**Definition 3.1 (halving process).** On a window of width $W$ an algorithm may either stop, scanning the residual window at expected cost $W/2$, or pay $1$ for a binary query that halves the window and continue. The value of stopping after exactly $k$ queries is
$$H(W,0) = \frac W2, \qquad H(W,k+1) = 1 + H\!\left(\frac W2,\,k\right).$$

**Definition 3.2 (cost curve).** $\displaystyle \mathrm{cost}(W,k) = \frac{W}{2^{k+1}} + k.$

**Theorem 3.1 (the cost curve is not an ansatz).** $H(W,k) = \mathrm{cost}(W,k)$ for all $W \in \mathbb R$ and $k \in \mathbb N$.

*Proof.* Induction on $k$, generalizing over $W$. Base: $H(W,0) = W/2 = W/2^{1} + 0$. Step: $H(W,k+1) = 1 + \mathrm{cost}(W/2,k) = 1 + (W/2)/2^{k+1} + k = W/2^{k+2} + (k+1)$. $\square$

So every statement about $\mathrm{cost}$ is a statement about the genuine adaptive process, not about a convenient closed form imposed on it.

### 3.2 Exact saturation

**Definition 3.3 (halving recursion).** $V(1) = \tfrac12$, $V(2W) = V(W)+1$; indexed by the dyadic exponent, $V_0 = \tfrac12$ and $V_{m+1} = V_m + 1$.

**Theorem 3.2 (closed form of the recursion).** $V_m = m + \tfrac12$ for all $m \in \mathbb N$.

**Theorem 3.3 (saturation, exact).** Let $W = 2^m$ and let $k = m$ be the **pin** (the number of queries reducing the window to unit width). Then
$$\mathrm{cost}(2^m, m) \;=\; \frac{2^m}{2^{m+1}} + m \;=\; m + \frac12 \;=\; \log_2 W + \frac12,$$
and this value is exactly $V_m$.

Equivalently $H(2^m,m) = m+\tfrac12$: the halving process run to the pin realizes the saturation value.

**Theorem 3.4 (doubling costs one query).** $\mathrm{cost}(2^{m+1}, m+1) = \mathrm{cost}(2^m,m) + 1$.

Theorems 3.2–3.4 together say that $\log_2 W + \tfrac12$ is not an asymptotic estimate but the exact fixed point of the doubling recursion, valid on every dyadic width — in particular on every dyadic $W \in [2,4096]$, matching an independent dynamic-programming reproduction of the curve over that range.

### 3.3 The marginal-value identity

**Theorem 3.5 (exact net marginal identity).** For all $W$ and $k$,
$$\mathrm{cost}(W,k) - \mathrm{cost}(W,k+1) \;=\; \frac{W}{2^{k+2}} - 1.$$

*Proof.* $\bigl(W/2^{k+1} + k\bigr) - \bigl(W/2^{k+2} + k + 1\bigr) = W/2^{k+2} - 1$. $\square$

The interpretation: one further query saves the halved residual scan $W/2^{k+2}$ but is itself charged $1$. The break-even point is $W = 2^{k+2}$, i.e. $k = \log_2 W - 2$ — which, as Section 3.4 shows, is exactly the lower end of the argmin plateau.

**Theorem 3.6 (the gross form is false).** The identity without the query charge, $\mathrm{cost}(W,k)-\mathrm{cost}(W,k+1) = W/2^{k+2}$, fails already at $W=4$, $k=0$: the left side is $2 - 2 = 0$ while the right side is $1$.

The drafted theory used the gross form; on a $250$-cell grid it failed in $231$ cells, whereas the net form of Theorem 3.5 holds in all $250$. The single explicit counterexample above suffices to refute it as an identity.

### 3.4 The pin is not the argmin

**Theorem 3.7 (lower envelope).** For all $m,k \in \mathbb N$, $\;\mathrm{cost}(2^m,k) \ge m.$

*Proof.* If $k \ge m$ the query term alone gives $k \ge m$ plus a positive residual. If $k<m$, write $m = k+1+d$ with $d \ge 0$; then $2^m/2^{k+1} = 2^d$ and $\mathrm{cost} = 2^d + k \ge (d+1) + k = m$, using $2^d \ge d+1$. $\square$

**Theorem 3.8 (the plateau).** $\mathrm{cost}(2^{m+1},m) = m+1$ and $\mathrm{cost}(2^{m+2},m) = m+2$. Hence on a dyadic window $W=2^M$ the minimum value $M$ of the cost curve is attained at $k=M-1$ and $k=M-2$, and only there.

*Proof.* $2^{m+1}/2^{m+1} = 1$ gives the first; $2^{m+2}/2^{m+1}=2$ gives the second. Both equal the lower envelope of Theorem 3.7, so both are minimizers. Strict increase away from the plateau follows from Theorem 3.5: the marginal $W/2^{k+2}-1$ is positive for $k < M-2$ and negative for $k>M-2$. $\square$

**Theorem 3.9 (pin–argmin separation).** For every $m$,
$$\mathrm{cost}(2^{m+1},m+1) - \mathrm{cost}(2^{m+1},m) \;=\; \frac12 .$$
The pinned value $\log_2 W + \tfrac12$ exceeds the minimum $\log_2 W$ by exactly half a query, on every dyadic window.

**Remark 3.1 (three distinct $k$'s).** Three stopping conventions must be kept apart:

1. the **pin** $k_{\mathrm{pin}} = \log_2 W$, where the residual window reaches unit width, of value $\log_2 W + \tfrac12$;
2. the **argmin** $k_{\mathrm{opt}} \in \{\log_2 W - 2, \log_2 W - 1\}$, of value $\log_2 W$;
3. the **economic optimum**, defined by an application's own marginal accounting, which lands roughly one query beyond the argmin.

A census of pinned values at scale confirms the offsets: at $W=2^{19}$ the pinned cost is $19.5$ and at $W=2^{20}$ it is $20.5$, while the argmin offsets are $\{-2,-1\}$ relative to $k_{\mathrm{pin}}$. Conflating conventions shifts reported optima by $1$ or by $\tfrac12$ — precisely the magnitude of the effects the theory measures. Naming these three unambiguously is one of the open items in Section 8.

### 3.5 The general-$W$ bracket

For non-dyadic widths the closed form remains correct to within half a query, in both directions.

**Lemma 3.10.** For all $u>0$, $\;\log_2 u \le u - \tfrac12$.

*Proof sketch.* Put $u = s^2$ with $s=\sqrt u>0$. From $\log s \le s-1$ we get $\log u = 2\log s \le 2(s-1)$, so it suffices that $2(s-1) \le (s^2-\tfrac12)\log 2$, i.e. that the quadratic
$$Q(s) \;=\; (\log 2)\,s^2 - 2s + \Bigl(2 - \tfrac{\log 2}{2}\Bigr)$$
is nonnegative for all $s$. Its discriminant is $4 - 4\log 2\,(2 - \tfrac{\log 2}{2}) = 4 - 8\log 2 + 2(\log 2)^2 \approx -0.584 < 0$, using $0.6931471803 < \log 2 < 0.6931471808$; since the leading coefficient is positive, $Q>0$ everywhere. Dividing by $\log 2$ gives $\log_2 u \le u - \tfrac12$. $\square$

**Theorem 3.11 (lower bracket).** For $W>0$ and every $k$, $\;\mathrm{cost}(W,k) \ge \log_2 W - \tfrac12.$

*Proof.* Set $u = W/2^{k+1} > 0$, so $\log_2 W = \log_2 u + (k+1)$ and $\mathrm{cost}(W,k) = u + k$. By Lemma 3.10, $\log_2 u \le u - \tfrac12$, hence $\log_2 W - \tfrac12 = \log_2 u + k + \tfrac12 \le u + k = \mathrm{cost}(W,k)$. $\square$

**Theorem 3.12 (upper bracket at the dyadic scale).** If $2^k \le W < 2^{k+1}$ then $\;\mathrm{cost}(W,k) \le \log_2 W + \tfrac12.$

*Proof sketch.* Write $t = W/2^k \in [1,2)$, so $\mathrm{cost}(W,k) = t/2 + k$ and $\log_2 W = \log_2 t + k$. The claim reduces to $t/2 - \tfrac12 \le \log_2 t$ on $[1,2)$. From $\log t \ge 1 - 1/t = (t-1)/t$ it suffices that $(\tfrac t2-\tfrac12)\log 2 \le (t-1)/t$, i.e. $t(t-1)\log 2 \le 2(t-1)$, which holds because $(t-1)\ge 0$ and $t\log 2 < 2\log 2 < 2$ on the range. $\square$

**Theorem 3.13 (T2 bracket).** For every $W \ge 1$:
$$\forall k,\ \ \mathrm{cost}(W,k) \ge \log_2 W - \tfrac12, \qquad \exists k,\ \ \mathrm{cost}(W,k) \le \log_2 W + \tfrac12 .$$
The upper bound is attained with equality exactly on dyadic $W$, at the pin.

*Proof.* Combine Theorems 3.11 and 3.12 with the existence of a unique dyadic scale $k$ with $2^k \le W < 2^{k+1}$ for $W \ge 1$. $\square$

**Remark 3.2 (undercut census).** A census of the general-width variant of the optimized curve, taken over widths up to $L = 4096$, records the closed form $\log_2 W + \tfrac12$ as an upper bound whose deepest recorded undercut is $-0.499349$, attained at $L = 3073$ — never crossing $-\tfrac12$. Theorem 3.11 proves that $-\tfrac12$ can never be crossed at all, and the near-attainment shows the bracket is essentially tight. The associated cost-offset bracket, drafted loosely, is corrected to $[0.415,\,0.5011]$.

---

## 4. Pipelines and the two classes

**Definition 4.1 (pipeline).** A pipeline $R\circ F$ applies a **filter** $F$ of relative cost $c_F$ (the expected fraction of the space that survives and must be handled), then a **positional stage** $R$ of relative cost $c_R$ on what survives. Total cost $c_{R\circ F} = c_R\, c_F$.

**Theorem 4.1 (speedups factor).** For nonzero $c_R,c_F$,
$$S(R\circ F) \;=\; S(R)\cdot S(F).$$

*Proof.* $1/(c_Rc_F) = (1/c_R)(1/c_F)$. $\square$

This is Conjecture D's factorization clause, and it is the reason a *dichotomy* is meaningful: a pipeline's speedup is the product of a COST-class factor and a SET-class factor, and one may cap each separately.

**Definition 4.2 (the two classes).**

* A **COST-class action** is one that eliminates candidates by an intrinsic arithmetic predicate — e.g. a residue filter selecting a congruence class of density $\theta$. Its speedup is $S(F)$.
* A **SET-class action** is one that localizes the target positionally — e.g. a certified partition of the space into named classes. Its speedup is $S(R)$.

---

## 5. The residue cap $4/3$ and the bits cap

### 5.1 The COST class is capped at $4/3$

**Definition 5.1 (residue cost).** A residue filter of density $\theta$ costs
$$c_{\mathrm{res}}(\theta) \;=\; 1 - \theta(1-\theta),$$
i.e. with probability $\theta$ the target lies in the selected class and only that class (measure $\theta$) is scanned, otherwise the whole space is scanned.

**Theorem 5.1 (T1 $\leftrightarrow$ Conjecture D identity).** $c_{\mathrm{res}}(\theta) = c_{\mathrm{fos}}(\theta,\theta)$: the residue law is exactly the fire-or-silent law evaluated at its uninformative point.

Thus the residue cap is not an independent constant of the theory. It is the extremum of the *diagonal slice* $P=\mu$ of the two-parameter fixed-window surface — a fact with real consequences for how the barrier map should be organized (Section 8).

**Theorem 5.2 (residue cap).** $c_{\mathrm{res}}(\theta) \ge \tfrac34$ for all real $\theta$, hence
$$S(F) \;=\; \frac{1}{c_{\mathrm{res}}(\theta)} \;\le\; \frac43 .$$

*Proof.* $c_{\mathrm{res}}(\theta) - \tfrac34 = (\theta-\tfrac12)^2 \ge 0$. $\square$

**Theorem 5.3 (attainment and uniqueness).** $S(F) = \tfrac43$ if and only if $\theta = \tfrac12$. Consequently $\tfrac43$ is a **greatest element** of $\{\,1/c_{\mathrm{res}}(\theta) : \theta\in\mathbb R\,\}$, not merely a supremum.

*Proof.* Equality in Theorem 5.2 forces $(\theta - \tfrac12)^2 = 0$. $\square$

A COST-class action therefore *cannot* buy more than a factor $4/3$, ever, under any density, and it buys exactly $4/3$ only at perfect balance.

### 5.2 The SET class and the bits cap

**Definition 5.2 (certified partition).** A positional stage partitions the space into classes of relative measures $m_1,\dots,m_n$ with $\sum_i m_i = 1$ and certifies which class contains the target. Its expected cost is $\sum_i m_i^2$ (with probability $m_i$ the target is in class $i$, whose scan costs $m_i$).

**Theorem 5.4 (Cauchy–Schwarz bits cap).** For any such partition, $\;\sum_i m_i^2 \ge 1/n$, hence
$$S(R) \;\le\; n .$$
If the positional certificate carries $k$ bits, so $n \le 2^k$, then $S(R) \le 2^k$.

*Proof.* $\bigl(\sum_i m_i\bigr)^2 \le n \sum_i m_i^2$ by Cauchy–Schwarz; the left side is $1$. $\square$

**Theorem 5.5 (sharpness).** The uniform partition into $n$ classes has cost $\sum_i n^{-2} = 1/n$ and speedup exactly $n$.

**Theorem 5.6 (rigidity).** If $\sum_i m_i^2 = 1/n$ then $m_i = 1/n$ for all $i$: only the uniform partition attains the cap, and any imbalance strictly costs speedup.

*Proof.* Expand $\sum_i (m_i - 1/n)^2 = \sum_i m_i^2 - \tfrac2n\sum_i m_i + n\cdot \tfrac1{n^2} = \tfrac1n - \tfrac2n + \tfrac1n = 0$; a sum of squares vanishes only termwise. $\square$

### 5.3 The dichotomy is strict

**Theorem 5.7 (strict SET/COST dichotomy).** For every constant $C$: every residue filter satisfies $S(F) \le \tfrac43$, while there exist $0<\mu<\tfrac12$ and $P\in[0,1]$ with $S_A(\mu,P) > C$.

*Proof.* Theorem 5.2 and Theorem 2.9. $\square$

The two classes are genuinely different resources: one is bounded by an absolute constant, the other by nothing.

### 5.4 The measured anchors

Four empirical anchors, reported as $5.19\times$, $6.91\times$, $4.35\times$ and $29.1\times$, are exact rational values of the fire-or-silent law:

| anchor | $(\mu, P)$ | exact speedup | decimal |
|---|---|---|---|
| $5.19\times$ | $(0.05,\ 0.85)$ | $400/77$ | $5.194805\ldots$ |
| $6.91\times$ | $(0.05,\ 0.9003)$ | $200000/28943$ | $6.910133\ldots$ |
| $4.35\times$ | $(0.05,\ 0.8106)$ | $200000/45986$ | $4.349150\ldots$ |
| $29.1\times$ | $(0.02,\ 0.9853)$ | $500000/17203$ | $29.064698\ldots$ |

Each exceeds $4/3$. Does this refute the residue cap? No.

**Theorem 5.8 (positional necessity).** If $S = S(R)\,S(F)$ with $S(F) \le \tfrac43$ and $S(R)\ge 0$, then
$$S(R) \;\ge\; \tfrac34\,S .$$
If moreover the positional budget $S(R) \le 1/\mu$ holds and $S>0$, then $\mu \le 4/(3S)$.

*Proof.* $S = S(R)S(F) \le \tfrac43 S(R)$. The second clause follows by combining with $S(R)\le 1/\mu$. $\square$

**Theorem 5.9 (class crossing).** Let $S>0$ and $\mu>0$ satisfy the budget condition $\tfrac34 S \le 1/\mu$. Then $S$ factors as $S = S(R)\cdot S(F)$ with $S(F) = 4/3$ attained by the balanced residue filter $\theta=\tfrac12$ and $S(R) = \tfrac34 S \le 1/\mu$ legal. Hence exceeding $4/3$ is never cap-breaking.

*Proof.* Take $S(R) = \tfrac34 S$, $S(F) = \tfrac43$. $\square$

**Corollary 5.10 (all four anchors are legal).** Each anchor satisfies $\tfrac34 S \le 1/\mu$ with its own $\mu$: for $\mu = 1/20$, $\tfrac34 \cdot \tfrac{400}{77} = \tfrac{300}{77} \approx 3.90 \le 20$, and similarly $\approx 5.18, 3.26 \le 20$; for $\mu = 1/50$, $\tfrac34\cdot\tfrac{500000}{17203} \approx 21.80 \le 50$. All four are realized by a legal pair with the COST factor exactly at its cap.

**Theorem 5.11 (no anchor is residue-realizable).** For every $\theta$, $\;1/c_{\mathrm{res}}(\theta) < 400/77$. The COST class alone cannot produce any measured anchor.

*Proof.* $1/c_{\mathrm{res}}(\theta) \le 4/3 < 400/77$. $\square$

**Interpretation.** A measurement of $5.19\times$ is not a residue filter doing the impossible; it is a *positional* stage doing something perfectly ordinary, optionally multiplied by a residue filter contributing at most $4/3$. The apparent violation is **class crossing**: the observable has moved off the uninformative diagonal, where the residue cap lives, onto the two-parameter surface, where no constant cap exists. Since the diagonal identity of Theorem 5.1 places both objects on one surface, the barrier map is internally consistent. Additionally, the master law of the general theory, evaluated at the uninformative point, coincides exactly with the specialized residue formula — an identity check that the two independent derivations agree.

---

## 6. The corner barrier for factor location

We now apply the calculus at the tropical corner.

**Setting.** To factor $N$, search the divisor hyperbola $xy=N$ — the tropical line $X\odot Y = N$ — for a lattice point. Every nontrivial factorization has a factor in the **corner window** $[1,\sqrt N]$, which carries relative measure $\mu = 1/\sqrt N$ in the residue range.

**Theorem 6.1 (uniqueness of the corner witness).** Let $N = pq$ with $p<q$ prime. Then
$$\bigl\{\,d : d \mid N,\ d^2 \le N \,\bigr\}\setminus\{1\} \;=\; \{p\}.$$
The corner window of a semiprime contains exactly one nontrivial witness.

**Theorem 6.2 (residue sieving cannot break $\sqrt N$).** Let $N \ge 1$. Suppose a pipeline consists of a positional stage of cost $c_R \ge 1/\sqrt N$ (it cannot beat the corner measure) composed with *any* residue filter, of cost $c_F \ge \tfrac34$ (the COST-class cap). Then
$$S(R\circ F) \;=\; \frac{1}{c_Rc_F} \;\le\; \frac43\,\sqrt N .$$

*Proof.* $c_Rc_F \ge \tfrac{3}{4\sqrt N}$; invert. $\square$

**Theorem 6.3 (corner-window cap).** For $N \ge 4$ (so $\mu = 1/\sqrt N \le \tfrac12$, placing us in the valid regime of Theorem 2.5) and any $P\in[0,1]$,
$$S_A\!\left(\tfrac1{\sqrt N},P\right) \;\le\; \sqrt N,$$
with equality exactly at a perfect oracle, where $c_{\mathrm{cert}} = 1/\sqrt N$.

**Theorem 6.4 (semiprime corner barrier).** For $N = pq$ with $p<q$ prime, the corner window contains exactly one nontrivial witness, and every pipeline of the form described in Theorem 6.2 has speedup at most $\tfrac43\sqrt{pq}$.

**Discussion.** The content of Theorem 6.4 is a clean separation of what sieving can and cannot do. Residue sieving — the entire apparatus of congruence-based candidate elimination — is a COST-class action, and Theorem 5.2 caps every COST-class action at $4/3$. It therefore contributes a *constant factor* on top of the positional $\sqrt N$ and cannot alter the exponent. To move the exponent one needs a genuinely SET-class resource with unbounded speedup — which, by Theorem 2.9, is not forbidden in the abstract, but requires an actual positional certificate of many bits, i.e. real information about *where* the factor is. Note also that Theorem 6.3 uses the small-block form of the cap legitimately: the corner measure $1/\sqrt N \le \tfrac12$ for $N\ge4$, so the correction of Theorem 2.6 does not weaken the barrier.

---

## 7. Algorithmic content

The theory is constructive and yields three algorithms.

**Algorithm A (optimal protocol selection).** Given $(\mu,P)$: compute the three costs $c_{\mathrm{cert}}, c_{\mathrm{fos}}, c_{\mathrm{rescan}}$; by Theorem 2.2 they are equally spaced with gap $\mu(1-P)$, so protocol A is optimal, and its scan order should be block-first by Theorem 2.10. If only a re-scan protocol is available, choose block-first iff $\mu \le P$ (Theorem 2.11). Cost: $O(1)$ arithmetic operations.

**Algorithm B (adaptive stopping).** Given $W$: the pin is $k_{\mathrm{pin}} = \lceil \log_2 W\rceil$ with value $\mathrm{cost}(W,k_{\mathrm{pin}})$; the argmin is the largest $k$ with positive net marginal, i.e. $W/2^{k+2} \ge 1$, giving $k_{\mathrm{opt}} = \lfloor \log_2 W\rfloor - 2$ (with the plateau extending to $-1$ on dyadic $W$). Emitting all three conventions explicitly (pin, argmin, economic) avoids the conflation identified in Remark 3.1. Cost: $O(\log W)$ if the curve is tabulated, $O(1)$ from the closed forms.

**Algorithm C (barrier audit of a measured speedup).** Given a measured $S$ and a positional measure $\mu$: verify $\tfrac34 S \le 1/\mu$; if so, output the certificate $(S(R),S(F)) = (\tfrac34 S, \tfrac43)$ and classify the measurement as *class-crossing*. If $\tfrac34 S > 1/\mu$, the measurement is inconsistent with the map and either $\mu$ is misreported or a new resource is present. Cost: $O(1)$.

---

## 8. Open problems

Three named gaps remain load-bearing.

**L4 — the stratum measure.** Define a quantity $\Delta(\pi,R)$ measuring the cost of a scan order $\pi$ relative to a positional stage $R$, so that the positional/magnitude stratification becomes quantitative rather than qualitative. Without it, "how positional is this algorithm?" has no numerical answer.

**L7 — extremality of $\sqrt{\cdot}$-descending order.** Is the order that scans candidates descending from $\sqrt N$ extremal among all orders computable from $N$? One expects a Siegel-type ineffectivity: a proof that no computable order does better, without any effective description of which orders are excluded.

**L8 — canonical $k$-naming.** Fix, once and for all, a convention distinguishing the pin, the argmin, and the economic optimum of Remark 3.1, and restate every census in it.

**A structural conjecture (diagonal extremality).** Theorem 5.1 showed that $4/3$ is the maximum of a one-dimensional slice ($P=\mu$) of a two-parameter cost surface, and that the slice is cut out by an *informational* condition (the oracle is uninformative). Conjecturally this is the general pattern: **every constant cap in the barrier map is the extremum of a slice determined by an informational budget.** If true, the scattered constants of the map collapse into a single finite convex-analysis problem on one surface, and "class crossing" becomes simply movement off a slice — never a violation. Both the cap and the anchors now live on the same law, so this is a tractable question rather than a modelling one.

---

## 9. Conclusion

Three laws, one surface.

For a fixed-window oracle, the value of a hint is $S_A = 1/[\mu P + (1-P)(1-\mu)]$; silence, when the protocol is committed, is a certificate worth exactly one block measure per occurrence, which is why the three protocols sit in arithmetic progression. The cap $1/\mu$ is real but regime-bound; the honest bound is $1/\min(\mu,1-\mu)$; and at a balanced block the oracle's accuracy is worth nothing at all.

For adaptive search, the cost saturates at exactly $\log_2 W + \tfrac12$ on dyadic windows — the fixed point of the halving recursion — while the true minimum sits exactly half a query lower, on a two-point plateau. The marginal value of a query is $W/2^{k+2}-1$, net of its own charge; the gross form is false. For general widths the closed form is correct within half a query in both directions.

For pipelines, speedups multiply, and the two factors obey incomparable laws: the COST class is capped at $4/3$, attained only at balance, and this $4/3$ is the extremum of the uninformative diagonal of the fixed-window surface; the SET class is capped only by its bit budget $2^k$, attained only by uniform partitions, and by no constant at all. Measured speedups of $5.19\times$ and beyond are class crossings, not cap violations.

At the corner of the divisor hyperbola all of this collapses to a single sentence: a positional stage buys $\sqrt N$, a residue filter buys $4/3$, and their product is the barrier.
