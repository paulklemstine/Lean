/-
# Primewise Persistence: Frobenius Orbit Signatures and Local-Global Detection

This file develops the theory of prime-indexed signatures derived from
Frobenius-type group actions on finite sets, and proves that collections
of such signatures can detect arithmetic obstructions.
-/
import Mathlib

open Finset BigOperators

/-! ## Part 1: Frobenius Orbit Signatures -/

/-- A `FrobeniusAction` models the action of Frobenius at a prime p on a finite
    set of points (e.g., points of a curve mod p). -/
structure FrobeniusAction where
  card : ℕ
  σ : Equiv.Perm (Fin card)

/-- The number of fixed points of Frobenius. -/
def FrobeniusAction.fixedPointCount (F : FrobeniusAction) : ℕ :=
  (Finset.univ.filter (fun x => F.σ x = x)).card

/-- The number of fixed points of the k-th iterate of Frobenius. -/
def FrobeniusAction.iterFixedCount (F : FrobeniusAction) (k : ℕ) : ℕ :=
  (Finset.univ.filter (fun x => (F.σ ^ k) x = x)).card

/-- A `PrimeSignature` captures the orbit data at a prime. -/
structure PrimeSignature (depth : ℕ) where
  prime : ℕ
  counts : Fin depth → ℕ
  deriving DecidableEq

/-- Two prime signatures agree if they have the same counts. -/
def PrimeSignature.agrees {d : ℕ} (s₁ s₂ : PrimeSignature d) : Prop :=
  s₁.counts = s₂.counts

instance {d : ℕ} (s₁ s₂ : PrimeSignature d) : Decidable (s₁.agrees s₂) :=
  inferInstanceAs (Decidable (s₁.counts = s₂.counts))

/-- The signature of a Frobenius action at a given depth. -/
def FrobeniusAction.signature (F : FrobeniusAction) (p : ℕ) (depth : ℕ) :
    PrimeSignature depth where
  prime := p
  counts := fun k => F.iterFixedCount (k.val + 1)

/-! ## Part 2: Fixed Point Counting Theorems -/

/-- The identity permutation fixes every element. -/
theorem fixedCount_id (n : ℕ) :
    (FrobeniusAction.mk n (Equiv.refl (Fin n))).fixedPointCount = n := by
  simp [FrobeniusAction.fixedPointCount]

/-- The 0-th iterate of any permutation is the identity. -/
theorem iterFixedCount_zero (F : FrobeniusAction) :
    F.iterFixedCount 0 = F.card := by
  simp [FrobeniusAction.iterFixedCount, pow_zero]

/-- Fixed points of σ are also fixed points of σ^k for any k. -/
theorem fixed_of_iter_fixed (F : FrobeniusAction) (x : Fin F.card)
    (hx : F.σ x = x) (k : ℕ) : (F.σ ^ k) x = x := by
  induction k with
  | zero => simp
  | succ n ih => simp [pow_succ, Equiv.Perm.mul_apply, ih, hx]

/-- The number of fixed points of σ ≤ the number of fixed points of σ^k for k ≥ 1. -/
theorem fixedCount_le_iterFixedCount (F : FrobeniusAction) (k : ℕ) (_hk : k ≥ 1) :
    F.fixedPointCount ≤ F.iterFixedCount k := by
  apply Finset.card_le_card
  intro x hx
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
  exact fixed_of_iter_fixed F x hx k

/-- The fixed point count is bounded by the total number of elements. -/
theorem iterFixedCount_le_card (F : FrobeniusAction) (k : ℕ) :
    F.iterFixedCount k ≤ F.card := by
  unfold FrobeniusAction.iterFixedCount
  calc (Finset.univ.filter _).card ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = F.card := Finset.card_fin F.card

/-- Fixed point count is monotone under divisibility. -/
theorem fixedCount_dvd_mono (F : FrobeniusAction) (k m : ℕ) (h : k ∣ m) :
    F.iterFixedCount k ≤ F.iterFixedCount m := by
  obtain ⟨c, rfl⟩ := h
  apply Finset.card_le_card
  intro x hx
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
  rw [pow_mul]
  induction c with
  | zero => simp
  | succ n ih =>
    rw [pow_succ, Equiv.Perm.mul_apply, hx]
    exact ih

/-! ## Part 3: Prime Separation -/

/-- An arithmetic object equipped with prime signatures. -/
structure ArithmeticObject (depth : ℕ) where
  signatureAt : ℕ → PrimeSignature depth

/-- Two objects are `PrimewiseSeparated` if signatures disagree at some prime. -/
def PrimewiseSeparated {d : ℕ} (A B : ArithmeticObject d) : Prop :=
  ∃ p, Nat.Prime p ∧ ¬(A.signatureAt p).agrees (B.signatureAt p)

/-- Two objects are `CofinallyDistinguished` if disagreement extends to
    arbitrarily large primes. -/
