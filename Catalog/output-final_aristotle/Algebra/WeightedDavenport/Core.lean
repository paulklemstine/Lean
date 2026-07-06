/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Kernel-cover characterisation of the weighted Davenport constant

Let `F`, `G` be abelian groups and let `W` (playing the role of the weight set
`Ψ` in G. Wang, *Comm. Algebra* 2025) be a set of homomorphisms `F →+ G`.
Given a length-`n` choice function `φ : Fin n → (F →+ G)` we form the **induced
universal homomorphism**

  `Phi φ : (Fin n → F) →+ G`,   `Phi φ x = ∑ i, φ i (x i)`.

A choice is *valid* for `W` when every coordinate lies in `insert 0 W` (the `0`
homomorphism models *skipping* a coordinate, i.e. taking a subsequence) and at
least one coordinate is nonzero. The **kernel-cover property** `KernelCover W n`
asserts that the kernels of the valid induced universal homomorphisms cover the
whole of `F^n`:

  `∀ x : Fin n → F, ∃ φ, ValidChoice W φ ∧ Phi φ x = 0`.

The weighted Davenport constant `D_Ψ(G)` is then the least `n` with this
property, so `D_Ψ(G) ≤ n ↔ KernelCover W n`.

## Main results

* `kernelCover_iff_iUnion_ker` — the conjectured characterisation: the
  kernel-cover property holds **iff** the union of the kernels of the induced
  universal homomorphisms is all of `F^n`.
* `kernelCover_succ`, `kernelCover_mono` — the property is monotone in `n`
  (this is what makes "`D_Ψ(G) ≤ n`" a sensible threshold statement).
* `kernelCover_id_iff` — for the singleton weight set `{id}` on a nontrivial
  group the property specialises to the classical statement that every
  length-`n` sequence has a nonempty zero-sum subsequence.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Wang's kernel-cover reformulation of the weighted
--   Davenport constant is faithful, i.e. `D_Ψ(G) ≤ n` is EXACTLY the statement
--   that the kernels of the induced universal homs `F^n → G` cover `F^n`.
-- Experiment (Experimenter): modelled a "subsequence" by allowing the zero
--   homomorphism as a weight (`insert 0 W`) with a genuine nonzero coordinate.
--   Small cases: for `W = {id}` on `ℤ/m` the property at level `n` unfolds to
--   the classical zero-sum-subsequence Davenport condition (see `CyclicDavenport`).
-- Analysis (Analyst): the characterisation `kernelCover_iff_iUnion_ker` is a
--   genuine (non-`rfl`) translation between a pointwise existential and a set
--   cover.  Monotonicity FAILS for the naive "use the entire tuple" definition
--   (a nonzero coordinate cannot be cancelled), which is exactly why the
--   subsequence model with the `0` weight is the correct one — with it,
--   monotonicity `kernelCover_succ` holds by padding with `0`.
-- Critique (Critic): `insert 0 W` with the `∃ i, φ i ≠ 0` clause is essential;
--   without the nonzero clause the property is vacuously true at every level.
--   The bridge `kernelCover_id_iff` needs `Nontrivial G` (else `id = 0`).
-/
import Mathlib

open scoped BigOperators

namespace WeightedDavenport

variable {F G : Type*} [AddCommGroup F] [AddCommGroup G]

/-- The induced universal homomorphism attached to a length-`n` choice of
weights `φ : Fin n → (F →+ G)`: it sends `x` to `∑ i, φ i (x i)`. -/
noncomputable def Phi {n : ℕ} (φ : Fin n → (F →+ G)) : (Fin n → F) →+ G :=
  ∑ i, (φ i).comp (Pi.evalAddMonoidHom (fun _ : Fin n => F) i)

@[simp] lemma Phi_apply {n : ℕ} (φ : Fin n → (F →+ G)) (x : Fin n → F) :
    Phi φ x = ∑ i, φ i (x i) := by
  rw [Phi, AddMonoidHom.finset_sum_apply]; rfl

/-- A choice of weights is *valid* for the weight set `W` when every coordinate
is either the skip-weight `0` or a genuine weight in `W`, and at least one
coordinate is a genuine (nonzero) weight. -/
def ValidChoice {n : ℕ} (W : Set (F →+ G)) (φ : Fin n → (F →+ G)) : Prop :=
  (∀ i, φ i ∈ insert (0 : F →+ G) W) ∧ ∃ i, φ i ≠ 0

/-- The kernel-cover property at level `n`: every `x ∈ F^n` lies in the kernel
of some valid induced universal homomorphism. Equivalently, `D_Ψ(G) ≤ n`. -/
def KernelCover (W : Set (F →+ G)) (n : ℕ) : Prop :=
  ∀ x : Fin n → F, ∃ φ : Fin n → (F →+ G), ValidChoice W φ ∧ Phi φ x = 0

