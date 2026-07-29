import Mathlib

/-!
# Reed–Solomon codes over finite fields

This file gives a direct polynomial-evaluation construction of Reed–Solomon codes and
proves their designed-distance bound.  It also derives injectivity, separation, and a
unique-decoding theorem from the bound.
-/

namespace AlgebraicCodingTheory

open Polynomial

variable {F : Type*} [Field F] [DecidableEq F]

/-- Evaluation of a polynomial at a finite family of code locations. -/
def reedSolomonEval {n : ℕ} (points : Fin n → F) (p : F[X]) : Fin n → F :=
  fun i => p.eval (points i)

/-- Hamming distance on words of fixed length. -/
def hammingDistance {n : ℕ} {α : Type*} [DecidableEq α] (u v : Fin n → α) : ℕ :=
  (Finset.univ.filter fun i => u i ≠ v i).card

/-- The number of zero evaluations of a nonzero polynomial at distinct points is at
most its degree. -/
theorem card_zero_evaluations_le_natDegree {n : ℕ} (points : Fin n → F)
    (hpoints : Function.Injective points) (p : F[X]) (hp : p ≠ 0) :
    (Finset.univ.filter fun i => p.eval (points i) = 0).card ≤ p.natDegree := by
  have hroots : p.roots.card ≤ p.natDegree := by
    have := Polynomial.card_roots hp
    rw [Polynomial.degree_eq_natDegree hp] at this
    exact WithBot.coe_le_coe.mp this
  -- The filtered indices map via points to distinct roots
  have himage : ((Finset.univ.filter fun i => p.eval (points i) = 0).image points).card =
                (Finset.univ.filter fun i => p.eval (points i) = 0).card := by
    exact Finset.card_image_of_injective _ hpoints
  -- The image is a subset of roots
  have hsub : (Finset.univ.filter fun i => p.eval (points i) = 0).image points ⊆ p.roots.toFinset := by
    rw [Finset.image_subset_iff]
    intro i hi
    simp [Finset.mem_filter] at hi
    rw [Multiset.mem_toFinset, Polynomial.mem_roots hp]
    exact hi
  have htofinset : p.roots.toFinset.card ≤ p.roots.card := Multiset.toFinset_card_le p.roots
  calc (Finset.univ.filter fun i => p.eval (points i) = 0).card
      = ((Finset.univ.filter fun i => p.eval (points i) = 0).image points).card := himage.symm
    _ ≤ p.roots.toFinset.card := Finset.card_le_card hsub
    _ ≤ p.roots.card := htofinset
    _ ≤ p.natDegree := hroots

/-- A nonzero polynomial of degree less than `k`, evaluated at `n` distinct points,
has Hamming weight at least `n-k+1`.  This is the Reed–Solomon designed-distance
bound. -/
theorem reedSolomon_weight_bound {n k : ℕ} (points : Fin n → F)
    (hpoints : Function.Injective points) (p : F[X]) (hp : p ≠ 0)
    (hdeg : p.natDegree < k) (hkn : k ≤ n) :
    n - k + 1 ≤ (Finset.univ.filter fun i => reedSolomonEval points p i ≠ 0).card := by
  have hzero := card_zero_evaluations_le_natDegree points hpoints p hp
  -- reedSolomonEval points p i = p.eval (points i)
  have heq : ∀ i, reedSolomonEval points p i = p.eval (points i) := fun i => rfl
  -- The nonzero and zero sets partition Fin n
  have hcard_sum : (Finset.univ.filter fun i => p.eval (points i) ≠ 0).card +
                   (Finset.univ.filter fun i => p.eval (points i) = 0).card = n := by
    have : (Finset.univ.filter fun i => p.eval (points i) ≠ 0) ∪
           (Finset.univ.filter fun i => p.eval (points i) = 0) = Finset.univ := by
      ext i; by_cases hi : p.eval (points i) = 0 <;> simp [hi]
    rw [← Finset.card_union_of_disjoint (Finset.disjoint_filter.mpr fun _ _ _ => by tauto), this]
    simp
  -- zeros ≤ p.natDegree < k implies zeros ≤ k - 1
  have hzero_lt_k : (Finset.univ.filter fun i => p.eval (points i) = 0).card < k := by
    calc (Finset.univ.filter fun i => p.eval (points i) = 0).card
        ≤ p.natDegree := hzero
      _ < k := hdeg
  -- nonzeros = n - zeros ≥ n - (k - 1) = n - k + 1
  have hnonzero_le : (Finset.univ.filter fun i => p.eval (points i) ≠ 0).card =
                     n - (Finset.univ.filter fun i => p.eval (points i) = 0).card := by
    omega
  simp only [reedSolomonEval]
  rw [hnonzero_le]
  omega

