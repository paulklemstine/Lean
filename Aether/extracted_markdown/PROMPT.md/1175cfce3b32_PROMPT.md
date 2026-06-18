

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

## YOUR ASSIGNMENT: Valuation-Skeleton Margin Duality for p-adic Rational Networks

Formalize a valuation-theoretic margin theory for `PadicLayeredMap` and operadic rational networks, with explicit finite Berkovich-skeleton decompositions on which threshold margins are locally constant or affine in valuation coordinates, and with certified robustness / label-complexity consequences motivated by non-Archimedean ML, tropical geometry, and post-quantum / lattice-style arithmetic complexity.

The central paradigm is:

- arithmetic network outputs over a non-Archimedean field admit valuation stratifications,
- threshold classification is constant on sufficiently high-margin skeleton cells,
- label transitions are controlled by the combinatorics of valuation breakpoints,
- hence one gets certified robustness and finite complexity bounds in a p-adic / tropical sense.

You should not merely restate continuity. Build a full mini-theory with new definitions, local lemmas, composition theorems, finite-cell decomposition theorems, and algorithmic counting bounds.

---

## CORE DEFINITIONS TO INTRODUCE

Define at least the following 10+ new notions, with doc comments explicitly saying `Bridge: connects ... to ...` and including keywords such as `quantum`, `certified`, `lattice`, `post_quantum_security`, `tropical`, `thermodynamic`.

### 1. Extended valuation codomain
Use either `WithTop ℤ`, `WithBot ℤ`, or a custom type:
```lean
def EVal := WithTop ℤ
```
or
```lean
inductive PoleVal
| finite : ℤ → PoleVal
| top    : PoleVal   -- zero output / infinite valuation
| bot    : PoleVal   -- pole / denominator zero
```

Provide order structure and basic lemmas.

### 2. Threshold margin
For scalar-valued networks:
```lean
def thresholdMargin {K : Type*} [Field K] [Valued K ℤₘ₀]
  (v : K → EVal) (f : α → K) (t : K) (x : α) : EVal := v (f x - t)
```
If existing `padicValNat` is easier to use, define a natural-valued special case:
```lean
def thresholdMarginNat {K : Type*} [Field K] [Valued K ℤₘ₀]
  (f : α → K) (t : K) (x : α) : ℕ := padicValNat (f x - t)
```

### 3. Label function
```lean
def thresholdLabel {K : Type*} [LinearOrder K] (f : α → K) (t : K) (x : α) : Bool :=
  t ≤ f x
```
If ordered fields are unavailable in the p-adic setting, define valuation-based surrogate labels:
```lean
def valuationSeparator {K : Type*} [Field K] [Valued K ℤₘ₀]
  (f g : α → K) (x : α) : Prop := v (f x) < v (g x)
```

### 4. Skeleton cell with affine valuation chart
```lean
structure SkeletonCell (α : Type*) where
  carrier : Set α
  chartDim : ℕ
  chart : α → Fin chartDim → ℤ
  admissible : Prop
```

Then define affine behavior on a cell:
```lean
def IsAffineOnCell (φ : α → EVal) (C : SkeletonCell α) : Prop :=
  ∃ (a : Fin C.chartDim → ℤ) (b : ℤ),
    ∀ x, x ∈ C.carrier →
      φ x = some_affine_encoding a b (C.chart x)
```
You may simplify by using `ℤ`-valued charts and `∑ i, a i * C.chart x i + b`.

### 5. Finite skeleton decomposition
```lean
structure FiniteSkeletonCover (α : Type*) where
  cells : Finset (SkeletonCell α)
  covers : ∀ x : α, ∃ C ∈ cells, x ∈ C.carrier
```

### 6. Primitive valuation-affine operation class
For operations used in operadic networks:
```lean
class ValuationAffinePrimitive (op : (Fin n → K) → K) : Prop where
  local_piecewise_affine :
    ∀ (D : Fin n → α → K), ∃ S : FiniteSkeletonCover α, ...
```
If too abstract, define this concretely for addition, multiplication, scalar multiplication, inversion away from poles.

