import Mathlib

/-! # Stone Duality for Neural Networks: Activation Boolean Algebras

This file develops the theory of **activation Boolean algebras** for neural networks,
establishing a Stone-duality perspective on neural network decision regions.

## Main Ideas

A ReLU network with `m` neurons defines `m` hyperplanes in ℝⁿ. For each input point,
the **activation pattern** records which neurons are active (positive pre-activation)
and which are inactive. The set of all realized activation patterns forms the atoms
of a finite Boolean algebra — the **activation Boolean algebra** `B(f)`.

By Stone duality, every finite Boolean algebra is isomorphic to the powerset algebra
of its atoms. The atoms correspond to **linear regions** of the network — the maximal
connected regions on which the network computes a single affine function.

## Main Results

* `ActivationPattern` — the type of activation patterns (functions `Fin m → Bool`)
* `activationRegion` — the set of inputs with a given activation pattern
* `activationRegions_pairwise_disjoint` — distinct patterns give disjoint regions
* `activationRegions_cover` — every input belongs to some activation region
* `realized_patterns_card_le` — at most `2^m` realized patterns
* `ActivationBooleanAlgebra` — the Boolean algebra of unions of activation regions
* Boolean algebra closure properties (union, intersection, complement)
* `relu_determined_by_pattern` — ReLU output determined by activation pattern
* `relu_equals_tropical_on_region` — connection to tropical representation
* `stonePoint_eq_iff` — Stone duality characterization

## Cross-Domain Connections

* **Algebra ↔ Machine Learning**: Boolean algebras classify neural decision regions
* **Topology ↔ Machine Learning**: Stone spaces give a topological view of networks
* **Tropical Geometry ↔ Machine Learning**: activation patterns = tropical types
-/

noncomputable section

open Classical in
attribute [local instance] Classical.propDecidable

open Set Function Finset

/-! ## Section 1: Hyperplane Arrangements and Activation Patterns -/

/-- A hyperplane in ℝⁿ defined by a weight vector `w` and bias `b`:
    the set `{x : w · x + b = 0}`. -/
structure Hyperplane (n : ℕ) where
  w : Fin n → ℝ
  b : ℝ

/-- A hyperplane arrangement is a finite indexed family of hyperplanes. -/
structure HyperplaneArrangement (n m : ℕ) where
  planes : Fin m → Hyperplane n

/-- The affine functional associated with a hyperplane: `w · x + b`. -/
def Hyperplane.eval {n : ℕ} (h : Hyperplane n) (x : Fin n → ℝ) : ℝ :=
  (∑ i, h.w i * x i) + h.b

/-- The positive half-space: `{x : w · x + b > 0}`. -/
def Hyperplane.positiveHalf {n : ℕ} (h : Hyperplane n) : Set (Fin n → ℝ) :=
  {x | h.eval x > 0}

/-- The non-positive half-space: `{x : w · x + b ≤ 0}`. -/
def Hyperplane.nonpositiveHalf {n : ℕ} (h : Hyperplane n) : Set (Fin n → ℝ) :=
  {x | h.eval x ≤ 0}

/-- An activation pattern is an assignment of `Bool` to each of `m` neurons.
    `true` means the neuron is active (positive pre-activation),
    `false` means inactive. -/
abbrev ActivationPattern (m : ℕ) := Fin m → Bool

/-- The activation pattern of a point `x` with respect to a hyperplane arrangement:
    neuron `i` is active iff `w_i · x + b_i > 0`. -/
def activationPatternOf {n m : ℕ} (arr : HyperplaneArrangement n m)
    (x : Fin n → ℝ) : ActivationPattern m :=
  fun i => decide (0 < (arr.planes i).eval x)

/-- The **activation region** of a pattern `σ` is the set of all inputs
    whose activation pattern equals `σ`. This is a (possibly empty)
    convex polyhedron — the intersection of half-spaces. -/
def activationRegion {n m : ℕ} (arr : HyperplaneArrangement n m)
    (σ : ActivationPattern m) : Set (Fin n → ℝ) :=
  {x | activationPatternOf arr x = σ}

