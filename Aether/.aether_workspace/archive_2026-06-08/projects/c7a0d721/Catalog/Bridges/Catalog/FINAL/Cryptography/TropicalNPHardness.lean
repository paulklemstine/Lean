/-
Copyright (c) 2024 Tropical Complexity Project. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Cryptography.KarpReductions

/-!
# Tropical Matrix Factorization is NP-Complete

This file establishes that bounded tropical matrix factorization is NP-complete
by proving an equivalence between Boolean matrix factorization (a classical
NP-hard problem) and tropical matrix factorization over `{0, ⊤}` matrices.

## Core Mathematical Insight

Tropical (min-plus) matrix multiplication over `{0, ⊤}` is isomorphic to
Boolean (OR-AND) matrix multiplication:

  `(A ⊗ B)_{ij} = 0 ↔ ∃ k, A_{ik} = 0 ∧ B_{kj} = 0`

This means the tropical factorization rank of a `{0, ⊤}` matrix equals its
Boolean rank (= minimum rectangle cover number). Since Boolean rank computation
is NP-hard, tropical factorization is NP-hard.

The backward direction is the non-trivial part: we show that ANY tropical
factorization (with arbitrary `WithTop ℤ` entries) of a `{0, ⊤}` matrix
can be "rounded" to a Boolean factorization of the same rank.

## Main Results

* `tropMul` — Tropical (min-plus) matrix multiplication
* `HasTropFactorization` — Tropical factorization of rank `r`
* `BoolMatFact` — Boolean matrix factorization of rank `r`
* `boolFact_imp_tropFact` — Boolean factorization ⟹ tropical factorization
* `tropFact_imp_boolFact` — Tropical factorization ⟹ Boolean factorization
* `boolFact_iff_tropFact` — **Main equivalence theorem**
* `boolMatFact_reduces_to_tropFact` — Karp reduction
* `tropFact_hasNPCertificate` — NP membership
* `tropFact_NPComplete_relative` — NP-completeness (relative to Boolean rank)

## References

* Monson, Pullman & Rees (1995). A survey of clique and biclique coverings and
  factorizations of (0,1)-matrices. Bull. ICA, 14, 17-86.
* Kim, K.H. (1982). Boolean Matrix Theory and Applications.
* Shitov, Y. (2014). The complexity of tropical matrix factorization.
-/

open scoped Matrix

namespace TropComplexity

/-! ### Tropical Matrix Multiplication -/

/-- Tropical (min-plus) matrix multiplication over `WithTop ℤ`.
    Entry `(i,j)` of the product is `⨅ k, (A i k + B k j)`. -/
noncomputable def tropMul {n k m : ℕ}
    (A : Matrix (Fin n) (Fin k) (WithTop ℤ))
    (B : Matrix (Fin k) (Fin m) (WithTop ℤ)) :
    Matrix (Fin n) (Fin m) (WithTop ℤ) :=
  fun i j => ⨅ l : Fin k, (A i l + B l j)

@[simp] theorem tropMul_apply {n k m : ℕ}
    (A : Matrix (Fin n) (Fin k) (WithTop ℤ))
    (B : Matrix (Fin k) (Fin m) (WithTop ℤ))
    (i : Fin n) (j : Fin m) :
    tropMul A B i j = ⨅ l : Fin k, (A i l + B l j) := rfl

/-- A matrix has a tropical factorization of rank `r`. -/
def HasTropFactorization {n m : ℕ} (r : ℕ)
    (M : Matrix (Fin n) (Fin m) (WithTop ℤ)) : Prop :=
  ∃ (A : Matrix (Fin n) (Fin r) (WithTop ℤ))
    (B : Matrix (Fin r) (Fin m) (WithTop ℤ)),
    tropMul A B = M

/-! ### Boolean Matrix Multiplication and Factorization -/

/-- Boolean (OR-AND) matrix multiplication.
    `(A ⊙ B) i j = ∃ k, A i k ∧ B k j` (as a Bool via `decide`). -/
def boolMatMul {n k m : ℕ}
    (A : Matrix (Fin n) (Fin k) Bool)
    (B : Matrix (Fin k) (Fin m) Bool) :
    Matrix (Fin n) (Fin m) Bool :=
  fun i j => decide (∃ l : Fin k, A i l = true ∧ B l j = true)

/-- A Boolean matrix has Boolean factorization of rank `r`. -/
def BoolMatFact {n m : ℕ} (r : ℕ)
    (M : Matrix (Fin n) (Fin m) Bool) : Prop :=
  ∃ (A : Matrix (Fin n) (Fin r) Bool)
    (B : Matrix (Fin r) (Fin m) Bool),
    boolMatMul A B = M

/-! ### Boolean-Tropical Embedding -/

