# Future Directions: Tropical Matrix Certificates

## Conjecture 1: Bounded Certificate Size for Higher Tropical Rank

**Precise statement.** For a matrix $A \in \mathbb{R}^{n \times m}$ of tropical rank $r > 1$, every obstruction to tropical rank $\leq r-1$ can be witnessed by a submatrix of size at most $r \times r$.

More precisely: if $A$ does not have tropical rank $\leq r-1$, then there exist row indices $i_1, \ldots, i_r$ and column indices $j_1, \ldots, j_r$ such that the $r \times r$ submatrix $A[i_1..i_r, j_1..j_r]$ does not have tropical rank $\leq r-1$.

**Test.** For $r = 2$: generate random $5 \times 5$ matrices of tropical rank 2 (as tropical sums of two rank-one matrices). Verify that rank > 1 is always witnessed by a $2 \times 2$ bad rectangle. For $r = 3$: construct matrices of tropical rank 3 and search for minimal obstructions to rank 2.

**Impact.** This would establish a tropical analogue of the classical result that matrix rank equals the size of the largest nonvanishing minor. It would give polynomial-time certificates for tropical rank bounds.

---

## Conjecture 2: Idempotent Rank-One Decomposition Uniqueness

**Precise statement.** If $A$ is a tropically idempotent $n \times n$ matrix with the tropical rectangle certificate (hence rank one), then the decomposition $A_{ij} = u_i + v_j$ satisfies:

$$\max_k (u_k + v_k) = 0$$

and the potentials $(u, v)$ are unique (no gauge freedom — the idempotence constraint fixes the gauge constant).

**Test.** Generate random rank-one idempotent matrices by choosing $u$ and setting $v_j = -u_j$ (which gives $\max_k(u_k + v_k) = 0$). Verify that potential extraction always returns potentials with $\max_k(u_k + v_k) = 0$, and that no other gauge choice preserves idempotence.

**Impact.** This would show that idempotence is a natural gauge-fixing condition in tropical linear algebra, analogous to how orthogonal projections in classical linear algebra are uniquely determined. It would connect to the theory of tropical eigenvalues.

---

## Conjecture 3: Certificate Propagation Under Tropical Convex Combinations

**Precise statement.** If matrices $A$ and $B$ both have the tropical rectangle certificate, then their tropical convex combination

$$C_{ij} = \max(\lambda + A_{ij}, \mu + B_{ij})$$

has the tropical rectangle certificate if and only if $A$ and $B$ have the same column-difference function (i.e., $A_{i,j_1} - A_{i,j_2} = B_{i,j_1} - B_{i,j_2}$ for all $i, j_1, j_2$).

**Test.** Generate pairs of rank-one matrices with (a) matching column differences and (b) different column differences. Compute tropical convex combinations and check the certificate. The conjecture predicts certificate holds in case (a) and fails in case (b).

**Impact.** This would characterize when tropical rank-one structure is preserved under tropical convex operations. It connects to tropical polytope theory and would give conditions under which rank-one certificates are stable under tropical perturbation.

---

## Conjecture 4: Helly Number for Rectangle Certificates

**Precise statement.** For an $n \times m$ matrix $A$, the tropical rectangle certificate holds if and only if it holds on every $3 \times 3$ submatrix (i.e., for every triple of rows and triple of columns, all $\binom{3}{2}^2 = 9$ rectangle equalities hold).

Equivalently: the Helly number for the tropical rectangle certificate system is 3.

**Test.** Construct matrices where all $2 \times 2$ submatrix certificates hold on $3 \times 3$ sub-selections but the full certificate fails. If no such matrix exists (across exhaustive search for small sizes), the conjecture is supported. A counterexample would refute it.

**Impact.** A Helly number of 3 would mean that certificate checking requires only $O(n^3 m^3)$ work on triples rather than $O(n^2 m^2)$ on pairs — not an improvement in this case, but conceptually it would show that the rectangle equality is "2-local" (which we already know) and the system has no hidden higher-order dependencies.

Actually, since the rectangle equality is inherently a 2-row, 2-column condition, the Helly number should be exactly 2. The real conjecture is: **no higher-order conditions are needed beyond pairwise ones**. This is already proved in our Theorem 1, but the generalization to tropical rank $r$ is open.

---

## Conjecture 5: Tropical Certificate Complexity Dichotomy

**Precise statement.** For fixed $r$, deciding whether a matrix has tropical rank $\leq r$ is:
- Polynomial-time for $r = 1$ (via the rectangle certificate, $O(n^2 m^2)$)
- NP-hard for $r \geq 3$
- Open for $r = 2$

Moreover, for $r = 1$, the certificate is always of size $O(nm)$ (the matrix itself), but for $r \geq 2$, there exist matrices where any certificate of rank $\leq r$ requires superpolynomial auxiliary data.

**Test.** For $r = 2$: attempt to reduce 3-SAT or another NP-hard problem to tropical rank-2 decision. For the certificate size claim: search for families of matrices where rank-2 certificates must encode a large amount of auxiliary information (e.g., the choice of which rows/columns participate in each rank-one component).

**Impact.** This would establish the computational complexity landscape of tropical rank, analogous to the classical result that matrix rank is polynomial but tensor rank is NP-hard. The certificate-based approach opens the door to complexity-theoretic study of tropical linear algebra.
