# The Secret Language of Functions: How Addition and Multiplication Speak Different Dialects

*Every continuous function, no matter how complex, can be built from simple one-variable pieces. But which pieces? A new mathematical structure reveals that logarithms and exponentials are all you need — and that addition is fundamentally harder than multiplication.*

---

In 1957, a 19-year-old Vladimir Arnold and his mentor Andrei Kolmogorov solved one of the most important problems in mathematics: David Hilbert's thirteenth problem, which asked whether every continuous function of several variables could be expressed using functions of fewer variables. Their answer — yes, spectacularly yes — showed that any continuous function of any number of variables can be broken down into a sum of functions that each depend on only one variable at a time.

The Kolmogorov-Arnold theorem, as it's now called, is one of those results that sounds almost too good to be true. Take any continuous function $f(x, y)$ of two variables — it could be as simple as $x \times y$ or as complicated as the temperature distribution across a metal plate. The theorem says you can always write it as:

$$f(x, y) = \Phi_1(g_1(x) + h_1(y)) + \Phi_2(g_2(x) + h_2(y)) + \cdots + \Phi_5(g_5(x) + h_5(y))$$

Five terms, each involving only one-variable functions combined by addition. That's it. No matter what $f$ is.

But there's a catch. The theorem tells you these functions exist — it doesn't tell you what they look like. In the general case, the inner functions $g_q$ and $h_q$ can be monstrous: continuous but nowhere differentiable, fractal-like, impossible to write down explicitly. For decades, mathematicians treated the theorem as a beautiful existence result with no practical applications.

Until now.

## The Logarithmic Key

New research has discovered that for a vast and important class of functions — those defined on positive real numbers — the inner functions can always be chosen from an astonishingly simple family: **logarithmic affine maps**, functions of the form $x \mapsto \alpha \cdot \ln(x) + \beta$.

These are among the simplest functions in mathematics: stretch a logarithm, then shift. Two parameters, $\alpha$ and $\beta$, and you're done. Combined with the exponential function as the "outer" function, these humble log-affine maps can represent multiplication, division, all power functions, polynomials, and much more — all in exact, explicit Kolmogorov-Arnold form.

The key identity that makes everything work is ancient:

$$\ln(x \cdot y) = \ln(x) + \ln(y)$$

Logarithms convert multiplication into addition. And addition is exactly what the Kolmogorov-Arnold theorem needs: the inner functions are combined by adding them together. So the logarithm is not just *a* choice for the inner function — it's the *natural* choice, the one that transforms the multiplicative world of positive reals into the additive world of Kolmogorov-Arnold.

## Two Languages, Two Costs

The most surprising discovery involves the simplest operations: addition and multiplication.

**Multiplication is cheap.** The product $x \times y$ can be written as a single Kolmogorov-Arnold term:

$$x \times y = \exp(\ln x + \ln y)$$

One term. Inner functions: logarithm for both variables. Outer function: exponential. Done.

**Addition is expensive.** To write $x + y$ in Kolmogorov-Arnold form, you need *two* terms:

$$x + y = \exp(\ln x + 0) + \exp(0 + \ln y)$$

And this is provably optimal — no single term of the form $\exp(\alpha \ln x + \beta \ln y)$ can ever equal $x + y$. The proof is elegant: setting $x = y = 1$, any such term gives $\exp(0) = 1$, but $1 + 1 = 2$. One does not equal two.

This is a genuinely surprising result. In our everyday experience, addition feels simpler than multiplication — we teach children to add before we teach them to multiply. But from the perspective of Kolmogorov-Arnold decompositions with logarithmic inner functions, the situation is reversed. Multiplication is the "primitive" operation (one term), and addition is the "compound" operation (two terms).

The reason is deep: logarithms are *multiplicative* at heart. They were invented to convert multiplication into addition. So when we ask them to represent addition directly, they have to work harder — they need two separate terms, each handling one variable independently.

## The Algebra of Decompositions

