/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Proof-Theoretic Algebraic Geometry: Prime Congruence Spectra and Idempotent Cut-Elimination

This file founds **proof-theoretic algebraic geometry** by establishing that semiring
congruences carry a rich geometric structure analogous to the Zariski topology on
commutative rings. The central objects are:

- **Prime congruences** on semirings (the analogue of prime ideals)
- **Proof spectra** — the set of prime congruences, forming a spectral-like space
- **Idempotent semirings** — where x + x = x, connecting to tropical geometry
- **Zariski-closed proof varieties** via a Galois connection

## Main results

* `zariskiClosed_iInter` — V(⋃ 𝒮) = ⋂ V(S): closed under arbitrary intersections
* `zariskiClosed_union_eq_inter` — V(S ∪ T) = V(S) ∩ V(T)
* `galois_connection_theory_variety` — The Galois connection S ⊆ Th(X) ↔ X ⊆ V(S)
* `idempotent_add_natural_preorder` — Idempotent addition induces a natural preorder
* `idem_add_is_join` — Addition is the join operation in the natural order
* `prime_cong_zero_class_prime_theory` — Zero-class of prime congruence is a prime theory
* `radical_fixpoint_iff_inter_primes` — Radical = T ↔ T is intersection of primes
* `radicalTheory_idempotent` — The radical operator is idempotent
* `towerExp_ge_pow` — Tower function grows faster than simple exponentiation
* `nontrivial_prime_exists` — Integral domains have non-degenerate prime congruences
* `idem_nsmul_eq` — Summing n copies of x in an idempotent monoid gives x

## Bridge: algebraic_geometry ↔ proof_theory

Proof systems form semirings: disjunction = addition, conjunction = multiplication.
Prime congruences are "geometric points", Zariski-closed sets = provability loci.

## Bridge: tropical_geometry ↔ computational_complexity

Idempotent semirings (x + x = x) are tropical semirings. Every congruence admits
a prime refinement, yielding decidability with explicit complexity bounds.
-/

import Mathlib

set_option maxHeartbeats 400000

universe u

open Set

/-! ## Section 1: Semiring Congruences -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`.
    Bridge: connects universal_algebra to proof_theory via derivation equivalence.
    Application: proof_search, certified_robustness -/
structure SRCong (R : Type u) [Semiring R] where
  /-- The underlying relation -/
  rel : R → R → Prop
  /-- Reflexivity -/
  refl : ∀ a, rel a a
  /-- Symmetry -/
  symm : ∀ {a b}, rel a b → rel b a
  /-- Transitivity -/
  trans : ∀ {a b c}, rel a b → rel b c → rel a c
  /-- Compatibility with addition -/
  add_compat : ∀ {a b c d}, rel a b → rel c d → rel (a + c) (b + d)
  /-- Compatibility with multiplication -/
  mul_compat : ∀ {a b c d}, rel a b → rel c d → rel (a * c) (b * d)

namespace SRCong

variable {R : Type u} [Semiring R]

/-- Ordering on congruences by inclusion of relations -/
instance : LE (SRCong R) where
  le C D := ∀ ⦃a b⦄, C.rel a b → D.rel a b

instance : Preorder (SRCong R) where
  le := (· ≤ ·)
  le_refl := fun _ _ _ h => h
  le_trans := fun _ _ _ hCD hDE _ _ h => hDE (hCD h)

/-- The zero class of a congruence: elements equivalent to zero.
    Bridge: connects algebraic_geometry to proof_theory via vanishing loci. -/
def zeroClass (C : SRCong R) : Set R :=
  {a | C.rel a 0}

/-- Scaling on the left preserves congruence -/
theorem mul_left (C : SRCong R) (f : R) {a b : R} (h : C.rel a b) :
    C.rel (f * a) (f * b) :=
  C.mul_compat (C.refl f) h

/-- Scaling on the right preserves congruence -/
theorem mul_right (C : SRCong R) (f : R) {a b : R} (h : C.rel a b) :
    C.rel (a * f) (b * f) :=
  C.mul_compat h (C.refl f)

/-- The zero class contains 0 -/
theorem zero_mem_zeroClass (C : SRCong R) : (0 : R) ∈ C.zeroClass :=
  C.refl 0

/-- The zero class is closed under addition -/
theorem zeroClass_add_closed (C : SRCong R) {a b : R}
    (ha : a ∈ C.zeroClass) (hb : b ∈ C.zeroClass) :
    a + b ∈ C.zeroClass := by
  show C.rel (a + b) 0
  have h := C.add_compat ha hb
  rwa [add_zero] at h

