# When Neural Networks Become Tropical Geometry

## A second language for piecewise-linear intelligence

A modern neural network can contain millions of numerical parameters, yet one of its most important building blocks is almost childishly simple. The rectified linear unit, or ReLU, takes a real number $t$ and returns

$$
\operatorname{ReLU}(t)=\max\{t,0\}.
$$

Negative values are flattened to zero; nonnegative values pass through unchanged. Stack this operation between affine transformations, and the result is a feedforward ReLU network: a machine capable of carving high-dimensional space into polyhedral regions and assigning a different affine rule to each one.

There is another branch of mathematics whose native operation is also maximum. In max-plus tropical mathematics, ordinary addition remains addition, while the role ordinarily played by addition is taken by maximum. A tropical polynomial is consequently assembled from affine forms by repeatedly adding them, taking their maximum, and multiplying them by nonnegative scalars. Its graph is not smoothly curved. It is a convex, piecewise-affine landscape: a collection of planar facets meeting along ridges.

The shared appearance of $\max$ is more than a visual analogy. Every finite scalar-valued feedforward ReLU network can be translated, exactly and constructively, into the difference of two generalized max-plus tropical polynomials. The translation preserves the value at every input. Neural computation and tropical rational geometry are therefore two descriptions of the same function.

## The two kinds of object

Fix an input dimension $n$, and write an input as $x=(x_1,\ldots,x_n)\in\mathbb R^n$. Begin with affine forms

$$
A(x)=\sum_{i=1}^{n}a_i x_i+b.
$$

A generalized tropical polynomial is any function obtained from affine forms using three closure operations:

1. if $P$ and $Q$ are tropical polynomials, then $P+Q$ is one;
2. if $P$ and $Q$ are tropical polynomials, then $\max\{P,Q\}$ is one;
3. if $c\ge 0$ and $P$ is a tropical polynomial, then $cP$ is one.

Constants and the zero function are affine forms, so they are included automatically. This definition is deliberately broad enough to make the essential algebra transparent. The maximum of convex piecewise-affine functions is again convex and piecewise affine; sums and nonnegative rescalings preserve those properties as well.

A tropical rational function in subtractive form is a pair $(P,Q)$ representing

$$
R(x)=P(x)-Q(x).
$$

The word “rational” is an analogy with ordinary algebra: just as ordinary rational functions enlarge polynomials by allowing division, tropical rational functions enlarge tropical polynomials by allowing tropical division, which becomes ordinary subtraction in max-plus notation.

On the neural side, consider circuits built from three ingredients. An affine node computes $A(x)$. A finite linear-combination node takes earlier subnetworks $N_1,\ldots,N_m$ and computes

$$
\sum_{j=1}^{m}w_jN_j(x)+b,
$$

where the weights $w_j$ may have either sign. A ReLU node computes $\max\{N(x),0\}$. Any finite feedforward scalar ReLU computation can be unfolded into this form; sharing may make a directed acyclic graph more compact, but unfolding does not change its function.

## The identity that opens the door

Suppose a subnetwork has already been written as $R=P-Q$. Applying ReLU gives

$$
\max\{P-Q,0\}=\max\{P,Q\}-Q.
$$

This elementary identity is the hinge of the entire correspondence. To see it, consider two cases. If $P\ge Q$, then the left side is $P-Q$ and the right side is also $P-Q$. If $P\le Q$, both sides are zero. Thus a nonlinear gate is absorbed by replacing the numerator $P$ with $\max\{P,Q\}$ while leaving the denominator $Q$ untouched.

That unchanged denominator is a useful structural fact: applying a ReLU gate does not enlarge the denominator in this constructive representation. All of the gate’s new geometry is placed in the numerator.

The other operations also have exact pairwise rules. If $R=P-Q$ and $S=U-V$, then

$$
R+S=(P+U)-(Q+V).
$$

Adding a constant $b$ amounts to placing that constant in the numerator. Multiplication by a nonnegative number $c$ gives

$$
cR=(cP)-(cQ).
$$

A negative weight is the only apparent obstacle, because tropical polynomials permit nonnegative scaling. But subtraction already gives the solution. When $c<0$,

$$
c(P-Q)=(-c)Q-(-c)P.
$$

The two components simply exchange roles and are scaled by the nonnegative number $-c$. Signed neural weights therefore cause no loss of closure.

## The Tropical–Neural Representation Theorem

**Theorem.** For every finite scalar-valued feedforward ReLU network $N$ on $\mathbb R^n$, there exist generalized max-plus tropical polynomials $P$ and $Q$ such that

$$
N(x)=P(x)-Q(x)
$$

for every $x\in\mathbb R^n$.

The statement is stronger than a claim of approximation. No limiting process, training procedure, grid, or tolerance is involved. The equality holds pointwise on all of $\mathbb R^n$.

