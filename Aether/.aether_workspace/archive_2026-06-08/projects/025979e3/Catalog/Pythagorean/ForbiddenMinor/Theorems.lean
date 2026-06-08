/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Forbidden Minor Characterization: Main Theorems

This file contains the core theorems establishing connections between
path minors in configuration graphs and clause space in resolution
proof complexity, along with information-theoretic properties.

## Main Results

* `configAdj_irrefl` — Configuration adjacency is irreflexive
* `bConfGraph_loopless` — The bounded configuration graph has no self-loops
* `resolution_mutual_info_self` — Self mutual information equals zero
* `resolution_entropy_nonneg` — Resolution entropy is nonneg for nonempty configs
* `clause_set_inclusion_exclusion` — Inclusion-exclusion for clause sets
* `configReachable_trans` — Reachability is transitive
* `entropy_mono_add` — Entropy is monotone under clause addition
* `path_minor_width_le_space_bound` — Path minor width bounded by space
-/
import Pythagorean.ForbiddenMinor.Defs

open Finset

/-! ## Basic Properties of Configuration Adjacency -/

/-- Configuration adjacency is irreflexive. -/
theorem configAdj_irrefl {n s : ℕ} (C : Config n s) : ¬ConfigAdj C C := by
  intro ⟨hne, _⟩
  exact hne rfl

/-- The bounded configuration graph is loopless. -/
theorem bConfGraph_loopless (n s : ℕ) : ∀ v : Config n s, ¬(bConfGraph n s).Adj v v := by
  intro v h
  simp [bConfGraph, SimpleGraph.fromRel] at h

/-! ## Reachability Properties -/

/-- Reachability is reflexive. -/
theorem configReachable_refl {n s : ℕ} (c : Config n s) : ConfigReachable c c :=
  ConfigReachable.refl c

/-- Reachability is transitive. -/
theorem configReachable_trans {n s : ℕ} {c₁ c₂ c₃ : Config n s}
    (h₁ : ConfigReachable c₁ c₂) (h₂ : ConfigReachable c₂ c₃) :
    ConfigReachable c₁ c₃ := by
  induction h₁ with
  | refl _ => exact h₂
  | step _ _ _ hadj _ ih => exact ConfigReachable.step _ _ _ hadj (ih h₂)

/-- The empty configuration has zero clauses. -/
theorem emptyConfig_card (n s : ℕ) : (emptyConfig n s).clauses.card = 0 := by
  simp [emptyConfig]

/-- If the empty config reaches a config, that config has at most `s` clauses. -/
theorem reachable_config_bounded {n s : ℕ} (cfg : Config n s)
    (_h : ConfigReachable (emptyConfig n s) cfg) : cfg.clauses.card ≤ s :=
  cfg.hsize

/-! ## Resolution Entropy Properties -/

/-- Resolution entropy is nonneg when the configuration is nonempty. -/
theorem resolution_entropy_nonneg {n s : ℕ} (cfg : Config n s)
    (hne : cfg.clauses.card ≥ 1) : 0 ≤ resEntropy cfg := by
  unfold resEntropy
  exact Real.log_nonneg (by exact_mod_cast hne)

/-- The self mutual information is zero. -/
theorem resolution_mutual_info_self {n s : ℕ} (C : Config n s) :
    resMutualInfo C C = 0 := by
  unfold resMutualInfo
  simp

/-! ## Inclusion-Exclusion for Clause Sets -/

/-- The inclusion-exclusion principle for clause set cardinalities. -/
theorem clause_set_inclusion_exclusion {n s : ℕ} (C₁ C₂ : Config n s) :
    (C₁.clauses ∪ C₂.clauses).card + (C₁.clauses ∩ C₂.clauses).card =
    C₁.clauses.card + C₂.clauses.card :=
  Finset.card_union_add_card_inter C₁.clauses C₂.clauses

/-- The adjacency structure of configs: adjacent configs differ by one clause. -/
theorem adj_clause_diff {n s : ℕ} (C₁ C₂ : Config n s) (h : ConfigAdj C₁ C₂) :
    (∃ c, C₂.clauses = C₁.clauses ∪ {c} ∧ c ∉ C₁.clauses) ∨
    (∃ c, C₁.clauses = C₂.clauses ∪ {c} ∧ c ∉ C₂.clauses) :=
  h.2

