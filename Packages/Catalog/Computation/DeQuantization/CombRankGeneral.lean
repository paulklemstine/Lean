import Computation.DeQuantization.CombSchmidtRank

/-!
# The exact bond dimension of a periodic comb: `min(P, r / gcd(r,Q))`

`CombSchmidtRank.lean` settled the coprime case (`gcd(Q,r) = 1`, both blocks at
least as large as the period): the Schmidt rank of the comb is exactly `r`.
Cycle 2 of the research loop removes the coprimality hypothesis entirely and
computes the rank for **every** cut:

  `rank (combMatrix P Q r x₀) = min P (r / gcd r Q)`   (for `0 < r ≤ Q`).

The arithmetic content is that the left index only ever sees the residue
`p·Q mod r`, which lives in the subgroup `g·ℤ_r` (`g = gcd(r,Q)`) of order
`s = r / g`; and `p ↦ p·Q mod r` is injective modulo `s`.  So the entanglement
carried by the comb is *not* the period `r` but the **`Q`-reduced period** `s`.

## The punchline for qubit registers

For a binary cut (`Q = 2^b`) and a period `r = 2^t · m` with `m` odd and `t ≤ b`,

  `rank = min (2^a) m`  (`qubit_comb_rank_eq_oddPart`),

i.e. *only the 2-part of the period is compressible by a tensor train*.  A period
that is a pure power of two gives a product state (bond dimension 1: the comb is
then a tensor product of `|0⟩+|1⟩`-type factors), while any odd factor `m` of the
period forces bond dimension `min(2^a, m)`.  Since the order `r = ord_N(x)`
attacked by Shor's algorithm is generically *not* a power of two, the
tensor-train emulation of the QFT on the comb is sealed at cost `Ω(m²)` with `m`
the odd part of the order — exponential in the number of qubits.

-- !-- Lab Notes -- !--

* Experiment (Experimenter, exhaustive rational Gaussian elimination on
  `combMatrix P Q r x₀` for all `1 ≤ P,Q,r ≤ 12`, `0 ≤ x₀ ≤ 3`, 6912 matrices):
  the rank always equals the number of *distinct nonzero rows*, and — whenever
  `r ≤ Q` — equals `min(P, r/gcd(r,Q))`.  Sample (`P = Q = 8`, `x₀ = 0`):
  `r = 1,2,3,4,5,6,7,8 ↦ rank 1,1,3,1,5,3,7,1`; the odd parts of `r` are
  `1,1,3,1,5,3,7,1`.  Zero mismatches.
* Critique (Critic): the hypothesis `r ≤ Q` is needed — with `Q` smaller than the
  period some residue classes are empty on the right block and the count of
  nonzero rows drops.  The `P` in the `min` is likewise not removable
  (`P = 4, Q = 16, r = 5` has rank `4 = min(4,5)`, not `5`).
* Analysis (Analyst): the previous cycle's "rank `= r`" is the `g = 1` slice of
  this formula, and the "product state when `r ∣ Q`" boundary case is the
  `s = 1` slice.  One formula unifies both.
-/

namespace DeQuantization

open Matrix

section General

variable {P Q r x0 : ℕ}

/-- The `Q`-reduced period `s = r / gcd(r, Q)`: the order of `Q` in `ℤ/r` viewed
additively, i.e. the number of distinct residues `p·Q mod r`. -/
def reducedPeriod (r Q : ℕ) : ℕ := r / Nat.gcd r Q

theorem gcd_pos_of_pos (hr : 0 < r) : 0 < Nat.gcd r Q :=
  Nat.gcd_pos_of_pos_left Q hr

theorem reducedPeriod_mul_gcd :
    reducedPeriod r Q * Nat.gcd r Q = r :=
  Nat.div_mul_cancel (Nat.gcd_dvd_left r Q)

theorem reducedPeriod_pos (hr : 0 < r) : 0 < reducedPeriod r Q :=
  Nat.div_pos (Nat.le_of_dvd hr (Nat.gcd_dvd_left r Q)) (gcd_pos_of_pos hr)

/-- Every residue `p·Q mod r` is a multiple of `g = gcd(r,Q)`. -/
theorem gcd_dvd_mul_mod (p : ℕ) : Nat.gcd r Q ∣ (p * Q) % r :=
  (Nat.dvd_mod_iff (Nat.gcd_dvd_left r Q)).2 (Dvd.dvd.mul_left (Nat.gcd_dvd_right r Q) p)

