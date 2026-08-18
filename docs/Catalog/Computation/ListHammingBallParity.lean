import Mathlib

/-!
# Hamming balls over `List Bool`, the sphere-packing bound, and the parity-extension code

This file closes the gap identified in the previous research cycle: the `d = 1` detection
statement for the parity-extension code was available, but the *general* combinatorial
input — an exact count of Hamming balls over `List Bool` of bounded length — was missing.
Here we build the whole chain from scratch, over lists (not over `Fin n → Bool`), and then
harvest the coding-theoretic consequences.

## Main results

* `hdist` — the Hamming distance on `List Bool` (`zipWith`-based), with
  `hdist_self`, `hdist_comm`, `eq_of_hdist_eq_zero`, `hdist_triangle`.
* `words n` — the finite set of all binary words of length `n`, `card_words : 2 ^ n`.
* `ball_card` — **the missing counting lemma**: for any centre `c` of length `n`,
  `|B_r(c)| = ∑_{i ≤ r} C(n, i)`.  In particular the volume does not depend on the centre.
* `hamming_bound` — sphere packing: a code `C ⊆ words n` of minimum distance `2t+1`
  satisfies `|C| · ∑_{i ≤ t} C(n,i) ≤ 2 ^ n`.
* `parity_iff_even_hdist` — the parity bit is the mod-2 reduction of Hamming distance:
  two words of equal length have equal parity iff their Hamming distance is even.
* `withParity_min_dist` — the parity-extension code has minimum distance exactly `2`
  (`withParity_min_dist` and `withParity_dist_two_exists`).
* `withParity_detects_single_flip` — a single bit flip of a codeword is never a codeword.
* `distance_two_code_card_le` / `parityCode_optimal` — every single-error-detecting code of
  length `n+1` has at most `2 ^ n` words, and the parity code attains this bound.
* `withParity_not_single_error_correcting` — the parity code cannot *correct* a single
  error: there is a received word equidistant (distance `1`) from two codewords.
* `repetitionCode3_perfect` — the length-3 repetition code meets the sphere-packing bound
  with equality, so the bound of `hamming_bound` is sharp.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): over `List Bool` the ball volume should again be the partial
binomial sum `∑_{i ≤ r} C(n,i)`, and it should be provable by a *purely recursive* argument
(peel off the leading letter) rather than by transporting the `Fin n → Bool` count along a
bijection.

Experiment (Experimenter): the recursion `B_{r+1}(b :: c) = b·B_{r+1}(c) ⊔ (!b)·B_r(c)` is
exactly Pascal's rule; formalised as `ball_cons_succ` (and `ball_cons_zero` for `r = 0`),
it gives `ball_card` by a double induction, with the arithmetic step isolated as
`pascal_partial_sum`.

Analysis (Analyst): with the count in hand, both classical bounds follow from *metric*
facts only: sphere packing needs the triangle inequality (`hdist_triangle`, valid only for
equal-length words — truncation of `zipWith` breaks it otherwise), and the distance-2 bound
needs only that puncturing the last coordinate is injective on such codes.  The parity code
then sits exactly at the optimum, while `withParity_not_single_error_correcting` shows the
optimum is achieved by *detection* and cannot be upgraded to correction.

Critique (Critic): the truncating behaviour of `zipWith` is a genuine corner case — all
metric statements carry explicit length hypotheses, and `hdist_triangle` is false without
them (take `k = []`).  The counting lemma itself needs no length hypothesis beyond
`c.length = n`, and every result below is checked against the degenerate `r > n` regime,
where `C(n,i) = 0` makes the formula collapse to `2 ^ n` as it must.
-/

namespace ListCode

open Finset

/-! ## The Hamming metric on `List Bool` -/

/-- Hamming distance between two binary words: the number of positions (within the common
prefix length) at which they differ. -/
def hdist (l m : List Bool) : ℕ :=
  (l.zipWith (fun a b => if a = b then 0 else 1) m).sum

@[simp] lemma hdist_nil_left (m : List Bool) : hdist [] m = 0 := rfl

@[simp] lemma hdist_nil_right (l : List Bool) : hdist l [] = 0 := by cases l <;> rfl

@[simp] lemma hdist_cons (a b : Bool) (l m : List Bool) :
    hdist (a :: l) (b :: m) = (if a = b then 0 else 1) + hdist l m := rfl

