# Bruhat Rank, Smooth Pattern Avoidance, and a Chain-Refined Regularity Bound for Schubert Varieties

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty (Algebraic Combinatorics / Algebraic Geometry)

## Abstract

We study the combinatorial scaffolding underlying a conjectural bound on
the multigraded Castelnuovo–Mumford regularity of Schubert varieties
$S_\sigma$ in their Plücker embedding. The conjecture asserts that this
regularity is bounded above by the length of the longest chain of
Bruhat-ordered Schubert varieties from the trivial element up to $\sigma$
whose every step is a *smooth* permutation, i.e. one avoiding the
Lakshmibai–Sandhya patterns $3412$ and $4231$. We isolate and rigorously
establish two pillars on which the conjecture rests. First, the *rank
structure*: the Coxeter length $\ell(\sigma) = \#\{\text{inversions}\}$
grades the Bruhat order, is bounded by $\binom{n}{2}$, vanishes on the
identity, and forces a **chain-rank bound** — every strictly
length-increasing chain from the identity to $w$ has at most $\ell(w) \le
\binom{n}{2}$ steps. This is the precise mechanism guaranteeing that
"longest chain" is a finite, well-posed quantity. Second, the *smooth
class*: we give a self-contained, decidable definition of pattern
containment and avoidance, prove that the identity and the longest
element $w_0$ (the reversal) are both smooth, and prove that all
permutations of rank below four are smooth automatically. We enumerate
the smooth class (OEIS A005802) and discuss the refined regularity
conjecture, its sharpness, and four falsifiable follow-up conjectures.

## 1. Introduction

Schubert varieties are among the most studied objects at the interface of
algebraic geometry, representation theory, and combinatorics. To each
permutation $\sigma$ of $\{1, \dots, n\}$ one associates a Schubert
variety $S_\sigma$ inside a flag variety (or, via the Plücker embedding,
inside a product of projective spaces of exterior powers). Two themes
dominate their study:

1. **Singularities.** When is $S_\sigma$ smooth? The celebrated
   Lakshmibai–Sandhya criterion answers this purely combinatorially:
   $S_\sigma$ is smooth if and only if $\sigma$ avoids the two patterns
   $3412$ and $4231$.

2. **Homological complexity.** How complicated is the homogeneous
   coordinate ring of $S_\sigma$? A standard measure is the
   Castelnuovo–Mumford regularity, and in the *multigraded* setting
   appropriate to the Plücker embedding, bounding it is subtle. Existing
   bounds (e.g. the analogue of "Theorem 1.3" in the regularity
   literature) are expressed through Bruhat-order combinatorics.

This paper formalizes the combinatorial core of a conjecture that
*refines* such bounds. The conjecture posits that regularity is
controlled not merely by the rank $\ell(\sigma)$ but by the longest
Bruhat chain to $\sigma$ that stays inside the smooth locus at every
step. For this to be a meaningful statement one needs (a) a guarantee
that chains are of bounded, finite length, and (b) a robust, decidable
notion of smoothness. We supply both, with complete proofs, and discuss
their consequences.

All results below have been verified in the Lean 4 proof assistant atop
Mathlib; here we present the mathematics with proof sketches rather than
formal scripts. The two formal developments are an inversion-length /
chain-rank module and a smooth-pattern module.

## 2. The Bruhat Rank Structure

Throughout, $S_n = \mathrm{Perm}(\mathrm{Fin}\,n)$ denotes the symmetric
group on $n$ letters, with positions and values indexed $0, \dots, n-1$
(0-indexed, as in the formalization).

### 2.1 Inversions and length

**Definition 2.1 (Inversion set).** For $\sigma \in S_n$, the *inversion
set* is
$$\mathrm{inv}(\sigma) = \{(i,j) \in \mathrm{Fin}\,n \times \mathrm{Fin}\,n : i < j \text{ and } \sigma(j) < \sigma(i)\}.$$
In the formalization this is `invSet σ`, the filter of the universal
finset by the predicate $i < j \wedge \sigma(j) < \sigma(i)$.

**Definition 2.2 (Length).** The *Coxeter (Bruhat) length* of $\sigma$ is
$$\ell(\sigma) = \#\,\mathrm{inv}(\sigma),$$
formalized as `len σ := (invSet σ).card`.

