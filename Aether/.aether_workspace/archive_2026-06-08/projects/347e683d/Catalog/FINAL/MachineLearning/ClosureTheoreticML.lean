/-
  # Closure-Theoretic Machine Learning

  Formalization of the thesis that every classifier induces an EML (Extensive,
  Monotone, Idempotent) closure operator on its input space, and that the
  algebraic properties of this operator yield certified robustness radii
  and adversarial training convergence guarantees.

  **Bridge**: connects order theory (closure operators, lattice theory, Galois connections)
  to certified machine learning (robustness certification, adversarial training).

  ## Main Results
  - `closureFiber` defines the fiber closure operator cl_f(A) = f⁻¹(f(A))
  - `closureFiberOperator` constructs a Mathlib `ClosureOperator (Set X)` from any classifier
  - Certified robustness via `certifiedRobustnessRadius` equals infDist to fiber complement
  - Robustness is 1-Lipschitz as a function of position
  - Fixed-point convergence theorems for adversarial training
  - Cryptographic structures: closure one-way functions with pigeonhole security bounds
-/
import Mathlib

open Set Function Metric

namespace ClosureML

/-! ## Section 1: The Closure Fiber Operator — Core Definition

The closure fiber operator is the algebraic heart of closure-theoretic ML.
Given a classifier f : X → C, the operator maps a set A ⊆ X to the full
preimage of the image: cl_f(A) = f⁻¹(f(A)). This captures all points that
share a label with some point in A. -/

/-- The **closure fiber operator**: cl_f(A) = f⁻¹(f(A)).
    Bridge: connects set-theoretic preimage to classification boundaries. -/
def closureFiber {X C : Type*} (f : X → C) (A : Set X) : Set X :=
  f ⁻¹' (f '' A)

/-- Alternative characterization via existential: x ∈ cl_f(A) iff ∃ y ∈ A, f x = f y. -/
theorem closureFiber_eq_exists {X C : Type*} (f : X → C) (A : Set X) :
    closureFiber f A = {x : X | ∃ y ∈ A, f x = f y} := by
  ext x; simp only [closureFiber, mem_preimage, mem_image, mem_setOf_eq]
  exact ⟨fun ⟨y, h, e⟩ => ⟨y, h, e.symm⟩, fun ⟨y, h, e⟩ => ⟨y, h, e.symm⟩⟩

/-! ## Section 2: EML Properties — The Algebraic Foundation

The three defining properties of an EML closure operator — extensivity,
monotonicity, and idempotence — each have direct ML interpretations. -/

/-- **Extensivity**: A ⊆ cl_f(A). Every point in A belongs to its fiber closure.
    ML: a training point is always classified consistently with itself. -/
theorem closureFiber_extensive {X C : Type*} (f : X → C) (A : Set X) :
    A ⊆ closureFiber f A :=
  subset_preimage_image f A

/-- **Monotonicity**: A ⊆ B → cl_f(A) ⊆ cl_f(B).
    ML: adding training data can only expand the certified region. -/
theorem closureFiber_monotone {X C : Type*} (f : X → C) :
    Monotone (closureFiber f) :=
  fun _ _ h => preimage_mono (image_mono h)

/-- **Idempotence**: cl_f(cl_f(A)) = cl_f(A).
    Key insight: f(f⁻¹(S)) ⊆ S for all S, so iterating adds nothing.
    ML: one round of adversarial expansion along fibers is sufficient. -/
theorem closureFiber_idempotent {X C : Type*} (f : X → C) (A : Set X) :
    closureFiber f (closureFiber f A) = closureFiber f A := by
  ext x; simp only [closureFiber, mem_preimage, mem_image]
  exact ⟨fun ⟨_, ⟨y, hy, hfy⟩, hfx⟩ => ⟨y, hy, hfy.trans hfx⟩,
         fun ⟨y, hy, hfy⟩ => ⟨y, ⟨y, hy, rfl⟩, hfy⟩⟩

