# When Is a Point Guaranteed to Fly Away? The Mathematics Behind Every Fractal Picture

## A picture made of decisions

Almost everyone has seen the Mandelbrot set: the black, warty, insect-shaped blob surrounded by filaments and flame-coloured haloes. What almost nobody sees is that the image is not a photograph of anything. It is a picture assembled out of millions of tiny yes/no decisions, one per pixel, and every one of those decisions is made by a computer program that gives up early.

Here is the recipe. Pick a complex number $c$ — a point in the plane. Start at the origin and repeatedly apply the map
$$f_c(z) = z^2 + c.$$
That is, form the sequence
$$z_0 = 0,\quad z_1 = c,\quad z_2 = c^2 + c,\quad z_3 = (c^2+c)^2 + c,\ \dots$$
This is the *critical orbit* of $c$. The Mandelbrot set $M$ is, by definition, the set of parameters $c$ for which this sequence stays bounded forever.

"Forever" is a problem for a computer. So every renderer ever written cheats in exactly the same way: it watches the orbit, and the moment some $|z_n|$ exceeds $2$, it declares $c$ to be outside the set, colours the pixel according to how long that took, and moves on. If the orbit survives a few hundred iterations without crossing $2$, the pixel is painted black.

Why $2$? Ask a programmer and you will usually get a shrug and the word "standard". Ask a mathematician and you will get a sketch on a napkin. What follows is the napkin turned into a complete, airtight theory — and then pushed considerably further, into a quantitative description of *how fast* escaping points escape, and of the smooth landscape of "escape rates" that surrounds the black blob and gives fractal images their glow.

## The one line that does all the work

Suppose you are standing at a point $z$ that is already fairly far out, and you apply $f_c$. The squaring term $z^2$ has magnitude $|z|^2$; the additive term $c$ can only pull you back by $|c|$. So
$$|f_c(z)| = |z^2 + c| \ \ge\ |z|^2 - |c|.$$

Now make one assumption: $|z|$ is strictly larger than the **escape radius**
$$R(c) := \max\bigl(2,\ |c|\bigr).$$
Then $|c| \le R(c) < |z|$, and the inequality above becomes
$$|f_c(z)| \ \ge\ |z|^2 - |z| \ =\ \bigl(|z| - 1\bigr)\,|z|.$$

Read that as a multiplication rule: **one step multiplies your distance from the origin by at least $|z| - 1$.** And since $|z| > R(c) \ge 2$, the factor $|z| - 1$ is strictly bigger than $1$. You have not merely moved; you have been amplified.

Better still, the amplification is self-reinforcing. Because $|z| - 1 > 1$, the new point $f_c(z)$ is farther from the origin than $z$ was, so it too lies beyond the escape radius, so *its* amplification factor is at least as large. The escaping region $\{z : |z| > R(c)\}$ is a trap you cannot climb out of, and the multiplier only ever grows.

Iterating this observation gives the central estimate of the theory.

> **Escape Growth Theorem.** Let $c$ be a complex parameter and let $z$ satisfy $|z| > R(c) = \max(2, |c|)$. Write $z_n = f_c^{\,n}(z)$ for the $n$-th point of the orbit. Then for every $n$,
> $$|z_n| > R(c) \qquad\text{and}\qquad \bigl(|z| - 1\bigr)^{n}\,|z| \ \le\ |z_n|.$$

The proof is an induction in which the two halves prop each other up: the first half (the orbit stays outside) licenses the one-step multiplication rule at each stage, and the multiplication rule delivers both halves at the next stage. Since $|z| - 1 > 1$, the right-hand side grows geometrically without bound, and therefore:

> **Escape Criterion.** If $|z| > \max(2,|c|)$ at any single moment, then $|f_c^{\,n}(z)| \to \infty$ as $n \to \infty$.

Note the phrase *at any single moment*. Because the escape criterion applies to arbitrary starting points, and because the orbit of the orbit is again an orbit, the criterion instantly upgrades: if a point $z$ has *any* iterate $z_N$ with $|z_N| > R(c)$, then restarting the argument at $z_N$ shows that the tail of the orbit diverges — and a sequence whose tail tends to infinity tends to infinity. This is the theorem the renderer actually relies on. Crossing the line once, at whatever late stage, is a certificate of divergence that can never be revoked.

