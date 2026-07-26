/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certified Tropical Polynomial Normal Form

This file establishes that tropical polynomial expressions over `ℝ` in `n` variables
admit a certified canonical normal form via **essentialization** — the removal of
dominated (inessential) monomials — and that semantic equality of tropical polynomial
functions is decidable through this normal form.

## Key insight: essential support, not raw support

The canonical normal form is NOT the raw expanded support of a tropical expression.
Example: `min(x, 0, x+1) = min(x, 0)` — the monomial `x + 1` is semantically invisible.
The correct canonical object is the **essential support**: the set of monomials that
achieve the infimum (uniquely) at some point. Two tropical polynomials define the same
function if and only if their essential supports coincide. This is the tropical analogue
of the Newton polytope lower-hull theorem.

## Convention: min-plus

We use the **min-plus** (min-tropical) convention throughout:
- Tropical addition = `min` (classical)
- Tropical multiplication = `+` (classical)

A tropical polynomial: `f(x) = min_{m ∈ S} (cₘ + Σᵢ wₘᵢ xᵢ)`

## Main Results

* `TropicalCNF.expand_sound` — Expansion preserves semantics
* `TropicalCNF.essentialize_sound` — Essentialization preserves semantics
* `TropicalCNF.normalize_sound` — **Soundness**: normalization preserves semantics
* `TropicalCNF.affine_eq_of_eval_eq` — Affine rigidity: equal evaluations ↔ equal monomials
* `TropicalCNF.essentialize_complete` — **Completeness**: equal functions → equal essential supports
* `TropicalCNF.normalize_complete` — **Decision principle**: equal functions → equal normal forms
-/
import Mathlib

noncomputable section
open scoped BigOperators
open Finset

attribute [local instance] Classical.propDecidable
set_option maxHeartbeats 800000

namespace TropicalCNF

/-! ## Core Definitions -/

abbrev TropMonom (n : ℕ) := ℝ × (Fin n → ℕ)

def evalMonom {n : ℕ} (m : TropMonom n) (x : Fin n → ℝ) : ℝ :=
  m.1 + ∑ i : Fin n, (m.2 i : ℝ) * x i

inductive TropExpr (n : ℕ) where
  | const : ℝ → TropExpr n
  | var   : Fin n → TropExpr n
  | add   : TropExpr n → TropExpr n → TropExpr n
  | mul   : TropExpr n → TropExpr n → TropExpr n

def evalExpr {n : ℕ} : TropExpr n → (Fin n → ℝ) → ℝ
  | .const c,     _ => c
  | .var i,       x => x i
  | .add e₁ e₂,  x => min (evalExpr e₁ x) (evalExpr e₂ x)
  | .mul e₁ e₂,  x => evalExpr e₁ x + evalExpr e₂ x

@[ext]
structure TropPolyNF (n : ℕ) where
  terms : Finset (TropMonom n)
  nonempty : terms.Nonempty

def evalNF {n : ℕ} (s : TropPolyNF n) (x : Fin n → ℝ) : ℝ :=
  s.terms.inf' s.nonempty (fun m => evalMonom m x)

/-! ## Normal-Form Operations -/

def addNF {n : ℕ} (s t : TropPolyNF n) : TropPolyNF n where
  terms := s.terms ∪ t.terms
  nonempty := s.nonempty.mono subset_union_left

def mulMonom {n : ℕ} (m₁ m₂ : TropMonom n) : TropMonom n :=
  (m₁.1 + m₂.1, fun i => m₁.2 i + m₂.2 i)

def mulNF {n : ℕ} (s t : TropPolyNF n) : TropPolyNF n where
  terms := (s.terms ×ˢ t.terms).image (fun p => mulMonom p.1 p.2)
  nonempty := by
    obtain ⟨a, ha⟩ := s.nonempty; obtain ⟨b, hb⟩ := t.nonempty
    exact ⟨mulMonom a b, mem_image.mpr ⟨(a, b), mem_product.mpr ⟨ha, hb⟩, rfl⟩⟩

def expand {n : ℕ} : TropExpr n → TropPolyNF n
  | .const c     => ⟨{(c, fun _ => 0)}, ⟨_, mem_singleton_self _⟩⟩
  | .var i       => ⟨{(0, Pi.single i 1)}, ⟨_, mem_singleton_self _⟩⟩
  | .add e₁ e₂  => addNF (expand e₁) (expand e₂)
  | .mul e₁ e₂  => mulNF (expand e₁) (expand e₂)

/-! ## Basic Monomial Lemmas -/

@[simp] lemma evalMonom_zero_exponent (c : ℝ) {n : ℕ} (x : Fin n → ℝ) :
    evalMonom (c, fun _ => (0 : ℕ)) x = c := by simp [evalMonom]

@[simp] lemma evalMonom_var {n : ℕ} (i : Fin n) (x : Fin n → ℝ) :
    evalMonom ((0 : ℝ), Pi.single i 1) x = x i := by
  unfold evalMonom; rw [Finset.sum_eq_single i] <;> aesop

lemma evalMonom_mulMonom {n : ℕ} (m₁ m₂ : TropMonom n) (x : Fin n → ℝ) :
    evalMonom (mulMonom m₁ m₂) x = evalMonom m₁ x + evalMonom m₂ x := by
  unfold evalMonom mulMonom; simp [add_mul, Finset.sum_add_distrib]; ring