/-! ## Section 2: Fundamental Properties of Activation Regions -/

/-- **Disjointness**: Distinct activation patterns yield disjoint regions.
    This is immediate from the definition — an input has a unique pattern. -/
theorem activationRegions_pairwise_disjoint {n m : ℕ}
    (arr : HyperplaneArrangement n m) :
    Pairwise (Disjoint on (activationRegion arr)) := by
  intro σ τ hne
  rw [Function.onFun]
  rw [Set.disjoint_iff]
  intro x ⟨hx1, hx2⟩
  simp [activationRegion] at hx1 hx2
  exact hne (hx1.symm.trans hx2)

/-- **Covering**: Every input belongs to exactly one activation region. -/
theorem activationRegions_cover {n m : ℕ}
    (arr : HyperplaneArrangement n m) :
    ∀ x : Fin n → ℝ, x ∈ activationRegion arr (activationPatternOf arr x) := by
  intro x
  simp [activationRegion]

/-- The union of all activation regions is the entire input space. -/
theorem activationRegions_union_univ {n m : ℕ}
    (arr : HyperplaneArrangement n m) :
    (⋃ σ : ActivationPattern m, activationRegion arr σ) = Set.univ := by
  ext x
  simp only [Set.mem_iUnion, Set.mem_univ, iff_true]
  exact ⟨activationPatternOf arr x, activationRegions_cover arr x⟩

/-! ## Section 3: The Activation Boolean Algebra -/

/-- The set of **realized** activation patterns — patterns that are non-empty. -/
def realizedPatterns {n m : ℕ} (arr : HyperplaneArrangement n m) :
    Set (ActivationPattern m) :=
  {σ | (activationRegion arr σ).Nonempty}

/-- The number of realized patterns is at most `2^m`.
    Uses a `calc` chain through the subtype/Fintype cardinality bound. -/
theorem realized_patterns_card_le {n m : ℕ}
    (arr : HyperplaneArrangement n m) :
    Fintype.card {σ : ActivationPattern m | (activationRegion arr σ).Nonempty} ≤ 2 ^ m := by
  calc Fintype.card {σ : ActivationPattern m | (activationRegion arr σ).Nonempty}
      ≤ Fintype.card (ActivationPattern m) := Fintype.card_subtype_le _
    _ = 2 ^ m := by simp [Fintype.card_bool]

/-- The **activation Boolean algebra** of a hyperplane arrangement.
    This is the subalgebra of `𝒫(ℝⁿ)` consisting of all unions of
    activation regions. It is a finite Boolean algebra whose atoms
    are exactly the non-empty activation regions.

    **Novel definition**: This connects the combinatorial structure of
    neural networks to Stone duality via Boolean algebras of sets. -/
def ActivationBooleanAlgebra {n m : ℕ} (arr : HyperplaneArrangement n m) :
    Set (Set (Fin n → ℝ)) :=
  {S | ∃ (P : Finset (ActivationPattern m)),
    S = ⋃ σ ∈ P, activationRegion arr σ}

/-- The empty set is in the activation Boolean algebra. -/
theorem ActivationBooleanAlgebra.empty_mem {n m : ℕ}
    (arr : HyperplaneArrangement n m) :
    ∅ ∈ ActivationBooleanAlgebra arr := by
  refine ⟨∅, ?_⟩
  simp

/-- The universal set is in the activation Boolean algebra. -/
theorem ActivationBooleanAlgebra.univ_mem {n m : ℕ}
    (arr : HyperplaneArrangement n m) :
    Set.univ ∈ ActivationBooleanAlgebra arr := by
  refine ⟨Finset.univ, ?_⟩
  rw [← activationRegions_union_univ arr]
  ext x
  simp [Set.mem_iUnion]

