import Mathlib
import Catalog.Computation.ListHammingBallParity
import Catalog.Computation.BinaryCodeBounds

/-!
# The [7,4,3] Hamming code is perfect, and `A(7,3) = 16`

Cycle 3 of the research thread.  Cycle 1 produced the ball-counting lemma and the
sphere-packing bound; cycle 2 produced the Singleton and Gilbert–Varshamov bounds and the
arithmetic obstruction `n + 1 = 2 ^ k` for perfect single-error-correcting codes.  The
obvious question left open was whether that necessary condition is ever *sufficient* — i.e.
whether a perfect code actually exists.  Here we settle the first nontrivial case.

## Main results

* `balls_tile_of_card_eq` — the equality case of sphere packing: if the volume identity
  `|C| · V = 2 ^ n` holds, the balls do not merely pack, they *tile*.  This turns a counting
  statement into a geometric one and is what makes perfectness checkable.
* `hamming74` — the systematic `[7,4,3]` Hamming code, listed explicitly.
* `hamming74_minDist`, `hamming74_card` — minimum distance `3`, size `16`.
* `hamming74_perfect` — the radius-1 balls around the 16 codewords tile the 7-cube.
  A perfect code exists in length `7 = 2 ^ 3 - 1`, complementing
  `perfect_one_error_correcting_length` and `no_perfect_code_length_four`.
* `hamming74_linear`, `hamming74_minWeight` — the code is closed under coordinatewise `xor`
  and contains the zero word, so by `linear_minDist_iff_minWeight` its distance property is
  equivalent to all 15 nonzero codewords having weight at least 3.
* `A_7_3_isGreatest` — the extremal number `A(7,3)` is determined exactly: `16` is the
  greatest size of a length-7 binary code with minimum distance 3.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the arithmetic condition `n + 1 = 2 ^ k` of cycle 2 is not
vacuous — for `n = 7` a perfect code exists, and moreover the sphere-packing bound is then
*exactly* the value of the extremal function `A(7,3)`.

Experiment (Experimenter): the naive route (checking the tiling `⋃ B_1(c) = words 7` by
evaluation) is expensive; instead we proved the equality case `balls_tile_of_card_eq`
abstractly, so that only two finite checks remain (`|C| = 16` and minimum distance `3`,
i.e. 256 pairwise distance evaluations).  The tiling — 16 balls of 8 words covering all 128
words — is then *derived*, not computed.

Analysis (Analyst): three cycles now interlock.  Counting (`ball_card`) gives packing;
packing plus an equality gives tiling; tiling gives the divisibility `(n+1) ∣ 2^n`; and the
explicit code shows the resulting arithmetic condition is achievable.  The extremal value
`A(7,3) = 16` is the first point where the upper bound (sphere packing) and the lower bound
(an explicit construction, in the spirit of Gilbert–Varshamov) meet.

Critique (Critic): the finite checks are genuine finite verifications of a nontrivial
object, not a substitute for the mathematics — every general statement used
(`balls_tile_of_card_eq`, `hamming_bound`, `linear_minDist_iff_minWeight`) is proved for
arbitrary `n`, `t`, `C`.  The one hidden assumption worth flagging: `A_7_3_isGreatest`
measures codes as *sets of words of length 7*, so it is the unrestricted `A(7,3)`, not the
linear-code analogue.
-/

namespace ListCode

open Finset

/-- `MinDist` is decidable on explicit finite codes. -/
instance decidableMinDist (C : Finset (List Bool)) (d : ℕ) : Decidable (MinDist C d) := by
  unfold MinDist; infer_instance

/-- **Equality case of sphere packing.**  If a code attains the volume identity
`|C| · V(n,t) = 2 ^ n`, then the radius-`t` balls around its codewords tile the cube. -/
theorem balls_tile_of_card_eq {n t : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C (2 * t + 1))
    (heq : C.card * (∑ i ∈ Finset.range (t + 1), n.choose i) = 2 ^ n) :
    C.biUnion (fun x => ball n t x) = words n := by
  classical
  have hsub : C.biUnion (fun x => ball n t x) ⊆ words n := by
    intro z hz
    obtain ⟨x, -, hzx⟩ := Finset.mem_biUnion.mp hz
    exact ball_subset_words n t x hzx
  have hcard : (C.biUnion (fun x => ball n t x)).card
      = ∑ x ∈ C, (ball n t x).card := Finset.card_biUnion (balls_pairwiseDisjoint hC hmin)
  have hvol : ∀ x ∈ C, (ball n t x).card = ∑ i ∈ Finset.range (t + 1), n.choose i :=
    fun x hx => ball_card n t x (mem_words.mp (hC hx))
  rw [Finset.sum_congr rfl hvol, Finset.sum_const, smul_eq_mul] at hcard
  refine Finset.eq_of_subset_of_card_le hsub ?_
  rw [hcard, heq, card_words]

