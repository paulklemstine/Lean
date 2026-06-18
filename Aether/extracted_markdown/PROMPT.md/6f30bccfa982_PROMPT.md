## Assignment: algebra_breakthrough_discovery

Survey the territory. Find deep structures. Prove theorems that reveal truth. Produce `FUTURE_DIRECTIONS.md`.

### Mode
`discover` with a secondary `sorry_fill` mandate if a decisive bridge theorem stalls. The cold-start opportunity is not to add one more lemma to algebra, but to expose a hidden organizing principle linking algebraic symmetry, tropical geometry, norms, and finite combinatorial structure already present in the library.

---

## Research Direction

Discover a **structural bridge theorem** showing that algebraic difference phenomena in finite additive sets are controlled simultaneously by:

1. **group-action symmetry**,
2. **lattice/norm geometry**, and
3. **tropicalized support function behavior**.

The catalog already contains fragments that should not remain isolated:

- `tropical_lattice_norm_bridge`
- `norm_congruence_bridge`
- `any_semiring_reduced_basis_exists`
- `symmetric_group_order`
- `qdf_symmetry_group_order`

This is the right moment to build a theorem that says: finite algebraic data in additive settings admits a canonical geometric shadow, and that shadow is invariant under natural symmetries and measurable by norm/lattice tools. That would create the first real bridge from Algebra into the nearby domains listed in the catalog: category, lattice, norm, metric, topology, tropical, and even machine-learning-flavored geometry.

The immediate proving ground is the existing file:

- `Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean`

where the definitions
- `differenceSet : Finset ℤ → Finset ℤ`
- `nonzeroDifferenceSet : Finset ℤ → Finset ℤ`

already encode a finite additive energy object. The breakthrough is to prove that these objects are not just combinatorial artifacts: they are functorial under translation/negation, symmetric under inversion, and canonically tied to norm/tropical summaries.

---

## Primary Breakthrough Target

### Theorem A: Difference-set symmetry and cardinal rigidity

Prove that for every finite set of integers, the nonzero difference set is invariant under negation, and hence decomposes into sign-paired orbits with even cardinality.

This is elementary in classical mathematics, but in the present catalog it becomes foundational: it turns `differenceSet` into a genuine algebraic symmetry object, opening the way to orbit-counting, additive energy inequalities, and tropical support interpretations.

### Precise theorem statement

```lean
theorem neg_mem_nonzeroDifferenceSet_iff
    {S : Finset ℤ} {z : ℤ} :
    z ∈ nonzeroDifferenceSet S ↔ -z ∈ nonzeroDifferenceSet S
```

and the cardinal consequence

```lean
theorem card_nonzeroDifferenceSet_even
    {S : Finset ℤ} :
    Even (nonzeroDifferenceSet S).card
```

A stronger orbit-level version would be even better:

```lean
theorem nonzeroDifferenceSet_eq_image_neg
    {S : Finset ℤ} :
    nonzeroDifferenceSet S = (nonzeroDifferenceSet S).image (fun z : ℤ => -z)
```

### Why this matters

This is not just a cleanup lemma. It promotes `nonzeroDifferenceSet S` from a raw finite set to a **finite signed symmetry object**. Once formalized, you can:

- treat additive combinatorics data via involution/orbit decomposition;
- derive parity constraints unavailable from raw cardinal estimates;
- prepare a bridge to tropical geometry, where negation symmetry corresponds to reflection symmetry of a tropical Newton support;
- prepare a bridge to harmonic or pair-correlation style algebra, where sign symmetry is the first shadow of Fourier self-duality.

This is the kind of theorem that turns a file of definitions into infrastructure.

---

## Secondary Breakthrough Target

### Theorem B: Translation invariance of the difference set

Prove that translating a finite set does not change its difference set.

Define, if useful:

```lean
def translateFinset (a : ℤ) (S : Finset ℤ) : Finset ℤ :=
  S.image (fun x => x + a)
```

Then prove:

```lean
theorem differenceSet_translate
    (a : ℤ) (S : Finset ℤ) :
    differenceSet (translateFinset a S) = differenceSet S
```

and similarly

```lean
theorem nonzeroDifferenceSet_translate
    (a : ℤ) (S : Finset ℤ) :
    nonzeroDifferenceSet (translateFinset a S) = nonzeroDifferenceSet S
```

### Why this matters

