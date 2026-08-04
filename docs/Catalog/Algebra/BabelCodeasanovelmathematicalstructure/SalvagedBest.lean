import Mathlib

/-!
# Babel codes: Plotkin, Lawvere and sphere-packing bounds

A *Babel code* is a set of words over a finite alphabet with a prescribed minimum
Hamming distance.  This file proves the Plotkin bound, a Lawvere fixed-point
(diagonal) theorem for words, invariance of Hamming-ball cardinalities, and the
sphere-packing (Hamming) bound.

The definitions below (`Volume`, `IsBabelCode`, `hammingBall` and the column
disagreement bound) were reconstructed from the theorem bodies of an
auto-salvaged fragment.
-/

open Finset Function

namespace BabelCode

/-- The library of words of length `L` over an alphabet with `A` letters. -/
abbrev Volume (A L : ℕ) := Fin L → Fin A

/-- `C` is a Babel code of minimum distance `d`: distinct codewords are at
Hamming distance at least `d`. -/
def IsBabelCode {A L : ℕ} (C : Finset (Volume A L)) (d : ℕ) : Prop :=
  ∀ v w : Volume A L, v ∈ C → w ∈ C → v ≠ w → d ≤ hammingDist v w

/-- The Hamming ball of radius `r` around `v`. -/
def hammingBall {A L : ℕ} (v : Volume A L) (r : ℕ) : Finset (Volume A L) :=
  Finset.univ.filter (fun w => hammingDist v w ≤ r)

