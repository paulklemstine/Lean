/-
  # Configuration-Based Clause Space for Resolution

  This file introduces a **configuration-based semantics** for resolution proofs,
  treating proofs as sequential trajectories through memory states.

  ## Key Theorems
  - `configRefutation_sound`: configuration refutations certify unsatisfiability
  - `bottleneck_space_lower_bound`: graph separation implies space lower bounds
  - `allTraceClauses_card_bound`: distinct clause count from space
  - `boundedReachable_mono`: monotonicity of reachability
-/
import Mathlib

namespace ConfigSpace

/-! ## Literals, Clauses, CNFs -/

inductive Lit (ν : Type)
  | pos : ν → Lit ν
  | neg : ν → Lit ν
  deriving DecidableEq

namespace Lit
def litEval {ν : Type} (τ : ν → Bool) : Lit ν → Bool
  | pos x => τ x
  | neg x => !(τ x)
end Lit

abbrev Clause (ν : Type) [DecidableEq ν] := Finset (Lit ν)
abbrev CNF (ν : Type) [DecidableEq ν] := Finset (Clause ν)

def Clause.Satisfied {ν : Type} [DecidableEq ν] (τ : ν → Bool) (C : Clause ν) : Prop :=
  ∃ l ∈ C, Lit.litEval τ l = true

theorem Clause.not_satisfied_empty {ν : Type} [DecidableEq ν] (τ : ν → Bool) :
    ¬Clause.Satisfied τ (∅ : Clause ν) := by
  intro ⟨_, hl, _⟩; simp at hl

def CNF.Satisfied {ν : Type} [DecidableEq ν] (τ : ν → Bool) (F : CNF ν) : Prop :=
  ∀ C ∈ F, Clause.Satisfied τ C

def CNF.Unsatisfiable {ν : Type} [DecidableEq ν] (F : CNF ν) : Prop :=
  ∀ τ : ν → Bool, ¬CNF.Satisfied τ F

/-! ## Resolution step soundness -/

theorem resolution_step_sound {ν : Type} [DecidableEq ν]
    (τ : ν → Bool) (x : ν) (C D : Clause ν) :
    Clause.Satisfied τ (insert (Lit.pos x) C) →
    Clause.Satisfied τ (insert (Lit.neg x) D) →
    Clause.Satisfied τ (C ∪ D) := by
  grind +locals

/-! ## Proof Configuration -/

structure ProofConfiguration (ν : Type) [DecidableEq ν] where
  liveClauses : Finset (Clause ν)

instance {ν : Type} [DecidableEq ν] : DecidableEq (ProofConfiguration ν) := by
  intro a b
  cases a with | mk la =>
  cases b with | mk lb =>
  by_cases h : la = lb
  · exact isTrue (by subst h; rfl)
  · exact isFalse (by intro hab; exact h (ProofConfiguration.mk.inj hab))

def initialConfig {ν : Type} [DecidableEq ν] : ProofConfiguration ν := ⟨∅⟩

def hasContradiction {ν : Type} [DecidableEq ν] (C : ProofConfiguration ν) : Prop :=
  (∅ : Clause ν) ∈ C.liveClauses

def configSize {ν : Type} [DecidableEq ν] (C : ProofConfiguration ν) : ℕ :=
  C.liveClauses.card

/-! ## Configuration Steps -/

inductive ConfigStep {ν : Type} [DecidableEq ν] (F : CNF ν) :
    ProofConfiguration ν → ProofConfiguration ν → Prop
  | axiom_download (cfg : ProofConfiguration ν) (C : Clause ν) (hC : C ∈ F) :
      ConfigStep F cfg ⟨insert C cfg.liveClauses⟩
  | resolve_step (cfg : ProofConfiguration ν) (x : ν) (C D : Clause ν)
      (hC : insert (Lit.pos x) C ∈ cfg.liveClauses)
      (hD : insert (Lit.neg x) D ∈ cfg.liveClauses) :
      ConfigStep F cfg ⟨insert (C ∪ D) cfg.liveClauses⟩
  | erase_step (cfg : ProofConfiguration ν) (C : Clause ν)
      (hC : C ∈ cfg.liveClauses) :
      ConfigStep F cfg ⟨cfg.liveClauses.erase C⟩

