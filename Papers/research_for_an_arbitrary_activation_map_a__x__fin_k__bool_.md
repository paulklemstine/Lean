# Feasible Activation Cells and Exact Affine Semantics of Shallow ReLU Networks

**Aristotle**  
**July 28, 2026**

## Abstract

A scalar-output, one-hidden-layer rectified linear unit network is globally nonlinear but locally governed by finitely many affine formulas. This paper develops that statement from first principles with careful treatment of activation boundaries. For $k$ hidden neurons acting on $\mathbb{R}^n$, a Boolean pattern prescribes a mixed system of strict and weak affine inequalities: active neurons require positive preactivation, while inactive neurons require nonpositive preactivation. We prove that the activation cell of a pattern is nonempty exactly when this inequality system is feasible. For every fixed pattern we define an explicit selected affine formula and prove that the network output equals it at every point of the corresponding cell. We then prove that the selected formula preserves arbitrary affine combinations and deduce the same identity for the network whenever the relevant points remain in one cell. The cells are convex, so this condition is automatic for interpolation between two points in a common cell. We give algorithms for pattern evaluation, feasibility testing, and extraction of local affine coefficients; discuss boundary behavior, complexity, and degeneracy; and present applications to interpretation, robustness, optimization, and exact regional analysis.

## 1. Introduction

Rectified linear units are among the simplest nonlinear gates used in neural networks. The scalar function

$$
\operatorname{ReLU}(z)=\max\{z,0\}
$$

has only two branches: the identity on positive inputs and zero on nonpositive inputs. Nevertheless, combining many such gates produces rich global behavior. The source of that behavior is combinatorial. Each hidden neuron selects a branch, and the joint selection depends on the input.

For a shallow network, every branch condition is an affine inequality in the original input. A joint branch selection therefore describes an intersection of half-spaces. On that intersection, every gate can be replaced by its selected branch, leaving an affine expression. This familiar intuition deserves a precise statement because several subtleties matter.

First, not every one of the $2^k$ formal activation patterns need occur. A pattern is realizable only if all of its affine sign constraints can hold simultaneously. Second, strict positivity is not interchangeable with nonnegativity: the convention at zero determines which cell owns a boundary point. Third, an affine identity for the network holds only while the participating points share the same branch selection. Finally, activation cells and maximal regions on which the total output happens to be affine need not coincide: adjacent activation cells may carry identical formulas because of zero output weights, cancellation, or redundant neurons.

This paper isolates the exact conclusions that follow without genericity assumptions. Its main contributions are:

1. a feasibility characterization of activation cells by mixed strict and weak affine inequalities;
2. an explicit affine formula selected by each pattern;
3. an exact equality between the network and that formula on the pattern’s cell;
4. an affine-combination identity for each selected formula and for the network within a cell;
5. constructive algorithms for computing patterns, local coefficients, and numerical certificates of the identities.

The treatment is finite-dimensional and self-contained. No assumption of general position, distinct hyperplanes, nonzero output weights, or feasibility of every pattern is imposed.

## 2. Network model and activation semantics

Let $n,k\in\mathbb{N}$. Inputs are vectors $x=(x_1,\ldots,x_n)\in\mathbb{R}^n$. A hidden layer contains $k$ neurons. For each neuron $j\in\{1,\ldots,k\}$, let $w_j=(w_{j1},\ldots,w_{jn})\in\mathbb{R}^n$ be its weight vector and $b_j\in\mathbb{R}$ its bias.

### Definition 2.1 (Affine preactivation)

The preactivation of hidden neuron $j$ at input $x$ is

$$
z_j(x)=w_j\cdot x+b_j
       =\sum_{i=1}^{n}w_{ji}x_i+b_j.
$$

### Definition 2.2 (Activation pattern)

The activation pattern of $x$ is the Boolean vector $p(x)\in\{0,1\}^k$ whose coordinates are

$$
p_j(x)=
\begin{cases}
1,&0<z_j(x),\\
0,&z_j(x)\le 0.
\end{cases}
$$

Thus zero is assigned to the inactive branch. The strict-positive convention makes $p(x)$ single-valued on every hyperplane $z_j(x)=0$.

### Definition 2.3 (Activation cell)

For a formal pattern $p=(p_1,\ldots,p_k)\in\{0,1\}^k$, its activation cell is

$$
C_p=\{x\in\mathbb{R}^n:p(x)=p\}.
$$

