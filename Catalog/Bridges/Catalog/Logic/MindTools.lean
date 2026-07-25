import Mathlib.Order.WellFounded
import Mathlib.Data.Set.Lattice
import Mathlib.SetTheory.Ordinal.Basic

/-!
# Mind tools as strict extensions of direct apprehension

The informal phrase “the human brain can directly apprehend” has no canonical
mathematical definition.  This file therefore isolates it as a set-valued
parameter.  The resulting theorems state exactly which certificates are needed
for claims about a named formal system; in particular, no claim about ZFC is
smuggled in as an axiom.
-/

namespace MindTools

/-- A formal system, represented extensionally by the sentences it proves. -/
structure FormalSystem (Sentence : Type*) where
  provable : Set Sentence

/-- A cognitive profile, represented by the sentences directly apprehended. -/
structure CognitiveProfile (Sentence : Type*) where
  direct : Set Sentence

/-- A system is a mind tool when direct apprehension is a proper subset of its
provable sentences. -/
def IsMindTool {Sentence : Type*} (F : FormalSystem Sentence)
    (H : CognitiveProfile Sentence) : Prop :=
  H.direct ⊂ F.provable

/-- Proof-theoretic comparison, deliberately restricted to a fixed language. -/
def Stronger {Sentence : Type*} (F G : FormalSystem Sentence) : Prop :=
  G.provable ⊂ F.provable

/-
The simplest usable certificate for a mind tool consists of containment and
one theorem outside direct apprehension.
-/
theorem isMindTool_iff_certificate {Sentence : Type*} (F : FormalSystem Sentence)
    (H : CognitiveProfile Sentence) :
    IsMindTool F H ↔
      H.direct ⊆ F.provable ∧ ∃ sentence, sentence ∈ F.provable ∧ sentence ∉ H.direct := by
  constructor;
  · exact fun h => ⟨ h.1, Set.exists_of_ssubset h ⟩;
  · exact fun h => ⟨ h.1, fun h' => h.2.choose_spec.2 ( h' h.2.choose_spec.1 ) ⟩

/-
A concrete inaccessible theorem and closure of direct reasoning certify a
mind tool.
-/
theorem isMindTool_of_witness {Sentence : Type*} (F : FormalSystem Sentence)
    (H : CognitiveProfile Sentence) (hclosed : H.direct ⊆ F.provable)
    {sentence : Sentence} (hproof : sentence ∈ F.provable)
    (hinaccessible : sentence ∉ H.direct) : IsMindTool F H := by
  exact ⟨ hclosed, fun h => hinaccessible <| h hproof ⟩

/-
Strictly increasing proof strength preserves the mind-tool property.
-/
theorem IsMindTool.upward_one {Sentence : Type*} {F G : FormalSystem Sentence}
    {H : CognitiveProfile Sentence} (hF : IsMindTool F H)
    (hGF : Stronger G F) : IsMindTool G H := by
  simp_all +decide [ IsMindTool, Stronger ];
  grind +qlia

/-
Proof-theoretic strength is transitive.
-/
theorem Stronger.trans {Sentence : Type*} {F G K : FormalSystem Sentence}
    (hFG : Stronger F G) (hGK : Stronger G K) : Stronger F K := by
  refine' ⟨ Set.Subset.trans hGK.1 hFG.1, fun h => _ ⟩;
  exact hFG.2 ( Set.Subset.trans h hGK.1 )

/-
Consequently an entire two-step hierarchy above a mind tool still extends
cognition.
-/
theorem IsMindTool.upward_two {Sentence : Type*} {F G K : FormalSystem Sentence}
    {H : CognitiveProfile Sentence} (hK : IsMindTool K H)
    (hGK : Stronger G K) (hFG : Stronger F G) : IsMindTool F H := by
  exact IsMindTool.upward_one ( IsMindTool.upward_one hK hGK ) hFG