/-! ## Configuration Traces -/

inductive IsConfigurationTrace {ν : Type} [DecidableEq ν] (F : CNF ν) :
    List (ProofConfiguration ν) → Prop
  | single (cfg : ProofConfiguration ν) :
      IsConfigurationTrace F [cfg]
  | cons_step (cfg₁ cfg₂ : ProofConfiguration ν) (rest : List (ProofConfiguration ν))
      (hstep : ConfigStep F cfg₁ cfg₂)
      (htail : IsConfigurationTrace F (cfg₂ :: rest)) :
      IsConfigurationTrace F (cfg₁ :: cfg₂ :: rest)

def IsConfigurationRefutation {ν : Type} [DecidableEq ν] (F : CNF ν)
    (π : List (ProofConfiguration ν)) : Prop :=
  IsConfigurationTrace F π ∧
  π.head? = some initialConfig ∧
  ∃ cfg ∈ π, hasContradiction cfg

def configurationSpace {ν : Type} [DecidableEq ν]
    (π : List (ProofConfiguration ν)) : ℕ :=
  π.foldl (fun m C => max m (configSize C)) 0

/-! ## Fold-max lemmas -/

private theorem foldl_max_ge_init {ν : Type} [DecidableEq ν]
    (π : List (ProofConfiguration ν)) (init : ℕ) :
    init ≤ π.foldl (fun m C => max m (configSize C)) init := by
  induction π generalizing init with
  | nil => simp
  | cons hd tl ih =>
    simp only [List.foldl_cons]
    exact le_trans (le_max_left _ _) (ih _)

private theorem foldl_max_ge_elem {ν : Type} [DecidableEq ν]
    (π : List (ProofConfiguration ν)) (cfg : ProofConfiguration ν)
    (hmem : cfg ∈ π) (init : ℕ) :
    configSize cfg ≤ π.foldl (fun m C => max m (configSize C)) init := by
  induction π generalizing init with
  | nil => simp at hmem
  | cons hd tl ih =>
    simp only [List.foldl_cons]
    rcases List.mem_cons.mp hmem with rfl | hmem
    · exact le_trans (le_max_right _ _) (foldl_max_ge_init _ _)
    · exact ih hmem _

theorem configSize_le_space {ν : Type} [DecidableEq ν]
    (π : List (ProofConfiguration ν)) (cfg : ProofConfiguration ν)
    (hmem : cfg ∈ π) :
    configSize cfg ≤ configurationSpace π :=
  foldl_max_ge_elem π cfg hmem 0

/-! ## Theorem 1: Soundness -/

theorem configStep_preserves {ν : Type} [DecidableEq ν]
    (F : CNF ν) (τ : ν → Bool) (hF : CNF.Satisfied τ F)
    (cfg₁ cfg₂ : ProofConfiguration ν)
    (hstep : ConfigStep F cfg₁ cfg₂)
    (hsat₁ : ∀ E ∈ cfg₁.liveClauses, Clause.Satisfied τ E) :
    ∀ E ∈ cfg₂.liveClauses, Clause.Satisfied τ E := by
  induction hstep with
  | axiom_download cl hcl =>
    exact fun E hE => by
      rw [Finset.mem_insert] at hE
      cases hE with
      | inl h => subst h; exact hF E hcl
      | inr h => exact hsat₁ E h
  | resolve_step x cl₁ cl₂ hcl₁ hcl₂ =>
    exact fun E hE => by
      rw [Finset.mem_insert] at hE
      cases hE with
      | inl h => subst h; exact resolution_step_sound τ x cl₁ cl₂ (hsat₁ _ hcl₁) (hsat₁ _ hcl₂)
      | inr h => exact hsat₁ E h
  | erase_step cl hcl =>
    exact fun E hE => hsat₁ E (Finset.mem_of_mem_erase hE)

