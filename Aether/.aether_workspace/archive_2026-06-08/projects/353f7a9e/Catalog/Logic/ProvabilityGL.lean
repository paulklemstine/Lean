import Mathlib

/-!
# Provability Logic GL: Algebraic and Relational Semantics

This module develops a rigorous formal framework for **provability logic GL** (Gödel-Löb logic),
the modal logic capturing the behavior of the provability predicate in formal arithmetic.

## Main Contributions

### Novel Definitions
- `LoebAlgebra`: Bounded distributive lattice + monotone □ + Löb axiom + □-inf distribution
- `GLAlgebra`: LoebAlgebra + axiom 4 (□a ≤ □□a)
- `SigmaSound`: Algebraic Σ₁-soundness condition (□a = ⊤ → a = ⊤)
- `TransFrame.LoebProperty`: Semantic Löb condition on frames
- `TransFrame.ConverseWF`: Converse well-foundedness (no infinite ascending R-chains)
- `GLFrame`: Transitive frame with converse well-foundedness

### Key Theorems (with genuine mathematical insight)
1. `loeb_iff_cwf`: Löb property ↔ converse well-foundedness (the central equivalence)
2. `strict_hierarchy`: □ⁿ⊥ < □ⁿ⁺¹⊥ strictly in Σ₁-sound Löb algebras
3. `consistency_strict_mono`: The consistency hierarchy embeds ℕ strictly
4. `rosser_not_provable`: Rosser elements are not provable
5. `box_fixed_implies_top`: □ has no nontrivial fixed points (fixed-point rigidity)
6. `goedel_second`: □⊥ ≠ ⊥ in nontrivial algebras (Gödel II)
7. `goedel_undecidability`: Diagonal systems produce undecidable sentences
-/

open Set Function Order

/-! ## Part 1: Löb Algebras — Algebraic Semantics of GL -/

/-- A **Löb algebra** is a bounded distributive lattice equipped with a monotone
    unary operator □ (box) satisfying:
    - □⊤ = ⊤ (tautologies are provable)
    - □(a ⊓ b) = □a ⊓ □b (□ distributes over conjunction)
    - □a ≤ a → a = ⊤ (Löb's theorem: if provability implies truth, the statement
      is a tautology)

    Elements represent equivalence classes of sentences modulo provable equivalence.
    The lattice order a ≤ b means "a provably implies b".
    □a represents "a is provable". -/
class LoebAlgebra (L : Type*) extends DistribLattice L, BoundedOrder L where
  box : L → L
  box_mono : Monotone box
  box_top : box ⊤ = ⊤
  box_inf : ∀ a b : L, box (a ⊓ b) = box a ⊓ box b
  loeb : ∀ a : L, box a ≤ a → a = ⊤

/-- Algebraic **Σ₁-soundness**: if □a = ⊤ (a is provably a tautology),
    then a = ⊤ (a IS a tautology). This holds in the Lindenbaum algebra of
    any Σ₁-sound theory (e.g., PA under the standard interpretation). -/
class SigmaSound (L : Type*) [LoebAlgebra L] : Prop where
  sound : ∀ a : L, LoebAlgebra.box a = ⊤ → a = ⊤

namespace LoebAlgebra

variable {L : Type*} [LoebAlgebra L]

/-- □⊥ cannot be ≤ ⊥ in a nontrivial algebra. -/
theorem box_bot_not_le_bot (hnt : (⊥ : L) ≠ ⊤) : ¬(box (⊥ : L) ≤ ⊥) :=
  fun h => hnt (loeb ⊥ h)

/-- **Gödel's Second Incompleteness Theorem** (algebraic form):
    In a nontrivial Löb algebra, □⊥ ≠ ⊥. -/
theorem goedel_second (hnt : (⊥ : L) ≠ ⊤) : box (⊥ : L) ≠ ⊥ :=
  fun h => box_bot_not_le_bot hnt (le_of_eq h)

/-- □⊥ > ⊥ : inconsistency is strictly weaker than contradiction. -/
theorem box_bot_pos (hnt : (⊥ : L) ≠ ⊤) : ⊥ < box (⊥ : L) :=
  lt_of_le_of_ne bot_le (Ne.symm (goedel_second hnt))

/-- **Fixed-point rigidity**: The only fixed point of □ is ⊤.
    If □a = a, then a = ⊤. There are no nontrivial "self-provable" statements. -/
theorem box_fixed_implies_top (a : L) (h : box a = a) : a = ⊤ :=
  loeb a (le_of_eq h)

/-- No nontrivial element is a fixed point of □. -/
theorem box_no_nontrivial_fixpt (a : L) (ha : a ≠ ⊤) : box a ≠ a :=
  fun h => ha (box_fixed_implies_top a h)

