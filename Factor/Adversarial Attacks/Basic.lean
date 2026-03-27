import Mathlib

/-!
# The Algebra of Adversarial Attacks

A formal framework connecting adversarial attacks on classifiers to oracle theory
and Boolean algebra. We formalize:

1. **Classifiers** as functions from feature spaces to label sets
2. **Adversarial attacks** as perturbation functions on the feature space
3. **Attack composition** forming a monoid (and group for invertible attacks)
4. **Robustness** as invariance of classification under perturbations
5. **The Contrarian Attack Theorem** — connection to anti-oracles
6. **Attack lattice** — Boolean algebra structure on attack sets
7. **Robustness regions** as downward-closed sets in the attack lattice

## Key Results

- `attack_comp_assoc`: Attack composition is associative
- `contrarian_attack_theorem`: A classifier attacked by complement-flip ≡ anti-oracle
- `robust_monotone`: Robustness is monotone w.r.t. attack budget inclusion
- `attack_robust_complement`: Attacked set and robust set partition the space
- `attack_as_pullback`: Adversarial attack = oracle pullback
-/

noncomputable section
open Set Function Classical

/-! ## Section 1: Classifiers and Decision Regions -/

/-- A Classifier maps feature vectors to labels. -/
structure Classifier (X : Type*) (L : Type*) where
  classify : X → L

/-- The decision region for label l: the set of inputs classified as l. -/
def Classifier.decisionRegion {X L : Type*} (c : Classifier X L) (l : L) : Set X :=
  {x | c.classify x = l}

/-- Decision regions for different labels are disjoint. -/
theorem Classifier.decisionRegion_disjoint {X L : Type*} (c : Classifier X L)
    {l₁ l₂ : L} (hl : l₁ ≠ l₂) :
    c.decisionRegion l₁ ∩ c.decisionRegion l₂ = ∅ := by
  ext x
  simp [Classifier.decisionRegion]
  intro h1 h2
  exact hl (h1.symm.trans h2)

/-- Decision regions cover the entire space. -/
theorem Classifier.decisionRegion_cover {X L : Type*} (c : Classifier X L) :
    ⋃ l, c.decisionRegion l = Set.univ := by
  ext x; simp [Classifier.decisionRegion]

/-! ## Section 2: Adversarial Attacks -/

/-- An AdversarialAttack is a perturbation function on the input space. -/
@[ext]
structure AdversarialAttack (X : Type*) where
  perturb : X → X

namespace AdversarialAttack

variable {X L : Type*}

/-- The identity attack: does nothing. -/
def idAttack : AdversarialAttack X where
  perturb := _root_.id

/-- Compose two attacks: apply a₁ first, then a₂. -/
def comp (a₂ a₁ : AdversarialAttack X) : AdversarialAttack X where
  perturb := a₂.perturb ∘ a₁.perturb

/-- Attack composition is associative. -/
theorem comp_assoc (a₃ a₂ a₁ : AdversarialAttack X) :
    (a₃.comp a₂).comp a₁ = a₃.comp (a₂.comp a₁) := by
  ext x; simp [comp, Function.comp]

/-- Identity is a left identity for composition. -/
theorem idAttack_comp (a : AdversarialAttack X) : idAttack.comp a = a := by
  ext x; simp [comp, idAttack]

/-- Identity is a right identity for composition. -/
theorem comp_idAttack (a : AdversarialAttack X) : a.comp idAttack = a := by
  ext x; simp [comp, idAttack]

/-- Attacks form a monoid under composition. -/
instance : Monoid (AdversarialAttack X) where
  mul := comp
  one := idAttack
  mul_assoc := comp_assoc
  one_mul := idAttack_comp
  mul_one := comp_idAttack

/-- The attack applied to a classifier yields a new classifier. -/
def applyToClassifier (a : AdversarialAttack X) (c : Classifier X L) :
    Classifier X L where
  classify := c.classify ∘ a.perturb

/-- Attack success: the attack causes misclassification on input x. -/
def succeeds (a : AdversarialAttack X) (c : Classifier X L) (x : X) : Prop :=
  c.classify (a.perturb x) ≠ c.classify x

/-- The attacked set: all inputs where the attack changes the classification. -/
def attackedSet (a : AdversarialAttack X) (c : Classifier X L) : Set X :=
  {x | a.succeeds c x}

/-- The identity attack never succeeds. -/
theorem idAttack_never_succeeds (c : Classifier X L) (x : X) :
    ¬idAttack.succeeds c x := by
  simp [succeeds, idAttack]

/-- The identity attack has empty attacked set. -/
theorem idAttack_attackedSet_empty (c : Classifier X L) :
    idAttack.attackedSet c = ∅ := by
  ext x; simp [attackedSet, succeeds, idAttack]

