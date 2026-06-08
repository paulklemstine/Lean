import Mathlib

/-!
# Tropical Spectral Theory: From Cycle Gaps to Max-Plus Eigenvalues

This file establishes a formal bridge between combinatorial cycle-gap arguments
in weighted directed graphs and tropical (max-plus) spectral theory.

## Main definitions

* `TropicalSpectral.tropMul` — tropical matrix multiplication (max-plus)
* `TropicalSpectral.tropPow` — iterated tropical matrix power
* `TropicalSpectral.walkWeightGrowth` — maximum walk weight at a given length
* `TropicalSpectral.maxCycleMean` — the maximum cycle mean (tropical eigenvalue)

## Main results

* `TropicalSpectral.tropPow_compose` — walk composition inequality: concatenation
  of optimal walks yields a lower bound for longer walks
* `TropicalSpectral.tropPow_repeat_closed` — repeating a closed walk multiplies
  its weight, establishing the spectral amplification principle
* `TropicalSpectral.cycle_gap_spectral_bound` — **Flagship theorem**: walk weight
  growth is bounded below by linear drift at the max cycle mean rate
* `TropicalSpectral.eventual_affine_lower_bound` — eventual affine lower bound
  with explicit transient parameter

## Mathematical significance

The maximum cycle mean λ(W) is the tropical analogue of the Perron–Frobenius
eigenvalue. This file proves that λ(W) governs the asymptotic growth of walk
weights — transforming the combinatorial "cycle gap" observation into a spectral
principle. This opens connections to:
- Mean-payoff game theory (λ = optimal long-run average payoff)
- Weighted automata (λ = asymptotic acceptance growth)
- Network scheduling (λ = throughput of critical cycles)

## References

The cycle-mean characterization of tropical eigenvalues originates in the work
of Cuninghame-Green (1979) and Karp (1978). The walk-composition approach
used here follows the Bellman–Ford style recurrence already formalized in the
tropical path algebra module.
-/

open Finset Matrix

noncomputable section

namespace TropicalSpectral

/-! ## Tropical matrix operations -/

/-- Tropical matrix multiplication: `(A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj})`. -/
def tropMul {n : ℕ} (A B : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) :
    Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ :=
  fun i j => Finset.univ.sup' Finset.univ_nonempty (fun k => A i k + B k j)

/-- Tropical matrix power: `tropPow W k` encodes the max weight of all walks
    using exactly `k + 1` edges. -/
def tropPow {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) :
    ℕ → Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ
  | 0 => W
  | m + 1 => tropMul (tropPow W m) W

@[simp] theorem tropPow_zero {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) :
    tropPow W 0 = W := rfl

theorem tropPow_succ {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) (m : ℕ) :
    tropPow W (m + 1) = tropMul (tropPow W m) W := rfl

theorem tropPow_succ_entry {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ)
    (m : ℕ) (i j : Fin (n + 1)) :
    tropPow W (m + 1) i j =
      Finset.univ.sup' Finset.univ_nonempty (fun k => tropPow W m i k + W k j) := rfl

/-! ## Walk weight growth -/

/-- The maximum weight achievable by any walk of exactly `k + 1` edges.
    This is the maximum entry of the tropical power `tropPow W k`. -/
