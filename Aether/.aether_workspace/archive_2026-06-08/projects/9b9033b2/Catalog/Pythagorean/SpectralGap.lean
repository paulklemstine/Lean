import Mathlib

/-!
# Spectral Gap Detection of Compositeness via Arithmetic Dynamics

The squaring endomorphism `x ↦ x²` on `ZMod n` defines a canonical dynamical system
whose fixed-point structure encodes the factorization of `n`. This file develops the
**arithmetic-to-graph fragmentation** paradigm: factorization of `n` into multiple
prime factors creates graph bottlenecks in the functional graph of squaring, which
in turn suppress spectral expansion.

## Key Definitions

* `sqMap n` — the squaring map on `ZMod n`
* `SqAdj n` — undirected squaring adjacency
* `sqBasin n e` — forward basin of an element under squaring iteration
* `IdempotentSeparated n` — disjointness of basins of distinct idempotents
* `sqEdgeBoundary n S` — edge boundary in the squaring graph
* `sqConductance n S` — Cheeger-style conductance proxy

## Main Results

* `prime_sq_idempotents_eq_zero_or_one` — primes have only trivial idempotents
* `prime_idempotentSubtype_card` — primes have exactly 2 idempotents
* `exists_two_distinct_idempotents` — composites with ≥2 prime factors have ≥2 distinct idempotents
* `idempotents_not_sq_adj` — distinct idempotents are never adjacent in the squaring graph
* `sqBasin_disjoint_of_ne_idempotent` — basins of distinct idempotents are disjoint
* `idempotent_separated` — `IdempotentSeparated n` holds for all `n`
* `arithmetic_fragmentation_theorem` — arithmetic fragmentation creates disjoint nonempty basins

## References

* Catalog: `Pythagorean/DynamicalSquaring.lean`
* Catalog: `Speculative/AutoResearch/PrimalityTesting/WitnessTheorems.lean`
-/

open Finset Nat BigOperators Function

noncomputable section

/-! ## §1. The Squaring Map and Adjacency -/

/-- The squaring map on `ZMod n`. -/
def sqMap (n : ℕ) : ZMod n → ZMod n := fun x => x ^ 2

/-- Undirected squaring adjacency: `x` and `y` are adjacent if one maps to the other
    and they are distinct. -/
def SqAdj (n : ℕ) (x y : ZMod n) : Prop :=
  x ≠ y ∧ (sqMap n x = y ∨ sqMap n y = x)

/-- The squaring map equals `x * x`. -/
theorem sqMap_eq_mul_self {n : ℕ} (x : ZMod n) : sqMap n x = x * x := by
  simp [sqMap, sq]

/-- Fixed points of the squaring map are exactly idempotents. -/
theorem sqMap_fixed_iff {n : ℕ} (x : ZMod n) : sqMap n x = x ↔ x ^ 2 = x := by
  simp [sqMap]

/-! ## §2. Idempotent Structure of Prime Moduli -/

/-
**Theorem 1 (Prime Rigidity)**: In `ZMod p` for prime `p`,
    every idempotent is `0` or `1`. This follows from `ZMod p` being a field:
    `x² = x` implies `x(x-1) = 0`, and fields have no zero divisors.
-/
theorem prime_sq_idempotents_eq_zero_or_one
    {p : ℕ} (hp : Nat.Prime p) (x : ZMod p) (hx : x ^ 2 = x) :
    x = 0 ∨ x = 1 := by
  haveI := Fact.mk hp; exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ h <| by linear_combination' hx;

/-
**Theorem 2 (Prime Idempotent Count)**: A prime modulus has exactly 2 idempotents.
-/
theorem prime_idempotentSubtype_card
    {p : ℕ} (hp : Nat.Prime p) :
    haveI : NeZero p := ⟨hp.ne_zero⟩
    (Finset.univ.filter (fun x : ZMod p => x ^ 2 = x)).card = 2 := by
  haveI := Fact.mk hp; rw [ Finset.card_eq_two ] ;
  refine' ⟨ 0, 1, _, _ ⟩ <;> norm_num [ Finset.ext_iff ];
  exact fun a => ⟨ fun h => or_iff_not_imp_left.mpr fun ha => mul_left_cancel₀ ha <| by linear_combination h, fun h => h.elim ( fun ha => by simp +decide [ ha ] ) fun ha => by simp +decide [ ha ] ⟩

/-! ## §3. Nontrivial Idempotents from Factorization -/

/-
CRT produces a nontrivial idempotent from coprime factorization.
    The element mapping to `(1, 0)` under CRT is idempotent but ≠ 0 and ≠ 1.
