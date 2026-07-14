# Climbing the Suspension Tower: How a Simple Doubling Trick Forces the Shape of Spheres

## A pancake that refuses to lie flat

Take a rubber ball, warm it up, and try to press it flat onto a table without tearing it or folding it. You cannot. Somewhere, two points that started on exact opposite sides of the ball are forced to land on top of each other. This stubbornness has a name — the **Borsuk–Ulam theorem** — and one of its most quoted consequences is the promise that, at any instant, there are two antipodal points on the Earth's surface with exactly the same temperature and the same barometric pressure.

The reason a ball cannot be flattened is not about rubber; it is about *symmetry*. A sphere carries a perfect twofold symmetry: every point $x$ has an opposite point $-x$, its **antipode**. A plane, a line, or a point of lower dimension simply does not have enough room to host that symmetry faithfully. When you try to squash a high-dimensional sphere down into a low-dimensional one, the symmetry gets in the way and something must collapse.

This article is about turning that intuition into a machine you can crank. We build a tower — call it the **suspension tower** — whose rungs are spheres of every dimension, wired together by a single doubling operation. Then we prove three things at once: that the tower is *functorial* (it respects composition, so it behaves like a well-oiled mechanism rather than an ad-hoc trick), that it *lifts* maps upward without ever losing them, and that at the bottom it *forbids* maps downward in exactly the sharpest possible way. The payoff is a clean, self-contained proof that the "symmetric complexity" of the $n$-dimensional sphere is exactly $n$ — no more, no less — for the first three floors of the tower, together with a general mechanism that spreads a single impossibility across an entire cone of dimensions.

## Spheres you can hold in your hand

To reason about spheres precisely, we replace the smooth rubber ball with a crisp combinatorial skeleton: the **cross-polytope**. In two dimensions the cross-polytope is a diamond (a square balanced on its corner); in three dimensions it is the octahedron; in general dimension $n+1$ it is the convex hull of the $2(n+1)$ points
$$\pm e_0,\ \pm e_1,\ \dots,\ \pm e_n,$$
the standard coordinate directions and their negatives. Its *boundary surface* is a triangulated sphere, and we call it $S^n$. The octahedron's surface, for instance, is a triangulated $2$-sphere $S^2$: eight triangular faces, six vertices, twelve edges.

The beauty of this model is how transparently it carries the antipodal symmetry. The vertices come in opposite pairs $+e_i$ and $-e_i$. The **antipodal map** simply swaps every vertex with its partner, $v \mapsto -v$. And the combinatorial rule for which vertices form a face is elegant: a set of vertices spans a face precisely when it never contains both a vertex and its opposite. You are allowed at most one representative from each antipodal pair. That single rule encodes the entire geometry.

An **antipodal map between spheres** — the central character of our story — is a map $F : S^m \to S^n$ of these skeletons that (i) sends vertices to vertices and faces to faces, and (ii) respects the symmetry: it sends antipodes to antipodes, $F(-v) = -F(v)$. These are the "honest" maps, the ones that cannot cheat by ignoring the twofold symmetry. The question "how complicated is a sphere?" becomes the sharply combinatorial question: *between which pairs of spheres does an honest map exist?*

We package the answer in one number. The **coindex** of a space $K$ is the largest dimension $n$ for which an antipodal map $S^n \to K$ exists — the biggest symmetric sphere you can fit inside $K$ without breaking the symmetry. For a sphere itself, the Borsuk–Ulam theorem is the statement $\operatorname{coind}(S^n) = n$: you can fit $S^n$ into itself (obviously), but you can never squeeze it into any lower $S^{n-1}$.

## The doubling trick: suspension

Now for the engine. There is a canonical way to build the next sphere up from the one you have, called **suspension**. Geometrically, take $S^n$, add two new "pole" points above and below it, and cone outward to both; the result is $S^{n+1}$. In our cross-polytope skeleton this could not be simpler: to pass from $S^n$ to $S^{n+1}$ you introduce one new antipodal pair of vertices — a north pole and a south pole — and glue them on. The equator of $S^{n+1}$ is a perfect copy of the old $S^n$.

Suspension acts not just on spheres but on the honest maps between them. Given $F : S^m \to S^n$, its **suspension** $\Sigma F : S^{m+1} \to S^{n+1}$ does exactly what $F$ did on the equator and sends the new north pole to the new north pole, the new south pole to the new south pole. It respects the symmetry automatically. Iterating this $k$ times gives the **suspension tower**:
$$F \ \rightsquigarrow\ \Sigma F \ \rightsquigarrow\ \Sigma^2 F \ \rightsquigarrow\ \cdots\ \rightsquigarrow\ \Sigma^k F : S^{m+k} \to S^{n+k}.$$
Each application lifts a map one floor up on both the domain and the codomain.

Two facts make this tower trustworthy rather than merely suggestive.

**Suspension is a functor.** It respects the two most basic operations you can do with maps. First, suspending the identity map gives the identity map one floor up: $\Sigma(\mathrm{id}_{S^n}) = \mathrm{id}_{S^{n+1}}$. Second, suspending a composite is the composite of the suspensions: $\Sigma(G \circ F) = \Sigma G \circ \Sigma F$. In plain terms, the tower does not scramble the wiring — if you first map, then map again, and then climb the tower, you get the same thing as climbing first and mapping afterward. By induction these two laws lift to the whole $k$-fold tower: $\Sigma^k(\mathrm{id}) = \mathrm{id}$ and $\Sigma^k(G \circ F) = \Sigma^k G \circ \Sigma^k F$. This is what earns the tower the right to be called a genuine mathematical object and not a coincidence.

