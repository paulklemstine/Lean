import Mathlib
import Pythagorean.PRNGBerggrenClassifier

/-!
# The Berggren path code: a uniquely decodable seed for Pythagorean data

Third instalment of the thread *"detect PRNG output and recover the seed"*.
`Pythagorean.PRNGBerggrenFingerprint` treats a **fixed** Berggren move iterated
from a seed triple; `Pythagorean.PRNGBerggrenClassifier` routes an observed file
to the right branch.  Here we treat the *full* generator: a ternary control word
`w ∈ {A,B,C}*` drives the Barning–Berggren tree from the root `(3,4,5)`, and the
word itself is the seed.

The three theorems that matter for the research gate are

* `applyPath_injective` — **unique decodability**: distinct control words produce
  distinct triples, so the code wastes nothing;
* `parentStep_applyStep` — **one-symbol seed recovery**: the last control symbol
  is recoverable from the *output alone*, by three sign tests;
* `decodeSeed_applyPath` — **exact seed recovery**: the decoder, run on the
  observed triple, returns the control word bit-for-bit.

Supporting results include `applyPath_good` (the generator never leaves the
positive null cone), `hyp_grow` (each step increases the hypotenuse by at least
`4`, giving the honest code-length bound `applyPath_length_bound`), and
`orbitA_root_closed_form`, the explicit quadratic benchmark family produced by
the all-`A` control word.
-/

namespace Catalog.Pythagorean.BerggrenPRNG

open Catalog.Probability.SeedRec BerggrenGroupoid

/-! ## Positivity is preserved by the generator -/

/-- A *good* triple: a Pythagorean triple in the strictly positive cone.  These
are the states the Berggren generator actually visits. -/
structure GoodTriple (p : ℤ × ℤ × ℤ) : Prop where
  pyth : IsPythag p.1 p.2.1 p.2.2
  fst_pos : 0 < p.1
  snd_pos : 0 < p.2.1
  hyp_pos : 0 < p.2.2

theorem GoodTriple.fst_lt_hyp {p : ℤ × ℤ × ℤ} (h : GoodTriple p) : p.1 < p.2.2 := by
  have hpy : p.1 ^ 2 + p.2.1 ^ 2 = p.2.2 ^ 2 := h.pyth
  nlinarith [h.fst_pos, h.snd_pos, h.hyp_pos]

theorem GoodTriple.snd_lt_hyp {p : ℤ × ℤ × ℤ} (h : GoodTriple p) : p.2.1 < p.2.2 := by
  have hpy : p.1 ^ 2 + p.2.1 ^ 2 = p.2.2 ^ 2 := h.pyth
  nlinarith [h.fst_pos, h.snd_pos, h.hyp_pos]

theorem applyStep_eq_moveA (p : ℤ × ℤ × ℤ) : applyStep .A p = moveA p := by
  obtain ⟨a, b, c⟩ := p; rfl

theorem applyStep_eq_moveB (p : ℤ × ℤ × ℤ) : applyStep .B p = moveB p := by
  obtain ⟨a, b, c⟩ := p; rfl

theorem applyStep_eq_moveC (p : ℤ × ℤ × ℤ) : applyStep .C p = moveC p := by
  obtain ⟨a, b, c⟩ := p; rfl

/-- Every Berggren step maps good triples to good triples: the generator stays in
the positive null cone forever. -/
theorem applyStep_good {p : ℤ × ℤ × ℤ} (h : GoodTriple p) (s : BerggrenStep) :
    GoodTriple (applyStep s p) := by
  have hab := h.fst_lt_hyp
  have hbc := h.snd_lt_hyp
  have ha := h.fst_pos
  have hb := h.snd_pos
  obtain ⟨a, b, c⟩ := p
  simp only at hab hbc ha hb
  cases s
  · exact ⟨bergA_pyth a b c h.pyth, by simp only [applyStep, bergA]; omega,
      by simp only [applyStep, bergA]; omega, by simp only [applyStep, bergA]; omega⟩
  · exact ⟨bergB_pyth a b c h.pyth, by simp only [applyStep, bergB]; omega,
      by simp only [applyStep, bergB]; omega, by simp only [applyStep, bergB]; omega⟩
  · exact ⟨bergC_pyth a b c h.pyth, by simp only [applyStep, bergC]; omega,
      by simp only [applyStep, bergC]; omega, by simp only [applyStep, bergC]; omega⟩

