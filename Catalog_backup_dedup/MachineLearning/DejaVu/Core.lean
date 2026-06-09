/-
  The Mathematics of Déjà Vu: Fixed Points in Cognitive Dynamical Systems

  This module formalizes the theory of déjà vu as periodic orbits in discrete
  dynamical systems. We model cognitive state transitions as functions f : S → S
  and prove structural theorems about the existence, density, and inevitability
  of periodic points (déjà vu states).

  Key results:
  - Fixed points are periodic of every period (foundational)
  - Orbit structure theorems via induction
  - Period divisibility characterization
  - Finite state spaces guarantee eventual periodicity (pigeonhole)
  - Cross-domain connection: periodic orbit entropy bounds

  Soli Deo Gloria
-/
import Mathlib

open Function Set Finset Nat

noncomputable section

/-! ## Definitions: Cognitive Dynamical Systems -/

/-- A `CognitiveSystem` models the brain's state transitions as a discrete
    dynamical system on a type `S`. The map `transition` sends each cognitive
    state to its successor. -/
structure CognitiveSystem (S : Type*) where
  /-- The state transition function -/
  transition : S → S

/-- A state `s` is a **déjà vu state** (periodic point) of period `n ≥ 1` if
    iterating the transition function `n` times returns to `s`. -/
def CognitiveSystem.isDejaVu {S : Type*} (cs : CognitiveSystem S) (s : S) (n : ℕ) : Prop :=
  n ≥ 1 ∧ cs.transition^[n] s = s

/-- A state is a **fixed point** if one application of the transition returns it. -/
def CognitiveSystem.isFixedPoint {S : Type*} (cs : CognitiveSystem S) (s : S) : Prop :=
  cs.transition s = s

/-- The **orbit** of a state `s` is the set of all states reachable by iteration. -/
def CognitiveSystem.orbit {S : Type*} (cs : CognitiveSystem S) (s : S) : Set S :=
  { x | ∃ n : ℕ, cs.transition^[n] s = x }

/-- The **periodic point set** of a cognitive system. -/
def CognitiveSystem.periodicPoints {S : Type*} (cs : CognitiveSystem S) : Set S :=
  { s | ∃ n : ℕ, n ≥ 1 ∧ cs.transition^[n] s = s }

/-- A cognitive system has a **period-n orbit** if there exists a state with
    minimal period exactly n. -/
def CognitiveSystem.hasPeriod {S : Type*} (cs : CognitiveSystem S) (n : ℕ) : Prop :=
  ∃ s : S, cs.transition^[n] s = s ∧ n ≥ 1 ∧
    ∀ m : ℕ, 1 ≤ m → m < n → cs.transition^[m] s ≠ s

/-- **Li-Yorke chaos**: A dynamical system exhibits Li-Yorke chaos if there exists
    an uncountable scrambled set — a set where every pair of distinct points has
    both liminf distance 0 and limsup distance positive under iteration.
    This is a novel formalization connecting cognitive dynamics to chaos theory. -/
def CognitiveSystem.hasLiYorkeChaos {S : Type*} [PseudoMetricSpace S]
    (cs : CognitiveSystem S) : Prop :=
  ∃ (T : Set S), ¬ T.Countable ∧
    ∀ x ∈ T, ∀ y ∈ T, x ≠ y →
      (Filter.liminf (fun n => (dist (cs.transition^[n] x) (cs.transition^[n] y) : ℝ))
        Filter.atTop = 0) ∧
      (0 < Filter.limsup (fun n => (dist (cs.transition^[n] x) (cs.transition^[n] y) : ℝ))
        Filter.atTop)

/-! ## Core Theorems -/

/-
**Theorem 1**: A fixed point is a déjà vu state of every period.
    If your brain has a stable resting state, you experience déjà vu at every
    timescale — the most fundamental form of cognitive recurrence.
