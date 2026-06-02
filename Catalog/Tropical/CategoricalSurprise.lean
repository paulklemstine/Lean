/-
# The Category Theory of Surprise: Universal Properties of Humor

This module formalizes a mathematical theory of "surprise" inspired by the
categorical structure of jokes. The key insight is that humor arises from
the distance between expected and actual outcomes — a concept made precise
using metric spaces, order theory, and information theory.

## Main Results

* `fundamental_theorem_of_comedy` — In compact spaces, the supremum of surprise is attained
* `infoSurprise_antitone` — Rarer events are more surprising (monotonicity)
* `infoSurprise_mul` — Surprise is additive for independent events
* `max_humor_iff_no_resolution` — Absurdist humor achieves maximum impact
* `gap_triangle` — Surprise gap satisfies a triangle inequality
-/

import Mathlib

open Real Set Filter Topology

/-! ## Part 1: Surprise Spaces -/

/-- A surprise space: a pseudo-metric space with a distinguished "expected" element. -/
structure SurpriseSpace (α : Type*) [PseudoMetricSpace α] where
  expected : α

namespace SurpriseSpace

variable {α : Type*} [PseudoMetricSpace α] (S : SurpriseSpace α)

/-- The surprise value of an element: its distance from the expected element. -/
noncomputable def surprise (x : α) : ℝ := dist x S.expected

theorem surprise_nonneg (x : α) : 0 ≤ S.surprise x := dist_nonneg

theorem surprise_expected : S.surprise S.expected = 0 := dist_self S.expected

/-- **Surprise Triangle Bound**: Each additional twist adds at most its own
deviation to the total surprise. -/
theorem surprise_triangle_bound (x y : α) :
    S.surprise y ≤ S.surprise x + dist y x := by
  unfold surprise
  linarith [dist_triangle y x S.expected]

/-- Nearby punchlines have similar surprise values. -/
theorem surprise_lipschitz (x y : α) :
    |S.surprise x - S.surprise y| ≤ dist x y := by
  unfold surprise
  exact abs_dist_sub_le x y S.expected

theorem surprise_continuous : Continuous S.surprise :=
  Continuous.dist continuous_id continuous_const

end SurpriseSpace

/-! ## Part 2: The Humor Metric -/

/-- A joke: an expected resolution paired with an actual punchline. -/
structure Joke (α : Type*) [PseudoMetricSpace α] where
  expectedResolution : α
  actualPunchline : α

namespace Joke

variable {α : Type*} [PseudoMetricSpace α]

noncomputable def humorValue (J : Joke α) : ℝ :=
  dist J.expectedResolution J.actualPunchline

theorem humor_nonneg (J : Joke α) : 0 ≤ J.humorValue := dist_nonneg

theorem humor_zero_of_expected (J : Joke α) (h : J.expectedResolution = J.actualPunchline) :
    J.humorValue = 0 := by
  unfold humorValue; rw [h]; exact dist_self _

/-- **Humor Symmetry**: Anti-jokes are equally funny. -/
theorem humor_symmetric (J : Joke α) :
    J.humorValue = (Joke.mk J.actualPunchline J.expectedResolution).humorValue := by
  unfold humorValue; exact dist_comm _ _

def humorEquiv (J₁ J₂ : Joke α) : Prop := J₁.humorValue = J₂.humorValue

theorem humorEquiv_equivalence : Equivalence (@humorEquiv α _) where
  refl _ := rfl
  symm h := h.symm
  trans h₁ h₂ := h₁.trans h₂

end Joke

/-! ## Part 3: Subversion Maps -/

/-- A subversion map: a function that amplifies surprise by a given factor. -/
structure SubversionMap (α β : Type*) [PseudoMetricSpace α] [PseudoMetricSpace β] where
  toFun : α → β
  source : SurpriseSpace α
  target : SurpriseSpace β
  maps_expected : toFun source.expected = target.expected
  amplification : ℝ
  amp_pos : 0 < amplification
  amplifies_surprise : ∀ x, target.surprise (toFun x) ≥ amplification * source.surprise x

