# Wilson’s Epsilon Expansion as an Exact Algebraic Model of the Truncated Renormalization-Group Flow

**Aristotle**  
**29 July 2026**

## Abstract

We study the polynomial renormalization-group model obtained from the one-loop beta function and two-loop anomalous dimension of the one-component quartic scalar theory near four dimensions. Writing $\varepsilon=4-d$, we take

$$
\beta(\varepsilon,g)=-\varepsilon g+3g^2,
\qquad
\eta(g)=\frac{g^2}{6}.
$$

The analysis is deliberately algebraic: the perturbative coefficients are treated as specified rational diagram data, and all subsequent claims are derived exactly. We classify every zero of the beta function, obtaining the Gaussian fixed point $g=0$ and the Wilson–Fisher fixed point $g_* = \varepsilon/3$. For $d<4$, the latter is positive, nonzero, and has linearized beta-function slope $\varepsilon>0$. Two equal sunset-diagram weights of $1/108$ sum to $1/54$, and substitution of $g_*$ into the anomalous dimension gives $\eta=\varepsilon^2/54$. With an explicit local definition of third-order remainder, we prove that adding any $O(\varepsilon^3)$ contribution preserves the expansion $\eta(\varepsilon)=\varepsilon^2/54+O(\varepsilon^3)$. We also disprove two overstrong extrapolations: uniqueness of the beta-function zero for every $\varepsilon$, and positivity of the non-Gaussian point when $\varepsilon<0$. Numerical algorithms and examples illustrate the fixed points, local slopes, diagram sum, and remainder bounds. The results establish the exact consequences of the stated truncation without claiming a derivation of diagram coefficients from regularized integrals or a nonperturbative construction of the field theory.

## 1. Introduction

The renormalization group describes how effective parameters change when the observational scale changes. A field theory is represented by a point in a space of couplings, and scale transformations generate a flow through that space. The beta function is the velocity of this flow. Its zeros are fixed points, at which the theory is scale invariant and critical exponents can be extracted.

Quartic scalar theory provides the canonical setting for the epsilon expansion. Four dimensions constitute the upper critical dimension for the quartic interaction in the perturbative picture. One therefore writes

$$
\varepsilon=4-d
$$

and develops quantities of interest as series near $\varepsilon=0$. When $d<4$ is close to $4$, the parameter $\varepsilon$ is small and positive. A nonzero fixed point then appears at a coupling proportional to $\varepsilon$, allowing critical exponents to be computed order by order.

This paper isolates the exact algebraic content of the one-component calculation in a fixed normalization. The one-loop beta function is quadratic in the coupling, while the first nonzero term of the anomalous dimension is quadratic in the coupling and therefore contributes at order $\varepsilon^2$ after fixed-point substitution. The analysis has three purposes.

First, it states and proves the fixed-point claims without silently ignoring the Gaussian solution. Second, it makes the $O(\varepsilon^3)$ remainder statement explicit as a local inequality. Third, it distinguishes conclusions that genuinely follow from the truncated polynomial data from stronger claims that fail by elementary counterexample.

The resulting model is finite and transparent, but it retains the logical architecture of the perturbative argument: diagrammatic coefficients determine flow functions; zeros of the beta function determine candidate scale-invariant theories; and evaluation of the anomalous dimension at the interacting zero determines the leading anomalous exponent.

## 2. Algebraic perturbative model

### 2.1 Dimension parameter and running coupling

Let $d\in\mathbb{R}$ denote the dimension parameter and define

$$
\varepsilon=4-d.
$$

Let $g\in\mathbb{R}$ be the renormalized quartic coupling in the chosen normalization. The sign of $\varepsilon$ separates the regions below and above four dimensions:

- $d<4$ if and only if $\varepsilon>0$;
- $d=4$ if and only if $\varepsilon=0$;
- $d>4$ if and only if $\varepsilon<0$.

### 2.2 One-loop beta function

**Definition 2.1 (truncated beta function).** The one-loop beta function is

$$
\beta(\varepsilon,g)=-\varepsilon g+3g^2.
$$

A fixed point at a specified $\varepsilon$ is a real number $g$ satisfying $\beta(\varepsilon,g)=0$.

