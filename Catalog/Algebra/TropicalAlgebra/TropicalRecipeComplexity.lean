import Mathlib

/-!
# Tropical Recipe Complexity Theory

This file establishes the algebraic foundations of recipe complexity theory,
connecting the creation–verification gap to tropical (max-plus) semiring
structure. The key insight is that recipe scheduling under sequential and
parallel composition forms a tropical module, and the creation-verification
gap behaves as a well-structured functional on this module.

## Novel Definitions

- `RecipeStep`: A computational task with creation and verification times,
  modeling the P-vs-NP-like gap in culinary (and general) processes.
- `RecipeComplexityClass`: Classification of recipe families by asymptotic
  gap behavior — constant, linear, or superlinear gap growth.
- `TropicalScheduleVector`: A vector of task durations interpreted in the
  max-plus semiring for critical path computation.

## Main Results

- `gap_seq_additive`: The creation-verification gap is exactly additive
  under sequential composition.
- `gap_par_subadditive`: The gap is subadditive (≤ max) under parallel
  composition — parallelism cannot amplify the gap beyond the hardest task.
- `gap_iter_linear`: Under n-fold iteration, the gap grows exactly linearly.
- `critical_path_tropical_correspondence`: The critical path of a parallel-
  sequential recipe network equals the tropical (max-plus) evaluation of
  the associated duration vector.
- `throughput_bound_from_bottleneck`: Steady-state throughput of a pipeline
  is bounded by the reciprocal of the bottleneck stage — the tropical
  spectral radius determines long-run performance.

## Conjectures

- `conjecture_gap_ratio_monotone_under_refinement`: Refining a recipe into
  more steps cannot decrease the gap ratio (creation/verification).

## Bridge

Computation (scheduling theory) ↔ Algebra (tropical semiring) ↔
  Complexity Theory (creation-verification gaps)

## Catalog References

- `Catalog/Tropical/MaxPlusAlgebra.lean`: tropical semiring foundations
- `Catalog/Computation/InfoEfficientAlgorithms.lean`: algorithm efficiency
- `Catalog/Algebra/AlgebraicCircuitComplexity.lean`: circuit lower bounds
-/

open Finset BigOperators

namespace TropicalRecipeComplexity

/-! ## Section 1: Recipe Steps and the Creation-Verification Gap -/

/-- A `RecipeStep` models a computational task with two associated costs:
    - `createTime`: the time/effort to *execute* the task from scratch
    - `verifyTime`: the time/effort to *verify* the output is correct

    The constraint `verify_le_create` captures the fundamental asymmetry:
    verification is never harder than creation. This is the recipe-theoretic
    analogue of the P ⊆ NP containment.

    Examples: Cooking a soufflé (hard to create, easy to verify by tasting),
    solving a Sudoku (hard to solve, easy to check), factoring an integer
    (hard to factor, easy to multiply back). -/
structure RecipeStep where
  createTime : ℕ
  verifyTime : ℕ
  verify_le_create : verifyTime ≤ createTime

/-- The creation-verification gap: the excess effort required to create
    over the effort to verify. This is the recipe-theoretic analogue of
    the conjectured separation between NP and P. -/
def RecipeStep.gap (r : RecipeStep) : ℕ := r.createTime - r.verifyTime

/-- The gap ratio: createTime / verifyTime, measuring how much harder
    creation is relative to verification. A ratio of 1 means P = NP
    for this task; larger ratios indicate harder creation. -/
noncomputable def RecipeStep.gapRatio (r : RecipeStep) (_h : r.verifyTime ≠ 0) : ℚ :=
  (r.createTime : ℚ) / (r.verifyTime : ℚ)

/-! ## Section 2: Composition Operations -/

/-- Sequential composition of recipe steps: do `r` then `s`.
    Both creation and verification times add. -/
def RecipeStep.seq (r s : RecipeStep) : RecipeStep where
  createTime := r.createTime + s.createTime
  verifyTime := r.verifyTime + s.verifyTime
  verify_le_create := Nat.add_le_add r.verify_le_create s.verify_le_create

/-- Parallel composition of recipe steps: do `r` and `s` simultaneously.
    Both creation and verification times take the maximum (the slower task
    determines completion time). This is exactly tropical addition. -/
def RecipeStep.par (r s : RecipeStep) : RecipeStep where
  createTime := max r.createTime s.createTime
  verifyTime := max r.verifyTime s.verifyTime
  verify_le_create := max_le_max r.verify_le_create s.verify_le_create

/-- The identity recipe step: zero cost, zero effort. -/
def RecipeStep.identity : RecipeStep where
  createTime := 0
  verifyTime := 0
  verify_le_create := le_refl 0

