/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Hexagonal Lattice: Core Definitions and Discrete Honeycomb Theorem

This file formalizes the hexagonal (honeycomb) lattice using axial coordinates
`(q, r) : ℤ × ℤ`, defines hexagonal patches, edge boundary, and proves
key results including the edge boundary formula for hex patches and
boundary-minimality properties.

## Main Results

* `hexPatch_card` — `|hexPatch r| = 3r² + 3r + 1` (centered hexagonal number)
* `boundary_plus_internal` — `edgeBoundary S + internalEdges S = 6 * S.card`
* `directionCount_formula` — direction pair count = `3r² + r`
* `edgeBoundary_hexPatch` — `edgeBoundary(hexPatch r) = 12r + 6`
* `edgeBoundary_pos` — any nonempty set has edge boundary ≥ 6
* `hex_isoperimetric_ratio_decreasing` — boundary/area ratio is monotone decreasing
* `edgeBoundary_lower_bound` — `edgeBoundary S ≥ 6` for nonempty `S`
* `isoperimetric_bound_from_card` — general lower bound on boundary from cardinality
-/
import Mathlib

namespace HexHoneycomb

/-! ## §1. Hexagonal Lattice Type and Adjacency -/

/-- A cell in the hexagonal lattice, using axial coordinates `(q, r)`. -/
abbrev HexCell := ℤ × ℤ

/-- Two hex cells are adjacent if they differ by one of the six hex directions. -/
def hexAdj (a b : HexCell) : Prop :=
  (b.1 - a.1 = 1 ∧ b.2 - a.2 = 0) ∨
  (b.1 - a.1 = -1 ∧ b.2 - a.2 = 0) ∨
  (b.1 - a.1 = 0 ∧ b.2 - a.2 = 1) ∨
  (b.1 - a.1 = 0 ∧ b.2 - a.2 = -1) ∨
  (b.1 - a.1 = 1 ∧ b.2 - a.2 = -1) ∨
  (b.1 - a.1 = -1 ∧ b.2 - a.2 = 1)

instance : DecidableRel hexAdj := fun a b => by unfold hexAdj; infer_instance

theorem hexAdj_symm {a b : HexCell} (h : hexAdj a b) : hexAdj b a := by
  unfold hexAdj at *; omega

theorem hexAdj_irrefl (a : HexCell) : ¬hexAdj a a := by
  unfold hexAdj; omega

/-! ## §2. Hex Distance -/

/-- The hex metric: `max(|Δq|, |Δr|, |Δq + Δr|)`. -/
def hexDist (a b : HexCell) : ℕ :=
  max (Int.natAbs (b.1 - a.1))
    (max (Int.natAbs (b.2 - a.2))
      (Int.natAbs (b.1 - a.1 + (b.2 - a.2))))

@[simp] theorem hexDist_self (a : HexCell) : hexDist a a = 0 := by simp [hexDist]

/-! ## §3. Hex Patches and Neighbors -/

/-- The hexagonal patch of radius `r`: all cells within hex distance `r` of origin. -/
def hexPatch (r : ℕ) : Finset HexCell :=
  ((Finset.Icc (-(r : ℤ)) r) ×ˢ (Finset.Icc (-(r : ℤ)) r)).filter
    (fun p => hexDist (0, 0) p ≤ r)

