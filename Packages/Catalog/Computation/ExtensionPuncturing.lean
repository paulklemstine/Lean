import Catalog.Computation.ListHammingBallParity
import Catalog.Computation.HammingCodePerfect
import Catalog.Computation.HammingCodesGeneral

/-!
# Cycle 7 — The extremal function `A(n,d)` and the extension/puncturing involution

This file introduces the *unrestricted binary extremal function*

  `A n d = sSup { |C| : C ⊆ words n, MinDist C d }`

for the `List Bool` model of cycle 1, and proves the classical structural theorem that
identifies odd and even minimum distances:

  **`A_succ_succ_of_odd` :  `Odd d → A n d = A (n + 1) (d + 1)`.**

Both inequalities are *constructive maps between codes*, not counting arguments:

* `≤` — **extension.**  `withParity` sends a length-`n` code of minimum distance `d` to a
  length-`(n+1)` code of minimum distance `d + 1`.  The gain of one unit is *not* automatic:
  it uses `parity_iff_even_hdist`, i.e. that all distances in the extended code are even,
  so a distance that was `≥ d` with `d` odd is forced up to `≥ d + 1`.
* `≥` — **puncturing.**  `List.dropLast` sends a length-`(n+1)` code of minimum distance
  `d + 1 ≥ 2` injectively to a length-`n` code of minimum distance `d`.

Consequences proved here: `A n 1 = 2 ^ n`, `A (n+1) 2 = 2 ^ n` (a second, structural proof
of the optimality of the parity code), `A 8 4 = 16`, and `A (2 ^ k) 4 = |Hamming k|`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the parity extension of cycle 1 is not merely a gadget for
`d = 1`; it is one half of a *bijection between extremal problems* at odd `d` and even
`d + 1`.  If so, every odd-distance result in the catalog (`A(7,3) = 16`,
`A(2^k - 1, 3)`) immediately yields an even-distance twin at no extra cost.

Experiment (Experimenter): the extension direction was proved first, and its parity-gain
step failed on the naive route `d ≤ hdist ⟹ d + 1 ≤ hdist + 1` (that needs the parity bit
to *always* disagree, which is false).  The repair is the evenness argument: when parities
agree the distance is even, and an even number `≥` an odd `d` is `≥ d + 1`.  The puncturing
direction needed the new inequality `hdist_le_hdist_dropLast_succ`, obtained by splitting
`x = x.dropLast ++ [x.getLast]` and applying `hdist_append`.

Analysis (Analyst): the hypothesis `Odd d` is load-bearing in the extension direction only;
puncturing works for every `d ≥ 1`.  So unconditionally `A (n+1) (d+1) ≤ A n d`, and for
*even* `d` the inequality can be strict: `A_four_three_lt_A_three_two` proves
`A 4 3 < A 3 2` (the right-hand side is `4` by `A_two`, the left-hand side is at most `3`
by sphere packing), so `A_succ_succ_of_odd` is false without `Odd d`.  The correct slogan
is therefore "odd distances are the primitive ones", which is exactly why the
sphere-packing bound is stated at `d = 2t + 1`.

Critique (Critic): `A` is defined by `sSup` on a set of naturals, so it could silently be
`0` if the set were unbounded or empty; `A_isGreatest` rules this out by exhibiting the set
as nonempty and bounded by `2 ^ n`, and every downstream corollary goes through that lemma
rather than through `sSup` directly.  No result here is `decide`-only: the two finite
inputs (`A 7 3 = 16`, `A (2^k-1) 3`) are imported from earlier cycles.
-/

namespace ListCode

open Finset

/-! ## The extremal function -/

/-- The set of achievable sizes of a length-`n` binary code with minimum distance `d`. -/
def codeSizes (n d : ℕ) : Set ℕ :=
  {m | ∃ C : Finset (List Bool), C ⊆ words n ∧ MinDist C d ∧ C.card = m}

/-- `A n d`: the largest size of a binary code of length `n` with minimum distance `d`. -/
noncomputable def A (n d : ℕ) : ℕ := sSup (codeSizes n d)

lemma codeSizes_nonempty (n d : ℕ) : (codeSizes n d).Nonempty :=
  ⟨0, ∅, by simp, by intro x hx; simp at hx, rfl⟩

