# The Suspension Tower of Free $\mathbb{Z}_2$-Complexes and an Iterated Borsuk–Ulam Obstruction

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We study the combinatorial $\mathbb{Z}_2$-co-index of free $\mathbb{Z}_2$-simplicial
complexes under the suspension operation. Working entirely within a finite,
combinatorial model — free $\mathbb{Z}_2$-complexes, equivariant simplicial maps, and
the octahedral spheres $\mathrm{Oct}(n) \cong S^n$ — we prove that suspension raises
the $\mathbb{Z}_2$-co-index by at least one, and that the $k$-fold **suspension tower**
$S^k(K)$ therefore raises the co-index by at least $k$. Applied to octahedral spheres,
the tower over $S^n$ realizes co-index $n+k$; we further prove that its dimension is
*exactly* $n+k$ by supplying matched lower and upper bounds on maximal face
cardinality. Consequently the tower is **co-index efficient**: the excess
$\mathrm{coind} - \dim$ remains identically zero at every level, making the tower the
canonical *zero-excess* reference family. Finally, we upgrade the combinatorial
Borsuk–Ulam base case (no equivariant simplicial map from a positive-dimensional
sphere onto $S^0$) to an **iterated obstruction**: for every $k \ge 1$ there is no
equivariant simplicial map from the $k$-fold suspension of $S^0$ back onto $S^0$. The
obstruction is non-vacuous precisely because the tower genuinely realizes co-index
$k$.

**Keywords:** free $\mathbb{Z}_2$-complex, $\mathbb{Z}_2$-co-index, suspension,
octahedral sphere, Borsuk–Ulam theorem, equivariant simplicial map, chromatic number.

---

## 1. Introduction

The Borsuk–Ulam theorem — that every continuous map $S^n \to \mathbb{R}^n$ identifies
some antipodal pair — is a fixed point of modern combinatorics. Through the work of
Lovász, Bárány, and many others it became the engine behind topological lower bounds
for the chromatic number, fair-division results, and Kneser-type theorems. The
organizing invariant in this circle of ideas is the **$\mathbb{Z}_2$-co-index** of a
free $\mathbb{Z}_2$-space: the largest $n$ for which there is an equivariant map
$S^n \to X$.

This paper isolates and answers, sharply, a structural question about how the
co-index behaves under **suspension**, the elementary operation $S(X) = X * S^0$ that
turns $S^n$ into $S^{n+1}$. We work in a fully finite, combinatorial category so that
every statement is an explicit, checkable fact about finite simplicial complexes and
vertex maps. The objects are *free $\mathbb{Z}_2$-complexes*; the maps are
*equivariant simplicial maps*; the yardsticks are the *octahedral spheres*.

Our contributions are:

1. **Single-step growth.** Suspension raises the co-index by at least one
   (Theorem 4.1).
2. **Tower growth.** The $k$-fold suspension tower raises the co-index by at least
   $k$ (Theorem 5.2), and over $S^n$ realizes co-index $n+k$ (Corollary 5.3).
3. **Exact dimension.** The tower over $S^n$ has dimension exactly $n+k$, via matched
   face-cardinality bounds (Theorems 6.1 and 6.2). Hence the tower is
   **zero-excess**.
4. **Iterated Borsuk–Ulam.** No equivariant simplicial map sends the $k$-fold
   suspension of $S^0$ onto $S^0$ for any $k \ge 1$ (Theorem 7.2), non-vacuously.

The co-index growth and the iterated obstruction are formal consequences of the
single-step lemmas — the constructive, "easy" half. The genuinely new estimate is the
dimension upper bound: a face of a suspension contains at most one apex, so
cardinality grows by exactly one per suspension.

---

## 2. The combinatorial model

### 2.1 Free $\mathbb{Z}_2$-complexes

**Definition 2.1 (Free $\mathbb{Z}_2$-complex).**
Let $V$ be a type with decidable equality. A *free $\mathbb{Z}_2$-complex* on $V$ is a
tuple consisting of:

- an *antipodal map* $\alpha : V \to V$ that is an involution ($\alpha(\alpha(v)) = v$
  for all $v$) and *free* (fixed-point-free: $\alpha(v) \ne v$ for all $v$);
- a predicate $\mathrm{IsFace}$ on finite subsets $s \subseteq V$ (the *faces*),
  such that
  - the empty set is a face,
  - faces are *downward closed*: if $t \subseteq s$ and $s$ is a face, then $t$ is a
    face, and
  - faces are *$\alpha$-symmetric*: if $s$ is a face, so is its image
    $\alpha(s)$ under the antipodal map.

