# The Constant That Refuses to Confess

## A number born between two infinities

Add up the reciprocals of the whole numbers, one after another:

$$H_n = 1 + \frac{1}{2} + \frac{1}{3} + \cdots + \frac{1}{n}.$$

This is the *harmonic sum*, and it is one of the great slow-motion explosions of
mathematics. It grows without bound — pile on enough terms and you will eventually
pass any target you like — but it does so with agonizing reluctance. To reach a
sum of $20$ you need more than $272$ million terms. The harmonic sum climbs forever,
but it climbs like a glacier.

How fast, exactly? The answer is one of the most beautiful facts in elementary
analysis: $H_n$ grows like the natural logarithm $\ln n$. The two quantities march
off to infinity locked in step, never drifting more than a hair apart. And here is
the magic. If you subtract the logarithm from the harmonic sum — if you cancel the
two infinities against each other — what is left over does **not** blow up and does
**not** collapse to zero. It settles, gently and permanently, onto a single number:

$$\gamma = \lim_{n \to \infty}\left(H_n - \ln n\right) = 0.5772156649\ldots$$

This is the **Euler–Mascheroni constant**, usually just called $\gamma$ (gamma). It
is the fingerprint left behind when the harmonic sum and the logarithm are
subtracted. Leonhard Euler computed it in 1734; Lorenzo Mascheroni pushed the
decimals further in 1790. Today we know billions of its digits.

And yet, after nearly three centuries, nobody on Earth knows whether $\gamma$ is a
fraction.

## The simplest unanswered question

We sort numbers into two great families. The **rational** numbers are the
fractions: $\tfrac{1}{2}$, $\tfrac{22}{7}$, $-\tfrac{99}{100}$ — anything you can
write as one integer over another. Everything else is **irrational**: numbers like
$\sqrt{2}$ or $\pi$ whose decimal expansions never settle into a repeating pattern.

We have known $\sqrt 2$ is irrational for 2,500 years. We have known $\pi$ is
irrational since 1761 and $e$ since Euler himself. But for $\gamma$ — a constant as
fundamental as any of these, appearing throughout number theory, physics, and the
analysis of algorithms — the question *"is $\gamma$ a fraction?"* remains open. It
is widely believed to be irrational (indeed transcendental), but believing is not
proving.

This package is about the mathematics you build *before* you can settle such a
question: a rigorous, verified toolkit for understanding $\gamma$ — how to corner
it between fences, how to express it as an infinite sum of positive pieces, how
fast you can approximate it, and what a proof of irrationality would even have to
look like. Three theorems form the backbone, and we will state every one of them
precisely.

## Cornering gamma between two fences

The first challenge is simply to be *sure* that $\gamma$ exists — that the leftover
$H_n - \ln n$ really does converge instead of wandering forever. The classical
trick is to trap it between two sequences closing in from opposite sides, like two
hands cupping a firefly.

Define a **lower fence** and an **upper fence**:

$$a_n = H_n - \ln(n+1), \qquad b_n = H_n - \ln n.$$

A short calculus argument — resting on the single fact that the area under the
curve $1/x$ over an interval lies between the values at its endpoints — shows that
the lower fence $a_n$ only ever *rises*, the upper fence $b_n$ only ever *falls*,
and the lower always stays below the upper. They are two monotone armies advancing
toward each other and never crossing. The gap between them is

$$b_n - a_n = \ln(n+1) - \ln n = \ln\!\left(1 + \frac1n\right),$$

which shrinks to zero. Two monotone sequences with a vanishing gap must converge to
the *same* limit, and that shared limit is precisely $\gamma$. In our formal
development the lower fence is the sequence `eulerMascheroniSeq`, the upper fence is
`eulerMascheroniSeq'`, and their common limit is the definition of
`eulerMascheroniConstant`. This is not hand-waving; it is the bedrock on which
everything else rests.

## Theorem A: how close is the obvious guess?

The most natural way to *estimate* $\gamma$ is to stop computing the harmonic sum
after $n$ terms and subtract $\ln n$. How good is this guess? Our first main result
gives a clean, honest error bar.

