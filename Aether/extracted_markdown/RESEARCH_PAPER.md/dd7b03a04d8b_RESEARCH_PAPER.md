# The Polynomial VC Growth Bound: From Sauer–Shelah to a Single Monomial

## Abstract

We present a self-contained development of the classical
Vapnik–Chervonenkis (VC) growth-function bound in its most usable form:
a set family `𝒜` on an `n`-element ground set with VC dimension `d`
satisfies `|𝒜| ≤ (n+1)ᵈ`. The semantic-to-counting half of this
statement — that bounded shattering caps the number of realizable
behaviors by a truncated binomial sum `∑_{k=0}^{d} C(n,k)` — is the
Sauer–Shelah lemma. The contribution isolated here is the *missing
combinatorial-to-polynomial step*: a clean inequality

`∑_{k=0}^{d} C(n,k) ≤ (n+1)ᵈ`

that collapses the partial binomial sum into a single monomial, after
which the textbook growth bound follows by composition. We give the
inequality and its short inductive proof, derive the polynomial bound for
the shatterer, for the family itself, and in the hypothesis form used in
learning theory, and prove a qualitative polynomial-vs-exponential
separation: once `(n+1)ᵈ < 2ⁿ`, a VC-dimension-`d` family cannot be the
full powerset. We discuss the algorithmic content (computing VC dimension
and verifying the bound), applications to generalization theory via the
identity `log|𝒜| ≤ d·log(n+1)`, and a research program extending the
result toward Rademacher complexity.

**Keywords:** VC dimension, Sauer–Shelah lemma, shattering, growth
function, binomial coefficients, statistical learning theory,
generalization bounds.

---

## 1. Introduction

A central quantitative object of statistical learning theory is the
*growth function* of a hypothesis class: the maximum number of distinct
labelings the class can realize on a sample of `n` points. On `n` points
there are `2ⁿ` conceivable labelings, yet structured classes realize far
fewer. The Vapnik–Chervonenkis theory explains exactly how much fewer: a
class whose VC dimension is `d` realizes at most polynomially many — on the
order of `nᵈ` — labelings. This polynomial ceiling, contrasted with the
exponential `2ⁿ` of arbitrary labelings, is the combinatorial engine
behind uniform convergence and hence behind learnability itself.

The bound is usually obtained in two stages. The first, semantic stage is
the **Sauer–Shelah lemma**: VC dimension `d` implies a count bounded by the
truncated binomial sum `∑_{k≤d} C(n,k)`. This is the difficult and famous
step, and it is available in mature form in the Mathlib library as
`Finset.card_shatterer_le_sum_vcDim`, alongside Pajor's inequality
`Finset.card_le_card_shatterer`. The second stage, often glossed over as
"clearly polynomial," is the purely arithmetic estimate that turns the sum
into a monomial. It is this second stage that we isolate, prove cleanly,
and chain to the first to obtain the growth bound in the exact form used
downstream.

### 1.1 Contributions

1. The binomial partial-sum inequality `∑_{k≤d} C(n,k) ≤ (n+1)ᵈ`
   (Theorem 3.1), with a three-line induction.
2. The polynomial growth bound for the shatterer, the family, and the
   hypothesis form (Theorems 4.1, 4.2, 4.3).
3. A qualitative separation theorem: bounded VC dimension forbids the full
   powerset whenever the polynomial gap opens (Theorem 5.1).
4. The retained sharp form `|𝒜| ≤ ∑_{k≤d} C(n,k)` as an intermediate
   strengthening (Theorem 4.4).

All results are stated over a finite type `α` with `n = |α|` and a set
family `𝒜 : Finset (Finset α)` with VC dimension `d = vcDim(𝒜)`.

---

## 2. Definitions

Throughout, `α` is a finite type and `n := |α|` is its cardinality. A
*set family* is a finite collection `𝒜` of subsets of `α`.

**Definition 2.1 (Shattering).** A subset `s ⊆ α` is *shattered* by `𝒜`
if every subset `t ⊆ s` arises as a trace `t = s ∩ a` for some `a ∈ 𝒜`.
Equivalently, the trace map `a ↦ s ∩ a` restricted to `𝒜` is onto the
powerset of `s`. When `s` is shattered, `𝒜` realizes all `2^{|s|}`
possible labelings of the points of `s`.

