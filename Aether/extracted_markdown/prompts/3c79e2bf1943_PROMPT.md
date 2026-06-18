

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

## VISIONARY BRIEF: Non-Archimedean Measure Theory — The Missing Foundation for Idempotent Probability

**Mode**: FORMALIZE  
**Target Files**: `AutoResearch/NonArchimedeanKolmogorov.lean`, `AutoResearch/MaxPlusRadonNikodym.lean`, `AutoResearch/CompactTropicalChoquetRadon.lean` (extend/closing existing sorry)

---

### WHY THIS OPENS A CIVILIZATION

Classical probability rests on three pillars: Kolmogorov extension (constructing stochastic processes), Radon-Nikodym (computing densities), and Choquet representation (decomposing functionals over extreme points). These three theorems, translated to the max-plus/idempotent setting, are the **missing measure-theoretic foundation** for Maslov dequantization, tropical information theory, and certified robustness of tropical neural networks. Without them, the existing catalog has tropical Shannon entropy without the stochastic processes that entropy measures, tropical functional analysis without the density theorem that makes integrals computable, and a sorry on `UCTropicalFunctional` that cannot be closed without Choquet representation. **This brief closes all three gaps simultaneously.**

---

### PILLAR 1: ULTRA-METRIC KOLMOGOROV EXTENSION — Constructing Non-Archimedean Stochastic Processes

**Key Insight**: In the max-plus setting, Kolmogorov extension is *dramatically simpler* than the classical case. Idempotent measures satisfy μ(⋃ᵢ Aᵢ) = ⊔ᵢ μ(Aᵢ) for *any* countable family — countable additivity is automatic from finite additivity plus idempotence. No Carathéodory extension theorem is needed. The projective limit is constructed directly on cylinder sets, and the extension is unique because cylinder sets generate the product σ-algebra and the measure is determined by its values on cylinders.

#### Definition 1: MaxPlusMeasureTarget

```lean
/-- The target space for max-plus measures. Bridge: connects order theory to
tropical analysis. The max-plus semiring ℝ ∪ {-∞} with max as addition
and + as multiplication. Instantiated by WithBot ℝ with appropriate operations. -/
class MaxPlusMeasureTarget (R : Type*) [CompleteLattice R] [AddCommMonoid R] where
  add_sup_left : ∀ a b c : R, a + (b ⊔ c) = (a + b) ⊔ (a + c)
  add_sup_right : ∀ a b c : R, (a ⊔ b) + c = (a + c) ⊔ (b + c)
  bot_add_absorb : ∀ r : R, ⊥ + r = ⊥
  add_bot_absorb : ∀ r : R, r + ⊥ = ⊥
  top_add : ∀ r : R, ⊤ + r = ⊤
  add_top : ∀ r : R, r + ⊤ = ⊤
```

#### Definition 2: MaxPlusMeasure

```lean
/-- An idempotent measure: μ(A ∪ B) = max(μ(A), μ(B)) for disjoint A, B.
Bridge: connects measure theory to tropical geometry. The normalization
μ(Set.univ) = 0 means the total mass equals the max-plus multiplicative unit. -/
structure MaxPlusMeasure (α : Type*) [MeasurableSpace α] where
  val : Set α → EReal
  val_empty : val ∅ = ⊥
  val_mono : ∀ ⦃s t : Set α⦄, s ⊆ t → val s ≤ val t
  val_union_disjoint : ∀ ⦃s t : Set α⦄, MeasurableSet s → MeasurableSet t →
    Disjoint s t → val (s ∪ t) = max (val s) (val t)
  val_univ : val Set.univ = 0
```

#### Definition 3: MaxPlusProbabilityMeasure

```lean
/-- A max-plus probability measure: idempotent measure with total mass 0
(the max-plus multiplicative identity). Bridge: connects probability theory
to idempotent analysis. Enables construction of non-Archimedean stochastic
processes via the Kolmogorov extension theorem. -/
structure MaxPlusProbabilityMeasure (α : Type*) [MeasurableSpace α] extends
    MaxPlusMeasure α where
  val_finite : ∀ ⦃A : Set α⦄, MeasurableSet A → val A > ⊥ → val A < ⊤
```

#### Definition 4: ProjectiveSystem

```lean
/-- A projective system of max-plus probability measures on measurable spaces
indexed by a directed poset. The compatibility condition
μ_i = (π_{ij})_* μ_j ensures consistency across projections.
Bridge: connects category theory (projective limits) to probability theory
(stochastic processes). -/
structure ProjectiveSystem {I : Type*} [Preorder I] [IsDirected I (· ≤ ·)]
    {X : I → Type*} [∀ i, MeasurableSpace (X i)]
    (π : ∀ ⦃i j⦄, i ≤ j → X j → X i)
    (π_comp : ∀ ⦃i j k⦄ (hij : i ≤ j) (hik : i ≤ k) (hjk : j ≤ k),
      π hij ∘ π hjk = π hik)
    (π_meas : ∀ ⦃i j⦄ (hij : i ≤ j), Measurable (π hij)) where
  μ : (i : I) → MaxPlusProbabilityMeasure (X i)
  compat : ∀ ⦃i j⦄ (hij : i ≤ j) (A : Set (X i)),
    MeasurableSet A → (μ j).val (π hij ⁻¹' A) = (μ i).val A
```

#### Definition 5: MaxPlusCylinderSet

```lean
/-- Cylinder set in the projective limit. C(A, i) = {x ∈ X : π_i(x) ∈ A}.
These generate the product σ-algebra and are the building blocks for the
Kolmogorov extension. -/
def maxPlusCylinderSet {I : Type*} [Preorder I] [IsDirected I (· ≤ ·)]
    {X : I → Type*} [∀ i, MeasurableSpace (X i)]
    {π : ∀ ⦃i j⦄, i ≤ j → X j → X i}
    (i : I) (A : Set (X i)) : Set (∀ i, X i) :=
  {x | x i ∈ A}
```

#### Main Theorem 1: maxplus_kolmogorov_extension

```lean
/-- The Ultra-Metric Kolmogorov Extension Theorem. Bridge: connects
probability theory to category theory and tropical geometry.
Every projective system of max-plus probability measures extends uniquely
to the projective limit. This is the non-Archimedean analogue of the
classical Kolmogorov extension theorem, but the proof is dramatically
simpler because idempotent measures automatically satisfy countable
additivity (no Carathéodory extension needed).

The uniqueness is crucial for tropical_certified_robustness_bound:
it guarantees that the max-plus stochastic process is well-defined,
enabling Lipschitz bounds for tropical neural networks with
certified robustness radius r* = margin / (2 · ‖dμ/dν‖_∞).

Computation time for evaluating μ on a cylinder set C(A,i): O(1)
after precomputing μ_i(A). -/
theorem maxplus_kolmogorov_extension {I : Type*} [Preorder I]
    [IsDirected I (· ≤ ·)] [Nonempty I]
    {X : I → Type*} [∀ i, MeasurableSpace (X i)]
    {π : ∀ ⦃i j⦄, i ≤ j → X j → X i}
    {π_comp : ∀ ⦃i j k⦄ (hij : i ≤ j) (hik : i ≤ k) (hjk : j ≤ k),
      π hij ∘ π hjk = π hik}
    {π_meas : ∀ ⦃i j⦄ (hij : i ≤ j), Measurable (π hij)}
    (sys : ProjectiveSystem π π_comp π_meas) :
    ∃! μ : MaxPlusProbabilityMeasure (∀ i, X i),
      ∀ ⦃i : I⦄ (A : Set (X i)) (hA : MeasurableSet A),
        μ.val (maxPlusCylinderSet i A) = (sys.μ i).val A := by
  -- PROOF STRATEGY (Cylinder Set Construction):
  -- Step 1: Define μ on cylinder sets: μ(C(A,i)) = μ_i(A)
  -- Step 2: Show well-definedness: if C(A,i) = C(B,j), then μ_i(A) = μ_j(B)
  --   using projective compatibility and directedness of I
  -- Step 3: Extend to the σ-algebra via μ(⋃ᵢ Aᵢ) = ⊔ᵢ μ(Aᵢ)
  --   This works because idempotent measures are automatically countably additive
  -- Step 4: Verify the MaxPlusMeasure axioms (monotonicity, disjoint union, normalization)
  -- Step 5: Uniqueness follows from the fact that cylinder sets generate the σ-algebra
  sorry  -- TO BE PROVED (this sorry should be eliminated in the actual proof)
```

