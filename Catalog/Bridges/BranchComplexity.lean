/-
# Exponential Growth Bounds and Complexity Classification for Bounded β-Reduction

This module develops a quantitative complexity theory for bounded lambda calculus
reduction. We introduce a **branching complexity invariant** that controls the
one-step expansion of bounded reduction trees, and prove:

1. **Theorem A (Exponential Upper Bound)**: `stateGrowth t d ≤ (B+1)^d`
   where `B` is a uniform bound on the successor count along reduction paths.
2. **Theorem C (Recurrence Inequality)**: `stateGrowth t (d+1) ≤ (B+1) * stateGrowth t d`,
   the branching process recurrence that drives the exponential bound.
3. **Successor Bound**: Each term has at most `redex_count t` distinct
   one-step β-reducts, so `branchComplexity t = redex_count t + 1` serves
   as a natural branching factor.

## Key Concepts

- **Branching complexity**: `redex_count t + 1`, a structural invariant
  bounding the number of distinct one-step successors.
- **State growth function**: The cardinality of the bounded reachable set,
  viewed as a discrete dynamical system.
- **Affine fragment**: Terms where each bound variable occurs at most once,
  a syntactic restriction relevant to complexity classification.

## Limitations and Open Problems

With named variables and naive (capture-permitting) substitution:
- `redex_count` can increase under affine substitution when a substituted
  lambda ends up in function position, creating a new redex.
- `branchComplexity` is therefore NOT monotone under β-reduction in general,
  even for affine terms (counterexample documented below).
- Proper monotonicity requires either capture-avoiding substitution
  (de Bruijn indices) or a refined invariant.
-/

import Pythagorean.BoundedBetaTheorems

open Lam

/-! ## Section 1: Structural Invariants -/

/-- Count the number of redex positions (β-redexes) in a lambda term.
    A redex is an application whose function part is a lambda abstraction. -/
def redex_count : Lam → Nat
  | .var _ => 0
  | .app (.lam _ body) arg => 1 + redex_count body + redex_count arg
  | .app t u => redex_count t + redex_count u
  | .lam _ body => redex_count body

/-- **Branching complexity**: `redex_count t + 1`, a structural bound on
    the number of distinct one-step β-reduction outcomes. -/
def branchComplexity (t : Lam) : Nat :=
  redex_count t + 1

theorem branchComplexity_pos (t : Lam) : 0 < branchComplexity t := by
  unfold branchComplexity; omega

/-- Count occurrences of variable `x` in a term. -/
def varCount (x : Nat) : Lam → Nat
  | .var n => if n = x then 1 else 0
  | .app t u => varCount x t + varCount x u
  | .lam y body => if y = x then 0 else varCount x body

/-- A term is **affine** if every bound variable occurs at most once in its body. -/
def IsAffine : Lam → Prop
  | .var _ => True
  | .app t u => IsAffine t ∧ IsAffine u
  | .lam x body => varCount x body ≤ 1 ∧ IsAffine body

instance IsAffine.decidable : ∀ t : Lam, Decidable (IsAffine t)
  | .var _ => isTrue trivial
  | .app t u =>
    match IsAffine.decidable t, IsAffine.decidable u with
    | isTrue ht, isTrue hu => isTrue ⟨ht, hu⟩
    | isFalse h, _ => isFalse (fun ⟨ht, _⟩ => h ht)
    | _, isFalse h => isFalse (fun ⟨_, hu⟩ => h hu)
  | .lam x body =>
    match Nat.decLe (varCount x body) 1, IsAffine.decidable body with
    | isTrue hv, isTrue hb => isTrue ⟨hv, hb⟩
    | isFalse h, _ => isFalse (fun ⟨hv, _⟩ => h hv)
    | _, isFalse h => isFalse (fun ⟨_, hb⟩ => h hb)

/-- A term is **linear** if every bound variable occurs exactly once. -/
def IsLinear : Lam → Prop
  | .var _ => True
  | .app t u => IsLinear t ∧ IsLinear u
  | .lam x body => varCount x body = 1 ∧ IsLinear body

