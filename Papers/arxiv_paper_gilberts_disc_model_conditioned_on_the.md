# One Point per Tile: A Guided Tour of the Conditioned Gilbert Model

*How far must a radio reach before an infinite city of one-house-per-block becomes a single
connected network?*

---

## 1. The setup, in one picture

Take the infinite sheet of graph paper $\mathbb{Z}^2$. Inside **each** unit cell, drop
exactly one point. Two points are joined by an edge when their Euclidean distance is less
than a fixed radius $R$. That is the whole model.

This is a *conditioned* version of the classical
[Gilbert disc model](https://en.wikipedia.org/wiki/Random_geometric_graph): instead of
scattering points by a Poisson process — which clumps in some places and leaves deserts in
others — we force perfect one-per-cell regularity, and let the only randomness be *where
inside its own cell* each point sits.

Start by playing. Drag any point inside its cell, sweep the radius, and switch between the
extremal placements. Shift-click (or double-click) a cell to move the highlighted focus.

{{interactive_demo:0}}

> **What to notice.** With the zig-zag placement selected, sweep $R$ across $0.5$. Below it
> the double row is a heap of isolated pairs; above it, one chain runs off both edges of the
> window. That snap is the whole subject in miniature.

<details>
<summary><b>Why "conditioned"? A note on the underlying probability</b></summary>

In the random version, the point of cell $(i,j)$ is $(i+U_{ij},\,j+V_{ij})$ with all
$U_{ij},V_{ij}$ independent and uniform on $[0,1]$. This is exactly a Poisson process on
the plane of intensity $1$ *conditioned* to place one point in every unit cell. Such a
process is [hyperuniform](https://en.wikipedia.org/wiki/Hyperuniformity) in the strongest
sense: the number of points in a large region is pinned to the number of cells the region
meets, up to a boundary error. Poisson percolation has neither large empty regions nor
tight counts; here we have both, and the geometry changes completely.

Everything proved below is *placement-uniform* — a statement about **all** placements at
once — so it applies to every realisation of the random model, not merely almost surely.
</details>

---

## 2. Three thresholds, not one

Because a placement is an object you can *choose*, one critical radius splits into three.

| Symbol | Question it answers | Proved bounds |
|---|---|---|
| $R_{\min}$ | Smallest $R$ for which **some** placement has an infinite component | $\tfrac13\le R_{\min}\le\tfrac12$ |
| $R_{\mathrm{conn}}$ | Smallest $R$ for which **some** placement connects *everything* | $\tfrac13\le R_{\mathrm{conn}}\le1$ |
| $R_{\mathrm{full}}$ | Smallest $R$ for which **every** placement connects everything | $\tfrac{\sqrt{17}}2\le R_{\mathrm{full}}\le\sqrt5$ |

Monotonicity in $R$ makes each of these a genuine threshold, and the obvious inclusions
between the three families of radii give
$$R_{\min}\ \le\ R_{\mathrm{conn}}\ \le\ R_{\mathrm{full}}.$$

The three upper bounds are realised by three transparent pictures — a zig-zag, a centred
lattice, and a staggered cut. Here they are side by side.

{{visualization:0}}

---

## 3. The zig-zag: how to percolate at radius $1/2$

Restrict attention to two adjacent rows of cells, $j=0$ and $j=1$. In every cell $(i,0)$
put the point at $(i+\tfrac34,\,1)$ — pushed to the **top** edge of the cell. In every cell
$(i,1)$ put the point at $(i+\tfrac14,\,1)$ — pushed to the **bottom** edge.

Every one of these points now lies on the single horizontal line $y=1$, and reading left to
right their $x$-coordinates are
$$\dots,\quad i+\tfrac14,\quad i+\tfrac34,\quad i+\tfrac54,\quad i+\tfrac74,\quad\dots$$
Consecutive gaps are exactly $\tfrac12$.

> **Theorem.** For every $R>\tfrac12$ this placement has an infinite connected component;
> in fact the entire double row $\mathbb{Z}\times\{0,1\}$ is one component. Hence
> $R_{\min}\le\tfrac12$.

The trick uses both degrees of freedom at once: the *vertical* freedom collapses two rows
onto a single line, and the *horizontal* freedom interleaves them, halving the effective
spacing from $1$ to $\tfrac12$.

<details>
<summary><b>Can you beat the zig-zag? The periodic-path search</b></summary>

Any bi-infinite chain that drifts to infinity can be approximated by a **periodic drifting
pattern**: a cycle of cells $c_0,\dots,c_{T-1}$ closing up as $c_T=c_0+(a,b)$ with
$(a,b)\ne(0,0)$, together with points $p_t$ in those cells. The quantity to minimise is the
longest edge
$$\Lambda \;=\; \max_{0\le t<T}\ \|p_{t+1}-p_t\| .$$
For a fixed cell sequence this is a **convex** optimisation (a maximum of norms over a
product of boxes — a second-order cone programme). The outer choice of cell sequence is
combinatorial, growing like $8^T$.

Exhaustive optimisation over all drifting patterns with $T\le4$ and randomised search for
$T=5,\dots,8$ never produced $\Lambda<\tfrac12$. The algorithm below reproduces that search.

{{algorithm:1}}
</details>

---

## 4. Nothing escapes a $3\times3$ box

Now the hard direction. Why can't a *cleverer* placement percolate with a smaller radius?

> **Confinement Theorem.** Let $R<\tfrac13$. Then for **every** placement, and every cell
> $c$, any cell reachable from $c$ differs from $c$ by at most one in each coordinate. In
> particular every connected component lies inside a $3\times3$ block, so no placement
> percolates and $R_{\min}\ge\tfrac13$.

The proof is a pleasure, and it is entirely elementary. Two ideas do all the work.

**Idea 1 — an edge is a line-crossing certificate.** Suppose two joined points lie in cells
with different columns. Since an edge has horizontal extent $<R<1$, the columns must be
adjacent; call $x=K$ the vertical grid line between them. The left point has $x\le K$ and
the right point has $x\ge K$, and they are less than $R$ apart. Therefore **both** are
within distance $R$ of the line $x=K$. Advancing a column *forces you to hug the line you
just crossed*.

**Idea 2 — you can only ever hug one line.** Distinct integers are at least $1$ apart. So if
the current point is within $2R<\tfrac23$ of $x=K$, no *other* vertical grid line is within
$R$ of it. Every column-crossing the path ever makes must cross the **same** line $K$.

<details>
<summary><b>Click to reveal the full argument (the travelling invariant)</b></summary>

Fix $0<R<\tfrac13$. Walk along a self-avoiding path and carry two integers $K$ and $J$ — the
only vertical and horizontal grid lines the path will ever cross. At each step, with
previous cell $p$ and current cell $c$, maintain:

1. $p\ne c$;
2. $p_1,c_1\in\{K-1,K\}$ and $p_2,c_2\in\{J-1,J\}$;
3. *(loose slack)* $|x(c)-K|<2R$ and $|y(c)-J|<2R$;
4. *(tight slack)* if the last step changed the column then $|x(c)-K|<R$, and if it changed
   the row then $|y(c)-J|<R$.

**Uniqueness.** If $|x(c)-K'|<R$ for an integer $K'$, then $|K'-K|<R+2R=3R<1$, so $K'=K$.
This is the only place where the constant $\tfrac13$ is used.

**Propagation.** Let $c\sim c'$ with $c'\ne p$. If the step changes the row only, the crossed
horizontal line is $J$ by uniqueness, so the $y$-slack refreshes to $R$; the $x$-slack
degrades from $R$ to at most $R+R=2R$ by the triangle inequality — *provided* the tight
$x$-slack held at $c$. If it did not, the previous step also changed the row only, both
steps crossed the same line $J$, and the row membership constraints force $c'=p$, which is
excluded. The column-only case is the mirror image, and a step changing both coordinates
refreshes both slacks to $R$.

**Initialisation.** Two steps suffice to install the invariant with
$K\in\{c_{0,1},c_{0,1}+1\}$ and $J\in\{c_{0,2},c_{0,2}+1\}$, using the fact that a
self-avoiding path cannot take two consecutive steps that both leave the column unchanged
(they would cross the same horizontal line and return to where they started).

**Conclusion.** From step two onward every cell has column in $\{K-1,K\}$ and row in
$\{J-1,J\}$; combined with the two possible values of $K$ and $J$, every reachable cell lies
within one of the start in each coordinate. $\blacksquare$

**Where $\tfrac13$ leaks.** If the tight slack $R$ could be maintained throughout instead of
degrading to $2R$, the same argument would give $R_{\min}\ge\tfrac12$ — the conjectured sharp
value. The missing ingredient is a *joint* potential in $x$ and $y$ that prevents the slack
from being recharged by direction reversals.
</details>

Test the theorem yourself: in the widget above, set $R$ below $1/3$, choose the random
placement, and hit "re-roll" as many times as you like. The component of the highlighted
cell never leaves its $3\times3$ block. Here is the same experiment run at scale.

{{demo:0}}

And here is the growth curve, with the theoretical ceiling of $9$ cells marked, alongside a
number line of the three thresholds.

{{visualization:1}}

The exploration itself is a breadth-first search with one subtlety: how far away can a
neighbour be? Along an edge, a cell coordinate changes by at most $\lceil R\rceil+1$, which
bounds the search stencil.

{{algorithm:0}}

---

## 5. The other end: connecting *everything*

Push the radius up. When does connectivity become unavoidable?

**The easy half.** Take two cells sharing an edge, say $(i,j)$ and $(i+1,j)$. Their points
can be at most $2$ apart horizontally (one at the far left of the left cell, one at the far
right of the right cell) and at most $1$ apart vertically. So they are within
$\sqrt{2^2+1^2}=\sqrt5$ of each other, in **every** placement.

> **Theorem.** For every $R>\sqrt5\approx2.2360$ and every placement, the graph contains the
> entire nearest-neighbour grid of $\mathbb{Z}^2$, hence is connected. So
> $R_{\mathrm{full}}\le\sqrt5$.

**The adversarial half.** Now build the meanest placement you can. Push every point in rows
$j\ge1$ to the **top** edge of its cell, at $(i+\tfrac12,\,j+1)$; push every point in rows
$j\le0$ to the **bottom-left** corner, at $(i,\,j)$. Look at the seam between rows $0$ and
$1$: any crossing edge has vertical extent at least $2$, and the horizontal stagger of
$\tfrac12$ makes its horizontal extent at least $\tfrac12$.

> **Theorem.** For every $R\le\tfrac{\sqrt{17}}2\approx2.0616$ this placement is
> disconnected: the upper half-plane of cells is closed under adjacency, so no chain crosses
> the seam. Hence $R_{\mathrm{full}}\ge\tfrac{\sqrt{17}}2$.

Select "staggered half-plane cut" in the widget and slowly increase $R$: the dashed seam
holds solid until you pass $2.0616$, and then the two half-planes fuse.

<details>
<summary><b>Why the gap between $\sqrt{17}/2$ and $\sqrt5$ is hard to close</b></summary>

The bound $\sqrt5$ is attained by a **single pair** of cells: put $p((0,0))=(0,0)$ and
$p((1,0))=(2,1)$ and their distance is exactly $\sqrt5$. But disconnection is a *global*
demand: an entire cut has to be long simultaneously. Pushing a point to the top-right corner
to escape its left neighbour drags it towards its right and top neighbours; each point serves
four neighbours at once, so the adversary cannot make every crossing extremal.

The natural family to try beyond straight cuts is **staircase cuts**, alternating between two
consecutive horizontal lines. The algorithm below evaluates straight cuts exactly (their
value is $\sqrt{4+\min(s,1-s)^2}$, maximised at stagger $s=\tfrac12$) and searches numerically
over staircases. Nothing found so far beats $\tfrac{\sqrt{17}}2$.

{{algorithm:2}}
</details>

---

## 6. The middle threshold

Between the two lies $R_{\mathrm{conn}}$: the range at which *some* placement connects
everything. The obvious candidate is the most symmetric placement of all — every point at
the exact centre of its cell, $(i+\tfrac12,\,j+\tfrac12)$. Then edge-adjacent points are at
distance exactly $1$.

> **Theorem.** For every $R>1$ the centred placement is connected, so
> $R_{\mathrm{conn}}\le1$. And since a connected graph on $\mathbb{Z}^2$ certainly
> percolates, the Confinement Theorem gives $R_{\mathrm{conn}}\ge\tfrac13$.

This is where the widest gap remains — $\tfrac13$ to $1$ — and where the honest answer is
"we do not know". Connecting *every* cell is far more demanding than growing one infinite
chain, so the lower bound is surely not sharp. A concrete first target: is there a placement
connecting everything at range close to $1/\sqrt2$, by tilting the alignment so that each
point serves both a horizontal and a vertical neighbour?

---

## 7. Where this leaves us

Run the complete numerical suite: confinement, the zig-zag snap at $\tfrac12$, the centred
placement, the $\sqrt5$ bound, the $\tfrac{\sqrt{17}}2$ cut, and the periodic-pattern search.

{{demo:0}}

Three conjectures stand out, each falsifiable by a single explicit example:

- **$R_{\min}=\tfrac12$.** Equivalently: for $R\le\tfrac12$, every component of every
  placement is finite. To refute it, exhibit one periodic drifting pattern with every edge
  shorter than $\tfrac12$.
- **Quantitative subcriticality.** For $R<\tfrac12$, components should have diameter of order
  $(1-2R)^{-1}$ — the slack recursion $a_{t+1}\le a_t-(1-2R)$ per column advance predicts it.
  We know only that the diameter is $3$ once $R<\tfrac13$.
- **$R_{\mathrm{full}}=\sqrt5$.** To refute it, prove that straight staggered cuts are
  extremal — which would pin the answer at $\tfrac{\sqrt{17}}2$ instead.

Why care? Point patterns with suppressed density fluctuations show up in
[photonic band-gap materials](https://en.wikipedia.org/wiki/Photonic_crystal), in avian
retinal cone mosaics, in jammed packings, and in planned wireless networks where one base
station is sited per administrative cell. In all of them, transport and coverage are governed
by exactly this kind of connectivity threshold — and here, unusually for percolation, the
constants are sharp, geometric, and provable by hand.
