/-
# Almost-lossless compression: an explicit decoder, its cost, and its failure probability

Part of the research thread *Compression Beyond the Pigeonhole Bound*
(Phase B, Question 2: can random number generators help?).

The scheme.  Fix a *typical set* `S : Finset α` (the strings the source actually
produces with high probability), enumerated as a duplicate-free candidate list
`L`, and a codebook `H : α → Fin M` drawn uniformly at random.  The encoder sends
`H x` (`⌈log₂ M⌉` bits).  The decoder scans `L`, collects all `y` with
`H y = H x`, and

* outputs `some y` **only** when that list is a singleton, and
* outputs `none` otherwise.

Main results:

* `AlmostLossless.decode_cost` — the decoder performs **exactly `|L|`** hash
  comparisons (an exact complexity figure, not an asymptotic one).
* `AlmostLossless.decode_never_wrong` — *no silent corruption*: whenever the
  decoder outputs a string, that string is the transmitted one.  Errors are
  always reported as `none`.
* `AlmostLossless.decode_success_of_not_mem_failSet` — the decoder succeeds
  unless the codebook collides on the typical set.
* `AlmostLossless.failSet_prob_le` / `AlmostLossless.success_prob_ge` — the
  Shannon random-coding bound in exact counting form and in ℝ:
  `P[failure] ≤ (|S| - 1)/M`, hence `P[success] ≥ 1 - ε` as soon as
  `M ≥ (|S| - 1)/ε`.
* `AlmostLossless.exists_good_codebook` — derandomisation: some *fixed*
  codebook of size `M` fails on at most `|S|(|S|-1)/M` typical strings.
-/
import Geometry.AlmostLosslessCore

namespace AlmostLossless

open Finset

/-! ## 1. The scanning decoder and its exact cost -/

variable {α : Type*} [DecidableEq α] {M : ℕ}

/-- One left-to-right pass over a candidate list: returns the sublist of matching
candidates together with the number of hash comparisons performed. -/
def scan (H : α → Fin M) (c : Fin M) : List α → List α × ℕ
  | [] => ([], 0)
  | y :: ys =>
      let r := scan H c ys
      (if H y = c then y :: r.1 else r.1, r.2 + 1)

omit [DecidableEq α] in
theorem scan_fst (H : α → Fin M) (c : Fin M) (L : List α) :
    (scan H c L).1 = L.filter (fun y => H y = c) := by
  induction L with
  | nil => rfl
  | cons y ys ih =>
      by_cases hy : H y = c <;> simp [scan, List.filter, hy, ih]

omit [DecidableEq α] in
/-- **Exact cost of one pass**: one hash comparison per candidate. -/
theorem scan_snd (H : α → Fin M) (c : Fin M) (L : List α) :
    (scan H c L).2 = L.length := by
  induction L with
  | nil => rfl
  | cons y ys ih => simp [scan, ih]

/-- The decoder: `some y` if exactly one candidate matches, `none` otherwise
(the singleton test is the built-in checksum: ambiguity is always *detected*).
The second component is the number of hash comparisons performed. -/
def decode (L : List α) (H : α → Fin M) (c : Fin M) : Option α × ℕ :=
  (match (scan H c L).1 with
    | [y] => some y
    | _ => none,
   (scan H c L).2)

omit [DecidableEq α] in
/-- **Exact decoding complexity**: the decoder uses exactly `|L|` hash
comparisons — one per candidate typical string. -/
theorem decode_cost (L : List α) (H : α → Fin M) (c : Fin M) :
    (decode L H c).2 = L.length := by
  simp [decode, scan_snd]

omit [DecidableEq α] in
/-- The decoder outputs a string exactly when the candidate list is a singleton. -/
theorem decode_fst_eq_some_iff (L : List α) (H : α → Fin M) (c : Fin M) (y : α) :
    (decode L H c).1 = some y ↔ L.filter (fun z => H z = c) = [y] := by
  constructor
  · intro h
    simp only [decode, scan_fst] at h
    rcases hl : L.filter (fun z => H z = c) with _ | ⟨a, l⟩
    · rw [hl] at h; simp at h
    · rcases l with _ | ⟨b, l'⟩
      · rw [hl] at h
        simp only [Option.some.injEq] at h
        rw [h]
      · rw [hl] at h; simp at h
  · intro h
    simp only [decode, scan_fst, h]

/-! ## 2. No silent corruption -/

