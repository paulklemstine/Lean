# The Grounded Extension is the Least Complete Extension

*A self-contained development of Dung's grounded semantics via transfinite
approximation of the defense operator*

## Abstract

Abstract argumentation, introduced by Dung, models a debate as a directed
graph whose vertices are *arguments* and whose edges encode an *attack*
relation. From this minimal structure one extracts several notions of a
"reasonable position," of which the *complete extensions* — conflict-free
sets that accept exactly the arguments they can defend — are central. Among
all complete extensions there is a distinguished least one, the *grounded
extension*, defined as the least fixed point of the characteristic (defense)
operator. While it is standard that the grounded extension lies below every
complete extension, the fact that it is *itself* a complete extension — in
particular that it is conflict-free — is subtle: conflict-freeness is *not*
a property of arbitrary fixed points of the defense operator, only of the
least one. We give a complete, self-contained proof of Dung's
characterization: the grounded extension is a complete extension and is
contained in every complete extension, hence is *the least complete
extension*. The argument proceeds by transfinite induction along the
ordinal approximation of the least fixed point, resting on two lemmas: the
defense operator preserves conflict-freeness, and a directed (chain) union
of conflict-free sets is conflict-free. As a corollary we obtain a
fixed-point characterization: a set is complete if and only if it is a
conflict-free fixed point of the defense operator.

**Keywords:** abstract argumentation, grounded extension, complete
extension, defense operator, least fixed point, conflict-freeness,
transfinite induction, Knaster–Tarski.

## 1. Introduction

Dung's theory of abstract argumentation provides a spare and powerful
language for nonmonotonic and defeasible reasoning. Its foundational move
is to discard the internal content of arguments and retain only a binary
*attack* relation. A remarkable amount of structure survives this
abstraction: several *extension-based semantics* — conflict-free,
admissible, complete, grounded, preferred, and stable — capture distinct
standards for which arguments a rational agent should accept.

This paper focuses on the **grounded extension**, the semantics of the
maximally cautious reasoner. It is defined operationally as the least fixed
point of the *characteristic operator* $F$, which maps a set $S$ to the set
of arguments $S$ can defend. Two facts about the grounded extension are
frequently quoted together:

1. it is contained in every complete extension, and
2. it is itself the least complete extension.

The first is an immediate consequence of the Knaster–Tarski fixed-point
principle. The second is more delicate, because it requires showing that
the grounded extension is a *legitimate* extension in the first place: that
it is **conflict-free**, and hence complete. This is precisely the step that
cannot be taken for granted. Conflict-freeness fails for general fixed
points of $F$ (the set of all arguments is a fixed point whenever nobody
attacks anyone, and larger fixed points can contain genuine conflicts).
Conflict-freeness is a property of the *least* fixed point specifically.

Because $F$ need not be $\omega$-continuous, the least fixed point is in
general reached only by *transfinite* iteration. We therefore prove
conflict-freeness of the grounded extension by transfinite induction along
the ordinal approximation of the least fixed point. This paper is
self-contained: we redevelop the necessary Dung semantics from scratch and
give complete proof sketches of every result, culminating in Dung's
characterization of grounded semantics and a fixed-point criterion for
completeness.

## 2. Preliminaries: argumentation frameworks

Throughout, fix a set $A$ of **arguments** and a binary **attack relation**
$R$ on $A$. We write $R\,a\,b$ (read "$a$ attacks $b$") for the proposition
that argument $a$ attacks argument $b$. The pair $(A, R)$ is an
**argumentation framework**. We make no finiteness assumption: $A$ may be
infinite, which is exactly what forces the transfinite machinery below.
Subsets $S \subseteq A$ are candidate *positions*, and the power set of $A$
is ordered by inclusion, forming a complete lattice.

### 2.1 Conflict-freeness

**Definition 2.1 (Conflict-free).** A set $S \subseteq A$ is
*conflict-free* if no argument in $S$ attacks an argument in $S$:
$$\mathrm{CF}(S) \iff \forall a \in S,\ \forall b \in S,\ \neg\, R\,a\,b.$$

Conflict-freeness expresses internal consistency: a position that contains
both an attacker and its target is self-defeating.

### 2.2 Defense and admissibility

**Definition 2.2 (Defense).** A set $S$ *defends* an argument $a$ if every
attacker of $a$ is counterattacked by some member of $S$:
$$\mathrm{Def}(S, a) \iff \forall b,\ R\,b\,a \Rightarrow \exists c \in S,\ R\,c\,b.$$