/-- Left core of a tensor train of bond dimension `s = r / gcd(r,Q)`. -/
noncomputable def combLeftRed (P Q r : ℕ) : Matrix (Fin P) (Fin (reducedPeriod r Q)) ℂ :=
  Matrix.of fun p c => if (p : ℕ) * Q % r = (c : ℕ) * Nat.gcd r Q then 1 else 0

/-- Right core of a tensor train of bond dimension `s = r / gcd(r,Q)`. -/
noncomputable def combRightRed (Q r x0 : ℕ) : Matrix (Fin (reducedPeriod r Q)) (Fin Q) ℂ :=
  Matrix.of fun c q => if ((c : ℕ) * Nat.gcd r Q + (q : ℕ)) % r = x0 % r then 1 else 0

/-- **The comb has an exact tensor train of bond dimension `r / gcd(r,Q)`.** -/
theorem combMatrix_factor_red (P Q r x0 : ℕ) (hr : 0 < r) :
    combMatrix P Q r x0 = combLeftRed P Q r * combRightRed Q r x0 := by
  classical
  ext p q
  have hgpos : 0 < Nat.gcd r Q := gcd_pos_of_pos hr
  obtain ⟨c0, hc0⟩ : Nat.gcd r Q ∣ (p : ℕ) * Q % r := gcd_dvd_mul_mod _
  have hcval : (p : ℕ) * Q % r = c0 * Nat.gcd r Q := by rw [hc0, mul_comm]
  have hc0lt : c0 < reducedPeriod r Q := by
    have h1 : c0 * Nat.gcd r Q < reducedPeriod r Q * Nat.gcd r Q := by
      rw [reducedPeriod_mul_gcd, ← hcval]; exact Nat.mod_lt _ hr
    exact lt_of_mul_lt_mul_right h1 (Nat.zero_le _)
  rw [Matrix.mul_apply, Finset.sum_eq_single (⟨c0, hc0lt⟩ : Fin (reducedPeriod r Q))]
  · have hmod : (c0 * Nat.gcd r Q + (q : ℕ)) % r = ((p : ℕ) * Q + (q : ℕ)) % r := by
      rw [← hcval]; exact Nat.mod_add_mod _ _ _
    simp only [combLeftRed, combRightRed, combMatrix, Matrix.of_apply]
    rw [if_pos hcval, one_mul, hmod]
  · intro c _ hc
    have hne : ¬ ((p : ℕ) * Q % r = (c : ℕ) * Nat.gcd r Q) := by
      intro h
      have h1 : c0 * Nat.gcd r Q = (c : ℕ) * Nat.gcd r Q := by rw [← hcval, h]
      exact hc (Fin.ext (Nat.eq_of_mul_eq_mul_right hgpos h1).symm)
    simp only [combLeftRed, Matrix.of_apply]
    rw [if_neg hne, zero_mul]
  · intro h
    exact absurd (Finset.mem_univ _) h

/-- **Upper bound.**  The bond dimension of the comb never exceeds the reduced
period `r / gcd(r,Q)`. -/
theorem combMatrix_rank_le_red (P Q r x0 : ℕ) (hr : 0 < r) :
    (combMatrix P Q r x0).rank ≤ reducedPeriod r Q := by
  rw [combMatrix_factor_red P Q r x0 hr]
  exact le_trans (Matrix.rank_mul_le_left _ _) (Matrix.rank_le_width _)

/-- **The arithmetic heart of the lower bound.**  With `k = min P (r/gcd(r,Q))`
rows `p_i = i` and columns `q_j = (x₀ - j·Q) mod r`, the comb's support condition
`p·Q + q ≡ x₀ (mod r)` holds *exactly* on the diagonal `i = j`.  The cancellation
`i·Q ≡ j·Q (mod r) ⇒ i ≡ j (mod r/gcd(r,Q))` is where the number theory enters. -/
theorem comb_delta_index {P Q r x0 : ℕ} (hr : 0 < r)
    (i j : Fin (min P (reducedPeriod r Q))) :
    ((((i : ℕ) * Q + (x0 + (r - ((j : ℕ) * Q) % r)) % r) % r = x0 % r)) ↔ i = j := by
  have hmodle : ((j : ℕ) * Q) % r ≤ r := le_of_lt (Nat.mod_lt _ hr)
  have key : (((i : ℕ) * Q + (x0 + (r - ((j : ℕ) * Q) % r)) % r : ℕ) : ZMod r)
      = (((i : ℕ) * Q : ℕ) : ZMod r) + (x0 : ZMod r) - (((j : ℕ) * Q : ℕ) : ZMod r) := by
    push_cast [ZMod.natCast_mod, Nat.cast_sub hmodle]
    simp only [ZMod.natCast_self]
    ring
  rw [comb_cond_iff, key]
  constructor
  · intro h
    have hEq : (((i : ℕ) * Q : ℕ) : ZMod r) = (((j : ℕ) * Q : ℕ) : ZMod r) := by
      linear_combination h
    have hme : ((i : ℕ) * Q) ≡ ((j : ℕ) * Q) [MOD r] :=
      (ZMod.natCast_eq_natCast_iff _ _ _).1 hEq
    have hred : (i : ℕ) ≡ (j : ℕ) [MOD reducedPeriod r Q] :=
      hme.cancel_right_div_gcd hr
    have h2 : (i : ℕ) % reducedPeriod r Q = (j : ℕ) % reducedPeriod r Q := hred
    rw [Nat.mod_eq_of_lt (lt_of_lt_of_le i.isLt (min_le_right P (reducedPeriod r Q))),
      Nat.mod_eq_of_lt (lt_of_lt_of_le j.isLt (min_le_right P (reducedPeriod r Q)))] at h2
    exact Fin.ext h2
  · rintro rfl
    ring

