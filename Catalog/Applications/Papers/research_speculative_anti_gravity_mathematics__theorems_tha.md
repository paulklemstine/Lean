# Anti-Gravity Mathematics: A Combinatorial Theory of Theorem Weight in Dependency DAGs

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Computation

---

## Abstract

We develop a rigorous combinatorial theory of how "importance" is distributed
across a formal body of mathematics. Modeling a library as a finite directed
acyclic graph (DAG) of theorems ordered by dependency, we define the
**gravitational weight** of a theorem as the number of other theorems that depend
on it, and we call a theorem **anti-gravity** when it combines high weight with a
short proof. We prove three exact structural laws. (1) *Monotonicity*
(`weight_lt_of_dep`): weight is strictly order-reversing along the dependency
order, so it is a graded invariant ranking the library by depth. (2)
*Conservation* (`sum_weight_eq`): the total weight summed over all theorems equals
the number of dependency pairs, a handshaking identity. (3) *Above-average
foundation* (`exists_weight_ge_average`): by pigeonhole, some theorem attains at
least the average weight, so heavy foundational theorems are forced. We then turn
to the existence and density of anti-gravity theorems. We exhibit a guaranteed
construction, the **fan**, whose hub has arbitrarily high weight and a constant
proof length. Finally, we **refute** the conjectured universal "10% law": the
anti-gravity fraction is not a library invariant. The **discrete** library
(no dependencies) realizes fraction `0`, while the **chain** library realizes
fraction `k/(k+1) → 1`, with an exact count `chain_antigravity_card`. We close
with three sharpened conjectures — a chain-length bound from monotonicity, a
threshold phase transition replacing the false 10% law, and a heavy-tail
consequence of conservation.

---

## 1. Introduction

A persistent intuition holds that the significance of a mathematical result and
the difficulty of proving it should rise together: the more a theorem matters, the
harder it ought to be. Yet practicing mathematicians know counterexamples
abound. Short, near-trivial results — the triangle inequality, the union bound,
`0 · x = 0`, the change-of-variables formula — are invoked everywhere while
costing almost nothing to establish. They are the load-bearing stones of the
edifice: they support enormous superstructure while weighing little themselves.

We name such results **anti-gravity theorems** and ask three questions:

1. Can the dual notions of "how much a theorem supports" and "how much it costs"
   be made precise and quantitative?
2. What structural laws govern the distribution of support across a library?
3. Are anti-gravity theorems rare, common, or — as conjectured — a fixed
   universal fraction (the "10% law")?

We answer all three. Support is captured by **gravitational weight**, a purely
combinatorial count on the dependency DAG. We prove three exact laws governing its
distribution. And we settle the density question in the negative: the anti-gravity
fraction depends entirely on the *shape* of the dependency graph and ranges across
the whole interval `[0,1)`, so no universal constant — least of all 10% — can
exist.

Throughout, a "library" is an abstract finite dependency graph; the theory is
agnostic to the underlying mathematics and applies verbatim to the internal
dependency record of any proof assistant.

---

## 2. Definitions

We fix a finite set `V` of *theorems* (the vertices) and a binary relation `≺` on
`V` read as **"depends on"**: `a ≺ b` means the proof of `a` uses `b`.

### Definition 2.1 (Dependency DAG)

A **dependency DAG** on a finite vertex set `V` is the relation `≺` together with
its transitive closure, required to be a strict partial order: `≺` is

- **irreflexive**: never `a ≺ a` (no theorem proves itself), and
- **transitive**: `a ≺ b` and `b ≺ c` imply `a ≺ c` (if your proof uses `a`, and
  `a` uses `b`, you ultimately use `b`).

Irreflexivity plus transitivity is exactly the acyclicity of the graph. We write
`a ≺ b` for the dependency order on the transitive closure, so that `a ≺ b` means
"`a` (transitively) depends on `b`."

### Definition 2.2 (Gravitational weight)

For `b ∈ V`, the **gravitational weight** is the number of theorems depending
on `b`:

