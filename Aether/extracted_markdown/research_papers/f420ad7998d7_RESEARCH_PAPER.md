# The Thermodynamic Proof System: Landauer and Bennett Principles as Theorems of Finite Information Theory

## Abstract

We develop a self-contained mathematical framework — the **Thermodynamic Proof
System (TPS)** — that models logical proof as a physical, entropy-reducing process and
derives the fundamental energetic limits on proving as theorems of pure finite
information theory. The framework rests on a first-principles formalization of Shannon
entropy `H(p) = −∑ₓ p(x) log p(x)` over distributions on a finite type, including the
non-negativity of entropy, additivity over independent product distributions, the value
`log n` of the uniform distribution, and the maximum-entropy theorem `H(p) ≤ log n`
proved via concave Jensen's inequality. On this substrate we model a *belief state* as a
finite probability distribution, a *proof* as a transition `p ⇝ q` that reduces
uncertainty, and define its **Landauer cost** at temperature `T` as
`T · (H(p) − H(q))`. Our main results are: (i) a fully determined ("proven") state has
zero entropy; (ii) **Bennett's principle** — relabelling microstates by any permutation
leaves entropy invariant and therefore costs no energy; (iii) a second-law statement —
genuine uncertainty reduction never returns energy at non-negative temperature; (iv) the
**fundamental Landauer bound** — the cost of resolving any prior to a determined
conclusion over an `n`-state world is at most `T · log n`; (v) its **tightness** —
starting from the uniform prior the cost is exactly `T · log n`; and (vi) the
corresponding count in **bits**, `log₂ n`. The unifying insight is that the
maximum-entropy theorem is simultaneously the bound on how much a proof can learn and the
Landauer bound on the energy a computation must dissipate; reversible (bijective) steps
sit precisely on the boundary `ΔH = 0`. All results have been verified in the Lean 4
proof assistant with no remaining gaps.

**Keywords:** Shannon entropy, Landauer's principle, Bennett's principle, reversible
computation, maximum entropy, proof complexity, information thermodynamics.

---

## 1. Introduction

Three foundational threads of twentieth-century science meet in this paper.

The first is **Shannon's information theory** (1948), which quantified uncertainty
through the entropy functional `H(p) = −∑ₓ p(x) log p(x)` and established the
maximum-entropy principle: among all distributions on a finite set of `n` outcomes, the
uniform distribution is the most uncertain, with entropy exactly `log n`.

The second is the **thermodynamics of computation**: Landauer's principle (1961), that
the *irreversible* erasure of one bit of information must dissipate at least `kT ln 2`
of energy as heat; and Bennett's principle (1973), that *logically reversible*
computation carries, in principle, no irreducible energy cost. Together they locate the
thermodynamic price of computation not in computing per se but in forgetting.

The third is the view of **proof as an epistemic process**. To prove a proposition is to
move from a state of uncertainty — the proposition might hold, or fail, or be
independent — to a determined state in which the answer is fixed. This is, structurally,
an act of erasure.

The central thesis of this paper is that these three threads describe a single object.
We model the answer space as a finite type `α` of *epistemic microstates*; a state of
knowledge as a probability distribution over `α`; and a proof as a transition between
such states. We then show that the energetic cost of proving, defined as temperature
times entropy reduction, obeys exactly the Landauer and Bennett laws, and that the
governing inequality is the Shannon maximum-entropy theorem read in two directions at
once. Every statement below is a theorem with a complete formal proof.

The contribution is twofold. First, a clean axiom-light formalization of finite Shannon
entropy with its four cornerstone results. Second, a derivation of the
thermodynamics-of-proof bounds — determinism, reversibility, the second law, the
Landauer capacity, its tightness, and the bit count — as corollaries of that
information-theoretic core, with temperature entering only as a non-negative scalar.

---

## 2. The information-theoretic substrate

We work throughout with a finite type `α` (`Fintype α`), and real-valued weight
functions `p : α → ℝ`.

### 2.1 Definition (Shannon entropy)

