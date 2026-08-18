import Mathlib
import Catalog.Computation.ListHammingBallParity

/-!
# Linear structure, the Singleton and Gilbert–Varshamov bounds, and perfect codes

Cycle 2 of the research thread.  Cycle 1 (`Catalog.Computation.ListHammingBallParity`)
established the Hamming ball counting lemma over `List Bool` together with the
sphere-packing bound and the optimality of the parity-extension code.  This file pushes the
theory in three directions that were listed there as open:

* **Algebraic**: the coordinatewise `xor` makes `List Bool` a metric group.  Weight,
  translation invariance, and the theorem that for a *linear* code minimum distance equals
  minimum nonzero weight (`linear_minDist_iff_minWeight`).  The parity code is exactly the
  even-weight code (`parityCode_eq_even_weight`) and is linear (`parityCode_xor_closed`).
* **Combinatorial**: the Singleton bound `|C| ≤ 2 ^ (n + 1 - d)` (`singleton_bound`),
  proved by puncturing, and the Gilbert–Varshamov existence bound
  (`gilbert_varshamov`), proved by a greedy/maximality argument — the exact converse
  direction to sphere packing.
* **Number-theoretic**: a *perfect* single-error-correcting binary code of length `n` forces
  `n + 1` to be a power of two (`perfect_one_error_correcting_length`); hence there is no
  perfect code of length `4` (`no_perfect_code_length_four`).  This is where the
  combinatorics of `ball_card` meets `Nat.dvd_prime_pow`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (i) the parity code is not just optimal but *linear*, and
linearity should reduce the quadratic minimum-distance condition to a linear
minimum-weight condition; (ii) puncturing gives Singleton, greedy maximality gives
Gilbert–Varshamov, so the counting lemma of cycle 1 controls codes from both sides;
(iii) perfectness is an arithmetic constraint, not merely a combinatorial one.

Experiment (Experimenter): all three were formalised.  (i) needed `hdist_eq_weight_xor`
(the metric is the weight of the difference) plus `xorWord_eq_zero_iff`.  (ii) Singleton
needed the split `x = x.take k ++ x.drop k` and `hdist_append`; note that with truncated
`ℕ` subtraction the statement `|C| ≤ 2 ^ (n + 1 - d)` is *uniformly* correct, including the
degenerate regime `d > n + 1` where it reads `|C| ≤ 1`.  (iii) the divisibility
`(n+1) ∣ 2^n` drops out of the tiling identity and `Nat.dvd_prime_pow` finishes.

Analysis (Analyst): the two bounds bracket the optimal size `A(n,d)`:
`2^n / V(n,d-1) ≤ A(n,d) ≤ 2 ^ (n+1-d)`, and both proofs consume exactly one ingredient
from cycle 1 (`ball_card` for the lower bound, `hdist_append` for the upper one).  The
failure mode we had to avoid twice is `zipWith` truncation: every metric statement is
guarded by an equal-length hypothesis, and `hdist_triangle` is genuinely false without it.

Critique (Critic): `gilbert_varshamov` is an existence statement — we checked it is not
vacuous by noting the extracted code satisfies `MinDist C d` and lives inside `words n`;
for `d = 1` it returns a code of size `2^n`.  `linear_minDist_iff_minWeight` assumes the
zero word is in the code; without it the backward direction fails (a coset of a linear code
has the same distances but no zero word, and the weight condition then says nothing).
-/

namespace ListCode

open Finset

/-! ## The metric group structure: `xor`, weight, translation invariance -/

/-- Coordinatewise `xor` of two words: the group operation of the Hamming cube. -/
def xorWord (l m : List Bool) : List Bool := List.zipWith xor l m

@[simp] lemma xorWord_nil_left (m : List Bool) : xorWord [] m = [] := rfl

@[simp] lemma xorWord_nil_right (l : List Bool) : xorWord l [] = [] := by cases l <;> rfl

@[simp] lemma xorWord_cons (a b : Bool) (l m : List Bool) :
    xorWord (a :: l) (b :: m) = (xor a b) :: xorWord l m := rfl

@[simp] lemma xorWord_length (l m : List Bool) :
    (xorWord l m).length = min l.length m.length := by
  simp [xorWord]

/-- The Hamming weight: the number of `true` letters. -/
def weight (l : List Bool) : ℕ := l.count true