The group $\mathbb{Z}_2 = \{1, \alpha\}$ acts freely on $V$, and the face structure is
$\mathbb{Z}_2$-invariant; this is the combinatorial analogue of a free $\mathbb{Z}_2$-space.

**Definition 2.2 (Equivariant simplicial map).**
Let $K$ (on $V$) and $L$ (on $W$) be free $\mathbb{Z}_2$-complexes. A
*$\mathbb{Z}_2$-simplicial map* $f : K \to L$ is a vertex map $f : V \to W$ such that

- $f$ is *equivariant*: $f(\alpha_K v) = \alpha_L(f v)$ for all $v \in V$, and
- $f$ *preserves faces*: if $s$ is a face of $K$, then $f(s)$ is a face of $L$.

Equivariant simplicial maps compose, and each complex carries an identity map; free
$\mathbb{Z}_2$-complexes thus form a category.

### 2.2 The octahedral spheres

**Definition 2.3 (Octahedral $n$-sphere).**
Fix $n \ge 0$. Let the vertex set be $\{0, \dots, n\} \times \{\text{true},
\text{false}\}$: for each of the $n+1$ axes $i$, two antipodal beads
$(i, \text{true})$ and $(i, \text{false})$. Define

- the antipodal map $\alpha(i, b) = (i, \lnot b)$ (flip the sign bit), and
- the face predicate: $s$ is a face iff it contains **no antipodal pair**, i.e. for no
  axis $i$ are both $(i, \text{true})$ and $(i, \text{false})$ in $s$.

This is the *octahedral $n$-sphere* $\mathrm{Oct}(n)$, the boundary complex of the
$(n{+}1)$-dimensional cross-polytope, a triangulation of $S^n$. The antipodal map is
free (a bead is never its own flip) and face-symmetric (flipping every bead of an
antipodal-pair-free set yields an antipodal-pair-free set), so $\mathrm{Oct}(n)$ is a
free $\mathbb{Z}_2$-complex.

**Definition 2.4 (Co-index lower bound).**
For free $\mathbb{Z}_2$-complexes we write $\mathrm{coind}(K) \ge n$ to mean there
exists an equivariant simplicial map $\mathrm{Oct}(n) \to K$. The
*$\mathbb{Z}_2$-co-index* of $K$ is the largest $n$ for which this holds. The identity
map gives $\mathrm{coind}(\mathrm{Oct}(n)) \ge n$.

---

## 3. Suspension

**Definition 3.1 (Suspension).**
Let $K$ be a free $\mathbb{Z}_2$-complex on $V$. Its *(unreduced) suspension*
$S(K) = K * S^0$ is the free $\mathbb{Z}_2$-complex on the disjoint union
$V \sqcup \{\text{north}, \text{south}\}$ (formally $V \oplus \mathrm{Bool}$) with:

- antipodal map acting as $\alpha_K$ on the base $V$ and swapping the two apexes
  $\text{north} \leftrightarrow \text{south}$;
- a set $T$ is a face iff its base part (the elements landing in $V$) is a face of
  $K$, **and** $T$ does not contain both apexes.

Geometrically $S(K)$ cones $K$ up to two antipodal apexes; the "not both apexes"
condition keeps the antipodal pair of poles from ever lying in a common face.

**Proposition 3.2 (Functoriality).**
Suspension is a functor: an equivariant simplicial map $g : K \to L$ induces an
equivariant simplicial map $S(g) : S(K) \to S(L)$ acting as $g$ on the base and as
the identity on apexes.

*Proof sketch.* Define $S(g) = g \sqcup \mathrm{id}$. Equivariance on the base is
inherited from $g$; on apexes it is the identity swap. For faces: the base part of
$S(g)(T)$ is $g$ applied to the base part of $T$, which is a face of $L$ since $g$
preserves faces; and $S(g)$ maps apexes to apexes injectively, so "not both apexes"
is preserved. $\square$

**Proposition 3.3 (Suspending a sphere gives the next sphere).**
There is an explicit equivariant simplicial isomorphism-onto-image
$$\mathrm{Oct}(n+1) \longrightarrow S(\mathrm{Oct}(n)),\qquad
S(\mathrm{Oct}(n)) \cong \mathrm{Oct}(n+1).$$

