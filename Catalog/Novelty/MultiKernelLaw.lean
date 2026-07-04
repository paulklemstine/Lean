/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sidon sets: the sum/difference multi-kernel conservation law

For a finite set `s ⊆ ℤ` there are two elementary vector-valued convolution
kernels attached to it: the **sum kernel** `r⁺_s(x) = #{(a,b) ∈ s² : a+b = x}`
(the self-convolution `1_s * 1_s`, supported on the sumset `s + s`) and the
**difference kernel** `r⁻_s(x) = #{(a,b) ∈ s² : a-b = x}` (the correlation
`1_s ⋆ 1_s`, supported on the difference set `s - s`).  The "multi-kernel
smoothing" programme studies weighted combinations of such kernels; the coarsest
invariant of any such combination is the size of the *support* of each kernel.

This file proves the two exact support counts for a Sidon set and combines them
into a single **conservation law** relating the two kernels:

`2·|s + s| = |s - s| + 2·|s| - 1`.

Equivalently `2·|s+s| = |s-s| + 2|s| - 1`: the doubled sum-kernel support equals
the difference-kernel support plus `2|s| - 1`.  Both support sizes are
`Θ(|s|²)`, but the difference kernel is *twice as spread out* per element as the
(unordered) sum kernel, and the deficit is exactly the linear term `2|s| - 1`
coming from the diagonal (`0` for differences, the `|s|` "doubles" `2a` for
sums).

## Main result

* `sidon_sum_diff_law` — for a nonempty Sidon set,
  `2·|s + s| = |s - s| + 2·|s| - 1`.

Auxiliary (self-contained) counts proved en route:

* `sidon_sum_card` — `2·|s + s| = |s|·(|s| + 1)` (the sum kernel support).
* `sidon_diff_card` — `|s - s| + |s| = |s|² + 1` (the difference kernel support).

## Tags
Sidon set, B₂ set, sumset, difference set, convolution kernel, conservation law

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).**  Given the exact sum-kernel support
`2|s+s| = |s|(|s|+1)` and the difference-kernel support `|s-s| = |s|²-|s|+1`,
we conjectured a *single* closed identity linking the two kernels with no leftover
error term.  Eliminating `|s|²` between the two counts predicts
`2|s+s| = |s-s| + 2|s| - 1`.

**Experiment (Experimenter).**  On `{1,2,4,8}` (|s|=4): `2·|s+s| = 2·10 = 20`
and `|s-s| + 2|s| - 1 = 13 + 8 - 1 = 20` ✓.  On `{1,2,4,8,16}` (|s|=5, still
Sidon): `2·15 = 30 = 21 + 10 - 1` ✓.  The identity held on every Sidon sample.

**Analysis (Analyst).**  The sum count is proved by the "ordered pair with
`a ≤ b`" injection: `p ↦ a+b` is injective on `{(a,b) : a ≤ b}` and surjects onto
`s+s`, and the cardinality of that half-square is `(|s|²+|s|)/2` via a
swap-involution inclusion–exclusion (`card_union_add_card_inter`).  The
difference count reuses the off-diagonal injection.  Combining the two is then a
purely arithmetic elimination (`omega`) once `|s|·(|s|+1)` is expanded by `ring`.

**Critique (Critic).**  The law is not a definitional triviality: both support
counts genuinely require the Sidon hypothesis — for the non-Sidon `{1,2,3,4}`
one has `|s-s| = 7 ≠ 13 = |s|²-|s|+1` and `2|s+s| = 14 ≠ 20 = |s|(|s|+1)`, so the
individual kernel counts break, and the proof uses injectivity-from-Sidon plus
`omega` arithmetic, never `decide`/`native_decide`.  Nonemptiness is load-bearing
for the `-1` (the empty set gives `0 ≠ 0 + 0 - 1`).

**Synthesis (PI).**  The two convolution kernels obey an exact linear
conservation law; the `2:1` ratio of their supports is the rigorous shadow of the
"L² energy distributed across kernels" heuristic.
-- !-- Lab Notes -- !--
-/
import Mathlib

open Finset
open scoped Pointwise

namespace Catalog.Novelty.SidonMultiKernel.MultiKernelLaw

/-- A finite set of integers is **Sidon** (a `B₂` set) if all pairwise sums are
distinct. -/
def IsSidon (s : Finset ℤ) : Prop :=
  ∀ a ∈ s, ∀ b ∈ s, ∀ c ∈ s, ∀ d ∈ s, a + b = c + d → a = c ∨ a = d

