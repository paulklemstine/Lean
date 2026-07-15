# Why Local Swaps Can Take Cubic Time to Forget

Imagine a token moving along a row of $n$ sites. It can interact only with its immediate neighbors. Every move is local, modest, and reversible: one adjacent swap at a time. Nothing in this picture looks especially slow. Yet a global memory can survive for a time proportional to $n^3$.

That cubic law is the central phenomenon of the weighted path swap model. It is a stripped-down laboratory for reconfiguration dynamics: systems that wander among arrangements through small legal changes. Such dynamics appear in polymer models, card shuffling, exclusion processes, distributed sorting, and combinatorial sampling. The path model asks the cleanest possible version of a broad physical question: when change is local, how quickly can a system forget where it began?

The answer is pinned between two universal constants. For every path with $n\ge 2$ sites, its spectral gap $\gamma_n$ satisfies

$$
\frac{2}{n^3}\le \gamma_n\le \frac{12}{n^3}.
$$

Thus the gap is exactly of cubic order: $\gamma_n=\Theta(n^{-3})$. This does not determine the best leading constant, but it settles the exponent. More importantly, the two sides of the estimate come from complementary ideas. One carefully chosen observable proves that some mode is slow. A telescoping inequality proves that no mode can be much slower.

## Turning motion into energy

Label the sites $0,1,\ldots,n-1$. An observable is any real-valued profile $f$ on these sites. It might represent temperature, concentration, displacement, or simply a numerical probe used to detect whether the system has mixed.

Two quantities measure how this profile behaves. Its adjacent-edge energy is

$$
E_{\mathrm{edge}}(f)=\sum_{k=0}^{n-2}\bigl(f(k+1)-f(k)\bigr)^2.
$$

This energy is small when $f$ changes gently from site to site. The oriented Dirichlet energy counts each undirected edge in both directions, so

$$
\mathcal E(f)=2E_{\mathrm{edge}}(f).
$$

The global spread of $f$ is measured by its ordered-pair variation,

$$
\mathcal V(f)=\sum_{i=0}^{n-1}\sum_{j=0}^{n-1}\bigl(f(i)-f(j)\bigr)^2.
$$

A constant profile has zero variation. Every nonconstant profile has positive variation. The Rayleigh quotient compares the local cost of a profile with its global spread:

$$
R(f)=\frac{\mathcal E(f)}{\mathcal V(f)}.
$$

Finally, the spectral gap is the smallest Rayleigh quotient among all nonconstant observables:

$$
\gamma_n=\inf_{f\ \mathrm{nonconstant}}R(f).
$$

This normalization is worth keeping in view. The spectral gap here is defined using the unnormalized sum over all ordered pairs, not the conventional probability variance. The physics is unchanged, but the numerical scale includes the corresponding factor of $n$.

A small gap means that some large-scale pattern can vary substantially while paying little local energy. Such a pattern decays slowly. A large gap means every nontrivial pattern is energetically expensive and therefore relaxes quickly.

## The slow witness: a ramp across the path

To prove that the gap is small, it is enough to exhibit one slow profile. The natural choice is the position ramp

$$
f(k)=k.
$$

Every adjacent increment equals $1$. There are $n-1$ undirected edges and two orientations, hence

$$
\mathcal E(f)=2(n-1).
$$

The global variation is much larger. Direct summation gives

$$
\mathcal V(f)=\frac{n^2(n^2-1)}{6}.
$$

The numerator grows linearly, while the denominator grows quartically. Dividing yields the exact quotient

$$
R(f)=\frac{12}{n^2(n+1)}.
$$

Because $n+1\ge n$, this implies

$$
\gamma_n\le R(f)\le \frac{12}{n^3}.
$$

This calculation captures the physical source of slow relaxation. A ramp distributes a macroscopic difference across the entire path. Each local step is tiny relative to the total separation between the ends. Local rules see only neighboring differences, while the variation sees every ordered pair. There are roughly $n$ energetic contributions but roughly $n^2$ pairs, and typical distant pairs differ by order $n$. The resulting competition is $n$ versus $n^4$, producing $n^{-3}$.

An upper bound alone, however, leaves open a troubling possibility. Perhaps a more devious profile has an even smaller quotient—say of order $n^{-4}$ or exponentially small. To establish the cubic law, one must control every nonconstant observable at once.

## The path cannot hide a cheaper mode

The key lower-bound fact is a discrete version of a familiar principle: a difference across a long interval is the sum of its local increments.

Suppose $i<j$. Then

$$
f(j)-f(i)=\sum_{k=i}^{j-1}\bigl(f(k+1)-f(k)\bigr).
$$

Cauchy–Schwarz turns this identity into an inequality:

$$
\bigl(f(j)-f(i)\bigr)^2
\le (j-i)\sum_{k=i}^{j-1}\bigl(f(k+1)-f(k)\bigr)^2.
$$

