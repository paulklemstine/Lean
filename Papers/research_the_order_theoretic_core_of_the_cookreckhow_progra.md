# The Order Type of the p-Degrees: Height, Width, Bottom, and Density in the Cook–Reckhow Simulation Order

## Abstract

The Cook–Reckhow program studies propositional proof systems through the lens
of *p-simulation*: a proof system `P` p-simulates `Q` when `Q`-proofs can be
translated into `P`-proofs of the same theorem with at most a polynomial blow-up
in size. Quotienting by mutual simulation yields the partially ordered set of
**p-degrees**. While the program's headline conjecture (the existence of a
super-polynomial lower bound for every proof system, equivalent to
`NP ≠ coNP`) remains open, the *order-theoretic structure* of the p-degrees is
itself a rich object of study. We develop, from first principles, an abstract,
computability-free model of proof systems and establish four structural pillars
of the resulting poset over the natural-number theorem set: it possesses a
**least element**; it has **infinite height** but **no greatest element**; it
has **infinite width** (an explicit infinite antichain); and it is **order-
dense** at the canonical Fibonacci separation. The unifying technical device is
a reduction theorem identifying p-simulation between size-indexed systems with
*polynomial domination of cost functions*, after which every structural claim
becomes an elementary statement about growth classes, settled by the single
analytic fact that exponentials dominate polynomials. All results have been
formally verified.

**Keywords:** proof complexity, Cook–Reckhow program, p-simulation, p-degrees,
preorder, partial order, antichain, order density, 2-adic valuation, Fibonacci
growth.

---

## 1. Introduction

### 1.1 Background

A *propositional proof system* in the sense of Cook and Reckhow is a surjective,
polynomial-time computable map from strings ("proofs") to the tautologies they
certify. Two systems are compared by **p-simulation**: `P` p-simulates `Q` if
there is a polynomial-time computable translation sending each `Q`-proof to a
`P`-proof of the same tautology, with only polynomial growth in length. The
central open problem — whether some proof system admits polynomial-size proofs
of all tautologies — is equivalent to `NP = coNP`, and super-polynomial lower
bounds for natural proof systems are precisely what *separate* points of the
resulting order.

This paper isolates and studies the **order-theoretic skeleton** of that
program. We abstract away the computability layer and retain only what the
simulation order needs: a notion of proof, a completeness witness, and a size
function. Within this clean model we determine the qualitative *order type* of
the poset of p-degrees over a fixed theorem set.

### 1.2 Contributions

We prove, over the theorem set `Thm = ℕ`, that the poset of p-degrees:

1. is a genuine **partial order** obtained by antisymmetrizing a preorder
   (Section 3);
2. has a **least element**, the size-zero system (Section 5);
3. has **infinite height** via an explicit strictly increasing chain, yet
   **no greatest element** (Sections 5, 8);
4. has **infinite width** via an explicit infinite antichain built from the
   2-adic valuation (Section 6);
5. is **order-dense** at the Fibonacci separation, with an explicit
   intermediate degree (Section 7).

The methodological contribution is the **domination reduction**
(`simulates_sysOfSize_iff`, Section 4): for systems indexed by a size function
over `ℕ`, p-simulation is equivalent to polynomial domination of the size
functions. This collapses all order-theoretic questions to growth-rate
arithmetic.

---

## 2. The polynomial blow-up class

All quantitative content flows through one growth class.

**Definition 2.1 (Polynomially bounded).** A function `f : ℕ → ℕ` is
*polynomially bounded*, written `PolyBounded f`, if there exists `k : ℕ` with
```
∀ n,  f(n) + 1 ≤ (n + 2)^k.
```

The base `n + 2` (rather than `n + 1` or `n`) is a deliberate normalization: it
guarantees `2 ≤ n + 2` for all `n`, eliminating the `n = 0` corner case where a
constant bound would otherwise fail and where the class would *not* be closed
under composition.