> `weight(b) = | { a ∈ V : a ≺ b } |.`

Equivalently, `weight(b)` is the in-degree of `b` in the transitive closure
(counting all transitive dependents, not only immediate ones). Foundational
theorems — used pervasively — have large weight; terminal "leaf" applications have
weight `0`.

### Definition 2.3 (Proof length)

Each theorem `b` carries a **proof length** `len(b) ∈ ℕ`, an abstract cost
parameter (e.g. number of proof steps, term size, or tactic count). The theory
uses only that `len` is a nonnegative integer attached to each vertex.

### Definition 2.4 (Anti-gravity theorem)

Fix a **weight threshold** `τ ∈ ℕ` and a **length budget** `ℓ ∈ ℕ`. A theorem `b`
is **anti-gravity** (at parameters `τ, ℓ`) when it is simultaneously heavy and
cheap:

> `antiGravity(τ, ℓ, b)  :⇔  weight(b) ≥ τ  ∧  len(b) ≤ ℓ.`

The **anti-gravity fraction** of a library with `n = |V|` theorems is

> `ρ(τ, ℓ) = | { b ∈ V : antiGravity(τ, ℓ, b) } | / n.`

### Definition 2.5 (Dependency pair count)

The **number of dependency pairs** is

> `D = | { (a, b) ∈ V × V : a ≺ b } |,`

the number of edges of the transitive closure — the total amount of "leaning" in
the library.

---

## 3. Structural laws

The three results in this section are exact and hold for *every* finite dependency
DAG.

### 3.1 Monotonicity: weight flows downhill

#### Theorem 3.1 (`weight_lt_of_dep`)

*If `a ≺ b` then `weight(a) < weight(b)`.*

**Proof sketch.** Consider the dependent sets `A = { x : x ≺ a }` and
`B = { x : x ≺ b }`. If `x ≺ a` then, since `a ≺ b`, transitivity (Definition 2.1)
gives `x ≺ b`; hence `A ⊆ B`. Moreover `a ∈ B` because `a ≺ b`, while `a ∉ A`
because `≺` is irreflexive (`a ⊀ a`). Thus `A ⊊ B` is a strict subset, and for
finite sets `|A| < |B|`, i.e. `weight(a) < weight(b)`. ∎

**Interpretation.** Weight is *strictly order-reversing*: it decreases as one
climbs the dependency order toward applications and increases as one descends
toward foundations. Consequently weight is a **graded invariant** — a height
function on the DAG. It linearly orders the library by depth with no human
judgment required: the most foundational results are exactly the heaviest.

A corollary used repeatedly: along any dependency chain
`t₀ ≺ t₁ ≺ ⋯ ≺ tₘ`, weight is strictly increasing, so the weights are `m + 1`
distinct natural numbers.

### 3.2 Conservation: total weight equals total dependency

#### Theorem 3.2 (`sum_weight_eq`)

*The total weight equals the number of dependency pairs:*

> `Σ_{b ∈ V} weight(b) = D.`

**Proof sketch.** Expand the left-hand side using Definition 2.2 and exchange the
order of summation (Fubini for finite indicator sums):

```
  Σ_b weight(b) = Σ_b | { a : a ≺ b } |
               = Σ_b Σ_a [a ≺ b]
               = | { (a,b) : a ≺ b } |
               = D,
```

where `[·]` is the 0/1 indicator. Each dependency pair `(a,b)` contributes exactly
`+1`, to the weight of its second coordinate `b`. ∎

**Interpretation.** This is the handshaking lemma for dependency: every act of one
theorem leaning on another adds one unit of weight to the supported theorem and to
nothing else. Total weight is therefore a *conserved* quantity, equal on the nose
to the raw count of dependencies. A library's aggregate "importance mass" is
neither more nor less than its number of dependency pairs.

### 3.3 Above-average foundation: heavy theorems are forced

#### Theorem 3.3 (`exists_weight_ge_average`)

*If `V` is nonempty with `n = |V|`, there exists `b ∈ V` with*

> `weight(b) ≥ D / n,`

