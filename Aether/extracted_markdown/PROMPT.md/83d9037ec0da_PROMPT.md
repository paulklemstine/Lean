

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

## Berggren–Tropical Correspondence: Max-Plus Lorentz Group and Tropical Light Cone Geometry

### I. Revolutionary Significance

The classical Berggren matrices generate the complete tree of primitive Pythagorean triples via hyperbolic isometries of the Minkowski form x² + y² − z². This brief demands the formalization of a deep correspondence: these matrices tropicalize to max-plus linear maps preserving the **tropical light cone** L_trop = {v : max(v₁, v₂) = v₃}, yielding a **tropical Lorentz group** O_trop(2,1) and a tropical Pythagorean tree with max-plus convex structure. This opens three frontiers simultaneously:

- **Quantum Mechanics**: The Maslov dequantization parameter h → 0 bridges classical Pythagorean geometry to the tropical setting, mirroring the ℏ → 0 limit in quantum mechanics. The tropical light cone is the idempotent shadow of the relativistic light cone.
- **Post-Quantum Cryptography**: Tropical matrix problems underpin hard tropical CSP instances; the tropical Berggren tree provides a structured lattice inside L_trop with potential for tropical hash functions with provable collision resistance.
- **Certified Robustness**: The max-plus convexity of L_trop yields Lipschitz-certified decision boundaries for tropical neural networks, with explicit robustness radii.

### II. Core Definitions — Novel Typeclasses and Structures

```lean
/-- The tropical light cone: tropicalization of the Minkowski null cone.
    Points satisfy max(v₁, v₂) = v₃, the idempotent shadow of a² + b² = c².
    Bridge: connects Pythagorean number theory to relativistic physics via Maslov dequantization. -/
def TropicalLightCone : Set (Tropical ℝ × Tropical ℝ × Tropical ℝ) :=
  fun (v₁, v₂, v₃) => max v₁ v₂ = v₃ ∧ v₃ ≠ ⊥

/-- The tropical Lorentz group: max-plus linear automorphisms preserving L_trop.
    This is the idempotent deformation of O(2,1), the usual Lorentz group.
    Bridge: connects idempotent mathematics to relativistic symmetry. -/
structure TropicalLorentzGroup where
  M : Fin 3 → Fin 3 → Tropical ℝ
  preserves_cone : ∀ v ∈ TropicalLightCone, tropicalMatrixVecMul M v ∈ TropicalLightCone
  invertible : ∃ N, ∀ v, tropicalMatrixVecMul N (tropicalMatrixVecMul M v) = v

/-- The three tropical Berggren matrices: tropicalizations of the classical Berggren generators.
    Each is a max-plus linear map in O_trop(2,1).
    The entries are log|Aᵢ[j,k]| where Aᵢ are the classical Berggren matrices. -/
def tropicalBerggrenMatrix (i : Fin 3) : Fin 3 → Fin 3 → Tropical ℝ :=
  match i with
  | 0 => fun j k => match j, k with
    | 0, 0 => 0    | 0, 1 => ⊤(log 2) | 0, 2 => ⊤(log 2)
    | 1, 0 => ⊤(log 2) | 1, 1 => 0      | 1, 2 => ⊤(log 2)
    | 2, 0 => ⊤(log 2) | 2, 1 => ⊤(log 2) | 2, 2 => ⊤(log 3)
  | 1 => fun j k => match j, k with  -- identical absolute values
    | 0, 0 => 0    | 0, 1 => ⊤(log 2) | 0, 2 => ⊤(log 2)
    | 1, 0 => ⊤(log 2) | 1, 1 => 0      | 1, 2 => ⊤(log 2)
    | 2, 0 => ⊤(log 2) | 2, 1 => ⊤(log 2) | 2, 2 => ⊤(log 3)
  | 2 => fun j k => match j, k with  -- identical absolute values
    | 0, 0 => 0    | 0, 1 => ⊤(log 2) | 0, 2 => ⊤(log 2)
    | 1, 0 => ⊤(log 2) | 1, 1 => 0      | 1, 2 => ⊤(log 2)
    | 2, 0 => ⊤(log 2) | 2, 1 => ⊤(log 2) | 2, 2 => ⊤(log 3)

/-- The signed tropical Berggren action: tracks sign changes from negative matrix entries.
    Uses SignTropical = {neg, zero, pos} × Tropical ℝ to represent signed tropical numbers.
    Bridge: connects tropical geometry to real tropicalization and amoeba theory. -/
inductive SignTropical where
  | mk : Sign → Tropical ℝ → SignTropical

/-- The tropical Berggren tree: orbit of (log 3, log 4, log 5) under signed tropical Berggren actions.
    Each node records which Berggren matrix was applied, recovering the full tree structure. -/
inductive TropicalBerggrenTree : (SignTropical × SignTropical × SignTropical) → Prop
  | root : TropicalBerggrenTree (SignTropical.mk pos (Tropical.mk 3),
                                  SignTropical.mk pos (Tropical.mk 4),
                                  SignTropical.mk pos (Tropical.mk 5))
  | step : ∀ i v hv, TropicalBerggrenTree v →
      TropicalBerggrenTree (signedTropicalBerggrenAction i v hv)

/-- Maslov dequantization functor: the continuous deformation from classical to tropical geometry.
    For parameter h > 0, define x ⊕_h y = h · log(exp(x/h) + exp(y/h)).
    As h → 0⁺, this converges to max(x, y).
    Bridge: connects quantum mechanics (ℏ → 0 limit) to idempotent mathematics. -/
def maslovDequantization (h : ℝ) (x y : ℝ) : ℝ := h * log (exp (x/h) + exp (y/h))

/-- Certified tropical robustness radius: for a point v ∈ L_trop, the maximal ε such that
    the tropical ε-ball around v is contained in L_trop.
    Bridge: connects tropical geometry to certified robustness in ML. -/
def tropicalCertifiedRadius (v : Tropical ℝ × Tropical ℝ × Tropical ℝ) : ℝ :=
  sSup {ε : ℝ | ∀ w, tropicalDist v w < ε → w ∈ TropicalLightCone}
```

