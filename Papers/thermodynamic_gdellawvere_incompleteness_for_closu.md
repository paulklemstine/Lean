# Effective Monotonicity Lemmas: Formally Verified Inequalities for Ordered Sequences

## Abstract

We present a formally verified library of fundamental inequalities that exploit monotonicity structure in finite sequences. The library, implemented in Lean 4 with the Mathlib mathematical library, includes complete machine-checked proofs of Chebyshev's sum inequality, the rearrangement inequality for pairs, Abel's summation formula (summation by parts), and Abel's inequality for oscillating sums. These results — absent from Mathlib at the time of writing — form a cohesive toolkit for reasoning about ordered data in both pure and applied mathematics. All proofs have been verified by the Lean kernel and depend only on the standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

Inequalities involving monotone sequences appear throughout mathematics, from analytic number theory to optimization and statistics. Three classical results stand out for their elegance and broad applicability:

1. **Chebyshev's Sum Inequality** (1882): For co-monotone sequences, the average of products is at least the product of averages.
2. **The Rearrangement Inequality**: Among all pairings of two sorted sequences, the concordant pairing maximizes the sum and the discordant pairing minimizes it.
3. **Abel Summation**: A discrete analog of integration by parts, enabling the transfer of regularity between factors in a sum.

Despite their fundamental nature, none of these results had been formalized in Lean's Mathlib library. This paper describes their formalization, the proof techniques used, and applications demonstrating their utility.

## 2. Main Results

### 2.1 The Rearrangement Inequality for Pairs

**Theorem** (`rearrangement_pair`). *For real numbers $a_1 \le a_2$ and $b_1 \le b_2$:*

$$a_1 b_2 + a_2 b_1 \le a_1 b_1 + a_2 b_2$$

*Proof.* The inequality is equivalent to $(a_2 - a_1)(b_2 - b_1) \ge 0$, which holds since both factors are non-negative. ∎

This deceptively simple result is the atomic building block for all rearrangement-type inequalities. In the formalization, the proof is a single call to `nlinarith`.

### 2.2 Monotone Pair Products

**Theorem** (`monotone_pair_mul_nonneg`). *Let $a, b : \text{Fin}(n) \to \mathbb{R}$ be monotone. Then for all $i, j$:*

$$(a(i) - a(j)) \cdot (b(i) - b(j)) \ge 0$$

*Proof.* Case split on $i \le j$ versus $j \le i$. In each case, both factors have the same sign by monotonicity. ∎

### 2.3 The Chebyshev Identity

The key insight behind Chebyshev's inequality is a purely algebraic identity that holds for *arbitrary* sequences (no monotonicity needed):

**Theorem** (`chebyshev_sum_identity`). *For any sequences $a, b : \text{Fin}(n) \to \mathbb{R}$:*

$$2\left(n \sum_i a_i b_i - \left(\sum_i a_i\right)\left(\sum_i b_i\right)\right) = \sum_i \sum_j (a_i - a_j)(b_i - b_j)$$

This identity decomposes the "covariance" of two finite sequences into a sum of pairwise products of differences. The proof proceeds by expanding $(a_i - a_j)(b_i - b_j) = a_i b_i - a_i b_j - a_j b_i + a_j b_j$ and using the fact that $\sum_i \sum_j a_i b_i = n \sum_i a_i b_i$ and $\sum_i \sum_j a_i b_j = (\sum_i a_i)(\sum_j b_j)$.

### 2.4 Chebyshev's Sum Inequality

**Theorem** (`chebyshev_sum_ineq`). *Let $a, b : \text{Fin}(n) \to \mathbb{R}$ be monotone. Then:*

$$\left(\sum_i a_i\right)\left(\sum_i b_i\right) \le n \sum_i a_i b_i$$

*Proof.* By the Chebyshev identity, it suffices to show $\sum_i \sum_j (a_i - a_j)(b_i - b_j) \ge 0$. Each term is non-negative by `monotone_pair_mul_nonneg`, so the sum is non-negative. ∎

**Theorem** (`chebyshev_sum_ineq_anti`). *If $a$ is monotone and $b$ is antitone:*

$$n \sum_i a_i b_i \le \left(\sum_i a_i\right)\left(\sum_i b_i\right)$$

*Proof.* Apply `chebyshev_sum_ineq` to $a$ and $-b$ (which is monotone when $b$ is antitone). ∎

### 2.5 Sum-of-Squares Lower Bound

**Theorem** (`sum_sq_lower_bound`). *For any sequence $a : \text{Fin}(n) \to \mathbb{R}$:*

$$\left(\sum_i a_i\right)^2 \le n \sum_i a_i^2$$

This is the discrete Cauchy-Schwarz inequality, a cornerstone of analysis. It follows from the Cauchy-Schwarz inequality applied to the constant function $1$ and the sequence $a$.

### 2.6 Abel Summation

