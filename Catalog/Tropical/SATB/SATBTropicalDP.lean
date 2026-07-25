import Mathlib

/-!
# Tropical Dynamic Programming for SATB Chorale Optimization

This file establishes a complete formal theory of four-part SATB (Soprano–Alto–Tenor–Bass)
chorale harmonization as a tropical (min-plus) dynamic programming problem on a layered
hypergraph of polyphonic states.

## Overview

We model SATB harmonization as a finite-horizon optimization problem:
- **States** are 4-tuples of integer pitches (`Voice := Fin 4 → ℤ`)
- **Vertical penalties** measure harmonic quality at each time step
- **Horizontal penalties** measure voice-leading quality between consecutive steps
- **Admissibility predicates** encode position-wise constraints (key, range, etc.)

The total cost of a realization decomposes as a sum of vertical and horizontal terms,
and the optimization is governed by a Bellman recursion over a finite admissible state space.

## Main Results

### Bellman Recursion (Theorem A)
* `satb_bellman_base` — Base case: value at horizon 0 is the vertical penalty
* `satb_bellman_recursion` — The value function satisfies the Bellman equation

### Optimal Substructure (Theorem B)
* `pathCost_cons_decompose` — Cost decomposes into first step + suffix cost
* `admissible_tail_of_admissible` — Tails of admissible paths are admissible
* `satb_optimal_tail` — Optimal realizations have optimal tails (principle of optimality)

### Penalty–Legality Correspondence (Theorem C)
* `satb_legality_zero_penalty` — Zero sets of penalties equal legality sets
* `tropical_conjunction_legal_iff` — Tropical max of nonneg penalties = 0 iff all = 0
* `tropical_conjunction_four_legal_iff` — 4-way version for SATB constraints
* `bool_and_as_tropical_max_satb` — Boolean AND ↔ tropical max = 0

### Additional Results
* `valueFn_mono_vert` — Monotonicity of value function in vertical penalties
* `valueFn_vert_shift` — Gauge invariance under additive shifts
* `combined_penalty_lower_bound` — Violations yield positive combined penalty
* `tropical_mirror_satb` — Idempotence of max (duplicate constraint elimination)

## Mathematical Significance

This formalization establishes that classical harmony can be treated as a **certified
min-plus control problem on structured musical states**, creating a new formal bridge
between tropical algebra, combinatorial optimization, computational music theory,
and weighted logic.
-/

open Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- A **Voice** configuration: 4 integer pitches for Soprano, Alto, Tenor, Bass. -/
abbrev Voice := Fin 4 → ℤ

/-- A **Realization** of length `N+1`: a sequence of voice configurations. -/
abbrev Realization (N : ℕ) := Fin (N + 1) → Voice

