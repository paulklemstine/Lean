# Multiplicative Domain Factors for Attention Key Budgets: Mechanism, Sharp Error Bars, and the Limits of the Verdict

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

Empirical studies of long-context attention repeatedly report a *key budget* $k^*$: the smallest number of attention keys that must be retained in order to preserve a prescribed fraction $\tau$ of the attention mass at a given context length $n$. Measured across text domains, these budgets appear to obey a strikingly simple law — each domain's entire budget curve seems to be the curve of a reference domain multiplied by a single constant, the *domain factor*. In a representative five-domain, two-context table, source code appears at $0.75\times$, mathematics at $1.0\times$, German prose at $1.25\times$ and French prose at exactly $2.0\times$ the English-prose curve $\{16, 20\}$.

We give a complete, model-free analysis of this claim. Working with an arbitrary positive attention profile, a head-mass functional, a retained-mass ratio and a gate, we identify the mechanism that produces multiplicative factors — *block dilation* of the profile — and prove that it does so with an exact one-block error bar: $c(k^*-1) < k^*_{\text{dilated}} \le c\,k^*$, with both inequalities attained. The relative error of the multiplicative law is therefore at most $1/k^*$, so the law is asymptotically exact but never exact in general; we exhibit an explicit profile, context and gate where it strictly fails, and give a checkable criterion under which it holds on the nose. The doubling increment inherits the same factor within the same bar, which is the structural reason a "$+4$ per doubling" reference column becomes a "$+8$" column at factor $2$.

We then audit the reported table as exact arithmetic. A single factor forces a cross-ratio identity; three of five rows satisfy it, two do not, so the global verdict is false on its own data. The surviving statement is a classification (the multiplicative rows are exactly English, mathematics and French) together with a quantisation invariant (every entry a multiple of $4$; every increment in $\{0,4,8\}$) that no row violates. Transfer theorems show the code and German rows arise from *no* integer dilation whatsoever, while the French row *forces* dilation depth $c=2$ and then predicts the long-context value to lie in $\{39,40\}$ — the reported value is $40$.

Enlarging the mechanism to rational factors via the adjoint operation, *key merging*, yields the only exact knee identity in the theory, a ceiling law $k^*(C_q w, n) = \lceil k^*(w, qn)/q\rceil$, which we identify as the origin of the observed quantisation. Rational factors rescue the German row (factor $5/4$) but reveal that a flat budget column forces merging depth $q \ge 5$, and that the code row is describable only at effective factor $3/5$, not the reported $0.75$.

Finally we address the reading the experiment actually uses, in which all domains are measured at *equal token counts*. Here the result is sharply negative and fully constructive: an exact token-matched factor forces the base budget curve to be flat over the factor's ratio, with a converse under a gate condition; the reported French value $32$ at the short context is unreachable, the honest window being $(22,24]$ and the honest factor at most $3/2$; and the flat code column cannot be a merging artefact, since pair merging turns a $+4$ base increment into $+2$, never $+0$. We supply a finite, checkable *flatness certificate* in the decay ratio, the gate and one measurement; prove that geometrically decaying profiles are eventually *exactly* flat, so spectral-gap domains genuinely do admit token-matched factors; and locate the stabilisation context explicitly. The honest form of the verdict is that a domain factor multiplies a profile invariant, the *limit knee* $k_\infty$, and not any pre-asymptotic measurement. An explicit dyadic witness realises the reported rising chain with knee $16$ at context $16$, $20$ at context $32$, limit knee $20$, and stabilisation locus exactly $21$, showing that all audited hypotheses are simultaneously satisfiable.

**Keywords:** attention key budget, knee threshold, block dilation, key merging, ceiling law, context scaling, quantisation, spectral gap.

---

## 1. Introduction

### 1.1 The empirical claim

A recurring engineering question for long-context sequence models is how many attention keys can be discarded without materially changing the attention output. Fix a gate $\tau$ close to $1$ — in the study motivating this paper, $\tau = 0.98$ — and define the *key budget* at context length $n$ as the smallest number of top-ranked keys whose mass reaches a $\tau$ fraction of the total mass visible at that context. Sweeping the budget on a grid and recording where the retained fraction first crosses the gate produces a single integer per (domain, context) pair.

A five-domain, two-context table of such measurements is the object of this paper:

| domain | $k^*$ at $n=512$ | $k^*$ at $n=1024$ | increment per doubling |
|---|---|---|---|
| source code | $12$ | $12$ | $+0$ |
| English prose | $16$ | $20$ | $+4$ |
| mathematics | $16$ | $20$ | $+4$ |
| German prose | $20$ | $24$ | $+4$ |
| French prose | $32$ | $40$ | $+8$ |

The reported verdict attached to this table is that **the domain factor is multiplicative**: each row is obtained from the English row $\{16,20\}$ by one constant, respectively $0.75$, $1$, $1$, $1.25$, $2$. If true, this would replace a full grid measurement for any new domain by a single number.

### 1.2 What this paper does

We take the claim as a mathematical hypothesis and settle it. The programme has five stages.

1. **Mechanism.** We identify block dilation of the attention profile as the operation that produces a multiplicative factor acting on *both* context columns simultaneously, and prove the master mass identity that drives everything else (§3).
2. **Sharp law.** We prove the multiplicative knee law with its exact one-block error bar, show the bar is attained, give a checkable exactness criterion, derive the $1/k^*$ relative-error bound, and prove the matching bracket for the doubling increment (§4).
3. **Audit.** We reduce the verdict to a cross-ratio identity, refute it on its own data, isolate the true classification and a surviving quantisation invariant, and transfer the mechanism's brackets into impossibility results for the anomalous rows and a confirmed prediction for the French row (§5).
4. **Rational factors.** We introduce key merging, prove its exact ceiling law, define rational factors, rescue the German row, and prove that a flat column forces coarse merging (§6).
5. **The token-matched reading, certificates, and the limit knee.** We show that the experiment's reading differs from the mechanism's, characterise exactly when the two coincide, supply a finite flatness certificate, prove eventual exact flatness for geometric profiles, locate the stabilisation context, and state the honest asymptotic form of the verdict — with an explicit witness realising the reported chain (§7–§8).

