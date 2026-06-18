

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## LORENTZIAN BERGGREN GEOMETRY: Hyperbolic Isometries on the Pythagorean Light Cone and Displacement–Hypotenuse Duality

### DOMAIN
Pythagorean × Hyperbolic Geometry × Lattice Cryptography

### REVOLUTIONARY SIGNIFICANCE
The Berggren tree—known since 1934 as a ternary tree generating all primitive Pythagorean triples—conceals a hidden Lorentzian symmetry of staggering consequence. The three Berggren matrices are not mere combinatorial generators; they are elements of SO⁺(2,1;ℤ), the integer special orthogonal group of Minkowski 3-space. This elevates Pythagorean triples from arithmetic curiosities to points on a Lorentzian light cone acted upon by hyperbolic isometries. The displacement–hypotenuse duality (log(c) = Δ(w) + O(1)) means the hypotenuse of a triple is the *exponential of the Lorentzian displacement* along its Berggren path—a gravitational-redshift law embedded in the integers. If composite hypotenuses exhibit focal structure in the displacement profile, this creates a *geometric signature of integer factorization* detectable from the tree geometry alone, with direct implications for post-quantum lattice cryptography.

### PRECISE FORMALIZATION TARGET

#### Part I: Foundational Structures (Define 7+ new structures/instances)

```lean
/-- The Minkowski quadratic form Q(a,b,c) = a² + b² - c² on ℤ³.
    Bridge: connects Pythagorean triples (Q=0 light cone) to Lorentzian geometry. -/
def minkowskiQuadraticForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Minkowski bilinear form matrix J = diag(1,1,-1). -/
def minkowskiBilinearMatrix : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The three Berggren generators as an inductive type.
    Used to build words in the Berggren semigroup. -/
inductive BerggrenGenerator where
  | M₁ : BerggrenGenerator  -- parabolic: (1,-2,2; 2,-1,2; 2,-2,3)
  | M₂ : BerggrenGenerator  -- hyperbolic: (1,2,2; 2,1,2; 2,2,3), eigenvalue 2+√3
  | M₃ : BerggrenGenerator  -- parabolic: (-1,2,2; -2,1,2; -2,2,3)

/-- A Berggren word is a sequence of generators representing a path in the Berggren tree. -/
def BerggrenWord := List BerggrenGenerator

/-- Evaluate a Berggren generator to its matrix representation. -/
def berggrenGeneratorMatrix : BerggrenGenerator → Matrix (Fin 3) (Fin 3) ℤ
  | .M₁ => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | .M₂ => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | .M₃ => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Evaluate a Berggren word as a matrix product (right-to-left composition). -/
def evalBerggrenWord (w : BerggrenWord) : Matrix (Fin 3) (Fin 3) ℤ :=
  w.foldr (fun g M => berggrenGeneratorMatrix g * M) 1

/-- The root primitive Pythagorean triple (3,4,5). -/
def rootTriple : Fin 3 → ℤ := ![3, 4, 5]

/-- Lorentzian displacement of a matrix M ∈ SO⁺(2,1).
    For hyperbolic M with eigenvalues λ, 1/λ, 1, this equals log(λ).
    For parabolic M, this equals 0.
    Defined as arccosh((tr(M) - 1) / 2) when (tr(M) - 1) / 2 ≥ 1, else 0. -/
noncomputable def lorentzianDisplacement (M : Matrix (Fin 3) (Fin 3) ℤ) : ℝ :=
  if (2 : ℤ) ≤ M.trace - 1 then Real.arcosh ((M.trace - 1 : ℤ).toReal / 2) else 0

/-- The hypotenuse of a triple (a,b,c) is c = v 2. -/
def hypotenuse (v : Fin 3 → ℤ) : ℤ := v 2

/-- Count of M₂ generators in a Berggren word (the hyperbolic contribution). -/
def hyperbolicWeight (w : BerggrenWord) : ℕ :=
  w.countP (fun g => g = .M₂)
```