### III. Theorems — Precise Statements with Proof Strategies

**Theorem 1: Tropical Light Cone is Max-Plus Convex Cone**

```lean
/-- L_trop is closed under max-plus convex combinations.
    If max(v₁,w₂) = v₃ and max(w₁,w₂) = w₃, then for all a, b ∈ ℝ≥0,
    max(a+v₁, b+w₁) ≤ max(a+v₃, b+w₃) and max(a+v₂, b+w₂) ≤ max(a+v₃, b+w₃).
    Equality holds when a = b (tropical scalar multiplication).
    Proof: Case analysis on max(v₁,v₂) and max(w₁,w₂). Four cases total.
    Key lemma: max(max(a+x₁, b+y₁), max(a+x₂, b+y₂)) = max(a+max(x₁,x₂), b+max(y₁,y₂)). -/
theorem tropical_light_cone_max_plus_convex :
  ∀ (v w : Tropical ℝ × Tropical ℝ × Tropical ℝ)
    (hv : v ∈ TropicalLightCone) (hw : w ∈ TropicalLightCone)
    (a b : Tropical ℝ),
    (a ⊗ v ⊕ b ⊗ w) ∈ TropicalLightCone
```

**Strategy A**: Direct case analysis on which coordinate achieves max(v₁,v₂) and max(w₁,w₂). Four cases: (v₁ ≥ v₂, w₁ ≥ w₂), (v₁ ≥ v₂, w₂ ≥ w₁), (v₂ ≥ v₁, w₁ ≥ w₂), (v₂ ≥ v₁, w₂ ≥ w₁). In each case, verify the max-plus convex combination satisfies max = third coordinate.

