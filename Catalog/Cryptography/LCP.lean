import Cryptography.Berggren.Divisibility

/-!
# Longest Common Prefix, Decidability, and Oracle Reductions

## Main Results

* `lcpList` — Longest common prefix on lists
* `lcpList_is_prefix_left/right` — LCP is a prefix of both inputs
* `lcpList_greatest` — LCP is the greatest common prefix
* `exists_inf_leftDivides` — Greatest lower bound for left divisibility
* `secret_suffix_unique` — Prefix recovery → secret extraction
-/

set_option linter.unusedVariables false
set_option linter.unusedTactic false
set_option linter.unusedSimpArgs false

/-! ## Longest common prefix on lists -/

/-- Longest common prefix of two lists. -/
def lcpList [DecidableEq α] : List α → List α → List α
  | [], _ => []
  | _, [] => []
  | a :: as, b :: bs => if a = b then a :: lcpList as bs else []

@[simp] theorem lcpList_nil_left [DecidableEq α] (l : List α) : lcpList [] l = [] := rfl
@[simp] theorem lcpList_nil_right [DecidableEq α] (l : List α) : lcpList l [] = [] := by
  cases l <;> rfl

/-- The LCP is a prefix of the first argument. -/
theorem lcpList_is_prefix_left [DecidableEq α] :
    ∀ l₁ l₂ : List α, lcpList l₁ l₂ <+: l₁
  | [], _ => List.nil_prefix
  | _ :: _, [] => List.nil_prefix
  | a :: as, b :: bs => by
    simp only [lcpList]; split
    · next h => subst h; exact List.cons_prefix_cons.mpr ⟨rfl, lcpList_is_prefix_left as bs⟩
    · exact List.nil_prefix

/-- The LCP is a prefix of the second argument. -/
theorem lcpList_is_prefix_right [DecidableEq α] :
    ∀ l₁ l₂ : List α, lcpList l₁ l₂ <+: l₂
  | [], _ => List.nil_prefix
  | _ :: _, [] => List.nil_prefix
  | a :: as, b :: bs => by
    simp only [lcpList]; split
    · next h => subst h; exact List.cons_prefix_cons.mpr ⟨rfl, lcpList_is_prefix_right as bs⟩
    · exact List.nil_prefix

/-- The LCP is the greatest common prefix. -/
theorem lcpList_greatest [DecidableEq α] (l₁ l₂ p : List α)
    (hp1 : p <+: l₁) (hp2 : p <+: l₂) : p <+: lcpList l₁ l₂ := by
  induction l₁ generalizing l₂ p with
  | nil => simp [List.prefix_nil.mp hp1]
  | cons a as ih =>
    cases l₂ with
    | nil => simp [List.prefix_nil.mp hp2]
    | cons b bs =>
      cases p with
      | nil => exact List.nil_prefix
      | cons x xs =>
        rw [List.cons_prefix_cons] at hp1 hp2
        obtain ⟨rfl, hp1'⟩ := hp1
        obtain ⟨rfl, hp2'⟩ := hp2
        simp only [lcpList]
        exact List.cons_prefix_cons.mpr ⟨rfl, ih bs xs hp1' hp2'⟩

/-! ## Decidability -/

/-- IsPrefixFS expressed in terms of list prefix. -/
theorem BerggrenSg.isPrefixFS_iff (u v : FreeSemigroup BGen) :
    BerggrenSg.IsPrefixFS u v ↔ (fsToList u) <+: (fsToList v) := by
  constructor
  · rintro (rfl | ⟨t, rfl⟩)
    · exact List.prefix_rfl
    · rw [fsToList_mul]; exact List.prefix_append _ _
  · intro ⟨s, hs⟩
    by_cases hs' : s = []
    · left; subst hs'; rw [List.append_nil] at hs; exact fsToList_injective hs
    · right
      obtain ⟨x, xs, rfl⟩ := List.exists_cons_of_ne_nil hs'
      exact ⟨⟨x, xs⟩, fsToList_injective (by rw [fsToList_mul]; exact hs.symm)⟩

noncomputable instance instDecidableLeftDivides' : DecidableRel BerggrenSg.LeftDivides := by
  intro A B
  rw [BerggrenSg.leftDivides_iff_prefix, BerggrenSg.isPrefixFS_iff]
  infer_instance

theorem BerggrenSg.decide_leftDivides_via_nf (A B : BerggrenSg) :
    LeftDivides A B ↔ IsPrefixFS (nf A) (nf B) :=
  leftDivides_iff_prefix A B

/-! ## Greatest lower bound = longest common prefix -/