omit [DecidableEq α] in
/-- Whatever the decoder outputs is a candidate carrying the received codeword. -/
theorem decode_sound {L : List α} {H : α → Fin M} {c : Fin M} {y : α}
    (h : (decode L H c).1 = some y) : y ∈ L ∧ H y = c := by
  rw [decode_fst_eq_some_iff] at h
  have hy : y ∈ L.filter (fun z => H z = c) := by rw [h]; simp
  rw [List.mem_filter] at hy
  exact ⟨hy.1, by simpa using hy.2⟩

omit [DecidableEq α] in
/-- **No silent corruption.**  If the transmitted string `x` is a candidate, then
any output of the decoder is *exactly* `x`; a failure can only manifest as `none`,
never as a wrong string. -/
theorem decode_never_wrong {L : List α} {H : α → Fin M} {x y : α}
    (hx : x ∈ L) (h : (decode L H (H x)).1 = some y) : y = x := by
  have hsing := (decode_fst_eq_some_iff L H (H x) y).1 h
  have hxmem : x ∈ L.filter (fun z => H z = H x) := by
    rw [List.mem_filter]
    exact ⟨hx, by simp⟩
  rw [hsing] at hxmem
  simpa [eq_comm] using hxmem

/-! ## 3. When does the decoder succeed? -/

variable [Fintype α]

/-- The set of codebooks that confuse `x` with another typical string. -/
def failSet (S : Finset α) (x : α) (M : ℕ) : Finset (α → Fin M) :=
  univ.filter (fun H => ∃ y ∈ S.erase x, H y = H x)

/-- Off the failure event the decoder returns the transmitted string, at a cost of
exactly `|S|` hash comparisons. -/
theorem decode_success_of_not_mem_failSet {S : Finset α} {L : List α} {x : α}
    {H : α → Fin M} (hnd : L.Nodup) (hmem : ∀ y, y ∈ L ↔ y ∈ S)
    (hx : x ∈ S) (hH : H ∉ failSet S x M) :
    decode L H (H x) = (some x, L.length) := by
  have hno : ∀ y ∈ S, y ≠ x → H y ≠ H x := by
    intro y hy hyx hHy
    exact hH (by
      simp only [failSet, mem_filter, mem_univ, true_and]
      exact ⟨y, Finset.mem_erase.2 ⟨hyx, hy⟩, hHy⟩)
  -- the candidate list is exactly `[x]`
  set F := L.filter (fun z => H z = H x) with hF
  have hnodup : F.Nodup := hnd.filter _
  have hall : ∀ z ∈ F, z = x := by
    intro z hz
    rw [hF, List.mem_filter] at hz
    by_contra hzx
    exact hno z ((hmem z).1 hz.1) hzx (by simpa using hz.2)
  have hxmem : x ∈ F := by
    rw [hF, List.mem_filter]
    exact ⟨(hmem x).2 hx, by simp⟩
  have hsub : F ⊆ [x] := by
    intro z hz; simpa using hall z hz
  have hlen1 : F.length ≤ 1 := by
    have := (hnodup.subperm hsub).length_le
    simpa using this
  have hlen2 : 1 ≤ F.length := List.length_pos_of_mem hxmem
  have hlen : F.length = 1 := le_antisymm hlen1 hlen2
  obtain ⟨a, ha⟩ := List.length_eq_one_iff.1 hlen
  have hax : a = x := hall a (by rw [ha]; simp)
  have hFx : F = [x] := by rw [ha, hax]
  have hfst : (decode L H (H x)).1 = some x :=
    (decode_fst_eq_some_iff L H (H x) x).2 (by rw [← hF, hFx])
  exact Prod.ext hfst (decode_cost L H (H x))

/-! ## 4. The random-coding bound -/

/-- The failure event is a union of `|S| - 1` pairwise collision events. -/
theorem failSet_eq_multiCollision (S : Finset α) (x : α) :
    failSet S x M = multiCollision M ((S.erase x).image (fun y => (y, x))) := by
  ext H
  simp only [failSet, multiCollision, mem_filter, mem_univ, true_and, mem_image]
  constructor
  · rintro ⟨y, hy, hHy⟩
    exact ⟨(y, x), ⟨y, hy, rfl⟩, hHy⟩
  · rintro ⟨p, ⟨y, hy, rfl⟩, hHp⟩
    exact ⟨y, hy, hHp⟩