@[simp] lemma weight_nil : weight [] = 0 := rfl

@[simp] lemma weight_cons (a : Bool) (l : List Bool) :
    weight (a :: l) = (if a = true then 1 else 0) + weight l := by
  cases a <;> simp [weight, Nat.add_comm]

/-- The all-zero word of length `n`. -/
def zeroWord (n : ℕ) : List Bool := List.replicate n false

@[simp] lemma zeroWord_length (n : ℕ) : (zeroWord n).length = n := by simp [zeroWord]

lemma zeroWord_succ (n : ℕ) : zeroWord (n + 1) = false :: zeroWord n := by
  simp [zeroWord, List.replicate_succ]

@[simp] lemma weight_zeroWord (n : ℕ) : weight (zeroWord n) = 0 := by
  induction n with
  | zero => simp [zeroWord]
  | succ n ih => rw [zeroWord_succ, weight_cons, ih]; simp

/-- **The metric is the weight of the difference.** -/
theorem hdist_eq_weight_xor {l m : List Bool} (hl : l.length = m.length) :
    hdist l m = weight (xorWord l m) := by
  induction l generalizing m with
  | nil => simp
  | cons a t ih =>
    cases m with
    | nil => simp at hl
    | cons b s =>
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
      rw [hdist_cons, xorWord_cons, weight_cons, ih hl]
      cases a <;> cases b <;> simp

/-- Distance to the zero word is the weight. -/
theorem hdist_zeroWord {n : ℕ} {l : List Bool} (hl : l.length = n) :
    hdist l (zeroWord n) = weight l := by
  induction l generalizing n with
  | nil => subst hl; simp [zeroWord]
  | cons a t ih =>
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨t.length, by simpa using hl.symm⟩
    rw [zeroWord_succ, hdist_cons, weight_cons, ih (by simpa using hl)]
    cases a <;> simp

/-- The difference of two equal-length words vanishes exactly when they are equal. -/
theorem xorWord_eq_zero_iff {n : ℕ} {l m : List Bool} (hl : l.length = n)
    (hm : m.length = n) : xorWord l m = zeroWord n ↔ l = m := by
  constructor
  · intro h
    refine eq_of_hdist_eq_zero (by omega) ?_
    rw [hdist_eq_weight_xor (by omega), h, weight_zeroWord]
  · rintro rfl
    subst hl
    induction l with
    | nil => simp [zeroWord]
    | cons a t ih => simp [zeroWord, List.replicate_succ, ih]

/-- **Translation invariance.**  Adding a fixed word to both arguments preserves the
Hamming distance: `(List Bool, xor, hdist)` is a metric group. -/
theorem hdist_xorWord_right {n : ℕ} {x y z : List Bool} (hx : x.length = n)
    (hy : y.length = n) (hz : z.length = n) :
    hdist (xorWord x z) (xorWord y z) = hdist x y := by
  induction x generalizing y z n with
  | nil =>
    have : y = [] := by
      cases y with
      | nil => rfl
      | cons b s =>
        rw [List.length_nil] at hx
        rw [List.length_cons] at hy
        omega
    simp [this]
  | cons a t ih =>
    cases y with
    | nil =>
      rw [List.length_cons] at hx
      rw [List.length_nil] at hy
      omega
    | cons b s =>
      cases z with
      | nil =>
        rw [List.length_cons] at hx
        rw [List.length_nil] at hz
        omega
      | cons c u =>
        obtain ⟨n', rfl⟩ : ∃ n', n = n' + 1 := ⟨t.length, by simpa using hx.symm⟩
        simp only [List.length_cons, Nat.add_right_cancel_iff] at hx hy hz
        rw [xorWord_cons, xorWord_cons, hdist_cons, hdist_cons, ih hx hy hz]
        cases a <;> cases b <;> cases c <;> simp

/-- Parity is a group homomorphism from the Hamming cube to `Bool`. -/
theorem parity_xorWord {l m : List Bool} (hl : l.length = m.length) :
    parity (xorWord l m) = xor (parity l) (parity m) := by
  induction l generalizing m with
  | nil =>
    have : m = [] := List.length_eq_zero_iff.mp hl.symm
    simp [this]
  | cons a t ih =>
    cases m with
    | nil => simp at hl
    | cons b s =>
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
      rw [xorWord_cons, parity_cons, parity_cons, parity_cons, ih hl]
      cases a <;> cases b <;> cases parity t <;> cases parity s <;> simp

