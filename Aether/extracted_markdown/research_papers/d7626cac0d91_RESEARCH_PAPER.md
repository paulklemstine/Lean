# Thermodynamic Proof Erasure: Landauer's Principle for Mathematics

## Abstract

We develop a quantitative information-thermodynamic theory of *proof compression*. A
proof discovered by search is modelled as a path of `n` binary decisions through a
complete binary search tree; "knowing the proof" is the uniform distribution on the
`2^n` leaves of that tree, whose Shannon entropy is exactly `n · ln 2` nats.
Compressing an `n`-step proof to at most `m`-step proofs (`m ≤ n`) is an arbitrary
function `f : Fin(2^n) → Fin(2^m)`, which acts on distributions by pushforward. Because
its image is supported on at most `2^m` configurations, the maximum-entropy (Gibbs)
inequality caps the surviving entropy at `m · ln 2`. Subtracting the pinned source
entropy `n · ln 2` yields an *erased-information floor* of `(n − m) · ln 2`, and hence,
by Landauer's principle, a dissipated-heat floor of `k · T · (n − m) · ln 2`. This
lower bound is independent of `f` and therefore of the proof system. We prove it tight:
the residue map `i ↦ i mod 2^m` equalizes all fibers, pushes the uniform distribution
to the uniform distribution on `2^m` points, and attains the bound exactly. A worked
instance bounds the cost of compressing a 1000-step proof to a 100-step proof by
`900 · k · T · ln 2`. The argument requires neither the data-processing inequality nor
any concavity machinery: it rests on (i) the exact source entropy and (ii) the
one-sided Gibbs bound, the latter reducing to the pointwise inequality `ln x ≤ x − 1`
summed against the distribution. All results have been formally verified.

**Keywords:** Landauer's principle, proof compression, Shannon entropy, Gibbs
inequality, maximum entropy, information thermodynamics, reversible computation, proof
complexity.

---

## 1. Introduction

### 1.1 Landauer's principle

Landauer's principle (Landauer, 1961) asserts that the erasure of one bit of
information in a physical system at temperature `T` dissipates at least `k · T · ln 2`
of heat, where `k` is Boltzmann's constant. The bound is striking for its universality:
it is charged on the *logical* operation of erasure, not on any particular physical
realization. Reversible computations — those that never lose information and could in
principle be undone — saturate the bound at zero (Bennett, 1973). The principle is a
corollary of the second law of thermodynamics and is best understood through Shannon
entropy: the heat dissipated by a logically irreversible map is `k · T` times the
*decrease* in Shannon entropy of the system's logical state.

### 1.2 The thesis: compression is erasure

We apply this accounting to *mathematics itself*, specifically to **proof compression**.
The informal thesis is:

> Compressing a proof discards the information that distinguished it from other proofs.
> Discarding information is erasure. Erasure costs heat. Therefore making a proof
> shorter has an irreducible thermodynamic price, set by the number of proof steps
> removed and independent of the method or proof system.

This paper turns that slogan into theorems. The contribution is threefold:

1. **A minimal, faithful model** of "a proof carries information": the uniform
   distribution on the `2^n` leaves of a depth-`n` binary search tree, with Shannon
   entropy exactly `n · ln 2`.
2. **A proof-system-independent lower bound** on the heat dissipated by *any*
   compression map, derived from the maximum-entropy (Gibbs) inequality alone.
3. **A matching tightness result** exhibiting an explicit compression map — the residue
   map modulo `2^m` — that attains the bound exactly.

### 1.3 Relation to the data-processing inequality

A companion development (the deterministic data-processing inequality, `H(f∗p) ≤ H(p)`
for arbitrary `f`) establishes that *no* deterministic computation increases Shannon
entropy. That result supplies a generic *direction* (entropy cannot grow) but not the
*extremal constants* we need. The present work is complementary: it pins the source
entropy at exactly `n · ln 2`, supplies the matching *upper* bound (Gibbs) on the image
entropy, and thereby extracts a concrete, tight numerical floor for the proof-tree
application. Notably, our lower bound does **not** route through the data-processing
inequality; it needs only the two opposing facts above.

