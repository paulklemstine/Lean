# Integration in Finite Terms: A Four-Drawer Calculus

## When does an antiderivative have a name?

Differentiation is local and obedient. Give it a formula assembled from powers, exponentials, logarithms, products, and quotients, and a short list of rules produces another formula. Integration runs the same movie backward, but the plot is no longer deterministic. The innocent-looking function $e^{-x^2}$ has no antiderivative expressible by a finite combination of the usual elementary functions, while $xe^{x^2}$ does. The difference is not numerical accuracy: both can be integrated approximately. It is a question of *finite terms*: can the answer be written in the same symbolic language as the question?

The Risch philosophy turns that apparently creative question into algebra. Instead of guessing an answer, one first reduces the input to controlled pieces. The development presented here studies the decisive finite stage after that reduction. Its input is a normalized list of polynomial monomials, simple rational poles, higher rational poles, and constant-rate exponentials, all with rational parameters. For this class, integration becomes a transparent four-drawer procedure. Every item has one destination, every destination has an explicit antiderivative, and the number of processing steps is visible from the input list itself.

This is both less and more than a slogan about symbolic integration. It does not claim that every elementary expression has already been converted into this form. Normalization is a separate and substantial problem. But once a function reaches the stated normal form, the remaining decision and construction are complete: the algorithm always returns a finite expression whose derivative is the input wherever the input is defined.

## The four drawers

A normalized function is a finite sum

$$
f(x)=\sum_i c_i x^{n_i}
+\sum_j \frac{r_j}{x-a_j}
+\sum_\ell \frac{d_\ell}{(x-b_\ell)^{m_\ell}}
+\sum_s u_s e^{v_sx},
$$

where all coefficients, pole locations, and exponential rates are rational, each $n_i$ is a nonnegative integer, and every higher-pole order satisfies $m_\ell\ge 2$. The four sums are the algebraic, logarithmic, higher-pole, and exponential drawers.

Why separate simple and higher poles? Because they leave different fingerprints under integration. A simple pole produces a logarithm:

$$
\int \frac{r}{x-a}\,dx=r\log|x-a|.
$$

In a real expression language using $\log(x-a)$, the same derivative identity holds on every interval where $x-a>0$; more generally, $\log|x-a|$ displays the real antiderivative on either side of the pole. A pole of order at least two stays rational:

$$
\int \frac{d}{(x-b)^m}\,dx
=-\frac{d}{m-1}(x-b)^{-(m-1)}.
$$

The pole order falls by one. This is the elementary face of Hermite reduction, one of the central mechanisms behind rational integration.

The other drawers are familiar. For $n\ge 0$,

$$
\int cx^n\,dx=\frac{c}{n+1}x^{n+1}.
$$

For an exponential with rate $v\ne 0$,

$$
\int ue^{vx}\,dx=\frac{u}{v}e^{vx}.
$$

There is one small branch that matters enormously to an actual algorithm. If $v=0$, division by $v$ is impossible, but $ue^{0x}=u$ is simply constant, so its primitive is $ux$. Treating this case explicitly makes the construction total rather than “correct except when a parameter happens to vanish.”

## The finite-term integration theorem

These four rules combine into the central result.

**Finite-Term Integration Theorem for Normalized Inputs.** Let $f$ be any finite sum of the four forms above, with rational data and higher-pole orders at least two. Define

$$
F(x)=
\sum_i \frac{c_i}{n_i+1}x^{n_i+1}
+\sum_j r_j\log|x-a_j|
-\sum_\ell \frac{d_\ell}{m_\ell-1}(x-b_\ell)^{-(m_\ell-1)}
+\sum_{s:v_s\ne0}\frac{u_s}{v_s}e^{v_sx}
+\sum_{s:v_s=0}u_sx.
$$

Then $F$ is a finite expression made from rational constants, the variable, arithmetic, logarithms, and exponentials. At every real number $x$ distinct from all pole locations $a_j$ and $b_\ell$, one has $F'(x)=f(x)$, interpreted interval by interval for the logarithmic terms.

The proof is a model of modular reasoning. Differentiate each summand using the power, logarithm, reciprocal-power, and exponential rules. Each derivative returns its corresponding input piece. Finally use linearity of differentiation to add the identities. Pole avoidance is exactly what makes every denominator nonzero and every local logarithmic derivative legitimate. No extra exceptional points are introduced by polynomial or exponential terms.

The theorem gives a decision procedure on this normalized class in an unusually strong sense. It does not merely answer “yes.” It constructs the witness $F$, and its correctness can be checked term by term. Completeness here comes from the input grammar: every permitted constructor belongs to one of the four drawers, and every drawer has a rule.

## A concrete example

Consider

$$
f(x)=3x^2-\frac{2}{x-1}+\frac{5}{(x+2)^3}+4e^{2x}+7e^{0x}.
$$

The drawer rules give

