import Mathlib

/-!
# Reversible ternary radius-one cellular automata: core framework

Alphabet `Fin 3`, local rules `g : Fin 3 → Fin 3 → Fin 3 → Fin 3` (a radius-one,
window-three rule) and the induced *global maps* on the finite cycle `ZMod n`:

`globalMap g s i = g (s (i-1)) (s i) (s (i+1))`.

A rule is **cycle-bijective** when its global map is bijective on *every* nonempty
finite cycle.  This file develops the general tools:

* `globalMap`, `CycleBijective`, `SingleCoordinatePerm`;
* `cycleBijective_of_decoder3` / `cycleBijective_of_decoder4R`: a *local decoder*
  (a local inverse rule, of window 3 resp. window 4) forces cycle-bijectivity on
  every cycle length simultaneously — this is the engine used everywhere else;
* closure properties: post-composition with a permutation of the alphabet, and
  spatial reflection, preserve cycle-bijectivity;
* `cycleBijective_of_singleCoordinatePerm`: the "trivial" rules
  `g = σ ∘ (one coordinate)` are cycle-bijective (the *easy* half of the
  classification claim under test);
* `diag_bijective_of_cycleBijective`: a first necessary condition.

The hard half of the classification claim (that these are the *only*
cycle-bijective rules) is **false**; see `Cryptography.TernaryReversible.Refutation`.
-/

namespace Cryptography
namespace TernaryReversible

/-- The ternary alphabet.  `ZMod 3` *is* `Fin 3` (definitionally, see `Alph_eq_Fin3`);
we use the `ZMod` presentation so that the field structure of `𝔽₃` is available. -/
abbrev Alph := ZMod 3

/-- The alphabet is literally `Fin 3`. -/
theorem Alph_eq_Fin3 : Alph = Fin 3 := rfl

/-- A radius-one local rule on the ternary alphabet: `g a b c` is the new value of a
cell whose left neighbour is `a`, whose own value is `b` and whose right neighbour
is `c`. -/
abbrev LocalRule := Alph → Alph → Alph → Alph

/-- Global map of a local rule on the cycle `ZMod n` (cyclic boundary conditions). -/
def globalMap (g : LocalRule) {n : ℕ} (s : ZMod n → Alph) : ZMod n → Alph :=
  fun i => g (s (i - 1)) (s i) (s (i + 1))

/-- A rule is *cycle-bijective* when its global map is bijective on every nonempty
finite cycle. -/
def CycleBijective (g : LocalRule) : Prop :=
  ∀ n : ℕ, 0 < n → Function.Bijective (globalMap (n := n) g)

/-- The rules the classification claim predicts: a single coordinate of the window,
post-composed with a permutation of the alphabet. -/
def SingleCoordinatePerm (g : LocalRule) : Prop :=
  ∃ σ : Equiv.Perm Alph,
    g = (fun a _ _ => σ a) ∨ g = (fun _ b _ => σ b) ∨ g = (fun _ _ c => σ c)

/-! ## Coordinate dependence -/

/-- `g` genuinely uses its left argument. -/
def DependsLeft (g : LocalRule) : Prop := ∃ a a' b c, g a b c ≠ g a' b c

/-- `g` genuinely uses its middle argument. -/
def DependsMiddle (g : LocalRule) : Prop := ∃ a b b' c, g a b c ≠ g a b' c

/-- `g` genuinely uses its right argument. -/
def DependsRight (g : LocalRule) : Prop := ∃ a b c c', g a b c ≠ g a b c'

instance : DecidablePred DependsLeft := fun g => by unfold DependsLeft; infer_instance

instance : DecidablePred DependsMiddle := fun g => by unfold DependsMiddle; infer_instance

instance : DecidablePred DependsRight := fun g => by unfold DependsRight; infer_instance

