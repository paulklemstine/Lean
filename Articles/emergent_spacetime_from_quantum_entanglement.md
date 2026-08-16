# The Shape of Entanglement

### How a universe of space can be knitted out of quantum correlations — and why some quantum states can never be woven into a space at all

---

## A bridge made of nothing

In 1935, Albert Einstein wrote two papers that would take eighty years to be introduced to one another.

The first, with Nathan Rosen, described a strange feature of general relativity: two distant regions of spacetime can be joined by a tunnel, a "bridge," through which the geometry passes without ever crossing the space in between. We now call these Einstein–Rosen bridges, or wormholes.

The second, with Boris Podolsky and Rosen again, described a strange feature of quantum mechanics: two particles can be prepared in a joint state so tightly correlated that measuring one instantly fixes what you will find when you measure the other, however far apart they are. We call this entanglement, and the paper's initials — EPR — are its shorthand.

For most of a century these were two separate oddities: one about geometry, one about information. Then Juan Maldacena and Leonard Susskind proposed something audacious. *They are the same oddity.* Entangled particles, they suggested, **are** microscopic wormholes: **ER = EPR**.

That is a beautiful sentence. But what would it mean to actually *prove* it?

This article describes a small, complete, fully worked-out mathematical world in which the question has a sharp answer — and in which the answer comes with a surprise attached. In this world, geometry really is built out of entanglement: the metric can be read off, edge by edge, from a table of quantum correlations. Two particles are entangled if and only if a bridge joins them. But we also find a hard wall. There are perfectly consistent-looking patterns of entanglement — patterns that satisfy every quantum rule anyone had checked — that **no geometry can ever produce**. Not a curved one, not a flat one, not one with hidden extra regions. None.

Space, it turns out, is picky about what it will be made of.

---

## The toy universe: a graph and a knife

To make the question precise you need a stripped-down model of spacetime, and the one that has proven most fruitful is disarmingly simple.

A **bulk geometry** is a finite weighted graph. Its vertices are "cells" of space. Between any two cells $u$ and $v$ there is a number $w(u,v) \ge 0$, symmetric in its arguments, which you should picture as the *area* of the wall separating those two cells. Big weight means a thick, expensive wall; zero weight means the cells are not directly joined at all.

Some cells are designated as **boundary** cells. These are where the quantum system lives — in the string-theory picture they are the edge of the universe, where a quantum field theory encodes everything that happens inside. The remaining cells are **hidden**: they are pure interior, the deep bulk.

Now for the knife. Given any way $f$ of splitting the cells into two groups — call it a *region* — the **area** it costs is the total weight of all the walls you had to cut:

$$\mathrm{area}(f) \;=\; \tfrac{1}{2}\sum_{u,v}\,[\,f(u) \neq f(v)\,]\; w(u,v).$$

The bracket is $1$ when the two cells land on opposite sides and $0$ otherwise; the factor of $\tfrac12$ is because each wall gets counted twice.

Finally, the definition that makes the whole subject go. Take a set $A$ of boundary cells. Among all the ways of cutting the bulk that agree with $A$ *on the boundary* — you must take exactly the cells of $A$ and none of the other boundary cells, but you may do whatever you like with the hidden cells — find the cheapest. Its area is the **entanglement entropy** of $A$:

$$S(A) \;=\; \min\{\,\mathrm{area}(f) : f \text{ agrees with } A \text{ on the boundary}\,\}.$$

This is the Ryu–Takayanagi prescription, in miniature. In the full theory it says that the entropy of a region of a quantum field equals the area of the smallest surface in the bulk that hangs from that region. Here it is a minimum cut in a finite graph — a quantity a computer can find, and about which one can prove theorems.

Two immediate sanity checks fall out. The empty region costs nothing: $S(\emptyset) = 0$. And the whole boundary also costs nothing — take *everything* to be inside, cut no walls at all — so $S(\text{everything}) = 0$. That second one is exactly the statement that the global quantum state is **pure**: the universe as a whole has no entropy, only its parts do. A slightly cleverer version of the same argument shows **complementarity**: a region and its complement always have the same entropy, $S(A) = S(A^{c})$, because flipping which side of a cut is "inside" doesn't change what you cut.

---

## Cutting arithmetic

The engine of everything that follows is a single, almost embarrassingly elementary observation.

Suppose you have a family of regions $f_1,\dots,f_k$ and you build from them a new family $g_1,\dots,g_m$ by some fixed Boolean recipe — each $g_j$ is computed cell by cell from whether that cell lies in each $f_i$. Ask: for a given pair of cells $(u,v)$, how many of the new regions *separate* them, versus how many of the old ones did?