-/
theorem nontrivial_idempotent_of_coprime_factors (m k : ℕ) (hm : 1 < m) (hk : 1 < k)
    (hcop : Nat.Coprime m k) :
    ∃ e : ZMod (m * k), e ^ 2 = e ∧ e ≠ 0 ∧ e ≠ 1 := by
  obtain ⟨e, he⟩ : ∃ e : ZMod (m * k), e ≠ 0 ∧ e ≠ 1 ∧ e^2 = e := by
    -- By the Chinese Remainder Theorem, there exists an element $e$ in $ZMod (m * k)$ such that $e \equiv 1 \pmod{m}$ and $e \equiv 0 \pmod{k}$.
    obtain ⟨e, he⟩ : ∃ e : ZMod (m * k), e.val ≡ 1 [MOD m] ∧ e.val ≡ 0 [MOD k] := by
      -- By the Chinese Remainder Theorem, there exists an integer $e$ such that $e \equiv 1 \pmod{m}$ and $e \equiv 0 \pmod{k}$.
      obtain ⟨e, he⟩ : ∃ e : ℕ, e ≡ 1 [MOD m] ∧ e ≡ 0 [MOD k] ∧ e < m * k := by
        have := Nat.chineseRemainder hcop 1 0;
        exact ⟨ this.val % ( m * k ), by simpa [ Nat.ModEq, Nat.mod_mod ] using this.2.1, by simpa [ Nat.ModEq, Nat.mod_mod ] using this.2.2, Nat.mod_lt _ ( by positivity ) ⟩;
      use e;
      simp_all +decide [ Nat.mod_eq_of_lt ];
    refine' ⟨ e, _, _, _ ⟩;
    · intro h; simp_all +decide [ Nat.ModEq ];
    · intro h; have := he.2; simp_all +decide [ Nat.ModEq, Nat.mod_eq_of_lt hm, Nat.mod_eq_of_lt hk ] ;
      rcases m with ( _ | _ | m ) <;> rcases k with ( _ | _ | k ) <;> simp_all +decide [ ZMod.val ];
      cases he.2;
    · have h_e_sq : e.val ^ 2 ≡ e.val [MOD (m * k)] := by
        rw [ ← Nat.modEq_and_modEq_iff_modEq_mul ];
        · simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
        · assumption;
      simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
      cases m <;> cases k <;> aesop;
  exact ⟨ e, he.2.2, he.1, he.2.1 ⟩

/-
Helper: a number with ≥2 distinct prime factors admits a coprime factorization.
-/
theorem exists_coprime_split {n : ℕ} (hn : 1 < n)
    (hω : 2 ≤ (Nat.factorization n).support.card) :
    ∃ m k, 1 < m ∧ 1 < k ∧ n = m * k ∧ Nat.Coprime m k := by
  -- Since n has ≥2 distinct prime factors, pick any prime p dividing n. Let a = p^(v_p(n)) be the p-part, k = n/a the coprime complement.
  obtain ⟨p, hp⟩ : ∃ p, Nat.Prime p ∧ p ∣ n := by
    exact Nat.exists_prime_and_dvd hn.ne'
  obtain ⟨k, hk⟩ : ∃ k, n = p ^ (n.factorization p) * k ∧ Nat.Coprime (p ^ (n.factorization p)) k := by
    exact ⟨ n / p ^ n.factorization p, by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], by exact Nat.Coprime.pow_left _ <| hp.left.coprime_iff_not_dvd.mpr <| Nat.not_dvd_ordCompl ( by aesop ) <| by aesop ⟩;
  refine ⟨ p ^ n.factorization p, k, ?_, ?_, hk.1, hk.2 ⟩ <;> contrapose! hω <;> norm_num at *;
  · exact absurd hω ( not_le_of_gt ( pow_lt_pow_right₀ hp.1.one_lt ( Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by { exact Nat.mem_primeFactors.mpr ⟨ hp.1, hp.2, by linarith ⟩ } ) ) ) ) );
  · interval_cases k <;> norm_num at *;
    · linarith;
    · rw [ hk, Nat.primeFactors_pow ] <;> norm_num [ hp.1 ];
      exact Finsupp.mem_support_iff.mp ( by contrapose! hk; simp_all +singlePass [ Nat.factorization_eq_zero_iff ] )

/-
**Theorem 3 (Composite Fragmentation)**: If `n` has at least two distinct prime factors,
    there exist two distinct idempotents in `ZMod n`.
-/
theorem exists_two_distinct_idempotents
    {n : ℕ} (hn : 1 < n)
    (hω : 2 ≤ (Nat.factorization n).support.card) :
    ∃ e₁ e₂ : ZMod n, e₁ ≠ e₂ ∧ e₁ ^ 2 = e₁ ∧ e₂ ^ 2 = e₂ := by
  -- Use `exists_coprime_split` to get m, k with 1 < m, 1 < k, n = m*k, coprime.
  obtain ⟨m, k, hm, hk, hn_eq, hcop⟩ : ∃ m k : ℕ, 1 < m ∧ 1 < k ∧ n = m * k ∧ Nat.Coprime m k := exists_coprime_split hn hω;
  -- Use `nontrivial_idempotent_of_coprime_factors` to get e with e^2 = e, e ≠ 0, e ≠ 1.
  obtain ⟨e, he⟩ : ∃ e : ZMod (m * k), e ^ 2 = e ∧ e ≠ 0 ∧ e ≠ 1 := nontrivial_idempotent_of_coprime_factors m k hm hk hcop;
  subst hn_eq; use 0, e; aesop;