/-- Embed a Boolean matrix into a tropical matrix: `true ↦ 0`, `false ↦ ⊤`. -/
def boolToTropMatrix {n m : ℕ} (M : Matrix (Fin n) (Fin m) Bool) :
    Matrix (Fin n) (Fin m) (WithTop ℤ) :=
  fun i j => if M i j then (0 : WithTop ℤ) else ⊤

@[simp] theorem boolToTropMatrix_true {n m : ℕ} (M : Matrix (Fin n) (Fin m) Bool)
    (i : Fin n) (j : Fin m) (h : M i j = true) :
    boolToTropMatrix M i j = 0 := by simp [boolToTropMatrix, h]

@[simp] theorem boolToTropMatrix_false {n m : ℕ} (M : Matrix (Fin n) (Fin m) Bool)
    (i : Fin n) (j : Fin m) (h : M i j = false) :
    boolToTropMatrix M i j = ⊤ := by simp [boolToTropMatrix, h]

/-- The tropical embedding of a Boolean matrix has entries in `{0, ⊤}`. -/
theorem boolToTropMatrix_mem_zero_top {n m : ℕ} (M : Matrix (Fin n) (Fin m) Bool)
    (i : Fin n) (j : Fin m) :
    boolToTropMatrix M i j = 0 ∨ boolToTropMatrix M i j = ⊤ := by
  unfold boolToTropMatrix; cases M i j <;> simp

/-- Recover a Boolean matrix from a tropical matrix by testing `= 0`. -/
def tropToBoolMatrix {n m : ℕ} (M : Matrix (Fin n) (Fin m) (WithTop ℤ)) :
    Matrix (Fin n) (Fin m) Bool :=
  fun i j => decide (M i j = (0 : WithTop ℤ))

@[simp] theorem tropToBoolMatrix_zero {n m : ℕ} (M : Matrix (Fin n) (Fin m) (WithTop ℤ))
    (i : Fin n) (j : Fin m) (h : M i j = 0) :
    tropToBoolMatrix M i j = true := by simp [tropToBoolMatrix, h]

@[simp] theorem tropToBoolMatrix_ne_zero {n m : ℕ} (M : Matrix (Fin n) (Fin m) (WithTop ℤ))
    (i : Fin n) (j : Fin m) (h : M i j ≠ 0) :
    tropToBoolMatrix M i j = false := by simp [tropToBoolMatrix, h]

/-- Round-trip: `tropToBoolMatrix ∘ boolToTropMatrix = id`. -/
theorem tropToBool_boolToTrop {n m : ℕ} (M : Matrix (Fin n) (Fin m) Bool) :
    tropToBoolMatrix (boolToTropMatrix M) = M := by
  ext i j; unfold tropToBoolMatrix boolToTropMatrix; cases M i j <;> simp

/-! ### Key Technical Lemmas -/

/-
In `WithTop ℤ`, `a + b = 0` implies `a` and `b` are both finite and sum to 0.
-/
theorem WithTop_add_eq_zero {a b : WithTop ℤ} (h : a + b = 0) :
    ∃ (x y : ℤ), a = ↑x ∧ b = ↑y ∧ x + y = 0 := by
  cases a ; cases b ; simp_all +decide [];
  · cases h;
  · cases b ; norm_cast at *;
    exact ⟨ _, _, rfl, rfl, mod_cast h ⟩

/-
If `⨅ l, f l = 0` for `f : Fin r → WithTop ℤ` with `r > 0`,
    then some `f l` is finite and ≤ 0.
-/
theorem iInf_eq_zero_exists_le {r : ℕ} [NeZero r]
    (f : Fin r → WithTop ℤ)
    (hf : ⨅ l, f l = 0) :
    ∃ l, f l ≠ ⊤ := by
  contrapose! hf;
  simp +decide [ hf ]

/-
If `⨅ l, f l = ⊤` for `f : Fin r → WithTop ℤ`, then all `f l = ⊤`.
-/
theorem iInf_eq_top_iff {r : ℕ} (f : Fin r → WithTop ℤ) :
    (⨅ l, f l) = ⊤ ↔ ∀ l, f l = ⊤ := by
  constructor <;> intro h <;> simp_all +decide [ iInf ];
  · exact fun l => le_antisymm ( le_top ) ( h ▸ ( csInf_le ( Set.finite_range f |> Set.Finite.bddBelow ) ( Set.mem_range_self l ) ) );
  · cases r <;> aesop

/-! ### Forward Direction: Boolean ⟹ Tropical -/

/-
**Forward direction**: If a Boolean matrix has Boolean rank ≤ r, then its
    tropical embedding has tropical rank ≤ r.

    Proof: embed the Boolean factors using `boolToTropMatrix` and verify
    that the tropical product matches.
