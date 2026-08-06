import Mathlib
import Catalog.Novelty.MindToolsBoundedApprehension

/-!
# A coded calculus with derivation trees: unconditional mind tools, concretely

`Catalog/Logic/MindTools.lean` models a formal system *extensionally*, by its set
of provable sentences, and `Catalog/Novelty/MindToolsBoundedApprehension.lean`
adds an abstract `ProofSystem` (proofs with conclusions and sizes).  Extension 1
of the programme asks for the missing intensional layer: coded syntax,
derivation trees, and soundness.

This file supplies it for a concrete Hilbert-style implicational calculus.

* `Form` is a coded syntax (atoms indexed by `ℕ`, implication).
* `Deriv` is an inductive family of *derivation trees* over the axiom schemes
  `K` and `S` with modus ponens.
* `Form.eval` is a two-valued semantics and `Deriv.sound` the soundness theorem,
  proved by induction over derivations.
* `hilbert : ProofSystem Form` packages derivations as a proof system whose size
  is the coded size of the derivation tree.

The payoff is an **unconditional mind tool for a genuine deductive calculus**:
`hilbert_isMindTool` shows that for every resource bound `b` the calculus proves
a theorem — explicitly, `atom (b+1) → atom (b+1)` — which has no derivation of
size `≤ b`, because `Form.size_le_derivSize` bounds the syntactic size of a
conclusion by the size of any derivation of it.  Soundness simultaneously gives
consistency (`atom_not_provable`), so the theory is a proper, sound, infinite
extension of every bounded profile.
-/

namespace MindTools
namespace Bounded

/-! ## Coded syntax -/

/-- Coded syntax of the implicational fragment: atoms indexed by `ℕ`. -/
inductive Form : Type
  | atom : ℕ → Form
  | imp : Form → Form → Form
  deriving DecidableEq

namespace Form

/-- The coded size of a formula.  The atom `atom n` has size `n + 1`, so that
formulas mentioning large atoms are syntactically large. -/
def size : Form → ℕ
  | atom n => n + 1
  | imp a b => a.size + b.size + 1

@[simp] theorem size_atom (n : ℕ) : (atom n).size = n + 1 := rfl

@[simp] theorem size_imp (a b : Form) : (imp a b).size = a.size + b.size + 1 := rfl

/-- Two-valued semantics for the implicational fragment. -/
def eval (v : ℕ → Bool) : Form → Bool
  | atom n => v n
  | imp a b => !(eval v a) || eval v b

@[simp] theorem eval_atom (v : ℕ → Bool) (n : ℕ) : eval v (atom n) = v n := rfl

@[simp] theorem eval_imp (v : ℕ → Bool) (a b : Form) :
    eval v (imp a b) = (!(eval v a) || eval v b) := rfl

end Form

/-! ## Derivation trees -/

/-- Derivation trees of a Hilbert-style calculus with the axiom schemes `K` and
`S` and the rule of modus ponens.  This is the intensional datum — a proof is a
tree, not merely the assertion that its conclusion is a theorem. -/
inductive Deriv : Form → Type
  | ax_k (a b : Form) : Deriv (Form.imp a (Form.imp b a))
  | ax_s (a b c : Form) :
      Deriv (Form.imp (Form.imp a (Form.imp b c))
        (Form.imp (Form.imp a b) (Form.imp a c)))
  | mp {a b : Form} : Deriv (Form.imp a b) → Deriv a → Deriv b

namespace Deriv

/-- The coded size of a derivation tree: axioms cost the size of the formula
they assert, modus ponens costs the sizes of its premises plus one. -/
def size : {f : Form} → Deriv f → ℕ
  | _, ax_k a b => (Form.imp a (Form.imp b a)).size
  | _, ax_s a b c =>
      (Form.imp (Form.imp a (Form.imp b c))
        (Form.imp (Form.imp a b) (Form.imp a c))).size
  | _, mp d e => d.size + e.size + 1

/-- **Soundness.**  Every derivable formula is true under every valuation. -/
theorem sound : ∀ {f : Form}, Deriv f → ∀ v : ℕ → Bool, Form.eval v f = true := by
  intro f d
  induction d with
  | ax_k a b => intro v; cases h : Form.eval v a <;> simp [h]
  | ax_s a b c =>
      intro v
      cases ha : Form.eval v a <;> cases hb : Form.eval v b <;>
        cases hc : Form.eval v c <;> simp [ha, hb, hc]
  | mp d e ihd ihe =>
      intro v
      have h1 := ihd v
      have h2 := ihe v
      simp only [Form.eval_imp, h2, Bool.not_true, Bool.false_or] at h1
      exact h1

/-- The syntactic size of a conclusion never exceeds the size of a derivation of
it: large statements need large proofs. -/
theorem size_conclusion_le : ∀ {f : Form} (d : Deriv f), f.size ≤ d.size := by
  intro f d
  induction d with
  | ax_k a b => exact le_rfl
  | ax_s a b c => exact le_rfl
  | mp d e ihd ihe =>
      simp only [Form.size_imp] at ihd
      simp only [size]
      omega

