# Separable Rank of Bivariate Targets and the EML Outer Count in Kolmogorov–Arnold Superpositions

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications

## Abstract

The Kolmogorov–Arnold superposition theorem guarantees that every continuous function $f:[0,1]^n\to\mathbb{R}$ is a finite sum of $2n+1$ outer univariate functions applied to sums of inner univariate functions. While the theorem fixes the number of *inner* functions, it says nothing about the number of *outer* terms required by a given target. We introduce the **separable rank** $\mathrm{SepRankLE}(f,r)$ of a bivariate target $f:\mathbb{R}\times\mathbb{R}\to\mathbb{R}$ — the property that $f(x,y)=\sum_{k<r} a_k(x)\,b_k(y)$ — which is exactly the number of outer functions in a finite *sum‑of‑products* Kolmogorov–Arnold superposition. When the factors are positive, every term is an **EML** (exp–log–multiply) expression $a_k(x)b_k(y)=\exp(\log a_k(x)+\log b_k(y))$, so separable rank equals the EML outer `exp` count. We prove four main results. (1) Separable rank $\le 1$ is *exactly* multiplicative separability, unifying the new notion with the classical one. (2) A **matrix sampling lower bound**: any $m\times m$ evaluation matrix $M_{ij}=f(x_i,y_j)$ of a separable‑rank‑$\le r$ target has matrix rank $\le r$; consequently one invertible sample forces $m\le r$. (3) The additive target $x+y$ has separable rank **exactly** $2$ (detected by a $2\times2$ sample with determinant $-1$). (4) The power‑sum family $p_N(x,y)=\sum_{k<N}x^k y^k$ has separable rank **exactly** $N$ (lower bound via a Vandermonde sample $VV^{\top}$ with $\det=(\det V)^2\ne 0$), so the number of EML outer terms is *unbounded* even though Kolmogorov–Arnold caps the number of inner functions at $2n+1$. All results have been formally verified in Lean 4.

## 1. Introduction

### 1.1 Background

Hilbert's thirteenth problem asked whether certain continuous functions of several variables are genuinely irreducible to functions of fewer variables. Kolmogorov (1956) and Arnold (1957) answered negatively in the strongest possible form.

**Theorem (Kolmogorov–Arnold superposition).** For every $n\ge 2$ there exist continuous functions $\psi_{q,p}:[0,1]\to\mathbb{R}$ ($0\le q\le 2n$, $1\le p\le n$) such that every continuous $f:[0,1]^n\to\mathbb{R}$ can be written as
$$f(x_1,\dots,x_n)=\sum_{q=0}^{2n}\Phi_q\!\left(\sum_{p=1}^{n}\psi_{q,p}(x_p)\right)$$
for suitable continuous outer functions $\Phi_q:\mathbb{R}\to\mathbb{R}$.

For $n=2$ the outer count is $2n+1=5$. The theorem is an existence statement: it does not identify the building blocks, nor does it quantify how many outer terms a *specific* target needs. This paper studies the second question through a concrete, computable invariant.

### 1.2 EML functions

An **EML** function is a finite composition of exponentiation ($\exp$), logarithm ($\log$), multiplication, addition, and constants. Formally we work with an inductive term algebra `EMLTerm` with constructors `var`, `const c`, `add`, `mul`, `expOf`, `logOf`, and an evaluation map $\mathrm{eval}:\texttt{EMLTerm}\to(\mathbb{R}\to\mathbb{R})$ defined by structural recursion (e.g. $\mathrm{eval}(\texttt{expOf } t)(x)=\exp(\mathrm{eval}(t)(x))$). The distinguished outer term is $\texttt{outerExp}=\texttt{expOf var}$ with $\mathrm{eval}(\texttt{outerExp})(u)=\exp u$, and the distinguished inner term is $\texttt{innerLog}=\texttt{logOf var}$ with $\mathrm{eval}(\texttt{innerLog})(t)=\log t$.

A basic identity, valid for $x>0$, is
$$\mathrm{eval}(\texttt{expOf}(\texttt{logOf } \texttt{var}))(x)=\exp(\log x)=x,$$
which is the EML‑level statement $\texttt{eval\_exp\_log}$.

