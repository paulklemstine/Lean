# The Basin Fixed Point Theorem: A Combinatorial Theory of Descent and Attraction

## Abstract

We develop, from first principles, an abstract theory of *descent dynamics* on
finite state spaces and prove a structural counting theorem: in any system where a
deterministic update rule is accompanied by a `ℕ`-valued Lyapunov ("energy")
function that strictly decreases away from fixed points, the number of basins of
attraction equals the number of fixed points. We call this the **Basin Fixed Point
Theorem**. The engine of the theory is a single lemma — the energy of a state is a
hard upper bound on the length of its descent trajectory — from which we derive
that iterating the update rule `energy s` times always produces a fixed point. This
yields a well-defined *limit map* whose fibers are precisely the basins of
attraction and whose range is precisely the fixed-point set. Reframing basins as
fibers of a single function reduces the dynamical question "how many basins?" to a
static image/fiber computation, and makes the central count almost immediate. We
then prove two extensions that follow with little additional effort: basin counts
are **multiplicative** across independent (synchronous-product) subsystems, and
they are **equivariant** under any energy-preserving symmetry that commutes with
the dynamics. We discuss algorithms for computing basins and fixed points, give
worked numerical examples, and survey five research directions — discrete Morse
inequalities, Burnside-style symmetric counting, a conjectural quantum deformation,
real-valued Lyapunov functions, and continuous Łojasiewicz gradient flow — that the
present abstraction is positioned to reach.

**Keywords:** dynamical systems, basins of attraction, Lyapunov functions, fixed
points, discrete dynamics, Morse theory, combinatorics, optimization landscapes.

---

## 1. Introduction

### 1.1 Motivation

Across an astonishing range of fields, the same picture recurs: a system evolves
deterministically, monotonically dissipating some quantity, until it settles into
a stable configuration. Hopfield networks recall stored patterns by descending an
energy function; gradient-based learning slides down a loss surface; simulated
annealing, belief propagation, and combinatorial local search all converge by
monotone improvement; physical systems relax toward energy minima. In each case the
state space is partitioned into **basins of attraction**, one per stable
configuration, and two questions dominate the analysis: *how many stable
configurations are there?* and *which initial states converge to which one?*

This paper isolates the minimal algebraic skeleton that makes these questions
tractable and answers them with a clean, fully general theorem. We do not assume
geometry, smoothness, a metric, or a vector-space structure. We assume only:

1. a finite state space `S`;
2. a deterministic update `step : S → S`;
3. an energy `energy : S → ℕ`; and
4. a **strict descent law**: `step s ≠ s ⟹ energy (step s) < energy s`.

We call such a quadruple a **DescentSystem**. The development was a cold start: no
prior basin/descent infrastructure existed, so every definition and lemma below is
built from scratch over a finite type.

### 1.2 Contributions

- A spare, reusable abstraction (`DescentSystem`) that captures discrete descent
  dynamics with a quantized Lyapunov function (Section 2).
- The **descent engine** (`step_iterate_isFix`): iterating `step` exactly
  `energy s` times always lands on a fixed point (Section 3).
- A well-defined **limit map** `limitPoint` and its basic properties
  (`limitPoint_isFixedPt`, `limitPoint_eq_self`) (Section 4).
- The **basin–fixed-point correspondence** (`range_limitPoint_eq_fixedPoints`) and
  the **Basin Fixed Point Theorem** (`basin_count_eq_fixedPoint_count`): the number
  of basins equals the number of fixed points (Section 5).
- The **partition theorem** (`mem_basin_self`, `basin_disjoint`,
  `iUnion_basin_eq_univ`): basins partition the state space (Section 5).
- **Multiplicativity** of basin counts over synchronous products
  (`prod_fixedPoint_count`) (Section 6).
- **Equivariance** of basins under energy-preserving symmetries (`isFix_equiv`,
  `limitPoint_equivariant`) (Section 7).

All results are formalized and machine-checked; here we present the mathematics with
proof sketches.

---