**Definition 2.3 (Admissible).** A set $S$ is *admissible* if it is
conflict-free and defends each of its members:
$$\mathrm{Adm}(S) \iff \mathrm{CF}(S) \ \wedge\ \forall a \in S,\ \mathrm{Def}(S, a).$$

Admissibility captures a position that is both coherent and self-defending:
it holds no internal contradiction and can rebut every attack on anything
it endorses.

### 2.3 The characteristic (defense) operator

**Definition 2.4 (Characteristic operator).** The *characteristic
operator* (or *defense operator*) $F : \mathcal{P}(A) \to \mathcal{P}(A)$
of the framework $(A,R)$ is
$$F(S) = \{\, a \in A : \mathrm{Def}(S, a) \,\}.$$

Thus $F(S)$ is the set of all arguments that $S$ is able to defend. The
membership rule $a \in F(S) \iff \mathrm{Def}(S,a)$ is used freely below.

### 2.4 Complete extensions

**Definition 2.5 (Complete extension).** A set $S$ is a *complete
extension* if it is admissible and closed under defense:
$$\mathrm{Comp}(S) \iff \mathrm{Adm}(S) \ \wedge\ F(S) \subseteq S.$$

A complete extension accepts precisely the arguments it can justify: it
adds nothing it cannot defend (admissibility ensures $S$ defends its
members, i.e. $S \subseteq F(S)$ on those members) and omits nothing it can
defend ($F(S) \subseteq S$).

## 3. Monotonicity of the defense operator

**Lemma 3.1 (Monotonicity of defense).** If $S \subseteq T$ and $S$
defends $a$, then $T$ defends $a$.

*Proof.* Let $b$ attack $a$. Since $S$ defends $a$, there is $c \in S$ with
$R\,c\,b$. As $S \subseteq T$, we have $c \in T$, so $T$ defends $a$. $\square$

**Lemma 3.2 (Monotonicity of $F$).** If $S \subseteq T$ then
$F(S) \subseteq F(T)$.

*Proof.* Immediate from Lemma 3.1: any $a \in F(S)$ is defended by $S$,
hence by $T$, so $a \in F(T)$. $\square$

Consequently $F$ is a **monotone self-map of the complete lattice**
$(\mathcal{P}(A), \subseteq)$. By the Knaster–Tarski theorem, $F$ has a
least fixed point.

**Definition 3.3 (Grounded extension).** The *grounded extension* of
$(A,R)$ is the least fixed point of $F$:
$$G = \mathrm{lfp}(F).$$

## 4. The defense operator preserves conflict-freeness

The following lemma is the technical heart of the development. It links the
two logically independent notions — consistency (conflict-freeness) and
justification (defense) — showing they cooperate.

**Lemma 4.1 (Preservation of conflict-freeness).** If $S$ is conflict-free,
then $F(S)$ is conflict-free.

*Proof.* Let $a, b \in F(S)$ and suppose, for contradiction, that
$R\,a\,b$. Since $b \in F(S)$, $S$ defends $b$; applied to the attacker $a$
this yields $c \in S$ with $R\,c\,a$. Since $a \in F(S)$, $S$ defends $a$;
applied to the attacker $c$ this yields $d \in S$ with $R\,d\,c$. Now
$c, d \in S$ and $R\,d\,c$, contradicting the conflict-freeness of $S$.
Hence no such attack exists and $F(S)$ is conflict-free. $\square$

The two-step "bounce" — an attack inside $F(S)$ forces a counterattack from
$S$, which forces a further counterattack from $S$, landing a conflict
*inside* $S$ — is what makes the lemma work, and it is the reason
conflict-freeness propagates through iterated defense.

## 5. Conflict-freeness is preserved by directed unions

To pass through limit stages of the transfinite construction we need
conflict-freeness to survive unions of suitably compatible families.

**Lemma 5.1 (Directed unions preserve conflict-freeness).** Let
$\mathcal{S}$ be a family of subsets of $A$ that is *directed* under
inclusion, meaning for all $S, T \in \mathcal{S}$ there is $U \in
\mathcal{S}$ with $S \subseteq U$ and $T \subseteq U$. If every member of
$\mathcal{S}$ is conflict-free, then $\bigcup \mathcal{S}$ is
conflict-free.

