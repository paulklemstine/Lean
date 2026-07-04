/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sidon sets: the difference kernel, its exact cardinality, and a sharp characterisation

A finite set of integers `s` is a **Sidon set** (a `B₂` set) when all of its
pairwise sums are distinct.  Companion catalog work analyses the *sum* kernel
`r⁺_s = 1_s * 1_s` (representation function, additive energy, sumset size).
This file develops the complementary **difference kernel** `r⁻_s(x) = #{(a,b) ∈
s² : a - b = x}`, i.e. the correlation `1_s ⋆ 1_s`.

The two convolution kernels `r⁺` and `r⁻` are the "multi-kernel" pair whose
combined support governs the additive structure of `s`.  For a Sidon set the
difference kernel is as *spread out* as possible: every nonzero difference is
attained exactly once, so the difference set `s - s` attains the maximal
possible cardinality `|s|² - |s| + 1` (the `|s|²-|s|` ordered pairs of distinct
elements, all distinct, together with `0`).  Conversely, attaining this maximum
*characterises* Sidon sets.

## Main results

* `sidon_diff_card` — for a nonempty Sidon set, `|s - s| + |s| = |s|² + 1`,
  i.e. `|s - s| = |s|² - |s| + 1`.
* `sidon_iff_diff_card` — a nonempty set is Sidon **iff** its difference set has
  the maximal cardinality `|s - s| + |s| = |s|² + 1`.

## Tags
Sidon set, B₂ set, difference set, correlation kernel, additive combinatorics

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).**  The classical Sidon theory pins down the *sum*
side: for a Sidon set `2|s+s| = |s|(|s|+1)`.  We conjectured a dual statement
for the *difference* kernel: since a Sidon set has all pairwise differences
distinct, the difference set should have the maximal cardinality
`|s-s| = |s|²-|s|+1`, and — more strongly — this maximum should *characterise*
Sidon sets.

**Experiment (Experimenter).**  Direct computation on the power-of-two Sidon set
`{1,2,4,8}` (|s|=4): `|s+s| = 10`, `|s-s| = 13 = 16-4+1` ✓, while the
non-Sidon `{1,2,3,4}` gives `|s-s| = 7 < 13`.  The extremal gap confirmed the
"maximal difference set ⇔ Sidon" hypothesis.

**Analysis (Analyst).**  The whole phenomenon factors through a single
equivalence, `sidon_iff_diffMap_injOn`: `s` is Sidon iff the map `(a,b)↦a-b` is
injective on the off-diagonal.  From there the counts are pure `Finset`
bookkeeping (`card_image_of_injOn`, `offDiag_card`, `card_insert_of_notMem`).
Injectivity failed on the *whole* square (the diagonal always collapses to `0`),
which is why the statements are phrased on `offDiag` and `s` must be nonempty
(the empty set is vacuously Sidon but has `|s-s| = 0 ≠ 1`).

**Critique (Critic).**  Neither theorem is vacuous: the reverse direction of
`sidon_iff_diff_card` genuinely recovers the Sidon property from a cardinality
equation, and the proofs use `card_image_iff`, `offDiag_card` and `omega`, not
`decide`/`native_decide`.  The nonemptiness hypothesis is load-bearing and
minimal.

**Synthesis (PI).**  The difference kernel yields an exact cardinality *and* a
new characterisation, dual to the known sum-kernel results, and feeds the
sum/difference "multi-kernel" identity in `MultiKernelLaw.lean`.
-- !-- Lab Notes -- !--
-/
import Mathlib

open Finset
open scoped Pointwise

namespace Catalog.Novelty.SidonMultiKernel

/-- A finite set of integers is **Sidon** (a `B₂` set) if all pairwise sums are
distinct: whenever `a + b = c + d` with all four in `s`, then `a = c` or
`a = d`. -/
def IsSidon (s : Finset ℤ) : Prop :=
  ∀ a ∈ s, ∀ b ∈ s, ∀ c ∈ s, ∀ d ∈ s, a + b = c + d → a = c ∨ a = d

/-- The ordered-difference map `(a,b) ↦ a - b`. -/
def diffMap (p : ℤ × ℤ) : ℤ := p.1 - p.2

/-- On the off-diagonal, the difference map never vanishes. -/
lemma diffMap_ne_zero_of_mem_offDiag {s : Finset ℤ} {p : ℤ × ℤ}
    (hp : p ∈ s.offDiag) : diffMap p ≠ 0 := by
  rw [Finset.mem_offDiag] at hp
  simpa [diffMap, sub_eq_zero] using hp.2.2

/-- `0` is not attained by the difference map on the off-diagonal. -/
lemma zero_not_mem_offDiag_image (s : Finset ℤ) :
    (0 : ℤ) ∉ s.offDiag.image diffMap := by
  simp only [Finset.mem_image, not_exists, not_and]
  intro p hp
  exact diffMap_ne_zero_of_mem_offDiag hp

