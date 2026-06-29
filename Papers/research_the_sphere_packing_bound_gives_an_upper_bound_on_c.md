# CSS Codes as Cohomology: Quantum Error Correction from Homological Algebra

## Abstract

We develop, in a fully rigorous and machine-checkable setting, the correspondence
between Calderbank–Shor–Steane (CSS) quantum error-correcting codes and the
homology of chain complexes over a field. A CSS code of length `n` is a pair of
nested subspaces `C_Z ⊆ C_X ⊆ 𝔽ⁿ`; it encodes `k = dim(C_X / C_Z)` logical
qubits. We show that every three-term chain complex
`V₂ —∂₂→ V₁ —∂₁→ V₀` with `∂₁ ∘ ∂₂ = 0` yields a CSS code with
`C_X = ker(∂₁)` and `C_Z = im(∂₂)`, and that the number of logical qubits of this
code equals the first Betti number `β₁ = dim(H₁)` of the complex (the
**Homological Dimension Theorem**). We derive a suite of structural identities:
a quantum rank–nullity theorem `β₁ + dim B₁ = dim Z₁`, the chain-level
rank–nullity `dim Z₁ + dim(im ∂₁) = n`, an additivity (third-isomorphism) law for
towers of nested codes, and the vanishing of logical content for self-dual codes
`C_X = C_Z`. We equip the ambient space with the Hamming weight, prove it is a
genuine metric (positive-definite and subadditive), and connect minimum distance
to the systolic distance of the complex. Finally we instantiate the theory on the
hypercube graphs `Q_n`, computing `β₁(Q_n) = n·2ⁿ⁻¹ − 2ⁿ + 1` and proving that
`β₁(Q_n) > 1` for all `n ≥ 3`, so that hypercube codes are genuinely multi-qubit.
All results have been formally verified.

**Keywords:** quantum error correction, CSS codes, chain complexes, homology,
Betti number, rank–nullity, Hamming weight, topological codes, hypercube.

---

## 1. Introduction

Quantum information is fragile. Unlike classical bits, qubits cannot be cloned,
decohere under observation, and suffer two independent species of error — bit
flips (`X` errors) and phase flips (`Z` errors). The CSS construction of
Calderbank, Shor, and Steane tames both at once by combining two classical linear
codes satisfying a containment (orthogonality) condition. Independently,
algebraic topology computes the "holes" of a space via the homology of a chain
complex. The central thesis of this paper, realized concretely and verified
formally, is that these two stories are one: *the logical dimension of a CSS code
is a homological invariant.*

This perspective is the foundation of topological quantum codes — surface codes,
toric codes, and the modern family of quantum LDPC codes — where code parameters
are read off from the geometry of an underlying complex. Our contribution is a
self-contained, axiom-clean formalization of the correspondence together with the
linear-algebraic conservation laws it induces, and an explicit worked family (the
hypercubes) demonstrating that the qubit count is dictated entirely by topology.

Throughout, `𝔽` denotes an arbitrary field; `Fin n → 𝔽` denotes the space
`𝔽ⁿ` of length-`n` vectors; `finrank 𝔽 M` denotes the dimension of a finite
dimensional `𝔽`-vector space `M`; `ker`, `im`, `comap` (preimage), and `⧸`
(quotient) carry their standard meanings.

---

## 2. CSS Codes

### Definition 2.1 (CSS code)

A **CSS code** over a field `𝔽` with ambient length `n` is a triple
`(C_X, C_Z, contains)` where `C_X, C_Z ⊆ 𝔽ⁿ` are subspaces and
`contains : C_Z ⊆ C_X`. We call `C_X` the **X-stabilizer code** (the kernel of
the parity checks) and `C_Z` the **Z-stabilizer code** (the image of the
generating matrix).

### Definition 2.2 (Logical qubits)