/-- The activation Boolean algebra is closed under union. -/
theorem ActivationBooleanAlgebra.union_mem {n m : ℕ}
    (arr : HyperplaneArrangement n m) {S T : Set (Fin n → ℝ)}
    (hS : S ∈ ActivationBooleanAlgebra arr)
    (hT : T ∈ ActivationBooleanAlgebra arr) :
    S ∪ T ∈ ActivationBooleanAlgebra arr := by
  obtain ⟨P, rfl⟩ := hS
  obtain ⟨Q, rfl⟩ := hT
  refine ⟨P ∪ Q, ?_⟩
  ext x
  simp only [Set.mem_union, Set.mem_iUnion, Finset.mem_union]
  constructor
  · rintro (⟨σ, hσP, hx⟩ | ⟨σ, hσQ, hx⟩)
    · exact ⟨σ, Or.inl hσP, hx⟩
    · exact ⟨σ, Or.inr hσQ, hx⟩
  · rintro ⟨σ, hσ, hx⟩
    rcases hσ with hσP | hσQ
    · left; exact ⟨σ, hσP, hx⟩
    · right; exact ⟨σ, hσQ, hx⟩

/-- The activation Boolean algebra is closed under complement.
    The complement of a union of activation regions is the union of the
    complementary regions — because activation regions partition the space. -/
theorem ActivationBooleanAlgebra.compl_mem {n m : ℕ}
    (arr : HyperplaneArrangement n m) {S : Set (Fin n → ℝ)}
    (hS : S ∈ ActivationBooleanAlgebra arr) :
    Sᶜ ∈ ActivationBooleanAlgebra arr := by
  obtain ⟨P, rfl⟩ := hS
  exact ⟨Finset.univ \ P, by
    ext x
    simp only [Set.mem_compl_iff, Set.mem_iUnion, exists_prop,
      Finset.mem_sdiff, Finset.mem_univ, true_and]
    constructor
    · intro hNotIn
      have hx := activationRegions_cover arr x
      exact ⟨activationPatternOf arr x,
        fun hmem => hNotIn ⟨activationPatternOf arr x, hmem, hx⟩, hx⟩
    · rintro ⟨σ, hσ, hx⟩ ⟨τ, hτ, hxτ⟩
      have heq : σ = τ := by
        simp [activationRegion] at hx hxτ
        rw [← hx, ← hxτ]
      exact hσ (heq ▸ hτ)⟩

/-- The activation Boolean algebra is closed under intersection. -/
theorem ActivationBooleanAlgebra.inter_mem {n m : ℕ}
    (arr : HyperplaneArrangement n m) {S T : Set (Fin n → ℝ)}
    (hS : S ∈ ActivationBooleanAlgebra arr)
    (hT : T ∈ ActivationBooleanAlgebra arr) :
    S ∩ T ∈ ActivationBooleanAlgebra arr := by
  -- S ∩ T = (Sᶜ ∪ Tᶜ)ᶜ, use closure under complement and union
  have h1 : Sᶜ ∈ ActivationBooleanAlgebra arr := compl_mem arr hS
  have h2 : Tᶜ ∈ ActivationBooleanAlgebra arr := compl_mem arr hT
  have h3 : Sᶜ ∪ Tᶜ ∈ ActivationBooleanAlgebra arr := union_mem arr h1 h2
  have h4 : (Sᶜ ∪ Tᶜ)ᶜ ∈ ActivationBooleanAlgebra arr := compl_mem arr h3
  rwa [Set.compl_union, compl_compl, compl_compl] at h4

/-! ## Section 4: ReLU Networks and their Activation Algebras -/

/-- A single-layer ReLU network: weight matrix `W`, bias vector `b`.
    Computes `x ↦ max(W x + b, 0)` componentwise. -/
structure ReluLayer (n_in n_out : ℕ) where
  W : Matrix (Fin n_out) (Fin n_in) ℝ
  bias : Fin n_out → ℝ

/-- Extract the hyperplane arrangement from a ReLU layer.
    Each row of the weight matrix defines a hyperplane. -/
def ReluLayer.toArrangement {n_in n_out : ℕ}
    (layer : ReluLayer n_in n_out) : HyperplaneArrangement n_in n_out :=
  { planes := fun i => ⟨fun j => layer.W i j, layer.bias i⟩ }

