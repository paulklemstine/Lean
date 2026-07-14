# Higher Spectral Moments of the Seidel Matrix under Edge Flips

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

The Seidel matrix of a finite simple graph is the symmetric sign matrix with
zero diagonal, $-1$ on adjacent pairs, and $+1$ on non-adjacent distinct pairs.
Its spectral moments encode global structure, and its energy — the sum of the
absolute values of its eigenvalues — obeys a universal lower bound
$E_S \ge \sqrt{n(n-1)}$ coming from the graph-independent second moment
$\operatorname{tr}(S^2) = n(n-1)$. This constancy of the second moment makes it
completely insensitive to local edits: deleting a single edge leaves
$\operatorname{tr}(S^2)$ unchanged. We prove the contrarian companion fact that
the *third* moment is not insensitive, and we give its change in closed form. An
edge flip is a symmetric rank-two update $M \mapsto M + c\,(E^{ab} + E^{ba})$,
and for any real symmetric zero-diagonal matrix $M$ and distinct positions
$a \neq b$ we prove the exact identity
$\operatorname{tr}((M+P)^3) - \operatorname{tr}(M^3) = 6c\,(M^2)_{ab}$. Deleting a
Seidel edge is exactly the flip with weight $c = 2$, so the third Seidel moment
changes by $12\,(S^2)_{ab}$, while the second moment is invariant. We exhibit the
phenomenon on $K_3$ versus $K_3 - e = P_3$, where $\operatorname{tr}(S^3)$ jumps
from $-6$ to $+6$ while $\operatorname{tr}(S^2)$ stays fixed at $6$. Finally we
show that complementation negates the Seidel matrix and therefore preserves the
Seidel energy, so energy cannot be a monotone function of the number of edges.

## 1. Introduction

Spectral graph theory studies a graph through the eigenvalues of a matrix
attached to it. The choice of matrix shapes the theory. The adjacency matrix
$A$ records connections asymmetrically ($1$ for an edge, $0$ otherwise); the
Laplacian $L = D - A$ governs diffusion and cuts. The **Seidel matrix** $S$ is a
third natural encoding, treating adjacency and non-adjacency as equal and
opposite $\pm 1$ signs. Its distinctive feature is a large invariance group: two
graphs related by *Seidel switching* (choosing a vertex subset and toggling all
edges between it and its complement) have the same Seidel spectrum. The Seidel
matrix is thus the correct object for questions that are naturally invariant under
switching, and it is central to the theory of two-graphs, regular two-graphs,
conference matrices, and equiangular lines.

The **Seidel energy** $E_S = \sum_i |\lambda_i|$, the sum of the absolute values
of the Seidel eigenvalues, is a scalar invariant that compresses the whole
spectrum. It inherits switching invariance from the spectrum. A basic and robust
fact is the universal lower bound $E_S \ge \sqrt{n(n-1)}$, a Cauchy–Schwarz
consequence of the second moment being a graph-independent constant.

This paper isolates a precise sense in which the low moments *fail* to see local
structure, and repairs the failure at the next moment. Our contributions are:

1. A closed-form formula for the change in the third spectral moment of an
   arbitrary symmetric zero-diagonal matrix under a symmetric rank-two "flip"
   (Theorem 4.1).
2. The identification of Seidel edge deletion with the specific flip of weight
   $c = 2$ (Theorem 5.1), and the resulting statement that the third Seidel moment
   changes by $12\,(S^2)_{ab}$ (Theorem 5.3) while the second moment is invariant
   (Theorem 5.2).
3. An explicit minimal witness, $K_3$ versus $P_3$ (Section 6).
4. A proof that complementation negates the Seidel matrix and hence preserves
   Seidel energy, refuting monotonicity of energy in the edge count (Section 7).

## 2. Definitions and notation

Throughout, $V$ is a finite vertex set with $|V| = n$, and all matrices are
indexed by $V$ over $\mathbb{R}$. For a symmetric adjacency relation
$\mathrm{adj}$ on $V$ (with $\mathrm{adj}\,i\,j \iff \mathrm{adj}\,j\,i$), define
the **Seidel matrix** $S = S(\mathrm{adj})$ by

