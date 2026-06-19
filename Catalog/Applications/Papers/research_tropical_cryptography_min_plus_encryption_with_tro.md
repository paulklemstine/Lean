# The Boundary Theorem for Tropical Eigenvalues and the No-Leak Property at λ = 0

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Tropical algebra, post-quantum cryptanalysis, machine-learning robustness

---

## Abstract

Tropical (min-plus) linear algebra replaces ordinary addition by `min` and
ordinary multiplication by `+`, turning matrix–vector multiplication into a
shortest-path computation. This algebra underlies a family of proposed
post-quantum cryptographic schemes whose security rests on the hardness of a
*tropical discrete logarithm problem* (TDLP): recover the exponent `k` from a
public matrix `A` and a tropical power `A⊗ᵏ`. The canonical attack exploits the
additivity of tropical eigenvalues under powers, `λ(A⊗ᵏ) = k·λ(A)`, which yields
`k = λ(A⊗ᵏ)/λ(A)` whenever `λ(A) ≠ 0`. We give a rigorous account of the single
value that defeats this attack, the **boundary eigenvalue** `λ = 0`. We introduce
the **tropical residual**, the one honest subtraction available in min-plus
algebra, prove that it equals the eigenvalue at every coordinate, and prove the
central **no-leak theorem**: at `λ = 0` the residual vanishes identically, so the
eigenvalue side-channel is silent. We then establish a **boundary theorem**: for
any weighted digraph with non-negative weights and zero self-loops, every
tropical eigenvalue satisfies `λ ≤ 0`, and `λ = 0` is attained by all constant
vectors. Combined with the shift-equivariance of tropical maps, these results
show that boundary eigenvectors are indistinguishable through the residual
channel up to a single global offset. All results have been formalized and
machine-checked. We close with proof sketches, algorithms, a worked numerical
demonstration, and a discussion of how the boundary analysis extends to generic
secrets, noisy observations, and formal hardness reductions.

---

## 1. Introduction

### 1.1 Tropical arithmetic and shortest paths

The **tropical (min-plus) semiring** is the set `ℝ` (often `ℝ ∪ {∞}`) equipped
with `a ⊕ b := min(a,b)` as "addition" and `a ⊙ b := a + b` as "multiplication".
The additive identity is `+∞` and the multiplicative identity is `0`. Lifting
these operations to matrices produces an algebra whose products compute optimal
paths: the `(i,j)` entry of a tropical matrix product is the minimum total weight
of a two-stage route from `i` to `j`. This is why min-plus algebra is the native
setting of dynamic programming, the Bellman–Ford and Floyd–Warshall algorithms,
discrete-event systems, and scheduling.

### 1.2 Tropical cryptography and the discrete logarithm

The computational asymmetry of tropical products — `O(n³)` to compute forward,
provably many-to-one to invert — has motivated proposals to base post-quantum
cryptography on min-plus operations. A representative construction is the
tropical Diffie–Hellman key exchange: a public matrix `A` is fixed; Alice
publishes `A⊗ᵃ` and Bob publishes `A⊗ᵇ` for secret exponents `a, b`; the shared
key is `A⊗ᵃᵇ`. An eavesdropper must solve the **tropical discrete logarithm
problem** (TDLP): given `(A, A⊗ᵏ)`, recover `k`.

### 1.3 The eigenvalue attack and the boundary

Tropical matrices possess eigenvalues in the min-plus sense, and these
eigenvalues are *additive under matrix powers*: `λ(A⊗ᵏ) = k·λ(A)`. Hence a single
eigenvalue computation breaks the TDLP via `k = λ(A⊗ᵏ)/λ(A)` — **unless `λ(A) =
0`**. The boundary value `λ = 0` is therefore the crux of the security analysis.
This paper provides a complete, formally verified treatment of that boundary: a
sharp characterization of when `λ = 0` occurs, a proof that the natural
observable (the residual) carries *no* information there, and a structural
theorem locating the entire spectrum of graph-based constructions at or below the
boundary.

### 1.4 Contributions

