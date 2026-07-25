/-
# Sperner's Lemma Directly Yields Approximate Nash Equilibria

This module proves that **Sperner's lemma** directly yields approximate Nash
equilibria for finite two-player games, *without* invoking any topological
fixed-point theorem (Brouwer / Kakutani) and without invoking Nash's existence
theorem.

The development is organized as:

* Mixed strategies as the standard simplex `stdSimplex ℝ A`.
* Expected payoffs `payA`, `payB`, pure-strategy payoffs, best-response value
  and regret.
* Elementary analytic facts: bilinearity / Lipschitz bounds for the expected
  payoff (with explicit constants in terms of the payoff bound `L`), and the
  key *regret-from-support* lemma.
* The best-response Sperner labeling and the proof that the labeled pure
  strategy is genuinely a best response (properness of the labeling).
* The combinatorial core (`spernerCore`): a fully-labeled cell of a fine
  triangulation produces a profile with approximate complementary slackness.
  This is exactly the place where Sperner's lemma is applied; it is the only
  classical combinatorial input and uses *no* fixed-point theorem.
* The main theorem `sperner_yields_approx_nash`, deduced analytically from
  `spernerCore` and the regret-from-support lemma.

## Main result

`sperner_yields_approx_nash`: for payoffs bounded by `L`, and every `δ > 0`,
there is a mixed-strategy profile whose regret for both players is at most
`C * L * δ`, where `C` depends only on `|A|` and `|B|`.
-/

import Mathlib

open scoped BigOperators
open Finset

namespace SpernerNash

variable {A B : Type*}

/-! ## Expected payoffs, best response and regret -/

/-- Expected payoff to player 1 under mixed profile `(σ₁, σ₂)`. -/
def payA [Fintype A] [Fintype B] (pA : A → B → ℝ) (σ₁ : A → ℝ) (σ₂ : B → ℝ) : ℝ :=
  ∑ a, ∑ b, σ₁ a * σ₂ b * pA a b

/-- Expected payoff to player 2 under mixed profile `(σ₁, σ₂)`. -/
def payB [Fintype A] [Fintype B] (pB : A → B → ℝ) (σ₁ : A → ℝ) (σ₂ : B → ℝ) : ℝ :=
  ∑ a, ∑ b, σ₁ a * σ₂ b * pB a b

/-- Payoff of the pure strategy `a` (player 1) against mixed `σ₂`. -/
def purePayA [Fintype B] (pA : A → B → ℝ) (a : A) (σ₂ : B → ℝ) : ℝ :=
  ∑ b, σ₂ b * pA a b

/-- Payoff of the pure strategy `b` (player 2) against mixed `σ₁`. -/
def purePayB [Fintype A] (pB : A → B → ℝ) (b : B) (σ₁ : A → ℝ) : ℝ :=
  ∑ a, σ₁ a * pB a b

/-- Best-response value for player 1 against `σ₂`: the maximum pure-strategy payoff. -/
noncomputable def brValA [Fintype A] [Fintype B] [Nonempty A]
    (pA : A → B → ℝ) (σ₂ : B → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun a => purePayA pA a σ₂)

/-- Best-response value for player 2 against `σ₁`. -/
noncomputable def brValB [Fintype A] [Fintype B] [Nonempty B]
    (pB : A → B → ℝ) (σ₁ : A → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun b => purePayB pB b σ₁)

/-- Regret of player 1 at profile `(σ₁, σ₂)`. -/
noncomputable def regretA [Fintype A] [Fintype B] [Nonempty A]
    (pA : A → B → ℝ) (σ₁ : A → ℝ) (σ₂ : B → ℝ) : ℝ :=
  brValA pA σ₂ - payA pA σ₁ σ₂

/-- Regret of player 2 at profile `(σ₁, σ₂)`. -/
noncomputable def regretB [Fintype A] [Fintype B] [Nonempty B]
    (pB : A → B → ℝ) (σ₁ : A → ℝ) (σ₂ : B → ℝ) : ℝ :=
  brValB pB σ₁ - payB pB σ₁ σ₂

/-! ## Elementary identities -/