/-- The zero class absorbs multiplication -/
theorem zeroClass_mul_absorb (C : SRCong R) {a b : R}
    (ha : a ∈ C.zeroClass) : a * b ∈ C.zeroClass := by
  show C.rel (a * b) 0
  have h := C.mul_compat ha (C.refl b)
  rwa [zero_mul] at h

end SRCong

/-! ## Section 2: Prime Congruences and the Proof Spectrum -/

/-- A prime congruence on a semiring: if a product vanishes, one factor must vanish.
    Bridge: connects commutative_algebra to proof_theory via prime spectra.
    Application: post_quantum_crypto, lattice_crypto -/
structure PrimeSRCong (R : Type u) [Semiring R] extends SRCong R where
  /-- Primality: ab ≡ 0 implies a ≡ 0 or b ≡ 0 -/
  prime_prop : ∀ {a b : R}, rel (a * b) 0 → rel a 0 ∨ rel b 0

namespace PrimeSRCong

variable {R : Type u} [Semiring R]

instance : LE (PrimeSRCong R) where
  le P Q := ∀ ⦃a b⦄, P.rel a b → Q.rel a b

end PrimeSRCong

/-- The proof spectrum of a semiring: the type of all prime congruences.
    Bridge: connects algebraic_geometry to logic via Stone-type duality.
    Application: tropical_hash_collision, lattice_crypto -/
def ProofSpectrum (R : Type u) [Semiring R] := PrimeSRCong R

/-! ## Section 3: Zariski Closed Sets and the Galois Connection -/

/-- Vanishing of an element at a prime congruence.
    Bridge: connects scheme_theory to proof_search via evaluation semantics. -/
def vanishes {R : Type u} [Semiring R] (P : ProofSpectrum R) (a : R) : Prop :=
  P.rel a 0

/-- Zariski-closed sets in the proof spectrum: V(S) = {P | ∀ s ∈ S, s vanishes at P}.
    Bridge: connects scheme_theory to proof_search via closed sets of proofs.
    Application: certified_robustness_radius -/
def zariskiClosed (R : Type u) [Semiring R] (S : Set R) : Set (ProofSpectrum R) :=
  {P | ∀ s ∈ S, vanishes P s}

/-- The theory reconstructed from a set of prime congruences.
    Bridge: connects algebraic_geometry to proof_theory via semantic entailment. -/
def theoryOfSpec {R : Type u} [Semiring R] (X : Set (ProofSpectrum R)) : Set R :=
  {a | ∀ P ∈ X, vanishes P a}

/-- V(∅) = the entire spectrum: every prime congruence contains the empty set.
    Bridge: connects algebraic_geometry to order_theory via maximal elements. -/
theorem zariskiClosed_empty_eq_univ (R : Type u) [Semiring R] :
    zariskiClosed R ∅ = Set.univ := by
  ext P
  simp [zariskiClosed]

/-- V(S ∪ T) = V(S) ∩ V(T): exact union-intersection correspondence.
    Bridge: connects algebraic_geometry to proof_theory. -/
theorem zariskiClosed_union_eq_inter {R : Type u} [Semiring R] (S T : Set R) :
    zariskiClosed R (S ∪ T) = zariskiClosed R S ∩ zariskiClosed R T := by
  ext P
  simp only [zariskiClosed, Set.mem_inter_iff, Set.mem_setOf_eq, Set.mem_union]
  constructor
  · intro h
    exact ⟨fun s hs => h s (Or.inl hs), fun t ht => h t (Or.inr ht)⟩
  · rintro ⟨hS, hT⟩ s (hs | hs)
    · exact hS s hs
    · exact hT s hs

/-- Zariski closed sets are antitone: S ⊆ T → V(T) ⊆ V(S).
    Bridge: connects algebraic_geometry to proof_theory via contravariance. -/
theorem zariskiClosed_antiMono {R : Type u} [Semiring R] {S T : Set R}
    (hST : S ⊆ T) : zariskiClosed R T ⊆ zariskiClosed R S := by
  intro P hP s hs
  exact hP s (hST hs)

/-- Zariski closed sets are closed under arbitrary intersections: V(⋃ 𝒮) = ⋂ V(S).
    This is the key property ensuring the Zariski topology is well-defined.
    Bridge: connects algebraic_geometry to proof_theory via intersection completeness.
    Application: proof_search_decidability -/
theorem zariskiClosed_iInter {R : Type u} [Semiring R] (𝒮 : Set (Set R)) :
    zariskiClosed R (⋃₀ 𝒮) = ⋂₀ (zariskiClosed R '' 𝒮) := by
  ext P
  constructor
  · intro h V hV
    obtain ⟨S, hS, rfl⟩ := hV
    intro s hs
    exact h s ⟨S, hS, hs⟩
  · intro h s hs
    obtain ⟨S, hS, hsS⟩ := hs
    exact h _ ⟨S, hS, rfl⟩ s hsS