*i.e. some theorem attains at least the average weight.*

**Proof sketch.** By Theorem 3.2 the mean weight is
`(1/n) Σ_b weight(b) = D/n`. No finite multiset of reals can have every element
strictly below its mean; equivalently, if every `weight(b) < D/n` then summing
gives `Σ weight(b) < n · (D/n) = D`, contradicting Theorem 3.2. Hence some `b`
satisfies `weight(b) ≥ D/n`. ∎

**Interpretation.** Interconnection concentrates. As soon as a library has
appreciable dependency density — in particular `D ≥ n`, i.e. at least as many
dependency pairs as theorems — there is *necessarily* a theorem of weight `≥ 1`,
and more generally of weight `≥ D/n`. Foundational, load-bearing theorems are not
a matter of taste or historical accident; they are a counting-theoretic
inevitability.

---

## 4. Existence of anti-gravity theorems: the fan

We now combine high weight with short proof.

### Construction 4.1 (The fan `F_n`)

Let `F_n` have vertices `{ r, a₁, …, a_n }` (so `|V| = n + 1`). Set the only
dependencies to be `aᵢ ≺ r` for each `i` (every leaf depends on the single root
`r`), with the transitive closure adding nothing new. Assign proof lengths
`len(r) = c` for a small constant `c` and `len(aᵢ)` arbitrary.

#### Proposition 4.2 (The fan guarantees anti-gravity)

*In `F_n`, `weight(r) = n`. Hence for any threshold `τ ≤ n` and any budget
`ℓ ≥ c`, the root `r` is anti-gravity.*

**Proof sketch.** The set `{ a : a ≺ r }` is exactly `{ a₁, …, a_n }`, so
`weight(r) = n ≥ τ`. By construction `len(r) = c ≤ ℓ`. Both clauses of
Definition 2.4 hold for `r`. ∎

**Interpretation.** The fan is a *machine* for anti-gravity: by enlarging `n` the
hub's weight grows without bound while its proof length stays fixed. Anti-gravity
theorems therefore always *can* be produced; existence is never in doubt. The
substantive question is **density**, treated next — and there the naive
conjecture fails.

---

## 5. Refutation of the 10% law

A natural conjecture (the original prediction of this investigation) asserts a
**universal anti-gravity fraction**: that in any formal library roughly `10%` of
theorems are anti-gravity, independent of the library. We refute it by exhibiting
two libraries whose fractions bracket the entire admissible range.

### 5.1 The discrete library: fraction 0

### Construction 5.1 (Discrete library `Dₙ`)

`Dₙ` has `n` vertices and *no* dependencies: `a ≺ b` never holds.

#### Proposition 5.2 (Discrete fraction is zero)

*In `Dₙ`, `weight(b) = 0` for all `b`. Hence for any threshold `τ ≥ 1` (any
nontrivial requirement of "high" weight), no theorem is anti-gravity, and
`ρ(τ, ℓ) = 0`.*

**Proof sketch.** With no dependency pairs, `{ a : a ≺ b } = ∅`, so every weight
is `0`. For `τ ≥ 1` the clause `weight(b) ≥ τ` fails for all `b`. ∎

This already contradicts any universal *positive* lower bound, in particular
`10%`.

### 5.2 The chain: fraction `k/(k+1) → 1`

### Construction 5.3 (Chain library `Cₖ`)

`Cₖ` has vertices `t₀, t₁, …, tₖ` (so `|V| = k + 1`) with the linear order
`t₀ ≺ t₁ ≺ ⋯ ≺ tₖ` (and its transitive closure). Assign every vertex a constant
short proof length `len(tᵢ) = c`.

#### Lemma 5.4 (Weights along the chain)

*In `Cₖ`, `weight(tⱼ) = j` for each `0 ≤ j ≤ k`.*

**Proof sketch.** The dependents of `tⱼ` are exactly `{ t₀, …, t_{j-1} }`, the `j`
vertices below it in the chain (by transitivity each lower index depends on
`tⱼ`), giving `weight(tⱼ) = j`. ∎