theorem IsLinear.isAffine {t : Lam} (h : IsLinear t) : IsAffine t := by
  induction t with
  | var _ => trivial
  | app t u ih_t ih_u => exact ⟨ih_t h.1, ih_u h.2⟩
  | lam x body ih => exact ⟨le_of_eq h.1, ih h.2⟩

/-! ## Section 2: One-Step Successor Counting -/

def betaSuccessors (t : Lam) : Set Lam := {u | BetaStep t u}

theorem betaSuccessors_finite (t : Lam) : Set.Finite (betaSuccessors t) :=
  finite_betaStep_successors t

/-- Each term has at most `redex_count` distinct one-step β-reducts.
    Each redex position contributes at most one successor. -/
theorem card_betaSuccessors_le_redex_count (t : Lam) :
    (betaSuccessors_finite t).toFinset.card ≤ redex_count t := by
  have h_ind : ∀ t : Lam, (finite_betaStep_successors t).toFinset.card ≤ redex_count t := by
    intro t
    induction' t with t ih
    · simp +decide [redex_count]
      exact Set.eq_empty_of_forall_notMem fun u hu => by cases hu
    · rename_i k hk₁ hk₂
      by_cases h : ∃ x body, ih = .lam x body
      · obtain ⟨x, body, rfl⟩ := h
        have h_succ : (finite_betaStep_successors (Lam.app (Lam.lam x body) k)).toFinset ⊆
            Finset.image (fun u => u.app k) (finite_betaStep_successors (Lam.lam x body)).toFinset ∪
            Finset.image (fun u => (Lam.lam x body).app u) (finite_betaStep_successors k).toFinset ∪
            {body.subst x k} := by
          intro u hu; simp_all +decide [Finset.subset_iff]
          cases hu <;> aesop
        refine le_trans (Finset.card_le_card h_succ) ?_
        grind +locals
      · have h_succ : (finite_betaStep_successors (ih.app k)).toFinset ⊆
            Finset.image (fun u => u.app k) (finite_betaStep_successors ih).toFinset ∪
            Finset.image (fun u => ih.app u) (finite_betaStep_successors k).toFinset := by
          intro u hu; simp_all +decide [Set.subset_def]
          cases hu <;> aesop
        refine le_trans (Finset.card_le_card h_succ) ?_
        refine' le_trans (Finset.card_union_le _ _) _
        rw [Finset.card_image_of_injective, Finset.card_image_of_injective] <;>
          norm_num [Function.Injective]
        rw [show redex_count (ih.app k) = redex_count ih + redex_count k from ?_]
        · lia
        · cases ih <;> aesop
    · rename_i k t ih
      have h_lam : (finite_betaStep_successors (lam k t)).toFinset ⊆
          Finset.image (fun u => lam k u) (finite_betaStep_successors t).toFinset := by
        intro u hu; simp_all +decide [Finset.subset_iff]
        cases hu; aesop
      exact le_trans (Finset.card_le_card h_lam)
        (Finset.card_image_le.trans (by simpa using ih))
  grind

theorem card_betaSuccessors_le_branchComplexity (t : Lam) :
    (betaSuccessors_finite t).toFinset.card ≤ branchComplexity t := by
  calc (betaSuccessors_finite t).toFinset.card
      ≤ redex_count t := card_betaSuccessors_le_redex_count t
    _ ≤ redex_count t + 1 := Nat.le_succ _
    _ = branchComplexity t := rfl

/-! ## Section 3: State Growth Function -/

/-- The state growth function: cardinality of the set of terms reachable
    within `d` β-reduction steps from `t`. -/
noncomputable def stateGrowth (t : Lam) (d : Nat) : Nat :=
  (finite_states_of_bounded_beta d t).toFinset.card

/-- At depth 0, only the initial term is reachable. -/
theorem stateGrowth_zero (t : Lam) : stateGrowth t 0 = 1 := by
  unfold stateGrowth
  have : (finite_states_of_bounded_beta 0 t).toFinset = {t} := by
    ext u; simp [reachableWithin_zero_iff]
  rw [this]; simp