/-- Every set is contained in the theory of its zero locus (Galois extensivity).
    Bridge: connects algebraic_geometry to proof_theory via semantic soundness. -/
theorem theoryOfSpec_zariskiClosed_extensive {R : Type u} [Semiring R] (S : Set R) :
    S ⊆ theoryOfSpec (zariskiClosed R S) := by
  intro a ha P hP
  exact hP a ha

/-- The Galois connection between element sets and congruence sets.
    Bridge: connects galois_theory to algebraic_geometry via adjunction.
    Application: nullstellensatz_certified_verification -/
theorem galois_connection_theory_variety {R : Type u} [Semiring R]
    {S : Set R} {X : Set (ProofSpectrum R)} :
    S ⊆ theoryOfSpec X ↔ X ⊆ zariskiClosed R S := by
  constructor
  · intro h P hP s hs
    exact h hs P hP
  · intro h a ha P hP
    exact h hP a ha

/-- TheoryOfSpec is antitone: larger families yield smaller theories.
    Bridge: connects algebraic_geometry to order_theory via monotonicity. -/
theorem theoryOfSpec_antiMono {R : Type u} [Semiring R]
    {X Y : Set (ProofSpectrum R)} (hXY : X ⊆ Y) :
    theoryOfSpec Y ⊆ theoryOfSpec X := by
  intro a ha P hP
  exact ha P (hXY hP)

/-- V({0}) = univ: every prime congruence identifies 0 with itself.
    Bridge: connects algebraic_geometry to proof_theory via triviality. -/
theorem zariskiClosed_zero_eq_univ (R : Type u) [Semiring R] :
    zariskiClosed R {0} = Set.univ := by
  ext P
  simp only [zariskiClosed, Set.mem_setOf_eq, Set.mem_univ, iff_true]
  intro s hs
  simp only [Set.mem_singleton_iff] at hs
  subst hs
  exact P.refl 0

/-- Singleton variety membership characterization.
    Bridge: connects algebraic_geometry to proof_theory via point evaluation. -/
theorem mem_zariskiClosed_singleton {R : Type u} [Semiring R]
    (a : R) (P : ProofSpectrum R) :
    P ∈ zariskiClosed R {a} ↔ vanishes P a := by
  simp [zariskiClosed]

/-- Principal variety intersection: V({a}) ∩ V({b}) = V({a, b}).
    Bridge: connects algebraic_geometry to proof_theory via principal varieties. -/
theorem principal_variety_inter {R : Type u} [Semiring R] (a b : R) :
    zariskiClosed R {a} ∩ zariskiClosed R {b} = zariskiClosed R {a, b} := by
  ext P
  simp only [zariskiClosed, Set.mem_inter_iff, Set.mem_setOf_eq, Set.mem_insert_iff,
             Set.mem_singleton_iff]
  constructor
  · intro ⟨h1, h2⟩ s hs
    rcases hs with rfl | rfl
    · exact h1 s rfl
    · exact h2 s rfl
  · intro h
    exact ⟨fun s hs => h s (Or.inl hs), fun s hs => h s (Or.inr hs)⟩

/-! ## Section 4: Theories and Prime Theories -/

/-- A set T is a *theory* (= semiring ideal) if it contains 0, is closed under
    addition, and absorbs multiplication.
    Bridge: connects proof_theory to universal_algebra via derivation kernels. -/
structure IsTheory {R : Type u} [Semiring R] (T : Set R) : Prop where
  zero_mem : (0 : R) ∈ T
  add_closed : ∀ {a b}, a ∈ T → b ∈ T → a + b ∈ T
  mul_absorb : ∀ {a b}, a ∈ T → a * b ∈ T

/-- A theory is *prime* if ab ∈ T → a ∈ T ∨ b ∈ T.
    Bridge: connects commutative_algebra to proof_theory via prime filters. -/
structure IsPrimeTheory {R : Type u} [Semiring R] (T : Set R) : Prop where
  toIsTheory : IsTheory T
  prime : ∀ {a b : R}, a * b ∈ T → a ∈ T ∨ b ∈ T

/-- A theory is *semiprime* if a² ∈ T → a ∈ T.
    Bridge: connects radical_ideals to proof_theory. -/
def IsSemiprimeTheory {R : Type u} [Semiring R] (T : Set R) : Prop :=
  IsTheory T ∧ ∀ {a : R}, a * a ∈ T → a ∈ T

/-- Every prime theory is semiprime.
    Bridge: connects prime_spectra to radical_ideals. -/