**Proof Strategy A** (Cylinder Set Construction — RECOMMENDED):
1. Define `μ₀` on the algebra of cylinder sets: `μ₀(C(A,i)) = μ_i(A)`.
2. **Well-definedness lemma** (`maxPlusCylinderSet_welldefined`): If `C(A, i) = C(B, j)`, use directedness to find `k ≥ i, j` and show `μ_i(A) = μ_k(π_{ik}⁻¹(A)) = μ_k(π_{jk}⁻¹(B)) = μ_j(B)` by projective compatibility.
3. **Idempotent countable additivity** (`maxPlusMeasure_countable_union`): For any countable family of measurable sets, `μ(⋃ᵢ Aᵢ) = ⊔ᵢ μ(Aᵢ)`. This follows from finite additivity + idempotence by induction: `μ(A ∪ B) = max(μ(A), μ(B))` extends to countable unions by `⨆ᵢ μ(Aᵢ)`.
4. **Extension to σ-algebra** (`maxPlusCylinderSetExtension`): The cylinder set algebra generates the product σ-algebra. By idempotent countable additivity, the extension is unique and well-defined.
5. **Verification**: Check `val_empty`, `val_mono`, `val_union_disjoint`, `val_univ` for the extended measure.

**Proof Strategy B** (Direct Supremum Construction):
1. Define `μ = ⊔ᵢ (πᵢ)_* μᵢ` where `(πᵢ)_* μᵢ(A) = μᵢ(πᵢ(A ∩ πᵢ⁻¹(Xᵢ)))`.
2. Show this supremum exists in the lattice of max-plus measures (using `CompleteLattice` structure).
3. Verify pushforward property directly.
4. **Problem**: The supremum may not preserve the probability normalization `μ(X) = 0`. Strategy A avoids this issue.

**Strategy A is strongly recommended** because it's constructive, gives O(1) evaluation on cylinder sets, and avoids completeness issues.

---

### PILLAR 2: MAX-PLUS RADON-NIKODYM — Computing Sup-Derivatives for Idempotent Densities

#### Definition 6: MaxPlusAbsolutelyContinuous

```lean
/-- Max-plus absolute continuity: μ ≪_⊕ ν iff ν(A) = ⊥ implies μ(A) = ⊥.
Bridge: connects measure theory to tropical analysis. The max-plus condition
is strictly weaker than the classical one: it only constrains the "bottom"
(= impossible) events, not null sets. This is the foundation for
tropical_certified_robustness_bound computations. -/
def MaxPlusAbsolutelyContinuous {α : Type*} [MeasurableSpace α]
    (μ ν : MaxPlusMeasure α) : Prop :=
  ∀ ⦃A : Set α⦄, MeasurableSet A → ν.val A = ⊥ → μ.val A = ⊥
```

#### Definition 7: MaxPlusRadonNikodymDerivative

```lean
/-- The max-plus Radon-Nikodym derivative (sup-derivative). Bridge: connects
measure theory to tropical analysis. Unlike the classical RN derivative which
is a function dμ/dν satisfying μ = (dμ/dν) · ν, the max-plus derivative
satisfies μ(A) = ⊔_{x ∈ A} (dμ/dν(x) ⊗ ν({x})) where ⊗ is + (max-plus
multiplication). This is the computational key to tropical neural network
certified robustness: the Lipschitz constant of a tropical network is
‖dμ/dν‖_∞ = ⊔_x |dμ/dν(x)|.

Computational bound: evaluating dμ/dν at a point x costs O(1) after
precomputing μ({x}) and ν({x}). -/
structure MaxPlusRadonNikodymDerivative {α : Type*} [MeasurableSpace α]
    (μ ν : MaxPlusMeasure α) where
  deriv : α → EReal
  deriv_measurable : Measurable deriv
  deriv_integral_repr : ∀ ⦃A : Set α⦄, MeasurableSet A →
    μ.val A = ⨆ x ∈ A, deriv x + ν.val {x}
  deriv_unique_ae : ∀ ⦃f : α → EReal⦄, Measurable f →
    (∀ ⦃A : Set α⦄, MeasurableSet A → μ.val A = ⨆ x ∈ A, f x + ν.val {x}) →
    ν.val {x : α | deriv x ≠ f x} = ⊥
```

#### Definition 8: MaxPlusSigmaFinite

```lean
/-- A max-plus measure ν is σ-finite if the space is a countable union of
sets where ν is finite. Bridge: connects measure theory to idempotent analysis.
This is the regularity condition needed for the max-plus Radon-Nikodym theorem. -/
def MaxPlusSigmaFinite {α : Type*} [MeasurableSpace α]
    (ν : MaxPlusMeasure α) : Prop :=
  ∃ (s : ℕ → Set α), (∀ n, MeasurableSet (s n)) ∧
    (∀ n, ν.val (s n) > ⊥ ∧ ν.val (s n) < ⊤) ∧
    (⋃ n, s n) = Set.univ
```

#### Main Theorem 2: maxplus_radon_nikodym_sup_derivative

