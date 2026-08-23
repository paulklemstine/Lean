# The Memory Knee of an Attention Profile: Grids, Dilution, and Collision Mass

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

Limited-memory inference for autoregressive attention models retains only the $k$ heaviest keys at each step, where $k$ is chosen so that the retained attention mass clears a fixed bar $\tau$. The minimal such $k$ — the **knee** of the attention profile — is estimated in practice by sweeping an arithmetic budget grid such as $\{8,16,24,32\}$. A measurement on French prose in which *no* grid point reached the bar (retention $0.9648$ at budget $24$ for context $512$; $0.9680$ at budget $32$ for context $1024$), despite full-context accuracy on French ($0.584$, $0.591$) exceeding that on English prose ($0.446$, $0.461$), motivates the following theory.

We work with an abstract attention profile $p:\mathbb{N}\to\mathbb{R}_{\ge 0}$, nonincreasing, its prefix (retained) mass $M_p(k)=\sum_{i<k}p(i)$, and its knee $K_p(\tau)=\min\{k:\tau\le M_p(k)\}$. We prove five groups of results.

1. **Grids are one-sided.** A failed probe at budget $g$ certifies $K_p(\tau)>g$ and nothing more; and for any grid ceiling $g$ and target $N>g$ there is a profile matching a reference profile's retention at every budget $k\le g$ with knee exactly $N$. Between consecutive probes $a<b$ two profiles can agree outside $(a,b)$ while having knees $a+1$ and $b$.

2. **The domain tax is multiplicative.** Under mass-preserving $r$-fold token dilution, $r(K-1)<K_{\mathrm{dil}}\le rK$, with both ends attained. Consequently no additive domain-shift law holds: for every offset $d$ there is an instance whose knee jumps by more than $d$. Dilutions form a multiplicative semigroup.

3. **The exact mechanism is a cumulative top-$K$ token count.** With variable tokens-per-word $w$ and $C_w(m)=\sum_{i<m}w(i)$, the diluted knee satisfies $C_w(K-1)<K_{\mathrm{dil}}\le C_w(K)$; bracketing by extreme ratios $L\le w\le R$ gives $L(K-1)<K_{\mathrm{dil}}\le RK$.

4. **A tokenizer-free lower bound.** With the collision (Rényi-2) mass $C_p(k)=\sum_{i<k}p(i)^2$, Cauchy–Schwarz yields $M_p(k)^2\le k\,C_p(k)$ and hence $K_p(\tau)\ge\tau^2/C$ whenever $C_p\le C$ uniformly. The bound is attained by flat profiles, and dilution divides collision mass exactly by $r$, so the same multiplicative factor $r$ is recovered without reference to any tokenizer.

5. **Design corollaries.** A geometric grid brackets the knee within a factor $2$ using $O(\log K)$ probes, whereas an arithmetic grid supplies no upper bound; and the knee of a mixture of two profiles lies between the component knees, so mixed traffic must be provisioned by the maximum, never by an average. Finally, full-context accuracy and the knee are logically independent: both orderings are simultaneously realizable.

**Keywords:** attention profile, memory knee, prefix mass, token dilution, tokens-per-word, collision mass, Rényi-2 entropy, geometric grid, budget sweep.

---

## 1. Introduction

### 1.1 The engineering setting

Autoregressive attention models maintain a cache of key–value pairs for every token processed. Its size grows linearly in context length, and it occupies the scarcest memory on the accelerator. *Limited-memory* (top-$k$ retention) inference discards all but the $k$ heaviest keys, on the empirical observation that attention distributions are concentrated: a small prefix of the sorted attention weights carries almost all the mass.

Choosing $k$ is a measurement problem. One fixes a **retention bar** $\tau$ — a fraction of total attention mass deemed sufficient — and looks for the smallest budget clearing it. Because each evaluation is expensive, one evaluates at a small number of budgets: a *grid sweep*, usually arithmetic, e.g. $\{8, 16, 24, 32\}$.

### 1.2 The measurement that motivated this work

A characterization campaign had established knees inside such grids for English prose, source code, and mathematical text, with domain-to-domain differences of about $\pm 4$ keys — one fine step of the grid. This suggested an additive "domain shift" rule: change the domain, adjust the budget by a fine step.

A subsequent cell moved to French prose. The result:

| context | best grid point | retained mass | verdict |
|---|---|---|---|
| $512$ | $24$ | $0.9648$ | bar not met; knee $>24$ |
| $1024$ | $32$ | $0.9680$ | bar not met; knee $>32$ |

