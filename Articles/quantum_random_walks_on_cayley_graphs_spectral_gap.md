# The Hidden Music of a Circular Network

## How Fourier waves reveal the spectrum of every cyclic Cayley graph

Imagine a necklace of $n$ identical stations. From any station, a traveler may move by any displacement listed in a fixed set $S$: perhaps one step clockwise or counterclockwise, perhaps jumps of two or five stations as well. Arithmetic wraps around the necklace, so station $n$ is station $0$. This simple rule produces a **cyclic Cayley graph**, a network whose view is identical from every vertex.

Such graphs occur wherever translation symmetry matters: periodic lattices, signal processing, diffusion on rings, consensus networks, and models of classical and quantum transport. Their symmetry suggests that their dynamics should have a simple description. The surprise is just how simple: the correct coordinates are waves, and every permitted jump merely changes a wave by a phase.

That observation creates a direct bridge among three subjects. Group theory describes the circular arithmetic. Fourier analysis supplies the waves. Spectral graph theory turns their phase changes into eigenvalues, the numbers that govern repeated evolution. For the ordinary cycle, the bridge ends in an elementary trigonometric formula:

$$
\lambda_k=2\cos\left(\frac{2\pi k}{n}\right).
$$

This is not merely a familiar formula for one matrix. It is the visible tip of a general theorem that diagonalizes every translation-invariant adjacency operator on a finite circle.

## A graph built from modular motion

Write $\mathbb Z/n\mathbb Z$ for the integers modulo $n$. Its elements label the stations. Choose a finite connection set $S\subseteq\mathbb Z/n\mathbb Z$. The associated Cayley graph permits a move from $x$ to $x+s$ for every $s\in S$.

A complex-valued signal on the graph is a function $f:\mathbb Z/n\mathbb Z\to\mathbb C$. The adjacency operator $A_S$ collects the signal arriving along all allowed displacements:

$$
(A_Sf)(x)=\sum_{s\in S}f(x+s).
$$

If one divides by $|S|$, this becomes the transition operator for the classical walk that chooses a displacement uniformly from $S$. Without normalization it is the graph’s adjacency operator. The distinction matters for numerical scales, but not for the eigenvectors.

The central question is: which signals preserve their shape under $A_S$? Such a signal $f$ satisfies

$$
A_Sf=\lambda f
$$

for some eigenvalue $\lambda$. Once these special signals are known, repeated applications of the operator become transparent: $A_S^tf=\lambda^t f$.

## The waves that fit perfectly around the circle

Choose a complex number $\zeta$ satisfying $\zeta^n=1$. Such a number is an $n$th root of unity. It defines a character, or Fourier wave,

$$
\chi_\zeta(x)=\zeta^x.
$$

The notation is well defined modulo $n$ because changing $x$ by $n$ multiplies the value by $\zeta^n=1$. The key identity is the familiar law of exponents, now interpreted as compatibility with circular addition:

$$
\chi_\zeta(x+s)=\chi_\zeta(x)\chi_\zeta(s).
$$

Apply the adjacency operator to this wave:

$$
\begin{aligned}
(A_S\chi_\zeta)(x)
&=\sum_{s\in S}\chi_\zeta(x+s)\\
&=\sum_{s\in S}\chi_\zeta(x)\chi_\zeta(s)\\
&=\left(\sum_{s\in S}\zeta^s\right)\chi_\zeta(x).
\end{aligned}
$$

We have reached the main result.

**Fourier Diagonalization Theorem.** For every nonempty modulus $n$, every connection set $S\subseteq\mathbb Z/n\mathbb Z$, and every $n$th root of unity $\zeta$, the character $x\mapsto\zeta^x$ is a nonzero eigenvector of $A_S$. Its eigenvalue is

$$
\lambda_S(\zeta)=\sum_{s\in S}\zeta^s.
$$

Because the $n$ standard roots $\zeta_k=e^{2\pi i k/n}$ give the discrete Fourier basis, these waves diagonalize the whole operator. Better still, the same basis works for every choice of $S$. Changing the jump rule changes the eigenvalues but not the spectral coordinates.

This is why circulant matrices are friendly. A matrix that looks complicated in the station basis becomes diagonal in the wave basis. The eigenvalue is simply the Fourier transform of the connection set’s indicator function.

## The loudest mode and a universal ceiling

Set $\zeta=1$. The corresponding wave is constant: every station has the same amplitude. Every summand in the eigenvalue equals $1$, so

$$
\lambda_S(1)=|S|.
$$

**Degree Eigenvalue Theorem.** The constant mode is an eigenvector with eigenvalue equal to the degree $|S|$.

No other Fourier eigenvalue can have larger modulus. Since every root of unity lies on the unit circle, $|\zeta^s|=1$, and the triangle inequality gives

$$
|\lambda_S(\zeta)|
=\left|\sum_{s\in S}\zeta^s\right|
\leq\sum_{s\in S}|\zeta^s|
=|S|.
$$

**Spectral Degree Bound.** Every character eigenvalue satisfies $|\lambda_S(\zeta)|\leq |S|$.

Geometrically, the eigenvalue is a sum of unit arrows in the complex plane. They can align and reach length $|S|$, as they do for the constant mode, or cancel partially. The amount of cancellation measures how strongly the jump rule suppresses that Fourier frequency.

