import Mathlib

/-!
# Vietoris--Rips topology of ordered point clouds

This file isolates the deterministic topology behind the proposed persistent-homology
model of the primes.  For points on the real line, zeroth persistence is controlled
exactly by consecutive gaps.  Moreover, every long edge across three ordered points
forces the two shorter edges, ruling out the proposed three-point mechanism for a
one-dimensional class in an ordinary Vietoris--Rips complex on `ℝ`.

The results are stated for every strictly increasing real sequence, and therefore apply
to any finite initial segment of the primes after coercion to `ℝ`.
-/

namespace PrimeRipsTopology

open Relation

/-- The edge relation at scale `ε` for a point sequence on the real line. -/
def Close (x : ℕ → ℝ) (ε : ℝ) (i j : ℕ) : Prop := |x i - x j| ≤ ε

/-- Reachability in the proximity graph, i.e. membership in the same `H₀` component. -/
def ConnectedAt (x : ℕ → ℝ) (ε : ℝ) (i j : ℕ) : Prop :=
  Relation.EqvGen (Close x ε) i j

/-
Every vertex has a loop at every nonnegative scale.
-/
theorem close_refl (x : ℕ → ℝ) {ε : ℝ} (hε : 0 ≤ ε) (i : ℕ) :
    Close x ε i i := by
  exact abs_le.mpr ⟨ by linarith, by linarith ⟩

/-
Rips proximity is symmetric.
-/
theorem close_symm (x : ℕ → ℝ) (ε : ℝ) {i j : ℕ} (h : Close x ε i j) :
    Close x ε j i := by
  exact abs_sub_le_iff.mpr ⟨ by linarith [ abs_sub_le_iff.mp h ], by linarith [ abs_sub_le_iff.mp h ] ⟩

/-
Edges persist when the filtration scale increases.
-/
theorem close_mono (x : ℕ → ℝ) {ε δ : ℝ} (hεδ : ε ≤ δ) {i j : ℕ}
    (h : Close x ε i j) : Close x δ i j := by
  exact le_trans h hεδ

/-
Component membership persists when the filtration scale increases.
-/
theorem connectedAt_mono (x : ℕ → ℝ) {ε δ : ℝ} (hεδ : ε ≤ δ) {i j : ℕ}
    (h : ConnectedAt x ε i j) : ConnectedAt x δ i j := by
  induction h;
  · exact Relation.EqvGen.rel _ _ ( close_mono x hεδ ‹_› );
  · exact Relation.EqvGen.refl _;
  · exact Relation.EqvGen.symm _ _ ‹_›;
  · exact EqvGen.trans _ _ _ ‹_› ‹_›

/-
On a line, a long Rips edge forces both shorter edges through every intermediate point.
-/
theorem ordered_edge_forces_triangle {x : ℕ → ℝ} (hx : StrictMono x) {ε : ℝ}
    {i j k : ℕ} (hij : i ≤ j) (hjk : j ≤ k) (hik : Close x ε i k) :
    Close x ε i j ∧ Close x ε j k := by
  constructor <;> rw [ Close ] at *;
  · exact abs_le.mpr ⟨ by linarith [ abs_le.mp hik, hx.monotone hij, hx.monotone hjk ], by linarith [ abs_le.mp hik, hx.monotone hij, hx.monotone hjk ] ⟩;
  · cases abs_cases ( x i - x k ) <;> cases abs_cases ( x j - x k ) <;> linarith [ hx.monotone hij, hx.monotone hjk ]

/-
In particular, an edge spanning three consecutive ordered points fills the triangle
on those points in the flag (Vietoris--Rips) complex.
-/
theorem consecutive_edge_fills_triangle {x : ℕ → ℝ} (hx : StrictMono x) {ε : ℝ}
    {i : ℕ} (h : Close x ε i (i + 2)) :
    Close x ε i (i + 1) ∧ Close x ε (i + 1) (i + 2) := by
  exact ordered_edge_forces_triangle hx (by omega) (by omega) h

