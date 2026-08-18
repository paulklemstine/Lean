import Mathlib
import Catalog.Computation.ListHammingBallParity
import Catalog.Computation.BinaryCodeBounds

/-!
# Classification of the optimal single-error-detecting codes

Cycle 6 of the research thread.  Cycle 1 proved that a length-`(n+1)` code of minimum
distance `2` has at most `2 ^ n` words and that the parity code attains this
(`parityCode_optimal`).  Attainment leaves the natural question: *is the parity code the
only optimum?*  The answer here is a complete classification: there are exactly two optimal
codes, the even-weight code (the parity code) and the odd-weight code, and nothing else.

## Main results

* `hypercube_connected` — the Hamming cube is connected by single flips: a function on
  `words n` that is constant along edges is constant.  This is the graph-theoretic
  ingredient the classification needs and is stated independently of coding theory.
* `parity_constant_on_optimal` — in an optimal detecting code all codewords have the same
  parity.
* `optimal_detecting_classification` — an optimal code is either `parityCode n` or
  `oddCode n`.
* `oddCode_card`, `oddCode_minDist` — the odd-weight code is a genuine second optimum
  (it is a coset of the parity code, not equal to it).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): optimality forces rigidity — the "checksum" attached to a
payload can only be the parity, up to a global flip.

Experiment (Experimenter): the proof runs in three moves.  (i) Puncturing the last
coordinate is a bijection from an optimal code onto `words n` (injectivity is cycle 1's
distance-2 argument; surjectivity is a cardinality count).  (ii) Along an edge of the cube
the two attached checksum bits must differ, and so do the payload parities — hence the
codeword parity is *constant along edges*.  (iii) `hypercube_connected` upgrades "constant
along edges" to "constant", and a constant parity pins the code down to one of the two
weight classes, which then coincide with the code by cardinality.

Analysis (Analyst): step (iii) is where a *graph* fact enters an otherwise metric/algebraic
development; the induction that proves it (restricting to a fixed leading letter) is the
same "peel the first coordinate" recursion used for `ball_card` in cycle 1, which suggests
that recursion is the organising principle of the whole `List Bool` treatment.

Critique (Critic): the classification is sharp — both alternatives really occur, since
`oddCode_card` and `oddCode_minDist` show the odd-weight code is also optimal; and the
hypothesis `C.card = 2 ^ n` cannot be weakened to `MinDist C 2` alone (any subset of the
parity code has distance 2 but is not one of the two codes).
-/

namespace ListCode

open Finset

/-! ## Connectivity of the Hamming cube -/

/-- **The Hamming cube is connected by single flips.**  A function that agrees on words at
distance `1` is constant on all words of length `n`. -/
theorem hypercube_connected : ∀ (n : ℕ) (h : List Bool → Bool),
    (∀ x y, x.length = n → y.length = n → hdist x y = 1 → h x = h y) →
    ∀ x y, x.length = n → y.length = n → h x = h y := by
  intro n
  induction n with
  | zero =>
    intro h _ x y hx hy
    rw [List.length_eq_zero_iff.mp hx, List.length_eq_zero_iff.mp hy]
  | succ n ih =>
    intro h hstep x y hx hy
    obtain ⟨a, t, rfl⟩ : ∃ a t, x = a :: t := by
      cases x with
      | nil => simp at hx
      | cons a t => exact ⟨a, t, rfl⟩
    obtain ⟨b, u, rfl⟩ : ∃ b u, y = b :: u := by
      cases y with
      | nil => simp at hy
      | cons b u => exact ⟨b, u, rfl⟩
    simp only [List.length_cons, Nat.add_right_cancel_iff] at hx hy
    have hsame : ∀ (c : Bool) (v w : List Bool), v.length = n → w.length = n →
        h (c :: v) = h (c :: w) := by
      intro c v w hv hw
      refine ih (fun z => h (c :: z)) ?_ v w hv hw
      intro p q hp hq hpq
      exact hstep (c :: p) (c :: q) (by simp [hp]) (by simp [hq]) (by simp [hpq])
    by_cases hab : a = b
    · subst hab
      exact hsame a t u hx hy
    · have h1 : h (a :: t) = h (a :: u) := hsame a t u hx hy
      have h2 : h (a :: u) = h (b :: u) :=
        hstep _ _ (by simp [hy]) (by simp [hy]) (by simp [hab])
      rw [h1, h2]

