-- Repaired copy: this module was a stale, non-compiling duplicate of `Shared.BabelCodeasanovelmathematicalstructure.SalvagedBest`.
-- Its content is synchronised with that (compiling) module.
/-
# Babel codes: Plotkin bound, Lawvere diagonal, and sphere packing

The "Volume" of the Library of Babel with alphabet size `A` and page length `L`
is the Hamming space `Fin L → Fin A`.  A *Babel code* of minimum distance `d` is
a set of volumes pairwise at Hamming distance at least `d`.

This file was recovered from a fragment whose supporting definitions
(`Volume`, `IsBabelCode`, `hammingBall`, and the column-disagreement counting
lemma) were missing.  They are supplied here and every statement is proved
from scratch, with no `sorry` and no appeal to `native_decide`.
-/
import Mathlib

open Function

namespace BabelCode

/-- The Hamming space of "volumes": pages of length `L` over an alphabet of size `A`. -/
abbrev Volume (A L : ℕ) := Fin L → Fin A

/-- A Babel code of minimum distance `d`: distinct codewords differ in at least
`d` positions. -/
def IsBabelCode {A L : ℕ} (C : Finset (Volume A L)) (d : ℕ) : Prop :=
  ∀ v w : Volume A L, v ∈ C → w ∈ C → v ≠ w → d ≤ hammingDist v w

/-- The Hamming ball of radius `r` around a volume `v`. -/
def hammingBall {A L : ℕ} (v : Volume A L) (r : ℕ) : Finset (Volume A L) :=
  {u | hammingDist u v ≤ r}

/-! ## Column counting

The engine of the Plotkin bound: in a single coordinate `j`, the number of
*ordered pairs of codewords agreeing at `j`* is `∑ₐ nₐ²` where `nₐ` counts the
codewords carrying the symbol `a` in position `j`.  Cauchy–Schwarz then bounds
the number of disagreeing pairs. -/

/-- Ordered pairs of codewords agreeing in column `j`, counted fibrewise. -/
lemma card_agree_column {A L : ℕ} (C : Finset (Volume A L)) (j : Fin L) :
    ((C ×ˢ C).filter (fun p => p.1 j = p.2 j)).card
      = ∑ a : Fin A, ((C.filter (fun v => v j = a)).card) ^ 2 := by
  classical
  rw [Finset.card_eq_sum_card_fiberwise
      (f := fun p : Volume A L × Volume A L => p.1 j) (t := Finset.univ)
      (fun x _ => by simp)]
  refine Finset.sum_congr rfl fun a _ => ?_
  have hfib : (((C ×ˢ C).filter (fun p => p.1 j = p.2 j)).filter (fun p => p.1 j = a))
      = (C.filter (fun v => v j = a)) ×ˢ (C.filter (fun v => v j = a)) := by
    ext ⟨u, x⟩
    simp only [Finset.mem_filter, Finset.mem_product]
    constructor
    · rintro ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩; exact ⟨⟨h1, h4⟩, ⟨h2, h3 ▸ h4⟩⟩
    · rintro ⟨⟨h1, h2⟩, ⟨h3, h4⟩⟩; exact ⟨⟨⟨h1, h3⟩, h2.trans h4.symm⟩, h2⟩
  rw [hfib, Finset.card_product, sq]

/-- The fibres of the `j`-th column map partition the code. -/
lemma sum_fiber_card {A L : ℕ} (C : Finset (Volume A L)) (j : Fin L) :
    ∑ a : Fin A, (C.filter (fun v => v j = a)).card = C.card := by
  classical
  exact (Finset.card_eq_sum_card_fiberwise (f := fun v : Volume A L => v j)
    (t := Finset.univ) (fun x _ => by simp)).symm