@[simp] lemma hdist_self (l : List Bool) : hdist l l = 0 := by
  induction l with
  | nil => rfl
  | cons a l ih => simp [ih]

lemma hdist_comm (l m : List Bool) : hdist l m = hdist m l := by
  induction l generalizing m with
  | nil => simp
  | cons a l ih =>
    cases m with
    | nil => simp
    | cons b m => simp only [hdist_cons, ih]; grind

/-- Two words of the same length at Hamming distance `0` are equal. -/
lemma eq_of_hdist_eq_zero {l m : List Bool} (hl : l.length = m.length)
    (h : hdist l m = 0) : l = m := by
  induction l generalizing m with
  | nil => cases m <;> simp_all
  | cons a l ih =>
    cases m with
    | nil => simp at hl
    | cons b m =>
      simp only [hdist_cons, Nat.add_eq_zero_iff] at h
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
      have hab : a = b := by by_contra hne; simp [hne] at h
      exact hab ▸ (ih hl h.2) ▸ rfl

/-- **Triangle inequality**, for words of a common length.  (The length hypotheses cannot be
dropped: `zipWith` truncates, so e.g. `k = []` would make the right-hand side `0`.) -/
lemma hdist_triangle {l m k : List Bool} (h1 : l.length = k.length)
    (h2 : k.length = m.length) : hdist l m ≤ hdist l k + hdist k m := by
  induction l generalizing m k with
  | nil => simp
  | cons a l ih =>
    cases k with
    | nil => simp at h1
    | cons c k =>
      cases m with
      | nil => simp at h2
      | cons b m =>
        simp only [List.length_cons, Nat.add_right_cancel_iff] at h1 h2
        have key := ih (m := m) (k := k) h1 h2
        have hstep : (if a = b then (0 : ℕ) else 1)
            ≤ (if a = c then 0 else 1) + (if c = b then 0 else 1) := by grind
        simp only [hdist_cons]
        omega

/-- Distances add over concatenation of equal-length blocks. -/
lemma hdist_append {l m : List Bool} (hl : l.length = m.length) (p q : List Bool) :
    hdist (l ++ p) (m ++ q) = hdist l m + hdist p q := by
  induction l generalizing m with
  | nil =>
    cases m with
    | nil => simp
    | cons b m => simp at hl
  | cons a l ih =>
    cases m with
    | nil => simp at hl
    | cons b m =>
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
      simp only [List.cons_append, hdist_cons, ih hl]
      omega

/-- The Hamming distance is bounded by the (common) length. -/
lemma hdist_le_length (l m : List Bool) : hdist l m ≤ l.length := by
  induction l generalizing m with
  | nil => simp
  | cons a l ih =>
    cases m with
    | nil => simp
    | cons b m =>
      have := ih (m := m)
      simp only [hdist_cons, List.length_cons]
      split <;> omega

/-! ## The space of binary words of a fixed length -/

/-- All binary words of length `n`. -/
def words : ℕ → Finset (List Bool)
  | 0 => {[]}
  | n + 1 => (Finset.univ : Finset Bool).biUnion (fun b => (words n).image (b :: ·))

@[simp] lemma mem_words {n : ℕ} {l : List Bool} : l ∈ words n ↔ l.length = n := by
  induction n generalizing l with
  | zero => simp [words, List.length_eq_zero_iff]
  | succ n ih =>
    cases l with
    | nil => simp [words]
    | cons a l => cases a <;> simp [words, ih]

/-- There are `2 ^ n` binary words of length `n`. -/
theorem card_words (n : ℕ) : (words n).card = 2 ^ n := by
  have hinj : ∀ b : Bool, Function.Injective (fun l : List Bool => b :: l) :=
    fun b x y h => by simpa using h
  induction n with
  | zero => simp [words]
  | succ n ih =>
    rw [words, Finset.card_biUnion]
    · simp [Finset.card_image_of_injective _ (hinj _), ih, Finset.sum_const]
      ring
    · intro x _ y _ hxy
      simp only [Finset.disjoint_left, Finset.mem_image]
      rintro l ⟨a, _, rfl⟩ ⟨b, _, hb⟩
      exact hxy ((by simpa using hb.symm : x = y ∧ a = b)).1

/-! ## Hamming balls and the counting lemma -/