theorem root_good : GoodTriple (3, 4, 5) :=
  ⟨by norm_num [IsPythag], by norm_num, by norm_num, by norm_num⟩

/-- Whatever the control word, the emitted triple is a positive Pythagorean
triple. -/
theorem applyPath_good (w : List BerggrenStep) : GoodTriple (applyPath w) := by
  induction w using List.reverseRecOn with
  | nil => exact root_good
  | append_singleton u s ih =>
      rw [applyPath_concat]
      exact applyStep_good ih s

/-! ## Growth of the hypotenuse and the code-length bound -/

/-- Each Berggren step increases the hypotenuse by at least `4`. -/
theorem hyp_grow {p : ℤ × ℤ × ℤ} (h : GoodTriple p) (s : BerggrenStep) :
    p.2.2 + 4 ≤ (applyStep s p).2.2 := by
  have hbc := h.snd_lt_hyp
  have hac := h.fst_lt_hyp
  have ha := h.fst_pos
  have hb := h.snd_pos
  obtain ⟨a, b, c⟩ := p
  simp only at hbc hac ha hb
  cases s <;> simp only [applyStep, bergA, bergB, bergC] <;> omega

/-- **Code-length bound.**  A control word of length `k` produces a triple whose
hypotenuse is at least `5 + 4k`; hence the seed length is bounded by the size of
the data it encodes, `k ≤ (c-5)/4`.  (Along the `B`-branch the growth is in fact
exponential — see `bergB_hypotenuse_pell` — while the unipotent branches grow
only quadratically, which is why no uniform exponential bound is available.) -/
theorem applyPath_length_bound (w : List BerggrenStep) :
    5 + 4 * (w.length : ℤ) ≤ (applyPath w).2.2 := by
  induction w using List.reverseRecOn with
  | nil => simp
  | append_singleton u s ih =>
      have hg := hyp_grow (applyPath_good u) s
      rw [applyPath_concat]
      simp only [List.length_append, List.length_cons, List.length_nil]
      push_cast
      omega

/-! ## Parent uniqueness: the last control symbol is recoverable -/

