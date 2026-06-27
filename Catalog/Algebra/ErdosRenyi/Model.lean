/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Erdős–Rényi random graph model `G(n, p)` — model and first moment method

We give a fully finite, measure-free formalization of the Erdős–Rényi model.
A *configuration* is an edge-indicator function `g : E → Bool`, where `E` is a
finite type of potential edges.  The `p`-biased law assigns to a configuration
`g` the weight

  `weight p g = ∏ e, (if g e then p else 1 - p)`,

i.e. each edge is independently present with probability `p`.  Probabilities of
events (finsets of configurations) and expectations of random variables are then
ordinary finite sums.

## Main results

* `ErdosRenyi.sum_weight` — the law is a probability measure: `∑ g, weight p g = 1`.
* `ErdosRenyi.prob_allPresent` — independence: the probability that every edge of
  a set `S` is present equals `p ^ |S|`.
* `ErdosRenyi.prob_allAbsent` — dually, the probability that every edge of `S` is
  absent equals `(1 - p) ^ |S|`.
* `ErdosRenyi.expectation_subgraphCount` — linearity of expectation for subgraph
  counts: the expected number of "copies" with prescribed edge sets `S i` equals
  `∑ i, p ^ |S i|`.
* `ErdosRenyi.expectation_subgraphCount_uniform` — for copies all of size `k`,
  the expected count is `(#copies) · p ^ k` (the basic first–moment quantity that
  governs subgraph thresholds).
* `ErdosRenyi.firstMoment` — the first moment method: the probability that at least
  one copy appears is at most `∑ i, p ^ |S i|`.  In particular it vanishes as the
  expected count tends to `0`, which is the "below threshold" half of every
  monotone subgraph threshold.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the Erdős–Rényi law can be captured without any
  measure-theoretic machinery as a `p`-biased product weight on the finite cube
  `E → Bool`, and the textbook "independence" and "linearity of expectation"
  identities are then pure `Finset` algebra (`Finset.prod_univ_sum`,
  `Finset.sum_comm`).  A bolder sub-hypothesis: the same proof yields *both* the
  all-present probability `p^|S|` and the all-absent probability `(1-p)^|S|` by the
  symmetry `p ↔ 1-p`.
Experiment (Stage 2): `sum_weight` is `Finset.prod_univ_sum` specialised to the
  two-point fibres `{p, 1-p}` whose column sums are `p + (1-p) = 1`.  The
  independence identity factors the weight product over `S` and its complement and
  collapses the complement sum to `1` by the same column-sum trick.
Analysis (Stage 3): the identities hold for *every* real `p` (no `0 ≤ p ≤ 1`
  needed) — positivity is only required for the Markov inequality `firstMoment`,
  where weights must be nonnegative.  This cleanly separates the algebraic
  (combinatorial identity) content from the order-theoretic (probabilistic
  inequality) content.
Critique (Stage 4): the theorems are genuine identities/inequalities proved by
  `induction`/`Finset` manipulation, not `decide`/`rfl`; `firstMoment` is a real
  Markov bound (the engine behind "no copies below threshold").  The sharp
  *asymptotic* connectivity/giant-component thresholds are deliberately NOT claimed
  here; they are recorded in `FUTURE_DIRECTIONS.md`.
Synthesis (Stage 5): this file is the algebraic core of `G(n,p)`; the companion
  files develop the second-moment method (`SecondMoment.lean`) and concrete
  vertex/triangle expectations (`Concrete.lean`).
-/
import Mathlib

open Finset BigOperators

namespace ErdosRenyi

variable {E : Type*} [Fintype E] [DecidableEq E]

/-- The `p`-biased weight of an edge configuration `g : E → Bool`: each present
edge contributes a factor `p`, each absent edge a factor `1 - p`. -/
noncomputable def weight (p : ℝ) (g : E → Bool) : ℝ :=
  ∏ e : E, (if g e then p else 1 - p)

