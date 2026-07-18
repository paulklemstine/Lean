# The Topology of Prime Numbers: What Gaps Really Reveal

Prime numbers look like scattered lights along an endless road. The first few stand at $2,3,5,7,11,13, \ldots$, sometimes close together and sometimes separated by a stretch of composite darkness. Number theorists traditionally study this landscape by measuring gaps. Topology suggests another question: if we gradually increase the distance over which two primes can “see” one another, when do isolated lights merge into constellations?

This question belongs to persistent topology, a language developed to distinguish durable geometric structure from short-lived accidents. Yet on the real line, the answer turns out to be both simpler and sharper than one might expect. For any finite increasing list—not only primes—its entire zero-dimensional persistence is governed exactly by its consecutive gaps. At the same time, the ordinary Vietoris–Rips construction cannot create enduring loops from points on a line. The geometry that makes the gap theorem elegant also blocks a tempting story about twin primes producing topological holes.

That combination is scientifically useful. It identifies precisely what this topological lens can measure, exposes what it cannot measure, and points toward richer constructions that may reveal genuinely new arithmetic patterns.

## From points to a growing network

Take a strictly increasing sequence of real numbers

$$
x_0<x_1<\cdots<x_{n-1}.
$$

Choose a scale $\varepsilon\ge 0$. Join $x_i$ and $x_j$ by an edge whenever

$$
|x_i-x_j|\le \varepsilon.
$$

As $\varepsilon$ grows, edges can appear but never disappear. At a tiny scale, most points are isolated. Later, nearby points form clusters. Eventually, once the scale is large enough, the whole cloud becomes connected. The Vietoris–Rips complex goes one step further: whenever every pair in a set of vertices is joined, it fills in the corresponding simplex. Three pairwise edges therefore fill a triangle rather than leaving its boundary as a loop.

The zero-dimensional homology group $H_0$ records connected components. In persistent $H_0$, every point begins as its own component, and a component “dies” when an edge merges it into an older component. A barcode depicts these lives as horizontal intervals. Long bars represent separations that survive to a large scale; short bars represent points that merge quickly.

For primes $p_1<p_2<\cdots<p_n$, the relevant distances are built from the prime gaps

$$
g_k=p_{k+1}-p_k.
$$

The central fact is that no hidden, nonlocal edge can bypass one of these gaps before the gap itself closes.

## A gap is a real barrier

Imagine a consecutive gap between $x_k$ and $x_{k+1}$ that is wider than the current scale:

$$
x_{k+1}-x_k>\varepsilon.
$$

Every point on the left is at most $x_k$, and every point on the right is at least $x_{k+1}$. Thus any cross-gap distance is at least $x_{k+1}-x_k$, which exceeds $\varepsilon$. No edge can cross the gap. Since every path is made of edges, no path can cross it either.

This gives the **Large-Gap Separation Theorem**: if a consecutive gap exceeds $\varepsilon$, then all points to its left lie in different connected components from all points to its right.

The converse is equally direct. Suppose every consecutive gap from $x_i$ through $x_j$ is at most $\varepsilon$. Then the chain

$$
x_i\!\longleftrightarrow x_{i+1}\!\longleftrightarrow\cdots\longleftrightarrow x_j
$$

is present, so the endpoints are connected. Combining the two directions yields the **Exact Connectivity Theorem**:

> For $i\le j$, the points $x_i$ and $x_j$ are connected at scale $\varepsilon$ if and only if every consecutive gap $x_{k+1}-x_k$ with $i\le k<j$ is at most $\varepsilon$.

Equivalently, their exact connection threshold is

$$
\tau(i,j)=\max_{i\le k<j}(x_{k+1}-x_k),
$$

with $\tau(i,i)=0$. This is a complete answer. It transforms what looks like a graph problem involving as many as $\binom n2$ distances into a scan of only $n-1$ adjacent gaps.

For the first six primes,

$$
2,3,5,7,11,13,
$$

the consecutive gaps are

$$
1,2,2,4,2.
$$

The primes $2$ and $13$ first belong to the same component at scale $4$. Below $4$, the gap from $7$ to $11$ is an impassable cut. At scale $4$, the adjacent chain is complete. Nothing about the longer pairwise distances changes this threshold.

## Reading the entire zero-dimensional barcode

The theorem says more than how two selected endpoints connect. For a finite ordered cloud, the finite death times in persistent $H_0$ are precisely the consecutive gaps, counted with multiplicity. There is also one infinite bar, representing the final component that survives forever.

Why? Begin with $n$ isolated points. Each of the $n-1$ boundaries between consecutive points separates neighboring blocks until its gap value is reached. When that value arrives, that boundary ceases to separate the cloud and one merger occurs. Equal gaps may trigger several mergers at the same scale, but multiplicity preserves them. Consequently, sorting the gaps gives the full sequence of finite merger times.

