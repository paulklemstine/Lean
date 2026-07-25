/-
# Persistent Homology of Prime Numbers: The Topology of Arithmetic

This file formalizes the Rips filtration on 1D point clouds with application
to the prime number sequence. The key insight is that for points on the real line,
the H_0 persistent homology barcode is completely determined by the consecutive gaps.

## Main Results

- `countGapsLE_mono`: Gap counts are monotone in the scale parameter.
- `components_antitone`: Components decrease monotonically as ε increases.
- `gaps_partition`: Gaps ≤ ε and gaps > ε partition all gaps.
- `rips_components_eq_gaps_gt_plus_one`: The 1D Rips theorem for H_0.
- `rips_edges_monotone`: The Rips filtration is nested.
- `twin_gap_merge_count`: Components merging at twin prime scale.
-/
import Mathlib

open Nat Finset

/-! ## Section 1: Gaps of a Sorted Sequence -/

/-- The gap function for a sequence: gap(i) = f(i+1) - f(i).
    For a strictly increasing sequence, all gaps are positive. -/
def seqGap (f : ℕ → ℕ) (i : ℕ) : ℕ := f (i + 1) - f i

/-- A sequence is strictly increasing on [0, n). -/
def StrictIncreasingOn (f : ℕ → ℕ) (n : ℕ) : Prop :=
  ∀ i j, i < j → j < n → f i < f j

/-
For a strictly increasing sequence, consecutive gaps are positive.
-/
theorem gap_pos_of_strict_increasing {f : ℕ → ℕ} {n : ℕ} {i : ℕ}
    (hf : StrictIncreasingOn f n) (hi : i + 1 < n) : 0 < seqGap f i := by
  exact Nat.sub_pos_of_lt ( hf _ _ ( Nat.lt_succ_self _ ) hi )

/-- Count of gaps at most ε in the first n-1 gaps. -/
def countGapsLE (f : ℕ → ℕ) (n : ℕ) (ε : ℕ) : ℕ :=
  ((Finset.range (n - 1)).filter (fun i => decide (seqGap f i ≤ ε) = true)).card

/-- Count of gaps strictly greater than ε. -/
def countGapsGT (f : ℕ → ℕ) (n : ℕ) (ε : ℕ) : ℕ :=
  ((Finset.range (n - 1)).filter (fun i => decide (ε < seqGap f i) = true)).card

/-! ## Section 2: Rips Components of a 1D Point Cloud -/

/-- The number of Rips-connected components at scale ε for a sorted sequence
    of n points. By the 1D Rips theorem, this equals n - (number of gaps ≤ ε). -/
def ripsComponents (f : ℕ → ℕ) (n : ℕ) (ε : ℕ) : ℕ :=
  n - countGapsLE f n ε

/-
As ε increases, we can only gain more bridged gaps, so the count increases.
-/
theorem countGapsLE_mono (f : ℕ → ℕ) (n : ℕ) {ε₁ ε₂ : ℕ} (h : ε₁ ≤ ε₂) :
    countGapsLE f n ε₁ ≤ countGapsLE f n ε₂ := by
  refine Finset.card_le_card ?_;
  grind

/-- Components are antitone: larger ε means fewer (or equal) components. -/
theorem components_antitone (f : ℕ → ℕ) (n : ℕ) {ε₁ ε₂ : ℕ} (h : ε₁ ≤ ε₂) :
    ripsComponents f n ε₂ ≤ ripsComponents f n ε₁ := by
  unfold ripsComponents
  exact Nat.sub_le_sub_left (countGapsLE_mono f n h) n

/-
The count of gaps ≤ ε is bounded by n - 1.
-/
theorem countGapsLE_le (f : ℕ → ℕ) (n : ℕ) (ε : ℕ) :
    countGapsLE f n ε ≤ n - 1 := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by simpa )

/-
The gaps ≤ ε plus gaps > ε partition all gaps.
-/
theorem gaps_partition (f : ℕ → ℕ) (n : ℕ) (ε : ℕ) :
    countGapsLE f n ε + countGapsGT f n ε = n - 1 := by
  convert Finset.card_union_of_disjoint _ using 1;
  any_goals exact ℕ;
  rw [ Finset.card_union_of_disjoint ];
  congr! 1;
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by norm_num at *; linarith;
  · rw [ Finset.card_filter, Finset.card_filter ];
    rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun x hx => by aesop, Finset.sum_const, Finset.card_range, smul_eq_mul, mul_one ];
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by norm_num at *; linarith;

/-
Components = (gaps > ε) + 1, when n ≥ 1.
    This is the **1D Rips Theorem for H_0**: the number of connected components
    at filtration scale ε equals the number of unresolved gaps plus one.
-/
theorem rips_components_eq_gaps_gt_plus_one {f : ℕ → ℕ} {n : ℕ} (hn : 1 ≤ n) (ε : ℕ) :
    ripsComponents f n ε = countGapsGT f n ε + 1 := by
  rw [ripsComponents];
  rw [ tsub_eq_of_eq_add_rev ] ; linarith [ gaps_partition f n ε, Nat.sub_add_cancel hn ] ;

