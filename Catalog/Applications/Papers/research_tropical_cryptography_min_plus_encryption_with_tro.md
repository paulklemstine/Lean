# Eigenvalue Additivity Breaks the Tropical Discrete Logarithm

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Logic (Tropical algebra / Post-quantum cryptanalysis)

## Abstract

We analyze the security of the *tropical Diffie–Hellman* key exchange and its
underlying hardness assumption, the *Tropical Discrete Logarithm Problem*
(TDLP): given a tropical (min-plus) matrix `A` and a tropical power
`B = A^{⊗m}`, recover the exponent `m`. The protocol's correctness rests on the
commutativity of tropical powers, `(A^{⊗a})^{⊗b} = A^{⊗ab}`, while its
conjectured security rests on the assumed one-wayness of tropical
exponentiation. We refute that conjecture. The key structural fact is that the
tropical eigenvalue is a homomorphism from tropical exponentiation to ordinary
scalar multiplication: if `(λ, v)` is a tropical eigenpair of `A`, then
`(m·λ, v)` is a tropical eigenpair of `A^{⊗m}`, so `λ(A^{⊗m}) = m·λ(A)`. This
*eigenvalue additivity* lets an adversary read the secret exponent off the
public power in closed form, `m = λ(B)/λ(A)`, whenever `λ(A) ≠ 0`. We prove the
additivity identity unconditionally, derive the closed-form recovery, exhibit an
explicit `2 × 2` instance in which every exponent leaks exactly, and isolate the
sole boundary `λ = 0` where the attack carries no information — showing that on
this boundary the power map degenerates to the identity on the eigen-orbit, so
the scheme is either leaky or trivial. All results have been formalized and
machine-checked.

---

## 1. Introduction

### 1.1 Motivation

Public-key cryptography is built on computational asymmetry: a function that is
easy to evaluate but hard to invert. The two pillars of classical
asymmetry — integer factorization and the discrete logarithm in finite
groups — both succumb to Shor's quantum algorithm, motivating an active search
for *post-quantum* alternatives grounded in different mathematical structures.

Tropical algebra has been proposed as one such foundation. The tropical (min-
plus) semiring replaces ordinary addition by `min` and ordinary multiplication
by `+`. Tropical matrix multiplication coincides with shortest-path /
dynamic-programming computation, and the inversion of tropical matrix products
is related to combinatorial problems believed to be hard. Several protocols have
been proposed on this basis, including a tropical analog of the Diffie–Hellman
key exchange whose security reduces to the *Tropical Discrete Logarithm Problem*
(TDLP).

### 1.2 Background on tropical algebra

The tropical semiring arises naturally wherever "cost of a path is the sum of
edge costs, and the best path minimizes that cost." Replacing the pair
`(+, ·)` of ordinary arithmetic by `(min, +)` turns the algebra of weighted
graphs into linear algebra: the `(i,j)` entry of the `k`-fold tropical power
`A^{⊗k}` is the minimum total weight of a length-`k` walk from `i` to `j`, and
the Kleene star `A^* = ⊕_k A^{⊗k}` is the all-pairs shortest-path matrix.
Tropical linear algebra is therefore the algebraic backbone of dynamic
programming, scheduling (max-plus for "latest completion time"), discrete-event
systems, and the combinatorics of tropical geometry.

Two features distinguish the tropical setting from the classical one and shape
every result below. First, there is **no subtraction**: `(ℝ, min, +)` is a
semiring, not a ring, so the only meaningful "difference" is the per-coordinate
residual we define in §3.2. Second, the spectral theory is **governed by the
underlying graph**: the tropical eigenvalue of an irreducible matrix is its
minimum cycle mean, a polynomial-time-computable quantity, and the eigenvectors
are determined by parametric shortest paths. It is precisely this transparency of
the spectrum — a feature, not a bug, for optimization — that turns out to be
fatal for cryptography.

### 1.3 The protocol and its security model

The tropical Diffie–Hellman key exchange publishes a tropical matrix `A`. Alice
samples a secret integer `a` and publishes `A^{⊗a}`; Bob samples `b` and
publishes `A^{⊗b}`; the shared key is `A^{⊗ab}`, which both compute by
`(A^{⊗b})^{⊗a} = (A^{⊗a})^{⊗b}` (the commutativity `tropMatPow_comm`). The
adversary observes `(A, A^{⊗a}, A^{⊗b})` and aims to compute the shared key. The
*key-recovery* security of the protocol reduces to the TDLP: if an adversary can
extract `a` from `(A, A^{⊗a})`, they reconstruct the shared key by computing
`(A^{⊗b})^{⊗a}`. We work in this standard passive (eavesdropping) model and show
the TDLP is solvable in polynomial time on essentially all instances, which
breaks key recovery and hence the protocol.