/-! ## The [7,4,3] Hamming code -/

/-- The systematic `[7,4,3]` Hamming code: the payload `(a,b,c,d)` is followed by the three
parity checks `a⊕b⊕c`, `b⊕c⊕d`, `a⊕b⊕d`. -/
def hamming74 : Finset (List Bool) :=
  {[false, false, false, false, false, false, false],
   [true, false, false, false, true, false, true],
   [false, true, false, false, true, true, true],
   [true, true, false, false, false, true, false],
   [false, false, true, false, true, true, false],
   [true, false, true, false, false, true, true],
   [false, true, true, false, false, false, true],
   [true, true, true, false, true, false, false],
   [false, false, false, true, false, true, true],
   [true, false, false, true, true, true, false],
   [false, true, false, true, true, false, false],
   [true, true, false, true, false, false, true],
   [false, false, true, true, true, false, true],
   [true, false, true, true, false, false, false],
   [false, true, true, true, false, true, false],
   [true, true, true, true, true, true, true]}

set_option maxRecDepth 100000 in
theorem hamming74_subset : hamming74 ⊆ words 7 := by decide

set_option maxRecDepth 100000 in
theorem hamming74_card : hamming74.card = 16 := by decide

set_option maxRecDepth 100000 in
/-- The 16 codewords are pairwise at Hamming distance at least `3`: the code corrects one
error. -/
theorem hamming74_minDist : MinDist hamming74 3 := by decide

set_option maxRecDepth 100000 in
/-- The code is closed under coordinatewise `xor`: it is linear. -/
theorem hamming74_linear :
    ∀ x ∈ hamming74, ∀ y ∈ hamming74, xorWord x y ∈ hamming74 := by decide

set_option maxRecDepth 100000 in
theorem zeroWord_mem_hamming74 : zeroWord 7 ∈ hamming74 := by decide

/-- Via the linear-code criterion of cycle 2, the distance property is equivalent to all 15
nonzero codewords having weight at least `3`. -/
theorem hamming74_minWeight : ∀ x ∈ hamming74, x ≠ zeroWord 7 → 3 ≤ weight x :=
  (linear_minDist_iff_minWeight hamming74_subset zeroWord_mem_hamming74 hamming74_linear).mp
    hamming74_minDist

/-- **The Hamming code is perfect.**  The 16 radius-1 balls tile the 7-cube: every one of
the 128 binary words of length 7 is within one bit flip of exactly one codeword. -/
theorem hamming74_perfect :
    hamming74.biUnion (fun x => ball 7 1 x) = words 7 := by
  refine balls_tile_of_card_eq hamming74_subset (by simpa using hamming74_minDist) ?_
  rw [hamming74_card]
  decide

/-- Consistency with the arithmetic obstruction of cycle 2: perfectness forces `n + 1` to be
a power of two, and indeed `7 + 1 = 2 ^ 3`. -/
theorem hamming74_length_power_of_two : ∃ k, 7 + 1 = 2 ^ k :=
  perfect_one_error_correcting_length hamming74_subset hamming74_minDist hamming74_perfect

/-! ## The extremal number `A(7,3)` -/

/-- **`A(7,3) = 16`.**  The greatest possible size of a binary code of length `7` with
minimum distance `3` is exactly `16`: the sphere-packing bound gives `≤ 16`, and the Hamming
code attains it. -/
theorem A_7_3_isGreatest :
    IsGreatest {m : ℕ | ∃ C : Finset (List Bool), C ⊆ words 7 ∧ MinDist C 3 ∧ C.card = m} 16 := by
  constructor
  · exact ⟨hamming74, hamming74_subset, hamming74_minDist, hamming74_card⟩
  · rintro m ⟨C, hC, hmin, rfl⟩
    have h := hamming_bound (t := 1) hC (by simpa using hmin)
    have hv : (∑ i ∈ Finset.range (1 + 1), (7 : ℕ).choose i) = 8 := by decide
    rw [hv] at h
    omega

end ListCode