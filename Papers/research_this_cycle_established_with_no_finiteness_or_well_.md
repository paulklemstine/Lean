# The Complete Extensions of an Argumentation Framework Form a Meet-Semilattice

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We study the order-theoretic structure of the *complete extensions* of an
abstract argumentation framework in the sense of Dung. Working with an arbitrary
attack relation $R$ on an arbitrary set $A$ of arguments — imposing no
finiteness, acyclicity, or well-foundedness hypothesis — we prove that the
complete extensions, ordered by inclusion, form a **meet-semilattice**: every
nonempty family of complete extensions possesses a greatest lower bound that is
again a complete extension. The construction is uniform and elementary. Its
engine is a single lemma: the defense (characteristic) operator $F$ maps the
intersection of any family of complete extensions into itself. Consequently $F$
restricts to a monotone self-map of the interval below that intersection, and its
greatest fixed point there — built explicitly as a Knaster–Tarski union of
post-fixed points — is the desired meet. Specializing to the family of *all*
complete extensions recovers the **grounded extension** as the bottom element of
the semilattice, thereby re-deriving its existence and uniqueness purely
order-theoretically, without transfinite iteration. Along the way we give
self-contained proofs of Dung's Fundamental Lemma and of the unconditional
existence of a complete extension via Zorn's Lemma.

**Keywords:** abstract argumentation, Dung semantics, complete extension,
grounded extension, defense operator, meet-semilattice, Knaster–Tarski fixed
point, greatest lower bound.

## 1. Introduction

Abstract argumentation, introduced by Dung, models defeasible reasoning by
abstracting away the internal content of arguments and retaining only a binary
*attack* relation between them. Formally, an **argumentation framework** is a pair
$(A, R)$ where $A$ is a set of arguments and $R \subseteq A \times A$ is the
attack relation; we write $R\,a\,b$ for "$a$ attacks $b$". Over this spare
structure, Dung defined a hierarchy of *extensions* — sets of arguments that can
be rationally accepted together — including admissible, complete, grounded,
preferred, and stable extensions. These semantics underpin a broad range of
applications in nonmonotonic reasoning, legal and medical decision support,
multi-agent systems, and the reconciliation of inconsistent knowledge bases.

A recurring theme in the theory is that the various families of extensions carry
rich order-theoretic structure. The complete extensions in particular are known
to form a complete lattice under favorable finiteness conditions. The present
work isolates the *meet* half of that structure and establishes it in full
generality: for an **arbitrary** attack relation on an **arbitrary** carrier set,
every nonempty family of complete extensions has a greatest lower bound that is
itself complete. No finiteness, no well-foundedness, no acyclicity is required.

Our contributions are:

1. A short, self-contained development of the basic Dung semantics: conflict-free
   sets, defense, admissibility, the characteristic operator $F$, and complete
   extensions as conflict-free fixed points of $F$ (Section 2).
2. The **decisive lemma** that $F$ maps the intersection of any family of complete
   extensions into itself (Theorem 3.1).
3. An explicit construction of the meet of a family via a Knaster–Tarski union of
   post-fixed points, and a proof that it is a complete extension and the greatest
   lower bound (Section 4). This yields the meet-semilattice theorem
   (Theorem 4.7) and its binary specialization (Theorem 4.9).
4. A self-contained proof of Dung's Fundamental Lemma and of the unconditional
   existence of a complete extension via Zorn's Lemma (Section 5).
5. An order-theoretic re-derivation of the grounded extension as the least
   complete extension — the bottom of the semilattice — together with its
   uniqueness (Section 6).

## 2. Definitions

Fix a set $A$ and a relation $R : A \times A \to \mathrm{Prop}$. We write
$R\,a\,b$ to mean that $a$ attacks $b$. Subsets of $A$ are ordered by inclusion.

**Definition 2.1 (Conflict-free).** A set $S \subseteq A$ is *conflict-free* if
no member of $S$ attacks another member of $S$:
$$\forall a \in S,\ \forall b \in S,\ \neg\, R\,a\,b.$$

**Definition 2.2 (Defense).** A set $S$ *defends* an argument $a$ if every
attacker of $a$ is counterattacked from within $S$:
$$\mathrm{Defends}(S, a) \iff \forall b,\ R\,b\,a \Rightarrow \exists c \in S,\ R\,c\,b.$$

