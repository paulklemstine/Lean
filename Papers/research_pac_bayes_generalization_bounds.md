# Finite PAC–Bayes Variational Bounds and Gaussian Perturbation Certificates

**Aristotle**  
**July 25, 2026**

## Abstract

This paper develops a self-contained finite-space foundation for PAC–Bayes generalization analysis and its specialization to isotropic Gaussian perturbations. For a finite nonempty hypothesis space with strictly positive prior and posterior masses, we define expectation, relative entropy, exponential partition functions, and Gibbs tilts. We prove positivity and normalization of the tilt, Gibbs’ inequality, an exact entropy identity for exponential tilting, the finite Donsker–Varadhan change-of-measure inequality, and equality at the Gibbs posterior. From a prior-weighted exponential-moment certificate we derive a risk inequality holding uniformly over all admissible posteriors. We then analyze the scalar McAllester and Catoni formulas, including their gaps, monotonicity, denominator conditions, and upper-envelope properties. For Gaussian perturbations $Q=\mathcal N(w,\sigma_q^2I)$ relative to $P=\mathcal N(0,\sigma_p^2I)$, we give the explicit KL decomposition into mean-shift and variance-mismatch costs, prove its nonnegativity and equal-variance reduction, and insert it into a computable McAllester certificate. Finally, we establish vanishing fixed-complexity penalties and an explicit equal-variance rate. The results isolate the deterministic variational core from the sample-level probabilistic argument. They provide the ingredients for finite posterior-uniform certification while making clear that sample-level concentration, measure-theoretic extensions, and matching lower bounds remain separate tasks.

## 1. Introduction

PAC–Bayes theory studies randomized predictors by comparing a data-dependent posterior distribution $Q$ with a reference prior distribution $P$. Its characteristic feature is a risk bound that applies simultaneously to a broad class of posteriors. The complexity of selecting $Q$ is quantified by the Kullback–Leibler divergence $\operatorname{KL}(Q\|P)$ rather than by a direct count of parameters.

The theory has two conceptually distinct layers. The first is probabilistic: one proves, under random sampling, that a suitable exponential moment is controlled with high probability. The second is variational: on that event, a change-of-measure inequality converts the prior-weighted moment into a posterior-uniform risk statement. Keeping these layers separate clarifies exactly which conclusions follow from algebra and which require assumptions on data and losses.

We focus first on the finite setting, where the mechanism can be presented without measure-theoretic overhead. The key inequality is

$$
\mathbb E_Q[a]
\leq
\operatorname{KL}(Q\|P)+
\log\mathbb E_P[e^a].
$$

The exponentially tilted distribution is shown to attain equality. This yields a complete finite variational theory from the elementary logarithmic inequality $\log x\leq x-1$.

We next study two scalar PAC–Bayes expressions. McAllester’s form adds a square-root complexity penalty to empirical risk. Catoni’s form applies a nonlinear exponential transform controlled by an inverse temperature. The scalar results establish structural facts about these formulas and state precisely how a valid moment certificate turns either expression into a true-risk bound.

Finally, we consider Gaussian perturbations of a parameter vector. This specialization is particularly relevant to neural networks, where a trained vector $w$ may be randomized by isotropic Gaussian noise. The resulting KL divergence is explicit and decomposes naturally into a mean-shift term and a variance-mismatch term. Substitution produces a directly computable certificate.

The scope is deliberately precise. The finite change-of-measure theorem and its moment-to-risk consequence are established under strict positivity. The Gaussian expressions are analyzed as explicit scalar quantities. Vanishing penalties are proved for fixed parameters. A full sample-level theorem would additionally require an i.i.d. loss model, a concentration estimate, and a high-probability construction of the moment certificate. Likewise, asymptotic tightness for a classifier family would require a matching lower bound under a specified data model; only the relevant upper-bound consistency ingredient is provided here.

## 2. Finite probability distributions and information cost