## 2. The DescentSystem Abstraction

Throughout, `S` is a finite type. We write `step^[n]` for the `n`-fold composition
of `step` with itself (`step^[0]` is the identity, `step^[n+1] = step ∘ step^[n]`).

> **Definition 2.1 (DescentSystem).** A *descent system* on a finite type `S`
> consists of:
> - an update map `step : S → S`;
> - an energy function `energy : S → ℕ`;
> - the *strict descent law*: for all `s ∈ S`, if `step s ≠ s` then
>   `energy (step s) < energy s`.

> **Definition 2.2 (Fixed point).** A state `s ∈ S` is a *fixed point* (written
> `IsFix s`) if `step s = s`. The *fixed-point set* is
> `fixedPoints := { s ∈ S : step s = s }`.

The intended reading: `step` is the dynamics, `energy` is a quantized potential,
and the strict descent law forbids "stalling" — the system can only stop changing
the energy by actually reaching a fixed point. The choice of `ℕ`-valued energy is
deliberate: it makes the worst-case trajectory length literally equal to a state's
energy value, sidestepping any well-foundedness subtleties. (Section 8 discusses the
real-valued generalization, where this convenience is replaced by a uniform-gap
hypothesis.)

> **Remark 2.3.** Finiteness of `S` is used only to make cardinalities and basin
> partitions meaningful; the descent engine of Section 3 needs only the strict
> descent law and `ℕ`-valuedness. Finiteness is not a serious restriction, since any
> computationally realized dynamical system has a finite state space.

---

## 3. The Descent Engine

The single technical fact underlying the entire theory is that energy bounds the
length of a descent trajectory.

> **Lemma 3.1 (Energy bounds trajectory length).** For every `s ∈ S` and every
> natural number `n` with `energy s ≤ n`, the state `step^[n] s` is a fixed point.

> **Proof sketch.** Strong induction on `n`, with the budget `n` generalized over
> all states (this generalization is the crucial proof move). If `s` is already a
> fixed point, then `step^[k] s = s` for all `k`, so `step^[n] s = s` is fixed.
> Otherwise `step s ≠ s`, so by the strict descent law `energy (step s) <
> energy s ≤ n`, hence `energy (step s) ≤ n − 1`. Apply the induction hypothesis to
> the state `step s` with the smaller budget `n − 1` to conclude that
> `step^[n−1] (step s) = step^[n] s` is a fixed point. (The base case `n = 0`
> forces `energy s = 0`, and one checks directly that an energy-`0` state must be
> fixed, since a non-trivial step would require strictly smaller — i.e. negative —
> energy.) ∎

Specializing the budget to `n = energy s` gives the form we use repeatedly.

> **Theorem 3.2 (`step_iterate_isFix`).** For every `s ∈ S`, the state
> `step^[energy s] s` is a fixed point.

> **Proof.** Immediate from Lemma 3.1 with `n = energy s`. ∎

This is the linchpin. Everything below is bookkeeping built on Theorem 3.2.

---

## 4. The Limit Map

> **Definition 4.1 (Limit map).** The *limit map* of a descent system is
> `limitPoint : S → S`, `limitPoint s := step^[energy s] s`.

> **Proposition 4.2 (`limitPoint_isFixedPt`).** For every `s`, `limitPoint s` is a
> fixed point: `IsFix (limitPoint s)`.

> **Proof.** This is exactly Theorem 3.2. ∎

> **Proposition 4.3 (`limitPoint_eq_self`).** If `IsFix s`, then `limitPoint s = s`.

> **Proof.** If `step s = s`, then `step^[k] s = s` for every `k` by a trivial
> induction; in particular `step^[energy s] s = s`. ∎

Together, Propositions 4.2 and 4.3 say that `limitPoint` is a **retraction** of `S`
onto the fixed-point set: it sends every state to a fixed point, and it is the
identity on fixed points. Consequently `limitPoint` is idempotent
(`limitPoint (limitPoint s) = limitPoint s`), since `limitPoint s` is already fixed.

