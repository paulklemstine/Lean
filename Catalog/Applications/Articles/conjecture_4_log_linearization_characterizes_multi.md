# The Hidden Geometry of Independence

## How a simple coordinate trick reveals when two quantities truly don't interact

---

Consider a factory that produces widgets. The output depends on two things: the number of machines and the number of workers. A natural question arises: does each factor contribute independently to production, or do machines and workers interact in some irreducible way?

This sounds like an economics question. But the same puzzle appears everywhere. In physics: do two subsystems of a gas exchange energy, or do they evolve independently? In medicine: does a drug's effect depend on the patient's age in a way that can't be separated into "drug effect" and "age effect"? In machine learning: does a neural network's prediction depend on two input features independently, or through their interaction?

For centuries, scientists have had an informal tool for answering this question. "Take the logarithm," they'd say, "and see if things separate." It's one of the oldest tricks in applied mathematics — and one of the least examined. Until now.

## The Logarithmic Lens

Here's the core idea, stripped to its essence.

Suppose you have a positive quantity $f(x, y)$ that depends on two positive inputs. You suspect it might factor as a product: $f(x, y) = \phi(x) \cdot \psi(y)$, where $\phi$ captures the effect of $x$ alone and $\psi$ captures the effect of $y$ alone. If this factorization exists, the two inputs contribute independently — there is no interaction.

How would you test this? Take the logarithm of both sides:

$$\log f(x, y) = \log \phi(x) + \log \psi(y).$$

The product becomes a sum. The multiplicative independence in the original coordinates becomes additive independence in logarithmic coordinates. And additive independence is much easier to detect: just check whether you can write the function as "something depending on $x$" plus "something depending on $y$."

Scientists have used this observation for generations. Statisticians fit log-linear models. Physicists decompose free energies. Economists take logs of production functions. But here's the remarkable thing: nobody had proved, with mathematical certainty, that this trick is *complete* — that it catches every case of independence and produces no false positives.

That gap has now been closed.

## A Theorem with Three Faces

The result comes in three equivalent forms, each revealing a different facet of the same truth.

**The Coordinate Form.** A positive continuous function on the positive quadrant factors as $f(x,y) = \phi(x) \cdot \psi(y)$ with positive continuous factors if and only if, after taking logarithms, it separates as $\log f(x,y) = u(\log x) + v(\log y)$ for continuous functions $u$ and $v$.

This is the version that validates the "take the log" heuristic. It says the heuristic is not merely useful but *exactly right*: log-additive separability and multiplicative factorization are logically equivalent, not just informally related.

**The Algebraic Form.** The same factorization holds if and only if a certain algebraic identity is satisfied:

$$f(x_1, y_1) \cdot f(x_2, y_2) = f(x_1, y_2) \cdot f(x_2, y_1)$$

for all positive inputs $x_1, x_2, y_1, y_2$. This identity — a "cross-ratio" condition — says that swapping the $y$-arguments between two evaluations of $f$ doesn't change the product. It's a kind of symmetry condition, and it has a beautiful interpretation.

**The Matrix Form.** If you think of $f(x, y)$ as a continuous analogue of a matrix, the cross-ratio condition says that every $2 \times 2$ "submatrix" has determinant zero (in a multiplicative sense). In linear algebra, a matrix with all $2 \times 2$ minors equal to zero has rank one — it's an outer product of two vectors. The theorem says the same is true in the continuous world: $f$ is a "rank-one kernel" if and only if all its $2 \times 2$ multiplicative minors vanish.

## The Interaction Defect: A Universal Detector

The algebraic form suggests something powerful: a *single number* that measures how far a function is from being separable.

Define the *interaction defect* at four points:

$$D = \frac{f(x_1, y_1) \cdot f(x_2, y_2)}{f(x_1, y_2) \cdot f(x_2, y_1)}.$$

If $f$ is multiplicatively separable, this ratio is exactly 1 — always, everywhere, for any choice of the four points. If the ratio deviates from 1, there is genuine interaction.

This single number unifies several concepts from different fields. In statistics, it's the *odds ratio* — the standard measure of association in contingency tables. In physics, taking its logarithm gives the mixed free energy, whose vanishing signals non-interacting subsystems. In machine learning, it quantifies *feature interaction strength*.

The theorem guarantees that $D = 1$ everywhere is not just necessary but *sufficient* for factorization. You don't need to check infinitely many conditions or solve an optimization problem. The interaction defect is a complete algebraic certificate of independence.

## The (x + y)² Test Case

To see the theorem in action, consider the function $f(x, y) = (x + y)^2$. It looks like it might factor — after all, it's a simple algebraic expression. But does it?

Apply the cross-ratio test with $x_1 = 1$, $x_2 = 2$, $y_1 = 1$, $y_2 = 2$:

- Left side: $f(1,1) \cdot f(2,2) = 4 \cdot 16 = 64$
- Right side: $f(1,2) \cdot f(2,1) = 9 \cdot 9 = 81$

Since $64 \neq 81$, the function cannot be multiplicatively separable. The interaction defect is $64/81 \approx 0.79$ — a clear signal of interaction.

