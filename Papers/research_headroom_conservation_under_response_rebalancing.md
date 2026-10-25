# Tie Profiles and the Ceiling of Spearman's Rho: An Exact Product Bound, the Failure of Headroom Factorisation, and a Ratio Law for Nested Profiles

**Aristotle**

*2026-10-25*

---

## Abstract

When a predictor (a "dial") and a response are recorded with ties, Spearman's rank correlation cannot reach $1$ even under a perfectly monotone relationship. We study the attainable ceiling as a function of the two **tie profiles**, the ordered lists of tied-block sizes. We first prove the two-sided tie correction in variance form: for a profile $L=(l_1,\dots,l_k)$ of $n$ observations, the centred sum of squares of the midranks equals $\big((n^3-n)-\sum_j(l_j^3-l_j)\big)/12$, that is, $(n^3-n)/12$ times the classical tie factor $f(L)=1-\sum_j(l_j^3-l_j)/(n^3-n)\in[0,1]$. From Cauchy–Schwarz we derive an **exact product bound**: for every pairing of observations, the textbook (untied-normalised) Spearman coefficient satisfies $\rho_u^2\le f(L)\,f(M)$, with no $O(1/n^2)$ remainder, and with equality for identical aligned profiles. We then show that the natural conjecture that the attainable correlation *factorises* through the two tie factors — which would make dial and response headrooms additive on the log scale — is **false**: the maximal $\rho_u$ is not a function of $(f(L),f(M))$, and with an untied dial the product bound is never attained by a response with $0<f(M)<1$. In its place we prove a **joint-profile law** for nested profiles: if one profile coarsens the other, $\max\rho_u=f(\text{coarse})$ and $\max\rho_c=\sqrt{f(\text{coarse})/f(\text{fine})}$ for the tie-corrected coefficient $\rho_c$. Headrooms therefore combine as a ratio, not a product. Applied to a pooled reading of $0.669$ with an untied dial, the results certify $f(M)\ge 0.669$ (textbook reading) or $f(M)\ge 0.447561$ (tie-corrected reading), but they do not allow a reported $+0.045$ advantage to be predicted from the response profile alone. We close with three conjectures supported by exhaustive enumeration for $n\le 7$.

---

## 1. Introduction

Spearman's rank correlation coefficient replaces observations by their ranks and measures how well two rankings agree. Its appeal is robustness: it sees only order, so it is invariant under monotone transformations of either variable. In practice, however, data are frequently **tied**. A predictor may take only a few settings; a response may be recorded on a coarse ordinal scale. The standard remedy assigns each member of a tied block the average of the ranks the block occupies — the *midrank* — and then either keeps the textbook normalisation or renormalises by the actual variances of the midrank vectors.

Either way, ties impose a *ceiling*: no pairing of observations can produce a rank correlation of $1$ unless the two variables are tied in exactly the same pattern. This paper asks how that ceiling depends on the two tie patterns.

A motivating scenario is the following. A study pools trials in which a dial (an experimenter-controlled ordinal setting) is compared with a response, and reports a pooled Spearman reading of $0.669$. The dial's ties are under the experimenter's control: one can always refine the dial until it is untied, driving its tie factor to $1$. A tempting accounting rule — which we call **headroom conservation** — holds that the attainable correlation factorises as the product of a dial factor and a response factor, so that the log-headrooms are additive. Under this rule the shortfall of $0.669$ below $1$ could be charged entirely to the response, and a reported $+0.045$ advantage between two analyses could be predicted from the response tie profile alone.

We show that the first half of this picture is exactly right — there *is* a product ceiling, and it holds with no error term — but that the second half fails: the ceiling is not attained in general, the attainable maximum is not determined by the two tie factors, and in the cleanest tractable case (nested profiles) the two headrooms combine as a *ratio*.

**Summary of contributions.**

1. *Two-sided tie correction (Theorem 1).* An exact closed form for the midrank sum of squares of any tie profile.
2. *Exact product bound (Theorem 2).* $\rho_u^2\le f(L)f(M)$ for every pairing, every $n\ge 2$.
3. *Equality and optimal pairing (Propositions 3–4).* Identical aligned profiles attain the bound; the aligned pairing maximises the covariance for any profiles.
4. *Failure of factorisation (Theorem 5, Corollary 7).* An explicit pair of configurations with equal tie factors and different ceilings; strictness of the bound for an untied dial.
5. *Nested-profile law (Theorem 6).* Exact maximal values of both coefficients for nested profiles.
6. *Pooled-reading certificate (Corollary 8).* Distribution-free lower bounds on the response tie factor implied by an observed coefficient.