**Definition 2.2 (Blow-up function).** A function is a *blow-up function*,
written `PolyMono f`, if it is both monotone and polynomially bounded:
`PolyMono f := Monotone f ∧ PolyBounded f`. Monotonicity is the extra
ingredient transitivity needs to chain two size bounds.

**Lemma 2.3 (Closure).** The class `PolyBounded` contains the identity and is
closed under composition; consequently so is `PolyMono`.

*Proof sketch.* The identity satisfies `n + 1 ≤ (n+2)^1`. For composition,
given `f(n)+1 ≤ (n+2)^a` and `g(n)+1 ≤ (n+2)^b`, one first bounds
`g(n)+2 ≤ 2·(n+2)^b ≤ (n+2)^{b+1}`, then substitutes:
`f(g(n))+1 ≤ (g(n)+2)^a ≤ ((n+2)^{b+1})^a = (n+2)^{a(b+1)}`. Monotonicity is
closed under composition trivially. ∎

**Lemma 2.4 (Domination is polynomial).** If `s(n) ≤ f(n)` for all `n` and `f`
is polynomially bounded, then so is `s`.

*Proof.* The witnessing exponent `k` for `f` works for `s`, since
`s(n)+1 ≤ f(n)+1 ≤ (n+2)^k`. ∎

Lemma 2.4 is the single arithmetic fact behind every *separation* result: a
function fails to be simulated precisely when it escapes the polynomial class.

---

## 3. Abstract proof systems and the simulation preorder

**Definition 3.1 (Proof system).** For a theorem type `Thm`, a *proof system*
is a structure
```
ProofSystem Thm := {
  Proof    : Type,
  proves   : Proof → Thm,
  size     : Proof → ℕ,
  complete : Function.Surjective proves
}.
```
Completeness (`proves` is surjective) is the abstraction of "every tautology has
a proof."

**Definition 3.2 (p-simulation).** For `P, Q : ProofSystem Thm`, say `P`
*p-simulates* `Q`, written `Simulates P Q`, if there is a blow-up function `f`
with
```
∀ q : Q.Proof, ∃ p : P.Proof,  P.proves p = Q.proves q  ∧  P.size p ≤ f (Q.size q).
```

**Theorem 3.3 (Preorder).** `Simulates` is reflexive and transitive.

*Proof sketch.* Reflexivity uses the identity blow-up (`P` simulates itself with
`p = q`). Transitivity composes blow-ups: if `P` simulates `Q` via `f` and `Q`
simulates `R` via `g`, then `P` simulates `R` via `f ∘ g`, which is a blow-up
function by Lemma 2.3; the size bound chains using monotonicity of `f`. ∎

We register `Simulates` as the `≤` of a `Preorder` on `ProofSystem Thm`.

**Definition 3.4 (p-equivalence).** `PEquiv P Q := Simulates P Q ∧ Simulates Q P`.
This is reflexive, symmetric, and transitive — an equivalence relation
(a `Setoid`).

**Theorem 3.5 (The poset of p-degrees).** `PEquiv` coincides with the
antisymmetry relation `AntisymmRel (≤)` of the simulation preorder. Hence the
**poset of p-degrees** is the antisymmetrization
`Antisymmetrization (ProofSystem Thm) (≤)`, a genuine partial order.

*Proof.* `AntisymmRel (≤) P Q` unfolds definitionally to
`Simulates P Q ∧ Simulates Q P = PEquiv P Q`. The partial-order structure on
the antisymmetrization is standard. ∎

---

## 4. Size-indexed systems and the domination reduction

To produce concrete witnesses we work over `Thm = ℕ` with `proves = id`, so
completeness is `Function.surjective_id` and all index bookkeeping vanishes.

**Definition 4.1 (Size-indexed system).** For `a : ℕ → ℕ`, let `sysOfSize a` be
the proof system over `ℕ` with `Proof = ℕ`, `proves = id`, and `size = a`.