/-- Two different Berggren branches never produce the same triple from good
parents: `A` and `B` disagree. -/
theorem no_common_child_AB {p p' : ℤ × ℤ × ℤ} (hb : 0 < p.2.1) (hb' : 0 < p'.2.1)
    (h : moveA p = moveB p') : False := by
  obtain ⟨a, b, c⟩ := p
  obtain ⟨a', b', c'⟩ := p'
  simp only at hb hb'
  simp only [moveA, moveB, bergA, bergB, Prod.mk.injEq] at h
  omega

/-- `A` and `C` disagree. -/
theorem no_common_child_AC {p p' : ℤ × ℤ × ℤ} (ha : 0 < p.1) (ha' : 0 < p'.1)
    (h : moveA p = moveC p') : False := by
  obtain ⟨a, b, c⟩ := p
  obtain ⟨a', b', c'⟩ := p'
  simp only at ha ha'
  simp only [moveA, moveC, bergA, bergC, Prod.mk.injEq] at h
  omega

/-- `B` and `C` disagree. -/
theorem no_common_child_BC {p p' : ℤ × ℤ × ℤ} (ha : 0 < p.1) (ha' : 0 < p'.1)
    (h : moveB p = moveC p') : False := by
  obtain ⟨a, b, c⟩ := p
  obtain ⟨a', b', c'⟩ := p'
  simp only at ha ha'
  simp only [moveB, moveC, bergB, bergC, Prod.mk.injEq] at h
  omega

/-- Each Berggren move is injective, so the parent is determined by the child once
the branch is known. -/
theorem applyStep_injective (s : BerggrenStep) : Function.Injective (applyStep s) := by
  intro p p' h
  obtain ⟨a, b, c⟩ := p
  obtain ⟨a', b', c'⟩ := p'
  cases s <;>
    simp only [applyStep, bergA, bergB, bergC, Prod.mk.injEq] at h ⊢ <;>
    refine ⟨by omega, by omega, by omega⟩

/-- **Parent uniqueness.**  A triple has at most one good parent, reached by at
most one branch: the last symbol of the seed *and* the previous state are
uniquely determined by the observed output. -/
theorem step_unique_of_pos {p p' q : ℤ × ℤ × ℤ} (ha : 0 < p.1) (hb : 0 < p.2.1)
    (ha' : 0 < p'.1) (hb' : 0 < p'.2.1) {s s' : BerggrenStep}
    (h : applyStep s p = q) (h' : applyStep s' p' = q) : s = s' ∧ p = p' := by
  have key : s = s' := by
    cases s <;> cases s' <;>
      simp only [applyStep_eq_moveA, applyStep_eq_moveB, applyStep_eq_moveC] at h h' <;>
      first
        | rfl
        | exact (no_common_child_AB hb hb' (h.trans h'.symm)).elim
        | exact (no_common_child_AB hb' hb (h'.trans h.symm)).elim
        | exact (no_common_child_AC ha ha' (h.trans h'.symm)).elim
        | exact (no_common_child_AC ha' ha (h'.trans h.symm)).elim
        | exact (no_common_child_BC ha ha' (h.trans h'.symm)).elim
        | exact (no_common_child_BC ha' ha (h'.trans h.symm)).elim
  subst key
  exact ⟨rfl, applyStep_injective s (h.trans h'.symm)⟩

/-! ## Unique decodability of the path code -/

/-- **Unique decodability.**  Distinct control words emit distinct triples: the
Berggren path code is injective, so the seed carries no redundancy. -/
theorem applyPath_injective : Function.Injective applyPath := by
  have key : ∀ n : ℕ, ∀ w w' : List BerggrenStep, w.length ≤ n →
      applyPath w = applyPath w' → w = w' := by
    intro n
    induction n with
    | zero =>
        intro w w' hw h
        have hw0 : w = [] := List.length_eq_zero_iff.mp (Nat.le_zero.mp hw)
        subst hw0
        rcases List.eq_nil_or_concat w' with rfl | ⟨u', s', rfl⟩
        · rfl
        · exfalso
          simp only [List.concat_eq_append] at h
          have h1 := applyPath_length_bound (u' ++ [s'])
          rw [← h] at h1
          simp only [applyPath_nil, List.length_append, List.length_cons,
            List.length_nil] at h1
          push_cast at h1
          omega
    | succ n ih =>
        intro w w' hw h
        rcases List.eq_nil_or_concat w with rfl | ⟨u, s, rfl⟩
        · rcases List.eq_nil_or_concat w' with rfl | ⟨u', s', rfl⟩
          · rfl
          · exfalso
            simp only [List.concat_eq_append] at h
            have h1 := applyPath_length_bound (u' ++ [s'])
            rw [← h] at h1
            simp only [applyPath_nil, List.length_append, List.length_cons,
              List.length_nil] at h1
            push_cast at h1
            omega
        · simp only [List.concat_eq_append] at h hw ⊢
          rcases List.eq_nil_or_concat w' with rfl | ⟨u', s', rfl⟩
          · exfalso
            have h1 := applyPath_length_bound (u ++ [s])
            rw [h] at h1
            simp only [applyPath_nil, List.length_append, List.length_cons,
              List.length_nil] at h1
            push_cast at h1
            omega
          · simp only [List.concat_eq_append] at h ⊢
            rw [applyPath_concat, applyPath_concat] at h
            have hg := applyPath_good u
            have hg' := applyPath_good u'
            obtain ⟨hs, hp⟩ :=
              step_unique_of_pos hg.fst_pos hg.snd_pos hg'.fst_pos hg'.snd_pos rfl h.symm
            have hlen : u.length ≤ n := by
              simp only [List.length_append, List.length_cons, List.length_nil] at hw
              omega
            rw [ih u u' hlen hp, hs]
  intro w w' h
  exact key w.length w w' (le_refl _) h

/-! ## The decoder: recovering the seed from the data -/

/-- The three sign tests that identify which branch was taken last. -/
def parentStep (q : ℤ × ℤ × ℤ) : Option BerggrenStep :=
  if 0 < (moveA' q).1 ∧ 0 < (moveA' q).2.1 then some .A
  else if 0 < (moveB' q).1 ∧ 0 < (moveB' q).2.1 then some .B
  else if 0 < (moveC' q).1 ∧ 0 < (moveC' q).2.1 then some .C
  else none

/-- The recovered parent state. -/
def parentOf (q : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match parentStep q with
  | some .A => moveA' q
  | some .B => moveB' q
  | some .C => moveC' q
  | none => q

/-- **One-symbol seed recovery.**  From the emitted triple alone, three sign
tests recover the control symbol that produced it. -/
theorem parentStep_applyStep {p : ℤ × ℤ × ℤ} (ha : 0 < p.1) (hb : 0 < p.2.1)
    (s : BerggrenStep) : parentStep (applyStep s p) = some s := by
  obtain ⟨a, b, c⟩ := p
  simp only at ha hb
  cases s <;>
    simp only [applyStep, parentStep, moveA', moveB', moveC', invA, invB, invC,
      bergA, bergB, bergC]
  · rw [if_pos ⟨by omega, by omega⟩]
  · rw [if_neg (by rintro ⟨x, y⟩; omega), if_pos ⟨by omega, by omega⟩]
  · rw [if_neg (by rintro ⟨x, y⟩; omega), if_neg (by rintro ⟨x, y⟩; omega),
      if_pos ⟨by omega, by omega⟩]

/-- The recovered parent state is the true previous state. -/
theorem parentOf_applyStep {p : ℤ × ℤ × ℤ} (ha : 0 < p.1) (hb : 0 < p.2.1)
    (s : BerggrenStep) : parentOf (applyStep s p) = p := by
  have hs := parentStep_applyStep ha hb s
  cases s <;> simp only [parentOf, hs]
  · rw [applyStep_eq_moveA]; exact moveA'_moveA p
  · rw [applyStep_eq_moveB]; exact moveB'_moveB p
  · rw [applyStep_eq_moveC]; exact moveC'_moveC p

/-- The seed-recovery decoder: peel off control symbols until the fuel runs out
or no good parent exists. -/
def decodeSeed : ℕ → ℤ × ℤ × ℤ → List BerggrenStep
  | 0, _ => []
  | (n + 1), q =>
      match parentStep q with
      | none => []
      | some s => decodeSeed n (parentOf q) ++ [s]

/-- **Exact seed recovery (the falsifiability gate).**  Run on the emitted
triple, the decoder returns the control word *exactly*; consequently
`applyPath (decodeSeed w.length (applyPath w)) = applyPath w`, i.e. decompression
reproduces the data bit-for-bit. -/
theorem decodeSeed_applyPath (w : List BerggrenStep) :
    decodeSeed w.length (applyPath w) = w := by
  induction w using List.reverseRecOn with
  | nil => rfl
  | append_singleton u s ih =>
      have hg := applyPath_good u
      have hlen : (u ++ [s]).length = u.length + 1 := by simp
      rw [hlen, applyPath_concat]
      show (match parentStep (applyStep s (applyPath u)) with
            | none => []
            | some t => decodeSeed u.length (parentOf (applyStep s (applyPath u))) ++ [t]) = _
      rw [parentStep_applyStep hg.fst_pos hg.snd_pos s,
        parentOf_applyStep hg.fst_pos hg.snd_pos s, ih]

/-- Decompression reproduces the observed file exactly. -/
theorem applyPath_decodeSeed (w : List BerggrenStep) :
    applyPath (decodeSeed w.length (applyPath w)) = applyPath w := by
  rw [decodeSeed_applyPath]

/-! ## A benchmark family -/

/-- The all-`A` control word emits the classical quadratic family
`(2t+3, 2t²+6t+4, 2t²+6t+5)`: a file of `n` triples whose entire content is three
integers plus the length, and whose third difference vanishes identically. -/
theorem orbitA_root_closed_form (t : ℕ) :
    moveA^[t] (3, 4, 5) =
      (2 * (t : ℤ) + 3, 2 * (t : ℤ) ^ 2 + 6 * t + 4, 2 * (t : ℤ) ^ 2 + 6 * t + 5) := by
  rw [orbitA_closed_form]
  simp only [Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- The all-`C` control word emits the family `(4t²+8t+3, 4t+4, 4t²+8t+5)`. -/
theorem orbitC_root_closed_form (t : ℕ) :
    moveC^[t] (3, 4, 5) =
      (4 * (t : ℤ) ^ 2 + 8 * t + 3, 4 * (t : ℤ) + 4, 4 * (t : ℤ) ^ 2 + 8 * t + 5) := by
  rw [orbitC_closed_form]
  simp only [Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

end Catalog.Pythagorean.BerggrenPRNG