/-- A rule that genuinely depends on two of its three arguments cannot be a single
coordinate followed by a permutation. -/
theorem not_singleCoordinatePerm_of_twoDeps {g : LocalRule}
    (h : (DependsLeft g ∧ DependsMiddle g) ∨ (DependsLeft g ∧ DependsRight g) ∨
      (DependsMiddle g ∧ DependsRight g)) : ¬ SingleCoordinatePerm g := by
  rintro ⟨σ, rfl | rfl | rfl⟩
  · have hm : ¬ DependsMiddle (fun (a : Alph) (_ _ : Alph) => σ a) := by
      rintro ⟨a, b, b', c, hne⟩; exact hne rfl
    have hr : ¬ DependsRight (fun (a : Alph) (_ _ : Alph) => σ a) := by
      rintro ⟨a, b, c, c', hne⟩; exact hne rfl
    rcases h with ⟨_, h2⟩ | ⟨_, h2⟩ | ⟨h1, _⟩
    · exact hm h2
    · exact hr h2
    · exact hm h1
  · have hl : ¬ DependsLeft (fun (_ : Alph) (b : Alph) (_ : Alph) => σ b) := by
      rintro ⟨a, a', b, c, hne⟩; exact hne rfl
    have hr : ¬ DependsRight (fun (_ : Alph) (b : Alph) (_ : Alph) => σ b) := by
      rintro ⟨a, b, c, c', hne⟩; exact hne rfl
    rcases h with ⟨h1, _⟩ | ⟨h1, _⟩ | ⟨_, h2⟩
    · exact hl h1
    · exact hl h1
    · exact hr h2
  · have hl : ¬ DependsLeft (fun (_ _ : Alph) (c : Alph) => σ c) := by
      rintro ⟨a, a', b, c, hne⟩; exact hne rfl
    have hm : ¬ DependsMiddle (fun (_ _ : Alph) (c : Alph) => σ c) := by
      rintro ⟨a, b, b', c, hne⟩; exact hne rfl
    rcases h with ⟨h1, _⟩ | ⟨h1, _⟩ | ⟨h1, _⟩
    · exact hl h1
    · exact hl h1
    · exact hm h1

/-! ## Local decoders force bijectivity on all cycles -/

/-- The pointwise decoding identity on a cycle: a window-3 decoder `d` for `g`
reconstructs every cell of a configuration from three consecutive cells of its image,
for every cycle length. -/
theorem decoder3_apply {g d : LocalRule}
    (h : ∀ v w x y z, d (g v w x) (g w x y) (g x y z) = x) {n : ℕ} (u : ZMod n → Alph)
    (i : ZMod n) :
    d (globalMap g u (i - 1)) (globalMap g u i) (globalMap g u (i + 1)) = u i := by
  have e1 : globalMap g u (i - 1) = g (u (i - 1 - 1)) (u (i - 1)) (u i) := by
    simp [globalMap, sub_add_cancel]
  have e3 : globalMap g u (i + 1) = g (u i) (u (i + 1)) (u (i + 1 + 1)) := by
    simp [globalMap, add_sub_cancel_right]
  rw [e1, e3]
  exact h _ _ _ _ _

/-- **Window-3 decoder criterion.** If a local rule `d` reconstructs the middle cell
from three consecutive output cells, then `g` is bijective on every finite cycle.
Note the decoder identity is a statement about *words*, yet it yields bijectivity
for *all* cycle lengths at once, including lengths shorter than the window. -/
theorem cycleBijective_of_decoder3 (g d : LocalRule)
    (h : ∀ v w x y z, d (g v w x) (g w x y) (g x y z) = x) : CycleBijective g := by
  intro n hn
  haveI : NeZero n := ⟨hn.ne'⟩
  rw [← Finite.injective_iff_bijective]
  intro s t hst
  funext i
  rw [← decoder3_apply h s i, ← decoder3_apply h t i, hst]

/-- A rule that decodes *itself* induces an involution on every finite cycle. -/
theorem globalMap_involutive_of_selfDecoder {g : LocalRule}
    (h : ∀ v w x y z, g (g v w x) (g w x y) (g x y z) = x) {n : ℕ} (s : ZMod n → Alph) :
    globalMap g (globalMap g s) = s := by
  funext i
  exact decoder3_apply h s i

