# The Determinant That Measures Two-Qubit Entanglement

## From a binary topological picture to a continuous geometric gauge

Entanglement resists ordinary intuition because it is neither a force nor a signal passing between particles. It is a property of a joint state: two quantum systems can possess a perfectly definite relationship even when neither system has a definite state of its own. That relationship is not merely present or absent. Pure two-qubit states range continuously from completely separable to maximally entangled, with every intermediate degree possible.

This continuity immediately challenges any attempt to describe entanglement by an integer-valued linking number. An integer can distinguish topological classes, but it cannot faithfully register a state whose entanglement lies halfway between the two extremes. The right replacement is geometric rather than purely topological. For a pure state of two qubits, one complex determinant supplies exactly the needed coordinate, and its normalized magnitude becomes a real number between zero and one.

The remarkable part is not only that this number has the correct endpoints. A single identity explains its entire range, its invariance under rescaling, and the rigid shape of every state at the upper endpoint.

## Four amplitudes arranged as a square

A general pure two-qubit state has four complex amplitudes:

$$
|\psi\rangle=a|00\rangle+b|01\rangle+c|10\rangle+d|11\rangle.
$$

It is useful to arrange them into a coefficient matrix

$$
A=\begin{pmatrix}a&b\\c&d\end{pmatrix}.
$$

The squared Hilbert norm is

$$
N=|a|^2+|b|^2+|c|^2+|d|^2.
$$

Physical states are usually normalized by requiring $N=1$, but allowing arbitrary nonzero representatives exposes the projective geometry: multiplying every amplitude by the same nonzero complex number changes neither the physical ray nor the entanglement.

The decisive quantity is the determinant

$$
\Delta=ad-bc.
$$

Why should this tiny expression know anything about entanglement? Because a product state has the form

$$
(\alpha|0\rangle+\beta|1\rangle)\otimes(\gamma|0\rangle+\delta|1\rangle),
$$

whose matrix is

$$
\begin{pmatrix}\alpha\gamma&\alpha\delta\\
\beta\gamma&\beta\delta\end{pmatrix}.
$$

Its second row is proportional to its first, so its determinant vanishes. Conversely, if a nonzero $2\times2$ matrix has determinant zero, its rank is one and it factors as a column times a row. That factorization is precisely the algebraic signature of a product state. Thus $\Delta=0$ describes the product-state variety exactly.

This determinant is also an exterior-algebra coordinate. If the two rows are vectors $r_1=(a,b)$ and $r_2=(c,d)$ in $\mathbb C^2$, then $ad-bc$ is the coefficient of their wedge product $r_1\wedge r_2$. Its magnitude measures the complex area spanned by the rows. Parallel rows span no area; balanced orthogonal rows span as much area as the normalization permits.

## The normalized Hopf functional

Define the real-valued functional

$$
H(\psi)=
\begin{cases}
0,&N=0,\\[4pt]
\dfrac{2|ad-bc|}{N},&N\ne0.
\end{cases}
$$

For a normalized state this simplifies to $H(\psi)=2|ad-bc|$, the usual concurrence of a pure two-qubit state. The factor of two is not decorative: it calibrates the largest possible determinant magnitude, $1/2$, to the value one.

The formula has four essential properties.

**First, it is insensitive to the choice of representative.** If every amplitude is multiplied by $z\ne0$, then the determinant is multiplied by $z^2$, while $N$ is multiplied by $|z|^2$. Therefore

$$
H(z\psi)=\frac{2|z^2\Delta|}{|z|^2N}=H(\psi).
$$

The functional consequently belongs to projective state space rather than to an arbitrary coordinate vector. In the quaternionic Hopf picture of two-qubit geometry, it is the normalized magnitude of the distinguished exterior-square coordinate.

**Second, it varies continuously away from the zero vector.** Intermediate entanglement is represented by intermediate real values rather than forced into discrete bins. For example,

$$
|\psi_t\rangle=\sqrt{t}\,|00\rangle+\sqrt{1-t}\,|11\rangle,
\qquad 0\le t\le1,
$$

has

$$
H(\psi_t)=2\sqrt{t(1-t)}.
$$

This rises smoothly from zero, reaches one at $t=1/2$, and falls smoothly back to zero.

**Third, its zero set is exact.** Since the denominator is positive for every nonzero state,

$$
H(\psi)=0\quad\Longleftrightarrow\quad ad-bc=0.
$$

For physical nonzero states, this is equivalent to being a product state.

**Fourth, every normalized state satisfies $0\le H(\psi)\le1$.** The lower bound is immediate from the absolute value. The upper bound contains the real geometry.

## One identity does the heavy lifting

Let

$$
x=|a|^2+|b|^2,
\qquad
y=|c|^2+|d|^2
$$

be the squared lengths of the two rows, and let

$$
s=\overline a c+\overline b d
$$

be their Hermitian inner product. The complex Lagrange identity states that

$$
|ad-bc|^2+|\overline a c+\overline b d|^2
=(|a|^2+|b|^2)(|c|^2+|d|^2).
$$

In compact form,

$$
|\Delta|^2+|s|^2=xy.
$$

This is a complex analogue of the familiar relation between dot product, area, and side lengths. It says that the product of the squared row lengths divides into two nonnegative pieces: alignment, measured by $|s|^2$, and exterior area, measured by $|\Delta|^2$.

For a normalized state, $x+y=1$. Since $|s|^2\ge0$, the identity gives $|\Delta|^2\le xy$. Meanwhile the elementary arithmetic-geometric mean inequality gives