---

## 2. Definitions

Throughout, `ι`, `α`, `β` are finite types, and probabilities are real numbers.
Logarithms are natural unless stated; one nat equals `1/ln 2 ≈ 1.4427` bits.

### 2.1 Shannon entropy

> **Definition 2.1 (Shannon entropy).** For a weight function `p : ι → ℝ` on a finite
> type `ι`, the Shannon entropy (in nats) is
>
> **H(p) := − Σ_{i ∈ ι} p(i) · ln p(i),**
>
> with the standard convention that the term for `p(i) = 0` is `0` (since
> `x · ln x → 0` as `x → 0⁺`).

> **Definition 2.2 (probability distribution).** `p : ι → ℝ` *is a probability
> distribution*, written `IsProb p`, iff `p(i) ≥ 0` for all `i` and `Σ_i p(i) = 1`.

### 2.2 The uniform distribution and the proof tree

> **Definition 2.3 (uniform distribution).** The uniform distribution on a finite type
> `ι` is `uniformProb(ι) := i ↦ 1 / |ι|`, where `|ι|` is the cardinality of `ι`.

The leaves of a complete binary search tree of depth `n` are indexed by `Fin(2^n)` (the
type of natural numbers `< 2^n`). "Knowing nothing about which length-`n` proof is the
right one" is the uniform distribution `uniformProb(Fin(2^n))`.

### 2.3 Pushforward (compression acting on distributions)

> **Definition 2.4 (pushforward).** For `f : α → β` and a weight function `p : α → ℝ`,
> the *pushforward* (image measure) is
>
> **(f∗p)(y) := Σ_{x : f(x) = y} p(x),**
>
> i.e. the total weight of the fiber `f⁻¹{y}`.

A *compression map* of an `n`-step proof to at-most-`m`-step proofs is any function
`f : Fin(2^n) → Fin(2^m)`. Its action on our knowledge is exactly the pushforward of
the uniform distribution.

### 2.4 The residue map

> **Definition 2.5 (residue map).** For `m ≤ n`, the residue map
> `residueMap : Fin(2^n) → Fin(2^m)` sends `i ↦ i mod 2^m`. (Since `2^m ∣ 2^n`, this is
> well defined and surjective.)

---

## 3. Main results

We state each result with its full mathematical content and a proof sketch.

### 3.1 The uniform distribution is a distribution

> **Lemma 3.1 (`uniformProb_isProb`).** If `|ι| > 0` then `uniformProb(ι)` satisfies
> `IsProb`.
>
> *Proof.* Nonnegativity is `1/|ι| ≥ 0`. The total is `Σ_i 1/|ι| = |ι| · (1/|ι|) = 1`.
> ∎

### 3.2 Entropy of the uniform distribution

> **Theorem 3.2 (`shannonEntropy_uniformProb`).** If `|ι| = N > 0` then
>
> **H(uniformProb(ι)) = ln N.**
>
> *Proof.* Each term is `(1/N) · ln(1/N) = −(1/N) ln N`; summing over the `N` points
> gives `−N · (1/N) ln N · (−1) = … `, i.e.
> `H = −Σ_i (1/N) ln(1/N) = −N · (1/N) · ln(1/N) = −ln(1/N) = ln N`. ∎

### 3.3 Maximum entropy (Gibbs' inequality)

This is the engine of the whole theory and the one nontrivial analytic input.