## Soundness and completeness: the test is exactly right

The escape-time test does two things, and it is worth separating them.

*Soundness*: if the test fires, the point really does escape. That is the Escape Criterion above.

*Completeness*: if the point escapes, the test eventually fires. This direction is nearly trivial — an orbit going to infinity must eventually exceed $R(c)$ — but combining the two gives a statement of genuine elegance:

> **Bounded ⟺ Never Escapes.** For every $c$ and every starting point $z$, the orbit $\{f_c^{\,n}(z)\}$ is bounded **if and only if** $|f_c^{\,n}(z)| \le \max(2, |c|)$ for all $n$.

There is no third possibility. An orbit that stays bounded stays inside a disc of radius $\max(2,|c|)$ — a specific, computable disc, not just "some" bound. An orbit that ever leaves that disc runs to infinity. This is a dichotomy of remarkable rigidity: for the quadratic family there is no orbit that wanders off, comes back, wanders off again, and manages to stay bounded while occasionally poking beyond the escape radius.

Applied to the critical orbit, this gives exactly the renderer's rule. One needs only the observation that a parameter of the Mandelbrot set automatically satisfies $|c| \le 2$, so that its escape radius $\max(2,|c|)$ is $2$ on the nose: indeed, if $|c| > 2$ then the second critical iterate obeys $|c^2 + c| \ge |c|^2 - |c| = (|c|-1)|c| > |c| = \max(2,|c|)$, so the criterion fires and $c$ escapes. Hence:

> **The Radius-2 Test.** A complex number $c$ belongs to the Mandelbrot set if and only if every point of its critical orbit satisfies $|z_n| \le 2$.

That is the whole algorithm, and it is now a theorem rather than a folk rule. Its companion is the dichotomy: for every $c$ whatsoever, either the critical orbit stays inside the closed disc of radius $2$ for all time, or its modulus tends to infinity.

## Why exactly 2, and not a hair less

Could a renderer save time by testing against $1.99$? No — and the counterexample is famous. Take $c = -2$. Its critical orbit is
$$0,\quad -2,\quad 2,\quad 2,\quad 2,\ \dots$$
because $(-2)^2 + (-2) = 2$ and $2^2 + (-2) = 2$: the orbit lands on the fixed point $2$ and stays there. It is bounded, so $c = -2$ belongs to the Mandelbrot set. But its orbit reaches modulus exactly $2$. Any test that rejects a point on crossing a radius $R < 2$ would wrongly expel $-2$ from the set.

> **Sharpness of the Escape Radius.** For every $R < 2$ there exists a parameter in the Mandelbrot set whose critical orbit exceeds $R$; namely $c = -2$. Hence the constant $2$ in the radius-2 test cannot be lowered.

This is also why the test must be stated with a *strict* inequality — "exceeds $2$", not "reaches $2$". The tip of the Mandelbrot set's antenna sits precisely on the boundary of the criterion, and the theory has to be exact about it.

## From a test to a topology

Once the algorithm is a theorem, the pictures start to prove things. For each $n$, let $T_n$ be the set of parameters that survive $n$ rounds of the test:
$$T_n = \{\,c : |z_k| \le 2 \text{ for all } k \le n \,\}.$$
This is what a renderer with an iteration budget of $n$ actually draws. Each $z_k$ is a polynomial in $c$, hence a continuous function of $c$, so each $T_n$ is a closed set; and clearly $T_0 \supseteq T_1 \supseteq T_2 \supseteq \cdots$. The radius-2 test says precisely that
$$M \ = \ \bigcap_{n \ge 0} T_n .$$
So the Mandelbrot set is a nested intersection of closed sets: it is closed. It is also contained in the disc of radius $2$, hence bounded. Therefore:

> **The Mandelbrot set is compact.**

That is a satisfying loop to close. The crude, finite, give-up-early algorithm is not an approximation to something the mathematics cannot reach; it *is* the mathematics, shown converging from the outside. The same argument, run with a fixed $c$ and a varying starting point $z$, shows that the **filled Julia set**
$$K_c = \{\, z : \text{the orbit of } z \text{ under } f_c \text{ is bounded} \,\}$$
is closed, contained in the disc of radius $\max(2,|c|)$, and hence compact; that it is totally invariant, meaning $z \in K_c$ if and only if $f_c(z) \in K_c$; and that it is never empty, since $f_c$ always has a fixed point $w = \frac{1 + \sqrt{1 - 4c}}{2}$, whose orbit is constant and therefore bounded.