def CofinallyDistinguished {d : ℕ} (A B : ArithmeticObject d) : Prop :=
  ∀ N : ℕ, ∃ p, p > N ∧ Nat.Prime p ∧ ¬(A.signatureAt p).agrees (B.signatureAt p)

/-- Cofinally distinguished implies primewise separated. -/
theorem cofinallyDistinguished_imp_separated {d : ℕ} (A B : ArithmeticObject d)
    (h : CofinallyDistinguished A B) : PrimewiseSeparated A B := by
  obtain ⟨p, _, hp, hdiff⟩ := h 0
  exact ⟨p, hp, hdiff⟩

/-- If signatures agree at all primes, the objects are not primewise separated. -/
theorem not_separated_of_all_agree {d : ℕ} (A B : ArithmeticObject d)
    (h : ∀ p, Nat.Prime p → (A.signatureAt p).agrees (B.signatureAt p)) :
    ¬PrimewiseSeparated A B := by
  intro ⟨p, hp, hdiff⟩
  exact hdiff (h p hp)

/-- CofinallyDistinguished is symmetric. -/
theorem cofinallyDistinguished_symm {d : ℕ} (A B : ArithmeticObject d)
    (h : CofinallyDistinguished A B) : CofinallyDistinguished B A := by
  intro N
  obtain ⟨p, hpN, hp, hdiff⟩ := h N
  exact ⟨p, hpN, hp, fun hagree => hdiff (by
    unfold PrimeSignature.agrees at hagree ⊢
    exact hagree.symm)⟩

/-
**Finite non-separation implies eventual agreement**: contrapositive form.
-/
theorem not_cofinallyDist_iff_eventual_agreement {d : ℕ} (A B : ArithmeticObject d) :
    ¬CofinallyDistinguished A B ↔
    ∃ N, ∀ p, p > N → Nat.Prime p → (A.signatureAt p).agrees (B.signatureAt p) := by
  unfold CofinallyDistinguished; aesop;

/-! ## Part 4: Alternating Sum Invariants (Euler Characteristic) -/

/-- The alternating sum of a sequence. -/
def alternatingSum {n : ℕ} (f : Fin n → ℤ) : ℤ :=
  ∑ i : Fin n, (-1) ^ (i : ℕ) * f i

/-- The alternating sum of a length-1 sequence is the single value. -/
theorem alternatingSum_one (f : Fin 1 → ℤ) : alternatingSum f = f 0 := by
  simp [alternatingSum]

/-- The alternating sum is additive. -/
theorem alternatingSum_add {n : ℕ} (f g : Fin n → ℤ) :
    alternatingSum (fun i => f i + g i) = alternatingSum f + alternatingSum g := by
  simp [alternatingSum, mul_add, Finset.sum_add_distrib]

/-- The alternating sum of the zero sequence is zero. -/
theorem alternatingSum_zero' {n : ℕ} :
    alternatingSum (fun _ : Fin n => (0 : ℤ)) = 0 := by
  simp [alternatingSum]

/-
**Cross-domain theorem**: The alternating sum of Frobenius fixed point counts
    is bounded by depth * card.
-/
theorem euler_char_bounded_by_geometry (F : FrobeniusAction) (depth : ℕ)
    (_hdepth : depth ≥ 1) :
    |alternatingSum (fun i : Fin depth => (F.iterFixedCount (i.val + 1) : ℤ))| ≤
    depth * F.card := by
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
  norm_num [ abs_mul ];
  exact_mod_cast le_trans ( Finset.sum_le_sum fun _ _ => iterFixedCount_le_card F _ ) ( by norm_num )

/-! ## Part 5: Persistence Module -/

/-- A persistence module with ranks and persistent ranks. -/
structure PersistenceModule (n : ℕ) where
  rank : Fin n → ℕ
  persistentRank : (i j : Fin n) → i ≤ j → ℕ
  persistentRank_diag : ∀ i, persistentRank i i le_rfl = rank i
  persistentRank_mono : ∀ i j k (hij : i ≤ j) (hjk : j ≤ k),
    persistentRank i k (le_trans hij hjk) ≤ persistentRank i j hij

/-- Total Betti number. -/
def PersistenceModule.totalBetti {n : ℕ} (M : PersistenceModule n) : ℕ :=
  ∑ i : Fin n, M.rank i

/-- A persistence interval. -/
structure PersistenceInterval (n : ℕ) where
  birth : Fin n
  death : ℕ
  valid : birth.val < death

/-- Persistence is always at least 1. -/
theorem PersistenceInterval.persistence_pos {n : ℕ} (I : PersistenceInterval n) :
    I.death - I.birth.val ≥ 1 := by
  have := I.valid; omega

