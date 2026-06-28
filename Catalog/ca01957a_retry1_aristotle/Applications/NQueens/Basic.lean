/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The n-queens problem: definitions, an explicit solution family, and a Hall-theorem
# completion lower bound

This file sets up the combinatorial framework for the `n`-queens *completion* problem
and proves:

1. **Full-solution results via an explicit toroidal construction** (`gcd(n,6) = 1`):
   * `exists_full_solution`: the board admits a full `n`-queens solution `x ↦ 2x + b`;
   * `single_queen_completable`: **any** single placed queen completes to a full
     solution, so the completion threshold is at least `1` for the infinite family
     `{n : gcd(n,6) = 1}` (`infinitely_many_coprime_six`).

2. **A Hall-theorem lower bound with constant `1/5 = 0.2 > 0.15`**
   (`completion_relaxation`): if `Q` is a non-attacking partial placement with
   `5 * #Q ≤ n` then `Q` extends to a permutation placement that shares no row, column
   or diagonal between any newly-placed queen and any original queen.

   The construction is the one suggested by Hall's Marriage Theorem
   (`Fintype.all_card_le_filter_rel_iff_exists_injective`): in the bipartite "rows vs.
   columns" graph an empty row may use an empty column whose cell avoids the diagonals
   of all pre-placed queens, while a used row keeps its own column.  The Hall condition
   is checked by double counting: a pre-placed queen forbids at most two columns in any
   fixed row and at most two rows in any fixed column; the slack `5 #Q ≤ n` makes the
   estimate close.  The probabilistic-method foundations referenced alongside this file
   live in `Catalog/Combinatorics/Probabilistic.lean`.

## Board model

Cells are indexed by `ZMod n × ZMod n`.  This gives the board a convenient ring
structure for the toroidal construction, while the *diagonals* are the ordinary,
non-wrapping chess diagonals, computed from the canonical representatives
`ZMod.val ∈ {0, …, n-1}` cast into `ℤ`.

## Scope (honest statement)

`completion_relaxation` proves the **bipartite relaxation** of queens completion: the
produced placement is row/column-distinct everywhere and diagonal-consistent between
*new and old* queens, but Hall's theorem alone does not rule out a diagonal conflict
between two *newly placed* queens.  Closing that last gap to obtain a genuine full
solution for a linear number of pre-placed queens is the much deeper completion
threshold theorem of Glock–Munhá Correia–Sudakov, which is not proved here.  Nothing
below depends on any completion-threshold statement (no circular dependency).
-/

import Mathlib

namespace Catalog.NQueens

open Finset

variable {n : ℕ}

/-! ## Board, attacks and (partial / full) solutions -/

/-- The integer "row + col" coordinate of a cell (its anti-diagonal index). -/
def antiDiag (a : ZMod n × ZMod n) : ℤ := (a.1.val : ℤ) + (a.2.val : ℤ)

/-- The integer "row - col" coordinate of a cell (its diagonal index). -/
def mainDiag (a : ZMod n × ZMod n) : ℤ := (a.1.val : ℤ) - (a.2.val : ℤ)

/-- Two cells attack each other as queens: same row, same column, or a common
(ordinary, non-wrapping) diagonal. -/
def Attacks (a b : ZMod n × ZMod n) : Prop :=
  a.1 = b.1 ∨ a.2 = b.2 ∨ antiDiag a = antiDiag b ∨ mainDiag a = mainDiag b

/-- A finite set of queens is *non-attacking* (a partial solution) when distinct
queens never attack each other. -/
def NonAttacking (Q : Finset (ZMod n × ZMod n)) : Prop :=
  ∀ a ∈ Q, ∀ b ∈ Q, a ≠ b → ¬ Attacks a b

/-- A *full solution* is a set of `n` pairwise non-attacking queens. -/
def IsFullSolution (Q : Finset (ZMod n × ZMod n)) : Prop :=
  NonAttacking Q ∧ Q.card = n

/-- `Q` is *completable* if it is a subset of some full solution. -/
def Completable (Q : Finset (ZMod n × ZMod n)) : Prop :=
  ∃ F, IsFullSolution F ∧ Q ⊆ F

