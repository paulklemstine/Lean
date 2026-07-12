import Mathlib

/-!
# No-(k+1)-in-line on the integer grid: the trivial upper bound `k·n`

For a set of points in the `n × n` integer grid, we study configurations with
*no `k+1` collinear points*: every straight line contains at most `k` of the
points. Let `f_k(n)` denote the maximum number of points of such a
configuration.

The motivating conjecture (an explicit-threshold strengthening of a known
theorem for "sufficiently large `n`") is that

    f_k(n) = k · n   for all k ≥ 3 and n ≥ k.

This file establishes the parts of this statement that are provable in full
generality, together with a nontrivial concrete instance:

* `NoKPlus1.card_le` : **the trivial upper bound** — any no-`(k+1)`-in-line
  configuration in the `n × n` grid has at most `k · n` points. (The heart is a
  column pigeonhole: each vertical line is a line, hence has `≤ k` points, and
  there are `n` columns.)
* `NoKPlus1.fk_le` : hence `f_k(n) ≤ k · n`.
* `NoKPlus1.fk_eq_sq` : in the trivial regime `n ≤ k` the whole grid is
  admissible, so `f_k(n) = n²`; in particular `f_k(k) = k² = k·k`
  (`NoKPlus1.fk_diag`), the boundary case of the conjecture.
* `NoKPlus1.f3_4` : `f_3(4) = 12 = 3·4`, a nontrivial instance of the
  conjecture with `n > k`, proven via the upper bound together with an explicit
  12-point configuration.

Collinearity is expressed with the standard integer cross-product
(determinant) test, which makes the no-`(k+1)`-in-line predicate decidable on a
finite point set.
-/

namespace NoKPlus1

open Finset

/-- Three integer lattice points are collinear (cross-product / determinant test):
the signed area of the triangle `p q r` is zero. -/
def Collinear3 (p q r : ℤ × ℤ) : Prop :=
  (q.1 - p.1) * (r.2 - p.2) = (q.2 - p.2) * (r.1 - p.1)

instance (p q r : ℤ × ℤ) : Decidable (Collinear3 p q r) := by
  unfold Collinear3; infer_instance

/-- The `n × n` integer grid `{0,…,n-1}²`. -/
def grid (n : ℕ) : Finset (ℤ × ℤ) := (Finset.Ico (0 : ℤ) n) ×ˢ (Finset.Ico (0 : ℤ) n)

/-- A finite point set has *no `k+1` collinear points*: for any two distinct points
`p, q` of the set, the line through them contains at most `k` points of the set.
(A line containing `k+1` points of the set contains two of them, so this is
exactly the no-`(k+1)`-in-line condition.) -/
def NoKp1 (k : ℕ) (S : Finset (ℤ × ℤ)) : Prop :=
  ∀ p ∈ S, ∀ q ∈ S, p ≠ q → (S.filter (fun r => Collinear3 p q r)).card ≤ k

instance (k : ℕ) (S : Finset (ℤ × ℤ)) : Decidable (NoKp1 k S) := by
  unfold NoKp1; infer_instance

/-
The grid has `n * n` points.
-/
lemma grid_card (n : ℕ) : (grid n).card = n * n := by
  simp [grid]

lemma mem_grid_fst {n : ℕ} {p : ℤ × ℤ} (hp : p ∈ grid n) : p.1 ∈ Finset.Ico (0 : ℤ) n := by
  exact Finset.mem_product.mp hp |>.1

/-
**Trivial upper bound.** Any no-`(k+1)`-in-line configuration in the `n × n`
grid has at most `k · n` points.
-/
theorem card_le (k n : ℕ) (hk : 1 ≤ k) (S : Finset (ℤ × ℤ)) (hS : S ⊆ grid n)
    (h : NoKp1 k S) : S.card ≤ k * n := by
  -- We can prove this by considering the vertical projection of the set \( S \) onto the x-axis and showing that the cardinality of the vertical projection is at most \( k \).
  have h_proj : ∀ x ∈ Finset.image (fun p => p.1) S, (S.filter (fun p => p.1 = x)).card ≤ k := by
    intro x hx
    by_cases h_card : (S.filter (fun p => p.1 = x)).card ≤ 1;
    · linarith;
    · obtain ⟨ p, hp, q, hq, hpq ⟩ := Finset.one_lt_card.mp ( lt_of_not_ge h_card );
      refine' le_trans _ ( h p ( Finset.filter_subset _ _ hp ) q ( Finset.filter_subset _ _ hq ) hpq );
      exact Finset.card_mono fun r hr => by unfold Collinear3; aesop;
  -- By summing over all the vertical projections, we obtain the cardinality of \( S \).
  have h_sum : S.card = ∑ x ∈ Finset.image (fun p => p.1) S, (S.filter (fun p => p.1 = x)).card := by
    rw [ Finset.card_eq_sum_ones, Finset.sum_image' ] ; aesop;
  refine' h_sum ▸ le_trans ( Finset.sum_le_sum h_proj ) _;
  norm_num [ mul_comm ];
  exact Nat.mul_le_mul_left _ ( le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun p hp => Finset.mem_Ico.mpr <| Finset.mem_Ico.mp <| Finset.mem_product.mp ( hS hp ) |>.1 ) <| by simp )