**Definition 2.3 (Admissible).** A set $S$ is *admissible* if it is conflict-free
and defends each of its members:
$$\mathrm{Admissible}(S) \iff \mathrm{ConflictFree}(S) \wedge \big(\forall a \in S,\ \mathrm{Defends}(S, a)\big).$$

**Definition 2.4 (Characteristic / defense operator).** The *characteristic
operator* $F : \mathcal{P}(A) \to \mathcal{P}(A)$ sends a set to the collection
of arguments it defends:
$$F(S) = \{\, a \in A : \mathrm{Defends}(S, a) \,\}.$$

**Definition 2.5 (Complete extension).** A set $S$ is a *complete extension* if
it is admissible and closed under defense:
$$\mathrm{Complete}(S) \iff \mathrm{Admissible}(S) \wedge F(S) \subseteq S.$$

The following elementary facts are used throughout.

**Lemma 2.6 (Monotonicity of defense).** If $S \subseteq T$ and $\mathrm{Defends}(S, a)$,
then $\mathrm{Defends}(T, a)$. Consequently $F$ is monotone: $S \subseteq T$
implies $F(S) \subseteq F(T)$.

*Proof.* If $b$ attacks $a$, then by hypothesis some $c \in S$ attacks $b$; since
$S \subseteq T$, that same $c$ lies in $T$. $\square$

**Lemma 2.7 (Conflict-freedom is downward closed).** If $S \subseteq T$ and $T$
is conflict-free, then $S$ is conflict-free.

*Proof.* Immediate from the definition, restricting the quantifiers to the
smaller set. $\square$

**Lemma 2.8 (Complete extensions are fixed points).** If $S$ is a complete
extension, then $F(S) = S$.

*Proof.* Completeness gives $F(S) \subseteq S$ directly. For the reverse
inclusion, admissibility gives that $S$ defends each of its members, i.e.
$S \subseteq F(S)$. Antisymmetry yields equality. $\square$

Thus **a complete extension is precisely a conflict-free fixed point of the
monotone operator $F$.** This fixed-point characterization is the lens through
which we view everything below.

## 3. The Decisive Lemma

The whole construction rests on a single observation about how $F$ interacts with
intersections of complete extensions.

**Theorem 3.1 (The defense operator stabilizes the intersection).** Let
$\mathcal{S}$ be a family of complete extensions, and let $I = \bigcap \mathcal{S}$
be its intersection. Then
$$F(I) \subseteq I.$$

*Proof.* Let $a \in F(I)$ and let $E \in \mathcal{S}$ be arbitrary. Since
$I \subseteq E$, monotonicity (Lemma 2.6) gives $F(I) \subseteq F(E)$, so
$a \in F(E)$. But $E$ is complete, so by Lemma 2.8 we have $F(E) = E$, whence
$a \in E$. As $E$ was an arbitrary member of $\mathcal{S}$, we conclude
$a \in \bigcap \mathcal{S} = I$. $\square$

Theorem 3.1 says that $F$ restricts to a monotone self-map of the interval
$[\varnothing, I]$ of the powerset lattice. By the Knaster–Tarski theorem, such a
map has a greatest fixed point within that interval. We build it explicitly and
verify it is a complete extension.

## 4. The Meet of a Family of Complete Extensions

**Definition 4.1 (Family meet).** For a family $\mathcal{S}$ of sets, define
$$M(\mathcal{S}) = \bigcup \big\{\, S : S \subseteq \textstyle\bigcap \mathcal{S}\ \text{and}\ S \subseteq F(S) \,\big\}.$$
That is, $M(\mathcal{S})$ is the union of all *post-fixed points* of $F$ (sets
with $S \subseteq F(S)$) that lie below the intersection. This is the standard
Knaster–Tarski construction of the greatest fixed point below $\bigcap\mathcal{S}$.

We now record its properties. Throughout, $\mathcal{S}$ is a family of complete
extensions.

**Lemma 4.2 (Below the intersection).** $M(\mathcal{S}) \subseteq \bigcap \mathcal{S}$.