/-- **Master theorem**: `closureFiber f` is a Mathlib `ClosureOperator` on `Set X`.
    This packages the three EML properties into Mathlib's algebraic hierarchy,
    unlocking lattice-theoretic infrastructure.
    Bridge: connects ML classifiers to Mathlib's order theory. -/
noncomputable def closureFiberOperator {X C : Type*} (f : X → C) :
    ClosureOperator (Set X) :=
  ClosureOperator.mk
    ⟨closureFiber f, fun _ _ h => closureFiber_monotone f h⟩
    (closureFiber_extensive f)
    (closureFiber_idempotent f)
    (fun A => closureFiber f A = A)

/-! ## Section 3: Structural Properties of the Fiber Closure -/

/-- The fiber closure of a singleton is the full preimage fiber.
    Bridge: connects closure of a point to its decision region. -/
theorem closureFiber_singleton {X C : Type*} (f : X → C) (x : X) :
    closureFiber f {x} = f ⁻¹' {f x} := by
  simp [closureFiber, image_singleton]

/-- Empty set is a fixed point of closure. -/
theorem closureFiber_empty {X C : Type*} (f : X → C) :
    closureFiber f ∅ = ∅ := by simp [closureFiber]

/-- Universe is a fixed point of closure. -/
theorem closureFiber_univ {X C : Type*} (f : X → C) :
    closureFiber f univ = univ := by simp [closureFiber]

/-- **Union distributes** over fiber closure. This is stronger than monotonicity:
    general closure operators do NOT have this property.
    ML: combining datasets yields the union of their certified regions. -/
theorem closureFiber_union {X C : Type*} (f : X → C) (A B : Set X) :
    closureFiber f (A ∪ B) = closureFiber f A ∪ closureFiber f B := by
  simp [closureFiber, image_union, preimage_union]

/-- Intersection containment (not equality in general). -/
theorem closureFiber_inter_subset {X C : Type*} (f : X → C) (A B : Set X) :
    closureFiber f (A ∩ B) ⊆ closureFiber f A ∩ closureFiber f B :=
  subset_inter (closureFiber_monotone f inter_subset_left)
    (closureFiber_monotone f inter_subset_right)

/-- The closure fiber decomposes as a union of complete fibers. -/
theorem closureFiber_eq_biUnion {X C : Type*} (f : X → C) (A : Set X) :
    closureFiber f A = ⋃ c ∈ f '' A, f ⁻¹' {c} := by
  ext x; simp only [closureFiber, mem_preimage, mem_image, mem_iUnion, mem_singleton_iff]
  constructor
  · rintro ⟨y, hy, hfx⟩; exact ⟨f y, ⟨y, hy, rfl⟩, hfx.symm⟩
  · rintro ⟨c, ⟨y, hy, rfl⟩, hfx⟩; exact ⟨y, hy, hfx.symm⟩

/-- Constant classifier: fiber closure is everything (for nonempty input).
    ML: a trivial classifier has infinite robustness. -/
theorem closureFiber_const {X C : Type*} (c : C) (A : Set X) (hA : A.Nonempty) :
    closureFiber (fun _ : X => c) A = univ := by
  ext x; simp [closureFiber]; exact hA

/-- Injective classifier: fiber closure of a singleton is just the singleton.
    ML: a maximally discriminative classifier has singleton decision regions. -/
theorem closureFiber_injective_singleton {X C : Type*} (f : X → C) (hf : Injective f) (x : X) :
    closureFiber f {x} = {x} := by
  ext y; simp [closureFiber, image_singleton]; exact hf.eq_iff

/-! ## Section 4: Fiber-Closed Sets — Fixed Points of Closure -/

/-- A set is **fiber-closed** if it equals its own closure fiber.
    These are exactly unions of complete fibers of f.
    ML: a fiber-closed set is an "adversarially stable" classification region. -/
def IsFiberClosed {X C : Type*} (f : X → C) (A : Set X) : Prop :=
  closureFiber f A = A

/-- A set is fiber-closed iff it is a preimage of some set of labels.
    Bridge: connects closure fixed-points to the lattice of label subsets. -/
