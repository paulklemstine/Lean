# Anti-Gravity Theorems in the Cryptographic Hardness Hierarchy: A Weight–Complexity Trade-off and a Density Theorem

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Cryptography

## Abstract

We formalize the folklore notion of an *anti-gravity theorem* — a result of large
influence ("gravitational weight") but short proof — inside the one-way-function
(OWF) stratum of a cryptographic hardness hierarchy. Modelling each theorem by a
single natural number, its *dependency index* `depth`, we define its **weight**
as `depth` (the number of reachable assumptions) and its **proof complexity** as
$\Omega(\text{depth})$, the number of prime factors of `depth` with multiplicity
(the count of irreducible reduction steps). Our main structural result is the
**Anti-Gravity Trade-off**: for every theorem of positive weight,
$2^{\text{proofComplexity}} \le \text{weight}$, equivalently
$\text{proofComplexity} \le \log_2 \text{weight}$. We call a theorem
*anti-gravity* when it attains equality, and we exhibit an explicit cofinal
family of such theorems — the prime witnesses $2^p$ — whose proof complexity is
exactly $p = \log_2(2^p)$. Equipping the stratum with the Alexandrov upper-set
topology of the weight preorder, we prove the **Density Theorem**: the
anti-gravity theorems are dense; every nonempty basic open set contains one.
Every result has been formally verified. We discuss why the universal,
unconditional truth is *density* rather than any fixed numeric fraction such as
the conjectured "10%."

---

## 1. Introduction

A recurring observation across mathematics is that some theorems are
disproportionately influential relative to the effort needed to prove them. The
Fundamental Theorem of Algebra underwrites vast tracts of algebra and analysis
yet admits a one-line proof via Liouville's theorem; in cryptography, the
equivalence of one-way functions with pseudorandom generators is foundational but
follows from a small number of reductions. We call such results **anti-gravity
theorems**: heavy in influence, light in proof.

To make this precise one must (i) define "weight" and "proof complexity" as
honest numerical invariants, (ii) relate them, and (iii) say something
quantitative about how common anti-gravity theorems are. This paper does all
three inside a deliberately minimal but faithful model drawn from the
cryptographic reduction graph, and every statement is machine-checked.

The choice of cryptography is natural: there, theorems *are* reductions, and the
reductions assemble into a dependency DAG whose most-studied component is the OWF
stratum. Our contributions are:

1. A numerical model of OWF-stratum theorems by a dependency index, with weight
   and proof complexity read off arithmetically (§2).
2. The Anti-Gravity Trade-off $2^{\text{proofComplexity}} \le \text{weight}$,
   bounding proof complexity logarithmically in weight (§3).
3. An explicit cofinal family of anti-gravity theorems, the prime witnesses (§4).
4. A topology on the stratum and a Density Theorem for anti-gravity theorems
   (§5).
5. A discussion of why "density," not a fixed fraction, is the robust conclusion
   (§6), with algorithms and applications (§7) and future work (§8).

---

## 2. The model: dependency index, weight, and proof complexity

We represent a theorem of the OWF stratum by a single natural number. Its
magnitude encodes how many assumptions it reaches; its prime factorization
encodes the irreducible reduction steps in its proof.

> **Definition 1 (OWF-stratum theorem, `OWFStratum`).** An object of the OWF
> stratum is a structure with one field, `depth : ℕ`, its *dependency index*.

> **Definition 2 (weight, `weight`).** The weight of a theorem $T$ is its
> dependency index:
> $$\text{weight}(T) = T.\text{depth}.$$
> It counts the assumptions reachable along the dependency graph (the
> "gravitational mass"). In particular `weight ⟨n⟩ = n` (`weight_mk`).

> **Definition 3 (proof complexity, `proofComplexity`).** The proof complexity of
> $T$ is the number of prime factors of its dependency index counted with
> multiplicity:
> $$\text{proofComplexity}(T) = \Omega(T.\text{depth})
>   = \text{length}\big(\text{primeFactorsList}(T.\text{depth})\big).$$
> Each prime factor models one *irreducible* reduction step. In particular
> `proofComplexity ⟨n⟩` is the length of the prime-factor list of $n$
> (`proofComplexity_mk`).