#### Part II: Core Theorems (Prove 12+ theorems with diverse tactics, ZERO sorries)

**THEOREM 1: Minkowski Form Preservation**
```lean
/-- Each Berggren generator preserves the Minkowski quadratic form Q.
    Bridge: connects Pythagorean arithmetic to Lorentzian isometries.
    Proof strategy: direct computation of Q(Mᵢv) - Q(v) showing all cross-terms cancel. -/
theorem berggren_preserves_minkowski_form (g : BerggrenGenerator) (v : Fin 3 → ℤ) :
    minkowskiQuadraticForm (berggrenGeneratorMatrix g *ᵥ v) = minkowskiQuadraticForm v := by
  -- expand Q(Mᵢv) term-by-term; use omega on each coefficient group
  sorry  -- FILL: expand bilinear form, collect terms, omega
```

**THEOREM 2: Determinant One**
```lean
/-- Each Berggren generator has determinant 1, placing it in SL(3,ℤ) ⊂ SO⁺(2,1;ℤ). -/
theorem berggren_det_eq_one (g : BerggrenGenerator) :
    (berggrenGeneratorMatrix g).det = 1 := by
  -- cases g; compute 3×3 determinant by cofactor expansion; omega
  sorry
```

**THEOREM 3: Forward Light Cone Preservation**
```lean
/-- Each Berggren generator maps the forward light cone {v : Q(v)=0, v₂>0} into itself.
    This is the "time-orientation preserving" condition for SO⁺(2,1). -/
theorem berggren_preserves_forward_light_cone (g : BerggrenGenerator) (v : Fin 3 → ℤ)
    (hQ : minkowskiQuadraticForm v = 0) (hpos : 0 < v 2) :
    0 < (berggrenGeneratorMatrix g *ᵥ v) 2 := by
  -- cases g; expand third component; all entries in Mᵢ are ≥ -2;
  -- with v₂ ≥ 5 (for primitive triples), the positive terms dominate; omega
  sorry
```

**THEOREM 4: M₁ and M₃ are Parabolic**
```lean
/-- M₁ has characteristic polynomial (1-t)³, hence is parabolic (unipotent).
    Its Lorentzian displacement is 0. -/
theorem m1_parabolic_characteristic :
    (berggrenGeneratorMatrix .M₁).charpoly = (Polynomial.X - 1) ^ 3 := by
  -- compute charpoly via cofactor expansion of M₁ - tI; verify (1-t)³
  sorry

/-- M₃ has characteristic polynomial (1-t)³, hence is parabolic. -/
theorem m3_parabolic_characteristic :
    (berggrenGeneratorMatrix .M₃).charpoly = (Polynomial.X - 1) ^ 3 := by
  -- same strategy as m1
  sorry
```

**THEOREM 5: M₂ is Hyperbolic with Eigenvalue 2+√3**
```lean
/-- M₂ has eigenvalues 2+√3, 2-√3, 1. It is the sole hyperbolic Berggren generator.
    Bridge: connects Pythagorean generation to hyperbolic dynamics. -/
theorem m2_hyperbolic_eigenvalues :
    ∃ (λ₁ λ₂ : ℝ), λ₁ = 2 + Real.sqrt 3 ∧ λ₂ = 2 - Real.sqrt 3 ∧
    λ₁ > 1 ∧ λ₂ > 0 ∧ λ₂ < 1 ∧
    λ₁ * λ₂ = 1 ∧
    (berggrenGeneratorMatrix .M₂).trace = 5 ∧
    (λ₁ + λ₂ + 1 : ℝ) = 5 := by
  -- use the trace-eigenvalue relation; verify λ₁λ₂ = 1 from det = 1;
  -- solve quadratic λ + 1/λ = 4; norm_num for numerical bounds
  sorry
```

