

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

## YOUR ASSIGNMENT: Algebraic–EML Hochschild Cohomology of Closure Semirings via Deformation Rigidity and Capacity Obstructions

Formalize a low-degree Hochschild-style deformation theory for **closure semirings** and **closure-preserving endomorphisms**, with explicit rigidity and obstruction theorems in degrees `0,1,2`, and with application-facing semantics for **quantum capacity**, **post_quantum_security**, and **lipschitz_certified_robustness**. The core goal is not a generic cohomology library, but a concrete Lean 4 package showing that first-order deformations of closure-preserving multiplication are classified by `H²`-style cocycles modulo coboundaries, and that vanishing of this obstruction space implies deformation rigidity.

Work in a mathematically minimal but formally robust setting: start from an idempotent semiring or semiring equipped with a closure operator compatible with multiplication, then define observables as closure-stable additive endomorphisms or closure-stable bimodule-valued cochains. Prove the theory first in low degree with explicit formulas and computational witnesses.

### 1. Core new definitions and structures to introduce

You should define at least the following, with doc comments explicitly naming bridges to algebra, semantics, and one application domain (quantum / cryptographic / ML):

```lean
/-- A semiring equipped with a closure operator compatible with `+` and `*`.
Bridge: connects idempotent algebra to EML fixed-point semantics and quantum capacity bounds. -/
class ClosureSemiring (R : Type u) extends Semiring R where
  cl : R → R
  cl_extensive : ∀ x, x ≤ cl x
  cl_idem : ∀ x, cl (cl x) = cl x
  cl_monotone : Monotone cl
  cl_zero : cl 0 = 0
  cl_add : ∀ x y, cl (x + y) = cl (cl x + cl y)
  cl_mul_left : ∀ x y, cl (x * y) = cl (cl x * y)
  cl_mul_right : ∀ x y, cl (x * y) = cl (x * cl y)
```

If the order-theoretic axioms above are too strong for Mathlib’s existing typeclass graph, introduce a weaker structure:

```lean
class WeakClosureSemiring (R : Type u) extends Semiring R, LE R where
  cl : R → R
  cl_extensive : ∀ x, x ≤ cl x
  cl_idem : ∀ x, cl (cl x) = cl x
  cl_monotone : Monotone cl
```

Then define closure-compatible multiplication separately.

Also introduce:

```lean
/-- Closure-preserving semiring endomorphisms. -/
structure ClosureEnd (R : Type u) [WeakClosureSemiring R] where
  toFun : R → R
  map_zero' : toFun 0 = 0
  map_one' : toFun 1 = 1
  map_add' : ∀ x y, toFun (x + y) = toFun x + toFun y
  map_mul' : ∀ x y, toFun (x * y) = toFun x * toFun y
  map_cl' : ∀ x, toFun (WeakClosureSemiring.cl x) = WeakClosureSemiring.cl (toFun x)
```

```lean
/-- Closure-stable observables with additive structure.
Bridge: connects Hochschild cochains to proof-semiring channels and certified robustness observables. -/
structure ClosureObservable (R M : Type u) [Semiring R] [AddCommMonoid M] [Module R M] where
  toFun : R → M
  map_zero' : toFun 0 = 0
  map_add' : ∀ x y, toFun (x + y) = toFun x + toFun y
```

```lean
/-- Bilinear first-order deformation kernel for multiplication. -/
structure ClosureTwoCochain (R : Type u) [Semiring R] where
  toFun : R → R → R
  add_left' : ∀ x₁ x₂ y, toFun (x₁ + x₂) y = toFun x₁ y + toFun x₂ y
  add_right' : ∀ x y₁ y₂, toFun x (y₁ + y₂) = toFun x y₁ + toFun x y₂
```

```lean
/-- Normalized 1-cochains vanishing on `0`; optional `1`-normalization if useful. -/
structure ClosureOneCochain (R : Type u) [Semiring R] where
  toFun : R → R
  map_zero' : toFun 0 = 0
  map_add' : ∀ x y, toFun (x + y) = toFun x + toFun y
```

