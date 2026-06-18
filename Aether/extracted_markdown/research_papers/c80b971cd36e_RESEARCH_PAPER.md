# The Oracle Counting Barrier: A Cardinal Mechanism for Finite Non-Computability, Its Constructive Core, and a Finite Turing Jump

## Abstract

We isolate the cardinal mechanism underlying the bridge between finite-description
complexity and the non-computability of three-valued oracles, and reduce it to a
single, domain-agnostic counting fact. A *three-valued oracle* on `N` statements is a
function assigning each statement one of three verdicts; there are exactly `3^N` of
them. We prove that any program space strictly smaller than the oracle space fails to
cover it — for an *arbitrary* answer alphabet, with the three-valued case as a
one-line corollary — and that any fixed program budget `b^k` is eventually outrun by
`3^N`. We separate this **coverage** obstruction from a logically independent
**information** obstruction: binary descriptions of length `N` satisfy `2^N < 3^N` for
`N ≥ 1`, the computable fraction `C / 3^N` of any constant budget tends to zero, and
the binary-reachable fraction obeys the exact geometric law `2^N / 3^N = (2/3)^N`,
which vanishes. We then push three directions further. First, a **constructive Cantor
diagonal** exhibits the escaping oracle *explicitly* when the program space is the
index set, for any alphabet of size at least two — replacing pigeonhole with an
explicit witness. Second, a **finite Turing jump**: the oracle-to-oracle composition
space has exact cardinality `3^(N · 3^N)`, strictly above the evaluation space `3^N`
for every `N ≥ 1` and beyond every fixed budget, exhibiting the jump phenomenon as a
bare cardinal inequality with no appeal to the halting problem. Third, **robustness to
logical structure**: any consistency constraint that still admits an independent
`3`-valued block of size `k` keeps the barrier biting against any sub-`3^k` program
space. The organizing insight is that coverage needs nothing about the number "3";
the "3" enters only the information story, where it yields the deficit `2^N < 3^N` and
the sharp rate `(2/3)^N`. Factoring the argument this way makes each result a one- or
two-line proof and makes the core lemma reusable across domains by changing only the
codomain.

**Keywords:** three-valued oracles, counting barrier, pigeonhole, Cantor
diagonalization, Turing jump, finite complexity, source coding, computability.

---

## 1. Introduction

The central impossibility results of logic and computation — Cantor's theorem,
Turing's undecidability of the halting problem, and the Turing jump hierarchy — are
usually presented as deep, infinitary facts requiring careful diagonal constructions.
This paper argues that, in a finite three-valued setting, the *load-bearing* content
of these results is a single elementary counting inequality, and that the
infinitary machinery is, for these purposes, dispensable.

We study **three-valued oracles**: total assignments of one of three verdicts —
intuitively *true*, *false*, *undetermined* — to each of `N` statements. Such oracles
model the verdicts produced by automated reasoning systems, formal verifiers, and
confidence-issuing assistants, all of which increasingly distinguish "proved" from
"refuted" from "unknown." The question we pose is whether a fixed, finite stock of
short programs (descriptions, recipes) can reproduce every oracle. The answer is no,
and the reason is counting.

Our contribution is twofold. **Mathematically**, we prove a suite of tight results
and, crucially, *separate two independent obstructions* that are usually conflated:

- the **coverage** obstruction — there are too many oracles for a small program
  space — which is alphabet-agnostic and uses nothing about the number `3`; and
- the **information** obstruction — each binary name is too narrow for a ternary
  verdict — which is where `3` enters and yields the sharp rate `(2/3)^N`.

**Methodologically**, we show that factoring the argument along this seam collapses
each proof to one or two lines and makes the core coverage lemma reusable by changing
only the codomain. We then extend the picture with a constructive diagonal witness, a
finite analogue of the Turing jump, and a robustness theorem under logical
consistency constraints.

All statements below are stated mathematically and accompanied by proof sketches.

---

## 2. Definitions

**Definition 2.1 (Three-valued oracle).** For `N ∈ ℕ`, a *three-valued oracle on `N`
statements* is a function `g : Fin N → Fin 3`, where `Fin N = {0, …, N-1}` indexes the
statements and `Fin 3 = {0, 1, 2}` is the verdict alphabet (read as
*false / undetermined / true*, say). We write `Oracle N := Fin N → Fin 3`.

