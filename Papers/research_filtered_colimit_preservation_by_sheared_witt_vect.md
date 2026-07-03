# Filtered-Colimit Preservation and the Finite-Support Dichotomy for Power Functors

## Abstract

We isolate and prove the combinatorial core of the statement that the *sheared*
Witt vector functor preserves filtered colimits over nilperfect rings, while the
naive (big) Witt vector functor does not. Modelling a filtered colimit by its
most concrete incarnation — a directed union $\bigcup_i S_i$ of a monotone family
of subsets indexed by a nonempty directed order — we establish a sharp
trichotomy for *power-shaped* set constructions $A \mapsto A^\kappa$. First,
**finite powers commute with directed unions**: for finite $\kappa$, a tuple all
of whose coordinates lie in the union already lies, as a whole, in a single
stage. Second, **countable powers fail to commute**: for the canonical
exhaustion $S_i = \{0, \dots, i\}$ of $\mathbb{N}$, the identity sequence lies in
the union of coordinate-membership but in no single stage. Third, the
**sheared repair works**: restricting the countable power to sequences of finite
essential support (eventually equal to a basepoint contained in every stage)
restores commutation. The single engine throughout is that directedness merges
any *finite* set of stages into one; the entire obstruction is concentrated in
the cardinality of the active index set. We phrase the ring-theoretic corollary
in terms of directed families of subrings, explain the connection to truncated,
naive, and sheared Witt vectors, and give algorithmic and numerical
illustrations.

**Keywords:** filtered colimit, directed union, power functor, finite support,
Witt vectors, sheared Witt vectors, Dieudonné theory, nilperfect rings.

## 1. Introduction

A functor $F$ between categories of algebraic objects is said to *preserve
filtered colimits* if the canonical comparison map
$$\operatorname*{colim}_{i} F(R_i) \longrightarrow F\!\left(\operatorname*{colim}_i R_i\right)$$
is an isomorphism for every filtered diagram $(R_i)_{i \in I}$. This property is
the abstract expression of *finitary computability*: filtered colimits are the
categorical mechanism by which arbitrary objects are assembled from finitely
generated (hence tractable) ones, and a functor that preserves them can be
evaluated on complicated inputs by evaluating on simple pieces and gluing.

For Witt vectors, this question is not academic. The Witt vector construction —
attaching to a ring $R$ a ring structure on infinite sequences over $R$ with
the classical polynomial addition and multiplication laws — underlies $p$-adic
Hodge theory and *Dieudonné theory*, the equivalence classifying certain
formal/algebraic groups. Dieudonné theory is classical over perfect rings but
obstructed over more general rings, in particular over the *nilperfect* rings
one wishes to admit. A central obstruction is that the naive (big) Witt vector
functor does **not** preserve filtered colimits, so it cannot be evaluated
finitarily. The *sheared* Witt vector construction is designed precisely to
repair this: it retains only the coordinates of *finite essential support*, and
thereby regains filtered-colimit preservation.

The purpose of this paper is to isolate this repair at its combinatorial root,
in a self-contained and elementary form, stripped of the polynomial arithmetic
of Witt vectors. We show that the phenomenon is governed entirely by the shape of
the underlying set functor $A \mapsto A^\kappa$ and by the cardinality of the
"active" index set, and we prove three complementary theorems that bracket the
behaviour on both sides.

## 2. Setup and definitions

Throughout, $I$ denotes a preordered index type that is **nonempty** and
**directed**: for all $i, j \in I$ there exists $k \in I$ with $i \le k$ and
$j \le k$.

**Definition 2.1 (monotone family of stages).** Let $A$ be a set. A *monotone
family of stages* is a map $S : I \to \mathcal{P}(A)$ such that $i \le j$ implies
$S_i \subseteq S_j$. Its *directed union* (the colimit) is
$$\bigcup_{i \in I} S_i \subseteq A.$$

Directedness makes $\bigcup_i S_i$ a genuine filtered colimit of the diagram
$(S_i)$: any two elements are witnessed at two stages, which merge into one.

**Definition 2.2 (power functor / arity).** For an index set $\kappa$, the
*$\kappa$-power* of $A$ is the set of functions $A^\kappa = \{ f : \kappa \to A\}$.
We call $\kappa$ the *arity*. When $\kappa$ is finite the power is a *finite-arity*
construction (e.g. $R \mapsto R^n$, the underlying set of the truncated Witt
vectors $W_n$); when $\kappa = \mathbb{N}$ it is a *countable-arity* construction
(e.g. $R \mapsto R^{\mathbb{N}}$, the underlying set of the naive/big Witt
vectors).