If the recipe never increases that count — for every pair of cells, the new family separates them at most as often as the old family did — then summing against the wall areas gives, immediately,

$$\sum_{j=1}^{m}\mathrm{area}(g_j) \;\le\; \sum_{i=1}^{k}\mathrm{area}(f_i).$$

That is the whole trick. A recipe with this property is called a **contraction**: viewed as a map from $\{0,1\}^k$ to $\{0,1\}^m$, it never increases Hamming distance. And the punchline is that **every contraction is an entropy inequality**. If the boundary traces work out — if applying the recipe to the boundary patterns of $A_1,\dots,A_k$ gives you exactly $B_1,\dots,B_m$ — then

$$\sum_j S(B_j) \;\le\; \sum_i S(A_i).$$

The proof is three lines. Take the minimal cut for each $A_i$; apply the recipe to get candidate cuts for each $B_j$; those candidates are admissible, so each $S(B_j)$ is at most the area of its candidate; and the contraction property says the total candidate area doesn't exceed the total minimal area, which is $\sum_i S(A_i)$. Done.

So the search for holographic entropy inequalities becomes the search for Hamming-nonexpansive Boolean maps. That is a finite search. A computer can do it.

---

## What the recipes say

**Recipe one: intersection and union.** Send the pair $(a_1, a_2)$ to $(a_1 \wedge a_2,\; a_1 \vee a_2)$. Checking the sixteen cases confirms it is a contraction, and it yields at once two of the pillars of quantum information theory. It gives **subadditivity**, $S(A \cup B) \le S(A) + S(B)$: two regions together are never more disordered than the sum of their parts. And it gives **strong subadditivity**,

$$S(A \cup B \cup C) + S(B) \;\le\; S(A \cup B) + S(B \cup C),$$

which is the hardest-won inequality in quantum information theory — Lieb and Ruskai's celebrated 1973 theorem, obtained here in a couple of lines because in the geometric world it is nothing but the submodularity of a min-cut.

**Recipe two: the minority rule.** This one is subtler and it is where geometry starts to say things that quantum mechanics alone does not. Given three regions $a_1,a_2,a_3$, form the three "minority" regions — the cells in exactly two of the three, e.g. $a_1 \wedge a_2 \wedge \lnot a_3$ — together with the union $a_1 \vee a_2 \vee a_3$. Four outputs from three inputs, and yet it is still a contraction: a fact verified across all sixty-four Boolean configurations.

Four outputs from three inputs is remarkable, and it buys you the signature inequality of holography, **monogamy of mutual information**:

$$S(A) + S(B) + S(C) + S(A\cup B\cup C) \;\le\; S(A\cup B) + S(B\cup C) + S(A\cup C).$$

Written in terms of the mutual information $I(A:B) = S(A) + S(B) - S(A\cup B)$, which measures how much $A$ and $B$ know about each other, this says

$$I(A : B\cup C) \;\ge\; I(A:B) + I(A:C).$$

Entanglement, in a geometric world, is *monogamous*: whatever correlation $A$ has with $B$ and with $C$ separately, it has at least that much with the two of them together. There is no way to spread correlation democratically among three parties.

And here is the detail that shows this is genuinely delicate. If you replace the minority regions by the naive pairwise intersections $a_i \wedge a_j$, the recipe **fails** to be a contraction — take all three $a$'s true and all three $b$'s false and count. The extra "$\lnot a_k$" in each minority region is not decoration. It is load-bearing.

---

## Reading the metric off the correlations

Now to the promised reconstruction. Consider a geometry with **no hidden cells**: every cell is a boundary cell, so there is nothing to minimise over and the entropy of a region is just the area of its own boundary wall. In that setting one can compute exactly what the mutual information of two individual cells is, and the answer is startlingly clean:

$$\boxed{\,w(u,v) \;=\; \tfrac12\, I(u:v)\,}$$

**Every single edge weight of the geometry — the entire metric — is one half of the mutual information of the two cells it joins.** Nothing is estimated, nothing is asymptotic. Given the table of pairwise correlations, you write down the geometry.

Three corollaries follow, and together they are as close to "spacetime from entanglement" as a theorem can get.

*Rigidity.* If two hidden-cell-free geometries produce the same pairwise mutual informations, they have the same edge weights, hence the same areas for every region and the same entropy for every boundary set. The correlation table determines everything.

*Connectivity.* Define a **bridge** between two cells to be a chain of positive-area steps joining them — the discrete version of a wormhole through the bulk. Two such geometries with the same correlations have literally the same bridges. The topology of the emergent space is fixed by the entanglement too, not just the metric.