/-- Distinct messages of degree less than `k` produce words separated by at least
`n-k+1` positions. -/
theorem reedSolomon_distance_bound {n k : ℕ} (points : Fin n → F)
    (hpoints : Function.Injective points) (p q : F[X]) (hpq : p ≠ q)
    (hpdeg : p.natDegree < k) (hqdeg : q.natDegree < k) (hkn : k ≤ n) :
    n - k + 1 ≤ hammingDistance (reedSolomonEval points p) (reedSolomonEval points q) := by
  have hdiff : p - q ≠ 0 := sub_ne_zero.mpr hpq
  have hdeg : (p - q).natDegree < k := by
    calc (p - q).natDegree ≤ max p.natDegree q.natDegree := Polynomial.natDegree_sub_le p q
      _ < k := max_lt hpdeg hqdeg
  have hbound := reedSolomon_weight_bound points hpoints (p - q) hdiff hdeg hkn
  simp only [hammingDistance, reedSolomonEval] at hbound ⊢
  convert hbound using 2
  simp [Polynomial.eval_sub]
  apply Finset.filter_congr
  intro i _
  simp [sub_eq_zero]

/-- When there are at least `k` evaluation points, Reed–Solomon encoding of
polynomials of degree less than `k` is injective. -/
theorem reedSolomon_eval_injective {n k : ℕ} (points : Fin n → F)
    (hpoints : Function.Injective points) (hkn : k ≤ n) :
    Function.Injective (fun p : {p : F[X] // p.natDegree < k} =>
      reedSolomonEval points p.1) := by
  intro p q hpq
  by_contra hne
  have hdist := reedSolomon_distance_bound points hpoints p.1 q.1 (by simpa [Subtype.ext_iff] using hne) p.2 q.2 hkn
  have hzero : hammingDistance (reedSolomonEval points p.1) (reedSolomonEval points q.1) = 0 := by
    simp [hpq, hammingDistance]
  rw [hzero] at hdist
  omega

/-- Metric form of unique decoding: two codewords at distance at least `d` cannot
both lie within radius `t` of one received word when `2t < d`. -/
theorem unique_decode_of_separation {α : Type*} [DecidableEq α] {n d t : ℕ}
    (x y received : Fin n → α) (hsep : d ≤ hammingDistance x y)
    (hx : hammingDistance x received ≤ t)
    (hy : hammingDistance y received ≤ t)
    (hradius : 2 * t < d) : False := by
  -- Triangle inequality: dist x y ≤ dist x received + dist received y
  have htri : hammingDistance x y ≤ hammingDistance x received + hammingDistance received y := by
    unfold hammingDistance
    have hsub : Finset.univ.filter fun i => x i ≠ y i ⊆
                (Finset.univ.filter fun i => x i ≠ received i) ∪
                (Finset.univ.filter fun i => received i ≠ y i) := by
      intro i hi
      simp at hi
      have : x i ≠ received i ∨ received i ≠ y i := by
        by_contra hne
        push_neg at hne
        exact hi (hne.1.trans hne.2)
      simp [this]
    exact le_trans (Finset.card_le_card hsub) (Finset.card_union_le _ _)
  -- Symmetry: dist y received = dist received y
  have hsym : hammingDistance y received = hammingDistance received y := by
    unfold hammingDistance
    congr 1
    apply Finset.filter_congr
    intro i _
    exact ne_comm
  omega

/-- Reed–Solomon unique-decoding guarantee up to any radius `t` satisfying
`2t < n-k+1`. -/
theorem reedSolomon_unique_decode {n k t : ℕ} (points : Fin n → F)
    (hpoints : Function.Injective points) (hkn : k ≤ n) (p q : F[X])
    (hpdeg : p.natDegree < k) (hqdeg : q.natDegree < k)
    (received : Fin n → F)
    (hpclose : hammingDistance (reedSolomonEval points p) received ≤ t)
    (hqclose : hammingDistance (reedSolomonEval points q) received ≤ t)
    (hradius : 2 * t < n - k + 1) : p = q := by
  by_contra hpq
  have hdist := reedSolomon_distance_bound points hpoints p q hpq hpdeg hqdeg hkn
  exact unique_decode_of_separation (reedSolomonEval points p) (reedSolomonEval points q) received hdist hpclose hqclose hradius

end AlgebraicCodingTheory