---

## 5. Basins, the Correspondence, and the Counting Theorem

> **Definition 5.1 (Basin).** For a fixed point `t`, its *basin of attraction* is
> the fiber of the limit map over `t`:
> `basin t := { s ∈ S : limitPoint s = t }`.

The reframing of basins as fibers is the conceptual core of the paper: it converts
all subsequent questions from dynamical to static.

> **Lemma 5.2 (`range_limitPoint_eq_fixedPoints`).** The range of the limit map is
> exactly the fixed-point set: `range limitPoint = fixedPoints`.

> **Proof sketch.** (⊆) Every value `limitPoint s` is a fixed point by
> Proposition 4.2. (⊇) Every fixed point `t` satisfies `t = limitPoint t` by
> Proposition 4.3, so `t` is in the range. ∎

### 5.1 The partition

> **Proposition 5.3 (`mem_basin_self`).** Every fixed point `t` lies in its own
> basin: `t ∈ basin t`. In particular each basin (indexed by a fixed point) is
> non-empty.

> **Proof.** `limitPoint t = t` by Proposition 4.3. ∎

> **Proposition 5.4 (`basin_disjoint`).** If `t₁` and `t₂` are distinct fixed
> points, then `basin t₁ ∩ basin t₂ = ∅`.

> **Proof.** A state `s` in both basins would satisfy `t₁ = limitPoint s = t₂`,
> contradicting `t₁ ≠ t₂` (the limit map is a function: each state has one
> destination). ∎

> **Proposition 5.5 (`iUnion_basin_eq_univ`).** Every state belongs to some basin:
> `⋃_{t ∈ fixedPoints} basin t = S`.

> **Proof.** Given any `s`, set `t = limitPoint s`. By Proposition 4.2, `t` is a
> fixed point, and by definition `s ∈ basin t`. ∎

Together, Propositions 5.3–5.5 establish:

> **Theorem 5.6 (Partition).** The family `{ basin t : t ∈ fixedPoints }` is a
> partition of `S` into non-empty, pairwise-disjoint, exhaustive blocks indexed by
> the fixed points.

### 5.2 The Basin Fixed Point Theorem

> **Theorem 5.7 (Basin Fixed Point Theorem, `basin_count_eq_fixedPoint_count`).**
> The number of basins of attraction equals the number of fixed points:
> `#{ basin t : t ∈ fixedPoints } = #fixedPoints`.

> **Proof sketch.** By Lemma 5.2 the destinations are exactly the fixed points, and
> by Proposition 5.3 each fixed point indexes a non-empty fiber (basin). Distinct
> fixed points index distinct fibers (the indexing `t ↦ basin t` is injective on
> fixed points because `t ∈ basin t` but `t ∉ basin t'` for `t' ≠ t`, by
> Proposition 5.4). Hence the map `t ↦ basin t` is a bijection from the fixed-point
> set onto the set of basins, and the cardinalities agree. ∎

Theorem 5.7 is the headline result: in any descent system, *counting basins is the
same as counting fixed points.* The proof is short precisely because the fiber
viewpoint has done the heavy lifting — the dynamical content was entirely absorbed
into Theorem 3.2 and the retraction property.

> **Remark 5.8 (Necessity of strict descent).** The hypothesis is not decorative.
> Consider `S = {A, B}` with `step A = B`, `step B = A` and any constant energy.
> Here there are no fixed points, the descent law fails, and `limitPoint` is not
> well-defined as a fixed-point-valued map. The cycle `A ↔ B` is exactly the
> pathology the strict descent law excludes: it guarantees that trajectories
> terminate and that the only terminal behavior is a fixed point, never a cycle.

---

## 6. Multiplicativity over Independent Subsystems

Descent systems compose. Running two of them synchronously and independently yields
a descent system on the product space, and basin counts multiply.

