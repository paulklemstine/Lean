# Additive Compression and PAC-Bayes Budgets for Overparameterized Neural Networks

**Aristotle**  
**July 30, 2026**

## Abstract

We present an algebraic framework that combines compression complexity and posterior information into a single generalization budget for neural-network profiles. A profile records ambient parameter dimension, quotient complexity, code length, posterior Kullback–Leibler divergence, and sample size. Its effective complexity is the sum of quotient complexity, code length, and posterior divergence. We prove that any simultaneous compression and posterior certificate upper-bounds this effective complexity; if the certificate budget is at most $n\varepsilon^2$, the associated square-root complexity radius is at most $\varepsilon$. A standard confidence specialization uses a posterior allowance of $\log(1/\delta)$. We also introduce a retained-architecture complexity equal to the number of active parameters plus the sum of layer widths, and derive an explicit architecture-to-sample-complexity criterion. Strict compression strictly improves the radius at every positive sample size. Most importantly, increasing only the ambient parameter dimension preserves the certificate and every guarantee derived from it. Explicit profiles with arbitrarily many more parameters than samples, fixed nonzero effective complexity, and valid generalization budgets demonstrate that ambient dimension alone does not determine certified sample complexity. The results isolate a reusable deterministic core for PAC-Bayes and compression analyses and clarify the precise sense in which overparameterized networks can generalize.

## 1. Introduction

Classical capacity intuition associates a larger hypothesis class with a greater risk of overfitting. Neural networks challenge a simplistic version of that intuition: a trained network may have more adjustable parameters than training examples and still perform well on unseen data. Resolving this tension requires separating the dimension of the parameter space from the complexity of the predictor selected within it.

Several mechanisms can make realized complexity much smaller than raw dimension. Different parameter vectors may represent the same function because hidden units can be permuted or rescaled. Many weights may be pruned, quantized, or reconstructed from a short code. A learned distribution over predictors may remain close to a prior distribution, producing a small information cost. These observations motivate two broad families of bounds. Compression bounds charge for describing a predictor; PAC-Bayes bounds charge for moving from a prior to a data-dependent posterior. Their mathematical interpretations differ, but their complexity contributions can be organized additively.

This paper develops that additive organization. The framework is deliberately algebraic. It begins after the application-specific probabilistic work has produced valid quotient, coding, and posterior-divergence quantities. It then answers four questions. How do these quantities combine? How does a combined budget translate into a square-root radius? How can a retained architecture control sample complexity? What happens when the ambient network is widened without changing any effective term?

The answers are concise. If $q$ is quotient complexity, $c$ is code length, $K$ is posterior divergence, and $n$ is sample size, define

$$
R=q+c+K.
$$

A certificate with $q+c\le B$ and $K\le J$ gives $R\le B+J$. If $B+J\le n\varepsilon^2$, then $R\le n\varepsilon^2$ and the radius $\sqrt{R/n}$ is at most $\varepsilon$ whenever $n>0$. In the common confidence specialization, $J$ is bounded by $\log(1/\delta)$. If a network's quotient and coding costs are bounded by the number of retained parameters plus the sum of layer widths, that architectural quantity replaces raw parameter count in the sample criterion. Finally, adding unused ambient parameters changes none of $q$, $c$, $K$, or $n$, so it changes neither the certificate nor the radius.

The contribution is not a new probabilistic PAC-Bayes inequality for a particular loss. Rather, it is a self-contained deterministic calculus for composing valid bounds supplied by such inequalities. This separation makes assumptions transparent and prevents raw parameter dimension from re-entering an argument where it plays no mathematical role.

## 2. Complexity profiles and certificates

### 2.1 Effective-complexity profiles

**Definition 2.1 (Effective-complexity profile).** An effective-complexity profile is a tuple

$$
P=(d,q,c,K,n),
$$

where $d,q,c,n$ are nonnegative integers and $K$ is a real number. The components are interpreted as follows:

- $d$ is the ambient parameter dimension;
- $q$ is quotient complexity, measuring the discrete cost remaining after equivalent parameterizations are identified;
- $c$ is the code length needed to specify a representative predictor;
- $K$ is a posterior information cost, typically a Kullback–Leibler divergence;
- $n$ is the number of samples.

The **effective complexity** of $P$ is

$$
R(P)=q+c+K.
$$