**Definition 2.2 (`a`-valued oracle).** More generally, for an alphabet size `a ∈ ℕ`,
an *`a`-valued oracle* on `N` statements is a function `Fin N → Fin a`.

**Definition 2.3 (Program space and compilation).** A *program space* is a finite type
`P` whose elements are descriptions/recipes. A *compilation* is a function
`f : P → (Fin N → Fin a)` assigning to each program the oracle it computes. We say `f`
*covers* an oracle `g` if `g` lies in the range of `f`, i.e. some `p ∈ P` has
`f p = g`. An oracle *escapes* `f` if it is not covered.

**Definition 2.4 (Program budget).** A *budget* of the form `b^k` represents the number
of programs expressible as strings of length at most `k` over an alphabet of size `b`
(up to the usual encoding conventions); it is a constant independent of `N`.

**Definition 2.5 (Reachable fraction).** Given a program space `P` and a compilation
into `Oracle N`, the *reachable (computable, nameable) fraction* is
`|range(f)| / 3^N ≤ |P| / 3^N`. For binary descriptions of length `N`, the
ambient describable count is `2^N`, giving binary-reachable fraction `2^N / 3^N`.

**Definition 2.6 (Composition space).** The *oracle-to-oracle composition space* on `N`
statements is the function type `Oracle N → Oracle N` of all transformations of oracles.

**Definition 2.7 (Consistency constraint and independent block).** A *consistency
constraint* is a predicate `C : Oracle N → Prop` selecting the "logically admissible"
oracles. An *independent `3`-valued block of size `k`* is an injection
`emb : (Fin k → Fin 3) → Oracle N` whose every image is consistent, i.e.
`C (emb x)` for all `x`. Intuitively, `k` statements are mutually unconstrained, so any
of the `3^k` free verdict-assignments on them extends to a consistent oracle.

---

## 3. The Foundational Barrier

### 3.1 The Census of Oracles

**Theorem 3.1 (`oracle_card`).** For every `N ∈ ℕ`,
`|Oracle N| = 3^N`.

*Proof sketch.* The cardinality of a function type `X → Y` between finite types is
`|Y|^|X|`. Here `|Fin 3| = 3` and `|Fin N| = N`, so `|Fin N → Fin 3| = 3^N`. ∎

This is the one fact from which everything else descends.

### 3.2 Coverage is alphabet-agnostic

**Theorem 3.2 (Generic barrier, `oracle_not_covered_generic`).** Let `P` be a finite
type, `N, a ∈ ℕ`, and `f : P → (Fin N → Fin a)` any compilation. If
`|P| < a^N`, then some `a`-valued oracle escapes `f`:
`∃ g : Fin N → Fin a, ∀ p, f p ≠ g`.

*Proof sketch.* Suppose, for contradiction, that every oracle is covered; then `f` is
surjective onto `Fin N → Fin a`. A surjection forces
`|Fin N → Fin a| ≤ |P|`, i.e. `a^N ≤ |P|` (using
`Fintype.card_le_of_surjective` and the function-space count `Fintype.card_fun`). This
contradicts `|P| < a^N`. Hence `f` is not surjective and an escaping oracle exists. ∎

The proof uses **nothing** about the value of `a`: coverage is a pure pigeonhole fact.

**Corollary 3.3 (Three-valued barrier, `oracle_not_covered`).** Let `P` be finite and
`f : P → Oracle N`. If `|P| < 3^N`, then some three-valued oracle escapes `f`.

*Proof sketch.* Instantiate Theorem 3.2 at `a = 3`. ∎

### 3.3 Constant budgets are eventually outrun

**Theorem 3.4 (Growth lemma, `budget_gap_exists`).** For all `b, k ∈ ℕ`, there exists
`N` with `b^k < 3^N`.

*Proof sketch.* `b^k` is a fixed natural number, and `N ↦ 3^N` is unbounded above
because `3 > 1`; any sufficiently large `N` works
(`pow_unbounded_of_one_lt`). ∎

Combining Theorems 3.3 and 3.4: for any fixed program budget `b^k`, there is a world
size `N` for which the budget cannot cover all oracles. No constant toolkit suffices
uniformly in `N`.