> **Theorem 3.3 (`shannonEntropy_le_log_card`).** For any probability distribution `p`
> on a finite type with `N` points,
>
> **H(p) ≤ ln N.**
>
> *Proof sketch.* If `N = 0` the type is empty and both sides handle trivially.
> Otherwise consider the relative entropy of `p` to the uniform distribution:
>
> `ln N − H(p) = Σ_i p(i) · ln(N · p(i)).`
>
> We show the right-hand side is `≥ 0`. Pointwise, for each `i`:
> - if `p(i) = 0`, the term is `0` and trivially `≥ p(i) − 1/N = −1/N` is not needed;
> - if `p(i) > 0`, apply `ln x ≤ x − 1` (valid for `x > 0`) to `x = 1/(N · p(i))`:
>   `−ln(N·p(i)) = ln(1/(N·p(i))) ≤ 1/(N·p(i)) − 1`, hence
>   `p(i) · ln(N·p(i)) ≥ p(i) − 1/N`.
>
> Summing over `i` and using `Σ_i p(i) = 1` and `Σ_i 1/N = 1`:
> `Σ_i p(i) ln(N·p(i)) ≥ Σ_i p(i) − Σ_i 1/N = 1 − 1 = 0.`
> Finally expand `ln(N·p(i)) = ln N + ln p(i)` (for `p(i) > 0`; the `p(i) = 0` terms
> vanish on both sides) to get `Σ_i p(i)(ln N + ln p(i)) ≥ 0`, i.e.
> `ln N · 1 − H(p) ≥ 0`. ∎

The decisive economy here is that Gibbs reduces entirely to the single pointwise
inequality `ln x ≤ x − 1`; no concavity, no Jensen, no convex-analysis API is needed.
The only subtlety is the `0 · ln 0` convention, handled by the case split on `p(i) = 0`.

### 3.4 A proof tree carries `n · ln 2` nats

> **Theorem 3.4 (`entropy_uniformProb_pow_two`).** For every `n`,
>
> **H(uniformProb(Fin(2^n))) = n · ln 2.**
>
> *Proof.* Apply Theorem 3.2 with `N = |Fin(2^n)| = 2^n`, then
> `ln(2^n) = n · ln 2`. ∎

This is the information-theoretic content of "an `n`-step proof is `n` binary
decisions": its uncertainty is exactly `n` bits.

### 3.5 Pushforward facts

> **Lemma 3.5 (`pushforward_nonneg`).** If `p ≥ 0` pointwise then `f∗p ≥ 0` pointwise.
> *Proof.* A fiber sum of nonnegative terms is nonnegative. ∎

> **Lemma 3.6 (`pushforward_total`).** `Σ_y (f∗p)(y) = Σ_x p(x)`.
> *Proof.* Fiberwise summation: partitioning `α` by the value of `f` and summing
> regroups the total without changing it. ∎

Consequently the pushforward of a probability distribution is again a probability
distribution, so Gibbs (Theorem 3.3) applies to it.

### 3.6 The Landauer lower bound for proof compression

> **Theorem 3.7 (`landauer_compression_lower_bound`).** Let `m ≤ n`, let
> `f : Fin(2^n) → Fin(2^m)` be any compression map, and let `k, T ≥ 0`. Write `u` for
> the uniform distribution on `Fin(2^n)`. Then the erased information is at least
> `(n − m) · ln 2`:
>
> **H(u) − H(f∗u) ≥ (n − m) · ln 2,**
>
> and hence the dissipated heat satisfies
>
> **k · T · (H(u) − H(f∗u)) ≥ k · T · (n − m) · ln 2.**
>
> *Proof.* By Theorem 3.4, `H(u) = n · ln 2` exactly. By Lemmas 3.5–3.6, `f∗u` is a
> probability distribution on `Fin(2^m)`, which has `2^m` points; by Gibbs
> (Theorem 3.3), `H(f∗u) ≤ ln(2^m) = m · ln 2`. Subtracting,
> `H(u) − H(f∗u) ≥ n·ln 2 − m·ln 2 = (n − m)·ln 2`. Multiplying the nonnegative gap by
> `k·T ≥ 0` preserves the inequality. ∎

The bound is **independent of `f`**: it constrains every compression map identically.
Because `f` ranges over all possible proof-compression schemes in all possible proof
systems, the bound is proof-system independent.

### 3.7 Tightness via the residue map

> **Lemma 3.8 (`residueMap_fiber_card`).** For `m ≤ n`, each fiber of the residue map
> `i ↦ i mod 2^m` has exactly `2^(n−m)` elements.
> *Proof.* The preimage of `r ∈ Fin(2^m)` is `{ r + 2^m·q : 0 ≤ q < 2^(n−m) }`, a set
> of size `2^(n−m) = 2^n / 2^m`. ∎

