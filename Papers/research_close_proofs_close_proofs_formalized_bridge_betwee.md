# CSS Codes as Cohomology: Quantum Error Correction from Homological Algebra

## Abstract

We develop, rigorously and from first principles, the correspondence between
Calderbank–Shor–Steane (CSS) quantum error-correcting codes and the homology of
chain complexes over a field. A CSS code is modeled as a nested pair of subspaces
`C_Z ≤ C_X` of the coordinate space `𝔽ⁿ`, encoding a number of logical qubits
equal to `dim(C_X / C_Z)`. We show that every three-term chain complex
`V₂ →[∂₂] V₁ →[∂₁] V₀` satisfying the chain condition `∂₁ ∘ ∂₂ = 0` canonically
yields a CSS code with `C_X = ker(∂₁)` and `C_Z = range(∂₂)`, and that the number
of logical qubits of this code equals the **first Betti number** `β₁ = dim(H₁)`,
where `H₁ = ker(∂₁)/range(∂₂)` is the first homology. We establish the supporting
dimension theory — a quantum rank–nullity identity, the underlying linear
rank–nullity theorem, and an additivity (third isomorphism) law for nested codes —
together with the metric infrastructure for code distance via the Hamming weight,
which we prove is a norm-like quantity (vanishing only at zero, subadditive under
addition). We exhibit a self-duality phenomenon (`C_X = C_Z ⇒ 0` logical qubits)
and package the whole construction into a Homological Quantum Error-Correcting
Code (HQECC) whose encoding rate is determined entirely by topology. As a concrete
application we compute the Betti numbers of the hypercube graphs `Q_n`, proving
`β₁(Q_2) = 1` and `β₁(Q_n) > 1` for all `n ≥ 3`, refuting the naive conjecture
that the hypercube always encodes a single logical qubit. All results have been
formally verified.

**Keywords:** CSS codes, quantum error correction, chain complex, homology, Betti
number, rank–nullity, Hamming weight, code distance, hypercube, homological codes.

---

## 1. Introduction

Quantum information cannot be cloned and is destroyed by measurement, so the
classical strategy of redundant copying is unavailable for protecting it. The
resolution, due to Shor, Steane, Calderbank, and others, is to encode a small
number of *logical* qubits into a larger collection of *physical* qubits so that
local errors produce a measurable syndrome and can be reversed without disturbing
the encoded superposition. The CSS construction is the central and most flexible
such scheme: it builds a quantum code from a pair of classical linear codes
satisfying a containment (dual) condition.

The purpose of this paper is to make precise, and to derive cleanly, the
observation that CSS codes are *the same data* as chain complexes, and that their
key quantitative invariants are the standard invariants of homological algebra.
This perspective — the **homological** or **topological** view of quantum codes —
underlies the surface and toric codes that dominate contemporary fault-tolerant
hardware, and it is the engine behind the modern theory of quantum
low-density-parity-check (qLDPC) codes. Our contribution here is a self-contained,
fully formalized account of the algebraic core of that correspondence: definitions,
the bridge theorem, the dimension theory, the distance infrastructure, and a
worked combinatorial family.

Throughout, `𝔽` is an arbitrary field (for physical qubits, `𝔽 = 𝔽₂`, the field
with two elements), `n` is the number of physical qubits, and the ambient space is
the finite-dimensional coordinate space `𝔽ⁿ`, written `Fin n → 𝔽`. We write
`finrank 𝔽 M` for the dimension of an `𝔽`-vector space `M`, and `M ⧸ N` for the
quotient of `M` by a subspace `N`.

---

## 2. CSS codes

### 2.1 Definition

**Definition 2.1 (CSS code).** A *CSS code* over a field `𝔽` with ambient
dimension `n` is a triple `(C_X, C_Z, contains)` where `C_X` and `C_Z` are
subspaces of `𝔽ⁿ` and `contains` is a proof that `C_Z ≤ C_X`.

The subspace `C_X` is the X-stabilizer code — the set of vectors annihilated by
the parity-check (X-type) measurements. The subspace `C_Z` is the Z-stabilizer
code — the image of the Z-type generators. The containment `C_Z ≤ C_X` is the
orthogonality/dual condition that makes the X- and Z-checks commute, and it is
exactly the hypothesis needed for the code to be well defined as a quantum code.