Let $H$ be a finite nonempty set. A strictly positive probability mass function on $H$ is a function $q:H\to\mathbb R$ such that $q(h)>0$ for all $h\in H$ and

$$
\sum_{h\in H}q(h)=1.
$$

For a real observable $x:H\to\mathbb R$, define expectation under $q$ by

$$
\mathbb E_q[x]
:=
\sum_{h\in H}q(h)x(h).
$$

For strictly positive probability mass functions $q$ and $p$, define the Kullback–Leibler divergence

$$
\operatorname{KL}(q\|p)
:=
\sum_{h\in H}q(h)
\log\frac{q(h)}{p(h)}.
$$

Given a prior $p$ and a score $a:H\to\mathbb R$, define the exponential partition function

$$
Z_p(a):=
\sum_{h\in H}p(h)e^{a(h)}
$$

and the Gibbs tilt

$$
p_a(h):=
\frac{p(h)e^{a(h)}}{Z_p(a)}.
$$

Strict positivity ensures that every logarithm and ratio appearing below is well-defined.

### Lemma 2.1: Positivity of the partition function

If $H$ is nonempty and $p(h)>0$ for every $h$, then $Z_p(a)>0$ for every real score $a$.

**Proof sketch.** Each summand $p(h)e^{a(h)}$ is strictly positive because both factors are positive. A finite sum containing at least one strictly positive summand is strictly positive. $\square$

### Lemma 2.2: The Gibbs tilt is a probability distribution

Under the assumptions of Lemma 2.1, $p_a(h)>0$ for every $h$ and

$$
\sum_{h\in H}p_a(h)=1.
$$

**Proof sketch.** Positivity follows by dividing the positive numerator $p(h)e^{a(h)}$ by the positive partition function. Summing the definition gives $Z_p(a)/Z_p(a)=1$. $\square$

### Theorem 2.3: Gibbs’ inequality on a finite space

Let $q$ and $p$ be strictly positive probability mass functions on $H$. Then

$$
\operatorname{KL}(q\|p)\geq0.
$$

**Proof sketch.** For each $h$, apply $\log x\leq x-1$ to $x=p(h)/q(h)>0$. After negating and multiplying by $q(h)>0$, one obtains

$$
q(h)\log\frac{q(h)}{p(h)}
\geq q(h)-p(h).
$$

Summing over $H$ gives

$$
\operatorname{KL}(q\|p)
\geq
\sum_h q(h)-\sum_h p(h)=0.
$$

This proof needs no convex-analysis machinery beyond the scalar logarithm inequality. $\square$

## 3. Exact exponential tilting and change of measure

The partition function links prior expectations, posterior expectations, and relative entropy.

### Theorem 3.1: Exact KL identity for exponential tilting

Let $q$ and $p$ be strictly positive probability mass functions on finite nonempty $H$, and let $a:H\to\mathbb R$. Then

$$
\operatorname{KL}(q\|p_a)
=
\operatorname{KL}(q\|p)
-
\mathbb E_q[a]
+
\log Z_p(a).
$$

**Proof sketch.** By the definition of the tilt,

$$
\frac{q(h)}{p_a(h)}
=
\frac{q(h)}{p(h)}e^{-a(h)}Z_p(a).
$$

Taking logarithms gives

$$
\log\frac{q(h)}{p_a(h)}
=
\log\frac{q(h)}{p(h)}-a(h)+\log Z_p(a).
$$

Multiply by $q(h)$ and sum. The last term becomes $\log Z_p(a)$ because $\sum_hq(h)=1$. $\square$

### Theorem 3.2: Finite change-of-measure inequality

Under the hypotheses of Theorem 3.1,

$$
\mathbb E_q[a]
\leq
\operatorname{KL}(q\|p)+\log Z_p(a).
$$

**Proof sketch.** The tilted distribution $p_a$ is strictly positive and normalized by Lemma 2.2. Gibbs’ inequality therefore gives $\operatorname{KL}(q\|p_a)\geq0$. Substitute Theorem 3.1 and rearrange. $\square$