lemma evalMonom_add_perturbation {n : ℕ} (m : TropMonom n) (x₀ δ : Fin n → ℝ) :
    evalMonom m (fun i => x₀ i + δ i) = evalMonom m x₀ + ∑ i, (m.2 i : ℝ) * δ i := by
  unfold evalMonom; simp [mul_add, Finset.sum_add_distrib]; ring

lemma evalMonom_sub {n : ℕ} (m₁ m₂ : TropMonom n) (x : Fin n → ℝ) :
    evalMonom m₁ x - evalMonom m₂ x =
    (m₁.1 - m₂.1) + ∑ i, ((m₁.2 i : ℝ) - (m₂.2 i : ℝ)) * x i := by
  simp [evalMonom, sub_mul, Finset.sum_sub_distrib]; ring

lemma continuous_evalMonom {n : ℕ} (m : TropMonom n) :
    Continuous (fun x : Fin n → ℝ => evalMonom m x) := by
  unfold evalMonom
  exact continuous_const.add (continuous_finset_sum _ fun i _ =>
    continuous_const.mul (continuous_apply i))

/-! ## Affine Rigidity -/

theorem affine_eq_of_eval_eq {n : ℕ} {m₁ m₂ : TropMonom n}
    (h : ∀ x : Fin n → ℝ, evalMonom m₁ x = evalMonom m₂ x) : m₁ = m₂ := by
  have h_coeff : m₁.1 = m₂.1 := by simpa [evalMonom] using h 0
  have h_exp : ∀ j : Fin n, m₁.2 j = m₂.2 j := by
    intro j
    have h0 := h 0; have hj := h (Pi.single j 1)
    simp [evalMonom, Pi.single_apply, Finset.sum_ite_eq'] at h0 hj
    have : (m₁.2 j : ℝ) = (m₂.2 j : ℝ) := by linarith
    exact_mod_cast this
  exact Prod.ext h_coeff (funext h_exp)

lemma eval_ne_of_ne {n : ℕ} {m₁ m₂ : TropMonom n} (h : m₁ ≠ m₂) :
    ∃ x : Fin n → ℝ, evalMonom m₁ x ≠ evalMonom m₂ x := by
  by_contra h'; push_neg at h'; exact h (affine_eq_of_eval_eq h')

/-! ## Geometric Lemmas -/

/-
A non-zero affine function has a nowhere dense zero set.
-/
lemma nowhere_dense_affine_zero {n : ℕ} {c : ℝ} {w : Fin n → ℝ}
    (h : c ≠ 0 ∨ w ≠ 0) :
    IsNowhereDense {x : Fin n → ℝ | c + ∑ i, w i * x i = 0} := by
  by_cases hc : c = 0 <;> by_cases hw : w = 0 <;> simp_all +decide [ IsNowhereDense ];
  · -- If $w \neq 0$, then the set $\{x \mid \sum_{i} w_i x_i = 0\}$ is a hyperplane in $\mathbb{R}^n$, which has empty interior.
    have h_hyperplane : ∀ x : Fin n → ℝ, (∑ i, w i * x i = 0) → ∀ ε > 0, ∃ y : Fin n → ℝ, (∑ i, w i * y i ≠ 0) ∧ dist y x < ε := by
      intro x hx ε hε_pos
      obtain ⟨i, hi⟩ : ∃ i, w i ≠ 0 := by
        exact Function.ne_iff.mp hw;
      refine' ⟨ fun j => if j = i then x i + ε / 2 else x j, _, _ ⟩ <;> simp_all +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
      · cases lt_or_gt_of_ne hi <;> nlinarith;
      · rw [ dist_eq_norm, pi_norm_lt_iff ] <;> norm_num [ hε_pos ];
        grind;
    -- Since the set $\{x \mid \sum_{i} w_i x_i = 0\}$ is closed, its closure is itself.
    have h_closed : IsClosed {x : Fin n → ℝ | ∑ i, w i * x i = 0} := by
      exact isClosed_eq ( continuous_finset_sum _ fun _ _ => continuous_const.mul ( continuous_apply _ ) ) continuous_const;
    rw [ h_closed.closure_eq ];
    exact Set.eq_empty_iff_forall_notMem.mpr fun x hx => by rcases Metric.mem_nhds_iff.mp ( mem_interior_iff_mem_nhds.mp hx ) with ⟨ ε, εpos, hε ⟩ ; obtain ⟨ y, hy₁, hy₂ ⟩ := h_hyperplane x ( hε <| Metric.mem_ball_self εpos ) ε εpos; exact hy₁ <| hε <| Metric.mem_ball.mpr hy₂;
  · -- Since $w \neq 0$, the set $\{x \mid c + \sum_{i} w_i x_i = 0\}$ is a hyperplane in $\mathbb{R}^n$.
    have h_hyperplane : IsClosed {x : Fin n → ℝ | c + ∑ i, w i * x i = 0} ∧ ∀ x : Fin n → ℝ, x ∈ {x : Fin n → ℝ | c + ∑ i, w i * x i = 0} → ∃ i, w i ≠ 0 := by
      exact ⟨ isClosed_eq ( continuous_const.add <| continuous_finset_sum _ fun _ _ => continuous_const.mul <| continuous_apply _ ) continuous_const, fun x hx => not_forall.mp fun h => hw <| funext h ⟩;
    -- Since the set is closed and a hyperplane, it has empty interior.
    have h_empty_interior : ∀ x : Fin n → ℝ, x ∈ {x : Fin n → ℝ | c + ∑ i, w i * x i = 0} → ∀ ε > 0, ∃ y : Fin n → ℝ, y ∈ Metric.ball x ε ∧ y ∉ {x : Fin n → ℝ | c + ∑ i, w i * x i = 0} := by
      intro x hx ε hε_pos
      obtain ⟨i, hi⟩ : ∃ i, w i ≠ 0 := h_hyperplane.right x hx
      use x + fun j => if j = i then ε / 2 else 0;
      simp_all +decide [ Finset.sum_add_distrib, mul_add, add_mul, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, dist_eq_norm, Pi.norm_def ];
      exact ⟨ by rw [ show ( univ.sup fun b => ‖if b = i then ε / 2 else 0‖₊ ) = ‖ε / 2‖₊ by exact le_antisymm ( Finset.sup_le fun j hj => by aesop ) ( by exact Finset.le_sup ( f := fun b => ‖if b = i then ε / 2 else 0‖₊ ) ( Finset.mem_univ i ) |> le_trans ( by aesop ) ) ] ; simpa [ abs_of_pos hε_pos ] using by linarith, by cases lt_or_gt_of_ne hi <;> nlinarith ⟩;
    simp_all +decide [ Set.ext_iff, mem_interior_iff_mem_nhds, Metric.mem_nhds_iff ];
    intro x ε hε h; specialize h_empty_interior x; contrapose! h_empty_interior; aesop;

/-
An open ball cannot be covered by finitely many hyperplanes.
-/
lemma ball_not_covered_by_hyperplanes {n : ℕ}
    (x₀ : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε)
    (affines : Finset (ℝ × (Fin n → ℝ)))
    (h_nonzero : ∀ p ∈ affines, p.1 ≠ 0 ∨ p.2 ≠ 0) :
    ∃ y : Fin n → ℝ, (∀ i, |y i - x₀ i| < ε) ∧
      ∀ p ∈ affines, p.1 + ∑ i, p.2 i * y i ≠ 0 := by
  -- By Baire category. Each {x | p.1 + ∑ p.2 i * x i = 0} is nowhere dense by nowhere_dense_affine_zero.
  have h_closed_nowhere_dense : ∀ p ∈ affines, IsClosed {x : Fin n → ℝ | p.1 + ∑ i, p.2 i * x i = 0} ∧ IsNowhereDense {x : Fin n → ℝ | p.1 + ∑ i, p.2 i * x i = 0} := by
    exact fun p hp => ⟨ isClosed_eq ( continuous_const.add <| continuous_finset_sum _ fun _ _ => continuous_const.mul <| continuous_apply _ ) continuous_const, nowhere_dense_affine_zero <| h_nonzero p hp ⟩;
  -- The union of finitely many nowhere dense sets is meager.
  have h_meager : IsMeagre (⋃ p ∈ affines, {x : Fin n → ℝ | p.1 + ∑ i, p.2 i * x i = 0}) := by
    simp_all +decide [ IsMeagre, IsNowhereDense ];
    simp_all +decide [ mem_residual_iff, Set.compl_def ];
    intro a b hab; use { ( closure { x : Fin n → ℝ | a + ∑ i, b i * x i = 0 } ) ᶜ } ; simp_all +decide [ Set.subset_def ] ;
    rw [ dense_iff_closure_eq ] ; specialize h_closed_nowhere_dense a b hab ; aesop;
  -- An open ball is not meager.
  have h_open_ball_not_meager : ¬ IsMeagre (Metric.ball x₀ ε) := by
    simp +decide [ IsMeagre ];
    simp +decide [ mem_residual ];
    intro x hx₁ hx₂ hx₃; have := hx₃.inter_nhds_nonempty ( Metric.ball_mem_nhds x₀ hε ) ; obtain ⟨ y, hy₁, hy₂ ⟩ := this; exact absurd ( hx₁ hy₁ ) ( by aesop ) ;
  contrapose! h_open_ball_not_meager;
  refine' h_meager.mono _;
  intro y hy; specialize h_open_ball_not_meager y; simp_all +decide [ Metric.mem_ball, dist_eq_norm ] ;
  exact h_open_ball_not_meager fun i => lt_of_le_of_lt ( norm_le_pi_norm ( y - x₀ ) i ) hy

/-- Near any point, there exists a nearby point where all monomials evaluate distinctly. -/
lemma exists_all_distinct_near {n : ℕ} (s : Finset (TropMonom n))
    (x₀ : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    ∃ y : Fin n → ℝ, (∀ i, |y i - x₀ i| < ε) ∧
      ∀ m₁ ∈ s, ∀ m₂ ∈ s, m₁ ≠ m₂ → evalMonom m₁ y ≠ evalMonom m₂ y := by
  set affines := s.offDiag.image (fun p : TropMonom n × TropMonom n =>
    ((p.1.1 - p.2.1 : ℝ), (fun i : Fin n => (p.1.2 i : ℝ) - (p.2.2 i : ℝ))))
  have h_nonzero : ∀ p ∈ affines, p.1 ≠ 0 ∨ p.2 ≠ 0 := by
    intro p hp
    simp only [affines, Finset.mem_image, Finset.mem_offDiag] at hp
    obtain ⟨⟨m₁, m₂⟩, ⟨hm₁, hm₂, hne⟩, rfl⟩ := hp
    by_contra h_both_zero
    push_neg at h_both_zero
    apply hne
    have h1 : m₁.1 = m₂.1 := by linarith [h_both_zero.1]
    have h2 : m₁.2 = m₂.2 := by
      ext i
      have hw := h_both_zero.2
      have : (m₁.2 i : ℝ) - (m₂.2 i : ℝ) = 0 := by
        have := congr_fun hw i; simp at this; exact this
      exact_mod_cast sub_eq_zero.mp this
    exact Prod.ext h1 h2
  obtain ⟨y, hy_ball, hy_avoid⟩ := ball_not_covered_by_hyperplanes x₀ ε hε affines h_nonzero
  exact ⟨y, hy_ball, fun m₁ hm₁ m₂ hm₂ hne h_eq => by
    have hmem : (m₁.1 - m₂.1, fun i : Fin n => (m₁.2 i : ℝ) - (m₂.2 i : ℝ)) ∈ affines :=
      Finset.mem_image.mpr ⟨(m₁, m₂), Finset.mem_offDiag.mpr ⟨hm₁, hm₂, hne⟩, rfl⟩
    have := hy_avoid _ hmem
    simp only at this
    have hsub := evalMonom_sub m₁ m₂ y
    rw [h_eq, sub_self] at hsub
    exact this (hsub.symm)⟩

/-! ## Essentialization -/

def IsEssential {n : ℕ} (s : Finset (TropMonom n)) (m : TropMonom n) : Prop :=
  m ∈ s ∧ ∃ x : Fin n → ℝ, ∀ m' ∈ s, m' ≠ m → evalMonom m x < evalMonom m' x

lemma essential_of_unique_min {n : ℕ} {s : Finset (TropMonom n)} {m : TropMonom n}
    {y : Fin n → ℝ} (hm : m ∈ s)
    (huniq : ∀ m' ∈ s, m' ≠ m → evalMonom m y < evalMonom m' y) :
    IsEssential s m := ⟨hm, y, huniq⟩

lemma essential_achieves_inf {n : ℕ} (s : Finset (TropMonom n)) (hs : s.Nonempty)
    (x : Fin n → ℝ) :
    ∃ m, IsEssential s m ∧
      evalMonom m x = s.inf' hs (fun m => evalMonom m x) := by
  -- Let $T = s.filter (evalMonom · x = inf' s x)$. $T$ is nonempty (contains $m₀$).
  set T := s.filter (fun m => evalMonom m x = s.inf' hs (fun m => evalMonom m x))
  have hT_nonempty : T.Nonempty := by
    exact Exists.elim ( Finset.exists_mem_eq_inf' hs fun m => evalMonom m x ) fun m hm => ⟨ m, by aesop ⟩;
  -- Let $\delta > 0$ be the minimum difference between $evalMonom m x$ and $inf' s x$ for $m \in s \setminus T$.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ m ∈ s \ T, evalMonom m x > s.inf' hs (fun m => evalMonom m x) + δ := by
    by_cases h_empty : s \ T = ∅;
    · exact ⟨ 1, zero_lt_one, by simp +decide [ h_empty ] ⟩;
    · have h_min_diff : ∃ m ∈ s \ T, ∀ m' ∈ s \ T, evalMonom m x ≤ evalMonom m' x := by
        exact Finset.exists_min_image _ _ ( Finset.nonempty_of_ne_empty h_empty );
      obtain ⟨ m, hm₁, hm₂ ⟩ := h_min_diff;
      simp +zetaDelta at *;
      exact ⟨ ( evalMonom m x - s.inf' hs fun m => evalMonom m x ) / 2, half_pos ( sub_pos.mpr ( lt_of_le_of_ne ( Finset.inf'_le _ hm₁.1 ) ( Ne.symm ( hm₁.2 hm₁.1 ) ) ) ), fun a b hab h => by linarith [ hm₂ a b hab h, show evalMonom m x > s.inf' hs fun m => evalMonom m x from lt_of_le_of_ne ( Finset.inf'_le _ hm₁.1 ) ( Ne.symm ( hm₁.2 hm₁.1 ) ) ] ⟩;
  -- By continuity of $evalMonom$, there exists an $\epsilon > 0$ such that for all $m \in s$, $evalMonom m y$ is close to $evalMonom m x$ when $|y_i - x_i| < \epsilon$.
  obtain ⟨ε, hε_pos, hε⟩ : ∃ ε > 0, ∀ m ∈ s, ∀ y : Fin n → ℝ, (∀ i, |y i - x i| < ε) → |evalMonom m y - evalMonom m x| < δ / 2 := by
    have h_cont : ∀ m ∈ s, ContinuousAt (fun y : Fin n → ℝ => evalMonom m y) x := by
      exact fun m hm => Continuous.continuousAt ( continuous_evalMonom m );
    choose! ε hε using fun m hm => Metric.continuousAt_iff.mp ( h_cont m hm ) ( δ / 2 ) ( half_pos hδ_pos );
    -- Let $\epsilon$ be the minimum of the $\epsilon_m$'s.
    obtain ⟨ε_min, hε_min⟩ : ∃ ε_min > 0, ∀ m ∈ s, ε_min ≤ ε m := by
      exact ⟨ Finset.min' ( s.image ε ) ⟨ _, Finset.mem_image_of_mem ε hs.choose_spec ⟩, by have := Finset.min'_mem ( s.image ε ) ⟨ _, Finset.mem_image_of_mem ε hs.choose_spec ⟩ ; aesop, fun m hm => Finset.min'_le _ _ <| Finset.mem_image_of_mem ε hm ⟩;
    exact ⟨ ε_min, hε_min.1, fun m hm y hy => hε m hm |>.2 <| by simpa [ dist_eq_norm, pi_norm_lt_iff hε_min.1 ] using hy |> fun h => lt_of_lt_of_le ( pi_norm_lt_iff hε_min.1 |>.2 h ) ( hε_min.2 m hm ) ⟩;
  -- By exists_all_distinct_near T x (min ε (δ/2)), get y near x where T-elements have distinct values.
  obtain ⟨y, hy₁, hy₂⟩ : ∃ y : Fin n → ℝ, (∀ i, |y i - x i| < min ε (δ / 2)) ∧ ∀ m₁ ∈ T, ∀ m₂ ∈ T, m₁ ≠ m₂ → evalMonom m₁ y ≠ evalMonom m₂ y := by
    exact exists_all_distinct_near T x _ ( lt_min hε_pos ( half_pos hδ_pos ) );
  -- Let $m^* = \argmin_{m \in T} evalMonom m y$. $m^*$ is unique minimizer among $T$ at $y$.
  obtain ⟨m_star, hm_star_T, hm_star_min⟩ : ∃ m_star ∈ T, ∀ m ∈ T, evalMonom m_star y ≤ evalMonom m y ∧ (∀ m' ∈ T, m' ≠ m_star → evalMonom m_star y < evalMonom m' y) := by
    obtain ⟨m_star, hm_star_T⟩ : ∃ m_star ∈ T, ∀ m ∈ T, evalMonom m_star y ≤ evalMonom m y := by
      exact Finset.exists_min_image _ _ hT_nonempty;
    exact ⟨ m_star, hm_star_T.1, fun m hm => ⟨ hm_star_T.2 m hm, fun m' hm' hm'_ne => lt_of_le_of_ne ( hm_star_T.2 m' hm' ) ( Ne.symm ( hy₂ _ hm' _ hm_star_T.1 hm'_ne ) ) ⟩ ⟩;
  refine' ⟨ m_star, ⟨ _, y, _ ⟩, _ ⟩;
  · exact Finset.mem_filter.mp hm_star_T |>.1;
  · grind +splitImp;
  · exact Finset.mem_filter.mp hm_star_T |>.2

lemma essential_nonempty {n : ℕ} (s : Finset (TropMonom n)) (hs : s.Nonempty) :
    (s.filter (fun m => IsEssential s m)).Nonempty := by
  obtain ⟨m, hm, _⟩ := essential_achieves_inf s hs 0
  exact ⟨m, mem_filter.mpr ⟨hm.1, hm⟩⟩

def essentialize {n : ℕ} (s : TropPolyNF n) : TropPolyNF n where
  terms := s.terms.filter (fun m => IsEssential s.terms m)
  nonempty := essential_nonempty s.terms s.nonempty

def normalize {n : ℕ} (e : TropExpr n) : TropPolyNF n := essentialize (expand e)

/-! ## NF Operation Soundness -/

lemma eval_addNF {n : ℕ} (s t : TropPolyNF n) (x : Fin n → ℝ) :
    evalNF (addNF s t) x = min (evalNF s x) (evalNF t x) := by
  unfold evalNF addNF; rw [Finset.inf'_union]

lemma inf'_product_add {α β : Type*} [DecidableEq α] [DecidableEq β]
    {S : Finset α} {T : Finset β} (hS : S.Nonempty) (hT : T.Nonempty)
    (f : α → ℝ) (g : β → ℝ) :
    (S ×ˢ T).inf' (hS.product hT) (fun p => f p.1 + g p.2) =
    S.inf' hS f + T.inf' hT g := by
  apply le_antisymm
  · rw [Finset.inf'_le_iff]
    obtain ⟨a, ha, ha'⟩ := Finset.exists_mem_eq_inf' hS f
    obtain ⟨b, hb, hb'⟩ := Finset.exists_mem_eq_inf' hT g
    exact ⟨(a, b), mem_product.mpr ⟨ha, hb⟩, by linarith⟩
  · exact Finset.le_inf' _ _ fun ⟨a, b⟩ hab => by
      simp only [mem_product] at hab
      exact add_le_add (Finset.inf'_le _ hab.1) (Finset.inf'_le _ hab.2)

lemma eval_mulNF {n : ℕ} (s t : TropPolyNF n) (x : Fin n → ℝ) :
    evalNF (mulNF s t) x = evalNF s x + evalNF t x := by
  convert inf'_product_add s.nonempty t.nonempty
    (fun m => evalMonom m x) (fun m => evalMonom m x) using 1
  unfold mulNF evalNF; rw [Finset.inf'_image]
  exact congr_arg _ (funext fun p => evalMonom_mulMonom _ _ _)

/-! ## Expansion Soundness -/

theorem expand_sound {n : ℕ} (e : TropExpr n) (x : Fin n → ℝ) :
    evalNF (expand e) x = evalExpr e x := by
  induction e with
  | const c => simp [evalNF, expand, evalExpr]
  | var i => exact evalMonom_var _ _
  | add _ _ ih₁ ih₂ => simp only [expand, evalExpr]; rw [eval_addNF, ih₁, ih₂]
  | mul _ _ ih₁ ih₂ => simp only [expand, evalExpr]; rw [eval_mulNF, ih₁, ih₂]

/-! ## Essentialization Soundness -/

theorem essentialize_sound {n : ℕ} (s : TropPolyNF n) (x : Fin n → ℝ) :
    evalNF (essentialize s) x = evalNF s x := by
  unfold evalNF; simp +decide [ essentialize ];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
  · intro a b hab;
    obtain ⟨ m, hm₁, hm₂ ⟩ := essential_achieves_inf s.terms s.nonempty x;
    exact ⟨ m.1, m.2, ⟨ hm₁.1, hm₁ ⟩, hm₂.symm ▸ Finset.inf'_le _ hab ⟩;
  · exact fun a b ha hb => ⟨ a, b, ha, le_rfl ⟩

/-! ## Completeness Helpers -/

lemma strict_min_neighborhood {n : ℕ} {s : Finset (TropMonom n)} {m : TropMonom n}
    {x₀ : Fin n → ℝ} (hm : m ∈ s)
    (hstrict : ∀ m' ∈ s, m' ≠ m → evalMonom m x₀ < evalMonom m' x₀) :
    ∃ ε > 0, ∀ x : Fin n → ℝ, (∀ i, |x i - x₀ i| < ε) →
      ∀ m' ∈ s, m' ≠ m → evalMonom m x < evalMonom m' x := by
  -- By continuity of $f(x) = evalMonom m' x - evalMonom m x$, there exists a $\delta > 0$ such that if $|x - x₀| < \delta$, then $f(x) > 0$.
  have h_cont : ∀ m' ∈ s, m' ≠ m → ∃ δ > 0, ∀ x : Fin n → ℝ, (∀ i, |x i - x₀ i| < δ) → evalMonom m x - evalMonom m' x < 0 := by
    intros m' hm' hne
    have h_cont : Continuous (fun x : Fin n → ℝ => evalMonom m x - evalMonom m' x) := by
      exact Continuous.sub ( continuous_evalMonom m ) ( continuous_evalMonom m' );
    have := Metric.continuous_iff.mp h_cont x₀;
    exact Exists.elim ( this ( evalMonom m' x₀ - evalMonom m x₀ ) ( sub_pos.mpr ( hstrict m' hm' hne ) ) ) fun δ hδ => ⟨ δ, hδ.1, fun x hx => by linarith [ abs_lt.mp ( hδ.2 x ( by simpa only [ dist_eq_norm, pi_norm_lt_iff hδ.1 ] using hx ) ) ] ⟩;
  choose! δ hδ_pos hδ using h_cont;
  by_cases h : ∃ m' ∈ s, m' ≠ m;
  · obtain ⟨ε, hε_pos, hε⟩ : ∃ ε > 0, ∀ m' ∈ s, m' ≠ m → ε ≤ δ m' := by
      exact ⟨ Finset.min' ( s.filter ( fun m' => m' ≠ m ) |> Finset.image δ ) ⟨ _, Finset.mem_image_of_mem δ ( Finset.mem_filter.mpr ⟨ h.choose_spec.1, h.choose_spec.2 ⟩ ) ⟩, by have := Finset.min'_mem ( s.filter ( fun m' => m' ≠ m ) |> Finset.image δ ) ⟨ _, Finset.mem_image_of_mem δ ( Finset.mem_filter.mpr ⟨ h.choose_spec.1, h.choose_spec.2 ⟩ ) ⟩ ; aesop, fun m' hm' hm'' => Finset.min'_le _ _ ( Finset.mem_image_of_mem δ ( Finset.mem_filter.mpr ⟨ hm', hm'' ⟩ ) ) ⟩;
    exact ⟨ ε, hε_pos, fun x hx m' hm' hm'' => by linarith [ hδ m' hm' hm'' x fun i => lt_of_lt_of_le ( hx i ) ( hε m' hm' hm'' ) ] ⟩;
  · exact ⟨ 1, zero_lt_one, fun x hx m' hm' hm'' => False.elim <| h ⟨ m', hm', hm'' ⟩ ⟩

lemma mem_of_inf_eq_on_ball {n : ℕ} {t : Finset (TropMonom n)} {m : TropMonom n}
    {x₀ : Fin n → ℝ} {ε : ℝ} (hε : 0 < ε) (ht : t.Nonempty)
    (h : ∀ x : Fin n → ℝ, (∀ i, |x i - x₀ i| < ε) →
      t.inf' ht (fun m' => evalMonom m' x) = evalMonom m x) :
    m ∈ t := by
  -- For each $m' \in t$, define the affine function $f_{m'}(x) = evalMonom m'(x) - evalMonom m(x)$.
  set f : TropMonom n → (Fin n → ℝ) → ℝ := fun m' x => evalMonom m' x - evalMonom m x;
  -- Since $f_{m'}(x₀) = 0$ for all $m' \in t$, and $f_{m'}$ is affine, the set $\{x \in \mathbb{R}^n \mid f_{m'}(x) = 0\}$ is a hyperplane.
  have h_hyperplane : ∀ m' ∈ t, m' ≠ m → ∃ c : ℝ, ∃ w : Fin n → ℝ, ¬(c = 0 ∧ w = 0) ∧ ∀ x : Fin n → ℝ, f m' x = c + ∑ i, w i * x i := by
    intro m' hm' hm'_ne_m
    use (m'.1 - m.1), fun i => (m'.2 i - m.2 i : ℝ);
    simp_all +decide [ funext_iff, sub_eq_iff_eq_add ];
    exact ⟨ fun h => by contrapose! hm'_ne_m; aesop, fun x => by rw [ show f m' x = evalMonom m' x - evalMonom m x from rfl ] ; rw [ evalMonom_sub ] ⟩;
  -- By the properties of hyperplanes, there exists a point $y$ in the ball around $x₀$ such that $f_{m'}(y) \neq 0$ for all $m' \in t$.
  obtain ⟨y, hy_ball, hy_ne⟩ : ∃ y : Fin n → ℝ, (∀ i, |y i - x₀ i| < ε) ∧ ∀ m' ∈ t, m' ≠ m → f m' y ≠ 0 := by
    choose! c w h_nonzero h_affine using h_hyperplane;
    have := ball_not_covered_by_hyperplanes x₀ ε hε ( t.filter ( fun m' => m' ≠ m ) |> Finset.image fun m' => ( c m', w m' ) ) ?_;
    · obtain ⟨ y, hy₁, hy₂ ⟩ := this; use y; simp_all +decide [ Finset.mem_image ] ;
      exact fun a b ha hb => hy₂ _ _ _ _ ha hb rfl rfl;
    · grind +splitImp;
  obtain ⟨ m', hm', hm'' ⟩ := Finset.exists_mem_eq_inf' ht ( fun m' => evalMonom m' y ) ; specialize hy_ne m' hm' ; aesop;

lemma essential_transfer {n : ℕ} {s t : Finset (TropMonom n)}
    (hs : s.Nonempty) (ht : t.Nonempty)
    (heq : ∀ x : Fin n → ℝ,
      s.inf' hs (fun m => evalMonom m x) = t.inf' ht (fun m => evalMonom m x))
    {m : TropMonom n} (hm : IsEssential s m) :
    IsEssential t m := by
  exact ⟨ by
    obtain ⟨ x₀, hx₀ ⟩ := hm.2;
    obtain ⟨ε, hε_pos, hε⟩ : ∃ ε > 0, ∀ x : Fin n → ℝ, (∀ i, |x i - x₀ i| < ε) → ∀ m' ∈ s, m' ≠ m → evalMonom m x < evalMonom m' x := strict_min_neighborhood hm.1 hx₀;
    apply mem_of_inf_eq_on_ball hε_pos ht;
    intro x hx;
    rw [ ← heq x, Finset.inf'_eq_csInf_image ];
    exact le_antisymm ( csInf_le ⟨ evalMonom m x, Set.forall_mem_image.2 fun m' hm' => if h : m' = m then h.symm ▸ le_rfl else le_of_lt ( hε x hx m' hm' h ) ⟩ ⟨ m, hm.1, rfl ⟩ ) ( le_csInf ⟨ evalMonom m x, Set.mem_image_of_mem _ hm.1 ⟩ <| Set.forall_mem_image.2 fun m' hm' => if h : m' = m then h.symm ▸ le_rfl else le_of_lt ( hε x hx m' hm' h ) ), by
    -- By strict_min_neighborhood, get ε > 0 ball where m strict min of s.
    obtain ⟨x₀, hx₀⟩ := hm.right
    obtain ⟨ε, hε_pos, hε⟩ := strict_min_neighborhood hm.left hx₀
    -- On ball, inf s = evalMonom m. By heq, inf t = evalMonom m on ball.
    have h_inf_t : ∀ x : Fin n → ℝ, (∀ i, |x i - x₀ i| < ε) → t.inf' ht (fun m' => evalMonom m' x) = evalMonom m x := by
      intro x hx; rw [ ← heq x ] ; exact (by
      exact le_antisymm ( Finset.inf'_le _ hm.1 ) ( Finset.le_inf' _ _ fun m' hm' => if h : m' = m then h.symm ▸ le_rfl else le_of_lt ( hε x hx m' hm' h ) ));
    -- By mem_of_inf_eq_on_ball, m ∈ t.
    have hm_t : m ∈ t := by
      exact mem_of_inf_eq_on_ball hε_pos ht h_inf_t
    generalize_proofs at *;
    -- By ball_not_covered_by_hyperplanes, find y where m' > m for all m' ≠ m in t.
    obtain ⟨y, hy⟩ : ∃ y : Fin n → ℝ, (∀ i, |y i - x₀ i| < ε) ∧ ∀ m' ∈ t, m' ≠ m → evalMonom m y < evalMonom m' y := by
      -- Define the set of affine functions corresponding to the differences between m and other monomials in t.
      set affines : Finset (ℝ × (Fin n → ℝ)) := Finset.image (fun m' => (m.1 - m'.1, fun i => (m.2 i : ℝ) - (m'.2 i : ℝ))) (t.filter (fun m' => m' ≠ m)) with h_affines_def
      generalize_proofs at *;
      -- By ball_not_covered_by_hyperplanes, find y where all affine functions are non-zero.
      obtain ⟨y, hy⟩ : ∃ y : Fin n → ℝ, (∀ i, |y i - x₀ i| < ε) ∧ ∀ p ∈ affines, p.1 + ∑ i, p.2 i * y i ≠ 0 := by
        apply ball_not_covered_by_hyperplanes x₀ ε hε_pos affines
        generalize_proofs at *;
        simp +zetaDelta at *;
        intro a b x y hx hy ha hb; contrapose! hy; simp_all +decide [ funext_iff ] ;
        exact Prod.ext ( by linarith ) ( by ext i; exact_mod_cast sub_eq_zero.mp ( hb i ) |> Eq.symm )
      generalize_proofs at *;
      use y; simp_all +decide [ evalMonom_sub ] ;
      intro a b ha hb; specialize hy; have := hy.2 ( m.1 - a ) ( fun i => ( m.2 i : ℝ ) - b i ) a b ha hb rfl rfl; simp_all +decide [ evalMonom ] ;
      contrapose! this; simp_all +decide [ sub_mul, Finset.sum_add_distrib ] ;
      exact le_antisymm ( by linarith [ h_inf_t y hy.1 ▸ Finset.inf'_le _ ha ] ) ( by linarith [ h_inf_t y hy.1 ▸ Finset.inf'_le _ ha ] )
    generalize_proofs at *;
    use y;
    intro m' hm' hm'_ne;
    aesop; ⟩

/-! ## Main Theorems -/

theorem essentialize_complete {n : ℕ} {s t : TropPolyNF n}
    (h : ∀ x : Fin n → ℝ, evalNF s x = evalNF t x) :
    essentialize s = essentialize t := by
  ext1; apply Finset.ext; intro m
  simp only [essentialize, Finset.mem_filter]
  constructor
  · rintro ⟨_, hm⟩
    exact ⟨(essential_transfer s.nonempty t.nonempty h hm).1,
           essential_transfer s.nonempty t.nonempty h hm⟩
  · rintro ⟨_, hm⟩
    exact ⟨(essential_transfer t.nonempty s.nonempty (fun x => (h x).symm) hm).1,
           essential_transfer t.nonempty s.nonempty (fun x => (h x).symm) hm⟩

theorem normalize_sound {n : ℕ} (e : TropExpr n) (x : Fin n → ℝ) :
    evalNF (normalize e) x = evalExpr e x := by
  unfold normalize; rw [essentialize_sound, expand_sound]

theorem normalize_complete {n : ℕ} {e₁ e₂ : TropExpr n}
    (h : ∀ x : Fin n → ℝ, evalExpr e₁ x = evalExpr e₂ x) :
    normalize e₁ = normalize e₂ := by
  apply essentialize_complete; intro x; rw [expand_sound, expand_sound, h]

theorem normalize_injective {n : ℕ} {e₁ e₂ : TropExpr n}
    (h : normalize e₁ = normalize e₂) :
    ∀ x : Fin n → ℝ, evalExpr e₁ x = evalExpr e₂ x := by
  intro x; rw [← normalize_sound e₁, ← normalize_sound e₂, h]

/-- Two tropical expressions are semantically equivalent iff they have the
    same normal form. -/
theorem normalize_iff {n : ℕ} {e₁ e₂ : TropExpr n} :
    (∀ x : Fin n → ℝ, evalExpr e₁ x = evalExpr e₂ x) ↔
    normalize e₁ = normalize e₂ :=
  ⟨normalize_complete, normalize_injective⟩

/-! ## Certified Bounds -/

theorem monomial_upper_bound {n : ℕ} (p : TropPolyNF n) (m : TropMonom n)
    (hm : m ∈ p.terms) (x : Fin n → ℝ) :
    evalNF p x ≤ evalMonom m x :=
  Finset.inf'_le (fun m => evalMonom m x) hm

theorem essential_witness {n : ℕ} {s : Finset (TropMonom n)} {m : TropMonom n}
    (hs : s.Nonempty) (hm : IsEssential s m) :
    ∃ x : Fin n → ℝ, s.inf' hs (fun m' => evalMonom m' x) = evalMonom m x := by
  exact ⟨ hm.2.choose, le_antisymm ( Finset.inf'_le _ hm.1 ) ( Finset.le_inf' _ _ fun m' hm' => le_of_not_gt fun hnm' => by linarith [ hm.2.choose_spec m' hm' ( by aesop ) ] ) ⟩

end TropicalCNF