/-- State growth is monotone: more steps ⟹ at least as many reachable states. -/
theorem stateGrowth_mono {d₁ d₂ : Nat} (t : Lam) (h : d₁ ≤ d₂) :
    stateGrowth t d₁ ≤ stateGrowth t d₂ := by
  unfold stateGrowth
  apply Finset.card_le_card
  intro u; simp
  exact fun hu => ReachableWithin.mono hu h

/-! ## Section 4: Recurrence Theorem (Theorem C) -/

/-- **Theorem C (Recurrence Inequality)**: If every depth-`d` reachable term
    has at most `B` one-step successors, then the number of states reachable
    in `d + 1` steps is at most `(B + 1) * stateGrowth t d`.

    This expresses bounded β-reduction as a branching process: at each
    depth level, the population can grow by at most a factor of `B + 1`
    (each existing state contributes itself plus up to `B` successors).

    This is the combinatorial heart of the exponential bound theorem. -/
theorem stateGrowth_succ_le_mul_of_bound
    (d : Nat) (t : Lam) (B : Nat)
    (hB : ∀ u, ReachableWithin d t u →
      (betaSuccessors_finite u).toFinset.card ≤ B) :
    stateGrowth t (d + 1) ≤ (B + 1) * stateGrowth t d := by
  have h_decomp : (finite_states_of_bounded_beta (d + 1) t).toFinset ⊆
      (finite_states_of_bounded_beta d t).toFinset ∪
      Finset.biUnion (finite_states_of_bounded_beta d t).toFinset
        (fun v => (finite_betaStep_successors v).toFinset) := by
    intro u hu; simp_all +decide [Set.subset_def]
    exact Classical.or_iff_not_imp_left.2 fun h => by
      rcases hu with (_ | ⟨h₁, h₂⟩) <;> tauto
  have h_card_d : (finite_states_of_bounded_beta d t).toFinset.card = stateGrowth t d := rfl
  have h_card_biUnion :
      (Finset.biUnion (finite_states_of_bounded_beta d t).toFinset
        (fun v => (finite_betaStep_successors v).toFinset)).card ≤
      B * stateGrowth t d := by
    exact le_trans Finset.card_biUnion_le
      (by simpa [mul_comm, h_card_d] using Finset.sum_le_sum fun x
        (hx : x ∈ (finite_states_of_bounded_beta d t).toFinset) =>
          hB x <| by simpa using hx)
  have := Finset.card_mono h_decomp
  simp_all +decide [add_mul]
  exact le_trans this (le_trans (Finset.card_union_le _ _) (by linarith!))

/-! ## Section 5: Exponential Upper Bound (Theorem A) -/

/-- **Theorem A (Exponential Upper Bound)**: If the successor count is
    uniformly bounded by `B` along all reduction paths from `t`,
    then `stateGrowth t d ≤ (B + 1)^d`.

    This is the foundational quantitative theorem: the state space of
    bounded β-reduction grows at most exponentially in the depth,
    with base determined by the maximum branching factor.

    Proof by induction on `d` using the recurrence (Theorem C). -/
theorem card_boundedStates_le_pow_of_bound
    (d : Nat) (t : Lam) (B : Nat)
    (hB : ∀ d', ∀ u, ReachableWithin d' t u →
      (betaSuccessors_finite u).toFinset.card ≤ B) :
    stateGrowth t d ≤ (B + 1) ^ d := by
  induction d with
  | zero => simp [stateGrowth_zero]
  | succ d ih =>
    calc stateGrowth t (d + 1)
        ≤ (B + 1) * stateGrowth t d :=
          stateGrowth_succ_le_mul_of_bound d t B (fun u hu => hB d u hu)
      _ ≤ (B + 1) * (B + 1) ^ d := Nat.mul_le_mul_left _ ih
      _ = (B + 1) ^ (d + 1) := by ring

/-- **Theorem A' (branchComplexity version)**: When branchComplexity is
    hereditary along reduction paths (i.e., no successor has higher
    branching complexity than `t`), state growth is bounded by
    `branchComplexity(t) ^ d`.

    The hereditary hypothesis holds in well-behaved settings, e.g.,
    with capture-avoiding substitution or on closed terms. -/