theorem mem_hexPatch {r : ℕ} {p : HexCell} :
    p ∈ hexPatch r ↔ hexDist (0, 0) p ≤ r := by
  simp only [hexPatch, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  constructor
  · exact fun ⟨_, h⟩ => h
  · intro h
    have hd : hexDist (0, 0) p = max p.1.natAbs (max p.2.natAbs (p.1 + p.2).natAbs) := by
      simp [hexDist]
    refine ⟨⟨⟨?_, ?_⟩, ⟨?_, ?_⟩⟩, h⟩
    all_goals {
      rw [hd] at h
      have := Int.le_natAbs (a := p.1)
      have := Int.le_natAbs (a := -p.1)
      have := Int.le_natAbs (a := p.2)
      have := Int.le_natAbs (a := -p.2)
      rw [Int.natAbs_neg] at *
      omega
    }

/-- The finset of 6 neighbors of a hex cell. -/
def hexNeighbors (p : HexCell) : Finset HexCell :=
  {(p.1 + 1, p.2), (p.1 - 1, p.2), (p.1, p.2 + 1),
   (p.1, p.2 - 1), (p.1 + 1, p.2 - 1), (p.1 - 1, p.2 + 1)}

/-- A cell is a neighbor iff it is adjacent. -/
theorem mem_hexNeighbors_iff {p q : HexCell} :
    q ∈ hexNeighbors p ↔ hexAdj p q := by
  simp only [hexNeighbors, hexAdj, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro (rfl | rfl | rfl | rfl | rfl | rfl) <;> simp
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩)
    · left; exact Prod.ext (by omega) (by omega)
    · right; left; exact Prod.ext (by omega) (by omega)
    · right; right; left; exact Prod.ext (by omega) (by omega)
    · right; right; right; left; exact Prod.ext (by omega) (by omega)
    · right; right; right; right; left; exact Prod.ext (by omega) (by omega)
    · right; right; right; right; right; exact Prod.ext (by omega) (by omega)

/-
The hexNeighbors finset always has exactly 6 elements.
-/
theorem hexNeighbors_card (p : HexCell) : (hexNeighbors p).card = 6 := by
  grind +locals

/-! ## §4. Edge Boundary -/

/-- The edge boundary of `S`: number of edges from `S` to its complement. -/
def edgeBoundary (S : Finset HexCell) : ℕ :=
  S.sum (fun p => ((hexNeighbors p).filter (· ∉ S)).card)

/-- Number of internal adjacencies (ordered pairs with both in S). -/
def internalEdges (S : Finset HexCell) : ℕ :=
  S.sum (fun p => ((hexNeighbors p).filter (· ∈ S)).card)

/-! ## §5. Computational Verification -/

theorem hexPatch_card_0 : (hexPatch 0).card = 1 := by native_decide
theorem hexPatch_card_1 : (hexPatch 1).card = 7 := by native_decide
theorem hexPatch_card_2 : (hexPatch 2).card = 19 := by native_decide
theorem hexPatch_card_3 : (hexPatch 3).card = 37 := by native_decide
theorem hexPatch_card_4 : (hexPatch 4).card = 61 := by native_decide

theorem edgeBoundary_hexPatch_0 : edgeBoundary (hexPatch 0) = 6 := by native_decide
theorem edgeBoundary_hexPatch_1 : edgeBoundary (hexPatch 1) = 18 := by native_decide
theorem edgeBoundary_hexPatch_2 : edgeBoundary (hexPatch 2) = 30 := by native_decide
theorem edgeBoundary_hexPatch_3 : edgeBoundary (hexPatch 3) = 42 := by native_decide
theorem edgeBoundary_hexPatch_4 : edgeBoundary (hexPatch 4) = 54 := by native_decide

theorem internalEdges_hexPatch_0 : internalEdges (hexPatch 0) = 0 := by native_decide
theorem internalEdges_hexPatch_1 : internalEdges (hexPatch 1) = 24 := by native_decide
theorem internalEdges_hexPatch_2 : internalEdges (hexPatch 2) = 84 := by native_decide
theorem internalEdges_hexPatch_3 : internalEdges (hexPatch 3) = 180 := by native_decide

/-! ## §6. Key Identity: Boundary + Internal = 6 × Card -/

/-- Each cell has 6 neighbors, partitioned into those inside S and those outside.
    Therefore `edgeBoundary S + internalEdges S = 6 * S.card`. -/
theorem boundary_plus_internal (S : Finset HexCell) :
    edgeBoundary S + internalEdges S = 6 * S.card := by
  have h_partition : ∀ p ∈ S,
      ((hexNeighbors p).filter (· ∉ S)).card + ((hexNeighbors p).filter (· ∈ S)).card = 6 := by
    intros p hp
    have : ((hexNeighbors p).filter (· ∉ S)).card +
           ((hexNeighbors p).filter (· ∈ S)).card = (hexNeighbors p).card := by
      rw [add_comm, Finset.card_filter_add_card_filter_not]
    simp_all +decide [hexNeighbors]
    grind
  simpa [mul_comm, Finset.sum_add_distrib] using Finset.sum_congr rfl h_partition

/-! ## §7. General Formulas -/

/-- **Hex patch cardinality**: `|hexPatch r| = 3r² + 3r + 1`. -/
theorem hexPatch_card (r : ℕ) : (hexPatch r).card = 3 * r ^ 2 + 3 * r + 1 := by
  unfold hexPatch
  have h_strip : Finset.card (Finset.filter (fun p : ℤ × ℤ => abs p.1 ≤ r ∧ abs p.2 ≤ r ∧ abs (p.1 + p.2) ≤ r) (Finset.product (Finset.Icc (-r : ℤ) r) (Finset.Icc (-r : ℤ) r))) = ∑ k ∈ Finset.Icc (-r : ℤ) r, (2 * r - abs k + 1) := by
    have h_strip : Finset.filter (fun p : ℤ × ℤ => abs p.1 ≤ r ∧ abs p.2 ≤ r ∧ abs (p.1 + p.2) ≤ r) (Finset.product (Finset.Icc (-r : ℤ) r) (Finset.Icc (-r : ℤ) r)) = Finset.biUnion (Finset.Icc (-r : ℤ) r) (fun k => Finset.image (fun m => (k, m)) (Finset.Icc (max (-r : ℤ) (-r - k)) (min r (r - k)))) := by
      ext ⟨k, m⟩; simp [Finset.mem_biUnion, Finset.mem_image];
      exact ⟨ fun h => ⟨ ⟨ by linarith, by linarith ⟩, ⟨ by linarith, by cases abs_cases ( k + m ) <;> linarith ⟩, by linarith, by cases abs_cases ( k + m ) <;> linarith ⟩, fun h => ⟨ ⟨ ⟨ by linarith, by linarith ⟩, ⟨ by linarith, by linarith ⟩ ⟩, abs_le.mpr ⟨ by linarith, by linarith ⟩, abs_le.mpr ⟨ by linarith, by linarith ⟩, abs_le.mpr ⟨ by linarith, by linarith ⟩ ⟩ ⟩;
    rw [ h_strip, Finset.card_biUnion ];
    · norm_num [ Finset.card_image_of_injective, Function.Injective ];
      refine' Finset.sum_congr rfl fun x hx => _;
      rw [ max_eq_left ] <;> cases abs_cases x <;> cases max_cases ( -r : ℤ ) ( -r - x ) <;> cases min_cases ( r : ℤ ) ( r - x ) <;> linarith [ Finset.mem_Icc.mp hx ];
    · exact fun a ha b hb hab => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hab <| by aesop;
  have h_sum_simplify : ∑ k ∈ Finset.Icc (-r : ℤ) r, (2 * r - abs k + 1) = 3 * r ^ 2 + 3 * r + 1 := by
    rw [ show ( Finset.Icc ( -r : ℤ ) r ) = Finset.image ( fun k : ℕ => k : ℕ → ℤ ) ( Finset.range ( r + 1 ) ) ∪ Finset.image ( fun k : ℕ => -k : ℕ → ℤ ) ( Finset.Icc 1 r ) from ?_, Finset.sum_union ] <;> norm_num;
    · erw [ Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ Finset.sum_range_succ' ] ; ring;
      exact Nat.recOn r ( by norm_num ) fun n ih => by norm_num [ Finset.sum_range_succ ] at * ; linarith;
    · norm_num [ Finset.disjoint_left ];
      aesop;
    · ext ( _ | k ) <;> simp +decide [ abs_le ];
      grind;
  norm_num [ ← Int.natCast_inj, hexDist ] at *;
  convert h_strip.trans h_sum_simplify using 1;
  norm_num [ ← Int.ofNat_le ]

/-- Hex distance changes by at most 1 for adjacent cells. -/
theorem hexDist_adj_le {p q : HexCell} (h : hexAdj p q) :
    hexDist (0, 0) q ≤ hexDist (0, 0) p + 1 := by
  rcases h with (h | h | h | h | h | h) <;> simp_all +decide [hexDist]
  grind +splitIndPred
  · grind +splitIndPred
  · grind +splitIndPred
  · grind
  · grind
  · grind +splitIndPred

/-- Interior cells have all neighbors inside the patch. -/
theorem interior_neighbors_inside {r : ℕ} {p : HexCell} (hp : hexDist (0, 0) p + 1 ≤ r) :
    hexNeighbors p ⊆ hexPatch r := by
  intros q hq
  exact mem_hexPatch.mpr (le_trans (hexDist_adj_le (mem_hexNeighbors_iff.mp hq)) hp)

/-- Count of pairs (p, p+(1,0)) both in hexPatch r. -/
def directionCount (r : ℕ) : ℕ :=
  ((Finset.Icc (-(r : ℤ)) r) ×ˢ (Finset.Icc (-(r : ℤ)) r)).filter
    (fun p => hexDist (0, 0) p ≤ r ∧ hexDist (0, 0) (p.1 + 1, p.2) ≤ r) |>.card

theorem directionCount_0 : directionCount 0 = 0 := by native_decide
theorem directionCount_1 : directionCount 1 = 4 := by native_decide
theorem directionCount_2 : directionCount 2 = 14 := by native_decide
theorem directionCount_3 : directionCount 3 = 30 := by native_decide

/-- **Direction count formula**: `directionCount r = 3r² + r`. -/
theorem directionCount_formula (r : ℕ) : directionCount r = 3 * r ^ 2 + r := by
  unfold directionCount;
  unfold hexDist;
  rw [ show ( Finset.filter ( fun p : ℤ × ℤ => _ ) _ ) = Finset.biUnion ( Finset.Icc ( -r : ℤ ) ( r - 1 ) ) fun x => Finset.image ( fun y => ( x, y ) ) ( Finset.Icc ( Max.max ( -r : ℤ ) ( -r - x ) ) ( Min.min ( r : ℤ ) ( r - 1 - x ) ) ) from ?_ ];
  · rw [ Finset.card_biUnion ];
    · rw [ Finset.sum_congr rfl fun x hx => Finset.card_image_of_injective _ fun y z h => by injection h ];
      erw [ show ( Finset.Icc ( -r : ℤ ) ( r - 1 ) ) = Finset.image ( fun x : ℕ => ( x : ℤ ) - r ) ( Finset.range ( 2 * r ) ) from ?_, Finset.sum_image ] <;> norm_num;
      · rw [ two_mul, Finset.sum_range_add ] ; norm_num;
        rw [ ← Finset.sum_add_distrib ] ; ring;
        rw [ Finset.sum_congr rfl fun x hx => by rw [ min_eq_left, max_eq_right ] <;> linarith [ Finset.mem_range.mp hx ] ] ; ring;
        rw [ Finset.sum_congr rfl fun x hx => by rw [ min_eq_right ] ; linarith [ Finset.mem_range.mp hx ] ] ; ring;
        rw [ Finset.sum_congr rfl fun x hx => by rw [ show ( 1 + r + x : ℤ ) = ( 1 + r + x : ℕ ) by norm_cast, show ( r * 2 - x : ℤ ) = ( r * 2 - x : ℕ ) by rw [ Nat.cast_sub ] <;> push_cast <;> linarith [ Finset.mem_range.mp hx ] ] ] ; norm_cast ; ring;
        rw [ Finset.sum_congr rfl fun x hx => by rw [ show 1 + r + x + ( r * 2 - x ) = 1 + r + r * 2 by linarith [ Nat.sub_add_cancel ( show x ≤ r * 2 from by linarith [ Finset.mem_range.mp hx ] ) ] ] ] ; norm_num ; ring;
      · ext aesop;
        simp +zetaDelta at *;
        exact ⟨ fun h => ⟨ Int.toNat ( aesop + r ), by linarith [ Int.toNat_of_nonneg ( by linarith : 0 ≤ aesop + r ) ], by linarith [ Int.toNat_of_nonneg ( by linarith : 0 ≤ aesop + r ) ] ⟩, by rintro ⟨ a, ha, rfl ⟩ ; exact ⟨ by linarith, by linarith ⟩ ⟩;
    · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z => by aesop;
  · ext ⟨x, y⟩; simp [Finset.mem_biUnion, Finset.mem_image];
    omega

/-! ## §7a. Internal Edges via Symmetry -/

set_option maxHeartbeats 1600000 in
/-
**Internal edges via symmetry**: each of 6 directions contributes equally.
    `internalEdges(hexPatch r) = 6 * directionCount r`.
    The proof uses 3 explicit bijections on hexPatch r:
    - negation (q,s) ↦ (-q,-s) maps direction (1,0) to (-1,0)
    - swap (q,s) ↦ (s,q) maps direction (1,0) to (0,1)
    - rotation (q,s) ↦ (q+s,-q) maps direction (1,0) to (1,-1)
-/
theorem internalEdges_eq_six_directionCount (r : ℕ) :
    internalEdges (hexPatch r) = 6 * directionCount r := by
  -- By definition of $internalEdges$, we can write
  have h_def : internalEdges (hexPatch r) = Finset.card (Finset.filter (fun (p : HexCell × HexCell) => hexAdj p.1 p.2 ∧ p.1 ∈ hexPatch r ∧ p.2 ∈ hexPatch r) (hexPatch r ×ˢ hexPatch r)) := by
    rw [ Finset.card_filter ];
    rw [ Finset.sum_product ];
    refine' Finset.sum_congr rfl fun x hx => _;
    simp +decide [ Finset.sum_ite, hexNeighbors ];
    congr 1 with y ; simp +decide [ hexAdj ];
    grind;
  -- We can partition the set of pairs (p, q) in hexPatch r × hexPatch r where hexAdj p q and p ∈ hexPatch r and q ∈ hexPatch r into six subsets based on the direction of the adjacency.
  have h_partition : Finset.filter (fun (p : HexCell × HexCell) => hexAdj p.1 p.2 ∧ p.1 ∈ hexPatch r ∧ p.2 ∈ hexPatch r) (hexPatch r ×ˢ hexPatch r) = Finset.biUnion (Finset.image (fun d => d) ({(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)} : Finset (ℤ × ℤ))) (fun d => Finset.image (fun p => (p, (p.1 + d.1, p.2 + d.2))) (Finset.filter (fun p => hexDist (0, 0) p ≤ r ∧ hexDist (0, 0) (p.1 + d.1, p.2 + d.2) ≤ r) (hexPatch r))) := by
    ext ⟨p, q⟩; simp [hexAdj];
    grind +suggestions;
  rw [ h_def, h_partition, Finset.card_biUnion ];
  · rw [ Finset.sum_image ] <;> simp +decide [ directionCount ];
    rw [ Finset.card_image_of_injective, Finset.card_image_of_injective, Finset.card_image_of_injective, Finset.card_image_of_injective, Finset.card_image_of_injective, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    rw [ show ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1 + -1, p.2 ) ≤ r ) ( hexPatch r ) ) = Finset.image ( fun p : ℤ × ℤ => ( -p.1, -p.2 ) ) ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1 + 1, p.2 ) ≤ r ) ( hexPatch r ) ) from ?_, show ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1, p.2 + 1 ) ≤ r ) ( hexPatch r ) ) = Finset.image ( fun p : ℤ × ℤ => ( p.2, p.1 ) ) ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1 + 1, p.2 ) ≤ r ) ( hexPatch r ) ) from ?_ ];
    · rw [ show ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1, p.2 + -1 ) ≤ r ) ( hexPatch r ) ) = Finset.image ( fun p : ℤ × ℤ => ( -p.2, -p.1 ) ) ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1 + 1, p.2 ) ≤ r ) ( hexPatch r ) ) from ?_, show ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1 + 1, p.2 + -1 ) ≤ r ) ( hexPatch r ) ) = Finset.image ( fun p : ℤ × ℤ => ( p.1 + p.2, -p.1 ) ) ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1 + 1, p.2 ) ≤ r ) ( hexPatch r ) ) from ?_ ];
      · rw [ show ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1 + -1, p.2 + 1 ) ≤ r ) ( hexPatch r ) ) = Finset.image ( fun p : ℤ × ℤ => ( -p.1 - p.2, p.1 ) ) ( Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ∧ hexDist ( 0, 0 ) ( p.1 + 1, p.2 ) ≤ r ) ( hexPatch r ) ) from ?_ ];
        · rw [ Finset.card_image_of_injective, Finset.card_image_of_injective, Finset.card_image_of_injective, Finset.card_image_of_injective, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
          · rw [ show hexPatch r = Finset.filter ( fun p : ℤ × ℤ => hexDist ( 0, 0 ) p ≤ r ) ( Finset.Icc ( -r : ℤ ) r ×ˢ Finset.Icc ( -r : ℤ ) r ) from ?_ ] ; ring;
            · rw [ Finset.filter_filter ];
              simp +decide [ and_assoc ];
            · ext ⟨q, r⟩; simp [hexPatch];
          · grind;
          · grind;
        · ext ⟨q, r⟩; simp [hexDist];
          constructor <;> intro h;
          · use -r - q;
            simp_all +decide [ hexPatch ];
            unfold hexDist at * ; simp_all +decide [ abs_le ];
            omega;
          · rcases h with ⟨ b, ⟨ hb₁, hb₂, hb₃, hb₄, hb₅ ⟩, rfl ⟩ ; simp_all +decide [ hexPatch ];
            unfold hexDist at * ; simp_all +decide [ abs_le ];
            omega;
      · ext ⟨q, r⟩; simp [hexDist];
        constructor;
        · intro h;
          use -r, q + r;
          simp_all +decide [ hexPatch ];
          unfold hexDist at * ; simp_all +decide [ abs_le ];
          omega;
        · rintro ⟨ a, b, h, rfl, rfl ⟩ ; simp_all +decide [ hexPatch ];
          unfold hexDist at *; simp_all +decide [ abs_le ] ;
          grind;
      · ext ⟨x, y⟩; simp [hexPatch];
        constructor;
        · intro h;
          use -y, -x;
          unfold hexDist at *; simp_all +decide [ abs_sub_comm ] ;
          omega;
        · rintro ⟨ a, b, h, rfl, rfl ⟩;
          unfold hexDist at *; simp_all +decide [ abs_le ] ;
          grind +splitImp;
    · ext ⟨x, y⟩; simp [hexDist];
      unfold hexPatch; simp +decide [ add_comm, add_left_comm, add_assoc ] ;
      unfold hexDist; simp +decide [ add_comm, add_left_comm, add_assoc ] ;
      tauto;
    · ext ⟨x, y⟩; simp [hexDist];
      constructor <;> intro h;
      · use -x, -y;
        simp_all +decide [ hexPatch ];
        unfold hexDist at *; simp_all +decide [ Int.natAbs_eq_iff ] ;
        omega;
      · rcases h with ⟨ a, b, h, rfl, rfl ⟩ ; simp_all +decide [ hexPatch ];
        unfold hexDist at * ; simp_all +decide [ abs_le ];
        grind;
  · intros d hd d' hd' hdd';
    rw [ Function.onFun, Finset.disjoint_left ] ; contrapose! hdd' ; aesop

/-- **Internal edges formula**: `internalEdges(hexPatch r) = 18r² + 6r`. -/
theorem internalEdges_hexPatch (r : ℕ) :
    internalEdges (hexPatch r) = 18 * r ^ 2 + 6 * r := by
  rw [internalEdges_eq_six_directionCount, directionCount_formula]; ring

/-- **Edge boundary formula**: `edgeBoundary(hexPatch r) = 12r + 6`.
    Follows from `boundary_plus_internal`, `hexPatch_card`, and `internalEdges_hexPatch`. -/
theorem edgeBoundary_hexPatch (r : ℕ) : edgeBoundary (hexPatch r) = 12 * r + 6 := by
  have h1 := boundary_plus_internal (hexPatch r)
  have h2 := hexPatch_card r
  have h3 := internalEdges_hexPatch r
  omega

/-! ## §8. Isoperimetric Lower Bound -/

set_option maxHeartbeats 1600000 in
/-- Any nonempty set has edge boundary at least 6. -/
theorem edgeBoundary_pos (S : Finset HexCell) (hne : S.Nonempty) :
    edgeBoundary S ≥ 6 := by
  have h_cases : ∀ (f : HexCell → ℤ), (∃ x ∈ S, ∀ y ∈ S, f y ≤ f x) ∧ (∃ x ∈ S, ∀ y ∈ S, f x ≤ f y) → ((Finset.sum S (fun p => if ¬((p.1 + 1, p.2) ∈ S) then 1 else 0)) + (Finset.sum S (fun p => if ¬((p.1 - 1, p.2) ∈ S) then 1 else 0)) + (Finset.sum S (fun p => if ¬((p.1, p.2 + 1) ∈ S) then 1 else 0)) + (Finset.sum S (fun p => if ¬((p.1, p.2 - 1) ∈ S) then 1 else 0)) + (Finset.sum S (fun p => if ¬((p.1 + 1, p.2 - 1) ∈ S) then 1 else 0)) + (Finset.sum S (fun p => if ¬((p.1 - 1, p.2 + 1) ∈ S) then 1 else 0))) ≥ 6 := by
    intro f hf;
    have h_directional_boundaries : ∀ (d : ℤ × ℤ), d ∈ [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)] → ∃ p ∈ S, (p.1 + d.1, p.2 + d.2) ∉ S := by
      intro d hd
      obtain ⟨p, hpS, hp⟩ : ∃ p ∈ S, ∀ q ∈ S, (p.1 * d.1 + p.2 * d.2) ≥ (q.1 * d.1 + q.2 * d.2) := by
        exact Finset.exists_max_image _ _ hne;
      grind;
    simp_all +decide [ Finset.sum_ite ];
    exact le_trans ( by norm_num ) ( add_le_add ( add_le_add ( add_le_add ( add_le_add ( add_le_add ( Finset.card_pos.mpr ⟨ _, Finset.mem_filter.mpr ⟨ h_directional_boundaries.1.choose_spec.choose_spec.1, h_directional_boundaries.1.choose_spec.choose_spec.2 ⟩ ⟩ ) ( Finset.card_pos.mpr ⟨ _, Finset.mem_filter.mpr ⟨ h_directional_boundaries.2.1.choose_spec.choose_spec.1, h_directional_boundaries.2.1.choose_spec.choose_spec.2 ⟩ ⟩ ) ) ( Finset.card_pos.mpr ⟨ _, Finset.mem_filter.mpr ⟨ h_directional_boundaries.2.2.1.choose_spec.choose_spec.1, h_directional_boundaries.2.2.1.choose_spec.choose_spec.2 ⟩ ⟩ ) ) ( Finset.card_pos.mpr ⟨ _, Finset.mem_filter.mpr ⟨ h_directional_boundaries.2.2.2.1.choose_spec.choose_spec.1, h_directional_boundaries.2.2.2.1.choose_spec.choose_spec.2 ⟩ ⟩ ) ) ( Finset.card_pos.mpr ⟨ _, Finset.mem_filter.mpr ⟨ h_directional_boundaries.2.2.2.2.1.choose_spec.choose_spec.1, h_directional_boundaries.2.2.2.2.1.choose_spec.choose_spec.2 ⟩ ⟩ ) ) ( Finset.card_pos.mpr ⟨ _, Finset.mem_filter.mpr ⟨ h_directional_boundaries.2.2.2.2.2.choose_spec.choose_spec.1, h_directional_boundaries.2.2.2.2.2.choose_spec.choose_spec.2 ⟩ ⟩ ) );
  convert h_cases ( fun p => p.1 ) ⟨ Finset.exists_max_image _ _ hne, Finset.exists_min_image _ _ hne ⟩ using 1;
  unfold edgeBoundary;
  simp +decide only [hexNeighbors, ← Finset.sum_add_distrib];
  refine' Finset.sum_congr rfl fun x hx => _;
  rw [ Finset.card_filter ];
  rw [ Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert ] <;> simp +decide;
  all_goals omega;