The coefficient $-\varepsilon$ reflects the engineering scaling of the interaction away from four dimensions, while the quadratic coefficient $3$ is the one-loop interaction correction in the selected normalization.

### 2.3 Wilson–Fisher coupling

**Definition 2.2 (Wilson–Fisher candidate).** Define

$$
g_*(\varepsilon)=\frac{\varepsilon}{3}.
$$

This is called the Wilson–Fisher candidate before its fixed-point property is established. Unlike $g=0$, it is non-Gaussian whenever $\varepsilon\ne0$.

### 2.4 Two-loop anomalous dimension

**Definition 2.3 (truncated anomalous dimension).** The coupling-dependent two-loop truncation of the anomalous dimension is

$$
\eta(g)=\frac{g^2}{6}.
$$

Since $g_*(\varepsilon)$ is of first order in $\varepsilon$, evaluating this expression at the fixed point produces a term of second order in $\varepsilon$.

### 2.5 Diagram weights

**Definition 2.4 (sunset weights).** The relevant finite diagram census consists of two equal rational contributions,

$$
w_1=w_2=\frac{1}{108}.
$$

These weights encode the two-loop coefficient after fixed-point substitution. They are input data of the present algebraic model; their derivation from graph enumeration, symmetry factors, and regularized momentum integrals lies outside the present scope.

### 2.6 Third-order remainder at the origin

**Definition 2.5 (local third-order bound).** A function $r:\mathbb{R}\to\mathbb{R}$ is of order three at zero if there exist constants $C>0$ and $\delta>0$ such that, for every real $\varepsilon$,

$$
|\varepsilon|<\delta
\quad\Longrightarrow\quad
|r(\varepsilon)|\le C|\varepsilon|^3.
$$

We write $r(\varepsilon)=O(\varepsilon^3)$ as $\varepsilon\to0$ for this property. This elementary formulation supplies exactly the estimate required for the epsilon expansion and avoids ambiguity about the point and variable of the asymptotic statement.

## 3. Complete fixed-point analysis

### 3.1 Existence of the interacting fixed point

**Theorem 3.1 (Wilson–Fisher fixed-point equation).** For every real $\varepsilon$,

$$
\beta\!\left(\varepsilon,g_*(\varepsilon)\right)=0.
$$

**Proof sketch.** Substitute $g_*(\varepsilon)=\varepsilon/3$ into the beta function:

$$
\beta\!\left(\varepsilon,\frac{\varepsilon}{3}\right)
=-\varepsilon\frac{\varepsilon}{3}
+3\left(\frac{\varepsilon}{3}\right)^2
=-\frac{\varepsilon^2}{3}+\frac{\varepsilon^2}{3}=0.
$$

Thus the candidate is a fixed point for every real value of the dimension parameter. $\square$

### 3.2 Classification of all fixed points

**Theorem 3.2 (complete classification of one-loop fixed points).** For all real $\varepsilon$ and $g$,

$$
\beta(\varepsilon,g)=0
\quad\Longleftrightarrow\quad
g=0\ \text{or}\ g=\frac{\varepsilon}{3}.
$$

**Proof sketch.** Factor the polynomial:

$$
\beta(\varepsilon,g)
=-\varepsilon g+3g^2
=g(-\varepsilon+3g).
$$

A product of real numbers vanishes exactly when at least one factor vanishes. The first factor gives $g=0$. The second gives $3g=\varepsilon$, hence $g=\varepsilon/3$. Conversely, substituting either value makes the factored expression zero. $\square$

The theorem is stronger than the mere construction of one nontrivial zero: it proves that the truncated flow has no additional real fixed points. At $\varepsilon=0$ the two listed points coincide. For $\varepsilon\ne0$ they are distinct.

### 3.3 Positivity below four dimensions

**Theorem 3.3 (nontrivial positive fixed point below four dimensions).** Let $d<4$ and set $\varepsilon=4-d$. Then

$$
g_*(4-d)>0,
\qquad
g_*(4-d)\ne0,
\qquad
\beta\!\left(4-d,g_*(4-d)\right)=0.
$$

**Proof sketch.** The inequality $d<4$ implies $4-d>0$. Division by the positive number $3$ preserves strict positivity, so

