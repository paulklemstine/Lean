# Future Directions: Tropical Arithmetic Geometry of Polarized Tori

This document outlines concrete breakthrough-level research opportunities opened by the tropical BSD formula for higher-dimensional polarized abelian varieties.

---

## Direction 1: Tropical BSD for Tropical Jacobians of Higher-Genus Curves

### Vision
Every tropical curve of genus *g* has a tropical Jacobian — a *g*-dimensional tropical abelian variety with a canonical principal polarization. Applying the BSD formula to tropical Jacobians would create a direct bridge between the combinatorics of tropical curves (chip-firing, divisor theory, Baker–Norine Riemann–Roch) and the BSD arithmetic of their Jacobians.

### Hypotheses
1. The tropical regulator of the Jacobian of a tropical curve Γ equals the number of spanning trees of Γ (the graph-theoretic complexity).
2. The tropical theta order for Jacobians equals the genus *g*, recoverable from the Baker–Norine theory.
3. For metric graphs with edge lengths, the regulator interpolates between the combinatorial complexity and a continuous volume invariant.

### Proof Strategy
- Construct the period matrix Ω of a tropical curve explicitly from its edge lengths and cycle structure.
- Show that det(Ω) equals the weighted complexity (weighted spanning tree count).
- Apply the general BSD theorem to specialize to the Jacobian case.
- Verify computationally for small-genus curves (g = 2, 3, 4).

### Cross-Domain Connections
- Baker–Norine chip-firing ↔ tropical Mordell–Weil group
- Kirchhoff's matrix-tree theorem ↔ tropical regulator = complexity
- Tropical Torelli theorem ↔ injectivity of the BSD invariant map

### Estimated Difficulty
Medium-high. The period matrix construction is standard but the determinant = complexity identity requires careful proof.

---

## Direction 2: Tropical Néron Models and Exact Tamagawa Computations

### Vision
In our current framework, bad places are empty and Tamagawa numbers are trivially 1. A richer theory arises when tropical abelian varieties have "bad reduction" — singularities or degenerations at certain valuations. Developing tropical Néron models would provide a systematic framework for computing nontrivial Tamagawa numbers.

### Hypotheses
1. A tropical Néron model for a degenerating family of tropical tori can be constructed as a piecewise-linear group scheme over a tropical base.
2. The component group of the special fiber at a bad place determines the Tamagawa number.
3. For degenerations of tropical abelian surfaces (g = 2), the Tamagawa numbers are determined by the singularity type of the degenerate fiber (analogous to Kodaira–Néron classification).

### Proof Strategy
- Define tropical Néron models as certain polyhedral complexes with group structure.
- Classify degeneration types for g = 2 and compute component groups.
- Show finiteness of bad places via a tropical discriminant criterion.
- Prove that the Tamagawa numbers computed from the Néron model satisfy the BSD formula.

### Cross-Domain Connections
- Classical Néron models ↔ tropical polyhedral group schemes
- Kodaira–Néron classification ↔ tropical degeneration types
- Berkovich analytification ↔ tropicalization of Néron models

### Estimated Difficulty
High. This requires substantial new infrastructure for tropical group schemes.

---

## Direction 3: Tropical Height Pairings and BSD Regulators

### Vision
In the classical BSD formula, the regulator is the determinant of the Néron–Tate height pairing matrix on a basis of the Mordell–Weil group. Our current tropical regulator is the determinant of the polarization matrix, which plays the role of the "period matrix regulator." Developing tropical height pairings would give a second, arithmetic regulator, and proving their agreement (or understanding their discrepancy) would deepen the tropical BSD formula.

### Hypotheses
1. A tropical Néron–Tate height on tropical abelian varieties can be defined as a piecewise-quadratic function on the torus.
2. The height pairing matrix on a basis of the tropical Mordell–Weil group has determinant equal to det(Ω) up to a correction factor involving the tropical Tate–Shafarevich group.
3. For tropical Jacobians, the height pairing reduces to the graph-theoretic energy pairing of Zhang.

### Proof Strategy
- Define tropical heights following the Green's function approach of Baker–Rumely and Zhang for metric graphs.
- Extend to higher-dimensional tropical tori using the polarization form.
- Prove the height pairing is positive definite and compute its determinant.
- Compare with the period matrix regulator.

### Cross-Domain Connections
- Arakelov theory ↔ tropical intersection theory
- Zhang's admissible pairing ↔ tropical Néron–Tate height
- Beilinson–Bloch regulators ↔ tropical higher regulators

### Estimated Difficulty
High. Tropical height theory in higher dimensions is largely undeveloped.

