# Homotopy Type Theory Foundations: Identity Types, Higher Inductive Types, and the Boundary of Univalence in a Proof-Irrelevant Setting

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Geometry (Homotopy Type Theory)

## Abstract

We develop core fragments of Homotopy Type Theory (HoTT) — identity types, higher
inductive types, and univalence — inside a dependently typed proof system whose
built-in propositional equality is *proof-irrelevant*, i.e. whose identity types are
subsingletons. Three results anchor the development. First, we prove the
**fundamental theorem of identity types**: for a pointed family $B$ over $(A,a)$ with
$b : B(a)$, the canonical transport map $\mathrm{encode}_x : (a = x) \to B(x)$ is a
fiberwise equivalence (in the contractible-fibers sense) **iff** the total space
$\sum_x B(x)$ is contractible. Second, we realize the simplest **higher inductive
type**, the propositional truncation $\|A\|$, as a quotient by the total relation,
prove that it is a mere proposition (the path constructor), establish its recursion
and dependent induction principles, prove its idempotence on propositions, and prove
that it commutes with binary products: $\|A \times B\| \simeq \|A\| \times \|B\|$.
Third, we analyze the **univalence axiom**: we show that, in the proof-irrelevant
setting, bundled univalence data is *inconsistent* (a contradiction is derivable from
the two distinct self-equivalences of $\mathrm{Bool}$), while univalence
*nevertheless holds* when restricted to the universe of propositions, where it is
realized by the canonical map $\mathrm{idToEquiv}$ and underwritten by propositional
extensionality. The overarching theme is that a proof-irrelevant system behaves as the
*0-truncated shadow* of a univalent universe: HoTT theorems either collapse to short
arguments (when they are invariant under 0-truncation) or fail globally while
surviving on propositions. All results are formalized and machine-checked.

## 1. Introduction

Homotopy Type Theory interprets the identity type $a = b$ of Martin-Löf type theory
as a *path space*: a type whose elements are identifications of $a$ with $b$, and
whose own identity types encode higher identifications, ad infinitum. Under this
interpretation, types are $\infty$-groupoids, functions are functors, and logical
constructions acquire geometric meaning. Three ingredients give the theory its
modern shape:

1. the **fundamental theorem of identity types**, which characterizes path spaces via
   contractibility of total spaces;
2. **higher inductive types (HITs)**, which freely generate types from point and path
   constructors; and
3. the **univalence axiom**, which identifies equivalence of types with equality of
   types.

This paper formalizes representative results for each ingredient and, crucially,
records what changes when the ambient system's equality is *proof-irrelevant* — when
each identity type $a = x$ is a `Subsingleton`. We refer to this as the **0-truncated
shadow** of HoTT. Our central empirical finding is a trichotomy: (i) statements
invariant under 0-truncation become *short* (the fundamental theorem); (ii) the
propositional-truncation HIT is fully realizable, with its genuinely higher content
isolated in a single lemma; and (iii) univalence becomes *globally inconsistent* yet
*survives on propositions*.

### 1.1 Conventions

We work with `Sort`-polymorphic definitions so that identity-type domains (which, in
this system, live in the lowest universe `Prop = Sort 0`) are admissible. Dependent
pairs are written $\sum' x, B\,x$ (the `PSigma` total space). The reflexivity path is
$\mathrm{refl}$, and transport of $u : B(a)$ along $p : a = x$ is written $p_*(u)$.

## 2. Identity types and the fundamental theorem

### 2.1 Contractibility, fibers, equivalences

**Definition 1 (Contractibility).** A type $A$ is *contractible*, $\mathrm{IsContr}(A)$,
if it is equipped with a *center* $c : A$ and a *contraction* $\prod_{x:A} (c = x)$.
Contractible types are the $(-2)$-truncated types: "uniquely inhabited."

**Definition 2 (Fiber).** For $f : A \to B$ and $y : B$, the (homotopy) *fiber* is
$$\mathrm{Fiber}(f, y) \;:=\; \sum' x : A,\; f(x) = y.$$

**Definition 3 (Equivalence).** A map $f : A \to B$ is an *equivalence*,
$\mathrm{IsEquiv}(f)$, if every fiber is contractible:
$\prod_{y:B} \mathrm{IsContr}(\mathrm{Fiber}(f,y))$. This is the *contractible-fibers*
formulation, chosen because it is a mere proposition and composes cleanly.