/-- The Hamming ball of radius `r` about `c` inside the words of length `n`. -/
def ball (n r : ℕ) (c : List Bool) : Finset (List Bool) :=
  (words n).filter (fun x => hdist x c ≤ r)

@[simp] lemma mem_ball {n r : ℕ} {c x : List Bool} :
    x ∈ ball n r c ↔ x.length = n ∧ hdist x c ≤ r := by
  simp [ball]

lemma ball_subset_words (n r : ℕ) (c : List Bool) : ball n r c ⊆ words n :=
  Finset.filter_subset _ _

/-- Peeling the leading letter, radius `0`. -/
lemma ball_cons_zero (n : ℕ) (b : Bool) (c : List Bool) :
    ball (n + 1) 0 (b :: c) = (ball n 0 c).image (b :: ·) := by
  ext x
  cases x with
  | nil => simp
  | cons a t =>
    simp only [mem_ball, List.length_cons, hdist_cons, Nat.add_right_cancel_iff,
      Finset.mem_image, Nat.le_zero, Nat.add_eq_zero_iff]
    constructor
    · rintro ⟨hl, hd1, hd2⟩
      have hab : a = b := by by_contra hne; simp [hne] at hd1
      subst hab
      exact ⟨t, ⟨hl, hd2⟩, rfl⟩
    · rintro ⟨s, ⟨hs1, hs2⟩, hcons⟩
      obtain ⟨rfl, rfl⟩ := List.cons_eq_cons.mp hcons.symm
      exact ⟨hs1, by simp, hs2⟩

/-- **Pascal's rule for Hamming balls.**  Peeling the leading letter splits a ball of radius
`r+1` into a ball of radius `r+1` (leading letter kept) and a ball of radius `r` (leading
letter flipped). -/
lemma ball_cons_succ (n r : ℕ) (b : Bool) (c : List Bool) :
    ball (n + 1) (r + 1) (b :: c)
      = (ball n (r + 1) c).image (b :: ·) ∪ (ball n r c).image ((!b) :: ·) := by
  ext x
  cases x with
  | nil => simp
  | cons a t =>
    simp only [mem_ball, List.length_cons, hdist_cons, Nat.add_right_cancel_iff,
      Finset.mem_union, Finset.mem_image]
    constructor
    · rintro ⟨hl, hd⟩
      by_cases hab : a = b
      · subst hab
        exact Or.inl ⟨t, ⟨hl, by simp at hd; omega⟩, rfl⟩
      · have hba : a = !b := by cases a <;> cases b <;> simp_all
        subst hba
        refine Or.inr ⟨t, ⟨hl, ?_⟩, rfl⟩
        rw [if_neg hab] at hd
        omega
    · rintro (⟨s, ⟨hs1, hs2⟩, hcons⟩ | ⟨s, ⟨hs1, hs2⟩, hcons⟩) <;>
        obtain ⟨rfl, rfl⟩ := List.cons_eq_cons.mp hcons.symm
      · exact ⟨hs1, by simp; omega⟩
      · refine ⟨hs1, ?_⟩
        have hbb : (!b) ≠ b := by cases b <;> simp
        rw [if_neg hbb]
        omega

/-- Degenerate binomial sum: `∑_{i ≤ r} C(0,i) = 1`. -/
lemma sum_choose_zero (r : ℕ) : ∑ i ∈ Finset.range (r + 1), Nat.choose 0 i = 1 := by
  induction r with
  | zero => simp
  | succ r ih => rw [Finset.sum_range_succ, ih]; simp

/-- The arithmetic shadow of `ball_cons_succ`: Pascal's rule for partial binomial sums. -/
lemma pascal_partial_sum (n s : ℕ) :
    ∑ i ∈ Finset.range (s + 2), (n + 1).choose i
      = (∑ i ∈ Finset.range (s + 2), n.choose i) + ∑ i ∈ Finset.range (s + 1), n.choose i := by
  induction s with
  | zero => simp [Finset.sum_range_succ]; omega
  | succ s ih =>
    have h : n.choose (s + 1 + 1) = n.choose (s + 2) := rfl
    rw [Finset.sum_range_succ (n := s + 2), ih,
      Finset.sum_range_succ (f := fun i => n.choose i) (n := s + 2),
      Finset.sum_range_succ (f := fun i => n.choose i) (n := s + 1), Nat.choose_succ_succ,
      Nat.succ_eq_add_one, h]
    omega

