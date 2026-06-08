/-
  # Hadamard Matrix Constructions — Tensor Closure and Sylvester Families

  This file establishes the constructive algebra of Hadamard existence:
  - Kronecker product of Hadamard matrices is Hadamard
  - HadamardOrder is closed under multiplication (tensor closure)
  - The Sylvester family: HadamardOrder (2^k) for all k
  - HadamardSeed inductive for generated orders
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Redefined core predicates (self-contained for modularity) -/

/-- A matrix is Hadamard if all entries are ±1 and H * Hᵀ = n • I. -/
def IsHadamard' {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- An order n admits a Hadamard matrix. -/
def HadamardOrder' (n : ℕ) : Prop :=
  ∃ H : Matrix (Fin n) (Fin n) ℤ, IsHadamard' H

/-! ## Trivial orders -/

theorem hadamardOrder'_one : HadamardOrder' 1 := by
  refine ⟨fun _ _ => 1, fun i j => Or.inl rfl, ?_⟩
  ext i j
  simp [Matrix.mul_apply, Matrix.one_apply]
  have := Subsingleton.elim i j; subst this; simp

theorem hadamardOrder'_two : HadamardOrder' 2 :=
  ⟨!![1, 1; 1, -1], fun i j => by fin_cases i <;> fin_cases j <;> simp,
    by ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]⟩

/-! ## Kronecker product for Hadamard matrices -/

/-- The Kronecker product of two matrices, indexed by `Fin (m * n)` via `finProdFinEquiv`. -/
noncomputable def hadamardKronecker {m n : ℕ}
    (H₁ : Matrix (Fin m) (Fin m) ℤ) (H₂ : Matrix (Fin n) (Fin n) ℤ) :
    Matrix (Fin (m * n)) (Fin (m * n)) ℤ :=
  fun i j =>
    H₁ (finProdFinEquiv.symm i).1 (finProdFinEquiv.symm j).1 *
    H₂ (finProdFinEquiv.symm i).2 (finProdFinEquiv.symm j).2