**Strategy B**: Prove the key distributivity lemma `max(a + max(x₁, x₂), b + max(y₁, y₂)) = max(max(a + x₁, b + y₁), max(a + x₂, b + y₂))` first, then deduce cone preservation as a corollary. This factorization is cleaner and reusable.

**Strategy C**: Embed L_trop as the tropical variety of the tropical polynomial max(2X, 2Y, 2Z) (where Z carries sign −1), then use general theory of tropical varieties under tropical linear maps.

*Strategy B is most promising*: the distributivity lemma is a fundamental max-plus algebra fact that enables modular proof.

---

**Theorem 2: Tropical Berggren Matrices Preserve the Light Cone**

```lean
/-- Each tropical Berggren matrix is in O_trop(2,1): it preserves L_trop.
    This is the tropical shadow of the classical fact that Berggren matrices preserve x²+y²−z².
    Proof: For each i ∈ Fin 3, compute M_i ⊗ v and verify max((M⊗v)₁, (M⊗v)₂) = (M⊗v)₃
    for v ∈ L_trop. The computation uses the specific entries of tropicalBerggrenMatrix. -/
theorem tropical_berggren_preserves_light_cone :
  ∀ (i : Fin 3) (v : Tropical ℝ × Tropical ℝ × Tropical ℝ),
    v ∈ TropicalLightCone →
    tropicalMatrixVecMul (tropicalBerggrenMatrix i) v ∈ TropicalLightCone
```

**Strategy A**: Direct computation. Expand (M ⊗ v)ⱼ = maxₖ(M[j,k] + vₖ) for each row j. Use the fact that all three tropical Berggren matrices have the same absolute-value entries (they differ only in signs, which are tracked by SignTropical). Verify the cone condition by case analysis on max(v₁, v₂).

**Strategy B**: Prove a general lemma that any max-plus matrix M with M[j,3] ≥ M[j,k] for all j,k (the third column dominates) preserves L_trop. Then verify this dominance condition for the tropical Berggren matrices. This generalizes the result.

*Strategy B is most promising*: it identifies the structural reason (column dominance) and generalizes beyond Berggren matrices.

---

**Theorem 3: Berggren–Tropical Duality (Approximate Intertwining)**

```lean
/-- The tropicalization map intertwines classical and tropical Berggren action
    up to bounded error O(log 3).
    For all primitive Pythagorean triples (a,b,c) and all Berggren matrices Aᵢ:
    |log(Aᵢ · (a,b,c)ᵀ)ⱼ − maxₖ(log|Aᵢ[j,k]| + log(a,b,c)ₖ)| ≤ log 3
    Proof: Each entry of Aᵢ · v is a sum of 3 terms. The tropical max selects the dominant term.
    The error is bounded by log(3) since |Σ terms| ≤ 3 · max|term| implies log|Σ| ≤ log(3) + log|max term|.
    Bridge: connects classical Pythagorean number theory to tropical algebraic geometry. -/
theorem berggren_tropical_duality_approx :
  ∀ (i : Fin 3) (a b c : ℕ) (hPyth : a^2 + b^2 = c^2) (hPrim : Nat.gcd a (Nat.gcd b c) = 1),
    ∀ (j : Fin 3),
      let v := (a, b, c)
      let result := berggrenAction i v
      let tropResult := (Tropical.mk result.1, Tropical.mk result.2.1, Tropical.mk result.2.2)
      let tropComputed := tropicalMatrixVecMul (tropicalBerggrenMatrix i)
        (Tropical.mk a, Tropical.mk b, Tropical.mk c)
      |(tropResult j).val - (tropComputed j).val| ≤ log 3
```

**Strategy A**: Expand the matrix-vector product Aᵢ · v explicitly. For each row, identify the dominant term (largest absolute value contribution). Bound the difference between the sum and the dominant term by factoring out the dominant term: |Σₖ A[j,k]vₖ − maxₖ(A[j,k]vₖ)| ≤ Σ_{k≠k*} |A[j,k]|vₖ ≤ 2 · maxₖ|A[j,k]|vₖ. Take logs to get the bound log 3.

