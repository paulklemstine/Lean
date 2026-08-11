import Mathlib
import Novelty.MindToolsTranslations

/-!
# Conservativity, faithfulness, and reflection-style strict extensions

This file continues the resource-bounded reading of "mind tools" of
`Catalog/Novelty/MindToolsBoundedApprehension.lean` and
`Catalog/Novelty/MindToolsTranslations.lean`, which build on the extensional
framework of `Catalog/Logic/MindTools.lean`.

Two remaining items of the stated programme are carried out.

* **Conservative and faithful interpretations (extension 4).**  We define
  `ConservativeOver Q P F` ("`Q` proves no new `F`-sentence over `P`") and
  `Translation.Faithful`.  Conservativity over the *whole* language collapses
  strength (`not_stronger_of_conservative`), while conservativity over a
  proper fragment does not (`exists_conservative_fragment_and_stronger`).  The
  key point for the programme is `faithful_translation_not_bounded_cognitive`:
  there is a *faithful* translation — the two systems prove literally the same
  sentences — whose inverse must inflate every budget beyond every polynomial.
  Expressive convenience, extensional strength and resource-bounded cognitive
  extension are therefore three genuinely different things, and the middle one
  is the coarsest.

* **Reflection-style strict extensions (extension 8).**  A `Diagonal` operator
  assigns to each finite theory a sentence that theory does not prove — the
  extensional shadow of a consistency or reflection statement for a sound
  metatheory.  Iterating it produces the hierarchy `iterTool`, an
  *unconditional* strictly ascending, ordinal-ranked, well-founded chain in
  which every stage is a mind tool for the previous stage
  (`iterTool_isMindTool`), and whose union strictly dominates every stage
  (`stronger_iterLimit`).  Crucially the cognitive premise is *not* assumed: it
  is proved for the concrete diagonal operator `natDiag` on `ℕ`
  (`natDiag_diagonal`), which makes the whole chain unconditional
  (`exists_unconditional_reflection_chain`), and the stages are computed
  exactly (`iter_natDiag_empty`).

* **Linear-budget interleaving.**  Mutual translations with linear bounds
  interleave the two apprehension chains (`apprehends_interleave_linear`), so
  every mind-tool certificate transfers at a linearly related budget
  (`isMindTool_transfer_linear`).
-/

namespace MindTools
namespace Bounded

universe u

variable {Sentence : Type u}

/-! ## Conservativity and faithfulness (extension 4) -/

/-- `Q` is **conservative over** `P` for the fragment `F` when every
`F`-sentence provable in `Q` is already provable in `P`. -/
def ConservativeOver (Q P : FormalSystem Sentence) (F : Set Sentence) : Prop :=
  ∀ s ∈ F, s ∈ Q.provable → s ∈ P.provable

/-- Conservativity is inherited by smaller fragments. -/
theorem ConservativeOver.mono {Q P : FormalSystem Sentence} {F G : Set Sentence}
    (h : ConservativeOver Q P F) (hGF : G ⊆ F) : ConservativeOver Q P G :=
  fun s hs => h s (hGF hs)

/-- Every theory is conservative over itself. -/
theorem conservativeOver_self (P : FormalSystem Sentence) (F : Set Sentence) :
    ConservativeOver P P F := fun _ _ h => h

/-- Conservativity over the whole language, for an extension, means the two
theories are literally equal. -/
theorem provable_eq_of_conservative {Q P : FormalSystem Sentence}
    (hext : P.provable ⊆ Q.provable) (hcons : ConservativeOver Q P Set.univ) :
    Q.provable = P.provable :=
  Set.Subset.antisymm (fun s hs => hcons s (Set.mem_univ s) hs) hext

/-- A conservative extension is never proof-theoretically stronger: this is the
exact sense in which conservativity rules out extensional gain. -/
theorem not_stronger_of_conservative {Q P : FormalSystem Sentence}
    (hcons : ConservativeOver Q P Set.univ) : ¬ Stronger Q P := by
  rintro ⟨-, hne⟩
  exact hne fun s hs => hcons s (Set.mem_univ s) hs