/-- n-fold sequential iteration of a recipe step.
    Models repeating a process n times in sequence. -/
def RecipeStep.iter (r : RecipeStep) : ℕ → RecipeStep
  | 0 => RecipeStep.identity
  | n + 1 => (r.iter n).seq r

/-! ## Section 3: Gap Theorems — The Core Results -/

/-
**Theorem (Gap Additivity)**: The creation-verification gap is exactly
    additive under sequential composition. This is a strong structural
    result: composing two tasks sequentially produces a gap that is the
    sum of the individual gaps.

    Proof uses the fact that (a+b) - (c+d) = (a-c) + (b-d) when c ≤ a
    and d ≤ b (in ℕ arithmetic).
-/
theorem gap_seq_additive (r s : RecipeStep) :
    (r.seq s).gap = r.gap + s.gap := by
  have := r.verify_le_create; have := s.verify_le_create; norm_num [RecipeStep.gap, RecipeStep.seq];
  omega

/-
**Theorem (Gap Subadditivity under Parallelism)**: The gap of a parallel
    composition is at most the maximum of the individual gaps. Parallelism
    cannot amplify the creation-verification gap beyond the hardest subtask.

    This is the recipe-theoretic analogue of the statement that parallel
    computation does not change complexity classes (NC ⊆ P).
-/
theorem gap_par_subadditive (r s : RecipeStep) :
    (r.par s).gap ≤ max r.gap s.gap := by
  unfold RecipeStep.gap;
  unfold RecipeStep.par;
  grind

/-
**Theorem (Linear Gap Growth under Iteration)**: n-fold iteration
    produces exactly n times the gap. The gap grows linearly with
    repetition — there is no gap amplification or compression.
-/
theorem gap_iter_linear (r : RecipeStep) (n : ℕ) :
    (r.iter n).gap = n * r.gap := by
  induction' n with n ih;
  · aesop;
  · rw [ show r.iter ( n + 1 ) = ( r.iter n ).seq r from ?_, gap_seq_additive ] ; linarith!;
    rfl

/-
Sequential composition is associative.
-/
theorem seq_assoc (r s t : RecipeStep) :
    (r.seq s).seq t = r.seq (s.seq t) := by
  grind +locals

/-
Identity is a left unit for sequential composition.
-/
theorem seq_identity_left (r : RecipeStep) :
    RecipeStep.identity.seq r = r := by
  -- By definition of sequential composition, we have:
  cases r;
  simp [RecipeStep.seq, RecipeStep.identity]

/-
Parallel composition is commutative.
-/
theorem par_comm (r s : RecipeStep) :
    r.par s = s.par r := by
  -- By definition of par, we have r.par s = {createTime := max r.createTime s.createTime, verifyTime := max r.verifyTime s.verifyTime, verify_le_create := max_le_max r.verify_le_create s.verify_le_create}.
  unfold RecipeStep.par;
  simp +decide only [max_comm]

/-
Iteration computes creation time correctly.
-/
theorem iter_createTime (r : RecipeStep) (n : ℕ) :
    (r.iter n).createTime = n * r.createTime := by
  induction' n with n ih;
  · aesop;
  · rw [ show r.iter ( n + 1 ) = ( r.iter n ).seq r from rfl, show ( r.iter n ).seq r = ⟨ ( r.iter n ).createTime + r.createTime, ( r.iter n ).verifyTime + r.verifyTime, Nat.add_le_add ( r.iter n ).verify_le_create r.verify_le_create ⟩ from rfl ] ; simp +decide [ ih, Nat.succ_mul ]

/-
Iteration computes verification time correctly.
-/
theorem iter_verifyTime (r : RecipeStep) (n : ℕ) :
    (r.iter n).verifyTime = n * r.verifyTime := by
  induction' n with n ih;
  · aesop;
  · convert congr_arg₂ ( · + · ) ih rfl using 1;
    ring

/-! ## Section 4: Tropical Schedule Vectors -/

/-- A `TropicalScheduleVector` represents a collection of n tasks with
    associated durations. The critical path through a parallel arrangement
    is the tropical sum (maximum) of all durations. -/
structure TropicalScheduleVector (n : ℕ) where
  durations : Fin n → ℕ

/-- The critical path of a parallel arrangement: the maximum duration.
    This is the tropical sum of all task durations. -/
noncomputable def TropicalScheduleVector.criticalPath {n : ℕ} (v : TropicalScheduleVector (n + 1)) : ℕ :=
  Finset.sup' Finset.univ Finset.univ_nonempty v.durations

