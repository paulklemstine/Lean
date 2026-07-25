import Mathlib

/-!
# Tropical Certified Robustness for DAG-Aggregated Decision Rules

This file formalizes a compositional robustness framework for multiclass classifiers
whose decision procedures are represented by finite rooted DAGs built from monotone
1-Lipschitz tropical primitives (`max`, `min`, score-difference comparisons).

## Mathematical Overview

Given a score map `score : (ι → ℝ) → C → ℝ` that is `K`-Lipschitz in the L∞ norm,
and a decision procedure built from pairwise score comparisons aggregated through
a DAG of monotone tropical operations, we prove that the decision is invariant
under perturbations of size `ε` whenever pathwise bottleneck margins exceed `2·K·ε`.

The key mathematical insight is that **pathwise bottleneck margins in an arbitrary
acyclic tropical decision graph compose correctly with pairwise logit-gap perturbation
bounds**. This unifies:
1. One-vs-all argmax certificates (star DAG with min aggregation)
2. Sequential elimination / tournament certificates (chain DAG)

## Main Results

### Foundational Lemmas
* `abs_sub_pairwise_gap_le` — Triangle inequality for pairwise score gaps
* `pairwise_gap_perturbation_le_two_mul` — Score gap perturbation bounded by `2·K·ε`
* `abs_max_sub_max_le_max_abs_sub` — Max is 1-Lipschitz (nonexpansive)
* `abs_min_sub_min_le_max_abs_sub` — Min is 1-Lipschitz (nonexpansive)

### Finset Stability
* `Finset.inf'_abs_sub_le` — `Finset.inf'` is nonexpansive
* `Finset.sup'_abs_sub_le` — `Finset.sup'` is nonexpansive
* `positive_inf'_of_pointwise_lower_bound` — Positivity from pointwise bounds

### DAG Certificate
* `dag_root_certificate_of_leaf_gap` — Root certificate positivity under perturbation

### Corollaries
* `one_vs_all_robust_of_margin` — Classical argmax robustness from runner-up margin
* `sequential_elimination_robust` — Sequential elimination robustness from stagewise margins
* `decision_invariant_of_dag_certificate` — Full end-to-end decision invariance
-/

open Finset

noncomputable section

/-! ## Section 1: Foundational Real-Analysis Lemmas -/

/-- The difference of two pairwise gaps is bounded by the sum of individual drifts.
This is the key estimate: if each logit drifts by at most `δ`, then
the pairwise gap `(a - b) - (a' - b')` drifts by at most `2δ`. -/
theorem abs_sub_pairwise_gap_le (a b a' b' : ℝ) :
    |(a - b) - (a' - b')| ≤ |a - a'| + |b - b'| := by
  grind

/-- Pairwise score-gap perturbation is bounded by `2 * K * ε`.
If each score changes by at most `K * ε`, the gap between any two scores
changes by at most `2 * K * ε`. -/
theorem pairwise_gap_perturbation_le_two_mul
    {C : Type*}
    (score_x score_z : C → ℝ)
    (i j : C) (K ε : ℝ)
    (hLip : ∀ c, |score_z c - score_x c| ≤ K * ε) :
    |(score_z i - score_z j) - (score_x i - score_x j)| ≤ 2 * K * ε := by
  exact abs_le.mpr
    ⟨by linarith [abs_le.mp (hLip i), abs_le.mp (hLip j)],
     by linarith [abs_le.mp (hLip i), abs_le.mp (hLip j)]⟩

/-- `max` is 1-Lipschitz: `|max a b - max a' b'| ≤ max |a-a'| |b-b'|`. -/
theorem abs_max_sub_max_le_max_abs_sub (a b a' b' : ℝ) :
    |max a b - max a' b'| ≤ max |a - a'| |b - b'| := by
  grind

/-- `min` is 1-Lipschitz: `|min a b - min a' b'| ≤ max |a-a'| |b-b'|`. -/
theorem abs_min_sub_min_le_max_abs_sub (a b a' b' : ℝ) :
    |min a b - min a' b'| ≤ max |a - a'| |b - b'| := by
  cases min_cases a b <;> cases min_cases a' b' <;>
    cases abs_cases (a - a') <;> cases abs_cases (b - b') <;>
    cases abs_cases (min a b - min a' b') <;> cases max_cases |a - a'| |b - b'| <;> linarith

