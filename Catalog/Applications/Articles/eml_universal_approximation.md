# One Exponential Neuron Is Enough: The Surprising Economy of Universal Approximation

## A question hiding in plain sight

Take a smooth curve drawn on a sheet of paper — say the silhouette of a mountain range, the price of a stock over a year, or the sound pressure of a spoken vowel. Now ask: out of what *building blocks* can you reconstruct that curve to any accuracy you like?

This is the central question of approximation theory, and it is also, in disguise, the central question of modern machine learning. A neural network is nothing more than a recipe for assembling complicated functions out of a fixed menu of simple ones. When we say a network is a "universal approximator," we mean that with enough of these simple pieces, it can mimic *any* continuous behavior on a bounded region — any mountain range, any stock chart, any vowel.

The classical answer to the question is well over a century old. In 1885 Karl Weierstrass proved that ordinary polynomials — sums of powers like $1, x, x^2, x^3, \dots$ — can approximate any continuous function on a closed interval as closely as you wish. In 1937 Marshall Stone generalized this into one of the most quietly powerful theorems in all of analysis, the **Stone–Weierstrass theorem**. It is the bedrock on which a great deal of approximation theory rests.

This article is about a sharp, almost startlingly minimal consequence of that bedrock. We will show — and the result has been verified in full formal detail — that you do **not** need a rich library of building blocks to approximate everything. You need essentially *one good ingredient*. A single exponential "feature," followed by ordinary polynomial arithmetic, is already a universal approximator. In the language of machine learning: **one injective exponential neuron, with a polynomial read-out, can approximate any continuous function on a compact domain.**

Let us unpack what that means, why it is true, and why it matters.

## The EML perspective: exp, multiply, log

The work described here belongs to a research programme around what we call **EML closures** — function classes built by repeatedly combining a few primitives: **E**xponentiation ($x \mapsto e^x$), **M**ultiplication (and addition and scaling), and **L**ogarithm ($x \mapsto \log x$). These three operations, mixed freely, generate an enormous and flexible family of functions. They are also, not coincidentally, exactly the operations a pocket calculator or a hardware floating-point unit performs natively, and they appear everywhere in physics, statistics, and the activation functions of neural networks (the softplus function $\log(1+e^x)$ is a pure EML expression).

The grand question of the EML programme is: **which EML-generated function classes are universal approximators, and how complex must they be?** A naive guess is that you need the full expressive richness of the EML term algebra — all the nested combinations of exponentials, products, and logarithms — to capture every continuous function. The result at the heart of this article overturns that guess. The richness is almost entirely unnecessary. Almost all of the work is done by a single, very humble property.

## The one property that does all the work: telling points apart

Here is the key idea, and it is beautiful precisely because it is so simple.

Imagine you are trying to build functions that can take *different values at different points*. The most basic requirement any universal approximator must satisfy is this: for any two distinct input points $x$ and $y$, there must be **some** function in your toolkit that distinguishes them — that assigns them different outputs. If your entire toolkit always gave $x$ and $y$ the same value, you could never approximate a function that treats them differently. This property is called **separating points**.

The Stone–Weierstrass theorem says something remarkable: for a *subalgebra* of continuous functions — a collection closed under addition, multiplication, and scaling by constants — separating points is not just necessary, it is **sufficient**. If your algebra can tell every pair of points apart, then it can approximate *every* continuous function on a compact domain, to any accuracy.

Stated precisely, the theorem we build on is:

> **Stone–Weierstrass (subalgebra form).** Let $X$ be a compact space and let $A$ be a subalgebra of $C(X, \mathbb{R})$, the continuous real-valued functions on $X$. If $A$ separates points, then $A$ is uniformly dense in $C(X,\mathbb{R})$: for every continuous $f$ and every $\varepsilon > 0$, there is a member $g \in A$ with $\sup_{x \in X} |g(x) - f(x)| < \varepsilon$.

So the entire problem of universal approximation collapses to a single question: **can my function class separate points?**

## A single injective feature separates everything

Now comes the punchline. Separating points sounds like it might require many functions cooperating — one for this pair, another for that pair. It does not. A *single* well-chosen function suffices.

A function $g$ is called **injective** if it never collapses two distinct inputs to the same output: whenever $x \neq y$, we have $g(x) \neq g(y)$. Such a function, all by itself, separates *every* pair of points. And so we obtain the cornerstone lemma:

> **Lemma (one injective generator separates points).** If a subalgebra $A \subseteq C(X,\mathbb{R})$ contains a single injective continuous function $g$, then $A$ separates points.

