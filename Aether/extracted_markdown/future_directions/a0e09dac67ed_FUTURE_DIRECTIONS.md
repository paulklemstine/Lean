# Future Directions: Tropical Scattering One-Way Duality

## 1. Tropical Inner Rank Theory and Full Duality

**Goal**: Establish that for the tropical inner rank (the minimum k in any min-plus factorization T(i,j) = min_v (A(i,v) + B(v,j))), every minimal realization is reduced AND every reduced realization with k equal to the tropical inner rank is minimal.

**Specific Theorem Target**:
```
theorem tropical_inner_rank_invariant (T : TropicalMatrix m n) :
    ∀ G G' : ScatteringNetwork m n,
      G.transferMatrix = T → G'.transferMatrix = T →
      G.IsMinimal → G'.IsMinimal →
      G.k = G'.k
```
(Already proved in this work.)

The next step is to characterize the tropical inner rank directly from the matrix T without reference to factorizations, using tropical determinantal conditions or Barvinok rank theory.

**Proof Strategy**: Use the tropical Grassmannian structure. The inner rank equals the minimum number of "tropical segments" needed to represent the matrix. Connect to the Develin–Santos–Sturmfels theory of tropical convexity.

**Cross-Domain Impact**: This would give a complete tropical analogue of the classical rank-nullity theorem, connecting tropical linear algebra to network complexity.

---

## 2. Hardness of Certified Reconstruction

**Goal**: Prove computational hardness results for the inverse problem: given a tropical transfer matrix T, find a path-separation certificate (i.e., a minimal reduced realization).

**Specific Theorem Target**:
```
theorem certified_reconstruction_NP_hard :
    ∃ (reduction : SAT_Instance → TropicalMatrix m n),
      polynomial_time reduction ∧
      (∀ φ, satisfiable φ ↔ HasMinimalCertificate (reduction φ))
```

**Proof Strategy**: Reduce from the Tropical Rank Decision Problem, which is known to be NP-hard (Kim–Roush 2005). The reduction maps a Boolean satisfiability instance to a tropical matrix whose inner rank encodes satisfiability. The path-separation certificate then corresponds to a satisfying assignment.

**Cross-Domain Impact**: This would establish the first rigorous hardness result for tropical scattering inversion, providing the complexity-theoretic foundation for tropical cryptographic primitives.

---

## 3. Probabilistic/Noisy Tropical Scattering

**Goal**: Extend the theory to the setting where the transfer matrix is observed with additive noise. Define "approximate certified reconstruction" and prove that small perturbations of a transfer matrix from a reduced network admit approximate certificates.

**Specific Theorem Target**:
```
theorem noisy_reconstruction_stability
    (G : ScatteringNetwork m n) (hred : G.IsReduced)
    (T_noisy : TropicalMatrix m n)
    (h_close : ∀ i j, |T_noisy i j - G.transferMatrix i j| < ε) :
    ∃ G' : ScatteringNetwork m n,
      G'.k = G.k ∧
      ∀ i j, |G'.transferMatrix i j - T_noisy i j| < δ(ε)
```

**Proof Strategy**: Use the separation gap from path-separation certificates. If vertex v has separation gap γ_v (minimum difference between its path weight and the next best), then perturbations of size ε < γ_v/2 preserve the essential vertex structure. The stability bound δ(ε) should be linear in ε.

**Cross-Domain Impact**: Connects to network tomography, where measurements are inherently noisy. Also relevant to adversarial robustness in tropical neural networks.

---

## 4. Tropical Spectral Invariants of Transfer Semimodules

**Goal**: Define tropical eigenvalues and eigenvectors of the transfer matrix and show they encode the internal network structure. Specifically, the tropical eigenvalues of T should determine the "energy levels" of the internal vertices.

**Specific Theorem Target**:
```
theorem tropical_eigenvalues_determine_vertex_structure
    (G : ScatteringNetwork m n) (hmin : G.IsMinimal) :
    TropicalSpectrum (G.transferMatrix) =
      {G.pathWeight i v j | i j v, IsEssentialVertex G v ∧ isWitnessPair G v i j}
```

**Proof Strategy**: Define the tropical spectrum as the set of critical values of the tropical permanent/determinant of T. Show that for a minimal realization, these critical values correspond exactly to the path weights at witness pairs of essential vertices. Use the max-plus spectral theory of Akian, Bapat, and Gaubert.

**Cross-Domain Impact**: Bridges tropical linear algebra to spectral graph theory and opens connections to quantum information (tropical analogues of Schmidt coefficients).

---

## 5. Categorical Duality: Scattering Networks vs. Idempotent State Objects

**Goal**: Establish a categorical equivalence between:
- The category of finite reduced scattering networks (with boundary-preserving weighted isomorphisms)
- The category of finitely generated irredundant idempotent semimodules (with tropical-linear maps)

**Specific Theorem Target**:
```
theorem scattering_semimodule_equivalence :
    CategoryEquivalence
      (ReducedScatteringNetworks m n)
      (IrredundantTransferSemimodules m n)
```

**Proof Strategy**: The functor from networks to semimodules sends G to its transfer semimodule. The functor from semimodules to networks uses the extremal generator construction. Show these are mutually inverse up to natural isomorphism, using the essential vertex correspondence as the key technical ingredient.

**Cross-Domain Impact**: This would be a tropical analogue of the Tannaka–Krein duality, connecting representation theory to network structure. It opens a path to tropical Langlands-type correspondences and categorical quantum mechanics in the idempotent setting.

---

## Summary Table

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| Tropical inner rank | Medium | High | Tropical convexity theory |
| Hardness of reconstruction | High | Very High | Complexity theory, NP-hardness reductions |
| Noisy scattering | Medium | High | Real analysis, metric geometry |
| Spectral invariants | Medium-High | High | Tropical spectral theory |
| Categorical duality | Very High | Breakthrough | Category theory, representation theory |

Each direction builds on the formally verified foundation established in this work: the definitions of `ScatteringNetwork`, `transferMatrix`, `IsEssentialVertex`, `IsReduced`, `IsMinimal`, and the key theorems `minimal_implies_reduced`, `nonessential_transfer_preserved`, and `exists_minimal_realization`.