**Definition 2.2 (Shatterer).** The *shatterer* of `𝒜`, written
`shatterer(𝒜)`, is the family of all subsets of `α` that are shattered by
`𝒜`.

**Definition 2.3 (VC dimension).** The *Vapnik–Chervonenkis dimension*
`vcDim(𝒜)` is the cardinality of the largest set shattered by `𝒜`:
`vcDim(𝒜) = max { |s| : s ∈ shatterer(𝒜) }`.

**Definition 2.4 (Growth function).** The *growth function* of `𝒜` is its
cardinality `|𝒜|`, viewed as the number of distinct realizable behaviors.
(In the sample-relative formulation one counts traces on a fixed sample;
here `α` itself plays the role of the sample, and `|𝒜|` counts distinct
members.)

**Definition 2.5 (Binomial partial sum).** For `n, d ∈ ℕ`, the partial sum
of binomial coefficients is `S(n,d) := ∑_{k=0}^{d} C(n,k)`, where `C(n,k)`
is the binomial coefficient "n choose k."

We use the standard background facts: `C(n,0) = 1`; `C(n,k) ≤ nᵏ`
(`Nat.choose_le_pow`); and `∑_{k=0}^{n} C(n,k) = 2ⁿ`.

**Definition 2.6 (Trace).** For a family `𝒜` and a set `s`, the *trace* of
`𝒜` on `s` is the family `𝒜|ₛ := { s ∩ a : a ∈ 𝒜 }` of distinct
intersections. The trace is the set of *behaviors* `𝒜` realizes on `s`; it
is a subfamily of the powerset `𝒫(s)`, hence `|𝒜|ₛ| ≤ 2^{|s|}`, and `s` is
shattered precisely when this last inequality is an equality.

### 2.1 Notation and conventions

All cardinalities are of finite sets; `|X|` denotes cardinality. We write
`𝒫(α)` for the powerset of `α` as a finite family, so that
`|𝒫(α)| = 2ⁿ`. Logarithms in Section 7 are natural unless flagged.
Throughout, the ground type `α` carries decidable equality and is a
finite type, which is what makes shattering, the shatterer, and the VC
dimension all *computable* objects (Section 6). The convention
`vcDim(𝒜) = 0` when `𝒜` shatters no nonempty set makes every statement
below unconditional in `d`.

---

## 3. The binomial partial-sum bound

The technical core of the development is the following inequality, which
converts the Sauer–Shelah binomial sum into a single polynomial.

**Theorem 3.1 (Binomial partial-sum bound).**
For all `n, d ∈ ℕ`,
```
∑_{k=0}^{d} C(n,k) ≤ (n+1)ᵈ.
```

*Proof sketch.* Induct on `d`, with `n` arbitrary.

- **Base case `d = 0`.** The left side is `C(n,0) = 1` and the right side
  is `(n+1)⁰ = 1`, so `1 ≤ 1`.

- **Inductive step.** Assume `∑_{k=0}^{d} C(n,k) ≤ (n+1)ᵈ` (for every `n`).
  Split off the new top term:
  ```
  ∑_{k=0}^{d+1} C(n,k) = ( ∑_{k=0}^{d} C(n,k) ) + C(n, d+1).
  ```
  Bound the running tail by the inductive hypothesis,
  `∑_{k=0}^{d} C(n,k) ≤ (n+1)ᵈ`, and bound the new term using
  `C(n, d+1) ≤ n^{d+1} = n · nᵈ ≤ n · (n+1)ᵈ` (monotonicity of the power
  base together with `Nat.choose_le_pow`). Adding,
  ```
  ∑_{k=0}^{d+1} C(n,k) ≤ (n+1)ᵈ + n·(n+1)ᵈ = (1 + n)·(n+1)ᵈ = (n+1)^{d+1},
  ```
  closing the induction. ∎