*Proof.* Let $a, b \in \bigcup\mathcal{S}$ with $R\,a\,b$. Choose $S \in
\mathcal{S}$ with $a \in S$ and $T \in \mathcal{S}$ with $b \in T$. By
directedness there is $U \in \mathcal{S}$ with $S \subseteq U$ and $T
\subseteq U$, so $a, b \in U$. Since $U$ is conflict-free, $\neg R\,a\,b$, a
contradiction. Hence $\bigcup\mathcal{S}$ is conflict-free. $\square$

Every *chain* of sets is directed, so in particular a union of a growing
chain of conflict-free sets is conflict-free. This is the exact form used
at limit ordinals below.

## 6. Transfinite approximation and conflict-freeness of the grounded extension

Since $F$ is monotone on a complete lattice, its least fixed point is the
limit of the **ordinal approximation** starting from the bottom element
$\bot = \varnothing$. Write $F^{\uparrow}_\alpha$ for the approximant at
ordinal stage $\alpha$; informally,
$$F^{\uparrow}_0 = \varnothing, \qquad F^{\uparrow}_{\alpha} = \bigcup_{\beta < \alpha} F\!\left(F^{\uparrow}_\beta\right) \ \cup\ \varnothing,$$
so that successor stages apply $F$ and limit stages take unions. The
approximation is **monotone**: $\beta \le \alpha$ implies $F^{\uparrow}_\beta
\subseteq F^{\uparrow}_\alpha$. There is an ordinal at which it stabilizes,
and its stable value equals $\mathrm{lfp}(F) = G$.

**Lemma 6.1 (Approximants are conflict-free).** For every ordinal
$\alpha$, the approximant $F^{\uparrow}_\alpha$ is conflict-free.

*Proof.* By transfinite induction on $\alpha$. Assume $F^{\uparrow}_\beta$
is conflict-free for all $\beta < \alpha$. Unfolding the definition,
$F^{\uparrow}_\alpha$ is the union of the family
$$\mathcal{S} = \bigl\{\, F\!\left(F^{\uparrow}_\beta\right) : \beta < \alpha \,\bigr\} \cup \{\varnothing\}.$$
Each $F(F^{\uparrow}_\beta)$ is conflict-free: by the induction hypothesis
$F^{\uparrow}_\beta$ is conflict-free, and Lemma 4.1 (preservation) then
gives conflict-freeness of its image under $F$. The empty set is trivially
conflict-free. Moreover $\mathcal{S}$ is directed: for $\beta_1, \beta_2 <
\alpha$, monotonicity of the approximation and of $F$ (Lemma 3.2) makes
$F(F^{\uparrow}_{\beta_1})$ and $F(F^{\uparrow}_{\beta_2})$ both contained
in $F(F^{\uparrow}_{\max(\beta_1,\beta_2)})$, which lies in $\mathcal{S}$.
By Lemma 5.1 the union $F^{\uparrow}_\alpha$ is conflict-free, completing
the induction. $\square$

**Theorem 6.2 (Grounded extension is conflict-free).** The grounded
extension $G$ is conflict-free.

*Proof.* $G$ equals the stable value of the ordinal approximation, i.e.
$G = F^{\uparrow}_\alpha$ for a sufficiently large $\alpha$. Apply Lemma
6.1. $\square$

## 7. The grounded extension is the least complete extension

**Lemma 7.1 (Fixed-point property).** $F(G) = G$.

*Proof.* $G = \mathrm{lfp}(F)$, and a least fixed point is a fixed point:
the Knaster–Tarski construction gives $F(\mathrm{lfp}(F)) =
\mathrm{lfp}(F)$. $\square$

**Theorem 7.2 (Admissibility of $G$).** $G$ is admissible.

*Proof.* Conflict-freeness is Theorem 6.2. For defense: let $a \in G$. By
Lemma 7.1, $G = F(G)$, so $a \in F(G)$, which by definition means $G$
defends $a$. Hence $G$ defends every one of its members and is admissible.
$\square$

**Theorem 7.3 (Completeness of $G$).** $G$ is a complete extension.

*Proof.* By Theorem 7.2, $G$ is admissible. Closure under defense holds
because $F(G) = G \subseteq G$ (Lemma 7.1). Hence $\mathrm{Comp}(G)$.
$\square$

**Lemma 7.4 (Prefixed points bound $G$ from above).** If $F(S) \subseteq
S$ then $G \subseteq S$.