> **Definition 6.1 (Synchronous product).** Given descent systems `D₁` on `S₁` and
> `D₂` on `S₂`, their *product* `D₁ × D₂` is the descent system on `S₁ × S₂` with:
> - `step (s₁, s₂) := (step₁ s₁, step₂ s₂)`;
> - `energy (s₁, s₂) := energy₁ s₁ + energy₂ s₂`.

One must check the product is again a descent system.

> **Lemma 6.2 (Product strict descent).** The product `D₁ × D₂` satisfies the
> strict descent law.

> **Proof sketch.** Suppose `(step₁ s₁, step₂ s₂) ≠ (s₁, s₂)`. Then at least one
> coordinate moves, say `step₁ s₁ ≠ s₁`, giving `energy₁ (step₁ s₁) < energy₁ s₁`;
> the other coordinate's energy is non-increasing (it either strictly decreases or
> stays equal, since a non-moving coordinate has equal energy). Summing, the total
> energy strictly decreases. ∎

> **Lemma 6.3 (`prod_isFix_iff`).** `(s₁, s₂)` is a fixed point of `D₁ × D₂` iff
> `s₁` is a fixed point of `D₁` and `s₂` is a fixed point of `D₂`. Consequently
> `fixedPoints (D₁ × D₂) = fixedPoints D₁ × fixedPoints D₂`.

> **Proof.** `(step₁ s₁, step₂ s₂) = (s₁, s₂)` iff `step₁ s₁ = s₁` and
> `step₂ s₂ = s₂`. ∎

> **Theorem 6.4 (Multiplicativity, `prod_fixedPoint_count`).** The number of basins
> of `D₁ × D₂` is the product of the numbers of basins of `D₁` and `D₂`:
> `#fixedPoints (D₁ × D₂) = #fixedPoints D₁ · #fixedPoints D₂`.

> **Proof.** Combine Theorem 5.7 (basins ↔ fixed points for each system and the
> product) with Lemma 6.3 and the cardinality of a Cartesian product,
> `#(A × B) = #A · #B`. ∎

> **Remark 6.5 (Quantum shadow).** Theorem 6.4 is the `q = 1` specialization of a
> conjectured *quantum* deformation in which each descent path of length `ℓ`
> contributes `q^ℓ` to a generating function `Q(q) = Σ_paths q^ℓ`, and basins carry
> a `q`-deformed product. Multiplicativity of the plain count is precisely the
> classical limit `q → 1` of multiplicativity of the deformed product; see
> Direction 3 in Section 9.

---

## 7. Equivariance under Symmetry

> **Definition 7.1 (Symmetry).** A *symmetry* of a descent system is a bijection
> `g : S → S` that (i) preserves energy, `energy (g s) = energy s`, and (ii)
> commutes with the dynamics, `step (g s) = g (step s)`.

> **Lemma 7.2 (`isFix_equiv`).** Symmetries permute fixed points: if `g` is a
> symmetry and `IsFix s`, then `IsFix (g s)`.

> **Proof.** `step (g s) = g (step s) = g s`. ∎

> **Lemma 7.3 (Iterate intertwining).** For any symmetry `g` and any `n`,
> `step^[n] (g s) = g (step^[n] s)`.

> **Proof.** Induction on `n`, using `step ∘ g = g ∘ step` at each step. ∎

> **Theorem 7.4 (Equivariance, `limitPoint_equivariant`).** For any symmetry `g`,
> `limitPoint (g s) = g (limitPoint s)`.

> **Proof sketch.** By Definition 7.1(i), `energy (g s) = energy s =: e`. Then
> `limitPoint (g s) = step^[e] (g s) = g (step^[e] s) = g (limitPoint s)`, using
> Lemma 7.3. ∎

Theorem 7.4 says the symmetry group acts on the set of basins (equivalently, on the
fibers of `limitPoint`) compatibly with its action on fixed points: relabeling a
state relabels its destination. This is exactly the structure required to count
basins *modulo* symmetry via Burnside's lemma (Direction 2, Section 9): one obtains
a `MulAction` of the symmetry group on the range of `limitPoint`, and the number of
basins up to symmetry is the average number of basins fixed by each group element.