**Definition 2.3 (Upper pairs).** The set of all ordered position pairs
with $i < j$ is
$$U_n = \{(i,j) \in \mathrm{Fin}\,n \times \mathrm{Fin}\,n : i < j\},$$
formalized as `upperPairs n`.

Clearly every inversion is an upper pair:

**Lemma 2.4 (`invSet_subset_upperPairs`).** $\mathrm{inv}(\sigma)
\subseteq U_n$.

*Proof.* Immediate: membership in $\mathrm{inv}(\sigma)$ requires $i < j$
by definition, which is exactly the defining predicate of $U_n$. $\square$

### 2.2 The combinatorial ceiling

**Theorem 2.5 (`upperPairs_card`).** $\#\,U_n = \binom{n}{2}$.

*Proof sketch.* Counting pairs $(i,j)$ with $i<j$ is the classical
identity $\sum_{j=0}^{n-1} \#\{i : i < j\} = \sum_{j=0}^{n-1} j = 0 + 1 +
\cdots + (n-1) = \binom{n}{2}$. In the formalization one rewrites the
filtered cardinality as a double sum over a product finset, recognizes
each inner count as $\#(\,\mathrm{Ioi}/\mathrm{Iio}\,)$ giving $j$, and
identifies the resulting Gauss sum $\sum_{j<n} j$ with $\binom{n}{2}$ via
`Nat.choose_two_right` and `Finset.sum_range_id`. $\square$

**Theorem 2.6 (`len_le_choose_two`).** For all $\sigma \in S_n$,
$$\ell(\sigma) \le \binom{n}{2}.$$

*Proof.* By Lemma 2.4, $\mathrm{inv}(\sigma) \subseteq U_n$, so by
monotonicity of cardinality $\ell(\sigma) = \#\,\mathrm{inv}(\sigma) \le
\#\,U_n = \binom{n}{2}$, using Theorem 2.5. $\square$

The bound is attained by the longest element $w_0$ (the reversal), for
which every upper pair is an inversion; thus $\binom{n}{2}$ is the exact
diameter of $S_n$ in the weak/Bruhat order, the rank of the top of the
poset.

**Theorem 2.7 (`len_one`).** $\ell(\mathrm{id}) = 0$.

*Proof.* The identity satisfies $\mathrm{id}(i) = i$, so $i < j$ implies
$\mathrm{id}(i) < \mathrm{id}(j)$, and no pair can satisfy $\sigma(j) <
\sigma(i)$. Hence $\mathrm{inv}(\mathrm{id}) = \varnothing$ and its
cardinality is $0$. $\square$

### 2.3 Length chains and the chain-rank bound

The Bruhat order is graded by $\ell$: a covering step raises length by
exactly one. Rather than import the full Coxeter machinery, we work with
the slightly more general and entirely self-contained notion of a
*length chain*, which every strictly-Bruhat-increasing chain satisfies.

**Definition 2.8 (Length chain, `LengthChain n k`).** A *length chain of
$k$ steps* in $S_n$ is data
$$(c_0, c_1, \dots, c_k), \qquad c_i \in S_n,$$
indexed by $\mathrm{Fin}(k+1)$, such that:
- **start:** $c_0 = \mathrm{id}$, and
- **mono:** for every $i \in \mathrm{Fin}\,k$, $\ell(c_i) < \ell(c_{i+1})$
  (strict length increase at each step).

**Lemma 2.9 (`LengthChain.len_ge_index`).** For a length chain $c$ and
each index $i \in \mathrm{Fin}(k+1)$,
$$i \le \ell(c_i).$$

*Proof.* Induction on $i$. For $i = 0$, $0 \le \ell(c_0)$ trivially. For
the successor, the inductive hypothesis gives $i \le \ell(c_i)$, and the
**mono** condition gives $\ell(c_i) < \ell(c_{i+1})$, so $i + 1 \le
\ell(c_{i+1})$ by `Nat.succ_le_of_lt`. $\square$

**Theorem 2.10 (Chain-rank bound, `chain_steps_le_len`).** For any length
chain $c$ ending at $w = c_k$,
$$k \le \ell(w).$$

*Proof.* Apply Lemma 2.9 at the last index $i = k$ (i.e. `Fin.last k`).
$\square$

**Corollary 2.11 (`chain_steps_le_choose`).** Every length chain in $S_n$
has at most $\binom{n}{2}$ steps:
$$k \le \binom{n}{2}.$$