```lean
/-- Hochschild-style differential on 1-cochains. -/
def closure_d1 {R : Type u} [Semiring R] (f : ClosureOneCochain R) : ClosureTwoCochain R := ...
```

```lean
/-- Hochschild-style 2-cocycle condition for first-order associativity. -/
def IsClosureTwoCocycle {R : Type u} [Semiring R] (φ : ClosureTwoCochain R) : Prop := ...
```

```lean
/-- Coboundary relation between 2-cochains induced by gauge change. -/
def ClosureTwoCohomologous {R : Type u} [Semiring R]
    (φ ψ : ClosureTwoCochain R) : Prop := ∃ f : ClosureOneCochain R, ψ = φ + closure_d1 f
```

You may realize `+` on cochains via instances on structures, or use pointwise definitions first and add instances later.

Further define at least five of the following to satisfy the utility/originality target:

```lean
def preserves_closure_bilinear ...
def normalized_two_cochain ...
def firstOrderDeformationMul ...
def firstOrderAssociative ...
def firstOrderEquivalent ...
def closure_rigidity ...
def quantum_capacity_obstruction ...
def post_quantum_security_obstruction ...
def lipschitz_certified_robustness_observable ...
def tropical_hash_collision_energy ...
def deformation_energy ...
def closure_center ...
def closure_derivation ...
```

### 2. Exact theorem targets with Lean-style signatures

You should prove a coherent chain of at least 20 theorems. The following are the minimum central theorems; name them boldly and non-generically.

#### Algebraic foundations

```lean
theorem closure_d1_additive
    {R : Type u} [Semiring R] (f : ClosureOneCochain R) :
    ∀ x y z, closure_d1 f (x + y) z = closure_d1 f x z + closure_d1 f y z := ...
```

```lean
theorem closure_d1_formula
    {R : Type u} [Semiring R] (f : ClosureOneCochain R) :
    ∀ x y, closure_d1 f x y = x * f.toFun y -? + f.toFun (x * y) -? + f.toFun x * y
```

If subtraction is unavailable over semirings, do **not** fake ring formulas. Instead define the semiring-compatible coboundary by exact equality of deformed products, or work over `[Ring R]` / `[Semiring R] [CanonicallyOrderedAddMonoid ...]` in parallel. A very good design is:

- semiring layer: define cocycle relation directly by associativity comparison
- ring layer: recover the classical alternating-sign formula

So add a ring-specialized theorem:

```lean
def ring_closure_d1 {R : Type u} [Ring R] (f : R →+ R) : R → R → R := ...

theorem ring_closure_d1_sq_zero_low_degree
    {R : Type u} [Ring R] (f : R →+ R) :
    IsRingTwoCocycle (ring_closure_d1 f) := ...
```

#### First-order associativity criterion

Define deformed multiplication:
```lean
def firstOrderDeformationMul {R : Type u} [Semiring R]
    (φ : ClosureTwoCochain R) : R → R → R := fun x y => x * y + φ.toFun x y
```

Then prove a semiring-compatible associativity criterion. Since equality of
`(x ⋆ y) ⋆ z` and `x ⋆ (y ⋆ z)` with `⋆ := * + εφ` cannot literally be encoded without dual numbers, encode **first-order associativity residual**:

```lean
def associativityResidual {R : Type u} [Semiring R]
    (φ : ClosureTwoCochain R) (x y z : R) : R :=
    φ.toFun (x * y) z + φ.toFun x y * z
      +? -- if needed, closure-adjusted combination
    ...
```

A cleaner route is to formalize a separate structure of “first-order symbols”:

```lean
structure DualLike (R : Type u) where
  base : R
  eps  : R
```

with multiplication truncated at order `ε² = 0`:
`(a,b)*(c,d) = (a*c, a*d + b*c)`.
This is highly recommended because it lets you state true associativity theorems without subtraction.

Then prove:

```lean
theorem quantum_firstOrder_associativity_iff_cocycle
    {R : Type u} [Semiring R] (φ : ClosureTwoCochain R) :
    (∀ a b c : DualLike R,
      dualMul φ (dualMul φ a b) c = dualMul φ a (dualMul φ b c))
    ↔ IsClosureTwoCocycle φ := ...
```