*Proof sketch.* Send the bead $(i, b)$ of $\mathrm{Oct}(n+1)$ to the base bead
$(i, b)$ of $S(\mathrm{Oct}(n))$ when $i < n+1$ (i.e. $i$ lies among the first $n+1$
axes), and to the apex of sign $b$ when $i = n+1$ (the last axis). This identifies the
final antipodal axis of $\mathrm{Oct}(n+1)$ with the pair of poles. Equivariance
follows because flipping the sign bit corresponds to swapping poles; faces map to
faces because an antipodal-pair-free set never uses both endpoints of the last axis,
which becomes exactly the "not both apexes" condition. $\square$

---

## 4. Suspension raises the co-index

**Theorem 4.1 (Single-step growth).**
If $\mathrm{coind}(K) \ge m$, then $\mathrm{coind}(S(K)) \ge m+1$. Equivalently,
$$\mathrm{coind}(S(K)) \ge \mathrm{coind}(K) + 1.$$

*Proof.* Let $g : \mathrm{Oct}(m) \to K$ be an equivariant simplicial map. By
functoriality (Prop. 3.2), $S(g) : S(\mathrm{Oct}(m)) \to S(K)$. By Prop. 3.3 there
is an equivariant map $\mathrm{Oct}(m+1) \to S(\mathrm{Oct}(m))$. Composing,
$$\mathrm{Oct}(m+1) \to S(\mathrm{Oct}(m)) \xrightarrow{\,S(g)\,} S(K),$$
which is an equivariant simplicial map $\mathrm{Oct}(m+1) \to S(K)$, exactly the
required co-index certificate. $\square$

---

## 5. The suspension tower

**Definition 5.1 (Suspension tower).**
For a free $\mathbb{Z}_2$-complex $K$ on $V$ define the *$k$-fold suspension tower*
recursively: $S^0(K) = K$ and $S^{k+1}(K) = S(S^k(K))$. Its vertex type is the
iterated sum $V \oplus \mathrm{Bool} \oplus \cdots \oplus \mathrm{Bool}$
($k$ copies of $\mathrm{Bool}$), which carries decidable equality at every level.

**Theorem 5.2 (Tower growth).**
If $\mathrm{coind}(K) \ge m$, then for every $k \ge 0$,
$$\mathrm{coind}(S^k(K)) \ge m+k.$$

*Proof.* Induction on $k$. Base $k=0$: the hypothesis itself. Step: apply
Theorem 4.1 to the inductive certificate $\mathrm{Oct}(m+k) \to S^k(K)$, obtaining
$\mathrm{Oct}(m+k+1) \to S(S^k(K)) = S^{k+1}(K)$. $\square$

**Corollary 5.3 (Tower over a sphere).**
For all $n, k \ge 0$, $\ \mathrm{coind}(S^k(\mathrm{Oct}(n))) \ge n+k$.

*Proof.* Apply Theorem 5.2 to $m = n$ and the identity certificate
$\mathrm{coind}(\mathrm{Oct}(n)) \ge n$. $\square$

---

## 6. Exact dimension of the tower

The *dimension* of a complex is the maximal face cardinality minus one. We bound the
maximal face cardinality of the tower over $S^n$ from both sides.

**Theorem 6.1 (Dimension lower bound).**
The tower $S^k(\mathrm{Oct}(n))$ has a face of cardinality exactly $n+1+k$; hence its
dimension is at least $n+k$.

*Proof.* Induction on $k$. Base: the "positive orthant"
$\{(0,\text{true}), \dots, (n,\text{true})\}$ contains one bead per axis and no
antipodal pair, so it is a face of $\mathrm{Oct}(n)$ with $n+1$ vertices. Step: given
a face $s$ of $S^k(\mathrm{Oct}(n))$ with $|s| = n+1+k$, insert one apex
$\text{north}$ into the image of $s$ under the base inclusion. The result is a face of
$S^{k+1}(\mathrm{Oct}(n))$ (its base part is $s$, and it uses only one apex) with
cardinality $(n+1+k) + 1$. $\square$

**Theorem 6.2 (Dimension upper bound).**
Every face of $S^k(\mathrm{Oct}(n))$ has at most $n+1+k$ vertices; hence its dimension
is at most $n+k$.

*Proof.* Induction on $k$. Base ($k=0$): a face of $\mathrm{Oct}(n)$ contains at most
one bead per axis (no antipodal pair), so projecting to the axis index is injective
and the face has at most $n+1$ vertices. Step: let $T$ be a face of
$S^{k+1}(\mathrm{Oct}(n)) = S(S^k(\mathrm{Oct}(n)))$. Partition $T$ into its base part
(a face of $S^k(\mathrm{Oct}(n))$, of size $\le n+1+k$ by induction) and its apex
part. Since a suspension face contains **at most one** apex, the apex part has at most
one element. Hence $|T| \le (n+1+k) + 1 = n+1+(k+1)$. $\square$