1. The **tropical residual** `tropResidual(A,v)ᵢ = (A ⊗ v)ᵢ − vᵢ`, the unique
   meaningful subtraction in min-plus algebra and the natural side-channel
   observable.
2. **Theorem 1**: the residual equals the eigenvalue at every coordinate.
3. **Theorem 2**: the eigenvalue is uniquely determined by the eigenvector.
4. **Theorem 3**: `λ = 0` ⇔ the eigenvector is a tropical fixed point.
5. **Theorem 4 (no-leak, main result)**: at `λ = 0` the residual vanishes
   identically.
6. **Theorem 6 (boundary theorem)**: for non-negative zero-self-loop digraphs,
   every eigenvalue satisfies `λ ≤ 0`; **Theorem 7**: the value `0` is attained
   by all constant vectors.
7. Consequences for **eigenvector indistinguishability** under the residual
   channel, up to the global shift symmetry of tropical maps.

---

## 2. Definitions

Throughout, `n ≥ 1`, indices range over `Fin n`, and matrices are real-valued
`n × n`. We write `inf'` for the (finite, nonempty) infimum.

**Definition 1 (tropical matrix product, `tropMatMul`).**
For matrices `A, B`,
`(A ⊗ B)(i,j) = min_{k} ( A(i,k) + B(k,j) )`.
This costs `O(n³)` arithmetic operations and computes the minimal two-hop path
weight from `i` to `j`. It is associative (`tropMatMul_assoc`):
`(A ⊗ B) ⊗ C = A ⊗ (B ⊗ C)`.

**Definition 2 (tropical identity, `tropId`).**
`tropId(n, M)(i,j) = 0` if `i = j`, else `M`. For `M` large enough relative to
the entries of `A`, `tropId` acts as a two-sided identity for `⊗`.

**Definition 3 (tropical matrix–vector product, `tropMatVecMul`).**
For a matrix `A` and vector `v`,
`(A ⊗ v)ᵢ = min_{k} ( A(i,k) + v(k) )`.

**Definition 4 (tropical eigenpair, `IsTropicalEigenpair`).**
A pair `(λ, v)` with `λ ∈ ℝ`, `v : Fin n → ℝ`, is a tropical eigenpair of `A`
iff
`(A ⊗ v)ᵢ = vᵢ + λ for all i`.
This is the min-plus analogue of `A v = λ v`.

**Definition 5 (weighted digraph, `WeightedDigraph`).**
A weighted digraph on `n` vertices is a weight matrix `W` together with the
hypotheses
`nonneg : ∀ i j, 0 ≤ W(i,j)` and `self_loop_zero : ∀ i, W(i,i) = 0`.
Edge weights are non-negative and staying put is free.

**Definition 6 (min-plus hash, `MinPlusHash`).**
A min-plus hash is an `m × n` compressor matrix `H` with bounded entries; it acts
on a vector `v` by `H.eval(v)ᵢ = min_k ( H(i,k) + v(k) )`. It is `1`-Lipschitz in
the sup norm and translation-equivariant: `H.eval(v + c) = H.eval(v) + c`
(`MinPlusHash.eval_shift`).

**Definition 7 (tropical residual, `tropResidual`).**
For a matrix `A` and vector `v`,
`tropResidual(A, v)ᵢ = (A ⊗ v)ᵢ − vᵢ`.
This is the only honest coordinatewise subtraction available in min-plus algebra,
and it is precisely the signal an adversary measures when probing a tropical
eigensystem.

---

## 3. Main Results

### 3.1 The residual encodes the eigenvalue

**Theorem 1 (`tropResidual_eq_eigenvalue`).**
*If `(λ, v)` is a tropical eigenpair of `A`, then for every coordinate `i`,*
`tropResidual(A, v)ᵢ = λ.`

*Proof sketch.* By Definition 4, `(A ⊗ v)ᵢ = vᵢ + λ`. Subtracting `vᵢ` from both
sides gives `(A ⊗ v)ᵢ − vᵢ = λ`, which is the residual by Definition 7. ∎

