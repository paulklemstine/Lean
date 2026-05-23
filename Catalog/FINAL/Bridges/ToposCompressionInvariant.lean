/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Pythagorean.ProbeComplexity.ToposCompressionDefs

/-!
# Topos-Level Compression Invariant — Main Theorems

This file proves the main theorems establishing compression as a **Morita-invariant
complexity measure** of finite presheaf models.

## Main Results

* `exists_minimizer_compression'` — **Theorem A**: existence and well-definedness.
* `transport_separation` — **Theorem B**: transport of separation under equivalences.
* `compressionNumber_eq_of_equiv'` — **Theorem C**: flagship Morita invariance.
* `compressionNumber_le_representableDim` — **Theorem D**: comparison with repDim.
* `observationComplexity_le_compressionNumber` — **Theorem E**: cross-domain bridge.
* `compression_pos_of_nontrivial` — positive compression from nontrivial fibers (by_contra).
* `compression_minimum_unique'` — uniqueness of the minimum (rcases + antisymmetry).
* `no_separating_below_compression'` — minimality by contradiction.
-/

open Finset Fintype

noncomputable section

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

universe u v w

/-! ## Part I: Well-Definedness (Theorem A) -/

section WellDefinedness

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

theorem compressionSpectrum_nonempty'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r) :
    (compressionSpectrum' F r).Nonempty :=
  ⟨Fintype.card Ob, Finset.univ, Finset.card_univ, hsep⟩

theorem presheafMinCompression_le_card'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r) :
    presheafMinCompression' F r ≤ Fintype.card Ob := by
  apply Nat.sInf_le
  exact ⟨Finset.univ, Finset.card_univ, hsep⟩

theorem presheafMinCompression_achieved'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r) :
    ∃ P : ProbeFamily Ob, P.card = presheafMinCompression' F r ∧
      ProbeSeparates F r P :=
  Nat.sInf_mem (compressionSpectrum_nonempty' F r hsep)

theorem presheafMinCompression_le'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (P : ProbeFamily Ob) (hP : ProbeSeparates F r P) :
    presheafMinCompression' F r ≤ P.card :=
  Nat.sInf_le ⟨P, rfl, hP⟩

/-- **Theorem A (Existence of minimizer).**
For any probe-separating presheaf on a finite type, the minimum compression
number exists: there is a realized value that is ≤ all others.

*Proof:* Uses well-ordering of ℕ via `Nat.sInf_mem` on the nonempty
compression spectrum. -/
theorem exists_minimizer_compression'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r) :
    ∃ n : ℕ, realizesCompression' F r n ∧
      ∀ m : ℕ, realizesCompression' F r m → n ≤ m := by
  refine ⟨presheafMinCompression' F r, ?_, ?_⟩
  · exact presheafMinCompression_achieved' F r hsep
  · intro m ⟨P, hcard, hP⟩
    rw [← hcard]
    exact presheafMinCompression_le' F r P hP

/-- **Topos compression number specification.**
The compression number is both realized and minimal. -/
theorem toposCompressionNumber_spec'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r) :
    realizesCompression' F r (presheafMinCompression' F r) ∧
    ∀ m : ℕ, realizesCompression' F r m → presheafMinCompression' F r ≤ m :=
  ⟨presheafMinCompression_achieved' F r hsep,
   fun m ⟨P, hcard, hP⟩ => hcard ▸ presheafMinCompression_le' F r P hP⟩

end WellDefinedness

/-! ## Part II: Transport and Monotonicity (Theorem B) -/

section Transport

variable {Ob₁ : Type u} {Ob₂ : Type v}
  [Fintype Ob₁] [DecidableEq Ob₁] [Fintype Ob₂] [DecidableEq Ob₂]

/-- **Transport of separation (Theorem B, part 1).**
A compression-compatible equivalence transports separating probe families:
if `P` separates `F₁`, then `P.map φ` separates `F₂`.

*Proof:* Given sections `s₂, t₂ ∈ F₂(φ(Y₁))` with identical signatures
under `P.map φ`, pull them back via `ψ⁻¹`, use compatibility to show
`F₁`-signatures agree under `P`, apply separation in `F₁`, push forward.
Uses `rcases` to unpack the surjectivity of `φ`, `funext` for signature
extensionality, and the compatibility equation `e.compat`. -/
theorem transport_separation
    {F₁ : Ob₁ → Type w} {F₂ : Ob₂ → Type w}
    {r₁ : ∀ Y Z, F₁ Y → F₁ Z} {r₂ : ∀ Y Z, F₂ Y → F₂ Z}
    (e : CompressionEquiv Ob₁ Ob₂ F₁ F₂ r₁ r₂)
    (P : ProbeFamily Ob₁) (hP : ProbeSeparates F₁ r₁ P) :
    ProbeSeparates F₂ r₂ (P.map e.φ.toEmbedding) := by
  intro Y₂
  rcases e.φ.surjective Y₂ with ⟨Y₁, rfl⟩
  intro s₂ t₂ hsig
  set s₁ := (e.ψ Y₁).symm s₂
  set t₁ := (e.ψ Y₁).symm t₂
  suffices h : s₁ = t₁ by
    have := congr_arg (e.ψ Y₁) h
    simp [s₁, t₁] at this
    exact this
  apply hP Y₁
  funext ⟨Z₁, hZ₁⟩
  simp only [probeSignature']
  have hZ₂ : e.φ Z₁ ∈ P.map e.φ.toEmbedding :=
    Finset.mem_map_of_mem _ hZ₁
  have key := congr_fun hsig ⟨e.φ Z₁, hZ₂⟩
  simp only [probeSignature'] at key
  apply (e.ψ Z₁).injective
  rw [e.compat Y₁ Z₁ s₁, e.compat Y₁ Z₁ t₁]
  simp only [s₁, t₁, Equiv.apply_symm_apply]
  exact key

/-- **Theorem B (Monotonicity under equivalence).**
Compression does not increase under compression-compatible equivalences.

*Proof via `calc`:* Transport the optimal family, use cardinality preservation. -/
theorem compressionNumber_le_of_equiv
    {F₁ : Ob₁ → Type w} {F₂ : Ob₂ → Type w}
    {r₁ : ∀ Y Z, F₁ Y → F₁ Z} {r₂ : ∀ Y Z, F₂ Y → F₂ Z}
    (e : CompressionEquiv Ob₁ Ob₂ F₁ F₂ r₁ r₂)
    (hsep₁ : ProbeSeparating' F₁ r₁) :
    presheafMinCompression' F₂ r₂ ≤ presheafMinCompression' F₁ r₁ := by
  rcases presheafMinCompression_achieved' F₁ r₁ hsep₁ with ⟨P, hcard, hP⟩
  calc presheafMinCompression' F₂ r₂
      ≤ (P.map e.φ.toEmbedding).card := presheafMinCompression_le' F₂ r₂ _ (transport_separation e P hP)
    _ = P.card := Finset.card_map _
    _ = presheafMinCompression' F₁ r₁ := hcard

end Transport

/-! ## Part III: Morita Invariance (Theorem C — Flagship) -/

section MoritaInvariance

variable {Ob₁ : Type u} {Ob₂ : Type v}
  [Fintype Ob₁] [DecidableEq Ob₁] [Fintype Ob₂] [DecidableEq Ob₂]

/-- **Theorem C (Flagship Morita Invariance).**
If two presheaf models are related by compression-compatible equivalences
in both directions, their compression numbers are equal.

*Proof:* Apply monotonicity (Theorem B) in both directions and use
antisymmetry of ≤ on ℕ. -/
theorem compressionNumber_eq_of_equiv'
    {F₁ : Ob₁ → Type w} {F₂ : Ob₂ → Type w}
    {r₁ : ∀ Y Z, F₁ Y → F₁ Z} {r₂ : ∀ Y Z, F₂ Y → F₂ Z}
    (e_fwd : CompressionEquiv Ob₁ Ob₂ F₁ F₂ r₁ r₂)
    (e_bwd : CompressionEquiv Ob₂ Ob₁ F₂ F₁ r₂ r₁)
    (hsep₁ : ProbeSeparating' F₁ r₁)
    (hsep₂ : ProbeSeparating' F₂ r₂) :
    presheafMinCompression' F₁ r₁ = presheafMinCompression' F₂ r₂ := by
  apply le_antisymm
  · exact compressionNumber_le_of_equiv e_bwd hsep₂
  · exact compressionNumber_le_of_equiv e_fwd hsep₁

end MoritaInvariance

/-! ## Part IV: Comparison with Representable Dimension (Theorem D) -/

section ComparisonRepDim

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-- Number of objects ≤ representable dimension when fibers are nonempty. -/
theorem card_le_representableDim
    (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (hne : ∀ Y, Nonempty (F Y)) :
    Fintype.card Ob ≤ representableDim F := by
  unfold representableDim
  have : Fintype.card Ob = ∑ _Y : Ob, 1 := by simp
  rw [this]
  apply Finset.sum_le_sum
  intro Y _
  exact Fintype.card_pos_iff.mpr (hne Y)

/-- **Theorem D (Compression ≤ representable dimension).**
For probe-separating presheaves with nonempty fibers, compression ≤ repDim.

*Proof via `calc`:*
1. `presheafMinCompression ≤ card Ob`
2. `card Ob ≤ representableDim F` -/
theorem compressionNumber_le_representableDim
    (F : Ob → Type v) [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r)
    (hne : ∀ Y, Nonempty (F Y)) :
    presheafMinCompression' F r ≤ representableDim F :=
  le_trans (presheafMinCompression_le_card' F r hsep) (card_le_representableDim F hne)

end ComparisonRepDim

/-! ## Part V: Observation Complexity Bridge (Theorem E) -/

section ObservationBridge

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-- Fiber observation complexity ≤ compression number at each object. -/
theorem fiberObsComplexity_le_compression
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r) (Y : Ob) :
    fiberObsComplexity F r Y ≤ presheafMinCompression' F r := by
  rcases presheafMinCompression_achieved' F r hsep with ⟨P, hcard, hP⟩
  apply Nat.sInf_le
  exact ⟨P, hcard, hP Y⟩

/-- **Theorem E (Cross-domain bridge: observation ≤ compression).**
The observation complexity is bounded by the compression number.

**Cross-domain significance:** Bridges categorical probe theory to
information-theoretic observation complexity. The minimum code length
for identification upper-bounds the worst-case measurement cost. -/
theorem observationComplexity_le_compressionNumber
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r) :
    observationComplexity' F r ≤ presheafMinCompression' F r := by
  apply Finset.sup_le
  intro Y _
  exact fiberObsComplexity_le_compression F r hsep Y

end ObservationBridge

/-! ## Part VI: Structural Properties (Deep Proof Tactics) -/

section Structural

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-- Monotonicity of separation: supersets of separating families separate. -/
theorem ProbeSeparates.mono
    {F : Ob → Type v} {r : ∀ Y Z, F Y → F Z}
    {P Q : ProbeFamily Ob}
    (hP : ProbeSeparates F r P) (hPQ : P ⊆ Q) :
    ProbeSeparates F r Q := by
  intro Y s t hsig
  apply hP Y
  funext ⟨Z, hZ⟩
  have hZQ : Z ∈ Q := hPQ hZ
  exact congr_fun hsig ⟨Z, hZQ⟩

/-- **Minimality by contradiction.**
If `n < presheafMinCompression`, then `n` is not realized.
Uses `by_contra` and `omega`. -/
theorem no_separating_below_compression'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r)
    (n : ℕ) (hn : n < presheafMinCompression' F r) :
    ¬ realizesCompression' F r n := by
  intro ⟨P, hcard, hP⟩
  have hle := presheafMinCompression_le' F r P hP
  omega

/-- **Uniqueness of minimum.**
The compression number is the unique value that is both realized and minimal.
Uses `rcases` to unpack witnesses and `le_antisymm`. -/
theorem compression_minimum_unique'
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r)
    (n : ℕ)
    (hreal : realizesCompression' F r n)
    (hmin : ∀ m, realizesCompression' F r m → n ≤ m) :
    n = presheafMinCompression' F r := by
  apply le_antisymm
  · rcases presheafMinCompression_achieved' F r hsep with ⟨P, hcard, hP⟩
    rw [← hcard]
    exact hmin P.card ⟨P, rfl, hP⟩
  · rcases hreal with ⟨P, hcard, hP⟩
    rw [← hcard]
    exact presheafMinCompression_le' F r P hP

/-- **For subsingleton fibers, compression is zero.** -/
theorem compression_zero_of_subsingleton_fibers
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hss : ∀ Y, Subsingleton (F Y)) :
    presheafMinCompression' F r = 0 := by
  apply le_antisymm
  · have h_empty_sep : ProbeSeparates F r ∅ := by
      intro Y s t _
      exact (hss Y).elim s t
    have := presheafMinCompression_le' F r ∅ h_empty_sep
    simp at this
    omega
  · exact Nat.zero_le _

/-- **Positive compression from nontrivial fibers.** If some fiber has
two distinct elements, at least one probe is needed.
Uses `by_contra` and derives contradiction from the empty family. -/
theorem compression_pos_of_nontrivial
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hsep : ProbeSeparating' F r)
    (Y : Ob) (a b : F Y) (hab : a ≠ b) :
    1 ≤ presheafMinCompression' F r := by
  by_contra h
  push_neg at h
  have h0 : presheafMinCompression' F r = 0 := by omega
  rcases presheafMinCompression_achieved' F r hsep with ⟨P, hcard, hP⟩
  rw [h0] at hcard
  have hempty : P = ∅ := Finset.card_eq_zero.mp hcard
  subst hempty
  have hsep_Y := hP Y
  -- Empty probe family means signature is into empty product, so trivially injective
  -- only if F Y is subsingleton. But we have a ≠ b.
  have : a = b := by
    apply hsep_Y
    funext ⟨_, h⟩
    exact absurd h (by simp)
  exact hab this

end Structural

/-! ## Part VII: Verified Computation -/

section Computation

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-- A **compression witness** certifies that a probe family achieves a given
compression number. This is the verified algorithmic component. -/
structure CompressionWitness
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) (n : ℕ) where
  family : ProbeFamily Ob
  card_eq : family.card = n
  separates : ProbeSeparates F r family

/-- A compression witness certifies the compression number is at most `n`. -/
theorem CompressionWitness.compression_le
    {F : Ob → Type v} {r : ∀ Y Z, F Y → F Z} {n : ℕ}
    (w : CompressionWitness F r n) :
    presheafMinCompression' F r ≤ n := by
  rw [← w.card_eq]
  exact presheafMinCompression_le' F r w.family w.separates

/-- **Verified optimality.** The compression number is optimal. -/
theorem compression_optimal
    {F : Ob → Type v} {r : ∀ Y Z, F Y → F Z}
    (hsep : ProbeSeparating' F r) :
    ∀ m, realizesCompression' F r m → presheafMinCompression' F r ≤ m :=
  fun m hm => (toposCompressionNumber_spec' F r hsep).2 m hm

end Computation

end