### 7. Pole-free region / denominator-safe cell
```lean
def PoleFreeOn (f : α → K) (s : Set α) : Prop := ∀ x ∈ s, f x ≠ 0
```

### 8. High-margin region
```lean
def HighMarginRegion (φ : α → EVal) (γ : ℤ) : Set α :=
  {x | some_order_predicate γ (φ x)}
```

### 9. Label change count across cells
```lean
def labelChangeCount (cells : Finset (SkeletonCell α)) (lbl : α → Bool) : ℕ := ...
```
A workable simplification: count cells on which both labels occur.
```lean
def mixedLabelCellCount (cells : Finset (SkeletonCell α)) (lbl : α → Bool) : ℕ :=
  (cells.filter fun C => (∃ x ∈ C.carrier, lbl x = true) ∧ (∃ y ∈ C.carrier, lbl y = false)).card
```

### 10. Skeleton complexity
```lean
def skeletonComplexity (S : FiniteSkeletonCover α) : ℕ := S.cells.card
```

### 11. Valuation Lipschitz robustness certificate
```lean
def ValuationRobustAt (f : α → K) (t : K) (x : α) (r : EVal) : Prop := ...
```
Tie it to ultrametric balls if available:
```lean
def LabelStableOnBall (f : K → K) (t : K) (x : K) (ρ : ℤ) : Prop :=
  ∀ y, v (y - x) ≥ ρ → thresholdLabel f t y = thresholdLabel f t x
```

### 12. Tropicalized margin profile
```lean
def tropicalMarginProfile (f : α → K) (t : K) (C : SkeletonCell α) : Fin C.chartDim → ℤ := ...
```

---

## PRECISE TARGET THEOREMS

Prove as many as possible of the following, with exact Lean statements. If some must be specialized to a simpler domain such as `ℚ_[p]`, `ℤ_[p]`, or a toy inductive network syntax, do so explicitly and prove the strongest complete version.

### A. Primitive operation lemmas

#### 1. Addition gives min-type lower bound
```lean
theorem thresholdMargin_add_ge_min
  {K : Type*} [Field K] [Valued K ℤₘ₀]
  (vZ : K → EVal)
  (f g : α → K) (x : α) :
  min (vZ (f x)) (vZ (g x)) ≤ vZ (f x + g x)
```
If the library provides the ultrametric inequality in another form, adapt.

#### 2. Multiplication gives exact additivity
```lean
theorem thresholdMargin_mul_eq_add
  {K : Type*} [Field K] [Valued K ℤₘ₀]
  (vZ : K → EVal)
  (f g : α → K) (x : α) :
  vZ (f x * g x) = vZ (f x) + vZ (g x)
```

#### 3. Inversion flips sign away from poles
```lean
theorem thresholdMargin_inv_eq_neg
  {K : Type*} [Field K] [Valued K ℤₘ₀]
  (vZ : K → EVal)
  (f : α → K) (x : α) (hx : f x ≠ 0) :
  vZ ((f x)⁻¹) = - vZ (f x)
```

#### 4. Constant-shift local constancy on strict dominance region
```lean
theorem valuation_shift_locally_constant_of_strict_domination
  {K : Type*} [Field K] [Valued K ℤₘ₀]
  (vZ : K → EVal)
  (f : α → K) (c : K) :
  ∀ x, vZ (f x) < vZ c → vZ (f x + c) = vZ (f x)
```

#### 5. Threshold margin for affine primitive is piecewise affine
```lean
theorem affine_primitive_piecewise_affine_margin
  ... :
  ∃ S : FiniteSkeletonCover α,
    ∀ C ∈ S.cells, IsAffineOnCell (thresholdMargin vZ f t) C
```

### B. Composition / operadic induction theorems

#### 6. Composition preserves finite skeleton piecewise affinity
```lean
theorem operadic_piecewise_affine_margin
  {Net : Type*} -- use existing PadicLayeredMap / operadic API
  (N : Net) :
  ∃ S : FiniteSkeletonCover α,
    ∀ C ∈ S.cells, IsAffineOnCell (thresholdMargin vZ (evalNet N) t) C
```