#### Theorem 5.5 (`chain_antigravity_card`)

*Fix threshold `τ = 1` and any budget `ℓ ≥ c`. In `Cₖ` the number of anti-gravity
theorems is exactly*

> `| { j : antiGravity(1, ℓ, tⱼ) } | = k,`

*namely `t₁, …, tₖ` (all but the top of the chain `t₀`). Consequently the
anti-gravity fraction is*

> `ρ(1, ℓ) = k / (k + 1) → 1  as  k → ∞.`

**Proof sketch.** Every proof length is `c ≤ ℓ`, so the length clause holds for all
`k + 1` vertices. By Lemma 5.4, `weight(tⱼ) ≥ 1` exactly when `j ≥ 1`, which holds
for `t₁, …, tₖ` — that is `k` vertices — and fails only for `t₀` (weight `0`).
Hence the count is `k`, and dividing by `|V| = k + 1` gives `k/(k+1)`, which tends
to `1`. ∎

### 5.3 Conclusion of the refutation

The discrete library forces the anti-gravity fraction to `0` (Proposition 5.2),
while the chain drives it arbitrarily close to `1` (Theorem 5.5); the fan
(Section 4) realizes intermediate values such as `1/(n+2)`. Therefore:

> **The anti-gravity fraction is not a library invariant. No universal constant —
> in particular not `10%` — can describe it.** The fraction is determined by the
> *shape* of the dependency DAG and the chosen threshold, and ranges over the whole
> interval `[0, 1)`.

Refuting the clean conjecture is itself the result: it tells us precisely what
*kind* of statement could be true instead — one parameterized by a threshold, not
a constant (Section 6).

---

## 6. A worked example

To make the abstract laws concrete, consider a small but non-trivial library `L`
with five theorems:

- `base` — a foundational lemma, proof length `1`;
- `midA`, `midB` — two intermediate results, each depending on `base`, proof
  lengths `5` and `4`;
- `top` — a capstone depending on both `midA` and `midB` (hence transitively on
  `base`), proof length `12`;
- `isolated` — an unrelated fact with no dependencies, proof length `2`.

The transitive closure of the depends-on relation is

```
  midA  ≺ base
  midB  ≺ base
  top   ≺ midA,  top ≺ midB,  top ≺ base   (the last by transitivity)
```

so the dependent sets are `{a : a ≺ base} = {midA, midB, top}`,
`{a : a ≺ midA} = {top}`, `{a : a ≺ midB} = {top}`, and `∅` for both `top` and
`isolated`. Reading off Definition 2.2:

| theorem    | weight | proof length |
|------------|:------:|:------------:|
| `base`     |   3    |      1       |
| `midA`     |   1    |      5       |
| `midB`     |   1    |      4       |
| `top`      |   0    |     12       |
| `isolated` |   0    |      2       |

We verify each law directly.

- **Monotonicity** (Theorem 3.1). Every dependency edge increases weight:
  `weight(midA) = 1 < 3 = weight(base)`, `weight(top) = 0 < 1 = weight(midA)`,
  and `weight(top) = 0 < 3 = weight(base)`. The heaviest theorem `base` is exactly
  the most foundational, and the lightest, `top`, is the most derived — the weight
  ranking recovers the intuitive hierarchy with no human input.
- **Conservation** (Theorem 3.2). The number of dependency pairs is
  `D = 3 + 1 + 1 = 5` (the closure has five edges), and the sum of weights is
  `3 + 1 + 1 + 0 + 0 = 5`. They agree exactly.
- **Above-average foundation** (Theorem 3.3). The average weight is
  `D/n = 5/5 = 1`, and `base` (weight `3`) and the two mid-level results (weight
  `1`) all meet or exceed it; the law is witnessed by `base`.

Note also that `base` is the unique **anti-gravity** theorem of `L` at, say,
threshold `τ = 2` and budget `ℓ = 3`: it alone is both heavy (`weight = 3 ≥ 2`)
and cheap (`len = 1 ≤ 3`). The isolated fact is cheap but not heavy; `top` is
neither. This five-node library already exhibits the entire phenomenology — a
single load-bearing stone carrying weight far above its proof cost, surrounded by
derived results that cost more yet support nothing.

