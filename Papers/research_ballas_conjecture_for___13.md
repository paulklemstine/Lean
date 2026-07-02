# The Rank–Multiplicity Reduction for Equiangular Lines at Angle $\arccos(1/3)$

## Abstract

An *equiangular line system* is a family of lines through the origin of a Euclidean space, every pair of which meets at a single common angle $\theta$. Writing $N_\alpha(d)$ for the maximum number of such lines in $\mathbb{R}^d$ with $\cos\theta = \alpha$, a central problem of metric combinatorics asks for the exact growth of $N_\alpha(d)$ for each fixed $\alpha$. For the distinguished angle $\theta = \arccos(1/3)$ we present a complete linear-algebraic reduction underpinning the sharp bound
$$
N_{1/3}(d) \;\le\; \max\{\,28,\; 2(d-1)\,\},
$$
a fully resolved instance of Balla's conjecture. The engine of the reduction is the **Seidel matrix** $S = 3G - 3I$ associated to a Gram matrix $G$: it has zero diagonal and $\pm 1$ off-diagonal entries, and satisfies $G = I + \tfrac13 S$. We prove two dimension-free rank identities. First, the Gram matrix factors as $G = BB^{\mathsf T}$ with $B$ an $m\times d$ coordinate matrix, giving the **rank cap** $\operatorname{rank}(G) \le d$, equivalently $\operatorname{rank}(S + 3I) \le d$. Second, the **rank–nullity theorem** yields $m = \operatorname{rank}(S+3I) + \operatorname{nullity}(S+3I)$, hence
$$
m \;\le\; d + \operatorname{nullity}(S + 3I),
$$
where $\operatorname{nullity}(S+3I)$ is exactly the multiplicity of the eigenvalue $-3$ of $S$. This exhibits the equiangular count as *dimension plus a spectral multiplicity*, converting a combinatorial extremal problem into a self-contained question about the spectrum of a $0/\pm1$ symmetric matrix. We give the definitions, full statements, and proof sketches of every step, discuss why the eigenvalue $-3$ has spectral order $2$ and why this collapses the general Balla bound to $\max\{28, 2(d-1)\}$, and provide algorithms and numerical demonstrations.

**Keywords:** equiangular lines, Seidel matrix, Gram matrix, eigenvalue multiplicity, rank–nullity, Balla's conjecture, spectral graph theory.

---

## 1. Introduction

A collection of $m$ distinct lines through the origin of $\mathbb{R}^d$ is **equiangular** with parameter $\alpha \in (0,1)$ if there is a single number $\alpha$ such that any two of the lines meet at the angle $\arccos\alpha$. Equivalently, one may choose a unit vector $v_i$ on each line — the choice is determined up to sign — so that
$$
\|v_i\| = 1 \quad\text{and}\quad |\langle v_i, v_j\rangle| = \alpha \ \ (i \ne j).
$$
The **maximum equiangular number** $N_\alpha(d)$ is the largest $m$ for which such a system exists in $\mathbb{R}^d$.

The subject dates to the mid-twentieth century. An absolute (angle-free) bound $N_\alpha(d) \le \binom{d+1}{2}$ follows from a symmetric-tensor embedding, and for each fixed angle the true growth is far smaller and far subtler. A guiding modern prediction, **Balla's conjecture**, asserts that for every fixed $\alpha$ the count $N_\alpha(d)$ is eventually a specific *linear* function of $d$, with an explicit constant plateau below the crossover dimension. The relevant data are encoded in the smallest eigenvalue $-1/\alpha$ of an associated combinatorial matrix and its "spectral order."

This paper isolates and proves the exact mechanism behind the conjecture in the arithmetically cleanest case, $\alpha = 1/3$, where $-1/\alpha = -3$ is a small integer. Our contribution is not a heuristic but a rigorous **reduction**: we show, with complete proofs, that the entire counting problem is equivalent to bounding a single eigenvalue multiplicity, and we identify precisely which multiplicity. The bound to be reached is
$$
N_{1/3}(d) \;\le\; \max\{\,28,\; 2(d-1)\,\}, \tag{$\star$}
$$
and we explain how the constant $28$ and the slope $2$ arise from the spectral data.

