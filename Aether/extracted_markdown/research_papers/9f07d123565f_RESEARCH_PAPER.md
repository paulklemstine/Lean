# The Order-Theoretic Geometry of the p-Simulation Preorder: Binary Meets and Infinite Height in the Poset of p-Degrees

## Abstract

We study the structural geometry of the **p-simulation preorder** on abstract
(Cook–Reckhow) proof systems and of its associated **poset of p-degrees**. Working
with proof systems abstracted to a completeness-witnessing map `proves : Proof → Thm`
equipped with a size measure `size : Proof → ℕ`, we model p-simulation as the existence
of a *monotone, polynomially bounded* size blow-up translating proofs of one system
into proofs of another that certify the same theorem. This relation is a preorder; its
antisymmetrization is the partial order of p-degrees.

We prove two structural theorems. First, **binary meets always exist**: the direct-sum
system `P ⊕ Q` (whose proofs are the disjoint union of `P`- and `Q`-proofs) is the
greatest lower bound of `{P, Q}`, so the simulation preorder is down-directed and the
p-degrees form a meet-semilattice. The universal property is closed by taking the
pointwise maximum of two blow-ups, which we show remains a polynomial blow-up. Second,
the poset of p-degrees has **infinite height**: restricting to size-indexed systems
`Sys(a)` over `ℕ`, we establish a clean *domination characterization* — `Sys(a)`
simulates `Sys(b)` iff `a` is dominated by a monotone polynomial blow-up of `b` — and
use it to exhibit the strictly increasing chain `powSystem(k) = Sys(n ↦ 2^(n^k))`,
`k ≥ 1`. The key arithmetic engine is the *gap lemma*: for every degree `c` and every
`k ≥ 1` there is an `n` with `(2^(n^k) + 2)^c < 2^(n^(k+1))`, so each rung is a
super-polynomial leap above its predecessor. We contrast this with the *collapsing*
ladder `2^(k·n)`, whose consecutive rungs are p-equivalent because `2^((k+1)n) =
(2^(kn))²`. The unifying invariant throughout is **polynomial comparability of growth
rates**: meets correspond to pointwise maxima of blow-ups, and height corresponds to
chains of pairwise poly-incomparable growth rates.

All results have been formally verified, with no remaining gaps, depending only on the
standard foundational axioms `propext`, `Classical.choice`, and `Quot.sound`.

---

## 1. Introduction

The Cook–Reckhow program reduces the comparison of formal reasoning systems to a single
preorder. A propositional proof system, in their original sense, is a polynomial-time
computable surjection from strings ("proofs") onto the tautologies they certify; one
system *p-simulates* another when proofs of the latter translate into proofs of the
former with at most polynomial size increase. Their foundational observation is that
the existence of a proof system in which every tautology has a polynomial-size proof is
equivalent to NP = coNP. Thus **separations** of proof systems — demonstrations that
one system cannot p-simulate another — are exactly the lower-bound steps in the program
to separate complexity classes.

Most of the literature is concerned with *concrete* separations between *specific*
systems (resolution, Frege, cutting planes, polynomial calculus, and so on). This paper
takes the complementary, **order-theoretic** view: ignoring which systems are
"natural," what is the *shape* of the entire ordered structure of p-degrees? We
abstract away the computability layer and isolate the polynomial blow-up class as the
sole structural parameter, then prove two theorems about the resulting poset:
existence of binary meets, and infinite height.

This work extends a prior development in which the simulation relation was shown to be a
preorder, p-equivalence a setoid, and a single separating pair (linear vs. Fibonacci
size) was exhibited via the super-polynomiality of the Fibonacci numbers. The
contributions here move from "there is a preorder with one separating pair" to genuine
structural geometry.

### 1.0 Context and design choices

The classical theory fixes a single, concrete notion of "polynomial" and a single
encoding of proofs as strings. We make two deliberate abstractions that sharpen the
order-theoretic picture without distorting it. First, we strip the computability layer:
a proof system is just a completeness witness `proves` together with a size function, so
that *any* mathematical object can serve as a proof. This is harmless for the questions
we ask, because simulation only ever inspects the size and the certified theorem, never
the internal syntax of a proof. Second, we make the polynomial blow-up class an explicit,
first-class object (Definition 2.1) rather than an informal side condition. The single
structural requirement we impose on this class is *closure under composition* (for
transitivity) and *closure under pointwise maximum* (for meets); everything downstream is
order theory layered on top of these two closure facts.