This is the finite Donsker–Varadhan or PAC–Bayes variational inequality. It is uniform in $q$: once $p$ and $a$ are fixed, every strictly positive posterior satisfies it.

### Theorem 3.3: Equality at the Gibbs posterior

For strictly positive $p$ and arbitrary $a$,

$$
\mathbb E_{p_a}[a]
-
\operatorname{KL}(p_a\|p)
=
\log Z_p(a).
$$

**Proof sketch.** Set $q=p_a$ in Theorem 3.1. Since $\operatorname{KL}(p_a\|p_a)=0$, rearrangement gives the identity. Equivalently, direct substitution shows

$$
\log\frac{p_a(h)}{p(h)}
=a(h)-\log Z_p(a),
$$

and normalization completes the sum. $\square$

Consequently,

$$
\log Z_p(a)
=
\max_q\left\{\mathbb E_q[a]-\operatorname{KL}(q\|p)\right\}
$$

over strictly positive probability mass functions $q$, with the maximum attained by $p_a$. This is a free-energy variational principle: expected score competes against information cost.

## 4. A posterior-uniform PAC–Bayes theorem from a moment certificate

Let $\widehat R:H\to\mathbb R$ denote empirical risk and $R:H\to\mathbb R$ true risk. Let $p$ be a strictly positive prior and $q$ an arbitrary strictly positive posterior. Fix $\eta>0$ and $\delta>0$.

### Theorem 4.1: Exponential-moment-to-risk conversion

Assume

$$
\sum_{h\in H}p(h)
\exp\!\left(\eta(R(h)-\widehat R(h))\right)
\leq\frac1\delta.
$$

Then every strictly positive posterior $q$ satisfies

$$
\mathbb E_q[R]
\leq
\mathbb E_q[\widehat R]
+
\frac{\operatorname{KL}(q\|p)+\log(1/\delta)}{\eta}.
$$

**Proof sketch.** In Theorem 3.2 choose

$$
a(h)=\eta(R(h)-\widehat R(h)).$$

Linearity of finite sums yields

$$
\mathbb E_q[a]
=
\eta\left(\mathbb E_q[R]-\mathbb E_q[\widehat R]\right).
$$

The partition function is positive. Since the logarithm is increasing and the assumed partition bound holds,

$$
\log Z_p(a)\leq\log(1/\delta).
$$

Substitute these facts into the change-of-measure inequality and divide by $\eta>0$. $\square$

The theorem is deterministic conditional on the displayed moment certificate. In a statistical application, one ordinarily proves that certificate on an event of sampling probability at least $1-\delta$ or introduces a related confidence allocation via Markov’s inequality. That sample-level concentration step is not implicit in Theorem 4.1 and must be supplied for the chosen loss and data model.

## 5. McAllester’s square-root expression

For real empirical risk $\widehat r$, real complexity $k$, sample size $n\in\mathbb N$, and confidence parameter $\delta$, define

$$
B_M(\widehat r,k,n,\delta)
:=
\widehat r+
\sqrt{
\frac{k+\log(2\sqrt n/\delta)}{2(n-1)}
}.
$$

In statistical use one takes $n>1$, $0<\delta<1$, and $k\geq0$, together with a probabilistic premise that controls true risk.

### Proposition 5.1: Exact gap and nonnegativity

For all scalar inputs for which the expression is interpreted over the reals,

$$
B_M(\widehat r,k,n,\delta)-\widehat r
=
\sqrt{
\frac{k+\log(2\sqrt n/\delta)}{2(n-1)}
}
\geq0.
$$

**Proof sketch.** The identity follows by cancellation. The inequality is the nonnegativity of the real square root. $\square$

### Proposition 5.2: Monotonicity in KL complexity

If $n>1$ and $k_1\leq k_2$, then

$$
B_M(\widehat r,k_1,n,\delta)
\leq
B_M(\widehat r,k_2,n,\delta).
$$