$$
g_*(4-d)=\frac{4-d}{3}>0.
$$

Every positive real number is nonzero. The fixed-point identity follows from Theorem 3.1 with $\varepsilon=4-d$. $\square$

This establishes the bifurcation relevant to the epsilon expansion: immediately below four dimensions, the polynomial flow contains a positive interacting zero at a distance of order $\varepsilon$ from the origin.

### 3.4 Linearization

The derivative of the beta function with respect to the coupling is

$$
\partial_g\beta(\varepsilon,g)=-\varepsilon+6g.
$$

**Theorem 3.4 (linearized coefficient at the Wilson–Fisher point).** If $\varepsilon>0$, then

$$
\partial_g\beta\!\left(\varepsilon,g_*(\varepsilon)\right)
=-\varepsilon+6g_*(\varepsilon)
=\varepsilon>0.
$$

**Proof sketch.** Substitute $g_*(\varepsilon)=\varepsilon/3$:

$$
-\varepsilon+6\frac{\varepsilon}{3}
=-\varepsilon+2\varepsilon
=\varepsilon.
$$

The final quantity is positive by hypothesis. $\square$

The theorem supplies the exact first-order variation of the beta function near the interacting point:

$$
\beta(\varepsilon,g_*+h)=\varepsilon h+3h^2.
$$

For sufficiently small $h$, the sign is governed by $\varepsilon h$. A dynamical label such as infrared stable or ultraviolet stable additionally requires a convention for the orientation of renormalization-group time; the algebraic slope does not depend on that convention.

## 4. The two-loop coefficient and anomalous exponent

### 4.1 Finite diagram census

**Lemma 4.1 (sunset-weight sum).** The two equal sunset weights satisfy

$$
\sum_{i=1}^{2}w_i
=\frac{1}{108}+\frac{1}{108}
=\frac{1}{54}.
$$

**Proof sketch.** Addition gives $2/108$, and division of numerator and denominator by $2$ gives $1/54$. $\square$

The lemma is elementary, but it makes the provenance of the coefficient explicit: the final rational number is a sum over two contributions rather than an unexplained constant.

### 4.2 Fixed-point substitution

**Theorem 4.2 (two-loop anomalous dimension at the fixed point).** For every real $\varepsilon$,

$$
\eta\!\left(g_*(\varepsilon)\right)=\frac{\varepsilon^2}{54}.
$$

**Proof sketch.** Use the definitions of $\eta$ and $g_*$:

$$
\eta\!\left(g_*(\varepsilon)\right)
=\frac{1}{6}\left(\frac{\varepsilon}{3}\right)^2
=\frac{1}{6}\frac{\varepsilon^2}{9}
=\frac{\varepsilon^2}{54}.
$$

The identity holds for every real $\varepsilon$ as an equality in the truncated algebraic model. $\square$

The order of the result follows structurally. The fixed-point coupling is linear in $\varepsilon$, and the anomalous dimension begins quadratically in $g$. Their composition therefore begins quadratically in $\varepsilon$.

## 5. Rigorous remainder propagation

A perturbative formula must separate the computed coefficient from omitted higher-order contributions. Let $r:\mathbb{R}\to\mathbb{R}$ represent the remainder and define

$$
\eta_{\mathrm{tot}}(\varepsilon)
=\eta\!\left(g_*(\varepsilon)\right)+r(\varepsilon).
$$

**Theorem 5.1 (epsilon expansion with a cubic-order remainder).** Suppose there exist $C>0$ and $\delta>0$ such that

$$
|\varepsilon|<\delta
\quad\Longrightarrow\quad
|r(\varepsilon)|\le C|\varepsilon|^3.
$$

Then the same constants satisfy

$$
|\varepsilon|<\delta
\quad\Longrightarrow\quad
\left|\eta_{\mathrm{tot}}(\varepsilon)-\frac{\varepsilon^2}{54}\right|
\le C|\varepsilon|^3.
$$

Equivalently,

$$
\eta_{\mathrm{tot}}(\varepsilon)
=\frac{\varepsilon^2}{54}+O(\varepsilon^3)
\qquad(\varepsilon\to0).
$$