$$
S_{ij} = \begin{cases}
\;\;0 & i = j,\\
-1 & i \neq j,\ \mathrm{adj}\,i\,j,\\
+1 & i \neq j,\ \neg\,\mathrm{adj}\,i\,j.
\end{cases}
$$

Then $S$ is real symmetric with zero diagonal, so it is Hermitian and has $n$ real
eigenvalues $\lambda_1, \dots, \lambda_n$ counted with multiplicity.

**Spectral moments.** For $k \ge 1$, the $k$-th spectral moment is
$\mu_k = \sum_i \lambda_i^k = \operatorname{tr}(S^k)$, using that trace is the sum
of eigenvalues and is invariant under conjugation.

**Seidel energy.** $E_S = \sum_i |\lambda_i|$.

**Matrix units.** For positions $a, b$, let $E^{ab}$ denote the matrix with a $1$
in position $(a,b)$ and $0$ elsewhere. For a weight $c$, the **flip perturbation**
at the pair $\{a,b\}$ is

$$
P = P_{ab}(c) = c\,(E^{ab} + E^{ba}),
$$

the symmetric rank-two matrix adding $c$ to positions $(a,b)$ and $(b,a)$.

**Complement.** The complement relation is
$\overline{\mathrm{adj}}\,i\,j \iff (i \neq j \wedge \neg\,\mathrm{adj}\,i\,j)$.

## 3. Foundational moment identities

We record the elementary facts that frame the problem.

**Proposition 3.1 (First moment).** $\operatorname{tr}(S) = 0$.

*Proof.* The diagonal of $S$ is identically zero. $\square$

**Proposition 3.2 (Second moment is graph-independent).**
$\operatorname{tr}(S^2) = n(n-1)$ for every graph on $n$ vertices.

*Proof.* Since $S$ is symmetric, $(S^2)_{ii} = \sum_j S_{ij} S_{ji}
= \sum_j S_{ij}^2$. Each off-diagonal $S_{ij}$ is $\pm 1$, so $S_{ij}^2 = 1$, and
the diagonal term is $0$; hence $(S^2)_{ii} = n - 1$. Summing over the $n$
diagonal entries gives $\operatorname{tr}(S^2) = n(n-1)$, independent of the
adjacency. $\square$

**Corollary 3.3 (Universal energy floor).** For every graph on $n \ge 1$
vertices, $E_S \ge \sqrt{n(n-1)}$.

*Proof.* By Cauchy–Schwarz applied to $(|\lambda_i|)_i$ and the all-ones vector,
$\big(\sum_i |\lambda_i|\big)^2 \le n \sum_i \lambda_i^2$ gives a bound in the
wrong direction; instead use that among all real vectors on the sphere
$\sum_i \lambda_i^2 = n(n-1)$ with $\sum_i \lambda_i = 0$, the $\ell^1$ norm is
minimized by spreading the mass as evenly as possible in magnitude. Concretely,
$\big(\sum_i |\lambda_i|\big)^2 \ge \sum_i \lambda_i^2 = n(n-1)$ because the
cross terms $2\sum_{i<j} |\lambda_i||\lambda_j| \ge 0$. Hence
$E_S \ge \sqrt{n(n-1)}$. $\square$

**Remark 3.4 (Switching invariance).** Seidel switching acts by conjugating $S$
with a diagonal $\pm 1$ matrix, which preserves the spectrum, hence all moments
and the energy. The invariants above are therefore switching-class invariants.

The tension we exploit is now visible: $\operatorname{tr}(S^2)$ is a constant that
pins every spectrum to a common sphere, but a constant cannot detect a local edit.

## 4. The third-moment edge-flip formula

We work with a general symmetric zero-diagonal matrix; the Seidel specialization
follows in Section 5.

**Lemma 4.1 (Cubic trace expansion).** For any matrices $M, P$,
$$
\operatorname{tr}((M+P)^3) = \operatorname{tr}(M^3)
+ 3\operatorname{tr}(M^2 P) + 3\operatorname{tr}(M P^2)
+ \operatorname{tr}(P^3).
$$

*Proof.* Expand $(M+P)^3$ into eight products and collect using the cyclicity of
trace, $\operatorname{tr}(XY) = \operatorname{tr}(YX)$. The three products with a
single $P$ (namely $M^2P$, $MPM$, $PM^2$) all have equal trace, giving the
coefficient $3$; likewise the three products with a single $M$. $\square$