Full-context accuracy on French was $0.584$ and $0.591$, *higher* than English prose's $0.446$ and $0.461$. Every pre-registered additive bracket was refuted: the shift exceeded $+8$ keys, escaping the grid entirely.

Two questions follow. What, exactly, does a failed sweep license one to conclude? And what functional form does a domain shift actually take? This paper answers both, and derives the corresponding experimental-design correction.

### 1.3 Contributions and organization

Section 2 fixes the abstract model. Section 3 establishes the one-sidedness of grid sweeps and two underdetermination theorems. Section 4 develops uniform token dilution and the multiplicative dilution law, and refutes all additive laws. Section 5 handles variable tokenization and gives the exact cumulative-count form of the mechanism. Section 6 develops the collision-mass lower bound, its sharpness, and its behaviour under dilution, giving a second, tokenizer-free derivation of the multiplicative factor. Section 7 draws the design corollaries: geometric grids, mixture provisioning, and the accuracy/knee decoupling. Section 8 gives algorithms; Section 9 discusses limitations and future work.

---

## 2. The model

Throughout, $\tau \in \mathbb{R}$ denotes a retention bar and $p:\mathbb{N}\to\mathbb{R}$ an attention profile.

> **Definition 2.1 (Attention profile).** An *attention profile* is a function $p:\mathbb{N}\to\mathbb{R}$ with $p(i)\ge 0$ for all $i$; it is *sorted* when it is antitone, $i\le j \Rightarrow p(j)\le p(i)$. The value $p(i)$ is the attention mass carried by the $i$-th heaviest key.

Sortedness is a modelling convenience; almost every result below needs only nonnegativity, and we flag the exceptions.

> **Definition 2.2 (Retained / prefix mass).** For $k\in\mathbb{N}$, the *retained mass* at budget $k$ is $M_p(k)=\sum_{i<k}p(i)$.

Two immediate facts are used constantly: $M_p(k+1)=M_p(k)+p(k)$, and, when $p\ge 0$, $M_p$ is monotone nondecreasing. Retained mass is additive in $p$ and homogeneous: $M_{p+q}=M_p+M_q$ and $M_{cp}=c\,M_p$.

> **Definition 2.3 (Knee).** The *knee* of $p$ at bar $\tau$ is
> $$K_p(\tau)=\inf\{k\in\mathbb{N}: \tau\le M_p(k)\},$$
> the least budget meeting the bar (the infimum of a set of naturals, taken to be $0$ if the set is empty).

Three characterizing properties follow directly from the definition of a least element and are used throughout:

* **(K1) Upper bound from a witness.** If $\tau\le M_p(k)$ then $K_p(\tau)\le k$.
* **(K2) The knee meets the bar.** If some $k$ has $\tau\le M_p(k)$, then $\tau\le M_p(K_p(\tau))$.
* **(K3) Minimality.** If $k<K_p(\tau)$ then $M_p(k)<\tau$.

Together, (K1)–(K3) give a characterization: if $\tau\le M_p(\kappa)$ and $M_p(j)<\tau$ for all $j<\kappa$, then $K_p(\tau)=\kappa$.

**Calibration objects.** Three families of profiles serve as extremal examples.

* The *flat profile* $u_n(i)=\mathbf{1}[i<n]$, with $M_{u_n}(k)=\min(k,n)$.
* The *scaled flat profile* $s_{c,n}=c\,u_n$, with $M_{s_{c,n}}(k)=c\min(k,n)$; its knee, for $\kappa\le n$, equals $\kappa$ precisely when $\tau\le c\kappa$ and $cj<\tau$ for all $j<\kappa$.
* The *two-level profile* $T_{g,N,c}=u_g+c\,(u_N-u_g)$ for $g\le N$ and $0\le c\le 1$: height $1$ on the first $g$ keys, height $c$ on keys $g,\dots,N-1$, then $0$. It is nonnegative and antitone, and
  $$M_{T_{g,N,c}}(k)=\min(k,g)+c\,\bigl(\min(k,N)-\min(k,g)\bigr).$$

---

## 3. What a grid sweep certifies

### 3.1 The one-sided gate

> **Theorem 3.1 (Grid lower bound).** Let $p\ge 0$, suppose the bar is attainable ($\exists k,\ \tau \le M_p(k)$), and suppose a probe fails: $M_p(g)<\tau$. Then $g<K_p(\tau)$.

*Proof.* Suppose $K_p(\tau)\le g$. By (K2), $\tau\le M_p(K_p(\tau))$, and by monotonicity of $M_p$ (using $p\ge 0$), $M_p(K_p(\tau))\le M_p(g)<\tau$ — a contradiction. $\square$