The proof is entirely finitary, using only the recurrence structure of the
sum, monotonicity of `m ↦ mᵈ`, and the elementary estimate
`C(n,k) ≤ nᵏ`. No real analysis is required; the inequality lives in `ℕ`.

**Remark 3.2 (Sharpness regime).** The bound is loose by design: it trades
sharpness for a single clean monomial. The sum `S(n,d)` is genuinely
smaller than `(n+1)ᵈ` for `d ≥ 1`, which is why Theorem 4.4 (the retained
sum form) is a strict strengthening. The optimal *entropy* refinement
replaces `(n+1)ᵈ` by `(e·n/d)ᵈ` for `1 ≤ d ≤ n`; see Section 8.

---

## 4. The polynomial VC growth bound

We now chain Theorem 3.1 with the Sauer–Shelah lemma and Pajor's
inequality. We write `n = |α|` and `d = vcDim(𝒜)`.

**Theorem 4.1 (Polynomial Sauer–Shelah for the shatterer).**
```
|shatterer(𝒜)| ≤ (n+1)^{vcDim(𝒜)}.
```

*Proof sketch.* The Sauer–Shelah lemma in counting form gives
`|shatterer(𝒜)| ≤ ∑_{k≤ vcDim(𝒜)} C(n,k)`. Apply Theorem 3.1 with
`d = vcDim(𝒜)` to the right side. ∎

**Theorem 4.2 (VC growth bound).**
```
|𝒜| ≤ (n+1)^{vcDim(𝒜)}.
```

*Proof sketch.* Pajor's inequality gives `|𝒜| ≤ |shatterer(𝒜)|`.
Compose with Theorem 4.1. ∎

**Theorem 4.3 (Growth bound, hypothesis form).**
If `vcDim(𝒜) ≤ d`, then
```
|𝒜| ≤ (n+1)ᵈ.
```

*Proof sketch.* From Theorem 4.2, `|𝒜| ≤ (n+1)^{vcDim(𝒜)}`. Since the base
`n+1 ≥ 1`, the map `m ↦ (n+1)ᵐ` is monotone, so `(n+1)^{vcDim(𝒜)} ≤ (n+1)ᵈ`
whenever `vcDim(𝒜) ≤ d`. ∎

This is the form used in practice: one typically knows an a priori ceiling
`d` on the VC dimension of a hypothesis class rather than its exact value.

**Theorem 4.4 (Sharp intermediate bound).**
```
|𝒜| ≤ ∑_{k=0}^{vcDim(𝒜)} C(n,k).
```

*Proof sketch.* Compose Pajor's inequality `|𝒜| ≤ |shatterer(𝒜)|` with the
Sauer–Shelah counting bound directly, without invoking Theorem 3.1. This is
strictly sharper than Theorem 4.2, since `∑_{k≤d} C(n,k) ≤ (n+1)ᵈ` with
strict inequality for `d ≥ 1`. ∎

---

## 5. Polynomial-versus-exponential separation

The growth bound has a striking qualitative corollary: a family of bounded
VC dimension cannot exhaust the powerset once the polynomial ceiling falls
below the exponential one.

**Theorem 5.1 (Bounded VC dimension forbids the full powerset).**
Suppose `vcDim(𝒜) ≤ d` and the gap condition `(n+1)ᵈ < 2ⁿ` holds. Then
```
𝒜 ≠ 𝒫(α),
```
i.e. `𝒜` is not the entire family of all subsets of `α`.

*Proof sketch.* Argue by contraposition. If `𝒜` were the full powerset,
then `|𝒜| = 2ⁿ`. But Theorem 4.3 forces `|𝒜| ≤ (n+1)ᵈ`, whence
`2ⁿ ≤ (n+1)ᵈ`, contradicting the gap hypothesis `(n+1)ᵈ < 2ⁿ`. Therefore
`𝒜` cannot be the full powerset. ∎

**Remark 5.2 (When the gap opens).** For any fixed `d`, the inequality
`(n+1)ᵈ < 2ⁿ` holds for all sufficiently large `n`, since the exponential
`2ⁿ` outgrows every fixed polynomial `(n+1)ᵈ`. Thus, for large samples,
*every* family of bounded VC dimension is strictly poorer than the full
powerset. This is the precise polynomial-vs-exponential phase transition
governed by the VC dimension.