**Lemma 1 (Contractible ⇒ subsingleton).** If $\mathrm{IsContr}(A)$ then
$\prod_{x,y:A} (x = y)$.
*Proof.* Given $x, y$, rewrite both along the contraction at the center: $x = c = y$.
∎ (`IsContr.subsingleton`)

### 2.2 Based path spaces are contractible

**Theorem 1 (Based path spaces are contractible).** For any $a : A$,
$$\mathrm{IsContr}\Big(\textstyle\sum' y : A,\; a = y\Big),$$
with center $(a, \mathrm{refl})$. (`singleton_isContr`)

*Proof.* The center is $(a, \mathrm{refl})$. For the contraction, take an arbitrary
pair $(y, p)$ with $p : a = y$ and perform path induction (case analysis) on $p$;
the only case is $p = \mathrm{refl}$, $y = a$, where the goal $(a, \mathrm{refl}) =
(a, \mathrm{refl})$ holds by reflexivity. ∎

This is the *singleton contractibility* lemma — the cornerstone of identity-type
theory — and its proof is a single application of path induction.

### 2.3 The transport (encoding) map

**Definition 4 (Encode / transport).** For a family $B : A \to \mathrm{Sort}$, a base
point $a : A$, and $b : B(a)$, define
$$\mathrm{encode}_x : (a = x) \to B(x), \qquad \mathrm{encode}_x(p) := p_*(b).$$
(`encode`)

### 2.4 The fundamental theorem

**Theorem 2 (Fundamental Theorem of Identity Types).** Let $B : A \to \mathrm{Sort}$,
$a : A$, $b : B(a)$. Then
$$\Big(\prod_{x:A} \mathrm{IsEquiv}(\mathrm{encode}_x)\Big) \;\Longleftrightarrow\;
\mathrm{IsContr}\Big(\textstyle\sum' x : A,\; B(x)\Big).$$
(`fundamental_identity_forward`, `fundamental_identity_backward`)

*Proof sketch (⇒, forward).* Assume each $\mathrm{encode}_x$ is an equivalence.
Propose $(a, b)$ as the center of $\sum' x, B(x)$. For an arbitrary $(x, u)$, the
fiber of $\mathrm{encode}_x$ over $u$ is contractible, hence inhabited: there is a
path $p : a = x$ with $\mathrm{encode}_x(p) = p_*(b) = u$. Path-induct on $p$ (so
$x = a$, $p = \mathrm{refl}$), and the witness equation collapses $u$ to $b$;
therefore $(x, u) = (a, b)$. Thus $(a,b)$ is a center. Only *inhabitedness* of fibers
(surjectivity) is used. ∎

*Proof sketch (⇐, backward).* Assume $\sum' x, B(x)$ is contractible; by Lemma 1 it is
a subsingleton. Fix $x$ and a target $u : B(x)$; we must show
$\mathrm{Fiber}(\mathrm{encode}_x, u)$ is contractible. Subsingleton-ness gives
$(a, b) = (x, u)$ in the total space; projecting, we obtain $a = x$ and (after
substituting) a heterogeneous identification of $b$ with $u$, yielding an element of
the fiber, namely $(\mathrm{refl}, e)$ for the appropriate $e$. Contractibility of the
fiber is then immediate: the fiber is a `PSigma` of two proof-irrelevant components
($a = x$ and an equality in $B(x)$), so any two of its elements are equal and the
exhibited element is a center. ∎

**Remark (the collapse).** In a proof-irrelevant ambient system the proof requires no
transport-coherence bookkeeping: each direction reduces to *inhabitedness of fibers*
plus *subsingleton-ness*. This is the "set-level shadow" of the fundamental theorem.
The higher-dimensional content of the genuine HoTT statement is precisely what is
discarded by 0-truncation.

**Corollary 1.** For the lifted identity family $x \mapsto \mathrm{PLift}(a = x)$ with
base point $\langle \mathrm{refl}\rangle$, the transport map $\mathrm{encode}_x$ is a
fiberwise equivalence. (`isEquiv_encode_of_isContr`)
*Proof.* Apply Theorem 2 (⇐), whose hypothesis — contractibility of
$\sum' x, \mathrm{PLift}(a=x)$ — follows from Theorem 1 (up to the trivial lift). ∎

## 3. Higher inductive types: propositional truncation

### 3.1 Construction

**Definition 5 (Propositional truncation).** For $A : \mathrm{Sort}\,u$, define the
*propositional truncation*
$$\|A\| \;:=\; \mathrm{Quot}\,(\lambda\, \_\,\_.\ \top),$$
the quotient of $A$ by the *total* relation. Write $\mathrm{mk} : A \to \|A\|$ for the
point constructor (the quotient projection). (`Trunc`, `mk`)

The path constructor — "any two elements are identified" — is not assumed; it is
*derived* from the totality of the relation via the quotient's soundness principle
($\mathrm{Quot.sound}$ applied to the trivial witness $\mathrm{trivial} : \top$).

### 3.2 The path constructor as a theorem

**Theorem 3 ($\|A\|$ is a mere proposition).** For all $x, y : \|A\|$, $x = y$.
(`Trunc.isProp`)

*Proof sketch.* By quotient induction ($\mathrm{Quot.ind}$) reduce $x$ and $y$ to
point-images $\mathrm{mk}(a)$ and $\mathrm{mk}(b)$. Since the defining relation is
total, $\mathrm{Quot.sound}$ on the witness $\mathrm{trivial}$ yields
$\mathrm{mk}(a) = \mathrm{mk}(b)$. ∎

This is the genuinely HIT-flavored fact: it fails for a bare quotient unless the
relation is total, and its proof *is* the path constructor.

### 3.3 Universal property

**Theorem 4 (Recursion and induction).** Let $P$ be a proposition (a `Subsingleton`).
(i) *Recursion:* for any $f : A \to P$ there is a map $\mathrm{lift}\,f : \|A\| \to P$
with $\mathrm{lift}\,f\,(\mathrm{mk}\,a) = f\,a$ (`Trunc.lift`, `Trunc.lift_mk`).
(ii) *Induction:* for any family $P : \|A\| \to \mathrm{Prop}$ with each $P(t)$ a
proposition, to prove $\prod_{t} P(t)$ it suffices to prove $\prod_{a} P(\mathrm{mk}\,a)$
(`Trunc.ind`).

*Proof sketch.* For (i), $f$ respects the total relation automatically because the
target $P$ is a subsingleton: $f\,a = f\,b$ by $\mathrm{Subsingleton.elim}$. Hence
$\mathrm{Quot.lift}$ applies, and the computation rule $\mathrm{lift}\,f\,(\mathrm{mk}\,a)
= f\,a$ holds definitionally. (ii) follows from $\mathrm{Quot.ind}$ together with
subsingleton-ness of each $P(t)$. ∎

The universal property exhibits $\|{-}\|$ as left adjoint to the inclusion of
propositions into types: $\|A\| \to P$ is naturally equivalent to $A \to P$ for $P$ a
proposition.

### 3.4 Idempotence and product preservation

**Theorem 5 (Idempotence on propositions).** If $A$ is a proposition, then
$\mathrm{mk} : A \to \|A\|$ is an equivalence; equivalently $\|A\| \simeq A$.
(`Trunc.equivOfIsProp`)
*Proof sketch.* Define the inverse by $\mathrm{lift}(\mathrm{id}_A) : \|A\| \to A$
(legitimate because $A$ is itself a proposition). The round-trips hold by
$\mathrm{lift\_mk}$ in one direction and by $\mathrm{isProp}$ in the other. ∎

**Theorem 6 (Truncation preserves binary products).**
$$\|A \times B\| \;\simeq\; \|A\| \times \|B\|.$$
(`Trunc.prod_equiv`)
*Proof sketch.* Forward: $\mathrm{lift}$ the map $(a,b) \mapsto (\mathrm{mk}\,a,
\mathrm{mk}\,b)$ — valid since $\|A\|\times\|B\|$ is a proposition (a product of
propositions). Backward: given $(s,t) : \|A\|\times\|B\|$, eliminate $s$ and then $t$
through the truncation (nested $\mathrm{Trunc.lift}$/$\mathrm{ind}$), recovering points
$a, b$ and returning $\mathrm{mk}(a,b)$; this is well defined because the target
$\|A\times B\|$ is a proposition. The two composites are equal by $\mathrm{isProp}$ on
each side. ∎

The backward map is the first construction requiring the recursor in an essential,
*iterated* way: two independently truncated witnesses must be recombined into a single
truncated pair.

## 4. Univalence: global failure and propositional survival

### 4.1 The canonical map and bundled data

**Definition 6 (idToEquiv and UnivalenceData).** For types $A, B$ there is a canonical
map
$$\mathrm{idToEquiv} : (A = B) \to (A \simeq B),$$
sending $\mathrm{refl}$ to the identity equivalence (transport along a type equality).
*Univalence data* ($\mathrm{UnivalenceData}$) bundles $\mathrm{idToEquiv}$ together
with the data witnessing that it is an equivalence (an inverse with round-trip laws).
(`idToEquiv`, `UnivalenceData`)

**Definition 7 (The Bool obstruction).** Let $\mathrm{negEquiv} : \mathrm{Bool} \simeq
\mathrm{Bool}$ be the equivalence given by Boolean negation $\mathrm{not}$
(self-inverse). It is distinct from the identity equivalence:
$\mathrm{negEquiv} \neq \mathrm{Equiv.refl}$, since they disagree on $\mathrm{true}$.
(`negEquiv`)

### 4.2 Global inconsistency

**Theorem 7 (Univalence is inconsistent in the proof-irrelevant setting).** From
$\mathrm{UnivalenceData}$ one derives $\bot$. (`UnivalenceData.not_inhabited`)

*Proof sketch.* Suppose $\mathrm{idToEquiv}$ admits an inverse $g$. Apply $g$ to the two
distinct self-equivalences $\mathrm{Equiv.refl}$ and $\mathrm{negEquiv}$ of
$\mathrm{Bool}$, obtaining two identifications $\mathrm{Bool} = \mathrm{Bool}$. Because
ambient equality is proof-irrelevant, those two identifications are *equal*; applying
$\mathrm{idToEquiv}$ and using the round-trip law $g$ is a section of, we conclude
$\mathrm{Equiv.refl} = \mathrm{negEquiv}$, contradicting Definition 7. ∎

**Interpretation.** The contradiction is powered by a *non-subsingleton equivalence
type*: $\mathrm{Bool} \simeq \mathrm{Bool}$ has at least two elements, while
$\mathrm{Bool} = \mathrm{Bool}$ has exactly one. Univalence demands a proof-relevant
identity type; $\mathrm{Bool}$, with $|\mathrm{Bool} \simeq \mathrm{Bool}| = 2$, is the
minimal witness that proof-irrelevance forbids it.

### 4.3 Survival on propositions

**Theorem 8 (Univalence on propositions).** Restricted to the universe of
propositions, identity and equivalence coincide: for propositions $P, Q$,
$$(P = Q) \;\simeq\; (P \simeq Q),$$
and this equivalence is realized by $\mathrm{idToEquiv}$. (`propUnivalence`,
`propUnivalence_idToEquiv`)

*Proof sketch.* For propositions, an equivalence $P \simeq Q$ is the same data as a
logical equivalence $P \leftrightarrow Q$ (both directions, with round-trips automatic
by subsingleton-ness). Propositional extensionality ($\mathrm{propext}$) turns
$P \leftrightarrow Q$ into $P = Q$, providing the inverse to $\mathrm{idToEquiv}$. The
round-trip laws hold because $P = Q$ is a subsingleton and equivalences of
propositions are determined by their underlying implications. ∎

**Interpretation.** The obstruction of §4.2 vanishes precisely because a proposition
has no nontrivial self-equivalence ($|P \simeq P| \le 1$). Thus the propositional
fragment is exactly the largest sub-universe on which $\mathrm{idToEquiv}$ is an
equivalence in a proof-irrelevant foundation.

## 5. Algorithms

The constructions above induce decision/transformation procedures on *finite* models,
where contractibility, equivalence, and truncation become concrete computations.

**Algorithm A (Fiberwise-equivalence ⇔ contractible-total-space checker).** Given a
finite base type $A$, a finite family $B(\cdot)$, a base point $a$, and $b : B(a)$,
the algorithm (i) builds each fiber of $\mathrm{encode}_x$ and tests contractibility
(exactly one element), and (ii) tests contractibility of $\sum_x B(x)$, then verifies
the two verdicts agree — a finite instance of Theorem 2. Complexity
$O\big(\sum_x |a = x|\cdot|B(x)|\big)$.

**Algorithm B (Propositional-truncation product oracle).** Given finite $A, B$,
compute $\|A\times B\|$ and $\|A\|\times\|B\|$ as Booleans (inhabited?) and verify the
equivalence of Theorem 6: $A\times B$ is inhabited iff both $A$ and $B$ are. Complexity
$O(1)$ after inhabitation tests.

**Algorithm C (Univalence-obstruction detector).** Given a finite type $T$, enumerate
$\mathrm{Aut}(T) = (T \simeq T)$ and compare $|\mathrm{Aut}(T)|$ with the number of
self-identifications available in a proof-irrelevant identity type (always $1$). The
obstruction of Theorem 7 is present iff $|\mathrm{Aut}(T)| > 1$; the minimal such $T$
is $\mathrm{Bool}$ with $|\mathrm{Aut}(\mathrm{Bool})| = 2$. Complexity $O(|T|!\cdot|T|)$
for the naive automorphism enumeration.

## 6. Applications

- **Path-space computations.** Theorem 2 is the standard device for characterizing the
  identity type of an inductive or higher-inductive type by exhibiting a contractible
  total space — e.g. encode–decode arguments computing loop spaces.
- **Hiding witnesses (the existential modality).** Theorem 3–6 make $\|{-}\|$ a usable
  propositional-existence modality: $\|A\|$ records *that* $A$ is inhabited while
  forgetting *which* element, and Theorem 6 lets such existence statements be combined
  componentwise.
- **Foundational diagnostics.** Theorems 7–8 quantify exactly where a proof-irrelevant
  foundation can and cannot host univalence, guiding the design of reflective
  proposition-subuniverses.

## 7. Discussion: the 0-truncated-shadow principle

The three developments fit a single template. A proof-irrelevant foundation is the
*0-truncated shadow* of a univalent universe: every identity type is a subsingleton.
Consequently:

- A HoTT theorem that is *invariant under 0-truncation* (its content survives flattening
  of path spaces) becomes provable by a short argument — exemplified by the fundamental
  theorem, whose two directions reduce to inhabitedness and subsingleton-ness.
- A HIT whose universal property targets propositions is *fully realizable* via quotient
  by the appropriate relation; its higher content concentrates in a single lemma
  (here, $\mathrm{isProp}$).
- A principle that *requires proof-relevance* (univalence) fails globally but persists
  exactly on the flat — propositional — part of the universe.

This delineates a precise frontier between what proof-irrelevant systems get "for free"
and what genuinely demands higher-dimensional foundations.

## 8. Future work

See the "Future Directions" appendix for three falsifiable conjectures:
(1) truncation level controls which HoTT theorems collapse, via finer quotient
encodings of $n$-truncation; (2) the Bool obstruction is the *unique minimal* witness
of non-univalence, formalizable through $|\mathrm{Aut}(T)|$; and (3) propositional
univalence extends to a reflective subuniverse of $h$-propositions that is the largest
sub-universe satisfying univalence.

## Appendix: index of formalized results

| Name | Statement |
|---|---|
| `IsContr`, `Fiber`, `IsEquiv` | contractibility, homotopy fiber, contractible-fibers equivalence |
| `IsContr.subsingleton` | contractible ⇒ subsingleton |
| `singleton_isContr` | based path space $\sum' y, a=y$ is contractible |
| `encode` | transport map $(a=x) \to B(x)$ |
| `fundamental_identity_forward` | fiberwise equiv ⇒ contractible total space |
| `fundamental_identity_backward` | contractible total space ⇒ fiberwise equiv |
| `isEquiv_encode_of_isContr` | corollary for the lifted identity family |
| `Trunc`, `mk` | propositional truncation via `Quot` of total relation |
| `Trunc.isProp` | $\|A\|$ is a mere proposition |
| `Trunc.lift`, `Trunc.lift_mk`, `Trunc.ind` | recursor, computation rule, dependent eliminator |
| `Trunc.equivOfIsProp` | idempotence on propositions |
| `Trunc.prod_equiv` | $\|A\times B\| \simeq \|A\|\times\|B\|$ |
| `idToEquiv`, `UnivalenceData` | canonical $A=B \to A\simeq B$ and its bundling |
| `negEquiv` | the nontrivial self-equivalence of `Bool` |
| `UnivalenceData.not_inhabited` | univalence data ⇒ ⊥ (proof-irrelevant setting) |
| `propUnivalence`, `propUnivalence_idToEquiv` | univalence holds on propositions |
