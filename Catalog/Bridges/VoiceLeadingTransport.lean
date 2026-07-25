/-
# Voice-Leading as Discrete Optimal Transport

This file formalizes the connection between voice-leading in counterpoint
and discrete optimal transport on ℤ. The core result is that for two-voice
sonorities with ordered pitches, the optimal 1-Wasserstein matching is
always order-preserving (the "monotone coupling theorem"), and the
voice-leading cost equals the transport cost.

## Main results

* `ordered_matching_optimal` — the ordered (voice-preserving) matching has
  cost ≤ the crossing matching, under ordering constraints.
* `W1TwoPoint_eq_orderedVL` — the 1-Wasserstein cost between two-atom
  measures equals the ordered voice-leading cost.
* `pathCost_eq_sum_W1` — the total melodic cost of a counterpoint path
  equals the sum of pairwise 1-Wasserstein costs.
* `sorted_matching_optimal` — generalization to k voices: sorted matching
  minimizes total transport cost among all permutations.
* `transportAction_lipschitz_in_cantus` — Lipschitz stability of the
  transport action under cantus perturbation.
-/

import Mathlib

open Finset BigOperators

/-! ## Two-voice voice-leading cost -/

/-- Ordered voice-leading cost: each voice moves to the corresponding voice. -/
def orderedVL (p q : ℤ × ℤ) : ℤ :=
  |p.1 - q.1| + |p.2 - q.2|

/-- Crossing voice-leading cost: voices swap partners. -/
def crossingVL (p q : ℤ × ℤ) : ℤ :=
  |p.1 - q.2| + |p.2 - q.1|

/-- The 1-Wasserstein cost between two two-atom measures: the minimum
of the ordered and crossing matchings. -/
def W1TwoPoint (p q : ℤ × ℤ) : ℤ :=
  min (orderedVL p q) (crossingVL p q)

/-! ## Core monotone coupling theorem -/

/-
**Monge inequality on the line**: For ordered pairs (a₁ ≤ b₁) and (a₂ ≤ b₂),
the order-preserving matching has cost at most the crossing matching.
This is the fundamental inequality underlying the monotone transport theorem.
-/
theorem ordered_matching_optimal
    (a₁ b₁ a₂ b₂ : ℤ)
    (h₁ : a₁ ≤ b₁) (h₂ : a₂ ≤ b₂) :
    orderedVL (a₁, b₁) (a₂, b₂) ≤ crossingVL (a₁, b₁) (a₂, b₂) := by
  grind +locals

/-
The 1-Wasserstein cost between ordered two-atom measures equals the
ordered voice-leading cost.
-/
theorem W1TwoPoint_eq_orderedVL
    (a₁ b₁ a₂ b₂ : ℤ)
    (h₁ : a₁ ≤ b₁) (h₂ : a₂ ≤ b₂) :
    W1TwoPoint (a₁, b₁) (a₂, b₂) = orderedVL (a₁, b₁) (a₂, b₂) := by
  exact min_eq_left ( ordered_matching_optimal a₁ b₁ a₂ b₂ h₁ h₂ )

/-! ## Path-level transport action -/

/-- A sonority at time i is a pair (cantus firmus pitch, counterpoint pitch). -/
def sonority (cf cp : Fin (n + 1) → ℤ) (i : Fin (n + 1)) : ℤ × ℤ := (cf i, cp i)

/-- The total melodic path cost: sum of ordered voice-leading costs over time. -/
def pathCost {n : ℕ} (cf cp : Fin (n + 1) → ℤ) : ℤ :=
  ∑ i : Fin n, orderedVL (sonority cf cp (Fin.castSucc i)) (sonority cf cp i.succ)

/-
The path cost equals the sum of 1-Wasserstein costs when voices are ordered.
-/
theorem pathCost_eq_sum_W1
    {n : ℕ}
    (cf cp : Fin (n + 1) → ℤ)
    (hord : ∀ i, cf i ≤ cp i) :
    pathCost cf cp =
      ∑ i : Fin n, W1TwoPoint (sonority cf cp (Fin.castSucc i))
          (sonority cf cp i.succ) := by
  exact Finset.sum_congr rfl fun i _ => W1TwoPoint_eq_orderedVL _ _ _ _ ( hord _ ) ( hord _ ) ▸ rfl

/-! ## k-voice sorted matching optimality (rearrangement inequality) -/

