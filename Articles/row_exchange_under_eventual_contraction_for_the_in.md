# When Symmetry Survives Forever: Row-Swaps on an Infinite Lattice Strip

## A tiling problem that never ends

Imagine an infinitely tall strip of squared paper, only five columns wide but
stretching upward without limit. On each tiny edge of this grid you are allowed
to place — or not place — an arrow, subject to local rules at every vertex. In
statistical physics this is a *vertex model*: each legal arrangement of arrows is
a microscopic state of a crystal, and the central question is always the same.
If you fix the arrows along the very bottom and the (infinitely distant) top, how
do all the allowed states in between add up?

The bookkeeping device that physicists use is the **transfer operator**. Think of
it as a machine that takes the statistical description of one horizontal row of the
lattice and produces the description of the next row up. Stack the rows, and the
whole half-infinite strip becomes a *product* of these operators, one factor per
row. Because our strip is five columns wide, each transfer operator is naturally a
$5 \times 5$ matrix of real numbers.

Two questions hover over every such model:

1. **Does the infinite product mean anything at all?** Multiplying infinitely many
   matrices is dangerous; the answer can blow up to nonsense.
2. **Do the symmetries of the local rules survive the infinite stacking?** A single
   vertex might look the same if you swap two of the five columns. But "looks the
   same locally" is a microscopic statement. Does the *macroscopic* object — the
   sum over the entire infinite strip — also look the same after the swap?

This article is about a clean, fully rigorous answer to both questions, under a
hypothesis that is as weak as one could reasonably hope for. The punchline: in the
regime where correlations decay, **local symmetry is never spontaneously broken by
the infinite tower. What is symmetric at the bottom stays symmetric all the way
up.**

## The asymmetric five-vertex model, in one paragraph

The classical *five-vertex model* is a close cousin of the famous six-vertex (or
"square ice") model, with one of the six vertex types forbidden. "Asymmetric"
means the Boltzmann weights — the statistical costs of the various vertex
configurations — are allowed to differ in the two directions, controlled by
spectral parameters that physicists call $v$ and $z$. The original motivating
conjecture concerned a *row-exchange identity*: swapping two rows of boundary data
should change the infinite partition function only by a fixed, explicit scalar
factor of the shape $f(v/z)/\alpha^2$, where $\alpha \neq 0$ is a normalization.
Lemma 2.1 of the paper that started this line proved exactly such an identity, but
only under a *uniform* contraction assumption: every single column had to contract.

The natural question — and the one resolved here — is whether that uniformity is
really needed, or whether **eventual** contraction suffices.

## The weakest reasonable hypothesis: eventual contraction

Here is the key relaxation. Instead of demanding that *every* row's operator be a
contraction, we only ask that they become contractions *eventually*. Formally, a
sequence of transfer operators $M_0, M_1, M_2, \dots$ is **eventually contracting**
if there is a single ratio $c < 1$ and a threshold $N$ such that

$$\|M_k\| \le c < 1 \quad \text{for all } k \ge N.$$

The first $N$ rows are allowed to do anything at all — they may even expand. Only
from some height onward must the operators shrink. This is precisely the
statistical-mechanics statement that *far up the strip, correlations decay*. The
opening rows near the boundary can be wild; what matters is the long-run behavior.

To make the half-strip an honest mathematical object we accumulate the operators
into a single product. Writing $P_m$ for the product of the first $m$ rows,

$$P_0 = I, \qquad P_{m+1} = M_m \, P_m, \qquad \text{so} \qquad
P_m = M_{m-1} M_{m-2} \cdots M_1 M_0.$$

In the formalized development this accumulated product is called `prodDown`.

**First theorem (the product washes out).** *If the sequence is eventually
contracting, then the norm of the accumulated half-strip product tends to zero:*

$$\|P_m\| \longrightarrow 0 \quad \text{as } m \to \infty.$$

The proof idea is exactly what intuition suggests. Once we pass the threshold $N$,
every additional factor multiplies the size by at most $c$, so