This identifies `differenceSet` as a **translation-quotient invariant** of finite subsets of `ℤ`. That is the first step toward a categorical view: finite subsets modulo translation map to symmetric finite subsets containing `0`. In other words, you are formalizing the idea that pair-correlation data depends only on relative geometry, not absolute location.

That principle is exactly what lets one connect additive combinatorics to:

- metric geometry: only relative displacement matters;
- topological data analysis: persistence-type summaries are translation invariant;
- machine learning: representation learning seeks invariants under nuisance group actions;
- tropical geometry: tropical objects are often governed by relative valuation data.

---

## Tertiary Breakthrough Target

### Theorem C: Difference-set range is controlled by extremal geometry

For nonempty finite sets of integers, every difference lies in the interval between `-(max' S hS - min' S hS)` and `max' S hS - min' S hS`. This upgrades combinatorial data to norm-diameter geometry.

A clean Lean-facing theorem could be:

```lean
theorem mem_differenceSet_abs_le_diam
    {S : Finset ℤ} (hS : S.Nonempty) {z : ℤ}
    (hz : z ∈ differenceSet S) :
    |z| ≤ S.max' hS - S.min' hS
```

If `Finset.max'` / `min'` on `ℤ` becomes cumbersome, formulate an equivalent boundedness theorem using witnesses `x y ∈ S` and derive the norm bound from them.

### Why this matters

This is the real bridge theorem. It says additive algebraic structure is controlled by a geometric diameter. Once formalized, this can connect directly to:

- `tropical_lattice_norm_bridge`: difference vectors are norm-bounded lattice points;
- `norm_congruence_bridge`: congruence constraints can be imposed on norm-bounded algebraic differences;
- quantitative additive combinatorics: cardinality of `differenceSet S` can now be studied through geometry of intervals and lattice counts.

This is the first step toward a formalized “algebraic uncertainty principle” in the library.

---

## Lean 4 Formalization Targets

At minimum, aim to place the following in `Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean` or a nearby bridge file:

```lean
theorem neg_mem_differenceSet_iff
    {S : Finset ℤ} {z : ℤ} :
    z ∈ differenceSet S ↔ -z ∈ differenceSet S
```

```lean
theorem neg_mem_nonzeroDifferenceSet_iff
    {S : Finset ℤ} {z : ℤ} :
    z ∈ nonzeroDifferenceSet S ↔ -z ∈ nonzeroDifferenceSet S
```

```lean
theorem card_nonzeroDifferenceSet_even
    {S : Finset ℤ} :
    Even (nonzeroDifferenceSet S).card
```

```lean
def translateFinset (a : ℤ) (S : Finset ℤ) : Finset ℤ :=
  S.image (fun x => x + a)
```

```lean
theorem differenceSet_translate
    (a : ℤ) (S : Finset ℤ) :
    differenceSet (translateFinset a S) = differenceSet S
```

```lean
theorem nonzeroDifferenceSet_translate
    (a : ℤ) (S : Finset ℤ) :
    nonzeroDifferenceSet (translateFinset a S) = nonzeroDifferenceSet S
```

```lean
theorem mem_differenceSet_abs_le_diam
    {S : Finset ℤ} (hS : S.Nonempty) {z : ℤ}
    (hz : z ∈ differenceSet S) :
    |z| ≤ S.max' hS - S.min' hS
```

If the even-cardinality theorem is technically awkward using `Finset.card`, an acceptable intermediate theorem is a disjoint decomposition into positive and negative parts:

```lean
theorem card_nonzeroDifferenceSet_eq_two_mul_card_pos
    {S : Finset ℤ} :
    (nonzeroDifferenceSet S).card =
      2 * ((nonzeroDifferenceSet S).filter (fun z => 0 < z)).card
```

That theorem would be even more structurally informative.

---

## Proof Strategy Paths

### Strategy 1: Direct witness-swapping on product finsets
Most promising for Theorems A and B.

1. Unfold `differenceSet` and `nonzeroDifferenceSet`.
2. For membership in `differenceSet`, extract witnesses `x,y ∈ S` with `z = x - y`.
3. Swap witnesses to obtain `-z = y - x`, and repackage the witness in the image of `(S ×ˢ S)`.
4. For translation invariance, use
   \[
   (x+a) - (y+a) = x-y.
   \]
   Show both inclusions by explicit witness transport.

Why this is promising: the definitions are already image/product based, and `simp` with `Finset.mem_image`, `Finset.mem_product`, `sub_eq_add_neg`, and ring normalization should do most of the work.