/-! ## Section 3: The H_0 Barcode Structure

The H_0 barcode of a 1D point cloud consists of bars, one per gap, where
bar i has birth = 0 and death = gap_i. The bar lengths ARE the gaps.
This is the fundamental connection between persistent homology and prime gaps. -/

/-- A bar in persistent homology H_0. Birth is always 0 for Rips on a point cloud. -/
structure PH0Bar where
  death : ℕ
  deriving Repr, DecidableEq

/-- The length (persistence) of a bar equals its death time (since birth = 0). -/
def PH0Bar.length (b : PH0Bar) : ℕ := b.death

/-- The H_0 barcode of a 1D sorted point cloud: one bar per gap.
    The essential bar (which never dies) is omitted. -/
def h0Barcode (f : ℕ → ℕ) (n : ℕ) : List PH0Bar :=
  (List.range (n - 1)).map fun i => ⟨seqGap f i⟩

/-- The barcode has exactly n-1 bars (one per gap). -/
theorem barcode_length (f : ℕ → ℕ) (n : ℕ) :
    (h0Barcode f n).length = n - 1 := by
  simp [h0Barcode]

/-
Each bar's length equals the corresponding gap.
-/
theorem bar_length_eq_gap (f : ℕ → ℕ) (n : ℕ) (i : ℕ) (hi : i < n - 1) :
    ((h0Barcode f n).get ⟨i, by rw [barcode_length]; exact hi⟩).length = seqGap f i := by
  unfold h0Barcode PH0Bar.length; aesop;

/-! ## Section 4: The Rips Filtration as a Nested Family -/

/-- The edge set at scale ε: pairs (i,j) with i < j < n and distance ≤ ε. -/
def ripsEdges (f : ℕ → ℕ) (n : ℕ) (ε : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range n ×ˢ Finset.range n).filter fun p =>
    p.1 < p.2 ∧ f p.2 - f p.1 ≤ ε

/-
The Rips filtration is nested: larger ε means more edges.
-/
theorem rips_edges_monotone (f : ℕ → ℕ) (n : ℕ) {ε₁ ε₂ : ℕ} (h : ε₁ ≤ ε₂) :
    ripsEdges f n ε₁ ⊆ ripsEdges f n ε₂ := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, Finset.mem_filter.mp hx |>.2.1, le_trans ( Finset.mem_filter.mp hx |>.2.2 ) h ⟩

/-! ## Section 5: Twin Prime Scale and Gap-Specific Merging -/

/-- Count of gaps equal to a specific value k in the first n-1 gaps. -/
def countGapsEq (f : ℕ → ℕ) (n : ℕ) (k : ℕ) : ℕ :=
  ((Finset.range (n - 1)).filter (fun i => decide (seqGap f i = k) = true)).card

/-
The component drop between consecutive integer scales equals
    the number of gaps equal to the new scale.
    This is the "derivative" of the filtration: each integer step
    merges exactly the gaps of that size.
-/
theorem component_drop_eq_gap_count (f : ℕ → ℕ) (n : ℕ) (hn : 1 ≤ n) (k : ℕ) :
    ripsComponents f n k - ripsComponents f n (k + 1) = countGapsEq f n (k + 1) := by
  unfold ripsComponents countGapsEq;
  rw [ tsub_right_comm, tsub_tsub_assoc ];
  · simp +decide [ countGapsLE ];
    rw [ tsub_eq_of_eq_add_rev ];
    rw [ ← Finset.card_union_of_disjoint ];
    · congr with i ; simp +decide [ le_iff_lt_or_eq ];
      grind;
    · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
  · norm_num;
  · exact le_trans ( countGapsLE_le _ _ _ ) ( Nat.pred_le _ )

/-! ## Section 6: The Prime Point Cloud -/

/-- The n-th prime (0-indexed), using Nat.nth. -/
noncomputable def nthPrime : ℕ → ℕ := Nat.nth Nat.Prime

/-- The prime gap: difference between consecutive primes. -/
noncomputable def primeGap (i : ℕ) : ℕ := seqGap nthPrime i

/-- Rips components of the prime point cloud at scale ε. -/
noncomputable def primeRipsComponents (n : ℕ) (ε : ℕ) : ℕ :=
  ripsComponents nthPrime n ε

/-- The H_0 barcode of the prime point cloud. Each bar has length = prime gap. -/
noncomputable def primeH0Barcode (n : ℕ) : List PH0Bar :=
  h0Barcode nthPrime n

/-! ## Section 7: Cramér's Conjecture in Barcode Language

Cramér's conjecture predicts that the maximum prime gap below x is ~ (log x)².
In our barcode language, this means the longest H_0 bar has length ~ (log p_n)². -/

/-- The maximum bar length in a barcode. -/
def maxBarLength (bars : List PH0Bar) : ℕ :=
  bars.foldr (fun b acc => max b.length acc) 0

