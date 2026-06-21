# The Two Letters That Can Spell Any Curve

## How a single exponential — and its gentle cousin, the softplus — can reconstruct every continuous shape

Imagine you are handed an unknown curve. Maybe it is the temperature of a city over a single day, the price of a stock between the opening and closing bells, or the brightness of a star as a planet drifts across it. You don't know the formula. You only know that the curve is *continuous* — it has no sudden teleportations, no instantaneous jumps. The question is deceptively simple: **using only a small alphabet of mathematical operations, can you rebuild this curve to any accuracy you like?**

It turns out the answer is yes, and the alphabet can be astonishingly small. You do not need sines and cosines. You do not need an infinite library of special functions. You need essentially two letters — the exponential function $e^x$ and the logarithm $\log x$ — together with the four operations of grade-school arithmetic: addition, subtraction, multiplication, and division. Functions built by composing these ingredients are called **EML functions** (Exponential–Multiplicative–Logarithmic), and this article is about a striking fact: *the EML alphabet is rich enough to write down every continuous curve, as closely as you want.*

What is more, you don't even need the whole alphabet. A single, well-chosen generator already does the job. And when you want not just *that* an approximation exists but *how good* it is at a given cost, a humble function called the **softplus** delivers explicit, honest error bars.

Let's walk through the story.

---

## Part 1: Density, or "close enough is everything"

Mathematicians have a precise word for "you can get as close as you want": **density**. A collection of functions is *dense* in the space of all continuous functions on an interval if, for any target curve $f$ and any tolerance $\varepsilon > 0$ (think of $\varepsilon$ as the thickness of your pencil line), there is a function $g$ in your collection that stays within $\varepsilon$ of $f$ everywhere at once:

$$\max_{x} \, |g(x) - f(x)| < \varepsilon.$$

This "everywhere at once" requirement — the *uniform* norm — is strict. It is not enough to match the target at a few sample points; the approximation must hug the entire curve from end to end, with no place where the two drift apart by more than the thickness of a pencil line.

The most famous density result in all of analysis is the **Weierstrass approximation theorem**: ordinary polynomials are dense in the continuous functions on any closed interval. Every continuous curve, no matter how wiggly, can be traced by a polynomial to within any tolerance. A century later, Marshall Stone discovered *why* this works, and his explanation — the **Stone–Weierstrass theorem** — is one of the great unifying insights of twentieth-century mathematics.

Stone's insight was that density is not really about polynomials at all. It is about two structural properties of a family of functions:

1. **The family is an algebra.** You can add two of its functions, multiply them, and scale them by constants, and you never leave the family. (Polynomials obviously satisfy this — add or multiply two polynomials and you get another polynomial.)

2. **The family separates points.** For any two distinct inputs $x \neq y$, *some* function in the family gives them different outputs. The family is rich enough to "tell points apart."

Stone proved that on a closed, bounded domain, **any** algebra of continuous functions that separates points (and contains the constants) is automatically dense. Separation is the *only* nontrivial hypothesis. If your toolkit can distinguish any two points, it can reconstruct any continuous curve.

This reframing is liberating. To prove that some exotic family of functions can approximate everything, you no longer have to construct clever approximations by hand. You just have to check one thing: *can the family tell points apart?*

---

## Part 2: One generator to rule them all

Here is where the EML story gets surprisingly economical. Suppose you pick a single continuous function $g$ on the interval $[0,1]$ and form the smallest algebra containing it — that is, all the *polynomials in $g$*:

$$c_0 + c_1\, g + c_2\, g^2 + c_3\, g^3 + \cdots + c_k\, g^k.$$

When is this one-generator family dense? Stone's theorem reduces the question to a single word: **injectivity**.

A function $g$ is *injective* if it never takes the same value twice — if $x \neq y$ forces $g(x) \neq g(y)$. But that is *exactly* the point-separating condition! If $g$ itself separates every pair of points, then so does the algebra of polynomials in $g$ (the generator $g$ is already sitting inside that algebra, ready to do the separating). So Stone–Weierstrass kicks in and the whole family is dense.

This is the content of the result we call **single-generator density**:

> **Theorem (single injective generator suffices).** *Let $g$ be a continuous, injective function on a closed bounded domain. Then the algebra of all polynomials in $g$ is dense in the space of continuous functions: every continuous target can be uniformly approximated to any accuracy by a polynomial in $g$ alone.*

