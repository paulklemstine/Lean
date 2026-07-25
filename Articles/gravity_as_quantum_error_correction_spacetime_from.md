# When Error Correction Draws a Geometry

## A careful finite model of distance, capacity, and emergent space

Imagine receiving a message whose pieces have been scattered around the boundary of a strange world. Some pieces are erased, yet the message survives. The deeper the message was hidden, the more boundary damage it can withstand. This is the intuition behind one of the most provocative ideas in modern theoretical physics: geometry may encode the same pattern of redundancy as a quantum error-correcting code.

That slogan is powerful, but slogans can outrun mathematics. A code has qubits, logical information, parity checks, and an integer called its distance. A spacetime has locations, paths, causal structure, curvature, and geometric lengths. Calling both notions “distance” does not make them identical. A precise bridge needs a dictionary, and that dictionary must say exactly which graph represents geometry and which pair of locations has separation equal to the code distance.

Once this missing assumption is made explicit, a clean picture emerges. The quantum Singleton bound becomes a geometric capacity inequality. Equality appears exactly when the code saturates that bound. The smallest perfect quantum code admits a simple four-vertex radial model whose endpoint separation is three. Yet the same example also supplies a decisive warning: its standard Tanner graph has nine vertices, so it cannot literally be that four-vertex chain. The mathematics therefore supports a disciplined version of “spacetime from codes”—one based on preserved metric information, not an unqualified identification of diagrams.

## The code side of the dictionary

A quantum code with parameters $[[n,k,d]]$ stores $k$ logical qubits in $n$ physical qubits. Its distance $d$ measures protection: in the standard error-correction interpretation, larger $d$ means that more local damage is required to enact an undetectable logical error.

For the stabilizer codes considered here, the relevant quantum Singleton bound is

$$
2d+k\le n+2.
$$

This is not the classical inequality $d\le n-k+1$. The factor of two is essential. Rearranging the quantum bound gives

$$
k\le n-2d+2.
$$

The expression $n-2d$ is a defect or excess budget: after paying twice for protective distance, whatever boundary capacity remains limits the logical information. This already sounds geometric, but it is still a statement about code parameters.

To turn it into geometry, take an undirected graph $G$ with distinguished vertices $s$ and $t$. Let $\operatorname{dist}_G(s,t)$ be the minimum number of edges in a walk from $s$ to $t$. We say that this graph is an **exact metric realization** of the code when

$$
\operatorname{dist}_G(s,t)=d.
$$

This one equation is the crucial bridge. It is an assumption about what the graph represents, not something implied by the three numbers $n$, $k$, and $d$ alone.

## The geometric Singleton principle

With the dictionary in place, the first main result is immediate but conceptually important.

**Geometric Singleton Principle.** If an $[[n,k,d]]$ stabilizer code obeys the quantum Singleton bound and a graph $G$ exactly realizes its distance between $s$ and $t$, then

$$
2\operatorname{dist}_G(s,t)+k\le n+2.
$$

The proof is substitution: replace $d$ by $\operatorname{dist}_G(s,t)$ in $2d+k\le n+2$. Its simplicity is a virtue. It exposes precisely where physics enters: not in the algebraic inequality, but in the decision to interpret code distance as a graph geodesic.

Equality requires more. If the code is Singleton-saturated,

$$
2d+k=n+2,
$$

then its exact metric realization satisfies

$$
2\operatorname{dist}_G(s,t)+k=n+2.
$$

Conversely, because the realization is exact, this geometric identity implies Singleton saturation. Thus, relative to a fixed exact realization, the equality of geometric capacity and boundary budget is equivalent to saturation:

$$
2\operatorname{dist}_G(s,t)+k=n+2
\quad\Longleftrightarrow\quad
2d+k=n+2.
$$

This distinction matters when comparing code inequalities with entropy-area formulas. A bound is not automatically an equality. Nor does a global equality in $n$, $k$, and $d$ determine the entropy of every boundary region. It supplies a global capacity identity—nothing less, but also nothing more.

## A four-station radial world

The smallest perfect quantum code has parameters $[[5,1,3]]$. It stores one logical qubit in five physical qubits and has distance three. Substituting these values gives

$$
2\cdot3+1=7=5+2,
$$

so the code saturates the quantum Singleton bound.

Now build the simplest possible radial graph with endpoint distance three: four vertices labeled $0,1,2,3$, with edges joining consecutive labels. Visually,

$$
0\;—\;1\;—\;2\;—\;3.
$$

There is an obvious three-edge walk from $0$ to $3$, so the endpoint distance is at most three. To see that no shorter route exists, observe a general fact about path graphs. Along any walk beginning at vertex $u$ and ending at vertex $v$, each edge changes the label by only one. Therefore a walk of length $L$ can increase the label by at most $L$:

$$
v\le u+L.
$$

This follows step by step: it is true for a walk of length zero, and appending one edge can increase the endpoint by at most one. Taking $u=0$ and $v=3$ forces $L\ge3$. Together with the explicit three-edge route, this proves

$$
\operatorname{dist}(0,3)=3.
$$

The chain is therefore an exact metric realization of the $[[5,1,3]]$ code distance. The geometric capacity identity becomes