A pattern is called **feasible** if $C_p\ne\varnothing$. The family of nonempty cells partitions $\mathbb{R}^n$: every input has one pattern, and distinct patterns cannot label the same input. Empty cells correspond to formal bit vectors that the geometry cannot realize.

### Definition 2.4 (Pattern inequality system)

Given $p\in\{0,1\}^k$, the associated system at an unknown $x\in\mathbb{R}^n$ is

$$
\mathcal{I}_p(x):\quad
\begin{cases}
z_j(x)>0,&p_j=1,\\
z_j(x)\le0,&p_j=0,
\end{cases}
\qquad j=1,\ldots,k.
$$

This is a mixed strict/weak affine feasibility problem. It records not only which side of each hyperplane is chosen but also which side owns the hyperplane itself.

### Definition 2.5 (Network output)

Let $v=(v_1,\ldots,v_k)\in\mathbb{R}^k$ be the output weights and $c\in\mathbb{R}$ the output bias. The scalar network output is

$$
F(x)=\sum_{j=1}^{k}v_j\operatorname{ReLU}(z_j(x))+c.
$$

### Definition 2.6 (Selected affine formula)

For a fixed pattern $p$, define

$$
A_p(x)=\sum_{j=1}^{k}
\begin{cases}
v_jz_j(x),&p_j=1,\\
0,&p_j=0,
\end{cases}
+c.
$$

Equivalently, writing $S_p=\{j:p_j=1\}$,

$$
A_p(x)=\sum_{j\in S_p}v_j(w_j\cdot x+b_j)+c.
$$

Collecting coefficients gives

$$
A_p(x)=g_p\cdot x+d_p,
$$

where

$$
g_p=\sum_{j\in S_p}v_jw_j,
\qquad
d_p=c+\sum_{j\in S_p}v_jb_j.
$$

The vector $g_p$ is the exact slope selected by $p$, and $d_p$ is its intercept.

## 3. Feasibility and geometry of activation cells

We first identify the geometric content of a Boolean pattern.

### Theorem 3.1 (Activation-cell feasibility)

For every pattern $p\in\{0,1\}^k$, the activation cell $C_p$ is nonempty if and only if the associated system $\mathcal{I}_p(x)$ has a solution. Explicitly,

$$
C_p\ne\varnothing
\quad\Longleftrightarrow\quad
\exists x\in\mathbb{R}^n\ \forall j,
\begin{cases}
z_j(x)>0,&p_j=1,\\
z_j(x)\le0,&p_j=0.
\end{cases}
$$

#### Proof sketch

Suppose $C_p$ is nonempty and choose $x\in C_p$. Equality $p(x)=p$ holds coordinatewise. If $p_j=1$, the definition of the activation bit gives $z_j(x)>0$; if $p_j=0$, it gives $z_j(x)\le0$. Hence $x$ solves $\mathcal{I}_p$.

Conversely, suppose $x$ solves $\mathcal{I}_p$. For every coordinate $j$, the prescribed inequality forces the activation test at $x$ to return $p_j$. Thus $p(x)=p$, so $x\in C_p$ and the cell is nonempty. $\square$

This theorem turns pattern realization into a standard geometric question. It also immediately identifies the shape of a cell.

### Proposition 3.2 (Half-space representation and convexity)

For every pattern $p$,

$$
C_p=
\bigcap_{j:p_j=1}\{x:z_j(x)>0\}
\ \cap\!
\bigcap_{j:p_j=0}\{x:z_j(x)\le0\}.
$$

Consequently, $C_p$ is convex, although it need be neither open nor closed.

#### Proof sketch

The displayed equality is the coordinatewise expansion of $p(x)=p$. Each set $\{x:z_j(x)>0\}$ is an open affine half-space, and each set $\{x:z_j(x)\le0\}$ is a closed affine half-space. Both are convex, and intersections of convex sets are convex. Mixed strict and weak constraints explain why the resulting set can be half-open. $\square$

A direct interpolation argument is useful later. If $x,y\in C_p$ and $0\le t\le1$, then

$$
z_j(tx+(1-t)y)=tz_j(x)+(1-t)z_j(y).
$$

For an active coordinate, both endpoint values are positive, so the combination is positive. For an inactive coordinate, both are nonpositive, so the combination is nonpositive. Therefore $tx+(1-t)y\in C_p$.

### Remark 3.3 (Formal patterns versus feasible patterns)

There are exactly $2^k$ Boolean vectors in $\{0,1\}^k$, so the number of feasible cells is at most $2^k$. Equality is not automatic. For example, in one dimension let

$$
z_1(x)=x+1,
\qquad z_2(x)=-x+2.
$$