## How fast is "fast"? Two very different answers

The Escape Growth Theorem gives $|z_n| \ge (|z|-1)^n |z|$: exponential growth. It is true, it is enough to prove divergence, and it is also *wildly* pessimistic. For $c = 0.3 + 0.1i$ and $z = 2.5$ the actual orbit moduli are
$$2.5,\quad 6.55,\quad 43.2,\quad 1.87 \times 10^{3},\quad 3.49\times 10^{6},$$
while the certified lower bounds are only
$$2.5,\quad 3.75,\quad 5.63,\quad 8.44,\quad 12.66 .$$
By the fifth step, reality is ahead of the guarantee by a factor of a quarter of a million, and the gap widens without limit.

The reason is that the geometric bound throws away the squaring. Squaring does not multiply the size; it **doubles the logarithm**. Take logarithms in $|f_c(z)| \ge |z|^2 - |z|$ and one obtains, after a short computation valid whenever $|z| > 2$ (so that $\log|z| > \log 2 > 1/2$),
$$\log|z_{n}| - 1 \ \ge\ 2^{\,n}\bigl(\log|z| - 1\bigr),$$
equivalently
$$|z_n| \ \ge\ \exp\Bigl(2^{\,n}\bigl(\log|z| - 1\bigr) + 1\Bigr).$$
This is **doubly exponential** escape: the number of correct digits doubles each step. It converts an escape-time question into a $\log\log$ question. If you want the orbit to exceed a threshold $B$, and you start from $|z| \ge 3$, it suffices that
$$2^{\,n} \ \ge\ \frac{\log B - 1}{\log |z| - 1},$$
i.e. $n$ of order $\log\log B$. Doubling the threshold costs essentially nothing. That is why escape-time renderers can afford absurdly generous bailout radii: raising the bailout from $2$ to $10^{100}$ costs a handful of extra iterations, not a hundredfold more.

For completeness, the crude bound also yields an honest effective statement, useful when the starting point is only barely outside: if $|z| \ge 2 + \varepsilon$ for some $\varepsilon > 0$ and $|z| > R(c)$, then $|z_n| \ge B$ as soon as $n \ge B/(\varepsilon\,|z|)$. Linear in $B$, versus $\log\log B$: a vivid measure of how much the logarithmic viewpoint buys.

## The invisible landscape: escape rates

The doubly exponential bound suggests the right way to measure escape. If $\log |z_n| $ roughly doubles each step, then the quantity
$$G_c(z) \ := \ \lim_{n \to \infty} \frac{\log |z_n|}{2^{\,n}}$$
should settle down to a finite, positive number. It does, and it is the single most important object in this story: the **escape rate**, also known as the Green's function of the filled Julia set.

Why does the limit exist? Because consecutive terms are extremely close. The engine is a small, sharp lemma about how much a squaring distorts a logarithm:

> **Logarithmic Distortion Lemma.** If $r > 2$ and $s$ is any number with $r^2 - r \le s \le r^2 + r$, then
> $$\bigl|\log s - 2\log r\bigr| \ \le\ \frac{2}{r}.$$

Since $|z_{n+1}| = |z_n^2 + c|$ lies between $|z_n|^2 - |z_n|$ and $|z_n|^2 + |z_n|$ (using $|c| < |z_n|$ throughout the escaping region), the lemma applies at every step with $r = |z_n| > 2$, giving $\bigl|\log|z_{n+1}| - 2\log|z_n|\bigr| \le 2/|z_n| \le 1$. Dividing by $2^{n+1}$:
$$\left|\frac{\log|z_{n+1}|}{2^{\,n+1}} - \frac{\log|z_n|}{2^{\,n}}\right| \ \le\ \frac{1}{2^{\,n+1}} .$$
The successive differences are dominated by a geometric series, so the sequence is Cauchy, so $G_c(z)$ exists. Summing the tail from step $n$ onwards gives an explicit error bar,
$$\left| \frac{\log|z_n|}{2^{\,n}} - G_c(z) \right| \ \le\ \frac{1}{2^{\,n}},$$
which is a computable stopping rule: twenty iterations pin the escape rate to within one part in a million.

