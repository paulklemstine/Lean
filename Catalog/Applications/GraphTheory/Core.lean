import Mathlib

/-!
# Agreement subtrees: restriction and threshold infrastructure

A finite unrooted phylogenetic tree is determined by its nontrivial edge splits. This
file isolates the restriction algebra used in the multiple-tree maximum-agreement-
subtree problem. A `SplitSystem α` is represented extensionally as a finite family of
finite leaf sets (one consistently chosen side of each split). Restriction to a leaf set
intersects every split with that set. The results therefore apply more generally to
arbitrary finite split systems.

The principal structural theorem, `commonAgreement_iff_pairwise`, says that a leaf set
is a common agreement set for a nonempty family exactly when every pair of systems has
identical restriction there. We also prove heredity under taking smaller leaf sets and
the abstract transfer from any common-subtree threshold to a common-quartet threshold.
-/

open Finset

namespace AgreementSubtrees

variable {α ι : Type*} [DecidableEq α]

/-- A finite split encoding of a labelled phylogenetic tree. -/
abbrev SplitSystem (α : Type*) := Finset (Finset α)

/-- Restrict every split of a system to a set of retained leaves. -/
def restrict (T : SplitSystem α) (A : Finset α) : SplitSystem α :=
  T.image (fun s => s ∩ A)

@[simp] theorem restrict_empty (T : SplitSystem α) : restrict T ∅ = {∅} ∨ T = ∅ := by
  by_cases h : T = ∅
  · exact Or.inr h
  · left
    ext x
    constructor
    · intro hx
      obtain ⟨s, _, rfl⟩ := Finset.mem_image.mp hx
      simp
    · intro hx
      have hnonempty : T.Nonempty := Finset.nonempty_iff_ne_empty.mpr h
      obtain ⟨s, hs⟩ := hnonempty
      simp only [Finset.mem_singleton] at hx
      subst x
      exact Finset.mem_image.mpr ⟨s, hs, by simp⟩