/-- Conservativity over a *fragment* is much weaker: the theory of all naturals
is conservative over the theory of the even ones for the fragment of even
sentences, yet strictly stronger.  So "no new theorems in the old part of the
language" does not mean "no new theorems". -/
theorem exists_conservative_fragment_and_stronger :
    ∃ (P Q : FormalSystem ℕ) (F : Set ℕ),
      P.provable ⊆ Q.provable ∧ ConservativeOver Q P F ∧ Stronger Q P := by
  refine ⟨⟨{n | Even n}⟩, ⟨Set.univ⟩, {n | Even n}, fun _ _ => trivial,
    fun s hs _ => hs, ⟨fun _ _ => trivial, fun h => ?_⟩⟩
  have h1 : (1 : ℕ) ∈ ({n | Even n} : Set ℕ) := h (Set.mem_univ 1)
  simp at h1

namespace Translation

variable {P Q : ProofSystem Sentence}

/-- A translation is **faithful** when it creates no new theorems: the target
theory is contained in the source theory, hence (with `theory_subset`) equal to
it.  This is the resource-sensitive analogue of a faithful interpretation. -/
def Faithful (_t : Translation P Q) : Prop :=
  (theory Q).provable ⊆ (theory P).provable

/-- A faithful translation makes the two theories equal. -/
theorem theory_eq_of_faithful {t : Translation P Q} (h : t.Faithful) :
    (theory Q).provable = (theory P).provable :=
  Set.Subset.antisymm h t.theory_subset

/-- A faithful translation is a conservative extension in the sense above. -/
theorem conservativeOver_of_faithful {t : Translation P Q} (h : t.Faithful) :
    ConservativeOver (theory Q) (theory P) Set.univ :=
  fun _ _ hs => h hs

/-- Hence a faithfully translated system is never extensionally stronger. -/
theorem not_stronger_of_faithful {t : Translation P Q} (h : t.Faithful) :
    ¬ Stronger (theory Q) (theory P) :=
  not_stronger_of_conservative (conservativeOver_of_faithful h)

end Translation

/-- The free translation of the unary length code into the optimal numeral code
is faithful: both systems prove exactly the sentences `ℕ`. -/
theorem lengthToBcode_faithful : lengthToBcode.Faithful := by
  intro s _
  rw [lengthSystem_theory]
  trivial

/-- **Faithfulness does not bound cognitive extension.**  There is a faithful
translation — so the two proof systems prove exactly the same sentences and
neither is extensionally stronger — for which every translation back inflates
budgets beyond every polynomial.  Extensional strength is therefore strictly
coarser than resource-bounded cognitive extension, which is the separation
promised by extension 4. -/
theorem faithful_translation_not_bounded_cognitive :
    lengthToBcode.Faithful ∧
      ¬ Stronger (theory (binary bcode)) (theory lengthSystem) ∧
      ∀ (t : Translation (binary bcode) lengthSystem) (c k : ℕ),
        ∃ b : ℕ, c * b ^ k + c < t.bound b :=
  ⟨lengthToBcode_faithful,
    Translation.not_stronger_of_faithful lengthToBcode_faithful,
    no_polynomial_translation_bcode_to_lengthSystem⟩

/-- Two systems with the *same* theory can nevertheless have strictly nested
bounded profiles: at every positive budget the numeral code apprehends strictly
more than the length code.  A conservative (indeed theory-preserving) extension
can be a genuine cognitive extension. -/
theorem apprehends_lengthSystem_ssubset_bcode {b : ℕ} (hb : 1 ≤ b) :
    (apprehends lengthSystem b).direct ⊂ (apprehends (binary bcode) b).direct := by
  have hb1 : b < 2 ^ b := Nat.lt_two_pow_self
  have he : (2:ℕ) ^ (b + 1) = 2 * 2 ^ b := by ring
  rw [lengthSystem_apprehends, bcode_apprehends]
  constructor
  · intro n hn
    simp only [Set.mem_Iic] at hn
    simp only [Set.mem_setOf_eq]
    omega
  · intro hsub
    have : b + 1 ∈ Set.Iic b := hsub (by simp only [Set.mem_setOf_eq]; omega)
    simp at this