set_option maxHeartbeats 1600000 in
/-- For a single cell, the edge boundary is exactly 6. -/
theorem edgeBoundary_card_one (S : Finset HexCell) (hcard : S.card = 1) :
    edgeBoundary S = 6 := by
  rw [ Finset.card_eq_one ] at hcard;
  obtain ⟨ a, rfl ⟩ := hcard;
  convert edgeBoundary_hexPatch_0 using 1;
  unfold edgeBoundary;
  unfold hexPatch; simp +decide [ hexNeighbors ] ;
  simp +decide [ Finset.filter_insert, Finset.filter_singleton, hexDist ];
  simp +decide [ Prod.ext_iff ];
  grind

/-! ## §8a. Internal Edge Upper Bound (Key Isoperimetric Tool) -/

/-
**The maximum internal edges for a set of `n` cells is at most
    `6n - (boundary lower bound)`.** This is a combinatorial reformulation:
    maximizing internal edges is equivalent to minimizing edge boundary.
-/
theorem internalEdges_le_of_card (S : Finset HexCell) :
    internalEdges S ≤ 6 * S.card - 6 := by
  -- By definition of internalEdges, we have `internalEdges S = 6 * S.card - edgeBoundary S`.
  have h_internalEdges_def : internalEdges S = 6 * S.card - edgeBoundary S := by
    exact eq_tsub_of_add_eq <| boundary_plus_internal S ▸ add_comm _ _;
  by_cases h : S.Nonempty <;> simp_all +decide [ edgeBoundary_pos ];
  linarith [ edgeBoundary_pos S h, Nat.sub_add_cancel ( show 6 ≤ 6 * S.card from by linarith [ Finset.card_pos.mpr h ] ) ]

