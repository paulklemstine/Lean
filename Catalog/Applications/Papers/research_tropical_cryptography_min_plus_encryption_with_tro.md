# An Eigenline Counterexample to the Tropical Discrete Logarithm Problem

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Tropical algebra / Post-quantum cryptography

## Abstract

The *tropical discrete logarithm problem* (TDLP) proposes to hide a secret
integer exponent `k` inside iterated min-plus matrix multiplication: publish a
tropical matrix `A` and the tropical power `A^{⊗k}`, and challenge an adversary to
recover `k`. Tropical (min-plus) arithmetic has been advanced as a foundation for
post-quantum key exchange precisely because its unfamiliar algebra was hoped to
resist the index-calculus and quantum Fourier attacks that break classical
discrete logarithms. We give a fully formalized counterexample showing that the
TDLP is trivially broken whenever the hidden iteration is observed along an
*eigenline* of the underlying map. Our central observation is structural and
requires no probabilistic or number-theoretic assumptions: any tropical map that
is *scalar-equivariant* (commutes with the uniform additive shift, as min-plus
matrix multiplication always does) collapses, on any of its eigenvectors, to a
single scalar addition `k·λ`. Consequently the secret exponent is recovered from
a single input/output pair by ordinary subtraction. We present the result in two
layers: a concrete `1×1` model and an abstract eigenline theorem valid for maps
of arbitrary dimension and unknown internal structure. All five results stated
below are machine-verified over the `Nat` carrier of the min-plus semiring.

---

## 1. Introduction

Tropical mathematics replaces the field operations `(+, ×)` by the *min-plus*
semiring operations `(⊕, ⊙) = (min, +)`. Over the carrier `ℕ` (or `ℤ`, or
`ℝ ∪ {+∞}`), one defines tropical matrix multiplication by

```
(A ⊗ B)_{ij} = min_ℓ ( A_{iℓ} + B_{ℓj} ),
```

with the tropical matrix power `A^{⊗k}` obtained by iterating `⊗`. Because
`A^{⊗k}` is computable in `O(n³ log k)` time by repeated squaring while the
inverse map `k ↦ A^{⊗k}` was *conjectured* to be one-way, several authors
proposed a **tropical Diffie–Hellman** key exchange: Alice publishes `A^{⊗a}`,
Bob publishes `A^{⊗b}`, and the shared key is `A^{⊗ab}`. The presumed hardness of
recovering `a` (resp. `b`) — the **Tropical Discrete Logarithm Problem (TDLP)** —
underwrites the scheme.

This paper records a decisive *negative* result. The min-plus action of a matrix
on a vector,

```
(A ⊗ v)_i = min_j ( A_{ij} + v_j ),
```

is **homogeneous** with respect to the uniform shift `v ↦ c + v`: shifting the
input by a constant `c` shifts the output by the same `c`. Tropical spectral
theory guarantees that any irreducible min-plus matrix has an eigenvector `v` with
eigenvalue `λ` (the maximum cycle mean of the associated weighted digraph),
meaning `A ⊗ v = λ + v` coordinatewise. We prove that homogeneity plus an
eigenvector is enough to destroy the TDLP: iterating the map `k` times on `v`
produces exactly `k·λ + v`, so `k` is read off by subtraction. The argument is
purely algebraic, uses no randomness, and is independent of the matrix
dimension or contents.

We model the carrier as `ℕ` (the min-plus semiring without `+∞`) to keep
subtraction total and the formalization elementary; the truncated `Nat`
subtraction we use is exact in every recovery statement because the output always
dominates the input. Section 3 treats the `1×1` case in full; Section 4 gives the
dimension-free eigenline theorem.

---

## 2. Preliminaries: the min-plus semiring

The min-plus semiring `(ℕ ∪ {+∞}, min, +)` has `min` as addition (identity
`+∞`) and `+` as multiplication (identity `0`). "Tropical scalar multiplication"
of a vector by a scalar `c` is the classical addition `c + (·)` applied
coordinatewise. We write tropical matrix power as `A^{⊗k}` and the `k`-fold
iterate of a self-map `F` as `F^[k]` (`F^[0] = id`).

A scalar `λ` is a **tropical (min-plus) eigenvalue** of `A` with **eigenvector**
`v` if `A ⊗ v = λ + v`. The classical Cuninghame-Green theorem states that an
irreducible matrix has a unique eigenvalue equal to the maximum cycle mean of its
digraph, computable by Karp's algorithm in `O(n·E)` time. The *additivity of
eigenvalues under powers* — `λ(A^{⊗k}) = k·λ(A)` — is the textbook fact that our
counterexample weaponizes.

---

## 3. The `1×1` model

We first isolate the mechanism in dimension one, where a tropical matrix is a
single scalar `λ` and the action on `x ∈ ℕ` is min-plus multiplication, i.e.
ordinary addition.

**Definition 3.1 (one-box action, `oneByOneAction`).**
For `λ ∈ ℕ`, define the action of the `1×1` tropical matrix with entry `λ` by
```
oneByOneAction(λ)(x) = λ + x.
```