---

## 2. Definitions and notation

### 2.1 Tie profiles and midranks

**Definition 1 (Tie profile).** A *tie profile* is a finite sequence $L=(l_1,\dots,l_k)$ of positive integers. Its *size* is $n=|L|=\sum_j l_j$. We write $s_j=l_1+\dots+l_{j-1}$ for the number of observations preceding block $j$.

A profile records the pattern of ties of a variable after sorting: the smallest value is shared by $l_1$ observations, the next by $l_2$, and so on. An untied variable has profile $(1,1,\dots,1)$; a constant variable has the single-block profile $(n)$.

**Definition 2 (Canonical midrank vector).** The midrank vector $R^L=(R^L_1,\dots,R^L_n)$ of $L$ assigns to each of the $l_j$ positions of block $j$ (namely positions $s_j+1,\dots,s_j+l_j$) the value
$$R^L_i=s_j+\frac{l_j+1}{2},$$
which is the average of the integers $s_j+1,\dots,s_j+l_j$. The vector $R^L$ is non-decreasing.

**Definition 3 (Tie mass and tie factor).** The *tie mass* of $L$ is $T(L)=\sum_j(l_j^3-l_j)$. For $n\ge 2$ the *tie factor* is
$$f(L)=1-\frac{T(L)}{n^3-n}.$$
This is the classical tie-attenuation factor; untied blocks ($l_j=1$) contribute nothing to $T(L)$.

**Definition 4 (Rank sum of squares).** With centre $c=(n+1)/2$,
$$\mathrm{SS}(L)=\sum_{i=1}^n\left(R^L_i-c\right)^2 .$$

### 2.2 Pairings and the two coefficients

Let $L$ and $M$ be profiles of the same size $n\ge 2$. We index observations by $i=1,\dots,n$ in the sorted order of the dial, so observation $i$ carries the dial midrank $R^L_i$. A *pairing* is a permutation $\sigma$ of $\{1,\dots,n\}$; under $\sigma$, observation $i$ carries the response midrank $R^M_{\sigma(i)}$. Every dataset of $n$ observations whose two variables have profiles $L$ and $M$ arises from some pairing, and conversely.

**Definition 5 (Rank covariance).**
$$\mathrm{Cov}_\sigma(L,M)=\sum_{i=1}^n\left(R^L_i-c\right)\left(R^M_{\sigma(i)}-c\right).$$

**Definition 6 (Textbook and tie-corrected rho).**
$$\rho_u(\sigma)=\frac{\mathrm{Cov}_\sigma(L,M)}{(n^3-n)/12},\qquad \rho_c(\sigma)=\frac{\mathrm{Cov}_\sigma(L,M)}{\sqrt{\mathrm{SS}(L)\,\mathrm{SS}(M)}} .$$
The *textbook* coefficient $\rho_u$ uses the untied normalisation (it coincides with the familiar formula $1-6\sum d_i^2/(n^3-n)$ in the absence of ties); the *tie-corrected* coefficient $\rho_c$ is the Pearson correlation of the midrank vectors.

**Definition 7 (Attainable maximum).** $\displaystyle \max\rho_u(L,M)=\max_\sigma \rho_u(\sigma)$, and similarly for $\rho_c$.

**Definition 8 (Nested profiles).** A profile $F$ *refines* a profile $C$ of the same size (equivalently, $C$ *coarsens* $F$) if every block of $C$ is a union of consecutive blocks of $F$; equivalently, every partial sum $s_j$ of $C$ is also a partial sum of $F$. Two profiles are *nested* if one refines the other. The untied profile refines every profile; every profile refines the single-block profile.

---

## 3. The two-sided tie correction

We begin with the first and second moments of a midrank vector.

**Lemma 1 (Moments of midranks).** For every profile $L$ of size $n$,
$$\sum_{i=1}^n R^L_i=\frac{n(n+1)}{2},\qquad \sum_{i=1}^n \left(R^L_i\right)^2=\frac{n(n+1)(2n+1)}{6}-\frac{T(L)}{12}.$$