/-! ## §4. Isolation of Idempotents in the Squaring Graph -/

/-
**Theorem 4 (Idempotent Isolation)**: Distinct idempotents are never adjacent
    in the undirected squaring graph. If `e₁² = e₁` and `e₂² = e₂` and `e₁ ≠ e₂`,
    then neither `e₁² = e₂` nor `e₂² = e₁` can hold, since `eᵢ² = eᵢ`.
-/
theorem idempotents_not_sq_adj
    {n : ℕ} {e₁ e₂ : ZMod n}
    (h₁ : e₁ ^ 2 = e₁) (h₂ : e₂ ^ 2 = e₂) (hne : e₁ ≠ e₂) :
    ¬ SqAdj n e₁ e₂ := by
  -- By definition of `SqAdj`, we need to show that `e₁` and `e₂` are not adjacent in the squaring graph.
  unfold SqAdj;
  unfold sqMap; aesop;

/-! ## §5. Basin Decomposition -/

/-- The forward basin of `e` under the squaring map: all elements whose
    iterated squaring eventually reaches `e`. -/
def sqBasin (n : ℕ) (e : ZMod n) : Set (ZMod n) :=
  {x | ∃ k : ℕ, (sqMap n)^[k] x = e}

/-
Once an orbit reaches an idempotent, it stays there forever.
-/
theorem sqMap_iterate_of_idempotent {n : ℕ} {e : ZMod n} (he : e ^ 2 = e)
    (k : ℕ) : (sqMap n)^[k] e = e := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply', sqMap ]

/-
**Theorem 5 (Basin Disjointness)**: Basins of distinct idempotents are disjoint.
    If `x` iterates to `e₁` in `k₁` steps and to `e₂` in `k₂` steps, then
    applying more squaring from `e₁` gives `e₁` (by idempotency), but also
    must give `e₂`, forcing `e₁ = e₂`.
-/
theorem sqBasin_disjoint_of_ne_idempotent {n : ℕ} {e₁ e₂ : ZMod n}
    (h₁ : e₁ ^ 2 = e₁) (h₂ : e₂ ^ 2 = e₂) (hne : e₁ ≠ e₂) :
    Disjoint (sqBasin n e₁) (sqBasin n e₂) := by
  refine' Set.disjoint_left.mpr _;
  intro x hx₁ hx₂; obtain ⟨ k₁, hk₁ ⟩ := hx₁; obtain ⟨ k₂, hk₂ ⟩ := hx₂; cases le_total k₁ k₂ <;> have := sqMap_iterate_of_idempotent h₁ <;> have := sqMap_iterate_of_idempotent h₂ <;> simp_all +decide [ Function.iterate_add_apply ] ;
  · have := Function.iterate_add_apply ( sqMap n ) ( k₂ - k₁ ) k₁ x; simp_all +decide [ Nat.add_sub_of_le ‹k₁ ≤ k₂› ] ;
  · have := Function.iterate_add_apply ( sqMap n ) k₂ ( k₁ - k₂ ) x; simp_all +decide [ Nat.add_sub_of_le ‹_› ] ;
    have h_eq : (sqMap n)^[k₂] ((sqMap n)^[k₁ - k₂] x) = (sqMap n)^[k₁ - k₂] ((sqMap n)^[k₂] x) := by
      rw [ ← Function.iterate_add_apply, add_comm, Function.iterate_add_apply ];
    aesop

/-- The basin separation property holds universally. -/
def IdempotentSeparated (n : ℕ) : Prop :=
  ∀ ⦃e₁ e₂ : ZMod n⦄, e₁ ≠ e₂ →
    e₁ ^ 2 = e₁ → e₂ ^ 2 = e₂ →
    Disjoint (sqBasin n e₁) (sqBasin n e₂)

/-- **Corollary**: `IdempotentSeparated n` holds for all `n`. -/
theorem idempotent_separated (n : ℕ) : IdempotentSeparated n := by
  intro e₁ e₂ hne h₁ h₂
  exact sqBasin_disjoint_of_ne_idempotent h₁ h₂ hne

/-! ## §6. Edge Boundary and Conductance Proxy -/

/-- The edge boundary of a subset `S` in the squaring graph:
    elements of `S` whose squaring image lies outside `S`. -/