**Definition 2.2 (Logical qubits).** The number of logical qubits encoded by a
CSS code `C` is
```
logicalQubits(C) := dim(C_X / C_Z),
```
where, formally, `C_Z` is viewed inside `C_X` via the comap of the inclusion
`C_X ↪ 𝔽ⁿ`, so the quotient `C_X ⧸ (C_Z ∩ C_X)` is taken; since `C_Z ≤ C_X`
this is the honest quotient `C_X / C_Z`.

The intuition: two codewords of `C_X` represent the same logical state iff they
differ by an element of `C_Z` (a stabilizer, which acts trivially), so logical
states are cosets, and the count of independent logical qubits is the dimension of
the coset space.

### 2.2 Self-duality

**Theorem 2.3 (Self-dual codes are trivial).** If `C_X = C_Z`, then
`logicalQubits(C) = 0`.

*Proof sketch.* If `C_X = C_Z`, then pulling `C_Z` back along the inclusion
`C_X ↪ 𝔽ⁿ` yields the whole of `C_X`, i.e. `C_Z ∩ C_X = C_X` as a subspace of
`C_X`, which is the top subspace `⊤`. The quotient `C_X / ⊤` is the zero space,
whose dimension is `0`. Formally one shows the comapped submodule equals `⊤` and
then applies the criterion that a finite-rank quotient by the top submodule is a
subsingleton. ∎

This is the algebraic statement that a self-dual CSS code is pure scaffolding: it
imposes constraints but encodes no information. Such codes are nonetheless useful
as components and as limiting cases.

### 2.3 Additivity

**Theorem 2.4 (Logical-qubit additivity; quantum third isomorphism theorem).**
Let `C_Z ≤ C_mid ≤ C_X` be nested subspaces of `𝔽ⁿ` with `𝔽ⁿ`
finite-dimensional. Then
```
dim(C_X / C_Z) = dim(C_X / C_mid) + dim(C_mid / C_Z).
```

*Proof sketch.* For any finite-dimensional space `V` and subspace `W` one has
`dim(V/W) = dim V − dim W` (a consequence of `dim(V/W) + dim W = dim V`). Applying
this to the three quotients reduces the claim to the additive identity among
plain dimensions
```
(dim C_X − dim C_Z) = (dim C_X − dim C_mid) + (dim C_mid − dim C_Z),
```
which holds by elementary arithmetic once one verifies, via the map/comap
adjunction for the relevant inclusions, that the dimensions of the comapped
submodules agree with the dimensions of `C_Z`, `C_mid` inside the larger spaces.
The arithmetic uses the truncated-subtraction identity
`(a − b) + (b − c) = (a − c)` valid when `c ≤ b ≤ a`. ∎

Operationally, Theorem 2.4 says one may analyze a code by inserting intermediate
stabilizer subgroups and counting logical qubits layer by layer; the counts are
exactly conserved.

---

## 3. Chain complexes and the bridge theorem

### 3.1 Three-term chain complexes

**Definition 3.1 (Three-term chain complex).** A *three-term chain complex* over
`𝔽` is the data
```
V₂ = 𝔽ᵐ  →[∂₂]  V₁ = 𝔽ⁿ  →[∂₁]  V₀ = 𝔽ᵖ,
```
consisting of dimensions `n, m, p`, linear maps `∂₂ : 𝔽ᵐ → 𝔽ⁿ` and
`∂₁ : 𝔽ⁿ → 𝔽ᵖ`, and a proof of the **chain condition**
```
∂₁ ∘ ∂₂ = 0.
```

The middle space `V₁ = 𝔽ⁿ` is the space of physical qubits; `∂₁` is the parity
check map and `∂₂` is the syndrome/generator map.

**Definition 3.2 (Cycles and boundaries).**
```
cycles(K)     := ker(∂₁)     (the 1-cycles),
boundaries(K) := range(∂₂)   (the 1-boundaries).
```

**Lemma 3.3 (Boundaries are cycles).** `boundaries(K) ≤ cycles(K)`.

*Proof sketch.* Let `x ∈ range(∂₂)`, say `x = ∂₂(y)`. Then
`∂₁(x) = ∂₁(∂₂(y)) = (∂₁ ∘ ∂₂)(y) = 0`, so `x ∈ ker(∂₁)`. The single ingredient is
the chain condition, applied pointwise. ∎

