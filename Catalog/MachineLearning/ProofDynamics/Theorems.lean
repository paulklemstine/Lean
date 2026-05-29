import Mathlib
import Speculative.ProofDynamics.Defs

/-!
# Proof Dynamics: Core Theorems

This file proves the main theorems of the proof dynamics framework:

1. **Well-foundedness of measure-decreasing relations** — any step relation
   with a strictly decreasing ℕ-valued measure yields a well-founded
   refinement order.

2. **Lexicographic complexity is well-founded** — the triple
   (length, depth, lemmaCount) with lexicographic order yields a
   well-founded refinement system strictly finer than scalar score.

3. **Existence of normal forms** — every proof sketch admits a finite
   descending chain to a normal form.

4. **Semantic invariance** — refinement steps preserve theorem semantics,
   and this lifts to the transitive closure.

5. **No cycles (discrete Lyapunov)** — a strictly decreasing energy
   functional prevents periodic orbits in refinement trajectories.

6. **Normal-form minimality** — normal forms are complexity-minimal among
   all reachable descendants.

7. **Concrete refinement chain** — a worked example showing refinement
   of a bloated √2-irrationality sketch to normal form.

## Cross-Domain Bridge

Theorem 5 establishes the proof-theoretic analogue of the discrete
Lyapunov stability theorem from dynamical systems theory: the complexity
score is a strict Lyapunov function for the refinement dynamics, and
consequently the system has no nontrivial periodic orbits.
-/

open ProofSketch ProofComplexity

universe u

variable {α : Type u}

/-! ## Theorem 1: Well-foundedness from measure decrease -/

/-- **Fundamental Descent Theorem.**
    Any binary relation `step` equipped with a strictly decreasing
    ℕ-valued measure `μ` yields a well-founded *converse* relation.

    Since `step p q` means "p refines to q" (complexity goes down),
    the converse `Function.swap step` is the "is refined from" order,
    which is well-founded: going toward simpler objects always terminates. -/
theorem wellFounded_of_measure_decrease
    {P : Type _} {step : P → P → Prop} {μ : P → ℕ}
    (hμ : ∀ {p q : P}, step p q → μ q < μ p) :
    WellFounded (Function.swap step) :=
  Subrelation.wf (fun {_ _} h => hμ h) (InvImage.wf μ wellFounded_lt)

/-! ## Theorem 2: Lexicographic complexity is well-founded -/

/-
The lexicographic order on `ProofComplexity` is well-founded.
    This gives a strictly finer notion of descent than scalar score.
-/
theorem wellFounded_lexComplexity :
    WellFounded ProofComplexity.Lex := by
  -- The lexicographic order on triples of natural numbers is well-founded because it is a product of well-ordered sets.
  have h_lex_wf : WellFounded (Prod.Lex (· < ·) (Prod.Lex (· < ·) (· < ·)) : ℕ × ℕ × ℕ → ℕ × ℕ × ℕ → Prop) := by
    convert wellFounded_lt.prod_lex ( wellFounded_lt.prod_lex wellFounded_lt ) using 1; all_goals infer_instance;
  convert h_lex_wf;
  constructor <;> intro h <;> rw [ WellFounded.wellFounded_iff_has_min ] at *;
  · exact h_lex_wf;
  · intro s hs; specialize h ( s.image fun x => ( x.length, x.depth, x.lemmaCount ) ) ; simp_all +decide [ ProofComplexity.Lex ] ;
    grind

/-- **Separation theorem:** lexicographic order detects simplification
    that scalar score misses. There exist complexity pairs with equal
    score but strict lexicographic decrease. -/
theorem exists_score_tie_but_lex_drop :
    ∃ c₁ c₂ : ProofComplexity,
      c₁.score = c₂.score ∧ ProofComplexity.Lex c₂ c₁ := by
  use ⟨2, 0, 1⟩, ⟨1, 1, 1⟩
  simp +decide [ProofComplexity.Lex]

/-! ## Theorem 3: Existence of normal forms -/

/-- Every element under a well-founded converse relation admits a
    normal form: a descendant with no further outgoing steps. -/