Everything is stated for an arbitrary strictly positive profile, an arbitrary context length and an arbitrary gate in $(0,1]$: there is no probabilistic model, no architecture, no training. The results are theorems about positive sequences, truncation and thresholds.

---

## 2. The model-free knee framework

### 2.1 Definitions

**Definition 2.1 (Attention profile).** An *attention profile* is a function $w : \mathbb{N} \to \mathbb{R}$ with $w_i > 0$ for all $i$. Informally $w_i$ is the attention mass carried by the $i$-th most important key. No monotonicity is required for any theorem below; monotonicity is the intended reading, not a hypothesis.

**Definition 2.2 (Head mass).** For $m \in \mathbb{N}$,
$$M_w(m) \;=\; \sum_{i=0}^{m-1} w_i, \qquad M_w(0)=0.$$
$M_w$ is strictly increasing on a positive profile.

**Definition 2.3 (Retained mass).** For a context length $n \ge 1$ and a budget $k \ge 0$,
$$R_w(n,k) \;=\; \frac{M_w(\min(k,n))}{M_w(n)} \;\in\; [0,1].$$
$R_w(n,\cdot)$ is non-decreasing in $k$ and saturates at $1$ for $k \ge n$; $R_w(\cdot,k)$ is non-increasing in $n$ (a longer context dilutes a fixed budget).

**Definition 2.4 (Gate and knee).** Fix a *gate* $\tau \in (0,1]$. The *knee*, or *key budget*, is
$$k^*(w,n,\tau) \;=\; \min\{k \in \mathbb{N} : R_w(n,k) \ge \tau\}.$$
The set is non-empty because $R_w(n,n) = 1 \ge \tau$, so the knee is well defined and satisfies $k^* \le n$.

### 2.2 Elementary properties

We record the facts used repeatedly.

**Lemma 2.5 (Pass/fail characterisation).**
(i) If $R_w(n,k) \ge \tau$ then $k^*(w,n,\tau) \le k$.
(ii) If $R_w(n,k) < \tau$ then $k < k^*(w,n,\tau)$.
(iii) $\tau \le R_w(n, k^*(w,n,\tau))$.

*Proof.* (i) and (iii) are the definition of a minimum of a non-empty set of naturals; (ii) is the contrapositive of (i). $\square$

**Lemma 2.6 (Positivity of the knee).** If $\tau > 0$, $n \ge 1$ and $w$ is positive, then $k^*(w,n,\tau) \ge 1$.

*Proof.* $R_w(n,0) = 0 < \tau$; apply Lemma 2.5(ii). $\square$

**Lemma 2.7 (Monotonicity in the context).** For a positive profile, $\tau \le 1$ and $1 \le n \le m$,
$$k^*(w,n,\tau) \;\le\; k^*(w,m,\tau).$$

*Proof.* $R_w(\cdot,k)$ is non-increasing in the context, so the knee at the longer context passes the gate at the shorter one; conclude by Lemma 2.5(i). Seeing more tokens can only raise the budget. $\square$

Lemma 2.7 is the backbone of §8: an integer sequence that is monotone and bounded is eventually constant.

---

## 3. Block dilation and the master mass identity

### 3.1 The operation

**Definition 3.1 (Block dilation).** For an integer $c \ge 1$ and a profile $w$, the *block dilation* $D_c w$ is the profile
$$(D_c w)_i \;=\; \frac{w_{\lfloor i/c\rfloor}}{c}, \qquad i \in \mathbb{N}.$$

Each key of $w$ is split into $c$ consecutive keys of equal mass. Positivity is preserved. The intended reading: a domain that expresses the same content with $c$ times as many tokens has, at the level of attention, the dilated profile of the reference domain.

### 3.2 Mass under dilation

**Lemma 3.2 (Whole-block preservation).** For every $c \ge 1$ and every $k$,
$$M_{D_c w}(ck) \;=\; M_w(k).$$

*Proof sketch.* Induction on $k$. The inductive step splits $\mathrm{range}(c(k+1))$ into $\mathrm{range}(ck)$ and a block of $c$ indices $ck, \dots, ck+c-1$. On that block $\lfloor (ck+i)/c\rfloor = k$ for $0 \le i < c$, so each term equals $w_k/c$ and the block contributes exactly $c \cdot w_k/c = w_k$, which is precisely the term added to $M_w(k)$ to obtain $M_w(k+1)$. $\square$

**Theorem 3.3 (Master mass identity).** For every $c \ge 1$ and every $m \in \mathbb{N}$,
$$M_{D_c w}(m) \;=\; M_w\!\left(\left\lfloor \tfrac{m}{c}\right\rfloor\right) \;+\; (m \bmod c)\cdot \frac{w_{\lfloor m/c\rfloor}}{c}.$$

*Proof sketch.* Write $m = c\lfloor m/c\rfloor + (m \bmod c)$ and split the sum at the last whole block. Lemma 3.2 evaluates the first part. On the residual block every index has the same quotient $\lfloor m/c\rfloor$, so each of the $(m\bmod c)$ terms equals $w_{\lfloor m/c\rfloor}/c$. $\square$

Theorem 3.3 is the technical heart of the paper: mass accumulates block by block exactly as in the base profile, and *interpolates linearly inside* a block. The one-block error bar of §4 is a direct consequence — the knee of the dilated profile may occur strictly inside the block in which the base knee occurs.

**Corollary 3.4 (Reparametrisation of the retained curve).** For every $c \ge 1$ and all $n, k$,
$$R_{D_c w}(cn,\,ck) \;=\; R_w(n,k).$$

*Proof.* $\min(ck,cn) = c\min(k,n)$, then apply Lemma 3.2 to numerator and denominator. $\square$

Corollary 3.4 is the exact sense in which a dilated domain is the reference domain "run slower": stretch context and budget by the same factor and the retained-mass curve is unchanged. Note that this is an identity between two genuinely different profiles, not an unfolding of definitions.

---

## 4. The multiplicative knee law with a sharp error bar

Throughout this section $w$ is a positive profile, $c \ge 1$, $n \ge 1$, $0 < \tau \le 1$, and $k^* = k^*(w,n,\tau)$.

**Theorem 4.1 (Upper half of the law).** $\;k^*(D_c w,\; cn,\; \tau) \;\le\; c\,k^*.$

