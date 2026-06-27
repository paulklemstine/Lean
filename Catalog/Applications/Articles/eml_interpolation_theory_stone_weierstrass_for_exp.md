# The Two Faces of Approximation: How $\exp$ and $\log$ Quietly Build Every Curve

## A promise no one keeps

There is a famous promise in the mathematics of neural networks, and it is almost always broken in spirit even when it is kept in letter. The promise is called the *universal approximation theorem*, and it says something that sounds wonderful: a neural network, given enough neurons, can approximate **any** continuous function on a bounded region as closely as you like.

It is a true theorem. But read the fine print and you discover it is a promise of pure existence. It says a good network *exists*. It does not tell you how wide that network must be. It does not tell you what its weights are. It does not hand you a recipe. It is the mathematical equivalent of a treasure map that reads, "The gold is somewhere on Earth."

This article is about closing that gap for a particular and surprisingly elegant family of networks — ones built not from the usual sigmoids and ReLUs, but from the two oldest transcendental functions in the book: the exponential $\exp$ and the logarithm $\log$. We call them **EML networks** (Exponential–Multiplicative–Logarithmic), and they are nothing more than finite combinations of $\exp$, $\log$, addition, and multiplication. The story has two acts. In the first, we prove that EML networks can approximate *anything*. In the second, we prove that for a concrete target — the humble parabola $x \mapsto x^2$ — they do so at an explicit, guaranteed rate, with no hidden constants and no hand-waving.

## Act I: Why $\exp$ and $\log$ are enough

To understand why a fixed palette of operations can paint every continuous curve, we need a result from 1937 that is one of the great unifying theorems of analysis: the **Stone–Weierstrass theorem**.

Karl Weierstrass had shown in the 1880s that polynomials can approximate any continuous function on a closed interval. Marshall Stone, decades later, saw the deeper reason. It was not really about polynomials. It was about *structure*. Stone's theorem says: take any collection $\mathcal{A}$ of continuous functions on a compact set $K$. Suppose this collection is closed under the natural operations — you can add two of its members, multiply them, and scale them by constants (such a collection is called an *algebra*). Then $\mathcal{A}$ can approximate every continuous function on $K$, provided it satisfies just **one** geometric condition:

> **Separation of points.** For any two distinct points $x \neq y$ in $K$, the collection must contain *some* function $g$ with $g(x) \neq g(y)$.

That is the entire secret. If your functions can tell every pair of points apart, then by adding, multiplying, and scaling them you can build anything. Separation is the seed; the algebra grows the forest.

So the question "can EML networks approximate everything?" collapses into a much smaller and more concrete question: **can a single EML function separate points?**

### One function to separate them all

Here is the candidate, exactly as the theory proposes it:

$$g(t) = e^{a} \cdot \log(b \cdot t + c).$$

It has three dials: $a$, $b$, and $c$. The claim is that with the dials set sensibly — $b > 0$, and $c$ large enough that the argument inside the logarithm stays positive — this single function separates points. The reason is beautifully simple. The function is **strictly monotone**: as $t$ increases, $g(t)$ strictly increases, never pausing, never reversing. And a strictly monotone function is injective — it sends distinct inputs to distinct outputs. Injectivity *is* separation.

Why is $g$ strictly increasing? Read it as a relay race of three runners, each strictly increasing on its leg:

1. The affine map $t \mapsto b\,t + c$ is strictly increasing when $b > 0$.
2. The logarithm $\log$ is strictly increasing on the positive numbers.
3. Multiplying by $e^{a}$, a strictly positive number, preserves the ordering.

Compose three strictly increasing maps and the result is strictly increasing. This is the content of the result we call `emlSep_strictMonoOn`, which states precisely that $g(t) = e^a \log(bt+c)$ is strictly increasing on the set of $t$ where $bt + c > 0$. From it follows `emlSep_separates`: any two distinct admissible points land on distinct values.

There is one subtlety worth dwelling on, because it is exactly the kind of detail that separates a real proof from a plausible sketch. The logarithm is only monotone where its argument is **positive**. Near the place where $bt + c$ would dip to zero, $\log$ plunges to $-\infty$ and the clean monotone behavior breaks down. So the condition "$bt + c > 0$" is not decoration — it is load-bearing. The theorem is *guarded* by it.

How do we guarantee positivity once and for all on a given interval $[lo, hi]$? With a single clean choice of dials: set $a = 0$, $b = 1$, and $c = 1 - lo$. Then

$$g(t) = \log(t + 1 - lo),$$

and for any $t \ge lo$ the argument satisfies $t + 1 - lo \ge 1 > 0$. Positivity is automatic, everywhere on the interval. This is `emlSep_separates_Icc`: on $[lo, hi]$, the function $\log(t + 1 - lo)$ separates every pair of points.

### From one function to everything

Now we feed this single separating function into Stone's machine. The functions you can build from $\log(t + 1 - lo)$ by adding, multiplying, and scaling form an algebra. That algebra separates points (we just proved it). Therefore — by Stone–Weierstrass — that algebra is **dense**: every continuous function on $[lo, hi]$ can be approximated arbitrarily well by these EML combinations. This is the headline of Act I, the theorem `eml_adjoin_dense_on_Icc`:

> The algebra generated by the single EML function $t \mapsto \log(t + 1 - lo)$ is uniformly dense in the space of all continuous functions on $[lo, hi]$.

Pause to appreciate what this says. *One* logarithm, plus the freedom to add, multiply, and scale, reproduces the entire continuum of continuous functions on an interval — sine waves, sawtooths, the wild graph of your favorite pathological example, all of them, to any tolerance you name. The transcendental richness of $\log$ is so great that a single copy of it seeds the whole space.

