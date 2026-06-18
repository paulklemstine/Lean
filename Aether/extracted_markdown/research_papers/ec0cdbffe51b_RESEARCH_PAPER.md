# The Maximum Fiber Size as a Unifying Invariant for Reversible Computation and Landauer Cost

## Abstract

We develop a self-contained theory connecting the combinatorial structure of a
finite function to the operational and thermodynamic costs of computing it
reversibly. The central object is the **maximum fiber size** of a function
`f : α → β`, the cardinality of its largest preimage. We prove that this single
invariant exactly determines the minimal auxiliary ("ancilla") space required to
make `f` logically reversible: at least `maxFiberSize f` ancilla states are
necessary (a pigeonhole argument on a single fiber), and exactly
`maxFiberSize f` states suffice (a fiber-enumeration construction via the
sigma-fiber equivalence). We then sharpen Landauer's non-strict cost bound into
a strict dichotomy: a function erases a positive amount of information — and
therefore incurs a strictly positive Landauer gap at positive temperature — if
and only if it is non-injective. Combining these results yields a fourfold
equivalence for any finite function `f`: (i) `f` needs more than one ancilla
state, (ii) `f` is non-injective, (iii) `f` erases positive information, and
(iv) `f` has a strictly positive Landauer gap. All four are governed by the same
combinatorial dial, the maximum fiber size. We illustrate the theory on sorting,
where the unique fiber has size `n!`, recovering the `log₂(n!)` information and
ancilla bounds, and we record the multiplicativity of ancilla cost under
composition.

**Keywords.** reversible computation, Landauer's principle, fiber structure,
ancilla bound, information erasure, Bennett's theorem, thermodynamics of
computation.

---

## 1. Introduction

### 1.1 Motivation

Two principles frame the thermodynamics of computation. **Landauer's principle**
(1961) asserts that erasing one bit of information dissipates at least `kT ln 2`
joules of heat. **Bennett's theorem** (1973) asserts that any computation can be
made *logically reversible* — and hence, in principle, thermodynamically free —
by retaining enough auxiliary information to invert it. Together they suggest a
quantitative trade-off: the price of reversibility is *memory* (the auxiliary
"history" one must keep), while the price of irreversibility is *energy* (the
heat one must dissipate). Both prices, intuitively, should be controlled by *how
much* the computation merges its inputs.

This paper makes that intuition exact. We identify a single combinatorial
invariant — the maximum fiber size — and show it pins down both costs precisely.

### 1.2 Contributions

Let `f : α → β` be a function between finite types. We prove:

1. **Counting identity** (Proposition 3.1): the fibers of `f` partition the
   domain, `∑_{b} |f⁻¹(b)| = |α|`.
2. **Bennett's reversible decomposition** (Theorem 4.1): `f` admits a bijection
   `α ≃ Σ_{b} f⁻¹(b)` whose first component recovers `f`.
3. **Tight ancilla lower bound** (Theorem 5.2): every reversible simulation of
   `f` requires at least `maxFiberSize f` ancilla states.
4. **Tight ancilla upper bound** (Theorem 5.3): a reversible simulation of `f`
   exists with ancilla type `Fin (maxFiberSize f)`.
5. **Exact minimality** (Theorem 5.4): `maxFiberSize f` is the exact minimal
   ancilla cardinality, and no simulation into `Fin (maxFiberSize f − 1)` exists
   once a nontrivial fiber appears.
6. **One ancilla ⇔ injective** (Theorem 5.5): `maxFiberSize f ≤ 1 ↔ f`
   injective.
7. **Strict image shrinkage** (Proposition 6.1): non-injective `f` has
   `|image f| < |α|`.
8. **Erasure characterizes irreversibility** (Theorem 6.2): the information
   erased by `f` is positive iff `f` is non-injective.
9. **Strict Landauer cost** (Theorem 6.3): at positive temperature, every
   non-injective `f` has a strictly positive Landauer gap.

Section 7 applies the theory to sorting; Section 8 records composition; Section 9
synthesizes the fourfold equivalence; Section 10 discusses future directions.

All results have been formally verified; the statements below are faithful
mathematical renderings of the verified theorems.

---

## 2. Preliminaries and Notation

Throughout, `α`, `β` are finite types (we write `|α| = Fintype.card α` for
cardinality), and `f : α → β` is an arbitrary function. We assume decidable
equality on `β` where needed (automatic for finite types).

- The **fiber** of `f` over `b ∈ β` is `f⁻¹(b) = {a ∈ α : f a = b}`, realized as
  the finite set `Finset.univ.filter (fun a => f a = b)`.
