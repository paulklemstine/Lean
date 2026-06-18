# Future Directions: Explicit Class Field Theory Framework

## Conjecture 1: Cycle Type Signatures Distinguish Finite Abelian Groups

**Precise statement.** For any two non-isomorphic finite abelian groups G and H of the same order, the multiset of cycle types of their regular permutation representations are distinct.

Formally: if G ≇ H, then the Counter `{cycle_type(ρ_G(g)) : g ∈ G, g ≠ 1}` differs from `{cycle_type(ρ_H(h)) : h ∈ H, h ≠ 1}`.

**Test.** Enumerate all pairs of non-isomorphic abelian groups up to order N and compare cycle type signatures. Our current computation confirms the conjecture for N ≤ 30 (all 11 orders with multiple abelian groups). Extending to N ≤ 1000 would provide strong computational evidence. A counterexample immediately disproves the conjecture.

**Impact.** If true, this provides a purely combinatorial invariant that classifies abelian groups — a representation-theoretic fingerprint computable in O(n²) time. This would give a practical algorithm for distinguishing class groups of number fields without computing their full structure.

## Conjecture 2: Extension from Finite Class Actions to Ray Class Data

**Precise statement.** The `ExplicitClassFieldDatum` structure can be extended with a modulus (a formal product of primes) to model ray class groups, and the collapse theorem generalizes: if the ray class group modulo m is trivial, then every abelian extension of conductor dividing m is trivial.

Formally: define `RayClassFieldDatum R m` extending `ExplicitClassFieldDatum R` with conductor data, and prove:
```
theorem ray_class_collapse (D : RayClassFieldDatum R m) [Subsingleton D.Cl] :
    -- the associated extension is trivial
```

**Test.** Implement `RayClassFieldDatum` in Lean 4 and verify that it specializes correctly for known examples: (a) ℚ with modulus m should recover the cyclotomic field ℚ(ζ_m); (b) imaginary quadratic fields with trivial ray class group should yield no new extensions.

**Impact.** This would extend the framework from class fields to *ray* class fields, covering the full abelian class field theory. It is the essential next step toward formalizing the Artin reciprocity map.

## Conjecture 3: Faithful Representations Lift to Linear Representations

**Precise statement.** For any finite abelian group G (modeling a class group), the faithful permutation representation ρ : G →* Equiv.Perm G decomposes over ℂ into a direct sum of one-dimensional representations (characters), and the multiplicity of each character equals 1.

Formally:
```
theorem regular_rep_decomposition (G : Type*) [CommGroup G] [Fintype G] :
    ∃ (chars : Finset (G →* ℂˣ)),
      chars.card = Fintype.card G ∧
      -- the regular representation decomposes as ⊕ χ over chars
```

**Test.** For small abelian groups (Z/n, Z/2 × Z/2, Z/2 × Z/4), compute the character table and verify that the regular representation decomposes with multiplicity one. The standard theory (Maschke's theorem + Schur's lemma for abelian groups) guarantees this, but the formalization would create the first mechanized link between class field data and character theory.

**Impact.** This connects the framework directly to the Langlands program: abelian class field theory should produce one-dimensional Galois representations (characters), and this conjecture/theorem would formalize that production pipeline. It bridges Hilbert 12 and Langlands in a machine-checkable way.

## Conjecture 4: Class Group Structure from Fixed-Point Statistics

**Precise statement.** The isomorphism type of a finite abelian group G is uniquely determined by the function `f(g) = |Fix(ρ(g))|` — the number of fixed points of each element's regular permutation.

Note: for the regular representation, `f(g) = |G|` if `g = 1` and `f(g) = 0` otherwise. So this conjecture is trivially true for the regular representation itself. The non-trivial version asks: for *any* faithful representation ρ (not just the regular one), does the fixed-point function determine G?

**Test.** For each abelian group of order ≤ 50, enumerate all faithful representations (not just the regular one) and compute fixed-point statistics. Check whether any two non-isomorphic groups share the same fixed-point function for some pair of faithful representations.

**Impact.** If true, this would provide a representation-theoretic "fingerprint" for class groups that could be computed from Galois-theoretic data (counting fixed points of Frobenius elements), connecting the framework to the Čebotarev density theorem.

## Conjecture 5: Orbit Stabilizer Duality for Class Data

**Precise statement.** For the regular representation of a finite group G on itself, every orbit has size exactly |G| (i.e., the action is free and transitive), and consequently the stabilizer of every point is trivial.

Formally:
```
theorem regular_action_free (G : Type*) [Group G] [Fintype G] (x : G) :
    (permOrbit (MulAction.toPermHom G G) x).card = Fintype.card G
```

This is stronger than our current `orbit_card_le_classGroup_card` (which gives ≤) and `permOrbit_one_eq_univ` (which handles x = 1).

**Test.** Verify computationally for all groups of order ≤ 100. Then attempt formal proof — the key step is showing that the map `g ↦ g * x` is injective (since right multiplication by x is a bijection in a group).

**Impact.** Combined with the faithfulness theorem, this gives the precise arithmetic identity `[H(K) : K] = h(K)` (the degree of the Hilbert class field equals the class number), which is one of the central theorems of class field theory. Formalizing this equality (rather than just the inequality) would be a significant milestone.
