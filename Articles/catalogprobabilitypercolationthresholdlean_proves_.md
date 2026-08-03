# One Set of Random Numbers, Every Percolation Threshold

## How a common-key coupling turns an evolving random network into a deterministic nested family

Imagine rain falling on a tiled landscape. At first only the lowest basins fill. As the water level rises, more tiles become wet, isolated puddles merge, and eventually a wet route may stretch from one side of the landscape to the other. Once such a route appears, raising the water cannot destroy it.

That simple picture contains the central idea of a threshold coupling for finite percolation. Instead of generating a fresh random configuration at every density, assign each object one permanent numerical key. A site or bond is declared open when its key lies below the chosen threshold. Turning the threshold upward then reveals objects in a fixed order. Every configuration is coupled to every other one, and the entire evolution is visible at once.

The construction is elementary, but it clarifies one of probability’s most useful principles: an increasing event should become no less likely when the density increases. Before probabilities enter, there is a stronger, pointwise fact. For each fixed assignment of keys, open sets are nested; therefore paths and crossings that exist at a lower threshold persist at every higher threshold.

## Sites, bonds, and keys

A finite graph consists of a set of vertices and a collection of edges joining selected pairs of vertices. Percolation comes in two standard forms.

In **site percolation**, vertices are either open or closed. An open site path from a vertex $u$ to a vertex $v$ is a graph path whose vertices are open. We say $u$ and $v$ are site-connected when such a path exists.

In **bond percolation**, edges are either open or closed. An open bond path is a graph path all of whose traversed edges are open. Its endpoints are bond-connected.

Now assign every vertex $x$ a real key $K(x)$. At threshold $p$, define the site state

$$
\eta_p(x)=\begin{cases}
1,&K(x)\le p,\\
0,&K(x)>p.
\end{cases}
$$

Likewise, give every edge $e$ a real key $L(e)$ and define

$$
\omega_p(e)=\begin{cases}
1,&L(e)\le p,\\
0,&L(e)>p.
\end{cases}
$$

No distributional assumption is required for the basic conclusions. The keys could be random, measured data, adversarial scores, or a hand-picked list. The argument uses only the order relation on real numbers.

The first result is the membership characterization: a vertex is open at threshold $p$ exactly when its key is at most $p$, and an edge is open exactly under the analogous inequality. This may look like a restatement of the definition, but it is the hinge on which every later result turns.

## The nesting theorem

Suppose $p\le q$. If a site $x$ is open at level $p$, then $K(x)\le p$. Transitivity gives $K(x)\le q$, so $x$ is also open at level $q$. Thus

$$
\{x:K(x)\le p\}\subseteq \{x:K(x)\le q\}.
$$

Exactly the same argument gives

$$
\{e:L(e)\le p\}\subseteq \{e:L(e)\le q\}.
$$

This is the **Threshold Nesting Theorem**: for one fixed key assignment, both site-open sets and bond-open sets are nested as the threshold increases.

Why is this more informative than merely saying that a higher density tends to open more objects? Because it compares two levels without resampling. Every object open at the lower level is literally the same object, with the same key, at the higher level. The configurations live on one common stage.

This coupling also reveals the exact moments at which the system can change. If the finite set of distinct keys is

$$
r_1<r_2<\cdots<r_m,
$$

then the configuration is constant between consecutive keys. New sites or bonds enter only when the threshold crosses one of the $r_i$. A continuum of threshold values therefore reduces to a finite sequence of combinatorial updates.

## Paths cannot disappear

The next theorem concerns connectivity. Let $G$ be any graph, let $u$ and $v$ be vertices, and let $p\le q$. If $u$ and $v$ are joined by an open site path at threshold $p$, every vertex on that witness path is open at $p$. Threshold nesting says each remains open at $q$. The very same path witnesses connectivity at $q$.

Hence the **Site Connectivity Persistence Theorem** states:

> Under a fixed assignment of vertex keys, site connectivity at threshold $p$ implies site connectivity at every threshold $q\ge p$.

For bonds, the witness consists of edges rather than vertices. Each edge on an open path at $p$ remains open at $q$. We obtain the **Bond Connectivity Persistence Theorem**:

> Under a fixed assignment of edge keys, bond connectivity at threshold $p$ implies bond connectivity at every threshold $q\ge p$.

These statements apply to arbitrary finite graphs. They do not rely on planarity, regular lattices, independence, or probabilities. Their proof is constructive in a particularly direct sense: the path at the low threshold is reused unchanged.

This is a small but powerful pattern. Many properties of configurations are **increasing**: once true, they remain true when additional sites or bonds are opened. Connectivity is one example. Others include the existence of a cluster of at least a given size, a route touching a designated boundary, or several disjoint routes. A common-key coupling turns the monotonicity of any such event into a pointwise statement.