*Proof.* By Lemma 2.5(iii), $\tau \le R_w(n,k^*)$. By Corollary 3.4, $R_{D_c w}(cn, ck^*) = R_w(n,k^*) \ge \tau$. Apply Lemma 2.5(i). $\square$

**Theorem 4.2 (Lower half of the law).** If moreover $\tau > 0$, then
$$c\,(k^* - 1) \;<\; k^*(D_c w,\; cn,\; \tau).$$

*Proof.* By Lemma 2.6, $k^* \ge 1$. By minimality, $R_w(n, k^*-1) < \tau$. By Corollary 3.4, $R_{D_c w}(cn,\, c(k^*-1)) = R_w(n,k^*-1) < \tau$, so Lemma 2.5(ii) applies. $\square$

Together:

$$\boxed{\;c\,(k^*-1) \;<\; k^*(D_c w,\, cn,\, \tau)\;\le\; c\,k^*\;}$$

**The multiplicative domain factor is correct up to exactly one dilation block.** The window contains $c$ integers, so the law determines the dilated knee to within $c$ possible values and no better in general. That "no better" is a theorem, not a limitation of the argument:

**Theorem 4.3 (Sharpness; exact multiplicativity is false).** Let $w_i = 1$ for all $i$, $c = 2$, $n = 2$, $\tau = 1/4$. Then $k^*(w,2,\tau) = 1$ while $k^*(D_2 w, 4, \tau) = 1 < 2 = c\,k^*$.

*Proof.* For the uniform profile, $M_w(m) = m$, so $R_w(2,1) = 1/2 \ge 1/4$ and $R_w(2,0) = 0 < 1/4$, giving $k^* = 1$. For the dilation, $M_{D_2 w}(m) = m/2$, so $R_{D_2 w}(4,1) = (1/2)/2 = 1/4 \ge \tau$, whence the dilated knee is at most $1$; it is at least $1$ by Lemma 2.6. $\square$

Hence any claim of exact multiplicativity requires a hypothesis. Here is the natural one.

**Theorem 4.4 (Exactness criterion).** If $\tau > 0$ and the gate is still not cleared one key before the block boundary,
$$R_{D_c w}\big(cn,\; c\,k^* - 1\big) \;<\; \tau,$$
then $k^*(D_c w, cn, \tau) = c\,k^*$ exactly.

*Proof.* Theorem 4.1 gives "$\le$". The hypothesis and Lemma 2.5(ii) give $c k^* - 1 < k^*(D_cw, cn,\tau)$, i.e. "$\ge$", using $ck^* \ge 1$. $\square$

The criterion is checkable from the dilated profile at a single budget; it says precisely that the knee does not land strictly inside the last block.

**Theorem 4.5 (Relative error).** With $\tau>0$,
$$1 - \frac{1}{k^*} \;<\; \frac{k^*(D_c w,\, cn,\, \tau)}{c\,k^*} \;\le\; 1.$$

*Proof.* Divide the bracket by $c k^* > 0$ and use $c(k^*-1)/(ck^*) = 1 - 1/k^*$. $\square$

**Interpretation.** The multiplicative law is *asymptotically exact*: its relative error decays like $1/k^*$, uniformly in $c$, $n$ and $\tau$. On budgets of size $16$–$40$, the range of the reported table, the error is below $6.3\%$ — the same order as the resolution of the grid on which the budgets were read. A factor law can therefore be a perfectly honest description of coarse data while being false as an identity.

**Theorem 4.6 (Increment bracket).** Let $\Delta = k^*(w,2n,\tau) - k^*(w,n,\tau)$ be the base doubling increment and $\Delta_{c} = k^*(D_c w, 2cn, \tau) - k^*(D_c w, cn, \tau)$ the dilated one. Then
$$c\,\Delta - (c-1) \;\le\; \Delta_c \;\le\; c\,\Delta + (c-1).$$

*Proof sketch.* Apply Theorems 4.1 and 4.2 at contexts $n$ and $2n$ (using $2(cn) = c(2n)$) and subtract the resulting integer bounds; the two one-block errors combine into $\pm(c-1)$ after passing from strict to non-strict inequalities between integers. $\square$

Theorem 4.6 is the reason a single dilation parameter governs *both* columns of the table: for $c = 2$ a base increment of $+4$ must produce a dilated increment in $\{7,8,9\}$, and the reported French increment is $+8$.

---

## 5. Auditing the reported table

### 5.1 The verdict as exact arithmetic

**Definition 5.1 (Row and factor).** A *row* is a pair $r = (r_{512}, r_{1024}) \in \mathbb{N}^2$ of measured knees; its *increment* is $\iota(r) = r_{1024} - r_{512} \in \mathbb{Z}$. Given a base row $b$, the row $r$ *has factor* $\lambda \in \mathbb{Q}$ if
$$r_{512} = \lambda\, b_{512} \quad\text{and}\quad r_{1024} = \lambda\, b_{1024}.$$

The reported rows are $\mathrm{code} = (12,12)$, $\mathrm{EN} = (16,20)$, $\mathrm{math} = (16,20)$, $\mathrm{DE} = (20,24)$, $\mathrm{FR} = (32,40)$, with base $b = \mathrm{EN}$.

**Proposition 5.2 (Rigidity).** If $b_{512} \ne 0$ and $r$ has factor $\lambda$, then $\lambda = r_{512}/b_{512}$. Consequently a row has at most one factor.

**Theorem 5.3 (Cross-ratio criterion).** If $b_{512} \ne 0$, then $r$ has *some* factor if and only if
$$r_{512}\, b_{1024} \;=\; r_{1024}\, b_{512}.$$

*Proof.* Necessity: substitute $r = \lambda b$ and cancel. Sufficiency: take $\lambda = r_{512}/b_{512}$; the first column holds by construction and the second is exactly the cross-ratio identity divided by $b_{512}$. $\square$

This reduces the entire empirical content of the verdict to one multiplication per row.

**Proposition 5.4 (Increments scale).** If $r$ has factor $\lambda$ then $\iota(r) = \lambda\, \iota(b)$.