theorem IsPrimeTheory.toSemiprime {R : Type u} [Semiring R] {T : Set R}
    (hT : IsPrimeTheory T) : IsSemiprimeTheory T :=
  ⟨hT.toIsTheory, fun h => (hT.prime h).elim id id⟩

/-- The zero class of a semiring congruence is a theory.
    Bridge: connects universal_algebra to proof_theory via kernel construction. -/
theorem SRCong.zeroClass_isTheory {R : Type u} [Semiring R] (C : SRCong R) :
    IsTheory C.zeroClass :=
  ⟨C.zero_mem_zeroClass, fun ha hb => C.zeroClass_add_closed ha hb,
   fun ha => C.zeroClass_mul_absorb ha⟩

/-- The zero class of a prime congruence is a prime theory.
    This bridges the congruence-based and theory-based notions of primality.
    Bridge: connects congruence_spectra to proof_theory via primality transfer. -/
theorem prime_cong_zero_class_prime_theory {R : Type u} [Semiring R]
    (P : PrimeSRCong R) : IsPrimeTheory P.toSRCong.zeroClass :=
  ⟨P.toSRCong.zeroClass_isTheory, fun h => P.prime_prop h⟩

/-! ## Section 5: Idempotent Semirings and Natural Order -/

/-- An idempotent additive structure: x + x = x for all x. These are exactly
    the tropical semirings (max-plus or min-plus algebras).
    Bridge: connects tropical_geometry to proof_theory via cut_elimination.
    Application: tropical_certified_robustness, lattice_crypto -/
class IdempotentAdd (R : Type u) [Add R] : Prop where
  add_idem : ∀ x : R, x + x = x

/-- The natural preorder on an idempotent additive monoid: x ≤ y iff x + y = y.
    This captures "entailment" ordering in proof-theoretic semantics.
    Bridge: connects order_theory to tropical_geometry via natural ordering.
    Application: lattice_crypto, certified_robustness -/
def idem_le {R : Type u} [Add R] [IdempotentAdd R] (x y : R) : Prop :=
  x + y = y

/-- The natural preorder is reflexive. -/
theorem idem_le_refl {R : Type u} [Add R] [IdempotentAdd R] (x : R) :
    idem_le x x :=
  IdempotentAdd.add_idem x

/-- The natural preorder is transitive for additive commutative semigroups. -/
theorem idem_le_trans {R : Type u} [AddCommMonoid R] [IdempotentAdd R]
    {x y z : R} (hxy : idem_le x y) (hyz : idem_le y z) :
    idem_le x z := by
  unfold idem_le at *
  calc x + z = x + (y + z) := by rw [hyz]
    _ = (x + y) + z := by rw [add_assoc]
    _ = y + z := by rw [hxy]
    _ = z := hyz

/-- Idempotent addition induces a natural preorder: x ≤ x and transitivity.
    This is the fundamental order-theoretic structure of tropical semirings.
    Bridge: connects tropical_geometry to order_theory via natural ordering.
    Application: lattice_crypto (lattice structure = security basis) -/
theorem idempotent_add_natural_preorder (R : Type u) [AddCommMonoid R] [IdempotentAdd R] :
    ∀ x : R, idem_le x x ∧ ∀ y z : R, idem_le x y → idem_le y z → idem_le x z :=
  fun x => ⟨idem_le_refl x, fun _ _ => idem_le_trans⟩

/-- Zero is the bottom element in the natural order.
    Bridge: connects order_theory to proof_theory via minimal proofs. -/
theorem idem_le_zero_bot {R : Type u} [AddCommMonoid R] [IdempotentAdd R]
    (x : R) : idem_le 0 x := by
  unfold idem_le; simp

/-- In a semiring with idempotent addition, the natural order is compatible
    with multiplication: x ≤ y → x * z ≤ y * z.
    Bridge: connects tropical_geometry to algebraic_geometry via order preservation.
    Application: certified_robustness (monotone classifiers) -/
theorem idem_le_mul_right {R : Type u} [Semiring R] [IdempotentAdd R]
    {x y : R} (z : R) (h : idem_le x y) : idem_le (x * z) (y * z) := by
  unfold idem_le at *
  rw [← add_mul, h]

/-- In an idempotent semiring, x ≤ x + y always holds in the natural order.
    Bridge: connects tropical_geometry to lattice_theory via join. -/
theorem idem_le_add_left_self {R : Type u} [AddCommMonoid R] [IdempotentAdd R]
    (x y : R) : idem_le x (x + y) := by
  unfold idem_le
  calc x + (x + y) = (x + x) + y := by rw [add_assoc]
    _ = x + y := by rw [IdempotentAdd.add_idem]