/-- **Kernel-cover characterisation (the conjecture).** The weighted Davenport
bound `D_Ψ(G) ≤ n`, encoded as `KernelCover W n`, holds precisely when the
kernels of the induced universal homomorphisms form a cover of `F^n`. -/
theorem kernelCover_iff_iUnion_ker (W : Set (F →+ G)) (n : ℕ) :
    KernelCover W n ↔
    (⋃ (φ : Fin n → (F →+ G)) (_ : ValidChoice W φ), ((Phi φ).ker : Set (Fin n → F)))
      = Set.univ := by
  rw [Set.eq_univ_iff_forall]
  constructor
  · intro h x
    obtain ⟨φ, hφ, hx⟩ := h x
    simp only [Set.mem_iUnion]
    exact ⟨φ, hφ, by rw [SetLike.mem_coe, AddMonoidHom.mem_ker]; exact hx⟩
  · intro h x
    have hx := h x
    simp only [Set.mem_iUnion] at hx
    obtain ⟨φ, hφ, hxk⟩ := hx
    exact ⟨φ, hφ, by rw [SetLike.mem_coe, AddMonoidHom.mem_ker] at hxk; exact hxk⟩

/-- The kernel-cover property is preserved when the length grows by one: pad the
witnessing choice with the skip-weight `0`. -/
theorem kernelCover_succ (W : Set (F →+ G)) (n : ℕ) (h : KernelCover W n) :
    KernelCover W (n + 1) := by
  intro x
  obtain ⟨φ', ⟨hmem, i0, hi0⟩, hsum⟩ := h (fun i => x i.castSucc)
  refine ⟨Fin.snoc φ' 0, ⟨?_, i0.castSucc, ?_⟩, ?_⟩
  · intro i
    refine Fin.lastCases ?_ ?_ i
    · simp
    · intro j; simpa using hmem j
  · simpa using hi0
  · rw [Phi_apply, Fin.sum_univ_castSucc]
    simp only [Fin.snoc_castSucc, Fin.snoc_last, AddMonoidHom.zero_apply, add_zero]
    rw [← Phi_apply]; exact hsum

/-- Monotonicity of the kernel-cover property in the length `n`. -/
theorem kernelCover_mono (W : Set (F →+ G)) {m n : ℕ} (hmn : m ≤ n)
    (h : KernelCover W m) : KernelCover W n := by
  induction n, hmn using Nat.le_induction with
  | base => exact h
  | succ k _ ih => exact kernelCover_succ W k ih

/-- A length-`n` sequence `x` in `G` has a **nonempty zero-sum subsequence**. -/
def HasZeroSumSub {n : ℕ} (x : Fin n → G) : Prop :=
  ∃ S : Finset (Fin n), S.Nonempty ∧ ∑ i ∈ S, x i = 0

lemma id_ne_zero [Nontrivial G] : (AddMonoidHom.id G) ≠ 0 := by
  obtain ⟨a, ha⟩ := exists_ne (0 : G)
  intro h
  apply ha
  have : (AddMonoidHom.id G) a = (0 : G →+ G) a := by rw [h]
  simpa using this

/-- **Bridge to the classical Davenport constant.** For the singleton weight set
`{id}` on a nontrivial group, the kernel-cover property at level `n` is exactly
the statement that every length-`n` sequence has a nonempty zero-sum
subsequence. -/
theorem kernelCover_id_iff [Nontrivial G] (n : ℕ) :
    KernelCover ({AddMonoidHom.id G}) n ↔ ∀ x : Fin n → G, HasZeroSumSub x := by
  classical
  constructor
  · intro h x
    obtain ⟨φ, ⟨hmem, i0, hi0⟩, hsum⟩ := h x
    refine ⟨Finset.univ.filter (fun i => φ i = AddMonoidHom.id G), ?_, ?_⟩
    · refine ⟨i0, ?_⟩
      rcases hmem i0 with h0 | h1
      · exact absurd h0 hi0
      · simp [Finset.mem_filter, Set.mem_singleton_iff.mp h1]
    · rw [Phi_apply] at hsum
      rw [← hsum, Finset.sum_filter]
      apply Finset.sum_congr rfl
      intro i _
      rcases hmem i with h0 | h1
      · rw [h0]; simp [id_ne_zero.symm]
      · rw [Set.mem_singleton_iff] at h1; rw [h1]; simp
  · intro h x
    obtain ⟨S, hSne, hSsum⟩ := h x
    refine ⟨fun i => if i ∈ S then AddMonoidHom.id G else 0, ⟨?_, ?_⟩, ?_⟩
    · intro i; by_cases hi : i ∈ S <;> simp [hi]
    · obtain ⟨i, hi⟩ := hSne
      exact ⟨i, by simp [hi, id_ne_zero]⟩
    · rw [Phi_apply, ← hSsum]
      have hterm : ∀ i, (if i ∈ S then AddMonoidHom.id G else 0) (x i)
          = if i ∈ S then x i else 0 := by
        intro i; by_cases hi : i ∈ S <;> simp [hi]
      simp_rw [hterm]
      rw [Finset.sum_ite_mem]
      simp

end WeightedDavenport