/-- **Window-4 (right-looking) decoder criterion.** If a rule `d` reconstructs the
leftmost cell of a window of six from the four outputs it determines, then `g` is
bijective on every finite cycle.  Such a decoder is an inverse cellular automaton
of neighbourhood `{1,2,3,4}`, i.e. of radius at least two. -/
theorem cycleBijective_of_decoder4R (g : LocalRule) (d : Alph → Alph → Alph → Alph → Alph)
    (h : ∀ x₀ x₁ x₂ x₃ x₄ x₅,
      d (g x₀ x₁ x₂) (g x₁ x₂ x₃) (g x₂ x₃ x₄) (g x₃ x₄ x₅) = x₀) :
    CycleBijective g := by
  intro n hn
  haveI : NeZero n := ⟨hn.ne'⟩
  rw [← Finite.injective_iff_bijective]
  intro s t hst
  funext i
  have key : ∀ u : ZMod n → Alph,
      d (globalMap g u (i + 1)) (globalMap g u (i + 2)) (globalMap g u (i + 3))
        (globalMap g u (i + 4)) = u i := by
    intro u
    have e : ∀ k : ZMod n,
        globalMap g u (k + 1) = g (u k) (u (k + 1)) (u (k + 2)) := by
      intro k
      have h1 : k + 1 - 1 = k := by ring
      have h2 : k + 1 + 1 = k + 2 := by ring
      simp only [globalMap, h1, h2]
    have e1 := e i
    have e2 : globalMap g u (i + 2) = g (u (i + 1)) (u (i + 2)) (u (i + 3)) := by
      have := e (i + 1)
      rw [show i + 1 + 1 = i + 2 by ring, show i + 1 + 2 = i + 3 by ring] at this
      exact this
    have e3 : globalMap g u (i + 3) = g (u (i + 2)) (u (i + 3)) (u (i + 4)) := by
      have := e (i + 2)
      rw [show i + 2 + 1 = i + 3 by ring, show i + 2 + 2 = i + 4 by ring] at this
      exact this
    have e4 : globalMap g u (i + 4) = g (u (i + 3)) (u (i + 4)) (u (i + 5)) := by
      have := e (i + 3)
      rw [show i + 3 + 1 = i + 4 by ring, show i + 3 + 2 = i + 5 by ring] at this
      exact this
    rw [e1, e2, e3, e4]
    exact h _ _ _ _ _ _
  rw [← key s, ← key t, hst]

/-! ## Closure properties -/

/-- Post-composing a cycle-bijective rule with a bijection of the alphabet keeps it
cycle-bijective. -/
theorem cycleBijective_comp {g : LocalRule} {f : Alph → Alph} (hf : Function.Bijective f)
    (hg : CycleBijective g) : CycleBijective (fun a b c => f (g a b c)) := by
  intro n hn
  have hcomp : globalMap (n := n) (fun a b c => f (g a b c))
      = (fun s => (fun i => f (s i))) ∘ globalMap (n := n) g := rfl
  rw [hcomp]
  refine Function.Bijective.comp ?_ (hg n hn)
  obtain ⟨hinj, hsurj⟩ := hf
  constructor
  · intro s t hst
    funext i
    exact hinj (congrFun hst i)
  · intro t
    choose finv hfinv using hsurj
    exact ⟨fun i => finv (t i), by funext i; simp [hfinv]⟩

/-- Cycle-bijectivity is invariant under relabelling the alphabet: it is a property of
the rule up to conjugation by a permutation. -/
theorem cycleBijective_conj {g : LocalRule} (σ : Equiv.Perm Alph) (hg : CycleBijective g) :
    CycleBijective (fun a b c => σ.symm (g (σ a) (σ b) (σ c))) := by
  intro n hn
  haveI : NeZero n := ⟨hn.ne'⟩
  have hconj : globalMap (n := n) (fun a b c => σ.symm (g (σ a) (σ b) (σ c)))
      = (fun (u : ZMod n → Alph) (i : ZMod n) => σ.symm (u i)) ∘ globalMap (n := n) g ∘
        (fun (u : ZMod n → Alph) (i : ZMod n) => σ (u i)) := rfl
  rw [hconj]
  have hpost : Function.Bijective (fun (u : ZMod n → Alph) (i : ZMod n) => σ.symm (u i)) :=
    ⟨fun u v huv => funext fun i => σ.symm.injective (congrFun huv i),
      fun v => ⟨fun i => σ (v i), by funext i; simp⟩⟩
  have hpre : Function.Bijective (fun (u : ZMod n → Alph) (i : ZMod n) => σ (u i)) :=
    ⟨fun u v huv => funext fun i => σ.injective (congrFun huv i),
      fun v => ⟨fun i => σ.symm (v i), by funext i; simp⟩⟩
  exact hpost.comp ((hg n hn).comp hpre)