Underlying all of this is a small but load-bearing observation: **an honest map is completely determined by what it does to vertices.** The symmetry and face-preservation conditions are properties, not extra data — once you know where the vertices go, the map is pinned down. This is what lets us verify the functor laws by a finite check on vertices rather than an infinite argument about the whole sphere.

## Going up is free; the tower never drops a map

The first structural theorem says the tower is a perfect elevator in the upward direction.

> **Lifting Theorem.** If there is an honest map $S^m \to S^n$, then for every height $k$ there is an honest map $S^{m+k} \to S^{n+k}$.

The proof is the tower itself: apply suspension $k$ times. Nothing is ever lost on the way up. In coindex language, whatever symmetric complexity a sphere already contains is preserved as you climb, floor after floor.

Two easy but useful corollaries fall out. Whenever $m \le n$ there is a "diagonal" honest map $S^m \to S^n$ to begin with (just place the smaller cross-polytope inside the larger one), and the Lifting Theorem then hands you one $S^{m+k} \to S^{n+k}$ at *every* height — the diagonal lower bound is stable all the way up the tower. And starting from the humblest map of all, the equatorial inclusion $S^0 \hookrightarrow S^n$, repeated suspension produces an honest map $S^k \to S^{n+k}$ for every $n$ and $k$. The bottom of the tower seeds the entire structure.

## Going down is forbidden — and one impossibility becomes many

The deep direction is the impossibility, and here the tower reveals its second talent: it can *propagate* a single "no" into an entire cone of "no"s. The mechanism is the humble **equatorial inclusion** $\iota : S^n \hookrightarrow S^{n+1}$, which realizes $S^n$ as the equator of the next sphere up.

> **Descent principles.**
> *Codomain descent:* if there is no honest map $S^m \to S^{n+1}$, then there is none $S^m \to S^n$ either — because any such map, followed by the equatorial inclusion, would produce the forbidden map to $S^{n+1}$.
> *Domain ascent:* if there is no honest map $S^m \to S^n$, then there is none $S^{m+1} \to S^n$ — because any such map, preceded by the equatorial inclusion of the domain, would produce the forbidden map from $S^m$.

Each principle is a one-line composition argument, yet together they are startlingly powerful: a single non-existence fact spawns a whole two-dimensional cone of non-existence facts. Feed them the finite base cases of Borsuk–Ulam and watch them spread.

The finite base cases are honest, hands-on impossibilities, small enough to be checked by exhaustive combinatorial search over the finitely many candidate vertex maps:
- there is no honest map $S^1 \to S^0$ (a circle cannot be squashed symmetrically onto two points);
- there is no honest map $S^2 \to S^1$ (a sphere cannot be squashed symmetrically onto a circle);
- there is no honest map $S^3 \to S^2$.

Combining each with domain ascent yields three infinite families in one stroke:

> **No maps to low spheres.**
> There is no honest map $S^{m+1} \to S^0$ for any $m$ — *nothing* above a point can hold the symmetry of even a circle.
> There is no honest map $S^{m+2} \to S^1$ for any $m$.
> There is no honest map $S^{m+3} \to S^2$ for any $m$.

A single checked impossibility at each level, amplified by the descent principles, forbids maps from an entire tower of dimensions above.

## The sharp diagonal: exactly one unit per floor

Putting the two directions together gives the crown result — the **excess spectrum** at the base of the tower. Combine the diagonal lower bound (there *is* a self-map $S^n \to S^n$) with the sharp non-existence (there is *no* map $S^{n+1} \to S^n$) for the bottom three floors:

> **Sharp Diagonal Theorem.** For $n \in \{0, 1, 2\}$, there is an honest self-map $S^n \to S^n$ but no honest map $S^{n+1} \to S^n$. Hence
> $$\operatorname{coind}(S^n) = n \quad\text{exactly, for } n = 0, 1, 2.$$

Read this as a statement about the tower's *increments*. Climbing one floor of the suspension tower raises the coindex by **precisely one** — never zero, never two — at each of the bottom three rungs. The suspension does not waste dimensions, and it does not manufacture free ones. It is a perfectly calibrated staircase, each step exactly one unit high. This is the combinatorial heartbeat of Borsuk–Ulam made completely explicit and verifiable.

## Why this matters beyond spheres

The temperature-and-pressure parlor trick is the friendly face of a principle that quietly underwrites a surprising range of mathematics. The same symmetry obstruction is the engine behind the **Ham Sandwich theorem** (any three globs of matter in space can be simultaneously bisected by a single flat cut), behind **fair-division** results (a necklace with several kinds of beads can be split fairly among thieves with few cuts), and behind lower bounds in **combinatorics** such as the chromatic number of Kneser graphs, where the coindex of an associated space directly controls how many colors you truly need.

What the suspension tower contributes is *modularity*. Instead of re-proving each impossibility from scratch, you establish a handful of small, finite base cases and then let two composition principles — descent and lifting — carry them across infinitely many dimensions, with functoriality guaranteeing the whole apparatus is coherent. It is the difference between forging each link of a chain by hand and building a machine that stamps them out identically, forever. The three floors we pin down exactly are a proof of concept for a staircase that, rung by rung, climbs as high as you care to go.