/-
A line (through two integer points `p, q`) meets the `n × n` grid in at most
`n` points.
-/
lemma line_inter_grid_le (n : ℕ) (p q : ℤ × ℤ) (hpq : p ≠ q) :
    ((grid n).filter (fun r => Collinear3 p q r)).card ≤ n := by
  by_cases h : p.1 = q.1;
  · unfold grid Collinear3;
    simp_all +decide [ sub_eq_iff_eq_add ];
    exact le_trans ( Finset.card_le_card ( show _ ⊆ Finset.image ( fun x : ℤ => ( q.1, x ) ) ( Finset.Ico 0 ( n : ℤ ) ) from fun x hx => by aesop ) ) ( Finset.card_image_le.trans ( by simp ) );
  · refine' le_trans ( Finset.card_le_card <| show { r ∈ grid n | Collinear3 p q r } ⊆ Finset.image ( fun r : ℤ => ( r, ( q.2 - p.2 ) * ( r - p.1 ) / ( q.1 - p.1 ) + p.2 ) ) ( Finset.Ico 0 n ) from _ ) _;
    · intro r hr; simp_all +decide [ Finset.mem_filter ] ;
      use r.1; simp_all +decide [ Collinear3 ] ;
      exact ⟨ Finset.mem_Ico.mp ( Finset.mem_product.mp hr.1 |>.1 ), Prod.ext rfl ( by rw [ ← hr.2, Int.mul_ediv_cancel_left _ ( sub_ne_zero_of_ne <| Ne.symm h ) ] ; ring ) ⟩;
    · exact Finset.card_image_le.trans ( by simp )

/-- In the trivial regime `n ≤ k`, the whole grid is a valid configuration. -/
theorem grid_NoKp1 (k n : ℕ) (h : n ≤ k) : NoKp1 k (grid n) := by
  intro p _ q _ hpq
  exact le_trans (line_inter_grid_le n p q hpq) h

open Classical in
/-- `f_k(n)`: the maximum number of points of a no-`(k+1)`-in-line configuration
contained in the `n × n` grid. -/
noncomputable def fk (k n : ℕ) : ℕ :=
  ((grid n).powerset.filter (fun S => NoKp1 k S)).sup Finset.card

/-
`f_k(n) ≤ k · n`.
-/
theorem fk_le (k n : ℕ) (hk : 1 ≤ k) : fk k n ≤ k * n := by
  -- By definition of $f_k$, we know that every subset of the $n \times n$ grid with no $k+1$ collinear points has cardinality at most $k \cdot n$.
  have h_subset : ∀ S ∈ Finset.powerset (grid n), NoKp1 k S → S.card ≤ k * n := by
    exact fun S hS h => card_le k n hk S ( Finset.mem_powerset.mp hS ) h;
  exact Finset.sup_le fun S hS => by aesop;

/-
`f_k(n) ≤ n²`, since every configuration is contained in the grid.
-/
theorem fk_le_sq (k n : ℕ) : fk k n ≤ n * n := by
  exact Finset.sup_le fun x hx => by simpa [ grid_card ] using Finset.card_le_card ( Finset.mem_powerset.mp <| Finset.mem_filter.mp hx |>.1 ) ;

/-
In the trivial regime `n ≤ k`, `f_k(n) ≥ n²` (the whole grid works).
-/
theorem fk_ge_sq_of_le (k n : ℕ) (h : n ≤ k) : n * n ≤ fk k n := by
  refine le_trans ?_ (Finset.le_sup (Finset.mem_filter.mpr
    ⟨Finset.mem_powerset.mpr (Finset.Subset.refl _), grid_NoKp1 k n h⟩));
  rw [grid_card]

/-- **Trivial regime.** For `n ≤ k`, `f_k(n) = n²`. -/
theorem fk_eq_sq (k n : ℕ) (h : n ≤ k) : fk k n = n * n :=
  le_antisymm (fk_le_sq k n) (fk_ge_sq_of_le k n h)

/-- Boundary case of the conjecture: `f_k(k) = k² = k · k`. -/
theorem fk_diag (k : ℕ) : fk k k = k * k := fk_eq_sq k k le_rfl

/-! ## A nontrivial instance with `n > k`: `f_3(4) = 12`. -/

/-- A transversal of the `4 × 4` grid hitting both long diagonals. -/
def badT : Finset (ℤ × ℤ) := {(0, 0), (1, 2), (2, 1), (3, 3)}

/-- An explicit `12`-point configuration in the `4 × 4` grid. -/
def T : Finset (ℤ × ℤ) := grid 4 \ badT

lemma T_card : T.card = 12 := by decide

lemma T_sub : T ⊆ grid 4 := Finset.sdiff_subset

lemma T_noKp1 : NoKp1 3 T := by decide

/-- **A nontrivial instance of the conjecture (`n = 4 > k = 3`):** `f_3(4) = 12 = 3·4`. -/
theorem f3_4 : fk 3 4 = 12 := by
  refine le_antisymm ?_ ?_
  · have h := fk_le 3 4 (by norm_num)
    simpa using h
  · have hmem : T ∈ (grid 4).powerset.filter (fun S => NoKp1 3 S) := by
      simp only [Finset.mem_filter, Finset.mem_powerset]
      exact ⟨T_sub, T_noKp1⟩
    have h := Finset.le_sup (f := Finset.card) hmem
    rw [T_card] at h
    exact h

end NoKPlus1