---

## 8. Algorithms

The constructive content of the theory yields direct algorithms. Let `N = #S`.

### 8.1 Computing the limit map

By Theorem 3.2, `limitPoint s = step^[energy s] s`, computable by iterating `step`
at most `energy s` times. In practice one short-circuits as soon as a fixed point is
detected (`step s = s`), which is never later than `energy s` steps. The cost is
`O(energy s)` applications of `step` per state, with a useful refinement: detecting
the first repeat (a fixed point under strict descent must be the *first* repeat)
costs `O(L_s)` where `L_s ≤ energy s` is the true trajectory length.

### 8.2 Enumerating fixed points and basins

Enumerate fixed points by testing `step s = s` for each `s ∈ S` — cost `O(N)`
step-evaluations. By Theorem 5.7 the basin count is immediately `#fixedPoints`. To
materialize the basins themselves, compute `limitPoint s` for each `s` and bucket
states by destination — cost `O(Σ_s L_s) ≤ O(N · max_s energy s)`. The buckets are
exactly the basins (Definition 5.1), and the partition guarantees (Theorem 5.6) that
this produces a clean, exhaustive, disjoint cover.

### 8.3 Product and symmetry exploitation

For a product system (Section 6) one need not enumerate the `#S₁ · #S₂` product
states: by Lemma 6.3 it suffices to enumerate fixed points of the factors
separately and multiply (Theorem 6.4), an exponential saving for many factors. For a
symmetric system (Section 7) one enumerates representatives of fixed points modulo
the symmetry group (Theorem 7.4) and counts orbits.

---

## 9. Applications and Worked Examples

**Hopfield-style associative memory.** A binary memory network with a Lyapunov
energy and asynchronous threshold updates is a descent system once the energy is
quantized (integer weights). Theorem 5.7 says the number of distinct retrievable
memories equals the number of stable patterns, and Theorem 5.6 says every initial
cue is recalled to exactly one memory.

**Combinatorial local search.** Hill-climbing on a finite candidate set with a
strictly improving move rule is a descent system; basins are the sets of starting
points leading to each local optimum, and Theorem 5.7 counts the local optima by
counting basins (or vice versa).

**Cellular-automaton still lifes.** In a discrete automaton whose dynamics admit a
monotone potential, fixed configurations ("still lifes") are the fixed points;
Theorem 5.7 relates the census of still lifes to the partition of configuration
space into convergence basins.

**A small explicit system.** Let `S = {0,1,2,3,4}` with `step 0 = 0`, `step 4 = 4`,
`step 1 = 0`, `step 3 = 4`, `step 2 = 1`, and `energy s = min(s, 4−s)` so that
`energy = (0,1,2,1,0)`. One checks the strict descent law holds. The fixed points
are `{0, 4}`, so there are exactly two basins (Theorem 5.7): `basin 0 = {0,1,2}` and
`basin 4 = {3,4}`. They partition `S` (Theorem 5.6). Running this in product with a
3-fixed-point system gives, by Theorem 6.4, exactly `2 · 3 = 6` basins without
enumerating the 5·(state count) product directly.

(These examples are realized numerically in the accompanying `demo.py`.)

---

## 10. Discussion and Future Work

The theory's design philosophy is *minimality*: keep only "things move and energy
falls," and recover the full basin/fixed-point dictionary. The single non-trivial
input is Theorem 3.2; everything else is the observation that **basins are fibers**,
which trivializes the partition structure, the count, multiplicativity, and
equivariance in turn. We close with five directions, ordered roughly by how directly
the present abstraction reaches them.

**Direction 1 — Discrete Morse inequalities.** Extend the system to track critical
cells of every index (not only minima) on a finite CW/simplicial complex, and prove
the weak Morse inequality `b_k ≤ c_k` (the `k`-th Betti number is bounded by the
number of critical `k`-cells) together with the Euler identity `Σ (−1)^k c_k = χ`.
The fiber/partition structure of `limitPoint` already supplies the alternating-sum
bookkeeping; each basin is a "descending cell," and Theorem 5.7 is the index-0 case
of the inequality.

