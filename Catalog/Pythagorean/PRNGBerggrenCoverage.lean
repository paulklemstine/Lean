import Mathlib
import Pythagorean.PRNGMatrixFingerprint
import Pythagorean.BerggrenTrees.Parent_hyp_lt

/-!
# Cycle 3: how much Pythagorean data is seed-compressible?  All of it.

The classifier file measures the *reach* of the seed compressor from a bounded
seed box and finds it tiny: seed compression cannot cover arbitrary files.  The
present file proves the complementary — and much stronger — statement for the
data the generator was designed for:

> **Coverage.**  Every primitive Pythagorean triple with positive legs and odd
> first leg is the output of the Berggren generator for exactly one control word.

Together with `applyPath_injective` (unique decodability) and
`decodeSeed_applyPath` (exact seed recovery) this makes `applyPath` an explicit
computable bijection

  `{A,B,C}*  ≃  {normalised primitive Pythagorean triples}`,

so a corpus of primitive Pythagorean triples is **100 % seed-compressible**: the
answer to "what fraction of this real data is PRNG output?" is `1`, and the seed
is recovered in `O(length)` sign tests.

Main contents.

* `TreeTriple` — the normalisation (positive legs, coprime legs, odd first leg).
* `applyPath_treeTriple` — the generator only emits normalised triples.
* `treeTriple_eq_root_of_hyp_le_five` — the base case of the descent.
* `parent_coprime`, `descent` — one step of seed recovery: a normalised triple
  with hypotenuse `> 5` has a normalised parent with strictly smaller hypotenuse.
* `exists_path_of_treeTriple` — **coverage**.
* `berggren_code_bijection` — coverage + unique decodability, as a bijection.
* `treeTriple_seed_length_bound` — the recovered seed has length at most
  `(c-5)/4`, so decoding terminates in linearly many steps.
-/

namespace Catalog.Pythagorean.BerggrenPRNG

open Catalog.Probability.SeedRec BerggrenGroupoid

/-- A *normalised primitive* Pythagorean triple: the shape the Berggren tree
enumerates. -/
structure TreeTriple (p : ℤ × ℤ × ℤ) : Prop where
  pyth : IsPythag p.1 p.2.1 p.2.2
  fst_pos : 0 < p.1
  snd_pos : 0 < p.2.1
  hyp_pos : 0 < p.2.2
  coprime : Int.gcd p.1 p.2.1 = 1
  fst_odd : Odd p.1

theorem TreeTriple.good {p : ℤ × ℤ × ℤ} (h : TreeTriple p) : GoodTriple p :=
  ⟨h.pyth, h.fst_pos, h.snd_pos, h.hyp_pos⟩

/-! ## The generator emits only normalised triples -/

theorem applyStep_treeTriple {p : ℤ × ℤ × ℤ} (h : TreeTriple p) (s : BerggrenStep) :
    TreeTriple (applyStep s p) := by
  have hg := applyStep_good h.good s
  obtain ⟨a, b, c⟩ := p
  obtain ⟨k, hk⟩ := h.fst_odd
  have hco := h.coprime
  simp only at hk hco
  cases s
  · exact ⟨hg.pyth, hg.fst_pos, hg.snd_pos, hg.hyp_pos, bergA_prim a b c h.pyth hco,
      ⟨k - b + c, by simp only [applyStep, bergA]; omega⟩⟩
  · exact ⟨hg.pyth, hg.fst_pos, hg.snd_pos, hg.hyp_pos, bergB_prim a b c h.pyth hco,
      ⟨k + b + c, by simp only [applyStep, bergB]; omega⟩⟩
  · exact ⟨hg.pyth, hg.fst_pos, hg.snd_pos, hg.hyp_pos, bergC_prim a b c h.pyth hco,
      ⟨-k + b + c - 1, by simp only [applyStep, bergC]; omega⟩⟩

theorem root_treeTriple : TreeTriple (3, 4, 5) :=
  ⟨by norm_num [IsPythag], by norm_num, by norm_num, by norm_num, by decide, ⟨1, by norm_num⟩⟩

