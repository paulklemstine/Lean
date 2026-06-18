# Future Directions: Formal Galois Solvability Theory

## Direction 1: Formal Irreducibility and Galois Group of X⁵ − X − 1

### Precise Theorem Statement
The polynomial X⁵ − X − 1 ∈ ℚ[X] is irreducible over ℚ, and its Galois group is isomorphic to S₅.

### Expected Lean Type Signature
```lean
theorem irreducible_X5_sub_X_sub_one :
    Irreducible (X ^ 5 - X - C (1 : ℚ) : Polynomial ℚ)

theorem galoisGroup_X5_sub_X_sub_one :
    Nonempty ((X ^ 5 - X - C (1 : ℚ) : Polynomial ℚ).Gal ≃* Equiv.Perm (Fin 5))
```

### Proof Strategy
1. **Irreducibility**: Use the rational root theorem (no rational roots since ±1 are not roots) combined with factorization analysis. Alternatively, reduce mod 2 where the polynomial is irreducible (verifiable by exhaustive check over F₂), then apply Hensel-style lifting or direct irreducibility transfer.

2. **Galois group = S₅**: Two-step argument:
   - Show Gal(f) contains a 5-cycle: f is irreducible mod 2, so the Frobenius at 2 is a 5-cycle.
   - Show Gal(f) ⊄ A₅: the discriminant is 2869 = 19 × 151, which is not a perfect square. Formalize the connection between discriminant and the sign character.
   - A transitive subgroup of S₅ containing a 5-cycle and not contained in A₅ must be S₅.

### Dependencies
- Mathlib: `Polynomial.Irreducible`, `Polynomial.Gal`, `Polynomial.roots`, `Finset.card`
- New definitions needed: discriminant of a polynomial (may exist in Mathlib), Frobenius element formalization, connection between factorization mod p and cycle types

### Cross-Domain Connection
**Computational Algebra**: This would enable formally verified factorization of polynomials over ℚ, with applications to certified computer algebra systems that guarantee correctness of irreducibility certificates.

---

## Direction 2: The Converse — Solvable Galois Group Implies Radical Tower

### Precise Theorem Statement
If K ⊆ L is a finite Galois extension and Gal(L/K) is solvable, then (assuming K contains appropriate roots of unity) there exists a tower K = K₀ ⊆ K₁ ⊆ ... ⊆ Kₙ = L where each Kᵢ₊₁ = Kᵢ(αᵢ) with αᵢ^mᵢ ∈ Kᵢ for some mᵢ.

### Expected Lean Type Signature
```lean
theorem radical_tower_of_solvable_galois
    (K L : Type*) [Field K] [Field L] [Algebra K L]
    [FiniteDimensional K L] [IsGalois K L]
    (hsolv : IsSolvable (L ≃ₐ[K] L))
    (hunity : ∀ n : ℕ, ∃ ζ : K, ζ ^ n = 1 ∧ orderOf ζ = n) :
    ∃ n : ℕ, ∃ F : Fin (n+1) → IntermediateField K L,
      F 0 = ⊥ ∧ F (Fin.last n) = ⊤ ∧
      (∀ i : Fin n, F i.castSucc ≤ F i.succ) ∧
      (∀ i : Fin n, ∃ m : ℕ, ∃ α : L,
        α ∈ (F i.succ : Set L) ∧ α ^ m ∈ (F i.castSucc : Set L) ∧
        F i.succ = (F i.castSucc)⟮α⟯)
```

### Proof Strategy
1. Use the derived series D⁰(G) ⊇ D¹(G) ⊇ ... ⊇ Dⁿ(G) = {e}
2. Via the Galois correspondence, convert to intermediate fields: ⊥ = F₀ ⊆ F₁ ⊆ ... ⊆ Fₙ = ⊤
3. Each quotient Dⁱ(G)/Dⁱ⁺¹(G) is abelian
4. By Kummer theory (using the roots of unity hypothesis), abelian extensions with sufficient roots of unity are radical extensions
5. The key lemma is that a cyclic extension of prime degree, when the base contains appropriate roots of unity, is a simple radical extension

### Dependencies
- Mathlib: Galois correspondence, Kummer theory (may need partial formalization), cyclotomic fields
- New definitions: radical extension, radical tower
- Key missing piece: Kummer theory connecting abelian extensions to radical extensions

### Cross-Domain Connection
**Programming Language Theory**: A radical tower is essentially a typed expression language for algebraic numbers. Formalizing this construction amounts to proving that the "radical expression language" is complete for solvable equations — a soundness and completeness theorem for a domain-specific programming language.

---

## Direction 3: Generic Quintic Non-Solvability over Function Fields

### Precise Theorem Statement
The generic quintic X⁵ + t₁X⁴ + t₂X³ + t₃X² + t₄X + t₅ over the function field ℚ(t₁,...,t₅) has Galois group S₅ over ℚ(t₁,...,t₅), and hence is not solvable by radicals.

### Expected Lean Type Signature
```lean
-- Define the generic quintic over the function field
noncomputable def genericQuintic :
    Polynomial (RatFunc (MvPolynomial (Fin 5) ℚ)) :=
  X ^ 5 + C (RatFunc.mk (MvPolynomial.X 0) 1) * X ^ 4 + ...

theorem generic_quintic_galois_group_S5 :
    Nonempty (genericQuintic.Gal ≃* Equiv.Perm (Fin 5))

theorem generic_quintic_not_solvable_by_radicals :
    ¬ ∃ α, Polynomial.aeval α genericQuintic = 0 ∧
      IsSolvableByRad (RatFunc (MvPolynomial (Fin 5) ℚ)) α
```

