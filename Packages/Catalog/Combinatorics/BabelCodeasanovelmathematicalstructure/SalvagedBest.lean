/-
The "Library of Babel" as a coding-theoretic structure.

NOTE (restored header).  This file was recorded without its opening section: the
imports, the namespace, the basic definitions (`Volume`, `IsBabelCode`,
`hammingBall`) and the auxiliary counting lemma `column_disagreement_bound` used
by `plotkin_bound` were missing, so the file did not compile.  The header below
reconstructs them, and `column_disagreement_bound` is given a complete proof
(a Cauchy–Schwarz / fibre-counting argument).  The remaining theorems are exactly
as originally recorded.
-/
import Mathlib

open Function Finset

namespace BabelCode

/-- A *volume* of the library of Babel: a word of length `L` over an alphabet with
`A` letters. -/
abbrev Volume (A L : ℕ) : Type := Fin L → Fin A

/-- `C` is a Babel code of minimum distance at least `d`: any two distinct volumes of
`C` differ in at least `d` positions. -/
def IsBabelCode {A L : ℕ} (C : Finset (Volume A L)) (d : ℕ) : Prop :=
  ∀ v w : Volume A L, v ∈ C → w ∈ C → v ≠ w → d ≤ hammingDist v w

/-- The Hamming ball of radius `r` around the volume `v`. -/
def hammingBall {A L : ℕ} (v : Volume A L) (r : ℕ) : Finset (Volume A L) :=
  Finset.univ.filter (fun w => hammingDist v w ≤ r)

/-- **Column disagreement bound.**  In a fixed coordinate `j`, the number of ordered
pairs of codewords that disagree is at most `|C|² (A-1)/A`.  Equivalently, `A` times
that number is at most `|C|² (A - 1)`.  This is Cauchy–Schwarz applied to the sizes of
the `A` fibres of the `j`-th coordinate map. -/
theorem column_disagreement_bound {A L : ℕ} (_hA : 1 ≤ A) (j : Fin L)
    (C : Finset (Volume A L)) :
    (∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0) * A ≤ #C ^ 2 * (A - 1) := by
  classical
  set n : Fin A → ℕ := fun a => #(C.filter (fun u => u j = a)) with hn
  have hsum : ∑ a : Fin A, n a = #C :=
    (Finset.card_eq_sum_card_fiberwise (f := fun u : Volume A L => u j) (s := C)
      (t := univ) (fun u _ => Finset.mem_coe.mpr (mem_univ _))).symm
  have heq : ∑ p ∈ C ×ˢ C, (if p.1 j = p.2 j then 1 else 0) = ∑ a : Fin A, n a * n a := by
    rw [Finset.sum_product]
    have step : ∀ u : Volume A L, (∑ v ∈ C, if u j = v j then 1 else 0) = n (u j) := by
      intro u
      rw [← Finset.sum_filter, Finset.sum_const, smul_eq_mul, mul_one, hn]
      simp only
      congr 1
      exact Finset.filter_congr fun v _ => by simp [eq_comm]
    rw [Finset.sum_congr rfl fun u _ => step u,
      ← Finset.sum_fiberwise C (fun u : Volume A L => u j) (fun u => n (u j))]
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [Finset.sum_congr rfl (fun u hu => by rw [(Finset.mem_filter.mp hu).2]),
      Finset.sum_const, smul_eq_mul, hn]
  have hone : ∀ p : Volume A L × Volume A L,
      (if p.1 j = p.2 j then 1 else 0) + (if p.1 j ≠ p.2 j then (1 : ℕ) else 0) = 1 := by
    intro p; by_cases h : p.1 j = p.2 j <;> simp [h]
  have htotal : (∑ p ∈ C ×ˢ C, (if p.1 j = p.2 j then 1 else 0))
      + (∑ p ∈ C ×ˢ C, (if p.1 j ≠ p.2 j then 1 else 0)) = #C ^ 2 := by
    rw [← Finset.sum_add_distrib, Finset.sum_congr rfl (fun p _ => hone p), Finset.sum_const,
      smul_eq_mul, mul_one, Finset.card_product, sq]
  have hcs : #C ^ 2 ≤ A * ∑ a : Fin A, n a * n a := by
    have h := sq_sum_le_card_mul_sum_sq (s := (univ : Finset (Fin A))) (f := n)
    simp only [Finset.card_univ, Fintype.card_fin] at h
    rw [hsum] at h
    calc #C ^ 2 ≤ A * ∑ a : Fin A, n a ^ 2 := h
      _ = A * ∑ a : Fin A, n a * n a := by simp [sq]
  rw [heq] at htotal
  set S := ∑ a : Fin A, n a * n a
  set X := ∑ p ∈ C ×ˢ C, (if p.1 j ≠ p.2 j then 1 else 0)
  obtain ⟨a, rfl⟩ : ∃ a, A = a + 1 := ⟨A - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  nlinarith [htotal, hcs]

theorem plotkin_bound {A L d : ℕ} (hA : 1 ≤ A)
    (hPlotkin : L * (A - 1) < d * A)
    (C : Finset (Volume A L)) (hC : IsBabelCode C d) :
    C.card * (d * A - L * (A - 1)) ≤ d * A := by
      by_contra! h_contra;
      -- By double-counting the total pairwise Hamming distance, we have:
      have h_double_count : ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 ≥ C.card * (C.card - 1) * d := by
        have h_double_count : ∑ p ∈ C ×ˢ C, (if p.1 = p.2 then 0 else d) ≤ ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 := by
          gcongr ; aesop;
        simp_all +decide [ Finset.sum_ite ];
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
  have h := plotkin_bound (by norm_num) (by norm_num) C hC
  omega

/-
**Generalization (stated)**: Plotkin bound with equality characterization.
    Equality holds iff C is an equidistant code (all pairs at exactly distance d).
-/

theorem babel_lawvere {A L : ℕ} (hA : 2 ≤ A)
    (f : Volume A L → Volume A L → Fin A) : ¬Surjective f := by
      -- Assume for contradiction that f is surjective.
      by_contra h_surjective;
      obtain ⟨ g, hg ⟩ := h_surjective ( fun x => ⟨ ( f x x + 1 ) % A, Nat.mod_lt _ ( by linarith ) ⟩ ) ; have := congr_fun hg ; simp_all +decide ;
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