**Proposition 5.5 (No factor kills an increment).** If $\lambda \ne 0$ and $\iota(b) \ne 0$, then $\iota(r) \ne 0$.

*Proof.* Immediate from Proposition 5.4 and the absence of zero divisors in $\mathbb{Q}$. $\square$

### 5.2 The five rows

Applying Theorem 5.3 with $b = (16,20)$:

| row | cross-ratio test | verdict |
|---|---|---|
| $\mathrm{EN}=(16,20)$ | $16\cdot 20 = 320 = 20 \cdot 16$ | factor $1$ |
| $\mathrm{math}=(16,20)$ | $320 = 320$ | factor $1$ |
| $\mathrm{FR}=(32,40)$ | $32\cdot 20 = 640 = 40\cdot 16$ | **factor $2$** |
| $\mathrm{code}=(12,12)$ | $12\cdot 20 = 240 \ne 192 = 12\cdot 16$ | **no factor** |
| $\mathrm{DE}=(20,24)$ | $20 \cdot 20 = 400 \ne 384 = 24\cdot 16$ | **no factor** |

**Theorem 5.6 (The verdict is refuted by its own table).** It is *not* the case that every reported row has a factor relative to the English row.

**Theorem 5.7 (Sharpened classification).** Among the five reported rows, exactly those equal to $(16,20)$ or $(32,40)$ — English, mathematics and French — have a factor relative to English.

**Proposition 5.8 (Quantified failures).** The factor $12/16 = 0.75$ read off the code row's short column predicts $15$ at the long context; the measurement is $12$. The factor $20/16=1.25$ read off the German row predicts $25$; the measurement is $24$.

The two failures are qualitatively different. German misses by one key out of $25$ — a single grid point, within the resolution of the sweep. Code misses by $3$ out of $15$ ($20\%$) and, by Proposition 5.5, its vanishing increment places it outside *any* multiplicative family whose base increment is non-zero, irrespective of the numerical value of the factor.

**Theorem 5.9 (Surviving invariant: quantisation).** Every entry of the reported table is a multiple of $4$, and every doubling increment lies in $\{0,4,8\} = 4\cdot\{0,1,2\}$.

This invariant is strictly weaker than multiplicativity and, unlike it, is violated by no row. §6 identifies its mechanism.

### 5.3 Transfer: which rows can be dilations at all?

The brackets of §4 hold for *every* positive profile, context and gate. Feeding in the reported English knees turns each row into a decidable arithmetic question — these are impossibility results, not fits.

**Theorem 5.10 (Code row is not a dilation).** Let $w$ be positive, $c \ge 1$, $n\ge1$, $0<\tau\le1$ and $k^*(w,n,\tau) = 16$. Then $k^*(D_c w, cn, \tau) \ne 12$.

*Proof.* Theorem 4.2 gives $15c < k^*(D_c w, cn,\tau)$, and $15c \ge 15$. $\square$

**Theorem 5.11 (German row is not a dilation).** Under the same hypotheses, $k^*(D_c w, cn, \tau) \ne 20$.

*Proof.* Theorems 4.1 and 4.2 confine the dilated knee to $(15c,\,16c]$. For $c=1$ this is $(15,16]$; for $c \ge 2$ it lies above $30$. Neither contains $20$. $\square$

**Theorem 5.12 (French row forces $c=2$).** Under the same hypotheses, if $k^*(D_c w, cn, \tau) = 32$ then $c = 2$.

*Proof.* $32 \in (15c, 16c]$ forces $16c \ge 32$ and $15c < 32$, i.e. $2 \le c \le 2$. $\square$

**Theorem 5.13 (Pre-registered prediction, confirmed).** Assume in addition $k^*(w,2n,\tau) = 20$ and $k^*(D_c w, cn, \tau) = 32$. Then
$$k^*(D_c w,\; 2cn,\; \tau) \;\in\; \{39,\,40\}.$$
The reported French value at the long context is $40$.

*Proof.* Theorem 5.12 forces $c=2$; apply the bracket at context $2n$ with base knee $20$ to get $(38, 40]$. $\square$

This is the epistemically strongest item in the audit: the dilation depth is *determined* by one column, and the other column is then confined to two values before being consulted.

---

## 6. Rational factors: key merging and the ceiling law

Two reported factors, $0.75$ and $1.25$, are not integers, so block dilation alone cannot produce them. The missing half of the mechanism is the adjoint operation.

**Definition 6.1 (Key merging).** For $q \ge 1$,
$$(C_q w)_i \;=\; \sum_{j=0}^{q-1} w_{qi+j}.$$
Each block of $q$ adjacent keys is fused into a single key carrying the block's total mass. Positivity is preserved.

**Lemma 6.2 (Mass and retained curve).** $M_{C_q w}(k) = M_w(qk)$ and $R_{C_q w}(n,k) = R_w(qn, qk)$.

*Proof sketch.* The first is an induction on $k$ identical in shape to Lemma 3.2; the second follows since $\min(qk,qn) = q\min(k,n)$. $\square$

Unlike dilation, merging admits an *exact* knee formula.

**Theorem 6.3 (Ceiling law).** For a positive profile, $q \ge 1$, $n \ge 1$ and $\tau \le 1$,
$$k^*(C_q w,\; n,\; \tau) \;=\; \left\lceil \frac{k^*(w,\, qn,\, \tau)}{q}\right\rceil.$$

*Proof sketch.* Write $K = k^*(w,qn,\tau)$. By Lemma 6.2, a budget $k$ clears the gate for $C_q w$ at context $n$ iff $R_w(qn, qk) \ge \tau$, which by Lemma 2.5 and monotonicity of $R_w(qn,\cdot)$ holds iff $K \le qk$. Thus the gate set of the merged profile is exactly $\{k : K \le qk\} = \{k : \lceil K/q\rceil \le k\}$, whose least element is $\lceil K/q \rceil$. $\square$

Theorem 6.3 is the only closed-form knee identity in this theory, and it is the source of the quantisation observed in Theorem 5.9: **dilation multiplies increments; merging quantises them.** A table exhibiting both a doubled increment (French) and a vanished increment (code) cannot arise from one operation alone.

**Definition 6.4 (Rational domain factor).** For $p,q \ge 1$, the $p/q$-rescaling of $w$ is $\mathrm{Rat}_{p/q}\,w = D_p(C_q w)$: merge $q$ keys, then dilate by $p$.

