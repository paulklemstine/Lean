# Escher Staircases: A Faithful Order-Theoretic Witness of Non-Noetherianity

**Author:** Aristotle
**Date:** 2026-07-04

## Abstract

We introduce and study the *Escher staircase*, an infinite strictly ascending
chain of ideals $I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq \cdots$ in a
commutative ring. Motivated by the evocative image of an infinite staircase that
"loops back" to its starting point, we resolve the apparent paradox completely and
extract a clean structural dictionary. Our central result is a characterization:
**a commutative ring admits an Escher staircase if and only if it is not
Noetherian.** Thus the existence of an "impossible staircase" is not merely
symptomatic of the failure of the ascending chain condition — it *is* that failure,
faithfully repackaged in order-theoretic terms. We prove a *Loop-Back Lemma*
showing that the infinite intersection of any ascending ideal chain equals its
first term, dissolving the paradox: every staircase loops back to its bottom rung
by pure lattice theory. We exhibit a fully explicit staircase in the Boolean
product ring $\prod_{\mathbb{N}} \mathbb{F}_2$ whose bottom rung and total
intersection both equal the zero ideal, giving a concrete "climb-forever, meet-is-
the-start" model. We contrast this with a descending mirror image — the dyadic
chain $(2^n)$ in $\mathbb{Z}$, whose intersection is likewise zero — and with the
$p$-adic integers $\mathbb{Z}_p$, a discrete valuation ring that, being Noetherian,
admits no Escher staircase whatsoever. We close with conjectures on refining the
crude Noetherian/non-Noetherian dichotomy by the *growth rate* of a staircase's
minimal generating sets.

**Keywords:** Escher staircase, ascending chain condition, Noetherian ring, ideal
lattice, well-founded order, product ring, discrete valuation ring, non-
Noetherianity.

## 1. Introduction

The lithographs of M. C. Escher popularized *impossible objects*: staircases that
ascend through four right-angle turns yet return to their origin, waterfalls that
feed themselves. The appeal lies in a local rule (each step rises) that seems
irreconcilable with a global fact (the structure closes into a loop). Such tensions
recur in mathematics, where they typically signal a productive confusion between
two distinct notions.

This paper studies the algebraic analogue. In commutative algebra, the sizes
internal to a ring are measured by its *ideals*, and the health of a ring is
governed by how its ideals stack into chains. Emmy Noether isolated the decisive
property — the *ascending chain condition* (ACC) — and rings satisfying it, the
*Noetherian* rings, form the foundation of modern commutative algebra and algebraic
geometry.

We formalize the "impossible staircase" as an infinite strictly ascending chain of
ideals and ask two questions. First, *which rings host such a staircase?* Second,
*in what sense does the staircase loop back?* We answer both completely. The first
answer is a clean biconditional: staircases exist precisely in the non-Noetherian
rings. The second answer dissolves the paradox: the infinite intersection of any
ascending chain is forced, by elementary lattice theory, to equal its first term.
The staircase always loops back — not as a rare accident but as an inevitability.

### Contributions

1. A precise definition of an Escher staircase and a proof that its existence is
   *equivalent* to non-Noetherianity (Theorem 3.3).
2. The Loop-Back Lemma (Theorem 4.1): the meet of any ascending ideal chain is its
   first term.
3. A fully explicit staircase in the Boolean product ring $\prod_{\mathbb{N}}
   \mathbb{F}_2$, with bottom rung and total intersection both equal to $\{0\}$
   (Section 5), yielding a self-contained proof that this ring is non-Noetherian.
4. A descending mirror image in $\mathbb{Z}$ (Section 6) and the negative instance
   $\mathbb{Z}_p$ (Section 7), delimiting exactly where staircases can and cannot
   live.
5. Conjectures upgrading the yes/no dichotomy to a graded invariant via generator
   growth (Section 8).

## 2. Preliminaries

Throughout, $R$ is a commutative ring with unit. An **ideal** $I \subseteq R$ is an
additive subgroup closed under multiplication by arbitrary ring elements: $x \in I$
and $r \in R$ imply $rx \in I$. The ideals of $R$, ordered by inclusion $\subseteq$,
form a complete lattice: any family $\{I_j\}$ has a meet $\bigcap_j I_j$ (their
intersection, again an ideal) and a join (the ideal they generate). The least ideal
is the zero ideal $\{0\}$, written $\bot$; the greatest is $R$ itself.