/-- **Random-coding bound, exact counting form.**  Among all `M ^ |α|` codebooks,
the fraction that fails on a fixed typical `x` is at most `(|S| - 1)/M`. -/
theorem failSet_prob_le (S : Finset α) {x : α} (hx : x ∈ S) :
    M * (failSet S x M).card ≤ (S.card - 1) * M ^ Fintype.card α := by
  classical
  rw [failSet_eq_multiCollision]
  have hpairs : ∀ p ∈ (S.erase x).image (fun y => (y, x)), p.1 ≠ p.2 := by
    intro p hp
    obtain ⟨y, hy, rfl⟩ := mem_image.1 hp
    exact (Finset.mem_erase.1 hy).1
  have hcard : ((S.erase x).image (fun y => (y, x))).card ≤ S.card - 1 := by
    have h : ((S.erase x).image (fun y => (y, x))).card ≤ (S.erase x).card :=
      Finset.card_image_le
    rwa [Finset.card_erase_of_mem hx] at h
  exact le_trans (card_multiCollision_mul_le _ hpairs) (Nat.mul_le_mul_right _ hcard)

/-- The set of codebooks on which the scheme decodes `x` correctly. -/
def goodSet (L : List α) (x : α) (M : ℕ) : Finset (α → Fin M) :=
  univ.filter (fun H => (decode L H (H x)).1 = some x)

theorem card_goodSet_ge {S : Finset α} {L : List α} (hnd : L.Nodup)
    (hmem : ∀ y, y ∈ L ↔ y ∈ S) {x : α} (hx : x ∈ S) :
    M ^ Fintype.card α ≤ (goodSet L x M).card + (failSet S x M).card := by
  classical
  have hsub : (failSet S x M)ᶜ ⊆ goodSet L x M := by
    intro H hH
    simp only [mem_compl] at hH
    have hdec := decode_success_of_not_mem_failSet hnd hmem hx hH
    simp only [goodSet, mem_filter, mem_univ, true_and, hdec]
  have h1 : ((failSet S x M)ᶜ).card ≤ (goodSet L x M).card := Finset.card_le_card hsub
  have hle : (failSet S x M).card ≤ M ^ Fintype.card α := by
    have h := Finset.card_le_univ (failSet S x M)
    simpa [Finset.card_univ, card_codebooks] using h
  have h2 : ((failSet S x M)ᶜ).card + (failSet S x M).card = M ^ Fintype.card α := by
    rw [Finset.card_compl, card_codebooks]
    omega
  omega

/-- **Almost-lossless guarantee, real-valued form.**  If the codebook has
`M ≥ (|S| - 1)/ε` entries, then a uniformly random codebook decodes a fixed
typical string correctly with probability at least `1 - ε`.

Note the rate: `log₂ M ≈ log₂ |S| + log₂(1/ε)` bits, versus the pigeonhole
requirement `log₂ |α|` bits for exact decoding of *every* string. -/
theorem success_prob_ge {S : Finset α} {L : List α} (hnd : L.Nodup)
    (hmem : ∀ y, y ∈ L ↔ y ∈ S) {x : α} (hx : x ∈ S) (hM : 0 < M)
    {ε : ℝ} (hε : 0 < ε) (hMe : ((S.card : ℝ) - 1) / ε ≤ M) :
    1 - ε ≤ ((goodSet L x M).card : ℝ) / ((M : ℝ) ^ Fintype.card α) := by
  have hpos : (0 : ℝ) < (M : ℝ) ^ Fintype.card α := by
    have : (0 : ℝ) < M := by exact_mod_cast hM
    positivity
  have hScard : (1 : ℕ) ≤ S.card := Finset.card_pos.2 ⟨x, hx⟩
  have hfail : (M : ℝ) * (failSet S x M).card
      ≤ ((S.card : ℝ) - 1) * (M : ℝ) ^ Fintype.card α := by
    have h := failSet_prob_le (M := M) S hx
    have h' : ((M * (failSet S x M).card : ℕ) : ℝ)
        ≤ (((S.card - 1) * M ^ Fintype.card α : ℕ) : ℝ) := Nat.cast_le.2 h
    push_cast [Nat.cast_sub hScard] at h'
    exact h'
  have hgood : (M : ℝ) ^ Fintype.card α - (failSet S x M).card ≤ (goodSet L x M).card := by
    have h := card_goodSet_ge (M := M) hnd hmem hx
    have h' : ((M ^ Fintype.card α : ℕ) : ℝ)
        ≤ ((goodSet L x M).card : ℝ) + ((failSet S x M).card : ℝ) := by exact_mod_cast h
    push_cast at h'
    linarith
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hbound : ((S.card : ℝ) - 1) ≤ ε * M := by
    have := (div_le_iff₀ hε).1 hMe
    linarith
  have hfail2 : ((failSet S x M).card : ℝ) ≤ ε * (M : ℝ) ^ Fintype.card α := by
    have h2 : (M : ℝ) * (failSet S x M).card ≤ (M : ℝ) * (ε * (M : ℝ) ^ Fintype.card α) := by
      have h3 : ((S.card : ℝ) - 1) * (M : ℝ) ^ Fintype.card α
          ≤ (ε * M) * (M : ℝ) ^ Fintype.card α :=
        mul_le_mul_of_nonneg_right hbound hpos.le
      nlinarith [hfail, h3]
    exact le_of_mul_le_mul_left h2 hMpos
  rw [le_div_iff₀ hpos]
  nlinarith [hgood, hfail2]

