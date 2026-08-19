# The Price of Universality: An Exact Non-Asymptotic Theory of Minimax Redundancy

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

A universal compression scheme must commit to a single decompressor — equivalently,
to a single coding distribution — before learning which of a family of possible
sources generated the data. The *price of universality* is the redundancy this
commitment forces, measured against a scheme that knows the source. We develop an
exact, non-asymptotic theory of this price for finite families of sources on finite
message spaces.

Our central result is a fully constructive proof of the **redundancy–capacity
theorem**: the minimax average redundancy of a finite family
$\{p_\theta\}_{\theta\in\Theta}$ of strictly positive sources equals the *capacity*
$C=\max_w I(w)$ of the associated channel from parameter to message, the maximum
being over priors on $\Theta$. The proof avoids any appeal to a minimax theorem; it
combines a compensation identity, compactness of the simplex, and a first-order
perturbation of the optimal prior controlled by a $\chi^2$ bound on relative
entropy. As corollaries we obtain the equalizer property of the optimal prior, a
verification criterion for optimality, and the **uniqueness of the optimal Bayes
mixture**.

We then determine the structure of the price. It is strictly positive for any
non-degenerate family; monotone under passage to subfamilies; bounded above by both
$\log_2|\Theta|$ and the worst-case (Shtarkov) price $\log_2 C_S$; and *additive*
over independent blocks, $C(S\otimes T)=C(S)+C(T)$. For unknown-offset classes over
a finite abelian group we obtain the closed forms $C=\log_2|A|-H(p_0)$ and
$\log_2 C_S=\log_2|A|-H_\infty(p_0)$, so the gap between the average-case and
worst-case prices is exactly $H(p_0)-H_\infty(p_0)$; an explicit two-source class
realises a gap of $\tfrac14\log_2 3$ bits. Merging $K$ specialised classes into one
universal scheme costs at most $\log_2 K$ bits, and never less than the worst
specialised price.

For front ends we prove an exact chain rule $D(p\|q)=D(f_*p\|f_*q)+D(p\|q\mid f)$
and show that the within-fibre defect vanishes if and only if the parse $f$ is a
sufficient statistic in the Fisher–Neyman sense: **a front end loses no bits exactly
when it computes a sufficient statistic**, and the price of universality is a
function of the sufficient statistic alone. Cashing this in yields Rissanen-style
rates: $C\le|A|\log_2(n+1)$ for memoryless families and
$C\le\log_2|A|+|A|^2\log_2(n+1)$ for Markov families on messages of length $n$.
Finally, an explicit Chebyshev packing of $\lfloor\sqrt n/4\rfloor$ Bernoulli
parameters yields the matching lower bound
$\tfrac{15}{32}\log_2 n-8\le C\le\log_2(n+1)$ for all $n\ge 64$, bracketing the
Rissanen constant of a one-parameter family between $15/32$ and $1$.

We conclude that specialisation can move only $O(\log n)$ bits from the message into
the shared decompressor, and that the productive engineering lever is not more
specialised decompressors but sufficient parses.

**Keywords:** universal compression, minimax redundancy, redundancy–capacity
theorem, channel capacity, Bayes mixture, sufficient statistic, Rissanen rate,
Shtarkov sum, min-entropy.

---

## 1. Introduction

### 1.1 The problem

A compressed file is meaningless without a decompressor, and the decompressor is
shared: one program must serve all inputs. A decompressor specialised to a class of
data — English prose, genomic reads, sensor logs — encodes prior knowledge and
therefore produces shorter files on that class. The **price of universality** is the
number of bits per message that a single shared scheme must waste, relative to a
scheme specialised to the true source.

Formally, fix a finite message space $X$ and a family of sources
$\mathcal S=\{p_\theta:\theta\in\Theta\}$, $\Theta$ finite, each $p_\theta$ a
probability distribution on $X$. A *coding distribution* is a probability
distribution $q$ on $X$; the ideal codeword length it assigns to $x$ is
$\log_2(1/q(x))$, and by the Kraft inequality this correspondence between coding
distributions and prefix codes is essentially exact (Section 6). The redundancy of
$q$ against the source $p_\theta$ is the relative entropy

$$D(p_\theta\,\|\,q)=\sum_{x\in X}p_\theta(x)\log_2\frac{p_\theta(x)}{q(x)},$$

the average number of bits per message wasted by coding $p_\theta$-data with $q$.
The price of universality is the minimax value

$$R^\star(\mathcal S)=\min_{q}\max_{\theta\in\Theta}D(p_\theta\,\|\,q). \tag{1.1}$$

The central question of this paper is to evaluate $R^\star$ exactly, to determine
its structure, and to decide whether the difference between $R^\star$ and the
per-source optimum is large enough to justify building specialised decompressors.

### 1.2 Two prices

There are two natural notions of "universal", and they give different numbers.

*Worst case (pointwise).* Demand that on **every individual message** the code be
close to the best-fitting member of the family. The minimax value is
$\log_2 C_{\mathcal S}$ where $C_{\mathcal S}=\sum_x\max_\theta p_\theta(x)$ is the
**Shtarkov sum**, and the optimum is the normalized maximum-likelihood distribution
$\mathrm{nml}(x)=\max_\theta p_\theta(x)/C_{\mathcal S}$.

*Average case (Bayes).* Demand only that the *expected* redundancy be small under
each source. This is (1.1). Its value, as we prove, is the channel capacity $C$ of
the family.

We show $C\le\log_2 C_{\mathcal S}$ always, and exhibit an explicit family where the
inequality is strict by $\tfrac14\log_2 3$ bits.

### 1.3 Contributions

1. An exact, non-asymptotic, minimax-theorem-free proof of the redundancy–capacity
   theorem (Theorem 4.4), with the saddle point obtained by prior perturbation and a
   $\chi^2$ bound (Theorem 4.2).
2. Structural theory of the capacity: positivity, monotonicity, additivity over
   products, closed forms under transitive symmetry, and the exact cost of model
   selection (Sections 5, 7).
3. Uniqueness of the optimal universal coding distribution (Theorem 4.7).
4. An exact chain rule for coarse-grainings and the characterisation of free front
   ends as sufficient statistics (Section 8).
