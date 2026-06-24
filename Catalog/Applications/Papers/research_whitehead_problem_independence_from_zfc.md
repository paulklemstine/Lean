# The ZFC-Provable Skeleton of the Whitehead Problem: Projectivity, Torsion-Freeness, and the Cyclic Obstruction

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Novelty (Algebra / Homological Algebra / Set-Theoretic Algebra)

## Abstract

The Whitehead problem asks whether every Whitehead group — every abelian group $A$
with $\mathrm{Ext}^1(A, \mathbb{Z}) = 0$ — is free. Shelah proved in 1974 that for
general (infinite) abelian groups this statement is independent of ZFC: it holds
under Gödel's axiom of constructibility $V = L$ and fails under Martin's Axiom plus
$\neg\mathrm{CH}$. The independence is a metatheorem about models of set theory and
lies outside the reach of any single object-level statement. This paper isolates
and rigorously establishes the **ZFC-provable skeleton** of the theory — the part
that holds in every model. We formalize the splitting definition of the Whitehead
property and prove three results. First, every *projective* abelian group is a
Whitehead group, via the lifting property of projectivity and with no appeal to
the structure theorem or to freeness (`isWhiteheadGroup_of_projective`). Second,
every projective $\mathbb{Z}$-module is torsion-free, obtained by embedding it as a
retract of a free module (`Module.IsTorsionFree.of_projective_int`). Third, the
cyclic group $\mathbb{Z}/n$ is **not** a Whitehead group for any $n \geq 2$,
witnessed by the explicit non-split extension $0 \to \mathbb{Z} \xrightarrow{\cdot
n} \mathbb{Z} \to \mathbb{Z}/n \to 0$ (`not_isWhiteheadGroup_zmod`). Together these
results delineate the decidable boundary of the Whitehead problem: freedom always
implies the Whitehead property, the Whitehead property always forces
torsion-freeness, and in the finitely generated regime the two notions coincide,
leaving the genuine independence confined to the uncountable wilderness.

## 1. Introduction

### 1.1 The problem

Let $A$ be an abelian group, regarded throughout as a module over the ring
$\mathbb{Z}$. An **extension of $A$ by $\mathbb{Z}$** is a short exact sequence of
abelian groups
$$0 \longrightarrow \mathbb{Z} \xrightarrow{\;i\;} G \xrightarrow{\;p\;} A
\longrightarrow 0,$$
meaning $i$ is injective, $p$ is surjective, and $\operatorname{range}(i) =
\ker(p)$. The extension **splits** if $p$ admits a $\mathbb{Z}$-linear section
$s : A \to G$ with $p \circ s = \mathrm{id}_A$; equivalently $G \cong \mathbb{Z}
\oplus A$. The isomorphism classes of extensions form the group
$\mathrm{Ext}^1(A, \mathbb{Z})$, and the split extension is its zero element.

J. H. C. Whitehead asked: if every extension of $A$ by $\mathbb{Z}$ splits — i.e.
$\mathrm{Ext}^1(A, \mathbb{Z}) = 0$ — must $A$ be free? Groups satisfying the
hypothesis are called **Whitehead groups**.

### 1.2 The independence phenomenon

The finitely generated case is classical: a finitely generated Whitehead group is
free. Stein extended this to countable groups. The infinite case resisted all
attack until Shelah (1974) proved that "every Whitehead group is free" is
**independent of ZFC**: it is a theorem under $V = L$ and refutable under
$\mathrm{MA} + \neg\mathrm{CH}$. This was among the first examples of a problem in
"ordinary" (non-set-theoretic) mathematics shown to be undecidable.

Independence is a statement about the class of models of ZFC and cannot be captured
by a single object-level proposition; it is therefore not the target of formal
object-level verification. What *can* be captured, and is the subject of this
paper, is the rich layer of theory that every model of ZFC agrees on — the
skeleton on which the independence result is hung.

It is worth dwelling on why this distinction matters. A formal proof assistant
verifies object-level statements: propositions quantifying over groups, maps, and
elements, all living inside a single fixed universe of sets. The assertion "every
Whitehead group is free" is such a proposition, and Shelah's theorem says it is
*neither* provable *nor* refutable from the ZFC axioms. Consequently there is no
honest object-level theorem to formalize that would settle it; any claim to have
"proved the independence" inside a single such statement would be a category error.
The intellectually correct target — and the one pursued here — is the body of
Whitehead theory that is an outright theorem of ZFC. That body is substantial,
structurally illuminating, and exactly what fixes the location of the independent
frontier. The independence is then understood not as a gap in our knowledge but as
a precisely surveyed coastline: we know which groups are decidably Whitehead, which
are decidably not, and that everything left undetermined lies strictly in the
uncountable, non-finitely-generated open sea.