For divergence-based applications one has $K\ge0$. The algebraic upper-bound results need only the inequalities stated in each theorem; nonnegativity becomes essential when interpreting square roots or certificates as information quantities.

**Definition 2.2 (Generalization at a prescribed scale).** For real numbers $\varepsilon$ and $\delta$, a profile $P$ generalizes at scale $(\varepsilon,\delta)$ when

$$
\varepsilon>0,\qquad \delta>0,\qquad R(P)\le n\varepsilon^2.
$$

This definition packages the deterministic numerical condition that appears after a probabilistic theorem has translated its confidence parameter into a complexity budget. It does not by itself assert a probability-of-error statement. In applications, the semantics of $\delta$ and the empirical-loss terms come from the chosen PAC-Bayes or compression theorem.

### 2.2 Simultaneous certificates

**Definition 2.3 (Compression–posterior certificate).** A certificate for $P$ consists of a nonnegative integer $B$, called the structural budget, and a real number $J$, called the posterior budget, satisfying

$$
q+c\le B,
$$

$$
K\le J,
$$

and $K\ge0$. The total certified budget is

$$
T=B+J.
$$

The structural budget merges quotient and coding costs. This grouping is convenient because both are discrete description costs, whereas $J$ is supplied by a posterior comparison. Other decompositions are possible, but the resulting addition principle is the same.

## 3. Additive budget theorems

**Theorem 3.1 (Certificate domination).** For every effective-complexity profile $P$ and every compression–posterior certificate with total budget $T$,

$$
R(P)\le T.
$$

**Proof sketch.** The certificate gives $q+c\le B$ and $K\le J$. Addition preserves order, so

$$
q+c+K\le B+J.
$$

The left side is $R(P)$ and the right side is $T$. $\square$

This elementary theorem provides the interface between independently derived bounds. One analysis can establish $q+c\le B$ by constructing a quotient code; another can establish $K\le J$ by selecting a prior and posterior. Neither argument needs to reproduce the other.

**Theorem 3.2 (Unified certificate criterion).** Let $P$ have sample size $n$, and let a certificate have total budget $T$. If $\varepsilon>0$, $\delta>0$, and

$$
T\le n\varepsilon^2,
$$

then $P$ generalizes at scale $(\varepsilon,\delta)$.

**Proof sketch.** Theorem 3.1 gives $R(P)\le T$. Composing this inequality with $T\le n\varepsilon^2$ yields $R(P)\le n\varepsilon^2$. Together with positivity of $\varepsilon$ and $\delta$, this is precisely Definition 2.2. $\square$

The criterion gives an explicit sufficient sample threshold. Whenever $\varepsilon>0$,

$$
n\ge\frac{T}{\varepsilon^2}
$$

is sufficient, subject to integer rounding when selecting an actual sample count.

**Corollary 3.3 (Confidence-specialized compression criterion).** Suppose $\varepsilon>0$ and $\delta>0$. If the posterior budget satisfies

$$
J\le\log(1/\delta)
$$

and the structural and confidence budgets satisfy

$$
B+\log(1/\delta)\le n\varepsilon^2,
$$

then $P$ generalizes at scale $(\varepsilon,\delta)$.

**Proof sketch.** Since $T=B+J$, the posterior inequality gives

$$
T\le B+\log(1/\delta).
$$

The second hypothesis therefore implies $T\le n\varepsilon^2$, and Theorem 3.2 applies. $\square$

No restriction such as $\delta<1$ is needed for the algebraic implication itself. In the usual probabilistic interpretation one takes $0<\delta<1$, ensuring $\log(1/\delta)>0$ and identifying $\delta$ as a failure probability.

## 4. Square-root radii and strict improvement

**Definition 4.1 (Complexity radius).** For real complexity $x$ and real sample count $s$, define

$$
\rho(x,s)=\sqrt{\frac{x}{s}}.
$$

The statistical interpretation assumes $x\ge0$ and $s>0$.

**Theorem 4.2 (Budget-to-radius conversion).** Let $P$ have positive integer sample size $n$. If $\varepsilon\ge0$ and

$$
R(P)\le n\varepsilon^2,
$$

then

$$
\rho(R(P),n)\le\varepsilon.
$$

**Proof sketch.** Positivity of $n$ permits division of the budget inequality by $n$, giving $R(P)/n\le\varepsilon^2$. The square-root function is monotone on nonnegative values, and $\sqrt{\varepsilon^2}=\varepsilon$ because $\varepsilon\ge0$. Hence $\sqrt{R(P)/n}\le\varepsilon$. $\square$

