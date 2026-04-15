/-! # CatalogBuild.Speculative.IdempotentCollapse.FixedPointCollapse

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 5
-/

import Mathlib

noncomputable section

theorem limit_of_iteration_idempotent {α : Type*} [TopologicalSpace α] [T2Space α]
    (f : α → α) (L : α → α) (hf_cont : Continuous f)
    (hconv : ∀ x, Tendsto (fun n => f^[n] x) atTop (nhds (L x))) :
    ∀ x, L (L x) = L x := by
  intro x;
  refine' tendsto_nhds_unique ( hconv _ ) _;
  have := hconv x;
  -- By continuity of $f$, we have $f(L(x)) = L(x)$.
  have h_fixed : f (L x) = L x := by
    exact tendsto_nhds_unique ( by erw [ ← Filter.tendsto_add_atTop_iff_nat 1 ] ; simpa only [ Function.iterate_succ_apply' ] using hf_cont.continuousAt.tendsto.comp this ) ( hconv x );
  exact tendsto_nhds_of_eventually_eq ( Filter.eventually_atTop.mpr ⟨ 0, fun n hn => by induction hn <;> simp_all +decide [ Function.iterate_fixed ] ⟩ )

/-! ### Fixed Points of Monotone Maps -/

/-- On any type, a monotone idempotent maps everything to fixed points. -/

theorem monotone_idempotent_determined_by_fixed {α : Type*} [PartialOrder α]
    (f : α → α) (hf_mono : Monotone f) (hf_idem : ∀ x, f (f x) = f x) :
    ∀ x, f x ∈ {y | f y = y} := by
  intro x; simp; exact hf_idem x

/-
PROBLEM
A monotone map on a finite set, iterated enough times, becomes idempotent.

PROVIDED SOLUTION
Use k = n. On Fin n, a monotone map f satisfies f^n ∘ f^n = f^n because the sequence x, f(x), f²(x), ... is eventually constant (monotone on a finite total order). Actually just use k = n and argue by finiteness.
-/

theorem monotone_iterate_stabilizes {n : ℕ} (f : Fin n → Fin n)
    (hf_mono : Monotone f) :
    ∃ k, ∀ x, f^[k] (f^[k] x) = f^[k] x := by
  by_contra h;
  -- By definition of negation, if $\neg P$ holds, then $P$ does not hold.
  push_neg at h;
  obtain ⟨ k, hk ⟩ := h 0 ; simp_all +decide [ Function.iterate_fixed ]

/-! ### Kleene's Fixed-Point Theorem -/

/-
PROBLEM
In a complete lattice, any monotone function has a fixed point.

PROVIDED SOLUTION
Use Knaster-Tarski: sSup {x | x ≤ f x} is a fixed point. Or use OrderHom.lfp or similar from Mathlib.
-/

theorem kleene_fixed_point_exists {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) :
    ∃ x, f x = x := by
  -- By Knaster-Tarski theorem, there exists a fixed point of f.
  have h_knaster_tarski : ∀ (f : α → α), Monotone f → ∃ x, f x = x := by
    intro f hf
    use sSup {x : α | x ≤ f x};
    refine' le_antisymm _ _;
    · refine' le_sSup _;
      refine' hf _;
      exact sSup_le fun x hx => hx.trans ( hf ( le_sSup hx ) );
    · exact sSup_le fun x hx => hx.trans ( hf ( le_sSup hx ) );
  exact h_knaster_tarski f hf

/-! ### Banach Contraction as Collapse -/

/-
PROBLEM
The unique fixed point of a contraction is the collapse target.

PROVIDED SOLUTION
This is Banach's contraction mapping theorem. Use ContractingWith and its isFixedPt_fixedPoint. Or construct directly using the Banach fixed point theorem from Mathlib.
-/

theorem contraction_total_collapse {α : Type*} [MetricSpace α] [CompleteSpace α]
    [Nonempty α] (f : α → α)
    (hf : ∃ k : ℝ, 0 ≤ k ∧ k < 1 ∧ ∀ x y, dist (f x) (f y) ≤ k * dist x y) :
    ∃! p, f p = p := by
  obtain ⟨ k, hk₀, hk₁, hk₂ ⟩ := hf
  have h_converge : ∀ x₀ : α, ∃ p : α, Filter.Tendsto (fun n => f^[n] x₀) Filter.atTop (nhds p) := by
    intro x₀
    have h_seq : ∀ n, dist (f^[n] x₀) (f^[n+1] x₀) ≤ k^n * dist x₀ (f x₀) := by
      intro n
      induction' n with n ih
      · simp [Function.iterate_succ_apply']
      generalize_proofs at *; (
      simpa only [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] using le_trans ( hk₂ _ _ ) ( mul_le_mul_of_nonneg_left ih hk₀ ))
    generalize_proofs at *; (
    refine' cauchySeq_tendsto_of_complete _;
    fapply cauchySeq_of_le_geometric;
    exacts [ k, dist x₀ ( f x₀ ), hk₁, fun n => by simpa only [ mul_comm ] using h_seq n ])
  generalize_proofs at *; (
  -- By the properties of the contraction mapping, the limit of the sequence is a fixed point.
  obtain ⟨p, hp⟩ : ∃ p : α, f p = p := by
    obtain ⟨ p, hp ⟩ := h_converge ( Classical.arbitrary α ) ; use p; have := hp; exact (by
    exact tendsto_nhds_unique ( by erw [ ← Filter.tendsto_add_atTop_iff_nat 1 ] ; simpa only [ Function.iterate_succ_apply' ] using Filter.Tendsto.comp ( show Filter.Tendsto f ( nhds p ) ( nhds ( f p ) ) from by exact Continuous.tendsto ( show Continuous f from by exact continuous_iff_continuousAt.mpr fun x => by exact tendsto_iff_dist_tendsto_zero.mpr <| squeeze_zero ( fun _ => dist_nonneg ) ( fun _ => hk₂ _ _ ) <| by simpa using tendsto_const_nhds.mul ( tendsto_iff_dist_tendsto_zero.mp <| Filter.tendsto_id ) ) _ ) this ) this;);
  generalize_proofs at *; (
  refine' ⟨ p, hp, fun q hq => _ ⟩
  generalize_proofs at *; (
  exact dist_le_zero.mp ( by have := hk₂ q p; norm_num [ hp, hq ] at this; nlinarith ) ▸ rfl;)))

/-! ### Convergence Rate of Collapse -/

/-
PROBLEM
For an idempotent, convergence is instantaneous (1 step).

PROVIDED SOLUTION
Induction on hn. Base: n=1, trivial. Step: f^[n+1] x = f(f^[n] x) = f(f x) by IH = f x by hf.
-/

end
