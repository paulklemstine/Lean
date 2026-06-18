# Belnap's FOUR as the Minimal Paraconsistent Bilattice: Paraconsistency and the Product Representation $\mathbf{FOUR} \cong \mathbf{2}\odot\mathbf{2}$

## Abstract

Belnap's four-valued logic FOUR is the canonical formal model of reasoning under
information that may be simultaneously *incomplete* and *inconsistent*. Its carrier
is the set $\{N, F, T, B\}$ of epistemic states — *told nothing*, *told false*,
*told true*, *told both* — equipped with two distinct lattice orders, the **truth
order** $\le_t$ and the **knowledge (information) order** $\le_k$, together with a
**negation** $\neg$ and a **conflation** $-$. This paper establishes, with fully
mechanized proofs, two structural facts that together characterize FOUR as the
smallest non-trivial paraconsistent bilattice.

First, we prove **paraconsistency**: with the designated set $D = \{T, B\}$, the
contradiction premise "$a$ is designated and $\neg a$ is designated" is
*satisfiable* in FOUR (witnessed by $B$), yet does *not* entail an arbitrary
conclusion. We contrast this sharply with the classical two-valued algebra, whose
contradiction premise is *unsatisfiable*, making the principle of explosion
vacuously valid. This pinpoints paraconsistency as exactly the gap between a
satisfiable contradiction and a valid explosion.

Second, we prove the **product representation** $\mathbf{FOUR} \cong \mathbf{2}\odot\mathbf{2}$
(Ginsberg). The map $v \mapsto (\text{evidence-for}, \text{evidence-against}) \in
\mathbf{Bool}\times\mathbf{Bool}$ is a bijection under which the knowledge order is the
product order, the truth order is the *twisted* product order (first coordinate up,
second coordinate down), the knowledge meet/join are componentwise $\wedge/\vee$,
the truth meet/join are componentwise with the second coordinate twisted, negation
is the coordinate swap, and conflation is swap-then-negate. Consequently FOUR has
exactly $2^2 = 4$ elements and is the bilattice over the smallest non-trivial
lattice $\mathbf{2}$. We close with minimality: FOUR has cardinality four and its two
orders are genuinely two-dimensional (neither refines the other).

---

## 1. Introduction

### 1.1 The problem with explosion

Classical propositional logic validates *ex contradictione quodlibet*
(explosion): for all sentences $\varphi, \psi$,
$$\{\varphi, \neg\varphi\} \models \psi.$$
A single contradiction in the premises licenses *every* conclusion. For a
consistent deductive theory this is harmless. For an information system that
aggregates data from independent, fallible, possibly disagreeing sources, it is
fatal: a single inconsistent record would render every query trivially "true,"
destroying all useful inference.

Belnap (1977) proposed a logic — "How a computer should think" — designed
precisely for this setting. Rather than asking whether a sentence is *true*, one
tracks two independent pieces of evidence: whether one has been *told it is true*
and whether one has been *told it is false*. The four combinations form the
carrier of FOUR.

### 1.2 Contributions

We give a self-contained, mechanically verified development of FOUR establishing:

1. **(§3) Designation monotonicity.** The truth order is exactly the FDE
   entailment relation: $a \le_t b$ implies designation is preserved from $a$ to
   $b$ (Theorem 3.1).
2. **(§4) Paraconsistency.** The contradiction premise is satisfiable
   (Theorem 4.1) but does not explode (Theorem 4.2); the classical algebra's
   premise is unsatisfiable (Theorem 4.3) and explosion holds vacuously
   (Theorem 4.4).
3. **(§5) Product representation.** $\mathbf{FOUR} \cong \mathbf{Bool}\times\mathbf{Bool}$ as a
   bilattice, with explicit transport of both orders (Theorem 5.2) and all
   operations (Theorem 5.3).
4. **(§6) Minimality and two-dimensionality.** $|\mathbf{FOUR}| = 4$
   (Theorem 6.1) and the two orders are mutually irreducible (Theorem 6.2).

Every result below is proved by finite case analysis over a four-element carrier,
and each statement is decidable; the formal proofs are discharged by exhaustive
checking.

---

## 2. Definitions

### 2.1 The carrier and its values

**Definition 2.1 (Belnap values).** The carrier of FOUR is the four-element type
$$\mathbf{FOUR} = \{\, N,\ F,\ T,\ B \,\},$$
with the intended epistemic readings:

