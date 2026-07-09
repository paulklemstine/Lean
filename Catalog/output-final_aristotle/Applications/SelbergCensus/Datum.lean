/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The L-Function Universe — A Cosmic Census

L-functions (the Riemann zeta function, Dirichlet L-functions, L-functions of
modular forms, elliptic curves, and Galois representations) form a vast
menagerie.  A recurring philosophical claim is that the collection of
*well-behaved* L-functions — those satisfying the Selberg class axioms — is only
**countable**: no bigger than the integers, even though each individual
L-function encodes infinitely much arithmetic information.

The structural reason is that a Selberg-class L-function is pinned down by a
*finite packet of data*:

  * its **degree** `d ∈ ℕ`,
  * its **conductor** `N ∈ ℕ`,
  * its **root number** (a point of the unit circle, here recorded by a pair of
    rationals), and
  * a finite list of **Euler factors**, one polynomial (with integer
    coefficients) per ramified/recorded prime.

This file makes that census precise and *proves the countability rigorously*:

  * `SelbergDatum` is the type of such finite data packets.
  * `SelbergDatum.instCountable` : the whole census is **countable**.
  * `SelbergDatum.instInfinite`  : it is nevertheless **infinite** — hence
    countably infinite, exactly the size of `ℕ`.
  * `census_countable` / `census_set_countable` : the **census principle** — any
    family of objects that is classified injectively by such data is countable.
  * `BoundedDatum` / `shellFinite` : the census is stratified into **finite
    shells** of bounded complexity, which can be enumerated (`Fintype.card`).

Nothing here is postulated: `SelbergDatum` is an honest data type and every
countability/finiteness statement is derived from first principles.
-/
import Mathlib

namespace SelbergCensus

/-- A finite data packet describing (the arithmetic fingerprint of) an
L-function in the style of the Selberg class:

* `degree`     — the degree of the functional equation;
* `conductor`  — the conductor / level;
* `rootNumber` — the sign of the functional equation, recorded as a pair of
  rationals (real and imaginary part of an approximation to a point of the unit
  circle);
* `eulerFactors` — a finite list of local Euler factors, each stored as a prime
  `p` together with the integer coefficient list of the local polynomial. -/
structure SelbergDatum where
  /-- Degree of the functional equation. -/
  degree : ℕ
  /-- Conductor / level. -/
  conductor : ℕ
  /-- Root number, recorded as a pair of rationals. -/
  rootNumber : ℚ × ℚ
  /-- Finite list of Euler factors: prime together with polynomial coefficients. -/
  eulerFactors : List (ℕ × List ℤ)

namespace SelbergDatum

/-- The finite data packet, flattened into a manifestly countable target type. -/
def encode (x : SelbergDatum) : ℕ × ℕ × (ℚ × ℚ) × List (ℕ × List ℤ) :=
  (x.degree, x.conductor, x.rootNumber, x.eulerFactors)

/-- Distinct L-function data packets have distinct encodings: the finite packet
determines the datum. -/
theorem encode_injective : Function.Injective encode := by
  rintro ⟨a1, a2, a3, a4⟩ ⟨b1, b2, b3, b4⟩ h
  simpa [encode] using h

/-- **The census is countable.**  Because each L-function datum is a finite
packet drawn from countable ingredients, the entire universe of such data — and
hence of the L-functions it classifies — is no larger than `ℕ`. -/
instance instCountable : Countable SelbergDatum :=
  encode_injective.countable

/-- The map recording an L-function of degree `0`, trivial root number and no
Euler factors, indexed by its conductor.  It is injective, witnessing that the
census is infinite. -/
def ofConductor (n : ℕ) : SelbergDatum :=
  ⟨0, n, (0, 0), []⟩

theorem ofConductor_injective : Function.Injective ofConductor := by
  intro a b h
  simpa [ofConductor] using h

/-- **The census is infinite.**  Together with `instCountable`, the universe of
L-function data is *countably infinite* — precisely the cardinality of `ℤ`. -/
instance instInfinite : Infinite SelbergDatum :=
  Infinite.of_injective ofConductor ofConductor_injective

end SelbergDatum

/-! ## The census principle