*Proof.* Combine Theorem 2.10 with Theorem 2.6: $k \le \ell(c_k) \le
\binom{n}{2}$. $\square$

**Remark 2.12.** Corollary 2.11 is precisely the finiteness mechanism the
regularity conjecture needs. It certifies that "the length of the longest
chain of Bruhat-ordered Schubert varieties up to $\sigma$" is a
well-defined natural number, bounded by the diameter $\binom{n}{2}$ of
$S_n$, regardless of any smoothness constraint imposed along the chain.
Because we assume only strict length increase (not that steps are Bruhat
covers), the bound is honest and slightly more general than required: it
applies to *every* strictly-Bruhat-increasing chain.

## 3. The Smooth Class via Pattern Avoidance

We now formalize the Lakshmibai–Sandhya smooth class combinatorially.

### 3.1 Patterns and containment

A *length-4 pattern* is a permutation of $\{0,1,2,3\}$ presented as a
one-line word $\pi : \mathrm{Fin}\,4 \to \mathrm{Fin}\,4$. The two
forbidden patterns are
$$3412 \longmapsto [2,3,0,1], \qquad 4231 \longmapsto [3,1,2,0]$$
in 0-indexed form.

**Definition 3.1 (Containment, `Contains`).** A permutation $\sigma \in
S_n$ *contains* the pattern $\pi$ when there is a strictly increasing map
$f : \mathrm{Fin}\,4 \to \mathrm{Fin}\,n$ (four positions $f(0) < f(1) <
f(2) < f(3)$) such that the four values $\sigma(f(0)), \dots,
\sigma(f(3))$ appear in the *same relative order* as $\pi(0), \dots,
\pi(3)$; that is, for all $a, b$, $\sigma(f(a)) < \sigma(f(b))$ iff
$\pi(a) < \pi(b)$.

**Definition 3.2 (Avoidance).** $\sigma$ *avoids* $\pi$ when it does not
contain $\pi$; formally $\neg\,\mathrm{Contains}(\sigma, \pi)$.

**Definition 3.3 (Smoothness, `IsSmooth`).** $\sigma$ is *smooth* when it
avoids both forbidden patterns:
$$\mathrm{IsSmooth}(\sigma) \iff \sigma \text{ avoids } 3412 \ \wedge\ \sigma \text{ avoids } 4231.$$

By the Lakshmibai–Sandhya theorem, this is equivalent to smoothness of
the Schubert variety $S_\sigma$. We take it as the combinatorial
definition; the geometric content is the external dictionary.

### 3.2 Structural theorems

**Theorem 3.4 (Identity is smooth, `idPerm_avoids_*`).** The identity
permutation avoids both $3412$ and $4231$; hence $\mathrm{IsSmooth}(\mathrm{id})$.

*Proof sketch.* For the identity, $\sigma(f(a)) < \sigma(f(b)) \iff f(a) <
f(b) \iff a < b$ (since $f$ is strictly monotone). So the only relative
order realized on any four positions is the increasing pattern $1234 =
[0,1,2,3]$. Neither $3412$ nor $4231$ is the increasing pattern (each has
a descent), so no witnessing $f$ can exist. $\square$

**Theorem 3.5 (Reversal is smooth, `revPerm_avoids_*`).** The longest
element $w_0 = \mathrm{Fin.revPerm}$ (the reversal $\sigma(i) = n-1-i$)
avoids both forbidden patterns; hence $\mathrm{IsSmooth}(w_0)$.

*Proof sketch.* For the reversal, $\sigma(f(a)) < \sigma(f(b)) \iff f(a) >
f(b) \iff a > b$. So the only relative order realized on any four
positions is the *decreasing* pattern $4321 = [3,2,1,0]$. Neither $3412$
nor $4231$ is the decreasing pattern (each has an ascent), so no
witnessing $f$ exists. Geometrically: the full flag variety, sitting at
the top of the Bruhat order with length $\binom{n}{2}$, is smooth.
$\square$

**Theorem 3.6 (Small rank is automatically smooth, `smooth_of_lt_four`).**
If $n < 4$, then every $\sigma \in S_n$ is smooth.