> **Lemma 3.9 (`residueMap_pushforward_uniform`).** The pushforward of the uniform
> distribution on `Fin(2^n)` along the residue map is the uniform distribution on
> `Fin(2^m)`.
> *Proof.* Each fiber has equal size `2^(n−m)` (Lemma 3.8), so the pushed weight of
> each `r ∈ Fin(2^m)` is `2^(n−m) · (1/2^n) = 1/2^m`. ∎

> **Theorem 3.10 (`landauer_compression_tight`).** With `u` the uniform distribution on
> `Fin(2^n)` and `f = residueMap`, the bound of Theorem 3.7 holds with equality:
>
> **H(u) − H(f∗u) = (n − m) · ln 2,**
>
> so the residue map dissipates exactly `k · T · (n − m) · ln 2`.
>
> *Proof.* By Lemma 3.9, `f∗u` is uniform on `2^m` points, so by Theorem 3.2
> `H(f∗u) = m · ln 2`. Combined with `H(u) = n · ln 2` (Theorem 3.4), the gap is
> exactly `(n − m) · ln 2`. ∎

Theorems 3.7 and 3.10 together establish that `k·T·(n−m)·ln 2` is the *exact* minimum
heat of compressing `n` steps to `m` steps: no scheme does better, and the residue map
does exactly this well.

### 3.8 Worked example

> **Corollary 3.11 (`compression_cost_1000_to_100`).** Compressing a 1000-step proof to
> a 100-step proof erases at least `900 · ln 2` nats and dissipates at least
> `900 · k · T · ln 2` of heat.
> *Proof.* Instantiate Theorem 3.7 at `n = 1000`, `m = 100`; `n − m = 900`. ∎

At `T = 300 K`, `k = 1.380649 × 10⁻²³ J/K`, this is
`900 · 1.380649×10⁻²³ · 300 · 0.6931 ≈ 2.58 × 10⁻¹⁸ J` — a few attojoules. Tiny, but
exact and unavoidable.

---

## 4. Algorithms

The theory is constructive and yields directly executable procedures.

### 4.1 Entropy of a pushforward

**Goal.** Given a compression map `f` and a source distribution `p`, compute the erased
information `H(p) − H(f∗p)` and the Landauer heat `k·T·(H(p) − H(f∗p))`.

```
ALGORITHM ErasedInformation(f, p, k, T):
  INPUT  f : array of length 2^n,  f[x] ∈ {0,…,2^m − 1}
         p : array of length 2^n,  nonnegative, sums to 1
         k, T : positive reals
  # 1. Source entropy
  Hs ← 0
  for x in 0 … 2^n − 1:
      if p[x] > 0: Hs ← Hs − p[x]·ln(p[x])
  # 2. Pushforward
  q ← array of zeros of length 2^m
  for x in 0 … 2^n − 1:
      q[f[x]] ← q[f[x]] + p[x]
  # 3. Image entropy
  Hi ← 0
  for y in 0 … 2^m − 1:
      if q[y] > 0: Hi ← Hi − q[y]·ln(q[y])
  erased ← Hs − Hi            # ≥ 0 by data-processing
  return (erased, k·T·erased)
```

**Complexity.** `O(2^n)` time, `O(2^m)` extra space. By Theorem 3.7, when `p` is
uniform the returned `erased ≥ (n−m)·ln 2`, with equality iff every nonempty fiber has
equal weight (the residue-map regime).

### 4.2 The residue compressor (bound-saturating)

```
ALGORITHM ResidueCompress(n, m):
  INPUT n ≥ m ≥ 0
  return  f : x ↦ x mod 2^m        # a map Fin(2^n) → Fin(2^m)
GUARANTEE: pushforward of uniform is uniform; erased information = (n−m)·ln 2 exactly.
```

**Complexity.** `O(1)` per evaluation; `O(2^n)` to tabulate.

---

## 5. Applications and interpretation