The proof is almost embarrassingly short. Pick any two distinct points $x \neq y$. Since $g$ is injective, $g(x) \neq g(y)$. Since $g$ belongs to $A$, we have exhibited a member of $A$ that distinguishes $x$ from $y$. Done. There is nothing more to it.

Combine this with Stone–Weierstrass and you get the engine of the whole theory:

> **Theorem (one injective generator is universal).** For a compact space $X$, the smallest subalgebra containing a single injective continuous function $g$ — that is, everything you can build from $g$ by adding, multiplying, and scaling — is uniformly dense in $C(X, \mathbb{R})$.

Read that again. *One* function, as long as it never confuses two points, generates (through pure arithmetic) a class rich enough to approximate **everything**. The expressive power was never in the *number* or *variety* of features. It was hiding in a single qualitative property: injectivity.

## Enter the exponential

Where does the exponential come in? The exponential function $x \mapsto e^x$ has a wonderful property: it is injective on the entire real line. It is strictly increasing, so it never takes the same value twice. Even better, injectivity *propagates* through it. If you have any injective feature $g$, then the composite $e^{g(x)}$ is still injective, because $e^x$ never undoes a distinction that $g$ has already made. Formally:

> **Lemma (the exponential preserves injectivity).** If $g : X \to \mathbb{R}$ is injective and continuous, then $x \mapsto e^{g(x)}$ is injective and continuous.

Feeding this into the previous theorem gives the headline result:

> **Theorem (single exponential feature universal approximation).** Let $X$ be compact and let $g : X \to \mathbb{R}$ be any injective continuous feature. Then the subalgebra generated by the single exponential feature $x \mapsto e^{g(x)}$ is uniformly dense in $C(X, \mathbb{R})$. Equivalently, for every continuous $f$ and every $\varepsilon > 0$ there is a polynomial $P$ such that
> $$\sup_{x \in X}\,\bigl|\,P\!\left(e^{g(x)}\right) - f(x)\,\bigr| < \varepsilon.$$

In the vocabulary of neural networks: a single exponential neuron $x \mapsto e^{g(x)}$, followed by a polynomial read-out layer, is a universal approximator. You do not need a wide hidden layer with thousands of distinct neurons. You need one neuron that does not collapse the input, and the freedom to take polynomial combinations of its output.

## The classical face of the theorem: exponential polynomials

Abstractions are most convincing when they reproduce something concrete and familiar. Specialize the domain $X$ to an ordinary closed interval $[a, b]$ on the real line, and take the feature $g$ to be the simplest injective function imaginable — the identity, $g(x) = x$. The single exponential feature becomes $x \mapsto e^x$, and the polynomials in it are precisely the **exponential polynomials**:
$$
P(e^x) = c_0 + c_1 e^{x} + c_2 e^{2x} + \cdots + c_N e^{Nx} = \sum_{k=0}^{N} c_k\, e^{k x}.
$$
The theorem then states:

> **Corollary (exponential polynomials are dense on $[a,b]$).** Finite real linear combinations of the functions $e^{0\cdot x}, e^{x}, e^{2x}, e^{3x}, \dots$ are uniformly dense in $C([a,b], \mathbb{R})$. Every continuous function on a closed interval can be approximated, to any accuracy, by such an exponential polynomial.

This is a genuine, classical-flavored approximation theorem — a sibling of Weierstrass's polynomial theorem — and it falls out of the abstract machinery in a single line. The functions $e^{kx} = (e^x)^k$ are exactly the powers of $e^x$, so a polynomial in $e^x$ is the same thing as a linear combination of the $e^{kx}$. The substitution $u = e^x$ turns an exponential polynomial on $[a,b]$ into an ordinary polynomial on the interval $[e^a, e^b]$, and Weierstrass's original theorem does the rest.

## Why injectivity is the whole game — and where it forces width

The cleanest way to appreciate a principle is to watch it fail at its boundary. On the real line, a single feature can be injective. But move to higher dimensions and something has to give.

Consider a domain in the plane, $K \subseteq \mathbb{R}^2$, and a so-called **ridge feature** $x \mapsto e^{\langle w, x\rangle}$, which depends on the input only through a single linear combination $\langle w, x \rangle = w_1 x_1 + w_2 x_2$. Such a feature is *blind* to any movement perpendicular to the direction $w$: shift the input along the line where $\langle w, x\rangle$ stays constant and the feature does not notice. Two genuinely different points get the same output. The feature is **not injective** — and by our principle, one such feature can never be universal in the plane.