/-
A consecutive gap larger than `ε` is a genuine cut: no Rips edge crosses it.
-/
theorem large_gap_is_edge_cut {x : ℕ → ℝ} (hx : StrictMono x) {ε : ℝ} {k a b : ℕ}
    (hgap : ε < x (k + 1) - x k) (hab : Close x ε a b) :
    (a ≤ k ↔ b ≤ k) := by
  constructor <;> intro h <;> contrapose! hab;
  · exact fun h' => by linarith [ abs_le.mp h', hx.monotone h, hx.monotone hab ] ;
  · exact fun H => by rw [ Close ] at H; cases abs_cases ( x a - x b ) <;> linarith [ hx.monotone h, hx.monotone ( show a ≥ k + 1 from hab ) ] ;

/-
Since every edge respects a large-gap cut, every graph path respects it as well.
-/
theorem large_gap_separates_components {x : ℕ → ℝ} (hx : StrictMono x)
    {ε : ℝ} {k a b : ℕ} (hgap : ε < x (k + 1) - x k)
    (hab : ConnectedAt x ε a b) : (a ≤ k ↔ b ≤ k) := by
  by_contra h_contra;
  induction hab;
  · exact h_contra <| large_gap_is_edge_cut hx hgap ‹_›;
  · tauto;
  · tauto;
  · grind

/-
If every consecutive gap in an index interval is at most `ε`, its endpoints
are in the same Rips component.
-/
theorem small_gaps_connect {x : ℕ → ℝ} {ε : ℝ} {i j : ℕ} (hij : i ≤ j)
    (hgaps : ∀ k, i ≤ k → k < j → Close x ε k (k + 1)) :
    ConnectedAt x ε i j := by
  induction' hij with j hj ih;
  · exact Relation.EqvGen.refl _;
  · exact Relation.EqvGen.trans _ _ _ ( ih fun k hk₁ hk₂ => hgaps k hk₁ ( Nat.lt_succ_of_lt hk₂ ) ) ( Relation.EqvGen.rel _ _ ( hgaps j hj ( Nat.lt_succ_self j ) ) )

/-
Exact `H₀` characterization for an ordered point cloud: two points are connected
at scale `ε` iff every consecutive gap between them has already appeared.
-/
theorem connectedAt_iff_all_intermediate_gaps {x : ℕ → ℝ} (hx : StrictMono x)
    {ε : ℝ} {i j : ℕ} (hij : i ≤ j) :
    ConnectedAt x ε i j ↔ ∀ k, i ≤ k → k < j → Close x ε k (k + 1) := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · intro k hk₁ hk₂;
    by_contra h_contra;
    have h_large_gap : ε < x (k + 1) - x k := by
      exact lt_of_not_ge fun h => h_contra <| by rw [ Close ] ; exact abs_le.mpr ⟨ by linarith [ hx.monotone ( Nat.le_succ k ) ], by linarith [ hx.monotone ( Nat.le_succ k ) ] ⟩ ;
    exact absurd ( large_gap_separates_components hx h_large_gap h ) ( by aesop );
  · exact small_gaps_connect hij h

/-
Equivalently, if `i < j`, the first scale at which the endpoints can be connected
is the maximum of their intervening consecutive gaps (expressed without a finite maximum).
-/
theorem connection_threshold_exact {x : ℕ → ℝ} (hx : StrictMono x)
    {ε : ℝ} {i j : ℕ} (hij : i ≤ j) :
    ConnectedAt x ε i j ↔ ∀ k, i ≤ k → k < j → x (k + 1) - x k ≤ ε := by
  rw [ connectedAt_iff_all_intermediate_gaps hx hij ];
  constructor <;> intro h k hk₁ hk₂ <;> have := h k hk₁ hk₂ <;> unfold Close at * <;> cases abs_cases ( x k - x ( k + 1 ) ) <;> cases abs_cases ( x ( k + 1 ) - x k ) <;> linarith [ hx k.lt_succ_self ]

