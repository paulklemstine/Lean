/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Davenport constant of a cyclic group is its order

Specialising the kernel-cover framework of `Core.lean` to the singleton weight
set `W = {id}` on the cyclic group `ℤ/m`, the kernel-cover property at level `n`
is exactly the classical Davenport condition (`kernelCover_id_iff`): every
length-`n` sequence in `ℤ/m` has a nonempty zero-sum subsequence.

The headline result `davenport_zmod` shows that the least such `n` — the
Davenport constant `D(ℤ/m)` — is exactly `m`:

* **Upper bound** (`hasZeroSumSub_zmod`): every length-`m` sequence in `ℤ/m`
  has a nonempty zero-sum subsequence.  Proof by the pigeonhole principle on the
  `m + 1` partial sums `s₀, …, s_m ∈ ℤ/m`.
* **Lower bound** (`not_hasZeroSumSub_zmod`): the constant sequence `(1, …, 1)`
  of length `m - 1` has no nonempty zero-sum subsequence, since every nonempty
  subset sums to `|S|` with `0 < |S| < m`.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): `D(ℤ/m) = m` should drop out of the kernel-cover
--   framework via the `{id}` weight set — a sanity check that the abstract
--   definition recovers the classical Davenport constant of a cyclic group.
-- Experiment (Experimenter): computed small cases.  m = 2: sequences of length
--   2 over ℤ/2 always contain a zero-sum subsequence (0 alone, or 1+1); the
--   length-1 sequence (1) does not.  m = 3: (1,1) has no zero-sum subsequence,
--   but any length-3 sequence does.  Pattern: threshold = m.
-- Analysis (Analyst): the upper bound is a genuine pigeonhole argument on
--   partial sums (`Fintype.exists_ne_map_eq_of_card_lt`, m+1 sums into an
--   m-element group); the lower bound uses `ZMod.natCast_zmod_eq_zero_iff_dvd`
--   applied to `0 < |S| < m`.  Neither is `decide`/`rfl`.
-- Critique (Critic): the statement is packaged as `IsLeast`, so it pins the
--   Davenport constant EXACTLY (both bounds), not just an inequality.  Requires
--   `2 ≤ m` so that `ℤ/m` is nontrivial (`id ≠ 0`) — for m = 1 the group is
--   trivial and no valid (nonzero) weight exists.
-- Synthesis: the kernel-cover reformulation is faithful and recovers the
--   classical `D(ℤ/m) = m`, confirming the conjecture on the cyclic base case.
-/
import Algebra.WeightedDavenport.Core

open scoped BigOperators

namespace WeightedDavenport

/-
**Upper bound (pigeonhole).** Every length-`m` sequence in `ℤ/m` has a
nonempty zero-sum subsequence.
-/
theorem hasZeroSumSub_zmod (m : ℕ) [NeZero m] (x : Fin m → ZMod m) :
    HasZeroSumSub x := by
  -- Define the m+1 partial sums s : Fin (m+1) → ZMod m by s j = ∑ i ∈ Finset.univ.filter (fun i : Fin m => (i:ℕ) < (j:ℕ)), x i.
  set s : Fin (m + 1) → ZMod m := fun j => ∑ i ∈ Finset.univ.filter (fun i : Fin m => i.val < j.val), x i;
  obtain ⟨j₁, j₂, hj₁j₂, hs⟩ : ∃ j₁ j₂ : Fin (m + 1), j₁ < j₂ ∧ s j₁ = s j₂ := by
    by_contra! h;
    exact absurd ( Fintype.card_le_of_injective s fun j₁ j₂ hj => le_antisymm ( not_lt.mp fun contra => h _ _ contra hj.symm ) ( not_lt.mp fun contra => h _ _ contra hj ) ) ( by simp +decide );
  -- Take S = Finset.univ.filter (fun i : Fin m => (j₁:ℕ) ≤ (i:ℕ) ∧ (i:ℕ) < (j₂:ℕ)).
  use Finset.univ.filter (fun i : Fin m => j₁.val ≤ i.val ∧ i.val < j₂.val);
  have h_filter : Finset.filter (fun i : Fin m => i.val < j₂.val) Finset.univ = Finset.filter (fun i : Fin m => i.val < j₁.val) Finset.univ ∪ Finset.filter (fun i : Fin m => j₁.val ≤ i.val ∧ i.val < j₂.val) Finset.univ := by
    grind;
  simp +zetaDelta at *;
  exact ⟨ ⟨ ⟨ j₁, by linarith [ Fin.is_lt j₁, Fin.is_lt j₂, show ( j₁ : ℕ ) < j₂ from hj₁j₂ ] ⟩, by aesop ⟩, by rw [ h_filter, Finset.sum_union ( Finset.disjoint_right.mpr fun i hi => by aesop ) ] at hs; linear_combination' hs.symm ⟩

/-
**Lower bound.** The constant sequence `(1, …, 1)` of length `m - 1` in
`ℤ/m` has no nonempty zero-sum subsequence, so not every length-`(m-1)`
sequence has one.
-/
theorem not_hasZeroSumSub_zmod (m : ℕ) [NeZero m] :
    ¬ ∀ x : Fin (m - 1) → ZMod m, HasZeroSumSub x := by
  by_contra! h_contra;
  obtain ⟨ S, hS₁, hS₂ ⟩ := h_contra ( fun _ => 1 );
  simp_all +decide;
  rw [ ZMod.natCast_eq_zero_iff ] at hS₂ ; exact Nat.not_dvd_of_pos_of_lt ( Finset.card_pos.mpr hS₁ ) ( lt_of_le_of_lt ( Finset.card_le_univ _ ) ( by simpa using Nat.sub_lt ( NeZero.pos m ) zero_lt_one ) ) hS₂

/-- **The Davenport constant of `ℤ/m` is `m`.** In the kernel-cover framework
with weight set `{id}`, the least length at which the kernels of the induced
universal homomorphisms cover `(ℤ/m)^n` is exactly `m`. -/
theorem davenport_zmod (m : ℕ) (hm : 2 ≤ m) :
    IsLeast {n | KernelCover ({AddMonoidHom.id (ZMod m)}) n} m := by
  haveI : NeZero m := ⟨by omega⟩
  haveI : Fact (1 < m) := ⟨by omega⟩
  haveI : Nontrivial (ZMod m) := ZMod.nontrivial m
  constructor
  · -- `m` has the property: length-`m` sequences always have a zero-sum subseq
    rw [Set.mem_setOf_eq, kernelCover_id_iff]
    exact hasZeroSumSub_zmod m
  · -- any `n` with the property satisfies `m ≤ n`
    intro n hn
    by_contra hlt
    push_neg at hlt
    have hle : n ≤ m - 1 := by omega
    have hcover : KernelCover ({AddMonoidHom.id (ZMod m)}) (m - 1) :=
      kernelCover_mono _ hle hn
    rw [kernelCover_id_iff] at hcover
    exact not_hasZeroSumSub_zmod m hcover

end WeightedDavenport