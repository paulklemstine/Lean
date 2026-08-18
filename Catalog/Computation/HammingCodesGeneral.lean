import Mathlib
import Catalog.Computation.ListHammingBallParity
import Catalog.Computation.BinaryCodeBounds
import Catalog.Computation.HammingCodePerfect

/-!
# General Hamming codes: a perfect binary code exists in length `n` iff `n + 1` is a power of 2

Cycle 4 of the research thread.  Cycle 2 proved the *necessary* arithmetic condition for a
perfect single-error-correcting binary code (`perfect_one_error_correcting_length`:
`n + 1 = 2 ^ k`), and cycle 3 verified the first nontrivial instance by exhibiting the
`[7,4,3]` Hamming code.  Here the condition is shown to be *sufficient for every* `k`, which
closes the characterisation:

`(∃ perfect 1-error-correcting code of length n) ↔ (∃ k, n + 1 = 2 ^ k)`
(`perfect_code_exists_iff_length_succ_pow_two`).

## Construction

Instead of linear algebra over `𝔽₂` we use the classical *syndrome as a natural-number
`xor`*: `synd s z` is the `xor` of the position indices `s, s+1, …` at which `z` is `true`.
The Hamming code of order `k` is the set of words of length `2 ^ k - 1` with vanishing
syndrome (`hammingCode`).  Then

* `synd_xorWord` — the syndrome is a homomorphism for coordinatewise `xor`;
* `synd_ne_zero_of_weight_le_two` — a word of weight `1` or `2` has nonzero syndrome
  (indices are distinct and nonzero), giving `hammingCode_minDist : MinDist (hammingCode k) 3`;
* `synd_lt_two_pow` — syndromes of words of length `2 ^ k - 1` are `< 2 ^ k`, so a nonzero
  syndrome `v` points at the position `v - 1` to flip; flipping it lands in the code
  (`hammingCode_covering`), whence `hammingCode_perfect`.