> **Corollary 3.2 (Whole-grid version).** If $G$ is a nonempty finite grid and every $g\in G$ fails the bar, then $\max G<K_p(\tau)$.

> **Corollary 3.3 (The measured cell).** For the grid $\{8,16,24,32\}$ with all four probes below the bar and the bar attainable, $K_p(\tau)\ge 33$.

Corollary 3.3 is the *entire* content of the French measurement at context $1024$. It is a lower bound. Nothing about the magnitude of the excess is licensed. The next two theorems show this is not conservatism but the exact truth.

### 3.2 Underdetermination above the grid

> **Theorem 3.4 (Grid underdetermination).** Let $g<N$ and set $\tau=g+1$. There exists a nonnegative antitone profile $p$ with:
> 1. $M_p(k)=k$ for every $k\le g$;
> 2. $M_p(k)<g+1$ for every $k\le g$;
> 3. $M_p(k)=g+1$ for every $k\ge N$;
> 4. $K_p(g+1)=N$ exactly.

*Proof sketch.* Take $p=T_{g,N,c}$ with $c=1/(N-g)$; note $0<c\le 1$ because $g+1\le N$. For $k\le g$ the retention formula gives $M_p(k)=k<g+1$, establishing (1) and (2). For $k\ge N$ it gives $M_p(k)=g+c(N-g)=g+1$, which is (3). For $g\le j<N$ we have $M_p(j)=g+c(j-g)=g+(j-g)/(N-g)<g+1$, so no budget below $N$ meets the bar; and $M_p(N)=g+1$ meets it. By the characterization (K1)–(K3), $K_p(g+1)=N$. $\square$

Since (1) fixes the retention at *every* budget up to the grid ceiling, all these profiles — one for each $N>g$ — are literally indistinguishable to any sweep confined to $\{0,\dots,g\}$, while their knees range over all of $\{g+1, g+2, \dots\}$. Formally:

> **Corollary 3.5 (No upper bound from an arithmetic grid).** For every ceiling $g$ and every bound $B$ there are nonnegative antitone profiles $p,q$ with $M_p(k)=M_q(k)$ for all $k\le g$, $K_p(g+1)=g+1$, and $K_q(g+1)>B$.

### 3.3 Underdetermination inside a gap

Even successful sweeps are limited by the coarseness of the grid.

> **Theorem 3.6 (Gap ambiguity).** Let $a<b$. There exist nonnegative antitone profiles $p,q$ such that $M_p(k)=M_q(k)$ for all $k\le a$ and for all $k\ge b$, while $K_p(a+1)=a+1$ and $K_q(a+1)=b$.

*Proof sketch.* Take $p=u_{a+1}$ and $q=T_{a,b,1/(b-a)}$ from Theorem 3.4 with $g=a$, $N=b$. Below $a$, both retain $k$; above $b$, both retain $a+1$. The knees are $a+1$ and $b$. $\square$

**Consequence.** A grid whose consecutive probes are $a<b$ cannot certify a bracket tighter than the *ratio* $b/(a+1)$. This identifies ratio, not difference, as the natural resolution parameter of a sweep — the first hint that the whole problem is multiplicative.

---

## 4. Uniform token dilution and the multiplicative law

### 4.1 The dilution operator

The hypothesized mechanism behind the French anomaly is tokenization: the tokenizer spends more tokens per word, so the attention mass associated with one semantic unit is spread across several keys.

> **Definition 4.1 (Uniform token dilution).** For $r\ge 1$, the $r$-fold dilution of $p$ is
> $$(D_r p)(j)=\frac{p(\lfloor j/r\rfloor)}{r}.$$
> Each semantic unit $i$ is spelt with $r$ tokens, each carrying an equal share $p(i)/r$ of the unit's mass.

Dilution preserves the class of profiles: if $p\ge 0$ then $D_rp\ge 0$, and if $p$ is antitone then so is $D_r p$ (weights are constant within a word and nonincreasing across words, since $a\le b$ implies $\lfloor a/r\rfloor\le\lfloor b/r\rfloor$).

> **Lemma 4.2 (Mass preservation on whole words).** For $r\ge 1$ and $m\in\mathbb{N}$, $M_{D_rp}(rm)=M_p(m)$.

*Proof sketch.* Induction on $m$. The block $[rm, rm+r)$ contributes $r$ copies of $p(m)/r$, i.e. exactly $p(m)$, and $M_{D_rp}(r(m+1))=M_{D_rp}(rm)+p(m)$. $\square$

> **Lemma 4.3 (Partial words).** For $0\le s\le r$, $M_{D_rp}(rm+s)=M_p(m)+s\,p(m)/r$: within a word the retained mass grows linearly in the number of its tokens kept.