*Sharpness.* And it is exactly sharp: the self-loop weights $w(u,u)$ are pure gauge. A cell is never separated from itself, so self-loops never contribute to any cut area and never carry a path anywhere new. Changing them all leaves every entropy and every bridge untouched. So the correlation data determines precisely the off-diagonal geometry — no more, and no less.

---

## No bridge, no entanglement — and back again

The two halves of ER = EPR now come into view.

**No bridge means no entanglement.** Suppose the cells split into two families with no positive-weight wall between them — a geometric disconnection. Then for a region $A$ on one side and $B$ on the other, the entropies are *exactly* additive, $S(A\cup B) = S(A) + S(B)$, so $I(A:B) = 0$. Physically: what the geometry has torn apart, the quantum state cannot correlate.

**Positive entanglement forces a bridge.** Contrapositively, if $I(A:B) > 0$ then there must exist a cell of $A$ and a cell of $B$ joined by a chain of positive-area steps. Correlation *compels* a tunnel. That is the geometric half of ER = EPR, and it is a theorem in this model, not an analogy.

Better still, in the hidden-cell-free case the two networks are not merely correlated but *identical*: two cells are joined by a chain of bridges precisely when they are joined by a chain of directly entangled pairs. The wormhole graph and the entanglement graph are the same graph.

---

## A qubit is a wormhole

Time to get concrete, with the smallest possible example: two qubits in a real pure state, described by a $2\times 2$ coefficient matrix $\psi$. Such a state is a **product state** — completely unentangled — exactly when $\det\psi = 0$. Its **concurrence**, the standard measure of two-qubit entanglement, is

$$C(\psi) \;=\; 2\,\bigl|\det\psi\bigr|,$$

which is zero for product states and $1$ for a maximally entangled Bell pair.

To this state assign the simplest possible geometry: two cells joined by one throat, whose area is set equal to the concurrence. Then everything lines up:

- The throat is a genuine bridge — there is a positive-area path from one cell to the other — **if and only if** the state is entangled. That is ER = EPR, proved.
- The mutual information across the throat is exactly twice its area: $I = 2C(\psi)$.
- The *linear entropy* $2(1 - \mathrm{Tr}\,\rho^2)$ of either qubit's reduced state — the standard measure of how mixed a piece of a pure state is — equals $C(\psi)^2$ exactly. So the throat area is the square root of the linear entropy, and $I^2 = 4 \cdot (\text{linear entropy})$.

A Bell pair gives $C = 1$: throat area $1$, mutual information $2$, linear entropy $1$. A product state gives $C = 0$: no throat, no bridge, no correlation. Turn a dial from product to Bell and you watch the wormhole widen continuously.

Take $n$ Bell pairs side by side and the emergent geometry is a **perfect matching**: $2n$ cells joined in couples by throats of the prescribed areas. Partners have mutual information twice their throat area. Non-partners have mutual information exactly zero — and no bridge whatsoever joins them, because in a matching no positive-weight step ever leaves a pair. Every throat area is recovered from the pairwise data. The dictionary is complete and quantitative.

---

## Where it breaks: entanglement that cannot be a space

Now the twist, and it is the real news.

Not every quantum state has a geometry. The obstruction is monogamy. Consider a four-party GHZ state, $(|0000\rangle + |1111\rangle)/\sqrt{2}$, and look at three of its parties. Every nonempty marginal — each single party, each pair, and the triple — has entropy exactly $1$. Feed that into monogamy: the left side reads $1+1+1+1 = 4$, the right side reads $1+1+1=3$. The inequality demands $4 \le 3$.

So there is no bulk geometry, of any size, with any arrangement of hidden cells, whose min-cut entropies reproduce the GHZ pattern. GHZ entanglement is real, physical, and preparable in a laboratory — and it is *geometrically homeless*. GHZ correlation is shared democratically among three parties, and democracy is exactly what geometry forbids.

This is not an artifact of a weak model. The GHZ pattern satisfies subadditivity, and it satisfies strong subadditivity in submodular form. It passes every inequality that holds for *all* quantum states. It is monogamy, a strictly geometric constraint, that catches it.

So we have a strict hierarchy: quantum-consistent entropy patterns form one cone; geometric ones form a strictly smaller cone inside it. Which raises the obvious question. Monogamy carves off a slice. Is that all there is?

---

## The five-party cyclic law, and the wall behind it

It is not all there is. There are more geometric laws, and they involve more parties.

Take five pairwise disjoint boundary regions $A_0, \dots, A_4$ arranged around a circle, indices read modulo $5$. Then every bulk geometry satisfies the **five-party cyclic inequality**:

$$\sum_{j=0}^{4} S(A_j A_{j+1}) \;+\; S(A_0A_1A_2A_3A_4) \;\;\le\;\; \sum_{j=0}^{4} S(A_j A_{j+1} A_{j+2}).$$

The five consecutive *pairs*, plus the whole boundary, cost no more than the five consecutive *triples*. This too comes from a contraction — but a much stranger one than intersection-and-union. The recipe is

$$\mathrm{cyc}(c_0,c_1,c_2,c_3,c_4) \;=\; c_4 \wedge \lnot c_2 \wedge \bigl(c_0 \vee (c_1 \wedge \lnot c_3)\bigr),$$

applied in all five rotations, together with the union: six outputs from five inputs. It is a contraction — one verifies this across all $1024$ Boolean configurations — and on the boundary, where the five inputs trace out the consecutive triples and the regions are disjoint, the rule traces out exactly the consecutive pairs. Whoever first stared at that formula was not guessing; it was found by search, and it is the certificate the inequality needs.

Which brings us to the sharpest result here. Is the cyclic law just monogamy in disguise, applied cleverly five times? A great many valid-looking inequalities collapse that way.

This one does not. There is an explicit assignment of a number to each of the $32$ subsets of a five-element set — call it $S_w$, with $S_w(\emptyset) = 0$ and, for example, $S_w(\{0\}) = 3$, $S_w(\{1\}) = 2$, $S_w(\{0,1\}) = 5$, and $S_w(\text{everything}) = 2$ — with these properties:

- it satisfies **subadditivity** on every disjoint pair of subsets;
- it satisfies **strong subadditivity** on every disjoint triple;
- it satisfies **weak monotonicity**, $S(X) + S(Z) \le S(XY) + S(YZ)$, on every disjoint triple;
- it satisfies **monogamy** on every disjoint triple;
- and it **violates the cyclic inequality by exactly one unit**: the left side comes to $29$, the right side to $28$.

Those first four claims are not one-off spot checks. They are exhaustive verifications, over all $32^3 = 32{,}768$ triples of subsets, of every instance of every one of the four families.

The consequence is decisive on two fronts. Mathematically, the cyclic inequality is **independent** of the four earlier laws: no amount of formal manipulation of subadditivity, strong subadditivity, weak monotonicity and monogamy can produce it, because they are all true of $S_w$ and it is false of $S_w$. Physically, **no bulk geometry whatsoever realises $S_w$** — no graph, no weights, no arrangement of hidden cells. And this obstruction is invisible to the four classical families. You could check every one of their $32{,}768$ instances, find perfect agreement, and still be looking at a pattern of entanglement that no space can carry.

---

## What it means

Put the pieces together and a picture emerges that is sharper than the slogan it started from.

**Geometry is entanglement, quantitatively.** Not metaphorically: every wall area is exactly one half of a mutual information. And the map is stable — perturb a geometry's total area by $\varepsilon$ and no entropy moves by more than $\varepsilon$ — so the dictionary is a continuous correspondence, not a knife-edge coincidence.

**Wormholes are entanglement, exactly.** Positive correlation forces a bridge; geometric disconnection forces zero correlation; and with no hidden cells the bridge network *is* the entanglement network. ER = EPR, in a setting where it is a theorem.

**But the dictionary has holes, in both directions.** Going from geometry to entanglement, information is lost: hide one cell in the bulk and uniqueness dies. A "star" — three boundary cells each joined by a unit throat to one hidden central cell — and a "triangle" — the same three cells joined pairwise by throats of area $\tfrac12$, no hidden cell — produce *identical* entropies for every boundary region, yet their edge weights differ. Two different spaces, one indistinguishable shadow. (Interestingly, the star also gives the cleanest illustration of the bridge theorem: its cells $0$ and $1$ have mutual information $1$, so they must be bridged — and indeed they are, not by a direct wall, which has area zero, but by a two-step path through the hidden centre. Entanglement without an edge, mediated by the deep bulk.)

And going from entanglement to geometry, existence fails: GHZ states have no dual, and $S_w$ has no dual either, for a reason that no previously known constraint can see.

That last point is the one to carry away. If spacetime is emergent — if geometry is a coarse-grained description of a pattern of quantum correlations — then the set of correlation patterns that can *be* a geometry is a strict, and strictly complicated, subset of the ones nature can prepare. Monogamy is the first wall. The cyclic law is the second, and provably not the first one in disguise. There is no reason to think it is the last.

The universe may well be made of entanglement. But most entanglement, it turns out, is not made into a universe.