/-- **The Hamming ball counting lemma over `List Bool`.**  For every centre `c` of length
`n` and every radius `r`, the ball `B_r(c)` inside the length-`n` words has exactly
`∑_{i ≤ r} C(n, i)` elements.  In particular the volume is independent of the centre. -/
theorem ball_card (n r : ℕ) (c : List Bool) (hc : c.length = n) :
    (ball n r c).card = ∑ i ∈ Finset.range (r + 1), n.choose i := by
  induction n generalizing r c with
  | zero =>
    have hc' : c = [] := List.length_eq_zero_iff.mp hc
    subst hc'
    have hb : ball 0 r ([] : List Bool) = {[]} := by
      ext x; simp [List.length_eq_zero_iff]
    rw [hb, sum_choose_zero]
    simp
  | succ n ih =>
    obtain ⟨b, c', rfl⟩ : ∃ (b : Bool) (c' : List Bool), c = b :: c' := by
      cases c with
      | nil => simp at hc
      | cons b c' => exact ⟨b, c', rfl⟩
    have hc' : c'.length = n := by simpa using hc
    have hinj : ∀ b : Bool, Function.Injective (fun l : List Bool => b :: l) :=
      fun b x y h => by simpa using h
    cases r with
    | zero =>
      rw [ball_cons_zero, Finset.card_image_of_injective _ (hinj _), ih 0 c' hc']
      simp
    | succ s =>
      rw [ball_cons_succ, Finset.card_union_of_disjoint, Finset.card_image_of_injective _ (hinj _),
        Finset.card_image_of_injective _ (hinj _), ih (s + 1) c' hc', ih s c' hc',
        pascal_partial_sum]
      · simp only [Finset.disjoint_left, Finset.mem_image]
        rintro x ⟨u, _, rfl⟩ ⟨v, _, hv⟩
        have : (!b) = b := (List.cons_eq_cons.mp hv).1
        cases b <;> simp at this

/-- The volume of a Hamming ball does not depend on its centre. -/
theorem ball_card_eq_of_length {n r : ℕ} {c d : List Bool}
    (hc : c.length = n) (hd : d.length = n) : (ball n r c).card = (ball n r d).card := by
  rw [ball_card n r c hc, ball_card n r d hd]

/-! ## Codes, sphere packing, and the distance-2 bound -/

/-- A code `C` has minimum distance at least `d`. -/
def MinDist (C : Finset (List Bool)) (d : ℕ) : Prop :=
  ∀ x ∈ C, ∀ y ∈ C, x ≠ y → d ≤ hdist x y

/-- **Packing.**  If the minimum distance exceeds `2t`, the radius-`t` balls around the
codewords are pairwise disjoint. -/
theorem balls_pairwiseDisjoint {n t : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C (2 * t + 1)) :
    (C : Set (List Bool)).PairwiseDisjoint (fun x => ball n t x) := by
  intro x hx y hy hxy
  simp only [Finset.disjoint_left, mem_ball]
  rintro z ⟨hz, hzx⟩ ⟨-, hzy⟩
  have hxl : x.length = n := mem_words.mp (hC (by simpa using hx))
  have hyl : y.length = n := mem_words.mp (hC (by simpa using hy))
  have htri : hdist x y ≤ hdist x z + hdist z y :=
    hdist_triangle (by omega) (by omega)
  have h1 : hdist x z = hdist z x := hdist_comm x z
  have := hmin x (by simpa using hx) y (by simpa using hy) hxy
  omega

/-- **Sphere-packing (Hamming) bound.**  A code of length `n` with minimum distance
`2t + 1` satisfies `|C| · ∑_{i ≤ t} C(n,i) ≤ 2 ^ n`. -/
theorem hamming_bound {n t : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C (2 * t + 1)) :
    C.card * (∑ i ∈ Finset.range (t + 1), n.choose i) ≤ 2 ^ n := by
  classical
  have hdisj := balls_pairwiseDisjoint hC hmin
  have hcard : (C.biUnion (fun x => ball n t x)).card
      = ∑ x ∈ C, (ball n t x).card := Finset.card_biUnion hdisj
  have hvol : ∀ x ∈ C, (ball n t x).card = ∑ i ∈ Finset.range (t + 1), n.choose i := by
    intro x hx
    exact ball_card n t x (mem_words.mp (hC hx))
  have hsub : C.biUnion (fun x => ball n t x) ⊆ words n := by
    intro z hz
    obtain ⟨x, -, hzx⟩ := Finset.mem_biUnion.mp hz
    exact ball_subset_words n t x hzx
  have hle : (C.biUnion (fun x => ball n t x)).card ≤ 2 ^ n := by
    rw [← card_words n]; exact Finset.card_le_card hsub
  rw [hcard, Finset.sum_congr rfl hvol, Finset.sum_const, smul_eq_mul] at hle
  exact hle

