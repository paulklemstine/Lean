import Novelty.StrangeAttractorPeriodicGrowth

/-!
# Strange attractors as algebraic objects, X: Perron–Frobenius existence

The previous file of this thread computed the entropy of a symbolic attractor spectrally,
`entropy = log value`, but only *for a graph carrying a Perron datum* — a strictly positive
eigenvector of the transfer matrix.  Existence of such a datum was the one missing
ingredient, listed as Conjecture 1′ of `FUTURE_DIRECTIONS.md`.  This file supplies it, and
thereby makes every spectral statement of the thread hypothesis-free for primitive graphs.

The proof is the Collatz–Wielandt variational construction, formalised from scratch (Mathlib
has no Perron–Frobenius theorem):

* `cwSet` : the compact set of pairs `(t, x)` with `x` in the standard simplex and
  `t • x ≤ A x` coordinatewise;
* `isCompact_cwSet` : it is compact — closed by continuity of `mulVec`, and contained in
  `[0, #V] × stdSimplex` because summing the defining inequality bounds `t` by `#V`;
* `exists_isMaxOn_cwSet` : hence the Collatz–Wielandt value `r = max {t : (t, x) ∈ cwSet}`
  is attained, and `1 ≤ r` because the uniform vector is admissible for `t = 1`;
* `mulVec_eq_of_isMaxOn` : **a maximiser is an eigenvector**.  If `w = A x - r x` were
  nonzero, then `A^k w` would be *strictly* positive (primitivity), so the normalisation `y`
  of `z = A^k x` would satisfy `A y ≥ (r + ε) y` for some `ε > 0`, contradicting maximality;
* `exists_perronDatum` : every primitive finite digraph carries a Perron datum;
* `entropy_eq_log_perronValue`, `isIntegral_exp_entropy_of_primitive`,
  `perronValue_spec` : the unconditional forms of the spectral theorems — for **every**
  primitive finite digraph the entropy is the logarithm of the (unique) Perron eigenvalue of
  the transfer matrix, and `exp (entropy)` is an algebraic integer;
* `card_le_perron_value_pow`, `one_lt_perronValue`, `entropy_pos_of_primitive` : **positive
  entropy** — a primitive attractor on at least two vertices has `value > 1`, hence strictly
  positive topological entropy, because `#V ≤ value ^ N` for a primitivity exponent `N`;
* `perron_eigenvector_eq_smul`, `perron_eigenspace_eq_span` : **geometric simplicity** — the
  eigenspace of the Perron value of a primitive graph is the line spanned by the positive
  eigenvector;
* `abs_le_perron_value_of_eigen`, `perronValue_isGreatest` : **spectral dominance** — the
  Perron value dominates every real eigenvalue in absolute value, so it *is* the spectral
  radius, and the entropy of a primitive symbolic attractor is the logarithm of the spectral
  radius of its transfer matrix.
-/

namespace LorenzLimit

open Filter Topology

variable {V : Type*} [Fintype V] [DecidableEq V] {E : V → V → Bool}

/-! ## The real transfer matrix -/

/-- The transfer matrix with real entries. -/
noncomputable def adjR (E : V → V → Bool) : Matrix V V ℝ :=
  (adjMatrix E).map (fun n : ℕ => (n : ℝ))

omit [Fintype V] [DecidableEq V] in
theorem adjR_apply (i j : V) : adjR E i j = (adjMatrix E i j : ℝ) := rfl

theorem adjR_pow_apply (n : ℕ) (i j : V) :
    (adjR E ^ n) i j = ((adjMatrix E ^ n) i j : ℝ) := by
  have h : (adjR E) ^ n = ((adjMatrix E) ^ n).map (fun m : ℕ => (m : ℝ)) :=
    (Matrix.map_pow (adjMatrix E) (Nat.castRingHom ℝ) n).symm
  rw [h]
  rfl

omit [Fintype V] [DecidableEq V] in
theorem adjR_nonneg (i j : V) : 0 ≤ adjR E i j := by
  rw [adjR_apply]; positivity

omit [Fintype V] [DecidableEq V] in
theorem adjR_le_one (i j : V) : adjR E i j ≤ 1 := by
  rw [adjR_apply, adjMatrix]
  by_cases h : E i j = true <;> simp [h]

theorem adjR_pow_nonneg (n : ℕ) (i j : V) : 0 ≤ (adjR E ^ n) i j := by
  rw [adjR_pow_apply]; positivity

omit [DecidableEq V] in
/-- `mulVec` in the sum notation used by `PerronDatum`. -/
theorem adjR_mulVec_apply (x : V → ℝ) (i : V) :
    (adjR E).mulVec x i = ∑ j, (adjMatrix E i j : ℝ) * x j := rfl