namespace SubversionMap

variable {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]

/-- A subversion map with amplification ≥ 1 never decreases surprise. -/
theorem surprise_nondecreasing (f : SubversionMap α β) (h : 1 ≤ f.amplification)
    (x : α) : f.target.surprise (f.toFun x) ≥ f.source.surprise x := by
  calc f.target.surprise (f.toFun x)
      ≥ f.amplification * f.source.surprise x := f.amplifies_surprise x
    _ ≥ 1 * f.source.surprise x :=
        mul_le_mul_of_nonneg_right h (f.source.surprise_nonneg x)
    _ = f.source.surprise x := one_mul _

theorem expected_maps_to_zero_surprise (f : SubversionMap α β) :
    f.target.surprise (f.toFun f.source.expected) = 0 := by
  unfold SurpriseSpace.surprise; rw [f.maps_expected]; exact dist_self _

end SubversionMap

/-! ## Part 4: Information-Theoretic Surprise -/

/-- Information-theoretic surprise: -log₂(p) for probability p. -/
noncomputable def infoSurprise (p : ℝ) : ℝ := -Real.log p / Real.log 2

theorem infoSurprise_one : infoSurprise 1 = 0 := by
  unfold infoSurprise; simp [Real.log_one]

/-- **Surprise Monotonicity**: Less probable events are more surprising. -/
theorem infoSurprise_antitone {p q : ℝ} (hp : 0 < p) (_hq : 0 < q) (hpq : p ≤ q) :
    infoSurprise q ≤ infoSurprise p := by
  unfold infoSurprise
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  apply div_le_div_of_nonneg_right _ (le_of_lt hlog2)
  linarith [Real.log_le_log hp hpq]