```lean
/-- The Max-Plus Radon-Nikodym Theorem. Bridge: connects measure theory to
tropical analysis and certified robustness. If μ is max-plus absolutely
continuous with respect to a σ-finite max-plus measure ν, then there exists
a unique (up to ν-a.e. equivalence) measurable sup-derivative dμ/dν satisfying
μ(A) = ⊔_{x∈A}(dμ/dν(x) ⊗ ν({x})) for all measurable A.

The sup-derivative is explicitly: dμ/dν(x) = μ({x}) - ν({x}) (max-plus
subtraction). This gives a direct O(1) formula for pointwise evaluation.

Application to tropical_certified_robustness_bound: If μ and ν are max-plus
measures representing two tropical network outputs, then the Lipschitz
constant of the network between these outputs is ‖dμ/dν‖_∞ ≤ C where
C = ⊔_x |μ({x}) - ν({x})|. This provides certified robustness with
computational cost O(n) for n-point domains. -/
theorem maxplus_radon_nikodym_sup_derivative {α : Type*} [MeasurableSpace α]
    [Countable α] [MeasurableSingletonClass α]
    (μ ν : MaxPlusMeasure α)
    (h_ac : MaxPlusAbsolutelyContinuous μ ν)
    (h_sigma_finite : MaxPlusSigmaFinite ν) :
    ∃ d : MaxPlusRadonNikodymDerivative μ ν, True := by
  -- PROOF STRATEGY:
  -- Step 1: Define the pointwise sup-derivative: d(x) = μ({x}) - ν({x})
  --   In max-plus arithmetic: d(x) = μ({x}) + (-ν({x}))
  --   where subtraction is defined as a - b when a ≥ b, and ⊥ otherwise
  -- Step 2: Show d is measurable (it's defined pointwise on atoms)
  -- Step 3: Prove the integral representation for singletons:
  --   μ({x}) = d(x) + ν({x}) by construction
  -- Step 4: Extend to finite sets by idempotent additivity:
  --   μ(A) = ⊔_{x ∈ A} μ({x}) = ⊔_{x ∈ A} (d(x) + ν({x}))
  --   This uses the key idempotent property μ(A) = ⊔_{x ∈ A} μ({x})
  -- Step 5: Extend to measurable sets by σ-finiteness and countable additivity
  -- Step 6: Prove uniqueness up to ν-a.e. equivalence
  sorry  -- TO BE PROVED
```

**Key Lemma** (maxplus_measure_atom_decomposition): For a countable measurable space with `MeasurableSingletonClass`, every max-plus measure satisfies `μ(A) = ⊔_{x ∈ A} μ({x})`. This is the idempotent analogue of the classical fact that a measure is determined by its values on atoms, and it's the crucial ingredient that makes the max-plus Radon-Nikodym theorem so much simpler than the classical one.

**Proof Strategy for the Key Lemma**:
1. For finite sets: `μ({x₁, ..., xₙ}) = max(μ({x₁}), ..., μ({xₙ}))` by repeated application of `val_union_disjoint` and idempotence.
2. For countable sets: `μ(⋃ᵢ {xᵢ}) = ⊔ᵢ μ({xᵢ})` by `maxPlusMeasure_countable_union`.
3. For general measurable sets: use σ-finiteness to reduce to countable unions of atoms.

---

### PILLAR 3: COMPACT CHOQUET REPRESENTATION — Closing the sorry on UCTropicalFunctional

This pillar directly extends the existing catalog file `AutoResearch/CompactTropicalChoquetRadon.lean` and closes the sorry on `UCTropicalFunctional`.

#### Definition 9: ShiftEquivariantTropicalFunctional

```lean
/-- A shift-equivariant, sup-preserving, monotone functional on compact
idempotent function spaces. Bridge: connects functional analysis to tropical
geometry and statistical mechanics. Shift-equivariance Φ(f ⊕ c) = Φ(f) ⊕ c
is the idempotent analogue of translation invariance in classical analysis.
Sup-preservation Φ(⊔ᵢ fᵢ) = ⊔ᵢ Φ(fᵢ) is the idempotent analogue of
linearity. Together, they characterize "tropical linear functionals". -/
structure ShiftEquivariantTropicalFunctional (K : Type*) [TopologicalSpace K]
    [CompactSpace K] where
  val : (K → EReal) → EReal
  shift_equiv : ∀ (f : K → EReal) (c : EReal), val (fun x => max (f x) c) = max (val f) c
  sup_preserve : ∀ (s : ℕ → K → EReal), val (fun x => ⊔ n, s n x) = ⊔ n, val (s n)
  mono : ∀ ⦃f g : K → EReal⦄, (∀ x, f x ≤ g x) → val f ≤ val g
```

#### Definition 10: IdempotentIntegral

```lean
/-- The Maslov (idempotent) integral of a function with respect to a
max-plus measure. Bridge: connects integration theory to tropical geometry.
∫^⊕ f dμ = ⊔_{x ∈ K} (f(x) ⊗ μ({x})) = ⊔_{x ∈ K} (f(x) + μ({x})).
This is the tropical analogue of the Lebesgue integral.

Computational bound: For a finite support measure on n points,
evaluation costs O(n). For compact K with Lipschitz f, approximation
to ε-precision costs O((Lip(f)/ε)^d) where d = dim(K). -/
def idempotentIntegral {K : Type*} [TopologicalSpace K] [MeasurableSpace K]
    [MeasurableSingletonClass K]
    (f : K → EReal) (μ : MaxPlusMeasure K) : EReal :=
  ⨆ x : K, f x + μ.val {x}
```

#### Definition 11: ExtremeMaxPlusMeasure

```lean
/-- An extreme max-plus measure: one that cannot be written as a max-plus
convex combination of two distinct max-plus measures. Bridge: connects
convex geometry to tropical analysis. In the classical setting, extreme
measures are point masses. In the max-plus setting, extreme measures are
"generalized point evaluations" that may have non-trivial support but
cannot be decomposed further. -/
def IsExtremeMaxPlusMeasure {K : Type*} [TopologicalSpace K] [CompactSpace K]
    [MeasurableSpace K]
    (μ : MaxPlusMeasure K) (Φ : ShiftEquivariantTropicalFunctional K) : Prop :=
  ∀ ⦃μ₁ μ₂ : MaxPlusMeasure K⦄,
    (∀ (f : K → EReal), idempotentIntegral f μ₁ ≤ idempotentIntegral f μ) →
    (∀ (f : K → EReal), idempotentIntegral f μ₂ ≤ idempotentIntegral f μ) →
    (∀ (f : K → EReal), idempotentIntegral f μ = max (idempotentIntegral f μ₁) (idempotentIntegral f μ₂)) →
    μ₁ = μ ∨ μ₂ = μ
```

#### Main Theorem 3: compact_choquet_idempotent_representation

```lean
/-- The Compact Choquet Representation Theorem for Idempotent Function Spaces.
Bridge: connects functional analysis (Choquet theory) to tropical geometry
(idempotent semirings) to statistical mechanics (variational principles).

Every shift-equivariant, sup-preserving, monotone tropical functional Φ on
a compact space K decomposes as a max-plus integral over the extreme measures
representing Φ:

  Φ(f) = ⊔_{μ ∈ Ext(Φ)} ∫^⊕ f dμ

This is the tropical analogue of the classical Choquet representation theorem
and directly closes the sorry on UCTropicalFunctional in
AutoResearch/CompactTropicalChoquetRadon.lean.

The extreme measures are precisely the "tropical point evaluations" —
max-plus analogues of Dirac measures that capture the essential structure
of the functional.

Application to tropical_certified_robustness_bound: The decomposition gives
Φ(f) = ⊔_{μ ∈ Ext(Φ)} ⊔_{x ∈ K}(f(x) + μ({x})), which is a max-plus
linear combination of point evaluations. For a tropical neural network layer,
this means every shift-equivariant layer decomposes as a max-plus combination
of at most |Ext(Φ)| point evaluations, giving a certified robustness bound
with Lipschitz constant max_{μ ∈ Ext(Φ)} ⊔_x |μ({x})| ≤ C. -/
theorem compact_choquet_idempotent_representation {K : Type*}
    [TopologicalSpace K] [CompactSpace K] [MeasurableSpace K]
    [MeasurableSingletonClass K] [T2Space K]
    (Φ : ShiftEquivariantTropicalFunctional K) :
    ∃ (E : Set (MaxPlusMeasure K)) (hE_finite : E.Finite)
      (hE_extreme : ∀ μ ∈ E, IsExtremeMaxPlusMeasure μ Φ),
      ∀ (f : K → EReal) (hf : Continuous f),
        Φ.val f = ⨆ μ ∈ E, idempotentIntegral f μ := by
  -- PROOF STRATEGY (Extreme Point Decomposition):
  -- Step 1: Define the representing set M_Φ = {μ : MaxPlusMeasure K |
  --   ∀ f, idempotentIntegral f μ ≤ Φ.val f}
  -- Step 2: Show M_Φ is nonempty (the zero measure is in M_Φ)
  -- Step 3: Show M_Φ is compact in the weak-* topology
  --   (using compactness of K and continuity of Φ)
  -- Step 4: Apply the idempotent Krein-Milman theorem:
  --   M_Φ = hull(Ext(M_Φ)) where the hull is the max-plus convex hull
  -- Step 5: Show that Φ achieves its minimum on M_Φ, giving the decomposition
  -- Step 6: Prove finiteness of Ext(M_Φ) using compactness and shift-equivariance
  sorry  -- TO BE PROVED
```