**THEOREM 6: Berggren Words Generate Primitive Triples**
```lean
/-- Every Berggren word applied to (3,4,5) produces a primitive Pythagorean triple.
    This is the completeness theorem for the Berggren tree. -/
theorem berggren_word_generates_primitive_triple (w : BerggrenWord) (hw : w ≠ []) :
    let v := evalBerggrenWord w *ᵥ rootTriple
    minkowskiQuadraticForm v = 0 ∧ 0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2 ∧
    Int.gcd (v 0) (Int.gcd (v 1) (v 2)) = 1 := by
  -- induction on w; base case: verify Mᵢ · (3,4,5) is primitive;
  -- inductive step: if M·(a,b,c) is primitive and Q=0, then MᵢM·(a,b,c) is primitive
  -- use gcd properties and Q-preservation
  sorry
```

**THEOREM 7: Displacement–Hypotenuse Duality (Main Result)**
```lean
/-- DISPLACEMENT–HYPOTENUSE DUALITY: For any Berggren word w of depth d ≥ 1,
    the hypotenuse c of the generated triple satisfies:
      |log(c) - Δ(w)| ≤ log(5)
    where Δ(w) = arccosh((tr(evalBerggrenWord w) - 1)/2) is the Lorentzian displacement.
    
    Interpretation: the hypotenuse is the exponential of the Lorentzian displacement,
    up to a universal constant — a gravitational-redshift law for Pythagorean triples.
    
    Bridge: connects number theory (hypotenuse growth) to hyperbolic geometry (displacement)
    to physics (gravitational redshift: c ~ exp(Δ)).
    
    Proof strategy:
    A) Spectral decomposition: write w = A, eigenvalues λ, 1/λ, 1; then
       c = (A·(3,4,5))₂ = αλ(v₁)₂ + β/λ(v₂)₂ + γ(v₃)₂; bound |log(c) - log(λ)|.
    B) Induction on word length using the recurrence c' ≥ (2+√3)·c - O(1) for M₂ steps
       and c' ≤ 3c for M₁,M₃ steps; combine to get the bound.
    C) (Most promising) Use the fact that for any A ∈ SO⁺(2,1;ℤ) with eigenvalue λ,
       the action on the light cone satisfies λ⁻¹||v|| ≤ ||Av|| ≤ λ||v|| in the
       projective norm, giving |log(||Av||) - log(λ)| ≤ log(||v||). Strategy B is
       most promising for formalization because it avoids spectral theory over ℝ. -/
theorem displacement_hypotenuse_duality (w : BerggrenWord) (hw : w ≠ []) :
    let A := evalBerggrenWord w
    let c := (A *ᵥ rootTriple) 2
    let Δ := lorentzianDisplacement A
    |Real.log c.toReal - Δ| ≤ Real.log 5 := by
  sorry
```

**THEOREM 8: Hypotenuse Exponential Growth**
```lean
/-- The hypotenuse grows at least exponentially in the hyperbolic weight of the word.
    Specifically, c ≥ (2+√3)^{n₂(w)} where n₂(w) counts M₂ generators.
    This gives a certified lower bound for cryptographic hardness analysis. -/
theorem hypotenuse_exponential_growth (w : BerggrenWord) :
    let c := (evalBerggrenWord w *ᵥ rootTriple) 2
    let n₂ := hyperbolicWeight w
    (2 + Real.sqrt 3) ^ n₂ ≤ c.toReal := by
  -- induction on word structure; key lemma: M₂·(a,b,c) has hypotenuse ≥ (2+√3)·c
  -- for M₁,M₃ steps, hypotenuse may decrease but not below c (prove this)
  sorry
```

