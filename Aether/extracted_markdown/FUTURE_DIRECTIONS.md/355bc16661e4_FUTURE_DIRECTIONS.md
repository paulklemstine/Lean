# Future Directions: Congruence-Level Tropical Geometry

Building on the congruence-level tropical Nullstellensatz established in
`Catalog/Bridges/EML/TropicalCongruenceNullstellensatz.lean`, we outline
five concrete next theorems and research directions.

## 1. Intrinsic Semiring-Congruence Radical Equals Ideal-Induced Radical

**Statement:** For an idempotent commutative semiring of functions, the intrinsic
radical of a finitely generated semiring congruence (defined via the lattice of
congruences) agrees with the congruence induced by the tropical radical of the
associated equation ideal.

**Why it matters:** This would show that the "transport through ideals" approach
used in the current formalization is not merely a convenience but a theorem:
the two natural definitions of radical congruence coincide.

**Lean target:**
```lean
theorem intrinsic_radical_eq_ideal_radical
    (R : Finset (A × A)) :
    intrinsicRadicalCongr (SemiringConGen.fromPairs R) =
      congrOfIdeal (tropRadical (idealOfPairs R))
```

## 2. Kernel Congruence of Evaluation Equals Vanishing Congruence

**Statement:** The kernel congruence of the evaluation homomorphism
`ev_V : A → (V → S)` (restricting functions to the solution locus V)
equals the vanishing congruence `I_c(V)`.

**Why it matters:** This is the first isomorphism theorem for tropical
congruence geometry. It identifies the quotient `A / I_c(V)` with the
image of the evaluation map, giving a canonical "coordinate semiring"
for the tropical variety V.

**Lean target:**
```lean
theorem kernel_eval_eq_vanishing
    (V : Set X) :
    RingCon.ker (evalHom V) = vanishingSemiringCon V
```

## 3. Quotient Coordinate Semiring Universal Property

**Statement:** The quotient semiring `A / I_c(V)` satisfies the universal
property: any semiring homomorphism from A that factors through evaluation
on V factors uniquely through the quotient.

**Why it matters:** This is the algebraic foundation for tropical affine
coordinate rings, analogous to the classical `k[X]/I(V) ≅ k[V]`.

## 4. Finite Tropical Elimination for Congruence-Defined Loci

**Statement:** Given finitely many equations in variables (x₁,...,xₙ),
the projection of the solution locus to a subset of variables is again
defined by finitely many congruence equations (tropical elimination theory).

**Why it matters:** This would be a tropical analogue of the classical
elimination theorem and has direct algorithmic applications to model
compression and symbolic simplification of neural network equations.

## 5. Congruence-Level Tropical Tensor-Product Nullstellensatz

**Statement:** For separable bivariate EML maps, the congruence
Nullstellensatz lifts to the tensor product: the radical congruence
of equations in `A ⊗ B` is captured by evaluation on the product
of solution loci.

**Why it matters:** This connects tropical congruence geometry to the
tensor-product universality already established in the EML development,
and opens paths toward tropical moduli spaces and deformation theory.

---

Each of these directions builds directly on the infrastructure in
`TropicalCongruenceNullstellensatz.lean` and would extend the
algebra-geometry dictionary for idempotent semiring geometry.