**Definition 3.4 (First homology and Betti number).**
```
H₁(K)   := cycles(K) / boundaries(K) = ker(∂₁)/range(∂₂),
β₁(K)   := dim H₁(K).
```

### 3.2 From complexes to codes

**Definition 3.5 (CSS code of a complex).** The CSS code associated to a complex
`K` is
```
toCSSCode(K) := ( C_X = cycles(K),  C_Z = boundaries(K),  contains = Lemma 3.3 ).
```
Lemma 3.3 supplies the required containment, so this is always a valid CSS code.

### 3.3 The bridge theorem

**Theorem 3.6 (Homological dimension theorem).** For every three-term chain
complex `K`,
```
logicalQubits(toCSSCode(K)) = β₁(K).
```

*Proof sketch.* By Definition 3.5 the code's `C_X` and `C_Z` are exactly
`cycles(K)` and `boundaries(K)`, so the quotient defining `logicalQubits` is by
definition `cycles(K)/boundaries(K) = H₁(K)`, whose dimension is `β₁(K)`. The two
sides are definitionally equal; the identity holds by reflexivity once the
definitions are unfolded. ∎

Theorem 3.6 is the keystone: the engineering quantity (number of logical qubits)
and the topological quantity (first Betti number) are literally identical. A code
designed by choosing a shape with `β₁` holes encodes exactly `β₁` logical qubits.

---

## 4. Dimension theory

### 4.1 The quantum rank–nullity identity

**Theorem 4.1 (CSS dimension formula).** For a finite-dimensional complex `K`,
```
β₁(K) + dim(boundaries(K)) = dim(cycles(K)),
```
where `dim(boundaries(K))` is computed as the dimension of `boundaries(K)` viewed
inside `cycles(K)` (the comap along the inclusion `cycles ↪ 𝔽ⁿ`).

*Proof sketch.* This is the rank–nullity theorem for the quotient map
`cycles(K) → cycles(K)/boundaries(K)`. Mathlib's
`finrank_quotient_add_finrank` states `dim(V/W) + dim W = dim V`; instantiating
`V = cycles(K)` and `W = boundaries(K) ∩ cycles(K)` and recognizing
`dim(V/W) = β₁(K)` gives the result directly. ∎

Theorem 4.1 says the cycles split cleanly into the "trivial" boundaries and the
"genuine holes" counted by `β₁`; no dimension is created or destroyed.

### 4.2 The underlying linear rank–nullity

**Theorem 4.2 (Rank–nullity for the parity-check map).** For a finite-dimensional
complex `K`,
```
dim(cycles(K)) + dim(range(∂₁)) = n.
```

*Proof sketch.* This is precisely the rank–nullity theorem applied to
`∂₁ : 𝔽ⁿ → 𝔽ᵖ`: `dim(range ∂₁) + dim(ker ∂₁) = dim(𝔽ⁿ) = n`. Since
`cycles(K) = ker(∂₁)`, commuting the summands gives the stated form. ∎

Combining Theorems 4.1 and 4.2 yields the full dimension count for the middle
layer of the complex: the `n` physical qubits split into the image of `∂₁` (the
detectable syndromes), the boundaries (the trivial stabilizer logicals), and the
`β₁` genuine logical qubits.

---

## 5. Distance and Hamming weight

To speak of error-correcting power we need a metric on `𝔽ⁿ`. The relevant one is
the Hamming weight.

**Definition 5.1 (Hamming weight).** For `v ∈ 𝔽ⁿ` (with `𝔽` having decidable
equality and a zero),
```
hammingWeight(v) := #{ i ∈ Fin n : v i ≠ 0 },
```
the number of nonzero coordinates.

**Theorem 5.2 (Definiteness).** `hammingWeight(v) = 0 ⇔ v = 0`.

*Proof sketch.* The weight is the cardinality of the set of coordinates where `v`
is nonzero; this cardinality is zero iff that set is empty iff `v i = 0` for every
`i` iff `v = 0` (by function extensionality). ∎

**Theorem 5.3 (Subadditivity / triangle inequality).** For `v, w ∈ 𝔽ⁿ` over an
additive group `𝔽`,
```
hammingWeight(v + w) ≤ hammingWeight(v) + hammingWeight(w).
```