> **Main Theorem A (`abs_harmonic_sub_log_sub_gamma_lt`).** For every $n \ge 1$,
> $$\bigl|\,H_n - \ln n - \gamma\,\bigr| < \frac{1}{n}.$$

In words: the difference between your $n$-term estimate and the true value of
$\gamma$ is always smaller than $1/n$. Want $\gamma$ to within one part in a
thousand? Use a thousand terms. To within a millionth? A million terms. The error
is guaranteed, not hoped for.

A concrete example makes it vivid. Take $n = 10$. The harmonic sum is
$$H_{10} = 1 + \tfrac12 + \cdots + \tfrac{1}{10} = 2.928968\ldots,$$
and $\ln 10 = 2.302585\ldots$. Their difference is $0.626383\ldots$. The true value
is $\gamma = 0.577215\ldots$, so the actual error is about $0.049$ — comfortably
below the promised ceiling of $1/10 = 0.1$. The theorem's guarantee holds, with
room to spare.

Why is the estimate always an *over*estimate that never errs by more than $1/n$?
Because $H_n - \ln n$ is exactly the upper fence $b_n$, which descends toward
$\gamma$ from above; and its distance to $\gamma$ can be no larger than the gap to
the lower fence, namely $\ln(1+1/n)$, which in turn is less than $1/n$. The
logarithm's own gentle curvature is what supplies the bound.

## Theorem B: gamma as an endless ladder of positive rungs

The fences tell us $\gamma$ exists; they do not give a transparent recipe for *what
it is made of*. The second main result rebuilds $\gamma$ from the ground up as an
infinite sum — and, remarkably, a sum every one of whose terms is positive.

Look again at the lower fence $a_n = H_n - \ln(n+1)$. Because the logarithm of a
product is the sum of the logarithms, $\ln(n+1)$ unfolds as a telescoping chain:
$$\ln(n+1) = \ln\frac{2}{1} + \ln\frac{3}{2} + \cdots + \ln\frac{n+1}{n}.$$
Subtracting this from $H_n$ term by term reorganizes the lower fence into a sum of
matched pairs. Each pair is the difference between a harmonic step and a logarithmic
step:

$$\gamma = \sum_{k=1}^{\infty}\left(\frac{1}{k} - \ln\frac{k+1}{k}\right).$$

This is our second theorem.

> **Main Theorem B (`hasSum_gammaSeries`).** The series with terms
> $g_k = \dfrac{1}{k} - \ln\!\dfrac{k+1}{k}$ converges, and its sum is exactly
> $\gamma$.

Every rung of this ladder is strictly positive, because the curve $\ln(1+x)$ always
lies *below* the straight line $x$: the harmonic step $1/k$ always overshoots the
logarithmic step $\ln\frac{k+1}{k}$, and the constant $\gamma$ is the total of all
those small overshoots. The first rung alone is $1 - \ln 2 = 0.3069\ldots$; the
next is $\tfrac12 - \ln\tfrac32 = 0.0945\ldots$; the rungs shrink roughly like
$1/(2k^2)$, and they pile up to $0.5772\ldots$. Where the fence picture shows
$\gamma$ as a *limit*, this picture shows it as a *construction* — a thing assembled
from infinitely many honest, positive bricks. That structural clarity is exactly
what later accelerations (Vacca-style alternating series, binary-digit regroupings)
take as their starting point.

## Theorem C: what a proof of irrationality must look like

Now the hard question. How would one ever prove that a number like $\gamma$ is *not*
a fraction? You cannot check infinitely many denominators by hand. You need a single,
decisive lever. Our third result is that lever — the classical engine behind nearly
every irrationality proof in history, made fully precise.

The idea is to attack a number $x$ with **integer linear forms**: expressions of the
shape $b\,x - a$ where $a$ and $b$ are whole numbers and $b > 0$. A linear form
measures how close $x$ is to the fraction $a/b$. The criterion says: if you can make
these forms *tiny but never exactly zero*, the number cannot be rational.

