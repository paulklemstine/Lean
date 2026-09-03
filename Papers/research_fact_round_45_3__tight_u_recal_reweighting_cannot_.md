# The Recalibration Ceiling of Small-Prime Footprints

### Exact limits of reweighting quadratic-residue dial features for the smoothness bias of $x^2-N$

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

Predictors used to rank candidates in quadratic-sieve-style factoring pipelines
frequently rest on the *small-prime footprint* of an integer $N$: the vector of
quadratic-residue **dials** $\operatorname{dial}_p(N)=\#\{x \bmod p: x^2\equiv N\}\in\{0,1,2\}$
for primes $p$ up to a bound $B$. When such a predictor degrades in a harder
operating regime, the natural remedy is to refit the footprint weights inside
that regime. We prove that this remedy is not merely ineffective but provably
counterproductive, and we compute the exact ceiling on what any reweighting
could ever achieve.

Working over the residue-data space $\Omega_A = \prod_{p\in A}\mathbb{Z}/p\mathbb{Z}$
with its uniform measure, we show that the centred dials
$x_p = \operatorname{dial}_p - 1$ form an *exactly* orthogonal design with
variances $v_p = (p-1)/p$, and we derive the exact three-term decomposition of
the mean squared error of any affine footprint predictor. Three consequences
follow. (i) *Localisation*: a target carried by primes outside the footprint has
zero covariance with every footprint feature, whence every nonzero refit is
strictly worse than the unrefit constant predictor by exactly
$\sum_p v_p\beta_p^2$, and the loss is invariant under $\beta \mapsto -\beta$, so
the direction of the fitted weights is unidentifiable — a stable structural
object with no informational content. (ii) *Exact ceiling*: for the structure
correction $C(N)=\prod_p (p-\operatorname{dial}_p(N))/(p-1)$, the exact
multiplicative smoothness bias, one has $\operatorname{cov}(C,x_p)=-1/p$
exactly, optimal weights $\beta_p^\ast=-1/(p-1)$, recalibration ceiling
$\sum_p 1/(p(p-1))$, and total signal $\prod_p(1+1/(p(p-1)))-1$; the ceiling is
strictly below the total as soon as two primes are present, the deficit being
the elementary-symmetric interaction tail. Since $\beta^\ast$ is *negative*,
any positively-shaped profile — in particular the $2/p$ profile predicted by the
motivating theory — is provably worse than not refitting. (iii) *Nonlinear
invisibility*: splitting the residue data along the footprint yields exactly
independent halves and the identity
$\mathbb{E}[(G-F)^2]=\operatorname{Var}G+\operatorname{Var}F+(\mathbb{E}F-\mathbb{E}G)^2$,
so *no* function of the footprint — linear or not — beats the constant
predictor. For the footprint $\{3,5,7\}$ the ceiling is exactly $101/420$ against
a total signal of $61/240$: a perfect refit reaches $94.6\%$ of the available
signal and the remaining $5.4\%$ is unreachable multi-prime interaction.

**Keywords:** quadratic residues, dial features, smoothness bias, orthogonal
design, recalibration ceiling, elementary symmetric functions, identifiability.

---

## 1. Introduction

### 1.1 The empirical situation

Sieve-based integer factorization spends most of its time searching for
*smooth* values of a quadratic polynomial: integers $x$ for which $x^2-N$
factors entirely over a fixed factor base. Whether a given $N$ is a fertile
target depends, in a precisely quantifiable way, on the behaviour of $N$ modulo
the small primes of the factor base. If $N$ is a quadratic non-residue modulo
$p$, then $p$ can never divide $x^2-N$; if $N$ is a nonzero quadratic residue,
then $p$ divides $x^2-N$ for two residue classes of $x$ out of $p$, twice the
generic density.

This suggests ranking candidates by a score built out of the *footprint* of
$N$ — the vector of dials at the small primes — with tunable weights. In an
operating regime with a tight threshold on the search parameter, a previously
adequate score was observed to drop. The follow-up question, and the subject of
this paper, is whether *refitting the footprint weights inside the hard regime*
recovers the drop.

The measured answer was emphatically negative: the recalibrated out-of-sample
score was $0.6050$ with confidence interval $[0.581, 0.626]$, versus $0.6288$
for the *unrefit* score with all weights set to zero — a paired gain of
$-0.0238$, negative on all five paired trials, a recovery of $-24\%$. What made
the result puzzling rather than merely disappointing is that the fitted weight
vector was highly *stable*: rank agreement $0.869$ across split halves and
$0.9433$ under leave-one-prime-out perturbation, while being anti-correlated at
$-0.93$ with the positive $2/p$ profile that the underlying theory predicted.
A reproducible structural object that damages prediction.

### 1.2 What this paper proves

We show that all three phenomena — the negative recovery, the negative-going
optimal profile, and the stable-but-empty weight vector — are theorems about
the arithmetic of quadratic residues rather than artefacts of any fitting
procedure. The argument has three layers.