### 4.2 The dilution law

> **Theorem 4.4 (Dilution law).** Let $r\ge 1$, $p\ge 0$, the bar attainable, and $K=K_p(\tau)>0$. Then
> $$r(K-1)\;<\;K_{D_rp}(\tau)\;\le\;rK .$$

*Proof.* Upper: by Lemma 4.2, $M_{D_rp}(rK)=M_p(K)\ge\tau$ by (K2), so (K1) gives $K_{D_rp}(\tau)\le rK$. Lower: $M_{D_rp}(r(K-1))=M_p(K-1)<\tau$ by (K3) since $K-1<K$; the bar is attainable for $D_rp$ (witness $rK$), so Theorem 3.1 gives $r(K-1)<K_{D_rp}(\tau)$. $\square$

> **Theorem 4.5 (Both ends are attained).** For $r\ge1$ and $m\le n$:
> * (upper) with $p=u_n$ and $\tau=m$ one has $K_p(\tau)=m$ and $K_{D_rp}(\tau)=rm$;
> * (lower) a flat profile with a suitably lowered bar attains $K_{D_rp}(\tau)=r(K-1)+1$.

*Proof sketch.* By Lemma 4.2, $D_r u_n=s_{1/r,\,rn}$, the flat profile of height $1/r$ on $rn$ keys. Its knee at bar $\tau$ is the least $\kappa$ with $\kappa/r\ge\tau$, i.e. $\lceil r\tau\rceil$; choosing $\tau=m$ gives $rm$, and choosing a bar just above $(K-1)$ gives $r(K-1)+1$. $\square$

So the sandwich in Theorem 4.4 is optimal as a function of $r$ and $K$ alone: neither endpoint can be improved.

### 4.3 Refutation of additive laws

> **Theorem 4.6 (No additive domain-shift law).** For every $d\in\mathbb{N}$ there exist a nonnegative antitone profile $p$, a bar $\tau$ with the bar attainable, and $r\ge1$ such that
> $$K_p(\tau)+d\;<\;K_{D_rp}(\tau).$$

*Proof.* Take $p=u_{d+2}$, $\tau=d+2$, $r=d+2$. Then $K_p(\tau)=d+2$, and by Theorem 4.5 (upper), $K_{D_rp}(\tau)=r(d+2)=(d+2)^2$. Since $(d+2)^2 > (d+2)+d$ for all $d\ge 0$, the claim holds. $\square$

This is the formal refutation of the "$\pm 4$ fine-step" rule. It was not a bad fit to the four-domain table; it was the wrong *functional form*, and an additive form fitted to ratios near $1$ gives no information about a domain whose ratio is not near $1$.

### 4.4 Composition

> **Theorem 4.7 (Dilution semigroup).** $D_r\circ D_s=D_{rs}$ for all $r,s\ge 1$.

*Proof.* $(D_r(D_sp))(j)=(D_sp)(\lfloor j/r\rfloor)/r = p(\lfloor \lfloor j/r\rfloor/s\rfloor)/(rs) = p(\lfloor j/(rs)\rfloor)/(rs)$, using $\lfloor\lfloor j/r\rfloor/s\rfloor=\lfloor j/(rs)\rfloor$. $\square$

> **Corollary 4.8.** $K_{D_{rs}p}(\tau)\le r\,(s\,K_p(\tau))$: composite domain shifts pay the *product* of the individual taxes.

### 4.5 Budget conversion

> **Proposition 4.9.** For $r\ge1$, $p\ge0$ and any budget $g$: $M_{D_rp}(g)\le M_p(\lfloor g/r\rfloor+1)$.

*Proof.* $g\le r(\lfloor g/r\rfloor+1)$, so monotonicity and Lemma 4.2 give $M_{D_rp}(g)\le M_{D_rp}(r(\lfloor g/r\rfloor +1))=M_p(\lfloor g/r\rfloor+1)$. $\square$

Read operationally: dilution converts a *token* budget into a *word* budget of roughly $g/r$. A fixed grid measured in tokens shrinks, in semantic terms, by the factor $r$ — a direct account of why the French sweep failed at $32$ while the English sweep succeeded well below it.

---

## 5. Variable tokenization: the exact mechanism

Real tokenizers assign different token counts to different words. Let $w:\mathbb{N}\to\mathbb{N}$ with $w(i)\ge1$ be the *tokens-per-word profile* and
$$C_w(m)=\sum_{i<m}w(i)$$
its cumulative count ($C_w$ is monotone and $m\le C_w(m)$).