**Corollary 1 (`tropResidual_const`).**
*For an eigenpair `(λ, v)` the residual is independent of the coordinate:*
`tropResidual(A, v)ᵢ = tropResidual(A, v)ⱼ` *for all `i, j`.* The residual signal
contains no positional information; it is a single scalar repeated across
coordinates. (Immediate from Theorem 1, since both sides equal `λ`.)

**Theorem 2 (`tropical_eigenvalue_unique`).**
*If `(λ, v)` and `(μ, v)` are both tropical eigenpairs of `A` (same eigenvector),
then `λ = μ`.*

*Proof sketch.* Evaluate both eigenpair relations at coordinate `0` (which exists
since `n ≥ 1`): `v₀ + λ = (A ⊗ v)₀ = v₀ + μ`, hence `λ = μ`. ∎

### 3.2 The boundary eigenvalue λ = 0

**Theorem 3 (`eigenzero_iff_fixed`).**
*`(0, v)` is a tropical eigenpair of `A` if and only if `v` is a tropical fixed
point of `A`, i.e. `(A ⊗ v)ᵢ = vᵢ` for all `i`.*

*Proof sketch.* Unfold Definition 4 with `λ = 0`: the relation `(A ⊗ v)ᵢ = vᵢ +
0` is literally `(A ⊗ v)ᵢ = vᵢ`. ∎

**Theorem 4 (no-leak, main result, `eigenzero_no_leak`).**
*If `(0, v)` is a tropical eigenpair of `A`, then for every coordinate `i`,*
`tropResidual(A, v)ᵢ = 0.`

*Proof sketch.* Apply Theorem 1 with `λ = 0`. ∎

Despite its one-line proof, Theorem 4 is the security-theoretic crux. The
residual is the canonical observable of an eigenvalue side-channel; at the
boundary it is identically zero, so the observable reveals nothing — neither the
value of `λ` (which is zero) nor any structure of the secret eigenvector `v`.

**Theorem 5 (`eigenzero_iterate`).**
*If `(0, v)` is a tropical eigenpair of `A`, then for every `k ∈ ℕ`,*
`(A ⊗ ·)^[k] (v) = v,`
*i.e. iterating the tropical map fixes `v`.*

*Proof sketch.* Induction on `k`. The base case is trivial. For the step, use the
iterate identity `f^[k+1] = f ∘ f^[k]`, apply the induction hypothesis to reduce
to one application of the map, and invoke Theorem 3 (fixed-point characterization)
coordinatewise. ∎

Theorem 5 shows that no eigenvalue "leaks" into the growth of iterates at the
boundary: the orbit is constant, so observing many rounds yields no additional
information.

### 3.3 The boundary theorem for weighted digraphs

**Lemma 1 (`digraph_residual_nonpos`).**
*For a weighted digraph `G` (Definition 5) and any vector `v`, the residual is
non-positive at every coordinate:*
`tropResidual(G.weights, v)ᵢ ≤ 0.`

*Proof sketch.* By definition `(G.weights ⊗ v)ᵢ = min_k (W(i,k) + v(k)) ≤ W(i,i)
+ v(i) = 0 + v(i) = v(i)`, using the candidate `k = i` and the zero self-loop
`W(i,i) = 0`. Subtracting `v(i)` gives a non-positive residual. ∎

**Theorem 6 (boundary theorem, `digraph_eigenvalue_nonpos`).**
*Every tropical eigenvalue of a weighted digraph (non-negative weights, zero
self-loops) satisfies `λ ≤ 0`.*

*Proof sketch.* Let `(λ, v)` be an eigenpair. By Theorem 1, `λ =
tropResidual(G.weights, v)₀`. By Lemma 1 that residual is `≤ 0`. Hence `λ ≤ 0`.
∎

Thus `λ = 0` is the upper boundary of the tropical spectrum of any such graph —
the min-plus analogue of an upper bound on the spectral radius. The non-negative
weights are not used directly in the eigenvalue bound (the zero self-loop alone
forces the residual upper bound); they are part of the graph model and guarantee
the value `0` is attained, as the next theorem shows.