**Layer 1 (exact least squares).** On any orthogonal design, the mean squared
error of an affine predictor decomposes into three squares
(Theorem 3.2). The gain of a refit over the unrefit constant predictor is at
most the *footprint energy* $\sum_p \operatorname{cov}(f,x_p)^2/v_p$
(Theorem 3.4), with equality at the projection weights; and if the covariances
vanish, every nonzero refit strictly loses (Theorem 3.6) and the loss is
invariant under sign flip of the weights (Theorem 3.7).

**Layer 2 (the arithmetic instance).** The centred dials form an exactly
orthogonal design with variances $(p-1)/p$ (Theorem 4.3). A target carried by
primes outside the footprint is exactly orthogonal to it (Theorem 4.5), giving
the qualitative no-recovery statement (Theorem 4.6). For the structure
correction we compute every quantity in closed form (Theorems 5.2–5.5), obtain
the exact ceiling and its strict deficit (Theorem 5.6, Theorem 5.7), and deduce
that positive weight profiles are strictly worse than no refit at all
(Theorem 5.9).

**Layer 3 (beyond linearity).** An exact independence split of the residue data
along the footprint (Lemma 6.1) yields a loss identity for arbitrary
predictors (Theorem 6.2), from which no function of the footprint can beat the
constant predictor (Theorem 6.3), with strict loss for every non-constant model
(Theorem 6.4).

Section 7 works the example $\{3,5,7\}$ exactly, Section 8 gives algorithms,
Section 9 discusses interpretation for practice, and Section 10 states the
conjectural interaction-order recovery curve suggested by the deficit formula.

---

## 2. Setup and definitions

Throughout, $A$ is a finite set of odd primes and all probabilistic statements
refer to the uniform measure on the finite **residue-data space**
$$\Omega_A \;=\; \prod_{p \in A} \mathbb{Z}/p\mathbb{Z}, \qquad |\Omega_A| = \prod_{p\in A} p .$$
By the Chinese Remainder Theorem this is precisely the joint distribution of
the residues $(N \bmod p)_{p\in A}$ of a uniformly random integer modulo
$\prod_{p\in A}p$; coordinates are exactly independent and exactly uniform. We
write $\mathbb{E}$ for the uniform average over $\Omega_A$.

**Definition 2.1 (Dial).** For an odd prime $p$ and $n \in \mathbb{Z}/p\mathbb{Z}$,
$$\operatorname{dial}_p(n) \;=\; \#\{x \in \mathbb{Z}/p\mathbb{Z} : x^2 = n\}
\;=\; 1 + \left(\frac{n}{p}\right) \;\in\; \{0,1,2\},$$
where $\left(\frac{\cdot}{p}\right)$ is the Legendre symbol. Thus
$\operatorname{dial}_p(n)=2$ for the $(p-1)/2$ nonzero squares, $0$ for the
$(p-1)/2$ non-squares, and $1$ at $n=0$.

**Definition 2.2 (Centred dial feature).**
$x_p(N) = \operatorname{dial}_p(N_p) - 1 = \left(\frac{N_p}{p}\right) \in \{-1,0,1\}$.

**Definition 2.3 (Footprint).** A *footprint* is a subset $S \subseteq A$ of
small primes; the *footprint features* are the family $(x_p)_{p\in S}$. The
remaining primes $A\setminus S$ are the *mid primes*.

**Definition 2.4 (Affine footprint predictor and loss).** For an intercept
$c\in\mathbb{Q}$ and weights $\beta = (\beta_p)_{p\in S}$ the predictor is
$c + \sum_{p\in S}\beta_p x_p$ and its loss is
$$\operatorname{MSE}(f;c,\beta) \;=\; \mathbb{E}\Bigl[\bigl(f - c - \textstyle\sum_{p\in S}\beta_p x_p\bigr)^2\Bigr].$$
The **zero-fit dial** is the untuned predictor $c=\mathbb{E}f$, $\beta=0$.

**Definition 2.5 (Structure correction).** The exact multiplicative smoothness
bias attached to the footprint is
$$C(N) \;=\; \prod_{p\in A} \frac{p - \operatorname{dial}_p(N_p)}{p-1}.$$
Each local factor equals $1$ at $N_p=0$, $\frac{p-2}{p-1}$ when $N_p$ is a
nonzero square (the prime is "doubly available" and the correction discounts
it), and $\frac{p}{p-1}$ when $N_p$ is a non-square.

**Definition 2.6 (Footprint energy).** For $v_p>0$ the variance of $x_p$,
$$\mathcal{E}(f) \;=\; \sum_{p\in S} \frac{\operatorname{cov}(f,x_p)^2}{v_p},
\qquad \operatorname{cov}(f,x_p) = \mathbb{E}[f\,x_p]$$
(the features being centred, the raw second moment *is* the covariance).