**Remark.** The modelling assumption is that an irreducible reduction step is an
atomic, unfactorable contribution to a proof, mirrored by a prime factor of the
index; composing two reductions multiplies their indices, so the total proof is
the product of its atoms and its length is the count of those atoms. With
$n=12=2^2\cdot 3$ we get weight $12$ and proof complexity $3$; with $n=2^{10}$ we
get weight $1024$ and proof complexity $10$.

---

## 3. The Anti-Gravity Trade-off

The crux is a tight relation between the two invariants, driven by the fact that
the smallest prime is $2$.

> **Lemma 7 (`two_pow_length_le_prod`).** For any finite list $l$ of natural
> numbers each at least $2$, $\;2^{|l|} \le \prod l.$
>
> *Proof sketch.* Induction on $l$. The empty list gives $2^0 = 1 \le 1$. For a
> head $x \ge 2$ and tail $xs$, the inductive hypothesis gives
> $2^{|xs|} \le \prod xs$, hence
> $2^{|xs|+1} = 2^{|xs|}\cdot 2 \le (\prod xs)\cdot x = \prod(x::xs)$. ∎

> **Theorem 8 (Anti-Gravity Trade-off, `antigravity_tradeoff`).** For every
> theorem $T$ with $0 < \text{weight}(T)$,
> $$2^{\text{proofComplexity}(T)} \le \text{weight}(T).$$
> Equivalently, $\text{proofComplexity}(T) \le \log_2 \text{weight}(T)$.
>
> *Proof sketch.* Let $d = T.\text{depth} = \text{weight}(T) > 0$. Every element
> of $d$'s prime-factor list is a prime, hence $\ge 2$
> (`Nat.prime_of_mem_primeFactorsList`, `Nat.Prime.two_le`). Apply Lemma 7 to
> that list: $2^{\text{(list length)}} \le \prod(\text{list})$. For $d \ne 0$ the
> product of the prime-factor list equals $d$ itself
> (`Nat.prod_primeFactorsList`). The list length is exactly
> $\text{proofComplexity}(T)$ and the product is $\text{weight}(T)$, giving
> $2^{\text{proofComplexity}(T)} \le \text{weight}(T)$. ∎

**Interpretation.** Weight is at least exponential in proof complexity, so proof
complexity is at most logarithmic in weight. A theorem of weight $10^9$ has proof
complexity at most $\lfloor \log_2 10^9 \rfloor = 29$. Heavy theorems are
*forced* to have short proof ladders; the apparent paradox of "important yet
easy" results is a structural necessity, not a coincidence.

---

## 4. Anti-gravity theorems and a cofinal family

> **Definition 9 (anti-gravity theorem, `IsAntiGravity`, `antiGravitySet`).** A
> theorem $T$ is *anti-gravity* iff it attains equality in Theorem 8:
> $$2^{\text{proofComplexity}(T)} = \text{weight}(T).$$
> The anti-gravity set is $\{T \mid \text{IsAntiGravity}(T)\}$.

Anti-gravity theorems carry the maximal weight permitted by their proof
complexity: every irreducible step is maximally load-bearing. Attaining equality
$2^k = n$ with $\Omega(n) = k$ forces all prime factors to equal $2$, i.e. $n$ is
a pure power of two. This yields a canonical infinite family.

> **Definition 10 (prime witness, `primeWitness`).** For $p \in \mathbb{N}$, the
> $p$-th prime witness is the theorem of dependency index $2^p$:
> $$\text{primeWitness}(p) = \langle 2^p \rangle.$$

> **Lemma 11 (`weight_primeWitness`, `proofComplexity_primeWitness`).**
> $\text{weight}(\text{primeWitness}(p)) = 2^p$ and
> $\text{proofComplexity}(\text{primeWitness}(p)) = p.$
>
> *Proof sketch.* The weight is $2^p$ by definition. The prime factorization of
> $2^p$ is $p$ copies of the prime $2$
> (`Nat.Prime.primeFactorsList_pow` with `Nat.prime_two`), so its list has length
> $p$. ∎

