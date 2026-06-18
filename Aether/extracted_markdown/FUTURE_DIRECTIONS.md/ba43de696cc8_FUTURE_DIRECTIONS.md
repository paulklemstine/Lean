# Future Directions: Tropical BSD Specialization Program

## Direction 1: Tropical BSD for Newton Polygon Families

**Target Theorem**: Extend the tropical order-equals-rank equality from finite-support models to piecewise-linear Newton polygon families, where the L-series arises as the lower envelope of a Newton polygon subdivision.

**Construction**: Given a Newton polygon Δ in ℝ² with lattice points indexed by a finite set, define the tropical L-series as the support function of Δ. The tropical order of vanishing at a specified slope becomes the lattice width of the corresponding face, and the tropical rank corresponds to the dimension of the dual cell in the normal fan.

**Target statement (Lean)**:
```lean
theorem tropical_BSD_Newton_polygon
    (Δ : Finset (ℤ × ℤ)) (slope : ℝ)
    (hΔ : NewtonPolygonNondegenerate Δ)
    (hcompat : NewtonBSDCompatible Δ slope) :
    newtonFaceWidth Δ slope = tropicalRank (newtonGenerators Δ slope)
```

**Why it matters**: This connects tropical BSD to toric geometry and makes the framework applicable to families of algebraic curves, where Newton polygons encode the combinatorial type of degenerations. It also connects to the theory of tropical curves via Mikhalkin's correspondence theorem.

**Builds on**: `tropical_order_eq_rank` (the flagship equality) and `activeSetAt_add_const_a` (shift invariance, needed for normalization in the Newton polygon setting).

---

## Direction 2: Tropical Regulators via Tropical Determinant Theory

**Target Construction**: Formalize competing definitions of tropical determinant (tropical permanent, Speyer's tropical determinant, and the signed tropical determinant) and prove comparison theorems relating the resulting regulator invariants.

**Key Questions**:
- When do the tropical permanent and tropical determinant agree?
- Under what conditions is the regulator invariant under different notions of tropical basis change?
- Can one define a "tropical height pairing" whose tropical determinant gives the regulator?

**Target statement (Lean)**:
```lean
theorem tropical_regulator_comparison
    (n : ℕ) (R : Matrix (Fin n) (Fin n) ℝ)
    (hR : TropicalRegulatorMatrix R)
    (hgeneric : GenericMatrix R) :
    tropicalPermanent R = tropicalSignedDeterminant R
```

**Why it matters**: The classical BSD regulator is a determinant of the height pairing matrix. Different tropicalizations give different invariants; understanding their relationships is essential for making tropical BSD rigorous as an approximation to classical BSD.

**Builds on**: `tropicalRegulatorAdditive_perm_invariant` (permutation invariance of the tropical permanent) and `tropicalRegulatorAdditive_le_trace` (upper bound on the regulator).

---

## Direction 3: Tropical Tate–Shafarevich Obstructions

**Target Construction**: Define a tropical Shafarevich group as an obstruction to lifting tropical generators to a full tropical BSD equality, and show it controls the gap between the inequality and equality versions of tropical BSD.

**Concept**: In classical BSD, the Tate–Shafarevich group Ш measures the failure of the local-global principle. In the tropical setting, define:
- Local tropical rank: rank computed from restrictions to individual coordinates
- Global tropical rank: rank of the full family
- Tropical Ш: a finite abelian group whose order equals the discrepancy

**Target statement (Lean)**:
```lean
theorem tropical_Sha_controls_gap
    (gens : Fin m → Fin k → ℝ)
    (a w : ℕ → ℝ) (support : Finset ℕ) (hs : support.Nonempty)
    (hineq : tropicalRank gens ≤ tropicalOrderAtOne a w support hs) :
    tropicalOrderAtOne a w support hs - tropicalRank gens =
      tropicalShaOrder gens a w support hs
```

**Why it matters**: This would complete the tropical BSD package by providing a tropical analogue of every term in the classical BSD formula. It opens connections to tropical cohomology and obstruction theory.

**Builds on**: `tropical_BSD_equality_upgrade` (the inequality-to-equality principle) and the compatibility structure `TropicalBSDCompatible`.

---

## Direction 4: Tropical BSD for Higher-Dimensional Abelian Varieties

**Target Theorem**: Extend tropical BSD from the 1-dimensional case (elliptic curves / rank-1 families) to higher-dimensional tropical abelian varieties, where the regulator becomes a tropical Gram matrix determinant and the Tamagawa numbers arise from a finite collection of local valuations.

**Construction**: For a g-dimensional tropical abelian variety A (a real torus with an integral structure), define:
- Tropical rank = dimension of the period lattice
- Tropical L-series from the theta function / Riemann form
- Tropical order = multiplicity of the zero of the tropical theta function

**Target statement (Lean)**:
```lean
theorem tropical_BSD_abelian_variety
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : PositiveDefinite Ω) (hcompat : AbelianBSDCompatible Ω) :
    tropicalThetaOrder Ω = g
```

**Why it matters**: This is the natural generalization of BSD to higher genus. Tropical abelian varieties are well-studied objects in tropical geometry, and formalizing their BSD-type invariants would create a bridge between formal arithmetic geometry and tropical moduli theory.

**Builds on**: `tropical_residue_decomposes_add` (the additive residue decomposition) and `tropicalRegulatorAdditive_perm_invariant` (regulator invariance).

---

## Direction 5: Tropical Special Values and Information-Theoretic Entropy

**Target Theorem**: Prove that the tropical residue at the critical point equals a tropical mutual information between the generator family and the L-data, establishing a formal connection between arithmetic special values and information theory.

**Construction**: Define:
- Tropical entropy H_trop(X) = log₂(|active set of X|) for a tropical random variable
- Tropical mutual information I_trop(X; Y) = H_trop(X) + H_trop(Y) - H_trop(X, Y)
- Show that the residue decomposes as: TropRes = I_trop(Generators; L-data) + correction

**Target statement (Lean)**:
```lean
theorem tropical_residue_information_decomposition
    (gens : Fin m → Fin k → ℝ) (a w : ℕ → ℝ)
    (support : Finset ℕ) (hs : support.Nonempty) :
    tropicalResidueAdditive R c =
      tropicalMutualInformation gens (a, w, support) +
      tropicalCorrectionTerm gens (a, w, support)
```

**Why it matters**: This establishes a deep connection between number theory and information theory through tropical geometry. The tropical limit is the zero-temperature limit of statistical mechanics, and this direction formalizes the "free energy = special value" principle. It opens pathways to:
- Tropical data-processing inequalities for arithmetic
- Information-theoretic bounds on ranks of elliptic curves
- Connections to machine learning via tropical neural networks

**Builds on**: `tropical_residue_decomposes_add` and `tropical_idempotent` (the min-plus idempotent identity used for normalization).

---

## Cross-Cutting Research Program

These five directions form a coherent research program:

```
Direction 1 (Newton Polygons) ←→ Direction 4 (Higher Dimension)
         ↕                                ↕
Direction 2 (Regulators) ←→ Direction 3 (Sha Obstructions)
                   ↕
Direction 5 (Information Theory)
```

Each direction is independently pursuable but strengthens the others. The common thread is the tropical BSD machine: a formal framework in which arithmetic invariants become finite, computable, and connected to optimization and information theory.

**Immediate next step**: Direction 2 (tropical regulator comparison) is the most accessible and has the clearest path to completion, building directly on the permutation invariance theorem proved in this cycle.
