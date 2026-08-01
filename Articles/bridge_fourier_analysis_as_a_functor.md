# Fourier Analysis as a Functor: What Reversing Arrows Really Explains

## A familiar transform in an unfamiliar light

Fourier analysis is often introduced as a change of coordinates. A signal is written as a sum of frequencies; an image is decomposed into spatial waves; a quantum state is viewed in position space or momentum space. This perspective powers audio compression, medical imaging, telecommunications, and numerical simulation. Yet it can make the Fourier transform look like an isolated computational trick: multiply by a special matrix, simplify, and invert.

There is another viewpoint. Instead of asking only what the transform does to one vector, ask how it behaves when spaces and maps between them are considered together. This is the language of categories. A category consists of objects, arrows between objects, identity arrows, and a rule for composing arrows. The decisive observation is that taking characters reverses arrows. That reversal is not a technical nuisance. It is the structural heart of duality.

A finite matrix model makes this idea completely explicit. It also exposes two tempting overstatements. Fourier transforms do not commute with every linear map, so they are not an unrestricted natural endomorphism. And arrow reversal by itself does not imply an uncertainty principle. Fourier inversion, naturality, and uncertainty are related, but each requires its own hypotheses.

## Coordinate spaces as a category

Fix a commutative ring $K$. For each nonnegative integer $n$, let the object $n$ represent the coordinate module $K^n$. A morphism from $m$ to $n$ is an $n\times m$ matrix over $K$, representing a linear map $K^m\to K^n$.

If $A:l\to m$ and $B:m\to n$, categorical composition is ordinary matrix multiplication in the order

$$
A\mathbin{;}B=BA.
$$

At the level of entries,

$$
(A\mathbin{;}B)_{ij}=\sum_k B_{ik}A_{kj}.
$$

Identity arrows are identity matrices. Associativity and the identity laws are exactly the standard laws of matrix multiplication. Thus a modest collection of coordinate spaces already forms a complete categorical laboratory.

Why use this language for Fourier analysis? Because it lets us distinguish three ideas that are easily blurred together: dualizing a map, applying a Fourier transform, and asserting compatibility with every other map.

## Duality reverses direction

The dual of $K^n$ may again be represented by an $n$-coordinate space. A matrix $A:m\to n$ induces a map in the opposite direction on linear functionals. In coordinates this induced map is the transpose

$$
A^{\mathsf T}:n\to m.
$$

The crucial identity is

$$
(BA)^{\mathsf T}=A^{\mathsf T}B^{\mathsf T}.
$$

The order reverses. If a vector travels first through $A$ and then through $B$, a functional is pulled back first through $B$ and then through $A$. This is called contravariance.

**Contravariant Duality Theorem.** For finite coordinate modules over a commutative ring, assigning $n$ to its dual coordinate space and assigning each matrix $A$ to $A^{\mathsf T}$ defines a contravariant functor. It preserves identities and transforms a composite into the reversed composite of the transposes.

The proof is the displayed transpose identity. Entry by entry, both sides are sums of the same products. Commutativity of $K$ allows the scalar factors to be exchanged when matching the categorical conventions.

This finite statement mirrors character duality for topological abelian groups. A character of a topological abelian group $G$ is a continuous homomorphism

$$
\chi:G\to \mathbb T,
$$

where $\mathbb T$ is the circle group. Given a continuous homomorphism $f:A\to B$, every character $\chi$ on $B$ pulls back to the character $\chi\circ f$ on $A$. If $f:A\to B$ and $g:B\to C$, then

$$
\chi\circ(g\circ f)=(\chi\circ g)\circ f.
$$

Hence the character map associated with $g\circ f$ equals the character map associated with $f$ composed with the character map associated with $g$. Once again, arrows reverse.

## Returning from the double dual

Transposition has an especially clean feature:

$$
(A^{\mathsf T})^{\mathsf T}=A.
$$

Objects also return unchanged after dualizing twice. These equations fit together uniformly across every object and arrow.

**Finite Bidual Equivalence Theorem.** The contravariant transpose construction gives an equivalence between the finite coordinate matrix category and its opposite category. Dualizing twice is naturally isomorphic to doing nothing.

In this skeletal model, the natural isomorphism is as simple as possible: at every object it is the identity matrix. The proof on arrows reduces to double transposition. This theorem is the exact categorical shape of biduality in finite coordinates. It should not be confused with the full analytic theorem for locally compact abelian groups, which additionally depends on topology and harmonic analysis. The finite model captures the architecture, not all of the analytic content.

## The smallest Fourier transform

The general unnormalized discrete Fourier matrix has entries

$$
F_{ji}=\omega^{ij},
$$

where $\omega$ is an appropriate root of unity. The two-point case already displays inversion without complex arithmetic. Over the rational numbers, choose $\omega=-1$. Then

$$
F=\begin{pmatrix}1&1\\1&-1\end{pmatrix}.
$$

Its normalized inverse is

$$
F^{-1}=\frac12F
=\begin{pmatrix}\tfrac12&\tfrac12\\[2pt]\tfrac12&-\tfrac12\end{pmatrix}.
$$