/-! ## Linear-budget interleaving -/

/-- Mutual translations interleave the two apprehension chains. -/
theorem apprehends_interleave {P Q : ProofSystem Sentence}
    (t : Translation P Q) (u : Translation Q P) (b : ℕ) :
    (apprehends P b).direct ⊆ (apprehends Q (t.bound b)).direct ∧
      (apprehends Q (t.bound b)).direct ⊆ (apprehends P (u.bound (t.bound b))).direct :=
  ⟨t.apprehends_subset b, u.apprehends_subset _⟩

/-- With linear bounds the interleaving is by linear budget changes. -/
theorem apprehends_interleave_linear {P Q : ProofSystem Sentence}
    (t : Translation P Q) (u : Translation Q P) {a c a' c' : ℕ}
    (ht : ∀ b, t.bound b ≤ a * b + c) (hu : ∀ b, u.bound b ≤ a' * b + c') (b : ℕ) :
    (apprehends P b).direct ⊆ (apprehends Q (a * b + c)).direct ∧
      (apprehends Q (a * b + c)).direct ⊆
        (apprehends P (a' * (a * b + c) + c')).direct := by
  refine ⟨(t.apprehends_subset b).trans (apprehends_mono Q (ht b)), ?_⟩
  exact (u.apprehends_subset (a * b + c)).trans (apprehends_mono P (hu _))