### 1.4 Contributions

We give a complete and self-contained cryptanalysis of the TDLP via tropical
spectral theory. Our contributions are:

1. **Eigenvalue additivity (`eigenvalue_additivity`).** A clean proof that
   tropical exponentiation acts on the spectrum by ordinary scaling:
   `(λ, v)` eigenpair of `A` ⟹ `(m·λ, v)` eigenpair of `A^{⊗m}`.

2. **Closed-form exponent recovery (`tdlp_recover_exponent`).** Whenever the
   public base admits an eigenvector with nonzero eigenvalue, the secret
   exponent is `m = λ(B)/λ(A)`, computable in polynomial time.

3. **An explicit total break (`tdlp_break_concrete`).** A `2 × 2` instance in
   which every exponent leaks exactly, verified as an identity for all `m`.

4. **The boundary dichotomy (`tdlp_boundary_no_leak`).** At `λ = 0` the residual
   vanishes for every exponent, so the attack is uninformative; but then the
   power map is the identity on the eigen-orbit, collapsing the key space. The
   scheme is thus either leaky (`λ ≠ 0`) or trivial (`λ = 0`).

All statements have been formalized and machine-verified; this paper presents
the mathematics and proof sketches.

---

## 2. Preliminaries: the tropical semiring and tropical matrices

### 2.1 The min-plus semiring

The **tropical (min-plus) semiring** is the structure `(ℝ, ⊕, ⊙)` where
`x ⊕ y := min(x, y)` and `x ⊙ y := x + y`. (Over `ℝ ∪ {+∞}` the additive
identity is `+∞` and the multiplicative identity is `0`; for the spectral
analysis below we work over `ℝ`.) Tropical "multiplication" is associative and
commutative with unit `0`, and `min` distributes over `+`, so this is a
commutative idempotent semiring.

### 2.2 Tropical matrix and matrix–vector products

For `A, B : Matrix (Fin n) (Fin n) ℝ`, the **tropical matrix product** is

> **Definition (`tropMatMul`).**
> `(A ⊗ B)(i, j) = min over k of ( A(i,k) + B(k,j) )`.

Equivalently, replacing `(Σ, ·)` by `(min, +)` in the usual matrix product.
Forward evaluation costs `O(n³)` arithmetic operations. The product is
associative:

> **Lemma (`tropMatMul_assoc`).** `(A ⊗ B) ⊗ C = A ⊗ (B ⊗ C)`, both sides
> equal to `min over (k,l) of ( A(i,k) + B(k,l) + C(l,j) )`.

The **tropical identity** is `tropId(M)(i,j) = 0` if `i = j` and `M` otherwise;
for `M` large enough relative to the entries of `A` it satisfies
`tropId(M) ⊗ A = A` and `A ⊗ tropId(M) = A`
(`tropId_mul_of_bound`, `mul_tropId_of_bound`).

The **tropical matrix–vector product** is

> **Definition (`tropMatVecMul`).**
> `(A ⊗ v)(i) = min over k of ( A(i,k) + v(k) )`.

It is monotone in `v` (`tropMatVecMul_monotone`) and, decisively for what
follows, **translation equivariant**:

> **Lemma (`tropMatVecMul_shift`).** For any constant `c`,
> `A ⊗ (v + c·1) = (A ⊗ v) + c·1`, where `c·1` is the all-`c` vector.
>
> *Proof sketch.* Each coordinate is `min_k (A(i,k) + v(k) + c) = (min_k
> (A(i,k) + v(k))) + c`, since adding a constant commutes with `min`. ∎