/-- The eigenvector equation propagates to powers of the matrix. -/
theorem mulVec_pow_of_mulVec_eq {r : ℝ} {x : V → ℝ} (h : (adjR E).mulVec x = r • x) :
    ∀ n : ℕ, ((adjR E) ^ n).mulVec x = r ^ n • x := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, ← Matrix.mulVec_mulVec, h, Matrix.mulVec_smul, ih, smul_smul]
      congr 1
      ring

/-! ## The Collatz–Wielandt set -/

/-- The **Collatz–Wielandt set**: pairs `(t, x)` with `t ≥ 0`, `x` in the standard simplex
and `t • x ≤ A x` coordinatewise.  Its maximal first coordinate is the Perron value. -/
noncomputable def cwSet (E : V → V → Bool) : Set (ℝ × (V → ℝ)) :=
  {p | 0 ≤ p.1 ∧ p.2 ∈ stdSimplex ℝ V ∧ ∀ i, p.1 * p.2 i ≤ (adjR E).mulVec p.2 i}

omit [DecidableEq V] in
theorem isClosed_cwSet : IsClosed (cwSet E) := by
  have hsplit : cwSet E =
      ({p : ℝ × (V → ℝ) | 0 ≤ p.1} ∩ (Prod.snd ⁻¹' stdSimplex ℝ V)) ∩
        ⋂ i : V, {p : ℝ × (V → ℝ) | p.1 * p.2 i ≤ (adjR E).mulVec p.2 i} := by
    ext p
    simp only [cwSet, Set.mem_setOf_eq, Set.mem_inter_iff, Set.mem_preimage, Set.mem_iInter,
      and_assoc]
  rw [hsplit]
  refine IsClosed.inter (IsClosed.inter (isClosed_le continuous_const continuous_fst)
    ((isClosed_stdSimplex V).preimage continuous_snd)) (isClosed_iInter fun i => ?_)
  refine isClosed_le (continuous_fst.mul ((continuous_apply i).comp continuous_snd)) ?_
  have : Continuous fun p : ℝ × (V → ℝ) => ∑ j, adjR E i j * p.2 j :=
    continuous_finset_sum _ fun j _ =>
      continuous_const.mul ((continuous_apply j).comp continuous_snd)
  exact this

omit [DecidableEq V] in
/-- Summing the defining inequality bounds the Collatz–Wielandt parameter by `#V`. -/
theorem cwSet_fst_le_card {p : ℝ × (V → ℝ)} (hp : p ∈ cwSet E) :
    p.1 ≤ Fintype.card V := by
  obtain ⟨-, ⟨hx0, hx1⟩, hle⟩ := hp
  have hsum : p.1 = ∑ i, p.1 * p.2 i := by
    rw [← Finset.mul_sum, hx1, mul_one]
  have hstep : ∑ i, p.1 * p.2 i ≤ ∑ i, (adjR E).mulVec p.2 i :=
    Finset.sum_le_sum fun i _ => hle i
  have hswap : ∑ i, (adjR E).mulVec p.2 i = ∑ j, (∑ i, adjR E i j) * p.2 j := by
    simp only [adjR_mulVec_apply, adjR_apply]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun j _ => by rw [Finset.sum_mul]
  have hcol : ∀ j : V, (∑ i, adjR E i j) ≤ Fintype.card V := by
    intro j
    calc ∑ i, adjR E i j ≤ ∑ _i : V, (1 : ℝ) := Finset.sum_le_sum fun i _ => adjR_le_one i j
      _ = Fintype.card V := by simp
  have hfinal : ∑ j, (∑ i, adjR E i j) * p.2 j ≤ ∑ j, (Fintype.card V : ℝ) * p.2 j :=
    Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_right (hcol j) (hx0 j)
  have hlast : ∑ j, (Fintype.card V : ℝ) * p.2 j = Fintype.card V := by
    rw [← Finset.mul_sum, hx1, mul_one]
  rw [hsum]
  calc ∑ i, p.1 * p.2 i ≤ ∑ i, (adjR E).mulVec p.2 i := hstep
    _ = ∑ j, (∑ i, adjR E i j) * p.2 j := hswap
    _ ≤ ∑ j, (Fintype.card V : ℝ) * p.2 j := hfinal
    _ = Fintype.card V := hlast

omit [DecidableEq V] in
theorem isCompact_cwSet : IsCompact (cwSet E) := by
  refine IsCompact.of_isClosed_subset
    ((isCompact_Icc (a := (0 : ℝ)) (b := (Fintype.card V : ℝ))).prod (isCompact_stdSimplex V))
    isClosed_cwSet ?_
  intro p hp
  exact ⟨⟨hp.1, cwSet_fst_le_card hp⟩, hp.2.1⟩

omit [DecidableEq V] in
/-- The uniform vector is admissible with parameter `1` whenever there are no dead ends. -/
theorem one_uniform_mem_cwSet [Nonempty V] (h : NoDeadEnds E) :
    ((1 : ℝ), fun _ : V => (Fintype.card V : ℝ)⁻¹) ∈ cwSet E := by
  have hcard : (0 : ℝ) < Fintype.card V := by
    have : 0 < Fintype.card V := Fintype.card_pos
    exact_mod_cast this
  refine ⟨zero_le_one, ⟨fun i => by positivity, ?_⟩, ?_⟩
  · rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp
  · intro i
    obtain ⟨j₀, hj₀⟩ := h i
    have hterm : (Fintype.card V : ℝ)⁻¹
        ≤ ∑ j, (adjMatrix E i j : ℝ) * (Fintype.card V : ℝ)⁻¹ := by
      have hA : adjMatrix E i j₀ = 1 := by simp [adjMatrix, hj₀]
      have hnn : ∀ j ∈ (Finset.univ : Finset V),
          (0 : ℝ) ≤ (adjMatrix E i j : ℝ) * (Fintype.card V : ℝ)⁻¹ := by
        intro j _
        have : (0 : ℝ) ≤ (adjMatrix E i j : ℝ) := by positivity
        have h2 : (0 : ℝ) ≤ (Fintype.card V : ℝ)⁻¹ := by positivity
        exact mul_nonneg this h2
      have := Finset.single_le_sum hnn (Finset.mem_univ j₀)
      rwa [hA, Nat.cast_one, one_mul] at this
    simpa [adjR_mulVec_apply] using hterm

omit [DecidableEq V] in
/-- The Collatz–Wielandt value is attained: a maximiser exists. -/
theorem exists_isMaxOn_cwSet [Nonempty V] (h : NoDeadEnds E) :
    ∃ p ∈ cwSet E, 1 ≤ p.1 ∧ ∀ q ∈ cwSet E, q.1 ≤ p.1 := by
  obtain ⟨p, hp, hmax⟩ := isCompact_cwSet.exists_isMaxOn
    (⟨_, one_uniform_mem_cwSet h⟩ : (cwSet E).Nonempty) continuous_fst.continuousOn
  exact ⟨p, hp, hmax (one_uniform_mem_cwSet h), fun q hq => hmax hq⟩

/-! ## A maximiser is an eigenvector -/

/-- **The Collatz–Wielandt maximiser is an eigenvector.**  This is the heart of
Perron–Frobenius: if `A x - r x` were nonzero, primitivity would make `A^k (A x - r x)`
strictly positive, and the normalisation of `A^k x` would beat the maximum. -/
theorem mulVec_eq_of_isMaxOn [Nonempty V] {k : ℕ}
    (hk : ∀ u v : V, 1 ≤ (adjMatrix E ^ k) u v)
    {p : ℝ × (V → ℝ)} (hp : p ∈ cwSet E) (hmax : ∀ q ∈ cwSet E, q.1 ≤ p.1) :
    (adjR E).mulVec p.2 = p.1 • p.2 := by
  obtain ⟨hr0, ⟨hx0, hx1⟩, hle⟩ := hp
  set r := p.1 with hrdef
  set x := p.2 with hxdef
  set B := (adjR E) ^ k with hB
  have hBentry : ∀ u v : V, 1 ≤ B u v := by
    intro u v
    rw [hB, adjR_pow_apply]
    exact_mod_cast hk u v
  -- some coordinate of `x` is positive
  obtain ⟨j₁, -, hj₁⟩ : ∃ j ∈ (Finset.univ : Finset V), 0 < x j := by
    by_contra hcon
    push_neg at hcon
    have : ∑ j, x j = 0 :=
      Finset.sum_eq_zero fun j hj => le_antisymm (hcon j hj) (hx0 j)
    rw [hx1] at this
    exact one_ne_zero this
  by_contra hne
  -- the defect `w = A x - r x` is nonnegative and nonzero
  set w : V → ℝ := fun i => (adjR E).mulVec x i - r * x i with hw
  have hw0 : ∀ i, 0 ≤ w i := fun i => sub_nonneg.mpr (hle i)
  have hwne : ∃ j, 0 < w j := by
    by_contra hcon
    push_neg at hcon
    apply hne
    funext i
    have : w i = 0 := le_antisymm (hcon i) (hw0 i)
    simp only [hw, sub_eq_zero] at this
    simpa using this
  obtain ⟨j₀, hj₀⟩ := hwne
  -- `z = B x` is strictly positive, and `A z - r z = B w` is strictly positive
  set z : V → ℝ := B.mulVec x with hz
  have hzpos : ∀ i, 0 < z i := by
    intro i
    have hterm : B i j₁ * x j₁ ≤ ∑ j, B i j * x j :=
      Finset.single_le_sum
        (f := fun j => B i j * x j)
        (fun j _ => mul_nonneg (le_trans zero_le_one (hBentry i j)) (hx0 j))
        (Finset.mem_univ j₁)
    have h1 : 0 < B i j₁ * x j₁ :=
      mul_pos (lt_of_lt_of_le zero_lt_one (hBentry i j₁)) hj₁
    exact lt_of_lt_of_le h1 hterm
  have hcomm : (adjR E) * B = B * (adjR E) := (Commute.refl (adjR E)).pow_right k
  have hdefect : ∀ i, (adjR E).mulVec z i - r * z i = B.mulVec w i := by
    intro i
    have h1 : (adjR E).mulVec z = B.mulVec ((adjR E).mulVec x) := by
      rw [hz, Matrix.mulVec_mulVec, hcomm, ← Matrix.mulVec_mulVec]
    have h2 : B.mulVec w = B.mulVec ((adjR E).mulVec x) - r • B.mulVec x := by
      have hwsub : w = (adjR E).mulVec x - r • x := by
        funext i; simp [hw, Pi.smul_apply, smul_eq_mul]
      rw [hwsub, Matrix.mulVec_sub, Matrix.mulVec_smul]
    rw [h1, h2]
    simp [hz, Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
  have hBwpos : ∀ i, 0 < B.mulVec w i := by
    intro i
    have hterm : B i j₀ * w j₀ ≤ ∑ j, B i j * w j :=
      Finset.single_le_sum
        (f := fun j => B i j * w j)
        (fun j _ => mul_nonneg (le_trans zero_le_one (hBentry i j)) (hw0 j))
        (Finset.mem_univ j₀)
    have h1 : 0 < B i j₀ * w j₀ :=
      mul_pos (lt_of_lt_of_le zero_lt_one (hBentry i j₀)) hj₀
    exact lt_of_lt_of_le h1 hterm
  -- normalise `z` and produce a strictly better parameter
  obtain ⟨i₀, -, hmin⟩ :=
    Finset.exists_min_image (Finset.univ : Finset V) (fun i => B.mulVec w i)
      ⟨Classical.arbitrary V, Finset.mem_univ _⟩
  set d := B.mulVec w i₀ with hd
  have hdpos : 0 < d := hBwpos i₀
  set S := ∑ i, z i with hS
  have hSpos : 0 < S :=
    Finset.sum_pos (fun i _ => hzpos i) ⟨Classical.arbitrary V, Finset.mem_univ _⟩
  set y : V → ℝ := fun i => S⁻¹ * z i with hy
  have hy0 : ∀ i, 0 ≤ y i := fun i => mul_nonneg (by positivity) (hzpos i).le
  have hy1 : ∑ i, y i = 1 := by
    rw [hy, ← Finset.mul_sum, ← hS]
    field_simp
  have hyle : ∀ i, y i ≤ 1 := by
    intro i
    rw [← hy1]
    exact Finset.single_le_sum (fun j _ => hy0 j) (Finset.mem_univ i)
  have hAy : ∀ i, (adjR E).mulVec y i = S⁻¹ * (adjR E).mulVec z i := by
    intro i
    simp only [Matrix.mulVec, dotProduct, hy]
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  set e := S⁻¹ * d with he
  have hepos : 0 < e := by positivity
  have hmem : (r + e, y) ∈ cwSet E := by
    refine ⟨by positivity, ⟨hy0, hy1⟩, fun i => ?_⟩
    have hdef : (adjR E).mulVec z i = r * z i + B.mulVec w i := by
      have := hdefect i; linarith
    have hge : d ≤ B.mulVec w i := hmin i (Finset.mem_univ i)
    have hstep : (adjR E).mulVec y i = r * y i + S⁻¹ * B.mulVec w i := by
      rw [hAy i, hdef, hy]
      ring
    have h1 : S⁻¹ * d ≤ S⁻¹ * B.mulVec w i := by
      have : (0:ℝ) ≤ S⁻¹ := by positivity
      exact mul_le_mul_of_nonneg_left hge this
    have h2 : e * y i ≤ e := by
      calc e * y i ≤ e * 1 := mul_le_mul_of_nonneg_left (hyle i) hepos.le
        _ = e := mul_one e
    calc (r + e) * y i = r * y i + e * y i := by ring
      _ ≤ r * y i + e := by linarith
      _ ≤ r * y i + S⁻¹ * B.mulVec w i := by rw [he]; linarith
      _ = (adjR E).mulVec y i := hstep.symm
  have := hmax _ hmem
  simp only at this
  linarith

/-! ## Existence of Perron data, and the unconditional spectral theorems -/

omit [Fintype V] [DecidableEq V] in
/-- A primitive graph has no dead ends. -/
theorem noDeadEnds_of_primitive (hP : Primitive E) : NoDeadEnds E := by
  obtain ⟨N, hN, hwalk⟩ := hP
  intro v
  obtain ⟨w, hw0, -, hedge⟩ := hwalk N le_rfl v v
  exact ⟨w 1, by simpa [hw0] using hedge 0 hN⟩

/-- **Perron–Frobenius existence** (Conjecture 1′).  Every primitive finite directed graph
carries a Perron datum: its transfer matrix has a strictly positive eigenvector.  The proof
is the Collatz–Wielandt construction; no Perron–Frobenius theorem is assumed. -/
theorem exists_perronDatum [Nonempty V] (hP : Primitive E) : Nonempty (PerronDatum E) := by
  obtain ⟨N, hN, hpow⟩ := exists_pow_pos_of_primitive hP
  have hE : NoDeadEnds E := noDeadEnds_of_primitive hP
  obtain ⟨p, hp, hp1, hmax⟩ := exists_isMaxOn_cwSet hE
  have heig : (adjR E).mulVec p.2 = p.1 • p.2 :=
    mulVec_eq_of_isMaxOn (k := N) (hpow N le_rfl) hp hmax
  obtain ⟨-, ⟨hx0, hx1⟩, -⟩ := hp
  -- some coordinate is positive, and primitivity spreads it to all coordinates
  obtain ⟨j₁, -, hj₁⟩ : ∃ j ∈ (Finset.univ : Finset V), 0 < p.2 j := by
    by_contra hcon
    push_neg at hcon
    have : ∑ j, p.2 j = 0 :=
      Finset.sum_eq_zero fun j hj => le_antisymm (hcon j hj) (hx0 j)
    rw [hx1] at this
    exact one_ne_zero this
  have hpow' : ∀ u v : V, (1 : ℝ) ≤ (adjR E ^ N) u v := by
    intro u v
    rw [adjR_pow_apply]
    exact_mod_cast hpow N le_rfl u v
  have hposvec : ∀ i, 0 < p.2 i := by
    intro i
    have hmv : ((adjR E) ^ N).mulVec p.2 = p.1 ^ N • p.2 := mulVec_pow_of_mulVec_eq heig N
    have hlow : 0 < ((adjR E) ^ N).mulVec p.2 i := by
      have hterm : (adjR E ^ N) i j₁ * p.2 j₁ ≤ ∑ j, (adjR E ^ N) i j * p.2 j :=
        Finset.single_le_sum
          (f := fun j => (adjR E ^ N) i j * p.2 j)
          (fun j _ => mul_nonneg (le_trans zero_le_one (hpow' i j)) (hx0 j))
          (Finset.mem_univ j₁)
      exact lt_of_lt_of_le (mul_pos (lt_of_lt_of_le zero_lt_one (hpow' i j₁)) hj₁) hterm
    rw [hmv] at hlow
    have hrpos : 0 < p.1 ^ N := lt_of_lt_of_le zero_lt_one (one_le_pow₀ hp1)
    have hmul : 0 < p.1 ^ N * p.2 i := by simpa [Pi.smul_apply, smul_eq_mul] using hlow
    nlinarith [hx0 i]
  exact ⟨{ value := p.1
           vector := p.2
           vector_pos := hposvec
           eigen := by
             intro i
             have := congrFun heig i
             simpa [adjR_mulVec_apply, Pi.smul_apply, smul_eq_mul] using this }⟩

/-- The Perron value of a primitive graph: the eigenvalue of any Perron datum (unique by
`perron_value_unique`). -/
noncomputable def perronValue [Nonempty V] (hP : Primitive E) : ℝ :=
  (Classical.choice (exists_perronDatum hP)).value

theorem perronValue_spec [Nonempty V] (hP : Primitive E) (p : PerronDatum E) :
    perronValue hP = p.value :=
  perron_value_unique (noDeadEnds_of_primitive hP) _ p

/-- **The entropy of a primitive attractor is the logarithm of its Perron value**, with no
side hypothesis: the Perron datum is now produced, not assumed. -/
theorem entropy_eq_log_perronValue [Nonempty V] (hP : Primitive E) :
    entropy (noDeadEnds_of_primitive hP) = Real.log (perronValue hP) :=
  entropy_eq_log_perron _ (Classical.choice (exists_perronDatum hP))

/-- `1 ≤ perronValue ≤ #V` for every primitive graph. -/
theorem one_le_perronValue [Nonempty V] (hP : Primitive E) : 1 ≤ perronValue hP :=
  one_le_perron_value (noDeadEnds_of_primitive hP) _

theorem perronValue_le_card [Nonempty V] (hP : Primitive E) :
    perronValue hP ≤ Fintype.card V :=
  perron_value_le_card (noDeadEnds_of_primitive hP) _

/-- **`exp` of the entropy of a primitive symbolic attractor is an algebraic integer** — now
unconditionally, for every primitive finite digraph. -/
theorem isIntegral_exp_entropy_of_primitive [Nonempty V] (hP : Primitive E) :
    IsIntegral ℤ (Real.exp (entropy (noDeadEnds_of_primitive hP))) :=
  isIntegral_exp_entropy _ (Classical.choice (exists_perronDatum hP))

/-- The Perron value is a genuine eigenvalue of the transfer matrix. -/
theorem perronValue_det_eq_zero [Nonempty V] (hP : Primitive E) :
    (Matrix.scalar V (perronValue hP) - adjR E).det = 0 :=
  perron_det_eq_zero (Classical.choice (exists_perronDatum hP))

/-- The periodic-orbit growth rate of a primitive attractor is `log` of its Perron value. -/
theorem tendsto_log_card_closedWalk_perronValue [Nonempty V] (hP : Primitive E) :
    Tendsto (fun n : ℕ => Real.log (Fintype.card (ClosedWalk E n)) / n) atTop
      (𝓝 (Real.log (perronValue hP))) := by
  have h := tendsto_log_card_closedWalk (noDeadEnds_of_primitive hP) hP
    (Classical.choice (exists_perronDatum hP))
  rwa [entropy_eq_log_perronValue hP] at h

/-! ## Positive entropy -/

/-- With `N` a primitivity exponent, `#V ≤ value ^ N`: every entry of `A ^ N` is at least `1`,
so the eigenvector equation at a vertex of minimal weight forces the Perron value to grow. -/
theorem card_le_perron_value_pow [Nonempty V] {N : ℕ}
    (hN : ∀ u v : V, 1 ≤ (adjMatrix E ^ N) u v) (p : PerronDatum E) :
    (Fintype.card V : ℝ) ≤ p.value ^ N := by
  obtain ⟨i₀, -, hmin⟩ :=
    Finset.exists_min_image (Finset.univ : Finset V) p.vector ⟨Classical.arbitrary V,
      Finset.mem_univ _⟩
  have hpow : ∀ u v : V, (1 : ℝ) ≤ ((adjMatrix E ^ N) u v : ℝ) := by
    intro u v; exact_mod_cast hN u v
  have hsum : ∑ j, p.vector j ≤ ∑ j, ((adjMatrix E ^ N) i₀ j : ℝ) * p.vector j :=
    Finset.sum_le_sum fun j _ => by
      have := mul_le_mul_of_nonneg_right (hpow i₀ j) (p.vector_pos j).le
      simpa using this
  rw [p.pow_eigen N i₀] at hsum
  have hcard : (Fintype.card V : ℝ) * p.vector i₀ ≤ ∑ j, p.vector j := by
    calc (Fintype.card V : ℝ) * p.vector i₀ = ∑ _j : V, p.vector i₀ := by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
      _ ≤ ∑ j, p.vector j := Finset.sum_le_sum fun j _ => hmin j (Finset.mem_univ j)
  have hv := p.vector_pos i₀
  have : (Fintype.card V : ℝ) * p.vector i₀ ≤ p.value ^ N * p.vector i₀ := le_trans hcard hsum
  exact le_of_mul_le_mul_right (by linarith) hv

/-- **A primitive attractor on more than one vertex has a Perron value `> 1`.** -/
theorem one_lt_perronValue [Nonempty V] (hP : Primitive E) (hcard : 2 ≤ Fintype.card V) :
    1 < perronValue hP := by
  obtain ⟨N, -, hpow⟩ := exists_pow_pos_of_primitive hP
  set p := Classical.choice (exists_perronDatum hP) with hp
  have hval : perronValue hP = p.value := perronValue_spec hP p
  have h1 : (1 : ℝ) ≤ p.value := one_le_perron_value (noDeadEnds_of_primitive hP) p
  have hle : (Fintype.card V : ℝ) ≤ p.value ^ N := card_le_perron_value_pow (hpow N le_rfl) p
  have h2 : (2 : ℝ) ≤ (Fintype.card V : ℝ) := by exact_mod_cast hcard
  rw [hval]
  rcases eq_or_lt_of_le h1 with heq | hlt
  · exfalso
    rw [← heq, one_pow] at hle
    linarith
  · exact hlt

/-- **Positive entropy.**  A primitive symbolic attractor on at least two vertices has
strictly positive topological entropy: the mixing hypothesis that gives Devaney chaos also
forces exponential orbit growth. -/
theorem entropy_pos_of_primitive [Nonempty V] (hP : Primitive E) (hcard : 2 ≤ Fintype.card V) :
    0 < entropy (noDeadEnds_of_primitive hP) := by
  rw [entropy_eq_log_perronValue hP]
  exact Real.log_pos (one_lt_perronValue hP hcard)

/-! ## Spectral dominance: the Perron value is the spectral radius -/

omit [DecidableEq V] in
/-- **Spectral dominance.**  Every real eigenvalue of the transfer matrix is bounded in
absolute value by the Perron value.  The proof compares an arbitrary eigenvector `y` with
the positive eigenvector `v` at the index maximising `|y i| / v i`. -/
theorem abs_le_perron_value_of_eigen (p : PerronDatum E) {lam : ℝ} {y : V → ℝ} (hy : y ≠ 0)
    (heig : (adjR E).mulVec y = lam • y) : |lam| ≤ p.value := by
  classical
  have hVne : (Finset.univ : Finset V).Nonempty := by
    rcases Function.ne_iff.mp hy with ⟨j, hj⟩
    exact ⟨j, Finset.mem_univ j⟩
  obtain ⟨i₀, -, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset V) (fun i => |y i| / p.vector i) hVne
  set m := |y i₀| / p.vector i₀ with hm
  have hmpos : 0 < m := by
    rcases Function.ne_iff.mp hy with ⟨j, hj⟩
    have hjpos : 0 < |y j| / p.vector j :=
      div_pos (abs_pos.mpr (by simpa using hj)) (p.vector_pos j)
    exact lt_of_lt_of_le hjpos (hmax j (Finset.mem_univ j))
  have hbound : ∀ j, |y j| ≤ m * p.vector j := by
    intro j
    have h := hmax j (Finset.mem_univ j)
    rw [div_le_iff₀ (p.vector_pos j)] at h
    exact h
  have hyeq : |y i₀| = m * p.vector i₀ := by
    rw [hm, div_mul_cancel₀ _ (ne_of_gt (p.vector_pos i₀))]
  have hyi₀ : 0 < |y i₀| := by
    rw [hyeq]
    exact mul_pos hmpos (p.vector_pos i₀)
  have hrow : |lam * y i₀| ≤ ∑ j, (adjMatrix E i₀ j : ℝ) * |y j| := by
    have hcomp : lam * y i₀ = ∑ j, (adjMatrix E i₀ j : ℝ) * y j := by
      have := congrFun heig i₀
      simpa [adjR_mulVec_apply, Pi.smul_apply, smul_eq_mul] using this.symm
    rw [hcomp]
    refine le_trans (Finset.abs_sum_le_sum_abs _ _) (le_of_eq ?_)
    exact Finset.sum_congr rfl fun j _ => by
      rw [abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ (adjMatrix E i₀ j : ℝ))]
  have hstep : ∑ j, (adjMatrix E i₀ j : ℝ) * |y j|
      ≤ ∑ j, (adjMatrix E i₀ j : ℝ) * (m * p.vector j) :=
    Finset.sum_le_sum fun j _ =>
      mul_le_mul_of_nonneg_left (hbound j) (by positivity)
  have hsum : ∑ j, (adjMatrix E i₀ j : ℝ) * (m * p.vector j) = m * (p.value * p.vector i₀) := by
    rw [← p.eigen i₀, Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  have hfinal : |lam| * |y i₀| ≤ p.value * |y i₀| := by
    have hkey : |lam| * |y i₀| ≤ m * (p.value * p.vector i₀) := by
      rw [← abs_mul]
      exact le_trans hrow (le_trans hstep (le_of_eq hsum))
    rw [hyeq]
    calc |lam| * (m * p.vector i₀) ≤ m * (p.value * p.vector i₀) := by
          rw [← hyeq]; exact hkey
      _ = p.value * (m * p.vector i₀) := by ring
  exact le_of_mul_le_mul_right (by linarith) hyi₀

/-- **The Perron value is the largest real eigenvalue** of the transfer matrix of a
primitive graph: it is an eigenvalue, and it dominates all of them.  Combined with
`entropy_eq_log_perronValue`, the topological entropy of a primitive symbolic attractor is
the logarithm of the spectral radius of its transfer matrix. -/
theorem perronValue_isGreatest [Nonempty V] (hP : Primitive E) :
    IsGreatest {lam : ℝ | ∃ y : V → ℝ, y ≠ 0 ∧ (adjR E).mulVec y = lam • y}
      (perronValue hP) := by
  set p := Classical.choice (exists_perronDatum hP) with hp
  have hval : perronValue hP = p.value := perronValue_spec hP p
  constructor
  · refine ⟨p.vector, ?_, ?_⟩
    · intro hzero
      have := p.vector_pos (Classical.arbitrary V)
      rw [hzero] at this
      simp at this
    · funext i
      have := p.eigen i
      simpa [adjR_mulVec_apply, Pi.smul_apply, smul_eq_mul, hval] using this
  · rintro lam ⟨y, hy, heig⟩
    rw [hval]
    exact le_trans (le_abs_self lam) (abs_le_perron_value_of_eigen p hy heig)

/-! ## Simplicity of the Perron eigenvalue -/

/-- **The Perron eigenspace is one-dimensional.**  For a primitive graph, every real
eigenvector for the Perron value is a multiple of the positive one: subtracting the largest
multiple `t • v` that still leaves `y - t v ≥ 0` produces a nonnegative eigenvector with a
zero coordinate, and `A ^ N` — all of whose entries are at least `1` — forces it to vanish. -/
theorem perron_eigenvector_eq_smul [Nonempty V] {N : ℕ}
    (hN : ∀ u v : V, 1 ≤ (adjMatrix E ^ N) u v) (p : PerronDatum E)
    {y : V → ℝ} (heig : (adjR E).mulVec y = p.value • y) :
    ∃ t : ℝ, y = t • p.vector := by
  obtain ⟨i₀, -, hmin⟩ :=
    Finset.exists_min_image (Finset.univ : Finset V) (fun i => y i / p.vector i)
      ⟨Classical.arbitrary V, Finset.mem_univ _⟩
  set t := y i₀ / p.vector i₀ with ht
  refine ⟨t, ?_⟩
  set z : V → ℝ := fun i => y i - t * p.vector i with hz
  have hz0 : ∀ i, 0 ≤ z i := by
    intro i
    have h := hmin i (Finset.mem_univ i)
    rw [le_div_iff₀ (p.vector_pos i)] at h
    simp only [hz, sub_nonneg]
    linarith
  have hzi₀ : z i₀ = 0 := by
    have hv0 := p.vector_pos i₀
    simp only [hz, ht]
    field_simp
    ring
  -- `z` is again an eigenvector for the same value
  have hpv : (adjR E).mulVec p.vector = p.value • p.vector := by
    funext i
    simpa [adjR_mulVec_apply, Pi.smul_apply, smul_eq_mul] using p.eigen i
  have hzeig : (adjR E).mulVec z = p.value • z := by
    have hzdef : z = y - t • p.vector := by
      funext i; simp [hz, Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
    rw [hzdef, Matrix.mulVec_sub, Matrix.mulVec_smul, heig, hpv]
    funext i
    simp [Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
    ring
  have hpowz : ((adjR E) ^ N).mulVec z = p.value ^ N • z := mulVec_pow_of_mulVec_eq hzeig N
  have hpow' : ∀ u v : V, (1 : ℝ) ≤ (adjR E ^ N) u v := by
    intro u v
    rw [adjR_pow_apply]
    exact_mod_cast hN u v
  have hsum : ∑ j, z j ≤ ((adjR E) ^ N).mulVec z i₀ := by
    refine Finset.sum_le_sum fun j _ => ?_
    have := mul_le_mul_of_nonneg_right (hpow' i₀ j) (hz0 j)
    simpa using this
  have hzero : ((adjR E) ^ N).mulVec z i₀ = 0 := by
    rw [hpowz]
    simp [Pi.smul_apply, smul_eq_mul, hzi₀]
  have hsum0 : ∑ j, z j ≤ 0 := by rw [← hzero]; exact hsum
  have hall : ∀ j, z j = 0 := by
    intro j
    have hnn : ∀ k ∈ (Finset.univ : Finset V), 0 ≤ z k := fun k _ => hz0 k
    have hle : 0 ≤ ∑ j, z j := Finset.sum_nonneg hnn
    have : ∑ j, z j = 0 := le_antisymm hsum0 hle
    exact (Finset.sum_eq_zero_iff_of_nonneg hnn).mp this j (Finset.mem_univ j)
  funext i
  have := hall i
  rw [hz] at this
  simp only [Pi.smul_apply, smul_eq_mul]
  linarith

/-- The Perron eigenvector of a primitive graph. -/
noncomputable def perronVector [Nonempty V] (hP : Primitive E) : V → ℝ :=
  (Classical.choice (exists_perronDatum hP)).vector

theorem perronVector_pos [Nonempty V] (hP : Primitive E) (i : V) : 0 < perronVector hP i :=
  (Classical.choice (exists_perronDatum hP)).vector_pos i

theorem mulVec_perronVector [Nonempty V] (hP : Primitive E) :
    (adjR E).mulVec (perronVector hP) = perronValue hP • perronVector hP := by
  funext i
  have := (Classical.choice (exists_perronDatum hP)).eigen i
  simpa [adjR_mulVec_apply, perronVector, perronValue, Pi.smul_apply, smul_eq_mul] using this

/-- **Geometric simplicity of the Perron eigenvalue.**  For a primitive graph the eigenspace
of the Perron value is the line spanned by the positive eigenvector. -/
theorem perron_eigenspace_eq_span [Nonempty V] (hP : Primitive E) {y : V → ℝ}
    (heig : (adjR E).mulVec y = perronValue hP • y) :
    ∃ t : ℝ, y = t • perronVector hP := by
  obtain ⟨N, -, hpow⟩ := exists_pow_pos_of_primitive hP
  exact perron_eigenvector_eq_smul (hpow N le_rfl) (Classical.choice (exists_perronDatum hP))
    (by simpa [perronValue] using heig)

/-! ## The templates, unconditionally -/

theorem perronValue_lorenzTemplate : perronValue primitive_lorenzTemplate = 2 :=
  perronValue_spec _ perronLorenz

theorem perronValue_prunedTemplate :
    perronValue primitive_prunedTemplate = Real.goldenRatio :=
  perronValue_spec _ perronPruned

end LorenzLimit