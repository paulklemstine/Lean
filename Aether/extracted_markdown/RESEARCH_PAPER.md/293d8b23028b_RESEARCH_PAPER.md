# Entropy-Bounded Computation: A Formal Core for Information Cost of Deterministic Steps

## Abstract

We develop a compact, fully rigorous mathematical core for **Entropy-Bounded
Computation (EBC)**, a framework that treats a single deterministic
computational step as a function between finite *state spaces* and measures its
information content by the base-2 logarithm of the number of states — the
Shannon entropy of the uniform distribution over the states, in bits. On this
skeleton we prove the structural laws of information under computation:
nonnegativity, the zero-entropy of single-state machines, invariance of entropy
under reversible (bijective) computation, additivity over independent (product)
state spaces, a data-processing/second-law inequality for surjective
deterministic maps, and a sharp form of **Landauer's principle** — that erasing
a multi-state space to a single state dissipates strictly positive entropy equal
to the source entropy. We give proof sketches for each result, an algorithmic
view, numerical illustrations, and connections to reversible computing, hashing,
and lattice cryptography. As a companion application bridge, we state and sketch
a compression-correctness theorem connecting operator norms of linear
compression maps to decryption correctness windows, of the kind used in
standards-compliance arguments for lattice-based key-encapsulation mechanisms.
The development is deliberately minimal: every result follows from elementary
properties of finite cardinalities and the base-2 logarithm, yet together they
reproduce, as exact theorems, the informational content of the second law of
thermodynamics for computation.

**Keywords:** entropy, Landauer's principle, reversible computation,
data-processing inequality, information theory, Shannon entropy,
finite state spaces, lattice cryptography, operator norm.

---

## 1. Introduction

### 1.1 Motivation

The thesis that *information is physical* — that logical operations carry
unavoidable thermodynamic consequences — originates with Rolf Landauer's 1961
observation that the erasure of a bit of information must dissipate at least
`k_B T ln 2` of energy as heat. The principle binds together three traditions
that are usually studied apart: thermodynamics (the second law, entropy
production), information theory (Shannon entropy, the data-processing
inequality), and the theory of computation (reversibility, irreversibility,
complexity).

The purpose of Entropy-Bounded Computation is to isolate the *purely
mathematical skeleton* common to all three. We do not model heat, energy, or
probability distributions over inputs in their full generality. Instead we take
the cleanest possible object — a deterministic map between finite state spaces —
and a single real-valued functional on it — the log of the cardinality — and we
prove that the expected information laws hold as theorems. The payoff is
conceptual clarity: each of the second law, the data-processing inequality, and
Landauer's principle turns out to be a one-line consequence of how cardinality
behaves under bijections, products, and surjections.

### 1.2 Relation to cardinality-only bridges

A coarser approach bounds *cardinality* directly through injective encodings:
an injection `S ↪ T` certifies `|S| ≤ |T|`. EBC promotes this to a genuine
real-valued entropy functional `H(S) = log₂ |S|` and proves its algebra
(additivity, monotonicity, invariance). The logarithm is what converts the
multiplicative structure of cardinalities into the additive structure of an
information *currency*, making compositional reasoning about cost possible.

### 1.3 Contributions

1. A single definition of entropy as `H(S) = log₂ |S|` over finite state spaces.
2. Ground facts: nonnegativity and the zero-entropy characterization of
   single-state spaces (Theorems 1–2).
3. Invariance of entropy under reversible computation (Theorem 3).
4. Additivity of entropy over independent product state spaces (Theorem 4).
5. A data-processing/second-law inequality for surjective deterministic maps
   (Theorem 5).
6. A sharp Landauer's principle: strict positivity of erasure cost and exact
   accounting of released entropy (Theorems 6–7).
7. A companion compression-correctness theorem linking operator norms to
   decryption correctness windows (Theorem 8).

---

## 2. Definitions

Throughout, a **state space** is a finite type `S` (a `Fintype`), with
cardinality `|S|`. We write `log₂` for the base-2 logarithm of a real number,
with the conventions `log₂ x = (ln x)/(ln 2)` for `x > 0`, and `log₂ x = 0` for
`x ≤ 0` (the convention used by the underlying real-logarithm function; it never
affects our results, where arguments are positive integers `≥ 1`).

> **Definition 2.1 (Entropy of a state space).**
> For a finite state space `S`,
> `H(S) := log₂ |S|`,
> the Shannon entropy, in bits, of the uniform distribution over `S`.

This is well-defined for any `Fintype`. When `S` is nonempty, `|S| ≥ 1` and the
argument of the logarithm is a positive integer.