Even if this theorem is first shown only for embedded base elements `(x,0)`, make the statement precise.

#### Coboundaries and gauge equivalence

Define a gauge transform on `DualLike R` induced by a `ClosureOneCochain R`, and prove:

```lean
theorem cryptographic_gauge_shift_changes_by_coboundary
    {R : Type u} [Semiring R]
    (f : ClosureOneCochain R) (φ : ClosureTwoCochain R) :
    firstOrderEquivalent (gaugeShift f φ) φ := ...
```

```lean
theorem firstOrderEquivalent_refl
    {R : Type u} [Semiring R] :
    Reflexive (@firstOrderEquivalent R _) := ...
```

```lean
theorem firstOrderEquivalent_symm
    {R : Type u} [Ring R] :
    Symmetric (@firstOrderEquivalent R _) := ...
```

```lean
theorem firstOrderEquivalent_trans
    {R : Type u} [Ring R] :
    Transitive (@firstOrderEquivalent R _) := ...
```

If symmetry/transitivity truly need additive inverses, separate semiring and ring versions explicitly.

#### Rigidity from vanishing `H²`

You likely cannot define full quotient cohomology elegantly without a substantial setoid development, but you can still prove the operational rigidity theorem:

```lean
def closure_rigidity {R : Type u} [Semiring R] : Prop :=
  ∀ φ : ClosureTwoCochain R, IsClosureTwoCocycle φ → ∃ f : ClosureOneCochain R, φ = closure_d1 f
```

Then prove:

```lean
theorem thermodynamic_deformation_rigidity_of_H2_vanishes
    {R : Type u} [Semiring R]
    (hRig : closure_rigidity R) :
    ∀ φ : ClosureTwoCochain R, IsClosureTwoCocycle φ →
      firstOrderEquivalent φ (zeroTwoCochain R) := ...
```

And conversely a weak converse:

```lean
theorem deformation_triviality_implies_coboundary_witness
    {R : Type u} [Semiring R]
    (h : ∀ φ, IsClosureTwoCocycle φ → firstOrderEquivalent φ (zeroTwoCochain R)) :
    ∀ φ, IsClosureTwoCocycle φ → ∃ f, φ = closure_d1 f := ...
```

#### Closure compatibility

Now incorporate closure. Define:

```lean
def ClosureCompatibleTwoCocycle {R : Type u} [WeakClosureSemiring R]
    (φ : ClosureTwoCochain R) : Prop :=
  ∀ x y, φ.toFun (WeakClosureSemiring.cl x) (WeakClosureSemiring.cl y) =
         WeakClosureSemiring.cl (φ.toFun x y)
```

Prove:

```lean
theorem closure_preserving_endomorphism_induces_zero_obstruction
    {R : Type u} [WeakClosureSemiring R]
    (f : ClosureEnd R) :
    ClosureCompatibleTwoCocycle (closure_d1_of_end f) := ...
```

```lean
theorem closure_cocycle_descends_to_closed_part
    {R : Type u} [WeakClosureSemiring R]
    (φ : ClosureTwoCochain R)
    (hφ : ClosureCompatibleTwoCocycle φ) :
    ∃ ψ : ClosureTwoCochain {x : R // WeakClosureSemiring.cl x = x}, True := ...
```

If the subtype theorem is too heavy, prove instead that the image of closed elements is closed.

#### Degree-0 / degree-1 interpretations

Define a closure center / derivation notion and prove classification theorems:

```lean
def closure_center {R : Type u} [Semiring R] : Set R := {z | ∀ x, z * x = x * z}
def is_closure_derivation {R : Type u} [Ring R] (δ : R →+ R) : Prop :=
  ∀ x y, δ (x * y) = x * δ y + δ x * y
```

Then prove:

```lean
theorem quantum_H0_equals_closure_center
    {R : Type u} [Semiring R] :
    True := ...
```