### 3.4 The information obstruction and where "3" enters

The previous results are about *how many* programs you have. The next are about *how
wide* each description is, and this is where the ternary alphabet matters.

**Theorem 3.5 (Information deficit, `binary_insufficient`).** For every `N ≥ 1`,
`2^N < 3^N`. (At `N = 0` equality holds: `2^0 = 3^0 = 1`, the boundary where the
deficit vanishes.)

*Proof sketch.* For `N ≥ 1`, strict monotonicity of `x ↦ x^N` in the base on positive
integers gives `2^N < 3^N`; equivalently `(3/2)^N > 1`. ∎

**Theorem 3.6 (Computable fraction collapses, `computable_fraction_tendsto_zero`).**
For any constant `C ∈ ℕ`, the nameable fraction `C / 3^N → 0` as `N → ∞`.

*Proof sketch.* `C` is fixed and `3^N → ∞` (since `3 > 1`), so the quotient
`C / 3^N` tends to `0` by the standard limit `c / a_N → 0` when `a_N → ∞`. ∎

**Theorem 3.7 (Exact geometric law, `binary_fraction_eq`).** For every `N`,
`2^N / 3^N = (2/3)^N` (as real numbers).

*Proof sketch.* `(2/3)^N = 2^N / 3^N` by the quotient rule for powers,
`(x/y)^N = x^N / y^N`. ∎

**Theorem 3.8 (Vanishing reach, `binary_fraction_tendsto_zero`).**
`(2/3)^N → 0` as `N → ∞`.

*Proof sketch.* `|2/3| < 1`, so the geometric sequence `(2/3)^N` tends to `0`
(`tendsto_pow_atTop_nhds_zero_of_lt_one`). ∎

Theorems 3.7–3.8 sharpen the constant-budget collapse of Theorem 3.6 to a *closed
form* in the binary-description case: not only does the reachable fraction vanish, it
vanishes at the exact geometric rate `(2/3)^N`, the finite shadow of Shannon source
coding (description rate below `log_2 3 ≈ 1.585` bits per ternary symbol cannot keep
up).

---

## 4. Extensions

### 4.1 A constructive diagonal witness

The barrier of §3 is nonconstructive — it asserts that an escaping oracle exists via
pigeonhole. When the program space is the *index set itself*, the witness can be
written down explicitly by a Cantor-style diagonal, and the construction needs only
that the alphabet has at least two verdicts.

**Theorem 4.1 (Constructive diagonal escape, `oracle_diagonal_escape`).** Let
`N, a ∈ ℕ` with `a ≥ 2`, and let `f : Fin N → (Fin N → Fin a)` be `N` descriptions of
`a`-valued oracles on `N` statements. Define `g : Fin N → Fin a` by
`g i := (f i i + 1) mod a`. Then `g` differs from the `i`-th description at coordinate
`i` for every `i`, hence `∀ i, f i ≠ g`: no description equals `g`.

*Proof sketch.* Suppose `f i = g` for some `i`. Evaluating at coordinate `i` gives
`f i i = g i = (f i i + 1) mod a`. Write `v := f i i`, so `v < a`. Two cases on whether
the successor wraps:
- If `v + 1 < a`, then `(v+1) mod a = v + 1`, so `v = v + 1`, impossible.
- If `v + 1 = a` (the only other possibility since `v < a`), then `(v+1) mod a = 0`,
  so `v = 0`; but then `a = v + 1 = 1`, contradicting `a ≥ 2`.
Either way we reach a contradiction, so `f i ≠ g` for all `i`. ∎

This is the finite, fully constructive form of Cantor's diagonal: an explicit
unreachable object rather than an existence proof. The "3" is again incidental — any
`a ≥ 2` admits a token to flip to.

### 4.2 A finite Turing jump

We now count *transformations* of oracles rather than oracles themselves.

**Theorem 4.2 (Composition census, `oracle_comp_card`).** For every `N`,
`|Oracle N → Oracle N| = 3^(N · 3^N)`.

*Proof sketch.* By the function-space count, `|Oracle N → Oracle N| = |Oracle N|^|Oracle N|`.
Theorem 3.1 gives both factors as `3^N`, so this is `(3^N)^(3^N)`, which collapses to
`3^(N · 3^N)` by the law `(x^m)^n = x^(m·n)`. ∎