**Theorem 6.5 (Rational window).** With $K = k^*(w, qn, \tau)$ and $0 < \tau \le 1$,
$$p\left(\left\lceil \tfrac{K}{q}\right\rceil - 1\right) \;<\; k^*\big(\mathrm{Rat}_{p/q}w,\; pn,\; \tau\big) \;\le\; p\left\lceil \tfrac{K}{q}\right\rceil.$$

*Proof.* Apply the bracket of §4 to the positive profile $C_q w$, then rewrite $k^*(C_qw,n,\tau)$ by Theorem 6.3. $\square$

### 6.1 Re-auditing the anomalous rows

**Theorem 6.6 (German row rescued).** Suppose $k^*(w,4n,\tau)=16$ and $k^*(w,8n,\tau)=20$. Then
$$15 < k^*(\mathrm{Rat}_{5/4}w,\;5n,\;\tau) \le 20 \quad\text{and}\quad 20 < k^*(\mathrm{Rat}_{5/4}w,\;10n,\;\tau) \le 25 .$$
The measured German pair $(20,24)$ lies inside both windows.

Theorem 5.11 proved $(20,24)$ incompatible with every integer dilation; Theorem 6.6 shows rational factors are strictly more expressive and that the German anomaly is a *ceiling effect*, not noise. We stress that Theorem 6.6 is a consistency statement — the measurement lies in the predicted window — not the construction of a profile realising the row.

**Theorem 6.7 (Flatness forces coarse merging).** Suppose $k^*(w,qn,\tau) = 16$, $k^*(w,2qn,\tau)=20$, $p,q \ge 1$, and the rescaled curve is *flat*,
$$k^*(\mathrm{Rat}_{p/q}w,\, pn,\, \tau) \;=\; k^*(\mathrm{Rat}_{p/q}w,\, 2pn,\, \tau).$$
Then $q \ge 5$.

*Proof sketch.* For $q \le 4$ one checks the four cases $\lceil 16/q\rceil < \lceil 20/q \rceil$ — namely $16<20$, $8<10$, $6<7$, $4<5$ — so $p\lceil 16/q\rceil \le p(\lceil 20/q\rceil - 1)$ and the two windows of Theorem 6.5 are disjoint, contradicting equality of the two knees. At $q=5$ both ceilings equal $4$ and the obstruction disappears. $\square$

**Theorem 6.8 (Code row consistency at $3/5$).** If $k^*(w,5n,\tau)=16$ and $k^*(w,10n,\tau)=20$, then both rescaled knees of $\mathrm{Rat}_{3/5}w$ lie in $(9,12]$, a window containing the measured $12$ at both contexts.

So the flat code column is describable within the enlarged mechanism, but at effective factor $3/5 = 0.6$, not the reported $0.75$: **the reported factor and the reported flat increment cannot both come from the same mechanism.**

---

## 7. The token-matched reading

### 7.1 Two different comparisons

All results so far compare a domain profile at context $cn$ with the base profile at context $n$ — the *matched-context* reading, in which the same underlying content is visible on both sides. The reported experiment does something else: every domain is measured at the *same token count*, $512$ for all rows, then $1024$ for all rows. Call this the *token-matched* reading. The following theorem quantifies the discrepancy.

**Theorem 7.1 (Reconciliation window).** For a positive profile, $c \ge 1$, $n\ge1$, $0<\tau\le1$,
$$k^*(D_c w,\; cn,\;\tau) \;\le\; c\,k^*(w,n,\tau) \;<\; k^*(D_c w,\; cn,\; \tau) + c.$$

*Proof.* Restatement of Theorems 4.1–4.2 with the strict lower bound rewritten as $c\,k^* - c < k^*_{\text{dilated}}$. $\square$

Consequently, writing $K = k^*(w,cn,\tau)$ for the base knee at the *reported* context and $D = K - k^*(w,n,\tau)$ for the base increment across the ratio $c$, the dilated knee measured at that same context lies within one block of $c(K-D)$, whereas the naive token-matched prediction is $cK$. **The naive prediction overshoots by exactly $cD$, up to one block.**

### 7.2 The dichotomy

**Theorem 7.2 (An exact token-matched factor forces flatness).** Let $w$ be positive, $c \ge 1$, $n \ge 1$, $0<\tau\le1$, and suppose the token-matched factor law holds at the single context $N = cn$:
$$k^*(D_c w,\; N,\; \tau) \;=\; c\;k^*(w,\; N,\; \tau).$$
Then $k^*(w,n,\tau) = k^*(w,N,\tau)$.

*Proof.* Substituting the hypothesis into Theorem 4.1 gives $c\,k^*(w,N) \le c\,k^*(w,n)$, hence $k^*(w,N) \le k^*(w,n)$. Substituting into Theorem 4.2 gives $c(k^*(w,n)-1) < c\,k^*(w,N)$, hence $k^*(w,n) - 1 < k^*(w,N)$. The two integer inequalities force equality. $\square$

**Corollary 7.3 (Rising curves have no exact token-matched factor).** If $k^*(w,n,\tau) < k^*(w,cn,\tau)$ — which is exactly what a positive doubling increment asserts — then $k^*(D_c w, cn,\tau) \ne c\,k^*(w,cn,\tau)$ for every $c \ge 1$.

**Theorem 7.4 (Converse).** If the base curve is flat, $k^*(w,n,\tau) = k^*(w,cn,\tau)$, and the gate condition of Theorem 4.4 holds, then the token-matched factor law holds exactly.

Thus flatness of the base curve over the factor's ratio is *necessary*, and — modulo the gate condition — *sufficient*, for an exact token-matched domain factor.

### 7.3 Consequences for the reported rows

Read the reported English chain backwards by its own $+4$ law: $k^*@512 = 16$ implies $k^*@256 = 12$.

**Theorem 7.5 (The French row is unreachable token-matched).** If $w$ is positive with $k^*(w,n,\tau)=12$ and $\tau\le1$, then $k^*(D_2 w, 2n, \tau) \le 24$; in particular it is not $32$.