**Definition 2.3 (coordinate-membership vs. staged membership).** For a monotone
family $S$ and arity $\kappa$, define
$$U \;=\; \{\, f : \kappa \to A \ \mid\ \forall k \in \kappa,\ f(k) \in \textstyle\bigcup_i S_i \,\},
\qquad
V \;=\; \bigcup_{i} \{\, f : \kappa \to A \ \mid\ \forall k \in \kappa,\ f(k) \in S_i \,\}.$$
The set $U$ collects tuples that are *coordinate-wise in the colimit*; the set
$V$ collects tuples that lie *entirely within some single stage*. Always
$V \subseteq U$. **Preservation** is the reverse inclusion $U \subseteq V$,
equivalently $U = V$: it says the $\kappa$-power functor commutes with the
directed union.

**Definition 2.4 (finite essential support).** Fix a *basepoint* $b \in A$. A
sequence $f : \mathbb{N} \to A$ has *finite essential support relative to $b$* if
there exists $N$ with $f(k) = b$ for all $k \ge N$. Write $A^{(\mathbb{N})}_b$ for
the set of such sequences. This is the *sheared* variant of the countable power.

## 3. Main results

### 3.1 Preservation for finite arity

**Theorem 3.1 (finite powers commute with directed unions).** Let $A$ be a set,
$I$ nonempty and directed, $S : I \to \mathcal{P}(A)$ monotone, and $\kappa$ a
*finite* index set. Then, in the notation of Definition 2.3,
$$\{\, f : \kappa \to A \ \mid\ \forall k,\ f(k) \in \textstyle\bigcup_i S_i \,\}
\;=\; \bigcup_{i} \{\, f : \kappa \to A \ \mid\ \forall k,\ f(k) \in S_i \,\}.$$

*Proof sketch.* The inclusion $V \subseteq U$ is immediate from monotonicity of
$S$ (a coordinate in $S_i$ is a coordinate in the union). For $U \subseteq V$,
let $f \in U$. For each coordinate $k$ choose a stage $c(k) \in I$ with
$f(k) \in S_{c(k)}$ (possible since $f(k) \in \bigcup_i S_i$). The image
$\{c(k) : k \in \kappa\}$ is a *finite* subset of $I$ because $\kappa$ is finite.
Directedness of $I$ provides an upper bound $M$ with $c(k) \le M$ for all $k$.
By monotonicity, $S_{c(k)} \subseteq S_M$, so $f(k) \in S_M$ for every $k$;
hence $f$ lies in the single stage $M$, i.e. $f \in V$. $\qquad\blacksquare$

The only nontrivial ingredient is the passage "directed + finite $\Rightarrow$
common upper bound." This is the structural reason the truncated Witt functor
$W_n$, whose underlying set is $R^n$, preserves filtered colimits.

### 3.2 The obstruction for countable arity

**Theorem 3.2 (countable powers do not commute).** Let $A = \mathbb{N}$,
$I = \mathbb{N}$ with its usual order, and $S_i = \{0, 1, \dots, i\}$ (so
$\bigcup_i S_i = \mathbb{N}$). Then
$$\{\, f : \mathbb{N} \to \mathbb{N} \ \mid\ \forall k,\ f(k) \in \textstyle\bigcup_i S_i \,\}
\;\ne\; \bigcup_{i} \{\, f : \mathbb{N} \to \mathbb{N} \ \mid\ \forall k,\ f(k) \in S_i \,\}.$$

*Proof sketch.* The identity sequence $\mathrm{id}(k) = k$ satisfies
$\mathrm{id}(k) = k \in \mathbb{N} = \bigcup_i S_i$ for all $k$, so
$\mathrm{id} \in U$. Suppose $\mathrm{id} \in V$; then $\mathrm{id} \in \{f :
\forall k,\ f(k) \le i\}$ for some fixed $i$, i.e. $k \le i$ for all $k$. Taking
$k = i + 1$ gives $i + 1 \le i$, a contradiction. Hence $\mathrm{id} \in U
\setminus V$ and $U \ne V$. $\qquad\blacksquare$

This is a *genuine* counterexample, not a vacuous inequality: the witness
$\mathrm{id}$ is explicit, the family $(S_i)$ is directed with full union, and the
gap $U \setminus V$ is nonempty. It is precisely the obstruction preventing the
naive Witt functor $R \mapsto R^{\mathbb{N}}$ from preserving filtered colimits —
a sequence can outrun every stage by remaining active in unboundedly many
coordinates.