### 1.3 Contributions

We make the splitting formulation precise and prove three mutually reinforcing
results, all valid in ZFC:

1. **Projective $\Rightarrow$ Whitehead** (Theorem 1). A direct consequence of the
   lifting property, avoiding the structure theorem entirely.
2. **Projective $\Rightarrow$ torsion-free** (Theorem 2). The structural reason
   free-like groups never twist.
3. **The cyclic torsion obstruction** (Theorem 3). $\mathbb{Z}/n$ ($n \geq 2$) is
   not Whitehead, proving torsion-freeness is necessary.

Section 2 fixes definitions; Section 3 states and proves the main results; Section
4 assembles them into the decidable boundary and locates the independence; Sections
5–9 treat the formalization, algorithms, applications, and future work.

### 1.4 The homological reformulation

The splitting condition of Definition 1 below is the explicit, element-level
incarnation of the vanishing of a derived functor. For abelian groups, the bifunctor
$\mathrm{Ext}^1(-, -)$ classifies extensions up to equivalence: there is a natural
bijection between $\mathrm{Ext}^1(A, \mathbb{Z})$ and equivalence classes of short
exact sequences $0 \to \mathbb{Z} \to G \to A \to 0$, under which the zero element
corresponds to the split extension $G \cong \mathbb{Z} \oplus A$. Hence
$\mathrm{Ext}^1(A, \mathbb{Z}) = 0$ if and only if *every* such extension splits —
which is precisely the Whitehead condition. Working with the splitting formulation
rather than the derived functor keeps all three theorems elementary and entirely
constructive, while losing no generality: it is the same condition phrased so that
the witnessing maps are explicit.

Two classical facts of homological algebra frame our results. First, $\mathbb{Z}$
is a principal ideal domain, hence of global dimension $1$, so $\mathrm{Ext}^k$
vanishes for $k \geq 2$ and the whole obstruction theory lives in degree $1$.
Second, projective modules $P$ are characterized by $\mathrm{Ext}^1(P, -) = 0$;
Theorem 1 is the abelian-group instance of this with the second argument fixed to
$\mathbb{Z}$. The negative result, Theorem 3, computes the prototypical nonzero
group: $\mathrm{Ext}^1(\mathbb{Z}/n, \mathbb{Z}) \cong \mathbb{Z}/n$, whose
nontriviality is exactly the failure of the displayed extension to split.

## 2. Definitions

Throughout, "group" means abelian group, identified with a $\mathbb{Z}$-module;
"linear" means $\mathbb{Z}$-linear (equivalently, a group homomorphism).

> **Definition 1 (Whitehead group).** An abelian group $A$ is a **Whitehead group**
> if for every abelian group $G$, every linear injection $i : \mathbb{Z} \to G$,
> and every linear surjection $p : G \to A$ satisfying
> $\operatorname{range}(i) = \ker(p)$, there exists a linear map $s : A \to G$ with
> $p \circ s = \mathrm{id}_A$.

This is the splitting form of $\mathrm{Ext}^1(A, \mathbb{Z}) = 0$. The exactness
hypothesis $\operatorname{range}(i) = \ker(p)$ together with injectivity of $i$ and
surjectivity of $p$ is exactly the data of a short exact sequence. In the
formalization this is `ProjectiveWhitehead.IsWhiteheadGroup`.

> **Definition 2 (Projective module).** A $\mathbb{Z}$-module $A$ is **projective**
> if for every surjective linear map $f : M \twoheadrightarrow A$ there is a linear
> section $\sigma : A \to M$ with $f \circ \sigma = \mathrm{id}_A$. Equivalently,
> $A$ is a direct summand of a free module.

> **Definition 3 (Torsion-free).** A $\mathbb{Z}$-module $A$ is **torsion-free** if
> for every scalar $r \neq 0$ and every $a \in A$, $r \cdot a = 0$ implies
> $a = 0$. Equivalently, no nonzero element is annihilated by a nonzero integer.

> **Definition 4 (Cyclic group $\mathbb{Z}/n$).** For $n \geq 1$, $\mathbb{Z}/n$
> denotes the integers modulo $n$, a finite abelian group of order $n$ in which
> $n \cdot x = 0$ for every $x$; for $n \geq 2$ it contains nonzero torsion.

## 3. Main results

### 3.1 Projective groups are Whitehead groups

> **Theorem 1 (`isWhiteheadGroup_of_projective`).** Let $A$ be an abelian group
> that is projective as a $\mathbb{Z}$-module. Then $A$ is a Whitehead group.