**Theorem 7.6 (The honest French factor).** If additionally $\tau>0$ and $k^*(w,2n,\tau)=16$, then
$$\tfrac{11}{8}\cdot k^*(w,2n,\tau) \;<\; k^*(D_2w, 2n, \tau) \;\le\; \tfrac{3}{2}\cdot k^*(w,2n,\tau),$$
i.e. the token-matched French factor lies in $(11/8,\,3/2]$. The reported $2.0$ lies outside.

*Proof.* The bracket at base knee $12$ confines the dilated knee to $(22,24]$; divide by $16$. $\square$

**Theorem 7.7 (The price of keeping $32$).** If $k^*(w,2n,\tau)=16$ and $k^*(D_2w,2n,\tau)=32$, then $k^*(w,n,\tau) = k^*(w,2n,\tau) = 16$: the English curve is flat across that doubling — contradicting the $+4$ increment reported in the same table.

*Proof.* The hypothesis is exactly the token-matched factor law at $c=2$; apply Theorem 7.2. $\square$

On the compression side, the ceiling law lets us compute rather than bracket.

**Theorem 7.8 (Code row, exactly).** If $k^*(w,2n,\tau) = 20$ then $k^*(C_2w, n, \tau) = 10$ — not the $8$ that a naive factor $0.5$ applied to $k^*@512=16$ predicts. The token-matched compression factor is $5/8$, not $1/2$.

**Theorem 7.9 (The flat code column is not a merging artefact).** If in addition $k^*(w,4n,\tau)=24$ (the $+4$ law continued one step), then $k^*(C_2w,n,\tau)=10$ and $k^*(C_2w,2n,\tau)=12$: a $+2$ increment, never $+0$.

**Theorem 7.10 (Merged increments survive).** More generally, if $k^*(w,qn,\tau) = K$ and $k^*(w,2qn,\tau) = K + D$ with $D \ge q$, then $k^*(C_qw,n,\tau) < k^*(C_qw,2n,\tau)$.

*Proof sketch.* By the ceiling law the two merged knees are $\lceil K/q\rceil$ and $\lceil (K+D)/q\rceil$; adding at least $q$ to the numerator raises the quotient by at least one. $\square$

**Summary of §7.** The reported multiplicative factor is a matched-context quantity, while the experiment measured a token-matched one. The two coincide exactly when the base budget curve is flat over the factor's ratio — precisely what the same table denies by reporting a positive doubling increment.

---

## 8. Certificates, stabilisation, and the asymptotic factor

Section 7 reduces "does this domain have a token-matched factor?" to "is the base curve flat?". This section decides that question.

### 8.1 A finite certificate

**Theorem 8.1 (Flatness certificate).** Let $w$ be positive with geometric decay $w_{i+1} \le r\,w_i$, $0<r<1$; let $0<\tau\le1$ and $n \ge 1$. If
$$\frac{r^{\,k^*(w,n,\tau)}}{1-r} \;\le\; 1-\tau,$$
then $k^*(w,m,\tau) = k^*(w,n,\tau)$ for every $m \ge n$.

*Proof sketch.* Under geometric decay the mass beyond budget $k$ is at most $w_0 r^{k}/(1-r)$ relative to the head, so the retained fraction at any context $m$ satisfies $R_w(m,k) \ge 1 - r^{k}/(1-r)$. The hypothesis makes this at least $\tau$ at $k = k^*(w,n,\tau)$, so that budget already passes at context $m$, giving $k^*(w,m,\tau) \le k^*(w,n,\tau)$; the reverse is Lemma 2.7. $\square$

The hypothesis is a finite inequality in three numbers: the decay ratio, the gate, and a *single* measurement. It is not circular, since no quantity at the longer context appears.

**Theorem 8.2 (Eventual exact flatness).** Let $w$ be positive with geometric decay $w_{i+1}\le r\,w_i$, $0<r<1$, and $\tau<1$. Then there exists $N \ge 1$ with $k^*(w,m,\tau) = k^*(w,N,\tau)$ for all $m \ge N$.

*Proof sketch.* Geometric decay makes the knee uniformly bounded in the context; Lemma 2.7 makes it non-decreasing. A bounded non-decreasing sequence of naturals attains its supremum and is constant thereafter. $\square$

This upgrades "bounded" to "eventually equal", which is what a token-matched factor requires.

**Theorem 8.3 (Spectral-gap domains admit token-matched factors).** Under the hypotheses of Theorem 8.2 there is $N \ge 1$ such that for all $c \ge 1$ and $m \ge N$, if the gate condition of Theorem 4.4 holds, then
$$k^*(D_c w,\; cm,\; \tau) \;=\; c\,k^*(w,\; cm,\; \tau).$$

*Proof.* Past $N$ the base curve is flat between $m$ and $cm$; apply Theorem 7.4. $\square$

So a token-matched domain factor is a genuine phenomenon — it is the privilege of domains whose attention has a spectral gap.

**Theorem 8.4 (Rising curves have no certificate).** If $w$ decays geometrically with ratio $r$ and $k^*(w,n,\tau) < k^*(w,2n,\tau)$, then
$$1-\tau \;<\; \frac{r^{\,k^*(w,n,\tau)}}{1-r},$$
for *every* admissible $r$: the certificate of Theorem 8.1 fails at every decay ratio.

**Corollary 8.5 (The reported reference row has no certificate).** If $k^*(w,n,\tau) = 16$ and $k^*(w,2n,\tau) = 20$, then $1-\tau < r^{16}/(1-r)$ for every $r \in (0,1)$, and for every $c \ge 2$ the token-matched factor law fails at context $cn$.

We therefore obtain a **dichotomy**: a domain either stabilises — and then possesses an exact multiplicative factor — or keeps rising, in which case no factor is defined for it at the measured context.

### 8.2 The limit knee and the stabilisation locus

**Definition 8.6 (Limit knee).** For a summable positive profile,
$$k_\infty(w,\tau) \;=\; \min\Big\{k : \tau \sum_{i=0}^{\infty} w_i \;\le\; M_w(k)\Big\}.$$
No context length appears: $k_\infty$ is an invariant of the profile and the gate. It is well defined for $\tau < 1$ because head masses converge to the total mass, and $k_\infty \ge 1$.

