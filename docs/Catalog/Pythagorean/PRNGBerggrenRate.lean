import Mathlib
import Pythagorean.PRNGBerggrenCoverage

/-!
# Cycle 4: how *good* is the seed code?  A branch-dependent dichotomy

Coverage (`Pythagorean.PRNGBerggrenCoverage`) says every normalised primitive
Pythagorean triple is generator output, so the qualitative answer to
"is this data seed-compressible?" is *always yes*.  That makes the quantitative
question the sharp one: **how long is the seed compared with the data?**

The answer proved here is a dichotomy, and it is not the optimistic one.

* Along the `B`-branch the hypotenuse grows at least like `5·3ᵏ`
  (`hyp_pureB_ge`), so a control word of length `k` encodes a number of size
  `≥ 3ᵏ`: the seed is *logarithmic* in the data, genuine compression.
* Along the `A`-branch the hypotenuse is only quadratic, `2k²+6k+5`
  (`hyp_pureA`), so the seed is of size `≈ √(c/2)`: **exponentially longer** than
  simply writing the triple in binary.  Seed compression *loses* on that branch.
* No branch does better than logarithmic: every step multiplies the hypotenuse
  by at most `7` (`hyp_le_seven_pow`), so `|w| ≥ log₇(c/5)`; a Berggren seed can
  never be asymptotically shorter than the binary encoding of the data.

`seed_rate_dichotomy` states the contrast in one theorem.  The moral for the
wider programme: *detecting* PRNG structure is not the same as *profiting* from
it — the profit is controlled by the spectral radius of the driving matrix
(`3+2√2` for `B`, `1` for the unipotent branches).
-/

namespace Catalog.Pythagorean.BerggrenPRNG

open Catalog.Probability.SeedRec BerggrenGroupoid

/-! ## Constant control words are iterations -/

theorem applyWordFrom_replicate (s : BerggrenStep) (k : ℕ) (p : ℤ × ℤ × ℤ) :
    applyWordFrom (List.replicate k s) p = (applyStep s)^[k] p := by
  induction k generalizing p with
  | zero => simp
  | succ k ih =>
      rw [List.replicate_succ, applyWordFrom_cons, ih, Function.iterate_succ_apply]

theorem applyPath_replicate (s : BerggrenStep) (k : ℕ) :
    applyPath (List.replicate k s) = (applyStep s)^[k] (3, 4, 5) :=
  applyWordFrom_replicate s k (3, 4, 5)

/-! ## The unipotent branch: quadratic data, square-root seeds -/

/-- The all-`A` control word of length `k` emits a triple with hypotenuse exactly
`2k² + 6k + 5`. -/
theorem hyp_pureA (k : ℕ) :
    (applyPath (List.replicate k .A)).2.2 = 2 * (k : ℤ) ^ 2 + 6 * k + 5 := by
  rw [applyPath_replicate]
  have hstep : (applyStep BerggrenStep.A)^[k] (3, 4, 5) = moveA^[k] (3, 4, 5) := by
    have : (applyStep BerggrenStep.A) = moveA := funext fun p => applyStep_eq_moveA p
    rw [this]
  rw [hstep, orbitA_root_closed_form]

/-- **No compression on the unipotent branch.**  The `A`-seed of length `k`
describes a hypotenuse of size at most `2(k+2)²`, i.e. the seed has length at
least `√(c/2) - 2`: it is polynomially, not logarithmically, long. -/
theorem pureA_seed_is_long (k : ℕ) :
    (applyPath (List.replicate k .A)).2.2 ≤ 2 * ((k : ℤ) + 2) ^ 2 := by
  rw [hyp_pureA]
  nlinarith [Int.natCast_nonneg k]

/-! ## The Pell branch: exponential data, logarithmic seeds -/

/-- Each `B`-step at least triples the hypotenuse. -/
theorem hyp_grow_B {p : ℤ × ℤ × ℤ} (h : GoodTriple p) :
    3 * p.2.2 ≤ (applyStep .B p).2.2 := by
  have ha := h.fst_pos
  have hb := h.snd_pos
  obtain ⟨a, b, c⟩ := p
  simp only at ha hb
  simp only [applyStep, bergB]
  omega