### 3.3 The sheared repair

**Theorem 3.3 (finitely supported countable powers commute again).** Let $A$ be
a set, $I$ nonempty and directed, $S : I \to \mathcal{P}(A)$ monotone, and fix a
basepoint $b \in A$ with $b \in S_i$ for *every* $i \in I$. Then, with essential
support taken relative to $b$,
$$\{\, f : \mathbb{N} \to A \ \mid\ (\exists N\ \forall k \ge N,\ f(k) = b)\ \wedge\ \forall k\ f(k) \in \textstyle\bigcup_i S_i \,\}$$
$$=\; \bigcup_{i} \{\, f : \mathbb{N} \to A \ \mid\ (\exists N\ \forall k \ge N,\ f(k) = b)\ \wedge\ \forall k\ f(k) \in S_i \,\}.$$

*Proof sketch.* The inclusion $\supseteq$ is again immediate from monotonicity,
carrying the support witness $N$ along unchanged. For $\subseteq$, let $f$ be
eventually $b$ beyond index $N$, with every coordinate in $\bigcup_i S_i$. For
each coordinate $k$ choose a stage $c(k)$ with $f(k) \in S_{c(k)}$. Only the
coordinates $k \in \{0, \dots, N-1\}$ can be nontrivial, so it suffices to bound
$c$ on this *finite* set; directedness yields $M$ with $c(k) \le M$ for all
$k < N$. Now fix any coordinate $k$. If $k < N$, monotonicity gives $f(k) \in
S_{c(k)} \subseteq S_M$. If $k \ge N$, then $f(k) = b \in S_M$ by hypothesis on
the basepoint. Either way $f(k) \in S_M$, so $f$ lies in the single stage $M$.
$\qquad\blacksquare$

The finite set of "pre-support" coordinates $\{0, \dots, N-1\}$ plays the role
that the whole finite arity played in Theorem 3.1; the basepoint hypothesis
disposes of the infinite tail for free. This is exactly the mechanism of the
sheared Witt vectors: retaining only finitely-supported coordinates makes an
infinite-arity functor behave like a finite-arity one.

## 4. Ring-theoretic corollary

Specialising the carrier to a ring and the stages to subrings turns the abstract
statements into filtered-colimit statements for genuine rings.

**Corollary 4.1.** Let $R$ be a ring and $(S_i)_{i \in I}$ a monotone family of
subrings of $R$ over a nonempty directed index, with colimit the subring
$\bigsqcup_i S_i = \bigcup_i S_i$. For any finite $n$, the finite-arity
underlying-set functor $T \mapsto T^n$ satisfies
$$\{ f : \{1, \dots, n\} \to R \mid \forall k,\ f(k) \in \textstyle\bigcup_i S_i \} = \bigcup_i \{ f \mid \forall k,\ f(k) \in S_i \},$$
i.e. the truncated construction is computed stagewise. The analogous statement
for $R^{\mathbb{N}}$ fails (Theorem 3.2, transported along any strictly
increasing exhaustion), but is restored once one passes to finitely-supported
sequences with basepoint $0 \in S_i$ (Theorem 3.3).

Interpreted for Witt vectors: since the underlying set of $W_n$ is $R^n$, the
truncated Witt functor preserves filtered colimits; the naive Witt functor,
underlain by $R^{\mathbb{N}}$, does not; and the sheared Witt functor, underlain
by the finitely-supported power, does. The last statement is the design goal of
shearing and the enabling step for extending Dieudonné theory to nilperfect
rings.

## 5. Algorithms

The proofs are constructive and yield explicit *lifting procedures* — given a
tuple that is coordinate-wise in the colimit, produce a single stage containing
it (or certify that none exists).

**Algorithm A (finite-tuple stage lifting).** Input: a finite tuple $f$ and, for
each coordinate, a witnessing stage index. Output: a single stage index
$M = \max_k c(k)$ (for a totally ordered exhaustion) or a directed join of the
finitely many witnesses. Correctness is Theorem 3.1; complexity is linear in the
number of coordinates plus the cost of one $(n-1)$-fold directed join.

**Algorithm B (obstruction detector for countable arity).** Input: a sequence
$f$ and a totally ordered exhaustion $S_i = \{x : x \le i\}$. Output: a single
containing stage if $\sup_k f(k) < \infty$, else a certificate of
non-liftability. For the identity sequence the supremum is infinite, reproducing
Theorem 3.2.