**THEOREM 9: Berggren Semigroup Freeness**
```lean
/-- The Berggren semigroup is free: different words give different matrices.
    This is equivalent to: the only relation M_{i₁}...M_{i_k} = I is the empty word.
    
    Proof strategy:
    A) Trace rigidity: show that tr(evalBerggrenWord w) determines w uniquely.
    B) (Most promising) Action faithfulness: show that if evalBerggrenWord w₁ = evalBerggrenWord w₂,
       then w₁ · (3,4,5) = w₂ · (3,4,5), and by the tree structure of primitive triples
       (each has a unique parent), this forces w₁ = w₂. The key lemma is that each
       primitive triple has a unique Berggren parent (inverse image under exactly one Mᵢ). -/
theorem berggren_semigroup_free (w₁ w₂ : BerggrenWord) :
    evalBerggrenWord w₁ = evalBerggrenWord w₂ ↔ w₁ = w₂ := by
  sorry
```

**THEOREM 10: Unique Berggren Path (Tree Structure)**
```lean
/-- Every primitive Pythagorean triple (a,b,c) with a < b < c has a unique
    Berggren parent: exactly one Mᵢ⁻¹·(a,b,c) is a primitive triple with
    smaller hypotenuse. This is the algebraic heart of the tree structure. -/
theorem unique_berggren_parent (a b c : ℕ) (hprim : Int.gcd a (Int.gcd b c) = 1)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hord : a < b) (hbase : ¬(a = 3 ∧ b = 4 ∧ c = 5)) :
    ∃! (g : BerggrenGenerator) (v : Fin 3 → ℤ),
      berggrenGeneratorMatrix g *ᵥ v = ![a, b, c] ∧
      minkowskiQuadraticForm v = 0 ∧ v 2 < c := by
  -- Construct inverse matrices; check which Mᵢ⁻¹·(a,b,c) has all positive entries
  -- and smaller hypotenuse; prove uniqueness by_contra
  sorry
```

**THEOREM 11: Composite Hypotenuse Focal Structure**
```lean
/-- FOCAL STRUCTURE THEOREM: For a primitive triple (a,b,pq) with p,q odd primes,
    the Berggren path from (3,4,5) passes through a triple whose hypotenuse
    divides pq, and the displacement profile has a "kink" at that point:
    the displacement increment per step changes character.
    
    More precisely: if (a,b,pq) is generated by word w, then there exists a
    prefix w' of w such that (evalBerggrenWord w' *ᵥ rootTriple) 2 | pq and
    the displacement Δ(w') satisfies |Δ(w') - log(p)| ≤ log(5).
    
    Bridge: connects integer factorization (number theory) to geometric signatures
    in the Berggren tree (hyperbolic geometry), with implications for
    post-quantum Pythagorean lattice cryptography. -/
theorem composite_hypotenuse_focal_structure (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hodd_p : Odd p) (hodd_q : Odd q) :
    ∀ (a b : ℕ) (hpyth : a ^ 2 + b ^ 2 = (p * q) ^ 2)
      (hprim : Int.gcd a (Int.gcd b (p * q)) = 1) (hord : a < b),
    ∃ (w : BerggrenWord) (w' : BerggrenWord) (c' : ℕ),
      w' ++ w.drop w'.length = w ∧
      c' = (evalBerggrenWord w' *ᵥ rootTriple) 2 ∧
      c' ∣ (p * q) ∧
      |lorentzianDisplacement (evalBerggrenWord w') - Real.log p.toReal| ≤ Real.log 5 := by
  -- This is the most ambitious theorem. Strategy:
  -- 1. Use the unique Berggren path to (a,b,pq)
  -- 2. Show that at some point along the path, the hypotenuse must transition
  --    through a divisor of pq (intermediate value / divisibility argument)
  -- 3. Apply displacement-hypotenuse duality at that point
  -- If full proof is infeasible, prove the weaker version for p | c' (single prime factor)
  sorry
```