$$\|P_m\| \;\le\; \|P_N\| \cdot c^{\,m-N} \quad \text{for } m \ge N,$$

and because $0 \le c < 1$ the geometric tail $c^{\,m-N}$ collapses to zero. A
squeeze argument finishes the job. The finitely many unruly bottom rows contribute
only the harmless constant $\|P_N\|$; they cannot save a tower that is doomed to
shrink. In the code this is `prodDown_tendsto_zero`, and its specialization to the
genuine five-vertex setting is `transferProduct_vanishes`.

So question 1 is settled: in the eventually-contracting regime the infinite strip
is perfectly well-behaved.

## Swapping two rows: a permutation that is its own undo

Now for the symmetry. Exchanging two of the five rows of the lattice is performed
by a **permutation matrix** $S$ — concretely $S$ is the matrix of the transposition
that swaps indices $i$ and $j$, written `rowExchange i j` in the formalization.
Conjugating a transfer operator $A$ by $S$, i.e. forming $S A S$, simultaneously
swaps rows $i,j$ and columns $i,j$ of $A$.

Two features of $S$ make everything work:

- **It is an involution:** $S \cdot S = I$. Swapping the same two rows twice
  returns you to where you started, so $S$ is its own inverse.
- **It has unit size:** $\|S\| = 1$. A pure relabeling neither stretches nor
  shrinks; the largest absolute row sum of a permutation matrix is exactly $1$.

We say a transfer operator $A$ is *symmetric under the swap* when it commutes with
$S$:

$$S \, A = A \, S.$$

This is the precise sense in which "the local Boltzmann weights don't notice the
swap." The question is whether the *infinite* object inherits this.

## The infinite object: a resolvent built from a geometric series

When $\|A\| < 1$, the half-infinite stacking of a single homogeneous transfer
operator is captured by the **resolvent**

$$(I - A)^{-1} \;=\; \sum_{n=0}^{\infty} A^{n} \;=\; I + A + A^2 + A^3 + \cdots,$$

the matrix version of the familiar geometric series $\tfrac{1}{1-a} = 1 + a + a^2 +
\cdots$. The contraction $\|A\| < 1$ is exactly what guarantees this infinite sum
converges to a genuine matrix. This resolvent *is* the generating function for the
entire half-strip: the term $A^n$ records the contribution of going up $n$ rows.

Here is the heart of the matter.

**Main theorem (symmetry survives to infinity).** *If $S$ is the row-swap
involution ($S \cdot S = I$), if it commutes with the contraction $A$ (so
$S A = A S$), and if $\|A\| < 1$, then conjugating the resolvent by $S$ leaves it
completely unchanged:*

$$S \, (I - A)^{-1} \, S \;=\; (I - A)^{-1}.$$

In the formalization this is `conj_inverse_one_sub_eq`, with the equivalent
series-form statement $S\bigl(\sum_n A^n\bigr)S = \sum_n A^n$ recorded as
`conj_tsum_geom_eq`, and the five-vertex specialization as
`rowExchange_resolvent_invariant`.

## Why it is true: the swap slides through, term by term

The proof is a small marvel of economy, and you can follow it without any heavy
machinery.

**Step 1 — handle one power at a time.** Look at a single term $A^n$ in the series.
Because $S$ commutes with $A$, it commutes with every power of $A$ too, so it can be
slid past $A^n$ until it meets its twin:

$$S \, A^{n} \, S \;=\; A^{n} \, S \, S \;=\; A^{n} \, I \;=\; A^{n}.$$

The two copies of $S$ annihilate one another, and the power is returned untouched.
This is the lemma `conj_pow_eq`: *each individual power is fixed by the
conjugation.*

**Step 2 — pass to the infinite sum.** Conjugation $y \mapsto S y S$ is a
*continuous, additive* operation on matrices. Continuous additive maps respect
convergent infinite sums: you may apply them term by term. Since each term is
unchanged by Step 1, the whole sum is unchanged. Uniqueness of limits then
transports the fixed-point property from the individual terms up to the resolvent
itself.