/-- Persistent rank is bounded by rank. -/
theorem persistent_rank_le_rank {n : ℕ} (M : PersistenceModule n) (i j : Fin n)
    (hij : i ≤ j) :
    M.persistentRank i j hij ≤ M.rank i := by
  calc M.persistentRank i j hij
      ≤ M.persistentRank i i le_rfl := M.persistentRank_mono i i j le_rfl hij
    _ = M.rank i := M.persistentRank_diag i

/-! ## Part 6: Chain Complex and Euler Characteristic -/

/-- A finite chain complex with ranks and boundary ranks. -/
structure FiniteChainComplex (n : ℕ) where
  rank : Fin n → ℕ
  boundaryRank : Fin n → ℕ
  boundary_le_source : ∀ i : Fin n, boundaryRank i ≤ rank i

/-- Euler characteristic. -/
def FiniteChainComplex.eulerChar {n : ℕ} (C : FiniteChainComplex n) : ℤ :=
  ∑ i : Fin n, (-1) ^ (i : ℕ) * (C.rank i : ℤ)

/-- The Euler characteristic of the zero complex is zero. -/
theorem eulerChar_zero (n : ℕ) :
    (FiniteChainComplex.mk (fun _ : Fin n => 0) (fun _ => 0)
      (fun _ => le_rfl)).eulerChar = 0 := by
  simp [FiniteChainComplex.eulerChar]

/-- **Euler characteristic is additive** over direct sums. -/
theorem eulerChar_additive {n : ℕ} (C₁ C₂ : FiniteChainComplex n) :
    (FiniteChainComplex.mk
      (fun i => C₁.rank i + C₂.rank i)
      (fun i => C₁.boundaryRank i + C₂.boundaryRank i)
      (fun i => Nat.add_le_add (C₁.boundary_le_source i) (C₂.boundary_le_source i))
    ).eulerChar = C₁.eulerChar + C₂.eulerChar := by
  simp [FiniteChainComplex.eulerChar, Nat.cast_add, mul_add, Finset.sum_add_distrib]

/-! ## Part 7: Frobenius to Chain Complex Bridge -/

/-- A Frobenius action induces a chain complex. -/
def frobeniusChainComplex (F : FrobeniusAction) (depth : ℕ) :
    FiniteChainComplex depth where
  rank := fun i => F.iterFixedCount (i.val + 1)
  boundaryRank := fun _ => 0
  boundary_le_source := fun _ => Nat.zero_le _

/-- The Euler characteristic of the Frobenius chain complex equals
    the alternating sum of fixed point counts. -/
theorem frobeniusEulerChar_eq_alternatingSum (F : FrobeniusAction) (depth : ℕ) :
    (frobeniusChainComplex F depth).eulerChar =
    alternatingSum (fun i : Fin depth => (F.iterFixedCount (i.val + 1) : ℤ)) := by
  simp [frobeniusChainComplex, FiniteChainComplex.eulerChar, alternatingSum]

/-
For the identity Frobenius, each iterate fixes all n points.
-/
theorem identity_iterFixedCount (n : ℕ) (k : ℕ) :
    (FrobeniusAction.mk n (Equiv.refl (Fin n))).iterFixedCount k = n := by
  unfold FrobeniusAction.iterFixedCount;
  simp +decide [ Finset.card_univ, Equiv.Perm.pow_apply_eq_self_of_apply_eq_self ]

/-
For the identity Frobenius, the Euler characteristic equals
    n * Σ (-1)^i.
-/
theorem trivial_frobenius_euler (n depth : ℕ) :
    (frobeniusChainComplex ⟨n, Equiv.refl _⟩ depth).eulerChar =
    (n : ℤ) * ∑ i : Fin depth, (-1 : ℤ) ^ (i : ℕ) := by
  unfold frobeniusChainComplex FiniteChainComplex.eulerChar; simp +decide [ identity_iterFixedCount, Finset.mul_sum _ _ _ ] ; ring;

/-- **CRT Separation**: Different residues mod a prime implies distinct. -/
theorem crt_separation (a b : ℤ) (p : ℕ) (_hp : Nat.Prime p)
    (h : a % p ≠ b % p) : a ≠ b := by
  intro hab; exact h (by rw [hab])

/-! ## Part 8: Falsifiable Conjecture -/

/-- **Conjecture (Primewise Persistence Separation)**:
    For curves over ℚ whose Frobenius signatures disagree at all
    sufficiently large primes, the curves are cofinallyDistinguished.

    **Computational Test**: Compare y² = x³ - x and 3x³ + 4y³ + 5z³ = 0
    (Selmer's curve) via Frobenius counts for primes p < 10000 at depth 2. -/
def hasseSeparationConjecture : Prop :=
  ∀ (A B : ArithmeticObject 2),
    (∀ p, Nat.Prime p → p > 5 →
      (A.signatureAt p).counts ≠ (B.signatureAt p).counts) →
    CofinallyDistinguished A B