theorem card_boundedStates_le_branchComplexity_pow
    (d : Nat) (t : Lam)
    (hH : ∀ d', ∀ u, ReachableWithin d' t u →
      branchComplexity u ≤ branchComplexity t) :
    stateGrowth t d ≤ (branchComplexity t) ^ d := by
  have key : ∀ d', ∀ u, ReachableWithin d' t u →
      (betaSuccessors_finite u).toFinset.card ≤ branchComplexity t - 1 := by
    intro d' u hu
    have h1 := card_betaSuccessors_le_redex_count u
    have h2 := hH d' u hu
    unfold branchComplexity at h2 ⊢; omega
  have h := card_boundedStates_le_pow_of_bound d t (branchComplexity t - 1) key
  have hpos := branchComplexity_pos t
  have heq : branchComplexity t - 1 + 1 = branchComplexity t := by omega
  rwa [heq] at h

/-- State growth bounded by `(redex_count t + 1) ^ d`. -/
theorem card_boundedStates_le_redexCount_succ_pow
    (d : Nat) (t : Lam)
    (hH : ∀ d', ∀ u, ReachableWithin d' t u →
      branchComplexity u ≤ branchComplexity t) :
    stateGrowth t d ≤ (redex_count t + 1) ^ d :=
  card_boundedStates_le_branchComplexity_pow d t hH

/-! ## Section 6: Substitution Lemmas -/

/-- Substituting into a term where the variable doesn't occur is the identity. -/
theorem subst_varCount_zero {body : Lam} {x : Nat} {arg : Lam}
    (h : varCount x body = 0) : body.subst x arg = body := by
  induction' body with body ih generalizing x
  · unfold varCount at h; unfold Lam.subst; aesop
  · simp_all +decide [varCount]
    rename_i k hk₁ hk₂
    exact congr_arg₂ _ (hk₁ h.1) (hk₂ h.2)
  · unfold varCount at h; unfold Lam.subst; aesop

/-- When a variable occurs at most once, substitution increases the redex
    count by at most `redex_count arg + 1`. The `+1` accounts for a possible
    new redex created when `var x` is in function position and `arg` is a λ. -/
