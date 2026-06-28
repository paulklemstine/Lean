# When Multiplication Hides Inside an Exponential: The Secret Geometry of Kolmogorov–Arnold Networks

## A question that refuses to die

In 1900, David Hilbert stood before the International Congress of Mathematicians and read out a list of problems that would shape a century. His thirteenth problem asked something that sounds almost childish: *can every function of several variables be built out of functions of fewer variables?* Could the tangled, multidimensional relationships of nature always be unspooled into simpler, one-dimensional threads?

For decades the answer seemed to be "no, surely not." Functions of three variables felt irreducibly three-dimensional. Then, in 1957, the Soviet mathematician Andrey Kolmogorov and his nineteen-year-old student Vladimir Arnold proved the opposite — and they proved it in the most spectacular way imaginable.

Their theorem says this: **every** continuous function $f$ of $n$ variables, no matter how complicated, can be written as a finite recipe built only from *addition* and a handful of *single-variable* functions. Precisely, there exist continuous one-variable functions so that

$$f(x_1, \dots, x_n) = \sum_{q=0}^{2n} \Phi_q\!\left( \sum_{p=1}^{n} \psi_{q,p}(x_p) \right).$$

Read that slowly. On the right there is no multiplication of variables, no interaction more complex than feeding a number into a function and adding the results. There are exactly $2n+1$ "outer" functions $\Phi_q$ and a grid of "inner" functions $\psi_{q,p}$, each eating a single coordinate. Every continuous surface over a cube — every weather model, every economic forecast, every image — is secretly a layered sandwich of curves and sums.

For sixty years this was a beautiful theorem with almost no users. The inner functions Kolmogorov and Arnold conjured were monstrous: continuous but wildly non-smooth, impossible to write down, impossible to compute. The theorem promised a representation existed but handed you nothing you could actually draw.

Then deep learning arrived, and suddenly the sandwich looked exactly like a neural network. The recent wave of *Kolmogorov–Arnold Networks* (KANs) takes the theorem literally: put learnable curves on the edges of a network instead of fixed weights, and let the data discover the inner and outer functions. The old existence theorem became an architecture.

But a nagging question remained, and it is the question this article is about. The theorem says the inner functions exist. **It never says what they look like.** If we want to *build* them — store them, compute them, reason about them — we need a concrete vocabulary. What if we insisted that every inner and outer function be drawn from one specific, well-behaved family of expressions?

## The exp–log–multiply vocabulary

The family we choose is deliberately frugal. Call an expression an **EML term** — short for *exp–log–multiply* — if it can be built from a single variable and constants using only four operations: addition, multiplication, the exponential $\exp$, and the logarithm $\log$. So $3x + 1$, $\exp(x)$, $\log(2x)$, and $\exp(\log x + 5)$ are all EML terms; an infinite power series or a fractal is not.

EML terms are attractive for three reasons. They are *finite* — you can write each one on an index card. They are *computable* — your calculator already has all four buttons. And they are *transparent* — you can read the formula and understand the function, unlike the opaque weight matrices of an ordinary neural network.

The conjecture, then, sharpens Kolmogorov and Arnold's existence theorem into something an engineer could love:

> **Can the inner and outer functions in a Kolmogorov–Arnold representation always be chosen to be EML terms?**

This article reports a precise, fully verified answer for the cleanest and most important case — and the answer turns out to be a story of triumph, obstruction, and a perfect dividing line.

## The triumph: multiplication is an exponential in disguise

Start with the most basic two-variable function that *isn't* a sum: the product $x \cdot y$. If anything resists being broken into one-dimensional pieces, surely it is multiplication, the very symbol of two things interacting.

And yet. Recall the schoolbook identity that turns multiplication into addition — the identity that powered slide rules and logarithm tables for three centuries:

$$\log(x \cdot y) = \log x + \log y.$$

Exponentiate both sides and you get something remarkable:

$$x \cdot y = \exp\big( \log x + \log y \big), \qquad x, y > 0.$$

Look at what just happened. On the right, each variable is touched by exactly *one* inner function, $\log$. Those two outputs are *added*. Then a *single* outer function, $\exp$, is applied. This is a Kolmogorov–Arnold representation — with one inner function and one outer function, both EML terms, and both of exp/log "depth" exactly one. Kolmogorov's theorem promised at most $2n+1 = 5$ outer functions for two variables. Multiplication needs just **one**.