*Proof sketch.* Induct on the number of blocks. Peeling off the first block $l$ of $L=(l,L')$, the midrank vector of $L$ is the constant $(l+1)/2$ on the first $l$ positions followed by $l+R^{L'}$ on the remaining $n'=n-l$ positions. Hence
$$\sum_i R^L_i=l\cdot\tfrac{l+1}{2}+l\,n'+\tfrac{n'(n'+1)}{2}=\tfrac{n(n+1)}{2}.$$
For squares, expand $(l+R^{L'}_x)^2=l^2+2lR^{L'}_x+(R^{L'}_x)^2$, use the induction hypotheses for $L'$, and add $l\big(\tfrac{l+1}{2}\big)^2$ for the first block. A direct polynomial computation shows that the result equals $\tfrac{n(n+1)(2n+1)}{6}-\tfrac{T(L')+(l^3-l)}{12}$. Conceptually: averaging the $l$ consecutive integers of a block preserves their sum and reduces their sum of squares by exactly their internal spread $\sum_{t=1}^{l}\big(t-\tfrac{l+1}{2}\big)^2=\tfrac{l^3-l}{12}$. $\square$

**Theorem 1 (Two-sided tie correction, variance form).** For every profile $L$ of size $n$,
$$\mathrm{SS}(L)=\sum_{i=1}^n\left(R^L_i-\frac{n+1}{2}\right)^2=\frac{(n^3-n)-T(L)}{12}.$$
If $n\ge 2$, equivalently $\mathrm{SS}(L)=\dfrac{n^3-n}{12}\,f(L)$.

*Proof sketch.* Expand $(R-c)^2=R^2-(n+1)R+(n+1)^2/4$, sum, and substitute Lemma 1:
$$\frac{n(n+1)(2n+1)}{6}-\frac{T(L)}{12}-(n+1)\frac{n(n+1)}{2}+\frac{n(n+1)^2}{4}=\frac{n^3-n}{12}-\frac{T(L)}{12}.$$
The second form follows by dividing by $n^3-n=n(n-1)(n+1)>0$. $\square$

**Corollary 1 (Range of the tie factor).** For every profile of size $n\ge 2$, $0\le f(L)\le 1$. Moreover $f(L)=1$ iff $L$ is untied and $f(L)=0$ iff $L=(n)$.

*Proof sketch.* Non-negativity: $\mathrm{SS}(L)\ge 0$ as a sum of squares and $(n^3-n)/12>0$, so Theorem 1 forces $f(L)\ge 0$. Upper bound: each $l^3-l=l(l-1)(l+1)\ge 0$, so $T(L)\ge 0$. The equality cases follow because $l^3-l=0$ iff $l=1$, and $\mathrm{SS}(L)=0$ iff all midranks coincide. $\square$

*Example.* For $L=(2,1,1)$, $n=4$: $R^L=(1.5,1.5,3,4)$, $T(L)=6$, $n^3-n=60$, $\mathrm{SS}(L)=9/2$ and $f(L)=9/10$. For the three-category profile $(3,4,3)$, $T=24+60+24=108$, $f=1-108/990=49/55\approx 0.8909$.

The two coefficients are related through Theorem 1: whenever $f(L),f(M)>0$,
$$\rho_c(\sigma)=\frac{\rho_u(\sigma)}{\sqrt{f(L)\,f(M)}} .\tag{1}$$

---

## 4. The product bound

**Theorem 2 (Exact product bound).** Let $L,M$ be profiles of the same size $n\ge 2$. For every pairing $\sigma$,
$$\mathrm{Cov}_\sigma(L,M)^2\le \mathrm{SS}(L)\,\mathrm{SS}(M),\qquad\text{hence}\qquad \rho_u(\sigma)^2\le f(L)\,f(M).$$

*Proof sketch.* The first inequality is Cauchy–Schwarz in $\mathbb{R}^n$ applied to $u_i=R^L_i-c$ and $v_i=R^M_{\sigma(i)}-c$:
$$\Big(\sum_i u_iv_i\Big)^2\le\sum_i u_i^2\sum_i v_i^2=\mathrm{SS}(L)\sum_i\big(R^M_{\sigma(i)}-c\big)^2=\mathrm{SS}(L)\,\mathrm{SS}(M),$$
where the last step re-indexes the sum by the bijection $\sigma$. Substituting $\mathrm{SS}(L)=\tfrac{n^3-n}{12}f(L)$ and $\mathrm{SS}(M)=\tfrac{n^3-n}{12}f(M)$ (Theorem 1) and dividing by $\big(\tfrac{n^3-n}{12}\big)^2>0$ gives $\rho_u^2\le f(L)f(M)$. $\square$

**Remark (no remainder).** The motivating conjecture allowed $\rho^2\le f(L)f(M)+O(1/n^2)$. Theorem 2 shows that the remainder is unnecessary: the bound is exact for every $n\ge 2$. In terms of (1), Theorem 2 is simply the statement $|\rho_c|\le 1$.

**Proposition 3 (Equality for identical aligned profiles).** For every profile $L$ of size $n\ge 2$, the identity pairing gives
$$\rho_u(\mathrm{id})=f(L),\qquad \rho_u(\mathrm{id})^2=f(L)\cdot f(L).$$

*Proof sketch.* With $M=L$ and $\sigma=\mathrm{id}$, $\mathrm{Cov}_{\mathrm{id}}(L,L)=\sum_i(R^L_i-c)^2=\mathrm{SS}(L)$; divide by $(n^3-n)/12$ and apply Theorem 1. $\square$

**Proposition 4 (Aligned pairing is optimal).** For all profiles $L,M$ of the same size,
$$\max_\sigma \mathrm{Cov}_\sigma(L,M)=\mathrm{Cov}_{\mathrm{id}}(L,M)=\sum_{i=1}^n\left(R^L_i-c\right)\left(R^M_i-c\right).$$

*Proof sketch.* Both $R^L$ and $R^M$ are non-decreasing. Since $\sum_i(R^L_i-c)(R^M_{\sigma(i)}-c)=\sum_i R^L_iR^M_{\sigma(i)}-n c^2$ (using Lemma 1), maximising the covariance is maximising $\sum_i R^L_iR^M_{\sigma(i)}$, and by the rearrangement inequality this is achieved by pairing the two sequences in the same order. $\square$

Consequently $\max\rho_u(L,M)$ and $\max\rho_c(L,M)$ are both computed in $O(n)$ time from the aligned midrank vectors (Algorithm A in §7).

---

## 5. Headroom factorisation fails

Call $-\log f(L)$ the *log-headroom* of $L$. The headroom-conservation conjecture asserts that $\max\rho_u^2 = f(L)\,f(M)$, possibly up to lower-order terms, so that the maximal attainable correlation is a function of the two tie factors alone and log-headrooms add. We refute it in two ways.

### 5.1 The maximum is not a function of the tie factors

**Theorem 5 (Non-factorisation).** There is no function $\Phi:[0,1]^2\to\mathbb{R}$ with $\max\rho_u(L,M)=\Phi\big(f(L),f(M)\big)$ for all pairs of profiles of equal size. Explicitly, with $n=4$,
$$f(2,1,1)=f(1,1,2)=\tfrac{9}{10},\qquad \max\rho_u\big((2,1,1),(2,1,1)\big)=\tfrac{9}{10},\qquad \max\rho_u\big((2,1,1),(1,1,2)\big)=\tfrac{4}{5}.$$

*Proof sketch.* The tie factors agree because the tie mass is invariant under reordering blocks: both profiles have $T=6$. The first maximum is Proposition 3. For the second, centred midranks are $u=(-1,-1,\tfrac12,\tfrac32)$ for $(2,1,1)$ and $v=(-\tfrac32,-\tfrac12,1,1)$ for $(1,1,2)$. By Proposition 4 the maximal covariance is the aligned one,
$$\tfrac32+\tfrac12+\tfrac12+\tfrac32=4,$$
and $(n^3-n)/12=5$, so $\max\rho_u=4/5$. Two configurations with the same pair of tie factors have different maxima, so no such $\Phi$ exists. $\square$

The mechanism is geometric: the tie factor measures *how much* a profile shrinks the rank variance, but the attainable covariance depends on *where* the shrinkage occurs. Ties at the bottom of one variable and at the top of the other cannot be aligned.

### 5.2 Block averaging and the nested-profile law

The positive result rests on a single averaging identity.

**Lemma 2 (Block averaging).** Let $F$ refine $C$. On every block $B$ of $C$, the sum of the $F$-midranks equals the sum of the $C$-midranks:
$$\sum_{i\in B} R^F_i=\sum_{i\in B} i=|B|\,R^C_B,$$
where $R^C_B$ denotes the common value of $R^C$ on $B$.

*Proof sketch.* $B$ is a union of consecutive blocks of $F$; on each of them the $F$-midranks sum to the sum of the integer positions they occupy (midranks preserve block sums). Adding over these blocks gives $\sum_{i\in B}i$, which is also $|B|R^C_B$ by definition of the midrank. $\square$

**Theorem 6 (Nested-profile law).** Let $F$ refine $C$, both of size $n\ge 2$. Then
$$\max\rho_u(F,C)=\max\rho_u(C,F)=f(C),$$
and if $f(C)>0$ (so also $f(F)\ge f(C)>0$),
$$\max\rho_c(F,C)=\sqrt{\frac{f(C)}{f(F)}} .$$

*Proof sketch.* By Proposition 4 it suffices to compute the aligned covariance. Since the centred vectors have zero sum, $\mathrm{Cov}_{\mathrm{id}}(F,C)=\sum_i (R^F_i-c)R^C_i=\sum_B R^C_B\sum_{i\in B}(R^F_i-c)$. By Lemma 2, $\sum_{i\in B}(R^F_i-c)=|B|(R^C_B-c)$, so
$$\mathrm{Cov}_{\mathrm{id}}(F,C)=\sum_B |B|\,R^C_B\,(R^C_B-c)=\sum_i R^C_i(R^C_i-c)=\mathrm{SS}(C).$$
Dividing by $(n^3-n)/12$ gives $\max\rho_u=f(C)$ (Theorem 1). For $\rho_c$, divide instead by $\sqrt{\mathrm{SS}(F)\mathrm{SS}(C)}$:
$$\max\rho_c=\frac{\mathrm{SS}(C)}{\sqrt{\mathrm{SS}(F)\mathrm{SS}(C)}}=\sqrt{\frac{\mathrm{SS}(C)}{\mathrm{SS}(F)}}=\sqrt{\frac{f(C)}{f(F)}} .$$
The inequality $f(F)\ge f(C)$ follows from Cauchy–Schwarz, $\mathrm{SS}(C)^2\le\mathrm{SS}(F)\mathrm{SS}(C)$. Symmetry in the roles of dial and response follows from Proposition 4 applied with the pairing inverted. $\square$

In log-headroom terms, for nested profiles
$$-\log\max\rho_c=\tfrac12\big[(-\log f(C))-(-\log f(F))\big],$$
a *difference* of log-headrooms, not a sum. The coarser variable is the bottleneck: refining the finer variable further leaves $\max\rho_u$ unchanged and *decreases* $\max\rho_c$.

**Corollary 7 (Untied dial).** Let the dial be untied, $L=(1,\dots,1)$, and let $M$ be any response profile of size $n\ge 2$. Then for every pairing
$$\rho_u(\sigma)\le f(M),\qquad \rho_c(\sigma)\le \sqrt{f(M)}\quad (f(M)>0),$$
with equality for the aligned pairing. In particular, if $0<f(M)<1$, then
$$\max\rho_u^2=f(M)^2<f(M)=f(L)\,f(M),$$
so the product bound of Theorem 2 is never attained.

*Proof sketch.* The untied profile refines every $M$, and $f(L)=1$; apply Theorem 6 with $F=L$, $C=M$. Strictness is $f(M)^2<f(M)$ for $0<f(M)<1$. $\square$

Corollary 7 is the sharpest form of the failure: precisely in the scenario where the conjecture was meant to be used — a dial flattened to remove its ties — the product ceiling is unattainable, and the actual ceiling for $\rho_u$ is $f(M)$, not $\sqrt{f(M)}$.

### 5.3 Numerical illustrations

| Dial profile | Response profile | $f(\text{dial})$ | $f(\text{resp})$ | $\max\rho_u$ | $\sqrt{f f}$ (product ceiling) | $\max\rho_c$ |
|---|---|---|---|---|---|---|
| $(2,1,1)$ | $(2,1,1)$ | $0.9000$ | $0.9000$ | $0.9000$ | $0.9000$ | $1.0000$ |
| $(2,1,1)$ | $(1,1,2)$ | $0.9000$ | $0.9000$ | $0.8000$ | $0.9000$ | $0.8889$ |
| $(1^{10})$ | $(3,4,3)$ | $1$ | $0.8909$ | $0.8909$ | $0.9439$ | $0.9439$ |
| $(1^{10})$ | $(1,8,1)$ | $1$ | $0.4909$ | $0.4909$ | $0.7006$ | $0.7006$ |
| $(1,2,1,1,3,2)$ | $(3,2,5)$ | $0.9636$ | $0.8485$ | $0.8485$ | $0.9042$ | $0.9384$ |

Here $(1^{n})$ denotes the untied profile. In every nested row the maximal $\rho_c$ equals $\sqrt{f(\text{coarse})/f(\text{fine})}$, and the maximal $\rho_u$ equals $f(\text{coarse})$.

---

## 6. The pooled reading

**Corollary 8 (Certificate from an observed coefficient).** Suppose the dial is untied and a coefficient $r>0$ is observed. Then:

1. if $r$ is the textbook coefficient, $f(M)\ge r$;
2. if $r$ is the tie-corrected coefficient, $f(M)\ge r^2$.

For the pooled reading $r=0.669$ this gives $f(M)\ge 0.669$, respectively $f(M)\ge 0.669^2=0.447561$.

*Proof sketch.* Immediate from Corollary 7: $r\le f(M)$, respectively $r\le\sqrt{f(M)}$. $\square$

These are distribution-free, finite-sample statements: they hold for every dataset, not merely in expectation. For orientation, equal-sized response categories on $n=120$ observations have $f(M)=0.750$ (two categories), $0.889$ (three), $0.938$ (four), $0.960$ (five), and $0.990$ (ten); a heavily concentrated response such as $(1,8,1)$ on $n=10$ has $f(M)\approx 0.491$, which is incompatible with a textbook reading of $0.669$ but compatible with a tie-corrected one.

**What does not follow.** The headroom-conservation rule would predict the $+0.045$ advantage from the response tie profile alone. Theorem 5 shows the attainable maximum depends jointly on both profiles, and Theorem 6 shows that even in the nested case the dial's factor enters (as the denominator of the ratio for $\rho_c$). The prediction from the response profile alone is valid only when the dial profile refines the response profile — for instance when the dial is untied, where Corollary 7 applies. The tie profiles underlying the pooled reading were not available to us, so the numerical value $0.045$ is not tested here; our conclusion is that the accounting must be carried out with a joint-profile bound.

---

## 7. Algorithms

**Algorithm A (Aligned ceiling).** *Input:* profiles $L,M$ of size $n$. *Output:* $\max\rho_u$, $\max\rho_c$.
1. Build $R^L,R^M$ by scanning blocks: for each block of size $l$ after $s$ observations, append $l$ copies of $s+(l+1)/2$.
2. Compute $\mathrm{Cov}=\sum_i(R^L_i-c)(R^M_i-c)$ with $c=(n+1)/2$.
3. Compute $\mathrm{SS}(L),\mathrm{SS}(M)$ by Theorem 1 directly from block sizes.
4. Return $\mathrm{Cov}/((n^3-n)/12)$ and $\mathrm{Cov}/\sqrt{\mathrm{SS}(L)\mathrm{SS}(M)}$.

Correctness is Proposition 4 plus Theorem 1; the cost is $O(n)$ time (or $O(k_L+k_M)$ by merging block boundaries). Exact rational arithmetic is available since all midranks are half-integers.

**Algorithm B (Exhaustive profile census).** *Input:* $n$. Enumerate all $2^{n-1}$ profiles of size $n$ (compositions, via bitmasks of block boundaries); for every ordered pair evaluate Algorithm A and record (i) whether $\max\rho_u^2=f(L)f(M)$, (ii) whether $\max\rho_c^2\le\min(f(L),f(M))/\max(f(L),f(M))$, and (iii) for nested pairs, whether equality holds in (ii). Cost $O(4^n n)$.

**Algorithm C (Pooled-reading certificate).** Given $r$ and the coefficient type, return the lower bound $r$ or $r^2$ on $f(M)$ and, for a candidate response profile, report whether it is consistent.

---

## 8. Computational evidence

Running Algorithm B for $2\le n\le 7$ with exact arithmetic gives:

| $n$ | pairs with $\max\rho_u^2=f(L)f(M)$ | $3\cdot 2^{n-1}-2$ | ratio-law violations | nested pairs with ratio equality |
|---|---|---|---|---|
| 2 | 4 | 4 | 0 | 1/1 |
| 3 | 10 | 10 | 0 | 7/7 |
| 4 | 22 | 22 | 0 | 31/31 |
| 5 | 46 | 46 | 0 | 115/115 |
| 6 | 94 | 94 | 0 | 391/391 |
| 7 | 190 | 190 | 0 | 1267/1267 |

(The ratio law and nested counts range over pairs with both tie factors positive.) The count $3\cdot 2^{n-1}-2$ is exactly the number of ordered pairs $(L,M)$ with $L=M$ or $L=(n)$ or $M=(n)$: there are $2^{n-1}$ pairs of each kind, and the pair $((n),(n))$ is counted three times.

---

## 9. Discussion

The results separate two questions that the headroom-conservation picture conflated.

*How much variance does each variable have?* This is answered exactly and separately by the tie factors (Theorem 1), and the product $f(L)f(M)$ is a valid universal ceiling for $\rho_u^2$ (Theorem 2). Equivalently, the tie-corrected coefficient never exceeds $1$ in absolute value.

*How much of that variance can be aligned?* This depends jointly on the profiles. For nested profiles the answer is that the coarser variable's variance is fully alignable and nothing more: covariance equals $\mathrm{SS}(\text{coarse})$, which is the projection of the fine midrank vector onto the space of vectors constant on coarse blocks. Projections shrink covariance to the retained variance, giving the ratio law.

For practitioners, Corollary 8 offers a simple diagnostic. An observed rank correlation with an untied predictor bounds the response's tie factor from below, and conversely a known response tie factor bounds the attainable correlation from above: $\rho_u\le f(M)$, $\rho_c\le\sqrt{f(M)}$. Reporting a correlation "relative to its ceiling" requires the joint profile, not two separate attenuation factors.

---

## 10. Future work

**Conjecture A (Equality characterisation of the product bound).** $\max\rho_u^2=f(L)f(M)$ if and only if $L=M$ or one of $L,M$ is a single block. Equality in Cauchy–Schwarz forces the centred aligned midrank vectors to be proportional; proportional non-decreasing step functions with midrank structure should share level sets. The census of §8 matches the predicted count $3\cdot 2^{n-1}-2$ exactly for $n\le 7$.

**Conjecture B (Meet/join formula for the aligned ceiling).** For arbitrary profiles, $12\,\mathrm{Cov}_{\mathrm{id}}(L,M)=(n^3-n)-\Phi(L,M)$ for a symmetric "interaction tie mass" $\Phi$ computed from the common refinement of $L$ and $M$ and the overlaps of their blocks, with $\Phi=T(\text{coarse})$ for nested profiles (Theorem 6). The aligned covariance admits a Kendall-type triple-sum representation $\tfrac14\sum_{i,j,k}\mathrm{sgn}(R^L_i-R^L_j)\,\mathrm{sgn}(R^M_i-R^M_k)$ (because $\sum_j\mathrm{sgn}(R^L_i-R^L_j)=2(R^L_i-c)$ for midranks), which decomposes over block overlaps.

**Conjecture C (Log-ratio headroom law).** For all profiles of equal size with positive tie factors,
$$\max\rho_c^2\le\frac{\min\big(f(L),f(M)\big)}{\max\big(f(L),f(M)\big)},$$
with equality exactly for nested profiles. The nested equality is Theorem 6; the census of §8 finds no violation for $n\le 7$.

Beyond these, natural extensions include the analogous ceiling for Kendall's tau-b, asymptotics of the joint ceiling for random profiles, and confidence statements for the certificate of Corollary 8 when profiles are only estimated.

---

## 11. Conclusion

The ceiling of Spearman's rho under ties admits an exact universal envelope, $\rho_u^2\le f(L)f(M)$, proved by Cauchy–Schwarz from an exact two-sided tie correction. But the envelope is not the ceiling: the attainable maximum is not a function of the two tie factors, and for nested profiles it is governed by a ratio, $\max\rho_c=\sqrt{f(\text{coarse})/f(\text{fine})}$. Dial and response headrooms are therefore not additive on the log scale, and accounting for an observed advantage requires a joint-profile bound.