$$
F(x)=x^3-2\log|x-1|-\frac{5}{2(x+2)^2}+2e^{2x}+7x.
$$

Differentiating yields

$$
F'(x)=3x^2-\frac{2}{x-1}+\frac{5}{(x+2)^3}+4e^{2x}+7,
$$

which is $f(x)$ because $e^{0x}=1$. The identity holds for $x\ne1,-2$. Those exclusions are not algorithmic blemishes; they are genuine singularities of the original function. On each interval cut out by the poles, $F$ is an antiderivative.

This example also shows why symbolic structure beats blind numerical sampling. A finite-difference check can compare $F'(x)$ and $f(x)$ at selected points, but the four-drawer argument explains the identity for every regular point at once. Numerical checks are valuable illustrations, not substitutes for the structural theorem.

## Why residues matter

The coefficient $r$ of $1/(x-a)$ is called the residue at the simple pole $a$. It controls the logarithmic part exactly. A nonzero residue cannot be erased by lowering a rational pole order: it announces that a logarithm is required. By contrast, a term with denominator $(x-b)^m$ for $m\ge2$ integrates without leaving rational functions.

This dichotomy connects symbolic integration to complex analysis and differential algebra. In complex analysis, residues measure contour integrals around poles. In elementary integration, the same local coefficient records the logarithm that must appear in a primitive. The normalized representation exposes this information before any formula is assembled.

The exponential drawer has a parallel diagnostic. The rate $v$ determines whether the primitive remains exponential after division by $v$ or degenerates to a linear function when $v=0$. Thus local algebraic data—pole order, residue, exponential rate—dictate the global shape of the answer.

## Why the procedure terminates quickly

For a rational input already written as polynomial terms plus simple and higher poles, charge one abstract processing step per summand. If there are $P$ polynomial pieces, $S$ simple poles, and $H$ higher poles, then

$$
T=P+S+H.
$$

A weighted representation size can be defined by

$$
N=1+2P+3S+4H.
$$

Immediately $T\le N$, and because $N\ge1$, also $T\le N^2$. Therefore the integration stage has a linear bound in this representation size and, in particular, a polynomial bound.

This statement is deliberately precise about what it measures. It counts traversal of an already normalized list. It is not yet a bit-complexity analysis of factoring an arbitrary denominator, computing partial fractions, or controlling coefficient growth. Those upstream tasks can dominate practical rational integration. Separating them prevents a common mistake: confusing a fast final pass with a complete complexity theorem for normalization.

## A map of singular terrain

The algorithm also offers a geometric way to read an integral. Poles divide the real line into open intervals. On each interval the primitive is smooth, but no single finite value can bridge a genuine pole. A simple pole has a logarithmic primitive that runs without bound as the pole is approached. A higher pole produces a rational primitive with a correspondingly sharp divergence. Thus the excluded points in the theorem are not technical debris: they map the places where the landscape itself tears.

This interval-by-interval viewpoint matters in applications. In a differential equation, an initial condition selects one connected interval, and the primitive is then determined there up to an additive constant. In a physical model, a pole may mark resonance, collision, or the failure of an idealized approximation. In complex analysis, circling a simple pole reveals its residue; on the real line, that same residue is the coefficient multiplying the logarithm. One small rational number therefore carries both local singular information and the shape of the antiderivative.

Exact rational data make this map unusually crisp. The pole locations are exact, not floating-point estimates, and the test of whether an exponential rate vanishes is conclusive. Such exact branching prevents a tiny numerical rate from being mistaken for zero, or zero from triggering an illegal division. Approximation remains useful when evaluating a returned formula, but the structural decisions happen before approximation enters.

## From calculus exercise to decision procedure

A school integral often asks for ingenuity: spot a substitution, complete a square, add and subtract the right term. A decision procedure asks for something stricter. It must specify its input, branch safely on every case, halt, return an output in a declared language, and justify that output throughout the domain where the input makes sense.

The normalized algorithm meets all five demands. Its input is a finite four-part list. Its only special branch tests whether an exponential rate is zero. It halts because every finite list is traversed once. Its output uses finite arithmetic, powers, logarithms, and exponentials. Its derivative agrees with the input away from listed poles. For rational partial fractions, the step count is linear.

The boundary of the result is equally informative. A full symbolic integrator must first transform broad expressions into suitable differential-field normal forms and must sometimes decide that no elementary primitive exists. Important next steps include canonical partial-fraction normalization, bit-level complexity bounds, residue criteria for split denominators, and the solution of the differential equations arising in exponential extensions. One especially important target is a semantics-preserving normalization whose complexity decreases at each recursive reduction.

Yet the finite stage already captures a central lesson of the Risch program: integration becomes decidable not by searching through an ocean of possible answers, but by discovering the right coordinates for the question. Once powers, residues, higher poles, and exponential rates have been laid in their proper drawers, the antiderivative is no longer guessed. It is read off.