**Lemma 4.2 (Trace against a matrix unit).** For any matrix $A$ and scalar $r$,
$\operatorname{tr}(A\, E^{ab}\, r) = r\,A_{ba}$, and more generally the trace of a
product picks out the appropriate entries.

*Proof.* $\big(A\,(r E^{ab})\big)_{ii} = \sum_j A_{ij}(rE^{ab})_{ji}
= r\,A_{ia}[b = i]$, so summing the diagonal leaves $r\,A_{ba}$. $\square$

**Theorem 4.3 (Third-moment change under a flip).** Let $M$ be real symmetric
with $M_{ii} = 0$ for all $i$, let $a \neq b$, and let $c \in \mathbb{R}$. With
$P = c\,(E^{ab} + E^{ba})$,
$$
\boxed{\;\operatorname{tr}\big((M+P)^3\big) - \operatorname{tr}(M^3)
= 6\,c\,(M^2)_{ab}.\;}
$$

*Proof.* By Lemma 4.1 the change equals
$3\operatorname{tr}(M^2 P) + 3\operatorname{tr}(M P^2) + \operatorname{tr}(P^3)$.

*The $\operatorname{tr}(P^3)$ term vanishes.* $P = c(E^{ab} + E^{ba})$ is
supported off the diagonal on the single transposition $\{a,b\}$; $P^2$ is
diagonal, supported on positions $(a,a)$ and $(b,b)$ with value $c^2$, and $P^3$
is again supported only on the off-diagonal $\{a,b\}$ block, so
$(P^3)_{ii} = 0$ for all $i$ and $\operatorname{tr}(P^3) = 0$.

*The $\operatorname{tr}(M P^2)$ term vanishes.* $P^2 = c^2(E^{aa} + E^{bb})$ is
diagonal, so $\operatorname{tr}(M P^2) = c^2(M_{aa} + M_{bb}) = 0$ using the zero
diagonal of $M$. This is the crucial place the zero-diagonal hypothesis enters.

*The surviving term.* Using Lemma 4.2 and symmetry of $M$,
$\operatorname{tr}(M^2 P) = c\big[(M^2)_{ba} + (M^2)_{ab}\big] = 2c\,(M^2)_{ab}$,
since $M^2$ is symmetric. Therefore the total change is
$3 \cdot 2c\,(M^2)_{ab} + 0 + 0 = 6c\,(M^2)_{ab}$. $\square$

The formula is striking in its economy: the entire third-moment response to a
rank-two flip is controlled by the single entry $(M^2)_{ab} = \sum_k M_{ak}M_{kb}$
and the weight $c$. The higher-order self-interaction terms disappear exactly
because of the zero diagonal — the same structural feature responsible for the
first two moment identities.

## 5. Edge deletion as a weight-two flip

We now specialize $M = S$ to Seidel matrices.