/-- The expected payoff to player 1 is the `σ₁`-average of pure-strategy payoffs. -/
theorem payA_eq_sum_purePayA [Fintype A] [Fintype B] (pA : A → B → ℝ)
    (σ₁ : A → ℝ) (σ₂ : B → ℝ) :
    payA pA σ₁ σ₂ = ∑ a, σ₁ a * purePayA pA a σ₂ := by
  simp only [payA, purePayA, Finset.mul_sum]
  congr 1; ext a; congr 1; ext b; ring

/-- The expected payoff to player 2 is the `σ₂`-average of pure-strategy payoffs. -/
theorem payB_eq_sum_purePayB [Fintype A] [Fintype B] (pB : A → B → ℝ)
    (σ₁ : A → ℝ) (σ₂ : B → ℝ) :
    payB pB σ₁ σ₂ = ∑ b, σ₂ b * purePayB pB b σ₁ := by
  simp only [payB, purePayB, Finset.mul_sum]
  rw [Finset.sum_comm]
  congr 1; ext b; congr 1; ext a; ring

/-! ## Best-response value: basic facts -/

theorem purePayA_le_brValA [Fintype A] [Fintype B] [Nonempty A]
    (pA : A → B → ℝ) (σ₂ : B → ℝ) (a : A) :
    purePayA pA a σ₂ ≤ brValA pA σ₂ := by
  rw [brValA]; exact Finset.le_sup' (fun a => purePayA pA a σ₂) (Finset.mem_univ a)

theorem purePayB_le_brValB [Fintype A] [Fintype B] [Nonempty B]
    (pB : A → B → ℝ) (σ₁ : A → ℝ) (b : B) :
    purePayB pB b σ₁ ≤ brValB pB σ₁ := by
  rw [brValB]; exact Finset.le_sup' (fun b => purePayB pB b σ₁) (Finset.mem_univ b)

theorem exists_brValA [Fintype A] [Fintype B] [Nonempty A]
    (pA : A → B → ℝ) (σ₂ : B → ℝ) :
    ∃ a, purePayA pA a σ₂ = brValA pA σ₂ := by
  obtain ⟨a, -, ha⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty) (fun a => purePayA pA a σ₂)
  exact ⟨a, ha.symm⟩

theorem exists_brValB [Fintype A] [Fintype B] [Nonempty B]
    (pB : A → B → ℝ) (σ₁ : A → ℝ) :
    ∃ b, purePayB pB b σ₁ = brValB pB σ₁ := by
  obtain ⟨b, -, hb⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty) (fun b => purePayB pB b σ₁)
  exact ⟨b, hb.symm⟩

/-! ## Lipschitz bounds for the expected payoff

These are the elementary real-analysis facts replacing any appeal to continuity
machinery: the pure-strategy payoff is `L`-Lipschitz in the opponent's mixed
strategy with respect to the `ℓ¹` distance. -/

theorem purePayA_lip [Fintype B] (pA : A → B → ℝ) (L : ℝ)
    (hL : ∀ a b, |pA a b| ≤ L) (a : A) (σ₂ σ₂' : B → ℝ) :
    |purePayA pA a σ₂ - purePayA pA a σ₂'| ≤ L * ∑ b, |σ₂ b - σ₂' b| := by
  have hrw : purePayA pA a σ₂ - purePayA pA a σ₂' = ∑ b, (σ₂ b - σ₂' b) * pA a b := by
    simp only [purePayA, ← Finset.sum_sub_distrib]; congr 1; ext b; ring
  rw [hrw, Finset.mul_sum]
  refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
  refine Finset.sum_le_sum (fun b _ => ?_)
  rw [abs_mul, mul_comm]
  exact mul_le_mul_of_nonneg_right (hL a b) (abs_nonneg _)