/-- Two words of equal length that agree away from the last coordinate are at distance
at most `1`. -/
lemma hdist_le_one_of_dropLast_eq {x y : List Bool} (hl : x.length = y.length)
    (h : x.dropLast = y.dropLast) : hdist x y ≤ 1 := by
  induction x generalizing y with
  | nil => simp
  | cons a t ih =>
    cases y with
    | nil => simp at hl
    | cons b s =>
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
      by_cases ht : t = []
      · subst ht
        have hs : s = [] := List.length_eq_zero_iff.mp hl.symm
        subst hs
        simp only [hdist_cons, hdist_nil_left]
        split <;> omega
      · have hs : s ≠ [] := by
          intro hs; subst hs; simp at hl; exact ht hl
        rw [List.dropLast_cons_of_ne_nil ht, List.dropLast_cons_of_ne_nil hs,
          List.cons_eq_cons] at h
        obtain ⟨hab, hts⟩ := h
        subst hab
        have hts' := ih hl hts
        simpa using hts'

/-- **The distance-2 (single-error-detecting) bound.**  A code of length `n + 1` with
minimum distance `2` has at most `2 ^ n` words: puncturing the last coordinate is
injective on such a code. -/
theorem distance_two_code_card_le {n : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words (n + 1))
    (hmin : MinDist C 2) : C.card ≤ 2 ^ n := by
  classical
  have hinj : Set.InjOn (fun x : List Bool => x.dropLast) (C : Set (List Bool)) := by
    intro x hx y hy hxy
    by_contra hne
    have hxl : x.length = n + 1 := mem_words.mp (hC (by simpa using hx))
    have hyl : y.length = n + 1 := mem_words.mp (hC (by simpa using hy))
    have := hmin x (by simpa using hx) y (by simpa using hy) hne
    have := hdist_le_one_of_dropLast_eq (x := x) (y := y) (by omega) hxy
    omega
  have himg : C.image (fun x => x.dropLast) ⊆ words n := by
    intro z hz
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
    have hxl : x.length = n + 1 := mem_words.mp (hC hx)
    simp [List.length_dropLast, hxl]
  calc C.card = (C.image (fun x => x.dropLast)).card := (Finset.card_image_of_injOn hinj).symm
    _ ≤ (words n).card := Finset.card_le_card himg
    _ = 2 ^ n := card_words n

/-! ## The parity-extension code -/

/-- The parity bit of a binary word: the `xor` of all its letters. -/
def parity (l : List Bool) : Bool := l.foldr xor false

@[simp] lemma parity_nil : parity [] = false := rfl

@[simp] lemma parity_cons (a : Bool) (l : List Bool) : parity (a :: l) = xor a (parity l) := rfl

@[simp] lemma parity_append_singleton (l : List Bool) (b : Bool) :
    parity (l ++ [b]) = xor (parity l) b := by
  induction l with
  | nil => simp
  | cons a l ih => simp [ih]

/-- **Parity is the mod-2 reduction of Hamming distance.**  Two words of the same length
have the same parity exactly when their Hamming distance is even. -/
theorem parity_iff_even_hdist {l m : List Bool} (hl : l.length = m.length) :
    (parity l = parity m ↔ Even (hdist l m)) := by
  induction l generalizing m with
  | nil =>
    have hm : m = [] := List.length_eq_zero_iff.mp hl.symm
    subst hm; simp
  | cons a t ih =>
    cases m with
    | nil => simp at hl
    | cons b s =>
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
      have key := ih hl
      have hc : Even (if a = b then (0 : ℕ) else 1) ↔ a = b := by
        by_cases h : a = b <;> simp [h]
      rw [hdist_cons, Nat.even_add, hc, ← key]
      simp only [parity_cons]
      clear key ih hl hc
      generalize parity t = p
      generalize parity s = q
      revert a b p q
      decide