We call this a **rank-one EML representation**: the absolute minimum, a single outer $\exp$ wrapped around a sum of single-variable inner functions,

$$f(x_1, \dots, x_n) = \exp\!\left( \sum_{i} \psi_i(x_i) \right).$$

The same trick scales effortlessly to any number of variables. For positive numbers $x_1, \dots, x_n$,

$$\prod_{i} x_i = \exp\!\left( \sum_i \log x_i \right).$$

One outer $\exp$. One inner $\log$, shared across every coordinate. The full $n$-dimensional product — the most "interacting" function imaginable — collapses to the leanest possible superposition, for *every* $n$. The verified statement is the lemma `prod_eq_exp_sum_log`: for any finite family of positive reals, $\prod_i f(i) = \exp(\sum_i \log f(i))$.

## The obstruction: where the magic breaks

Every good magic trick has a moment where it could fail, and here it fails at the edge of the world.

The logarithm has a fatal flaw: it is undefined at zero and below. Watch what happens at the innocent-looking point $(0, 1)$. The true product is $0 \cdot 1 = 0$. But $\log 0$ is not a number, and when a formal system is forced to assign it *some* value (the convention $\log 0 = 0$ is standard), the EML formula computes

$$\exp(\log 0 + \log 1) = \exp(0 + 0) = 1 \neq 0.$$

The elegant rank-one representation is **locally** perfect and **globally** broken. It works beautifully on the open positive quadrant and shatters the instant a coordinate touches the boundary. This is the verified theorem `expLog_fails_at_boundary`, and it is not a technicality — it is the price of using $\log$ as an inner function.

Is there a way to represent $x \cdot y$ that works *everywhere*, with no positivity caveat? Yes — and it costs us the transcendental elegance. The polarization identity,

$$x \cdot y = \tfrac{1}{4}(x + y)^2 - \tfrac{1}{4}(x - y)^2,$$

is a Kolmogorov–Arnold representation using two outer functions, $\pm\tfrac14 u^2$, and inner functions $\pm x$, $\pm y$. These are EML terms too — but *polynomial* ones, with zero exp/log depth. They are clumsier (two outer terms instead of one) but utterly robust: valid for all real $x$ and $y$, boundary and all. This is the verified theorem `mul_eq_polarization`, and its boundary success is `polarization_ok_at_boundary`.

So we have a genuine trade-off, and it is captured by a single invariant: the **exp/log depth** of the representation. Depth-one (transcendental) buys you rank one but only on the interior; depth-zero (polynomial) buys you global validity at the cost of more terms. The product is EML-representable in two qualitatively different ways, and the depth is exactly what separates "interior-only" from "everywhere."

## The dividing line: separability is destiny

Here is where the story turns from a clever trick into a theorem with teeth. We found that the *product* collapses to rank one. The natural question — the one that elevates the whole investigation — is: **which functions do?**

The answer is astonishingly clean. A two-variable function $f(x, y)$ has a rank-one EML representation $\exp(\psi(x) + \varphi(y))$ if and only if it is **multiplicatively separable**: it factors as

$$f(x, y) = a(x) \cdot b(y)$$

for some single-variable functions $a, b$. The reason is the same slide-rule magic running in reverse: $\exp$ turns a sum of inner functions into a *product* of factors, $\exp(\psi(x) + \varphi(y)) = e^{\psi(x)} \cdot e^{\varphi(y)}$, and those factors are automatically positive. Rank-one EML representability *is* positive product separability. In $n$ variables this is the verified equivalence `rankOneEMLn_iff_prodSeparable`: a function admits a single outer $\exp$ of a sum of inner functions exactly when it is a product of strictly positive one-variable factors.

But "is this function secretly a product?" sounds hard to check — you would have to guess the factors. The investigation produced a shortcut: a **four-point test** that detects separability without ever finding the factors. A function is multiplicatively separable precisely when it satisfies the *cross-multiplicative identity*

$$f(x, y) \cdot f(x', y') = f(x, y') \cdot f(x', y) \quad \text{for all } x, y, x', y'.$$

