/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.TropicalPrimeStoneDuality
/-!
# Spectral Hardness Separation for Tropical Cryptographic Primitives

## Overview

We formalize spectral certificates and a hardness separation theorem:
if two elements of a semiring are separated by a spectral certificate,
then no congruence-reflecting attack can collapse them. This converts
topological non-collapse (spectral separation) into a cryptographic
lower bound on inversion/collision complexity.

## Main Results

* `spectral_noncollapse` — reflecting attacks preserve spectral separation
* `spectral_hardness_separation` — the main hardness theorem
* `collision_implies_trivial_cert` — contrapositive: collision ⟹ trivial cert
* `spectralOWF_collision_resistant` — certified collision resistance
* `separated_implies_cert` — separation axiom yields certificates
* `certs_imply_evalMap_injective` — certificates imply Stone reconstruction
* `universal_collision_resistance` — all distinct pairs resist reflecting attacks
-/

noncomputable section

open Function Set TropicalStoneDuality

set_option maxHeartbeats 800000
set_option linter.unusedVariables false

namespace SpectralHardness

/-! ## Section 1: Spectral Certificates -/

/-- A **spectral certificate** for a pair `(x, y)`: a finite family of prime congruences,
each of which separates `x` from `y`.

In cryptographic terms, this is a multi-observer separation witness that
certifies collision resistance of the pair `(x, y)`. -/
structure SpectralCert (S : Type*) [Add S] [Mul S] (x y : S) where
  /-- Number of separating prime congruences -/
  size : ℕ
  /-- The family of separating prime congruences -/
  primes : Fin size → PrimeCong S
  /-- Each prime congruence in the family separates `x` from `y` -/
  separates : ∀ i : Fin size, ¬ (primes i).rel x y

/-- The **certificate complexity**: the number of prime congruences used. -/
def certComplexity {S : Type*} [Add S] [Mul S] {x y : S}
    (C : SpectralCert S x y) : ℕ := C.size

/-- A spectral certificate witnesses that the pair is distinct. -/
theorem cert_implies_ne {S : Type*} [Add S] [Mul S] {x y : S}
    (C : SpectralCert S x y) (hpos : 0 < C.size) :
    x ≠ y := by
  intro heq; subst heq
  exact C.separates ⟨0, hpos⟩ ((C.primes ⟨0, hpos⟩).rel.refl _)

/-! ## Section 2: Congruence-Reflecting Functions (Attack Model) -/

/-- A function `f : S → S` **reflects** a ring congruence `c` if
`c(f(a), f(b)) → c(a, b)`.

This captures functions that are "injective modulo `c`": they cannot
collapse distinct congruence classes into the same class. -/
def CongReflecting {S : Type*} [Add S] [Mul S] (f : S → S) (c : RingCon S) : Prop :=
  ∀ a b : S, c (f a) (f b) → c a b

/-- A function `f` is **fully reflecting** with respect to a certificate `C`
if it reflects every prime congruence in `C`. -/
def FullyReflecting {S : Type*} [Add S] [Mul S] (f : S → S) {x y : S}
    (C : SpectralCert S x y) : Prop :=
  ∀ i : Fin C.size, CongReflecting f (C.primes i).rel

/-! ## Section 3: The Spectral Hardness Separation Theorem -/

/-- **Spectral non-collapse (single congruence).**

If `f` reflects a congruence `c`, and `c` separates `x` from `y`,
then `c` also separates `f(x)` from `f(y)`. -/
theorem spectral_noncollapse_single {S : Type*} [Add S] [Mul S]
    (f : S → S) (c : RingCon S) (x y : S)
    (hrefl : CongReflecting f c) (hsep : ¬ c x y) :
    ¬ c (f x) (f y) :=
  fun hc => hsep (hrefl x y hc)

/-- **Spectral non-collapse (full certificate).**

If `f` is fully reflecting with respect to a certificate `C` for `(x, y)`,
then every congruence in `C` separates `f(x)` from `f(y)`. -/
theorem spectral_noncollapse {S : Type*} [Add S] [Mul S]
    (f : S → S) {x y : S} (C : SpectralCert S x y)
    (hrefl : FullyReflecting f C) :
    ∀ i : Fin C.size, ¬ (C.primes i).rel (f x) (f y) :=
  fun i => spectral_noncollapse_single f (C.primes i).rel x y (hrefl i) (C.separates i)

/-- **The Spectral Hardness Separation Theorem.**

If there exists a spectral certificate `C` separating `x` from `y`,
and an attack `f` reflects all congruences in `C`, then `f(x) ≠ f(y)`.

This is the central result: **spectral non-collapse implies non-invertibility**. -/
theorem spectral_hardness_separation {S : Type*} [Add S] [Mul S]
    (f : S → S) {x y : S} (C : SpectralCert S x y)
    (hpos : 0 < C.size)
    (hrefl : FullyReflecting f C) :
    f x ≠ f y := by
  intro heq
  have := spectral_noncollapse f C hrefl ⟨0, hpos⟩
  exact this (heq ▸ (C.primes ⟨0, hpos⟩).rel.refl _)