Three properties make $G_c$ the natural coordinate on the escaping region.

**It doubles under the dynamics.** $G_c(f_c(z)) = 2\,G_c(z)$, and more generally $G_c(f_c^{\,N}(z)) = 2^N G_c(z)$. This is immediate from the definition — shifting the sequence by one step and rescaling — and it means $G_c$ turns the complicated nonlinear map $f_c$ into simple multiplication by $2$.

**It is close to $\log|z|$, quantitatively.** Summing the same geometric bound from the start gives $|G_c(z) - \log|z|| \le 1$ everywhere in the escaping region, and a sharper version of the argument — using $2/|z_n| \le 2/|z|$ rather than $2/|z_n| \le 1$ — improves this to
$$\bigl|G_c(z) - \log|z|\bigr| \ \le\ \frac{2}{|z|} .$$
So $G_c(z) - \log|z| \to 0$ as $z \to \infty$, at rate $O(1/|z|)$: far away, the escape rate is simply the logarithm of the distance, exactly as an electrostatic potential should be. And $G_c(z) > 0$ strictly whenever $z$ escapes, which is what makes $G_c$ a genuine potential vanishing precisely on the filled Julia set.

**It is continuous.** The error bound $|2^{-n}\log|z_n| - G_c(z)| \le 2^{-n}$ is uniform in $z$: the same $n$ works everywhere on the escaping region. Each approximant $z \mapsto 2^{-n}\log|z_n|$ is continuous there, and a uniform limit of continuous functions is continuous, so $G_c$ is continuous on $\{|z| > \max(2,|c|)\}$.

This is the mathematical content of the coloured haloes in fractal images. The smooth bands you see are level curves of $G_c$ — or, in parameter space, of its Mandelbrot analogue. The reason "smooth colouring" schemes look smooth is that the quantity they compute converges uniformly to a continuous function.

## The potential around the Mandelbrot set

The same construction runs in parameter space. For $|c| > 2$ one defines the **Douady–Hubbard potential**
$$G_M(c) \ = \ \lim_{n\to\infty} \frac{\log\bigl|f_c^{\,n}(c)\bigr|}{2^{\,n}},$$
the escape rate of the *critical value* $c$ under its own map. (A subtlety worth flagging: the natural object is the orbit of the critical value $c$, not of the critical point $0$; getting this wrong shifts the answer by a factor of $2$. Since $|c|$ itself equals the escape radius when $|c| > 2$ and so is not strictly beyond it, the clean way to define $G_M$ is $G_M(c) = \tfrac12 G_c(c^2 + c)$, using one step of the dynamics to enter the escaping region and the doubling law to compensate.)

The parameter-space potential inherits everything: it is strictly positive for $|c| > 2$, it is bounded below by the explicit quantity $\tfrac12\bigl(\log|c^2+c| - 2/|c^2+c|\bigr)$, and — again by a uniform $2^{-n}$ error bound on its approximants, each of which is continuous — it is **continuous on $\{|c| > 2\}$**. It is $G_M$, extended by $0$ on $M$ itself, that a modern renderer is really drawing.

## What the story is really about

Three morals, in increasing order of generality.

First: a good inequality is worth a thousand pixels. The whole edifice rests on $|z^2 + c| \ge |z|^2 - |c|$, the triangle inequality applied once. Everything else — invariance, divergence, compactness, potential theory — is bookkeeping on top of that.

Second: the choice of coordinate is the whole game. The multiplicative bound "at least $(|z|-1)$ times bigger" and the additive-in-logarithm bound "at least twice the logarithm" are the *same* inequality viewed through different lenses, but the first yields only "eventually escapes" while the second yields an escape time of order $\log\log B$, a convergent potential function, a functional equation, and continuity. Exponentially lossy estimates and sharp ones can be one change of variables apart.

Third: algorithms and theorems are not different species. The escape-time loop is not an approximation to the Mandelbrot set; the nested closed test sets it computes intersect exactly in the Mandelbrot set, and that identity is what proves compactness. The picture on your screen, with its arbitrary iteration cap and its bailout radius of $2$, is the honest finite shadow of an exact statement — and, thanks to the escape criterion, every black pixel it draws is a pixel about which nothing has been decided, while every coloured one is a pixel about which the answer is certain forever.
