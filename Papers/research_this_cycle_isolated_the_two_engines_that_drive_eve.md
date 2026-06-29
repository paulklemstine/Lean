# A Conserved-Quantity View of Cryptographic Reductions

## Abstract

We isolate the two *quantitative* engines that drive essentially every provable-security argument and the one *structural* engine that drives every black-box separation, and we present each as a standalone, self-contained theorem with an elementary proof. The unifying thread is **conservation**. On the quantitative side, computational indistinguishability — measured by the *advantage* — behaves like a single real coordinate of a pseudo-metric: the hybrid argument is sub-additivity of advantage along a path of games (an *additive* conservation law), and reduction composition is multiplicativity of advantage-loss (a *multiplicative* conservation law). On the structural side, a black-box separation is the statement that a conserved scalar — the *rank* of a primitive — cannot decrease along any constructor of a construction calculus; every separation then reduces to a numeric inequality. We formalize five quantitative results (triangle inequality, hybrid telescoping, hybrid averaging, reduction composition, stretch amplification) and four structural results (the rank invariant, two separations, and a non-triviality witness), all proved from first principles over abstract real-valued advantage sequences and an inductive primitive tower. We discuss algorithms induced by the averaging and composition laws, applications to PRG stretch and reduction-tightness accounting, and a research program that extends the metric and the invariant to capture resource cost, tightness lower bounds, and the Minicrypt/Cryptomania divide.

**Keywords.** Provable security, hybrid argument, reduction composition, pseudo-metric, black-box separation, conserved invariant, pseudorandom generator, one-way function.

---

## 1. Introduction

Modern cryptography is a science of *reductions*. A scheme is "secure" not in an absolute sense but relative to a hardness assumption: a proof exhibits a transformation turning any efficient adversary against the scheme into an efficient adversary against a presumed-hard problem. Two families of techniques dominate the resulting proofs.

1. **Quantitative arguments** track a real number — the adversary's *advantage*, the amount by which it beats a trivial guessing baseline — through a sequence of game transformations. The canonical instruments are the *hybrid argument* (introduced by Goldwasser and Micali, and Yao) and *reduction composition*.

2. **Structural arguments** ask whether one primitive can be constructed from another at all. *Black-box separations* (in the tradition of Impagliazzo–Rudich) prove that certain constructions are impossible, classically via probabilistic oracle separations.

These techniques are usually taught and used as a heterogeneous toolkit, each with its own "loss factor" bookkeeping. The contribution of this work is conceptual unification: we show that the quantitative toolkit consists of exactly two conservation laws of a single real coordinate, and the structural toolkit consists of exactly one conserved scalar on a construction calculus. The proofs become short and modular, stated over abstract objects (an arbitrary advantage sequence `d : ℕ → ℝ`; an inductive tower of primitives), so that they are reusable lemmas rather than instance-specific bounds.

### 1.1 Contributions

We prove, from first principles:

- **Quantitative (advantage as a pseudo-metric coordinate).**
  1. `advantage_triangle` — the triangle inequality for advantage.
  2. `hybrid_argument` — telescoping sub-additivity along a path of games.
  3. `hybrid_averaging` — the pigeonhole extraction principle.
  4. `reduction_composition` — multiplicativity of advantage-loss.
  5. `prg_stretch_amplification` — a uniform per-step gap `ε` over `n` hybrids yields total gap `≤ n·ε`.

- **Structural (separations as a conserved invariant).**
  6. `cryptoImplies_rank_mono` — the rank invariant: rank is monotone along every derivation.
  7. `enc_not_implies_owf` — encryption cannot black-box-construct a strictly weaker one-way function.
  8. `prf_not_implies_prg` — a pseudorandom function does not collapse downward to a generator.
  9. `owf_implies_enc` — non-triviality: the full tower is derivable.

All results are elementary and axiom-clean; the deepest ingredient is the pigeonhole principle.

---

## 2. The advantage coordinate

### 2.1 Setup and definitions