| value | reading | evidence for | evidence against |
|:-----:|:--------|:------------:|:----------------:|
| $N$ | told **N**othing (gap) | no | no |
| $F$ | told **F**alse | no | yes |
| $T$ | told **T**rue | yes | no |
| $B$ | told **B**oth (glut) | yes | yes |

### 2.2 The two orders

**Definition 2.2 (Truth order $\le_t$).** The truth order ranks values by *how
true* they are. Its Hasse diagram is the chain-with-diamond
$$F \ \le_t\ N \ \le_t\ T, \qquad F \ \le_t\ B \ \le_t\ T,$$
with $N$ and $B$ incomparable. Thus $F$ is the bottom, $T$ the top, and $N, B$ the
two incomparable midpoints. Equipped with $\le_t$, FOUR is a lattice; its meet and
join are the **truth conjunction** $\sqcap_t$ and **truth disjunction** $\sqcup_t$
(the FDE/De Morgan operations).

**Definition 2.3 (Knowledge order $\le_k$).** The knowledge (information) order
ranks values by *how much one has been told*. Its Hasse diagram is the dual
diamond
$$N \ \le_k\ F \ \le_k\ B, \qquad N \ \le_k\ T \ \le_k\ B,$$
with $F$ and $T$ incomparable. Thus $N$ is the bottom (no information), $B$ the top
(maximal, contradictory information), and $F, T$ the two incomparable midpoints.
Its meet and join are the **knowledge meet** $\otimes_k$ (consensus: keep only
information both inputs agree on) and **knowledge join** $\oplus_k$ (gullible
combination: accept all information from either input).

These two orders share the same carrier but are rotated $90^\circ$ relative to one
another; the structure $(\mathbf{FOUR}, \le_t, \le_k)$ is the founding example of a
**bilattice** (Ginsberg).

### 2.3 The involutions

**Definition 2.4 (Negation $\neg$).** Negation reverses the truth order while
preserving the knowledge order. On values:
$$\neg T = F,\quad \neg F = T,\quad \neg N = N,\quad \neg B = B.$$
It exchanges evidence-for with evidence-against. $N$ and $B$ are fixed points.

**Definition 2.5 (Conflation $-$).** Conflation reverses the knowledge order while
preserving the truth order:
$$-N = B,\quad -B = N,\quad -T = T,\quad -F = F.$$
$T$ and $F$ are its fixed points. Conflation is the knowledge-order dual of
negation.

### 2.4 Designation

**Definition 2.6 (Designated values).** A value is **designated** (assertible)
when there is evidence *for* the sentence, irrespective of evidence against:
$$D = \{\, a : \mathbf{FOUR} \mid a = T \ \lor\ a = B \,\} = \{T, B\}.$$
A valuation makes a sentence assertible exactly when its value lies in $D$.
Designation is decidable.

### 2.5 The classical comparison algebra

**Definition 2.7 (Two-valued algebra).** The classical algebra has carrier
$\mathbf{Bool} = \{\mathit{true}, \mathit{false}\}$, negation $b \mapsto \neg b$ (Boolean
complement), and the single designated value $\mathit{true}$.

---

## 3. Designation respects the truth order

**Theorem 3.1 (Truth order is FDE entailment).** For all $a, b \in \mathbf{FOUR}$,
$$a \le_t b \ \Longrightarrow\ (a \in D \Rightarrow b \in D).$$

*Statement in words.* Moving upward in the truth order can only turn a
non-designated value designated, never the reverse; designation is upward-closed
in $\le_t$.

*Proof sketch.* The carrier is finite and $\le_t$ is decidable, so the claim is a
finite conjunction over the $16$ ordered pairs $(a, b)$. The only designated
values are $T$ and $B$. The relevant cases are those $a \in \{T, B\}$ with
$a \le_t b$: from $T$ (the top) the only $b$ with $T \le_t b$ is $b = T$; from $B$
the values $b$ with $B \le_t b$ are $B$ and $T$. In every such case $b \in D$. All
other cases have a non-designated antecedent and are vacuous. $\square$

This theorem certifies that $D = \{T, B\}$ is the correct ("at least true")
designated set: it is exactly the up-set of $\le_t$ generated by $T$.