---

## 5b. Worked examples

We instantiate the bounds on three families that recur in computational
geometry and learning theory. In each case `n` is the ground-set size,
`d = vcDim`, and we compare the realized size `|𝒜|`, the Sauer–Shelah sum
`S(n,d)`, the polynomial ceiling `(n+1)ᵈ`, and the powerset `2ⁿ`.

**Example A (thresholds, `d = 1`).** Let the ground set be `{0,…,n−1}` and
let `𝒜` consist of the `n+1` down-sets `{0,…,j−1}` for `0 ≤ j ≤ n`. Any
single point is shattered (it can be in or out), but no two points
`i < j` are shattered, since no threshold puts `j` in while leaving `i`
out. Hence `d = 1`, and `|𝒜| = n+1`, which meets the bound `(n+1)¹ = n+1`
exactly. Thresholds are the extremal example showing the growth bound is
tight for `d = 1`.

**Example B (intervals, `d = 2`).** Let `𝒜` be all discrete intervals
`{i,…,j}` (with the empty interval) on `{0,…,n−1}`. Two points are
shattered — an interval can include either, both, or neither — but no
three points `i < j < k` are, since an interval containing `i` and `k`
must contain `j`. So `d = 2`, `|𝒜| = 1 + C(n+1,2)`, and the polynomial
bound reads `|𝒜| ≤ (n+1)²`. For `n = 8`: `|𝒜| = 37`, `S(8,2) = 37`,
`(8+1)² = 81`, `2⁸ = 256`. The realized size equals the Sauer–Shelah sum
here, and both sit comfortably below the polynomial ceiling, which sits
below the powerset.

**Example C (axis-aligned rectangles, `d = 4`).** Encode an `m × m`
integer grid as `n = m²` ground points and let `𝒜` be the family of
axis-aligned rectangles. Four points in "diamond" position can be
shattered, but no five can, so `d = 4`. For `m = 3` (`n = 9`): the
realized `|𝒜| = 37`, `S(9,4) = 256`, `(9+1)⁴ = 10000`, `2⁹ = 512`. This
example also illustrates Remark 5.2's caveat: when `n` is small relative
to `d`, the polynomial ceiling `(n+1)ᵈ` can *exceed* `2ⁿ` (here
`10000 > 512`), so the separation of Section 5 only bites for larger `n`.
The always-valid chain `|𝒜| ≤ S(n,d) ≤ (n+1)ᵈ` (Theorems 4.4 and 3.1)
still holds: `37 ≤ 256 ≤ 10000`.

These examples are reproduced numerically in the accompanying demo, which
computes the VC dimension by exhaustive shattering search and checks every
inequality in the chain.

## 6. Algorithms

The development is constructive over finite data and yields directly
implementable procedures.

**Algorithm 6.1 (Partial binomial sum).** Compute
`S(n,d) = ∑_{k=0}^{d} C(n,k)` by accumulating binomial coefficients. This
is the left-hand side of Theorem 3.1; comparing it against `(n+1)ᵈ`
numerically verifies the inequality for any concrete `(n,d)`.

```
function partial_binomial_sum(n, d):
    total = 0
    for k in 0..d:
        total += binomial(n, k)
    return total
```

**Algorithm 6.2 (Shattering test).** Given a family `𝒜` of subsets of an
`n`-element ground set and a candidate set `s`, decide whether `s` is
shattered: form the trace set `{ s ∩ a : a ∈ 𝒜 }` and check that it equals
the powerset of `s` (i.e. has `2^{|s|}` elements, all subsets of `s`).

```
function shatters(family, s):
    traces = { frozenset(s & a) for a in family }
    return len(traces) == 2 ** len(s)
```

**Algorithm 6.3 (VC dimension by search).** Compute `vcDim(𝒜)` by testing
shattering of candidate subsets in order of decreasing size and returning
the size of the first shattered set found (or `0` if none of positive
size). Practical enumeration restricts attention to subsets of the union of
`𝒜`. Once `d = vcDim(𝒜)` is known, the growth bound `(n+1)ᵈ` of
Theorem 4.2 can be reported and compared with the realized size `|𝒜|` and
the exponential ceiling `2ⁿ`.

