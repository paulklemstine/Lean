# The Hidden Architecture of Multiplication

*How two ancient mathematical functions — exponentials and logarithms — turn out to be the universe's optimal building blocks for computation*

---

In 1957, a young Soviet mathematician named Andrey Kolmogorov resolved one of David Hilbert's famous problems by proving something extraordinary: every continuous function of several variables, no matter how complicated, can be decomposed into a sum of functions that each depend on only one variable at a time. His student Vladimir Arnold refined the result, and the **Kolmogorov-Arnold representation theorem** became one of the most surprising results in mathematics — and one of the most mysterious.

The theorem says that for any continuous function *f*(*x*, *y*), there exist continuous single-variable functions φ and Φ such that *f* can be written as a sum of terms like Φ(φ₁(*x*) + φ₂(*y*)). The formula is beautiful, almost magical in its generality. There is just one problem.

The theorem guarantees that the decomposition *exists*, but says nothing about what the single-variable building blocks should look like. For decades, the inner functions in the decomposition were treated as abstract mathematical objects — guaranteed to exist by a clever proof, but seemingly impossible to write down explicitly. The original construction used highly pathological functions, leading many to dismiss the theorem as a theoretical curiosity with no practical relevance.

Now, new research reveals that for a vast class of important functions, those building blocks are hiding in plain sight. They are the exponential function and the natural logarithm — two of the oldest and most studied functions in all of mathematics.

## The Depth-Independence Discovery

Consider the humble act of multiplication: computing *x* × *y*. If you had to build this operation from scratch using only single-variable functions, how would you do it?

The answer turns out to be startlingly elegant. For any positive numbers *x* and *y*:

> *x* × *y* = exp(log *x* + log *y*)

This identity is well known — it's the principle behind slide rules, those elegant analog computers that engineers carried in their pockets before the digital age. Take the logarithm of each number, add them together, and exponentiate the result. Three steps: log, add, exp.

But the new insight goes much further. Consider the monomial *x*^100 × *y*^200, a function that multiplies the hundredth power of *x* by the two-hundredth power of *y*. In ordinary arithmetic, computing *x*^100 alone requires dozens of multiplications, even with clever shortcuts like repeated squaring. You might expect that representing such a function in the Kolmogorov-Arnold framework would require a correspondingly complex decomposition, perhaps growing with the size of the exponents.

It doesn't. The decomposition is:

> *x*^100 × *y*^200 = exp(100 · log *x* + 200 · log *y*)

This has exactly the same structure — one logarithm for each variable, one linear scaling, one addition, one exponential — regardless of whether the exponents are 1 and 1, or a million and a million. The researchers call this the **depth-independence phenomenon**: the complexity of the decomposition does not grow with the complexity of the function being decomposed.

This is not an approximation. It is exact. And it extends far beyond simple monomials.

## Polynomials for Free

Any polynomial in two variables — say, 3*x*²*y* + 2*x*·*y*³ − √*x* · √*y* — is just a sum of monomials. Since each monomial has a depth-1 decomposition, a polynomial with *M* terms has an *M*-term decomposition, still at depth 1. The classical Kolmogorov-Arnold theorem, by contrast, requires 2*n* + 1 = 5 terms for a function of two variables and says nothing about depth.

The polynomial result has a particularly elegant structure. For each monomial term *c* · *x*^*a* · *y*^*b*, the decomposition uses exactly the same recipe: apply logarithms to the inputs, scale by the exponents, add them together, exponentiate, and scale by the coefficient. It doesn't matter whether the exponents are integers, fractions, or irrational numbers. The recipe is the same, the depth is the same, and only the numerical parameters change.

The implications cascade. Since polynomials can approximate any continuous function on a compact domain (the classical Weierstrass approximation theorem, one of the foundational results of analysis), the EML decomposition — named for its use of **E**xp **M**inus **L**og operations — provides a concrete, constructive path to universal function representation using only exponentials and logarithms. Where Kolmogorov's theorem says "some continuous functions exist that make this work," the EML approach says "exp and log are sufficient."

## The Convex Duality Bridge

Why should exponentials and logarithms be special? The answer comes from an unexpected direction: optimization theory. Specifically, from a beautiful idea called *convex duality* that connects every convex function to a partner, its *convex conjugate*.