**Algorithm C (sheared-tuple stage lifting).** Input: an eventually-basepoint
sequence with support bound $N$ and per-coordinate witnesses. Output: a single
stage $M$ bounding the finitely many pre-support witnesses; the tail is absorbed
by the basepoint. Correctness is Theorem 3.3.

## 6. Applications and numerical illustration

The trichotomy can be exhibited concretely with the integer exhaustion
$S_i = \{0, \dots, i\}$:

- A finite tuple such as $(3, 7, 2)$ is coordinate-wise in $\mathbb{N} =
  \bigcup_i S_i$ and lifts to the single stage $M = \max(3,7,2) = 7$.
- The identity sequence $(0,1,2,3,\dots)$ is coordinate-wise in $\mathbb{N}$ but
  lifts to no finite stage — the naive obstruction.
- The eventually-zero sequence $(3,7,2,0,0,0,\dots)$ lifts to $M = 7$, the max of
  its finitely many nonzero pre-support values — the sheared repair.

These computations are carried out explicitly in the accompanying numerical
demonstration, which also verifies the required-stage bounds and the identity of
the two set constructions on random finitely-supported inputs.

## 7. Discussion

The results say something sharper than "finite good, infinite bad." The true
invariant is the *cardinality of the active index set*: the set of coordinates on
which a tuple can differ from the basepoint. Directedness is a merging machine
with exactly one limitation — it can absorb any finite collection of stages into
one, but nothing more. Every result here is a direct consequence:

- finite arity $\Rightarrow$ finite active set $\Rightarrow$ mergeable
  (Theorem 3.1);
- countable arity with unbounded activity $\Rightarrow$ infinite active set
  $\Rightarrow$ not mergeable (Theorem 3.2);
- countable arity with finite essential support $\Rightarrow$ finite active set
  $\Rightarrow$ mergeable again (Theorem 3.3).

Thus "eventually equal to a basepoint" is not an ad hoc fix but the natural
finite-support condition; shearing is the minimal modification of an
infinite-arity functor that recovers filtered-colimit preservation.

## 8. Future directions

**A finiteness dichotomy for power functors over directed systems.** We conjecture
that, for a monotone directed family and an arbitrary arity $\kappa$, the
$\kappa$-power functor commutes with the directed union *if and only if* every
$\kappa$-indexed family of germs has finite essential support relative to the
system — equivalently, $\kappa$ is finite or the coordinates are constrained to a
finitely-supported subspace, with no intermediate regime. Directedness absorbs an
arbitrary *finite* set of stages but is powerless against an infinite one, so the
whole obstruction is concentrated in the cardinality of the active index set; the
three results here already bracket both sides, leaving only the sharp equivalence.

**Quantitative stage bounds for finite tuples.** We conjecture that when an
$n$-tuple lifts to a common stage, the required stage is bounded by an explicit
function of the $n$ coordinate-stages — exactly their maximum for a totally
ordered exhaustion, and a height-controlled join of the $n$ witnesses for a
general directed poset. The merge is not merely existential: the bound is
effective, computed from finitely many witnesses, upgrading preservation to a
constructive, size-bounded lifting.

**Shearing as a universal colimit-preserving correction.** We conjecture that for
any power-shaped functor failing to commute with filtered colimits, the
finitely-supported subfunctor is the *largest* subfunctor that does commute, and
is characterised by a universal property: every colimit-preserving subfunctor
factors through it. "Eventually equal to a basepoint" would then be the maximal
finite-support condition compatible with the colimit, making shearing canonical
rather than ad hoc.

**Finite limits beyond products against filtered colimits.** We conjecture that
the commutation established for finite products extends to all finite limits
(equalisers, pullbacks, and general finite diagrams) against filtered colimits,
recovering the classical "finite limits commute with filtered colimits" in this
concrete directed-union setting and clarifying which of those limits interact
with shearing.

## 9. Conclusion

Filtered-colimit preservation of a power-shaped functor is governed entirely by
the finiteness of its essential index set. Finite powers preserve; unrestricted
countable powers do not, witnessed explicitly by the identity sequence against
the standard exhaustion of $\mathbb{N}$; and restricting to finitely-supported
coordinates restores preservation. This trichotomy is the combinatorial heart of
why truncated Witt vectors behave, why naive Witt vectors do not, and why the
sheared Witt construction — keeping only finitely-supported coordinates — is the
right vehicle for carrying Dieudonné theory beyond perfect rings.