> **Definition 2.2 (Reversible computation).**
> A computational step from `S` to `T` is **reversible** if it is realized by a
> bijection `e : S ≃ T`. Equivalently, no two distinct input states map to the
> same output and every output is realized.

> **Definition 2.3 (Independent composition).**
> Two state spaces `S` and `T` compose **independently** as the product `S × T`,
> whose states are all pairs `(s, t)`; `|S × T| = |S| · |T|`.

> **Definition 2.4 (Erasure).**
> An **erasure** of `S` is a deterministic step `S → T` whose target `T` has a
> single state (`|T| = 1`); every input is reset to the same fixed output.

> **Definition 2.5 (Entropy defect).**
> For a deterministic step `f : S → T`, the **entropy defect** is
> `defect(f) := H(S) − H(range f)`, the information irreversibly discarded by the
> step. (Used in §7 on future work.)

---

## 3. Ground facts

> **Theorem 1 (Nonnegativity).** For any nonempty finite state space `S`,
> `H(S) ≥ 0`.

*Proof sketch.* Nonemptiness gives `|S| ≥ 1`, so the real number `|S|` is `≥ 1`.
The base-2 logarithm is nonnegative on `[1, ∞)` (base `2 > 1`). Hence
`H(S) = log₂ |S| ≥ log₂ 1 = 0`. ∎

> **Theorem 2 (Single-state spaces store no information).**
> If `|S| = 1` then `H(S) = 0`.

*Proof sketch.* Substituting `|S| = 1` gives `H(S) = log₂ 1 = 0`. ∎

These two results pin down the calibration of the functional: the minimum of
entropy is `0`, attained exactly by deterministic (single-state) spaces. They
are the base of every later argument — Theorem 2 in particular is reused
verbatim inside the erasure accounting of Theorem 7.

---

## 4. Reversibility is free

> **Theorem 3 (Reversibility preserves entropy).**
> If there is a bijection `e : S ≃ T`, then `H(S) = H(T)`.

*Proof sketch.* A bijection between finite types implies equal cardinalities,
`|S| = |T|` (cardinality is a bijection invariant). Entropy depends only on
cardinality, so `H(S) = log₂ |S| = log₂ |T| = H(T)`. ∎

**Interpretation.** Reversible computation generates no entropy. This is the
mathematical counterpart of the thermodynamic statement that reversible
processes are isentropic, and it underlies the theoretical possibility of
dissipationless (reversible/adiabatic) computing. Theorem 3 is the equality case
that bounds the inequality of Theorem 5 from above.

---

## 5. Additivity over independent systems

> **Theorem 4 (Additivity).** For nonempty finite state spaces `S` and `T`,
> `H(S × T) = H(S) + H(T)`.

*Proof sketch.* The product state space has cardinality `|S × T| = |S| · |T|`.
Both factors are positive (nonemptiness), so the product rule for logarithms
applies: `log₂(|S|·|T|) = log₂ |S| + log₂ |T|`. The left side is `H(S × T)`, the
right side `H(S) + H(T)`. The only subtlety is the nonvanishing of the factors,
which nonemptiness supplies (`|S|, |T| ≠ 0`). ∎

**Interpretation.** Additivity makes entropy a *currency* that composes:
the information content of a system built from independent subsystems is the sum
of their contents. This is precisely the property that justifies summing bit
counts across registers, fields, or pipeline stages.

---

## 6. The second law and Landauer's principle

### 6.1 Data-processing inequality

> **Theorem 5 (Second law / data-processing inequality).**
> Let `S` be nonempty and let `f : S → T` be a surjective deterministic map.
> Then `H(T) ≤ H(S)`.

*Proof sketch.* A surjection from a finite type forces `|T| ≤ |S|`
(`Fintype.card_le_of_surjective`). Moreover `T` is nonempty (it is the image of a
nonempty domain), so `|S|` and `|T|` are positive reals. The base-2 logarithm is
monotone increasing on the positive reals (base `2 > 1`), so `|T| ≤ |S|` gives
`log₂ |T| ≤ log₂ |S|`, i.e. `H(T) ≤ H(S)`. ∎

**Interpretation.** A deterministic computation cannot increase entropy: the
output carries no more information than the input. This single inequality is
simultaneously (i) the information-theoretic data-processing inequality
specialized to deterministic channels with uniform inputs, and (ii) the
computational second law of thermodynamics. Theorem 3 (bijections) is exactly
its equality case.

### 6.2 Landauer's principle

> **Theorem 6 (Strict positivity of erasure cost).**
> If `|S| ≥ 2`, then `H(S) > 0`.

