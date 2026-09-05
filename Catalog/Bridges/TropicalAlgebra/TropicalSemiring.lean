import Mathlib

/-! # CatalogBuild.Tropical.Core.TropicalSemiring

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 14
-/

noncomputable section

/-- ReLU.  (Supplied here: the auto-generated file used `relu` and `logSumExp`
without carrying their definitions along.) -/
def relu (x : ℝ) : ℝ := max x 0

/-- The log-sum-exp of a finite family. -/
def logSumExp {ι : Type*} (s : Finset ι) (f : ι → ℝ) : ℝ :=
  Real.log (∑ j ∈ s, Real.exp (f j))

/-- ReLU is definitionally max(x, 0) -/
theorem relu_eq_max (x : ℝ) : relu x = max x 0 := rfl

/-- [Section: # CatalogBuild.Tropical.Core.TropicalSemiring
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 14] -/
theorem relu_relu (x : ℝ) : relu (relu x) = relu x := by
  unfold relu; aesop;

/-- [Section: # CatalogBuild.Tropical.Core.TropicalSemiring
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 14] -/
theorem le_logSumExp {ι : Type*} {s : Finset ι} {f : ι → ℝ} {i : ι}
    (hi : i ∈ s) : f i ≤ logSumExp s f := by
  exact Real.le_log_iff_exp_le ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ i, hi ⟩ ) |>.2 ( Finset.single_le_sum ( fun j _ => Real.exp_nonneg ( f j ) ) hi )

theorem logSumExp_le_sup_add_log {ι : Type*} [DecidableEq ι] {s : Finset ι}
    {f : ι → ℝ} (hs : s.Nonempty) :
    logSumExp s f ≤ s.sup' hs f + Real.log (s.card : ℝ) := by
  -- Applying the logarithm to both sides of the inequality $\sum_{j \in s} \exp(f j) \leq \text{card}(s) \cdot \exp(\sup(f))$.
  have h_log : Real.log (∑ j ∈ s, Real.exp (f j)) ≤ Real.log (↑(Finset.card s) * Real.exp (s.sup' hs f)) := by
    gcongr;
    -- Since each term in the sum is less than or equal to the supremum, we can bound the sum by multiplying the supremum by the number of terms.
    have h_le_sup : ∀ j ∈ s, Real.exp (f j) ≤ Real.exp (s.sup' hs f) := by
      exact fun j hj => Real.exp_le_exp.2 ( Finset.le_sup' f hj );
    simpa using Finset.sum_le_sum h_le_sup;
  convert h_log using 1 ; rw [ Real.log_mul ( by aesop ) ( by positivity ), Real.log_exp ] ; ring

/-- Softmax function for a single component -/
def softmax_component {n : ℕ} (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (x i) / ∑ j, Real.exp (x j)

theorem softmax_sum_eq_one {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    ∑ i, softmax_component x i = 1 := by
  unfold softmax_component; rw [ ← Finset.sum_div _ _ _, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ ↦ Real.exp_pos _ ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩ ] ;

theorem softmax_shift_invariant {n : ℕ} (x : Fin n → ℝ) (c : ℝ) (i : Fin n) :
    softmax_component (fun j => x j + c) i = softmax_component x i := by
  unfold softmax_component; ring;
  simp +decide [ Real.exp_add, mul_assoc, Finset.mul_sum _ _ _, mul_comm, mul_left_comm, ne_of_gt ( Real.exp_pos _ ) ];
  simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, mul_comm, ne_of_gt ( Real.exp_pos _ ) ]

/-- exp preserves addition → multiplication -/
theorem exp_add_eq_mul (x y : ℝ) :
    Real.exp (x + y) = Real.exp x * Real.exp y :=
  Real.exp_add x y

theorem exp_max_eq_max (x y : ℝ) :
    Real.exp (max x y) = max (Real.exp x) (Real.exp y) := by
  -- Since the exponential function is strictly increasing, we have `exp (max x y) = max (exp x) (exp y)`.
  cases max_cases x y <;> simp [*, Real.exp_le_exp];
  linarith

/-- exp is strictly monotone -/
theorem exp_strictMono : StrictMono Real.exp :=
  Real.exp_strictMono

/-- exp is positive -/
theorem exp_pos_forall (x : ℝ) : 0 < Real.exp x :=
  Real.exp_pos x

theorem max_affine_is_relu_computable (a b c d : ℝ) :
    ∀ x : ℝ, max (a * x + b) (c * x + d) =
      relu (a * x + b - (c * x + d)) + (c * x + d) := by
  -- By definition of max, we know that max(u, v) = u if u ≥ v and max(u, v) = v if v > u.
  intro x
  simp [max_def, relu];
  split_ifs <;> linarith

theorem relu_as_max_affine (x : ℝ) : relu x = max (1 * x + 0) (0 * x + 0) := by
  simp +zetaDelta at *;
  rfl

theorem monotone_preserves_max {f : ℝ → ℝ} (hf : Monotone f) (x y : ℝ) :
    f (max x y) = max (f x) (f y) := by
  cases le_total x y <;> aesop