/-- The parity extension of a word: append its parity bit. -/
def withParity (l : List Bool) : List Bool := l ++ [parity l]

@[simp] lemma withParity_length (l : List Bool) : (withParity l).length = l.length + 1 := by
  simp [withParity]

/-- Every parity-extended word has parity `false`: the code is the even-weight code. -/
@[simp] theorem parity_withParity (l : List Bool) : parity (withParity l) = false := by
  simp [withParity]

lemma withParity_injective : Function.Injective withParity := by
  intro x y h
  have := congrArg (fun l => l.dropLast) h
  simpa [withParity] using this

/-- The distance between two parity-extended words is the distance of the payloads plus the
parity disagreement. -/
lemma hdist_withParity {l m : List Bool} (hl : l.length = m.length) :
    hdist (withParity l) (withParity m)
      = hdist l m + (if parity l = parity m then 0 else 1) := by
  unfold withParity
  rw [hdist_append hl]
  simp only [hdist_cons, hdist_nil_left, Nat.add_zero]

/-- **Minimum distance `2`.**  Distinct payloads produce codewords at Hamming distance at
least `2`: this is the single-error-detecting property of the parity code. -/
theorem withParity_min_dist {l m : List Bool} (hl : l.length = m.length) (hne : l ≠ m) :
    2 ≤ hdist (withParity l) (withParity m) := by
  have hpos : 1 ≤ hdist l m := by
    rcases Nat.eq_zero_or_pos (hdist l m) with h | h
    · exact absurd (eq_of_hdist_eq_zero hl h) hne
    · exact h
  rw [hdist_withParity hl]
  by_cases hp : parity l = parity m
  · have heven : Even (hdist l m) := (parity_iff_even_hdist hl).mp hp
    rcases heven with ⟨k, hk⟩
    rw [if_pos hp]
    omega
  · rw [if_neg hp]
    omega

/-- **A single bit flip is always detected.**  If `x` has the same length as a codeword
`withParity l` and is at Hamming distance `1` from it, then `x` is not itself a codeword. -/
theorem withParity_detects_single_flip {l x : List Bool}
    (hx : x.length = (withParity l).length) (h1 : hdist x (withParity l) = 1) :
    ∀ m : List Bool, x ≠ withParity m := by
  intro m hm
  subst hm
  have hlen : (withParity m).length = (withParity l).length := hx
  have hml : m.length = l.length := by simpa using hlen
  have hne : m ≠ l := by
    intro h; subst h; simp at h1
  have := withParity_min_dist hml hne
  omega

/-- The parity code of length `n + 1`: all parity extensions of the length-`n` payloads. -/
def parityCode (n : ℕ) : Finset (List Bool) := (words n).image withParity

lemma parityCode_subset (n : ℕ) : parityCode n ⊆ words (n + 1) := by
  intro x hx
  obtain ⟨l, hl, rfl⟩ := Finset.mem_image.mp hx
  simp [mem_words.mp hl]

theorem parityCode_card (n : ℕ) : (parityCode n).card = 2 ^ n := by
  rw [parityCode, Finset.card_image_of_injective _ withParity_injective, card_words]

theorem parityCode_minDist (n : ℕ) : MinDist (parityCode n) 2 := by
  intro x hx y hy hxy
  obtain ⟨l, hl, rfl⟩ := Finset.mem_image.mp hx
  obtain ⟨m, hm, rfl⟩ := Finset.mem_image.mp hy
  have hlen : l.length = m.length := by rw [mem_words.mp hl, mem_words.mp hm]
  exact withParity_min_dist hlen (fun h => hxy (by rw [h]))

/-- **Optimality of the parity code.**  No single-error-detecting code of length `n + 1`
beats the parity code, which has exactly `2 ^ n` words. -/
theorem parityCode_optimal {n : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words (n + 1))
    (hmin : MinDist C 2) : C.card ≤ (parityCode n).card := by
  rw [parityCode_card]
  exact distance_two_code_card_le hC hmin