**Definition 2.7 (Orthogonal design).** A family $(x_i)_{i\in I}$ of observables
with positive numbers $(v_i)$ is an *orthogonal design* if
$\mathbb{E}[x_i]=0$ for all $i$, $\mathbb{E}[x_i x_j]=0$ for $i\ne j$, and
$\mathbb{E}[x_i^2]=v_i$ for all $i$.

---

## 3. Layer 1: exact least squares on an orthogonal design

Fix an orthogonal design $(x_i)_{i\in I}$ with variances $(v_i)$ on a finite
probability space, and write $\operatorname{score}_\beta = \sum_i \beta_i x_i$
and $W(\beta) = \sum_i v_i\beta_i^2$ (the *weight energy*).

**Lemma 3.1 (Moments of the score).**
$\mathbb{E}[\operatorname{score}_\beta] = 0$,
$\mathbb{E}[f\operatorname{score}_\beta] = \sum_i \beta_i \operatorname{cov}(f,x_i)$,
and $\mathbb{E}[\operatorname{score}_\beta^2] = W(\beta)$.

*Proof sketch.* Linearity gives the first two. For the third, expand the square
into $\sum_{i,j}\beta_i\beta_j \mathbb{E}[x_ix_j]$; every off-diagonal term
vanishes by orthogonality and the diagonal contributes $v_i\beta_i^2$. $\square$

**Theorem 3.2 (Exact MSE decomposition).** For every target $f$, intercept $c$
and weight vector $\beta$,
$$\operatorname{MSE}(f;c,\beta)
= (\mathbb{E}f - c)^2
+ \sum_{i} v_i\Bigl(\beta_i - \frac{\operatorname{cov}(f,x_i)}{v_i}\Bigr)^2
+ \bigl(\operatorname{Var} f - \mathcal{E}(f)\bigr).$$

*Proof sketch.* Expanding the square and applying Lemma 3.1 gives
$$\operatorname{MSE} = \mathbb{E}[f^2] - 2c\,\mathbb{E}[f] + c^2
- 2\sum_i \beta_i\operatorname{cov}(f,x_i) + W(\beta).$$
Completing the square separately in $c$ and in each $\beta_i$ — the variables
do not interact, precisely because the design is orthogonal — and using
$\operatorname{Var}f = \mathbb{E}[f^2]-(\mathbb{E}f)^2$ produces the three
stated terms. $\square$

All three terms are nonnegative, which yields the whole of Layer 1 by
inspection.

**Corollary 3.3 (Zero-fit loss).** $\operatorname{MSE}(f;\mathbb{E}f,0)=\operatorname{Var}f$.

**Theorem 3.4 (Recalibration ceiling).** For every $c$ and $\beta$,
$$\operatorname{MSE}(f;\mathbb{E}f,0) - \operatorname{MSE}(f;c,\beta) \;\le\; \mathcal{E}(f),$$
with equality exactly for $c=\mathbb{E}f$ and $\beta_i = \operatorname{cov}(f,x_i)/v_i$.
Thus $\mathcal{E}(f)$ is the *maximal achievable gain* from any reweighting.

**Theorem 3.5 (Bessel).** $\mathcal{E}(f) \le \operatorname{Var}f$: the
footprint can never explain more than the whole signal. *(Immediate from
Theorem 3.2 with the optimal $c,\beta$, whose loss is nonnegative.)*

**Theorem 3.6 (No recovery under orthogonality).** If
$\operatorname{cov}(f,x_i)=0$ for every $i$, then for every $c$ and every
$\beta$
$$\operatorname{MSE}(f;c,\beta) = \operatorname{Var}f + (\mathbb{E}f-c)^2 + W(\beta),$$
so the gain over the zero-fit dial equals $-\bigl((\mathbb{E}f-c)^2+W(\beta)\bigr) \le 0$
and is *strictly negative* whenever $\beta\ne 0$. Refitting cannot recover; it
can only lose.

**Theorem 3.7 (Unidentifiability of the weight direction).** Under the same
hypothesis the loss depends on $\beta$ only through $W(\beta)=\sum_i v_i\beta_i^2$.
In particular $\operatorname{MSE}(f;c,\beta) = \operatorname{MSE}(f;c,-\beta)$:
a fitted weight vector and its exact negation are indistinguishable to the data.
Any statement about the *direction* of $\beta$ — including its correlation with
a theoretical profile — is therefore a statement about the fitting procedure's
tie-breaking, not about the target.

**Theorem 3.8 (Cauchy–Schwarz for achievable covariance).** For every $\beta$,
$$\operatorname{cov}\bigl(f, \operatorname{score}_\beta\bigr)^2 \;\le\; \mathcal{E}(f)\cdot W(\beta).$$
*Proof sketch.* Write $\operatorname{cov}(f,\operatorname{score}_\beta)=\sum_i \beta_i\operatorname{cov}(f,x_i)
=\sum_i (\sqrt{v_i}\beta_i)(\operatorname{cov}(f,x_i)/\sqrt{v_i})$ and apply
Cauchy–Schwarz. $\square$