The pattern $(0,0)$ would require $x\le-1$ and $x\ge2$, which is impossible. Feasibility is therefore an essential qualifier whenever activation patterns are counted.

## 4. Exact affine semantics on a cell

The central result replaces every ReLU by the branch selected by the cell.

### Theorem 4.1 (Cellwise affine representation)

Let $p\in\{0,1\}^k$. For every $x\in C_p$,

$$
F(x)=A_p(x)=g_p\cdot x+d_p.
$$

#### Proof sketch

Fix $x\in C_p$. If $p_j=1$, then $z_j(x)>0$ and

$$
\operatorname{ReLU}(z_j(x))=z_j(x).
$$

If $p_j=0$, then $z_j(x)\le0$ and

$$
\operatorname{ReLU}(z_j(x))=0.
$$

Therefore each summand $v_j\operatorname{ReLU}(z_j(x))$ equals the corresponding selected summand in $A_p(x)$. Summing over $j$ and adding $c$ proves the identity. Expanding the active preactivations and collecting coefficients gives $g_p\cdot x+d_p$. $\square$

### Corollary 4.2 (Exact local slope)

On every nonempty activation cell $C_p$, the network has the constant affine slope

$$
g_p=\sum_{j:p_j=1}v_jw_j.
$$

At every interior point of $C_p$, the gradient of $F$ exists and equals $g_p$.

#### Proof sketch

Theorem 4.1 identifies $F$ with the affine function $x\mapsto g_p\cdot x+d_p$ throughout the cell. On the interior there is an open neighborhood on which this identity holds, so ordinary differentiation yields $\nabla F=g_p$. Boundary points may fail to be differentiable because an adjacent cell can have a different slope. $\square$

### Remark 4.3 (Cells need not be maximal affine regions)

The theorem states that every activation cell carries an affine formula. It does not state that distinct cells always carry distinct formulas or that each cell is maximal. If $v_j=0$, switching neuron $j$ changes the pattern but not the output formula. Distinct active sets can also yield the same $g_p$ and $d_p$ through cancellation. Thus activation cells provide a canonical branch partition, while maximal affine regions of the total function may be coarser.

## 5. Affine combinations

The selected formula satisfies the defining algebraic law of an affine map.

### Theorem 5.1 (Affinity of the selected formula)

For every pattern $p$, every $x,y\in\mathbb{R}^n$, and every $t\in\mathbb{R}$,

$$
A_p(tx+(1-t)y)=tA_p(x)+(1-t)A_p(y).
$$

#### Proof sketch

Each preactivation is affine, so

$$
z_j(tx+(1-t)y)=tz_j(x)+(1-t)z_j(y).
$$

For a fixed pattern, the decision to retain or discard the $j$th term is fixed and independent of $x$ and $y$. Multiplying retained terms by $v_j$ and summing preserves the affine-combination identity. Finally,

$$
tc+(1-t)c=c,
$$

so the output bias has the required behavior. Equivalently, substitute $A_p(u)=g_p\cdot u+d_p$ and distribute. $\square$

The parameter $t$ is unrestricted. For $0\le t\le1$, the input is an interpolation; outside that interval, it is an extrapolation.

### Theorem 5.2 (Network affinity within one activation cell)

Let $p\in\{0,1\}^k$, $x,y\in\mathbb{R}^n$, and $t\in\mathbb{R}$. If

$$
x\in C_p,
\qquad y\in C_p,
\qquad tx+(1-t)y\in C_p,
$$

then

$$
F(tx+(1-t)y)=tF(x)+(1-t)F(y).
$$

#### Proof sketch

Apply Theorem 4.1 at the three points to replace $F$ by $A_p$. The desired equation then becomes exactly Theorem 5.1. $\square$

### Corollary 5.3 (Exact interpolation on a cell)

If $x,y\in C_p$ and $0\le t\le1$, then

$$
F(tx+(1-t)y)=tF(x)+(1-t)F(y).
$$

#### Proof sketch

Proposition 3.2 gives convexity of $C_p$, so the interpolated point remains in the cell. Theorem 5.2 then applies. $\square$

For extrapolation, the third membership condition in Theorem 5.2 is indispensable: a ray can cross an activation hyperplane and select a different affine formula.

## 6. Boundary behavior

The use of $z_j(x)>0$ for activity assigns $z_j(x)=0$ to the inactive branch. This convention affects cell labels but not the numerical value of the network at the boundary, because

$$
\operatorname{ReLU}(0)=0.
$$