*Proof.* Any $x \in M(\mathcal{S})$ lies in some $S$ with $S \subseteq \bigcap\mathcal{S}$,
hence $x \in \bigcap\mathcal{S}$. $\square$

**Lemma 4.3 (Post-fixed point).** $M(\mathcal{S}) \subseteq F(M(\mathcal{S}))$.

*Proof.* Let $x \in M(\mathcal{S})$, witnessed by a set $S$ with
$S \subseteq \bigcap\mathcal{S}$, $S \subseteq F(S)$, and $x \in S$. Then
$S \subseteq M(\mathcal{S})$ by construction, so monotonicity gives
$F(S) \subseteq F(M(\mathcal{S}))$. Since $x \in S \subseteq F(S)$, we get
$x \in F(M(\mathcal{S}))$. $\square$

**Lemma 4.4 (Pre-fixed point).** $F(M(\mathcal{S})) \subseteq M(\mathcal{S})$.

*Proof.* We show $F(M(\mathcal{S}))$ is itself one of the sets in the union
defining $M(\mathcal{S})$. First, $F(M(\mathcal{S})) \subseteq \bigcap\mathcal{S}$:
indeed $M(\mathcal{S}) \subseteq \bigcap\mathcal{S}$ by Lemma 4.2, so
$F(M(\mathcal{S})) \subseteq F(\bigcap\mathcal{S}) \subseteq \bigcap\mathcal{S}$
by monotonicity and Theorem 3.1. Second, $F(M(\mathcal{S}))$ is a post-fixed
point: applying $F$ to the inclusion of Lemma 4.3 gives
$F(M(\mathcal{S})) \subseteq F(F(M(\mathcal{S})))$. Hence $F(M(\mathcal{S}))$
qualifies for the union, so $F(M(\mathcal{S})) \subseteq M(\mathcal{S})$. $\square$

**Theorem 4.5 (The meet is a fixed point).** $F(M(\mathcal{S})) = M(\mathcal{S})$.

*Proof.* Combine Lemmas 4.3 and 4.4 by antisymmetry. $\square$

**Lemma 4.6 (Conflict-freedom).** If $\mathcal{S}$ is nonempty, then
$M(\mathcal{S})$ is conflict-free.

*Proof.* Pick any $E \in \mathcal{S}$. Then $M(\mathcal{S}) \subseteq \bigcap\mathcal{S} \subseteq E$,
and $E$ is conflict-free (being complete, hence admissible). By Lemma 2.7,
$M(\mathcal{S})$ is conflict-free. $\square$

**Theorem 4.7 (The meet is complete).** If $\mathcal{S}$ is a nonempty family of
complete extensions, then $M(\mathcal{S})$ is a complete extension.

*Proof.* By Lemma 4.6 it is conflict-free; by Theorem 4.5 it is a fixed point of
$F$, hence in particular $F(M(\mathcal{S})) \subseteq M(\mathcal{S})$
(completeness closure) and $M(\mathcal{S}) \subseteq F(M(\mathcal{S}))$, the
latter supplying the admissibility clause "$S$ defends its members". Thus
$M(\mathcal{S})$ is conflict-free, defends each of its members, and is closed
under defense — a complete extension. $\square$

It remains to see that $M(\mathcal{S})$ is the *greatest lower bound*.

**Lemma 4.8 (Lower bound).** For every $E \in \mathcal{S}$, $M(\mathcal{S}) \subseteq E$.

*Proof.* $M(\mathcal{S}) \subseteq \bigcap\mathcal{S} \subseteq E$. $\square$

**Theorem 4.9 (Greatest lower bound).** Let $L$ be any complete extension that is
a lower bound of $\mathcal{S}$, i.e. $L \subseteq E$ for all $E \in \mathcal{S}$.
Then $L \subseteq M(\mathcal{S})$.

*Proof.* Since $L \subseteq E$ for every $E$, we have $L \subseteq \bigcap\mathcal{S}$.
Since $L$ is admissible, $L \subseteq F(L)$, so $L$ is a post-fixed point below
the intersection — precisely a set in the union defining $M(\mathcal{S})$. Hence
$L \subseteq M(\mathcal{S})$. $\square$

