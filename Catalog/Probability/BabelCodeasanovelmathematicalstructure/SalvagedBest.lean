import Mathlib

/-!
# Babel codes: Plotkin, Lawvere and sphere packing

The auto-generated version of this file was a fragment: it used `Volume`,
`IsBabelCode`, `hammingBall` and `column_disagreement_bound` without defining
them, had no imports and an unbalanced `namespace`/`end` pair.  This file
supplies the missing definitions together with the missing counting lemma, and
gives complete proofs of all the statements the fragment contained.

The "library of Babel" of parameters `(A, L)` is the set of words of length `L`
over an alphabet with `A` letters; a *Babel code* of minimum distance `d` is a
set of words that are pairwise at Hamming distance at least `d`.
-/

namespace BabelCode

open Function Finset

/-- The library of Babel: words of length `L` over an alphabet of `A` letters. -/
abbrev Volume (A L : ℕ) : Type := Fin L → Fin A

variable {A L : ℕ}

/-- A code with minimum distance `d`. -/
def IsBabelCode (C : Finset (Volume A L)) (d : ℕ) : Prop :=
  ∀ v w, v ∈ C → w ∈ C → v ≠ w → d ≤ hammingDist v w

/-- The Hamming ball of radius `r` around `v`. -/
def hammingBall (v : Volume A L) (r : ℕ) : Finset (Volume A L) :=
  Finset.univ.filter (fun u => hammingDist v u ≤ r)

@[simp] lemma mem_hammingBall {v u : Volume A L} {r : ℕ} :
    u ∈ hammingBall v r ↔ hammingDist v u ≤ r := by simp [hammingBall]

/-! ## Counting disagreements in a single column -/

/-- The number of codewords of `C` carrying the letter `a` in column `j`. -/
def colCount (C : Finset (Volume A L)) (j : Fin L) (a : Fin A) : ℕ :=
  (C.filter (fun c => c j = a)).card

lemma sum_colCount (C : Finset (Volume A L)) (j : Fin L) :
    ∑ a : Fin A, colCount C j a = C.card :=
  (Finset.card_eq_sum_card_fiberwise (t := Finset.univ)
    (fun c _ => Finset.mem_coe.mpr (Finset.mem_univ (c j)))).symm

lemma agree_pairs (C : Finset (Volume A L)) (j : Fin L) :
    ((C ×ˢ C).filter (fun p => p.1 j = p.2 j)).card = ∑ a : Fin A, (colCount C j a) ^ 2 := by
  rw [Finset.card_eq_sum_card_fiberwise (f := fun p : Volume A L × Volume A L => p.1 j)
      (t := Finset.univ) (fun p _ => Finset.mem_coe.mpr (Finset.mem_univ _))]
  refine Finset.sum_congr rfl fun a _ => ?_
  have hset : (((C ×ˢ C).filter (fun p => p.1 j = p.2 j)).filter (fun p => p.1 j = a))
      = (C.filter (fun c => c j = a)) ×ˢ (C.filter (fun c => c j = a)) := by
    ext ⟨x, y⟩
    simp only [Finset.mem_filter, Finset.mem_product]
    constructor
    · rintro ⟨⟨⟨hx, hy⟩, hxy⟩, hxa⟩
      exact ⟨⟨hx, hxa⟩, ⟨hy, hxy ▸ hxa⟩⟩
    · rintro ⟨⟨hx, hxa⟩, ⟨hy, hya⟩⟩
      exact ⟨⟨⟨hx, hy⟩, hxa.trans hya.symm⟩, hxa⟩
  rw [hset, Finset.card_product, colCount, sq]

/-- **Column disagreement bound.**  In any single column, the number of ordered pairs of
codewords that disagree is at most `|C|²(A-1)/A`, stated multiplicatively to stay in `ℕ`. -/
theorem column_disagreement_bound (hA : 1 ≤ A) (j : Fin L) (C : Finset (Volume A L)) :
    A * (∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0) ≤ C.card ^ 2 * (A - 1) := by
  set S := ∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0 with hS
  set T := ∑ p ∈ C ×ˢ C, if p.1 j = p.2 j then 1 else 0 with hT
  have hTeq : T = ∑ a : Fin A, (colCount C j a) ^ 2 := by
    rw [hT, ← Finset.card_filter]
    exact agree_pairs C j
  have hcs : C.card ^ 2 ≤ A * T := by
    rw [hTeq, ← sum_colCount C j]
    simpa using sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin A)))
      (f := colCount C j)
  have htotal : S + T = C.card ^ 2 := by
    rw [hS, hT, ← Finset.sum_add_distrib]
    have : ∀ p ∈ C ×ˢ C,
        ((if p.1 j ≠ p.2 j then 1 else 0) + (if p.1 j = p.2 j then 1 else 0)) = 1 := by
      intro p _
      by_cases h : p.1 j = p.2 j <;> simp [h]
    rw [Finset.sum_congr rfl this]
    simp [Finset.card_product, sq]
  obtain ⟨a1, rfl⟩ : ∃ a1, A = a1 + 1 := ⟨A - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  nlinarith [htotal, hcs]