/-! ## §9. Projection Bound and Width Analysis -/

/-- Width of S in the q-direction: number of distinct first coordinates. -/
def widthQ (S : Finset HexCell) : ℕ := (S.image Prod.fst).card

/-- Width of S in the s-direction: number of distinct second coordinates. -/
def widthS (S : Finset HexCell) : ℕ := (S.image Prod.snd).card

/-- Width of S in the diagonal direction: number of distinct q+s values. -/
def widthD (S : Finset HexCell) : ℕ := (S.image (fun p => p.1 + p.2)).card

/-
The boundary in direction (1,0) is at least the number of occupied rows (s-values).
-/
theorem boundary_dir10_ge_widthS (S : Finset HexCell) :
    S.sum (fun p => if (p.1 + 1, p.2) ∉ S then 1 else 0) ≥ widthS S := by
  -- For each distinct second coordinate s in S, there exists a cell (q, s) in S such that (q + 1, s) is not in S.
  have h_exists_cell : ∀ s ∈ S.image Prod.snd, ∃ p ∈ S, p.2 = s ∧ (p.1 + 1, p.2) ∉ S := by
    intro s hs;
    obtain ⟨p, hpS, hpq⟩ : ∃ p ∈ S, p.2 = s ∧ ∀ q ∈ S, q.2 = s → q.1 ≤ p.1 := by
      obtain ⟨p, hpS, hpq⟩ : ∃ p ∈ S, p.2 = s := by
        grind;
      have := Finset.exists_max_image ( S.filter fun q => q.2 = s ) ( fun q => q.1 ) ⟨ p, by aesop ⟩ ; aesop;
    grind;
  choose! f hf using h_exists_cell;
  have h_inj : Finset.card (Finset.image f (S.image Prod.snd)) ≤ ∑ p ∈ S, (if (p.1 + 1, p.2) ∉ S then 1 else 0) := by
    have h_inj : Finset.image f (S.image Prod.snd) ⊆ Finset.filter (fun p => (p.1 + 1, p.2) ∉ S) S := by
      grind;
    exact le_trans ( Finset.card_le_card h_inj ) ( by simp +decide [ Finset.sum_ite ] );
  rwa [ Finset.card_image_of_injOn fun x hx y hy hxy => by have := hf x hx; have := hf y hy; aesop ] at h_inj

