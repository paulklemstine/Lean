import Mathlib

/-!
# Algebraic Statistics: The Markov Basis of the Two-Way Independence Model

This file formalises the **two-way independence model** on `m × n` contingency tables and
proves the *Fundamental Theorem of Markov Bases* for it (Diaconis–Sturmfels): the set of
**basic `2 × 2` swap moves** connects every fiber of the model.

An `m × n` contingency table is `u : Fin m → Fin n → ℤ`.  The independence model fixes the
two families of one-dimensional margins (all row sums and all column sums).  A *fiber* is the
set of non-negative integer tables with prescribed row and column sums (a transportation
polytope's lattice points).

The classical Markov basis of this model is the collection of **basic moves**
`B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}` for `i ≠ i'`, `j ≠ j'`: the
`2 × 2` minor swaps.  This file proves these moves connect every fiber, using the textbook
distance-reduction argument.

## Main results

* `basicMove_preserves_margins` — every basic move lies in the kernel of the margin map
  (it is a legal model move): adding it changes no row sum and no column sum.
* `exists_good_indices` — for any two distinct equal-margin tables there is a `2 × 2`
  configuration `(i,i',j,j')` aligned with the sign pattern of `u - v` (a three-step
  pigeonhole on the all-cells sum, a row sum, then a column sum).
* `dist_decrease` — the corresponding basic move strictly decreases the `ℓ¹` distance to `v`.
* `twoWay_fiber_connected` — **Fundamental Theorem of Markov Bases (independence model).**
  Any two non-negative tables with equal row and column sums are joined by a walk of basic
  `2 × 2` moves that stays non-negative at every step: the basic moves connect every fiber.

## Catalog synthesis

This is the foundational companion to `Algebra.MarkovBases.NoThreeWay` (which handles the
rank-one `2 × 2 × 2` no-three-way model).  Where that model has a *single* generator, the
independence model needs the full family of `2 × 2` swaps, so the connectivity proof is a
genuine *distance-reduction* (potential-function) argument rather than a one-line walk: a
reusable bridge between integer lattice walks (combinatorial step relations via
`Relation.ReflTransGen`) and the `ℓ¹` metric on fibers.  The three-stage pigeonhole in
`exists_good_indices` (all-cells sum → row sum → column sum) is the structural heart of the
Fundamental Theorem of Markov Bases.
-/

namespace MarkovBases.TwoWay

variable {m n : ℕ}

/-- An `m × n` integer contingency table. -/
abbrev Table (m n : ℕ) := Fin m → Fin n → ℤ

/-- The `i`-th row margin (sum over columns). -/
def rowSum (u : Table m n) (i : Fin m) : ℤ := ∑ j, u i j
/-- The `j`-th column margin (sum over rows). -/
def colSum (u : Table m n) (j : Fin n) : ℤ := ∑ i, u i j

/-- Two tables lie in the same fiber of the independence model iff all row sums and all
column sums agree. -/
def SameMargins (u v : Table m n) : Prop :=
  (∀ i, rowSum u i = rowSum v i) ∧ (∀ j, colSum u j = colSum v j)

/-- The basic `2 × 2` swap move `B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}`. -/
def basicMove (i i' : Fin m) (j j' : Fin n) : Table m n :=
  fun a b =>
    (if a = i ∧ b = j' then 1 else 0)
  + (if a = i' ∧ b = j then 1 else 0)
  - (if a = i ∧ b = j then 1 else 0)
  - (if a = i' ∧ b = j' then 1 else 0)

/-- Non-negativity of a table (membership in a fiber requires non-negative counts). -/
def Nonneg (u : Table m n) : Prop := ∀ i j, 0 ≤ u i j

/-- A single legal Markov step: add a basic `2 × 2` move (with distinct rows and columns),
staying non-negative at both ends.  The reverse move is obtained by swapping `i, i'`. -/
def Step (u v : Table m n) : Prop :=
  Nonneg u ∧ Nonneg v ∧
    ∃ (i i' : Fin m) (j j' : Fin n), i ≠ i' ∧ j ≠ j' ∧ v = u + basicMove i i' j j'

/-- `Connected u v`: a walk of legal basic `2 × 2` moves from `u` to `v`. -/
def Connected (u v : Table m n) : Prop := Relation.ReflTransGen Step u v

/-- The `ℓ¹` distance between two tables (number of unit cell-discrepancies). -/
def D (u v : Table m n) : ℕ := ∑ p : Fin m × Fin n, (u p.1 p.2 - v p.1 p.2).natAbs

-- !-- Lab Notebook: basicMove_preserves_margins -- !--
-- !-- Hypothesis: every basic 2×2 move has all row and column margins zero, so it is legal -- !--
-- !-- Result: PROVED. Adding any basic move leaves every rowSum and colSum unchanged. -- !--
-- !-- Insight: each row of B sums to +1-1=0 (cols j,j'), each column to +1-1=0 (rows i,i') -- !--
-- !-- Failure analysis: keeping B in the explicit four-`if` form lets `simp +decide` plus a
--     case split on whether the running index equals i/i' (resp. j/j') discharge each line
--     sum after `Finset.sum_add_distrib` splits the perturbation off the base table. -- !--
-- !-- End Lab Notebook -- !--

-- !-- basicMove_preserves_margins: each row of B sums to 0 (uses j≠j') and each column sums to
-- 0 (uses i≠i'), so adding B changes no margin: B is in the kernel of the margin map. -- !--
/-- Adding a basic move (with distinct rows and columns) preserves all row and column
margins: every basic move lies in the kernel of the margin map. -/
theorem basicMove_preserves_margins (u : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (hj : j ≠ j') : SameMargins u (u + basicMove i i' j j') := by
  constructor <;> intro k <;> simp_all +decide [ rowSum, colSum, Finset.sum_add_distrib ];
  · unfold basicMove; by_cases hk : k = i <;> by_cases hk' : k = i' <;> simp_all +decide ;
  · unfold basicMove; simp +decide [ *, Finset.sum_add_distrib ] ;
    by_cases hi : k = j <;> by_cases hj : k = j' <;> simp_all +decide [ Finset.filter_eq' ]

-- !-- D_eq_zero_iff: the ℓ¹ distance is a sum of natAbs cells, zero iff every cell agrees. -- !--
/-- `D u v = 0` exactly when the tables coincide. -/
theorem D_eq_zero_iff (u v : Table m n) : D u v = 0 ↔ u = v := by
  simp +decide [ funext_iff, D ];
  grind

-- !-- Lab Notebook: exists_good_indices -- !--
-- !-- Hypothesis: u≠v with equal margins ⇒ a 2×2 frame aligned to the sign pattern of u-v -- !--
-- !-- Result: PROVED. Returns i≠i', j≠j' with v i j<u i j, u i j'<v i j', v i' j'<u i' j'. -- !--
-- !-- Insight: total sum of (u-v) is 0 (equal margins) so some cell has u>v; its row sums to 0
--     so some cell in that row has u<v; that column sums to 0 so some cell has u>v -- !--
-- !-- Failure analysis: distinctness of the two rows/columns is *not* a separate hypothesis —
--     it falls out of the opposite signs (a positive and a negative cell cannot coincide),
--     proved by `rintro rfl; linarith`. -- !--
-- !-- End Lab Notebook -- !--

-- !-- exists_good_indices: three-stage pigeonhole — the all-cells sum of u-v is 0 giving a cell
-- with u>v, its row sum is 0 giving a cell with u<v, that column sum is 0 giving u>v again;
-- distinctness of the two rows/columns is forced by the opposite signs. -- !--
/-- **Sign-pattern pigeonhole.** If `u ≠ v` have the same margins, there is a `2 × 2`
configuration `(i,i',j,j')` with `i ≠ i'`, `j ≠ j'` and the sign pattern
`v i j < u i j`, `u i j' < v i j'`, `v i' j' < u i' j'`. -/
theorem exists_good_indices (u v : Table m n) (hm : SameMargins u v) (hne : u ≠ v) :
    ∃ (i i' : Fin m) (j j' : Fin n), i ≠ i' ∧ j ≠ j' ∧
      v i j < u i j ∧ u i j' < v i j' ∧ v i' j' < u i' j' := by
  -- By the pigeonhole principle, there exists a cell $(i,j)$ with $d_{ij} > 0$.
  obtain ⟨i, j, h_pos⟩ : ∃ i j, u i j > v i j := by
    contrapose! hne;
    ext i j; exact le_antisymm ( hne i j ) ( by have := hm.1 i; have := hm.2 j; exact (by
    exact le_of_not_gt fun h => absurd this ( ne_of_lt <| Finset.sum_lt_sum ( fun a _ => by aesop ) ⟨ i, Finset.mem_univ _, h ⟩ )) ) ;
  -- By the pigeonhole principle, there exists a cell $(i,j')$ with $d_{ij'} < 0$.
  obtain ⟨j', h_neg⟩ : ∃ j', u i j' < v i j' := by
    contrapose! hm;
    exact fun h => by have := h.1 i; exact absurd this ( ne_of_gt <| Finset.sum_lt_sum ( fun a _ => by linarith [ hm a ] ) ⟨ j, Finset.mem_univ _, h_pos ⟩ ) ;
  -- By the pigeonhole principle, there exists a cell $(i',j')$ with $d_{i'j'} > 0$.
  obtain ⟨i', h_pos'⟩ : ∃ i', u i' j' > v i' j' := by
    contrapose! hm;
    exact fun h => by have := h.2 j'; exact this.not_lt <| Finset.sum_lt_sum ( fun a _ => hm a ) ⟨ i, Finset.mem_univ i, h_neg ⟩ ;
  exact ⟨ i, i', j, j', by rintro rfl; linarith, by rintro rfl; linarith, h_pos, h_neg, h_pos' ⟩

-- !-- Lab Notebook: dist_decrease -- !--
-- !-- Hypothesis: the sign-aligned basic move strictly reduces the ℓ¹ distance to v -- !--
-- !-- Result: PROVED. D (u + basicMove i i' j j') v < D u v. -- !--
-- !-- Insight: three of the four touched cells move toward v (−1 distance each); the fourth
--     changes distance by at most +1, so the net change is ≤ −2 < 0 -- !--
-- !-- Failure analysis: localise the sum to the four distinct touched cells by splitting the
--     universe sum along the explicit 4-element frame {(i,j),(i,j'),(i',j),(i',j')}; off the
--     frame `u + basicMove = u`, so only the four cells contribute and `grind` finishes. -- !--
-- !-- End Lab Notebook -- !--

-- !-- dist_decrease: only the four cells of the frame change; cells (i,j),(i,j'),(i',j') each
-- move one step toward v while (i',j) moves at most one step away, so D drops by ≥ 2. -- !--
/-- The sign-aligned basic move strictly decreases the `ℓ¹` distance to `v`. -/
theorem dist_decrease (u v : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (hj : j ≠ j')
    (h1 : v i j < u i j) (h2 : u i j' < v i j') (h3 : v i' j' < u i' j') :
    D (u + basicMove i i' j j') v < D u v := by
  unfold D;
  rw [ ← Finset.sum_sdiff <| Finset.subset_univ { ( i, j ), ( i, j' ), ( i', j ), ( i', j' ) } ];
  rw [ ← Finset.sum_sdiff <| Finset.subset_univ { ( i, j ), ( i, j' ), ( i', j ), ( i', j' ) } ];
  rw [ Finset.sum_congr rfl fun x hx => by rw [ show ( u + basicMove i i' j j' ) x.1 x.2 = u x.1 x.2 from by unfold basicMove; aesop ] ];
  simp +decide [ *, basicMove ];
  grind

-- !-- Lab Notebook: exists_step -- !--
-- !-- Hypothesis: a non-negative u≠v in a fiber admits one legal step strictly closer to v -- !--
-- !-- Result: PROVED. Combines exists_good_indices + dist_decrease + a non-negativity check. -- !--
-- !-- Insight: the three decreasing cells stay ≥ v ≥ 0 (so subtracting 1 is safe); the two
--     increasing cells trivially remain non-negative. -- !--
-- !-- Failure analysis: the non-negativity goal is closed cell-by-cell by `grind +locals`
--     after unfolding basicMove, using hv to bound the decremented cells below by v. -- !--
-- !-- End Lab Notebook -- !--

-- !-- exists_step: assemble the pigeonhole frame and the distance-decrease bound, and check the
-- moved table is non-negative (the three decreasing cells stay ≥ v ≥ 0, the increasing cell
-- stays ≥ 0), producing one legal Markov step strictly closer to v. -- !--
/-- From any non-negative `u ≠ v` in the same fiber there is a single legal basic Markov step
to a table strictly closer to `v` in `ℓ¹` distance. -/
theorem exists_step (u v : Table m n) (hu : Nonneg u) (hv : Nonneg v)
    (hm : SameMargins u v) (hne : u ≠ v) :
    ∃ u', Step u u' ∧ D u' v < D u v := by
  obtain ⟨ i, i', j, j', hi, hj, h1, h2, h3 ⟩ := exists_good_indices u v hm hne;
  refine' ⟨ _, ⟨ hu, _, i, i', j, j', hi, hj, rfl ⟩, dist_decrease u v i i' j j' hi hj h1 h2 h3 ⟩;
  intro a b; unfold basicMove; simp +decide [ * ] ;
  grind +locals

-- !-- Lab Notebook: twoWay_fiber_connected -- !--
-- !-- Hypothesis: the basic 2×2 moves connect every fiber of the independence model (FTMB) -- !--
-- !-- Result: PROVED (via connected_of_D_le). Any two non-negative equal-margin tables are
--     joined by a non-negative walk of basic moves. -- !--
-- !-- Insight: strong induction on the ℓ¹ distance D u v; each step strictly decreases D -- !--
-- !-- Failure analysis: packaged as connected_of_D_le with an explicit Nat bound so that
--     `Nat.strong_induction_on` has a decreasing measure; margins are propagated to the moved
--     table by basicMove_preserves_margins before recursing. -- !--
-- !-- End Lab Notebook -- !--

-- !-- connected_of_D_le: strong induction on the distance bound N; if u=v use refl, else
-- exists_step yields a strictly closer non-negative neighbour with equal margins; recurse. -- !--
/-- Auxiliary strong-induction packaging: connectivity for tables within `ℓ¹` distance `N`. -/
theorem connected_of_D_le : ∀ (N : ℕ) (u v : Table m n), D u v ≤ N →
    Nonneg u → Nonneg v → SameMargins u v → Connected u v := by
  intro N u v hN hu hv;
  induction' N using Nat.strong_induction_on with N ih generalizing u v;
  by_cases huv : u = v;
  · exact fun _ => huv ▸ Relation.ReflTransGen.refl;
  · intro hm
    obtain ⟨u', hu', hD⟩ := exists_step u v hu hv hm huv;
    obtain ⟨ hu₁, hu₂, i, i', j, j', hi, hj, rfl ⟩ := hu';
    have h_connected : Connected (u + basicMove i i' j j') v := by
      apply ih (D (u + basicMove i i' j j') v) (by linarith) (u + basicMove i i' j j') v (by linarith) hu₂ hv (by
      exact ⟨ fun k => by linarith [ hm.1 k, basicMove_preserves_margins u i i' j j' hi hj |>.1 k ], fun k => by linarith [ hm.2 k, basicMove_preserves_margins u i i' j j' hi hj |>.2 k ] ⟩);
    exact .single ⟨ hu₁, hu₂, i, i', j, j', hi, hj, rfl ⟩ |> Relation.ReflTransGen.trans <| h_connected

-- !-- twoWay_fiber_connected: induct on the ℓ¹ distance; exists_step gives a non-negative move
-- strictly closer to v, basicMove_preserves_margins keeps margins fixed, recurse — the
-- Fundamental Theorem of Markov Bases for the independence model. -- !--
/-- **Fundamental Theorem of Markov Bases (two-way independence model).**
Any two non-negative tables with equal row and column margins are joined by a walk of basic
`2 × 2` swap moves that stays non-negative at every step.  Equivalently, the basic moves form
a Markov basis: they connect every fiber of the independence model. -/
theorem twoWay_fiber_connected (u v : Table m n)
    (hu : Nonneg u) (hv : Nonneg v) (hm : SameMargins u v) : Connected u v :=
  connected_of_D_le (D u v) u v le_rfl hu hv hm

-- !-- Lab Notebook: step_symm / Connected.symm -- !--
-- !-- Hypothesis: the Markov step relation is symmetric, so connectivity is an equivalence -- !--
-- !-- Result: PROVED. step_symm gives Step v u from Step u v; Connected.symm lifts it. -- !--
-- !-- Insight: the reverse of basicMove i i' j j' is basicMove i' i j j' (swap the two rows),
--     which negates the move; so every legal step has a legal inverse -- !--
-- !-- Failure analysis: the inverse step reuses the same non-negativity certificates; the only
--     content is the pointwise cancellation basicMove i i' j j' + basicMove i' i j j' = 0,
--     and Connected.symm is then a fold of step_symm through the reflexive-transitive closure. -- !--
-- !-- End Lab Notebook -- !--

-- !-- step_symm: swapping the two rows negates the basic move, so u = v + basicMove i' i j j';
-- the non-negativity certificates carry over unchanged, giving the inverse legal step. -- !--
/-- The Markov step relation is symmetric: the reverse of a basic move is the basic move with
its two rows swapped (`basicMove i' i j j' = - basicMove i i' j j'`). -/
theorem step_symm {u v : Table m n} (h : Step u v) : Step v u := by
  rcases h with ⟨ hu, hv, i, i', j, j', hi, hj, h ⟩;
  refine' ⟨ hv, hu, i', i, j, j', hi.symm, hj, _ ⟩;
  ext a b; simp +decide [ h, basicMove ] ; ring;

-- !-- Connected.symm: fold step_symm through the reflexive-transitive closure, so the fiber
-- connectivity relation is symmetric — hence an equivalence relation on contingency tables. -- !--
/-- **Fibers are equivalence classes.** Connectivity by basic moves is symmetric (and, being a
reflexive–transitive closure, reflexive and transitive); thus it is an equivalence relation,
and its classes are exactly the fibers of the independence model. -/
theorem Connected.symm {u v : Table m n} (h : Connected u v) : Connected v u := by
  induction' h with v w h₁ h₂;
  · constructor;
  · exact .trans ( .single ( step_symm h₂ ) ) ‹_›

end MarkovBases.TwoWay