*Proof.* This is the defining universal property of the least fixed point:
$\mathrm{lfp}(F)$ is below every *prefixed point* $S$ (a set with $F(S)
\subseteq S$). $\square$

**Theorem 7.5 (Grounded is below every complete extension).** If $S$ is a
complete extension, then $G \subseteq S$.

*Proof.* A complete extension satisfies $F(S) \subseteq S$ by definition.
Apply Lemma 7.4. $\square$

**Theorem 7.6 (Dung's characterization: least complete extension).** The
grounded extension $G$ is a complete extension, and $G \subseteq S$ for
every complete extension $S$. Equivalently, $G$ is the least element of the
set of complete extensions ordered by inclusion.

*Proof.* Completeness is Theorem 7.3; minimality is Theorem 7.5. $\square$

This is the central result: the maximally skeptical position — accept only
what is forced — is a genuine, coherent, self-justifying stance, and it is
the common floor beneath every coherent stance whatsoever.

## 8. A fixed-point criterion for completeness

The development yields a clean characterization of *all* complete
extensions, not merely the grounded one.

**Theorem 8.1 (Complete = conflict-free fixed point).** A set $S$ is a
complete extension if and only if $S$ is conflict-free and $F(S) = S$.

*Proof.* ($\Rightarrow$) Suppose $S$ is complete. Then $S$ is conflict-free
by admissibility. For the fixed-point equation, closure under defense gives
$F(S) \subseteq S$; conversely, admissibility says $S$ defends each of its
members, i.e. $S \subseteq F(S)$. By antisymmetry $F(S) = S$.

($\Leftarrow$) Suppose $S$ is conflict-free with $F(S) = S$. Then $S$
defends each member (for $a \in S = F(S)$ means $S$ defends $a$), so $S$ is
admissible; and $F(S) = S \subseteq S$ gives closure under defense. Hence
$S$ is complete. $\square$

Theorem 8.1 recasts completeness in purely lattice-theoretic terms:
complete extensions are exactly the conflict-free fixed points of $F$, and
the grounded extension is the least among them. It also explains, in one
line, why conflict-freeness cannot be dropped: fixed points of $F$ are
plentiful, but only the conflict-free ones qualify as extensions, and the
least fixed point is guaranteed conflict-free precisely by the transfinite
argument of Sections 4–6.

## 9. Worked examples

Three small frameworks illustrate the full range of behavior and make the
theorems concrete.

**Reinstatement chain $a \to b \to c$.** Here $a$ is unattacked, $a$ attacks
$b$, and $b$ attacks $c$. Iterating $F$ from the empty set: $F(\varnothing)$
accepts every argument with no attackers, so $F(\varnothing) = \{a\}$ (both
$b$ and $c$ have attackers not yet counterattacked). Next, $F(\{a\})$ still
contains $a$, and now $c$ qualifies because its only attacker $b$ is
counterattacked by $a \in \{a\}$; but $b$ does not qualify, since its
attacker $a$ is not counterattacked by anything. Thus $F(\{a\}) = \{a, c\}$,
and $F(\{a,c\}) = \{a,c\}$ is a fixed point. The grounded extension is
$G = \{a, c\}$: the unattacked argument $a$ is accepted, and it *reinstates*
$c$ by defeating $c$'s attacker. This is the paradigmatic pattern of
skeptical acceptance. It is also the unique complete extension here, so
grounded, preferred, and stable semantics coincide.

**Two-cycle $a \leftrightarrow b$.** Here $a$ and $b$ attack each other.
Starting from $\varnothing$: no argument is unattacked, so
$F(\varnothing) = \varnothing$, already a fixed point. The grounded extension
is $G = \varnothing$ — the skeptic commits to nothing, because neither
argument can be defended without first accepting the other. Yet there are
three complete extensions in total: $\varnothing$, $\{a\}$, and $\{b\}$; the
latter two are the (mutually exclusive) bolder positions. The grounded
extension $\varnothing$ is contained in all three, as Theorem 7.6 demands.
This framework also exhibits the phenomenon that makes the conflict-freeness
proof delicate: the *full* set $\{a, b\}$ is a fixed point of $F$ (each
argument's attacker is counterattacked by the other), yet it is *not*
conflict-free. Conflict-freeness is enjoyed by the least fixed point, not by
fixed points in general.

**Three-cycle $a \to b \to c \to a$.** No argument is unattacked and no
nonempty conflict-free set can defend its members, so $F(\varnothing) =
\varnothing$ and $G = \varnothing$ is the unique complete extension. The
framework has no nonempty admissible set at all: the odd cycle is
"paradoxical," and the grounded semantics correctly withholds judgment on
every argument.

## 10. Algorithms

For **finite** frameworks the transfinite machinery collapses to ordinary
iteration, because on a finite lattice $F$ is $\omega$-continuous and the
least fixed point is reached in finitely many steps.

**Grounded extension by iteration.** Start from $S_0 = \varnothing$; set
$S_{n+1} = F(S_n)$; stop when $S_{n+1} = S_n$. The chain is increasing and,
in a framework with $n$ arguments, stabilizes within $n$ steps. The stable
value is the grounded extension. Each application of $F$ scans, for every
argument $a$, all attackers of $a$ and, for each, all members of the current
set that counterattack — a polynomial-time computation. The grounded
extension is therefore computable in polynomial time, a notable contrast
with preferred and stable semantics, whose decision problems are
intractable in general.

**Completeness check.** To verify that a candidate $S$ is a complete
extension, test (i) conflict-freeness by scanning all ordered pairs in $S$
for an attack, and (ii) the fixed-point equation $F(S) = S$ by computing
$F(S)$ and comparing. By Theorem 8.1 these two tests are jointly necessary
and sufficient.

## 11. Applications

Grounded semantics is the default choice wherever a *single, canonical,
skeptical* verdict is required:

- **Defeasible and legal reasoning.** Rules with exceptions, precedents
  that override one another, and evidence that undercuts other evidence map
  naturally onto attack graphs. The grounded extension yields the set of
  conclusions safe under maximal caution.
- **Multi-agent negotiation and dialogue.** When agents exchange arguments
  and counterarguments, the grounded extension is the uncontroversial
  common ground — accepted regardless of which broader (preferred or stable)
  position any single agent favors.
- **Explainable AI.** Because the grounded extension is unique and
  computed by a transparent monotone process (accept the unattacked, then
  what they defend, and so on), the justification status of each argument
  comes with an intelligible, step-indexed explanation.
- **Inconsistency-tolerant querying.** Over knowledge bases that harbor
  contradictions, argumentation semantics extract coherent answers; grounded
  semantics gives the most conservative, contradiction-free core.

## 12. Discussion

The mathematical lesson of this development is the interplay between two a
priori unrelated properties — *consistency* (conflict-freeness) and
*justification* (defense) — mediated by a single monotone operator. Neither
property implies the other for arbitrary sets, and conflict-freeness is not
inherited by arbitrary fixed points of the defense operator. What rescues
the grounded extension is *leastness*: the least fixed point is built from
below, and conflict-freeness, unlike many properties, is preserved both by
the defense step (Lemma 4.1) and by the chain-union step (Lemma 5.1). These
two closure properties, threaded through a transfinite induction, are
exactly what a least-fixed-point argument needs.

The necessity of transfinite iteration is worth emphasizing. For finite
frameworks a handful of applications of $F$ suffice, and even for many
infinite frameworks $\omega$ steps are enough. But $F$ is not
$\omega$-continuous in general, so a fully general proof cannot stop at
$\omega$; it must climb through all the ordinals until stabilization. The
proof above is faithful to this generality, working directly with the
ordinal approximation rather than assuming continuity.

## 13. Future directions

- **Grounded as an intersection.** Combine the least-complete-extension
  characterization with completeness of preferred extensions to determine
  when the grounded extension equals the intersection of all complete
  (equivalently, all preferred) extensions, and to characterize the
  frameworks in which this equality holds.
- **Uniqueness via well-foundedness.** For frameworks whose attack
  relation is well-founded, prove that the grounded extension is the unique
  complete extension, so that grounded, preferred, and stable semantics
  coincide.
- **Labelling correspondence.** Develop the three-valued *labelling*
  presentation of the semantics (in/out/undecided) and prove its
  equivalence with the extension-based grounded semantics developed here.

## 14. Conclusion

We have given a self-contained proof that, in every argumentation
framework, the grounded extension is the least complete extension. The
argument isolates two closure properties of conflict-freeness — under the
defense operator and under directed unions — and runs them through a
transfinite induction along the ordinal approximation of the least fixed
point. A corollary characterizes complete extensions as exactly the
conflict-free fixed points of the defense operator, placing the grounded
extension as the least element of that class. The result captures a
sharp intuition: the most skeptical coherent position always exists, is
unique, and underlies every coherent position one might defend.