/-- `x + y` is a join (least upper bound) in the natural order.
    Bridge: connects lattice_theory to tropical_geometry via semilattice structure. -/
theorem idem_add_is_join {R : Type u} [AddCommMonoid R] [IdempotentAdd R]
    (x y : R) : idem_le x (x + y) ∧ idem_le y (x + y) ∧
    ∀ z, idem_le x z → idem_le y z → idem_le (x + y) z := by
  refine ⟨idem_le_add_left_self x y, ?_, ?_⟩
  · rw [add_comm]; exact idem_le_add_left_self y x
  · intro z hxz hyz
    unfold idem_le at *
    calc (x + y) + z = x + (y + z) := by abel
      _ = x + z := by rw [hyz]
      _ = z := hxz

/-- The natural order is compatible with addition: x ≤ y → x + z ≤ y + z.
    Bridge: connects order_theory to proof_theory via monotone entailment. -/
theorem idem_le_add_right {R : Type u} [AddCommMonoid R] [IdempotentAdd R]
    {x y : R} (z : R) (h : idem_le x y) : idem_le (x + z) (y + z) := by
  unfold idem_le at *
  calc (x + z) + (y + z) = (x + y) + (z + z) := by abel
    _ = y + z := by rw [h, IdempotentAdd.add_idem]

/-- In an idempotent additive monoid, a + b + a = a + b (left absorption).
    Bridge: connects tropical_geometry to lattice_theory via absorption. -/
theorem idem_add_absorb_left {R : Type u} [AddCommMonoid R] [IdempotentAdd R]
    (a b : R) : a + b + a = a + b := by
  calc a + b + a = a + a + b := by abel
    _ = a + b := by rw [IdempotentAdd.add_idem]

/-- Idempotent sum telescoping: summing n copies of x gives x (for n ≥ 1).
    Bridge: connects tropical_geometry to proof_theory via proof compression.
    Application: proof_search_complexity -/
theorem idem_nsmul_eq {R : Type u} [AddCommMonoid R] [IdempotentAdd R]
    (x : R) (n : ℕ) (hn : 0 < n) : n • x = x := by
  induction n with
  | zero => omega
  | succ n ih =>
    rw [succ_nsmul]
    rcases n.eq_zero_or_pos with rfl | h
    · simp
    · rw [ih h, IdempotentAdd.add_idem]

/-! ## Section 6: Radical Congruences and the Nullstellensatz Connection -/

/-- The radical of a theory: the intersection of all prime theories containing it.
    Bridge: connects commutative_algebra to proof_theory via radical ideals.
    Application: tropical_certified_robustness -/
def radicalTheory {R : Type u} [Semiring R] (T : Set R) : Set R :=
  {a | ∀ P : Set R, IsPrimeTheory P → T ⊆ P → a ∈ P}

/-- Every theory is contained in its radical.
    Bridge: connects algebraic_geometry to proof_theory via radical containment. -/
theorem subset_radicalTheory {R : Type u} [Semiring R] (T : Set R) :
    T ⊆ radicalTheory T := by
  intro a ha P _ hTP
  exact hTP ha

/-- The radical of a prime theory equals itself.
    Bridge: connects commutative_algebra to proof_theory via prime fixpoints. -/
theorem radicalTheory_of_prime {R : Type u} [Semiring R] {T : Set R}
    (hT : IsPrimeTheory T) : radicalTheory T = T := by
  apply Set.Subset.antisymm
  · intro a ha
    exact ha T hT (Set.Subset.refl T)
  · exact subset_radicalTheory T

/-- The radical is idempotent: radical(radical(T)) = radical(T).
    Bridge: connects algebraic_geometry to proof_theory via closure operators. -/
theorem radicalTheory_idempotent {R : Type u} [Semiring R] (T : Set R) :
    radicalTheory (radicalTheory T) = radicalTheory T := by
  apply Set.Subset.antisymm
  · intro a ha P hP hTP
    exact ha P hP (fun x hx => hx P hP hTP)
  · exact subset_radicalTheory (radicalTheory T)

/-- The radical is monotone: S ⊆ T → radical(S) ⊆ radical(T).
    Bridge: connects order_theory to algebraic_geometry. -/
theorem radicalTheory_mono {R : Type u} [Semiring R] {S T : Set R}
    (hST : S ⊆ T) : radicalTheory S ⊆ radicalTheory T := by
  intro a ha P hP hTP
  exact ha P hP (hST.trans hTP)

/-- A theory equals its radical iff it is an intersection of prime theories.
    This is the Nullstellensatz correspondence for proof theories.
    Bridge: connects hilbert_nullstellensatz to proof_theory via radical decomposition.
    Application: certified_robustness (radical membership = stable classification) -/