This theorem explains the familiar scaling $\rho\asymp\sqrt{R/n}$. At fixed complexity, multiplying the sample size by four halves the radius. At fixed sample size, reducing complexity by a factor of four also halves it.

**Theorem 4.3 (Strict compression improvement).** Let $x$ and $y$ be real complexity values and let $s>0$. If

$$
0\le x<y,
$$

then

$$
\rho(x,s)<\rho(y,s).
$$

**Proof sketch.** Division by the positive number $s$ preserves strict order, so $x/s<y/s$. Since $x/s\ge0$, strict monotonicity of the square-root function yields the claim. $\square$

Thus every genuine reduction in certified complexity produces a genuine improvement in the radius. The result does not depend on the magnitude of the sample size, only on its positivity.

## 5. Architecture-sensitive complexity

### 5.1 Retained architecture summaries

**Definition 5.1 (Architecture summary).** A finite architecture summary consists of layer widths

$$
(w_1,\ldots,w_L),
$$

an ambient parameter count $d$, and an active parameter count $a$, with $a\le d$. Its retained structural complexity is

$$
S(A)=a+\sum_{\ell=1}^{L}w_\ell.
$$

The active parameters are those retained by a compression certificate. The width sum supplies a simple charge for recording the layer structure. This choice is intentionally transparent rather than universally optimal; an application can replace it with any certified upper bound on $q+c$.

**Theorem 5.2 (Architecture-to-sample-complexity bridge).** Let $P$ have sample size $n$, and let $A$ be an architecture summary. Suppose $\varepsilon>0$, $\delta>0$, and

$$
q+c\le S(A),
$$

$$
K\le\kappa.
$$

If

$$
S(A)+\kappa\le n\varepsilon^2,
$$

then $P$ generalizes at scale $(\varepsilon,\delta)$.

**Proof sketch.** Adding the first two hypotheses gives

$$
R(P)=q+c+K\le S(A)+\kappa.
$$

The sample-budget hypothesis then gives $R(P)\le n\varepsilon^2$. Positivity of $\varepsilon$ and $\delta$ completes Definition 2.2. $\square$

**Corollary 5.3 (Explicit sample threshold).** Under the hypotheses controlling $q+c$ and $K$, any integer sample size satisfying

$$
n\ge\frac{S(A)+\kappa}{\varepsilon^2}
$$

meets the budget condition, provided $\varepsilon>0$.

**Proof sketch.** Multiply the displayed inequality by the positive quantity $\varepsilon^2$ to obtain $S(A)+\kappa\le n\varepsilon^2$, then apply Theorem 5.2. $\square$

The theorem distinguishes available parameters from retained parameters. If pruning reduces $a$ while preserving the predictor and its posterior budget, the certified numerator decreases. If a wider architecture adds inactive channels without changing $a$ or the width-description convention used in the certificate, its ambient parameter count can grow without affecting the effective rate. When added widths must themselves be described, their cost should be included honestly in $S(A)$; invariance applies only to changes that leave all certified effective terms unchanged.

### 5.2 Numerical illustration

Take layer widths $(100,50,10)$, active count $a=240$, posterior allowance $\kappa=90$, and sample size $n=4{,}000$. Then

$$
S(A)=240+100+50+10=400,
$$

and the total numerator is at most $490$. The radius is bounded by

$$
\sqrt{\frac{490}{4000}}=0.35.
$$

If an improved compression procedure reduces the active count to $80$ while leaving all other terms fixed, the structural complexity becomes $240$ and the radius becomes

$$
\sqrt{\frac{330}{4000}}\approx0.2872.
$$

The strict improvement is guaranteed by Theorem 4.3. These calculations illustrate conditional consequences of certified budgets; they do not establish that a specific empirical network has those budgets without an accompanying coding and posterior analysis.

## 6. Overparameterization invariance

**Definition 6.1 (Ambient overparameterization).** For a nonnegative integer $k$, the $k$-fold ambient enlargement of

$$
P=(d,q,c,K,n)
$$

is

$$
P^{+k}=(d+k,q,c,K,n).
$$

Only the raw parameter dimension changes.