/-! ## Section 2: Finset Inf'/Sup' Stability -/

/-- `Finset.inf'` (minimum over a nonempty finite set) is nonexpansive:
if pointwise perturbations are bounded by `Δ`, then the minimum changes by at most `Δ`. -/
theorem Finset.inf'_abs_sub_le
    {α : Type*} [DecidableEq α]
    (s : Finset α) (hs : s.Nonempty)
    (g h : α → ℝ) (Δ : ℝ)
    (_hΔ : 0 ≤ Δ)
    (herr : ∀ a ∈ s, |g a - h a| ≤ Δ) :
    |s.inf' hs g - s.inf' hs h| ≤ Δ := by
  refine abs_sub_le_iff.mpr ⟨?_, ?_⟩
  · simp +zetaDelta at *
    rcases Finset.exists_mem_eq_inf' hs fun x => h x with ⟨i, hi, hi'⟩
    exact ⟨i, hi, by linarith [abs_le.mp (herr i hi)]⟩
  · simp_all +decide [Finset.inf'_le_iff]
    exact Exists.elim (Finset.exists_mem_eq_inf' hs fun a => g a) fun x hx =>
      ⟨x, hx.1, by linarith [abs_le.mp (herr x hx.1), hx.2]⟩

/-- `Finset.sup'` (maximum over a nonempty finite set) is nonexpansive. -/
theorem Finset.sup'_abs_sub_le
    {α : Type*} [DecidableEq α]
    (s : Finset α) (hs : s.Nonempty)
    (g h : α → ℝ) (Δ : ℝ)
    (_hΔ : 0 ≤ Δ)
    (herr : ∀ a ∈ s, |g a - h a| ≤ Δ) :
    |s.sup' hs g - s.sup' hs h| ≤ Δ := by
  refine abs_sub_le_iff.mpr ⟨?_, ?_⟩
  · obtain ⟨a, ha⟩ := Finset.exists_mem_eq_sup' hs g
    linarith [abs_le.mp (herr a ha.1), show s.sup' hs h ≥ h a from Finset.le_sup' h ha.1]
  · simp_all +decide [Finset.sup'_le_iff]
    exact fun a ha => by
      linarith [abs_le.mp (herr a ha), Finset.le_sup' (fun a => g a) ha]

/-- If every value in a nonempty finite set exceeds a positive threshold `γ`,
then the minimum also exceeds `γ`. -/
theorem positive_inf'_of_pointwise_lower_bound
    {α : Type*} [DecidableEq α]
    (s : Finset α) (hs : s.Nonempty)
    (g : α → ℝ)
    (γ : ℝ)
    (hγ : 0 < γ)
    (hg : ∀ a ∈ s, γ ≤ g a) :
    0 < s.inf' hs g := by
  exact lt_of_lt_of_le hγ (Finset.le_inf' _ _ hg)

/-! ## Section 3: DAG Root Certificate Theorem -/

/-
**Main DAG certificate theorem.**

Given a finite DAG with a recursive certificate function where:
- leaf certificates perturb by at most `Δ`,
- internal nodes aggregate children via monotone 1-Lipschitz operations
  (perturbation at a node ≤ sup of perturbations at its children),
- the root certificate at the clean input exceeds `Δ`,

then the root certificate remains strictly positive under perturbation.

The proof proceeds by strong induction on `rank`, showing that the certificate
perturbation at every node is bounded by `Δ`. Since the root certificate
exceeds `Δ`, it remains positive.
-/
theorem dag_root_certificate_of_leaf_gap
    {V : Type*} [Fintype V] [DecidableEq V]
    (root : V)
    (children : V → Finset V)
    (rank : V → ℕ)
    (cert_x cert_z : V → ℝ)
    (Δ : ℝ)
    (_ : 0 ≤ Δ)
    (hacyclic : ∀ {u v}, v ∈ children u → rank v < rank u)
    (hleaf :
      ∀ u, children u = ∅ →
        |cert_x u - cert_z u| ≤ Δ)
    (hmono_lip :
      ∀ u, ∀ hne : (children u).Nonempty,
        |cert_x u - cert_z u| ≤
          (children u).sup' hne fun v => |cert_x v - cert_z v|)
    (hroot_pos :
      Δ < cert_x root) :
    0 < cert_z root := by
      -- We prove that the perturbation bound holds for every node in the DAG.
      have h_node_perturbation_bound : ∀ u, |cert_x u - cert_z u| ≤ Δ := by
        -- We prove the perturbation bound using induction on the rank of the node in the DAG.
        have h_ind : ∀ k, ∀ u, rank u = k → |cert_x u - cert_z u| ≤ Δ := by
          intro k;
          induction' k using Nat.strong_induction_on with k ih;
          intro u hu;
          by_cases h : ( children u ).Nonempty <;> simp_all +decide;
          obtain ⟨ v, hv₁, hv₂ ⟩ := hmono_lip u h; exact le_trans hv₂ ( ih _ ( by linarith [ hacyclic hv₁ ] ) _ rfl ) ;
        exact fun u => h_ind _ _ rfl;
      linarith [ abs_le.mp ( h_node_perturbation_bound root ) ]

/-
Auxiliary lemma: under the DAG hypotheses, the perturbation at every node
is bounded by `Δ`. This is the inductive core of the DAG certificate theorem.
-/
theorem dag_node_perturbation_bound
    {V : Type*} [Fintype V] [DecidableEq V]
    (children : V → Finset V)
    (rank : V → ℕ)
    (cert_x cert_z : V → ℝ)
    (Δ : ℝ)
    (_ : 0 ≤ Δ)
    (hacyclic : ∀ {u v}, v ∈ children u → rank v < rank u)
    (hleaf :
      ∀ u, children u = ∅ →
        |cert_x u - cert_z u| ≤ Δ)
    (hmono_lip :
      ∀ u, ∀ hne : (children u).Nonempty,
        |cert_x u - cert_z u| ≤
          (children u).sup' hne fun v => |cert_x v - cert_z v|)
    (u : V) :
    |cert_x u - cert_z u| ≤ Δ := by
      -- By induction on the rank of u.
      induction' n : rank u using Nat.strong_induction_on with n ih generalizing u;
      by_cases hne : (children u).Nonempty;
      · refine' le_trans ( hmono_lip u hne ) ( Finset.sup'_le _ _ fun v hv => _ );
        exact ih _ ( by linarith [ hacyclic hv ] ) _ rfl;
      · aesop

/-! ## Section 4: One-vs-All Argmax Robustness Corollary -/

/-- **One-vs-all robustness from runner-up margin.**

If score map `score` is `K`-Lipschitz in L∞ and the margin of the predicted class `y`
over every other class exceeds `2·K·ε`, then `y` remains the strict winner under
any perturbation of L∞ size at most `ε`.

This is the classical argmax robustness certificate, derived here as a special case
of the tropical DAG framework where the DAG is a star graph with `min` aggregation. -/
theorem one_vs_all_robust_of_margin
    {ι C : Type*} [Fintype ι] [Fintype C] [DecidableEq C]
    (score : (ι → ℝ) → C → ℝ)
    (x : ι → ℝ) (y : C) (K ε : ℝ)
    (_hK : 0 ≤ K)
    (_hε : 0 ≤ ε)
    (hLip : ∀ z : ι → ℝ, (∀ i, |z i - x i| ≤ ε) →
      ∀ c, |score z c - score x c| ≤ K * ε)
    (hmargin : ∀ j, j ≠ y → 2 * K * ε < score x y - score x j) :
    ∀ z : ι → ℝ, (∀ i, |z i - x i| ≤ ε) →
      ∀ j, j ≠ y → score z y > score z j := by
  exact fun z hz j hj => by
    linarith [abs_le.mp (hLip z hz y), abs_le.mp (hLip z hz j), hmargin j hj]

/-! ## Section 5: Sequential Elimination Robustness Corollary -/

/-- **Sequential elimination robustness from stagewise margins.**

If each stage of a sequential elimination process has a gap function that is
`2·K`-Lipschitz in L∞ input perturbation, and every stage margin exceeds `2·K·ε`,
then all stage outcomes are preserved under perturbation.

This models tournament brackets, cascaded classifiers, and sequential reject-option
classifiers where each stage eliminates candidates via pairwise comparisons. -/
theorem sequential_elimination_robust
    {ι S : Type*} [Fintype ι] [Fintype S]
    (stageGap : S → (ι → ℝ) → ℝ)
    (x : ι → ℝ) (K ε : ℝ)
    (_hK : 0 ≤ K)
    (_hε : 0 ≤ ε)
    (hLip : ∀ s, ∀ z : ι → ℝ, (∀ i, |z i - x i| ≤ ε) →
      |stageGap s z - stageGap s x| ≤ 2 * K * ε)
    (hmargin : ∀ s, 2 * K * ε < stageGap s x) :
    ∀ z : ι → ℝ, (∀ i, |z i - x i| ≤ ε) →
      ∀ s, 0 < stageGap s z := by
  exact fun z hz s => by linarith [abs_le.mp (hLip s z hz), hmargin s]

/-! ## Section 6: Full End-to-End Decision Invariance -/

/-
**End-to-end decision invariance theorem.**

Combines score-map Lipschitz continuity, DAG certificate stability, and
decision determinism to conclude that the final classification is invariant
on the entire L∞ ball of radius `ε`.

The proof has three steps:
1. Score perturbation: `∀ c, |score z c - score x c| ≤ K * ε`
2. Certificate stability: by induction on rank, every DAG node's certificate
   changes by at most `2·K·ε` (leaves use pairwise gap bound, internal nodes
   use monotone 1-Lipschitz aggregation)
3. Decision invariance: since `dagCert (score x) root > 2·K·ε > 0` and
   `dagCert (score z) root > 0`, the decision is the same by `hdecide`.

This theorem subsumes both the one-vs-all argmax certificate and the
sequential elimination certificate as special cases.
-/
theorem decision_invariant_of_dag_certificate
    {ι C V : Type*} [Fintype ι] [Fintype V] [DecidableEq V]
    [Fintype C] [DecidableEq C]
    (score : (ι → ℝ) → C → ℝ)
    (decide_fn : (C → ℝ) → C)
    (dagCert : (C → ℝ) → V → ℝ)
    (root : V)
    (children : V → Finset V)
    (rank : V → ℕ)
    (x : ι → ℝ) (K ε : ℝ)
    (hK : 0 ≤ K)
    (hε : 0 ≤ ε)
    (hacyclic : ∀ {u v}, v ∈ children u → rank v < rank u)
    (hscore_lip :
      ∀ z : ι → ℝ, (∀ i, |z i - x i| ≤ ε) →
        ∀ c, |score z c - score x c| ≤ K * ε)
    (hleaf :
      ∀ u, children u = ∅ →
        ∀ s s' : C → ℝ, (∀ c, |s c - s' c| ≤ K * ε) →
        |dagCert s u - dagCert s' u| ≤ 2 * K * ε)
    (hmono_lip :
      ∀ (s s' : C → ℝ) (u : V), ∀ hne : (children u).Nonempty,
        |dagCert s u - dagCert s' u| ≤
          (children u).sup' hne fun v => |dagCert s v - dagCert s' v|)
    (hdecide :
      ∀ s s' : C → ℝ, 0 < dagCert s root → 0 < dagCert s' root →
        decide_fn s = decide_fn s')
    (hroot_pos :
      2 * K * ε < dagCert (score x) root) :
    ∀ z : ι → ℝ, (∀ i, |z i - x i| ≤ ε) →
      decide_fn (score z) = decide_fn (score x) := by
        have hcert_stable : ∀ z : ι → ℝ, (∀ i, |z i - x i| ≤ ε) → |dagCert (score z) root - dagCert (score x) root| ≤ 2 * K * ε := by
          intro z hz;
          apply dag_node_perturbation_bound;
          any_goals assumption;
          · positivity;
          · exact fun u hu => hleaf u hu _ _ fun c => hscore_lip z hz c;
          · exact fun u hne => hmono_lip _ _ _ hne;
        exact fun z hz => hdecide _ _ ( by linarith [ abs_le.mp ( hcert_stable z hz ) ] ) ( by linarith [ abs_le.mp ( hcert_stable z hz ) ] )

end