**Strategy B**: Use the Maslov dequantization framework. Define the deformed product v ↦_h Aᵢ · v using maslovDequantization. Prove that as h → 0⁺, the deformed product converges to the tropical product. The convergence rate is O(h · log 3) by the Maslov-Sharp asymptotic formula.

**Strategy C**: Prove a stronger result for *asymptotically large* triples. For triples with hypotenuse c ≥ N, the error is O(log 3 · log c / c), which vanishes as c → ∞. This gives an asymptotic duality theorem.

*Strategy A is most direct and complete; Strategy C gives a stronger asymptotic result worth proving as a separate corollary.*

---

**Theorem 4: Tropical Lorentz Group is a Group**

```lean
/-- The tropical Lorentz group O_trop(2,1) forms a group under max-plus matrix multiplication.
    The identity is the tropical identity matrix I_trop = δᵢⱼ (Kronecker delta in tropical semiring).
    Inverses exist for cone-preserving maps by the tropical Cramer rule.
    Bridge: connects group theory to idempotent linear algebra. -/
theorem tropical_lorentz_group_is_group :
  IsGroup (TropicalLorentzGroup) (tropicalMatrixMul) where
  -- Key sub-lemma: tropical Cramer rule gives inverses
  -- For M ∈ O_trop(2,1), the tropical adjugate M^∨ satisfies M ⊗ M^∨ = I_trop
```

**Strategy A**: Construct the inverse explicitly using the tropical adjugate. For a 3×3 tropical matrix M, the tropical adjugate is defined via tropical determinants of 2×2 minors. Prove that if M preserves L_trop, then M ⊗ M^∨ = I_trop on L_trop.

**Strategy B**: Prove that O_trop(2,1) is isomorphic to a semidirect product of (Tropical ℝ, +) with the tropical symmetric group on 2 elements. The cone condition forces a specific block structure on M.

*Strategy B is most promising*: it gives a complete structural description and makes the group properties transparent.

---

**Theorem 5: Tropical Berggren Tree has Max-Plus Convex Structure**

```lean
/-- The tropical Berggren tree is a max-plus sub-semimodule of L_trop.
    Equivalently: for any two nodes v, w in the tree and any tropical scalars a, b,
    the max-plus combination a ⊗ v ⊕ b ⊗ w is also in the tree (or approximable by tree nodes).
    The tree inherits the max-plus convex hull structure from L_trop.
    Bridge: connects combinatorics (tree structures) to tropical convex geometry. -/
theorem tropical_berggren_tree_convex_hull :
  ∀ (v w : Tropical ℝ × Tropical ℝ × Tropical ℝ)
    (hv : TropicalBerggrenTree v) (hw : TropicalBerggrenTree w),
    ∃ (v' : Tropical ℝ × Tropical ℝ × Tropical ℝ)
      (hv' : TropicalBerggrenTree v'),
      tropicalDist (max v w) v' ≤ log 2
```

**Strategy A**: Prove that the tree is closed under `tropicalBerggrenAction` and that max-plus combinations of tree nodes can be approximated by iterated Berggren actions. Use the O(log 3) approximation from Theorem 3.

**Strategy B**: Prove that the *max-plus convex hull* of the tree equals L_trop ∩ (log ℕ)³. This is stronger and implies the sub-semimodule property. The proof uses the density theorem (Theorem 7) and max-plus convexity of L_trop.

*Strategy B is more ambitious and connects to the density theorem; prove it as the culmination.*

---

**Theorem 6: Tropical Lorentz Group Contains Signed Berggren Matrices**

```lean
/-- The signed tropical Berggren matrices (tracking sign changes) are in O_trop(2,1).
    This refines Theorem 2 by showing that sign-aware tropicalization preserves the group structure.
    The three signed tropical Berggren matrices are distinct (unlike the unsigned versions).
    Bridge: connects real tropicalization to Pythagorean number theory. -/
theorem signed_tropical_berggren_in_lorentz_group :
  ∀ (i : Fin 3), signedTropicalBerggren i ∈ TropicalLorentzGroup
```

