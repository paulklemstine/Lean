import Applications.AdjacentSumPolytopes.Necklace
import Applications.AdjacentSumPolytopes.Periodicity

/-!
# The full Gauss congruence for the adjacent-sum transfer matrix

`Applications.AdjacentSumPolytopes.Necklace` proved the Gauss congruence
`p ∣ tr(Mᵖ) − tr(M)` for *prime* lengths, using the `p`-group fixed point formula, and
left the general case as a conjecture.  Here we settle it:

`n ∣ ∑_{d ∣ n} μ(n/d) · tr(Mⁿ)`   for every `n ≥ 1`,

where `M = adjMat s` is the adjacent-sum transfer matrix.  Equivalently the *primitive*
cyclic counts `primCyc s n` — the Möbius transform of the trace sequence — count the
aperiodic cyclic adjacent-sum words, hence are divisible by their length.

The proof is the necklace argument, made precise:

* `cycExt` extends a cyclic word of length `e + 1` periodically to a cyclic word of
  length `q + 1` whenever `(e+1) ∣ (q+1)`; it is injective, rotation-equivariant, and its
  image is exactly the set of `(e+1)`-periodic words (`cycExt_surjective_on_periodic`);
* therefore the number of length-`(q+1)` words of *exact* period `d` equals the number of
  *aperiodic* words of length `d` (`card_minimalPeriod_eq_aper`);
* the abstract orbit-peeling lemma of `Applications.AdjacentSumPolytopes.Periodicity`
  gives `d ∣ aperCyc s d`, and Möbius inversion identifies `aperCyc s n = primCyc s n`.

-- !-- Lab Notes -- !--
* **Hypothesis.** `primCyc s n` counts aperiodic cyclic adjacent-sum words of length `n`,
  hence `n ∣ primCyc s n` for all `n ≥ 1`, not only for `n` prime.
* **Experiment.** `s = 2`, trace sequence `tr(Mⁿ) = 2, 6, 11, 26, 57, 129, 289` for
  `n = 1..7`.  Möbius transforms: `primCyc 1 = 2`, `primCyc 2 = 6 - 2 = 4`,
  `primCyc 3 = 11 - 2 = 9`, `primCyc 4 = 26 - 6 = 20`, `primCyc 6 = 129 - 11 - 6 + 2 = 114`.
  Divisibility: `1∣2`, `2∣4`, `3∣9`, `4∣20`, `6∣114 = 6·19`.  The composite cases `4` and
  `6` are exactly the ones the prime-only argument could not reach.
* **Analysis.** The obstruction in the previous cycle was that the `p`-group fixed-point
  theorem only sees prime lengths.  Replacing it by the exact-period decomposition
  removes the arithmetic hypothesis entirely: the only input is that rotation is an
  injective map with `rot^[n] = id`.
* **Critique.** The argument nowhere assumes the alphabet nonempty or the constraint
  nontrivial; the degenerate readings are still true statements, and for `s ≥ 0` the
  counts are positive (the all-zero word is always admissible), so the congruence is not
  vacuous.
-/

namespace AdjSum

open Finset Function Matrix

/-- The residue index `m mod (e+1)` as an element of `Fin (e+1)`. -/
def idx (e m : ℕ) : Fin (e + 1) := ⟨m % (e + 1), Nat.mod_lt _ (Nat.succ_pos e)⟩

@[simp] lemma idx_val (e m : ℕ) : (idx e m).val = m % (e + 1) := rfl

lemma idx_self (e : ℕ) (i : Fin (e + 1)) : idx e i.val = i :=
  Fin.ext (by simp [idx, Nat.mod_eq_of_lt i.isLt])