---

### Strategy 2: Use involutions and finite orbit decomposition
Best for the parity theorem.

1. Prove negation preserves `nonzeroDifferenceSet S`.
2. Show negation has no fixed points on `nonzeroDifferenceSet S` because `z = -z` in `ℤ` implies `z = 0`, excluded by definition.
3. Invoke a finite-set involution principle to deduce even cardinality.

Why this is promising: it captures the theorem at the correct conceptual level. Even if the exact library lemma for fixed-point-free involutions is inconvenient, you can construct an equivalence between positive and negative parts manually.

---

### Strategy 3: Extremal-element geometry for diameter bounds
Best for Theorem C.

1. Unfold membership in `differenceSet` to get `z = x - y` with `x,y ∈ S`.
2. Use `Finset.min'` and `Finset.max'` bounds:
   \[
   \min S \le y \le \max S,\quad \min S \le x \le \max S.
   \]
3. Deduce
   \[
   -( \max S - \min S ) \le x-y \le \max S - \min S,
   \]
   hence `|z| ≤ max' S hS - min' S hS`.

Why this is promising: it turns a finite algebraic object into a norm estimate, exactly the sort of bridge theorem the catalog is missing.

---

## Cross-Domain Connections You Should Exploit Explicitly

### 1. Tropical geometry
The difference set is a discrete shadow of a tropical support polytope: pairwise differences encode slopes, valuations, and support-function changes. If Theorem C is formalized, you effectively show that tropicalized support variation is bounded by a diameter norm. This is the first bridge from finite additive algebra to the existing tropical infrastructure.

### 2. Group actions and representation flavor
Negation on `ℤ` acts as a `C₂`-symmetry on the nonzero difference set. Translation acts by a quotient symmetry on the underlying finite set while leaving difference data invariant. These are the beginnings of an algebraic invariant theory for `Finset ℤ`.

### 3. Metric and normed geometry
The diameter bound converts additive combinatorics into a metric statement. This is precisely the kind of theorem that can later be generalized from `ℤ` to normed abelian groups, seminormed modules, or lattice-ordered groups.

### 4. Machine learning / data representation
Difference sets are pairwise feature maps. Translation invariance corresponds to representation invariance under nuisance shifts; sign symmetry corresponds to bidirectional relational encoding. Formalizing this in algebra creates a mathematically rigorous bridge to invariant representation learning.

### 5. Semiring and reduced-basis infrastructure
The existence theorem `any_semiring_reduced_basis_exists` suggests a larger agenda: compress algebraic objects into canonical reduced representatives. Difference sets modulo translation are exactly such reduced representatives for finite subsets of `ℤ`. Make this philosophical connection explicit in comments and theorem naming.

---

## Suggested Theorem Packaging Vision

If the initial theorems go through cleanly, package them as a mini-theory:

- `differenceSet` is translation invariant,
- `nonzeroDifferenceSet` carries a fixed-point-free negation involution,
- every difference is norm-bounded by diameter.

This triad would justify a future abstraction:

> finite additive configurations admit a canonical symmetric, norm-controlled quotient invariant.

That statement is broad enough to propagate into abelian groups, modules, lattices, and tropical semirings.

---

## If You Need a Stronger Stretch Goal

Attempt a cardinal upper bound by interval geometry:

```lean
theorem card_differenceSet_le_two_mul_diam_add_one
    {S : Finset ℤ} (hS : S.Nonempty) :
    (differenceSet S).card ≤
      2 * Int.natAbs (S.max' hS - S.min' hS) + 1
```

or for the nonzero set:

```lean
theorem card_nonzeroDifferenceSet_le_two_mul_diam
    {S : Finset ℤ} (hS : S.Nonempty) :
    (nonzeroDifferenceSet S).card ≤
      2 * Int.natAbs (S.max' hS - S.min' hS)
```

This would be a genuinely useful additive-combinatorial estimate and would make the geometry/algebra bridge quantitative.

---

## Revolutionary Significance

If you complete this program, you will have done more than prove a few facts about finite sets of integers. You will have established a **formal invariant theory of difference data** in Lean:

- symmetry under involution,
- invariance under group action,
- control by norm geometry.

That opens several new fields of formalization:

- additive combinatorics with genuine structural theorems,
- tropicalized algebraic statistics via pairwise difference supports,
- norm-controlled algebraic feature maps for machine learning,
- eventual category-theoretic functoriality of finite configurations modulo symmetry.