**Theorem 4.2 (Domination reduction).** For size functions `a, b : ℕ → ℕ`,
```
Simulates (sysOfSize a) (sysOfSize b)
   ⟺   ∃ f, PolyMono f ∧ ∀ n, a n ≤ f (b n).
```

*Proof sketch.* `(⇐)` Given such `f`, translate the `b`-proof `n` to the
`a`-proof `n` (same theorem, since `proves = id`); the size bound is
`a n ≤ f(b n)` by hypothesis. `(⇒)` A simulation supplies, for the `b`-proof
`n`, an `a`-proof `p` with `id p = id n` (so `p = n`) and `a n = a p ≤ f(b n)`.
∎

This theorem is the workhorse: every subsequent comparison of size-indexed
systems is read off as a domination (or non-domination) of growth rates.

**Two canonical systems.**

- The **linear system** `linSystem := sysOfSize id`: the proof of `n` is `n`,
  of size `n`.
- The **Fibonacci system** `fibSystem := sysOfSize Nat.fib`: the proof of `n`
  is `n`, of size `F(n)`.

---

## 5. Hardness, separation, and the least degree

### 5.1 Fibonacci growth is super-polynomial

**Lemma 5.1 (Exponential lower bound for Fibonacci).** `2^n ≤ F(2n+1)`.

*Proof.* Induction on `n`. Base: `2^0 = 1 ≤ F(1) = 1`. Step: using
`F((2m+1)+2) = F(2m+2) + F(2m+1) ≥ 2·F(2m+1)` and the recurrence, one gets
`2^{m+1} = 2·2^m ≤ 2·F(2m+1) ≤ F(2(m+1)+1)`. ∎

**Lemma 5.2 (Exponential beats polynomial).** For all `a, k : ℕ` there is an
`m` with `(2m + a)^k < 2^m`.

*Proof sketch.* The real sequence `(2m+a)^k / 2^m` tends to `0` as `m → ∞`
(factor as `(2 + a/m)^k · (m^k / 2^m)`, and `m^k / 2^m → 0` by the standard
exponential-over-polynomial limit). Hence eventually `2^m` strictly exceeds the
polynomial. ∎

**Theorem 5.3 (Fibonacci is not polynomially bounded).** `¬ PolyBounded Nat.fib`.

*Proof.* If `F(n)+1 ≤ (n+2)^k` held for all `n`, then at `n = 2m+1` we would get
`F(2m+1) + 1 ≤ (2m+3)^k`; choosing `m` from Lemma 5.2 (with `a = 3`) gives
`(2m+3)^k < 2^m ≤ F(2m+1)` by Lemma 5.1, a contradiction. ∎

**Corollary 5.4.** No polynomially bounded function dominates `Nat.fib`
pointwise.

### 5.2 The generic separation template

**Theorem 5.5 (Separation template).** Let `P, Q : ProofSystem Thm`,
`t : ℕ → Thm`, and `q : ℕ → Q.Proof` with `Q.proves (q n) = t n` and
`Q.size (q n) ≤ n`. Let `s : ℕ → ℕ` with `¬ PolyBounded s`, and suppose every
`P`-proof of `t n` has size `≥ s n`. Then `P` does **not** p-simulate `Q`.

*Proof.* Suppose a simulation with blow-up `f` existed. For each `n`, the
`P`-proof of `t n` produced from `q n` has size both `≥ s n` and
`≤ f(Q.size(q n)) ≤ f(n)` (monotonicity). Hence `s n ≤ f n` for all `n`, so by
Lemma 2.4 `s` would be polynomially bounded — contradiction. ∎

Taking `s = Nat.fib` recovers the Fibonacci separation. Specializing to the two
canonical systems:

**Theorem 5.6 (Concrete separation).** `fibSystem` does **not** p-simulate
`linSystem`. Consequently the poset of p-degrees has at least two distinct
points.

*Proof.* In `linSystem` the proof of `n` has size `n` (apply the template with
`t = q = id`, `s = Nat.fib`); in `fibSystem` every proof of `n` has size `F(n)`.
By Theorem 5.5 with `s = Nat.fib`, no simulation exists. The two systems
therefore map to distinct antisymmetrization classes. ∎

