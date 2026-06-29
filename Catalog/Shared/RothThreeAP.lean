import Mathlib

/-! # Roth's theorem on 3-term arithmetic progressions, positive form

Mathlib's `roth_3ap_theorem` states Roth's theorem *negatively*: a dense subset
of a finite abelian group is **not** `ThreeAPFree`. For applications one wants the
*positive* existence statement: a dense set actually **contains** a genuine
(non-degenerate) 3-term arithmetic progression `a, a + d, a + 2d` with `d ≠ 0`.

* `exists_nontrivial_threeAP_of_dense`: positive Roth for an arbitrary finite
  abelian group `G`.
* `exists_nontrivial_threeAP_zmod`: the specialization to `ZMod N`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `roth_3ap_theorem` says `¬ ThreeAPFree A`; unfolding
  the definition should yield an *explicit* progression, not just non-freeness.
  Conjecture: from `¬ ThreeAPFree A` we can extract `a, d` with `d ≠ 0` and all
  of `a, a+d, a+2d ∈ A`.
Experiment (Experimenter): `ThreeAPFree A` unfolds to
  `∀ a∈A, ∀ b∈A, ∀ c∈A, a + c = b + b → a = b`. `push_neg` gives witnesses
  `a, b, c ∈ A` with `a + c = b + b` and `a ≠ b`. Setting `d := b - a`, additive
  group arithmetic (`abel`) gives `b = a + d` and, from `a + c = 2b`,
  `c = a + 2d`; non-degeneracy `d ≠ 0` follows from `a ≠ b` via `sub_eq_zero`.
Analysis (Analyst): The middle term `b` of the AP is the witness that must equal
  the others if the set were AP-free; its inequality with `a` is exactly the
  common difference being nonzero. The `2 • d` form matches `a + c = b + b`.
Critique (Critic): The statement is non-vacuous precisely under the density
  hypothesis `ε·|G| ≤ |A|` together with `cornersTheoremBound ε ≤ |G|`; without
  these `roth_3ap_theorem` does not apply, so the corollary is not vacuously
  true. The proof uses `push_neg`, `rcases`, and `abel`, not pure `simp`.
Synthesis (PI): Roth (negative) ⇒ explicit non-degenerate 3-AP ⇒ `ZMod N` form.
-/

open Finset

/-- **Roth's theorem on 3-APs, positive form.** If `A` is a subset of a finite
abelian group `G` with `|A| ≥ ε|G|` and `|G|` is large enough
(`cornersTheoremBound ε ≤ |G|`), then `A` contains a non-degenerate three-term
arithmetic progression `a, a + d, a + 2d` with `d ≠ 0`. -/
theorem exists_nontrivial_threeAP_of_dense
    {G : Type*} [AddCommGroup G] [Fintype G] (ε : ℝ) (hε : 0 < ε)
    (hcard : cornersTheoremBound ε ≤ Fintype.card G)
    (A : Finset G) (hA : ε * (Fintype.card G) ≤ #A) :
    ∃ a d : G, d ≠ 0 ∧ a ∈ A ∧ a + d ∈ A ∧ a + 2 • d ∈ A := by
  have h := roth_3ap_theorem ε hε hcard A hA
  unfold ThreeAPFree at h
  push_neg at h
  obtain ⟨a, ha, b, hb, c, hc, hsum, hne⟩ := h
  rw [Finset.mem_coe] at ha hb hc
  refine ⟨a, b - a, ?_, ha, ?_, ?_⟩
  · intro hd; rw [sub_eq_zero] at hd; exact hne hd.symm
  · simpa using hb
  · have heq : a + 2 • (b - a) = c := by
      rw [show c = b + b - a by rw [← hsum]; abel, two_smul]; abel
    rw [heq]; exact hc

/-- **Roth's theorem in `ZMod N`.** A dense subset of `ZMod N` (for `N` large
relative to the density) contains a non-degenerate 3-term arithmetic
progression. -/
theorem exists_nontrivial_threeAP_zmod
    (N : ℕ) [NeZero N] (ε : ℝ) (hε : 0 < ε)
    (hcard : cornersTheoremBound ε ≤ N)
    (A : Finset (ZMod N)) (hA : ε * N ≤ #A) :
    ∃ a d : ZMod N, d ≠ 0 ∧ a ∈ A ∧ a + d ∈ A ∧ a + 2 • d ∈ A := by
  have hN : Fintype.card (ZMod N) = N := ZMod.card N
  apply exists_nontrivial_threeAP_of_dense ε hε
  · rw [hN]; exact hcard
  · rw [hN]; exact hA