This is the kind of bridge theorem that changes how the catalog is explored. It upgrades Algebra from a declaration-rich area to a theorem-rich architecture.

---

## Application Keywords

additive combinatorics, finite group actions, involution principle, orbit decomposition, translation invariance, norm bounds, diameter estimates, tropical geometry, lattice methods, invariant representation learning, finite metric geometry, algebraic feature maps, canonical quotient invariants, combinatorial symmetry, formalized harmonic structure

---

## Deliverables

1. Formalize and prove as many of Theorems A–C as possible.
2. If one theorem blocks, prove the strongest structurally adjacent version rather than stopping.
3. Add clear theorem docstrings explaining the invariant/symmetry meaning.
4. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, not generic ideas.

Your `FUTURE_DIRECTIONS.md` must include specific next targets such as:
- extension from `Finset ℤ` to finite subsets of linearly ordered additive commutative groups;
- an abstraction of `differenceSet` as a functor modulo translation;
- quantitative additive energy theorems relating `card S` and `card (differenceSet S)`;
- a tropical support-function formalization of difference data;
- a normed/module generalization replacing integer diameter by seminorm radius.

Do not be incremental. Find the hidden invariant and formalize it so the rest of algebra can build on it.

### Catalog Reference Files
@Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean
```lean
import Mathlib

/-! # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34
-/


noncomputable section

/-- The difference set of a finite set S: all values s - t for s, t ∈ S. -/
def differenceSet (S : Finset ℤ) : Finset ℤ :=
  (S ×ˢ S).image (fun p => p.1 - p.2)




/-- The nonzero difference set — excludes the trivial zero difference. -/
def nonzeroDifferenceSet (S : Finset ℤ) : Finset ℤ :=
  (differenceSet S).filter (· ≠ 0)




/-- Zero is always in the difference set of a nonempty set. -/
theorem zero_mem_differenceSet {S : Finset ℤ} (hS : S.Nonempty) :
    (0 : ℤ) ∈ differenceSet S := by
  obtain ⟨x, hx⟩ := hS
  simp only [differenceSet, Finset.mem_image, Finset.mem_product]
  exact ⟨⟨x, x⟩, ⟨hx, hx⟩, sub_self x⟩




/-- [Section: # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34] -/
theorem nonzero_diff_card_le (S : Finset ℤ) :
    (nonzeroDifferenceSet S).card ≤ S.card ^ 2 - S.card := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun p : ℤ × ℤ => p.1 - p.2 ) ( Finset.filter ( fun p : ℤ × ℤ => p.1 ≠ p.2 ) ( S ×ˢ S ) );
  · unfold nonzeroDifferenceSet differenceSet;
    intro x hx; aesop;
  · refine' le_trans ( Finset.card_image_le ) _;
    rw [ show ( Finset.filter ( fun p : ℤ × ℤ => p.1 ≠ p.2 ) ( S ×ˢ S ) ) = Finset.offDiag S by ext ⟨ x, y ⟩ ; aesop ] ; simp +decide [ sq, Finset.offDiag_card ]




/-- [Section: # CatalogBuild.Algebra.Core.MontgomeryPairCorrelation
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 34] -/
theorem sidon_diff_card (S : Finset ℤ) (hS : IsSidonSet S) :
    (nonzeroDifferenceSet S).card = S.card * (S.card - 1) := by
  -- For a Sidon set, every nonzero difference d = s - t with s ≠ t appears exactly once. The total number of ordered pairs (s,t) with s ≠ t is |S|*(|S|-1). Each such pair contributes a unique nonzero difference (this is the Sidon condition). So the number of distinct nonzero differences equals |S|*(|S|-1).
  have h_diff_set_card : ((S ×ˢ S).filter (fun p => p.1 ≠ p.2)).card = S.card * (S.card - 1) := by
    simp +contextual [ Finset.filter_ne, Finset.card_product ];
    rw [ show ( Finset.filter ( fun p => ¬p.1 = p.2 ) ( S ×ˢ S ) ) = Finset.offDiag S by ext; aesop ] ; simp +decide [ Finset.offDiag_card ];
    rw [ Nat.mul_sub_left_distrib, Nat.mul_one ];
  -- Since these pairs contribute distinct nonzero differences, the cardinality of the nonzero difference set is equal to the cardinality of the set of pairs.
  have h_distinct_diffs : Finset.image (fun p : ℤ × ℤ => p.1 - p.2) ((S ×ˢ S).filter (fun p => p.1 ≠ p.2)) = nonzeroDifferenceSet S := by
    ext; simp [differenceSet, nonzeroDifferenceSet];
    grind +ring;
  rw [ ← h_diff_set_card, ← h_distinct_diffs, Finset.card_image_of_injOn ];
  intro p hp q hq; have := hS ( p.1 - p.2 ) ; simp_all +decide [ Set.InjOn ] ;
  intro h; have := this ( sub_ne_zero_of_ne hp.2 ) ; simp_all +decide [ autocorrelation ] ;
  contrapose! this;
  refine' Finset.one_lt_card.mpr ⟨ p, _, q, _, _ ⟩ <;> aesop




/-- The autocorrelation energy: sum of squared autocorrelation values over
the difference set. This measures departure from randomness. -/
def autocorrelationEnergy (S : Finset ℤ) : ℕ :=
  ∑ d ∈ differenceSet S, (autocorrelation S d) ^ 2




theorem autocorrelation_total_sum (S : Finset ℤ) :
    ∑ d ∈ differenceSet S, autocorrelation S d = S.card ^ 2 := by
  unfold differenceSet autocorrelation;
  rw [ Finset.sum_image' ];
  rotate_left;
  use fun _ => 1;
  · aesop;
  · norm_num [ sq ]




/-- The number of "additive quadruples" (a,b,c,d) with a-b = c-d. -/
def additiveQuadruples (S : Finset ℤ) : ℕ :=
  ((S ×ˢ S).filter (fun p => p.1 - p.2 = 0)).card  -- simplified placeholder




/-- The Sidon defect: number of nonzero differences with multiplicity ≥ 2. -/
def sidonDefect (S : Finset ℤ) : ℕ :=
  ((S ×ˢ S).image (fun p => p.1 - p.2) |>.filter
    (fun d => d ≠ 0 ∧ 1 < autocorrelation S d)).card




theorem sidon_iff_defect_zero (S : Finset ℤ) :
    IsSidonSet S ↔ sidonDefect S = 0 := by
  rw [ sidonDefect ];
  constructor;
  · aesop;
  · intro h;
    intro d hd; contrapose! h; simp_all +decide [ Finset.ext_iff ] ;
    obtain ⟨ p, hp ⟩ := Finset.card_pos.mp ( pos_of_gt h ) ; use p.1, by aesop, p.2; aesop;




/-- Compute the Sidon defect of a list-represented set. -/
def sidonDefectCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let nonzeroDiffs := diffs.filter (· ≠ 0) |>.eraseDups
  nonzeroDiffs.countP (fun d =>
    1 < (S.product S).countP (fun p => p.1 - p.2 = d))




/-- Compute maximum autocorrelation value for d ≠ 0. -/
def maxAutocorrCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let nonzeroDiffs := diffs.filter (· ≠ 0) |>.eraseDups
  nonzeroDiffs.foldl (fun acc d =>
    max acc ((S.product S).countP (fun p => p.1 - p.2 = d))) 0




/-- Compute autocorrelation energy. -/
def autocorrEnergyCompute (S : List ℤ) : ℕ :=
  let diffs := (S.product S).map (fun p => p.1 - p.2)
  let allDiffs := diffs.eraseDups
  allDiffs.foldl (fun acc d =>
    acc + ((S.product S).countP (fun p => p.1 - p.2 = d))^2) 0

-- ... (truncated, full file has 409 lines)
```