/-- **Genuine compression on the Pell branch.**  The all-`B` control word of
length `k` emits a hypotenuse of size at least `5·3ᵏ`, so the seed is
logarithmic in the data. -/
theorem hyp_pureB_ge (k : ℕ) :
    5 * 3 ^ k ≤ (applyPath (List.replicate k .B)).2.2 := by
  induction k with
  | zero => norm_num
  | succ k ih =>
      have hgood : GoodTriple (applyPath (List.replicate k BerggrenStep.B)) :=
        (applyPath_treeTriple _).good
      have hstep := hyp_grow_B hgood
      have hrep : (List.replicate (k + 1) BerggrenStep.B) =
          List.replicate k BerggrenStep.B ++ [BerggrenStep.B] := by
        simp [List.replicate_succ']
      rw [hrep, applyPath_concat]
      calc (5 : ℤ) * 3 ^ (k + 1) = 3 * (5 * 3 ^ k) := by ring
        _ ≤ 3 * (applyPath (List.replicate k BerggrenStep.B)).2.2 := by omega
        _ ≤ _ := hstep

/-! ## No branch beats the logarithm -/

/-- One Berggren step multiplies the hypotenuse by at most `7`. -/
theorem hyp_le_seven_mul {p : ℤ × ℤ × ℤ} (h : GoodTriple p) (s : BerggrenStep) :
    (applyStep s p).2.2 ≤ 7 * p.2.2 := by
  have hac := h.fst_lt_hyp
  have hbc := h.snd_lt_hyp
  have ha := h.fst_pos
  have hb := h.snd_pos
  obtain ⟨a, b, c⟩ := p
  simp only at hac hbc ha hb
  cases s <;> simp only [applyStep, bergA, bergB, bergC] <;> omega

/-- **A seed can never be shorter than logarithmic.**  A control word of length
`k` emits a hypotenuse of at most `5·7ᵏ`, so `k ≥ log₇(c/5)`: the Berggren code
never beats the binary encoding of the data by more than a constant factor. -/
theorem hyp_le_seven_pow (w : List BerggrenStep) :
    (applyPath w).2.2 ≤ 5 * 7 ^ w.length := by
  induction w using List.reverseRecOn with
  | nil => norm_num
  | append_singleton u s ih =>
      have hgood : GoodTriple (applyPath u) := (applyPath_treeTriple u).good
      have hstep := hyp_le_seven_mul hgood s
      rw [applyPath_concat]
      have hlen : ((u ++ [s]).length : ℕ) = u.length + 1 := by simp
      rw [hlen]
      calc (applyStep s (applyPath u)).2.2 ≤ 7 * (applyPath u).2.2 := hstep
        _ ≤ 7 * (5 * 7 ^ u.length) := by omega
        _ = 5 * 7 ^ (u.length + 1) := by ring

/-! ## The dichotomy -/

/-- **Seed-compression rate dichotomy.**  For every length `k`, the `B`-branch
emits data exponentially large in the seed length while the `A`-branch emits data
only quadratically large: whether "recover the seed" is a *win* depends on the
branch, not on the detectability, which is uniform (order-3 LFSR in both cases). -/
theorem seed_rate_dichotomy (k : ℕ) :
    5 * 3 ^ k ≤ (applyPath (List.replicate k .B)).2.2 ∧
      (applyPath (List.replicate k .A)).2.2 ≤ 2 * ((k : ℤ) + 2) ^ 2 :=
  ⟨hyp_pureB_ge k, pureA_seed_is_long k⟩

/-- Concretely at `k = 10`: the `B`-seed of ten trits (≈16 bits) describes a
hypotenuse of at least `295245`, whereas ten `A`-trits describe only `265`. -/
theorem seed_rate_dichotomy_ten :
    295245 ≤ (applyPath (List.replicate 10 .B)).2.2 ∧
      (applyPath (List.replicate 10 .A)).2.2 = 265 := by
  refine ⟨?_, ?_⟩
  · have := hyp_pureB_ge 10
    norm_num at this ⊢
    omega
  · rw [hyp_pureA]
    norm_num

end Catalog.Pythagorean.BerggrenPRNG