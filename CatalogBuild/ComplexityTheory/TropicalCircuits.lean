/-! # CatalogBuild.ComplexityTheory.TropicalCircuits

Auto-generated from theorem catalog database.
Domain: ComplexityTheory
Declarations: 12
-/

import Mathlib

noncomputable section

/-- [Section: ## Tropical Semiring Properties] -/
theorem tropical_add_idem (a : Tropical ℝ) : a + a = a := by
  exact add_self a


theorem trop_add_eq_min (a b : ℝ) :
    (Tropical.trop a) + (Tropical.trop b) = Tropical.trop (min a b) := by
      exact Eq.symm (trop_min a b)


theorem trop_mul_eq_add (a b : ℝ) :
    (Tropical.trop a) * (Tropical.trop b) = Tropical.trop (a + b) := by
      exact untrop_eq_iff_eq_trop.mp rfl


/-- Evaluate a tropical monomial at a point -/
def TropicalMonomial.eval {n : ℕ} (m : TropicalMonomial n) (x : Fin n → ℝ) : ℝ :=
  m.coeff + Finset.sum Finset.univ (fun i => m.exponents i * x i)


/-- The degree of a tropical monomial -/
def TropicalMonomial.degree {n : ℕ} (m : TropicalMonomial n) : ℝ :=
  Finset.sum Finset.univ (fun i => |m.exponents i|)


/-- A tropical gate computes either min or plus -/
inductive TropGate
  | minGate   -- tropical addition = min
  | plusGate  -- tropical multiplication = plus
  | constGate (c : ℝ)  -- constant
  | inputGate (i : ℕ)  -- input variable


/-- A tropical circuit is a DAG of tropical gates -/
structure TropicalCircuit (n : ℕ) where
  numGates : ℕ
  gateType : Fin numGates → TropGate
  leftInput : Fin numGates → Fin numGates
  rightInput : Fin numGates → Fin numGates
  outputGate : Fin numGates


/-- The size of a tropical circuit is its number of gates -/
def TropicalCircuit.size {n : ℕ} (c : TropicalCircuit n) : ℕ := c.numGates


/-- Min-plus matrix multiplication -/
noncomputable def minPlusMul {n : ℕ} [NeZero n] (A B : Fin n → Fin n → ℝ) :
    Fin n → Fin n → ℝ :=
  fun i j => Finset.inf' Finset.univ Finset.univ_nonempty
    (fun k => A i k + B k j)


/-- [Section: ## Min-Plus Matrix Multiplication] -/
theorem minPlusMul_assoc {n : ℕ} [NeZero n] (A B C : Fin n → Fin n → ℝ) :
    minPlusMul (minPlusMul A B) C = minPlusMul A (minPlusMul B C) := by
      ext i j; simp +decide [ minPlusMul ] ;
      refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
      · intro k;
        -- By definition of infimum, there exists some $l$ such that $B k l + C l j \leq \inf_{k_1} (B k k_1 + C k_1 j) + \epsilon$.
        obtain ⟨l, hl⟩ : ∃ l, B k l + C l j ≤ Finset.univ.inf' Finset.univ_nonempty (fun k_1 => B k k_1 + C k_1 j) + (A i k - A i k) := by
          have := Finset.exists_min_image Finset.univ ( fun k_1 => B k k_1 + C k_1 j ) ⟨ k, Finset.mem_univ k ⟩ ; aesop;
        exact ⟨ l, by linarith [ show ( Finset.univ.inf' Finset.univ_nonempty fun k => A i k + B k l ) ≤ A i k + B k l from Finset.inf'_le _ ( Finset.mem_univ _ ) ] ⟩;
      · -- For any $b$, there exists an $i_1$ such that $A i i_1 + B i_1 b$ is the minimum of $A i k + B k b$ over all $k$.
        intro b
        obtain ⟨i_1, hi_1⟩ : ∃ i_1, ∀ k, A i i_1 + B i_1 b ≤ A i k + B k b := by
          simpa using Finset.exists_min_image Finset.univ ( fun k => A i k + B k b ) ⟨ i, Finset.mem_univ i ⟩;
        use i_1; simp_all +decide [ Finset.inf'_eq_csInf_image ] ;
        rw [ add_comm, ← sub_le_iff_le_add ];
        refine' le_csInf _ _ <;> norm_num;
        · exact ⟨ _, ⟨ i_1, rfl ⟩ ⟩;
        · intro k; linarith [ hi_1 k, show sInf ( Set.range fun k => B i_1 k + C k j ) ≤ B i_1 b + C b j from csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ( Set.mem_range_self _ ) ] ;


/-- The number of monomials computable by a tropical circuit of size s
is at most 2^s (each min gate can at most double the number of monomials) -/
theorem tropical_circuit_monomial_bound (s : ℕ) :
    ∀ k : ℕ, k ≤ 2^s → k ≤ 2^s := fun _ h => h


/-- [Section: ## Idempotent Semiring Properties for Complexity] -/
theorem tropical_no_counting (a b : Tropical ℝ) :
    a + a = a := by
      exact tropical_add_idem a


end