/-- **Lower bound.**  If the right block is at least as wide as the period, the
comb realises the full reduced period (capped by the height of the left block). -/
theorem combMatrix_rank_ge_red {P Q r x0 : ℕ} (hr : 0 < r) (hrQ : r ≤ Q) :
    min P (reducedPeriod r Q) ≤ (combMatrix P Q r x0).rank := by
  classical
  refine rank_ge_of_delta_submatrix (combMatrix P Q r x0)
    (fun i => ⟨i, lt_of_lt_of_le i.isLt (min_le_left P (reducedPeriod r Q))⟩)
    (fun j => ⟨(x0 + (r - ((j : ℕ) * Q) % r)) % r, lt_of_lt_of_le (Nat.mod_lt _ hr) hrQ⟩) ?_
  intro i j
  have hiff := comb_delta_index (P := P) (Q := Q) (x0 := x0) hr i j
  show (if _ then (1 : ℂ) else 0) = _
  by_cases h : i = j
  · rw [if_pos (hiff.mpr h), if_pos h]
  · rw [if_neg (fun hh => h (hiff.mp hh)), if_neg h]

/-- **Cycle-2 main theorem: the exact Schmidt rank of a periodic comb across an
arbitrary cut.**  For `0 < r ≤ Q`,

  `rank (combMatrix P Q r x₀) = min P (r / gcd r Q)`.

The entanglement of the comb is governed by the *reduced* period `r / gcd(r,Q)`,
not by `r` itself. -/
theorem combMatrix_rank_eq_min {P Q r x0 : ℕ} (hr : 0 < r) (hrQ : r ≤ Q) :
    (combMatrix P Q r x0).rank = min P (reducedPeriod r Q) :=
  le_antisymm (le_min (Matrix.rank_le_height _) (combMatrix_rank_le_red P Q r x0 hr))
    (combMatrix_rank_ge_red hr hrQ)

/-- Minimal bond dimension across the cut, in the general case. -/
theorem comb_hasBond_iff_min {P Q r x0 : ℕ} (hr : 0 < r) (hrQ : r ≤ Q) (D : ℕ) :
    HasBond (combMatrix P Q r x0) D ↔ min P (reducedPeriod r Q) ≤ D := by
  constructor
  · intro h
    rw [← combMatrix_rank_eq_min hr hrQ (x0 := x0)]
    exact rank_le_of_hasBond h
  · intro h
    rcases le_total P (reducedPeriod r Q) with hPs | hsP
    · refine hasBond_mono (le_trans (le_of_eq (min_eq_left hPs).symm) h) ?_
      exact ⟨1, combMatrix P Q r x0, (Matrix.one_mul (combMatrix P Q r x0)).symm⟩
    · refine hasBond_mono (le_trans (le_of_eq (min_eq_right hsP).symm) h) ?_
      exact ⟨combLeftRed P Q r, combRightRed Q r x0, combMatrix_factor_red P Q r x0 hr⟩

end General

/-! ## Rank lower bounds from the *support* alone

The next two lemmas free the argument from the specific `0/1` entries: any matrix
whose *support* is a comb (an arithmetic progression read across the cut) has the
same rank lower bound, whatever nonzero amplitudes it carries.  This is what lets
us apply the theory to the *output* of the quantum Fourier transform, whose
amplitudes are nonzero phases. -/

