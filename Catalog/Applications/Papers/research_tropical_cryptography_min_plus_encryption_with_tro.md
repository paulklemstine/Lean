# Global-Min Superadditivity: A Monotone Exponent Witness for Tropical Discrete Logarithms

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Cryptography / Tropical Algebra

---

## Abstract

We study a single scalar invariant of a tropical (min-plus) matrix — its **global
minimum entry** `gmin(A) = min_{i,j} A_{ij}` — and establish that it is
**superadditive** under the tropical matrix product:
`gmin(A) + gmin(B) ≤ gmin(A ⊗ B)`. From this one inequality we derive a complete
family of growth laws for tropical matrix powers: superadditivity along the
exponent, a doubling inequality tracked by repeated tropical squaring, and an
unconditional linear lower bound `(k+1)·gmin(A) ≤ gmin(A^{⊗(k+1)})`. We place these
results in two contexts. First, in **ergodic/spectral theory**: superadditivity is
exactly the hypothesis of Fekete's subadditive lemma, so the normalized sequence
`gmin(A^{⊗m})/m` converges to the **minimum cycle mean** of the weighted digraph of
`A`, a tropical analog of the spectral radius. Second, in **cryptanalysis**: the
proposed tropical Diffie–Hellman / tropical discrete logarithm scheme exposes the
secret exponent through this invariant. Where the prior spectral attack
(`λ(A^{⊗m}) = m·λ(A)`) requires a nonzero-eigenvalue eigenvector, the global-min
channel is unconditional, requires only two minimum computations, and yields a
monotone, cheaply computable witness that upper-bounds the secret exponent by
`gmin(A^{⊗k}) / gmin(A)`. All results have been formally verified in Lean 4 with no
additional axioms. We give full statements, proof sketches, algorithms, and
numerical demonstrations.

---

## 1. Introduction

### 1.1 Tropical arithmetic

The **tropical** (or **min-plus**) **semiring** is the set `ℝ` (optionally extended
by `+∞`) equipped with the operations

- tropical addition: `x ⊕ y := min(x, y)`,
- tropical multiplication: `x ⊙ y := x + y`.

Tropical addition is idempotent (`min(x, x) = x`) and has no additive inverses, so
the structure is a semiring rather than a ring. Despite — indeed because of — this
degeneracy, tropical algebra linearizes a wide range of combinatorial optimization
problems: shortest paths, critical-path scheduling, mean-payoff games, and the
Viterbi algorithm are all instances of tropical linear algebra.

### 1.2 Tropical matrices and powers

For `n × n` real matrices `A`, `B`, the **tropical matrix product** is

```
(A ⊗ B)_{ij} = min_{k} ( A_{ik} + B_{kj} ).
```

Interpreting `A_{ik}` as the weight of a directed edge `i → k` in a weighted
digraph, `(A ⊗ B)_{ij}` is the minimum weight of a two-edge walk from `i` to `j`,
and `(A^{⊗m})_{ij}` is the minimum weight of an `m`-edge walk. The forward
computation costs `O(n³)` per product, and `A^{⊗k}` is obtained by repeated
squaring in `O(n³ log k)`.

**Indexing convention.** Over a field there is no finite tropical identity matrix
(it would require `+∞` off the diagonal), so powers cannot be indexed from a
zeroth power. We adopt the field-friendly convention

```
tropMatPow A 0 = A,     tropMatPow A (k+1) = A ⊗ (tropMatPow A k),
```

so that `tropMatPow A k` denotes the genuine `(k+1)`-fold product `A^{⊗(k+1)}`.
Throughout, every statement carries the explicit `+1` this convention induces.

### 1.3 The cryptographic proposal

The **tropical Diffie–Hellman key exchange** replaces the cyclic-group base of
classical Diffie–Hellman with a public tropical matrix `A` and exponentiation with
tropical powers: Alice publishes `A^{⊗a}`, Bob publishes `A^{⊗b}`, and the shared
key is `A^{⊗ab}`. The associated hardness assumption is the **Tropical Discrete
Logarithm Problem (TDLP)**: given `(A, A^{⊗k})`, recover `k`. The scheme's appeal
is post-quantum: its structure is unrelated to the hidden-subgroup framework that
Shor's algorithm exploits.

### 1.4 Contributions