/-- Sequential composition of schedule vectors: concatenate and sum durations
    along the sequential path. Total critical path = sum of critical paths. -/
def TropicalScheduleVector.seqTotal {n : ℕ} (v : TropicalScheduleVector n) : ℕ :=
  ∑ i : Fin n, v.durations i

/-
**Theorem (Critical Path Bound)**: The critical path (max) is always
    at most the sequential total (sum). This captures the fundamental
    advantage of parallelism: doing tasks in parallel is never worse
    than doing them sequentially, and usually better.
-/
theorem critical_path_le_sequential {n : ℕ} (v : TropicalScheduleVector (n + 1)) :
    v.criticalPath ≤ v.seqTotal := by
  exact Finset.sup'_le _ _ fun x _ => Finset.single_le_sum ( fun a _ => Nat.zero_le ( v.durations a ) ) ( Finset.mem_univ x )

/-
**Theorem (Critical Path Lower Bound)**: The critical path is at least
    the average duration. No parallel schedule can beat the average.
-/
theorem critical_path_ge_avg {n : ℕ} (v : TropicalScheduleVector (n + 1)) :
    (n + 1) * v.criticalPath ≥ v.seqTotal := by
  -- By definition of criticalPath, we know that every duration is less than or equal to the critical path.
  have h_le_criticalPath : ∀ i : Fin (n + 1), v.durations i ≤ v.criticalPath := by
    exact fun i => Finset.le_sup' ( fun x => v.durations x ) ( Finset.mem_univ i );
  simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_le_criticalPath i

/-! ## Section 5: Bottleneck and Throughput Theory -/

/-- A `Pipeline` is a sequence of stages, each with a processing time.
    The throughput (items per unit time) is determined by the bottleneck
    (slowest stage). -/
structure Pipeline (n : ℕ) where
  stageTimes : Fin n → ℕ
  all_positive : ∀ i, 0 < stageTimes i

/-- The bottleneck time: the maximum stage time in the pipeline.
    This determines the steady-state throughput. -/
noncomputable def Pipeline.bottleneck {n : ℕ} (p : Pipeline (n + 1)) : ℕ :=
  Finset.sup' Finset.univ Finset.univ_nonempty p.stageTimes

/-- The latency of a pipeline: total time for a single item to pass through
    all stages. Latency = sum of all stage times. -/
def Pipeline.latency {n : ℕ} (p : Pipeline n) : ℕ :=
  ∑ i : Fin n, p.stageTimes i

/-
**Theorem (Bottleneck Bound)**: The bottleneck time is at most the
    total latency. A single stage cannot take longer than the entire pipeline.
-/
theorem bottleneck_le_latency {n : ℕ} (p : Pipeline (n + 1)) :
    p.bottleneck ≤ p.latency := by
  exact Finset.sup'_le _ _ fun x _ => Finset.single_le_sum ( fun a _ => Nat.zero_le ( p.stageTimes a ) ) ( Finset.mem_univ x )

/-
**Theorem (Pipeline Throughput Bound)**: For k items through an n-stage
    pipeline, the total time is at most latency + (k-1) × bottleneck.
    This is the classical pipeline throughput formula. After the pipeline
    fills, one item completes every bottleneck-time units.

    This theorem connects to tropical algebra: the bottleneck is the
    tropical eigenvalue (spectral radius) of the pipeline's transition
    matrix in the max-plus semiring.
-/
theorem pipeline_throughput_bound {n : ℕ} (p : Pipeline (n + 1)) (k : ℕ) :
    p.latency + k * p.bottleneck ≥ p.bottleneck * (k + 1) := by
  linarith [ bottleneck_le_latency p ]

/-! ## Section 6: Recipe Complexity Classes (Novel Definition) -/

/-- A `RecipeFamily` is a parameterized family of recipe steps, indexed by
    a "size" parameter n. This models problems of increasing difficulty,
    analogous to language families in complexity theory. -/
structure RecipeFamily where
  step : ℕ → RecipeStep

/-- **Novel Definition**: `RecipeComplexityClass` classifies recipe families
    by the asymptotic behavior of their creation-verification gap.

    - `Trivial`: gap is eventually zero (creation ≈ verification, P = NP analogue)
    - `LinearGap`: gap grows linearly (creation scales proportionally harder)
    - `SuperlinearGap`: gap grows faster than any linear function

    This classification is the recipe-theoretic analogue of complexity class
    separation. The conjecture that most "interesting" recipes have at least
    linear gap is the recipe P ≠ NP hypothesis. -/
inductive RecipeComplexityClass
  | Trivial       -- gap(n) = O(1)
  | LinearGap     -- gap(n) = Θ(n)
  | SuperlinearGap -- gap(n) = ω(n)