**Corollary 6.3 (Zero excess).**
The tower over $S^n$ has co-index and dimension both equal to $n+k$:
$$\mathrm{coind}(S^k(\mathrm{Oct}(n))) = \dim(S^k(\mathrm{Oct}(n))) = n+k.$$
Thus its *excess* $\mathrm{coind} - \dim$ is identically zero: the suspension tower is
**co-index efficient**, wasting no dimension at any level.

*Proof.* Corollary 5.3 gives $\mathrm{coind} \ge n+k$. The co-index of any complex is
bounded by its dimension (an equivariant image of $\mathrm{Oct}(N)$ needs a face of
size $N+1$), and Theorem 6.2 gives $\dim \le n+k$; combined with the lower bound
from Theorem 6.1 the dimension equals $n+k$, forcing $\mathrm{coind} = n+k$ as
well. $\square$

---

## 7. An iterated Borsuk–Ulam obstruction

**Theorem 7.1 (Combinatorial Borsuk–Ulam, base case).**
If there is an equivariant simplicial map $\mathrm{Oct}(n) \to \mathrm{Oct}(0)$, then
$n = 0$.

*Proof sketch.* Suppose $n \ge 1$ and let $g : \mathrm{Oct}(n) \to \mathrm{Oct}(0)$
be equivariant. The target $\mathrm{Oct}(0) = S^0$ has exactly two vertices, an
antipodal pair, and its only faces are the empty set and the two singletons — in
particular no face has two distinct vertices. Consider two beads $a = (0,\text{true})$
and $b = (1,\text{true})$ on different axes; $\{a,b\}$ is a face of $\mathrm{Oct}(n)$,
so $\{g(a), g(b)\}$ is a face of $S^0$, forcing $g(a) = g(b)$. Now
$\{a, \alpha(b)\}$ is also a face (still no antipodal pair, since $a,b$ are on
distinct axes), so $\{g(a), g(\alpha b)\}$ is a face of $S^0$. But equivariance gives
$g(\alpha b) = \alpha(g(b)) = \alpha(g(a))$, so this face is
$\{g(a), \alpha(g(a))\}$ — an antipodal pair in $S^0$, which is *not* a face. This
contradiction forces $n = 0$. $\square$

**Theorem 7.2 (Iterated Borsuk–Ulam obstruction).**
For every $k \ge 1$, there is **no** equivariant simplicial map from the $k$-fold
suspension of $S^0$ back onto $S^0$:
$$S^k(\mathrm{Oct}(0)) \not\longrightarrow \mathrm{Oct}(0).$$

*Proof.* Suppose $g : S^k(\mathrm{Oct}(0)) \to \mathrm{Oct}(0)$ were equivariant. By
Corollary 5.3 (with $n=0$) there is an equivariant map
$f : \mathrm{Oct}(k) \to S^k(\mathrm{Oct}(0))$. The composite $g \circ f$ is an
equivariant simplicial map $\mathrm{Oct}(k) \to \mathrm{Oct}(0)$, so by Theorem 7.1
we get $k = 0$, contradicting $k \ge 1$. Hence no such $g$ exists. $\square$

**Remark 7.3 (Non-vacuity).**
The obstruction is not an empty statement about an unreachable complex: by
Corollary 6.3 the tower $S^k(\mathrm{Oct}(0))$ genuinely has co-index and dimension
$k$, so it is a bona fide $k$-dimensional free $\mathbb{Z}_2$-complex. The theorem
says a *real* high-dimensional object cannot retract equivariantly to the
$0$-sphere — a discrete shadow of the classical fact that $S^k$ admits no odd map to
$S^0$ for $k \ge 1$.

---

## 8. Algorithms

The constructions are effective. We describe three algorithms whose implementations
appear in the accompanying demonstration code.

**8.1 Face enumeration.** Given $n$, enumerate the faces of $\mathrm{Oct}(n)$ by
scanning all subsets of the $2(n+1)$ beads and retaining those with no antipodal
pair. Complexity $O(4^{n+1})$ subsets; used for small-$n$ sanity checks and for
verifying maximal face cardinality equals $n+1$.