### 1.3 The product as a rank‑one EML superposition

The simplest non‑trivial $n=2$ target is $f(x,y)=x\cdot y$. On the open positive quadrant $\{x>0,y>0\}$,
$$x\cdot y=\exp(\log x+\log y)=\mathrm{eval}(\texttt{outerExp})\big(\mathrm{eval}(\texttt{innerLog})(x)+\mathrm{eval}(\texttt{innerLog})(y)\big),$$
a Kolmogorov–Arnold superposition with a **single** outer EML term and exp/log‑depth $1$. This identity is not globally valid: $\exp>0$ everywhere, so it cannot reproduce $x\cdot y<0$. Globally one uses the polarization identity
$$x\cdot y=\tfrac14(x+y)^2-\tfrac14(x-y)^2,$$
a **two‑term** representation valid on all of $\mathbb{R}^2$ with outer EML terms $\pm\tfrac14\,(\cdot)^2$ and inner terms $\pm(\cdot)$. The contrast between the local rank‑one form and the global rank‑two form motivates a quantitative notion of outer count.

### 1.4 Contributions

We introduce separable rank and prove it is governed entirely by matrix rank of sampled evaluation grids. Our contributions are:

1. The definition `SepRankLE` and the equivalence with multiplicative separability at rank $1$ (`mulSeparable_iff_sepRankLE_one`).
2. A matrix sampling lower bound (`sample_rank_le`) and its determinant corollary (`sepRankLE_ge_of_det_ne_zero`).
3. Exact separable rank $2$ for the additive target (`add_sepRankLE_two`, `add_not_sepRankLE_one`).
4. Exact, *unbounded* separable rank $N$ for the power‑sum family (`powerSum_sepRankLE`, `powerSum_rank_ge`).

All statements are formalized and machine‑checked.

## 2. Definitions

Throughout, $f,g:\mathbb{R}\to\mathbb{R}\to\mathbb{R}$ are bivariate targets (curried), and $r,m,N\in\mathbb{N}$.

**Definition 2.1 (Multiplicative separability).** $f$ is *multiplicatively separable*, written $\mathrm{MulSeparable}(f)$, if there exist $a,b:\mathbb{R}\to\mathbb{R}$ with $f(x,y)=a(x)\,b(y)$ for all $x,y$.

**Definition 2.2 (Cross‑multiplicative identity).** $f$ satisfies $\mathrm{CrossMul}(f)$ if
$$f(x,y)\,f(x',y')=f(x,y')\,f(x',y)\qquad\text{for all }x,y,x',y'.$$
This is a checkable four‑point invariant. (Background: $\mathrm{MulSeparable}(f)\Rightarrow\mathrm{CrossMul}(f)$ always, and the converse holds once $f$ has one nonzero value.)

**Definition 2.3 (Separable rank).** $f$ has *separable rank at most $r$*, written $\mathrm{SepRankLE}(f,r)$, if there exist $a,b:\mathrm{Fin}\,r\to(\mathbb{R}\to\mathbb{R})$ such that
$$f(x,y)=\sum_{k=0}^{r-1} a_k(x)\,b_k(y)\qquad\text{for all }x,y.$$
The (exact) separable rank of $f$ is the least such $r$. This is precisely the number of outer functions in a sum‑of‑products Kolmogorov–Arnold superposition; when each $a_k,b_k>0$ it equals the number of EML `outerExp` terms because $a_k(x)b_k(y)=\exp(\log a_k(x)+\log b_k(y))$.

**Definition 2.4 (Evaluation/sampling matrix).** For row points $x:\mathrm{Fin}\,m\to\mathbb{R}$ and column points $y:\mathrm{Fin}\,m\to\mathbb{R}$, the *evaluation matrix* is $M\in\mathbb{R}^{m\times m}$ with $M_{ij}=f(x_i,y_j)$. (More generally row and column counts may differ.)

**Definition 2.5 (Power‑sum target).** For $N\in\mathbb{N}$,
$$p_N(x,y)=\sum_{k=0}^{N-1} x^k\,y^k.$$

## 3. Main Results

### 3.1 Rank one equals multiplicative separability

