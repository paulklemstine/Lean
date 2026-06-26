# The Price of Forgetting: Why Erasing a Bit Costs Heat

## A thought that refuses to be free

Imagine you have a single switch that can be either ON or OFF. It is your one bit
of memory. Now suppose you want to *erase* it — to force it into the OFF position
no matter where it started, the way you press "clear" on a calculator. It feels
like the most trivial act in the world. You are throwing information away, not
building anything. Surely destruction is free?

It is not. In 1961 the physicist Rolf Landauer discovered something startling:
forgetting has a thermodynamic price. Every time a computer irreversibly erases one
bit of information, it must dump a minimum amount of heat into its surroundings. The
amount is tiny but it is *unavoidable*, fixed by the temperature of the world around
the machine and by one of the deepest constants in physics. The rule is now called
**Landauer's principle**, and it draws a permanent line connecting two things that
seem to live in different universes: the abstract logic of information, and the
sweaty, dissipative physics of heat.

This article is about that line — and about a recent effort to make it not just
believable but *certain*, by reconstructing the whole argument from elementary
mathematics so airtight that a computer can check every step. Along the way we will
meet a beautiful re-telling of Landauer's bound in the language of **relative
entropy**, a precise account of *when* the bound can actually be reached, and a clean
explanation of why "logical irreversibility" is the same thing as "wasted heat."

## The magic number

Landauer's minimum cost to erase one bit is

$$ W_{\min} = k\,T\,\ln 2. $$

Here $T$ is the absolute temperature of the environment (in kelvin), and $k$ is
**Boltzmann's constant**, $k \approx 1.38 \times 10^{-23}$ joules per kelvin, the
fundamental exchange rate between temperature and energy. The factor $\ln 2$ — the
natural logarithm of two — is the fingerprint of the fact that a bit has exactly two
possible states.

At room temperature, around $300$ K, this works out to roughly $3 \times 10^{-21}$
joules. That is fantastically small: you would have to erase trillions of bits before
the energy added up to the warmth of a single falling raindrop. And yet it is not
zero, and it cannot be cheated. As our chips pack ever more switches into ever smaller
spaces, this once-negligible tax has crept from a curiosity into a real engineering
constraint on the energy efficiency of computation.

Where does $\ln 2$ come from? From counting uncertainty. Before erasure, an unknown
bit could be either ON or OFF with equal odds. Information theorists measure that
uncertainty with the **Shannon entropy**. For a probability distribution $p$ over
outcomes, the entropy is

$$ H(p) = -\sum_\omega p(\omega)\,\ln p(\omega), $$

with the natural convention that an impossible outcome (probability zero) contributes
nothing. A fair coin — our unknown bit, ON or OFF each with probability $\tfrac12$ —
has entropy

$$ H\!\left(\tfrac12,\tfrac12\right) = -\tfrac12\ln\tfrac12 - \tfrac12\ln\tfrac12 = \ln 2. $$

After erasure the bit is *definitely* OFF; there is no uncertainty left, so its
entropy is $0$. The **entropy lost** in erasing the bit is therefore exactly

$$ H(\text{before}) - H(\text{after}) = \ln 2 - 0 = \ln 2. $$

That lost $\ln 2$ of *logical* uncertainty is what Landauer's principle converts,
through the temperature $T$, into the *physical* energy $kT\ln 2$ that must be paid.

## Two faces of the same cost: enter relative entropy

Shannon entropy measures the uncertainty in a *single* distribution. But there is a
second, subtler quantity in information theory that compares *two* distributions: the
**Kullback–Leibler divergence**, also called the **relative entropy**. For a
distribution $p$ measured against a reference distribution $q$, it is defined as

$$ D(p\,\|\,q) = \sum_\omega p(\omega)\,\ln\frac{p(\omega)}{q(\omega)}. $$

You can think of $D(p\,\|\,q)$ as a measure of *surprise*: how badly you would be
fooled if you believed the world was described by $q$ but it was really described by
$p$. It is not a distance — it is asymmetric, and swapping $p$ and $q$ generally
changes the answer — but it has one cast-iron property, known since the work of Gibbs:
it is **never negative**, and it is zero only when the two distributions agree.

This is **Gibbs' inequality**:

$$ D(p\,\|\,q) \ge 0. $$

The proof is a small marvel of economy. It rests on a single elementary fact about the
logarithm — that its graph never rises above its tangent line at $1$:

$$ \ln x \le x - 1 \quad\text{for all } x > 0. $$