The proof is almost embarrassingly short once you see it: injectivity means $g(x) \neq g(y)$ whenever $x \neq y$, which is *precisely* separation of points, and separation is all Stone–Weierstrass needs. We even get the quantitative companion for free:

> **Theorem (single-generator $\varepsilon$-approximation).** *For any continuous target $f$ and any tolerance $\varepsilon > 0$, there is a polynomial $p$ in the single generator $g$ with $\max_x |p(x) - f(x)| < \varepsilon$.*

The beauty is that the *identity* of the generator never enters the argument. It does not have to be polynomial, trigonometric, or anything special. It just has to be injective. The generator is, in a precise sense, *generic*: almost any function you scribble down that doesn't fold the interval back on itself will generate everything.

---

## Part 3: The exponential as a universal seed

Now we plant a specific seed. Take the most fundamental EML primitive of all — the exponential function $e^x$ — restricted to the interval $[0,1]$. This is what we call the **exponential generator**, written $\mathrm{expGen}$.

Is $e^x$ injective? Absolutely — the exponential is strictly increasing, so it never repeats a value: if $e^x = e^y$ then $x = y$. (This is just the statement that the logarithm is a genuine inverse.) Therefore $e^x$ separates the points of $[0,1]$, and our single-generator theorem applies instantly:

> **Theorem (density of the exponential EML class).** *The algebra of real polynomials in $e^x$ — that is, all functions of the form*
> $$c_0 + c_1 e^x + c_2 e^{2x} + \cdots + c_k e^{kx}$$
> *— is uniformly dense in the continuous functions on $[0,1]$.*

Pause to appreciate what this says. The "exponential polynomials" $\sum_j c_j e^{jx}$ are about as simple as EML functions get. They have **compositional depth one**: a single layer of exponentials, combined with arithmetic. And yet this shallow, depth-one class is already capable of tracing *any* continuous curve on $[0,1]$ to any precision. The full machinery of nested exponentials and logarithms — the deep EML towers — is not required for *qualitative* universality. One layer of $e^x$ suffices.

This is the EML analogue of the classical fact that ordinary polynomials are universal. Polynomials are built from the identity function $x$; the exponential class is built from $e^x$. Both seeds are injective, so both grow into everything.

---

## Part 4: From "exists" to "how good?" — the softplus bridge

Density is a *qualitative* promise: an approximation exists. But an engineer building a system, or a data scientist training a model, wants a *quantitative* answer: *given a budget — so many terms, so much computation — exactly how close can I get?* For this we change generators, trading the exponential for its smoother relative, the **softplus**.

Modern machine learning is built on a piecewise-linear switch called the **ReLU** (Rectified Linear Unit):

$$\mathrm{relu}(x) = \max(x, 0).$$

It is zero for negative inputs and the identity for positive inputs, with a sharp corner — a *kink* — at the origin. ReLU is the workhorse nonlinearity of neural networks, but its kink is not an EML function (you cannot build a sharp corner from smooth exponentials and logarithms exactly). What you *can* build is an arbitrarily good smooth substitute. Enter the softplus:

$$\mathrm{softplus}_\beta(x) = \frac{\log\!\left(1 + e^{\beta x}\right)}{\beta}.$$

Read the formula from the inside out and you see it is a textbook EML function: take an exponential $e^{\beta x}$, add the constant $1$, take a logarithm, and divide by the scalar $\beta$. Its compositional **depth is exactly two** — one exponential followed by one logarithm. It is the simplest genuinely nonlinear EML primitive there is. The number $\beta > 0$ is a *steepness* dial: large $\beta$ makes the curve hug the ReLU corner tightly; small $\beta$ makes it a gentle ramp.

How close is softplus to ReLU? The Phase-A analysis pins it down with a clean two-sided sandwich. On one side, softplus is always at least ReLU:

$$\mathrm{relu}(x) \le \mathrm{softplus}_\beta(x).$$

On the other side, it never overshoots by more than a fixed, $x$-independent amount:

$$\mathrm{softplus}_\beta(x) \le \mathrm{relu}(x) + \frac{\log 2}{\beta}.$$

Putting the two halves together gives the headline **depth-two rate**:

$$\bigl|\,\mathrm{softplus}_\beta(x) - \mathrm{relu}(x)\,\bigr| \le \frac{\log 2}{\beta} \qquad \text{for every } x.$$