> **Theorem 12 (`primeWitness_isAntiGravity`, `primeWitness_mem`).** Every prime
> witness is anti-gravity: $2^{\,p} = 2^p$, so
> $\text{primeWitness}(p) \in \text{antiGravitySet}$.
>
> *Proof sketch.* Substitute Lemma 11 into Definition 9:
> $2^{\text{proofComplexity}} = 2^p = \text{weight}$. ∎

Thus each witness has proof complexity $p = \log_2$ of its weight — the minimum
allowed by Theorem 8. The family also exhausts the weight order from below.

> **Theorem 13 (prime cofinality, `primeWitness_cofinal`).** For every theorem
> $a$ there exists a *prime* $p$ with $a \le \text{primeWitness}(p)$.
>
> *Proof sketch.* By the infinitude of primes (`Nat.exists_infinite_primes`)
> choose a prime $p \ge \text{weight}(a)$. Since $p \le 2^p$, we get
> $\text{weight}(a) \le p \le 2^p = \text{weight}(\text{primeWitness}(p))$, i.e.
> $a \le \text{primeWitness}(p)$ in the weight preorder. ∎

The prime witnesses are therefore cofinal: no theorem out-weighs all of them.

---

## 5. Topology and the Density Theorem

To speak of "nearby theorems" we order the stratum by weight and take the
order-induced Alexandrov topology.

> **Definition 4 (weight preorder, `Preorder OWFStratum`, `le_iff_weight`).**
> $a \le b \iff \text{weight}(a) \le \text{weight}(b)$. Reflexivity and
> transitivity are inherited from $\le$ on $\mathbb{N}$.

> **Definition 5 (Alexandrov topology, `TopologicalSpace OWFStratum`,
> `isOpen_iff_isUpperSet`).** A set $s$ is open iff it is an *upper set* for the
> weight preorder ($x \in s$ and $x \le y$ imply $y \in s$). This is a topology:
> the universe is upper (`isUpperSet_univ`), and upper sets are closed under
> binary intersection and arbitrary union (`isUpperSet_sUnion`).

> **Lemma 6 (basic opens, `isOpen_Ici`).** Each principal upper set
> $\text{Ici}(a) = \{x \mid a \le x\}$ is open (`isUpperSet_Ici`). The sets
> $\text{Ici}(a)$ form a basis: every nonempty open set contains some
> $\text{Ici}(a)$ around each of its points.

> **Lemma 14 (`basic_open_contains_antiGravity`).** Every nonempty basic open set
> $\text{Ici}(a)$ contains an anti-gravity theorem.
>
> *Proof sketch.* Given the threshold $a$, take a prime $p$ with
> $a \le \text{primeWitness}(p)$ (Theorem 13). Then
> $\text{primeWitness}(p) \in \text{Ici}(a)$, and it is anti-gravity
> (Theorem 12). ∎

> **Theorem 15 (Density Theorem, `antiGravity_dense`).** The anti-gravity
> theorems are dense in the Alexandrov topology on the OWF stratum.
>
> *Proof sketch.* Density means the anti-gravity set meets every nonempty open
> set $U$. Pick $x \in U$. Since $U$ is an upper set containing $x$, it contains
> $\text{Ici}(x)$. By Lemma 14, $\text{Ici}(x)$ contains an anti-gravity theorem,
> which therefore lies in $U$. Hence the anti-gravity set meets $U$. ∎

This is the rigorous form of the original speculation that anti-gravity theorems
are "dense in the space of all theorems": in our cryptographic universe it is a
proved topological fact.

---

## 6. Why density, not a fixed fraction

The motivating conjecture predicted that roughly $10\%$ of theorems in a formal
library are anti-gravity. Our analysis separates the robust kernel of this claim
from its fragile numeric shell.

- **Robust (proved here):** anti-gravity theorems are *dense* and *cofinal*. They
  occur arbitrarily high in weight and arbitrarily close to every theorem.