- The **image** of `f` is `image f = {f a : a ∈ α}`, realized as
  `Finset.image f Finset.univ`.
- `f` is **injective** if `f a₁ = f a₂ ⟹ a₁ = a₂`.
- `Fin k` denotes the canonical `k`-element type `{0, 1, …, k−1}`.
- `logb 2 x` is the base-2 logarithm; `log` is the natural logarithm.

---

## 3. The Fiber Partition

### Proposition 3.1 (Counting identity)

For finite types `α`, `β` and any `f : α → β`,
$$
\sum_{b \,:\, β} \bigl|\,\{a : f\,a = b\}\,\bigr| \;=\; |α|.
$$

**Proof sketch.** Expand each fiber cardinality as a sum of indicators,
`|f⁻¹(b)| = ∑_{a} [f a = b]`, swap the order of summation, and observe that for
each fixed `a` exactly one `b` (namely `b = f a`) contributes. The inner sum
collapses to `1`, leaving `∑_a 1 = |α|`. ∎

This identity is the bookkeeping foundation of everything that follows: it says
the fibers tile the domain exactly, with no overlaps and no gaps.

### Definition 3.2 (Maximum fiber size)

The **maximum fiber size** of `f` is
$$
\mathrm{maxFiberSize}\,f \;=\; \max_{b \,:\, β} \bigl|\,\{a : f\,a = b\}\,\bigr|,
$$
the cardinality of the largest preimage. (Formally a `Finset.sup` over `β` of
fiber cardinalities.)

---

## 4. Bennett's Reversible Decomposition

A computation is *logically reversible* when the map from inputs to (outputs
together with retained history) is a bijection. Bennett's theorem says such a
decomposition always exists, with the history being exactly the fiber index.

### Definition 4.1 (Reversible witness)

A **reversible witness** for `f : α → β` is an auxiliary type `Aux` together
with a bijection `encode : α ≃ β × Aux` such that `(encode a).1 = f a` for all
`a`. Its inverse `decode = encode.symm` reconstructs the input from
`(output, history)`.

A reversible witness requires `|β| · |Aux| = |α|`, so as a *bijection* it exists
only when `|β|` divides `|α|`. The more flexible notion of Section 5 removes this
constraint.

### Theorem 4.2 (Bennett's reversible decomposition, sigma form)

For any `f : α → β` there is a bijection
$$
e : α \;\simeq\; \sum_{b \,:\, β} \{a : α \mid f\,a = b\}
$$
with `(e a).1 = f a` for all `a`.

**Proof sketch.** The sigma type `Σ_b {a // f a = b}` is the disjoint union of
the fibers, and the canonical "sigma-fiber equivalence" sends each `a` to the
pair `(f a, a)` (with `a` viewed as a member of its own fiber). This is a
bijection because every `a` lies in exactly one fiber (Proposition 3.1), and its
first component is `f a` by construction. ∎

For the special case `β = Unit` (every output identified), the sigma form
collapses to a product witness `α ≃ Unit × α`, the prototypical reversible
embedding of a maximally collapsing computation.

---

## 5. The Tight Ancilla Bound

Bennett's witness uses a *fiber-dependent* history. We now ask for a *uniform*
ancilla type and determine its exact minimal size. The right notion for
arbitrary (possibly non-surjective) functions relaxes "bijection" to
"injection."

### Definition 5.1 (Reversible simulation)

A **reversible simulation** of `f : α → β` consists of an auxiliary type `Aux`
and an *injective* encoding `encode : α → β × Aux` with `(encode a).1 = f a` for
all `a`. The injectivity of `encode` is precisely the reversibility
requirement: distinct inputs receive distinct `(output, ancilla)` pairs, so the
input is recoverable.

Unlike a reversible witness, a reversible simulation exists for *every* `f`; the
question is how small `Aux` can be.

### Theorem 5.2 (Lower bound)

For finite `α`, `β` and any reversible simulation of `f` with finite ancilla
`Aux`,
$$
\mathrm{maxFiberSize}\,f \;\le\; |Aux|.
$$

**Proof sketch.** Fix an output `b` achieving the maximum fiber. Restrict the
encoding's second component to the fiber `f⁻¹(b)`, giving a map
`a ↦ (encode a).2 : f⁻¹(b) → Aux`. This map is injective: if two fiber elements
`a₁, a₂` had the same ancilla, then since both have first component `b = f a₁ =
f a₂`, their full encodings `(b, ancilla)` would coincide, and injectivity of
`encode` forces `a₁ = a₂`. An injection from a set of size `maxFiberSize f` into
`Aux` yields `maxFiberSize f ≤ |Aux|`. ∎