*Proof sketch.* The support of `v + w` is contained in the union of the supports
of `v` and `w`: if `v i = 0` and `w i = 0` then `(v + w) i = 0`. Hence
`#supp(v+w) ≤ #(supp v ∪ supp w) ≤ #supp v + #supp w`, using monotonicity of
cardinality under inclusion and the inclusion–exclusion bound
`#(A ∪ B) ≤ #A + #B`. ∎

Theorems 5.2 and 5.3 establish that the Hamming weight behaves as a norm on `𝔽ⁿ`,
which is exactly what is needed to define and reason about the code **distance**,
the minimum weight of a nontrivial logical operator. In the homological dictionary
a nontrivial logical operator is a cycle that is *not* a boundary — a loop around a
hole — and its Hamming weight is the loop's combinatorial length. The minimum such
length is the **systolic distance** of the complex, and it lower-bounds (in fact,
equals, for the canonical logicals) the error-correcting distance of the code.
This is the quantitative content of the slogan "distance is systole."

---

## 6. Homological quantum error-correcting codes (HQECC)

We package the construction.

**Definition 6.1 (HQECC).** A *homological quantum error-correcting code* over
`𝔽` is a triple `(complex, code, code_eq)` consisting of a three-term chain
complex `complex`, a CSS code `code` on `complex.n` qubits, and a proof
`code_eq : code = toCSSCode(complex)`.

**Definition 6.2 (Canonical HQECC).** For any complex `K`,
`fromComplex(K) := (K, toCSSCode(K), rfl)`.

**Theorem 6.3 (Topological encoding rate).** For every HQECC `H`,
```
logicalQubits(H.code) = β₁(H.complex).
```

*Proof sketch.* Rewrite `H.code` by `code_eq` to `toCSSCode(H.complex)` and apply
Theorem 3.6. ∎

Theorem 6.3 says the encoding rate `k = β₁` of an HQECC is a topological
invariant: it does not depend on any choice of basis or presentation, only on the
homotopy type of the underlying complex.

---

## 7. Worked example: hypercube codes

We illustrate the theory on the hypercube graphs.

**Definition 7.1 (Hypercube Betti number).** Treating a connected graph as a
one-dimensional complex, its first Betti number is `β₁ = |E| − |V| + 1`. The
hypercube graph `Q_n` has `|V| = 2ⁿ` vertices and `|E| = n·2^{n-1}` edges, so we
define
```
hypercube_betti1(n) := n·2^{n-1} − 2ⁿ + 1   (as an integer).
```

**Theorem 7.2 (The square).** `hypercube_betti1(2) = 1`.

*Proof sketch.* Direct computation: `2·2^{1} − 2^{2} + 1 = 4 − 4 + 1 = 1`. ∎

The square `Q_2` has a single independent cycle (its boundary loop); the
associated HQECC therefore encodes exactly one logical qubit.

**Theorem 7.3 (Multi-qubit hypercubes).** For all `n ≥ 3`,
`hypercube_betti1(n) > 1`.

*Proof sketch.* Write `f(n) = n·2^{n-1} − 2ⁿ + 1 = 2^{n-1}(n − 2) + 1`. For
`n ≥ 3` we have `n − 2 ≥ 1` and `2^{n-1} ≥ 4`, so `f(n) ≥ 4·1 + 1 = 5 > 1`;
formally one cases on small `n` and applies positivity of powers of two together
with a linear-arithmetic step. ∎

Theorem 7.3 **refutes** the naive conjecture that the highly symmetric hypercube
always encodes a single logical qubit: for every `n ≥ 3` the hypercube code is a
genuine multi-qubit code, with capacity growing as `β₁(Q_n) = 2^{n-1}(n-2)+1`,
i.e. roughly `n·2^{n-1}`. This shows the homological framework yields crisp,
falsifiable predictions about families of codes.

---

## 8. Algorithms

The constructive content of the theory is computable over a finite field; we
record the principal algorithms (full implementations appear in the accompanying
demonstration code).

**Algorithm A (Subspace dimension via Gaussian elimination).** Given a list of
vectors over `𝔽`, row-reduce to echelon form and count pivots; this computes the
dimension of their span (rank). Complexity `O(r · c · min(r, c))` for `r` vectors
in `c` dimensions.

**Algorithm B (Betti number / logical-qubit count).** Given matrices for `∂₂` and
`∂₁` (with `∂₁ ∂₂ = 0`), compute `dim cycles = n − rank(∂₁)` and
`dim boundaries = rank(∂₂)`, and return `β₁ = dim cycles − dim boundaries`
(Theorems 4.1, 4.2). Complexity dominated by two Gaussian eliminations.