> **Definition 5.1 (Variable dilution).** Word $i$ occupies the token block $[C_w(i),\,C_w(i+1))$; the variable dilution is
> $$(V_wp)(j)=\frac{p(\omega(j))}{w(\omega(j))},\qquad \omega(j)=\min\{m: j<C_w(m+1)\},$$
> where $\omega(j)$ is the word containing token $j$.

The block $[C_w(m), C_w(m)+w(m))$ consists precisely of the tokens with $\omega=m$, each of mass $p(m)/w(m)$, so the block sums to $p(m)$, whence:

> **Lemma 5.2 (Mass preservation).** $M_{V_wp}(C_w(m))=M_p(m)$ for all $m$.

> **Theorem 5.3 (Variable dilution law).** Let $w\ge1$ pointwise, $p\ge0$, the bar attainable, and $K=K_p(\tau)>0$. Then
> $$C_w(K-1)\;<\;K_{V_wp}(\tau)\;\le\;C_w(K).$$

*Proof.* By Lemma 5.2, $M_{V_wp}(C_w(K))=M_p(K)\ge\tau$, giving the upper bound by (K1). Also $M_{V_wp}(C_w(K-1))=M_p(K-1)<\tau$ by (K3), and the bar is attainable for $V_wp$, so Theorem 3.1 gives the strict lower bound. $\square$

**Interpretation and the sharp prediction.** The diluted knee equals, up to the width of one word, *the number of tokens the tokenizer spends on the top-$K$ attended words*. The correct predictor is therefore not the corpus-average tokens-per-word but the average restricted to the top-$K$ attention words:
$$K_{V_wp}(\tau)\approx \overline{w}_{\mathrm{top}\text{-}K}\cdot K,\qquad \overline{w}_{\mathrm{top}\text{-}K}=\frac{C_w(K)}{K}.$$
These two quantities diverge exactly when attention concentrates on words of atypical token cost. In French, accented and elided high-frequency function words carry both high attention and high token cost, so the top-$K$ average should exceed the corpus average — a discriminating, falsifiable prediction requiring only one extra logging line in a sweep.

Bracketing by the extreme ratios:

> **Corollary 5.4 (Ratio band).** If $L\le w(i)\le R$ for all $i$, then $L(K-1)<K_{V_wp}(\tau)\le RK$.

*Proof.* $Lm\le C_w(m)\le Rm$ by induction; combine with Theorem 5.3. $\square$

Two languages whose ratio bands are disjoint enough — precisely, when $L(K-1)\ge R'K'$ for the second language's band and knee — have knees separated by whole grid ranges. This is the formal content of "language families differ by whole grid ranges."

> **Proposition 5.5 (Consistency).** For constant $w\equiv r$ with $r\ge1$, $V_wp=D_rp$, and Theorem 5.3 specializes to Theorem 4.4.

---

## 6. Collision mass: a tokenizer-free lower bound

The dilution account is mechanistic and requires access to the tokenizer. We now give an independent route to the same scaling that requires only the attention numbers.

> **Definition 6.1 (Collision mass).** The *collision mass* (Rényi-2 mass) of the top $k$ keys is
> $$C_p(k)=\sum_{i<k}p(i)^2.$$

$C_p$ is monotone in $k$. For a probability vector, $C_p(\infty)$ is the collision probability; its reciprocal is the Rényi-2 effective support size. Small collision mass means flat, high-entropy attention; large means peaked.

> **Theorem 6.2 (Cauchy–Schwarz for attention budgets).** For all $p$ and $k$, $M_p(k)^2\le k\cdot C_p(k)$.

*Proof.* Apply the Cauchy–Schwarz inequality on $\{0,\dots,k-1\}$ to the constant vector $1$ and to $p$: $\bigl(\sum_{i<k}1\cdot p(i)\bigr)^2\le\bigl(\sum_{i<k}1\bigr)\bigl(\sum_{i<k}p(i)^2\bigr)=k\,C_p(k)$. $\square$

> **Theorem 6.3 (Entropy bound on the knee).** Let $\tau>0$, $C>0$, suppose $C_p(k)\le C$ for all $k$, and suppose the bar is attainable. Then
> $$\frac{\tau^2}{C}\;\le\;K_p(\tau).$$

*Proof.* Write $\kappa=K_p(\tau)$. By (K2), $\tau\le M_p(\kappa)$, and since $\tau>0$, $\tau^2\le M_p(\kappa)^2$. By Theorem 6.2, $M_p(\kappa)^2\le \kappa\,C_p(\kappa)\le \kappa C$. Hence $\tau^2\le \kappa C$, i.e. $\tau^2/C\le\kappa$. $\square$

No tokenizer, no linguistic labels, no domain identity: only the flatness of the observed attention. Flat attention *forces* a large knee.