### Proof Strategy
1. Show the Galois group of the generic polynomial is the full symmetric group by a specialization argument
2. Any proper subgroup of S₅ has a "larger" fixed field, which would impose algebraic relations among the coefficients t₁,...,t₅ — contradicting their algebraic independence
3. Alternatively, use the fact that the generic polynomial's splitting field over ℚ(t₁,...,t₅) is ℚ(x₁,...,x₅) where the tᵢ are elementary symmetric polynomials, and the Galois group acts by permuting the xᵢ

### Dependencies
- Mathlib: `MvPolynomial`, `RatFunc`, symmetric polynomials, transcendence degree
- New definitions: generic polynomial over function field
- Key challenge: working with multivariate polynomial rings and their fraction fields in Lean

### Cross-Domain Connection
**Algebraic Geometry**: The generic quintic lives over the moduli space of degree-5 polynomials. Its Galois group being S₅ means the "generic point" of this moduli space has maximal symmetry — a statement about the geometry of the parameter space of quintic equations.

---

## Direction 4: Resolvent Polynomials and Galois Group Computation

### Precise Theorem Statement
For a polynomial f of degree n, the Galois group can be determined by computing resolvent polynomials and testing their factorization patterns. For degree 5, this gives a complete decision procedure.

### Expected Lean Type Signature
```lean
/-- The sextic resolvent of a quintic polynomial -/
noncomputable def sexticResolvent (f : Polynomial ℚ) : Polynomial ℚ := ...

/-- The Galois group of a quintic is determined by the factorization of its resolvent -/
theorem galoisGroup_quintic_of_resolvent
    (f : Polynomial ℚ)
    (hf : f.natDegree = 5)
    (hf_irred : Irreducible f)
    (hres_irred : Irreducible (sexticResolvent f)) :
    Nonempty (f.Gal ≃* Equiv.Perm (Fin 5)) ∨
    Nonempty (f.Gal ≃* alternatingGroup (Fin 5))
```

### Proof Strategy
1. Define the sextic resolvent: a degree-6 polynomial whose roots are products of pairs of roots of f
2. The factorization pattern of the resolvent determines which subgroup of S₅ the Galois group is:
   - Resolvent irreducible → Gal = S₅ or A₅
   - Resolvent has a linear factor → Gal ⊆ F₂₀ (Frobenius group)
   - etc.
3. Combined with discriminant (square vs. non-square), this distinguishes S₅ from A₅

### Dependencies
- Mathlib: polynomial resultants, symmetric functions
- New definitions: resolvent polynomials, their construction from root products
- Key challenge: formalizing the relationship between resolvent factorization and subgroups of S_n

### Cross-Domain Connection
**Verified Algorithms**: This would yield a formally verified algorithm for computing Galois groups of quintics — the first such verified algorithm. It could be extracted to executable code and used in certified computer algebra.

---

## Direction 5: Inverse Galois Problem for Small Solvable Groups

### Precise Theorem Statement
Every finite solvable group G is the Galois group of some polynomial f ∈ ℚ[X]. More precisely, for specific small groups (cyclic groups, dihedral groups, small symmetric groups), exhibit explicit polynomials realizing them.

### Expected Lean Type Signature
```lean
/-- Every cyclic group is a Galois group over ℚ -/
theorem cyclic_is_galois_group (n : ℕ) (hn : 0 < n) :
    ∃ f : Polynomial ℚ, Nonempty (f.Gal ≃* ZMod n)

/-- The dihedral group D_n is a Galois group over ℚ for odd n -/
theorem dihedral_is_galois_group (n : ℕ) (hn : Odd n) (hn2 : 2 < n) :
    ∃ f : Polynomial ℚ, Nonempty (f.Gal ≃* DihedralGroup n)

/-- S₅ is a Galois group over ℚ (realized by X⁵ - X - 1) -/
theorem S5_is_galois_group :
    ∃ f : Polynomial ℚ, Nonempty (f.Gal ≃* Equiv.Perm (Fin 5))
```

### Proof Strategy
1. **Cyclic groups**: Use cyclotomic polynomials. Φₙ(X) has Galois group (ℤ/nℤ)* over ℚ. For prime n, this is cyclic of order n-1. Construct appropriate subfield extensions.
2. **Dihedral groups**: Use minimal polynomials of cos(2π/n), which generate extensions with dihedral Galois groups.
3. **S₅**: Use X⁵ − X − 1 (conditional on Direction 1).
4. **General solvable groups**: Use Shafarevich's theorem (much harder, probably out of reach).

### Dependencies
- Mathlib: cyclotomic polynomials, `DihedralGroup`, `ZMod`
- Direction 1 as a prerequisite for the S₅ case
- New definitions: explicit polynomial constructions for each group

### Cross-Domain Connection
**Number Theory**: The inverse Galois problem is one of the central open problems in algebraic number theory. Even partial formal results (for specific small groups) would connect to the Langlands program and modern arithmetic geometry. Formalizing explicit realizations creates a database of "certified Galois extensions" usable in computational number theory.