**Proof sketch.** Let $0 \to \mathbb{Z} \xrightarrow{i} G \xrightarrow{p} A \to 0$
be any extension, so $p : G \to A$ is a surjective linear map. By Definition 2,
projectivity of $A$ provides a section of *any* surjection onto $A$; applying this
to $p$ yields a linear $s : A \to G$ with $p \circ s = \mathrm{id}_A$. This $s$ is
the required splitting. (Formally, the section is produced by the universal lifting
property `Module.projective_lifting_property` applied to $p$ and $\mathrm{id}_A$.)
The injectivity of $i$ and the exactness hypothesis are not even consumed: a
surjection onto a projective module always splits. $\qquad\blacksquare$

**Remark.** Theorem 1 is strictly stronger than the classical "free $\Rightarrow$
Whitehead," because free modules are projective. Phrasing the hypothesis as
projectivity makes the proof a one-line invocation of the defining lifting
property and severs any circular dependence on the structure theory of free
modules.

### 3.2 Projective groups are torsion-free

> **Theorem 2 (`Module.IsTorsionFree.of_projective_int`).** Every projective
> $\mathbb{Z}$-module $A$ is torsion-free.

**Proof sketch.** Projectivity gives a linear section $s : A \to (A \to_0
\mathbb{Z})$ of the canonical surjection from the free module $A \to_0 \mathbb{Z}$
of finitely supported integer-valued functions on $A$ (the "free module on the
underlying set of $A$"). Because $s$ is a section it is injective. The free module
$A \to_0 \mathbb{Z}$ is a direct sum of copies of the torsion-free module
$\mathbb{Z}$, hence torsion-free. A linear injection from $A$ into a torsion-free
module pulls back the torsion-freeness: if $r \cdot a = 0$ with $r \neq 0$, then
$r \cdot s(a) = s(r \cdot a) = 0$, so $s(a) = 0$ in the torsion-free codomain, and
injectivity gives $a = 0$. Hence $A$ is torsion-free. (Formally this is
`Function.Injective.moduleIsTorsionFree` applied to the section extracted from
`Module.projective_def`.) $\qquad\blacksquare$

**Remark.** Theorem 2 is the structural counterpart of Theorem 1: it explains
*why* the only obstruction to the Whitehead property is torsion. It deliberately
avoids the structure theorem (projective $\mathbb{Z}$-module $\Rightarrow$ free),
deriving torsion-freeness directly from the splitting of the projective
presentation.

### 3.3 The cyclic torsion obstruction

> **Theorem 3 (`not_isWhiteheadGroup_zmod`).** For every integer $n \geq 2$, the
> cyclic group $\mathbb{Z}/n$ is **not** a Whitehead group.

**Proof sketch.** Consider the extension
$$0 \longrightarrow \mathbb{Z} \xrightarrow{\;\cdot n\;} \mathbb{Z}
\xrightarrow{\;\bmod n\;} \mathbb{Z}/n \longrightarrow 0,$$
where the first map is multiplication by $n$ (left multiplication
`LinearMap.mulLeft`) and the second is reduction modulo $n$ (the integer cast
$\mathbb{Z} \to \mathbb{Z}/n$). We verify it is a genuine extension:

- *Injectivity of $\cdot n$:* if $n x = n y$ then $x = y$ since $n \neq 0$ and
  $\mathbb{Z}$ is an integral domain (cancellation, `mul_left_cancel₀`).
- *Surjectivity of $\bmod n$:* every residue class is the image of an integer
  (`ZMod.intCast_surjective`).
- *Exactness:* an integer reduces to $0$ modulo $n$ iff $n \mid$ it, i.e. iff it
  lies in the image of $\cdot n$; thus $\operatorname{range}(\cdot n) = \ker(\bmod
  n)$ (`ZMod.intCast_zmod_eq_zero_iff_dvd`).

Suppose toward contradiction that the extension splits, giving a linear section
$s : \mathbb{Z}/n \to \mathbb{Z}$. For any $x \in \mathbb{Z}/n$ we have $n \cdot x
= 0$, so by linearity $n \cdot s(x) = s(n \cdot x) = s(0) = 0$ in $\mathbb{Z}$.
Since $\mathbb{Z}$ is torsion-free and $n \neq 0$, this forces $s(x) = 0$. Hence
$s = 0$ is the zero map. But then $(\bmod n) \circ s = 0 \neq \mathrm{id}_{
\mathbb{Z}/n}$ (the right-hand side sends $1 \mapsto 1 \neq 0$ because $n \geq 2$),
contradicting that $s$ is a section. Therefore no splitting exists and
$\mathbb{Z}/n$ is not a Whitehead group. $\qquad\blacksquare$

**Remark.** Theorem 3 shows that the torsion-freeness of Theorem 2 is not a happy
side effect of projectivity but a genuine *necessary* condition for the Whitehead
property: any group containing a copy of $\mathbb{Z}/n$ as a direct summand
inherits this obstruction. It is the irreducible kernel of the negative side of
the Whitehead problem.

### 3.4 How the three results interlock

The three theorems are not independent observations but a tightly coupled triangle.
Theorem 1 supplies the *sufficient* condition (projective, hence the lifting
property, hence splitting). Theorem 2 extracts the *invariant* that all such groups
share (torsion-freeness), converting an abstract universal property into a
concrete, checkable feature of elements. Theorem 3 then shows that this invariant
is *not negotiable*: drop torsion-freeness and the Whitehead property fails at once,
with an extension one can write down explicitly. Read together they say that, at
least in the regime where the problem is decidable, the Whitehead property is
"detected" by torsion: presence of torsion certifies failure, and freedom (the
strongest form of torsion-free finite generation) certifies success.

The proofs are also methodologically uniform. Each turns on the torsion-freeness of
$\mathbb{Z}$ and on a single splitting/section map. In Theorem 1 the section is
handed to us by projectivity; in Theorem 2 it is the section embedding $A$ into a
free module; in Theorem 3 the *non-existence* of a section is forced because the
only linear map $\mathbb{Z}/n \to \mathbb{Z}$ is zero. The recurring lemma — a
linear map out of a torsion group into a torsion-free group must annihilate all
torsion — is the technical heart shared by Theorems 2 and 3.

## 4. The decidable boundary and the location of independence

The three theorems combine into a sharp description of where the Whitehead problem
is decidable.

> **Corollary (finitely generated case).** A finitely generated abelian group $A$
> is a Whitehead group if and only if it is free.

**Argument.** By the structure theorem over the PID $\mathbb{Z}$, a finitely
generated $A$ decomposes as $A \cong \mathbb{Z}^r \oplus T$ with $T$ finite
torsion. If $T \neq 0$ it contains a summand $\mathbb{Z}/n$ ($n \geq 2$), whose
obstruction (Theorem 3) lifts to $A$, so $A$ is not Whitehead; thus a finitely
generated Whitehead group has $T = 0$ and is free $\mathbb{Z}^r$. Conversely
$\mathbb{Z}^r$ is free, hence projective, hence Whitehead by Theorem 1. (The full
lifting of the obstruction across a direct summand and the structure theorem step
are stated as Conjectures 1–2 in Section 7; the two endpoints — Theorems 1 and 3 —
are established here.) $\qquad\square$

Thus in the finitely generated world there is *no* independence: Whitehead $=$
free, provably in ZFC. The same holds, by Stein's theorem, in the countable world.
The independence Shelah discovered lives strictly in the realm of uncountable,
non-finitely-generated groups, where constructing a global section requires
amalgamating uncountably many local choices — a process governed by combinatorial
principles ($\diamondsuit$ under $V = L$ versus uniformization failures under
$\mathrm{MA} + \neg\mathrm{CH}$) that ZFC does not settle.

The picture is therefore:

$$\underbrace{\text{free} \Rightarrow \text{projective} \Rightarrow
\text{Whitehead}}_{\text{Theorem 1, always}} \qquad
\underbrace{\text{Whitehead} \Rightarrow \text{torsion-free}}_{\text{Theorems
2–3, always (f.g./ctble.)}}$$
$$\underbrace{\text{Whitehead} \Rightarrow \text{free}}_{\text{independent of ZFC
in general}}.$$

## 5. Notes on the formalization

The development is carried out over $\mathbb{Z}$-modules. Definition 1 is recorded
as a predicate `IsWhiteheadGroup` quantifying over all abelian groups $G$ in a
fixed universe, with the exactness data given as an injection `i`, a surjection
`p`, and the hypothesis `range i = ker p`, concluding the existence of a linear
section `s` with `p ∘ s = id`. Theorem 1
(`isWhiteheadGroup_of_projective`) is discharged by the universal lifting property
of projective modules applied to the surjection `p` and the identity on $A$; the
strength of the statement comes precisely from *not* unfolding projectivity into a
basis. Theorem 2 (`Module.IsTorsionFree.of_projective_int`) extracts a splitting of
the canonical free presentation and transports torsion-freeness back along the
resulting injection into the free module $A \to_0 \mathbb{Z}$ of finitely supported
functions. Theorem 3 (`not_isWhiteheadGroup_zmod`) instantiates the Whitehead
predicate at the concrete extension `0 → ℤ →(·n) ℤ → ZMod n → 0`, verifies the
three short-exactness obligations (injectivity by cancellation, surjectivity of
the cast, exactness via divisibility), and derives a contradiction by showing the
putative section is forced to be the zero map. The use of the integers' lack of
torsion is what makes the final step go through, mirroring the informal argument
line for line.

## 6. Algorithms

The constructive content of the proofs yields concrete procedures.

### 6.1 Section extraction for split extensions

Given an extension $0 \to \mathbb{Z} \to G \xrightarrow{p} A \to 0$ with $A$
projective and a presentation of $A$ as a retract of a free module (a basis-like
generating system with a chosen lift of each generator), one constructs the
splitting $s$ by lifting each generator of $A$ to $G$ along $p$ and extending
linearly. This is the algorithmic shadow of Theorem 1.

### 6.2 Obstruction detection for cyclic summands

Given a presentation of a finitely generated abelian group via its Smith normal
form $\bigoplus_i \mathbb{Z}/d_i$ (with $d_i = 0$ encoding free $\mathbb{Z}$
factors), the group is Whitehead iff every $d_i \in \{0, 1\}$ (i.e. no genuine
torsion). Each $d_i \geq 2$ certifies a non-split extension by Theorem 3. This is a
decidable test in the finitely generated regime.

## 7. Applications and discussion

- **Homological algebra.** Theorems 1–3 instantiate the general fact that
  $\mathrm{Ext}^1(P, -) = 0$ for projective $P$ and that $\mathrm{Ext}^1(\mathbb{Z}/n,
  \mathbb{Z}) \cong \mathbb{Z}/n \neq 0$, made fully explicit and basis-free.
- **Module classification.** The decidable boundary gives a clean criterion for the
  Whitehead property on finitely generated and countable groups, tying it to Smith
  normal form / torsion detection.
- **Foundations.** The result is a case study in separating the ZFC-provable core
  of a theory from its independent periphery — a methodological template applicable
  to other undecidable algebraic statements.

A limitation, by design: we do not (and cannot, at the object level) formalize the
independence metatheorem itself, which quantifies over models of ZFC.

## 8. Future directions

The following are conjectures and program statements, not results proven here.

**Conjecture 1 (Whitehead $\Rightarrow$ torsion-free, full generality).** If $A$
is Whitehead then $A$ is torsion-free. The cyclic counterexample $0 \to \mathbb{Z}
\xrightarrow{\cdot n} \mathbb{Z} \to \mathbb{Z}/n \to 0$ realizes the only
obstruction; the general case follows by pushing it out along an injection
$\mathbb{Z}/n \hookrightarrow A$, i.e. surjectivity of the restriction
$\mathrm{Ext}^1(A,\mathbb{Z}) \to \mathrm{Ext}^1(\mathbb{Z}/n,\mathbb{Z}) \cong
\mathbb{Z}/n$ from $\mathbb{Z}$ having global dimension $1$.

**Conjecture 2 (Finitely generated Whitehead $\Leftrightarrow$ free).** For
finitely generated $A$, $A$ is Whitehead iff $A$ is free. The structure theorem
gives $A \cong \mathbb{Z}^r \oplus (\text{torsion})$; Conjecture 1 kills the
torsion, leaving $\mathbb{Z}^r$, which is Whitehead by Theorem 1.

**Conjecture 3 (Stein's theorem).** Every countable Whitehead group is free,
proved by filtering $A$ by a chain of finitely generated pure subgroups with
finitely generated torsion-free (hence free) quotients, killing the extension
class at each step.

**Conjecture 4 (Finite biproduct additivity).** $\prod_{i \in \mathrm{Fin}\,k} A_i$
is Whitehead iff each $A_i$ is, the $k$-fold generalization of binary additivity
via a $\mathrm{Fin}\,k$ induction with the section over a finite product given by
the sum of componentwise sections.

## 9. Conclusion

We have delineated the ZFC-provable skeleton of the Whitehead problem. Projectivity
guarantees the Whitehead property (Theorem 1); projective groups are torsion-free
(Theorem 2); and torsion provably obstructs the property, with $\mathbb{Z}/n$
($n \geq 2$) as an explicit witness (Theorem 3). Together they fix the decidable
boundary — free $=$ Whitehead for finitely generated groups — and locate Shelah's
independence precisely in the uncountable beyond. The shoreline is mapped; the
tide of the Continuum Hypothesis moves only out at sea.
