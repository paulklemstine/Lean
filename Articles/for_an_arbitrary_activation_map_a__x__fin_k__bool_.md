# The Hidden Mosaic Inside a ReLU Network

A neural network can look smooth from a distance. Feed it a photograph, a sensor reading, or a point in space, and a number comes out. Yet inside one of the most common architectures, the computation is governed by a crisp geometric switchboard. Every hidden unit asks a yes-or-no question. Together, those answers divide the input world into cells, and within each cell the apparently nonlinear network becomes nothing more mysterious than an affine formula.

That observation is simple to state, but it gives a remarkably precise way to understand what a one-hidden-layer rectified linear unit network is doing. It connects neural computation to systems of linear inequalities, convex geometry, exact local explanation, and efficient evaluation.

## The switchboard

Consider an input vector $x\in\mathbb{R}^n$ and $k$ hidden neurons. Neuron $j$ first computes an affine preactivation

$$
z_j(x)=\sum_{i=1}^{n}w_{ji}x_i+b_j.
$$

It then applies the rectified linear unit, or ReLU,

$$
\operatorname{ReLU}(z)=\max\{z,0\}.
$$

Positive signals pass unchanged; zero and negative signals are replaced by zero. If the output weights are $v_1,\ldots,v_k$ and the output bias is $c$, the network output is

$$
F(x)=\sum_{j=1}^{k}v_j\operatorname{ReLU}(z_j(x))+c.
$$

Each neuron therefore carries a Boolean status. It is **active** when $z_j(x)>0$ and **inactive** when $z_j(x)\le 0$. The activation pattern at $x$ is the $k$-bit vector

$$
p(x)=(p_1(x),\ldots,p_k(x)),\qquad
p_j(x)=
\begin{cases}
1,&z_j(x)>0,\\
0,&z_j(x)\le 0.
\end{cases}
$$

At first glance there are $2^k$ possible patterns. But “possible to write down” does not mean “geometrically realizable.” The same input must satisfy all $k$ sign conditions at once. Correlated neurons, repeated hyperplanes, and contradictory inequalities can make many patterns impossible.

For a fixed bit pattern $p\in\{0,1\}^k$, define its activation cell by

$$
C_p=\{x\in\mathbb{R}^n:p(x)=p\}.
$$

The cells form the hidden mosaic of the network. Some tiles may be empty. Every actual input lies in exactly one nonempty tile.

## A pattern is a system of inequalities

The first key result says exactly how to decide whether a proposed tile exists.

**Activation-Cell Feasibility Theorem.** The cell $C_p$ is nonempty if and only if there is an $x\in\mathbb{R}^n$ satisfying, for every hidden neuron $j$,

$$
\begin{cases}
z_j(x)>0,&p_j=1,\\
z_j(x)\le 0,&p_j=0.
\end{cases}
$$

The theorem may sound tautological, but it is the bridge from a neural description to a geometric and computational one. A bit string becomes a mixed system of strict and weak affine inequalities. Feasibility can then be studied with the tools of convex geometry and linear optimization.

Why the asymmetry between $>0$ and $\le 0$? It records the chosen convention at the ReLU kink: a neuron is active only under strict positivity. A point on the hyperplane $z_j(x)=0$ belongs to the inactive side. That convention makes every input receive one unambiguous pattern.

The proof follows the definitions in both directions. If $x$ lies in $C_p$, its activation bits are precisely $p$, so each requested inequality holds. Conversely, if all the inequalities hold, every neuron has the status prescribed by $p$, hence $x\in C_p$.

There is more geometry hiding here. Each condition $z_j(x)>0$ is an open half-space, while each condition $z_j(x)\le 0$ is a closed half-space. Their intersection is convex, even though it may include some boundary faces and exclude others. Thus every activation cell is convex. A straight line segment between two points in one cell stays in that cell: affine preactivations interpolate linearly, preserving strict positivity on active coordinates and nonpositivity on inactive ones.

## Nonlinearity freezes into an affine map

Once the pattern is fixed, every ReLU branch is known. For a pattern $p$, define the selected formula

$$
A_p(x)=\sum_{j=1}^{k}
\begin{cases}
v_jz_j(x),&p_j=1,\\
0,&p_j=0,
\end{cases}
+c.
$$

Because each $z_j$ is affine, $A_p$ is affine. The network’s nonlinear gates have disappeared; the pattern has selected which affine terms survive.

**Cellwise Affine Representation Theorem.** If $x\in C_p$, then

$$
F(x)=A_p(x).
$$

The reason is local and exact. For an active neuron, $z_j(x)>0$, so $\operatorname{ReLU}(z_j(x))=z_j(x)$. For an inactive neuron, $z_j(x)\le 0$, so $\operatorname{ReLU}(z_j(x))=0$. Substituting these identities term by term turns $F$ into $A_p$.

Expanding the selected expression exposes its slope and intercept:

$$
A_p(x)=
\left(\sum_{j:p_j=1}v_jw_j\right)\!\cdot x
+\left(c+\sum_{j:p_j=1}v_jb_j\right),
$$

where $w_j$ is the input-weight vector of neuron $j$. The local gradient is therefore

$$
\nabla A_p=\sum_{j:p_j=1}v_jw_j.
$$

Every point in the same cell shares this exact local linear explanation. Crossing an activation boundary may add or remove one or more terms and thereby change the slope.

## The affine-combination law

An affine function is characterized by how it treats weighted combinations. For any real $t$ and any $x,y\in\mathbb{R}^n$, the selected formula obeys

$$
A_p(tx+(1-t)y)=tA_p(x)+(1-t)A_p(y).
$$

This is the **Selected-Formula Affinity Theorem**. It holds for every real $t$, not merely for $0\le t\le1$, because it is an algebraic identity. Each preactivation obeys the same law, multiplication by $v_j$ preserves it, and summation plus the output bias preserves it as well.

Combining this identity with the cellwise representation yields the operational result.

**Network Affinity on a Cell.** Suppose $x$, $y$, and $tx+(1-t)y$ all belong to the same activation cell $C_p$. Then

$$
F(tx+(1-t)y)=tF(x)+(1-t)F(y).
$$

For interpolation, where $0\le t\le1$, the third membership condition follows automatically from convexity of $C_p$. Thus along any segment contained in a cell, the output graph is exactly a straight line. The theorem is stated more generally because for extrapolation, with $t$ outside $[0,1]$, the combined point can leave the cell; in that case the ReLU branch selection may change.

## A small example

Take a one-dimensional network with two hidden units,

$$
z_1(x)=x+1,\qquad z_2(x)=-x+2,
$$

and output

$$
F(x)=2\operatorname{ReLU}(x+1)-\operatorname{ReLU}(-x+2)+\tfrac12.
$$

The switching points are $x=-1$ and $x=2$. On $x\le-1$, the pattern is $(0,1)$ and

$$
F(x)=x-\tfrac32.
$$

On $-1<x<2$, the pattern is $(1,1)$ and

$$
F(x)=3x+\tfrac12.
$$

On $x\ge2$, apart from the boundary convention at $x=2$, the active branches select

$$
F(x)=2x+\tfrac52.
$$

The network is globally continuous and piecewise affine, but its slope changes from $1$ to $3$ to $2$. At a boundary, the disappearing or appearing ReLU contribution is zero, which is why adjacent formulas agree there even though their derivatives need not.

This example also illustrates infeasibility. The pattern $(0,0)$ would require both $x+1\le0$ and $-x+2\le0$, or $x\le-1$ and $x\ge2$ simultaneously. No such input exists. Two neurons offer four formal bit strings, but only three are realized away from the boundary assignments.

## Why this geometry matters

The cell viewpoint makes exact local explanations possible. Once an input’s active neurons are known, the network near that input is summarized by a slope vector and an intercept. This is stronger than merely approximating the network by a tangent plane: inside the cell, the affine expression is exact.

It also sharpens robustness questions. How far can an input move before its explanation changes? The answer is controlled by distances to the hyperplanes $z_j(x)=0$. As long as perturbations stay on the prescribed side of every hyperplane, the pattern remains fixed and the same affine rule applies. Optimization within a fixed cell becomes linear or quadratic, depending on the objective, rather than generically nonlinear.

For verification and control, the mosaic separates two tasks. First enumerate or search for feasible patterns by solving inequality systems. Then analyze an affine formula on each feasible cell. This does not make the combinatorics disappear: there can still be many cells. But it exposes the precise source of complexity. The arithmetic within a cell is easy; the challenge lies in how cells fit together and which patterns are feasible.

The distinction also guards against a common overstatement. A network with $k$ hidden units does not necessarily carve space into $2^k$ nonempty regions. That number counts formal patterns, not realized geometry. In fixed dimension, hyperplane-arrangement bounds can be much smaller, and degeneracies can shrink the count further.

## From switches to structure

A ReLU network is nonlinear because its formula changes, not because each local formula is complicated. Its hidden neurons jointly choose a region; that region chooses an affine map. The Activation-Cell Feasibility Theorem tells us which choices correspond to actual inputs. The Cellwise Affine Representation Theorem tells us the exact formula on each choice. The affine-combination law tells us how the output behaves along every path that remains within one tile.

This picture suggests a broad research program: vector-valued outputs, exact continuity relations across neighboring cells, genericity conditions linking patterns to maximal linear regions, sharper counts in fixed dimension, and an inductive extension to deep networks. In deeper architectures the boundaries themselves become piecewise affine, but the central idea survives: freeze the switches, and the computation simplifies.

Behind the continuous-looking output lies a finite switchboard. Behind that switchboard lies a geometric mosaic. And on every tile of that mosaic, the network speaks the oldest language in applied mathematics: an affine equation.