The proof follows the architecture of the network. An affine node starts as $(A,0)$. For a linear combination, translate every input subnetwork, scale each resulting pair using the sign-sensitive rule, add all pairs componentwise, and include the bias. For a ReLU node, replace $(P,Q)$ by $(\max\{P,Q\},Q)$. Structural induction guarantees that each translated pair evaluates to the same function as the corresponding subnetwork. At the output node, the desired $P$ and $Q$ are already present.

This process is best understood as a compiler between mathematical languages. It reads a finite computational tree and emits a pair of tropical expressions. Every translation rule is local, so the procedure is deterministic once the network syntax is fixed.

## A small network under the microscope

Consider the one-dimensional network

$$
N(x)=2\operatorname{ReLU}(x-1)-3\operatorname{ReLU}(-x-2)+\frac12.
$$

The first hidden unit satisfies

$$
\operatorname{ReLU}(x-1)=\max\{x-1,0\}-0.
$$

The second satisfies

$$
\operatorname{ReLU}(-x-2)=\max\{-x-2,0\}-0.
$$

The coefficient $2$ keeps the first term in the numerator. The coefficient $-3$ swaps the second pair, placing $3\max\{-x-2,0\}$ in the denominator. One valid representation is therefore

$$
P(x)=2\max\{x-1,0\}+\frac12,
$$

$$
Q(x)=3\max\{-x-2,0\},
$$

with $N=P-Q$. At $x=-3$, the values are $P(-3)=1/2$ and $Q(-3)=3$, so $P(-3)-Q(-3)=-5/2$, exactly matching the network. At $x=2$, they are $P(2)=5/2$ and $Q(2)=0$, again matching it.

This example also reveals the geometry. Breakpoints occur where affine competitors tie: here at $x=-2$ and $x=1$. Between those points, and outside them, the output is affine. In higher dimensions the breakpoints become polyhedral walls.

## Why the correspondence matters

The theorem gives neural networks a geometric coordinate system. A tropical polynomial is a convex piecewise-affine surface, and the network output is a difference of two such surfaces. Questions about activation patterns can therefore be reframed as questions about which affine facets dominate and where their ties occur.

This viewpoint may assist exact analysis. Instead of sampling a network at many points, one can manipulate its symbolic pair $(P,Q)$. Equality of evaluations is preserved at every construction step. The representation can expose linearity regions, support exact arithmetic when parameters are rational, and separate positive from negative influence through the numerator–denominator swap.

It also clarifies why ReLU networks are piecewise affine. Affine forms begin the construction; addition and nonnegative scaling preserve piecewise affinity; maximum joins pieces along polyhedral boundaries; subtraction combines two such landscapes. The familiar polyhedral behavior of ReLU models is not an accidental side effect of implementation. It is the visible geometry of tropical algebra.

There are practical caveats. Unfolding a network with shared nodes can duplicate expressions. Repeated maxima and sums may produce many affine terms, some dominated everywhere and therefore irrelevant. The representation theorem promises exact existence and supplies a direct construction, but it does not claim that the raw expression is minimal. Simplification, cancellation, and compact data structures are separate algorithmic questions.

## Beyond a change of notation

A useful mathematical translation should reveal something that was hard to see in the original language. Here the network diagram emphasizes information flow: values move through weighted edges and gates. The tropical pair emphasizes global shape: two convex polyhedral surfaces compete through subtraction. Neither description replaces the other. Training and implementation are naturally expressed by layers and parameters, while questions about facets, breakpoints, and linear regions may be clearer in the geometric picture.

The translation also distinguishes exact structure from statistical behavior. A trained network may have uncertain predictions or encounter unfamiliar data, but its computed function is nevertheless specified exactly by its parameters. The tropical representation concerns that deterministic function. It does not claim that the model is accurate, fair, robust, or well calibrated. Instead, it provides a precise object on which such questions can potentially be studied.

One can imagine tracing a decision boundary through the places where affine pieces exchange dominance, or checking whether a supposed breakpoint disappears because the numerator and denominator change in canceling ways. In low dimensions, the pair can even be plotted as two folded surfaces whose vertical separation is the network output. The network’s answer is then literally the gap between two polyhedral landscapes.

## A map for what comes next

Several natural problems emerge. Integer-weight networks should correspond to integer-slope tropical data, suggesting an arithmetic refinement in both directions. For layered networks, one would like depth-sensitive bounds on the number of affine terms and matching examples showing when exponential growth is unavoidable. A canonical normalization could remove globally dominated terms and perhaps identify a unique reduced pair under suitable genericity conditions.

The geometric side invites a sharper comparison between neural linearity regions and the normal complexes of $P$ and $Q$. For generic parameters, one expects the output regions to be governed by the common refinement of those complexes; special parameter choices should merge regions rather than create new ones. Finally, rational weights and biases call for an exact rational implementation, postponing real-number interpretation until the end.

The central lesson is already complete. A ReLU network is not merely reminiscent of tropical geometry. Node by node, with negative weights handled by exchanging two convex pieces and nonlinear gates handled by one maximum identity, the entire computation becomes tropical rational. What looks like a layered machine is equally a difference of polyhedral landscapes—and moving between those views requires no approximation at all.
