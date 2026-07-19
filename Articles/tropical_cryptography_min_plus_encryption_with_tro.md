# The Arithmetic That Makes a Cryptographic Secret Visible

## Tropical matrices, hidden exponents, and an eigenvalue leakage channel

Ordinary arithmetic has trained us to expect that addition means adding and multiplication means multiplying. Tropical mathematics changes the rules. In the **min-plus algebra**, the smaller of two numbers plays the role of a sum, while ordinary addition plays the role of a product:

$$
x\oplus y=\min(x,y),\qquad x\otimes y=x+y.
$$

This modest substitution creates a surprisingly rich world. Polynomial graphs become angular landscapes. Matrix products become shortest-path calculations. Repeated multiplication records the cheapest cost of a journey made in a prescribed number of steps. These connections have encouraged proposals to use tropical matrix powers as cryptographic hiding places: publish a matrix $A$ and a large power $A^{\otimes r}$, then challenge an observer to recover $r$.

The attraction is easy to understand. Fast exponentiation computes a power without walking through every preceding exponent. If tropical matrix multiplication is expensive to reverse, perhaps the exponent can serve as a secret. But tropical arithmetic has spectral invariants of its own, and one of them moves in exact lockstep with the exponent. That creates a basic leakage channel.

The central result is simple to state. If a tropical matrix has an eigenvector with a nonzero eigenvalue, then its positive powers cannot collide, and the eigenvalue of a public power reveals the exact scaling of the hidden exponent. This is an identifiability theorem, not by itself an efficient attack: it says the secret is mathematically encoded in a scalar spectral quantity. Whether that quantity can be computed efficiently depends on the representation and assumptions of a concrete system. Yet any security design must confront the leakage rather than treating the eigenvalue law as evidence of hardness.

## A matrix multiplication built from cheapest routes

Let $A$ and $B$ be $n\times n$ real matrices, where $n\ge 1$. Their min-plus product is the matrix $A\otimes B$ defined by

$$
(A\otimes B)_{ij}=\min_{1\le k\le n}(A_{ik}+B_{kj}).
$$

Read $A_{ik}$ as the cost of going from $i$ to $k$ in one stage and $B_{kj}$ as the cost from $k$ to $j$ in a second stage. Then $(A\otimes B)_{ij}$ is the cheapest two-stage route from $i$ to $j$. This is the same dynamic-programming pattern that underlies shortest-path algorithms, scheduling, and discrete-event systems.

A matrix acts on a vector $v\in\mathbb{R}^n$ by

$$
(A\otimes v)_i=\min_{1\le j\le n}(A_{ij}+v_j).
$$

The vector entry $v_j$ may be viewed as a terminal cost attached to state $j$. The action asks for the cheapest first step plus terminal cost.

For clarity, define positive powers with an index beginning at zero:

$$
P_0(A)=A,\qquad P_{k+1}(A)=A\otimes P_k(A).
$$

Thus $P_k(A)$ is the usual tropical power with exponent $k+1$. This shift matters. A secret index $k$ in this convention corresponds to $k+1$ matrix factors.

The engine behind the theory is an associativity law for actions:

$$
(A\otimes B)\otimes v=A\otimes(B\otimes v).
$$

Why is this true? The $i$th coordinate of the left side minimizes first over a final state $j$ and then over an intermediate state $k$. Expanding it gives the minimum of

$$
A_{ik}+B_{kj}+v_j
$$

over all pairs $(k,j)$. The right side takes exactly the same minimum, merely in the opposite order. Because both index sets are finite and nonempty, reordering the minimization changes nothing.

There is a second useful identity. Adding the same scalar $c$ to every component of a vector commutes with the matrix action:

$$
A\otimes(c+v)=c+(A\otimes v),
$$

where $c+v$ denotes the vector with components $c+v_i$. Every candidate inside the minimum gains the same amount $c$, so the minimum does too.

## Tropical eigenvectors are clocks

A scalar $\lambda\in\mathbb{R}$ and vector $v\in\mathbb{R}^n$ form a **min-plus eigenpair** of $A$ when

$$
A\otimes v=\lambda+v.
$$

This differs in appearance from the familiar equation $Av=\lambda v$, but it expresses the same organizing idea: applying the matrix preserves the shape of the vector while changing its overall scale. In min-plus arithmetic, scaling means ordinary translation. Each application of $A$ adds $\lambda$ to every coordinate.

That makes an eigenvector behave like a clock. Apply the matrix once, and the clock advances by $\lambda$. Apply it again, and it advances by another $\lambda$. After $k+1$ applications, it has advanced by $(k+1)\lambda$.

**Power-law theorem.** If $A\otimes v=\lambda+v$, then for every integer $k\ge 0$,

$$
P_k(A)\otimes v=(k+1)\lambda+v.
$$

The proof is induction. The case $k=0$ is precisely the eigenpair equation. For the next power, associate the action as

$$
P_{k+1}(A)\otimes v
=A\otimes(P_k(A)\otimes v).
$$

Insert the induction hypothesis and move the scalar translation through the action:

$$
A\otimes((k+1)\lambda+v)
=(k+1)\lambda+(A\otimes v)
=(k+2)\lambda+v.
$$

The spectral clock therefore ticks with perfect regularity.