/-- The pre-activation value of neuron `i` at input `x`. -/
def ReluLayer.preactivation {n_in n_out : ℕ}
    (layer : ReluLayer n_in n_out) (x : Fin n_in → ℝ) (i : Fin n_out) : ℝ :=
  (layer.toArrangement.planes i).eval x

/-- The ReLU function: `max(t, 0)`. -/
def relu (t : ℝ) : ℝ := max t 0

/-- ReLU is piecewise linear with exactly two pieces. -/
theorem relu_eq_ite (t : ℝ) : relu t = if 0 < t then t else 0 := by
  unfold relu
  split_ifs with h
  · exact max_eq_left (le_of_lt h)
  · push_neg at h
    exact max_eq_right h

/-- ReLU is nonneg -/
theorem relu_nonneg (t : ℝ) : 0 ≤ relu t := le_max_right t 0

/-- ReLU of a positive value is the value itself. -/
theorem relu_of_pos {t : ℝ} (h : 0 < t) : relu t = t :=
  max_eq_left (le_of_lt h)

/-- ReLU of a nonpositive value is zero. -/
theorem relu_of_nonpos {t : ℝ} (h : t ≤ 0) : relu t = 0 :=
  max_eq_right h

/-- The activation pattern determines the ReLU output:
    if the pattern says active, output = pre-activation;
    if inactive, output = 0. This is the key linearity property. -/
theorem relu_determined_by_pattern {n_in n_out : ℕ}
    (layer : ReluLayer n_in n_out) (x : Fin n_in → ℝ)
    (i : Fin n_out) :
    relu (layer.preactivation x i) =
      if (activationPatternOf layer.toArrangement x i) then
        layer.preactivation x i
      else 0 := by
  simp only [activationPatternOf, relu, ReluLayer.preactivation]
  split_ifs with h
  · simp at h
    exact max_eq_left (le_of_lt h)
  · simp at h
    exact max_eq_right h

/-! ## Section 5: Tropical Geometry Connection

The activation pattern of a ReLU network has a direct tropical interpretation.
A ReLU network computes a **tropical rational function** — the domains of linearity
correspond exactly to activation regions.

This establishes: **Machine Learning ↔ Tropical Geometry**. -/

/-- A single-layer ReLU network with a linear readout defines a family of
    affine functions indexed by activation patterns. On each activation region,
    the network output equals the corresponding affine function. -/
def reluLayerToTropical {n_in n_out : ℕ}
    (layer : ReluLayer n_in n_out) (readout : Fin n_out → ℝ) (c : ℝ) :
    ActivationPattern n_out → (Fin n_in → ℝ) → ℝ :=
  fun σ x =>
    c + ∑ i : Fin n_out,
      if σ i then readout i * ((layer.toArrangement.planes i).eval x) else 0

/-- On each activation region, the ReLU network equals the corresponding
    affine function from the tropical representation. This theorem establishes
    that ReLU networks are piecewise affine, with pieces indexed by
    activation patterns — the fundamental connection to tropical geometry. -/
theorem relu_equals_tropical_on_region {n_in n_out : ℕ}
    (layer : ReluLayer n_in n_out) (readout : Fin n_out → ℝ) (c : ℝ)
    (σ : ActivationPattern n_out) (x : Fin n_in → ℝ)
    (hx : x ∈ activationRegion layer.toArrangement σ) :
    c + ∑ i, readout i * relu (layer.preactivation x i) =
    reluLayerToTropical layer readout c σ x := by
  unfold reluLayerToTropical
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  rw [relu_determined_by_pattern]
  have hpat : activationPatternOf layer.toArrangement x = σ := hx
  rw [hpat]
  split_ifs <;> simp [ReluLayer.preactivation]

/-! ## Section 6: VC Dimension and Shattering

The VC dimension of a binary classifier based on a hyperplane arrangement
is bounded by the number of possible activation patterns. -/