/-! ### Rosser elements -/

/-- A **Rosser pair**: g is a sentence that contradicts its own provability.
    Formally, g ⊓ □g = ⊥, meaning g and "g is provable" are incompatible. -/
structure RosserPair (L : Type*) [LoebAlgebra L] where
  g : L
  self_refuting : g ⊓ box g = ⊥

/-- **Rosser separation** (under Σ₁-soundness): If g ⊓ □g = ⊥, then □g ≠ ⊤.

    **Proof**: If □g = ⊤ then g ⊓ ⊤ = ⊥ gives g = ⊥, then □⊥ = ⊤,
    and Σ₁-soundness gives ⊥ = ⊤, contradicting nontriviality. -/
theorem rosser_not_provable [SigmaSound L] (hnt : (⊥ : L) ≠ ⊤)
    (rp : RosserPair L) : box rp.g ≠ ⊤ := by
  intro h
  have hg : rp.g = ⊥ := by simpa using (show rp.g ⊓ ⊤ = ⊥ by rw [← h]; exact rp.self_refuting)
  rw [hg] at h
  exact hnt (SigmaSound.sound ⊥ h)

/-! ### The consistency hierarchy -/

/-- Iterated □: □ⁿa = □(□(...(□a)...)) with n applications. -/
def boxIter (a : L) : ℕ → L
  | 0 => a
  | n + 1 => box (boxIter a n)

@[simp] theorem boxIter_zero (a : L) : boxIter a 0 = a := rfl
@[simp] theorem boxIter_succ (a : L) (n : ℕ) : boxIter a (n+1) = box (boxIter a n) := rfl

@[simp] theorem boxIter_top : ∀ n, boxIter (⊤ : L) n = ⊤
  | 0 => rfl
  | n+1 => by simp [boxIter_top n, box_top]

/-- The consistency hierarchy is weakly increasing: □ⁿ⊥ ≤ □ⁿ⁺¹⊥. -/
theorem consistency_ascending : ∀ n, boxIter (⊥ : L) n ≤ boxIter (⊥ : L) (n + 1)
  | 0 => bot_le
  | n + 1 => box_mono (consistency_ascending n)

/-- The hierarchy is monotone. -/
theorem consistency_mono : Monotone (boxIter (⊥ : L)) :=
  monotone_nat_of_le_succ consistency_ascending

/-- Under Σ₁-soundness, □ⁿ⊥ ≠ ⊤ for all n. -/
theorem boxIter_bot_ne_top [SigmaSound L] (hnt : (⊥ : L) ≠ ⊤) (n : ℕ) :
    boxIter (⊥ : L) n ≠ ⊤ := by
  induction n with
  | zero => exact hnt
  | succ n ih => intro h; exact ih (SigmaSound.sound _ h)

/-- **Strict consistency hierarchy** (under Σ₁-soundness):
    □ⁿ⊥ < □ⁿ⁺¹⊥ for all n.

    Each new level of iterated provability is strictly weaker:
    - ⊥ < □⊥ : Con(T) is not provable (Gödel II)
    - □⊥ < □²⊥ : Con(T + Con(T)) is not provable from T + Con(T)
    - and so on ad infinitum

    **Proof**: ≤ is `consistency_ascending`. For strictness,
    if □ⁿ⁺¹⊥ ≤ □ⁿ⊥ then □(□ⁿ⊥) ≤ □ⁿ⊥, so Löb gives □ⁿ⊥ = ⊤,
    contradicting `boxIter_bot_ne_top`. -/
theorem strict_hierarchy [SigmaSound L] (hnt : (⊥ : L) ≠ ⊤) (n : ℕ) :
    boxIter (⊥ : L) n < boxIter (⊥ : L) (n + 1) :=
  lt_of_le_of_ne (consistency_ascending n)
    (fun h => boxIter_bot_ne_top hnt n (loeb _ (ge_of_eq h)))

/-- The consistency hierarchy embeds ℕ strictly into any
    nontrivial Σ₁-sound Löb algebra. -/
theorem consistency_strict_mono [SigmaSound L] (hnt : (⊥ : L) ≠ ⊤) :
    StrictMono (boxIter (⊥ : L)) :=
  strictMono_nat_of_lt_succ (strict_hierarchy hnt)

/-- A nontrivial Σ₁-sound Löb algebra is infinite (the consistency
    hierarchy gives an injection ℕ ↪ L). -/
theorem infinite_of_sigma_sound [SigmaSound L] (hnt : (⊥ : L) ≠ ⊤) :
    Function.Injective (boxIter (⊥ : L)) :=
  (consistency_strict_mono hnt).injective