/-- Total path cost = sum of vertical penalties + sum of voice-leading penalties. -/
def pathCost (N : ℕ) (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (x : Realization N) : ℤ :=
  (∑ i : Fin (N + 1), vert (x i)) +
  (∑ i : Fin N, lead (x (Fin.castSucc i)) (x i.succ))

/-- A realization is **admissible** if every voice satisfies the position predicate. -/
def admissible (N : ℕ) (allow : Fin (N + 1) → Voice → Prop)
    (x : Realization N) : Prop :=
  ∀ i, allow i (x i)

/-- Extract the tail of a realization (dropping the first element). -/
def tailRealization {N : ℕ} (x : Realization (N + 1)) : Realization N :=
  fun i => x i.succ

/-- Value function for the finite-state tropical DP on SATB voicings. -/
def valueFn (S : Finset Voice) (allow : ℕ → Voice → Prop)
    [inst : ∀ n v, Decidable (allow n v)]
    (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (hne : ∀ n, (S.filter (allow n)).Nonempty) : ℕ → Voice → ℤ
  | 0, v => vert v
  | n + 1, v =>
    vert v + (S.filter (allow (n + 1))).inf' (hne (n + 1))
      (fun w => lead v w + valueFn S allow vert lead hne n w)

/-! ## Part I: Bellman Recursion (Theorem A) -/

/-- **Base case**: The value function at horizon 0 is the vertical penalty. -/
theorem satb_bellman_base
    (S : Finset Voice) (allow : ℕ → Voice → Prop)
    [inst : ∀ n v, Decidable (allow n v)]
    (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (hne : ∀ n, (S.filter (allow n)).Nonempty)
    (v : Voice) :
    valueFn S allow vert lead hne 0 v = vert v := rfl

/-- **Bellman recursion** for the SATB tropical dynamic program:
    `V(n+1, v) = vert(v) + min_{w admissible} (lead(v,w) + V(n, w))` -/
theorem satb_bellman_recursion
    (S : Finset Voice) (allow : ℕ → Voice → Prop)
    [inst : ∀ n v, Decidable (allow n v)]
    (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (hne : ∀ n, (S.filter (allow n)).Nonempty)
    (n : ℕ) (v : Voice) :
    valueFn S allow vert lead hne (n + 1) v =
      vert v + (S.filter (allow (n + 1))).inf' (hne (n + 1))
        (fun w => lead v w + valueFn S allow vert lead hne n w) := rfl

/-! ## Part II: Path Cost Decomposition and Optimal Substructure (Theorem B) -/

/-- Path cost of a single-step realization is just the vertical penalty. -/
theorem pathCost_zero (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (x : Realization 0) :
    pathCost 0 vert lead x = vert (x 0) := by
  simp [pathCost]

/-
Path cost decomposes into first-step cost plus tail cost.
-/
theorem pathCost_cons_decompose (N : ℕ) (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (x : Realization (N + 1)) :
    pathCost (N + 1) vert lead x =
      vert (x 0) + lead (x 0) (x 1) + pathCost N vert lead (tailRealization x) := by
  simp +decide only [pathCost];
  rw [ Fin.sum_univ_succ ] ; simp +decide [ Fin.sum_univ_succ ] ; ring!;

/-
The tail of an admissible realization is admissible.
-/
theorem admissible_tail_of_admissible
    {N : ℕ} (allow : Fin (N + 2) → Voice → Prop)
    (x : Realization (N + 1))
    (hadm : admissible (N + 1) allow x) :
    admissible N (fun i => allow i.succ) (tailRealization x) := by
  exact Function.const ℕ (fun i => hadm i.succ) N

/-
**Principle of optimality (Theorem B)**: If a realization is globally optimal
    among all admissible realizations with the same starting voice, then its tail
    is optimal among all admissible continuations from `x 1`.
-/
theorem satb_optimal_tail
    (N : ℕ) (allow : Fin (N + 2) → Voice → Prop)
    (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (x : Realization (N + 1))
    (hadm : admissible (N + 1) allow x)
    (hopt : ∀ y : Realization (N + 1), admissible (N + 1) allow y →
      y 0 = x 0 → pathCost (N + 1) vert lead x ≤ pathCost (N + 1) vert lead y) :
    ∀ z : Realization N,
      admissible N (fun i => allow i.succ) z →
      z 0 = x 1 →
      pathCost N vert lead (tailRealization x) ≤ pathCost N vert lead z := by
  -- Construct y from z by prepending x 0.
  intro z hz hz0
  have hy : ∃ y : Realization (N + 1), y 0 = x 0 ∧ tailRealization y = z ∧ admissible (N + 1) allow y := by
    refine' ⟨ Fin.cons ( x 0 ) z, _, _, _ ⟩ <;> simp_all +decide [ Fin.forall_fin_succ, admissible ];
    exact funext fun i => by cases i using Fin.inductionOn <;> rfl;
  obtain ⟨ y, hy0, hy1, hy2 ⟩ := hy; specialize hopt y hy2 hy0; simp_all +decide [ pathCost_cons_decompose ] ;
  unfold tailRealization at *; aesop;

/-! ## Part III: Penalty–Legality Correspondence (Theorem C) -/

/-
The zero set of a penalty function equals the legality set.
-/
theorem satb_legality_zero_penalty
    (pen : Voice → ℤ)
    (legal : Voice → Prop)
    (hpen : ∀ v, pen v = 0 ↔ legal v) :
    {v | pen v = 0} = {v | legal v} := by
  exact Set.ext hpen

/-
Indicator penalties are nonneg.
-/
theorem tropical_penalty_nonneg_of_indicator
    (legal : Voice → Prop) [DecidablePred legal]
    (M : ℤ) (hM : 0 < M) :
    ∀ v, 0 ≤ (if legal v then (0 : ℤ) else M) := by
  grind

/-
**Tropical conjunction**: max of nonneg penalties = 0 iff each = 0.
-/
theorem tropical_conjunction_legal_iff
    (p₁ p₂ : Voice → ℤ)
    (h₁ : ∀ v, 0 ≤ p₁ v) (h₂ : ∀ v, 0 ≤ p₂ v) (v : Voice) :
    max (p₁ v) (p₂ v) = 0 ↔ p₁ v = 0 ∧ p₂ v = 0 := by
  grind

/-
**4-way tropical conjunction** for SATB constraints.
-/
theorem tropical_conjunction_four_legal_iff
    (p₁ p₂ p₃ p₄ : Voice → ℤ)
    (h₁ : ∀ v, 0 ≤ p₁ v) (h₂ : ∀ v, 0 ≤ p₂ v)
    (h₃ : ∀ v, 0 ≤ p₃ v) (h₄ : ∀ v, 0 ≤ p₄ v)
    (v : Voice) :
    max (p₁ v) (max (p₂ v) (max (p₃ v) (p₄ v))) = 0 ↔
      p₁ v = 0 ∧ p₂ v = 0 ∧ p₃ v = 0 ∧ p₄ v = 0 := by
  grind

/-
**Boolean AND as tropical max**: conjunction of predicates ↔ max of indicators = 0.
-/
theorem bool_and_as_tropical_max_satb
    (c₁ c₂ c₃ c₄ : Voice → Prop) [DecidablePred c₁] [DecidablePred c₂]
    [DecidablePred c₃] [DecidablePred c₄]
    (M : ℤ) (hM : 0 < M) (v : Voice) :
    (c₁ v ∧ c₂ v ∧ c₃ v ∧ c₄ v) ↔
      max (if c₁ v then 0 else M) (max (if c₂ v then 0 else M)
        (max (if c₃ v then 0 else M) (if c₄ v then 0 else M))) = 0 := by
  grind

/-
Violation of any constraint yields positive combined penalty.
-/
theorem combined_penalty_lower_bound
    (p₁ p₂ : Voice → ℤ)
    (h₁ : ∀ v, 0 ≤ p₁ v) (h₂ : ∀ v, 0 ≤ p₂ v)
    (v : Voice) (hv : p₁ v ≠ 0 ∨ p₂ v ≠ 0) :
    0 < max (p₁ v) (p₂ v) := by
  grind

/-- Duplicate constraints don't increase penalty (tropical idempotence). -/
theorem tropical_mirror_satb (p : Voice → ℤ) (v : Voice) :
    max (p v) (p v) = p v :=
  max_self _

/-! ## Part IV: Value Function Properties -/

/-
Monotonicity: larger vertical penalties yield larger value.
-/
theorem valueFn_mono_vert
    (S : Finset Voice) (allow : ℕ → Voice → Prop)
    [inst : ∀ n v, Decidable (allow n v)]
    (vert₁ vert₂ : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (hne : ∀ n, (S.filter (allow n)).Nonempty)
    (hle : ∀ v, vert₁ v ≤ vert₂ v) :
    ∀ n v, valueFn S allow vert₁ lead hne n v ≤ valueFn S allow vert₂ lead hne n v := by
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · exact fun v => (fun {a b} => Int.le_def.mpr) (hle v);
  · intros v
    rw [satb_bellman_recursion, satb_bellman_recursion];
    refine' add_le_add ( hle v ) _;
    simp +zetaDelta at *;
    grind +revert

/-
Gauge invariance: shifting vertical penalties by `c` shifts value by `(n+1)*c`.
-/
theorem valueFn_vert_shift
    (S : Finset Voice) (allow : ℕ → Voice → Prop)
    [inst : ∀ n v, Decidable (allow n v)]
    (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
    (hne : ∀ n, (S.filter (allow n)).Nonempty)
    (c : ℤ) :
    ∀ n v, valueFn S allow (fun w => vert w + c) lead hne n v =
      valueFn S allow vert lead hne n v + (↑n + 1) * c := by
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · aesop;
  · intros v
    simp [valueFn, ih];
    simp +decide [ add_assoc, add_left_comm, add_comm, Finset.inf'_eq_csInf_image ];
    rw [ show ( fun x => lead v x + ( valueFn S allow vert lead hne n x + ( n + 1 ) * c ) ) = fun x => lead v x + valueFn S allow vert lead hne n x + ( n + 1 ) * c by ext; ring ] ; rw [ show ( fun w => lead v w + valueFn S allow vert lead hne n w ) = fun w => lead v w + valueFn S allow vert lead hne n w by rfl ] ; rw [ show ( sInf ( ( fun x => lead v x + valueFn S allow vert lead hne n x + ( n + 1 ) * c ) '' { x | x ∈ S ∧ allow ( n + 1 ) x } ) ) = sInf ( ( fun w => lead v w + valueFn S allow vert lead hne n w ) '' { x | x ∈ S ∧ allow ( n + 1 ) x } ) + ( n + 1 ) * c from ?_ ] ; ring;
    rw [ show ( fun x => lead v x + valueFn S allow vert lead hne n x + ( n + 1 ) * c ) '' { x | x ∈ S ∧ allow ( n + 1 ) x } = ( fun w => w + ( n + 1 ) * c ) '' ( ( fun w => lead v w + valueFn S allow vert lead hne n w ) '' { x | x ∈ S ∧ allow ( n + 1 ) x } ) from ?_, csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
    · obtain ⟨ w, hw ⟩ := hne ( n + 1 );
      exact ⟨ lead v w + valueFn S allow vert lead hne n w + ( n + 1 ) * c, by aesop ⟩;
    · simp +zetaDelta at *;
      intro a x hx₁ hx₂ hx₃; linarith [ show sInf ( ( fun w => lead v w + valueFn S allow vert lead hne n w ) '' { x | x ∈ S ∧ allow ( n + 1 ) x } ) ≤ lead v x + valueFn S allow vert lead hne n x from csInf_le ( by exact Set.Finite.bddBelow <| Set.Finite.image _ <| Set.Finite.subset ( Finset.finite_toSet S ) fun x hx => hx.1 ) <| Set.mem_image_of_mem _ ⟨ hx₁, hx₂ ⟩ ] ;
    · intro w hw;
      obtain ⟨ x, hx ⟩ := ( show ∃ x ∈ ( fun w => lead v w + valueFn S allow vert lead hne n w ) '' { x | x ∈ S ∧ allow ( n + 1 ) x }, x ≤ sInf ( ( fun w => lead v w + valueFn S allow vert lead hne n w ) '' { x | x ∈ S ∧ allow ( n + 1 ) x } ) from by
                              exact ⟨ _, ( IsCompact.sInf_mem ( show IsCompact ( ( fun w => lead v w + valueFn S allow vert lead hne n w ) '' { x | x ∈ S ∧ allow ( n + 1 ) x } ) from Set.Finite.isCompact <| Set.Finite.image _ <| Set.Finite.subset ( Finset.finite_toSet S ) fun x hx => hx.1 ) <| Set.Nonempty.image _ <| by obtain ⟨ x, hx ⟩ := hne ( n + 1 ) ; exact ⟨ x, by aesop ⟩ ), le_rfl ⟩ );
      exact ⟨ x + ( n + 1 ) * c, Set.mem_image_of_mem _ hx.1, by linarith ⟩;
    · aesop

/-- The vertical penalty decomposition is definitionally correct. -/
theorem satb_vertical_penalty_decomposes
    (p₁ p₂ p₃ p₄ : Voice → ℤ) (v : Voice) :
    (fun w => max (p₁ w) (max (p₂ w) (max (p₃ w) (p₄ w)))) v =
      max (p₁ v) (max (p₂ v) (max (p₃ v) (p₄ v))) := rfl

end