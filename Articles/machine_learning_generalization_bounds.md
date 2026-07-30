# The Size of a Network Is Not the Size of Its Idea

## Why compressed descriptions can explain generalization in enormous neural networks

A modern neural network can contain more adjustable numbers than there are examples in its training set. By an old and appealing intuition, this should be a recipe for memorization. Give a model enough knobs and it can fit almost anything; why should it make reliable predictions about data it has never seen?

Yet large networks routinely do exactly that. They are overparameterized—sometimes spectacularly so—and nevertheless classify images, transcribe speech, and forecast physical systems beyond their training samples. The apparent paradox comes from measuring the wrong kind of size.

There is the **ambient size** of a network: the total number of trainable parameters available in its architecture. Then there is its **effective complexity**: the amount of information needed to specify the predictor that learning actually selected, after redundancies, symmetries, inactive components, and prior knowledge have been taken into account. Generalization depends on the second quantity, not automatically on the first.

This distinction can be made precise with a small algebraic framework that unifies two influential ways of thinking. Compression asks how briefly a learned predictor can be described. PAC-Bayes analysis asks how much a data-dependent distribution over predictors departs from a prior distribution. The central message is additive: the costs of identifying a functional class, encoding a representative, and moving from prior to posterior combine into one budget. If the sample size dominates that budget at the desired accuracy, a generalization certificate follows.

## Three ledgers for complexity

Imagine a learned predictor accompanied by five numbers. Its raw parameter dimension is $d$. Its quotient complexity is $q$, the cost of identifying the predictor after functionally equivalent parameter settings have been grouped together. Its code length is $c$, the number of additional units needed to encode a chosen representative. Its posterior divergence is $K$, a nonnegative information cost measuring departure from a prior. Finally, it was trained on $n$ samples.

The effective complexity is

$$
R=q+c+K.
$$

The units of $q$ and $c$ are discrete, while $K$ is real-valued, but all three can be embedded in one numerical budget. The raw dimension $d$ is deliberately absent. This is not sleight of hand: $d$ records the size of the coordinate system, whereas $R$ records the complexity that the certificate actually uses.

For a requested accuracy scale $oldsymbol{\varepsilon>0}$ and confidence parameter $oldsymbol{\delta>0}$, say that the profile generalizes at scale $(\varepsilon,\delta)$ when

$$
R\le n\varepsilon^2.
$$

The confidence parameter is retained because confidence typically determines part of the information budget. In the standard specialization, that contribution is $log(1/\delta)$. The elementary algebra developed here does not itself impose a probabilistic interpretation on $\delta$; rather, it identifies exactly what remains to be checked once a probabilistic PAC-Bayes or compression theorem has supplied the relevant budgets.

## A certificate that combines compression and prior knowledge

Suppose a certificate provides a nonnegative integer structural budget $B$ and a real posterior budget $J$. It guarantees

$$
q+c\le B,\qquad K\le J,
$$

with $K\ge0$. Its total budget is

$$
T=B+J.
$$

The first main result is almost disarmingly simple, but it is the hinge of the whole framework.

**Certificate Domination Theorem.** The effective complexity satisfies $R\le T$.

Indeed, adding $q+c\le B$ and $K\le J$ gives $q+c+K\le B+J$. This addition step is what lets compression and PAC-Bayes information live in one ledger.

A direct consequence turns the ledger into a sample-complexity statement.

**Unified Generalization Theorem.** If $\varepsilon>0$, $\delta>0$, and

$$
T\le n\varepsilon^2,
$$

then the profile generalizes at scale $(\varepsilon,\delta)$.

The theorem says that one need not control the effective complexity term by term at the final stage. It is enough to construct a certificate whose total cost fits under the sample budget.

The standard confidence form makes the role of $\delta$ visible. If

$$
J\le \log(1/\delta)
$$

and

$$
B+\log(1/\delta)\le n\varepsilon^2,
$$

then generalization at scale $(\varepsilon,\delta)$ follows. This is useful operationally: compression controls $B$, a PAC-Bayes argument controls $J$, and the two analyses meet in one final inequality.

## From a budget to a radius

Generalization estimates are often displayed as a square-root radius. For complexity $x$ and positive sample size $n$, define

$$
\rho(x,n)=\sqrt{\frac{x}{n}}.
$$

If $R\le n\varepsilon^2$, $n>0$, and $\varepsilon\ge0$, then

$$
\rho(R,n)\le\varepsilon.
$$

This **Radius Theorem** translates the budget form into the familiar inverse-square-root scaling. Divide by the positive number $n$ to get $R/n\le\varepsilon^2$, then take square roots.

The radius also quantifies the value of genuine compression. If $0\le x<y$ and $n>0$, then

$$
\rho(x,n)<\rho(y,n).
$$