**Proof Strategy A** (Extreme Point Decomposition — RECOMMENDED):
1. Define `M_Φ = {μ : MaxPlusMeasure K | ∀ f, idempotentIntegral f μ ≤ Φ.val f}`.
2. **Non-emptiness** (`representingSet_nonempty`): The measure `μ₀` with `μ₀(A) = ⊥` for all `A ≠ Set.univ` and `μ₀(Set.univ) = 0` is in `M_Φ`.
3. **Compactness** (`representingSet_compact`): `M_Φ` is closed in the product topology on `EReal^(Set K)`, which is compact by Tychonoff's theorem (restricted to the relevant subset).
4. **Idempotent Krein-Milman** (`idempotentKreinMilman`): Every compact subset of a max-plus convex space equals the max-plus convex hull of its extreme points. This is proved by showing that if `μ ∈ M_Φ` is not extreme, then `μ = max(μ₁, μ₂)` for some `μ₁, μ₂ ∈ M_Φ`, and iterating this decomposition until reaching extreme points (which terminates by compactness).
5. **Decomposition** (`choquet_decomposition`): For any `f`, `Φ.val f = ⊔_{μ ∈ Ext(M_Φ)} idempotentIntegral f μ`. This follows from the fact that `Φ.val f` is the supremum of `idempotentIntegral f μ` over `μ ∈ M_Φ`, and this supremum is achieved at extreme points.
6. **Finiteness** (`extremeSet_finite`): `Ext(M_Φ)` is finite because `K` is compact and `Φ` is shift-equivariant, so the extreme measures are determined by finitely many "critical points" where `Φ` achieves its maximum.

**Proof Strategy B** (Direct Construction via Evaluation Functionals):
1. For each `x ∈ K`, define `δ_x : MaxPlusMeasure K` by `δ_x(A) = 0` if `x ∈ A`, `δ_x(A) = ⊥` otherwise.
2. Show that `Φ.val f = ⊔_{x ∈ K} (f(x) + c_x)` for some function `c_x = Φ.val(δ_x)`.
3. The set `{x : K | c_x > ⊥}` is finite (by compactness and shift-equivariance).
4. The extreme measures are `μ_x = δ_x + c_x` (shifted Dirac measures).
5. **Problem**: This only works for "simple" functionals. Strategy A is more general.

**Proof Strategy C** (Reduction to Existing sorry via AlgebraicHypothesisClass):
1. Build on `AlgebraicHypothesisClass` from the catalog to define the class of functionals that admit Choquet representation.
2. Use `log_compression_principle` to show that shift-equivariant functionals compress to extreme representations.
3. Close the sorry on `UCTropicalFunctional` by showing it satisfies the `AlgebraicHypothesisClass` conditions.
4. **This strategy directly uses catalog infrastructure** and is recommended for closing the existing sorry.

---

### SUPPORTING LEMMAS AND DEFINITIONS (10+ theorems required for rigor)

#### Lemma Chain for Pillar 1 (Kolmogorov Extension)

```lean
/-- Cylinder sets are measurable. -/
theorem maxPlusCylinderSet_measurable {I : Type*} [Preorder I]
    [IsDirected I (· ≤ ·)] [Nonempty I]
    {X : I → Type*} [∀ i, MeasurableSpace (X i)]
    (i : I) (A : Set (X i)) (hA : MeasurableSet A) :
    MeasurableSet (maxPlusCylinderSet i A) := by
  -- Direct from MeasurableSpace definition and π_meas
  sorry

/-- Cylinder set values are well-defined: compatible measures agree. -/
theorem maxPlusCylinderSet_welldefined {I : Type*} [Preorder I]
    [IsDirected I (· ≤ ·)] [Nonempty I]
    {X : I → Type*} [∀ i, MeasurableSpace (X i)]
    {π : ∀ ⦃i j⦄, i ≤ j → X j → X i}
    {π_comp : ∀ ⦃i j k⦄ (hij : i ≤ j) (hik : i ≤ k) (hjk : j ≤ k),
      π hij ∘ π hjk = π hik}
    {π_meas : ∀ ⦃i j⦄ (hij : i ≤ j), Measurable (π hij)}
    (sys : ProjectiveSystem π π_comp π_meas)
    {i j : I} (A : Set (X i)) (B : Set (X j))
    (hA : MeasurableSet A) (hB : MeasurableSet B)
    (h_eq : maxPlusCylinderSet i A = maxPlusCylinderSet j B) :
    (sys.μ i).val A = (sys.μ j).val B := by
  -- Use directedness to find k ≥ i, j, then use projective compatibility
  sorry

/-- Idempotent measures satisfy countable "additivity" (sup-union). -/
theorem maxPlusMeasure_countable_union {α : Type*} [MeasurableSpace α]
    (μ : MaxPlusMeasure α) (s : ℕ → Set α)
    (hs : ∀ n, MeasurableSet (s n)) (hs_disjoint : Pairwise (Disjoint on s)) :
    μ.val (⋃ n, s n) = ⨆ n, μ.val (s n) := by
  -- Key: finite additivity + idempotence implies countable additivity
  -- μ(⋃_{i<n} s_i) = max_{i<n} μ(s_i) by induction
  -- Take supremum over n
  sorry

/-- The Kolmogorov extension is unique on the product σ-algebra. -/
theorem maxplus_kolmogorov_extension_unique {I : Type*} [Preorder I]
    [IsDirected I (· ≤ ·)] [Nonempty I]
    {X : I → Type*} [∀ i, MeasurableSpace (X i)]
    {π : ∀ ⦃i j⦄, i ≤ j → X j → X i}
    {π_comp : ∀ ⦃i j k⦄ (hij : i ≤ j) (hik : i ≤ k) (hjk : j ≤ k),
      π hij ∘ π hjk = π hik}
    {π_meas : ∀ ⦃i j⦄ (hij : i ≤ j), Measurable (π hij)}
    (sys : ProjectiveSystem π π_comp π_meas)
    (μ₁ μ₂ : MaxPlusProbabilityMeasure (∀ i, X i))
    (h₁ : ∀ ⦃i : I⦄ (A : Set (X i)) (hA : MeasurableSet A),
      μ₁.val (maxPlusCylinderSet i A) = (sys.μ i).val A)
    (h₂ : ∀ ⦃i : I⦄ (A : Set (X i)) (hA : MeasurableSet A),
      μ₂.val (maxPlusCylinderSet i A) = (sys.μ i).val A) :
    μ₁ = μ₂ := by
  -- Cylinder sets generate the σ-algebra, and μ₁, μ₂ agree on cylinders
  sorry
```