**Theorem 4.3 (The finite jump, `oracle_comp_jump`).** For every `N ≥ 1`,
`|Oracle N| < |Oracle N → Oracle N|`, i.e. `3^N < 3^(N · 3^N)`.

*Proof sketch.* Since `3 > 1`, the map `m ↦ 3^m` is strictly increasing, so it suffices
to show `N < N · 3^N`. For `N ≥ 1` we have `3^N ≥ 3^1 = 3 ≥ 2`, hence
`N · 3^N ≥ 2N > N`. ∎

**Theorem 4.4 (Composition outruns every budget, `oracle_comp_budget_gap`).** For all
`b, k ∈ ℕ`, there exists `N` with `b^k < |Oracle N → Oracle N|`.

*Proof sketch.* By Theorem 3.4 choose `N` with `b^k < 3^N`. Then
`3^N ≤ 3^(N · 3^N) = |Oracle N → Oracle N|` because `N ≤ N · 3^N` and `3 > 1`. Chain
the inequalities. ∎

Together, Theorems 4.2–4.4 reproduce the qualitative content of the Turing jump —
"transforming is strictly harder to describe than evaluating, and unboundedly so" —
as a bare cardinal inequality between a finite set and the function space on it. No
halting problem, no infinite diagonal, no degree theory is invoked.

### 4.3 Robustness to logical structure

One might hope that imposing logical consistency on oracles shrinks their number below
the program budget and restores computability. It does not, provided any independent
block survives.

**Theorem 4.5 (Robustness, `consistent_oracles_escape`).** Let `P` be finite, `N, k ∈ ℕ`,
and `C : Oracle N → Prop` a consistency constraint. Suppose there is an injection
`emb : (Fin k → Fin 3) → Oracle N` with `C (emb x)` for all `x` (an independent
`3`-valued block of size `k` inside the consistent oracles). If `|P| < 3^k`, then for
any compilation `f : P → Oracle N` there exists a *consistent* oracle `g` (i.e.
`C g`) with `∀ p, f p ≠ g`.

*Proof sketch.* Let `A := image(emb)` and `B := image(f)` inside `Oracle N`. Since `emb`
is injective, `|A| = |Fin k → Fin 3| = 3^k`. Since `B` is the image of `P`,
`|B| ≤ |P| < 3^k = |A|`. A set of strictly larger cardinality cannot be a subset of a
smaller one, so `A ⊄ B`; pick `a ∈ A \ B`. As `a ∈ A`, write `a = emb x`, whence
`C a` holds by hypothesis. As `a ∉ B`, `a` is not in the range of `f`, i.e.
`∀ p, f p ≠ a`. Take `g := a`. ∎

The proof reduces to comparing two Finset cardinalities. The barrier needs only a
single uncluttered antichain of `k` mutually independent statements; to defeat it, a
consistency constraint would have to entangle almost all statements, collapsing every
independent block below `log_3 |P|`.

---

## 5. Algorithms

The results are constructive enough to drive exact computation. We summarize three
procedures (full code in the accompanying demo).

**Algorithm A — Oracle census and reachable-fraction calculator.** Given `N`, alphabet
size `a`, and budget `B`, compute the oracle count `a^N`, the reachable fraction
`min(B, a^N) / a^N`, and the exact binary law `(2/3)^N` when `a = 3`. Complexity:
`O(log` of the numbers`)` using big-integer arithmetic; the outputs are exact rationals.

**Algorithm B — Constructive diagonal witness.** Given `N` descriptions
`f : {0,…,N-1} → ({0,…,N-1} → {0,…,a-1})`, return the explicit escaping oracle
`g i = (f(i)(i) + 1) mod a` and verify `f(i) ≠ g` for all `i`. Complexity: `O(N²)` to
build and verify (or `O(N)` to build, `O(N²)` to certify against all descriptions).

**Algorithm C — Finite-jump and budget-gap search.** Given a budget `b^k`, find the
smallest `N` with `b^k < 3^N` (evaluation gap) and confirm
`b^k < 3^(N · 3^N)` (composition gap). Complexity: `O(N)` big-integer comparisons via
incremental powering.