Using Mathlib's `Real.negMulLog x = −x · log x`, which already encodes the convention
`0 · log 0 = 0`, define the **entropy** of a finite weight function by

> **H(p) := ∑ₓ negMulLog(p x) = −∑ₓ p(x) · log p(x).**

### 2.2 Definition (probability distribution)

A weight function `p : α → ℝ` is a **probability distribution**, written
`IsProbDist p`, when

1. `p(x) ≥ 0` for all `x` (non-negativity), and
2. `∑ₓ p(x) = 1` (normalization).

### 2.3 Theorem (non-negativity of entropy)

*If `0 ≤ p(x) ≤ 1` for all `x`, then `0 ≤ H(p)`.*

**Proof sketch.** Each summand `negMulLog(p x) = −p(x) log p(x)` is non-negative when
`p(x) ∈ [0,1]`, since `log p(x) ≤ 0` there (Mathlib's `Real.negMulLog_nonneg`). A finite
sum of non-negative terms is non-negative. ∎

### 2.4 Theorem (additivity over independent distributions)

*Let `p` on `α` and `q` on `β` satisfy `∑ₓ p(x) = 1` and `∑_y q(y) = 1`. For the
product distribution `(x,y) ↦ p(x) · q(y)` on `α × β`,*

> **H(p ⊗ q) = H(p) + H(q).**

**Proof sketch.** Expand each term using the multiplicativity identity
`negMulLog(p·q) = q · negMulLog(p) + p · negMulLog(q)` (Mathlib's `Real.negMulLog_mul`).
Reindex the sum over `α × β` as an iterated sum over `α` and `β`. Factoring and using
the two normalizations `∑ p = ∑ q = 1` collapses the cross terms, leaving exactly
`H(p) + H(q)`. ∎

This is the precise sense in which entropy is *extensive*: independent systems' uncertainties add.

### 2.5 Theorem (entropy of the uniform distribution)

*For a non-empty `α` with `|α| = n`, the uniform distribution `u(x) = 1/n` has*

> **H(u) = log n.**

**Proof sketch.** Every term equals `negMulLog(1/n) = (1/n) log n`; summing the `n`
identical terms (using `n > 0` from non-emptiness) yields `log n`. ∎

### 2.6 Theorem (maximum-entropy theorem)

*For any probability distribution `p` on a non-empty `α` with `|α| = n`,*

> **H(p) ≤ log n,**

*with equality for the uniform distribution.*

**Proof sketch.** Apply Jensen's inequality to the concave function `negMulLog`
(Mathlib's `Real.concaveOn_negMulLog`) with uniform weights `wᵢ = 1/n`:

> (1/n) ∑ᵢ negMulLog(pᵢ) ≤ negMulLog( (1/n) ∑ᵢ pᵢ ) = negMulLog(1/n) = (1/n) log n,

where the middle equality uses normalization `∑ pᵢ = 1`. Multiplying through by `n` gives
`H(p) ≤ log n`. Equality at the uniform distribution follows from §2.5. ∎

Theorems §2.5 and §2.6 together formalize the slogan *uniform = maximal uncertainty*:
the uniform distribution is the unique maximizer, and its value `log n` is the
information capacity of an `n`-state world.

---

## 3. The Thermodynamic Proof System

We now overlay the thermodynamic interpretation. The type `α` is reinterpreted as a
finite space of *epistemic microstates* — the possible answers to a question. A
probability distribution is a *belief state*.

### 3.1 Definition (determined state / point mass)

For `a : α` (with decidable equality), the **point mass** at `a` is

> **pointMass(a)(x) := 1 if x = a, else 0.**

This represents a proposition resolved (proven) to the value `a`: all belief is
concentrated on a single answer.

### 3.2 Definition (Landauer cost of a proof)

A **proof** is a transition from belief state `p` to belief state `q`. Its
**thermodynamic (Landauer) cost** at temperature `T` is

> **landauerCost(T, p, q) := T · ( H(p) − H(q) ).**

Setting Boltzmann's constant `k = 1` and measuring entropy in nats, this is the energy
that must be dissipated to collapse the uncertainty from `p` to `q`, in the spirit of
Landauer's `kT ln 2` per erased bit.

### 3.3 Theorem (determined states are distributions)

*`pointMass(a)` is a probability distribution: its weights are non-negative and sum to one.*

**Proof sketch.** Each weight is `0` or `1`, hence non-negative; exactly one weight (at
`x = a`) equals `1` and the rest are `0`, so the sum is `1`. ∎

### 3.4 Theorem (a proven proposition carries no uncertainty)

> **H(pointMass(a)) = 0.**

**Proof sketch.** Every summand of `H(pointMass(a))` is either `negMulLog(1) = 0` or
`negMulLog(0) = 0`, so the total is `0`. ∎

This is the endpoint of every complete proof: zero entropy is the formal meaning of
"the answer is known."

### 3.5 Theorem (Bennett's principle, entropy form)

*For any bijection `σ : α ≃ β` and any `p : α → ℝ`,*

> **H( b ↦ p(σ⁻¹ b) ) = H(p).**

**Proof sketch.** Relabelling the microstates by `σ` merely reindexes the entropy sum;
since a finite sum is invariant under any bijective reindexing
(Mathlib's `Equiv.sum_comp`), the value is unchanged. ∎

### 3.6 Theorem (Bennett's principle, energy form)

*For any permutation `σ` of `α`, any temperature `T`, and any `p`,*

> **landauerCost(T, p, p∘σ⁻¹) = 0.**

**Proof sketch.** By §3.5 the two belief states have equal entropy, so
`T · (H(p) − H(p)) = T · 0 = 0`, for any `T`. ∎

A logically reversible step — one that only permutes microstates and destroys nothing —
costs no energy at any temperature. This is Bennett's principle as a theorem: the cost
lives entirely in *irreversible* erasure, never in reversible rearrangement.

### 3.7 Theorem (second-law flavour)

*If `T ≥ 0` and the proof genuinely reduces uncertainty (`H(q) ≤ H(p)`), then*

> **0 ≤ landauerCost(T, p, q).**

**Proof sketch.** `H(p) − H(q) ≥ 0` and `T ≥ 0`, so their product is non-negative. ∎

A real proof never returns energy; uncertainty destroyed is paid for, never refunded.

### 3.8 Theorem (the fundamental Landauer bound for proofs)

*Let `α` be non-empty with `|α| = n`, let `T ≥ 0`, and let `p` be any probability
distribution. For any conclusion `a`,*

> **landauerCost(T, p, pointMass(a)) ≤ T · log n.**

**Proof sketch.** By §3.4, `H(pointMass(a)) = 0`, so the cost is `T · H(p)`. By the
maximum-entropy theorem §2.6, `H(p) ≤ log n`. Multiplying by `T ≥ 0` (monotonicity)
gives the bound. ∎

The `n`-state epistemic world has a finite **information capacity**: no proof over it can
cost more than `T · log n`, because no distribution over it can carry more than `log n`
of uncertainty.

### 3.9 Theorem (tightness of the Landauer bound)

*Under the same hypotheses, starting from the uniform prior `u(x) = 1/n`,*

> **landauerCost(T, u, pointMass(a)) = T · log n.**

**Proof sketch.** By §2.5, `H(u) = log n`; by §3.4, `H(pointMass(a)) = 0`; so the cost
is `T · (log n − 0) = T · log n`. ∎

Combined with §3.8, the capacity `T · log n` is *sharp*: it is exactly the cost of
resolving complete (uniform) uncertainty.

### 3.10 Theorem (Landauer bound in bits)

*At unit temperature, resolving the uniform prior over `n` worlds costs*

> **landauerCost(1, u, pointMass(a)) = log 2 · log₂ n,**

*that is, exactly `log₂ n` bits.*

**Proof sketch.** By §3.9 at `T = 1` the cost is `log n` nats. The change of base
`log n = log 2 · log₂ n` rewrites this as `log₂ n` bits. In physical units where a bit
costs `kT ln 2`, this is the canonical Landauer count. ∎

---

## 4. The unifying observation

The maximum-entropy theorem §2.6 plays two roles at once:

- **Epistemic.** It bounds how much a proof can learn: at most `log n` of certainty can
  be extracted from an `n`-state world.
- **Physical.** It is the Landauer bound on heat dissipation: at most `T · log n` of
  energy is ever needed (and exactly that much from maximal ignorance) to reach a
  definite answer.

These are not two coincidentally similar formulas; they are a single inequality applied
on two interpretations of the same structure. "Proving a proposition" and "erasing a
bit" are the same operation — driving entropy down — and the same theorem governs both.
Reversible (bijective) steps sit exactly on the boundary `ΔH = 0` (§3.5–3.6), where no
energy is spent. Everything irreversible lies above it.

This dictionary can be summarized:

| Information theory | Thermodynamics | Proof |
|---|---|---|
| distribution `p` | macrostate / occupation | belief state |
| entropy `H(p)` | thermodynamic entropy | uncertainty |
| point mass | pure state | proven conclusion |
| `H = 0` | zero-entropy ground state | certainty |
| `H ≤ log n` | maximal disorder bound | learnable-information bound |
| permutation of states | reversible operation | reversible inference step |
| entropy reduction | bit erasure | act of proof |
| `T · ΔH` | dissipated heat | cost of proof |

---

## 5. Worked examples

The abstract bounds become tangible on small state spaces, and these examples also serve
as regression checks for the accompanying code.

**The single bit (`n = 2`).** Consider a yes/no question with answer space
`α = {0, 1}`. In total ignorance the belief state is the uniform prior `u = (½, ½)`. Its
entropy is

> H(u) = negMulLog(½) + negMulLog(½) = 2 · (½ · log 2) = log 2 ≈ 0.6931 nats.

This equals `log 2 = 1 · log 2`, i.e. exactly one bit, confirming §2.5 and §3.10 at
`n = 2`. To *prove* the answer is, say, `0`, we collapse `u` to `pointMass(0) = (1, 0)`,
whose entropy is `0` by §3.4. At unit temperature the cost is
`landauerCost(1, u, (1,0)) = log 2 − 0 = log 2` — one bit erased, the smallest nonzero
proof. Had we started from a biased prior `p = (0.9, 0.1)`, its entropy
`H(p) ≈ 0.3251` nats is below the capacity `log 2 ≈ 0.6931`, so the proof costs only
`≈ 0.3251` nats: a partially decided question is cheaper to finish, exactly as §3.8
predicts.

**A byte's worth of answers (`n = 256`).** The capacity is
`log 256 = 8 · log 2 ≈ 5.545` nats, i.e. eight bits. Resolving the uniform prior over all
256 possibilities to a single determined value costs precisely `T · log 256`; at unit
temperature that is eight bits of erasure (§3.9–3.10). This is the familiar statement that
identifying one byte requires eight binary decisions, here recovered as a thermodynamic
cost.

**A reversible reformulation.** Take any prior `p` on `n = 6` outcomes and apply a random
permutation `σ` of the labels to obtain `q(x) = p(σ⁻¹ x)`. By §3.5, `H(q) = H(p)` to
machine precision, so `landauerCost(T, p, q) = 0` for every `T` (§3.6). Reordering the
hypotheses of an argument, renaming variables, or any other bijective bookkeeping is
thermodynamically free; only the irreversible collapse to a conclusion is charged.

**Additive independent systems.** For `p = (0.6, 0.4)` and `q = (0.5, 0.3, 0.2)`, direct
computation gives `H(p) ≈ 0.6730`, `H(q) ≈ 1.0297`, and the product distribution on the
six joint outcomes has entropy `≈ 1.7027 = H(p) + H(q)`, witnessing §2.4. Independent
uncertainties simply add.

## 6. Algorithms

The framework is fully computational over rational or floating-point distributions. We
describe the core procedures used in the accompanying demonstration code.

### 6.1 Entropy evaluation

Given a finite distribution `p = (p₁, …, pₙ)`, compute `H(p) = −∑ᵢ pᵢ log pᵢ` using the
convention `0 · log 0 = 0`. Complexity `O(n)`.

### 6.2 Landauer-cost evaluation

Given temperature `T` and two distributions `p, q`, return `T · (H(p) − H(q))`. Combined
with §6.1, complexity `O(n)`.

### 6.3 Maximum-entropy verification

Given any distribution `p` over `n` outcomes, verify `H(p) ≤ log n` numerically and
compare against the uniform distribution, which attains the maximum. This empirically
witnesses Theorems §2.5–2.6.

### 6.4 Bit-count conversion

Convert a cost in nats to bits via division by `log 2`, witnessing §3.10. For a uniform
prior over `n` outcomes at unit temperature, the result is `log₂ n` bits exactly.

---

## 7. Applications

- **Lower bounds for decision procedures.** Any algorithm that resolves a uniformly
  uncertain `n`-way question must, by §3.9, dissipate at least `T · log n` of energy in
  any physical realization that erases its uncertainty — independent of the algorithm.

- **Reversible-computation accounting.** §3.5–3.6 give a clean criterion: a step is
  thermodynamically free iff it acts as a permutation of microstates. This is a usable
  rule for designing low-power reversible pipelines.

- **Entropy budgeting for inference.** Treating a multi-step argument as a sequence of
  belief states, the total cost telescopes to `T · (H_initial − H_final)`, so only net
  uncertainty reduction is charged. Intermediate reversible reformulations are free.

- **Information capacity of state spaces.** §3.8 quantifies the maximum resolvable
  uncertainty of any finite model as `log n`, a hard ceiling on what observation or
  proof over that model can ever determine.

---

## 8. Discussion

The framework is deliberately minimal: temperature enters only as a non-negative scalar
multiplier, and all the mathematical content lives in the finite-entropy core of §2.
This minimality is a feature — it shows that the Landauer and Bennett principles, in
their information-theoretic form, require no thermodynamic machinery beyond the
maximum-entropy theorem.

A subtlety worth recording concerns units. An early formulation of the bit-count result
scaled the cost by `T = log 2`, which double-counts the nats-to-bits conversion and
yields the incorrect `(log 2) · log n`. The correct statement (§3.10) takes `T = 1` so
that the cost is `log n` nats, equal to `log 2 · log₂ n` — exactly `log₂ n` bits. The
`0 · log 0 = 0` convention and the need for decidable equality on point masses are both
absorbed cleanly by routing all computation through `negMulLog`.

The framework treats *static* belief states and single transitions. The natural next
layer — adaptive, multi-round observation, where each step's measurement depends on the
outcomes of previous steps — is where information-theoretic and thermodynamic accounting
become genuinely interactive, and is the subject of ongoing work (§9).

---

## 9. Future work

See the accompanying "Future Directions" material, which lays out the *observation gap*
program: extending the static, single-transition model to **adaptive observation
systems** with information-theoretic bounds, and a parallel line on the
**Fibonacci rank-of-apparition** function `z(m)`, including the conjecture that `z` is a
lattice homomorphism `z(lcm(a,b)) = lcm(z(a), z(b))`.

Concretely, promising directions include: (i) a chain rule for multi-step proofs giving
`landauerCost(T, p₀ ⇝ pₖ) = ∑ landauerCost` over reversible/irreversible step
classification; (ii) conditional and mutual-information refinements of the capacity
bound for proofs that learn only part of the answer; (iii) continuous (differential
entropy) analogues; and (iv) tightening the second law into a fluctuation-style equality
for randomized proof procedures.

---

## 10. Conclusion

We have shown that proving a proposition, erasing a bit, and reducing Shannon entropy are
the same operation, and that the fundamental limits on all three are captured by a single
inequality — the maximum-entropy theorem — together with two definitions: entropy and
Landauer cost. Determined states carry zero entropy; reversible steps are free; genuine
proofs never refund energy; and the cost of resolving complete uncertainty over `n`
possibilities is exactly `T · log n`, or `log₂ n` bits. Certainty has a price, and that
price is now a theorem.
