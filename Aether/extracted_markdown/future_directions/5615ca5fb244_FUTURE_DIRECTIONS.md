# Future Directions: Geometric Cryptanalysis

This document outlines concrete next steps opened by the bounded-box collision and short kernel vector theorems. Each direction includes exact theorem statements, required definitions, proof strategies, and cross-domain significance.

---

## 1. Matrix SIS Generalization with Ring Structure

### Goal
Extend `bounded_box_sis_witness` to exploit algebraic structure in the matrix `A` — for example, when `A` is a circulant matrix (as in Ring-SIS / NTRU-style constructions). Structured matrices yield shorter vectors because the kernel lattice has higher symmetry.

### Theorem Statement
```
theorem ring_sis_short_vector
    {n q B : ℕ}
    (hq : 0 < q)
    (a : Fin n → ℤ)  -- first row of circulant
    (hsize : q < (2 * B + 1) ^ n) :
    ∃ z : Fin n → ℤ,
      z ≠ 0 ∧
      (∀ i, |z i| ≤ 2 * B) ∧
      -- Az ≡ 0 mod q where A is the circulant of a
      (∀ j : Fin n, ((∑ i, a ((j - i) % n) * z i : ℤ) ≡ 0 [ZMOD q]))
```

### Definitions Needed
- `circulantMatrix : (Fin n → ℤ) → Matrix (Fin n) (Fin n) ℤ`
- `polynomialRingSIS : (ZMod q)[X] / (X^n + 1) → ...`

### Proof Strategies
1. **Direct instantiation**: Apply `bounded_box_sis_witness` with `A = circulantMatrix a` and `m = n`. The cardinality condition becomes `q^n < (2B+1)^n`, i.e., `q < 2B+1`.
2. **Polynomial ring approach**: Work in `(ℤ/qℤ)[X]/(X^n+1)` where circulant multiplication becomes polynomial multiplication. The kernel lattice is an ideal lattice, and Minkowski-type bounds from algebraic number theory give tighter norm estimates.

### Cross-Domain Significance
- **Post-quantum cryptography**: Ring-SIS is the hardness assumption behind CRYSTALS-Dilithium (NIST standard). Formal bounds on short vector existence directly bound the security level.
- **Algebraic number theory**: Connects ideal lattices in cyclotomic fields to combinatorial counting.

---

## 2. Weighted Norm / Anisotropic Box Version

### Goal
Replace the uniform box `|x_i| ≤ B` by coordinate-dependent bounds `|x_i| ≤ B_i`. This models attacks where different coordinates have different search ranges (e.g., partial key recovery, side-channel leakage of some bits).

### Theorem Statement
```
theorem weighted_box_collision_yields_short_kernel_vector
    {n q : ℕ}
    (hq : 0 < q)
    (a : Fin n → ℤ)
    (B : Fin n → ℕ)
    (hsize : q < ∏ i, (2 * B i + 1)) :
    ∃ z : Fin n → ℤ,
      z ≠ 0 ∧
      (∀ i, |z i| ≤ 2 * (B i : ℤ)) ∧
      ((∑ i, a i * z i : ℤ) ≡ 0 [ZMOD q])
```

### Definitions Needed
- `weightedBoxVec (n : ℕ) (B : Fin n → ℕ) : Finset (Fin n → ℤ)` — product of `Icc (-B i) (B i)`
- `anisotropicNorm (B : Fin n → ℕ) (z : Fin n → ℤ) : Prop` — `∀ i, |z i| ≤ 2 * B i`

### Proof Strategies
1. **Direct generalization**: The proof of `bounded_box_collision_yields_short_kernel_vector` works almost verbatim — replace the uniform `Icc (-B) B` by `Icc (-B i) (B i)` in the product finset. The cardinality becomes `∏ i, (2 * B i + 1)` instead of `(2B+1)^n`.
2. **Reduction to uniform case**: Choose `B_max = max_i B_i` and apply the uniform theorem in a larger box, then observe that the collision vectors actually lie in the weighted box.

### Cross-Domain Significance
- **Side-channel cryptanalysis**: Models attacks where some key bits are known (those coordinates have B_i = 0) while others are searched.
- **Lattice geometry**: Connects to Banaszczyk's transference theorem for non-uniform lattice bases.
- **Coding theory**: Weighted Hamming distance and unequal error protection codes.

---

## 3. Collision Multiplicity Theorem

### Goal
When the box is *much* larger than `q` (say `(2B+1)^n ≥ k · q`), guarantee not just one but at least `k` distinct short kernel vectors. This quantifies how attack complexity grows with the number of witnesses needed.

### Theorem Statement
```
theorem collision_multiplicity
    {n q B k : ℕ}
    (hq : 0 < q)
    (a : Fin n → ℤ)
    (hsize : k * q < (2 * B + 1) ^ n) :
    ∃ S : Finset (Fin n → ℤ),
      S.card ≥ k ∧
      (∀ z ∈ S, z ≠ 0) ∧
      (∀ z ∈ S, ∀ i, |z i| ≤ 2 * (B : ℤ)) ∧
      (∀ z ∈ S, ((∑ i, a i * z i : ℤ) ≡ 0 [ZMOD q]))
```

### Definitions Needed
- None beyond existing definitions; the key challenge is the inductive extraction argument.

### Proof Strategies
1. **Iterated pigeonhole**: By the pigeonhole principle, some residue class modulo `q` contains at least `⌈(2B+1)^n / q⌉ ≥ k+1` box vectors. Any two differences give kernel vectors. From `k+1` vectors in a coset, extract `k` distinct nonzero differences.
2. **Averaging argument**: The expected number of collisions is `(2B+1)^n / q`. Formalize this as a lower bound on the number of pairs, then extract distinct difference vectors via a greedy algorithm.