/-
In a non-attacking placement, each row carries at most one queen.
-/
lemma NonAttacking.col_unique {Q : Finset (ZMod n × ZMod n)} (hQ : NonAttacking Q)
    {r c c' : ZMod n} (h : (r, c) ∈ Q) (h' : (r, c') ∈ Q) : c = c' := by
  grind +locals

/-
In a non-attacking placement, each column carries at most one queen.
-/
lemma NonAttacking.row_unique {Q : Finset (ZMod n × ZMod n)} (hQ : NonAttacking Q)
    {r r' c : ZMod n} (h : (r, c) ∈ Q) (h' : (r', c) ∈ Q) : r = r' := by
  by_contra h_contra;
  exact hQ _ h _ h' ( by aesop ) ( by unfold Attacks; aesop )

/-! ## An explicit toroidal solution family -/

/-- The toroidal placement `x ↦ 2x + b`, as a finite set of queens. -/
def diagGraph [NeZero n] (b : ZMod n) : Finset (ZMod n × ZMod n) :=
  Finset.univ.image (fun x => (x, 2 * x + b))

@[simp] lemma mem_diagGraph [NeZero n] {b : ZMod n} {p : ZMod n × ZMod n} :
    p ∈ diagGraph b ↔ p.2 = 2 * p.1 + b := by
  unfold diagGraph; aesop

/-
`2` is a unit in `ZMod n` when `gcd(n, 6) = 1`.
-/
lemma isUnit_two (hcop : Nat.Coprime n 6) : IsUnit (2 : ZMod n) := by
  -- Since gcd(n, 2) = 1, 2 is a unit in ZMod n.
  have h_coprime_2 : Nat.Coprime n 2 := by
    exact hcop.coprime_dvd_right <| by decide;
  convert ZMod.isUnit_iff_coprime _ _ |>.2 h_coprime_2.symm

/-
`3` is a unit in `ZMod n` when `gcd(n, 6) = 1`.
-/
lemma isUnit_three (hcop : Nat.Coprime n 6) : IsUnit (3 : ZMod n) := by
  have h_coprime : Nat.Coprime 3 n := by
    exact hcop.symm.coprime_dvd_left ( by decide );
  convert ZMod.isUnit_iff_coprime 3 n |>.2 h_coprime using 1

/-
The toroidal placement uses every row exactly once, so it has `n` queens.
-/
lemma diagGraph_card [NeZero n] (b : ZMod n) : (diagGraph b).card = n := by
  rw [ diagGraph, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ]

/-
The toroidal placement `x ↦ 2x + b` is a full `n`-queens solution whenever
`gcd(n, 6) = 1`.
-/
lemma diagGraph_isFullSolution [NeZero n] (hcop : Nat.Coprime n 6) (b : ZMod n) :
    IsFullSolution (diagGraph b) := by
  refine' ⟨ _, _ ⟩;
  · intro a ha b hb hab;
    obtain ⟨x₁, y₁⟩ := a
    obtain ⟨x₂, y₂⟩ := b
    simp [diagGraph] at ha hb;
    unfold Attacks;
    unfold antiDiag mainDiag; simp_all +decide [ ← eq_sub_iff_add_eq' ] ;
    refine' ⟨ _, _, _, _ ⟩;
    · aesop;
    · have h_unit : IsUnit (2 : ZMod n) := isUnit_two hcop
      exact fun h => hab ( h_unit.mul_left_cancel <| by linear_combination' -hb + h ) h;
    · intro h; have := congr_arg ( fun z => z : ℤ → ZMod n ) h; norm_num at this; simp_all +decide [ sub_eq_iff_eq_add ] ;
      -- Since $3$ is a unit in $ZMod n$, we can cancel it from both sides of the equation.
      have h_unit : IsUnit (3 : ZMod n) := by
        convert isUnit_three hcop using 1;
      exact hab ( h_unit.mul_right_injective <| by linear_combination' hb.symm );
    · intro h;
      -- From the equality $x₁.cast - y₁.cast = x₂.cast - y₂.cast$, we can deduce that $x₁ - y₁ = x₂ - y₂$ in $ZMod n$.
      have h_eq : x₁ - y₁ = x₂ - y₂ := by
        simpa [ ← ZMod.intCast_eq_intCast_iff ] using congr_arg ( fun z : ℤ => z : ℤ → ZMod n ) h;
      grind;
  · exact diagGraph_card b

/-- **Existence of solutions.** Whenever `gcd(n, 6) = 1` the `n`-queens problem has a
full solution. -/
theorem exists_full_solution [NeZero n] (hcop : Nat.Coprime n 6) :
    ∃ Q : Finset (ZMod n × ZMod n), IsFullSolution Q :=
  ⟨diagGraph 0, diagGraph_isFullSolution hcop 0⟩

/-
**Single-queen completion.** Whenever `gcd(n, 6) = 1`, any single placed queen can
be completed to a full solution.  Hence the completion threshold is at least `1` for
this infinite family of board sizes.
-/
theorem single_queen_completable [NeZero n] (hcop : Nat.Coprime n 6) (r c : ZMod n) :
    Completable ({(r, c)} : Finset (ZMod n × ZMod n)) := by
  refine' ⟨ diagGraph ( c - 2 * r ), _, _ ⟩;
  · exact diagGraph_isFullSolution hcop _;
  · simp +decide [ mem_diagGraph ]

/-
The family of board sizes `n` with `gcd(n, 6) = 1` is infinite (e.g. all `6k + 1`).
-/
theorem infinitely_many_coprime_six : {n : ℕ | Nat.Coprime n 6}.Infinite := by
  exact Set.infinite_of_forall_exists_gt fun n => ⟨ 6 * n + 1, by norm_num, by linarith ⟩

/-! ## A Hall-theorem completion lower bound (constant `1/5 > 0.15`) -/

/-- Two cells share a diagonal (either the `+` or the `-` diagonal). -/
def DiagAttacks (a b : ZMod n × ZMod n) : Prop :=
  antiDiag a = antiDiag b ∨ mainDiag a = mainDiag b

/-- The set of occupied rows of `Q`. -/
def usedRows (Q : Finset (ZMod n × ZMod n)) : Finset (ZMod n) := Q.image Prod.fst

/-- The set of occupied columns of `Q`. -/
def usedCols (Q : Finset (ZMod n × ZMod n)) : Finset (ZMod n) := Q.image Prod.snd

/-- The Hall relation: a used row `i` must keep its own column; an empty row `i` may use
any empty column `c` whose cell `(i, c)` avoids the diagonals of all queens of `Q`. -/
def restrRel (Q : Finset (ZMod n × ZMod n)) (i c : ZMod n) : Prop :=
  (i, c) ∈ Q ∨
    (i ∉ usedRows Q ∧ c ∉ usedCols Q ∧ ∀ q ∈ Q, ¬ DiagAttacks (i, c) q)

lemma usedRows_card {Q : Finset (ZMod n × ZMod n)} (hQ : NonAttacking Q) :
    (usedRows Q).card = Q.card := by
  convert Finset.card_image_of_injOn _;
  exact fun x hx y hy hxy => Prod.ext hxy ( NonAttacking.col_unique hQ hx ( by aesop ) )

lemma usedCols_card {Q : Finset (ZMod n × ZMod n)} (hQ : NonAttacking Q) :
    (usedCols Q).card = Q.card := by
  convert Finset.card_image_iff.mpr _;
  intro a ha b hb; have := hQ a ha b hb; simp_all +decide [ Attacks ] ;
  grind

/-
A filter `{c | (c.val : ℤ) = P}` has at most one element, since `ZMod.val` is
injective.
-/
lemma card_filter_val_eq [NeZero n] (P : ℤ) :
    (Finset.univ.filter (fun c : ZMod n => (c.val : ℤ) = P)).card ≤ 1 := by
  rw [ Finset.card_le_one_iff ];
  simp +zetaDelta at *;
  grind +suggestions

open Classical in
/-- In a fixed row `i`, a single queen `q` lies on a common diagonal with at most two
columns. -/
lemma colsHit_card_le_two [NeZero n] (i : ZMod n) (q : ZMod n × ZMod n) :
    (Finset.univ.filter (fun c : ZMod n => DiagAttacks (i, c) q)).card ≤ 2 := by
  -- The set of cells that attack q is contained in the union of two sets, each of which has at most one element.
  have h_union : Finset.univ.filter (fun c => DiagAttacks (i, c) q) ⊆ Finset.univ.filter (fun c => (c.val : ℤ) = (antiDiag q - i.val : ℤ)) ∪ Finset.univ.filter (fun c => (c.val : ℤ) = (i.val - mainDiag q : ℤ)) := by
    grind +locals;
  exact le_trans ( Finset.card_le_card h_union ) ( Finset.card_union_le _ _ ) |> le_trans <| add_le_add ( card_filter_val_eq _ ) ( card_filter_val_eq _ )

open Classical in
/-- In a fixed column `c`, a single queen `q` lies on a common diagonal with at most two
rows. -/
lemma rowsHit_card_le_two [NeZero n] (c : ZMod n) (q : ZMod n × ZMod n) :
    (Finset.univ.filter (fun i : ZMod n => DiagAttacks (i, c) q)).card ≤ 2 := by
  unfold DiagAttacks;
  -- Each equation has at most one solution.
  have h_eq : ∀ (a b : ℤ), (Finset.univ.filter (fun i : ZMod n => (i.val : ℤ) = a)).card ≤ 1 ∧ (Finset.univ.filter (fun i : ZMod n => (i.val : ℤ) = b)).card ≤ 1 := by
    exact fun a b => ⟨ card_filter_val_eq a, card_filter_val_eq b ⟩;
  convert le_trans ( Finset.card_union_le _ _ ) ( add_le_add ( h_eq ( antiDiag q - c.val ) ( mainDiag q + c.val ) |>.1 ) ( h_eq ( antiDiag q - c.val ) ( mainDiag q + c.val ) |>.2 ) ) using 1;
  congr with i ; simp +decide [ antiDiag, mainDiag ] ; omega

open Classical in
/-- In a fixed row `i`, the queens of `Q` forbid (diagonally) at most `2 #Q` columns. -/
lemma forbidden_cols_card [NeZero n] (Q : Finset (ZMod n × ZMod n)) (i : ZMod n) :
    (Finset.univ.filter (fun c : ZMod n => ∃ q ∈ Q, DiagAttacks (i, c) q)).card
      ≤ 2 * Q.card := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.biUnion Q fun q => Finset.filter ( fun c => DiagAttacks ( i, c ) q ) Finset.univ;
  · grind;
  · exact le_trans ( Finset.card_biUnion_le ) ( by simpa [ mul_comm ] using Finset.sum_le_sum fun q hq => colsHit_card_le_two i q )

open Classical in
/-- In a fixed column `c`, the queens of `Q` forbid (diagonally) at most `2 #Q` rows. -/
lemma forbidden_rows_card [NeZero n] (Q : Finset (ZMod n × ZMod n)) (c : ZMod n) :
    (Finset.univ.filter (fun i : ZMod n => ∃ q ∈ Q, DiagAttacks (i, c) q)).card
      ≤ 2 * Q.card := by
  convert Finset.card_biUnion_le.trans _ using 1;
  convert rfl;
  rotate_left;
  exact ZMod n × ZMod n;
  infer_instance;
  exact Q;
  use fun q => Finset.filter ( fun i => DiagAttacks ( i, c ) q ) Finset.univ;
  · exact le_trans ( Finset.sum_le_sum fun _ _ => rowsHit_card_le_two _ _ ) ( by simp +decide [ mul_comm ] );
  · aesop

open Classical in
/-- The Marriage condition for `restrRel` holds once `5 #Q ≤ n`. -/
lemma hall_condition [NeZero n] {Q : Finset (ZMod n × ZMod n)} (hQ : NonAttacking Q)
    (hk : 5 * Q.card ≤ n) (A : Finset (ZMod n)) :
    A.card ≤ (Finset.univ.filter (fun c => ∃ i ∈ A, restrRel Q i c)).card := by
  by_contra h_contra;
  -- Split `A = A_u ∪ A_e` with `A_u := A.filter (· ∈ UR)` and `A_e := A.filter (· ∉ UR)`; these are disjoint with `#A = #A_u + #A_e`.
  set UR := usedRows Q
  set UC := usedCols Q
  set AU := A.filter (· ∈ UR)
  set AE := A.filter (· ∉ UR)
  have h_card_A : A.card = AU.card + AE.card := by
    rw [ Finset.card_filter_add_card_filter_not ]
  have h_card_AU : AU.card ≤ (Finset.filter (fun c => ∃ i ∈ AU, restrRel Q i c) Finset.univ).card := by
    -- For each `i ∈ AU`, there is a unique `c` such that `(i, c) ∈ Q`.
    have h_unique_c : ∀ i ∈ AU, ∃ c, (i, c) ∈ Q ∧ ∀ c', (i, c') ∈ Q → c' = c := by
      simp +zetaDelta at *;
      exact fun i hi hi' => by rcases Finset.mem_image.mp hi' with ⟨ x, hx, rfl ⟩ ; exact ⟨ _, hx, fun c' hc' => NonAttacking.col_unique hQ hc' hx ⟩ ;
    choose! f hf₁ hf₂ using h_unique_c;
    refine' le_trans _ ( Finset.card_mono <| show Finset.image f AU ⊆ Finset.filter ( fun c => ∃ i ∈ AU, restrRel Q i c ) Finset.univ from _ );
    · rw [ Finset.card_image_of_injOn ];
      intro i hi j hj hij; have := hf₁ i hi; have := hf₁ j hj; simp_all +decide;
      exact NonAttacking.row_unique hQ this ( hf₁ j hj );
    · simp +contextual [ Finset.subset_iff, restrRel ];
      exact fun i hi => ⟨ i, hi, Or.inl <| hf₁ i hi ⟩
  have h_card_AE : AE.card ≤ (Finset.filter (fun c => ∃ i ∈ AE, restrRel Q i c) Finset.univ).card := by
    by_cases h_case : AE.card ≤ (n - Q.card) - 2 * Q.card;
    · -- Choose any `i₀ ∈ AE`. The columns of `EC` allowed for `i₀`, namely `EC \ (univ.filter (fun c => ∃ q ∈ Q, DiagAttacks (i₀,c) q))`, are all in `N \ UC`, and their count is `≥ #EC - 2k = (n-k) - 2k ≥ #A_e` (using `forbidden_cols_card` and `Finset.card_sdiff`-type bound `#(EC \ F) ≥ #EC - #F`).
      obtain ⟨i₀, hi₀⟩ : ∃ i₀ ∈ AE, True := by
        by_cases hAE_empty : AE = ∅;
        · simp_all +decide [ Finset.ext_iff ];
          contrapose! h_contra;
          refine' le_trans h_card_AU _;
          exact Finset.card_mono fun x hx => by aesop;
        · exact Exists.elim ( Finset.nonempty_of_ne_empty hAE_empty ) fun x hx => ⟨ x, hx, trivial ⟩
      have h_card_EC : (Finset.univ.filter (fun c => c ∉ UC ∧ ∀ q ∈ Q, ¬ DiagAttacks (i₀, c) q)).card ≥ AE.card := by
        have h_card_EC : (Finset.univ.filter (fun c => c ∉ UC ∧ ∀ q ∈ Q, ¬ DiagAttacks (i₀, c) q)).card ≥ (Finset.univ.filter (fun c => c ∉ UC)).card - (Finset.univ.filter (fun c => ∃ q ∈ Q, DiagAttacks (i₀, c) q)).card := by
          simp +decide [ Finset.filter_and ];
          rw [ ← Finset.card_union_add_card_inter ];
          exact le_add_right ( Finset.card_le_card fun x hx => by by_cases hx' : ∃ a b : ZMod n, ( a, b ) ∈ Q ∧ DiagAttacks ( i₀, x ) ( a, b ) <;> aesop );
        have h_card_EC : (Finset.univ.filter (fun c => c ∉ UC)).card = n - Q.card := by
          simp +decide [ Finset.filter_not, Finset.card_sdiff, * ];
          rw [ usedCols_card hQ ];
        have h_card_EC : (Finset.univ.filter (fun c => ∃ q ∈ Q, DiagAttacks (i₀, c) q)).card ≤ 2 * Q.card := by
          convert forbidden_cols_card Q i₀ using 1;
        omega;
      refine le_trans h_card_EC <| Finset.card_le_card ?_;
      grind +locals;
    · -- Since `AE` has more than `2k` elements, every empty column `c ∈ EC` is in `N \ UC`.
      have h_empty_cols : ∀ c ∈ Finset.univ \ UC, ∃ i ∈ AE, restrRel Q i c := by
        intros c hc
        have h_diag : (Finset.filter (fun i => ∃ q ∈ Q, DiagAttacks (i, c) q) AE).card ≤ 2 * Q.card := by
          exact le_trans ( Finset.card_le_card ( Finset.filter_subset_filter _ <| Finset.subset_univ _ ) ) ( forbidden_rows_card Q c );
        have h_empty_cols : (Finset.filter (fun i => ¬∃ q ∈ Q, DiagAttacks (i, c) q) AE).card > 0 := by
          have h_empty_cols : (Finset.filter (fun i => ¬∃ q ∈ Q, DiagAttacks (i, c) q) AE).card = AE.card - (Finset.filter (fun i => ∃ q ∈ Q, DiagAttacks (i, c) q) AE).card := by
            grind +suggestions;
          omega;
        obtain ⟨ i, hi ⟩ := Finset.card_pos.mp h_empty_cols; use i; simp_all +decide [ restrRel ] ;
        exact Or.inr ⟨ Finset.mem_filter.mp hi.1 |>.2, hc ⟩;
      refine' le_trans _ ( Finset.card_mono <| show Finset.univ \ UC ⊆ Finset.filter ( fun c => ∃ i ∈ AE, restrRel Q i c ) Finset.univ from fun x hx => by aesop );
      rw [ Finset.card_sdiff ] ; norm_num [ Finset.card_univ, usedCols_card hQ ];
      exact le_trans ( Finset.card_le_card ( show AE ⊆ Finset.univ \ UR from fun x hx => by aesop ) ) ( by rw [ Finset.card_sdiff ] ; norm_num [ Finset.card_univ, UR, UC, usedRows_card hQ, usedCols_card hQ ] );
  contrapose! h_contra;
  refine le_trans ( h_card_A.le ) ( add_le_add h_card_AU h_card_AE ) |> le_trans <| ?_;
  rw [ ← Finset.card_union_of_disjoint ];
  · exact Finset.card_mono fun x hx => by aesop;
  · simp +contextual [ Finset.disjoint_left, restrRel ];
    grind +locals

open Classical in
/-- **Hall lower bound for queens completion (bipartite relaxation), constant `1/5`.**
If `Q` is non-attacking and `5 #Q ≤ n` then `Q` extends to a permutation placement that
shares no row, column or diagonal between any new queen and any original queen. -/
theorem completion_relaxation [NeZero n] {Q : Finset (ZMod n × ZMod n)}
    (hQ : NonAttacking Q) (hk : 5 * Q.card ≤ n) :
    ∃ σ : ZMod n → ZMod n, Function.Bijective σ ∧
      (∀ q ∈ Q, σ q.1 = q.2) ∧
      (∀ i, i ∉ usedRows Q → ∀ q ∈ Q, ¬ Attacks (i, σ i) q) := by
  -- By Hall's theorem, there exists an injective function `f : ZMod n → ZMod n` such that `restrRel Q i (f i)` holds for all `i`.
  obtain ⟨f, hf_inj, hf_rel⟩ : ∃ f : ZMod n → ZMod n, Function.Injective f ∧ ∀ i, restrRel Q i (f i) := by
    have := @Fintype.all_card_le_filter_rel_iff_exists_injective;
    exact this _ |>.1 ( hall_condition hQ hk );
  refine' ⟨ f, _, _, _ ⟩;
  · exact ⟨ hf_inj, Finite.injective_iff_surjective.mp hf_inj ⟩;
  · grind +locals;
  · grind +locals

end Catalog.NQueens