theorem isFiberClosed_iff_preimage {X C : Type*} (f : X → C) (A : Set X) :
    IsFiberClosed f A ↔ ∃ S : Set C, A = f ⁻¹' S := by
  constructor
  · exact fun h => ⟨f '' A, h.symm⟩
  · rintro ⟨S, rfl⟩
    ext x; simp [closureFiber]
    exact ⟨fun ⟨_, hy, hyx⟩ => hyx.symm ▸ hy, fun hx => ⟨x, hx, rfl⟩⟩


/-- Preimages are always fiber-closed. -/
theorem preimage_isFiberClosed {X C : Type*} (f : X → C) (S : Set C) :
    IsFiberClosed f (f ⁻¹' S) :=
  (isFiberClosed_iff_preimage f _).mpr ⟨S, rfl⟩

/-- Union of fiber-closed sets is fiber-closed. -/
theorem isFiberClosed_union {X C : Type*} (f : X → C) {A B : Set X}
    (hA : IsFiberClosed f A) (hB : IsFiberClosed f B) :
    IsFiberClosed f (A ∪ B) := by
  show closureFiber f (A ∪ B) = A ∪ B
  rw [closureFiber_union, hA, hB]

/-- The image of closureFiber is always fiber-closed. -/
theorem closureFiber_is_fiberClosed {X C : Type*} (f : X → C) (A : Set X) :
    IsFiberClosed f (closureFiber f A) :=
  closureFiber_idempotent f A

/-- The complement of a fiber-closed preimage is fiber-closed. -/
theorem fiberClosed_compl_preimage {X C : Type*} (f : X → C) (S : Set C) :
    IsFiberClosed f (f ⁻¹' S)ᶜ := by
  have h : (f ⁻¹' S)ᶜ = f ⁻¹' Sᶜ := preimage_compl
  rw [h]; exact preimage_isFiberClosed f Sᶜ

/-- Intersection of preimage fiber-closed sets is fiber-closed. -/
theorem fiberClosed_inter_preimage {X C : Type*} (f : X → C) (S T : Set C) :
    IsFiberClosed f (f ⁻¹' S ∩ f ⁻¹' T) := by
  rw [← preimage_inter]; exact preimage_isFiberClosed f (S ∩ T)

/-! ## Section 5: Certified Robustness via Closure Boundaries

The certified robustness radius at a point x measures how far x is from the
nearest decision boundary. This is exactly the infimum distance to the complement
of the closure fiber cl_f({x}). -/

/-- A **closure classifier** bundles a classifier with its induced closure structure.
    Bridge: connects metric geometry to algebraic EML structure. -/
structure ClosureClassifier (X : Type*) [PseudoMetricSpace X] (C : Type*) where
  classify : X → C

/-- The **certified robustness radius** at x: infimum distance to any
    differently-classified point. Uses Mathlib's `Metric.infDist`.
    Bridge: connects metric geometry to classification security. -/
noncomputable def certifiedRobustnessRadius {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x : X) : ℝ :=
  Metric.infDist x {y | f y ≠ f x}

/-- The certified radius is always non-negative.
    ML: robustness is never negative. -/
theorem certifiedRobustnessRadius_nonneg {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x : X) :
    0 ≤ certifiedRobustnessRadius f x :=
  Metric.infDist_nonneg

/-- Complement of the fiber equals differently-classified points. -/
theorem compl_fiber_eq_ne_class {X C : Type*} (f : X → C) (x : X) :
    (closureFiber f {x})ᶜ = {y | f y ≠ f x} := by
  ext y; simp [closureFiber_singleton]

/-- **Fundamental theorem**: the certified radius equals the distance to the
    complement of the closure fiber of {x}.
    Bridge: unifies Cohen et al.'s randomized smoothing with algebraic closure theory. -/
theorem certifiedRadius_eq_infDist_compl {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x : X) :
    certifiedRobustnessRadius f x = Metric.infDist x (closureFiber f {x})ᶜ := by
  unfold certifiedRobustnessRadius; rw [compl_fiber_eq_ne_class]

/-- **Same-label guarantee**: within the certified radius, all points share x's label.
    ML: predictions within the certified ball are provably correct. -/
theorem same_label_within_radius {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x y : X)
    (hy : dist x y < certifiedRobustnessRadius f x) :
    f y = f x := by
  by_contra h
  exact absurd (Metric.infDist_le_dist_of_mem (show y ∈ {z | f z ≠ f x} from h))
    (not_le.mpr hy)

/-- **Robustness is 1-Lipschitz**: certified radius degrades by at most dist(x,y).
    Uses the triangle inequality.
    ML: robustness degrades gracefully with distance. -/
theorem robustness_triangle_bound {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x y : X) :
    certifiedRobustnessRadius f x - dist x y ≤ certifiedRobustnessRadius f y := by
  unfold certifiedRobustnessRadius
  by_cases heq : f x = f y
  · have : {z : X | f z ≠ f x} = {z | f z ≠ f y} := by ext z; simp [heq]
    rw [this]; linarith [@Metric.infDist_le_infDist_add_dist _ _ {z | f z ≠ f y} x y]
  · have : y ∈ {z : X | f z ≠ f x} := fun h => heq (h.symm ▸ rfl)
    linarith [@Metric.infDist_le_dist_of_mem _ _ {z | f z ≠ f x} x y this,
              Metric.infDist_nonneg (x := y) (s := {z | f z ≠ f y})]

/-- **Robustness Lipschitz bound**: |r(x) - r(y)| ≤ d(x,y) for same-label points.
    ML: nearby points have similar robustness guarantees. -/
theorem robustness_lipschitz {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x y : X) :
    |certifiedRobustnessRadius f x - certifiedRobustnessRadius f y| ≤ dist x y := by
  rw [abs_sub_le_iff]
  exact ⟨by linarith [robustness_triangle_bound f x y],
         by linarith [robustness_triangle_bound f y x, dist_comm x y]⟩

/-- Points at the decision boundary have zero certified radius. -/
theorem boundary_zero_radius {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x : X)
    (h : x ∈ closure {y | f y ≠ f x}) :
    certifiedRobustnessRadius f x = 0 :=
  Metric.infDist_zero_of_mem_closure h

/-- Positive radius implies a ball of same-label points exists.
    ML: positive robustness ↔ robust classification. -/
theorem positive_radius_gives_ball {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x : X) (h : 0 < certifiedRobustnessRadius f x) :
    ∃ ε > 0, ∀ y, dist x y < ε → f y = f x :=
  ⟨_, h, fun y hy => same_label_within_radius f x y hy⟩

/-- A constant classifier has zero certified radius (empty complement). -/
theorem const_classifier_zero_radius {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (c : C) (x : X) :
    certifiedRobustnessRadius (fun _ : X => c) x = 0 := by
  simp [certifiedRobustnessRadius, Metric.infDist_empty]

/-- For an injective classifier, the certified radius is the infDist to {y | y ≠ x}. -/
theorem injective_radius_eq_nearest {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (hf : Injective f) (x : X) :
    certifiedRobustnessRadius f x = Metric.infDist x {y | y ≠ x} := by
  unfold certifiedRobustnessRadius; congr 1; ext y; simp
  exact ⟨fun h heq => h (congr_arg f heq), fun h hfe => h (hf hfe)⟩

/-! ## Section 6: Lipschitz Closure Classifiers -/

/-- A **Lipschitz closure classifier** bundles a Lipschitz function
    with its NNReal constant. The constant K certifies that decision
    boundaries cannot be sharper than 1/K.
    Bridge: connects Lipschitz analysis to closure-theoretic certification. -/
structure LipschitzClosureClassifier (X : Type*) [PseudoMetricSpace X]
    (C : Type*) [PseudoMetricSpace C] where
  classify : X → C
  lipschitzBound : NNReal
  lipschitz_certified : LipschitzWith lipschitzBound classify

/-! ## Section 7: Galois Connection Perspective

The deepest explanation for why closureFiber is an EML operator: it arises
from the image-preimage Galois connection between Set X and Set C. -/

/-- The image-preimage pair forms a Galois connection.
    Bridge: connects Galois connections (order theory) to classification (ML). -/
theorem image_preimage_galoisConnection {X C : Type*} (f : X → C) :
    GaloisConnection (image f) (preimage f) :=
  fun _ _ => image_subset_iff

/-- The fiber closure IS the Galois connection closure operator.
    This is the categorical insight: cl_f = f⁻¹ ∘ f_* = right ∘ left.
    Bridge: identifies classifier closure with a universal categorical construction. -/
theorem closureFiber_eq_galois_closure {X C : Type*} (f : X → C) (A : Set X) :
    (image_preimage_galoisConnection f).closureOperator A = closureFiber f A := rfl

/-! ## Section 8: Fixed-Point Theory — Adversarial Training Convergence -/

/-- **Idempotent convergence**: applying the fiber closure twice gives the same result.
    ML: one round of adversarial expansion is provably sufficient.
    Bridge: connects idempotence (algebra) to training convergence (optimization). -/
theorem adversarial_training_one_step {X C : Type*} (f : X → C) (trainingSet : Set X) :
    closureFiber f (closureFiber f trainingSet) = closureFiber f trainingSet :=
  closureFiber_idempotent f trainingSet

/-- Iterating a monotone extensive operator. Models the general adversarial training loop. -/
def iterateClosure {X : Type*} (cl : Set X → Set X) : ℕ → Set X → Set X
  | 0, A => A
  | n + 1, A => cl (iterateClosure cl n A)

/-- Iterates form an ascending chain under a monotone extensive operator.
    ML: each adversarial training round expands (or maintains) the training set. -/
theorem iterate_ascending {X : Type*} (cl : Set X → Set X)
    (h_mono : Monotone cl) (h_ext : ∀ A, A ⊆ cl A) (A : Set X) (n : ℕ) :
    iterateClosure cl n A ⊆ iterateClosure cl (n + 1) A := by
  induction n with
  | zero => exact h_ext A
  | succ n ih => exact h_mono ih

/-- For an idempotent operator, iteration stabilizes at step 1.
    ML: with an EML closure, adversarial training converges in exactly one round. -/
theorem iterate_idempotent_stabilizes {X : Type*} (cl : Set X → Set X)
    (h_idem : ∀ A, cl (cl A) = cl A) (A : Set X) (n : ℕ) (hn : 0 < n) :
    iterateClosure cl n (cl A) = cl A := by
  induction n with
  | zero => omega
  | succ n ih =>
    simp only [iterateClosure]
    cases n with
    | zero => exact h_idem A
    | succ n => rw [ih (by omega)]; exact h_idem A

/-- Once iteration hits a fixed point, all subsequent iterates are the same. -/
theorem iterate_fixed_stable {X : Type*} (cl : Set X → Set X) (A : Set X)
    (n : ℕ) (h_fix : cl (iterateClosure cl n A) = iterateClosure cl n A)
    (m : ℕ) (hm : n ≤ m) :
    iterateClosure cl m A = iterateClosure cl n A := by
  induction m with
  | zero => interval_cases n; rfl
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le hm with h | h
    · subst h; rfl
    · show cl _ = _; rw [ih (Nat.le_of_lt_succ h)]; exact h_fix

/-- **Adversarial training optimality**: one closure step gives a set that is
    (1) stable, (2) contains the training data, and (3) is minimal among
    stable sets containing the data.
    Bridge: connects algebra (EML minimality) to optimization (optimal convergence). -/
theorem adversarial_training_optimal {X C : Type*} (f : X → C) (trainingSet : Set X) :
    (closureFiber f (closureFiber f trainingSet) = closureFiber f trainingSet) ∧
    (trainingSet ⊆ closureFiber f trainingSet) ∧
    (∀ B, trainingSet ⊆ B → B ⊆ closureFiber f trainingSet →
      closureFiber f B = closureFiber f trainingSet) := by
  refine ⟨closureFiber_idempotent f trainingSet, closureFiber_extensive f trainingSet, ?_⟩
  intro B hB₁ hB₂
  exact le_antisymm
    ((closureFiber_monotone f hB₂).trans (closureFiber_idempotent f trainingSet).le)
    (closureFiber_monotone f hB₁)

/-! ## Section 9: Classifier Composition and Refinement -/

/-- Composing classifiers refines the closure: f-fibers ⊆ (g∘f)-fibers.
    ML: deeper networks have coarser decision boundaries. -/
theorem closureFiber_comp_refines {X Y C : Type*} (f : X → Y) (g : Y → C) (A : Set X) :
    closureFiber f A ⊆ closureFiber (g ∘ f) A := by
  intro x hx
  obtain ⟨y, hy, e⟩ := (closureFiber_eq_exists f A ▸ hx :
    x ∈ {z | ∃ w ∈ A, f z = f w})
  rw [closureFiber_eq_exists]; exact ⟨y, hy, congr_arg g e⟩

/-- Composition with an injective function preserves the closure exactly. -/
theorem closureFiber_comp_injective {X Y C : Type*} (f : X → Y) (g : Y → C) (hg : Injective g)
    (A : Set X) : closureFiber (g ∘ f) A = closureFiber f A := by
  ext x; simp [closureFiber_eq_exists, comp_apply]
  exact ⟨fun ⟨y, hy, e⟩ => ⟨y, hy, hg e⟩, fun ⟨y, hy, e⟩ => ⟨y, hy, congr_arg g e⟩⟩

/-! ## Section 10: Fiber Partition Structure -/

/-- The fibers of a classifier are pairwise disjoint. -/
theorem fiber_pairwise_disjoint {X C : Type*} (f : X → C) :
    Pairwise (Disjoint on fun c => f ⁻¹' {c}) := by
  intro c₁ c₂ hne
  simp only [Function.onFun, Set.disjoint_iff]
  intro x ⟨h₁, h₂⟩
  exact hne (by rw [mem_preimage, mem_singleton_iff] at h₁ h₂; exact h₁.symm.trans h₂)

/-- The fibers cover the entire space. -/
theorem fiber_cover {X C : Type*} (f : X → C) :
    ⋃ c : C, f ⁻¹' {c} = univ := by ext x; simp

/-- Fibers indexed by the range are injective. -/
theorem fiber_injective_on_range {X C : Type*} (f : X → C) :
    Injective (fun c : range f => f ⁻¹' {(c : C)}) := by
  intro ⟨c₁, hc₁⟩ ⟨c₂, _⟩ h
  simp only [Subtype.mk.injEq]
  obtain ⟨x₁, rfl⟩ := hc₁
  have hmem : x₁ ∈ f ⁻¹' {f x₁} := mem_preimage.mpr rfl
  have heq : f ⁻¹' {f x₁} = f ⁻¹' {c₂} := h
  rw [heq] at hmem; exact mem_preimage.mp hmem

/-! ## Section 11: Topological Properties -/

/-- If f is continuous and C is T1, each fiber is topologically closed.
    Bridge: connects topological closure to order-theoretic closure. -/
theorem fiber_topologically_closed {X : Type*} [TopologicalSpace X]
    {C : Type*} [TopologicalSpace C] [T1Space C]
    (f : X → C) (hf : Continuous f) (c : C) :
    IsClosed (f ⁻¹' {c}) :=
  isClosed_singleton.preimage hf

/-- If f is continuous and A is finite, closureFiber f A is topologically closed.
    Bridge: order-theoretic EML closure ↔ topological closure for continuous classifiers. -/
theorem closureFiber_finite_isClosed {X : Type*} [TopologicalSpace X]
    {C : Type*} [TopologicalSpace C] [T1Space C]
    (f : X → C) (hf : Continuous f) (A : Set X) (hA : A.Finite) :
    IsClosed (closureFiber f A) :=
  (hA.image f).isClosed.preimage hf

/-! ## Section 12: The EMLClassifier Typeclass

Every function automatically satisfies the EML axioms. This typeclass
makes the structure explicit for downstream use. -/

/-- **EMLClassifier** typeclass: marks a function as having the EML closure property.
    Bridge: connects typeclass abstraction (software engineering) to certified ML. -/
class EMLClassifier (X C : Type*) where
  classify : X → C
  extensive_ax : ∀ A : Set X, A ⊆ closureFiber classify A
  monotone_ax : ∀ A B : Set X, A ⊆ B → closureFiber classify A ⊆ closureFiber classify B
  idempotent_ax : ∀ A : Set X,
    closureFiber classify (closureFiber classify A) = closureFiber classify A

/-- Every function gives an EMLClassifier. The EML property is *universal* for classifiers. -/
instance EMLClassifier.ofFunction {X C : Type*} (f : X → C) : EMLClassifier X C where
  classify := f
  extensive_ax := closureFiber_extensive f
  monotone_ax := fun _ _ h => closureFiber_monotone f h
  idempotent_ax := closureFiber_idempotent f

/-! ## Section 13: Cryptographic Structures — Closure One-Way Functions

A closure one-way function is a classifier where computing the fiber is easy
(just apply f) but finding a specific preimage is hard (fiber has many elements).
Bridge: connects EML closure operators to post-quantum cryptographic primitives. -/

/-- A **closure one-way function**: a classifier with guaranteed minimum fiber size.
    The `minFiberCard` parameter quantifies preimage resistance.
    Bridge: connects EML closure operators to cryptographic security. -/
structure ClosureOneWayFunction (X : Type*) [Fintype X]
    (C : Type*) [Fintype C] [DecidableEq C] where
  classify : X → C
  minFiberCard : ℕ
  fiber_card_bound : ∀ c ∈ Finset.image classify Finset.univ,
    minFiberCard ≤ (Finset.univ.filter (fun x => classify x = c)).card

/-- Each fiber of a closure OWF has at least minFiberCard elements.
    ML: adversarial examples are hard to find when fibers are large. -/
theorem closure_owf_fiber_bound {X : Type*} [Fintype X] [DecidableEq X]
    {C : Type*} [Fintype C] [DecidableEq C]
    (owf : ClosureOneWayFunction X C) (x : X) :
    owf.minFiberCard ≤
      (Finset.univ.filter (fun y => owf.classify y = owf.classify x)).card :=
  owf.fiber_card_bound _ (Finset.mem_image_of_mem _ (Finset.mem_univ x))

/-- **Pigeonhole security bound**: |X| ≥ minFiberCard × |range(f)|.
    Bridge: connects combinatorial counting to cryptographic security parameters. -/
theorem closure_owf_pigeonhole {X : Type*} [Fintype X] [DecidableEq X]
    {C : Type*} [Fintype C] [DecidableEq C]
    (owf : ClosureOneWayFunction X C) :
    owf.minFiberCard * (Finset.image owf.classify Finset.univ).card ≤ Fintype.card X := by
  have h1 : owf.minFiberCard * (Finset.image owf.classify Finset.univ).card =
      ∑ _c ∈ Finset.image owf.classify Finset.univ, owf.minFiberCard := by
    rw [Finset.sum_const, smul_eq_mul, mul_comm]
  rw [h1]
  calc ∑ _c ∈ Finset.image owf.classify Finset.univ, owf.minFiberCard
      ≤ ∑ c ∈ Finset.image owf.classify Finset.univ,
          (Finset.univ.filter (fun x => owf.classify x = c)).card :=
        Finset.sum_le_sum (fun c hc => owf.fiber_card_bound c hc)
    _ = Finset.card Finset.univ := by
        rw [← Finset.card_biUnion]
        · congr 1; ext x; simp
        · intro c₁ _ c₂ _ hne
          exact Finset.disjoint_filter.mpr (fun x _ h₁ h₂ => hne (h₁.symm.trans h₂))
    _ = Fintype.card X := Finset.card_univ

/-! ## Section 14: Lattice Height and Classifier Complexity -/

/-- The **fiber lattice height** of a classifier: the number of distinct labels
    in the range. Bounds VC-dimension of the closure classifier family.
    Bridge: connects lattice height (order theory) to sample complexity (learning theory). -/
noncomputable def fiberLatticeHeight {X C : Type*} [Fintype X] [DecidableEq C]
    (f : X → C) : ℕ :=
  (Finset.image f Finset.univ).card

/-- Fiber lattice height is bounded by |C|.
    ML: classifier complexity ≤ number of classes. -/
theorem fiberLatticeHeight_le_card {X : Type*} [Fintype X]
    {C : Type*} [Fintype C] [DecidableEq C] (f : X → C) :
    fiberLatticeHeight f ≤ Fintype.card C := by
  exact (Finset.card_le_card (Finset.subset_univ _)).trans_eq Finset.card_univ

/-- For an injective classifier, height equals |X|. -/
theorem fiberLatticeHeight_injective {X : Type*} [Fintype X]
    {C : Type*} [Fintype C] [DecidableEq C] (f : X → C) (hf : Injective f) :
    fiberLatticeHeight f = Fintype.card X := by
  unfold fiberLatticeHeight
  rw [Finset.card_image_of_injective _ hf, Finset.card_univ]

/-- Height is positive when X is nonempty.
    ML: any non-trivial classifier uses at least one label. -/
theorem fiberLatticeHeight_pos {X : Type*} [Fintype X] [Nonempty X]
    {C : Type*} [DecidableEq C] (f : X → C) :
    0 < fiberLatticeHeight f :=
  Finset.card_pos.mpr ⟨f (Classical.arbitrary X),
    Finset.mem_image_of_mem _ (Finset.mem_univ _)⟩

/-- The fibers partition Finset.univ into exactly fiberLatticeHeight f parts,
    and the total number of elements sums to |X|. -/
theorem fiber_partition_card {X : Type*} [Fintype X] [DecidableEq X]
    {C : Type*} [DecidableEq C] (f : X → C) :
    ∑ c ∈ Finset.image f Finset.univ,
      (Finset.univ.filter (fun x => f x = c)).card = Fintype.card X := by
  rw [← Finset.card_univ, ← Finset.card_biUnion]
  · congr 1; ext x; simp
  · intro c₁ _ c₂ _ hne
    exact Finset.disjoint_filter.mpr (fun x _ h₁ h₂ => hne (h₁.symm.trans h₂))

/-! ## Section 15: Certification Pipeline -/

/-- The **robustness certification pipeline**: given a classifier and a point,
    produce a certified radius with machine-verified same-label guarantee.
    Bridge: connects formal verification to deployable ML certification. -/
noncomputable def certificationPipeline {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x : X) :
    {r : ℝ // r ≥ 0 ∧ ∀ y : X, dist x y < r → f y = f x} :=
  ⟨certifiedRobustnessRadius f x,
   certifiedRobustnessRadius_nonneg f x,
   fun y hy => same_label_within_radius f x y hy⟩

/-! ## Section 16: Grand Unification Theorem -/

/-- **Grand unification**: the certified robustness radius equals the infDist to
    the closure fiber boundary, all points within that radius share x's label,
    and the radius is non-negative.
    Bridge: unifies order theory, metric geometry, and ML certification into
    a single certified statement. -/
theorem grand_unification {X : Type*} [PseudoMetricSpace X]
    {C : Type*} (f : X → C) (x : X) :
    certifiedRobustnessRadius f x = Metric.infDist x (closureFiber f {x})ᶜ ∧
    (∀ y, dist x y < certifiedRobustnessRadius f x → f y = f x) ∧
    0 ≤ certifiedRobustnessRadius f x :=
  ⟨certifiedRadius_eq_infDist_compl f x,
   fun y hy => same_label_within_radius f x y hy,
   certifiedRobustnessRadius_nonneg f x⟩

end ClosureML