5. Rissanen-style rates for memoryless and Markov families, and a matching explicit
   lower bound $\tfrac{15}{32}\log_2 n-8$ for the Bernoulli family (Section 9).
6. A quantitative verdict on the value of specialised decompressors (Section 11).

---

## 2. Setup and notation

Throughout, $X$ is a finite set (the *message space*) and $\Theta$ is a finite
non-empty set (the *parameter space*).

**Definition 2.1 (Source class).** A *source class* $\mathcal S$ on $X$ indexed by
$\Theta$ assigns to each $\theta\in\Theta$ a probability vector
$p_\theta:X\to\mathbb R_{\ge0}$ with $\sum_x p_\theta(x)=1$. We call $\mathcal S$
*strictly positive* if $p_\theta(x)>0$ for all $\theta,x$.

**Definition 2.2 (Entropy, divergence).** For probability vectors $p,q$ on $X$ with
$q>0$,
$$H(p)=-\sum_x p(x)\log_2 p(x),\qquad D(p\|q)=\sum_x p(x)\log_2\frac{p(x)}{q(x)},$$
with the convention $0\log_2 0=0$. Gibbs' inequality gives $D(p\|q)\ge0$, with
equality iff $p=q$.

**Definition 2.3 (Prior, Bayes mixture, Bayes redundancy).** A *prior* is an element
$w$ of the standard simplex $\Delta(\Theta)=\{w:\Theta\to\mathbb R_{\ge0},\ \sum_\theta w_\theta=1\}$.
Its *Bayes mixture* is the distribution $m_w(x)=\sum_\theta w_\theta p_\theta(x)$,
and its *Bayes redundancy* is
$$I(w)=\sum_\theta w_\theta\,D(p_\theta\,\|\,m_w).$$

**Definition 2.4 (Capacity).**
$$C=C(\mathcal S)=\sup_{w\in\Delta(\Theta)} I(w).$$

**Definition 2.5 (Shtarkov sum).**
$C_{\mathcal S}=\sum_x\max_\theta p_\theta(x)\ \ (\ge 1)$, and
$\mathrm{nml}(x)=\max_\theta p_\theta(x)/C_{\mathcal S}$.

Two elementary identities are used constantly.

**Lemma 2.6 (Compensation identity).** For every prior $w$ and every strictly
positive $q$ with $\sum_x q(x)\le1$,
$$\sum_\theta w_\theta D(p_\theta\|q)=I(w)+D(m_w\|q).$$

*Proof.* Expand $\log_2 (p_\theta/q)=\log_2(p_\theta/m_w)+\log_2(m_w/q)$, multiply
by $w_\theta p_\theta(x)$ and sum; the second term sums to
$\sum_x m_w(x)\log_2(m_w(x)/q(x))$ because $\sum_\theta w_\theta p_\theta = m_w$. $\square$

**Lemma 2.7 (Mutual-information form).** If $\mathcal S$ is strictly positive and
$w\in\Delta(\Theta)$, then
$$I(w)=H(m_w)-\sum_\theta w_\theta H(p_\theta).$$
Thus $I(w)$ is the mutual information between the source index (distributed as $w$)
and the emitted message, and $C$ is the Shannon capacity of the channel
$\theta\mapsto x$ with transition law $p_\theta$.

*Proof.* Write $D(p_\theta\|m_w)=\sum_x p_\theta(x)\log_2 p_\theta(x)-\sum_x p_\theta(x)\log_2 m_w(x)$,
weight by $w_\theta$ and sum. The first block gives $-\sum_\theta w_\theta H(p_\theta)$;
exchanging the order of summation in the second block turns
$\sum_\theta w_\theta p_\theta(x)$ into $m_w(x)$, giving $+H(m_w)$. $\square$

Lemma 2.7 is not cosmetic: it exhibits $I$ as a continuous function of $w$ (the map
$u\mapsto u\log u$ is continuous on $[0,\infty)$), which is what compactness needs.

---

## 3. Two analytic tools

**Lemma 3.1 (Vanishing first order).** Let $a,K\in\mathbb R$ with $K\ge0$. If
$a\le tK$ for every $t\in(0,1]$, then $a\le0$.

*Proof.* If $a>0$, take $t=\min\{1,\,a/(2(K+1))\}>0$; then $tK\le a/2<a$, a
contradiction. $\square$

This lemma replaces the derivative computation of the classical proof: it converts
"$a\le O(t)$ for all small $t>0$" into "$a\le0$" with no differentiability
hypotheses.

**Theorem 3.2 ($\chi^2$ bound for relative entropy).** Let $a$ be a probability
vector and $b$ a strictly positive probability vector on $X$. Then
$$D(a\|b)\;\le\;\frac{1}{\ln 2}\sum_x\frac{(a(x)-b(x))^2}{b(x)}\;=\;\frac{\chi^2(a\|b)}{\ln2}.$$

*Proof.* By $\ln u\le u-1$ applied to $u=a(x)/b(x)$,
$a(x)\ln\frac{a(x)}{b(x)}\le a(x)\left(\frac{a(x)}{b(x)}-1\right)=\frac{a(x)^2}{b(x)}-a(x)$.
Summing and using $\sum_x a(x)=1$,
$\sum_x a(x)\ln\frac{a(x)}{b(x)}\le\sum_x\frac{a(x)^2}{b(x)}-1$. Finally
$\frac{(a-b)^2}{b}=\frac{a^2}{b}-2a+b$ summed over $x$ equals
$\sum_x\frac{a(x)^2}{b(x)}-1$. Divide by $\ln 2$. $\square$

The point of Theorem 3.2 is *quadratic* control: if $a-b=t\,v$ then
$D(a\|b)\le t^2\chi^2$-type bound, which is $O(t^2)$ and therefore beaten by the
linear term in the perturbation argument.

---

## 4. The redundancy–capacity theorem

Throughout this section $\mathcal S$ is strictly positive and $\Theta\neq\emptyset$.

**Lemma 4.1 (Existence of an optimal prior).** The supremum defining $C$ is attained:
there is $w^\star\in\Delta(\Theta)$ with $I(w^\star)=C$.

*Proof.* By Lemma 2.7, $I$ agrees on $\Delta(\Theta)$ with the continuous function
$w\mapsto H(m_w)-\sum_\theta w_\theta H(p_\theta)$; $\Delta(\Theta)$ is compact and
non-empty; apply the extreme value theorem. $\square$