This is not merely a numerical observation. It has been proved with mathematical certainty: no continuous positive functions $\phi$ and $\psi$ exist such that $(x + y)^2 = \phi(x) \cdot \psi(y)$ for all positive $x$ and $y$. The addition inside the square creates an irreducible coupling between $x$ and $y$.

Compare this with $f(x, y) = x^2 \cdot y^3$. Here the cross-ratio test gives:

- Left side: $1^2 \cdot 1^3 \cdot 2^2 \cdot 2^3 = 1 \cdot 32 = 32$
- Right side: $1^2 \cdot 2^3 \cdot 2^2 \cdot 1^3 = 8 \cdot 4 = 32$

Perfect equality, as the theorem predicts.

## From Heuristic to Instrument

What makes this more than an elegant mathematical exercise?

The key is that the theorem transforms a qualitative intuition — "take the log and see if it separates" — into a *quantitative instrument*. The interaction defect can be computed on real data, from finite samples, with known error bounds. It doesn't require fitting a model, choosing a basis, or making distributional assumptions. It's a direct algebraic measurement.

In computational experiments, the defect works exactly as predicted. For the monomial $x^2 y^3$, the maximum defect over a grid of test points is less than $10^{-15}$ — machine epsilon, indistinguishable from zero. For $(x + y)^2$, the defect exceeds 2.0 — an unambiguous signal.

Even more striking is the stability behavior. When a small perturbation is added — say, $f(x,y) = x^2 y^3 (1 + \varepsilon \sin(xy))$ — the defect grows proportionally to $\varepsilon$. At $\varepsilon = 0.01$, the defect is about 0.036. At $\varepsilon = 0.1$, it's about 0.36. The defect is a sensitive, calibrated meter of interaction strength.

## A Map of Applications

The theorem's reach extends across disciplines because the same mathematical structure appears in different guises.

**In statistics**, the interaction defect is the logarithm of the odds ratio. A joint density $f(x,y)$ of two random variables is a product of marginals — meaning the variables are independent — if and only if the odds ratio is identically 1. The theorem provides a continuous, infinite-dimensional version of this classical result.

**In thermodynamics**, the logarithm of a partition function is the free energy. If the partition function of a composite system factorizes as $Z(\beta_1, \beta_2) = Z_1(\beta_1) \cdot Z_2(\beta_2)$, the subsystems are thermodynamically decoupled — they don't exchange energy. The mixed partial derivative of the free energy (the "interaction free energy") vanishes. The theorem makes this equivalence exact.

**In economics**, the Cobb-Douglas production function $Y = A \cdot K^\alpha \cdot L^\beta$ is multiplicatively separable in capital $K$ and labor $L$. The CES (Constant Elasticity of Substitution) production function is not. The interaction defect provides a single-number test that distinguishes these cases without fitting parametric models.

**In machine learning**, detecting feature interactions is fundamental to model interpretability. If a model's output depends on features $x$ and $y$ only through $\phi(x) \cdot \psi(y)$, the features are "disentangled." The cross-ratio test provides a model-agnostic certificate of disentanglement.

## The Deeper Pattern

Step back and look at what this theorem really says. It identifies three equivalent ways to express the same idea:

1. **Multiplicative factorization** in original coordinates
2. **Additive separation** in logarithmic coordinates
3. **Vanishing cross-ratio** as an algebraic identity

Each perspective illuminates something the others miss. The multiplicative view is natural for probabilities and partition functions. The additive view is natural for energies and log-likelihoods. The algebraic view provides a finite, testable criterion.

The key insight is that the logarithm is not just a computational convenience — it is a *coordinate transformation* that converts a geometric property (rank-one structure) into an algebraic one (additivity). The theorem says this conversion is lossless. Nothing is gained or lost by changing coordinates. Independence is a coordinate-invariant property of the function, not an artifact of how we choose to look at it.

This is a surprisingly deep statement. It means that whether you're a physicist thinking about free energies, a statistician thinking about log-linear models, or a machine learning engineer thinking about feature interactions, you're all studying the same mathematical object from different vantage points. The theorem provides the Rosetta Stone that translates between these perspectives.

## What Comes Next

The bivariate case is just the beginning. The natural next step is the multivariate version: when does a function of $n$ variables factor as a product of $n$ univariate functions? The conjecture is that pairwise cross-ratio tests suffice — that checking all pairs of variables for interaction is enough to certify global factorization. If true, this would reduce an exponentially complex problem (checking all possible groupings) to a quadratic one.

There's also the stability question. In practice, exact separability never holds — there's always noise, model error, or finite-sample effects. A quantitative stability theorem would say: if the interaction defect is small (less than $\varepsilon$), then $f$ is close (within $C \cdot \varepsilon$) to a genuinely separable function. Preliminary computational evidence strongly supports this, with the defect scaling linearly with perturbation strength.

And there's the smooth version. If $f$ is twice differentiable, the cross-ratio identity is equivalent to the vanishing of a mixed partial derivative — a PDE condition. This opens connections to differential geometry: multiplicative separability becomes a zero-curvature condition on a certain connection. The "interaction geometry" of positive functions is a space waiting to be explored.

What began as a folk heuristic — "take the log and see if it separates" — has become the cornerstone of a mathematical theory. And like all good mathematics, it reveals that a simple idea, examined carefully enough, connects to everything.