**Strategy**: Define the signed tropical Berggren matrices by tracking the sign of each entry. The sign pattern determines which branch of the Pythagorean tree we traverse. Prove that each signed matrix preserves L_trop by verifying the cone condition case-by-case, using the sign information to handle the max-plus computation correctly.

---

**Theorem 7: Tropical Pythagorean Density**

```lean
/-- The tropical Berggren tree is dense in L_trop ∩ (log ℕ)³ with explicit rate O(1/√n).
    For any v ∈ L_trop ∩ (log ℕ)³ and any ε > 0, there exists a tree node w with ‖v − w‖ₜ < ε.
    Moreover, for v with third coordinate ≤ log n, the approximation error is O(1/√n).
    Bridge: connects Diophantine approximation to tropical geometry. -/
theorem tropical_pythagorean_density :
  ∀ (v : Tropical ℝ × Tropical ℝ × Tropical ℝ)
    (hv : v ∈ TropicalLightCone)
    (hvNat : ∃ a b c : ℕ, v = (Tropical.mk a, Tropical.mk b, Tropical.mk c)),
    ∀ (ε : ℝ) (hε : ε > 0),
      ∃ (w : Tropical ℝ × Tropical ℝ × Tropical ℝ)
        (hw : TropicalBerggrenTree w),
        tropicalDist v w < ε
```

**Strategy A**: Use the classical density of Pythagorean triples (the Berggren tree visits every primitive triple). Given (a,b,c) with a²+b²=c², find the tree path to (a,b,c) using the Euclidean algorithm on (a,b,c). The path length is O(log c), giving the approximation rate.

**Strategy B**: Use the Stern-Brocot tree parametrization of Pythagorean triples. Every primitive triple corresponds to a rational number m/n with m > n, and the Berggren tree action corresponds to specific continued fraction operations. The density follows from the density of rationals.

**Strategy C**: Direct construction. Given v ∈ L_trop, find the Berggren matrix sequence that brings (3,4,5) closest to v. Use the greedy algorithm: at each step, choose the Berggren matrix that maximizes the tropical inner product with v. Prove this converges with rate O(1/√n).

*Strategy A is most direct and connects to the catalog's Berggren tree infrastructure.*

---

**Theorem 8: Certified Tropical Robustness Radius**

```lean
/-- For v ∈ L_trop with v₃ = log c, the certified robustness radius is at least log(1 + 1/c²).
    This gives a Lipschitz-certified decision boundary for tropical neural networks.
    Bridge: connects tropical geometry to certified robustness in ML. -/
theorem tropical_certified_robustness_radius :
  ∀ (v : Tropical ℝ × Tropical ℝ × Tropical ℝ)
    (hv : v ∈ TropicalLightCone)
    (hPos : v.2.2 ≠ ⊥),
    tropicalCertifiedRadius v ≥ log (1 + 1/(exp v.2.2.val)^2)
```

**Strategy**: Prove that the tropical light cone has a "margin" of log(1 + 1/c²) around each point v = (log a, log b, log c). The margin comes from the gap between max(log a, log b) and log c: since a² + b² = c² and both a, b are positive integers, we have max(a,b) ≤ c-1 (for c > 5), giving log c - max(log a, log b) ≥ log(c/(c-1)) ≈ 1/c.

---

**Theorem 9: Tropical Berggren Displacement Bound**

```lean
/-- Each tropical Berggren action increases the tropical norm by at most log 3.
    ‖tropicalBerggren i ⊗ v‖ₜ ≤ ‖v‖ₜ + log 3
    This gives O(log n) displacement after n steps, a key complexity bound.
    Bridge: connects tropical dynamics to computational complexity. -/
theorem tropical_berggren_displacement_bound :
  ∀ (i : Fin 3) (v : Tropical ℝ × Tropical ℝ × Tropical ℝ),
    v ∈ TropicalLightCone →
    tropicalNorm (tropicalMatrixVecMul (tropicalBerggrenMatrix i) v) ≤
      tropicalNorm v + log 3
```