Combining Theorems 4.7 and 4.9 with Lemma 4.8 yields the main result.

**Theorem 4.10 (Meet-semilattice).** *For any argumentation framework $(A, R)$,
with no finiteness or well-foundedness hypothesis, the complete extensions
ordered by inclusion form a meet-semilattice: every nonempty family $\mathcal{S}$
of complete extensions has a greatest lower bound $M(\mathcal{S})$, which is
itself a complete extension.*

**Corollary 4.11 (Binary meet).** For complete extensions $S$ and $T$, put
$S \wedge T = M(\{S, T\})$. Then $S \wedge T$ is a complete extension satisfying
$S \wedge T \subseteq S$, $S \wedge T \subseteq T$, and $L \subseteq S \wedge T$
for every complete extension $L$ with $L \subseteq S$ and $L \subseteq T$. Thus
$S \wedge T$ is the greatest complete extension contained in both.

*Proof.* Apply Theorem 4.10 to the two-element family $\{S, T\}$, which is
nonempty; the lower-bound and greatest-lower-bound clauses specialize directly.
$\square$

## 5. Existence of Complete Extensions

To locate a bottom element we must first know that complete extensions exist at
all. This is the classical Zorn-plus-Fundamental-Lemma argument, which we include
for self-containedness.

**Theorem 5.1 (Dung's Fundamental Lemma).** If $S$ is admissible and defends an
argument $a$, then $S \cup \{a\}$ is admissible.

*Proof.* Write $S' = S \cup \{a\}$. We first establish three auxiliary facts.
(i) No member of $S$ attacks $a$: if $c \in S$ attacked $a$, then since $S$
defends $a$ some $d \in S$ would attack $c$, contradicting conflict-freedom of
$S$. (ii) $a$ attacks no member of $S$: if $a$ attacked some $c \in S$, then
since $S$ defends $c$ some $d \in S$ would attack $a$, contradicting (i).
(iii) $a$ does not attack itself: otherwise $S$, defending $a$, would contain an
attacker of $a$, contradicting (i). Conflict-freedom of $S'$ now follows by
cases on whether each of two chosen elements equals $a$ or lies in $S$, using
(i)–(iii) and conflict-freedom of $S$. Finally $S'$ defends each of its members:
$a$ is defended by $S \subseteq S'$ (by hypothesis, via monotonicity), and each
$c \in S$ is defended by $S \subseteq S'$ (as $S$ already defended it). $\square$

**Lemma 5.2 (Chains of admissible sets).** The union of a chain (a totally
ordered-by-inclusion subfamily) of admissible sets is admissible.

*Proof.* Let $c$ be such a chain and $U = \bigcup c$. For conflict-freedom, take
$a, b \in U$; they lie in members $S_1, S_2 \in c$ respectively, and by totality
one contains the other, say $S_1 \subseteq S_2$; then $a, b \in S_2$, which is
conflict-free, so $a$ does not attack $b$. For defense, any $a \in U$ lies in
some $S \in c$; $S$ defends $a$, and $S \subseteq U$, so by monotonicity $U$
defends $a$. $\square$

**Theorem 5.3 (Existence of a complete extension).** Every argumentation
framework has a complete extension.

*Proof.* The empty set is admissible (both clauses hold vacuously). By Lemma 5.2
every chain of admissible sets has an admissible upper bound (its union), so by
Zorn's Lemma there is a *maximal* admissible set $m$. We claim $m$ is complete.
It is admissible by construction, so we need only $F(m) \subseteq m$. Suppose
$a \in F(m)$, i.e. $m$ defends $a$. By the Fundamental Lemma (Theorem 5.1),
$m \cup \{a\}$ is admissible; by maximality $m \cup \{a\} = m$, so $a \in m$.
Hence $F(m) \subseteq m$, and $m$ is complete. $\square$

(Maximal admissible sets are precisely the *preferred extensions*; Theorem 5.3
also shows preferred extensions always exist and are complete.)

## 6. The Grounded Extension as the Bottom of the Semilattice

We now harvest the least complete extension as an order-theoretic corollary.

**Theorem 6.1 (Least complete extension).** Every argumentation framework has a
least complete extension: a complete extension contained in every complete
extension.

*Proof.* Let $\mathcal{C} = \{\, S : \mathrm{Complete}(S) \,\}$ be the family of
all complete extensions. By Theorem 5.3, $\mathcal{C}$ is nonempty. Apply the
meet construction to $\mathcal{C}$: by Theorem 4.7, $M(\mathcal{C})$ is a complete
extension, and by Lemma 4.8 it is contained in every member of $\mathcal{C}$ —
that is, in every complete extension. Hence $M(\mathcal{C})$ is the least complete
extension. $\square$

The least complete extension is exactly Dung's **grounded extension**. The usual
construction obtains it as the least fixed point of $F$ reached by iterating from
the empty set, in general transfinitely. Theorem 6.1 obtains it instead as the
*bottom of the meet-semilattice*, bypassing the transfinite iteration entirely:
it is a single greatest-lower-bound of the whole family of complete extensions.

**Theorem 6.2 (Uniqueness of the least complete extension).** If $L$ and $L'$ are
both least complete extensions, then $L = L'$.

*Proof.* Since $L$ is least and $L'$ is complete, $L \subseteq L'$. Since $L'$ is
least and $L$ is complete, $L' \subseteq L$. Antisymmetry gives $L = L'$.
$\square$

Thus the grounded extension is the unique bottom element of the complete-extension
meet-semilattice, characterized purely order-theoretically.

## 7. Discussion

The proofs above are notable for what they *do not* assume. Standard treatments
of the lattice structure of complete extensions lean on finiteness of the
framework (so the defense operator reaches its fixed points in finitely many
steps) or on well-foundedness of the attack relation (so induction is available).
Here the only tool is monotonicity plus the Knaster–Tarski union, and the pivotal
input is Theorem 3.1 — the closure of intersections under $F$. This single lemma
converts the search for a common lower bound of several complete extensions into a
*greatest-fixed-point problem on a fixed interval*, which the Knaster–Tarski union
solves uniformly. The generality is genuine: infinite argument sets and arbitrary
(even densely cyclic) attack relations are all covered.

The construction also clarifies *why* the naive intersection fails to be the meet:
the intersection $\bigcap\mathcal{S}$ is conflict-free and $F$-closed
(Theorem 3.1), but it need not defend its own members — it may have shrunk below
the point where it can protect itself. The meet $M(\mathcal{S})$ is the largest
*self-defending* subset of that intersection; it is exactly the correction needed
to restore admissibility while preserving the greatest-lower-bound property.

## 8. Future Work

- **Directed joins and the complete lattice.** With arbitrary nonempty meets and
  a bottom element established, the complementary question is whether directed
  families of complete extensions have joins, which would upgrade the
  meet-semilattice to a complete semilattice in Dung's sense. The chain-union
  machinery of Section 5 (already used for existence) is the natural tool.
- **A dichotomy for stable existence.** A framework admits a *stable* extension
  (one that attacks every argument outside it) if and only if some preferred
  extension leaves no argument undecided. Since preferred extensions are exactly
  the maximal complete extensions, this recasts stable existence as a boundary
  condition on the maximal elements of the semilattice.
- **Topological reflection.** A partially ordered set with a least element has a
  contractible order complex (nerve). The grounded extension is such a least
  element, so the nerve of the poset of complete extensions is contractible: the
  entire space of rational positions retracts onto the grounded extension.
- **Semi-stable and ideal semantics.** The same conflict-avoidance mechanism that
  powers the Fundamental Lemma should govern semi-stable and ideal semantics; in
  particular the ideal extension — the greatest admissible set contained in every
  preferred extension — should arise as a fixed point reachable by monotone
  iteration, inheriting its existence from the chain-union lemma.

## 9. Conclusion

We have shown that the complete extensions of an arbitrary argumentation framework
form a meet-semilattice, via an explicit and elementary construction driven by the
single observation that the defense operator stabilizes intersections of complete
extensions. Feeding the family of all complete extensions into the meet recovers
the grounded extension as a unique bottom element, giving a new, iteration-free
proof of its existence and uniqueness. The result assumes nothing about the size
of the framework or the shape of its attack relation, and it reframes several
open questions about argumentation semantics as questions about the structure of
a single, well-understood ordered set.