/-- The first six primes, indexed by `Fin 6`, for a finite certified example. -/
def firstSixPrimes (i : Fin 6) : ℝ := ([2, 3, 5, 7, 11, 13] : List ℝ)[i]

/-
The first six prime positions are strictly increasing.
-/
theorem firstSixPrimes_strictMono : StrictMono firstSixPrimes := by
  intro i j hij;
  fin_cases i <;> fin_cases j <;> simp +decide at hij ⊢;
  all_goals unfold firstSixPrimes; norm_num;

/-
Certified small case: among the first six primes, positions `2` and `13` become
connected exactly at scale `4`, the largest intervening gap (`7` to `11`).
-/
theorem firstSixPrimes_endpoint_threshold (ε : ℝ) :
    Relation.EqvGen (fun i j : Fin 6 => |firstSixPrimes i - firstSixPrimes j| ≤ ε)
      ⟨0, by decide⟩ ⟨5, by decide⟩ ↔ 4 ≤ ε := by
  constructor <;> intro h;
  · contrapose! h;
    intro H;
    have h_cut : ∀ i j : Fin 6, |firstSixPrimes i - firstSixPrimes j| ≤ ε → (i.val ≤ 3 ↔ j.val ≤ 3) := by
      unfold firstSixPrimes; norm_num [ Fin.forall_fin_succ ] ;
      exact ⟨ ⟨ by linarith, by linarith ⟩, ⟨ by linarith, by linarith ⟩, ⟨ by linarith, by linarith ⟩, ⟨ by linarith, by linarith ⟩, ⟨ by linarith, by linarith, by linarith, by linarith ⟩, by linarith, by linarith, by linarith, by linarith ⟩;
    have h_cut : ∀ i j : Fin 6, EqvGen (fun i j => |firstSixPrimes i - firstSixPrimes j| ≤ ε) i j → (i.val ≤ 3 ↔ j.val ≤ 3) := by
      intros i j hij;
      induction hij;
      · exact h_cut _ _ ‹_›;
      · rfl;
      · tauto;
      · grind;
    exact absurd ( h_cut _ _ H ) ( by decide );
  ·
    have h_values : firstSixPrimes ⟨0, by decide⟩ = 2 ∧ firstSixPrimes ⟨1, by decide⟩ = 3 ∧ firstSixPrimes ⟨2, by decide⟩ = 5 ∧ firstSixPrimes ⟨3, by decide⟩ = 7 ∧ firstSixPrimes ⟨4, by decide⟩ = 11 ∧ firstSixPrimes ⟨5, by decide⟩ = 13 := by
      unfold firstSixPrimes; norm_num;
    have h_rel : |firstSixPrimes ⟨0, by decide⟩ - firstSixPrimes ⟨1, by decide⟩| ≤ ε ∧ |firstSixPrimes ⟨1, by decide⟩ - firstSixPrimes ⟨2, by decide⟩| ≤ ε ∧ |firstSixPrimes ⟨2, by decide⟩ - firstSixPrimes ⟨3, by decide⟩| ≤ ε ∧ |firstSixPrimes ⟨3, by decide⟩ - firstSixPrimes ⟨4, by decide⟩| ≤ ε ∧ |firstSixPrimes ⟨4, by decide⟩ - firstSixPrimes ⟨5, by decide⟩| ≤ ε := by
      grind +splitIndPred;
    exact EqvGen.trans _ _ _ ( EqvGen.rel _ _ h_rel.1 ) ( EqvGen.trans _ _ _ ( EqvGen.rel _ _ h_rel.2.1 ) ( EqvGen.trans _ _ _ ( EqvGen.rel _ _ h_rel.2.2.1 ) ( EqvGen.trans _ _ _ ( EqvGen.rel _ _ h_rel.2.2.2.1 ) ( EqvGen.rel _ _ h_rel.2.2.2.2 ) ) ) )

end PrimeRipsTopology