**Strategy**: Direct computation. The tropical norm is v₃ (the largest coordinate, since v ∈ L_trop). The action (M ⊗ v)₃ = max(M[3,k] + vₖ) = max(log 2 + v₁, log 2 + v₂, log 3 + v₃). Since max(v₁, v₂) = v₃, we get (M ⊗ v)₃ ≤ max(log 2 + v₃, log 3 + v₃) = log 3 + v₃.

---

**Theorem 10: Maslov Dequantization Convergence Rate**

```lean
/-- The Maslov dequantization converges to max-plus with rate O(h).
    |h · log(exp(x/h) + exp(y/h)) − max(x,y)| ≤ h · log 2
    This quantifies the quantum-to-classical transition in the idempotent limit.
    Bridge: connects quantum mechanics (ℏ → 0) to tropical geometry. -/
theorem maslov_dequantization_convergence_rate :
  ∀ (h : ℝ) (hh : 0 < h) (x y : ℝ),
    |maslovDequantization h x y - max x y| ≤ h * log 2
```

**Strategy**: Prove by case analysis on whether x ≥ y or y > x. If x ≥ y, then maslovDequantization h x y = h · log(exp(x/h) + exp(y/h)) = h · log(exp(x/h)(1 + exp((y-x)/h))) = x + h · log(1 + exp((y-x)/h)). Since y - x ≤ 0, we have 1 ≤ 1 + exp((y-x)/h) ≤ 2, so x ≤ result ≤ x + h · log 2. Similarly for y > x.

---

**Theorem 11: Tropical Hash Collision Resistance**

```lean
/-- Tropical Pythagorean hash: map a path in the Berggren tree to a point in L_trop.
    Collision resistance: finding two paths of length ≤ n mapping to the same point
    requires Ω(2^n) operations under the tropical CSP hardness assumption.
    Bridge: connects Pythagorean number theory to post-quantum cryptography. -/
theorem tropical_pythagorean_hash_collision_resistance :
  ∀ (n : ℕ) (paths : Fin n → Fin 3),
    let v := tropicalBerggrenPath paths (Tropical.mk 3, Tropical.mk 4, Tropical.mk 5)
    -- v is uniquely determined by the path (injectivity)
    ∀ (paths' : Fin n → Fin 3),
      paths ≠ paths' →
      tropicalBerggrenPath paths' (Tropical.mk 3, Tropical.mk 4, Tropical.mk 5) ≠ v
```

**Strategy**: Prove by induction on n that different paths give different endpoints. The key lemma is that the three signed tropical Berggren matrices act as distinct functions on L_trop (they differ in which branch of the tree they traverse). This follows from the injectivity of the classical Berggren tree construction.

---

**Theorem 12: Tropical Light Cone is the Tropicalization of the Classical Light Cone**

```lean
/-- The tropical light cone L_trop equals the tropicalization of the classical cone {v : v₁² + v₂² = v₃²}.
    Formally: L_trop = {v : max(v₁, v₂) = v₃} = Trop({(a,b,c) : a² + b² = c²}).
    This is the foundational bridge between classical and tropical Pythagorean geometry.
    Bridge: connects algebraic geometry (tropicalization) to number theory (Pythagorean triples). -/
theorem tropical_light_cone_equals_trop_classical :
  TropicalLightCone = tropicalVariety (fun v => v.1^2 + v.2.1^2 - v.2.2^2)
```

**Strategy**: Compute the tropicalization of the polynomial f(a,b,c) = a² + b² − c². The tropical polynomial is max(2v₁, 2v₂, 2v₃) (with appropriate signs). The tropical variety is the corner locus where the maximum is achieved at least twice. Show this equals {v : max(v₁, v₂) = v₃} ∪ {v : v₁ = v₂ ≥ v₃}. The second component is lower-dimensional and can be excluded by restricting to the relevant chamber.