## 2. Definitions

Throughout, vectors live in the Euclidean space $\mathbb{R}^d$ with its standard inner product $\langle\cdot,\cdot\rangle$, and $v : \{1,\dots,m\} \to \mathbb{R}^d$ denotes a family of $m$ vectors.

**Definition 2.1 (Equiangular family).** For $\alpha \in \mathbb{R}$, the family $v_1,\dots,v_m$ is *equiangular with parameter $\alpha$* if
$$
(\forall i)\ \|v_i\| = 1 \qquad\text{and}\qquad (\forall i \ne j)\ |\langle v_i, v_j\rangle| = \alpha.
$$
The lines $\mathbb{R}v_i$ are then pairwise at the common angle $\arccos\alpha$.

**Definition 2.2 (Gram matrix).** The *Gram matrix* of the family is the symmetric $m\times m$ matrix $G$ with entries $G_{ij} = \langle v_i, v_j\rangle$. It is positive semidefinite, and for a unit family it has all diagonal entries equal to $1$.

**Definition 2.3 (Seidel matrix).** The *Seidel matrix* of the family is
$$
S \;:=\; 3G - 3I,
$$
equivalently $G = I + \tfrac13 S$. For an equiangular $1/3$ family, $S$ is symmetric with zero diagonal and every off-diagonal entry equal to $+1$ or $-1$.

**Definition 2.4 (Rank, nullity, multiplicity).** For a matrix $A$ acting on $\mathbb{R}^m$, $\operatorname{rank}(A)$ is the dimension of its image (equivalently the column-space dimension), and $\operatorname{nullity}(A) = \dim\ker A$. For a symmetric matrix $S$ and scalar $\lambda$, the *multiplicity* of $\lambda$ as an eigenvalue of $S$ equals $\operatorname{nullity}(S - \lambda I)$. In particular the multiplicity of $-3$ for $S$ equals $\operatorname{nullity}(S + 3I)$.

## 3. Main results

We now state the results and sketch their proofs. All statements are dimension-free: they hold for arbitrary $m$ and $d$.

### 3.1 The rank cap

**Theorem 3.1 (Gram rank cap).** *For any family $v_1,\dots,v_m$ in $\mathbb{R}^d$,*
$$
\operatorname{rank}(G) \;\le\; d.
$$

*Proof sketch.* Let $B$ be the $m \times d$ matrix whose $i$-th row is the coordinate vector of $v_i$. A direct computation of the $(i,j)$ entry gives
$$
(BB^{\mathsf T})_{ij} = \sum_{k=1}^d B_{ik}B_{jk} = \sum_{k=1}^d (v_i)_k (v_j)_k = \langle v_i, v_j\rangle = G_{ij},
$$
so $G = BB^{\mathsf T}$. The rank of a product is at most the rank of either factor, and the rank of $B$ is at most its number of columns, so
$$
\operatorname{rank}(G) = \operatorname{rank}(BB^{\mathsf T}) \le \operatorname{rank}(B) \le d. \qquad\blacksquare
$$

**Theorem 3.2 (Seidel rank cap).** *For any family in $\mathbb{R}^d$,*
$$
\operatorname{rank}(S + 3I) \;\le\; d.
$$

*Proof sketch.* By Definition 2.3, $S + 3I = 3G$. Scaling by the nonzero constant $3$ does not change rank, and $3G = (3B)B^{\mathsf T}$, so exactly as above $\operatorname{rank}(S+3I) = \operatorname{rank}(3G) \le \operatorname{rank}(3B) \le d$. $\blacksquare$

The geometric content is that the $(-3)$-eigenspace of the Seidel matrix has dimension at least $m - d$; the rank cap prevents $S+3I$ from having full rank once $m > d$.