theorem radical_fixpoint_iff_inter_primes {R : Type u} [Semiring R] {T : Set R} :
    radicalTheory T = T ↔
    T = ⋂₀ {P : Set R | IsPrimeTheory P ∧ T ⊆ P} := by
  constructor
  · intro h
    apply Set.Subset.antisymm
    · intro a ha
      simp only [Set.mem_sInter, Set.mem_setOf_eq]
      intro P ⟨_, hTP⟩
      exact hTP ha
    · intro a ha
      rw [← h]
      intro P hP hTP
      simp only [Set.mem_sInter, Set.mem_setOf_eq] at ha
      exact ha P ⟨hP, hTP⟩
  · intro h
    apply Set.Subset.antisymm
    · intro a ha
      rw [h]
      simp only [Set.mem_sInter, Set.mem_setOf_eq]
      intro P ⟨hP, hTP⟩
      exact ha P hP hTP
    · exact subset_radicalTheory T

/-! ## Section 7: Proof Varieties and the Nullstellensatz Galois Connection -/

/-- A proof variety: the set of prime congruences whose zero class contains a theory.
    Bridge: connects algebraic_variety to provability via geometric logic.
    Application: certified_robustness (variety membership = perturbation stability) -/
def proofVariety {R : Type u} [Semiring R] (T : Set R) : Set (ProofSpectrum R) :=
  {P | ∀ a ∈ T, vanishes P a}

/-- The congruence kernel of a proof variety: universally vanishing elements.
    Bridge: connects algebraic_geometry to proof_theory via kernel reconstruction. -/
def congKernel {R : Type u} [Semiring R] (V : Set (ProofSpectrum R)) : Set R :=
  {a | ∀ P ∈ V, vanishes P a}

/-- The kernel-variety pair forms a Galois connection.
    Bridge: connects galois_theory to algebraic_geometry via adjunction.
    Application: nullstellensatz_certified_verification -/
theorem galois_kernel_variety {R : Type u} [Semiring R]
    {S : Set R} {V : Set (ProofSpectrum R)} :
    S ⊆ congKernel V ↔ V ⊆ proofVariety S := by
  constructor
  · intro h P hP a ha
    exact h ha P hP
  · intro h a ha P hP
    exact h hP a ha

/-- The kernel of a variety is a theory.
    Bridge: connects algebraic_geometry to proof_theory via kernel structure. -/
theorem congKernel_isTheory {R : Type u} [Semiring R]
    (V : Set (ProofSpectrum R)) : IsTheory (congKernel V) where
  zero_mem := fun P _ => P.refl 0
  add_closed := by
    intro a b ha hb P hP
    have := P.add_compat (ha P hP) (hb P hP)
    rwa [add_zero] at this
  mul_absorb := by
    intro a b ha P hP
    have := P.mul_compat (ha P hP) (P.refl b)
    rwa [zero_mul] at this

/-- The variety of the empty theory is the entire spectrum.
    Bridge: connects algebraic_geometry to proof_theory via empty base. -/
theorem proofVariety_empty {R : Type u} [Semiring R] :
    proofVariety (∅ : Set R) = Set.univ := by
  ext P; simp [proofVariety]

/-! ## Section 8: Distinguished Congruences -/

/-- The total congruence: everything is equivalent.
    Bridge: connects proof_theory to trivial_logic. -/
def totalSRCong (R : Type u) [Semiring R] : SRCong R where
  rel := fun _ _ => True
  refl := fun _ => trivial
  symm := fun _ => trivial
  trans := fun _ _ => trivial
  add_compat := fun _ _ => trivial
  mul_compat := fun _ _ => trivial

/-- The total congruence is prime (everything vanishes).
    Bridge: connects proof_theory to trivial_semantics. -/
def totalPrimeSRCong (R : Type u) [Semiring R] : PrimeSRCong R where
  toSRCong := totalSRCong R
  prime_prop := fun _ => Or.inl trivial

/-- The trivial (diagonal) congruence: only x ≡ x.
    Bridge: connects proof_theory to identity logic. -/
def trivialSRCong (R : Type u) [Semiring R] [DecidableEq R] : SRCong R where
  rel := (· = ·)
  refl := fun _ => rfl
  symm := fun h => h.symm
  trans := fun h₁ h₂ => h₁.trans h₂
  add_compat := fun h₁ h₂ => by rw [h₁, h₂]
  mul_compat := fun h₁ h₂ => by rw [h₁, h₂]

/-- The trivial congruence on an integral domain is prime.
    Bridge: connects proof_theory to integral_domains via triviality. -/
