import Mathlib

/-!
# Core definitions for the Learning-With-Errors problem

This file sets up the generic, ring-agnostic scaffolding for the Learning With
Errors (LWE) problem in its **search** and **decision** flavours.  Concrete
instantiations (such as the ring-LWE problem over `ℤ[i]` developed in
`FINAL.Cryptography.LWE.GaussianBridge`) are obtained by choosing the coefficient
ring `R`.

An LWE sample with secret `s` is a pair `(a, b)` where `a` is public/uniform and
`b = a · s + e` for a small error `e`.  The *search* problem asks to recover `s`
from many samples; the *decision* problem asks to distinguish honest samples from
uniformly random pairs.
-/

namespace FINAL.Cryptography.LWE

/-- A single LWE sample over a coefficient ring `R`: a public element `a`
together with the (noisy) inner product `b`. -/
structure LWESample (R : Type*) where
  /-- The public (uniform) coordinate. -/
  a : R
  /-- The noisy observation `b = a · s + e`. -/
  b : R

/-- The honest LWE sample produced from a secret `s`, an error `e`, and a public
coordinate `a`: it sets `b = a · s + e`. -/
def lweSample {R : Type*} [Mul R] [Add R] (s e a : R) : LWESample R :=
  ⟨a, a * s + e⟩

@[simp]
theorem lweSample_a {R : Type*} [Mul R] [Add R] (s e a : R) :
    (lweSample s e a).a = a := rfl

@[simp]
theorem lweSample_b {R : Type*} [Mul R] [Add R] (s e a : R) :
    (lweSample s e a).b = a * s + e := rfl

/-- The error of a sample relative to a candidate secret `s`: `b - a · s`.
For the honest secret this returns exactly the noise `e`. -/
def residual {R : Type*} [Mul R] [Sub R] (c : LWESample R) (s : R) : R :=
  c.b - c.a * s

@[simp]
theorem residual_lweSample {R : Type*} [CommRing R] (s e a : R) :
    residual (lweSample s e a) s = e := by
  simp [residual, lweSample]

/-- A candidate secret `s` is **consistent** with a list of samples up to an error
predicate `small` if every residual `b - a · s` is small. -/
def IsConsistentSecret {R : Type*} [Mul R] [Sub R]
    (small : R → Prop) (samples : List (LWESample R)) (s : R) : Prop :=
  ∀ c ∈ samples, small (residual c s)

/-- The **search-LWE** statement (existence form): there is a secret consistent
with the observed samples. -/
def SearchLWE {R : Type*} [Mul R] [Sub R]
    (small : R → Prop) (samples : List (LWESample R)) : Prop :=
  ∃ s : R, IsConsistentSecret small samples s

/-- The honest secret is always a consistent solution to its own samples, as long
as all the injected errors are small. -/
theorem searchLWE_of_honest {R : Type*} [CommRing R]
    (small : R → Prop) (s : R) (samples : List (LWESample R))
    (hgen : ∀ c ∈ samples, ∃ e a, c = lweSample s e a ∧ small e) :
    SearchLWE small samples := by
  refine ⟨s, ?_⟩
  intro c hc
  obtain ⟨e, a, rfl, he⟩ := hgen c hc
  simpa using he

end FINAL.Cryptography.LWE