#### 7. Exists finite skeleton with valuation-chart control
```lean
theorem exists_finite_skeleton_piecewise_affine_margin
  {Net : Type*} (N : Net) :
  ∃ (S : FiniteSkeletonCover α) (B : ℕ),
    skeletonComplexity S ≤ B ∧
    ∀ C ∈ S.cells, IsAffineOnCell (thresholdMargin vZ (evalNet N) t) C
```

#### 8. Quantified chart witness theorem
This must include quantifier alternation:
```lean
theorem forall_point_exists_cell_affine_chart
  {Net : Type*} (N : Net) :
  ∀ x : α, ∃ C, C ∈ (Classical.choose (exists_finite_skeleton_piecewise_affine_margin (N := N))).1.cells
    ∧ x ∈ C.carrier
    ∧ IsAffineOnCell (thresholdMargin vZ (evalNet N) t) C
```

### C. Robustness / label constancy theorems

#### 9. High-margin implies label constancy on cell
```lean
theorem threshold_label_constant_on_high_margin_cell
  {Net : Type*} (N : Net) (γ : ℤ) :
  ∀ C, C ∈ S.cells →
    (∀ x ∈ C.carrier, γ ≤ thresholdMargin vZ (evalNet N) t x) →
    ∃ b : Bool, ∀ x ∈ C.carrier, thresholdLabel (evalNet N) t x = b
```
If order-based labels are unavailable over p-adics, replace by a valuation comparator label.

#### 10. Certified ultrametric robustness from margin
```lean
theorem padic_quantum_certified_robustness_from_margin
  {K : Type*} [Field K] [Valued K ℤₘ₀] [IsUltrametricDist K]
  (f : K → K) (t x : K) :
  ∀ γ, γ ≤ thresholdMargin vZ f t x →
    ∃ ρ, LabelStableOnBall f t x ρ
```
Make `ρ = γ` or `ρ = γ - L` if using a Lipschitz constant.

#### 11. Lipschitz-margin robustness with explicit radius
```lean
theorem lipschitz_certified_robustness_radius_explicit
  {K : Type*} [Field K] [Valued K ℤₘ₀]
  (f : K → K) (L γ : ℤ) (x t : K)
  (hLip : PadicValuationLipschitz f L)
  (hMargin : γ ≤ thresholdMargin vZ f t x) :
  LabelStableOnBall f t x (γ - L)
```

### D. Complexity / counting theorems

#### 12. Label-change cells are finite
```lean
theorem label_change_cells_finite
  (S : FiniteSkeletonCover α) (lbl : α → Bool) :
  mixedLabelCellCount S.cells lbl ≤ S.cells.card
```

#### 13. Explicit cell-count upper bound under composition depth
State a recurrence and prove it by induction:
```lean
theorem label_change_cell_count_le
  (N : Net) :
  ∃ A B : ℕ, mixedLabelCellCount S.cells (thresholdLabel (evalNet N) t) ≤ A * depth N + B
```
or, stronger and more useful:
```lean
theorem skeleton_complexity_depth_bound
  (N : Net) :
  ∃ c : ℕ, skeletonComplexity (buildSkeleton N) ≤ c ^ depth N
```
If exact architecture parameters exist, use them:
```lean
... ≤ (width N + 1) ^ depth N
```

#### 14. Polynomial-time evaluation of chart margin
Even if actual complexity classes are not formalized, define a simple cost model:
```lean
def chartEvalCost (C : SkeletonCell α) : ℕ := ...
```
Then prove:
```lean
theorem tropical_hash_collision_chartEvalCost_linear
  (C : SkeletonCell α) :
  chartEvalCost C ≤ C.chartDim + 1
```

#### 15. Mixed-label cells controlled by breakpoint count
```lean
theorem mixedLabelCellCount_le_breakpointCount
  (S : FiniteSkeletonCover α) :
  mixedLabelCellCount S.cells lbl ≤ breakpointCount S
```

### E. Symmetry / invariance theorems