A recurring theme is that *all* arithmetic content of the theory is concentrated in a
handful of elementary growth-rate facts. Transitivity is composition closure; meets are
maximum closure; separations are failures of polynomial domination. Once these are in
hand, the structural theorems (preorder, meet-semilattice, infinite height) are formal
consequences. This separation of concerns — soft order theory over a thin layer of hard
arithmetic — is what makes the development both robust and reusable: replacing the
polynomial class by any other composition-and-maximum-closed class of blow-ups would
leave the meet theorem and the domination law intact.

The choice to model the computable family over `Thm = ℕ` with `proves = id` (Definition
5.1) is also deliberate: it eliminates all index bookkeeping, so that the hardness
hypothesis collapses to a statement purely about the size functions, and the
antisymmetrization machinery of the ambient order library applies verbatim.

### 1.1 Contributions

1. **Binary meets (Section 4).** The direct sum `sumSystem P Q` is the greatest lower
   bound of `{P, Q}` (Theorem `isGLB_sumSystem`). Consequently the preorder is
   down-directed (Theorem `simulation_directed`) and the p-degrees form a
   meet-semilattice.
2. **A domination characterization (Section 5).** For size-indexed systems over `ℕ`,
   simulation reduces to pointwise polynomial domination of size functions
   (`simulates_sysOfSize_iff`). Every separation question becomes a question about
   comparing growth rates.
3. **Infinite height (Section 6).** The power ladder `powSystem(k) = Sys(n ↦ 2^(n^k))`
   is a strictly increasing chain of distinct p-degrees (`powSystem_strictMono`,
   `powSystem_pdegrees_injective`), driven by the gap lemma `pow_pow_succ_gap`.

---

## 2. The polynomial blow-up class

We measure size with natural numbers and quantify "efficient translation" through a
single, composition-closed class of stretch functions.

**Definition 2.1 (Polynomially bounded).** A function `f : ℕ → ℕ` is *polynomially
bounded*, written `PolyBounded f`, if there exists `k : ℕ` such that
```
∀ n,  f n + 1 ≤ (n + 2)^k.
```

The `+2` base and `+1` offset are deliberate. They make the class robust at `n = 0`
(where a constant `f` exceeding `1` would defeat a naive `(n+1)^k` bound) and, crucially,
**closed under composition** — the algebraic engine behind transitivity of simulation.

**Definition 2.2 (Monotone blow-up).** `PolyMono f` holds when `f` is monotone *and*
`PolyBounded`. Monotonicity is the ingredient that lets one chain two size bounds: if a
later stage enlarges its input, its budget does not shrink.

**Lemma 2.3 (Identity and composition).**
`PolyBounded (id)`; and if `PolyBounded f` and `PolyBounded g` then
`PolyBounded (f ∘ g)`. Hence `PolyMono` is closed under composition.

*Proof sketch.* For composition, suppose `f n + 1 ≤ (n+2)^a` and `g n + 1 ≤ (n+2)^b`.
Then `g n + 2 ≤ (n+2)^(b+1)` (doubling a power of `n+2` is absorbed by one more factor),
so
```
f(g n) + 1 ≤ (g n + 2)^a ≤ ((n+2)^(b+1))^a = (n+2)^(a(b+1)).
```
∎

**Lemma 2.4 (Domination is polynomially bounded).** If `s n ≤ f n` for all `n` and
`PolyBounded f`, then `PolyBounded s`.

This single closure fact is the only arithmetic input to *every* simulation
separation: "P fails to simulate Q" always reduces to "the required blow-up would
escape the polynomial class."

---

## 3. Proof systems and the simulation preorder

**Definition 3.1 (Proof system).** A *proof system* for theorems of type `Thm` is a
structure
```
ProofSystem Thm := {
  Proof   : Type,
  proves  : Proof → Thm,
  size    : Proof → ℕ,
  complete : Function.Surjective proves
}.
```
Completeness asserts every theorem is certified by some proof.

**Definition 3.2 (p-simulation).** `Simulates P Q` ("`P` p-simulates `Q`") holds iff
there is a blow-up `f` with `PolyMono f` such that
```
∀ q : Q.Proof,  ∃ p : P.Proof,  P.proves p = Q.proves q  ∧  P.size p ≤ f (Q.size q).
```
Every `Q`-proof is matched by a `P`-proof of the *same* theorem with polynomially
bounded size.

**Theorem 3.3 (Preorder).** `Simulates` is reflexive (identity blow-up) and transitive
(composite blow-up via Lemma 2.3), hence a `Preorder` with `P ≤ Q := Simulates P Q`.