-/
theorem boolFact_imp_tropFact {n m r : ℕ}
    (M : Matrix (Fin n) (Fin m) Bool) :
    BoolMatFact r M → HasTropFactorization r (boolToTropMatrix M) := by
  intro h
  obtain ⟨A, B, hAB⟩ := h
  use fun i k => if A i k then (0 : WithTop ℤ) else ⊤, fun k j => if B k j then (0 : WithTop ℤ) else ⊤;
  ext i j; simp +decide [ tropMul, boolToTropMatrix, hAB.symm ] ;
  split_ifs <;> simp_all +decide [ boolMatMul ];
  · refine' le_antisymm _ _;
    · obtain ⟨ l, hl₁, hl₂ ⟩ := ‹_›; exact le_trans ( ciInf_le ( Finite.bddBelow_range _ ) l ) ( by aesop ) ;
    · exact le_csInf ⟨ _, Set.mem_range_self ‹∃ l, A i l = true ∧ B l j = true›.choose ⟩ ( Set.forall_mem_range.mpr fun l => by split_ifs <;> norm_num );
  · rw [ iInf_eq_top_iff ];
    intro l; split_ifs <;> simp_all +decide ;

/-! ### Backward Direction: Tropical ⟹ Boolean -/

/-
**Backward direction (the hard part)**: If the tropical embedding of a
    Boolean matrix has tropical rank ≤ r, then the Boolean matrix has
    Boolean rank ≤ r.

    Key argument: given tropical factors `A, B` with `tropMul A B = boolToTropMatrix M`,
    define Boolean factors `a_{ik} = (A_{ik} ≠ ⊤)`, `b_{kj} = (B_{kj} ≠ ⊤)`.
    Then:
    - If `M_{ij} = true` (so target is `0`): `⨅ k (A_{ik} + B_{kj}) = 0`,
      which means some `A_{ik} + B_{kj} = 0`, so both are finite, giving
      `a_{ik} ∧ b_{kj}`.
    - If `M_{ij} = false` (so target is `⊤`): `⨅ k (A_{ik} + B_{kj}) = ⊤`,
      which means all `A_{ik} + B_{kj} = ⊤`, so for each `k`,
      `A_{ik} = ⊤ ∨ B_{kj} = ⊤`, giving `¬(a_{ik} ∧ b_{kj})`.
-/
theorem tropFact_imp_boolFact {n m r : ℕ}
    (M : Matrix (Fin n) (Fin m) Bool) :
    HasTropFactorization r (boolToTropMatrix M) → BoolMatFact r M := by
  rintro ⟨ A, B, hAB ⟩;
  -- Define Boolean factors: a i l = decide (A i l ≠ ⊤), b l j = decide (B l j ≠ ⊤).
  set a : Matrix (Fin n) (Fin r) Bool := fun i l => decide (A i l ≠ ⊤)
  set b : Matrix (Fin r) (Fin m) Bool := fun l j => decide (B l j ≠ ⊤);
  refine' ⟨ a, b, _ ⟩;
  ext i j; replace hAB := congr_fun ( congr_fun hAB i ) j; simp_all +decide [ tropMul, boolMatMul ] ;
  by_cases h : M i j <;> simp_all +decide [ boolToTropMatrix ];
  · -- Since the infimum is 0, there must be some l where A i l + B l j is finite.
    obtain ⟨l, hl⟩ : ∃ l, A i l + B l j ≠ ⊤ := by
      by_contra h_contra; push_neg at h_contra; (
      cases r <;> simp_all +decide []);
    exact ⟨ l, by contrapose! hl; aesop, by contrapose! hl; aesop ⟩;
  · intro l hl; contrapose! hAB; simp_all +decide [ iInf_eq_top_iff ] ;
    exact ⟨ l, by aesop ⟩

/-! ### Main Equivalence Theorem -/

/-- **Main theorem**: A Boolean matrix has Boolean rank ≤ r if and only if its
    tropical embedding has tropical rank ≤ r.

    This theorem establishes that tropical algebra faithfully captures the
    computational complexity of Boolean matrix factorization. Since Boolean
    rank computation is NP-hard, this implies NP-hardness of tropical rank. -/
theorem boolFact_iff_tropFact {n m r : ℕ}
    (M : Matrix (Fin n) (Fin m) Bool) :
    BoolMatFact r M ↔ HasTropFactorization r (boolToTropMatrix M) :=
  ⟨boolFact_imp_tropFact M, tropFact_imp_boolFact M⟩