#### 16. Permutation invariance of symmetric charts
```lean
theorem symmetric_skeleton_quantum_invariance
  (σ : Equiv.Perm (Fin n))
  (C : SkeletonCell α)
  (hSymm : SymmetricChart C) :
  transformedComplexity σ C = skeletonCellComplexity C
```

#### 17. Margin invariant under equivalent chart presentations
```lean
theorem affine_chart_reparametrization_preserves_margin
  (C₁ C₂ : SkeletonCell α)
  (hEq : EquivalentChart C₁ C₂) :
  IsAffineOnCell φ C₁ → IsAffineOnCell φ C₂
```

### F. Tropical / physics / crypto bridge theorems

#### 18. Tropicalization of valuation margin
```lean
theorem tropicalized_margin_is_minplus_affine
  (C : SkeletonCell α) :
  IsAffineOnCell (thresholdMargin vZ f t) C →
  ∃ a b, ∀ x ∈ C.carrier,
    thresholdMargin vZ f t x = b + Finset.univ.sum (fun i => a i * C.chart x i)
```

#### 19. Thermodynamic monotonicity of certified margin regions
Define a simple entropy-like proxy:
```lean
def cellEntropy (S : FiniteSkeletonCover α) : ℚ := ...
```
Then prove monotonicity under refinement:
```lean
theorem thermodynamic_entropy_monotone_under_refinement
  (S₁ S₂ : FiniteSkeletonCover α)
  (hRef : Refines S₂ S₁) :
  cellEntropy S₁ ≤ cellEntropy S₂
```

#### 20. Post-quantum / lattice style hardness proxy via cell complexity
Define:
```lean
def latticeSecurityProxy (N : Net) : ℕ := skeletonComplexity (buildSkeleton N)
```
Then prove a nontrivial monotonicity or lower bound:
```lean
theorem post_quantum_security_proxy_monotone_in_depth
  (N₁ N₂ : Net) (hDepth : depth N₁ ≤ depth N₂)
  (hEmbed : EmbedsAsPrefix N₁ N₂) :
  latticeSecurityProxy N₁ ≤ latticeSecurityProxy N₂
```

---

## RECOMMENDED LEAN TYPE SIGNATURES

Prefer abstraction, but specialize if needed to get complete proofs.

### Valuation API layer
If direct `Valued K ℤₘ₀` is cumbersome, define an interface:
```lean
class HasIntValuation (K : Type*) where
  v : K → WithTop ℤ
  map_zero : v 0 = ⊤
  map_one : v 1 = 0
  map_mul : ∀ x y, v (x * y) = v x + v y
  map_add_ge_min : ∀ x y, min (v x) (v y) ≤ v (x + y)
```
Then many theorems become cleaner:
```lean
variable {K : Type*} [Field K] [HasIntValuation K]
```

### Skeleton-cell predicates
```lean
def CellConst (φ : α → β) (C : SkeletonCell α) : Prop :=
  ∃ b, ∀ x ∈ C.carrier, φ x = b

def CellAffine (φ : α → WithTop ℤ) (C : SkeletonCell α) : Prop := ...
```

### Toy syntax for rational operadic networks
If existing APIs are too opaque, introduce an auxiliary syntax and prove transfer lemmas:
```lean
inductive RationalGate
| input : ℕ → RationalGate
| const : K → RationalGate
| add : RationalGate → RationalGate → RationalGate
| mul : RationalGate → RationalGate → RationalGate
| inv : RationalGate → RationalGate

def RationalGate.eval (σ : ℕ → K) : RationalGate → K
def RationalGate.depth : RationalGate → ℕ
def RationalGate.margin (t : K) (σ : ℕ → K) (g : RationalGate) : EVal
```
Then prove skeleton theorems first for `RationalGate`, and finally connect to `PadicLayeredMap` by an interpretation theorem.

---

## PROOF STRATEGY BLUEPRINT

Use at least 3 proof styles: structural induction on syntax/depth, `rcases` on finite covers and witnesses, contradiction on mixed-label cells, arithmetic automation (`omega`, `linarith`) for complexity recurrences, and algebraic cleanup (`field_simp`) in rational examples.