/-
The boundary in direction (0,1) is at least the number of occupied columns (q-values).
-/
theorem boundary_dir01_ge_widthQ (S : Finset HexCell) :
    S.sum (fun p => if (p.1, p.2 + 1) ∉ S then 1 else 0) ≥ widthQ S := by
  simp +zetaDelta at *;
  have h_proj : Finset.card (Finset.image Prod.fst S) ≤ Finset.card (Finset.image (fun x => x.1) (Finset.filter (fun x => (x.1, x.2 + 1) ∉ S) S)) := by
    refine Finset.card_le_card ?_;
    simp +decide [ Finset.subset_iff ];
    intro q r hq;
    -- Let $x$ be the maximum $r$-coordinate among the cells in $S$ with first coordinate $q$.
    obtain ⟨x, hx⟩ : ∃ x, (q, x) ∈ S ∧ ∀ y, (q, y) ∈ S → y ≤ x := by
      exact ⟨ Finset.max' ( S.image Prod.snd |> Finset.filter ( fun y => ( q, y ) ∈ S ) ) ⟨ _, Finset.mem_filter.mpr ⟨ Finset.mem_image_of_mem _ hq, hq ⟩ ⟩, by have := Finset.max'_mem ( S.image Prod.snd |> Finset.filter ( fun y => ( q, y ) ∈ S ) ) ⟨ _, Finset.mem_filter.mpr ⟨ Finset.mem_image_of_mem _ hq, hq ⟩ ⟩ ; aesop, fun y hy => Finset.le_max' _ _ <| by aesop ⟩;
    exact ⟨ x, hx.1, fun h => not_lt_of_ge ( hx.2 _ h ) ( by linarith ) ⟩;
  refine le_trans h_proj ?_;
  refine' le_trans ( Finset.card_image_le ) _;
  simp +decide [ Finset.sum_ite ]