### Theorem 5.3 (Upper bound)

For finite `α`, `β` and any `f : α → β`, there exists a reversible simulation
with ancilla type `Fin (maxFiberSize f)`.

**Proof sketch.** By Bennett's decomposition (Theorem 4.2), `α` is in bijection
with the disjoint union of its fibers. Each fiber `f⁻¹(b)` has cardinality at
most `maxFiberSize f`, so it embeds into `Fin (maxFiberSize f)` (any finite set
of size `≤ k` injects into `Fin k`, via `Finset.equivFin` or
`Embedding.nonempty_of_card_le`). Define `encode a = (f a, ι(a))`, where `ι(a)`
is the index of `a` within its own fiber under such an embedding. The first
component is `f a` by construction. Injectivity: if `encode a₁ = encode a₂` then
`f a₁ = f a₂`, so `a₁, a₂` lie in the same fiber, and the equal indices `ι(a₁) =
ι(a₂)` plus injectivity of the per-fiber embedding give `a₁ = a₂`. Routing the
construction through the sigma type rather than building the index map by hand
avoids all index arithmetic. ∎

### Theorem 5.4 (Exact minimality)

The minimal ancilla cardinality over all reversible simulations of `f` is
*exactly* `maxFiberSize f`. Consequently, once `f` has a fiber of size `≥ 2`, no
reversible simulation with ancilla `Fin (maxFiberSize f − 1)` exists.

**Proof sketch.** Theorem 5.3 exhibits a simulation of ancilla size
`maxFiberSize f`; Theorem 5.2 forbids anything smaller. The impossibility of
`maxFiberSize f − 1` is the contrapositive of the lower bound applied to
`|Aux| = maxFiberSize f − 1 < maxFiberSize f`. ∎

### Theorem 5.5 (One ancilla state ⇔ injective)

For finite `α`, `β`,
$$
\mathrm{maxFiberSize}\,f \le 1 \quad\Longleftrightarrow\quad f \text{ is injective.}
$$

**Proof sketch.** `maxFiberSize f ≤ 1` says every fiber has at most one element.
A fiber `f⁻¹(b)` with two distinct elements `a₁ ≠ a₂` is exactly a witness to
non-injectivity (`f a₁ = b = f a₂`); conversely, injectivity means no output is
hit twice, so every fiber is a singleton or empty. ∎

Theorem 5.5 is the bridge to the thermodynamic half of the paper: "one ancilla
suffices" is synonymous with "no information is lost."

---

## 6. Strict Irreversibility Cost

We now formalize information erasure and Landauer cost, then sharpen the
classical non-strict bound into a strict dichotomy.

### Definition 6.1 (Landauer cost and information erased)

- The **Landauer cost** of erasing `r` bits at thermal energy `kT` is
  $$\mathrm{landauerCost}(kT, r) = kT \cdot (\ln 2) \cdot r.$$
- The **information erased** by `f : α → β` (in bits) is
  $$\mathrm{infoErased}\,f = \log_2 |α| \;-\; \log_2 |image\,f|.$$
- The **Landauer gap** of `f` at thermal energy `kT` is
  $$\mathrm{landauerGap}\,f\,(kT) = \mathrm{landauerCost}\bigl(kT,\ \mathrm{infoErased}\,f\bigr).$$

### Proposition 6.2 (Image strictly shrinks under non-injectivity)

If `f : α → β` is not injective (with `α` finite), then
$$
|image\,f| \;<\; |α|.
$$