### Strategy A: Structural induction on rational-gate syntax
Most promising if existing operadic API supports recursion or a depth measure.

1. Prove primitive valuation lemmas for `const`, `input`, `add`, `mul`, `inv`.
2. Define a skeleton constructor `buildSkeleton : RationalGate → FiniteSkeletonCover α`.
3. Show:
   - inputs/constants give one-cell covers,
   - addition/multiplication refine the common refinement of child covers,
   - inversion only requires splitting off the pole locus.
4. Prove by induction:
```lean
∀ g, ∃ S, ∀ C ∈ S.cells, IsAffineOnCell (marginOfGate g) C
```
5. Derive complexity recurrence:
```lean
complexity(add g h) ≤ complexity g * complexity h
complexity(inv g) ≤ complexity g + 1
```
6. Finish with depth-based exponential/polynomial upper bounds by induction and `omega`.

Why this is strongest: it converts Berkovich geometry into explicit combinatorics that Lean can manage.

### Strategy B: Local constancy via ultrametric inequalities + cover extraction
Best for robustness theorems.

1. Start from `padicLayeredMap_lipschitz_certified_robustness`.
2. Show if `v (f x - t) ≥ γ` and `v (f y - f x) ≥ γ`, then `v (f y - t) ≥ γ` by ultrametric triangle.
3. Use the Lipschitz theorem to derive `v (f y - f x) ≥ γ` whenever `v (y - x) ≥ γ - L`.
4. Conclude label stability on ultrametric balls.
5. Package each such ball as a degenerate `SkeletonCell`.

Why this matters: it converts valuation margin directly into certified robustness, a p-adic analogue of adversarial robustness.

### Strategy C: Tropicalization / min-plus linearization
Best for cross-domain originality.

1. Translate valuation identities into min-plus relations:
   - multiplication ↔ addition,
   - ultrametric sum ↔ min lower bound,
   - strict dominance ↔ exact min selection.
2. On regions where a unique monomial dominates, prove exact affine formulas for valuation margins.
3. Build cells by conjunctions of dominance inequalities.
4. Show threshold labels are constant on cells with strict valuation gap.
5. Derive cell-count bounds from the number of possible dominant patterns.

Why this is revolutionary: it links non-Archimedean neural decision boundaries to tropical polyhedral decompositions, opening arithmetic certified ML and cryptographic complexity interpretations.

---

## KEY INTERMEDIATE LEMMAS TO PRIORITIZE

Prove these early; many main theorems should reduce to them.

```lean
theorem min_strict_selects_left
  {a b : WithTop ℤ} (h : a < b) : min a b = a
```

```lean
theorem valuation_add_eq_of_strictly_smaller
  [HasIntValuation K] {x y : K}
  (h : HasIntValuation.v x < HasIntValuation.v y) :
  HasIntValuation.v (x + y) = HasIntValuation.v x
```

```lean
theorem affine_on_inter_refinement
  (φ : α → EVal) (C₁ C₂ : SkeletonCell α) :
  IsAffineOnCell φ C₁ → IsAffineOnCell φ C₂ →
  IsAffineOnCell φ (interRefine C₁ C₂)
```

```lean
theorem const_on_high_margin_of_affine_gap
  (C : SkeletonCell α) (φ : α → EVal) (γ : ℤ) :
  IsAffineOnCell φ C →
  (∀ x ∈ C.carrier, γ ≤ φ x) →
  CellConst (thresholdLabel f t) C
```

```lean
theorem complexity_refinement_mul
  (S₁ S₂ : FiniteSkeletonCover α) :
  skeletonComplexity (commonRefinement S₁ S₂) ≤ skeletonComplexity S₁ * skeletonComplexity S₂
```

```lean
theorem depth_complexity_recurrence
  (g : RationalGate) :
  skeletonComplexity (buildSkeleton g) ≤ baseComplexity ^ g.depth
```

---

## EXPECTED TACTICS / PROOF METHODS

Use varied tactics across the file.

