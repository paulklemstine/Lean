import Mathlib

/-!
# The Fundamental Theorem of Identity Types

This file develops the core of Homotopy Type Theory (HoTT) inside Lean 4, using Lean's
built-in identity type `Eq` as the identity type of the theory and `PSigma` for dependent
pair (total) types.  We work with the HoTT notions of *contractibility* and *equivalence
(in the sense of contractible fibers)* and prove the **fundamental theorem of identity
types**: for a pointed type family `B` over `(A, a)` with `b : B a`, the canonical transport
map `encode x : (a = x) → B x` is a fiberwise equivalence **iff** the total space `Σ' x, B x`
is contractible.

Because Lean's `Eq` lives in `Prop`, all definitions are stated for `Sort` (so identity-type
domains are allowed) and use `PSigma`.

## Main results

* `HoTT.singleton_isContr`              — based path spaces `Σ' y, a = y` are contractible.
* `HoTT.fundamental_identity_forward`   — fiberwise equivalence ⇒ contractible total space.
* `HoTT.fundamental_identity_backward`  — contractible total space ⇒ fiberwise equivalence.
* `HoTT.isEquiv_encode_of_isContr`      — corollary for the lifted identity family.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The fundamental theorem of identity types — usually proved with
heavy equivalence calculus (total spaces of fibrations, 3-for-2, etc.) — should collapse to a
short argument inside Lean because `Eq` is proof-irrelevant (`Subsingleton (a = x)`).  We
conjecture each direction reduces to *inhabitedness* of fibers plus subsingleton-ness.

EXPERIMENT (Experimenter): Forward direction uses only that fibers of an equivalence are
inhabited (surjectivity). Backward direction uses that the contractible total space is a
subsingleton, so the needed fiber is inhabited; contractibility of the fiber is then free
because it is a `PSigma` of two propositions (`a = x` and an `Eq` in `B x`).

ANALYSIS (Analyst): The collapse is real: the "set-level shadow" of HoTT validates the
fundamental theorem with no transport-coherence bookkeeping. The first attempt failed because
`Eq` is `Prop = Sort 0`, not a `Type u`; the fix is to make `IsContr`/`Fiber`/`IsEquiv`
`Sort`-polymorphic and use `PSigma`.

CRITIQUE (Critic): Is the statement vacuous? No: `singleton_isContr` is a genuine
construction, and both directions have nontrivial content (explicit center `⟨a, b⟩` and the
explicit decoding path). The corollary is not definitional.

SYNTHESIS (PI): The theorem assembles from `singleton_isContr` plus the subsingleton
structure of identity-type fibers.
-- !-- Lab Notes -- !--
-/

universe u v

namespace HoTT

/-- A type is **contractible** if it has a center of contraction to which every element is
equal. This is the HoTT notion of a `(-2)`-truncated type. -/
structure IsContr (A : Sort u) : Sort (max 1 u) where
  /-- The center of contraction. -/
  center : A
  /-- Every element is equal to the center. -/
  contraction : ∀ x, center = x

/-- The (homotopy) **fiber** of a map `f` over a point `y`. -/
def Fiber {A : Sort u} {B : Sort v} (f : A → B) (y : B) : Sort (max 1 u) :=
  Σ' x : A, f x = y

/-- A map is an **equivalence** (in the HoTT sense) iff all of its fibers are contractible. -/
def IsEquiv {A : Sort u} {B : Sort v} (f : A → B) : Sort (max 1 v u) :=
  ∀ y : B, IsContr (Fiber f y)

/-- A contractible type is a subsingleton: any two elements are equal. -/
theorem IsContr.subsingleton {A : Sort u} (h : IsContr A) (x y : A) : x = y := by
  rw [← h.contraction x, ← h.contraction y]

/-- **Based path spaces are contractible.** The total space of the identity family at `a`,
namely `Σ' y, a = y`, is contractible with center `⟨a, rfl⟩`. -/
def singleton_isContr {A : Sort u} (a : A) : IsContr (Σ' y : A, a = y) where
  center := ⟨a, rfl⟩
  contraction := by
    rintro ⟨y, p⟩
    cases p
    rfl

section Family

variable {A : Sort u} (a : A) (B : A → Sort v) (b : B a)

/-- The canonical **transport (encoding) map** of a pointed family: send a path `p : a = x`
to `p ▸ b : B x`. -/
def encode : ∀ x : A, a = x → B x := fun _ p => p ▸ b

/-- **Fundamental Theorem of Identity Types (forward direction).** If the transport map
`encode x` is a fiberwise equivalence, then the total space `Σ' x, B x` is contractible. -/
def fundamental_identity_forward
    (h : ∀ x : A, IsEquiv (encode a B b x)) : IsContr (Σ' x : A, B x) where
  center := ⟨a, b⟩
  contraction := by
    rintro ⟨x, u⟩
    obtain ⟨p, hp⟩ := (h x u).center
    cases p
    cases hp
    rfl

/-- **Fundamental Theorem of Identity Types (backward direction).** If the total space
`Σ' x, B x` is contractible, then the transport map `encode x` is a fiberwise equivalence. -/
def fundamental_identity_backward
    (h : IsContr (Σ' x : A, B x)) : ∀ x : A, IsEquiv (encode a B b x) := by
  intro x u
  have e : (⟨a, b⟩ : Σ' x : A, B x) = ⟨x, u⟩ := h.subsingleton _ _
  injection e with e1 e2
  subst e1
  exact ⟨⟨rfl, eq_of_heq e2⟩, fun _ => rfl⟩

end Family

/-- Corollary: for the lifted identity family `fun x => PLift (a = x)`, the transport map is a
fiberwise equivalence. This follows from the backward direction together with contractibility
of the based path space. -/
def isEquiv_encode_of_isContr {A : Sort u} (a : A) :
    ∀ x : A, IsEquiv (encode a (fun x => PLift (a = x)) ⟨rfl⟩ x) := by
  refine fundamental_identity_backward a (fun x => PLift (a = x)) ⟨rfl⟩ ?_
  refine ⟨⟨a, ⟨rfl⟩⟩, ?_⟩
  rintro ⟨x, ⟨p⟩⟩
  cases p
  rfl

end HoTT