**Proof sketch.** The denominator $2(n-1)$ is positive. Hence increasing $k$ increases the square-root argument, and the square root is monotone. $\square$

### Proposition 5.3: Subadditivity of square-root complexity

For $x,y\geq0$,

$$
\sqrt{x+y}\leq\sqrt x+\sqrt y.
$$

**Proof sketch.** Both sides are nonnegative. Squaring the right side gives $x+y+2\sqrt{xy}\geq x+y$. $\square$

This permits a penalty containing several nonnegative contributions to be upper-bounded by a sum of simpler penalties.

### Theorem 5.4: McAllester certificate rule

Suppose a sample-level argument establishes

$$
R(q)
\leq
\widehat R(q)+
\sqrt{
\frac{\operatorname{KL}(q\|p)+\log(2\sqrt n/\delta)}{2(n-1)}
}.
$$

Then

$$
R(q)
\leq
B_M\!\left(\widehat R(q),\operatorname{KL}(q\|p),n,\delta\right).
$$

**Proof sketch.** This is substitution into the definition of $B_M$. The substantive probabilistic work is exactly the premise; the conclusion records it in scalar certificate form. $\square$

## 6. Catoni’s exponential expression

For inverse temperature $\lambda>0$, define

$$
B_C(\widehat r,k,n,\delta,\lambda)
:=
\frac{1-
\exp\!\left(-\lambda\widehat r-rac{k+\log(1/\delta)}{n}\right)}
{1-e^{-\lambda}}.
$$

### Lemma 6.1: Positive denominator

If $\lambda>0$, then

$$
1-e^{-\lambda}>0.
$$

**Proof sketch.** Since $-\lambda<0$, strict monotonicity of the exponential gives $e^{-\lambda}<e^0=1$. $\square$

### Proposition 6.2: Monotonicity in empirical risk

If $\lambda>0$ and $\widehat r_1\leq\widehat r_2$, then

$$
B_C(\widehat r_1,k,n,\delta,\lambda)
\leq
B_C(\widehat r_2,k,n,\delta,\lambda).
$$

**Proof sketch.** Increasing $\widehat r$ decreases the exponent $-\lambda\widehat r-(k+\log(1/\delta))/n$. The exponential therefore decreases, so one minus the exponential increases. Division by the positive denominator preserves the order. $\square$

### Proposition 6.3: Monotonicity in KL complexity

If $\lambda>0$, $n>0$, and $k_1\leq k_2$, then

$$
B_C(\widehat r,k_1,n,\delta,\lambda)
\leq
B_C(\widehat r,k_2,n,\delta,\lambda).
$$

**Proof sketch.** Increasing $k$ decreases the exponent by $(k_2-k_1)/n$. The same monotonicity argument as in Proposition 6.2 applies. $\square$

### Proposition 6.4: Universal scalar upper envelope

For $\lambda>0$,

$$
B_C(\widehat r,k,n,\delta,\lambda)
\leq
\frac{1}{1-e^{-\lambda}}.
$$

**Proof sketch.** The exponential is nonnegative, so $1-e^u\leq1$ for every real $u$. Divide by the positive denominator. $\square$

### Theorem 6.5: Catoni certificate rule

Suppose a Catoni exponential-moment argument establishes

$$
R(q)
\leq
\frac{1-
\exp\!\left(-\lambda\widehat R(q)-
\frac{\operatorname{KL}(q\|p)+\log(1/\delta)}{n}\right)}
{1-e^{-\lambda}}.
$$

Then

$$
R(q)
\leq
B_C\!\left(\widehat R(q),\operatorname{KL}(q\|p),n,\delta,\lambda\right).
$$

**Proof sketch.** Expand the definition of $B_C$. $\square$

If valid McAllester and Catoni premises are both available for the same true risk, then that risk lies below both corresponding expressions. No unconditional ordering between the two formulas is asserted. In particular, the Catoni scalar expression need not exceed empirical risk for arbitrary inputs; validity as a risk bound comes from its moment premise.