A chain of ideals indexed by $\mathbb{N}$ is a function $I : \mathbb{N} \to
\{\text{ideals of } R\}$. It is **ascending** (monotone) if $m \le n \Rightarrow
I_m \subseteq I_n$, and **strictly ascending** if $m < n \Rightarrow I_m
\subsetneq I_n$; equivalently, by a standard reduction, if $I_n \subsetneq
I_{n+1}$ for all $n$.

> **Definition 2.1 (Noetherian ring).** $R$ is *Noetherian* if it satisfies the
> ascending chain condition (ACC): every ascending chain of ideals eventually
> stabilizes, i.e. for each ascending chain there is an $N$ with $I_n = I_N$ for
> all $n \ge N$.

An equivalent, order-theoretic formulation is central to our arguments. Reverse the
inclusion order on ideals; then ACC says the reversed order has no infinite
strictly descending sequence — that is, the strict order $\supsetneq$ is
*well-founded*. Well-foundedness of a relation is equivalent to the nonexistence of
an order-embedding of $(\mathbb{N}, <)$ into it; this is the pivot we use to pass
between "no infinite chain" and "an explicit infinite chain."

## 3. Escher staircases and the characterization theorem

> **Definition 3.1 (Escher staircase).** An *Escher staircase* in $R$ is an
> infinite strictly ascending chain of ideals,
> $$I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq \cdots,$$
> i.e. a strictly monotone map $I : \mathbb{N} \to \{\text{ideals of } R\}$.

> **Lemma 3.2 (Staircase $\Rightarrow$ non-Noetherian).** If $R$ carries an Escher
> staircase, then $R$ is not Noetherian.

*Proof.* A strictly monotone $\mathbb{N}$-indexed chain never stabilizes: $I_n
\subsetneq I_{n+1}$ for all $n$ directly violates ACC. Equivalently, a strictly
monotone map into the ideal lattice would be an infinite strictly descending
sequence in the reversed (well-founded) order, which is impossible. $\square$

> **Theorem 3.3 (Characterization).** A commutative ring $R$ admits an Escher
> staircase if and only if $R$ is not Noetherian.

*Proof.* ($\Rightarrow$) is Lemma 3.2. For ($\Leftarrow$), suppose $R$ is not
Noetherian. Then ACC fails, so the reversed inclusion order on ideals is *not*
well-founded. A relation fails to be well-founded exactly when it admits an order-
embedding of $(\mathbb{N}, <)$; concretely, the failure of the "every nonempty
family of ideals has a maximal element" form of ACC lets us make a recursive
choice. Start with any non-maximal ideal $I_0$ in a witnessing family; having chosen
$I_n$, its non-maximality provides a strictly larger ideal in the family, which we
take as $I_{n+1}$. The resulting sequence satisfies $I_n \subsetneq I_{n+1}$ for all
$n$ and is therefore an Escher staircase. $\square$

Theorem 3.3 is the paper's organizing principle: it converts an evocative picture
into an exact invariant. "Carries an Escher staircase" and "is non-Noetherian" are
interchangeable descriptions of the same rings.

## 4. The Loop-Back Lemma: dissolving the paradox

The name "Escher staircase" promises a paradox: a chain that climbs forever yet
loops back to its origin. We now show the loop-back is automatic and utterly
non-paradoxical.

> **Theorem 4.1 (Loop-Back Lemma).** For any ascending chain of ideals $I_0
> \subseteq I_1 \subseteq \cdots$ (strict or not),
> $$\bigcap_{n=0}^{\infty} I_n = I_0.$$

*Proof.* Two inclusions. ($\subseteq$) The intersection is contained in each
factor, in particular in $I_0$. ($\supseteq$) By monotonicity, $I_0 \subseteq I_n$
for every $n$, so $I_0$ is contained in the intersection of all the $I_n$.
Antisymmetry gives equality. $\square$

The lemma exposes the sleight of hand behind the paradox. Two genuinely different
questions get conflated:

- *Does the chain keep growing?* For a staircase, yes — strictly, at every step.
- *What do all rungs have in common?* Only the bottom rung $I_0$ — always, by
  Theorem 4.1.

There is no contradiction between an unbounded ascent and a fixed common floor. The
"loop back to the start" is the second question's answer, true for *every*
ascending chain, and it says nothing about whether the chain stabilizes. Escher's
optical illusion and the algebraist's chain are the same confusion viewed through
different lenses.

A staircase whose bottom rung is the zero ideal therefore satisfies
$\bigcap_n I_n = \{0\}$: it "loops back to $\{0\}$." We produce such a staircase
next.

## 5. An explicit staircase in the Boolean product ring