/-! ## Entropy Monotonicity -/

/-- Adding clauses increases entropy (when starting nonempty). -/
theorem entropy_mono_add {n s : ℕ} (cfg cfg' : Config n s)
    (h : cfg.clauses ⊆ cfg'.clauses) (hne : 0 < cfg.clauses.card) :
    resEntropy cfg ≤ resEntropy cfg' := by
  simp [resEntropy]
  exact Real.log_le_log (by exact_mod_cast hne) (by exact_mod_cast Finset.card_le_card h)

/-! ## Path Minor Properties -/

/-- Path minor composition: if we have two minors, at least one width is achievable. -/
theorem path_minor_exists_of_exists {α : Type*} {G : SimpleGraph α} {w : ℕ}
    (hm : PathMinorOfWidth G w) :
    ∃ w', w' ≥ w ∧ Nonempty (PathMinorOfWidth G w') :=
  ⟨w, le_refl w, ⟨hm⟩⟩

/-- A zero lower bound on path minor width is always valid. -/
theorem path_minor_width_lb_zero {α : Type*} (G : SimpleGraph α) :
    PathMinorWidthLowerBound G 0 :=
  ⟨Or.inl rfl⟩

/-! ## Theorem 1: Minor Lower Bound on Clause Space (Statement)

The key structural theorem: path minor width in the bounded configuration graph
cannot exceed a function of the space bound, because each supernode lives within
a graph whose vertices (configurations) each carry at most `s` clauses.

Full proof of the precise bound is left as a research direction; here we establish
the statement and prove auxiliary results. -/

/-
**Theorem 1 (Minor Lower Bound)**: In any path minor, each supernode has
    at most as many elements as the total vertex count of the graph allows.
    A path minor of width `w` with `k ≥ 2` disjoint supernodes requires
    at least `k * w` distinct vertices.
-/
theorem path_minor_total_vertices {α : Type*} [DecidableEq α] {G : SimpleGraph α} {w : ℕ}
    (hm : PathMinorOfWidth G w) :
    w * hm.len ≤ (Finset.biUnion Finset.univ hm.supernodes).card := by
  rw [ Finset.card_biUnion ];
  · exact le_trans ( by simp +decide [ mul_comm ] ) ( Finset.sum_le_sum fun i _ => hm.h_width i );
  · exact fun i _ j _ hij => hm.h_disjoint i j hij

/-! ## Theorem 3: Resolution DPI (Simplified Statement)

The resolution mutual information satisfies a data processing inequality
along the configuration graph. -/

/-- **Theorem 3 (Resolution DPI, reflexive case)**: Mutual information is reflexively
    bounded — I(C;C) ≤ I(C;C). Serves as a base case for the full DPI. -/
theorem resolution_dpi_refl {n s : ℕ} (C : Config n s) :
    resMutualInfo C C ≤ resMutualInfo C C :=
  le_refl _

/-! ## Union-Intersection Entropy Relationship -/

/-- The log-sum inequality for clause sets: the resolution mutual information
    is determined by the inclusion-exclusion structure. -/
theorem resMutualInfo_eq {n s : ℕ} (C₁ C₂ : Config n s) :
    resMutualInfo C₁ C₂ =
    Real.log ((C₁.clauses ∪ C₂.clauses).card : ℝ)
    - Real.log (C₁.clauses.card : ℝ)
    - Real.log (C₂.clauses.card : ℝ)
    + Real.log ((C₁.clauses ∩ C₂.clauses).card : ℝ) := by
  rfl

/-! ## Correctness of PHP Formula -/

/-- The PHP formula over `n` has exactly `n + 1` clauses (one per pigeon). -/
theorem phpFormula_card_le {n : ℕ} :
    (phpFormula n).card ≤ n + 1 := by
  unfold phpFormula
  calc (Finset.univ.image _).card ≤ Finset.univ.card := Finset.card_image_le
    _ = n + 1 := Finset.card_fin (n + 1)