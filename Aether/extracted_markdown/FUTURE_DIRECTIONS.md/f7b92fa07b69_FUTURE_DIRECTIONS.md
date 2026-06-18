# Future Directions — Homological CSS Codes and X–Z Duality

## Synthesis

The file `Bridges/CSSHomologicalDuality.lean` upgrades the *integer* Betti-number
bookkeeping of `Bridges/HigherQuantumLDPC.lean` (`HigherQuantumLDPC.CSSParams`,
`HigherQuantumLDPC.css_logical_dim_eq_betti`) into an *honest vector-space* model of a
CSS quantum code attached to a length-2 chain complex `C₂ → C₁ → C₀` over a field.
The logical qubits are the genuine homology `H₁ = ker d₁ / im d₂`, and the central
discovery is that the textbook CSS dimension calculus is **entirely rank–nullity**:

* `homology_finrank` : `dim H₁ = dim ker d₁ − dim im d₂`;
* `logicalQubits_eq` : `k = n − rank H_Z − rank H_X` (the standard CSS count);
* `css_duality` : the *transpose* (dual) complex has the **same** logical dimension —
  the algebraic shadow of CSS X↔Z self-duality, requiring no metric or Poincaré
  pairing, only `rank f = rank fᵀ` (`finrank_range_dualMap_eq_finrank_range`) and
  `dim V* = dim V` (`Subspace.dual_finrank_eq`);
* `circleCode_logicalQubits` : a concrete positive-rate witness with `k = 1`.

This is a clean *duality & representation* result: a topological/geometric complex is
represented by linear maps, the quantum code is read off its homology, and X–Z
symmetry becomes a dimension equality between a space and its dual.

## Results Summary

| Theorem | Statement |
|---------|-----------|
| `CSSComplex.range_d₂_le_ker_d₁` | CSS commutation `im d₂ ⊆ ker d₁` |
| `CSSComplex.homology_finrank` | `dim H₁ = dim ker d₁ − dim im d₂` |
| `CSSComplex.logicalQubits_eq` | `k = n − rank H_Z − rank H_X` |
| `CSSComplex.css_duality` | dual complex has identical logical dimension |
| `circleCode_logicalQubits` | explicit `k = 1` witness |

All proved with `sorry = 0`; axioms restricted to `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Euler–Poincaré at the vector-space level
Extend the middle-homology result to a full three-term Euler characteristic:
`dim H₂ − dim H₁ + dim H₀ = dim C₂ − dim C₁ + dim C₀`, identifying `H₀ = C₀/im d₁`
and `H₂ = ker d₂`. **The key insight is** that the alternating sum of homology
dimensions is invariant under the boundary maps, so the combinatorial Euler identity
`euler_char_eq_alternating_face_sum` in `HigherQuantumLDPC` lifts to an equality of
*actual* quotient/sub spaces rather than integers. **Why now?** The rank–nullity
toolchain (`finrank_range_add_finrank_ker`, `finrank_quotient_add_finrank`) used here
already discharges every term; only one more application per slot is needed.
*Falsifiable:* exhibit a complex where the two alternating sums differ.

### 2. Homological product codes and rate multiplicativity
Define the tensor (hypergraph) product of two `CSSComplex`es and prove
`dim H₁(A ⊗ B)` factors through the Künneth formula, yielding
`k(A⊗B) = k(A)·dim H₀(B) + dim H₀(A)·k(B) + …`. **The key insight is** that the
Mathlib tensor product of chain complexes makes the *rate* of a product code a
bilinear function of the factors' Betti numbers, so positive-rate families are closed
under products. **Why now?** With homology already a concrete quotient space, the
Künneth machinery in Mathlib (`TensorProduct`, `LinearMap.rTensor`) applies directly.
*Falsifiable:* find a product whose logical dimension violates the Künneth count.

### 3. Distance as a normed/weighted minimum over homology classes
Equip `C₁` with the Hamming weight (over `ZMod 2`) and *define* the code distance as
the minimum weight of a nonzero homology class, then prove a lower bound from
injectivity-radius / coboundary-expansion hypotheses. **The key insight is** that the
distance is a `sInf` over the nonzero cosets of `im d₂` inside `ker d₁`, a quantity
that is well-typed precisely because `homology` is an honest quotient. **Why now?**
The present file fixes the homology space; layering a weight function on top is the
minimal addition needed to make the `css_distance_lower_bound` of `HigherQuantumLDPC`
a statement about real codewords. *Falsifiable:* a family with positive rate but
distance bounded by a constant would refute polynomial-distance hopes.

### 4. Duality of distances, not just dimensions
Strengthen `css_duality` from an equality of *dimensions* to a pairing between the
minimum X-distance and the minimum Z-distance via the dual basis. **The key insight
is** that the perfect pairing `Module.Dual` induces an isomorphism of homology and
cohomology that should be *weight-aware* for self-dual complexes, linking `d_X` and
`d_Z`. **Why now?** `finrank_range_dualMap_eq_finrank_range` already gives the
numerical half; the dual-basis isomorphism (`Module.evalEquiv`,
`Basis.toDual`) is available to upgrade it. *Falsifiable:* a self-dual complex with
`d_X ≠ d_Z` would refute weight-aware duality.

### 5. Spectral (Laplacian) bound on the energy barrier
Introduce the combinatorial Laplacian `Δ = d₁ᵀd₁ + d₂d₂ᵀ` on `C₁` and relate its
spectral gap to a lower bound on the energy barrier of the associated quantum memory.
**The key insight is** that, in the dual/spectral picture, the energy barrier is
controlled by the smallest nonzero eigenvalue of `Δ` restricted to the syndrome-free
subspace, translating a hard combinatorial barrier problem into an eigenvalue
estimate. **Why now?** Mathlib's spectral theorem for self-adjoint operators on
finite-dimensional inner-product spaces makes the eigenvalue side tractable, and the
homology decomposition `ker Δ ≅ H₁` (discrete Hodge theory) is exactly the bridge our
homology construction supplies. *Falsifiable:* a positive-gap family with vanishing
asymptotic barrier would refute the spectral-barrier link.