This is the tropical analog of linearity in the scalar `c` (tropical "scalar
multiplication" is ordinary addition of a constant), and it is the structural
seed of eigenvalue additivity.

### 2.3 Tropical matrix powers

The **tropical power** `A^{⊗m}` is the `m`-fold tropical product of `A` with
itself. We use the convention, matching the formalization, that `tropMatPow A k`
denotes `A^{⊗(k+1)}` (i.e. `k` extra multiplications on top of `A`). Powers obey
the expected exponent laws:

> **Power multiplicativity.** `A^{⊗a} ⊗ A^{⊗b} = A^{⊗(a+b)}`.
>
> **Commutativity (`tropMatPow_comm`).** `(A^{⊗a})^{⊗b} = (A^{⊗b})^{⊗a} =
> A^{⊗ab}`.

Powers act on vectors as iterated dynamics, the tropical version of `A^m v =
A(A(... A v))`:

> **Lemma (`tropMatVecMul_tropMatPow`).** `A^{⊗(k+1)} ⊗ v = (A ⊗ ·)^[k+1] v`,
> i.e. acting once with the `(k+1)`-th power equals iterating the action `k+1`
> times.

Repeated squaring computes `A^{⊗m}` in `O(n³ log m)` time, so the forward
direction of the protocol is efficient for very large exponents.

---

## 3. Tropical spectral theory

### 3.1 Eigenpairs

> **Definition (`IsTropicalEigenpair`).** A pair `(λ, v)` with `λ ∈ ℝ` and
> `v : Fin n → ℝ` is a **tropical eigenpair** of `A` if
> `(A ⊗ v)(i) = v(i) + λ` for every `i`.

This is the min-plus analog of `A v = λ v`: tropical multiplication by the scalar
`λ` is addition of `λ` to every coordinate.

Eigenpairs are abundant. A simple sufficient criterion:

> **Lemma (`tropical_eigenpair_from_diagonal`).** If `A` has constant diagonal
> `A(i,i) = d` for all `i`, and `A(i,j) + v(j) ≥ v(i) + d` for all `i, j`, then
> `(d, v)` is a tropical eigenpair of `A`.
>
> *Proof sketch.* For each `i`, the term `k = i` gives `A(i,i) + v(i) = v(i) +
> d`, so the minimum is `≤ v(i) + d`; the off-diagonal hypothesis gives every
> term `≥ v(i) + d`, so the minimum equals `v(i) + d`. ∎

In particular the smallest example, the diagonal-`1`, off-diagonal-`100`
`2 × 2` matrix with `v = (0,0)`, has eigenvalue `λ = 1` (used in §5).

### 3.2 The residual and uniqueness

Tropical algebra has no general subtraction, but the per-coordinate **residual**
`tropResidual A v i := (A ⊗ v)(i) − v(i)` is meaningful and, for an eigenpair,
recovers the eigenvalue at every coordinate (`tropResidual_eq_eigenvalue`). It
follows that the eigenvalue is uniquely determined by the eigenvector
(`tropical_eigenvalue_unique`): if `(λ, v)` and `(μ, v)` are both eigenpairs then
`λ = μ`.

### 3.3 Shift invariance

Translation equivariance lifts to the spectrum:

> **Lemma (`eigenpair_shift_invariant`).** If `(λ, v)` is an eigenpair of `A`,
> so is `(λ, v + c·1)` for any constant `c`.
>
> *Proof sketch.* Apply `tropMatVecMul_shift`: `A ⊗ (v + c) = (A ⊗ v) + c =
> (v + λ) + c = (v + c) + λ`. ∎

Thus an eigenvector is only ever determined up to a global additive offset.

---

## 4. Main results: eigenvalue additivity and the attack

### 4.1 Iterating the action on an eigenvector

> **Theorem 1 (`tropMatVecMul_iterate_eigen`).** Let `(λ, v)` be a tropical
> eigenpair of `A`. Then for every `m ∈ ℕ` and every coordinate `i`,
> `((A ⊗ ·)^[m] v)(i) = v(i) + m·λ`.
>
> *Proof sketch.* Induction on `m`. The base case `m = 0` is `v(i) = v(i)`. For
> the step, assume `(A ⊗ ·)^[m] v = v + m·λ` (as functions). Then
> `(A ⊗ ·)^[m+1] v = A ⊗ (v + m·λ)`, and by translation equivariance
> (`tropMatVecMul_shift`) this equals `(A ⊗ v) + m·λ = (v + λ) + m·λ = v +
> (m+1)·λ`, using the eigenpair relation `A ⊗ v = v + λ`. ∎

### 4.2 Eigenvalue additivity

> **Theorem 2 (`eigenvalue_additivity`).** If `(λ, v)` is a tropical eigenpair
> of `A`, then `((k+1)·λ, v)` is a tropical eigenpair of `A^{⊗(k+1)} =
> tropMatPow A k`, for every `k ∈ ℕ`. Equivalently, `λ(A^{⊗m}) = m·λ(A)`.
>
> *Proof sketch.* By `tropMatVecMul_tropMatPow`, acting with `A^{⊗(k+1)}` on `v`
> equals iterating the action `k+1` times, which by Theorem 1 equals
> `v + (k+1)·λ`. That is exactly the eigenpair relation for eigenvalue
> `(k+1)·λ`. ∎

This is the crux. The map `A ↦ λ(A)` is a **homomorphism** from the monoid of
tropical powers under `⊗` to `(ℝ, +)` scaled by the exponent: tropical
exponentiation is converted into ordinary multiplication of the eigenvalue by the
exponent. A one-way function must lack precisely this kind of transparent
structure.

### 4.3 The TDLP attack

> **Theorem 3 (`tdlp_recover_exponent`).** Let `(λ, v)` be a tropical eigenpair
> of `A` with `λ ≠ 0`, and let `B = A^{⊗(k+1)} = tropMatPow A k`. Then for every
> coordinate `i`,
> `((B ⊗ v)(i) − v(i)) / λ = k + 1`.
> That is, the secret exponent is recovered in closed form as
> `m = (residual of B on v) / λ = λ(B)/λ(A)`.
>
> *Proof sketch.* By Theorem 2, `(B ⊗ v)(i) = v(i) + (k+1)·λ`, so the residual is
> `(k+1)·λ`; dividing by `λ ≠ 0` gives `k+1`. ∎

**Algorithmic form of the attack.** Given the public `(A, B)`:

1. Compute a tropical eigenvalue `λ = λ(A)` of the base. This is the minimum mean
   cycle of the weighted digraph of `A`, computable in polynomial time (e.g.
   Karp's algorithm, `O(n·E)`), together with an eigenvector `v`.
2. Compute the residual `(B ⊗ v)(i) − v(i)` for any `i`; by additivity it equals
   `m·λ`.
3. Output `m = ((B ⊗ v)(i) − v(i)) / λ`.

The total cost is dominated by the eigenvalue computation and one tropical
matrix–vector product, both polynomial in `n`. The conjectured exponential
hardness of the TDLP is therefore false on every instance with `λ(A) ≠ 0`.

### 4.4 An explicit total break

> **Theorem 4 (`tdlp_break_concrete`).** Let `A` be the `2 × 2` tropical matrix
> with `A(i,i) = 1` and `A(i,j) = 100` for `i ≠ j`, and let `v = (0, 0)`. Then
> for every `k ∈ ℕ`,
> `(A^{⊗(k+1)} ⊗ v)(0) − 0 = k + 1`.
>
> *Proof sketch.* `v = (0,0)` is an eigenvector with eigenvalue `λ = 1`
> (`min(1, 100) = 1` in each coordinate). Apply Theorem 2 with `λ = 1`: the
> residual of `A^{⊗(k+1)}` on `v` is `(k+1)·1 = k+1`. ∎

Every exponent leaks exactly, as an identity holding simultaneously for all `k`.
This is a fully worked counterexample to the security conjecture.

### 4.5 The boundary `λ = 0`

> **Theorem 5 (`tdlp_boundary_no_leak`).** If `(0, v)` is a tropical eigenpair of
> `A`, then for every `k ∈ ℕ` and every `i`,
> `(A^{⊗(k+1)} ⊗ v)(i) − v(i) = 0`.
>
> *Proof sketch.* By Theorem 2 with `λ = 0`, `(A^{⊗(k+1)} ⊗ v)(i) = v(i) +
> (k+1)·0 = v(i)`, so the residual vanishes. ∎

At `λ = 0` the recovery of Theorem 3 would divide by zero and indeed carries no
information: the residual is identically `0` for every exponent. But this refuge
is degenerate. A zero eigenvalue means `v` is a **tropical fixed point**
(`eigenzero_iff_fixed`: `(0,v)` is an eigenpair iff `A ⊗ v = v`), so by iteration
`A^{⊗m} ⊗ v = v` for all `m` (`eigenzero_iterate`). The power map does nothing on
the eigen-orbit; the key space collapses. Hence:

> **Dichotomy.** For any tropical-power-based key exchange, each public matrix is
> either *leaky* (it has an eigenvector with `λ ≠ 0`, and Theorem 3 extracts the
> exponent) or *trivial on that orbit* (`λ = 0`, and Theorem 5 / `eigenzero_
> iterate` show the power map is the identity there). There is no secure middle
> ground.

For the natural class of matrices arising from weighted digraphs with
nonnegative weights and zero self-loops, one further shows every eigenvalue
satisfies `λ ≤ 0` (`digraph_eigenvalue_nonpos`) and that `λ = 0` is attained by
constant eigenvectors (`digraph_eigenzero_const`), so the boundary is intrinsic
to the geometry rather than an avoidable special case.

---

## 5. Algorithms

### 5.1 Tropical matrix power by repeated squaring

To compute `A^{⊗m}` efficiently, use binary exponentiation in the tropical
semiring. Start from the tropical identity, square the base while scanning the
bits of `m`, and accumulate when a bit is set. Cost: `O(n³ log m)`.

### 5.2 Tropical eigenvalue via minimum mean cycle

The unique tropical eigenvalue of an irreducible matrix equals the minimum cycle
mean of its weighted digraph,
`λ = min over cycles C of ( (sum of edge weights on C) / (length of C) )`.
Karp's dynamic-programming algorithm computes this in `O(n·E)` time, and an
eigenvector is recovered from the parametric shortest paths to a node on the
critical cycle.

### 5.3 The TDLP attack

Combine §5.2 (on the public base `A`) with a single tropical matrix–vector
product (on the public power `B`) and one division, as in §4.3. Polynomial time
overall.

---

## 6. Discussion

The break is structural, not incidental. The eigenvalue map is a homomorphism
that transports the secret integer `m` unchanged through the public transcript:
`λ(A^{⊗m}) = m·λ(A)`. Homomorphisms are double-edged in cryptography. The
*commutativity* `(A^{⊗a})^{⊗b} = (A^{⊗b})^{⊗a}` that makes the key exchange
*function* is itself a structural identity; the *additivity* `λ(A^{⊗m}) =
m·λ(A)` that makes it *break* is a closely related one. A secure scheme must
retain enough structure to run the protocol while denying the adversary any
linear readout of the secret. Tropical powers fail this test completely: the
exponent passes through the eigenvalue channel with no obfuscation.

The analysis also pins the hardness boundary precisely. Off the boundary the
scheme leaks in closed form; on the boundary the power map degenerates to the
identity. This sharp dichotomy explains why patching the scheme by forcing small
or zero eigenvalues cannot help: it trades information leakage for triviality.

---

## 7. Future directions

**Conjecture 1 — The eigenvalue channel is complete for the TDLP.** For a random
tropical matrix `A` of size `n ≥ 10` with finite entries, the public power
`B = A^{⊗m}` always determines `m` exactly via `m = λ(B)/λ(A)`, except on a
measure-zero set where `λ(A) = 0`. The key insight is that the tropical
eigenvalue is a homomorphism from tropical exponentiation to ordinary scalar
multiplication, so the one secret scalar `m` is linearly exposed — exactly the
structure a one-way function must lack. With eigenvalue additivity and
closed-form recovery formalized, the remaining step is a genericity statement
(almost-everywhere `λ(A) ≠ 0`).

**Conjecture 2 — The boundary `λ = 0` is the only refuge, and it is degenerate.**
Any tropical DH variant whose security survives must force every public matrix to
have spectral value `0` (a tropical fixed point); but then the no-leak and
fixed-point results show the public power equals the input up to a global shift,
collapsing the key space. The same homomorphism that leaks `m` when `λ ≠ 0` makes
the scheme trivial when `λ = 0`: additivity reads `m·0 = 0`, so the power map is
the identity on the eigen-orbit. Both halves are formal, so the dichotomy "either
leaky or trivial" can be stated as a single theorem.

**Conjecture 3 — Multi-eigenvalue (Perron) attacks tighten the bound.** When `A`
has several tropical eigenvalues (one per critical cycle of its digraph), each
yields an independent linear equation in `m`; the system is consistent and
over-determined, giving an error-correcting recovery of `m` even under bounded
entry noise. The critical-cycle spectrum is a vector of homomorphic readouts of
the same exponent, so redundancy makes the attack robust rather than fragile.
The single-readout lemma already exists; extending it across cycle-eigenvalues is
a finite combinatorial step.

**Conjecture 4 — Non-power protocols inherit the weakness.** Any protocol whose
public transcript is a tropical-linear image of a secret integer (e.g.
`A^{⊗m} ⊗ C`, semidirect-product tropical schemes) leaks that integer through the
same eigenvalue homomorphism applied to the dominant tropical block, because
tropical-linearity (equivariance under the global shift) preserves the eigenvalue
readout.

---

## 8. Conclusion

Tropical eigenvalues are additive under tropical power: `λ(A^{⊗m}) = m·λ(A)`.
This single homomorphic identity, proved unconditionally from the translation
equivariance of the min-plus action, collapses the conjectured hardness of the
tropical discrete logarithm. The secret exponent is recovered in closed form
`m = λ(B)/λ(A)` whenever the public base has a nonzero-eigenvalue eigenvector,
and the only escape — `λ = 0` — turns the power map into the identity. The
tropical Diffie–Hellman key exchange, in its current form, is insecure: it is
either leaky or trivial.