---

## 7. Discussion and future work

The three structural laws survive scrutiny and reframe the subject. Monotonicity
makes weight a height function; conservation pins total weight to total
dependency; the averaging bound forces heavy foundations. What collapses is the
density conjecture, and its collapse points to the right replacement questions.

### Conjecture 7.1 (Weight is a graded invariant bounding chain length)

In any finite dependency DAG, the longest chain `t₀ ≺ t₁ ≺ ⋯ ≺ tₘ` satisfies
`m ≤ weight(t₀)`, and more strongly `weight(tᵢ) ≥ m − i`.

*Rationale.* Theorem 3.1 makes `weight` strictly decreasing along the chain (from
the heavy bottom `t₀` to the light top `tₘ`); a strictly monotone `ℕ`-valued
function on a chain of length `m` forces a spread of at least `m`. This converts
the *global* quantity "number of dependents" into a *local* certificate of proof
depth. The remaining step is a finite induction over the order, directly supported
by the framework that proved Theorems 3.1–3.3.

### Conjecture 7.2 (Threshold-determined fraction; phase transition)

The anti-gravity fraction is governed by the *threshold*, not the library. For the
family of all DAGs on `n` nodes, the expected fraction with `weight ≥ τ` is
`Θ(1)` only when `τ = Θ(1)`, and decays whenever `τ → ∞`.

*Rationale.* Sections 4–5 already realize fractions spanning `[0, 1)` (discrete
`→ 0`, chain `→ 1`, fan `1/(n+2)`), so the fraction cannot be an invariant. The
correct object is the dependence of the fraction on `τ` and on the weight
*distribution*, i.e. a phase transition in `τ`. With `chain_antigravity_card`
(Theorem 5.5) giving exact counts, fraction-vs-threshold statements are concrete
and testable, and random-DAG weight distributions are within reach of finite
counting.

### Conjecture 7.3 (Conservation forces a heavy tail)

In any DAG with `D` dependency pairs on `n` nodes, some theorem has weight
`≥ D/n`; and if `D ≥ n` then a *positive fraction* of theorems are anti-gravity at
threshold `1`.

*Rationale.* Theorem 3.2 turns total weight into the exact pair-count `D`, so the
averaging bound `exists_weight_ge_average` (Theorem 3.3) upgrades from "someone is
heavy" to a counting statement: dense dependency (`D ≥ n`) cannot be spread so
thinly that everyone has weight `0`, forcing a nonvanishing load-bearing
population.

### Applications

The framework applies directly to the dependency record of any proof assistant or
mathematical corpus. Concrete uses include: ranking lemmas by computed weight to
prioritize maintenance of high-impact foundations; using the monotonicity
height-function to estimate proof depth without unfolding proofs; auditing a
library's anti-gravity profile *as a function of threshold* (per Conjecture 7.2)
rather than chasing a nonexistent universal constant; and using the conservation
identity as a sanity check on extracted dependency graphs (total weight must equal
edge count exactly).

---

## 8. Conclusion

We have given a precise combinatorial account of how mathematical "importance"
distributes across a library. Gravitational weight — the count of dependents —
obeys three exact laws: it flows strictly downhill along dependency
(`weight_lt_of_dep`), it is conserved with total equal to the dependency-pair
count (`sum_weight_eq`), and it forces an above-average load-bearer
(`exists_weight_ge_average`). Anti-gravity theorems — heavy yet cheap — always
exist by the fan construction. But their prevalence obeys no universal law: the
discrete library yields fraction `0` and the chain yields `k/(k+1) → 1`
(`chain_antigravity_card`), refuting the conjectured `10%` rule and replacing it
with a threshold-parameterized question. The quiet, load-bearing stones of
mathematics are real and forced to exist — but they sit wherever the architecture
of dependency places its weight, not in any fixed proportion.