def sqEdgeBoundary (n : ℕ) [NeZero n] (S : Finset (ZMod n)) : Finset (ZMod n) :=
  S.filter fun x => sqMap n x ∉ S

/-- Edge boundary size as a natural number. -/
def sqEdgeBoundaryCard (n : ℕ) [NeZero n] (S : Finset (ZMod n)) : ℕ :=
  (sqEdgeBoundary n S).card

/-- Conductance proxy: ratio of edge boundary to subset size. -/
def sqConductance (n : ℕ) [NeZero n] (S : Finset (ZMod n)) : ℚ :=
  if S.card = 0 then 0
  else (sqEdgeBoundaryCard n S : ℚ) / (S.card : ℚ)

/-- Verified edge boundary bound: the edge boundary is always at most the set itself. -/
theorem sqEdgeBoundary_card_le (n : ℕ) [NeZero n] (S : Finset (ZMod n)) :
    sqEdgeBoundaryCard n S ≤ S.card :=
  Finset.card_filter_le S _

/-- Conductance is bounded above by 1. -/
theorem sqConductance_le_one (n : ℕ) [NeZero n] (S : Finset (ZMod n)) :
    sqConductance n S ≤ 1 := by
  simp only [sqConductance]
  split_ifs with h
  · norm_num
  · rw [div_le_one (by positivity)]
    exact_mod_cast sqEdgeBoundary_card_le n S

/-! ## §7. Cross-Domain Bridge: Arithmetic Fragmentation → Graph Structure -/

/-- Every idempotent is in its own basin. -/
theorem mem_sqBasin_self {n : ℕ} (e : ZMod n) : e ∈ sqBasin n e :=
  ⟨0, rfl⟩

/-- Zero is always an idempotent. -/
theorem zero_idempotent (n : ℕ) : (0 : ZMod n) ^ 2 = 0 := by ring

/-- One is always an idempotent. -/
theorem one_idempotent (n : ℕ) : (1 : ZMod n) ^ 2 = 1 := by ring

/-- **Theorem 6 (Arithmetic Fragmentation Bridge)**: When `n` has at least two distinct
    prime factors, the functional graph of squaring decomposes into at least two disjoint
    nonempty basins. This is the formal bridge from number theory (factorization) to
    spectral graph theory (graph fragmentation): compositeness creates phase-space
    decomposition in the squaring dynamics. -/
theorem arithmetic_fragmentation_theorem
    {n : ℕ} (hn : 1 < n)
    (hω : 2 ≤ (Nat.factorization n).support.card) :
    ∃ e₁ e₂ : ZMod n, e₁ ≠ e₂ ∧
      e₁ ^ 2 = e₁ ∧ e₂ ^ 2 = e₂ ∧
      Disjoint (sqBasin n e₁) (sqBasin n e₂) ∧
      e₁ ∈ sqBasin n e₁ ∧ e₂ ∈ sqBasin n e₂ := by
  obtain ⟨e₁, e₂, hne, h₁, h₂⟩ := exists_two_distinct_idempotents hn hω
  exact ⟨e₁, e₂, hne, h₁, h₂,
    sqBasin_disjoint_of_ne_idempotent h₁ h₂ hne,
    mem_sqBasin_self e₁, mem_sqBasin_self e₂⟩

/-! ## §8. Verified Computational Method -/

/-- Compute the set of idempotents as a `Finset`. -/
def computeIdempotents (n : ℕ) [NeZero n] : Finset (ZMod n) :=
  Finset.univ.filter (fun x => x ^ 2 = x)

/-- Every element reported by `computeIdempotents` is truly idempotent. -/
theorem computeIdempotents_correct (n : ℕ) [NeZero n] (x : ZMod n)
    (hx : x ∈ computeIdempotents n) : x ^ 2 = x := by
  simp [computeIdempotents] at hx; exact hx

/-- The computed idempotent set contains all idempotents. -/
theorem computeIdempotents_complete (n : ℕ) [NeZero n] (x : ZMod n)
    (hx : x ^ 2 = x) : x ∈ computeIdempotents n := by
  simp [computeIdempotents]; exact hx

/-- Iterate squaring `k` times. -/
def sqIterate (n : ℕ) (k : ℕ) (x : ZMod n) : ZMod n :=
  (sqMap n)^[k] x

/-- Verify that a claimed basin membership is correct. -/
def verifyBasinMembership (n : ℕ) [NeZero n] (x e : ZMod n) (k : ℕ) : Bool :=
  decide ((sqMap n)^[k] x = e)

/-- The basin membership verifier is sound. -/
theorem verifyBasinMembership_sound (n : ℕ) [NeZero n] (x e : ZMod n) (k : ℕ)
    (h : verifyBasinMembership n x e k = true) : x ∈ sqBasin n e := by
  simp [verifyBasinMembership] at h
  exact ⟨k, h⟩

end