theorem exists_normalForm_of_wf
    {P : Type _} {step : P → P → Prop}
    (hwf : WellFounded (Function.swap step)) :
    ∀ p : P, ∃ q : P, Relation.ReflTransGen step p q ∧ NormalForm step q := by
  intro p
  have := hwf.has_min { q | Relation.ReflTransGen step p q } ⟨p, by tauto⟩
  exact ⟨this.choose, this.choose_spec.1,
    fun q hq => this.choose_spec.2 q
      (Relation.ReflTransGen.tail this.choose_spec.1 hq) hq⟩

/-- Corollary: under a measure-decreasing step relation, every element
    reaches a normal form via finitely many steps. -/
theorem exists_normalForm_of_finite_descent
    {P : Type _} {step : P → P → Prop} {μ : P → ℕ}
    (hμ : ∀ {p q : P}, step p q → μ q < μ p) :
    ∀ p : P, ∃ q : P, Relation.ReflTransGen step p q ∧ NormalForm step q :=
  exists_normalForm_of_wf (wellFounded_of_measure_decrease hμ)

/-! ## Theorem 4: Semantic invariance -/

/-- Each refinement step preserves the theorem label (semantic content)
    of a proof sketch. Proved by case analysis on the refinement constructor. -/
theorem refinementStep_preserves_semantics :
    ∀ {p q : ProofSketch α}, RefinementStep p q → p.sem = q.sem := by
  intro p q h; cases h <;> rfl

/-
**Semantic Invariance Theorem.**
    The reflexive-transitive closure of refinement preserves semantics.
    Any proof reachable by refinement establishes the same theorem.
-/
theorem refines_preserves_semantics :
    ∀ {p q : ProofSketch α}, Refines RefinementStep p q → p.sem = q.sem := by
  intro p q hpq;
  induction hpq <;> [ rfl; exact Eq.trans ‹_› ( refinementStep_preserves_semantics ‹_› ) ]

/-! ## Theorem 5: No cycles — Discrete Lyapunov theorem -/

/-- **Discrete Lyapunov / No-Cycle Theorem.**
    If every refinement step strictly decreases an ℕ-valued energy
    functional, then no nontrivial cycle `p →⁺ p` exists. -/
theorem no_cycles_of_energy_descent
    {P : Type _} {step : P → P → Prop} {E : P → ℕ}
    (hE : ∀ {p q : P}, step p q → E q < E p) :
    ∀ p, ¬ Relation.TransGen step p p := by
  intro p hp
  suffices h : ∀ {a b : P}, Relation.TransGen step a b → E b < E a from
    lt_irrefl _ (h hp)
  intro a b hab
  induction hab with
  | single h => exact hE h
  | tail _ h ih => exact lt_trans (hE h) ih

/-- Energy drop is strictly positive along any refinement step. -/
theorem energyDrop_pos_of_step
    {P : Type _} {step : P → P → Prop} {E : P → ℕ}
    (hE : ∀ {p q : P}, step p q → E q < E p)
    {p q : P} (h : step p q) :
    0 < energyDrop E p q :=
  Int.sub_pos_of_lt (Int.ofNat_lt.mpr (hE h))

/-- The `TransGen` of a measure-decreasing relation also strictly
    decreases the measure. -/
theorem transGen_decreases_measure
    {P : Type _} {step : P → P → Prop} {μ : P → ℕ}
    (hμ : ∀ {p q : P}, step p q → μ q < μ p)
    {p q : P} (h : Relation.TransGen step p q) : μ q < μ p := by
  induction h with
  | single h => exact hμ h
  | tail _ h ih => exact lt_trans (hμ h) ih

/-! ## Theorem 6: Normal-form minimality -/

/-
**Minimality Theorem.**
    A normal form has minimal measure among its own descendants.
-/
theorem normalForm_minimal
    {P : Type _} {step : P → P → Prop} {μ : P → ℕ}
    (_hμ : ∀ {p q : P}, step p q → μ q < μ p) :
    ∀ {p q : P}, Relation.ReflTransGen step p q → NormalForm step q →
      ∀ r, Relation.ReflTransGen step q r → μ q ≤ μ r := by
  intro p q hpq hq r hr;
  induction hr <;> simp_all +decide [ NormalForm ];
  grind +qlia