Since $j-i\le n$, and since the partial edge sum is no larger than the total edge energy,

$$
\bigl(f(j)-f(i)\bigr)^2\le nE_{\mathrm{edge}}(f).
$$

The same conclusion holds regardless of the order of $i$ and $j$. Now sum over all $n^2$ ordered pairs. This gives the Path Poincaré Inequality:

$$
\mathcal V(f)\le n^3E_{\mathrm{edge}}(f).
$$

The theorem makes no monotonicity assumption. The profile may rise, fall, oscillate, or look completely irregular. Unique-path geometry alone forces every endpoint difference to be paid for by adjacent increments.

Since $\mathcal E(f)=2E_{\mathrm{edge}}(f)$, every nonconstant $f$ obeys

$$
R(f)=\frac{2E_{\mathrm{edge}}(f)}{\mathcal V(f)}\ge \frac{2}{n^3}.
$$

Taking the infimum over all such profiles proves

$$
\gamma_n\ge \frac{2}{n^3}.
$$

Together with the ramp witness, this completes the two-sided estimate.

## Why the exponent is more important than the constants

The constants $2$ and $12$ are not expected to be final. The lower proof deliberately replaces each exact distance $|i-j|$ by the coarse bound $n$. It also charges every pair against the entire edge set, although a pair uses only the segment between its endpoints. These simplifications lose information.

Nevertheless, they preserve the scaling exponent. That is the robust discovery. The upper bound sees linear local energy divided by quartic global variation. The lower bound sees at most $n$ edges on a route and $n^2$ ordered endpoint pairs. Both mechanisms independently produce the same cubic power.

There is a sharper spectral picture behind the constants. The true slowest profile should be a discrete cosine rather than a straight ramp. For this normalization, the expected exact formula is

$$
\gamma_n=\frac{2-2\cos(\pi/n)}{n},
$$

which would imply

$$
n^3\gamma_n\longrightarrow \pi^2.
$$

This remains a natural next target rather than part of the present two-sided theorem. It explains why the current interval is plausible: $\pi^2$ lies strictly between $2$ and $12$.

## Congestion: every pair sends a message

There is another way to read the proof. Imagine that every ordered pair $(i,j)$ sends one unit of informational traffic along the unique path from $i$ to $j$. An edge near the center carries far more traffic than an edge near an endpoint. The telescoping argument is a routing argument in disguise: global variation is controlled by local energy multiplied by route length and edge congestion.

This viewpoint points beyond lines. On a tree, every pair of vertices still has a unique route. Deleting an edge separates the tree into components of sizes $a$ and $N-a$, so the edge participates in $2a(N-a)$ oriented routes. Recording this exact load should produce stronger Poincaré inequalities than a uniform worst-case estimate.

For more complicated reconfiguration spaces, paths are no longer unique. One can instead choose canonical routes between pairs of states and ask how much traffic accumulates on the busiest transition. This is a standard physical intuition with a combinatorial heart: bottlenecks create long memory because many global changes must pass through a small set of local moves.

## From paths to chord diagrams and product systems

The path is a prototype, not an endpoint. In chord-swap dynamics, states are chord diagrams and legal moves exchange local chord data. A major conjectural extension is that, for a fixed genus $g$, the gap on diagrams with $n$ chords is also of order $n^{-3}$, with constants depending only on $g$.

The path proof separates the challenge into two concrete tasks. For an upper bound, find one genus-aware displacement statistic whose local change is controlled and whose global variance is quartic in $n$. For a lower bound, route all pairs of diagrams through legal swaps while keeping weighted edge congestion at order $n^3$. The analytic bookkeeping is already visible on the line; what remains is the geometry of the chord-diagram state space.

The same ideas suggest stability under products. If several independent path systems evolve through additive coordinate energies, an observable depending on only one coordinate reproduces the one-dimensional upper bound. A conditional-variance argument should give the corresponding lower bound, so the slowest coordinate controls the product. In that regime, adding dimensions creates more ways to move without changing the cubic bottleneck.

## A general lesson about local dynamics

The result is a compact example of how global timescales emerge from local rules. No individual swap is dramatic. Yet a disturbance spread across distance $n$ must be assembled from $n$ tiny increments, and the system must reconcile differences among $n^2$ ordered pairs. Those two counts—route length and pair count—multiply into the cubic scale.

The final theorem can be stated in one line: for every $n\ge2$, the weighted unit path has spectral gap between $2n^{-3}$ and $12n^{-3}$. But the deeper message has two halves. A single smooth witness can expose slow behavior, while a telescoping Poincaré inequality can certify that no hidden profile is slower by an entire power of $n$.

That witness-versus-all-observables structure is widely reusable. It turns a question about a huge family of possible fluctuations into two tangible objects: one profile that moves slowly, and one routing inequality that controls everything. On the path, those objects meet exactly at the cubic exponent.