lemma idx_add_one (e m : ℕ) : idx e m + 1 = idx e (m + 1) := by
  refine Fin.ext ?_
  show (m % (e + 1) + (1 : Fin (e + 1)).val) % (e + 1) = (m + 1) % (e + 1)
  rw [Fin.val_one', ← Nat.add_mod]

/-- Auxiliary normalisation of `1 % (q+1)` modulo a divisor `e + 1` of `q + 1`. -/
lemma add_one_mod_dvd {e q : ℕ} (h : (e + 1) ∣ (q + 1)) (m : ℕ) :
    (m + 1 % (q + 1)) % (e + 1) = (m + 1) % (e + 1) := by
  rcases Nat.eq_zero_or_pos q with rfl | hq
  · have he : e = 0 := by
      have := Nat.le_of_dvd (by omega) h
      omega
    subst he
    simp
  · rw [Nat.mod_eq_of_lt (show 1 < q + 1 by omega)]

/-! ## Iterates of the rotation -/

lemma rot_iterate_apply (s q k : ℕ) (x : CycPt s q) (i : Fin (q + 1)) :
    ((rot s q)^[k] x).1 i = x.1 (idx q (i.val + k)) := by
  induction k generalizing x i with
  | zero => simp [idx_self]
  | succ k ih =>
      rw [Function.iterate_succ_apply]
      rw [ih (rot s q x) i]
      show x.1 ((idx q (i.val + k)) + 1) = _
      rw [idx_add_one, Nat.add_assoc]

lemma rot_iterate_card (s q : ℕ) (x : CycPt s q) : (rot s q)^[q + 1] x = x := by
  refine Subtype.ext ?_
  funext i
  rw [rot_iterate_apply]
  refine congrArg _ (Fin.ext ?_)
  simp [idx, Nat.add_mod_right, Nat.mod_eq_of_lt i.isLt]

lemma rot_injective (s q : ℕ) : Function.Injective (rot s q) :=
  injective_of_iterate_id (Nat.succ_pos q) (rot_iterate_card s q)

lemma rot_periodicPts (s q : ℕ) (x : CycPt s q) : x ∈ Function.periodicPts (rot s q) :=
  ⟨q + 1, Nat.succ_pos q, rot_iterate_card s q x⟩

/-! ## Periodic extension of cyclic words -/

/-- A cyclic word fixed by the `(e+1)`-fold rotation is determined by its residues
modulo `e + 1`. -/
lemma period_mod {s e q : ℕ} (x : CycPt s q)
    (hx : (rot s q)^[e + 1] x = x) (m : ℕ) :
    x.1 (idx q m) = x.1 (idx q (m % (e + 1))) := by
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    by_cases hm : m < e + 1
    · rw [Nat.mod_eq_of_lt hm]
    · push_neg at hm
      have hstep : x.1 (idx q (m - (e + 1))) = x.1 (idx q m) := by
        have := congrArg (fun z : CycPt s q => z.1 (idx q (m - (e + 1)))) hx
        simp only at this
        rw [rot_iterate_apply] at this
        rw [← this]
        refine congrArg _ (Fin.ext ?_)
        show ((m - (e + 1)) % (q + 1) + (e + 1)) % (q + 1) = m % (q + 1)
        rw [Nat.mod_add_mod]
        congr 1
        omega
      have hlt : m - (e + 1) < m := by omega
      have hmod : (m - (e + 1)) % (e + 1) = m % (e + 1) := by
        conv_rhs => rw [show m = (m - (e + 1)) + (e + 1) from by omega]
        rw [Nat.add_mod_right]
      rw [← hstep, ih _ hlt, hmod]

/-- Periodic extension of a cyclic word of length `e + 1` to one of length `q + 1`. -/
def cycExt {s e q : ℕ} (h : (e + 1) ∣ (q + 1)) (y : CycPt s e) : CycPt s q :=
  ⟨fun i => y.1 (idx e i.val), by
    rw [mem_cycSet]
    intro i
    have hy := (mem_cycSet.mp y.2) (idx e i.val)
    have hkey : idx e ((i + 1).val) = idx e i.val + 1 := by
      rw [idx_add_one]
      refine Fin.ext ?_
      show ((i.val + (1 : Fin (q + 1)).val) % (q + 1)) % (e + 1) = (i.val + 1) % (e + 1)
      rw [Fin.val_one', Nat.mod_mod_of_dvd _ h, add_one_mod_dvd h]
    rw [hkey]
    exact hy⟩

@[simp] lemma cycExt_apply {s e q : ℕ} (h : (e + 1) ∣ (q + 1)) (y : CycPt s e)
    (i : Fin (q + 1)) : (cycExt h y).1 i = y.1 (idx e i.val) := rfl

lemma cycExt_injective {s e q : ℕ} (h : (e + 1) ∣ (q + 1)) :
    Function.Injective (cycExt (s := s) h) := by
  intro y z hyz
  have hle : e + 1 ≤ q + 1 := Nat.le_of_dvd (Nat.succ_pos q) h
  refine Subtype.ext ?_
  funext j
  have hj : j.val < q + 1 := lt_of_lt_of_le j.isLt hle
  have := congrArg (fun w : CycPt s q => w.1 ⟨j.val, hj⟩) hyz
  simpa [cycExt_apply, idx, Nat.mod_eq_of_lt hj, Nat.mod_eq_of_lt j.isLt] using this

lemma cycExt_rot {s e q : ℕ} (h : (e + 1) ∣ (q + 1)) (y : CycPt s e) :
    cycExt h (rot s e y) = rot s q (cycExt h y) := by
  refine Subtype.ext ?_
  funext i
  show (rot s e y).1 (idx e i.val) = (cycExt h y).1 (i + 1)
  show y.1 (idx e i.val + 1) = y.1 (idx e ((i + 1).val))
  refine congrArg _ (Fin.ext ?_)
  rw [idx_add_one]
  show (i.val + 1) % (e + 1) = ((i.val + (1 : Fin (q + 1)).val) % (q + 1)) % (e + 1)
  rw [Fin.val_one', Nat.mod_mod_of_dvd _ h, add_one_mod_dvd h]

lemma cycExt_iterate {s e q : ℕ} (h : (e + 1) ∣ (q + 1)) (y : CycPt s e) (k : ℕ) :
    cycExt h ((rot s e)^[k] y) = (rot s q)^[k] (cycExt h y) := by
  induction k generalizing y with
  | zero => rfl
  | succ k ih =>
      rw [Function.iterate_succ_apply, Function.iterate_succ_apply, ih, cycExt_rot]

/-- The image of the periodic extension is exactly the set of `(e+1)`-periodic words. -/
lemma cycExt_surjective_on_periodic {s e q : ℕ} (h : (e + 1) ∣ (q + 1)) (x : CycPt s q)
    (hx : (rot s q)^[e + 1] x = x) : ∃ y : CycPt s e, cycExt h y = x := by
  have hle : e + 1 ≤ q + 1 := Nat.le_of_dvd (Nat.succ_pos q) h
  have hmem : (fun j : Fin (e + 1) => x.1 (idx q j.val)) ∈ cycSet s e := by
    rw [mem_cycSet]
    intro j
    have hj : j.val < q + 1 := lt_of_lt_of_le j.isLt hle
    have hx1 := (mem_cycSet.mp x.2) (idx q j.val)
    have hstep : (idx q j.val) + 1 = idx q (j.val + 1) := idx_add_one q j.val
    rw [hstep] at hx1
    have h2 : x.1 (idx q (j.val + 1)) = x.1 (idx q ((j + 1).val)) := by
      rw [period_mod x hx (j.val + 1)]
      refine congrArg _ (congrArg _ ?_)
      show (j.val + 1) % (e + 1) = (j.val + (1 : Fin (e + 1)).val) % (e + 1)
      rw [Fin.val_one', add_one_mod_dvd dvd_rfl]
    rw [h2] at hx1
    exact hx1
  refine ⟨⟨_, hmem⟩, ?_⟩
  refine Subtype.ext ?_
  funext i
  show x.1 (idx q ((idx e i.val).val)) = x.1 i
  rw [idx_val, ← period_mod x hx i.val, idx_self]

/-! ## Exact-period counts -/

/-- The number of *aperiodic* cyclic adjacent-sum words of length `q + 1`. -/
noncomputable def aperCyc (s q : ℕ) : ℕ :=
  (Finset.univ.filter
    (fun x : CycPt s q => Function.minimalPeriod (rot s q) x = q + 1)).card

lemma minimalPeriod_cycExt {s e q : ℕ} (h : (e + 1) ∣ (q + 1)) (y : CycPt s e) :
    Function.minimalPeriod (rot s q) (cycExt h y) = Function.minimalPeriod (rot s e) y := by
  have key : ∀ k : ℕ, Function.IsPeriodicPt (rot s q) k (cycExt h y)
      ↔ Function.IsPeriodicPt (rot s e) k y := by
    intro k
    constructor
    · intro hk
      have : cycExt h ((rot s e)^[k] y) = cycExt h y := by
        rw [cycExt_iterate]; exact hk
      exact cycExt_injective h this
    · intro hk
      show (rot s q)^[k] (cycExt h y) = cycExt h y
      rw [← cycExt_iterate]
      exact congrArg _ hk
  refine Nat.dvd_antisymm ?_ ?_
  · exact Function.isPeriodicPt_iff_minimalPeriod_dvd.mp
      ((key _).mpr (Function.isPeriodicPt_minimalPeriod _ _))
  · exact Function.isPeriodicPt_iff_minimalPeriod_dvd.mp
      ((key _).mp (Function.isPeriodicPt_minimalPeriod _ _))

/-- **Exact-period count = aperiodic count of the shorter length.** -/
theorem card_minimalPeriod_eq_aper {s e q : ℕ} (h : (e + 1) ∣ (q + 1)) :
    (Finset.univ.filter
      (fun x : CycPt s q => Function.minimalPeriod (rot s q) x = e + 1)).card
      = aperCyc s e := by
  rw [aperCyc]
  refine (Finset.card_bij (fun y _ => cycExt h y) ?_ ?_ ?_).symm
  · intro y hy
    rw [Finset.mem_filter] at hy ⊢
    exact ⟨Finset.mem_univ _, by rw [minimalPeriod_cycExt]; exact hy.2⟩
  · intro y _ z _ hyz
    exact cycExt_injective h hyz
  · intro x hx
    rw [Finset.mem_filter] at hx
    have hper : (rot s q)^[e + 1] x = x :=
      Function.isPeriodicPt_iff_minimalPeriod_dvd.mpr (by rw [hx.2])
    obtain ⟨y, hy⟩ := cycExt_surjective_on_periodic h x hper
    refine ⟨y, ?_, hy⟩
    rw [Finset.mem_filter]
    refine ⟨Finset.mem_univ _, ?_⟩
    rw [← minimalPeriod_cycExt h y, hy]
    exact hx.2

/-- Every aperiodic count is divisible by its length. -/
theorem length_dvd_aperCyc (s q : ℕ) : (q + 1) ∣ aperCyc s q :=
  dvd_card_minimalPeriod_eq (rot_injective s q) (rot_periodicPts s q) (Nat.succ_pos q)

/-! ## The necklace decomposition of the trace sequence -/

/-- The aperiodic counts indexed by the *length* `n` (rather than by `n - 1`). -/
noncomputable def aperN (s n : ℕ) : ℕ := if n = 0 then 0 else aperCyc s (n - 1)

lemma aperN_succ (s q : ℕ) : aperN s (q + 1) = aperCyc s q := by simp [aperN]

theorem dvd_aperN (s n : ℕ) : n ∣ aperN s n := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp [aperN]
  · obtain ⟨q, rfl⟩ : ∃ q, n = q + 1 := ⟨n - 1, by omega⟩
    rw [aperN_succ]
    exact length_dvd_aperCyc s q

/-- **Necklace decomposition.**  The trace of the `n`-th power of the transfer matrix is
the sum of the aperiodic counts over the divisors of `n`. -/
theorem sum_divisors_aperN (s n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, (aperN s d : ℤ) = traceSeq s n := by
  obtain ⟨q, rfl⟩ : ∃ q, n = q + 1 := ⟨n - 1, by omega⟩
  have hcard : Fintype.card (CycPt s q) = cycCount s q := by
    rw [cycCount]; exact Fintype.card_coe _
  have hsplit := card_eq_sum_divisors_card_minimalPeriod (f := rot s q)
    (Nat.succ_pos q) (rot_iterate_card s q)
  rw [hcard] at hsplit
  have hterm : ∀ d ∈ (q + 1).divisors,
      (Finset.univ.filter
        (fun x : CycPt s q => Function.minimalPeriod (rot s q) x = d)).card = aperN s d := by
    intro d hd
    rw [Nat.mem_divisors] at hd
    obtain ⟨e, rfl⟩ : ∃ e, d = e + 1 := ⟨d - 1, by
      rcases Nat.eq_zero_or_pos d with rfl | hd0
      · exact absurd (Nat.eq_zero_of_zero_dvd hd.1) (by omega)
      · omega⟩
    rw [aperN_succ]
    exact card_minimalPeriod_eq_aper hd.1
  rw [Finset.sum_congr rfl hterm] at hsplit
  have : (cycCount s q : ℤ) = ∑ d ∈ (q + 1).divisors, (aperN s d : ℤ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℤ)) hsplit
  rw [← this, cycCount_eq, traceSeq]

/-- **The primitive cyclic counts are the aperiodic counts.** -/
theorem primCyc_eq_aperN (s n : ℕ) (hn : 0 < n) : primCyc s n = (aperN s n : ℤ) := by
  have h := (ArithmeticFunction.sum_eq_iff_sum_smul_moebius_eq
    (f := fun d => (aperN s d : ℤ)) (g := traceSeq s)).mp
    (fun m hm => sum_divisors_aperN s m hm) n hn
  rw [primCyc]
  exact h

/-- **Full Gauss congruence.**  For every `n ≥ 1` the Möbius transform of the trace
sequence of the adjacent-sum transfer matrix is divisible by `n`. -/
theorem gauss_congruence (s n : ℕ) (hn : 0 < n) : (n : ℤ) ∣ primCyc s n := by
  rw [primCyc_eq_aperN s n hn]
  exact_mod_cast Int.natCast_dvd_natCast.mpr (dvd_aperN s n)

/-- Expanded form of the Gauss congruence in terms of traces of matrix powers. -/
theorem gauss_congruence_trace (s n : ℕ) (hn : 0 < n) :
    (n : ℤ) ∣ ∑ x ∈ n.divisorsAntidiagonal,
      (ArithmeticFunction.moebius x.1 : ℤ) * Matrix.trace (adjMatZ s ^ x.2) := by
  have h := gauss_congruence s n hn
  rw [primCyc] at h
  simpa [traceSeq, zsmul_eq_mul] using h

/-- The classical form: `tr(Mⁿ) ≡ tr(M^{n/p}) …`; for `n = p` prime this recovers the
congruence proved in `Necklace`, but the statement now holds for every `n`. -/
theorem cycCount_gauss_congruence (s q : ℕ) :
    ((q + 1 : ℕ) : ℤ) ∣ ∑ x ∈ (q + 1).divisorsAntidiagonal,
      (ArithmeticFunction.moebius x.1 : ℤ) * (cycCount s (x.2 - 1) : ℤ) := by
  have h := gauss_congruence_trace s (q + 1) (Nat.succ_pos q)
  have heq : ∑ x ∈ (q + 1).divisorsAntidiagonal,
      (ArithmeticFunction.moebius x.1 : ℤ) * (cycCount s (x.2 - 1) : ℤ)
      = ∑ x ∈ (q + 1).divisorsAntidiagonal,
        (ArithmeticFunction.moebius x.1 : ℤ) * Matrix.trace (adjMatZ s ^ x.2) := by
    refine Finset.sum_congr rfl ?_
    intro x hx
    rw [Nat.mem_divisorsAntidiagonal] at hx
    obtain ⟨hx1, hx2⟩ := hx
    obtain ⟨e, he⟩ : ∃ e, x.2 = e + 1 := by
      rcases Nat.eq_zero_or_pos x.2 with h0 | h0
      · rw [h0, Nat.mul_zero] at hx1; omega
      · exact ⟨x.2 - 1, by omega⟩
    rw [he]
    simp only [Nat.add_sub_cancel]
    rw [cycCount_eq]
  rw [heq]
  exact h

end AdjSum