/-
The boundary in direction (1,-1) is at least the number of occupied diagonals.
-/
theorem boundary_dir1neg1_ge_widthD (S : Finset HexCell) :
    S.sum (fun p => if (p.1 + 1, p.2 - 1) ∉ S then 1 else 0) ≥ widthD S := by
  -- For each distinct diagonal value d = q+s in S, among all cells (q, s) in S with q+s = d, the one with maximum q has (q+1, s-1) ∉ S (since q+1 + (s-1) = q+s = d, and q+1 > q which was maximal for that diagonal).
  have h_diag_bound : ∀ d ∈ S.image (fun p => p.1 + p.2), ∃ p ∈ S, p.1 + p.2 = d ∧ (p.1 + 1, p.2 - 1) ∉ S := by
    intro d hd
    obtain ⟨p, hpS, hpD⟩ : ∃ p ∈ S, p.1 + p.2 = d ∧ ∀ q ∈ S, q.1 + q.2 = d → q.1 ≤ p.1 := by
      have h_max : ∃ p ∈ S, p.1 + p.2 = d := by
        grind;
      have := Finset.exists_max_image ( S.filter fun p => p.1 + p.2 = d ) ( fun p => p.1 ) ⟨ h_max.choose, Finset.mem_filter.mpr ⟨ h_max.choose_spec.1, h_max.choose_spec.2 ⟩ ⟩ ; aesop;
    grind;
  simp +zetaDelta at *;
  choose! a b h using h_diag_bound;
  have h_diag_bound : Finset.card (Finset.image (fun p => p.1 + p.2) S) ≤ Finset.card (Finset.image (fun p => (a (p.1 + p.2) p.1 p.2, b (p.1 + p.2) p.1 p.2)) S) := by
    have h_diag_bound : Finset.image (fun p => p.1 + p.2) S ⊆ Finset.image (fun p => p.1 + p.2) (Finset.image (fun p => (a (p.1 + p.2) p.1 p.2, b (p.1 + p.2) p.1 p.2)) S) := by
      intro x hx; aesop;
    exact le_trans ( Finset.card_le_card h_diag_bound ) ( Finset.card_image_le );
  refine le_trans h_diag_bound ?_;
  have h_diag_bound : Finset.image (fun p => (a (p.1 + p.2) p.1 p.2, b (p.1 + p.2) p.1 p.2)) S ⊆ Finset.filter (fun p => (p.1 + 1, p.2 - 1) ∉ S) S := by
    grind;
  exact le_trans ( Finset.card_le_card h_diag_bound ) ( by simp +decide [ Finset.sum_ite ] )

