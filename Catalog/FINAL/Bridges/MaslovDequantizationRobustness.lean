import Mathlib
import Catalog.Tropical.NeuralNetworks.TropicalDegreeRobustness

/-! # Maslov Dequantization Isometry & Robustness Transfer

This file establishes the formal bridge between EML (Emergent Meta-Language)
classifiers, their tropical limits, and certified adversarial robustness.

The main result (`maslov_dequantization_isometry`) proves:
1. The Maslov map is a semiring homomorphism modulo ε·log 2
2. Pointwise dequantization error is bounded by ε·log d
3. Lipschitz constants are preserved exactly through dequantization
4. Certified robustness transfers from tropical to EML classifiers

The proof technique — bounding log-sum-exp via softmax convex combinations —
establishes the first formal robustness certificate for EML neural classifiers
by isometric transfer from tropical geometry.
-/

noncomputable section

open Real Finset BigOperators

variable {n : ℕ}

/-! ## Definitions -/

/-- EML log-plus semiring addition on scalar functions. This is the smooth surrogate
    for tropical max induced by the EML exp-log-logistic bridge. -/
noncomputable def emlAdd (ε : ℝ) (f g : (Fin n → ℝ) → ℝ) : (Fin n → ℝ) → ℝ :=
  fun x ↦ ε * Real.log (Real.exp (f x / ε) + Real.exp (g x / ε))

/-- Tropical max-plus addition on scalar functions. -/
noncomputable def tropAdd (f g : (Fin n → ℝ) → ℝ) : (Fin n → ℝ) → ℝ :=
  fun x ↦ max (f x) (g x)

/-- An EML-approximated neural classifier with m classes. Each class score is a
    width-d log-sum-exp of affine functions φ_{k,i}(x) = a_{k,i} + ⟨w_{k,i}, x⟩. -/
noncomputable def emlClassifier {n m d : ℕ} (Φ : Fin m → Fin d → (Fin n → ℝ) → ℝ) (ε : ℝ) :
    (Fin n → ℝ) → (Fin m → ℝ) :=
  fun x k ↦ ε * Real.log (∑ i : Fin d, Real.exp (Φ k i x / ε))

/-- The tropicalization of the EML classifier (the Maslov limit as ε → 0). -/
noncomputable def tropClassifier {n m d : ℕ} (Φ : Fin m → Fin d → (Fin n → ℝ) → ℝ) :
    (Fin n → ℝ) → (Fin m → ℝ) :=
  fun x k ↦ ⨆ i : Fin d, Φ k i x

/-! ## Part I: Binary Logsumexp Bounds -/