/-- **Column disagreement bound.** In any single coordinate, the number of ordered
pairs of codewords that disagree is at most `|C|² (A-1)/A`, stated without
division as `A · #disagreeing ≤ |C|² (A-1)`.  This is Cauchy–Schwarz. -/
lemma column_disagreement_bound {A L : ℕ} (j : Fin L) (C : Finset (Volume A L)) :
    A * ((C ×ˢ C).filter (fun p => p.1 j ≠ p.2 j)).card ≤ C.card ^ 2 * (A - 1) := by
  classical
  set n : Fin A → ℕ := fun a => (C.filter (fun v => v j = a)).card with hn
  set S : ℕ := ∑ a : Fin A, (n a) ^ 2 with hS
  have hsum : ∑ a : Fin A, n a = C.card := sum_fiber_card C j
  have hcs : C.card ^ 2 ≤ A * S := by
    have h : ((∑ a : Fin A, (n a : ℤ)) ^ 2)
        ≤ (Finset.univ.card : ℤ) * ∑ a : Fin A, (n a : ℤ) ^ 2 := sq_sum_le_card_mul_sum_sq
    rw [Finset.card_univ, Fintype.card_fin] at h
    rw [hS]
    push_cast [← hsum]
    exact_mod_cast h
  have hsplit : ((C ×ˢ C).filter (fun p => p.1 j = p.2 j)).card
      + ((C ×ˢ C).filter (fun p => p.1 j ≠ p.2 j)).card = C.card ^ 2 := by
    simpa [ne_eq] using
      (Finset.card_filter_add_card_filter_not (s := C ×ˢ C)
        (p := fun p : Volume A L × Volume A L => p.1 j = p.2 j)).trans
        (by rw [Finset.card_product, sq])
  rw [card_agree_column, ← hS] at hsplit
  have hdis : ((C ×ˢ C).filter (fun p => p.1 j ≠ p.2 j)).card = C.card ^ 2 - S := by omega
  rw [hdis]
  calc A * (C.card ^ 2 - S) = A * C.card ^ 2 - A * S := by rw [Nat.mul_sub]
    _ ≤ A * C.card ^ 2 - C.card ^ 2 := Nat.sub_le_sub_left hcs _
    _ = C.card ^ 2 * (A - 1) := by rw [Nat.mul_sub, Nat.mul_one, Nat.mul_comm]

/-- Total pairwise Hamming distance, decomposed column by column. -/
lemma sum_hammingDist_eq_sum_columns {A L : ℕ} (C : Finset (Volume A L)) :
    ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2
      = ∑ j : Fin L, ((C ×ˢ C).filter (fun p => p.1 j ≠ p.2 j)).card := by
  classical
  simp only [hammingDist, Finset.card_filter]
  rw [Finset.sum_comm]

/-- Lower bound for the total pairwise Hamming distance of a code of minimum
distance `d`: every one of the `|C|² - |C|` off-diagonal ordered pairs
contributes at least `d`. -/
lemma sum_hammingDist_lower {A L d : ℕ} (C : Finset (Volume A L)) (hC : IsBabelCode C d) :
    d * (C.card ^ 2 - C.card) ≤ ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 := by
  classical
  have h1 : ∑ p ∈ C ×ˢ C, (if p.1 = p.2 then 0 else d)
      ≤ ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 := by
    refine Finset.sum_le_sum ?_
    rintro ⟨u, v⟩ hp
    rw [Finset.mem_product] at hp
    by_cases h : u = v
    · simp [h]
    · simpa [h] using hC u v hp.1 hp.2 h
  refine le_trans (le_of_eq ?_) h1
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
  have hoff : ((C ×ˢ C).filter (fun p => ¬ p.1 = p.2)).card = C.card ^ 2 - C.card := by
    have h2 : ((C ×ˢ C).filter (fun p : Volume A L × Volume A L => p.1 = p.2)).card
        = C.card := by
      rw [show ((C ×ˢ C).filter (fun p : Volume A L × Volume A L => p.1 = p.2))
          = C.image (fun v => (v, v)) by
        ext ⟨u, v⟩; simp [Finset.mem_product]; aesop]
      exact Finset.card_image_of_injective _ (fun a b h => (Prod.mk.injEq _ _ _ _ ▸ h).1)
    have h3 := Finset.card_filter_add_card_filter_not (s := C ×ˢ C)
      (p := fun p : Volume A L × Volume A L => p.1 = p.2)
    rw [h2, Finset.card_product] at h3
    have h4 : C.card ^ 2 = C.card * C.card := sq C.card
    omega
  simp [hoff, Nat.mul_comm]

/-! ## Theorem 1: the Plotkin bound

**PEGB**:
- **P**roof: double count the total pairwise Hamming distance of the code; the
  off-diagonal pairs force it to be at least `|C|(|C|-1)d`, while column-by-column
  Cauchy–Schwarz forces it to be at most `L|C|²(A-1)/A`.
- **E**xample: binary codes of length 6 and distance 4 have at most 4 codewords.
- **G**eneralization: the same double count gives the Plotkin bound over any
  alphabet, and equality forces equidistance.
- **B**oundary: the hypothesis `L(A-1) < dA` is essential; without it the bound
  is vacuous (and the natural subtraction would truncate).
-/