**Theorem 7 (boundary attained, `digraph_eigenzero_const`).**
*For a weighted digraph `G` and any constant `c`, the constant vector `v ≡ c` is a
tropical eigenvector with eigenvalue `0`:* `IsTropicalEigenpair(G.weights, 0,
(fun _ => c))`.

*Proof sketch.* Compute `(G.weights ⊗ v)ᵢ = min_k (W(i,k) + c)`. The upper bound
`≤ c` follows from `k = i` and `W(i,i) = 0`. The lower bound `≥ c` follows because
`W(i,k) + c ≥ c` for all `k` by non-negativity of the weights. Hence `(G.weights
⊗ v)ᵢ = c = vᵢ + 0`. ∎

Theorems 6 and 7 together pin the picture: the spectrum lies in `(−∞, 0]`, the
ceiling `0` is always realized (by constant vectors), and only there does the
residual channel go silent (Theorem 4).

### 3.4 Shift symmetry and indistinguishability

Tropical maps are equivariant under the global additive shift, the min-plus
"scalar action": `(A ⊗ (v + c))ᵢ = (A ⊗ v)ᵢ + c` (`tropMatVecMul_shift`).
Consequently:

- The eigenpair relation is preserved under shifting the eigenvector by any
  constant; an eigenvector is determined only up to a global offset
  (*shift-invariance of the spectrum*).
- At the boundary `λ = 0`, any two fixed-point eigenvectors — and any shifted
  copies — yield the **identically zero** residual signature (Theorem 4). An
  adversary measuring residuals cannot distinguish among them
  (*eigenvector indistinguishability at the boundary*).
- Lifting this to the min-plus hash (Definition 6), the translation-equivariance
  `H.eval(v + c) = H.eval(v) + c` shows that the hash of a boundary eigenvector
  leaks **at most** the single global offset constant and nothing about the
  shape of the secret.

These three statements correspond to the Section-4 results of the formal
development (`eigenpair_shift_invariant` / `eigenzero_shift_invariant`,
`eigenzero_residual_indistinguishable` / `eigenzero_residual_uninformative`,
`minPlusHash_leak_only_offset`); they are stated here at the level of their
formal summaries.

---

## 4. Algorithms

### 4.1 Tropical matrix power by repeated squaring

The forward direction of the TDLP. Computing `A⊗ᵏ` costs `O(n³ log k)`.

```
function TropicalPower(A, k):
    # P accumulates the result; B is the running square
    P ← TropicalIdentity(n)          # 0 on diagonal, +∞ off diagonal
    B ← A
    while k > 0:
        if k is odd:  P ← TropMatMul(P, B)
        B ← TropMatMul(B, B)
        k ← k // 2
    return P
```

### 4.2 Tropical eigenvalue via the residual (the attack)

For an eigenvector `v`, the eigenvalue is read off any coordinate of the residual
(Theorem 1); for a generic probe vector one averages the residual or uses the
maximal cycle mean. The attack on the TDLP divides eigenvalues:

```
function TDLPviaEigenvalue(A, B):     # B = A^{⊗k}, recover k
    λA ← TropicalEigenvalue(A)
    λB ← TropicalEigenvalue(B)
    if λA = 0:  return FAIL           # boundary: no-leak (Theorem 4)
    return round(λB / λA)
```

The `λA = 0` branch is exactly the regime where Theorem 4 guarantees the residual
channel is silent, and the attack provably cannot proceed.

### 4.3 Residual / leakage probe

```
function Residual(A, v):
    return [ TropMatVecMul(A, v)[i] - v[i]  for i in 0..n-1 ]
```

By Theorem 1 every entry equals `λ` on an eigenvector; by Theorem 4 every entry
is `0` at the boundary.

---

## 5. Applications