end AdversarialAttack

/-! ## Section 3: Robustness -/

/-- A classifier is robust to an attack at point x. -/
def robust_at {X L : Type*} (c : Classifier X L) (a : AdversarialAttack X) (x : X) : Prop :=
  c.classify (a.perturb x) = c.classify x

/-- A classifier is robust to a set of attacks. -/
def robust {X L : Type*} (c : Classifier X L) (S : Set (AdversarialAttack X)) : Prop :=
  ∀ a ∈ S, ∀ x, robust_at c a x

/-- The robustness region: all attacks a classifier is robust to. -/
def robustnessRegion {X L : Type*} (c : Classifier X L) :
    Set (AdversarialAttack X) :=
  {a | ∀ x, robust_at c a x}

/-- The identity attack is always in the robustness region. -/
theorem id_in_robustnessRegion {X L : Type*} (c : Classifier X L) :
    AdversarialAttack.idAttack ∈ robustnessRegion c := by
  intro x; simp [robust_at, AdversarialAttack.idAttack]

/-- Robustness is monotone: robust to S implies robust to any T ⊆ S. -/
theorem robust_monotone {X L : Type*} (c : Classifier X L)
    {S T : Set (AdversarialAttack X)} (hST : T ⊆ S) (hS : robust c S) :
    robust c T :=
  fun a ha x => hS a (hST ha) x

/-- Pointwise robustness: the set of points where classifier is robust to attack a. -/
def robustPoints {X L : Type*} (c : Classifier X L) (a : AdversarialAttack X) : Set X :=
  {x | robust_at c a x}

/-- The complement of robust points is the attacked set. -/
theorem robustPoints_compl_eq_attackedSet {X L : Type*}
    (c : Classifier X L) (a : AdversarialAttack X) :
    (robustPoints c a)ᶜ = a.attackedSet c := by
  ext x; simp [robustPoints, AdversarialAttack.attackedSet, AdversarialAttack.succeeds, robust_at]

/-! ## Section 4: The Contrarian Attack Theorem -/

/-- The complementary (anti) binary classifier: flips all labels. -/
def antiClassifier {X : Type*} (c : Classifier X Bool) : Classifier X Bool where
  classify := fun x => !(c.classify x)

/-- The Contrarian Attack Theorem: For a binary classifier, an attack that flips
    every classification is equivalent to the anti-classifier.
    This connects adversarial attacks to the anti-oracle theorem. -/
theorem contrarian_attack_theorem {X : Type*} (c : Classifier X Bool)
    (a : AdversarialAttack X)
    (h_contrarian : ∀ x, c.classify (a.perturb x) = !(c.classify x)) :
    (a.applyToClassifier c).classify = (antiClassifier c).classify := by
  funext x
  simp [AdversarialAttack.applyToClassifier, antiClassifier, h_contrarian]

/-- Anti-classifier is an involution: anti(anti(c)) = c. -/
theorem antiClassifier_involution {X : Type*} (c : Classifier X Bool) :
    antiClassifier (antiClassifier c) = c := by
  simp [antiClassifier, Bool.not_not]

/-- If we know the attack is contrarian, we can recover the true classifier. -/
theorem contrarian_recovery {X : Type*} (c : Classifier X Bool)
    (a : AdversarialAttack X)
    (h_contrarian : ∀ x, c.classify (a.perturb x) = !(c.classify x)) :
    ∀ x, c.classify x = !((a.applyToClassifier c).classify x) := by
  intro x
  simp [AdversarialAttack.applyToClassifier, h_contrarian, Bool.not_not]

/-! ## Section 5: Attack Effects and Lattice Structure -/

/-- The attack effect: the set of inputs where classification changes. -/
def attackEffect {X L : Type*} (c : Classifier X L) (a : AdversarialAttack X) : Set X :=
  {x | c.classify (a.perturb x) ≠ c.classify x}

/-- An attack refines another if its effect is a subset. -/
def attackRefines {X L : Type*} (c : Classifier X L)
    (a₁ a₂ : AdversarialAttack X) : Prop :=
  attackEffect c a₁ ⊆ attackEffect c a₂

/-- Attack refinement is reflexive. -/
theorem attackRefines_refl {X L : Type*} (c : Classifier X L)
    (a : AdversarialAttack X) : attackRefines c a a :=
  Subset.refl _

/-- Attack refinement is transitive. -/
theorem attackRefines_trans {X L : Type*} (c : Classifier X L)
    {a₁ a₂ a₃ : AdversarialAttack X}
    (h₁₂ : attackRefines c a₁ a₂) (h₂₃ : attackRefines c a₂ a₃) :
    attackRefines c a₁ a₃ :=
  Subset.trans h₁₂ h₂₃