/-! ## 5. Derandomisation: a single good codebook exists -/

/-- The typical strings that a *fixed* codebook `H` fails to distinguish. -/
def badStrings (S : Finset α) (H : α → Fin M) : Finset α :=
  S.filter (fun x => ∃ y ∈ S.erase x, H y = H x)

/-- **Existence of a good deterministic codebook** (derandomised random coding):
some codebook with `M` codewords is ambiguous on at most `|S|(|S|-1)/M` of the
typical strings.  In particular with `M ≥ |S|/ε` at most `ε|S|` typical strings
are lost, while the code length stays `log₂ M`. -/
theorem exists_good_codebook (S : Finset α) (hM : 0 < M) :
    ∃ H : α → Fin M, M * (badStrings S H).card ≤ S.card * (S.card - 1) := by
  classical
  set f : (α → Fin M) → ℕ := fun H => (badStrings S H).card with hf
  -- double counting: ∑_H |bad(H)| = ∑_{x ∈ S} |failSet x|
  have hswap : ∑ H : α → Fin M, f H = ∑ x ∈ S, (failSet S x M).card := by
    simp only [hf, badStrings, failSet, Finset.card_filter]
    rw [Finset.sum_comm]
  have hbound : M * ∑ H : α → Fin M, f H ≤ S.card * ((S.card - 1) * M ^ Fintype.card α) := by
    rw [hswap, Finset.mul_sum]
    calc ∑ x ∈ S, M * (failSet S x M).card
        ≤ ∑ _x ∈ S, (S.card - 1) * M ^ Fintype.card α :=
          Finset.sum_le_sum (fun x hx => failSet_prob_le S hx)
      _ = S.card * ((S.card - 1) * M ^ Fintype.card α) := by
          rw [Finset.sum_const, smul_eq_mul]
  obtain ⟨H₀, -, hmin⟩ :=
    Finset.exists_min_image (univ : Finset (α → Fin M)) f ⟨fun _ => ⟨0, hM⟩, mem_univ _⟩
  have hsum : (M ^ Fintype.card α) * f H₀ ≤ ∑ H : α → Fin M, f H := by
    have h : ∑ _H : α → Fin M, f H₀ ≤ ∑ H : α → Fin M, f H :=
      Finset.sum_le_sum (fun H _ => hmin H (mem_univ H))
    rwa [Finset.sum_const, smul_eq_mul, Finset.card_univ, card_codebooks] at h
  refine ⟨H₀, ?_⟩
  have hpow : 0 < M ^ Fintype.card α := Nat.pow_pos hM
  have key : (M ^ Fintype.card α) * (M * f H₀)
      ≤ (M ^ Fintype.card α) * (S.card * (S.card - 1)) := by
    calc (M ^ Fintype.card α) * (M * f H₀) = M * ((M ^ Fintype.card α) * f H₀) := by ring
      _ ≤ M * ∑ H : α → Fin M, f H := Nat.mul_le_mul_left _ hsum
      _ ≤ S.card * ((S.card - 1) * M ^ Fintype.card α) := hbound
      _ = (M ^ Fintype.card α) * (S.card * (S.card - 1)) := by ring
  exact Nat.le_of_mul_le_mul_left key hpow

end AlmostLossless