omit [DecidableEq E] in
/-- Weights are nonnegative when `p ∈ [0,1]`. -/
theorem weight_nonneg {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) (g : E → Bool) :
    0 ≤ weight p g := by
  apply Finset.prod_nonneg
  intro e _
  split <;> linarith

/-- The Erdős–Rényi law is a probability measure: the weights sum to `1`. -/
theorem sum_weight (p : ℝ) : ∑ g : E → Bool, weight p g = 1 := by
  -- The sum over all functions $g : E → Bool$ can be rewritten as a product of sums over each $e ∈ E$.
  have h_sum : ∑ g : E → Bool, (∏ e : E, (if g e then p else 1 - p)) = ∏ e : E, (∑ g : Bool, (if g then p else 1 - p)) := by
    exact Eq.symm (Fintype.prod_sum fun i j => if j = true then p else 1 - p);
  aesop

/-- Probability of an event (a finset of configurations). -/
noncomputable def prob (p : ℝ) (A : Finset (E → Bool)) : ℝ := ∑ g ∈ A, weight p g

/-- Expectation of a real random variable. -/
noncomputable def expectation (p : ℝ) (X : (E → Bool) → ℝ) : ℝ :=
  ∑ g : E → Bool, weight p g * X g

/-- The event that every edge in `S` is present. -/
def allPresent (S : Finset E) : Finset (E → Bool) :=
  Finset.univ.filter (fun g => ∀ e ∈ S, g e = true)

/-- The event that every edge in `S` is absent. -/
def allAbsent (S : Finset E) : Finset (E → Bool) :=
  Finset.univ.filter (fun g => ∀ e ∈ S, g e = false)