/-
**Sorted matching optimality for k voices**: Among all permutations,
the identity matching minimizes the total absolute-value transport cost
when both sequences are monotone. This is the discrete monotone coupling
theorem for k-atom measures on ℤ.
-/
theorem sorted_matching_optimal
    {k : ℕ} (x y : Fin k → ℤ)
    (hx : Monotone x) (hy : Monotone y)
    (σ : Equiv.Perm (Fin k)) :
    (∑ i, |x i - y i|) ≤ ∑ i, |x i - y (σ i)| := by
  -- By induction on $k$, we can show that the sum of absolute differences is minimized when the sequences are paired in the same order.
  induction' k with k ih;
  · norm_num;
  · -- Consider two cases: $\sigma(k) = k$ and $\sigma(k) \ne k$.
    by_cases hσk : σ (Fin.last k) = Fin.last k;
    · -- Since $\sigma(k) = k$, we can restrict $\sigma$ to a permutation of $\{0, 1, ..., k-1\}$.
      obtain ⟨σ', hσ'⟩ : ∃ σ' : Equiv.Perm (Fin k), ∀ i : Fin k, σ (Fin.castSucc i) = Fin.castSucc (σ' i) := by
        have h_restrict : ∀ i : Fin k, σ (Fin.castSucc i) ≠ Fin.last k := by
          exact fun i hi => by have := σ.injective ( hi.trans hσk.symm ) ; exact absurd this ( ne_of_lt ( Fin.castSucc_lt_last i ) ) ;
        have h_restrict : ∀ i : Fin k, ∃ j : Fin k, σ (Fin.castSucc i) = Fin.castSucc j := by
          exact fun i => ⟨ ⟨ σ ( Fin.castSucc i ) |> Fin.val, lt_of_le_of_ne ( Fin.le_last _ ) ( by simpa [ Fin.ext_iff ] using h_restrict i ) ⟩, by simp +decide [ Fin.ext_iff ] ⟩;
        choose f hf using h_restrict;
        have h_inj : Function.Injective f := by
          intro i j hij; have := σ.injective ( by aesop : σ ( Fin.castSucc i ) = σ ( Fin.castSucc j ) ) ; aesop;
        exact ⟨ Equiv.ofBijective f ⟨ h_inj, Finite.injective_iff_surjective.mp h_inj ⟩, hf ⟩;
      have := ih ( fun i => x ( Fin.castSucc i ) ) ( fun i => y ( Fin.castSucc i ) ) ( fun i j hij => hx hij ) ( fun i j hij => hy hij ) σ';
      simp_all +decide [ Fin.sum_univ_castSucc ];
    · -- Since $\sigma(k) \ne k$, there exists some $j < k$ such that $\sigma(j) = k$.
      obtain ⟨j, hj⟩ : ∃ j : Fin k, σ (Fin.castSucc j) = Fin.last k := by
        by_contra h_contra; push_neg at h_contra; (
        have := σ.surjective ( Fin.last k ) ; rcases this with ⟨ j, hj ⟩ ; cases h : j using Fin.lastCases <;> simp_all +decide ;);
      -- Consider the permutation $\sigma'$ obtained by swapping $\sigma(j)$ and $\sigma(k)$.
      set σ' : Equiv.Perm (Fin (k + 1)) := σ * Equiv.swap (Fin.castSucc j) (Fin.last k);
      -- By the properties of the swap, we have $\sum_{i=0}^{k} |x_i - y_{\sigma'(i)}| \leq \sum_{i=0}^{k} |x_i - y_{\sigma(i)}|$.
      have h_swap : ∑ i : Fin (k + 1), |x i - y (σ' i)| ≤ ∑ i : Fin (k + 1), |x i - y (σ i)| := by
        have h_swap : |x (Fin.castSucc j) - y (σ' (Fin.castSucc j))| + |x (Fin.last k) - y (σ' (Fin.last k))| ≤ |x (Fin.castSucc j) - y (σ (Fin.castSucc j))| + |x (Fin.last k) - y (σ (Fin.last k))| := by
          simp +zetaDelta at *;
          rw [ hj ];
          cases abs_cases ( x ( Fin.castSucc j ) - y ( σ ( Fin.last k ) ) ) <;> cases abs_cases ( x ( Fin.last k ) - y ( Fin.last k ) ) <;> cases abs_cases ( x ( Fin.castSucc j ) - y ( Fin.last k ) ) <;> cases abs_cases ( x ( Fin.last k ) - y ( σ ( Fin.last k ) ) ) <;> linarith [ hx ( show Fin.castSucc j ≤ Fin.last k from Fin.le_last _ ), hy ( show σ ( Fin.last k ) ≤ Fin.last k from Fin.le_last _ ) ];
        have h_swap : ∑ i ∈ Finset.univ \ {Fin.castSucc j, Fin.last k}, |x i - y (σ' i)| = ∑ i ∈ Finset.univ \ {Fin.castSucc j, Fin.last k}, |x i - y (σ i)| := by
          refine' Finset.sum_congr rfl fun i hi => _;
          simp +zetaDelta at *;
          rw [ Equiv.swap_apply_def ] ; aesop;
        simp_all +decide [ Finset.sum_pair, Finset.sum_sdiff ];
        linarith;
      -- By the induction hypothesis, we have $\sum_{i=0}^{k-1} |x_i - y_{\sigma'(i)}| \geq \sum_{i=0}^{k-1} |x_i - y_i|$.
      have h_ind : ∑ i : Fin k, |x (Fin.castSucc i) - y (σ' (Fin.castSucc i))| ≥ ∑ i : Fin k, |x (Fin.castSucc i) - y (Fin.castSucc i)| := by
        have h_ind : ∃ σ'' : Equiv.Perm (Fin k), ∀ i : Fin k, σ' (Fin.castSucc i) = Fin.castSucc (σ'' i) := by
          have h_ind : ∀ i : Fin k, σ' (Fin.castSucc i) ≠ Fin.last k := by
            intro i hi; have := σ.injective ( hi.trans hj.symm ) ; simp_all +decide [ Equiv.swap_apply_def ] ;
            split_ifs at this <;> simp_all +decide [ Fin.ext_iff ];
          have h_ind : ∀ i : Fin k, ∃ j : Fin k, σ' (Fin.castSucc i) = Fin.castSucc j := by
            exact fun i => ⟨ ⟨ σ' ( Fin.castSucc i ) |> Fin.val, lt_of_le_of_ne ( Fin.le_last _ ) ( by simpa [ Fin.ext_iff ] using h_ind i ) ⟩, by simp +decide [ Fin.ext_iff ] ⟩;
          choose f hf using h_ind;
          have h_ind : Function.Injective f := by
            intro i j hij; have := σ'.injective ( by aesop : σ' ( Fin.castSucc i ) = σ' ( Fin.castSucc j ) ) ; aesop;
          exact ⟨ Equiv.ofBijective f ⟨ h_ind, Finite.injective_iff_surjective.mp h_ind ⟩, hf ⟩;
        obtain ⟨ σ'', hσ'' ⟩ := h_ind; specialize ih ( fun i => x ( Fin.castSucc i ) ) ( fun i => y ( Fin.castSucc i ) ) ( fun i j hij => hx hij ) ( fun i j hij => hy hij ) σ''; aesop;
      simp_all +decide [ Fin.sum_univ_castSucc ];
      simp +zetaDelta at *;
      grind

/-! ## Stability theorems -/

/-- Sup-norm distance between two sequences over Fin n. -/
noncomputable def supNormFin {n : ℕ} (f g : Fin n → ℤ) : ℤ :=
  if h : Finset.univ (α := Fin n) = ∅ then 0
  else Finset.sup' Finset.univ (Finset.nonempty_iff_ne_empty.mpr h) (fun i => |f i - g i|)

/-
Auxiliary: orderedVL is Lipschitz in each argument.
-/
theorem orderedVL_lipschitz_fst (a₁ a₂ b c d : ℤ) :
    |orderedVL (a₁, b) (c, d) - orderedVL (a₂, b) (c, d)| ≤ |a₁ - a₂| := by
  unfold orderedVL;
  grind +splitImp

/-
Auxiliary: orderedVL is Lipschitz in the second-slot first coordinate.
-/
theorem orderedVL_lipschitz_third (a b c₁ c₂ d : ℤ) :
    |orderedVL (a, b) (c₁, d) - orderedVL (a, b) (c₂, d)| ≤ |c₁ - c₂| := by
  unfold orderedVL;
  grind

/-
**Lipschitz stability of the transport action under cantus perturbation.**
Changing the cantus firmus in sup-norm by δ changes the path cost by at most 2n·δ.
-/
theorem transportAction_lipschitz_in_cantus
    {n : ℕ}
    (cf₁ cf₂ cp : Fin (n + 1) → ℤ) :
    |pathCost cf₁ cp - pathCost cf₂ cp|
      ≤ 2 * (n : ℤ) * supNormFin cf₁ cf₂ := by
  -- By the triangle inequality for sums, we have:
  have h_triangle : |pathCost cf₁ cp - pathCost cf₂ cp| ≤ ∑ i : Fin n, |orderedVL (sonority cf₁ cp (Fin.castSucc i)) (sonority cf₁ cp i.succ) - orderedVL (sonority cf₂ cp (Fin.castSucc i)) (sonority cf₂ cp i.succ)| := by
    convert Finset.abs_sum_le_sum_abs _ _ using 2 ; aesop;
    infer_instance;
  -- By the triangle inequality for absolute values, we have:
  have h_triangle_ineq : ∀ i : Fin n, |orderedVL (sonority cf₁ cp (Fin.castSucc i)) (sonority cf₁ cp i.succ) - orderedVL (sonority cf₂ cp (Fin.castSucc i)) (sonority cf₂ cp i.succ)| ≤ |cf₁ (Fin.castSucc i) - cf₂ (Fin.castSucc i)| + |cf₁ i.succ - cf₂ i.succ| := by
    intros i
    simp [orderedVL, sonority];
    grind +qlia;
  -- By definition of supNormFin, we have:
  have h_supNormFin : ∀ i : Fin (n + 1), |cf₁ i - cf₂ i| ≤ supNormFin cf₁ cf₂ := by
    unfold supNormFin;
    simp +decide [ Finset.ext_iff ];
    exact fun i => ⟨ i, le_rfl ⟩;
  refine le_trans h_triangle <| le_trans ( Finset.sum_le_sum fun i _ => h_triangle_ineq i ) ?_;
  exact le_trans ( Finset.sum_le_sum fun _ _ => add_le_add ( h_supNormFin _ ) ( h_supNormFin _ ) ) ( by norm_num; linarith )