This width gap between addition (2 terms) and multiplication (1 term) propagates throughout mathematics. Division? One term: $x/y = \exp(\ln x - \ln y)$. Any monomial $x^a y^b$? One term: $\exp(a \ln x + b \ln y)$. The geometric mean $\sqrt{xy}$? One term, and it's *symmetric* — the inner functions for $x$ and $y$ are identical.

But polynomials — which involve addition of monomials — require one term per monomial. A polynomial like $3x^2y + 2xy^3 + 5xy$ needs three terms, one for each monomial. Each term is a "channel" that independently processes the variables through logarithms and reassembles them through exponentiation.

The research also proved two beautiful closure properties. First: if function $f$ needs $Q_1$ terms and function $g$ needs $Q_2$ terms, then $f + g$ needs at most $Q_1 + Q_2$ terms. Second: multiplying $f$ by a constant doesn't increase the number of terms at all. These closure properties mean that the set of decomposable functions forms a *vector space* — one of the most fundamental structures in mathematics.

## The Fenchel-Young Connection

A surprising bridge connects this decomposition theory to an entirely different area of mathematics: convex optimization.

The *Fenchel-Young inequality* states that for any real $x$ and positive $s$:

$$e^x + s \ln s - s - xs \geq 0$$

This gap measures the "cost of mismatch" between the exponential encoding and the logarithmic decoding. When $x = \ln s$ — when the input is the logarithm of $s$ — the gap vanishes exactly. The encoding is lossless. But for any other $x$, there's a strictly positive penalty.

This gap function turns out to be the mathematical expression of a deep principle: the logarithm-exponential encoding works perfectly when it's used correctly (encoding via $\ln$, decoding via $\exp$), and the Fenchel-Young gap quantifies exactly how much you lose when the encoding is "off."

## What This Means

These results have implications in several directions.

For **machine learning**, the connection to Kolmogorov-Arnold Networks (KANs) — a recently proposed neural network architecture inspired by the 1957 theorem — is immediate. The research suggests that for data on positive reals (which covers most real-world measurements), the optimal inner activation functions should be logarithmic. This could guide network architecture design.

For **approximation theory**, the polynomial completeness theorem provides a concrete, constructive path from the abstract Kolmogorov-Arnold theorem to explicit representations. Instead of wrestling with pathological functions, practitioners can use log-affine inner functions and exponential outers.

For **mathematics itself**, the LogAffine Separation Algebra provides a new lens on the interplay between additive and multiplicative structures. The fact that multiplication is "cheaper" than addition in this framework — a reversal of the usual computational hierarchy — hints at deeper structural truths about the relationship between these two fundamental operations.

The most tantalizing open question is whether this approach extends to all continuous functions on compact subsets of $(0,\infty)^2$ — not just polynomials but arbitrary continuous functions. The separation and non-vanishing properties are precisely what's needed for a Stone-Weierstrass density argument, and the polynomial completeness result covers a large class. But bridging from "all polynomials" to "all continuous functions" requires additional work on approximation by polynomials with positive coefficients on positive domains.

## The Bigger Picture

Mathematics has always searched for the simplest building blocks from which complex structures can be assembled. The Kolmogorov-Arnold theorem told us that one-variable functions suffice. The LogAffine Separation Algebra tells us which one-variable functions: logarithms for encoding, exponentials for decoding, and linear scaling in between.

In a sense, this confirms what John Napier intuited four centuries ago when he invented logarithms: the logarithm is nature's preferred coordinate system for positive quantities. It converts the multiplicative complexity of the real world into the additive simplicity that mathematics can handle. The Kolmogorov-Arnold theorem, viewed through this logarithmic lens, becomes not just an existence result but a constructive blueprint: encode with $\ln$, add, decode with $\exp$, and repeat as needed.

The number of times you need to repeat — that's the complexity. And the remarkable finding is that complexity tracks not with how "complicated" a function looks, but with how many essentially *additive* operations it requires. Multiplication is free. Addition costs one term. And every polynomial is just a sum of free operations, each costing one term.

Sometimes the simplest questions — how should we decompose a function? — lead to the deepest answers.
