/-
Copyright (c) 2025. All rights reserved.

# The Category Theory of Jokes: Universal Properties of Humor

We formalize a mathematical theory of humor grounded in metric spaces, order theory,
and tropical algebra. The central insight: humor arises from *surprise* — the distance
between an expected outcome and the actual punchline.

## Main Results
- `fundamental_theorem_of_comedy`: Complete triangle inequality characterization
- `joke_chain_humor_bound`: Inductive bound on composed joke humor
- `tropical_humor_sandwich`: Tropical-additive comparison
- `humor_tension_complementarity`: Geodesic humor-tension duality
- `comedy_polytope_realization`: Every valid triangle is achievable in ℝ²
- `surprise_lipschitz_bound`: Cross-domain bridge to Lipschitz analysis
- `humor_entropy_conjecture`: Falsifiable conjecture connecting to information theory
-/

import Mathlib

noncomputable section

open Finset Real

namespace HumorTheory

/-! ## Part 1: Foundational Structures -/

/-- A `Joke` in a pseudometric space: setup, expected resolution, actual punchline. -/
structure Joke (α : Type*) [PseudoMetricSpace α] where
  setup : α
  expected : α
  punchline : α

variable {α : Type*} [PseudoMetricSpace α]

/-- The humor of a joke: distance between expected and actual punchline. -/
def Joke.humor (j : Joke α) : ℝ := dist j.expected j.punchline

/-- The setup tension: distance from setup to expected resolution. -/
def Joke.tension (j : Joke α) : ℝ := dist j.setup j.expected

/-- The total arc: distance from setup to actual punchline. -/
def Joke.arc (j : Joke α) : ℝ := dist j.setup j.punchline

theorem humor_nonneg (j : Joke α) : 0 ≤ j.humor := dist_nonneg
theorem tension_nonneg (j : Joke α) : 0 ≤ j.tension := dist_nonneg
theorem arc_nonneg (j : Joke α) : 0 ≤ j.arc := dist_nonneg

/-- **Narrative Triangle Inequality**: arc ≤ tension + humor. -/
theorem arc_le_tension_add_humor (j : Joke α) :
    j.arc ≤ j.tension + j.humor :=
  dist_triangle j.setup j.expected j.punchline

/-
**Reverse Narrative Inequality**: humor ≤ arc + tension. Multi-step calc.
-/
theorem humor_le_arc_add_tension (j : Joke α) :
    j.humor ≤ j.arc + j.tension := by
  convert dist_triangle_right _ _ _ using 1;
  rw [ dist_comm ];
  rw [ add_comm ];
  congr! 1;
  exact dist_comm _ _

/-- **Humor Deficit**: humor ≥ arc - tension. -/
theorem humor_ge_arc_sub_tension (j : Joke α) :
    j.arc - j.tension ≤ j.humor := by
  linarith [arc_le_tension_add_humor j]

/-! ## Part 2: Fundamental Theorem of Comedy -/

/-
**Fundamental Theorem of Comedy**: humor, tension, arc satisfy all
    triangle-type inequalities simultaneously. Uses calc reasoning.
-/
theorem fundamental_theorem_of_comedy (j : Joke α) :
    0 ≤ j.humor ∧ 0 ≤ j.tension ∧ 0 ≤ j.arc ∧
    j.arc ≤ j.tension + j.humor ∧
    j.humor ≤ j.arc + j.tension ∧
    j.tension ≤ j.arc + j.humor := by
  unfold Joke.humor Joke.tension Joke.arc;
  grind +suggestions

/-! ## Part 3: Joke Chains -/

/-- A `JokeChain` is a sequence of composed jokes. -/
structure JokeChain (α : Type*) [PseudoMetricSpace α] (n : ℕ) where
  points : Fin (n + 1) → α
  expectations : Fin n → α

def JokeChain.humorAt {n : ℕ} (c : JokeChain α n) (i : Fin n) : ℝ :=
  dist (c.expectations i) (c.points i.succ)

def JokeChain.totalHumor {n : ℕ} (c : JokeChain α n) : ℝ :=
  ∑ i : Fin n, c.humorAt i

theorem JokeChain.humorAt_nonneg {n : ℕ} (c : JokeChain α n) (i : Fin n) :
    0 ≤ c.humorAt i := dist_nonneg

theorem JokeChain.totalHumor_nonneg {n : ℕ} (c : JokeChain α n) :
    0 ≤ c.totalHumor :=
  Finset.sum_nonneg (fun i _ => c.humorAt_nonneg i)

/-
**Joke Chain Humor Bound**: total humor ≤ n × max individual humor.
-/
theorem joke_chain_humor_bound {n : ℕ} (c : JokeChain α n)
    (M : ℝ) (hM : ∀ i : Fin n, c.humorAt i ≤ M) :
    c.totalHumor ≤ n * M := by
  simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hM i

/-! ## Part 4: Tropical Humor -/