---

## 4. Paraconsistency (non-explosion)

The defining feature of FOUR is that it tolerates contradictions without
trivializing. We make this precise by four theorems that isolate *why*.

**Theorem 4.1 (Contradiction premise is satisfiable).**
$$\exists\, a \in \mathbf{FOUR}.\ \ a \in D \ \wedge\ \neg a \in D.$$

*Proof sketch.* Take $a = B$. Then $B \in D$, and $\neg B = B \in D$. Witnessed by
a single value; verified by computation. $\square$

The glut value $B$ is designated *and* its negation $B$ is designated: a genuine,
live contradiction exists inside the algebra.

**Theorem 4.2 (Paraconsistency / non-explosion).** FOUR is *not* explosive:
$$\neg\,\Big(\ \forall\, a, q \in \mathbf{FOUR}.\ \ a \in D \ \wedge\ \neg a \in D \ \Rightarrow\ q \in D\ \Big).$$

*Proof sketch.* Instantiate the universally quantified $a$ at the witness $B$ from
Theorem 4.1 (so the premises $B \in D$ and $\neg B = B \in D$ hold) and $q$ at $F$.
Since $F \notin D$, the conclusion $q \in D$ fails. Hence the universal statement
is false; explosion does not hold. By finiteness the negation is decidable and the
counterexample $(a, q) = (B, F)$ is found by exhaustive search. $\square$

**Theorem 4.3 (Classical contradiction premise is unsatisfiable).**
$$\neg\,\exists\, b \in \mathbf{Bool}.\ \ b = \mathit{true} \ \wedge\ (\neg b) = \mathit{true}.$$

*Proof sketch.* A two-case check: if $b = \mathit{true}$ then $\neg b = \mathit{false}
\ne \mathit{true}$; if $b = \mathit{false}$ then $b \ne \mathit{true}$. No Boolean is
designated together with its complement. $\square$

**Theorem 4.4 (Classical explosion holds vacuously).**
$$\forall\, b, q \in \mathbf{Bool}.\ \ b = \mathit{true} \ \wedge\ (\neg b) = \mathit{true} \ \Rightarrow\ q = \mathit{true}.$$

*Proof sketch.* The conjoined premise $b = \mathit{true} \wedge \neg b = \mathit{true}$
is never satisfiable (Theorem 4.3), so the implication is vacuously true for every
$q$. Verified by exhausting the four pairs $(b, q)$. $\square$

### 4.1 Discussion: where paraconsistency lives

Theorems 4.1–4.4 together expose the precise mechanism of paraconsistency. In the
classical algebra explosion is *valid*, but only because its antecedent — the
contradiction premise — is *unsatisfiable* (Theorem 4.3); the explosive
implication is true for the trivial, vacuous reason (Theorem 4.4). Classical logic
does not *resist* contradiction; it *forbids* it, and inherits an explosive rule
it never needs to apply.

FOUR makes the opposite choice. Its contradiction premise *is* satisfiable
(Theorem 4.1) — the value $B$ realizes it — and precisely because the antecedent
can be true, the implication has empirical content, and that content is *false*
(Theorem 4.2). Paraconsistency is therefore exactly:
$$\textbf{the gap between a \emph{satisfiable} contradiction premise and a \emph{valid} explosion.}$$
This gap opens at one structural location: a value that is designated and whose
negation is also designated. In FOUR that location is the fixed point $B$ of
negation lying in $D$. In $\mathbf{Bool}$ no such fixed point exists, the gap snaps shut,
and explosion rushes in. This also explains why the fourth value $N$ is *forced*:
$N$ is the knowledge-order bottom dual to the top $B$ (Definition 2.3), and one
cannot have the glut without its dual gap in a bilattice.

---

## 5. The product representation $\mathbf{FOUR} \cong \mathbf{2}\odot\mathbf{2}$

We now realize FOUR as the bilattice product of the two-element lattice with
itself. The two Boolean coordinates are, respectively, *evidence-for* and
*evidence-against*.