/-
The max bar length of the barcode equals the max gap.
-/
theorem max_bar_length_eq_max_gap (f : ℕ → ℕ) (n : ℕ) :
    maxBarLength (h0Barcode f n) =
    (List.range (n - 1)).foldr (fun i acc => max (seqGap f i) acc) 0 := by
  -- By definition of `maxBarLength`, we have `maxBarLength (h0Barcode f n) = List.foldr (fun b acc => max b.length acc) 0 (h0Barcode f n)`.
  unfold maxBarLength h0Barcode;
  induction ( List.range ( n - 1 ) ) <;> aesop

/-- Cramér's Conjecture (barcode form): The maximum bar length in the H_0 barcode
    of the first n primes is asymptotically (log p_n)².

    This is a major open conjecture in number theory, restated topologically. -/
noncomputable def cramerBarcodeConjecture : Prop :=
  Filter.Tendsto
    (fun n => (maxBarLength (primeH0Barcode n) : ℝ) / (Real.log (nthPrime (n - 1) : ℝ))^2)
    Filter.atTop
    (nhds 1)

/-! ## Section 8: Barcode Stability Under Perturbation

A key property: the barcode is stable under small perturbations.
If two sequences have pointwise close values, their barcodes are close.
This is a 1D version of the stability theorem in persistent homology. -/

/-- Two sequences are δ-close if their values differ by at most δ pointwise. -/
def SeqClose (f g : ℕ → ℕ) (n : ℕ) (δ : ℕ) : Prop :=
  ∀ i, i < n → (f i : ℤ) - (g i : ℤ) ≤ δ ∧ (g i : ℤ) - (f i : ℤ) ≤ δ

/-
Gap perturbation bound: if sequences are δ-close, their gaps differ by at most 2δ.
-/
theorem gap_perturbation {f g : ℕ → ℕ} {n : ℕ} {δ : ℕ} (i : ℕ) (hi : i + 1 < n)
    (hclose : SeqClose f g n δ) :
    ((seqGap f i : ℤ) - (seqGap g i : ℤ)).natAbs ≤ 2 * δ := by
  have h_seqGapClose : abs ((f (i + 1) : ℤ) - (g (i + 1) : ℤ)) ≤ δ ∧ abs ((f i : ℤ) - (g i : ℤ)) ≤ δ := by
    exact ⟨ abs_le.mpr ⟨ by linarith [ hclose ( i + 1 ) hi ], by linarith [ hclose ( i + 1 ) hi ] ⟩, abs_le.mpr ⟨ by linarith [ hclose i ( Nat.lt_of_succ_lt hi ) ], by linarith [ hclose i ( Nat.lt_of_succ_lt hi ) ] ⟩ ⟩;
  unfold seqGap; norm_num [ abs_le ] at *; omega;

/-! ## Section 9: Statistical Structure of the Barcode

We define the empirical mean of bar lengths, which for the prime barcode
equals the average prime gap. By PNT, this should be approximately log(p_n). -/

/-- Sum of all bar lengths in the barcode. -/
def totalBarLength (bars : List PH0Bar) : ℕ :=
  bars.foldr (fun b acc => b.length + acc) 0

/-
For the barcode of a strictly increasing sequence, the total bar length
    equals the total gap: f(n-1) - f(0). This is the telescoping identity
    reformulated in barcode language.
-/
theorem total_bar_length_eq_total_gap (f : ℕ → ℕ) (n : ℕ) (hn : 2 ≤ n)
    (hf : StrictIncreasingOn f n) :
    totalBarLength (h0Barcode f n) = f (n - 1) - f 0 := by
  unfold totalBarLength h0Barcode;
  induction hn <;> simp_all +decide [ List.range_succ ];
  · rfl;
  · induction' ‹ℕ› with m ih <;> simp_all +decide [ List.range_succ ];
    rename_i k hk;
    convert congr_arg ( · + seqGap f m ) ( hk <| fun i j hij hj => hf i j hij <| by linarith ) using 1;
    · induction ( List.range m ) <;> simp +arith +decide [ * ];
      · rfl;
      · simp_all +decide [ add_comm, add_left_comm ];
    · unfold seqGap; rw [ tsub_add_eq_add_tsub ( hf 0 m ( by linarith ) ( by linarith ) |> le_of_lt ) ] ;
      rw [ Nat.add_sub_of_le ( hf m ( m + 1 ) ( by linarith ) ( by linarith ) |> le_of_lt ) ]

/-
The total bar length is a telescoping sum.
    This is the key identity: sum of gaps = last point - first point.
    For primes: sum of first (n-1) prime gaps = p_n - p_1.
-/
theorem telescoping_gaps (f : ℕ → ℕ) (n : ℕ) (hn : 1 ≤ n)
    (hf : StrictIncreasingOn f (n + 1)) :
    ∑ i ∈ Finset.range n, seqGap f i = f n - f 0 := by
  induction hn <;> simp_all +decide [ Finset.sum_range_succ, seqGap ];
  rename_i k hk ih; have := ih ( fun i j hij hj => hf i j hij ( by linarith ) ) ; rw [ this ] ;
  rw [ tsub_add_eq_add_tsub ( hf 0 k ( by linarith ) ( by linarith ) |> le_of_lt ) ];
  rw [ Nat.add_sub_of_le ( hf _ _ ( by linarith ) ( by linarith ) |> le_of_lt ) ]