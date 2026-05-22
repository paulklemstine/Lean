/-
# Deep EML Universal Approximation Theorem

This file combines the compositional error propagation theory with
quantitative approximation hypotheses to prove that deep compositions
of Lipschitz layers can be uniformly approximated on compact spaces.

## Main results

* `HasApproxRate` — Abstract quantitative approximation hypothesis.
* `HasApproxRate.vector_approx` — Coordinatewise extension to vector-valued maps.
* `deep_uniform_approx` — Deep compositional universal approximation theorem.
-/
import Mathlib
import EMLDeep.UniformApprox
import EMLDeep.DeepComposition

noncomputable section

open NNReal

/-! ## Quantitative approximation rate -/

/-- A set `A` of continuous functions has quantitative approximation rate if
every continuous function on `K` can be approximated within any `ε > 0`
by some element of `A`. This is the abstract density hypothesis. -/
def HasApproxRate {K : Type*} [TopologicalSpace K] [PseudoMetricSpace K]
    (A : Set C(K, ℝ)) : Prop :=
  ∀ (f : C(K, ℝ)) {ε : ℝ}, 0 < ε →
    ∃ g ∈ A, ∀ x, dist (f x) (g x) ≤ ε

/-! ## Coordinatewise vector-valued approximation -/

/-
**Coordinatewise density upgrade.**
If a function class `A` is quantitatively dense in `C(K, ℝ)`, then
for any continuous `F : K → Fin m → ℝ`, each coordinate can be
approximated by an element of `A`, yielding a vector-valued approximant
within `ε` in the sup metric on `Fin m → ℝ`.
-/
theorem HasApproxRate.vector_approx
    {K : Type*} [TopologicalSpace K] [CompactSpace K] [PseudoMetricSpace K]
    (A : Set C(K, ℝ))
    (hDense : HasApproxRate A)
    {m : ℕ} (_hm : 0 < m)
    (F : K → Fin m → ℝ)
    (hF : ∀ i : Fin m, Continuous (fun x => F x i))
    {ε : ℝ} (hε : 0 < ε) :
    ∃ G : Fin m → C(K, ℝ),
      (∀ i, G i ∈ A) ∧
      UniformApproxOn Set.univ F (fun x i => G i x) ε := by
  unfold UniformApproxOn;
  norm_num [ dist_pi_le_iff, hε ];
  choose G hG using fun i => hDense ( ContinuousMap.mk ( fun x => F x i ) ( hF i ) ) hε;
  exact ⟨ G, fun i => hG i |>.1, fun x => by rw [ dist_pi_le_iff hε.le ] ; intro i; simpa using hG i |>.2 x ⟩

/-! ## Deep compositional universal approximation -/

/-
**Deep compositional universal approximation theorem.**
Given `n` Lipschitz continuous layers `Φ 0, ..., Φ (n-1)` on a metric space `α`,
if each layer can be uniformly approximated on compact sets,
then the deep composition `Φ (n-1) ∘ ... ∘ Φ 0` can be uniformly approximated
on any compact set `K` within any tolerance `ε > 0`.

This is the core result connecting:
1. Per-layer approximation (e.g., from Stone–Weierstrass/EML density)
2. Lipschitz error propagation through composition
3. The telescoping error formula
-/
theorem deep_uniform_approx {α : Type*} [PseudoMetricSpace α]
    (K : Set α)
    (n : ℕ)
    (Φ : ℕ → α → α)
    (L : ℕ → NNReal)
    (hLip : ∀ i, LipschitzWith (L i) (Φ i))
    (hApproxLayer : ∀ i, ∀ δ > 0, ∃ Ψ : α → α,
      ∀ x, dist (Φ i x) (Ψ x) ≤ δ)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ Ψ : ℕ → α → α,
      UniformApproxOn K (composeN Φ n) (composeN Ψ n) ε := by
  -- Choose δ such that deepError (fun _ => δ) (fun i => L i) n ≤ ε.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, deepError (fun _ => δ) (fun i => L i) n ≤ ε := by
    have h_cont : Continuous (fun δ : ℝ => deepError (fun _ => δ) (fun i => L i) n) := by
      induction' n with n ih <;> simp_all +decide [ deepError ];
      · exact continuous_const;
      · exact Continuous.add continuous_id ( Continuous.mul continuous_const ih );
    have h_cont : Filter.Tendsto (fun δ : ℝ => deepError (fun _ => δ) (fun i => L i) n) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
      convert h_cont.continuousWithinAt.tendsto using 2;
      exact Eq.symm ( Nat.recOn n rfl fun n ih => by simp +decide [ ih, deepError ] );
    have := h_cont.eventually ( ge_mem_nhds hε ) ; have := this.and self_mem_nhdsWithin; obtain ⟨ δ, hδ₁, hδ₂ ⟩ := this.exists; exact ⟨ δ, hδ₂, hδ₁ ⟩ ;
  choose Ψ hΨ using fun i => hApproxLayer i δ hδ_pos;
  refine' ⟨ Ψ, _ ⟩;
  exact UniformApproxOn.mono ( deep_approx_recursive K Φ Ψ ( fun _ => δ ) L hLip ( fun i x => hΨ i x ) ( fun _ => hδ_pos.le ) n ) hδ