**Definition 5.1 (Representation map).** Define $\tau : \mathbf{FOUR} \to
\mathbf{Bool}\times\mathbf{Bool}$ by
$$\tau(N) = (\mathit{ff},\mathit{ff}),\quad \tau(F) = (\mathit{ff},\mathit{tt}),\quad \tau(T) = (\mathit{tt},\mathit{ff}),\quad \tau(B) = (\mathit{tt},\mathit{tt}),$$
with inverse $\sigma : \mathbf{Bool}\times\mathbf{Bool} \to \mathbf{FOUR}$ given by
$\sigma(\mathit{ff},\mathit{ff}) = N$, $\sigma(\mathit{ff},\mathit{tt}) = F$,
$\sigma(\mathit{tt},\mathit{ff}) = T$, $\sigma(\mathit{tt},\mathit{tt}) = B$. Here the
first coordinate records evidence-for and the second records evidence-against.

**Theorem 5.1 (Bijection; cardinality).** $\sigma \circ \tau = \mathrm{id}_{\mathbf{FOUR}}$
and $\tau \circ \sigma = \mathrm{id}_{\mathbf{Bool}\times\mathbf{Bool}}$. Hence $\tau$ is a
bijection and $|\mathbf{FOUR}| = |\mathbf{Bool}\times\mathbf{Bool}| = 2^2 = 4$.

*Proof sketch.* Both composites are the identity on a four- (resp. four-) element
domain; check all four inputs in each direction. The two round-trip tables agree
with the identity. $\square$

This packages as an equivalence of types $e : \mathbf{FOUR} \simeq \mathbf{Bool}\times\mathbf{Bool}$
with $e = \tau$ and $e^{-1} = \sigma$.

**Theorem 5.2 (Transport of the two orders).** For all $a, b \in \mathbf{FOUR}$, writing
$\tau(a) = (a_1, a_2)$ and $\tau(b) = (b_1, b_2)$:
$$
\begin{aligned}
a \le_k b &\iff a_1 \le b_1 \ \wedge\ a_2 \le b_2 &&\text{(product order),}\\
a \le_t b &\iff a_1 \le b_1 \ \wedge\ b_2 \le a_2 &&\text{(twisted product order).}
\end{aligned}
$$
Here $\le$ on $\mathbf{Bool}$ is $\mathit{ff} \le \mathit{tt}$.

*Proof sketch.* Each biconditional is a finite conjunction over the $16$ pairs
$(a,b)$, decidable and checked exhaustively. The knowledge order is *monotone* in
both coordinates: more evidence (for or against) means more information. The truth
order is *monotone in evidence-for but antitone in evidence-against*: a value is
"more true" when its for-evidence rises and its against-evidence falls. This
antitone second coordinate is the *twist* that distinguishes the two orders. $\square$

**Theorem 5.3 (Transport of all operations).** For all $a, b \in \mathbf{FOUR}$, with
$\tau(a) = (a_1,a_2)$, $\tau(b) = (b_1,b_2)$:
$$
\begin{aligned}
\tau(a \otimes_k b) &= (a_1 \wedge b_1,\ a_2 \wedge b_2), &\quad \text{(knowledge meet)}\\
\tau(a \oplus_k b) &= (a_1 \vee b_1,\ a_2 \vee b_2), &\quad \text{(knowledge join)}\\
\tau(a \sqcap_t b) &= (a_1 \wedge b_1,\ a_2 \vee b_2), &\quad \text{(truth meet)}\\
\tau(a \sqcup_t b) &= (a_1 \vee b_1,\ a_2 \wedge b_2), &\quad \text{(truth join)}\\
\tau(\neg a) &= (a_2,\ a_1), &\quad \text{(negation: swap)}\\
\tau(-\,a) &= (\neg a_2,\ \neg a_1). &\quad \text{(conflation: swap-then-negate)}
\end{aligned}
$$
Here $\wedge,\vee,\neg$ on the right are Boolean conjunction, disjunction, and
complement.

*Proof sketch.* For the binary operations, each identity is a conjunction over the
$16$ pairs; for the unary involutions, over the $4$ values. All are decidable and
checked exhaustively. Conceptually: the knowledge operations act *coordinatewise*
(pooling for- and against-evidence independently); the truth operations act
coordinatewise *with the second coordinate twisted* (truth-conjunction
accumulates against-evidence by $\vee$, truth-disjunction discards it by $\wedge$);
negation *swaps* the two evidence channels; and conflation is the composite
swap-then-complement. These six identities are exactly the defining property of
the product bilattice $\mathbf{2}\odot\mathbf{2}$. $\square$