@Algebra/Advanced/MetaOracleAdvanced.lean
```lean
import Mathlib

/-! # CatalogBuild.Computation.Oracles.MetaOracleAdvanced

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/


noncomputable section

/-- The identity meta-oracle: does nothing. -/
def metaOracleId {α : Type*} : α → α := id




/-- The identity is a fixed point of any meta-oracle composition scheme. -/
theorem metaOracleId_fixed {α : Type*} (f : (α → α) → (α → α))
    (hf : f id = id) : f metaOracleId = metaOracleId :=
  hf




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleAdvanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem exists_fixed_quality_strict {n : ℕ} (hn : 0 < n)
    (M : Fin n → Fin n) (q : Fin n → ℝ)
    (h_strict : ∀ i, M i ≠ i → q i < q (M i)) :
    ∃ i, M i = i := by
  contrapose! h_strict with h;
  -- Consider the maximum value of $q$ over all elements in $Fin n$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, ∀ i : Fin n, q i₀ ≥ q i := by
    simpa using Finset.exists_max_image Finset.univ q ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ );
  exact ⟨ i₀, h i₀, hi₀ _ ⟩




/-- The improvement ratio after n steps of a contraction with rate k. -/
def improvementRatio (k : ℝ) (n : ℕ) : ℝ := 1 - k ^ n




/-- The improvement ratio approaches 1 (complete improvement) as n → ∞. -/
theorem improvementRatio_tendsto_one (k : ℝ) (hk : 0 < k) (hk1 : k < 1) :
    Filter.Tendsto (improvementRatio k) Filter.atTop (nhds 1) := by
  unfold improvementRatio
  have h := tendsto_pow_atTop_nhds_zero_of_lt_one (le_of_lt hk) hk1
  convert Filter.Tendsto.const_sub 1 h using 1 <;> ring




/-- Number of iterations needed to achieve ε-optimality. -/
def iterationsNeeded (k ε d₀ : ℝ) : ℝ :=
  Real.log (ε / d₀) / Real.log k




/-- The number of iterations needed is proportional to 1/H where H is oracle entropy. -/
theorem iterations_proportional_to_inv_entropy
    (k ε d₀ : ℝ) (_hk : 0 < k) (_hk1 : k < 1) (_hε : 0 < ε) (_hd : 0 < d₀) :
    iterationsNeeded k ε d₀ = Real.log (ε / d₀) / (-(-Real.log k)) := by
  unfold iterationsNeeded
  ring




/-- Meta-oracles on a fixed type form a semigroup under composition. -/
instance metaOracleSemigroup (α : Type*) : Semigroup (α → α) where
  mul := Function.comp
  mul_assoc := Function.comp_assoc




/-- Meta-oracles on a fixed type form a monoid with identity. -/
instance metaOracleMonoid (α : Type*) : Monoid (α → α) where
  one := id
  one_mul := Function.id_comp
  mul_one := Function.comp_id




/-- If f and g both contract with rates k₁ and k₂, then f ∘ g contracts with rate k₁ * k₂. -/
theorem comp_contraction_rate {α : Type*} [PseudoMetricSpace α]
    (f g : α → α) (k₁ k₂ : ℝ)
    (hk₁ : 0 ≤ k₁) (_hk₂ : 0 ≤ k₂)
    (hf : ∀ x y, dist (f x) (f y) ≤ k₁ * dist x y)
    (hg : ∀ x y, dist (g x) (g y) ≤ k₂ * dist x y) :
    ∀ x y, dist ((f ∘ g) x) ((f ∘ g) y) ≤ (k₁ * k₂) * dist x y := by
  intro x y
  simp only [Function.comp_apply]
  calc dist (f (g x)) (f (g y))
      ≤ k₁ * dist (g x) (g y) := hf _ _
    _ ≤ k₁ * (k₂ * dist x y) := by
        apply mul_le_mul_of_nonneg_left (hg _ _) hk₁
    _ = (k₁ * k₂) * dist x y := by ring




/-- A weighted combination of quality values (portfolio quality). -/
def portfolioQuality {n : ℕ} (weights : Fin n → ℝ) (qualities : Fin n → ℝ) : ℝ :=
  ∑ i, weights i * qualities i




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleAdvanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem portfolio_quality_bounded {n : ℕ} (hn : 0 < n)
    (w : Fin n → ℝ) (q : Fin n → ℝ)
    (hw_nn : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1) :
    (∃ i, q i ≤ portfolioQuality w q) ∧ (∃ i, portfolioQuality w q ≤ q i) := by
  constructor;
  · -- Let $j$ be an index such that $q_j$ is the minimum among the $q_i$.
    obtain ⟨j, hj⟩ : ∃ j, ∀ i, q i ≥ q j := by
      simpa using Finset.exists_min_image Finset.univ ( fun i => q i ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ j, by simpa [ ← Finset.sum_mul _ _ _, hw_sum ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => mul_le_mul_of_nonneg_left ( hj i ) ( hw_nn i ) ⟩;
  · -- Since the weights are non-negative and sum to 1, the weighted average of the qualities is bounded above by the maximum quality.
    have h_max : ∃ i, ∀ j, q j ≤ q i := by
      simpa using Finset.exists_max_image Finset.univ q ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    exact ⟨ h_max.choose, le_trans ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( h_max.choose_spec i ) ( hw_nn i ) ) ( by simp +decide [ ← Finset.sum_mul, hw_sum ] ) ⟩




end
```

