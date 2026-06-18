# Future Directions: Circuit Universality and Boolean Clone Theory

## 1. Post-Style Completeness Theorem

### Theorem Statement
Every finite set of boolean gates generates all boolean functions if and only if it is not contained in any of the five maximal clones: the 0-preserving functions, the 1-preserving functions, the monotone functions, the affine functions, or the self-dual functions.

```lean
theorem post_completeness (G : Finset Gate) :
    IsUniversal G ↔
      ¬ SubsetOfClone G ZeroPreserving ∧
      ¬ SubsetOfClone G OnePreserving ∧
      ¬ SubsetOfClone G Monotone ∧
      ¬ SubsetOfClone G Affine ∧
      ¬ SubsetOfClone G SelfDual
```

### Expected Definitions
- `Clone`: a set of boolean operations closed under composition and projections
- `SubsetOfClone G C`: every operation definable by circuits over `G` belongs to clone `C`
- `IsUniversal G`: every boolean function is definable by circuits over `G`
- Predicates for each maximal clone: `ZeroPreserving`, `OnePreserving`, `Monotone`, `Affine`, `SelfDual`

### Proof Strategy
1. **Forward direction (easier):** If `G` escapes all five clones, show it generates NOT and AND (hence NAND), then invoke `nand_universal`. This requires five "escape" lemmas showing how breaking each invariant yields a useful gate.
2. **Backward direction:** Show each maximal clone is closed under composition, projections, and substitution. If `G ⊆ C` for some clone `C`, then `Clone(G) ⊆ C ⊊ AllBoolFun`, so `G` is not universal.

