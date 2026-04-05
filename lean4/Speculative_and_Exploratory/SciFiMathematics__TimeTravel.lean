/-
# Mathematics of Science Fiction — Chapter 2: Time Travel and Fixed Points

Formalized proofs about fixed point theorems and their connection to
self-consistent time travel loops.
-/
import Mathlib

namespace SciFiMathematics.TimeTravel

/-! ## Section 2.2: Fixed Point Theorems -/

/-
A contraction mapping on a complete metric space has a unique fixed point.
    This is the mathematical foundation of the Novikov self-consistency
    principle: if the universe's evolution is a contraction, then exactly one
    self-consistent time loop exists.

    We state a version showing that the Banach fixed point gives a fixed point.
-/
theorem contraction_has_fixed_point {X : Type*} [MetricSpace X] [CompleteSpace X]
    [Nonempty X] (f : X → X) (q : ℝ) (hq : q ∈ Set.Ico (0 : ℝ) 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ q * dist x y) :
    ∃ x, f x = x := by
  -- By Banach's fixed point theorem, since $f$ is a contraction mapping on a complete metric space, it has a unique fixed point.
  have h_banach : ∃ x, Filter.Tendsto (fun n => (f^[n]) (Classical.arbitrary X)) Filter.atTop (nhds x) := by
    refine' cauchySeq_tendsto_of_complete _;
    -- We'll use induction to show that the distance between consecutive terms of the sequence is bounded by $q^n$ times the initial distance.
    have h_inductive_bound : ∀ n, dist (f^[n] (Classical.arbitrary X)) (f^[n+1] (Classical.arbitrary X)) ≤ q^n * dist (Classical.arbitrary X) (f (Classical.arbitrary X)) := by
      intro n; induction' n with n ih <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] ;
      exact le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ih hq.1 );
    fapply cauchySeq_of_le_geometric;
    exacts [ q, dist ( Classical.arbitrary X ) ( f ( Classical.arbitrary X ) ), hq.2, fun n => by simpa only [ mul_comm ] using h_inductive_bound n ];
  cases' h_banach with x hx
  have h_fixed : Filter.Tendsto (fun n => (f^[n+1]) (Classical.arbitrary X)) Filter.atTop (nhds (f x)) := by
    simp +decide only [Function.iterate_succ', Function.comp_apply];
    exact Filter.Tendsto.comp ( show Filter.Tendsto f ( nhds x ) ( nhds ( f x ) ) from Metric.tendsto_nhds_nhds.2 fun ε εpos => by exact ⟨ ε, εpos, by intro y hy; exact lt_of_le_of_lt ( hf _ _ ) ( by nlinarith [ hq.1, hq.2 ] ) ⟩ ) hx;
  exact ⟨ x, tendsto_nhds_unique h_fixed ( hx.comp ( Filter.tendsto_add_atTop_nat 1 ) ) ⟩

/-
The fixed point of a contraction mapping is unique.
    In the time travel interpretation: there is exactly one self-consistent
    timeline — no ambiguity, no paradox.
-/
theorem contraction_fixed_point_unique {X : Type*} [MetricSpace X]
    (f : X → X) (q : ℝ) (hq : q < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ q * dist x y)
    (x₁ x₂ : X) (h₁ : f x₁ = x₁) (h₂ : f x₂ = x₂) :
    x₁ = x₂ := by
  contrapose! hq with hq
  generalize hq : dist x₁ x₂ = d at *;
  have := hf x₁ x₂; simp_all +decide [ dist_comm ] ;
  nlinarith [ show 0 < d by exact hq ▸ dist_pos.mpr ‹_› ]

/-! ## The Knaster-Tarski Theorem (Order-Theoretic Fixed Points)

If timelines can be ordered and time travel preserves this ordering,
then the set of self-consistent timelines is rich and structured. -/

/-
A monotone function on a complete lattice has a fixed point.
    (This is a consequence of the Knaster-Tarski theorem.)
-/
theorem monotone_has_fixed_point {L : Type*} [CompleteLattice L]
    (f : L → L) (hf : Monotone f) :
    ∃ x, f x = x := by
  -- By the Knaster-Tarski theorem, since $f$ is monotone, it has a least fixed point.
  have h_least_fixed_point : ∃ x, IsLeast {x | f x ≤ x} x := by
    refine' ⟨ _, ⟨ _, fun x hx => _ ⟩ ⟩;
    exact ⨅ x : { x // f x ≤ x }, x.val;
    · simp +zetaDelta at *;
      exact fun x hx => le_trans ( hf <| iInf_le _ ⟨ x, hx ⟩ ) hx;
    · exact iInf_le_of_le ⟨ x, hx ⟩ le_rfl;
  obtain ⟨ x, hx ⟩ := h_least_fixed_point;
  exact ⟨ x, le_antisymm hx.1 ( hx.2 ( hf hx.1 ) ) ⟩

/-! ## Iterated Function Systems and Temporal Loops

A time loop that repeats n times is mathematically equivalent to computing
the n-th iterate of a function. -/

/-
If f has a unique fixed point x*, then the iterates f^n(y) converge to x*
    for any starting point y (in a contraction mapping setting).
    Here we prove the simpler statement: the iterate of f at the fixed point
    is still the fixed point.
-/
theorem iterate_at_fixed_point {X : Type*} (f : X → X)
    (x : X) (hx : f x = x) (n : ℕ) :
    f^[n] x = x := by
  exact Function.iterate_fixed hx n

/-! ## The Bootstrap Paradox: Self-Referential Objects

The bootstrap paradox creates an object that is its own cause.
Mathematically, this is simply a fixed point. -/

/-
If f(x) = x (x is a fixed point), then the "origin" of x is x itself.
    This is the mathematical content of the bootstrap paradox: the object
    x exists self-consistently without requiring an external cause.
-/
theorem bootstrap_self_consistent {X : Type*} (f : X → X)
    (x : X) (hfx : f x = x) :
    f (f x) = f x := by
  grind +suggestions

end SciFiMathematics.TimeTravel