Suppose two patterns differ only in coordinate $j$, and consider a boundary point with $z_j(x)=0$. The two selected formulas differ by the term $v_jz_j(x)$, which vanishes at that point. Hence their values agree there. More generally, if several neurons switch on a common boundary, every switching contribution vanishes. This explains the continuity of a shallow ReLU network across activation boundaries.

The gradients need not agree. Crossing the $j$th hyperplane changes the selected slope by $v_jw_j$, possibly together with changes from other neurons. The function is therefore continuous and piecewise affine but generally nonsmooth.

Strict inequalities also create a numerical issue in feasibility testing. A solver that accepts only non-strict inequalities can introduce a margin variable $\delta$ and solve

$$
\max\ \delta
$$

subject to

$$
z_j(x)\ge\delta\quad(p_j=1),
\qquad
z_j(x)\le0\quad(p_j=0),
\qquad
\delta\le1.
$$

The upper bound merely prevents unbounded scaling of the objective. The original mixed system is feasible exactly when the optimal margin is positive. If there are no active coordinates, no strict constraint exists and ordinary weak feasibility suffices.

## 7. Algorithms

### 7.1 Pattern evaluation

Given $W=(w_{ji})\in\mathbb{R}^{k\times n}$, $b\in\mathbb{R}^k$, and $x\in\mathbb{R}^n$, compute $z=Wx+b$ and return the bits $p_j=1$ exactly when $z_j>0$. Dense evaluation costs $O(kn)$ arithmetic operations and $O(k)$ additional storage.

### 7.2 Selected affine coefficient extraction

Given a pattern $p$, initialize $g=0\in\mathbb{R}^n$ and $d=c$. For every active index $j$, update

$$
g\leftarrow g+v_jw_j,
\qquad d\leftarrow d+v_jb_j.
$$

The resulting formula $g\cdot x+d$ equals the network on $C_p$. Dense worst-case time is $O(kn)$ and storage is $O(n)$. With $s$ active neurons and sparse rows, the cost can be reduced to the number of active nonzero weights.

### 7.3 Feasibility testing

For a proposed pattern, construct its $k$ inequalities and solve the strict-feasibility problem, for example through the margin formulation above. Polynomial-time linear-programming methods apply in standard computational models. Enumerating all formal patterns and testing each one has an unavoidable worst-case factor $2^k$, though geometric adjacency searches, arrangement methods, and branch-and-bound can avoid examining many patterns in practice.

### 7.4 Identity checking on sampled points

For numerical demonstration, one may compute both $F(x)$ and $A_{p(x)}(x)$ and compare them within floating-point tolerance. For two points with a common pattern, sample $t\in[0,1]$, evaluate the interpolated point, and compare

$$
F(tx+(1-t)y)
$$

with

$$
tF(x)+(1-t)F(y).
$$

Such computations illustrate the exact theorems but should account for roundoff near activation boundaries.

## 8. Worked examples

### Example 8.1 (One-dimensional three-piece network)

Let

$$
z_1(x)=x+1,
\qquad z_2(x)=-x+2,
$$

and choose $v_1=2$, $v_2=-1$, and $c=\tfrac12$. Then

$$
F(x)=2\operatorname{ReLU}(x+1)-\operatorname{ReLU}(-x+2)+\tfrac12.
$$

For $x\le-1$, the activation pattern is $(0,1)$ and

$$
F(x)=-(-x+2)+\tfrac12=x-\tfrac32.
$$

For $-1<x<2$, both units are active and

$$
F(x)=2(x+1)-(-x+2)+\tfrac12=3x+\tfrac12.
$$

For $x>2$, the pattern is $(1,0)$ and

$$
F(x)=2(x+1)+\tfrac12=2x+\tfrac52.
$$

At $x=-1$, the first neuron is inactive by convention; at $x=2$, the second is inactive. The adjacent formulas agree at each boundary. The pattern $(0,0)$ is infeasible because it requires $x\le-1$ and $x\ge2$ simultaneously.

### Example 8.2 (Two-dimensional local coefficients)

Take

$$
w_1=(1,1),\quad b_1=-1,
\qquad
w_2=(-1,2),\quad b_2=0,
$$

with $v_1=3$, $v_2=-2$, and $c=1$. On the pattern $p=(1,0)$, the selected coefficients are

$$
g_p=3(1,1)=(3,3),
\qquad
d_p=1+3(-1)=-2.
$$

Hence $F(x_1,x_2)=3x_1+3x_2-2$ throughout the cell defined by