**Theorem 6.2 (Certificate preservation under ambient enlargement).** If $C$ is a compression–posterior certificate for $P$, then for every $k\ge0$ there is a certificate for $P^{+k}$ with exactly the same structural budget, posterior budget, and total budget. Consequently, every generalization guarantee derived from $C$ is also valid for $P^{+k}$.

**Proof sketch.** The defining certificate inequalities mention $q$, $c$, and $K$, all of which are unchanged by ambient enlargement. Hence the same $B$ and $J$ satisfy the same inequalities. The sample size is also unchanged, so a bound $B+J\le n\varepsilon^2$ remains true. Theorem 3.2 then supplies the same guarantee. $\square$

This theorem is exact but conditional. It does not say that arbitrary widening preserves the learned function or its certificate. It says that if widening changes only ambient dimension—for example, by adding provably unused coordinates—then ambient dimension alone creates no penalty.

**Theorem 6.3 (Arbitrarily overparameterized profiles with fixed nonzero complexity).** Let $n,e$ be nonnegative integers and let $\varepsilon>0$ and $\delta>0$. If

$$
1\le n\varepsilon^2,
$$

then there exists an effective-complexity profile $P$ such that

$$
d=n+e+1,
$$

$$
R(P)=1,
$$

$$
d>n,
$$

and $P$ generalizes at scale $(\varepsilon,\delta)$.

**Proof sketch.** Choose

$$
P=(n+e+1,1,0,0,n).
$$

Then $R(P)=1+0+0=1$. Since $e\ge0$, $n+e+1>n$. The assumed inequality $1\le n\varepsilon^2$ is exactly the required effective-complexity budget. Together with $\varepsilon>0$ and $\delta>0$, it proves the claim. $\square$

Because $e$ is arbitrary, the ratio or difference between ambient dimension and sample size can grow without changing effective complexity. This construction establishes a logical separation: no theorem depending only on the inequality $d>n$ can conclude failure of every effective-complexity certificate.

## 7. Algorithms

### 7.1 Certificate evaluation

Given $(q,c,K,n)$, budgets $(B,J)$, and target $(\varepsilon,\delta)$, a certificate evaluator performs four checks:

1. verify $q+c\le B$;
2. verify $K\le J$ and $K\ge0$;
3. compute $T=B+J$;
4. test $\varepsilon>0$, $\delta>0$, and $T\le n\varepsilon^2$.

The procedure uses constant arithmetic time once the summary values are available. Its output is only as sound as the supplied component bounds; deriving $q$, $c$, or $K$ may be the dominant application-specific computation.

### 7.2 Architecture budgeting

For widths $(w_1,\ldots,w_L)$ and active count $a$, compute

$$
S=a+\sum_{\ell=1}^{L}w_\ell.
$$

Then add a posterior allowance $\kappa$, compute the radius $\sqrt{(S+\kappa)/n}$ for $n>0$, and compute the minimum integer sample count

$$
\left\lceil\frac{S+\kappa}{\varepsilon^2}\right\rceil.
$$

The runtime is $O(L)$ and the auxiliary space is $O(1)$ apart from storing the width list.

### 7.3 Compression comparison

For candidate certified complexities $x_1,\ldots,x_m$ at a common positive sample size $n$, compute each radius $\sqrt{x_i/n}$ and rank candidates by $x_i$. Because square root and division by $n$ are strictly increasing on nonnegative inputs, ranking by complexity and ranking by radius are identical. The computation takes $O(m)$ time, or $O(m\log m)$ if a full sorted ordering is required.

## 8. Applications and interpretation

The framework applies whenever one can supply honest bounds on its three effective terms.

**Pruning and sparsification.** A sparse subnetwork can reduce active count and code length. The architecture theorem turns those reductions into a smaller sufficient sample budget, provided the cost of describing locations and values is included.

**Quantization.** Replacing high-precision weights with a finite alphabet can reduce code length. If predictive behavior is preserved and the quotient term is unchanged, Theorem 4.3 yields a strictly smaller radius.

**Symmetry reduction.** Hidden-unit permutations, positive-homogeneous rescalings, or other equivalences can place many parameter vectors in one functional class. Coding the class rather than a raw vector can lower $q$.

**Prior-informed learning.** A prior centered on reusable structure can reduce posterior divergence $K$ when the learned posterior remains nearby. The confidence-specialized criterion then combines this information advantage with compression.

**Safe widening.** Identity channels, zero residual channels, or dormant coordinates can enlarge the parameterization while preserving a predictor and its effective certificate. Theorem 6.2 formalizes why such widening does not automatically worsen a complexity bound.