/-! ## The Plotkin bound -/

lemma hammingDist_eq_sum (x y : Volume A L) :
    hammingDist x y = ∑ j : Fin L, if x j ≠ y j then 1 else 0 := by
  simp [hammingDist, Finset.card_filter]

lemma sum_dist_eq_sum_columns (C : Finset (Volume A L)) :
    ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2
      = ∑ j : Fin L, ∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0 := by
  rw [Finset.sum_congr rfl fun p (_ : p ∈ C ×ˢ C) => hammingDist_eq_sum p.1 p.2,
    Finset.sum_comm]

lemma sum_dist_lower (C : Finset (Volume A L)) {d : ℕ} (hC : IsBabelCode C d) :
    (C.card * C.card - C.card) * d ≤ ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 := by
  have hsub : C.offDiag ⊆ C ×ˢ C := by
    intro p hp
    simp only [Finset.mem_offDiag] at hp
    exact Finset.mem_product.mpr ⟨hp.1, hp.2.1⟩
  calc (C.card * C.card - C.card) * d
      = ∑ _p ∈ C.offDiag, d := by rw [Finset.sum_const, Finset.offDiag_card, smul_eq_mul]
    _ ≤ ∑ p ∈ C.offDiag, hammingDist p.1 p.2 := by
        refine Finset.sum_le_sum fun p hp => ?_
        simp only [Finset.mem_offDiag] at hp
        exact hC p.1 p.2 hp.1 hp.2.1 hp.2.2
    _ ≤ ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 :=
        Finset.sum_le_sum_of_subset hsub

lemma sum_dist_upper (hA : 1 ≤ A) (C : Finset (Volume A L)) :
    A * (∑ p ∈ C ×ˢ C, hammingDist p.1 p.2) ≤ L * (C.card ^ 2 * (A - 1)) := by
  rw [sum_dist_eq_sum_columns, Finset.mul_sum]
  calc ∑ j : Fin L, A * ∑ p ∈ C ×ˢ C, (if p.1 j ≠ p.2 j then 1 else 0)
      ≤ ∑ _j : Fin L, C.card ^ 2 * (A - 1) :=
        Finset.sum_le_sum fun j _ => column_disagreement_bound hA j C
    _ = L * (C.card ^ 2 * (A - 1)) := by simp [mul_comm]

/-- **The Plotkin bound.**  If `L(A-1) < dA` then a code of minimum distance `d`
satisfies `|C| · (dA - L(A-1)) ≤ dA`.

The hypothesis `1 ≤ d` is part of the statement as originally posed; the proof
below does not need it (it is implied by `L * (A-1) < d * A`). -/
theorem plotkin_bound {A L d : ℕ} (hA : 1 ≤ A) (_hd : 1 ≤ d)
    (hPlotkin : L * (A - 1) < d * A)
    (C : Finset (Volume A L)) (hC : IsBabelCode C d) :
    C.card * (d * A - L * (A - 1)) ≤ d * A := by
  rcases Nat.eq_zero_or_pos C.card with hm | hm
  · simp [hm]
  obtain ⟨k, hk⟩ : ∃ k, C.card = k + 1 := ⟨C.card - 1, by omega⟩
  have hlow := sum_dist_lower C hC
  have hup := sum_dist_upper hA C
  -- combine: A * (m*m - m) * d ≤ L * m² * (A-1)
  have hkey : A * ((C.card * C.card - C.card) * d) ≤ L * (C.card ^ 2 * (A - 1)) :=
    le_trans (Nat.mul_le_mul_left A hlow) hup
  rw [hk] at hkey
  have hcancel : A * d * k ≤ L * (A - 1) * (k + 1) := by
    have hexp : A * (((k + 1) * (k + 1) - (k + 1)) * d) = (k + 1) * (A * d * k) := by
      have : (k + 1) * (k + 1) - (k + 1) = (k + 1) * k := by ring_nf; omega
      rw [this]; ring
    have hexp2 : L * ((k + 1) ^ 2 * (A - 1)) = (k + 1) * (L * (A - 1) * (k + 1)) := by ring
    rw [hexp, hexp2] at hkey
    exact Nat.le_of_mul_le_mul_left hkey (Nat.succ_pos k)
  set T := L * (A - 1) with hTdef
  obtain ⟨s, hs⟩ : ∃ s, d * A = T + s := ⟨d * A - T, by omega⟩
  have hAd : A * d = T + s := by rw [mul_comm]; exact hs
  rw [hk, hs, Nat.add_sub_cancel_left]
  nlinarith [hcancel, hAd]

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