theorem redex_count_subst_le_succ (body : Lam) (x : Nat) (arg : Lam)
    (hvc : varCount x body ≤ 1) :
    redex_count (body.subst x arg) ≤ redex_count body + redex_count arg + 1 := by
  induction' body with y body' ih generalizing x arg;
  · by_cases hy : y = x <;> simp_all +decide [ Lam.subst ];
    · exact Nat.le_succ_of_le ( Nat.le_add_left _ _ );
    · grind;
  · by_cases h : varCount x body' = 0 <;> by_cases h' : varCount x ih = 0 <;> simp_all +decide [ Lam.subst ];
    · rw [ subst_varCount_zero h, subst_varCount_zero h' ] ; simp +arith +decide [ redex_count ];
    · have h_subst_body' : body'.subst x arg = body' := by
        grind +suggestions
      simp_all +decide [ varCount ];
      have h_redex_count_app : ∀ (t u : Lam), redex_count (t.app u) = if let .lam _ body := t then 1 + redex_count body + redex_count u else redex_count t + redex_count u := by
        intro t u; cases t <;> rfl;
      grind +revert;
    · have h_subst_ih : ih.subst x arg = ih := by
        grind +suggestions;
      cases body' <;> simp_all +arith +decide [ redex_count ];
      · simp_all +arith +decide [ varCount ];
        simp_all +arith +decide [ Lam.subst ];
        cases arg <;> simp_all +arith +decide [ redex_count ];
      · rename_i a b ha hb;
        have h_subst_b : redex_count ((b.app ha).subst x arg) ≤ redex_count arg + redex_count (b.app ha) + 1 := by
          apply hb;
          exact le_trans ( by rw [ show varCount x ( ( b.app ha ).app ih ) = varCount x ( b.app ha ) + varCount x ih from rfl ] at hvc; linarith ) ( Nat.le_refl _ );
        cases h : ( b.app ha ).subst x arg <;> simp_all +arith +decide [ redex_count ];
        cases h' : ( b.app ha ).subst x arg <;> simp_all +arith +decide [ Lam.subst ];
      · cases eq_or_ne x ‹_› <;> simp_all +arith +decide [ varCount ];
        rename_i k hk hk₂;
        specialize hk x arg ; simp_all +arith +decide [ Lam.subst ];
        exact Nat.le_of_lt_succ ( by linarith! [ show redex_count ( ( lam ‹_› ( k.subst x arg ) ).app ih ) = 1 + redex_count ( lam ‹_› ( k.subst x arg ) ) + redex_count ih from rfl ] );
    · exact absurd hvc ( by erw [ show varCount x ( body'.app ih ) = varCount x body' + varCount x ih from rfl ] ; omega );
  · unfold varCount at hvc;
    rename_i k hk ih ; simp_all +decide [ Lam.subst ];
    split_ifs <;> simp_all +arith +decide [ redex_count ]

/-! ## Section 7: Affine Monotonicity — Analysis and Counterexample

With named variables and naive substitution, `branchComplexity` is NOT monotone
under β-reduction, even for affine terms.

**Counterexample**: The affine term
  `t = (λ0. λ3. (0 1)) (λ2. 2) 4`
reduces via the inner β-step to
  `u = (λ3. (λ2. 2) 1) 4`

Computation shows:
- `branchComplexity t = 2` (one redex: the inner application)
- `branchComplexity u = 3` (two redexes: the new `(λ2. 2) 1` created by
  substituting `λ2. 2` into function position, plus the outer application)

The issue is that naive substitution allows a lambda argument to land in
function position, creating a new redex without consuming a corresponding
old one at the same structural level.

This does NOT affect Theorems A and C, which are parameterized by an
explicit branching bound `B` and do not assume monotonicity. The
exponential bound `stateGrowth t d ≤ (B+1)^d` remains valid for ANY
uniform bound `B` on successor counts.

For a proper monotonicity theorem, one needs either:
1. Capture-avoiding substitution (de Bruijn indices), or
2. A refined invariant that accounts for "latent redexes" created by
   substitution. -/

-- Note: The `branchComplexity` monotonicity claim is FALSE for affine terms
-- with naive substitution. See the counterexample documented above.

/-! ## Section 8: Computable Functions for Experiments -/

/-- Compute the list of one-step β-reducts of a term. -/
def computeSuccessors : Lam → List Lam
  | .var _ => []
  | .app (.lam x body) arg =>
    [body.subst x arg] ++
    (computeSuccessors (Lam.lam x body) |>.map (·.app arg)) ++
    (computeSuccessors arg |>.map ((Lam.lam x body).app ·))
  | .app t u =>
    (computeSuccessors t |>.map (·.app u)) ++
    (computeSuccessors u |>.map (t.app ·))
  | .lam x body =>
    computeSuccessors body |>.map (Lam.lam x ·)

/-- Compute bounded reachable states up to depth `d` by BFS. -/
def computeBoundedStates (d : Nat) (t : Lam) : List Lam :=
  match d with
  | 0 => [t]
  | d + 1 =>
    let prev := computeBoundedStates d t
    let new := prev.flatMap computeSuccessors
    (prev ++ new).eraseDups

/-- Compute state growth by counting reachable states. -/
def computeStateGrowth (t : Lam) (d : Nat) : Nat :=
  (computeBoundedStates d t).length

/-- Check if a term is affine (computable version). -/
def checkAffine : Lam → Bool
  | .var _ => true
  | .app t u => checkAffine t && checkAffine u
  | .lam x body => decide (varCount x body ≤ 1) && checkAffine body

-- Example terms and computations
def id_term : Lam := .lam 0 (.var 0)
def simple_redex : Lam := .app (.lam 0 (.var 0)) (.lam 1 (.var 1))

#eval branchComplexity id_term         -- 1
#eval branchComplexity simple_redex    -- 2
#eval checkAffine id_term              -- true
#eval computeSuccessors simple_redex   -- [lam 1 (var 1)]
#eval computeBoundedStates 2 simple_redex |>.map repr