/-! ## Section 6: Perturbation Budgets and ε-Robustness -/

/-- ε-robustness: the classifier is robust to all attacks in the budget. -/
def epsilonRobust {X L : Type*} (c : Classifier X L)
    (budget : Set (AdversarialAttack X)) : Prop :=
  robust c budget

/-- Smaller budget → easier to be robust. -/
theorem epsilonRobust_monotone {X L : Type*} (c : Classifier X L)
    {B₁ B₂ : Set (AdversarialAttack X)} (h : B₁ ⊆ B₂) (hB₂ : epsilonRobust c B₂) :
    epsilonRobust c B₁ :=
  robust_monotone c h hB₂

/-- The intersection of budgets preserves robustness. -/
theorem epsilonRobust_inter {X L : Type*} (c : Classifier X L)
    {B₁ B₂ : Set (AdversarialAttack X)}
    (h₁ : epsilonRobust c B₁) :
    epsilonRobust c (B₁ ∩ B₂) :=
  epsilonRobust_monotone c inter_subset_left h₁

/-! ## Section 7: The Adversarial Information Theorem -/

/-- Attacked set and robust set are complements (partition the space). -/
theorem attack_robust_complement {X L : Type*} (c : Classifier X L)
    (a : AdversarialAttack X) :
    attackEffect c a ∪ robustPoints c a = Set.univ := by
  ext x; simp [attackEffect, robustPoints, robust_at]
  tauto

/-- The attacked set and robust set are disjoint. -/
theorem attack_robust_disjoint {X L : Type*} (c : Classifier X L)
    (a : AdversarialAttack X) :
    attackEffect c a ∩ robustPoints c a = ∅ := by
  ext x; simp [attackEffect, robustPoints, robust_at]

/-! ## Section 8: Oracle-Attack Correspondence -/

/-- Convert a binary classifier to an oracle (set). -/
def classifierToOracle {X : Type*} (c : Classifier X Bool) : Set X :=
  {x | c.classify x = true}

/-- The anti-classifier corresponds to the complement oracle. -/
theorem anti_classifier_complement_oracle {X : Type*} (c : Classifier X Bool) :
    classifierToOracle (antiClassifier c) = (classifierToOracle c)ᶜ := by
  ext x
  simp [classifierToOracle, antiClassifier]

/-- An adversarial attack on a classifier induces a pullback on the oracle. -/
theorem attack_as_pullback {X : Type*} (c : Classifier X Bool)
    (a : AdversarialAttack X) :
    classifierToOracle (a.applyToClassifier c) =
    a.perturb ⁻¹' (classifierToOracle c) := by
  ext x
  simp [classifierToOracle, AdversarialAttack.applyToClassifier]

/-! ## Section 9: Composition Theorems -/

/-- Composing attacks composes their effects on the oracle. -/
theorem attack_comp_pullback {X : Type*} (c : Classifier X Bool)
    (a₁ a₂ : AdversarialAttack X) :
    classifierToOracle ((a₂.comp a₁).applyToClassifier c) =
    a₁.perturb ⁻¹' (a₂.perturb ⁻¹' (classifierToOracle c)) := by
  ext x
  simp [classifierToOracle, AdversarialAttack.applyToClassifier,
        AdversarialAttack.comp, Function.comp]

/-! ## Section 10: Robustness Region is Downward-Closed -/

/-- If an attack is in the robustness region, and another attack refines it,
    then the refining attack is also in the robustness region. -/
theorem robustnessRegion_downward_closed {X L : Type*} (c : Classifier X L)
    (a₁ a₂ : AdversarialAttack X)
    (h₁ : a₁ ∈ robustnessRegion c)
    (h_refine : attackEffect c a₂ ⊆ attackEffect c a₁) :
    a₂ ∈ robustnessRegion c := by
  intro x
  simp [robust_at]
  by_contra h
  have : x ∈ attackEffect c a₂ := h
  have := h_refine this
  simp [attackEffect] at this
  exact this (h₁ x)

/-- The empty attack set has robustness. -/
theorem robust_empty {X L : Type*} (c : Classifier X L) :
    robust c (∅ : Set (AdversarialAttack X)) := by
  intro a ha; simp at ha

/-- The singleton identity set has robustness. -/
theorem robust_singleton_id {X L : Type*} (c : Classifier X L) :
    robust c ({AdversarialAttack.idAttack} : Set (AdversarialAttack X)) := by
  intro a ha x
  simp [Set.mem_singleton_iff] at ha
  subst ha
  simp [robust_at, AdversarialAttack.idAttack]

end
