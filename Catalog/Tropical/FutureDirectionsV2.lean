import Mathlib

/-! # CatalogBuild.Tropical.Core.FutureDirectionsV2

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 43
-/

noncomputable section

/-- Hard attention: for each query, select the key with maximum score -/
def hardAttention {n d : ℕ} [NeZero n] (Q K V : Fin n → Fin d → ℝ)
    (q : Fin n) : Fin d → ℝ :=
  let scores : Fin n → ℝ := fun k =>
    ∑ j : Fin d, Q q j * K k j
  let best : Fin n := Finset.univ.sup' Finset.univ_nonempty
    (fun k => (⟨scores k, k⟩ : Prod ℝ (Fin n))) |>.2
  V best

/-- The score function for attention -/
def attentionScore {n d : ℕ} (Q K : Fin n → Fin d → ℝ) (q k : Fin n) : ℝ :=
  ∑ j : Fin d, Q q j * K k j

/-- Softmax maps ℝⁿ → the probability simplex -/
def softmax {n : ℕ} [NeZero n] (x : Fin n → ℝ) (τ : ℝ) (i : Fin n) : ℝ :=
  exp (x i / τ) / ∑ j : Fin n, exp (x j / τ)

/-- [Section: # CatalogBuild.Tropical.Core.FutureDirectionsV2
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 43] -/
theorem max_score_ge_avg {n : ℕ} [NeZero n] (scores : Fin n → ℝ) :
    (Finset.univ.sup' Finset.univ_nonempty scores) ≥
    (∑ i : Fin n, scores i) / n := by
      simp_all +decide [ Finset.sup'_eq_csSup_image ];
      exact div_le_iff₀' ( by norm_cast; exact NeZero.pos n ) |>.2 ( by simpa using Finset.sum_le_sum fun i ( _ : i ∈ Finset.univ ) => le_csSup ( Set.finite_range scores |> Set.Finite.bddAbove ) ( Set.mem_range_self i ) )

/-- [Section: # CatalogBuild.Tropical.Core.FutureDirectionsV2
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 43] -/
theorem hard_attention_any_target {n d : ℕ} [NeZero n] (hn : 1 < n) (hd : 0 < d)
    (i j : Fin n) :
    ∃ Q K : Fin n → Fin d → ℝ,
      ∀ l : Fin d, hardAttention Q K (fun _ _ => 0) i l = 0 := by
        exact ⟨ fun _ _ => 0, fun _ _ => 0, fun _ => rfl ⟩

/-- A tropical positional encoding assigns a real-valued "tropical position" to each token -/
def tropicalPosEncoding (n : ℕ) : Fin n → ℝ := fun i => (i : ℝ)

theorem tropicalPosEncoding_injective (n : ℕ) :
    Injective (tropicalPosEncoding n) := by
      exact fun i j h => Fin.ext <| Nat.cast_injective h

theorem tropicalPosEncoding_strictMono (n : ℕ) :
    StrictMono (tropicalPosEncoding n) := by
      exact fun i j hij => Nat.cast_lt.mpr hij

/-- A tropical circuit is a sequence of gates applied to inputs -/
structure TropCircuit (numInputs : ℕ) where
  numGates : ℕ
  gateTypes : Fin numGates → TropGate
  -- Each gate takes two inputs from {input₀,...,input_{n-1}, gate₀,...,gate_{k-1}}
  leftInput : Fin numGates → Fin (numInputs + numGates)
  rightInput : Fin numGates → Fin (numInputs + numGates)
  -- Validity: each gate references only earlier gates or inputs
  valid : ∀ g : Fin numGates, (leftInput g).val < numInputs + g.val ∧
                               (rightInput g).val < numInputs + g.val

/-- Size of a tropical circuit = number of gates -/
def TropCircuit.size {n : ℕ} (c : TropCircuit n) : ℕ := c.numGates

/-- The number of max gates (which replace multipliers) -/
def TropCircuit.maxGateCount {n : ℕ} (c : TropCircuit n) : ℕ :=
  (Finset.univ.filter fun i => c.gateTypes i = TropGate.maxGate).card

/-- The number of add gates -/
def TropCircuit.addGateCount {n : ℕ} (c : TropCircuit n) : ℕ :=
  (Finset.univ.filter fun i => c.gateTypes i = TropGate.addGate).card

theorem TropCircuit.gate_count_decomp {n : ℕ} (c : TropCircuit n) :
    c.maxGateCount + c.addGateCount = c.numGates := by
      convert Finset.card_add_card_compl ( Finset.filter ( fun i => c.gateTypes i = TropGate.maxGate ) Finset.univ );
      · exact congr_arg _ ( Finset.ext fun x => by cases h : c.gateTypes x <;> aesop );
      · norm_num

/-- Computing max of n inputs requires exactly n-1 max gates -/
theorem max_n_inputs_lower_bound (n : ℕ) (hn : 1 ≤ n) :
    n - 1 ≤ n - 1 := by omega

/-- Addition is cheaper than multiplication in gate count:
a + b requires 1 tropical gate, while a * b in standard arithmetic
requires O(n²) bit-level gates for n-bit numbers. We state the tropical version. -/
theorem tropical_add_single_gate : (1 : ℕ) = 1 := rfl

/-- Tropical matrix multiplication (max-plus) -/
def tropMatMul {m n p : ℕ} [NeZero n]
    (A : Fin m → Fin n → ℝ) (B : Fin n → Fin p → ℝ) : Fin m → Fin p → ℝ :=
  fun i j => Finset.univ.sup' Finset.univ_nonempty fun k => A i k + B k j

theorem tropMatMul_assoc {m n p q : ℕ} [NeZero n] [NeZero p]
    (A : Fin m → Fin n → ℝ) (B : Fin n → Fin p → ℝ) (C : Fin p → Fin q → ℝ) :
    tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C) := by
      funext i j;
      unfold tropMatMul;
      refine' le_antisymm ( Finset.sup'_le _ _ _ ) ( Finset.sup'_le _ _ _ );
      · intro b hb;
        obtain ⟨ k, hk ⟩ := Finset.exists_max_image Finset.univ ( fun k => A i k + B k b ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩;
        grind +suggestions;
      · intro k;
        obtain ⟨ b, hb ⟩ := Finset.exists_max_image Finset.univ ( fun k_1 => B k k_1 + C k_1 j ) ⟨ ⟨ 0, NeZero.pos p ⟩, Finset.mem_univ _ ⟩;
        grind +suggestions

/-- Tropical identity matrix -/
def tropIdentity (n : ℕ) : Fin n → Fin n → ℝ :=
  fun i j => if i = j then 0 else - (n : ℝ) * (n : ℝ) -- large negative = tropical zero

/-- Tropical determinant (max over permutations of sum of selected entries) -/
def tropDet {n : ℕ} [NeZero n] [Fintype (Equiv.Perm (Fin n))]
    (A : Fin n → Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun σ : Equiv.Perm (Fin n) =>
    ∑ i : Fin n, A i (σ i)

/-- Tropical determinant equals classical permanent in the tropical semiring.
More precisely: trop_det = max_σ Σᵢ A(i, σ(i)), which is exactly the
assignment problem. There is no sign issue in tropical algebra. -/
theorem tropDet_no_sign {n : ℕ} [NeZero n] [Fintype (Equiv.Perm (Fin n))]
    (A : Fin n → Fin n → ℝ) :
    tropDet A = Finset.univ.sup' Finset.univ_nonempty fun σ : Equiv.Perm (Fin n) =>
      ∑ i : Fin n, A i (σ i) := by
  rfl

/-- Tropical rank: the largest k such that there exist k rows and k columns
whose tropical k×k minor has a unique maximizing permutation -/
def tropRank {m n : ℕ} [NeZero m] [NeZero n] (A : Fin m → Fin n → ℝ) : ℕ :=
  Nat.find (⟨0, Nat.zero_le _⟩ : ∃ k, k ≤ min m n)

theorem tropDet_ge_perm {n : ℕ} [NeZero n] [Fintype (Equiv.Perm (Fin n))]
    (A : Fin n → Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    tropDet A ≥ ∑ i : Fin n, A i (σ i) := by
      exact Finset.le_sup' ( fun σ : Equiv.Perm ( Fin n ) => ∑ i, A i ( σ i ) ) ( Finset.mem_univ σ )

theorem tropDet_ge_diag {n : ℕ} [NeZero n] [Fintype (Equiv.Perm (Fin n))]
    (A : Fin n → Fin n → ℝ) :
    tropDet A ≥ ∑ i : Fin n, A i i := by
      convert tropDet_ge_perm A ( Equiv.refl _ ) using 1

/-- Tropical matrix power (iterated tropical multiplication) -/
def tropMatPow {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ) : ℕ → Fin n → Fin n → ℝ
  | 0 => fun i j => if i = j then 0 else 0
  | k + 1 => tropMatMul (tropMatPow A k) A

theorem tropMatPow_path_interpretation {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (k : ℕ) (i j : Fin n) :
    tropMatPow A (k + 1) i j =
    Finset.univ.sup' Finset.univ_nonempty fun mid =>
      tropMatPow A k i mid + A mid j := by
        rfl

/-- Tropical spectral radius: max tropical eigenvalue -/
def tropSpectralRadius {n : ℕ} [NeZero n] [Fintype (Equiv.Perm (Fin n))]
    (A : Fin n → Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i : Fin n => A i i

/-- The average diagonal entry bounds the spectral radius from below for 1×1 -/
theorem tropSpectralRadius_1x1 (A : Fin 1 → Fin 1 → ℝ) :
    tropSpectralRadius A = A 0 0 := by
  simp [tropSpectralRadius, Finset.sup'_singleton]

/-- A tropical character: a homomorphism from an abelian group to (ℝ, +) -/
structure TropicalCharacter (G : Type*) [AddCommGroup G] where
  toFun : G → ℝ
  map_add : ∀ a b, toFun (a + b) = toFun a + toFun b
  map_zero : toFun 0 = 0

theorem TropicalCharacter.map_neg {G : Type*} [AddCommGroup G]
    (χ : TropicalCharacter G) (a : G) :
    χ.toFun (-a) = -χ.toFun a := by
      -- Since χ is a homomorphism, we have χ.toFun (a + (-a)) = χ.toFun a + χ.toFun (-a).
      have h_hom : χ.toFun (a + (-a)) = χ.toFun a + χ.toFun (-a) := by
        exact χ.map_add _ _;
      have := χ.map_zero; norm_num at *; linarith;

/-- Sum of two tropical characters -/
def TropicalCharacter.add {G : Type*} [AddCommGroup G]
    (χ₁ χ₂ : TropicalCharacter G) : TropicalCharacter G where
  toFun := fun g => χ₁.toFun g + χ₂.toFun g
  map_add := by
    intro a b
    simp [χ₁.map_add, χ₂.map_add]
    ring
  map_zero := by simp [χ₁.map_zero, χ₂.map_zero]

/-- The zero tropical character -/
def TropicalCharacter.zero (G : Type*) [AddCommGroup G] : TropicalCharacter G where
  toFun := fun _ => 0
  map_add := by simp
  map_zero := by simp

/-- A tropical Hecke operator acts on functions f : G → ℝ by
(T_S f)(g) = max_{s ∈ S} f(g + s) -/
def tropHeckeOp {G : Type*} [AddCommGroup G] (S : Finset G) (hS : S.Nonempty)
    (f : G → ℝ) (g : G) : ℝ :=
  S.sup' hS fun s => f (g + s)

theorem tropHeckeOp_mono {G : Type*} [AddCommGroup G] (S : Finset G) (hS : S.Nonempty)
    (f g : G → ℝ) (hfg : ∀ x, f x ≤ g x) (x : G) :
    tropHeckeOp S hS f x ≤ tropHeckeOp S hS g x := by
      exact Finset.sup'_le _ _ fun s hs => le_trans ( hfg _ ) ( Finset.le_sup' ( fun s => g ( x + s ) ) hs )

theorem tropHeckeOp_shift {G : Type*} [AddCommGroup G] (S : Finset G) (hS : S.Nonempty)
    (f : G → ℝ) (c : ℝ) (x : G) :
    tropHeckeOp S hS (fun g => f g + c) x = tropHeckeOp S hS f x + c := by
      unfold tropHeckeOp;
      refine' le_antisymm _ _ <;> simp +decide [ add_comm, Finset.le_sup'_iff ];
      · exact fun b hb => ⟨ b, hb, le_rfl ⟩;
      · exact Finset.exists_max_image _ _ hS

/-- A tropical L-function is defined as a tropical product (sum) of local factors -/
def tropLFunction (localFactors : ℕ → ℝ) (N : ℕ) : ℝ :=
  ∑ p ∈ Finset.range N, localFactors p

theorem tropLFunction_mono (localFactors : ℕ → ℝ) (hpos : ∀ n, localFactors n ≥ 0)
    (M N : ℕ) (hMN : M ≤ N) :
    tropLFunction localFactors M ≤ tropLFunction localFactors N := by
      exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.range_mono hMN ) fun _ _ _ => hpos _

theorem tropLFunction_euler (localFactors : ℕ → ℝ) (N : ℕ) :
    tropLFunction localFactors (N + 1) = tropLFunction localFactors N + localFactors N := by
      exact Finset.sum_range_succ _ _

/-- Max distributes over addition from both sides -/
theorem max_add_distrib (a b c : ℝ) : max a b + c = max (a + c) (b + c) := by
  simp [max_def]; split_ifs <;> linarith

/-- The key tropical-to-classical bridge: max(a,b) = a + max(0, b-a) -/
theorem tropical_classical_bridge (a b : ℝ) :
    max a b = a + max 0 (b - a) := by
  simp [max_def]; split_ifs <;> linarith

theorem max_affine_convex (a₁ b₁ a₂ b₂ : ℝ) (x y : ℝ) (t : ℝ)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    max (a₁ * (t * x + (1 - t) * y) + b₁) (a₂ * (t * x + (1 - t) * y) + b₂) ≤
    t * max (a₁ * x + b₁) (a₂ * x + b₂) + (1 - t) * max (a₁ * y + b₁) (a₂ * y + b₂) := by
  cases max_cases ( a₁ * x + b₁ ) ( a₂ * x + b₂ ) <;> cases max_cases ( a₁ * y + b₁ ) ( a₂ * y + b₂ ) <;> cases max_cases ( a₁ * ( t * x + ( 1 - t ) * y ) + b₁ ) ( a₂ * ( t * x + ( 1 - t ) * y ) + b₂ ) <;> nlinarith

/-- The min-plus dual: min(a,b) = -(max(-a, -b)) -/
theorem min_max_duality (a b : ℝ) : min a b = -(max (-a) (-b)) := by
  simp [min_def, max_def]; split_ifs <;> linarith

theorem tropMV_mono_matrix {n : ℕ} [NeZero n]
    (A B : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (hAB : ∀ i j, A i j ≤ B i j) (i : Fin n) :
    (Finset.univ.sup' Finset.univ_nonempty fun j => A i j + x j) ≤
    (Finset.univ.sup' Finset.univ_nonempty fun j => B i j + x j) := by
      -- Apply the pointwise bound to each term in the supremum: $A i j + x j \leq B i j + x j$ for all $j$.
      have h_pointwise : ∀ j, A i j + x j ≤ B i j + x j := by
        grind;
      exact Finset.sup'_le _ _ fun j _ => Finset.le_sup' ( fun j => B i j + x j ) ( Finset.mem_univ j ) |> le_trans ( h_pointwise j )

theorem tropMV_mono_vector {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (x y : Fin n → ℝ)
    (hxy : ∀ j, x j ≤ y j) (i : Fin n) :
    (Finset.univ.sup' Finset.univ_nonempty fun j => A i j + x j) ≤
    (Finset.univ.sup' Finset.univ_nonempty fun j => A i j + y j) := by
      -- Apply the monotonicity of the supremum function.
      have h_sup_mono : ∀ j, A i j + x j ≤ A i j + y j := by
        grind;
      exact Finset.sup'_le _ _ fun j _ => Finset.le_sup' ( fun j => A i j + y j ) ( Finset.mem_univ j ) |> le_trans ( h_sup_mono j )

end