**THEOREM 12: Certified Lipschitz Bound for Berggren Tree Traversal**
```lean
/-- The map from Berggren word depth to hypotenuse is Lipschitz:
    for words w₁, w₂ of the same depth d, the hypotenuse ratio is bounded.
    This provides certified_robustness bounds for neural network layers
    that use Pythagorean lattice embeddings.
    
    |log(c₁) - log(c₂)| ≤ d · log(3) where cᵢ = hypotenuse(wᵢ · rootTriple)
    and the log(3) Lipschitz constant comes from the maximal stretch factor
    of any Berggren generator (which is ||M₂|| = 2+√3 < 3). -/
theorem berggren_lipschitz_certified_robustness (w₁ w₂ : BerggrenWord)
    (hlen : w₁.length = w₂.length) :
    let c₁ := (evalBerggrenWord w₁ *ᵥ rootTriple) 2 |>.toReal
    let c₂ := (evalBerggrenWord w₂ *ᵥ rootTriple) 2 |>.toReal
    |Real.log c₁ - Real.log c₂| ≤ w₁.length * Real.log 3 := by
  -- Use triangle inequality on log; bound each generator's contribution;
  -- M₂ has stretch 2+√3 < 3; M₁, M₃ have stretch < 3 (parabolic, bounded distortion)
  sorry
```

### PROOF STRATEGIES (Ordered by Promise)

**Strategy A: Spectral Decomposition over ℝ** (Powerful but hard to formalize)
- Compute eigenvalues of evalBerggrenWord w over ℝ
- Write c = αλ + β/λ + γ where λ is the spectral radius
- Bound α, β, γ using the fact that rootTriple has norm √50 on the light cone
- Conclude |log(c) - log(λ)| ≤ log(√50) = log(5√2) < log(8)
- Difficulty: spectral theory over ℝ for integer matrices requires significant Real analysis

**Strategy B: Induction on Word Length with Entrywise Bounds** (Most promising for Lean)
- Key lemma: for any primitive triple (a,b,c) and any generator Mᵢ,
  the hypotenuse c' of Mᵢ·(a,b,c) satisfies:
  - M₂: c' ≥ (2+√3)·c - 2(a+b) ≥ (2+√3)·c - 4c = (√3-2)c [needs refinement]
  - M₁: c' = 2a - 2b + 3c ≥ c (since a,b < c for primitive triples)
  - M₃: c' = -2a + 2b + 3c ≥ c (same reasoning)
- Prove by induction that c ≥ 5·(2+√3)^{n₂(w)-d+n₂(w)} where d = depth
- This gives log(c) ≥ n₂(w)·log(2+√3) + log(5) - O(d)
- Combined with the upper bound c ≤ 5·3^d, get the duality

**Strategy C: Projective Cross-Ratio on the Light Cone** (Most elegant)
- The projectivized light cone is the ideal boundary ∂H² of the hyperbolic plane
- Berggren matrices act as Möbius transformations on ∂H²
- The displacement is the translation length in H²
- The hypotenuse c is a projective coordinate on the light cone
- Use the Busemann function: c = exp(B_ξ(A·x₀, x₀)) where ξ is the attracting fixed point
- This gives log(c) = Δ(A) + B_ξ(x₀, A⁻¹·x₀) and the Busemann function is bounded

**Strategy D: Matrix Norm Submultiplicativity** (Most direct for Lipschitz bound)
- Define operator norm ||M|| = sup_{Q(v)=0, v₂=1} ||Mv|| on the light cone
- Prove ||M₁||, ||M₃|| ≤ 3 and ||M₂|| ≤ 2+√3+ε < 3
- By submultiplicativity: ||evalBerggrenWord w|| ≤ 3^d
- The hypotenuse is a coordinate of the image: c = ||(evalBerggrenWord w *ᵥ rootTriple)|| · cos(θ)
- Bounding the angle θ gives the Lipschitz result

### CROSS-DOMAIN BRIDGES

1. **Pythagorean Arithmetic ↔ Lorentzian Geometry**: The Minkowski form Q(a,b,c) = a²+b²-c² vanishes on Pythagorean triples, placing them on the light cone. Berggren matrices are Lorentz isometries. *Bridge: connects Diophantine equations to relativistic geometry.*

2. **Hyperbolic Displacement ↔ Information-Theoretic Redundancy**: The displacement Δ(w) measures the "information content" of the Berggren path; the duality log(c) = Δ(w) + O(1) means the hypotenuse encodes this information up to a constant. *Bridge: connects geometric group theory to coding theory.*