- `induction g with`
- `rcases hcov x with ⟨C, hCmem, hxC⟩`
- `by_contra hmix`
- `have htri := ultrametric_triangle_inequality ...`
- `omega` for cardinality/depth/cost recurrences
- `linarith` where integer inequalities are cast to ordered rings
- `field_simp` for rational-function examples over `ℚ`
- `simp`, `aesop`, `constructor`, `refine`, `exact`
- `classical` only when needed for finite-cover witnesses
- `simpa [thresholdMargin, thresholdLabel, HighMarginRegion]`

Do not rely on `simp` alone. Make the file exhibit proof diversity.

---

## MINIMAL HYPOTHESIS DISCIPLINE

Push for the strongest possible abstraction:

- primitive valuation lemmas under `[Field K] [HasIntValuation K]`,
- robustness under `[IsUltrametricDist K]`,
- chart-affinity over arbitrary input type `α`,
- counting theorems over finite covers independent of network semantics.

Then instantiate to p-adic networks.

If order on `K` is problematic, define labels through comparison with another output or through valuation gap predicates. A mathematically elegant option is binary classification by dominant output:
```lean
def argminValLabel (f₀ f₁ : α → K) (x : α) : Bool :=
  decide (HasIntValuation.v (f₀ x) ≤ HasIntValuation.v (f₁ x))
```
Then high-margin means strict separation in valuation, which is natural in tropical / p-adic classification.

---

## STRONG SPECIAL CASES IF FULL GENERALITY STALLS

If direct formalization against full operadic APIs becomes intractable, fully complete one of these special cases instead, with all proofs:

1. **Toy rational-gate syntax over a valued field**:
   complete all piecewise-affine and complexity theorems there.

2. **One-variable p-adic rational functions**:
   cells are ultrametric balls / annuli, margin is constant or affine in valuation of `x - a`.

3. **Two-output classifier with valuation-gap label**:
   prove robustness and finite mixed-cell count for
```lean
def valuationGap (f g : α → K) (x : α) : EVal := v (f x) - v (g x)
```

4. **Polynomial networks only (no inversion)**:
   prove exact tropical piecewise-affine margin decomposition, then add inversion as a separate theorem on pole-free cells.

State any remaining conjecture precisely, e.g.
```lean
conjecture operadic_rational_margin_global_skeleton
  ...
```
but prove all consequences of the special case rigorously.

---

## SIGNIFICANCE TO THE RESEARCH PROGRAM

This formalization should establish a new bridge between:

- **non-Archimedean analytic geometry** and **certified robustness in ML**,
- **tropical piecewise-linearization** and **arithmetic operadic networks**,
- **Berkovich skeleta** and **post-quantum / lattice-style complexity proxies**.

The breakthrough is not merely continuity: it is a certified, finite, computable combinatorial model of p-adic decision boundaries. This creates a formal language for:

- p-adic analogues of adversarial robustness,
- valuation-based VC / complexity stratification,
- tropicalized network verification,
- arithmetic hardness proxies relevant to cryptographic architectures,
- possible future links to quantum / thermodynamic interpretations of valuation phase regions.

Use theorem names and doc comments to make these bridges explicit, e.g.
`padic_quantum_certified_robustness_from_margin`,
`tropical_hash_collision_chartEvalCost_linear`,
`post_quantum_security_proxy_monotone_in_depth`.

---

## DELIVERABLE SHAPE

Produce a substantial Lean development with:

- 10+ new definitions,
- 20+ theorems/lemmas,
- at least 3 theorem families: primitive valuation algebra, skeleton decomposition, robustness/counting,
- zero sorries,
- one coherent mathematical narrative from primitive operations to a main finite-skeleton theorem and robustness corollaries.

