import Mathlib

/-!
# Translation stabilizers of finite torus drum patterns

This file develops a small, self-contained theory of *translation stabilizers*.

Given a function `f : G → α` on an additive group `G`, its translation stabilizer
`transStab f` is the additive subgroup of all `g : G` such that translating the
argument by `g` leaves `f` unchanged: `∀ x, f (x + g) = f x`.

We then specialize to *drum patterns* on a finite discrete torus
`ZMod m × ZMod n`, modelled as boolean functions `Pattern m n`, and study their
translation stabilizers.

## Main results

* `transStab` : the translation-stabilizer subgroup, with its basic API
  (`zero_mem_transStab`, `add_mem_transStab`, `neg_mem_transStab`,
  `mem_transStab_iff`).
* `invariantUnder_iff_sameOrbit` : a function is invariant under a fixed subgroup
  `H` iff it is constant on `H`-orbits.
* `transStab_eq_top_iff` : the stabilizer is everything iff `f` is globally constant.
* `transStab_eq_bot_iff` : the stabilizer is trivial iff every nonzero translation
  changes `f` somewhere.
* `constPattern_translationStabilizer_eq_top` : a constant drum pattern has full
  stabilizer.
* `singleOnset_translationStabilizer_eq_bot` : a single-onset drum pattern has
  trivial stabilizer.
-/

namespace DrumPatternTranslationSymmetry

variable {G : Type*} {α : Type*}

/-! ## The generic translation stabilizer -/

/-- The translation stabilizer of `f : G → α`: the additive subgroup of elements
`g : G` whose translation action fixes `f`, i.e. `∀ x, f (x + g) = f x`. -/
def transStab [AddGroup G] (f : G → α) : AddSubgroup G where
  carrier := {g | ∀ x, f (x + g) = f x}
  zero_mem' := by intro x; simp
  add_mem' := by
    intro a b ha hb x
    have hx : x + (a + b) = (x + a) + b := by rw [add_assoc]
    rw [hx, hb, ha]
  neg_mem' := by
    intro a ha x
    have h := ha (x + -a)
    rw [neg_add_cancel_right] at h
    exact h.symm

@[simp] lemma mem_transStab_iff [AddGroup G] {f : G → α} {g : G} :
    g ∈ transStab f ↔ ∀ x, f (x + g) = f x := Iff.rfl

lemma zero_mem_transStab [AddGroup G] (f : G → α) : (0 : G) ∈ transStab f :=
  (transStab f).zero_mem

lemma add_mem_transStab [AddGroup G] {f : G → α} {a b : G}
    (ha : a ∈ transStab f) (hb : b ∈ transStab f) : a + b ∈ transStab f :=
  (transStab f).add_mem ha hb

lemma neg_mem_transStab [AddGroup G] {f : G → α} {a : G}
    (ha : a ∈ transStab f) : -a ∈ transStab f :=
  (transStab f).neg_mem ha

/-! ## Orbit / invariance package for a fixed subgroup -/

/-- `x` and `y` lie in the same `H`-orbit when `y = x + h` for some `h ∈ H`. -/
def sameOrbitH [AddGroup G] (H : AddSubgroup G) (x y : G) : Prop :=
  ∃ h : H, y = x + h.1

/-- `f` is invariant under the subgroup `H` when translating by any `h ∈ H`
fixes `f`. -/
def InvariantUnder [AddGroup G] (H : AddSubgroup G) (f : G → α) : Prop :=
  ∀ h ∈ H, ∀ x, f (x + h) = f x

/-- A function is invariant under `H` iff it is constant on `H`-orbits. -/
theorem invariantUnder_iff_sameOrbit [AddGroup G] (H : AddSubgroup G) (f : G → α) :
    InvariantUnder H f ↔ ∀ x y, sameOrbitH H x y → f x = f y := by
  constructor
  · rintro hinv x y ⟨h, rfl⟩
    exact (hinv h.1 h.2 x).symm
  · intro h g hg x
    exact (h x (x + g) ⟨⟨g, hg⟩, rfl⟩).symm

/-! ## Extremal stabilizers -/

/-- The stabilizer is the whole group iff `f` is globally constant. -/
theorem transStab_eq_top_iff [AddGroup G] (f : G → α) :
    transStab f = ⊤ ↔ ∀ x y : G, f x = f y := by
  rw [AddSubgroup.eq_top_iff']
  constructor
  · intro h x y
    have := h (-x + y) x
    rw [add_neg_cancel_left] at this
    exact this.symm
  · intro h g x
    exact h _ _

/-- The stabilizer is trivial iff every nonzero translation changes `f`
somewhere. -/
theorem transStab_eq_bot_iff [AddGroup G] (f : G → α) :
    transStab f = ⊥ ↔ ∀ g : G, g ≠ 0 → ∃ x, f (x + g) ≠ f x := by
  rw [AddSubgroup.eq_bot_iff_forall]
  constructor
  · intro h g hg
    by_contra hcon
    push_neg at hcon
    exact hg (h g hcon)
  · intro h g hg
    by_contra hne
    obtain ⟨x, hx⟩ := h g hne
    exact hx (hg x)

/-! ## Concrete drum patterns -/

/-- A drum pattern on the discrete torus `ZMod m × ZMod n` is a boolean function:
`true` marks an onset. -/
def Pattern (m n : ℕ) := (ZMod m × ZMod n) → Bool

/-- The translation stabilizer of a drum pattern. -/
def translationStabilizer {m n : ℕ} (f : Pattern m n) :
    AddSubgroup (ZMod m × ZMod n) :=
  transStab f

/-- The constant drum pattern with value `b`. -/
def constPattern (m n : ℕ) (b : Bool) : Pattern m n := fun _ => b

/-- A constant drum pattern is fixed by every translation. -/
theorem constPattern_translationStabilizer_eq_top (m n : ℕ) (b : Bool) :
    translationStabilizer (constPattern m n b) = ⊤ := by
  rw [translationStabilizer, transStab_eq_top_iff]
  intro x y; rfl

/-- The single-onset drum pattern with its unique onset at `a`. -/
def singleOnset {m n : ℕ} (a : ZMod m × ZMod n) : Pattern m n :=
  fun x => decide (x = a)

/-- A single-onset drum pattern has trivial translation stabilizer: no nonzero
translation can fix a pattern with a unique onset.

The hypotheses `1 < m` and `1 < n` are requested in the problem statement; the
proof works by additive cancellation and does not in fact need them. -/
theorem singleOnset_translationStabilizer_eq_bot {m n : ℕ}
    (hm : 1 < m) (hn : 1 < n) (a : ZMod m × ZMod n) :
    translationStabilizer (singleOnset a) = ⊥ := by
  rw [translationStabilizer, transStab_eq_bot_iff]
  intro g hg
  refine ⟨a + -g, ?_⟩
  simp only [singleOnset]
  rw [show a + -g + g = a from by abel]
  intro hcon
  -- `decide (a = a) = decide (a + -g = a)`, so the onset is fixed: `a + -g = a`.
  have heq : a + -g = a := by
    have : decide (a + -g = a) = true := by
      rw [← hcon]; simp
    simpa using this
  have : -g = 0 := by
    have := add_eq_left.mp heq
    exact this
  exact hg (by simpa using neg_eq_zero.mp this)

end DrumPatternTranslationSymmetry