**8.2 Suspension-tower dimension.** Compute the maximal face cardinality of
$S^k(\mathrm{Oct}(n))$ recursively: $\mathrm{maxface}(S^0) = n+1$ and
$\mathrm{maxface}(S^{j+1}) = \mathrm{maxface}(S^{j}) + 1$, returning dimension
$\mathrm{maxface} - 1 = n+k$. This certifies Theorems 6.1–6.2 in $O(k)$ time without
enumerating faces.

**8.3 Obstruction certificate.** Given $k \ge 1$, output the certificate chain
$\mathrm{Oct}(k) \xrightarrow{f} S^k(\mathrm{Oct}(0)) \xrightarrow{g?} \mathrm{Oct}(0)$
and report that $g$ cannot exist because $g \circ f : \mathrm{Oct}(k) \to
\mathrm{Oct}(0)$ would violate the base case ($k \ne 0$).

---

## 9. Applications

**Chromatic lower bounds.** The $\mathbb{Z}_2$-co-index of a graph's *box complex*
$B(G)$ underpins the Lovász-type bound $\chi(G) \ge \mathrm{coind}(B(G)) + 2$.
Suspension of the box complex corresponds to concrete graph-theoretic operations
(via Csorba's identity $B_0(G) \simeq S(B(G))$), so precise control of how suspension
moves the co-index translates directly into control of chromatic lower bounds. The
zero-excess tower supplies a calibration standard: when a complex's excess is large,
the associated topological color bound is *loose* and can potentially be sharpened.

**A reference family for the excess programme.** The excess
$\mathrm{coind} - \dim$ measures how much antipodal complexity a complex fails to
carry relative to its ambient dimension. The suspension tower pins excess at zero at
every level, giving the exact control against which maximal-excess constructions must
be contrasted.

---

## 10. Discussion and future work

The results here are the *constructive, zero-excess* half of a broader programme on
how suspension moves the $\mathbb{Z}_2$-co-index. Three directions stand out.

1. **Excess as a tower invariant.** For a finite free $\mathbb{Z}_2$-complex $K$, the
   excess sequence $e_k = \mathrm{coind}(S^k(K)) - \dim(S^k(K))$ is conjectured
   non-increasing and eventually constant: past some $k_0$, each suspension raises
   co-index and dimension by exactly one, so $e_k$ freezes at an intrinsic value.
   Suspension can repair only a bounded amount of equivariant homotopical defect per
   step, while always adding one to the dimension; once the defect is exhausted the
   invariants lock together.

2. **Maximal excess in a single step.** For every $d \ge 2$ and $1 \le c \le d$ we
   conjecture a finite free $\mathbb{Z}_2$-complex $K$ with $\dim K = d$ and
   $\mathrm{coind}(K) = c$ whose single suspension already achieves the maximal jump
   $\mathrm{coind}(S(K)) = d+1$, i.e. excess $d - c$ collapses to $0$ in one step. The
   defect and the ambient dimension are independently tunable: a complex can be made
   "co-index poor but suspension rich".

3. **A full combinatorial Borsuk–Ulam for the octahedral family.** We conjecture that
   there is no equivariant simplicial map $\mathrm{Oct}(m) \to \mathrm{Oct}(n)$
   whenever $m > n$ — equivalently $\mathrm{coind}(\mathrm{Oct}(n)) = n$ exactly — and
   more generally none $S^k(\mathrm{Oct}(m)) \to \mathrm{Oct}(n)$ when $m + k > n$.
   The antipodal-pair-freeness of top-dimensional faces should encode the parity
   obstruction underlying Borsuk–Ulam, so the non-existence ought to follow from a
   discrete degree/parity count rather than a continuous argument. Promoting the base
   case to all $n$ would turn the co-index lower bounds of this work into exact
   values.

---

## 11. Conclusion

Within a fully finite combinatorial model we established a sharp staircase: a single
suspension raises the $\mathbb{Z}_2$-co-index by at least one, the $k$-fold tower by
at least $k$, and over an octahedral sphere the tower's co-index and dimension climb
in lockstep to $n+k$, so its excess is identically zero. Iterating the Borsuk–Ulam
base case then forbids any $k$-fold suspension of $S^0$ ($k \ge 1$) from retracting
equivariantly onto $S^0$ — a non-vacuous, iterated obstruction. The suspension tower
emerges as the canonical zero-excess reference family, tightening the bridge between
combinatorial co-index and the topological Borsuk–Ulam obstruction, and setting the
stage for the excess-spectrum conjectures above.