/-
Key factorization: sums over `Fin (m * n)` split as products of sums.
-/
theorem sum_finProdFin_eq {m n : ℕ} (f : Fin m → ℤ) (g : Fin n → ℤ) :
    ∑ k : Fin (m * n),
      f (finProdFinEquiv.symm k).1 * g (finProdFinEquiv.symm k).2 =
    (∑ a : Fin m, f a) * (∑ b : Fin n, g b) := by
      rw [ Finset.sum_mul_sum ];
      rw [ ← Finset.sum_product' ];
      refine' Finset.sum_bij ( fun k _ => ( finProdFinEquiv.symm k ) ) _ _ _ _ <;> simp +decide [ Finset.mem_product ];
      · exact fun a₁ a₂ h₁ h₂ => Fin.ext <| by nlinarith [ Nat.mod_add_div a₁ n, Nat.mod_add_div a₂ n, show a₁.val % n = a₂.val % n from congr_arg Fin.val h₂, show a₁.val / n = a₂.val / n from congr_arg Fin.val h₁ ] ;
      · intro a b; use ⟨ a * n + b, by nlinarith [ Fin.is_lt a, Fin.is_lt b ] ⟩ ; simp +decide [ Nat.div_eq_of_lt, Nat.mod_eq_of_lt, Fin.ext_iff ] ;
        rw [ Nat.add_div ] <;> norm_num [ Nat.div_eq_of_lt, Fin.is_lt ];
        · cases n <;> simp_all +decide [ Nat.div_eq_of_lt, Nat.mod_eq_of_lt ];
          · exact Fin.elim0 b;
          · exact Nat.le_of_lt_succ ( Nat.mod_lt _ ( Nat.succ_pos _ ) );
        · exact Fin.pos b

/-
Entries of the Kronecker product of ±1 matrices are ±1.
-/
theorem hadamardKronecker_entries {m n : ℕ}
    {H₁ : Matrix (Fin m) (Fin m) ℤ} {H₂ : Matrix (Fin n) (Fin n) ℤ}
    (h₁ : ∀ i j, H₁ i j = 1 ∨ H₁ i j = -1)
    (h₂ : ∀ i j, H₂ i j = 1 ∨ H₂ i j = -1) :
    ∀ i j, hadamardKronecker H₁ H₂ i j = 1 ∨ hadamardKronecker H₁ H₂ i j = -1 := by
      intro i j; obtain hi | hi := h₁ ( finProdFinEquiv.symm i |>.1 ) ( finProdFinEquiv.symm j |>.1 ) <;> obtain hj | hj := h₂ ( finProdFinEquiv.symm i |>.2 ) ( finProdFinEquiv.symm j |>.2 ) <;> simp +decide only [hadamardKronecker, hi, hj] ;

/-
The Kronecker product of two Hadamard matrices is Hadamard.
-/
set_option maxHeartbeats 400000 in
theorem isHadamard'_kronecker {m n : ℕ}
    {H₁ : Matrix (Fin m) (Fin m) ℤ} {H₂ : Matrix (Fin n) (Fin n) ℤ}
    (hH₁ : IsHadamard' H₁) (hH₂ : IsHadamard' H₂) :
    IsHadamard' (hadamardKronecker H₁ H₂) := by
      refine' ⟨ hadamardKronecker_entries hH₁.1 hH₂.1, _ ⟩;
      -- By definition of matrix multiplication and the properties of the Kronecker product, we can expand the product.
      have h_expand : ∀ i j : Fin (m * n), (∑ k : Fin (m * n), (hadamardKronecker H₁ H₂ i k) * (hadamardKronecker H₁ H₂ j k)) = (∑ a : Fin m, (H₁ ((finProdFinEquiv.symm i).1) a) * (H₁ ((finProdFinEquiv.symm j).1) a)) * (∑ b : Fin n, (H₂ ((finProdFinEquiv.symm i).2) b) * (H₂ ((finProdFinEquiv.symm j).2) b)) := by
        intros i j;
        convert sum_finProdFin_eq _ _ using 2 ; ring!;
        unfold hadamardKronecker; ring!;
      -- By definition of matrix multiplication and the properties of the Kronecker product, we can expand the product and simplify.
      have h_simplify : ∀ i j : Fin (m * n), (∑ k : Fin (m * n), (hadamardKronecker H₁ H₂ i k) * (hadamardKronecker H₁ H₂ j k)) = if i = j then (m * n : ℤ) else 0 := by
        have h_simplify : ∀ i j : Fin m, (∑ a : Fin m, (H₁ i a) * (H₁ j a)) = if i = j then (m : ℤ) else 0 := by
          intro i j; have := congr_fun ( congr_fun hH₁.2 i ) j; simp_all +decide [ Matrix.mul_apply ] ;
          simp +decide [ Matrix.one_apply ];
        have h_simplify₂ : ∀ i j : Fin n, (∑ b : Fin n, (H₂ i b) * (H₂ j b)) = if i = j then (n : ℤ) else 0 := by
          intro i j; have := congr_fun ( congr_fun hH₂.2 i ) j; simp_all +decide [ Matrix.mul_apply ] ;
          simp +decide [ Matrix.one_apply ];
        simp_all +decide [ Fin.ext_iff ];
        intro i j; split_ifs <;> simp_all +decide [ Nat.mod_eq_of_lt, Nat.div_eq_of_lt ] ;
        exact False.elim <| ‹¬ ( i : ℕ ) = j› <| by nlinarith [ Nat.mod_add_div i n, Nat.mod_add_div j n ] ;
      ext i j; simp +decide [ Matrix.mul_apply, h_simplify ] ;
      simp +decide [ Matrix.one_apply ]

/-! ## Tensor closure of Hadamard existence

This is the formal core of "Hadamard orders form a multiplicative semigroup."
Once certified, every new sporadic order immediately explodes into infinitely many others.
-/

/-- **Tensor closure**: if Hadamard matrices exist of orders m and n,
    then one exists of order m * n. -/
theorem hadamardOrder'_mul {m n : ℕ}
    (hm : HadamardOrder' m) (hn : HadamardOrder' n) :
    HadamardOrder' (m * n) := by
  obtain ⟨H₁, hH₁⟩ := hm
  obtain ⟨H₂, hH₂⟩ := hn
  exact ⟨hadamardKronecker H₁ H₂, isHadamard'_kronecker hH₁ hH₂⟩

/-! ## Sylvester family: powers of two -/

/-- **Sylvester family**: for every k, there exists a Hadamard matrix of order 2^k.
    This gives a fully verified infinite family of Hadamard orders. -/
theorem hadamardOrder'_pow_two (k : ℕ) : HadamardOrder' (2 ^ k) := by
  induction k with
  | zero => simpa using hadamardOrder'_one
  | succ k ih =>
    rw [pow_succ]
    exact hadamardOrder'_mul ih hadamardOrder'_two

/-- Corollary: 4 * 2^k is always a Hadamard order. -/
theorem hadamardOrder'_four_mul_pow_two (k : ℕ) :
    HadamardOrder' (4 * 2 ^ k) := by
  have h4 : HadamardOrder' 4 := by
    rw [show (4 : ℕ) = 2 ^ 2 from by norm_num]
    exact hadamardOrder'_pow_two 2
  exact hadamardOrder'_mul h4 (hadamardOrder'_pow_two k)

/-! ## Hadamard generation calculus -/

/-- Inductive structure encoding which orders are constructively generated
    by the known Hadamard constructions. -/
inductive HadamardSeed : ℕ → Prop
  | base1 : HadamardSeed 1
  | base2 : HadamardSeed 2
  | tensor {m n : ℕ} : HadamardSeed m → HadamardSeed n → HadamardSeed (m * n)

/-- Every generated order is indeed a Hadamard order (soundness). -/
theorem hadamardSeed_implies_order {n : ℕ} (h : HadamardSeed n) :
    HadamardOrder' n := by
  induction h with
  | base1 => exact hadamardOrder'_one
  | base2 => exact hadamardOrder'_two
  | tensor _ _ ih₁ ih₂ => exact hadamardOrder'_mul ih₁ ih₂

/-- Powers of two are generated. -/
theorem hadamardSeed_pow_two (k : ℕ) : HadamardSeed (2 ^ k) := by
  induction k with
  | zero => simpa using HadamardSeed.base1
  | succ k ih =>
    rw [pow_succ]
    exact HadamardSeed.tensor ih HadamardSeed.base2

/-- The set of generated Hadamard orders (as a predicate). -/
def GeneratedHadamardOrder (n : ℕ) : Prop := HadamardSeed n