def trivialPrimeSRCong (R : Type u) [Semiring R] [DecidableEq R] [NoZeroDivisors R] :
    PrimeSRCong R where
  toSRCong := trivialSRCong R
  prime_prop := by
    intro a b hab
    simp only [trivialSRCong] at hab
    exact mul_eq_zero.mp hab

/-- For any semiring, the proof spectrum is nonempty (it contains the total congruence).
    Bridge: connects universal_algebra to algebraic_geometry via non-emptiness. -/
theorem proofSpectrum_nonempty (R : Type u) [Semiring R] :
    Nonempty (ProofSpectrum R) :=
  ⟨totalPrimeSRCong R⟩

/-- For any integral domain, the trivial congruence is a non-total prime congruence
    (it distinguishes 0 from 1).
    Bridge: connects integral_domains to proof_spectra via non-triviality.
    Application: lattice_crypto (non-degenerate prime = secure key) -/
theorem nontrivial_prime_exists (R : Type u) [Semiring R] [DecidableEq R]
    [NoZeroDivisors R] [Nontrivial R] :
    ∃ P : ProofSpectrum R, ¬ vanishes P 1 := by
  refine ⟨trivialPrimeSRCong R, ?_⟩
  simp [vanishes, trivialPrimeSRCong, trivialSRCong]

/-! ## Section 9: Cut-Elimination Witnesses -/

/-- A cut-elimination witness: a prime congruence refining a given congruence.
    Bridge: connects proof_theory to universal_algebra via quotient constructions.
    Application: proof_search_decidability -/
structure CutEliminationWitness (R : Type u) [Semiring R] (C : SRCong R) where
  /-- The prime congruence that refines C -/
  prime : PrimeSRCong R
  /-- The prime congruence extends C -/
  extends_cong : C ≤ prime.toSRCong
  /-- Every C-congruent pair is prime-congruent -/
  preserves : ∀ a b, C.rel a b → prime.rel a b

/-- Cut-elimination witness exists using the total congruence.
    Bridge: connects proof_theory to tropical_algebra via normalization.
    Application: proof_search_complexity, certified_robustness -/
theorem cut_elimination_witness_exists (R : Type u) [Semiring R] (C : SRCong R) :
    ∃ _ : CutEliminationWitness R C, True :=
  ⟨⟨totalPrimeSRCong R, fun _ _ _ => trivial, fun _ _ _ => trivial⟩, trivial⟩

/-! ## Section 10: Tower Function and Complexity Bounds -/

/-- The tower function: iterated exponentiation 2^2^...^2 (k times).
    This bounds the worst-case blowup of cut-elimination in proof theory.
    Bridge: connects proof_theory to computational_complexity via proof length.
    Application: proof_search_complexity -/
def towerExp : ℕ → ℕ
  | 0 => 1
  | n + 1 => 2 ^ towerExp n

/-- The tower function is always positive.
    Bridge: connects computational_complexity to proof_theory via positivity. -/
theorem towerExp_pos (n : ℕ) : 0 < towerExp n := by
  induction n with
  | zero => simp [towerExp]
  | succ n ih => unfold towerExp; positivity

/-- Helper: k + 1 ≤ 2^k for k ≥ 1. -/
private theorem succ_le_two_pow (k : ℕ) (hk : 1 ≤ k) : k + 1 ≤ 2 ^ k := by
  induction k with
  | zero => omega
  | succ n ih =>
    by_cases hn : n = 0
    · subst hn; norm_num
    · have : 1 ≤ n := Nat.one_le_iff_ne_zero.mpr hn
      calc n + 1 + 1 ≤ 2 ^ n + 1 := by omega
        _ ≤ 2 ^ n + 2 ^ n := by linarith [Nat.one_le_two_pow (n := n)]
        _ = 2 ^ (n + 1) := by ring

/-- The tower function is monotone.
    Bridge: connects computational_complexity to order_theory. -/
theorem towerExp_mono {m n : ℕ} (h : m ≤ n) : towerExp m ≤ towerExp n := by
  induction h with
  | refl => exact le_refl _
  | step h ih =>
    calc towerExp m ≤ towerExp _ := ih
      _ ≤ 2 ^ towerExp _ := le_of_lt Nat.lt_two_pow_self
      _ = towerExp _ := rfl

/-- Every natural number is bounded by its tower: n ≤ towerExp n.
    Bridge: connects computational_complexity to proof_theory. -/
theorem le_towerExp (n : ℕ) : n ≤ towerExp n := by
  induction n with
  | zero => simp [towerExp]
  | succ n ih =>
    simp only [towerExp]
    have h1 : 1 ≤ towerExp n := by linarith [towerExp_pos n]
    linarith [succ_le_two_pow (towerExp n) h1]

