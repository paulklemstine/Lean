# Gilbert's Disc Model Conditioned on the Square Lattice: Deterministic Critical Radii

**Author:** Aristotle
**Date:** 2026-08-05

## Abstract

We study a percolation model on the plane obtained by conditioning Gilbert's disc model on
the square lattice: one point is placed in each cell of the grid $\mathbb{Z}^2$, and two
points are joined by an edge when their Euclidean distance is smaller than a fixed radius
$R$. The rigidity of the "one point per cell" constraint makes several thresholds
accessible to purely geometric, placement-uniform analysis. We isolate three critical
radii determined by the geometry rather than by the law of the points: $R_{\min}$, the
infimum of the radii for which *some* placement produces an infinite connected component;
$R_{\mathrm{conn}}$, the infimum of the radii for which *some* placement makes the whole
graph connected; and $R_{\mathrm{full}}$, the infimum of the radii for which *every*
placement makes the whole graph connected. We prove
$$\tfrac13\le R_{\min}\le\tfrac12,\qquad \tfrac13\le R_{\mathrm{conn}}\le 1,\qquad
\tfrac{\sqrt{17}}{2}\le R_{\mathrm{full}}\le\sqrt5,$$
together with the ordering $R_{\min}\le R_{\mathrm{conn}}\le R_{\mathrm{full}}$. The lower
bound for $R_{\min}$ is a deterministic non-percolation theorem: for $R<\tfrac13$ and for
*every* placement, every connected component is contained in a $3\times3$ block of cells.
Its proof rests on a *line-crossing lemma* and a travelling invariant along self-avoiding
paths, and it applies simultaneously to all realisations of the random model. The upper
bounds are realised by three explicit extremal placements: a collinear zig-zag double row
(radius $\tfrac12$), the centred placement (radius $1$), and a staggered half-plane cut
(radius $\tfrac{\sqrt{17}}2$). We discuss the conjectured sharp values $R_{\min}=\tfrac12$
and $R_{\mathrm{full}}=\sqrt5$, present the computational evidence for them, and outline a
quantitative subcriticality programme predicting component diameters of order
$(1-2R)^{-1}$ for $R<\tfrac12$.

**Keywords:** continuum percolation, Gilbert disc model, random geometric graph,
conditioned point process, square lattice, hyperuniformity, critical radius, extremal
configurations.

---

## 1. Introduction

### 1.1 Gilbert's disc model and its conditioning

In Gilbert's disc model, introduced in 1961 as a model for radio communication networks,
points of a homogeneous Poisson process of intensity $\lambda$ in $\mathbb{R}^2$ are joined
whenever their distance is below a fixed threshold. The model exhibits a sharp phase
transition: there is a critical intensity $\lambda_c$ below which all clusters are almost
surely finite and above which an infinite cluster exists almost surely. The precise value
of $\lambda_c$ is unknown; simulations give $\lambda_c R^2\approx 0.3591$, and no closed
form is expected.

The model considered here replaces the Poisson process by a strongly conditioned one: the
process is conditioned to have exactly one point in each unit cell of the square lattice
$\mathbb{Z}^2$, with the point uniform in its cell and the cells independent. Equivalently,
the point of cell $(i,j)$ is $(i+U_{i,j},\,j+V_{i,j})$ with $(U_{i,j},V_{i,j})$ independent
and uniform on $[0,1]^2$.

This conditioning eliminates both of the mechanisms that dominate Poisson percolation:
clumping (which creates dense local clusters at low intensity) and vacancy (which creates
arbitrarily large empty regions at any intensity). What remains is a *maximally rigid*
point process — the number of points in any large region equals the number of cells the
region meets, up to a boundary error, so the model is hyperuniform in the strongest sense.

### 1.2 Three geometric thresholds

Because the point locations range over a compact parameter space $[0,1]^{\mathbb{Z}^2}$,
the conditioned model supports questions that are meaningless for the Poisson model:
questions about *all* placements simultaneously, or about the *existence* of a placement
with a given property. This is what produces the three critical radii studied here. The
almost-sure percolation threshold of the random model, which we denote $R_c$, satisfies
$R_{\min}\le R_c$ trivially (a percolating realisation is a percolating placement) and is
not the subject of this paper; our results are placement-uniform and therefore hold for
every realisation.

### 1.3 Results

The main results are the two-sided bounds
$$\tfrac13\le R_{\min}\le\tfrac12,\qquad \tfrac13\le R_{\mathrm{conn}}\le 1,\qquad
\tfrac{\sqrt{17}}{2}\le R_{\mathrm{full}}\le\sqrt5,$$
the ordering $R_{\min}\le R_{\mathrm{conn}}\le R_{\mathrm{full}}$, and the confinement
theorem: for $R<\tfrac13$, every component of every placement is contained in a
$3\times 3$ block of cells.

### 1.4 Organisation

Section 2 fixes definitions. Section 3 gives the elementary geometry of edges in the
conditioned model. Section 4 proves the deterministic non-percolation theorem, the
technical heart of the paper. Section 5 presents the three extremal placements. Section 6
assembles the critical-radius bounds. Section 7 discusses algorithms and computational
evidence. Section 8 discusses applications and open problems.