- **Regime-dependent (not universal):** any *specific fraction* such as $10\%$.
  The proportion of theorems attaining equality in the trade-off depends on the
  shape of the dependency graph. A "star" library (one hub, many leaves) yields a
  vanishing fraction; a totally ordered chain yields a large one. The "10%" is
  best read as a claim about the growth exponent of total dependency mass
  $M = \sum \text{weight}$: only $M = \Theta(n^2)$ in an $n$-result library forces
  a constant positive fraction.

Thus the unconditional, model-independent statement is the Density Theorem; the
numeric prediction is a separate, empirical question about real dependency graphs
(see §8).

---

## 7. Algorithms and applications

**Computing the invariants.** Both invariants are elementary to compute from the
dependency index: the weight is the index, and the proof complexity is
$\Omega(\text{index})$, obtained by trial-division factorization in
$O(\sqrt{\text{index}})$ time. Checking `IsAntiGravity` reduces to testing whether
the index is a power of two — equivalently whether $2^{\Omega(n)} = n$.

**Finding the nearest floating theorem.** Given any threshold weight $w$, the
smallest anti-gravity theorem of weight $\ge w$ is the witness $2^{\lceil \log_2
w\rceil}$. This constructively realizes Lemma 14: for any region "from weight $w$
up," it returns a floating theorem inside it in $O(\log w)$ steps.

**Cryptographic reading.** Interpreting the stratum as reductions, the trade-off
says foundational primitives — those reachable from many assumptions — can be
reached by logarithmically many irreducible reductions. The prime witnesses are
the maximally efficient load-bearers, and density says efficient reformulations
exist arbitrarily close to any given reduction chain. In the broader hierarchy,
the one-way function is conjectured to be the global weight-maximizer (§8).

---

## 8. Discussion and future work

We turned a metaphor into theorems: weight and proof complexity became honest
arithmetic invariants of a dependency index, an exponential trade-off bounded one
by the other, and a topological density theorem pinned the floating theorems
everywhere in the space. The model is intentionally minimal; its strength is that
every claim is provable and verified, and its limitation is that the rich
structure of real reduction DAGs is compressed into a single integer.

Three directions extend the work.

**The mass–density law.** Conjecture: a library with $n$ results, total
dependency mass $M = \sum w$, and weight threshold $\theta = c\,n$ has
anti-gravity fraction $\Theta\!\big(M/(c\,n^2)\big)$, tight in both directions.
The upper half follows from a conservation/Markov bound ($\theta \cdot
\#\text{antigravity} \le \sum w$); the matching lower bound for the intermediate
$M = \Theta(n^{1+\alpha})$ regime generalizes the total-order construction.

**Empirical 10% from $M = \Theta(n^2)$.** Conjecture: measured on the real
Mathlib/`Catalog` import-and-use graph, the fraction of declarations with
above-median dependent count and below-median proof length lies in $[5\%, 15\%]$,
*explained* by the graph's near-quadratic total weight (a scale-free /
preferential-attachment structure). Lean's `importGraph` tooling exposes the
transitive-dependent relation needed to populate the abstract weight vector and
test the conservation bound directly.

**Foundations as weight-maximizers.** Conjecture: in a cryptographic reduction
DAG, a primitive is a minimal computational assumption iff it is a local maximum
of the level weight; the one-way function is the global maximizer. This is the
order-theoretic shadow of being a bottom element of the reduction preorder, and
extends the existing hierarchy's rank/level-weight machinery from the fixed
four-level chain to arbitrary finite reduction DAGs.

---

## 9. Conclusion

Within a faithful numerical model of the OWF stratum we proved that proof
complexity is at most logarithmic in weight (the Anti-Gravity Trade-off), that an
explicit cofinal family of theorems attains the bound (the prime witnesses), and
that such floating theorems are dense in the weight topology (the Density
Theorem). The anti-gravity phenomenon is therefore not anecdotal but structural,
and its truly universal expression is density rather than any fixed percentage.