## When two powers look the same

Suppose two public powers coincide:

$$
P_a(A)=P_b(A).
$$

Act on the same eigenvector $v$. The power law gives

$$
(a+1)\lambda+v=(b+1)\lambda+v.
$$

Canceling $v$ yields $(a-b)\lambda=0$. If $\lambda\ne 0$, then $a=b$.

This proves the **nonzero-eigenvalue injectivity theorem**: for any matrix possessing a min-plus eigenpair with nonzero eigenvalue, the map $k\mapsto P_k(A)$ is injective. Distinct positive exponents produce distinct matrices.

The contrapositive is equally revealing. If distinct positive powers do collide, then every eigenvalue represented by an eigenvector must be zero. A collision is therefore not spectrally neutral; it forces the spectral clock to stop.

Now suppose an observer knows that $B=P_k(A)$ and finds that the same vector $v$ satisfies

$$
A\otimes v=\lambda+v,
\qquad
B\otimes v=\mu+v.
$$

The power law and the observed equation describe the same action, so

$$
\mu=(k+1)\lambda.
$$

If $\lambda\ne 0$, the index is algebraically determined:

$$
k=\frac{\mu}{\lambda}-1.
$$

This is the leakage formula. It should be interpreted carefully. The theorem does not promise that an eigenpair is available, that it can be found quickly, or that floating-point calculations recover it reliably. It says that once certified values $\lambda$ and $\mu$ on a common eigenvector are available, there is no remaining ambiguity about the exponent.

## Shifting all costs does not hide the clock

A natural masking attempt is to add a constant $c$ to every entry of $A$. Let the shifted matrix $S_c(A)$ be defined by

$$
S_c(A)_{ij}=c+A_{ij}.
$$

Uniformly increasing every edge cost seems as though it might obscure the spectrum. Instead, it merely resets the clock.

**Shift theorem.** If $A\otimes v=\lambda+v$, then

$$
S_c(A)\otimes v=(c+\lambda)+v.
$$

Indeed, every candidate $A_{ij}+v_j$ inside the minimum gains $c$, so the minimum gains $c$. The eigenvector remains unchanged and the eigenvalue moves from $\lambda$ to $c+\lambda$.

Consequently, the positive powers of $S_c(A)$ are injective whenever $c+\lambda\ne 0$. There is exactly one exceptional offset relative to this eigenpair, namely $c=-\lambda$. Every other uniform shift leaves a nonzero spectral clock. Uniform scalar masking therefore does not generically remove exponent identifiability.

## A concrete two-state example

Consider

$$
A=
\begin{pmatrix}
2&5\\
4&2
\end{pmatrix},
\qquad
v=
\begin{pmatrix}
0\\
1
\end{pmatrix}.
$$

The first coordinate of $A\otimes v$ is $\min(2+0,5+1)=2$, and the second is $\min(4+0,2+1)=3$. Hence

$$
A\otimes v=
\begin{pmatrix}2\\3\end{pmatrix}
=2+
\begin{pmatrix}0\\1\end{pmatrix},
$$

so $(2,v)$ is an eigenpair. The spectral clock advances by $2$ per factor. For the third positive power, corresponding to $k=2$, the eigenvalue is $6$. If an observer measures $\mu=6$ against the same vector, the leakage formula returns $k=6/2-1=2$.

Shift every entry by $-2$. The eigenvalue becomes zero, which is the unique exceptional shift for this eigenpair. Shift instead by $1$, and the new eigenvalue is $3$; all positive powers remain distinct, and the clock now advances by $3$.

## What this means for tropical cryptography

A proposed tropical discrete-logarithm problem asks for the exponent hidden in a pair $(A,P_k(A))$. The results above do not settle the computational complexity of that problem for every matrix family. They identify a structural condition under which the exponent has a direct spectral description. Any claim of one-wayness must therefore specify how matrices are sampled, whether eigenpairs exist in the chosen number system, how hard they are to compute, how zero eigenvalues are handled, and whether normalization destroys or preserves the relevant scalar information.

The same caution applies to key exchange. In a single-base power semigroup, parties may hope to combine private exponents through repeated powering. Before security can even be discussed, the exponent convention, associativity, public transcript, and shared-key identity must be stated precisely. Spectral leakage must then be analyzed in that exact model.

This is not a verdict against tropical methods. It is a design lesson. Tropical algebra has genuine computational structure, deep links to optimization, and unusual nonclassical behavior. But cryptography cannot rely on unfamiliar notation alone. A hard problem must remain hard after every efficiently accessible invariant has been extracted.

The broader lesson reaches beyond this particular algebra. Cryptographic candidates are often built from operations that are easy to perform and seem awkward to undo. Before trusting that asymmetry, one searches for a projection that turns the complicated operation into something simpler. Determinants, traces, norms, parities, and eigenvalues have all played this role in different settings. A projection need not reconstruct the whole secret object; it only needs to retain the secret quantity. Here the eigenvector supplies exactly such a projection, reducing a matrix-power problem to a one-dimensional linear equation.

Here the invariant tells a vivid story: an eigenvector turns repeated tropical multiplication into ordinary addition. With a nonzero eigenvalue, every power leaves a timestamp. The matrix may look complicated, yet along one special direction its hidden exponent is counting out loud.