/-! ## Linear codes: minimum distance is minimum nonzero weight -/

/-- **Minimum distance = minimum nonzero weight, for linear codes.**  For a code containing
the zero word and closed under coordinatewise `xor`, the quadratic condition "all pairwise
distances are at least `d`" is equivalent to the linear condition "all nonzero codewords
have weight at least `d`". -/
theorem linear_minDist_iff_minWeight {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hz : zeroWord n ∈ C) (hxor : ∀ x ∈ C, ∀ y ∈ C, xorWord x y ∈ C) :
    MinDist C d ↔ ∀ x ∈ C, x ≠ zeroWord n → d ≤ weight x := by
  constructor
  · intro hmin x hx hne
    have hxl : x.length = n := mem_words.mp (hC hx)
    rw [← hdist_zeroWord hxl]
    exact hmin x hx (zeroWord n) hz hne
  · intro hw x hx y hy hxy
    have hxl : x.length = n := mem_words.mp (hC hx)
    have hyl : y.length = n := mem_words.mp (hC hy)
    have hne : xorWord x y ≠ zeroWord n := fun h => hxy ((xorWord_eq_zero_iff hxl hyl).mp h)
    have := hw _ (hxor x hx y hy) hne
    rwa [← hdist_eq_weight_xor (by omega)] at this

/-! ## The parity code is the even-weight code, and it is linear -/

/-- **Structure of the parity code.**  It is exactly the set of length-`n+1` words of even
weight (parity `false`). -/
theorem parityCode_eq_even_weight (n : ℕ) :
    parityCode n = (words (n + 1)).filter (fun x => parity x = false) := by
  ext x
  simp only [parityCode, Finset.mem_image, Finset.mem_filter, mem_words]
  constructor
  · rintro ⟨l, hl, rfl⟩
    exact ⟨by simp [hl], parity_withParity l⟩
  · rintro ⟨hxl, hpar⟩
    have hne : x ≠ [] := by intro h; rw [h] at hxl; simp at hxl
    refine ⟨x.dropLast, ?_, ?_⟩
    · simp [hxl]
    · have hsplit : x.dropLast ++ [x.getLast hne] = x := List.dropLast_append_getLast hne
      have hpar' : xor (parity x.dropLast) (x.getLast hne) = false := by
        rw [← parity_append_singleton, hsplit]; exact hpar
      have : x.getLast hne = parity x.dropLast := by
        cases hg : x.getLast hne <;> cases hd : parity x.dropLast <;> simp_all
      rw [withParity, ← this, hsplit]

/-- The parity code contains the zero word. -/
theorem zeroWord_mem_parityCode (n : ℕ) : zeroWord (n + 1) ∈ parityCode n := by
  rw [parityCode_eq_even_weight]
  refine Finset.mem_filter.mpr ⟨by simp [mem_words], ?_⟩
  induction n with
  | zero => simp [zeroWord]
  | succ n ih =>
    rw [zeroWord, List.replicate_succ, parity_cons]
    simpa [zeroWord] using ih

/-- **The parity code is linear**: it is closed under coordinatewise `xor`. -/
theorem parityCode_xor_closed (n : ℕ) :
    ∀ x ∈ parityCode n, ∀ y ∈ parityCode n, xorWord x y ∈ parityCode n := by
  intro x hx y hy
  rw [parityCode_eq_even_weight] at hx hy ⊢
  obtain ⟨hxl, hxp⟩ := Finset.mem_filter.mp hx
  obtain ⟨hyl, hyp⟩ := Finset.mem_filter.mp hy
  rw [mem_words] at hxl hyl
  refine Finset.mem_filter.mpr ⟨mem_words.mpr (by simp [hxl, hyl]), ?_⟩
  rw [parity_xorWord (by omega), hxp, hyp]
  simp

/-- Consequently the parity code's minimum distance `2` is witnessed by weights: every
nonzero codeword has weight at least `2`. -/
theorem parityCode_minWeight (n : ℕ) :
    ∀ x ∈ parityCode n, x ≠ zeroWord (n + 1) → 2 ≤ weight x :=
  (linear_minDist_iff_minWeight (parityCode_subset n) (zeroWord_mem_parityCode n)
    (parityCode_xor_closed n)).mp (parityCode_minDist n)