Do not leave this vacuous; encode a meaningful statement, e.g. every central element defines a zero-degree cocycle, or degree-0 closed observables coincide with the closure center under your definitions.

```lean
theorem certified_derivation_yields_trivial_firstOrder_channel
    {R : Type u} [Ring R] (δ : R →+ R)
    (hδ : is_closure_derivation δ) :
    IsRingTwoCocycle (ring_closure_d1 δ) := ...
```

### 3. Computational / capacity obstruction layer

You must include explicit quantitative definitions, even if elementary. This is essential.

Introduce a finite-support or finite-enumeration complexity surrogate for a cochain on `Fin n`. For example:

```lean
def cochain_eval_cost (n : ℕ) : ℕ := n^2
def cocycle_check_cost (n : ℕ) : ℕ := n^3
def gauge_normalization_cost (n : ℕ) : ℕ := n^2 + n
```

Then prove exact or asymptotic upper bounds:

```lean
theorem cocycle_check_cost_cubic (n : ℕ) :
    cocycle_check_cost n ≤ n^3 + 3*n^2 + 1 := by omega
```

```lean
theorem gauge_normalization_cost_quadratic (n : ℕ) :
    gauge_normalization_cost n ≤ 2 * n^2 + 1 := by
  nlinarith [sq_nonneg (n : ℤ)]
```

If `nlinarith` over naturals is awkward, cast carefully to integers or use `omega`.

Now define simple obstruction functionals:

```lean
def quantum_capacity_obstruction {R : Type u} [CanonicallyOrderedCommSemiring R]
    (φ : ClosureTwoCochain R) (x y z : R) : R := ...

def post_quantum_security_obstruction {R : Type u} [CanonicallyOrderedCommSemiring R]
    (φ : ClosureTwoCochain R) (x y z : R) : R :=
    quantum_capacity_obstruction φ x y z + quantum_capacity_obstruction φ z y x

def lipschitz_certified_robustness_observable {R : Type u} [LinearOrderedSemiring R]
    (φ : ClosureTwoCochain R) (L : R) : Prop :=
    ∀ x y z, quantum_capacity_obstruction φ x y z ≤ L * (x + y + z)
```

Prove monotonicity / vanishing lemmas:

```lean
theorem quantum_capacity_obstruction_zero_of_zeroTwoCochain
    {R : Type u} [CanonicallyOrderedCommSemiring R] (x y z : R) :
    quantum_capacity_obstruction (zeroTwoCochain R) x y z = 0 := ...
```

```lean
theorem post_quantum_security_obstruction_symmetric
    {R : Type u} [CanonicallyOrderedCommSemiring R]
    (φ : ClosureTwoCochain R) :
    ∀ x y z, post_quantum_security_obstruction φ x y z =
             post_quantum_security_obstruction φ z y x := ...
```

```lean
theorem certified_lipschitz_robustness_of_trivial_obstruction
    {R : Type u} [LinearOrderedCommSemiring R]
    (L : R) (hL : 0 ≤ L) :
    lipschitz_certified_robustness_observable (zeroTwoCochain R) L := ...
```

Also give at least one theorem on finite domains such as `Fin n → R`, matrices, or tuples, with an explicit `O(n^3)`-style cost statement encoded as a polynomial upper bound.

### 4. Strong special cases that should definitely be completed

If the full generality becomes technically expensive, complete these special cases fully and cleanly:

1. **Ring-specialized low-degree theory** with classical alternating-sign Hochschild differential.
2. **Commutative semiring + DualLike truncation** for first-order associativity without subtraction.
3. **Finite semiring on `Fin n → ℕ` or matrices over `ℕ`** with explicit obstruction-cost lemmas.
4. **Idempotent / tropical-flavored semiring** where closure is identity; show the abstract theory specializes cleanly.
5. **ClosureEnd-induced cocycles** where the obstruction is provably zero or bounded.

A very strong package is one where:
- semiring theory handles truncated dual numbers and cocycle semantics,
- ring theory handles quotient-like coboundary algebra,
- ordered semiring theory handles quantitative obstruction bounds.

### 5. Concrete proof strategy guidance