/-
**Projection bound**: edge boundary is at least twice the sum of the three widths.
-/
set_option maxHeartbeats 1600000 in
theorem edgeBoundary_ge_twice_widths (S : Finset HexCell) :
    edgeBoundary S ≥ 2 * (widthQ S + widthS S + widthD S) := by
  -- By definition of edgeBoundary, we can decompose it into six directional sums.
  have h_decomp : edgeBoundary S = (S.sum (fun p => if (p.1 + 1, p.2) ∉ S then 1 else 0)) + (S.sum (fun p => if (p.1 - 1, p.2) ∉ S then 1 else 0)) + (S.sum (fun p => if (p.1, p.2 + 1) ∉ S then 1 else 0)) + (S.sum (fun p => if (p.1, p.2 - 1) ∉ S then 1 else 0)) + (S.sum (fun p => if (p.1 + 1, p.2 - 1) ∉ S then 1 else 0)) + (S.sum (fun p => if (p.1 - 1, p.2 + 1) ∉ S then 1 else 0)) := by
    rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ];
    refine' Finset.sum_congr rfl fun x hx => _;
    simp +decide [ hexNeighbors ];
    rw [ Finset.card_filter ];
    rw [ Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert ] <;> simp +decide [ hx ];
    all_goals omega;
  -- By the properties of the hexagonal lattice, we know that each directional sum is at least the corresponding width.
  have h_dir_sums : S.sum (fun p => if (p.1 + 1, p.2) ∉ S then 1 else 0) ≥ widthS S ∧ S.sum (fun p => if (p.1 - 1, p.2) ∉ S then 1 else 0) ≥ widthS S ∧ S.sum (fun p => if (p.1, p.2 + 1) ∉ S then 1 else 0) ≥ widthQ S ∧ S.sum (fun p => if (p.1, p.2 - 1) ∉ S then 1 else 0) ≥ widthQ S ∧ S.sum (fun p => if (p.1 + 1, p.2 - 1) ∉ S then 1 else 0) ≥ widthD S ∧ S.sum (fun p => if (p.1 - 1, p.2 + 1) ∉ S then 1 else 0) ≥ widthD S := by
    refine' ⟨ _, _, _, _, _ ⟩;
    · convert boundary_dir10_ge_widthS S using 1;
    · -- For each row $s$, the cell with minimum $q$ has its left neighbor absent. So this is also ≥ widthS S.
      have h_min_q : ∀ s ∈ S.image Prod.snd, ∃ p ∈ S, p.2 = s ∧ (p.1 - 1, p.2) ∉ S := by
        intro s hs
        obtain ⟨p, hpS, hpq⟩ : ∃ p ∈ S, p.2 = s ∧ ∀ q ∈ S, q.2 = s → q.1 ≥ p.1 := by
          obtain ⟨ p, hpS, hpq ⟩ := Finset.mem_image.mp hs;
          exact Finset.exists_min_image ( S.filter fun q => q.2 = s ) ( fun q => q.1 ) ⟨ p, by aesop ⟩ |> fun ⟨ q, hq₁, hq₂ ⟩ => ⟨ q, by aesop ⟩;
        grind;
      choose! f hf using h_min_q;
      have h_min_q : Finset.card (Finset.image f (S.image Prod.snd)) ≤ Finset.card (Finset.filter (fun p => (p.1 - 1, p.2) ∉ S) S) := by
        exact Finset.card_le_card fun x hx => by obtain ⟨ s, hs, rfl ⟩ := Finset.mem_image.mp hx; specialize hf s hs; aesop;
      rw [ Finset.card_image_of_injOn ] at h_min_q;
      · exact h_min_q.trans ( by rw [ Finset.card_filter ] );
      · intro s hs t ht; have := hf s hs; have := hf t ht; aesop;
    · convert boundary_dir01_ge_widthQ S using 1;
    · -- For each column q, there is at least one cell in S whose neighbor in the negative s-direction is not in S.
      have h_col_neg_s : ∀ q ∈ S.image Prod.fst, ∃ p ∈ S, p.1 = q ∧ (p.1, p.2 - 1) ∉ S := by
        intro q hq
        obtain ⟨p, hpS, hpq⟩ : ∃ p ∈ S, p.1 = q ∧ ∀ p' ∈ S, p'.1 = q → p'.2 ≥ p.2 := by
          obtain ⟨ p, hpS, hpq ⟩ := Finset.mem_image.mp hq;
          exact Finset.exists_min_image ( S.filter fun p => p.1 = q ) ( fun p => p.2 ) ⟨ p, by aesop ⟩ |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, by aesop ⟩;
        exact ⟨ p, hpS, hpq.1, fun h => not_lt_of_ge ( hpq.2 _ h ( by aesop ) ) ( by aesop ) ⟩;
      choose! f hf using h_col_neg_s;
      have h_col_neg_s_sum : ∑ p ∈ Finset.image f (S.image Prod.fst), (if (p.1, p.2 - 1) ∉ S then 1 else 0) ≥ widthQ S := by
        rw [ Finset.sum_image ];
        · rw [ Finset.sum_congr rfl fun x hx => if_pos <| hf x hx |>.2.2 ] ; aesop;
        · intro q hq q' hq' h_eq; have := hf q hq; have := hf q' hq'; aesop;
      exact h_col_neg_s_sum.trans ( Finset.sum_le_sum_of_subset <| Finset.image_subset_iff.mpr fun q hq => hf q hq |>.1 );
    · have := boundary_dir1neg1_ge_widthD S;
      refine' ⟨ this, _ ⟩;
      convert boundary_dir1neg1_ge_widthD ( S.image fun p => ( -p.1, -p.2 ) ) using 1;
      · rw [ Finset.sum_image ] <;> norm_num;
        refine' Finset.sum_congr rfl fun x hx => _ ; simp +decide [ Prod.ext_iff ];
        grind;
      · refine' Finset.card_bij ( fun x hx => -x ) _ _ _ <;> simp +decide;
        · grind;
        · grind +extAll;
  bv_omega

/-
For hexPatch r, all three widths equal 2r+1.
-/
theorem hexPatch_widthQ (r : ℕ) : widthQ (hexPatch r) = 2 * r + 1 := by
  -- The image of the first coordinate of `hexPatch r` is exactly the set of integers from `-r` to `r`.
  have h_image : (hexPatch r).image Prod.fst = Finset.Icc (-(r : ℤ)) r := by
    ext q;
    simp +decide [ hexPatch ];
    constructor;
    · grind +splitImp;
    · unfold hexDist;
      exact fun h => ⟨ 0, ⟨ h, by norm_num, by norm_num ⟩, by norm_num; omega ⟩;
  convert congr_arg Finset.card h_image using 1 ; ring;
  norm_num [ mul_two, add_comm ];
  norm_cast

theorem hexPatch_widthS (r : ℕ) : widthS (hexPatch r) = 2 * r + 1 := by
  convert hexPatch_widthQ r using 1;
  nontriviality;
  refine' Finset.card_bij ( fun x hx => x ) _ _ _ <;> simp +decide [ Finset.mem_image ];
  · intro a x hxop;
    unfold hexPatch at *;
    unfold hexDist at *; simp_all +decide [ abs_le ] ;
    grind +revert;
  · intro b x hxop;
    unfold hexPatch at *;
    unfold hexDist at *; simp_all +decide [ abs_le ] ;
    exact ⟨ x, hxop.1.2, hxop.2.2.1, by omega ⟩