/-- The ordered-sum map `(a,b) ↦ a + b`. -/
def sumMap (p : ℤ × ℤ) : ℤ := p.1 + p.2

/-- The ordered-difference map `(a,b) ↦ a - b`. -/
def diffMap (p : ℤ × ℤ) : ℤ := p.1 - p.2

/-! ### The difference kernel support -/

lemma zero_not_mem_offDiag_image (s : Finset ℤ) :
    (0 : ℤ) ∉ s.offDiag.image diffMap := by
  simp only [Finset.mem_image, not_exists, not_and]
  intro p hp
  rw [Finset.mem_offDiag] at hp
  simpa [diffMap, sub_eq_zero] using hp.2.2

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

lemma diffMap_injOn (s : Finset ℤ) (hs : IsSidon s) :
    Set.InjOn diffMap (s.offDiag : Set (ℤ × ℤ)) := by
  intro p hp q hq hpq
  rw [Finset.mem_coe, Finset.mem_offDiag] at hp hq
  obtain ⟨hp1, hp2, hpne⟩ := hp
  obtain ⟨hq1, hq2, hqne⟩ := hq
  simp only [diffMap] at hpq
  have key : p.1 + q.2 = p.2 + q.1 := by linarith
  rcases hs p.1 hp1 q.2 hq2 p.2 hp2 q.1 hq1 key with h | h
  · exact absurd h hpne
  · exact Prod.ext h (by omega)

/-- The difference kernel support: `|s - s| + |s| = |s|² + 1`. -/
lemma sidon_diff_card (s : Finset ℤ) (hs : IsSidon s) (hne : s.Nonempty) :
    (s - s).card + s.card = s.card ^ 2 + 1 := by
  have h1 : (s - s).card = (s.offDiag.image diffMap).card + 1 := by
    rw [sub_eq_insert_zero_image s hne,
      Finset.card_insert_of_notMem (zero_not_mem_offDiag_image s)]
  have h2 : (s.offDiag.image diffMap).card = s.offDiag.card :=
    Finset.card_image_of_injOn (diffMap_injOn s hs)
  have h3 : s.offDiag.card = s.card * s.card - s.card := Finset.offDiag_card s
  have hkK : s.card ≤ s.card * s.card :=
    Nat.le_mul_of_pos_left _ (Finset.card_pos.mpr hne)
  rw [h1, h2, h3, pow_two]; omega

/-! ### The sum kernel support -/