**Algorithm C (Hypercube complex builder).** Generate the vertex/edge incidence
of `Q_n` and assemble the graph boundary map `∂₁` (and, for higher complexes, the
2-cell map `∂₂`), then apply Algorithm B. This realizes the family of Section 7
and lets one verify the formula `β₁(Q_n) = n·2^{n-1} − 2ⁿ + 1` numerically.

---

## 9. Applications and discussion

**Surface and toric codes.** The most successful quantum codes in practice arise
exactly as `toCSSCode` of two-dimensional cellular complexes (the torus, or a
planar patch with boundary). Their logical-qubit count is the surface's Betti
number (`2` for the torus, `1` for a planar patch with the right boundary
conditions), in precise agreement with Theorem 3.6, and their distance is the
systole, in agreement with Section 5.

**qLDPC codes.** Modern high-rate quantum codes are built by taking products
(tensor/balanced products) of small chain complexes. Theorems 3.6, 4.1, and 4.2
are the bookkeeping tools that compute the resulting rate and dimensions; the
additivity law (Theorem 2.4) governs how the counts behave under filtration.

**Code design as shape design.** The dictionary
```
logical qubits ↔ Betti number,   distance ↔ systole,   stabilizers ↔ boundaries
```
turns the search for good codes into the geometric problem of building complexes
with large `β₁` and large systole simultaneously — the central tension of the
field.

**Scope and limitations.** The present development treats the algebraic core: the
exact equality of logical-qubit count with the Betti number, the dimension theory,
and the metric infrastructure for distance. We have established the *definiteness*
and *subadditivity* of the Hamming weight (the prerequisites for distance bounds)
but state the systole–distance equality at the level of interpretation rather than
proving a quantitative lower bound here; that is the natural next target
(Section 10). Everything is over a field, so torsion phenomena (which distinguish
homology over `ℤ` from homology over `𝔽`) do not appear; over `𝔽₂`, the relevant
field for qubits, this is exactly right.

---

## 10. Future directions

1. **Quantitative systolic distance bound.** Prove `d(toCSSCode(K)) ≥ sys(K)` as
   an inequality between the code distance (minimum weight of a non-boundary
   cycle) and the combinatorial systole, upgrading the interpretive statement of
   Section 5 to a theorem. Combined with Theorems 5.2–5.3 this would give fully
   formal `[[n, k, d]]` parameters for homological codes.

2. **Dual (cohomological) code and Poincaré duality.** Formalize the Z-type code
   as the cohomology `H¹` and prove that, for complexes arising from closed
   `D`-manifolds, Poincaré duality identifies `β₁` with `β_{D−1}`, explaining the
   X/Z symmetry of CSS codes intrinsically.

3. **Products of complexes.** Define the tensor/balanced product of three-term
   complexes and prove a Künneth-style formula for the resulting Betti number,
   giving a formal route to high-rate qLDPC codes.

4. **Higher-dimensional complexes.** Extend from three-term to arbitrary length
   chain complexes, recovering `H_i` for all `i` and the corresponding multi-sector
   stabilizer structure.

5. **Numerically certified families.** Use Algorithms A–C to enumerate small
   complexes and certify their `[[n, k, d]]` parameters, building a verified
   catalogue of homological codes — including a complete account of the hypercube
   family `Q_n` whose rate `β₁(Q_n) = 2^{n-1}(n-2)+1` we have already established.

---

## 11. Conclusion

We have given a self-contained, formally verified account of the homological
foundations of CSS quantum codes. The central result is an exact identity — the
number of logical qubits of the code associated to a chain complex equals the
complex's first Betti number — supported by a complete dimension theory (a quantum
rank–nullity identity, the underlying linear rank–nullity theorem, and an
additivity law), the metric groundwork for code distance (the Hamming weight as a
norm), a self-duality result, an HQECC packaging with topologically determined
encoding rate, and an explicit combinatorial family (the hypercube codes) whose
Betti numbers we compute, refuting a naive single-qubit conjecture for all
`n ≥ 3`. The upshot is a precise dictionary in which the design of quantum memories
becomes the design of shapes, and the protection of quantum information becomes the
counting of holes.