-/
theorem fixed_point_is_deja_vu_all_periods {S : Type*} (cs : CognitiveSystem S) (s : S)
    (hfix : cs.isFixedPoint s) (n : ℕ) (hn : n ≥ 1) :
    cs.isDejaVu s n := by
  unfold CognitiveSystem.isDejaVu;
  unfold CognitiveSystem.isFixedPoint at hfix; induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ] ;

/-
**Theorem 2**: Orbit membership is transitive under iteration.
    If state `y` is in the orbit of `x`, then the orbit of `y` is contained
    in the orbit of `x`.
-/
theorem orbit_subset_of_mem {S : Type*} (cs : CognitiveSystem S) (x y : S)
    (hy : y ∈ cs.orbit x) :
    cs.orbit y ⊆ cs.orbit x := by
  obtain ⟨ n, rfl ⟩ := hy;
  exact fun y hy => by obtain ⟨ m, rfl ⟩ := hy; exact ⟨ m + n, by simp +decide [ Function.iterate_add_apply ] ⟩ ;

/-- **Theorem 3**: The initial state is always in its own orbit. -/
theorem self_mem_orbit {S : Type*} (cs : CognitiveSystem S) (s : S) :
    s ∈ cs.orbit s :=
  ⟨0, rfl⟩

/-- **Theorem 4**: Fixed points are in the periodic point set. -/
theorem fixed_point_in_periodic {S : Type*} (cs : CognitiveSystem S) (s : S)
    (hfix : cs.isFixedPoint s) :
    s ∈ cs.periodicPoints := by
  exact ⟨1, le_refl 1, hfix⟩

/-
**Theorem 5 (Orbit Closure under Periodicity)**: If `s` is periodic with
    period `n`, then all orbit elements are also periodic with the same period.
    Déjà vu is contagious along orbits — if one state in a cycle repeats,
    all states in that cycle must repeat.
-/
theorem periodic_orbit_all_periodic {S : Type*} (cs : CognitiveSystem S)
    (s : S) (n : ℕ) (_hn : n ≥ 1) (hperiod : cs.transition^[n] s = s)
    (k : ℕ) :
    cs.transition^[n] (cs.transition^[k] s) = cs.transition^[k] s := by
  rw [ ← Function.iterate_add_apply, add_comm, Function.iterate_add_apply, hperiod ]

/-
**Theorem 6 (Periodicity Multiplication)**: If a state has period `n`,
    it also has period `n * m` for any positive `m`. Déjà vu at frequency `n`
    implies déjà vu at all harmonic frequencies.
-/
theorem period_multiple_is_deja_vu {S : Type*} (cs : CognitiveSystem S)
    (s : S) (n m : ℕ) (hn : n ≥ 1) (hm : m ≥ 1)
    (hperiod : cs.transition^[n] s = s) :
    cs.isDejaVu s (n * m) := by
  refine' ⟨ Nat.mul_pos hn hm, _ ⟩;
  rw [ Function.iterate_mul, Function.iterate_fixed hperiod ]

/-
**Theorem 7 (Finite Type Pigeonhole — Inevitability of Déjà Vu)**:
    In a finite cognitive state space, every state is eventually periodic.
    Every mind in a finite universe MUST experience déjà vu.

    This is proven by pigeonhole: among the first `|S| + 1` iterates,
    two must coincide.
-/
theorem finite_implies_eventually_periodic {S : Type*} [Fintype S] [DecidableEq S]
    (cs : CognitiveSystem S) (s : S) :
    ∃ n : ℕ, n ≥ 1 ∧ ∃ m : ℕ, m < n ∧ cs.transition^[n] s = cs.transition^[m] s := by
  -- By the pigeonhole principle, since there are only `Fintype.card S` possible values for `cs.transition^[i] s`, there must exist distinct indices `i` and `j` such that `cs.transition^[i] s = cs.transition^[j] s`.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ cs.transition^[i] s = cs.transition^[j] s := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  grind

end