/-- Half the square (`a ≤ b`) has `2·|·| = |s|² + |s|` elements. -/
lemma half_square_card (s : Finset ℤ) :
    2 * ((s ×ˢ s).filter (fun p => p.1 ≤ p.2)).card = s.card * s.card + s.card := by
  set L := (s ×ˢ s).filter (fun p : ℤ × ℤ => p.1 ≤ p.2) with hL
  set L' := (s ×ˢ s).filter (fun p : ℤ × ℤ => p.2 ≤ p.1) with hL'
  have hunion : L ∪ L' = s ×ˢ s := by
    ext p; simp only [hL, hL', Finset.mem_union, Finset.mem_filter]
    constructor
    · rintro (⟨h, _⟩ | ⟨h, _⟩) <;> exact h
    · intro h; rcases le_total p.1 p.2 with hle | hle
      · exact Or.inl ⟨h, hle⟩
      · exact Or.inr ⟨h, hle⟩
  have hinter : L ∩ L' = (s ×ˢ s).filter (fun p : ℤ × ℤ => p.1 = p.2) := by
    ext p; simp only [hL, hL', Finset.mem_inter, Finset.mem_filter]
    constructor
    · rintro ⟨⟨h, h1⟩, ⟨_, h2⟩⟩; exact ⟨h, le_antisymm h1 h2⟩
    · rintro ⟨h, he⟩; exact ⟨⟨h, he.le⟩, ⟨h, he.ge⟩⟩
  have hswap : L'.card = L.card := by
    apply Finset.card_bij (fun p _ => (p.2, p.1))
    · rintro ⟨a, b⟩ hp; simp only [hL', hL, Finset.mem_filter, Finset.mem_product] at *
      exact ⟨⟨hp.1.2, hp.1.1⟩, hp.2⟩
    · rintro ⟨a, b⟩ hp ⟨c, d⟩ hq h; simp only [Prod.mk.injEq] at h; ext <;> simp [h.1, h.2]
    · rintro ⟨a, b⟩ hp; refine ⟨(b, a), ?_, rfl⟩
      simp only [hL, hL', Finset.mem_filter, Finset.mem_product] at *
      exact ⟨⟨hp.1.2, hp.1.1⟩, hp.2⟩
  have hdiag : ((s ×ˢ s).filter (fun p : ℤ × ℤ => p.1 = p.2)).card = s.card := by
    apply Finset.card_bij (fun p _ => p.1)
    · rintro ⟨a, b⟩ hp; simp only [Finset.mem_filter, Finset.mem_product] at hp; exact hp.1.1
    · rintro ⟨a, b⟩ hp ⟨c, d⟩ hq h
      simp only [Finset.mem_filter, Finset.mem_product] at hp hq
      simp only at h; ext
      · exact h
      · rw [← hp.2, ← hq.2, h]
    · intro a ha; refine ⟨(a, a), ?_, rfl⟩; simp [ha]
  have key := Finset.card_union_add_card_inter L L'
  rw [hunion, hinter, hdiag, hswap, Finset.card_product] at key
  omega

lemma sum_image_eq (s : Finset ℤ) :
    ((s ×ˢ s).filter (fun p => p.1 ≤ p.2)).image sumMap = s + s := by
  ext x
  simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_product, Finset.mem_add, sumMap]
  constructor
  · rintro ⟨⟨a, b⟩, ⟨⟨ha, hb⟩, _⟩, rfl⟩; exact ⟨a, ha, b, hb, rfl⟩
  · rintro ⟨a, ha, b, hb, rfl⟩
    rcases le_total a b with hle | hle
    · exact ⟨(a, b), ⟨⟨ha, hb⟩, hle⟩, rfl⟩
    · exact ⟨(b, a), ⟨⟨hb, ha⟩, hle⟩, by simp [add_comm]⟩

lemma sumMap_injOn (s : Finset ℤ) (hs : IsSidon s) :
    Set.InjOn sumMap (((s ×ˢ s).filter (fun p => p.1 ≤ p.2)) : Set (ℤ × ℤ)) := by
  intro p hp q hq hpq
  rw [Finset.mem_coe, Finset.mem_filter, Finset.mem_product] at hp hq
  obtain ⟨⟨hp1, hp2⟩, hple⟩ := hp
  obtain ⟨⟨hq1, hq2⟩, hqle⟩ := hq
  simp only [sumMap] at hpq
  rcases hs p.1 hp1 p.2 hp2 q.1 hq1 q.2 hq2 hpq with h | h
  · exact Prod.ext h (by omega)
  · exact Prod.ext (by omega) (by omega)

/-- The sum kernel support: `2·|s + s| = |s|·(|s| + 1)`. -/
lemma sidon_sum_card (s : Finset ℤ) (hs : IsSidon s) :
    2 * (s + s).card = s.card * (s.card + 1) := by
  have hcard : (s + s).card = ((s ×ˢ s).filter (fun p => p.1 ≤ p.2)).card := by
    rw [← sum_image_eq s, Finset.card_image_of_injOn (sumMap_injOn s hs)]
  rw [hcard, mul_add, mul_one, half_square_card s]

/-! ### The conservation law -/

/-- **Main Theorem 3.**  The sum/difference multi-kernel conservation law: for a
nonempty Sidon set, `2·|s + s| = |s - s| + 2·|s| - 1`.  The doubled sum-kernel
support and the difference-kernel support differ by exactly the linear diagonal
term `2·|s| - 1`. -/
theorem sidon_sum_diff_law (s : Finset ℤ) (hs : IsSidon s) (hne : s.Nonempty) :
    2 * (s + s).card = (s - s).card + 2 * s.card - 1 := by
  have hsum := sidon_sum_card s hs
  have hdiff := sidon_diff_card s hs hne
  have hk : 1 ≤ s.card := Finset.card_pos.mpr hne
  have hmul : s.card * (s.card + 1) = s.card * s.card + s.card := by ring
  rw [hmul] at hsum
  rw [pow_two] at hdiff
  omega

end Catalog.Novelty.SidonMultiKernel.MultiKernelLaw