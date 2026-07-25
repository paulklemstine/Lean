# Tropical Hodge Theory: Finding the Quiet Signal Inside a Geometric Network

A city map, a river delta, and a crystalline skeleton can all be reduced to the same mathematical picture: a collection of pieces joined along shared boundaries. Roads meet at intersections, channels meet along junctions, and polygonal cells meet along edges. Once a space has been assembled from finitely many pieces, we can place numbers on those pieces and ask how the numbers fit together.

That modest question leads to a powerful principle. Certain data are mere changes of potential: they arise from data one degree lower and carry no new global information. Certain data contain an irreducible global signal. And certain data fail even the first consistency test, so they cannot be understood using only those two categories.

The central result developed here says exactly when the first two categories suffice. On a finite weighted geometric complex, every **closed** cochain splits uniquely into an exact part and a harmonic part. The exact part records local, potential-driven variation. The harmonic part is the quiet global residue, orthogonal to every exact variation. If two closed cochains differ only by an exact correction, they have precisely the same harmonic residue.

The word “tropical” evokes geometry built from polyhedral pieces, often carrying balancing conditions and positive weights. Yet the core mechanism is more universal. Once a finite tropical complex provides finite-dimensional real vector spaces, positive inner products, and boundary-compatible coboundary maps, the decomposition follows from Euclidean projection.

## Cochains, coboundaries, and the rule that boundaries have no boundary

Consider three finite-dimensional real inner-product spaces

$$
P \xrightarrow{d_-} C \xrightarrow{d_+} N.
$$

One may think of $C$ as the space of cochains of a fixed degree. The space $P$ contains cochains one degree lower, and $N$ contains cochains one degree higher. The linear maps $d_-$ and $d_+$ are consecutive coboundary operators. Their defining compatibility is

$$
d_+d_-=0.
$$

This equation is the algebraic expression of a familiar geometric fact: taking a boundary twice yields nothing. It immediately implies that every exact cochain is closed.

A cochain $x\in C$ is called **exact** when $x=d_-p$ for some $p\in P$. Thus the exact cochains form the subspace $\operatorname{im}d_-$. A cochain is called **closed** when $d_+x=0$, so the closed cochains form $\ker d_+$. Because $d_+d_-=0$, we have

$$
\operatorname{im}d_-\subseteq\ker d_+.
$$

Now the inner product enters. It can encode cell weights, geometric sizes, conductances, or confidence levels. A closed cochain $h$ is called **harmonic** when it is orthogonal to every exact cochain:

$$
d_+h=0,
\qquad
\langle h,d_-p\rangle=0\quad\text{for every }p\in P.
$$

Equivalently, the harmonic space is

$$
\mathcal H=\ker d_+\cap(\operatorname{im}d_-)^\perp.
$$

This definition captures a “signal without local gradient.” It satisfies the consistency law $d_+h=0$, but no portion of it points along an exact direction.

## The decomposition theorem

**Closed Hodge Decomposition Theorem.** Let $P$, $C$, and $N$ be finite-dimensional real inner-product spaces, and let $d_-:P\to C$ and $d_+:C\to N$ be linear maps satisfying $d_+d_-=0$. Then every closed cochain $x\in C$ admits a decomposition

$$
x=e+h,
$$

where $e\in\operatorname{im}d_-$ is exact and $h\in\mathcal H$ is harmonic. The two summands are orthogonal, and both $e$ and $h$ are unique.

The proof is geometric. Let $E=\operatorname{im}d_-$. Finite-dimensional inner-product geometry gives the orthogonal splitting

$$
C=E\oplus E^\perp.
$$

Project $x$ onto $E$ and call the result $e$; let $h=x-e$ be the orthogonal remainder. By construction, $e$ is exact and $h\perp E$. Since exact cochains are closed, $d_+e=0$. Since $x$ is closed as well,

$$
d_+h=d_+(x-e)=d_+x-d_+e=0.
$$

Thus $h$ is both closed and orthogonal to exact cochains: it is harmonic.

Uniqueness is equally visual. Suppose

$$
x=e_1+h_1=e_2+h_2
$$

with both $e_i$ exact and both $h_i$ harmonic. Then

$$
e_1-e_2=h_2-h_1.
$$

The left side lies in $E$; the right side lies in $E^\perp$. Their common value therefore lies in $E\cap E^\perp$, which contains only $0$. Hence $e_1=e_2$ and $h_1=h_2$.

## Why the harmonic part carries global information

The decomposition turns an equivalence class into a canonical object. Suppose two closed cochains differ by an exact cochain:

$$
y=x+d_-p.
$$

Write their decompositions as $x=e_x+h_x$ and $y=e_y+h_y$. Then

$$
y=(e_x+d_-p)+h_x.
$$

This is already an exact-plus-harmonic decomposition of $y$. By uniqueness, $h_y=h_x$.

**Harmonic Representative Theorem.** Closed cochains that differ by an exact cochain have the same harmonic component.