**Theorem 3.1 (`mulSeparable_iff_sepRankLE_one`).** For every bivariate $f$,
$$\mathrm{MulSeparable}(f)\iff\mathrm{SepRankLE}(f,1).$$

*Proof sketch.* ($\Rightarrow$) If $f(x,y)=a(x)b(y)$, take the single‑index families $a_0=a$, $b_0=b$; the one‑term sum $\sum_{k<1}a_k(x)b_k(y)=a_0(x)b_0(y)$ equals $f$. ($\Leftarrow$) Conversely, a rank‑$\le 1$ representation has a single index $k=0$, and $\sum_{k<1}a_k(x)b_k(y)=a_0(x)b_0(y)$, exhibiting $f$ as the product $a_0(x)\,b_0(y)$. The only formal content is the evaluation of a one‑element `Fin` sum. $\square$

Together with the classical equivalence $\mathrm{MulSeparable}\iff\mathrm{CrossMul}$ (on targets with a nonzero value), Theorem 3.1 shows that separable rank $\le 1$ is decidable by a four‑point identity.

### 3.2 The matrix sampling lower bound

**Theorem 3.2 (`sample_rank_le`).** If $\mathrm{SepRankLE}(f,r)$, then for all $m$ and all point families $x,y:\mathrm{Fin}\,m\to\mathbb{R}$,
$$\mathrm{rank}\big(M\big)\le r,\qquad M_{ij}=f(x_i,y_j).$$

*Proof sketch.* Let $f(x,y)=\sum_{k<r}a_k(x)b_k(y)$. Define $A\in\mathbb{R}^{m\times r}$ by $A_{ik}=a_k(x_i)$ and $B\in\mathbb{R}^{r\times m}$ by $B_{kj}=b_k(y_j)$. Then
$$(AB)_{ij}=\sum_{k<r}A_{ik}B_{kj}=\sum_{k<r}a_k(x_i)b_k(y_j)=f(x_i,y_j)=M_{ij},$$
so $M=AB$. Therefore $\mathrm{rank}(M)\le\mathrm{rank}(A)\le r$, using $\mathrm{rank}(AB)\le\mathrm{rank}(A)$ and that an $m\times r$ matrix has rank at most its width $r$. $\square$

**Corollary 3.3 (`sepRankLE_ge_of_det_ne_zero`).** If $\mathrm{SepRankLE}(f,r)$ and some $m\times m$ evaluation matrix $M$ has $\det M\ne 0$, then $m\le r$.

*Proof sketch.* A square matrix with nonzero determinant is invertible (a unit), hence has full rank $m$. By Theorem 3.2, $m=\mathrm{rank}(M)\le r$. $\square$

Corollary 3.3 is the *lower‑bound engine*: a single invertible sample certifies a lower bound on rank. It converts an infinite‑dimensional question about univariate decompositions into a finite determinant computation.

### 3.3 The product: rank one

**Theorem 3.4 (`mul_sepRankLE_one`).** The product target $f(x,y)=x\cdot y$ satisfies $\mathrm{SepRankLE}(f,1)$.

*Proof sketch.* Take $a_0=b_0=\mathrm{id}$; then $\sum_{k<1}a_k(x)b_k(y)=x\cdot y$. $\square$

### 3.4 The sum: rank exactly two

**Theorem 3.5 (upper bound, `add_sepRankLE_two`).** The additive target $f(x,y)=x+y$ satisfies $\mathrm{SepRankLE}(f,2)$.

*Proof sketch.* Use the two‑term decomposition $a=[\,\mathrm{id},\,1\,]$, $b=[\,1,\,\mathrm{id}\,]$:
$$x+y=x\cdot 1+1\cdot y=\sum_{k<2}a_k(x)b_k(y).\qquad\square$$

**Theorem 3.6 (lower bound, `add_not_sepRankLE_one`).** The additive target does *not* satisfy $\mathrm{SepRankLE}(f,1)$. Consequently its separable rank is exactly $2$.

*Proof sketch.* Sample at $x,y\in\{0,1\}$:
$$M=\begin{pmatrix}0&1\\1&2\end{pmatrix},\qquad \det M = 0\cdot 2-1\cdot 1=-1\ne 0.$$
If $\mathrm{SepRankLE}(f,1)$ held, Corollary 3.3 would give $2\le 1$, a contradiction. With Theorem 3.5 the exact rank is $2$. $\square$