#### Lemma Chain for Pillar 2 (Radon-Nikodym)

```lean
/-- Max-plus measures on countable spaces decompose as suprema over atoms. -/
theorem maxPlusMeasure_atom_decomposition {α : Type*} [Countable α]
    [MeasurableSpace α] [MeasurableSingletonClass α]
    (μ : MaxPlusMeasure α) (A : Set α) (hA : MeasurableSet A) :
    μ.val A = ⨆ x ∈ A, μ.val {x} := by
  -- Countable union of singletons + idempotent countable additivity
  sorry

/-- Pointwise sup-derivative formula. -/
theorem maxPlusRadonNikodymDerivative_pointwise {α : Type*} [Countable α]
    [MeasurableSpace α] [MeasurableSingletonClass α]
    (μ ν : MaxPlusMeasure α) (x : α)
    (h_ac : MaxPlusAbsolutelyContinuous μ ν)
    (h_nu_atom : ν.val {x} > ⊥) :
    (MaxPlusRadonNikodymDerivative.deriv
      (maxplus_radon_nikodym_sup_derivative μ ν h_ac
        (maxPlusSigmaFinite_of_countable ν)).choose).choose x =
      μ.val {x} - ν.val {x} := by
  -- The sup-derivative at x is μ({x}) - ν({x}) by definition
  sorry

/-- MaxPlus sigma-finiteness for countable spaces. -/
theorem maxPlusSigmaFinite_of_countable {α : Type*} [Countable α]
    [MeasurableSpace α] (ν : MaxPlusMeasure α) :
    MaxPlusSigmaFinite ν := by
  -- Take s n = {a_n} where (a_n) enumerates α
  sorry
```

#### Lemma Chain for Pillar 3 (Choquet Representation)

```lean
/-- Shift-equivariant functionals are determined by their values on
Dirac measures. Bridge: connects tropical geometry to functional analysis. -/
theorem shiftEquivariant_determined_by_dirac {K : Type*}
    [TopologicalSpace K] [CompactSpace K] [MeasurableSpace K]
    [MeasurableSingletonClass K] [T2Space K]
    (Φ : ShiftEquivariantTropicalFunctional K)
    (f : K → EReal) (hf : Continuous f) :
    Φ.val f = ⨆ x : K, f x + Φ.val (fun y => if y = x then (0 : EReal) else ⊥) := by
  -- Key: f = ⊔_x (f(x) ⊕ δ_x) where δ_x is the Dirac function at x
  -- Apply shift-equivariance and sup-preservation
  sorry

/-- The representing set is compact in the weak-* topology. -/
theorem representingSet_compact {K : Type*}
    [TopologicalSpace K] [CompactSpace K] [MeasurableSpace K]
    [MeasurableSingletonClass K] [T2Space K]
    (Φ : ShiftEquivariantTropicalFunctional K) :
    IsCompact {μ : MaxPlusMeasure K | ∀ f, idempotentIntegral f μ ≤ Φ.val f} := by
  -- Closed subset of a compact space (product of compact intervals)
  sorry

/-- Idempotent Krein-Milman: compact convex sets in max-plus are hulls of extremes. -/
theorem idempotentKreinMilman {K : Type*}
    [TopologicalSpace K] [CompactSpace K] [MeasurableSpace K]
    [MeasurableSingletonClass K] [T2Space K]
    (S : Set (MaxPlusMeasure K)) (hS_compact : IsCompact S)
    (hS_convex : MaxPlusConvex S) :
    S = MaxPlusConvexHull (MaxPlusExtremePoints S) := by
  -- Idempotent version: every point in a compact max-plus convex set
  -- is a max-plus convex combination of extreme points
  sorry

/-- The extreme set of a shift-equivariant functional is finite. -/
theorem extremeSet_finite_of_shiftEquivariant {K : Type*}
    [TopologicalSpace K] [CompactSpace K] [MeasurableSpace K]
    [MeasurableSingletonClass K] [T2Space K]
    (Φ : ShiftEquivariantTropicalFunctional K) :
    (Set.filter (fun μ => IsExtremeMaxPlusMeasure μ Φ)
      {μ : MaxPlusMeasure K | ∀ f, idempotentIntegral f μ ≤ Φ.val f}).Finite := by
  -- Compactness + shift-equivariance implies finitely many extreme points
  sorry
```

---

### CROSS-DOMAIN CONNECTIONS AND APPLICATION IMPACT

**1. Tropical Certified Robustness for Neural Networks** (ML → Measure Theory):
The Radon-Nikodym sup-derivative `dμ/dν` gives the **Lipschitz constant** for tropical neural network layers. If two input distributions `μ, ν` have `‖dμ/dν‖_∞ ≤ C`, then the tropical network has **certified robustness radius** `r* = margin / (2C)`. This is a quantitative, computable bound: evaluating `dμ/dν(x)` costs O(1) per point, so the total certification cost is O(n) for n-point domains. Theorem name: `tropical_certified_robustness_bound`.

**2. Maslov Dequantization Convergence** (Physics → Probability):
Classical probability measures `μ_h` with parameter `h > 0` converge to max-plus measures as `h → 0` via the Maslov dequantization: `μ_h(A) = h · log(∫_A exp(f/h) dν) → max_{x ∈ A} f(x)` as `h → 0`. The Kolmogorov extension theorem for max-plus measures is the `h = 0` limit of the classical Kolmogorov extension, opening the door to **non-Archimedean quantum mechanics** where the path integral is a max-plus integral. Theorem name: `maslov_dequantization_convergence_rate`.

**3. Post-Quantum Lattice Cryptography** (Cryptography → Measure Theory):
Max-plus measures on lattices give rise to "tropical distributions" that are computationally hard to distinguish from uniform. The Radon-Nikodym derivative provides a quantitative measure of this hardness: if `dμ/dν` is close to `0` (the max-plus multiplicative identity), then `μ` and `ν` are "tropically indistinguishable," which connects to the **Shortest Vector Problem** in lattice-based post-quantum cryptography. Theorem name: `post_quantum_lattice_distinguisher_bound`.

**4. Idempotent Free Energy Variational Principle** (Statistical Mechanics → Tropical Geometry):
The Choquet representation gives a **variational principle** for max-plus statistical mechanics: the max-plus free energy `F_⊕(Φ) = Φ(-H)` (where `H` is the Hamiltonian) satisfies `F_⊕(Φ) = ⊔_{μ ∈ Ext(Φ)} F_⊕(μ)`. This is the tropical analogue of the classical variational principle `F = min_μ F(μ)`, with `min` replaced by `max` and addition by `+`. Theorem name: `idempotent_free_energy_variational`.

---

### DELIVERABLES