These three procedures together let one *measure* the VC dimension of a
concrete family and *witness* the chain
`|𝒜| ≤ S(n,d) ≤ (n+1)ᵈ ≤ 2ⁿ` of Theorems 4.4, 3.1, and the separation of
Section 5 on explicit examples (intervals, halfplanes, axis-aligned
rectangles).

---

## 7. Applications to generalization theory

The growth bound is the combinatorial input to uniform convergence. Taking
logarithms of Theorem 4.3,
```
log |𝒜| ≤ d · log(n+1),
```
which exhibits `d · log(n+1)` as the *effective complexity* of the class —
the quantity that plays the role of "number of parameters" in
generalization theorems. Concretely:

- **Uniform convergence.** Classical VC theory shows that, with `n`
  i.i.d. samples, the gap between empirical and true error of every
  hypothesis in a class of VC dimension `d` is, with high probability,
  `O( √( (d log(n/d)) / n ) )`. The growth bound is precisely what makes
  the union bound over realizable behaviors polynomial rather than
  exponential, so that the failure probability is controllable.

- **Sample complexity.** To achieve error `ε`, it suffices to take
  `n = O( (d/ε²) · log(1/ε) )` samples — linear in the VC dimension. The
  polynomial growth bound is the step that converts "finitely many
  behaviors" into this concrete, dimension-driven sample size.

- **Occam-style bounds.** Because `log |𝒜| ≤ d log(n+1)` grows only
  logarithmically in `n`, a hypothesis that fits the training data is
  forced to generalize: there are too few realizable behaviors for a good
  empirical fit to be coincidental.

The separation theorem (Section 5) is the structural counterpart: it
formalizes the intuition that a learnable class is *strictly* poorer than
the space of all labelings, which is exactly what prevents memorization of
arbitrary (including adversarial or noisy) labelings.

---

## 8. Discussion and future work

The development isolates the one arithmetic step — Theorem 3.1 — that the
literature usually treats as folklore, and shows that it is the precise
hinge between the semantic Sauer–Shelah lemma and the polynomial growth
bound used throughout learning theory. Several extensions build directly on
the stated declarations.

**8.1 Entropy sharpening `(en/d)ᵈ`.** Replace the crude `(n+1)ᵈ` with the
optimal binary-entropy bound `∑_{k≤d} C(n,k) ≤ (e·n/d)ᵈ` for `1 ≤ d ≤ n`.
The idea is to inflate each term `C(n,k)` by `(n/d)^{d-k} ≥ 1`, summing the
truncated series up to the full binomial expansion `(1 + d/n)ⁿ · (n/d)ᵈ`,
and then use `(1 + d/n)ⁿ ≤ eᵈ`. Chaining with Theorem 4.4 upgrades
Theorem 4.2 to the form yielding the optimal `O(√(d log(n/d)/n))`
generalization rate.

**8.2 Matching lower bound `2ᵈ`.** Complement the upper bounds with the
lower bound: if `𝒜` shatters some `s` with `|s| = d`, then the trace family
`{ s ∩ a : a ∈ 𝒜 }` has exactly `2ᵈ` elements, since shattering is
definitionally a surjection of the trace onto the powerset of `s`. Together
with Theorem 4.2 this pins the growth function between `2ᵈ` and `(n+1)ᵈ`,
making the separation of Section 5 two-sided.

**8.3 Massart's finite lemma.** With `log |𝒜| ≤ d log(n+1)` in hand, define
the empirical Rademacher complexity of a finite set `A ⊆ ℝⁿ` and prove
Massart's lemma `R̂(A) ≤ c√(2 log m / n)` for `|A| = m`, `max ‖a‖₂ ≤ c`.
This follows from Hoeffding's inequality applied to the moment generating
function of the Rademacher average, then optimizing the exponential
parameter — a discrete computation over the cube `{-1,+1}ⁿ`.