/-- **Column disagreement bound.**  In a single coordinate, the number of ordered
pairs of codewords that disagree is at most `|C|² (A-1)/A`. -/
theorem column_disagreement_bound {A L : ℕ} (hA : 1 ≤ A) (j : Fin L)
    (C : Finset (Volume A L)) :
    (∑ p ∈ C ×ˢ C, (if p.1 j ≠ p.2 j then 1 else 0)) * A ≤ C.card ^ 2 * (A - 1) := by
  classical
  set f : Fin A → ℕ := fun a => (C.filter (fun v => v j = a)).card with hf
  -- the fibres of the `j`-th coordinate partition `C`
  have hsum : ∑ a : Fin A, f a = C.card := by
    conv_rhs => rw [Finset.card_eq_sum_ones C]
    rw [← Finset.sum_fiberwise_of_maps_to (g := fun (v : Volume A L) => v j)
      (t := (Finset.univ : Finset (Fin A))) (fun v _ => Finset.mem_univ (v j))]
    refine Finset.sum_congr rfl (fun a _ => ?_)
    simp only [hf]
    exact Finset.card_eq_sum_ones _
  -- ordered pairs agreeing at `j` are counted by the sum of squares of the fibre sizes
  have hagree : (∑ p ∈ C ×ˢ C, (if p.1 j = p.2 j then 1 else 0)) = ∑ a : Fin A, (f a) ^ 2 := by
    rw [Finset.sum_product]
    have hfil : ∀ v : Volume A L,
        (C.filter (fun w => v j = w j)) = C.filter (fun w => w j = v j) :=
      fun v => Finset.filter_congr (fun w _ => ⟨Eq.symm, Eq.symm⟩)
    have inner : ∀ v : Volume A L, (∑ w ∈ C, (if v j = w j then 1 else 0))
        = (C.filter (fun w => w j = v j)).card := by
      intro v
      rw [Finset.sum_boole, hfil v]
      simp
    rw [Finset.sum_congr rfl (fun v _ => inner v)]
    rw [← Finset.sum_fiberwise_of_maps_to (g := fun (v : Volume A L) => v j)
        (t := (Finset.univ : Finset (Fin A))) (fun v _ => Finset.mem_univ (v j))]
    refine Finset.sum_congr rfl (fun a _ => ?_)
    rw [Finset.sum_congr rfl (fun v hv => by rw [(Finset.mem_filter.mp hv).2])]
    rw [Finset.sum_const, smul_eq_mul, sq]
  -- every ordered pair either agrees or disagrees at `j`
  have htotal : (∑ p ∈ C ×ˢ C, (if p.1 j ≠ p.2 j then 1 else 0))
      + (∑ p ∈ C ×ˢ C, (if p.1 j = p.2 j then 1 else 0)) = C.card ^ 2 := by
    have h1 : ∀ p : Volume A L × Volume A L,
        (if p.1 j ≠ p.2 j then 1 else 0) + (if p.1 j = p.2 j then 1 else 0) = 1 := by
      intro p; by_cases h : p.1 j = p.2 j <;> simp [h]
    rw [← Finset.sum_add_distrib, Finset.sum_congr rfl (fun p _ => h1 p)]
    simp [sq]
  -- Cauchy-Schwarz on the fibre sizes
  have hCS : ((C.card : ℤ)) ^ 2 ≤ (A : ℤ) * ∑ a : Fin A, ((f a : ℤ)) ^ 2 := by
    have h := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin A)))
      (f := fun a => (f a : ℤ))
    have hs : ∑ a : Fin A, ((f a : ℤ)) = (C.card : ℤ) := by
      rw [← Nat.cast_sum, hsum]
    rw [hs] at h
    simpa using h
  have hCS' : C.card ^ 2 ≤ A * ∑ a : Fin A, (f a) ^ 2 := by exact_mod_cast hCS
  have hsplit : (∑ p ∈ C ×ˢ C, (if p.1 j ≠ p.2 j then 1 else 0)) + (∑ a : Fin A, (f a) ^ 2)
      = C.card ^ 2 := by rw [← hagree]; exact htotal
  have hAm : A - 1 + 1 = A := Nat.sub_add_cancel hA
  nlinarith [hsplit, hCS', hAm]

theorem plotkin_bound {A L d : ℕ} (hA : 1 ≤ A) (hd : 1 ≤ d)
    (hPlotkin : L * (A - 1) < d * A)
    (C : Finset (Volume A L)) (hC : IsBabelCode C d) :
    C.card * (d * A - L * (A - 1)) ≤ d * A := by
      by_contra! h_contra;
      -- By double-counting the total pairwise Hamming distance, we have:
      have h_double_count : ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 ≥ C.card * (C.card - 1) * d := by
        have h_double_count : ∑ p ∈ C ×ˢ C, (if p.1 = p.2 then 0 else d) ≤ ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 := by
          gcongr ; aesop;
        simp_all +decide [ Finset.sum_ite, Finset.filter_ne ];
        convert h_double_count using 2 ; rw [ show ( Finset.filter ( fun x : Volume A L × Volume A L => ¬x.1 = x.2 ) ( C ×ˢ C ) ) = Finset.offDiag C by ext ; aesop ] ; simp +decide [ Finset.offDiag_card ];
        rw [ Nat.mul_sub_left_distrib, Nat.mul_one ];
      -- On the other hand, we can bound the total pairwise Hamming distance from above by considering each coordinate separately.
      have h_upper_bound : ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 ≤ L * C.card ^ 2 * (A - 1) / A := by
        have h_upper_bound : ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 = ∑ j : Fin L, ∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0 := by
          rw [ Finset.sum_comm, Finset.sum_congr rfl ];
          simp +decide [ hammingDist ];
          simp +decide [ Finset.sum_ite ];
        -- By the column disagreement bound, each coordinate contributes at most $C.card^2 * (A - 1) / A$ to the sum.
        have h_column_disagreement : ∀ j : Fin L, ∑ p ∈ C ×ˢ C, (if p.1 j ≠ p.2 j then 1 else 0) ≤ C.card ^ 2 * (A - 1) / A := by
          intro j
          have := column_disagreement_bound hA j C
          simp_all +decide [ Finset.sum_ite ];
          rwa [ Nat.le_div_iff_mul_le hA ];
        rw [ h_upper_bound, Nat.le_div_iff_mul_le hA ];
        exact le_trans ( Nat.mul_le_mul_right _ ( Finset.sum_le_sum fun _ _ => h_column_disagreement _ ) ) ( by norm_num; nlinarith [ Nat.div_mul_le_self ( #C ^ 2 * ( A - 1 ) ) A ] );
      rcases k : #C with ( _ | _ | k ) <;> simp_all +decide;
      · omega;
      · rw [ Nat.le_div_iff_mul_le ] at h_upper_bound <;> nlinarith [ Nat.sub_add_cancel hPlotkin.le, mul_pos ( Nat.succ_pos ‹_› ) ( Nat.succ_pos ‹_› ) ]

/-- **Example**: Binary code, length 6, min distance 4.
    Plotkin gives |C| · (8 - 6) ≤ 8, so |C| ≤ 4. -/
example : ∀ (C : Finset (Volume 2 6)), IsBabelCode C 4 →
    C.card ≤ 4 := by
  intro C hC
  have h := plotkin_bound (by norm_num) (by norm_num) (by norm_num) C hC
  omega

/-
**Generalization (stated)**: Plotkin bound with equality characterization.
    Equality holds iff C is an equidistant code (all pairs at exactly distance d).
-/

theorem babel_lawvere {A L : ℕ} (hA : 2 ≤ A)
    (f : Volume A L → Volume A L → Fin A) : ¬Surjective f := by
      -- Assume for contradiction that f is surjective.
      by_contra h_surjective;
      obtain ⟨ g, hg ⟩ := h_surjective ( fun x => ⟨ ( f x x + 1 ) % A, Nat.mod_lt _ ( by linarith ) ⟩ ) ; have := congr_fun hg ; simp_all +decide [ Fin.ext_iff ] ;
      replace hg := congr_fun hg g; simp_all +decide [ Fin.ext_iff ] ;
      linarith [ Nat.mod_eq_of_lt ( show ( f g g : ℕ ) + 1 < A from lt_of_le_of_ne ( Nat.succ_le_of_lt ( Fin.is_lt _ ) ) ( by intro t; rw [ t ] at hg; norm_num at hg; linarith [ Fin.is_lt ( f g g ) ] ) ) ]

/-
**Generalization**: Lawvere for arbitrary finite types with |Y| ≥ 2.
-/

theorem lawvere_finite {X Y : Type*} [Fintype X] [Fintype Y] [DecidableEq Y]
    (hcard : Fintype.card Y ≥ 2) (_hX : Nonempty X)
    (f : X → X → Y) : ¬Surjective f := by
      obtain ⟨a, b, hab⟩ : ∃ a b : Y, a ≠ b := by
        exact Fintype.one_lt_card_iff.1 hcard;
      intro h_surjective
      obtain ⟨x₀, hx₀⟩ : ∃ x₀ : X, f x₀ = fun x => if f x x = a then b else a := by
        exact h_surjective _;
      have := congr_fun hx₀ x₀; by_cases h : f x₀ x₀ = a <;> simp +decide [ h ] at this;
      exact hab this

/-- **Boundary**: Lawvere fails when A = 1 (trivial alphabet). With only one symbol,
    there is only one function Volume → Fin 1, and any f trivially covers it. -/

theorem hamming_ball_card_eq {A L : ℕ} (v w : Volume A L) (r : ℕ) :
    (hammingBall v r).card = (hammingBall w r).card := by
      fapply Finset.card_bij;
      exact fun a ha => fun i => if h : a i = v i then w i else if h' : a i = w i then v i else a i;
      · simp +contextual [ hammingBall ];
        intro a ha; rw [ hammingDist_comm ] at ha; simp_all +decide [ hammingDist ] ;
        exact le_trans ( Finset.card_le_card fun i hi => by aesop ) ha;
      · intro a₁ ha₁ a₂ ha₂ h; ext i; replace h := congr_fun h i; aesop;
      · intro b hb;
        refine' ⟨ fun i => if h : b i = w i then v i else if h' : b i = v i then w i else b i, _, _ ⟩ <;> simp_all +decide [ hammingBall ];
        · refine' le_trans _ hb;
          refine' Finset.card_le_card _;
          grind;
        · grind

/-
**Hamming bound (sphere-packing)**: If balls of radius `t` around codewords
    are disjoint (which holds when min distance ≥ 2t+1), the number of
    codewords times the ball size cannot exceed the library size.
-/

theorem hamming_bound_via_packing {A L d : ℕ} (_hA : 1 ≤ A) (t : ℕ)
    (hdt : 2 * t + 1 ≤ d)
    (C : Finset (Volume A L)) (hC : IsBabelCode C d)
    (v₀ : Volume A L) :
    C.card * (hammingBall v₀ t).card ≤ A ^ L := by
      -- First show balls around distinct codewords are disjoint: if u ∈ hammingBall v t ∩ hammingBall w t for v ≠ w in C, then hammingDist v w ≤ hammingDist v u + hammingDist u w ≤ t + t = 2t < d, contradicting IsBabelCode. So the balls are pairwise disjoint subsets of Finset.univ (which has card A^L).
      have h_disjoint : ∀ v w : Volume A L, v ∈ C → w ∈ C → v ≠ w → Disjoint (hammingBall v t) (hammingBall w t) := by
        intros v w hv hw hvw
        have h_dist : ∀ u : Volume A L, u ∈ hammingBall v t → u ∈ hammingBall w t → False := by
          intros u hu hvu
          have h_dist : hammingDist v w ≤ hammingDist v u + hammingDist u w := by
            exact hammingDist_triangle v u w;
          unfold hammingBall at *; simp_all +decide [ hammingDist_comm ] ; linarith [ hC v w hv hw hvw ] ;
        exact Finset.disjoint_left.mpr h_dist;
      -- The disjoint union of the balls has cardinality equal to the sum of their cardinalities.
      have h_union_card : (Finset.biUnion C (fun v => hammingBall v t)).card = C.card * (hammingBall v₀ t).card := by
        rw [ Finset.card_biUnion ];
        · rw [ Finset.sum_congr rfl fun x hx => hamming_ball_card_eq x v₀ t ] ; aesop;
        · exact fun v hv w hw hvw => h_disjoint v w hv hw hvw;
      exact h_union_card ▸ le_trans ( Finset.card_le_univ _ ) ( by simp +decide [ Finset.card_univ ] )

end BabelCode

/-!
## FUTURE DIRECTIONS

1. **Harper's vertex isoperimetric inequality**: Among all subsets of {0,1}^n of
   fixed size k, the initial segment in the simplicial order minimizes the vertex
   boundary. *Testable*: verify computationally for n ≤ 6 by exhaustive enumeration.

2. **Spectral gap of the Hamming graph**: The adjacency operator of H(L,A) has
   eigenvalues λ_k = L(A-1) - kA with multiplicity C(L,k)(A-1)^k. The spectral
   gap is A, independent of L. *Testable*: compute the 8×8 adjacency matrix of
   H(3,2) and verify eigenvalues are {3,1,1,1,-1,-1,-1,-3}.

3. **Plotkin bound equality characterization**: Equality in the Plotkin bound holds
   iff the code is equidistant. *Testable*: verify for all binary codes of length 6,
   distance 4 achieving |C| = 4 that all pairwise distances equal 4.

4. **Gilbert-Varshamov lower bound**: There exists a BabelCode with |C| ≥ A^L / V(L,d-1)
   where V is the Hamming ball volume. *Testable*: for A=2, L=7, d=3, verify a code
   of size ≥ 128/29 ≈ 4.4, i.e., size ≥ 5 exists (it does: the [7,4,3] Hamming code
   has 16 codewords).

5. **BabelCode lattice structure**: The set of all BabelCodes ordered by inclusion
   forms a lattice. The meet is intersection (with adjusted distance), the join
   requires recomputing minimum distance. *Testable*: enumerate all BabelCodes
   over {0,1}^3 and verify the lattice axioms.
-/