/-- Reflecting a rule in space (`a b c ↦ g c b a`) preserves cycle-bijectivity:
the global maps are conjugate by the index reflection `i ↦ -i`. -/
theorem cycleBijective_reflect {g : LocalRule} (hg : CycleBijective g) :
    CycleBijective (fun a b c => g c b a) := by
  intro n hn
  haveI : NeZero n := ⟨hn.ne'⟩
  have hRR : ∀ s : ZMod n → Alph, (fun i : ZMod n => (fun j : ZMod n => s (-j)) (-i)) = s := by
    intro s; funext i; simp
  have hRbij : Function.Bijective (fun (s : ZMod n → Alph) (i : ZMod n) => s (-i)) := by
    constructor
    · intro s t hst
      funext i
      have := congrFun hst (-i)
      simpa using this
    · intro t
      exact ⟨fun i => t (-i), by funext i; simp⟩
  have hconj : globalMap (n := n) (fun a b c => g c b a)
      = (fun (u : ZMod n → Alph) (i : ZMod n) => u (-i)) ∘ globalMap (n := n) g ∘
        (fun (u : ZMod n → Alph) (i : ZMod n) => u (-i)) := by
    funext s i
    show g (s (i + 1)) (s i) (s (i - 1)) = g (s (-(-i - 1))) (s (-(-i))) (s (-(-i + 1)))
    rw [show -(-i - 1) = i + 1 by ring, show -(-i) = i by ring, show -(-i + 1) = i - 1 by ring]
  rw [hconj]
  exact hRbij.comp ((hg n hn).comp hRbij)

/-! ## The easy half of the classification claim -/

/-- A single coordinate followed by a permutation is cycle-bijective. -/
theorem cycleBijective_of_singleCoordinatePerm {g : LocalRule}
    (hg : SingleCoordinatePerm g) : CycleBijective g := by
  obtain ⟨σ, h | h | h⟩ := hg <;> subst h
  · -- `g a b c = σ a`: decode from the right output
    refine cycleBijective_of_decoder3 _ (fun _ _ z => σ.symm z) ?_
    intro v w x y z; simp
  · -- `g a b c = σ b`: decode from the middle output
    refine cycleBijective_of_decoder3 _ (fun _ y _ => σ.symm y) ?_
    intro v w x y z; simp
  · -- `g a b c = σ c`: decode from the left output
    refine cycleBijective_of_decoder3 _ (fun x _ _ => σ.symm x) ?_
    intro v w x y z; simp

/-! ## A necessary condition -/

/-- On the one-cell cycle the global map is `a ↦ g a a a`, so this "diagonal" map of a
cycle-bijective rule must be a permutation of the alphabet. -/
theorem diag_bijective_of_cycleBijective {g : LocalRule} (hg : CycleBijective g) :
    Function.Bijective (fun a : Alph => g a a a) := by
  have h1 := hg 1 one_pos
  have e : (fun a : Alph => g a a a)
      = (fun s : ZMod 1 → Alph => s 0) ∘ globalMap (n := 1) g ∘ (fun a _ => a) := by
    funext a
    rfl
  rw [e]
  have hfst : Function.Bijective (fun s : ZMod 1 → Alph => s 0) := by
    constructor
    · intro s t hst
      funext i
      rw [Subsingleton.elim i 0]
      exact hst
    · intro a; exact ⟨fun _ => a, rfl⟩
  have hconst : Function.Bijective (fun (a : Alph) (_ : ZMod 1) => a) := by
    constructor
    · intro a b hab; exact congrFun hab 0
    · intro s; exact ⟨s 0, by funext i; rw [Subsingleton.elim i 0]⟩
  exact hfst.comp (h1.comp hconst)

end TernaryReversible
end Cryptography