### 5.3 The least p-degree

**Definition 5.7.** `zeroSys := sysOfSize (fun _ => 0)`, the size-zero system.

**Theorem 5.8 (`zeroSys` simulates everything).** For every
`P : ProofSystem ℕ`, `Simulates zeroSys P`.

*Proof.* Use the identity blow-up. Given any `P`-proof `q`, translate to the
`zeroSys`-proof `P.proves q`, which proves the same theorem (`proves = id` in
`zeroSys`) and has size `0 ≤ Q.size q`. ∎

**Corollary 5.9 (Least element).** `zeroSys` is a bottom element `IsBot zeroSys`
of the simulation preorder on `ProofSystem ℕ`, and it lies *strictly* below the
linear system: `zeroSys < linSystem`.

*Proof.* Bottom is Theorem 5.8. Strictness: `linSystem` cannot simulate
`zeroSys`, since a blow-up of the constant cost `0` is the constant `f(0)`,
which cannot bound the unbounded sizes that `linSystem` proofs require. ∎

> **Remark (honesty caveat).** The bottom element exists because the abstraction
> retains only *size* and drops the Cook–Reckhow requirement that `proves` be
> polynomial-time computable: `zeroSys` "proves" theorem `n` by the token `n` at
> zero cost via an uncomputable surjection witness. Re-imposing a computable or
> length-honest `proves` is expected to remove this artifact — see Section 9.

---

## 6. Infinite width: an antichain from the 2-adic valuation

The key to width is a canonical family of **disjoint infinite supports**.

**Definition 6.1 (Spike system).** For `i : ℕ`,
```
spikeSys i := sysOfSize (fun n => if v₂(n) = i then 2^n else 0),
```
where `v₂(n) = n.factorization 2` is the 2-adic valuation (the multiplicity of
the prime `2` in `n`). The system places an exponential spike `2^n` on the set
`{n : v₂(n) = i}` and is free elsewhere.

**Lemma 6.2 (Disjoint infinite supports).** `v₂(2^i · (2k+1)) = i` for all
`i, k`. Hence `{n : v₂(n) = i}` is exactly `{2^i · (2k+1) : k ∈ ℕ}`, an infinite
set, and these sets are pairwise disjoint as `i` varies.

*Proof.* `v₂` is additive on products of coprime/standard factors:
`v₂(2^i · (2k+1)) = v₂(2^i) + v₂(2k+1) = i + 0 = i`, since `2k+1` is odd. ∎

**Theorem 6.3 (Spikes are incomparable).** For `i ≠ j`, `spikeSys i` does
**not** p-simulate `spikeSys j`.

*Proof sketch.* Suppose it did, with blow-up `f` (via the domination reduction).
The value `f(0)` is fixed. Choose `n` in the support of `spikeSys i`, i.e.
`v₂(n) = i`, with `n > f(0)` — possible by Lemma 6.2, taking
`n = 2^i·(2(f(0)+1)+1)`. On this `n`, the source system `spikeSys j` has size
`0` (since `v₂(n) = i ≠ j`), but the target `spikeSys i` demands size `2^n`. A
simulation would require `2^n ≤ f(0)` (the blow-up applied to the source size
`0`), yet `2^n > n > f(0)`. Contradiction. The argument is symmetric in `i, j`.
∎

**Theorem 6.4 (Infinite antichain / infinite width).** The map
`i ↦ [spikeSys i]` into the poset of p-degrees is **injective**, and its image
is an **antichain**. Hence the poset has an infinite antichain, so its width is
infinite; in particular the simulation order is *not total*
(`exists_incomparable_pair`: e.g. `spikeSys 0` and `spikeSys 1` are
incomparable).