Theorem 3.7 already answers the identifiability puzzle in the abstract:
*stability of a fitted structure is not evidence of information*. When the
achievable gain is zero, the loss surface is an exactly round bowl centred at
$\beta=0$; any deterministic fitting pipeline will roll to the same place for
reasons entirely internal to itself, and will do so reproducibly across splits.

---

## 4. Layer 2: the dial design and localisation

We now instantiate Layer 1 on $\Omega_A$.

**Lemma 4.1 (Dial sums).** For an odd prime $p$,
$\sum_{n\in\mathbb{Z}/p}\operatorname{dial}_p(n) = p$ and
$\sum_{n\in\mathbb{Z}/p}\operatorname{dial}_p(n)^2 = 2p-1$.

*Proof sketch.* The first sum counts pairs $(x,n)$ with $x^2=n$, i.e. counts
$x$, giving $p$. For the second, $\operatorname{dial}_p$ takes the value $2$
exactly $(p-1)/2$ times, $0$ exactly $(p-1)/2$ times and $1$ once, so the sum
of squares is $4\cdot\frac{p-1}{2}+1 = 2p-1$. $\square$

**Lemma 4.2 (Local moments).** $\mathbb{E}[x_p] = 0$ and
$\mathbb{E}[x_p^2] = \dfrac{p-1}{p}$.

*Proof sketch.* $\mathbb{E}[x_p] = \frac1p(\sum_n \operatorname{dial}_p(n)) - 1 = 0$
by Lemma 4.1, and
$\mathbb{E}[x_p^2] = \frac1p\bigl((2p-1) - 2p + p\bigr) = \frac{p-1}{p}$. $\square$

**Theorem 4.3 (The dial footprint is an exactly orthogonal design).** For any
footprint $S\subseteq A$, the family $(x_p)_{p\in S}$ satisfies
$\mathbb{E}[x_p]=0$, $\mathbb{E}[x_px_q]=0$ for $p\ne q$ in $S$, and
$\mathbb{E}[x_p^2]=v_p=(p-1)/p>0$.

*Proof sketch.* The observables $x_p$ depend on disjoint coordinates of the
product space, so any average of a product of local observables factors as the
product of the local averages:
$$\mathbb{E}\Bigl[\prod_{p\in A} g_p(N_p)\Bigr] = \prod_{p\in A}\mathbb{E}[g_p].$$
Hence $\mathbb{E}[x_px_q]=\mathbb{E}[x_p]\mathbb{E}[x_q]=0$ by Lemma 4.2, and
the remaining claims are Lemma 4.2 itself. Positivity of $v_p$ uses $p\ge3$. $\square$

The design is orthogonal *exactly*, not up to sampling error; this is why every
subsequent statement is an identity.

**Definition 4.4 (Local target).** A *local target* is a product
$f(N)=\prod_{p\in A} h_p(N_p)$ of per-prime factors. The structure correction is
the local target with $h_p(n) = (p-\operatorname{dial}_p(n))/(p-1)$.

**Theorem 4.5 (Localisation of lost content).** Let $f=\prod_p h_p$ be a local
target whose footprint factors are trivial, i.e. $h_p \equiv 1$ for all
$p \in S$. Then $\operatorname{cov}(f,x_p)=0$ for every $p\in S$.

*Proof sketch.* Fix $p\in S$. The product $f\cdot x_p$ is again a product of
per-prime factors, whose $p$-th factor is $h_p\cdot x_p = x_p$. Factoring the
average as in Theorem 4.3 exhibits $\mathbb{E}[x_p]=0$ as one of the factors, so
the whole product vanishes. $\square$

**Theorem 4.6 (No-recovery, arithmetic form).** For such a target and any
$c,\beta$,
$$\operatorname{MSE}(f;\mathbb{E}f,0) - \operatorname{MSE}(f;c,\beta)
= -\Bigl((\mathbb{E}f-c)^2 + \sum_{p\in S}\tfrac{p-1}{p}\beta_p^2\Bigr) .$$
Consequently every nonzero refit is *strictly* worse than the zero-fit dial, and
$\operatorname{MSE}(f;c,\beta)=\operatorname{MSE}(f;c,-\beta)$, so the direction
of $\beta$ is unidentifiable.

*Proof.* Combine Theorem 4.5 with Theorems 3.6 and 3.7. $\square$

This is the qualitative core of the finding: *no weighting of a small-prime
footprint can capture content that lives in the mid primes*, and any attempt
pays a quantified penalty.

---

## 5. The exact ceiling for the structure correction

The structure correction is *not* orthogonal to the footprint: each dial carries
a nonzero amount of it. We compute that amount exactly and show it still does
not suffice.

**Lemma 5.1 (Local coupling).** For an odd prime $p$, with
$h_p(n)=(p-\operatorname{dial}_p(n))/(p-1)$,
$$\sum_{n\in\mathbb{Z}/p} h_p(n)\,\bigl(\operatorname{dial}_p(n)-1\bigr) = -1 .$$

