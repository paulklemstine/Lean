import Mathlib

/-! # CatalogBuild.Speculative.RosettaStone.Bridge10_Research

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 64
-/

noncomputable section

/-- In a product ring, idempotents decompose componentwise. -/
theorem prod_idempotent_iff {R S : Type*} [Ring R] [Ring S] (x : R × S) :
    x * x = x ↔ x.1 * x.1 = x.1 ∧ x.2 * x.2 = x.2 := by
  constructor
  · intro h; exact ⟨congr_arg Prod.fst h, congr_arg Prod.snd h⟩
  · intro ⟨h1, h2⟩; ext <;> assumption

/-- A field has exactly 2 idempotents: 0 and 1. -/
theorem field_idempotent_iff {F : Type*} [Field F] (e : F) :
    e * e = e ↔ e = 0 ∨ e = 1 := by
  constructor
  · intro h
    have : e * (e - 1) = 0 := by rw [mul_sub, mul_one, h, sub_self]
    rcases mul_eq_zero.mp this with rfl | h2
    · exact Or.inl rfl
    · exact Or.inr (sub_eq_zero.mp h2)
  · rintro (rfl | rfl) <;> simp

/-- ℤ/pℤ for prime p has exactly 2 idempotents (computationally verified for small primes). -/
theorem prime_two_idempotents_2 :
    (Finset.univ.filter (fun e : ZMod 2 => e * e = e)).card = 2 := by decide

/-- [Section: # CatalogBuild.Speculative.RosettaStone.Bridge10_Research
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 65] -/
theorem prime_two_idempotents_3 :
    (Finset.univ.filter (fun e : ZMod 3 => e * e = e)).card = 2 := by decide

/-- [Section: # CatalogBuild.Speculative.RosettaStone.Bridge10_Research
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 65] -/
theorem prime_two_idempotents_5 :
    (Finset.univ.filter (fun e : ZMod 5 => e * e = e)).card = 2 := by decide

theorem prime_two_idempotents_7 :
    (Finset.univ.filter (fun e : ZMod 7 => e * e = e)).card = 2 := by decide

theorem prime_two_idempotents_11 :
    (Finset.univ.filter (fun e : ZMod 11 => e * e = e)).card = 2 := by decide

theorem prime_two_idempotents_13 :
    (Finset.univ.filter (fun e : ZMod 13 => e * e = e)).card = 2 := by decide

/-- Idempotent count for ℤ/2ℤ × ℤ/3ℤ is 2 × 2 = 4 (= count for ℤ/6ℤ). -/
theorem prod_idempotent_count_2_3 :
    (Finset.univ.filter (fun e : ZMod 2 × ZMod 3 => e * e = e)).card = 4 := by
  decide

/-- The CRT-Motivic principle: idempotents in ℤ/6ℤ match ℤ/2ℤ × ℤ/3ℤ. -/
theorem crt_idempotent_match :
    (Finset.univ.filter (fun e : ZMod 6 => e * e = e)).card =
    (Finset.univ.filter (fun e : ZMod 2 × ZMod 3 => e * e = e)).card := by
  decide

/-- Complement of idempotent is idempotent. -/
theorem idem_compl (e : R) (he : e * e = e) :
    (1 - e) * (1 - e) = 1 - e := by
  have : (1 - e) * (1 - e) = 1 - 2 * e + e * e := by ring
  rw [this, he]; ring

/-- Meet and complement give ⊥. -/
theorem idem_meet_compl (e : R) (he : e * e = e) :
    e * (1 - e) = 0 := by rw [mul_sub, mul_one, he, sub_self]

/-- Join and complement give ⊤. -/
theorem idem_join_compl (e : R) (he : e * e = e) :
    e + (1 - e) - e * (1 - e) = 1 := by rw [idem_meet_compl e he]; ring

/-- Absorption: e ∧ (e ∨ f) = e. -/
theorem idem_absorption (e f : R) (he : e * e = e) :
    e * (e + f - e * f) = e := by
  have : e * (e + f - e * f) = e * e + e * f - e * e * f := by ring
  rw [this, he]; ring

/-- The trace of a diagonal projection counts the selected indices. -/
theorem trace_diagonal_projection {n : ℕ} (S : Finset (Fin n)) :
    (Matrix.diagonal (fun i => if i ∈ S then (1 : ℝ) else 0)).trace =
    (S.card : ℝ) := by
  simp [Matrix.trace, Matrix.diag_apply, Finset.sum_ite_mem]

theorem trace_complement {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ) :
    P.trace + (1 - P).trace = (n : ℝ) := by
      norm_num [ Matrix.trace_sub ]

/-- Trace is invariant under cyclic permutation. -/
theorem trace_cyclic_perm {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) ℝ) :
    (A * B).trace = (B * A).trace :=
  Matrix.trace_mul_comm A B