**Theorem** (`abel_summation`). *For sequences $a, b : \mathbb{N} \to \mathbb{R}$ and any $n$:*

$$\sum_{k=0}^{n-1} a_k(b_{k+1} - b_k) = a_n b_n - a_0 b_0 - \sum_{k=0}^{n-1} (a_{k+1} - a_k) b_{k+1}$$

*Proof.* By induction on $n$. The base case is trivial. The inductive step uses the telescoping identity $a_k(b_{k+1} - b_k) + (a_{k+1} - a_k)b_{k+1} = a_{k+1}b_{k+1} - a_k b_k$. ∎

### 2.7 Abel's Inequality

**Theorem** (`abel_inequality`). *Let $a : \mathbb{N} \to \mathbb{R}$ be non-negative and antitone, and let $c : \mathbb{N} \to \mathbb{R}$ with partial sums bounded by $M$: $|\sum_{j < k} c_j| \le M$ for all $k$. Then:*

$$\left|\sum_{k=0}^{n-1} a_k c_k\right| \le a_0 \cdot M$$

*Proof.* Apply Abel's summation formula with partial sums $B_k = \sum_{j < k} c_j$. Then $\sum a_k c_k = a_n B_n - \sum (a_{k+1} - a_k) B_{k+1}$. By the triangle inequality and telescoping:

$$\left|\sum a_k c_k\right| \le a_n M + \sum |a_{k+1} - a_k| \cdot M = a_n M + (a_0 - a_n)M = a_0 M$$

using the fact that $\sum_{k=0}^{n-1} |a_{k+1} - a_k| = a_0 - a_n$ when $a$ is decreasing. ∎

## 3. Formalization Details

### 3.1 Design Choices

- **Sequences as functions**: We represent finite sequences as `Fin n → ℝ` for Chebyshev-type results and `ℕ → ℝ` for Abel summation. The `Fin n` representation leverages Lean's dependent types for automatic bound-checking, while `ℕ → ℝ` is more natural for the telescoping argument in Abel's formula.

- **Monotonicity via Mathlib**: We use Mathlib's `Monotone` and `Antitone` typeclasses, which provide `ha : Monotone a` meaning `∀ i j, i ≤ j → a i ≤ a j`. This integrates seamlessly with the existing library.

- **Algebraic identity separate from inequality**: The Chebyshev identity (`chebyshev_sum_identity`) is stated and proved independently of any monotonicity hypothesis. This separation of concerns makes the proof modular and the identity reusable in other contexts (e.g., computing exact covariances).

### 3.2 Proof Architecture

The dependency graph of our results:

```
rearrangement_pair
        ↓
monotone_pair_mul_nonneg
        ↓
chebyshev_sum_identity  ←——  (pure algebra, no monotonicity)
        ↓
chebyshev_sum_ineq
    ↙        ↘
chebyshev_sum_ineq_anti   sum_sq_lower_bound

abel_summation
        ↓
abel_summation_partial_sums
        ↓
abel_inequality
```

### 3.3 Axiom Usage

All theorems depend only on the standard Lean axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No additional axioms, `sorry`, or `@[implemented_by]` are used.

## 4. Applications

### 4.1 Optimal Assignment Problems

Chebyshev's inequality provides the mathematical foundation for a class of assignment problems. Given workers with skill levels $s_1 \le \cdots \le s_n$ and tasks with difficulty $d_1 \le \cdots \le d_n$, the total "synergy" $\sum s_i d_{\sigma(i)}$ over all assignments $\sigma$ is maximized by the concordant assignment ($\sigma = \text{id}$) and minimized by the discordant assignment ($\sigma$ reverses the order). This is precisely the rearrangement inequality.

Moreover, Chebyshev's inequality gives a quantitative bound: for any random assignment,

$$\mathbb{E}\left[\sum s_i d_{\sigma(i)}\right] = \frac{(\sum s_i)(\sum d_i)}{n} \le \frac{\sum s_i d_i}{1} \cdot \frac{n}{n} = \sum s_i d_i$$

This has applications in:
- **Scheduling**: Assigning jobs to machines to minimize total completion time
- **Economics**: Assortative matching in labor markets
- **Sports**: Optimal lineup ordering in relay races

### 4.2 Bounding Oscillating Sums in Number Theory

Abel's inequality is a fundamental tool in analytic number theory. Consider the Dirichlet series problem: estimate $\sum_{k=1}^{n} \frac{\chi(k)}{k}$ where $\chi$ is a Dirichlet character. Since $\chi$ has bounded partial sums and $1/k$ is decreasing, Abel's inequality gives

$$\left|\sum_{k=1}^{n} \frac{\chi(k)}{k}\right| \le \frac{M}{1} = M$$

where $M$ bounds the partial sums of $\chi$. This is the starting point for proving the non-vanishing of $L(1, \chi)$ and hence Dirichlet's theorem on primes in arithmetic progressions.

### 4.3 Statistical Covariance