1. **`AutoResearch/NonArchimedeanKolmogorov.lean`** (500+ lines): Definitions `MaxPlusMeasure`, `MaxPlusProbabilityMeasure`, `ProjectiveSystem`, `MaxPlusCylinderSet`; theorems `maxPlusCylinderSet_measurable`, `maxPlusCylinderSet_welldefined`, `maxPlusMeasure_countable_union`, `maxPlusMeasure_atom_decomposition`, `maxplus_kolmogorov_extension`, `maxplus_kolmogorov_extension_unique`. All proofs complete, zero sorries.

2. **`AutoResearch/MaxPlusRadonNikodym.lean`** (500+ lines): Definitions `MaxPlusAbsolutelyContinuous`, `MaxPlusRadonNikodymDerivative`, `MaxPlusSigmaFinite`; theorems `maxPlusSigmaFinite_of_countable`, `maxPlusRadonNikodymDerivative_pointwise`, `maxplus_radon_nikodym_sup_derivative`, `tropical_certified_robustness_bound` (connecting the sup-derivative norm to Lipschitz constants). All proofs complete, zero sorries.

3. **`AutoResearch/CompactTropicalChoquetRadon.lean`** (extend existing, 300+ new lines): Definitions `ShiftEquivariantTropicalFunctional`, `IdempotentIntegral`, `IsExtremeMaxPlusMeasure`; theorems `shiftEquivariant_determined_by_dirac`, `representingSet_compact`, `idempotentKreinMilman`, `extremeSet_finite_of_shiftEquivariant`, `compact_choquet_idempotent_representation` (closing the sorry on `UCTropicalFunctional`). All proofs complete, zero sorries.

4. **`FUTURE_DIRECTIONS.md`**: Three concrete, breakthrough-level next steps:
   - (a) **Maslov dequantization convergence**: Prove that classical probability measures converge to max-plus measures at rate `O(h · log(1/h))` as `h → 0`, establishing the `h = 0` limit as the non-Archimedean stochastic process.
   - (b) **Tropical mutual information**: Define max-plus mutual information `I_⊕(X;Y) = H_⊕(X) + H_⊕(Y) - H_⊕(X,Y)` and prove the max-plus data processing inequality, enabling certified robustness bounds for tropical neural networks via information-theoretic arguments.
   - (c) **Post-quantum lattice distinguisher**: Prove that distinguishing a max-plus measure from uniform on a lattice `Λ ⊂ ℝ^n` requires `Ω(2^n)` samples, connecting to the hardness of the Shortest Vector Problem and establishing post-quantum security for tropical hash functions.

---

### PROOF TACTIC DIVERSITY REQUIREMENT

The 10+ theorems must use diverse tactics:
- **`induction`**: For `maxPlusMeasure_countable_union` (induction on finite unions)
- **`rcases`**: For `maxPlusCylinderSet_welldefined` (case split on the directed index)
- **`by_contra`**: For `representingSet_compact` (contradiction from non-compactness)
- **`omega`**: For `extremeSet_finite_of_shiftEquivariant` (arithmetic on measure values)
- **`linarith`**: For `tropical_certified_robustness_bound` (Lipschitz bound computation)
- **`field_simp`**: For `maxPlusRadonNikodymDerivative_pointwise` (algebraic manipulation of the sup-derivative)
- **`simp`** and **`rfl`**: For basic equalities (but NOT as the primary tactic)
- **Custom `conv`/`ring`**: For max-plus arithmetic identities

### TYPECLASS ABSTRACTION REQUIREMENT

Use `[Semiring R]` or `[LinearOrder R]` or `[CompleteLattice R]` as appropriate, not concrete types. The `MaxPlusMeasureTarget` typeclass should be abstract enough to support `WithBot ℝ`, `WithBot ℚ`, and other idempotent semirings.

### QUANTIFIER ALTERNATION REQUIREMENT

Every main theorem must have `∀`-`∃` alternation:
- `maxplus_kolmogorov_extension`: `∀ projective_system, ∃! measure, ∀ cylinder, ...`
- `maxplus_radon_nikodym_sup_derivative`: `∀ measures, ∀ absolutely_continuous, ∃ derivative, ∀ set, ...`
- `compact_choquet_idempotent_representation`: `∀ functional, ∃ extreme_set, ∀ function, ...`

---

**This is the measure-theoretic foundation that makes tropical probability theory possible. Prove it.**

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
            Open the field of non-Archimedean probability theory by proving three foundational results: (1) An ultra-metric Kolmogorov extension theorem establishing that projective systems of max-plus probability measures extend uniquely to the projective limit, enabling construction of non-Archimedean stochastic processes — the measure-theoretic prerequisite that the prior Tropical Shannon Theory work lacked; (2) A max-plus Radon-Nikodym theorem characterizing max-plus absolute continuity via sup-derivatives: for σ-finite idempotent measures μ ≪_𝕋 ν, there exists a unique max-plus density dμ/dν satisfying μ(A) = sup_{x∈A}(dμ/dν(x) + ν({x})) for all measurable A; (3) A compact Choquet representation theorem for idempotent function spaces, closing the existing sorry on UCTropicalFunctional (AutoResearch/CompactTropicalChoquetRadon.lean) and proving that every shift-equivariant, sup-preserving, monotone tropical functional on a compact idempotent semialgebra decomposes as a max-plus integral over extreme points. These three theorems form the measure-theoretic foundation for non-Archimedean statistics, enabling certified robustness bounds for tropical neural networks via information-theoretic arguments and Maslov dequantization convergence for stochastic processes.

            ### Precise Mathematical Framing
            Let 𝕋 = (ℝ ∪ {-∞}, max, +) be the tropical semiring. A max-plus probability space is (X, Σ, μ) where μ: Σ → ℝ is max-additive (μ(A ∪ B) = max(μ(A), μ(B))) with μ(X) = 0 in log-coordinates. Theorem 1 (Ultra-Metric Kolmogorov Extension): For a projective system {(X_i, Σ_i, μ_i)}_{i∈I} of max-plus probability spaces with compatible projections π_{ij}: X_j → X_i satisfying μ_i = μ_j ∘ π_{ij}^{-1}, there exists a unique max-plus measure μ on the projective limit lim← X_i extending each μ_i, with convergence guaranteed by ultra-metric completeness. Theorem 2 (Max-Plus Radon-Nikodym): If μ ≪_𝕋 ν (meaning ν(A) = -∞ ⟹ μ(A) = -∞), then there exists a unique 𝕋-measurable function f = dμ/dν such that μ(A) = sup_{x∈A}(f(x) + ν({x})), and this sup-derivative is characterized by f(x) = μ({x}) - ν({x}) at atoms. Theorem 3 (Compact Choquet Representation): Every compact tropical functional Φ ∈ UCTropicalFunctional(𝒜) decomposes as Φ(f) = sup_{φ ∈ Ext(𝒜^*)}(φ(f) + c_Φ(φ)) where Ext(𝒜^*) denotes extreme tropical characters and c_Φ is the Choquet coefficient function, closing the sorry on UCTropicalFunctional by constructing the representation explicitly.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `exists_least_bisimulation_metric_finite` : theorem exists_least_bisimulation_metric_finite
     (file: Bridges/BisimulationMetric.lean)
  2. `tropical_max_idempotent` : theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_self x
     (file: Bridges/BreakthroughDirections.lean)
  3. `gl3_tropical_satake_certified_robustness` : theorem gl3_tropical_satake_certified_robustness
     (file: Bridges/TropicalSatakeRobustness.lean)
  4. `analysis_bridge_unique_limit` : theorem analysis_bridge_unique_limit {X : Type*} [TopologicalSpace X] [T2Space X]
     (file: Bridges/CategoricalBridges.lean)
  5. `exists_finite_separating_map` : theorem exists_finite_separating_map (C : Set σ → Set σ) (hC : IsClosureOp C)
     (file: Bridges/ClosureProofSemiring.lean)

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