Conclude with a precise `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps, for example:

1. multiclass valuation arrangements and tropical Voronoi cells,
2. p-adic PAC-Bayes or entropy bounds on skeleton partitions,
3. transfer from toy `RationalGate` syntax to full operadic `PadicLayeredMap`,
4. post-quantum security interpretations of skeleton complexity,
5. Berkovich-homological invariants of arithmetic decision boundaries.

Make the file feel like the first chapter of a new subject, not an isolated lemma dump.

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
            Formalize a duality between p-adic analytic skeleton stratifications of rational operadic networks and arithmetic classification margins: prove that for a rational operadic network f : Q_p^n -> Q_p with bounded parameter height, the valuation profile x ↦ v_p(f(x)-t) induces a finite Berkovich skeleton decomposition on which the decision margin to threshold t is piecewise affine, and derive an algorithmic upper bound on the number of label-change cells in terms of depth, arity profile, and parameter heights. This extends the successful Berkovich continuity and arithmetic VC-dimension threads, but is distinct from in-flight vector-valued certification and arithmetic cell decomposition because it targets threshold margins and label complexity rather than Lipschitz constants or generic region counting.

            ### Precise Mathematical Framing
            Let f be a rational operadic network assembled from affine and rational primitive operations over Q_p, with all coefficients of logarithmic height <= H. For a threshold t in Q_p, define the arithmetic margin m_t(x) := v_p(f(x)-t). The proposed result is that there exists a finite skeleton stratification S of the Berkovich analytification of the input domain such that m_t restricts to an integer-affine function on each cell of S away from poles and exact threshold loci. A second result bounds the number of sign/threshold transition cells by a function polynomial or singly exponential in depth and H, depending on the allowed primitives. A third result identifies a transfer principle: if two inputs lie in the same skeleton cell and have margin above a computable radius-dependent cutoff, then they share the same threshold label under all parameter perturbations of valuation >= r. This would synthesize Berkovich geometry, valuation combinatorics, and learning-theoretic margin stability into a new arithmetic decision-boundary theory.

            ### Lean 4 Sketch
Build on existing `PadicLayeredMap`/operadic network APIs and Berkovich continuity lemmas to define `thresholdMargin (f) (t) (x) := padicValNat (f x - t)` or an extended valuation type handling zero/poles. Introduce a `SkeletonCell` structure with affine valuation charts, prove local constancy/piecewise-affinity lemmas for primitive operations, then induct on operadic composition. Final statements likely resemble `exists_finite_skeleton_piecewise_affine_margin`, `threshold_label_constant_on_high_margin_cell`, and `label_change_cell_count_le`.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `certified_robustness_from_margin_and_lipschitz` : theorem certified_robustness_from_margin_and_lipschitz
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  3. `deep_network_region_bound` : theorem deep_network_region_bound (k : ℕ) (widths : Fin k → ℕ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  4. `padic_arithmetic_depth_bound` : theorem padic_arithmetic_depth_bound (p : ℕ) [Fact p.Prime]
     (file: Bridges/NonArchimedeanComputation.lean)
  5. `network_depth_spectral_bound` : theorem network_depth_spectral_bound (d : ℕ) :
     (file: Bridges/SpectralApplications.lean)

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



Recent successful concepts: Functorial Entropic Uncertainty via Tropical–Ultrametric Quantum Measurement Skeletons, Berkovich Continuity and Skeleton Region Bounds for p-adic Operadic Neural Networks, Arithmetic VC-Dimension via Height-Stratified Shattering for Rational Operadic Networks


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • ALL images MUST be embedded as base64 data URIs:
                 `<img src="data:image/png;base64,..." />` for PNGs,
                 `<img src="data:image/svg+xml;base64,..." />` for SVGs.
                 For SVG diagrams, prefer inlining `<svg>...</svg>` markup directly.
                 If you generate matplotlib/plotly charts, convert to base64 and embed.
                 NEVER reference external image files — they won't exist standalone.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the HTML as base64 data URIs. Use the format:
  `<img src="data:image/png;base64,..." />` for PNGs,
  `<img src="data:image/svg+xml;base64,..." />` for SVGs.
  If you generate matplotlib/plotly figures in Python, convert them to base64
  and embed them. For SVG diagrams, inline the SVG markup directly with
  `<svg>...</svg>` tags — this is preferred over base64 for vector graphics.
  NEVER use `<img src="filename.png">` — the file won't exist when viewing.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