> **Theorem 6.4 (Sharpness).** Let $n\ge 1$ and take the flat probability profile $s_{1/n,\,n}$. Then $C_{s_{1/n,n}}(k)\le 1/n$ for all $k$; the knee at bar $\tau=1$ is exactly $n$; and $\tau^2/C=1^2/(1/n)=n$.

*Proof sketch.* $C_{s_{c,n}}(k)=c^2\min(k,n)$, so with $c=1/n$ this is at most $n^{-2}\cdot n=1/n$. For the knee: $M(k)=\min(k,n)/n$, which first reaches $1$ at $k=n$. $\square$

Equality holds, so **no function of the collision mass yields a bound better than $\tau^2/C$**.

### 6.1 Dilution divides collision mass exactly

> **Theorem 6.5.** For $r\ge1$ and all $m$: $C_{D_rp}(rm)=C_p(m)/r$.

*Proof sketch.* Induction on $m$. The block $[rm,rm+r)$ contributes $r$ copies of $(p(m)/r)^2$, i.e. $p(m)^2/r$. $\square$

> **Corollary 6.6 (Uniform bound under dilution).** If $C_p(k)\le C$ for all $k$, then $C_{D_rp}(k)\le C/r$ for all $k$.

*Proof.* Given $k$, put $m=\lfloor k/r\rfloor+1$, so $k\le rm$. By monotonicity and Theorem 6.5, $C_{D_rp}(k)\le C_{D_rp}(rm)=C_p(m)/r\le C/r$. $\square$

> **Theorem 6.7 (The entropy route reproduces the multiplicative law).** Under the hypotheses of Theorem 6.3, for $r\ge 1$ and the bar attainable for $D_rp$,
> $$r\cdot\frac{\tau^2}{C}\;\le\;K_{D_rp}(\tau).$$

*Proof.* By Corollary 6.6, $C/r$ is a uniform collision bound for $D_rp$; apply Theorem 6.3 with this bound and rewrite $\tau^2/(C/r)=r\,\tau^2/C$. $\square$

**Two independent derivations of one law.** Theorem 4.4 obtained the factor $r$ from the tokenizer; Theorem 6.7 obtains the same $r$ from flatness alone. The agreement is a structural consistency check on the whole account, and it upgrades the mechanism hypothesis into something measurable from attention maps with no tokenizer in the loop: the French cell should exhibit a *smaller* collision mass than the English cell at the same context, and the collision-mass ratio should track the knee ratio.

---

## 7. Design consequences

### 7.1 Geometric grids are adequate; arithmetic grids are not

> **Theorem 7.1 (Geometric grid brackets the knee).** Let $p\ge0$ and let the bar be attainable. Let $S=\min\{i:\tau\le M_p(2^i)\}$ (well defined, since $k\le 2^k$ and $M_p$ is monotone). Then
> $$K_p(\tau)\le 2^S,\qquad\text{and}\qquad S>0\ \Rightarrow\ 2^S<2\,K_p(\tau).$$

*Proof.* The first claim is (K1) applied to the witness $2^S$. For the second, minimality of $S$ gives $M_p(2^{S-1})<\tau$, so Theorem 3.1 yields $2^{S-1}<K_p(\tau)$; multiply by $2$ and use $2\cdot 2^{S-1}=2^S$. $\square$

Thus a geometric sweep returns a **two-sided** bracket of ratio $2$, using $\lceil\log_2 K\rceil+1$ probes. A multiplicative tax of factor $r$ shifts $S$ by only $\log_2 r$: it translates along the instrument rather than escaping it. Contrast:

> **Theorem 7.2 (Arithmetic grids give no upper bound).** Restatement of Corollary 3.5: for every arithmetic ceiling $g$ and every $B$, two profiles indistinguishable on all budgets $\le g$ can have knees $g+1$ and $>B$.

Combined with the resolution limit of Theorem 3.6 — no grid certifies better than the ratio $b/(a+1)$ of consecutive probes — the geometric grid is *optimal in form*: it attains ratio $2$ everywhere at logarithmic cost. Six geometric probes reach budget $64$, more than the four arithmetic probes that reached $32$ and returned only a lower bound.

**Recommendation.** Replace arithmetic budget grids by geometric ones in all budget characterization. The change reduces cost and converts information-free "knee $>32$" verdicts into two-sided brackets.

### 7.2 Mixed traffic: budget by the maximum

Multilingual serving sees a mixture of domains. Mixing is affine on retention:

> **Proposition 7.3.** $M_{sp+(1-s)q}(k)=s\,M_p(k)+(1-s)\,M_q(k)$.