Note also that strict positivity of $\mathcal S$ and $w\in\Delta(\Theta)$ force
$m_w>0$, since some $w_\theta>0$ and $m_w(x)\ge w_\theta p_\theta(x)>0$.

The heart of the matter is that a prior which is optimal *on average* produces a
mixture that is good *uniformly*.

**Theorem 4.2 (Saddle point).** Let $w^\star$ maximise $I$ over $\Delta(\Theta)$ and
put $m^\star=m_{w^\star}$. Then
$$D(p_\theta\,\|\,m^\star)\;\le\;I(w^\star)=C\qquad\text{for every }\theta\in\Theta.$$

*Proof.* Fix $\theta_0$ and for $t\in(0,1]$ set $w_t=(1-t)w^\star+t\delta_{\theta_0}$,
a prior. Its mixture is $m_t=(1-t)m^\star+t\,p_{\theta_0}$, so
$$m_t-m^\star=t\,(p_{\theta_0}-m^\star). \tag{4.1}$$
Apply Lemma 2.6 with prior $w_t$ and coding distribution $q=m^\star$:
$$\sum_\theta (w_t)_\theta D(p_\theta\|m^\star)=I(w_t)+D(m_t\|m^\star).$$
The left-hand side is
$(1-t)\sum_\theta w^\star_\theta D(p_\theta\|m^\star)+t\,D(p_{\theta_0}\|m^\star)
=(1-t)I(w^\star)+t\,D(p_{\theta_0}\|m^\star)$, using Lemma 2.6 again with $w^\star$ and
$q=m^\star$ (where $D(m^\star\|m^\star)=0$). By maximality, $I(w_t)\le I(w^\star)$.
Hence
$$t\big(D(p_{\theta_0}\|m^\star)-I(w^\star)\big)\;\le\;D(m_t\|m^\star).$$
By Theorem 3.2 and (4.1),
$$D(m_t\|m^\star)\le\frac{1}{\ln2}\sum_x\frac{t^2(p_{\theta_0}(x)-m^\star(x))^2}{m^\star(x)}=t^2\frac{V}{\ln2},
\qquad V:=\chi^2(p_{\theta_0}\|m^\star)\ge0 .$$
Dividing by $t>0$ gives $D(p_{\theta_0}\|m^\star)-I(w^\star)\le t\,(V/\ln2)$ for all
$t\in(0,1]$; Lemma 3.1 with $K=V/\ln2$ concludes. $\square$

**Corollary 4.3 (Achievability).** There is a strictly positive probability
distribution $q$ on $X$ — namely $q=m^\star$ — with
$D(p_\theta\|q)\le C$ for every $\theta$.

**Theorem 4.4 (Redundancy–capacity theorem).** For a finite strictly positive source
class,
$$\min_{q}\max_\theta D(p_\theta\|q)=C .$$
Explicitly: (i) the mixture $m^\star$ over a capacity-achieving prior satisfies
$D(p_\theta\|m^\star)\le C$ for all $\theta$; and (ii) for every strictly positive
$q$ with $\sum_x q(x)\le1$ there exists $\theta$ with $D(p_\theta\|q)\ge C$.

*Proof.* (i) is Corollary 4.3. For (ii), by Lemma 2.6 with $w=w^\star$,
$\sum_\theta w^\star_\theta D(p_\theta\|q)=C+D(m^\star\|q)\ge C$, since relative
entropy against a sub-probability vector is non-negative. An average of the numbers
$D(p_\theta\|q)$ with weights $w^\star$ is at least $C$, hence some term is. $\square$

Statement (ii) holds for sub-probability $q$, i.e. for arbitrary Kraft-compliant
codes, which is what makes the operational form of Section 6 work.

**Theorem 4.5 (Verification criterion).** If some strictly positive $q$ with
$\sum_x q(x)\le1$ satisfies $D(p_\theta\|q)\le c$ for all $\theta$, then $C\le c$.

*Proof.* Lemma 2.6 with $w^\star$: $C\le C+D(m^\star\|q)=\sum_\theta w^\star_\theta D(p_\theta\|q)\le c$. $\square$

Theorem 4.5 is the workhorse of the whole paper: *every* upper bound on capacity
below is obtained by exhibiting one coding distribution and estimating its
divergence from every source.

**Theorem 4.6 (Equalizer property).** If $w^\star$ is capacity-achieving and
$w^\star_\theta>0$, then $D(p_\theta\|m^\star)=C$ exactly.

*Proof.* All terms satisfy $D(p_\theta\|m^\star)\le C$ by Theorem 4.2. If one term
with positive weight were strictly smaller, then
$C=I(w^\star)=\sum_\theta w^\star_\theta D(p_\theta\|m^\star)<\sum_\theta w^\star_\theta C=C$,
a contradiction. $\square$

**Theorem 4.7 (Uniqueness of the optimal code).** If $w_1,w_2$ are both
capacity-achieving priors, then $m_{w_1}=m_{w_2}$.

*Proof sketch.* By Theorem 4.2 applied at $w_2$, $D(p_\theta\|m_{w_2})\le C$ for all
$\theta$. By Lemma 2.6 with prior $w_1$ and $q=m_{w_2}$,
$$C+D(m_{w_1}\|m_{w_2})=\sum_\theta (w_1)_\theta D(p_\theta\|m_{w_2})\le C,$$
so $D(m_{w_1}\|m_{w_2})\le 0$, hence $=0$, and strict Gibbs gives
$m_{w_1}=m_{w_2}$. $\square$

Thus the optimal universal decompressor is a canonical object attached to the source
class, not an artefact of which optimal prior one happens to compute.

---

## 5. First structural consequences

**Theorem 5.1 (Positivity).** If $p_{\theta_1}\neq p_{\theta_2}$ for some
$\theta_1,\theta_2$, then $C>0$.

*Proof sketch.* Let $u$ be the uniform prior and $m_u$ its mixture. If
$C=0$ then $I(u)=0$, i.e. $\sum_\theta u_\theta D(p_\theta\|m_u)=0$ with all terms
non-negative, so every $p_\theta=m_u$ by the strict Gibbs inequality; in particular
$p_{\theta_1}=p_{\theta_2}$. $\square$