Let $B = \prod_{\mathbb{N}} \mathbb{F}_2$ be the ring of all functions $f :
\mathbb{N} \to \mathbb{F}_2$, where $\mathbb{F}_2 = \{0,1\}$ is the field with two
elements and operations are pointwise: $(f+g)(i) = f(i)+g(i)$ and $(fg)(i) =
f(i)g(i)$. This is a commutative ring (indeed a Boolean ring, since $f^2 = f$),
with zero the constant sequence $0$ and unit the constant sequence $1$.

> **Definition 5.1.** For $n \in \mathbb{N}$, let
> $$I_n = \{\, f \in B : f(i) = 0 \text{ for all } i \ge n \,\},$$
> the functions *supported below $n$*.

> **Lemma 5.2.** Each $I_n$ is an ideal of $B$.

*Proof.* The zero function lies in $I_n$. If $f,g \in I_n$ then $(f+g)(i) = f(i)+
g(i) = 0$ for $i \ge n$, so $f+g \in I_n$. For absorption, if $f \in I_n$ and $c
\in B$ is arbitrary, then $(cf)(i) = c(i)f(i) = c(i)\cdot 0 = 0$ for $i \ge n$, so
$cf \in I_n$. $\square$

> **Lemma 5.3 (Bottom rung is zero).** $I_0 = \{0\}$.

*Proof.* $f \in I_0$ means $f(i) = 0$ for all $i \ge 0$, i.e. $f$ is the zero
function. $\square$

> **Lemma 5.4 (Strict ascent).** For every $n$, $I_n \subsetneq I_{n+1}$.

*Proof.* Monotonicity: if $f(i) = 0$ for all $i \ge n$, then a fortiori $f(i) = 0$
for all $i \ge n+1$, so $I_n \subseteq I_{n+1}$. Strictness: let $e_n$ be the
indicator sequence with $e_n(n) = 1$ and $e_n(i) = 0$ for $i \ne n$. Then $e_n(i) =
0$ for all $i \ge n+1$, so $e_n \in I_{n+1}$; but $e_n(n) = 1 \ne 0$, so $e_n \notin
I_n$. Hence the inclusion is proper. $\square$

Combining Lemmas 5.3–5.4 with the reduction from "$I_n \subsetneq I_{n+1}$ for all
$n$" to full strict monotonicity, the family $(I_n)$ is an Escher staircase.

> **Theorem 5.5 (Explicit loop-back staircase).** The chain $(I_n)_{n\in\mathbb{N}}$
> of Definition 5.1 is an Escher staircase in $B$ with
> $$I_0 = \{0\} \qquad\text{and}\qquad \bigcap_{n=0}^{\infty} I_n = \{0\}.$$
> Consequently, by Theorem 3.3, the Boolean product ring $B = \prod_{\mathbb{N}}
> \mathbb{F}_2$ is **not Noetherian.**

*Proof.* Strict ascent is Lemma 5.4, so $(I_n)$ is a staircase; Lemma 3.2 (or
Theorem 3.3) gives non-Noetherianity. The bottom rung is $\{0\}$ by Lemma 5.3, and
the total intersection equals the bottom rung by the Loop-Back Lemma (Theorem 4.1).
Directly: $f \in \bigcap_n I_n$ forces $f(i) = 0$ beyond every threshold $n$, hence
everywhere, so the intersection is $\{0\}$. $\square$

This is the promised "impossible staircase": it climbs strictly forever, adding the
new indicator $e_n$ at each step, yet the ideal common to all its rungs is exactly
the zero ideal it started from. Nothing about the construction is special to
$\mathbb{F}_2$: the identical argument in $\prod_{\mathbb{N}} \mathbb{Z}$, or in
$\prod_{\mathbb{N}} k$ for any nonzero ring $k$, produces the same picture.

## 6. The descending mirror in the integers

The loop-back to zero has a descending twin. In $\mathbb{Z}$, consider the dyadic
principal ideals
$$(2^0) \supseteq (2^1) \supseteq (2^2) \supseteq \cdots,$$
i.e. $\mathbb{Z} \supseteq 2\mathbb{Z} \supseteq 4\mathbb{Z} \supseteq \cdots$.
This is a genuinely *shrinking* chain (each is properly contained in the previous),
and its intersection also collapses to zero.

> **Proposition 6.1.** $\displaystyle\bigcap_{n=0}^{\infty} (2^n) = \{0\}$ in
> $\mathbb{Z}$.

*Proof.* If $m \in \bigcap_n (2^n)$ then $2^n \mid m$ for all $n$. A nonzero
integer $m$ has finite $2$-adic valuation $v_2(m)$, so $2^{v_2(m)+1} \nmid m$, a
contradiction. Hence $m = 0$. $\square$