**Theorem 5.1 (Edge deletion is a flip with $c = 2$).** Let $\mathrm{adj}$ and
$\mathrm{adj}'$ be symmetric adjacency relations that agree on every pair except
$\{a,b\}$, where $\{a,b\}$ is an edge of $\mathrm{adj}$ but not of
$\mathrm{adj}'$. Then
$$
S(\mathrm{adj}') = S(\mathrm{adj}) + 2\,(E^{ab} + E^{ba})
= S(\mathrm{adj}) + P_{ab}(2).
$$

*Proof.* Off the pair $\{a,b\}$ the two matrices are equal by hypothesis. At
$(a,b)$ and $(b,a)$, deletion changes an adjacent pair (Seidel entry $-1$) into a
non-adjacent pair (Seidel entry $+1$), an additive change of $+2$; the diagonal is
unchanged at $0$. $\square$

**Theorem 5.2 (Second moment is invariant under deletion).** For any two graphs on
the same vertex set, $\operatorname{tr}(S(\mathrm{adj}')^2)
= \operatorname{tr}(S(\mathrm{adj})^2)$. In particular deleting an edge does not
change $\operatorname{tr}(S^2)$.

*Proof.* By Proposition 3.2 both sides equal $n(n-1)$; the diagonal of $S^2$
counts off-diagonal pairs regardless of adjacency. $\square$

**Theorem 5.3 (Third moment detects deletion).** Under the hypotheses of
Theorem 5.1,
$$
\operatorname{tr}\big(S(\mathrm{adj}')^3\big)
- \operatorname{tr}\big(S(\mathrm{adj})^3\big)
= 12\,(S(\mathrm{adj})^2)_{ab}.
$$

*Proof.* Combine Theorem 5.1 with Theorem 4.3 applied to $M = S(\mathrm{adj})$
(symmetric, zero diagonal) and $c = 2$:
$6 \cdot 2 \cdot (S^2)_{ab} = 12\,(S^2)_{ab}$. $\square$

**Interpretation of $(S^2)_{ab}$.** The controlling quantity is
$(S^2)_{ab} = \sum_{k \neq a,b} S_{ak} S_{kb}$. Each summand is $+1$ when $k$
relates the same way to both $a$ and $b$ (both adjacent or both non-adjacent), and
$-1$ when $k$ relates oppositely. Thus $(S^2)_{ab}$ is the number of vertices
"agreeing" on $\{a,b\}$ minus the number "disagreeing." It is a signed common-
neighbourhood count, generically nonzero — which is precisely why the third moment
sees the edit that the sphere constraint $\sum_i \lambda_i^2 = n(n-1)$ cannot.

## 6. A minimal witness: $K_3$ versus $P_3$

The smallest nontrivial example makes the dichotomy concrete. Let $K_3$ be the
triangle on $\{1,2,3\}$, with Seidel matrix
$$
S(K_3) = \begin{pmatrix} 0 & -1 & -1 \\ -1 & 0 & -1 \\ -1 & -1 & 0
\end{pmatrix}.
$$
Deleting the edge $\{2,3\}$ (equivalently, working with the path $P_3$) flips two
entries to $+1$:
$$
S(P_3) = \begin{pmatrix} 0 & -1 & -1 \\ -1 & 0 & +1 \\ -1 & +1 & 0
\end{pmatrix}.
$$

Direct computation gives:

| Quantity | $K_3$ | $P_3 = K_3 - e$ | Change |
|---|---|---|---|
| $\operatorname{tr}(S^2)$ | $6$ | $6$ | $0$ |
| $\operatorname{tr}(S^3)$ | $-6$ | $+6$ | $+12$ |

The second moment is unchanged (both $6 = 3 \cdot 2$, matching $n(n-1)$). The third
moment jumps by $+12$. The formula predicts exactly this: the flipped position has
$(S(K_3)^2)_{23} = \sum_k S_{2k}S_{k3} = S_{21}S_{13} = (-1)(-1) = 1$, so the
predicted change is $12 \cdot 1 = 12$. Theory and computation agree.

## 7. Complementation and non-monotonicity of energy

**Theorem 7.1 (Complementation negates the Seidel matrix).** For any graph,
$$
S(\overline{\mathrm{adj}}) = -\,S(\mathrm{adj}).
$$

*Proof.* On the diagonal both sides are $0$. Off the diagonal, complementation
exchanges adjacency and non-adjacency, so a $-1$ becomes $+1$ and vice versa; that
is, each off-diagonal entry is negated. $\square$

**Theorem 7.2 (Energy is negation-invariant).** For any Hermitian matrix $A$,
$E(-A) = E(A)$, where $E$ denotes the sum of absolute values of eigenvalues.

*Proof.* The eigenvalues of $-A$ are the negatives of those of $A$, and
$|-\lambda| = |\lambda|$; sum over the spectrum. (Formally, the multiset of
absolute values of the roots of the characteristic polynomial is unchanged by the
substitution $x \mapsto -x$, which relates the characteristic polynomials of $A$
and $-A$.) $\square$

**Corollary 7.3 (Complementation preserves Seidel energy).**
$E_S(\overline{G}) = E_S(G)$ for every graph $G$.

*Proof.* Combine Theorems 7.1 and 7.2. $\square$

**Consequence.** A graph and its complement generally have very different edge
counts (their counts sum to $\binom{n}{2}$), yet identical Seidel energy. Hence
$E_S$ is **not** a monotone function of the number of edges — a clean refutation
of the naive heuristic "more edges, more energy." This complements the moment
story: even quantities that *do* respond to individual edits (like
$\operatorname{tr}(S^3)$) aggregate into an energy that is blind to global edge
density in this symmetric way.

## 8. Algorithms

Two elementary algorithms recur in verifying and exploring the results.

**Algorithm A (Moment computation via traces).** Given an adjacency relation,
build $S$, then compute $\operatorname{tr}(S^k)$ for $k = 1, 2, 3$ by repeated
matrix multiplication, at cost $O(n^3)$ per power. This avoids eigen-decomposition
and directly exposes the moment identities.

**Algorithm B (Predicted vs. actual flip response).** For a chosen edge $\{a,b\}$,
compute $(S^2)_{ab}$ in $O(n)$, predict the third-moment change $12(S^2)_{ab}$,
then delete the edge, recompute $\operatorname{tr}(S^3)$, and confirm the change
matches while $\operatorname{tr}(S^2)$ stays fixed.

## 9. Applications and discussion

**Design of experiments and coding.** Seidel/conference matrices underlie
optimal weighing designs and certain error-correcting codes; understanding how
their spectra respond to local perturbations informs robustness analysis of these
designs.

**Two-graphs and equiangular lines.** Switching classes of graphs correspond to
two-graphs, and regular two-graphs to equiangular line systems. The universal
floor $E_S \ge \sqrt{n(n-1)}$ and the moment invariants are switching-class
invariants, so they descend to two-graph invariants; the third-moment formula
gives a handle on how these invariants move under the elementary operation of an
edge flip within a class.

**Network science.** Treating $\pm 1$ as "friend/foe" (a signed-network reading of
the Seidel sign convention), the results say the coarse spectral energy is
insensitive to a global friend–foe swap, while the third moment tracks individual
relationship changes with an explicit sign given by a signed common-neighbour
count.

**The philosophical point.** Compressing a spectrum into a few moments buys
tractability at the cost of resolution. The second Seidel moment is powerful
*because* it is constant — it yields a free universal energy bound — but that same
constancy blinds it to local structure. The correct response is not to abandon
moments but to ascend to the first moment that resolves the change, where
structure (here, the zero diagonal) often makes the answer clean.

## 10. Future work

Several concrete directions extend the moment-level program.

1. **Sign of $(S^2)_{ab}$ on structured families.** Turn
   $(S^2)_{ab} = \sum_k S_{ak}S_{kb}$ into an explicit combinatorial count
   (agreeing minus disagreeing vertices) and determine its sign on Turán graphs,
   toward a strict edge-deletion inequality: on $T(n,r)$ with $r \ge 4$ and
   $n \ge 4r$, deleting any edge strictly increases the Seidel energy.

2. **From moments to energy.** Combine the exact third-moment change with the
   fixed second moment to constrain how eigenvalue mass crosses zero, converting an
   analytic energy inequality into an eigenvalue-counting statement: the sign of
   the energy change should be determined by how many eigenvalues the flip pushes
   across $0$.

3. **Fourth moment.** Compute $\operatorname{tr}((M+P)^4) - \operatorname{tr}(M^4)$
   for the same flip; the leading correction is expected to be
   $4\operatorname{tr}(M^2 P^2) + \cdots$, giving a second higher-moment invariant
   sensitive to edge changes and refining the eigenvalue-mass picture.

4. **Switching-refinement monotonicity.** Within a fixed switching class, all
   spectra live on the common sphere $\sum_i \lambda_i^2 = n(n-1)$; conjecturally
   energy is minimized at conference-type representatives and increases as the
   spectrum spreads, a majorization statement on the sphere.

5. **Sharpness of the floor.** The universal bound $E_S \ge \sqrt{n(n-1)}$ should
   be asymptotically attained only by conference two-graphs, since equality in the
   Cauchy–Schwarz step forces all eigenvalues to share a common magnitude — the
   regular two-graph condition.

## 11. Conclusion

We have shown that the Seidel second moment's celebrated constancy is exactly what
renders it blind to edge deletion, and that the third moment repairs this blindness
with an exact closed-form response $12(S^2)_{ab}$, derived from a general
zero-diagonal rank-two flip identity $6c(M^2)_{ab}$. The $K_3$-versus-$P_3$ witness
makes the dichotomy tangible, and the complementation symmetry shows that Seidel
energy — despite the third moment's sensitivity — is not monotone in the edge
count. Together these results form an elementary, self-contained foundation for a
moment-level theory of Seidel spectra under local edits.