Recent successful concepts: Tropical Certified Robustness: Max-Plus Spectral Composition and Layerwise Verification Bounds for Deep Networks, Provability Spectral Theory: Löb Fixed-Point Lattices, Modal Eigenvalue Decomposition, and Stone Duality for EML Closure Self-Models, Algebraic Learning Theory: Module-Theoretic VC Dimension, Spectral Rademacher Decomposition, and Certified Generalization over Algebraic Structures


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
            @AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```

@AutoResearch/CompactRiesz.lean
```lean
import Bridges.TropicalFunctional.Basic
import Bridges.TropicalFunctional.Capacity
import Bridges.TropicalFunctional.FiniteRiesz

/-!
# Compact-Space Tropical Riesz Theory

This file develops the tropical Riesz representation theory for compact Hausdorff spaces,
building on the finite discrete case.

## Main results

- `TropSubsemialgebra`: tropical subsemialgebras of `TropCont X`
- `tropical_functional_ext_of_dense`: if two tropical functionals agree on a dense
  subsemialgebra, they are equal (requires an upper-continuity hypothesis)
- `tropical_riesz_compact_eval`: evaluation functionals are tropical functionals

## Mathematical significance

The extensionality theorem says that a tropical functional on a compact Hausdorff space
is uniquely determined by its values on any dense tropical subsemialgebra. Combined with
the Stone–Weierstrass approximation theorem for max-plus algebras, this establishes
that the "states" on a tropical function algebra are geometric objects (maxitive measures).
-/

noncomputable section

variable {X : Type*} [TopologicalSpace X]

/-! ## Tropical subsemialgebra -/

/-- A tropical subsemialgebra of `TropCont X`: a set of continuous functions closed under
pointwise sup (tropical addition), containing all constants, and closed under additive
translation (tropical scalar multiplication). -/
structure TropSubsemialgebra (X : Type*) [TopologicalSpace X] where
  /-- The carrier set. -/
  carrier : Set (TropCont X)
  /-- Closed under pointwise sup. -/
  sup_mem' : ∀ {f g}, f ∈ carrier → g ∈ carrier →
    TropCont.tsup f g ∈ carrier
  /-- Contains all constant functions. -/
  const_mem' : ∀ c : WithBot ℝ, ContinuousMap.const _ c ∈ carrier

/-! ## Evaluation functionals -/

/-- Evaluation at a point `x₀` is a tropical functional.
This is the tropical analogue of the Dirac measure at `x₀`. -/
def evalTropicalFunctional [CompactSpace X] [T2Space X] (x₀ : X) :
    TropicalFunctional X where
  toFun f := f x₀
  map_sup' f g := rfl
  map_const' c := rfl
  map_addConst' c f g hfg := by simp [hfg x₀]
  monotone' h := h x₀

/-- Evaluation at `x₀` applied to the basis function at `x₀` returns `0`. -/
theorem eval_tropBasis_self [Fintype X] [DecidableEq X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X] (x₀ : X) :
    (evalTropicalFunctional x₀).toFun (tropBasis x₀) = 0 := by
  simp [evalTropicalFunctional, tropBasis]

/-! ## Finite-space evaluation reconstruction -/

/-
On a finite discrete space, evaluation at `x₀` has weight function `δ_{x₀}`.
That is, the tropical measure corresponding to evaluation at `x₀` is the tropical
Dirac delta.
-/
theorem eval_deltaWeight [Fintype X] [DecidableEq X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X] (x₀ x : X) :
    deltaWeight (evalTropicalFunctional x₀) x = if x = x₀ then 0 else ⊥ := by
  cases eq_or_ne x x₀ <;> simp_all +decide [deltaWeight, evalTropicalFunctional]
  exact tropBasis_apply_ne (Ne.symm ‹_ ≠ _›)

/-- The representation formula for evaluation functionals on finite spaces:
`f(x₀) = sup_x (δ_{x₀}(x) + f(x))`, which is immediate from the Riesz theorem. -/
theorem eval_representation [Fintype X] [DecidableEq X] [Nonempty X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X]
    (x₀ : X) (f : TropCont X) :
    f x₀ = Finset.univ.sup (fun x => deltaWeight (evalTropicalFunctional x₀) x + f x) := by
  exact finite_representation_formula (evalTropicalFunctional x₀) f

/-! ## Upper-continuous tropical functional -/

/-- An upper-continuous tropical functional: if a monotone sequence of functions converges
pointwise, the functional values converge. This is the tropical analogue of the
monotone convergence theorem. -/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    extends TropicalFunctional X where
  /-- Upper continuity: commutes with directed suprema of monotone sequences. -/
  upper_continuous' :
    ∀ {f : ℕ → TropCont X} {g : TropCont X},
      Monotone f →
      (∀ x, Filter.Tendsto (fun n => f n x) Filter.atTop (nhds (g x))) →
      Filter.Tendsto (fun n => toFun (f n)) Filter.atTop (nhds (toFun g))

/-! ## Functional extensionality from density -/

/-- **Tropical functional extensionality from density.**
If two upper-continuous tropical functionals agree on all functions in a dense
tropical subsemialgebra, they agree on all continuous functions. This is the
key uniqueness principle for the tropical Riesz representation.

*Proof idea*: For any `f : TropCont X`, the density of `A` provides a sequence
of functions in `A` converging to `f`. By upper continuity of both functionals,
the functional values converge, and since they agree on `A`, they agree on `f`. -/
theorem tropical_functional_ext_of_dense
    [CompactSpace X] [T2Space X]
    (A : TropSubsemialgebra X)
    (h_dense : Dense A.carrier)
    (Λ₁ Λ₂ : UCTropicalFunctional X)
    (h_eq : ∀ f : TropCont X, f ∈ A.carrier → Λ₁.toFun f = Λ₂.toFun f) :
    Λ₁.toFun = Λ₂.toFun := by
  -- This requires converting density in the compact-open topology to monotone
  -- approximation sequences, then using upper_continuous' to pass to limits.
  -- Full proof requires substantial infrastructure around function space topologies.
  sorry

/-! ## Capacity from functional -/

/-- The canonical measure (maxitive capacity) on compact sets, derived from a tropical
functional. For each compact set `K`, this is the infimum of `Λ(f)` over all
continuous functions that dominate the tropical indicator of `K`. -/
def μ_from_Λ [CompactSpace X] (Λ : TropicalFunctional X) (K : Set X) : WithBot ℝ :=
  muK Λ K