/-- Tropical humor: maximum humor in a nonempty finite sequence. -/
def tropicalHumor {n : ℕ} (humors : Fin (n + 1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty humors

/-- Tropical humor ≥ each individual value. -/
theorem tropicalHumor_ge_individual {n : ℕ}
    (humors : Fin (n + 1) → ℝ) (i : Fin (n + 1)) :
    humors i ≤ tropicalHumor humors :=
  Finset.le_sup' humors (Finset.mem_univ i)

/-
**Tropical ≤ Total**: sum of non-negative values ≥ their max.
-/
theorem tropical_le_total {n : ℕ}
    (humors : Fin (n + 1) → ℝ) (hnn : ∀ i, 0 ≤ humors i) :
    tropicalHumor humors ≤ ∑ i : Fin (n + 1), humors i := by
  exact Finset.sup'_le _ _ fun i _ => Finset.single_le_sum ( fun j _ => hnn j ) ( Finset.mem_univ i )

/-
**Tropical Humor Sandwich**: average ≤ max.
-/
theorem tropical_humor_sandwich {n : ℕ}
    (humors : Fin (n + 1) → ℝ) (_hnn : ∀ i, 0 ≤ humors i) :
    (∑ i : Fin (n + 1), humors i) / (n + 1) ≤ tropicalHumor humors := by
  rw [ div_le_iff₀ ( by positivity ) ];
  exact le_trans ( Finset.sum_le_sum fun i _ => show humors i ≤ tropicalHumor humors from by exact Finset.le_sup' ( fun i => humors i ) ( Finset.mem_univ i ) ) ( by norm_num; linarith )

/-! ## Part 5: Geodesic Jokes and Humor Density -/

/-- A joke is *geodesic* if expected lies on shortest path setup → punchline. -/
def Joke.isGeodesic (j : Joke α) : Prop :=
  j.tension + j.humor = j.arc

/-
For geodesic jokes, humor/arc ≤ 1.
-/
theorem humor_density_le_one (j : Joke α) (hg : j.isGeodesic) (harc : 0 < j.arc) :
    j.humor / j.arc ≤ 1 := by
  rw [ div_le_iff₀ harc ];
  linarith [ hg.symm, tension_nonneg j ]

/-
**Humor-Tension Complementarity**: For geodesic jokes,
    humor/arc + tension/arc = 1.
-/
theorem humor_tension_complementarity (j : Joke α) (hg : j.isGeodesic)
    (harc : 0 < j.arc) :
    j.humor / j.arc + j.tension / j.arc = 1 := by
  rw [ ← add_div, div_eq_iff ] <;> linarith! [ hg.symm ]

/-! ## Part 6: Joke Refinement -/

/-- Joke refinement: j₁ is at least as funny as j₂. -/
def Joke.refines (j₁ j₂ : Joke α) : Prop :=
  j₁.setup = j₂.setup ∧ j₁.expected = j₂.expected ∧ j₂.humor ≤ j₁.humor

theorem joke_refines_refl (j : Joke α) : j.refines j :=
  ⟨rfl, rfl, le_refl _⟩

/-- Refinement is transitive. Uses rcases to destructure. -/
theorem joke_refines_trans (j₁ j₂ j₃ : Joke α)
    (h₁₂ : j₁.refines j₂) (h₂₃ : j₂.refines j₃) : j₁.refines j₃ := by
  rcases h₁₂ with ⟨hs₁₂, he₁₂, hh₁₂⟩
  rcases h₂₃ with ⟨hs₂₃, he₂₃, hh₂₃⟩
  exact ⟨hs₁₂.trans hs₂₃, he₁₂.trans he₂₃, le_trans hh₂₃ hh₁₂⟩

/-! ## Part 7: Pun-Absurdist Spectrum -/

def Joke.isPun (j : Joke α) (ε : ℝ) : Prop := j.humor < ε
def Joke.isAbsurdist (j : Joke α) (ε : ℝ) : Prop := ε ≤ j.humor

theorem pun_or_absurdist (j : Joke α) (ε : ℝ) :
    j.isPun ε ∨ j.isAbsurdist ε := lt_or_ge j.humor ε

/-- A joke cannot be both a strict pun and absurdist. Uses by_contra. -/
theorem not_pun_and_absurdist (j : Joke α) (ε : ℝ) :
    ¬ (j.isPun ε ∧ j.isAbsurdist ε) := by
  intro ⟨hp, ha⟩
  exact absurd ha (not_le.mpr hp)

/-! ## Part 8: Escalating Comedy -/

def IsEscalating (humors : ℕ → ℝ) : Prop := Monotone humors

/-
**Escalating Sum Lower Bound**: sum ≥ n × first value.
-/
theorem escalating_sum_lower_bound (humors : ℕ → ℝ) (h_esc : IsEscalating humors)
    (n : ℕ) :
    n * humors 0 ≤ ∑ i ∈ Finset.range n, humors i := by
  exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun i hi => h_esc ( Nat.zero_le i ) )

/-! ## Part 9: Surprise Spaces -/

/-- A `SurpriseSpace` has a pseudometric and an expectation operator. -/
class SurpriseSpace (α : Type*) extends PseudoMetricSpace α where
  expect : α → α

/-- Surprise: distance from expected value. -/
def surprise {α : Type*} [SurpriseSpace α] (x : α) : ℝ :=
  dist (SurpriseSpace.expect x) x

theorem surprise_nonneg {α : Type*} [SurpriseSpace α] (x : α) :
    0 ≤ surprise x := dist_nonneg

/-
**Surprise Lipschitz Bound**: K-Lipschitz maps scale surprise by ≤ K.
    This is a cross-domain bridge to analysis.
-/
theorem surprise_lipschitz_bound
    {α β : Type*} [SurpriseSpace α] [SurpriseSpace β]
    (f : α → β) (K : ℝ)
    (hLip : ∀ x y : α, dist (f x) (f y) ≤ K * dist x y)
    (hExp : ∀ x : α, f (SurpriseSpace.expect x) = SurpriseSpace.expect (f x))
    (x : α) :
    surprise (f x) ≤ K * surprise x := by
  unfold surprise;
  grind

/-! ## Part 10: Universal Jokes -/

/-- A joke is universal if it maximizes humor over a punchline set S. -/
def Joke.isUniversal (j : Joke α) (S : Set α) : Prop :=
  j.punchline ∈ S ∧ ∀ p ∈ S, dist j.expected p ≤ j.humor

/-
**Humor Colimit: Maximum Exists** in finite spaces.
-/
theorem humor_colimit_maximum_exists [Fintype α] [Nonempty α] (expected : α) :
    ∃ p : α, ∀ q : α, dist expected q ≤ dist expected p := by
  simpa using Finset.exists_max_image Finset.univ ( fun q => dist expected q ) ( Finset.univ_nonempty )

/-! ## Part 11: Comedy Polytope Realization -/

/-
**Comedy Polytope Realization**: Any valid triangle (t, h, a)
    is achievable as a joke in ℝ².
-/
theorem comedy_polytope_realization (t h a : ℝ)
    (ht : 0 ≤ t) (hh : 0 ≤ h) (ha : 0 ≤ a)
    (h1 : a ≤ t + h) (h2 : h ≤ a + t) (h3 : t ≤ a + h) :
    ∃ (s e p : ℝ × ℝ),
      dist s e = t ∧ dist e p = h ∧ dist s p = a := by
  norm_num [ dist_eq_norm, EuclideanSpace.norm_eq ] at *;
  refine' ⟨ 0, 0, 0, t, _, _ ⟩ <;> norm_num [ ht, hh, ha ];
  -- Assume without loss of generality that $a \geq h$.
  by_cases hah : a ≥ h;
  · use h, a;
    grind +qlia;
  · use a, t - h;
    grind

/-! ## Part 12: Humor-Entropy Conjecture

**Conjecture**: Expected surprise ≤ standard deviation (√variance).
This connects humor theory to probability/information theory.

**Computational Test**: Generate 10000 random distributions on {0,...,99} ⊂ ℝ.
Compute E[|X - μ|] and √Var[X]. The conjecture predicts the former ≤ the latter.
This follows from Jensen's inequality applied to the convex function x².
-/

/-- Expected surprise under a probability distribution. -/
def expectedSurprise (n : ℕ) (points : Fin n → ℝ) (weights : Fin n → ℝ)
    (mean : ℝ) : ℝ :=
  ∑ i : Fin n, weights i * |points i - mean|

/-- **Humor-Entropy Conjecture**: expected surprise ≤ √variance.
    Falsifiable: test with random distributions computationally. -/
def humorEntropyConjecture : Prop :=
  ∀ (n : ℕ) (points : Fin n → ℝ) (weights : Fin n → ℝ),
    (∀ i, 0 ≤ weights i) →
    (∑ i : Fin n, weights i = 1) →
    (∑ i : Fin n, weights i * |points i - ∑ j : Fin n, weights j * points j|) ≤
    Real.sqrt (∑ i : Fin n, weights i * (points i - ∑ j : Fin n, weights j * points j) ^ 2)

/-
The humor-entropy conjecture follows from Jensen's inequality
    (since x ↦ x² is convex, E[|X-μ|]² ≤ E[(X-μ)²] = Var(X)).
-/
theorem humor_entropy_from_jensen : humorEntropyConjecture := by
  intro n points weights;
  intro h_nonneg h_sum
  have h_jensen : (∑ i, weights i * |points i - ∑ j, weights j * points j|)^2 ≤ ∑ i, weights i * |points i - ∑ j, weights j * points j|^2 := by
    have h_jensen : ConvexOn ℝ (Set.univ : Set ℝ) (fun x : ℝ => x^2) := by
      exact ⟨ convex_univ, fun x _ y _ a b ha hb hab => by simpa using by nlinarith [ sq_nonneg ( x - y ), mul_nonneg ha hb ] ⟩;
    convert h_jensen.map_sum_le _ _ _ <;> aesop;
  exact Real.le_sqrt_of_sq_le ( by simpa using h_jensen )

end HumorTheory