Ascending loop-back (Theorem 5.5) and descending collapse (Proposition 6.1) are two
manifestations of a vanishing intersection, reached from opposite directions. The
ascending case is compatible with non-Noetherianity; the descending case is
compatible with $\mathbb{Z}$ being a perfectly Noetherian PID, because ACC
restricts only *ascending* chains. This asymmetry is exactly the content of
Definition 2.1.

## 7. The negative instance: $p$-adic integers

Not every ring admits an Escher staircase. By Theorem 3.3, the Noetherian rings are
precisely those that do not.

> **Theorem 7.1.** For any prime $p$, the ring $\mathbb{Z}_p$ of $p$-adic integers
> admits *no* Escher staircase.

*Proof.* $\mathbb{Z}_p$ is a discrete valuation ring: it is a local principal ideal
domain whose nonzero ideals are exactly the powers $(p^k)$, $k \ge 0$, linearly
ordered by
$$(1) = \mathbb{Z}_p \supsetneq (p) \supsetneq (p^2) \supsetneq \cdots.$$
In particular $\mathbb{Z}_p$ is a principal ideal domain, hence Noetherian: every
ideal is finitely generated and ACC holds. By Theorem 3.3, no Escher staircase can
exist. Concretely, any ascending chain of ideals in $\mathbb{Z}_p$ corresponds to a
*non-increasing* sequence of valuation exponents in $\mathbb{N}$, which must
stabilize. $\square$

Thus $\mathbb{Z}_p$ is the clean negative instance predicted by the theory: every
staircase in it is finite and terminates at a genuine top step.

## 8. Discussion and future work

Theorem 3.3 makes "hosts an Escher staircase" a faithful synonym for "non-
Noetherian," and Theorem 4.1 strips the paradox from the name. But the yes/no test
is coarse: it cannot distinguish, say, the Boolean product ring from an infinite
polynomial ring $k[x_1, x_2, \dots]$, both merely "non-Noetherian." The natural
refinement is to *grade* staircases by how quickly they must grow.

**Generator growth and the Escher spectrum.** Attach to a staircase $(I_n)$ its
growth function $n \mapsto \mu(I_n)$, where $\mu(I)$ is the minimal number of
generators of $I$. Define the *Escher spectrum* of a ring as the set of asymptotic
growth classes realized by its staircases. We conjecture that the Boolean product
ring realizes only *linear* growth, while $k[x_1, x_2, \dots]$ realizes *super-
polynomial* growth, so the two rings — indistinguishable to the plain dichotomy —
have disjoint Escher spectra. The existence of a chain is a yes/no fact; the rate at
which minimal generating sets swell is a genuine ring-theoretic invariant that
discriminates among non-Noetherian rings.

**Loop-back staircases and collapsing intersections.** Call an ascending chain a
*loop-back staircase* when its total intersection equals its smallest member — by
Theorem 4.1 this is automatic, but the *interesting* case fixes the bottom rung at
$\{0\}$. We conjecture that a domain admits a loop-back staircase with bottom rung
$\{0\}$ iff it contains an infinite family of pairwise-comparable ideals with
trivial intersection; in particular every non-Noetherian von Neumann regular ring
admits one, a property strictly stronger than non-Noetherianity.

**Escher height on the Noetherian side.** For Noetherian rings no infinite
ascending chain exists, so the invariant must be sought among *prime* chains.
Define the *Escher height* as the supremum of lengths of strictly ascending chains
of prime ideals — the Krull dimension. We conjecture that for polynomial rings this
recovers the classical dimension formula, tying the Escher framework to established
dimension theory and providing a uniform invariant that is infinite (an actual
staircase) on the non-Noetherian side and finite (the Krull dimension) on the
Noetherian side.

## 9. Conclusion

The Escher staircase — an infinite strictly ascending ideal chain — is a faithful,
order-theoretic certificate of non-Noetherianity: a ring carries one exactly when
it fails the ascending chain condition. The apparent paradox of a chain that
"loops back" is dissolved by the Loop-Back Lemma, which shows the total intersection
of any ascending chain is its first term. The Boolean product ring furnishes a fully
explicit staircase looping back to $\{0\}$; the dyadic chain in $\mathbb{Z}$ is its
descending mirror; and the $p$-adic integers, being a discrete valuation ring,
admit no staircase at all. The picture is complete for the yes/no question, and it
points toward a graded refinement — measuring not just *whether* a ring is wild but
*how* wild — as the next chapter of the story.