## 7. Gaussian perturbation posteriors

Let the parameter space be $\mathbb R^d$. Consider the isotropic Gaussian posterior and prior

$$
Q=\mathcal N(w,\sigma_q^2I),
\qquad
P=\mathcal N(0,\sigma_p^2I),
$$

where $w\in\mathbb R^d$, $\sigma_q>0$, and $\sigma_p>0$. Write $r=\lVert w\rVert$.

### Definition 7.1: Isotropic Gaussian KL complexity

The Gaussian complexity is

$$
K_G(d,r,\sigma_q,\sigma_p)
:=
\frac{r^2}{2\sigma_p^2}
+
\frac d2\left(
\frac{\sigma_q^2}{\sigma_p^2}-1-
\log\frac{\sigma_q^2}{\sigma_p^2}
\right).
$$

The first term is a mean-shift cost. The second is a variance-mismatch cost.

### Lemma 7.2: Nonnegative variance mismatch

For every $x>0$,

$$
x-1-\log x\geq0.
$$

**Proof sketch.** Rearrange $\log x\leq x-1$. Equality occurs at $x=1$. $\square$

### Theorem 7.3: Nonnegativity of Gaussian complexity

If $\sigma_q>0$ and $\sigma_p>0$, then

$$
K_G(d,r,\sigma_q,\sigma_p)\geq0.
$$

**Proof sketch.** The shift term is a square divided by a positive number. Set $x=\sigma_q^2/\sigma_p^2>0$ and apply Lemma 7.2 to the mismatch term. Its prefactor $d/2$ is nonnegative. $\square$

### Theorem 7.4: Equal-variance reduction

If $\sigma>0$, then

$$
K_G(d,r,\sigma,\sigma)
=
\frac{r^2}{2\sigma^2}.
$$

In particular,

$$
K_G(d,0,\sigma,\sigma)=0.
$$

**Proof sketch.** The variance ratio is one, and $1-1-\log1=0$. The remaining shift term vanishes when $r=0$. $\square$

### Proposition 7.5: Monotonicity in squared norm

For fixed $d$, $\sigma_q$, and $\sigma_p>0$, if $r_1^2\leq r_2^2$, then

$$
K_G(d,r_1,\sigma_q,\sigma_p)
\leq
K_G(d,r_2,\sigma_q,\sigma_p).
$$

**Proof sketch.** The variance term is unchanged, and division by $2\sigma_p^2>0$ preserves the ordering of squared norms. $\square$

### Theorem 7.6: Explicit Gaussian McAllester certificate

For $n>1$ and appropriate confidence parameter $\delta$, define

$$
C_G
:=
\widehat r+
\sqrt{
\frac{
K_G(d,r,\sigma_q,\sigma_p)+
\log(2\sqrt n/\delta)
}{2(n-1)}
}.
$$

The quantity $C_G$ is exactly the McAllester scalar expression obtained by substituting the isotropic Gaussian KL complexity. Its penalty is nonnegative, and therefore

$$
\widehat r\leq C_G.
$$

Whenever the corresponding sample-level McAllester premise holds for the Gaussian randomized predictor, its true risk is at most $C_G$.

**Proof sketch.** Substitute Definition 7.1 into the formula of Section 5. Exact equality of the computed penalty and the displayed square root is immediate. Nonnegativity follows from the square root. The final true-risk statement invokes Theorem 5.4 with the Gaussian KL value. $\square$

This theorem separates computation from probabilistic validity. The displayed number can always be calculated on a valid numerical domain. Calling it a true-risk certificate additionally requires the high-probability premise generated by a sample-level PAC–Bayes theorem.

## 8. Algorithms

### 8.1 Finite variational audit

Given arrays $p_h$, $q_h$, and $a_h$ on a finite set, compute

$$
Z=\sum_h p_he^{a_h},
\qquad
q_a(h)=\frac{p_he^{a_h}}Z,
$$

followed by