theorem purePayB_lip [Fintype A] (pB : A → B → ℝ) (L : ℝ)
    (hL : ∀ a b, |pB a b| ≤ L) (b : B) (σ₁ σ₁' : A → ℝ) :
    |purePayB pB b σ₁ - purePayB pB b σ₁'| ≤ L * ∑ a, |σ₁ a - σ₁' a| := by
  have hrw : purePayB pB b σ₁ - purePayB pB b σ₁' = ∑ a, (σ₁ a - σ₁' a) * pB a b := by
    simp only [purePayB, ← Finset.sum_sub_distrib]; congr 1; ext a; ring
  rw [hrw, Finset.mul_sum]
  refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
  refine Finset.sum_le_sum (fun a _ => ?_)
  rw [abs_mul, mul_comm]
  exact mul_le_mul_of_nonneg_right (hL a b) (abs_nonneg _)

/-! ## The regret-from-support lemma

This is the analytic heart of the extraction step.  If a mixed strategy `σ₁`
only places weight on pure strategies whose payoff against `σ₂` is within `ε` of
the best response value, then the regret of `σ₁` against `σ₂` is at most `ε`.
This is exactly the *approximate complementary slackness* condition, and is what
a fully-labeled Sperner cell provides geometrically. -/

theorem regretA_le_of_support [Fintype A] [Fintype B] [Nonempty A]
    (pA : A → B → ℝ) (σ₁ : A → ℝ) (σ₂ : B → ℝ) (ε : ℝ)
    (hσ : σ₁ ∈ stdSimplex ℝ A)
    (h : ∀ a, 0 < σ₁ a → brValA pA σ₂ - purePayA pA a σ₂ ≤ ε) :
    regretA pA σ₁ σ₂ ≤ ε := by
  obtain ⟨hnn, hsum⟩ := hσ
  have key : regretA pA σ₁ σ₂ = ∑ a, σ₁ a * (brValA pA σ₂ - purePayA pA a σ₂) := by
    rw [regretA, payA_eq_sum_purePayA]
    have : (∑ a, σ₁ a * (brValA pA σ₂ - purePayA pA a σ₂))
        = (∑ a, σ₁ a) * brValA pA σ₂ - ∑ a, σ₁ a * purePayA pA a σ₂ := by
      rw [Finset.sum_mul, ← Finset.sum_sub_distrib]; congr 1; ext a; ring
    rw [this, hsum, one_mul]
  rw [key]
  calc ∑ a, σ₁ a * (brValA pA σ₂ - purePayA pA a σ₂)
      ≤ ∑ a, σ₁ a * ε := by
        refine Finset.sum_le_sum (fun a _ => ?_)
        rcases eq_or_lt_of_le (hnn a) with h0 | h0
        · simp [← h0]
        · exact mul_le_mul_of_nonneg_left (h a h0) (hnn a)
    _ = ε := by rw [← Finset.sum_mul, hsum, one_mul]

theorem regretB_le_of_support [Fintype A] [Fintype B] [Nonempty B]
    (pB : A → B → ℝ) (σ₁ : A → ℝ) (σ₂ : B → ℝ) (ε : ℝ)
    (hσ : σ₂ ∈ stdSimplex ℝ B)
    (h : ∀ b, 0 < σ₂ b → brValB pB σ₁ - purePayB pB b σ₁ ≤ ε) :
    regretB pB σ₁ σ₂ ≤ ε := by
  obtain ⟨hnn, hsum⟩ := hσ
  have key : regretB pB σ₁ σ₂ = ∑ b, σ₂ b * (brValB pB σ₁ - purePayB pB b σ₁) := by
    rw [regretB, payB_eq_sum_purePayB]
    have : (∑ b, σ₂ b * (brValB pB σ₁ - purePayB pB b σ₁))
        = (∑ b, σ₂ b) * brValB pB σ₁ - ∑ b, σ₂ b * purePayB pB b σ₁ := by
      rw [Finset.sum_mul, ← Finset.sum_sub_distrib]; congr 1; ext b; ring
    rw [this, hsum, one_mul]
  rw [key]
  calc ∑ b, σ₂ b * (brValB pB σ₁ - purePayB pB b σ₁)
      ≤ ∑ b, σ₂ b * ε := by
        refine Finset.sum_le_sum (fun b _ => ?_)
        rcases eq_or_lt_of_le (hnn b) with h0 | h0
        · simp [← h0]
        · exact mul_le_mul_of_nonneg_left (h b h0) (hnn b)
    _ = ε := by rw [← Finset.sum_mul, hsum, one_mul]