If some family `L` of analytic objects can be *classified* by an injective map
into `SelbergDatum` (i.e. each object is determined by its finite data packet),
then `L` is countable.  This is the abstract engine behind "there are only
countably many L-functions of each type". -/

/-- **Census principle (type form).**  Any type that is injectively classified by
finite Selberg data is countable. -/
theorem census_countable {L : Type*} (classify : L → SelbergDatum)
    (h : Function.Injective classify) : Countable L :=
  h.countable

/-- **Census principle (set form).**  Any set of objects on which the
classification map is injective is a countable set. -/
theorem census_set_countable {α : Type*} {S : Set α} (classify : α → SelbergDatum)
    (h : Set.InjOn classify S) : S.Countable := by
  obtain ⟨g, hg⟩ := (SelbergDatum.instCountable).exists_injective_nat'
  exact Set.countable_iff_exists_injOn.2
    ⟨g ∘ classify, fun a ha b hb hab => h ha hb (hg hab)⟩

/-! ## Finite shells

The census is exhausted by *finite* strata of bounded complexity.  `BoundedDatum`
collects the data packets whose degree `≤ d`, conductor `≤ N`, that have at most
`k` recorded Euler factors of degree `≤ d`, and whose coefficients and root
number are bounded by `c` in absolute value.  Each such stratum is a `Fintype`,
so it can be explicitly enumerated. -/

/-- A *shell* of L-function data of bounded complexity, encoded so as to be a
finite type:

* `degree`   ranges over `Fin (d+1)`;
* `conductor` over `Fin (N+1)`;
* `reRoot`, `imRoot` over `Fin (2*c+1)` (a symmetric window of integers);
* `eulerFactors` is a length-`k` tuple of (prime `< N+1`, coefficient tuple of
  length `d+1` valued in a symmetric window of size `2*c+1`). -/
structure BoundedDatum (d N k c : ℕ) where
  /-- Bounded degree. -/
  degree : Fin (d + 1)
  /-- Bounded conductor. -/
  conductor : Fin (N + 1)
  /-- Real part of the (windowed) root number. -/
  reRoot : Fin (2 * c + 1)
  /-- Imaginary part of the (windowed) root number. -/
  imRoot : Fin (2 * c + 1)
  /-- The `k` bounded Euler factors. -/
  eulerFactors : Fin k → (Fin (N + 1) × (Fin (d + 1) → Fin (2 * c + 1)))
deriving Fintype

/-- Realise a bounded shell datum as a genuine `SelbergDatum`.  Windowed
coefficients `Fin (2*c+1)` are recentred to the integer interval `[-c, c]`. -/
def BoundedDatum.toSelberg {d N k c : ℕ} (x : BoundedDatum d N k c) : SelbergDatum where
  degree := x.degree
  conductor := x.conductor
  rootNumber := ((((x.reRoot : ℤ) - c : ℤ) : ℚ), (((x.imRoot : ℤ) - c : ℤ) : ℚ))
  eulerFactors :=
    List.ofFn fun i : Fin k =>
      ((x.eulerFactors i).1.1,
        List.ofFn fun j : Fin (d + 1) => (((x.eulerFactors i).2 j : ℤ) - c : ℤ))

/-- **Every shell is finite.**  The bounded-complexity L-functions form a finite
set, whose size is `Fintype.card (BoundedDatum d N k c)`. -/
theorem shellFinite (d N k c : ℕ) :
    (Set.range (BoundedDatum.toSelberg (d := d) (N := N) (k := k) (c := c))).Finite :=
  Set.finite_range _

/-
The realisation map on a shell is injective: distinct bounded data give
distinct L-functions.  Hence a shell has exactly `Fintype.card (BoundedDatum …)`
elements.
-/
theorem BoundedDatum.toSelberg_injective (d N k c : ℕ) :
    Function.Injective (BoundedDatum.toSelberg (d := d) (N := N) (k := k) (c := c)) := by
  intro x y; simp +decide [toSelberg]
  intro h1 h2 h3 h4 h5; have := congr_fun h5; simp_all +decide [funext_iff]
  cases x; cases y; simp_all +decide [Fin.ext_iff]
  ext a; specialize this a; simp_all +decide
  rename_i i; induction i using Fin.inductionOn <;> aesop

end SelbergCensus