### Cross-Domain Significance
- **Additive combinatorics**: Connects to sumset structure theorems — many collisions force additive structure in the kernel.
- **Cryptographic security reduction**: Bounds the number of attack witnesses available, which appears in tight security reductions for lattice signatures.
- **Statistical physics**: Multiple ground states in a discrete energy landscape.

---

## 4. Tropical Determinant Bridge

### Goal
Connect the bounded-box collision threshold with the tropical determinant `det_trop(L)` of the kernel lattice to derive a formal complexity-vs-volume principle: the tropical determinant controls the minimal box size needed to guarantee a collision.

### Theorem Statement
```
theorem tropical_det_controls_collision_threshold
    {n q : ℕ}
    (hq : 0 < q)
    (a : Fin n → ℤ)
    (L : Set (Fin n → ℤ))  -- the kernel lattice
    (hL : L = {z | (∑ i, a i * z i : ℤ) ≡ 0 [ZMOD q]})
    (det_bound : ℕ)
    (hdet : det_bound ≤ q)  -- det of kernel sublattice divides q
    :
    -- If box volume exceeds det_bound, a short vector exists
    ∀ B : ℕ, det_bound < (2 * B + 1) ^ n →
    ∃ z : Fin n → ℤ,
      z ≠ 0 ∧ z ∈ L ∧ (∀ i, |z i| ≤ 2 * (B : ℤ))
```

### Definitions Needed
- `kernelLattice (q : ℕ) (a : Fin n → ℤ) : AddSubgroup (Fin n → ℤ)` — the kernel as an additive subgroup
- `latticeIndex : AddSubgroup (Fin n → ℤ) → ℕ` — the index `[ℤ^n : L]` for finite-index sublattices
- `tropicalDet : AddSubgroup (Fin n → ℤ) → ℕ` — connecting to `tropical_lattice_det_bound`

### Proof Strategies
1. **Index-based argument**: The kernel lattice `L` has index dividing `q` in `ℤ^n`. The number of cosets of `L` in the box is at most `(2B+1)^n / index(L)`. When this exceeds 1, two box vectors lie in the same coset, yielding a kernel vector.
2. **Smith normal form**: Express the kernel lattice via Smith normal form of the map `x ↦ ∑ a_i x_i mod q`. The tropical determinant relates to the product of diagonal entries, connecting to the determinant bound.

### Cross-Domain Significance
- **Geometry of numbers**: Formal discrete analog of Minkowski's first theorem relating lattice determinant to shortest vector length.
- **Complexity theory**: The tropical determinant becomes a formal measure of "cryptographic hardness" — larger determinant = harder to find short vectors = more secure.
- **Optimization**: Connects to tropical geometry and min-plus algebra interpretations of lattice problems.

---

## 5. Coding-Theoretic Corollary: Bounded Syndrome-Zero Patterns

### Goal
Reinterpret the matrix SIS theorem as a statement about error-correcting codes: if a parity-check matrix `H` over `ℤ_q` defines a code, and the number of bounded error patterns exceeds the syndrome space, then a nonzero bounded-weight codeword must exist.

### Theorem Statement
```
theorem bounded_weight_codeword_existence
    {m n q : ℕ}
    (hq : 0 < q)
    (H : Matrix (Fin m) (Fin n) (ZMod q))  -- parity check matrix
    (w : ℕ)  -- weight bound
    (hsize : q ^ m < (2 * w + 1) ^ n) :
    ∃ c : Fin n → ℤ,
      c ≠ 0 ∧
      (∀ i, |c i| ≤ 2 * (w : ℤ)) ∧
      (∀ j : Fin m, (∑ i, H j i * (c i : ZMod q)) = 0)
```

### Definitions Needed
- `qaryCode (q : ℕ) (H : Matrix (Fin m) (Fin n) (ZMod q)) : Set (Fin n → ZMod q)` — the null space of H
- `liftToInt : (Fin n → ZMod q) → Finset (Fin n → ℤ)` — lift representatives
- `hammingWeight / supNorm` — appropriate weight measures for q-ary codes

### Proof Strategies
1. **Direct application**: Apply `bounded_box_sis_witness` with `A` being any integer lift of `H`. The modular arithmetic ensures the result holds for the `ZMod q` parity check.
2. **Singleton bound comparison**: Compare the existence threshold `(2w+1)^n > q^m` with the classical q-ary Singleton and Plotkin bounds. Show that the SIS theorem recovers known distance bounds for random codes as a special case.

### Cross-Domain Significance
- **Coding theory**: Provides a unified lattice-geometric proof of minimum distance bounds for q-ary codes, complementing algebraic and probabilistic arguments.
- **Cryptography**: The dual view — codes whose minimum distance is large correspond to hard SIS instances — is the foundation of code-based cryptography (McEliece, BIKE, Classic McEliece).
- **Information theory**: Connects channel coding capacity to lattice packing density.

---

## Team Directive

Create a team to conduct research along these five directions. Each direction should:

1. **Formulate precise hypotheses** in both mathematical and formal (type-theoretic) language.
2. **Build proof skeletons** with helper lemmas isolating each logical step.
3. **Run computational experiments** to validate conjectures before formal proof attempts.
4. **Cross-validate** between directions — results in one direction should constrain or inform others.
5. **Iterate** — each proved theorem opens new questions; update this document as the frontier advances.

The overall research program aims to build a comprehensive formal library of **geometric cryptanalysis**, where:
- Security parameters are derived from lattice geometry,
- Attack complexities are proved (not estimated) from counting arguments,
- The connection between combinatorial search and geometric structure is made mathematically rigorous.

This is not an incremental program. It is the foundation of a new mathematical discipline at the intersection of cryptography, lattice theory, and formal verification.