**Definition 3.4 (p-equivalence and p-degrees).** `PEquiv P Q := Simulates P Q ∧
Simulates Q P`. This is an equivalence relation, in fact precisely the antisymmetry
relation `AntisymmRel (≤)`. The **poset of p-degrees** is the antisymmetrization
`Antisymmetrization (ProofSystem Thm) (≤)` with its induced partial order.

**Theorem 3.5 (Generic separation template).** Let `s : ℕ → ℕ` satisfy `¬ PolyBounded s`.
Suppose `Q` proves a family `t n` with proofs of size `≤ n`, while every `P`-proof of
`t n` has size `≥ s n`. Then `¬ Simulates P Q`.

*Proof sketch.* A simulation blow-up `f` would force `s n ≤ f n` for all `n` (translate
the size-`≤ n` `Q`-proof of `t n`; the resulting `P`-proof has size both `≥ s n` and
`≤ f n`, using monotonicity to absorb `Q.size ≤ n`). By Lemma 2.4 this makes `s`
polynomially bounded, a contradiction. ∎

The Fibonacci numbers `F` are super-polynomial (`¬ PolyBounded F`, via the exponential
lower bound `2^n ≤ F(2n+1)` and the fact that exponentials dominate polynomials), so
Theorem 3.5 specializes to a concrete separation, treated next.

---

## 4. Binary meets: the direct-sum system

**Definition 4.1 (Direct sum).** For `P, Q : ProofSystem Thm` define
```
sumSystem P Q := {
  Proof   := P.Proof ⊕ Q.Proof,
  proves  := Sum.elim P.proves Q.proves,
  size    := Sum.elim P.size Q.size,
  complete := (completeness of P lifted along Sum.inl)
}.
```
A proof is *either* a `P`-proof or a `Q`-proof, certifying the same theorem with the
same size — the "keep whichever proof you like" system.

**Lemma 4.2 (Max of blow-ups).** If `PolyMono f` and `PolyMono g`, then
`PolyMono (n ↦ max (f n) (g n))`.

*Proof sketch.* Monotonicity of the pointwise max is immediate from monotonicity of `f`
and `g`: if `n ≤ m` then `f n ≤ f m` and `g n ≤ g m`, hence `max(f n, g n) ≤ max(f m,
g m)`. For the bound, from `f n + 1 ≤ (n+2)^a` and `g n + 1 ≤ (n+2)^b` we get
`max(f n, g n) + 1 ≤ (n+2)^(a+b+1)`, since both `(n+2)^a` and `(n+2)^b` are `≤
(n+2)^(a+b+1)` (the base `n+2 ≥ 1` so larger exponents only increase the value). The
single exponent `a+b+1` therefore witnesses `PolyBounded` for the maximum. ∎

**Lemma 4.3 (Lower bound).** `Simulates (sumSystem P Q) P` and
`Simulates (sumSystem P Q) Q`, each via the identity blow-up and the injections
`Sum.inl`, `Sum.inr`.

**Lemma 4.4 (Universal property).** If `Simulates R P` and `Simulates R Q`, then
`Simulates R (sumSystem P Q)`.

*Proof sketch.* Let `f₁`, `f₂` be the two blow-ups. Use `max f₁ f₂` (polynomial by
Lemma 4.2). For a left summand `Sum.inl q` apply the `P`-simulation and bound by
`le_max_left`; for `Sum.inr q` apply the `Q`-simulation and bound by `le_max_right`. ∎

**Theorem 4.5 (Meets exist).** For all `P, Q`, the direct sum `sumSystem P Q` is the
greatest lower bound of `{P, Q}`:
```
IsGLB ({P, Q} : Set (ProofSystem Thm)) (sumSystem P Q).
```

*Proof.* Lemma 4.3 gives the lower-bound half; Lemma 4.4 gives the greatest-lower-bound
half (any common lower bound `R` simulates the direct sum). ∎

**Corollary 4.6 (Down-directedness).** Every two systems have a common lower bound
(`simulation_directed`), namely their direct sum. Hence the poset of p-degrees is a
**meet-semilattice**.

*Remark.* The dual question of binary **joins** (least upper bounds) is genuinely open
and is discussed in Section 8.

---

## 5. Size-indexed systems and the domination law

To probe height we restrict to a transparent, computable family.

**Definition 5.1 (Size-indexed system).** For `a : ℕ → ℕ`,
```
sysOfSize a := { Proof := ℕ, proves := id, size := a, complete := surjective_id }.
```
The proof `n` certifies the theorem `n`; its size is `a n`. The catalog's `linSystem`
and `fibSystem` are the cases `a = id` and `a = F`.