> **Theorem 7.4 (Mixture law).** Let $p,q\ge0$, $0\le s\le1$, and let the bar be attainable for both. Then
> $$\min\bigl(K_p(\tau),K_q(\tau)\bigr)\;\le\;K_{sp+(1-s)q}(\tau)\;\le\;\max\bigl(K_p(\tau),K_q(\tau)\bigr).$$

*Proof sketch.* Upper: at budget $\max(K_p,K_q)$ both components already meet the bar, hence so does any convex combination; apply (K1). Lower: at any budget $k<\min(K_p,K_q)$ both components are strictly below the bar by (K3), hence so is the combination, so the knee cannot be smaller. $\square$

Since Theorem 4.6 forbids interpolating budgets *between* domains, Theorem 7.4 is the correct provisioning rule: the mixture knee can be as large as the worst component's, so **provision by the maximum, never by an average or a traffic-weighted mean.**

### 7.3 Accuracy and knee are logically independent

Full-context accuracy is sometimes used as a proxy for how much memory a domain needs ("harder domains need more keys"). The measurements refute this in both directions: code is easier and cheaper; French is easier and dearer. This is not accidental.

> **Definition 7.5 (Domain cell).** A *domain cell* is a pair consisting of a full-context accuracy $a\in\mathbb{R}$ and a sorted attention profile $p\ge0$; its knee at $\tau$ is $K_p(\tau)$.

> **Theorem 7.6 (Accuracy/knee decoupling, both signs).** There exist four domain cells $D_1,D_2,D_3,D_4$ with only two distinct accuracy values, $a(D_1)=a(D_3)<a(D_2)=a(D_4)$, such that
> $$K_{D_1}(1)<K_{D_2}(1)\qquad\text{and}\qquad K_{D_4}(1)<K_{D_3}(1).$$

*Proof.* Use two profiles: $A=s_{1,4}$ (flat height $1$ on four keys), with $K_A(1)=1$; and $B=s_{1/2,4}$, with $K_B(1)=2$. Set $D_1=(0,A)$, $D_2=(1,B)$, $D_3=(0,B)$, $D_4=(1,A)$. Then $K_{D_1}=1<2=K_{D_2}$ (higher accuracy, larger knee) and $K_{D_4}=1<2=K_{D_3}$ (higher accuracy, smaller knee). $\square$

Hence **no function** — in particular no monotone one — maps full-context accuracy to the memory knee. The two quantities measure different things: accuracy measures how predictable the text is, the knee measures how concentrated the attention is. A serving system that budgets memory by a quality metric is budgeting by an unrelated statistic.

---

## 8. Algorithms

### 8.1 Geometric knee bracketing

Given an oracle for $M_p(k)$ (in practice, a retention evaluation at budget $k$), find a two-sided bracket for $K_p(\tau)$.

```
Input: retention oracle M, bar tau, cap Kmax
S <- 0
while 2^S <= Kmax and M(2^S) < tau:
    S <- S + 1
if M(2^S) < tau: return ("knee > Kmax", unbounded above)
lo <- (2^(S-1) + 1) if S > 0 else 1
hi <- 2^S
return (lo, hi)          # hi < 2 * knee whenever S > 0
```

Cost: $\lceil\log_2 K\rceil+1$ oracle calls; guarantee: ratio-$2$ bracket (Theorem 7.1). An optional binary refinement inside $[lo, hi]$ costs a further $\lceil\log_2(hi-lo)\rceil$ calls and returns the exact knee, exploiting monotonicity of $M_p$.

### 8.2 Top-$K$ tokens-per-word prediction

Given an undiluted (word-level) profile knee $K$ and the tokenizer's counts $w(i)$ for the top attended words, predict the diluted knee bracket.

```
Input: word counts w[0..K-1], undiluted knee K
lower <- sum(w[0..K-2])           # C_w(K-1)
upper <- sum(w[0..K-1])           # C_w(K)
return (lower + 1, upper)          # C_w(K-1) < knee <= C_w(K)
```

Cost: $O(K)$ after one tokenizer pass. This is the operational form of Theorem 5.3, and it is what discriminates the top-$K$ average from the corpus average.

### 8.3 Collision-mass floor

Given measured attention weights (sorted, nonnegative) and a bar, compute the tokenizer-free floor.

```
Input: sorted weights p[0..n-1], bar tau
C <- max over k of sum_{i<k} p[i]^2      # = sum of all squares if p >= 0
floor <- tau^2 / C
return ceil(floor)                        # knee >= tau^2 / C
```

Cost: $O(n)$. By Theorem 6.4 this is the best possible bound expressible in terms of the collision mass; by Theorem 6.7 it scales by $r$ under $r$-fold dilution.