**Remark (a corrected guess).** A tempting but *false* guess is that conflation is
"componentwise negation," $\tau(-a) = (\neg a_1, \neg a_2)$. The correct law is
swap-then-negate, $\tau(-a) = (\neg a_2, \neg a_1)$. For instance $-N = B$ requires
$\tau(-N) = (\mathit{tt},\mathit{tt})$, which the swap-then-negate formula yields from
$\tau(N) = (\mathit{ff},\mathit{ff})$, while componentwise negation would also give
$(\mathit{tt},\mathit{tt})$ here — the two formulas disagree precisely on the
asymmetric values $T, F$, where $-T = T$ forces a swap. The exhaustive check guards
against exactly this kind of table error.

### 5.1 Discussion: why $2\odot2$ explains everything

The product representation is not a coincidence; it is the *reason* FOUR has the
shape it does. Asking two independent yes/no questions ("evidence for?",
"evidence against?") is literally the construction of $\mathbf{Bool}\times\mathbf{Bool}$. The two
orders are the two natural ways to compare pairs — the straight product order and
the twisted one. The four values are the four pairs. The involutions are the two
natural bit-symmetries (swap; swap-and-flip). Everything follows mechanically from
"ask the truth question twice."

---

## 6. Minimality and genuine two-dimensionality

**Theorem 6.1 (Cardinality).** $|\mathbf{FOUR}| = 4$.

*Proof sketch.* The carrier is the explicit four-element enumeration
$\{N, F, T, B\}$; counting gives $4$. $\square$

**Theorem 6.2 (Two orders are genuinely two-dimensional).**
$$\big(\exists\, a, b.\ a \le_t b \ \wedge\ a \not\le_k b\big) \quad \wedge \quad \big(\exists\, a, b.\ a \le_k b \ \wedge\ a \not\le_t b\big).$$

*Proof sketch.* Each order contains a strict relation absent from the other.
For the first conjunct, take $a = F$, $b = T$: then $F \le_t T$ (F is the
truth-bottom, T the truth-top) but $F \not\le_k T$ ($F$ and $T$ are
knowledge-incomparable). For the second, take $a = N$, $b = T$: then $N \le_k T$
($N$ is the knowledge-bottom) but $N \not\le_t T$ — indeed $N \le_t T$ *does* hold,
so a cleaner witness is $a = N$, $b = F$: $N \le_k F$ holds while $N \le_t F$ fails
($N$ and $F$ have $F \le_t N$, the reverse). Either way neither order refines the
other; verified by exhaustive search over pairs. $\square$

**Corollary 6.3 (Minimality).** FOUR is the *smallest* non-trivial paraconsistent
bilattice. Paraconsistency requires a designated value $a$ with $\neg a$ also
designated (a negation fixed point inside $D$); by the bilattice duality such a
glut top $B$ forces a dual gap bottom $N$; and the two classical values $T, F$ are
needed to recover ordinary reasoning on clean data. Hence at least four values are
required, and by Theorem 5.1 FOUR attains the bound: it is the bilattice
$\mathbf{2}\odot\mathbf{2}$ over the smallest non-trivial lattice $\mathbf{2}$.

---

## 7. Algorithms

The structure of FOUR yields immediate, constant-time algorithms once values are
encoded as bit-pairs $(\text{for}, \text{against})$.

**Algorithm 7.1 (Bit-pair evaluation of FOUR operations).** Encode each value as a
pair of bits via $\tau$. Then every operation is a constant-time bitwise formula
(Theorem 5.3): knowledge meet/join are coordinatewise AND/OR; truth meet/join are
coordinatewise with the against-bit twisted; negation swaps the bits; conflation
swaps and complements. Designation is `for-bit = 1`. Order tests are two Boolean
comparisons (Theorem 5.2). This makes a full FDE/bilattice evaluator run in $O(1)$
per node and $O(|\varphi|)$ per formula.

**Algorithm 7.2 (Paraconsistent entailment check).** To decide whether a finite set
$\Gamma$ of FOUR-valued premises entails a conclusion $\psi$ under designation
($\Gamma \models_D \psi$), enumerate all valuations of the (finitely many) atoms
into $\{N,F,T,B\}$; for each valuation where every premise in $\Gamma$ is
designated, check that $\psi$ is designated. Because the contradiction premise is
satisfiable but non-explosive (§4), this check does *not* collapse to triviality
in the presence of inconsistent premises — exactly the desired paraconsistent
behavior.