The Chebyshev identity has a direct statistical interpretation. For a random variable uniformly distributed on $\{1, \ldots, n\}$, define $X = a(i)$ and $Y = b(i)$. Then:

$$\text{Cov}(X, Y) = \mathbb{E}[XY] - \mathbb{E}[X]\mathbb{E}[Y] = \frac{1}{n}\sum a_i b_i - \frac{(\sum a_i)(\sum b_i)}{n^2}$$

Chebyshev's inequality states that this covariance is non-negative when both functions are monotone — i.e., monotone functions of the same variable are positively correlated. This principle is known as the **FKG inequality** in its most general form and is fundamental to statistical mechanics and percolation theory.

### 4.4 Signal Processing

In signal processing, Abel summation provides a framework for analyzing weighted averages with decaying weights. If a signal $c_k$ has bounded partial sums (e.g., it oscillates without trending), and we apply decaying weights $a_k$ (e.g., exponential decay or $1/k$), Abel's inequality guarantees the weighted sum is bounded by the initial weight times the partial sum bound. This justifies the use of Cesàro summation and Abel summation methods for regularizing divergent series.

## 5. Discussion: Why Monotonicity Matters

*For the general reader*

Imagine you're organizing a relay race. You have four runners with speeds 2, 5, 7, and 9 meters per second, and four legs of the course with lengths 1, 3, 6, and 8 hundred meters. How should you assign runners to legs to minimize total time?

Intuition suggests putting the fastest runner on the longest leg. Chebyshev's inequality confirms this: the "concordant" assignment — matching the fastest to the longest, second-fastest to second-longest, and so on — always gives the best result. But it says more: it tells you *how much better* this assignment is compared to a random one.

The key insight is the **covariance decomposition**. The advantage of concordant pairing over average pairing decomposes into a sum of pairwise comparisons. Each comparison asks: "Is it better to pair runner A with leg X and runner B with leg Y, or vice versa?" When both sequences are sorted the same way, *every single pairwise comparison favors the concordant pairing*. There is no trade-off, no sacrifice — concordance is uniformly optimal.

This principle — that "similarity breeds synergy" — appears throughout nature and human institutions. It explains why assortative mating is prevalent in biology (tall mates with tall), why companies match their best employees to their most important projects, and why efficient markets tend toward concordant allocation of resources to opportunities.

The Abel summation formula, meanwhile, is the discrete version of a trick every calculus student learns: integration by parts. Just as $\int u\,dv = uv - \int v\,du$ transfers smoothness from one factor to another, Abel summation transfers regularity between sequences. This trick is so powerful that it forms the backbone of analytic number theory — from estimating sums over primes to proving that certain infinite series converge.

What makes formal verification valuable here? These inequalities are "well-known" and appear in every textbook on inequalities. But their proofs involve subtle details — the exact conditions needed, the direction of inequalities, the handling of edge cases (empty sums, single-element sequences). Machine verification eliminates any possibility of error and creates a foundation that other formal proofs can build upon with confidence.

## 6. Related Work

Chebyshev's sum inequality was first proved by P.L. Chebyshev in 1882 in the context of approximation theory. The rearrangement inequality in its full generality was established by Hardy, Littlewood, and Pólya in their landmark 1934 book *Inequalities*. Abel's summation formula dates to Abel's 1826 work on power series.

In the formal verification community, Mathlib contains AM-GM (`geom_mean_le_arith_mean_weighted`) and Cauchy-Schwarz, but not Chebyshev's sum inequality, the rearrangement inequality, or Abel summation. Our formalization fills this gap.

## 7. Future Directions

1. **Full Rearrangement Inequality**: Extend from pairs to arbitrary permutations, proving that the concordant permutation uniquely maximizes the sum.
2. **Continuous Chebyshev**: Formalize the integral version: $\int_a^b f(x)g(x)\,dx \cdot (b-a) \ge \int_a^b f(x)\,dx \cdot \int_a^b g(x)\,dx$ for co-monotone $f, g$.
3. **FKG Inequality**: Generalize to lattice-valued functions on partially ordered sets.
4. **Abel Summation for Series Convergence**: Use Abel's formula to formalize Dirichlet's test and Abel's test for convergence of infinite series.

## References

1. Chebyshev, P.L. "Sur les expressions approchées des intégrales définies par les autres prises entre les mêmes limites." *Proc. Math. Soc. Kharkov* 2 (1882), 93–98.
2. Hardy, G.H., Littlewood, J.E., and Pólya, G. *Inequalities*. Cambridge University Press, 1934.
3. Abel, N.H. "Untersuchungen über die Reihe $1 + \frac{m}{1}x + \frac{m(m-1)}{1\cdot 2}x^2 + \cdots$." *J. Reine Angew. Math.* 1 (1826), 311–339.
4. The Mathlib Community. *Mathlib: a unified library of mathematics formalized in Lean*. https://leanprover-community.github.io/mathlib4_docs/
