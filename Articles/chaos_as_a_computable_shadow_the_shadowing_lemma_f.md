# Chaos as a Computable Shadow

## What a numerical trajectory can—and cannot—promise

A chaotic simulation creates an immediate paradox. Its rule may be perfectly deterministic, yet two computations that differ only in their last decimal places can soon display unrelated futures. Weather models, turbulent flows, recurrent neural networks, and nonlinear control systems all face versions of the same question: when a computer rounds every arithmetic operation, is the curve on the screen still telling us something mathematically true?

There is a seductive answer: every imperfect numerical trajectory must lie near some exact trajectory. That principle is called *shadowing*. In strongly hyperbolic systems, sophisticated shadowing theorems can indeed turn suitable approximate trajectories into nearby exact ones, sometimes for arbitrarily long times. But chaos alone does not grant that conclusion, and ordinary continuity is not enough. Before invoking deep dynamical structure, one needs a baseline that says exactly what follows from a one-step error certificate.

That baseline is a finite-horizon shadowing theorem. It applies to maps on any normed state space, gives a concrete error budget, distinguishes stable from expanding dynamics, and specializes cleanly to the famous logistic map. It also reveals an important connection to residual neural networks: numerical error through time and perturbation through network depth obey the same recurrence.

The story begins not with chaos, but with bookkeeping.

## Approximate and exact orbits

Let $f:E\to E$ be a map on a normed vector space. An exact orbit beginning at $y_0$ is the sequence

$$
y_n=f^n(y_0),
$$

where $f^n$ means applying $f$ exactly $n$ times. A reported sequence $x_0,x_1,\ldots,x_N$ is a $\delta$-pseudo-orbit if every step misses the prescribed dynamics by at most $\delta$:

$$
\lVert x_{n+1}-f(x_n)\rVert\leq\delta
\qquad(0\leq n<N).
$$

This definition deliberately separates two subjects. The *numerical semantics* must establish a local defect $\delta$ for the actual computation. The *dynamics* determine how that defect can grow. Saying “double precision” is not itself a defect certificate: intermediate magnitudes, operation order, overflow, underflow, and exceptional values all matter.

Assume now that $f$ is Lipschitz with constant $L\geq0$:

$$
\lVert f(a)-f(b)\rVert\leq L\lVert a-b\rVert.
$$

Compare the pseudo-orbit with the exact orbit starting from the same first point, $y_0=x_0$. If

$$
e_n=\lVert x_n-y_n\rVert,
$$

then the triangle inequality gives the one-step recurrence

$$
e_{n+1}\leq\delta+Le_n.
$$

The new discrepancy has two sources: at most $\delta$ of fresh local error, plus at most $L$ times everything inherited from the past. Since $e_0=0$, repeated substitution yields the central result.

**Finite-Horizon Shadowing Theorem.** If $x_0,\ldots,x_N$ is a $\delta$-pseudo-orbit of an $L$-Lipschitz map, with $L,\delta\geq0$, then the exact orbit beginning at $x_0$ satisfies

$$
\lVert x_n-f^n(x_0)\rVert
\leq \delta\sum_{k=0}^{n-1}L^k
$$

for every $0\leq n\leq N$.

The proof is induction. The bound is zero at $n=0$. If it holds at time $n$, the one-step recurrence gives

$$
e_{n+1}\leq\delta+L\delta\sum_{k=0}^{n-1}L^k
=\delta\sum_{k=0}^{n}L^k.
$$

No orbit-search algorithm is needed: the theorem exhibits a witness directly—the exact trajectory with the reported initial condition.

## Three regimes of error

The geometric sum divides dynamics into three familiar regimes.

When $0\leq L<1$, old errors shrink. The finite sum is at most $1/(1-L)$, so the estimate becomes independent of time:

$$
\lVert x_n-f^n(x_0)\rVert\leq\frac{\delta}{1-L}.
$$

This is the **Uniform Contraction Shadowing Theorem**. A contracting system continually forgets its numerical past. For example, if $L=0.8$ and each step introduces at most $10^{-12}$ of defect, the discrepancy stays below $5\times10^{-12}$ at every certified time.

When $L=1$, errors can accumulate linearly, giving $e_n\leq n\delta$. When $L>1$, the generic bound grows geometrically. That does not prove every actual error grows so quickly; it says that a global Lipschitz estimate alone cannot rule it out. A worst-case certificate may be conservative, but it is honest.

This distinction is the conceptual heart of the result. A finite-horizon estimate is not the classical shadowing lemma. Classical shadowing for hyperbolic systems uses stable and unstable directions, often allowing the nearby exact orbit to start from a carefully adjusted initial point. A scalar Lipschitz constant discards that directional geometry. It records expansion but not the cancellation that hyperbolicity can provide.

## The logistic map under a microscope

The logistic map at parameter four is

$$
f(x)=4x(1-x).
$$

It is one of the simplest formulas to display chaotic behavior. On the unit interval $[0,1]$, two elementary facts make a complete finite-horizon analysis possible.

First, the interval is forward invariant. If $0\leq x\leq1$, then

$$
0\leq4x(1-x)\leq1.
$$

The lower bound follows because both factors are nonnegative. The upper bound follows from