/-- The minimum distance is *exactly* `2`, not more: for `n ≥ 1` there are two codewords at
distance `2`. -/
theorem withParity_dist_two_exists (n : ℕ) :
    hdist (withParity (false :: List.replicate n false))
      (withParity (true :: List.replicate n false)) = 2 := by
  have hlen : (false :: List.replicate n false).length
      = (true :: List.replicate n false).length := by simp
  rw [hdist_withParity hlen]
  have hp : parity (List.replicate n false) = false := by
    induction n with
    | zero => simp
    | succ n ih => simp [List.replicate_succ, ih]
  have hd : hdist (false :: List.replicate n false) (true :: List.replicate n false) = 1 := by
    simp
  rw [hd]
  simp [hp]

/-- **The parity code cannot correct a single error.**  There is a received word at distance
`1` from two distinct codewords, so no decoder can recover the payload: detection is the
best possible, matching `withParity_min_dist` being an equality. -/
theorem withParity_not_single_error_correcting (n : ℕ) :
    ∃ x : List Bool, ∃ u v : List Bool,
      u ∈ parityCode (n + 1) ∧ v ∈ parityCode (n + 1) ∧ u ≠ v ∧
      x.length = n + 2 ∧ hdist x u = 1 ∧ hdist x v = 1 := by
  classical
  refine ⟨false :: List.replicate n false ++ [true],
    withParity (false :: List.replicate n false),
    withParity (true :: List.replicate n false), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact Finset.mem_image.mpr ⟨_, by simp, rfl⟩
  · exact Finset.mem_image.mpr ⟨_, by simp, rfl⟩
  · intro h
    have := withParity_injective h
    simp at this
  · simp
  · have hp : parity (List.replicate n false) = false := by
      induction n with
      | zero => simp
      | succ n ih => simp [List.replicate_succ, ih]
    have hpar : parity (false :: List.replicate n false) = false := by simp [hp]
    unfold withParity
    rw [hpar]
    rw [hdist_append (by simp)]
    simp
  · have hp : parity (List.replicate n false) = false := by
      induction n with
      | zero => simp
      | succ n ih => simp [List.replicate_succ, ih]
    have hpar : parity (true :: List.replicate n false) = true := by simp [hp]
    unfold withParity
    rw [hpar]
    rw [hdist_append (by simp)]
    have : hdist (false :: List.replicate n false) (true :: List.replicate n false) = 1 := by simp
    rw [this]
    simp

/-! ## Sharpness of the sphere-packing bound: the length-3 repetition code -/

/-- The binary repetition code of length `3`. -/
def repetitionCode3 : Finset (List Bool) := {[false, false, false], [true, true, true]}

lemma repetitionCode3_subset : repetitionCode3 ⊆ words 3 := by decide

lemma repetitionCode3_minDist : MinDist repetitionCode3 3 := by
  intro x hx y hy hxy
  fin_cases hx <;> fin_cases hy <;> simp_all

/-- **Perfectness, geometrically.**  The two radius-1 balls around `000` and `111` tile the
whole cube `words 3`. -/
theorem repetitionCode3_balls_tile :
    repetitionCode3.biUnion (fun x => ball 3 1 x) = words 3 := by decide

/-- **The sphere-packing bound is attained.**  Derived from the tiling above together with
`balls_pairwiseDisjoint` and the counting lemma `ball_card`: the length-3 repetition code
has minimum distance `3 = 2·1 + 1` and `2 · (C(3,0) + C(3,1)) = 8 = 2 ^ 3`, so the
inequality of `hamming_bound` cannot be improved in general. -/
theorem repetitionCode3_attains_hamming_bound :
    repetitionCode3.card * (∑ i ∈ Finset.range (1 + 1), (3 : ℕ).choose i) = 2 ^ 3 := by
  classical
  have hmin : MinDist repetitionCode3 (2 * 1 + 1) := by
    simpa using repetitionCode3_minDist
  have hdisj := balls_pairwiseDisjoint repetitionCode3_subset hmin
  have hcard : (repetitionCode3.biUnion (fun x => ball 3 1 x)).card
      = ∑ x ∈ repetitionCode3, (ball 3 1 x).card := Finset.card_biUnion hdisj
  have hvol : ∀ x ∈ repetitionCode3,
      (ball 3 1 x).card = ∑ i ∈ Finset.range (1 + 1), (3 : ℕ).choose i := by
    intro x hx
    exact ball_card 3 1 x (mem_words.mp (repetitionCode3_subset hx))
  rw [Finset.sum_congr rfl hvol, Finset.sum_const, smul_eq_mul] at hcard
  rw [← hcard, repetitionCode3_balls_tile, card_words]

end ListCode