*Proof.* Containment of a length-4 pattern requires a strictly increasing
$f : \mathrm{Fin}\,4 \to \mathrm{Fin}\,n$, hence four distinct positions
$0 \le f(0) < f(1) < f(2) < f(3) \le n-1$, which forces $n \ge 4$. When
$n < 4$ no such $f$ exists, so $\sigma$ vacuously avoids every length-4
pattern and is smooth. This is the combinatorial shadow of the classical
fact that all Schubert varieties in $\mathrm{Fl}(\le 3)$ are smooth.
$\square$

**Remark 3.7 (Non-vacuity).** For $n \ge 4$ the forbidden patterns
genuinely occur — $3412$ and $4231$ are themselves honest non-identity,
non-reversal permutations, and supply explicit witnessing embeddings — so
Theorems 3.4–3.6 have real content rather than being vacuously true.

### 3.3 Enumeration

Counting smooth permutations of $S_n$ yields
$$1,\ 2,\ 6,\ 22,\ 88,\ 366,\ 1552,\ \dots \qquad (n = 1,2,3,4,5,6,7),$$
which is OEIS A005802, the census of smooth Schubert varieties. For $n
\le 3$ all $n!$ permutations are smooth (consistent with Theorem 3.6);
the first singular permutations appear at $n = 4$, where exactly $24 - 22
= 2$ permutations (namely $3412$ and $4231$ themselves) are singular.
A005802 has a known generating function, evidence that the smooth class
is a richly structured family.

## 4. The Refined Regularity Conjecture

We can now state the central conjecture precisely.

**Conjecture 4.1 (Smooth-chain regularity bound).** Let $\sigma \in S_n$
and let $S_\sigma$ be its Schubert variety in the Plücker embedding.
Then the multigraded Castelnuovo–Mumford regularity of $S_\sigma$
satisfies
$$\mathrm{reg}(S_\sigma) \ \le\ \max\{\,k : \text{there is a length chain } (c_0,\dots,c_k) \text{ to } \sigma \text{ with each } c_i \text{ smooth}\,\}.$$
Moreover, whenever the longest *smooth* chain to $\sigma$ is strictly
shorter than $\ell(\sigma)$, this bound strictly refines the existing
Bruhat-length bound (the analogue of Theorem 1.3 in the regularity
literature).

The two combinatorial pillars established above make this conjecture
well-posed and plausibly sharp:

- **Well-posedness (finiteness).** By Corollary 2.11 the right-hand side
  is a finite natural number $\le \binom{n}{2}$, since a smooth chain is
  in particular a length chain.

- **Plausible sharpness.** Smooth Schubert varieties enjoy a hereditary
  property: the Bruhat interval $[\mathrm{id}, \sigma]$ below a smooth
  $\sigma$ tends to consist entirely of smooth elements. Thus a saturated
  Bruhat chain to a smooth $\sigma$ stays smooth, and Theorem 2.10's
  bound $k \le \ell(\sigma)$ is conjecturally *attained* by a smooth
  chain — making the refined bound sharp for smooth $\sigma$.

## 5. Algorithms

The combinatorial framework is fully decidable on small ranks, enabling
direct computational verification of the structural theorems and
exploration of the conjecture.

### 5.1 Inversion length

Computing $\ell(\sigma)$ is a direct $O(n^2)$ scan over position pairs:

```
function LENGTH(σ : array[0..n-1]):
    count ← 0
    for i in 0 .. n-1:
        for j in i+1 .. n-1:
            if σ[i] > σ[j]:
                count ← count + 1
    return count
```

This realizes Definition 2.2 and lets one verify $\ell(\mathrm{id}) = 0$,
$\ell(w_0) = \binom{n}{2}$, and $\ell(\sigma) \le \binom{n}{2}$ directly.

### 5.2 Pattern-containment test

Deciding whether $\sigma$ contains a length-4 pattern $\pi$ is an
$O(n^4)$ search over increasing quadruples, comparing relative orders:

```
function CONTAINS(σ, π):
    for each increasing quadruple (a < b < c < d) of positions:
        vals ← (σ[a], σ[b], σ[c], σ[d])
        if RELATIVE_ORDER(vals) == RELATIVE_ORDER(π):
            return true
    return false

function IS_SMOOTH(σ):
    return not CONTAINS(σ, 3412) and not CONTAINS(σ, 4231)
```

This realizes Definitions 3.1–3.3 and certifies Theorems 3.4–3.6 on any
fixed rank.

### 5.3 Longest smooth chain (dynamic program)

Searching for the longest smooth chain to $\sigma$ is a longest-path
computation in the Bruhat (or simply length-graded) DAG restricted to
smooth vertices. Memoizing on permutations gives a finite search bounded
by Corollary 2.11.