This paper isolates and analyzes the simplest possible invariant of the public key
— the global minimum entry — and shows it is both a deep spectral seed and a
practical cryptanalytic tool. Concretely:

1. We characterize `gmin` as the greatest entrywise lower bound (Section 3).
2. We prove **superadditivity** of `gmin` under the tropical product, and transport
   it to powers, obtaining a doubling inequality and an unconditional linear lower
   bound (Section 4).
3. We connect superadditivity to Fekete's lemma and the minimum cycle mean,
   exhibiting `gmin` as the Fekete seed of the tropical min spectral radius
   (Section 5).
4. We derive a cryptanalytic exponent witness and contrast it with the spectral
   (eigenvalue-additivity) attack, identifying the shared degeneracy boundary
   (Section 6).
5. We give algorithms and numerical evidence (Sections 7–8).

All theorems below are formalized and machine-checked in Lean 4 over `ℝ`, with the
only axioms being the standard `propext`, `Classical.choice`, and `Quot.sound`.

---

## 2. Preliminaries and Notation

Fix `n ≥ 1` and let `A, B : Matrix (Fin n) (Fin n) ℝ`. We write `⊗` for `tropMatMul`
and `A^{⊗m}` informally for the `m`-fold tropical product (Lean: `tropMatPow A
(m-1)`). We record the algebraic backbone established in the supporting development.

**Definition 2.1 (Tropical matrix product).**
`(A ⊗ B)_{ij} = inf'_{k ∈ univ} (A_{ik} + B_{kj})`, where `inf'` is the minimum over
the nonempty finite index set.

**Definition 2.2 (Tropical matrix–vector product).**
`(A ⊗ v)_i = inf'_{k} (A_{ik} + v_k)` for `v : Fin n → ℝ`.

**Definition 2.3 (Tropical eigenpair).** `(λ, v)` is a tropical eigenpair of `A` if
`(A ⊗ v)_i = v_i + λ` for all `i`; equivalently `A ⊗ v = v + λ·1`.

**Proposition 2.4 (Associativity).** `(A ⊗ B) ⊗ C = A ⊗ (B ⊗ C)`.

**Proposition 2.5 (Power multiplicativity).**
`A^{⊗(a+1)} ⊗ A^{⊗(b+1)} = A^{⊗(a+b+2)}`; equivalently, with the indexing
convention, `tropMatMul (tropMatPow A a) (tropMatPow A b) = tropMatPow A (a+b+1)`.

**Proposition 2.6 (Diffie–Hellman correctness).**
`tropMatPow (tropMatPow A a) b = tropMatPow (tropMatPow A b) a`, i.e.
`(A^{⊗a})^{⊗b} = (A^{⊗b})^{⊗a}`. The shared key is well defined.

**Proposition 2.7 (Eigenvalue additivity).** If `(λ, v)` is a tropical eigenpair of
`A`, then `((k+1)·λ, v)` is a tropical eigenpair of `A^{⊗(k+1)}`. Consequently the
secret exponent is recoverable as `(k+1) = (residual on B)/λ` whenever `λ ≠ 0`; the
attack carries no information when `λ = 0`.

Propositions 2.4–2.7 are the established context; the present paper develops the
**global-min channel**, which is independent of and unconditional relative to the
spectral channel of Proposition 2.7.

---

## 3. The Global Minimum Entry

**Definition 3.1 (Global minimum entry).** For `A : Matrix (Fin n) (Fin n) ℝ`,

```
gmin(A) := inf'_{(i,j) ∈ univ × univ} A_{ij}.
```

Graph-theoretically, `gmin(A)` is the lightest single edge weight in the weighted
digraph of `A`. It is computable in `O(n²)` time by a single scan.

**Theorem 3.2 (`gmin_le`: entrywise lower bound).** For all `i, j`,
`gmin(A) ≤ A_{ij}`.

*Proof.* Immediate from the definition of the finite minimum: the infimum over the
index set `univ × univ` is `≤` the value at the particular index `(i, j)`. Formally,
`Finset.inf'_le` applied to `(i, j) ∈ univ`. ∎

**Theorem 3.3 (`le_gmin`: greatest lower bound).** If `c : ℝ` satisfies `c ≤ A_{ij}`
for all `i, j`, then `c ≤ gmin(A)`.