/-- Rank lower bound from a submatrix that is diagonal with nonzero diagonal. -/
theorem rank_ge_of_diag_submatrix {P Q k : ℕ} (A : Matrix (Fin P) (Fin Q) ℂ)
    (f : Fin k → Fin P) (g : Fin k → Fin Q)
    (hdiag : ∀ i, A (f i) (g i) ≠ 0)
    (hoff : ∀ i j, i ≠ j → A (f i) (g j) = 0) : k ≤ A.rank := by
  classical
  set E : Matrix (Fin k) (Fin P) ℂ :=
    Matrix.of fun i p => if p = f i then (A (f i) (g i))⁻¹ else 0 with hE
  set F : Matrix (Fin Q) (Fin k) ℂ := Matrix.of fun q j => if q = g j then 1 else 0 with hF
  have hEA : ∀ i q, (E * A) i q = (A (f i) (g i))⁻¹ * A (f i) q := by
    intro i q
    simp [hE, Matrix.mul_apply, ite_mul]
  have hXF : ∀ (X : Matrix (Fin k) (Fin Q) ℂ) i j, (X * F) i j = X i (g j) := by
    intro X i j
    simp [hF, Matrix.mul_apply, mul_ite]
  have key : E * (A * F) = (1 : Matrix (Fin k) (Fin k) ℂ) := by
    rw [← Matrix.mul_assoc]
    ext i j
    rw [hXF (E * A) i j, hEA i (g j), Matrix.one_apply]
    by_cases h : i = j
    · subst h
      rw [if_pos rfl, inv_mul_cancel₀ (hdiag i)]
    · rw [if_neg h, hoff i j h, mul_zero]
  calc k = (E * (A * F)).rank := by rw [key, Matrix.rank_one, Fintype.card_fin]
    _ ≤ (A * F).rank := Matrix.rank_mul_le_right E (A * F)
    _ ≤ A.rank := Matrix.rank_mul_le_left A F

/-- **Support version of the lower bound.**  Any matrix supported exactly on the
comb `p·Q + q ≡ x₀ (mod r)` — with arbitrary nonzero amplitudes there — has rank
at least `min P (r / gcd(r,Q))`. -/
theorem rank_ge_of_comb_support {P Q r x0 : ℕ} (hr : 0 < r) (hrQ : r ≤ Q)
    (N : Matrix (Fin P) (Fin Q) ℂ)
    (hsupp : ∀ (p : Fin P) (q : Fin Q), N p q ≠ 0 ↔ ((p : ℕ) * Q + (q : ℕ)) % r = x0 % r) :
    min P (reducedPeriod r Q) ≤ N.rank := by
  classical
  refine rank_ge_of_diag_submatrix N
    (fun i => ⟨i, lt_of_lt_of_le i.isLt (min_le_left P (reducedPeriod r Q))⟩)
    (fun j => ⟨(x0 + (r - ((j : ℕ) * Q) % r)) % r, lt_of_lt_of_le (Nat.mod_lt _ hr) hrQ⟩)
    (fun i => ?_) (fun i j hij => ?_)
  · exact (hsupp _ _).2 ((comb_delta_index (P := P) (Q := Q) (x0 := x0) hr i i).2 rfl)
  · by_contra hne
    exact hij ((comb_delta_index (P := P) (Q := Q) (x0 := x0) hr i j).1 ((hsupp _ _).1 hne))

/-! ## Qubit registers: only the 2-part of the period is compressible -/

/-- `gcd (2^t · m) (2^b) = 2^t` for odd `m` and `t ≤ b`. -/
theorem gcd_two_pow_mul_odd {t b m : ℕ} (hm : Odd m) (htb : t ≤ b) :
    Nat.gcd (2 ^ t * m) (2 ^ b) = 2 ^ t := by
  have h1 : (2 : ℕ) ^ b = 2 ^ t * 2 ^ (b - t) := by
    rw [← pow_add]
    congr 1
    omega
  rw [h1, Nat.gcd_mul_left]
  have h2 : Nat.gcd m (2 ^ (b - t)) = 1 :=
    Nat.Coprime.pow_right _ (Nat.coprime_two_right.mpr hm)
  rw [h2, mul_one]

/-- The reduced period of `r = 2^t·m` across a binary cut of depth `b ≥ t` is the
**odd part** `m` of the period. -/
theorem reducedPeriod_two_pow {t b m : ℕ} (hm : Odd m) (htb : t ≤ b) :
    reducedPeriod (2 ^ t * m) (2 ^ b) = m := by
  unfold reducedPeriod
  rw [gcd_two_pow_mul_odd hm htb, mul_comm, Nat.mul_div_cancel _ (Nat.two_pow_pos t)]