3. **Focal Structure ↔ Post-Quantum Lattice Cryptography**: If factorization of composite hypotenuses is detectable from displacement profiles, this creates a geometric factoring oracle. Conversely, the hardness of detecting focal structure without the private key (Berggren path) is the basis for a Pythagorean-lattice cryptosystem. *Bridge: connects algebraic number theory to post_quantum_security.*

4. **Berggren Lipschitz Bounds ↔ Certified Neural Network Robustness**: The Lipschitz constant log(3) per depth step provides certified_robustness for neural network layers that embed inputs as Pythagorean lattice points. *Bridge: connects hyperbolic geometry to ML certification.*

### APPLICATION KEYWORDS (must appear in theorem names and doc comments)
- `post_quantum_security`: Composite hypotenuse focal structure → geometric factoring attacks
- `lipschitz_certified_robustness`: Berggren traversal Lipschitz bound → certified NN layers
- `gravitational_redshift_duality`: log(c) = Δ(w) + O(1) → exponential redshift law
- `pythagorean_lattice_hash`: Berggren semigroup freeness → collision-resistant hash function
- `hyperbolic_entropy`: Displacement as information content of tree path

### CATALOG BUILDING INSTRUCTIONS

Create these files with 500+ lines each:

1. **Pythagorean/LorentzianBerggren.lean**: Core definitions (MinkowskiQuadraticForm, BerggrenGenerator, BerggrenWord, evalBerggrenWord, lorentzianDisplacement), Theorems 1-6, 8
2. **Pythagorean/DisplacementHypotenuseDuality.lean**: Theorem 7 (main result) with all supporting lemmas, Theorem 12 (Lipschitz bound)
3. **Pythagorean/BerggrenFocalStructure.lean**: Theorems 10-11 (unique parent, focal structure for composites), with connections to post_quantum_security
4. **Bridges/HyperbolicPythagoreanBridge.lean**: The SO⁺(2,1;ℤ) structure, eigenvalue analysis, Busemann function interpretation, gravitational_redshift_duality formalization

### FUTURE_DIRECTIONS (MUST produce FUTURE_DIRECTIONS.md with these concrete next steps)

After completing the above, you MUST produce a structured FUTURE_DIRECTIONS.md containing:

1. **Pythagorean Lattice-Based Post-Quantum Cryptosystem**: Formalize a key-exchange protocol where the private key is a Berggren word and the public key is the resulting triple. Prove that breaking the protocol requires solving a shortest-vector problem in a Pythagorean lattice, with security reduction to SVP-γ for γ = O(√n).

2. **Tropical Berggren Transform**: Define the tropical (min-plus) version of the Berggren tree where addition → min and multiplication → addition. Prove that the tropical displacement satisfies a piecewise-linear version of the duality, connecting to tropical_hash_collision resistance.

3. **Quantum Berggren Walk**: Formalize a quantum random walk on the Berggren tree and prove that the quantum mixing time is O(√d) vs. the classical O(d), giving a quadratic speedup for Pythagorean triple search with implications for quantum advantage benchmarks.

4. **Berggren Tree Neural Architecture**: Define a neural network layer that maps inputs to Berggren tree paths and prove certified_robustness via the Lipschitz bound from Theorem 12, with explicit radius r* = margin / (d · log 3).