**Proof sketch.** Theorem 4.2 gives the exact identity

$$
\eta\!\left(g_*(\varepsilon)\right)=\frac{\varepsilon^2}{54}.
$$

Consequently,

$$
\eta_{\mathrm{tot}}(\varepsilon)-\frac{\varepsilon^2}{54}
=r(\varepsilon).
$$

Taking absolute values converts the desired inequality into the assumed inequality for $r$. No change of constants or neighborhood is required. $\square$

This theorem is a precise version of the familiar perturbative statement

$$
\eta=\frac{\varepsilon^2}{54}+O(\varepsilon^3).
$$

It is conditional in exactly the appropriate way: the algebra determines the quadratic coefficient, while analytic control of omitted terms is represented by the local cubic bound.

### 5.1 Example remainder family

For a concrete check, let

$$
r_a(\varepsilon)=a\varepsilon^3
$$

for a real constant $a$. Then

$$
|r_a(\varepsilon)|=|a||\varepsilon|^3.
$$

If $a\ne0$, choose $C=|a|$ and any $\delta>0$. If $a=0$, choose any $C>0$ and any $\delta>0$. Thus every cubic polynomial correction of this form satisfies the hypothesis, and

$$
\eta_{\mathrm{tot}}(\varepsilon)
=\frac{\varepsilon^2}{54}+a\varepsilon^3
$$

has the asserted expansion.

## 6. Counterexamples delimiting the conclusions

### 6.1 Failure of global uniqueness

**Proposition 6.1 (the fixed point is not globally unique).** The statement “for every real $\varepsilon$, the equation $\beta(\varepsilon,g)=0$ has a unique real solution” is false.

**Proof sketch.** Set $\varepsilon=3$. Then

$$
\beta(3,g)=-3g+3g^2=3g(g-1).
$$

Both $g=0$ and $g=1$ are zeros, and they are distinct. This single instance contradicts global uniqueness. $\square$

Indeed, Theorem 3.2 gives the sharper picture: there is one distinct zero at $\varepsilon=0$, where the Gaussian and Wilson–Fisher expressions coincide, and two distinct zeros for every $\varepsilon\ne0$.

### 6.2 Failure of positivity above four dimensions

**Proposition 6.2 (the non-Gaussian point need not be positive for negative $\varepsilon$).** The statement “if $\varepsilon<0$, then $g_*(\varepsilon)>0$” is false.

**Proof sketch.** Take $\varepsilon=-3$. Then

$$
g_*(-3)=\frac{-3}{3}=-1<0.
$$

Therefore positivity does not extend to the region above four dimensions. $\square$

More generally, because division by $3$ preserves sign, $g_*(\varepsilon)$ has exactly the sign of $\varepsilon$. The positivity theorem is therefore equivalent to the condition $d<4$.

## 7. Computational procedures

Although all central expressions admit closed forms, explicit algorithms are useful for reproducible numerical exploration.

### 7.1 Fixed-point classification algorithm

Given $d$, compute $\varepsilon=4-d$, return the Gaussian point $0$ and the Wilson–Fisher point $\varepsilon/3$, and evaluate the beta function at both. The procedure uses a constant number of arithmetic operations, so its time and auxiliary-space complexity are both $O(1)$.

For numerical work, residuals

$$
R_0=|\beta(\varepsilon,0)|,
\qquad
R_*=|\beta(\varepsilon,\varepsilon/3)|
$$

measure floating-point error. In exact arithmetic both are zero.

### 7.2 Exponent evaluation algorithm

Given $d$, compute $\varepsilon$, then $g_* = \varepsilon/3$, and finally

$$
\eta_* = \frac{g_*^2}{6}.
$$

An independent direct calculation uses $\varepsilon^2/54$. Comparing the two values checks the fixed-point substitution identity numerically. This also has $O(1)$ time and space complexity.

### 7.3 Sampled remainder-bound audit

Given a candidate remainder $r$, constants $C$ and $\delta$, and a finite list of sample points satisfying $|\varepsilon|<\delta$, evaluate whether

$$
|r(\varepsilon)|\le C|\varepsilon|^3
$$