Direct multiplication gives

$$
FF^{-1}=F^{-1}F=I_2.
$$

**Two-Point Fourier Inversion Theorem.** The two-point discrete Fourier transform over $\mathbb Q$ is an isomorphism, with inverse $\frac12F$.

For a vector $(x_0,x_1)^{\mathsf T}$, the transform produces

$$
F\begin{pmatrix}x_0\\x_1\end{pmatrix}
=\begin{pmatrix}x_0+x_1\\x_0-x_1\end{pmatrix}.
$$

The first output measures the average-like component before normalization; the second measures contrast. Applying $\frac12F$ reconstructs the two samples. This tiny example is the seed of the fast Walsh--Hadamard transform and a close relative of the binary frequency decompositions used throughout computation.

## A boundary: Fourier is not natural for every linear map

A natural transformation must commute with every morphism in its stated category. If the Fourier matrices formed a natural endomorphism of the identity functor on a category containing all linear maps, then every endomorphism $A$ would satisfy

$$
AF=FA.
$$

That claim is false even in dimension two. Consider projection onto the first coordinate,

$$
P=\begin{pmatrix}1&0\\0&0\end{pmatrix}.
$$

Then

$$
PF=\begin{pmatrix}1&1\\0&0\end{pmatrix},
\qquad
FP=\begin{pmatrix}1&0\\1&0\end{pmatrix}.
$$

The matrices differ.

**Failure of Unrestricted Fourier Naturality.** The two-point Fourier matrix does not commute with every rational $2\times2$ matrix. Therefore a family of Fourier matrices cannot be a natural endomorphism of the identity on a category whose arrows include all linear maps.

This negative result is constructive: one matrix and one differing entry settle the matter. More importantly, it tells us how to repair the idea. Fourier analysis can be natural only relative to a carefully chosen class of maps, such as group isomorphisms compatible with character pullback and counting or Haar measure, or between distinct functors that correctly track pushforward and pullback. The slogan “Fourier analysis is functorial” can be right, but only after its domain and variance are stated precisely.

## Another boundary: variance is not uncertainty

The uncertainty principle says, in various settings, that a nonzero object and its Fourier transform cannot both be sharply localized. For a vector $v\in\mathbb Q^n$, define its support size by

$$
|\operatorname{supp}(v)|
=\#\{i:v_i\ne0\}.
$$

A finite Fourier-style inequality may take the form

$$
|\operatorname{supp}(v)|\,
|\operatorname{supp}(Tv)|\ge n.
$$

Could such a bound follow merely because duality is contravariant? No. Contravariance describes how maps compose; it says nothing about spreading mass among coordinates.

Take $n=2$, let $T$ be the identity, and choose the delta vector

$$
\delta_0=\begin{pmatrix}1\\0\end{pmatrix}.
$$

Both $\delta_0$ and $T\delta_0$ have support size $1$, so

$$
|\operatorname{supp}(\delta_0)|
|\operatorname{supp}(T\delta_0)|=1<2.
$$

**Insufficiency of Contravariance for Uncertainty.** A contravariant duality alone does not force a Fourier support uncertainty bound. Even in a setting possessing transpose duality, the identity transform and a delta vector violate the proposed two-dimensional lower bound.

Uncertainty needs more: orthogonality of characters, nondegeneracy of the Fourier pairing, invertibility together with suitable minor conditions, or analytic information such as Plancherel theory. Variance organizes arrows; orthogonality controls localization.

## What the categorical view contributes

The finite model delivers a useful map of the conceptual terrain.

First, character duality is genuinely contravariant. This is not metaphorical: composition reverses by an exact equation. Second, double dualization produces an equivalence in finite coordinates, revealing the categorical skeleton of biduality. Third, the Fourier transform itself can be an isomorphism, as the two-point matrix demonstrates. But these facts do not collapse into one another. Invertibility does not mean commutation with every map, and contravariance does not mean uncertainty.

That separation matters in applications. Signal-processing pipelines mix transforms, projections, resampling maps, and symmetries. Knowing which diagrams commute tells an engineer when operations may be reordered without changing the result. In quantum theory, changing between conjugate representations is invertible, while uncertainty depends on the geometry of the bases rather than on invertibility alone. In algorithms, transposition and reversal explain adjoint data flow, while fast Fourier structure depends on special roots of unity and factorization.

The lesson is both positive and cautionary. Category theory does not replace the equations of Fourier analysis. It shows which equations express universal structure and which depend on special analytic ingredients. The reversal of arrows is universal. Biduality has a clean finite form. Fourier inversion requires a special matrix. Naturality requires carefully selected morphisms. Uncertainty requires orthogonality or nondegeneracy.

Seen this way, Fourier analysis is not merely one matrix calculation, nor is it automatically a universal transformation on every linear space. It is a meeting point of duality, symmetry, measure, and computation. The categorical viewpoint earns its keep by making those ingredients visible—and by showing exactly where each one begins and ends.