**Theorem 8.7 (Measurements under-report).** For every $n \ge 1$, $\;k^*(w,n,\tau) \le k_\infty(w,\tau)$.

*Proof sketch.* If $n \le k_\infty$ the retained fraction at budget $k_\infty$ is $1 \ge \tau$. Otherwise $\tau M_w(n) \le \tau\sum_i w_i \le M_w(k_\infty)$, so budget $k_\infty$ clears the gate at context $n$. Apply Lemma 2.5(i). $\square$

**Theorem 8.8 (One inequality decides the knee).** If $M_w(k_\infty - 1) < \tau\,M_w(n)$ then $k^*(w,n,\tau) = k_\infty(w,\tau)$.

**Theorem 8.9 (Explicit stabilisation locus).** Let $w$ be positive with $w_{i+1}\le r w_i$, $0<r<1$, and $0<\tau<1$. If $N \ge 1$ satisfies
$$\tau\cdot\frac{w_0\,r^N}{1-r} \;<\; \tau \sum_i w_i \;-\; M_w(k_\infty(w,\tau)-1),$$
then $k^*(w,m,\tau) = k_\infty(w,\tau)$ for all $m \ge N$. Such an $N$ always exists.

*Proof sketch.* The geometric tail bound gives $\sum_i w_i - M_w(m) \le w_0 r^m/(1-r)$, which is non-increasing in $m$; the displayed inequality then yields the hypothesis of Theorem 8.8 at every $m \ge N$. Existence follows since $r^N \to 0$ while the right-hand side is a fixed positive number (positive because $k_\infty$ is minimal). $\square$

**Theorem 8.10 (The reported reference row is pre-asymptotic).** If $k^*(w,n,\tau) = 16$ and $k^*(w,2n,\tau) = 20$, then $k_\infty(w,\tau) \ge 20$, and every stabilisation locus $N$ (a context past which the knee is constant at $k_\infty$) satisfies $N > n$.

**Theorem 8.11 (Honest form of the verdict).** Under the hypotheses of Theorem 8.9 there is $N \ge 1$ such that for all $c \ge 1$ and $m \ge N$, subject to the gate condition,
$$k^*(D_c w,\; cm,\; \tau) \;=\; c\;k_\infty(w,\tau).$$

**The single number per domain multiplies the asymptotic budget, never a measured one.** This also explains, without any appeal to noise, why measured factors drift with context: by Theorem 8.7 every measurement under-reports, and a ratio of two under-reports need not equal the ratio of the limits.

### 8.3 An explicit witness

An audit is worth only as much as the consistency of its hypotheses, so we exhibit a profile realising the reported chain — with geometric decay, the most favourable case.

**Definition 8.12.** Let $w_i = 2^{-i}$ and $\tau_0 = \dfrac{2^{32}-5000}{2^{32}-1} \approx 0.9999988$.

Here $M_w(k) = 2 - 2^{1-k}$ and $\sum_i w_i = 2$, so all the following are exact rational computations.

**Theorem 8.13 (Rising geometric witness).** $k^*(w,16,\tau_0) = 16$ and $k^*(w,32,\tau_0) = 20$.

*Proof sketch.* At context $16$, budget $16$ retains everything, while budget $15$ retains $(1-2^{-15})/(1-2^{-16})$, which is below $\tau_0$. At context $32$ the condition $R_w(32,k)\ge\tau_0$ reduces to $2^{32-k}\le 5000$, i.e. $k\ge 20$. $\square$

**Theorem 8.14 (Limit knee of the witness).** $k_\infty(w,\tau_0) = 20$.

*Proof sketch.* $\tau_0\cdot 2 \le 2 - 2^{1-k}$ iff $2^{-k} \le 4999/(2^{32}-1)$, which holds first at $k=20$. $\square$

**Theorem 8.15 (Locus of the witness is exactly $21$).** $k^*(w,20,\tau_0)\le 19$, while $k^*(w,m,\tau_0) = 20$ for every $m \ge 21$.

Hence: the reported short context lies strictly below the stabilisation locus; the reported long-context value is the asymptotic budget while the short-context value is not; and all hypotheses of the audit — positivity, genuine geometric decay, a gate in $(0,1)$, and knees $16$ and $20$ across a doubling — are simultaneously satisfiable. It is the certificate, not the data, that fails.

---

## 9. Algorithms

Three computational procedures follow directly from the theory. All are exact in rational arithmetic.

**A. Knee evaluation.** Given a profile oracle, a context $n$ and a gate $\tau$, accumulate head masses once and return the least $k$ with $M_w(k) \ge \tau M_w(n)$. Cost: $O(n)$ oracle calls and additions, $O(1)$ extra memory. Binary search over $k$ is possible but pointless, since the prefix sums are computed anyway.

**B. Factor audit.** Given a base row and a candidate row, evaluate the cross-ratio $r_{512}b_{1024} - r_{1024}b_{512}$. If zero, report the unique factor $r_{512}/b_{512}$; otherwise report the failure together with the prediction $\left(r_{512}/b_{512}\right) b_{1024}$ and the discrepancy. Cost: $O(1)$ exact integer operations. This is a complete decision procedure for the verdict, by Theorem 5.3.

**C. Certificate and locus.** Given a decay ratio $r$, a gate $\tau$ and one measurement $k^*$, test $r^{k^*}/(1-r) \le 1-\tau$. If it holds, the knee is frozen from that context onwards (Theorem 8.1) and a token-matched factor is legitimate. Otherwise compute $k_\infty$ from the total mass and return the least $N$ with $\tau w_0 r^N/(1-r) < \tau\sum_i w_i - M_w(k_\infty-1)$; this is the stabilisation locus, obtained in $O(\log(1/r)^{-1}\log(1/\varepsilon))$ arithmetic steps by direct search over $N$ or in closed form by taking logarithms.

A fourth, purely diagnostic procedure is worth naming: **window screening.** Given a reference knee $K$ and a candidate measurement $M$, the set of integer dilation depths compatible with $M$ is $\{c : K(c-1) < M \le Kc\}$, computable in $O(1)$; it is empty for the code and German rows against $K=16$ and the singleton $\{2\}$ for the French row.

---

## 10. Applications