/-- Along a trace, if the head's clauses are satisfied, all clauses are satisfied. -/
theorem trace_all_satisfied {ν : Type} [DecidableEq ν]
    (F : CNF ν) (τ : ν → Bool) (hF : CNF.Satisfied τ F)
    (π : List (ProofConfiguration ν))
    (htrace : IsConfigurationTrace F π)
    (hsat_head : ∀ cfg₀, π.head? = some cfg₀ →
                   ∀ C ∈ cfg₀.liveClauses, Clause.Satisfied τ C) :
    ∀ cfg ∈ π, ∀ C ∈ cfg.liveClauses, Clause.Satisfied τ C := by
  induction htrace with
  | single cfg =>
    intro cfg' hcfg'
    rw [List.mem_singleton.mp hcfg']
    exact hsat_head cfg (by simp)
  | cons_step cfg₁ cfg₂ rest hstep _htail ih =>
    intro cfg' hcfg'
    cases List.mem_cons.mp hcfg' with
    | inl h => subst h; exact hsat_head cfg' (by simp)
    | inr hrest =>
      apply ih
      · intro cfg₀ h
        simp at h; subst h
        exact configStep_preserves F τ hF cfg₁ cfg₂ hstep
          (hsat_head cfg₁ (by simp))
      · exact hrest

/-- **Theorem 1: Soundness of configuration refutations.**
    If a configuration refutation of F exists, then F is unsatisfiable. -/
theorem configRefutation_sound {ν : Type} [DecidableEq ν]
    (F : CNF ν) (π : List (ProofConfiguration ν))
    (href : IsConfigurationRefutation F π) :
    CNF.Unsatisfiable F := by
  intro τ hF
  obtain ⟨htrace, hstart, cfg, hcfg, hcontra⟩ := href
  have hall := trace_all_satisfied F τ hF π htrace (fun cfg₀ h => by
    rw [hstart] at h; simp at h; subst h
    intro C hC; simp [initialConfig] at hC)
  exact Clause.not_satisfied_empty τ (hall cfg hcfg ∅ hcontra)

/-! ## Graph-Theoretic Reachability -/

inductive ReachableWithinBound {ν : Type} [DecidableEq ν] (F : CNF ν) (s : ℕ) :
    ProofConfiguration ν → Prop
  | init : ReachableWithinBound F s initialConfig
  | step (cfg₁ cfg₂ : ProofConfiguration ν)
      (hreach : ReachableWithinBound F s cfg₁)
      (hstep : ConfigStep F cfg₁ cfg₂)
      (hbound : configSize cfg₂ ≤ s) :
      ReachableWithinBound F s cfg₂

theorem boundedReachable_mono {ν : Type} [DecidableEq ν]
    (F : CNF ν) {s t : ℕ} (hst : s ≤ t)
    (cfg : ProofConfiguration ν)
    (h : ReachableWithinBound F s cfg) :
    ReachableWithinBound F t cfg := by
  induction h with
  | init => exact ReachableWithinBound.init
  | step cfg₁ cfg₂ _ hstep hbound ih =>
    exact ReachableWithinBound.step cfg₁ cfg₂ ih hstep (le_trans hbound hst)

@[simp]
theorem configSize_initial {ν : Type} [DecidableEq ν] :
    configSize (initialConfig : ProofConfiguration ν) = 0 := by
  simp [configSize, initialConfig]

/-! ## Theorem 2: Bottleneck Space Lower Bound -/

theorem trace_bounded_reachable {ν : Type} [DecidableEq ν]
    (F : CNF ν) (s : ℕ)
    (π : List (ProofConfiguration ν))
    (htrace : IsConfigurationTrace F π)
    (hreach_head : ∀ cfg₀, π.head? = some cfg₀ → ReachableWithinBound F s cfg₀)
    (hbound : ∀ cfg ∈ π, configSize cfg ≤ s) :
    ∀ cfg ∈ π, ReachableWithinBound F s cfg := by
  induction htrace with
  | single cfg =>
    intro cfg' hcfg'
    rw [List.mem_singleton.mp hcfg']
    exact hreach_head cfg (by simp)
  | cons_step cfg₁ cfg₂ rest hstep _htail ih =>
    intro cfg' hcfg'
    cases List.mem_cons.mp hcfg' with
    | inl h => subst h; exact hreach_head cfg' (by simp)
    | inr hrest =>
      apply ih
      · intro cfg₀ h
        simp at h; subst h
        exact ReachableWithinBound.step cfg₁ cfg₂
          (hreach_head cfg₁ (by simp)) hstep
          (hbound cfg₂ (by simp))
      · intro c hc; exact hbound c (List.mem_cons_of_mem _ hc)
      · exact hrest

/-- **Theorem 2: Bottleneck space lower bound.**
    If no contradiction-containing configuration is reachable within space s,
    then every configuration refutation has space ≥ s + 1. -/
theorem bottleneck_space_lower_bound {ν : Type} [DecidableEq ν]
    (F : CNF ν) (s : ℕ)
    (hsep : ∀ cfg, ReachableWithinBound F s cfg → ¬hasContradiction cfg)
    (π : List (ProofConfiguration ν))
    (href : IsConfigurationRefutation F π) :
    configurationSpace π ≥ s + 1 := by
  by_contra hlt
  push_neg at hlt
  have hle : configurationSpace π ≤ s := by omega
  obtain ⟨htrace, hstart, cfg, hcfg, hcontra⟩ := href
  have hbound : ∀ c ∈ π, configSize c ≤ s :=
    fun c hc => le_trans (configSize_le_space π c hc) hle
  have hreach := trace_bounded_reachable F s π htrace
    (fun cfg₀ h => by rw [hstart] at h; simp at h; subst h; exact ReachableWithinBound.init)
    hbound cfg hcfg
  exact hsep cfg hreach hcontra

/-! ## Theorem 3: Distinct Clause Bound -/

def allTraceClauses {ν : Type} [DecidableEq ν]
    (π : List (ProofConfiguration ν)) : Finset (Clause ν) :=
  π.foldr (fun cfg acc => cfg.liveClauses ∪ acc) ∅

theorem mem_allTraceClauses_of_mem {ν : Type} [DecidableEq ν]
    (π : List (ProofConfiguration ν)) (cfg : ProofConfiguration ν)
    (hcfg : cfg ∈ π) (C : Clause ν) (hC : C ∈ cfg.liveClauses) :
    C ∈ allTraceClauses π := by
  induction π with
  | nil => simp at hcfg
  | cons hd tl ih =>
    simp only [allTraceClauses, List.foldr_cons]
    cases List.mem_cons.mp hcfg with
    | inl h => subst h; exact Finset.mem_union_left _ hC
    | inr h => exact Finset.mem_union_right _ (ih h)

private theorem allTraceClauses_card_aux {ν : Type} [DecidableEq ν]
    (π : List (ProofConfiguration ν)) :
    (allTraceClauses π).card ≤
      (π.map (fun cfg => cfg.liveClauses.card)).sum := by
  induction π with
  | nil => simp [allTraceClauses]
  | cons hd tl ih =>
    simp only [allTraceClauses, List.foldr_cons, List.map_cons, List.sum_cons]
    calc (hd.liveClauses ∪ allTraceClauses tl).card
        ≤ hd.liveClauses.card + (allTraceClauses tl).card :=
          Finset.card_union_le _ _
      _ ≤ hd.liveClauses.card + (tl.map (fun cfg => cfg.liveClauses.card)).sum :=
          Nat.add_le_add_left ih _

/-
**Theorem 3: Distinct clause count bounded by length × space.**
-/
theorem allTraceClauses_card_bound {ν : Type} [DecidableEq ν]
    (π : List (ProofConfiguration ν)) :
    (allTraceClauses π).card ≤ π.length * configurationSpace π := by
  -- By definition of `allTraceClauses`, we have:
  have h_card : (allTraceClauses π).card ≤ List.sum (List.map (fun cfg => cfg.liveClauses.card) π) := by
    convert allTraceClauses_card_aux π using 1;
  refine le_trans h_card ?_;
  convert List.sum_le_card_nsmul _ _ _ using 2;
  · rw [ List.length_map ];
  · infer_instance;
  · infer_instance;
  · intro x hx; obtain ⟨ cfg, hcfg, rfl ⟩ := List.mem_map.mp hx; exact configSize_le_space π cfg hcfg;

/-! ## Clause Space Bound -/

def clauseSpaceBound (n w : ℕ) : ℕ :=
  ∑ k ∈ Finset.range (w + 1), Nat.choose n k * 2 ^ k

theorem clauseSpaceBound_mono (n : ℕ) : Monotone (clauseSpaceBound n) := by
  intro w₁ w₂ h
  apply Finset.sum_le_sum_of_subset_of_nonneg
  · exact Finset.range_mono (by omega)
  · intros; exact Nat.zero_le _

end ConfigSpace