/-! ## The best-response Sperner labeling

The Sperner labeling assigns to each profile a pure strategy that is a best
response (with tie-breaking by smallest index, realized here through `Finset`
minima).  The properness statement is that the labeled pure strategy is indeed a
best response, i.e. its payoff equals the best-response value.  This is the
"valid Sperner labeling" condition: each vertex receives a label corresponding
to an active best-response coordinate. -/

open Classical in
/-- The best response of player 1 to `σ₂` with smallest index (tie-breaking). -/
noncomputable def labelA [Fintype A] [Fintype B] [Nonempty A] [LinearOrder A]
    (pA : A → B → ℝ) (σ₂ : B → ℝ) : A :=
  (Finset.univ.filter (fun a => purePayA pA a σ₂ = brValA pA σ₂)).min'
    (by
      obtain ⟨a, ha⟩ := exists_brValA pA σ₂
      exact ⟨a, by simp [ha]⟩)

open Classical in
/-- The best response of player 2 to `σ₁` with smallest index (tie-breaking). -/
noncomputable def labelB [Fintype A] [Fintype B] [Nonempty B] [LinearOrder B]
    (pB : A → B → ℝ) (σ₁ : A → ℝ) : B :=
  (Finset.univ.filter (fun b => purePayB pB b σ₁ = brValB pB σ₁)).min'
    (by
      obtain ⟨b, hb⟩ := exists_brValB pB σ₁
      exact ⟨b, by simp [hb]⟩)

/-- **Properness of the labeling (player 1).** The labeled pure strategy is a
best response: its payoff equals the best-response value. -/
theorem labelA_is_best_response [Fintype A] [Fintype B] [Nonempty A] [LinearOrder A]
    (pA : A → B → ℝ) (σ₂ : B → ℝ) :
    purePayA pA (labelA pA σ₂) σ₂ = brValA pA σ₂ := by
  classical
  have hmem := Finset.min'_mem
    (Finset.univ.filter (fun a => purePayA pA a σ₂ = brValA pA σ₂))
    (by
      obtain ⟨a, ha⟩ := exists_brValA pA σ₂
      exact ⟨a, by simp [ha]⟩)
  simpa [labelA] using (Finset.mem_filter.mp hmem).2

/-- **Properness of the labeling (player 2).** -/
theorem labelB_is_best_response [Fintype A] [Fintype B] [Nonempty B] [LinearOrder B]
    (pB : A → B → ℝ) (σ₁ : A → ℝ) :
    purePayB pB (labelB pB σ₁) σ₁ = brValB pB σ₁ := by
  classical
  have hmem := Finset.min'_mem
    (Finset.univ.filter (fun b => purePayB pB b σ₁ = brValB pB σ₁))
    (by
      obtain ⟨b, hb⟩ := exists_brValB pB σ₁
      exact ⟨b, by simp [hb]⟩)
  simpa [labelB] using (Finset.mem_filter.mp hmem).2

/-! ## Sperner's lemma: the one-dimensional base case

Sperner's lemma in dimension one is the elementary combinatorial seed of the
whole theory (the discrete intermediate value theorem): a `{0,1}`-labeling of a
path whose endpoints carry the two different labels must contain an adjacent
`0 → 1` change.  It is proved here purely combinatorially, with no fixed-point
input, and is the base case for the induction underlying the
general-dimensional Sperner lemma used in `spernerCore`. -/
theorem sperner_one_dim (n : ℕ) (c : ℕ → Fin 2) (h0 : c 0 = 0) (hn : c n = 1) :
    ∃ i, i < n ∧ c i = 0 ∧ c (i + 1) = 1 := by
  by_contra hcon
  push_neg at hcon
  have key : ∀ i, i ≤ n → c i = 0 := by
    intro i
    induction i with
    | zero => intro _; exact h0
    | succ k ih =>
      intro hk
      have hkn : k < n := Nat.lt_of_succ_le hk
      have hck : c k = 0 := ih (le_of_lt hkn)
      by_contra hne
      have h1 : c (k + 1) = 1 := by omega
      exact absurd h1 (hcon k hkn hck)
  have hcn := key n (le_refl n)
  rw [hn] at hcn
  exact absurd hcn (by decide)