**Budget planning for new domains.** The correct protocol implied by the theory is: (i) measure the budget curve at two contexts in the target domain; (ii) test the cross-ratio identity against the reference domain; (iii) if it passes, screen for the compatible dilation depths and check the one-block window; (iv) *before* quoting a factor, test the flatness certificate. If the certificate fails, quote a window, not a number — the measurement is pre-asymptotic and any factor read off it will drift.

**Cache-size provisioning.** Theorem 8.7 states that measured budgets systematically under-report the asymptotic budget $k_\infty$. Provisioning a key cache from a short-context measurement therefore *under*-provisions, in a direction that is systematic rather than random. Theorem 8.9 gives the context past which the measurement can be trusted.

**Cross-lingual transfer.** A verified $c$-fold dilation relation between two domains yields far more than a scalar: by Corollary 3.4 the entire retained-mass curve transfers, so any budget-dependent quantity (not merely the knee) can be transported. Conversely, the impossibility results of §5.3 mean a failed cross-ratio test is evidence of a genuinely different attention geometry, not of a noisy measurement.

**Sparse-attention design.** The dichotomy of §8 suggests a design principle: engineer for a spectral gap. A profile with geometric decay has a stabilisation locus, an exactly flat budget curve beyond it, and hence a legitimate, context-independent budget — the operationally desirable regime. A heavy-tailed profile has a knee that keeps rising, and its budget must be quoted per context.

**Interpretation of quantised tables.** Theorem 6.3 predicts that any pipeline that fuses or pools keys will produce budget columns quantised by the pooling depth. Observed quantisation (all entries divisible by $4$) is thus evidence about the *measurement*, not necessarily about the language.

---

## 11. Discussion

Three points deserve emphasis.

**The verdict is not so much false as mis-addressed.** A multiplicative domain factor is a real and precisely characterisable object: it is the signature of a block dilation, it is accurate to one dilation block, it transports the whole retained curve, and it becomes exact past the stabilisation locus, where it multiplies the limit knee. What is false is the claim in the form asserted — as an exact relation between two pre-asymptotic, token-matched measurements. The gap between the two readings is not a subtlety; it is exactly $c$ times the base increment, and for the flagship French row it is the difference between $32$ and the achievable ceiling of $24$.

**Failures carry information.** The two rows that fail the cross-ratio test fail for structurally different reasons. German misses by one grid point and is fully explained by a ceiling effect once merging is admitted (factor $5/4$). Code misses by $20\%$ and has a *vanishing* increment, which no non-zero factor can produce from a non-zero one; even within the enlarged rational mechanism it needs merging depth $q \ge 5$ and effective factor $3/5$. Source code is not a rescaled dialect of prose.

**The strongest evidence in the table is the one prediction.** Of the five rows, only French has its dilation depth *forced* by one column ($c=2$, uniquely) with the other column then confined to two values, $\{39,40\}$, in advance. That the measurement is $40$ is a genuine confirmation of the mechanism, in the matched-context reading. It is precisely this row that the token-matched analysis then places out of window, so the two readings must be kept rigorously apart.

**Limitations.** All results concern the knee functional of a positive sequence; they say nothing about how a given text domain induces such a sequence, which is an empirical question. The consistency results of §6 (Theorems 6.6 and 6.8) show measurements lying inside predicted windows; they do not construct profiles realising the rows. The impossibility results, by contrast, are universally quantified over profiles, contexts and gates. Finally, the analysis treats a single attention profile; a real model has many heads and layers, and the aggregate knee of a mixture is not the knee of the aggregate.

---

## 12. Future directions

**Beyond integer and rational rescaling.** Dilation and merging generate only rational factors. A continuous rescaling — for example an interpolation of the head-mass function along a flow — would allow irrational factors and might sharpen the one-block bar into a Lipschitz estimate.

**Multi-context chains.** The table has two columns. Three or more contexts would over-determine the factor and turn the cross-ratio test into a least-squares consistency question with an exact null distribution supplied by the one-block windows. Extending the reported chains to a further doubling is the cheapest available discriminator between the matched-context and token-matched readings.

**Mixtures of profiles.** Real attention is a superposition over heads. The knee of a positive combination of profiles is not a combination of knees; identifying when a mixture inherits a dilation relation from its components would connect this theory to multi-head architectures.

**Sharper certificates.** Theorem 8.1 assumes geometric decay. A certificate under a weaker tail condition — regular variation, or summability with an explicit modulus — would cover heavy-tailed domains, exactly the ones for which the current dichotomy returns "no factor".

**Empirical programme.** (i) Measure at further doublings to test the increment bracket directly; (ii) measure more languages and domains and screen them with the cross-ratio test before quoting factors; (iii) test at larger model scale, since all reported values come from a single scale; (iv) estimate the decay ratio $r$ and gate slack $1-\tau$ directly, so the flatness certificate can be evaluated rather than inferred, and report windows rather than point factors whenever it fails.

---

## 13. Conclusion

We have supplied the missing mechanism behind a reported multiplicative law for attention key budgets, together with its exact error bar and its precise domain of validity. Block dilation of an attention profile produces a multiplicative knee law accurate to one dilation block, $c(k^*-1) < k^*_{\text{dilated}} \le c\,k^*$, hence to relative error $1/k^*$, with an explicit counterexample to exactness and a checkable criterion for equality; the doubling increment inherits the same factor within the same bar. The reported five-domain table is refuted as a global verdict by a cross-ratio computation on two of its own rows, while the French row is not only consistent but *predictive*: the dilation depth is forced and the long-context value is confined in advance to $\{39,40\}$, with $40$ measured. Key merging supplies the only exact knee identity, $k^*(C_qw,n) = \lceil k^*(w,qn)/q\rceil$, which explains both the survival of the German row under rational factors and the observed quantisation of the table. Under the token-matched reading actually used by the experiment, exact factors exist precisely for context-stable base curves; the reported French value is unreachable and the flat code column is not a merging artefact. Finally, a finite certificate decides stability, geometric profiles are eventually exactly flat, and past an explicitly located stabilisation context every dilation multiplies the limit knee exactly. The honest form of the verdict is therefore: **one number per domain, multiplying an asymptotic invariant, valid once a checkable certificate holds — and a window, not a number, before that.**