/-
A faithful formal version of the proposed ZFC claim: a formalized ZFC is a
mind tool once supplied with closure and a specific ZFC theorem not directly
apprehended.  Gödel incompleteness alone does not manufacture the final premise.
-/
theorem zfc_isMindTool_of_certificate {Sentence : Type*}
    (ZFC : FormalSystem Sentence) (human : CognitiveProfile Sentence)
    (direct_reasoning_formalizable : human.direct ⊆ ZFC.provable)
    (godelianTheorem : Sentence) (zfc_proves : godelianTheorem ∈ ZFC.provable)
    (not_directly_apprehended : godelianTheorem ∉ human.direct) :
    IsMindTool ZFC human := by
  exact Set.ssubset_iff_subset_ne.mpr ⟨ direct_reasoning_formalizable, fun h => not_directly_apprehended ( h.symm ▸ zfc_proves ) ⟩

/-- A class of problems is represented by the sentences encoding those
problems.  Uniform power means proving every sentence in that class. -/
def SolvesClass {Sentence : Type*} (F : FormalSystem Sentence)
    (problems : Set Sentence) : Prop :=
  problems ⊆ F.provable

/-
A stronger tool inherits every uniformly solved class.
-/
theorem Stronger.solvesClass {Sentence : Type*} {F G : FormalSystem Sentence}
    {problems : Set Sentence} (hFG : Stronger F G)
    (hsolves : SolvesClass G problems) : SolvesClass F problems := by
  exact fun x hx => hFG.1 ( hsolves hx )

/-
A uniform family plus one genuinely new theorem yields strict superiority.
This captures the precise content available from “all categories at once”:
uniformity is useful only when accompanied by a theorem unavailable below.
-/
theorem stronger_of_uniform_class_and_separation {Sentence : Type*}
    (categoryTool setTool : FormalSystem Sentence) (categoricalProblems : Set Sentence)
    (setContained : setTool.provable ⊆ categoryTool.provable)
    (uniform : SolvesClass categoryTool categoricalProblems)
    {universalTheorem : Sentence} (belongs : universalTheorem ∈ categoricalProblems)
    (setCannotProve : universalTheorem ∉ setTool.provable) :
    Stronger categoryTool setTool := by
  constructor;
  · assumption;
  · exact fun h => setCannotProve <| h <| uniform belongs

/-
The uniform categorical certificate also transports the mind-tool property
from the weaker set-theoretic tool.
-/
theorem categorical_mindTool_of_uniform_separation {Sentence : Type*}
    (categoryTool setTool : FormalSystem Sentence) (human : CognitiveProfile Sentence)
    (categoricalProblems : Set Sentence) (setMindTool : IsMindTool setTool human)
    (setContained : setTool.provable ⊆ categoryTool.provable)
    (uniform : SolvesClass categoryTool categoricalProblems)
    {universalTheorem : Sentence} (belongs : universalTheorem ∈ categoricalProblems)
    (setCannotProve : universalTheorem ∉ setTool.provable) :
    IsMindTool categoryTool human := by
  apply IsMindTool.upward_one setMindTool
  exact stronger_of_uniform_class_and_separation categoryTool setTool
    categoricalProblems setContained uniform belongs setCannotProve

/-- A hierarchy indexed by `ι` is ranked by ordinals when strict tool strength
always produces a strict increase of rank. -/
def OrdinalRanks {ι Sentence : Type*} (tools : ι → FormalSystem Sentence)
    (rank : ι → Ordinal) : Prop :=
  ∀ i j, Stronger (tools j) (tools i) → rank i < rank j

/-
The proposed ordinal ranking has a rigorous consequence: there is no
infinite descending chain of tools whose direction is strict increase in
proof-theoretic strength.
-/
theorem hierarchy_wellFounded_of_ordinalRanks {ι Sentence : Type*}
    (tools : ι → FormalSystem Sentence) (rank : ι → Ordinal)
    (hrank : OrdinalRanks tools rank) :
    WellFounded (fun i j => Stronger (tools j) (tools i)) := by
  rw [WellFounded.wellFounded_iff_has_min]
  intro s hs
  obtain ⟨m, hm⟩ : ∃ m ∈ Set.image rank s,
      ∀ n ∈ Set.image rank s, m ≤ n := by
    exact ⟨InfSet.sInf (rank '' s), csInf_mem (Set.Nonempty.image _ hs),
      fun n hn => csInf_le' hn⟩
  rcases hm with ⟨⟨x, hx, rfl⟩, hm⟩
  exact ⟨x, hx, fun y hy hxy =>
    not_lt_of_ge (hm _ (Set.mem_image_of_mem _ hy)) (hrank _ _ hxy)⟩

end MindTools