at each point. For $n$ samples, the audit takes $O(n)$ time and $O(1)$ additional space if results are streamed. A sampled audit illustrates but does not prove a universal bound; the theorem in Section 5 applies only after the bound has been established for every point in the neighborhood.

## 8. Numerical examples

Table 1 records representative dimensions.

| $d$ | $\varepsilon=4-d$ | $g_*=\varepsilon/3$ | $\eta_*=\varepsilon^2/54$ | linear slope |
|---:|---:|---:|---:|---:|
| $3.9$ | $0.1$ | $0.0333333$ | $0.000185185$ | $0.1$ |
| $3.5$ | $0.5$ | $0.166667$ | $0.00462963$ | $0.5$ |
| $3.0$ | $1.0$ | $0.333333$ | $0.0185185$ | $1.0$ |
| $4.0$ | $0$ | $0$ | $0$ | $0$ |
| $5.0$ | $-1.0$ | $-0.333333$ | $0.0185185$ | $-1.0$ |

The first three rows display the positive interacting point below four dimensions. At four dimensions, it merges with the Gaussian point. Above four dimensions, the algebraic non-Gaussian zero is negative. The value $\eta_* = \varepsilon^2/54$ is insensitive to the sign of $\varepsilon$ because it is quadratic, but this symmetry of the truncated expression does not restore positivity of the coupling.

For an illustrative remainder, choose

$$
r(\varepsilon)=0.2\varepsilon^3.
$$

Then $C=0.2$ works for every $\delta>0$, because

$$
|r(\varepsilon)|=0.2|\varepsilon|^3.
$$

At $\varepsilon=0.1$, the leading term is approximately $1.85185\times10^{-4}$ and the remainder is $2\times10^{-4}$. At $\varepsilon=0.01$, the leading term is approximately $1.85185\times10^{-6}$ and the remainder is $2\times10^{-7}$. Their ratio is proportional to $|\varepsilon|$, illustrating why the cubic correction becomes relatively smaller near the origin.

## 9. Interpretation and applications

The model captures a general perturbative pipeline applicable far beyond this example.

1. **Identify a control parameter.** Here the displacement from the upper critical dimension is $\varepsilon=4-d$.
2. **Compute a truncated flow.** The beta function $-\varepsilon g+3g^2$ balances engineering scaling against interaction effects.
3. **Classify fixed points.** Factorization reveals both the Gaussian and interacting solutions.
4. **Select the physically relevant branch.** For $d<4$, the interacting coupling is positive.
5. **Linearize the flow.** The slope $\varepsilon$ supplies local dynamical information.
6. **Evaluate observables at the fixed point.** The two-loop formula $g^2/6$ becomes $\varepsilon^2/54$.
7. **Control omitted terms.** A local cubic bound turns an exact truncated identity into an asymptotic expansion.

In critical phenomena, fixed points explain universality: systems with different microscopic details can share the same large-scale exponents if their renormalization-group trajectories approach the same fixed point. In effective field theory, analogous polynomial beta functions describe how couplings vary with energy. In dynamical-systems language, the calculation is a parameter-dependent bifurcation in which a second equilibrium passes through the origin at $\varepsilon=0$.

The sunset-weight sum also highlights the interface between combinatorics and analysis. A full diagrammatic derivation would enumerate graph topologies and labelings, compute symmetry factors, regularize divergent integrals, extract pole coefficients, and combine counterterms. Once those tasks produce rational coefficients, however, the remaining consequences are algebraic and can be stated independently.

## 10. Structural observations

Several features of the calculation are worth separating from its physical interpretation. First, the fixed-point classification is global in the real variables $\varepsilon$ and $g$: it is not merely a small-$\varepsilon$ approximation. Once the quadratic beta function is adopted, its factorization identifies every real zero for every real parameter value. Smallness of $\varepsilon$ enters only when the formula is interpreted as a controlled perturbative approximation to a richer theory.

Second, the exponent identity is also exact within the truncation. The notation $O(\varepsilon^3)$ does not express uncertainty in the coefficient $1/54$. Rather, it marks the order at which contributions absent from the displayed model may enter. This distinction is important: the algebraic identity

$$
\eta(g_*)=\frac{\varepsilon^2}{54}
$$