/-! ## The odd-weight code -/

/-- The odd-weight code of length `n + 1`: the other optimal detecting code. -/
def oddCode (n : ℕ) : Finset (List Bool) := (words (n + 1)).filter (fun x => parity x = true)

lemma oddCode_subset (n : ℕ) : oddCode n ⊆ words (n + 1) := Finset.filter_subset _ _

theorem oddCode_card (n : ℕ) : (oddCode n).card = 2 ^ n := by
  classical
  have h1 : (parityCode n).card + (oddCode n).card = 2 ^ (n + 1) := by
    rw [parityCode_eq_even_weight, oddCode]
    have heq : (words (n + 1)).filter (fun x => parity x = true)
        = (words (n + 1)).filter (fun x => ¬ (parity x = false)) := by
      apply Finset.filter_congr
      intro x _
      cases hp : parity x <;> simp
    rw [heq, Finset.card_filter_add_card_filter_not (fun x => parity x = false), card_words]
  rw [parityCode_card] at h1
  have h2 : 2 ^ (n + 1) = 2 ^ n + 2 ^ n := by ring
  omega

/-- The odd-weight code also has minimum distance `2`: two words of odd weight cannot differ
in exactly one place. -/
theorem oddCode_minDist (n : ℕ) : MinDist (oddCode n) 2 := by
  intro x hx y hy hxy
  obtain ⟨hxw, hxp⟩ := Finset.mem_filter.mp hx
  obtain ⟨hyw, hyp⟩ := Finset.mem_filter.mp hy
  have hxl : x.length = n + 1 := mem_words.mp hxw
  have hyl : y.length = n + 1 := mem_words.mp hyw
  have hpar : parity x = parity y := by rw [hxp, hyp]
  have heven : Even (hdist x y) := (parity_iff_even_hdist (by omega)).mp hpar
  have hpos : 1 ≤ hdist x y := by
    rcases Nat.eq_zero_or_pos (hdist x y) with h | h
    · exact absurd (eq_of_hdist_eq_zero (by omega) h) hxy
    · exact h
  obtain ⟨k, hk⟩ := heven
  omega

/-! ## Rigidity of optimal detecting codes -/

