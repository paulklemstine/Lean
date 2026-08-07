import Mathlib

/-!
# The Library of Babel as a coding-theoretic structure

This file is the salvaged and completed version of a fragment about "Babel codes":
sets of *volumes* (words of length `L` over an alphabet with `A` symbols) with a
prescribed minimum Hamming distance.  The underlying definitions (`Volume`,
`IsBabelCode`, `hammingBall`, the column-disagreement bound) had been lost from
the catalog; they are reconstructed here and every statement is given a complete
proof.

Main results:

* `column_disagreement_bound` — in a fixed coordinate, the number of ordered
  disagreeing pairs of a code is at most `|C|²(A-1)/A` (stated multiplicatively);
* `plotkin_bound` — the Plotkin bound `|C| · (dA - L(A-1)) ≤ dA`;
* `hamming_ball_card_eq` — Hamming balls of a fixed radius are equicardinal;
* `hamming_bound_via_packing` — the sphere-packing (Hamming) bound;
* `babel_lawvere`, `lawvere_finite` — Lawvere's fixed-point/diagonal argument.
-/

open Function

namespace BabelCode

/-- A *volume* of the Library of Babel: a word of length `L` over an alphabet
with `A` symbols. -/
abbrev Volume (A L : ℕ) : Type := Fin L → Fin A

/-- `IsBabelCode C d` says that distinct volumes of `C` are at Hamming distance
at least `d`. -/
def IsBabelCode {A L : ℕ} (C : Finset (Volume A L)) (d : ℕ) : Prop :=
  ∀ v w : Volume A L, v ∈ C → w ∈ C → v ≠ w → d ≤ hammingDist v w

/-- The Hamming ball of radius `r` centred at `v`. -/
def hammingBall {A L : ℕ} (v : Volume A L) (r : ℕ) : Finset (Volume A L) :=
  Finset.univ.filter fun u => hammingDist v u ≤ r

@[simp] lemma mem_hammingBall {A L : ℕ} {v u : Volume A L} {r : ℕ} :
    u ∈ hammingBall v r ↔ hammingDist v u ≤ r := by
  simp [hammingBall]

/-- The Hamming distance is the number of disagreeing coordinates. -/
lemma hammingDist_eq_sum {A L : ℕ} (x y : Volume A L) :
    hammingDist x y = ∑ j : Fin L, if x j ≠ y j then 1 else 0 := by
  simp [hammingDist, Finset.card_filter]

/-! ## The column disagreement bound -/

/-- A purely arithmetic step used twice below. -/
private lemma aux_le (X v u P : ℕ) (h1 : X + v = u + P) (h2 : u ≤ v) : X ≤ P := by
  omega