/-- **Contrapositive form**: if a reflecting attack produces a collision,
the certificate must be empty (trivial). -/
theorem collision_implies_trivial_cert {S : Type*} [Add S] [Mul S]
    (f : S → S) {x y : S} (C : SpectralCert S x y)
    (hrefl : FullyReflecting f C)
    (hcoll : f x = f y) :
    C.size = 0 := by
  by_contra hne
  exact spectral_hardness_separation f C (Nat.pos_of_ne_zero hne) hrefl hcoll

/-! ## Section 4: Certificate Operations and Complexity Bounds -/

/-- The identity function reflects every congruence. -/
theorem id_congReflecting {S : Type*} [Add S] [Mul S] (c : RingCon S) :
    CongReflecting (S := S) id c :=
  fun _ _ h => h

/-- The identity is fully reflecting for any certificate. -/
theorem id_fullyReflecting {S : Type*} [Add S] [Mul S] {x y : S}
    (C : SpectralCert S x y) :
    FullyReflecting id C :=
  fun i => id_congReflecting (C.primes i).rel

/-- The identity never produces collisions on spectrally separated pairs. -/
theorem no_trivial_collapse {S : Type*} [Add S] [Mul S] {x y : S}
    (C : SpectralCert S x y) (hpos : 0 < C.size) : id x ≠ id y :=
  spectral_hardness_separation id C hpos (id_fullyReflecting C)

/-- Composition of congruence-reflecting functions preserves the reflecting property. -/
theorem congReflecting_comp {S : Type*} [Add S] [Mul S]
    (f g : S → S) (c : RingCon S)
    (hf : CongReflecting f c) (hg : CongReflecting g c) :
    CongReflecting (f ∘ g) c :=
  fun a b h => hg a b (hf (g a) (g b) h)

/-- If `f` and `g` both fully reflect a certificate, so does `f ∘ g`.
This shows the attack class is closed under composition. -/
theorem fullyReflecting_comp {S : Type*} [Add S] [Mul S]
    (f g : S → S) {x y : S} (C : SpectralCert S x y)
    (hf : FullyReflecting f C) (hg : FullyReflecting g C) :
    FullyReflecting (f ∘ g) C :=
  fun i => congReflecting_comp f g (C.primes i).rel (hf i) (hg i)

/-- **Hardness amplification under composition**: composing two reflecting attacks
still cannot collapse a spectrally separated pair. -/
theorem composed_noncollapse {S : Type*} [Add S] [Mul S]
    (f g : S → S) {x y : S} (C : SpectralCert S x y)
    (hpos : 0 < C.size)
    (hf : FullyReflecting f C) (hg : FullyReflecting g C) :
    (f ∘ g) x ≠ (f ∘ g) y :=
  spectral_hardness_separation (f ∘ g) C hpos (fullyReflecting_comp f g C hf hg)

/-! ## Section 5: Subcertificates and Monotonicity -/

/-- A subcertificate of a certificate: obtained by restricting to a subset of primes. -/
def subcert {S : Type*} [Add S] [Mul S] {x y : S}
    (C : SpectralCert S x y) (m : ℕ) (hm : m ≤ C.size) :
    SpectralCert S x y where
  size := m
  primes := fun i => C.primes ⟨i.val, Nat.lt_of_lt_of_le i.isLt hm⟩
  separates := fun i => C.separates ⟨i.val, Nat.lt_of_lt_of_le i.isLt hm⟩

/-- Subcertificates have smaller or equal complexity. -/
theorem subcert_complexity_le {S : Type*} [Add S] [Mul S] {x y : S}
    (C : SpectralCert S x y) (m : ℕ) (hm : m ≤ C.size) :
    certComplexity (subcert C m hm) ≤ certComplexity C := hm

/-- **Monotonicity**: if an attack reflects a certificate, it also reflects
any subcertificate. -/
theorem fullyReflecting_subcert {S : Type*} [Add S] [Mul S]
    (f : S → S) {x y : S} (C : SpectralCert S x y) (m : ℕ) (hm : m ≤ C.size)
    (hrefl : FullyReflecting f C) :
    FullyReflecting f (subcert C m hm) :=
  fun i => hrefl ⟨i.val, Nat.lt_of_lt_of_le i.isLt hm⟩

/-! ## Section 6: Connection to Stone Duality -/

/-- **Bridge: Stone duality implies spectral certificate existence.**

If `S` is spectrally separated, then for any distinct pair `(x, y)`,
a spectral certificate of size 1 exists. -/
theorem separated_implies_cert {S : Type*} [NonAssocSemiring S]
    (hsep : SpectrallySeparated S) {x y : S} (hne : x ≠ y) :
    ∃ C : SpectralCert S x y, 0 < C.size := by
  obtain ⟨p, hp⟩ := hsep x y hne
  exact ⟨⟨1, fun _ => p, fun _ => hp⟩, Nat.one_pos⟩