$$
4x(1-x)=1-4\left(x-\tfrac12\right)^2\leq1.
$$

Second, the map is Lipschitz with constant four on this interval. Indeed,

$$
f(x)-f(y)=4(x-y)(1-x-y),
$$

and for $x,y\in[0,1]$ one has $|1-x-y|\leq1$. Therefore

$$
|f(x)-f(y)|\leq4|x-y|.
$$

These facts produce the **Logistic Finite-Horizon Certificate**. Suppose every reported point $x_n$ through time $N$ lies in $[0,1]$, and suppose

$$
|x_{n+1}-4x_n(1-x_n)|\leq\delta
$$

for $n<N$. Then the exact logistic orbit beginning at $x_0$ obeys

$$
|x_n-f^n(x_0)|
\leq\delta\sum_{k=0}^{n-1}4^k
=\delta\frac{4^n-1}{3}
$$

for every $n\leq N$.

Consequently, a sufficient condition for an error tolerance $\varepsilon$ throughout the first $N$ steps is

$$
\delta(4^N-1)\leq3\varepsilon.
$$

This formula is useful precisely because it is sobering. With $\delta=10^{-16}$ and $\varepsilon=10^{-10}$, the certificate supports only a short horizon: $N=10$ passes, while $N=11$ does not. At one million iterations the global factor-four estimate is astronomically larger than the requested tolerance. Thus the claim that ordinary floating-point output remains within $10^{-10}$ of a true orbit for one million steps does not follow from this analysis. Nor can binary search for an initial condition be assumed to succeed: the logistic map folds the interval, and closeness over a long itinerary is not a monotone function of the initial point.

This does not mean long shadowing is impossible. It means that proving it requires stronger information—hyperbolic structure, symbolic itineraries, interval methods, or local derivative bounds—not a slogan about chaos.

## A bridge to residual networks

Now replace a time-step map by a residual block

$$
F(z)=z+g(z).
$$

If $g$ is $L$-Lipschitz, then

$$
\lVert F(a)-F(b)\rVert
\leq\lVert a-b\rVert+\lVert g(a)-g(b)\rVert
\leq(1+L)\lVert a-b\rVert.
$$

The finite-horizon theorem immediately gives the **Residual-System Shadowing Theorem**: any $\delta$-pseudo-orbit of $F$ through depth $N$ is within

$$
\delta\sum_{k=0}^{n-1}(1+L)^k
$$

of the exact depth-$n$ iterate beginning at the same input.

This is more than a change of vocabulary. In a dynamical simulation, $n$ is time. In a residual network, $n$ is depth. In both cases, each stage injects a local perturbation and later stages amplify it. Quantization errors, approximate kernels, sensor noise, and adversarial input perturbations can all be studied through related recurrences, provided their local bounds are stated precisely.

The estimate also explains why depth-varying analysis matters. Replacing every layer by one worst-case constant may hide contracting stages or small local derivatives. A sharper nonautonomous theory would use products of layer-specific factors rather than $(1+L)^n$.

## What the computation should demonstrate

A responsible numerical demonstration has two complementary parts. First, it generates a reported orbit, records the local defects against a higher-precision evaluation, and checks the theorem’s geometric envelope. Second, it displays how quickly that envelope becomes uninformative for the parameter-four logistic map even while the actual discrepancy may remain temporarily small.

Such an experiment should never present a high-precision decimal trajectory as metaphysically “the” exact real orbit. It is a controlled numerical reference. The theorem itself concerns exact real arithmetic; the experiment illustrates its scale and conservatism.

For contracting maps, the experiment should show errors settling under the uniform ceiling $\delta/(1-L)$. For residual systems, it should show the same recurrence appearing across layers. For the logistic map, it should compare three quantities at each step: observed discrepancy, certified local-defect propagation, and the requested tolerance.

## The right meaning of a computable shadow

Numerical chaos is neither meaningless error nor automatically a nearby exact history. The mathematically justified statement is conditional and quantitative. If a computation supplies a local pseudo-orbit certificate, and if the dynamics supply an amplification estimate, then an exact orbit—often the one from the same initial point—lies within an explicit radius for an explicit horizon.

For contractions, that radius is uniform. For the logistic map under only a global Lipschitz bound, it grows like $4^n$. For residual networks, it grows according to the same geometric calculus with factor $1+L$. These conclusions are strong enough to guide precision choices and modest enough not to disguise missing structure.

This viewpoint changes how simulations should be communicated. A plot is not accompanied merely by a precision label, but by a chain of evidence: a range certificate, a local defect bound, an amplification law, and a stated horizon. Each component answers a different question. Together they turn a visually persuasive computation into a quantitatively interpretable experiment. When the resulting radius is too large, that is useful information rather than failure: it identifies exactly which coarse estimate or missing structure must be improved.

The deeper research program is now sharply defined. One must translate actual floating-point executions into certified local defects; replace global constants by itinerary-sensitive derivative products; and incorporate stable and unstable cone geometry when genuine long-time shadowing is desired. The computer’s trajectory can indeed be a shadow of mathematical truth—but the shape, distance, and lifetime of that shadow must be earned by hypotheses.