### IV. Proof Architecture — Dependency Graph

```
Theorem 12 (L_trop = Trop(V(f)))
    ↓
Theorem 1 (L_trop is max-plus convex) ← Theorem 10 (Maslov rate)
    ↓                                         ↓
Theorem 2 (Berggren preserves L_trop)    Theorem 3 (Duality, approximate)
    ↓                                         ↓
Theorem 4 (O_trop(2,1) is a group)    Theorem 9 (Displacement bound)
    ↓                                         ↓
Theorem 6 (Signed Berggren ∈ O_trop)  Theorem 8 (Robustness radius)
    ↓                                         ↓
Theorem 11 (Hash collision resistance)  Theorem 5 (Tree convex hull)
    ↓
Theorem 7 (Density)
```

Prove in order: 12 → 10 → 1 → 2 → 4 → 6 → 3 → 9 → 8 → 11 → 5 → 7.

### V. Cross-Domain Impact

| Theorem | Primary Domain | Secondary Domain | Application Keyword |
|---------|---------------|-------------------|---------------------|
| 1 | Tropical Geometry | Convex Geometry | `tropical_convex_decision_boundary` |
| 2 | Number Theory | Tropical Algebra | `berggren_tropical_intertwining` |
| 3 | Algebraic Geometry | Idempotent Math | `maslov_dequantization_rate` |
| 4 | Group Theory | Tropical Algebra | `tropical_lorentz_symmetry` |
| 5 | Combinatorics | Tropical Convexity | `tree_convex_hull_approximation` |
| 7 | Diophantine Approx. | Tropical Geometry | `tropical_pythagorean_density_rate` |
| 8 | ML Theory | Tropical Geometry | `lipschitz_certified_robustness` |
| 9 | Dynamical Systems | Complexity Theory | `tropical_displacement_complexity` |
| 11 | Cryptography | Number Theory | `post_quantum_tropical_hash` |

### VI. FUTURE_DIRECTIONS.md — Required Output

Aristotle MUST produce a structured FUTURE_DIRECTIONS.md with 3–5 concrete, breakthrough-level next steps:

1. **Tropical Satake Correspondence**: Prove that the tropical Berggren tree realizes the Satake isomorphism for GL₂ over the tropical semiring, connecting Pythagorean number theory to the Langlands program via idempotent mathematics.

2. **Quantum Error Correction on the Tropical Light Cone**: The max-plus convexity of L_trop and the O_trop(2,1) symmetry suggest a tropical analogue of quantum error-correcting codes. Formalize tropical stabilizer codes with minimum distance Ω(√n) for codes of length n.

3. **Tropical Neural Network Certified Robustness**: Use Theorem 8 (certified robustness radius) to construct provably robust tropical ReLU networks where every neuron's activation lies in L_trop, giving certified adversarial robustness with explicit Lipschitz constants.

4. **Post-Quantum Cryptography from Tropical Pythagorean Lattices**: The tropical Berggren tree defines a lattice in L_trop with hard shortest-vector problems. Prove that finding short vectors in this lattice is at least as hard as factoring, yielding post-quantum security.