Apply this pointwise (with $x = q(\omega)/p(\omega)$), multiply through by the
probability $p(\omega)$, and sum. The right-hand side collapses to $\sum_\omega
\big(p(\omega) - q(\omega)\big) = 1 - 1 = 0$, because both $p$ and $q$ are genuine
probability distributions that sum to one. What remains on the left is exactly
$D(p\,\|\,q) \ge 0$. No heavy machinery, no calculus of variations — just the tangent
line to a logarithm.

Now comes the punchline that ties this back to Landauer. Take $p$ to be the *erased*
bit (all its weight on OFF) and $q$ to be the *uniform* reference (the fair coin,
ON or OFF each with probability $\tfrac12$). Plug into the definition: the OFF term
contributes $1 \cdot \ln(1 / \tfrac12) = \ln 2$, and the ON term contributes nothing
because its probability is zero. So

$$ D(\text{erased}\,\|\,\text{uniform}) = \ln 2. $$

The relative entropy of the erased state against the uniform background is *exactly*
the same $\ln 2$ we found from the Shannon entropy loss. The two accounts — one based
on the change in a single distribution's uncertainty, the other on the divergence of
the final state from a reference — give the identical answer. Landauer's free-energy
cost can be written either way:

$$ k\,T\,\ln 2 = k\,T\,D(\text{erased}\,\|\,\text{uniform}). $$

Why does this matter? Because the relative-entropy form is far more general. The
quantity $kT\,D(p\,\|\,q)$ has a direct physical meaning: it is the *extra free
energy* of a system in state $p$ relative to equilibrium $q$ — the minimum work
needed to push the system from equilibrium into the state $p$, or equivalently the
work you are guaranteed to need to prepare or erase that state. Gibbs' inequality then
says this work is always nonnegative:

$$ k\,T\,D(p\,\|\,q) \ge 0 \quad (k, T \ge 0). $$

You cannot extract free energy for nothing out of a mismatch with equilibrium. The
second law, dressed in information-theoretic clothing.

## The bridge: when logic forces physics

There is a phrase Landauer used that deserves to be made precise: *logical
irreversibility implies thermodynamic irreversibility*. What does it mean for erasure
to be "logically irreversible"? Simply this: the erasure operation is a function that
sends both inputs — ON and OFF — to the same output, OFF. Knowing the output tells you
nothing about the input. The map is **not injective**; it cannot be undone. Two
distinct pasts have been crushed into one present.

This purely logical fact — a statement about a function on two symbols, with no physics
in it at all — turns out to *force* a physical consequence. Any real machine that
performs this non-invertible erasure, while obeying the laws of statistical mechanics,
must dissipate a *strictly positive* amount of heat on average. You cannot build the
forgetting machine that runs cold. The non-injectivity of a two-element function and
the strict positivity of dissipated work are, mathematically, two ends of the same
short argument.

To get there, we need the engine room of nonequilibrium thermodynamics: the
**Jarzynski equality**. Discovered by Christopher Jarzynski in 1997, it is a
remarkable exact identity that holds even when a process is driven rapidly and
violently, far from gentle equilibrium. It relates the *fluctuating* work $W$ done in
a process to the equilibrium free-energy difference $\Delta F$:

$$ \big\langle e^{-\alpha W}\big\rangle = e^{-\alpha \Delta F}, $$

where $\alpha = 1/(kT)$ is the inverse temperature and the angle brackets denote an
average over many repetitions of the (noisy) process. The astonishing thing about
this identity is that it is *exact* — not an approximation, not a limit — and it
encodes the entire second law inside a single average of an exponential.

From this identity one can extract an *exact* bookkeeping of the work. Writing
$\langle W\rangle$ for the mean work, a short manipulation yields

$$ \langle W \rangle = \Delta F + \frac{1}{\alpha}\,
\ln\big\langle e^{-\alpha (W - \langle W\rangle)}\big\rangle. $$

The first term, $\Delta F$, is the reversible free-energy cost — the unavoidable
minimum. The second term is a **fluctuation correction**: a record of how noisy the
process was. Landauer's identity is precisely the special case where the free-energy
cost is the erasure cost, $\Delta F = (\ln 2)/\alpha = kT\ln 2$ divided by the energy
scale, so that the equation becomes the exact statement of one-bit erasure with its
fluctuation tax made explicit.

Now, what is the *sign* of that correction term? Here lies the heart of the second
law. The quantity inside the logarithm is an average of $e^{-\alpha(W-\langle
W\rangle)}$, an exponential of a quantity whose mean is zero. And exponentials are
convex: their graph curves upward. The simple inequality $1 + x \le e^{x}$, true for
every real $x$, lifts to averages and gives