/-- A hypothesis class shatters a set if every labeling is realized. -/
def Shatters' {X : Type*} (H : Set (X → Bool)) (S : Finset X) : Prop :=
  ∀ f : S → Bool, ∃ h ∈ H, ∀ x : S, h x.val = f x

/-- A binary classifier induced by a hyperplane arrangement. -/
def arrangementClassifier {n m : ℕ} (arr : HyperplaneArrangement n m)
    (positive : Finset (ActivationPattern m)) : (Fin n → ℝ) → Bool :=
  fun x => decide ((activationPatternOf arr x) ∈ positive)

/-- The class of all binary classifiers definable by a hyperplane arrangement. -/
def arrangementHypothesisClass {n m : ℕ}
    (arr : HyperplaneArrangement n m) : Set ((Fin n → ℝ) → Bool) :=
  {h | ∃ P : Finset (ActivationPattern m), h = arrangementClassifier arr P}

/-
**Shattering bound**: If a set `S` is shattered by the arrangement
    hypothesis class, then `|S| ≤ 2^m`.

    Proof sketch: The classification of any point depends only on its
    activation pattern. Points with the same pattern always get the same
    label. So the number of distinct dichotomies on `S` is at most
    `2^(|image of pattern map on S|) ≤ 2^(2^m)`. But shattering needs
    `2^|S|` dichotomies, which requires the pattern map to be injective
    on `S`, giving `|S| ≤ |Fin m → Bool| = 2^m`.