/-
**Deep approximation with explicit per-layer error allocation.**
Given Lipschitz layers, we can choose per-layer tolerances `δ i` such that
the total telescoping error is within `ε`. The allocation uses
`δ i = ε / (n * Π_{j>i} L j)` (simplified to uniform allocation).
-/
theorem deep_uniform_approx_allocated {α : Type*} [PseudoMetricSpace α]
    (K : Set α)
    (n : ℕ) (_hn : 0 < n)
    (Φ : ℕ → α → α)
    (L : ℕ → NNReal)
    (hLip : ∀ i, LipschitzWith (L i) (Φ i))
    (hApproxLayer : ∀ i, ∀ δ > 0, ∃ Ψ : α → α,
      ∀ x, dist (Φ i x) (Ψ x) ≤ δ)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ (Ψ : ℕ → α → α) (δ : ℕ → ℝ),
      (∀ i, 0 < δ i) ∧
      (∀ i x, dist (Φ i x) (Ψ i x) ≤ δ i) ∧
      deepError δ (fun i => (L i : ℝ)) n ≤ ε ∧
      UniformApproxOn K (composeN Φ n) (composeN Ψ n) ε := by
  obtain ⟨δ, hδ_pos, hδ_le⟩ : ∃ δ : ℝ, 0 < δ ∧ deepError (fun _ => δ) (fun i => L i) n ≤ ε := by
    have h_cont : Continuous (fun δ : ℝ => deepError (fun _ => δ) (fun i => L i) n) := by
      refine' Nat.recOn n _ _ <;> simp_all +decide [ deepError ];
      · exact continuous_const;
      · exact fun n hn => continuous_id.add ( continuous_const.mul hn );
    have h_cont : Filter.Tendsto (fun δ : ℝ => deepError (fun _ => δ) (fun i => L i) n) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
      convert h_cont.continuousWithinAt.tendsto using 2;
      exact Eq.symm ( Nat.recOn n ( by rfl ) fun n ih => by simp +decide [ ih, deepError ] );
    have := h_cont.eventually ( ge_mem_nhds hε ) ; have := this.and self_mem_nhdsWithin; obtain ⟨ δ, hδ₁, hδ₂ ⟩ := this.exists; exact ⟨ δ, hδ₂, hδ₁ ⟩ ;
  choose Ψ hΨ using fun i => hApproxLayer i δ hδ_pos;
  refine' ⟨ Ψ, fun _ => δ, fun _ => hδ_pos, hΨ, hδ_le, _ ⟩;
  exact UniformApproxOn.mono ( deep_approx_recursive K Φ Ψ ( fun _ => δ ) L hLip ( fun i x => hΨ i x ) ( fun _ => hδ_pos.le ) n ) hδ_le

/-! ## Application: EML subalgebra deep approximation -/

/-
The EML subalgebra on a compact Hausdorff space has the quantitative
approximation property: any continuous function can be uniformly
approximated within any `ε > 0`. This follows from Stone–Weierstrass
and compactness.
-/
theorem eml_has_approx_rate
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    [PseudoMetricSpace X]
    (A : Subalgebra ℝ C(X, ℝ))
    (hA : A.topologicalClosure = ⊤) :
    HasApproxRate (A : Set C(X, ℝ)) := by
  intro f ε hε;
  have h_closure : f ∈ A.topologicalClosure := by
    aesop;
  rcases Metric.mem_closure_iff.1 h_closure ε hε with ⟨ g, hgA, hgε ⟩;
  exact ⟨ g, hgA, fun x => le_trans ( by simpa using ContinuousMap.norm_coe_le_norm ( f - g ) x ) ( le_of_lt ( by simpa [ dist_eq_norm ] using hgε ) ) ⟩

end