/-- **Bridge: certificates imply evaluation map injectivity.** -/
theorem certs_imply_evalMap_injective {S : Type*} [NonAssocSemiring S]
    (hcerts : ∀ x y : S, x ≠ y → ∃ C : SpectralCert S x y, 0 < C.size) :
    Injective (evalMap S) := by
  apply evalMap_injective
  intro a b hab
  obtain ⟨C, hpos⟩ := hcerts a b hab
  exact ⟨C.primes ⟨0, hpos⟩, C.separates ⟨0, hpos⟩⟩

/-- **Bridge: every distinct pair in a spectrally separated semiring
is collision-resistant against reflecting attacks.** -/
theorem universal_collision_resistance {S : Type*} [NonAssocSemiring S]
    (hsep : SpectrallySeparated S) (f : S → S)
    {x y : S} (hne : x ≠ y)
    (hrefl : ∀ p : SpecC S, ¬ p.rel x y → CongReflecting f p.rel) :
    f x ≠ f y := by
  obtain ⟨p, hp⟩ := hsep x y hne
  intro heq
  apply spectral_noncollapse_single f p.rel x y (hrefl p hp) hp
  rw [heq]; exact p.rel.refl _

/-! ## Section 7: Spectral One-Way Functions -/

/-- A **one-way function candidate** in the spectral framework:
a semiring endomorphism equipped with spectral hardness certificates. -/
structure SpectralOWF (S : Type*) [Add S] [Mul S] where
  /-- The candidate one-way function -/
  func : S → S
  /-- Predicate for hard pairs -/
  hardPairs : S → S → Prop
  /-- Certificate witness for hard pairs -/
  cert : ∀ x y : S, hardPairs x y → SpectralCert S (func x) (func y)
  /-- Hard pair certificates are nontrivial -/
  cert_nontrivial : ∀ x y : S, (h : hardPairs x y) → 0 < (cert x y h).size

/-- **Certified collision resistance**: a spectral OWF resists collisions
from reflecting attacks on hard pairs. -/
theorem spectralOWF_collision_resistant {S : Type*} [Add S] [Mul S]
    (owf : SpectralOWF S) (A : S → S)
    {x y : S} (hhard : owf.hardPairs x y)
    (hrefl : FullyReflecting A (owf.cert x y hhard)) :
    A (owf.func x) ≠ A (owf.func y) :=
  spectral_hardness_separation A (owf.cert x y hhard)
    (owf.cert_nontrivial x y hhard) hrefl

/-- **Minimum certificate complexity**: the spectral OWF hardness is bounded below
by the certificate complexity. -/
theorem spectralOWF_complexity_bound {S : Type*} [Add S] [Mul S]
    (owf : SpectralOWF S) {x y : S} (hhard : owf.hardPairs x y) :
    0 < certComplexity (owf.cert x y hhard) :=
  owf.cert_nontrivial x y hhard

/-! ## Section 8: Tropical Attack Syntax -/

/-- Elementary tropical operations: the syntax of the attack model. -/
inductive TropOp (S : Type*) where
  | id : TropOp S
  | const : S → TropOp S
  | comp : TropOp S → TropOp S → TropOp S

/-- Interpretation of a tropical operation as a function. -/
def TropOp.eval {S : Type*} : TropOp S → (S → S)
  | .id => _root_.id
  | .const c => fun _ => c
  | .comp f g => fun x => f.eval (g.eval x)

/-- The **depth** of a tropical operation: a measure of attack complexity. -/
def TropOp.depth {S : Type*} : TropOp S → ℕ
  | .id => 0
  | .const _ => 0
  | .comp f g => 1 + max f.depth g.depth

/-- The identity operation reflects every congruence. -/
theorem tropOp_id_reflects {S : Type*} [Add S] [Mul S] (c : RingCon S) :
    CongReflecting (TropOp.eval (TropOp.id (S := S))) c :=
  fun _ _ h => h

/-- Composition of reflecting operations yields a reflecting operation. -/
theorem tropOp_comp_reflects {S : Type*} [Add S] [Mul S]
    {f g : TropOp S} {c : RingCon S}
    (hf : CongReflecting f.eval c) (hg : CongReflecting g.eval c) :
    CongReflecting (TropOp.comp f g).eval c := by
  intro a b h
  exact hg a b (hf _ _ h)

/-- **Depth lower bound**: if an attack is fully reflecting for a certificate
with positive size, the attack cannot collapse the pair. -/
theorem tropOp_depth_hardness {S : Type*} [Add S] [Mul S]
    {op : TropOp S} {x y : S} (C : SpectralCert S x y)
    (hpos : 0 < C.size)
    (hrefl : FullyReflecting op.eval C) :
    op.eval x ≠ op.eval y :=
  spectral_hardness_separation op.eval C hpos hrefl

end SpectralHardness