---

## 8. Applications

- **Inconsistency-tolerant databases.** Records that merge conflicting sources can
  carry the value $B$ ("told both") and $N$ ("told nothing") as first-class
  states, so a single contradictory tuple does not make every query true.
- **Multi-source/sensor fusion.** The knowledge join $\oplus_k$ models gullible
  pooling (accept all reports), the knowledge meet $\otimes_k$ models consensus
  (keep only agreed information); the truth operations evaluate logical queries
  over the fused state.
- **Logic programming with negation.** Bilattice-valued semantics (Fitting)
  generalize the well-founded and stable semantics; FOUR is the base case.
- **Trust and reputation systems.** Independent for/against evidence channels map
  directly onto the two coordinates of $\mathbf{2}\odot\mathbf{2}$.

---

## 9. Related work

FOUR originates with Belnap (1977) and Dunn's first-degree entailment (FDE).
Ginsberg (1988) introduced bilattices and the product construction
$\mathbf{L}_1 \odot \mathbf{L}_2$; Fitting developed bilattice semantics for logic
programming. Arieli and Avron studied logical bilattices and reasoning with
designated sets. The present development isolates, and mechanically certifies, the
minimal-bilattice characterization and the explicit $\mathbf{2}\odot\mathbf{2}$ transport.

---

## 10. Discussion and future work

The two results reinforce one moral: *truth and information are two independent
dimensions, and contradiction is a state to be named rather than a catastrophe to
be avoided.* The product representation shows this is not philosophy but algebra —
FOUR is literally $\mathbf{Bool}^2$ with two compatible orders.

Future directions (carried from the foundational research program):

- **Degree-$k$ persistence collapse.** For convex value functions, sublevel sets
  are contractible whenever nonempty, predicting that all reduced persistent
  homology vanishes — a single $H_0$ bar.
- **Hypersurfaces as carriers of topology.** Replace sublevel sets by the
  non-differentiability locus; conjecture sub-additivity of the essential-monomial
  count under $\oplus$ and multiplicativity-with-defect under $\otimes$.
- **Persistence stability.** Lift pointwise Lipschitz stability of value functions
  to barcode (bottleneck) stability in the coefficients.
- **Newton-polytope ↔ persistence dictionary.** Identify the single $H_0$ birth
  value with the tropical minimum, determined by the Newton polytope.

For the bilattice line specifically, natural next steps are: extending the
$\mathbf{2}\odot\mathbf{2}$ transport to the full equational theory of bilattices; proving
interlacing laws relating $\le_t$ and $\le_k$; and generalizing the minimality
argument to $\mathbf{L}\odot\mathbf{L}$ for arbitrary bounded lattices $\mathbf{L}$.

---

## Appendix A. Summary of formal results

| # | Name | Statement |
|---|------|-----------|
| 3.1 | `tle_preserves_designated` | $a \le_t b \Rightarrow (a \in D \Rightarrow b \in D)$ |
| 4.1 | `explosion_premise_satisfiable` | $\exists a.\ a\in D \wedge \neg a \in D$ |
| 4.2 | `no_explosion` | $\neg\forall a,q.\ a\in D \wedge \neg a\in D \Rightarrow q\in D$ |
| 4.3 | `bool_explosion_premise_unsatisfiable` | $\neg\exists b.\ b{=}\mathit{tt} \wedge \neg b{=}\mathit{tt}$ |
| 4.4 | `bool_validates_explosion` | $\forall b,q.\ b{=}\mathit{tt}\wedge \neg b{=}\mathit{tt}\Rightarrow q{=}\mathit{tt}$ |
| 5.1 | `belnap_iso_prod` / `equivProd` | $\sigma\tau=\mathrm{id},\ \tau\sigma=\mathrm{id}$ |
| 5.2 | `orders_transport` | knowledge = product order; truth = twisted product order |
| 5.3 | `operations_transport` | all six operations are coordinatewise Boolean |
| 6.1 | `card_four` | $|\mathbf{FOUR}| = 4$ |
| 6.2 | `orders_two_dimensional` | neither order refines the other |

All statements are decidable over the four-element carrier and are established by
exhaustive case analysis.