> **Main Theorem C (`irrational_of_int_linear_forms`).** Suppose there exist integer
> sequences $a_n$ and $b_n$ with $b_n > 0$ such that for every $n$,
> $$b_n x - a_n \neq 0 \qquad\text{and}\qquad b_n x - a_n \longrightarrow 0.$$
> Then $x$ is irrational.

The reasoning is a beautiful one-line trap. Suppose, for contradiction, that $x$
*were* a fraction $p/q$ in lowest terms. Then each linear form becomes
$$b_n x - a_n = \frac{b_n p - a_n q}{q}.$$
The numerator $b_n p - a_n q$ is a whole number. We assumed the form is never zero,
so this whole number is never zero — meaning its absolute value is *at least 1*.
Therefore the whole linear form has absolute value at least $1/q$, a fixed positive
floor that does not depend on $n$. But we also assumed the forms march down to zero.
A quantity cannot both stay above $1/q$ and sink below it. Contradiction. The only
escape is that $x$ was never a fraction at all.

A familiar example shows the criterion in action on a number we *can* handle: take
$x = \sqrt 2$. Its continued-fraction convergents $\tfrac{a_n}{b_n} =
\tfrac{3}{2}, \tfrac{7}{5}, \tfrac{17}{12}, \tfrac{41}{29}, \ldots$ produce linear
forms $b_n\sqrt2 - a_n$ equal to $-0.0858\ldots, +0.0294\ldots, -0.0102\ldots,
+0.0035\ldots$, alternating in sign, never zero, and visibly collapsing to zero.
Theorem C instantly certifies what the ancient Greeks proved another way:
$\sqrt 2$ is irrational.

## Why gamma is so stubborn — and why the toolkit matters

So why has this lever never been pried under $\gamma$? Because nobody has managed to
build the sequence of linear forms it requires. For $\sqrt 2$ the convergents fall
out of a periodic continued fraction; for $\pi$ and $e$ there are integral and
series representations that, with great ingenuity, can be squeezed into vanishing
integer combinations. For $\gamma$, every known representation has resisted being
shaped into integers $a_n, b_n$ whose linear forms provably shrink to zero without
hitting zero on the way. The famous near-miss is Apéry's 1979 proof that
$\zeta(3) = \sum 1/k^3$ is irrational, achieved by constructing exactly such forms;
half a century of effort has not produced an "Apéry sequence" for $\gamma$.

That is what makes the present toolkit the right foundation rather than a footnote.
Theorem A pins down precisely how fast rational approximations can be extracted from
the harmonic sum. Theorem B re-expresses $\gamma$ as a controlled sum of positive
pieces — the natural raw material for engineering clever integer combinations.
Theorem C states, with no loopholes, the exact target any future proof must hit:
*manufacture nonzero integer linear forms in $\gamma$ that tend to zero.* Together
they convert a vague aspiration — "show $\gamma$ is irrational" — into a concrete
engineering specification.

## A constant everywhere you look

It would be a mistake to think of $\gamma$ as a curiosity. It is woven through
mathematics and its applications. It governs the expected number of comparisons in
the analysis of algorithms like quicksort, where harmonic sums count recursive
splits. It appears in the asymptotics of the divisor function and the distribution
of prime numbers, in the reflection formula for the Gamma function (whence its
name), and in regularization calculations across quantum field theory, where it
emerges when physicists subtract one infinity from another — precisely the move that
defined $\gamma$ in the first place. Every time a logarithm is cancelled against a
discrete sum, $\gamma$ tends to be the residue.

There is something fitting about that. The Euler–Mascheroni constant is the
universe's record of a near-collision between the continuous and the discrete —
between the smooth logarithm and the staircase of fractions $1/k$. It is small,
unassuming, and almost certainly irrational. But until someone forges the right
ladder of integer linear forms, this most natural of numbers will keep its oldest
secret: whether, deep down, it is just a fraction in disguise.

The fences are built. The ladder is counted. The lever is forged and tested. What
remains is to find where to place it.
