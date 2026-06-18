# Future Directions: Inverse Stereographic Neural Field Theory

## Conjecture 1: Mexican-Hat Mode Selection Law

**Conjecture**: For the spherical neural field linearized at the homogeneous state with Mexican-hat interaction kernel of radius r = 1/k (k ≥ 1), the maximal unstable eigenspace is exactly the degree-k spherical harmonic space, hence has dimension 2k+1.

**Test**: For r = 1, 1/2, 1/3, 1/4, 1/5, compute the first 20 Funk–Hecke eigenvalues λ_ℓ(r) for the Mexican-hat kernel on S². Verify that:
- The maximum of {λ_ℓ(r) : ℓ = 0, 1, ...} occurs uniquely at ℓ = k = ⌊1/r⌋.
- No other degree shares the maximal eigenvalue.

**Impact**: If true, this provides a computable prediction linking cortical interaction radius to the number of independent hallucinatory patterns (2k+1). If false, it constrains which kernel families admit clean mode selection, guiding experimental kernel fitting.

---

## Conjecture 2: Nodal Domain Correspondence Under Stereographic Transport

**Conjecture**: The number of nodal domains of a generic degree-ℓ spherical harmonic, when pulled back to ℝ² via inverse stereographic projection, equals the number of nodal domains of the original spherical function minus at most one (corresponding to the domain containing the north pole).

**Test**: For ℓ = 1, 2, 3, 4, construct explicit spherical harmonics Y_ℓ^m on S². Pull them back to ℝ² via inverse stereographic projection. Count nodal domains on S² (using Courant's theorem bounds) and compare with nodal domains in the planar pullback. Verify the correspondence numerically on a fine grid.

**Impact**: If confirmed, this establishes that the topology of cortical activation patterns (connected regions of excitation/inhibition) is preserved under conformal transport, validating the use of planar models for spherical cortical dynamics.

---

## Conjecture 3: Conformal Robustness of Mode Selection

**Conjecture**: Small perturbations of the cortical metric that preserve the conformal class (i.e., changes to the conformal factor but not the underlying conformal structure) do not change the index N of the dominant mode or its multiplicity 2N+1, provided the perturbation is C² small.

**Test**: Perturb the conformal factor from (2/(1+|x|²))² to (2/(1+|x|²))² · (1 + ε·φ(x)) for several smooth compactly supported φ and ε ∈ {0.01, 0.1, 0.5}. Recompute the spectrum of the linearized neural field operator numerically. Check whether the dominant mode index N and multiplicity are preserved.

**Impact**: If true, this justifies modeling real cortical geometry (which is only approximately spherical) using exact spherical harmonics. It would provide rigorous error bounds for the spherical approximation in mathematical neuroscience.

---

## Conjecture 4: Schrödinger Bound State Analogy

**Conjecture**: The weighted planar eigenvalue equation Δv + V_ℓ(x)v = 0 with conformal potential V_ℓ(x) = 4ℓ(ℓ+1)/(1+|x|²)² has exactly 2ℓ+1 linearly independent L²-solutions (bound states), and no continuous spectrum intersects the eigenvalue -ℓ(ℓ+1).

**Test**: Numerically solve the radial part of the Schrödinger equation with conformal potential for ℓ = 1, 2, 3, 4, 5. Count the number of L² solutions. Compare with the predicted multiplicity 2ℓ+1. Verify the absence of embedded eigenvalues using spectral methods.

**Impact**: If true, this creates a complete bridge between spherical harmonic analysis and quantum-mechanical scattering theory for conformal potentials, opening new tools for analyzing neural field stability via scattering theory.

---

## Conjecture 5: Equivariant Neural Network Optimality

**Conjecture**: For SO(3)-equivariant neural networks operating on spherical data, the optimal filter basis at resolution level ℓ consists of exactly 2ℓ+1 basis functions — the pulled-back spherical harmonics via stereographic projection — and any other equivariant basis of the same size is a rotation of this one.

**Test**: Train SO(3)-equivariant neural networks on spherical image classification tasks (e.g., spherical MNIST, climate data) using (a) the stereographic harmonic basis and (b) other equivariant bases (Wigner D-matrices, graph-based). Compare convergence rates, parameter efficiency, and final accuracy. Verify that learned filters project primarily onto the harmonic basis predicted by conformal transport.

**Impact**: If confirmed, this provides a mathematical foundation for the design of equivariant neural architectures on manifolds, showing that conformal geometry — not just group theory — determines optimal filter banks. This would bridge geometric deep learning with the cortical pattern theory.