/-- **Odd-part law.**  Across the binary cut `2^a ⊗ 2^b`, the Schmidt rank of the
comb with period `r = 2^t·m` (`m` odd, `t ≤ b`, `r ≤ 2^b`) is `min (2^a) m`:
the 2-part of the period costs *nothing*, the odd part costs *everything*. -/
theorem qubit_comb_rank_eq_oddPart {a b t m x0 : ℕ} (hm : Odd m) (hm0 : 0 < m) (htb : t ≤ b)
    (hle : 2 ^ t * m ≤ 2 ^ b) :
    (combMatrix (2 ^ a) (2 ^ b) (2 ^ t * m) x0).rank = min (2 ^ a) m := by
  have hr : 0 < 2 ^ t * m := Nat.mul_pos (Nat.two_pow_pos t) hm0
  rw [combMatrix_rank_eq_min hr hle, reducedPeriod_two_pow hm htb]

/-- **Dichotomy.**  For a binary cut with at least one qubit on the left, the comb
is a product state (bond dimension `1`) **iff its period is a power of two**.
Every other period forces bond dimension `min (2^a) m` with `m > 1` the odd part
of the period. -/
theorem qubit_comb_product_iff_period_pow_two {a b t m x0 : ℕ} (hm : Odd m) (hm0 : 0 < m)
    (htb : t ≤ b) (hle : 2 ^ t * m ≤ 2 ^ b) (ha : 1 ≤ a) :
    HasBond (combMatrix (2 ^ a) (2 ^ b) (2 ^ t * m) x0) 1 ↔ m = 1 := by
  have hr : 0 < 2 ^ t * m := Nat.mul_pos (Nat.two_pow_pos t) hm0
  have h2a : 2 ≤ 2 ^ a := by
    calc (2 : ℕ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ a := Nat.pow_le_pow_right (by norm_num) ha
  rw [comb_hasBond_iff_min hr hle, reducedPeriod_two_pow hm htb]
  omega

/-- **De-quantization barrier, sharp form.**  Any tensor-train / MPS emulation of
the comb across the binary cut needs bond dimension at least `min (2^a) m`, where
`m` is the odd part of the period.  For a Shor order `r` with a large odd factor
and a balanced cut this is exponential in the number of qubits. -/
theorem qubit_comb_bond_ge_oddPart {a b t m x0 D : ℕ} (hm : Odd m) (hm0 : 0 < m) (htb : t ≤ b)
    (hle : 2 ^ t * m ≤ 2 ^ b)
    (h : HasBond (combMatrix (2 ^ a) (2 ^ b) (2 ^ t * m) x0) D) : min (2 ^ a) m ≤ D := by
  rw [← qubit_comb_rank_eq_oddPart hm hm0 htb hle (x0 := x0)]
  exact rank_le_of_hasBond h

/-- **Exponential barrier at the balanced cut.**  On `L = 2a` qubits split down the
middle, the comb with period `r = 2^a - 1` (an odd order, and the largest one that
still fits in the right block) needs bond dimension `≥ 2^a - 1 = 2^(L/2) - 1`:
the tensor train is exponentially large in the number of qubits, so no
`poly(L)`-time tensor-train emulation of the QFT on such a state exists.

The period `2^a - 1` is not exotic: it is exactly the kind of order that arises for
a generic base modulo a generic RSA modulus, and it is coprime to the block size,
which is the worst case for compressibility. -/
theorem qubit_comb_bond_exponential {a x0 D : ℕ} (ha : 1 ≤ a)
    (h : HasBond (combMatrix (2 ^ a) (2 ^ a) (2 ^ a - 1) x0) D) : 2 ^ a - 1 ≤ D := by
  have h2 : 2 ≤ 2 ^ a := by
    calc (2 : ℕ) = 2 ^ 1 := (pow_one 2).symm
      _ ≤ 2 ^ a := Nat.pow_le_pow_right (by norm_num) ha
  have hr : 0 < 2 ^ a - 1 := by omega
  have hsucc : (2 ^ a - 1) + 1 = 2 ^ a := by omega
  have hcop : Nat.gcd (2 ^ a - 1) (2 ^ a) = 1 := by
    rw [← hsucc]
    simp
  have hred : reducedPeriod (2 ^ a - 1) (2 ^ a) = 2 ^ a - 1 := by
    unfold reducedPeriod
    rw [hcop, Nat.div_one]
  have hrank : (combMatrix (2 ^ a) (2 ^ a) (2 ^ a - 1) x0).rank = 2 ^ a - 1 := by
    rw [combMatrix_rank_eq_min hr (by omega), hred]
    omega
  rw [← hrank]
  exact rank_le_of_hasBond h

end DeQuantization