You should not rely on a single giant proof. Build a staircase of lemmas.

#### Strategy A: Dual-like truncation for semirings (most promising)
1. Define `DualLike R := R × R` or a structure with fields `base eps`.
2. Define addition and multiplication:
   - `(a,b) + (c,d) = (a+c, b+d)`
   - `(a,b) * (c,d) = (a*c, a*d + b*c)`
3. Twist multiplication by a two-cochain:
   - `dualMul φ (a,b) (c,d) := (a*c, a*d + b*c + φ a c)`
4. Expand both associativity sides on triples `(x,0),(y,0),(z,0)` and identify equality of epsilon-components with your cocycle condition.
5. Use `ext <;> simp [dualMul, add_assoc, add_left_comm, add_comm, mul_add, add_mul, mul_assoc]`.

This route avoids subtraction and is ideal for `[Semiring R]`.

#### Strategy B: Ring-level Gerstenhaber low degree
1. Over `[Ring R]`, define `d1 f x y = x * f y - f (x*y) + f x * y`.
2. Define `d2 φ x y z = x*φ y z - φ (x*y) z + φ x (y*z) - φ x y * z`.
3. Prove `d2 (d1 f) = 0` by direct expansion.
4. Use `ring_nf`, `abel`, `simp`, `noncomm_ring` if available; otherwise expand carefully.
5. Show gauge-equivalent deformations differ by a coboundary.

This is the cleanest path for theorems involving symmetry, quotient intuition, and exact coboundary formulas.

#### Strategy C: Closure descent and closed-part restriction
1. Define the subtype of closed elements `{x // cl x = x}`.
2. Prove closure of a closed element is itself by simp.
3. Show a closure-compatible cochain maps closed pairs to closed outputs.
4. Package the restricted map as a cochain on the closed subtype.
5. Use `Subtype.ext`, `rcases`, and closure compatibility hypotheses.

This is the key bridge to EML semantics and fixed-point condensation.

### 6. Tactic diversity requirements inside the theorem corpus

Ensure the file visibly uses many tactics and proof styles:
- `ext`
- `simp`
- `rw`
- `calc`
- `rcases`
- `constructor`
- `obtain`
- `induction` on naturals for cost recurrences or finite tuple lemmas
- `by_contra` for non-rigidity / obstruction contrapositives
- `omega` for polynomial natural-number bounds
- `linarith` / `nlinarith` after casts for quantitative inequalities
- `field_simp` in at least one ring/field quantitative lemma, e.g. a normalized obstruction average over `ℚ` or `ℝ`
- `aesop` only as a supplement, never the main engine

Include at least one theorem with quantifier alternation of the form:
```lean
theorem rigidity_witness_extraction
    {R : Type u} [Semiring R] :
    closure_rigidity R →
    ∀ φ, IsClosureTwoCocycle φ → ∃ f, firstOrderEquivalent φ (closure_d1 f) := ...
```

And at least one contrapositive-style theorem:
```lean
theorem nontrivial_capacity_obstruction_forces_nonrigidity
    {R : Type u} [CanonicallyOrderedCommSemiring R]
    (h : ∃ φ, IsClosureTwoCocycle φ ∧
         ¬ firstOrderEquivalent φ (zeroTwoCochain R)) :
    ¬ closure_rigidity R := ...
```

### 7. Theorems connecting to application semantics

Use these keywords explicitly in theorem names and doc comments.

Prove at least some precise application-facing theorems such as:

```lean
theorem quantum_capacity_obstruction_vanishes_under_rigidity
    {R : Type u} [CanonicallyOrderedCommSemiring R]
    (hRig : closure_rigidity R)
    (hCompat : ∀ φ f x y z,
      quantum_capacity_obstruction (φ + closure_d1 f) x y z =
      quantum_capacity_obstruction φ x y z) :
    ∀ φ, IsClosureTwoCocycle φ →
      ∃ f, ∀ x y z,
        quantum_capacity_obstruction (φ + closure_d1 f) x y z = 0 := ...
```