Note that the size `|C| = 2 ^ (n - k)` is *not* needed as an input: it comes out of the
tiling and the cycle-1 counting lemma (`hammingCode_card`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the obstruction of cycle 2 is exactly tight — perfect codes exist
in every admissible length, and the proof should avoid linear algebra entirely by treating
the syndrome as a `Nat.xor` of indices.

Experiment (Experimenter): the arithmetic route worked.  Two facts carry the whole proof:
`a ^^^ b = 0 ↔ a = b` (so distinct indices never cancel — this is exactly "the columns of
the parity-check matrix are distinct and nonzero"), and `x, y < 2 ^ k → x ^^^ y < 2 ^ k` (so
the syndrome is a legal position).  Decoding is then literally "flip position `synd x - 1`".

Analysis (Analyst): what makes this work for all `k` and not just `k = 3` is that the index
set `{1, …, 2^k - 1}` is precisely the set of nonzero `k`-bit strings; the length
`2 ^ k - 1` is forced by the same fact that forces `(n+1) ∣ 2 ^ n` in cycle 2.  The two
directions of the final characterisation are therefore the *same* arithmetic seen from the
counting side and from the construction side.

Critique (Critic): the degenerate case `k = 0` gives the length-0 code `{[]}`, which is
perfect for trivial reasons; the statement is kept uniform rather than excluding it.  The
covering argument needs `v ≤ 2 ^ k - 1` for the flipped position to exist — this is
`synd_lt_two_pow` and is the only place where the length `2 ^ k - 1` is used.
-/

namespace ListCode

open Finset

/-! ## Syndromes -/

/-- `synd s z` is the `xor` of the indices `s, s+1, …` at which the word `z` is `true`. -/
def synd : ℕ → List Bool → ℕ
  | _, [] => 0
  | s, a :: t => (if a = true then s else 0) ^^^ synd (s + 1) t

@[simp] lemma synd_nil (s : ℕ) : synd s [] = 0 := rfl

@[simp] lemma synd_cons (s : ℕ) (a : Bool) (t : List Bool) :
    synd s (a :: t) = (if a = true then s else 0) ^^^ synd (s + 1) t := rfl

lemma synd_of_weight_zero {z : List Bool} (h : weight z = 0) (s : ℕ) : synd s z = 0 := by
  induction z generalizing s with
  | nil => rfl
  | cons a t ih =>
    rw [weight_cons] at h
    have ha : a = false := by cases a <;> simp_all
    subst ha
    have ht : weight t = 0 := by simpa using h
    simp [ih ht]

/-- **The syndrome is a homomorphism** for coordinatewise `xor`. -/
theorem synd_xorWord {x y : List Bool} (hl : x.length = y.length) (s : ℕ) :
    synd s (xorWord x y) = synd s x ^^^ synd s y := by
  induction x generalizing y s with
  | nil =>
    have : y = [] := List.length_eq_zero_iff.mp hl.symm
    subst this; simp
  | cons a t ih =>
    cases y with
    | nil => simp at hl
    | cons b u =>
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
      rw [xorWord_cons, synd_cons, synd_cons, synd_cons, ih hl]
      cases a <;> cases b <;> simp [Nat.xor_assoc, Nat.xor_left_comm]

/-- A word of weight `1` has syndrome `s + i`, where `i` is the position of its unique
`true`. -/
lemma synd_of_weight_one {z : List Bool} (h : weight z = 1) (s : ℕ) :
    ∃ i < z.length, synd s z = s + i := by
  induction z generalizing s with
  | nil => simp [weight] at h
  | cons a t ih =>
    rw [weight_cons] at h
    cases a with
    | true =>
      refine ⟨0, by simp, ?_⟩
      have ht : weight t = 0 := by simp at h; omega
      simp [synd_of_weight_zero ht]
    | false =>
      have ht : weight t = 1 := by simp at h; omega
      obtain ⟨j, hj, hval⟩ := ih ht (s + 1)
      exact ⟨j + 1, by simpa using hj, by simp [hval]; omega⟩

/-- **Distinct nonzero indices never cancel.**  A word of weight `1` or `2` has nonzero
syndrome — this is the statement that the columns of the parity-check matrix are distinct
and nonzero. -/
theorem synd_ne_zero_of_weight_le_two {z : List Bool} (h1 : 1 ≤ weight z) (h2 : weight z ≤ 2)
    {s : ℕ} (hs : 0 < s) : synd s z ≠ 0 := by
  induction z generalizing s with
  | nil => simp [weight] at h1
  | cons a t ih =>
    rw [weight_cons] at h1 h2
    cases a with
    | false =>
      have h1' : 1 ≤ weight t := by simpa using h1
      have h2' : weight t ≤ 2 := by simpa using h2
      have hne := ih h1' h2' (s := s + 1) (by omega)
      simpa using hne
    | true =>
      have h2' : weight t ≤ 1 := by simp at h2; omega
      rcases Nat.eq_zero_or_pos (weight t) with h0 | hpos
      · have hval : synd s (true :: t) = s := by simp [synd_of_weight_zero h0]
        rw [hval]
        omega
      · have ht : weight t = 1 := by omega
        obtain ⟨j, -, hj⟩ := synd_of_weight_one ht (s + 1)
        have hval : synd s (true :: t) = s ^^^ (s + 1 + j) := by simp [hj]
        rw [hval, Ne, Nat.xor_eq_zero_iff]
        omega

/-- Syndromes stay inside the index range: if all indices used are `< 2 ^ k`, so is the
syndrome. -/
theorem synd_lt_two_pow {z : List Bool} {s k : ℕ} (h : s + z.length ≤ 2 ^ k) :
    synd s z < 2 ^ k := by
  induction z generalizing s with
  | nil => simp
  | cons a t ih =>
    simp only [List.length_cons] at h
    refine Nat.xor_lt_two_pow ?_ (ih (by omega))
    split
    · omega
    · exact Nat.two_pow_pos k

/-! ## Flipping a single coordinate -/

/-- Flip the letter at position `i` (a no-op if `i` is out of range). -/
def flipAt : ℕ → List Bool → List Bool
  | _, [] => []
  | 0, a :: t => (!a) :: t
  | i + 1, a :: t => a :: flipAt i t

@[simp] lemma flipAt_length (i : ℕ) (z : List Bool) : (flipAt i z).length = z.length := by
  induction z generalizing i with
  | nil => cases i <;> rfl
  | cons a t ih => cases i with
    | zero => rfl
    | succ i => simp [flipAt, ih]

/-- Flipping one coordinate moves the word by exactly one unit of Hamming distance. -/
theorem hdist_flipAt {i : ℕ} {z : List Bool} (hi : i < z.length) :
    hdist z (flipAt i z) = 1 := by
  induction z generalizing i with
  | nil => simp at hi
  | cons a t ih =>
    cases i with
    | zero => cases a <;> simp [flipAt]
    | succ i =>
      simp only [List.length_cons] at hi
      have hrec := ih (i := i) (by omega)
      simp [flipAt, hrec]

/-- Flipping the coordinate at position `i` changes the syndrome by `s + i`. -/
theorem synd_flipAt {i : ℕ} {z : List Bool} (hi : i < z.length) (s : ℕ) :
    synd s (flipAt i z) = synd s z ^^^ (s + i) := by
  induction z generalizing i s with
  | nil => simp at hi
  | cons a t ih =>
    cases i with
    | zero =>
      cases a <;> simp [flipAt, Nat.xor_comm]
    | succ i =>
      simp only [List.length_cons] at hi
      have := ih (i := i) (s := s + 1) (by omega)
      rw [flipAt, synd_cons, this, synd_cons]
      have harg : s + 1 + i = s + (i + 1) := by omega
      rw [harg, Nat.xor_assoc]

/-! ## The Hamming code of order `k` -/

/-- The Hamming code of order `k`: the words of length `2 ^ k - 1` with vanishing
syndrome. -/
def hammingCode (k : ℕ) : Finset (List Bool) :=
  (words (2 ^ k - 1)).filter (fun x => synd 1 x = 0)

lemma hammingCode_subset (k : ℕ) : hammingCode k ⊆ words (2 ^ k - 1) :=
  Finset.filter_subset _ _

@[simp] lemma mem_hammingCode {k : ℕ} {x : List Bool} :
    x ∈ hammingCode k ↔ x.length = 2 ^ k - 1 ∧ synd 1 x = 0 := by
  simp [hammingCode]

/-- **Minimum distance 3.**  Two distinct codewords differ in at least three positions,
because their difference has nonzero syndrome unless it has weight at least `3`. -/
theorem hammingCode_minDist (k : ℕ) : MinDist (hammingCode k) 3 := by
  intro x hx y hy hxy
  obtain ⟨hxl, hxs⟩ := mem_hammingCode.mp hx
  obtain ⟨hyl, hys⟩ := mem_hammingCode.mp hy
  by_contra hlt
  push_neg at hlt
  have hle : hdist x y ≤ 2 := by omega
  have hpos : 1 ≤ hdist x y := by
    rcases Nat.eq_zero_or_pos (hdist x y) with h | h
    · exact absurd (eq_of_hdist_eq_zero (by omega) h) hxy
    · exact h
  have hw : weight (xorWord x y) = hdist x y := (hdist_eq_weight_xor (by omega)).symm
  have hs : synd 1 (xorWord x y) = 0 := by
    rw [synd_xorWord (by omega), hxs, hys]; simp
  exact synd_ne_zero_of_weight_le_two (by omega) (by omega) (by norm_num) hs

/-- **Decoding.**  Every word of length `2 ^ k - 1` is within one bit flip of a codeword:
if its syndrome is `v ≠ 0`, flipping position `v - 1` produces a codeword. -/
theorem hammingCode_covering (k : ℕ) {x : List Bool} (hx : x.length = 2 ^ k - 1) :
    ∃ c ∈ hammingCode k, hdist x c ≤ 1 := by
  have hpow : 1 ≤ 2 ^ k := Nat.one_le_two_pow
  rcases Nat.eq_zero_or_pos (synd 1 x) with h0 | hpos
  · exact ⟨x, mem_hammingCode.mpr ⟨hx, h0⟩, by simp⟩
  · have hlt : synd 1 x < 2 ^ k := synd_lt_two_pow (by omega)
    set v := synd 1 x with hv
    have hi : v - 1 < x.length := by omega
    refine ⟨flipAt (v - 1) x, mem_hammingCode.mpr ⟨by simpa using hx, ?_⟩, ?_⟩
    · rw [synd_flipAt hi]
      have : 1 + (v - 1) = v := by omega
      rw [this, ← hv, Nat.xor_self]
    · rw [hdist_flipAt hi]

/-- **The Hamming code is perfect.**  The radius-1 balls around its codewords tile the whole
cube of length `2 ^ k - 1`. -/
theorem hammingCode_perfect (k : ℕ) :
    (hammingCode k).biUnion (fun x => ball (2 ^ k - 1) 1 x) = words (2 ^ k - 1) := by
  apply Finset.Subset.antisymm
  · intro z hz
    obtain ⟨x, -, hzx⟩ := Finset.mem_biUnion.mp hz
    exact ball_subset_words _ 1 x hzx
  · intro z hz
    obtain ⟨c, hc, hd⟩ := hammingCode_covering k (mem_words.mp hz)
    exact Finset.mem_biUnion.mpr ⟨c, hc, mem_ball.mpr ⟨mem_words.mp hz, hd⟩⟩

/-- The size of the Hamming code is forced by perfectness and the counting lemma:
`|C| · 2 ^ k = 2 ^ (2 ^ k - 1)`. -/
theorem hammingCode_card (k : ℕ) :
    (hammingCode k).card * 2 ^ k = 2 ^ (2 ^ k - 1) := by
  classical
  have hpow : 1 ≤ 2 ^ k := Nat.one_le_two_pow
  set n := 2 ^ k - 1 with hn
  have hmin : MinDist (hammingCode k) (2 * 1 + 1) := by simpa using hammingCode_minDist k
  have hcard : ((hammingCode k).biUnion (fun x => ball n 1 x)).card
      = ∑ x ∈ hammingCode k, (ball n 1 x).card :=
    Finset.card_biUnion (balls_pairwiseDisjoint (hammingCode_subset k) hmin)
  have hvol : ∀ x ∈ hammingCode k, (ball n 1 x).card = n + 1 := by
    intro x hx
    rw [ball_card n 1 x (mem_words.mp (hammingCode_subset k hx))]
    simp [Finset.sum_range_succ]
    omega
  rw [Finset.sum_congr rfl hvol, Finset.sum_const, smul_eq_mul, hammingCode_perfect k,
    card_words] at hcard
  have hn1 : n + 1 = 2 ^ k := by omega
  rw [hn1] at hcard
  exact hcard.symm

/-- The Hamming code of order `2` is the length-3 repetition code of cycle 1. -/
theorem hammingCode_two_eq_repetitionCode3 : hammingCode 2 = repetitionCode3 := by decide

/-- **The extremal number `A(2^k - 1, 3)` is attained by the Hamming code.**  For every
Hamming length the sphere-packing bound is exactly the maximal size of a length-`(2^k-1)`
binary code with minimum distance `3`.  (For `k = 3` this is `A(7,3) = 16`.) -/
theorem A_hamming_isGreatest (k : ℕ) :
    IsGreatest {m : ℕ | ∃ C : Finset (List Bool),
        C ⊆ words (2 ^ k - 1) ∧ MinDist C 3 ∧ C.card = m} (hammingCode k).card := by
  have hpow : 1 ≤ 2 ^ k := Nat.one_le_two_pow
  constructor
  · exact ⟨hammingCode k, hammingCode_subset k, hammingCode_minDist k, rfl⟩
  · rintro m ⟨C, hC, hmin, rfl⟩
    have h := hamming_bound (t := 1) hC (by simpa using hmin)
    have hv : (∑ i ∈ Finset.range (1 + 1), (2 ^ k - 1).choose i) = 2 ^ k := by
      simp [Finset.sum_range_succ]
      omega
    rw [hv] at h
    have hH := hammingCode_card k
    have : C.card * 2 ^ k ≤ (hammingCode k).card * 2 ^ k := by omega
    exact Nat.le_of_mul_le_mul_right this (by omega)

/-- **Strict sphere packing at non-Hamming lengths.**  If `n + 1` is not a power of two,
the sphere-packing inequality for distance-3 codes is *strict*: equality would force a
tiling, which cycle 2 rules out arithmetically. -/
theorem hamming_bound_strict {n : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C 3) (hn : ¬ ∃ k, n + 1 = 2 ^ k) :
    C.card * (n + 1) < 2 ^ n := by
  have hmin' : MinDist C (2 * 1 + 1) := by simpa using hmin
  have hv : (∑ i ∈ Finset.range (1 + 1), n.choose i) = n + 1 := by
    simp [Finset.sum_range_succ]
    omega
  have hle : C.card * (n + 1) ≤ 2 ^ n := by
    have := hamming_bound (t := 1) hC hmin'
    rwa [hv] at this
  rcases lt_or_eq_of_le hle with h | h
  · exact h
  · exact absurd (perfect_one_error_correcting_length hC hmin
      (balls_tile_of_card_eq hC hmin' (by rw [hv]; exact h))) hn

/-! ## The characterisation -/

/-- **Existence of perfect single-error-correcting binary codes.**  There is a code of
length `n` with minimum distance `3` whose radius-1 balls tile the cube if and only if
`n + 1` is a power of two.  The forward direction is the arithmetic obstruction of cycle 2;
the backward direction is the Hamming code construction. -/
theorem perfect_code_exists_iff_length_succ_pow_two (n : ℕ) :
    (∃ C : Finset (List Bool), C ⊆ words n ∧ MinDist C 3 ∧
        C.biUnion (fun x => ball n 1 x) = words n) ↔ ∃ k, n + 1 = 2 ^ k := by
  constructor
  · rintro ⟨C, hC, hmin, hcov⟩
    exact perfect_one_error_correcting_length hC hmin hcov
  · rintro ⟨k, hk⟩
    have hn : n = 2 ^ k - 1 := by omega
    subst hn
    exact ⟨hammingCode k, hammingCode_subset k, hammingCode_minDist k, hammingCode_perfect k⟩

/-- Nearest-neighbour decoding is unambiguous for a perfect code: every received word has a
*unique* codeword within distance `1`. -/
theorem hammingCode_unique_decoding (k : ℕ) {x : List Bool} (hx : x.length = 2 ^ k - 1) :
    ∃! c, c ∈ hammingCode k ∧ hdist x c ≤ 1 := by
  obtain ⟨c, hc, hd⟩ := hammingCode_covering k hx
  refine ⟨c, ⟨hc, hd⟩, ?_⟩
  rintro c' ⟨hc', hd'⟩
  by_contra hne
  have hcl : c.length = 2 ^ k - 1 := mem_words.mp (hammingCode_subset k hc)
  have hc'l : c'.length = 2 ^ k - 1 := mem_words.mp (hammingCode_subset k hc')
  have htri : hdist c' c ≤ hdist c' x + hdist x c := hdist_triangle (by omega) (by omega)
  have hsym : hdist c' x = hdist x c' := hdist_comm c' x
  have := hammingCode_minDist k c' hc' c hc hne
  omega

end ListCode