theorem applyPath_treeTriple (w : List BerggrenStep) : TreeTriple (applyPath w) := by
  induction w using List.reverseRecOn with
  | nil => exact root_treeTriple
  | append_singleton u s ih =>
      rw [applyPath_concat]
      exact applyStep_treeTriple ih s

/-! ## Base case of the descent -/

/-- The only normalised primitive triple with hypotenuse at most `5` is the root
`(3,4,5)`. -/
theorem treeTriple_eq_root_of_hyp_le_five {p : ℤ × ℤ × ℤ} (h : TreeTriple p)
    (hc : p.2.2 ≤ 5) : p = (3, 4, 5) := by
  obtain ⟨a, b, c⟩ := p
  have ha := h.fst_pos
  have hb := h.snd_pos
  have hcpos := h.hyp_pos
  have hpy : a ^ 2 + b ^ 2 = c ^ 2 := h.pyth
  have hco := h.coprime
  have hodd := h.fst_odd
  simp only at ha hb hcpos hc hco hodd ⊢
  have hac : a < c := by nlinarith
  have hbc : b < c := by nlinarith
  have ha5 : a ≤ 4 := by omega
  have hb5 : b ≤ 4 := by omega
  interval_cases a <;> interval_cases b <;> interval_cases c <;>
    simp_all [Int.gcd, Int.odd_iff]

/-! ## One step of seed recovery -/

/-- If a Berggren image has coprime legs, so had its parent. -/
theorem parent_coprime {q p : ℤ × ℤ × ℤ} (hq : IsPythag q.1 q.2.1 q.2.2) (s : BerggrenStep)
    (hsp : applyStep s q = p) (hp : Int.gcd p.1 p.2.1 = 1) : Int.gcd q.1 q.2.1 = 1 := by
  set d : ℤ := (Int.gcd q.1 q.2.1 : ℤ) with hd
  have hd1 : d ∣ q.1 := Int.gcd_dvd_left q.1 q.2.1
  have hd2 : d ∣ q.2.1 := Int.gcd_dvd_right q.1 q.2.1
  have hd3 : d ∣ q.2.2 := dvd_hyp_of_dvd_legs _ _ _ _ hq hd1 hd2
  obtain ⟨k₁, hk₁⟩ := hd1
  obtain ⟨k₂, hk₂⟩ := hd2
  obtain ⟨k₃, hk₃⟩ := hd3
  have hdiv : d ∣ p.1 ∧ d ∣ p.2.1 := by
    subst hsp
    obtain ⟨x, y, z⟩ := q
    simp only at hk₁ hk₂ hk₃
    cases s
    · exact ⟨⟨k₁ - 2 * k₂ + 2 * k₃, by simp only [applyStep, bergA]; rw [hk₁, hk₂, hk₃]; ring⟩,
        ⟨2 * k₁ - k₂ + 2 * k₃, by simp only [applyStep, bergA]; rw [hk₁, hk₂, hk₃]; ring⟩⟩
    · exact ⟨⟨k₁ + 2 * k₂ + 2 * k₃, by simp only [applyStep, bergB]; rw [hk₁, hk₂, hk₃]; ring⟩,
        ⟨2 * k₁ + k₂ + 2 * k₃, by simp only [applyStep, bergB]; rw [hk₁, hk₂, hk₃]; ring⟩⟩
    · exact ⟨⟨-k₁ + 2 * k₂ + 2 * k₃, by simp only [applyStep, bergC]; rw [hk₁, hk₂, hk₃]; ring⟩,
        ⟨-2 * k₁ + k₂ + 2 * k₃, by simp only [applyStep, bergC]; rw [hk₁, hk₂, hk₃]; ring⟩⟩
  have hdvd1 : d ∣ (1 : ℤ) := by
    have := Int.dvd_coe_gcd hdiv.1 hdiv.2
    rwa [hp, Nat.cast_one] at this
  have hd0 : 0 ≤ d := by positivity
  have hone : d = 1 := Int.eq_one_of_dvd_one hd0 hdvd1
  rw [hd] at hone
  exact_mod_cast hone