Think of it this way: every hill has a shadow. The shape of the shadow encodes information about the hill, but in a transformed way. Convex duality is the mathematical version of this principle, but for curves instead of hills. The conjugate of the exponential function turns out to be the function *s* · log(*s*) − *s* — a quantity closely related to entropy from thermodynamics and information theory. This pairing is not arbitrary — it is optimal in a precise variational sense.

The **Fenchel-Young inequality** makes this precise:

> *x* · *s* ≤ exp(*x*) + *s* · log(*s*) − *s*

for any real *x* and positive *s*. The gap between the two sides — the "Fenchel-Young gap" — is always nonneg, and it equals zero if and only if *s* = exp(*x*). In other words, exp and log are the unique pair of functions that saturate this inequality along the curve *s* = exp(*x*). They are, in the language of optimization theory, perfectly paired.

This duality has profound implications. The same mathematical structure that makes exp and log optimal for function representation also makes them optimal for:

- **Information theory**: The Kullback-Leibler divergence, which measures the "distance" between probability distributions, decomposes naturally into exp-log operations. When a machine learning model learns, it is essentially minimizing KL divergence — and the mathematical engine beneath is exp-log duality.
- **Machine learning**: Mirror descent algorithms use the exp-log duality to design optimization methods that respect the geometry of probability spaces. The multiplicative weights update method, one of the most versatile algorithms in computer science, is mirror descent with the exp-log pair.
- **Statistical physics**: The free energy functional, central to thermodynamics, is the convex conjugate of the log-partition function. When a system reaches equilibrium, it is finding the point where the Fenchel-Young gap vanishes.

## The Bregman Connection

The researchers formalized another deep link through **Bregman divergences** — a family of distance-like quantities generated by convex functions. Named after the Soviet mathematician Lev Bregman, who introduced them in the 1960s for solving optimization problems, these divergences have become central to modern machine learning and statistics.

The exponential function generates one Bregman divergence; the negative logarithm generates another. Each is proven to be nonneg (a fact encoding convexity), and their sum defines an "EML-Bregman divergence" that captures both aspects of the exp-log duality simultaneously.

The KL divergence — perhaps the most important quantity in information theory, measuring how one probability distribution differs from another — turns out to be exactly the Bregman divergence of the neg-entropy function ψ(*x*) = *x* · log(*x*) − *x*. This function has a special property: its gradient is log(*x*), and its convex conjugate is exp(*x*). The circle closes. Information, entropy, optimization, and function representation all meet at the same mathematical crossroads.

The research proves not just that KL divergence is nonneg (the famous Gibbs' inequality from thermodynamics), but exactly when it equals zero: if and only if the two distributions are identical. This is a complete characterization — a mathematical "if and only if" that leaves no ambiguity.

## What It Means

The depth-independence phenomenon suggests that the exponential and logarithm are not merely convenient functions — they are somehow fundamental to the structure of multivariate computation. Any function that can be expressed as a polynomial (or approximated by one) can be decomposed into a fixed-depth architecture of logs and exps, with only the number of terms growing.

This has practical implications for neural network design. The recent resurgence of interest in Kolmogorov-Arnold networks (KANs) — neural architectures directly inspired by the KA representation theorem — suggests that using exp and log as activation functions might be more natural than the currently popular ReLU or sigmoid functions. The depth-independence result provides theoretical backing: an EML-KAN architecture could represent any monomial polynomial at depth 1, whereas ReLU networks require depth proportional to the degree.

There is also a tantalizing connection to circuit complexity, the branch of theoretical computer science that studies the minimum resources needed to compute functions. The depth-independence result says that in the "EML circuit model," monomials of any degree can be computed in constant depth. This is dramatically better than classical arithmetic circuits, where computing *x*^*n* requires at least log(*n*) depth by repeated squaring. The log-exp bridge bypasses this entirely.

Perhaps most intriguingly, the result connects three seemingly disparate fields — approximation theory, convex optimization, and information geometry — through a single pair of functions. The exponential and the logarithm are not just tools for computation. They are, in a precise mathematical sense, the atoms from which complex multivariate relationships are most efficiently assembled.

The ancient Babylonians who first used logarithmic tables to simplify multiplication were, it turns out, onto something much deeper than they knew. The trick of "adding logs instead of multiplying" is not a computational shortcut. It is a glimpse of the fundamental architecture of functions themselves.

---

*This research establishes rigorous mathematical proofs connecting EML function chains to the Kolmogorov-Arnold representation theorem, Fenchel-Young convex duality, and Bregman divergence theory. All main results have been verified through machine-checked mathematical proofs.*