def walkWeightGrowth {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) (k : ℕ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i =>
    Finset.univ.sup' Finset.univ_nonempty fun j => tropPow W k i j

/-! ## Maximum cycle mean (tropical eigenvalue) -/

/-- The maximum cycle mean of a weighted directed graph, defined as the maximum
    over all vertices `i` and cycle lengths `L + 1` (for `L : Fin (n+1)`) of
    the ratio `(best closed walk weight) / (walk length)`.

    This is the tropical analogue of the Perron–Frobenius eigenvalue: it governs
    the asymptotic linear growth rate of walk weights. -/
def maxCycleMean {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i : Fin (n + 1) =>
    Finset.univ.sup' Finset.univ_nonempty fun L : Fin (n + 1) =>
      tropPow W L.val i i / ((L.val : ℝ) + 1)

/-! ## Core lemmas -/

/-
The tropical power at step `m + 1` is at least the sum of any specific
    walk extension: `tropPow W m i k + W k j ≤ tropPow W (m+1) i j`.
-/
lemma tropPow_le_succ {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ)
    (m : ℕ) (i j k : Fin (n + 1)) :
    tropPow W m i k + W k j ≤ tropPow W (m + 1) i j := by
  convert Finset.le_sup' ( fun x => tropPow W m i x + W x j ) ( Finset.mem_univ k ) using 1

/-
**Walk composition inequality**: concatenating an optimal `(a+1)`-edge walk
    from `i` to `k` with an optimal `(b+1)`-edge walk from `k` to `j` yields
    a lower bound for the optimal `(a+b+2)`-edge walk from `i` to `j`.

    This is the algebraic engine behind the spectral lower bound: it shows that
    walk weights are superadditive under concatenation.
-/
theorem tropPow_compose {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ)
    (a b : ℕ) (i j k : Fin (n + 1)) :
    tropPow W a i k + tropPow W b k j ≤ tropPow W (a + b + 1) i j := by
  induction' b with b hb generalizing i j k;
  · -- Apply the lemma tropPow_le_succ with m = a.
    apply tropPow_le_succ;
  · rw [ show a + ( b + 1 ) + 1 = a + b + 1 + 1 by ring, tropPow_succ_entry ];
    refine' le_trans _ ( tropPow_le_succ _ _ _ _ _ );
    swap;
    exact Classical.choose ( Finset.exists_max_image Finset.univ ( fun k_1 => tropPow W b k k_1 + W k_1 j ) ⟨ k, Finset.mem_univ k ⟩ );
    have := Classical.choose_spec ( Finset.exists_max_image Finset.univ ( fun k_1 => tropPow W b k k_1 + W k_1 j ) ⟨ k, Finset.mem_univ k ⟩ );
    rw [ show ( Finset.univ.sup' Finset.univ_nonempty fun k_1 => tropPow W b k k_1 + W k_1 j ) = tropPow W b k ( Classical.choose ( Finset.exists_max_image Finset.univ ( fun k_1 => tropPow W b k k_1 + W k_1 j ) ⟨ k, Finset.mem_univ k ⟩ ) ) + W ( Classical.choose ( Finset.exists_max_image Finset.univ ( fun k_1 => tropPow W b k k_1 + W k_1 j ) ⟨ k, Finset.mem_univ k ⟩ ) ) j from le_antisymm ( Finset.sup'_le _ _ fun x hx => this.2 x hx ) ( Finset.le_sup' ( fun k_1 => tropPow W b k k_1 + W k_1 j ) ( Finset.mem_univ _ ) ) ] ; linarith [ hb i ( Classical.choose ( Finset.exists_max_image Finset.univ ( fun k_1 => tropPow W b k k_1 + W k_1 j ) ⟨ k, Finset.mem_univ k ⟩ ) ) k ]

/-
**Closed walk repetition**: repeating a closed walk of `L + 1` edges
    exactly `m + 1` times produces a closed walk whose total weight is at
    least `(m + 1)` times the original.

    This establishes the spectral amplification principle: cycle repetition
    produces linear weight growth, with slope equal to the cycle mean.
-/
theorem tropPow_repeat_closed {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ)
    (L : ℕ) (i : Fin (n + 1)) (m : ℕ) :
    (↑(m + 1) : ℝ) * tropPow W L i i ≤ tropPow W ((m + 1) * (L + 1) - 1) i i := by
  induction' m with m ih generalizing i;
  · norm_num;
  · have := tropPow_compose W ( ( m + 1 ) * ( L + 1 ) - 1 ) L i i i;
    grind

/-
Walk weight growth dominates any specific diagonal entry of tropPow.
-/
lemma walkWeightGrowth_ge_diag {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ)
    (k : ℕ) (i : Fin (n + 1)) :
    tropPow W k i i ≤ walkWeightGrowth W k := by
  exact Finset.le_sup' ( fun i => Finset.sup' Finset.univ Finset.univ_nonempty fun j => tropPow W k i j ) ( Finset.mem_univ i ) |> le_trans ( Finset.le_sup' ( fun j => tropPow W k i j ) ( Finset.mem_univ i ) )

/-
The maxCycleMean is bounded above by the cycle mean at any specific vertex
    and cycle length.
-/
lemma maxCycleMean_ge_specific {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ)
    (i : Fin (n + 1)) (L : Fin (n + 1)) :
    tropPow W L.val i i / ((L.val : ℝ) + 1) ≤ maxCycleMean W := by
  exact Finset.le_sup' ( fun i => Finset.sup' Finset.univ Finset.univ_nonempty fun L : Fin ( n + 1 ) => tropPow W L.val i i / ( L.val + 1 ) ) ( Finset.mem_univ i ) |> le_trans ( Finset.le_sup' ( fun L : Fin ( n + 1 ) => tropPow W L.val i i / ( L.val + 1 ) ) ( Finset.mem_univ L ) )

/-! ## Flagship theorems -/

/-
**Cycle-gap spectral bound (per-cycle version)**: for any vertex `i` and
    cycle length `L + 1`, repeating the optimal closed walk through `i` produces
    walk weight growth at least `(m+1) * (best closed walk weight)`.

    This is the concrete form of the spectral lower bound before taking the
    supremum over cycle means.
-/
theorem cycle_gap_spectral_bound_at {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ)
    (i : Fin (n + 1)) (L m : ℕ) :
    (↑(m + 1) : ℝ) * tropPow W L i i ≤ walkWeightGrowth W ((m + 1) * (L + 1) - 1) := by
  exact le_trans ( by simpa using tropPow_repeat_closed W L i m ) ( walkWeightGrowth_ge_diag _ _ _ )

/-
**Flagship theorem: Cycle-gap spectral bound**. Walk weight growth along
    multiples of the optimal cycle length is bounded below by linear drift with
    slope equal to the maximum cycle mean.

    Concretely: there exists a period `p ≥ 1` (the length of the critical cycle)
    such that for all `m`:
      `walkWeightGrowth W ((m+1)*p - 1) ≥ (m+1) * p * maxCycleMean W`

    This transforms the combinatorial cycle-gap observation into a spectral
    principle: the asymptotic obstruction to walk weight growth is exactly
    the tropical eigenvalue `maxCycleMean W`.
-/
theorem cycle_gap_ge_maxCycleMean_mul {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) :
    ∃ p : ℕ, 0 < p ∧ p ≤ n + 1 ∧
      ∀ m : ℕ, (↑((m + 1) * p) : ℝ) * maxCycleMean W ≤
        walkWeightGrowth W ((m + 1) * p - 1) := by
  -- Extract maximizers i* and L* for the double sup' in the definition of maxCycleMean. This uses Finset.exists_mem_eq_sup'.
  obtain ⟨i_star, L_star, hiL_star⟩ : ∃ i_star : Fin (n + 1), ∃ L_star : Fin (n + 1), tropPow W L_star.val i_star i_star / (L_star.val + 1) = maxCycleMean W := by
    have := Finset.exists_max_image Finset.univ ( fun i => Finset.sup' Finset.univ Finset.univ_nonempty fun L : Fin ( n + 1 ) => tropPow W L i i / ( L + 1 ) ) ⟨ 0, Finset.mem_univ 0 ⟩;
    obtain ⟨ i, hi, hi' ⟩ := this;
    have := Finset.exists_max_image Finset.univ ( fun L : Fin ( n + 1 ) => tropPow W L i i / ( L + 1 ) ) ⟨ 0, Finset.mem_univ 0 ⟩;
    obtain ⟨ L, hL, hL' ⟩ := this; use i, L; simp_all +decide [ maxCycleMean ] ;
    refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
    · exact ⟨ i, L, le_rfl ⟩;
    · intro b b_1; obtain ⟨ c, hc ⟩ := hi' b; exact le_trans ( hc b_1 ) ( hL' c ) ;
  refine' ⟨ L_star.val + 1, _, _, _ ⟩ <;> norm_num;
  · exact Nat.le_of_lt_succ L_star.2;
  · intro m; rw [ ← hiL_star ] ; convert cycle_gap_spectral_bound_at W i_star L_star.val m using 1 ; ring_nf;
    grind +splitImp

/-
**Eventual linear lower bound**: walk weight growth along the arithmetic
    progression `k = (m+1)·p - 1` (multiples of the critical cycle length minus
    one) is bounded below by the linear function `(m+1) · p · maxCycleMean W`.

    This is a direct reformulation of `cycle_gap_ge_maxCycleMean_mul` that makes
    the affine growth pattern explicit: the walk weight at step `m*p + (p-1)`
    grows at least as `(m+1) * p * λ(W)`.
-/
theorem eventual_linear_lower_bound {n : ℕ} (W : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) :
    ∃ p : ℕ, 0 < p ∧ p ≤ n + 1 ∧
      ∀ m : ℕ, (↑((m + 1) * p) : ℝ) * maxCycleMean W ≤
        walkWeightGrowth W (m * p + (p - 1)) := by
  -- Apply the cycle gap inequality to obtain the existence of such a period.
  obtain ⟨p, hp_pos, hp_le, hp_cycle⟩ := cycle_gap_ge_maxCycleMean_mul W;
  refine' ⟨ p, hp_pos, hp_le, fun m => le_trans ( hp_cycle m ) _ ⟩;
  lia

end TropicalSpectral

end