/-! ## The Singleton bound -/

/-- Two equal-length words agreeing on their first `k` letters are at distance at most
`n - k`. -/
lemma hdist_le_of_take_eq {n k : ℕ} {x y : List Bool} (hx : x.length = n)
    (h : x.take k = y.take k) : hdist x y ≤ n - k := by
  have hsx : x = x.take k ++ x.drop k := (List.take_append_drop k x).symm
  have hsy : y = y.take k ++ y.drop k := (List.take_append_drop k y).symm
  have hlen : (x.take k).length = (y.take k).length := by rw [h]
  calc hdist x y = hdist (x.take k ++ x.drop k) (y.take k ++ y.drop k) := by rw [← hsx, ← hsy]
    _ = hdist (x.take k) (y.take k) + hdist (x.drop k) (y.drop k) := hdist_append hlen _ _
    _ ≤ 0 + (x.drop k).length := by
        rw [h, hdist_self]
        exact Nat.add_le_add_left (hdist_le_length _ _) 0
    _ = n - k := by simp [hx]

/-- **Singleton bound.**  A binary code of length `n` and minimum distance `d ≥ 1` has at
most `2 ^ (n + 1 - d)` words.  (With truncated subtraction the statement is also correct in
the degenerate regime `d > n + 1`, where it says `|C| ≤ 1`.) -/
theorem singleton_bound {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C d) (hd : 1 ≤ d) : C.card ≤ 2 ^ (n + 1 - d) := by
  classical
  set k := n + 1 - d with hk
  have hinj : Set.InjOn (fun x : List Bool => x.take k) (C : Set (List Bool)) := by
    intro x hx y hy hxy
    by_contra hne
    have hxl : x.length = n := mem_words.mp (hC (by simpa using hx))
    have hyl : y.length = n := mem_words.mp (hC (by simpa using hy))
    have h1 := hmin x (by simpa using hx) y (by simpa using hy) hne
    have h2 := hdist_le_of_take_eq hxl hxy
    omega
  have himg : C.image (fun x => x.take k) ⊆ words k := by
    intro z hz
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
    have hxl : x.length = n := mem_words.mp (hC hx)
    rw [mem_words, List.length_take, hxl]
    omega
  calc C.card = (C.image (fun x => x.take k)).card := (Finset.card_image_of_injOn hinj).symm
    _ ≤ (words k).card := Finset.card_le_card himg
    _ = 2 ^ k := card_words k

/-! ## The Gilbert–Varshamov bound -/