### 3.5 The power‑sum family: unbounded rank

**Theorem 3.7 (upper bound, `powerSum_sepRankLE`).** For every $N$, $\mathrm{SepRankLE}(p_N,N)$.

*Proof sketch.* By definition $p_N(x,y)=\sum_{k<N}x^k y^k$; take $a_k(x)=x^k$ and $b_k(y)=y^k$. The decomposition is term‑for‑term, so it holds by reflexivity. $\square$

**Theorem 3.8 (lower bound, `powerSum_rank_ge`).** If $\mathrm{SepRankLE}(p_N,r)$ then $N\le r$. Consequently the separable rank of $p_N$ is exactly $N$.

*Proof sketch.* Sample at the distinct points $t_i=i$ for $i=0,\dots,N-1$ in both coordinates. The evaluation matrix is
$$M_{ij}=p_N(i,j)=\sum_{k<N} i^k j^k=\sum_{k<N} V_{ik}V_{jk}=(VV^{\top})_{ij},$$
where $V\in\mathbb{R}^{N\times N}$ is the Vandermonde matrix $V_{ik}=i^{k}$. Since the $t_i$ are distinct,
$$\det V=\prod_{0\le i<j<N}(t_j-t_i)\ne 0,\qquad\text{hence}\qquad \det M=\det(VV^{\top})=(\det V)^2\ne 0.$$
By Corollary 3.3, $N\le r$. With Theorem 3.7 the exact rank is $N$. $\square$

**Corollary 3.9 (unbounded EML outer count).** The separable rank of bivariate continuous targets is unbounded: $\sup_N \mathrm{SepRank}(p_N)=\infty$. Hence there is no fixed bound on the number of EML outer `exp` terms in a sum‑of‑products Kolmogorov–Arnold representation, even though the number of inner functions is capped at $2n+1$.

### 3.6 The EML bridge

When all factors $a_k(x),b_k(y)$ are strictly positive, each separable term is a single catalog `outerExp` applied to a sum of inner `log`s:
$$a_k(x)\,b_k(y)=\exp\big(\log a_k(x)+\log b_k(y)\big)=\mathrm{eval}(\texttt{outerExp})\big(\log a_k(x)+\log b_k(y)\big).$$
Thus a positive separable‑rank‑$r$ target is a sum of $r$ EML `outerExp` terms (the statement `sepRank_pos_eml`), and the separable rank coincides exactly with the EML outer count. This is the precise bridge between linear‑algebraic rank and EML representation complexity.

## 4. Algorithms

### 4.1 Separable‑rank lower bound via sampling

The constructive engine behind all lower bounds is a sampling‑and‑determinant procedure.

**Input:** a target $f$, a candidate width $r$, a set of $m$ row points and $m$ column points.
**Output:** a certificate that $\mathrm{SepRank}(f)\ge m$ whenever the sample is invertible.

```
function SEPARABLE_RANK_LOWER_BOUND(f, xs, ys):
    m  <- length(xs)            # = length(ys)
    M  <- matrix where M[i][j] = f(xs[i], ys[j])
    d  <- det(M)
    if d != 0:
        return ("rank >= m", m)         # by Corollary 3.3
    else:
        return ("inconclusive", None)   # try a different / larger sample
```

By Theorem 3.2 the sampled rank never exceeds the true separable rank, so any invertible $m\times m$ sample certifies $\mathrm{SepRank}(f)\ge m$. For the power‑sum the canonical sample $t_i=i$ yields $M=VV^{\top}$ with $\det M=(\det V)^2$, certifying $\mathrm{SepRank}(p_N)\ge N$.

### 4.2 Vandermonde determinant detector

To certify the power‑sum lower bound one computes a Vandermonde determinant.

```
function VANDERMONDE_DET(points):       # points = [t_0, ..., t_{N-1}]
    prod <- 1
    for j in 0 .. N-1:
        for i in 0 .. j-1:
            prod <- prod * (points[j] - points[i])
    return prod                          # = det V, nonzero iff points distinct
```