---

## 9. Discussion

### 9.1 What the measurement did and did not establish

Honestly stated, the French cell establishes exactly: *the knee is at least $33$ at context $1024$, and at least $25$ at context $512$*, and, jointly with the earlier cells, that no additive offset of $\pm4$ or even $+8$ describes the shift. Theorem 3.4 shows that the size of the excess is not merely unmeasured but *unmeasurable* by the instrument used. The correct response is to change the instrument (Section 7.1), not to interpolate.

**Limitations of the empirical basis.** The French cell rests on a single corpus source (a second intended source was unavailable), so the corpus-level generalization is weaker than the four-domain baseline. All theorems in this paper are unconditional statements about attention profiles and are unaffected by that limitation; only the identification of French with a large tokens-per-word ratio depends on it.

### 9.2 Why an additive law appeared to hold

The four earlier domains all had tokenization ratios close to one another. Where $r\approx r'$, Theorem 4.4 gives $K'\approx (r'/r)K$, and for $K$ within a narrow range a multiplicative factor near $1$ is empirically indistinguishable from a small additive offset. The additive law was a local linearization of a multiplicative law, valid in a neighbourhood and catastrophically wrong outside it — the offset it predicts scales with $K$, while the true shift scales with $rK$.

### 9.3 Two mechanisms, one exponent

It is worth stressing the structure of Sections 4–6. The tokenization route derives the factor $r$ from a *combinatorial* fact (mass-preserving splitting of blocks). The collision-mass route derives the same factor from an *analytic* fact (Cauchy–Schwarz plus exact scaling of the Rényi-2 mass). They share no lemmas beyond the definition of the knee. A theory whose central exponent survives two disjoint derivations is far more likely to describe the phenomenon than one supported by a fitted table.

### 9.4 Relation to concentration measures

The collision mass is the $\ell_2$ mass, so $\tau^2/C$ is essentially a statement that the *effective support size* of the attention distribution lower-bounds the budget. Because the bound is exactly attained by the uniform profile, refinements must use more than the second moment — e.g. the full Rényi spectrum or the shape of the sorted tail. That is a natural direction: a bound in terms of $C_p(k)$ *as a function of $k$* rather than a uniform cap should be strictly stronger for peaked-plus-heavy-tail profiles, which is what real attention looks like.

---

## 10. Future work

1. **Top-$K$ tokens-per-word test.** Log, for each evaluation, the tokenizer's token count for the top-$K$ attended words and compare $C_w(K)$ with the observed knee (Theorem 5.3). This discriminates decisively between the corpus-average predictor and the top-$K$ predictor, and the two diverge in exactly the regime — attention concentrated on rare or accented words — the French cell inhabits.

2. **Adopt geometric grids.** Replace $\{8,16,24,32\}$ with $\{1,2,4,8,16,32,64\}$: fewer probes reach a higher ceiling, and every verdict becomes a two-sided bracket rather than an unbounded lower bound (Theorems 7.1, 7.2).

3. **Collision mass as a domain-free predictor.** Measure $C_p$ directly from attention maps in each domain and test whether $\tau^2/C$ tracks the observed knee ordering across domains and languages. Because this requires no tokenizer, it applies to modalities where "word" is undefined.

4. **More languages and larger models.** Extend the language panel beyond French; test whether the ratio bands of Corollary 5.4 separate language families as predicted, and whether the multiplicative law persists at larger model scale.

5. **Beyond the second moment.** Seek knee bounds using the full profile of $C_p(k)$ or higher Rényi masses, aiming for two-sided estimates rather than a lower bound.

6. **Mixed-traffic provisioning in practice.** Validate Theorem 7.4 on genuinely mixed multilingual traffic and quantify the cost of max-provisioning against the (unsound but tempting) traffic-weighted average.

---

## 11. Conclusion

The knee of an attention profile — the smallest key budget retaining a prescribed share of attention mass — is a multiplicative quantity. It scales with the number of tokens a tokenizer spends on the words a model actually attends to; it is bounded below by $\tau^2/C$ where $C$ caps the collision mass of the attention distribution; and it composes multiplicatively under successive domain shifts. Arithmetic budget grids are therefore the wrong instrument: they can be escaped, and once escaped they certify a lower bound and provably nothing more. Geometric grids cannot be escaped and always return a factor-two bracket at logarithmic cost. Finally, full-context accuracy carries no information about the knee, in the strong sense that both orderings between them are simultaneously realizable.

A failed sweep on French prose is, read correctly, not a gap in a table. It is evidence that the table had the wrong shape.