**Theorem 3.2 (iterate formula, `oneByOne_tropical_iterate`).**
For all `λ, x, k ∈ ℕ`,
```
(y ↦ λ + y)^[k] (x) = k·λ + x.
```

*Proof sketch.* Induction on `k`. The base case `k = 0` gives `id(x) = 0·λ + x`.
For the step, `(y ↦ λ+y)^[k+1] x = λ + (y ↦ λ+y)^[k] x = λ + (k·λ + x) =
(k+1)·λ + x`, using `Function.iterate_succ_apply'` to peel one application and the
identity `(k+1)·λ = λ + k·λ` (Lean's `Nat.succ_mul` followed by `ring`). ∎

**Theorem 3.3 (instant recovery, `tdlp_recover_oneByOne`).**
For all `x, k ∈ ℕ`, taking the public eigenvalue `λ = 1`,
```
(y ↦ 1 + y)^[k] (x) − x = k.
```

*Proof sketch.* Specialize Theorem 3.2 at `λ = 1`, giving output `k·1 + x = k + x`;
then `(k + x) − x = k` (truncated `Nat` subtraction is exact because `k + x ≥ x`). ∎

Theorem 3.3 is the entire break in miniature: the "encryption" `x ↦ k + x` is
inverted by one subtraction, with no search over `k`.

---

## 4. The dimension-free eigenline attack

We now show the same collapse holds for an *arbitrary* tropical-linear map of any
dimension, depending only on two structural properties.

**Definition 4.1 (tropical vector, `Vec`).**
For an index type `ι`, `Vec ι := ι → ℕ`.

**Definition 4.2 (tropical scalar action, `tropScalarAdd`).**
For `c ∈ ℕ` and `v : Vec ι`, `tropScalarAdd(c)(v) = (i ↦ c + v i)`. This is the
uniform shift "turn the dial by `c`."

**Definition 4.3 (scalar equivariance, `ScalarEquivariant`).**
A map `F : Vec ι → Vec ι` is *scalar-equivariant* if
```
∀ c v,  F(tropScalarAdd(c)(v)) = tropScalarAdd(c)(F(v)).
```
Every min-plus matrix action `v ↦ A ⊗ v` is scalar-equivariant, since
`min_j (A_{ij} + (c + v_j)) = c + min_j (A_{ij} + v_j)`.

**Definition 4.4 (tropical eigenvector, `IsTropicalEigen`).**
`v` is an eigenvector of `F` with eigenvalue `λ` if `F(v) = tropScalarAdd(λ)(v)`,
i.e. `F` shifts every coordinate of `v` uniformly by `λ`.

**Lemma 4.5 (additivity of the shift, `tropScalarAdd_add`).**
For all `a, b ∈ ℕ` and `v : Vec ι`,
```
tropScalarAdd(a)(tropScalarAdd(b)(v)) = tropScalarAdd(a + b)(v).
```
*Proof sketch.* Coordinatewise, `a + (b + v_i) = (a + b) + v_i` by associativity. ∎

**Theorem 4.6 (eigenline attack, `iterate_eigenline_attack`).**
Let `F : Vec ι → Vec ι` be scalar-equivariant and let `v` be an eigenvector with
eigenvalue `λ`. Then for all `k ∈ ℕ`,
```
F^[k] (v) = tropScalarAdd(k·λ)(v).
```

*Proof sketch.* Induction on `k`. Base case: `F^[0] v = v = tropScalarAdd(0)(v)`
since `0·λ = 0` and `0 + v_i = v_i`. Inductive step: using
`Function.iterate_succ_apply'`,
```
F^[k+1] v = F(F^[k] v) = F(tropScalarAdd(k·λ)(v))         (IH)
          = tropScalarAdd(k·λ)(F v)                       (scalar equivariance, Def 4.3)
          = tropScalarAdd(k·λ)(tropScalarAdd(λ)(v))       (eigenvector, Def 4.4)
          = tropScalarAdd(k·λ + λ)(v)                     (Lemma 4.5)
          = tropScalarAdd((k+1)·λ)(v),
```
where the last step is `k·λ + λ = (k+1)·λ` (`Nat.succ_mul` with commutativity).
Crucially, the internal structure of `F` is never used beyond the two hypotheses. ∎

**Theorem 4.7 (coordinate recovery, `tdlp_recover_eigenline`).**
Let `F` be scalar-equivariant and let `v` be an eigenvector with eigenvalue
`λ = 1`. Then for every coordinate `i`,
```
F^[k] (v) i − v i = k.
```

*Proof sketch.* By Theorem 4.6 with `λ = 1`, `F^[k] v = tropScalarAdd(k)(v)`, so
the `i`-th coordinate is `k + v i`; subtracting gives `(k + v i) − v i = k`. ∎

### 4.1 Interpretation

Theorem 4.6 says that on an eigenline the iterated map is *indistinguishable* from
the trivial `1×1` machine of Section 3: all of the matrix's `n²` entries are
washed out, leaving only the scalar `k·λ`. Theorem 4.7 turns this into a single-
query, single-coordinate, single-subtraction recovery of the secret exponent. No
dimension `n`, however large, provides any protection, because the attack never
inspects the matrix — it inspects one coordinate of one output.

In operational terms: if a tropical Diffie–Hellman instance is seeded (even
inadvertently) by a vector lying on an eigenline of the public matrix, the secret
exponents `a, b` leak immediately, and with them the shared key `A^{⊗ab}`. Because
irreducible tropical matrices *always* possess eigenvectors (supported on a
critical cycle), eigenlines are generic rather than exceptional.

---

## 5. Algorithms

### 5.1 Tropical power by repeated squaring (the "honest" direction)
Computes `A^{⊗k}` in `O(n³ log k)`; this is the easy direction the scheme relies on.

### 5.2 Eigenvalue recovery via the iterate ratio
Given `λ ≠ 0` and a single pair `(v, F^[k] v)` on an eigenline, recover
`k = (F^[k]v_i − v_i) / λ` for any coordinate `i` (Theorems 4.6–4.7). For `λ = 1`
this is a single subtraction; for general `λ` it is one subtraction and one
division. Cost: `O(1)` per query after the (cheap) eigenvalue computation.

### 5.3 Maximum-cycle-mean eigenvalue (Karp / Howard)
To locate an eigenline of a concrete matrix, compute the maximum cycle mean of
its weighted digraph (Karp's algorithm, `O(n·E)`) and read off the critical-cycle
eigenvector. This connects the abstract `IsTropicalEigen` hypothesis to explicit
matrices.

---

## 6. Applications and consequences

- **Cryptanalysis.** The eigenline attack is a complete break of the naive TDLP /
  tropical Diffie–Hellman whenever the seed vector is (or drifts toward) an
  eigenline. Combined with the cyclicity theorem for max-plus dynamics — orbits of
  irreducible matrices become eventually periodic and align with the dominant
  eigenvector after a bounded transient — even off-eigenline seeds are suspect.
- **Design guidance (in the negative).** Security in any tropical scheme must come
  from *breaking* scalar equivariance or *avoiding* eigenlines: e.g. mixing
  min-plus with classical operations, using non-homogeneous maps, or perturbing
  away from the spectrum. Theorem 4.6 is a precise statement of what must be
  avoided.
- **Pedagogy.** The result is a crisp instance of a general cryptographic maxim:
  iteration of a (tropically) linear operator hides nothing, because eigenvalues
  are additive under iteration.

---

## 7. Discussion

The counterexample is deliberately minimal. We work over `ℕ` rather than
`ℕ ∪ {+∞}` so that subtraction is total; this loses no generality for the break,
since recovery only ever subtracts a smaller quantity from a larger one. The
abstraction to `ScalarEquivariant` maps is what gives the result its reach: it
shows the failure is not a quirk of a particular matrix but a consequence of
min-plus *homogeneity*, the very property that makes tropical linear algebra
useful elsewhere. In effect, the feature that makes tropical algebra a good model
for shortest paths and scheduling is exactly the feature that makes it a poor
hiding place for secrets.

---

## 8. Future directions

1. **Full tropical semiring with infinities.** Reprove the eigenline attack over
   `WithTop ℕ` / `Tropical (WithTop ℝ)`, replacing truncated subtraction by an
   order-theoretic difference. The homogeneity argument should survive the carrier
   change intact.
2. **Genuine `n×n` min-plus matrices.** Lift `ScalarEquivariant` to concrete
   matrix multiplication on `Fin n → ℕ`, connecting `IsTropicalEigen` to the
   maximum cycle mean and enabling a `decide`/`native_decide`-backed treatment of
   explicit matrices.
3. **Residual hardness off the eigenline.** Quantify how fast off-eigenline orbits
   align with the dominant eigenvector (transient length / cyclicity), turning the
   counterexample into a generic attack with explicit bounds.
4. **Formal security game.** Encode the TDLP as an interactive game (challenger
   samples `k`, publishes `(λ, x, F^[k]x)`; adversary guesses) and prove the
   subtraction adversary wins with probability `1`.
5. **Design criteria for non-linearizable tropical schemes.** Use the
   counterexample to derive positive constraints characterizing maps and seeds
   that resist the eigenline collapse.

---

## 9. Conclusion

We have given a fully formalized, dimension-free counterexample to the security of
the tropical discrete logarithm problem. The `1×1` results
(`oneByOne_tropical_iterate`, `tdlp_recover_oneByOne`) expose the mechanism; the
abstract results (`iterate_eigenline_attack`, `tdlp_recover_eigenline`, supported
by `tropScalarAdd_add`) show it holds for any scalar-equivariant map on an
eigenline, irrespective of dimension or matrix contents. The secret exponent
leaks through the spectrum: on an eigenline, tropical exponentiation is just
scalar addition, and addition is undone by subtraction.