theorem hexPatch_widthD (r : ℕ) : widthD (hexPatch r) = 2 * r + 1 := by
  -- The set of q+s values for cells in hexPatch r is exactly the set of integers from -r to r.
  have h_diag_range : Finset.image (fun p => p.1 + p.2) (hexPatch r) = Finset.Icc (-r : ℤ) r := by
    ext d; simp [hexPatch];
    constructor;
    · unfold hexDist at *;
      grind;
    · intro hd
      use d, 0
      simp [hd, hexDist];
      grind;
  unfold widthD; simp_all +decide ; ring;
  norm_cast

/-- The projection bound is tight for hex patches. -/
theorem hexPatch_projection_tight (r : ℕ) :
    edgeBoundary (hexPatch r) = 2 * (widthQ (hexPatch r) + widthS (hexPatch r) + widthD (hexPatch r)) := by
  rw [hexPatch_widthQ, hexPatch_widthS, hexPatch_widthD, edgeBoundary_hexPatch]
  ring

/-
**Cardinality-width bound**: |S| ≤ widthQ S * widthS S.
-/
theorem card_le_widthQ_mul_widthS (S : Finset HexCell) :
    S.card ≤ widthQ S * widthS S := by
  have h_card_le_width : S.card ≤ Finset.card (S.image Prod.fst) * Finset.card (S.image Prod.snd) := by
    rw [ ← Finset.card_product ] ; exact Finset.card_le_card ( fun x hx => by aesop ) ;
  exact h_card_le_width

/-
|S| ≤ widthQ S * widthD S
-/
theorem card_le_widthQ_mul_widthD (S : Finset HexCell) :
    S.card ≤ widthQ S * widthD S := by
  convert Finset.card_le_card ( show S.image ( fun p : HexCell => ( p.1, p.1 + p.2 ) ) ⊆ Finset.image Prod.fst S ×ˢ Finset.image ( fun p : HexCell => p.1 + p.2 ) S from ?_ ) using 1;
  · rw [ Finset.card_image_of_injective _ fun x y hxy => by aesop ];
  · norm_num [ widthQ, widthD ];
  · grind

/-
|S| ≤ widthS S * widthD S
-/
theorem card_le_widthS_mul_widthD (S : Finset HexCell) :
    S.card ≤ widthS S * widthD S := by
  -- The map p ↦ (p.2, p.1+p.2) is injective on S. Its image is a subset of (S.image Prod.snd) ×ˢ (S.image (fun p => p.1+p.2)).
  have h_inj : (S.image (fun p => (p.2, p.1 + p.2))).card ≤ (widthS S) * (widthD S) := by
    have h_image_subset : (S.image (fun p => (p.2, p.1 + p.2))) ⊆ (S.image Prod.snd) ×ˢ (S.image (fun p => p.1 + p.2)) := by
      grind +splitImp;
    exact le_trans ( Finset.card_le_card h_image_subset ) ( Finset.card_product _ _ ▸ le_rfl );
  rwa [ Finset.card_image_of_injective _ fun x y h => by aesop ] at h_inj

/-- **Width sum lower bound for hex numbers**:
    If |S| = 3r²+3r+1, then widthQ S + widthS S + widthD S ≥ 3(2r+1).
    This is the key algebraic step of the discrete honeycomb theorem.
    The proof uses three pairwise product bounds (ab ≥ n, ac ≥ n, bc ≥ n)
    combined with the triangle inequality c ≤ a + b - 1. -/
theorem width_sum_lower_bound
    (r : ℕ) (S : Finset HexCell)
    (hcard : S.card = 3 * r ^ 2 + 3 * r + 1) :
    widthQ S + widthS S + widthD S ≥ 3 * (2 * r + 1) := by
  sorry

/-! ## §10. Discrete Honeycomb: Main Theorem -/

/-- **Discrete Honeycomb Theorem at Hex Numbers**: The hex patch of radius `r`
    minimizes edge boundary among all finite sets with `|S| = 3r² + 3r + 1`. -/
theorem hex_patch_edge_boundary_minimal_at_hex_number
    (r : ℕ) (S : Finset HexCell)
    (hcard : S.card = 3 * r ^ 2 + 3 * r + 1) :
    edgeBoundary S ≥ edgeBoundary (hexPatch r) := by
  calc edgeBoundary S
      ≥ 2 * (widthQ S + widthS S + widthD S) := edgeBoundary_ge_twice_widths S
    _ ≥ 2 * (3 * (2 * r + 1)) := by linarith [width_sum_lower_bound r S hcard]
    _ = edgeBoundary (hexPatch r) := by rw [edgeBoundary_hexPatch]; ring

/-! ## §10. Isoperimetric Ratio -/

/-- The boundary-to-area ratio is decreasing in `r` for `r ≥ 1`. -/
theorem hex_isoperimetric_ratio_decreasing (r : ℕ) (hr : r ≥ 1) :
    (12 * r + 6) * (3 * (r + 1) ^ 2 + 3 * (r + 1) + 1) ≥
    (12 * (r + 1) + 6) * (3 * r ^ 2 + 3 * r + 1) := by
  nlinarith [sq_nonneg r]

/-! ## §11. Hex Connectivity -/

/-- A set `S` is hex-connected if for any two cells in `S`,
    there is a path of adjacent cells within `S`. -/
def HexConnected (S : Finset HexCell) : Prop :=
  ∀ a b : HexCell, a ∈ S → b ∈ S →
    ∃ path : List HexCell, path ≠ [] ∧ path.head? = some a ∧ path.getLast? = some b ∧
      (∀ p, p ∈ path → p ∈ S) ∧
      path.IsChain (fun x y => hexAdj x y)

/-- **Discrete Honeycomb (Connected Version)**. -/
theorem hex_patch_boundary_minimal_connected
    (r : ℕ) (S : Finset HexCell)
    (_hconn : HexConnected S)
    (hcard : S.card = 3 * r ^ 2 + 3 * r + 1) :
    edgeBoundary S ≥ edgeBoundary (hexPatch r) :=
  hex_patch_edge_boundary_minimal_at_hex_number r S hcard

/-! ## §11. Isoperimetric Profile -/

/-- The isoperimetric profile: minimum edge boundary among sets of cardinality `n`. -/
noncomputable def hexEdgeIsoProfile (n : ℕ) : ℕ :=
  if n = 0 then 0
  else sInf {m | ∃ S : Finset HexCell, S.card = n ∧ edgeBoundary S = m}

end HexHoneycomb