@Algebra/AutoResearch/ArithmeticDarkMatter.lean
```lean
import Mathlib

/-! # CatalogBuild.Algebra.Core.ArithmeticDarkMatter

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24
-/


/-- The Lorentz form Q(a,b,c) = a² + b² - c² -/
def Q_form (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2




/-- An arithmetic particle: an integer triple with its mass classification -/
structure ArithParticle where
  a : ℤ
  b : ℤ
  c : ℤ
  a_pos : 0 < a
  b_pos : 0 < b
  c_pos : 0 < c




/-- The mass-squared of a particle -/
def ArithParticle.massSq (p : ArithParticle) : ℤ :=
  p.c ^ 2 - p.a ^ 2 - p.b ^ 2




/-- A particle is a photon (null/massless) -/
def ArithParticle.isPhoton (p : ArithParticle) : Prop :=
  p.massSq = 0




/-- A particle is massive (timelike) -/
def ArithParticle.isMassive' (p : ArithParticle) : Prop :=
  p.massSq > 0




/-- A particle is tachyonic (spacelike) -/
def ArithParticle.isTachyon (p : ArithParticle) : Prop :=
  p.massSq < 0




/-- The mass spectrum: which mass-squared values are realized? -/
def massIsRealized (m_sq : ℤ) : Prop :=
  ∃ a b c : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ c ^ 2 - a ^ 2 - b ^ 2 = m_sq




/-- [Section: # CatalogBuild.Algebra.Core.ArithmeticDarkMatter
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24] -/
theorem every_nonneg_mass_realized (m_sq : ℕ) :
    massIsRealized (m_sq : ℤ) := by
  by_contra h;
  -- For even m_sq, we can take a=1, b=m_sq/2, c=m_sq/2+1.
  by_cases h_even : Even m_sq;
  · obtain ⟨ k, rfl ⟩ := h_even;
    exact h ⟨ 1, k, k + 1, by norm_num, by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by rintro rfl; exact h ⟨ 3, 4, 5, by norm_num ⟩ ) ], by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by rintro rfl; exact h ⟨ 3, 4, 5, by norm_num ⟩ ) ], by push_cast; linarith ⟩;
  · -- For odd m_sq, we can take a=2, b=(m_sq+3)/2, c=(m_sq+5)/2.
    obtain ⟨k, hk⟩ : ∃ k : ℕ, m_sq = 2 * k + 1 := by
      exact m_sq.even_or_odd.resolve_left h_even;
    refine h ⟨ 2, k + 2, k + 3, by norm_num, by linarith, by linarith, ?_ ⟩ ; push_cast [ hk ] ; ring




/-- The Berggren B₁ matrix action on a triple -/
def berggren_B1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)




/-- The Berggren matrices preserve Q (the full Lorentz form, not just Q=0) -/
theorem B1_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B1 a b c).1 (berggren_B1 a b c).2.1 (berggren_B1 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B1 Q_form
  ring




/-- B₂ also preserves Q -/
def berggren_B2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)




/-- [Section: # CatalogBuild.Algebra.Core.ArithmeticDarkMatter
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24] -/
theorem B2_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B2 a b c).1 (berggren_B2 a b c).2.1 (berggren_B2 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B2 Q_form
  ring




/-- B₃ also preserves Q -/
def berggren_B3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)




theorem B3_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B3 a b c).1 (berggren_B3 a b c).2.1 (berggren_B3 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B3 Q_form
  ring




/-- A path in the dark matter tree (same branching as the photon tree) -/
inductive DarkPath where
  | root : DarkPath
  | b1 : DarkPath → DarkPath
  | b2 : DarkPath → DarkPath
  | b3 : DarkPath → DarkPath
  deriving Repr




/-- The triple at a given dark matter path, starting from seed (a₀, b₀, c₀) -/
def darkTriple (seed : ℤ × ℤ × ℤ) : DarkPath → ℤ × ℤ × ℤ
  | .root => seed
  | .b1 p =>
-- ... (truncated, full file has 299 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py, diagram.svg

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Structure it with specific theorem statements, proof strategies, and
            cross-domain connections.


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
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
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
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Algebra
Research mode: discover