This is nothing but the statement that every $2 \times 2$ block of the function's value table has vanishing "multiplicative determinant" — the function's value grid has rank one in a multiplicative sense. The verified theorem `mulSeparable_iff_crossMul` proves this checkable identity is equivalent to separability, and `rankOne_exp_of_pos_crossMul` upgrades it: any strictly positive function passing the four-point test has an *explicit* rank-one EML representation. Even better, `rankOne_exp_continuous` guarantees that if the function's slices are continuous, the inner functions come out continuous too — exactly the regularity Kolmogorov and Arnold demanded.

And now the punchline, the sharpest result of all. Take the other elementary two-variable function, the *sum* $x + y$. Does it pass the four-point test? Compute one block:

$$f(0,0)\cdot f(1,1) = 0 \cdot 2 = 0, \qquad f(0,1) \cdot f(1,0) = 1 \cdot 1 = 1.$$

They disagree. The sum **fails** the cross-multiplicative identity, and therefore — provably, with no escape — it has **no** rank-one EML representation. This is the verified theorem `add_not_rankOne_exp`. You cannot write $x + y$ as $\exp(\psi(x) + \varphi(y))$, not on any region where the test fails, no matter how cleverly you choose $\psi$ and $\varphi$.

So the two most elementary binary operations of arithmetic sit on **opposite sides** of a precise mathematical boundary. Multiplication is rank-one EML; addition is not. The thing that distinguishes them is separability, and separability is detectable by a single, finite, four-point check.

## Why this matters beyond the chalkboard

This might look like a tour of identities every high-schooler half-knows. But pulling them into a single, rigorous frame does real work.

**For machine learning.** Kolmogorov–Arnold Networks are spreading fast because they are more interpretable than standard neural nets. But interpretability is only as good as your vocabulary of inner functions. This investigation says: if your network is trying to model a *multiplicative* relationship — concentrations multiplying in a chemical rate law, probabilities multiplying for independent events, gains multiplying through a signal chain — then a single $\exp$-of-sums layer captures it exactly and minimally, and the inner functions are literally logarithms of your factors. Conversely, if your target is *additive*, forcing an $\exp$-headed layer onto it is mathematically doomed; the four-point test tells you so before you waste a single epoch of training. The cross-multiplicative identity is a cheap diagnostic you can run on data to decide *which kind of layer* you need.

**For scientific modeling.** The boundary obstruction is a parable about domains. The most elegant model — the rank-one $\exp$–$\log$ form — silently lies at the edge of its valid region, returning $1$ where the truth is $0$. In a world of floating-point arithmetic that does not throw errors but quietly substitutes junk values, this is exactly the kind of bug that ships to production. The lesson, made precise, is that transcendental elegance and global robustness can be genuinely incompatible, and the exp/log depth is the dial that trades one for the other.

**For mathematics itself.** Hilbert's thirteenth problem and the Kolmogorov–Arnold theorem are about *existence*. This work is about *construction and classification*: not merely "a representation exists" but "here is the explicit representation, here is the exact class of functions that admit the cleanest one, and here is a finite test to recognize them." The product and the sum become the two poles of a spectrum, and the whole geography of rank-one representability is mapped by the single notion of separability.

## The frontier

The story does not end at rank one. The obvious next move is to ask about *rank two and beyond*: functions that are sums of two or more rank-one EML terms, like $\exp(x+y) + \exp(2x + 3y)$. The conjecture — backed by numerical witnesses — is that such a function genuinely needs two terms, that the four-point test, being a rank-one detector, fails for it, and that there is a strict hierarchy: rank-one functions are a proper subset of rank-two, which are a proper subset of rank-three, and so on. The deeper conjecture is that the minimal number of EML terms needed equals the *rank of the function's value matrix* — that the slide-rule trick turns the whole theory of Kolmogorov–Arnold representation into the familiar, beloved theory of matrix rank.

If that is true, then the question Hilbert asked in 1900 — how do functions of many variables decompose into functions of few — will have, at least for the EML vocabulary, an answer as clean as linear algebra. Multiplication taught us the first lesson: that interaction can hide inside an exponential. The rest of the frontier is learning to count exactly how many exponentials it takes.