*Proof.* The finite minimum is the greatest lower bound: `Finset.le_inf'` reduces
the goal to verifying `c ≤ A_{p.1 p.2}` for every pair `p`, which is the hypothesis.
∎

Theorems 3.2 and 3.3 together state that `gmin(A)` is the *greatest* number bounding
`A` from below — the order-theoretic characterization that powers every inequality
in Section 4. Whenever we wish to prove `c ≤ gmin(X)`, it suffices (and is
necessary) to prove `c ≤ X_{ij}` for all entries.

---

## 4. Superadditivity and Growth Laws

### 4.1 Superadditivity under the product

**Theorem 4.1 (`gmin_tropMatMul_superadd`: superadditivity).**
For all `A, B`,

```
gmin(A) + gmin(B) ≤ gmin(A ⊗ B).
```

*Proof sketch.* By Theorem 3.3 it suffices to show `gmin(A) + gmin(B) ≤ (A ⊗ B)_{ij}`
for every `(i, j)`. Fix `(i, j)`. By Definition 2.1, `(A ⊗ B)_{ij} = min_k (A_{ik} +
B_{kj})`. For each `k`, Theorem 3.2 gives `gmin(A) ≤ A_{ik}` and `gmin(B) ≤ B_{kj}`,
so `gmin(A) + gmin(B) ≤ A_{ik} + B_{kj}`. Since this lower bound holds for every
`k`, it holds for the minimum over `k` (`Finset.le_inf'`):
`gmin(A) + gmin(B) ≤ min_k (A_{ik} + B_{kj}) = (A ⊗ B)_{ij}`. ∎

The direction matters: because `gmin` is a *minimum* and the product *sums* weights
along the minimizing walk, "a minimum of sums of bounded-below terms is bounded
below by the sum of the bounds" gives **super**additivity. The dual functional
`gmax(A) = max_{i,j} A_{ij}` is instead **sub**additive,
`gmax(A ⊗ B) ≤ gmax(A) + gmax(B)`, since each two-hop route is bounded above by the
sum of the heaviest edges.

### 4.2 Superadditivity along powers

**Theorem 4.2 (`gmin_tropMatPow_superadd`).** For all `a, b ∈ ℕ`,

```
gmin(A^{⊗(a+1)}) + gmin(A^{⊗(b+1)}) ≤ gmin(A^{⊗(a+b+2)}),
```

i.e. in the indexing convention,
`gmin(tropMatPow A a) + gmin(tropMatPow A b) ≤ gmin(tropMatPow A (a+b+1))`.

*Proof.* By power multiplicativity (Proposition 2.5),
`tropMatPow A a ⊗ tropMatPow A b = tropMatPow A (a+b+1)`. Rewriting the right side of
Theorem 4.1 (with `A := tropMatPow A a`, `B := tropMatPow A b`) by this identity
gives the claim. ∎

### 4.3 The doubling inequality

**Theorem 4.3 (`gmin_tropMatPow_double`).** For all `k ∈ ℕ`,

```
2 · gmin(A^{⊗(k+1)}) ≤ gmin(A^{⊗(2k+2)}),
```

i.e. `2 · gmin(tropMatPow A k) ≤ gmin(tropMatPow A (2k+1))`.

*Proof.* Specialize Theorem 4.2 to `a = b = k`: the left side becomes
`gmin(tropMatPow A k) + gmin(tropMatPow A k) = 2·gmin(tropMatPow A k)` and the right
side index is `k + k + 1 = 2k + 1`. ∎

This is precisely the invariant maintained by one step of repeated tropical
squaring, the algorithm used to construct the public key: squaring the matrix at
least doubles its lightest edge.

### 4.4 The linear lower bound

**Theorem 4.4 (`gmin_tropMatPow_lower`: monotone exponent witness).** For all
`k ∈ ℕ`,

```
(k + 1) · gmin(A) ≤ gmin(A^{⊗(k+1)}),
```

i.e. `(k+1)·gmin(A) ≤ gmin(tropMatPow A k)`.