lemma codeSizes_bddAbove (n d : ℕ) : BddAbove (codeSizes n d) := by
  refine ⟨2 ^ n, ?_⟩
  rintro m ⟨C, hC, -, rfl⟩
  calc C.card ≤ (words n).card := Finset.card_le_card hC
    _ = 2 ^ n := card_words n

/-- `A n d` is attained: it is the greatest achievable code size. -/
theorem A_isGreatest (n d : ℕ) : IsGreatest (codeSizes n d) (A n d) :=
  ⟨Nat.sSup_mem (codeSizes_nonempty n d) (codeSizes_bddAbove n d),
    fun _ hm => le_csSup (codeSizes_bddAbove n d) hm⟩

/-- Any code of length `n` with minimum distance `d` has at most `A n d` words. -/
theorem card_le_A {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n) (hmin : MinDist C d) :
    C.card ≤ A n d :=
  (A_isGreatest n d).2 ⟨C, hC, hmin, rfl⟩

/-- If some code of length `n`, minimum distance `d`, has `m` words then `m ≤ A n d`;
conversely `A n d` itself is realised by a code. -/
theorem exists_code_card_A (n d : ℕ) :
    ∃ C : Finset (List Bool), C ⊆ words n ∧ MinDist C d ∧ C.card = A n d :=
  (A_isGreatest n d).1

theorem A_le_two_pow (n d : ℕ) : A n d ≤ 2 ^ n := by
  obtain ⟨C, hC, -, hcard⟩ := exists_code_card_A n d
  calc A n d = C.card := hcard.symm
    _ ≤ (words n).card := Finset.card_le_card hC
    _ = 2 ^ n := card_words n

/-! ## Extension: odd distance `d` at length `n` becomes distance `d + 1` at length `n + 1` -/

/-- **Parity extension raises an odd minimum distance.**  All Hamming distances inside a
parity-extended code are even, so a bound `d ≤ hdist` with `d` odd improves to `d + 1`. -/
theorem minDist_image_withParity {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C d) (hd : Odd d) : MinDist (C.image withParity) (d + 1) := by
  rintro x hx y hy hxy
  obtain ⟨l, hl, rfl⟩ := Finset.mem_image.mp hx
  obtain ⟨m, hm, rfl⟩ := Finset.mem_image.mp hy
  have hlen : l.length = m.length := by
    rw [mem_words.mp (hC hl), mem_words.mp (hC hm)]
  have hne : l ≠ m := fun h => hxy (by rw [h])
  have hbase : d ≤ hdist l m := hmin l hl m hm hne
  rw [hdist_withParity hlen]
  by_cases hp : parity l = parity m
  · rw [if_pos hp]
    have heven : Even (hdist l m) := (parity_iff_even_hdist hlen).mp hp
    obtain ⟨k, hk⟩ := heven
    obtain ⟨j, hj⟩ := hd
    omega
  · rw [if_neg hp]
    omega

/-- The parity extension of a length-`n` code lives in the words of length `n + 1`. -/
lemma image_withParity_subset {n : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n) :
    C.image withParity ⊆ words (n + 1) := by
  intro x hx
  obtain ⟨l, hl, rfl⟩ := Finset.mem_image.mp hx
  simp [mem_words.mp (hC hl)]