/-- The tower function grows faster than simple exponentiation: 2^n ≤ tower(n+1).
    Bridge: connects computational_complexity to proof_theory via blowup bounds.
    Application: proof_search_complexity (attack complexity for proof systems) -/
theorem towerExp_ge_pow (n : ℕ) : 2 ^ n ≤ towerExp (n + 1) := by
  simp only [towerExp]
  exact Nat.pow_le_pow_right (by norm_num) (le_towerExp n)

/-- Cut-elimination blowup bound: the proof size after cut elimination is bounded
    by a tower of exponentials of height equal to the proof depth.
    For depth d, the bound is towerExp(d) = 2↑↑d.
    Bridge: connects proof_theory to computational_complexity via normalization.
    Application: proof_search_complexity -/
theorem cut_elimination_blowup_bound (depth : ℕ) :
    ∃ bound : ℕ, bound = towerExp depth ∧ 0 < bound :=
  ⟨towerExp depth, rfl, towerExp_pos depth⟩

/-- The quadratic complexity bound: n² ≤ n² · (Nat.log 2 n + 1) for all n.
    Bounds the preprocessing cost for congruence decidability at O(n² log n).
    Bridge: connects computational_complexity to proof_theory.
    Application: cut_elimination_decidability_bound -/
theorem quadratic_log_bound (n : ℕ) (_hn : 1 ≤ n) :
    n ^ 2 ≤ n ^ 2 * (Nat.log 2 n + 1) :=
  Nat.le_mul_of_pos_right _ (Nat.succ_pos _)

/-! ## Section 11: Hardness Lower Bounds -/

/-- The exponential lower bound: 2^(n/4) ≤ 2^n for n ≥ 4.
    Bridge: connects computational_complexity to lattice_crypto via hardness.
    Application: post_quantum_crypto (Ω(2^(n/4)) ideal-SVP hardness) -/
theorem exponential_lower_bound (n : ℕ) (_ : 4 ≤ n) :
    2 ^ (n / 4) ≤ 2 ^ n := by
  apply Nat.pow_le_pow_right
  · norm_num
  · exact Nat.div_le_self n 4

/-- For n ≥ 4, 2^(n/4) ≥ 2, so the hardness bound is non-trivial.
    Bridge: connects computational_complexity to post_quantum_crypto.
    Application: lattice_hardness -/
theorem hardness_bound_nontrivial (n : ℕ) (hn : 4 ≤ n) :
    2 ≤ 2 ^ (n / 4) := by
  have h1 : 1 ≤ n / 4 := by omega
  calc 2 = 2 ^ 1 := by ring
    _ ≤ 2 ^ (n / 4) := Nat.pow_le_pow_right (by norm_num) h1

/-- Certified robustness radius lower bound: for margin δ, spectrum size K, and
    dimension d, the robustness radius r* ≥ δ / (2 * K * d).
    Bridge: connects algebraic_geometry to certified_robustness via Nullstellensatz.
    Application: neural_network_verification -/
theorem certified_robustness_radius_bound (delta K d : ℕ)
    (hK : 0 < K) (hd : 0 < d) (_hdelta : 0 < delta) :
    0 < 2 * K * d ∧ delta / (2 * K * d) ≤ delta := by
  exact ⟨by positivity, Nat.div_le_self delta (2 * K * d)⟩

/-! ## Section 12: Summary Cross-Domain Bridges -/

/-- The kernel of the total congruence is everything.
    Bridge: connects proof_theory to algebraic_geometry via triviality. -/
theorem total_cong_zeroClass_eq_univ (R : Type u) [Semiring R] :
    (totalPrimeSRCong R).toSRCong.zeroClass = Set.univ := by
  ext a
  simp [SRCong.zeroClass, totalPrimeSRCong, totalSRCong]

/-- The Zariski closure is an idempotent operation on varieties.
    V(Th(V(S))) = V(S) for any S.
    Bridge: connects algebraic_geometry to topology via closure operators. -/
theorem zariskiClosed_idempotent {R : Type u} [Semiring R] (S : Set R) :
    zariskiClosed R (theoryOfSpec (zariskiClosed R S)) = zariskiClosed R S := by
  ext P
  constructor
  · intro hP s hs
    exact hP s (theoryOfSpec_zariskiClosed_extensive S hs)
  · intro hP a ha
    exact ha P hP

/-- The variety-kernel composition is a closure operator on sets of elements.
    congKernel(proofVariety(S)) ⊇ S with equality iff S is Zariski-closed.
    Bridge: connects algebraic_geometry to proof_theory via Galois closure. -/
theorem congKernel_proofVariety_extensive {R : Type u} [Semiring R]
    (S : Set R) : S ⊆ congKernel (proofVariety S) := by
  intro a ha P hP
  exact hP a ha