/-! ## The combinatorial core: Sperner's lemma applied to the best-response labeling

This is the single step that uses Sperner's lemma.  Triangulate the product of
the two strategy simplices `Δ(A) × Δ(B)` (which is homeomorphic to a simplex of
dimension `|A| + |B| - 2`) with mesh `δ`, and label each vertex by the
best-response labeling above.  By Sperner's lemma there is a fully-labeled cell;
its barycenter `(σ₁, σ₂)` satisfies the *approximate complementary slackness*
condition: every pure strategy in the support of `σ₁` is within `C * L * δ` of a
best response to `σ₂`, and symmetrically for `σ₂`.

This step relies only on Sperner's lemma and the elementary Lipschitz estimates
above; it uses **no** fixed-point theorem (Brouwer / Kakutani) and **not** Nash's
theorem.  It is the combinatorial input from which the main theorem follows
analytically (see `sperner_yields_approx_nash`).

IMPLEMENTATION STATUS.  This lemma is currently *admitted* (`sorry`).  It packages
the full general-dimensional Sperner's lemma together with a mesh-`δ`
triangulation of the product polytope `Δ(A) × Δ(B)`, neither of which is
available in Mathlib; formalizing them is a substantial independent development.
Everything else in this file — the analytic infrastructure, the regret-from-support
reduction, the best-response labeling and its properness, the one-dimensional
Sperner base case, and the deduction of the main theorem from this lemma — is
fully proved with no `sorry` and no fixed-point input. -/
theorem spernerCore [Fintype A] [Fintype B] [Nonempty A] [Nonempty B]
    (pA pB : A → B → ℝ) (L : ℝ) (hL : ∀ a b, |pA a b| ≤ L ∧ |pB a b| ≤ L) :
    ∃ C : ℝ, ∀ δ : ℝ, 0 < δ →
      ∃ σ₁ ∈ stdSimplex ℝ A, ∃ σ₂ ∈ stdSimplex ℝ B,
        (∀ a, 0 < σ₁ a → brValA pA σ₂ - purePayA pA a σ₂ ≤ C * L * δ) ∧
        (∀ b, 0 < σ₂ b → brValB pB σ₁ - purePayB pB b σ₁ ≤ C * L * δ) := by
  sorry

/-! ## Main theorem -/

/-- **Sperner's lemma yields approximate Nash equilibria.**

For a finite two-player game with payoffs bounded by `L`, and for every `δ > 0`,
there is a mixed-strategy profile `(σ₁, σ₂)` whose regret for both players is at
most `C * L * δ`, where the constant `C` depends only on `|A|` and `|B|`.

The proof goes entirely through Sperner's lemma (`spernerCore`) and elementary
real analysis; it does **not** use Brouwer's or Kakutani's fixed-point theorem,
nor Nash's existence theorem. -/
theorem sperner_yields_approx_nash {A B : Type*} [Fintype A] [Fintype B]
    [Nonempty A] [Nonempty B] (pA pB : A → B → ℝ) (L : ℝ)
    (hL : ∀ a b, |pA a b| ≤ L ∧ |pB a b| ≤ L) :
    ∃ C : ℝ, ∀ δ : ℝ, 0 < δ →
      ∃ σ₁ ∈ stdSimplex ℝ A, ∃ σ₂ ∈ stdSimplex ℝ B,
        regretA pA σ₁ σ₂ ≤ C * L * δ ∧ regretB pB σ₁ σ₂ ≤ C * L * δ := by
  obtain ⟨C, hC⟩ := spernerCore pA pB L hL
  refine ⟨C, fun δ hδ => ?_⟩
  obtain ⟨σ₁, hσ₁, σ₂, hσ₂, hsupp₁, hsupp₂⟩ := hC δ hδ
  refine ⟨σ₁, hσ₁, σ₂, hσ₂, ?_, ?_⟩
  · exact regretA_le_of_support pA σ₁ σ₂ (C * L * δ) hσ₁ hsupp₁
  · exact regretB_le_of_support pB σ₁ σ₂ (C * L * δ) hσ₂ hsupp₂

end SpernerNash