This makes computation exceptionally efficient. Generate the ordered points, subtract neighbors, and sort the differences. The work after sorting the input is $O(n\log n)$ if one wants an ordered barcode, or $O(n)$ if one only wants connectivity thresholds along the line. A general all-pairs Rips computation would be needless overhead.

For primes, this means that zero-dimensional persistence is not a mysterious new invariant independent of classical arithmetic. It is an exact repackaging of prime-gap data. That repackaging can still be valuable: barcodes, survival curves, and persistence landscapes provide useful statistical summaries and connect arithmetic data with tools used in data analysis. But interpretation must remain honest. Any statistical feature of the $H_0$ barcode is a statistical feature of consecutive prime gaps.

## The Poisson comparison—and its limits

A common heuristic says that near a large number $X$, primes have average spacing about $\log X$. This invites comparison with a Poisson process of local intensity $1/\log X$, whose independent gaps have an exponential distribution with mean $\log X$. In normalized units, one compares

$$
\frac{p_{k+1}-p_k}{\log X}
$$

with an exponential random variable of mean $1$.

The topology theorem makes the comparison transparent: one is comparing normalized finite $H_0$ bar lengths with exponential samples. This is a meaningful empirical question in a local window such as $[X,X+H]$, provided the statistic, fitted parameters, and sampling regime are specified.

But literal equality is impossible. Apart from the first gap, gaps between odd primes are even integers. An exponential law is continuous and assigns probability zero to every individual value. Prime gaps also carry congruence constraints and correlations. Thus “the same barcode as a Poisson process” can only mean an asymptotic or approximate statement about selected statistics, never exact equality of distributions.

A careful study might compare empirical survival functions, quantiles, or a Kolmogorov–Smirnov distance after normalization. It should also separate exploratory fit from a theorem: the deterministic identification of bars with gaps is exact, while any Poisson resemblance is statistical and scale-dependent.

## Why the expected loops disappear

Could higher-dimensional persistence reveal something beyond gaps? A tempting picture imagines three primes whose edges form a loop, perhaps associating a special gap such as $2$ with a long-lived one-dimensional class. Ordinary Rips topology on a line does not allow this mechanism.

Here is the geometric obstruction. If $x_i\le x_j\le x_k$ and the long edge from $x_i$ to $x_k$ exists at scale $\varepsilon$, then

$$
x_j-x_i\le x_k-x_i\le\varepsilon
$$

and

$$
x_k-x_j\le x_k-x_i\le\varepsilon.
$$

So both shorter edges exist too. In the Rips complex, the three pairwise edges automatically fill a triangle. The supposed loop has no empty interior.

This is the **Ordered-Triangle Filling Theorem**: whenever an edge spans an intermediate point in an ordered real cloud, the two shorter edges are present, and the resulting three-clique is filled as a $2$-simplex.

The consequence for twin primes is decisive. A twin-prime pair contributes an edge at scale $2$; it does not create a hole beginning at scale $2$. Nor can an ordinary Rips barcode contain a one-dimensional bar that starts at $2$ and persists forever merely because infinitely many twin primes might exist. Short arithmetic distances and topological cycles are different objects.

More broadly, unit interval graphs—the proximity graphs arising from points on a line—have a nested geometry that strongly suggests every connected Rips component is contractible. The triangle theorem proves the local obstruction needed here; a full collapse argument would establish vanishing homology in every positive dimension.

## A better research program

The correction does not end the topological study of primes. It clarifies its next move.

First, zero-dimensional persistence offers a clean data-analysis pipeline. In local windows, one can compute gap barcodes, normalize by $\log X$, and compare empirical summaries across locations. Abrupt changes in long bars correspond exactly to unusually large prime gaps. Multiple short bars record dense local clusters. Because the invariant is interpretable, statistical conclusions can be translated directly back into arithmetic.

Second, nontrivial higher-dimensional topology requires a richer geometry. One could embed blocks of consecutive gaps into a delay-coordinate space,

$$
(g_k,g_{k+1},\ldots,g_{k+d-1})\in\mathbb R^d,
$$

so that cycles represent recurring patterns among several neighboring gaps. One could represent primes by residue-class feature vectors, use weighted complexes whose filling rules retain arithmetic distinctions, or construct witness complexes from divisibility and congruence relations. These models may support loops because they no longer force all data onto a single ordered axis.

The lesson is larger than prime numbers. Persistent topology is most illuminating when geometry and interpretation are matched. On the line, topology gives an exact, elegant theorem: components are separated by consecutive gaps, endpoint thresholds are maxima of those gaps, and the finite $H_0$ barcode is the gap multiset. The same geometry also warns us not to see holes where filled triangles must occur.

Prime numbers do have a landscape. Along the real line, its persistent signature is the rhythm of its intervals—the arithmetic beat of one prime after another. To hear harmonies rather than rhythm alone, we must place the primes in a space rich enough to carry them.