/-- **Column disagreement bound.**  Fix a coordinate `j`.  Among the `|C|²`
ordered pairs of codewords, the number of pairs disagreeing at `j` is at most
`|C|²(A-1)/A`; multiplicatively, `A · #disagreements ≤ |C|²(A-1)`. -/
theorem column_disagreement_bound {A L : ℕ} (hA : 1 ≤ A) (j : Fin L)
    (C : Finset (Volume A L)) :
    (∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0) * A ≤ C.card ^ 2 * (A - 1) := by
  classical
  set n : Fin A → ℕ := fun a => (C.filter fun c => c j = a).card with hn_def
  -- the fibres of `c ↦ c j` partition `C`
  have hn : ∑ a : Fin A, n a = C.card :=
    (Finset.card_eq_sum_card_fiberwise (fun c _ => Finset.mem_univ (c j))).symm
  -- number of agreeing ordered pairs
  have hagree : (∑ p ∈ C ×ˢ C, if p.1 j = p.2 j then 1 else 0) = ∑ a : Fin A, n a * n a := by
    rw [Finset.sum_product]
    have hinner : ∀ u : Volume A L, (∑ v ∈ C, if u j = v j then 1 else 0) = n (u j) := by
      intro u
      simp only [hn_def]
      rw [Finset.card_filter]
      exact Finset.sum_congr rfl fun v _ => by by_cases h : u j = v j <;> simp [h, eq_comm]
    simp only [hinner]
    rw [← Finset.sum_fiberwise_of_maps_to (g := fun c : Volume A L => c j)
      (fun c _ => Finset.mem_univ (c j)) (fun u => n (u j))]
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [Finset.sum_congr rfl (g := fun _ => n a) (fun u hu => by
      rw [(Finset.mem_filter.mp hu).2])]
    simp [hn_def]
  -- total number of ordered pairs
  have htotal : (∑ p ∈ C ×ˢ C, (1 : ℕ)) = C.card ^ 2 := by
    simp [Finset.card_product, sq]
  have hsplit : (∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0)
      + (∑ p ∈ C ×ˢ C, if p.1 j = p.2 j then 1 else 0) = C.card ^ 2 := by
    rw [← htotal, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun p _ => ?_
    by_cases h : p.1 j = p.2 j <;> simp [h]
  -- Cauchy–Schwarz
  have hcs : C.card ^ 2 ≤ A * ∑ a : Fin A, n a * n a := by
    have := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin A))) (f := fun a => (n a : ℤ))
    have hcard : ((Finset.univ : Finset (Fin A)).card : ℤ) = (A : ℤ) := by simp
    rw [hcard] at this
    have hz : ((C.card : ℤ)) ^ 2 ≤ (A : ℤ) * ∑ a : Fin A, (n a : ℤ) * (n a : ℤ) := by
      calc ((C.card : ℤ)) ^ 2 = (∑ a : Fin A, (n a : ℤ)) ^ 2 := by
            rw [← Nat.cast_sum, hn]
        _ ≤ (A : ℤ) * ∑ a : Fin A, (n a : ℤ) ^ 2 := this
        _ = (A : ℤ) * ∑ a : Fin A, (n a : ℤ) * (n a : ℤ) := by
            simp [sq]
    exact_mod_cast hz
  -- assemble
  obtain ⟨A', rfl⟩ : ∃ A', A = A' + 1 := ⟨A - 1, by omega⟩
  set D := ∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0 with hD
  set G := ∑ a : Fin (A' + 1), n a * n a with hG
  rw [hagree] at hsplit
  have hDG : D ≤ A' * G := by nlinarith
  simp only [Nat.add_sub_cancel]
  nlinarith

/-! ## The Plotkin bound

**PEGB**:
- **P**roof: double count `∑_{(u,v) ∈ C × C} d(u,v)` from below by the minimum
  distance and from above by the column disagreement bound.
- **E**xample: binary codes of length 6 and distance 4 have at most 4 codewords.
- **G**eneralization: the same argument gives the `q`-ary Plotkin bound.
- **B**oundary: the bound is vacuous unless `L(A-1) < dA`.
-/

/-- **Plotkin bound.** -/
theorem plotkin_bound {A L d : ℕ} (hA : 1 ≤ A)
    (hPlotkin : L * (A - 1) < d * A)
    (C : Finset (Volume A L)) (hC : IsBabelCode C d) :
    C.card * (d * A - L * (A - 1)) ≤ d * A := by
  classical
  set S := ∑ p ∈ C ×ˢ C, hammingDist p.1 p.2 with hS
  -- lower bound on the total distance
  have hoff : ((C ×ˢ C).filter fun p : Volume A L × Volume A L => p.1 ≠ p.2) = C.offDiag := by
    ext p
    simp [Finset.mem_offDiag, Finset.mem_product, and_assoc]
  have hlow : (C.card * C.card - C.card) * d ≤ S := by
    have h1 : (∑ p ∈ C ×ˢ C, if p.1 ≠ p.2 then d else 0) ≤ S := by
      refine Finset.sum_le_sum fun p hp => ?_
      rcases Finset.mem_product.mp hp with ⟨hp1, hp2⟩
      by_cases h : p.1 = p.2
      · simp [h]
      · simpa [h] using hC p.1 p.2 hp1 hp2 h
    have h2 : (∑ p ∈ C ×ˢ C, if p.1 ≠ p.2 then d else 0)
        = (C.card * C.card - C.card) * d := by
      rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
      simp only [smul_eq_mul, mul_zero, add_zero]
      rw [hoff, Finset.offDiag_card]
    linarith [h1, h2.symm.le, h2.le]
  -- upper bound on the total distance
  have hup : A * S ≤ L * (C.card ^ 2 * (A - 1)) := by
    have hexpand : S = ∑ p ∈ C ×ˢ C, ∑ j : Fin L, if p.1 j ≠ p.2 j then 1 else 0 :=
      Finset.sum_congr rfl fun p _ => hammingDist_eq_sum p.1 p.2
    have hswap : S = ∑ j : Fin L, ∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0 := by
      rw [hexpand]; exact Finset.sum_comm
    rw [hswap, Finset.mul_sum]
    calc (∑ j : Fin L, A * ∑ p ∈ C ×ˢ C, if p.1 j ≠ p.2 j then 1 else 0)
        ≤ ∑ _j : Fin L, (C.card ^ 2 * (A - 1) : ℕ) := by
          refine Finset.sum_le_sum fun j _ => ?_
          rw [mul_comm]
          exact column_disagreement_bound hA j C
      _ = L * (C.card ^ 2 * (A - 1)) := by simp
  -- combine
  rcases Nat.eq_zero_or_pos C.card with hc | hc
  · simp [hc]
  obtain ⟨m, hm⟩ : ∃ m, C.card = m + 1 := ⟨C.card - 1, by omega⟩
  have hmain : A * ((C.card * C.card - C.card) * d) ≤ L * (C.card ^ 2 * (A - 1)) := by
    calc A * ((C.card * C.card - C.card) * d) ≤ A * S := Nat.mul_le_mul_left _ hlow
      _ ≤ L * (C.card ^ 2 * (A - 1)) := hup
  rw [hm] at hmain ⊢
  have hexp : ((m + 1) * (m + 1) - (m + 1)) = (m + 1) * m := by
    rw [Nat.mul_succ]
    omega
  rw [hexp] at hmain
  -- divide by `m + 1`
  have hdiv : A * (m * d) ≤ L * ((m + 1) * (A - 1)) := by
    have h := hmain
    have : (m + 1) * (A * (m * d)) ≤ (m + 1) * (L * ((m + 1) * (A - 1))) := by
      calc (m + 1) * (A * (m * d)) = A * ((m + 1) * m * d) := by ring
        _ ≤ L * ((m + 1) ^ 2 * (A - 1)) := h
        _ = (m + 1) * (L * ((m + 1) * (A - 1))) := by ring
    exact Nat.le_of_mul_le_mul_left this (by omega)
  refine aux_le _ ((m + 1) * (L * (A - 1))) (m * (d * A)) (d * A) ?_ ?_
  · have hle : L * (A - 1) ≤ d * A := le_of_lt hPlotkin
    have : (m + 1) * (d * A - L * (A - 1)) + (m + 1) * (L * (A - 1))
        = (m + 1) * (d * A) := by
      rw [← Nat.mul_add]
      congr 1
      omega
    rw [this]
    ring
  · calc m * (d * A) = A * (m * d) := by ring
      _ ≤ L * ((m + 1) * (A - 1)) := hdiv
      _ = (m + 1) * (L * (A - 1)) := by ring

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

/-! ## Lawvere's diagonal argument -/

/-- **Lawvere's fixed-point theorem, finite form.** -/
theorem lawvere_finite {X Y : Type*} [Fintype X] [Fintype Y] [DecidableEq Y]
    (hcard : Fintype.card Y ≥ 2) (_hX : Nonempty X)
    (f : X → X → Y) : ¬Surjective f := by
  obtain ⟨a, b, hab⟩ : ∃ a b : Y, a ≠ b := Fintype.one_lt_card_iff.1 hcard
  intro h_surjective
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : X, f x₀ = fun x => if f x x = a then b else a :=
    h_surjective _
  have h := congr_fun hx₀ x₀
  by_cases hc : f x₀ x₀ = a
  · rw [if_pos hc] at h
    exact hab (hc.symm.trans h)
  · rw [if_neg hc] at h
    exact hc h

/-- No map `Volume × Volume → Fin A` is surjective onto the function space in the
Lawvere sense: the Library cannot index its own descriptions. -/
theorem babel_lawvere {A L : ℕ} (hA : 2 ≤ A)
    (f : Volume A L → Volume A L → Fin A) : ¬Surjective f := by
  have hne : Nonempty (Volume A L) := ⟨fun _ => ⟨0, by omega⟩⟩
  refine lawvere_finite ?_ hne f
  simpa using hA

/-- **Boundary**: Lawvere fails when A = 1 (trivial alphabet). With only one symbol,
there is only one function `Volume → Fin 1`, and any `f` trivially covers it. -/
example (L : ℕ) (f : Volume 1 L → Volume 1 L → Fin 1) : Surjective f := by
  intro g
  refine ⟨fun _ => ⟨0, by omega⟩, ?_⟩
  funext x
  exact Subsingleton.elim _ _

/-! ## Equicardinality of Hamming balls -/

/-- Coordinatewise transposition of the symbols of `v` and `w`. -/
private def swapMap {A L : ℕ} (v w : Volume A L) : Volume A L → Volume A L :=
  fun a i => Equiv.swap (v i) (w i) (a i)

private lemma swapMap_involutive {A L : ℕ} (v w : Volume A L) (a : Volume A L) :
    swapMap v w (swapMap v w a) = a := by
  funext i
  simp [swapMap]

private lemma swapMap_left {A L : ℕ} (v w : Volume A L) : swapMap v w v = w := by
  funext i
  simp [swapMap]

private lemma hammingDist_swapMap {A L : ℕ} (v w a b : Volume A L) :
    hammingDist (swapMap v w a) (swapMap v w b) = hammingDist a b := by
  unfold hammingDist
  congr 1
  apply Finset.filter_congr
  intro i _
  simp [swapMap]

/-- Hamming balls of a fixed radius all have the same cardinality. -/
theorem hamming_ball_card_eq {A L : ℕ} (v w : Volume A L) (r : ℕ) :
    (hammingBall v r).card = (hammingBall w r).card := by
  classical
  have key : ∀ a : Volume A L, hammingDist w (swapMap v w a) = hammingDist v a := by
    intro a
    calc hammingDist w (swapMap v w a)
        = hammingDist (swapMap v w v) (swapMap v w a) := by rw [swapMap_left]
      _ = hammingDist v a := hammingDist_swapMap v w v a
  have himg : (hammingBall v r).image (swapMap v w) = hammingBall w r := by
    ext u
    simp only [Finset.mem_image, mem_hammingBall]
    constructor
    · rintro ⟨a, ha, rfl⟩
      rw [key a]
      exact ha
    · intro hu
      refine ⟨swapMap v w u, ?_, swapMap_involutive v w u⟩
      have hk := key (swapMap v w u)
      rw [swapMap_involutive] at hk
      omega
  rw [← himg, Finset.card_image_of_injective]
  intro a b hab
  have := congrArg (swapMap v w) hab
  rwa [swapMap_involutive, swapMap_involutive] at this

/-! ## The sphere-packing (Hamming) bound

If balls of radius `t` around codewords are disjoint (which holds when the minimum
distance is at least `2t+1`), the number of codewords times the ball size cannot
exceed the size of the library.
-/

/-- **Hamming (sphere-packing) bound.** -/
theorem hamming_bound_via_packing {A L d : ℕ} (_hA : 1 ≤ A) (t : ℕ)
    (hdt : 2 * t + 1 ≤ d)
    (C : Finset (Volume A L)) (hC : IsBabelCode C d)
    (v₀ : Volume A L) :
    C.card * (hammingBall v₀ t).card ≤ A ^ L := by
  classical
  have h_disjoint : ∀ v w : Volume A L, v ∈ C → w ∈ C → v ≠ w →
      Disjoint (hammingBall v t) (hammingBall w t) := by
    intro v w hv hw hvw
    refine Finset.disjoint_left.mpr fun u hu hu' => ?_
    rw [mem_hammingBall] at hu hu'
    have htri : hammingDist v w ≤ hammingDist v u + hammingDist u w :=
      hammingDist_triangle v u w
    rw [hammingDist_comm u w] at htri
    have := hC v w hv hw hvw
    omega
  have h_union_card : (C.biUnion fun v => hammingBall v t).card
      = C.card * (hammingBall v₀ t).card := by
    rw [Finset.card_biUnion (fun v hv w hw hvw => h_disjoint v w hv hw hvw)]
    rw [Finset.sum_congr rfl fun x _ => hamming_ball_card_eq x v₀ t]
    simp
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