/-- **Gilbert–Varshamov.**  For every length `n` and every `d ≥ 1` there exists a code of
length `n` and minimum distance `d` with `2 ^ n ≤ |C| · ∑_{i < d} C(n,i)`; equivalently
`|C| ≥ 2 ^ n / V(n, d-1)`.  Proved by greedy maximality: a code that cannot be extended has
its radius-`(d-1)` balls covering the whole cube. -/
theorem gilbert_varshamov (n d : ℕ) (hd : 1 ≤ d) :
    ∃ C : Finset (List Bool), C ⊆ words n ∧ MinDist C d ∧
      2 ^ n ≤ C.card * ∑ i ∈ Finset.range d, n.choose i := by
  classical
  set S : Finset (Finset (List Bool)) :=
    (words n).powerset.filter (fun C => MinDist C d) with hS
  have hemp : (∅ : Finset (List Bool)) ∈ S := by
    refine Finset.mem_filter.mpr ⟨Finset.empty_mem_powerset _, ?_⟩
    intro x hx; simp at hx
  obtain ⟨C, hCS, hCmax⟩ := S.exists_max_image (fun C => C.card) ⟨∅, hemp⟩
  obtain ⟨hCsub, hCmin⟩ := Finset.mem_filter.mp hCS
  rw [Finset.mem_powerset] at hCsub
  -- maximality forces the radius-`(d-1)` balls to cover the cube
  have hcover : words n ⊆ C.biUnion (fun x => ball n (d - 1) x) := by
    intro z hz
    by_contra hzn
    have hfar : ∀ x ∈ C, d ≤ hdist z x := by
      intro x hx
      by_contra hlt
      exact hzn (Finset.mem_biUnion.mpr ⟨x, hx, mem_ball.mpr ⟨mem_words.mp hz, by omega⟩⟩)
    have hzC : z ∉ C := by
      intro hzc
      have := hfar z hzc
      simp at this
      omega
    have hins : insert z C ∈ S := by
      refine Finset.mem_filter.mpr ⟨Finset.mem_powerset.mpr (Finset.insert_subset hz hCsub), ?_⟩
      intro x hx y hy hxy
      rcases Finset.mem_insert.mp hx with rfl | hx' <;>
        rcases Finset.mem_insert.mp hy with rfl | hy'
      · exact absurd rfl hxy
      · exact hfar y hy'
      · rw [hdist_comm]; exact hfar x hx'
      · exact hCmin x hx' y hy' hxy
    have hcard := hCmax _ hins
    rw [Finset.card_insert_of_notMem hzC] at hcard
    omega
  have hle : (words n).card ≤ (C.biUnion (fun x => ball n (d - 1) x)).card :=
    Finset.card_le_card hcover
  have hsum : (C.biUnion (fun x => ball n (d - 1) x)).card
      ≤ ∑ x ∈ C, (ball n (d - 1) x).card := Finset.card_biUnion_le
  have hvol : ∀ x ∈ C, (ball n (d - 1) x).card = ∑ i ∈ Finset.range d, n.choose i := by
    intro x hx
    have := ball_card n (d - 1) x (mem_words.mp (hCsub hx))
    rwa [Nat.sub_add_cancel hd] at this
  rw [Finset.sum_congr rfl hvol, Finset.sum_const, smul_eq_mul] at hsum
  refine ⟨C, hCsub, hCmin, ?_⟩
  rw [← card_words n]
  omega

/-! ## Perfect codes: an arithmetic obstruction -/

/-- **A perfect single-error-correcting binary code forces `n + 1` to be a power of two.**
If the radius-1 balls around the codewords of a distance-3 code tile the cube, then
`|C| · (n + 1) = 2 ^ n`, so `n + 1` divides `2 ^ n` and is therefore a power of `2`.  This
is the classical necessary condition satisfied by the Hamming codes `n = 2^k - 1`. -/
theorem perfect_one_error_correcting_length {n : ℕ} {C : Finset (List Bool)}
    (hC : C ⊆ words n) (hmin : MinDist C 3)
    (hcov : C.biUnion (fun x => ball n 1 x) = words n) :
    ∃ k, n + 1 = 2 ^ k := by
  classical
  have hmin' : MinDist C (2 * 1 + 1) := by simpa using hmin
  have hdisj := balls_pairwiseDisjoint hC hmin'
  have hcard : (C.biUnion (fun x => ball n 1 x)).card = ∑ x ∈ C, (ball n 1 x).card :=
    Finset.card_biUnion hdisj
  have hvol : ∀ x ∈ C, (ball n 1 x).card = n + 1 := by
    intro x hx
    rw [ball_card n 1 x (mem_words.mp (hC hx))]
    simp [Finset.sum_range_succ]
    omega
  rw [Finset.sum_congr rfl hvol, Finset.sum_const, smul_eq_mul, hcov, card_words] at hcard
  have hdvd : (n + 1) ∣ 2 ^ n := ⟨C.card, by rw [hcard]; ring⟩
  obtain ⟨k, -, hk⟩ := (Nat.dvd_prime_pow Nat.prime_two).mp hdvd
  exact ⟨k, hk⟩

/-- **No perfect single-error-correcting binary code of length 4.**  `5` is not a power of
two, so the tiling required by perfectness is arithmetically impossible. -/
theorem no_perfect_code_length_four :
    ¬ ∃ C : Finset (List Bool), C ⊆ words 4 ∧ MinDist C 3 ∧
        C.biUnion (fun x => ball 4 1 x) = words 4 := by
  rintro ⟨C, hC, hmin, hcov⟩
  obtain ⟨k, hk⟩ := perfect_one_error_correcting_length hC hmin hcov
  have hkle : k ≤ 2 := by
    by_contra hlt
    have : 2 ^ 3 ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) (by omega)
    omega
  interval_cases k <;> omega

end ListCode