/-! ## Theorem 7: Refinement step strictly decreases score -/

/-
Every refinement step on `ProofSketch α` strictly decreases the
    scalar complexity score.
-/
theorem refinementStep_decreases_score :
    ∀ {p q : ProofSketch α}, RefinementStep p q → q.score < p.score := by
  intro p q h;
  rcases h with ( _ | _ | _ | _ | _ | _ );
  all_goals unfold ProofSketch.score; simp +decide [ ProofComplexity.score ] ;
  all_goals unfold ProofSketch.complexity; simp +arith +decide [ ProofSketch.size, ProofSketch.depth, ProofSketch.lcount ] ;

/-! ## Theorem 8: Concrete refinement chain for √2 irrationality -/

/-- A bloated proof sketch for `IrrationalSqrt2`. -/
def sqrt2Bloated : ProofSketch TheoremLabel :=
  .redundant (.duplicate (.redundant (.axiom_ .IrrationalSqrt2)))

/-- A partially simplified sketch. -/
def sqrt2Medium : ProofSketch TheoremLabel :=
  .duplicate (.redundant (.axiom_ .IrrationalSqrt2))

/-- A further simplified sketch. -/
def sqrt2Reduced : ProofSketch TheoremLabel :=
  .redundant (.axiom_ .IrrationalSqrt2)

/-- The final normal form: just the axiom. -/
def sqrt2Final : ProofSketch TheoremLabel :=
  .axiom_ .IrrationalSqrt2

/-
**Concrete Refinement Chain.**
    Demonstrates a complete refinement trajectory from a bloated
    proof sketch through intermediate forms to the normal form.
-/
theorem sqrt2_sketch_refinement_chain :
    ∃ p₀ p₁ p₂ : ProofSketch TheoremLabel,
      p₀.sem = .IrrationalSqrt2 ∧
      RefinementStep p₀ p₁ ∧
      RefinementStep p₁ p₂ ∧
      p₂.score < p₁.score ∧
      p₁.score < p₀.score ∧
      NormalForm RefinementStep p₂ := by
  use .duplicate (.redundant (.axiom_ .IrrationalSqrt2)), .redundant (.axiom_ .IrrationalSqrt2), .axiom_ .IrrationalSqrt2;
  constructor;
  · rfl;
  · refine' ⟨ _, _, _, _, _ ⟩;
    · constructor;
    · constructor;
    · decide +revert;
    · decide +kernel;
    · intro q hq; cases hq ;

/-! ## Theorem 9: Confluence for the redundancy/duplication subsystem -/

/-- Local confluence: the `dropRedundant` rule at root level is deterministic. -/
theorem local_confluence_drop_subsystem
    {p q₁ q₂ : ProofSketch α}
    (h₁ : RefinementStep (.redundant p) q₁)
    (h₂ : RefinementStep (.redundant p) q₂) :
    q₁ = q₂ := by
  cases h₁ <;> cases h₂ <;> rfl

/-! ## Theorem 10: Normalize preserves semantics -/

/-
One step of greedy simplification preserves semantics.
-/
theorem stepOnce_sem (p : ProofSketch α) (q : ProofSketch α)
    (h : p.stepOnce = some q) : p.sem = q.sem := by
  revert p q;
  intro p q h_eq
  induction' p with p hp generalizing q;
  all_goals unfold ProofSketch.stepOnce at h_eq; aesop;

/-
Normalization with fuel preserves semantics.
-/
theorem normalizeFuel_sem (n : ℕ) (p : ProofSketch α) :
    (p.normalizeFuel n).sem = p.sem := by
  induction' n with n ih generalizing p;
  · rfl;
  · by_cases h : p.stepOnce = none <;> simp_all +decide [ normalizeFuel ];
    -- Since p.stepOnce is not none, we can write it as some p'.
    obtain ⟨p', hp'⟩ : ∃ p', p.stepOnce = some p' := by
      exact Option.ne_none_iff_exists'.mp h;
    rw [ hp', ih, stepOnce_sem p p' hp' ]

/-
**Normalize preserves semantics.**
-/
theorem normalize_semantics (p : ProofSketch α) :
    p.normalize.sem = p.sem := by
  exact normalizeFuel_sem _ _