/-- **Surprise Additivity**: The surprise of independent events adds.
Independent jokes compound their comedic impact. -/
theorem infoSurprise_mul {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    infoSurprise (p * q) = infoSurprise p + infoSurprise q := by
  unfold infoSurprise
  rw [Real.log_mul (ne_of_gt hp) (ne_of_gt hq)]
  ring

/-! ## Part 5: Maximal Surprise in Compact Spaces -/

/-- **Maximal Surprise Theorem**: In a nonempty compact space, the optimal joke exists. -/
theorem maximal_surprise_exists {α : Type*} [PseudoMetricSpace α] [CompactSpace α]
    [Nonempty α] (S : SurpriseSpace α) :
    ∃ x : α, ∀ y : α, S.surprise y ≤ S.surprise x := by
  obtain ⟨x, _, hx⟩ := isCompact_univ.exists_isMaxOn Set.univ_nonempty
    S.surprise_continuous.continuousOn
  exact ⟨x, fun y => hx (Set.mem_univ y)⟩

/-- **Fundamental Theorem of Comedy**: In a compact space, the supremum
of surprise is attained. There exists a funniest possible joke. -/
theorem fundamental_theorem_of_comedy {α : Type*} [PseudoMetricSpace α]
    [CompactSpace α] [Nonempty α] (S : SurpriseSpace α) :
    ∃ x : α, S.surprise x = ⨆ y : α, S.surprise y := by
  obtain ⟨x, _, hx⟩ := isCompact_univ.exists_isMaxOn Set.univ_nonempty
    S.surprise_continuous.continuousOn
  have hbdd : BddAbove (Set.range S.surprise) := by
    rw [show Set.range S.surprise = S.surprise '' Set.univ from by simp [Set.image_univ]]
    exact (isCompact_univ.image S.surprise_continuous).bddAbove
  exact ⟨x, le_antisymm (le_ciSup hbdd x) (ciSup_le fun y => hx (Set.mem_univ y))⟩

/-! ## Part 6: Joke Diagrams and Colimit-Limit Distance -/

/-- A joke diagram: limit (expected) and colimit (actual). -/
structure JokeDiagram (α : Type*) [PseudoMetricSpace α] where
  lim : α
  colim : α

noncomputable def JokeDiagram.clDistance {α : Type*} [PseudoMetricSpace α]
    (D : JokeDiagram α) : ℝ := dist D.lim D.colim

/-- Humor is bounded by the diameter of the ambient space. -/
theorem JokeDiagram.cl_distance_le_diameter {α : Type*} [PseudoMetricSpace α]
    (D : JokeDiagram α) (S : Set α) (hS : D.lim ∈ S) (hP : D.colim ∈ S)
    (hbdd : Bornology.IsBounded S) :
    D.clDistance ≤ Metric.diam S :=
  Metric.dist_le_diam_of_mem hbdd hS hP

/-- **Factoring Through Intermediate Nodes**: Comedy works by accumulation. -/
theorem JokeDiagram.humor_factors {α : Type*} [PseudoMetricSpace α]
    (D : JokeDiagram α) (m : α) :
    D.clDistance ≤ dist D.lim m + dist m D.colim :=
  dist_triangle D.lim m D.colim

/-! ## Part 7: The Incongruity-Resolution Model -/

/-- An incongruity-resolution joke. -/
structure IRJoke where
  incongruity : ℝ
  resolution : ℝ
  inc_nonneg : 0 ≤ incongruity
  res_nonneg : 0 ≤ resolution
  res_le_one : resolution ≤ 1

noncomputable def IRJoke.netHumor (J : IRJoke) : ℝ :=
  J.incongruity * (1 - J.resolution)

theorem IRJoke.netHumor_nonneg (J : IRJoke) : 0 ≤ J.netHumor :=
  mul_nonneg J.inc_nonneg (by linarith [J.res_le_one])

theorem IRJoke.netHumor_le_incongruity (J : IRJoke) : J.netHumor ≤ J.incongruity := by
  unfold netHumor
  have h1 : 1 - J.resolution ≤ 1 := by linarith [J.res_nonneg]
  calc J.incongruity * (1 - J.resolution)
      ≤ J.incongruity * 1 := mul_le_mul_of_nonneg_left h1 J.inc_nonneg
    _ = J.incongruity := mul_one _

/-- **Maximum Humor Theorem**: Net humor equals incongruity iff resolution
is zero or incongruity is zero. Absurdism = maximum comedy. -/
theorem IRJoke.max_humor_iff_no_resolution (J : IRJoke) :
    J.netHumor = J.incongruity ↔ J.resolution = 0 ∨ J.incongruity = 0 := by
  constructor
  · intro h
    unfold netHumor at h
    by_cases hinc : J.incongruity = 0
    · exact Or.inr hinc
    · left
      have : 1 - J.resolution = 1 := by
        exact mul_left_cancel₀ hinc (by linarith)
      linarith
  · rintro (h | h) <;> simp [netHumor, h]

/-- **Pun Theorem**: High-resolution jokes have at most half the humor. -/
theorem IRJoke.pun_humor_bound (J : IRJoke) (hres : J.resolution ≥ 1/2) :
    J.netHumor ≤ J.incongruity / 2 := by
  unfold netHumor
  have h1 : 1 - J.resolution ≤ 1/2 := by linarith
  calc J.incongruity * (1 - J.resolution)
      ≤ J.incongruity * (1/2) := mul_le_mul_of_nonneg_left h1 J.inc_nonneg
    _ = J.incongruity / 2 := by ring

/-- **Absurdist Humor**: With zero resolution, net humor = incongruity. -/
theorem IRJoke.absurdist_humor (J : IRJoke) (h : J.resolution = 0) :
    J.netHumor = J.incongruity := by
  unfold netHumor; rw [h]; ring

/-- Net humor interpolates linearly. -/
theorem IRJoke.humor_interpolation (J : IRJoke) :
    J.netHumor = (1 - J.resolution) * J.incongruity := by
  unfold netHumor; ring

/-! ## Part 8: Comedy Routines -/

/-- **Routine Monotonicity**: Adding a positive joke never decreases total humor. -/
theorem routine_monotone (R : List ℝ) (h : ℝ) (hpos : 0 ≤ h) :
    R.sum ≤ (R ++ [h]).sum := by
  simp [List.sum_append, List.sum_cons, List.sum_nil]
  linarith

/-- Concatenating routines adds their humor. -/
theorem routine_additive (R₁ R₂ : List ℝ) :
    (R₁ ++ R₂).sum = R₁.sum + R₂.sum := by
  exact List.sum_append

/-! ## Part 9: Surprise-Diameter Duality -/

/-- For any two points, there's a surprise space measuring their distance. -/
theorem comedy_duality {α : Type*} [PseudoMetricSpace α] (a b : α) :
    let S : SurpriseSpace α := ⟨a⟩
    S.surprise b = dist b a := rfl

/-- Maximum surprise in a bounded set is bounded by its diameter. -/
theorem surprise_le_diam {α : Type*} [PseudoMetricSpace α]
    (S : SurpriseSpace α) (A : Set α) (hexp : S.expected ∈ A)
    (hbdd : Bornology.IsBounded A) (x : α) (hx : x ∈ A) :
    S.surprise x ≤ Metric.diam A :=
  Metric.dist_le_diam_of_mem hbdd hx hexp

/-! ## Part 10: Entropy-Surprise Connection -/

/-- The surprise of a uniform distribution on n elements is log₂(n). -/
theorem uniform_entropy_eq_log (n : ℕ) (hn : 1 ≤ n) :
    infoSurprise (1 / (n : ℝ)) = Real.log n / Real.log 2 := by
  unfold infoSurprise
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
  rw [Real.log_div (by norm_num) (by exact_mod_cast ne_of_gt hn'), Real.log_one]
  ring

/-! ## Part 11: Functorial Surprise -/

/-- A **surprise functor**: a monotone map paired with a "twist" that
subverts the expected output. The gap between them is the surprise. -/
structure SurpriseFunctor (α β : Type*) [Preorder α] [Preorder β] where
  toFun : α → β
  monotone : Monotone toFun
  twist : α → β
  twist_monotone : Monotone twist

noncomputable def SurpriseFunctor.gap {α β : Type*} [Preorder α] [Preorder β]
    [PseudoMetricSpace β] (F : SurpriseFunctor α β) (x : α) : ℝ :=
  dist (F.toFun x) (F.twist x)

theorem SurpriseFunctor.gap_nonneg {α β : Type*} [Preorder α] [Preorder β]
    [PseudoMetricSpace β] (F : SurpriseFunctor α β) (x : α) :
    0 ≤ F.gap x := dist_nonneg

/-- **Surprise Gap Triangle Inequality**: The gap at y is bounded by the
gap at x plus the narrative distances between the two images. -/
theorem SurpriseFunctor.gap_triangle {α β : Type*} [Preorder α] [Preorder β]
    [PseudoMetricSpace β] (F : SurpriseFunctor α β) (x y : α) :
    F.gap y ≤ F.gap x + dist (F.toFun x) (F.toFun y) + dist (F.twist x) (F.twist y) := by
  unfold gap
  calc dist (F.toFun y) (F.twist y)
      ≤ dist (F.toFun y) (F.toFun x) + dist (F.toFun x) (F.twist y) :=
        dist_triangle _ _ _
    _ ≤ dist (F.toFun y) (F.toFun x) +
        (dist (F.toFun x) (F.twist x) + dist (F.twist x) (F.twist y)) := by
        linarith [dist_triangle (F.toFun x) (F.twist x) (F.twist y)]
    _ = _ := by rw [dist_comm (F.toFun y) (F.toFun x)]; ring

/-! ## Axiom Verification -/
#print axioms fundamental_theorem_of_comedy
#print axioms IRJoke.max_humor_iff_no_resolution
#print axioms infoSurprise_antitone
#print axioms infoSurprise_mul
#print axioms SurpriseFunctor.gap_triangle