Fix a probabilistic distinguisher and a family of *games* (distributions over the distinguisher's view). For a game `G`, write `d(G) ∈ [0,1]` for the probability that the distinguisher outputs `1` on `G`. The **advantage** of the distinguisher between games `G` and `H` is `|d(G) − d(H)|`.

We abstract away every cryptographic detail and work with a bare sequence of reals.

**Definition 2.1 (Advantage sequence).** An *advantage sequence* is any function `d : ℕ → ℝ`. We interpret `d i` as the distinguisher's output probability on the `i`-th game in a chain `G₀, G₁, …`. The *per-step advantage* at step `i` is `|d i − d (i+1)|`, and the *end-to-end advantage* of an `n`-step chain is `|d 0 − d n|`.

This is the entire ontology required for the quantitative theory. No probability space, no complexity class, no security parameter appears in the statements; those live in the *instantiation* of `d`, not in the conservation laws themselves.

### 2.2 The additive law: triangle inequality

**Theorem 2.2 (`advantage_triangle`).** For all `a, b, c ∈ ℝ`,
$$|a - c| \le |a - b| + |b - c|.$$

*Proof sketch.* This is the triangle inequality for the absolute value on `ℝ`, applied to the differences `(a-b)` and `(b-c)` whose sum is `(a-c)`. ∎

Interpreted cryptographically: the advantage between two games is at most the sum of advantages through any intermediate game. The absolute value `|·|` is a pseudo-metric on output probabilities, and `advantage_triangle` is its defining inequality. Every subsequent quantitative result is a consequence of iterating or inverting this one fact.

### 2.3 Sub-additivity along a path: the hybrid argument

**Theorem 2.3 (`hybrid_argument`).** For every advantage sequence `d : ℕ → ℝ` and every `n ∈ ℕ`,
$$\left| d\,0 - d\,n \right| \;\le\; \sum_{i=0}^{n-1} \left| d\,i - d\,(i+1) \right|.$$

*Proof sketch.* Induction on `n`. The base case `n = 0` is `|d 0 − d 0| = 0 ≤ 0`. For the inductive step, write
$$|d\,0 - d\,(n+1)| \le |d\,0 - d\,n| + |d\,n - d\,(n+1)|$$
by `advantage_triangle` (Theorem 2.2), bound the first summand by the inductive hypothesis, and recognize the resulting right-hand side as `Σ_{i<n+1} |d i − d(i+1)|` after splitting off the last term of the sum (`Finset.sum_range_succ`). ∎

This is the **hybrid argument** in its purest form: end-to-end advantage is sub-additive over the per-step advantages. The cryptographic content — that two far-apart worlds are indistinguishable provided every neighboring pair of a carefully chosen chain is indistinguishable — is exactly the contrapositive reading of this telescoping bound.

### 2.4 The extraction principle: hybrid averaging

The hybrid argument bounds a total by its parts. Reductions need the converse: from a large total, *extract* a single large part.

**Theorem 2.4 (`hybrid_averaging`).** Let `a : ℕ → ℝ`, `n ∈ ℕ` with `n > 0`, and `ε ∈ ℝ`. If
$$\varepsilon \le \sum_{i=0}^{n-1} a\,i,$$
then there exists an index `i < n` with `a i ≥ ε / n`.

*Proof sketch.* By contraposition. Suppose `a i < ε/n` for every `i < n`. Since the range `{0,…,n-1}` is nonempty (as `n > 0`), summing the strict inequalities termwise (`Finset.sum_lt_sum_of_nonempty`) gives
$$\sum_{i=0}^{n-1} a\,i \;<\; n \cdot \frac{\varepsilon}{n} \;=\; \varepsilon,$$
where the equality cancels `n` using `n ≠ 0`. This contradicts the hypothesis `ε ≤ Σ a i`. ∎

This is the pigeonhole/averaging principle, and it is the engine of reductions: when an adversary's advantage is spread across `n` hybrid steps and totals at least `ε`, some single step must carry advantage at least `ε/n`, and the reduction "plants its challenge" at that step.

**Remark 2.5 (Necessity of `n > 0`).** The hypothesis `n > 0` is load-bearing. With `n = 0` the sum is empty (`= 0`), so `ε ≤ 0` is forced, yet there is no index `i < 0` to return, and the conclusion would refer to `ε/0`. The boundary case is exactly where the principle fails, which is why the positivity hypothesis is explicit.

### 2.5 The multiplicative law: reduction composition

**Theorem 2.6 (`reduction_composition`).** Let `advA, advB, advC, l₁, l₂ ∈ ℝ` with `l₂ ≥ 0`. If
$$\text{advB} \le l_1 \cdot \text{advA} \qquad\text{and}\qquad \text{advC} \le l_2 \cdot \text{advB},$$
then
$$\text{advC} \le (l_2 \cdot l_1) \cdot \text{advA}.$$

*Proof sketch.* From `advB ≤ l₁·advA` and `l₂ ≥ 0`, monotonicity of multiplication by a nonnegative scalar gives `l₂·advB ≤ l₂·(l₁·advA)`. Chaining with `advC ≤ l₂·advB` and using associativity `l₂·(l₁·advA) = (l₂·l₁)·advA` yields the claim. ∎

This is the **composition lemma**: stacking a reduction of loss `l₁` with a reduction of loss `l₂` produces a reduction of loss `l₂·l₁`. Losses *multiply*; this is the multiplicative conservation law dual to the additive hybrid law. The nonnegativity of `l₂` is exactly the hypothesis needed to preserve the inequality direction under scaling.

### 2.6 The flagship application: stretch amplification

**Theorem 2.7 (`prg_stretch_amplification`).** Let `d : ℕ → ℝ`, `n ∈ ℕ`, `ε ∈ ℝ`. If `|d i − d (i+1)| ≤ ε` for every `i < n`, then
$$|d\,0 - d\,n| \le n \cdot \varepsilon.$$

*Proof sketch.* Two routes give the same bound. (i) Apply `hybrid_argument` (Theorem 2.3) and bound each of the `n` summands by `ε`, so the sum is at most `n·ε`. (ii) Directly by induction on `n`: the base case is `0 ≤ 0`; in the step, `|d 0 − d(n+1)| ≤ |d 0 − d n| + |d n − d(n+1)| ≤ n·ε + ε = (n+1)·ε`, splitting the absolute values into their two linear bounds and finishing with linear arithmetic. ∎

Cryptographically: if a pseudorandom generator is stretched by composing `n` indistinguishable one-step extensions, each costing advantage `ε`, the fully stretched generator costs advantage at most `n·ε`. The security degrades *linearly* in the number of hybrids — the hallmark signature of the additive conservation law.

---

## 3. The rank invariant and black-box separations

### 3.1 The primitive tower and the construction calculus

We model the standard symmetric-key tower of primitives as a four-element inductive type.

**Definition 3.1 (Primitives).** Let
$$\mathsf{Primitive} = \{\, \mathsf{OWF},\ \mathsf{PRG},\ \mathsf{PRF},\ \mathsf{ENC} \,\}$$
denote, respectively, one-way functions, pseudorandom generators, pseudorandom functions, and IND-CPA secure (symmetric) encryption.

**Definition 3.2 (Rank).** The *rank* `rank : Primitive → ℕ` is the conserved scalar
$$\mathsf{rank}(\mathsf{OWF}) = 0,\quad \mathsf{rank}(\mathsf{PRG}) = 1,\quad \mathsf{rank}(\mathsf{PRF}) = 2,\quad \mathsf{rank}(\mathsf{ENC}) = 3.$$

**Definition 3.3 (Construction calculus `CryptoImplies`).** `CryptoImplies : Primitive → Primitive → Prop` is the inductive relation generated by:

- **refl.** `CryptoImplies X X` for every primitive `X`.
- **trans.** from `CryptoImplies X Y` and `CryptoImplies Y Z`, conclude `CryptoImplies X Z`.
- **hill.** `CryptoImplies OWF PRG` (a one-way function yields a pseudorandom generator — the Håstad–Impagliazzo–Levin–Luby construction).
- **ggm.** `CryptoImplies PRG PRF` (a generator yields a pseudorandom function — the Goldreich–Goldwasser–Micali tree construction).
- **enc.** `CryptoImplies PRF ENC` (a pseudorandom function yields IND-CPA encryption).

The intended reading of `CryptoImplies X Y` is "primitive `Y` can be built, black-box, from primitive `X`." The three upgrade constructors each climb exactly one rung of the tower; reflexivity and transitivity make the relation a preorder.

### 3.2 The conservation law

**Theorem 3.4 (`cryptoImplies_rank_mono`).** For all primitives `X, Y`, if `CryptoImplies X Y` then `rank X ≤ rank Y`.

*Proof sketch.* Induction on the derivation of `CryptoImplies X Y`. The `refl` case is `rank X ≤ rank X`. The `trans` case composes two inequalities `rank X ≤ rank Y ≤ rank Z`. Each of the three upgrade constructors is a concrete numeric step: `0 ≤ 1` (hill), `1 ≤ 2` (ggm), `2 ≤ 3` (enc). All five cases close by `omega`. ∎

Rank is therefore a *conserved scalar*: no constructor of the calculus decreases it. This single monotonicity fact reduces every separation to arithmetic.

### 3.3 Separations as numeric inequalities

**Theorem 3.5 (`enc_not_implies_owf`).** `¬ CryptoImplies ENC OWF`.

*Proof sketch.* If `CryptoImplies ENC OWF` held, then by `cryptoImplies_rank_mono` we would have `rank ENC ≤ rank OWF`, i.e. `3 ≤ 0`, which is false (`omega`). ∎

**Theorem 3.6 (`prf_not_implies_prg`).** `¬ CryptoImplies PRF PRG`.

*Proof sketch.* Identical pattern: `CryptoImplies PRF PRG` would give `rank PRF = 2 ≤ 1 = rank PRG`, contradiction. ∎

These are *black-box separations* expressed as a one-line numeric contradiction. The classical content — that no black-box construction climbs *down* the tower — is captured by the conserved invariant, with no probabilistic oracle argument needed at the structural level. (The invariant is an *abstraction* of the oracle technique: it records what every legitimate construction must preserve.)

### 3.4 Non-triviality

A monotone invariant is only meaningful if the calculus actually derives something. It does.

**Theorem 3.7 (`owf_implies_enc`).** `CryptoImplies OWF ENC`.

*Proof sketch.* Chain the three upgrade constructors with transitivity: `OWF → PRG` (hill), `PRG → PRF` (ggm), `PRF → ENC` (enc), so `OWF → ENC`. ∎

Thus the full symmetric-key tower is constructible upward, while every downward construction is forbidden by rank. The same scalar simultaneously *enables* (Theorem 3.7) and *obstructs* (Theorems 3.5–3.6).

### 3.5 Rank as both obstruction and metric

The rank invariant plays two roles. As an **obstruction**, distinct ranks witness separations (Section 3.3). As a **metric**, the rank gap `rank Y − rank X` lower-bounds the number of upgrade steps in any derivation `CryptoImplies X Y`, because each upgrade increments rank by one and reflexivity/transitivity cannot increase it. Combined with the additive conservation law (`prg_stretch_amplification`), which converts hybrid count into advantage loss, the rank gap becomes a *lower bound on unavoidable security loss*. The single scalar therefore drives both the impossibility story and the tightness story — a point we develop in the research program of Section 6.

---

## 4. Algorithms induced by the conservation laws

The conservation laws are not merely descriptive; each yields a constructive procedure.

### 4.1 Weak-link localization (from `hybrid_averaging`)

**Input.** Per-step advantages `a[0..n-1]` with `n > 0` and a threshold guarantee `Σ a[i] ≥ ε`.
**Output.** An index `i*` with `a[i*] ≥ ε/n`.
**Procedure.** Return `argmax_i a[i]`. Correctness: if every `a[i] < ε/n`, the sum is `< ε`, contradicting the guarantee; hence the maximum is `≥ ε/n`. Complexity: `O(n)` time, `O(1)` extra space.

This is the algorithmic skeleton of every reduction that "guesses the right hybrid": it deterministically (or, in the standard cryptographic setting, by uniform random choice) selects the step on which to plant the challenge.

### 4.2 Loss accounting (from `reduction_composition`)

**Input.** A pipeline of reductions with per-stage losses `l[1..k]`.
**Output.** The end-to-end loss factor `L`.
**Procedure.** Return `L = Π_j l[j]`. Correctness: induction on `k` using `reduction_composition`. Complexity: `O(k)`.

### 4.3 Stretch-budget allocation (from `prg_stretch_amplification`)

**Input.** A target end-to-end advantage budget `B` and a hybrid count `n`.
**Output.** The maximum admissible per-step gap `ε`.
**Procedure.** Return `ε = B / n`. Correctness: `prg_stretch_amplification` guarantees end-to-end advantage `≤ n·ε = B`. Complexity: `O(1)`.

### 4.4 Separation oracle (from `cryptoImplies_rank_mono`)

**Input.** Two primitives `X, Y`.
**Output.** `True` if `CryptoImplies X Y` is *refuted* by rank, else `Unknown`.
**Procedure.** If `rank X > rank Y`, return "separated (no black-box construction)"; else "Unknown" (rank cannot certify a positive construction beyond the tower). Complexity: `O(1)`.

---

## 5. Applications

- **PRG stretch.** Section 2.6 is the textbook proof that a length-extending generator can be iterated to arbitrary polynomial stretch with linear security loss; `prg_stretch_amplification` is the exact bound.
- **Tightness audits.** Sections 4.2 and 3.5 give a uniform method to compute (and lower-bound) the loss of a multi-stage proof: multiply stage losses, and never expect fewer hybrids than the rank gap demands.
- **Curriculum and proof engineering.** Recasting the hybrid argument, averaging, and composition as three operations on one coordinate gives a compact mental model and a small library of reusable lemmas, replacing ad-hoc, instance-specific bounds.
- **Separation triage.** The rank oracle (Section 4.4) instantly rules out impossible black-box directions in the symmetric-key tower, focusing human effort on the genuinely open comparabilities.

---

## 6. Discussion and future directions

The results above are deliberately minimal: abstract advantage sequences and a four-rung tower. Their value is as *load-bearing primitives* on which richer theory can be built. We outline a program.

### Direction 1 — A resource coordinate for the indistinguishability pseudo-metric
`advantage_triangle` proves sub-additivity of the advantage coordinate, but real computational indistinguishability lives on a two-coordinate space `(advantage, running-time)`, where chaining two distinguishers costs a factor of two (or `+O(1)`) in the time coordinate. Conjecture: there is a faithful pseudo-metric on `ℕ → (ℝ × ℝ)` whose advantage coordinate obeys the triangle inequality exactly while the time coordinate accumulates additively; the standard product-pseudo-metric machinery then yields a completion whose points are the "indistinguishability classes" of game families. The seemingly cryptographic factor-2 loss is revealed as a *product pseudo-metric* phenomenon.

### Direction 2 — Tightness lower bounds from the rank gap
Conjecture: in the `CryptoImplies` calculus, any minimal-length derivation `CryptoImplies X Y` has length exactly `rank Y − rank X`, so any quantitative realization through `prg_stretch_amplification` incurs advantage loss at least `(rank Y − rank X)·ε` — a *provable lower bound* on tightness driven purely by the rank gap. The missing lemma is "minimal derivation length = rank gap," a finite induction on `CryptoImplies`.

### Direction 3 — A two-dimensional invariant separating Minicrypt from Cryptomania
The one-dimensional `rank` is necessarily a total order, so it can only separate *comparable* (symmetric-key) primitives; it cannot witness the Impagliazzo separation of Minicrypt (one-way functions, no public-key) from Cryptomania (public-key exists), because public-key crypto is *incomparable* to, not weaker than, a PRF. Conjecture: extending `Primitive` with a public-key constructor and replacing `rank : Primitive → ℕ` with a two-dimensional invariant `rank₂ : Primitive → ℕ × ℕ` (symmetric strength, key asymmetry) under the product order makes `¬ CryptoImplies OWF PKE` provable by the identical invariant-then-`omega` pattern. Black-box separations are exactly the *incomparabilities* of the right partial order.

### Direction 4 — GGM as a tree-indexed hybrid with logarithmic loss
`prg_stretch_amplification` handles a *linear* chain of `n` hybrids with loss `n·ε`. The GGM construction evaluates a *balanced binary tree* of depth `n` with `2^n` leaves, yet its security loss is the *depth* `n`, not the leaf count. Conjecture: a tree-indexed analogue states that a root-to-leaf distinguisher in a depth-`n` tree whose every internal edge has gap `≤ ε` has root-to-leaf advantage `≤ n·ε`, provable by the *same* telescoping `hybrid_argument` applied along the unique path. The exponential-hybrids/logarithmic-loss phenomenon is just the averaging principle applied path-locally.

### Direction 5 — Goldreich–Levin as a correlation-to-rank bridge
The Goldreich–Levin hardcore-bit theorem turns a predictor with advantage `ε` on `⟨x,r⟩ mod 2` into an inverter succeeding with probability `poly(ε)`; its core is list-decoding a Boolean function significantly correlated with a linear function. Conjecture: the list-decoding bound is an instance of `hybrid_averaging` — `ε`-correlation summed over `r` forces, by pigeonhole, a single heavy Fourier coefficient (the `∃ i, ε/n ≤ a i` shape) — so a GL reduction is `hybrid_averaging` (heavy-coefficient extraction) composed with `reduction_composition` (predictor-to-inverter loss multiplication). "Significant correlation forces a heavy linear coefficient" is the averaging principle in the Fourier basis.

---

## 7. Conclusion

The quantitative theory of provable security is governed by two conservation laws of a single real coordinate — the advantage: sub-additivity along a path (the hybrid argument) and multiplicativity under composition (reduction composition), with the pigeonhole averaging principle as the extraction dual. The structural theory of black-box separations is governed by a single conserved scalar — the rank of a primitive — that no construction can decrease. Five elementary quantitative theorems and four structural theorems suffice to capture the recurring "loss factor" bookkeeping and the standard symmetric-key separations. Recasting the field's folklore as conservation laws makes the proofs modular, reusable, and short, and it charts a concrete program toward resource-aware pseudo-metrics, tightness lower bounds, the Minicrypt/Cryptomania divide, tree-indexed hybrids, and a Fourier-analytic Goldreich–Levin reduction.