/-- Derivability of `a → a`, the standard `S`–`K` combination. -/
def identity (a : Form) : Deriv (Form.imp a a) :=
  .mp (.mp (.ax_s a (Form.imp a a) a) (.ax_k a (Form.imp a a))) (.ax_k a a)

/-- The size of the standard `S`–`K`–`K` derivation of `a → a` is an explicit
affine function of the size of `a`. -/
theorem identity_size (a : Form) : (identity a).size = 16 * a.size + 15 := by
  simp only [identity, size, Form.size_imp]
  ring

end Deriv

/-! ## The calculus as a proof system -/

/-- The Hilbert calculus packaged as a `ProofSystem`: proofs are derivation
trees, the conclusion map forgets the tree, the size is the coded tree size. -/
def hilbert : ProofSystem Form where
  Proof := Σ f : Form, Deriv f
  conclusion p := p.1
  size p := p.2.size

@[simp] theorem hilbert_mem_theory {f : Form} :
    f ∈ (theory hilbert).provable ↔ Nonempty (Deriv f) := by
  constructor
  · rintro ⟨⟨g, d⟩, rfl⟩
    exact ⟨d⟩
  · rintro ⟨d⟩
    exact ⟨⟨f, d⟩, rfl⟩

/-- Soundness yields consistency: no atom is derivable, so the theory is a
proper subset of all formulas. -/
theorem atom_not_provable (n : ℕ) : Form.atom n ∉ (theory hilbert).provable := by
  intro h
  obtain ⟨d⟩ := hilbert_mem_theory.1 h
  have := Deriv.sound d (fun _ => false)
  simp at this

/-- The theory of the calculus is consistent in the extensional sense: it is not
everything. -/
theorem hilbert_theory_ne_univ : (theory hilbert).provable ≠ Set.univ := by
  intro h
  exact atom_not_provable 0 (h ▸ Set.mem_univ _)

/-- A formula whose derivations must all be large: no derivation of a formula of
size `> b` fits in budget `b`. -/
theorem not_apprehends_of_size_lt {f : Form} {b : ℕ} (h : b < f.size) :
    f ∉ (apprehends hilbert b).direct := by
  rintro ⟨⟨g, d⟩, hsize, rfl⟩
  exact absurd ((Deriv.size_conclusion_le d).trans hsize) (not_le.2 h)

/-- **Unconditional mind tool for a real deductive calculus.**  For every
resource bound `b`, the Hilbert calculus proves a theorem with no derivation of
size at most `b`; the explicit witness is `atom (b+1) → atom (b+1)`.  Unlike the
conditional certificates of `Catalog/Logic/MindTools.lean`, no premise about
human cognition is assumed: both premises are discharged, the containment by
`apprehends_subset_theory` and the inaccessible witness by the size bound. -/
theorem hilbert_isMindTool (b : ℕ) :
    IsMindTool (theory hilbert) (apprehends hilbert b) := by
  set f : Form := Form.imp (Form.atom (b + 1)) (Form.atom (b + 1)) with hf
  have hsize : b < f.size := by simp [hf]; omega
  refine isMindTool_of_witness _ _ (apprehends_subset_theory _ b)
    (sentence := f) ?_ (not_apprehends_of_size_lt hsize)
  exact hilbert_mem_theory.2 ⟨Deriv.identity _⟩

/-- The theory of the calculus is infinite: it contains `a → a` for every atom
`a`, and these are pairwise distinct. -/
theorem hilbert_theory_infinite : (theory hilbert).provable.Infinite := by
  have hinj : Function.Injective
      (fun n : ℕ => Form.imp (Form.atom n) (Form.atom n)) := by
    intro m n h
    simpa using h
  refine Set.infinite_of_injective_forall_mem (f := fun n : ℕ =>
    Form.imp (Form.atom n) (Form.atom n)) hinj (fun n => ?_)
  exact hilbert_mem_theory.2 ⟨Deriv.identity _⟩

/-- Every budget is strictly improved by a larger one for the Hilbert calculus:
the bounded profiles form an infinite strictly ascending chain inside a sound,
consistent theory. -/
theorem hilbert_exists_strictly_larger_bound (b : ℕ) :
    ∃ b', b ≤ b' ∧ (apprehends hilbert b).direct ⊂ (apprehends hilbert b').direct := by
  set f : Form := Form.imp (Form.atom (b + 1)) (Form.atom (b + 1)) with hf
  have hsize : b < f.size := by simp [hf]; omega
  refine ⟨max b (Deriv.identity (Form.atom (b + 1))).size, le_max_left _ _, ?_⟩
  refine ⟨apprehends_mono hilbert (le_max_left _ _), fun hsub => ?_⟩
  refine not_apprehends_of_size_lt hsize (hsub ?_)
  exact ⟨⟨f, Deriv.identity _⟩, le_max_right _ _, rfl⟩

end Bounded
end MindTools