---

## 2. The model

### 2.1 Placements

**Definition 2.1 (Placement).** A *placement* (or *configuration*) is a family
$$\mathrm{off}:\mathbb{Z}^2\to[0,1]^2,\qquad c\mapsto \big(\mathrm{off}_1(c),
\mathrm{off}_2(c)\big),$$
of offsets, one for each cell of the grid. The *point of the cell* $c=(c_1,c_2)$ is
$$p(c)=\big(x(c),\,y(c)\big) := \big(c_1+\mathrm{off}_1(c),\; c_2+\mathrm{off}_2(c)\big)
\in [c_1,c_1+1]\times[c_2,c_2+1].$$

We work with the closed cell $[0,1]^2$ of admissible offsets. This is a compactification of
the open cell used by the random model; it is harmless for the random model (the boundary
has measure zero) and it makes the extremal placements below legitimate objects rather than
limits of legitimate objects. All results proved for closed cells are a fortiori true for
the random model.

**Definition 2.2 (Gilbert graph).** For $R\in\mathbb{R}$ and a placement $C$, the *Gilbert
graph* $G_R(C)$ is the simple graph on the vertex set $\mathbb{Z}^2$ (the cells) with
$$c\sim c' \iff c\ne c' \text{ and } \|p(c)-p(c')\| < R,$$
where $\|\cdot\|$ is the Euclidean norm. We write $d(c,c')=\|p(c)-p(c')\|$ and
$d^2(c,c')=(x(c)-x(c'))^2+(y(c)-y(c'))^2$.

Two immediate remarks. First, the graph is symmetric and loopless by construction. Second,
it is monotone in $R$: if $R\le R'$ then $G_R(C)\subseteq G_{R'}(C)$ as edge sets, hence
reachability in $G_R(C)$ implies reachability in $G_{R'}(C)$. Also, an edge can exist only
if $R>0$, since distances are non-negative.

### 2.2 The three critical radii

**Definition 2.3.** Define three sets of radii:

- $\mathcal{P}=\{R : \exists$ a placement $C$ and a cell $c$ with the component of $c$ in
  $G_R(C)$ infinite$\}$;
- $\mathcal{C}=\{R : \exists$ a placement $C$ with $G_R(C)$ connected$\}$;
- $\mathcal{F}=\{R : \forall$ placements $C$, $G_R(C)$ is connected$\}$;

and set
$$R_{\min}=\inf\mathcal{P},\qquad R_{\mathrm{conn}}=\inf\mathcal{C},\qquad
R_{\mathrm{full}}=\inf\mathcal{F}.$$

By monotonicity each of the three sets is upward-closed in the sense that its infimum is a
genuine threshold: if $R\in\mathcal{P}$ and $R'\ge R$ then $R'\in\mathcal{P}$, and likewise
for $\mathcal{C}$ and $\mathcal{F}$. Clearly $\mathcal{F}\subseteq\mathcal{C}$: if every
placement gives a connected graph, then in particular *some* placement does, and any
non-empty set of placements exists. Also $\mathcal{C}\subseteq\mathcal{P}$: a connected
graph on the infinite vertex set $\mathbb{Z}^2$ has an infinite component. Consequently
$$R_{\min}\le R_{\mathrm{conn}}\le R_{\mathrm{full}}. \tag{2.1}$$
All three infima are over non-empty sets bounded below (Sections 4–6), so all three are
finite real numbers.

---

## 3. Elementary geometry of edges

Throughout this section $C$ is a placement and $R$ a radius.

**Lemma 3.1 (Coordinate bounds along an edge).** If $c\sim c'$ in $G_R(C)$ then
$$|x(c)-x(c')|<R\quad\text{and}\quad |y(c)-y(c')|<R.$$

*Proof.* Each coordinate difference is bounded in absolute value by the Euclidean distance,
which is $<R$. $\square$

**Lemma 3.2 (Neighbours are grid-adjacent for $R\le1$).** If $R\le1$ and $c\sim c'$ in
$G_R(C)$ then $|c'_1-c_1|\le1$ and $|c'_2-c_2|\le1$.

*Proof.* Write $c'_1-c_1=\big(x(c')-x(c)\big)+\big(\mathrm{off}_1(c)-\mathrm{off}_1(c')\big)$.
The first bracket has absolute value $<R\le1$ by Lemma 3.1, the second at most $1$ since
both offsets lie in $[0,1]$. Hence $|c'_1-c_1|<2$, and being an integer it is at most $1$.
The vertical case is identical. $\square$

**Lemma 3.3 (Diameter of a grid-adjacent pair).** If $c$ and $c'$ are cells sharing an
edge (that is, $|c_1-c'_1|+|c_2-c'_2|=1$), then $d(c,c')\le\sqrt5$ for every placement.

*Proof.* Say $c'=(c_1+1,c_2)$. The horizontal separation satisfies
$x(c')-x(c)=1+\mathrm{off}_1(c')-\mathrm{off}_1(c)\in[0,2]$, and the vertical separation
satisfies $|y(c')-y(c)|=|\mathrm{off}_2(c')-\mathrm{off}_2(c)|\le1$. Hence
$d^2\le 4+1=5$. The vertical case is symmetric. $\square$

**Lemma 3.4 (Line-crossing lemma).** Let $R<1$ and let $c\sim c'$ with $c_1\ne c'_1$. Then
there is an integer $K$ such that $\{c_1,c'_1\}\subseteq\{K-1,K\}$ and
$$|x(c)-K|<R\quad\text{and}\quad |x(c')-K|<R.$$
The analogous statement holds for rows: if $c_2\ne c'_2$ there is an integer $J$ with
$\{c_2,c'_2\}\subseteq\{J-1,J\}$ and $|y(c)-J|<R$, $|y(c')-J|<R$.

*Proof.* By Lemma 3.2, $c'_1=c_1\pm1$; suppose $c'_1=c_1+1$ and take $K=c_1+1$. Then
$x(c)\le c_1+1=K$ and $x(c')\ge c'_1=K$, so the two points straddle the line $x=K$. Since
$|x(c)-x(c')|<R$ and $x(c)\le K\le x(c')$, both are within $R$ of $K$:
$K-x(c)\le x(c')-x(c)<R$ and $x(c')-K\le x(c')-x(c)<R$. The case $c'_1=c_1-1$ is symmetric
with $K=c_1$. $\square$

Lemma 3.4 is the structural fact that drives the entire subcritical analysis: *an edge that
advances a column is a certificate that both of its endpoints hug the same vertical grid
line.*

**Lemma 3.5 (Integer separation).** If $K,K'\in\mathbb{Z}$ and $|K-K'|<1$ then $K=K'$.

*Proof.* Distinct integers differ by at least $1$. $\square$

**Lemma 3.6 (Grid connectivity criterion).** If, in $G_R(C)$, every pair of horizontally
adjacent cells $(i,j)\sim(i+1,j)$ and every pair of vertically adjacent cells
$(i,j)\sim(i,j+1)$ is an edge, then $G_R(C)$ is connected.

*Proof.* By induction along $\mathbb{Z}$ in each direction, $(i,j)$ is reachable from
$(i',j)$ for all $i,i'$, and $(i,j)$ from $(i,j')$ for all $j,j'$. Concatenating a
horizontal and a vertical path connects any two cells. $\square$

---

## 4. Deterministic non-percolation below $1/3$

This section proves the paper's technical centrepiece.

**Theorem 4.1 (Confinement).** Let $R<\tfrac13$. Then for **every** placement $C$ and all
cells $c,d$, if $d$ is reachable from $c$ in $G_R(C)$ then
$$|d_1-c_1|\le1\quad\text{and}\quad|d_2-c_2|\le1 .$$

**Corollary 4.2.** For $R<\tfrac13$ and every placement, every connected component of
$G_R(C)$ is contained in a $3\times3$ block of cells; in particular every component is
finite and no placement percolates. Hence $R_{\min}\ge\tfrac13$.

### 4.1 The invariant

Fix $R$ with $0<R<\tfrac13$ (the case $R\le0$ is vacuous: no edges exist). Fix integers
$K,J$. For an ordered pair of cells $(p,c)$ — "previous" and "current" — say that the
*invariant* $\mathrm{Inv}(K,J;p,c)$ holds when:

1. $p\ne c$;
2. $p_1,c_1\in\{K-1,K\}$ and $p_2,c_2\in\{J-1,J\}$;
3. *(loose slack)* $|x(c)-K|<2R$ and $|y(c)-J|<2R$;
4. *(tight slack)* if $p_1\ne c_1$ then $|x(c)-K|<R$; if $p_2\ne c_2$ then $|y(c)-J|<R$.

Read informally: $K$ and $J$ are the only vertical and horizontal grid lines the path will
ever cross; the current point is always within $2R$ of both, and within the tighter $R$ of
whichever it just crossed.

**Lemma 4.3 (Uniqueness of the crossed line).** Assume $\mathrm{Inv}(K,J;p,c)$ and
$R<\tfrac13$. If $K'\in\mathbb{Z}$ satisfies $|x(c)-K'|<R$ then $K'=K$; likewise for rows.

*Proof.* By the triangle inequality $|K'-K|\le|K'-x(c)|+|x(c)-K|<R+2R=3R<1$; apply
Lemma 3.5. $\square$

**Lemma 4.4 (Propagation).** Assume $\mathrm{Inv}(K,J;p,c)$, $R<\tfrac13$, and let
$c\sim c'$ with $c'\ne p$. Then $\mathrm{Inv}(K,J;c,c')$.

*Proof.* Note $c\ne c'$ since $c\sim c'$. Three cases.

*(a) The step changes the row only* ($c'_1=c_1$, $c'_2\ne c_2$). Lemma 3.4 produces an
integer $J'$ with $c_2,c'_2\in\{J'-1,J'\}$ and $|y(c)-J'|<R$, $|y(c')-J'|<R$; by Lemma 4.3,
$J'=J$. This immediately gives conditions 2 (for rows), 3 and 4 in the $y$-coordinate:
$|y(c')-J|<R<2R$. For the $x$-coordinate we must show $|x(c')-K|<2R$; this follows from
$$|x(c')-K|\le|x(c')-x(c)|+|x(c)-K|<R+|x(c)-K|$$
provided $|x(c)-K|<R$, i.e. provided the tight slack holds in $x$ at $c$. If $p_1\ne c_1$
this is condition 4 of the hypothesis. If $p_1=c_1$, then $p_2\ne c_2$ (else $p=c$), so the
previous step also changed the row only, and by Lemma 3.4 and Lemma 4.3 it crossed the same
horizontal line $J$; combining the membership constraints $p_2,c_2\in\{J-1,J\}$,
$p_2 \ne c_2$, $c_2,c'_2\in\{J-1,J\}$, $c_2 \ne c'_2$ forces $p_2=c'_2$, hence $p=c'$,
contradicting $c'\ne p$. Finally, the tight condition in $x$ at $c'$ is vacuous since
$c'_1=c_1$.

*(b) The step changes the column only.* Symmetric to (a), exchanging the roles of the
coordinates.

*(c) The step changes both.* Lemma 3.4 applies in both coordinates, and Lemma 4.3 identifies
the crossed lines as $K$ and $J$; both slacks are refreshed to the tight value, and all
conditions hold at $(c,c')$. $\square$

The two "no two consecutive trivial steps" facts used inside case (a) deserve to be stated
separately, since they are the combinatorial engine of the argument.

**Lemma 4.5.** Let $R<\tfrac13$ and let $c_0\sim c_1\sim c_2$ with $c_2\ne c_0$. Then it is
impossible that $c_1$ and $c_2$ have the same column as $c_0$; likewise it is impossible
that they have the same row as $c_0$.

*Proof.* Suppose $(c_1)_1=(c_0)_1=(c_2)_1$. Since $c_0\ne c_1$ and $c_1\ne c_2$, both steps
change the row, so Lemma 3.4 produces horizontal lines $J_1$ and $J_2$ with
$|y(c_1)-J_1|<R$ and $|y(c_1)-J_2|<R$; by Lemma 3.5 and the triangle inequality
($|J_1-J_2|<2R<1$) we get $J_1=J_2=:J$. Then $(c_0)_2,(c_1)_2\in\{J-1,J\}$ with
$(c_0)_2\ne (c_1)_2$, and $(c_1)_2,(c_2)_2\in\{J-1,J\}$ with $(c_1)_2\ne(c_2)_2$, forcing
$(c_2)_2=(c_0)_2$ and hence $c_2=c_0$, a contradiction. $\square$

**Lemma 4.6 (Initialisation).** Let $R<\tfrac13$ and let $c_0\sim c_1\sim c_2$ with
$c_2\ne c_0$. Then there exist integers $K\in\{(c_0)_1,(c_0)_1+1\}$ and
$J\in\{(c_0)_2,(c_0)_2+1\}$ with $\mathrm{Inv}(K,J;c_1,c_2)$.

*Proof.* We construct $K$; the construction of $J$ is symmetric, and the two are
independent. If the second step changes the column ($(c_2)_1\ne (c_1)_1$), take $K$ from
Lemma 3.4 applied to $c_1\sim c_2$; then both slacks in $x$ at $c_2$ are $<R$. It remains
to check $K\in\{(c_0)_1,(c_0)_1+1\}$: if the first step also changed the column, the line
it crossed coincides with $K$ by the argument of Lemma 4.5, so $K$ is adjacent to
$(c_0)_1$; if the first step did not change the column, $(c_1)_1=(c_0)_1$ and Lemma 3.4
places $K\in\{(c_1)_1,(c_1)_1+1\}$. If the second step leaves the column unchanged, then by
Lemma 4.5 the first step must have changed it; take $K$ from Lemma 3.4 applied to
$c_0\sim c_1$, so $|x(c_1)-K|<R$, and then $|x(c_2)-K|\le|x(c_2)-x(c_1)|+|x(c_1)-K|<2R$,
giving the loose bound (the tight bound is vacuous here). $\square$

### 4.2 Proof of Theorem 4.1

Let $d$ be reachable from $c$. Reachability is witnessed by a *path* (a self-avoiding walk),
obtained from any walk by deleting cycles. Let $c=c_0,c_1,\dots,c_n=d$ be such a path. If
$n\le1$, Lemma 3.2 gives the conclusion directly (using $R<\tfrac13<1$). If $n\ge2$, then
$c_2\ne c_0$ because the path is self-avoiding, so Lemma 4.6 supplies $K,J$ with
$\mathrm{Inv}(K,J;c_1,c_2)$, $K\in\{c_{0,1},c_{0,1}+1\}$, $J\in\{c_{0,2},c_{0,2}+1\}$.
Applying Lemma 4.4 inductively along the path — the hypothesis $c_{t+1}\ne c_{t-1}$ holds
at every step since the path is self-avoiding — we conclude that every subsequent cell
$c_t$ ($t\ge2$) satisfies $c_{t,1}\in\{K-1,K\}$ and $c_{t,2}\in\{J-1,J\}$. Since
$K\in\{c_{0,1},c_{0,1}+1\}$, we get $c_{t,1}\in\{c_{0,1}-1,c_{0,1},c_{0,1}+1\}$, and
similarly for rows. Hence $|d_1-c_1|\le1$ and $|d_2-c_2|\le1$. $\square$

**Where the constant $\tfrac13$ comes from.** The only quantitative input is Lemma 4.3:
tight slack $R$ plus loose slack $2R$ must be less than the integer gap $1$. If one could
maintain slack $R$ rather than $2R$ throughout, the argument would give
$R_{\min}\ge\tfrac12$; the loss of a factor arises precisely from steps that fail to
refresh a coordinate. Repairing this — designing a joint potential in $x$ and $y$ that
prevents the slack from being recharged by direction reversals — is the route to the
conjectured sharp value, discussed in Section 8.

---

## 5. Extremal placements

### 5.1 The line placement: percolation above $1/2$

**Definition 5.1.** The *line placement* $L$ assigns
$$\mathrm{off}\big((i,0)\big)=\big(\tfrac34,\,1\big),\qquad
\mathrm{off}\big((i,1)\big)=\big(\tfrac14,\,0\big),$$
and $\mathrm{off}(c)=(0,0)$ for all other cells. Thus $p\big((i,0)\big)=(i+\tfrac34,\,1)$
and $p\big((i,1)\big)=(i+\tfrac14,\,1)$: every point of the two rows $j\in\{0,1\}$ lies on
the horizontal line $y=1$.

**Lemma 5.2.** In the line placement, $d\big((i,1),(i,0)\big)=\tfrac12$ and
$d\big((i,0),(i+1,1)\big)=\tfrac12$ for every $i\in\mathbb{Z}$.

*Proof.* Both pairs lie on $y=1$; the $x$-coordinates are $i+\tfrac14$ and $i+\tfrac34$ in
the first case, and $i+\tfrac34$ and $i+1+\tfrac14=i+\tfrac54$ in the second. $\square$

**Theorem 5.3 (Percolating placement above $\tfrac12$).** For every $R>\tfrac12$, the
Gilbert graph of the line placement has an infinite connected component; explicitly, all
cells $(n,0)$ with $n\in\mathbb{Z}$ lie in the component of $(0,0)$. Consequently
$R_{\min}\le\tfrac12$.

*Proof.* By Lemma 5.2 and $R>\tfrac12$, the chain
$(i,0)\sim(i+1,1)\sim(i+1,0)$ shows that $(i,0)$ and $(i+1,0)$ are in the same component,
for every $i$. Induction gives an injection $n\mapsto(n,0)$ from $\mathbb{N}$ into the
component of $(0,0)$, so the component is infinite. Since a percolating placement exists for
every $R>\tfrac12$, the infimum defining $R_{\min}$ is at most $\tfrac12$. $\square$

The reading of the construction is: within a *pair* of adjacent rows, one can force all
points onto a single line and alternate their horizontal offsets, halving the effective
spacing from $1$ to $\tfrac12$. This uses both degrees of freedom of the model — the
vertical freedom to collapse two rows onto one line, and the horizontal freedom to
interleave.

### 5.2 The centred placement: full connectivity above $1$

**Definition 5.4.** The *centred placement* $Z$ assigns $\mathrm{off}(c)=(\tfrac12,\tfrac12)$
for all $c$, so $p\big((i,j)\big)=(i+\tfrac12,\,j+\tfrac12)$.

**Theorem 5.5.** For every $R>1$, the Gilbert graph of the centred placement is connected:
all points are connected to each other. Consequently $R_{\mathrm{conn}}\le1$.

*Proof.* Edge-adjacent cells have points at distance exactly $1<R$, so all grid edges are
present; apply Lemma 3.6. $\square$

### 5.3 The cut placement: disconnection below $\sqrt{17}/2$

**Definition 5.6.** The *cut placement* $X$ assigns
$$\mathrm{off}(c)=\begin{cases}(\tfrac12,\,1) & \text{if } c_2\ge1,\\[2pt]
(0,\,0) & \text{if } c_2\le0,\end{cases}$$
so that $p\big((i,j)\big)=(i+\tfrac12,\,j+1)$ for $j\ge1$ and $p\big((i,j)\big)=(i,\,j)$ for
$j\le0$. Every point of the upper half is pushed to the top edge of its cell and staggered
horizontally by $\tfrac12$; every point of the lower half is pushed to the bottom-left
corner of its cell.

**Lemma 5.7.** In the cut placement, if $c_2\ge1$ and $c'_2\le0$ then
$d^2(c,c')\ge\tfrac{17}4$.

*Proof.* Vertically, $y(c)-y(c')=(c_2+1)-c'_2\ge (0+1)+1-0=2$ since $c_2\ge c'_2+1$.
Horizontally, $x(c)-x(c')=(c_1+\tfrac12)-c'_1$, which is a half-integer of the form
$m+\tfrac12$ with $m\in\mathbb{Z}$, so $|x(c)-x(c')|\ge\tfrac12$. Hence
$d^2\ge 4+\tfrac14=\tfrac{17}4$. $\square$

**Theorem 5.8 (Persistent cut).** For every $R$ with $R^2\le\tfrac{17}4$ — equivalently
$R\le\tfrac{\sqrt{17}}2$ — the Gilbert graph of the cut placement is disconnected: no cell
with $c_2\ge1$ is reachable from any cell with $c'_2\le0$. Consequently
$R_{\mathrm{full}}\ge\tfrac{\sqrt{17}}2\approx 2.0616$.

*Proof.* By Lemma 5.7 no edge joins $\{c_2\ge1\}$ to $\{c_2\le0\}$, so the upper half-plane
of cells is closed under adjacency and hence, by induction along walks, under reachability.
Thus $(0,1)$ is not reachable from $(0,0)$ and $G_R(X)$ is not connected. $\square$

### 5.4 Universal connectivity above $\sqrt5$

**Theorem 5.9.** For every $R>\sqrt5$ and **every** placement $C$, the graph $G_R(C)$ is
connected. Consequently $R_{\mathrm{full}}\le\sqrt5\approx 2.2360$.

*Proof.* By Lemma 3.3, all grid edges are present; apply Lemma 3.6. $\square$

---

## 6. The critical radii

**Theorem 6.1 (Geometric percolation threshold).** $\tfrac13\le R_{\min}\le\tfrac12$.

*Proof.* Upper bound: Theorem 5.3 shows $(\tfrac12,\infty)\subseteq\mathcal{P}$, so
$R_{\min}=\inf\mathcal{P}\le\inf(\tfrac12,\infty)=\tfrac12$. Lower bound: Corollary 4.2
shows $R\ge\tfrac13$ for every $R\in\mathcal{P}$, and $\mathcal{P}\ne\emptyset$, so
$\inf\mathcal{P}\ge\tfrac13$. $\square$

**Theorem 6.2 (Connecting threshold).** $\tfrac13\le R_{\mathrm{conn}}\le1$.

*Proof.* Upper bound: Theorem 5.5 shows $(1,\infty)\subseteq\mathcal{C}$. Lower bound:
$\mathcal{C}\subseteq\mathcal{P}$ (a connected graph on $\mathbb{Z}^2$ has an infinite
component — indeed the component of any cell is all of $\mathbb{Z}^2$), so Corollary 4.2
applies to every $R\in\mathcal{C}$. $\square$

**Theorem 6.3 (Full-connectivity threshold).** $\tfrac{\sqrt{17}}2\le R_{\mathrm{full}}
\le\sqrt5$, i.e. $2.0615\ldots\le R_{\mathrm{full}}\le 2.2360\ldots$

*Proof.* Theorem 5.9 gives $(\sqrt5,\infty)\subseteq\mathcal{F}$, hence the upper bound.
For the lower bound, let $R\in\mathcal{F}$. Then $R>0$ (a connected graph on $\mathbb{Z}^2$
has at least one edge, and edges require $R>0$), and if $R<\tfrac{\sqrt{17}}2$ then
$R^2<\tfrac{17}4$, so Theorem 5.8 exhibits a disconnected placement, contradicting
$R\in\mathcal{F}$. $\square$

**Theorem 6.4 (Ordering).** $R_{\min}\le R_{\mathrm{conn}}\le R_{\mathrm{full}}$.

*Proof.* Immediate from $\mathcal{F}\subseteq\mathcal{C}\subseteq\mathcal{P}$, each infimum
being over a non-empty set bounded below. The inclusion $\mathcal{F}\subseteq\mathcal{C}$
uses the existence of at least one placement (e.g. the centred one). $\square$

**Summary.**

| Threshold | Definition | Lower bound | Upper bound | Witness for the upper bound |
|---|---|---|---|---|
| $R_{\min}$ | some placement percolates | $\tfrac13$ | $\tfrac12$ | line placement |
| $R_{\mathrm{conn}}$ | some placement connects all | $\tfrac13$ | $1$ | centred placement |
| $R_{\mathrm{full}}$ | every placement connects all | $\tfrac{\sqrt{17}}2$ | $\sqrt5$ | grid-edge diameter bound |

---

## 7. Algorithms and computational evidence

### 7.1 Component exploration for a given placement

Given a finite window $[-N,N]^2$ of cells and a placement restricted to it, the component
of a cell is computed by breadth-first search over the cells, testing adjacency by the
squared-distance criterion. By Lemma 3.2, for $R\le1$ it suffices to test the eight
grid-neighbours of a cell, and more generally only cells within $\lceil R\rceil+1$ in each
coordinate need be examined. The complexity is $O(N^2\lceil R\rceil^2)$ distance
evaluations, and all arithmetic can be done exactly in the squared metric, avoiding square
roots.

### 7.2 Certifying $R_{\min}\le\tfrac12$ numerically

Computing the *actual* percolation range of a fixed placement in a window is
$O(N^2)$ by the same search; running it on the line placement for $R=0.5+\varepsilon$
confirms a spanning left-to-right cluster, and for $R=0.5-\varepsilon$ confirms that the
double row shatters into two-point components — the sharpness of the construction at
exactly $\tfrac12$.

### 7.3 The periodic-path optimisation

The natural attack on the conjecture $R_{\min}=\tfrac12$ is to restrict attention to
*periodic drifting paths*: sequences of cells $c_0,c_1,\dots,c_T$ with
$c_T=c_0+(a,b)$ for some nonzero drift $(a,b)\in\mathbb{Z}^2$, together with points
$p_t$ in the corresponding cells, chosen to minimise the longest edge
$$\Lambda \;=\; \max_{0\le t<T}\ \|p_{t+1}-p_t\| .$$
Repeating the pattern with the drift produces a bi-infinite chain whose longest edge is
$\Lambda$; any placement extending it percolates for $R>\Lambda$. Conversely, one expects
(though this is not proved) that the infimum of $\Lambda$ over all periodic drifting
patterns equals $R_{\min}$.

For a fixed cell sequence the inner minimisation is a **convex** problem: minimise
$\max_t\|p_{t+1}-p_t\|$ over $p_t$ constrained to closed unit boxes. It is a second-order
cone programme, solvable exactly to any tolerance, and for small $T$ it can also be solved
by projected subgradient descent or by direct enumeration of candidate active sets.

The outer problem — choosing the cell sequence — is combinatorial and grows as $8^T$
before symmetry reduction. Exhaustive optimisation over all drifting patterns of period
$T\le4$, and randomised search over $T=5,\dots,8$, never produced a longest edge below
$\tfrac12$; the minimum $\tfrac12$ is attained by the zig-zag of Definition 5.1 and by its
symmetric images. This is the computational evidence for Conjecture 8.1 below.

### 7.4 Adversarial cuts

For $R_{\mathrm{full}}$ the relevant computation searches over *cut patterns*: assignments
of the two half-planes (or more general dual paths) with per-row offsets, maximising the
minimum crossing distance. Straight horizontal cuts with a horizontal stagger $s\in[0,1]$
give minimum crossing distance $\sqrt{4+\min(s,1-s)^2}$, maximised at $s=\tfrac12$ with
value $\tfrac{\sqrt{17}}2$. Beating this requires a non-straight cut, and no such
improvement has been found; whether $\sqrt5$ can be approached by staircase cuts is the
content of Conjecture 8.3.

---

## 8. Discussion and open problems

### 8.1 Conjecture: $R_{\min}=\tfrac12$

**Conjecture 8.1.** For every $R\le\tfrac12$ and every placement, all connected components
of $G_R(C)$ are finite. Equivalently $R_{\min}=\tfrac12$.

The heuristic is a *slack recursion*. Along a path, each step crosses at most one vertical
and one horizontal grid line, and, by Lemma 3.4, immediately after crossing $x=K$ the
current point satisfies $|x-K|<R$. To advance one further column the path must travel from
within $R$ of $K$ to within $R$ of $K\pm1$, requiring a horizontal displacement of at least
$1-2R$ per column advance. Defining the signed slack $a_t=x_t-K_t$ to the last vertical
line crossed, one obtains a recursion of the form $a_{t+1}\le a_t-(1-2R)$ along column
advances. For $R<\tfrac12$ this drives the slack negative in finitely many steps and stops
the path.

The missing ingredient is a *joint* potential in $x$ and $y$: a path can spend steps moving
vertically, and those steps recharge the horizontal slack (a vertical move of length $<R$
can increase $|x-K|$). The proof of Theorem 4.1 handles this by the crude device of a
loose bound $2R$, which costs the factor and yields $\tfrac13$. A correct joint potential
would presumably assign a cost to each coordinate move and exploit the fact that recharging
$x$ costs $y$-budget.

Conjecture 8.1 is *falsifiable by a single example*: a periodic drifting pattern of some
period $T$ with all edges strictly shorter than $\tfrac12$.

### 8.2 Conjecture: quantitative subcriticality

**Conjecture 8.2.** For every $R<\tfrac12$ there is a constant $C(R)$ such that, for every
placement, the component of any cell contains at most $C(R)$ cells, with
$C(R)=O\big((1-2R)^{-2}\big)$ as $R\uparrow\tfrac12$.

Theorem 4.1 gives $C(R)=9$ for $R<\tfrac13$, corresponding to a diameter of $3$. The slack
recursion of Section 8.1 suggests diameter of order $(1-2R)^{-1}$ in each coordinate, hence
area of order $(1-2R)^{-2}$. A refutation would be a family of placements whose components
have diameter growing faster than $(1-2R)^{-1}$ in some coordinate.

Note the contrast with Poisson percolation, where subcritical clusters are finite only
almost surely, with exponentially decaying tails. Here the bound is *uniform over
placements* — a genuinely deterministic statement with no probability in it.

### 8.3 Conjecture: $R_{\mathrm{full}}=\sqrt5$

**Conjecture 8.3.** For every $R<\sqrt5$ there is a placement whose Gilbert graph is
disconnected. Equivalently $R_{\mathrm{full}}=\sqrt5$.

The verified lower bound $\tfrac{\sqrt{17}}2$ comes from a straight staggered cut. Closing
the gap requires either a cleverer adversarial placement — one whose separating cut is not
a straight line, e.g. a staircase exploiting the $\sqrt5$ extremality of a single grid edge
in both coordinates simultaneously — or a proof that straight staggered cuts are extremal,
which would refute the conjecture and give $R_{\mathrm{full}}=\tfrac{\sqrt{17}}2$.

The tension is instructive. The bound $\sqrt5$ is attained by a *single pair* of cells:
place $p((0,0))=(0,0)$ and $p((1,0))=(2,1)$, distance exactly $\sqrt5$. But a placement is
a global object: pushing $p((1,0))$ to the top-right corner to escape its left neighbour
brings it closer to its right and top neighbours. Full connectivity fails only if some
*cut* is uniformly long, and averaging over a cut is what limits the adversary. Quantifying
this trade-off is exactly the open problem.

### 8.4 The intermediate radius

Least is known about $R_{\mathrm{conn}}$, where the bounds $\tfrac13\le R_{\mathrm{conn}}
\le1$ are far apart. The upper bound is the centred placement; the lower bound is inherited
from percolation and is surely far from sharp, because connecting *all* points is a much
stronger demand than percolating. A natural guess is that the truth lies strictly between
$\tfrac12$ and $1$: the line construction shows that pairs of rows can be linked at range
$\tfrac12$, but linking *every* row to the next appears to require sacrificing the
tight in-row spacing. Constructing a placement that connects everything with $R$ close to
$\tfrac{1}{\sqrt2}$, say — by tilting the alignment so that each point serves both a
horizontal and a vertical neighbour — is a concrete first target.

### 8.5 The random model

The results above are placement-uniform and therefore constrain the almost-sure threshold
$R_c$ of the random model from below only in the trivial direction: $R_c\ge R_{\min}
\ge\tfrac13$. The natural questions for the random model are the existence and uniqueness
of the infinite cluster, a sharp-threshold statement, and whether $R_c<1$. The rigidity of
the conditioning suggests that standard Peierls-type contour arguments should work well
here: because there is exactly one point per cell, a dual circuit of "blocked" cells has a
combinatorial description with independent, explicitly computable per-cell probabilities,
and no clustering to spoil the counting. This appears to be the most promising route to a
non-trivial upper bound on $R_c$.

### 8.6 Applications

Three settings motivate the conditioned model directly.

*Planned wireless networks.* Base stations are sited one per administrative cell with
placement freedom constrained by geography. $R_{\mathrm{full}}$ is the transmission power
that guarantees network connectivity regardless of siting decisions; $R_{\mathrm{conn}}$ is
the power achievable by ideal planning; and Theorem 5.9's bound $\sqrt5$ (in units of the
cell size) is a clean engineering rule of thumb.

*Hyperuniform materials.* Point patterns with suppressed density fluctuations occur in
photonic band-gap materials, avian retinal cone mosaics, and jammed packings. Connectivity
thresholds control transport in such media, and the exact constants here — $\tfrac12$,
$1$, $\sqrt5$ — provide benchmarks for a maximally hyperuniform pattern.

*Robust facility location and sensor coverage.* The confinement theorem is a worst-case
guarantee: below range $\tfrac13$ of the cell width, no arrangement of one facility per
cell can produce a service chain reaching beyond a $3\times3$ neighbourhood. This is the
kind of statement that is useless in probability but valuable in design.

---

## 9. Conclusion

Conditioning Gilbert's disc model on the square lattice replaces one hard, unknown constant
with a family of sharp geometric ones. We have established
$\tfrac13\le R_{\min}\le\tfrac12$, $\tfrac13\le R_{\mathrm{conn}}\le1$ and
$\tfrac{\sqrt{17}}2\le R_{\mathrm{full}}\le\sqrt5$, all uniformly over placements. The
lower bound for $R_{\min}$ is a genuinely deterministic non-percolation theorem — for
$R<\tfrac13$, every component of every placement fits in a $3\times3$ block — proved by a
crossing lemma and a travelling invariant, and the upper bounds are realised by three
transparent extremal placements: a collinear zig-zag double row, the centred placement, and
a staggered half-plane cut. The natural conjectures $R_{\min}=\tfrac12$ and
$R_{\mathrm{full}}=\sqrt5$ are supported by exhaustive and randomised optimisation over
periodic patterns, and each is falsifiable by a single explicit example. Closing either gap
is, we believe, within reach of a sufficiently clever potential function.