Then $\det(VV^{\top})=(\det V)^2$. Complexity is $O(N^2)$ for the product form, versus $O(N^3)$ for a direct Gaussian elimination on $M$.

## 5. Numerical Illustrations

For $p_3(x,y)=1+xy+x^2y^2$, sampling at $t=(0,1,2)$ gives
$$V=\begin{pmatrix}1&0&0\\1&1&1\\1&2&4\end{pmatrix},\quad \det V=(1-0)(2-0)(2-1)=2,\quad \det(VV^{\top})=4\ne 0,$$
certifying separable rank $\ge 3$; with the trivial $3$‑term decomposition the rank is exactly $3$. For the sum, the $2\times2$ sample at $\{0,1\}$ gives $\det=-1$, certifying rank exactly $2$. These are reproduced in `demo.py`.

## 6. Applications

- **Kolmogorov–Arnold Networks (KANs).** Sum‑of‑products layers are exactly separable‑rank decompositions; Theorem 3.8 gives a hard, target‑dependent lower bound on the width such a layer must have to represent a function exactly, independent of optimization.
- **Low‑rank function approximation.** The sampling bound is the function‑space analogue of the Eckart–Young phenomenon: sampled rank lower‑bounds the number of separable terms, guiding separation‑of‑variables and tensor‑train methods.
- **Certified complexity.** Corollary 3.3 turns "this surface is irreducibly complex" into a single determinant computation — a finite, auditable certificate.

## 7. Discussion

The results expose a clean decoupling: Kolmogorov–Arnold pins the number of *inner* univariate functions at $2n+1$, but the number of *outer* EML terms is unbounded across targets (Corollary 3.9). The mechanism is uniform — sampling a sum of products is a matrix factorization (Theorem 3.2) — which is why a single linear‑algebraic principle controls every lower bound. The role of the Vandermonde matrix is the bridge that promotes the polynomial structure of the power‑sum into an invertible sample.

A subtlety worth emphasizing is locality. The product's rank‑one form $\exp(\log x+\log y)$ is valid only where logarithms exist (the positive quadrant); globally the product needs the rank‑two polarization. Separable rank makes this a precise statement about a rank jump across the coordinate axes.

## 8. Future Directions

1. **Separable rank equals the supremum of sampled matrix ranks.** Conjecture: for every bivariate $f$, the separable rank equals the supremum over finite point sets of $\mathrm{rank}(M_{ij}=f(x_i,y_j))$; i.e. the upper bound `sample_rank_le` is tight, and a representation of width equal to that supremum always exists. The missing half is a *construction* realizing the supremum — a finite‑rank‑factorization theorem for the kernel $f$.
2. **Multiplicativity for tensor products.** Conjecture: if $h(x_1,x_2,y_1,y_2)=f(x_1,y_1)\,g(x_2,y_2)$ then $\mathrm{SepRank}(h)=\mathrm{SepRank}(f)\cdot\mathrm{SepRank}(g)$, mirroring $\mathrm{rank}(A\otimes B)=\mathrm{rank}(A)\,\mathrm{rank}(B)$ via Kronecker products.
3. **Polarization is rank‑optimal globally.** Conjecture: over all of $\mathbb{R}^2$ (no positivity), $x\cdot y$ has separable rank exactly $2$, and the local rank‑one $\exp(\log x+\log y)$ form is a genuine rank jump from $1$ (local) to $2$ (global), detectable by a sample crossing the axes.
4. **Prescribed rank with bounded EML depth.** Conjecture: for each $N$ there is a target of separable rank $N$ whose inner and outer functions are EML terms of exp/log‑depth $\le 1$; the candidate is $p_N(x,y)=\sum x^k y^k=\sum\exp(k\log x+k\log y)$ on the positive quadrant.

## 9. Conclusion

We have defined separable rank, identified it with the EML outer count of sum‑of‑products Kolmogorov–Arnold superpositions, and shown it is governed entirely by the matrix rank of sampled evaluation grids. The additive target has rank exactly $2$, and the power‑sum family realizes every rank $N$, proving the outer count is unbounded. The proofs reduce deep representation questions to elementary, machine‑checkable determinant computations, with the Vandermonde determinant providing the decisive sample.