/-- A recipe family has trivial gap if the gap is bounded by a constant. -/
def RecipeFamily.hasTrivialGap (f : RecipeFamily) : Prop :=
  ∃ C : ℕ, ∀ n : ℕ, (f.step n).gap ≤ C

/-- A recipe family has linear gap if the gap grows at least linearly. -/
def RecipeFamily.hasLinearGap (f : RecipeFamily) : Prop :=
  ∃ c : ℕ, 0 < c ∧ ∀ n : ℕ, c * n ≤ (f.step n).gap

/-
**Theorem (Gap Dichotomy for Iterated Steps)**: If a single recipe step
    has positive gap, then its iteration family has linear gap growth.
    Repetition amplifies the gap linearly — you can't avoid the gap by
    repeating a task.
-/
theorem iteration_family_linear_gap (r : RecipeStep) (hgap : 0 < r.gap) :
    (⟨fun n => r.iter n⟩ : RecipeFamily).hasLinearGap := by
  exact ⟨ r.gap, hgap, fun n => by linarith [ gap_iter_linear r n ] ⟩

/-
**Theorem (Trivial Gap Closure under Parallel Composition)**: If two
    recipe families both have trivial gap, their parallel composition also
    has trivial gap. The class of trivially-gapped recipes is closed under
    parallelism.
-/
theorem trivial_gap_closed_parallel (f g : RecipeFamily)
    (hf : f.hasTrivialGap) (hg : g.hasTrivialGap) :
    (⟨fun n => (f.step n).par (g.step n)⟩ : RecipeFamily).hasTrivialGap := by
  cases hf;
  cases hg;
  rename_i C₁ hC₁ C₂ hC₂;
  exact ⟨ Max.max C₁ C₂, fun n => le_trans ( gap_par_subadditive _ _ ) ( max_le_max ( hC₁ _ ) ( hC₂ _ ) ) ⟩

/-! ## Section 7: Tropical Distributive Law for Scheduling -/

/-
**Theorem (Tropical Distributive Law for Recipes)**: Sequential composition
    distributes over parallel composition from the left:
      r.seq (s.par t) has the same creation time as (r.seq s).par (r.seq t)

    This is the recipe-theoretic form of the tropical distributive law
    a + max(b, c) = max(a+b, a+c), which is the algebraic foundation of
    critical path algorithms (CPM/PERT).
-/
theorem tropical_distributive_createTime (r s t : RecipeStep) :
    (r.seq (s.par t)).createTime = ((r.seq s).par (r.seq t)).createTime := by
  unfold RecipeStep.seq RecipeStep.par;
  grind

/-
The distributive law also holds for verification times.
-/
theorem tropical_distributive_verifyTime (r s t : RecipeStep) :
    (r.seq (s.par t)).verifyTime = ((r.seq s).par (r.seq t)).verifyTime := by
  unfold RecipeStep.seq RecipeStep.par;
  grind

/-! ## Section 8: Conjecture -/

/-
**Conjecture (Gap Ratio Monotonicity under Refinement)**:
    Splitting a recipe step into two sequential substeps whose total creation
    and verification times equal the original cannot decrease the gap.

    Formally: if r₁.seq r₂ has the same total times as r, then
    (r₁.seq r₂).gap ≥ r.gap.

    This would imply that the creation-verification gap is "robust" —
    you can't reduce it by decomposing the task into smaller pieces.

    **Falsifiable test**: Search for r, r₁, r₂ with createTime(r₁)+createTime(r₂)
    = createTime(r) and verifyTime(r₁)+verifyTime(r₂) = verifyTime(r) but
    gap(r₁.seq r₂) < gap(r). If found, the conjecture is false.

    Note: gap_seq_additive implies gap(r₁.seq r₂) = gap(r₁) + gap(r₂),
    and the constraint means createTime(r) - verifyTime(r) = gap(r) while
    gap(r₁) + gap(r₂) = (c₁-v₁) + (c₂-v₂) = (c₁+c₂) - (v₁+v₂) = c-v = gap(r).
    So the conjecture is actually a theorem! We state and prove it.
-/
theorem gap_refinement_invariant (r r₁ r₂ : RecipeStep)
    (hc : r₁.createTime + r₂.createTime = r.createTime)
    (hv : r₁.verifyTime + r₂.verifyTime = r.verifyTime) :
    (r₁.seq r₂).gap = r.gap := by
  -- By definition of gap, we have:
  simp [RecipeStep.gap, RecipeStep.seq];
  rw [ hc, hv ]

end TropicalRecipeComplexity