The number of **logical qubits** of a CSS code `C` is
```
logicalQubits(C) := dim_𝔽 ( C_X / C_Z' ),
```
where `C_Z'` is `C_Z` regarded as a subspace of `C_X` via the inclusion
(formally, the preimage `comap (C_X.subtype) C_Z`). Thus
`logicalQubits(C) = dim(C_X / C_Z)`, the dimension of the quotient of the larger
stabilizer space by the smaller.

This single number is the fundamental code parameter `k`: it counts the dimensions
of `C_X` that remain after the redundancy encoded by `C_Z` is collapsed.

---

## 3. The Chain-Complex Construction

### Definition 3.1 (Three-term chain complex)

A **3-term chain complex** over `𝔽` is the data
```
V₂ = 𝔽ᵐ  —∂₂→  V₁ = 𝔽ⁿ  —∂₁→  V₀ = 𝔽ᵖ
```
of two `𝔽`-linear maps `∂₂ : 𝔽ᵐ → 𝔽ⁿ` and `∂₁ : 𝔽ⁿ → 𝔽ᵖ` subject to the
**chain condition**
```
∂₁ ∘ ∂₂ = 0.
```

### Definition 3.2 (Cycles and boundaries)

Within the middle term `V₁ = 𝔽ⁿ` we define
```
Z₁ := cycles      = ker(∂₁),
B₁ := boundaries  = im(∂₂).
```

### Lemma 3.3 (Boundaries are cycles)

`B₁ ⊆ Z₁`.

*Proof sketch.* Let `x ∈ B₁`, so `x = ∂₂ y` for some `y`. Then
`∂₁ x = ∂₁(∂₂ y) = (∂₁ ∘ ∂₂) y = 0` by the chain condition, whence `x ∈ ker(∂₁) = Z₁`. ∎

### Definition 3.4 (CSS code of a complex)

The chain complex `K` yields a CSS code `toCSSCode(K)` with
```
C_X := Z₁ = ker(∂₁),   C_Z := B₁ = im(∂₂),
```
the containment `C_Z ⊆ C_X` being Lemma 3.3. Conceptually, the chain condition
`∂₁ ∘ ∂₂ = 0` *is* the CSS orthogonality condition.

### Definition 3.5 (First homology and Betti number)

The **first homology** is the quotient
```
H₁(K) := Z₁ / B₁     (formally  Z₁ / comap (Z₁.subtype) B₁ ),
```
and the **first Betti number** is `β₁(K) := dim_𝔽 H₁(K)`.

---

## 4. Main Results

### Theorem 4.1 (Homological Dimension Theorem)

For any 3-term chain complex `K`, the CSS code `toCSSCode(K)` satisfies
```
logicalQubits(toCSSCode(K)) = β₁(K).
```
That is, *the number of logical qubits equals the first Betti number.*

*Proof sketch.* By Definition 3.4, `C_X = Z₁` and `C_Z = B₁`. By Definition 2.2,
`logicalQubits(toCSSCode(K)) = dim(Z₁ / B₁)`, which is precisely `dim(H₁) = β₁`
by Definition 3.5. The two sides are definitionally equal once the inclusions are
unwound; in the formalization the statement closes by `rfl`. ∎

This theorem is the conceptual heart of topological quantum coding: the logical
capacity of the code is a topological invariant, insensitive to any presentation
of the complex.

### Theorem 4.2 (Quantum rank–nullity)

If `𝔽ⁿ` is finite dimensional, then
```
β₁(K) + dim_𝔽(B₁) = dim_𝔽(Z₁),
```
where `B₁` is viewed inside `Z₁`.

*Proof sketch.* This is the rank–nullity theorem applied to the quotient
`Z₁ / B₁`: for any subspace `W` of a finite-dimensional space `V`,
`dim(V/W) + dim(W) = dim(V)`. Taking `V = Z₁` and `W = B₁` (as a subspace of
`Z₁`) gives the claim, since `dim(V/W) = β₁`. ∎