/-- Consequently every mind-tool certificate transfers along a linearly bounded
translation, at a linearly related budget. -/
theorem isMindTool_transfer_linear {P Q : ProofSystem Sentence}
    (t : Translation P Q) {a c : ℕ} (ht : ∀ b, t.bound b ≤ a * b + c) (b : ℕ)
    {s : Sentence} (hs : s ∈ (theory Q).provable)
    (hs' : s ∉ (apprehends Q (a * b + c)).direct) :
    IsMindTool (theory Q) (apprehends P b) := by
  refine isMindTool_of_witness _ _ ?_ hs (fun hmem => hs' ?_)
  · exact fun x hx => apprehends_subset_theory Q _ (t.apprehends_subset b hx)
  · exact apprehends_mono Q (ht b) (t.apprehends_subset b hmem)

/-! ## Reflection-style strict extensions (extension 8) -/

/-- A **diagonal operator** assigns to every finite theory a sentence that
theory does not prove.  This is the extensional content of a consistency or
reflection statement supplied by a sound metatheory: it is a *separately stated
assumption*, not a cognitive premise, and it is realised concretely below by
`natDiag`. -/
def Diagonal (g : Set Sentence → Sentence) : Prop :=
  ∀ X : Set Sentence, X.Finite → g X ∉ X

/-- The iterated reflection extension of a base theory. -/
def iter (g : Set Sentence → Sentence) (T : Set Sentence) : ℕ → Set Sentence
  | 0 => T
  | n + 1 => insert (g (iter g T n)) (iter g T n)

/-- The hierarchy of theories obtained by iterated reflection. -/
def iterTool (g : Set Sentence → Sentence) (T : Set Sentence) (n : ℕ) :
    FormalSystem Sentence := ⟨iter g T n⟩

variable {g : Set Sentence → Sentence} {T : Set Sentence}

@[simp] theorem iter_zero : iter g T 0 = T := rfl

@[simp] theorem iter_succ (n : ℕ) :
    iter g T (n + 1) = insert (g (iter g T n)) (iter g T n) := rfl

/-- Every stage of a finitely based hierarchy is finite. -/
theorem iter_finite (hT : T.Finite) : ∀ n, (iter g T n).Finite
  | 0 => hT
  | n + 1 => (iter_finite hT n).insert _

theorem iter_subset_succ (n : ℕ) : iter g T n ⊆ iter g T (n + 1) :=
  Set.subset_insert _ _

theorem iter_mono {m n : ℕ} (h : m ≤ n) : iter g T m ⊆ iter g T n := by
  induction n with
  | zero => simp [Nat.le_zero.1 h]
  | succ k ih =>
      rcases Nat.lt_or_ge m (k + 1) with hlt | hge
      · exact (ih (Nat.lt_succ_iff.1 hlt)).trans (iter_subset_succ k)
      · have : m = k + 1 := le_antisymm h hge
        subst this
        exact subset_rfl

/-- The sentence added at stage `n` is not provable at stage `n`. -/
theorem g_iter_not_mem (hg : Diagonal g) (hT : T.Finite) (n : ℕ) :
    g (iter g T n) ∉ iter g T n :=
  hg _ (iter_finite hT n)

theorem mem_iter_succ (n : ℕ) : g (iter g T n) ∈ iter g T (n + 1) :=
  Set.mem_insert _ _

/-- **Each stage strictly extends the previous one.** -/
theorem stronger_iterTool_succ (hg : Diagonal g) (hT : T.Finite) (n : ℕ) :
    Stronger (iterTool g T (n + 1)) (iterTool g T n) := by
  refine ⟨iter_subset_succ n, fun hsub => ?_⟩
  exact g_iter_not_mem hg hT n (hsub (mem_iter_succ n))

/-- The whole chain is strictly increasing. -/
theorem stronger_iterTool_of_lt (hg : Diagonal g) (hT : T.Finite) {m n : ℕ}
    (h : m < n) : Stronger (iterTool g T n) (iterTool g T m) := by
  refine ⟨iter_mono h.le, fun hsub => ?_⟩
  refine g_iter_not_mem hg hT m (hsub ?_)
  exact iter_mono h (mem_iter_succ m)

/-- Every stage is a mind tool for the direct-apprehension profile given by the
previous stage: the reflection step is exactly one theorem beyond reach. -/
theorem iterTool_isMindTool (hg : Diagonal g) (hT : T.Finite) (n : ℕ) :
    IsMindTool (iterTool g T (n + 1)) ⟨iter g T n⟩ :=
  isMindTool_of_witness _ _ (iter_subset_succ n) (mem_iter_succ n)
    (g_iter_not_mem hg hT n)

/-- The stage index is a concrete ordinal rank for the hierarchy. -/
theorem ordinalRanks_iterTool (hg : Diagonal g) (hT : T.Finite) :
    OrdinalRanks (iterTool g T) (fun n => (n : Ordinal.{0})) := by
  intro i j hij
  rcases lt_trichotomy i j with h | h | h
  · exact Nat.cast_lt.mpr h
  · subst h
    exact absurd subset_rfl hij.2
  · exact absurd (hij.1 : iter g T i ⊆ iter g T j)
      (fun hsub => g_iter_not_mem hg hT j (hsub (iter_mono h (mem_iter_succ j))))

/-- Hence the reflection hierarchy is well-founded. -/
theorem wellFounded_iterTool (hg : Diagonal g) (hT : T.Finite) :
    WellFounded (fun i j : ℕ => Stronger (iterTool g T j) (iterTool g T i)) :=
  hierarchy_wellFounded_of_ordinalRanks _ _ (ordinalRanks_iterTool hg hT)

/-- The limit theory: everything provable at some finite stage. -/
def iterLimit (g : Set Sentence → Sentence) (T : Set Sentence) :
    FormalSystem Sentence := ⟨⋃ n, iter g T n⟩

/-- The limit stage is strictly stronger than every finite stage, so the
reflection hierarchy does not stabilise. -/
theorem stronger_iterLimit (hg : Diagonal g) (hT : T.Finite) (n : ℕ) :
    Stronger (iterLimit g T) (iterTool g T n) := by
  refine ⟨Set.subset_iUnion _ n, fun hsub => ?_⟩
  refine g_iter_not_mem hg hT n (hsub ?_)
  exact Set.mem_iUnion.2 ⟨n + 1, mem_iter_succ n⟩

/-! ### A concrete diagonal operator, making the chain unconditional -/

/-- The least natural number a theory does not prove.  For finite theories this
is a genuine diagonal operator, so no unproved cognitive or metamathematical
premise is needed below. -/
noncomputable def natDiag (X : Set ℕ) : ℕ := sInf {n : ℕ | n ∉ X}

/-- `natDiag` really is a diagonal operator. -/
theorem natDiag_diagonal : Diagonal (natDiag) := by
  intro X hX
  have hne : {n : ℕ | n ∉ X}.Nonempty := by
    by_contra h
    rw [Set.not_nonempty_iff_eq_empty] at h
    have : X = Set.univ := by
      ext n
      simp only [Set.mem_univ, iff_true]
      by_contra hn
      have : n ∈ {m : ℕ | m ∉ X} := hn
      rw [h] at this
      exact this
    rw [this] at hX
    exact Set.infinite_univ hX
  exact Nat.sInf_mem hne

/-- **An unconditional reflection hierarchy.**  There is a family of theories
which is strictly ascending, ordinal-ranked, well-founded, in which every stage
is a mind tool for the previous stage, and which is strictly dominated by its
limit — with no cognitive premise and no unproved metamathematical assumption. -/
theorem exists_unconditional_reflection_chain :
    ∃ (tools : ℕ → FormalSystem ℕ) (limit : FormalSystem ℕ) (rank : ℕ → Ordinal.{0}),
      (∀ n, Stronger (tools (n + 1)) (tools n)) ∧
      (∀ m n, m < n → Stronger (tools n) (tools m)) ∧
      (∀ n, IsMindTool (tools (n + 1)) ⟨(tools n).provable⟩) ∧
      OrdinalRanks tools rank ∧
      WellFounded (fun i j : ℕ => Stronger (tools j) (tools i)) ∧
      (∀ n, Stronger limit (tools n)) := by
  have hT : (∅ : Set ℕ).Finite := Set.finite_empty
  exact ⟨iterTool natDiag ∅, iterLimit natDiag ∅, fun n => (n : Ordinal.{0}),
    fun n => stronger_iterTool_succ natDiag_diagonal hT n,
    fun _ _ h => stronger_iterTool_of_lt natDiag_diagonal hT h,
    fun n => iterTool_isMindTool natDiag_diagonal hT n,
    ordinalRanks_iterTool natDiag_diagonal hT,
    wellFounded_iterTool natDiag_diagonal hT,
    fun n => stronger_iterLimit natDiag_diagonal hT n⟩

/-- The stages of the concrete hierarchy are computed exactly: starting from the
empty theory, stage `n` proves precisely the sentences `0, …, n − 1`, and the
sentence added by reflection at stage `n` is exactly `n`. -/
theorem iter_natDiag_empty : ∀ n : ℕ, iter natDiag (∅ : Set ℕ) n = {k | k < n} := by
  intro n
  induction n with
  | zero => simp
  | succ m ih =>
      have hInf : natDiag {k : ℕ | k < m} = m := by
        have hmem : m ∈ {n : ℕ | n ∉ {k : ℕ | k < m}} := by
          simp
        refine le_antisymm (Nat.sInf_le hmem) ?_
        refine le_csInf ⟨m, hmem⟩ ?_
        intro x hx
        simpa using hx
      rw [iter_succ, ih, hInf]
      ext k
      simp only [Set.mem_insert_iff, Set.mem_setOf_eq]
      omega

/-- The limit of the concrete hierarchy is the complete theory. -/
theorem iterLimit_natDiag_empty :
    (iterLimit natDiag (∅ : Set ℕ)).provable = Set.univ := by
  ext k
  simp only [iterLimit, Set.mem_iUnion, Set.mem_univ, iff_true]
  exact ⟨k + 1, by rw [iter_natDiag_empty]; simp⟩

end Bounded
end MindTools