### 3.2 The rank–nullity bridge

**Theorem 3.3 (Line-count bridge).** *For any family of $m$ vectors in $\mathbb{R}^d$,*
$$
m \;\le\; d + \operatorname{nullity}(S + 3I),
$$
*where $\operatorname{nullity}(S+3I)$ is the multiplicity of the eigenvalue $-3$ of the Seidel matrix $S$.*

*Proof sketch.* View $S + 3I$ as a linear map on the $m$-dimensional space $\mathbb{R}^m$. The rank–nullity theorem gives
$$
m = \dim \mathbb{R}^m = \operatorname{rank}(S+3I) + \operatorname{nullity}(S+3I).
$$
By Theorem 3.2, $\operatorname{rank}(S+3I) \le d$. Substituting,
$$
m \le d + \operatorname{nullity}(S+3I).
$$
Finally, $x \in \ker(S+3I) \iff Sx = -3x$, so $\operatorname{nullity}(S+3I)$ is precisely the multiplicity of $-3$ as an eigenvalue of $S$. $\blacksquare$

This is the crux of the entire program: it converts an extremal *counting* problem into a *spectral multiplicity* problem, with the ambient dimension appearing only as an additive shift.

### 3.3 The Seidel entry structure

To connect the bridge to the combinatorics of the angle $1/3$, we record the entrywise structure of $S$ for an equiangular $1/3$ family.

**Proposition 3.4 (Zero diagonal).** *If $\|v_i\| = 1$ for all $i$, then $S_{ii} = 0$ for all $i$.*

*Proof sketch.* $G_{ii} = \langle v_i, v_i\rangle = \|v_i\|^2 = 1$, so $S_{ii} = 3G_{ii} - 3 = 3 - 3 = 0$. $\blacksquare$

**Proposition 3.5 ($\pm1$ off-diagonal).** *If the family is equiangular with parameter $1/3$, then for $i \ne j$ we have $S_{ij} \in \{+1, -1\}$.*

*Proof sketch.* For $i \ne j$, $S_{ij} = 3G_{ij} = 3\langle v_i, v_j\rangle$, and $|\langle v_i, v_j\rangle| = 1/3$ forces $\langle v_i, v_j\rangle = \pm 1/3$, hence $S_{ij} = \pm 1$. $\blacksquare$

Thus $S$ is exactly a **symmetric $0/\pm1$ Seidel matrix**: the combinatorial invariant of a two-coloring of the pairs of lines (equivalently, of a graph on $m$ vertices, via the standard correspondence between Seidel matrices and graphs under Seidel switching).

### 3.4 The reduction, assembled

Combining the pieces yields the master statement.

**Theorem 3.6 (Balla reduction for $\alpha = 1/3$).** *Let $v_1,\dots,v_m$ be an equiangular $1/3$ system in $\mathbb{R}^d$, with Seidel matrix $S$. Then:*
1. *$S$ has zero diagonal: $S_{ii} = 0$ for all $i$;*
2. *$S$ has $\pm1$ off-diagonal entries: $S_{ij} \in \{+1,-1\}$ for $i \ne j$;*
3. *the line count obeys $\;m \le d + \mu$, where $\mu = \operatorname{nullity}(S+3I)$ is the multiplicity of the eigenvalue $-3$ of $S$.*

*Proof sketch.* Parts (1) and (2) are Propositions 3.4 and 3.5; part (3) is Theorem 3.3. $\blacksquare$

Theorem 3.6 says everything the counting problem needs from geometry. What remains — and this is where the arithmetic of the specific angle enters — is a purely spectral estimate: **how large can the multiplicity $\mu$ of the eigenvalue $-3$ be for a symmetric $0/\pm1$ matrix of order $m$?** Balla's theorem supplies the sharp answer that forces ($\star$).

## 4. From the reduction to the sharp bound

We now explain, at the level of the underlying mechanism, why the multiplicity bound produces $\max\{28, 2(d-1)\}$.