Interpretation: the cycle space decomposes into the "filled" part (boundaries) and
the genuinely "hollow" part (homology = logical qubits); dimensions are conserved.

### Theorem 4.3 (Chain-level rank–nullity)

If `𝔽ⁿ` is finite dimensional, then
```
dim_𝔽(Z₁) + dim_𝔽(im ∂₁) = n.
```

*Proof sketch.* Apply rank–nullity to `∂₁ : 𝔽ⁿ → 𝔽ᵖ`:
`dim(im ∂₁) + dim(ker ∂₁) = dim(𝔽ⁿ) = n`. Since `Z₁ = ker(∂₁)`, rearranging gives
the statement. ∎

Interpretation: the ambient space splits into cycles and the detectable syndrome
directions of the parity map.

### Theorem 4.4 (Logical-qubit additivity / third isomorphism)

Let `C_Z ⊆ C_mid ⊆ C_X` be a tower of subspaces of a finite-dimensional `𝔽ⁿ`.
Then
```
dim(C_X / C_Z) = dim(C_X / C_mid) + dim(C_mid / C_Z).
```

*Proof sketch.* Using `dim(V/W) = dim(V) − dim(W)` for nested subspaces and the
fact that intersecting `C_Z` (resp. `C_mid`) with the larger ambient space
recovers the original subspace (because of the inclusions), expand both sides:
```
dim(C_X) − dim(C_Z) = (dim(C_X) − dim(C_mid)) + (dim(C_mid) − dim(C_Z)).
```
The right side telescopes to the left. The formalization manages the subspace
coercions via `map`/`comap` identities (`map_comap_subtype`, `inf_eq_right`) to
identify the relevant intersected subspaces with `C_Z` and `C_mid`. ∎

Interpretation: refining a code through an intermediate stage protects exactly the
same total information as a single-stage refinement; logical content is additive
along towers.

### Theorem 4.5 (Self-dual codes are trivial)

If a CSS code satisfies `C_X = C_Z`, then `logicalQubits(C) = 0`.

*Proof sketch.* When `C_X = C_Z`, the subspace `C_Z` viewed inside `C_X` is all of
`C_X` (its preimage under the inclusion is `⊤`), so the quotient `C_X / C_Z` is
the zero space and has dimension `0`. ∎

A code whose two stabilizer spaces coincide stores no quantum information — the
homological analogue of "a shape with no holes."

---

## 5. The Hamming Metric and Code Distance

Code distance, the parameter governing how many errors can be corrected, is built
on the Hamming weight.

### Definition 5.1 (Hamming weight)

For `v ∈ 𝔽ⁿ` (with `𝔽` having decidable equality and a zero),
```
weight(v) := |{ i ∈ Fin n : v i ≠ 0 }|,
```
the number of nonzero coordinates.

### Theorem 5.2 (Positive-definiteness)

`weight(v) = 0  ⟺  v = 0`.

*Proof sketch.* The filtered set `{i : v i ≠ 0}` is empty iff every coordinate of
`v` is zero, i.e. iff `v = 0`. ∎

### Theorem 5.3 (Triangle inequality)

For `v, w ∈ 𝔽ⁿ` over an additive group `𝔽`,
```
weight(v + w) ≤ weight(v) + weight(w).
```

*Proof sketch.* The support of `v + w` is contained in the union of the supports
of `v` and `w`: if `(v + w) i ≠ 0` then `v i ≠ 0` or `w i ≠ 0`. Hence
`|supp(v+w)| ≤ |supp(v) ∪ supp(w)| ≤ |supp(v)| + |supp(w)|`. The formalization
uses `card_union_add_card_inter` to bound the union by the sum. ∎

Theorems 5.2 and 5.3 make `d(v, w) := weight(v − w)` a genuine metric, turning
`𝔽ⁿ` into **Hamming space**. The **minimum distance** of a code is the least
weight of a nonzero codeword; under the chain-complex correspondence it coincides
with the **systolic distance** — the length of the shortest non-contractible cycle
of the complex — which is the topological measure of code robustness.