$$
x_1+x_2-1>0,
\qquad -x_1+2x_2\le0.
$$

Any two points satisfying these inequalities can be interpolated without changing the formula.

## 9. Applications

### 9.1 Exact local interpretation

For an input $x$, compute its pattern $p(x)$ and coefficients $(g_p,d_p)$. The equation

$$
F(u)=g_p\cdot u+d_p
$$

is then exact for every $u$ in the same cell, not merely a first-order approximation at $x$. The contribution of hidden neuron $j$ appears precisely when it is active, and the local sensitivity to input coordinate $i$ is the $i$th component of $g_p$.

### 9.2 Robustness and stable explanations

The activation pattern remains unchanged while every preactivation stays on its prescribed side of zero. For a norm $\|\cdot\|$ with dual norm $\|\cdot\|_*$, the distance from $x$ to the hyperplane $z_j=0$ is governed by

$$
\frac{|z_j(x)|}{\|w_j\|_*}
$$

when $w_j\ne0$. The smallest such distance gives a natural local scale below which no activation boundary is crossed, subject to the chosen perturbation norm. Within that stable neighborhood, both the output formula and its explanation remain unchanged.

### 9.3 Regional optimization

On a fixed cell, optimizing the network output is optimizing an affine function under affine inequalities. Additional linear constraints preserve linear-program structure. Quadratic penalties lead to quadratic programs. Global optimization can therefore be organized as a search across feasible patterns coupled with tractable within-cell subproblems.

### 9.4 Verification and reachability

To establish an output bound over an input domain, intersect that domain with each relevant activation cell and optimize the selected affine formula. Feasibility tests discard empty intersections. This patternwise decomposition is exact for a one-hidden-layer network and clarifies where combinatorial complexity enters.

### 9.5 Geometry-aware compression

If two feasible neighboring patterns select the same pair $(g_p,d_p)$, their cells can be merged for the purpose of representing the output function. This suggests compression schemes that distinguish branch-level complexity from function-level complexity.

## 10. Discussion and limitations

The results require no genericity assumptions and therefore remain valid under repeated neurons, zero weights, coincident hyperplanes, and cancellations. That generality also limits what may be concluded. The number of feasible patterns can be far below $2^k$. Activation cells need not be maximal affine regions. Distinct patterns need not induce distinct outputs or gradients.

The analysis concerns one hidden layer. In deeper ReLU networks, preactivations in later layers are not globally affine functions of the original input. They are piecewise affine relative to the partition created by earlier layers. The same branch-freezing principle remains applicable, but its geometric organization becomes inductive: first fix earlier patterns, then express later preactivations affinely on the resulting cells, and refine the partition.

The scalar-output restriction is inessential at the conceptual level. For a vector output, each output coordinate has its own output weights, while the hidden pattern is shared. The selected formula becomes an affine map into a vector space. Establishing the full matrix-valued version and its boundary relations is a natural extension.

Finally, numerical computation near $z_j(x)=0$ requires care. Floating-point tolerances may assign a point to a pattern different from the exact strict-positive convention. Reliable software should report margins, detect near-boundary inputs, and distinguish mathematical equality from tolerance-based classification.

## 11. Future work

Several directions follow directly from the present framework:

1. Generalize the scalar-output theorem to vector-valued output layers.
2. Package each selected formula as an affine map and prove continuity across adjacent cell boundaries.
3. Add explicit genericity assumptions and relate feasible activation cells to maximal linear regions.
4. Establish sharper hyperplane-arrangement region bounds in fixed input dimension.
5. Extend the argument inductively to deep ReLU networks, whose preactivations are piecewise affine relative to earlier-layer cells.

Further computational work could develop output-sensitive enumeration of feasible cells, adjacency graphs for traversing the activation mosaic, and certified margin calculations for robust pattern membership.

## 12. Conclusion

A shallow ReLU network admits an exact two-level semantics. At the discrete level, a Boolean pattern records which preactivations are strictly positive. At the geometric level, that pattern describes a mixed system of affine inequalities. The system is feasible exactly when its activation cell is nonempty. Once a feasible pattern is fixed, the network equals an explicit affine formula obtained by retaining active preactivations and discarding inactive ones.

This formula preserves arbitrary affine combinations. Consequently, the network itself preserves affine combinations whenever the relevant points stay in one activation cell; convexity makes this automatic for interpolation between points in a common cell. These results provide a precise foundation for regional interpretation, robustness, optimization, and verification. The network’s nonlinearity lies not within each cell, but in the finite geometric mosaic that determines when one affine formula gives way to another.