$$
2\operatorname{dist}(0,3)+1=2\cdot3+1=7=5+2.
$$

This is a complete finite example in which code distance, graph-geodesic length, and a saturated quantum Singleton budget agree.

## The diagram that does not fit

The same example tests a much stronger claim: could the standard Tanner graph of the five-qubit code literally be the four-vertex radial chain?

A Tanner presentation is bipartite. For this code it contains five variable vertices, one for each physical qubit, and four check vertices, one for each independent stabilizer constraint. Its vertex set therefore has

$$
5+4=9
$$

members. The radial chain has four. A graph isomorphism must begin with a bijection between vertex sets, but no bijection exists between a nine-element set and a four-element set. Therefore no choice of Tanner incidences can make that nine-vertex presentation isomorphic to the four-vertex chain.

This cardinality obstruction is basic, yet it marks a profound conceptual boundary. The chain realizes one metric datum: the distance three between two chosen locations. It does not reproduce the entire incidence structure of the code. In particular, it is not a Penrose diagram, and an undirected graph by itself supplies neither time orientation nor Lorentzian signature. Metric realization and literal identity are different claims.

That difference is familiar in other sciences. A subway map can preserve which stations are adjacent while distorting geographic distance. A topographic profile can preserve elevation along one route without reproducing an entire landscape. A circuit diagram can preserve electrical connectivity while ignoring physical placement. Likewise, a code-derived geometric model must state which structure it preserves: distances, cuts, recoverable regions, causal order, or something else.

## Defect as a capacity ledger

The geometric version of the Singleton bound yields another useful result. Suppose an exact metric realization has boundary size

$$
n=2\operatorname{dist}_G(s,t)+\delta,
$$

where $\delta$ is a nonnegative geometric defect. Then

$$
k\le\delta+2.
$$

Indeed, insert the expression for $n$ into

$$
2\operatorname{dist}_G(s,t)+k\le n+2
$$

and cancel the common distance term. The result says that bounded excess over twice the geodesic length forces bounded logical capacity.

This has a sharp asymptotic message. Consider larger and larger codes and exact metric realizations. If $\delta$ stays bounded, then $k$ stays bounded as well, so the logical rate $k/n$ tends to zero as $n$ grows. Conversely, a family with positive limiting logical rate cannot keep $n-2\operatorname{dist}_G(s,t)$ microscopic; the defect must grow proportionally to system size. In a spatial network, that extensive excess may eventually be related to branching, multiple routes, or additional geometric volume—but those conclusions require assumptions such as locality, bounded degree, and planarity.

## What this says about gravity

The appealing phrase “gravity is quantum error correction” contains several possible mathematical statements. The present results validate one of them conditionally: if code distance is exactly represented by a selected graph geodesic, then the quantum Singleton bound becomes a geometric capacity bound. If the code saturates Singleton, the bound becomes an exact identity, and that identity is equivalent to saturation relative to the same metric dictionary.

But three stronger leaps remain unsupported by these ingredients alone.

First, global parameters do not determine regional entropy. Two codes may share $n$, $k$, and $d$ while arranging logical access and entanglement differently across subsets of the boundary. An entropy formula needs regional information.

Second, a Tanner graph is not automatically a spacetime. The five-qubit example demonstrates the problem numerically: the natural Tanner presentation and the minimal radial realization do not even have the same number of vertices.

Third, undirected incidence and shortest-path distance do not determine causality. A Lorentzian bulk requires orientation, causal order, metric signature, and a meaningful continuum limit. Correctable-region inclusions may offer additional directed data, but that is a further construction.

The best conclusion is therefore more precise—and more useful—than the slogan. Quantum codes provide capacity constraints. Exact metric dictionaries can transport those constraints into geometry. Saturation identifies when a geometric inequality becomes an equality. Small models reveal both the promise of this bridge and the extra structure still needed for spacetime.

## A roadmap from metaphor to mechanism

The next step is not to declare every code a universe. It is to discover rigidity principles. Suppose a family of bounded-degree tensor networks uses the same local building block, supports complementary recovery, realizes code distance by shortest paths, and saturates the Singleton bound at every scale. Do these combined conditions force a negatively curved limiting metric? Singleton saturation alone cannot: it is only a global budget. Locality and recovery may supply the missing geometry.

A second test is entropic. Construct two Singleton-saturated stabilizer encodings with identical $[[n,k,d]]$ parameters but different entropy profiles for some boundary regions. Such a pair would cleanly demonstrate that global distance data cannot by itself imply a regional area law.

A third test concerns causality. One may ask whether a Tanner graph augmented by logical-operator supports and a nested family of correctable boundary regions can determine a causal order, perhaps up to reversal. This would replace an impossible literal identification by a carefully specified reconstruction.

The lesson of the four-vertex chain is not that spacetime has been reduced to four dots. It is that the grand question can be split into exact, falsifiable pieces. Distance can be transported. Capacity can be bounded. Saturation can be characterized. Literal graph identity can fail. Between those statements lies a research program: identify the additional local, entropic, and causal data that turn the mathematics of protection into the geometry of a world.