*Proof sketch.* For base `2 > 1`, `log₂ x > 0` whenever `x > 1`. Since
`|S| ≥ 2 > 1` as a real number, `H(S) = log₂ |S| > 0`. ∎

> **Theorem 7 (Exact erasure accounting).**
> Let `S` be nonempty and let `T` be a single-state space (`|T| = 1`). Then
> `H(S) − H(T) = H(S)` and `H(S) − H(T) ≥ 0`.

*Proof sketch.* By Theorem 2, `H(T) = 0`. Substituting, `H(S) − H(T) =
H(S) − 0 = H(S)`, which establishes the first claim. Nonnegativity of the
difference is then Theorem 1. ∎

**Interpretation.** Together, Theorems 6 and 7 are Landauer's principle as
arithmetic. Erasure — the maximally forgetful step, collapsing every state to a
fixed one — dissipates entropy equal to the full source entropy `H(S)`, and this
is strictly positive whenever there were at least two possibilities to forget.
Erasing one bit (`|S| = 2`) costs exactly `log₂ 2 = 1` bit; erasing a byte costs
`8` bits. This is the irreducible toll Landauer identified, recovered here from
counting and logarithms alone.

---

## 7. A companion application bridge: compression correctness

The entropy laws govern *how much* information a step can carry or destroy. A
complementary question in coding and cryptography is *whether* a lossy linear
transformation preserves correctness. The following result, proved in the same
spirit (a single chain of inequalities), connects the **operator norm** of a
linear compression map to a decoder's error-tolerance window.

> **Theorem 8 (Compression preserves correctness).**
> Let `𝕜` be a nontrivially normed field and `M`, `N` normed `𝕜`-spaces. Let
> `f : M →L[𝕜] N` be a continuous linear compression map with operator norm
> `‖f‖`. Let `encode : Message → N`, `decode : N → Message`, a message `m`, a
> noise vector `e ∈ M`, and a radius `δ ≥ 0` be given. Suppose
> 1. the noise is bounded: `‖e‖ ≤ δ`; and
> 2. the decoder is correct within the amplified window: for all `x`,
>    `‖x − encode m‖ ≤ ‖f‖ · δ ⟹ decode x = m`.
>
> Then `decode(encode m + f e) = m`.

*Proof sketch.* Compute the deviation of the received point from the true
codeword: `(encode m + f e) − encode m = f e`. By the defining bound of the
operator norm, `‖f e‖ ≤ ‖f‖ · ‖e‖`. By hypothesis 1 and nonnegativity of `‖f‖`,
`‖f‖ · ‖e‖ ≤ ‖f‖ · δ`. Chaining, `‖(encode m + f e) − encode m‖ ≤ ‖f‖ · δ`.
Hypothesis 2 then yields `decode(encode m + f e) = m`. ∎

**Interpretation.** The operator norm `‖f‖` is the exact factor by which the
compression map can amplify noise. Theorem 8 turns a NIST-style "decryption
failure probability is zero below threshold" guarantee into a clean functional
inequality: choose `δ` so that `‖f‖ · δ` lies inside the decoder's correctness
radius, and compression is certified safe. A second formulation packages `δ` as
the `radius` of a `ComplianceWindow` and the noise bound as a
`LinearNoiseCertified` certificate, the form most natural for standards-
compliance arguments about lattice-based key-encapsulation mechanisms.

---

## 8. Algorithms

Although the theorems are abstract, the entropy functional and its laws are
directly computable for explicit finite state spaces. We summarize the core
computations as algorithms (full Python in the accompanying demo).

### 8.1 Entropy of a state space

Given `|S| = N ≥ 1`, return `log₂ N`. Complexity: `O(1)` arithmetic
(plus the cost of one logarithm). Validates Definition 2.1 and, for `N = 1`,
Theorem 2.

### 8.2 Erasure cost

Given a source count `N` and a target count `1`, return the released entropy
`log₂ N − log₂ 1 = log₂ N` (Theorem 7), and assert it is `> 0` when `N ≥ 2`
(Theorem 6). Complexity: `O(1)`.

### 8.3 Pipeline entropy accounting

Given a list of stage state-counts `[N₀, N₁, …, N_k]` representing the reachable
state space after each deterministic stage (with `N_{i+1} ≤ N_i`), compute the
per-stage entropy drop `log₂ N_i − log₂ N_{i+1} ≥ 0` and the total dissipated
entropy `log₂ N₀ − log₂ N_k`. Each drop is nonnegative by Theorem 5. The total
telescopes — a discrete echo of additivity (Theorem 4). Complexity: `O(k)`.

### 8.4 Compression safety certification