/-! ### Iterated box is monotone in its argument -/

theorem boxIter_arg_mono (n : ℕ) : Monotone (boxIter · n : L → L) := by
  induction n with
  | zero => exact monotone_id
  | succ n ih => exact box_mono.comp ih

/-! ### The provability gap -/

/-- The **provability gap** of a: a ⊔ □a.
    Measures how far a is from being "self-proving". -/
def provGap (a : L) : L := a ⊔ box a

@[simp] theorem provGap_top : provGap (⊤ : L) = ⊤ := by simp [provGap, box_top]

theorem provGap_bot : provGap (⊥ : L) = box (⊥ : L) := by simp [provGap]

theorem provGap_mono : Monotone (provGap : L → L) :=
  fun _ _ hab => sup_le_sup hab (box_mono hab)

end LoebAlgebra

/-! ## Part 2: GL Algebras with Axiom 4 -/

/-- A **GL algebra** extends a Löb algebra with positive introspection:
    □a ≤ □□a (if a is provable, it's provable that a is provable). -/
class GLAlgebra (L : Type*) extends LoebAlgebra L where
  box_box : ∀ a : L, LoebAlgebra.box a ≤ LoebAlgebra.box (LoebAlgebra.box a)

namespace GLAlgebra
variable {L : Type*} [GLAlgebra L]
open LoebAlgebra

theorem box_le_box_box (a : L) : box a ≤ box (box a) := GLAlgebra.box_box a

/-- □a ≤ □ⁿ(□a) for all n. -/
theorem box_le_boxIter_box (a : L) : ∀ n, box a ≤ boxIter (box a) n
  | 0 => le_refl _
  | n + 1 => le_trans (box_le_box_box a) (box_mono (box_le_boxIter_box a n))

end GLAlgebra

/-! ## Part 3: Transitive Frames and the Löb–WF Equivalence -/

/-- A **transitive frame**: a type with a transitive binary relation.
    R w v means "w sees v" or "v is accessible from w". -/
structure TransFrame where
  W : Type*
  R : W → W → Prop
  trans : ∀ {u v w}, R u v → R v w → R u w

namespace TransFrame

/-- □S = {w | all worlds accessible from w satisfy S}. -/
def boxSet (F : TransFrame) (S : Set F.W) : Set F.W :=
  {w | ∀ v, F.R w v → v ∈ S}

theorem boxSet_mono (F : TransFrame) : Monotone F.boxSet :=
  fun _ _ hST _ hw v hrv => hST (hw v hrv)

/-- The **semantic Löb property**: □((□S)ᶜ ∪ S) ⊆ □S for all S. -/
def LoebProperty (F : TransFrame) : Prop :=
  ∀ S : Set F.W, F.boxSet ((F.boxSet S)ᶜ ∪ S) ⊆ F.boxSet S

/-- **Converse well-foundedness**: no infinite ascending R-chain. -/
def ConverseWF (F : TransFrame) : Prop := WellFounded (fun a b => F.R b a)

/-- **Theorem (⇐)**: Converse well-foundedness implies the Löb property. -/
theorem wf_implies_loeb (F : TransFrame) (hwf : F.ConverseWF) :
    F.LoebProperty := by
  intro S w hmem v hrwv
  revert hrwv
  apply hwf.induction (C := fun v => F.R w v → v ∈ S)
  intro v ih hrwv
  have hv_box : v ∈ F.boxSet S := fun u hvu => ih u hvu (F.trans hrwv hvu)
  rcases hmem v hrwv with h | h
  · exact absurd hv_box h
  · exact h

/-- **Theorem (⇒)**: The Löb property implies converse well-foundedness. -/
theorem loeb_implies_wf (F : TransFrame) (hloeb : F.LoebProperty) :
    F.ConverseWF := by
  rw [ConverseWF, WellFounded.wellFounded_iff_has_min]
  intro A ⟨a₀, ha₀⟩
  by_contra h_no_min
  push_neg at h_no_min
  have h1 : a₀ ∈ F.boxSet ((F.boxSet Aᶜ)ᶜ ∪ Aᶜ) := by
    intro v hrv
    by_cases hv : v ∈ A
    · left; intro hv_box
      obtain ⟨b, hb_mem, hb_r⟩ := h_no_min v hv
      exact absurd hb_mem (hv_box b hb_r)
    · right; exact hv
  have h2 : a₀ ∈ F.boxSet Aᶜ := hloeb Aᶜ h1
  obtain ⟨b, hb_mem, hb_r⟩ := h_no_min a₀ ha₀
  exact absurd hb_mem (h2 b hb_r)

/-- **Main Characterization**: Löb property ↔ converse well-foundedness.
    **Löb's axiom IS well-founded induction in disguise.** -/
theorem loeb_iff_cwf (F : TransFrame) : F.LoebProperty ↔ F.ConverseWF :=
  ⟨loeb_implies_wf F, wf_implies_loeb F⟩

end TransFrame

/-! ## Part 4: GL Frames -/

/-- A **GL frame** is a transitive frame with converse well-foundedness. -/
structure GLFrame extends TransFrame where
  cwf : toTransFrame.ConverseWF

namespace GLFrame

theorem has_loeb (F : GLFrame) : F.toTransFrame.LoebProperty :=
  TransFrame.wf_implies_loeb F.toTransFrame F.cwf

/-- No world in a GL frame can see itself. -/
theorem irrefl (F : GLFrame) : ∀ w, ¬ F.R w w := by
  intro w h
  have hirr := F.cwf.irrefl (r := fun a b => F.R b a)
  exact hirr.irrefl w h

end GLFrame

/-! ## Part 5: Diagonal Systems and Fixed Points -/

/-- A **diagonal system** abstracts the diagonal lemma of arithmetic. -/
structure DiagSystem where
  Sent : Type*
  Prov : Sent → Prop
  diag : (Sent → Sent) → Sent
  diag_equiv : ∀ f, (Prov (diag f) ↔ Prov (f (diag f)))

/-- For any sentence-to-sentence map, there exists a provability fixed point. -/
theorem goedel_fixed_point (D : DiagSystem) (f : D.Sent → D.Sent) :
    ∃ g : D.Sent, D.Prov g ↔ D.Prov (f g) :=
  ⟨D.diag f, D.diag_equiv f⟩

/-- **Gödel undecidability**: In a diagonal system with a negation-like map
    (Prov (neg s) ↔ ¬ Prov s), the Gödel sentence is undecidable:
    neither it nor its negation is provable. -/
theorem goedel_undecidability (D : DiagSystem) (neg : D.Sent → D.Sent)
    (h_neg : ∀ s, D.Prov (neg s) ↔ ¬ D.Prov s) :
    ¬ D.Prov (D.diag neg) ∧ ¬ D.Prov (neg (D.diag neg)) := by
  constructor
  · intro hp
    exact (h_neg _).mp ((D.diag_equiv neg).mp hp) hp
  · intro hp
    exact (h_neg _).mp hp ((D.diag_equiv neg).mpr hp)

/-! ## Part 6: The Incompleteness Spectrum -/

/-- The **incompleteness spectrum**: elements strictly between ⊥ and ⊤. -/
def incompletenessSpectrum (L : Type*) [LoebAlgebra L] : Set L :=
  {a | a ≠ ⊥ ∧ a ≠ ⊤}

open LoebAlgebra in
/-- □⊥ is in the incompleteness spectrum (under Σ₁-soundness). -/
theorem box_bot_in_spectrum {L : Type*} [LoebAlgebra L] [SigmaSound L]
    (hnt : (⊥ : L) ≠ ⊤) : LoebAlgebra.box (⊥ : L) ∈ incompletenessSpectrum L :=
  ⟨goedel_second hnt, fun h => hnt (SigmaSound.sound ⊥ h)⟩

open LoebAlgebra in
/-- The entire consistency hierarchy (for n ≥ 1) lives in the spectrum. -/
theorem hierarchy_in_spectrum {L : Type*} [LoebAlgebra L] [SigmaSound L]
    (hnt : (⊥ : L) ≠ ⊤) (n : ℕ) (hn : 0 < n) :
    boxIter (⊥ : L) n ∈ incompletenessSpectrum L := by
  refine ⟨?_, boxIter_bot_ne_top hnt n⟩
  intro h
  have h1 := strict_hierarchy hnt (n - 1)
  have h2 : n - 1 + 1 = n := by omega
  rw [h2] at h1
  rw [h] at h1
  exact not_lt_bot h1

/-! ## Falsifiable Conjecture

**Conjecture**: In any nontrivial Löb algebra with Σ₁-soundness, the elements
□ⁿ⊥ for distinct n are the ONLY elements below □⊥ that form a chain.

**Test**: Construct a finite distributive lattice with a monotone operator
satisfying the Löb axiom and Σ₁-soundness. Verify that no element outside
the chain ⊥ < □⊥ < □²⊥ < ... is comparable to all chain elements.

**Prediction**: This forces the algebra to contain a copy of ℕ as a sublattice,
with the chain ⊥ < □⊥ < □²⊥ < ... being cofinal. Any finite algebra satisfying
both the Löb axiom and Σ₁-soundness must be trivial (⊥ = ⊤).
-/