$$
xy\le\left(\frac{x+y}{2}\right)^2=\frac14.
$$

Hence $|\Delta|\le1/2$ and therefore

$$
0\le H(\psi)=2|\Delta|\le1.
$$

The proof reveals more than a bound. It identifies exactly where any loss occurs. The determinant can reach its maximum only if the alignment term $|s|^2$ vanishes and the product $xy$ reaches its maximum under $x+y=1$.

## The summit is rigid

The sharp-maximizer theorem gives a complete answer.

**Sharp-Maximizer Theorem.** For a normalized two-qubit state, $H(\psi)=1$ if and only if

$$
\overline a c+\overline b d=0,
\qquad |a|^2+|b|^2=\frac12,
\qquad |c|^2+|d|^2=\frac12.
$$

In words: the coefficient rows must be Hermitian-orthogonal, and they must carry equal probability weight.

The forward implication follows by tracing equality through the two inequalities. If $H=1$, then $|\Delta|^2=1/4$. The Lagrange identity says $1/4+|s|^2=xy$, but $xy\le1/4$. Both nonnegative gaps must therefore disappear: $s=0$ and $xy=1/4$. Together with $x+y=1$, the latter equation forces $x=y=1/2$. Conversely, orthogonality and equal row weights make the identity read $|\Delta|^2=1/4$, so $H=1$.

This describes the summit of the entanglement landscape without ambiguity. Consider the Bell state

$$
|\Phi^+\rangle=\frac{|00\rangle+|11\rangle}{\sqrt2}.
$$

Its rows are $(1/\sqrt2,0)$ and $(0,1/\sqrt2)$: orthogonal and equally long. Its determinant has magnitude $1/2$, so $H=1$. The theorem says that every other normalized maximizer has the same row geometry, even though phases and local coordinate choices may disguise it.

## A geometric landscape with meaningful strata

The result organizes pure two-qubit state space into level sets. At $H=0$ lies the Segre variety of product states, cut out by the quadratic equation $ad-bc=0$. At $H=1$ lies a rigid maximally entangled stratum characterized by balanced orthogonality. Between them are continuous level sets $0<H<1$.

This is why the determinant succeeds where integer linking fails. Linking numbers are designed to remain unchanged under continuous deformations until a singular event occurs. Entanglement, by contrast, is expected to change continuously when amplitudes change continuously. The normalized determinant magnitude behaves accordingly while retaining geometric meaning: it measures exterior area relative to total norm.

The quaternionic Hopf viewpoint adds another layer. A normalized pair of qubits lives on a seven-dimensional sphere before global phase is removed. Grouping the complex amplitudes into quaternionic coordinates produces a Hopf-geometric description in which fibers encode redundant phase-like information and the base captures relational geometry. The determinant component is naturally adapted to this structure, but taking its modulus and dividing by the total squared norm is what turns it into a canonical real gauge.

## Reading the dial through examples

Three states locate the geometry immediately. The state $|00\rangle$ has matrix $\left(\begin{smallmatrix}1&0\\0&0\end{smallmatrix}\right)$, so its rows are dependent and $H=0$. The Bell state $(|00\rangle+|11\rangle)/\sqrt2$ has a diagonal matrix with entries $1/\sqrt2$; its rows are balanced and orthogonal, so $H=1$.

A genuine midpoint is also easy to construct. Let

$$
|\chi\rangle=rac{\sqrt{2+\sqrt3}}2|00\rangle+
\frac{\sqrt{2-\sqrt3}}2|11\rangle.
$$

The squared coefficients add to one, while their product is $1/4$. Therefore $H(\chi)=1/2$. This state is neither product nor maximal: its coefficient rows remain orthogonal, but their unequal lengths prevent them from enclosing the largest possible area. The example separates two ingredients that are easy to conflate. Orthogonality creates exterior area; balance optimizes it under a fixed total norm.

Phases can make the same geometry look less obvious. Multiplying the entire state by $e^{i\theta}$ rotates every amplitude but leaves $H$ fixed. More generally, multiplying by any nonzero complex scalar changes both determinant magnitude and squared norm by the same factor. The ratio sees the physical ray, not the brightness of its chosen representative.

## Why this small formula matters

The determinant is computationally inexpensive: four complex amplitudes, two multiplications, one subtraction, one modulus, and a normalization. Yet it draws a precise boundary between separability and entanglement and classifies the most entangled states through equality conditions.

That combination makes it useful conceptually and practically. In quantum information, concurrence helps compare state-preparation protocols, diagnose degradation under noise when pure-state approximations are appropriate, and reveal how entanglement is redistributed by gates. In geometry, the same formula identifies the norm of a Plücker coordinate, suggesting a route toward larger systems: flatten a multipartite tensor across a bipartition, take its minors, and study the norms of the corresponding exterior powers.

Several natural questions now become sharply posed. Can one derive exact distances from a state to the product-state variety directly from $H$? What are the diffeomorphism types of the interior level sets? Can the balanced-orthogonal classification be converted into an explicit local-unitary normal form? And for larger bipartite or multipartite systems, which combinations of minors provide the most informative hierarchy?

The central lesson is already clear. Entanglement is not well captured by asking whether two loops are linked an integer number of times. For two pure qubits, the right image is an oriented parallelogram in complex space. Its normalized area is zero when the rows collapse onto one line, maximal when they are orthogonal and balanced, and smoothly variable everywhere between. A four-term quantum state thus carries a complete geometric dial in the compact expression $2|ad-bc|$.