---

## 6. Applications

**Automated reasoning at scale.** Treat each statement of a corpus as carrying a
verdict in {proved, refuted, unknown}. Theorem 3.3 says any fixed-size verifier or
prover-cache misses some verdict-assignment once the corpus is large; Theorem 3.8 says
the missed fraction is overwhelming and grows geometrically. The "unknown" verdict —
the third token — is exactly what enlarges the space beyond binary reach.

**Confidence and modal oracles.** Discretizing real-valued confidence into `a` levels
yields `a`-valued oracles; the generic barrier (Theorem 3.2) applies uniformly in `a`,
covering decision, modal, and confidence oracles under one lemma.

**Cross-domain transfer.** Any domain whose objects map onto a three-valued verdict
vector with at least `2^n` realizable patterns inherits Corollary 3.3 verbatim: no
fixed-size certificate family reproduces all patterns. Candidate targets include
tropical feasibility/infeasibility/degeneracy verdicts and structured logical systems.

**Source-coding analogue.** Theorem 3.7's law `(2/3)^N` is the finite mirror of the
Shannon bound: binary descriptions at rate `1 < log_2 3` bits per ternary symbol
cannot name the typical oracle, and the failure probability is exactly `1 - (2/3)^N`.

---

## 7. Discussion

The methodological point deserves emphasis. The folklore reading of "you can't compute
all the oracles" bundles two facts: there are too many oracles, and each is too rich to
name in binary. We have shown these are *logically independent* and provable separately
in one line each. Coverage (Theorem 3.2) is alphabet-blind; the ternary structure
enters only the information story (Theorems 3.5, 3.7). This factoring is what makes the
core lemma a reusable primitive: to transport the barrier to a new domain, one supplies
only a count of realizable codomain elements and applies the generic barrier.

The extensions show the mechanism is sturdier than a single inequality. It has a
constructive witness (Theorem 4.1), it amplifies under composition into a finite,
halting-problem-free Turing jump (Theorems 4.2–4.4), and it survives logical
consistency constraints whenever an independent block remains (Theorem 4.5). In every
case the proof is a cardinality comparison; the depth lies in the *organization*, not
the technical machinery.

A natural worry is that the finiteness trivializes the analogy with the classical,
infinitary results. We view it the other way: the finite version isolates what the
infinitary proofs are *really* using. Cantor's diagonal becomes an explicit modular
flip; the jump becomes `|X| < |X → X|`; undecidability of "all verdicts" becomes
`|P| < a^N`. The infinitary apparatus is a way to take limits of these finite facts,
not an additional ingredient.

---

## 8. Future Work

Five directions extend the program (stated in detail in the package's future-directions
field):

1. **Consistent oracles still escape.** Lower-bound the number of `C`-consistent
   oracles by `3^k` on an independent antichain and feed it to the generic barrier;
   conjecture the barrier survives any `R` leaving a linear-in-`N` antichain.
2. **Composition amplifies the gap.** Generalize the finite jump to iterated
   composition, conjecturing a strictly increasing tower of description costs — a fully
   constructive finite jump hierarchy.
3. **Exact reachability spectrum.** Determine the fraction
   `min(2^m, a^N)/a^N` of `a`-valued oracles reachable by length-`m` binary
   descriptions, and prove a sharp phase transition at description rate `c = log_2 a`.
4. **Confidence oracles via discretization limit.** Show real-valued confidence
   oracles, discretized to `a` levels, inherit the barrier uniformly in `a` and in the
   limit `a → ∞`.
5. **Tropical solution oracles.** Map tropical polynomial systems to three-valued
   feasibility verdicts and apply Corollary 3.3 to show no fixed-size certificate family
   computes them all.

---

## 9. Conclusion

The bridge between finite-description complexity and three-valued non-computability
rests on a single cardinal mechanism: there are `3^N` oracles, and any smaller program
space — for any alphabet — misses one. Separating coverage from information turns the
folklore into a handful of one-line theorems, yields an explicit diagonal witness, a
finite Turing jump as a bare inequality `3^N < 3^(N · 3^N)`, and robustness to logical
constraints. The deepest barriers of computability, viewed finitely, are arithmetic.