These applications share a caution. A raw network does not arrive with a small certificate merely because it is large, sparse-looking, or easy to describe informally. The quotient relation, code, posterior, and all associated inequalities must be specified and justified. The present results then compose those ingredients without adding hidden dependence on ambient dimension.

## 9. Discussion and limitations

The framework's strength is modularity. Compression and PAC-Bayes analyses can be developed separately, then joined through addition. Architecture appears through a certified structural summary rather than a universal parameter-count heuristic. Overparameterization is treated as an explicit transformation, making clear exactly which quantities must remain fixed for invariance.

The same modularity marks the limits of the results. First, the framework does not derive a loss-specific stochastic generalization inequality; it captures the numerical core that remains once such an inequality is available. Second, it does not show that a training algorithm will discover a low-complexity solution. Third, the additive budget may be conservative. Compression and posterior information can encode overlapping structure, and a sharper theory might use a minimum or a joint code rather than their sum. Fourth, the architecture summary $a+\sum w_\ell$ is one sufficient proxy, not a uniquely optimal measure. Finally, an ambient enlargement that changes optimization dynamics, posterior divergence, or functional behavior falls outside the invariance theorem.

These limitations prevent an overly broad conclusion. The results do not claim that all overparameterized networks generalize. They prove that overparameterization alone is compatible with generalization, and that valid effective-complexity certificates are insensitive to parameters that do not alter their ingredients.

## 10. Future work

Several extensions are natural. Layerwise codes may compose subadditively, with strict savings when adjacent layers share symmetry. Margin information may control quotient complexity for positively homogeneous classifiers. Compression length and posterior divergence may admit a minimum principle when both describe the same posterior. Residual networks may support width-independent bounds under controlled path norms. Finally, free actions of finite symmetry groups should produce explicit savings proportional to the logarithm of group order.

Each direction asks for more than algebra: it requires a concrete construction connecting network function, data, code, and posterior. If established, the resulting bounds would plug directly into the certificate and radius theorems developed here.

## 11. Worked confidence calculation

Consider a profile with quotient complexity $q=120$, code length $c=180$, posterior divergence $K=40$, and sample size $n=10{,}000$. A structural certificate may take $B=300$, while a posterior certificate may take $J=40$. The total certified budget is therefore

$$
T=300+40=340.
$$

Theorem 3.1 gives $R(P)\le340$; in this example equality holds because $R(P)=120+180+40=340$. The associated radius is

$$
\rho(R(P),n)=\sqrt{\frac{340}{10{,}000}}\approx0.1844.
$$

Thus every target $\varepsilon\ge0.1844$ meets the square-root budget. For example, $\varepsilon=0.2$ gives

$$
T=340\le10{,}000(0.2)^2=400.
$$

For a confidence specialization with $\delta=0.01$, one has $\log(1/\delta)=\log(100)\approx4.605$. A posterior allowance $J=40$ would not satisfy $J\le\log(100)$, so that particular confidence certificate would fail even though the generic certificate succeeds. This distinction illustrates why component checks must not be skipped: a total numerical budget does not retroactively establish a stronger, specifically structured posterior bound.

Now suppose a better prior lowers the posterior divergence and its certified allowance $J$ to $4$ while the structural budget remains $300$. The new total is $304$, the radius is approximately $0.1744$, and the confidence inequality $4\le\log(100)$ holds. Since

$$
300+\log(100)\approx304.605\le400,
$$

Corollary 3.3 certifies the target scale $(0.2,0.01)$. This example shows the complete pipeline: verify each component, aggregate the permitted budgets, compare with the sample–accuracy product, and only then interpret the resulting radius and confidence.

## 12. Conclusion

Generalization budgets for neural networks need not scale with every available parameter. Quotient complexity, code length, and posterior divergence combine into an effective complexity that is upper-bounded by a simultaneous certificate. A certificate below $n\varepsilon^2$ yields the target scale, and strict compression strictly improves the associated square-root radius. Retained architecture supplies a direct sample-complexity bridge, while ambient enlargement preserves all certificate-derived guarantees when effective terms remain unchanged. Explicit profiles with fixed nonzero complexity and arbitrarily large parameter surplus show why raw dimension cannot by itself settle the generalization question. The decisive quantity is not the size of the space a network could use, but the certified information required to identify the predictor it actually uses.