and the analytic claim that omitted terms obey a cubic bound are logically separate statements.

Third, the signs of $g_*$ and of the linearized slope are controlled by the same parameter. Both equal a positive constant multiple of $\varepsilon$, namely

$$
g_* = \frac{\varepsilon}{3},
\qquad
\partial_g\beta(\varepsilon,g_*)=\varepsilon.
$$

Thus their sign changes occur simultaneously at four dimensions. By contrast, the leading anomalous dimension is proportional to $\varepsilon^2$ and is nonnegative on either side. This difference between odd and even dependence on $\varepsilon$ explains why the anomalous-dimension formula alone cannot determine which side of four dimensions contains a positive interacting coupling.

Finally, the coalescence at $\varepsilon=0$ is algebraically degenerate. There the beta function is $3g^2$, so the sole fixed point $g=0$ is a double root and its linearized slope vanishes. The usual first-derivative test therefore carries no directional information exactly at four dimensions; the quadratic term controls the local graph. Moving away from four dimensions splits this double root into the Gaussian branch and the Wilson–Fisher branch.

## 11. Scope and limitations

The present results are exact theorems about a specified truncated renormalization-group model. They do not constitute a nonperturbative construction of the one-component quartic quantum field theory. In particular, this paper does not:

- derive the coefficient $3$ from a one-loop regularized integral;
- derive the two weights $1/108$ from graph symmetry factors and two-loop integrals;
- include a cubic term in the beta function;
- calculate the fixed point beyond first order in $\varepsilon$;
- establish convergence or Borel summability of the epsilon expansion;
- provide an analytic bound for a remainder arising from a full quantum field theory;
- assign infrared or ultraviolet stability without fixing the orientation of the flow parameter.

These limitations do not weaken the internal conclusions. They identify the boundary between exact algebraic propagation of perturbative input and the analytical derivation of that input.

## 12. Future work

A natural first extension is a diagram-level construction. Combinatorial Feynman graphs, automorphisms, and symmetry factors could be defined explicitly, allowing the two equal sunset contributions to emerge from an enumeration rather than enter as data.

A second extension is analytical. A controlled regularization scheme could be introduced, and the relevant pole coefficients could be derived from momentum-space integrals. This would connect the rational algebraic model to the underlying loop calculation.

A third direction is to add the two-loop beta-function term. If

$$
\beta(\varepsilon,g)=-\varepsilon g+3g^2+b_3g^3+\cdots,
$$

then the interacting fixed point acquires an $O(\varepsilon^2)$ correction. Propagating that corrected coupling through the anomalous dimension refines the exponent expansion.

A fourth direction is the $O(N)$ model, in which coefficients depend on the number $N$ of field components. Uniform statements in $N$ would expose which positivity and remainder properties persist throughout an admissible parameter range.

A fifth direction is dynamical. Defining an explicit differential equation for renormalization-group time would permit a local stability theorem with an unambiguous time orientation. Finally, one could separate identities of formal power series from analytic remainder estimates and seek certified neighborhoods in which higher-order truncation errors obey explicit bounds.

## 13. Conclusion

The truncated one-component epsilon expansion supports a complete and self-contained algebraic analysis. Its beta function factors as

$$
\beta(\varepsilon,g)=g(-\varepsilon+3g),
$$

so its only fixed points are $0$ and $\varepsilon/3$. When $d<4$, the latter is positive, nonzero, and has linearized slope $\varepsilon>0$. The two equal sunset weights sum to $1/54$, and the two-loop anomalous dimension evaluated at the interacting point is exactly

$$
\eta\!\left(g_*(\varepsilon)\right)=\frac{\varepsilon^2}{54}.
$$

Any additional contribution bounded by $C|\varepsilon|^3$ near the origin leaves the expansion

$$
\eta(\varepsilon)=\frac{\varepsilon^2}{54}+O(\varepsilon^3)
$$

intact. Counterexamples at $\varepsilon=3$ and $\varepsilon=-3$ show, respectively, why global uniqueness and positivity above four dimensions must not be claimed. Together, these results present the epsilon expansion as a precise chain from polynomial flow, through fixed-point classification, to asymptotic critical exponent.