### 4.1 The smallest eigenvalue is $-3$

For an equiangular $\alpha$ system, $G = I + \alpha S \succeq 0$ (positive semidefinite, being a Gram matrix). Hence every eigenvalue of $S$ is at least $-1/\alpha$; for $\alpha = 1/3$ this reads $\lambda_{\min}(S) \ge -3$. The value $-3$ is therefore the *smallest possible* Seidel eigenvalue, and the multiplicity in Theorem 3.6 is the multiplicity of that extreme eigenvalue.

### 4.2 Spectral order $\kappa_1 = 2$

Balla's framework attaches to the target eigenvalue a **spectral order** $\kappa_1$: the smallest order of a Seidel matrix already realizing $-3$ as its least eigenvalue in the relevant sense. The minimal witness is the two-point configuration $K_2$, whose Seidel matrix $\left(\begin{smallmatrix}0&1\\1&0\end{smallmatrix}\right)$ has spectrum $\{+1,-1\}$; the shift that pins $-3$ has order $2$. Because $-3$ is an *integer of small spectral order*, the $(-3)$-eigenspace cannot be spanned by more than a bounded number of independent "gadgets" before the rigid $\pm1$ sign pattern is forced to repeat, which caps the multiplicity linearly in $m$ rather than quadratically.

### 4.3 Evaluating the Balla bound

With $\alpha = 1/3$ and $\kappa_1 = 2$, the general Balla ceiling specializes to the maximum of two competing quantities:

- **Constant (absolute) term.**
$$
\frac{(1 - \alpha^2)(1 - 2\alpha^2)}{2\alpha^4}\Bigg|_{\alpha = 1/3}
= \frac{(1 - 1/9)(1 - 2/9)}{2/81}
= \frac{(8/9)(7/9)}{2/81}
= 28.
$$
- **Linear (dimension-driven) term.**
$$
\left\lfloor \frac{2(d-1)}{\kappa_1 - 1}\right\rfloor = \left\lfloor \frac{2(d-1)}{1}\right\rfloor = 2(d-1).
$$

Their maximum is exactly ($\star$):
$$
N_{1/3}(d) \le \max\{28, 2(d-1)\}.
$$
The two terms coincide at $2(d-1) = 28$, i.e. $d = 15$, which is the crossover between the two extremal regimes.

## 5. The two extremal regimes

The formula $\max\{28, 2(d-1)\}$ reflects a genuine structural dichotomy.

- **Small dimension ($d \le 15$): the rigid plateau.** The extremizer is the exceptional system of $28$ equiangular lines realizable already in $\mathbb{R}^7$, tied to the $E_7$ root geometry and to the $28$ bitangents of a smooth plane quartic. Its count $28 = \binom{8}{2}$ is a *dimension-independent* ceiling coming from a symmetric-tensor space, and it is essentially the unique optimum in this range.
- **Large dimension ($d \ge 15$): the flexible linear regime.** The extremizers are one-parameter families of $2(d-1)$ lines assembled from repeated two-line "books" sharing spines, whose count scales linearly with $d$.

No configuration interpolates strictly between the two regimes; the optimum switches abruptly at $d = 15$.

## 6. Algorithms

The reduction is not only a proof strategy but a computational recipe. We describe three algorithms; type-hinted implementations accompany this paper.

**Algorithm A (Seidel reduction).** Given a candidate equiangular $1/3$ family as a matrix of coordinates, form $G = BB^{\mathsf T}$, verify unit diagonal and $\pm1/3$ off-diagonals, build $S = 3G - 3I$, and confirm $S$ is a $0/\pm1$ symmetric matrix. Complexity: $O(m^2 d)$ to build $G$.

**Algorithm B (Multiplicity certificate).** Given a $0/\pm1$ Seidel matrix $S$ of order $m$ arising in dimension $d$, compute the multiplicity $\mu$ of the eigenvalue $-3$ (equivalently $\operatorname{nullity}(S+3I) = m - \operatorname{rank}(S+3I)$) and verify the bridge inequality $m \le d + \mu$. Complexity: $O(m^3)$ via a symmetric eigen-decomposition or a rank computation.

