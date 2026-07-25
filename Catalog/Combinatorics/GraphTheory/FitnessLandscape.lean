import Mathlib
import Combinatorics.Proofsearchinformationlimits.ProofSearchInformationLimits

/-!
# Fitness landscapes for finite mathematical ecosystems

A theory is represented only by two measurable resources: its stock of established
results and its source length.  Fitness is their rational ratio.  A separate
migration relation records which rewrites count as one step, while a style map
partitions the ecosystem into algebraic, analytic, and combinatorial regions.
The model is intentionally extensional: it studies consequences of measurable
counts and migration barriers rather than asserting empirical facts about any
particular library.

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).** Seven falsifiable claims were ranked by structural
impact: (1) every nonempty finite ecosystem has a global fitness maximizer;
(2) every global maximizer is locally optimal for every migration relation;
(3) stylewise champions become simultaneous local optima when one-step migration
stays within style; (4) every finite migration from a style to its complement has
a first boundary crossing; (5) a penalized boundary forces every such migration
through a strict fitness valley; (6) independent theory composition should make
result counts multiplicative while source costs add; (7) a universal library is
a global maximum among all expressible theories. Claims (6) and (7) are bold
frontiers: neither follows from counting alone, and (7) requires a bounded,
empirically specified comparison class.

**Experiment (Experimenter).** The profile with result/line pairs
`(30,10), (20,10), (24,12), (9,6)` has fitnesses `3,2,2,3/2`; assigning the first
three as style champions and the fourth as a boundary state realizes three local
peaks and a strict valley. Candidate derivations supply a cross-domain example:
words of length `n` over `q` symbols contribute exactly `q^n` candidates, linking
finite combinatorics to the numerator of fitness.

**Analysis (Analyst).** Local optimality is not created by naming styles.  It
follows from two independent ingredients: a champion inequality inside each
style and a neighborhood relation that respects style.  Valley inevitability is
likewise topological-combinatorial: endpoint separation forces a boundary edge,
and a quantitative penalty turns that crossing into a fitness decrease.

**Critique (Critic).** The raw claim that three named styles must produce local
optima is false without style-preserving neighborhoods and champion hypotheses.
The global-maximum claim is false on an unbounded class: adding results without
increasing charged lines makes fitness unbounded.  A migration valley is also
not automatic; it needs a boundary penalty.  The theorems below expose all three
assumptions rather than hiding them.

**Synthesis (Principal Investigator).** The surviving theory consists of a finite
maximum principle, a three-style local-optimum theorem, and an unavoidable-valley
theorem based on first boundary crossing.  Together they give a precise,
testable version of the ecological metaphor while marking the universal-library
claim as a conjecture requiring empirical bounds.
-- !-- Lab Notes -- !--

### Generalization
The finite maximum principle extends to any linearly ordered value type.  The
boundary argument extends from three styles to arbitrary predicates and from
fitness to any potential function.  Weighted source costs, dependency-adjusted
result counts, and directed migration graphs are immediate broader variants.

### Boundaries
Zero source length is excluded because the ratio would be undefined.  Local
optima need not be unique, disconnected styles need not have comparable peaks,
and no valley follows if cross-style adapters preserve or improve fitness.  An
unbounded ecosystem need not possess a global maximizer.
-/

namespace FitnessLandscape

/-- The three coarse methodological regions considered in the landscape. -/
inductive Style
  | algebraic
  | analytic
  | combinatorial
  deriving DecidableEq, Fintype, Repr

/-- A measurable theory organism, with a positive source-length charge. -/
structure Organism where
  theoremCount : ℕ
  lineCount : ℕ
  lineCount_pos : 0 < lineCount

/-- Results established per charged source line. -/
def fitness (M : Organism) : ℚ := M.theoremCount / M.lineCount

/-- A point dominates all of its one-step migration neighbors. -/
def IsLocalMaximum {α : Type*} (score : α → ℚ) (step : α → α → Prop) (x : α) : Prop :=
  ∀ y, step x y → score y ≤ score x

/-- A point dominates the whole comparison class. -/
def IsGlobalMaximum {α : Type*} (score : α → ℚ) (x : α) : Prop :=
  ∀ y, score y ≤ score x

/-
Comparing fitness ratios is equivalent to cross-multiplying their counts.
-/
theorem fitness_le_iff (M N : Organism) :
    fitness M ≤ fitness N ↔
      M.theoremCount * N.lineCount ≤ N.theoremCount * M.lineCount := by
  norm_num [ fitness, div_le_div_iff₀, M.lineCount_pos, N.lineCount_pos ];
  norm_cast