$$
L=\sum_hq_ha_h,
\qquad
U=\sum_hq_h\log\frac{q_h}{p_h}+\log Z.
$$

Theorem 3.2 predicts $L\leq U$. The slack is exactly

$$
U-L=\operatorname{KL}(q\|q_a).
$$

For $q=q_a$, the slack vanishes up to numerical roundoff. The procedure uses $O(|H|)$ arithmetic operations and $O(|H|)$ storage if the tilt is retained.

### 8.2 Gaussian certificate computation

Inputs are $d$, $r$, $\sigma_q$, $\sigma_p$, $n$, $\delta$, and $\widehat r$. Validate $d\geq0$, $n>1$, $0<\delta<1$, and positive scales. Compute the variance ratio $x=\sigma_q^2/\sigma_p^2$, then

$$
k=\frac{r^2}{2\sigma_p^2}+\frac d2(x-1-\log x).
$$

Return

$$
\widehat r+
\sqrt{\frac{k+\log(2\sqrt n/\delta)}{2(n-1)}}.
$$

This is a constant-time scalar computation once $r$ is known. Computing $r$ directly from a $d$-dimensional parameter vector costs $O(d)$ time.

### 8.3 Temperature search for Catoni’s expression

For a finite grid $\Lambda\subset(0,\infty)$, evaluate $B_C(\widehat r,k,n,\delta,\lambda)$ for each $\lambda\in\Lambda$ and return the smallest finite value and its temperature. The cost is $O(|\Lambda|)$ time and $O(1)$ auxiliary memory. If the same data are used to choose $\lambda$, a rigorous statistical deployment must account for this selection, for example by choosing the grid in advance and allocating confidence across it.

## 9. Numerical interpretation and applications

The formulas expose several practical effects.

First, increasing the sample size shrinks McAllester’s denominator-adjusted penalty. The confidence term $\log(2\sqrt n/\delta)$ grows only logarithmically, whereas the denominator grows linearly.

Second, Gaussian variance choice is not innocuous. If $\sigma_q$ is much smaller or much larger than $\sigma_p$, then $x-1-\log x$ grows, multiplied by $d/2$. In high dimension, even moderate variance mismatch can dominate the mean-shift cost. Equal variances remove this dimension-dependent mismatch entirely, although they may not minimize empirical perturbed risk.

Third, the prior scale controls the cost of the learned mean. A larger $\sigma_p$ reduces $r^2/(2\sigma_p^2)$, but prior choice must obey the rules of the sample-level theorem; a prior tuned on the same data without correction generally invalidates the intended interpretation.

For neural networks, one may flatten parameters into $w$, define $Q$ by adding Gaussian noise, estimate $\widehat R(Q)$ through repeated perturbations, and evaluate the explicit formula. The certificate then balances perturbation-averaged fit against the information cost of the Gaussian posterior. Relating this randomized performance to a deterministic network requires an additional derandomization or margin-stability argument.

## 10. Asymptotic behavior

### Theorem 10.1: Vanishing fixed square-root complexity

For every fixed $C\geq0$,

$$
\sqrt{\frac{C}{n+1}}
\longrightarrow0
\qquad(n\to\infty).
$$

**Proof sketch.** The denominator tends to infinity, so $C/(n+1)\to0$. Continuity of the square root at zero gives the result. $\square$

### Theorem 10.2: Vanishing Gaussian McAllester argument

Fix $d$, $r$, positive $\sigma_q$, positive $\sigma_p$, and $\delta>0$. Then

$$
\frac{
K_G(d,r,\sigma_q,\sigma_p)+
\log(2\sqrt n/\delta)
}{2(n-1)}
\longrightarrow0.
$$

**Proof sketch.** The Gaussian KL term is constant in $n$. Expand the logarithm as

$$
\log(2\sqrt n/\delta)
=
\log2+\tfrac12\log n-\log\delta.
$$

Constants divided by $n-1$ vanish, and $\log n/(n-1)\to0$. $\square$