/-
Binary logsumexp upper bound: log(exp a + exp b) ≤ max a b + log 2.
-/
lemma logsumexp_binary_upper (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 := by
  rw [ Real.log_le_iff_le_exp ( by positivity ) ];
  rw [ Real.exp_add, Real.exp_log ] <;> cases max_cases a b <;> nlinarith [ Real.exp_pos a, Real.exp_pos b, Real.exp_le_exp.2 ( le_max_left a b ), Real.exp_le_exp.2 ( le_max_right a b ) ]

/-
Binary logsumexp lower bound: max a b ≤ log(exp a + exp b).
-/
lemma logsumexp_binary_lower (a b : ℝ) :
    max a b ≤ Real.log (Real.exp a + Real.exp b) := by
  rw [ max_le_iff ];
  exact ⟨ by rw [ Real.le_log_iff_exp_le ( by positivity ) ] ; linarith [ Real.exp_pos a, Real.exp_pos b ], by rw [ Real.le_log_iff_exp_le ( by positivity ) ] ; linarith [ Real.exp_pos a, Real.exp_pos b ] ⟩

/-
**Part (i):** EML addition approximates tropical addition within ε·log 2.
-/
lemma emlAdd_tropAdd_bound (ε : ℝ) (hε : 0 < ε) (f g : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ) :
    |emlAdd ε f g x - tropAdd f g x| ≤ ε * Real.log 2 := by
  -- Apply the bounds for log-sum-exp to show the inequalities
  have h_bounds : Real.log (Real.exp (f x / ε) + Real.exp (g x / ε)) ≤ max (f x / ε) (g x / ε) + Real.log 2 ∧ max (f x / ε) (g x / ε) ≤ Real.log (Real.exp (f x / ε) + Real.exp (g x / ε)) := by
    exact ⟨ logsumexp_binary_upper _ _, logsumexp_binary_lower _ _ ⟩;
  unfold emlAdd tropAdd;
  rw [ abs_le ] ; constructor <;> cases max_cases ( f x ) ( g x ) <;> cases max_cases ( f x / ε ) ( g x / ε ) <;> nlinarith [ mul_div_cancel₀ ( f x ) hε.ne', mul_div_cancel₀ ( g x ) hε.ne' ] ;

/-! ## Part II: d-term Logsumexp Bounds -/

/-
d-term logsumexp lower bound: the iSup is bounded by ε·log-sum-exp.
-/
lemma logsumexp_d_lower {d : ℕ} [NeZero d] (z : Fin d → ℝ) (ε : ℝ) (hε : 0 < ε) :
    (⨆ i : Fin d, z i) ≤ ε * Real.log (∑ i : Fin d, Real.exp (z i / ε)) := by
  have h_logsumexp : ∀ i, z i / ε ≤ Real.log (∑ i, Real.exp (z i / ε)) := by
    exact fun i => le_trans ( by rw [ Real.log_exp ] ) ( Real.log_le_log ( by positivity ) ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( z i / ε ) ) ( Finset.mem_univ i ) ) );
  exact ciSup_le fun i => by have := h_logsumexp i; rwa [ div_le_iff₀' hε ] at this;

/-
d-term logsumexp upper bound: ε·log-sum-exp is bounded by iSup + ε·log d.
-/
lemma logsumexp_d_upper {d : ℕ} [NeZero d] (z : Fin d → ℝ) (ε : ℝ) (hε : 0 < ε) :
    ε * Real.log (∑ i : Fin d, Real.exp (z i / ε)) ≤ (⨆ i : Fin d, z i) + ε * Real.log d := by
  -- Each z i ≤ ⨆ j, z j (by le_ciSup with Finite.bddAbove_range). So exp(z i / ε) ≤ exp((⨆ j, z j) / ε) by Real.exp_le_exp.2 with div_le_div_right hε.
  have h_exp_le : ∀ i, Real.exp (z i / ε) ≤ Real.exp ((⨆ j, z j) / ε) := by
    exact fun i => Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( le_ciSup ( Finite.bddAbove_range z ) i ) hε.le );
  have h_sum_le : ∑ i, Real.exp (z i / ε) ≤ d * Real.exp ((⨆ j, z j) / ε) := by
    exact le_trans ( Finset.sum_le_sum fun _ _ => h_exp_le _ ) ( by norm_num );
  have := Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) h_sum_le;
  rw [ Real.log_mul ( by norm_cast; exact NeZero.ne d ) ( by positivity ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( ⨆ j, z j ) hε.ne' ]

/-
**Part (ii):** EML classifier approximates tropical classifier within ε·log d.
-/
lemma emlClassifier_tropClassifier_bound {n m d : ℕ} [NeZero d]
    (Φ : Fin m → Fin d → (Fin n → ℝ) → ℝ) (ε : ℝ) (hε : 0 < ε)
    (x : Fin n → ℝ) (k : Fin m) :
    |emlClassifier Φ ε x k - tropClassifier Φ x k| ≤ ε * Real.log d := by
  refine' abs_sub_le_iff.mpr _;
  constructor <;> unfold emlClassifier tropClassifier;
  · convert sub_le_iff_le_add'.mpr ( logsumexp_d_upper ( fun i => Φ k i x ) ε hε ) using 1;
  · have := logsumexp_d_upper ( fun i => Φ k i x ) ε hε;
    linarith [ show ε * Real.log ( ∑ i, Real.exp ( Φ k i x / ε ) ) ≥ ( ⨆ i, Φ k i x ) from logsumexp_d_lower ( fun i => Φ k i x ) ε hε ]

/-! ## Part III: Lipschitz Preservation -/

/-
The L∞ norm is symmetric: ‖-x‖∞ = ‖x‖∞.
-/
lemma linftyNorm_neg_eq {m : ℕ} (x : Fin m → ℝ) : linftyNorm (-x) = linftyNorm x := by
  unfold linftyNorm; aesop;

/-
The L∞ norm is symmetric in subtraction: ‖z - w‖∞ = ‖w - z‖∞.
-/
lemma linftyNorm_sub_comm {m : ℕ} (z w : Fin m → ℝ) :
    linftyNorm (z - w) = linftyNorm (w - z) := by
  unfold linftyNorm;
  simp +decide [ abs_sub_comm ]

/-
Key ratio bound: ∑ exp(z_i/ε) ≤ exp(‖z-w‖∞/ε) · ∑ exp(w_i/ε).
    This is the core of the softmax convex combination argument.
-/
lemma logsumexp_ratio_bound {d : ℕ} [NeZero d] (ε : ℝ) (hε : 0 < ε)
    (z w : Fin d → ℝ) :
    ∑ i : Fin d, Real.exp (z i / ε) ≤
    Real.exp (linftyNorm (z - w) / ε) * ∑ i : Fin d, Real.exp (w i / ε) := by
  rw [ Finset.mul_sum _ _ _ ];
  gcongr;
  rw [ ← Real.exp_add ] ; ring_nf;
  exact Real.exp_le_exp.mpr ( by nlinarith [ abs_le.mp ( show |z ‹_› - w ‹_›| ≤ linftyNorm ( z - w ) from by simpa using abs_le_linftyNorm ( z - w ) ‹_› ), inv_pos.mpr hε ] )

/-
The scalar log-sum-exp function `ε·log(∑ exp(z_i/ε))` is 1-Lipschitz
    w.r.t. the L∞ norm. This is the key technical lemma for exact Lipschitz
    preservation through dequantization.
-/
lemma logsumexp_one_lipschitz {d : ℕ} [NeZero d] (ε : ℝ) (hε : 0 < ε)
    (z w : Fin d → ℝ) :
    |ε * Real.log (∑ i, Real.exp (z i / ε)) -
     ε * Real.log (∑ i, Real.exp (w i / ε))| ≤ linftyNorm (z - w) := by
  rw [ abs_le ];
  constructor;
  · have := logsumexp_ratio_bound ε hε w z;
    have := Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) this;
    rw [ Real.log_mul ( by positivity ) ( by exact ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ), Real.log_exp ] at this ; rw [ show linftyNorm ( w - z ) = linftyNorm ( z - w ) by rw [ linftyNorm_sub_comm ] ] at this ; nlinarith [ mul_div_cancel₀ ( linftyNorm ( z - w ) ) hε.ne' ];
  · have := logsumexp_ratio_bound ε hε z w;
    have := Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) this;
    rw [ Real.log_mul ( by positivity ) ( by exact ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( linftyNorm ( z - w ) ) hε.ne' ]

/-
The vector of evaluations `(Φ k 0 x, ..., Φ k (d-1) x)` maps L-Lipschitz
    component functions to an L-Lipschitz vector function in L∞.
-/
lemma phi_vector_lipschitz {n m d : ℕ} [NeZero d] [Nonempty (Fin n)]
    (Φ : Fin m → Fin d → (Fin n → ℝ) → ℝ)
    (L : ℝ) (_hL : 0 < L) (hLip : ∀ k i, IsLinftyLipschitz (Φ k i) L)
    (k : Fin m) (x y : Fin n → ℝ) :
    linftyNorm (fun i ↦ Φ k i x - Φ k i y) ≤ L * linftyNorm (x - y) := by
  convert ciSup_le fun i => ?_ using 1;
  · exact ⟨ 0 ⟩;
  · exact hLip k i |>.2 x y

/-
**Part (iii):** Each coordinate of the EML classifier is L-Lipschitz.
    The Lipschitz constant is preserved exactly — no degree factor d appears.
-/
lemma emlClassifier_lipschitz {n m d : ℕ} [NeZero d] [Nonempty (Fin n)]
    (Φ : Fin m → Fin d → (Fin n → ℝ) → ℝ) (ε : ℝ) (hε : 0 < ε)
    (L : ℝ) (hL : 0 < L) (hLip : ∀ k i, IsLinftyLipschitz (Φ k i) L)
    (k : Fin m) :
    IsLinftyLipschitz (fun x ↦ emlClassifier Φ ε x k) L := by
  refine' ⟨ hL.le, fun x y => _ ⟩;
  -- Apply the logsumexp_one_lipschitz lemma to the vectors z and w.
  have h_logsumexp : |ε * Real.log (∑ i, Real.exp (Φ k i x / ε)) - ε * Real.log (∑ i, Real.exp (Φ k i y / ε))| ≤ linftyNorm (fun i => Φ k i x - Φ k i y) := by
    convert logsumexp_one_lipschitz ε hε ( fun i => Φ k i x ) ( fun i => Φ k i y ) using 1;
  exact h_logsumexp.trans ( phi_vector_lipschitz Φ L hL hLip k x y )

/-! ## Part IV: Robustness Transfer -/

/-
CertifiedRobust is monotone: smaller radius is easier to certify.
-/
lemma CertifiedRobust_mono {n m : ℕ} {f : (Fin n → ℝ) → (Fin m → ℝ)}
    {x : Fin n → ℝ} {y : Fin m} {r r' : ℝ}
    (h : CertifiedRobust f x y r) (hr : r' ≤ r) :
    CertifiedRobust f x y r' := by
  exact fun δ hδ j hj => h δ ( lt_of_lt_of_le hδ hr ) j hj

/-
The classMargin is stable under pointwise bounded perturbation:
    if |f(x)_k - g(x)_k| ≤ δ for all k, then classMargin f ≥ classMargin g - 2δ.
-/
lemma classMargin_approx_bound {n m : ℕ}
    (f g : (Fin n → ℝ) → (Fin m → ℝ))
    (x : Fin n → ℝ) (y : Fin m) (δ : ℝ)
    (hbound : ∀ k : Fin m, |f x k - g x k| ≤ δ) :
    classMargin g x y - 2 * δ ≤ classMargin f x y := by
  by_contra! h_contra;
  obtain ⟨j, hj⟩ : ∃ j : Fin m, j ≠ y ∧ f x y - f x j < classMargin g x y - 2 * δ := by
    unfold classMargin at *;
    rcases m with ( _ | _ | m ) <;> norm_num at *;
    · exact Fin.elim0 y;
    · grind;
    · have := exists_lt_of_csInf_lt ( show Set.Nonempty ( Set.range fun j : { j : Fin ( m + 1 + 1 ) // j ≠ y } => f x y - f x j ) from ⟨ _, ⟨ ⟨ y + 1, by simp +decide ⟩, rfl ⟩ ⟩ ) h_contra;
      grind +qlia;
  have h_ineq : g x y - g x j ≥ classMargin g x y := by
    refine' ciInf_le_of_le _ _ _;
    exacts [ Set.finite_range _ |> Set.Finite.bddBelow, ⟨ j, hj.1 ⟩, rfl.le ];
  linarith [ abs_le.mp ( hbound y ), abs_le.mp ( hbound j ) ]

/-
If the classMargin is at least γ > 0 and each component is L-Lipschitz,
    then the classifier is certified robust with radius γ/(2L).
-/
lemma certified_robust_from_margin_bound {n m : ℕ}
    (f : (Fin n → ℝ) → (Fin m → ℝ))
    (L : ℝ) (hL : 0 < L)
    (hLip : ∀ k : Fin m, IsLinftyLipschitz (fun x => f x k) L)
    (x : Fin n → ℝ) (y_true : Fin m)
    (γ : ℝ) (hγ : 0 < γ)
    (hmargin : γ ≤ classMargin f x y_true) :
    CertifiedRobust f x y_true (γ / (2 * L)) := by
  apply CertifiedRobust_mono;
  exact margin_preservation f L hL hLip x y_true ( by linarith );
  gcongr

/-! ## Main Theorem -/

/-
**Maslov Dequantization Isometry & Robustness Transfer — Main Theorem.**
    Let C_ε be an EML classifier with m ≥ 2 classes, each class score generated from
    d affine pieces. Let C_0 be its tropicalization. Assume every affine piece is
    L-Lipschitz w.r.t. the L∞ norm with L > 0. Then:
    (i)   The Maslov map is a semiring homomorphism modulo ε·log 2:
          ∀ f g x, |emlAdd ε f g x - tropAdd f g x| ≤ ε * Real.log 2.
    (ii)  The pointwise dequantization error for the classifier is bounded by ε·log d:
          ∀ k, |C_ε(x)_k - C_0(x)_k| ≤ ε * Real.log d.
    (iii) Lipschitz constant is preserved exactly: every coordinate of C_ε is L-Lipschitz.
    (iv)  If the tropical margin exceeds γ + 2ε·log d, then the EML classifier inherits
          the certified L∞ robustness radius r* = γ / (2L).

    This establishes the first formal robustness certificate for emergent meta-language
    (EML) neural classifiers by isometric transfer from tropical geometry.
-/
theorem maslov_dequantization_isometry
    {n m d : ℕ} [NeZero d] [Nonempty (Fin n)] (hm : 2 ≤ m)
    (Φ : Fin m → Fin d → (Fin n → ℝ) → ℝ)
    (hΦ : ∀ k i, ∃ (a : ℝ) (w : Fin n → ℝ), Φ k i = fun x ↦ a + ∑ j, w j * x j)
    (ε : ℝ) (hε : 0 < ε)
    (L : ℝ) (hL : 0 < L)
    (hLip : ∀ k i, IsLinftyLipschitz (Φ k i) L)
    (x : Fin n → ℝ) (y_true : Fin m)
    (γ : ℝ) (hγ : 0 < γ)
    (hmargin : γ + 2 * ε * Real.log d ≤ classMargin (tropClassifier Φ) x y_true) :
    (∀ (f g : (Fin n → ℝ) → ℝ) (x' : Fin n → ℝ),
      |emlAdd ε f g x' - tropAdd f g x'| ≤ ε * Real.log 2) ∧
    (∀ k : Fin m, |emlClassifier Φ ε x k - tropClassifier Φ x k| ≤ ε * Real.log d) ∧
    (∀ k : Fin m, IsLinftyLipschitz (fun x ↦ emlClassifier Φ ε x k) L) ∧
    CertifiedRobust (emlClassifier Φ ε) x y_true (γ / (2 * L)) := by
  refine ⟨fun f g x' => emlAdd_tropAdd_bound ε hε f g x',
          fun k => emlClassifier_tropClassifier_bound Φ ε hε x k,
          fun k => emlClassifier_lipschitz Φ ε hε L hL hLip k, ?_⟩
  apply certified_robust_from_margin_bound _ L hL
    (fun k => emlClassifier_lipschitz Φ ε hε L hL hLip k) x y_true γ hγ
  calc γ = γ + 2 * ε * Real.log ↑d - 2 * (ε * Real.log ↑d) := by ring
    _ ≤ classMargin (tropClassifier Φ) x y_true - 2 * (ε * Real.log ↑d) := by linarith
    _ ≤ classMargin (emlClassifier Φ ε) x y_true :=
        classMargin_approx_bound _ _ x y_true _ (fun k => emlClassifier_tropClassifier_bound Φ ε hε x k)

end