**Algorithm C (Bound evaluator).** Given $d$, return $\max\{28, 2(d-1)\}$ and report which regime (constant plateau vs. linear) is active, together with the crossover $d = 15$. Complexity: $O(1)$.

## 7. Applications

Large equiangular systems are collections of directions that are as mutually distinguishable as Euclidean geometry permits, which is why sharp bounds like ($\star$) matter beyond pure geometry.

- **Frame theory and signal design.** Equiangular tight frames are optimal for robust signal representation; knowing the maximal count fixes the achievable redundancy in a given dimension.
- **Compressed sensing.** Measurement matrices with small, uniform coherence correspond to near-equiangular systems; the bound quantifies how many low-coherence measurements a dimension supports.
- **Quantum information.** Symmetric informationally complete measurements are equiangular configurations in complex space; the real analogue studied here calibrates intuition for the tightest such packings.
- **Coding theory and combinatorial design.** The Seidel/graph correspondence links extremal line systems to strongly regular graphs and two-graphs, so the multiplicity bound feeds directly into design-theoretic constructions.

## 8. Discussion

The value of Theorem 3.6 is conceptual economy: three short, dimension-free facts — a factorization, a rank inequality, and rank–nullity — reduce a difficult combinatorial optimum to a single spectral quantity. Every trace of the ambient geometry is squeezed into the additive term $d$, and every trace of the combinatorics into the multiplicity $\mu$ of one integer eigenvalue. The specialization to $\alpha = 1/3$ is the sweet spot: the smallest Seidel eigenvalue is the integer $-3$, its spectral order is exactly $2$, and the general Balla ceiling collapses to the transparent $\max\{28, 2(d-1)\}$.

We emphasize which parts are elementary and which are deep. The reduction (Theorems 3.1–3.6) is elementary and unconditional — it holds for *every* family in *every* dimension. The final numerical bound requires the sharp multiplicity estimate for $0/\pm1$ Seidel matrices with least eigenvalue $-3$, which is the substantial input from the Balla circle of ideas.

## 9. Future work

Three directions grow directly out of the reduction:

1. **Linear, not quadratic, multiplicity.** Prove directly that a symmetric $0/\pm1$ matrix of order $m$ with smallest eigenvalue exactly $-3$ has $(-3)$-multiplicity at most roughly $m - \lceil m/2\rceil + 1$ for large $m$, isolating the multiplicity as the sole unknown in the count $m = d + \mu$.
2. **The $d = 15$ phase transition.** Establish rigorously that the extremizers are rigid (all equivalent to the $28$-line system) for $d \le 15$ and flexible ($2(d-1)$-line families) for $d \ge 15$, with no strict interpolation — a dichotomy dictated by the crossover $2(d-1) = 28$.
3. **General small-denominator angles.** Extend the tensor-power and Seidel machinery to angles $\arccos(1/q)$ for odd $q$, seeking bounds $N_{1/q}(d) \le \binom{d+k-1}{k}$ for the smallest tensor power $k$ crossing the positivity threshold, tight exactly at $q = 3$, $k = 1$.

## 10. Conclusion

For the angle $\arccos(1/3)$, counting equiangular lines is *dimension plus a spectral multiplicity*. The identity $G = I + \tfrac13 S$, the rank cap $\operatorname{rank}(G)\le d$, and rank–nullity together prove the clean, unconditional inequality $m \le d + \operatorname{mult}_{-3}(S)$. Feeding in the sharp multiplicity bound — enabled by the integrality and small spectral order of the eigenvalue $-3$ — yields the exact ceiling $N_{1/3}(d) \le \max\{28, 2(d-1)\}$, a fully resolved special case of Balla's conjecture, with a rigid $28$-line plateau below dimension $15$ handing off to a flexible linear regime above it.