```lean
theorem post_quantum_security_zero_class_blocks_tropical_hash_collision
    {R : Type u} [CanonicallyOrderedCommSemiring R]
    (hRig : closure_rigidity R) :
    ∀ φ, IsClosureTwoCocycle φ →
      ∃ f, ∀ x y z,
        post_quantum_security_obstruction (φ + closure_d1 f) x y z = 0 := ...
```

```lean
theorem lipschitz_certified_robustness_from_zero_obstruction
    {R : Type u} [LinearOrderedCommSemiring R]
    (L : R) (hL : 0 ≤ L) :
    ∀ φ, (∀ x y z, quantum_capacity_obstruction φ x y z = 0) →
      lipschitz_certified_robustness_observable φ L := ...
```

Even if the semantics are toy-level, the formal pattern should clearly expose how algebraic rigidity controls physically/computationally meaningful observables.

### 8. Expected file architecture

Produce a substantial narrative, not isolated lemmas. A good architecture is:

- `ClosureSemiring/Deformation/Basic.lean`
  - structures, cochains, dual-like first-order algebra, 10+ lemmas
- `ClosureSemiring/Deformation/Rigidity.lean`
  - cocycles, coboundaries, equivalence, rigidity theorems
- `ClosureSemiring/Deformation/Capacity.lean`
  - quantitative obstructions, cost bounds, application semantics
- `ClosureSemiring/Deformation/ClosedPart.lean`
  - restriction to closed elements, closure-preserving endomorphisms

Each file should contain rich doc comments:
- `Bridge: connects Hochschild deformation theory to EML fixed-point semantics`
- `Bridge: connects closure rigidity to quantum capacity and post-quantum obstruction witnesses`
- `Bridge: connects tropical/idempotent algebra to certified robustness observables`

### 9. Minimum theorem list to ensure depth

Complete at least these 20 theorem-level items in some form:

1. `ClosureEnd.ext`
2. `ClosureTwoCochain.ext`
3. `zeroTwoCochain_is_cocycle`
4. `closure_d1_zero`
5. `closure_d1_add`
6. `dualMul_assoc_residual_formula`
7. `quantum_firstOrder_associativity_iff_cocycle`
8. `gaugeShift_zero`
9. `cryptographic_gauge_shift_changes_by_coboundary`
10. `firstOrderEquivalent_refl`
11. `firstOrderEquivalent_symm` (ring version if needed)
12. `firstOrderEquivalent_trans` (ring version if needed)
13. `thermodynamic_deformation_rigidity_of_H2_vanishes`
14. `deformation_triviality_implies_coboundary_witness`
15. `closure_preserving_endomorphism_induces_zero_obstruction`
16. `closure_cocycle_closed_output`
17. `closure_cocycle_descends_to_closed_part`
18. `cocycle_check_cost_cubic`
19. `post_quantum_security_obstruction_symmetric`
20. `lipschitz_certified_robustness_from_zero_obstruction`

Add several more supporting lemmas to comfortably exceed 10 theorems and 10 definitions.

### 10. Significance to the research program

This formalization matters because it creates a new bridge between:
- **Hochschild deformation theory** and **closure/idempotent semiring semantics**
- **EML fixed-point / condensation semantics** and **algebraic rigidity**
- **cohomological obstructions** and **computable quantitative certificates** relevant to
  **quantum capacity**, **post_quantum_security**, **tropical_hash_collision**, and
  **lipschitz_certified_robustness**

The breakthrough is not merely that a cohomology differential is formalized, but that low-degree cohomology becomes a **machine-checkable obstruction calculus** for semantics-preserving deformation of proof/closure systems. This opens the door to a full derived deformation package for semiring semantics, obstruction-controlled channel design, and eventually a certified algebraic language for robustness/cryptographic invariants.

### 11. If a full quotient `H²` is too heavy

Do not stall. Use the operational substitute:
- define cocycles,
- define coboundaries,
- define rigidity as “every cocycle admits a coboundary witness,”
- prove equivalence/trivialization theorems from that.

This is enough to establish the low-degree deformation-rigidity paradigm and is fully aligned with the target theorem.

### 12. Deliverable completion condition