**Direction 2 — Burnside-style symmetric counting.** For a finite group `G` acting
by energy-preserving, dynamics-commuting symmetries, the number of basins modulo `G`
equals `(1/|G|) Σ_{g∈G} #{basins fixed by g}`. Theorem 7.4 already shows `G` acts on
the set of basins; only the orbit-counting wrapper (`MulAction` + Burnside's lemma)
remains. The payoff is a closed-form count of *essentially distinct* minima found by
symmetric descent — e.g. modulo neural-network neuron-permutation symmetry.

**Direction 3 — Quantum deformation (WDVV test).** Define `Q(q) = Σ_paths q^{length}`
over descent paths and a `q`-deformed product on basins; Theorem 6.4 is the `q → 1`
limit. Test whether the deformed product satisfies a WDVV associativity relation on
small explicit systems. Success would support a Gromov–Witten analogy for basin
counting; a generic failure would be a clean negative result.

**Direction 4 — Real-valued Lyapunov functions.** Replace `energy : S → ℕ` with
`energy : S → ℝ` plus a *uniform gap*: `∃ δ > 0`, `step s ≠ s ⟹ energy s −
energy (step s) ≥ δ`. Then descent reaches a fixed point in at most
`⌈(energy s − min energy)/δ⌉` steps, and Theorems 3.2, 5.6, 5.7 survive verbatim.
The current proof's only use of `ℕ` is the discreteness of the decrease; the gap
hypothesis isolates exactly that dependence.

**Direction 5 — Continuous Łojasiewicz gradient flow.** For a real-analytic loss on
`ℝⁿ`, the Łojasiewicz inequality `|∇L(θ)|² ≥ c |L(θ) − L(θ*)|^α` forces gradient-flow
trajectories to have finite length and converge, yielding a continuous basin map
whose fibers partition a neighborhood of the critical set — the continuous Basin
Fixed Point Theorem. The Łojasiewicz inequality is precisely the continuous analogue
of the strict-descent/uniform-gap axiom: both forbid stalling at non-critical points.

---

## 11. Conclusion

We have built a small, self-contained theory of descent dynamics on finite spaces
and proved that **the number of basins of attraction equals the number of fixed
points**. The proof rests on one inequality — energy strictly falls while anything
moves — which bounds trajectory length, makes the limit map well-defined, and
exhibits basins as its fibers. From that fiber viewpoint the partition structure,
the counting theorem, multiplicativity over products, and equivariance under
symmetry all follow with minimal additional effort. The abstraction is positioned to
reach discrete Morse theory, symmetric (Burnside) counting, a conjectural quantum
deformation, and — by relaxing quantization to a uniform gap and then to the
Łojasiewicz inequality — the continuous landscapes of modern optimization.

---

## Appendix A: Glossary of Formal Results

- `step_iterate_isFix` — `step^[energy s] s` is always a fixed point (Theorem 3.2).
- `limitPoint_isFixedPt` — every state flows to a fixed point (Proposition 4.2).
- `limitPoint_eq_self` — fixed points are their own limit (Proposition 4.3).
- `range_limitPoint_eq_fixedPoints` — range of `limitPoint` = fixed-point set
  (Lemma 5.2).
- `mem_basin_self` — each fixed point lies in its own basin (Proposition 5.3).
- `basin_disjoint` — distinct fixed points have disjoint basins (Proposition 5.4).
- `iUnion_basin_eq_univ` — basins cover the space (Proposition 5.5).
- `basin_count_eq_fixedPoint_count` — **Basin Fixed Point Theorem** (Theorem 5.7).
- `prod`, `prod_isFix_iff`, `prod_fixedPoint_count` — multiplicativity over
  independent subsystems (Section 6).
- `isFix_equiv`, `limitPoint_equivariant` — equivariance under symmetry (Section 7).