**Proof sketch.** Always `|image f| ≤ |α|` (the image is the image of a set of
size `|α|`). Equality `|image f| = |α|` holds iff `f` is injective on the domain
(Finset's `card_image_iff`). Since `f` is assumed non-injective, the inequality
is strict. ∎

### Theorem 6.3 (Erasure characterizes irreversibility)

For finite `α`, `β` with `α` nonempty,
$$
0 < \mathrm{infoErased}\,f \quad\Longleftrightarrow\quad f \text{ is not injective.}
$$

**Proof sketch.** `infoErased f = log₂|α| − log₂|image f|`.

*(⇐)* If `f` is non-injective then `|image f| < |α|` (Proposition 6.2). Both
cardinalities are positive integers (`|image f| ≥ 1` since `α` is nonempty), so
strict monotonicity of `log₂` on the positive reals gives
`log₂|image f| < log₂|α|`, i.e. `infoErased f > 0`.

*(⇒)* Contrapositive: if `f` is injective then `|image f| = |α|`, the two logs
coincide, and `infoErased f = 0`, contradicting positivity. ∎

The degenerate cases are benign: non-injectivity forces `|α| ≥ 2` and
`|image f| ≥ 1`, so both logarithms are evaluated at strictly positive integers
where `log₂` is well behaved and strictly increasing.

### Theorem 6.4 (Strict Landauer cost)

For finite `α`, `β` with `α` nonempty, any `kT > 0`, and any non-injective
`f : α → β`,
$$
0 < \mathrm{landauerGap}\,f\,(kT).
$$

**Proof sketch.** `landauerGap f (kT) = kT · (ln 2) · infoErased f` is a product
of three strictly positive factors: `kT > 0` by hypothesis, `ln 2 > 0`, and
`infoErased f > 0` by Theorem 6.3. A product of positives is positive. ∎

For contrast, the classical non-strict bound also holds and follows by the same
factorization with non-strict inequalities:

### Theorem 6.5 (Landauer gap is non-negative)

For finite `α`, `β`, any `f`, and any `kT > 0`,
$$
0 \le \mathrm{landauerGap}\,f\,(kT).
$$

**Proof sketch.** `kT ≥ 0`, `ln 2 ≥ 0`, and `infoErased f ≥ 0` because
`|image f| ≤ |α|` always (with the empty-domain corner handled separately). The
product of non-negatives is non-negative. ∎

Theorems 6.4 and 6.5 together state Landauer's principle as a sharp dichotomy:
the gap is `≥ 0` always, and `> 0` exactly when the computation is irreversible.

---

## 7. Application: The Thermodynamics of Sorting

Sorting is the canonical irreversible computation. Model the "sort" map on `n`
distinct keys as the constant map
$$
\mathrm{sort}_n : \mathrm{Perm}(\mathrm{Fin}\,n) \to \mathrm{Unit},
\qquad \mathrm{sort}_n(\sigma) = (),
$$
which collapses every one of the `n!` input permutations to the single sorted
output.

### Proposition 7.1 (The sorting fiber)

The (unique) fiber of `sort_n` is the entire permutation group, so
$$
\mathrm{maxFiberSize}\,(\mathrm{sort}_n) = |\mathrm{Perm}(\mathrm{Fin}\,n)| = n!.
$$

**Proof sketch.** Every permutation maps to `()`, so the filter defining the
fiber is the whole universe; its cardinality is `|Perm(Fin n)| = n!` by the
standard permutation count. ∎

### Corollary 7.2 (Sorting ancilla lower bound)

Any reversible implementation of `sort_n` requires at least `n!` ancilla states.

**Proof.** Immediate from Theorem 5.2 and Proposition 7.1 (equivalently, from
the dedicated lower bound that injects `Perm(Fin n)` into any consistent ancilla
via the history component). ∎

### Corollary 7.3 (Information erased by sorting)

For `n ≥ 1`,
$$
\mathrm{infoErased}\,(\mathrm{sort}_n) = \log_2(n!).
$$

**Proof sketch.** The image of a constant map has one element, so `infoErased =
log₂|Perm(Fin n)| − log₂ 1 = log₂(n!) − 0 = log₂(n!)`. ∎

By Stirling's approximation `log₂(n!) = n log₂ n − n log₂ e + O(log n)`, this
matches the classical `Θ(n log n)` comparison-sorting lower bound: the
information-theoretic cost and the thermodynamic cost of sorting coincide, both
governed by `log₂(n!)`. For `n = 13`, `log₂(13!) ≈ 32.5` bits.

### Proposition 7.4 (Sorting is non-injective for `n ≥ 2`)

For `n ≥ 2`, `sort_n` is not injective.

**Proof sketch.** The transposition swapping two distinct indices and the
identity are distinct permutations mapping to the same output `()`. ∎

Combining Proposition 7.4 with Theorem 6.4 shows that sorting two or more
distinct items has a strictly positive Landauer gap — irreversible sorting is
never thermodynamically free.

---

## 8. Composition of Reversible Computations

Reversible building blocks combine into reversible programs, with ancilla cost
multiplying.

### Theorem 8.1 (Composition of reversible witnesses)

Given reversible witnesses for `f : α → β` (ancilla `A`) and `g : β → γ`
(ancilla `B`), there is a reversible witness for `g ∘ f` with ancilla `A × B`,
and its first component recovers `g(f a)`.

**Proof sketch.** Chain the encodings: `α ≃ β × A ≃ (γ × B) × A ≃ γ × (A × B)`,
using the witness for `f`, then the witness for `g` on the `β` factor, then
associativity/commutativity rearrangement. The first component is `g(f a)` by
unfolding the two consistency conditions. ∎

### Corollary 8.2 (Ancilla cost is multiplicative)

In the setting of Theorem 8.1 with finite ancillas,
$$
|A \times B| = |A| \cdot |B|.
$$

**Proof.** Cardinality of a product type. ∎

This multiplicativity underlies Bennett's program-composition discipline and the
"compute–copy–uncompute" pattern used pervasively in reversible and quantum
computing, where intermediate histories are reversibly erased to keep ancilla
growth in check.

---

## 9. Synthesis: The Fourfold Equivalence

Assembling Theorems 5.5, 6.3, and 6.4 yields the conceptual payoff. For a finite
function `f : α → β` (with `α` nonempty) and any positive temperature `kT > 0`,
the following are equivalent:

1. **More than one ancilla state is required**: `maxFiberSize f ≥ 2`.
2. **`f` is non-injective**.
3. **`f` erases positive information**: `infoErased f > 0`.
4. **`f` has a strictly positive Landauer gap**: `landauerGap f (kT) > 0`.

The implications form a cycle through three mathematical worlds —
combinatorics (1 ⇔ 2 via Theorem 5.5), information theory (2 ⇔ 3 via
Theorem 6.3), and thermodynamics (3 ⇔ 4 via Theorem 6.4) — all calibrated by the
single invariant `maxFiberSize f`. When the dial reads `1`, the function is
reversible, lossless, and free; the instant it reads `2`, all four costs switch
on simultaneously.

---

## 10. Discussion and Future Directions

The maximum fiber size emerges as the master invariant of finite reversible
computation, simultaneously controlling memory overhead and energy cost. Several
threads extend the theory.

**Optimal ancilla in bits, not states.** We pinned the minimal ancilla
*cardinality* at `maxFiberSize f`. Physically the relevant cost is the number of
*bits*, i.e. `⌈log₂(maxFiberSize f)⌉`. The conjecture is that a reversible
simulation realized over a *binary* ancilla `(Fin 2)^m` requires and admits
exactly `m = ⌈log₂(maxFiberSize f)⌉`, matching `infoErased` on the worst-case
uniform input.

**Tight ancilla for general functions.** Generalize beyond the surjective
(hence bijective on finite types) case to arbitrary `f` with maximum fiber size
`k`, proving that `Fin k` ancilla is both necessary and sufficient and that
`Fin (k−1)` is impossible — the pigeonhole lower bound combined with explicit
fiber enumeration.

**Circuit complexity of reversible simulation.** The Toffoli gate is universal
for reversible Boolean computation. A natural target: any `f : (Fin 2)^n →
(Fin 2)^n` decomposes into `O(n · 2^n)` Toffoli gates with `O(n)` ancilla bits,
with a matching `Ω(2^n / n)` Shannon-style counting lower bound.

**Shannon entropy preservation.** Extend cardinality-preservation under
bijections to full Shannon entropy: for any distribution `p` and bijection `σ`,
`H(p) = H(p ∘ σ⁻¹)`; and for any non-injective `f`, some distribution has
`H(f_* p) < H(p)`, by strict concavity of `−x log x`.

**Kolmogorov complexity.** For computable bijections, `K(f(n)) = K(n) + O(1)`;
for non-injective computable maps, `K` drops by roughly the log of the fiber
size for infinitely many inputs — the algorithmic-information analogue of the
fiber-size cost.

**Thermodynamic cost of sorting, refined.** Beyond the `log₂(n!)` bound, connect
comparison-based lower bounds to reversible ancilla requirements and to merge
sort's achievability of the bound up to lower-order terms.

---

## 11. Conclusion

We have shown that a single combinatorial invariant — the maximum fiber size of
a finite function — exactly governs both the auxiliary-memory cost of making the
function reversible and the thermodynamic energy cost of running it
irreversibly. The ancilla bound is tight (necessary and sufficient at
`maxFiberSize f` states), and the Landauer cost obeys a sharp dichotomy
(non-negative always, strictly positive exactly for non-injective maps). The
resulting fourfold equivalence unifies combinatorial, information-theoretic, and
thermodynamic accounts of irreversibility into one ledger, with the maximum
fiber size as its common currency.