*Proof sketch.* Write $\operatorname{dial}_p = 1+\chi$ with $\chi$ the Legendre
symbol, so $h_p = (p-1-\chi)/(p-1)$ and the summand is
$\chi(p-1-\chi)/(p-1)$. Using $\sum_n \chi(n)=0$ and $\sum_n\chi(n)^2=p-1$
gives $\bigl(0-(p-1)\bigr)/(p-1) = -1$. $\square$

**Theorem 5.2 (Mean).** $\mathbb{E}[C] = 1$.

*Proof sketch.* By factorisation the mean is $\prod_p \mathbb{E}[h_p]$, and
$\mathbb{E}[h_p] = \frac{1}{p}\cdot\frac{p\cdot p - p}{p-1} = 1$ using
$\sum_n\operatorname{dial}_p(n)=p$. $\square$

**Theorem 5.3 (Exact footprint signal).** For every $p\in S$,
$$\operatorname{cov}(C, x_p) = -\frac1p .$$

*Proof sketch.* Factor $\mathbb{E}[C x_p]$ over primes. All factors $q\ne p$
contribute $\mathbb{E}[h_q]=1$ (Theorem 5.2), and the $p$-th factor is
$\frac1p\sum_n h_p(n)(\operatorname{dial}_p(n)-1) = -\frac1p$ by Lemma 5.1. $\square$

**Theorem 5.4 (Optimal profile).** The optimal footprint weights are
$$\beta_p^{\ast} = \frac{\operatorname{cov}(C,x_p)}{v_p}
= \frac{-1/p}{(p-1)/p} = -\frac{1}{p-1} .$$
In particular $\beta^\ast$ is strictly *negative* at every prime and decays like
$-1/p$.

**Theorem 5.5 (Total signal).**
$$\operatorname{Var} C \;=\; \prod_{p\in A}\Bigl(1 + \frac{1}{p(p-1)}\Bigr) - 1 .$$

*Proof sketch.* $\mathbb{E}[C^2]=\prod_p \mathbb{E}[h_p^2]$, and with
$h_p = (p-1-\chi)/(p-1)$,
$$\mathbb{E}[h_p^2] = \frac{(p-1)^2 - 2(p-1)\mathbb{E}[\chi] + \mathbb{E}[\chi^2]}{(p-1)^2}
= 1 + \frac{(p-1)/p}{(p-1)^2} = 1 + \frac{1}{p(p-1)} .$$
Subtract $(\mathbb{E}C)^2 = 1$. $\square$

**Theorem 5.6 (Exact recalibration ceiling).** With footprint $S$,
$$\mathcal{E}(C) \;=\; \sum_{p\in S}\frac{\operatorname{cov}(C,x_p)^2}{v_p}
\;=\; \sum_{p \in S} \frac{1}{p(p-1)} .$$
By Theorem 3.4 this is exactly the largest gain over the zero-fit dial that any
intercept and any weight vector can achieve, and it is attained at
$c=1$, $\beta=\beta^\ast$.

Write $c_p = \dfrac{1}{p(p-1)}$, so that the ceiling is $\sum_{p} c_p$ and the
total signal is $\prod_p (1+c_p)-1$.

**Theorem 5.7 (Strict deficit).** If $A=S$ contains at least two primes then
$$\sum_{p} c_p \;<\; \prod_{p}(1+c_p) - 1,$$
i.e. $\mathcal{E}(C) < \operatorname{Var}C$ strictly. The unreachable share is
exactly the interaction tail
$$\prod_p (1+c_p) - 1 - \sum_p c_p \;=\; \sum_{\substack{T\subseteq S \\ |T|\ge 2}} \ \prod_{p\in T} c_p .$$

*Proof sketch.* Expanding the product gives all elementary symmetric functions
of $(c_p)$; the linear part is $\sum_p c_p$ and the rest is a sum of
nonnegative terms, strictly positive as soon as two $c_p$ are positive
(pairwise term $c_pc_q>0$). Equivalently, one proves
$1+\sum_p c_p \le \prod_p (1+c_p)$ by induction on the footprint and upgrades
to strictness by isolating one coordinate. $\square$

**Theorem 5.8 (Quantitative deficit bound).** For any $q \in S$,
$$\operatorname{Var}C - \mathcal{E}(C) \;\ge\; c_q \sum_{p \in S\setminus\{q\}} c_p
\;=\; \frac{1}{q(q-1)}\sum_{p\ne q}\frac{1}{p(p-1)} .$$