@[simp] theorem restrict_univ_of_subset (T : SplitSystem α) (U : Finset α)
    (hT : ∀ s ∈ T, s ⊆ U) : restrict T U = T := by
  convert T.image_congr fun s hs => Finset.inter_eq_left.2 (hT s hs)
  rw [image_id']

/-- Restriction is functorial: restricting first to `A`, then to `B`, is restriction
straight to `A ∩ B`. -/
theorem restrict_restrict (T : SplitSystem α) (A B : Finset α) :
    restrict (restrict T A) B = restrict T (A ∩ B) := by
  ext
  simp [restrict]

/-- On nested leaf sets, iterated restriction is simply restriction to the smaller set. -/
theorem restrict_restrict_of_subset (T : SplitSystem α) {A B : Finset α} (hBA : B ⊆ A) :
    restrict (restrict T A) B = restrict T B := by
  rw [restrict_restrict, Finset.inter_eq_right.mpr hBA]

/-- Two trees agree on `A` when their induced split systems on `A` coincide. -/
def AgreeOn (T U : SplitSystem α) (A : Finset α) : Prop :=
  restrict T A = restrict U A

theorem agreeOn_refl (T : SplitSystem α) (A : Finset α) : AgreeOn T T A := by
  rfl

theorem agreeOn_symm {T U : SplitSystem α} {A : Finset α} :
    AgreeOn T U A → AgreeOn U T A := by
  exact fun h => h.symm

theorem agreeOn_trans {T U V : SplitSystem α} {A : Finset α} :
    AgreeOn T U A → AgreeOn U V A → AgreeOn T V A := by
  exact fun h₁ h₂ => h₁.trans h₂

/-- Agreement subtrees are hereditary under deleting leaves. -/
theorem AgreeOn.mono {T U : SplitSystem α} {A B : Finset α}
    (h : AgreeOn T U A) (hBA : B ⊆ A) : AgreeOn T U B := by
  change restrict T B = restrict U B
  rw [← restrict_restrict_of_subset T hBA, ← restrict_restrict_of_subset U hBA, h]

/-- A family has a common induced subtree on `A` if all restrictions equal one witness. -/
def CommonAgreement (F : Finset ι) (T : ι → SplitSystem α) (A : Finset α) : Prop :=
  ∃ R : SplitSystem α, ∀ i ∈ F, restrict (T i) A = R

/-- Common agreement is hereditary under taking a smaller leaf set. -/
theorem CommonAgreement.mono {F : Finset ι} {T : ι → SplitSystem α} {A B : Finset α}
    (h : CommonAgreement F T A) (hBA : B ⊆ A) : CommonAgreement F T B := by
  obtain ⟨R, hR⟩ := h
  use restrict R B
  intro i hi
  rw [← hR i hi, restrict_restrict_of_subset]
  exact hBA

/-- For a nonempty family, agreement with one chosen base tree characterizes common
agreement. -/
theorem commonAgreement_iff_base {F : Finset ι} (hF : F.Nonempty)
    (T : ι → SplitSystem α) (A : Finset α) :
    CommonAgreement F T A ↔ ∃ b ∈ F, ∀ i ∈ F, AgreeOn (T i) (T b) A := by
  obtain ⟨b, hb⟩ := hF
  constructor
  · rintro ⟨R, hR⟩
    exact ⟨b, hb, fun i hi => (hR i hi).trans (hR b hb).symm⟩
  · rintro ⟨b, _, h⟩
    exact ⟨restrict (T b) A, h⟩

/-- Main structural result: common agreement is exactly pairwise agreement. -/
theorem commonAgreement_iff_pairwise {F : Finset ι} (hF : F.Nonempty)
    (T : ι → SplitSystem α) (A : Finset α) :
    CommonAgreement F T A ↔ ∀ i ∈ F, ∀ j ∈ F, AgreeOn (T i) (T j) A := by
  constructor
  · rintro ⟨R, hR⟩ i hi j hj
    exact (hR i hi).trans (hR j hj).symm
  · intro h
    rw [commonAgreement_iff_base hF]
    obtain ⟨b, hb⟩ := hF
    exact ⟨b, hb, fun i hi => h i hi b hb⟩

/-- Any common agreement subtree with at least four leaves contains a common quartet. -/
theorem common_quartet_of_common_subtree {F : Finset ι} {T : ι → SplitSystem α}
    {A : Finset α} (h : CommonAgreement F T A) (hcard : 4 ≤ A.card) :
    ∃ Q ⊆ A, Q.card = 4 ∧ CommonAgreement F T Q := by
  obtain ⟨Q, hQA, hQcard⟩ := Finset.exists_subset_card_eq hcard
  exact ⟨Q, hQA, hQcard, CommonAgreement.mono h hQA⟩

/-- `N` forces an `n`-leaf common agreement subtree for every `k`-indexed family. -/
def IsAgreementThreshold (N k n : ℕ) : Prop :=
  ∀ (T : Fin k → SplitSystem (Fin N)),
    ∃ A : Finset (Fin N), A.card = n ∧ CommonAgreement Finset.univ T A

/-- A threshold for an `n`-leaf common subtree (`n ≥ 4`) is automatically a threshold
for a common quartet. This is the formal implication used to pass from the paper's
multiple-tree MAST upper bound to its upper bound on `h(k)`. -/
theorem agreementThreshold_implies_quartetThreshold {N k n : ℕ} (hn : 4 ≤ n)
    (h : IsAgreementThreshold N k n) : IsAgreementThreshold N k 4 := by
  intro T
  obtain ⟨A, hAcard, hA⟩ := h T
  obtain ⟨Q, _, hQcard, hQ⟩ := common_quartet_of_common_subtree hA (hAcard ▸ hn)
  exact ⟨Q, hQcard, hQ⟩

/-- Thresholds are monotone in requested agreement size. -/
theorem agreementThreshold_mono_size {N k m n : ℕ} (hmn : m ≤ n)
    (h : IsAgreementThreshold N k n) : IsAgreementThreshold N k m := by
  intro T
  obtain ⟨A, hAcard, hA⟩ := h T
  obtain ⟨B, hBA, hBcard⟩ := Finset.exists_subset_card_eq (hAcard ▸ hmn)
  exact ⟨B, hBcard, CommonAgreement.mono hA hBA⟩

/-
No agreement threshold can request more leaves than the ambient leaf set contains.
-/
theorem agreementThreshold_size_bound {N k n : ℕ} (h : IsAgreementThreshold N k n) : n ≤ N := by
  obtain ⟨A, hAcard, _⟩ := h (fun _ => ∅)
  exact hAcard ▸ le_trans (Finset.card_le_univ _) (by simp)

/-
For one tree, the exact threshold condition is simply that the requested leaf set
fits in the ambient leaf set. This is the base case of the multiple-tree problem.
-/
theorem oneTree_agreementThreshold_iff {N n : ℕ} :
    IsAgreementThreshold N 1 n ↔ n ≤ N := by
  constructor
  · exact agreementThreshold_size_bound
  · intro hn T
    obtain ⟨A, _, hAcard⟩ := Finset.exists_subset_card_eq
      (show n ≤ (Finset.univ : Finset (Fin N)).card by simpa)
    refine ⟨A, hAcard, restrict (T 0) A, ?_⟩
    intro i _
    have hi : i = 0 := Subsingleton.elim _ _
    subst i
    rfl

end JacobianConjecture
end AgreementSubtrees