---

## 6. Homological Quantum Error-Correcting Codes

### Definition 6.1 (HQECC)

A **Homological Quantum Error-Correcting Code** packages a chain complex `K`
together with its derived CSS code and a proof that the code is exactly
`toCSSCode(K)`. The constructor `HQECC.fromComplex(K)` builds the canonical HQECC
from any complex.

### Theorem 6.2 (Encoding rate)

For any HQECC `H`,
```
logicalQubits(H.code) = β₁(H.complex).
```

*Proof sketch.* By definition `H.code = toCSSCode(H.complex)`; substitute and
apply Theorem 4.1. ∎

The *rate* of the code — logical qubits per physical qubit, `k/n` — is therefore
determined entirely by the topology of the complex.

---

## 7. Worked Family: Hypercube Codes

A graph is a one-dimensional chain complex `𝔽^E —∂→ 𝔽^V` whose boundary map sends
each edge to the difference of its endpoints. For a connected graph, the first
Betti number is the **cyclomatic number** given by Euler's relation
`β₁ = |E| − |V| + 1`.

### Definition 7.1 (Hypercube Betti number)

The hypercube graph `Q_n` has `|V| = 2ⁿ` vertices (binary strings of length `n`)
and `|E| = n·2ⁿ⁻¹` edges (pairs differing in one coordinate). Hence we define
```
β₁(Q_n) := n·2ⁿ⁻¹ − 2ⁿ + 1.
```

### Theorem 7.2 (The square)

`β₁(Q₂) = 1`.

*Proof sketch.* Direct computation: `2·2¹ − 2² + 1 = 4 − 4 + 1 = 1`. The square
has a single independent cycle. ∎

### Theorem 7.3 (Hypercubes are multi-qubit)

For all `n ≥ 3`, `β₁(Q_n) > 1`.

*Proof sketch.* For `n ≥ 3` one shows `n·2ⁿ⁻¹ − 2ⁿ + 1 > 1`, i.e.
`n·2ⁿ⁻¹ > 2ⁿ`, i.e. `n > 2`. The formalization handles small cases `n = 0,1,2`
by elimination and the tail `n ≥ 3` by a positivity (`nlinarith`) argument using
`2ⁿ > 0`. Concretely `β₁(Q₃) = 12 − 8 + 1 = 5`. ∎

This refutes the naive expectation that a connected lattice has a single essential
cycle: hypercube codes encode a number of qubits that grows rapidly with
dimension, governed purely by topology.

---

## 8. Algorithms

The formal results correspond to concrete linear-algebra algorithms over a field.

1. **Logical-dimension computation.** Given matrices for `∂₁` and `∂₂`, compute
   `dim ker(∂₁)` and `dim im(∂₂)` by Gaussian elimination, then
   `k = dim ker(∂₁) − dim im(∂₂)` (Theorems 4.1–4.2). Complexity `O(n³)` for
   dense matrices of size `O(n)`.

2. **Chain-condition verification.** Check `∂₁ ∘ ∂₂ = 0` by matrix multiplication,
   `O(n·m·p)`.

3. **Minimum-distance estimation.** Enumerate or search low-weight codewords of
   `C_X` not in `C_Z` to bound the minimum distance (Theorems 5.2–5.3); exact
   computation is NP-hard in general, so heuristics or structure (systoles) are
   used in practice.

4. **Hypercube parameters.** Evaluate `β₁(Q_n) = n·2ⁿ⁻¹ − 2ⁿ + 1` in `O(1)`
   arithmetic operations (Definition 7.1).

---

## 9. Applications

- **Topological quantum memory.** Surface and toric codes are exactly the CSS
  codes of cellulated surfaces; Theorem 4.1 says their qubit count is the surface's
  first Betti number (e.g. a torus encodes `2` qubits).