/-! ## Lawvere's fixed point argument -/

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

theorem babel_lawvere {A L : ℕ} (hA : 2 ≤ A)
    (f : Volume A L → Volume A L → Fin A) : ¬Surjective f := by
  have hne : Nonempty (Volume A L) := ⟨fun _ => ⟨0, by omega⟩⟩
  exact lawvere_finite (by simpa using hA) hne f

/-
**Boundary**: Lawvere fails when A = 1 (trivial alphabet). With only one symbol,
    there is only one function Volume → Fin 1, and any f trivially covers it.
-/

/-! ## Sphere packing -/

theorem hamming_ball_card_eq {A L : ℕ} (v w : Volume A L) (r : ℕ) :
    (hammingBall v r).card = (hammingBall w r).card := by
  classical
  have key : ∀ (x y a : Volume A L) (k : Fin L),
      (y k = Equiv.swap (x k) (y k) (a k)) ↔ (x k = a k) := by
    intro x y a k
    constructor
    · intro h
      have h2 := congrArg (Equiv.swap (x k) (y k)) h
      rw [Equiv.swap_apply_right, Equiv.swap_apply_self] at h2
      exact h2
    · intro h
      rw [← h, Equiv.swap_apply_left]
  have hdist : ∀ a : Volume A L,
      hammingDist w (fun k => Equiv.swap (v k) (w k) (a k)) = hammingDist v a := by
    intro a
    simp only [hammingDist]
    refine congrArg Finset.card (Finset.filter_congr fun k _ => ?_)
    simp only [ne_eq, not_iff_not]
    exact key v w a k
  have hdist' : ∀ a : Volume A L,
      hammingDist v (fun k => Equiv.swap (v k) (w k) (a k)) = hammingDist w a := by
    intro a
    simp only [hammingDist]
    refine congrArg Finset.card (Finset.filter_congr fun k _ => ?_)
    simp only [ne_eq, not_iff_not]
    rw [Equiv.swap_comm]
    exact key w v a k
  refine Finset.card_bij' (fun a _ => fun k => Equiv.swap (v k) (w k) (a k))
    (fun b _ => fun k => Equiv.swap (v k) (w k) (b k)) ?_ ?_ ?_ ?_
  · intro a ha
    rw [mem_hammingBall] at ha ⊢
    rw [hdist a]
    exact ha
  · intro b hb
    rw [mem_hammingBall] at hb ⊢
    rw [hdist' b]
    exact hb
  · intro a _
    funext k
    exact Equiv.swap_apply_self _ _ _
  · intro b _
    funext k
    exact Equiv.swap_apply_self _ _ _

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
  classical
  have h_disjoint : ∀ v ∈ C, ∀ w ∈ C, v ≠ w →
      Disjoint (hammingBall v t) (hammingBall w t) := by
    intro v hv w hw hvw
    refine Finset.disjoint_left.mpr fun u hu hu' => ?_
    rw [mem_hammingBall] at hu hu'
    have htri : hammingDist v w ≤ hammingDist v u + hammingDist u w :=
      hammingDist_triangle v u w
    rw [hammingDist_comm u w] at htri
    have := hC v w hv hw hvw
    omega
  have h_union_card : (C.biUnion (fun v => hammingBall v t)).card
      = C.card * (hammingBall v₀ t).card := by
    rw [Finset.card_biUnion h_disjoint]
    rw [Finset.sum_congr rfl (fun x _ => hamming_ball_card_eq x v₀ t), Finset.sum_const,
      smul_eq_mul]
  rw [← h_union_card]
  refine le_trans (Finset.card_le_univ _) ?_
  simp [Finset.card_univ]

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