A successful result contains:
- 10+ definitions / structures / instances,
- 20+ theorem statements with proofs,
- semiring and ring special cases,
- explicit quantitative cost bounds,
- explicit theorem names using application keywords,
- zero sorries,
- and a structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps such as:
  1. full quotient/setoid `Hⁿ` for closure semirings,
  2. spectral sequence from closure filtration,
  3. matrix/lattice instantiations for post-quantum semantics,
  4. tropical neural robustness semantics via idempotent cocycles,
  5. derived deformation stacks for proof-semiring channels.

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
            Develop a deformation theory for finitary EML closure systems by associating to each closure semiring of endomorphisms a Hochschild-style cochain complex whose 1-cocycles classify infinitesimal closure perturbations and whose 2-cocycles classify obstruction classes to extending local closure dynamics. Prove a rigidity principle: vanishing of the second cohomology forces formal rigidity of the induced EML semantics, while nonvanishing yields a computable obstruction spectrum controlling fixed-point multiplicity and semantic capacity jumps. This extends the successful Algebraic–EML spectral and Tannaka directions, but is distinct from current in-flight Stone–Čech, sheaf, thermodynamic, and phase-space programs because it studies deformation/cohomological invariants rather than representation/completion/dynamical reconstruction.

            ### Precise Mathematical Framing
            Let C be a finitary closure operator on a semiring-enriched algebra A, and let End_C(A) denote closure-preserving endomorphisms with composition and pointwise idempotent addition where available. Define C^n_C(A,M) as n-linear closure-compatible cochains into a bimodule M of semantic observables, with Hochschild differential restricted by closure-stability conditions. Prove: (1) d^2=0 and functoriality under closure-preserving semiring morphisms; (2) H^1_C classifies first-order semantic deformations modulo inner perturbations; (3) H^2_C is the obstruction space for extending first-order deformations to second order; (4) if H^2_C=0 then every infinitesimal EML deformation integrates uniquely up to equivalence; (5) obstruction classes bound jumps in prime-closure spectra and in coding capacity of proof/closure channels constructed from prior prime-spectrum semantics. Algorithmically, define a finite cochain truncation for finitely generated closure semirings and compute obstruction certificates by solving cocycle equations over idempotent semiring data. This opens a cohomological semantics program linking algebraic deformation theory, EML closure dynamics, and information-bearing proof systems.

            ### Lean 4 Sketch
Likely feasible by building on existing semiring, closure, endomorphism-monoid, and prime-spectrum infrastructure. Core formal objects: closure-preserving endomorphism subtype, semiring bimodule of observables, cochain complex, differential proof d_sq, equivalence relation on first-order deformations, and rigidity lemmas under H2 = 0. Initial formalization can target low degrees n<=2 for concrete rigidity/obstruction theorems before abstract derived package.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `knaster_tarski_closure_fixed_point` : theorem knaster_tarski_closure_fixed_point (f : H → H)
     (file: Bridges/EMLClosureCore.lean)
  2. `closure_fixed_points_are_iterative_invariants` : theorem closure_fixed_points_are_iterative_invariants {α : Type*}
     (file: Bridges/EntropyClosureSeparation.lean)
  3. `closure_has_least_fixed_point` : theorem closure_has_least_fixed_point {α : Type*} [CompleteLattice α]
     (file: Bridges/QuantumTropicalCore.lean)
  4. `entropy_bound_from_obstruction` : theorem entropy_bound_from_obstruction
     (file: Bridges/HomologicalDeepLearning.lean)
  5. `spectral_search_space_bound` : theorem spectral_search_space_bound (k : ℕ) : k < 2 ^ k :=
     (file: Bridges/ProofAlgGeomBridge.lean)

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



Recent successful concepts: Vector-Valued Ultrametric Neural Network Certification via Width-Free Operator Lipschitz Calculus, Arithmetic–Berkovich Cell Decomposition and Height-Sensitive Region Counting for Rational Operadic Networks, Berggren–Residual Automata Correspondence for Primitive Triple Languages and Orbit-Minimal Quantum Control


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