/-- Classical: in ℝ, x² = x implies x ∈ {0, 1}. -/
theorem classical_idempotent_sparse (x : ℝ) (hx : x * x = x) :
    x = 0 ∨ x = 1 := (field_idempotent_iff x).mp hx

/-- Tropical: min(x, x) = x for ALL x. -/
theorem tropical_idempotent_dense (x : ℝ) : min x x = x := min_self x

/-- The tropical semiring satisfies left distributivity. -/
theorem tropical_left_distrib (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith

/-- The tropical semiring satisfies right distributivity. -/
theorem tropical_right_distrib (a b c : ℝ) :
    min a b + c = min (a + c) (b + c) := by
  simp [min_def]; split_ifs <;> linarith

/-- Complete system of orthogonal idempotents in a ring. -/
structure CSOI (R : Type*) [Ring R] (n : ℕ) where
  proj : Fin n → R
  idempotent : ∀ i, proj i * proj i = proj i
  orthogonal : ∀ i j, i ≠ j → proj i * proj j = 0
  complete : ∑ i : Fin n, proj i = 1

/-- Spectral decomposition: any element is the sum of its projections. -/
theorem spectral_decomposition {R : Type*} [Ring R] {n : ℕ}
    (csoi : CSOI R n) (x : R) :
    x = ∑ i : Fin n, csoi.proj i * x := by
  conv_lhs => rw [← one_mul x, ← csoi.complete]; rw [Finset.sum_mul]

/-- Each spectral component is stable under its projector. -/
theorem spectral_component_stable {R : Type*} [Ring R] {n : ℕ}
    (csoi : CSOI R n) (x : R) (k : Fin n) :
    csoi.proj k * (csoi.proj k * x) = csoi.proj k * x := by
  rw [← mul_assoc, csoi.idempotent]

/-- Orthogonality of spectral components. -/
theorem spectral_orthogonality {R : Type*} [Ring R] {n : ℕ}
    (csoi : CSOI R n) (x : R) (i j : Fin n) (hij : i ≠ j) :
    csoi.proj i * (csoi.proj j * x) = 0 := by
  rw [← mul_assoc, csoi.orthogonal i j hij, zero_mul]

theorem csoi_two_is_complement {R : Type*} [Ring R]
    (csoi : CSOI R 2) :
    csoi.proj 1 = 1 - csoi.proj 0 := by
      have := csoi.complete;
      rw [ ← this, Fin.sum_univ_two, eq_sub_iff_add_eq', add_comm ]

/-- The trivial CSOI: {1}. -/
def csoi_trivial (R : Type*) [Ring R] : CSOI R 1 where
  proj := fun _ => 1
  idempotent := fun _ => one_mul 1
  orthogonal := fun i j hij => absurd (Subsingleton.elim i j) hij
  complete := by simp

def csoi_from_idempotent {R : Type*} [Ring R] (e : R) (he : e * e = e)
    (he_orth1 : e * (1 - e) = 0) (he_orth2 : (1 - e) * e = 0) :
    CSOI R 2 where
  proj := ![e, 1 - e]
  idempotent := by
    simp_all +decide [ Fin.forall_fin_two, sub_mul, mul_sub ]
  orthogonal := by
    intro i j hij; fin_cases i <;> fin_cases j <;> simp_all [Matrix.cons_val_zero, Matrix.cons_val_one]
  complete := by
    simp [Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]

theorem range_eq_ker_complement (e : W →ₗ[K] W) (he : e ∘ₗ e = e) :
    LinearMap.range e = LinearMap.ker (LinearMap.id - e) := by
      ext x;
      simp +zetaDelta at *;
      constructor <;> intro h;
      · obtain ⟨ y, rfl ⟩ := h;
        rw [ sub_eq_zero, ← LinearMap.comp_apply, he ];
      · grind

theorem ker_eq_range_complement (e : W →ₗ[K] W) (he : e ∘ₗ e = e) :
    LinearMap.ker e = LinearMap.range (LinearMap.id - e) := by
      exact LinearMap.IsIdempotentElem.ker_eq_range he

/-- The oracle "identity on image" theorem for linear maps. -/
theorem linear_oracle_identity (e : W →ₗ[K] W) (he : e ∘ₗ e = e)
    (x : W) (hx : x ∈ LinearMap.range e) : e x = x := by
  obtain ⟨y, rfl⟩ := hx; exact LinearMap.congr_fun he y

theorem idem_p2 : idemCount 2 = 2 := by native_decide

theorem idem_p3 : idemCount 3 = 2 := by native_decide

theorem idem_p5 : idemCount 5 = 2 := by native_decide

theorem idem_p7 : idemCount 7 = 2 := by native_decide

-- Prime powers: still 2 idempotents (ω = 1)

theorem idem_4 : idemCount 4 = 2 := by native_decide

theorem idem_9 : idemCount 9 = 2 := by native_decide

theorem idem_25 : idemCount 25 = 2 := by native_decide

-- Products of 2 distinct primes: 4 = 2² idempotents

theorem idem_6 : idemCount 6 = 4 := by native_decide

theorem idem_10 : idemCount 10 = 4 := by native_decide

theorem idem_15 : idemCount 15 = 4 := by native_decide

theorem idem_21 : idemCount 21 = 4 := by native_decide

theorem idem_35 : idemCount 35 = 4 := by native_decide

-- Products of 3 distinct primes: 8 = 2³ idempotents

theorem idem_30 : idemCount 30 = 8 := by native_decide

theorem idem_42 : idemCount 42 = 8 := by native_decide

-- Multiplicativity verified computationally

theorem idem_mult_6 : idemCount 6 = idemCount 2 * idemCount 3 := by native_decide

theorem idem_mult_10 : idemCount 10 = idemCount 2 * idemCount 5 := by native_decide

theorem idem_mult_15 : idemCount 15 = idemCount 3 * idemCount 5 := by native_decide

theorem idem_mult_30 : idemCount 30 = idemCount 2 * idemCount 15 := by native_decide

theorem idem_mult_210 : idemCount 210 = idemCount 2 * idemCount 105 := by native_decide

/-- An interior operator on a partial order. -/
structure InteriorOp (α : Type*) [Preorder α] where
  op : α → α
  mono : ∀ a b, a ≤ b → op a ≤ op b
  restrictive : ∀ a, op a ≤ a
  idempotent : ∀ a, op (op a) = op a

/-- Topological closure is a closure operator. -/
noncomputable def topological_closure (X : Type*) [TopologicalSpace X] :
    ClosureOp (Set X) where
  op := closure
  mono := fun _ _ h => closure_mono h
  extensive := fun _ => subset_closure
  idempotent := fun _ => isClosed_closure.closure_eq

/-- Topological interior is an interior operator. -/
noncomputable def topological_interior (X : Type*) [TopologicalSpace X] :
    InteriorOp (Set X) where
  op := interior
  mono := fun _ _ h => interior_mono h
  restrictive := fun _ => interior_subset
  idempotent := fun _ => isOpen_interior.interior_eq

/-- Every element of the form cl(a) is a fixed point. -/
theorem closure_image_fixed {α : Type*} [Preorder α] (cl : ClosureOp α) (a : α) :
    cl.op (cl.op a) = cl.op a := cl.idempotent a

/-- Interior = complement of closure of complement. -/
theorem interior_via_closure (X : Type*) [TopologicalSpace X] (s : Set X) :
    interior s = (closure sᶜ)ᶜ := by rw [closure_compl, compl_compl]

theorem bridge1_instance {R : Type*} [Ring R] (e : R) (he : e * e = e) : IsIdem e := he

theorem bridge2_instance {α : Type*} [SemilatticeInf α] (a : α) :
    @IsIdem α ⟨(· ⊓ ·)⟩ a := inf_idem a

theorem bridge5_instance {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ) (hP : P * P = P) :
    IsIdem P := hP

theorem bridge7_instance (a : ℝ) : @IsIdem ℝ ⟨min⟩ a := min_self a

/-- The idempotent entropy: log of the number of idempotents. -/
noncomputable def idemEntropy (k : ℕ) : ℝ :=
  if k = 0 then 0 else Real.log k

theorem field_idem_entropy : idemEntropy 2 = Real.log 2 := by simp [idemEntropy]

theorem zmod6_idem_entropy : idemEntropy 4 = Real.log 4 := by simp [idemEntropy]

/-- Entropy increases with number of idempotents. -/
theorem idem_entropy_mono (k₁ k₂ : ℕ) (hk1 : 0 < k₁) (hk2 : k₁ ≤ k₂) :
    idemEntropy k₁ ≤ idemEntropy k₂ := by
  simp only [idemEntropy, if_neg (by omega : k₁ ≠ 0), if_neg (by omega : k₂ ≠ 0)]
  exact Real.log_le_log (by positivity) (by exact_mod_cast hk2)

/-- Multiplicativity of counts implies additivity of entropy. -/
theorem idem_entropy_additive (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    idemEntropy (m * n) = idemEntropy m + idemEntropy n := by
  have hmn : m * n ≠ 0 := by positivity
  simp only [idemEntropy, if_neg (by omega : m ≠ 0), if_neg (by omega : n ≠ 0), if_neg hmn]
  push_cast
  exact Real.log_mul (by positivity) (by positivity)

end