/-- Inverse moves preserve the Pythagorean condition. -/
theorem isPythag_moveA' (p : ℤ × ℤ × ℤ) (h : IsPythag p.1 p.2.1 p.2.2) :
    IsPythag (moveA' p).1 (moveA' p).2.1 (moveA' p).2.2 := by
  have h1 : lorentz (moveA (moveA' p)) = lorentz (moveA' p) := lorentz_moveA _
  rw [moveA_moveA'] at h1
  have h2 : lorentz p = 0 := (isPythag_iff_lorentzQ_zero p.1 p.2.1 p.2.2).1 h
  have h3 : lorentz (moveA' p) = 0 := by rw [← h1]; exact h2
  exact (isPythag_iff_lorentzQ_zero _ _ _).2 h3

theorem isPythag_moveB' (p : ℤ × ℤ × ℤ) (h : IsPythag p.1 p.2.1 p.2.2) :
    IsPythag (moveB' p).1 (moveB' p).2.1 (moveB' p).2.2 := by
  have h1 : lorentz (moveB (moveB' p)) = lorentz (moveB' p) := lorentz_moveB _
  rw [moveB_moveB'] at h1
  have h2 : lorentz p = 0 := (isPythag_iff_lorentzQ_zero p.1 p.2.1 p.2.2).1 h
  have h3 : lorentz (moveB' p) = 0 := by rw [← h1]; exact h2
  exact (isPythag_iff_lorentzQ_zero _ _ _).2 h3

theorem isPythag_moveC' (p : ℤ × ℤ × ℤ) (h : IsPythag p.1 p.2.1 p.2.2) :
    IsPythag (moveC' p).1 (moveC' p).2.1 (moveC' p).2.2 := by
  have h1 : lorentz (moveC (moveC' p)) = lorentz (moveC' p) := lorentz_moveC _
  rw [moveC_moveC'] at h1
  have h2 : lorentz p = 0 := (isPythag_iff_lorentzQ_zero p.1 p.2.1 p.2.2).1 h
  have h3 : lorentz (moveC' p) = 0 := by rw [← h1]; exact h2
  exact (isPythag_iff_lorentzQ_zero _ _ _).2 h3

/-- **Descent.**  Every normalised triple other than the root has a normalised
parent with strictly smaller hypotenuse, reached by a unique control symbol. -/
theorem descent {p : ℤ × ℤ × ℤ} (h : TreeTriple p) (hc : 5 < p.2.2) :
    ∃ (s : BerggrenStep) (q : ℤ × ℤ × ℤ), TreeTriple q ∧ q.2.2 < p.2.2 ∧ applyStep s q = p := by
  have hpar := parent_exists p.1 p.2.1 p.2.2 h.fst_pos h.snd_pos h.hyp_pos h.pyth hc h.coprime
  have hlt : -2 * p.1 - 2 * p.2.1 + 3 * p.2.2 < p.2.2 :=
    parent_hyp_lt p.1 p.2.1 p.2.2 h.fst_pos h.snd_pos h.pyth
  obtain ⟨k, hk⟩ := h.fst_odd
  rcases hpar with h1 | h1 | h1
  · refine ⟨.A, moveA' p, ?_, ?_, ?_⟩
    · have hpy := isPythag_moveA' p h.pyth
      refine ⟨hpy, h1.1, h1.2.1, h1.2.2, ?_, ⟨k + p.2.1 - p.2.2, ?_⟩⟩
      · exact parent_coprime hpy .A (by rw [applyStep_eq_moveA, moveA_moveA']) h.coprime
      · simp only [moveA', invA]; omega
    · simp only [moveA', invA]; omega
    · rw [applyStep_eq_moveA, moveA_moveA']
  · refine ⟨.B, moveB' p, ?_, ?_, ?_⟩
    · have hpy := isPythag_moveB' p h.pyth
      refine ⟨hpy, h1.1, h1.2.1, h1.2.2, ?_, ⟨k + p.2.1 - p.2.2, ?_⟩⟩
      · exact parent_coprime hpy .B (by rw [applyStep_eq_moveB, moveB_moveB']) h.coprime
      · simp only [moveB', invB]; omega
    · simp only [moveB', invB]; omega
    · rw [applyStep_eq_moveB, moveB_moveB']
  · refine ⟨.C, moveC' p, ?_, ?_, ?_⟩
    · have hpy := isPythag_moveC' p h.pyth
      refine ⟨hpy, h1.1, h1.2.1, h1.2.2, ?_, ⟨-k - p.2.1 + p.2.2 - 1, ?_⟩⟩
      · exact parent_coprime hpy .C (by rw [applyStep_eq_moveC, moveC_moveC']) h.coprime
      · simp only [moveC', invC]; omega
    · simp only [moveC', invC]; omega
    · rw [applyStep_eq_moveC, moveC_moveC']

/-! ## Coverage -/

/-- **Coverage (100 % seed-compressibility of primitive Pythagorean data).**
Every normalised primitive Pythagorean triple is emitted by the Berggren
generator from some control word. -/
theorem exists_path_of_treeTriple {p : ℤ × ℤ × ℤ} (h : TreeTriple p) :
    ∃ w : List BerggrenStep, applyPath w = p := by
  have key : ∀ n : ℕ, ∀ q : ℤ × ℤ × ℤ, TreeTriple q → q.2.2.toNat ≤ n →
      ∃ w : List BerggrenStep, applyPath w = q := by
    intro n
    induction n with
    | zero =>
        intro q hq hn
        have := hq.hyp_pos
        omega
    | succ n ih =>
        intro q hq hn
        by_cases hc : q.2.2 ≤ 5
        · exact ⟨[], by rw [applyPath_nil, treeTriple_eq_root_of_hyp_le_five hq hc]⟩
        · push_neg at hc
          obtain ⟨s, r, hr, hlt, hsr⟩ := descent hq hc
          have hrn : r.2.2.toNat ≤ n := by
            have := hr.hyp_pos
            omega
          obtain ⟨w, hw⟩ := ih r hr hrn
          exact ⟨w ++ [s], by rw [applyPath_concat, hw, hsr]⟩
  exact key p.2.2.toNat p h (le_refl _)

/-- **The Berggren path code is a bijection.**  A triple is emitted by the
generator iff it is a normalised primitive Pythagorean triple, and then the
control word — the seed — is unique. -/
theorem berggren_code_bijection (p : ℤ × ℤ × ℤ) :
    TreeTriple p ↔ ∃! w : List BerggrenStep, applyPath w = p := by
  constructor
  · intro h
    obtain ⟨w, hw⟩ := exists_path_of_treeTriple h
    exact ⟨w, hw, fun w' hw' => applyPath_injective (hw'.trans hw.symm)⟩
  · rintro ⟨w, hw, -⟩
    rw [← hw]
    exact applyPath_treeTriple w

/-- **Seed length is linear in the data.**  The control word recovered from a
normalised triple has length at most `(c-5)/4`, so the decoder halts after at
most that many rounds of sign tests. -/
theorem treeTriple_seed_length_bound {p : ℤ × ℤ × ℤ}
    {w : List BerggrenStep} (hw : applyPath w = p) : 4 * (w.length : ℤ) ≤ p.2.2 - 5 := by
  have := applyPath_length_bound w
  rw [hw] at this
  omega

/-- **Exact reproduction, end to end.**  For any normalised primitive triple, the
decoder recovers a seed which regenerates the triple exactly. -/
theorem treeTriple_seed_recovery {p : ℤ × ℤ × ℤ} (h : TreeTriple p) :
    ∃ w : List BerggrenStep, decodeSeed w.length p = w ∧ applyPath w = p := by
  obtain ⟨w, hw⟩ := exists_path_of_treeTriple h
  exact ⟨w, by rw [← hw, decodeSeed_applyPath], hw⟩

end Catalog.Pythagorean.BerggrenPRNG