$$ \big\langle e^{-\alpha (W - \langle W\rangle)}\big\rangle \ge 1, $$

so its logarithm is $\ge 0$. The fluctuation correction can only *add* to the cost,
never subtract. We conclude the **second law in finite-size form**:

$$ \Delta F \le \langle W \rangle \qquad (\alpha > 0). $$

Specialising to one-bit erasure gives **Landauer's principle** as a genuine lower
bound:

$$ k\,T\,\ln 2 \le \langle W \rangle. $$

And because erasing the bit costs at least $kT\ln 2 > 0$ whenever the temperature is
positive, the non-invertible erasure map dissipates strictly positive work. Logical
irreversibility has produced thermodynamic irreversibility, exactly as Landauer
claimed.

## When can the bound actually be reached?

A lower bound invites a question: can you ever *achieve* it? Is $kT\ln 2$ a hard floor
you can stand on, or an unreachable ideal you can only approach?

The answer is sharp and satisfying. The fluctuation correction we just met — the gap
between the mean work and the reversible cost — vanishes **exactly when the work has no
fluctuations at all**. If, run after run, the erasure always costs precisely the same
amount of work (a single, deterministic value), then the correction is zero and the
bound is saturated: $\langle W\rangle = kT\ln 2$ on the nose. But the moment the work
*genuinely fluctuates* — the moment two different runs can cost different amounts — the
inequality becomes *strict*, and the average cost is forced *above* $kT\ln 2$.

The mathematics behind this dichotomy is the **strict** version of the convexity bound:
$1 + x < e^{x}$ for every $x \neq 0$. As long as the work fluctuation is nonzero
somewhere, this strict inequality survives the averaging, and the correction is
strictly positive. Physically, the only way to pay exactly Landauer's price is to
erase *reversibly* — infinitely slowly, in the idealized quasi-static limit, where
every run is identical and there is no wasted noise. Any real, finite-speed erasure
fluctuates, and every bit of fluctuation is a surcharge over the ideal. This is the
precise, finite-size meaning of the "Jarzynski-like correction": it is a tax on
haste, strictly positive away from the reversible limit and zero only at it.

## Forgetting in bulk, and computations that run free

Two final consequences round out the picture.

First, the cost is **extensive**: it adds up. An $n$-bit memory register, fully
uncertain, carries entropy $n\ln 2$ — because the uniform distribution over $2^n$
possible states has entropy $\ln(2^n) = n\ln 2$. Erasing the whole register therefore
costs at least

$$ n\,k\,T\,\ln 2, $$

and the guaranteed price *per bit* is exactly $kT\ln 2$, the single-bit answer,
holding for every register size. There is no bulk discount on forgetting.

Second, and conversely, not every computation must pay. The deep principle beneath
Landauer's bound is that **a deterministic computation can never increase entropy**.
If a machine applies any function $f$ to its data, the entropy of the output is at most
the entropy of the input — and the heat it must dissipate, proportional to the entropy
*drop*, is therefore never negative. But when $f$ is **invertible** (injective), no two
inputs collide, no information is destroyed, the entropy is preserved exactly, and the
dissipated heat is precisely **zero**. Reversible computation is, in principle, free.
This is the theoretical license behind the entire field of reversible computing: if you
never throw information away, you never have to pay Landauer's tax. The cost is not a
fee on *computing* — it is a fee on *forgetting*.

## Why bother making it certain?

Landauer's principle has been argued, re-argued, debated, and experimentally confirmed
(beautiful experiments in the last decade have measured the $kT\ln 2$ floor with single
colloidal particles and single electrons). So why reconstruct the whole chain of
reasoning from the most elementary ingredients — the tangent line to a logarithm, the
inequality $1 + x \le e^x$, the definition of a sum?

Because foundational results deserve foundational certainty. By building Landauer's
principle up from these atoms — Gibbs' inequality from the logarithm's tangent, the
second law from the convexity of the exponential, the saturation condition from the
*strict* version of that same convexity — we obtain not just confidence but a kind of
X-ray of the result: we see exactly which mathematical fact powers each physical claim.
The nonnegativity of relative entropy is the tangent line. The second law is convexity.
Reaching the bound is the *strictness* of convexity. Logical irreversibility becoming
heat is the non-injectivity of a two-element map. Each piece of physics is pinned to a
single, transparent piece of mathematics.

That is the quiet pleasure of this corner of science. The price of forgetting, it turns
out, is written in the curvature of an exponential and the slope of a logarithm — and
when you trace it carefully, the abstract logic of information and the concrete physics
of heat are revealed to be the same story, told twice.