### Cross-Domain Significance
- **Logic:** Mechanizes a cornerstone of finite model theory (Post's lattice).
- **Hardware design:** Gives an automated decision procedure for gate set sufficiency.
- **Complexity theory:** Provides the semantic foundation for circuit complexity lower bounds.

---

## 2. Quantitative Synthesis Bounds

### Theorem Statement
The DNF synthesis produces circuits of size at most exponential in `n`, matching the Lupanov bound for the worst case.

```lean
theorem dnf_size_bound {n : ℕ} (f : BFun n) :
    ∃ c : Circuit n, (∀ σ, Circuit.eval c σ = f σ) ∧
      Circuit.size c ≤ (n + 3) * 2^n

theorem shannon_lower_bound (n : ℕ) (hn : n ≥ 5) :
    ∃ f : BFun n, ∀ c : Circuit n,
      (∀ σ, Circuit.eval c σ = f σ) → Circuit.size c ≥ 2^n / (2 * n)
```

### Expected Definitions
- `Circuit.size`: already defined (number of nodes)
- `Circuit.depth`: already defined
- Counting arguments over `Fintype (BFun n)` and `Circuit n`

### Proof Strategy
1. **Upper bound:** Analyze the DNF construction. Each minterm uses O(n) gates, there are at most 2^n minterms, and the OR-tree adds at most 2^n gates.
2. **Lower bound (Shannon counting):** There are 2^(2^n) boolean functions on n bits. A circuit of size s can be described in O(s log s) bits. If s < 2^n/(2n), the number of describable circuits is less than 2^(2^n), so some function has no small circuit.

### Cross-Domain Significance
- **Complexity theory:** Formalizes the Shannon counting argument, the foundation of circuit complexity.
- **Optimization:** Guides practical circuit minimization by establishing fundamental limits.

---

## 3. Affine and Monotone Separation Theorems

### Theorem Statement
The clone of affine functions and the clone of monotone functions are both proper subsets of all boolean functions, and each is closed under composition.

```lean
theorem affine_closed_under_composition {n m : ℕ}
    (f : BFun n) (gs : Fin n → BFun m)
    (hf : IsAffine f) (hgs : ∀ i, IsAffine (gs i)) :
    IsAffine (fun σ => f (fun i => gs i σ))

theorem monotone_closed_under_composition {n m : ℕ}
    (f : BFun n) (gs : Fin n → BFun m)
    (hf : IsMonotone f) (hgs : ∀ i, IsMonotone (gs i)) :
    IsMonotone (fun σ => f (fun i => gs i σ))

theorem xor_not_universal :
    ¬ ∀ {n : ℕ} (f : BFun n), ∃ c : XorCircuit n, eval c = f
```

### Expected Definitions
- `IsMonotone`: `∀ σ τ, (∀ i, σ i ≤ τ i) → f σ ≤ f τ` (using `Bool` ordering `false < true`)
- `IsAffine`: already defined (XOR-linear plus constant)
- `XorCircuit`: circuit type using only XOR and constants

### Proof Strategy
1. **Affine closure:** Substitution of affine functions into an affine function preserves linearity over GF(2). Direct algebraic computation.
2. **Monotone closure:** If all component functions are monotone and the outer function is monotone, pointwise composition preserves the ordering.
3. **XOR non-universality:** AND is not affine (already proved). Any XOR circuit computes an affine function. Therefore AND cannot be computed by XOR circuits.

### Cross-Domain Significance
- **Additive combinatorics:** Affine functions correspond to structured subsets; non-affine functions have high "complexity energy."
- **Cryptography:** Affine vs. non-linear distinguishers are the basis of linear cryptanalysis.
- **Learning theory:** Affine functions are efficiently learnable; separating them from arbitrary functions underlies hardness of learning.

---

## 4. Categorical Semantics of Circuits

### Theorem Statement
Boolean circuits form a symmetric monoidal category where objects are natural numbers (wire counts), morphisms are circuit families, and composition is circuit substitution. This category is equivalent to the category of finite boolean functions.

```lean
structure CircuitCat : Type where
  obj := ℕ
  hom (n m : ℕ) := Fin m → Circuit n
  id (n : ℕ) : hom n n := fun i => Circuit.input i
  comp {n m k : ℕ} (f : hom m k) (g : hom n m) : hom n k :=
    fun i => Circuit.subst (f i) g

theorem circuit_cat_eval_functorial {n m k : ℕ}
    (f : Fin k → Circuit m) (g : Fin m → Circuit n) (σ : Fin n → Bool) :
    ∀ i, Circuit.eval (CircuitCat.comp f g i) σ =
         Circuit.eval (f i) (fun j => Circuit.eval (g j) σ)
```

### Expected Definitions
- `Circuit.subst`: substitute sub-circuits for input wires
- `CircuitCat`: category structure with composition as substitution
- Functor to `BoolFunCat` (the category of finite-dimensional boolean vector spaces and functions)

### Proof Strategy
1. Define `Circuit.subst` by structural recursion, replacing `input i` with the i-th sub-circuit.
2. Prove `eval_subst` compositionally.
3. Verify associativity and identity laws for `CircuitCat`.
4. Construct the evaluation functor and prove it is faithful and essentially surjective (by universality).

### Cross-Domain Significance
- **Program semantics:** Circuits-as-morphisms is the syntactic side of denotational semantics for hardware.
- **Quantum computing:** Extends naturally to quantum circuits (replacing Bool with complex amplitudes).
- **Operad theory:** Gate libraries form colored operads; universality becomes a statement about operad generation.

---

## 5. Automated Gate Basis Discovery and Certification

### Theorem Statement
For boolean functions up to arity 3, there is a decidable procedure that determines whether a finite gate set is universal, and produces either a NAND circuit from the gates or a proof of non-universality via clone membership.

```lean
def checkUniversal (G : List Gate) : Bool :=
  -- Decision procedure checking all five Post conditions

theorem checkUniversal_correct (G : List Gate) :
    checkUniversal G = true ↔ IsUniversal (G.toFinset)

-- Concrete instances:
theorem nand_is_universal : checkUniversal [nandGate] = true := by native_decide
theorem xor_not_universal : checkUniversal [xorGate] = false := by native_decide
```

### Expected Definitions
- `checkUniversal`: computable decision procedure
- Finite enumeration of all boolean functions up to arity k
- Closure computation for small gate sets

### Proof Strategy
1. Implement clone membership checks for each of the five Post classes as decidable predicates.
2. For small arities (≤ 3), enumerate all 2^(2^k) boolean functions and check invariant preservation.
3. Use `native_decide` or `decide` to verify concrete instances.
4. Prove soundness: the check correctly implements the Post completeness criterion.

### Cross-Domain Significance
- **Hardware CAD:** Direct application to logic synthesis tool verification.
- **Formal methods:** Bridges the gap between decision procedures and mathematical proofs.
- **Education:** Interactive tool for exploring Post's lattice computationally.