By continuity, the associated square-root penalty also converges to zero.

### Theorem 10.3: Equal-variance rate

Suppose $\sigma>0$ and $r^2\leq C$. For every $n>1$,

$$
\frac{K_G(d,r,\sigma,\sigma)}{n}
=
\frac{r^2}{2\sigma^2n}
\leq
\frac{C}{2\sigma^2n}.
$$

**Proof sketch.** Apply Theorem 7.4 and divide $r^2\leq C$ by the positive quantity $2\sigma^2n$. $\square$

These results show consistency of the complexity contribution when parameters remain fixed. They do not establish asymptotic tightness for linear classifiers. Tightness requires a data-generating distribution, a loss, margin or noise assumptions, and a lower bound matching the upper rate.

## 11. Discussion and limitations

The finite theory identifies a minimal chain of reasoning. Positivity normalizes the Gibbs tilt. The scalar inequality $\log x\leq x-1$ proves nonnegative relative entropy. The exact tilt identity then yields change of measure, and a moment certificate yields posterior-uniform risk control. No step in this chain requires an assumed variational conclusion.

Strict positivity is convenient but restrictive. Standard relative entropy permits zero posterior mass and treats positive posterior mass outside prior support as infinite cost. A support-aware finite formulation or a measure-theoretic formulation using Radon–Nikodym derivatives would remove this limitation.

The scalar McAllester and Catoni formulas should also be interpreted carefully. Their algebraic properties do not by themselves create a high-probability statement. The true-risk premises arise from concentration inequalities under explicit assumptions, commonly bounded i.i.d. losses. The Catoni expression additionally depends on temperature selection. The Gaussian formula, while explicit, must ultimately be connected to actual Gaussian probability measures and to the empirical behavior of randomized predictors.

The asymptotic conclusions are upper-bound statements. A vanishing penalty means that the certificate approaches empirical randomized risk under fixed complexity; it does not show that the rate cannot be improved. Claims of tightness demand lower bounds.

## 12. Future work

Several extensions follow naturally.

1. **Measure-theoretic change of measure.** Extend the finite theorem to measurable hypothesis spaces using Radon–Nikodym derivatives and extended-real relative entropy, with absolute continuity replacing strict positivity.
2. **Sample-level McAllester theorem.** Introduce i.i.d. bounded losses, prove an exponential-moment estimate through Hoeffding-type arguments, and use Markov’s inequality to construct one event uniform over posteriors.
3. **Sample-level Catoni theorem.** Derive the nonlinear transform from a Bernoulli exponential-moment inequality, establish monotonicity of its inverse, and treat temperature optimization with valid confidence accounting.
4. **Measure-level Gaussian perturbations.** Derive the isotropic Gaussian KL formula from densities and insert it into a sample-level theorem for randomized neural predictors.
5. **Derandomization and margin control.** Bound the difference between perturbation-averaged loss and deterministic-network loss through layerwise, spectral, or margin stability.
6. **Linear-classifier tightness.** Under a specified distribution and margin/noise model, prove matching upper and lower asymptotic rates.
7. **Sharper finite interfaces.** Replace strictly positive real mass functions with probability mass functions carrying explicit support conditions, and package the Gibbs posterior as a normalized distribution.

## 13. Conclusion

The finite PAC–Bayes mechanism is an exact variational statement: exponential tilting converts a prior into the posterior that optimally balances expected score and relative entropy. A controlled prior exponential moment then implies a risk bound simultaneously for all admissible posteriors. McAllester and Catoni formulas provide two scalar realizations of this principle, with transparent monotonicity and domain conditions. Isotropic Gaussian perturbations make the information cost explicit and decompose it into mean-shift and variance-mismatch terms, yielding computable bounds for high-dimensional parameter vectors. Fixed-complexity penalties vanish with sample size, while stronger claims—sample-level validity, deterministic-network control, and classifier tightness—require the additional probabilistic and lower-bound theory identified above.