## Act II: From "exists" to "here it is"

Act I is a universal-approximation theorem, and like all such theorems it is existential. It tells us a good EML approximation exists; it does not build one or bound its size. Act II repairs exactly this, for a concrete and beloved target: the parabola $f(x) = x^2$ on the unit interval $[0,1]$.

The construction uses only the *exponential* half of the EML toolkit. Define, for a small step size $h > 0$, the function

$$\text{emlQuadApprox}_h(x) = \frac{2}{h^2}\left(e^{hx} - 1 - hx\right).$$

This is a genuine EML network: one exponential, two subtractions, and two scalar multiplications. Where does it come from, and why should it look like $x^2$? The answer is the Taylor series of the exponential, the most reliable source of polynomials in all of analysis:

$$e^{hx} = 1 + hx + \frac{(hx)^2}{2} + \frac{(hx)^3}{6} + \cdots$$

Subtract off the first two terms $1 + hx$ and you are left with $\frac{(hx)^2}{2} + \frac{(hx)^3}{6} + \cdots$. Multiply by $\frac{2}{h^2}$ and the leading term becomes exactly $x^2$, while everything after it carries at least one extra factor of $h$:

$$\text{emlQuadApprox}_h(x) = x^2 + \frac{h\,x^3}{3} + \frac{h^2 x^4}{12} + \cdots$$

As the step $h$ shrinks toward zero, the tail vanishes and the parabola emerges. The exponential, properly rescaled, *is* the parabola plus a controllable error.

### The rate, with a real number attached

The whole point of Act II is to refuse to stop at "the error vanishes." We want to know *how fast*. The result `emlQuadApprox_rate` delivers an honest, finite bound:

> For every step size $h$ with $0 < h \le 1$ and every $x$ in $[0,1]$,
> $$\left|\,\text{emlQuadApprox}_h(x) - x^2\,\right| \le \frac{4}{9}\,h.$$

No asymptotic fog, no unspecified constant $C$, no "for sufficiently small $h$." A concrete fraction, $4/9$, valid for every $h$ up to $1$. If you want the approximation accurate to within $\varepsilon$, you choose $h = \tfrac{9}{4}\varepsilon$ and you are done. Phrased in the language of network *width* — where using $n$ refinement steps corresponds to $h = 1/n$ — the error decays like $\tfrac{4}{9n} = O(1/n)$. You can dial in any accuracy and know exactly the price.

Where does $4/9$ come from? The error is $\frac{2}{h^2}\sum_{k \ge 3}\frac{(hx)^k}{k!}$, which on $[0,1]$ is largest at $x = 1$ and grows with $h$, so it is maximized at $h = 1$, where it equals $2\left(e - 2 - \tfrac12\right) = 2(e - 2.5) \approx 0.4366$. The bound $4/9 \approx 0.4444$ is a clean rational number sitting just above this worst case — provably correct and almost tight. (The true leading slope, by the way, is $1/3$, coming from the $\tfrac{h x^3}{3}$ term at $x=1$; pinning down the exact optimal constant between $1/3$ and $4/9$ is a tidy open question.)

## Why this matters beyond the parabola

It is tempting to dismiss "approximating $x^2$" as a toy. It is not. It is a *proof of concept for constructive guarantees*. The universal-approximation literature is overwhelmingly existential; results that hand you an explicit network with an explicit, computable error bound are rare and valuable. Act II is exactly such a result, and the recipe behind it — rescaled exponential increments built from Taylor remainders — generalizes. The same second-order increment kernel that reproduces $x^2$ can, by linear superposition, be aimed at any Lipschitz function, with the conjecture that the same $O(1/n)$ first-order rate survives.

There is also a conceptual payoff. Modern machine learning is built on a small zoo of activation functions — ReLU, sigmoid, tanh, softplus — chosen largely for convenience of gradient computation. The softplus activation $\log(1 + e^x)$ is, tellingly, an EML function: it is exactly the kind of $\exp$-$\log$ composition this theory studies. By placing $\exp$ and $\log$ at the foundation and deriving approximation *constructively*, this work suggests a way to think about expressive power that is grounded in classical analysis rather than empirical lore. The strict monotonicity that gives separation is the same monotonicity that makes such activations well-behaved for optimization; the two virtues are not a coincidence.

And there is the sheer economy of the thing. Two functions — $\exp$ and $\log$, each the inverse of the other, the pair that turns multiplication into addition and powers into products — turn out to be a complete basis for continuous functions, in two complementary senses. $\log$ supplies *separation*, hence the qualitative power to approximate everything. $\exp$ supplies *quantitative rates*, hence the explicit recipes. Between them they cover both faces of approximation: that it can be done, and how well.

## The shape of the argument, in one breath

Strip away the details and the logic is a clean chain:

**strict monotonicity** $\Rightarrow$ **injectivity** $\Rightarrow$ **separation of points** $\Rightarrow$ (Stone–Weierstrass) $\Rightarrow$ **density** — and separately, **Taylor's theorem** $\Rightarrow$ **explicit increment** $\Rightarrow$ **$4/9$ error bound** $\Rightarrow$ **$O(1/n)$ rate**.

The first chain tells you EML networks are universal. The second tells you they are efficient on concrete targets, with numbers you can hold in your hand. Together they turn a famous broken promise — "a good network exists, somewhere" — into a kept one: here is the function, here is its width, and here, to the fraction $4/9$, is exactly how wrong it is allowed to be.

That is the quiet power of $\exp$ and $\log$. The two functions that taught humanity to multiply by adding now teach our networks to approximate by composing — and, for once, they show their work.
