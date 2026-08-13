import Physics.EntanglementMonotone.PartialTranspose

/-!
# Logarithmic negativity is an entanglement monotone

Building on the trace norm theory of `Physics.EntanglementMonotone.TraceNorm` and on the
partial transpose of `Physics.EntanglementMonotone.PartialTranspose`, this file defines

* the **negativity** `N(ρ) = (‖Γ ρ‖₁ - 1) / 2`, and
* the **logarithmic negativity** `E_N(ρ) = log ‖Γ ρ‖₁`,

and proves the properties that make `E_N` an entanglement monotone:

* `EntMonotone.logNeg_nonneg`      : `E_N ≥ 0` on states;
* `EntMonotone.logNeg_eq_zero_of_isPPT` : `E_N` vanishes on PPT states, in particular on
  product states (`EntMonotone.logNeg_kronecker`);
* `EntMonotone.logNeg_mono`        : `E_N` does not increase under PPT operations, a class
  that contains all local operations (`EntMonotone.isPPTOperation_local`);
* `EntMonotone.logNeg_strong_mono` : the *strong* (selective) monotonicity
  `∑ᵢ pᵢ E_N(ρᵢ) ≤ E_N(ρ)` for a PPT instrument with outcome probabilities `pᵢ`;
* `EntMonotone.negativity_convex`  : convexity of the negativity;
* `EntMonotone.logNeg_maxEntangled`: `E_N` of the maximally entangled state of local
  dimension `d` equals `log d`, hence `E_N > 0` whenever `d ≥ 2`.  This last point shows the
  monotone is *nontrivial*: it strictly separates maximally entangled states from all PPT
  (in particular all separable) states.
-/

namespace EntMonotone

open Matrix Kronecker ComplexOrder
open scoped MatrixOrder

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-! ## States, negativity and logarithmic negativity -/

/-- A density matrix: positive semidefinite with unit trace. -/
structure IsState (ρ : Matrix (α × β) (α × β) ℂ) : Prop where
  pos : ρ.PosSemidef
  trace_one : ρ.trace = 1

/-- The negativity `N(ρ) = (‖Γ ρ‖₁ - 1)/2`. -/
noncomputable def negativity (ρ : Matrix (α × β) (α × β) ℂ) : ℝ :=
  (traceNorm (ptrans ρ) - 1) / 2

/-- The logarithmic negativity `E_N(ρ) = log ‖Γ ρ‖₁`. -/
noncomputable def logNeg (ρ : Matrix (α × β) (α × β) ℂ) : ℝ :=
  Real.log (traceNorm (ptrans ρ))