- **Cryptanalysis (primary).** The boundary theorem maps the attack surface of
  tropical Diffie–Hellman: the eigenvalue division attack (Algorithm 4.2)
  succeeds for `λ ≠ 0` and is provably defeated at `λ = 0` (Theorem 4). Because
  graph-based constructions accumulate eigenvectors at the boundary (Theorems
  6–7), the boundary is the natural design target for resistant secrets.

- **Side-channel resistance.** Theorem 4 is a no-leak statement for the residual
  observable: the canonical side-channel reveals neither the eigenvalue nor the
  secret eigenvector at the boundary. Theorem 5 extends this across many
  iterations.

- **Certified ML robustness.** The same min-plus operations serve as neural
  network layers; the `1`-Lipschitz bound for `tropMatVecMul` and the min-plus
  hash give certified robustness radii. The shift-equivariance is the tropical
  analogue of layer linearity.

---

## 6. Discussion

The boundary `λ = 0` plays a dual role. From the *attacker's* side it is the
single point where the eigenvalue division attack fails. From the *designer's*
side it is the natural locus of secrets in graph-based schemes, since the spectrum
is capped at `0` and constant vectors realize it. Theorem 4 makes the necessary
condition precise: at the boundary the residual channel is silent. We emphasize
that this is *necessary, not sufficient* for security — other channels (e.g. the
shape of the public power, the structure of the compressor) may still leak, and
ruling them out requires a hardness reduction rather than a vanishing-observable
argument. The preimage non-uniqueness theorem `trop_preimage_nonunique` (for any
`C` there are distinct factorizations `A ⊗ B = A' ⊗ B' = C`) supplies a candidate
hard problem — tropical matrix factorization — to which boundary
indistinguishability might be reduced.

---

## 7. Future Work

1. **From eigenvectors to arbitrary secret vectors.** Real protocols use generic
   secrets, for which the orbit `A⊗ᵏ ⊗ v` becomes eventually periodic with slope
   the maximal cycle mean. The eigenvalue `λ` of the boundary theorems is exactly
   that cycle mean; extending `eigenzero_no_leak` to "eventually constant"
   behavior off the eigenvector locus is the natural next step.

2. **Quantitative, noisy leakage bounds.** The `1`-Lipschitz bound for
   `tropMatVecMul` lifts to the iterated action, bounding how an `ε`-perturbation
   of `v` or `A` propagates over `k` rounds; the affine leak `v + k·λ` is robust,
   with estimation error growing only linearly in `k`.

3. **Hardness certification at and near the boundary.** Turn "no leakage" into a
   formal reduction: show that distinguishing exponents in the `λ = 0` regime is
   equivalent to an independently hard tropical problem, e.g. the min-plus matrix
   factorization underlying `trop_preimage_nonunique`.

4. **Multiple eigenvalues and the spectral attack surface.** A tropical matrix may
   possess several distinct eigenvalues with distinct eigenspaces; a secret may
   decompose across them, and the total observed leak is a tropical (min)
   combination of per-eigenspace contributions.

---

## 8. Conclusion

We have given a complete, machine-verified account of the boundary eigenvalue `λ
= 0` in tropical linear algebra and its cryptanalytic significance. The tropical
residual encodes the eigenvalue exactly (Theorem 1) and uniquely (Theorem 2); at
the boundary it vanishes identically (Theorem 4, the no-leak property); and the
boundary is both the ceiling of the spectrum (Theorem 6) and always attained
(Theorem 7) for graph-based constructions. Together with the shift symmetry of
tropical maps, these results delineate precisely where the eigenvalue attack on
the tropical discrete logarithm succeeds and where it provably fails, and they
identify the zero-eigenvalue boundary as the natural design target for
resistant tropical cryptography.

---

## References

1. P. Butkovič, *Max-linear Systems: Theory and Algorithms*, Springer, 2010.
2. R. A. Cuninghame-Green, *Minimax Algebra*, Lecture Notes in Economics and
   Mathematical Systems 166, Springer, 1979.
3. M. Akian, S. Gaubert, A. Guterman, "Tropical polyhedra are equivalent to mean
   payoff games," *International Journal of Algebra and Computation*, 2012.