/-
The capacity derived from an evaluation functional at `x₀` assigns `0` to
any compact set containing `x₀`, and `⊥` to sets not containing `x₀`.
-/
theorem μ_from_eval_mem [CompactSpace X] [T2Space X] (x₀ : X)
    (K : Set X) (_hK : IsCompact K) (_hx : x₀ ∈ K) :
    μ_from_Λ (evalTropicalFunctional x₀) K ≤ 0 := by
  refine' csInf_le _ _;
  · exact ⟨ ⊥, Set.forall_mem_image.2 fun f hf => bot_le ⟩;
  · exact ⟨ ContinuousMap.const _ 0, fun x _ => by simp +decide, rfl ⟩

end
```


### Catalog Reference Files
            @AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```

@AutoResearch/CompactRiesz.lean
```lean
import Bridges.TropicalFunctional.Basic
import Bridges.TropicalFunctional.Capacity
import Bridges.TropicalFunctional.FiniteRiesz

/-!
# Compact-Space Tropical Riesz Theory

This file develops the tropical Riesz representation theory for compact Hausdorff spaces,
building on the finite discrete case.

## Main results

- `TropSubsemialgebra`: tropical subsemialgebras of `TropCont X`
- `tropical_functional_ext_of_dense`: if two tropical functionals agree on a dense
  subsemialgebra, they are equal (requires an upper-continuity hypothesis)
- `tropical_riesz_compact_eval`: evaluation functionals are tropical functionals

## Mathematical significance

The extensionality theorem says that a tropical functional on a compact Hausdorff space
is uniquely determined by its values on any dense tropical subsemialgebra. Combined with
the Stone–Weierstrass approximation theorem for max-plus algebras, this establishes
that the "states" on a tropical function algebra are geometric objects (maxitive measures).
-/

noncomputable section

variable {X : Type*} [TopologicalSpace X]

/-! ## Tropical subsemialgebra -/

/-- A tropical subsemialgebra of `TropCont X`: a set of continuous functions closed under
pointwise sup (tropical addition), containing all constants, and closed under additive
translation (tropical scalar multiplication). -/
structure TropSubsemialgebra (X : Type*) [TopologicalSpace X] where
  /-- The carrier set. -/
  carrier : Set (TropCont X)
  /-- Closed under pointwise sup. -/
  sup_mem' : ∀ {f g}, f ∈ carrier → g ∈ carrier →
    TropCont.tsup f g ∈ carrier
  /-- Contains all constant functions. -/
  const_mem' : ∀ c : WithBot ℝ, ContinuousMap.const _ c ∈ carrier

/-! ## Evaluation functionals -/

/-- Evaluation at a point `x₀` is a tropical functional.
This is the tropical analogue of the Dirac measure at `x₀`. -/
def evalTropicalFunctional [CompactSpace X] [T2Space X] (x₀ : X) :
    TropicalFunctional X where
  toFun f := f x₀
  map_sup' f g := rfl
  map_const' c := rfl
  map_addConst' c f g hfg := by simp [hfg x₀]
  monotone' h := h x₀

/-- Evaluation at `x₀` applied to the basis function at `x₀` returns `0`. -/
theorem eval_tropBasis_self [Fintype X] [DecidableEq X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X] (x₀ : X) :
    (evalTropicalFunctional x₀).toFun (tropBasis x₀) = 0 := by
  simp [evalTropicalFunctional, tropBasis]

/-! ## Finite-space evaluation reconstruction -/

/-
On a finite discrete space, evaluation at `x₀` has weight function `δ_{x₀}`.
That is, the tropical measure corresponding to evaluation at `x₀` is the tropical
Dirac delta.
-/
theorem eval_deltaWeight [Fintype X] [DecidableEq X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X] (x₀ x : X) :
    deltaWeight (evalTropicalFunctional x₀) x = if x = x₀ then 0 else ⊥ := by
  cases eq_or_ne x x₀ <;> simp_all +decide [deltaWeight, evalTropicalFunctional]
  exact tropBasis_apply_ne (Ne.symm ‹_ ≠ _›)

/-- The representation formula for evaluation functionals on finite spaces:
`f(x₀) = sup_x (δ_{x₀}(x) + f(x))`, which is immediate from the Riesz theorem. -/
theorem eval_representation [Fintype X] [DecidableEq X] [Nonempty X]
    [CompactSpace X] [T2Space X] [DiscreteTopology X]
    (x₀ : X) (f : TropCont X) :
    f x₀ = Finset.univ.sup (fun x => deltaWeight (evalTropicalFunctional x₀) x + f x) := by
  exact finite_representation_formula (evalTropicalFunctional x₀) f

/-! ## Upper-continuous tropical functional -/

/-- An upper-continuous tropical functional: if a monotone sequence of functions converges
pointwise, the functional values converge. This is the tropical analogue of the
monotone convergence theorem. -/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    extends TropicalFunctional X where
  /-- Upper continuity: commutes with directed suprema of monotone sequences. -/
  upper_continuous' :
    ∀ {f : ℕ → TropCont X} {g : TropCont X},
      Monotone f →
      (∀ x, Filter.Tendsto (fun n => f n x) Filter.atTop (nhds (g x))) →
      Filter.Tendsto (fun n => toFun (f n)) Filter.atTop (nhds (toFun g))

/-! ## Functional extensionality from density -/

/-- **Tropical functional extensionality from density.**
If two upper-continuous tropical functionals agree on all functions in a dense
tropical subsemialgebra, they agree on all continuous functions. This is the
key uniqueness principle for the tropical Riesz representation.

*Proof idea*: For any `f : TropCont X`, the density of `A` provides a sequence
of functions in `A` converging to `f`. By upper continuity of both functionals,
the functional values converge, and since they agree on `A`, they agree on `f`. -/
theorem tropical_functional_ext_of_dense
    [CompactSpace X] [T2Space X]
    (A : TropSubsemialgebra X)
    (h_dense : Dense A.carrier)
    (Λ₁ Λ₂ : UCTropicalFunctional X)
    (h_eq : ∀ f : TropCont X, f ∈ A.carrier → Λ₁.toFun f = Λ₂.toFun f) :
    Λ₁.toFun = Λ₂.toFun := by
  -- This requires converting density in the compact-open topology to monotone
  -- approximation sequences, then using upper_continuous' to pass to limits.
  -- Full proof requires substantial infrastructure around function space topologies.
  sorry

/-! ## Capacity from functional -/

/-- The canonical measure (maxitive capacity) on compact sets, derived from a tropical
functional. For each compact set `K`, this is the infimum of `Λ(f)` over all
continuous functions that dominate the tropical indicator of `K`. -/
def μ_from_Λ [CompactSpace X] (Λ : TropicalFunctional X) (K : Set X) : WithBot ℝ :=
  muK Λ K

/-
The capacity derived from an evaluation functional at `x₀` assigns `0` to
any compact set containing `x₀`, and `⊥` to sets not containing `x₀`.
-/
theorem μ_from_eval_mem [CompactSpace X] [T2Space X] (x₀ : X)
    (K : Set X) (_hK : IsCompact K) (_hx : x₀ ∈ K) :
    μ_from_Λ (evalTropicalFunctional x₀) K ≤ 0 := by
  refine' csInf_le _ _;
  · exact ⟨ ⊥, Set.forall_mem_image.2 fun f hf => bot_le ⟩;
  · exact ⟨ ContinuousMap.const _ 0, fun x _ => by simp +decide, rfl ⟩

end
```


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

Research domain: Bridges
Research mode: formalize
