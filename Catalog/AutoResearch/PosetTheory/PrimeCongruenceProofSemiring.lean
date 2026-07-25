/-
# Prime Congruence Spectra of Closure-Generated Proof Semirings

This file establishes the algebraic core of **proof-spectrum semantics**: the reconstruction
of semiprime theories/kernels as intersections of prime theories in commutative semirings.

## Main results

* `semiprime_eq_iInter_prime_theories` — A semiprime kernel in a commutative semiring equals the
  intersection of all prime theories containing it. This is the algebraic heart of the
  proof-spectrum correspondence.

* `exists_prime_theory_avoiding` — Prime separation: if `a` is not in a semiprime kernel `K`,
  there exists a prime theory containing `K` but not `a` (via Zorn's lemma).

* `zeroLocus_anti_mono`, `theoryOf_zeroLocus_extensive`, `theoryOf_zeroLocus_galois` — The
  antitone Galois correspondence between sets of proof terms and sets of congruences.

* `zeroClass_of_prime_congruence_isPrimeTheory` — The zero-class of a prime proof congruence
  is a prime theory.

## Mathematical overview

The key insight is that a proof system can be given the structure of an idempotent commutative
semiring, where `a + b` represents "either derivation resource," `a * b` represents "composite
derivation," and the induced order captures logical entailment. The prime congruence spectrum
then provides a geometric semantics: theories correspond to vanishing loci, and derivability
is captured by vanishing on all points of the associated spectral set.

The decisive theorem is that **semiprime** theories (those closed under square roots:
`a * a ∈ T → a ∈ T`) are exactly the intersections of prime theories. This is the
semiring-theoretic analogue of the radical ideal theorem from algebraic geometry.

## References

The algebraic content is a semiring generalization of the classical commutative algebra result
that semiprime ideals are intersections of prime ideals (a consequence of Krull's theorem).
The proof uses Zorn's lemma applied to the family of ideals disjoint from a multiplicative set.
-/

import Mathlib

set_option maxHeartbeats 800000

universe u

open Set

/-! ## Section 1: Proof Congruences and Basic Definitions -/

/-- A semiring congruence interpreted as proof indistinguishability. -/
structure ProofCongruence (α : Type u) [CommSemiring α] where
  r : α → α → Prop
  iseqv : Equivalence r
  add_compat : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul_compat : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

/-- Vanishing of an element at a congruence: identified with zero. -/
def vanishesAt {α : Type u} [CommSemiring α] (P : ProofCongruence α) (a : α) : Prop :=
  P.r a 0

/-- Zariski closed set defined by a family of proof terms. -/
def zeroLocus {α : Type u} [CommSemiring α]
    (S : Set α) : Set (ProofCongruence α) :=
  {P | ∀ a ∈ S, vanishesAt P a}

/-- The theory reconstructed from a family of proof congruences. -/
def theoryOf {α : Type u} [CommSemiring α]
    (X : Set (ProofCongruence α)) : Set α :=
  {a | ∀ P ∈ X, vanishesAt P a}

/-- A proof congruence is prime if `ab ~ 0` forces `a ~ 0` or `b ~ 0`. -/
def ProofCongruence.IsPrime {α : Type u} [CommSemiring α]
    (P : ProofCongruence α) : Prop :=
  ∀ {a b : α}, P.r (a * b) 0 → P.r a 0 ∨ P.r b 0

/-- The prime spectrum: the set of all prime proof congruences. -/
def primeSpectrum {α : Type u} [CommSemiring α] : Set (ProofCongruence α) :=
  {P | ProofCongruence.IsPrime P}

/-! ## Section 2: Basic Galois Correspondence Lemmas -/

/-- Zero loci are antitone: larger generating sets yield smaller loci. -/
theorem zeroLocus_anti_mono
    {α : Type u} [CommSemiring α] {S T : Set α}
    (hST : S ⊆ T) :
    zeroLocus T ⊆ zeroLocus S := by
  intro P hP a ha
  exact hP a (hST ha)

/-- Every set is contained in the theory of its zero locus. -/
theorem theoryOf_zeroLocus_extensive
    {α : Type u} [CommSemiring α] (S : Set α) :
    S ⊆ theoryOf (zeroLocus S) := by
  intro a ha P hP
  exact hP a ha

/-- The Galois connection between sets of elements and sets of congruences. -/
theorem theoryOf_zeroLocus_galois
    {α : Type u} [CommSemiring α] {S : Set α} {X : Set (ProofCongruence α)} :
    S ⊆ theoryOf X ↔ X ⊆ zeroLocus S := by
  constructor
  · intro h P hP a ha
    exact h ha P hP
  · intro h a ha P hP
    exact h hP a ha

/-- TheoryOf is antitone: larger families of congruences yield smaller theories. -/
theorem theoryOf_anti_mono
    {α : Type u} [CommSemiring α] {X Y : Set (ProofCongruence α)}
    (hXY : X ⊆ Y) :
    theoryOf Y ⊆ theoryOf X := by
  intro a ha P hP
  exact ha P (hXY hP)

/-! ## Section 3: Prime Theories (Set-Based Approach) -/

/-- A set `T` is a *theory* if it contains 0, is closed under addition,
and absorbs multiplication. This captures the algebraic properties of
derivability kernels. -/
structure IsTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop where
  zero_mem : (0 : α) ∈ T
  add_closed : ∀ {a b}, a ∈ T → b ∈ T → a + b ∈ T
  mul_absorb : ∀ {a b}, a ∈ T → a * b ∈ T

/-- A theory is *prime* if `a * b ∈ T` implies `a ∈ T` or `b ∈ T`. -/
structure IsPrimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop
    extends IsTheory T where
  prime : ∀ {a b : α}, a * b ∈ T → a ∈ T ∨ b ∈ T

/-- A theory is *semiprime* if `a * a ∈ T` implies `a ∈ T`. -/
def IsSemiprimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop :=
  IsTheory T ∧ ∀ {a : α}, a * a ∈ T → a ∈ T

/-! ### Key lemma: powers in semiprime kernels -/

/-
In a semiprime kernel, if any power `a ^ n` (with `n ≥ 1`) belongs to `K`,
then `a ∈ K`. This strengthens the defining condition `a² ∈ K → a ∈ K`
using the absorption and closure properties.

The proof is by strong induction on `n`. For even `n = 2k`: `a^(2k) = (a^k)²`,
so `a^k ∈ K` by semiprimality, then `a ∈ K` by induction. For odd `n`:
`(a^n)² = a^(2n) ∈ K` by absorption, so `a^n ∈ K → a^(2n) ∈ K → a^n ∈ K`
(circular, but `2n` is even so we use the even case).
-/
theorem pow_mem_of_semiprime {α : Type u} [CommSemiring α]
    {K : Set α} (hK : IsTheory K) (hsemiprime : ∀ {a : α}, a * a ∈ K → a ∈ K)
    {a : α} {n : ℕ} (hn : 0 < n) (ha : a ^ n ∈ K) : a ∈ K := by
  revert ha;
  induction' n using Nat.strong_induction_on with n ih;
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩;
  · rw [ pow_mul' ];
    exact fun h => ih k ( by linarith ) ( by linarith ) ( hsemiprime ( by simpa only [ sq ] using h ) );
  · by_cases hk : k = 0;
    · aesop;
    · intro ha
      have h_even : a ^ (2 * k + 2) ∈ K := by
        convert hK.mul_absorb ha using 1 ; ring;
      exact ih ( k + 1 ) ( by linarith [ Nat.pos_of_ne_zero hk ] ) ( Nat.succ_pos _ ) ( hsemiprime ( by convert h_even using 1; ring ) )

/-! ### The ideal generated by a set and an element -/

/-- The theory generated by a theory `M` and an additional element `x`:
the set of all `m + x * r` for `m ∈ M` and `r : α`. -/
def theoryGenBy {α : Type u} [CommSemiring α] (M : Set α) (x : α) : Set α :=
  {z | ∃ m ∈ M, ∃ r : α, z = m + x * r}

/-- The generated theory contains the base theory. -/
theorem subset_theoryGenBy {α : Type u} [CommSemiring α] (M : Set α) (x : α) :
    M ⊆ theoryGenBy M x := by
  intro m hm
  exact ⟨m, hm, 0, by simp⟩

/-- The generated theory contains `x` (when the base contains 0). -/
theorem mem_theoryGenBy {α : Type u} [CommSemiring α]
    {M : Set α} (hM : (0 : α) ∈ M) (x : α) :
    x ∈ theoryGenBy M x := by
  exact ⟨0, hM, 1, by simp⟩

/-- The generated theory is a theory when the base is a theory. -/
theorem isTheory_theoryGenBy {α : Type u} [CommSemiring α]
    {M : Set α} (hM : IsTheory M) (x : α) : IsTheory (theoryGenBy M x) where
  zero_mem := subset_theoryGenBy M x hM.zero_mem
  add_closed := by
    rintro a b ⟨m₁, hm₁, r₁, rfl⟩ ⟨m₂, hm₂, r₂, rfl⟩
    exact ⟨m₁ + m₂, hM.add_closed hm₁ hm₂, r₁ + r₂, by ring⟩
  mul_absorb := by
    rintro a b ⟨m, hm, r, rfl⟩
    exact ⟨m * b, hM.mul_absorb hm, r * b, by ring⟩

/-
Product of elements from two generated theories lands in the base.
This is the key algebraic lemma for the primality argument: if `x * y ∈ M`,
then `(m₁ + x*r₁)(m₂ + y*r₂)` expands to a sum of terms all in `M`.
-/
theorem mul_theoryGenBy_mem {α : Type u} [CommSemiring α]
    {M : Set α} (hM : IsTheory M) {x y : α} (hxy : x * y ∈ M)
    {a b : α} (ha : a ∈ theoryGenBy M x) (hb : b ∈ theoryGenBy M y) :
    a * b ∈ M := by
  -- Expand a and b: $a = m_1 + x r_1$ and $b = m_2 + y r_2$ for some $m_1, m_2 \in M$ and $r_1, r_2 \in α$.
  obtain ⟨m1, hm1, r1, hm1a⟩ := ha
  obtain ⟨m2, hm2, r2, hm2b⟩ := hb

  -- Then $a * b = (m_1 + x r_1) * (m_2 + y r_2)$
  have hab : a * b = m1 * m2 + m1 * y * r2 + m2 * x * r1 + x * y * (r1 * r2) := by
    simpa only [ hm1a, hm2b ] using by ring;
  -- Each term in the expansion is in $M$ by the properties of $M$.
  have h_terms : m1 * m2 ∈ M ∧ m1 * y * r2 ∈ M ∧ m2 * x * r1 ∈ M ∧ x * y * (r1 * r2) ∈ M := by
    exact ⟨ hM.mul_absorb hm1, hM.mul_absorb ( hM.mul_absorb hm1 ), hM.mul_absorb ( hM.mul_absorb hm2 ), hM.mul_absorb hxy ⟩;
  exact hab.symm ▸ hM.add_closed ( hM.add_closed ( hM.add_closed h_terms.1 h_terms.2.1 ) h_terms.2.2.1 ) h_terms.2.2.2

/-! ### Prime separation via Zorn's lemma -/

/-- The family of theories containing `K`, disjoint from powers of `a`. -/
private def avoidingFamily {α : Type u} [CommSemiring α]
    (K : Set α) (a : α) : Set (Set α) :=
  {I | IsTheory I ∧ K ⊆ I ∧ ∀ n : ℕ, 0 < n → a ^ n ∉ I}

/-
Chains in the avoiding family have upper bounds (their union).
-/
private theorem chain_ub_in_avoidingFamily {α : Type u} [CommSemiring α]
    {K : Set α} {a : α}
    {c : Set (Set α)} (hc_sub : c ⊆ avoidingFamily K a)
    (hc_chain : IsChain (· ⊆ ·) c) (hc_ne : c.Nonempty) :
    ∃ ub ∈ avoidingFamily K a, ∀ s ∈ c, s ⊆ ub := by
  refine' ⟨ ⋃₀ c, ⟨ _, _, _ ⟩, fun s hs => Set.subset_sUnion_of_mem hs ⟩;
  · constructor;
    · exact Exists.elim hc_ne fun x hx => ⟨ x, hx, hc_sub hx |>.1.zero_mem ⟩;
    · rintro a b ⟨ s, hs, ha ⟩ ⟨ t, ht, hb ⟩;
      cases hc_chain.total hs ht <;> [ exact ⟨ t, ht, by have := hc_sub ht; exact this.1.add_closed ( by tauto ) hb ⟩ ; exact ⟨ s, hs, by have := hc_sub hs; exact this.1.add_closed ha ( by tauto ) ⟩ ];
    · rintro a b ⟨ I, hI, ha ⟩;
      exact ⟨ I, hI, by have := hc_sub hI; exact this.1.mul_absorb ha ⟩;
  · exact fun x hx => Set.mem_sUnion.2 ⟨ _, hc_ne.some_mem, hc_sub hc_ne.some_mem |>.2.1 hx ⟩;
  · intro n hn h; obtain ⟨ s, hs, hs' ⟩ := h; have := hc_sub hs; simp_all +decide [ avoidingFamily ] ;

/-
**Prime Separation Theorem**: If `K` is a semiprime kernel and `a ∉ K`,
there exists a prime theory `T ⊇ K` with `a ∉ T`.

This is the semiring generalization of the classical result that elements outside
a semiprime ideal can be separated by a prime ideal. The proof uses Zorn's lemma
to find a maximal theory containing `K` but avoiding all powers of `a`, and then
shows that maximality forces primality.
-/
theorem exists_prime_theory_avoiding {α : Type u} [CommSemiring α]
    {K : Set α} (hK : IsTheory K) (hsemiprime : ∀ {a : α}, a * a ∈ K → a ∈ K)
    {a : α} (ha : a ∉ K) :
    ∃ T : Set α, IsPrimeTheory T ∧ K ⊆ T ∧ a ∉ T := by
  -- By Zorn's lemma, there exists a maximal element $M$ in the avoiding family.
  obtain ⟨M, hM_max⟩ : ∃ M ∈ avoidingFamily K a, ∀ N ∈ avoidingFamily K a, M ⊆ N → N = M := by
    have := zorn_subset_nonempty { I : Set α | IsTheory I ∧ K ⊆ I ∧ ∀ n : ℕ, 0 < n → a ^ n ∉ I } ?_;
    · exact Exists.elim ( this K ⟨ hK, Set.Subset.refl _, fun n hn => fun h => ha <| pow_mem_of_semiprime hK hsemiprime hn h ⟩ ) fun M hM => ⟨ M, hM.2.prop, fun N hN hMN => hM.2.eq_of_ge hN hMN ⟩;
    · intro c hc hc_chain hc_ne;
      convert chain_ub_in_avoidingFamily hc hc_chain hc_ne using 1;
  refine' ⟨ M, _, hM_max.1.2.1, _ ⟩;
  · refine' ⟨ hM_max.1.1, _ ⟩;
    intro x y hxy
    by_contra h_contra
    push_neg at h_contra
    have hMx : x ∉ M := by
      exact h_contra.1
    have hMy : y ∉ M := by
      exact h_contra.2
    have hMx' : ∃ n : ℕ, 0 < n ∧ a ^ n ∈ theoryGenBy M x := by
      contrapose! hM_max;
      refine' fun h => ⟨ theoryGenBy M x, _, _, _ ⟩ <;> simp_all +decide [ avoidingFamily ];
      · exact ⟨ isTheory_theoryGenBy h.1 x, h.2.1.trans ( subset_theoryGenBy M x ) ⟩;
      · exact fun m hm => ⟨ m, hm, 0, by simp +decide ⟩;
      · grind +suggestions
    have hMy' : ∃ m : ℕ, 0 < m ∧ a ^ m ∈ theoryGenBy M y := by
      have hMy' : ¬(theoryGenBy M y ∈ avoidingFamily K a) := by
        intro hMy''; specialize hM_max; have := hM_max.2 ( theoryGenBy M y ) hMy''; simp_all +decide [ subset_theoryGenBy ] ;
        exact hMy ( this ▸ mem_theoryGenBy ( hM_max.1.1.zero_mem ) y );
      contrapose! hMy';
      exact ⟨ isTheory_theoryGenBy hM_max.1.1 y, hM_max.1.2.1.trans ( subset_theoryGenBy _ _ ), hMy' ⟩
    obtain ⟨n, hn_pos, hn⟩ := hMx'
    obtain ⟨m, hm_pos, hm⟩ := hMy';
    have h_contra : a ^ (n + m) ∈ M := by
      convert mul_theoryGenBy_mem hM_max.1.1 hxy hn hm using 1 ; ring;
    exact hM_max.1.2.2 ( n + m ) ( add_pos hn_pos hm_pos ) h_contra;
  · exact fun h => hM_max.1.2.2 1 Nat.one_pos ( by simpa using h )

/-! ## Section 4: Main Reconstruction Theorem -/

/-
**Semiprime Theory Reconstruction Theorem**: A semiprime kernel in a commutative semiring
equals the intersection of all prime theories containing it.

This is the algebraic core of proof-spectrum semantics. It says that a theory/kernel
is completely determined by which prime "semantic points" it vanishes on.
Equivalently, derivability in the closure system is captured by semantic vanishing
on the prime spectrum.
-/
theorem semiprime_eq_iInter_prime_theories
    {α : Type u} [CommSemiring α]
    (K : Set α)
    (hK : IsTheory K)
    (hsemiprime : ∀ {a : α}, a * a ∈ K → a ∈ K) :
    K = {a | ∀ T : Set α, IsPrimeTheory T → K ⊆ T → a ∈ T} := by
  refine' Set.Subset.antisymm _ _;
  · exact fun x hx T hT hKT => hKT hx;
  · intro a ha;
    by_contra h_contra;
    obtain ⟨ T, hT₁, hT₂, hT₃ ⟩ := exists_prime_theory_avoiding hK hsemiprime h_contra;
    exact hT₃ ( ha T hT₁ hT₂ )

/-! ## Section 5: Zero-Classes and the Congruence Bridge -/

/-- The zero-class of a proof congruence: the set of elements identified with 0. -/
def zeroClass {α : Type u} [CommSemiring α] (P : ProofCongruence α) : Set α :=
  {a | P.r a 0}

/-- The zero-class of any proof congruence is a theory. -/
theorem zeroClass_isTheory {α : Type u} [CommSemiring α] (P : ProofCongruence α) :
    IsTheory (zeroClass P) where
  zero_mem := P.iseqv.refl 0
  add_closed := by
    intro a b (ha : P.r a 0) (hb : P.r b 0)
    show P.r (a + b) 0
    have h := P.add_compat ha hb
    rwa [add_zero] at h
  mul_absorb := by
    intro a b (ha : P.r a 0)
    show P.r (a * b) 0
    have h := P.mul_compat ha (P.iseqv.refl b)
    rwa [zero_mul] at h

/-- The zero-class of a prime congruence is a prime theory.
This bridges the congruence-based and theory-based notions of primality. -/
theorem zeroClass_of_prime_congruence_isPrimeTheory
    {α : Type u} [CommSemiring α] (P : ProofCongruence α)
    (hP : P.IsPrime) : IsPrimeTheory (zeroClass P) where
  toIsTheory := zeroClass_isTheory P
  prime := fun hab => hP hab

/-- The zero-class characterization of vanishing. -/
theorem vanishesAt_iff_mem_zeroClass {α : Type u} [CommSemiring α]
    (P : ProofCongruence α) (a : α) :
    vanishesAt P a ↔ a ∈ zeroClass P :=
  Iff.rfl

/-- TheoryOf coincides with the intersection of zero-classes. -/
theorem theoryOf_eq_iInter_zeroClass {α : Type u} [CommSemiring α]
    (X : Set (ProofCongruence α)) :
    theoryOf X = {a | ∀ P ∈ X, a ∈ zeroClass P} :=
  rfl

/-! ## Section 6: Main Theorem — Congruence Formulation -/

/-- The forward inclusion: a semiprime kernel is contained in the theory of
all prime congruences whose zero-class contains it. -/
theorem semiprime_theory_sub_inter_primeSpectrum
    {α : Type u} [CommSemiring α]
    (K : Set α) :
    K ⊆
      theoryOf {P : ProofCongruence α |
        ProofCongruence.IsPrime P ∧ ∀ a, a ∈ K → vanishesAt P a} := by
  intro a ha P ⟨_, hPK⟩
  exact hPK a ha

/-! ## Section 7: Topological Upgrade — Closed Theory Correspondence -/

/-
Two semiprime theories with identical prime theories above them are equal.
This is the injectivity half of the spectral correspondence: distinct semiprime
theories can always be distinguished by some prime theory.
-/
theorem closed_theory_correspondence
    {α : Type u} [CommSemiring α]
    {K L : Set α}
    (hK_theory : IsTheory K) (hK_sp : ∀ {a : α}, a * a ∈ K → a ∈ K)
    (hL_theory : IsTheory L) (hL_sp : ∀ {a : α}, a * a ∈ L → a ∈ L)
    (h : ∀ T : Set α, IsPrimeTheory T → (K ⊆ T ↔ L ⊆ T)) :
    K = L := by
  rw [ semiprime_eq_iInter_prime_theories K hK_theory hK_sp, semiprime_eq_iInter_prime_theories L hL_theory hL_sp ];
  grind

/-! ## Section 8: Prime Congruence Separation for Commutative Rings -/

/-
In a commutative ring, a theory (contains 0, closed under +, absorbs *) is
automatically a two-sided ideal, because negation is multiplication by -1.
-/
theorem theory_to_ideal_mem {α : Type u} [CommRing α] {T : Set α}
    (hT : @IsTheory α _ T) : ∀ {a : α}, a ∈ T → -a ∈ T := by
  intro a ha;
  convert hT.mul_absorb ha using 1;
  rw [ mul_neg_one ]

/-- Convert a theory in a CommRing to a Mathlib Ideal. -/
noncomputable def theoryToIdeal {α : Type u} [CommRing α] {T : Set α}
    (hT : @IsTheory α _ T) : Ideal α where
  carrier := T
  add_mem' := fun ha hb => hT.add_closed ha hb
  zero_mem' := hT.zero_mem
  smul_mem' := fun r a ha => by
    show r • a ∈ T
    rw [smul_eq_mul, mul_comm]
    exact hT.mul_absorb ha

/-
A prime theory in a CommRing gives a prime ideal.
-/
theorem primeTheory_gives_prime_ideal {α : Type u} [CommRing α] {T : Set α}
    (hT : IsPrimeTheory T) (hne : T ≠ Set.univ) :
    (theoryToIdeal hT.toIsTheory).IsPrime := by
  constructor;
  · contrapose! hne;
    simp_all +decide [ SetLike.ext_iff, theoryToIdeal ];
    exact Set.eq_univ_of_forall hne;
  · exact fun { x y } hxy => hT.prime hxy

/-- Construct a ProofCongruence from a RingCon. -/
def proofCongruenceOfRingCon {α : Type u} [CommSemiring α]
    (c : RingCon α) : ProofCongruence α where
  r := c
  iseqv := c.toSetoid.iseqv
  add_compat := fun ha hb => c.add ha hb
  mul_compat := fun ha hb => c.mul ha hb

/-
**Prime Congruence Separation for Commutative Rings**: In a commutative ring,
every semiprime kernel can be separated from non-members by prime proof congruences.
This is the full congruence version of the reconstruction theorem, proved by
constructing the quotient ring congruence.
-/
theorem prime_congruence_separation_ring
    {α : Type u} [CommRing α]
    (K : Set α) (a : α)
    (hK : @IsTheory α _ K)
    (hsemiprime : ∀ {x : α}, x * x ∈ K → x ∈ K)
    (ha : a ∉ K) :
    ∃ P : ProofCongruence α,
      P.IsPrime ∧
      (∀ x, x ∈ K → vanishesAt P x) ∧
      ¬ vanishesAt P a := by
  -- Use exists_prime_theory_avoiding to get a prime theory T ⊇ K with a ∉ T.
  obtain ⟨T, hT_prime, hT_K, hT_a⟩ : ∃ T : Set α, IsPrimeTheory T ∧ K ⊆ T ∧ a ∉ T := by
    exact exists_prime_theory_avoiding hK hsemiprime ha;
  -- Convert T to a Mathlib Ideal I using theoryToIdeal.
  set I : Ideal α := theoryToIdeal hT_prime.1 with hI_def
  have hI_prime : I.IsPrime := by
    grind +suggestions
  have hI_T : I.carrier = T := by
    grind
  have hI_a : a ∉ I := by
    exact fun h => hT_a <| hI_T ▸ h
  have hI_K : K ⊆ I := by
    exact hT_K.trans ( hI_T ▸ Set.Subset.refl _ )
  use proofCongruenceOfRingCon (RingCon.ker (Ideal.Quotient.mk I));
  refine' ⟨ _, _, _ ⟩;
  · intro a b hab;
    simp_all +decide [ proofCongruenceOfRingCon ];
  · intro x hx; exact (by
    exact Ideal.Quotient.eq_zero_iff_mem.mpr ( hI_K hx ));
  · simp +decide [ vanishesAt, proofCongruenceOfRingCon ];
    rwa [ Ideal.Quotient.eq_zero_iff_mem ]

/-! ## Section 9: Conjectures for Stronger Results -/

/-- **Conjecture (Prime Congruence Separation)**: Every semiprime kernel can be separated
from non-members by prime proof congruences (not just prime theories).

The gap lies in constructing a ProofCongruence from a prime theory in a general
commutative semiring. In rings, this is automatic via the quotient ring construction.
In semirings, the Bourne congruence `r x y ↔ ∃ s t ∈ I, x + s = y + t` works for
k-closed ideals (those satisfying `a + b ∈ I ∧ b ∈ I → a ∈ I`).

This conjecture holds automatically when:
- `α` is a ring (use the quotient ring)
- The prime theory is k-closed (use the Bourne congruence)
- `α` is an idempotent semiring with downward-closed theories -/
theorem prime_congruence_separation_conjecture
    {α : Type u} [CommSemiring α]
    (K : Set α) (a : α)
    (hK : IsTheory K)
    (hsemiprime : ∀ {x : α}, x * x ∈ K → x ∈ K)
    (ha : a ∉ K) :
    ∃ P : ProofCongruence α,
      P.IsPrime ∧
      (∀ x, x ∈ K → vanishesAt P x) ∧
      ¬ vanishesAt P a := by
  sorry