This is a remarkably strong statement. The error is **uniform** — the *same* bound $\frac{\log 2}{\beta}$ holds for all inputs $x$, from $-\infty$ to $+\infty$, not just on a tiny interval. And it shrinks like $1/\beta$: double the steepness, halve the error. The constant $\log 2 \approx 0.693$ is not an artifact; it is *sharp*, achieved exactly at the kink $x = 0$, where $\mathrm{relu}(0) = 0$ but $\mathrm{softplus}_\beta(0) = \frac{\log(1+1)}{\beta} = \frac{\log 2}{\beta}$. The worst case lives precisely at the corner, which is exactly where intuition says a smooth curve should struggle most to imitate a sharp one.

The underlying inequality powering all of this is elementary and pretty: for any real $t$,

$$1 + e^t \le 2\, e^{\max(t, 0)},$$

which after taking logarithms and dividing by $\beta$ becomes the upper sandwich bound. The lower bound is just monotonicity of the logarithm.

---

## Part 5: Building whole networks, with error bars

A single softplus unit is one neuron. Real approximation power comes from combining many of them. A **shallow network** — a single hidden layer of width $N$ — is a weighted sum of $N$ shifted, scaled ReLU units:

$$F(x) = \sum_{i=1}^{N} c_i \, \mathrm{relu}(a_i x + b_i).$$

Such sums can trace any continuous piecewise-linear curve, and piecewise-linear curves can trace anything continuous. Now replace every ReLU by a softplus of steepness $\beta$, producing a genuine shallow **EML** network. How much error does this swap introduce? Because each replacement costs at most $\frac{\log 2}{\beta}$, and the costs add up weighted by the output coefficients, the total uniform error is controlled explicitly:

> **Theorem (shallow-network error bound).** *Replacing every ReLU unit in a width-$N$ network by a softplus unit of steepness $\beta$ changes the output by at most*
> $$\left(\sum_{i=1}^N |c_i|\right)\frac{\log 2}{\beta}$$
> *uniformly in $x$.*

The error is the total "output weight mass" $\sum_i |c_i|$ times the per-unit rate $\frac{\log 2}{\beta}$. Nothing is hidden; every quantity is something you can read off the network. And because the only free parameter is $\beta$, you can drive the error below *any* target $\varepsilon$ simply by turning up the steepness:

> **Theorem (explicit accuracy on demand).** *For any target accuracy $\varepsilon > 0$, choosing the steepness*
> $$\beta > \frac{\left(\sum_i |c_i|\right)\log 2}{\varepsilon}$$
> *guarantees the shallow softplus network is within $\varepsilon$ of the original ReLU network everywhere.*

This is the quantitative payoff that density alone cannot give. Stone–Weierstrass tells you a good approximation *exists* somewhere in the haystack; the softplus rate tells you *exactly which needle to grab* and *how sharp it will be*.

---

## Why this matters

Two threads weave together here, and their union is the real story.

The **qualitative thread** says the EML alphabet is universal: a single injective generator — and in particular the lone exponential $e^x$ — already grows into a family dense in all continuous functions. This is a statement about *what is possible in principle*, and it is proved with a single elegant observation: injectivity *is* point separation, and point separation is all that Stone–Weierstrass requires.

The **quantitative thread** says that when you want *guarantees with numbers attached*, the depth-two softplus unit delivers a uniform $O(1/\beta)$ rate with a sharp constant $\log 2$, which lifts cleanly to whole shallow networks with an explicit, auditable error budget.

Together they close a loop that matters far beyond pure mathematics. Every neural network is, under the hood, an EML function — a tower of exponentials, logarithms (think softmax and log-likelihoods), and arithmetic. The fact that such towers are *universal* is the theoretical license for using them at all; the fact that *shallow* ones already approximate with *explicit, controllable* error is the theoretical license for using small, interpretable, certifiable ones. When you want a model whose behavior you can *prove* something about — a model deployed in a medical device, an aircraft controller, a financial system — knowing the exact error of a depth-two approximation, with a constant as concrete as $\log 2$, is worth far more than a vague promise that "something close exists."

So the next time you see a smooth $S$-shaped ramp in a machine-learning diagram, recognize it for what it is: a logarithm of one-plus-an-exponential, a two-letter word in the EML alphabet, quietly approximating a sharp corner to within $\log 2$ divided by however steep you dare to make it. From two letters, every curve.