/-- The difference set is `0` together with the image of the off-diagonal under
the difference map (valid for any nonempty set). -/
lemma sub_eq_insert_zero_image (s : Finset ℤ) (hne : s.Nonempty) :
    s - s = insert 0 (s.offDiag.image diffMap) := by
  ext x
  simp only [Finset.mem_sub, Finset.mem_insert, Finset.mem_image, Finset.mem_offDiag, diffMap]
  constructor
  · rintro ⟨a, ha, b, hb, rfl⟩
    by_cases hab : a = b
    · subst hab; left; ring
    · right; exact ⟨(a, b), ⟨ha, hb, hab⟩, rfl⟩
  · rintro (rfl | ⟨⟨a, b⟩, ⟨ha, hb, hab⟩, rfl⟩)
    · obtain ⟨c, hc⟩ := hne; exact ⟨c, hc, c, hc, by ring⟩
    · exact ⟨a, ha, b, hb, rfl⟩

/-- **Key equivalence.** A set is Sidon iff the difference map is injective on
its off-diagonal. -/
lemma sidon_iff_diffMap_injOn (s : Finset ℤ) :
    IsSidon s ↔ Set.InjOn diffMap (s.offDiag : Set (ℤ × ℤ)) := by
  constructor
  · intro hs p hp q hq hpq
    rw [Finset.mem_coe, Finset.mem_offDiag] at hp hq
    obtain ⟨hp1, hp2, hpne⟩ := hp
    obtain ⟨hq1, hq2, hqne⟩ := hq
    simp only [diffMap] at hpq
    have key : p.1 + q.2 = p.2 + q.1 := by linarith
    rcases hs p.1 hp1 q.2 hq2 p.2 hp2 q.1 hq1 key with h | h
    · exact absurd h hpne
    · have : p.2 = q.2 := by linarith
      exact Prod.ext h this
  · intro hinj a ha b hb c hc d hd hsum
    by_cases had : a = d
    · exact Or.inr had
    · by_cases hcb : c = b
      · right; linarith
      · left
        have hp : (a, d) ∈ (s.offDiag : Set (ℤ × ℤ)) := by
          rw [Finset.mem_coe, Finset.mem_offDiag]; exact ⟨ha, hd, had⟩
        have hq : (c, b) ∈ (s.offDiag : Set (ℤ × ℤ)) := by
          rw [Finset.mem_coe, Finset.mem_offDiag]; exact ⟨hc, hb, hcb⟩
        have hd2 : diffMap (a, d) = diffMap (c, b) := by
          simp only [diffMap]; linarith
        have := hinj hp hq hd2
        exact (Prod.ext_iff.mp this).1

/-- Cardinality of the difference set as `|off-diagonal image| + 1`. -/
lemma sub_card_eq (s : Finset ℤ) (hne : s.Nonempty) :
    (s - s).card = (s.offDiag.image diffMap).card + 1 := by
  rw [sub_eq_insert_zero_image s hne,
    Finset.card_insert_of_notMem (zero_not_mem_offDiag_image s)]

/-- **Main Theorem 1.**  For a nonempty Sidon set, the difference set attains its
maximal size: `|s - s| + |s| = |s|² + 1`, equivalently `|s - s| = |s|² - |s| +
1`.  Every nonzero difference is represented exactly once. -/
theorem sidon_diff_card (s : Finset ℤ) (hs : IsSidon s) (hne : s.Nonempty) :
    (s - s).card + s.card = s.card ^ 2 + 1 := by
  have hinj := (sidon_iff_diffMap_injOn s).mp hs
  have h1 := sub_card_eq s hne
  have h2 : (s.offDiag.image diffMap).card = s.offDiag.card :=
    Finset.card_image_of_injOn hinj
  have h3 : s.offDiag.card = s.card * s.card - s.card := Finset.offDiag_card s
  have hkK : s.card ≤ s.card * s.card :=
    Nat.le_mul_of_pos_left _ (Finset.card_pos.mpr hne)
  rw [h1, h2, h3, pow_two]
  omega

/-- **Main Theorem 2.**  A nonempty finite set of integers is Sidon **iff** its
difference set has the maximal possible cardinality `|s - s| + |s| = |s|² + 1`.
The maximal-difference-set property is thus an exact characterisation of the
Sidon condition. -/
theorem sidon_iff_diff_card (s : Finset ℤ) (hne : s.Nonempty) :
    IsSidon s ↔ (s - s).card + s.card = s.card ^ 2 + 1 := by
  constructor
  · intro hs; exact sidon_diff_card s hs hne
  · intro hcard
    rw [sidon_iff_diffMap_injOn]
    have h1 := sub_card_eq s hne
    have h3 : s.offDiag.card = s.card * s.card - s.card := Finset.offDiag_card s
    have hkK : s.card ≤ s.card * s.card :=
      Nat.le_mul_of_pos_left _ (Finset.card_pos.mpr hne)
    have himg : (s.offDiag.image diffMap).card = s.offDiag.card := by
      rw [h3]; rw [pow_two] at hcard; omega
    exact Finset.card_image_iff.mp himg

end Catalog.Novelty.SidonMultiKernel