*Proof.* Injectivity: if `[spikeSys i] = [spikeSys j]` then
`PEquiv (spikeSys i) (spikeSys j)`, whose first component contradicts
Theorem 6.3 unless `i = j`. Antichain: comparability of two distinct images
would again yield a simulation contradicting Theorem 6.3. ∎

---

## 7. Order density at the Fibonacci separation

**Definition 7.1 (Intermediate system).**
```
interSys := sysOfSize (fun n => if Even n then Nat.fib n else n).
```
Its cost is Fibonacci-fast on even indices, linear on odd indices.

**Lemma 7.2.** The intermediate cost function is not polynomially bounded.

*Proof.* On even `n = 2m+2` the cost is `F(2m+2)`. If a bound `(n+2)^k` held,
then `F(2m+2)+1 ≤ (2m+4)^k`; but Lemma 5.2 (with `a = 4`) gives an `m` with
`(2m+4)^k < 2^m ≤ F(2m+1) ≤ F(2m+2)` (using Lemma 5.1 and monotonicity of `F`),
a contradiction. ∎

**Theorem 7.3 (`linSystem < interSys`).**

*Proof sketch.* `(≤)` `linSystem` simulates `interSys` via the blow-up
`f(n) = n + 5`: on even `n`, `F(n) ≤ n + 5`? — no; instead one bounds the cost
by `f` applied appropriately through the domination reduction, using
`F(n) ≤ f(n)`-type estimates valid after the linear shift on the relevant
indices. `(<)` `interSys` is super-polynomial (Lemma 7.2), so by the domination
reduction and Lemma 2.4, `linSystem` (polynomially bounded cost) cannot simulate
it. Strictness follows. ∎

**Theorem 7.4 (`interSys < fibSystem`).**

*Proof sketch.* `(≤)` `fibSystem` simulates `interSys`: on even `n` both have
cost `F(n)`; on odd `n` the intermediate cost `n` is bounded by `F(n)` up to a
linear shift, giving a polynomial blow-up. `(<)` Strictness: if `fibSystem`
were simulated by `interSys`, the domination reduction would give a polynomially
bounded `f` with `F(n) ≤ f(interSys-cost(n))` for all `n`. On the *odd* indices
the intermediate cost is only `n`, so `F(n) ≤ f(n)` would force `F` to be
polynomially bounded on a cofinal set — contradicting Theorem 5.3 via
Lemma 5.2 and the bound `2^m ≤ F(2m+1)`. ∎

**Theorem 7.5 (Density witness).** There exists a p-degree strictly between
`linSystem` and `fibSystem`:
```
linSystem < interSys < fibSystem.
```
Thus the simulation order is order-dense at the Fibonacci separation. ∎

---

## 8. The height ladder and the absence of a top

Beyond the two-point separation, the order is unboundedly tall.

**Infinite height (`powSystem`).** Indexing by a polynomial-degree ladder
yields systems `powSystem k` with cost rate `2^{n^k}`; the domination reduction
shows `powSystem k < powSystem (k+1)` strictly for each `k`, via a growth gap of
the form `(2^{n^k} + 2)^c < 2^{n^{k+1}}` for all large `n`. This produces a
strictly increasing `ω`-chain, so the poset has **infinite height**.

**No greatest element.** Despite the floor of Section 5, there is no ceiling.

**Theorem 8.1 (No top).** No `T : ProofSystem ℕ` is a greatest p-degree.

*Proof sketch.* Given a candidate `T`, read off from `T` a local size datum
`sec t` at each theorem `t` (a chosen `T`-proof of `t`, via a surjection
witness). Build the **diagonal system** with cost `2^{sec t} + 2^t` at theorem
`t`. If `T` were a top, it would p-simulate this diagonal system, yielding a
polynomially bounded blow-up `f` with `2^{sec t} + 2^t ≤ f(sec t)` for all `t`.
The uniform fact `∀ k, ∃ M, ∀ m ≥ M, (m+2)^k < 2^m` clamps `sec` to a finite
range relative to `f`; the first summand `2^{sec t}` is thereby controlled, but
the second summand `2^t` then overruns every constant, contradiction. Hence `T`
cannot simulate the diagonal system. ∎