*Proof sketch.* Split $\prod_p(1+c_p) = (1+c_q)\prod_{p\ne q}(1+c_p)$, bound the
second factor below by $1+\sum_{p\ne q}c_p$ (Theorem 5.7's inequality) and
expand. $\square$

**Theorem 5.9 (Positive profiles are strictly worse than no refit).** Suppose
$\beta_p \ge 0$ for all $p\in S$ and $\beta_{p_0} > 0$ for some $p_0 \in S$.
Then for every intercept $c$,
$$\operatorname{MSE}(C;\mathbb{E}C, 0) \;<\; \operatorname{MSE}(C;c,\beta).$$

*Proof sketch.* By Theorem 3.2 the loss exceeds the zero-fit loss
$\operatorname{Var}C$ by
$(\mathbb{E}C-c)^2 + \sum_p v_p(\beta_p-\beta_p^\ast)^2 - \mathcal{E}(C)$; since
$\beta_p^\ast<0 \le \beta_p$ we have $(\beta_p-\beta_p^\ast)^2 \ge (\beta_p^\ast)^2$
termwise, with strict inequality at $p_0$, and $\sum_p v_p(\beta_p^\ast)^2 = \mathcal{E}(C)$. $\square$

Theorem 5.9 is the theoretical counterpart of the measured $-0.93$
anti-correlation between the fitted weights and the $2/p$ theory profile: the
sign of the optimal profile is opposite to that of the hypothesised one, so a
positively-shaped refit is worse than doing nothing, *whatever* its magnitude.

---

## 6. Layer 3: nonlinear invisibility

The results so far concern affine scores. One might object that a nonlinear
model of the same footprint could see what the linear model misses. It cannot.

Split each $N \in \Omega_A$ as $(N|_S, N|_{S^c})$, the footprint half and the
mid-prime half.

**Lemma 6.1 (Exact independence of the halves).** For any
$F : \Omega_S \to \mathbb{Q}$ and $G:\Omega_{S^c}\to\mathbb{Q}$,
$$\mathbb{E}\bigl[F(N|_S)\,G(N|_{S^c})\bigr] = \mathbb{E}[F]\cdot\mathbb{E}[G] .$$

*Proof sketch.* $\Omega_A \cong \Omega_S \times \Omega_{S^c}$ as measure spaces
with $|\Omega_A|=|\Omega_S|\cdot|\Omega_{S^c}|$; the double sum factors. $\square$

**Theorem 6.2 (Nonlinear loss identity).** Let $G$ be *any* function of the
mid-prime half and $F$ *any* function of the footprint half — no linearity, no
shape restriction, no bound on complexity. Then
$$\mathbb{E}\bigl[(G-F)^2\bigr] \;=\; \operatorname{Var}G + \operatorname{Var}F + \bigl(\mathbb{E}F-\mathbb{E}G\bigr)^2 .$$

*Proof sketch.* Expand $\mathbb{E}[(G-F)^2] = \mathbb{E}[G^2]-2\mathbb{E}[GF]+\mathbb{E}[F^2]$
and use Lemma 6.1 on the cross term: $\mathbb{E}[GF]=\mathbb{E}[G]\mathbb{E}[F]$.
Then $\mathbb{E}[G^2] = \operatorname{Var}G + (\mathbb{E}G)^2$ and similarly for
$F$, and $(\mathbb{E}G)^2 - 2\mathbb{E}G\,\mathbb{E}F + (\mathbb{E}F)^2 = (\mathbb{E}F-\mathbb{E}G)^2$. $\square$

**Theorem 6.3 (No footprint model of any kind recovers).** For every $F$,
$$\operatorname{Var}G \;=\; \mathbb{E}\bigl[(G-\mathbb{E}G)^2\bigr] \;\le\; \mathbb{E}\bigl[(G-F)^2\bigr],$$
i.e. the constant predictor $\mathbb{E}G$ — the zero-fit dial — is optimal
among *all* footprint models.

**Theorem 6.4 (Strict loss for non-constant models).** If $F$ is non-constant
then $\operatorname{Var}F>0$ and
$$\mathbb{E}[(G-F)^2] - \operatorname{Var}G = \operatorname{Var}F + (\mathbb{E}F-\mathbb{E}G)^2 > 0 .$$

The interpretation is sharp: the content lost in the hard regime is not
*badly weighted* small-prime information; it is not small-prime information at
all. Increasing model capacity on the footprint channel is not a partial
remedy — it is a strictly harmful operation, and the harm is exactly the
variance the model manufactures.

---

## 7. A fully explicit example: the footprint $\{3,5,7\}$

Take $A=S=\{3,5,7\}$, so $|\Omega_A| = 105$ and every quantity below is a
rational number computed by finite enumeration or by the formulas above; the
two agree exactly.

| quantity | value | decimal |
|---|---|---|
| $v_3, v_5, v_7$ | $2/3,\ 4/5,\ 6/7$ | $0.667,\ 0.800,\ 0.857$ |
| $\operatorname{cov}(C,x_p)$ | $-1/3,\ -1/5,\ -1/7$ | $-0.333,\ -0.200,\ -0.143$ |
| optimal weights $\beta^\ast_p$ | $-1/2,\ -1/4,\ -1/6$ | $-0.500,\ -0.250,\ -0.167$ |
| ceiling $\mathcal{E}(C)=\sum c_p$ | $\tfrac16+\tfrac1{20}+\tfrac1{42} = \tfrac{101}{420}$ | $0.240476$ |
| total signal $\operatorname{Var}C$ | $\tfrac{301}{240}-1 = \tfrac{61}{240}$ | $0.254167$ |
| reachable share | $\tfrac{101/420}{61/240} = \tfrac{404}{427}$ | $94.61\%$ |
| unreachable interaction tail | $\tfrac{61}{240}-\tfrac{101}{420}$ | $0.013690$ |

So *even a perfectly recalibrated footprint* on $\{3,5,7\}$ reaches only
$94.6\%$ of the available signal. The missing $5.4\%$ is pure multi-prime
interaction: $c_3c_5+c_3c_7+c_5c_7+c_3c_5c_7$.

Adding $11$ changes the picture only in the expected direction: the ceiling
becomes $1153/4620 \approx 0.249567$, the total $2337/8800 \approx 0.265568$,
and the reachable share drops slightly to $93.98\%$ — more primes means more
pairs, hence proportionally more interaction content.

**Model-order recovery for $\{3,5,7,11\}$.** Truncating the elementary
symmetric series at interaction order $d$ gives
$$R(d) \;=\; \sum_{1\le |T| \le d}\ \prod_{p\in T} c_p ,$$
namely $R(1)=93.975\%$, $R(2)=99.878\%$, $R(3)=99.999\%$, $R(4)=100\%$ of
$\operatorname{Var}C$. The recovery curve is therefore extremely steep at
order $2$: essentially all of the missing content is *pairwise*.

---

## 8. Algorithms

**Algorithm A (Exact recalibration ceiling).** Given a footprint $S$ of odd
primes, return the ceiling $\sum_{p\in S} \frac{1}{p(p-1)}$, the total signal
$\prod_{p\in S}(1+\frac{1}{p(p-1)})-1$, the reachable share, the optimal profile
$\beta^\ast_p=-1/(p-1)$, and the deficit. All arithmetic is rational; the cost
is $O(|S|)$ operations on rationals of size $O(\sum_p \log p)$. No enumeration
of $\Omega_A$ is required — the closed forms of Section 5 replace it.

**Algorithm B (Brute-force certification).** Enumerate $\Omega_S$ (size
$\prod_{p\in S}p$), compute all dials, and evaluate the design moments, the
covariances, the energy, the variance, and the loss at prescribed
$(c,\beta)$ in exact rational arithmetic. Cost $O(|S| \prod_p p)$, feasible for
$\prod_p p$ up to about $10^7$. Its purpose is to certify Algorithm A's closed
forms on small footprints — they agree exactly.

**Algorithm C (Interaction-order recovery curve).** Given $(c_p)_{p\in S}$,
compute the elementary symmetric polynomials $e_1,\dots,e_{|S|}$ by the
standard product recursion $\prod_p (1+c_p z)$, accumulating coefficients in
$O(|S|^2)$ operations, and return the partial sums
$R(d)=\sum_{k\le d} e_k$ against the total $\prod(1+c_p)-1 = \sum_{k\ge1}e_k$.

**Algorithm D (Optimal nonlinear footprint model).** To certify Theorem 6.3
empirically: group the enumerated residue data by footprint half, average the
target within each group (the conditional expectation, which is the pointwise
optimal footprint model), and observe that the resulting function is constant
whenever the target is carried by the mid primes. Cost $O(|\Omega_A|)$.

---

## 9. Discussion

### 9.1 Reconciling the three empirical observations

*Negative recovery.* Theorem 3.6 and Theorem 4.6 say that when the footprint
covariance vanishes, the paired gain of any refit is exactly
$-\bigl((\mathbb{E}f-c)^2+\sum_p v_p\beta_p^2\bigr)$ — a strictly negative
number for any nonzero fitted weight vector. A refit fitted on finite data will
essentially never return $\beta=0$, so the paired gain is negative on *every*
trial, which is what was observed ($5/5$ negative, mean $-0.0238$). When the
covariance does not vanish, Theorem 3.4 caps the recovery at the energy and
Theorem 5.9 shows that a positively-shaped profile overshoots past zero into
strict loss.

*Stable but empty $\beta$.* Theorem 3.7 says the loss cannot distinguish
$\beta$ from $-\beta$, hence cannot identify direction at all in the orthogonal
regime. High split-half and leave-one-out rank stability of the fitted weights
therefore measures the reproducibility of the estimator's geometry — the
conditioning of the design, the regulariser, the sample-to-sample structure of
$\operatorname{cov}(f,x_p)$ estimates — and not the presence of signal. "A
consistent structural object that is informationally empty" is an exact
description of a round loss bowl.

*Anti-correlation with the theory profile.* Theorem 5.4 computes the true
optimal profile and it is $-1/(p-1)$: negative and $1/p$-shaped. A theory
predicting a positive $2/p$-shaped profile is predicting the wrong sign, and
Theorem 5.9 turns that sign error into a guaranteed loss. The measured
correlation of $-0.93$ is not evidence of estimation pathology; it is the
arithmetic showing through.

### 9.2 Consequences for practice

1. **Keep the untuned score.** In the small-prime channel, the zero-fit
   predictor is provably optimal for mid-prime-carried content and within a
   computable $\mathcal{E}(C)$ of optimal in general. Adopting it requires no
   qualification.
2. **Compute the ceiling before you fit.** Algorithm A returns, in
   $O(|S|)$ time and before a single data point is touched, the maximum
   conceivable gain from recalibrating a footprint. If the target improvement
   exceeds $\sum_{p\in S} 1/(p(p-1))$, no amount of fitting will deliver it.
3. **Do not read stability as signal.** Report identifiability (e.g. the
   invariance $\beta \mapsto -\beta$) alongside stability; in an orthogonal
   design with vanishing covariance, the two are entirely decoupled.
4. **Capacity is not the fix.** Theorem 6.4 rules out nonlinear footprint
   models as a remedy, and quantifies the damage as $\operatorname{Var}F$.
5. **Look where the content is.** The lost content must live in the mid primes
   or in non-footprint structure. The interaction tail formula says how much of
   the small-prime channel remains unreachable and at which interaction order it
   sits.

### 9.3 Scope and limitations

All statements are exact identities on the uniform residue-data model, in which
the residues of $N$ modulo distinct primes are independent and uniform. This is
exactly correct for $N$ uniform modulo $\prod_{p\in A}p$ and is the standard
model for smoothness heuristics; for a *tilted* sampling of $N$ — which is what
a hard operating regime often amounts to — the design is no longer exactly
orthogonal and the corrections are governed by the covariance of the tilt with
the dial pattern. Quantifying that is the second conjecture below. The
structure correction is likewise the exact multiplicative bias for the
small-prime part; the mid primes enter only through the complementary factor,
which is precisely why they are orthogonal to the footprint.

---

## 10. Future work

**Conjecture 1 (Mid-prime interaction barrier).** The unreachable share is the
elementary symmetric tail $\prod_p(1+c_p)-1-\sum_p c_p$ with $c_p=1/(p(p-1))$:
it is *degree $\ge 2$* content in the dial variables, so no one-prime feature
set of any weighting can see it. We conjecture that the degree-$d$ truncation of
the Walsh/Fourier expansion of any predictor in the dial pattern variables
captures exactly
$$\sum_{1\le|T|\le d}\ \prod_{p\in T}c_p$$
of the variance, so that the recovery curve *as a function of model order* is
the partial elementary symmetric series. The degree-$1$ case is Theorem 5.6;
the general case needs the Walsh basis over the dial pattern space, which the
exact joint uniformity of the residue coordinates already supplies.

**Conjecture 2 (Tight thresholds as a measure change).** A hard operating
regime is a *tilting* of the residue-data measure, not a change of the feature
algebra: replacing the uniform average by a weighted average $w(N)\,\cdot$
breaks orthogonality of the dial design by exactly the covariance of $w$ with
the dial pattern. We expect the resulting ceiling to be the uniform ceiling
plus an explicit correction bilinear in the Fourier coefficients of $w$, and in
particular that a tilt supported on mid-prime structure *lowers* the small-prime
ceiling — a mechanism that would explain the drop and its non-recoverability
simultaneously.

**Further directions.** (i) Extend the closed forms to prime powers and to the
prime $2$, where the dial has a genuinely different local structure. (ii)
Replace the multiplicative structure correction by additive smoothness proxies
and determine whether the ceiling remains an elementary symmetric truncation.
(iii) Study the finite-sample distribution of the fitted $\beta$ in the exactly
orthogonal regime and derive the expected rank-stability under pure
tie-breaking — a null model against which measured stability figures such as
$0.869$ and $0.9433$ could be judged. (iv) Transfer across problem sizes: an
observed cross-size transfer of $0.5693$ suggests the ceiling itself moves with
the operating parameters, and the tilt framework of Conjecture 2 is the natural
setting to predict it.

---

## 11. Conclusion

The failure of recalibration to recover a lost predictive signal is, in this
setting, not a failure of methodology but a theorem. The centred quadratic
dials form an exactly orthogonal design with variances $(p-1)/p$; the structure
correction couples to them with covariance exactly $-1/p$; the best conceivable
gain from reweighting is exactly $\sum_p 1/(p(p-1))$, attained at the negative
profile $-1/(p-1)$; the total available signal is $\prod_p(1+1/(p(p-1)))-1$; and
the gap between them is the elementary symmetric interaction tail, which no
one-prime feature can reach. For content carried outside the footprint the
ceiling is exactly zero, every nonzero refit strictly loses, the direction of
the fitted weights is unidentifiable, and no nonlinear model of the footprint
does any better than the constant. The negative experimental result is thereby
converted into a positive structural claim: the lost content is genuinely
elsewhere, and we now know both how much of the small-prime channel is
reachable and precisely at which interaction order the remainder sits.