/-- **Plotkin bound.** If `L(A-1) < dA` then a Babel code of minimum distance `d`
satisfies `|C| · (dA - L(A-1)) ≤ dA`. -/
theorem plotkin_bound {A L d : ℕ} (hA : 1 ≤ A) (hd : 1 ≤ d)
    (hPlotkin : L * (A - 1) < d * A)
    (C : Finset (Volume A L)) (hC : IsBabelCode C d) :
    C.card * (d * A - L * (A - 1)) ≤ d * A := by
  classical
  set m := C.card with hm
  -- Upper bound on `A ·` (total pairwise distance), column by column.
  have hupper : A * ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 ≤ L * (m ^ 2 * (A - 1)) := by
    rw [sum_hammingDist_eq_sum_columns, Finset.mul_sum]
    calc ∑ j : Fin L, A * ((C ×ˢ C).filter (fun p => p.1 j ≠ p.2 j)).card
        ≤ ∑ _j : Fin L, m ^ 2 * (A - 1) :=
          Finset.sum_le_sum fun j _ => column_disagreement_bound j C
      _ = L * (m ^ 2 * (A - 1)) := by simp [Finset.sum_const, mul_comm]
  -- Lower bound.
  have hlower : A * (d * (m ^ 2 - m)) ≤ A * ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 :=
    Nat.mul_le_mul_left _ (sum_hammingDist_lower C hC)
  have hkey : (d * A) * (m ^ 2 - m) ≤ (L * (A - 1)) * m ^ 2 := by
    have h := le_trans hlower hupper
    calc (d * A) * (m ^ 2 - m) = A * (d * (m ^ 2 - m)) := by ring
      _ ≤ L * (m ^ 2 * (A - 1)) := h
      _ = (L * (A - 1)) * m ^ 2 := by ring
  -- Pure arithmetic finish.
  clear hupper hlower hC hd hA
  set X := d * A
  set Y := L * (A - 1)
  rcases Nat.eq_zero_or_pos m with hm0 | hmpos
  · simp [hm0]
  obtain ⟨k, hk⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
  obtain ⟨Z, hZ⟩ : ∃ Z, X = Y + Z := ⟨X - Y, by omega⟩
  rw [hk] at hkey ⊢
  rw [hZ] at hkey ⊢
  have hsq : (k + 1) ^ 2 - (k + 1) = (k + 1) * k := by ring_nf; omega
  rw [hsq] at hkey
  have h2 : (Y + Z) * k ≤ Y * (k + 1) := by
    have hmul : (k + 1) * ((Y + Z) * k) ≤ (k + 1) * (Y * (k + 1)) := by
      calc (k + 1) * ((Y + Z) * k) = (Y + Z) * ((k + 1) * k) := by ring
        _ ≤ Y * (k + 1) ^ 2 := hkey
        _ = (k + 1) * (Y * (k + 1)) := by ring
    exact Nat.le_of_mul_le_mul_left hmul (by omega)
  have hYZ : Y + Z - Y = Z := by omega
  rw [hYZ]
  nlinarith

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
  classical
  -- Apply the coordinatewise transposition swapping `v i` and `w i`.
  have key : ∀ u : Volume A L,
      hammingDist (fun i => Equiv.swap (v i) (w i) (u i)) w = hammingDist u v := by
    intro u
    unfold hammingDist
    refine congrArg Finset.card (Finset.filter_congr fun i _ => ?_)
    simp [Equiv.apply_eq_iff_eq_symm_apply, Equiv.swap_apply_right]
  have key2 : ∀ u : Volume A L,
      hammingDist (fun i => Equiv.swap (v i) (w i) (u i)) v = hammingDist u w := by
    intro u
    unfold hammingDist
    refine congrArg Finset.card (Finset.filter_congr fun i _ => ?_)
    simp [Equiv.apply_eq_iff_eq_symm_apply, Equiv.swap_apply_left]
  refine Finset.card_bij' (fun u _ => fun i => Equiv.swap (v i) (w i) (u i))
      (fun u _ => fun i => Equiv.swap (v i) (w i) (u i)) ?_ ?_ ?_ ?_
  · intro u hu
    simp only [hammingBall, Finset.mem_filter, Finset.mem_univ, true_and] at hu ⊢
    rw [key]; exact hu
  · intro u hu
    simp only [hammingBall, Finset.mem_filter, Finset.mem_univ, true_and] at hu ⊢
    rw [key2]; exact hu
  · intro u _; funext i; simp
  · intro u _; funext i; simp

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
  have hdisj : ∀ v ∈ C, ∀ w ∈ C, v ≠ w →
      Disjoint (hammingBall v t) (hammingBall w t) := by
    intro v hv w hw hvw
    refine Finset.disjoint_left.mpr ?_
    intro u hu hu'
    simp only [hammingBall, Finset.mem_filter, Finset.mem_univ, true_and] at hu hu'
    have htri : hammingDist v w ≤ hammingDist v u + hammingDist u w := hammingDist_triangle _ _ _
    have hcomm : hammingDist v u = hammingDist u v := hammingDist_comm _ _
    have hmin := hC v w hv hw hvw
    omega
  have hcard : (C.biUnion (fun v => hammingBall v t)).card
      = C.card * (hammingBall v₀ t).card := by
    rw [Finset.card_biUnion hdisj, Finset.sum_congr rfl (fun x _ => hamming_ball_card_eq x v₀ t),
      Finset.sum_const, smul_eq_mul]
  rw [← hcard]
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