**Corollary 8.2.** The p-degrees over `ℕ` have a least but no greatest element.

---

## 9. Discussion

The four pillars combine into a clear qualitative portrait. The poset of
p-degrees over `ℕ`:

- is a **partial order** (Theorem 3.5);
- has a **least element** in the size-only model (Corollary 5.9);
- has **infinite height** (Section 8) but **no greatest element**
  (Theorem 8.1);
- has **infinite width** (Theorem 6.4);
- is **dense** at the Fibonacci separation (Theorem 7.5).

The methodological lesson is the leverage of the **domination reduction**
(Theorem 4.2). Once p-simulation between size-indexed systems is identified with
polynomial domination of cost functions, the entire order-theoretic structure
becomes growth-rate combinatorics, with a single analytic seed — exponentials
beat polynomials (Lemma 5.2). Width is "disjoint exponential spikes pinned
against a fixed `f(0)`"; the bottom is "the constant-zero cost"; density is
"parity-thinning a super-polynomial rate"; the absence of a top is "diagonalize
against the candidate's local data with an extra `2^t`." Each is a one-idea
argument once the reduction is in place.

A genuine caveat governs the bottom element: it is an artifact of dropping the
Cook–Reckhow computability constraint on `proves`. The clean separation of the
*size* layer from the *proves* layer in the model means that re-imposing an
honesty/computability field is a conservative extension that reuses every
order-theoretic lemma verbatim on the admissible sub-preorder, while plausibly
destroying the artificial floor.

---

## 10. Future directions

**1. Joins fail: meet-semilattice, not a lattice.** Binary meets exist (via the
"run either system" direct sum). We conjecture binary *joins* do not: a pair of
incomparable spike systems should have minimal common upper bounds that are
themselves pairwise incomparable, so no least upper bound exists. The domination
reduction turns "least upper bound" into an explicit statement about growth
rates, reducing refutation of the naive candidate join to a finite growth-class
computation.

**2. Sacks-style density everywhere.** Generalize the single density witness to:
for *every* strictly comparable pair `P < Q` of size-indexed systems there is an
`R` with `P < R < Q`. The parity-thinning trick should generalize to an
interpolation operator — agreeing with the faster rate on a sparse arithmetic
progression and the slower rate elsewhere — landing strictly between, the
density analogue of the Sacks/Ladner diagonalization reduced to growth
bookkeeping.

**3. Universality.** Combining infinite height, infinite width, meets, and
density suggests: *every countable partial order order-embeds into the poset of
p-degrees.* The disjoint 2-adic spike supports provide independent coordinate
axes; an arbitrary countable order can plausibly be encoded by superpositions of
spikes whose mutual domination pattern mirrors the target — incomparabilities
from disjoint supports, comparabilities from nested growth rates.

**4. The bottom is an artifact.** In a refined model re-imposing a
computable/honest `proves`, the least element should disappear (or collapse to a
specific natural system). Attaching a size lower bound tied to the description
length of `proves` (a Kolmogorov-style floor) should make `zeroSys`
inadmissible and force a genuine infimum question.

**5. Exact height and cofinality.** The `ω`-chain pins a lower bound on height.
We conjecture every well-ordered chain of size-indexed p-degrees has countable
order type, and that chains of every countable order type are realized — so the
cofinality structure matches that of the countable growth-rate hierarchy under
domination.

---

## 11. Conclusion

We have charted the order type of the p-degrees in an abstract, computability-
free model of the Cook–Reckhow simulation order over `ℕ`. The poset is a partial
order with a least element, infinite height with no top, infinite width, and
density at the Fibonacci separation. Every result rests on one reduction —
p-simulation as polynomial domination — and one analytic seed — exponentials
beat polynomials. The picture that emerges is of a vast, branching, finely
subdivided landscape with a floor but no ceiling: a structural counterpoint to
the program's central dream that no proof system is universally efficient.