## Crossing a square grid

Consider an $n\times n$ grid with $n>0$. A horizontal site crossing is an open path that starts on the left boundary and reaches the right boundary. Assign one key to each grid site and open sites whose keys do not exceed the threshold.

The **Horizontal Crossing Persistence Theorem** says that if a horizontal crossing exists at $p$ and $p\le q$, then a horizontal crossing exists at $q$. The proof again preserves a witness: all sites of the original left-to-right path stay open.

This result captures the rising-water intuition exactly. As the threshold grows, a crossing indicator can switch from false to true, but never back from true to false. For a fixed key assignment, the indicator is a nondecreasing step function of $p$.

If keys are independent and uniformly distributed on $[0,1]$, then for each fixed $p\in[0,1]$ every site is open with probability $p$. Indeed,

$$
\Pr(K(x)\le p)=p.
$$

The common-key construction therefore realizes all Bernoulli site densities on one probability space. Since the crossing indicator is pointwise nondecreasing, averaging over key assignments shows that the crossing probability is nondecreasing in $p$. This probabilistic consequence is an application of the deterministic theorem; the deterministic core itself needs no probability law.

The same viewpoint makes simulation more efficient and more interpretable. A naive experiment might generate independent grids separately at $p=0.3$, $p=0.4$, and $p=0.5$. Such snapshots can misleadingly show a crossing at the lower value and no crossing at the higher one, simply because unrelated randomness was used. Common keys remove that noise: each trial produces a genuinely nested movie.

## Two models, one principle—not one sample space

Site and bond percolation are related, but they are not identical. Vertex keys are indexed by vertices; edge keys are indexed by unordered pairs that form graph edges. A theorem can discuss both models simultaneously without pretending that a vertex configuration is an edge configuration.

The **Joint Persistence Theorem** makes precisely this distinction. Take a site graph with vertex keys and a possibly different bond graph with edge keys. Suppose selected site endpoints are connected at threshold $p$, and selected bond endpoints are also connected at $p$. For every $q\ge p$, both connections persist. The site conclusion follows from the site keys; the bond conclusion follows independently from the edge keys.

This packaging matters conceptually. Similar formulas at a tiny local scale do not identify entire percolation models. The right lesson is structural: both models obey the same order-theoretic coupling principle, while retaining their distinct objects and events.

## Why call this a coupling?

In probability, a coupling places several random objects on one shared probability space. Here a single key vector creates the complete family $(\eta_p)_{p\in\mathbb R}$, or the family $(\omega_p)_{p\in\mathbb R}$. When the keys are uniform on $[0,1]$, each snapshot has the correct Bernoulli marginal law, while different threshold levels are maximally coordinated by inclusion.

This coordination supports both theory and computation. It gives immediate monotonicity inequalities. It reduces variance when comparing nearby parameter values, because the same underlying randomness is reused. It also suggests an event-driven algorithm: sort keys, activate objects one at a time, and update connectivity with a disjoint-set data structure. Rather than solving a new path problem at every threshold, one tracks mergers as the system grows.

There are practical analogies far beyond porous materials. In a communication network, a key can represent the signal level needed to activate a relay. In reliability analysis, it can represent a component’s tolerance. In epidemiology, it can encode an individual activation threshold in a simplified contact model. In security and cryptography, threshold-controlled access structures and randomized network tests often need guarantees that raising an authorization or inclusion level cannot revoke a connection already present. The mathematics here isolates exactly that monotone backbone.

Care is needed with interpretation. These finite results do not by themselves determine an infinite-lattice critical probability. They prove nesting and persistence for fixed finite configurations. To reach infinite-volume percolation one needs additional machinery: probability measures on infinite configurations, limiting arguments, planar duality where appropriate, and sharp-threshold estimates.

## The complete chain of results

The argument can be summarized in five steps.

1. **Threshold membership.** A site or bond is open exactly when its key is no greater than the threshold.
2. **Pointwise nesting.** If $p\le q$, every object open at $p$ remains open at $q$.
3. **Site connectivity persistence.** Any open site path at $p$ remains an open site path at $q$.
4. **Crossing persistence.** In every positive finite square grid, a horizontal site crossing at $p$ remains at $q$.
5. **Bond and joint persistence.** Bond paths obey the same principle, and site and bond conclusions can be asserted together while keeping their sample spaces separate.

Each step is finite and deterministic. Randomness enters only when one chooses to sample keys.

The deepest insight is therefore not a complicated formula. It is a way of organizing randomness. Give each object one enduring key, and an apparently changing random world becomes a single ordered landscape. Raise the threshold, and the landscape reveals itself without forgetting its past. Open paths may appear and merge, but they never vanish. That one-way evolution is the foundation on which much of finite percolation theory is built.