There is no free universality over a genuinely uncertain family.

**Theorem 5.2 (Two-part bound).** $C\le\log_2|\Theta|$.

*Proof.* Apply Theorem 4.5 to $q=m_u$, the uniform mixture: since
$m_u(x)\ge p_\theta(x)/|\Theta|$, we get
$D(p_\theta\|m_u)\le\log_2|\Theta|$ termwise. $\square$

**Theorem 5.3 (Average $\le$ worst case).** $C\le\log_2 C_{\mathcal S}$.

*Proof.* Apply Theorem 4.5 to $q=\mathrm{nml}$. For every $\theta$ and $x$,
$p_\theta(x)/\mathrm{nml}(x)=C_{\mathcal S}\,p_\theta(x)/\max_{\theta'}p_{\theta'}(x)\le C_{\mathcal S}$,
so $D(p_\theta\|\mathrm{nml})\le\log_2 C_{\mathcal S}$. $\square$

**Theorem 5.4 (Monotonicity).** If $\mathcal T=\{p_{f(\theta')}\}_{\theta'\in\Theta'}$
is a subfamily of $\mathcal S$ (i.e. obtained by restricting the parameter along any
map $f:\Theta'\to\Theta$), then $C(\mathcal T)\le C(\mathcal S)$.

*Proof.* The universal code for $\mathcal S$ from Corollary 4.3 is within $C(\mathcal S)$
of every source of $\mathcal T$; apply Theorem 4.5. $\square$

**Theorem 5.5 (Distinguishable classes).** Suppose there are pairwise disjoint sets
$A_\theta\subseteq X$ with $\sum_{x\in A_\theta}p_\theta(x)\ge1-\delta$ for every
$\theta$. Then
$$(1-\delta)\log_2|\Theta|-4\;\le\;C\;\le\;\log_2|\Theta| .$$

*Proof sketch.* The upper bound is Theorem 5.2. For the lower bound, let $q$ be any
coding distribution. Since the $A_\theta$ are disjoint, $\sum_\theta q(A_\theta)\le1$,
so some $\theta$ has $q(A_\theta)\le1/|\Theta|$; for that $\theta$, a standard
data-processing/binary-divergence estimate on the two-cell partition
$\{A_\theta,A_\theta^c\}$ gives
$D(p_\theta\|q)\ge(1-\delta)\log_2|\Theta|-4$. Now apply this to the optimal $q$ of
Corollary 4.3. $\square$

The constant $4$ absorbs the binary entropy term; no attempt is made to optimise it.

---

## 6. Operational form: real codes, real bits

Capacity is defined through relative entropies; the following two statements convert
it into a statement about prefix codes, whose codeword lengths are integers.

A length function $\ell:X\to\mathbb N$ is *Kraft compliant* if
$\sum_x 2^{-\ell(x)}\le1$; such $\ell$ are exactly the length functions of
prefix-free binary codes. Write
$L(p,\ell)=\sum_x p(x)\ell(x)$ for expected length.

**Theorem 6.1 (Converse in code lengths).** For every Kraft-compliant $\ell$ there
exists $\theta$ with
$$L(p_\theta,\ell)\;\ge\;H(p_\theta)+C .$$

*Proof.* Put $q(x)=2^{-\ell(x)}$, a strictly positive sub-probability vector. A
direct computation gives $L(p,\ell)=H(p)+D(p\|q)$. Apply Theorem 4.4(ii). $\square$

**Theorem 6.2 (Achievability in code lengths).** There is a Kraft-compliant $\ell$ —
the Shannon code $\ell(x)=\lceil\log_2(1/m^\star(x))\rceil$ of the capacity mixture —
with
$$L(p_\theta,\ell)\;\le\;H(p_\theta)+C+1\qquad\text{for every }\theta .$$

*Proof.* Kraft compliance follows from $2^{-\lceil\log_2(1/m^\star(x))\rceil}\le m^\star(x)$
and $\sum_x m^\star(x)=1$. For the bound, $\ell(x)<\log_2(1/m^\star(x))+1$ gives
$L(p_\theta,\ell)\le H(p_\theta)+D(p_\theta\|m^\star)+1\le H(p_\theta)+C+1$. $\square$

Together: the minimax expected redundancy of prefix codes over the class is bracketed
between $C$ and $C+1$ bits per message. The one-bit slack is the usual integer-length
rounding and is removed by arithmetic coding over blocks.

---

## 7. Symmetry, products, and the cost of model selection

### 7.1 Additivity over independent blocks

For classes $\mathcal S$ on $X$ indexed by $\Theta$ and $\mathcal T$ on $Y$ indexed by
$\Psi$, define the product class $\mathcal S\otimes\mathcal T$ on $X\times Y$ indexed
by $\Theta\times\Psi$ by $(p\otimes r)_{(\theta,\psi)}(x,y)=p_\theta(x)r_\psi(y)$.

**Theorem 7.1 (Additivity).** For strictly positive $\mathcal S,\mathcal T$,
$$C(\mathcal S\otimes\mathcal T)=C(\mathcal S)+C(\mathcal T).$$

*Proof sketch.* For products of distributions, divergence is additive:
$D(p\otimes r\,\|\,a\otimes b)=D(p\|a)+D(r\|b)$. The inequality $\le$ follows from
Theorem 4.5 applied to the product $m^\star_{\mathcal S}\otimes m^\star_{\mathcal T}$
of the two optimal mixtures, which is within $C(\mathcal S)+C(\mathcal T)$ of every
product source. For $\ge$, take capacity-achieving priors $w^\star,v^\star$; their
product prior has mixture $m_{w^\star}\otimes m_{v^\star}$ and Bayes redundancy
$I(w^\star)+I(v^\star)$ by the same additivity. $\square$

The direction $\le$ is exactly the statement that there is **no universality discount
across independent data** — a fact that is awkward to obtain from the classical
minimax-theorem proof but immediate from the saddle point.

### 7.2 Transitive symmetry and unknown-offset classes

**Theorem 7.2 (Symmetric classes).** Suppose a group $G$ acts on $X$ and on $\Theta$
by bijections with $p_{g\cdot\theta}(g\cdot x)=p_\theta(x)$, and the action on
$\Theta$ is transitive. Then the uniform prior is capacity-achieving, and
$C=D(p_\theta\|m_u)$ for any (hence every) $\theta$.

*Proof sketch.* Compatibility shows $m_u$ is $G$-invariant and that
$\theta\mapsto D(p_\theta\|m_u)$ is constant on $G$-orbits, hence constant by
transitivity; so $I(u)=D(p_\theta\|m_u)$ for every $\theta$, and Theorem 4.5 applied
to $q=m_u$ with $c=D(p_\theta\|m_u)$ gives $C\le I(u)\le C$. $\square$

**Definition 7.3 (Unknown-offset class).** Let $A$ be a finite abelian group and
$p_0$ a probability distribution on $A$. The *shift class* is
$\mathcal S_{p_0}=\{p_\theta\}_{\theta\in A}$ with $p_\theta(x)=p_0(x-\theta)$.

**Theorem 7.4 (Closed forms).** If $p_0>0$ then
$$C(\mathcal S_{p_0})=\log_2|A|-H(p_0),\qquad
\log_2 C_{\mathcal S_{p_0}}=\log_2|A|-H_\infty(p_0),$$
where $H_\infty(p_0)=-\log_2\max_a p_0(a)$ is the min-entropy. Consequently
$$\boxed{\ \log_2 C_{\mathcal S_{p_0}}-C(\mathcal S_{p_0})=H(p_0)-H_\infty(p_0)\ \ge 0 .}$$

*Proof sketch.* The translation group $A$ acts transitively and compatibly, so
Theorem 7.2 applies; the uniform mixture of all translates of $p_0$ is the uniform
distribution $u_A$ on $A$, and $D(p_0\|u_A)=\log_2|A|-H(p_0)$. For the Shtarkov sum,
$\max_\theta p_0(x-\theta)=\max_a p_0(a)$ for every $x$, so
$C_{\mathcal S}=|A|\max_a p_0(a)$. $\square$

**Example 7.5 (An explicit strict gap).** Let $A=\mathbb Z/2$ and $p_0=(3/4,1/4)$, so
the class is $\{(3/4,1/4),(1/4,3/4)\}$. Then $H(p_0)=2-\tfrac34\log_2 3$ and
$H_\infty(p_0)=2-\log_2 3$, whence
$$C=\tfrac34\log_2 3-1\approx0.1887,\qquad
\log_2 C_{\mathcal S}=\log_2 3-1\approx0.5850,$$
with gap exactly $\tfrac14\log_2 3\approx0.3962$ bits. The two prices of universality
are genuinely different quantities, and the worst-case theory overcharges an
average-case coder by a factor of about three here.

### 7.3 The exact cost of model selection

Let $\mathcal T_1,\dots,\mathcal T_K$ be source classes on the same message space
(the "specialists"), and let $\Sigma=\bigsqcup_i\mathcal T_i$ be their disjoint union
regarded as a single class (the "generalist"): its parameter set is
$\{(i,\theta):\theta\in\Theta_i\}$ and its sources are those of the $\mathcal T_i$.

**Theorem 7.6 (Model-selection sandwich).** If $C(\mathcal T_i)\le B$ for all $i$,
then
$$\max_i C(\mathcal T_i)\;\le\;C(\Sigma)\;\le\;B+\log_2 K .$$

*Proof sketch.* The lower bound is Theorem 5.4 ($\mathcal T_i$ is a subfamily of
$\Sigma$). For the upper bound, let $q_i$ be the optimal code for $\mathcal T_i$ from
Corollary 4.3 and take $q=\frac1K\sum_i q_i$. Then $q\ge q_i/K$ pointwise, so
$D(p\|q)\le D(p\|q_i)+\log_2 K\le B+\log_2 K$ for every source $p$ of
$\mathcal T_i$; apply Theorem 4.5. $\square$

This is the quantitative answer to the motivating question:

> **The total number of bits that specialisation can move from the message into the
> shared decompressor is at most $\log_2(\text{number of specialised classes})$.**

Merging a thousand specialised codecs into one universal codec costs at most about
ten bits per message.

---

## 8. Parses: data processing, sufficiency, and the price of a front end

Practical compressors never see raw data; they see a *parse* — a token stream, a
match/literal split, a histogram. Formally the coder sees $f(x)$ for a map
$f:X\to Y$ into a finite set. Write $f_*p(y)=\sum_{x:f(x)=y}p(x)$ for the pushforward,
and $f_*\mathcal S$ for the class $\{f_*p_\theta\}$.

**Theorem 8.1 (Data processing).** $D(f_*p\|f_*q)\le D(p\|q)$ for all $p,q>0$;
consequently $I_{f_*\mathcal S}(w)\le I_{\mathcal S}(w)$ for every prior and
$$C(f_*\mathcal S)\le C(\mathcal S).$$

*Proof sketch.* The log-sum inequality
$\left(\sum_i a_i\right)\log_2\frac{\sum_i a_i}{\sum_i b_i}\le\sum_i a_i\log_2\frac{a_i}{b_i}$
applied fibre by fibre. The capacity statement follows by taking suprema, or from
Theorem 4.5 applied to the pushforward of the optimal code. $\square$

**Definition 8.2 (Parse defect).** For strictly positive $p,q$ and $f:X\to Y$, put
$$D(p\|q\mid f)=\sum_{y\in Y}\ \sum_{x:f(x)=y} p(x)\,
\log_2\frac{p(x)/f_*p(y)}{q(x)/f_*q(y)} ,$$
the divergence between the conditional laws of $p$ and $q$ inside the fibres of $f$,
averaged (implicitly, through the weights $p(x)$) over fibres.

**Theorem 8.3 (Chain rule).** For strictly positive $p,q$,
$$D(p\|q)=D(f_*p\|f_*q)+D(p\|q\mid f),$$
and $D(p\|q\mid f)\ge0$.

*Proof.* Inside a fibre over $y$, write
$\log_2\frac{p(x)}{q(x)}=\log_2\frac{f_*p(y)}{f_*q(y)}+\log_2\frac{p(x)/f_*p(y)}{q(x)/f_*q(y)}$
and sum, using $\sum_{x:f(x)=y}p(x)=f_*p(y)$. Non-negativity of each fibre term is
Gibbs' inequality applied to the two conditional laws, weighted by $f_*p(y)$. $\square$

Theorem 8.3 makes Theorem 8.1 a corollary and, more importantly, *prices* a parse: the
defect is exactly the divergence the coarse-graining throws away.

**Theorem 8.4 (Price of a parse, at capacity level).** There is a capacity-achieving
prior $w^\star$ with
$$C(f_*\mathcal S)\;\le\;C(\mathcal S)\;\le\;C(f_*\mathcal S)+\sum_\theta w^\star_\theta\,
D\!\left(p_\theta\,\middle\|\,m_{w^\star}\ \middle|\ f\right).$$

*Proof.* Apply Theorem 8.3 to each $D(p_\theta\|m_{w^\star})$, weight by $w^\star$, and
observe that $\sum_\theta w^\star_\theta D(f_*p_\theta\|f_*m_{w^\star})$ is the Bayes
redundancy of $w^\star$ for the pushed-forward class, hence at most $C(f_*\mathcal S)$. $\square$

**Theorem 8.5 (Free front ends are exactly sufficient statistics).** Let
$\{p_\theta\}$ and $m$ be strictly positive. Then
$$D(p_\theta\|m\mid f)=0\ \ \text{for every }\theta
\iff
\exists\,g_\theta:Y\to\mathbb R_{>0}\ \ \text{with}\ \ p_\theta(x)=g_\theta(f(x))\,m(x)\ \ \forall\theta,x .$$

*Proof sketch.* ($\Leftarrow$) If $p_\theta=g_\theta\circ f\cdot m$, then inside each
fibre the conditional laws of $p_\theta$ and $m$ coincide (the factor $g_\theta(y)$ is
constant on the fibre and cancels against the pushforward), so every fibre term
vanishes. ($\Rightarrow$) Each fibre term is a non-negative multiple of a relative
entropy between the two conditional laws on that fibre; a zero sum forces each to
vanish, and strict Gibbs forces the conditional laws to be equal:
$p_\theta(x)/f_*p_\theta(f(x))=m(x)/f_*m(f(x))$. Rearranging gives the Fisher–Neyman
factorisation with the explicit factor
$g_\theta(y)=f_*p_\theta(y)/f_*m(y)$. $\square$

Combining Theorems 8.4 and 8.5: if $f$ is sufficient for $\mathcal S$ (Fisher–Neyman
with a common factor $h$), then $C(f_*\mathcal S)=C(\mathcal S)$; otherwise the deficit
is the explicit, computable within-fibre defect. In slogan form:

> **The price of universality is a function of the sufficient statistic alone.**

This is the test a compressor designer wants: given a proposed parse, decide whether
it can be adopted for free.

---

## 9. Rates: how the price grows with message length

We now compute the price for the families of practical interest. Since the theory
requires a finite parameter set, we work with arbitrary *finite subfamilies* of the
(continuum-parametrised) classical classes; all bounds below are uniform in the
subfamily, i.e. independent of how many parameters are selected.

### 9.1 Counting bound through the message space

**Lemma 9.1.** For any strictly positive class on a message space $X$,
$C\le\log_2|X|$.

*Proof.* $C_{\mathcal S}=\sum_x\max_\theta p_\theta(x)\le|X|$; apply Theorem 5.3.
(Equivalently, apply Theorem 4.5 to the uniform distribution on $X$.) $\square$

Combined with sufficiency, Lemma 9.1 becomes powerful: pushing forward along a
sufficient statistic preserves the capacity but can shrink the effective message
space dramatically.

### 9.2 Memoryless families

Let $A$ be a finite alphabet, $n\ge0$, $X=A^n$. For a probability vector $t$ on $A$
let $p_t(x)=\prod_{i<n}t(x_i)$. A *memoryless subfamily* is
$\{p_{t_\theta}\}_{\theta\in\Theta}$ for finitely many parameters $t_\theta$.

The *type* map $\tau:A^n\to\mathbb N^A$ sends $x$ to its vector of symbol counts.
Since $p_t(x)=\prod_{a\in A}t(a)^{\tau(x)_a}$, the type is a sufficient statistic
(with $h\equiv1$), so $C(\tau_*\mathcal S)=C(\mathcal S)$ by Theorem 8.5. The type
space has at most $(n+1)^{|A|}$ elements, and Lemma 9.1 gives:

**Theorem 9.2 (Memoryless rate).** For every finite memoryless subfamily over the
alphabet $A$ on messages of length $n$ with strictly positive parameters,
$$C\;\le\;|A|\,\log_2(n+1),$$
uniformly in the number of sources. For $A=\{0,1\}$ the count of ones is already
sufficient, so
$$C\;\le\;\log_2(n+1).$$

### 9.3 Markov families

Let $A$ be a finite alphabet and consider first-order Markov laws on $A^n$ specified
by an initial distribution and a transition matrix. The pair (first symbol, matrix of
transition counts) is a sufficient statistic, and its range has at most
$|A|\cdot(n+1)^{|A|^2}$ elements, giving:

**Theorem 9.3 (Markov rate).** For every finite subfamily of first-order Markov laws
on $A^n$ with strictly positive parameters,
$$C\;\le\;\log_2|A|+|A|^2\log_2(n+1).$$

The multiplier $|A|^2$ is the number of free parameters of the model class: this is
exactly the Rissanen shape "redundancy $\asymp\frac{d}{2}\log_2 n$ with $d$ the
parameter count", here proved as a clean non-asymptotic upper bound with constant $1$
rather than $1/2$.

### 9.4 Smoothing: making rich classes admissible

The capacity theory requires strictly positive sources, whereas the richest natural
classes (types, deterministic files) are mutually singular. Fix $\varepsilon\in(0,1]$
and define the $\varepsilon$-*smoothing* of a class by
$p^{(\varepsilon)}_\theta=(1-\varepsilon)p_\theta+\varepsilon\,u_X$, where $u_X$ is
uniform on $X$. Smoothing makes the class strictly positive while preserving
distinguishability: if $p_\theta$ was supported on a private set $A_\theta$ then
$p^{(\varepsilon)}_\theta(A_\theta)\ge1-\varepsilon$.

**Theorem 9.4 (Smoothed distinguishable classes).** If the $A_\theta$ are pairwise
disjoint with $p_\theta(A_\theta)=1$, then
$$(1-\varepsilon)\log_2|\Theta|-4\;\le\;C\big(\mathcal S^{(\varepsilon)}\big)\;\le\;\log_2|\Theta| .$$

*Proof.* Theorem 5.5 with $\delta=\varepsilon$, applied to the smoothed class. $\square$

Applied to the constant-composition class of $n$-bit files (one source per possible
number of ones, uniform on its composition class; $|\Theta|=n+1$), Theorem 9.4 yields
an $n$-dependent lower bound
$(1-\varepsilon)\log_2(n+1)-4\le C\le\log_2(n+1)$: for this rich binary class,
$\log_2 n$ is the exact order of the average-case price.

### 9.5 A genuine one-parameter lower bound: the Bernoulli packing

Theorem 9.4 concerns a rich, somewhat artificial class. The natural question is
whether an honest one-parameter family — the Bernoulli family — already pays
$\Theta(\log n)$. It does, and the proof is an explicit packing plus Chebyshev.

Fix $n$ and a scale $k$ with $k^2\le n$; the intended choice is
$k=\lfloor\sqrt n\rfloor$. Consider the $\lfloor k/4\rfloor$ Bernoulli parameters
$$t_j=\frac{4j+2}{k},\qquad 0\le j<\lfloor k/4\rfloor ,$$
and the corresponding i.i.d. laws on $\{0,1\}^n$. Let $N(x)$ be the number of ones.

**Lemma 9.5 (Moments).** Under the product Bernoulli$(t)$ law on $\{0,1\}^n$,
$$\mathbb E[N]=nt,\qquad \mathbb E[(N-nt)^2]=nt(1-t)\le n/4 .$$

*Proof sketch.* Induction on $n$ using the splitting bijection
$\{0,1\}^{n+1}\cong\{0,1\}\times\{0,1\}^n$; the "expectations" are finite sums over
the message space, so no measure theory is required. $\square$

**Lemma 9.6 (Chebyshev window).** For any $r>0$,
$\Pr\big[|N-nt|\ge r\big]\le nt(1-t)/r^2\le n/(4r^2)$. In particular, with
$r=2n/k$ and $k^2\le n$,
$$\Pr\Big[\,|N-nt|<\tfrac{2n}{k}\,\Big]\;\ge\;1-\frac{n k^2}{16n^2}\;\ge\;\frac{15}{16}.$$

**Lemma 9.7 (Disjointness).** The windows $W_j=\{x: |N(x)-nt_j|<2n/k\}$ are pairwise
disjoint, because consecutive means $nt_j=(n/k)(4j+2)$ are $4n/k$ apart while the
windows have half-width $2n/k$.

**Theorem 9.8 (Bernoulli lower bound).** For $k^2\le n$ and $k\ge8$, the family
$\{p_{t_j}\}_{j<\lfloor k/4\rfloor}$ satisfies
$$\tfrac{15}{16}\log_2\lfloor k/4\rfloor-4\;\le\;C .$$
Taking $k=\lfloor\sqrt n\rfloor$, for every $n\ge64$,
$$\boxed{\ \tfrac{15}{32}\log_2 n-8\;\le\;C\;\le\;\log_2(n+1).\ }$$

*Proof.* Lemmas 9.6 and 9.7 make $\{W_j\}$ an approximately disjoint family with
$\delta=1/16$ and $|\Theta|=\lfloor k/4\rfloor$; apply Theorem 5.5 for the lower
bound and Theorem 9.2 (binary case) for the upper bound. The stated form follows from
$\lfloor\lfloor\sqrt n\rfloor/4\rfloor\ge\sqrt n/8$ for $n\ge64$ and
$\log_2\sqrt n=\tfrac12\log_2 n$. $\square$

So the average-case price of universality of the Bernoulli class grows like a
constant times $\log_2 n$, and the constant — the Rissanen constant of a
one-parameter family, classically $1/2$ — is bracketed between $15/32=0.46875$ and
$1$. The loss factor $15/16$ is exactly the Chebyshev tail; sharpening the tail
estimate would push the lower constant towards $1/2$.

---

## 10. Algorithms

The theory is constructive. Three algorithms follow directly.

### 10.1 Blahut–Arimoto: computing the price

Capacity is a concave maximisation over the simplex and is computed by the classical
alternating-maximisation iteration. Given the matrix $p_\theta(x)$:

1. Start from the uniform prior $w^{(0)}$.
2. Given $w^{(s)}$, form the mixture $m^{(s)}(x)=\sum_\theta w^{(s)}_\theta p_\theta(x)$
   and the divergences $d^{(s)}_\theta=D(p_\theta\|m^{(s)})$.
3. Update $w^{(s+1)}_\theta\propto w^{(s)}_\theta\,2^{\,d^{(s)}_\theta}$.
4. Iterate. Then $\max_\theta d^{(s)}_\theta$ decreases to $C$ from above and
   $I(w^{(s)})$ increases to $C$ from below, giving a certified two-sided bracket at
   every step (the upper certificate is Theorem 4.5, the lower one is
   $I(w)\le C$).

The per-iteration cost is $O(|\Theta||X|)$, and the bracket
$[\,I(w^{(s)}),\ \max_\theta d^{(s)}_\theta\,]$ is a rigorous enclosure of $C$ at
every step — a feature the saddle point provides for free.

### 10.2 The optimal universal code

Run the iteration to tolerance, output $m^\star$, and encode with the Shannon code
$\ell(x)=\lceil\log_2(1/m^\star(x))\rceil$ (in practice, arithmetic coding against
$m^\star$, which removes the $+1$). By Theorems 6.1 and 6.2 this code is within
$C+1$ bits of the entropy of *every* source in the family, and no code beats $C$.

### 10.3 Auditing a front end

Given a proposed parse $f$ and the class, compute for the optimal prior
$$\Delta(f)=\sum_\theta w^\star_\theta\,D(p_\theta\|m^\star\mid f)
=\sum_\theta w^\star_\theta\Big(D(p_\theta\|m^\star)-D(f_*p_\theta\|f_*m^\star)\Big).$$
By Theorems 8.3–8.5, $\Delta(f)=0$ if and only if $f$ is sufficient, and in general
$\Delta(f)$ is the number of bits per message the front end discards. The cost is one
pass over $X$ per source.

---

## 11. Discussion: is specialisation worth it?

Collecting the quantitative statements:

* The price of universality of a $d$-parameter family on messages of length $n$ is
  $\Theta(\log n)$ bits *in total* (not per symbol): upper bounds
  $|A|\log_2(n+1)$ (memoryless) and $\log_2|A|+|A|^2\log_2(n+1)$ (Markov); matching
  lower bound $\tfrac{15}{32}\log_2 n-8$ already for $d=1$.
* Merging $K$ specialised classes costs at most $\log_2 K$ bits (Theorem 7.6), and at
  least the worst specialised price.
* The price is additive over independent blocks (Theorem 7.1), so it cannot be
  amortised by bundling independent files.
* The price is strictly positive whenever the family is non-degenerate (Theorem 5.1),
  but is bounded by $\log_2|\Theta|$ (Theorem 5.2).

**Verdict.** Specialised decompressors can move at most $O(\log n)$ bits out of the
message and into the shared decompressor. For a one-megabyte file from a modest model
class ($n\approx8\times10^6$, $d$ small) the entire theoretical prize is on the order
of tens of bits — negligible. Specialisation pays only in three regimes:

1. **Short messages.** When $\log_2 n$ is comparable to $n\cdot H$, i.e. for very
   short records, the toll is a substantial fraction of the file.
2. **Many independent records.** Additivity means the $\Theta(\log n)$ toll is paid
   *per independently coded block*. A million tiny records pay a million tolls; here
   a specialised (or adaptively shared) model is genuinely valuable.
3. **Large model families.** The toll scales with the parameter count $d$ (through
   $|A|$ or $|A|^2$ above), so for rich model classes — the interesting case in
   practice — the price grows and specialisation matters more.

This settles the gate posed at the outset ("if specialisation doesn't move bits from
*message* to *shared*, the direction is dead"): specialisation *does* move bits, but
only logarithmically many, so the direction is alive only in regimes 1–3.

**The constructive redirection.** The sufficiency theorem (Theorem 8.5) points at a
better lever. Since the price is a function of the sufficient statistic alone, the
useful engineering question is not "should I ship more decompressors?" but "is my
front end sufficient?" A sufficient parse is free; a non-sufficient one has an
explicit, computable price $\Delta(f)$. This converts a matter of taste
(match/literal splits, tokenisation, histogram front ends) into a computation.

**Relation to classical results.** Theorem 4.4 is the redundancy–capacity theorem of
Gallager, Ryabko and Davisson; the contribution here is a proof that is
non-asymptotic, avoids the minimax theorem, and therefore yields the equalizer
property, the verification criterion, uniqueness, and additivity as immediate
corollaries rather than as separate arguments. Theorems 9.2–9.3 are non-asymptotic
forms of Rissanen's $\frac d2\log n$ rate, obtained purely from sufficiency plus
counting; Theorem 9.8 supplies the matching lower half for $d=1$ with explicit
constants at every finite $n$.

---

## 12. Future directions

Two exact theories now sit side by side: the **worst-case (pointwise)** minimax
redundancy, equal to $\log_2 C_{\mathcal S}$, and the **average-case (Bayes)** minimax
redundancy, equal to the capacity $C$. They are provably ordered
($C\le\log_2 C_{\mathcal S}$) and provably distinct (gap $\tfrac14\log_2 3$ on an
explicit two-source class). For unknown-offset classes the gap is exactly
$H(p_0)-H_\infty(p_0)$. Capacity is additive over independent blocks, strictly
positive for any non-trivial class, monotone under subclasses, costs at most
$\log_2 K$ to merge $K$ classes, and the optimal universal decompressor is unique.

A front end is free exactly when it is a sufficient statistic: the parse defect obeys
the chain rule $D(p\|q)=D(f_*p\|f_*q)+D(p\|q\mid f)$, is monotone under
coarse-graining, vanishes iff the family factors through the parse, and is strictly
positive when the parse destroys the data. *The price of universality is a function of
the sufficient statistic alone.* Cashed out as rates: memoryless families obey
$C\le|A|\log_2(n+1)$ (and $C\le\log_2(n+1)$ in the binary case), and finite Markov
families obey $C\le\log_2|A|+|A|^2\log_2(n+1)$.

The natural next steps:

* **Close the Rissanen constant.** The one-parameter bracket is
  $[15/32,\,1]$. Replacing the Chebyshev tail by a sharper (Bernstein or exact
  binomial) estimate should move the lower constant towards $1/2$; matching the
  classical $\tfrac12\log_2 n+O(1)$ with explicit constants at every finite $n$ is
  within reach.
* **Multi-parameter packings.** Extend the packing construction from the
  one-parameter Bernoulli family to $d$-parameter memoryless and Markov families,
  producing lower bounds of the form $\tfrac{d}{2}\log_2 n-O(d)$ and closing the gap
  with the $|A|\log_2(n+1)$ and $|A|^2\log_2(n+1)$ upper bounds.
* **The Jeffreys prior.** Identify the capacity-achieving prior asymptotically with
  the Jeffreys prior for smooth parametric families, turning the uniqueness theorem
  into an explicit description of the canonical universal decompressor.
* **Sequential and adaptive codes.** Extend the exact theory from block codes to
  sequential prediction, where the mixture is updated online; the compensation
  identity has a per-symbol form that should give a non-asymptotic regret bound.
* **Practical parse audits.** Implement the front-end audit $\Delta(f)$ for the
  parses used by real codecs (LZ match/literal splits, byte-pair tokenisations,
  context-mixing statistics) and measure how far from sufficiency they are.
* **Beyond finite spaces.** Extend the perturbation proof to countable and continuous
  message spaces, where the $\chi^2$ bound and the compactness argument both need
  care but neither is obviously obstructed.

---

## 13. Conclusion

The price of universality is not a heuristic overhead; it is a number, and the number
is the capacity of the channel that carries the identity of the source to the
observed message. That single identification — proved here exactly, non-asymptotically,
and by an elementary perturbation — organises the whole subject: it makes the optimal
universal decompressor unique and canonical, makes the price additive, positive,
monotone, and computable, prices front ends by their sufficiency defect, and reduces
the practical question of specialised decompressors to a logarithm. Information you
cannot extract from the data and information you must pay for in order to compress it
are the same information, seen from two sides.
