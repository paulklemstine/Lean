/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Dirichlet L-functions: the degree-one stratum of the census

The simplest infinite family of L-functions beyond the Riemann zeta function is
the family of **Dirichlet L-functions** `L(s, χ) = ∑ₙ χ(n) n⁻ˢ`, one for each
Dirichlet character `χ` modulo `n`.  In Lean/Mathlib a Dirichlet character mod
`n` valued in `ℂ` is `DirichletCharacter ℂ n = MulChar (ZMod n) ℂ`.

This file quantifies "how many Dirichlet L-functions there are":

* `dirichlet_finite_mod` — for each modulus `n ≥ 1` there are only **finitely
  many** Dirichlet characters;
* `dirichlet_family_countable` — the family of **all** Dirichlet characters, over
  all moduli, is **countable**;
* `dirichlet_family_infinite` — it is nevertheless **infinite** (an explicit
  injection via principal characters of growing modulus);
* `dirichlet_family_countably_infinite` — packaging the two: the Dirichlet
  L-functions are exactly as numerous as `ℕ`.

This is the concrete, fully verified confirmation of point (2) of the census:
*Dirichlet L-functions are countable.*

The file is self-contained and imports only Mathlib.
-/
import Mathlib

namespace SelbergCensus

open scoped Classical

/-- **Finitely many characters per modulus.**  For a nonzero modulus `n`, the
Dirichlet characters mod `n` form a finite set — a finite abelian group of order
`φ(n)`.  (For `n = 0` the domain `ZMod 0 = ℤ` is infinite and this fails, which
is why `NeZero n` is required.) -/
theorem dirichlet_finite_mod (n : ℕ) [NeZero n] : Finite (DirichletCharacter ℂ n) :=
  inferInstance

/-- **The universe of Dirichlet L-functions is countable.**  Bundling a
character together with its modulus, `Σ n, DirichletCharacter ℂ n` is countable:
a countable union (over the modulus `n`) of finite sets. -/
theorem dirichlet_family_countable : Countable (Σ n : ℕ, DirichletCharacter ℂ n) :=
  inferInstance

/-- The principal (trivial) Dirichlet character of modulus `n + 1`, bundled with
its modulus.  As `n` varies this produces infinitely many *distinct* Dirichlet
characters, because the modulus `n + 1` is strictly increasing. -/
noncomputable def principalFamily (n : ℕ) : Σ m : ℕ, DirichletCharacter ℂ m :=
  ⟨n + 1, (1 : DirichletCharacter ℂ (n + 1))⟩

theorem principalFamily_injective : Function.Injective principalFamily := by
  intro a b h
  simp only [principalFamily, Sigma.mk.injEq] at h
  omega

/-- **The universe of Dirichlet L-functions is infinite.**  Principal characters
of distinct moduli give an injection `ℕ ↪ Σ n, DirichletCharacter ℂ n`. -/
theorem dirichlet_family_infinite : Infinite (Σ n : ℕ, DirichletCharacter ℂ n) :=
  Infinite.of_injective principalFamily principalFamily_injective

/-- **Dirichlet L-functions are countably infinite.**  Combining countability and
infinitude: the collection of all Dirichlet L-functions has exactly the
cardinality of `ℕ` (equivalently of `ℤ`) — the census claim for the degree-one
stratum. -/
theorem dirichlet_family_countably_infinite :
    Countable (Σ n : ℕ, DirichletCharacter ℂ n) ∧
      Infinite (Σ n : ℕ, DirichletCharacter ℂ n) :=
  ⟨dirichlet_family_countable, dirichlet_family_infinite⟩

end SelbergCensus