This statement is the bridge to cohomology. Cohomology regards closed cochains as equivalent when their difference is exact. The theorem says that each such class has one distinguished representative: its harmonic cochain. Instead of carrying an entire family of equivalent descriptions, one keeps the unique member perpendicular to all local gauge changes.

This has a direct analogy in data analysis. Suppose measurements live on edges of a network. Adding a potential difference at vertices changes the edge data by a gradient-like, exact term. Such a change may reflect recalibration rather than a new circulation pattern. The harmonic component survives the recalibration and records the genuinely global feature.

## The tempting statement that fails

It is natural to overreach and claim that **every** cochain is exact plus harmonic. That is false. Closedness is not cosmetic; it is essential.

The smallest instructive counterexample lives in $C=\mathbb R^2$. Define

$$
d_-:\mathbb R\to\mathbb R^2,
\qquad
d_-(a)=(a,0),
$$

and

$$
d_+:\mathbb R^2\to\mathbb R,
\qquad
d_+(u,v)=v.
$$

Clearly $d_+d_-=0$. Exact cochains form the first coordinate axis. Closed cochains also form the first coordinate axis, because $d_+(u,v)=0$ exactly when $v=0$. A harmonic cochain must be closed and orthogonal to the first axis, so the only harmonic cochain is $(0,0)$.

Now consider

$$
z=(0,1).
$$

It is not closed, since $d_+z=1$. It cannot be exact plus harmonic: every exact cochain has second coordinate $0$, and the only harmonic cochain is $0$. Thus the proposed two-part decomposition misses $z$ completely.

This failure is informative rather than destructive. It identifies the missing direction. For arbitrary cochains, classical Hodge theory includes a third, **coexact** summand associated with the adjoint of $d_+$. In the example, $(0,1)$ points precisely along that omitted direction.

## A computational recipe

The theorem is constructive. Choose coordinates and let $D_-$ be the matrix of $d_-$. Given a closed vector $x$, find the exact part by orthogonally projecting $x$ onto the column space of $D_-$. Numerically, a singular-value decomposition or a least-squares solver provides a stable implementation:

$$
e=D_-D_-^+x,
\qquad
h=x-e,
$$

where $D_-^+$ is the Moore–Penrose pseudoinverse. One then checks

$$
D_+h=0,
\qquad
D_-^{\mathsf T}h=0.
$$

For a matrix with $m$ rows and $n$ columns, a dense singular-value decomposition costs roughly $O(mn\min\{m,n\})$. Sparse tropical complexes permit much larger calculations because incidence matrices are usually sparse.

## From polyhedral geometry to applications

Balanced weighted polyhedral complexes arise naturally in tropical geometry, where curved algebraic objects are replaced by piecewise-linear shadows. A finite complex supplies oriented cells and incidence maps; balancing ensures geometric compatibility, while positive weights produce meaningful inner products. The theorem then separates closed tropical data into local exact structure and global harmonic structure.

The same architecture appears elsewhere. On electrical networks, exact edge data come from voltage potentials, while harmonic modes encode persistent circulations. In sensor networks, an exact correction can model recalibration, while the harmonic residue detects loops not explained by local offsets. In mesh processing, orthogonal decomposition separates gradient-like content from topology-sensitive content. In all these settings, the weighted inner product matters: changing weights changes what “closest exact approximation” means, even when the underlying cohomology is unchanged.

The result also teaches a methodological lesson. A decomposition theorem is only as strong as its hypotheses. Closed data admit an exact-plus-harmonic split. Arbitrary data generally require a third term. The two-dimensional counterexample marks that boundary with complete clarity.

## The quiet coordinate of a global class

The harmonic component can be viewed as a canonical coordinate for global structure. Exact terms are movable: they change when one modifies a potential. Harmonic terms are stable under those changes. Orthogonality makes the stable representative unique, and finite-dimensional geometry makes it computable.

So the heart of tropical Hodge theory is not an ornate formula but a disciplined separation. First enforce consistency through closedness. Then remove everything generated locally. What remains is perpendicular to all such local generation and therefore cannot be erased by changing potentials. It is the quiet signal of the whole complex.

## A small example with a genuine harmonic mode

To see more than the counterexample, take $C=\mathbb R^3$, let exact cochains be the first coordinate axis, and let closed cochains be the plane spanned by the first two coordinate axes. In matrices, choose

$$
D_-=\begin{bmatrix}1\\0\\0\end{bmatrix},
\qquad
D_+=\begin{bmatrix}0&0&1\end{bmatrix}.
$$

Then $D_+D_-=0$. A closed vector has the form $x=(a,b,0)$. Orthogonal projection gives

$$
e=(a,0,0),
\qquad
h=(0,b,0).
$$

The second coordinate is a genuine harmonic direction: it is closed but cannot be generated from the preceding space. If one adds an exact perturbation $(t,0,0)$, the vector becomes $(a+t,b,0)$; its harmonic part remains $(0,b,0)$. By contrast, a vector with a nonzero third coordinate is not closed and lies beyond the two-summand theorem. This three-coordinate picture displays the entire story at once: one axis for exact variation, one for global harmonic information, and one for the closure defect that a future coexact term must capture.