This is not a defect to be patched; it is a law. It explains, from first principles, *why neural networks need width*. A single ridge neuron in $n$-dimensional space collapses an entire $(n-1)$-dimensional sheet of inputs to a single value. To recover the lost directions you need more features — and a careful count shows you need at least $n$ of them, one for each coordinate, to jointly separate all points. The multivariate companion to our main theorem makes this precise: the $n$ coordinate exponential features $x \mapsto e^{x_1}, \dots, x \mapsto e^{x_n}$ together generate a dense subalgebra on any compact $K \subseteq \mathbb{R}^n$, and fewer than $n$ ridge features provably cannot.

The slogan that emerges is crisp:

> **Nonlinearity is supplied by a single $\exp$; width is forced by the dimension of the domain.**

Depth and richness of the activation menu, so often treated as the essential magic of deep learning, turn out to be secondary. The two real resources are *one* genuinely nonlinear, non-collapsing primitive, and *enough* features to see every direction of the input.

## Connecting to complexity: how hard is a function to approximate?

There is a deeper current running beneath these results. Universal approximation tells you that *some* exponential polynomial gets within $\varepsilon$ of your target $f$ — but it does not, by itself, tell you how *large* that polynomial must be. How many terms $e^{kx}$ do you need? What is the cost of accuracy?

This is where approximation theory shakes hands with **complexity theory**. The number of building blocks required to reach accuracy $\varepsilon$ is a measure of how *intricate* the target function is — a continuous analog of Kolmogorov complexity, the length of the shortest program that generates an object. A gentle, slowly varying function needs only a few terms; a wildly oscillating one needs many. Quantitative "Jackson-type" theorems aim to bound the error of the best degree-$N$ exponential polynomial in terms of the smoothness of $f$, predicting that smoother targets are cheaper to approximate. The substitution $u = e^x$ that we used to prove density also transports the classical polynomial error estimates into the exponential world, suggesting that the cost of $\varepsilon$-accuracy scales gracefully with the inherent complexity of the function being learned.

The vision behind the EML programme is that *the depth, width, and degree needed to approximate a function are not arbitrary engineering choices but reflections of the function's intrinsic complexity* — and that these relationships can be stated and proved as theorems, not merely observed in experiments.

## Why this matters

It is easy to read a result like "one exponential neuron is universal" as a curiosity. It is more than that. Here is why it deserves attention.

**It demystifies universality.** The folklore around neural networks often attributes their power to mysterious, hard-to-pin-down properties of particular activation functions. The results here say the opposite: universality is *cheap and structural*. It requires only that your nonlinearity not collapse distinct inputs. Once you have that, ordinary arithmetic does the rest. The mystery dissolves into a one-line argument about injectivity.

**It separates the two true costs.** By cleanly distinguishing the role of the nonlinearity (one $\exp$ suffices) from the role of width (forced by dimension), the theory tells architects of learning systems where to spend their resources. You are not buying expressive power by stacking exotic activations; you are buying it by ensuring your features collectively see every direction of the input.

**It is exact, not approximate folklore.** Each statement above has been formalized and machine-checked in complete logical detail, with no gaps and no hidden assumptions. The chain of reasoning — Stone–Weierstrass, then "one injective generator separates points," then "exp preserves injectivity," then the exponential-polynomial corollary — is verified end to end. When we say one exponential neuron is enough, it is a theorem in the strictest possible sense.

**It connects fields.** The same circle of ideas touches classical analysis (Weierstrass and Müntz density theorems), modern machine learning (universal approximation, the necessity of width), and complexity theory (how the cost of approximation reflects the complexity of the target). A single, simple principle — *separate the points and you can approximate anything* — runs through all of them.

## The shape of the argument, in one breath

If you remember one thing, let it be this chain:

1. To approximate every continuous function on a compact domain, an algebra of functions need only **separate points** (Stone–Weierstrass).
2. A **single injective function** separates all points at once.
3. The **exponential** is injective and keeps any injective feature injective.
4. Therefore **one exponential feature, plus polynomial arithmetic, approximates everything** — and on an interval this is exactly the density of exponential polynomials $\sum_k c_k e^{kx}$.
5. In dimension $n$, a lone ridge feature *cannot* be injective, so **width equal to the dimension is forced** — explaining, from pure logic, why higher-dimensional learning needs more neurons.

The economy of it is the lesson. Behind the apparent extravagance of universal approximation lies a single, frugal idea: don't lose information, and arithmetic will carry you the rest of the way.