/-- **All codewords of an optimal detecting code have the same parity.** -/
theorem parity_constant_on_optimal {n : ℕ} {C : Finset (List Bool)}
    (hC : C ⊆ words (n + 1)) (hmin : MinDist C 2) (hcard : C.card = 2 ^ n) :
    ∀ c1 ∈ C, ∀ c2 ∈ C, parity c1 = parity c2 := by
  classical
  have hinj : Set.InjOn (fun x : List Bool => x.dropLast) (C : Set (List Bool)) := by
    intro x hx y hy hxy
    by_contra hne
    have hxl : x.length = n + 1 := mem_words.mp (hC (by simpa using hx))
    have hyl : y.length = n + 1 := mem_words.mp (hC (by simpa using hy))
    have h1 := hmin x (by simpa using hx) y (by simpa using hy) hne
    have h2 := hdist_le_one_of_dropLast_eq (x := x) (y := y) (by omega) hxy
    omega
  have himg : C.image (fun x => x.dropLast) = words n := by
    refine Finset.eq_of_subset_of_card_le ?_ ?_
    · intro z hz
      obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
      have hxl : x.length = n + 1 := mem_words.mp (hC hx)
      simp [List.length_dropLast, hxl]
    · rw [Finset.card_image_of_injOn hinj, hcard, card_words]
  have hsurj : ∀ l ∈ words n, ∃ c, c ∈ C ∧ c.dropLast = l := by
    intro l hl
    rw [← himg] at hl
    obtain ⟨c, hc, hcl⟩ := Finset.mem_image.mp hl
    exact ⟨c, hc, hcl⟩
  choose! F hFC hFd using hsurj
  have hsplit : ∀ l ∈ words n, ∃ p, F l = l ++ [p] := by
    intro l hl
    have hFl : (F l).length = n + 1 := mem_words.mp (hC (hFC l hl))
    have hne : F l ≠ [] := by intro h; rw [h] at hFl; simp at hFl
    refine ⟨(F l).getLast hne, ?_⟩
    conv_lhs => rw [← List.dropLast_append_getLast hne]
    rw [hFd l hl]
  have hstep : ∀ x y, x.length = n → y.length = n → hdist x y = 1 →
      parity (F x) = parity (F y) := by
    intro x y hx hy hd
    obtain ⟨p, hp⟩ := hsplit x (mem_words.mpr hx)
    obtain ⟨q, hq⟩ := hsplit y (mem_words.mpr hy)
    have hne : F x ≠ F y := by
      intro h
      have hxy : x = y := by rw [← hFd x (mem_words.mpr hx), ← hFd y (mem_words.mpr hy), h]
      rw [hxy] at hd
      simp at hd
    have hdxy : hdist (F x) (F y) = hdist x y + (if p = q then 0 else 1) := by
      rw [hp, hq, hdist_append (by omega)]
      simp
    have h2 := hmin (F x) (hFC x (mem_words.mpr hx)) (F y) (hFC y (mem_words.mpr hy)) hne
    have hpq : p ≠ q := by
      intro h
      rw [hdxy, hd, if_pos h] at h2
      omega
    have hpar : parity x ≠ parity y := by
      intro h
      have heven := (parity_iff_even_hdist (by omega)).mp h
      rw [hd] at heven
      simp at heven
    rw [hp, hq, parity_append_singleton, parity_append_singleton]
    cases hx' : parity x <;> cases hy' : parity y <;> cases p <;> cases q <;> simp_all
  have hconst := hypercube_connected n (fun l => parity (F l)) hstep
  intro c1 h1 c2 h2
  have hc1 : c1.length = n + 1 := mem_words.mp (hC h1)
  have hc2 : c2.length = n + 1 := mem_words.mp (hC h2)
  have e1 : F c1.dropLast = c1 := by
    have hmem : c1.dropLast ∈ words n := by simp [List.length_dropLast, hc1]
    exact hinj (by simpa using hFC _ hmem) (by simpa using h1) (by simpa using hFd _ hmem)
  have e2 : F c2.dropLast = c2 := by
    have hmem : c2.dropLast ∈ words n := by simp [List.length_dropLast, hc2]
    exact hinj (by simpa using hFC _ hmem) (by simpa using h2) (by simpa using hFd _ hmem)
  have hfin := hconst c1.dropLast c2.dropLast (by simp [List.length_dropLast, hc1])
    (by simp [List.length_dropLast, hc2])
  simp only [e1, e2] at hfin
  exact hfin

/-- **Classification of optimal single-error-detecting codes.**  A length-`(n+1)` binary
code of minimum distance `2` and maximal size `2 ^ n` is either the even-weight (parity)
code or the odd-weight code. -/
theorem optimal_detecting_classification {n : ℕ} {C : Finset (List Bool)}
    (hC : C ⊆ words (n + 1)) (hmin : MinDist C 2) (hcard : C.card = 2 ^ n) :
    C = parityCode n ∨ C = oddCode n := by
  classical
  have hne : C.Nonempty := by
    rw [← Finset.card_pos, hcard]
    exact Nat.two_pow_pos n
  obtain ⟨c0, hc0⟩ := hne
  have hconst := parity_constant_on_optimal hC hmin hcard
  cases hp : parity c0 with
  | false =>
    left
    refine Finset.eq_of_subset_of_card_le ?_ ?_
    · intro y hy
      rw [parityCode_eq_even_weight]
      exact Finset.mem_filter.mpr ⟨hC hy, by rw [hconst y hy c0 hc0, hp]⟩
    · simp [hcard, parityCode_card]
  | true =>
    right
    refine Finset.eq_of_subset_of_card_le ?_ ?_
    · intro y hy
      exact Finset.mem_filter.mpr ⟨hC hy, by rw [hconst y hy c0 hc0, hp]⟩
    · simp [hcard, oddCode_card]

/-- The all-zero word has even parity. -/
lemma parity_zeroWord (n : ℕ) : parity (zeroWord n) = false := by
  induction n with
  | zero => simp [zeroWord]
  | succ n ih => rw [zeroWord_succ, parity_cons, ih]; simp

/-- Both alternatives genuinely occur, and they are distinct for every `n`. -/
theorem parityCode_ne_oddCode (n : ℕ) : parityCode n ≠ oddCode n := by
  intro h
  have hz : zeroWord (n + 1) ∈ parityCode n := zeroWord_mem_parityCode n
  rw [h] at hz
  have hodd := (Finset.mem_filter.mp hz).2
  rw [parity_zeroWord] at hodd
  exact absurd hodd (by simp)

end ListCode