- **A physical lower bound on proof complexity.** The gap between a long proof and its
  shortest equivalent is, by this theory, denominated in joules: at least
  `k·T·(steps removed)·ln 2`. This recasts proof minimization as an irreversible
  thermodynamic process.
- **Proof-system independence.** Because the bound holds for *every* compression map,
  it is invariant under the choice of proof calculus (resolution, natural deduction,
  sequent calculus, neural search). The cost is intrinsic to the information discarded.
- **Reversible proof transformation is free.** An invertible transformation between
  proofs (one carrying a decompression certificate) erases nothing and dissipates no
  heat — the proof-theoretic analogue of Bennett's reversible computation. Only genuine
  *forgetting* of the longer derivation is charged.
- **A conservation-law style impossibility.** Unlike hardness lower bounds (P vs NP),
  this is a conservation argument: it does not say a transformation is hard to compute,
  but that — however computed — it must dissipate a fixed minimum of heat.

---

## 6. Discussion

The mathematical heart of the result is the tension between an *exact* source entropy
and a *one-sided* image bound. The source is a sharp `n · ln 2`; the image is capped at
`m · ln 2` by Gibbs. The lower bound is the subtraction; tightness is the observation
that one explicit map makes the cap an equality. We emphasize that the lower bound
requires **neither** the data-processing inequality **nor** concavity of entropy — only
the maximum-entropy upper bound, which itself collapses to `ln x ≤ x − 1`. This
minimality is both an aesthetic and a practical virtue: the whole tower rests on a
single elementary brick, and the formal verification is correspondingly robust.

A natural worry is the modelling assumption that a proof's information is exactly the
uniform distribution on `2^n` tree leaves. This is a deliberate idealization — the
maximally agnostic prior over length-`n` proofs. Non-uniform priors (e.g. weighting
proofs by a length-conditioned probability, or by a prover's heuristic) only *decrease*
the source entropy below `n · ln 2`, and the same Gibbs argument continues to give a
valid (if smaller) erased-information floor. The uniform case is the extremal,
worst-for-the-compressor scenario, which is exactly what makes its tightness result
sharp.

---

## 7. Future work

See the dedicated Future Directions material accompanying this package. Highlights:

1. **Strict-loss refinement.** Show compression is *strictly* dissipative unless `f`
   is injective on the support — a quantitative gap above the floor for any
   non-residue map, via the equality case of Gibbs.
2. **Non-uniform priors.** Extend to length-conditioned proof distributions and
   prover-heuristic priors, recovering the uniform case as the worst case.
3. **Free energy of partial information.** Account for compression maps that retain a
   decompression certificate, formalizing reversible proof transformation as zero-cost.
4. **Continuous/structured proof spaces.** Replace the binary tree by richer
   combinatorial models of proof search (and-or trees, DAG proofs), and re-derive the
   appropriate maximum-entropy ceilings.

---

## 8. Conclusion

We have given a complete, formally verified, two-sided account of the thermodynamic
cost of proof compression. Modelling an `n`-step proof as the uniform distribution on a
`2^n`-leaf search tree, we proved its entropy is exactly `n · ln 2`; that any
compression to `2^m` proofs erases at least `(n − m) · ln 2` nats (Gibbs), dissipating
at least `k·T·(n−m)·ln 2` of heat independent of the proof system; and that the residue
map `i ↦ i mod 2^m` attains this exactly. Elegance — the act of making a proof shorter —
has a temperature, and we have written down its receipt.

---

## References

- Landauer, R. (1961). *Irreversibility and heat generation in the computing process.*
  IBM Journal of Research and Development, 5(3), 183–191.
- Bennett, C. H. (1973). *Logical reversibility of computation.* IBM Journal of
  Research and Development, 17(6), 525–532.
- Cover, T. M., & Thomas, J. A. (2006). *Elements of Information Theory* (2nd ed.).
  Wiley. (Shannon entropy, Gibbs' inequality, data-processing inequality.)
- Shannon, C. E. (1948). *A mathematical theory of communication.* Bell System
  Technical Journal, 27, 379–423, 623–656.