/-
Every global optimum is a local optimum, independently of the migration graph.
-/
theorem global_is_local {α : Type*} (score : α → ℚ) (step : α → α → Prop) (x : α)
    (hx : IsGlobalMaximum score x) : IsLocalMaximum score step x := by
  exact fun y hy => hx y

/-
Every nonempty finite ecosystem has a global fitness maximizer.
-/
theorem exists_global_maximum {α : Type*} [Fintype α] [Nonempty α]
    (score : α → ℚ) : ∃ x, IsGlobalMaximum score x := by
  exact Finset.exists_max_image Finset.univ score ( Finset.univ_nonempty ) |> fun ⟨ x, hx ⟩ => ⟨ x, fun y => hx.2 y ( Finset.mem_univ y ) ⟩

/-
If migration preserves style and each designated center dominates its style,
then every designated center is a local optimum.
-/
theorem style_centers_are_local {α : Type*} (score : α → ℚ)
    (step : α → α → Prop) (style : α → Style) (center : Style → α)
    (hcenter_style : ∀ s, style (center s) = s)
    (hstep_style : ∀ x y, step x y → style y = style x)
    (hchampion : ∀ s x, style x = s → score x ≤ score (center s)) :
    ∀ s, IsLocalMaximum score step (center s) := by
  exact fun s y hy => hchampion _ _ ( hstep_style _ _ hy ▸ hcenter_style _ )

/-
A finite path that starts in a region and ends outside it has a first exit.
-/
theorem exists_boundary_crossing {α : Type*} (region : α → Prop)
    [DecidablePred region] (path : ℕ → α) (n : ℕ)
    (hstart : region (path 0)) (hend : ¬ region (path n)) :
    ∃ i, i < n ∧ region (path i) ∧ ¬ region (path (i + 1)) := by
  contrapose! hend;
  induction' n with n ih;
  · exact hstart;
  · exact hend n n.lt_succ_self ( ih fun i hi hi' => hend i ( Nat.lt_succ_of_lt hi ) hi' )

/-
Any migration between separated regions crosses a strict fitness valley when
all outward boundary steps incur a penalty below both endpoint fitnesses.
-/
theorem migration_crosses_valley {α : Type*} (score : α → ℚ)
    (step : α → α → Prop) (region : α → Prop) [DecidablePred region]
    (path : ℕ → α) (n : ℕ)
    (hstart : region (path 0)) (hend : ¬ region (path n))
    (hpath : ∀ i, i < n → step (path i) (path (i + 1)))
    (hpenalty : ∀ x y, step x y → region x → ¬ region y →
      score y < min (score (path 0)) (score (path n))) :
    ∃ i, i < n ∧ score (path (i + 1)) < score (path 0) ∧
      score (path (i + 1)) < score (path n) := by
  obtain ⟨ i, hi, h ⟩ := exists_boundary_crossing region path n hstart hend;
  exact ⟨ i, hi, lt_of_lt_of_le ( hpenalty _ _ ( hpath i hi ) h.1 h.2 ) ( min_le_left _ _ ), lt_of_lt_of_le ( hpenalty _ _ ( hpath i hi ) h.1 h.2 ) ( min_le_right _ _ ) ⟩

/-- The finite-word candidate family provides an explicit combinatorial organism:
its theorem stock is the exact number of depth-`n` words over `q` symbols. -/
def wordOrganism (q n : ℕ) : Organism where
  theoremCount := Fintype.card (ProofSearchInformationLimits.Words q n)
  lineCount := n + 1
  lineCount_pos := by omega

/-
Cross-domain bridge: the numerator of word-organism fitness is exponential.
-/
theorem wordOrganism_theoremCount (q n : ℕ) :
    (wordOrganism q n).theoremCount = q ^ n := by
  convert ProofSearchInformationLimits.card_words q n

/-! ## Concrete examples -/

#check @exists_global_maximum
#check @style_centers_are_local
#check @migration_crosses_valley
#check @ProofSearchInformationLimits.card_words

example : fitness ⟨30, 10, by omega⟩ = 3 := by norm_num [fitness]

example : fitness ⟨9, 6, by omega⟩ < fitness ⟨30, 10, by omega⟩ := by
  norm_num [fitness]

example : (wordOrganism 2 5).theoremCount = 32 := by
  rw [wordOrganism_theoremCount]
  norm_num

example : ∃ i, i < 3 ∧ (i < 2) ∧ ¬ (i + 1 < 2) := by
  simpa using exists_boundary_crossing (fun i : ℕ => i < 2) (fun i : ℕ => i) 3
    (by norm_num) (by norm_num)

end FitnessLandscape