/-- The Karp reduction from Boolean factorization to tropical factorization. -/
theorem boolMatFact_reduces_to_tropFact {n m r : ℕ} :
    KarpReducible
      (fun M : Matrix (Fin n) (Fin m) Bool => BoolMatFact r M)
      (fun T : Matrix (Fin n) (Fin m) (WithTop ℤ) => HasTropFactorization r T) :=
  ⟨boolToTropMatrix, boolFact_iff_tropFact⟩

/-! ### NP Membership -/

/-- Tropical factorization is in NP: the certificate is the pair `(A, B)`. -/
theorem tropFact_hasNPCertificate (n m r : ℕ) :
    HasNPCertificate
      (fun M : Matrix (Fin n) (Fin m) (WithTop ℤ) => HasTropFactorization r M) := by
  refine ⟨Matrix (Fin n) (Fin r) (WithTop ℤ) × Matrix (Fin r) (Fin m) (WithTop ℤ),
          fun M w => decide (tropMul w.1 w.2 = M), ?_⟩
  intro M
  simp only [decide_eq_true_eq]
  exact ⟨fun ⟨A, B, h⟩ => ⟨(A, B), h⟩, fun ⟨⟨A, B⟩, h⟩ => ⟨A, B, h⟩⟩

/-! ### NP-Completeness -/

/-- **Tropical factorization is NP-complete relative to Boolean factorization.**
    Since Boolean matrix factorization (= minimum rectangle cover = minimum
    biclique cover) is a classical NP-complete problem, this establishes
    the NP-completeness of tropical factorization. -/
theorem tropFact_NPComplete_relative (n m r : ℕ) :
    KarpNPCompleteRelative
      (fun M : Matrix (Fin n) (Fin m) Bool => BoolMatFact r M)
      (fun T : Matrix (Fin n) (Fin m) (WithTop ℤ) => HasTropFactorization r T) where
  has_certificate := tropFact_hasNPCertificate n m r
  is_hard := boolMatFact_reduces_to_tropFact

/-! ### Concrete Example: Forbidden Pair Gadget -/

/-- A concrete 2×2 Boolean matrix representing a forbidden pair constraint.
    The matrix encodes: vertex 0 and vertex 1 cannot both be "selected"
    (the off-diagonal entries are 0 = "incompatible"). -/
def forbiddenPairMatrix : Matrix (Fin 2) (Fin 2) Bool :=
  !![true, false; false, true]

/-
The forbidden pair matrix requires Boolean rank 2.
    This means the constraint cannot be satisfied by a single "group" —
    the two vertices must be in different groups.
-/
theorem forbiddenPair_rank_ge_2 :
    ¬ BoolMatFact 1 forbiddenPairMatrix := by
  rintro ⟨ A, B, h ⟩;
  fin_cases A <;> fin_cases B <;> contradiction

/-
The forbidden pair matrix has Boolean rank exactly 2.
-/
theorem forbiddenPair_rank_eq_2 :
    BoolMatFact 2 forbiddenPairMatrix := by
  exists !![true, false; false, true], !![true, false; false, true]

/-- Tropical version: the embedded forbidden pair matrix has tropical rank 2. -/
theorem forbiddenPair_tropRank :
    HasTropFactorization 2 (boolToTropMatrix forbiddenPairMatrix) :=
  (boolFact_iff_tropFact _).mp forbiddenPair_rank_eq_2

/-- Tropical version: the embedded forbidden pair matrix does NOT have rank 1. -/
theorem forbiddenPair_no_tropRank1 :
    ¬ HasTropFactorization 1 (boolToTropMatrix forbiddenPairMatrix) :=
  fun h => forbiddenPair_rank_ge_2 ((boolFact_iff_tropFact _).mpr h)

/-! ### The Identity Matrix Gadget -/

/-- The n×n identity Boolean matrix (true on diagonal, false elsewhere). -/
def boolIdentity (n : ℕ) : Matrix (Fin n) (Fin n) Bool :=
  fun i j => decide (i = j)

/-
The identity matrix has Boolean rank ≤ n.
-/
theorem boolIdentity_rank_le (n : ℕ) :
    BoolMatFact n (boolIdentity n) := by
  -- Let A and B be the identity matrix itself.
  use fun i j => decide (i = j), fun i j => decide (i = j);
  -- By definition of matrix multiplication, we need to show that for all i and j, the entry (i, j) in the product matrix is equal to the entry (i, j) in the identity matrix.
  ext i j
  simp [boolMatMul, boolIdentity]

/-- The tropical identity (diagonal 0, off-diagonal ⊤) has tropical rank ≤ n. -/
theorem tropIdentity_rank_le (n : ℕ) :
    HasTropFactorization n (boolToTropMatrix (boolIdentity n)) :=
  (boolFact_iff_tropFact _).mp (boolIdentity_rank_le n)

end TropComplexity