Given `‖f‖`, `δ`, and the decoder's correctness radius `r`, certify safety by
checking `‖f‖ · δ ≤ r`. If so, Theorem 8 guarantees correct decoding for all
noise with `‖e‖ ≤ δ`. Complexity: `O(1)`.

---

## 9. Applications

**Reversible and low-power computing.** Theorem 3 formalizes why reversible logic
can, in principle, compute without entropy cost, while Theorems 6–7 quantify the
unavoidable toll of every irreversible erasure. This is the theoretical backbone
of adiabatic logic and the search for energy-efficient hardware near the
Landauer limit.

**Cryptographic one-wayness.** The security value of hash functions and other
compressing primitives is that they forget: many inputs map to one output.
Theorem 5 makes precise that the discarded information cannot be recovered by any
deterministic post-processing — the entropy of the digest space is strictly
below that of the message space.

**Lattice cryptography compliance.** Theorem 8 gives a functional-analytic route
from operator-norm bounds to certified decryption correctness, matching the
zero-failure-below-threshold guarantees demanded by post-quantum standards for
lattice-based key-encapsulation mechanisms.

**Information accounting for pipelines.** Additivity (Theorem 4) and the
telescoping of stage defects (§8.3) let designers budget the information lost
across a multi-stage computation as a single, well-defined total.

---

## 10. Discussion

The development is intentionally minimal, and that is its strength. By choosing
the uniform-distribution Shannon entropy `log₂ |S|` as the sole functional, every
law of interest reduces to an elementary property of cardinality:

| Information law | Cardinality fact | Theorem |
|---|---|---|
| Nonnegativity | `|S| ≥ 1` | 1 |
| Zero information | `|S| = 1` | 2 |
| Reversibility free | `|S| = |T|` under bijection | 3 |
| Additivity | `|S × T| = |S|·|T|` | 4 |
| Second law | `|T| ≤ |S|` under surjection | 5 |
| Landauer (strict) | `|S| ≥ 2 ⟹ |S| > 1` | 6 |
| Landauer (exact) | `|T| = 1 ⟹ H(T)=0` | 7 |

The price of minimality is generality: we model uniform distributions over
finite states, not arbitrary input distributions, and we treat single steps, not
the dynamics of full machines. Section 11 sketches how to lift these
restrictions without leaving the finite, mechanically checkable setting.

---

## 11. Future Directions

**Direction 1 — Subadditivity under arbitrary deterministic maps.**
Strengthen Theorem 5 by dropping surjectivity: for *any* `f : S → T`, the image
`range f` is the true reachable output space, and `H(range f) ≤ H(S)`, with
equality iff `f` is injective. This makes the entropy defect
`defect(f) = H(S) − H(range f)` an *exact* accounting of the information
irreversibly discarded. The key fact is that `|range f| ≤ |S|` always holds, with
equality exactly when `f` is injective — the entire reversibility/irreversibility
dichotomy is encoded in the cardinality of the range, with no probability theory.
Theorems 3 and 5 are the two extreme (bijective, surjective) cases; the general
statement is their natural interpolation and is reachable with standard
range/image cardinality lemmas.

**Direction 2 — Compositional cost: defect additivity along pipelines.**
Define `defect(f) = H(S) − H(range f)` and prove that for a pipeline `g ∘ f` the
total dissipated entropy is bounded by the sum of stage defects:
`defect(g ∘ f) ≤ defect(f) + defect(g)`, with equality when stages do not
re-merge already-merged states. This is the EBC analogue of additivity of
thermodynamic cost along a process, building on the additivity already
established in Theorem 4 and the telescoping computation of §8.3.

**Further directions.** (i) Lift from uniform distributions to general input
distributions, recovering full Shannon entropy and the general data-processing
inequality. (ii) Connect the entropy defect to concrete energy bounds via the
Landauer constant `k_B T ln 2`. (iii) Extend the compression bridge (Theorem 8)
to randomized noise models, producing decryption-failure-probability bounds
rather than worst-case windows.

---

## 12. Conclusion

Entropy-Bounded Computation packages the informational heart of the second law of
thermodynamics for computation into seven short theorems over finite state
spaces, with a companion compression-correctness bridge. From the single
definition `H(S) = log₂ |S|` follow nonnegativity, the zero-entropy of
single-state machines, the freeness of reversible computation, additivity over
independent systems, the data-processing/second-law inequality, and a sharp
Landauer's principle. The framework substantiates Landauer's slogan that
"information is physical" by deriving its mathematical content from elementary
facts about cardinality and the logarithm — and it lays a mechanically
checkable foundation for an information-theoretic theory of computational cost.