/-- **Independence.** The probability that all edges of `S` are present is `p ^ |S|`. -/
theorem prob_allPresent (p : ℝ) (S : Finset E) :
    prob p (allPresent S) = p ^ S.card := by
  -- The sum of the weights over the configurations where all edges in S are present can be factored into the product of the weights over S and the sum of the weights over the complement of S.
  have h_factor : ∑ g ∈ allPresent S, weight p g = (∏ e ∈ S, p) * ∑ g : {e : E // e ∉ S} → Bool, ∏ e : {e : E // e ∉ S}, (if g e then p else 1 - p) := by
    have h_factor : ∑ g ∈ allPresent S, weight p g = ∑ g ∈ Finset.univ.filter (fun g : E → Bool => ∀ e ∈ S, g e = true), (∏ e ∈ S, p) * (∏ e ∈ Finset.univ \ S, (if g e then p else 1 - p)) := by
      refine' Finset.sum_congr _ _;
      · rfl;
      · intro g hg; rw [ weight ] ; rw [ ← Finset.prod_sdiff ( Finset.subset_univ S ) ] ; simp_all +decide [ Finset.prod_ite ] ;
        ring;
    rw [ h_factor, Finset.mul_sum _ _ _ ];
    refine' Finset.sum_bij ( fun g hg => fun e => g e ) _ _ _ _ <;> simp +decide [ Finset.prod_ite ];
    · intro a₁ ha₁ a₂ ha₂ h; ext e; by_cases he : e ∈ S <;> simp_all +decide [ funext_iff ] ;
    · intro b; use fun e => if h : e ∈ S then true else b ⟨ e, h ⟩ ; aesop;
    · intro g hg; left; congr! 2;
      · refine' Finset.card_bij ( fun x hx => ⟨ x, by aesop ⟩ ) _ _ _ <;> aesop;
      · refine' Finset.card_bij ( fun x hx => ⟨ x, by aesop ⟩ ) _ _ _ <;> aesop;
  -- The sum of the weights over the complement of S is equal to 1, since it is the sum of the weights over all possible configurations of the complement of S.
  have h_sum_complement : ∑ g : {e : E // e ∉ S} → Bool, ∏ e : {e : E // e ∉ S}, (if g e then p else 1 - p) = 1 := by
    convert sum_weight p using 1;
  aesop

/-- **Independence (dual).** The probability that all edges of `S` are absent is
`(1 - p) ^ |S|`.
-/
theorem prob_allAbsent (p : ℝ) (S : Finset E) :
    prob p (allAbsent S) = (1 - p) ^ S.card := by
  -- Consider the symmetric case where the event is that every edge in `S` is present.
  have h_symm : prob (1 - p) (allPresent S) = (1 - p) ^ S.card := by
    exact prob_allPresent (1 - p) S
  simp_all +decide [ prob, allPresent, allAbsent ];
  convert h_symm using 1;
  apply Finset.sum_bij (fun g _ => fun e => !g e);
  · aesop;
  · simp +contextual [ funext_iff ];
  · exact fun g hg => ⟨ fun e => !g e, by aesop ⟩;
  · grind +locals

/-- The number of "copies" present in `g`, where copy `i` occupies edge set `S i`. -/
noncomputable def subgraphCount {ι : Type*} [Fintype ι] (S : ι → Finset E)
    (g : E → Bool) : ℕ :=
  (Finset.univ.filter (fun i => ∀ e ∈ S i, g e = true)).card

/-- **Linearity of expectation** for subgraph counts: the expected number of copies
present equals `∑ i, p ^ |S i|`.
-/
theorem expectation_subgraphCount {ι : Type*} [Fintype ι] (p : ℝ) (S : ι → Finset E) :
    expectation p (fun g => (subgraphCount S g : ℝ)) = ∑ i, p ^ (S i).card := by
  -- The expectation of the subgraph count can be expressed using the indicator function as:
  have h_indicator : (expectation p (fun g => (subgraphCount S g : ℝ))) = ∑ i, ∑ g : E → Bool, (weight p g) * (if (∀ e ∈ (S i), (g e) = true) then 1 else 0) := by
    rw [ Finset.sum_comm, expectation ];
    simp +decide [ subgraphCount, Finset.sum_ite ];
    ac_rfl;
  simp_all +decide [ Finset.sum_ite ];
  convert Finset.sum_congr rfl fun i _ => prob_allPresent p ( S i ) using 1

/-- When every copy uses exactly `k` edges, the expected count is `(#copies) · p ^ k`. -/
theorem expectation_subgraphCount_uniform {ι : Type*} [Fintype ι] (p : ℝ)
    (S : ι → Finset E) (k : ℕ) (hk : ∀ i, (S i).card = k) :
    expectation p (fun g => (subgraphCount S g : ℝ)) = (Fintype.card ι : ℝ) * p ^ k := by
  simp_all +decide [ expectation_subgraphCount ]

/-- **First moment method.** The probability that at least one copy appears is at
most the expected number of copies `∑ i, p ^ |S i|`.  Hence if the expected count
is `< 1`, copies are unlikely; this is the "below threshold" direction.
-/
theorem firstMoment {ι : Type*} [Fintype ι] (p : ℝ) (h0 : 0 ≤ p) (h1 : p ≤ 1)
    (S : ι → Finset E) :
    prob p (Finset.univ.filter (fun g => 1 ≤ subgraphCount S g)) ≤ ∑ i, p ^ (S i).card := by
  -- By definition of expectation, we know that the expectation of the subgraph count is equal to the sum of p^(S_i).card.
  have h_expectation : expectation p (fun g => (subgraphCount S g : ℝ)) = ∑ i, p ^ (S i).card := by
    convert expectation_subgraphCount p S using 1;
  rw [ ← h_expectation, expectation ];
  refine' le_trans _ ( Finset.sum_le_sum fun g _ => mul_le_mul_of_nonneg_left ( Nat.cast_le.mpr <| show subgraphCount S g ≥ if 1 ≤ subgraphCount S g then 1 else 0 from _ ) <| weight_nonneg h0 h1 g );
  · simp +decide [ prob, Finset.sum_ite ];
  · split_ifs <;> linarith

end ErdosRenyi