**Theorem 5.2 (Domination law).** For all `a, b : ℕ → ℕ`,
```
Simulates (sysOfSize a) (sysOfSize b)
   ↔  ∃ f, PolyMono f ∧ ∀ n, a n ≤ f (b n).
```

*Proof sketch.* (⇒) A simulation translates the proof `n` of `sysOfSize b` (size
`b n`) into a proof of the same theorem `n` in `sysOfSize a`; since `proves = id`, that
proof *is* `n`, of size `a n`, and the simulation bound gives `a n ≤ f (b n)`. (⇐)
Given such an `f`, translate each proof `n` to itself; the same theorem is certified and
`a n ≤ f (b n)` is exactly the required size bound. ∎

Theorem 5.2 is the **law of the land**: simulation between size families is *exactly*
polynomial domination of size functions. A slower-growing size function yields a
*stronger* system.

**Corollary 5.3 (Strict 2-chain).** `linSystem < fibSystem`: the linear system
simulates the Fibonacci system (`id n ≤ F n` and `id` is a blow-up), but the Fibonacci
system does not simulate the linear system, since `F n ≤ f n` would make `F`
polynomially bounded (Lemma 2.4), contradicting super-polynomiality of Fibonacci.

---

## 6. Infinite height: the power ladder

We seek an infinite strictly increasing chain of p-degrees. By Theorem 5.2 this means
a sequence of size functions, each *not* polynomially dominated by the next.

### 6.1 Why the exponential ladder collapses

Consider `a_k(n) = 2^(k·n)`. Then
```
a_{k+1}(n) = 2^((k+1)n) = (2^(kn))² = (a_k(n))².
```
Squaring is a polynomial operation, so `a_{k+1} ≤ poly ∘ a_k` and, symmetrically,
`a_k ≤ a_{k+1}`. By Theorem 5.2 all rungs are *p-equivalent*: the entire family lives in
a single p-degree. A plain exponential, however its rate is scaled, occupies one floor.

### 6.2 The working ladder

Move the parameter into the exponent of the exponent.

**Definition 6.1 (Power ladder).** `powSystem k := sysOfSize (n ↦ 2^(n^k))`.

**Lemma 6.2 (Gap lemma `pow_pow_succ_gap`).** For every `c : ℕ` and every `k ≥ 1`,
there exists `n` with
```
(2^(n^k) + 2)^c < 2^(n^(k+1)).
```

*Proof sketch.* Take `n > c` (and `n ≥ 2`). Then
```
(2^(n^k) + 2)^c ≤ (2^(n^k + 1))^c = 2^(c·(n^k + 1)) ≤ 2^(c·n^k + c).
```
It remains to dominate the exponent: `c·n^k + c < n^(k+1) = n·n^k` once `n > c` (since
`n·n^k = c·n^k + (n-c)·n^k` and `(n-c)·n^k ≥ n^k ≥ c+1` for `n ≥ 2, k ≥ 1`). Strict
monotonicity of `2^(·)` finishes the inequality. ∎

The left side is the largest value a degree-`c` polynomial blow-up could extract from
rung `k` (using `f(m) ≤ (m+2)^c` for a blow-up `f`); the right side is rung `k+1`. The
lemma says rung `k+1` eventually outruns *every* polynomial inflation of rung `k`.

**Theorem 6.3 (Strict chain `powSystem_strictMono`).** The map `j ↦ powSystem (j+1)` is
strictly increasing in the simulation order: `powSystem(j+1) < powSystem(j+2)` for all
`j`.

*Proof sketch.* The slower function `2^(n^k)` is dominated by `2^(n^(k+1))` (indeed
`n^k ≤ n^(k+1)`), giving simulation one way via Theorem 5.2. For strictness, a
simulation the other way would supply a *single* blow-up `f` with `PolyMono f` and
`2^(n^(k+1)) ≤ f(2^(n^k))` for all `n`. Writing `f(m) + 1 ≤ (m+2)^c` and instantiating
the gap lemma at the offending `n` contradicts the bound. ∎

**Theorem 6.4 (Distinct degrees `powSystem_pdegrees_injective`).** The rungs descend to
pairwise distinct p-degrees in `Antisymmetrization (ProofSystem ℕ) (≤)`; equivalently
the chain is genuinely infinite.

**Corollary 6.5 (Infinite height).** The poset of p-degrees contains an infinite
strictly increasing chain; its height is infinite.

### 6.3 The unifying invariant

Two growth rates collapse to one p-degree exactly when each is a polynomial of the
other (*polynomial comparability*). The family `2^(k·n)` is a single comparability
class; the family `2^(n^k)` is an infinite antichain of comparability classes stacked
into a chain. Height in the p-degree poset is precisely a tower of pairwise
poly-incomparable growth rates — and the meet of Section 4 corresponds, under Theorem
5.2, to the pointwise *minimum strength* (= pointwise *maximum* of blow-ups).