---

## Direction 4: Nonarchimedean Comparison Theorems

### Vision
The deepest open question is: how do tropical BSD invariants relate to classical BSD invariants? Via the Berkovich skeleton construction, every abelian variety *A* over a nonarchimedean field has a tropical skeleton Σ(A), which is a tropical abelian variety. A comparison theorem would show that the BSD invariants of *A* and Σ(A) are related by explicit and computable factors.

### Hypotheses
1. For an abelian variety *A* over a nonarchimedean field *K* with good reduction, the tropical regulator of Σ(A) equals the nonarchimedean regulator of *A* (up to a log-volume correction).
2. The tropical Tamagawa numbers of Σ(A) at bad places correspond to the classical Tamagawa numbers of *A* at the same places.
3. For totally degenerate abelian varieties (Mumford uniformization), the comparison is exact.

### Proof Strategy
- For totally degenerate abelian varieties, use Mumford's construction to identify the period matrix with the tropical polarization.
- Prove that the Berkovich skeleton is a tropical abelian variety with the induced polarization.
- Show that det(Ω_trop) = det(Ω_classical) · (explicit correction).
- Handle the non-totally-degenerate case via a filtration argument.

### Cross-Domain Connections
- Berkovich geometry ↔ tropical geometry
- Mumford uniformization ↔ tropical period matrices
- Rigid analytic theta functions ↔ tropical theta functions
- SYZ mirror symmetry ↔ tropical/classical duality

### Estimated Difficulty
Very high. This is at the frontier of nonarchimedean geometry.

---

## Direction 5: Reconstruction of Global Regulators from Rank-2 Slices

### Vision
Inspired by the rank-2 Levi profile reconstruction theorem from the GL₃ Satake theory, we conjecture that the global tropical regulator can be recovered from the family of all rank-2 tropical sections. This would provide a "local-to-global" principle for tropical regulators, analogous to the local-to-global philosophy in arithmetic geometry.

### Hypotheses
1. For a *g*-dimensional tropical abelian variety, the determinant det(Ω) can be reconstructed from the 2×2 minors of Ω (i.e., from all rank-2 tropical sections).
2. This reconstruction is unique for g ≥ 3.
3. The reconstruction formula has a representation-theoretic interpretation in terms of the symmetric group action on the lattice.

### Proof Strategy
- For g = 3, show that the 3 independent 2×2 principal minors, together with the 3 off-diagonal entries, determine det(Ω) via the formula det = m₁₁m₂₂m₃₃ + 2m₁₂m₁₃m₂₃ − m₁₁m₂₃² − m₂₂m₁₃² − m₃₃m₁₂².
- Generalize via the cofactor expansion identity.
- Prove that rank-2 slice data determines the full Gram matrix (up to the action of GL_g(ℤ)).

### Cross-Domain Connections
- Representation theory of GL_g ↔ minor determinants
- Cauchy–Binet formula ↔ slice determinants
- Matroid theory ↔ independence of rank-2 sections

### Estimated Difficulty
Medium. The linear algebra is classical but the formal verification and the representation-theoretic interpretation are novel.

---

## Meta-Direction: Building a Tropical Arithmetic Geometry Library

### Vision
The results in this paper should be the first module in a comprehensive formally verified library for tropical arithmetic geometry. The library should include:

1. **Tropical abelian varieties** (real tori with polarizations)
2. **Tropical theta functions** (piecewise linear functions, tropical Fourier analysis)
3. **Tropical Jacobians** (from tropical curves to abelian varieties)
4. **Tropical heights** (Néron–Tate pairings, Arakelov theory)
5. **Tropical L-functions** (zeta functions of tropical varieties)
6. **Tropical BSD invariants** (the full dictionary)
7. **Comparison theorems** (tropical vs. classical vs. nonarchimedean)

This would be a multi-year effort but would produce the first formally verified arithmetic geometry library, with applications to number theory, algebraic geometry, cryptography, and combinatorics.

---

## Timeline and Priority

| Direction | Priority | Timeline | Dependencies |
|:---:|:---:|:---:|:---:|
| 1. Tropical Jacobians | High | 3–6 months | Current work |
| 2. Tropical Néron models | Medium | 6–12 months | Direction 1 |
| 3. Tropical heights | Medium | 6–12 months | Directions 1–2 |
| 4. Nonarchimedean comparison | High (long-term) | 12–24 months | Directions 1–3 |
| 5. Rank-2 reconstruction | Medium | 3–6 months | Current work |
| Library building | Ongoing | Continuous | All |