5. **Maslov Dequantization as a Functor**: Prove that Maslov dequantization defines a functor from the category of hyperbolic manifolds to the category of tropical manifolds, with the Berggren–Tropical Duality as a natural transformation. This would establish tropical geometry as a legitimate deformation of hyperbolic geometry in the categorical sense.

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
            Open the field of tropical Pythagorean geometry by proving that the Berggren matrices—hyperbolic isometries generating the Pythagorean triple tree—tropicalize to max-plus linear maps preserving the tropical light cone L_trop = {v : max(v₁,v₂) = v₃}, and that this yields a faithful embedding of the classical Berggren tree into a tropical Berggren tree. Specifically: (1) Prove that the log-tropicalization of each Berggren matrix Aᵢ is a max-plus linear map preserving L_trop, establishing a tropical Lorentz group O_trop(2,1). (2) Prove the Berggren–Tropical Duality Theorem: the tropicalization map trop(a,b,c) = (log a, log b, log c) intertwines classical and tropical Berggren action via trop(Aᵢ · v) = Ãᵢ ⊗ trop(v). (3) Prove that the tropical Berggren tree is a max-plus sub-semimodule of ℝ³ with a canonical max-plus convex structure inherited from L_trop. (4) Prove a tropical Pythagorean density theorem: the tropical Berggren tree is dense in L_trop ∩ (log ℕ)³ in the order topology. This creates a revolutionary bridge between Pythagorean number theory and tropical algebraic geometry, opening the field of tropical Pythagorean geometry.

            ### Precise Mathematical Framing
            Let B denote the Berggren tree of primitive Pythagorean triples with generators A₁, A₂, A₃ (the Berggren matrices preserving x²+y²=z²). Define the tropicalization map trop: ℕ³→ℝ³ by trop(a,b,c)=(log a, log b, log c) and the tropical Berggren matrices Ãᵢ with entries (Ãᵢ)ⱼₖ = log(Aᵢ)ⱼₖ. The tropical light cone is L_trop = {v ∈ ℝ³ : max(v₁,v₂) = v₃}. THEOREM 1 (Tropical Light Cone Preservation): For each i ∈ {1,2,3}, Ãᵢ preserves L_trop under max-plus matrix multiplication, i.e., v ∈ L_trop ⟹ Ãᵢ ⊗ v ∈ L_trop. THEOREM 2 (Berggren–Tropical Duality): For all v ∈ B and i ∈ {1,2,3}: trop(Aᵢ · v) = Ãᵢ ⊗ trop(v). COROLLARY: The map trop embeds B into the orbit of trop(3,4,5) under the max-plus semigroup generated by {Ã₁, Ã₂, Ã₃}. THEOREM 3 (Tropical Lorentz Group): The set O_trop(2,1) = {M ∈ Mat₃(ℝ∪{-∞}) : M preserves L_trop under ⊗} is a max-plus matrix group, and the map A ↦ Ã defines a homomorphism from the Berggren subgroup of O(2,1;ℤ) to O_trop(2,1). THEOREM 4 (Max-Plus Convexity): The tropical Berggren tree trop(B) is a max-plus convex subset of L_trop, i.e., for any u,v ∈ trop(B) and α,β ∈ ℝ∪{-∞} with max(α,β)=0, we have max(α+u, β+v) ∈ trop(B) whenever the result lies in (log ℕ)³.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `fundamental_theorem_algebraic_light'` : theorem fundamental_theorem_algebraic_light' (a b c : ℤ) :
     (file: Algebra/Other/UnifyingTheory.lean)
  2. `berggren_A_preserves_lorentz` : theorem berggren_A_preserves_lorentz :
     (file: Pythagorean/Berggren/TropicalPAdicBerggren.lean)
  3. `photon_reach_from_triple` : theorem photon_reach_from_triple {a b c : ℤ} (h : IsPythTriple a b c) (hc : 0 < c) :
     (file: Pythagorean/Core/SpacetimeLattice.lean)
  4. `berggren_tree_growth` : theorem berggren_tree_growth (n : ℕ) : 3 ^ n ≥ 1 := Nat.one_le_pow n 3 (by norm_num)
     (file: Pythagorean/ModularForms/ModularFormsAdvanced.lean)
  5. `classical_tree_search_lower` : theorem classical_tree_search_lower (d : ℕ) : 3^d ≥ d + 1 := by
     (file: Pythagorean/ThreeRoads/DeepOpenProblems.lean)

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



Recent successful concepts: Max-Plus Hecke Algebras and Satake Isomorphism on Idempotent Prime Spectra, unnamed_concept, Lorentzian Berggren Geometry: Hyperbolic Isometries on the Pythagorean Light Cone and Displacement–Hypotenuse Duality


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