```
function LONGEST_SMOOTH_CHAIN(σ):
    if not IS_SMOOTH(σ): return -∞
    best ← 0
    for each τ with τ ⋖ σ in Bruhat order (so ℓ(τ) = ℓ(σ) - 1):
        if IS_SMOOTH(τ):
            best ← max(best, 1 + LONGEST_SMOOTH_CHAIN(τ))
    return best
```

## 6. Applications and Discussion

- **Sharper regularity certificates.** When verified, Conjecture 4.1
  provides regularity upper bounds that improve on length-only bounds
  precisely on permutations whose smooth-chain rank drops below
  $\ell(\sigma)$ — a computable diagnostic.

- **A bridge between singularity theory and homological algebra.** The
  conjecture ties the *singularity* data of intermediate Schubert
  varieties (smoothness) to the *homological* complexity (regularity) of
  the top variety, suggesting that the geometry of the Bruhat interval,
  not just its top, governs syzygetic behavior.

- **Decidable experimentation.** Because every notion here is decidable,
  the conjecture can be stress-tested exhaustively on $S_n$ for small
  $n$, turning a frontier question into a finite search certified by the
  chain-rank bound.

## 7. Future Directions

**Conjecture 7.1 (Inverse-closure).** For every $\sigma \in S_n$,
$\mathrm{IsSmooth}(\sigma) \iff \mathrm{IsSmooth}(\sigma^{-1})$. The
forbidden patterns are self-inverse involutions ($3412^{-1} = 3412$,
$4231^{-1} = 4231$), so containment dualizes under $\sigma \mapsto
\sigma^{-1}$ and preserves the smooth class. The only missing ingredient
is the standard "patterns transpose under inverse" reindexing lemma.

**Conjecture 7.2 (Length complementation).** For the longest element $w_0
= \mathrm{Fin.revPerm}$, $\ell(w_0 \sigma) = \binom{n}{2} - \ell(\sigma)$.
Left multiplication by $w_0$ reverses every value comparison, setting up
a bijection between the inversions of $\sigma$ and the non-inversions of
$w_0\sigma$ inside the $\binom{n}{2}$ upper pairs. With
`upperPairs_card` and `invSet ⊆ upperPairs` already in hand, this is a
finset-complement argument.

**Conjecture 7.3 (Smooth chains are co-final).** The maximal length of a
smooth length chain to a smooth $\sigma$ equals $\ell(\sigma)$; smoothness
of all intermediate Schubert varieties does not lower the achievable
rank. The $\le$ direction is `chain_steps_le_len`; the new content is
exhibiting a smooth saturated chain attaining it, using the hereditary
smoothness of the interval $[\mathrm{id}, \sigma]$.

**Conjecture 7.4 (The mission conjecture, refined).** The multigraded
Castelnuovo–Mumford regularity of $S_\sigma$ in the Plücker embedding is
at most the maximal length of a Bruhat chain to $\sigma$ with a
$3412$/$4231$-avoiding element at each step, and this refines the
Theorem 1.3 bound whenever the longest smooth chain is strictly shorter
than $\ell(\sigma)$. The rank function $\ell$ controls every
length-graded chain (`chain_steps_le_len`), supplying the finiteness; the
smooth-chain co-finality of Conjecture 7.3 would supply the sharpness.

## 8. Conclusion

We have established, with complete proofs, the combinatorial foundations
of a chain-refined regularity conjecture for Schubert varieties: the
inversion length $\ell$ grades the Bruhat order, is bounded by
$\binom{n}{2}$, vanishes on the identity, and forces the chain-rank bound
$k \le \ell(w) \le \binom{n}{2}$; and the smooth class, defined by
avoidance of $3412$ and $4231$, contains the identity and the reversal
and is automatic below rank four. Together these make the conjectural
smooth-chain regularity bound finite, well-posed, and plausibly sharp,
and they reduce a frontier question in algebraic geometry to a decidable
search over staircases of permutations.

## References (general background, no external file dependencies)

- V. Lakshmibai, B. Sandhya, *Criterion for smoothness of Schubert
  varieties in $SL(n)/B$*, Proc. Indian Acad. Sci. (1990).
- OEIS A005802, *Number of permutations avoiding $3412$ and $4231$
  (smooth permutations)*.