---

## 7. Algorithms

The constructive content yields decision procedures for the size-indexed family, useful
for experimentation (see the accompanying demo).

**Algorithm 7.1 (Witnessed polynomial-domination test).** Given size functions `a`, `b`
as callables and a search bound, find the least exponent `k` and verify
`a n + 1 ≤ (b n + 2)^k` on a sampled prefix — a *certified-on-sample* witness that
`sysOfSize a` simulates `sysOfSize b` with blow-up `m ↦ (m+2)^k`.

**Algorithm 7.2 (Gap-witness search).** Given `c` and `k ≥ 1`, return the least `n`
realizing the gap lemma inequality `(2^(n^k)+2)^c < 2^(n^(k+1))`. Theory guarantees
`n = c + 1` (with `n ≥ 2`) always works; the search confirms it and exhibits the
margin.

**Algorithm 7.3 (Collapse detector).** Given a parametric family `a_k`, test whether
consecutive rungs are mutually polynomially dominated on a sample; flag p-equivalence
(collapse) versus separation. Applied to `2^(k·n)` it reports collapse; applied to
`2^(n^k)` it reports separation.

---

## 8. Discussion and future work

### 8.1 Meet-semilattice vs. lattice

We proved binary **meets** always exist (Theorem 4.5). The dual is open: do binary
**joins** (least upper bounds) exist? A natural candidate — a "product" system forcing a
simulator to handle both — does not obviously have the right universal property, because
upper bounds in the simulation order must be *stronger* than both inputs and there is no
canonical way to manufacture extra strength. If joins fail in general, the p-degrees
would be a meet-semilattice that is provably **not** a lattice: a genuine asymmetry
between *combining weakness* (easy, via direct sum) and *combining strength* (obstructed).

### 8.2 Order type of the height

The power ladder shows height is at least `ω`. Is it exactly `ω`, or do diagonal /
limit constructions push the order type higher? Size functions like
`2^(n^{f(n)})` for slowly growing `f` may interleave between rungs, suggesting a dense
or higher-ordinal structure between consecutive power rungs.

### 8.3 Width and antichains

Beyond chains, are there large antichains of pairwise incomparable p-degrees? Growth
functions that are oscillating or incomparable (e.g. `2^(n^k)` on evens, `2^(n^j)` on
odds) plausibly yield incomparable degrees, bounding the poset's width from below.

### 8.4 Bridges to concrete systems

The abstract size-indexed family is a laboratory. Transporting the meet construction and
the domination law to *genuine* propositional proof systems (resolution, Frege) — where
size functions arise from real lower bounds — would connect this geometry to the
mainline Cook–Reckhow separations.

---

## 9. Conclusion

The p-simulation preorder, viewed purely order-theoretically, has a definite and
attractive shape. It is **down-directed with binary meets**, realized concretely by the
direct-sum "run either system" construction. On the computable family of size-indexed
systems it is governed by a **single law** — simulation is polynomial domination of
growth rates — which turns proof-complexity separations into elementary calculus. And it
is **infinitely tall**, witnessed by the power ladder `2^(n^k)` whose rungs are
separated by super-polynomial gaps, in pointed contrast to the collapsing exponential
ladder `2^(k·n)`. The single invariant organizing all three phenomena is *polynomial
comparability of size functions*: meets are maxima of blow-ups, and height is a tower of
poly-incomparable growth rates. The dual existence of joins remains the natural open
frontier.

---

## Appendix A. Formal status

All statements above are formalized and machine-checked with no remaining gaps. The
development depends only on the standard foundational axioms `propext`,
`Classical.choice`, and `Quot.sound`. The principal named results are: `polyMono_max`,
`simulates_sumSystem_left`, `simulates_sumSystem_right`,
`simulates_sumSystem_of_simulates_both`, `isGLB_sumSystem`, `simulation_directed`,
`simulates_sysOfSize_iff`, `lin_lt_fib`, `pow_pow_succ_gap`, `powSystem_strictMono`,
`powSystem_pdegrees_injective`, building on the preorder core (`Simulates_refl`,
`Simulates_trans`, `simulationPreorder`, `pEquivSetoid`), the super-polynomiality of
Fibonacci (`two_pow_le_fib`, `not_polyBounded_fib`, `no_poly_bound_dominates_fib`), and
the generic separation template (`no_simulation_of_hard`, `polyBounded_of_le`).