/-- `A n d ≤ A (n + 1) (d + 1)` for odd `d`. -/
theorem A_le_A_succ_of_odd (n : ℕ) {d : ℕ} (hd : Odd d) : A n d ≤ A (n + 1) (d + 1) := by
  obtain ⟨C, hC, hmin, hcard⟩ := exists_code_card_A n d
  have hcard' : (C.image withParity).card = C.card :=
    Finset.card_image_of_injective _ withParity_injective
  calc A n d = (C.image withParity).card := by rw [hcard', hcard]
    _ ≤ A (n + 1) (d + 1) :=
        card_le_A (image_withParity_subset hC) (minDist_image_withParity hC hmin hd)

/-! ## Puncturing: deleting the last coordinate loses at most one unit of distance -/

/-- Deleting the last coordinate decreases the Hamming distance by at most `1`. -/
lemma hdist_le_hdist_dropLast_succ {x y : List Bool} (hl : x.length = y.length) :
    hdist x y ≤ hdist x.dropLast y.dropLast + 1 := by
  rcases eq_or_ne x [] with rfl | hx
  · simp
  · have hy : y ≠ [] := by
      intro h; subst h; simp at hl; exact hx hl
    have hxs : x.dropLast ++ [x.getLast hx] = x := List.dropLast_append_getLast hx
    have hys : y.dropLast ++ [y.getLast hy] = y := List.dropLast_append_getLast hy
    have hdl : x.dropLast.length = y.dropLast.length := by
      simp [List.length_dropLast, hl]
    have := hdist_append hdl [x.getLast hx] [y.getLast hy]
    rw [hxs, hys] at this
    rw [this]
    have : hdist [x.getLast hx] [y.getLast hy] ≤ 1 := by
      simp only [hdist_cons, hdist_nil_left]
      split <;> omega
    omega

/-- **Puncturing preserves injectivity** when the minimum distance is at least `2`. -/
lemma dropLast_injOn {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words (n + 1))
    (hmin : MinDist C (d + 1)) (hd : 1 ≤ d) :
    Set.InjOn (fun x : List Bool => x.dropLast) (C : Set (List Bool)) := by
  intro x hx y hy hxy
  by_contra hne
  have hxl : x.length = n + 1 := mem_words.mp (hC (by simpa using hx))
  have hyl : y.length = n + 1 := mem_words.mp (hC (by simpa using hy))
  have h1 := hmin x (by simpa using hx) y (by simpa using hy) hne
  have h2 := hdist_le_one_of_dropLast_eq (x := x) (y := y) (by omega) hxy
  omega

/-- **Puncturing lowers the minimum distance by at most one.** -/
theorem minDist_image_dropLast {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words (n + 1))
    (hmin : MinDist C (d + 1)) : MinDist (C.image (fun x => x.dropLast)) d := by
  rintro u hu v hv huv
  obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hu
  obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hv
  have hxl : x.length = n + 1 := mem_words.mp (hC hx)
  have hyl : y.length = n + 1 := mem_words.mp (hC hy)
  have hne : x ≠ y := fun h => huv (by rw [h])
  have h1 := hmin x hx y hy hne
  have h2 := hdist_le_hdist_dropLast_succ (x := x) (y := y) (by omega)
  omega

lemma image_dropLast_subset {n : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words (n + 1)) :
    C.image (fun x => x.dropLast) ⊆ words n := by
  intro z hz
  obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
  have hxl : x.length = n + 1 := mem_words.mp (hC hx)
  simp [List.length_dropLast, hxl]

/-- `A (n + 1) (d + 1) ≤ A n d` for every `d ≥ 1`.  No parity hypothesis is needed here. -/
theorem A_succ_le_A (n : ℕ) {d : ℕ} (hd : 1 ≤ d) : A (n + 1) (d + 1) ≤ A n d := by
  obtain ⟨C, hC, hmin, hcard⟩ := exists_code_card_A (n + 1) (d + 1)
  have hcard' : (C.image (fun x => x.dropLast)).card = C.card :=
    Finset.card_image_of_injOn (dropLast_injOn hC hmin hd)
  calc A (n + 1) (d + 1) = (C.image (fun x => x.dropLast)).card := by rw [hcard', hcard]
    _ ≤ A n d := card_le_A (image_dropLast_subset hC) (minDist_image_dropLast hC hmin)

/-! ## The extension/puncturing theorem -/

/-- **Odd/even collapse of the extremal function.**  For odd `d`, the extremal problems
`(n, d)` and `(n + 1, d + 1)` have the *same* answer: parity extension and puncturing are
mutually inverse at the level of optimal codes.  This is the structural reason why binary
code tables only ever list odd minimum distances. -/
theorem A_succ_succ_of_odd (n : ℕ) {d : ℕ} (hd : Odd d) : A n d = A (n + 1) (d + 1) :=
  le_antisymm (A_le_A_succ_of_odd n hd) (A_succ_le_A n hd.pos)

/-! ## Consequences -/

/-- Distance `1` imposes no condition at all. -/
theorem A_one (n : ℕ) : A n 1 = 2 ^ n := by
  refine le_antisymm (A_le_two_pow n 1) ?_
  have hmin : MinDist (words n) 1 := by
    intro x hx y hy hxy
    rcases Nat.eq_zero_or_pos (hdist x y) with h | h
    · exact absurd (eq_of_hdist_eq_zero (by rw [mem_words.mp hx, mem_words.mp hy]) h) hxy
    · exact h
  calc (2 : ℕ) ^ n = (words n).card := (card_words n).symm
    _ ≤ A n 1 := card_le_A (Finset.Subset.refl _) hmin

/-- **The parity code is optimal, second proof.**  `A (n+1) 2 = 2 ^ n` now follows purely
structurally from `A n 1 = 2 ^ n` and the extension/puncturing theorem. -/
theorem A_two (n : ℕ) : A (n + 1) 2 = 2 ^ n := by
  rw [← A_succ_succ_of_odd n odd_one, A_one]

/-- `A 7 3 = 16`, restated through the extremal function. -/
theorem A_seven_three : A 7 3 = 16 :=
  IsGreatest.unique (A_isGreatest 7 3) A_7_3_isGreatest

/-- **`A 8 4 = 16`.**  The extended Hamming code is optimal at length `8`, distance `4`. -/
theorem A_eight_four : A 8 4 = 16 := by
  rw [← A_succ_succ_of_odd 7 (by decide), A_seven_three]

/-- `A (2 ^ k - 1) 3` is the size of the `k`-th Hamming code. -/
theorem A_hamming (k : ℕ) : A (2 ^ k - 1) 3 = (hammingCode k).card :=
  IsGreatest.unique (A_isGreatest _ 3) (A_hamming_isGreatest k)

/-- **The extended Hamming codes are optimal.**  For every `k`, the largest length-`2 ^ k`
binary code of minimum distance `4` has exactly `|Hamming k|` words. -/
theorem A_extended_hamming (k : ℕ) : A (2 ^ k) 4 = (hammingCode k).card := by
  have hpow : 1 ≤ 2 ^ k := Nat.one_le_two_pow
  have hn : 2 ^ k = (2 ^ k - 1) + 1 := by omega
  rw [hn, ← A_succ_succ_of_odd (2 ^ k - 1) (by decide), A_hamming]

/-! ## Sharpness: the parity hypothesis cannot be dropped -/

/-- Sphere packing at length `4`, distance `3`. -/
theorem A_four_three_le : A 4 3 ≤ 3 := by
  obtain ⟨C, hC, hmin, hcard⟩ := exists_code_card_A 4 3
  have h := hamming_bound (t := 1) hC (by simpa using hmin)
  have hv : (∑ i ∈ Finset.range (1 + 1), (4 : ℕ).choose i) = 5 := by decide
  rw [hv] at h
  omega

/-- **The `Odd d` hypothesis in `A_succ_succ_of_odd` is necessary.**  For the even distance
`d = 2` the extension step fails outright: `A 4 3 < A 3 2`.  Equivalently, no
minimum-distance-`2` code of length `3` and size `4` can be extended to a
minimum-distance-`3` code of length `4`. -/
theorem A_four_three_lt_A_three_two : A 4 3 < A 3 2 := by
  have h1 : A 3 2 = 4 := by simpa using A_two 2
  have h2 := A_four_three_le
  omega

/-- The extremal function is antitone in the distance. -/
theorem A_antitone_dist {n d e : ℕ} (h : d ≤ e) : A n e ≤ A n d := by
  obtain ⟨C, hC, hmin, hcard⟩ := exists_code_card_A n e
  exact hcard ▸ card_le_A hC (fun x hx y hy hxy => le_trans h (hmin x hx y hy hxy))

/-- **Puncturing bound in general form.**  Lengths may be traded for distance one unit at a
time; iterating `A_succ_le_A` gives the Singleton-type decay `A (n + j) (d + j) ≤ A n d`. -/
theorem A_shift_le (n d j : ℕ) (hd : 1 ≤ d) : A (n + j) (d + j) ≤ A n d := by
  induction j with
  | zero => simp
  | succ j ih =>
    have h1 : A (n + (j + 1)) (d + (j + 1)) ≤ A (n + j) (d + j) := by
      have := A_succ_le_A (n + j) (d := d + j) (by omega)
      simpa [Nat.add_assoc] using this
    exact le_trans h1 ih

end ListCode