For the normalized transition operator $P_S=A_S/|S|$, all eigenvalues lie in the closed unit disk, and the constant mode has eigenvalue $1$. This is the starting point of spectral analysis for classical mixing.

## Why symmetry makes the spectrum real

Suppose the move set is symmetric: whenever $s$ is allowed, so is $-s$. Then every clockwise jump is paired with its counterclockwise counterpart. In matrix language, the adjacency operator is Hermitian. In the character formula, the same fact appears through conjugate pairs.

For a root of unity, $\overline{\zeta^s}=\zeta^{-s}$. Therefore

$$
\overline{\lambda_S(\zeta)}
=\sum_{s\in S}\zeta^{-s}.
$$

The substitution $s\mapsto -s$ merely permutes a symmetric set $S$, so the last sum equals $\lambda_S(\zeta)$.

**Reality Theorem for Symmetric Connection Sets.** If $S=-S$, then every Fourier eigenvalue $\lambda_S(\zeta)$ is real.

The result turns a complex polygonal sum into a real number. Paired terms satisfy

$$
\zeta^s+\zeta^{-s}=2\operatorname{Re}(\zeta^s),
$$

so their imaginary parts cancel. This is the spectral signature of reversible motion.

## Hearing the cycle

The ordinary cycle permits the two moves $S=\{1,-1\}$. Assume $n\geq3$, so these are distinct. The general character-sum formula immediately becomes

$$
\lambda(\zeta)=\zeta+\zeta^{-1}.
$$

Choose the $k$th standard root

$$
\zeta_k=\exp\left(\frac{2\pi i k}{n}\right).
$$

Euler’s formula then gives

$$
\zeta_k+\zeta_k^{-1}
=e^{2\pi i k/n}+e^{-2\pi i k/n}
=2\cos\left(\frac{2\pi k}{n}\right).
$$

**Cycle Spectrum Theorem.** For the cycle on $n\geq3$ vertices, the Fourier mode indexed by $k$ has adjacency eigenvalue

$$
\lambda_k=2\cos\left(\frac{2\pi k}{n}\right).
$$

For the simple random walk, divide by $2$; its transition eigenvalues are $\mu_k=\cos(2\pi k/n)$. The mode $k=0$ is constant and has eigenvalue $1$. The slowly decaying low-frequency modes $k=1$ and $k=n-1$ sit close to $1$ when $n$ is large.

This gives a precise way to “hear” the size of a ring. Near zero, $1-\cos\theta$ behaves like $\theta^2/2$, so the transition spectral gap of the cycle behaves like a constant times $n^{-2}$. Consequently, classical diffusion around a long cycle is slow: information must traverse a one-dimensional periodic space.

That asymptotic observation is a consequence of the displayed spectrum and standard trigonometric estimates; it also points beyond the exact results here, toward quantitative mixing bounds.

## What the spectrum says—and what it does not

Spectral gaps are often described as clocks for mixing. For a reversible classical walk, the gap between the top transition eigenvalue $1$ and the next relevant eigenvalue controls how quickly nonconstant modes decay. In a cyclic Cayley graph, the theorem above makes every one of those modes explicit:

$$
\mu_k=\frac{1}{|S|}\sum_{s\in S}e^{2\pi i ks/n}.
$$

This formula can guide the design of jump sets. If the unit arrows cancel strongly for every nonconstant $k$, the normalized eigenvalues are small and classical averaging is fast. If some arrows nearly align, a slowly varying mode survives.

Quantum walks require an important extra sentence. A genuine discrete-time quantum walk evolves by a unitary operator, often with an auxiliary “coin” space or through a Szegedy construction. The adjacency operator studied here supplies essential spectral geometry, but it is not itself generally unitary. Unitary evolution does not make amplitudes decay in the way a stochastic operator does, and notions such as instantaneous, time-averaged, or measured mixing must be distinguished.

For that reason, no universal quadratic mixing advantage follows from the adjacency spectrum alone. In particular, the cycle does not support a blanket $O(\sqrt n\log n)$ mixing law for every quantum-walk model. The correct claims depend on the model, graph, initial state, and definition of mixing. The exact Fourier spectrum is valuable precisely because it provides a firm foundation on which those distinctions can be analyzed rather than blurred.

## A reusable bridge

The circular case is the cleanest laboratory for a broad idea: symmetry chooses the right basis. On any finite abelian group, characters play the role of the waves $x\mapsto\zeta^x$, and convolution by a connection set acts diagonally on them. For nonabelian groups, scalar frequencies are replaced by matrix-valued irreducible representations, producing blocks rather than single eigenvalues.

Even on the circle, the bridge has many uses. It computes spectra without generic matrix diagonalization. It explains why symmetric rules have real eigenvalues. It gives immediate degree bounds. It supports numerical checks through a fast Fourier transform. It can also reveal different connection sets with identical spectra, leading to isospectral graphs.

The deepest lesson is simple enough to picture. Place $n$ points around a circle. At frequency $k$, each allowed jump contributes a unit arrow whose angle records how that jump shifts the wave. Add the arrows. Their sum is the eigenvalue. Alignment preserves the mode; cancellation erases it; symmetry folds the sum onto the real axis.

A network of modular jumps has become a piece of harmonic music—and its entire spectrum is written in the geometry of roots of unity.

That compact rule—translate a wave, collect its phases, and add them—turns the apparent complexity of a network into an exact spectral portrait.