So reducing certified complexity is not merely cosmetic. At every positive sample size, a strict reduction in complexity yields a strict reduction in the square-root bound. Halving complexity improves the radius by a factor of $1/\sqrt{2}$; reducing it by a factor of one hundred improves the radius by a factor of ten.

## Reading architecture through retained structure

How can architecture enter without returning to a crude count of all parameters? Summarize a network by its layer widths, its raw parameter count, and its active parameter count. The active count is no larger than the raw count. Define the structural complexity

$$
S=a+\sum_{\ell=1}^{L}w_\ell,
$$

where $a$ is the number of retained parameters and $w_1,\ldots,w_L$ are the layer widths.

This quantity charges for the parameters that survive a compression certificate and for a simple description of the architecture. It does not charge for every dormant coordinate merely because the ambient model made that coordinate available.

**Architecture-to-Sample-Complexity Theorem.** Suppose

$$
q+c\le S,\qquad K\le\kappa,
$$

and $\varepsilon>0$, $\delta>0$. If

$$
S+\kappa\le n\varepsilon^2,
$$

then the network profile generalizes at scale $(\varepsilon,\delta)$.

This theorem creates a bridge from a concrete architecture summary to a sample budget. Solving its inequality for $n$ suggests the threshold

$$
n\ge\frac{S+\kappa}{\varepsilon^2}.
$$

The dependence is linear in retained structural complexity and quadratic in inverse accuracy. The total raw parameter count need not appear.

Consider a network with one million available parameters but only $2{,}000$ retained parameters, and layer widths summing to $500$. Then $S=2{,}500$. If the posterior contribution is $400$, the relevant numerator is at most $2{,}900$, not one million. At $n=50{,}000$, the corresponding radius is approximately

$$
\sqrt{\frac{2{,}900}{50{,}000}}\approx0.241.
$$

A raw-count radius would be larger than $4$, conveying essentially no useful scale. The example does not claim that every million-parameter network admits this certificate. It shows what follows when one does.

## Why adding parameters need not hurt

Now comes the resolution of the overparameterization puzzle. Enlarge a profile by adding $k$ ambient parameters while leaving $q$, $c$, $K$, and $n$ unchanged. The old certificate remains valid with exactly the same total budget.

**Overparameterization Invariance Theorem.** Increasing only the ambient parameter dimension preserves every certificate-derived generalization guarantee.

The proof is conceptual: none of the inequalities defining the certificate changes. The coordinate space has grown, but the encoded predictor, quotient cost, posterior cost, and data set have not.

There is also an explicit existence result.

**Arbitrarily Overparameterized Generalization Theorem.** Let $n$ and $e$ be nonnegative integers, and let $\varepsilon>0$ and $\delta>0$. If

$$
1\le n\varepsilon^2,
$$

then there exists a profile with sample size $n$, parameter dimension $n+e+1$, effective complexity exactly $1$, and a valid generalization guarantee at scale $(\varepsilon,\delta)$.

Since $e$ can be arbitrarily large, the gap between parameter count and sample size can be arbitrarily large while the effective complexity stays fixed and nonzero. This is an existence theorem about complexity profiles, not a claim that arbitrary training procedures always discover such simple predictors. Its purpose is sharper: parameter count alone cannot rule out generalization.

## What this changes in practice

The framework suggests a different workflow for studying large networks. Do not begin and end with the number of parameters. Instead ask:

1. Which parameter settings represent the same function, at least on the relevant domain?
2. How many parameters remain active after pruning, quantization, low-rank factorization, or other compression?
3. How long is the description of the retained architecture and weights?
4. How far is the learned posterior from a meaningful prior?
5. Does the sum of these costs fit below $n\varepsilon^2$?

These questions connect theory to concrete engineering. Pruning can reduce $a$. Quantization can reduce $c$. Permutation symmetries can reduce $q$. A data-independent pretraining prior can reduce $K$ when the downstream posterior remains nearby. Each intervention targets a term in the same budget.

The theory is intentionally modular. It does not pretend that constructing a tight certificate is easy, nor does it replace the probabilistic theorem that links a particular loss and data-generating process to a PAC-Bayes bound. Instead, it isolates the arithmetic that any such argument must satisfy. Once valid component bounds are available, they combine cleanly, and irrelevant ambient parameters drop out.

The broader lesson is familiar beyond neural networks. A long book may contain a short idea; a huge program may execute a simple algorithm; a high-dimensional coordinate system may describe a low-dimensional object. Capacity is not the same as realized complexity. For neural networks, that difference can be the difference between an apparent paradox and a quantitative explanation.

Overparameterization is therefore not, by itself, the enemy of generalization. Uncontrolled effective complexity is. A network may have an enormous space in which it could move, yet settle on a predictor whose quotient, code, and posterior description is compact. When that compact description fits inside the information supplied by the sample, the size of the surrounding space no longer tells the story. The idea the network learned can be much smaller than the network that learned it.