/-- For a state the trace norm of the partial transpose is at least `1`. -/
theorem one_le_traceNorm_ptrans {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    1 ≤ traceNorm (ptrans ρ) := by
  have h := re_trace_le_traceNorm (ptrans_isHermitian hρ.pos.isHermitian)
  rwa [trace_ptrans, hρ.trace_one, Complex.one_re] at h

theorem traceNorm_ptrans_pos {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    0 < traceNorm (ptrans ρ) :=
  lt_of_lt_of_le zero_lt_one (one_le_traceNorm_ptrans hρ)

/-- The logarithmic negativity of a state is nonnegative. -/
theorem logNeg_nonneg {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) : 0 ≤ logNeg ρ :=
  Real.log_nonneg (one_le_traceNorm_ptrans hρ)

/-- The negativity of a state is nonnegative. -/
theorem negativity_nonneg {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) : 0 ≤ negativity ρ := by
  have := one_le_traceNorm_ptrans hρ
  unfold negativity
  linarith

/-- On PPT states both the negativity and the logarithmic negativity vanish. -/
theorem traceNorm_ptrans_of_isPPT {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ)
    (h : IsPPT ρ) : traceNorm (ptrans ρ) = 1 := by
  rw [traceNorm_posSemidef h, trace_ptrans, hρ.trace_one, Complex.one_re]

theorem logNeg_eq_zero_of_isPPT {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ)
    (h : IsPPT ρ) : logNeg ρ = 0 := by
  rw [logNeg, traceNorm_ptrans_of_isPPT hρ h, Real.log_one]

theorem negativity_eq_zero_of_isPPT {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ)
    (h : IsPPT ρ) : negativity ρ = 0 := by
  rw [negativity, traceNorm_ptrans_of_isPPT hρ h]; ring

/-- Product states have vanishing logarithmic negativity. -/
theorem logNeg_kronecker {A : Matrix α α ℂ} {B : Matrix β β ℂ}
    (hA : A.PosSemidef) (hB : B.PosSemidef) (hstate : IsState (A ⊗ₖ B)) :
    logNeg (A ⊗ₖ B) = 0 :=
  logNeg_eq_zero_of_isPPT hstate (isPPT_kronecker hA hB)

/-! ## PPT operations and monotonicity -/

/-- A **PPT operation**: a positive, trace preserving, subtraction respecting map which
moreover stays positive after conjugation by the partial transpose.  Local operations
(conjugation by `A ⊗ B`) are of this kind, see `isPPTOperation_local`; so are all LOCC
protocols, since the class of PPT operations is closed under composition and convex
combination and contains local channels and classical communication. -/
structure IsPPTOperation (Λ : Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ) : Prop where
  map_sub : ∀ A B, Λ (A - B) = Λ A - Λ B
  map_pos : ∀ A, A.PosSemidef → (Λ A).PosSemidef
  map_trace : ∀ A, (Λ A).trace = A.trace
  ppt_pos : ∀ A, (ptrans A).PosSemidef → (ptrans (Λ A)).PosSemidef

omit [DecidableEq α] [DecidableEq β] in
/-- A PPT operation maps states to states. -/
theorem IsPPTOperation.isState {Λ : Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ}
    (hΛ : IsPPTOperation Λ) {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) : IsState (Λ ρ) :=
  ⟨hΛ.map_pos ρ hρ.pos, by rw [hΛ.map_trace, hρ.trace_one]⟩

omit [DecidableEq α] [DecidableEq β] in
/-- The conjugated map `Γ ∘ Λ ∘ Γ` of a PPT operation is positive and trace preserving. -/
theorem IsPPTOperation.conjugate_isPositiveTP
    {Λ : Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ} (hΛ : IsPPTOperation Λ) :
    IsPositiveTP (fun A => ptrans (Λ (ptrans A))) := by
  refine ⟨?_, ?_, ?_⟩
  · intro A B; rw [ptrans_sub, hΛ.map_sub, ptrans_sub]
  · intro A hA
    exact hΛ.ppt_pos (ptrans A) (by rwa [ptrans_ptrans])
  · intro A _
    rw [trace_ptrans, hΛ.map_trace, trace_ptrans]

/-- **The trace norm of the partial transpose is monotone under PPT operations.** -/
theorem traceNorm_ptrans_mono {Λ : Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ}
    (hΛ : IsPPTOperation Λ) {ρ : Matrix (α × β) (α × β) ℂ} (hρ : ρ.IsHermitian) :
    traceNorm (ptrans (Λ ρ)) ≤ traceNorm (ptrans ρ) := by
  have h := traceNorm_le_of_positiveTP hΛ.conjugate_isPositiveTP (ptrans_isHermitian hρ)
  rwa [ptrans_ptrans] at h

/-- **Monotonicity of the logarithmic negativity under PPT operations** (which include all
LOCC protocols). -/
theorem logNeg_mono {Λ : Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ}
    (hΛ : IsPPTOperation Λ) {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    logNeg (Λ ρ) ≤ logNeg ρ :=
  Real.log_le_log (traceNorm_ptrans_pos (hΛ.isState hρ))
    (traceNorm_ptrans_mono hΛ hρ.pos.isHermitian)

/-- Monotonicity of the negativity under PPT operations. -/
theorem negativity_mono {Λ : Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ}
    (hΛ : IsPPTOperation Λ) {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    negativity (Λ ρ) ≤ negativity ρ := by
  have := traceNorm_ptrans_mono hΛ hρ.pos.isHermitian
  unfold negativity
  linarith

/-- **Local operations are PPT operations.**  Conjugation by a local operator `A ⊗ B`
satisfying the isometry condition `(A ⊗ B)ᴴ (A ⊗ B) = 1` is a PPT operation. -/
theorem isPPTOperation_local (A : Matrix α α ℂ) (B : Matrix β β ℂ)
    (hiso : (A ⊗ₖ B)ᴴ * (A ⊗ₖ B) = 1) :
    IsPPTOperation (fun X => (A ⊗ₖ B) * X * (A ⊗ₖ B)ᴴ) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro X Y; rw [Matrix.mul_sub, Matrix.sub_mul]
  · intro X hX; exact hX.mul_mul_conjTranspose_same _
  · intro X
    rw [Matrix.trace_mul_comm, ← Matrix.mul_assoc, hiso, Matrix.one_mul]
  · intro X hX
    rw [ptrans_conj_local]
    exact hX.mul_mul_conjTranspose_same _

/-! ## Selective (strong) monotonicity -/

/-- A **PPT instrument**: a family of positive, PPT preserving branch maps whose traces add
up to the trace, i.e. a measurement whose branches are individually PPT operations up to
normalisation. -/
structure IsPPTInstrument {ι : Type*} [Fintype ι]
    (Λ : ι → Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ) : Prop where
  map_sub : ∀ i A B, Λ i (A - B) = Λ i A - Λ i B
  map_pos : ∀ i A, A.PosSemidef → (Λ i A).PosSemidef
  sum_trace : ∀ A, ∑ i, (Λ i A).trace = A.trace
  ppt_pos : ∀ i A, (ptrans A).PosSemidef → (ptrans (Λ i A)).PosSemidef

/-- The branch trace norms of a PPT instrument add up to at most the trace norm of the
partial transpose of the input. -/
theorem sum_traceNorm_ptrans_le {ι : Type*} [Fintype ι]
    {Λ : ι → Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ} (hΛ : IsPPTInstrument Λ)
    {ρ : Matrix (α × β) (α × β) ℂ} (hρ : ρ.IsHermitian) :
    ∑ i, traceNorm (ptrans (Λ i ρ)) ≤ traceNorm (ptrans ρ) := by
  have h := sum_traceNorm_le_of_positive_family
      (Psi := fun i A => ptrans (Λ i (ptrans A)))
      (fun i A B => by
        show ptrans (Λ i (ptrans (A - B))) = ptrans (Λ i (ptrans A)) - ptrans (Λ i (ptrans B))
        rw [ptrans_sub, hΛ.map_sub, ptrans_sub])
      (fun i A hA => by
        show (ptrans (Λ i (ptrans A))).PosSemidef
        exact hΛ.ppt_pos i (ptrans A) (by rwa [ptrans_ptrans]))
      (fun A _ => by
        show (∑ i, (ptrans (Λ i (ptrans A))).trace) = A.trace
        simp only [trace_ptrans]
        rw [hΛ.sum_trace, trace_ptrans])
      (ptrans_isHermitian hρ)
  simpa only [ptrans_ptrans] using h

/-- A weighted logarithm estimate (the finite form of Jensen's inequality for `log`, proved
directly from `log x ≤ x - 1`): for probabilities `pᵢ` and positive numbers `tᵢ`,
`∑ᵢ pᵢ log (tᵢ / pᵢ) ≤ log (∑ᵢ tᵢ)`. -/
theorem log_weighted_le {ι : Type*} [Fintype ι] (p t : ι → ℝ)
    (hp : ∀ i, 0 < p i) (ht : ∀ i, 0 < t i) (hsum : ∑ i, p i = 1) :
    ∑ i, p i * Real.log (t i / p i) ≤ Real.log (∑ i, t i) := by
  set T := ∑ i, t i with hT
  have hne : Nonempty ι := by
    by_contra h
    rw [not_nonempty_iff] at h
    simp at hsum
  have hTpos : 0 < T := Finset.sum_pos (fun i _ => ht i) Finset.univ_nonempty
  have key : ∀ i, p i * Real.log (t i / p i) ≤ p i * Real.log T + t i / T - p i := by
    intro i
    have hpne : p i ≠ 0 := ne_of_gt (hp i)
    have hdiv : 0 < t i / p i := div_pos (ht i) (hp i)
    have hlog := Real.log_le_sub_one_of_pos (div_pos hdiv hTpos)
    rw [Real.log_div (ne_of_gt hdiv) (ne_of_gt hTpos)] at hlog
    have h2 := mul_le_mul_of_nonneg_left hlog (hp i).le
    have hpi : p i * ((t i / p i) / T) = t i / T := by field_simp
    nlinarith [h2, hpi]
  have hfin : ∑ i, (p i * Real.log T + t i / T - p i) = Real.log T := by
    rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.sum_div,
      hsum, ← hT]
    field_simp
    ring
  calc ∑ i, p i * Real.log (t i / p i)
      ≤ ∑ i, (p i * Real.log T + t i / T - p i) := Finset.sum_le_sum fun i _ => key i
    _ = Real.log T := hfin

/-- **Strong (selective) monotonicity of the logarithmic negativity.**
For a PPT instrument with outcome probabilities `pᵢ = tr (Λᵢ ρ)` and post-measurement states
`ρᵢ = Λᵢ ρ / pᵢ`, the *average* logarithmic negativity of the branches does not exceed the
logarithmic negativity of the input.  Note that this is strictly stronger than
`logNeg_mono`: it also rules out increasing entanglement on average by selecting on
measurement outcomes.  The proof combines the trace norm bound
`∑ᵢ ‖Γ Λᵢ ρ‖₁ ≤ ‖Γ ρ‖₁` with the concavity estimate `log x ≤ x - 1`. -/
theorem logNeg_strong_mono {ι : Type*} [Fintype ι]
    {Λ : ι → Matrix (α × β) (α × β) ℂ → Matrix (α × β) (α × β) ℂ} (hΛ : IsPPTInstrument Λ)
    {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ)
    (hp : ∀ i, 0 < (Λ i ρ).trace.re) :
    ∑ i, (Λ i ρ).trace.re *
        logNeg ((((Λ i ρ).trace.re⁻¹ : ℝ) : ℂ) • Λ i ρ) ≤ logNeg ρ := by
  classical
  set p : ι → ℝ := fun i => (Λ i ρ).trace.re with hpdef
  set t : ι → ℝ := fun i => traceNorm (ptrans (Λ i ρ)) with htdef
  -- the branch matrices are positive semidefinite, hence Hermitian
  have hherm : ∀ i, (ptrans (Λ i ρ)).IsHermitian := fun i =>
    ptrans_isHermitian (hΛ.map_pos i ρ hρ.pos).isHermitian
  -- probabilities sum to one
  have hsum_p : ∑ i, p i = 1 := by
    have h := hΛ.sum_trace ρ
    rw [hρ.trace_one] at h
    have := congrArg Complex.re h
    simpa [hpdef, Complex.re_sum] using this
  -- each branch trace norm dominates its probability
  have hpt : ∀ i, p i ≤ t i := by
    intro i
    have h := re_trace_le_traceNorm (hherm i)
    rwa [trace_ptrans] at h
  have htpos : ∀ i, 0 < t i := fun i => lt_of_lt_of_le (hp i) (hpt i)
  set T : ℝ := ∑ i, t i with hTdef
  have hTpos : 0 < T := by
    have : ∑ i, p i ≤ ∑ i, t i := Finset.sum_le_sum fun i _ => hpt i
    rw [hsum_p] at this
    linarith
  have hTle : T ≤ traceNorm (ptrans ρ) := sum_traceNorm_ptrans_le hΛ hρ.pos.isHermitian
  -- rewrite the branch logarithmic negativities
  have hbranch : ∀ i, logNeg ((((p i)⁻¹ : ℝ) : ℂ) • Λ i ρ) = Real.log (t i / p i) := by
    intro i
    rw [logNeg, ptrans_smul, traceNorm_smul (hherm i) (le_of_lt (inv_pos.mpr (hp i)))]
    rw [inv_mul_eq_div]
  calc ∑ i, p i * logNeg ((((p i)⁻¹ : ℝ) : ℂ) • Λ i ρ)
      = ∑ i, p i * Real.log (t i / p i) :=
        Finset.sum_congr rfl fun i _ => by rw [hbranch i]
    _ ≤ Real.log T := log_weighted_le p t hp htpos hsum_p
    _ ≤ logNeg ρ := Real.log_le_log hTpos hTle

/-! ## Convexity of the negativity -/

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- Partial transposition commutes with finite sums. -/
theorem ptrans_sum {ι : Type*} (s : Finset ι) (X : ι → Matrix (α × β) (α × β) ℂ) :
    ptrans (∑ i ∈ s, X i) = ∑ i ∈ s, ptrans (X i) := by
  classical
  induction s using Finset.cons_induction with
  | empty => simp
  | cons a s ha ih => rw [Finset.sum_cons, Finset.sum_cons, ptrans_add, ih]

/-- **The negativity is convex**: mixing states cannot increase it. -/
theorem negativity_convex {ι : Type*} [Fintype ι] (w : ι → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hw1 : ∑ i, w i = 1) (ρ : ι → Matrix (α × β) (α × β) ℂ) (hρ : ∀ i, IsState (ρ i)) :
    negativity (∑ i, ((w i : ℝ) : ℂ) • ρ i) ≤ ∑ i, w i * negativity (ρ i) := by
  classical
  have hherm : ∀ i, (ptrans (ρ i)).IsHermitian := fun i => ptrans_isHermitian (hρ i).pos.isHermitian
  have h1 : traceNorm (ptrans (∑ i, ((w i : ℝ) : ℂ) • ρ i))
      ≤ ∑ i, w i * traceNorm (ptrans (ρ i)) := by
    rw [ptrans_sum]
    have hsmul : ∀ i, ptrans (((w i : ℝ) : ℂ) • ρ i) = ((w i : ℝ) : ℂ) • ptrans (ρ i) :=
      fun i => ptrans_smul _ _
    calc traceNorm (∑ i, ptrans (((w i : ℝ) : ℂ) • ρ i))
        = traceNorm (∑ i, ((w i : ℝ) : ℂ) • ptrans (ρ i)) := by
          exact congrArg traceNorm (Finset.sum_congr rfl fun i _ => hsmul i)
      _ ≤ ∑ i, traceNorm (((w i : ℝ) : ℂ) • ptrans (ρ i)) :=
          traceNorm_sum_le _ _ fun i _ => isHermitian_real_smul (hherm i) (w i)
      _ = ∑ i, w i * traceNorm (ptrans (ρ i)) :=
          Finset.sum_congr rfl fun i _ => traceNorm_smul (hherm i) (hw i)
  have h2 : ∑ i, w i * negativity (ρ i)
      = (∑ i, w i * traceNorm (ptrans (ρ i)) - 1) / 2 := by
    have hterm : ∀ i, w i * negativity (ρ i)
        = (w i * traceNorm (ptrans (ρ i)) - w i) / 2 := by
      intro i; unfold negativity; ring
    rw [Finset.sum_congr rfl fun i _ => hterm i, ← Finset.sum_div, Finset.sum_sub_distrib, hw1]
  rw [negativity, h2]
  linarith

end EntMonotone