/-- Compute the common prefix of two BerggrenSg elements, if nonempty. -/
noncomputable def BerggrenSg.commonPrefix? (A B : BerggrenSg) : Option BerggrenSg :=
  match lcpList (fsToList (BerggrenSg.nf A)) (fsToList (BerggrenSg.nf B)) with
  | [] => none
  | a :: as => some (BerggrenSg.ofWord ⟨a, as⟩)

namespace BerggrenSg

/-- When the common prefix is nonempty, it gives the greatest lower bound. -/
theorem exists_inf_leftDivides_of_common_prefix (A B : BerggrenSg)
    (g : BGen) (gs : List BGen)
    (hlcp : lcpList (fsToList (nf A)) (fsToList (nf B)) = g :: gs) :
    let G := ofWord ⟨g, gs⟩
    LeftDivides G A ∧ LeftDivides G B ∧
    ∀ H : BerggrenSg, LeftDivides H A → LeftDivides H B → LeftDivides H G := by
  intro G
  have hGA : (fsToList (nf G)) <+: fsToList (nf A) := by
    rw [nf_ofWord]; show (g :: gs) <+: _
    rw [← hlcp]; exact lcpList_is_prefix_left _ _
  have hGB : (fsToList (nf G)) <+: fsToList (nf B) := by
    rw [nf_ofWord]; show (g :: gs) <+: _
    rw [← hlcp]; exact lcpList_is_prefix_right _ _
  refine ⟨(leftDivides_iff_prefix G A).mpr ((isPrefixFS_iff _ _).mpr hGA),
          (leftDivides_iff_prefix G B).mpr ((isPrefixFS_iff _ _).mpr hGB), ?_⟩
  intro H hHA hHB
  rw [leftDivides_iff_prefix] at hHA hHB ⊢
  rw [isPrefixFS_iff] at hHA hHB ⊢
  rw [nf_ofWord]; show _ <+: (g :: gs)
  rw [← hlcp]
  exact lcpList_greatest _ _ _ hHA hHB

/-- The common prefix list is always the longest common prefix:
    it is a prefix of both, and it is the greatest such. -/
theorem lcpList_is_greatest_common_prefix (l₁ l₂ : List BGen) :
    lcpList l₁ l₂ <+: l₁ ∧ lcpList l₁ l₂ <+: l₂ ∧
    ∀ p, p <+: l₁ → p <+: l₂ → p <+: lcpList l₁ l₂ :=
  ⟨lcpList_is_prefix_left l₁ l₂, lcpList_is_prefix_right l₁ l₂,
   fun p h1 h2 => lcpList_greatest l₁ l₂ p h1 h2⟩

/-- Common prefixes of two words form a chain under the prefix order. -/
theorem common_prefixes_form_chain (u v : FreeSemigroup BGen)
    (p q : FreeSemigroup BGen) (hp : IsPrefixFS p u) (hq : IsPrefixFS q u)
    (hp' : IsPrefixFS p v) (hq' : IsPrefixFS q v) :
    IsPrefixFS p q ∨ IsPrefixFS q p := by
  rw [isPrefixFS_iff] at hp hq hp' hq'
  rw [isPrefixFS_iff, isPrefixFS_iff]
  exact List.prefix_or_prefix_of_prefix hp hq

/-! ## Oracle reduction: prefix recovery → secret extraction -/

/-- **Secret suffix uniqueness**: for any `A` and `T`, the suffix `U` such that
    `nf (A * T) = nf A * U` exists and is unique. -/
theorem secret_suffix_unique (A T : BerggrenSg) :
    ∃! U : FreeSemigroup BGen, nf (A * T) = nf A * U :=
  ⟨nf T, nf_mul A T, fun U hU => by rw [nf_mul] at hU; exact fs_left_cancel hU.symm⟩

/-- When `A` strictly left-divides `B` via `C`, the suffix is uniquely `nf C`. -/
theorem strict_prefix_recovery
    (A B C : BerggrenSg) (hC : B = A * C) :
    ∃! t : FreeSemigroup BGen, nf B = nf A * t :=
  ⟨nf C, by rw [hC, nf_mul],
   fun t' ht' => by rw [hC, nf_mul] at ht'; exact fs_left_cancel ht'.symm⟩

/-- **Main oracle reduction theorem**: an oracle that, given images of `A` and `A * T`
    under a semigroup homomorphism, returns `nf A`, enables unique recovery of `nf T`. -/
theorem oracle_reduction_to_secret
    {G : Type*} [Mul G]
    (ψ : MulHom BerggrenSg G)
    (O : G → G → Option (FreeSemigroup BGen))
    (A T : BerggrenSg)
    (hO : O (ψ A) (ψ (A * T)) = some (nf A)) :
    ∃! U : FreeSemigroup BGen, nf (A * T) = nf A * U :=
  secret_suffix_unique A T

end BerggrenSg