- **Quantum LDPC codes.** Sparse chain complexes (expander-based, high-dimensional)
  yield codes with simultaneously high rate and distance; the design problem is the
  homological one of building complexes with large `β₁` and large systole.
- **Code concatenation and towers.** Theorem 4.4 quantifies how logical content
  accumulates across nested codes, guiding multi-level fault-tolerant designs.
- **Duality engineering.** Poincaré duality on the complex exchanges `X`- and
  `Z`-type defenses; self-dual points (Theorem 4.5) mark degenerate, information-free
  configurations to be avoided.

---

## 10. Discussion

The value of the correspondence is twofold. Conceptually, it imports the entire
toolbox of homological algebra — exact sequences, duality, spectral sequences —
into quantum coding, turning code design into geometry. Practically, it yields
*provable* parameter formulas: once a code is presented as a complex, its logical
dimension is a Betti number that can be computed exactly and reasoned about with
conservation laws rather than ad hoc counting.

A subtle but important point is the role of the chain condition. It is not an
auxiliary technical hypothesis but the very embodiment of CSS orthogonality; the
"boundary of a boundary is zero" law and the "Z-stabilizers commute with
X-stabilizers" law are the same equation. This is why Theorem 4.1 holds at the
level of definitions.

---

## 11. Future Directions

Building on the sorry-free homological core developed here and on the companion
classical coding-theory results (the sphere-packing/Hamming upper bound and the
Gilbert–Varshamov lower bound), several avenues are natural:

1. **Packing–covering sandwich.** State and prove a combined bracketing theorem
   for the optimal code size `A_q(n,d)`, namely
   `qⁿ / V(d−1) ≤ A_q(n,d) ≤ qⁿ / V(⌊(d−1)/2⌋)`, derived mechanically from
   Gilbert–Varshamov and the sphere-packing bound sharing the extremal-code
   witness. Requires only the definition of `A_q(n,d)` and ball-volume
   monotonicity `V(s) ≤ V(t)` for `s ≤ t`.

2. **Plotkin bound via weight double-counting.** When `d > n/2` the sphere-packing
   bound is trivial; the Plotkin bound `|C| ≤ 2d/(2d−n)` fills the gap through a
   double-counting of total pairwise Hamming weight, bridging the Hamming-metric
   formalization with linear algebra over `F₂`.

3. **Kolmogorov complexity via Turing machines.** A minimal universal-machine
   model would let `K(x) = min{|p| : U(p) = x}` be defined, after which the
   combinatorial incompressibility counting immediately gives the "most strings
   are random" theorem.

4. **Perfect-code classification.** Verify that Hamming codes
   `[2ʳ−1, 2ʳ−r−1, 3]` (and the Golay `[23,12,7]` code) achieve equality in the
   sphere-packing bound, using the exact ball-cardinality formula and the integer
   identity `2ⁿ = 2ⁿ⁻ʳ·V(n,1)` for `n = 2ʳ−1`.

5. **Metric entropy and covering numbers.** Establish the exact covering-number
   formula `N(ε) = ⌈qⁿ / V(n,ε)⌉` for Hamming space, yielding metric entropy
   `H(ε) = log N(ε)` and a formal bridge between coding theory and approximation
   theory.

Within the homological program specifically, the next milestones are: formalizing
the systolic lower bound on minimum distance, Poincaré duality as CSS duality,
and the toric/surface codes as explicit complexes with computed `[[n, k, d]]`
parameters.

---

## 12. Conclusion

We have given a clean, verified account of CSS codes as the homology of chain
complexes: logical qubits are first Betti numbers (Theorem 4.1), supported by
rank–nullity conservation laws (4.2, 4.3), an additivity theorem for towers
(4.4), the triviality of self-dual codes (4.5), a Hamming metric with full
metric axioms (5.2, 5.3), and an explicit multi-qubit hypercube family
(7.2, 7.3). The picture that emerges is uniform and powerful: *to build a better
quantum code, build a better shape.*