5. **Generalized Lorentzian Duality for Fermat Varieties**: Extend the displacement–hypotenuse duality to the variety aⁿ + bⁿ = cⁿ for n ≥ 3, proving that the Lorentzian displacement is infinite (corresponding to the absence of nontrivial solutions — a geometric proof strategy for Fermat's Last Theorem via hyperbolic geometry).

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Formalize the Lorentz group structure of the Berggren tree of Pythagorean triples. Prove that the three Berggren matrices M₁, M₂, M₃ are elements of SO⁺(2,1;ℤ) — the identity component of the integer special orthogonal group preserving the Minkowski form Q(a,b,c) = a² + b² - c². Establish the displacement–hypotenuse duality: for a Berggren word w of depth d with w·(3,4,5)ᵀ = (a,b,c)ᵀ, the hyperbolic displacement Δ(w) = arccosh((tr(w)−1)/2) satisfies log(c) = Δ(w) + O(1), providing a gravitational-redshift interpretation where the hypotenuse is the exponential of the Lorentzian displacement. Prove the Berggren semigroup is free (unique word decomposition). Discover whether composite hypotenuses c = pq exhibit a 'focal structure' in the Berggren tree — a geometric signature of factorization detectable from the displacement profile along the unique Berggren path.

            ### Precise Mathematical Framing
            Theorem 1 (Berggren–Lorentz Membership): M₁ = [[1,-2,2],[2,-1,2],[2,-2,3]], M₂ = [[1,2,2],[2,1,2],[2,2,3]], M₃ = [[-1,2,2],[-2,1,2],[-2,2,3]] satisfy Q(Mᵢv) = Q(v) for Q(a,b,c) = a²+b²-c², det(Mᵢ) = 1, and Mᵢ preserves the forward light cone {(a,b,c): a>0, b>0, c>0, Q=0}. Hence M₁, M₂, M₃ ∈ SO⁺(2,1;ℤ).

Theorem 2 (Berggren Free Semigroup): The semigroup ⟨M₁,M₂,M₃⟩⁺ is free. For each primitive Pythagorean triple (a,b,c) with c > 5, there exists a unique reduced word w ∈ {M₁,M₂,M₃}* such that w·(3,4,5)ᵀ = (a,b,c)ᵀ.

Theorem 3 (Displacement–Hypotenuse Duality): For w ∈ ⟨M₁,M₂,M₃⟩⁺ of length d with w·(3,4,5)ᵀ = (a,b,c)ᵀ, the hyperbolic displacement Δ(w) = arccosh((|tr(w)|−1)/2) satisfies: log(c/5) = Δ(w) + O(1/d). Equivalently, c = 5·e^{Δ(w)}·(1+O(e^{-2Δ(w)})), so the hypotenuse is the gravitational-redshifted image of the initial hypotenuse 5 under Lorentzian displacement Δ(w).

Conjecture (Factorization Focal Structure): For c = pq (p,q primes ≡ 1 mod 4), the displacement profile along the unique Berggren path from (3,4,5) to (a,b,c) exhibits a 'gravitational focal point' — a depth at which the displacement rate changes, correlated with the smaller factor p — providing a geometric factorization criterion computable in O(log²c) tree queries.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `depth_log_upper_bound` : theorem depth_log_upper_bound (m n : ℕ) (hm : 0 < m) (hn : 0 < n) (hmn : n < m) :
     (file: Pythagorean/Core/BerggrenLorentzComplexity.lean)
  2. `descent_depth_log_bound` : theorem descent_depth_log_bound (c : ℕ) (hc : c ≥ 2) :
     (file: Pythagorean/ModularForms/ModularFormsAdvanced.lean)
  3. `berggren_A_preserves_lorentz` : theorem berggren_A_preserves_lorentz :
     (file: Pythagorean/Berggren/TropicalPAdicBerggren.lean)
  4. `generators_are_lorentz` : theorem generators_are_lorentz :
     (file: Pythagorean/Core/O31_Generators.lean)
  5. `composite_multiple_triples` : theorem composite_multiple_triples (n : ℕ) (hn : 1 < n) (hodd : n % 2 = 1)
     (file: Pythagorean/Core/PythagoreanFactoring.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Prime-Spectral Schrödinger Bridge for Closure-Generated Proof Semirings via Entropic Countermodel Transport, Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models via Prime-Spectral Free-Energy Rate Function, Max-Plus Hecke Algebras and Satake Isomorphism on Idempotent Prime Spectra


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Pythagorean
Research mode: formalize