-/
theorem shattered_card_le_two_pow {n m : ℕ}
    (arr : HyperplaneArrangement n m)
    (S : Finset (Fin n → ℝ))
    (hS : Shatters' (arrangementHypothesisClass arr) S) :
    S.card ≤ 2 ^ m := by
  -- The activation pattern map is injective on S.
  have h_inj : S.card ≤ (Finset.image (fun x => activationPatternOf arr x) S).card := by
    contrapose! hS;
    -- If the activation pattern map is not injective on S, then � there� exist distinct elements x and y in S such that activationPatternOf arr x = activationPatternOf arr y.
    obtain ⟨x, y, hxy, h_eq⟩ : ∃ x y : Fin n → ℝ, x ∈ S ∧ y ∈ S ∧ x ≠ y ∧ activationPatternOf arr x = activationPatternOf arr y := by
      grind +suggestions;
    -- By definition of shattering, there exists a function f : S → Bool such that for all h ∈ arrangementHypothesisClass arr, h x ≠ f x or h y ≠ f y.
    unfold Shatters' at *; simp_all +decide [ arrangementHypothesisClass ];
    refine' ⟨ fun z => if z.val = x then Bool.true else Bool.false, fun P => _ ⟩ ; simp_all +decide [ arrangementClassifier ];
    grind;
  exact h_inj.trans ( le_trans ( Finset.card_le_univ _ ) ( by norm_num ) )

/-! ## Section 7: Zaslavsky Bound -/

/-- Zaslavsky number: the upper bound on regions for `m` hyperplanes in ℝⁿ. -/
def zaslavskyBound (n m : ℕ) : ℕ :=
  ∑ k ∈ Finset.range (n + 1), m.choose k

/-- For `m = 3, n = 2`, the Zaslavsky bound is 7. -/
theorem zaslavsky_3_2 : zaslavskyBound 2 3 = 7 := by
  unfold zaslavskyBound
  simp [Finset.sum_range_succ]

/-- The Zaslavsky bound is monotone in `m`. -/
theorem zaslavsky_mono_m (n : ℕ) {m₁ m₂ : ℕ} (hm : m₁ ≤ m₂) :
    zaslavskyBound n m₁ ≤ zaslavskyBound n m₂ := by
  unfold zaslavskyBound
  apply Finset.sum_le_sum
  intro k _
  exact Nat.choose_le_choose k hm

/-
The Zaslavsky bound is at most `2^m`.
-/
theorem zaslavsky_le_two_pow (n m : ℕ) :
    zaslavskyBound n m ≤ 2 ^ m := by
  rw [ ← Nat.sum_range_choose ];
  by_cases h : n < m;
  · exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( by linarith ) );
  · unfold zaslavskyBound; simp +decide [ Finset.sum_range_succ' ] ;
    rw [ ← Finset.sum_range_add_sum_Ico _ ( by linarith : m ≤ n ) ];
    simp +arith +decide [ Nat.choose_eq_zero_of_lt, Finset.sum_Ico_eq_sum_range ]

/-! ## Section 8: Stone Space Structure -/

/-- The **Stone point** of an input `x` is its activation pattern.
    This is the "Stone dual" map: it sends a point in the semantic space
    to a point in the syntax space (the Stone space). -/
def stonePoint {n m : ℕ} (arr : HyperplaneArrangement n m) :
    (Fin n → ℝ) → ActivationPattern m :=
  activationPatternOf arr

/-- The Stone map is surjective onto realized patterns. -/
theorem stonePoint_surj_realized {n m : ℕ}
    (arr : HyperplaneArrangement n m) (σ : ActivationPattern m)
    (hσ : σ ∈ realizedPatterns arr) :
    ∃ x, stonePoint arr x = σ := by
  obtain ⟨x, hx⟩ := hσ
  exact ⟨x, hx⟩

/-- Two inputs map to the same Stone point iff they agree on which side of
    every hyperplane they lie on. This is the fundamental theorem of Stone
    duality for neural networks: the Stone dual map identifies points that
    no hyperplane can distinguish. -/
theorem stonePoint_eq_iff {n m : ℕ}
    (arr : HyperplaneArrangement n m) (x y : Fin n → ℝ) :
    stonePoint arr x = stonePoint arr y ↔
    ∀ i : Fin m, (0 < (arr.planes i).eval x ↔ 0 < (arr.planes i).eval y) := by
  unfold stonePoint activationPatternOf
  constructor
  · intro h i
    have := congr_fun h i
    simp [decide_eq_decide] at this
    exact this
  · intro h
    ext i
    simp [decide_eq_decide]
    exact h i

/-- The Stone dual map preserves the Boolean algebra structure:
    a set `S` is in the activation Boolean algebra iff it is a union
    of fibers of the Stone point map. -/
theorem stone_dual_characterization {n m : ℕ}
    (arr : HyperplaneArrangement n m) (S : Set (Fin n → ℝ)) :
    S ∈ ActivationBooleanAlgebra arr ↔
    ∃ T : Finset (ActivationPattern m), S = stonePoint arr ⁻¹' (T : Set _) := by
  constructor
  · rintro ⟨P, rfl⟩
    refine ⟨P, ?_⟩
    ext x
    simp [stonePoint, activationRegion, Set.mem_preimage, Set.mem_iUnion]
  · rintro ⟨T, rfl⟩
    refine ⟨T, ?_⟩
    ext x
    simp [stonePoint, activationRegion, Set.mem_preimage, Set.mem_iUnion]

/-! ## Section 9: Falsifiable Conjecture

**Conjecture** (Stone-VC Equality): For a generic single-hidden-layer ReLU network
with `m` neurons in ℝⁿ where `m ≥ n`, the number of realized activation patterns
(atoms of the activation Boolean algebra) equals the Zaslavsky bound
`∑_{k=0}^{n} C(m,k)`.

**Computational test**: For `m = 3, n = 2`, we should get exactly 7 regions
for a generic arrangement. Verify by random sampling.

This is a known result (Zaslavsky 1975) for generic arrangements, but stating it
for neural networks provides a bridge between combinatorics and machine learning. -/

/-- **Upper bound**: The number of realized activation patterns is at most `2^m`.
    This is always true regardless of genericity. -/
theorem regions_le_two_pow {n m : ℕ}
    (arr : HyperplaneArrangement n m) :
    Fintype.card {σ : ActivationPattern m | (activationRegion arr σ).Nonempty} ≤ 2 ^ m :=
  realized_patterns_card_le arr

end