**8.4 Contraction principle.** Formalize the Ledoux–Talagrand contraction
principle: for `L`-Lipschitz `φ` with `φ(0) = 0`, the Rademacher complexity
of `{φ∘f : f ∈ F}` is at most `L · R(F)`. In the discrete setting this is a
clean inequality about weighted sums of Rademacher signs and extends the
bounds from linear to nonlinear (e.g. neural) classes.

**8.5 Margin and kernel bounds.** For linear classifiers with `‖w‖ ≤ W` on
data with `‖x‖ ≤ B` and margin `γ`, the Rademacher complexity is
`O(WB/(γ√n))`, independent of ambient dimension — strictly tighter than the
VC bound in high dimension. Extending to a kernel `K` with `tr(K) ≤ T`
gives `R̂(F) ≤ √(T/n)`, computed exactly from the eigenvalues of the
(centered) kernel matrix.

Together these form the pipeline VC dimension → growth function → Rademacher
complexity → dimension-free margin/kernel bounds, with the present
polynomial growth bound as its combinatorial foundation.

---

## 8b. Related work and context

The Sauer–Shelah lemma was proved independently by Sauer (1972) and Shelah
(1972), and in a probabilistic form by Vapnik and Chervonenkis (1971) as
the combinatorial heart of their theory of uniform convergence of
empirical measures; Perles and Shelah, and later Frankl and Pajor,
contributed the polynomial-form and dual-shatter refinements used here.
The quantity `vcDim` and the growth function are textbook objects in
statistical learning theory, where the bound `|𝒜| ≤ (n+1)ᵈ` (or its
entropy sharpening) underlies the fundamental theorem of PAC learning:
finite VC dimension is equivalent to distribution-free learnability.

What the present development adds is *modular separation* of the two
logically distinct steps. The semantic step — bounded shattering caps the
count by `∑_{k≤d} C(n,k)` — is genuinely deep and is taken as given from
the ambient library. The arithmetic step — that this sum is at most
`(n+1)ᵈ` — is elementary but is exactly the part most often left implicit
in informal treatments. Isolating it as `choose_partial_sum_le_pow`
makes the downstream growth bounds one-line compositions and exposes the
precise place where sharper estimates (the entropy form of Section 8.1)
plug in.

The phenomenon of an exponential ambient space collapsing to a polynomial
realizable subspace under a structural constraint recurs widely:
antichain widths of certificate posets, the number of cells in an
arrangement of hyperplanes, and the number of sign patterns of a family
of polynomials (the Milnor–Thom and Warren bounds) all exhibit the same
polynomial-vs-exponential dichotomy. The VC growth bound is the
learning-theoretic representative of this family of results, and the
separation theorem of Section 5 is its qualitative signature.

## 8c. Limitations and scope

Three scope remarks are worth making explicit. First, the bound is stated
with the ground set `α` itself as the "sample"; the sample-relative growth
function `Π_𝒜(n) = max_{|s|=n} |𝒜|ₛ|` obeys the same bound by applying the
results to traces, but we have stated the cleanest ambient form. Second,
the polynomial bound `(n+1)ᵈ` is deliberately loose: Theorem 4.4 retains
the sharp sum, and Section 8.1 sketches the optimal entropy form, but the
monomial is what most downstream uniform-convergence arguments consume.
Third, all results are purely combinatorial and carry no probabilistic
content on their own; converting them into generalization guarantees (as
in Section 7) requires the separate machinery of concentration
inequalities, which is the subject of the future-work pipeline toward
Rademacher complexity.

## 9. Conclusion

The passage from "bounded shattering" to "polynomially many behaviors"
rests on two clearly separable facts: the deep Sauer–Shelah lemma, which
caps the count by a truncated binomial sum, and the elementary inequality
`∑_{k≤d} C(n,k) ≤ (n+1)ᵈ`, which collapses that sum into a single monomial.
Composing them yields `|𝒜| ≤ (n+1)ᵈ` in the exact hypothesis form used by
learning theory, together with a strict separation showing that bounded VC
dimension forbids the full powerset. The result is small, sharp where it
needs to be, loose where looseness buys clarity, and positioned as the
combinatorial backbone for a program extending toward Rademacher
complexity and modern generalization theory.