That is the entire argument. Notice what it avoids: we never invert a matrix by
hand, never compute determinants, never expand $5\times5$ formulas. The symmetry is
inherited *structurally*, one geometric term at a time, and the only analytic
ingredient is that summation commutes with a continuous map.

A concrete miniature makes it vivid. Take the symmetric two-state contraction

$$A = \begin{pmatrix} 0.2 & 0.1 \\ 0.1 & 0.2 \end{pmatrix}, \qquad
S = \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}.$$

Here $S$ swaps the two coordinates, $A$ is unchanged by that swap ($SA = AS$), and
$\|A\| = 0.3 < 1$. Summing the geometric series gives

$$(I-A)^{-1} = \begin{pmatrix} 1.28 & 0.16 \\ 0.16 & 1.28 \end{pmatrix},$$

a matrix that is manifestly invariant when you swap its two rows *and* its two
columns. The diagonal entries are equal, the off-diagonal entries are equal —
exactly the fingerprint of $S(I-A)^{-1}S = (I-A)^{-1}$. The same phenomenon holds
verbatim for the genuine $5 \times 5$ five-vertex operators.

## One swap, or a whole group of them?

Once you see the proof, you realize the involution property $S \cdot S = I$ was a
convenience, not a necessity. The slide-through argument only needs that $S$ be
*invertible* and commute with $A$. Replacing $S S = I$ by the general identity
$S S^{-1} = I$ runs the proof unchanged for **any invertible matrix** $u$:

**Symmetry-group theorem.** *For any unit (invertible) $u$ commuting with a
contraction $A$ ($\|A\| < 1$),*

$$u \, (I - A)^{-1} \, u^{-1} \;=\; (I - A)^{-1}.$$

This is `conj_unit_inverse_one_sub_eq`. Its consequence is conceptually large: if a
whole *group* of column-permutations leaves the local weights invariant, then the
infinite resolvent is invariant under the entire group, not merely under one
transposition. There is no spontaneous symmetry breaking inside the contraction
radius — the macroscopic object is at least as symmetric as the microscopic rules.

## How big can the infinite object get?

A symmetry statement is most useful when paired with a size estimate. The same
geometric series that builds the resolvent also bounds it, by comparing the matrix
series termwise to the ordinary scalar one:

**Neumann bound.** *If $\|A\| < 1$, then*

$$\bigl\|(I - A)^{-1}\bigr\| \;\le\; \frac{1}{\,1 - \|A\|\,}.$$

This is `norm_inverse_one_sub_le`. Each matrix power obeys $\|A^n\| \le \|A\|^n$, so
the matrix series is dominated term-by-term by the scalar series $\sum_n \|A\|^n =
1/(1-\|A\|)$. And because the row-swap $S$ has unit norm, this bound is *itself*
row-exchange invariant: swapping rows changes neither the resolvent nor its size
estimate. Finally, since the accumulated transfer product already vanishes, its
row-exchanged version $S P_m$ vanishes too — multiplying by the unit-norm $S$
cannot rescue a sequence already heading to zero. That last observation is
`rowExchange_transferProduct_vanishes`.

## What it all means

Strip away the lattice language and the message is strikingly simple. A
half-infinite product of operators, each eventually a contraction, produces a
finite, well-defined macroscopic object — and that object faithfully carries every
symmetry of its building blocks. The original conjecture asked whether *uniform*
contraction could be relaxed to *eventual* contraction in the five-vertex
row-exchange identity. The answer is yes: the finitely many badly behaved rows at
the boundary are invisible to the infinite tail, both for the existence of the
limit and for the survival of symmetry.

The deeper lesson is portable far beyond five-vertex models. Wherever a physical or
computational system is assembled by repeatedly applying contracting maps —
renormalization flows, Markov chains relaxing to equilibrium, iterated linear
filters, fixed-point solvers — the same two principles apply. **Eventual
contraction guarantees a limit. Commuting symmetries are preserved by that limit,
exactly, with no breaking and no leakage.** Symmetry, it turns out, has remarkable
staying power: establish it locally, ensure the dynamics eventually contract, and it
will follow you all the way to infinity.