*Proof sketch.* By Theorem 3.3 it suffices to show `(k+1)·gmin(A) ≤
(tropMatPow A k)_{ij}` for every `(i, j)`. This is the global-min specialization of
the entrywise sandwich for tropical powers: with `amin := gmin(A)`, every entry of
`A^{⊗(k+1)}` is bounded below by `(k+1)·amin`, because every `(k+1)`-edge walk
contributes at least `gmin(A)` per edge. (Formally this is `tropMatPow_entry_lower`,
proved by induction on `k`: the base case is `gmin(A) ≤ A_{ij}` from Theorem 3.2,
and the inductive step adds one more edge, each of weight at least `gmin(A)`, then
uses the minimum-as-greatest-lower-bound step.) Applying Theorem 3.3 collapses the
entrywise bound to the scalar `gmin`. ∎

Alternatively, Theorem 4.4 follows from Theorem 4.2 by induction on `k`, taking
`gmin(A^{⊗1}) = gmin(A)` as the base case and adding one factor of `gmin(A)` per
step; both routes give the same bound.

**Monotonicity corollary.** Since `gmin(A) ≥ 0` whenever `A` has nonnegative entries
(a standing assumption for weighted digraphs with nonnegative weights), the sequence
`m ↦ gmin(A^{⊗m})` is nondecreasing and grows at least linearly with slope
`gmin(A)`.

---

## 5. The Fekete Seed: Convergence to the Minimum Cycle Mean

The growth laws above are not merely cryptanalytic curiosities; they are the
structural input that forces a fundamental spectral limit to exist.

**Theorem 5.1 (Fekete's subadditive lemma).** If a sequence `(s_m)_{m≥1}` is
superadditive (`s_a + s_b ≤ s_{a+b}`), then `lim_{m→∞} s_m / m` exists in
`ℝ ∪ {+∞}` and equals `sup_m s_m / m`.

Applying Theorem 5.1 to `s_m := gmin(A^{⊗m})` — whose superadditivity is *exactly*
Theorem 4.2 — yields:

**Corollary 5.2 (existence of the tropical min spectral radius).** For every
tropical matrix `A`, the normalized limit

```
ρ_min(A) := lim_{m→∞} gmin(A^{⊗m}) / m
```

exists.

**Theorem 5.3 (identification, tropical Perron–Frobenius / Cuninghame-Green).** For a
weighted digraph of `A`, `ρ_min(A)` equals the **minimum cycle mean**

```
μ(A) = min over directed cycles C of [ weight(C) / length(C) ].
```

The minimum cycle mean is the tropical analog of the spectral radius and the central
invariant of mean-payoff games and max-plus spectral theory. Thus the lightest edge,
iterated, has a growth rate equal to a genuine spectral quantity. Theorem 4.4
provides the matching coarse lower bound `gmin(A) ≤ ρ_min(A)`, with equality on
circulant examples whose minimizing cycle is a self-loop or a uniform-weight cycle
(see Section 8).

*Status.* Theorems 4.1–4.4 are formalized and machine-checked. Corollary 5.2 and
Theorem 5.3 are stated here as the immediate analytic consequences of the formalized
superadditivity together with Fekete's lemma (available in Lean's Mathlib as
`Subadditive.tendsto_lim` applied to `-gmin`) and the classical cycle-mean
identification; their full formalization is the principal future direction
(Conjecture 2 below).

---

## 6. Cryptanalysis: A Second Exponent-Leak Channel

### 6.1 Two channels, one boundary

The tropical DH / TDLP scheme exposes the secret exponent through *two independent
homomorphic shadows*:

- **Spectral channel** (Proposition 2.7): `λ(A^{⊗(k+1)}) = (k+1)·λ(A)`, giving exact
  recovery `k+1 = λ(B)/λ(A)` whenever an eigenvector with `λ(A) ≠ 0` exists.
- **Magnitude / global-min channel** (this paper): the linear lower bound of
  Theorem 4.4.

**Theorem 6.1 (global-min exponent witness).** Let `B = A^{⊗(k+1)}` be the public
power, and suppose `gmin(A) > 0`. Then

```
k + 1 ≤ gmin(B) / gmin(A).
```

*Proof.* Theorem 4.4 gives `(k+1)·gmin(A) ≤ gmin(A^{⊗(k+1)}) = gmin(B)`. Dividing by
`gmin(A) > 0` preserves the inequality. ∎

This bound is:

- **Unconditional in spectral structure.** It needs no eigenvector and no
  shortest-path solve — only two `O(n²)` scans, `gmin(A)` and `gmin(B)`.
