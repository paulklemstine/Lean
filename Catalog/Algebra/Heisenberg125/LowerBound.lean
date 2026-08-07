/-
# The lower bound `d(H_{p^3}) ≥ 3p - 3`

The explicit product-one-free sequence is `x^{p-1} y^{p-1} v^{p-1}`, of length
`3p - 3`.  For `p = 5` this gives the lower bound `d(H_125) ≥ 12` of the paper
"The small Davenport constant of the Heisenberg group of order 125".

The proof is a clean application of the product formula `Heis.prod_eq`: the
first two coordinates of a product are order independent, so a product-one
subsequence must use a multiple of `p` copies of `x` and of `y`; as at most
`p - 1` copies of each are available, it uses none, and is then a power of the
central element `v`, whose third coordinate is its length.
-/
import Algebra.Heisenberg125.Basic

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

@[simp] lemma asum_append (L M : List (Heis p)) : asum (L ++ M) = asum L + asum M := by
  simp [asum]
@[simp] lemma bsum_append (L M : List (Heis p)) : bsum (L ++ M) = bsum L + bsum M := by
  simp [bsum]
@[simp] lemma csum_append (L M : List (Heis p)) : csum (L ++ M) = csum L + csum M := by
  simp [csum]

@[simp] lemma asum_replicate (n : ℕ) (g : Heis p) :
    asum (List.replicate n g) = (n : ZMod p) * g.a := by
  simp [asum, List.map_replicate, nsmul_eq_mul]
@[simp] lemma bsum_replicate (n : ℕ) (g : Heis p) :
    bsum (List.replicate n g) = (n : ZMod p) * g.b := by
  simp [bsum, List.map_replicate, nsmul_eq_mul]
@[simp] lemma csum_replicate (n : ℕ) (g : Heis p) :
    csum (List.replicate n g) = (n : ZMod p) * g.c := by
  simp [csum, List.map_replicate, nsmul_eq_mul]

/-- The candidate extremal sequence `x^{p-1} y^{p-1} v^{p-1}`. -/
def extremalSeq (p : ℕ) : List (Heis p) :=
  List.replicate (p - 1) (x p) ++ List.replicate (p - 1) (y p) ++ List.replicate (p - 1) (v p)

@[simp] lemma length_extremalSeq : (extremalSeq p).length = 3 * (p - 1) := by
  simp only [extremalSeq, List.length_append, List.length_replicate]
  ring

/-- A natural number `n ≤ p - 1` whose class in `ZMod p` vanishes is zero. -/
lemma eq_zero_of_cast_eq_zero (hp : 0 < p) {n : ℕ} (hn : n ≤ p - 1)
    (h : (n : ZMod p) = 0) : n = 0 := by
  have hdvd : p ∣ n := (ZMod.natCast_eq_zero_iff _ _).1 h
  by_contra hne
  have := Nat.le_of_dvd (Nat.pos_of_ne_zero hne) hdvd
  omega

/-- **The lower bound sequence is product-one-free.** -/
theorem productOneFree_extremalSeq (hp : 0 < p) : ProductOneFree (extremalSeq p) := by
  rintro T hT hne ⟨M, hM, hprod⟩
  obtain ⟨T12, T3, rfl, h12, h3⟩ := List.sublist_append_iff.1 hT
  obtain ⟨T1, T2, rfl, h1, h2⟩ := List.sublist_append_iff.1 h12
  obtain ⟨i, hi, rfl⟩ := List.sublist_replicate_iff.1 h1
  obtain ⟨j, hj, rfl⟩ := List.sublist_replicate_iff.1 h2
  obtain ⟨k, hk, rfl⟩ := List.sublist_replicate_iff.1 h3
  rw [prod_eq_one_iff] at hprod
  obtain ⟨ha, hb, hc⟩ := hprod
  rw [asum_perm hM] at ha
  rw [bsum_perm hM] at hb
  simp only [asum_append, asum_replicate, bsum_append, bsum_replicate, x, y, v,
    mul_zero, mul_one, add_zero, zero_add] at ha hb
  have hi0 : i = 0 := eq_zero_of_cast_eq_zero hp hi ha
  have hj0 : j = 0 := eq_zero_of_cast_eq_zero hp hj hb
  subst hi0; subst hj0
  -- now `T` is a power of the central element `v`
  have hmemM : ∀ g ∈ M, g = v p := by
    intro g hg
    have : g ∈ List.replicate 0 (x p) ++ List.replicate 0 (y p) ++ List.replicate k (v p) :=
      hM.mem_iff.1 hg
    simpa using List.eq_of_mem_replicate (by simpa using this)
  have hcross : crossSum M = 0 :=
    crossSum_eq_zero_of_a_eq_zero fun g hg => by rw [hmemM g hg]; rfl
  rw [hcross, add_zero, csum_perm hM] at hc
  simp only [csum_replicate, v, mul_one, List.replicate_zero, List.nil_append] at hc
  have hk0 : k = 0 := eq_zero_of_cast_eq_zero hp hk hc
  subst hk0
  exact hne (by simp)

end Heis

/-! ## Consequences for the small Davenport constant -/

open Heis

variable {p : ℕ}

/-- **Lower bound.**  `d(H_{p^3}) ≥ 3p - 3` for every prime `p` (indeed every `p ≥ 1`). -/
theorem three_p_sub_three_le_smallDavenport [NeZero p] :
    3 * (p - 1) ≤ smallDavenport (Heis p) := by
  have hp : 0 < p := Nat.pos_of_ne_zero (NeZero.ne p)
  simpa using (productOneFree_extremalSeq (p := p) hp).length_le_smallDavenport

/-- The lower bound of the paper: `d(H_125) ≥ 12`, witnessed by `x^4 y^4 v^4`. -/
theorem twelve_le_smallDavenport_heis_five : 12 ≤ smallDavenport (Heis 5) := by
  simpa using three_p_sub_three_le_smallDavenport (p := 5)

/-- The trivial general upper bound for `H_125`: `d(H_125) ≤ 124`. -/
theorem smallDavenport_heis_five_le_124 : smallDavenport (Heis 5) ≤ 124 := by
  have := smallDavenport_le_card_sub_one (G := Heis 5)
  simpa using this

end Heisenberg125