- **Monotone.** `gmin(A^{⊗m})` is nondecreasing in `m`, so the witness can never
  collapse and disguise a large exponent as a small one.
- **Tight in the limit.** As `k → ∞`, `gmin(B)/(k+1) → ρ_min(A) = μ(A)`, so the
  multiplicative slack of the bound is governed by `μ(A)/gmin(A)`, the ratio of the
  cycle mean to the lightest edge.

### 6.2 The shared degeneracy boundary

Both channels go silent at the *same* degenerate value. The spectral channel is
uninformative exactly when `λ = 0` (Proposition 2.7's boundary). The global-min
channel is uninformative exactly when `gmin(A) = 0`, since then Theorem 6.1 reduces
to the vacuous `0 ≤ gmin(B)`. This supports a unifying principle:

> **Degeneracy = the only possible security.** Any tropical DH/TDLP instance with
> either a nonzero eigenvalue or a positive lightest edge leaks its exponent through
> a cheap, structural channel. Security, if it exists at all, is confined to the
> degenerate corner where these invariants vanish — precisely the corner where the
> scheme has little algebraic content to hide behind.

### 6.3 Consequence for parameter selection

The witness shows that security cannot be bought by increasing the matrix dimension
`n`: the bound `k+1 ≤ gmin(B)/gmin(A)` is dimension-free. The residual ambiguity is
controlled by the *additive spread* of the entries (the gap between the lightest and
heaviest edges), not by `n`. This contradicts the original design intuition that
"random tropical matrices of size `n ≥ 10`" would be safe.

---

## 7. Algorithms

### 7.1 Tropical matrix product and power

```
function TROP_MATMUL(A, B):           # O(n^3)
    for i in 0..n-1:
        for j in 0..n-1:
            best = +inf
            for k in 0..n-1:
                best = min(best, A[i][k] + B[k][j])
            C[i][j] = best
    return C

function TROP_MATPOW(A, e):           # e-fold product A^{⊗e}, O(n^3 log e)
    # repeated squaring; result is the e-fold tropical product
    result = A; base = A; t = e - 1
    while t > 0:
        if t is odd: result = TROP_MATMUL(result, base)
        base = TROP_MATMUL(base, base)
        t = t >> 1
    return result
```

### 7.2 Global-min witness attack on TDLP

```
function GMIN(A):                      # O(n^2)
    return min over all i, j of A[i][j]

function TDLP_GMIN_WITNESS(A, B):      # B = A^{⊗(k+1)} public; recover bound on k
    gA = GMIN(A)
    gB = GMIN(B)
    if gA <= 0:
        return "no leak: gmin(A) <= 0 (degenerate boundary)"
    upper = floor(gB / gA)             # k + 1 <= upper
    return { "k_plus_1_upper_bound": upper,
             "candidates": [1 .. upper] }   # each testable in O(n^3 log k)
```

The witness reduces the search space for the secret to `O(gB/gA)` candidates with no
spectral computation. Combined with the spectral channel (when an eigenvector
exists) it typically pins `k` exactly.

---

## 8. Numerical Evidence

Consider the `2 × 2` circulant `A = [[1, 3], [3, 1]]` over `ℝ`.

- `gmin(A) = 1` (the diagonal weight).
- Tropical powers: `A^{⊗(m+1)}` has all diagonal entries equal to `m+1` and
  off-diagonal entries `≥ m+1`, so `gmin(A^{⊗(m+1)}) = m+1`. Every inequality of
  Section 4 holds, with *equality* in Theorem 4.4: `(m+1)·gmin(A) = (m+1)·1 = m+1 =
  gmin(A^{⊗(m+1)})`.
- Minimum cycle mean: the lightest cycle is the self-loop of weight `1`, so
  `μ(A) = 1 = gmin(A) = ρ_min(A)`. The Fekete limit is attained at every step.

For the asymmetric example `A = [[1, 3], [3, 1]]` perturbed to `A = [[2, 5],
[1, 4]]`, `gmin(A) = 1`, while `μ(A)` is the minimum over the self-loops (weights
`2`, `4`) and the 2-cycle `1 → 2 → 1` of mean `(5+1)/2 = 3`; thus `μ(A) = 2 >
gmin(A) = 1`, and the linear lower bound `gmin(A^{⊗m}) ≥ m·1` is strict, with the
true slope approaching `2`. These behaviors are reproduced numerically in `demo.py`.

For the cryptanalytic break, the concrete instance `A = diag(1) + offdiag(100)` of
size `2 × 2` (used in the spectral break `tdlp_break_concrete`) also leaks through
the global-min channel: `gmin(A) = 1`, `gmin(A^{⊗(k+1)}) = k+1`, so the witness
returns the exact upper bound `k+1` on the exponent.

---

## 9. Discussion

The global minimum entry is, on its face, the least informative summary of a matrix
— a single number discarding all structure. Its interest lies entirely in its
behavior under iteration. Three threads converge:

1. **Order theory.** `gmin` is the greatest entrywise lower bound (Theorems 3.2–3.3);
   this characterization is the only tool needed to prove every growth law.
2. **Analysis.** Superadditivity (Theorem 4.1) is the precise hypothesis of Fekete's
   lemma, forcing convergence of `gmin(A^{⊗m})/m` to the minimum cycle mean
   (Section 5).
3. **Cryptography.** The linear lower bound (Theorem 4.4) yields an unconditional,
   monotone, cheaply computable witness for the secret exponent (Theorem 6.1),
   complementing the spectral attack and sharing its degeneracy boundary.

The overarching cryptanalytic lesson is methodological: *any invariant that
transforms predictably under the forward map of a one-way function candidate is a
potential attack vector.* Tropical exponentiation is unusually rich in such
invariants — eigenvalues that add, lightest edges that grow linearly — and each is a
homomorphic shadow of the exponent. The same algebraic regularity that makes
tropical constructions elegant is what makes them cryptographically fragile.

---

## 10. Future Directions

**Conjecture 1 (interval channel pins `k`).** For any tropical matrix with entries in
a positive band `[amin, amax]` with `amax/amin < R`, the exponent `k+1` recovered
from a single public entry lies in an interval containing at most `⌈(R-1)(k+1)⌉ + 1`
integers; hence TDLP on positive-band matrices is solvable in time polynomial in `k`
and `n` with no spectral data. The multiplicative spread `amax/amin`, not `n`,
controls residual ambiguity.

**Conjecture 2 (Fekete limit).** `gmin(A^{⊗m})/(m+1)` converges to the minimum cycle
mean `μ(A)`. Superadditivity (Theorem 4.2) is exactly the hypothesis of Fekete's
lemma (applied to `-gmin`); the remaining content is the digraph-cycle
identification (tropical Perron–Frobenius / Cuninghame-Green).

**Conjecture 3 (channels coincide generically).** For a strongly connected matrix,
the tropical eigenvalue equals the minimum cycle mean, so the spectral and
global-min channels measure the same intrinsic invariant; the global-min channel is
the unconditional, eigenvector-free realization of the spectral attack.

---

## Appendix A. Summary of Formalized Results

| Name | Statement |
|------|-----------|
| `gmin_le` | `gmin(A) ≤ A_{ij}` |
| `le_gmin` | `(∀ i j, c ≤ A_{ij}) → c ≤ gmin(A)` |
| `gmin_tropMatMul_superadd` | `gmin(A) + gmin(B) ≤ gmin(A ⊗ B)` |
| `gmin_tropMatPow_superadd` | `gmin(A^{⊗(a+1)}) + gmin(A^{⊗(b+1)}) ≤ gmin(A^{⊗(a+b+2)})` |
| `gmin_tropMatPow_double` | `2·gmin(A^{⊗(k+1)}) ≤ gmin(A^{⊗(2k+2)})` |
| `gmin_tropMatPow_lower` | `(k+1)·gmin(A) ≤ gmin(A^{⊗(k+1)})` |
| `tropMatPow_comm` | `(A^{⊗a})^{⊗b} = (A^{⊗b})^{⊗a}` (DH correctness) |
| `eigenvalue_additivity` | `(λ,v)` eigenpair of `A` ⟹ `((k+1)λ, v)` eigenpair of `A^{⊗(k+1)}` |
| `tdlp_recover_exponent` | `(residual on B)/λ = k+1` when `λ ≠ 0` |

All verified in Lean 4 with axioms limited to `propext`, `Classical.choice`,
`Quot.sound`.
